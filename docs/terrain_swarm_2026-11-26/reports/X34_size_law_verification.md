---
id: X34
ticket: TERRAIN-SWARM-2026-11-26 / X34 (DONOR-FIRST independent verification)
title: "X34 — independent 710/710 verification of the F01 `.pattern` size law, five-region layout and corrected grid offset G=8+(w-1)(h-1)"
agent: "worker X34 (read-only verifier; DONOR-FIRST terrain swarm 2026-11-26)"
date: 2026-11-26
status: REPORT LANDED__ONE_REPORT_ONLY__READ_ONLY__NO_CODE_EDITS__NO_GODOT
labels: [O, D, I, U, "PORT APPROXIMATION"]
donor: "C:\\Games\\Cossacks 3 (READ ONLY; raw bytes + latin-1 + struct only; no donor binary executed or copied)"
scope: "Exactly one repo file written: this report. Scratch scripts only in %TEMP%\\opencode\\size_law\\. No source/shader/config/asset/test/git/Godot edit."
verdict: "F01_CORE_CONFIRMED__710_710_SIZE_LAW__710_710_REGION_TILING__13_13_GRID_BIT_EXACT__V37_CONFIRMED__I02_SELFTEST_29_29__ONE_F01_DOC_TYPO__NO_PARITY_CLAIM"
parity_claim: false
parity_guard: "No donor GPU A/B frame exists (CHARTER §3). All port consequences are PORT APPROXIMATION; no donor visual parity is claimed."
---

# X34 — independent verification of F01's `.pattern` size law and layout

## 1. Executive summary

1. **[O]+[D] F01's size law is confirmed, 710 PASS / 0 FAIL.** For every one
   of the 710 donor `.pattern` files,
   `filesize = 8 + 4*w*h + 54*(w-1)*(h-1)` holds with **zero residual**.
   An independent second derivation solved `N` from the *file size*
   (`N_size = (S − 8 − 4wh)/54`) and checked it equals `(w−1)(h−1)` with
   remainder 0 for **710/710** files. No file breaks the law.
2. **[O]+[D] The layout closes as seven contiguous regions**, which is F01's
   "five regions" with the PRE+records block split: `header | mask | height |
   PRE | records | weights | tail`. All 710 files tile `[0, filesize)` with
   no gap and no overlap; exact boundaries for the four requested patterns
   are in §5.
3. **[O]+[D] The corrected grid offset `G = 8 + (w-1)*(h-1)` (V37) is
   confirmed 13/13 patterns**, each bit-exact against `pattern.lib`
   `HeightFieldMin`/`HeightFieldMax`. Crucially, extrema *alone* are ambiguous
   (§4.3, multi-pass P3): the offset is proven by **structural closure**, not
   by min/max scanning.
4. **[O] I02's decoder self-test claims are confirmed.** A read-only
   `python variant3d\tools\decode_donor_pattern.py --dry-run --check` reported
   `CHECK SUMMARY: PASS 29 / FAIL 0`; an independent validator of I02's
   in-memory output passed 710/710 on all six checks (§6). Dry-run wrote
   nothing.
5. **[U] Semantics remain unverifiable** for `Rec24.id`, `Rec24.tail4`/PRE,
   the `int32[4N−1]` weight block and the `Tail13` `i16`/`flag` fields, and for
   mask occupancy meaning, engine blend order and row flip — there is no
   donor plaintext consumer tying those bytes to field names (§7).
   **No parity claim.**

---

## 2. Evidence table

