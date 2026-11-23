//! Minimal std-only software framebuffer and triangle rasterizer (T6-R06).
//!
//! # Pixel format
//!
//! A pixel is a packed `u32` **RGBA8 with R in the least-significant byte**:
//! `pixel = r | g<<8 | b<<16 | a<<24` (big-endian hex notation `0xAABBGGRR`).
//! On this little-endian host the in-memory bytes of that `u32` are exactly
//! `R,G,B,A`, which is also the byte order written by [`Framebuffer::to_rgba_bytes`].
//! There is no BGRA swizzle anywhere in this module.
//!
//! # Rasterization rules
//!
//! Triangle coverage uses barycentric edge functions sampled at **pixel centres**
//! `(x+0.5, y+0.5)` in screen space (x right, y down, integer corner coords).
//! Winding is normalised to positive signed area, and the classic **top-left
//! rule** resolves pixels lying exactly on a shared edge: an edge is inclusive
//! iff it is a top edge (horizontal, left-to-right) or a left edge (y
//! decreasing). This partitions adjacent triangles and tiles with no gaps and
//! no double-draws.
//!
//! A per-pixel `f32` depth buffer is kept alongside the colour buffer. Smaller
//! z is nearer; a fragment is written only when `z < depth` (**strict**), so
//! depth ordering is independent of draw order.

/// Packed RGBA8 pixel (R in the least-significant byte).
pub type Pixel = u32;

#[inline]
pub fn pack(r: u8, g: u8, b: u8, a: u8) -> Pixel {
    (r as u32) | ((g as u32) << 8) | ((b as u32) << 16) | ((a as u32) << 24)
}
#[inline]
pub fn red(p: Pixel) -> u8 {
    p as u8
}
#[inline]
pub fn green(p: Pixel) -> u8 {
    (p >> 8) as u8
}
#[inline]
pub fn blue(p: Pixel) -> u8 {
    (p >> 16) as u8
}
#[inline]
pub fn alpha(p: Pixel) -> u8 {
    (p >> 24) as u8
}

/// A borrowed row-major RGBA8 texture (pixel (x,y) at `(y*w+x)*4`).
pub struct TextureRef<'a> {
    pub width: usize,
    pub height: usize,
    pub rgba: &'a [u8],
}

/// One textured/depth triangle vertex. `x,y` are integer corner coords; `u,v`
/// are (possibly sub-integer) texture coords; `z` is the depth value.
#[derive(Debug, Clone, Copy)]
pub struct TexVertex {
    pub x: i32,
    pub y: i32,
    pub u: f32,
    pub v: f32,
    pub z: f32,
}

/// CPU-side RGBA8 framebuffer with an f32 depth buffer.
pub struct Framebuffer {
    pub width: usize,
    pub height: usize,
    pixels: Vec<Pixel>,
    depth: Vec<f32>,
}

impl Framebuffer {
    pub fn new(width: usize, height: usize) -> Self {
        Self {
            width,
            height,
            pixels: vec![0u32; width * height],
            depth: vec![f32::INFINITY; width * height],
        }
    }

    pub fn clear(&mut self, color: Pixel) {
        self.pixels.fill(color);
        self.depth.fill(f32::INFINITY);
    }

    #[inline]
    fn idx(&self, x: i32, y: i32) -> Option<usize> {
        if x < 0 || y < 0 {
            return None;
        }
        let (x, y) = (x as usize, y as usize);
        if x >= self.width || y >= self.height {
            return None;
        }
        Some(y * self.width + x)
    }

    /// Write a pixel unconditionally (no depth test). Returns false if clipped.
    pub fn put_pixel(&mut self, x: i32, y: i32, color: Pixel) -> bool {
        match self.idx(x, y) {
            Some(i) => {
                self.pixels[i] = color;
                true
            }
            None => false,
        }
    }

