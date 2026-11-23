//! Win32 platform backend for the pure-Rust Cossacks 3 port (ticket T6-R02).
//!
//! Raw FFI only: hand-written `extern "system"` declarations against
//! `user32.dll`, `gdi32.dll` and `kernel32.dll`. No third-party crates, no
//! bindings crates, `std` only.
//!
//! # Pixel format
//!
//! The software framebuffer is `Vec<u32>` in **BGRA byte order**. On a little
//! endian host the `u32` value is `0xAARRGGBB`, i.e. memory bytes are
//! `[blue, green, red, alpha]`. This matches a 32-bpp `BI_RGB` Windows DIB,
//! so `present_pixels` can pass the buffer straight to `StretchDIBits` with a
//! `BITMAPINFOHEADER` whose `biHeight` is **negative** (top-down DIB).
//!
//! # Ownership / reentrancy note
//!
//! Win32 has no user-data parameter on the window procedure, so a pointer to
//! the heap-allocated `SharedState` is stashed in `GWLP_USERDATA` during
//! `WM_CREATE` and recovered in every later message. `Window` owns the `Box`;
//! the message loop never holds a borrow into that Box across
//! `DispatchMessageW`, so the raw-pointer writes in `WndProc` do not alias a
//! live Rust reference.

#![allow(non_snake_case, non_camel_case_types)]
// This module is included directly by the demo/test binaries, so rustc sees
// only a subset of the API in each crate. The rest is intentional surface for
// the integration ticket that wires `platform` into lib.rs.
#![allow(dead_code)]

use std::ffi::c_void;
use std::mem::size_of;
use std::ptr::null;

// ---------------------------------------------------------------------------
// Win32 scalar typedefs (pointer-width handles, so this is x86/x64 correct).
// ---------------------------------------------------------------------------

pub type HWND = isize;
pub type HDC = isize;
pub type HINSTANCE = isize;
pub type HCURSOR = isize;
pub type HBRUSH = isize;
pub type WPARAM = usize;
pub type LPARAM = isize;
pub type LRESULT = isize;
pub type BOOL = i32;
pub type UINT = u32;
pub type DWORD = u32;
pub type ATOM = u16;
pub type UINT_PTR = usize;

// ---------------------------------------------------------------------------
// Constants used by this backend (names kept Win32-recognisable).
// ---------------------------------------------------------------------------

pub const WM_CREATE: UINT = 0x0001;
pub const WM_DESTROY: UINT = 0x0002;
pub const WM_SIZE: UINT = 0x0005;
pub const WM_PAINT: UINT = 0x000F;
pub const WM_CLOSE: UINT = 0x0010;
pub const WM_QUIT: UINT = 0x0012;
pub const WM_KEYDOWN: UINT = 0x0100;
pub const WM_KEYUP: UINT = 0x0101;
pub const WM_TIMER: UINT = 0x0113;
pub const WM_MOUSEMOVE: UINT = 0x0200;
pub const WM_LBUTTONDOWN: UINT = 0x0201;
pub const WM_LBUTTONUP: UINT = 0x0202;
pub const WM_RBUTTONDOWN: UINT = 0x0204;
pub const WM_RBUTTONUP: UINT = 0x0205;

pub const CS_HREDRAW: UINT = 0x0001;
pub const CS_VREDRAW: UINT = 0x0002;
pub const CS_OWNDC: UINT = 0x0020;
pub const WS_OVERLAPPEDWINDOW: DWORD = 0x00CF_0000;
pub const SW_SHOW: i32 = 5;
pub const COLOR_WINDOW: i32 = 5;
pub const IDC_ARROW: isize = 32512;
pub const CW_USEDEFAULT: i32 = i32::MIN;
pub const GWLP_USERDATA: i32 = -21;
pub const ERROR_CLASS_ALREADY_EXISTS: i32 = 1410;

pub const BI_RGB: DWORD = 0;
pub const DIB_RGB_COLORS: UINT = 0;
pub const SRCCOPY: DWORD = 0x00CC_0020;

/// Timer id used by the demo. `WM_TIMER` passes it back in `wparam`.
pub const DEMO_TIMER_ID: UINT_PTR = 1;

// ---------------------------------------------------------------------------
// FFI structs. All are `#[repr(C)]` and match the Win32 ABI on x86_64.
// ---------------------------------------------------------------------------

#[repr(C)]
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
pub struct POINT {
    pub x: i32,
    pub y: i32,
}

