---
id: X05
title: "Independent validation of F02 `pattern.lib` decoder claims — 680/680 schema, 5/5 line offsets, 12/12 grid checks, 1 donor header anomaly"
agent: "worker X05 (DONOR-FIRST terrain swarm, 2026-11-26; validator of F02 → I03)"
date: 2026-11-26
status: REPORT LANDED
labels: [O, D, I, U, "PORT APPROXIMATION"]
donor: "C:\\Games\\Cossacks 3 (READ ONLY; raw bytes + latin-1; no donor binary executed/copied)"
scope: "Re-derive F02's pattern.lib claims from scratch: record split, 37-field prologue, name↔file join, five line→byte citations, 12 float-grid cross-checks, HeightField* flag census; emit machine-readable index"
verdict: "CORE_CLAIMS_CONFIRMED__680_680__5_5_FIELD_BYTES__12_12_GRID_BIT_EXACT__F02_5_2_BYTE_SPAN_COLUMN_WRONG_4_5__ONE_DONOR_HEADER_ANOMALY__NO_PARITY_CLAIM"
---

# X05 — validation of F02's `pattern.lib` decoder (for I03 port)

## Executive summary

1. **[O] Core F02 claims confirmed.** `C:\Games\Cossacks 3\data\pattern\pattern.lib`
   is plaintext with CRLF line endings: 30,309,138 bytes, 1,172,417 split lines,
   1,172,416 CRLF pairs and **zero** bare LF/CR. It splits at column-0
   `section.begin`/`section.end` into **680 records**, and **680/680** carry the
   identical 37-key prologue in the identical order. **0 records break the schema.**
   (`pattern.lib:1`, `:321-6773`, `:1171115-1172415`; full-file scan).
2. **[O] Name→file join is 680/680**, zero misses; 710 `.pattern` files exist, so
   30 are orphans. One match is case-only (`k_ravine_2` → `K_ravine_2.pattern`,
   `pattern.lib:555365`). Binary W/H headers agree for 679/680; the sole
   exception is `m_swamp_12_old` (`pattern.lib:905523`, `m_swamp_12_old.pattern:0-7`).
3. **[D] All five "known offsets" are 1-based LINE numbers — confirmed 5/5.**
   For each cited pair the line content is exactly `HeightFieldMin` /
   `HeightFieldMax`, and every derived byte start is bit-identical to F02's table
   (`pattern.lib:6805-6806`, `:33111-33112`, `:366499-366500`,
   `:549585-549586`, `:730045-730046`). **However** F02 §5.2's adjacent
   "byte span of section" column is wrong for 4/5 rows: those values are copied
   from the §5.4 *family* byte ranges, not the section spans (§Anomaly A2).
4. **[O] Twelve grid cross-checks pass 12/12 bit-exactly.** Decoding `w*h`
   float32 values at the F02-quoted `G` offsets in the corresponding `.pattern`
   files reproduces both `HeightFieldMin` and `HeightFieldMax` bit-for-bit, and
   matches F02's own decoded doubles bit-for-bit (§Validation V4).
5. **[O] HeightField* census complete.** 14 distinct `HeightField*` keys. Of the
   seven named flags: `Stand` True 582/False 98; `Scale` non-1 in 11/680;
   `Min`/`Max` present 680/680; `Replace` False 680/680 (zero True);
   `ReplaceForWater` True 85; `Smooth` True 41. Full value→owner lists emitted
   to temp JSON. One minor F02 enumeration omission found: `HeightFieldScale`
   non-unity value `0.649999976158142` (`hil1`) is missing from F02 §5.5 (§A3).
6. **[D] No donor-parity claim.** These are structural/byte validations only;
   engine-side consumption of the fields remains UNVERIFIED.

---

## Evidence table

