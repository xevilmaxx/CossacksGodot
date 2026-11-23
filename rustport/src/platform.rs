//! Raw platform layer: window creation, input and framebuffer presentation.
//!
//! Selected per target with `#[cfg(...)]` attributes:
//! * `#[cfg(target_os = "windows")]` - Win32 (T6-R02)
//! * `#[cfg(any(target_os = "linux", target_os = "android"))]` - X11/Wayland (T6-R03)
//! * `#[cfg(target_os = "macos")]` - Cocoa / AppKit (T6-R04)
//!
//! No third-party windowing crates: `extern "system"` / `extern "C"` FFI only.
//! Stub - implemented by T6-R02/R03/R04.
