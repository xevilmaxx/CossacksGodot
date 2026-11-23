//! std-only DDS reader: DXT1 / DXT3 / DXT5 -> 8-bit RGBA.
//!
//! Scope: the first (top-level) image of an uncompressed-DXT DDS file. The
//! standard 128-byte `DDSURFACEDESC2` header is parsed; mip levels beyond the
//! first are ignored. Mip chains are common in the donor `.dds` files, so the
//! payload is validated as *at least* one level rather than exactly one.
//!
//! Decoding mirrors the integer arithmetic of Pillow's `BcnDecode.c` (the
//! reference used by `app/tools/bake_sprites.py::dds_to_png`) so that decoded
//! bytes can be compared byte-for-byte against a Pillow golden: 5/6-bit
//! channel expansion by bit replication, palette interpolation by truncating
//! integer division, and 4x4 blocks emitted row-major, top-down.
//!
//! Donor files are read at runtime from the donor path only. No donor bytes
//! are copied into, or committed to, this repository.

use std::error::Error;
use std::fmt;
use std::path::Path;

/// Size of the standard DDS header (`DDSURFACEDESC2`).
pub const DDS_HEADER_SIZE: usize = 128;

/// The three S3TC FourCC values this reader supports.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum FourCc {
    Dxt1,
    Dxt3,
    Dxt5,
}

impl FourCc {
    /// Canonical 4-character FourCC text.
    pub fn as_str(self) -> &'static str {
        match self {
            FourCc::Dxt1 => "DXT1",
            FourCc::Dxt3 => "DXT3",
            FourCc::Dxt5 => "DXT5",
        }
    }

    /// Bytes per 4x4 compressed block (top mip level only).
    fn block_bytes(self) -> usize {
        match self {
            FourCc::Dxt1 => 8,
            FourCc::Dxt3 | FourCc::Dxt5 => 16,
        }
    }
}

impl fmt::Display for FourCc {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self.as_str())
    }
}

/// Why a DDS file could not be decoded.
#[derive(Debug)]
pub enum DdsError {
    /// Fewer than 128 bytes were supplied.
    TooShort { need: usize, got: usize },
    /// First four bytes are not `b"DDS "`.
    BadMagic([u8; 4]),
    /// `dwSize` at offset 4 is not 124.
    BadHeaderSize(u32),
    /// FourCC is not DXT1/DXT3/DXT5 (includes the DX10 extension).
    UnsupportedFormat(String),
    /// Width or height is zero (or overflows the row-size calculation).
    BadDimensions { width: u32, height: u32 },
    /// Not enough compressed bytes for the top mip level.
    TruncatedData { expected: usize, got: usize },
    /// Filesystem error from [`decode_file`].
    Io(std::io::Error),
}

impl fmt::Display for DdsError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            DdsError::TooShort { need, got } => {
                write!(f, "DDS header needs {need} bytes, got {got}")
            }
            DdsError::BadMagic(m) => write!(f, "bad DDS magic {:?}, expected b\"DDS \"", m),
            DdsError::BadHeaderSize(v) => write!(f, "bad DDS dwSize {v}, expected 124"),
            DdsError::UnsupportedFormat(s) => write!(f, "unsupported DDS format: {s}"),
            DdsError::BadDimensions { width, height } => {
                write!(f, "invalid DDS dimensions {width}x{height}")
            }
            DdsError::TruncatedData { expected, got } => write!(
                f,
                "truncated DDS payload: top level needs {expected} bytes, got {got}"
            ),
            DdsError::Io(e) => write!(f, "DDS I/O error: {e}"),
        }
    }
}

impl Error for DdsError {
    fn source(&self) -> Option<&(dyn Error + 'static)> {
        match self {
            DdsError::Io(e) => Some(e),
            _ => None,
        }
    }
}

/// A decoded top-level DDS image, row-major RGBA8, top-down.
#[derive(Debug, Clone)]
pub struct DdsImage {
    pub width: u32,
    pub height: u32,
    pub format: FourCc,
    /// `width * height * 4` bytes, pixel (x, y) at `(y * width + x) * 4`.
    pub rgba: Vec<u8>,
}

fn u32_le(b: &[u8], off: usize) -> u32 {
    u32::from_le_bytes([b[off], b[off + 1], b[off + 2], b[off + 3]])
}

fn u16_le(b: &[u8], off: usize) -> u16 {
    u16::from_le_bytes([b[off], b[off + 1]])
}

