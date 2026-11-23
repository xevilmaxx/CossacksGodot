# T6-R05-AAF — std-only Rust reader for ASCII `.aaf` action ranges

**Worker:** T6-R05-AAF (child of lane parent T6-RUST).
**Scope:** ONE donor format (`.aaf`). No other assets reader, scaffold, manifest or board file was touched.
**Donor policy:** the donor file was read at inspection/test time only; no donor bytes were copied into the repository.

## Owned files written

| File | State |
|---|---|
| `rustport/src/assets/aaf.rs` | NEW — `Action`, `Aaf`, `AafError`, `parse`, `parse_file` |
| `rustport/tests/assets_aaf.rs` | NEW — 3 integration tests, includes reader via `#[path = "../src/assets/aaf.rs"] mod aaf_reader;` |
| `docs/t6/reports/T6-R05-AAF.md` | NEW — this report |

No owned file existed before this ticket, so the backup rule created no `.bak-T6-R05-AAF` copies.
`rustport/src/assets.rs` (integration-owned stub) was **not** edited.

## Claim table

| # | Claim | Label | Evidence | Verification method |
|---|---|---|---|---|
| C1 | `.aaf` is ASCII text: line 1 `AAF`, line 2 an action count, then `"name",start,end,morph` rows with inclusive bounds | observed | `docs/decomp/DC_FORMATS.md` §2.3 (lines 96–109); `app/tools/bake_sprites.py::read_aaf` (lines 71–82) | Direct read of both read-only references |
| C2 | `yacht.aaf` declares exactly 4 actions — `idle`, `walk`, `death`, `attack0` — each `start=1`, `end=280`, `morph="morph"` | observed | `docs/decomp/DC_FORMATS.md` §2.3 example; runtime read of `C:\Games\Cossacks 3\data\animations\aaf\yacht.aaf` by test `donor_yacht_aaf_has_four_full_range_actions` | Test assertion, passing; donor file 92 bytes, CRLF endings, final line ending present |
| C3 | The donor file uses CRLF and ends with a line terminator (trailing blank line) | observed | Hex inspection of the donor file at inspection time (`0D 0A` after every row, including the last) | `str::lines()` handles both LF and CRLF and does not emit a spurious trailing empty line; synthetic CRLF test passes |
| C4 | A quoted name may contain an escaped quote (`\"`), an escaped backslash (`\\`), and a literal comma without ending the field | derived | Required by the ticket; `read_aaf` uses a naive `split('"', 1)` and therefore cannot express it — the Rust reader must be stronger than the Python reference | Test `synthetic_crlf_escapes_and_trailing_blank_lines` asserts parsed name `say"hi,from\path` |
| C5 | `parse` rejects a wrong magic, a non-integer count, missing fields, an unterminated quote, an unknown escape, and a declared count exceeding the non-empty row count, reporting a line-numbered error | derived | Ticket requirement "reject malformed lines with a clear error"; `AafError` variants in `aaf.rs` | Test `malformed_inputs_are_rejected` asserts `Err` for all six cases and checks `line 1` / `line 3` in two messages |
| C6 | Rows after the first N non-empty ones are trailing content and are ignored | inferred | Ticket wording "the next N non-empty lines" plus "tolerate trailing blank lines"; no donor sample with extra non-empty rows was examined | Implemented as `break` once N actions are collected; no acceptance case exercises it — see Open question Q1 |
| C7 | `start <= end` is not enforced | inferred | The Python reference's `sample()` explicitly handles `b <= a`, so reversed ranges are meaningful to the pipeline | No validation added; negative and zero-width bounds are accepted (test covers both) — see Open question Q2 |
| C8 | Non-ASCII bytes in an `.aaf` file must not abort the read | inferred | Ticket: "read as ASCII/UTF-8 lossy if needed" | `parse_file` uses `fs::read` + `String::from_utf8_lossy`; no test exercises invalid UTF-8 — see Open question Q3 |

## Acceptance criteria — PASS / FAIL

