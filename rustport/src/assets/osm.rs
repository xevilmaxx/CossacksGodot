//! Reader for the donor static-mesh `.osm` format (first vertex frame only).
//!
//! This is a std-only, byte-driven port of the proven Python reader
//! `app/tools/bake_sprites.py::read_osm_first`. Donor files are read at runtime;
//! no donor bytes are embedded in this crate.
//!
//! Layout (all little-endian, from `docs/decomp/DC_FORMATS.md` §2.2):
//!
//! * 68-byte header = 17 i32. Long indices:
//!   0 magic `0x32504449` ("IDP2"), 1 version, 2-3 sw/sh, 4 fs, 5 ns,
//!   6-8 nv/nu/nt, 9-10 ng/nf, 11 os, 12 ou (UV offset),
//!   13 ot (triangle offset), 14 of (vertex-frame offset), 15-16 og/oe
//!   (end == file size).
//! * UVs at `ou`: `nu` x `[2f32]`.
//! * Triangles at `ot`: `nt` x `[6i32]` = three vertex indices + three UV
//!   indices. Both triples are consumed with the winding swap `(0,2,1)`.
//! * Vertices at `of + 16`: a 16-byte frame/name header is read and discarded,
//!   then `nv` x `[3f32 + u32 normal/attribute]`.
//!
//! The alleged "longs 10/11/12 offset bug" is REFUTED: the shared reader
//! already uses longs 12/13/14, exactly as this reader does. See
//! `docs/decomp/DC_FORMATS.md` §3.

use std::fmt;
use std::path::Path;

/// Number of i32 words in the `.osm` header.
pub const HEADER_I32_COUNT: usize = 17;
/// Header size in bytes (`HEADER_I32_COUNT * 4`).
pub const HEADER_LEN: usize = 68;
/// `IDP2` magic, stored as a little-endian i32.
pub const MAGIC: i32 = 0x3250_4449;

/// Errors produced while parsing a `.osm` byte buffer or file.
#[derive(Debug)]
pub enum OsmError {
    /// The input is shorter than the 68-byte header.
    TooShort { needed: usize, got: usize },
    /// The magic word is not `IDP2`.
    BadMagic { got: i32 },
    /// A count or offset field is negative.
    NegativeField { field: &'static str, value: i32 },
    /// A section's computed byte range falls outside the input.
    OutOfBounds {
        field: &'static str,
        start: usize,
        end: usize,
        len: usize,
    },
    /// Integer arithmetic overflowed while computing a section range.
    Overflow { field: &'static str },
    /// The file could not be read from disk.
    Io(std::io::Error),
}

impl fmt::Display for OsmError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            OsmError::TooShort { needed, got } => {
                write!(f, ".osm too short: need {needed} bytes, got {got}")
            }
            OsmError::BadMagic { got } => {
                write!(f, "bad .osm magic: expected {MAGIC:#x}, got {got:#x}")
            }
            OsmError::NegativeField { field, value } => {
                write!(f, "negative .osm field {field}: {value}")
            }
            OsmError::OutOfBounds {
                field,
                start,
                end,
                len,
            } => write!(
                f,
                ".osm {field} range {start}..{end} exceeds input length {len}"
            ),
            OsmError::Overflow { field } => write!(f, "overflow computing .osm {field} range"),
            OsmError::Io(e) => write!(f, ".osm file I/O error: {e}"),
        }
    }
}

impl std::error::Error for OsmError {
    fn source(&self) -> Option<&(dyn std::error::Error + 'static)> {
        match self {
            OsmError::Io(e) => Some(e),
            _ => None,
        }
    }
}

impl From<std::io::Error> for OsmError {
    fn from(e: std::io::Error) -> Self {
        OsmError::Io(e)
    }
}

/// A decoded static mesh: first vertex frame, faces, UVs and an AABB.
#[derive(Debug, Clone)]
pub struct Osm {
    pub nv: i32,
    pub nu: i32,
    pub nt: i32,
    pub vertices: Vec<[f32; 3]>,
    pub faces: Vec<[i32; 3]>,
    pub uvs: Vec<[f32; 2]>,
    pub face_uvs: Vec<[i32; 3]>,
    /// `(min_x, min_y, min_z), (max_x, max_y, max_z)` over `vertices`.
    pub bbox: ([f32; 3], [f32; 3]),
}

/// Read the 17 header words, with a bounds check.
pub fn parse_header(bytes: &[u8]) -> Result<[i32; HEADER_I32_COUNT], OsmError> {
    if bytes.len() < HEADER_LEN {
        return Err(OsmError::TooShort {
            needed: HEADER_LEN,
            got: bytes.len(),
        });
    }
    let mut h = [0i32; HEADER_I32_COUNT];
    for (i, word) in h.iter_mut().enumerate() {
        let p = i * 4;
        *word = i32::from_le_bytes([bytes[p], bytes[p + 1], bytes[p + 2], bytes[p + 3]]);
    }
    Ok(h)
}

fn i32_at(bytes: &[u8], p: usize, field: &'static str) -> Result<i32, OsmError> {
    let end = p.checked_add(4).ok_or(OsmError::Overflow { field })?;
    let b = bytes.get(p..end).ok_or(OsmError::OutOfBounds {
        field,
        start: p,
        end,
        len: bytes.len(),
    })?;
    Ok(i32::from_le_bytes([b[0], b[1], b[2], b[3]]))
}

