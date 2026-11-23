//! T6-R02 piece test: framebuffer/gradient + DIB struct layout.
//!
//! This test is intentionally headless: it validates the pure-Rust pieces
//! without creating a window, so it passes even in environments with no
//! interactive desktop. The real window-open evidence comes from the
//! `win32_demo` binary run (recorded in docs/t6/reports/T6-R02.md).

#[path = "../src/platform/win32.rs"]
mod win32;

use std::mem::{offset_of, size_of};

#[test]
fn bitmap_info_header_layout_and_negative_height_roundtrip() {
    assert_eq!(
        size_of::<win32::BITMAPINFOHEADER>(),
        40,
        "BITMAPINFOHEADER must be exactly 40 bytes"
    );
    assert_eq!(size_of::<win32::BITMAPINFO>(), 44);
    assert_eq!(size_of::<win32::RECT>(), 16);
    assert_eq!(size_of::<win32::POINT>(), 8);
    assert_eq!(offset_of!(win32::BITMAPINFOHEADER, biSize), 0);
    assert_eq!(offset_of!(win32::BITMAPINFOHEADER, biWidth), 4);
    assert_eq!(offset_of!(win32::BITMAPINFOHEADER, biHeight), 8);
    assert_eq!(offset_of!(win32::BITMAPINFOHEADER, biPlanes), 12);
    assert_eq!(offset_of!(win32::BITMAPINFOHEADER, biBitCount), 14);
    assert_eq!(offset_of!(win32::BITMAPINFOHEADER, biCompression), 16);

    if cfg!(target_pointer_width = "64") {
        assert_eq!(size_of::<win32::MSG>(), 48, "Win64 MSG size");
        assert_eq!(size_of::<win32::WNDCLASSEXW>(), 80, "Win64 WNDCLASSEXW size");
    }

    let h = win32::dib_header(640, 400);
    assert_eq!(h.biSize, 40);
    assert_eq!(h.biWidth, 640);
    assert_eq!(h.biHeight, -400, "top-down DIB needs negative height");
    assert_eq!(h.biPlanes, 1);
    assert_eq!(h.biBitCount, 32);
    assert_eq!(h.biCompression, win32::BI_RGB);

    // Serialize to raw bytes and read back: field offsets really round-trip.
    let bytes = unsafe {
        std::slice::from_raw_parts(
            &h as *const win32::BITMAPINFOHEADER as *const u8,
            size_of::<win32::BITMAPINFOHEADER>(),
        )
    };
    assert_eq!(&bytes[0..4], &40u32.to_ne_bytes());
    assert_eq!(&bytes[8..12], &(-400i32).to_ne_bytes());
    let h2 = unsafe {
        std::ptr::read_unaligned(bytes.as_ptr() as *const win32::BITMAPINFOHEADER)
    };
    assert_eq!((h2.biSize, h2.biWidth, h2.biHeight), (40, 640, -400));
}

#[test]
fn gradient_is_deterministic_and_matches_demo_samples() {
    let fb = win32::make_gradient_framebuffer(640, 400);
    assert_eq!((fb.width(), fb.height()), (640, 400));
    assert_eq!(fb.as_slice().len(), 640 * 400);

    let s = fb.sample_corners_center();
    assert_eq!(
        s,
        [
            0xFF00_0080, // top-left     (r=0,   g=0)
            0xFFFF_0080, // top-right    (r=255, g=0)
            0xFF7F_7F80, // center       (r=127, g=127)
            0xFF00_FF80, // bottom-left  (r=0,   g=255)
            0xFFFF_FF80, // bottom-right (r=255, g=255)
        ]
    );

    // Monotonic in both axes (the visible gradient proof).
    assert!(win32::gradient_pixel(0, 10, 640, 400) < win32::gradient_pixel(639, 10, 640, 400));
    assert!(win32::gradient_pixel(10, 0, 640, 400) < win32::gradient_pixel(10, 399, 640, 400));
    assert_eq!(fb.pixel(320, 200), win32::gradient_pixel(320, 200, 640, 400));

    // Small / degenerate sizes must not panic or divide by zero.
    let one = win32::make_gradient_framebuffer(1, 1);
    // Single pixel has no span, so both axes map to value 0 (not a divide-by-zero).
    assert_eq!(one.pixel(0, 0), 0xFF00_0080);
}

#[test]
fn present_wrapper_rejects_short_buffer_without_a_window() {
    // Guards the length check before any HDC is touched: no window needed.
    assert!(!win32::present_pixels(0, &[0u32; 4], 640, 400));
    assert!(!win32::present_pixels(0, &[0u32; 4], 0, 400));
}