/// Expand one RGB565 endpoint to 8-bit RGB using bit replication, exactly as
/// Pillow's `decode_565`: 5-bit `r|r>>2`, 6-bit `g|g>>4`, 5-bit `b|b>>2`.
fn expand_565(x: u16) -> [u8; 3] {
    let r5 = ((x >> 11) & 0x1f) as u32;
    let g6 = ((x >> 5) & 0x3f) as u32;
    let b5 = (x & 0x1f) as u32;
    [
        ((r5 << 3) | (r5 >> 2)) as u8,
        ((g6 << 2) | (g6 >> 4)) as u8,
        ((b5 << 3) | (b5 >> 2)) as u8,
    ]
}

/// Decode the 8-byte colour sub-block shared by DXT1/3/5.
///
/// `separate_alpha` is true for DXT3/DXT5, which behave as if `c0 > c1`
/// (always 4-colour mode) even when the raw endpoints compare the other way.
fn decode_color_block(src: &[u8], off: usize, separate_alpha: bool) -> [[u8; 4]; 16] {
    let c0 = u16_le(src, off);
    let c1 = u16_le(src, off + 2);
    let p0 = expand_565(c0);
    let p1 = expand_565(c1);

    let mut p = [[0u8; 4]; 4];
    p[0] = [p0[0], p0[1], p0[2], 255];
    p[1] = [p1[0], p1[1], p1[2], 255];

    if c0 > c1 || separate_alpha {
        // 4-colour mode: interpolants at 1/3 and 2/3 (truncating division).
        for ch in 0..3 {
            p[2][ch] = ((2 * p0[ch] as u16 + p1[ch] as u16) / 3) as u8;
            p[3][ch] = ((p0[ch] as u16 + 2 * p1[ch] as u16) / 3) as u8;
        }
        p[2][3] = 255;
        p[3][3] = 255;
    } else {
        // 3-colour mode: single midpoint plus transparent black.
        for ch in 0..3 {
            p[2][ch] = ((p0[ch] as u16 + p1[ch] as u16) / 2) as u8;
        }
        p[2][3] = 255;
        p[3] = [0, 0, 0, 0];
    }

    // Selector bytes: one per row, four 2-bit indices low-to-high (left-right).
    let mut out = [[0u8; 4]; 16];
    for n in 0..4 {
        let selector = src[off + 4 + n];
        for o in 0..4 {
            let idx = ((selector >> (2 * o)) & 3) as usize;
            out[n * 4 + o] = p[idx];
        }
    }
    out
}

/// DXT1 (BC1): 8 bytes, no alpha channel data.
fn decode_bc1_block(src: &[u8], off: usize) -> [[u8; 4]; 16] {
    decode_color_block(src, off, false)
}

/// DXT3 (BC2): 8 bytes of explicit 4-bit alpha followed by a DXT1 colour block.
fn decode_bc2_block(src: &[u8], off: usize) -> [[u8; 4]; 16] {
    let mut out = decode_color_block(src, off + 8, true);
    for n in 0..16 {
        let bit = n * 4;
        byte_alpha(&mut out[n][3], src[off + (bit >> 3)] >> (bit & 7));
    }
    out
}

fn byte_alpha(dst: &mut u8, low4: u8) {
    let av = low4 & 0x0f;
    *dst = (av << 4) | av;
}

/// DXT5 (BC3): 8 bytes of interpolated alpha followed by a DXT1 colour block.
fn decode_bc3_block(src: &[u8], off: usize) -> [[u8; 4]; 16] {
    let mut out = decode_color_block(src, off + 8, true);

    let a0 = src[off] as u32;
    let a1 = src[off + 1] as u32;
    let lut1 = src[off + 2] as u32
        | ((src[off + 3] as u32) << 8)
        | ((src[off + 4] as u32) << 16);
    let lut2 = src[off + 5] as u32
        | ((src[off + 6] as u32) << 8)
        | ((src[off + 7] as u32) << 16);

    // Pillow's bc3_alpha: 8-entry codebook, truncating integer division.
    let mut a = [0u8; 8];
    a[0] = a0 as u8;
    a[1] = a1 as u8;
    if a0 > a1 {
        a[2] = ((6 * a0 + a1) / 7) as u8;
        a[3] = ((5 * a0 + 2 * a1) / 7) as u8;
        a[4] = ((4 * a0 + 3 * a1) / 7) as u8;
        a[5] = ((3 * a0 + 4 * a1) / 7) as u8;
        a[6] = ((2 * a0 + 5 * a1) / 7) as u8;
        a[7] = ((a0 + 6 * a1) / 7) as u8;
    } else {
        a[2] = ((4 * a0 + a1) / 5) as u8;
        a[3] = ((3 * a0 + 2 * a1) / 5) as u8;
        a[4] = ((2 * a0 + 3 * a1) / 5) as u8;
        a[5] = ((a0 + 4 * a1) / 5) as u8;
        a[6] = 0;
        a[7] = 255;
    }

    for n in 0..8 {
        out[n][3] = a[((lut1 >> (3 * n)) & 7) as usize];
        out[8 + n][3] = a[((lut2 >> (3 * n)) & 7) as usize];
    }
    out
}

