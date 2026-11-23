# T6-R05-DDS — std-only DDS (DXT1/3/5) reader

**Ticket:** T6-R05-DDS (child of lane parent T6-RUST).
**Date:** 2026-11-23. **Host:** Windows, `python` = Python 3.14.3, Pillow 12.1.1,
Rust/cargo 1.99.x (edition 2021). **Donor:** `C:\Games\Cossacks 3` — private
use only; read at test time, never copied into the repo.

## 1. Scope and owned files

| Path | State | Purpose |
|---|---|---|
| `rustport/src/assets/dds.rs` | NEW | std-only DDS header parser + DXT1/3/5 → RGBA8 decoder and public API |
| `rustport/tests/assets_dds.rs` | NEW | 6 synthetic/negative unit tests + 1 donor/Pillow golden comparison test |
| `rustport/tests/tools/dds_golden.py` | NEW | Pillow golden + header-metadata generator (writes to `rustport/target/dds_golden` only) |
| `docs/t6/reports/T6-R05-DDS.md` | NEW | this report |

No existing owned file existed, so no backup was required. `rustport/src/assets.rs`
(scaffold stub, owned by integration), `Cargo.toml`, `src/main.rs`, all sibling
readers (`aaf.rs`, `osm.rs`, `oss.rs`), `SWARM_BOARD.md` and other docs were NOT edited.

Per the ticket, the test includes the reader directly:
`#[path = "../src/assets/dds.rs"] mod dds_reader;`.

## 2. Implementation summary

- **Header:** validates `b"DDS "` magic, `dwSize == 124`, reads flags / height /
  width / pitch-or-linear-size / depth / mip count, `ddspf` size+flags and
  FourCC at byte offset 84. Accepts `DXT1`, `DXT3`, `DXT5`; returns
  `DdsError::UnsupportedFormat` with an explicit message for `DX10` and for any
  other FourCC. Mip levels past the first are ignored (donor files carry mips;
  payload is validated as *at least* one top level, never "exactly one").
- **Blocks:** RGB565 endpoints expanded by bit replication (`r|r>>2`, `g|g>>4`,
  `b|b>>2`) — the same integer arithmetic as Pillow's `decode_565`; 4-colour
  palette `(2c0+c1)/3` and `(c0+2c1)/3`, 3-colour case `(c0+c1)/2` plus
  transparent black; DXT3 explicit 4-bit alpha replicated to 8 bits; DXT5
  8-entry alpha codebook with both `/7` and `/5` branches. All interpolation
  uses truncating integer division. Blocks are emitted row-major and clipped
  to the image rectangle (partial edge blocks).
- **API:** `pub struct DdsImage { width, height, format: FourCc, rgba: Vec<u8> }`,
  `pub fn parse(&[u8]) -> Result<DdsImage, DdsError>`,
  `pub fn decode_file(&Path) -> Result<DdsImage, DdsError>`, plus `FourCc`
  (`Dxt1`/`Dxt3`/`Dxt5`, `as_str()`), `DdsError` (`Display` + `Error`), and
  `DDS_HEADER_SIZE`. `decode_file` takes any path; the tests point it at donor files.

## 3. Claim table

Labels: **observed** = read directly from bytes/tool output/source; **derived** =
computed from observed values; **inferred** = interpretation, not proven here.

| # | Claim | Label | Evidence |
|---|---|---|---|
| C1 | `grass1.dds` = 1024×1024 DXT1; `sand1.dds` = 256×256 DXT1 (raw header at offsets 12/16/84) | observed | §5 command 1; `.meta.txt` sidecars |
| C2 | Pillow reports both files as `DDS / RGBA` with matching `im.size`; header size field = 124, magic `DDS ` | observed | §5 command 1; `.meta.txt` (`pillow_width/height/mode/format`) |
| C3 | Pillow 12.1.1 decodes DXTn with bit-replicated 565 expansion and truncating integer interpolation; DXT3 = 4-bit alpha nibble replication, DXT5 = 8-entry `/7` or `/5` codebook | observed | Pillow 12.1.1 `src/libImaging/BcnDecode.c` (`decode_565`, `decode_bc1_color`, `decode_bc2_block`, `decode_bc3_alpha`), fetched read-only |
| C4 | Reader output is **byte-identical** to `Image.open(path).convert('RGBA').tobytes()` for 4 donor files spanning DXT1/DXT3/DXT5 | observed | `GOLDEN ... mismatches=0` lines in §5 command 3 |
| C5 | Total compared payload = 5,521,408 bytes; total mismatching bytes = 0 (0.000000%) | derived | sum of the four `bytes=` values in §5 command 3 |
| C6 | Donor `data/` contains 1469 `.dds` files: 1284 DXT5, 179 DXT1, 6 DXT3, **0 DX10** FourCC | observed + derived | §5 command 5; sum = 1469 matches `DC_FORMATS.md` §1 family count |
| C7 | Synthetic hand-computed expectations for DXT1 4-colour, DXT1 3-colour/transparent, DXT3, DXT5, and a clipped 5×3 edge block all pass | observed | §5 command 3 test list |
| C8 | Full crate test suite passes (22 tests: 3 AAF + 7 DDS + 4 OSM + 5 OSS + 3 win32) — no regression to siblings | observed | §5 command 4 |
| C9 | Decoder deliberately ignores mips beyond level 0; DXT1 1-bit alpha was exercised only by a synthetic block, not by a donor file with transparent endpoints | observed | code + chosen donor samples (grass1/sand1 alpha = 255 throughout) |
| C10 | The 8 building-decal DDS reported unreadable by Pillow in `TERRAIN_DONOR_ASSETS.md` §3.2 are unlikely to be DX10, given the 0-DX10 census; they were not investigated (out of scope) | inferred | C6 + audit doc; needs a separate format-identification ticket |

