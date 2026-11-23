//! T6-R05-OSS acceptance tests for the `.oss` reader.
//!
//! The two donor tests read real files at runtime from the donor install; no
//! donor bytes are embedded here. The synthetic test exercises the parser with
//! entirely invented data so it also passes without a donor install.

#[path = "../src/assets/oss.rs"]
mod oss_reader;

use oss_reader::{parse, parse_file, OssError};
use std::fs;
use std::path::PathBuf;

const DONOR_UNITS: &str = r"C:\Games\Cossacks 3\data\actors\units";

fn donor_path(name: &str) -> PathBuf {
    PathBuf::from(DONOR_UNITS).join(name)
}

fn push_i32(buf: &mut Vec<u8>, x: i32) {
    buf.extend_from_slice(&x.to_le_bytes());
}

fn push_f32(buf: &mut Vec<u8>, x: f32) {
    buf.extend_from_slice(&x.to_le_bytes());
}

/// Shared checks: counts, exact size closure, finiteness and plausible ranges.
fn check_donor(
    name: &str,
    (ek, efps, eb, ev, efc, et): (i32, i32, i32, i32, i32, i32),
    expected_size: usize,
) -> oss_reader::Oss {
    let path = donor_path(name);
    let data = fs::read(&path).unwrap_or_else(|e| panic!("cannot read donor file {path:?}: {e}"));
    assert_eq!(
        data.len(), expected_size,
        "{name}: on-disk size differs from documented closure"
    );

    let oss = parse(&data).unwrap_or_else(|e| panic!("{name}: parse failed: {e}"));

    assert_eq!(oss.k, ek, "{name}: k (frames per bone)");
    assert_eq!(oss.fps, efps, "{name}: fps");
    assert_eq!(oss.bones, eb, "{name}: b (bones)");
    assert_eq!(oss.vertices.len(), ev as usize, "{name}: v (vertices)");
    assert_eq!(oss.faces.len(), efc as usize, "{name}: fc (faces)");
    assert_eq!(oss.uvs.len(), et as usize, "{name}: t (UVs)");
    assert_eq!(oss.uv_indices.len(), efc as usize, "{name}: UV index triples");
    assert_eq!(oss.weights.len(), ev as usize, "{name}: weight lists");

    // Size closure: every byte consumed, zero left over.
    assert_eq!(
        oss.consumed_bytes(),
        data.len(),
        "{name}: parser did not consume the whole file"
    );

    // Track shape: one track per bone, `k` frames each.
    assert_eq!(oss.tracks.len(), eb as usize, "{name}: bone track count");
    for (bi, bone) in oss.tracks.iter().enumerate() {
        assert_eq!(bone.len(), ek as usize, "{name}: bone {bi} frame count");
    }

    // Vertices / UVs: finite and inside a plausible model-space band.
    for (i, v) in oss.vertices.iter().enumerate() {
        assert!(v.iter().all(|x| x.is_finite()), "{name}: vertex {i} non-finite");
        assert!(v[0].abs() < 100.0 && v[1].abs() < 100.0 && v[2].abs() < 100.0,
            "{name}: vertex {i} out of plausible range {v:?}");
    }
    for (i, uv) in oss.uvs.iter().enumerate() {
        assert!(uv.iter().all(|x| x.is_finite()), "{name}: UV {i} non-finite");
    }

    // Indices: in range for the corresponding vertex / UV table.
    for (i, f) in oss.faces.iter().enumerate() {
        for &idx in f.iter() {
            assert!(idx >= 0 && (idx as usize) < ev as usize,
                "{name}: face {i} vertex index {idx} out of range");
        }
    }
    for (i, f) in oss.uv_indices.iter().enumerate() {
        for &idx in f.iter() {
            assert!(idx >= 0 && (idx as usize) < et as usize,
                "{name}: face {i} UV index {idx} out of range");
        }
    }

    // Quaternion sample: unit norm (the donor stores near-unit quaternions).
    let mut sampled = 0usize;
    for bone in &oss.tracks {
        for frame in bone.iter().step_by(7) {
            let q = &frame[3..7];
            let norm = (q[0] * q[0] + q[1] * q[1] + q[2] * q[2] + q[3] * q[3]).sqrt();
            assert!((norm - 1.0).abs() < 0.05,
                "{name}: quaternion norm {norm} outside 1.0 +/- 0.05");
            sampled += 1;
        }
    }
    assert!(sampled > 0, "{name}: no quaternion samples checked");

    oss
}

