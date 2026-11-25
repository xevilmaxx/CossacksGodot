---
id: RV-TRN-02
task: "Third-pass donor re-verification: terrain tile-assignment + smoothing rules (DTRN-01 C8/C9/C10 Q5)"
date: 2026-11-25
status: DELIVERED__AUDIT_ONLY__NO_DONOR_BINARY_EXECUTED
scope: "One report written. No port mapgen/code edit, no runner job, no donor copy/execute. Donor read-only."
donor: "C:\\Games\\Cossacks 3 (READ-ONLY, private use; Python 3.14 bytes/latin-1; no file copied or run)"
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
output: "docs/coord_swarm_2026-11-25/reports/RV_TRN_02_smoothing_rules.md"
labels: [observed, derived, inferred, UNVERIFIED]
verification_passes: 2
donor_truth_primary: true
---

# RV-TRN-02 — Donor terrain tile-assignment and smoothing rules, fully parsed

## 0. Goal

Resolve **DTRN-01 §8 Q5**: DTRN-01 read only lines 1–35 of the 1,864-line
`gen\tilesmooth_scripts.cfg` and marked the remaining 1,829 lines UNVERIFIED,
which blocks the donor-faithful tile-diversity fix (V3D_02 F3). This pass:

1. parses **all 1,864 lines** of `tilesmooth_scripts.cfg` (active and commented),
2. independently re-verifies the smoothing algorithm in `smoothtiles.inc`,
3. re-verifies shore/rock/road tile selection in `texturemap.inc`,
4. cross-checks the two older donor-pipeline reports and records corrections.

Every claim is tagged **observed** (literal donor line/byte), **derived**
(deterministic arithmetic/control-flow on cited lines), **inferred** (reading
with a caveat), or **UNVERIFIED** (not provable from readable donor data).
Donor truth is primary; port files are not edited. No visual-parity claim is made.

---

## 1. Method and sources (two independent passes)

- **V1 — structural parse.** `python` 3.14:
  `open(path,'rb').read().decode('latin-1').split('\n')`, then an indentation-
  driven stack parser building a `struct.begin`/`struct.end` tree from all
  1,864 lines. Lines prefixed `//` were classified as commented; data values
  were taken from active lines only (this matters: six active lists carry a
  commented-out `//Prob = 0.36` alternative *before* the live `Prob = 0.64`,
  e.g. `gen\tilesmooth_scripts.cfg:451-452`). Coverage check: 1,860 of 1,864
  lines match a known token (section, struct, `[*]`, `TileName`, `Prob`);
  the remaining four are double-commented `// //Prob = 0` alternatives at
  `:42, :47, :972, :977`. **No line was skipped or skimmed.**
- **V2 — independent means.** (a) raw regex scan over the same bytes for
  `TileName`/`Prob` counts and `Prob=0` lines; (b) SHA-256/size fingerprint of
  all five donor files; (c) structural cross-check of every extracted tile name
  against the 245 `TileBlock` names in `terrain\tiles\terrain.presets` —
  **all 86 distinct active names resolve, 0 missing**; (d) cross-check against
  the two prior reports written by other lanes (§6). Where V1 and V2 disagree,
  the raw byte read wins.

| Donor file (relative to `C:\Games\Cossacks 3\data`) | Bytes (V2) | SHA-256 (V2) | Lines (V1) |
|---|---:|---|---:|
| `gen\tilesmooth_scripts.cfg` | 64,017 | `b82c88844160c0451696951466a72bcd1dff64079388c0ad0b3b0a07a531b433` | 1,864 |
| `gen\tilesmooth.cfg` | 2,796 | `1753533e7984c2319c3c5fdbc519728e0937905c4cc5117846432ce008b89c7d` | 130 |
| `gen\globalparams.cfg` | 537 | `15a8dc64a91dc4e72f45a997d6f6a5b770b2b77786518f48a75e04ab95727a51` | 23 |
| `scripts\common.inc\smoothtiles.inc` | 10,691 | `1887b5ddc6ebed051b709647eaafe6e96b415b56a2be15ba5b4e81ea6bcf179c` | 247 |
| `scripts\common.inc\texturemap.inc` | 48,954 | `97eab41145382806a77cfd520a0b4d90ec055e4470a1872961291b2bdb55fbdf` | 964 |
| `scripts\common.inc\loadtextureterrainfrombitmap.inc` | 1,885 | `aebe7a572d0b2bfb34f93a257c74e80883d86cfba5e86dc27cfd1f61464c93e8` | 50 |

(All six hashes are new this lane; a changed install can be detected by
recomputing them. **observed**, V1+V2.)

---

## 2. Prior DTRN-01 / older-report claims re-checked

| Prior claim (source) | Verdict after RV-TRN-02 | Detail |
|---|---|---|
| DTRN-01 C8: discrete per-cell tile index + weighted neighbour compatibility + alpha-atlas modulation (`DTRN_01…:122`) | **CONFIRMED as donor text; activity caveat added** | `smoothtiles.inc:4-6,35-59,63-80,84-187,191-243` exists verbatim, but **every code line is `;`-commented** (§4.6). |
| DTRN-01 C9: 3 passes, horizontal then vertical; Δ=1 unchanged; Δ=2 weighted midpoint; larger gap pull one step (`:123`) | **CONFIRMED + refined** | `smoothtiles.inc:126-180,197-234,237`. Δ=1 has an extra `probzero` condition at `:142`; J is the *list index*, not the position inside `TileNames` (§4.3). |
| DTRN-01 C10: first-rule weights; "some lists have Prob=0"; roulette over `SumProb` (`:124`) | **CONFIRMED but incomplete → superseded** | First rule verified at `:5-36`; full 22-Item inventory in §3; exactly 8 active `Prob=0` entries in 4 lists (§3.5). |
| DTRN-01 §4 `Items[64]` rules (`:231`) | **CORRECTED** | 64 is the *array bound* (`smoothtiles.inc:26`); actual parsed `Count` = **22 Items** (`:7,35`). |
| DTRN-01 §4 road `test2` p=0.25 / `test3` p=0.25 (`:221`, `:296`) | **CORRECTED** | Two separate `RandomExt` calls (`texturemap.inc:627,633`) ⇒ 0.5 / **0.375 / 0.125** (§5.4). |
| DTRN-01 §8 Q5 "full cfg not exhaustively parsed" (`:501-503`) | **RESOLVED** | This report covers all 1,864 lines (§3). |
| `TERRAIN_DONOR_PIPELINE.md:78` "builds 64 probability tables" | **CORRECTED** | 22 Items × 1–9 active lists = **118 active lists**; 64 is the array bound. |
| `TERRAIN_DONOR_PIPELINE.md:413-414` / Q4 "cfg contents not read" | **RESOLVED** | §3 inventory + §7 machine-readable table. |
| `TERRAIN2_01…:63-64` E32/E33 (weights from `:1-35` only) | **EXTENDED, not contradicted** | E33's six weights are exactly Item 0 J=0/J=1; the other 116 active lists are new here. |

---

## 3. Full rule inventory (complete — all 1,864 lines)

### 3.1 Structure, counts, and semantics

The config contains **one** `section` (`:1`, `:1863`) with **one**
`TileSmoothLists` struct (`:2`). Its 22 `[*]` children are the `Items` consumed
by `smoothtiles.inc:35-39`; each has exactly one `SmoothTiles` struct, whose
`[*]` children are the rule lists, each with one `TileNames` array of `[*]`
tile entries. (V1 tree + V2 regex agree.)

| Quantity | Value | Evidence / label |
|---|---:|---|
| Total lines parsed | 1,864 | file byte read; **observed** |
| `struct.begin` / `struct.end` | 615 / 615 (balanced) | V1; **observed** |
| `Item` = `TileSmoothLists[*]` | **22** (0–21) | `:3,97,193,285,397,518,627,732,780,816,880,933,1027,1123,1215,1327,1448,1557,1662,1710,1746,1810`; **observed** |
| `SmoothTiles` rule lists, total | 130 | V1 tree; **observed** |
| — active lists | **118** | V1+V2; **derived** (commented lists excluded) |
| — commented lists | 12 | `:37,746,882,890,902,914,967,1676,1812,1820,1832,1844`; **observed** |
| Max active lists in one Item | 9 (Items 3, 4, 14, 15) | §3.4; **derived** |
| `TileName` entries, total | 310 | V1+V2; **observed** |
| — active | **282** | V1+V2; **observed** |
| — commented | 28 (26 inside commented lists + 2 at `:857`, `:1787` inside active lists) | V1+V2; **observed** |
| `Prob` lines, total | 320 | V1; **observed** |
| — active / commented | 282 / 38 (incl. 4 double-comments at `:42,47,972,977` and six `//Prob = 0.36` alternatives at `:451,572,681,1381,1502,1611`) | V1+V2; **observed** |
| Distinct active tile names | **86** (43 Summer + 43 `*_winter`); all resolve in `terrain.presets` (245 `TileBlock` names) | V2 cross-check; **observed + derived** |
| Array bounds in consumer (not actual counts) | `Items[0..63]`, `SmoothTiles[0..23]`, `SmoothTile[0..15]` | `smoothtiles.inc:26,23,18`; **observed** |

