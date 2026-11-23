//! std-only reader for the donor ASCII action-range `.aaf` format.
//!
//! Layout (per `docs/decomp/DC_FORMATS.md` §2.3 and `app/tools/bake_sprites.py::read_aaf`):
//! ```text
//! AAF
//! <N>
//! "name",start,end,morph
//! ...  (N non-empty lines)
//! ```
//! Line 1 is the literal magic `AAF`, line 2 is the action count, and each of
//! the next N non-empty lines declares one action. `start`/`end` are inclusive
//! frame bounds. CRLF endings and trailing blank lines are tolerated.
//!
//! Donor assets are PRIVATE USE ONLY: this module only reads them at runtime
//! from the donor path supplied by the caller; no donor bytes live in the repo.

use std::error::Error;
use std::fmt;
use std::fs;
use std::path::Path;

/// One action range declared by an `.aaf` file.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Action {
    pub name: String,
    pub start: i32,
    pub end: i32,
    pub morph: String,
}

/// Parsed contents of an `.aaf` file.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Aaf {
    pub actions: Vec<Action>,
}

/// Errors produced while parsing or reading an `.aaf` file.
#[derive(Debug)]
pub enum AafError {
    /// The file could not be read from disk.
    Io(std::io::Error),
    /// Line 1 was not the literal `AAF` magic.
    BadMagic { found: String },
    /// Line 2 was not a non-negative integer action count.
    BadCount { line_no: usize, text: String },
    /// Fewer non-empty action lines were present than the declared count.
    TooFewActions { expected: usize, found: usize },
    /// A non-empty action line did not match `"name",start,end,morph`.
    Malformed {
        line_no: usize,
        text: String,
        reason: String,
    },
}

impl fmt::Display for AafError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            AafError::Io(e) => write!(f, "aaf: I/O error: {e}"),
            AafError::BadMagic { found } => {
                write!(f, "aaf: line 1: expected magic \"AAF\", found {found:?}")
            }
            AafError::BadCount { line_no, text } => write!(
                f,
                "aaf: line {line_no}: expected an integer action count, found {text:?}"
            ),
            AafError::TooFewActions { expected, found } => write!(
                f,
                "aaf: declared {expected} actions but found only {found} non-empty action lines"
            ),
            AafError::Malformed {
                line_no,
                text,
                reason,
            } => write!(
                f,
                "aaf: line {line_no}: malformed action {text:?}: {reason} \
                 (expected \"name\",start,end,morph)"
            ),
        }
    }
}

impl Error for AafError {
    fn source(&self) -> Option<&(dyn Error + 'static)> {
        match self {
            AafError::Io(e) => Some(e),
            _ => None,
        }
    }
}

impl From<std::io::Error> for AafError {
    fn from(e: std::io::Error) -> Self {
        AafError::Io(e)
    }
}

/// A byte-position cursor over one action line. All positions stay on
/// `char` boundaries, so string slicing by `pos` is always valid UTF-8.
struct Cursor<'a> {
    s: &'a str,
    pos: usize,
}

impl<'a> Cursor<'a> {
    fn new(s: &'a str) -> Self {
        Cursor { s, pos: 0 }
    }

    fn peek(&self) -> Option<char> {
        self.s[self.pos..].chars().next()
    }

    fn next(&mut self) -> Option<char> {
        let c = self.peek()?;
        self.pos += c.len_utf8();
        Some(c)
    }

    fn skip_ws(&mut self) {
        while matches!(self.peek(), Some(c) if c.is_whitespace()) {
            self.next();
        }
    }
}

fn malformed(line_no: usize, line: &str, reason: impl Into<String>) -> AafError {
    AafError::Malformed {
        line_no,
        text: line.to_string(),
        reason: reason.into(),
    }
}

