# T6-R05-OSS — `.oss` skinned-animation reader (Rust, std-only)

**Worker:** T6-R05-OSS (child of T6-RUST). **Date:** 2026-11-23.
**Donor:** `C:\Games\Cossacks 3` — PRIVATE USE ONLY, read at test time; no donor bytes committed.
**Claim labels:** `observed` = directly read/measured; `derived` = computed from observed data; `inferred` = conclusion from a documented/established fact, not re-verified here.

## Files changed

| Path | Status | Backup |
|---|---|---|
| `rustport/src/assets/oss.rs` | NEW | n/a (new file) |
| `rustport/tests/assets_oss.rs` | NEW | n/a (new file) |
| `docs/t6/reports/T6-R05-OSS.md` | NEW | n/a (new file) |

No existing owned file was edited, so the backup rule did not trigger. Nothing under `app/**`, `Cargo.toml`, `src/main.rs`, `src/assets.rs` (integration stub), sibling `assets/*.rs`, `SWARM_BOARD.md`, or other docs was touched.

## Claim table

| # | Claim | Label | Evidence |
|---|---|---|---|
| 1 | Header `yacht.oss` = `k=311, fps=30, b=20, v=584, fc=947, t=793` | observed | `python -c "struct.unpack('<6i', ...)"` on donor file; also asserted in `rustport/tests/assets_oss.rs::donor_yacht_oss` |
| 2 | Header `peaukr.oss` = `k=483, fps=30, b=20, v=577, fc=921, t=733` | observed | same method; `donor_peaukr_oss` |
| 3 | On-disk sizes: 217,344 B (`yacht`), 312,376 B (`peaukr`) | observed | `Get-Item` on donor files + `fs::read(...).len()` assertions in tests |
| 4 | Payload order = verts `v×3f`, faces `fc×3i`, UVs `t×2f`, UV-index triples `fc×3i`, `v` weight lists, `b×k` tracks of `7f` | observed | `docs/decomp/DC_FORMATS.md` §2.1; `app/tools/bake_sprites.py:57-69` (`read_oss`, read-only) |
| 5 | Exact size closure 217,344 / 312,376 B from the header counts | derived | `24 + v·12 + fc·12 + t·8 + fc·12 + Σweightbytes + b·k·28`; recomputed by the reader, asserted via `consumed_bytes() == file_len` |
| 6 | All 335 donor `.oss` files close exactly (no trailing/short files) | observed | read-only Python census over `data/**/*.oss`: `exact closure: 335, trailing: 0, short: 0` |
| 7 | Sampled bone quaternions are unit norm (≈1.0, measured range 0.99999995–1.00000007 on `yacht`) | observed | read-only Python spot check; test asserts `|norm−1| < 0.05` on every 7th frame of every bone for both donors |
| 8 | Face vertex indices ∈ [0,v), UV indices ∈ [0,t), all verts/UVs finite | observed | assertions in `check_donor()`; `yacht` face[0] = `[1,2,8]`, uv_index[0] = `[0,1,2]` |
| 9 | Donor rotations are applied **transposed** (row-vector convention) by `bake_sprites.qmat`; reader returns raw tracks only | inferred | established port fact recorded in `DC_FORMATS.md` §2.1 line 64; documented in module docs; not re-derived from donor skinning code in this ticket |
| 10 | Reader is std-only with zero dependencies | observed | `rustport/Cargo.toml` `[dependencies]` empty; `oss.rs` imports only `std::{error::Error, fmt, fs, path::Path}` |
| 11 | Both donor files parse with **0 bytes left** | observed | `assert_eq!(oss.consumed_bytes(), data.len())` passes for both; strict `parse` rejects any trailing byte (`OssError::TrailingBytes`) |

## Acceptance criteria

| # | Criterion | Result |
|---|---|---|
| A1 | std-only `.oss` reader: 24-byte header + sequential payload in documented order | **PASS** |
| A2 | Public `Oss` struct (`k, fps, bones, vertices, faces, uvs, weights, tracks`), `parse(&[u8])`, `parse_file(&Path)` | **PASS** (+ additive `uv_indices` field and `consumed_bytes()` accessor; additive `OssError` enum) |
| A3 | `yacht.oss`: counts 311/30/20/584/947/793, exact 217,344-byte closure | **PASS** |
| A4 | `peaukr.oss`: counts 483/30/20/577/921/733, exact 312,376-byte closure | **PASS** |
| A5 | Finite/plausible vertex/face/quaternion spot checks (quat norm ≈1 sample) | **PASS** |
| A6 | Synthetic in-memory header+payload test works without donor files | **PASS** |
| A7 | From `rustport/`: `cargo test --test assets_oss` passes | **PASS** — `5 passed; 0 failed` |
| A8 | Transposed-rotation convention documented; raw tracks only | **PASS** |
| A9 | Ownership boundary + backup rule respected | **PASS** — only the 3 owned files written, all new |
| A10 | (informational, not an acceptance gate) repo-wide `cargo test` | **FAIL — external**: sibling `tests/assets_dds.rs::synthetic_partial_edge_block` fails at line 120; DDS is another worker's file, untouched by this ticket. Re-run after that worker's fix. |