**Critical semantic point.** `reconcile()` compares `j` — the index of the
*active rule list* inside one Item (`smoothtiles.inc:108-135`) — not the
position of the tile inside its `TileNames` array. Commented lists do **not**
occupy a `j` slot: e.g. Item 0 has `j=0` sandsea1–4, `j=1` sandsea5–6, the
commented sandrock list at source `:37` is skipped, `j=2` is the all-zero rock
list (`:51`), and `j=3` is rock1–7/4 (`:67`). (V1 tree + V2 text; **derived**.)

Items 0–10 are the **Summer** set, Items 11–21 the identical **Winter** set with
`_winter` appended; the list-count pattern is mirrored exactly
(5,6,6,9,9,8,6,4,3,5,4 / 5,6,6,9,9,8,6,4,3,5,4). **derived** from §3.4 rows
and `smoothtiles.inc:51,56`.

### 3.2 Compressed pattern table (identical patterns grouped)

54 distinct active patterns; 30 occur more than once. Groups with count ≥2
(every tile name is still listed; the 24 singletons are in §7):

| Count | TileName:Prob pattern | SumProb |
|---:|---|---:|
| 7 | grass1:1, grass2:1, test8:1 | 3 |
| 7 | grass1_winter:1, grass2_winter:1, test8_winter:1 | 3 |
| 4 | sandsea1:1, sandsea2:1, sandsea3:1, sandsea4:1 | 4 |
| 4 | sandsea5:0.7, sandsea6:0.3 | 1 |
| 4 | rock1:0.16, rock2:0.16, rock3:0.16, rock6:0.16, rock7:0.16, rock4:0.20 | 1 |
| 4 | rock9:1 | 1 |
| 4 | sandsea1_winter:1, sandsea2_winter:1, sandsea3_winter:1, sandsea4_winter:1 | 4 |
| 4 | sandsea5_winter:0.7, sandsea6_winter:0.3 | 1 |
| 4 | rock1_winter:0.16, rock2_winter:0.16, rock3_winter:0.16, rock6_winter:0.16, rock7_winter:0.16, rock4_winter:0.20 | 1 |
| 4 | rock9_winter:1 | 1 |
| 3 | sandrock1:0.4, sandrock3:0.6 | 1 |
| 3 | sandrock4:0.6, sandrock2:0.4 | 1 |
| 3 | rock8:0.5, rock5:0.5 | 1 |
| 3 | grass_ground1:0.64, grass_ground2:0.0028, grass_ground3:0.36 | 1.0028 |
| 3 | sandrock1_winter:0.4, sandrock3_winter:0.6 | 1 |
| 3 | sandrock4_winter:0.6, sandrock2_winter:0.4 | 1 |
| 3 | rock8_winter:0.5, rock5_winter:0.5 | 1 |
| 3 | grass_ground1_winter:0.64, grass_ground2_winter:0.0028, grass_ground3_winter:0.36 | 1.0028 |
| 2 | grass7:0.25, test12:0.25, test13:0.25, test14:0.25 | 1 |
| 2 | grass9:1 | 1 |
| 2 | test9:1 | 1 |
| 2 | grass3:1 | 1 |
| 2 | grass4:0.9, grass10:0.1 | 1 |
| 2 | grass5:1 | 1 |
| 2 | grass7_winter:0.25, test12_winter:0.25, test13_winter:0.25, test14_winter:0.25 | 1 |
| 2 | grass9_winter:1 | 1 |
| 2 | test9_winter:1 | 1 |
| 2 | grass3_winter:1 | 1 |
| 2 | grass4_winter:0.9, grass10_winter:0.1 | 1 |
| 2 | grass5_winter:1 | 1 |

### 3.3 Tile families referenced (complete, 43 base names)

Summer (43): `grass1, grass2, grass3, grass4, grass5, grass6, grass7, grass8,
grass9, grass10` (10); `grass_ground1, grass_ground2, grass_ground3` (3);
`ground1` (1); `rock1, rock2, rock3, rock4, rock5, rock6, rock7, rock8, rock9`
(9); `sandrock1, sandrock2, sandrock3, sandrock4` (4); `sandsea1..sandsea6` (6);
`test1, test2, test3, test6, test7, test8, test9, test12, test13, test14` (10).
Winter: the same 43 names with `_winter` appended (e.g. `:935`, `:1776`).
**observed + derived**; every one resolves to a `TileBlock` in
`terrain\tiles\terrain.presets` (V2, 0 missing). Note the config references
`sandrock1..4`, `rock2/5/6`, `test1/12/13/14`, which DTRN-01's first-rule-only
read did not cover.

### 3.4 Complete per-item inventory (all 130 lists, active and commented)

`J` is the per-Item active-list index used by `reconcile()`; `[c]` marks a
commented `TileName` inside an otherwise active list (it does not participate).
SumProb is the arithmetic sum of the **active** Prob values in that list
(§4.2 caveat: the engine must zero-initialise `sumProb`/`tmp`).