#[repr(C)]
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
pub struct RECT {
    pub left: i32,
    pub top: i32,
    pub right: i32,
    pub bottom: i32,
}

#[repr(C)]
#[derive(Clone, Copy, Debug, Default)]
pub struct MSG {
    pub hwnd: HWND,
    pub message: UINT,
    pub wparam: WPARAM,
    pub lparam: LPARAM,
    pub time: DWORD,
    pub pt: POINT,
}

pub type WndProcFn = unsafe extern "system" fn(HWND, UINT, WPARAM, LPARAM) -> LRESULT;

#[repr(C)]
pub struct WNDCLASSEXW {
    pub cbSize: UINT,
    pub style: UINT,
    pub lpfnWndProc: Option<WndProcFn>,
    pub cbClsExtra: i32,
    pub cbWndExtra: i32,
    pub hInstance: HINSTANCE,
    pub hIcon: isize,
    pub hCursor: HCURSOR,
    pub hbrBackground: HBRUSH,
    pub lpszMenuName: *const u16,
    pub lpszClassName: *const u16,
    pub hIconSm: isize,
}

/// Only the first field of `CREATESTRUCTW` is read in `WM_CREATE`; keeping the
/// definition minimal is safe because `lpCreateParams` sits at offset 0.
#[repr(C)]
struct CREATESTRUCTW {
    lpCreateParams: *mut c_void,
}

#[repr(C)]
#[derive(Clone, Copy, Debug)]
pub struct PAINTSTRUCT {
    pub hdc: HDC,
    pub fErase: BOOL,
    pub rcPaint: RECT,
    pub fRestore: BOOL,
    pub fIncUpdate: BOOL,
    pub rgbReserved: [u8; 32],
}

impl Default for PAINTSTRUCT {
    fn default() -> Self {
        Self {
            hdc: 0,
            fErase: 0,
            rcPaint: RECT::default(),
            fRestore: 0,
            fIncUpdate: 0,
            rgbReserved: [0; 32],
        }
    }
}

#[repr(C)]
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
pub struct RGBQUAD {
    pub rgbBlue: u8,
    pub rgbGreen: u8,
    pub rgbRed: u8,
    pub rgbReserved: u8,
}

/// 40-byte DIB header. `biHeight < 0` means a top-down DIB.
#[repr(C)]
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct BITMAPINFOHEADER {
    pub biSize: DWORD,
    pub biWidth: i32,
    pub biHeight: i32,
    pub biPlanes: u16,
    pub biBitCount: u16,
    pub biCompression: DWORD,
    pub biSizeImage: DWORD,
    pub biXPelsPerMeter: i32,
    pub biYPelsPerMeter: i32,
    pub biClrUsed: DWORD,
    pub biClrImportant: DWORD,
}

impl Default for BITMAPINFOHEADER {
    fn default() -> Self {
        Self {
            biSize: size_of::<BITMAPINFOHEADER>() as DWORD,
            biWidth: 0,
            biHeight: 0,
            biPlanes: 1,
            biBitCount: 32,
            biCompression: BI_RGB,
            biSizeImage: 0,
            biXPelsPerMeter: 0,
            biYPelsPerMeter: 0,
            biClrUsed: 0,
            biClrImportant: 0,
        }
    }
}

#[repr(C)]
#[derive(Clone, Copy, Debug)]
pub struct BITMAPINFO {
    pub bmiHeader: BITMAPINFOHEADER,
    pub bmiColors: [RGBQUAD; 1],
}

// ---------------------------------------------------------------------------
// Raw imports. Explicit #[link] makes the dependency on the three system DLLs
// obvious and works for both msvc and gnu targets.
// ---------------------------------------------------------------------------