## 4. Acceptance criteria

| # | Criterion | Result | Note |
|---|---|---|---|
| A1 | Parse 128-byte header (magic, dwSize, flags, w/h, pitch/depth, FourCC; DX10 reported unsupported) | **PASS** | header asserts against Python meta; `rejects_bad_magic_header_dx10_and_truncation` |
| A2 | DXT1 (1-bit alpha + no-alpha 3-colour), DXT3 4-bit alpha, DXT5 8-entry alpha, 4×4 blocks, partial edges, row-major top-down | **PASS** | 5 synthetic unit tests + 4 donor goldens |
| A3 | Public API `DdsImage` / `parse` / `decode_file` | **PASS** | all three exercised by tests |
| A4 | From `rustport/`: `cargo test --test assets_dds` passes | **PASS** | 7 passed, 0 failed, exit 0 (§5 commands 2–3) |
| A5 | Read real donor DDS at runtime | **PASS** | 4 donor files, no donor bytes in repo |
| A6 | Header fields match what Python/Pillow reports | **PASS** | width/height from header == `im.size`; mode/format == RGBA/DDS |
| A7 | Golden produced at test time by Python+Pillow, written to temp file under `rustport/target/`, read by Rust, compared byte-for-byte | **PASS** | `dds_golden.py` invoked via `std::process::Command` from the test; goldens gitignored (`git check-ignore` confirms) |
| A8 | Pure-unit synthetic 4×4 tests for all three formats | **PASS** | independent of donor presence |
| A9 | No rounding mismatch silently accepted | **PASS** | test asserts `mismatches == 0`; mismatch/delta statistics printed on every run |

## 5. Commands and output tails (exact)

Run from project root unless noted. PowerShell: `python`, not `python3`.

**Command 1 — Pillow version and raw header inspection (read-only):**
```
python -c "import PIL; from PIL import Image; print('Pillow', PIL.__version__)"
Pillow 12.1.1
python -c "import struct; ... unpack_from('<5I', b, 4) ... Image.open(p) ..."
grass1 magic b'DDS ' dwSize 124 h 659463 w 1024 pitch 1024 depth 524288 fourcc b'DXT1'
  Pillow: size (1024, 1024) mode RGBA format DDS
sand1  magic b'DDS ' dwSize 124 h 659463 w 256  pitch 256  depth 32768  fourcc b'DXT1'
  Pillow: size (256, 256) mode RGBA format DDS
```
(Field labels in that ad-hoc print were shifted by one: the printed `h` is
`dwFlags`, `w` is `dwHeight`, `pitch` is `dwWidth`. Correct values are stated
in C1/C2 and are re-derived cleanly by `dds_golden.py`.)

**Command 2 — required test (plain form):**
```
cd rustport
cargo test --test assets_dds
    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.10s
     Running tests\assets_dds.rs (target\debug\deps\assets_dds-a2323e5241229314.exe)

running 7 tests
test synthetic_dxt1_three_colour_transparent ... ok
test synthetic_dxt3_block ... ok
test rejects_bad_magic_header_dx10_and_truncation ... ok
test synthetic_dxt5_block ... ok
test synthetic_partial_edge_block ... ok
test synthetic_dxt1_block ... ok
golden grass1: 1024x1024 fourcc=b'DXT1' pillow=(1024, 1024) RGBA/DDS rgba_len=4194304
golden sand1: 256x256 fourcc=b'DXT1' pillow=(256, 256) RGBA/DDS rgba_len=262144
test donor_golden_bytes_match ... ok

test result: ok. 7 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 2.74s
EXITCODE=0
```

**Command 3 — same test with `--nocapture` (mismatch statistics exposed):**
```
cargo test --test assets_dds -- --nocapture
running 7 tests
... all synthetic/negative tests ok ...
golden grass1: 1024x1024 fourcc=b'DXT1' pillow=(1024, 1024) RGBA/DDS rgba_len=4194304
GOLDEN grass1.dds: bytes=4194304 mismatches=0 (0.000000%) max_delta=0 first=None
golden sand1: 256x256 fourcc=b'DXT1' pillow=(256, 256) RGBA/DDS rgba_len=262144
GOLDEN sand1.dds: bytes=262144 mismatches=0 (0.000000%) max_delta=0 first=None
golden pine1: 512x512 fourcc=b'DXT3' pillow=(512, 512) RGBA/DDS rgba_len=1048576
GOLDEN pine1.dds: bytes=1048576 mismatches=0 (0.000000%) max_delta=0 first=None
golden highlight.ally: 64x64 fourcc=b'DXT5' pillow=(64, 64) RGBA/DDS rgba_len=16384
GOLDEN highlight.ally.dds: bytes=16384 mismatches=0 (0.000000%) max_delta=0 first=None
test donor_golden_bytes_match ... ok

test result: ok. 7 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 9.22s
EXITCODE=0
```

