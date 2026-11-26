---
id: X49
ticket: "TERRAIN-SWARM-2026-11-26 / X49 (verification subagent, worker X49, reporting to COORD)"
title: "X49 — read-only audit of I02's decode_donor_pattern.py against X23's canonical relief-grid tables"
agent: "worker X49 (verification subagent)"
date: 2026-11-26
status: DELIVERED__ONE_REPORT_ONLY__DONOR_READ_ONLY__NO_REPO_SOURCE_NO_GIT_NO_GODOT
scope: "Exactly one repo file written: this report. Donor at C:\\Games\\Cossacks 3 opened 'rb' only; no donor binary executed or copied. No source/asset/config/test/shader/queue/git edit; no Godot job. Two throwaway verification scripts were written ONLY to C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\ (outside the repo)."
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_claim: false
parity_guard: "No donor GPU A/B frame exists (CHARTER §3/§5). Grid values here are derived numeric data; a port that stamps from them is PORT APPROXIMATION. No donor parity claim is made anywhere in this report."
sources_read:
  - docs/terrain_swarm_2026-11-26/CHARTER.md
  - docs/terrain_swarm_2026-11-26/SWARM_BOARD.md
  - docs/terrain_swarm_2026-11-26/reports/F01_pattern_format.md
  - docs/terrain_swarm_2026-11-26/reports/X23_corrected_relief_grids.md
  - docs/terrain_swarm_2026-11-26/reports/X26_blend_formula_verification.md
  - variant3d/tools/decode_donor_pattern.py (I02)
file_hashes:
  decode_donor_pattern.py: 00c0591aae0aef23d661a8aa9aae33fa807b3ea9b5c97d857520fa0d407e6619
  x49_grid_compare.py (temp only): 7445dc240fd0aa746b80dd458b7f6efbcbe2494882e5cee3a03ad82317ff4485
  x49_semantics_check.py (temp only): 1d1c924d2e411f289a1190dea286cdff64d6cc67c4e68c2d0f64a41582691ea1
verdict: "5_OF_5_AUDIT_ITEMS_PASS_FOR_I02__TASK_BRIEF_HAS_2222_8225_LABEL_SWAP__I03_CONCURRENT_EDIT_OBSERVED__NO_PARITY_CLAIM"
---

# X49 — I02 grid audit against X23 canonical tables

## 0. Mandate and label key

Verify I02's `.pattern` decoder against X23's canonical corrected relief grids on
five points: (1) byte-closure formula and region boundaries, (2) grid offsets,
(3) emitted grid values vs X23 tables, (4) `m_swamp_12_old` quarantine and
null+UNVERIFIED semantics, (5) output ownership vs I03. Every anomaly got
multiple passes before a verdict (§2–§7); no defect was declared on a single
reading. Donor bytes were read with Python `bytes`/`struct`/`numpy` only.

Labels: **[O]** observed literal code/byte/line, **[D]** derived arithmetic or
control-flow consequence, **[I]** inference, **[U]** UNVERIFIED. Port use is
**PORT APPROXIMATION**. **No donor parity claim.**

---

## 1. Verdict table

| # | Audit item | Verdict | Authority (file:line) |
|---|---|---|---|
| 1 | `filesize=8+4wh+54(w−1)(h−1)` byte closure + region boundaries | **PASS** | `decode_donor_pattern.py:283-310,390-410`; runtime 710/710 |
| 2 | Grid offsets 968 / 1864 / 2798 / 2222 / 8225; never stale 1000/1912/2866 | **PASS** (code); **brief label swap flagged** (non-code) | `:127-147,283-292,413`; X23 §4.2/§4.4/§4.5 |
| 3 | `--dry-run --check` grid-value comparison vs X23 | **PASS** (conditional not triggered — tool prints no grid values; independent in-process comparison 17/17 cells) | `:952-980,905-907`; §4 below |
| 4 | `m_swamp_12_old` quarantined UNVERIFIED; record/weight/tail null+UNVERIFIED; no donor bytes copied | **PASS** | `:335-365,453-514,516-521,944-948,864-871` |
| 5 | No output ownership collision with I03 | **PASS** (disjoint filenames); shared directory + stale family artifacts flagged as COORD observation | `:87,905,983-988`; `decode_pattern_lib.py:1059-1060` |