#[link(name = "user32")]
extern "system" {
    pub fn RegisterClassExW(lpwcx: *const WNDCLASSEXW) -> ATOM;
    pub fn CreateWindowExW(
        dwExStyle: DWORD,
        lpClassName: *const u16,
        lpWindowName: *const u16,
        dwStyle: DWORD,
        x: i32,
        y: i32,
        nWidth: i32,
        nHeight: i32,
        hWndParent: HWND,
        hMenu: isize,
        hInstance: HINSTANCE,
        lpParam: *const c_void,
    ) -> HWND;
    pub fn DefWindowProcW(hwnd: HWND, msg: UINT, wparam: WPARAM, lparam: LPARAM) -> LRESULT;
    pub fn GetMessageW(lpMsg: *mut MSG, hwnd: HWND, wMsgFilterMin: UINT, wMsgFilterMax: UINT) -> BOOL;
    pub fn TranslateMessage(lpMsg: *const MSG) -> BOOL;
    pub fn DispatchMessageW(lpMsg: *const MSG) -> LRESULT;
    pub fn PostQuitMessage(nExitCode: i32);
    pub fn PostThreadMessageW(idThread: DWORD, msg: UINT, wparam: WPARAM, lparam: LPARAM) -> BOOL;
    pub fn ShowWindow(hwnd: HWND, nCmdShow: i32) -> BOOL;
    pub fn UpdateWindow(hwnd: HWND) -> BOOL;
    pub fn GetClientRect(hwnd: HWND, lprc: *mut RECT) -> BOOL;
    pub fn LoadCursorW(hInstance: HINSTANCE, lpCursorName: *const u16) -> HCURSOR;
    pub fn InvalidateRect(hwnd: HWND, lpRect: *const RECT, bErase: BOOL) -> BOOL;
    pub fn SetTimer(
        hwnd: HWND,
        nIDEvent: UINT_PTR,
        uElapse: UINT,
        lpTimerFunc: Option<unsafe extern "system" fn(HWND, UINT, UINT_PTR, DWORD)>,
    ) -> UINT_PTR;
    pub fn KillTimer(hwnd: HWND, uIDEvent: UINT_PTR) -> BOOL;
    pub fn SetWindowLongPtrW(hwnd: HWND, nIndex: i32, dwNewLong: isize) -> isize;
    pub fn GetWindowLongPtrW(hwnd: HWND, nIndex: i32) -> isize;
    pub fn DestroyWindow(hwnd: HWND) -> BOOL;
    pub fn BeginPaint(hwnd: HWND, lpPaint: *mut PAINTSTRUCT) -> HDC;
    pub fn EndPaint(hwnd: HWND, lpPaint: *const PAINTSTRUCT) -> BOOL;
    pub fn GetDC(hwnd: HWND) -> HDC;
    pub fn ReleaseDC(hwnd: HWND, hdc: HDC) -> i32;
}

#[link(name = "gdi32")]
extern "system" {
    pub fn StretchDIBits(
        hdc: HDC,
        xDest: i32,
        yDest: i32,
        nDestWidth: i32,
        nDestHeight: i32,
        xSrc: i32,
        ySrc: i32,
        nSrcWidth: i32,
        nSrcHeight: i32,
        lpBits: *const c_void,
        lpBitsInfo: *const BITMAPINFO,
        iUsage: UINT,
        dwRop: DWORD,
    ) -> i32;
}

#[link(name = "kernel32")]
extern "system" {
    pub fn GetModuleHandleW(lpModuleName: *const u16) -> HINSTANCE;
    pub fn GetCurrentThreadId() -> DWORD;
}

// ---------------------------------------------------------------------------
// Software framebuffer + deterministic test pattern.
// ---------------------------------------------------------------------------

/// Owned RGBA/BGRA software framebuffer. See module docs for pixel format.
#[derive(Clone, Debug)]
pub struct Framebuffer {
    pixels: Vec<u32>,
    width: u32,
    height: u32,
}

impl Framebuffer {
    pub fn new(width: u32, height: u32) -> Self {
        Self {
            pixels: vec![0u32; (width as usize).saturating_mul(height as usize)],
            width,
            height,
        }
    }

    pub fn width(&self) -> u32 {
        self.width
    }

    pub fn height(&self) -> u32 {
        self.height
    }

    pub fn as_slice(&self) -> &[u32] {
        &self.pixels
    }

    pub fn as_slice_mut(&mut self) -> &mut [u32] {
        &mut self.pixels
    }

    pub fn pixel(&self, x: u32, y: u32) -> u32 {
        assert!(x < self.width && y < self.height, "pixel out of bounds");
        self.pixels[(y as usize) * (self.width as usize) + (x as usize)]
    }

    pub fn put_pixel(&mut self, x: u32, y: u32, value: u32) {
        assert!(x < self.width && y < self.height, "pixel out of bounds");
        let i = (y as usize) * (self.width as usize) + (x as usize);
        self.pixels[i] = value;
    }