/// Parse a DDS byte buffer and decode its top-level image to RGBA8.
pub fn parse(bytes: &[u8]) -> Result<DdsImage, DdsError> {
    if bytes.len() < DDS_HEADER_SIZE {
        return Err(DdsError::TooShort {
            need: DDS_HEADER_SIZE,
            got: bytes.len(),
        });
    }
    if &bytes[0..4] != b"DDS " {
        let mut m = [0u8; 4];
        m.copy_from_slice(&bytes[0..4]);
        return Err(DdsError::BadMagic(m));
    }
    let dw_size = u32_le(bytes, 4);
    if dw_size != 124 {
        return Err(DdsError::BadHeaderSize(dw_size));
    }

    // Offsets from the standard DDSURFACEDESC2 / DDSPIXELFORMAT layout.
    let _flags = u32_le(bytes, 8);
    let height = u32_le(bytes, 12);
    let width = u32_le(bytes, 16);
    let _pitch_or_linear = u32_le(bytes, 20);
    let _depth = u32_le(bytes, 24);
    let _mipmap_count = u32_le(bytes, 28);
    let _pf_size = u32_le(bytes, 76);
    let _pf_flags = u32_le(bytes, 80);
    let fourcc = [bytes[84], bytes[85], bytes[86], bytes[87]];

    let format = match fourcc {
        [b'D', b'X', b'T', b'1'] => FourCc::Dxt1,
        [b'D', b'X', b'T', b'3'] => FourCc::Dxt3,
        [b'D', b'X', b'T', b'5'] => FourCc::Dxt5,
        [b'D', b'X', b'1', b'0'] => {
            return Err(DdsError::UnsupportedFormat(
                "DX10/DXGI extension (BC1..BC7 via dxgiFormat) is not supported; \
                 use a DXT1/DXT3/DXT5 FourCC file"
                    .to_string(),
            ))
        }
        _ => {
            return Err(DdsError::UnsupportedFormat(format!(
                "FourCC {:?} (0x{:08x}) is not DXT1/DXT3/DXT5",
                fourcc,
                u32_le(bytes, 84)
            )))
        }
    };

    if width == 0 || height == 0 {
        return Err(DdsError::BadDimensions { width, height });
    }
    let w = width as usize;
    let h = height as usize;
    let _ = _flags; // read for layout documentation; not required to trust flags.
    let total = w
        .checked_mul(4)
        .and_then(|n| n.checked_mul(h))
        .ok_or(DdsError::BadDimensions { width, height })?;

    let blocks_x = (w + 3) / 4;
    let blocks_y = (h + 3) / 4;
    let block_bytes = format.block_bytes();
    let data_needed = blocks_x
        .checked_mul(blocks_y)
        .and_then(|n| n.checked_mul(block_bytes))
        .ok_or(DdsError::BadDimensions { width, height })?;
    let got = bytes.len() - DDS_HEADER_SIZE;
    if got < data_needed {
        return Err(DdsError::TruncatedData {
            expected: data_needed,
            got,
        });
    }

    let mut rgba = vec![0u8; total];
    let data = &bytes[DDS_HEADER_SIZE..DDS_HEADER_SIZE + data_needed];
    let mut off = 0usize;
    for by in 0..blocks_y {
        for bx in 0..blocks_x {
            let block = match format {
                FourCc::Dxt1 => decode_bc1_block(data, off),
                FourCc::Dxt3 => decode_bc2_block(data, off),
                FourCc::Dxt5 => decode_bc3_block(data, off),
            };
            off += block_bytes;

            // Partial edge blocks: clip to the image rectangle. Pixels outside
            // it stay zero (matching Pillow's put_block bounds check).
            for j in 0..4 {
                let y = by * 4 + j;
                if y >= h {
                    continue;
                }
                for i in 0..4 {
                    let x = bx * 4 + i;
                    if x >= w {
                        continue;
                    }
                    let dst = (y * w + x) * 4;
                    rgba[dst..dst + 4].copy_from_slice(&block[j * 4 + i]);
                }
            }
        }
    }

    Ok(DdsImage {
        width,
        height,
        format,
        rgba,
    })
}

/// Read a DDS file from disk (intended for the donor install path) and decode it.
pub fn decode_file(path: &Path) -> Result<DdsImage, DdsError> {
    let bytes = std::fs::read(path).map_err(DdsError::Io)?;
    parse(&bytes)
}
