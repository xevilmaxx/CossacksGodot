//! Integration test for the `.osm` reader.
//!
//! The reader is included directly so this test does not depend on the
//! `assets.rs` scaffold stub (owned by integration):
//!     #[path = "../src/assets/osm.rs"] mod osm_reader;
//!
//! Real donor files are read at RUNTIME from `C:\Games\Cossacks 3`
//! (overridable with the `COSSACKS3_DIR` env var). No donor bytes are stored
//! in the repo; this test would fail cleanly if the donor were absent.

#[path = "../src/assets/osm.rs"]
mod osm_reader;

use osm_reader::{parse, parse_file, parse_header, Osm, OsmError, HEADER_LEN, MAGIC};
use std::path::{Path, PathBuf};

fn donor_root() -> PathBuf {
    match std::env::var("COSSACKS3_DIR") {
        Ok(p) if !p.trim().is_empty() => PathBuf::from(p),
        _ => PathBuf::from(r"C:\Games\Cossacks 3"),
    }
}

fn close(got: f32, want: f32, tol: f32, label: &str) {
    assert!(
        (got - want).abs() <= tol,
        "{label}: expected {want} +/- {tol}, got {got}"
    );
}

fn check_indices(osm: &Osm) {
    for (fi, f) in osm.faces.iter().enumerate() {
        for (k, &idx) in f.iter().enumerate() {
            assert!(
                idx >= 0 && (idx as usize) < osm.vertices.len(),
                "face[{fi}][{k}] vertex index {idx} out of range (nv={})",
                osm.vertices.len()
            );
        }
    }
    for (fi, f) in osm.face_uvs.iter().enumerate() {
        for (k, &idx) in f.iter().enumerate() {
            assert!(
                idx >= 0 && (idx as usize) < osm.uvs.len(),
                "face_uvs[{fi}][{k}] UV index {idx} out of range (nu={})",
                osm.uvs.len()
            );
        }
    }
}

fn check_header_and_closure(
    bytes: &[u8],
    osm: &Osm,
    expected: &[i32; 17],
    want_size: usize,
) {
    let h = parse_header(bytes).expect("header must be readable");
    assert_eq!(h, *expected, "17-word header mismatch");
    assert_eq!(bytes.len(), want_size, "on-disk file size mismatch");
    assert_eq!(h[0], MAGIC, "magic must be IDP2 as i32");
    assert_eq!(h[1], 8, "version must be 8");

    // Exact arithmetic closure documented in DC_FORMATS.md §2.2.
    assert_eq!(h[12] + h[7] * 8, h[13], "ou + nu*8 must equal ot");
    assert_eq!(h[13] + h[8] * 24, h[14], "ot + nt*24 must equal of");
    assert_eq!(
        h[14] + 16 + h[6] * 16,
        h[16],
        "of + 16 + nv*16 must equal oe"
    );
    assert_eq!(h[16] as usize, bytes.len(), "oe must equal file size");
    assert_eq!(h[15], h[16], "og must equal oe (single frame)");

    assert_eq!(osm.nv, h[6]);
    assert_eq!(osm.nu, h[7]);
    assert_eq!(osm.nt, h[8]);
    assert_eq!(osm.vertices.len(), h[6] as usize, "vertex count");
    assert_eq!(osm.uvs.len(), h[7] as usize, "UV count");
    assert_eq!(osm.faces.len(), h[8] as usize, "face count");
    assert_eq!(osm.face_uvs.len(), h[8] as usize, "face-UV count");
    check_indices(osm);

    // Winding swap (0,2,1) on BOTH triples: verify the very first triangle
    // against its raw six-i32 record at ot.
    let p = h[13] as usize;
    let raw: Vec<i32> = (0..6)
        .map(|i| {
            let q = p + i * 4;
            i32::from_le_bytes([bytes[q], bytes[q + 1], bytes[q + 2], bytes[q + 3]])
        })
        .collect();
    assert_eq!(osm.faces[0], [raw[0], raw[2], raw[1]], "vertex winding swap");
    assert_eq!(
        osm.face_uvs[0],
        [raw[3], raw[5], raw[4]],
        "UV winding swap"
    );
}

#[test]
fn yacht_osm_real_donor() {
    let path = donor_root().join(r"data\actors\units\yacht.osm");
    let bytes = std::fs::read(&path)
        .unwrap_or_else(|e| panic!("donor file missing at {}: {e}", path.display()));
    let osm = parse(&bytes).expect("yacht.osm must parse");

    check_header_and_closure(
        &bytes,
        &osm,
        &[
            MAGIC, 8, 256, 256, 149_840, 1, 9364, 11_490, 7731, 0, 1, 68, 132, 92_052,
            277_596, 427_436, 427_436,
        ],
        427_436,
    );

    // Also exercise parse_file on the same real file.
    let via_file = parse_file(&path).expect("parse_file(yacht.osm)");
    assert_eq!(via_file.vertices.len(), osm.vertices.len());
    assert_eq!(via_file.bbox, osm.bbox);

    let (lo, hi) = osm.bbox;
    for (k, axis) in ["x", "y", "z"].iter().enumerate() {
        close(lo[k], [-1.752, -4.819, -0.376][k], 0.01, &format!("{axis} min"));
        close(hi[k], [1.752, 3.208, 6.803][k], 0.01, &format!("{axis} max"));
    }
}