| # | Donor path : offset / line | Label | What it establishes |
|---:|---|---|---|
| E1 | `data\pattern\*.pattern` headers @`0x00`, 710/710 | [O] | Two LE `int32` `(w,h)`; `w*h` ∈ 16…9116. |
| E2 | `data\pattern\*.pattern`, full size census, 710/710 | [O]+[D] | `S == 8+4wh+54(w−1)(h−1)`, residual 0 (§4.1). |
| E3 | same files, size-derived `N` | [D] | `(S−8−4wh)/54 == (w−1)(h−1)`, rem 0, 710/710 (second instrument). |
| E4 | same files, region walker | [D] | Seven regions tile `[0,S)`, 710/710 (§4.2). |
| E5 | `data\pattern\fb_1.pattern:0x00000000` | [O] | `08 00 00 00 09 00 00 00` → w=8,h=9, S=3320. |
| E6 | `fb_1.pattern:0x00000040` | [O] | height plane start G=64 (`8+N`, N=56), 288 B of 0.0f. |
| E7 | `fb_1.pattern:0x00000160` | [O] | PRE=`00 00 00 00`; first `Rec24` @`0x164` id=`e1`=225. |
| E8 | `fb_1.pattern:0x000006A4` | [O] | weights region starts at byte 1700 (see anomaly A1). |
| E9 | `fb_1.pattern:0x00000A20` | [O] | tail starts 2592; `00×10 ff ff 01`. |
| E10 | `mni_1.pattern:0x00000000`, `:0x00000187`, `:0x00000B5F` | [O] | w=8,h=10; PRE=`00 00 00 00` @391; tail `ff ff 00` @2911. |
| E11 | `hil1.pattern:0x00000000`, `:0x000003C8`, `:0x000013CC` | [O] | w=25,h=41; G=968 (0x3C8); PRE=`08 08 00 00` @5068. |
| E12 | `k_ravine_big_stone_1.pattern:0x00000000`, `:0x002021`, `:0x00A361` | [O] | w=84,h=100; G=8225 (0x2021); PRE @41825, id `79`=121 @41829. |
| E13 | `pattern.lib:533127-533128` (`fb_1`) | [O] | Min=Max=0.0; bit-exact vs grid at G=64. |
| E14 | `pattern.lib:715177-715178` (`mni_1`) | [O] | Min=Max=0.0; bit-exact vs grid at G=71. |
| E15 | `pattern.lib:33111-33112` (`hil1`) | [O] | Min=0, Max=3.86130237579346; bit-exact at G=968. |
| E16 | `pattern.lib:730045-730046` (`k_ravine_big_stone_1`) | [O] | Min=−2.96362733840942, Max=0.173864871263504; bit-exact at G=8225. |
| E17 | `pattern.lib:549585-549586` (`k_ravine_1`) | [O] | Min=−2.963627576828, Max=3.13982009887695; bit-exact at G=2798. |
| E18 | `pattern.lib` full scan | [O] | 30,309,138 B; 1,172,417 lines; 680 sections (matches X05). |
| E19 | `variant3d\tools\decode_donor_pattern.py --dry-run --check` | [O] | printed `CHECK SUMMARY: PASS 29 / FAIL 0` (read-only, no writes). |
| E20 | I02 output, in-memory independent validation | [D] | 710/710 pass six structural checks (§6). |

Scratch artifacts (not repo): `%TEMP%\opencode\size_law\fresh_reader.py`,
`pass2.py`, `validate_i02_output.py`, `hexdump.py`, `fresh_results.json`.

---

## 3. Method

1. **Fresh reader, no reuse of F01 scripts.** `fresh_reader.py` re-derives
   everything from raw bytes with `pathlib` + `struct` + `os.stat` only. For
   each file: read 8-byte `<2i` header, compute `wh`, `N=(w−1)(h−1)`,
   `expected = 8+4wh+54N`, compare with `st_size`; derive all seven region
   boundaries from those numbers. No F01/I02 code was imported by this pass.
2. **Second independent instrument.** `pass2.py` solves `N` from *file size*
   alone (`N_size=(S−8−4wh)//54`, require rem 0) and scans candidate grid
   offsets over a ±64-float window, recording every offset whose `w*h` float
   window reproduces lib Min/Max bit-exactly. This is the multi-pass check on
   the grid-offset claim.
3. **Grid cross-check.** `parse_lib()` splits `pattern.lib` on `\r\n`, pairs
   column-0 `section.begin`/`section.end`, extracts `Name/Width/Height/
   HeightFieldMin/HeightFieldMax` with a fresh regex. Grid floats are decoded
   at `G=8+N` and compared by **float32 bit pattern**
   (`struct.pack('<f', …)`) to `float(literal)`.
4. **I02 validation.** Ran I02's own `--dry-run --check` (default dry-run ⇒
   no files written), then `validate_i02_output.py` imported I02's `decode_one`
   in-memory and independently re-validated each emitted record against fresh
   donor reads.
5. **Anomaly policy (CHARTER §4).** Every discrepancy was re-read with at
   least two instruments before any conclusion (§4.3 P1–P3, A1).