| # | Donor path : line / byte | Observation / label | Used for |
|---|---|---|---|
| E1 | `pattern.lib:1` byte 0 | [O] `section.begin\r\n`, no binary magic | container type |
| E2 | `pattern.lib:1..1172417` (full scan) | [O] 1,172,417 lines, 1,172,416 CRLF, 0 bare LF/CR | line table |
| E3 | `pattern.lib` col-0 scan | [O] 680 `section.begin`, 680 `section.end`; 679 gaps of exactly 2 B | record count / boundaries |
| E4 | `pattern.lib:322-358`, all 680 prologues | [O] identical ordered 37 keys in 680/680 | schema |
| E5 | `pattern.lib:555365` | [O] `k_ravine_2` → `K_ravine_2.pattern` (only case-only join) | name↔file |
| E6 | `pattern.lib:905523` +2/+3; `m_swamp_12_old.pattern:0-7` | [O] lib 17×20 vs binary 18×23 | donor anomaly |
| E7 | `pattern.lib:6805-6806` bytes 173,669/173,710 | [O/D] `plt2` min/max; line pair → exact byte starts | V3 |
| E8 | `pattern.lib:33111-33112` bytes 854,933/854,956 | [O/D] `hil1` min/max | V3 |
| E9 | `pattern.lib:366499-366500` bytes 9,458,861/9,458,904 | [O/D] `g_hil4` min/max | V3 |
| E10 | `pattern.lib:549585-549586` bytes 14,196,248/14,196,285 | [O/D] `k_ravine_1` min/max | V3 |
| E11 | `pattern.lib:730045-730046` bytes 18,877,479/18,877,518 | [O/D] `k_ravine_big_stone_1` min/max | V3 |
| E12 | `*.pattern` float plane at F02 `G` offsets (12 files) | [O] min/max bit-exact vs lib literals | V4 |
| E13 | `pattern.lib` 3-space + 9-space `BaseName =` scan | [O] 39,783 `BaseName` lines = 39,780 at 9 spaces + 3 at 6 spaces | F02 cross-check |
| E14 | `pattern.lib` tail bytes 30,309,134..30,309,138 | [O] `...section.end\r\n\r\n`; 2 trailing bytes after the final line | byte closure |

Prior art read (not new donor evidence): `reports/F02_pattern_lib.md` (target of
this validation). F01 was not consulted; validation is deliberately independent.

---

## Method

1. **Prototype (temp only).** `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\patternlib_validate\validate_patternlib.py`
   reads the donor with `open(...,'rb')`, splits on `b'\r\n'` and builds a prefix
   byte-offset table `off[i] = byte start of 1-based line i+1`. Companion scripts
   `investigate.py`, `supplemental.py`, `hf_owners.py` re-read the same bytes with
   *different instruments* (`raw.find` walking instead of the prefix table;
   indentation histograms) for multi-pass checks.
2. **Records** = lines whose exact bytes are `b'section.begin'` / `b'section.end'`
   at column 0, paired in file order. Prologue = lines `section.begin+1 … +37`,
   keys matched by `^   ([A-Za-z_]\w*) = (.*)$`.
3. **Name→file** = case-insensitive stem join against `data\pattern\*.pattern`;
   W/H read with `struct.unpack('<ii', b[:8])`.
4. **Line→byte** = `off[L-1]` for a 1-based line `L`; compared to F02 §5.2.
5. **Grid** = `struct.unpack_from('<%df' % (w*h), b, G)`; min/max compared by
   float32 *bit pattern* (`struct.pack('<f',…)`) to both `float32(literal)` and
   F02's reported decoded doubles.
6. **Outputs in temp only:** `patternlib_index.json` (995,941 B, all 680 records
   with fields), `validation_summary.json`, `hf_owners.json` (196,555 B), plus
   the scripts and captured console logs. **No repo file other than this report
   was written; no donor binary executed or copied.**

---

## Validation results (exact pass/fail counts)

### V1 — split and prologue schema — PASS

| Check | Result | Count |
|---|---|---|
| `section.begin` at col 0 | PASS | 680 |
| `section.end` at col 0 | PASS | 680 |
| Records emitted (begin/end paired) | PASS | **680/680** |
| Prologue = 37 fields, exact key order | PASS | **680/680** |
| Records breaking schema | — | **0** |
| Inter-record gaps (all 2 B) | PASS | 679 × 2 B |
| Byte closure: 30,307,778 + 1,358 + 2 trailing | PASS | 30,309,138 = file size |

