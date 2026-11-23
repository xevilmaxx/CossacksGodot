//! Shared shot-writing helpers for the T6-R06 demo binary and integration test.

use std::path::{Path, PathBuf};
use std::process::Command;

use crate::framebuffer::{alpha, blue, green, red, Framebuffer};
use crate::sha256::sha256_hex;

/// `rustport/shots/` under this package's manifest dir.
pub fn shots_dir() -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR")).join("shots")
}

/// Write `<stem>.raw` + `<stem>.png` into `rustport/shots/` and print their
/// paths and the SHA-256 of the raw bytes. Returns `(raw_path, png_path, hash)`.
pub fn write_shot(fb: &Framebuffer, stem: &str) -> (PathBuf, PathBuf, String) {
    let dir = shots_dir();
    std::fs::create_dir_all(&dir).expect("create shots dir");
    let raw = dir.join(format!("{stem}.raw"));
    let png = dir.join(format!("{stem}.png"));
    let bytes = fb.to_rgba_bytes();
    std::fs::write(&raw, &bytes).expect("write raw shot");
    let hash = sha256_hex(&bytes);

    let script = Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("tests")
        .join("tools")
        .join("raw_to_png.py");
    let status = Command::new("python")
        .arg(&script)
        .arg(&raw)
        .arg(&png)
        .arg(fb.width.to_string())
        .arg(fb.height.to_string())
        .status()
        .expect("run Pillow raw->png helper (python + Pillow required)");
    assert!(status.success(), "raw_to_png.py failed");

    println!("RAW {}", raw.display());
    println!("PNG {}", png.display());
    println!("SHA256(raw) {}", hash);
    (raw, png, hash)
}

/// Rec. 709-ish integer luminance `(77R + 150G + 29B) >> 8`, averaged used for
/// variance measurements. Opaque alpha is assumed.
pub fn luminance(p: u32) -> f64 {
    let (r, g, b) = (red(p) as u32, green(p) as u32, blue(p) as u32);
    ((77 * r + 150 * g + 29 * b) >> 8) as f64
}

/// Population luminance variance (E[x^2] - E[x]^2) over all pixels.
pub fn luminance_variance(fb: &Framebuffer) -> f64 {
    let mut sum = 0.0f64;
    let mut sum2 = 0.0f64;
    let mut n = 0.0f64;
    for y in 0..fb.height as i32 {
        for x in 0..fb.width as i32 {
            let p = fb.get_pixel(x, y).unwrap();
            debug_assert!(alpha(p) > 0);
            let l = luminance(p);
            sum += l;
            sum2 += l * l;
            n += 1.0;
        }
    }
    let mean = sum / n;
    (sum2 / n - mean * mean).max(0.0)
}