#[test]
fn algcen_osm_real_donor() {
    let path = donor_root().join(r"data\actors\buildings\alg\algcen.osm");
    let bytes = std::fs::read(&path)
        .unwrap_or_else(|e| panic!("donor file missing at {}: {e}", path.display()));
    let osm = parse(&bytes).expect("algcen.osm must parse");

    check_header_and_closure(
        &bytes,
        &osm,
        &[
            MAGIC, 8, 256, 256, 78_432, 1, 4901, 5256, 4325, 0, 1, 68, 132, 42_180,
            145_980, 224_412, 224_412,
        ],
        224_412,
    );
}

#[test]
fn synthetic_header_and_payload() {
    // Minimal mesh: 3 vertices, 3 UVs, 1 triangle.
    let nv: i32 = 3;
    let nu: i32 = 3;
    let nt: i32 = 1;
    let ou: i32 = HEADER_LEN as i32; // 68
    let ot: i32 = ou + nu * 8; // 92
    let of: i32 = ot + nt * 24; // 116
    let oe: i32 = of + 16 + nv * 16; // 180
    let h = [
        MAGIC, 8, 256, 256, 0, 1, nv, nu, nt, 0, 1, 68, ou, ot, of, oe, oe,
    ];
    let mut bytes = Vec::new();
    for w in h {
        bytes.extend_from_slice(&w.to_le_bytes());
    }
    // UVs: (0,0), (1,0), (0,1).
    for uv in [(0.0f32, 0.0f32), (1.0, 0.0), (0.0, 1.0)] {
        bytes.extend_from_slice(&uv.0.to_le_bytes());
        bytes.extend_from_slice(&uv.1.to_le_bytes());
    }
    // One raw triangle [v0,v1,v2, uv0,uv1,uv2] = [0,1,2, 0,1,2].
    for i in [0i32, 1, 2, 0, 1, 2] {
        bytes.extend_from_slice(&i.to_le_bytes());
    }
    // 16-byte frame/name header (discarded).
    bytes.extend_from_slice(&[0xAA; 16]);
    // 3 vertices: (0,0,0), (2,0,0), (0,0,3) + a normal word each.
    for (v, normal) in [([0.0f32, 0.0, 0.0], 1u32), ([2.0, 0.0, 0.0], 2), ([0.0, 0.0, 3.0], 3)] {
        for c in v {
            bytes.extend_from_slice(&c.to_le_bytes());
        }
        bytes.extend_from_slice(&normal.to_le_bytes());
    }
    assert_eq!(bytes.len(), oe as usize, "synthetic buffer size closure");

    let osm = parse(&bytes).expect("synthetic mesh must parse");
    assert_eq!((osm.nv, osm.nu, osm.nt), (3, 3, 1));
    assert_eq!(osm.vertices, vec![[0.0, 0.0, 0.0], [2.0, 0.0, 0.0], [0.0, 0.0, 3.0]]);
    assert_eq!(osm.uvs, vec![[0.0, 0.0], [1.0, 0.0], [0.0, 1.0]]);
    assert_eq!(osm.faces, vec![[0, 2, 1]]);
    assert_eq!(osm.face_uvs, vec![[0, 2, 1]]);
    assert_eq!(osm.bbox, ([0.0, 0.0, 0.0], [2.0, 0.0, 3.0]));
    check_indices(&osm);
}

#[test]
fn malformed_inputs_are_rejected() {
    // Too short for a header.
    assert!(matches!(
        parse(&[0u8; 4]),
        Err(OsmError::TooShort { needed: HEADER_LEN, got: 4 })
    ));

    // Right size but wrong magic.
    let mut bad = vec![0u8; HEADER_LEN];
    bad[..4].copy_from_slice(&0xDEAD_BEEFu32.to_le_bytes());
    assert!(matches!(parse(&bad), Err(OsmError::BadMagic { .. })));

    // Valid header, but the UV section claims to run past the buffer.
    let mut short = vec![0u8; HEADER_LEN + 8];
    let h = [MAGIC, 8, 256, 256, 0, 1, 0, 3, 0, 0, 1, 68, 68, 92, 92, 100, 100];
    for (i, w) in h.iter().enumerate() {
        short[i * 4..i * 4 + 4].copy_from_slice(&w.to_le_bytes());
    }
    assert!(matches!(
        parse(&short),
        Err(OsmError::OutOfBounds { .. })
    ));
    // parse_file on a non-existent path must surface an I/O error, not panic.
    assert!(matches!(
        parse_file(Path::new("C:/does/not/exist/missing.osm")),
        Err(OsmError::Io(_))
    ));
}