**No code fix is required for I02 on any of the five items.** Two non-I02
issues are flagged for COORD in §3/§7.

---

## 2. Item 1 — byte closure and region boundaries: **PASS**

**[O]+[D] Code.** `region_table()` (`decode_donor_pattern.py:283-301`) derives
`n=(w−1)(h−1)`, `wh=w*h`, `g0=8+n`, `p0=g0+4*wh`, `r0=p0+4`, `w0=r0+24*n`,
`t0=size−13*n` and emits seven contiguous regions
`header(8) | mask(n) | height(4wh) | pre(4) | records(24n) | weights(16n−4) | tail(13n)`.
`byte_closure()` (`:304-310`) walks with a cursor, rejecting any region whose
offset ≠ cursor or whose length < 0, and requires the final cursor to equal
`size`. The sum is `8+n+4wh+4+24n+(16n−4)+13n = 8+4wh+54n`. `decode_one()`
(`:390-410`) additionally checks `len(raw) == 8+4*wh+54*n` and returns early
with `status/label = UNVERIFIED` if closure fails — no fields are emitted from
a broken file. **[O]** The docstring formula at `:16` and the emitted
`byte_closure.formula` at `:400` match F01 §4.1 `:123-144`.

**Passes.** P1 static read of the region walker; P2 algebraic sum of the seven
lengths; P3 runtime read-only run `python variant3d\tools\decode_donor_pattern.py
--dry-run --check` → `BYTE CLOSURE: 710/710`, check
`F01 size law / byte closure 710/710 PASS`. P4 explicit printed closure audits:
`fb_1` 3320 B = 3320 predicted, 7 regions (mask 8/56, height 64/288, pre
352/4, records 356/1344, weights 1700/892, tail 2592/728) — identical to F01
§5; `k_ravine_big_stone_1` 477326 B = 477326 predicted, height offset 8225,
weights offset 239037 length 131468 (=16·8217−4), tail offset 370505 length
106821 (=13·8217). All match F01 §4.2. **Fix: none.**

---

## 3. Item 2 — grid offsets: **PASS for I02 code; the assignment text has a label swap**

**(a) Code is correct.** `CITED_PAIRS` (`decode_donor_pattern.py:127-144`)
records `plt2=2222`, `hil1=968`, `g_hil4=1864`, `k_ravine_1=2798`,
`k_ravine_big_stone_1=8225`, each annotated as the F01-corrected
`G=8+(w−1)(h−1)`. `:145-147` explicitly says the F02/DPATTERN starts
`1000/1912/2866` are stale by +8/+12/+17 floats and are never used. More
importantly, the decoder does **not** take any offset from that table for the
actual decode: `region_table():287` computes `g0 = 8 + n` from the file header
for every one of the 710 files, and `:413` decodes the grid at
`regions[2]["offset"]`. The five hard-coded numbers exist only for the
metadata cross-check at `:788-793`. No min/max scanning exists anywhere in the
tool (docstring `:32-33`).

**(b) The task brief mislabels two patterns.** The assignment reads
`G=... 2222 (k_ravine_big_stone_1), 8225 (plt2)`, but the canonical tables say
the opposite. Five independent passes were run before flagging this:

| Pass | Instrument | Result |
|---|---|---|
| A | Assignment text (X49 ticket) | `2222 (k_ravine_big_stone_1)`, `8225 (plt2)` |
| B | X23 §4.2 `:158-162` / §4.5 `:218-223` | `plt2 G=2222`; `k_ravine_big_stone_1 G=8225` |
| C | X23 §6 S1 `:293-297` and F01 §4.4 `:207-225`, §4.10 `:349,385` | same pairing; DPATTERN `plt2` old G=2266, `k_ravine_big_stone_1` old G=8225 |
| D | I02 code `:128,140-143` | `plt2 2222`, `k_ravine_big_stone_1 8225` |
| E | Runtime in-process decode (§4 below) | `plt2 G=2222`, `k_ravine_big_stone_1 G=8225`, both grids reproduce X23 tables |