    /// [top-left, top-right, center, bottom-left, bottom-right] as BGRA `u32`.
    pub fn sample_corners_center(&self) -> [u32; 5] {
        let xr = self.width.saturating_sub(1);
        let yb = self.height.saturating_sub(1);
        let xc = self.width / 2;
        let yc = self.height / 2;
        [
            self.pixel(0, 0),
            self.pixel(xr, 0),
            self.pixel(xc, yc),
            self.pixel(0, yb),
            self.pixel(xr, yb),
        ]
    }

    /// Present the whole buffer to a window's client area via `StretchDIBits`.
    pub fn present(&self, hwnd: HWND) -> bool {
        present_pixels(hwnd, self.as_slice(), self.width, self.height)
    }
}

/// Pure function: red increases left→right, green increases top→bottom,
/// blue is a constant 0x80 so all five samples stay distinguishable.
/// Result is a BGRA `u32` (`0xAARRGGBB`).
pub fn gradient_pixel(x: u32, y: u32, width: u32, height: u32) -> u32 {
    let wx = width.saturating_sub(1).max(1);
    let hy = height.saturating_sub(1).max(1);
    let r = (x.min(wx) * 255 / wx) & 0xFF;
    let g = (y.min(hy) * 255 / hy) & 0xFF;
    let b = 0x80u32;
    let a = 0xFFu32;
    (a << 24) | (r << 16) | (g << 8) | b
}

/// Build a deterministic horizontal+vertical gradient framebuffer.
pub fn make_gradient_framebuffer(width: u32, height: u32) -> Framebuffer {
    let mut fb = Framebuffer::new(width, height);
    for y in 0..height {
        let row = (y as usize) * (width as usize);
        for x in 0..width {
            fb.pixels[row + x as usize] = gradient_pixel(x, y, width, height);
        }
    }
    fb
}

/// Build the 40-byte top-down 32-bpp BI_RGB DIB header for a framebuffer.
pub fn dib_header(width: u32, height: u32) -> BITMAPINFOHEADER {
    BITMAPINFOHEADER {
        biSize: size_of::<BITMAPINFOHEADER>() as DWORD, // must be 40
        biWidth: width as i32,
        biHeight: -(height as i32), // NEGATIVE => top-down rows
        biPlanes: 1,
        biBitCount: 32,
        biCompression: BI_RGB,
        biSizeImage: width.saturating_mul(height).saturating_mul(4),
        biXPelsPerMeter: 0,
        biYPelsPerMeter: 0,
        biClrUsed: 0,
        biClrImportant: 0,
    }
}

/// Safe-ish wrapper over `StretchDIBits`: takes only a shared `&[u32]` slice
/// and validates its length before touching FFI. Returns `false` on bad input
/// or if no device context could be obtained.
pub fn present_pixels(hwnd: HWND, pixels: &[u32], width: u32, height: u32) -> bool {
    if width == 0 || height == 0 {
        return false;
    }
    if pixels.len() < (width as usize).saturating_mul(height as usize) {
        return false;
    }
    unsafe {
        let hdc = GetDC(hwnd);
        if hdc == 0 {
            return false;
        }
        let ok = present_to_dc(hdc, pixels, width, height);
        ReleaseDC(hwnd, hdc);
        ok
    }
}

/// Present into an already-open HDC (used by `present_pixels` and `WM_PAINT`).
fn present_to_dc(hdc: HDC, pixels: &[u32], width: u32, height: u32) -> bool {
    let info = BITMAPINFO {
        bmiHeader: dib_header(width, height),
        bmiColors: [RGBQUAD::default()],
    };
    unsafe {
        StretchDIBits(
            hdc,
            0,
            0,
            width as i32,
            height as i32, // destination: 1:1 in device pixels
            0,
            0,
            width as i32,
            height as i32, // source: whole top-down DIB
            pixels.as_ptr() as *const c_void,
            &info as *const BITMAPINFO,
            DIB_RGB_COLORS,
            SRCCOPY,
        ) > 0
    }
}

/// Post a quit message to the current thread's message loop.
pub fn post_quit() {
    unsafe { PostQuitMessage(0) }
}

// ---------------------------------------------------------------------------
// Input state (read-only from outside this module).
// ---------------------------------------------------------------------------

#[derive(Clone, Debug)]
pub struct InputState {
    keys: [bool; 256],
    cursor_x: i32,
    cursor_y: i32,
    left_down: bool,
    right_down: bool,
}