fn parse_i32_field(
    c: &mut Cursor<'_>,
    field: &str,
    line_no: usize,
    line: &str,
) -> Result<i32, AafError> {
    c.skip_ws();
    let begin = c.pos;
    while matches!(c.peek(), Some(ch) if ch.is_ascii_digit() || ch == '-' || ch == '+') {
        c.next();
    }
    let text = &c.s[begin..c.pos];
    if text.is_empty() {
        return Err(malformed(line_no, line, format!("missing {field} integer")));
    }
    text.parse::<i32>()
        .map_err(|_| malformed(line_no, line, format!("invalid {field} integer {text:?}")))
}

/// Parse a single `"name",start,end,morph` line.
fn parse_action(line: &str, line_no: usize) -> Result<Action, AafError> {
    let mut c = Cursor::new(line);
    c.skip_ws();
    if c.next() != Some('"') {
        return Err(malformed(
            line_no,
            line,
            "expected a quoted name starting with '\"'",
        ));
    }

    let mut name = String::new();
    loop {
        match c.next() {
            Some('"') => break,
            Some('\\') => match c.next() {
                Some('"') => name.push('"'),
                Some('\\') => name.push('\\'),
                Some(x) => {
                    return Err(malformed(
                        line_no,
                        line,
                        format!("unknown escape '\\{x}' in name"),
                    ))
                }
                None => {
                    return Err(malformed(
                        line_no,
                        line,
                        "trailing backslash in name",
                    ))
                }
            },
            Some(ch) => name.push(ch),
            None => {
                return Err(malformed(
                    line_no,
                    line,
                    "unterminated quoted name (missing closing '\"')",
                ))
            }
        }
    }

    c.skip_ws();
    if c.next() != Some(',') {
        return Err(malformed(line_no, line, "expected ',' after name"));
    }
    let start = parse_i32_field(&mut c, "start", line_no, line)?;
    c.skip_ws();
    if c.next() != Some(',') {
        return Err(malformed(line_no, line, "expected ',' after start"));
    }
    let end = parse_i32_field(&mut c, "end", line_no, line)?;
    c.skip_ws();
    if c.next() != Some(',') {
        return Err(malformed(line_no, line, "expected ',' after end"));
    }

    c.skip_ws();
    let morph_begin = c.pos;
    while c.next().is_some() {}
    let morph = c.s[morph_begin..].trim();
    if morph.is_empty() {
        return Err(malformed(line_no, line, "missing morph token"));
    }
    if morph.chars().any(char::is_whitespace) {
        return Err(malformed(
            line_no,
            line,
            "morph must be a single token without whitespace",
        ));
    }

    Ok(Action {
        name,
        start,
        end,
        morph: morph.to_string(),
    })
}

/// Parse `.aaf` text. `str::lines()` transparently accepts LF or CRLF and does
/// not emit a spurious empty line for a final line ending; explicit blank
/// lines are skipped.
pub fn parse(text: &str) -> Result<Aaf, AafError> {
    let lines: Vec<&str> = text.lines().collect();

    let magic = lines.first().copied().unwrap_or("").trim();
    if magic != "AAF" {
        return Err(AafError::BadMagic {
            found: magic.to_string(),
        });
    }

    let count_text = lines.get(1).copied().unwrap_or("").trim();
    let expected: usize = count_text.parse().map_err(|_| AafError::BadCount {
        line_no: 2,
        text: count_text.to_string(),
    })?;

    let mut actions = Vec::with_capacity(expected);
    for (idx, raw) in lines.iter().enumerate().skip(2) {
        let line_no = idx + 1;
        let line = raw.trim();
        if line.is_empty() {
            continue;
        }
        if actions.len() == expected {
            // Exactly the first N non-empty lines are actions; anything after
            // them is trailing content and is ignored.
            break;
        }
        actions.push(parse_action(line, line_no)?);
    }

    if actions.len() < expected {
        return Err(AafError::TooFewActions {
            expected,
            found: actions.len(),
        });
    }

    Ok(Aaf { actions })
}

/// Read and parse an `.aaf` file from disk. Bytes are decoded as UTF-8 with
/// lossy fallback so stray non-ASCII bytes cannot abort the read.
pub fn parse_file(path: &Path) -> Result<Aaf, AafError> {
    let bytes = fs::read(path)?;
    let text = String::from_utf8_lossy(&bytes);
    parse(&text)
}