**Verdict.** I02 is **PASS**; the **assignment brief is FAIL** on these two
parenthetical labels only. **Fix (COORD, not I02):** correct the X49 task text
to `2222 (plt2), 8225 (k_ravine_big_stone_1)` so the canonical register does
not inherit a swapped pair. The stale values `1000/1912/2866` are absent as
decode offsets (they appear only as documented negatives at `:30,146-147`), so
that half of the item is PASS.

---

## 4. Item 3 — emitted grid values vs X23: **PASS**

**Conditional.** `--dry-run --check` prints per-file paths, sha256s, labels,
`PATTERN FILES`, `BYTE CLOSURE`, three pipeline hashes, `DRY_RUN`, the check
summary and the two closure audits (`:952-980`) — it does **not** print grid
values (`:905-907` prints a hash, not the grid). The literal condition
"if the tool prints emitted grid values" is therefore **not triggered**.

To avoid leaving the claim unverified, I ran a second read-only instrument:
a temp script importing I02's `load_pattern_lib`/`decode_one` (no writes),
taking I02's emitted `relief_float_grid` and computing X23's 8×10 band means
(integer-floor bands, `numpy.mean(dtype='<f4')` — the accumulator X23 §3 P9
accepted) plus raw f32 bit patterns. **17/17 comparison cells matched** (13
block means + 4 X23 §6 S5 `TRUE g bits`):

| Pattern | X23 §4 cell (j,i) | I02 | X23 | Result |
|---|---:|---:|---:|---|
| `k_ravine_1` (G=2798) | (2,4) | −2.957 | −2.957 | PASS |
| `k_ravine_1` | (4,5) | +2.101 | +2.101 | PASS |
| `k_ravine_1` | (5,3) | +2.924 | +2.924 | PASS |
| `plt2` (G=2222) | (2,4) | +3.248 | +3.248 | PASS |
| `plt2` | (3,5) | +3.403 | +3.403 | PASS |
| `plt2` | (4,4) | +3.216 | +3.216 | PASS |
| `hil1` (G=968) | (3,3) | +2.461 | +2.461 | PASS |
| `hil1` | (4,0) | +0.220 | +0.220 | PASS |
| `hil1` | (4,4) | +3.283 | +3.283 | PASS |
| `g_hil4` (G=1864) | (3,4) | +1.780 | +1.780 | PASS |
| `g_hil4` | (4,5) | +1.616 | +1.616 | PASS |
| `k_ravine_big_stone_1` (G=8225) | (3,6) | −2.953 | −2.953 | PASS |
| `k_ravine_big_stone_1` | (5,2) | −2.275 | −2.275 | PASS |

| X23 §6 S5 cell | I02 f32 bits | X23 TRUE g bits | Result |
|---|---|---|---|
| `hil1` (z=22,x=1) | `0x3E8F5C29` | `0x3E8F5C29` | PASS |
| `g_hil4` (z=28,x=4) | `0x3D53C32A` | `0x3D53C32A` | PASS |
| `k_ravine_1` (z=13,x=4) | `0xB1A736BB` | `0xB1A736BB` | PASS |
| `k_ravine_1` (z=31,x=23) | `0xBF79F586` | `0xBF79F586` | PASS |

The accumulator-sensitive `hil1 (4,0)` reproduces X23's `0.220` with the
float32 accumulator; this is the cell X23 §3 P6/P9/P-A resolved after four
passes (double gives `0.221`, exact mean `0.220500004292…`). I02 emits full
precision and declares the layout at `:362-363,518-519`, so the display digit
is not baked into the asset. **Fix: none.** No 8×10 display table is emitted by
I02; `blend_test_vectors.json` uses synthetic `min/mid/max` samples with `g`
from lib literals and is explicitly labelled `[D]` (`:621-651`) — not an X23
8×10 table and not a donor frame.