| Item | src-list | Status | cfg line | TileName (Prob) | SumProb |
|---:|---:|---|---:|---|---:|
| 0 | 0 | ACTIVE J=0 | 5 | sandsea1 (1); sandsea2 (1); sandsea3 (1); sandsea4 (1) | 4 |
| 0 | 1 | ACTIVE J=1 | 25 | sandsea5 (0.7); sandsea6 (0.3) | 1 |
| 0 | 2 | COMMENTED | 37 | sandrock1 (0.4) [c]; sandrock3 (0.6) [c] | 0 |
| 0 | 3 | ACTIVE J=2 | 51 | rock9 (0.0); rock8 (0.0); rock5 (0.0) | 0 |
| 0 | 4 | ACTIVE J=3 | 67 | rock1 (0.16); rock2 (0.16); rock3 (0.16); rock6 (0.16); rock7 (0.16); rock4 (0.20) | 1 |
| 1 | 0 | ACTIVE J=0 | 99 | sandsea1 (1); sandsea2 (1); sandsea3 (1); sandsea4 (1) | 4 |
| 1 | 1 | ACTIVE J=1 | 119 | sandsea5 (0.7); sandsea6 (0.3) | 1 |
| 1 | 2 | ACTIVE J=2 | 131 | sandrock1 (0.4); sandrock3 (0.6) | 1 |
| 1 | 3 | ACTIVE J=3 | 143 | sandrock4 (0.6); sandrock2 (0.4) | 1 |
| 1 | 4 | ACTIVE J=4 | 155 | grass1 (1); grass2 (1); test8 (1) | 3 |
| 1 | 5 | ACTIVE J=5 | 171 | grass7 (0.25); test12 (0.25); test13 (0.25); test14 (0.25) | 1 |
| 2 | 0 | ACTIVE J=0 | 195 | sandsea1 (1); sandsea2 (1); sandsea3 (1); sandsea4 (1) | 4 |
| 2 | 1 | ACTIVE J=1 | 215 | sandsea5 (0.7); sandsea6 (0.3) | 1 |
| 2 | 2 | ACTIVE J=2 | 227 | sandrock1 (0.4); sandrock3 (0.6) | 1 |
| 2 | 3 | ACTIVE J=3 | 239 | sandrock4 (0.6); sandrock2 (0.4) | 1 |
| 2 | 4 | ACTIVE J=4 | 251 | grass1 (1); grass2 (1); test8 (1) | 3 |
| 2 | 5 | ACTIVE J=5 | 267 | test7 (1); grass8 (1); test6 (1) | 3 |
| 3 | 0 | ACTIVE J=0 | 287 | sandsea1 (1); sandsea2 (1); sandsea3 (1); sandsea4 (1) | 4 |
| 3 | 1 | ACTIVE J=1 | 307 | sandsea5 (0.7); sandsea6 (0.3) | 1 |
| 3 | 2 | ACTIVE J=2 | 319 | sandrock1 (0.4); sandrock3 (0.6) | 1 |
| 3 | 3 | ACTIVE J=3 | 331 | sandrock4 (0.6); sandrock2 (0.4) | 1 |
| 3 | 4 | ACTIVE J=4 | 343 | grass1 (1); grass2 (1); test8 (1) | 3 |
| 3 | 5 | ACTIVE J=5 | 359 | grass9 (1) | 1 |
| 3 | 6 | ACTIVE J=6 | 367 | test9 (1) | 1 |
| 3 | 7 | ACTIVE J=7 | 375 | grass3 (1) | 1 |
| 3 | 8 | ACTIVE J=8 | 383 | grass4 (0.9); grass10 (0.1) | 1 |
| 4 | 0 | ACTIVE J=0 | 399 | rock1 (0.16); rock2 (0.16); rock3 (0.16); rock6 (0.16); rock7 (0.16); rock4 (0.20) | 1 |
| 4 | 1 | ACTIVE J=1 | 427 | rock8 (0.5); rock5 (0.5) | 1 |
| 4 | 2 | ACTIVE J=2 | 439 | rock9 (1) | 1 |
| 4 | 3 | ACTIVE J=3 | 447 | grass_ground1 (0.64); grass_ground2 (0.0028); grass_ground3 (0.36) | 1.0028 |
| 4 | 4 | ACTIVE J=4 | 464 | grass1 (1); grass2 (1); test8 (1) | 3 |
| 4 | 5 | ACTIVE J=5 | 480 | grass9 (1) | 1 |
| 4 | 6 | ACTIVE J=6 | 488 | test9 (1) | 1 |
| 4 | 7 | ACTIVE J=7 | 496 | grass3 (1) | 1 |
| 4 | 8 | ACTIVE J=8 | 504 | grass4 (0.9); grass10 (0.1) | 1 |
| 5 | 0 | ACTIVE J=0 | 520 | rock1 (0.16); rock2 (0.16); rock3 (0.16); rock6 (0.16); rock7 (0.16); rock4 (0.20) | 1 |
| 5 | 1 | ACTIVE J=1 | 548 | rock8 (0.5); rock5 (0.5) | 1 |
| 5 | 2 | ACTIVE J=2 | 560 | rock9 (1) | 1 |
| 5 | 3 | ACTIVE J=3 | 568 | grass_ground1 (0.64); grass_ground2 (0.0028); grass_ground3 (0.36) | 1.0028 |
| 5 | 4 | ACTIVE J=4 | 585 | grass1 (1); grass2 (1); test8 (1) | 3 |
| 5 | 5 | ACTIVE J=5 | 601 | test7 (1) | 1 |
| 5 | 6 | ACTIVE J=6 | 609 | grass8 (1) | 1 |
| 5 | 7 | ACTIVE J=7 | 617 | test6 (1) | 1 |
| 6 | 0 | ACTIVE J=0 | 629 | rock1 (0.16); rock2 (0.16); rock3 (0.16); rock6 (0.16); rock7 (0.16); rock4 (0.20) | 1 |
| 6 | 1 | ACTIVE J=1 | 657 | rock8 (0.5); rock5 (0.5) | 1 |
| 6 | 2 | ACTIVE J=2 | 669 | rock9 (1) | 1 |
| 6 | 3 | ACTIVE J=3 | 677 | grass_ground1 (0.64); grass_ground2 (0.0028); grass_ground3 (0.36) | 1.0028 |
| 6 | 4 | ACTIVE J=4 | 694 | grass1 (1); grass2 (1); test8 (1) | 3 |
| 6 | 5 | ACTIVE J=5 | 710 | grass7 (0.25); test12 (0.25); test13 (0.25); test14 (0.25) | 1 |
| 7 | 0 | ACTIVE J=0 | 734 | rock9 (1); test8 (0) | 1 |
| 7 | 1 | COMMENTED | 746 | grass_ground1 (0.36) [c]; grass_ground2 (0.28) [c]; grass_ground3 (0.36) [c] | 0 |
| 7 | 2 | ACTIVE J=1 | 762 | grass5 (1) | 1 |
| 7 | 3 | ACTIVE J=2 | 770 | grass6 (1) | 1 |
| 8 | 0 | ACTIVE J=0 | 782 | rock9 (1) | 1 |
| 8 | 1 | ACTIVE J=1 | 790 | grass5 (1) | 1 |
| 8 | 2 | ACTIVE J=2 | 798 | grass_ground1 (0.36); grass_ground2 (0.28); grass_ground3 (0.36) | 1 |
| 9 | 0 | ACTIVE J=0 | 818 | ground1 (1) | 1 |
| 9 | 1 | ACTIVE J=1 | 826 | test2 (1) | 1 |
| 9 | 2 | ACTIVE J=2 | 834 | test1 (1); test3 (1) | 2 |
| 9 | 3 | ACTIVE J=3 | 846 | test8 (0.4); test7 (0.6); grass2 (1) [c] | 1 |
| 9 | 4 | ACTIVE J=4 | 862 | grass1 (1); grass2 (1); test8 (1) | 3 |
| 10 | 0 | COMMENTED | 882 | test2 (1) [c] | 0 |
| 10 | 1 | COMMENTED | 890 | test1 (0.7) [c]; test3 (0.3) [c] | 0 |
| 10 | 2 | COMMENTED | 902 | test6 (1) [c]; grass2 (1) [c] | 0 |
| 10 | 3 | COMMENTED | 914 | grass1 (1) [c]; grass2 (1) [c]; test8 (1) [c] | 0 |
| 11 | 0 | ACTIVE J=0 | 935 | sandsea1_winter (1); sandsea2_winter (1); sandsea3_winter (1); sandsea4_winter (1) | 4 |
| 11 | 1 | ACTIVE J=1 | 955 | sandsea5_winter (0.7); sandsea6_winter (0.3) | 1 |
| 11 | 2 | COMMENTED | 967 | sandrock1_winter (0.4) [c]; sandrock3_winter (0.6) [c] | 0 |
| 11 | 3 | ACTIVE J=2 | 981 | rock9_winter (0.0); rock8_winter (0.0); rock5_winter (0.0) | 0 |
| 11 | 4 | ACTIVE J=3 | 997 | rock1_winter (0.16); rock2_winter (0.16); rock3_winter (0.16); rock6_winter (0.16); rock7_winter (0.16); rock4_winter (0.20) | 1 |
| 12 | 0 | ACTIVE J=0 | 1029 | sandsea1_winter (1); sandsea2_winter (1); sandsea3_winter (1); sandsea4_winter (1) | 4 |
| 12 | 1 | ACTIVE J=1 | 1049 | sandsea5_winter (0.7); sandsea6_winter (0.3) | 1 |
| 12 | 2 | ACTIVE J=2 | 1061 | sandrock1_winter (0.4); sandrock3_winter (0.6) | 1 |
| 12 | 3 | ACTIVE J=3 | 1073 | sandrock4_winter (0.6); sandrock2_winter (0.4) | 1 |
| 12 | 4 | ACTIVE J=4 | 1085 | grass1_winter (1); grass2_winter (1); test8_winter (1) | 3 |
| 12 | 5 | ACTIVE J=5 | 1101 | grass7_winter (0.25); test12_winter (0.25); test13_winter (0.25); test14_winter (0.25) | 1 |
| 13 | 0 | ACTIVE J=0 | 1125 | sandsea1_winter (1); sandsea2_winter (1); sandsea3_winter (1); sandsea4_winter (1) | 4 |
| 13 | 1 | ACTIVE J=1 | 1145 | sandsea5_winter (0.7); sandsea6_winter (0.3) | 1 |
| 13 | 2 | ACTIVE J=2 | 1157 | sandrock1_winter (0.4); sandrock3_winter (0.6) | 1 |
| 13 | 3 | ACTIVE J=3 | 1169 | sandrock4_winter (0.6); sandrock2_winter (0.4) | 1 |
| 13 | 4 | ACTIVE J=4 | 1181 | grass1_winter (1); grass2_winter (1); test8_winter (1) | 3 |
| 13 | 5 | ACTIVE J=5 | 1197 | test7_winter (1); grass8_winter (1); test6_winter (1) | 3 |
| 14 | 0 | ACTIVE J=0 | 1217 | sandsea1_winter (1); sandsea2_winter (1); sandsea3_winter (1); sandsea4_winter (1) | 4 |
| 14 | 1 | ACTIVE J=1 | 1237 | sandsea5_winter (0.7); sandsea6_winter (0.3) | 1 |
| 14 | 2 | ACTIVE J=2 | 1249 | sandrock1_winter (0.4); sandrock3_winter (0.6) | 1 |
| 14 | 3 | ACTIVE J=3 | 1261 | sandrock4_winter (0.6); sandrock2_winter (0.4) | 1 |
| 14 | 4 | ACTIVE J=4 | 1273 | grass1_winter (1); grass2_winter (1); test8_winter (1) | 3 |
| 14 | 5 | ACTIVE J=5 | 1289 | grass9_winter (1) | 1 |
| 14 | 6 | ACTIVE J=6 | 1297 | test9_winter (1) | 1 |
| 14 | 7 | ACTIVE J=7 | 1305 | grass3_winter (1) | 1 |
| 14 | 8 | ACTIVE J=8 | 1313 | grass4_winter (0.9); grass10_winter (0.1) | 1 |
| 15 | 0 | ACTIVE J=0 | 1329 | rock1_winter (0.16); rock2_winter (0.16); rock3_winter (0.16); rock6_winter (0.16); rock7_winter (0.16); rock4_winter (0.20) | 1 |
| 15 | 1 | ACTIVE J=1 | 1357 | rock8_winter (0.5); rock5_winter (0.5) | 1 |
| 15 | 2 | ACTIVE J=2 | 1369 | rock9_winter (1) | 1 |
| 15 | 3 | ACTIVE J=3 | 1377 | grass_ground1_winter (0.64); grass_ground2_winter (0.0028); grass_ground3_winter (0.36) | 1.0028 |
| 15 | 4 | ACTIVE J=4 | 1394 | grass1_winter (1); grass2_winter (1); test8_winter (1) | 3 |
| 15 | 5 | ACTIVE J=5 | 1410 | grass9_winter (1) | 1 |
| 15 | 6 | ACTIVE J=6 | 1418 | test9_winter (1) | 1 |
| 15 | 7 | ACTIVE J=7 | 1426 | grass3_winter (1) | 1 |
| 15 | 8 | ACTIVE J=8 | 1434 | grass4_winter (0.9); grass10_winter (0.1) | 1 |
| 16 | 0 | ACTIVE J=0 | 1450 | rock1_winter (0.16); rock2_winter (0.16); rock3_winter (0.16); rock6_winter (0.16); rock7_winter (0.16); rock4_winter (0.20) | 1 |
| 16 | 1 | ACTIVE J=1 | 1478 | rock8_winter (0.5); rock5_winter (0.5) | 1 |
| 16 | 2 | ACTIVE J=2 | 1490 | rock9_winter (1) | 1 |
| 16 | 3 | ACTIVE J=3 | 1498 | grass_ground1_winter (0.64); grass_ground2_winter (0.0028); grass_ground3_winter (0.36) | 1.0028 |
| 16 | 4 | ACTIVE J=4 | 1515 | grass1_winter (1); grass2_winter (1); test8_winter (1) | 3 |
| 16 | 5 | ACTIVE J=5 | 1531 | test7_winter (1) | 1 |
| 16 | 6 | ACTIVE J=6 | 1539 | grass8_winter (1) | 1 |
| 16 | 7 | ACTIVE J=7 | 1547 | test6_winter (1) | 1 |
| 17 | 0 | ACTIVE J=0 | 1559 | rock1_winter (0.16); rock2_winter (0.16); rock3_winter (0.16); rock6_winter (0.16); rock7_winter (0.16); rock4_winter (0.20) | 1 |
| 17 | 1 | ACTIVE J=1 | 1587 | rock8_winter (0.5); rock5_winter (0.5) | 1 |
| 17 | 2 | ACTIVE J=2 | 1599 | rock9_winter (1) | 1 |
| 17 | 3 | ACTIVE J=3 | 1607 | grass_ground1_winter (0.64); grass_ground2_winter (0.0028); grass_ground3_winter (0.36) | 1.0028 |
| 17 | 4 | ACTIVE J=4 | 1624 | grass1_winter (1); grass2_winter (1); test8_winter (1) | 3 |
| 17 | 5 | ACTIVE J=5 | 1640 | grass7_winter (0.25); test12_winter (0.25); test13_winter (0.25); test14_winter (0.25) | 1 |
| 18 | 0 | ACTIVE J=0 | 1664 | rock9_winter (1); test8_winter (0) | 1 |
| 18 | 1 | COMMENTED | 1676 | grass_ground1_winter (0.36) [c]; grass_ground2_winter (0.28) [c]; grass_ground3_winter (0.36) [c] | 0 |
| 18 | 2 | ACTIVE J=1 | 1692 | grass5_winter (1) | 1 |
| 18 | 3 | ACTIVE J=2 | 1700 | grass6_winter (1) | 1 |
| 19 | 0 | ACTIVE J=0 | 1712 | rock9_winter (1) | 1 |
| 19 | 1 | ACTIVE J=1 | 1720 | grass5_winter (1) | 1 |
| 19 | 2 | ACTIVE J=2 | 1728 | grass_ground1_winter (0.36); grass_ground2_winter (0.28); grass_ground3_winter (0.36) | 1 |
| 20 | 0 | ACTIVE J=0 | 1748 | ground1_winter (1) | 1 |
| 20 | 1 | ACTIVE J=1 | 1756 | test2_winter (1) | 1 |
| 20 | 2 | ACTIVE J=2 | 1764 | test1_winter (1); test3_winter (1) | 2 |
| 20 | 3 | ACTIVE J=3 | 1776 | test8_winter (0.4); test7_winter (0.6); grass2_winter (1) [c] | 1 |
| 20 | 4 | ACTIVE J=4 | 1792 | grass1_winter (1); grass2_winter (1); test8_winter (1) | 3 |
| 21 | 0 | COMMENTED | 1812 | test2_winter (1) [c] | 0 |
| 21 | 1 | COMMENTED | 1820 | test1_winter (0.7) [c]; test3_winter (0.3) [c] | 0 |
| 21 | 2 | COMMENTED | 1832 | test6_winter (1) [c]; grass2_winter (1) [c] | 0 |
| 21 | 3 | COMMENTED | 1844 | grass1_winter (1) [c]; grass2_winter (1) [c]; test8_winter (1) [c] | 0 |