`NativeSeason = Summer`, `Summer/Autumn/Winter/Spring = True`,
`HeightFieldMin = +30`, `HeightFieldMax = +31` relative to `section.begin`
confirmed across all 680 (implied by the 37-key order check).

### V2 — name↔file join — PASS (with one known donor anomaly)

| Check | Result | Count |
|---|---|---|
| Section names matched to `.pattern` | PASS | **680/680** |
| Misses | — | **0** |
| Case-insensitive-only matches | — | 1 (`k_ravine_2` → `K_ravine_2.pattern`) |
| `.pattern` files present | — | 710 |
| Orphan files (no section) | — | 30 |
| Binary W/H header equality | PASS-with-exception | **679/680** |
| Header mismatch | — | 1: `m_swamp_12_old` (lib 17×20, binary 18×23) |
| `BaseName` lines at 9-space object indent | PASS | 39,780 (F02's figure) |
| `BaseName` lines at 6-space indent | extra | 3 (total 39,783) |

### V3 — five cited line pairs → byte offsets — CORE PASS 5/5, table-column FAIL 4/5

| Citation | Section | Field lines correct | Derived byte starts = F02 | F02 §5.2 "byte span of section" |
|---|---|---|---|---|
| `:6805-6806` | `plt2` (`pattern.lib:6775`) | PASS | PASS 173,669 / 173,710 | PASS 172,901..344,605 |
| `:33111-33112` | `hil1` (`pattern.lib:33081`) | PASS | PASS 854,933 / 854,956 | **FAIL** (see A2) |
| `:366499-366500` | `g_hil4` (`pattern.lib:366469`) | PASS | PASS 9,458,861 / 9,458,904 | **FAIL** |
| `:549585-549586` | `k_ravine_1` (`pattern.lib:549555`) | PASS | PASS 14,196,248 / 14,196,285 | **FAIL** |
| `:730045-730046` | `k_ravine_big_stone_1` (`pattern.lib:730015`) | PASS | PASS 18,877,479 / 18,877,518 | **FAIL** |

**5/5** cited pairs land on `HeightFieldMin`/`HeightFieldMax` and produce the
exact byte starts F02 reports. The claim "prior offsets are 1-based line numbers"
is therefore **fully confirmed**. The separate illustrative byte-span column is
wrong in 4 rows (A2).

### V4 — 12 grid cross-checks — PASS 12/12

| Pattern | lib W×H | binary W×H | `G` | decoded min vs float32 literal | decoded max vs float32 literal | F02 doubles bit-equal | Result |
|---|---|---|---:|---|---|---|---|
| `plt1` | 38×53 | 38×53 | 1,972 | bit-equal | bit-equal | yes | PASS |
| `plt2` | 42×55 | 42×55 | 2,266 | bit-equal | bit-equal | yes | PASS |
| `hil1` | 25×41 | 25×41 | 1,000 | bit-equal | bit-equal | yes | PASS |
| `g_hil4` | 33×59 | 33×59 | 1,912 | bit-equal | bit-equal | yes | PASS |
| `k_ravine_1` | 46×63 | 46×63 | 2,866 | bit-equal | bit-equal | yes | PASS |
| `k_ravine_7` | 68×73 | 68×73 | 4,832 | bit-equal | bit-equal | yes | PASS |
| `k_ravine_big_stone_1` | 84×100 | 84×100 | 8,225 | bit-equal | bit-equal | yes | PASS |
| `f_plt_big_1` | 81×93 | 81×93 | 7,536 | bit-equal | bit-equal | yes | PASS |
| `d_plt1` | 51×63 | 51×63 | 3,124 | bit-equal | bit-equal | yes | PASS |
| `g_mnt_1` | 43×38 | 43×38 | 1,562 | 0.0 = 0.0 | 0.0 = 0.0 | yes | PASS |
| `i_mnt_big_1` | 51×55 | 51×55 | 2,708 | bit-equal | bit-equal | yes | PASS |
| `brush_plt_1x1` | 4×4 | 4×4 | 17 | bit-equal | bit-equal | yes | PASS |

Example: `plt1` decoded min `-0.09494117647409439` equals
`float32(-0.0949411764740944)` bit-for-bit; max `3.4966981410980225` equals
`float32(3.49669814109802)`. F02's "many offsets give the same min/max"
boundary caveat was **not** re-derived (the `G` values were taken from F02);
see UNVERIFIED U-X05-2.

### V5 — `HeightField*` flag census — PASS

14 distinct keys found. Seven named flags (counts over 680 records):

| Flag | Value distribution | Owning records (examples / full list location) |
|---|---|---|
| `HeightFieldStand` | True **582**, False **98** | True: `brush_plt_*`, `plt1/2/3/5`, `hil1-4`, `dcr1-3`, `str_*`, `frt_*` … |
| `HeightFieldScale` | `1` **669**; `-0.925` **4**; `+0.925` **3**; `1.175`, `0.8`, `1.5`, `0.65` **1 each** | non-1: `brush_plt_15x15_2`, `brush_plt_13x13_2`, `brush_plt_7x7_2`, `brush_plt_1x1` (−); `brush_plt_11x11_2`, `brush_plt_3x3_2`, `brush_plt_1x1_half` (+); `brush_plt_1x1_mid` (1.175); `plt3` (0.8); `plt5` (1.5); `hil1` (0.65) |
| `HeightFieldMin` | 680 values; `0` **522**, non-zero **158** | e.g. `plt1` = −0.0949411764740944; `hil1` = 0 |
| `HeightFieldMax` | 680 values; `0` **512**, non-zero **168** | e.g. `plt1` = 3.49669814109802; `hil1` = 3.86130237579346 |
| `HeightFieldReplace` | False **680**, True **0** | none (flag is universally off) |
| `HeightFieldReplaceForWater` | False **595**, True **85** | True: `brush_plt_*`, `plt1/2/3/5`, `hil1-4`, `mng4/mnc4/mni4`, `g_mnt_1-7`, `g_hil1-9`, `i_mnt_big_1-5` … |
| `HeightFieldSmooth` | False **639**, True **41** | True: `brush_plt_*`, `d_plt1`, `g_mnt_1-7`, `g_hil1-9`, `i_mnt_big_*`, `k_ravine_big_1`, `k_ravine_big_stone_1-8`, `gift1-4` |

Other seven `HeightField*` keys: `MinScale = 1` (680), `MaxScale = 1` (680),
`Offset = 0` (680), `UseRndScale = False` (680), `SmoothFactor = 4` (680),
`SmoothRadius` {2:427, 3:248, 1:5}, `SmoothOffset` {0:435, 2:240, 1:5}.
**Complete value→owner lists for all 14 keys are in temp `hf_owners.json`.**

### V6 — machine-readable index — PASS

`patternlib_index.json` holds 680 record objects with `name`, `line_start`,
`line_end`, `byte_start`, `byte_end`, `size`, `prologue_ok`, `n_prologue`,
`pattern_file`, `pattern_w`, `pattern_h`, `header_ok`, and all field literals.

---

## Anomalies and multi-pass notes

Owner directive (CHARTER §4) requires several instruments before calling an
anomaly. Every item below was re-read with at least two methods.

**A1 — byte closure off by 2 in my first check (prototype bug, F02 correct).**
- *Pass 1:* prefix-sum records + 679 gaps gave 30,309,136, not 30,309,138.
- *Pass 2:* `raw.find` walk of `section.begin`/`section.end` tokens placed the
  final `section.end` text at byte 30,309,123, its CRLF ending at 30,309,136.
- *Pass 3:* raw tail bytes `0d0a0d0a` = `...section.end\r\n\r\n`; one extra blank
  CRLF line (line 1,172,416 at byte 30,309,136).
- **Resolution:** my check omitted the 2 trailing bytes. F02's arithmetic
  (30,307,778 + 1,358 + 2 = 30,309,138) is correct. No donor anomaly.

**A2 — F02 §5.2 "byte span of section" is wrong for 4/5 sections (documentation
error in F02, not in donor bytes).**
- *Pass 1:* computed section span from the same prefix table used for field
  bytes; field bytes matched F02 exactly, but four section `byte_end` values did
  not. `plt2` matched.
- *Pass 2:* independent `raw.find` scan confirmed my section ends: `hil1`
  895,878; `g_hil4` 9,534,168; `k_ravine_1` 14,346,835;
  `k_ravine_big_stone_1` 19,157,731.
- *Pass 3:* compared each F02 §5.2 value to F02 §5.4 family table: F02's
  `hil1` end 1,008,612 = `hills_dark` family end; `g_hil4` 9,881,235 =
  `hills_light` end; `k_ravine_1` 15,714,652 = `ravine_medium` end;
  `k_ravine_big_stone_1` 20,907,169 = `ravine_big` end. `plt2`'s 344,605 is a
  genuine section end.
- **Resolution:** F02's §5.2 column mixed section ends with family ends for four
  rows. The *field byte starts* — the load-bearing claim — are all correct.
  **I03 must derive section boundaries from `section.begin`/`section.end`, never
  from the §5.2 byte-span column.**

**A3 — `HeightFieldScale` distribution in F02 §5.5 omits one value.**
- *Pass 1:* main prototype counted 11 non-`1` values (4+3+1+1+1+1).
- *Pass 2:* independent regex scan over every section listed the six distinct
  values and owners; F02 §5.5 enumerates only five (−0.925, +0.925, 1.175, 0.8,
  1.5 = 10 sections), summing to 679 with 669 ones.
- *Pass 3:* the missing section is `hil1` = `0.649999976158142`
  (`pattern.lib:33081`, prologue `HeightFieldScale`).
- **Resolution:** minor enumeration omission in F02; the "1 in 669/680" count is
  correct. Add `0.65` to any F02-derived constant table.

**A4 — `m_swamp_12_old` header mismatch (genuine donor inconsistency).**
- *Pass 1:* case-insensitive name join succeeded; W/H check failed
  (lib 17×20 at `pattern.lib:905523` +2/+3; index lines 905,525/905,526).
- *Pass 2:* re-read the prologue with a second regex instrument — `Width = 17`,
  `Height = 20` confirmed in the lib.
- *Pass 3:* opened `m_swamp_12_old.pattern` directly — bytes 0..7 decode to
  18×23; file is 21,860 B.
- **Resolution:** **[O] donor anomaly**, not a decoder defect. F02 documented it
  identically. I03 needs an explicit policy (trust the `.pattern` header, or
  flag and skip); a strict lib-header equality check will abort on this record.

**A5 — case-only name variant (resolved, not an anomaly).** Independent
indentation-aware scan found exactly one: section `k_ravine_2`
(`pattern.lib:555365`) ↔ `K_ravine_2.pattern`. Consistent with F02; case-insensitive
join is required.

**A6 — 39,783 vs F02's 39,780 `BaseName` lines (resolved).** Indentation
histogram: 39,780 at 9 spaces (the `[*]` object records F02 counted) and 3 at
6 spaces. F02's figure is correct for its stated scope.

---

## Implications for I03 (decoder port into `variant3d/tools/`)

1. **[PORT APPROXIMATION] The decoder design in F02 §5.6 is sound.** The
   validated prototype reproduces all six F02 outputs; port the line-oriented
   parser (raw bytes → CRLF split → prefix byte table → column-0 record split →
   regex prologue → nested struct scan) essentially unchanged.
2. **[PORT APPROXIMATION] Emit exact `Name`-keyed records with `line_start/end`
   and `byte_start/end` derived from `section.begin`/`section.end`.** Do **not**
   ingest F02 §5.2's byte spans (A2). Preserve the 37 prologue keys verbatim;
   schema check must assert the ordered key tuple for every record (680/680 in
   this build), and should fail loudly if a donor update changes it.
3. **[PORT APPROXIMATION] Treat `pattern.lib:N` citations strictly as 1-based
   line numbers.** Optionally attach `byte B = off[N-1]`. Rewrite the five corpus
   citations accordingly; relying on them as byte offsets reads unrelated text.
4. **[D] Header validation policy must be explicit:** 679/680 pass; quarantine
   `m_swamp_12_old` rather than aborting (A4). Keep the `.pattern` binary W/H as
   the authoritative geometry source.
5. **[PORT APPROXIMATION] HeightField* metadata can be copied verbatim** — the
   12 bit-exact grid checks justify treating `Min`/`Max`/`Scale` literals as
   float32. Include the `0.65` value (A3). `Replace` is always False and
   `ReplaceForWater` is True on exactly 85 records; preserve those flags because
   they are the only plaintext signal for water-height substitution.
6. **[PORT APPROXIMATION] Family membership still comes from `generator.cfg`,
   not the lib** (F02 §5.3/§5.4). This validation did not re-derive the 64-family
   join; I03 should keep F02's exact-name-first strategy and mark the
   normaliser path PORT APPROXIMATION.
7. **[D] The temp `patternlib_index.json` / `hf_owners.json` are suitable
   fixtures** for an I03 unit test (`assert record_count==680`,
   `assert prologue_ok==680`, `assert header_ok==679`, `assert 5 field bytes`,
   `assert 12 grid checks`). They are derived data only — no donor bytes copied.

---

## Risks

* **R1 [O]** F02 §5.2's byte-span column is unreliable (4/5 rows); a tool that
  uses it to slice sections will read into adjacent families (A2).
* **R2 [O]** One donor record (`m_swamp_12_old`) defeats strict lib↔binary header
  equality (A4).
* **R3 [O]** 30 `.pattern` files have no section; enumerating files instead of
  sections generates unreferenced patterns.
* **R4 [O]** One case-insensitive-only name; a case-sensitive join loses
  `k_ravine_2` (A5).
* **R5 [U]** The float-grid start offset `G` was accepted from F02, not
  independently located; exact plane start and row order remain unproven.
* **R6 [U]** Engine-side application of `HeightField*` flags is outside this
  validation; no donor A/B frame exists.
* **R7 [I]** Any DLC/patch that reorders sections would invalidate cached byte
  offsets; line-based citations are similarly build-specific.

---

## UNVERIFIED register

| ID | Claim | Status | Why not verified |
|---|---|---|---|
| U-X05-1 | Engine consumption of the 14 `HeightField*` keys | UNVERIFIED | Structural validation only; no native consumer read. |
| U-X05-2 | Exact float-plane start byte (the `G` values) and row flip | UNVERIFIED | `G` taken from F02; min/max alone admit many offsets (F02 caveat not re-derived). |
| U-X05-3 | 64-family `generator.cfg` join / `Freq` semantics | UNVERIFIED | Out of scope for this validation pass; F02 §5.3/§5.4 not re-derived. |
| U-X05-4 | Meaning of the 3 six-space `BaseName` lines | UNVERIFIED | Observed, not classified (likely nested non-`[*]` records). |
| U-X05-5 | Cause of `m_swamp_12_old` 17×20 vs 18×23 | UNVERIFIED | Consistent with a stale/legacy section; no proof. |
| U-X05-6 | 205,571 `struct.begin`/`struct.end` pair count | OBSERVED-not-in-scope | Re-counted as 205,571/205,571 by a third instrument, but full nesting semantics not audited. |
| U-X05-7 | Donor visual parity of decoded relief | UNVERIFIED | No donor GPU A/B frame; no parity claim made. |

---

## Open questions

1. Should I03 emit the §5.2 byte-span correction as a patch to F02's report, or
   wait for COORD to integrate both reports (worker X05 does not edit F02)?
2. Why does F02 §5.2 use family ends for four sections — manual copy from §5.4,
   or a different (family-based) definition that was mislabeled?
3. Should `m_swamp_12_old` be skipped, repaired from its binary header, or kept
   with a warning in the derived index?
4. Is the lone `0.65` `HeightFieldScale` (`hil1`) intentional relief tuning or a
   typo in the donor data?
5. Do the 3 six-space `BaseName` lines belong to `Waters`/`Decals` blocks and
   should the converter import them as objects?

---

*No donor binary was executed or copied into the repository; no repo source,
asset, config, git or Godot job was touched by this worker. All port readings
are PORT APPROXIMATION; no donor visual parity is claimed.*
