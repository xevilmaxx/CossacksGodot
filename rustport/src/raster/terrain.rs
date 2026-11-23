//! Deterministic terrain-tile renderer (T6-R06).
//!
//! Included as a top-level module (`mod terrain;`) by the demo binary and the
//! integration test, next to top-level `framebuffer`, `dds` and `sha256`.
//! Donor block DDS files are decoded at **runtime** via the R05 reader; no
//! donor bytes are embedded here.
//!
//! # Tile assignment (deterministic, seeded)
//!
//! A 16x16 grid (64 px per tile -> 1024x1024) picks, for each `(tx,ty)`, a
//! block from a curated list of donor families documented in
//! `docs/audit/TERRAIN_DONOR_ASSETS.md` §3.2, plus a 64x64 crop origin. Every
//! choice is a `splitmix64` hash of the seed and tile coords: no unseeded
//! randomness. Same seed -> same image, byte for byte.
//!
//! # Height shading (documented)
//!
//! Height field over the whole image:
//! ```text
//! h(x,y) = 0.012*x - 0.008*y
//!        + 9.0*sin(0.011*x + p1)*cos(0.013*y + p2)
//!        + 4.0*sin(0.027*(x+y) + 0.5*p1)
//! ```
//! with `p1,p2` derived from the seed. Central differences give the gradient
//! `(gx,gy)`; the surface normal is `normalize((-2.5*gx, -2.5*gy, 1))`.
//! Light direction (unit length, screen space y down, coming from upper-left):
//! `L = (-0.5, -0.5, 0.70710678)`. Diffuse multiplier:
//! `shade = 0.30 + 0.85*max(0, dot(N, L))`, clamped to `[0, 1.5]` before being
//! applied to each sampled RGB channel. `shade_enabled=false` yields the flat
//! unshaded paste baseline (multiplier 1.0) used by the variance test.

use std::path::Path;

use crate::dds::{decode_file, DdsImage};
use crate::framebuffer::{pack, Framebuffer, TextureRef, TexVertex};

/// Fixed seed used by the demo binary and the integration test shot.
pub const SHOT_SEED: u64 = 0x4353_5333_5230_3652; // "CSS3R06R"

pub const TILES: usize = 16;
pub const TILE_PX: usize = 64;
pub const OUT_W: usize = TILES * TILE_PX; // 1024
pub const OUT_H: usize = TILES * TILE_PX; // 1024

/// Representative donor blocks, one or more per documented §3.2 family.
pub const BLOCK_NAMES: [&str; 8] = [
    "grass1.dds",        // grass
    "grass2.dds",        // grass
    "grass_ground1.dds", // grass_ground
    "grass_sand1.dds",   // grass_sand
    "ground1.dds",       // ground
    "rock1.dds",         // rock
    "sandsea1.dds",      // sandsea (donor shoreline treatment)
    "sandrock1.dds",     // sandrock
];
const BLOCK_REL: &str = r"data\terrain\tiles\textures";

/// Shading constants (see module docs).
pub const LIGHT: [f64; 3] = [-0.5, -0.5, 0.707_106_781_186_547_6];
pub const AMBIENT: f64 = 0.30;
pub const DIFFUSE: f64 = 0.85;
pub const NORMAL_SCALE: f64 = 2.5;

/// Decode the curated donor blocks at runtime. The returned vector is in the
/// same order as [`BLOCK_NAMES`].
pub fn load_blocks(donor_root: &Path) -> Result<Vec<DdsImage>, String> {
    let dir = donor_root.join(BLOCK_REL);
    let mut out = Vec::with_capacity(BLOCK_NAMES.len());
    let mut missing = Vec::new();
    for name in BLOCK_NAMES {
        let path = dir.join(name);
        match decode_file(&path) {
            Ok(img) => out.push(img),
            Err(e) => {
                missing.push(format!("{}: {e}", path.display()));
            }
        }
    }
    if !missing.is_empty() {
        return Err(format!(
            "donor blocks unavailable (run from a host with the donor installed):\n  {}",
            missing.join("\n  ")
        ));
    }
    Ok(out)
}

#[inline]
fn splitmix64(mut x: u64) -> u64 {
    x = x.wrapping_add(0x9e37_79b9_7f4a_7c15);
    x = (x ^ (x >> 30)).wrapping_mul(0xbf58_476d_1ce4_e5b9);
    x = (x ^ (x >> 27)).wrapping_mul(0x94d0_49bb_1331_11eb);
    x ^ (x >> 31)
}