### 3.5 Prob=0 entries and hard separators

Exactly **8 active** tile entries have `Prob=0` (V1+V2 agree; **observed**):

| cfg line | Item / J | Entry | Role |
|---:|---|---|---|
| `:55, :59, :63` | Item 0 / J=2 | `rock9`, `rock8`, `rock5` (all 0.0) | whole list SumProb=0 — hard separator |
| `:742` | Item 7 / J=0 | `test8` (0) inside `rock9:1` list | position-only tile, never selectable |
| `:985, :989, :993` | Item 11 / J=2 | `rock9_winter`, `rock8_winter`, `rock5_winter` (all 0.0) | winter hard separator |
| `:1672` | Item 18 / J=0 | `test8_winter` (0) inside `rock9_winter:1` | position-only tile |

`FindRandomTileIndex` tests `(prob>0) and (rnd<tmp)` (`smoothtiles.inc:74`), so
a Prob=0 tile can **never** be returned; a SumProb=0 list returns `-1` for every
rnd, i.e. "no change". A zero-prob list still occupies a `J` slot and therefore
acts as a *barrier*: sandsea5 (Item 0 J=1) separated from rock1 (J=3) by the J=2
zero list cannot be bridged, because the Δ=2 midpoint pick is `-1`.
**derived** from `:66-80` + `:126-180` + config rows above.

Two authoring anomalies (both **observed**, do not silently "fix" them):
- `grass_ground1` has a commented `//Prob = 0.36` then live `Prob = 0.64`
  (`:451-452,572-573,681-682,1381-1382,1502-1503,1611-1612`), and
  `grass_ground2 = 0.0028` — SumProb **1.0028**, not 1.0 (6 lists).
  In Items 8/19 the same family is `0.36 / 0.28 / 0.36` — SumProb **1.0**
  (`:798-810`, `:1728-1740`).
- Only duplicate active name inside one Item is `test8` in Item 9 (J=3 and J=4,
  `:846` and `:862`) and `test8_winter` in Item 20 (`:1776`, `:1792`). Because
  the search loop overwrites `ind1`/`ind2` (`smoothtiles.inc:112-121`), the
  **higher J (4) wins** for that name. `grass2` at `:857` and `grass2_winter` at
  `:1787` are commented, so they do not duplicate. **derived**.
---

## 4. Smoothing algorithm verification (`scripts\common.inc\smoothtiles.inc`)

### 4.1 Load phase (`:4-61`)

`ParserLoadFromFileByHandle(pTileSmoothLists, '.\data\gen\tilesmooth_scripts.cfg')`
(`:5`), then `ParserSelectByHandleByKey(..., 'TileSmoothLists')` (`:6`) and
`Count := ParserGetCountByHandle(...)` (`:7`). With the parsed file this is
**22**, matching §3.1. Types: `TSmoothTile{tileName,tileIndex,prob}` (`:9-13`),
`TSmoothTileList{sumProb,tileCount,SmoothTile[0..15]}` (`:15-19`),
`TItem{tileListsCount,SmoothTiles[0..23]}` (`:21-24`),
`Items[0..63]` (`:26`), `atilemap[0..640][0..640]` (`:27`). Snapshot loop
`atilemap[i,j] := GetTileIndex(i,j)` (`:30-32`). Load loops `:35-60`: for each
Item `i`, each list `j`, each tile `k`: name (`:50`), index via
`MapGetTileIndexByTileBlock` (`:51`), prob (`:52`), `sumProb := sumProb+prob`
(`:53`), `SumProb := sumProb` (`:58`). **observed**, V1 re-read in full.

