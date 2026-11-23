//! Tests for the std-only DDS (DXT1/3/5) reader.
//!
//! Synthetic 4x4 block tests are self-contained (no donor needed). The donor
//! test generates a Pillow RGBA golden at test time into rustport/target/ and
//! compares decoded bytes byte-for-byte; no donor bytes or goldens are committed.

use std::collections::BTreeMap;
use std::path::{Path, PathBuf};
use std::process::Command;

#[path = "../src/assets/dds.rs"]
mod dds_reader;

use dds_reader::{decode_file, parse, DdsError, FourCc};

const DONOR_ROOT: &str = r"C:\Games\Cossacks 3";

/// Build a minimal 128-byte DDS header with DDPF_FOURCC set.
fn make_header(width: u32, height: u32, fourcc: &[u8; 4], data_len: u32) -> Vec<u8> {
    let mut h = vec![0u8; 128];
    h[0..4].copy_from_slice(b"DDS ");
    h[4..8].copy_from_slice(&124u32.to_le_bytes()); // dwSize
    h[8..12].copy_from_slice(&0x100fu32.to_le_bytes()); // CAPS|HEIGHT|WIDTH|PIXELFORMAT
    h[12..16].copy_from_slice(&height.to_le_bytes());
    h[16..20].copy_from_slice(&width.to_le_bytes());
    h[20..24].copy_from_slice(&data_len.to_le_bytes()); // pitch/linear size
    h[76..80].copy_from_slice(&32u32.to_le_bytes()); // ddspf.dwSize
    h[80..84].copy_from_slice(&0x4u32.to_le_bytes()); // DDPF_FOURCC
    h[84..88].copy_from_slice(fourcc);
    h[108..112].copy_from_slice(&0x1000u32.to_le_bytes()); // DDSCAPS_TEXTURE
    h
}

fn flatten(expected: &[[u8; 4]]) -> Vec<u8> {
    expected.iter().flat_map(|p| p.iter().copied()).collect()
}

// --- Synthetic unit tests: hand-computed expected RGBA -----------------------

/// c0=0xF800 (red), c1=0x07E0 (green), c0>c1 => 4-colour mode.
#[test]
fn synthetic_dxt1_block() {
    let mut bytes = make_header(4, 4, b"DXT1", 8);
    bytes.extend_from_slice(&[0x00, 0xF8, 0xE0, 0x07, 0x00, 0x55, 0xAA, 0xFF]);
    let img = parse(&bytes).expect("parse synthetic DXT1");
    assert_eq!((img.width, img.height, img.format), (4, 4, FourCc::Dxt1));

    // Palette: p0=(255,0,0), p1=(0,255,0), p2=(170,85,0), p3=(85,170,0).
    // Selector rows 0x00,0x55,0xAA,0xFF => each row is one palette entry.
    let expected: [[u8; 4]; 16] = [
        [255, 0, 0, 255], [255, 0, 0, 255], [255, 0, 0, 255], [255, 0, 0, 255],
        [0, 255, 0, 255], [0, 255, 0, 255], [0, 255, 0, 255], [0, 255, 0, 255],
        [170, 85, 0, 255], [170, 85, 0, 255], [170, 85, 0, 255], [170, 85, 0, 255],
        [85, 170, 0, 255], [85, 170, 0, 255], [85, 170, 0, 255], [85, 170, 0, 255],
    ];
    assert_eq!(img.rgba, flatten(&expected), "DXT1 synthetic block mismatch");
}

/// c0=0x07E0 (green) < c1=0xF800 (red) => 3-colour mode, index 3 transparent.
#[test]
fn synthetic_dxt1_three_colour_transparent() {
    let mut bytes = make_header(4, 4, b"DXT1", 8);
    bytes.extend_from_slice(&[0xE0, 0x07, 0x00, 0xF8, 0x00, 0x55, 0xAA, 0xFF]);
    let img = parse(&bytes).expect("parse synthetic DXT1 3-colour");
    assert_eq!(img.format, FourCc::Dxt1);

    // Palette: p0=(0,255,0), p1=(255,0,0), p2=(127,127,0), p3=(0,0,0,0).
    let expected: [[u8; 4]; 16] = [
        [0, 255, 0, 255], [0, 255, 0, 255], [0, 255, 0, 255], [0, 255, 0, 255],
        [255, 0, 0, 255], [255, 0, 0, 255], [255, 0, 0, 255], [255, 0, 0, 255],
        [127, 127, 0, 255], [127, 127, 0, 255], [127, 127, 0, 255], [127, 127, 0, 255],
        [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0],
    ];
    assert_eq!(img.rgba, flatten(&expected), "DXT1 transparent case mismatch");
}

