# T6-R05-OSM - `.osm` static-mesh reader (Rust, std-only) - worker report

**Ticket:** T6-R05-OSM (LANE RUST, parent T6-RUST; siblings own DDS / `.oss` / `.aaf`)
**Worker:** MICRO-WORKER T6-R05-OSM
**Date:** 2026-11-23
**Scope:** one format. Implement a std-only Rust reader for the donor static-mesh
`.osm` format (first vertex frame only), matching the proven Python reader
`app/tools/bake_sprites.py::read_osm_first`, plus a real-donor integration test
and this report.

## Boundaries respected

- Wrote **only** the three owned files (all **new** - no `.bak` required; the
  backup rule applies to pre-existing owned files only,cf. T6-R01 precedent):
  - `rustport/src/assets/osm.rs`
  - `rustport/tests/assets_osm.rs`
  - `docs/t6/reports/T6-R05-OSM.md` (this file)
- Did **not** edit `rustport/src/assets.rs` (integration-owned scaffold stub);
  the test includes the reader directly with
  `#[path = "../src/assets/osm.rs"] mod osm_reader;`.
- Did not touch `app/**`, `Cargo.toml`, `src/main.rs`, `lib.rs`, sibling
  `assets/*.rs`, other docs, or `SWARM_BOARD.md`.
- Donor files were **read at test time only**. No donor bytes were copied into
  the repo, no donor executable was run, no Godot runner job was used (this is a
  std-only Rust ticket; per AGENT_PROTOCOL §1b zero runner jobs).