**Command 4 — full crate suite (regression check):**
```
cargo test
... unittests lib/main/win32_demo: 0 tests each ...
     Running tests\assets_aaf.rs ... 3 passed; 0 failed
     Running tests\assets_dds.rs ... 7 passed; 0 failed
     Running tests\assets_osm.rs ... 4 passed; 0 failed
     Running tests\assets_oss.rs ... 5 passed; 0 failed
     Running tests\win32_piece.rs ... 3 passed; 0 failed
   Doc-tests cossacks3_rust ... 0 passed
EXITCODE=0
```

**Command 5 — donor FourCC census (read-only, at test time):**
```
fourcc counts: {'DXT5': 1284, 'DXT1': 179, 'DXT3': 6}
DXT5 -> C:\Games\Cossacks 3\data\brushes\textures\highlight.ally.dds (64, 64)
DXT3 -> C:\Games\Cossacks 3\data\materials\env\pine1.dds (512, 512)
```

**Command 6 — repo hygiene:**
```
git check-ignore -v rustport/target/dds_golden/grass1.rgba
rustport/.gitignore:2:target/  rustport/target/dds_golden/grass1.rgba
```
Goldens and donor pixels live only under `rustport/target/dds_golden/`; none
are staged or committed.

## 6. Mismatch statistics

| Donor file | Format | Dimensions | RGBA bytes compared | Mismatching bytes | % | max per-byte delta | first mismatch |
|---|---|---:|---:|---:|---:|---:|---|
| `grass1.dds` | DXT1 | 1024×1024 | 4,194,304 | 0 | 0.000000% | 0 | none |
| `sand1.dds` | DXT1 | 256×256 | 262,144 | 0 | 0.000000% | 0 | none |
| `pine1.dds` | DXT3 | 512×512 | 1,048,576 | 0 | 0.000000% | 0 | none |
| `highlight.ally.dds` | DXT5 | 64×64 | 16,384 | 0 | 0.000000% | 0 | none |
| **TOTAL** | | | **5,521,408** | **0** | **0.000000%** | **0** | none |

There is no Pillow-versus-Rust rounding difference on the tested corpus. The
zero-mismatch result is attributed to mirroring Pillow's exact integer
interpolation (C3) rather than a tolerance-based comparison.

## 7. Open questions

1. **DX10 path is fail-loud but untested on donor data.** The census found 0
   DX10 FourCC files among 1469 donor `.dds`; the explicit
   `UnsupportedFormat` error is covered only by a synthetic test. If a future
   donor drop contains DX10/BC7 assets, a separate ticket should add BC7
   support or a documented skip list.
2. **8 building-decal DDS that Pillow could not open** (per
   `TERRAIN_DONOR_ASSETS.md` §3.2, C12) were not examined. Given the 0-DX10
   census they are probably malformed or use a non-BC FourCC rather than DX10;
   this ticket does not claim a cause. Suggest a small format-ID ticket.
3. **DXT1 1-bit alpha on real donor pixels.** The two DXT1 samples are fully
   opaque; the transparent/no-alpha-3-colour branch is verified only by the
   synthetic test. A DXT1 donor texture with transparent endpoints would give
   stronger real-data evidence if one exists.
4. **Integration wiring is not mine.** `rustport/src/assets.rs` remains the
   scaffold stub; a separate integration ticket must add `pub mod dds;` (and
   expose the reader through the crate) before engine code can consume it.
5. **Mip levels beyond level 0 are intentionally ignored.** If the renderer
   later needs mipmapping, the decoder must be extended to emit the full chain.

## 8. Evidence paths

- Reader: `rustport/src/assets/dds.rs`
- Tests: `rustport/tests/assets_dds.rs`
- Golden generator: `rustport/tests/tools/dds_golden.py`
- Golden output (gitignored, not committed): `rustport/target/dds_golden/*.meta.txt`, `rustport/target/dds_golden/*.rgba`
- Reference docs read: `docs/decomp/DC_FORMATS.md` §1–2,
  `docs/audit/TERRAIN_DONOR_ASSETS.md` §3.2, `SWARM_OPS.md` §7,
  `app/tools/AGENT_PROTOCOL.md`, `app/tools/bake_sprites.py` (`dds_to_png`)
- External source read (read-only): Pillow 12.1.1
  `src/libImaging/BcnDecode.c` via
  `https://raw.githubusercontent.com/python-pillow/Pillow/12.1.1/src/libImaging/BcnDecode.c`

---
*T6-R05-DDS. Piece-level gate PASS: std-only DXT1/3/5 decode matches Pillow
byte-for-byte on 4 real donor textures (5,521,408 bytes, 0 mismatches).*
