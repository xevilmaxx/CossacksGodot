//! T6-R06 acceptance test: std-only rasterizer + seeded terrain tile renderer.
//!
//! Reads donor block DDS files at RUNTIME (never commits donor bytes). Writes
//! the deterministic generated render to rustport/shots/raster_piece.{raw,png}
//! and cross-checks the std-only SHA-256 against Python hashlib.
//! No Godot, no runner.

use std::path::PathBuf;
use std::process::Command;

#[path = "../src/assets/dds.rs"]
mod dds;
#[path = "../src/raster/framebuffer.rs"]
mod framebuffer;
#[path = "../src/raster/sha256.rs"]
mod sha256;
#[path = "../src/raster/terrain.rs"]
mod terrain;
#[path = "../src/raster/output.rs"]
mod output;

use dds::DdsImage;
use framebuffer::{pack, Framebuffer};
use output::{luminance_variance, write_shot};
use sha256::sha256_hex;
use terrain::{load_blocks, render_terrain, shade_at, OUT_H, OUT_W, SHOT_SEED};

const DONOR_ROOT: &str = r"C:\Games\Cossacks 3";

fn donor_blocks() -> Vec<DdsImage> {
    let donor = std::env::var_os("COSSACKS3_DONOR")
        .map(PathBuf::from)
        .unwrap_or_else(|| PathBuf::from(DONOR_ROOT));
    load_blocks(&donor).unwrap_or_else(|e| panic!("donor blocks unavailable: {e}"))
}

/// Known FIPS vector: SHA-256("abc") validates our std-only implementation.
#[test]
fn sha256_self_check() {
    assert_eq!(
        sha256_hex(b"abc"),
        "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"
    );
}

/// Geometry: exact pixel count under the top-left rule, and depth ordering
/// (near wins in both draw orders).
#[test]
fn geometry_triangle_count_and_depth() {
    let mut fb = Framebuffer::new(64, 64);
    fb.clear(pack(0, 0, 0, 0));
    let tri = [(0, 0), (10, 0), (0, 10)];
    fb.fill_triangle(tri, pack(255, 0, 0, 255), [0.0; 3]);

    let mut filled = 0usize;
    for y in 0..64 {
        for x in 0..64 {
            if fb.get_pixel(x, y).unwrap() != 0 {
                // Independent analytic check: x,y >= 0 and x+y <= 8.
                assert!(x + y <= 8, "pixel ({x},{y}) outside analytic triangle");
                filled += 1;
            }
        }
    }
    // sum_{s=0..8} (s+1) = 45 (hypotenuse x+y==9 is a right edge: excluded).
    assert_eq!(filled, 45, "unexpected top-left-rule pixel count");
    assert_eq!(fb.opaque_count(), 45);

    let far = pack(0, 255, 0, 255);
    let near = pack(0, 0, 255, 255);

    // Far then near.
    let mut a = Framebuffer::new(64, 64);
    a.fill_triangle(tri, far, [10.0; 3]);
    a.fill_triangle(tri, near, [1.0; 3]);
    assert_eq!(a.get_pixel(1, 1), Some(near), "near must overwrite far");
    assert_eq!(a.get_depth(1, 1), Some(1.0));

    // Near then far: strict `<` still keeps the near fragment.
    let mut b = Framebuffer::new(64, 64);
    b.fill_triangle(tri, near, [1.0; 3]);
    b.fill_triangle(tri, far, [10.0; 3]);
    assert_eq!(b.get_pixel(1, 1), Some(near), "far must not overwrite near");
    assert_eq!(b.get_depth(1, 1), Some(1.0));

    assert_eq!(a.to_rgba_bytes(), b.to_rgba_bytes(), "draw order must not matter");
}

/// Determinism: same seed -> byte-identical buffers; a different seed changes it.
#[test]
fn determinism_same_seed_byte_identical() {
    let blocks = donor_blocks();
    let a = render_terrain(SHOT_SEED, &blocks, true).to_rgba_bytes();
    let b = render_terrain(SHOT_SEED, &blocks, true).to_rgba_bytes();
    assert_eq!(a, b, "same seed must produce byte-identical buffers");
    assert_eq!(sha256_hex(&a), sha256_hex(&b));

    let other = render_terrain(SHOT_SEED + 1, &blocks, true).to_rgba_bytes();
    assert_ne!(a, other, "seed must influence the assignment/shading");
}

/// Terrain: 1024x1024, all opaque, visibly height-shaded vs flat paste,
/// writes the .raw/.png shot and prints paths + SHA-256.
#[test]
fn terrain_grid_shaded_vs_flat_and_shot() {
    let blocks = donor_blocks();
    let shaded = render_terrain(SHOT_SEED, &blocks, true);
    let flat = render_terrain(SHOT_SEED, &blocks, false);

    assert_eq!((shaded.width, shaded.height), (OUT_W, OUT_H));
    assert_eq!((OUT_W, OUT_H), (1024, 1024));
    assert_eq!(shaded.opaque_count(), OUT_W * OUT_H, "tile grid must cover every pixel");
    assert_eq!(flat.opaque_count(), OUT_W * OUT_H);

    let sb = shaded.to_rgba_bytes();
    let fb = flat.to_rgba_bytes();
    assert_eq!(sb.len(), OUT_W * OUT_H * 4);
    assert_ne!(sb, fb, "shaded render must differ from flat paste");

    let mut differing = 0usize;
    for (s, f) in sb.chunks_exact(4).zip(fb.chunks_exact(4)) {
        if s[0..3] != f[0..3] {
            differing += 1;
        }
    }
    eprintln!("DIFFERING_PIXELS {differing} / {}", OUT_W * OUT_H);
    assert!(differing > (OUT_W * OUT_H) / 10, "shading too subtle: {differing} px");

    let sv = luminance_variance(&shaded);
    let fv = luminance_variance(&flat);
    eprintln!("LUMINANCE_VARIANCE shaded={sv:.4} flat={fv:.4}");
    assert!(
        (sv - fv).abs() > fv * 0.05,
        "luminance variance must differ from unshaded baseline by >5%: {sv:.4} vs {fv:.4}"
    );

    // Variance of the shade multiplier field itself (independent confirmation).
    let (mut ss, mut ss2, mut n) = (0.0f64, 0.0f64, 0.0f64);
    for y in 0..OUT_H as i32 {
        for x in 0..OUT_W as i32 {
            let s = shade_at(x, y, SHOT_SEED, true);
            ss += s;
            ss2 += s * s;
            n += 1.0;
        }
    }
    let smean = ss / n;
    let svar = ss2 / n - smean * smean;
    eprintln!("SHADE_FIELD mean={smean:.5} variance={svar:.6}");
    assert!(svar > 0.0005, "height field must produce a varying shade");

    let (_raw, _png, hash) = write_shot(&shaded, "raster_piece");
    assert_eq!(hash, sha256_hex(&sb), "hash must describe the written raw");

    // Cross-check the std-only SHA-256 against Python hashlib.
    let py = Command::new("python")
        .arg("-c")
        .arg("import hashlib,sys;print(hashlib.sha256(open(sys.argv[1],'rb').read()).hexdigest())")
        .arg(&_raw)
        .output()
        .expect("python hashlib check");
    assert!(py.status.success());
    let py_hash = String::from_utf8(py.stdout).unwrap().trim().to_string();
    eprintln!("PYTHON_HASHLIB {py_hash}");
    assert_eq!(py_hash, hash, "std-only SHA-256 disagrees with hashlib");
}