| # | Criterion | Result |
|---|---|---|
| A1 | std-only Rust reader with the specified public API (`Action`, `Aaf`, `parse`, `parse_file`) | **PASS** — no dependencies; `Cargo.toml` untouched; zero `use` of any crate outside `std` |
| A2 | Line 1 magic, line 2 count, N non-empty rows, quoted name with escaped quotes/backslashes, inclusive i32 bounds, morph token | **PASS** — `parse_action` implements the grammar; synthetic test passes |
| A3 | Tolerates CRLF and trailing blank lines | **PASS** — `str::lines()` + blank-line skip; synthetic test passes |
| A4 | Rejects malformed lines with a clear error | **PASS** — `AafError` is `Debug + Display + Error` with line numbers; 6 negative cases pass |
| A5 | `parse_file` reads as ASCII/UTF-8 lossy | **PASS** — `fs::read` + `from_utf8_lossy` + `parse` |
| A6 | Runtime donor test: `yacht.aaf` → 4 actions `idle/walk/death/attack0`, all `1..280`, `morph` | **PASS** — test `donor_yacht_aaf_has_four_full_range_actions` |
| A7 | Synthetic test with escaped quote + comma, CRLF, trailing blank lines | **PASS** — test `synthetic_crlf_escapes_and_trailing_blank_lines` |
| A8 | Malformed-input test asserts `Err` | **PASS** — test `malformed_inputs_are_rejected` |
| A9 | `cargo test --test assets_aaf` passes from `rustport/` | **PASS** — 3 passed, 0 failed |
| A10 | Strict file ownership / no donor bytes committed | **PASS** — only the 3 owned files written; donor read at test runtime only |

## Commands run and output tails

From the project root, host-fact check (Python is `python`, not `python3` — this lane did not need Python):

```text
> python --version
Python 3.14.3
```

Concrete piece gate, run from `rustport/`:

```text
> cargo test --test assets_aaf
   Compiling cossacks3-rust v0.1.0 (C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\rustport)
warning: `cossacks3-rust` (bin "win32_demo") generated 6 warnings (run `cargo fix --bin "win32_demo" -p cossacks3-rust` to apply 1 suggestion)
    Finished `test` profile [unoptimized + debuginfo] target(s) in 6.95s
     Running tests\assets_aaf.rs (target\debug\deps\assets_aaf-180deff9f8b42c6d.exe)

running 3 tests
test synthetic_crlf_escapes_and_trailing_blank_lines ... ok
test donor_yacht_aaf_has_four_full_range_actions ... ok
test malformed_inputs_are_rejected ... ok

test result: ok. 3 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.02s
```

The 6 warnings are pre-existing in `src/platform/win32.rs` (owned by another worker) and are unrelated to this ticket. No Godot runner job was used — this is a headless Rust test.

## Evidence paths

- `docs/decomp/DC_FORMATS.md` §2.3 (format description and `yacht.aaf` example)
- `app/tools/bake_sprites.py` lines 71–82 (`read_aaf`, read-only)
- `C:\Games\Cossacks 3\data\animations\aaf\yacht.aaf` (donor, read at test time only, never committed)
- `rustport/src/assets/aaf.rs`, `rustport/tests/assets_aaf.rs` (this ticket)
- `SWARM_OPS.md` §7 (recursive swarm rules, piece-before-whole), `app/tools/AGENT_PROTOCOL.md` (ownership/backup rules)

## Open questions

1. **Q1 — extra non-empty rows after the N actions.** Currently ignored. If a donor `.aaf` has trailing comment/garbage rows, should they be rejected as malformed? No such sample was inspected; a validation sweep over all 246 donor `.aaf` files (deferred ticket T-2) would settle it.
2. **Q2 — `start > end`.** Accepted (no validation), matching the Python reference's handling of reversed ranges. Should the Rust reader reject them with a clear error instead?
3. **Q3 — invalid UTF-8.** `parse_file` uses lossy decoding as instructed, but this is untested; a synthetic byte-level test could be added if the integration owner wants that guarantee pinned.
4. **Q4 — integration.** `rustport/src/assets.rs` remains a stub owned by integration. Wiring `pub mod aaf;` (or a re-export) into it is an integration ticket, not part of this micro-task.

---
*T6-R05-AAF. One format, three tests, zero donor bytes committed.*