**Runtime provenance of the read-only run:** `CHECK SUMMARY: PASS 30 / FAIL 0`;
`PIPELINE_SHA256 9bc45639874b9eff7c6401db4fcd459f87d2cfc870d923cfb069a1d0d1498ff7`;
`BLEND_VECTORS_SHA256 ad5bce…`; `MANIFEST_SHA256 898eec…`;
`DRY_RUN: yes (no files written)`.

---

## 5. Item 4 — quarantine, null+UNVERIFIED semantics, no donor copy: **PASS**

**Multiple passes on `m_swamp_12_old`.** P1 static read: `dim_mismatch` is
computed at `:453-459` by comparing section `Width`/`Height` with the binary
`<2i` header (`:381`); the quarantine block at `:489-503` sets
`stats["quarantined"]=True`, `result["flags"]=None`, `status="UNVERIFIED_QUARANTINE"`,
`label="UNVERIFIED"` and a `[U] QUARANTINED` label. P2 check-battery evidence at
`:771-776`: `exactly one dim anomaly (m_swamp_12_old) ['m_swamp_12_old']` PASS
and `m_swamp_12_old quarantined UNVERIFIED 1 quarantined` PASS. P3 runtime
in-process decode of the actual donor file:
section `17×20` vs binary `18×23`; `status=UNVERIFIED_QUARANTINE`;
`flags=None`; `overall label="UNVERIFIED: quarantined donor header anomaly"`;
`byte_closure.ok=True`; grid still emitted. **[D]** This matches X23 §6 S3
`:323-332` (binary header is truth; config mismatch logged) and F01 §4.9
`:307-313`; the tool decodes the binary and withholds only the stale
metadata — it does not "hold the decoder" on the case.

**Null+UNVERIFIED semantics.** P1 static: `result` initialises
`collision_records=None`, `lattice_weights=None` (`:360-361`) with explicit
labels `[U] Tail13 code/flag semantics unidentified — null, not guessed/padded`
and `[U] i32[4N−1] semantics unidentified — null, not guessed/padded`
(`:340-341`). Only the three structurally decoded regions are filled at
`:518-520`; the two unidentified ones stay `None` for all 710 files. P2
check battery `:815-818` `null+UNVERIFIED for undecodable regions` PASS.
P3 runtime on `m_swamp_12_old`: both fields `None`, labels intact.
**[D]** `object_records` *are* emitted as numeric `id/f4/tail4` structures
(`:417-425`) with `[O] structure only … semantics [U] — no prop-name mapping`
(`:339`) — this is exactly F01 §6's parser contract and X23 §7 implication 4,
not a null-violation; the *semantics*, not the bytes, are UNVERIFIED.

**No donor bytes copied.** P1 docstring `:8-11`; P2 `:944-948` labels
(`derived: JSON numbers + labels + sha256 only; no donor bytes embedded`);
P3 emitted key set contains only `source`/`source_sha256`/numeric arrays/labels
(no `raw`, `bytes` or base64 payload). Write guard `:864-871` refuses `--out`
inside the donor root or the legacy `assets/terrain` tree; dry-run is the
default (`:843-849,854`) and the run reported no files written. **Fix: none.**

---

## 6. Item 5 — output ownership vs I03: **PASS**

I02 writes only `<stem>.json` for each of 710 patterns plus
`blend_test_vectors.json` and `pattern_decode_manifest.json` into
`variant3d/assets/terrain_new/patterns/` (`:87,905,982-988`; manifest
`:919-951`). Its source contains **zero** occurrences of `family` /
`families` / `family_index` (grep: no matches), and its write mode only
`mkdir(exist_ok=True)` then writes its own names — it never clears or
overwrites another owner's files. I03's current tool declares its ownership
boundary explicitly at `decode_pattern_lib.py:1059-1060`
(`"Ownership boundary (COORD/V44): one lib index only; no I02-owned outputs"`,
`docs = {"pattern_lib_index.json": ...}`). **No filename collision.**