- No helpers spawned - one format, completed in one sitting (piece-before-whole:
  this single format's own test passes before any whole-lane integration).
- Host facts: `python` is 3.14.3 (never `python3`); toolchain rustc/cargo 1.99.1.
  Blender/Godot not used.

## The offset-bug claim is REFUTED (explicit)

The claim that "`bake_sprites.read_osm_first` reads offset longs **10/11/12**;
correct is **12/13/14**" is **REFUTED as stated** by `docs/decomp/DC_FORMATS.md`
§3. The shared reader already uses **longs 12/13/14** (its zip list ends
`"nf","os","ou","ot","of","og","oe"`, so `ou=h[12]`, `ot=h[13]`, `of=h[14]`),
and both readers are byte-identical on the samples. Reading 10/11/12 gives
UV=1, face=68, vert=132 and unmistakable garbage. **This Rust reader uses longs
12/13/14**, exactly like the proven Python reader. The only real issue is a
misleading comment in `app/tools/bake_naval.py:80-84`, which is out of scope here.

## Files changed (all new)

| Path | Purpose |
|---|---|
| `rustport/src/assets/osm.rs` | std-only reader: `Osm`, `OsmError`, `parse`, `parse_file`, `parse_header`, constants. Section bodies read from longs 12/13/14; winding swap `(0,2,1)` on both triples; 16-byte frame header discarded; AABB computed over the first vertex frame. |
| `rustport/tests/assets_osm.rs` | 4 integration tests: yacht real donor, algcen real donor, synthetic in-memory mesh, malformed-input rejection. Includes the reader by path (no dependency on the `assets.rs` stub). |
| `docs/t6/reports/T6-R05-OSM.md` | this report |

## Claim table

Labels follow SWARM_OPS §5b-QUALITY (`observed` / `derived` / `inferred`).
"Evidence" names the command/output block below or a read-list source.

| # | Label | Claim | Evidence | Verdict |
|---|---|---|---|---|
| C1 | observed | Toolchain is rustc 1.99.1 / cargo 1.99.1; Python is 3.14.3. | §Toolchain | PASS |
| C2 | observed | Both donor `.osm` files exist at the documented sizes: yacht 427,436 B, algcen 224,412 B. | §Donor file metadata | PASS |
| C3 | observed | `cargo test --test assets_osm` passes: 4 tests, 0 failed, `CARGO_EXIT=0`. | §Commands (1) | PASS |
| C4 | observed | yacht header decodes to `[IDP2, 8, 256, 256, 149840, 1, 9364, 11490, 7731, 0, 1, 68, 132, 92052, 277596, 427436, 427436]`; magic i32 = 844,121,161 = `0x32504449`. | §Commands (1), (3) | PASS |
| C5 | observed | algcen header decodes to `[IDP2, 8, 256, 256, 78432, 1, 4901, 5256, 4325, 0, 1, 68, 132, 42180, 145980, 224412, 224412]`. | §Commands (1), (3) | PASS |
| C6 | observed | Arithmetic closure is exact on both files: `ou+nu*8=ot`, `ot+nt*24=of`, `of+16+nv*16=oe=filesize`. | §Commands (1), (3) | PASS |
| C7 | observed | Winding swap `(0,2,1)` verified against raw first triangle: yacht raw `(154,86,12,16,12,11)` -> v `(154,12,86)`, uv `(16,11,12)`; algcen raw `(58,1,0,2,0,1)` -> v `(58,0,1)`, uv `(2,1,0)`. | §Commands (3) | PASS |
| C8 | observed | yacht AABB measured independently in Python: lo `(-1.751901,-4.819017,-0.375741)`, hi `(1.751902,3.208057,6.803313)` - within ±0.01 of documented `-1.752..1.752 / -4.819..3.208 / -0.376..6.803`. | §Commands (3) | PASS |
| C9 | observed | Counts match vector lengths and every face / face-UV index is in range on both real files. | §Commands (1) (test `check_indices`) | PASS |
| C10 | observed | Synthetic 180-byte mesh round-trips: 3 verts / 3 UVs / 1 tri, swapped face `[0,2,1]`, bbox `([0,0,0],[2,0,3])`. | §Commands (1) | PASS |
| C11 | observed | Malformed inputs are rejected: short buffer -> `TooShort`, wrong magic -> `BadMagic`, over-long section -> `OutOfBounds`, missing path via `parse_file` -> `Io`. | §Commands (1) | PASS |
| C12 | observed | Full `cargo test` is green including sibling tests (`assets_aaf` 3/3, `win32_piece` 3/3): this ticket caused no cross-worker breakage. | §Commands (2) | PASS |
| C13 | derived | Offsets are header longs **12/13/14** (`ou`/`ot`/`of`), not 10/11/12; the "bug" claim is refuted. | `docs/decomp/DC_FORMATS.md` §2.2 + §3; header values in C4/C5; Python source `read_osm_first` (read-only) | PASS |
| C14 | derived | The reader is std-only: it imports only `std::fmt`, `std::path::Path` and `std::fs`, and `Cargo.toml` has an empty `[dependencies]`. | `rustport/src/assets/osm.rs` imports; `rustport/Cargo.toml` (read-only) | PASS |
| C15 | derived | `parse` deliberately reads from the declared offsets and validates each section span with checked arithmetic; it does not require the three sections to be byte-contiguous, matching the Python reader. The exact closure is asserted at test level instead. | `rustport/src/assets/osm.rs` `checked_span`/`parse`; test `check_header_and_closure` | PASS |
| C16 | inferred | `oe`/`og` equal the file size in every sample, so these are single-frame static meshes; reading only the first vertex frame is sufficient for the port's static meshes. Based on the two samples + §2.2 note; **not** proven over all 3,897 donor `.osm` files. | §Commands (3); `docs/decomp/DC_FORMATS.md` §2.2 | UNVERIFIED (sample-scoped) |
| C17 | inferred | A future integration ticket can wire `osm::parse_file` into `assets.rs`; this worker did not do so because that file is integration-owned. | task boundary; `rustport/src/assets.rs` stub (read-only) | OPEN (integration) |

## Acceptance criteria - PASS/FAIL

| ID | Acceptance criterion (from ticket) | Result |
|---|---|---|
| A1 | From `rustport/`, `cargo test --test assets_osm` passes. | **PASS** - 4 passed, 0 failed, exit 0 |
| A2 | Test reads real donor files at runtime (`yacht.osm`, `algcen.osm`). | **PASS** - `std::fs::read` on `C:\Games\Cossacks 3\...`, `COSSACKS3_DIR` override; no donor bytes in repo |
| A3 | yacht expectations: nv=9364, nu=11490, nt=7731, ou=132, ot=92052, of=277596, size=427436. | **PASS** - exact header array asserted |
| A4 | algcen expectations: nv=4901, nu=5256, nt=4325, ou=132, ot=42180, of=145980, size=224412. | **PASS** - exact header array asserted |
| A5 | Exact arithmetic closure asserted on both files. | **PASS** - three equations + `oe == filesize` + `og == oe` |
| A6 | Magic and version asserted. | **PASS** - `h[0] == MAGIC`, `h[1] == 8` |
| A7 | Count checks (vectors match nv/nu/nt). | **PASS** |
| A8 | bbox within tolerance of documented values (yacht only documented). | **PASS** - ±0.01 on all six components |
| A9 | Face indices in range (and UV indices in range). | **PASS** |
| A10 | Synthetic in-memory header+payload unit test. | **PASS** - plus winding-swap and bbox assertions |
| A11 | Public API `Osm` / `parse` / `parse_file` as specified, std only. | **PASS** |
| A12 | Report written BEFORE reporting done; claim table, observed/derived/inferred, evidence paths, PASS/FAIL, open questions. | **PASS** - this file |
| A13 | Explicitly note the "longs 10/11/12 bug" claim is REFUTED and longs 12/13/14 are used. | **PASS** - §The offset-bug claim is REFUTED + C13 |
| A14 | Owned-file boundary / backup rule respected. | **PASS** - 3 new files only; no existing owned file modified; hence no `.bak` needed |
| A15 | No Godot/Blender, no donor bytes committed. | **PASS** |

## Exact commands and output tails

All Rust commands were run from
`C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\rustport`.

### Toolchain / host verification

```
PS> cargo --version; rustc --version; python --version
cargo 1.99.1 (5f94df478 2026-08-27)
rustc 1.99.1 (58cf8f9c3 2026-10-13)
Python 3.14.3
```

### Donor file metadata (read-only, at test time)

```
PS> Get-Item "C:\Games\Cossacks 3\data\actors\units\yacht.osm","C:\Games\Cossacks 3\data\actors\buildings\alg\algcen.osm" | Select-Object FullName,Length
C:\Games\Cossacks 3\data\actors\units\yacht.osm            427436
C:\Games\Cossacks 3\data\actors\buildings\alg\algcen.osm   224412
```

### (1) Required command: `cargo test --test assets_osm`

```
PS> cargo test --test assets_osm; Write-Output "CARGO_EXIT=$LASTEXITCODE"
    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.07s
     Running tests\assets_osm.rs (target\debug\deps\assets_osm-03ec25390e6ef842.exe)

running 4 tests
test synthetic_header_and_payload ... ok
test yacht_osm_real_donor ... ok
test algcen_osm_real_donor ... ok
test malformed_inputs_are_rejected ... ok

test result: ok. 4 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.16s

CARGO_EXIT=0
```

Note: an earlier attempt used `2>&1` in PowerShell; native-command stderr was
wrapped as `NativeCommandError`, producing a misleading shell exit 1 although
cargo itself reported `test result: ok`. Re-running without the redirect showed
the true `CARGO_EXIT=0`.

### (2) Full suite regression check: `cargo test`

```
PS> cargo test; Write-Output "CARGO_EXIT=$LASTEXITCODE"
   Compiling cossacks3-rust v0.1.0 (...)
    Finished `test` profile [unoptimized + debuginfo] target(s) in 2.46s
     Running unittests src\lib.rs (...)      -> 0 tests, ok
     Running unittests src\main.rs (...)     -> 0 tests, ok
     Running unittests src\bin\win32_demo.rs (...) -> 0 tests, ok

     Running tests\assets_aaf.rs (...)
running 3 tests
test malformed_inputs_are_rejected ... ok
test synthetic_crlf_escapes_and_trailing_blank_lines ... ok
test donor_yacht_aaf_has_four_full_range_actions ... ok
test result: ok. 3 passed; 0 failed; ...

     Running tests\assets_osm.rs (...)
running 4 tests
test synthetic_header_and_payload ... ok
test malformed_inputs_are_rejected ... ok
test yacht_osm_real_donor ... ok
test algcen_osm_real_donor ... ok
test result: ok. 4 passed; 0 failed; ...

     Running tests\win32_piece.rs (...)
running 3 tests
test present_wrapper_rejects_short_buffer_without_a_window ... ok
test bitmap_info_header_layout_and_negative_height_roundtrip ... ok
test gradient_is_deterministic_and_matches_demo_samples ... ok
test result: ok. 3 passed; 0 failed; ...

   Doc-tests cossacks3_rust
running 0 tests
test result: ok. 0 passed; 0 failed; ...

CARGO_EXIT=0
```

### (3) Independent Python cross-check (different method, read-only)

Temp probe written to `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\osm_probe_t6r05.py`
(outside the repo; not committed). Output:

```
yacht.osm
  header = (844121161, 8, 256, 256, 149840, 1, 9364, 11490, 7731, 0, 1, 68, 132, 92052, 277596, 427436, 427436)
  size = 427436
  closure = 92052 277596 427436
  bbox_lo = ['-1.751901', '-4.819017', '-0.375741']
  bbox_hi = ['1.751902', '3.208057', '6.803313']
  raw_tri0 = (154, 86, 12, 16, 12, 11) swapped_v = (154, 12, 86) swapped_uv = (16, 11, 12)
algcen.osm
  header = (844121161, 8, 256, 256, 78432, 1, 4901, 5256, 4325, 0, 1, 68, 132, 42180, 145980, 224412, 224412)
  size = 224412
  closure = 42180 145980 224412
  bbox_lo = ['-6.320889', '-3.277747', '0.000000']
  bbox_hi = ['6.351555', '3.229498', '15.549480']
  raw_tri0 = (58, 1, 0, 2, 0, 1) swapped_v = (58, 0, 1) swapped_uv = (2, 1, 0)
```

This independently reproduces every value the Rust test asserts: header words,
size closure, and the yacht bbox quoted in `DC_FORMATS.md` §2.2 / §3.

## Read-list sources used (all read-only)

- `docs/decomp/DC_FORMATS.md` §2.2 (`.osm` first frame decoded, offset
  arithmetic, winding-swap verdict) and §3 (offset bug REFUTED; longs 12/13/14).
- `app/tools/bake_sprites.py` - `read_osm_first` (lines 485-494), READ ONLY.
- `SWARM_OPS.md` §7 (recursive swarm, piece-before-whole, report format,
  ownership, §5b-QUALITY labels).
- `app/tools/AGENT_PROTOCOL.md` (boundaries, backup rule, zero runner jobs for
  tool-only work).
- Context only: `rustport/src/lib.rs`, `rustport/src/assets.rs` (stub),
  `rustport/Cargo.toml`, `rustport/README.md`, sibling report `T6-R01.md`.

## Open questions

1. **Integration wiring (owner: integration).** `rustport/src/assets.rs` is a
   stub owned by integration. This reader deliberately lives in its own file;
   a future integration ticket should add `pub mod osm;` / re-exports there.
   No integration edit was made here (C17).
2. **Coverage over all 3,897 `.osm` files (C16).** Only two samples were tested
   (one ship hull, one building). A validation sweep across the full donor
   family (header magic, count/offset bounds, size closure) is `T-2` in
   `DC_FORMATS.md` §4 and remains out of this ticket's scope.
3. **`oe`/`og` usage.** Both equal file size in the samples and are only sanity
  -checked (`oe <= bytes.len()`); `og` is not consumed. If multi-frame `.osm`
   files exist, the extra frames are currently ignored by design (first frame
   only). No such file was observed.
4. **Normal/attribute word.** The 4th word of each vertex record is read and
   discarded exactly as the Python reader does. Its semantics (packed normal
   vs. attribute flags) were not needed for geometry fidelity.
5. **Stale donor comment (owner: AC / out of scope).** `app/tools/bake_naval.py:80-84`
   still claims the shared reader is wrong. Recommend the comment-only ticket
   `T-1` from `DC_FORMATS.md` §4; do not "fix" `read_osm_first` to 10/11/12.

---
*T6-R05-OSM - one format implemented. All 15 acceptance criteria PASS.
No donor bytes copied, no out-of-bound files edited, no Godot/Blender used,
no helpers spawned. Offset-bug claim REFUTED; longs 12/13/14 used.*