6. Only this report was written to the repo; no donor binary was run or copied;
   no Godot job, source, config, asset, test or git change.

---

## 4. Pass/fail results

### 4.1 Pass 1 — size law: **710 PASS / 0 FAIL**

| Check | Result | Count |
|---|---|---|
| `.pattern` files enumerated | PASS | 710 |
| `S == 8 + 4wh + 54(w−1)(h−1)` | PASS | **710/710** |
| Break-law files / residual bytes | — | **0 / 0** |
| Largest absolute `S − expected` | PASS | 0 B (every file) |

Representative arithmetic [D] (recomputed independently; matches F01 §4.1):

| file | w×h | wh | N | predicted | actual |
|---|---:|---:|---:|---:|---:|
| `fb_1` | 8×9 | 72 | 56 | 8+288+3024=3320 | 3320 |
| `mni_1` | 8×10 | 80 | 63 | 8+320+3402=3730 | 3730 |
| `hil1` | 25×41 | 1025 | 960 | 8+4100+51840=55948 | 55948 |
| `k_ravine_big_stone_1` | 84×100 | 8400 | 8217 | 8+33600+443718=477326 | 477326 |

### 4.2 Pass 2 — region layout: **710/710 contiguous**

General region table [O]+[D], with `N=(w−1)(h−1)`, `wh=w*h`, `S=filesize`:

| Region | Start | Length | End (inclusive) | Type |
|---|---:|---:|---:|---|
| header | 0 | 8 | 7 | `<2i` w,h |
| mask | 8 | `N` | `7+N` | `u8[N]` 0/1 only |
| height | `8+N` | `4wh` | `7+N+4wh` | `<f4[wh]` row-major h×w |
| PRE | `8+N+4wh` | 4 | `11+N+4wh` | `u8[4]` |
| records | `8+N+4wh+4` | `24N` | `11+N+4wh+24N` | `N × Rec24` |
| weights | `8+N+4wh+4+24N` | `16N−4` | `7+N+4wh+24N+16N` | `<i4[4N−1]` |
| tail | `S−13N` | `13N` | `S−1` | `N × Tail13` |

Checks: `header.end+1 == mask.start == 8`; `mask.end+1 == height.start`;
`height.end+1 == PRE.start`; `PRE.end+1 == records.start`;
`records.end+1 == weights.start`; `weights.end+1 == tail.start`;
`tail.end+1 == S`. **All hold for 710/710 files**, zero gaps, zero overlaps.
The mask is 0/1-only in **710/710** files (F01 E6 confirmed). F01's "five
regions" groups PRE+records as one block; split, they are the seven rows
above. The 54-byte-per-cell decomposition is
`1(mask)+4(grid per cell)+4(PRE per cell)+24(record)+16(weights)+13(tail)=54`
plus the global `8+4wh` header+grid term. **[D]**

### 4.3 Pass 3 — corrected grid offset `G = 8+(w−1)(h−1)` (V37): **13/13 bit-exact**

Grid decoded at the structural offset `G=8+N`; Min/Max compared by float32
bit pattern to `pattern.lib` literals (1-based line numbers):