impl Default for InputState {
    fn default() -> Self {
        Self {
            keys: [false; 256],
            cursor_x: 0,
            cursor_y: 0,
            left_down: false,
            right_down: false,
        }
    }
}

impl InputState {
    /// True while the given Win32 virtual-key code is held down.
    pub fn key_down(&self, vk: u16) -> bool {
        (vk as usize) < 256 && self.keys[vk as usize]
    }

    /// Most recent client-space cursor position, in pixels.
    pub fn cursor(&self) -> (i32, i32) {
        (self.cursor_x, self.cursor_y)
    }

    pub fn left_button_down(&self) -> bool {
        self.left_down
    }

    pub fn right_button_down(&self) -> bool {
        self.right_down
    }
}

struct SharedState {
    input: InputState,
    client_width: i32,
    client_height: i32,
    framebuffer: Framebuffer,
}

unsafe fn state_ptr(hwnd: HWND) -> Option<*mut SharedState> {
    let raw = GetWindowLongPtrW(hwnd, GWLP_USERDATA);
    if raw == 0 {
        None
    } else {
        Some(raw as *mut SharedState)
    }
}

/// Window procedure. `WM_CREATE` captures the `SharedState*` passed through
/// `CreateWindowExW`'s `lpParam`; all later messages recover it from user data.
unsafe extern "system" fn wnd_proc(
    hwnd: HWND,
    msg: UINT,
    wparam: WPARAM,
    lparam: LPARAM,
) -> LRESULT {
    match msg {
        WM_CREATE => {
            let cs = lparam as *const CREATESTRUCTW;
            if !cs.is_null() {
                let state = (*cs).lpCreateParams as *mut SharedState;
                SetWindowLongPtrW(hwnd, GWLP_USERDATA, state as isize);
            }
            0
        }
        WM_DESTROY => {
            PostQuitMessage(0);
            0
        }
        WM_TIMER => {
            // The demo's auto-close path: kill the timer, then quit the loop.
            KillTimer(hwnd, wparam);
            PostQuitMessage(0);
            0
        }
        WM_SIZE => {
            if let Some(st) = state_ptr(hwnd) {
                let w = (lparam as u32 & 0xFFFF) as u16 as i32;
                let h = ((lparam as u32 >> 16) & 0xFFFF) as u16 as i32;
                (*st).client_width = w;
                (*st).client_height = h;
            }
            InvalidateRect(hwnd, null(), 1);
            0
        }
        WM_KEYDOWN | WM_KEYUP => {
            if let Some(st) = state_ptr(hwnd) {
                if wparam < 256 {
                    (*st).input.keys[wparam] = msg == WM_KEYDOWN;
                }
            }
            0
        }
        WM_MOUSEMOVE => {
            if let Some(st) = state_ptr(hwnd) {
                let x = ((lparam as u32) & 0xFFFF) as u16 as i16 as i32;
                let y = ((lparam as u32 >> 16) & 0xFFFF) as u16 as i16 as i32;
                (*st).input.cursor_x = x;
                (*st).input.cursor_y = y;
            }
            0
        }
        WM_LBUTTONDOWN | WM_LBUTTONUP => {
            if let Some(st) = state_ptr(hwnd) {
                (*st).input.left_down = msg == WM_LBUTTONDOWN;
            }
            0
        }
        WM_RBUTTONDOWN | WM_RBUTTONUP => {
            if let Some(st) = state_ptr(hwnd) {
                (*st).input.right_down = msg == WM_RBUTTONDOWN;
            }
            0
        }
        WM_PAINT => {
            let mut ps = PAINTSTRUCT::default();
            let hdc = BeginPaint(hwnd, &mut ps);
            if let Some(st) = state_ptr(hwnd) {
                let fb = &(*st).framebuffer;
                present_to_dc(hdc, fb.as_slice(), fb.width(), fb.height());
            }
            EndPaint(hwnd, &ps);
            0
        }
        _ => DefWindowProcW(hwnd, msg, wparam, lparam),
    }
}

fn to_wide(s: &str) -> Vec<u16> {
    let mut v: Vec<u16> = s.encode_utf16().collect();
    v.push(0); // NUL terminator for the Win32 W APIs
    v
}

// ---------------------------------------------------------------------------
// Window owner.
// ---------------------------------------------------------------------------

/// A top-level overlapped Win32 window with an owned software framebuffer.
pub struct Window {
    hwnd: HWND,
    state: Box<SharedState>,
    timer_id: UINT_PTR,
}