    /// Write a pixel with a strict `<` depth test. Returns true if written.
    pub fn put_pixel_depth(&mut self, x: i32, y: i32, color: Pixel, z: f32) -> bool {
        match self.idx(x, y) {
            Some(i) if z < self.depth[i] => {
                self.depth[i] = z;
                self.pixels[i] = color;
                true
            }
            _ => false,
        }
    }

    pub fn get_pixel(&self, x: i32, y: i32) -> Option<Pixel> {
        self.idx(x, y).map(|i| self.pixels[i])
    }

    pub fn get_depth(&self, x: i32, y: i32) -> Option<f32> {
        self.idx(x, y).map(|i| self.depth[i])
    }

    /// Number of currently opaque pixels (alpha > 0).
    pub fn opaque_count(&self) -> usize {
        self.pixels.iter().filter(|&&p| alpha(p) > 0).count()
    }

    /// Serialise the colour buffer to explicit R,G,B,A bytes (row-major).
    pub fn to_rgba_bytes(&self) -> Vec<u8> {
        let mut out = Vec::with_capacity(self.pixels.len() * 4);
        for &p in &self.pixels {
            out.extend_from_slice(&[red(p), green(p), blue(p), alpha(p)]);
        }
        out
    }

    /// Raw region copy with clipping: copies `src` (origin 0,0) to `(dx,dy)` in
    /// `self`, overwriting colour **and** depth (no depth test).
    pub fn blit(&mut self, src: &Framebuffer, dx: i32, dy: i32) {
        for y in 0..src.height as i32 {
            for x in 0..src.width as i32 {
                let Some(di) = self.idx(dx + x, dy + y) else {
                    continue;
                };
                let si = y as usize * src.width + x as usize;
                self.pixels[di] = src.pixels[si];
                self.depth[di] = src.depth[si];
            }
        }
    }

    // ---- edge functions -------------------------------------------------

    /// Twice the signed area of triangle `(a,b,c)`; positive for our CCW
    /// convention in screen space (y down).
    #[inline]
    fn edge(ax: f64, ay: f64, bx: f64, by: f64, px: f64, py: f64) -> f64 {
        (bx - ax) * (py - ay) - (by - ay) * (px - ax)
    }

    /// Top-left rule: an edge (integer corner coords) is inclusive iff it is a
    /// top edge (horizontal, left-to-right) or a left edge (y decreasing).
    #[inline]
    fn top_left(ax: i32, ay: i32, bx: i32, by: i32) -> bool {
        (ay == by && ax < bx) || by < ay
    }

    /// Shared rasterizer. The callback receives `(x, y, l0, l1, l2)` (normalised
    /// barycentric weights) and returns the `(colour, depth)` to write, or
    /// `None` to skip the pixel.
    fn rasterize<F>(&mut self, p: [(i32, i32); 3], mut fragment: F)
    where
        F: FnMut(i32, i32, f64, f64, f64) -> Option<(Pixel, f32)>,
    {
        let mut v = p;
        let mut area = Self::edge(
            v[0].0 as f64, v[0].1 as f64,
            v[1].0 as f64, v[1].1 as f64,
            v[2].0 as f64, v[2].1 as f64,
        );
        if area == 0.0 {
            return;
        }
        if area < 0.0 {
            v.swap(1, 2);
            area = -area;
        }
        let (a, b, c) = (v[0], v[1], v[2]);
        // Edges opposite vertices a,b,c respectively.
        let inc_a = Self::top_left(b.0, b.1, c.0, c.1);
        let inc_b = Self::top_left(c.0, c.1, a.0, a.1);
        let inc_c = Self::top_left(a.0, a.1, b.0, b.1);

        let xmin = a.0.min(b.0).min(c.0);
        let xmax = a.0.max(b.0).max(c.0);
        let ymin = a.1.min(b.1).min(c.1);
        let ymax = a.1.max(b.1).max(c.1);

        for y in ymin..=ymax {
            for x in xmin..=xmax {
                let (px, py) = (x as f64 + 0.5, y as f64 + 0.5);
                let w_a = Self::edge(
                    b.0 as f64, b.1 as f64, c.0 as f64, c.1 as f64, px, py,
                );
                if w_a < 0.0 || (w_a == 0.0 && !inc_a) {
                    continue;
                }
                let w_b = Self::edge(
                    c.0 as f64, c.1 as f64, a.0 as f64, a.1 as f64, px, py,
                );
                if w_b < 0.0 || (w_b == 0.0 && !inc_b) {
                    continue;
                }
                let w_c = Self::edge(
                    a.0 as f64, a.1 as f64, b.0 as f64, b.1 as f64, px, py,
                );
                if w_c < 0.0 || (w_c == 0.0 && !inc_c) {
                    continue;
                }
                let l0 = w_a / area;
                let l1 = w_b / area;
                let l2 = w_c / area;
                if let Some((color, z)) = fragment(x, y, l0, l1, l2) {
                    self.put_pixel_depth(x, y, color, z);
                }
            }
        }
    }

