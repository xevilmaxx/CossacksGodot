//! Reader for the donor `.oss` skinned-animated-mesh format.
//!
//! PRIVATE USE ONLY: donor files live under `C:\Games\Cossacks 3` and are read
//! at runtime. No donor bytes are embedded in this crate.
//!
//! # Layout (24-byte header + sequential payload, all little-endian)
//!
//! Header: six `i32` — `k, fps, b, v, fc, t`
//! (`k` frames per bone, `fps` playback rate, `b` bones, `v` vertices,
//! `fc` triangles, `t` UVs). Then, in order:
//!
//! 1. `v × [3f32]` vertices,
//! 2. `fc × [3i32]` face vertex indices,
//! 3. `t × [2f32]` UV pairs,
//! 4. `fc × [3i32]` per-face UV index triples,
//! 5. `v` weight lists — `i32` count, then `count × (i32 bone_index, f32 weight)`,
//! 6. `b × k × [7f32]` bone tracks — position `xyz` + quaternion `xyzw`.
//!
//! # Rotation convention
//!
//! The donor applies bone rotations **transposed** (row-vector convention)
//! when skinning (`bake_sprites.qmat`). This reader returns the raw track
//! floats unchanged; any later consumer must apply that convention itself.
//!
//! Source of the layout: `docs/decomp/DC_FORMATS.md` §2.1 and
//! `app/tools/bake_sprites.py::read_oss` (both read-only references).

use std::error::Error;
use std::fmt;
use std::fs;
use std::path::Path;

/// Parsed contents of one `.oss` file.
#[derive(Debug, Clone)]
pub struct Oss {
    /// Frames per bone (`k`).
    pub k: i32,
    /// Playback frames per second (`fps`).
    pub fps: i32,
    /// Number of bones (`b`).
    pub bones: i32,
    /// Rest-pose vertices `(x, y, z)`, length `v`.
    pub vertices: Vec<[f32; 3]>,
    /// Triangle vertex-index triples, length `fc`.
    pub faces: Vec<[i32; 3]>,
    /// UV pairs `(u, v)`, length `t`.
    pub uvs: Vec<[f32; 2]>,
    /// Per-triangle UV-index triples, length `fc`. Stored so that no payload
    /// block is silently dropped; required for exact size closure.
    pub uv_indices: Vec<[i32; 3]>,
    /// Per-vertex skin weights `(bone_index, weight)`, length `v`.
    pub weights: Vec<Vec<(i32, f32)>>,
    /// Raw bone tracks `tracks[bone][frame] = [px, py, pz, qx, qy, qz, qw]`,
    /// with `bones` bones and `k` frames each. **Not** de-transposed; see the
    /// module-level rotation-convention note.
    pub tracks: Vec<Vec<[f32; 7]>>,
    consumed_bytes: usize,
}

impl Oss {
    /// Number of input bytes consumed by `parse`. On success this always
    /// equals the input length (exact size closure).
    pub fn consumed_bytes(&self) -> usize {
        self.consumed_bytes
    }
}

/// Errors returned by [`parse`] / [`parse_file`].
#[derive(Debug)]
pub enum OssError {
    /// A payload block needed more bytes than the input contains.
    TooShort {
        need: usize,
        have: usize,
        field: &'static str,
    },
    /// A header/count field was negative.
    NegativeCount { field: &'static str, value: i32 },
    /// A computed byte length overflowed `usize`.
    Overflow(&'static str),
    /// The input has bytes left after the last bone track (no exact closure).
    TrailingBytes { extra: usize },
    /// File I/O failed in [`parse_file`].
    Io(std::io::Error),
}

impl fmt::Display for OssError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            OssError::TooShort { need, have, field } => {
                write!(f, ".oss {field}: need {need} bytes, have {have}")
            }
            OssError::NegativeCount { field, value } => {
                write!(f, ".oss {field}: negative count {value}")
            }
            OssError::Overflow(field) => write!(f, ".oss {field}: byte length overflow"),
            OssError::TrailingBytes { extra } => {
                write!(f, ".oss: {extra} trailing bytes after last bone track")
            }
            OssError::Io(e) => write!(f, ".oss I/O error: {e}"),
        }
    }
}

impl Error for OssError {}

impl From<std::io::Error> for OssError {
    fn from(e: std::io::Error) -> Self {
        OssError::Io(e)
    }
}

/// Bounds-checked little-endian cursor over the input slice.
struct Cursor<'a> {
    bytes: &'a [u8],
    pos: usize,
}

impl<'a> Cursor<'a> {
    fn new(bytes: &'a [u8]) -> Self {
        Self { bytes, pos: 0 }
    }