**Caveat (UNVERIFIED engine detail).** `var sumProb : Float;` (`:42`) and
`var tmp : Float;` (`:68`) are declared without an explicit `:= 0`. The
computed SumProb values in §3 assume the script runtime zero-initialises local
floats (near-certain for a Delphi-like DSL, but not provable from the text).
This does not change any authored Prob or tile name.

### 4.2 Roulette — `FindRandomTileIndex(i,j)` (`:63-80`)

```
Result := -1;                                    (:65)
sumProb := Items[i].SmoothTiles[j].SumProb;       (:66)
rnd := RandomExt * sumProb;                      (:67)
for k:=0..TileCount-1: tmp := tmp+Prob[k];       (:70-73)
   if (Prob[k]>0) and (rnd<tmp):                 (:74)
       Result := TileIndex[k]; exit;             (:76-77)
```

Two consequences (**derived**): (1) Prob=0 entries are unselectable;
(2) a SumProb=0 list always returns `-1`. `RandomExt` has **no definition in
the donor plaintext** (V2 scan of all `.script/.inc/.cfg/.lib/.global`: 0
assignments), and is used as a fresh uniform in e.g.
`scripts\lib\ai.script:2517-2518`; exact engine semantics are **UNVERIFIED**,
but "new random per occurrence" is the only consistent reading.

### 4.3 Reconcile — `GetNeighbourTiles(t1,t2)` (`:84-187`)

1. Resolve `tilename1/2` from the two tile indices (`:95-96`).
2. Scan every Item `i`, every active list `j`, every tile `k` (`:102-123`):
   `ind1/ind2 := j` whenever the name matches; `ind?ProbZero := (Prob=0)`
   (`:115,120`). Because match assigns rather than breaks, the **highest `j`
   wins** for duplicated names (§3.5).
3. `:124-125` is a no-op (`ind2ProbZero := ind2ProbZero`) for the rock5/rock2
   pair — literally no behaviour change.
4. Require `ind1<>ind2` (`:126`), both `>-1` (`:127`), and minimal
   `Abs(ind1-ind2)` (`:128-136`); store `i1,i2,ilist`. If no list contains both
   names, `ilist=-1` → no change (`:182-186`).
5. Cases (`:139-181`):

| Condition (donor lines) | Action | Reading |
|---|---|---|
| `Abs(i1-i2)=1` **and** `(not i1ProbZero) or (not i2ProbZero)` (`:142-156`) | `outtile1=-1; outtile2=-1` | adjacent lists compatible **unless both matched entries are Prob=0**; the commented rewrite block `:144-151` is dead |
| `i1-i2=2` (`:159-163`) | `outtile1 := FindRandomTileIndex(ilist,(i1+i2) div 2)`; `outtile2=-1` | replace the tile in the **higher-J** list with a weighted pick from the midpoint list `i1-1` |
| `i2-i1=2` (`:165-169`) | `outtile2 := FindRandomTileIndex(ilist,(i1+i2) div 2)`; `outtile1=-1` | symmetric |
| `i1<i2`, otherwise (`:171-175`) | `outtile2 := FindRandomTileIndex(ilist,i1+1)`; `outtile1=-1` | Δ>2: pull the higher-J tile **one step down** toward the other |
| else (`i1>i2`, `:176-180`) | `outtile1 := FindRandomTileIndex(ilist,i2+1)`; `outtile2=-1` | symmetric |

**Corrections to DTRN-01 §4** (`:240-246`): DTRN's "|Δ|=1 unchanged" omitted
the probzero guard at `:142`; its "midpoint list" is `(i1+i2) div 2`, which for
Δ=2 equals the lower J + 1; and the "pull one step" rule applies only to Δ>2
(after the two Δ=2 cases fail). All of the above are **observed** lines with
**derived** consequences; labels stated per row.

Worked donor example (**derived**): Item 0, `sandsea5` (J=1) next to `rock1`
(J=3): Δ=2 ⇒ midpoint J=2 = `rock9/rock8/rock5` all Prob=0 ⇒ roulette returns
`-1` ⇒ **no rewrite** — the zero list is a genuine hard separator (§3.5).

### 4.4 Pass structure and final call (`:191-243`)

```
procedure SmoothTileMap(mini,minj,maxi,maxj,passes)
  for k := 0 to passes-1:                    (:197)
     for i := mini to maxi-1:                (:200)
     for j := minj to maxj:                  (:201)
        t1=atilemap[i,j]; t2=atilemap[i+1,j] (:203-204)
        if t1<>t2:                            (:205)
           GetNeighbourTiles(t1,t2,...)       (:207)
           if change1>-1: atilemap[i,j]:=...  (:209-210)
           if change2>-1: atilemap[i+1,j]:=.. (:212-213)
     for j := minj to maxj-1:                (:218)
     for i := mini to maxi:                  (:219)
        t1=atilemap[i,j]; t2=atilemap[i,j+1] (:221-222)
        ... same guard/reconcile/write ...   (:223-231)
SmoothTileMap(0,0,GetMapWidth,GetMapHeight,3); (:237)
for j:=0..H-1; for i:=0..W-1: SetTileIndex(i,j,atilemap[i,j]); (:240-242)
```

Precise loop order (**observed**): within each pass the **horizontal** sweep
runs first with `i` as outer loop and `j` inner (`:200-201`, pair
`(i,j)-(i+1,j)`); then the **vertical** sweep with `j` outer and `i` inner
(`:218-219`, pair `(i,j)-(i,j+1)`). DTRN-01's "horizontal (i) then vertical
(j)" (`:123`) is correct at sweep level but imprecise about nesting. There are
**3 passes**, hard-coded at `:237`, and identical tiles are skipped (`:205,:223`).
Changes are written immediately into `atilemap`, then flushed to
`SetTileIndex` (`:240-242`). **observed**, V1.

### 4.5 Editor `TileSmoothPasses=6` vs runtime `3`

`gen\globalparams.cfg:9` says `TileSmoothPasses = 6` and `:10`
`TileSmoothListFileName = .\data\gen\tilesmooth.cfg`. That file is a *different*
config: 8 separate `section` blocks, each a `SmoothTiles` list of 3–4
**`TileName` only — no `Prob`** (`tilesmooth.cfg:2-12,15-27,…,114-129`). A V2
scan finds `TileSmoothPasses` / `TileSmoothListFileName` / `tilesmooth.cfg`
**only** in `globalparams.cfg` (1 hit each) and `MapGeneratorSmoothTiles` only
as a commented line at `generatemap.inc:784`. Therefore:

- **observed:** two distinct configurations exist — editor `tilesmooth.cfg`
  (8 unweighted lists, 30 `TileName` entries, 6 passes) and generator `tilesmooth_scripts.cfg`
  (22 weighted Items, 3 passes).
- **derived:** the editor value cannot be the skirmish path: the skirmish call
  site `ExecuteState('SmoothTiles')` (`generatemap.inc:781-789`) leads to the
  script that hardcodes `3` (`smoothtiles.inc:237`) and loads the weighted file
  (`:5`). The 6-pass setting is consumed by editor/binary code, not by any
  readable plaintext script. Whether the editor actually applies six passes is
  **UNVERIFIED** (engine side). DTRN-01 §5.1 `:299` already recorded the
  discrepancy; this pass explains it.

### 4.6 Donor *intent* vs verified *runtime activity*

A V2 scan of `smoothtiles.inc`, `texturemap.inc`,
`loadtextureterrainfrombitmap.inc` and `generatemap.inc` finds **zero**
uncommented code-like lines: every executable line is stored as
`[*] = ;<code>` (e.g. `smoothtiles.inc:4-6`, `texturemap.inc:415-416`,
`loadtextureterrainfrombitmap.inc:6-9`, `generatemap.inc:781-789`). Therefore
all algorithms in §4 and §5 are **donor intent as authored text**, not proven
activity in the shipped build. DTRN-01 §8 Q9 (`DTRN_01…:509-512`) already noted
this; this pass confirms it independently. The *config file* is passive data —
its weights are real bytes, but the consumer script is commented.

---

## 5. Shore / rock / road verification (`texturemap.inc`)

### 5.1 Constants and gates

`cMaxHeight=2.96`, `cWaterHeight=-0.25`, `cWaterShoreHeight=-0.1`
(`texturemap.inc:29-31`); `cTextureTerrain=True` (`:38`), `cPlaceRoads=True`
(`:39`). Water/shore tagging is **only** inside `gMapMask[ix,iy].b>0`
(`:464`): `height < -0.25` ⇒ `bWater` (`:466-467`), else `height < -0.1` ⇒
`bWaterShore` (`:469-470`). The earlier identical test at `:427-432` is wrapped
in `{...}` and is dead. **observed**.