#[test]
fn donor_yacht_oss() {
    // DC_FORMATS.md 2.1: k=311, fps=30, b=20, v=584, fc=947, t=793,
    // exact closure 217344 bytes.
    let oss = check_donor("yacht.oss", (311, 30, 20, 584, 947, 793), 217_344);

    // Spot checks against the decoded donor sample (scalar values only).
    assert_eq!(oss.faces[0], [1, 2, 8]);
    assert_eq!(oss.uv_indices[0], [0, 1, 2]);
    assert!((oss.vertices[0][2] - 1.8613).abs() < 0.01);
    assert!((oss.tracks[0][0][6] - 1.0).abs() < 1e-6);
}

#[test]
fn donor_peaukr_oss() {
    // DC_FORMATS.md 2.1: k=483, fps=30, b=20, v=577, fc=921, t=733,
    // exact closure 312376 bytes.
    let _ = check_donor("peaukr.oss", (483, 30, 20, 577, 921, 733), 312_376);
}

#[test]
fn parse_file_api_reads_donor_yacht() {
    let oss = parse_file(&donor_path("yacht.oss"))
        .unwrap_or_else(|e| panic!("parse_file(yacht.oss) failed: {e}"));
    assert_eq!(oss.k, 311);
    assert_eq!(oss.vertices.len(), 584);
    assert_eq!(oss.consumed_bytes(), 217_344);
}

#[test]
fn synthetic_header_and_payload_without_donor() {
    // Fully invented data: k=2, fps=30, b=2, v=3, fc=1, t=3.
    let mut buf = Vec::new();

    for x in [2, 30, 2, 3, 1, 3] {
        push_i32(&mut buf, x);
    }
    // 3 vertices.
    for x in [0.0f32, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0] {
        push_f32(&mut buf, x);
    }
    // 1 face.
    for x in [0, 2, 1] {
        push_i32(&mut buf, x);
    }
    // 3 UVs.
    for x in [0.0f32, 0.0, 0.5, 1.0, 1.0, 0.25] {
        push_f32(&mut buf, x);
    }
    // 1 UV-index triple.
    for x in [0, 2, 1] {
        push_i32(&mut buf, x);
    }
    // 3 weight lists: 1 pair, 2 pairs, 0 pairs.
    push_i32(&mut buf, 1); push_i32(&mut buf, 0); push_f32(&mut buf, 1.0);
    push_i32(&mut buf, 2); push_i32(&mut buf, 0); push_f32(&mut buf, 0.25);
    push_i32(&mut buf, 1); push_f32(&mut buf, 0.75);
    push_i32(&mut buf, 0);
    // 2 bones x 2 frames x 7 floats.
    for x in [
        0.0f32, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0,
        1.0, 2.0, 3.0, 0.0, 0.0, 0.0, 1.0,
        4.0, 5.0, 6.0, 0.0, 0.0, 0.0, 1.0,
        7.0, 8.0, 9.0, 0.0, 0.0, 0.0, 1.0,
    ] {
        push_f32(&mut buf, x);
    }

    let oss = parse(&buf).expect("synthetic .oss must parse");
    assert_eq!(oss.k, 2);
    assert_eq!(oss.fps, 30);
    assert_eq!(oss.bones, 2);
    assert_eq!(oss.vertices, vec![[0.0f32, 1.0, 2.0], [3.0, 4.0, 5.0], [6.0, 7.0, 8.0]]);
    assert_eq!(oss.faces, vec![[0, 2, 1]]);
    assert_eq!(oss.uvs, vec![[0.0f32, 0.0], [0.5, 1.0], [1.0, 0.25]]);
    assert_eq!(oss.uv_indices, vec![[0, 2, 1]]);
    assert_eq!(oss.weights[0], vec![(0, 1.0f32)]);
    assert_eq!(oss.weights[1], vec![(0, 0.25f32), (1, 0.75f32)]);
    assert!(oss.weights[2].is_empty());
    assert_eq!(oss.tracks.len(), 2);
    assert_eq!(oss.tracks[0].len(), 2);
    assert_eq!(oss.tracks[0][1], [1.0f32, 2.0, 3.0, 0.0, 0.0, 0.0, 1.0]);
    assert_eq!(oss.consumed_bytes(), buf.len());
}

#[test]
fn rejects_truncated_and_trailing_input() {
    let path = donor_path("yacht.oss");
    if let Ok(data) = fs::read(&path) {
        match parse(&data[..20]) {
            Err(OssError::TooShort { field, .. }) => assert_eq!(field, "header.t"),
            other => panic!("truncated header should be TooShort, got {other:?}"),
        }
    }

    let mut buf = vec![0u8; 24]; // k=0, fps=0, b=0, v=0, fc=0, t=0: valid empty file
    assert!(parse(&buf).is_ok(), "empty-but-complete .oss should parse");
    buf.push(0);
    match parse(&buf) {
        Err(OssError::TrailingBytes { extra }) => assert_eq!(extra, 1),
        other => panic!("extra byte should be TrailingBytes, got {other:?}"),
    }
}