| pattern | lib section : Min/Max line | W×H | N | G | lib Min / Max | decoded Min / Max | result |
|---|---|---:|---:|---:|---|---|---|
| `fb_1` | `pattern.lib:533097` → `:533127-533128` | 8×9 | 56 | 64 | 0 / 0 | 0 / 0 | PASS |
| `mni_1` | `pattern.lib:715147` → `:715177-715178` | 8×10 | 63 | 71 | 0 / 0 | 0 / 0 | PASS |
| `hil1` | `pattern.lib:33081` → `:33111-33112` | 25×41 | 960 | 968 | 0 / 3.86130237579346 | 0 / 3.861302375793457 | PASS |
| `k_ravine_big_stone_1` | `pattern.lib:730015` → `:730045-730046` | 84×100 | 8217 | 8225 | −2.96362733840942 / 0.173864871263504 | −2.963627338409424 / 0.17386487126350403 | PASS |
| `plt1` | `pattern.lib:321` → `:351-352` | 38×53 | 1924 | 1932 | −0.0949411764740944 / 3.49669814109802 | −0.09494117647409439 / 3.4966981410980225 | PASS |
| `plt2` | `pattern.lib:6775` → `:6805-6806` | 42×55 | 2214 | 2222 | −0.0732548981904984 / 3.61341166496277 | −0.07325489819049835 / 3.6134116649627686 | PASS |
| `k_ravine_1` | `pattern.lib:549555` → `:549585-549586` | 46×63 | 2790 | 2798 | −2.963627576828 / 3.13982009887695 | −2.963627576828003 / 3.139820098876953 | PASS |
| `hil2` | `pattern.lib:34747` → `:34777-34778` | 36×42 | 1435 | 1443 | 0 / 2.2668342590332 | 0 / 2.266834259033203 | PASS |
| `g_hil4` | `pattern.lib:366469` → `:366499-366500` | 33×59 | 1856 | 1864 | −4.321273157e−13 / 1.91698789596558 | −4.321273157e−13 / 1.9169878959655762 | PASS |
| `plt3` | `pattern.lib:13509` → `:13539-13540` | 58×63 | 3534 | 3542 | −0.0298823565244675 / 4.74128341674805 | −0.02988235652446747 / 4.741283416748047 | PASS |
| `g_mnt_1` | `pattern.lib:337461` → `:337491-337492` | 43×38 | 1554 | 1562 | 0 / 0 | 0 / 0 | PASS |
| `brush_plt_1x1` | `pattern.lib:201` → `:231-232` | 4×4 | 9 | 17 | 3.20392155647278 / 3.20392155647278 | 3.2039215564727783 / 3.2039215564727783 | PASS |
| `k_ravine_7` | `pattern.lib:583043` → `:583073-583074` | 68×73 | 4824 | 4832 | −2.96362733840942 / 2.96362495422363 | −2.963627338409424 / 2.963624954223633 | PASS |

All 13 have `dim_agree=True` (lib W/H == binary W/H). The five X05-cited
line pairs were independently re-derived: e.g. `hil1` Min line 33111 starts
at byte 854,933 and Max line 33112 at byte 854,956 — bit-identical to X05 E8.
**[O]+[D] V37 confirmed.**

**Multi-pass P1 / P2 / P3 on the offset claim (owner directive):**

- **P1 (fresh reader):** `G` derived as `8+N` from header; 13/13 bit-exact.
- **P2 (different instrument):** `N` solved from file size, giving
  `G_size = 8+N_size = 8+(w−1)(h−1)` for all 8 retested patterns; `rem=0`
  everywhere. This removes reliance on the header interpretation.
- **P3 (ambiguity probe, ±64 floats around `G`):** min/max matching is
  **not unique**. `fb_1` matches at offsets 64 and 68; `mni_1` at 71 and 75;
  `hil1` matches at dozens of shifted positions including the DPATTERN-01
  value 1000 (both `off=968` and `off=1000` give min=0/max=3.86130238);
  `k_ravine_big_stone_1`, `plt2`, `k_ravine_1` match across long negative
  windows. **Resolution:** V37 `G` is accepted because it is the *unique*
  offset satisfying structural closure (mask ends at `8+N`, height begins
  exactly there, PRE immediately after `4wh`, records after PRE), **and** it
  is bit-exact for all 13 extrema checks. Extrema alone would not prove it —
  this is exactly why DPATTERN-01 recorded 17 shifted offsets (F01 §4.4).
  **No anomaly against F01; multi-passes strengthen the claim.**

### 4.4 Anomaly A1 — F01 §5 weights-start typo (documentation only)

- *Pass 1:* `fresh_reader.py` region walker gives `fb_1` weights at
  **1700…2591** (892 B), records ending at 1699.