/// Deterministic block index + 4-pixel-aligned crop origin for one tile.
fn tile_choice(seed: u64, tx: usize, ty: usize) -> (usize, usize, usize) {
    let base = seed
        ^ (tx as u64).wrapping_mul(0x9e37_79b9_7f4a_7c15)
        ^ (ty as u64).wrapping_mul(0xbf58_476d_1ce4_e5b9);
    let h1 = splitmix64(base);
    let h2 = splitmix64(h1 ^ 0x94d0_49bb_1331_11eb);
    let h3 = splitmix64(h2 ^ 0xabcdef01_23456789);
    let block = (h1 % BLOCK_NAMES.len() as u64) as usize;
    // Crop origin in [0, 960], aligned to 4 so it is a clean DXT block edge.
    let cx = (h2 % 241) as usize * 4;
    let cy = (h3 % 241) as usize * 4;
    (block, cx, cy)
}

#[inline]
fn seed_phase(seed: u64, which: u64) -> f64 {
    let h = splitmix64(seed ^ which.wrapping_mul(0x1234_5678_9abc_def0));
    (h & 0xffff) as f64 / 65535.0 * std::f64::consts::TAU
}

/// Height field (documented in the module header).
pub fn height(x: f64, y: f64, seed: u64) -> f64 {
    let p1 = seed_phase(seed, 1);
    let p2 = seed_phase(seed, 2);
    0.012 * x - 0.008 * y
        + 9.0 * (0.011 * x + p1).sin() * (0.013 * y + p2).cos()
        + 4.0 * (0.027 * (x + y) + 0.5 * p1).sin()
}

/// Diffuse shade multiplier at a pixel (documented in the module header).
pub fn shade_at(x: i32, y: i32, seed: u64, shade_enabled: bool) -> f64 {
    if !shade_enabled {
        return 1.0;
    }
    let (xf, yf) = (x as f64, y as f64);
    let gx = height(xf + 1.0, yf, seed) - height(xf - 1.0, yf, seed);
    let gy = height(xf, yf + 1.0, seed) - height(xf, yf - 1.0, seed);
    let nx = -NORMAL_SCALE * gx;
    let ny = -NORMAL_SCALE * gy;
    let inv = 1.0 / (nx * nx + ny * ny + 1.0).sqrt();
    let dot = (nx * LIGHT[0] + ny * LIGHT[1] + LIGHT[2]) * inv;
    AMBIENT + DIFFUSE * dot.max(0.0)
}

/// Render the seeded 16x16 terrain grid into a fresh 1024x1024 framebuffer.
/// Every tile is drawn as two textured triangles through the real rasterizer.
pub fn render_terrain(seed: u64, blocks: &[DdsImage], shade_enabled: bool) -> Framebuffer {
    assert!(!blocks.is_empty(), "no donor blocks supplied");
    let mut fb = Framebuffer::new(OUT_W, OUT_H);
    fb.clear(pack(0, 0, 0, 0)); // transparent: any uncovered pixel fails the opacity test

    for ty in 0..TILES {
        for tx in 0..TILES {
            let (bi, cx, cy) = tile_choice(seed, tx, ty);
            let img = &blocks[bi % blocks.len()];
            let tex = TextureRef {
                width: img.width as usize,
                height: img.height as usize,
                rgba: &img.rgba,
            };
            let (x0, y0) = ((tx * TILE_PX) as i32, (ty * TILE_PX) as i32);
            let (x1, y1) = (x0 + TILE_PX as i32, y0 + TILE_PX as i32);
            let (u0, u1) = (cx as f32, (cx + TILE_PX) as f32);
            let (v0, v1) = (cy as f32, (cy + TILE_PX) as f32);
            let v00 = TexVertex { x: x0, y: y0, u: u0, v: v0, z: 0.0 };
            let v10 = TexVertex { x: x1, y: y0, u: u1, v: v0, z: 0.0 };
            let v11 = TexVertex { x: x1, y: y1, u: u1, v: v1, z: 0.0 };
            let v01 = TexVertex { x: x0, y: y1, u: u0, v: v1, z: 0.0 };
            let shade = |x: i32, y: i32| -> f32 { shade_at(x, y, seed, shade_enabled) as f32 };
            fb.fill_textured_triangle([v00, v10, v11], &tex, &shade);
            fb.fill_textured_triangle([v00, v11, v01], &tex, &shade);
        }
    }
    fb
}