/// Explicit 4-bit alpha nibbles 0..15 -> 8-bit alpha 0,17,...,255.
#[test]
fn synthetic_dxt3_block() {
    let mut bytes = make_header(4, 4, b"DXT3", 16);
    bytes.extend_from_slice(&[0x10, 0x32, 0x54, 0x76, 0x98, 0xBA, 0xDC, 0xFE]);
    bytes.extend_from_slice(&[0x00, 0xF8, 0xE0, 0x07, 0x00, 0x55, 0xAA, 0xFF]);
    let img = parse(&bytes).expect("parse synthetic DXT3");
    assert_eq!(img.format, FourCc::Dxt3);

    let expected: [[u8; 4]; 16] = [
        [255, 0, 0, 0], [255, 0, 0, 17], [255, 0, 0, 34], [255, 0, 0, 51],
        [0, 255, 0, 68], [0, 255, 0, 85], [0, 255, 0, 102], [0, 255, 0, 119],
        [170, 85, 0, 136], [170, 85, 0, 153], [170, 85, 0, 170], [170, 85, 0, 187],
        [85, 170, 0, 204], [85, 170, 0, 221], [85, 170, 0, 238], [85, 170, 0, 255],
    ];
    assert_eq!(img.rgba, flatten(&expected), "DXT3 synthetic block mismatch");
}

/// a0=255,a1=0 => codebook [255,0,218,182,145,109,72,36]; indices 0..7,0..7.
#[test]
fn synthetic_dxt5_block() {
    let mut bytes = make_header(4, 4, b"DXT5", 16);
    bytes.extend_from_slice(&[0xFF, 0x00, 136, 198, 250, 136, 198, 250]);
    bytes.extend_from_slice(&[0x00, 0xF8, 0xE0, 0x07, 0x00, 0x55, 0xAA, 0xFF]);
    let img = parse(&bytes).expect("parse synthetic DXT5");
    assert_eq!(img.format, FourCc::Dxt5);

    // Colour rows are constant (selectors 0x00,0x55,0xAA,0xFF); alpha cycles
    // through the 8-entry LUT per pixel (indices 0..7 then 0..7).
    let expected: [[u8; 4]; 16] = [
        [255, 0, 0, 255], [255, 0, 0, 0], [255, 0, 0, 218], [255, 0, 0, 182],
        [0, 255, 0, 145], [0, 255, 0, 109], [0, 255, 0, 72], [0, 255, 0, 36],
        [170, 85, 0, 255], [170, 85, 0, 0], [170, 85, 0, 218], [170, 85, 0, 182],
        [85, 170, 0, 145], [85, 170, 0, 109], [85, 170, 0, 72], [85, 170, 0, 36],
    ];
    assert_eq!(img.rgba, flatten(&expected), "DXT5 synthetic block mismatch");
}

/// A single DXT1 block clipped to a 5x3 image: row-major, partial edge handled.
#[test]
fn synthetic_partial_edge_block() {
    // 5x3 => 2 blocks across x, 1 down: 16 compressed bytes.
    let mut bytes = make_header(5, 3, b"DXT1", 16);
    bytes.extend_from_slice(&[0x00, 0xF8, 0xE0, 0x07, 0x00, 0x55, 0xAA, 0xFF]);
    // Second block: c0=0x001F (blue), c1=0x0000 (black), all selectors 0.
    bytes.extend_from_slice(&[0x1F, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]);
    let img = parse(&bytes).expect("parse partial edge block");
    assert_eq!((img.width, img.height), (5, 3));
    assert_eq!(img.rgba.len(), 5 * 3 * 4);

    // Block 1 fills x=0..3; the clipped x=4 column comes from block 2 (blue).
    let expected: [[u8; 4]; 15] = [
        [255, 0, 0, 255], [255, 0, 0, 255], [255, 0, 0, 255], [255, 0, 0, 255], [0, 0, 255, 255],
        [0, 255, 0, 255], [0, 255, 0, 255], [0, 255, 0, 255], [0, 255, 0, 255], [0, 0, 255, 255],
        [170, 85, 0, 255], [170, 85, 0, 255], [170, 85, 0, 255], [170, 85, 0, 255], [0, 0, 255, 255],
    ];
    assert_eq!(img.rgba, flatten(&expected), "partial edge block mismatch");
}

#[test]
fn rejects_bad_magic_header_dx10_and_truncation() {
    let mut bad = make_header(4, 4, b"DXT1", 8);
    bad[0] = b'X';
    assert!(matches!(parse(&bad), Err(DdsError::BadMagic(_))));

    let mut bad_size = make_header(4, 4, b"DXT1", 8);
    bad_size[4] = 125;
    assert!(matches!(parse(&bad_size), Err(DdsError::BadHeaderSize(125))));

    let mut dx10 = make_header(4, 4, b"DX10", 20);
    dx10.extend_from_slice(&[0u8; 20]);
    match parse(&dx10) {
        Err(DdsError::UnsupportedFormat(msg)) => assert!(msg.contains("DX10"), "msg: {msg}"),
        other => panic!("expected DX10 unsupported error, got {other:?}"),
    }

    let truncated = make_header(4, 4, b"DXT1", 8); // no payload bytes
    assert!(matches!(
        parse(&truncated),
        Err(DdsError::TruncatedData { expected: 8, got: 0 })
    ));
}

