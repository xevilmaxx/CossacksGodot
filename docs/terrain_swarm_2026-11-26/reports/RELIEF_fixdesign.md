---
id: RELIEF-FIXDESIGN
ticket: "TERRAIN-SWARM-2026-11-26 / RELIEF_fixdesign (worker RELIEF-FIXDESIGN)"
date: 2026-11-27
status: DELIVERED__ONE_REPORT_ONLY__READ_ONLY__NO_SOURCE_NO_GIT_NO_GODOT
scope: "Exactly one repo file written: this report. No source/asset/config/test/shader/queue/git/Godot state changed. No donor binary executed, copied, or installed. All numbers below are read-only recomputations over repo-landed files."
labels: [O, D, U, "PORT APPROXIMATION"]
parity_claim: false
parity_guard: "No donor GPU A/B frame exists. Every grid comparison below is static numeric observation. No parity claim."
chain: "0/6"
result: "RESULT IS NOT GOOD"
---

# RELIEF_fixdesign — are the hardcoded 8×10 grids the corrected windows or the stale shifted windows, and what is the donor-faithful replacement

## 0. Verdict up front

1. **[O]+[D] The hardcoded tables are the STALE shifted windows, not the corrected windows.** `variant3d/scripts/game.gd:133-152` reproduces `DPATTERN_01` Appendix A1/A2 (`G=2866` / `G=2266`) with **max absolute difference 0.0** on all 80 cells for both patterns (§2, computation C2). Against the block means recomputed read-only from the repo-landed full grids (`variant3d/assets/terrain_new/patterns/plt2.json`, grid `G=2222`, `42×55`; `k_ravine_1.json`, `G=2798`, `46×63`), the same hardcoded tables differ by **MAE 1.04388 / 1.15354, max 3.215 / 2.947, 63/80 and 67/80 cells > 0.05** (§2, computation C1) — exactly the X23 §5 stale-vs-corrected diff row.
2. **[O]+[D] The repo-landed full grids reproduce the X23 corrected tables exactly.** Recomputing 8×10 integer-floor-band block means from `relief_float_grid` gives X23 §4.2 (`plt2`) and §4.1 (`k_ravine_1`) with **max difference 0.0 at 3 dp** (§2, computation C3). Method: X23 §4 header — row band `[j*h/8,(j+1)*h/8)`, column band `[i*w/10,(i+1)*w/10)`, integer floor, arithmetic mean.
3. **[D] Donor-faithful replacement is the FULL `w*h` float32 grids, not new 8×10 tables.** Swapping in the X23 corrected 8×10 tables + corrected offsets is only a Tier-A shape correction and stays a labelled PORT APPROXIMATION. The Tier-B (donor-faithful) change is: load `relief_float_grid` per pattern, sample it with per-pattern `w/h`, keep Min/Max/Scale/Offset from flags, and fix the sampler, meta, and ledger call sites named in §3. `k_ravine_1` stays BLOCKED (unreachable recipe); no new stamp is authorised by this report.
4. **[U] This is NOT donor-exact, then or now.** Even Tier B remains PORT APPROXIMATION until the owner evidence in §4 lands (loader struct, row-sign flip, blend/clamp order, smooth semantics, A/B frame). **No live generation change is authorised by this report.**

Parity: **UNVERIFIED**. Chain: **0/6**. **RESULT IS NOT GOOD.**

---

## 1. Inputs (all [O], read-only)