    /// Flat-colour triangle with per-vertex depth (linearly interpolated).
    pub fn fill_triangle(&mut self, p: [(i32, i32); 3], color: Pixel, z: [f32; 3]) {
        self.rasterize(p, |_, _, l0, l1, l2| {
            Some((color, (l0 * z[0] as f64 + l1 * z[1] as f64 + l2 * z[2] as f64) as f32))
        });
    }

    /// Gouraud-style triangle: per-vertex RGBA is interpolated channel-wise.
    pub fn fill_triangle_gradient(&mut self, p: [(i32, i32); 3], colors: [Pixel; 3], z: [f32; 3]) {
        self.rasterize(p, |_, _, l0, l1, l2| {
            let mix = |i: usize| -> u8 {
                let c = l0 * colors[0].to_le_bytes()[i] as f64
                    + l1 * colors[1].to_le_bytes()[i] as f64
                    + l2 * colors[2].to_le_bytes()[i] as f64;
                c.round().clamp(0.0, 255.0) as u8
            };
            let zz = (l0 * z[0] as f64 + l1 * z[1] as f64 + l2 * z[2] as f64) as f32;
            let (r, g, b, a) = (mix(0), mix(1), mix(2), mix(3));
            Some((pack(r, g, b, a), zz))
        });
    }

    /// Textured triangle with affine UVs. `shade(x,y)` is a multiplier applied
    /// to the sampled RGB (forced alpha 255; donor alpha is dropped by the port).
    pub fn fill_textured_triangle(
        &mut self,
        v: [TexVertex; 3],
        tex: &TextureRef<'_>,
        shade: &dyn Fn(i32, i32) -> f32,
    ) {
        let p = [(v[0].x, v[0].y), (v[1].x, v[1].y), (v[2].x, v[2].y)];
        self.rasterize(p, |x, y, l0, l1, l2| {
            let u = (l0 * v[0].u as f64 + l1 * v[1].u as f64 + l2 * v[2].u as f64) as f32;
            let tv = (l0 * v[0].v as f64 + l1 * v[1].v as f64 + l2 * v[2].v as f64) as f32;
            let zz = (l0 * v[0].z as f64 + l1 * v[1].z as f64 + l2 * v[2].z as f64) as f32;
            let sx = ((u + 0.5) as i64).clamp(0, tex.width as i64 - 1) as usize;
            let sy = ((tv + 0.5) as i64).clamp(0, tex.height as i64 - 1) as usize;
            let i = (sy * tex.width + sx) * 4;
            let s = shade(x, y).clamp(0.0, 1.5) as f64;
            let ch = |k: usize| -> u8 {
                (tex.rgba[i + k] as f64 * s).round().clamp(0.0, 255.0) as u8
            };
            Some((pack(ch(0), ch(1), ch(2), 255), zz))
        });
    }
}