### 5.2 Aspect → sector → `sandseaN` (`:433-529`)

`lh,rh,th,bh` from four neighbours (`:433-436`); `dirX=lh-rh`, `dirY=th-bh`
(`:438-439`), normalised only when `len>0.01` (`:441-444`);
`vecangle := VectorAngle(1,0,0,dirX,0,dirY)` (`:445`), negated when `dirY<0`
(`:446-447`); `+180` at `:476`. Quantisation uses `cAngle=45` and eight
half-open bands `k*45 ± 22.5` (`:479-499`), with `bRT` as the final else
(`:500-501`). Sector → tile (`:504-511`):

| Sector flag | Active tile | Commented alternative |
|---|---|---|
| `bLB` | `sandsea5` | `sandsea4` (`:504`) |
| `bRB` | `sandsea6` | `sandsea3` (`:505`) |
| `bB` | `sandsea1` | — (`:506`) |
| `bL` | `sandsea6` | `sandsea2` (`:507`) |
| `bR` | `sandsea6` | `sandsea2` (`:508`) |
| `bT` | `sandsea1` | — (`:509`) |
| `bRT` | `sandsea5` | `sandsea4` (`:510`) |
| `bLT` | `sandsea6` | `sandsea3` (`:511`) |

Assignments are sequential `if`s, so later flags overwrite earlier ones.
Winter suffix at `:525-526`; index via `MapGetTileIndexByTileBlock` at `:527`;
`SetTileIndex(x,y,newtex)` at `:528`. The height overrides `|h|>2.7→rock8`,
`>2.4→rock4` inside this shore branch are **commented out** (`:514-519`).
**observed**, V1.

### 5.3 Rock / cliff tiles (`:557-611`)

Gate: `x=GetMapWidth` **or** `y=GetMapHeight` **or**
`GetMapCollisionTagInRadius(realx,realy,0,False)>0` (`:557`). Aspect uses a
*different* band scheme here (`:560-575`): `30±7.5`→`bRB`, `120..150+20`→`bLB`,
`±45`→`bR`, `45..135`→`bB`, `-135..-45`→`bT`, else `bL`. Tile map
(`:578-591`): `bLB→rock7` (`:578`), `bB→rock1` (`:580`), `bL→rock3` (`:581`),
`bR→rock4` (`:583`), `bT→rock4` (`:590`), `bRB→rock4` (`:591`). Commented
alternatives: `bRB→rock6` (`:579`), `bR→rock2` (`:582`) and a whole random
block (`:584-589`). Active height overrides: `Abs(height)>2.7 → rock8`
(`:594-595`), `>2.4 → rock4` (`:597-598`), `<0.1 → ''` (i.e. no tile,
`:600-601`). Winter suffix (`:605-606`), index/write (`:607-608`). **observed**.

### 5.4 Roads (`:617-646`)

```
if gMapMask[x,y].broad then                       (:622)
   if RandomExt > 0.5   then newtile := 'ground1' (:627-628)
   else if RandomExt > 0.25 then newtile := 'test2' (:633-634)
   else newtile := 'test3';                       (:636)
   winter suffix (:639-640); MapGetTileIndexByTileBlock (:641);
   SetTileIndex (:642)
```

The commented `sand7` alternative is at `:630-632`. **Important correction:**
`:627` and `:633` are **two separate `RandomExt` evaluations**, so with an
independent uniform per call (**inferred** from usage at
`scripts\lib\ai.script:2517-2518`, engine semantics UNVERIFIED):

| Tile | Probability | Derivation |
|---|---:|---|
| `ground1` | **0.5** | first test passes |
| `test2` | **0.375** | `0.5 × 0.75` (first fails, second >0.25) |
| `test3` | **0.125** | `0.5 × 0.25` |

DTRN-01 C14/§4/§5.1 (`:128,221,296`) and `TERRAIN_DONOR_PIPELINE.md:135,375`
state 0.5/0.25/0.25; those are **corrected** here. (Cf. §6.)

### 5.5 Base tile from bitmap (`loadtextureterrainfrombitmap.inc`)

`cLowHeight=0.1` (`:4`); loads `gen\bitmap\ext\tile_lowground.bmp` /
`tile_highground.bmp` (`:8-9`); loops `y:=0..Min(H,height)`, `x:=0..Min(W,width)`
(`:18-19`); `h<cLowHeight` picks low bitmap, else high (`:26-29`);
`r=floor(fr*255)` (`:33`), `tex := r div 2` (`:36`); applies only where
`GetTileIndex(x,y)=0` and `MapGetTileBlockByTileIndex(tex)<>''` (`:37-41`).
All lines `;`-commented (V2 scan: 0 active code lines) → **donor intent, not
verified runtime activity**. **observed**.

---

## 6. Corrections to prior reports

| # | Prior statement | Corrected statement | Evidence / label |
|---:|---|---|---|
| 1 | Roads `ground1`/`test2`/`test3` at p=0.5/0.25/0.25 — DTRN-01 `:128,221,296`; `TERRAIN_DONOR_PIPELINE.md:135,375` | 0.5 / **0.375 / 0.125** (two `RandomExt` calls) | `texturemap.inc:627,633`; **derived** (fresh-random semantics **inferred**) |
| 2 | `Items[64]` rules — DTRN-01 `:231` | 64 is array bound; actually **22 Items** | `smoothtiles.inc:26` vs config `:3…:1810`; **observed+derived** |
| 3 | "builds 64 probability tables" — `TERRAIN_DONOR_PIPELINE.md:78` | 22 Items → **118 active lists** (12 commented) | §3.1; **derived** |
| 4 | "|Δ|=1 unchanged" — DTRN-01 `:243` | unchanged only if `not i1ProbZero or not i2ProbZero`; if both matched entries have Prob=0 it falls through to the pull case | `smoothtiles.inc:142,157-180`; **derived** |
| 5 | "list indices i1,i2" read as positions inside `TileNames` — implicit in DTRN-01 `:231-245` | J = index of the active **rule list** inside one Item; commented lists do not consume J; highest J wins for duplicate names | `smoothtiles.inc:108-135`; §3.1/§3.5; **observed+derived** |
| 6 | "some lists have Prob=0 (hard separator)" — DTRN-01 `:124` | Precise: 8 active Prob=0 entries in 4 lists; only 2 lists are wholly zero (Items 0/11 J=2); two lists merely contain a zero position-only tile | config `:55,59,63,742,985,989,993,1672`; **observed** |
| 7 | (not previously reported) | `grass_ground*` SumProb is 1.0028 in 6 lists (`0.64/0.0028/0.36`) but 1.0 in 2 (`0.36/0.28/0.36`); six `//Prob = 0.36` alternatives precede live `0.64` | `:451-460,572-580,681-689,1381-1390,1502-1510,1611-1619` vs `:798-810,1728-1740`; **observed** |
| 8 | "cfg contents not read" — `TERRAIN_DONOR_PIPELINE.md:413-414` (Q4); Q5 in DTRN-01 `:501-503` | Both resolved: complete inventory §3, machine-readable §7 | this report; **derived** |
| 9 | E33 weights "from `:1-35`" — `TERRAIN2_01…:64` | Correct but only covers Item 0 J=0/J=1; 116 further active lists inventoried here | §3.4; **derived** |
| 10 | Scripts described as executing — implicit in all three prior reports' pseudocode | Every code line in the four `.inc` files is `;`-commented; donor **intent**, runtime activity **UNVERIFIED** | V2 scan; `smoothtiles.inc:4-6`, `texturemap.inc:415-416`; **observed** |

No correction was needed to DTRN-01 C12/C13's shore/rock sector→tile tables:
`:504-511` and `:578-591` match them exactly (including `RB→rock4`).

---

## 7. Machine-readable summary table of rules (for the mapgen owner)

One row per **active** `SmoothTiles` list (118 rows). `Item` selects which of
the 22 `TileSmoothLists[*]` blocks to use (season pair: 0–10 Summer, 11–21
Winter); `J` is the compatibility index compared by `GetNeighbourTiles`;
`cfg line` locates the source for audit. `SumProb` is the roulette denominator
(`FindRandomTileIndex`). Prob=0 entries are position-only, never selected.
Rows are complete: every one of the 282 active `TileName:Prob` triples appears.