// --- Donor golden comparison (Pillow generated at test time) -----------------

fn golden_dir() -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("target")
        .join("dds_golden")
}

fn read_meta(path: &Path) -> BTreeMap<String, String> {
    let text = std::fs::read_to_string(path)
        .unwrap_or_else(|e| panic!("cannot read meta {}: {e}", path.display()));
    let mut m = BTreeMap::new();
    for line in text.lines() {
        if let Some((k, v)) = line.split_once(' ') {
            m.insert(k.to_string(), v.to_string());
        }
    }
    m
}

fn generate_golden(donor: &Path, out: &Path) -> BTreeMap<String, String> {
    let script = Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("tests")
        .join("tools")
        .join("dds_golden.py");
    let status = Command::new("python")
        .arg(&script)
        .arg(donor)
        .arg(out)
        .status()
        .unwrap_or_else(|e| panic!("cannot run python golden generator: {e}"));
    assert!(
        status.success(),
        "python golden generator failed for {}",
        donor.display()
    );
    let name = donor.file_stem().unwrap().to_string_lossy();
    read_meta(&out.join(format!("{name}.meta.txt")))
}

/// Decode a real donor DDS, compare header fields to Pillow and RGBA bytes to
/// a Pillow golden. Donor pixels never enter the repo (golden is under target/).
#[test]
fn donor_golden_bytes_match() {
    let out = golden_dir();
    // grass1/sand1 are the terrain-tile examples in the ticket (both DXT1);
    // pine1.dds and highlight.ally.dds add real DXT3 and DXT5 donor coverage.
    let cases: [(&str, u32, u32, &str); 4] = [
        ("data\\terrain\\tiles\\textures\\grass1.dds", 1024, 1024, "DXT1"),
        ("data\\terrain\\tiles\\textures\\sand1.dds", 256, 256, "DXT1"),
        ("data\\materials\\env\\pine1.dds", 512, 512, "DXT3"),
        ("data\\brushes\\textures\\highlight.ally.dds", 64, 64, "DXT5"),
    ];

    for (rel, expect_w, expect_h, expect_fourcc) in cases {
        let donor = Path::new(DONOR_ROOT).join(rel);
        let file = donor.file_name().unwrap().to_string_lossy().into_owned();
        if !donor.exists() {
            eprintln!("SKIP {file}: donor file absent (synthetic tests still cover decoder)");
            continue;
        }

        let meta = generate_golden(&donor, &out);
        // Header fields must agree with what Pillow reports for the same file.
        assert_eq!(meta["header_size"], "124");
        assert_eq!(meta["magic"], "DDS ");
        assert_eq!(meta["fourcc"], expect_fourcc);
        assert_eq!(meta["width"], expect_w.to_string());
        assert_eq!(meta["height"], expect_h.to_string());
        assert_eq!(meta["pillow_width"], expect_w.to_string());
        assert_eq!(meta["pillow_height"], expect_h.to_string());
        assert_eq!(meta["pillow_mode"], "RGBA");
        assert_eq!(meta["pillow_format"], "DDS");

        let img = decode_file(&donor).unwrap_or_else(|e| panic!("decode {file}: {e}"));
        assert_eq!(img.width, expect_w);
        assert_eq!(img.height, expect_h);
        assert_eq!(img.format.as_str(), expect_fourcc);

        let stem = donor.file_stem().unwrap().to_string_lossy();
        let golden = std::fs::read(out.join(format!("{stem}.rgba")))
            .unwrap_or_else(|e| panic!("cannot read golden for {file}: {e}"));
        let golden_len: usize = meta["rgba_len"].parse().unwrap();
        assert_eq!(golden.len(), golden_len, "golden length meta mismatch");
        assert_eq!(golden.len(), img.rgba.len(), "RGBA length mismatch for {file}");

        let mut mismatches = 0usize;
        let mut max_delta = 0i32;
        let mut first: Option<(usize, u8, u8)> = None;
        for (i, (got, want)) in img.rgba.iter().zip(golden.iter()).enumerate() {
            if got != want {
                mismatches += 1;
                max_delta = max_delta.max((*got as i32 - *want as i32).abs());
                if first.is_none() {
                    first = Some((i, *got, *want));
                }
            }
        }
        let pct = 100.0 * mismatches as f64 / img.rgba.len() as f64;
        eprintln!(
            "GOLDEN {file}: bytes={} mismatches={} ({:.6}%) max_delta={} first={:?}",
            img.rgba.len(),
            mismatches,
            pct,
            max_delta,
            first
        );
        assert_eq!(
            mismatches, 0,
            "{file}: decoded RGBA differs from Pillow golden ({pct:.4}% of bytes)"
        );
    }
}