| # | Path:line | What it establishes |
|---|---|---|
| I1 | `variant3d/scripts/game.gd:123-132` | The two tables are "block MEANS decoded from the donor float32 height windows in DPATTERN_01 Appendix A1/A2 (:595-626)", "full windows are not in the port", "labelled PORT APPROXIMATION". Row-order/file-row→map-row sign UNVERIFIED (§9 Q3 in that file's comment). |
| I2 | `variant3d/scripts/game.gd:131-152` | `RELIEF_GRID_W := 10`, `RELIEF_GRID_H := 8`; `RELIEF_GRID_K_RAVINE_1` (80 values, :133-142); `RELIEF_GRID_PLT2` (80 values, :143-152). |
| I3 | `variant3d/scripts/game.gd:157-162` | `RELIEF_GRID_META`: `k_ravine_1` `w 46 h 63 offset 2866 lib pattern.lib:549585-549586`, min `-2.963627576828003`, max `3.139820098876953`; `plt2` `w 42 h 55 offset 2266 lib pattern.lib:6805-6806`, min `-0.07325489819049835`, max `3.6134116649627686`; both `scale 1.0`. |
| I4 | `variant3d/scripts/game.gd:1469-1485` | `func _sample_relief_grid(grid, u, v)`: bilinear sample over a fixed `10×8` table (`RELIEF_GRID_W-1`, `RELIEF_GRID_H-1` index math); row order = file order, row flip UNVERIFIED per its own comment. |
| I5 | `variant3d/scripts/game.gd:1488-1615` | `_shape_stamp_relief`: two-id name gate (`plt2` :1533-1535, `k_ravine_1` :1536-1538; `k_ravine_1` BLOCKED comment :1526-1529); grid path `h = clamp(h_base + grid*Scale, Min, Max)` with `Offset 0`, no Smooth (:1595-1615); `gu/gv` bbox mapping labelled PORT APPROXIMATION (:1600-1601); call `gv0 := _sample_relief_grid(donor_grid, gu, gv)` at :1607. |
| I6 | `variant3d/scripts/game.gd:1680-1690` | `map_meta["relief_grid"]` ledger: label PORT APPROXIMATION, `tables [k_ravine_1, plt2]`, `source DPATTERN_01 Appendix A1/A2 — 8x10 block means`, `blend h = clamp(h_base + donor8x10*HeightFieldScale, HeightFieldMin, HeightFieldMax)`, `row_flip UNVERIFIED`. |
| I7 | `variant3d/assets/terrain_new/patterns/plt2.json` | `name plt2`, `grid_offset 2222`, `w 42`, `h 55`, `relief_float_grid` length **2310** (= 42×55); `flags Min -0.0732548981904984 Max 3.61341166496277 Scale 1.0 Offset 0.0 Replace False ReplaceForWater True Smooth False Stand True`; `grid_layout h x w row-major f32 at G=8+(w-1)*(h-1)`; `byte_closure ok` (formula `8+4wh+54(w-1)(h-1)`, 128804 B); `source data\pattern\plt2.pattern sha256 26269592…`. |
| I8 | `variant3d/assets/terrain_new/patterns/k_ravine_1.json` | `name k_ravine_1`, path `variant3d/assets/terrain_new/patterns/k_ravine_1.json`, `grid_offset 2798`, `w 46`, `h 63`, `relief_float_grid` length **2898** (= 46×63); `flags Min -2.963627576828 Max 3.13982009887695 Scale 1.0 Offset 0 Replace False ReplaceForWater True Smooth False`; `byte_closure ok` (162260 B); `source data\pattern\k_ravine_1.pattern sha256 9a806a05…`. |
| I9 | `docs/coord_swarm_2026-11-25/reports/DPATTERN_01_relief_grids.md:595-626` | Appendix A construction (row `j` = file-row band, col `i` = file-col band, "debug/preview aids only — stamp from the full grid"); **A1 `k_ravine_1` (G=2866)** :602-613; **A2 `plt2` (G=2266)** :615-626. |
| I10 | `docs/terrain_swarm_2026-11-26/reports/X23_corrected_relief_grids.md:131-175` | Block-mean definition (§4 header) and corrected tables: §4.1 `k_ravine_1 G=2798`, §4.2 `plt2 G=2222` (both 8×10, 3 dp, float32 accumulator). |
| I11 | `X23 §5 table (:250-256)` + `ANOM_reliefgrid.md §4-5` | Old-vs-true `2866→2798 (+68 B = +17 cols)`, `2266→2222 (+44 B = +11 cols)`; old tables = shifted-window means with zero deviation; full windows already landed in repo JSONs at F01 offsets. |

Byte-shift note [D]: `2866 − 2798 = 68 B = 17 float32 columns`; `2266 − 2222 = 44 B = 11 float32 columns`. This matches X23 §5 exactly and is why edge block means move by up to ~3.2 height units while `pattern.lib` Min/Max still match (zero border runs, X23 §5 mechanism).

---

## 2. Byte-proven computations (read-only; [O]+[D])

Method [D]: all three computations below were run read-only with plain averaging over repo-landed arrays — `game.gd` constants extracted by regex (80 values per table), `relief_float_grid` from I7/I8, block means by the X23 §4 integer-floor-band rule. No file was written by the computation; no donor file was opened. Rounding: values compared at the published 3 dp; the float32-vs-double accumulator caveat (X23 §3 P6/P9, `hil1 (4,0)`) does not move any cell of these two patterns at 3 dp (C3 = 0.0).

### C1. Hardcoded `game.gd` tables vs block means of the repo full grids (corrected windows) — MISMATCH [D]

| Pattern | Hardcoded source | Reference (recomputed from repo full grid) | MAE | RMSE | Max abs diff (cell `j,i`) | Cells > 0.05 | Argmax detail |
|---|---|---|---|---|---|---|---|
| `plt2` | `game.gd:143-152` (80) | `plt2.json` 42×55 grid → 8×10 means | **1.04388** | **1.49831** | **3.215 at (3,5)** | **63/80** | hard `0.188` vs corrected `3.403185` |
| `k_ravine_1` | `game.gd:133-142` (80) | `k_ravine_1.json` 46×63 grid → 8×10 means | **1.15354** | **1.55982** | **2.947 at (2,0)** | **67/80** | hard `-2.947` vs corrected `-0.000018` |

These four numbers per row reproduce the X23 §5 diff row to all printed digits (`plt2`: MAE 1.04389 / RMSE 1.49833 / max 3.215 (3,5) / 63/80; `k_ravine_1`: MAE 1.15355 / RMSE 1.55986 / max 2.947 (2,0) / 67/80; residual 5th-decimal dust is print rounding). First-row spot values of the recomputed corrected means: `plt2` row 0 = `-0.000 -0.003 -0.003 0.056 0.055 0.053 0.011 -0.003 -0.002 -0.000` (equals X23 §4.2 row 0); `k_ravine_1` row 0 = `0.000 -0.000 -0.000 -0.002 -0.156 -0.320 -0.194 -0.018 -0.345 -1.454` (equals X23 §4.1 row 0).

### C2. Hardcoded `game.gd` tables vs DPATTERN Appendix stale windows — EXACT MATCH [D]

- `game.gd RELIEF_GRID_K_RAVINE_1` vs DPATTERN A1 (`G=2866`, I9 :605-612): **max abs diff 0.0** (80/80 cells).
- `game.gd RELIEF_GRID_PLT2` vs DPATTERN A2 (`G=2266`, I9 :618-625): **max abs diff 0.0** (80/80 cells).

So the live constants are bit-for-bit the stale shifted-window tables at the stale offsets `2866/2266` (I3), not the corrected `2798/2222` windows (I7/I8).

### C3. Recomputed corrected means vs X23 §4 corrected tables — EXACT MATCH [D]

- Recomputed `plt2` 8×10 means (from I7) vs X23 §4.2 table: **max abs diff 0.0** at 3 dp (80/80).
- Recomputed `k_ravine_1` 8×10 means (from I8) vs X23 §4.1 table: **max abs diff 0.0** at 3 dp (80/80).

This closes the loop: the repo full grids are the corrected windows; X23 §4 is their exact downsampling; `game.gd` matches neither — it matches the stale windows (C2) and contradicts the corrected windows (C1).

### Meta-field cross-check [O]+[D]

- `w/h` in `RELIEF_GRID_META` (I3) are correct for both ids (42×55, 46×63 — agree with I7/I8). No change needed there.
- `min/max/scale` in meta agree with the landed `flags` (I7/I8) to all printed digits (`plt2` Min `-0.07325489819049835`, Max `3.6134116649627686`; `k_ravine_1` Min `-2.963627576828003`, Max `3.139820098876953`; both `Scale 1.0`, `Offset 0`). No change needed there.
- `offset` in meta (**2266 / 2866**) is STALE; corrected values are **2222 / 2798** (I7/I8, X23 §4). This is the one meta field that must change under either tier (§3).

---

## 3. Donor-faithful replacement ([D] design; no code changed)

### 3.1 The answer: replace the 8×10 path with the full grids

The donor-faithful replacement is **NOT a third set of 8×10 numbers**. It is to stamp from the already-landed full `w*h` float32 `relief_float_grid` arrays (I7/I8; X23 §7 I02-2; DPATTERN Appendix header "stamp from the full grid, not from these means", I9):

- `plt2`: 2310-float window (`42×55`, `G=2222`), flags `Scale 1 Offset 0 ReplaceForWater True Smooth False` (I7).
- `k_ravine_1`: 2898-float window (`46×63`, `G=2798`), same flag shape (I8). Note it stays **BLOCKED / unreachable** (`game.gd:1528-1529`, ANOM §3): wiring its grid does not authorise a stamp.

Tier A (minimal, still an approximation — do only if a full-grid loader cannot land): substitute the X23 §4.1/§4.2 corrected 8×10 tables verbatim and flip meta offsets to `2798/2222`. This fixes the +17/+11-column spatial error but keeps every approximation listed in §4 (block-mean edge loss up to ~3.2 units is then *baked in correctly* rather than *shifted*, but still baked in).

### 3.2 Exact code changes required (Tier B; file/line pointers, no edit made)

1. **Data source.** Load `relief_float_grid` + `w/h` per pattern from `variant3d/assets/terrain_new/patterns/<name>.json` (schema `terrain_new.pattern_decode.v1`, I7/I8) into the stamp path, instead of the `RELIEF_GRID_PLT2 / RELIEF_GRID_K_RAVINE_1` constants (I2). Note the live loader gap: `pattern_gen.gd:58` reads the legacy `donor_patterns.json` (footprint `w/h/cells` only, no float window — ANOM §5 E20); the full grids are not currently visible at stamp time.
2. **Sampler** `game.gd:1469-1485` (`_sample_relief_grid`). Current form hardcodes the coarse geometry (`RELIEF_GRID_W/H = 10/8`, I4). Donor-faithful form indexes the **per-pattern full grid** (`w=42/46`, `h=55/63`) with `u,v ∈ 0..1` over the stamp footprint; interpolation kernel stays PORT APPROXIMATION until §4 evidence lands (donor bilinearity is UNVERIFIED). The fixed `const RELIEF_GRID_W/H` (I2) must stop governing relief sampling (remove or scope to the Tier-A fallback only).
3. **Call site** `game.gd:1605-1611`. `gu/gv` bbox mapping (:1605-1606) is labelled PORT APPROXIMATION (I5); keep the label. `donor_meta.get("scale"/"min"/"max")` + `clampf(h + gv0*scale, …)` stays structurally, with meta `min/max/scale` unchanged (correct per §2) and `offset` corrected to `2222/2798` (§2 meta check). `Offset` is `0` for both ids so no additive change; `Smooth` is `False` for both ids so no post-pass is modelled.
4. **Meta** `game.gd:157-162` (I3). Change only `offset`: `plt2 2266 → 2222`, `k_ravine_1 2866 → 2798`. Keep `w/h/min/max/scale/lib` (verified correct in §2). Under Tier B, meta gains a pointer to the full-grid asset per id (path + `grid_offset` + `w/h` already present in I7/I8).
5. **Ledger** `game.gd:1681-1690` (I6). Update `source` (no longer "DPATTERN_01 Appendix A1/A2 — 8x10 block means"), `tables`, `blend` (no longer "donor8x10"), and `row_flip` (still UNVERIFIED) lines to describe full-grid sampling; keep the PORT APPROXIMATION label and the `candidates/applied_cells` counters.
6. **Gate.** No gate expansion is authorised here: `k_ravine_1` remains BLOCKED; `hil1` (`G=968`), `g_hil4` (`G=1864`), `k_ravine_big_stone_1` (`G=8225`) full windows exist in the repo (ANOM §5) but have **no tables, no meta entries, and no recipe wiring** in `game.gd:1523-1540` — adding any of them needs a named owner and the §4 evidence, not this ticket.

### 3.3 What explicitly does NOT change

- `w/h/min/max/scale` values (verified correct, §2). `RELIEF_PLATEAU/HILL/RAVINE` analytic-fallback path (`game.gd:1541-1659`) is untouched by this ticket. No stamp footprint, mask, RNG, or tileblock logic is touched.

---

## 4. Donor-exact vs approximation, and owner evidence required ([U] register)

**Explicit statement: neither the current code nor Tier A nor Tier B (as specified above) is donor-exact. All three are PORT APPROXIMATION.** Tier B removes the proven spatial-window error (C1/C2) but does not promote the path to donor-exact. The following stay [U] (X23 §8 U1-U4/U6-U9; ANOM §8 U3; `game.gd` own labels I1/I4/I5/I6):

- **U1. Loader field semantics.** `G = 8+(w-1)(h-1)` is structurally derived (F01 710/710 closure + 5/5 bit-exact Min/Max, X23 E2-E8) but no loader struct/RTTI names the fields. Required: D01 RTTI/CODE lift naming the mask/plane/record fields.
- **U2. Row-sign flip.** File-row → world-y sign is UNVERIFIED (`game.gd:130,1472` I1/I4; ledger I6). Required: donor engine row-order evidence or A/B frame decision; until then any sign is a guess.
- **U3. Engine blend / clamp / Max use.** Current `h = clamp(h_base + g*Scale, Min, Max)` with `Max` unused-in-stamp per D05/X12 is accepted models only; x87 precision, rotation rounding, global clamp order, and post-pass update order are UNVERIFIED (X23 U3/U4/U7). Required: D05/X26 blend-formula owner sign-off at the corrected offsets (X13 vectors are stale per X23 §6 S5 — do NOT re-run a bit gate against them).
- **U4. Smooth post-pass.** `False` for these two ids (I7/I8) so unmodelled here; any future `Smooth=True` id (`hil1` False; `g_hil4`/`k_ravine_big_stone_1` True) needs the in-place vs double-buffer ruling (X23 §6 S7). Required: smooth-kernel owner ruling before wiring those ids.
- **U5. Extent/placement.** Stamp-footprint bbox mapping (I5 :1600-1601) is a port approximation; donor placement scale/rotation is UNVERIFIED. Required: placement-semantics evidence (X29 scope) before any silhouette claim.
- **U6. Visual parity.** No donor GPU A/B frame exists (CHARTER §3/§5). Required: owner-accepted A/B protocol; until then `parity.status = UNVERIFIED` stays mandatory and **no parity claim** may be attached to any relief change.

**Gate for any live generation change:** §3 Tier-B items 1-5 implemented + U1-U3 closed (or explicitly risk-accepted by named owners) + fresh full-grid blend vectors issued (X13-B, X23 §6 S5/S6) + `selftest/uitest` green with thresholds unchanged. This report authorises none of that; it is design only.

---

## 5. Evidence index (all [O] unless marked)

| # | Pointer | Class | What it establishes |
|---|---|---|---|
| E1 | `variant3d/scripts/game.gd:123-162` | [O] | Live 8×10 tables + stale meta offsets 2266/2866, labelled PORT APPROXIMATION |
| E2 | `variant3d/scripts/game.gd:1469-1485, 1605-1611, 1681-1690` | [O] | Fixed-10×8 bilinear sampler, bbox-mapped call site, stale-labelled ledger |
| E3 | `variant3d/assets/terrain_new/patterns/plt2.json` (`grid_offset 2222`, `w 42 h 55`, grid len 2310, flags) | [O] | Corrected full window + flag inputs |
| E4 | `variant3d/assets/terrain_new/patterns/k_ravine_1.json` (`grid_offset 2798`, `w 46 h 63`, grid len 2898, flags) | [O] | Corrected full window + flag inputs |
| E5 | DPATTERN_01 Appendix A1/A2 `:602-626` | [O] | Stale shifted windows at G=2866/2266 |
| E6 | X23 §4.1/§4.2 | [O]+[D] | Corrected 8×10 tables at G=2798/2222 + band-mean definition |
| E7 | X23 §5 diff table | [D] | Predicted MAE/RMSE/max/cells>0.05 reproduced by C1 |
| E8 | C1 recomputation (this report §2) | [D] | Hardcoded-vs-corrected: plt2 1.04388/1.49831/3.215 (3,5)/63; kr1 1.15354/1.55982/2.947 (2,0)/67 |
| E9 | C2 recomputation (this report §2) | [D] | Hardcoded-vs-DPATTERN-stale: 0.0 both |
| E10 | C3 recomputation (this report §2) | [D] | Repo-grid-means-vs-X23-corrected: 0.0 both |
| E11 | ANOM_reliefgrid §3-5 | [O]+[D] | `k_ravine_1` BLOCKED; full grids landed; legacy loader gap |

## 6. Open / UNVERIFIED

- U-a. Tail/prop/weight semantics of the pattern binaries (F01 §9; X23 U6) — untouched, not needed for the window verdict.
- U-b. Sibling-pattern Stand flags beyond the six proven in ANOM §1 — names only; no claim made here.
- U-c. Whether COORD wants Tier A as an interim commit or Tier B directly — builder decision; this ticket makes no change either way.
- U-d. Per-seed stamp census effects of any future correction — not derived here; any changed silhouette invalidates prior seed observations until re-scanned.

*End of RELIEF_fixdesign. Exactly one repo file written. Read-only; no code, no Godot, no git, no donor execution. Parity UNVERIFIED. Chain 0/6. RESULT IS NOT GOOD.*