| Item | J | cfg line | TileName:Prob pairs | SumProb |
|---:|---:|---:|---|---:|
| 0 | 0 | 5 | sandsea1:1, sandsea2:1, sandsea3:1, sandsea4:1 | 4 |
| 0 | 1 | 25 | sandsea5:0.7, sandsea6:0.3 | 1 |
| 0 | 2 | 51 | rock9:0.0, rock8:0.0, rock5:0.0 | 0 |
| 0 | 3 | 67 | rock1:0.16, rock2:0.16, rock3:0.16, rock6:0.16, rock7:0.16, rock4:0.20 | 1 |
| 1 | 0 | 99 | sandsea1:1, sandsea2:1, sandsea3:1, sandsea4:1 | 4 |
| 1 | 1 | 119 | sandsea5:0.7, sandsea6:0.3 | 1 |
| 1 | 2 | 131 | sandrock1:0.4, sandrock3:0.6 | 1 |
| 1 | 3 | 143 | sandrock4:0.6, sandrock2:0.4 | 1 |
| 1 | 4 | 155 | grass1:1, grass2:1, test8:1 | 3 |
| 1 | 5 | 171 | grass7:0.25, test12:0.25, test13:0.25, test14:0.25 | 1 |
| 2 | 0 | 195 | sandsea1:1, sandsea2:1, sandsea3:1, sandsea4:1 | 4 |
| 2 | 1 | 215 | sandsea5:0.7, sandsea6:0.3 | 1 |
| 2 | 2 | 227 | sandrock1:0.4, sandrock3:0.6 | 1 |
| 2 | 3 | 239 | sandrock4:0.6, sandrock2:0.4 | 1 |
| 2 | 4 | 251 | grass1:1, grass2:1, test8:1 | 3 |
| 2 | 5 | 267 | test7:1, grass8:1, test6:1 | 3 |
| 3 | 0 | 287 | sandsea1:1, sandsea2:1, sandsea3:1, sandsea4:1 | 4 |
| 3 | 1 | 307 | sandsea5:0.7, sandsea6:0.3 | 1 |
| 3 | 2 | 319 | sandrock1:0.4, sandrock3:0.6 | 1 |
| 3 | 3 | 331 | sandrock4:0.6, sandrock2:0.4 | 1 |
| 3 | 4 | 343 | grass1:1, grass2:1, test8:1 | 3 |
| 3 | 5 | 359 | grass9:1 | 1 |
| 3 | 6 | 367 | test9:1 | 1 |
| 3 | 7 | 375 | grass3:1 | 1 |
| 3 | 8 | 383 | grass4:0.9, grass10:0.1 | 1 |
| 4 | 0 | 399 | rock1:0.16, rock2:0.16, rock3:0.16, rock6:0.16, rock7:0.16, rock4:0.20 | 1 |
| 4 | 1 | 427 | rock8:0.5, rock5:0.5 | 1 |
| 4 | 2 | 439 | rock9:1 | 1 |
| 4 | 3 | 447 | grass_ground1:0.64, grass_ground2:0.0028, grass_ground3:0.36 | 1.0028 |
| 4 | 4 | 464 | grass1:1, grass2:1, test8:1 | 3 |
| 4 | 5 | 480 | grass9:1 | 1 |
| 4 | 6 | 488 | test9:1 | 1 |
| 4 | 7 | 496 | grass3:1 | 1 |
| 4 | 8 | 504 | grass4:0.9, grass10:0.1 | 1 |
| 5 | 0 | 520 | rock1:0.16, rock2:0.16, rock3:0.16, rock6:0.16, rock7:0.16, rock4:0.20 | 1 |
| 5 | 1 | 548 | rock8:0.5, rock5:0.5 | 1 |
| 5 | 2 | 560 | rock9:1 | 1 |
| 5 | 3 | 568 | grass_ground1:0.64, grass_ground2:0.0028, grass_ground3:0.36 | 1.0028 |
| 5 | 4 | 585 | grass1:1, grass2:1, test8:1 | 3 |
| 5 | 5 | 601 | test7:1 | 1 |
| 5 | 6 | 609 | grass8:1 | 1 |
| 5 | 7 | 617 | test6:1 | 1 |
| 6 | 0 | 629 | rock1:0.16, rock2:0.16, rock3:0.16, rock6:0.16, rock7:0.16, rock4:0.20 | 1 |
| 6 | 1 | 657 | rock8:0.5, rock5:0.5 | 1 |
| 6 | 2 | 669 | rock9:1 | 1 |
| 6 | 3 | 677 | grass_ground1:0.64, grass_ground2:0.0028, grass_ground3:0.36 | 1.0028 |
| 6 | 4 | 694 | grass1:1, grass2:1, test8:1 | 3 |
| 6 | 5 | 710 | grass7:0.25, test12:0.25, test13:0.25, test14:0.25 | 1 |
| 7 | 0 | 734 | rock9:1, test8:0 | 1 |
| 7 | 1 | 762 | grass5:1 | 1 |
| 7 | 2 | 770 | grass6:1 | 1 |
| 8 | 0 | 782 | rock9:1 | 1 |
| 8 | 1 | 790 | grass5:1 | 1 |
| 8 | 2 | 798 | grass_ground1:0.36, grass_ground2:0.28, grass_ground3:0.36 | 1 |
| 9 | 0 | 818 | ground1:1 | 1 |
| 9 | 1 | 826 | test2:1 | 1 |
| 9 | 2 | 834 | test1:1, test3:1 | 2 |
| 9 | 3 | 846 | test8:0.4, test7:0.6 | 1 |
| 9 | 4 | 862 | grass1:1, grass2:1, test8:1 | 3 |
| 11 | 0 | 935 | sandsea1_winter:1, sandsea2_winter:1, sandsea3_winter:1, sandsea4_winter:1 | 4 |
| 11 | 1 | 955 | sandsea5_winter:0.7, sandsea6_winter:0.3 | 1 |
| 11 | 2 | 981 | rock9_winter:0.0, rock8_winter:0.0, rock5_winter:0.0 | 0 |
| 11 | 3 | 997 | rock1_winter:0.16, rock2_winter:0.16, rock3_winter:0.16, rock6_winter:0.16, rock7_winter:0.16, rock4_winter:0.20 | 1 |
| 12 | 0 | 1029 | sandsea1_winter:1, sandsea2_winter:1, sandsea3_winter:1, sandsea4_winter:1 | 4 |
| 12 | 1 | 1049 | sandsea5_winter:0.7, sandsea6_winter:0.3 | 1 |
| 12 | 2 | 1061 | sandrock1_winter:0.4, sandrock3_winter:0.6 | 1 |
| 12 | 3 | 1073 | sandrock4_winter:0.6, sandrock2_winter:0.4 | 1 |
| 12 | 4 | 1085 | grass1_winter:1, grass2_winter:1, test8_winter:1 | 3 |
| 12 | 5 | 1101 | grass7_winter:0.25, test12_winter:0.25, test13_winter:0.25, test14_winter:0.25 | 1 |
| 13 | 0 | 1125 | sandsea1_winter:1, sandsea2_winter:1, sandsea3_winter:1, sandsea4_winter:1 | 4 |
| 13 | 1 | 1145 | sandsea5_winter:0.7, sandsea6_winter:0.3 | 1 |
| 13 | 2 | 1157 | sandrock1_winter:0.4, sandrock3_winter:0.6 | 1 |
| 13 | 3 | 1169 | sandrock4_winter:0.6, sandrock2_winter:0.4 | 1 |
| 13 | 4 | 1181 | grass1_winter:1, grass2_winter:1, test8_winter:1 | 3 |
| 13 | 5 | 1197 | test7_winter:1, grass8_winter:1, test6_winter:1 | 3 |
| 14 | 0 | 1217 | sandsea1_winter:1, sandsea2_winter:1, sandsea3_winter:1, sandsea4_winter:1 | 4 |
| 14 | 1 | 1237 | sandsea5_winter:0.7, sandsea6_winter:0.3 | 1 |
| 14 | 2 | 1249 | sandrock1_winter:0.4, sandrock3_winter:0.6 | 1 |
| 14 | 3 | 1261 | sandrock4_winter:0.6, sandrock2_winter:0.4 | 1 |
| 14 | 4 | 1273 | grass1_winter:1, grass2_winter:1, test8_winter:1 | 3 |
| 14 | 5 | 1289 | grass9_winter:1 | 1 |
| 14 | 6 | 1297 | test9_winter:1 | 1 |
| 14 | 7 | 1305 | grass3_winter:1 | 1 |
| 14 | 8 | 1313 | grass4_winter:0.9, grass10_winter:0.1 | 1 |
| 15 | 0 | 1329 | rock1_winter:0.16, rock2_winter:0.16, rock3_winter:0.16, rock6_winter:0.16, rock7_winter:0.16, rock4_winter:0.20 | 1 |
| 15 | 1 | 1357 | rock8_winter:0.5, rock5_winter:0.5 | 1 |
| 15 | 2 | 1369 | rock9_winter:1 | 1 |
| 15 | 3 | 1377 | grass_ground1_winter:0.64, grass_ground2_winter:0.0028, grass_ground3_winter:0.36 | 1.0028 |
| 15 | 4 | 1394 | grass1_winter:1, grass2_winter:1, test8_winter:1 | 3 |
| 15 | 5 | 1410 | grass9_winter:1 | 1 |
| 15 | 6 | 1418 | test9_winter:1 | 1 |
| 15 | 7 | 1426 | grass3_winter:1 | 1 |
| 15 | 8 | 1434 | grass4_winter:0.9, grass10_winter:0.1 | 1 |
| 16 | 0 | 1450 | rock1_winter:0.16, rock2_winter:0.16, rock3_winter:0.16, rock6_winter:0.16, rock7_winter:0.16, rock4_winter:0.20 | 1 |
| 16 | 1 | 1478 | rock8_winter:0.5, rock5_winter:0.5 | 1 |
| 16 | 2 | 1490 | rock9_winter:1 | 1 |
| 16 | 3 | 1498 | grass_ground1_winter:0.64, grass_ground2_winter:0.0028, grass_ground3_winter:0.36 | 1.0028 |
| 16 | 4 | 1515 | grass1_winter:1, grass2_winter:1, test8_winter:1 | 3 |
| 16 | 5 | 1531 | test7_winter:1 | 1 |
| 16 | 6 | 1539 | grass8_winter:1 | 1 |
| 16 | 7 | 1547 | test6_winter:1 | 1 |
| 17 | 0 | 1559 | rock1_winter:0.16, rock2_winter:0.16, rock3_winter:0.16, rock6_winter:0.16, rock7_winter:0.16, rock4_winter:0.20 | 1 |
| 17 | 1 | 1587 | rock8_winter:0.5, rock5_winter:0.5 | 1 |
| 17 | 2 | 1599 | rock9_winter:1 | 1 |
| 17 | 3 | 1607 | grass_ground1_winter:0.64, grass_ground2_winter:0.0028, grass_ground3_winter:0.36 | 1.0028 |
| 17 | 4 | 1624 | grass1_winter:1, grass2_winter:1, test8_winter:1 | 3 |
| 17 | 5 | 1640 | grass7_winter:0.25, test12_winter:0.25, test13_winter:0.25, test14_winter:0.25 | 1 |
| 18 | 0 | 1664 | rock9_winter:1, test8_winter:0 | 1 |
| 18 | 1 | 1692 | grass5_winter:1 | 1 |
| 18 | 2 | 1700 | grass6_winter:1 | 1 |
| 19 | 0 | 1712 | rock9_winter:1 | 1 |
| 19 | 1 | 1720 | grass5_winter:1 | 1 |
| 19 | 2 | 1728 | grass_ground1_winter:0.36, grass_ground2_winter:0.28, grass_ground3_winter:0.36 | 1 |
| 20 | 0 | 1748 | ground1_winter:1 | 1 |
| 20 | 1 | 1756 | test2_winter:1 | 1 |
| 20 | 2 | 1764 | test1_winter:1, test3_winter:1 | 2 |
| 20 | 3 | 1776 | test8_winter:0.4, test7_winter:0.6 | 1 |
| 20 | 4 | 1792 | grass1_winter:1, grass2_winter:1, test8_winter:1 | 3 |