impl Window {
    /// Register the class (idempotent across multiple instances), create a
    /// window and allocate its framebuffer.
    pub fn new(width: u32, height: u32, caption: &str) -> Result<Self, String> {
        unsafe {
            let hinst = GetModuleHandleW(null());
            if hinst == 0 {
                return Err("GetModuleHandleW failed".to_string());
            }

            let class_name = to_wide("Cossacks3RustWin32");
            let caption_wide = to_wide(caption);

            let wc = WNDCLASSEXW {
                cbSize: size_of::<WNDCLASSEXW>() as UINT,
                style: CS_HREDRAW | CS_VREDRAW | CS_OWNDC,
                lpfnWndProc: Some(wnd_proc),
                cbClsExtra: 0,
                cbWndExtra: 0,
                hInstance: hinst,
                hIcon: 0,
                hCursor: LoadCursorW(0, IDC_ARROW as *const u16),
                hbrBackground: (COLOR_WINDOW + 1) as HBRUSH,
                lpszMenuName: null(),
                lpszClassName: class_name.as_ptr(),
                hIconSm: 0,
            };
            let atom = RegisterClassExW(&wc);
            if atom == 0 {
                let err = std::io::Error::last_os_error();
                if err.raw_os_error() != Some(ERROR_CLASS_ALREADY_EXISTS) {
                    return Err(format!("RegisterClassExW failed: {err}"));
                }
            }

            let mut state = Box::new(SharedState {
                input: InputState::default(),
                client_width: width as i32,
                client_height: height as i32,
                framebuffer: Framebuffer::new(width, height),
            });
            // Moving the Box into Window does not move the pointee.
            let state_ptr = (&mut *state) as *mut SharedState;

            let hwnd = CreateWindowExW(
                0,
                class_name.as_ptr(),
                caption_wide.as_ptr(),
                WS_OVERLAPPEDWINDOW,
                CW_USEDEFAULT,
                CW_USEDEFAULT,
                width as i32,
                height as i32,
                0,
                0,
                hinst,
                state_ptr as *const c_void,
            );
            if hwnd == 0 {
                return Err(format!(
                    "CreateWindowExW failed: {}",
                    std::io::Error::last_os_error()
                ));
            }

            ShowWindow(hwnd, SW_SHOW);
            UpdateWindow(hwnd);
            let mut rc = RECT::default();
            if GetClientRect(hwnd, &mut rc) != 0 {
                state.client_width = rc.right - rc.left;
                state.client_height = rc.bottom - rc.top;
            }

            Ok(Self {
                hwnd,
                state,
                timer_id: 0,
            })
        }
    }

    pub fn hwnd(&self) -> HWND {
        self.hwnd
    }

    pub fn framebuffer(&self) -> &Framebuffer {
        &self.state.framebuffer
    }

    pub fn framebuffer_mut(&mut self) -> &mut Framebuffer {
        &mut self.state.framebuffer
    }

    /// Read-only view of the latest keyboard/mouse state.
    pub fn input(&self) -> &InputState {
        &self.state.input
    }

    pub fn client_size(&self) -> (i32, i32) {
        (self.state.client_width, self.state.client_height)
    }

    /// Present the current framebuffer to the client area.
    pub fn present(&self) -> bool {
        self.framebuffer().present(self.hwnd)
    }

    /// Start a one-shot-style timer; `WM_TIMER` kills it and posts quit.
    pub fn set_timer(&mut self, id: UINT_PTR, elapse_ms: u32) -> bool {
        let ok = unsafe { SetTimer(self.hwnd, id, elapse_ms, None) != 0 };
        if ok {
            self.timer_id = id;
        }
        ok
    }

    /// Blocking `GetMessageW` loop. Returns when `WM_QUIT` arrives.
    pub fn run_message_loop(&mut self) {
        let mut msg = MSG::default();
        loop {
            let ret = unsafe { GetMessageW(&mut msg, 0, 0, 0) };
            if ret <= 0 {
                break; // 0 == WM_QUIT, -1 == error
            }
            unsafe {
                TranslateMessage(&msg);
                DispatchMessageW(&msg);
            }
        }
    }
}

impl Drop for Window {
    fn drop(&mut self) {
        unsafe {
            if self.timer_id != 0 {
                KillTimer(self.hwnd, self.timer_id);
            }
            DestroyWindow(self.hwnd);
        }
    }
}