fn f32_at(bytes: &[u8], p: usize, field: &'static str) -> Result<f32, OsmError> {
    let end = p.checked_add(4).ok_or(OsmError::Overflow { field })?;
    let b = bytes.get(p..end).ok_or(OsmError::OutOfBounds {
        field,
        start: p,
        end,
        len: bytes.len(),
    })?;
    Ok(f32::from_le_bytes([b[0], b[1], b[2], b[3]]))
}

/// Validate a `[start, start + count*stride)` byte range, returning `(start, end)`.
fn checked_span(
    start: usize,
    count: i32,
    stride: usize,
    len: usize,
    field: &'static str,
) -> Result<(usize, usize), OsmError> {
    let count = if count < 0 {
        return Err(OsmError::NegativeField { field, value: count });
    } else {
        count as usize
    };
    let size = count
        .checked_mul(stride)
        .ok_or(OsmError::Overflow { field })?;
    let end = start.checked_add(size).ok_or(OsmError::Overflow { field })?;
    if end > len {
        return Err(OsmError::OutOfBounds {
            field,
            start,
            end,
            len,
        });
    }
    Ok((start, end))
}

/// Parse a `.osm` byte slice. Offsets are taken from header longs 12/13/14;
/// no contiguity assumption is made (the Python reader does not make one either).
pub fn parse(bytes: &[u8]) -> Result<Osm, OsmError> {
    let h = parse_header(bytes)?;
    if h[0] != MAGIC {
        return Err(OsmError::BadMagic { got: h[0] });
    }

    let nv = h[6];
    let nu = h[7];
    let nt = h[8];
    let ou = h[12]; // UVs
    let ot = h[13]; // triangles
    let of = h[14]; // vertex frame
    let oe = h[16]; // declared end

    for &(name, value) in &[("nv", nv), ("nu", nu), ("nt", nt), ("ou", ou), ("ot", ot), ("of", of), ("oe", oe)] {
        if value < 0 {
            return Err(OsmError::NegativeField { field: name, value });
        }
    }
    let frame_skip = (of as usize)
        .checked_add(16)
        .ok_or(OsmError::Overflow { field: "of+16" })?;

    // Validate each section before reading it, so every element read below
    // is provably in bounds.
    checked_span(ou as usize, nu, 8, bytes.len(), "uvs")?;
    checked_span(ot as usize, nt, 24, bytes.len(), "triangles")?;
    checked_span(frame_skip, nv, 16, bytes.len(), "vertices")?;
    if (oe as usize) > bytes.len() {
        return Err(OsmError::OutOfBounds {
            field: "oe",
            start: 0,
            end: oe as usize,
            len: bytes.len(),
        });
    }

    let mut uvs = Vec::with_capacity(nu as usize);
    let ou = ou as usize;
    for i in 0..nu as usize {
        let p = ou + i * 8;
        uvs.push([f32_at(bytes, p, "uv.u")?, f32_at(bytes, p + 4, "uv.v")?]);
    }

    let mut faces = Vec::with_capacity(nt as usize);
    let mut face_uvs = Vec::with_capacity(nt as usize);
    let ot = ot as usize;
    for i in 0..nt as usize {
        let p = ot + i * 24;
        let v0 = i32_at(bytes, p, "tri.v0")?;
        let v1 = i32_at(bytes, p + 4, "tri.v1")?;
        let v2 = i32_at(bytes, p + 8, "tri.v2")?;
        let u0 = i32_at(bytes, p + 12, "tri.uv0")?;
        let u1 = i32_at(bytes, p + 16, "tri.uv1")?;
        let u2 = i32_at(bytes, p + 20, "tri.uv2")?;
        // Winding swap (0,2,1) for BOTH triples, matching read_osm_first.
        faces.push([v0, v2, v1]);
        face_uvs.push([u0, u2, u1]);
    }

    let mut vertices = Vec::with_capacity(nv as usize);
    for i in 0..nv as usize {
        let p = frame_skip + i * 16;
        let x = f32_at(bytes, p, "vert.x")?;
        let y = f32_at(bytes, p + 4, "vert.y")?;
        let z = f32_at(bytes, p + 8, "vert.z")?;
        // u32 normal/attribute word at p+12 is read-and-discarded.
        let _normal_bits = i32_at(bytes, p + 12, "vert.normal")? as u32;
        vertices.push([x, y, z]);
    }

    let mut lo = [f32::INFINITY; 3];
    let mut hi = [f32::NEG_INFINITY; 3];
    for v in &vertices {
        for k in 0..3 {
            if v[k] < lo[k] {
                lo[k] = v[k];
            }
            if v[k] > hi[k] {
                hi[k] = v[k];
            }
        }
    }
    if vertices.is_empty() {
        lo = [0.0; 3];
        hi = [0.0; 3];
    }

    Ok(Osm {
        nv,
        nu,
        nt,
        vertices,
        faces,
        uvs,
        face_uvs,
        bbox: (lo, hi),
    })
}

/// Read a `.osm` file from disk and parse it.
pub fn parse_file(path: &Path) -> Result<Osm, OsmError> {
    let bytes = std::fs::read(path)?;
    parse(&bytes)
}
