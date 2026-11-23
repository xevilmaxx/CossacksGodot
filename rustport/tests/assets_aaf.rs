//! Integration tests for the std-only `.aaf` reader.
//!
//! `src/assets.rs` is an integration-owned stub, so this file includes the
//! reader directly by path instead of going through the crate module tree.

#[path = "../src/assets/aaf.rs"]
mod aaf_reader;

use std::path::Path;

use aaf_reader::parse;

const DONOR_YACHT: &str = r"C:\Games\Cossacks 3\data\animations\aaf\yacht.aaf";

/// Acceptance 1: read the real donor file at runtime and check every field.
#[test]
fn donor_yacht_aaf_has_four_full_range_actions() {
    let path = Path::new(DONOR_YACHT);
    assert!(
        path.exists(),
        "donor file missing at test time: {} (donor is private use only)",
        DONOR_YACHT
    );

    // parse_file reads the donor bytes at test time; nothing is committed.
    let aaf = aaf_reader::parse_file(path).expect("yacht.aaf should parse");
    assert_eq!(aaf.actions.len(), 4, "yacht.aaf must declare 4 actions");

    let expected = ["idle", "walk", "death", "attack0"];
    for (action, name) in aaf.actions.iter().zip(expected.iter()) {
        assert_eq!(action.name, *name);
        assert_eq!(action.start, 1, "{} start", name);
        assert_eq!(action.end, 280, "{} end", name);
        assert_eq!(action.morph, "morph", "{} morph", name);
    }
}

/// Acceptance 2: escaped quote + backslash inside a quoted name, a comma in
/// that name, CRLF line endings, a blank line between actions and trailing
/// blank lines. A negative start bound is included as an integer sanity check.
#[test]
fn synthetic_crlf_escapes_and_trailing_blank_lines() {
    let text = concat!(
        "AAF\r\n",
        "3\r\n",
        "\"say\\\"hi,from\\\\path\",10,20,morph\r\n",
        "\"plain\",-5,7,walk\r\n",
        "\r\n",
        "\"last\",0,0,idle\r\n",
        "\r\n",
        "\r\n",
    );

    let aaf = parse(text).expect("synthetic CRLF input should parse");
    assert_eq!(aaf.actions.len(), 3);

    assert_eq!(aaf.actions[0].name, "say\"hi,from\\path");
    assert_eq!(aaf.actions[0].start, 10);
    assert_eq!(aaf.actions[0].end, 20);
    assert_eq!(aaf.actions[0].morph, "morph");

    assert_eq!(aaf.actions[1].name, "plain");
    assert_eq!(aaf.actions[1].start, -5);
    assert_eq!(aaf.actions[1].end, 7);
    assert_eq!(aaf.actions[1].morph, "walk");

    assert_eq!(aaf.actions[2].name, "last");
    assert_eq!(aaf.actions[2].start, 0);
    assert_eq!(aaf.actions[2].end, 0);
    assert_eq!(aaf.actions[2].morph, "idle");
}

/// Acceptance 3: malformed inputs return Err, with a line-numbered message.
#[test]
fn malformed_inputs_are_rejected() {
    // Wrong magic.
    let wrong_magic = parse("NOTAAF\n1\n\"a\",1,2,morph\n");
    assert!(wrong_magic.is_err(), "wrong magic must be rejected");
    assert!(wrong_magic.unwrap_err().to_string().contains("line 1"));

    // Missing fields (no end / morph).
    let missing = parse("AAF\n1\n\"a\",1\n");
    assert!(missing.is_err(), "missing fields must be rejected");
    let msg = missing.unwrap_err().to_string();
    assert!(msg.contains("line 3"), "error should name the bad line: {msg}");

    // Non-integer count.
    assert!(parse("AAF\nx\n\"a\",1,2,morph\n").is_err());

    // Unterminated quoted name.
    assert!(parse("AAF\n1\n\"a,1,2,morph\n").is_err());

    // Declared count larger than the number of non-empty action lines.
    assert!(parse("AAF\n2\n\"a\",1,2,morph\n").is_err());

    // Unknown escape sequence in the quoted name.
    assert!(parse("AAF\n1\n\"a\\q\",1,2,morph\n").is_err());
}