## Commands and output tails

Run from `C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\rustport` (PowerShell).

```
PS> python --version
Python 3.14.3

PS> rustc --version
rustc 1.99.1 (58cf8f9c3 2026-10-13)
PS> cargo --version
cargo 1.99.1 (5f94df478 2026-08-27)

PS> Get-Item "C:\Games\Cossacks 3\data\actors\units\yacht.oss", "C:\Games\Cossacks 3\data\actors\units\peaukr.oss" | Select-Object Name, Length
yacht.oss   217344
peaukr.oss  312376
```

Header verification (read-only):

```
PS> python -c "import struct; ... struct.unpack('<6i', ...)"
yacht (311, 30, 20, 584, 947, 793)
peaukr (483, 30, 20, 577, 921, 733)
```

Required acceptance command (output tail, `EXITCODE=0`):

```
PS> cargo test --test assets_oss
   Compiling cossacks3-rust v0.1.0 (...)
    Finished `test` profile [unoptimized + debuginfo] target(s) in 3.74s
     Running tests\assets_oss.rs (target\debug\deps\assets_oss-5879f4953f2dea65.exe)

running 5 tests
test synthetic_header_and_payload_without_donor ... ok
test donor_yacht_oss ... ok
test parse_file_api_reads_donor_yacht ... ok
test donor_peaukr_oss ... ok
test rejects_truncated_and_trailing_input ... ok

test result: ok. 5 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.08s
EXITCODE=0
```

Note: piping `cargo` through PowerShell `Tee-Object` surfaces a harmless `NativeCommandError` because cargo writes progress to stderr; the captured `$LASTEXITCODE` is `0` and the test harness reports all 5 tests `ok`.

Repo-wide check (informational only; sibling DDS failure is out of scope):

```
PS> cargo test
...
---- synthetic_partial_edge_block stdout ----
thread 'synthetic_partial_edge_block' (24120) panicked at tests\assets_dds.rs:120:29:
parse partial edge block: TruncatedData { expected: 16, got: 8 }
test result: FAILED. 6 passed; 1 failed; 0 ignored; 0 measured; 0 filtered out;
error: test failed, to rerun pass `--test assets_dds`
EXITCODE=101
```

## Design notes / evidence paths

- Reader: `rustport/src/assets/oss.rs` — bounds-checked little-endian `Cursor`, negative-count and overflow guards, strict exact closure (`TrailingBytes` when bytes remain), raw track values with no de-transposition.
- Tests: `rustport/tests/assets_oss.rs` — includes the reader directly via `#[path = "../src/assets/oss.rs"] mod oss_reader;` (integration owns the `assets.rs` stub, so it was not edited).
- Reference docs (read-only): `docs/decomp/DC_FORMATS.md` §1 & §2.1; `app/tools/bake_sprites.py:57-69`; `SWARM_OPS.md` §7; `app/tools/AGENT_PROTOCOL.md` §0/§4.
- Donor files (runtime only, never committed): `C:\Games\Cossacks 3\data\actors\units\yacht.oss`, `...\peaukr.oss`.

## Open questions

1. **Integration wiring**: `rustport/src/assets.rs` is the integration-owned stub. Whoever owns integration must add `pub mod oss;` (or re-export `oss::*`) — this worker intentionally did not edit it. The test bypasses it via `#[path]`.
2. **`uv_indices` field**: additive beyond the task's field list; retained so no payload block is silently discarded. Confirm integration is happy with the extra public field.
3. **Strict closure**: `parse` rejects trailing bytes. All 335 donor `.oss` files close exactly, so this is safe for the donor corpus, but an outside consumer with padded/extension data would need a lenient variant. Add `parse_lenient` only if requested.
4. **Transposed rotations**: documented, not verified by this reader (raw tracks only). A future skinning ticket must apply the row-vector convention when consuming `tracks`.
5. **Sibling DDS test failure**: `tests/assets_dds.rs::synthetic_partial_edge_block` fails in repo-wide `cargo test`; outside this worker's ownership — flagged to T6-RUST lane parent, not fixed here.