**Observation for COORD (not an I02 defect).** `family_index.json` and
`families/**` *are* present on disk under the **same** shared directory
`variant3d/assets/terrain_new/patterns/`; `family_index.json:2` describes them
as metadata-only, "no per-.pattern binary decode (I02 owns grids/occupancy/
tails)". They are stale artifacts of an earlier I03 invocation. Two passes on
the concurrency: an initial grep of `decode_pattern_lib.py` showed a
`family_index.json`/`families/` boundary at lines 1056–1057; an immediate
re-read and re-grep showed the file had changed (I03 is still RUNNING on the
board) to the `pattern_lib_index.json`-only boundary at `:1060`. I therefore
declare **no defect** against either worker — only the record that the two
ownership statements were observed at different times. **Suggested COORD fix
(housekeeping only):** when I03 lands, rename/remove the stale
`family_index.json` + `families/**` artifacts or re-affirm them as I03-owned,
so a future reader does not attribute them to I02. I02 needs no change.

---

## 7. Multiple-pass register (owner directive)

| Anomaly | Passes | Result |
|---|---|---|
| Item 1 closure | static region sum → runtime 710/710 → two printed closure audits | PASS, no defect |
| Item 2 brief label swap | assignment → X23 §4 → F01 §4 → code → runtime decode (5 passes) | Brief FAIL, code PASS; defect assigned to task text |
| Item 3 `hil1 (4,0)` `0.220` vs `0.221` | float32 accumulator → X23 P9/P-A provenance → I02 full precision emitted | PASS, no defect |
| Item 4 quarantine | static → check battery → in-process donor decode | PASS, no defect |
| Item 5 ownership + concurrent I03 edit | grep (old boundary) → re-read (new boundary) → re-grep → on-disk artifact read | PASS for I02; no defect declared; observation logged |

Nothing was skipped after one reading; the only FAIL is in the audit brief,
and it was confirmed across five instruments before being reported.

---

## 8. UNVERIFIED register

| ID | Claim | Status |
|---|---|---|
| U1 | Exact grid plane boundary from the engine loader | **[U]** `G=8+N` structurally derived (F01 710/710 + X23 5/5 bit-exact); loader field names not RTTI-confirmed. I02 uses the derived law, never a scan. |
| U2 | Row-sign flip, engine blend x87 exactness, global setter clamp | **[U]** inherited F01 §9 / X23 §8 / X26 §UNVERIFIED; I02 labels blend inputs `[D]` and parity `[U]`. |
| U3 | Semantics of mask, `Rec24.id/tail4`, weights, `Tail13` codes | **[U]** I02 emits structure only; weights/tail `None`+`[U]`. |
| U4 | Provenance of on-disk `family_index.json`/`families/**` after I03's edit | **[U]** observed on disk; current I03 source emits only `pattern_lib_index.json`; owner COORD/I03 to reconcile. |
| U5 | Donor GPU visual parity | **[U]** no A/B frame exists. **No parity claim.** |

---

## 9. Five-line summary

1. **Item 1 PASS** — I02 derives `filesize=8+4wh+54N` and seven contiguous regions, rejects broken files, and ran 710/710 closure with printed audits matching F01 §4.2/§5.
2. **Item 2 PASS for code** — decode offset is computed `G=8+N`; `CITED_PAIRS` carries 968/1864/2798/2222/8225 and documents 1000/1912/2866 as stale; **the X49 assignment text itself swaps the `2222`/`8225` pattern labels** (5 passes) — COORD fix, not an I02 fix.
3. **Item 3 PASS** — `--dry-run --check` prints hashes, not grid values; an independent read-only in-process comparison matched 13/13 X23 §4 block cells and 4/4 X23 §6 S5 TRUE-g bit cells (including `hil1 (4,0)=0.220`).
4. **Item 4 PASS** — `m_swamp_12_old` is `UNVERIFIED_QUARANTINE` with flags withheld while its binary grid is decoded; weights/tail are `None`+`[U]` for all files; only derived JSON is emitted and donor-root output is refused.
5. **Item 5 PASS** — I02 emits no `family_index.json`/`families/**`; the shared directory and stale I03 artifacts are a COORD housekeeping observation, and I03's concurrent source edit was confirmed across multiple passes. **PORT APPROXIMATION only; no donor parity claim.**

*End of X49. Exactly one repo file written. Donor read only; no donor binary executed or copied; no repo source, asset, config, test, shader, queue, git or Godot state changed.*