    fn take(&mut self, n: usize, field: &'static str) -> Result<&'a [u8], OssError> {
        let end = self.pos.checked_add(n).ok_or(OssError::Overflow(field))?;
        if end > self.bytes.len() {
            return Err(OssError::TooShort {
                need: end,
                have: self.bytes.len(),
                field,
            });
        }
        let out = &self.bytes[self.pos..end];
        self.pos = end;
        Ok(out)
    }

    fn i32(&mut self, field: &'static str) -> Result<i32, OssError> {
        let b = self.take(4, field)?;
        Ok(i32::from_le_bytes([b[0], b[1], b[2], b[3]]))
    }

    /// Reads a non-negative count field and converts it to `usize`.
    fn count(&mut self, field: &'static str) -> Result<usize, OssError> {
        let n = self.i32(field)?;
        usize::try_from(n).map_err(|_| OssError::NegativeCount { field, value: n })
    }

    fn remaining(&self) -> usize {
        self.bytes.len() - self.pos
    }
}

/// Checked multiplication used for both byte lengths and element counts.
fn mul(a: usize, b: usize, field: &'static str) -> Result<usize, OssError> {
    a.checked_mul(b).ok_or(OssError::Overflow(field))
}

fn vec3s(c: &mut Cursor<'_>, n: usize, field: &'static str) -> Result<Vec<[f32; 3]>, OssError> {
    let raw = c.take(mul(n, 12, field)?, field)?;
    Ok(raw
        .chunks_exact(12)
        .map(|s| {
            [
                f32::from_le_bytes([s[0], s[1], s[2], s[3]]),
                f32::from_le_bytes([s[4], s[5], s[6], s[7]]),
                f32::from_le_bytes([s[8], s[9], s[10], s[11]]),
            ]
        })
        .collect())
}

fn vec2s(c: &mut Cursor<'_>, n: usize, field: &'static str) -> Result<Vec<[f32; 2]>, OssError> {
    let raw = c.take(mul(n, 8, field)?, field)?;
    Ok(raw
        .chunks_exact(8)
        .map(|s| {
            [
                f32::from_le_bytes([s[0], s[1], s[2], s[3]]),
                f32::from_le_bytes([s[4], s[5], s[6], s[7]]),
            ]
        })
        .collect())
}

fn triples(c: &mut Cursor<'_>, n: usize, field: &'static str) -> Result<Vec<[i32; 3]>, OssError> {
    let raw = c.take(mul(n, 12, field)?, field)?;
    Ok(raw
        .chunks_exact(12)
        .map(|s| {
            [
                i32::from_le_bytes([s[0], s[1], s[2], s[3]]),
                i32::from_le_bytes([s[4], s[5], s[6], s[7]]),
                i32::from_le_bytes([s[8], s[9], s[10], s[11]]),
            ]
        })
        .collect())
}

fn tracks7(c: &mut Cursor<'_>, n: usize, field: &'static str) -> Result<Vec<[f32; 7]>, OssError> {
    let raw = c.take(mul(n, 28, field)?, field)?;
    Ok(raw
        .chunks_exact(28)
        .map(|s| {
            [
                f32::from_le_bytes([s[0], s[1], s[2], s[3]]),
                f32::from_le_bytes([s[4], s[5], s[6], s[7]]),
                f32::from_le_bytes([s[8], s[9], s[10], s[11]]),
                f32::from_le_bytes([s[12], s[13], s[14], s[15]]),
                f32::from_le_bytes([s[16], s[17], s[18], s[19]]),
                f32::from_le_bytes([s[20], s[21], s[22], s[23]]),
                f32::from_le_bytes([s[24], s[25], s[26], s[27]]),
            ]
        })
        .collect())
}

/// Parse one `.oss` byte buffer.
///
/// All counts are validated and every block is bounds-checked. On success the
/// cursor consumed the whole input: trailing bytes are rejected with
/// [`OssError::TrailingBytes`] (all 335 donor `.oss` files close exactly).
pub fn parse(bytes: &[u8]) -> Result<Oss, OssError> {
    let mut c = Cursor::new(bytes);

    // 24-byte header: six little-endian i32.
    let k = c.count("header.k")?;
    let fps = c.i32("header.fps")?;
    let bones = c.count("header.b")?;
    let vertices_n = c.count("header.v")?;
    let faces_n = c.count("header.fc")?;
    let uvs_n = c.count("header.t")?;

    // Payload blocks in file order.
    let vertices = vec3s(&mut c, vertices_n, "vertices")?;
    let faces = triples(&mut c, faces_n, "faces")?;
    let uvs = vec2s(&mut c, uvs_n, "uvs")?;
    let uv_indices = triples(&mut c, faces_n, "uv_indices")?;

    let mut weights = Vec::with_capacity(vertices_n);
    for _ in 0..vertices_n {
        let n = c.count("weight_count")?;
        let raw = c.take(mul(n, 8, "weight_pair")?, "weight_pair")?;
        let mut list = Vec::with_capacity(n);
        for pair in raw.chunks_exact(8) {
            list.push((
                i32::from_le_bytes([pair[0], pair[1], pair[2], pair[3]]),
                f32::from_le_bytes([pair[4], pair[5], pair[6], pair[7]]),
            ));
        }
        debug_assert_eq!(list.len(), n);
        weights.push(list);
    }

    let frame_count = mul(bones, k, "tracks")?;
    let flat = tracks7(&mut c, frame_count, "tracks")?;
    let tracks = if k == 0 {
        vec![Vec::new(); bones]
    } else {
        flat.chunks_exact(k).map(|s| s.to_vec()).collect()
    };

    let consumed = c.pos;
    let extra = c.remaining();
    if extra != 0 {
        return Err(OssError::TrailingBytes { extra });
    }

    Ok(Oss {
        k: k as i32,
        fps,
        bones: bones as i32,
        vertices,
        faces,
        uvs,
        uv_indices,
        weights,
        tracks,
        consumed_bytes: consumed,
    })
}

/// Read an `.oss` file from disk and parse it (donor path is supplied by the
/// caller; no donor bytes are stored in this crate).
pub fn parse_file(path: &Path) -> Result<Oss, OssError> {
    let bytes = fs::read(path)?;
    parse(&bytes)
}