---

## 8. Open questions (do not guess)

1. **Local-float initialisation.** `sumProb` (`smoothtiles.inc:42`) and `tmp`
   (`:68`) have no explicit `:= 0`. The engine's zero-init behaviour is
   **UNVERIFIED**; §3 SumProb values assume it.
2. **`RandomExt` exact semantics.** No definition exists in donor plaintext
   (V2 scan, 0 hits for assignment). Treated as a fresh uniform per call,
   **inferred** from `scripts\lib\ai.script:2517-2518` and similar. This is the
   only uncertainty in the road-probability correction (§5.4).
3. **Runtime activity of the `.inc` scripts.** All code lines are `;`-commented
   (§4.6). Which engine path, if any, executes an equivalent algorithm in the
   shipped build is **UNVERIFIED**; the config bytes and the authored algorithm
   are fully readable, but "the game does this" cannot be asserted.
4. **Item selection.** There are 11 Summer + 11 Winter Items (§3.1), but no
   plaintext statement selects `Items[i]` by season. `texturemap.inc:525-526,
   605-606,639-640` appends `_winter` to tile names, which implies the winter
   Item block, but the binding is **UNVERIFIED** (engine side).
5. **Editor 6-pass consumer.** `TileSmoothPasses` appears only in
   `globalparams.cfg:9`; the binary/editor code reading it is not in the
   plaintext tree. Whether six passes are actually performed is **UNVERIFIED**.
6. **Boundary safety.** `atilemap` is declared `[0..640]` (`smoothtiles.inc:27`)
   while a 640-cell grid is indexed `0..639`; the config-driven passes call
   `SmoothTileMap(0,0,GetMapWidth,GetMapHeight,3)` (`:237`) with `maxi=640` and
   read `atilemap[i+1,j]` / `[i,j+1]` (`:204,222`). Whether this is intentional
   slack or a benign over-allocation is **UNVERIFIED**.
7. **Zero-list roulette.** With SumProb=0, `FindRandomTileIndex` returns `-1`
   (`:65,74`); this makes the J=2 all-zero lists hard separators in Item 0/11
   (§3.5). Confirming the intended artistic effect requires a GPU A/B — not
   done, no visual parity claimed.
8. **`grass_ground` SumProb anomaly** (1.0028 vs 1.0, §6 #7). Whether the
   `0.0028` is a typo for `0.28` is author intent, not provable. For
   donor-faithful porting, reproduce the literal active value (`0.64`,
   `0.0028`) — do not normalise silently.
9. **Duplicate-name last-match rule.** `test8` appears in two active lists of
   Item 9/20 (§3.5). The loop overwrites `ind` (`:112-121`), so higher J wins;
   this is a control-flow consequence, but whether the author intended it is
   **inferred**.

---

## 9. Summary

- `gen\tilesmooth_scripts.cfg` was parsed **in full**: 1,864/1,864 lines,
  balanced 615/615 `struct` pairs, **1 section, 1 `TileSmoothLists`, 22 Items,
  130 lists (118 active + 12 commented), 310 `TileName` entries (282 active +
  28 commented), 320 `Prob` lines (282 active + 38 commented)**. All 86 distinct
  active tile names resolve in `terrain.presets`. (§3, **observed + derived**,
  V1+V2.)
- The compatibility ordering is the **active list index J within an Item**, not
  the position inside `TileNames`; commented lists do not occupy J. Items 0–10
  are Summer, 11–21 Winter. (§3.1, **derived**.)
- Eight active `Prob=0` entries exist in four lists; only Items 0/11 J=2 are
  wholly zero and act as hard separators because roulette over SumProb=0
  returns `-1`. (§3.5, **observed + derived**.)
- `smoothtiles.inc` implements a snapshot → weighted load → 3-pass
  horizontal-then-vertical neighbour reconciliation → writeback. `|Δ|=1` is
  compatible unless both entries are Prob=0; `Δ=2` replaces the higher-J tile
  from the midpoint list; larger gaps pull it one step down; no shared list ⇒
  no change. Final call is `SmoothTileMap(0,0,W,H,3)` (`:237`). (§4, **observed**.)
- The editor's `TileSmoothPasses=6` / `tilesmooth.cfg` (8 unweighted lists) is a
  **separate editor-side configuration**; no plaintext consumer exists. The
  generator script hardcodes 3 passes and the weighted file. (§4.5, **observed**
  + **UNVERIFIED** for actual editor execution.)
- Shore selection is 8 sectors × 45° → `sandsea1/5/6` (`:504-511`); rock is
  edge/collision-gated 6-sector map → `rock1/3/4/7` with `|h|>2.7→rock8`,
  `>2.4→rock4`, `<0.1→none` (`:578-601`); roads are `ground1` 0.5 / `test2`
  0.375 / `test3` 0.125 from two `RandomExt` calls (`:627,633`). All are
  **donor intent**: every code line in these `.inc` files is `;`-commented, so
  runtime activity is **UNVERIFIED**. (§5.)
- Ten corrections were recorded, chiefly the road probabilities, the 64-vs-22
  Item count, the J semantics, and the Prob=0 detail. DTRN-01 Q4/Q5 are now
  resolved. (§6.)

The mapgen owner can translate §7's 118 rows directly: for each season choose
the corresponding Item block, map each `TileName:Prob` to the donor tile index
via `terrain.presets`, use `SumProb` as the roulette denominator, compare `J`
values with the §4.3 case table, and preserve the literal `0.0028`/`0.64`
anomaly rather than normalising it. No port file was changed; no donor asset
was copied or executed; visual parity is not claimed.

*End of RV-TRN-02. One report written. No code, asset, config, test, runner job
or git state changed.*