- *Pass 2:* F01 §4.2 table also says `1700…2591`; only F01 §5's byte-accounting
  table says **1696…2591** (and its hexdump annotates `0x6A0` as "weights
  block begins"), which is 4 B early and would give 896 B.
- *Pass 3:* raw bytes at `fb_1.pattern:0x000006A4` (=1700) are the first
  weight int32 (`00 00 00 00`); bytes `0x6A0..0x6A3` are the tail4 of the last
  `Rec24` (last record starts `356+55*24=1676`, ends at 1700). Tiling check
  passes with 1700.
- **Resolution:** F01's *formula* and §4.2 table are correct; its §5 prose row
  and hexdump annotation carry a 4-byte typo. This is a **documentation
  defect**, not a donor anomaly and not a format error. COORD should quote
  `1700` for `fb_1` weights. No F01 core claim is weakened.

---

## 5. Region tables — four requested patterns

### 5.1 `fb_1.pattern` — 3320 B, w=8, h=9, N=56, G=64

| Region | Bytes (inclusive) | Length | Boundary evidence |
|---|---:|---:|---|
| header | 0…7 | 8 | `fb_1.pattern:0x00000000` = `08 00 00 00 09 00 00 00` |
| mask | 8…63 | 56 | `fb_1.pattern:0x00000008` = `01 01 …` (0/1 only) |
| height | 64…351 | 288 | `fb_1.pattern:0x00000040` = 72 f32, all 0.0 |
| PRE | 352…355 | 4 | `fb_1.pattern:0x00000160` = `00 00 00 00` |
| records | 356…1699 | 1344 | `fb_1.pattern:0x00000164` = first id `e1`=225 |
| weights | 1700…2591 | 892 | `fb_1.pattern:0x000006A4` (223 int32, all 0) |
| tail | 2592…3319 | 728 | `fb_1.pattern:0x00000A20` = `00×10 ff ff 01` |

### 5.2 `mni_1.pattern` — 3730 B, w=8, h=10, N=63, G=71

| Region | Bytes (inclusive) | Length | Boundary evidence |
|---|---:|---:|---|
| header | 0…7 | 8 | `mni_1.pattern:0x00000000` = `08 00 00 00 0a 00 00 00` |
| mask | 8…70 | 63 | `mni_1.pattern:0x00000008` |
| height | 71…390 | 320 | `mni_1.pattern:0x00000047` |
| PRE | 391…394 | 4 | `mni_1.pattern:0x00000187` = `00 00 00 00` |
| records | 395…1906 | 1512 | `mni_1.pattern:0x0000018B` = first id `93`=147 |
| weights | 1907…2910 | 1004 | `mni_1.pattern:0x00000773` (4N−1=251 int32) |
| tail | 2911…3729 | 819 | `mni_1.pattern:0x00000B5F` = `00×10 ff ff 00` |

### 5.3 `hil1.pattern` — 55948 B, w=25, h=41, N=960, G=968

| Region | Bytes (inclusive) | Length | Boundary evidence |
|---|---:|---:|---|
| header | 0…7 | 8 | `hil1.pattern:0x00000000` = `19 00 00 00 29 00 00 00` |
| mask | 8…967 | 960 | `hil1.pattern:0x00000008` |
| height | 968…5067 | 4100 | `hil1.pattern:0x000003C8`; max 3.8613023758 = `pattern.lib:33112` |
| PRE | 5068…5071 | 4 | `hil1.pattern:0x000013CC` = `08 08 00 00` |
| records | 5072…28111 | 23040 | `hil1.pattern:0x000013D0` = first id `c6`=198 |
| weights | 28112…43467 | 15356 | `hil1.pattern:0x00006DD0` (4N−1=3839 int32) |
| tail | 43468…55947 | 12480 | `hil1.pattern:0x0000A9CC` = `00×10 ff ff 00` |

### 5.4 `k_ravine_big_stone_1.pattern` — 477326 B, w=84, h=100, N=8217, G=8225

| Region | Bytes (inclusive) | Length | Boundary evidence |
|---|---:|---:|---|
| header | 0…7 | 8 | `k_ravine_big_stone_1.pattern:0x00000000` = `54 00 00 00 64 00 00 00` |
| mask | 8…8224 | 8217 | `k_ravine_big_stone_1.pattern:0x00000008` |
| height | 8225…41824 | 33600 | `k_ravine_big_stone_1.pattern:0x002021`; min −2.9636273384 = `pattern.lib:730045` |
| PRE | 41825…41828 | 4 | `k_ravine_big_stone_1.pattern:0x00A361` = `00 00 00 00` |
| records | 41829…239036 | 197208 | `k_ravine_big_stone_1.pattern:0x00A365` = first id `79`=121 |
| weights | 239037…370504 | 131468 | `k_ravine_big_stone_1.pattern:0x03A5BD` (4N−1=32867 int32) |
| tail | 370505…477325 | 106821 | `k_ravine_big_stone_1.pattern:0x05A749` = `00×10 ff ff 00` |

All four tile `[0, S)` exactly; no residual byte. **[O]+[D]**

---

## 6. Implications for I02 and the exact byte-closure check

### 6.1 I02 self-test claims — confirmed

The landed tool `variant3d/tools/decode_donor_pattern.py` was exercised
read-only (`--dry-run --check`). It printed `PATTERN FILES: 710`,
`BYTE CLOSURE: 710/710`, and `CHECK SUMMARY: PASS 29 / FAIL 0`; all 29 named
checks passed, including `grid Min/Max bit-exact 678/680`,
`five cited grids match at corrected G 5/5`, `two decode passes byte-identical
710/710 hashes`, and `visual_parity_claim false everywhere 710 documents`.
No file was written (dry-run default). Pipeline SHA-256 reported:
`9bc45639874b9eff7c6401db4fcd459f87d2cfc870d923cfb069a1d0d1498ff7`.
This is a **structural verification of I02's self-test**, not a parity claim.

### 6.2 Independent validation of I02's *output* — 710/710 on six checks

`validate_i02_output.py` imported I02's `decode_one` in-memory (no writes) and
checked each emitted record against fresh donor reads:

| Check | Result |
|---|---:|
| `source_sha256` == sha256(re-read donor file) | 710/710 |
| `byte_closure.ok` and `actual_bytes == expected_bytes == 8+4wh+54N == S` | 710/710 |
| Seven regions tile `[0,S)` with exact expected offsets/lengths | 710/710 |
| `len(occupancy_cells)==N`, `len(relief_float_grid)==wh`, `len(object_records)==N` | 710/710 |
| `grid_offset==8+N`, `weight_offset==8+N+4wh+4+24N`, `tail_offset==S−13N`, `tail_offset+13N==S` | 710/710 |
| `collision_records is None`, `lattice_weights is None`, `visual_parity_claim is False` | 710/710 |
| **All six simultaneously** | **710/710** |

### 6.3 Exact byte-closure check COORD can reuse on I02's emitted JSON

For each output document (and the manifest), assert **all** of the following;
any failure ⇒ quarantine that output, never silently pad or "fix":

```python
import hashlib, struct
raw = open(source, 'rb').read()            # donor read-only; source from record
w, h = rec["w"], rec["h"]
S = len(raw); wh = w*h; N = (w-1)*(h-1)
assert rec["source_sha256"] == hashlib.sha256(raw).hexdigest()
assert S == 8 + 4*wh + 54*N == rec["byte_closure"]["expected_bytes"] \
         == rec["byte_closure"]["actual_bytes"]
want = [("header",0,8),
        ("mask",8,N),
        ("height",8+N,4*wh),
        ("pre",8+N+4*wh,4),
        ("records",8+N+4*wh+4,24*N),
        ("weights",8+N+4*wh+4+24*N,16*N-4),
        ("tail",S-13*N,13*N)]
assert [(r["name"],r["offset"],r["length"])
        for r in rec["byte_closure"]["regions"]] == want   # exact, not just "contiguous"
cursor = 0
for _, off, L in want:
    assert off == cursor and L >= 0
    cursor += L
assert cursor == S                                           # zero residual
assert rec["grid_offset"] == 8+N
assert rec["weight_offset"] == 8+N+4*wh+4+24*N
assert rec["tail_offset"] == S-13*N and rec["tail_offset"]+13*N == S
assert len(rec["occupancy_cells"]) == N
assert len(rec["relief_float_grid"]) == wh
assert (rec["object_records"] is None or len(rec["object_records"]) == N)
assert rec["collision_records"] is None and rec["lattice_weights"] is None
assert rec["visual_parity_claim"] is False
# manifest: assert determinism_second_pass_equal is True; recompute
# pipeline_sha256 from name+'\\0'+sha256(canonical JSON) over the sorted list.
```

This check is independent of F01/I02 code and passed 710/710 in scratch.
Note the strict `regions == want` equality catches the F01 §5 typo class
(an off-by-4 weights start) that a mere contiguity test would miss.

### 6.4 Port consequences (all **PORT APPROXIMATION**)

- The corrected offset `G=8+(w−1)(h−1)` and full `w*h` grid are the only
  donor-grounded relief source; any tool transcribing 8×10 means must use
  this `G`, never an extrema scan (§4.3 P3).
- I02 correctly emits `null` + UNVERIFIED for the two semantically unknown
  regions; COORD must not wire those to gameplay until D07/D06/D01 evidence.
- `m_swamp_12_old` remains the single dimension-stale section; I02
  quarantines it (29/29 self-test confirms). Keep the binary header as the
  authoritative geometry source.
- No donor visual parity can be asserted: these are byte/structure checks
  only. **No parity claim.**

---

## 7. UNVERIFIED register

| ID | Field / claim | Why UNVERIFIABLE here |
|---|---|---|
| U-X34-1 | `Rec24.id` (int32, observed 0…255) meaning | No plaintext consumer or RTTI field mapping in the `.pattern` bytes; distribution alone cannot distinguish model index / tile index / colour byte / seed. |
| U-X34-2 | `Rec24.tail4[4]` and PRE (4 B) meaning | Only byte distributions observed; no loader struct tying them to semantics. PRE plausibly a default but **[I]** only. |
| U-X34-3 | `Rec24.f[4]` four `1.0f` values' meaning | Constant in 550,908 records; no donor string/field name; likely scale defaults **[I]** only. |
| U-X34-4 | `int32[4N−1]` weight block (values 0/99/100/101/200 + ~2.8e7 exceptions) meaning | Per-corner-weight reading is **[I]**; correlation with negative heights is a hint, not proof; no consumer. Framing beyond `4N−1` int32 unproven. |
| U-X34-5 | `Tail13.i16` (−1/255) and `flag` (0/1) meaning | Collision/stand reading is **[I]**; no engine code tying them to `CollisionStand`. |
| U-X34-6 | Mask (`u8[N]` 0/1) occupancy semantics | 0/1 confirmed but what "occupied" triggers is not in the bytes. |
| U-X34-7 | Engine blend order / `HeightFieldScale` sign / clamp / `HeightFieldMin` pivot | No plaintext consumer; D05/X12 opcode claims are static observations, not this verification; no A/B frame. |
| U-X34-8 | File-row → map-row sign (`row_flip`) | Extrema are invariant to row order; only structure was checked. |
| U-X34-9 | Runtime selection among `pattern.lib` `Objects` vs per-cell records | Engine-side; out of scope for byte verification. |
| U-X34-10 | Donor visual parity | No donor GPU A/B frame exists (CHARTER §3). |

---

## 8. Open questions

1. Should COORD patch F01 §5's weights-start row (`1696` → `1700`) and the
   `0x6A0` hexdump annotation? (X34 does not edit F01.)
2. Will D01's RTTI lift identify the loader struct and confirm field names for
   `Rec24`/weights/`Tail13`, upgrading any U-X34 item to **[O]**?
3. Is the DPATTERN-01 shifted-offset corpus worth re-exporting from `G=8+N`,
   given §4.3 P3 shows min/max alone cannot detect the shift?
4. Should I02's `--check` be extended with the strict `regions == want`
   equality from §6.3 instead of its current contiguity-only
   `byte_closure()`? (Contiguity alone would have accepted a shifted weights
   start.)
5. Does the `m_swamp_12_old` stale header indicate a second `.pattern` version
   that needs a version discriminator in the decoder?

---

## 9. Five-line summary

1. **Size law confirmed:** `filesize = 8 + 4*w*h + 54*(w-1)*(h-1)` holds **710/710** donor files, 0 failures, 0 residual bytes (two independent instruments).
2. **Layout confirmed:** seven contiguous regions tile `[0, S)` 710/710; exact boundaries given for `fb_1`, `mni_1`, `hil1`, `k_ravine_big_stone_1` with donor offsets.
3. **V37 confirmed:** `G = 8+(w-1)*(h-1)` is bit-exact against `pattern.lib` Min/Max for **13/13** patterns; proven structurally (min/max alone is ambiguous).
4. **I02 confirmed:** self-test `PASS 29/FAIL 0` on read-only `--dry-run --check`; independent output validation 710/710 on six checks; strict byte-closure check supplied in §6.3.
5. **Still UNVERIFIED:** record id/tail4, weights and `Tail13` semantics, blend/row flip — no plaintext consumer; all port readings PORT APPROXIMATION, **no parity claim**.

*End of X34. One repo file written (this report). No donor binary executed or copied; no repo source, config, asset, test, Godot job or git change. No donor visual parity claimed.*
