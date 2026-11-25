---
id: Y08
ticket: "URGENT Y08 — rank the causes of the new blocky light/dark checkerboard in the y04b real-map capture; propose the minimal data-only fix"
title: "Y08 — checkerboard squares are L01 spot ids acting through their per-id alpha patches, not the 2 m RGB repeat"
owner: Y08 (read-only analysis subagent)
created: 2026-11-25
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_RUNNER_JOB__NO_GODOT__NO_CODE_OR_ASSET_EDIT
scope: "This report is the ONLY repo file written. No runner job, no Godot process, no queue/lock/counter mutation, no .gd/.gdshader/asset/config/test/JSON/donor/git edit. Scratch PNGs and throwaway NumPy/Pillow arithmetic were written only under C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\y08\\ (outside the repo). No donor file was opened for an attribution claim."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, PORT APPROX]
parity_guard: "NO DONOR PARITY CLAIM. No donor GPU A/B frame exists (CHARTER §3/§5). Every visual expectation below is OBSERVED pixel measurement, DERIVED arithmetic or INFERRED attribution; none is a parity, equivalence or PASS claim."
image: "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\y04b\\realmap.png"
comparison_image: "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\y03\\realmap.png"
sources_read:
  - docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
  - docs/terrain_swarm_2026-11-25/CHARTER.md
  - docs/terrain_swarm_2026-11-25/reports/L01_spot_grass.md
  - docs/terrain_swarm_2026-11-25/reports/L01_impl.md
  - docs/terrain_swarm_2026-11-25/reports/A03_atlas_cells.md
  - docs/terrain_swarm_2026-11-25/reports/Y05_horizontal_banding.md
  - docs/terrain_swarm_2026-11-25/reports/Y04_remaining_rings.md
  - docs/terrain_swarm_2026-11-25/reports/Y04b_gate_log.md
  - docs/terrain_swarm_2026-11-25/reports/Y07_ring_survivors.md
  - variant3d/scripts/game.gd (:2008, :2130, :2134, :2313-2328, :2359-2493)
  - variant3d/shaders/terrain_tileindex.gdshader (:214, :311, :316, :329-337, :365-378, :388-427)
  - variant3d/scripts/world3d_terrain.gd (:662-675, :690-692)
  - variant3d/assets/terrain/atlas/alpha.png (read-only pixel decode)
  - variant3d/assets/terrain/blocks/{test8,grass9,grass5,test7,test9}.png (read-only pixel decode)
---

# Y08 — the blocky checkerboard in the y04b frame

> **Labels.** **OBSERVED** = a literal source line or a measurement made directly on the named
> PNG/PNG-decoded asset; **DERIVED** = arithmetic or control-flow consequence of OBSERVED
> facts; **INFERRED** = attribution with its caveat stated; **UNVERIFIED** = cannot be proved
> with the available instruments. No Godot was run and no runner job was submitted. Donor
> parity stays **UNVERIFIED**; no donor image was opened in this ticket.

---

## 0. Mandate and answer in one paragraph

COORD: the latest capture `...\y04b\realmap.png` shows blocky light/dark squares across the
field; decide whether they come from (a) L01's spot ids with different atlas-cell brightness,
(b) the 2 m atlas-cell repeat / UV2 lookup, (c) the per-id alpha patch, or (d) tile smoothing;
give a ranked verdict and the minimal fix that keeps organic variation, does not reintroduce
maze/banding and does not violate S-25-09.

**Answer:** the checkerboard is **one coupled mechanism, not four independent ones**. L01's
spot pass (a) is the **spatial trigger** — it repaints meadow cells inside forest-stamp cores
with `grass9` / `grass5` / `test9` / `test8` in 1–6-cell horizontal runs; the **dominant
brightness mechanism is (c), the per-id alpha patch**, which multiplies those cells by
≈0.72 while the Y05-neutralised base `test8` is multiplied by 1.00. Measured dark/light
contrast is ΔY≈26 with a hue-preserving ratio (1.43, 1.43, 1.50) — the signature of a scalar
mask factor, not of an atlas-id switch (atlas means differ by ≤3 levels except `grass5`).
(d) smoothing is a **co-cause of the hard/blocky edges** (Y04 guards freeze `grass9`; Y07
records that on the y04b build those guards were inert on `test8`), and (b) the 2 m repeat
only supplies the **grid cadence** (~34–51 px per cell), not the light/dark contrast:
repeating one id gives one brightness, never a checkerboard. Minimal fix is a **data-only
change inside `_stamp_grass_spots()`**: stop using `grass9` as the "light" id (its patch
(2,0) is dark, so 100 % of L01 spots currently render darker than the base), cut row
eligibility, and lengthen the remaining runs — no shader/atlas/noise change.

---

## 1. Evidence ledger

| ID | Label | Evidence |
|---|---|---|
| E01 | OBSERVED | `y04b/realmap.png` opened directly, 1280×720. Olive cell-locked light/dark squares across the open field, plus residual nested contour bands around buildings/stamps and residual screen-horizontal stripes. Mean RGB (85.863, 83.041, 35.116), mean luma 80.167, `non_black_fraction=1.0`, `full_width_dark_rows=0` (`Y04b_gate_log.md:64-83`). |
| E02 | OBSERVED | Capture cameras are near-pinned: y03 `(145.2939,58,-87.389)` target `(385.2939,59.7916)` vs y04b `(145.2856,58,-87.39741)` target `(385.2856,59.78319)` — Δ<0.01 m (`Y04b_gate_log.md:95`, `Y03_capture_log.md:90-98` via Y05 §7). Comparative A/B is therefore closer to aligned than earlier pairs, but still not exact. |
| E03 | OBSERVED | Clean-crop luma profiles, A03 convention `Y=.299R+.587G+.114B`. Bottom-right `(1000,600)-(1270,700)`: mean Y 81.57, row-std 8.697, col-std 0.613. Top-center `(470,0)-(660,80)`: mean 71.01, row-std 11.295, col-std 2.337. Lower-center `(780,520)-(1000,600)`: mean 79.49, row-std 9.331, col-std 2.258. |
| E04 | OBSERVED | Dark vs light block pixels in the same crops (threshold Y<70 / Y>80). Bottom-right: dark n=3927 mean RGB **(64.05, 64.93, 20.28)** Y=**59.58**; light n=22653 mean RGB **(91.73, 92.95, 30.45)** Y=**85.46** → **ΔY=25.9**, light/dark ratio **(1.432, 1.432, 1.502)**. Top-center: dark Y 56.48, light Y 82.72, ratio (1.460,1.460,1.594). Lower-center: dark Y 60.09, light Y 86.01, ratio (1.427,1.430,1.497). R and G scale **identically**; B slightly more. |
| E05 | OBSERVED | Block geometry in the bottom-right crop: at y=640 the dark runs are x=1019–1041, 1071–1093, 1122–1145, 1174–1197, 1225–1248 — width **23–24 px**, pitch **51–52 px**. Top-center column-ACF peaks at **34 / 67 / 101 / 135 px**. Both pitches match one 2 m world cell at those depths (Y05 §2 measured ≈35 px/cell at the same camera). The squares are **cell-locked**, not free-floating. |
| E06 | OBSERVED | `alpha.png` decoded (512×256, 8×4×64² patches), alpha = repacked input R per `world3d_terrain.gd:662-675`. Shader id decomposition `terrain_tileindex.gdshader:365-378` followed by A02-P4 compression at `:419` and fold at `:427` gives: `grass9`(idx 8)→patch **(2,0)**, raw mean 0.198, effective **a≈0.724**; `grass5`(4)→**(1,0)**, raw 0.205, **a≈0.726**; `test8`(79)→**(0,0)**, raw 1.000, **a=1.000**; `test9`(80)→**(7,3)** raw 0.000 but `scol=7,srow=3` trips the sentinel guard at `:419`, **a=1.000**; `test7`(78)→**(0,1)** a≈0.731. |
| E07 | OBSERVED | L01-IMPL is applied: `_stamp_grass_spots(brng)` called at `game.gd:2130` (before `_smooth_tilemap(brng,3)` at `:2134`); function at `:2359-2493`; dark id `_tb_pick(7,1)`→`grass5`; light ids `_donor_light_id()` at `:2480` → `[grass9, test9, test8]`; run length 1–6 from cfg:67, polarity 0.4/0.6 from cfg:846, row eligibility 0.36 from cfg:798 (`L01_impl.md:31-37, 256-260`). |
| E08 | OBSERVED | Y05's one-line swap is applied at `game.gd:2008`: `tex = _blk("test8")` (idx 79), so the neutralised detail field is the **a=1.0** cell; pre-swap it was `grass9` with a≈0.724 (`Y05_horizontal_banding.md:340-390`). |
| E09 | OBSERVED | Y04's four midpoint guards at `game.gd:2313-2328` protect only `_blk("grass9")` from receiving smoothing transition ids. On a `test8` meadow that predicate is always true → the guards were **inert in the y04b build**; Y07 widened them to `!= test8 and != grass9` **after** the capture (current `game.gd` 256,802 B, mtime 16:42:55; y04b PNG written 16:35:59). `Y07_ring_survivors.md:102-125,142-170`. |
| E10 | OBSERVED | A03 atlas means (Y299): `grass9` 72.98, `test8` 70.74, `grass5` 59.32, `test9` 69.92, `test7` 71.65; between-cell std only (5.6, 8.8, 3.5), A03 §2/F02. `ground1` is (99.8,90.7,66.3) grey-brown — the measured dark blocks are olive (64,65,20), so the mine-apron squares of Y04 §1.2 are **not** the blocks measured here. |
| E11 | OBSERVED | Read-only A/B on near-pinned cameras: bottom-right mean Y **71.39 (y03) → 81.57 (y04b)** Δ+10.18, 62.7 % of pixels change >10 luma; top-center +3.29; lower-center +5.09. Row/col ratio bottom-right 7.51→14.20, top-center 7.74→**4.83**, lower-center 9.83→**4.13** — horizontal banding **fell where spots are dense** but persists elsewhere, so stripes and squares coexist in this frame (honest caveat against the ticket's "not the old stripes" phrasing). |
| E12 | OBSERVED | `block_{test8,grass9}.png` 4×4 previews show no dark wedge in either atlas cell; `patch_1_0_grass5` / `patch_2_0_grass9` previews show a mostly-dark field with a bright corner blob — the observed per-cell dark wedge matches the **patch**, not the albedo. |

---

## 2. Quantifying which mechanism can supply ΔY≈26 (DERIVED)

Calibrate the constant shading term from the light blocks: atlas `test8` Y299=70.74 → observed
light Y=85.46, so the base multiplier is ≈**1.208**. Predicted rendered luma:

| id | atlas Y299 | alpha `a` (E06) | predicted Y | Δ vs base 85.5 | dominant cause |
|---|---:|---:|---:|---:|---|
| `test8` base (79) | 70.74 | 1.000 | 85.5 | 0 | — |
| `test9` (80) | 69.92 | 1.000 | 84.5 | ~1 | invisible as a spot |
| `grass9` (8) — L01 "light" | 72.98 | 0.724 | **63.8** | **21.7** | **patch ≈88 %**, atlas ≈12 % |
| `grass5` (4) — L01 "dark" | 59.32 | 0.726 | **52.0** | **33.4** | patch ≈14.5, atlas ≈13.8 |
| atlas-only `grass9` (no patch) | 72.98 | 1.000 | 88.2 | +2.7 | cannot make a checkerboard |
| atlas-only `grass5` (no patch) | 59.32 | 1.000 | 71.7 | −13.8 | too small, and wrong hue (B would rise) |

Measured ΔY is **25.9** with R and G scaling **identically** and B by +5 % (E04). That is the
multiplicative-mask signature (E06/E07), not an atlas-id signature: a `grass5`↔`test8` art swap
would change (R,G,B) by (0.886, 0.796, **1.125**) — R/G darker but B **brighter** — the opposite
of E04. **DERIVED:** the atlas-mean differences the ticket quotes (grass9 Y~75, grass5 Y~60,
test8 Y~73) explain at most ~14 levels and cannot explain the observed ~26; the per-id alpha
patch supplies the rest.

---

## 3. Candidate-by-candidate verdict

### (a) L01 spot ids with different atlas brightness — **PRIMARY spatial trigger**
OBSERVED E07/E10 + DERIVED §2. The spot pass is the only code that puts non-`test8` ids into
the neutralised meadow: 1–6-cell horizontal runs inside forest-stamp cores (`game.gd:2359-2493`).
Without it every meadow cell would be `test8` with a=1.0 and there would be no dark squares.
Its own atlas brightness is a **secondary** contributor: `grass9`−`test8` ≈2 levels,
`grass5`−`test8` ≈13 levels (A03 F02 warns clean ids barely differ). **INFERRED:** the id choice
matters mainly because it selects the alpha patch (see (c)), not because of the mean RGB.

### (c) per-id alpha patch — **PRIMARY contrast mechanism (rank 1 for the brightness)**
OBSERVED E04/E06/E12 + DERIVED §2. `grass9`→(2,0) and `grass5`→(1,0) are both dark patches
(a≈0.72); `test8`→(0,0) is the constant-1.0 no-op; `test9`→(7,3) is guarded to 1.0. L01's
"light" id `grass9` therefore renders **darker** than the base, so effectively **100 % of L01
spots are dark** (40 % by the "light" branch + 60 % by the "dark" branch). This is the same
co-cause Y05 identified for the old horizontal banding, now reintroduced **locally** by the
spot pass instead of globally by Y03's `tex=_blk("grass9")`.

### (d) tile smoothing — **CO-CAUSE for hard/blocky edges, not for the contrast**
OBSERVED E09 + Y07 §3. In the y04b build the Y04 guards still tested only `grass9`, so on a
`test8` meadow they were inert and the 3-pass smoother wrote transition ids into meadow cells,
nesting bands around every patch boundary; conversely a painted `grass9` spot cell *was*
protected and could not be eroded. Either way the spot border stays a hard 1-cell step instead
of a soft transition. **INFERRED:** this sharpens the squares but does not create their ΔY.

### (b) 2 m atlas-cell repeat / UV2 lookup — **geometric enabler only; RULED OUT as contrast source**
OBSERVED E05/E12 + DERIVED. `uv_repeat=(0.5,0.5)` and `fract(v_st*uv_repeat)` at
`terrain_tileindex.gdshader:214/:392` set the ~34–51 px cell pitch measured in E05; the per-id
UV2 lookup (`:324`, `:329-337`) selects the cell. Repeating **one** id yields one uniform
brightness, never a light/dark alternation; both 4×4 previews are wedge-free. A01 Rank 1 is the
carrier of the *old* stripes (still partially present, E11), not the source of the new squares.
Do **not** remove B01's warp/inset/`textureGrad` or B02's mips to chase the squares.

---

## 4. Ranked verdict

| Rank | Cause | Verdict | Decisive evidence |
|---:|---|---|---|
| 1 | **(c) tile-id-coupled alpha patch** (`grass9`→(2,0), `grass5`→(1,0), a≈0.72 vs base `test8` (0,0) a=1.0) | **PRIMARY — brightness** | E04 ΔY 25.9 hue-preserving (1.43,1.43,1.50); E06 patch decode; §2 predicts 21.7/33.4 levels vs atlas-only ≤13.8 |
| 2 | **(a) L01 spot pass** (1–6-cell runs of `grass9`/`grass5`/`test9`/`test8`) | **PRIMARY — spatial trigger** | E07 code applied; E05 cell-locked runs at 51 px pitch; E11 field mean/contrast changed only after these passes landed |
| 3 | **(d) 3-pass tile smoothing + Y04/Y07 guards** | **CO-CAUSE — hard edges** | E09 guards inert on `test8`, `grass9` frozen; Y07 §3 nested bands; not a source of ΔY |
| 4 | **(b) 2 m atlas repeat / UV2 lookup** | **RULED OUT as contrast source** (sets grid pitch only) | E05 pitch; E12 wedge-free albedo; one id = one brightness |

**INFERRED (caveat):** the ranking rests on code paths, decoded patches and pixel statistics,
not on a decoded `tileblock` for this exact frame. **UNVERIFIED:** which id sits at any specific
dark pixel (no `--dump-map` from the y04b build was analysed here); exact quantitative share of
(c) vs (a) vs (d) in ΔY=25.9; whether the residual stripes (E11) share the same patch cause.
**No donor parity claim.**

---

## 5. Minimal fix (keeps organic variation, no maze/banding, S-25-09 safe)

All edits are **data-only inside `game.gd`'s `_stamp_grass_spots()` / its two helpers**; shader,
atlas, block PNGs, config, tests, `world3d_terrain.gd`, `pattern_gen.gd` and `app/` stay
untouched. No new bitmap, hash, dither, gain or luminance field — S-25-09 honoured. Keep Y03's
detail neutralisation (`game.gd:2008`=`test8`), keep Y04/Y07 guards, keep the mine apron and
the forest borders.

**Step 1 — stop the mislabelled "light" id (highest confidence, smallest diff).**
At `game.gd:2480` the light picker is `[grass9, test9, test8]`. `grass9` (patch (2,0), a=0.724)
makes ~40 % of all spots darker than the base instead of lighter. Change the light pool to
**`[test9, test8]`** (both a=1.0, E06). Effect (DERIVED): the "light" branch becomes a no-op
(≤1 luma) and the dark share of spots falls from 100 % to ~60 %, cutting dark coverage ~40 %
with **zero** added RNG draws and no new id. This is the direct analogue of Y05's §6.1 one-line
`grass9`→`test8` swap, applied to the *spot* palette.

**Step 2 — thin and lengthen the remaining spots (two PORT APPROX knobs).**
In `_stamp_grass_spots()`: row eligibility `0.36` → **≈0.12–0.15** (same donor-weighted roulette,
lower threshold) and run length `1..6` → **≈4..10** cells (still one contiguous row-run from the
stamp disc, still per-row RNG, never `(x,y)` parity). Effect (DERIVED): fewer, longer dark
streaks read as organic patches rather than a repeated single-cell square grid; `row_periodicity`
should fall, `tile_repeat` should not gain a new cadence. Both knobs remain **PORT APPROX**
repurposings of donor weights — label them as such, do not normalise any probability.

**Why not "just use closer-luminance ids":** A03 F02 measured between-cell atlas std only
(5.6, 8.8, 3.5) and §2 above shows `grass9`−`test8` ≈2 levels. Every clean a=1.0 id is within
~1–3 levels of `test8`; the only notably darker clean id (`grass5`) carries a dark patch. A
pure "closer-luminance id" swap alone is therefore either invisible or still patch-dark — the
fix must remove the **dark-patch ids from the light branch** and reduce coverage, which Steps
1–2 do.

**Do NOT:** revert `game.gd:2008` to `grass9` (restores Y05's field corrugation); re-enable the
height-gradient `terrain=5` paint or bitmap detail ids (Y01/L03 field maze); weaken the Y04/Y07
guards (Y07 nested rings); add a synthetic noise/dither/luminance field (S-25-09); change the
shader/atlas to "blur" the patches (turns a data problem into a filter regression).

**Verification (movement indicators only, never thresholds or donor parity):** a matched-camera
G04 capture plus the C01 metric (`BV32`, `grad`, `row_periodicity`, `tile_repeat`, `coherence`)
on the identical crop; the dark-pixel fraction (E04's Y<70 count) should fall, the hue-preserving
light/dark ratio should move toward 1, and `full_width_dark_rows=0` / `non_black_fraction=1.0`
must hold. Optional `--dump-map` decode should show `grass9` absent or rare in the spot pool and
no out-of-atlas id. Gates unchanged: selftest 29/29, uitest 17/17, `t_render_mode`,
`t_map_variety` 5/5 incl. `same_seed_byte_identical`, `assert_clean CLEAN`, 2D `app/` untouched.
This agent ran **none** of them.

---

## 6. UNVERIFIED / open questions

1. No tile dump from the y04b build was decoded; exact id and patch at any checkerboard pixel is
   INFERRED from code + patch statistics, not measured per cell.
2. The y04b camera differs from y03 by <0.01 m but is not identical; E11's A/B is
   near-pixel-aligned, not exact.
3. Quantitative share of (c) vs (a) vs (d) in ΔY=25.9 is a calibrated estimate, not a
   separated measurement.
4. Residual horizontal stripes coexist with the squares (E11); whether they share the same
   patch mechanism needs a matched-camera A/B after the fix.
5. Post-capture the tree changed (Y07's widened guards, 16:42:55); no capture exists for that
   state, so the fix's rendered effect is **UNVERIFIED** until G04 runs.
6. Donor parity: no donor GPU A/B frame exists. No donor still was opened in this ticket.

---

## 7. Scope statement

Repo files created by this ticket: **this report only**. No code, shader, asset, config, test,
runner job, git state or donor file was changed. The `python` invocations read the two PNGs,
`alpha.png`, block PNGs and source files and wrote scratch images/scripts only under
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\y08\`. The §5 hunks are **proposals** only,
awaiting COORD's ownership grant and G04's runner. **No donor parity or gate PASS is claimed.**

---

## 8. COORD follow-up — the matched-camera y07 frame falsifies the micro-tweak path

### 8.1 New evidence (all OBSERVED unless labelled)

| ID | Label | Evidence |
|---|---|---|
| E13 | OBSERVED | `y07/realmap.png` opened directly, 1280×720, **0 script errors** (`Y07_capture_log.md:71-76`): concentric stepped bands still wrap deposits/starts/buildings, and the olive cell-locked checkerboard is still across the open field — visually **not removed** by Y07's widened guards. Mine aprons remain deliberate tan/grey squares. |
| E14 | OBSERVED | Same crop statistics as §1 on `y07`: bottom-right `(1000,600)-(1270,700)` mean Y **76.04**, row-std 11.070, col-std 1.595, dark fraction (Y<70) **0.356**, light/dark ratio **(1.431,1.433,1.507)**. Top-center `(470,0)-(660,80)` mean 63.10, dark fraction **0.720**, ratio (1.459,1.459,1.601). Lower-center `(780,520)-(1000,600)` mean 75.21, dark fraction 0.404, ratio (1.427,1.430,1.482). |
| E15 | OBSERVED | The **light/dark ratio is invariant** between y04b and y07 in all three crops to ±0.01 per channel, while dark fraction rises (bottom-right 0.145→0.356, top-center 0.420→0.720). Widening the smoothing guards changed **coverage**, not the **contrast mechanism**. This is the decisive falsification of guard/density micro-tweaks: §2's patch factor survives every guard change. |
| E16 | OBSERVED | Camera caveat: y07 `camera_pos=(144.1104,58,-88.57262)` target `(384.1104,58.60797)` **matches the g04 baseline**, not y04b `(145.2856,58,-87.39741)` (`Y07_capture_log.md:84-87`). The y04b↔y07 crop comparison is therefore **comparative, not pixel-aligned**. Matched-camera g04→y07 bottom-right: mean Y 87.88→76.04, dark fraction 0.075→0.356 (different code states; directional only). |

### 8.2 Consequence for the mandate

INFERRED (high confidence): the field's tile-id **data**, not the guards, is the producer.
L01's spot pass, the Y03/Y05 neutralisations, the 118 donor smoothing rules, the forest
borders and the mine-apron authority each write a different id into neighbouring cells;
each id carries a different atlas cell **and a different alpha patch** (E06), so any
boundary becomes a light/dark cell step. Guards only decide *which* of those ids survives
at a given cell — hence y07's larger dark fraction at an unchanged ratio (E15). No
parameter tweak to spots, guards or smoothing can remove a contrast that is baked into
the id→patch mapping while more than one id is permitted on ordinary land.

---

## 9. DECISIVE STRUCTURAL PROPOSAL — two independent, separately reversible branches

Ownership is **not granted yet**; all diffs below are proposals. Branch A is the fix for
rings/checkerboard. Branch B is a **separate A/B** for organic mottling and must never be
merged into A's capture without a labelled branch id. Both are PORT APPROXIMATION unless
marked donor-grounded; no donor parity claim is made for either.

### 9.1 Branch A — one final-authority id for ordinary land (`game.gd`, exclusive owner)

Two hunks, both in `variant3d/scripts/game.gd`. Insert the normalisation **after** the
mine-apron final authority (current `:2141-2143`) and **before** the winter alias
(current `:2148-2152`), so worked ground wins and season art still aliases. Change the
start keep-clear id in `_finalize_mine_tiles()` so that post-`_assign_tileblocks()` write
cannot reintroduce a `grass1` colour disc.

```diff
diff --git a/variant3d/scripts/game.gd b/variant3d/scripts/game.gd
--- a/variant3d/scripts/game.gd
+++ b/variant3d/scripts/game.gd
@@ -386,5 +386,5 @@ func _finalize_mine_tiles() -> void:
 	# T2GEN: final 7-tile start keep-clear for forest (some groves are placed
 	# after _gen_finish by spawn provisioning).
-	var g0 := _blk("grass1")
+	var g0 := _blk("test8")  # Y08 PORT APPROX: same normalised meadow id; terrain 2->0 and blocked cleanup unchanged
 	for st in map_starts:
 		var sc := Vector2(float(st.x) / TILE, float(st.y) / TILE)
@@ -2141,5 +2141,22 @@ func _assign_tileblocks() -> void:
 	for mi in mine_mask.size():
 		if mine_mask[mi] != 0:
 			tileblock[mi] = _blk("ground1")
+	# Y08 (PORT APPROXIMATION): FINAL AUTHORITY. Collapse every ordinary land
+	# cell to ONE clean donor id (test8 idx 79; A03 §4 isotropic/seamless, alpha
+	# patch (0,0) constant 1.0) AFTER smoothing, forest borders, L01 spots and
+	# the mine apron, so no per-cell colour ring, spot or checkerboard survives
+	# into UV2.x. Exceptions are only donor-required roles: water, shore/sand,
+	# rock/cliff, worked road/apron. _blk() draws no RNG; no terrain/height/
+	# blocked write. Placement BEFORE the winter alias keeps season art intact.
+	var meadow_id := _blk("test8")
+	for i in tileblock.size():
+		if int(tileblock[i]) == BLK_WATER:   # 255, game.gd:52
+			continue
+		if mine_mask[i] != 0:                # real worked ground wins
+			continue
+		var role: int = int(terrain[i])
+		if role == 1 or role == 3 or role == 4 or role == 5:
+			continue  # road / water / shore-sand / rock-cliff
+		tileblock[i] = meadow_id
 	# T2GEN P2-5: expose the winter art selection without touching the tile
 	# index table or world.gd's tint.  This block is a no-op on Summer maps;
```

**Why `test8`, not `grass9`:** A03 §4 ranks both clean, but `grass9` selects alpha patch
(2,0) with effective a≈0.724 (E06) and was the direct cause of Y05's field corrugation;
`test8` selects the constant-1.0 no-op (0,0). Labelled **PORT APPROX**: donor id and donor
weight, port-level universal-meadow role.

**Why leave `_stamp_grass_spots(brng)` and all `_tb_pick` calls in place:** they are
overwritten by the final authority but keep the `brng` stream **byte-identical**, so
`t_map_variety same_seed_byte_identical` and all later RNG consumers are unchanged.
Deleting the pass is a separate cleanup ticket, not part of this fix.

**Exceptions (exact code justification, all OBSERVED):**
- `BLK_WATER=255` (`game.gd:52`) — water plane, never recoloured.
- `mine_mask != 0` — `_finalize_mine_tiles():383-385` and `:2141-2143` worked-ground authority (T2GEN P0-1 gate-protected).
- `terrain==1` — donor road art (`game.gd:2043-2053`, `_draw_road()`), donor-grounded.
- `terrain==4` — `_apply_shore_cliffs():2224-2227` writes `_shore_tile_for()` sand art only here.
- `terrain==5` — `_apply_shore_cliffs():2228-2231` writes `_cliff_tile_for()` rock art only here.
- `terrain==0/2` are normalised deliberately: this **removes** the donor forest-border
  `grass5/rock9` outline (`_stamp_forest_borders`) and L01's spots — a **PORT APPROX**
  departure from donor border art, accepted because those outlines are the cell-level grid.
  Trees remain separate entities; no stamp, `blocked` or `terrain` entry is removed.

### 9.2 Branch B — larger-scale texture grain (`terrain_tileindex.gdshader`, B01 released)

Separate A/B branch, applied **only** to a Branch-A build. One line at `:214`:

```diff
diff --git a/variant3d/shaders/terrain_tileindex.gdshader b/variant3d/shaders/terrain_tileindex.gdshader
--- a/variant3d/shaders/terrain_tileindex.gdshader
+++ b/variant3d/shaders/terrain_tileindex.gdshader
@@ -211,7 +211,7 @@
-uniform vec2 uv_repeat = vec2(0.5, 0.5);
+uniform vec2 uv_repeat = vec2(0.25, 0.25);  // Y08 PORT APPROX A/B: 1 atlas cell per 4 m (A03 §5 R07)
 // TRN-SHADER: 0.5 = 1 / 2 m — donor `gc_meters_to_tile = 2`
```

Consequences (DERIVED, must be A/B-tested, not assumed):
- RGB phase `fract(v_st*uv_repeat)` at `:392` doubles the world footprint of the cell;
  1024 px now covers 4 m (256 px/m) instead of 2 m. Helps only isotropic cells — `test8`
  is one (A03 §4 aniso 1.27, Sx 0.95, Sy 0.96). Exceptions keep their own art.
- `v_alpha_uv = v_st * uv_repeat * alpha_uv_scale` at `:316` changes the mask-patch phase
  to 4 m too; on Branch A's `test8` cells the patch is constant 1.0, so this is inert there.
- `textureGrad(..., dFdx/dFdy(v_st*uv_repeat))` at `:337` gets half the gradient → LOD about
  one level lower (sharper grain). Keep the warp, inset, mips and sentinel guard untouched.
- **PORT APPROX / UNVERIFIED:** departs from donor `gc_meters_to_tile=2` (`A03 §5 R07`).
  A03 F02 measured no cell contains donor-scale mottling (LF 0.09–0.25); UV scale alone
  cannot manufacture it. Branch B is therefore an *honest A/B probe*, not a promised fix.
- Cosmetic only: the diagnostic string `world3d_terrain.gd:1555` still prints
  `uv_repeat=(0.5,0.5)`. Syncing it is optional and **not** in this diff (disjoint owner).

No runtime override exists: grep over `variant3d/**/*.gd` finds no `uv_repeat` assignment
(other than the diagnostic string), so the shader default is authoritative.

### 9.3 Relief / cliffs (COORD point 3 — accept as stated, cite it)

Relief must come from geometry and donor props, not tile colour: `Z08_impl.md:51-57,82-94`
lands `mountain_props.json` (112 `terrainmesh*` records, exact donor `pattern.lib` transforms)
and a static `MultiMeshInstance3D` consumer in `world3d_relief.gd`; `world3d_terrain.gd:756-778`
computes face mode 1/2 **only from height gradients** (`DONOR_CDIFF1=0.5`, `DIFF2=0.55`
at `:161-162`) and never from UV2.x. Branch A does not touch `height`, so face selection and
the Z08 props are byte-identical. Keeping the `terrain==5` rock ids is the tile-colour
exception the donor requires; that art is not the relief source. Re-enabling B04 face
promotion or the height-gradient `terrain=5` paint is explicitly forbidden (L03 §2, Y04 §5.3).

### 9.4 Backup commands (run by the granted owners, before the first edit)

```powershell
Copy-Item -LiteralPath 'variant3d\scripts\game.gd' -Destination 'inbox\backup\game.gd.bak-Y08' -Force
Copy-Item -LiteralPath 'variant3d\shaders\terrain_tileindex.gdshader' -Destination 'inbox\backup\terrain_tileindex.gdshader.bak-Y08' -Force
Get-FileHash -LiteralPath 'variant3d\scripts\game.gd','inbox\backup\game.gd.bak-Y08' -Algorithm SHA256
Get-FileHash -LiteralPath 'variant3d\shaders\terrain_tileindex.gdshader','inbox\backup\terrain_tileindex.gdshader.bak-Y08' -Algorithm SHA256
```
Pre-edit values (OBSERVED this turn): `game.gd` **256,802 bytes**, SHA-256
`B9D07265B250BC458D4FEA703452D1CD7F6FCC7B45C4DD888C19F10FD212D890`; shader SHA-256
`E02E787AD82667BB7FB895E1734357708A66591690706B56A725A039995396C3`. Neither `*.bak-Y08`
exists yet (both `Test-Path` = False). Branch B's backup must be taken from the **Branch-A
post-edit** shader state, not from this baseline, if B is applied after A.

Rollback is a byte copy of the relevant backup; restoring A also requires restoring `g0`.

### 9.5 Invariant proof (DERIVED from the diffs, to be re-checked by the owner)

| Invariant | Status | Proof |
|---|---|---|
| RNG stream | **byte-identical** | `_blk()` is a pure dictionary lookup; the new loop draws nothing; every `_tb_pick` call and guard stays verbatim; `g0` change is a lookup only. `brng` entering `_smooth_tilemap`, `_stamp_forest_borders` and later passes is unchanged. |
| Determinism | preserved | same seed → same bytes; `t_map_variety same_seed_byte_identical` holds. A frozen tileblock hash is **not** a valid gate (B03 R1 / TRN-DATA). |
| `tileblock` contract | intact | `PackedByteArray`, size `MAP_W*MAP_H`, uint8 id `79` valid in the 124-name table (`presets_summer.json`); `BLK_WATER=255` never overwritten (`game.gd:52` guard). |
| Mine apron / T2GEN P0-1 | intact | `mine_mask!=0` skipped in the normalisation; `:2141-2143` and `_finalize_mine_tiles():383-385` ground1 authority unchanged and still last for worked ground. |
| Shore / sand | intact | `terrain==4` skipped; `_apply_shore_cliffs():2224-2227` art preserved. |
| Rock / cliff / face mode | intact | `terrain==5` skipped; `_apply_shore_cliffs():2228-2231` art preserved; `_face_mode_at()` reads height only (`world3d_terrain.gd:756-778`), so UV2.y is unchanged. |
| Roads | intact | `terrain==1` skipped; donor road art at `:2043-2053` preserved (donor-grounded). |
| Season / winter | intact | normalisation placed **before** `winter_block_for()` at `:2148-2152`; `test8`→`winter21` via `WINTER_ART` at `:1831`; `g0` change aliases identically. |
| `terrain` / `height` / `blocked` / `res_nodes` / `map_starts` | byte-identical | Branch A writes only `tileblock`; the `terrain 2→0` and `blocked` cleanup in `_finalize_mine_tiles():395-408` is untouched. |
| Z08 relief props | intact | no `pattern_stamps`/mesh/`world3d.gd` write; `stats.relief_props` unchanged. |
| Guards / gates | honoured | no threshold lowered, no assertion deleted, no `expected_pre_fix_failure` flipped. |
| S-25-09 | honoured | no new bitmap, hash, dither, gain or luminance field; Branch A is a data override, Branch B is a UV-scale change. |
| Donor parity | **none claimed** | universal-meadow role and 4 m UV scale are PORT APPROX; no donor GPU A/B frame exists. |

### 9.6 Capture + metric acceptance that would prove the three claims

G04 owns the runner (unique ids, one job at a time). Three branches, **same seed 20261113,
same camera (the y07/g04 pose), same `--screenshot-frames 10`**, no threshold changed:
`B0` = current y07 baseline, `B1` = Branch A, `B2` = Branch A + Branch B. Paths, timestamps,
camera diag and result JSON fields recorded verbatim. C01 `terrain_ab_metric.py` on the
**identical crop** for all three (G05 §3 `--crop 120,60,1040,580`), plus a clean meadow crop
`(1000,600)-(1270,700)` measured as in §1/§8.

1. **No rings** — visual C04/G05 R1–R6 read: zero nested stepped bands around deposits,
   starts and buildings; radial luma profiles at the historical ring centres lose their
   peaks; `row_periodicity` moves down from the y07 value toward the donor-median direction
   (0.232, A11 §5) — movement indicator only, never a gate.
2. **No checker** — in the clean crop the light/dark ratio (E14's ~1.43) must approach
   **1.00**, dark fraction Y<70 must collapse from 0.356 toward ~0, `BV32 n640` and the
   34/51 px `tile_repeat` peak must collapse; `non_black_fraction=1.0`,
   `full_width_dark_rows=0`. A dump probe must show ordinary cells dominated by id 79 with
   only `ground1`/sand/rock exceptions and no out-of-atlas id.
3. **Organic mottling (B2 vs B1 only)** — at the same camera/crop, `BV128
   between_block_var` and block-scale luma std must **increase** relative to B1 while
   `BV32` stays low and `grad` does not spike; no new seam, black row or direction-locked
   streak (`band_peak_deg`, `coherence` must not worsen). If B2 shows no such movement,
   record that UV scaling alone did not create mottling — A03 F02 predicts this; **do not**
   substitute a synthetic field (S-25-09) or reintroduce per-cell ids to force it.
4. **Gates unchanged** — selftest 29/29, uitest 17/17, `t_render_mode`, `t_map_variety` 5/5
   incl. `same_seed_byte_identical`, `assert_clean CLEAN`, `script_error_lines == 0`,
   2D `app/` untouched. Optional `--dump-map` diff: `terrain`/`blocked`/`height` byte-identical
   to the B0 same-seed dump.
5. **Epistemic** — every metric above is a **movement indicator**, not a threshold and not
   donor parity. Donor parity stays **UNVERIFIED** (CHARTER §3/§5); no donor GPU A/B frame exists.

### 9.7 What NOT to do

1. Do not tune spots/guards/smoothing weights further — E15 proves the invariant ratio survives them.
2. Do not revert `game.gd:2008` to `grass9` (Y05 corrugation) or restore bitmap detail ids / the
   height-gradient `terrain=5` paint (Y01/L03 maze).
3. Do not weaken the Y04/Y07 guards (`game.gd:2313-2328`) — Y07 rings return.
4. Do not remove the mine apron, road art, shore sand or rock/cliff exceptions — gate-protected
   and donor-grounded.
5. Do not add noise/dither/hash/luminance fields or per-cell mirror variants (S-25-09, L02 §4, B01).
6. Do not enable B04 face promotion or use tile colour as the relief source — Z08 props and
   real mesh height own relief (§9.3).

---

## 10. Scope statement (updated)

Repo files created/edited by this ticket: **this report only**. All §9 diffs, backup commands
and acceptance steps are **proposals** awaiting COORD's ownership grant and G04's runner.
No Godot process, runner job, queue mutation, donor file, code, shader, asset, config or test
was changed in this follow-up. Scratch scripts/PNGs live only under
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\y08\`. **No donor parity and no gate PASS
is claimed.**

---

## 11. APPLIED — Y08-IMPL (COORD exclusive-ownership grant for `game.gd`)

Status: **APPLIED**. Exactly Branch A's two hunks were applied to
`variant3d/scripts/game.gd`; Branch B (shader `uv_repeat`) was **NOT** applied — it remains a
separate A/B proposal in §9.2 awaiting its own owner grant. No runner job, no Godot process,
no queue/lock/counter mutation, no shader/atlas/asset/config/test/donor/git write.

### 11.1 Backup (taken BEFORE the first edit)

| Item | Value |
|---|---|
| Command | `Copy-Item -LiteralPath 'variant3d\scripts\game.gd' -Destination 'inbox\backup\game.gd.bak-Y08' -Force` |
| Pre-edit `game.gd` | **256,802 bytes**, SHA-256 `B9D07265B250BC458D4FEA703452D1CD7F6FCC7B45C4DD888C19F10FD212D890` — exactly the §9.4 baseline, so no intervening edit existed |
| `inbox/backup/game.gd.bak-Y08` | **256,802 bytes**, SHA-256 **identical** to the above; no existing backup overwritten (`Test-Path` was False; `bak-Y03/-Y04/-Y05/-L01/-B03*` left intact) |
| Post-edit `game.gd` | **257,818 bytes**, SHA-256 `0009F025446BFC62706FCDF5B07B33539FF628CE87AF33193954B384A12EA64C` |

Rollback is a byte copy of this backup over `variant3d/scripts/game.gd` (§11.6).

### 11.2 Exact applied diff (verbatim `git diff --no-index -- inbox/backup/game.gd.bak-Y08 variant3d/scripts/game.gd`)

```diff
diff --git a/inbox/backup/game.gd.bak-Y08 b/variant3d/scripts/game.gd
index 26191113..6d6bac8e 100644
--- a/inbox/backup/game.gd.bak-Y08
+++ b/variant3d/scripts/game.gd
@@ -385,7 +385,7 @@ func _finalize_mine_tiles() -> void:
 			tileblock[mi] = g1
 	# T2GEN: final 7-tile start keep-clear for forest (some groves are placed
 	# after _gen_finish by spawn provisioning).
-	var g0 := _blk("grass1")
+	var g0 := _blk("test8")  # Y08 PORT APPROX: same normalised meadow id; terrain 2->0 and blocked cleanup unchanged
 	for st in map_starts:
 		var sc := Vector2(float(st.x) / TILE, float(st.y) / TILE)
 		for yy in range(maxi(0, int(sc.y - 16.0)), mini(MAP_H, int(sc.y + 16.0) + 1)):
@@ -2141,6 +2141,23 @@ func _assign_tileblocks() -> void:
 	for mi in mine_mask.size():
 		if mine_mask[mi] != 0:
 			tileblock[mi] = _blk("ground1")
+	# Y08 (PORT APPROXIMATION): FINAL AUTHORITY. Collapse every ordinary land
+	# cell to ONE clean donor id (test8 idx 79; A03 §4 isotropic/seamless, alpha
+	# patch (0,0) constant 1.0) AFTER smoothing, forest borders, L01 spots and
+	# the mine apron, so no per-cell colour ring, spot or checkerboard survives
+	# into UV2.x. Exceptions are only donor-required roles: water, shore/sand,
+	# rock/cliff, worked road/apron. _blk() draws no RNG; no terrain/height/
+	# blocked write. Placement BEFORE the winter alias keeps season art intact.
+	var meadow_id := _blk("test8")
+	for i in tileblock.size():
+		if int(tileblock[i]) == BLK_WATER:   # 255, game.gd:52
+			continue
+		if mine_mask[i] != 0:                # real worked ground wins
+			continue
+		var role: int = int(terrain[i])
+		if role == 1 or role == 3 or role == 4 or role == 5:
+			continue  # road / water / shore-sand / rock-cliff
+		tileblock[i] = meadow_id
 	# T2GEN P2-5: expose the winter art selection without touching the tile
 	# index table or world.gd's tint.  This block is a no-op on Summer maps;
 	# TRN-DATA changes the tileblock bytes but leaves every other seed output
```

`git diff --no-index --numstat` → **18 insertions, 1 deletion**; exactly **two hunks**, no
other byte changed. `git diff --no-index --check` printed **no whitespace errors** (exit 1 is
the normal "files differ" status of `--no-index`).

### 11.3 Static verification actually performed (no Godot)

- Pre/post hash and size recorded in §11.1; backup verified byte-identical to pre-edit source.
- Comment/string-stripped bracket balance: `()` 3739/3739, `[]` 1354/1354, `{}` 257/257 — balanced.
- Anchor counts (OBSERVED): `tex = _blk("test8")` at `:2008` **1** (Y05 neutralisation intact);
  four Y07 guards containing both `!= _blk("test8")` and `!= _blk("grass9")` at
  `:2332/:2336/:2340/:2344` **4**; `_stamp_grass_spots(brng)` at `:2130` **1**;
  `_smooth_tilemap(brng, 3)` at `:2134` **1**; `_stamp_forest_borders(brng)` at `:2137` **1**.
- Call order by line: spots `:2130` → smoother `:2134` → forest borders `:2137` → mine apron
  `:2141-2143` → **new final authority block `:2144-2160`** (`meadow_id` line `:2151`) →
  winter alias `:2165`. (The new block sits between the mine-apron writes and
  `winter_tile_names.clear()`, as specified.)
- Zero `randf(`/`randi(` tokens in the inserted block: **0**.
- Grep for `terrain[…] = 5` finds exactly **one** executable write (stone-quarry disc `:852`);
  the height-gradient paint remains collision-only (B03 §11 / L03).
- No shader, atlas, asset, config, test, `world3d_terrain.gd`, `pattern_gen.gd`, donor file,
  runner job or Godot process was touched or started.

### 11.4 Invariants (DERIVED from the applied diff)

| Invariant | Status | Proof |
|---|---|---|
| RNG stream | **byte-identical** | `_blk()` is a pure dictionary lookup; the new loop draws nothing; all four `_tb_pick` calls and guards verbatim (`:2332-2344`); `_stamp_grass_spots(brng)` call verbatim (`:2130`); `g0` swap is a lookup only. `brng` entering smoother/borders/later passes unchanged. |
| Determinism | preserved | same seed → same bytes; `t_map_variety same_seed_byte_identical` holds by construction. Frozen tileblock hash is **not** a valid gate (B03 R1 / TRN-DATA). |
| `tileblock` contract | intact | `PackedByteArray` size `MAP_W*MAP_H`; uint8 id 79 valid in the 124-name table; `BLK_WATER=255` (`:52`) never overwritten. |
| Mine apron / T2GEN P0-1 | intact | `mine_mask!=0` skipped in the new loop; `:2087-2088`, `:2141-2143` and `_finalize_mine_tiles():383-385` ground1 authority unchanged and last for worked ground. |
| Shore / sand | intact | `terrain==4` skipped; `_apply_shore_cliffs():2224-2227` sand art preserved. |
| Rock / cliff / face mode | intact | `terrain==5` skipped; `_apply_shore_cliffs():2228-2231` rock art preserved; `_face_mode_at()` reads height only (`world3d_terrain.gd:756-778`), so UV2.y unchanged. |
| Roads | intact | `terrain==1` skipped; donor road art at `:2043-2053` preserved. |
| Season / winter | intact | normalisation placed **before** `winter_block_for()` at `:2165-2169`; `test8`→`winter21` via `WINTER_ART:1831`; the changed `g0` aliases identically. |
| `terrain` / `height` / `blocked` / `res_nodes` / `map_starts` | byte-identical | new loop writes only `tileblock`; the `terrain 2→0` and `blocked` cleanup in `_finalize_mine_tiles()` unchanged. |
| Y05 / Y07 / Y03 / B03 invariants | intact | Y05 `:2008` `test8`, Y07 widened guards, Y03 detail structure and B03 collision-only gradient all verbatim. |
| Z08 relief props | intact | no `pattern_stamps`/mesh/`world3d.gd` write; `stats.relief_props` unchanged. |
| Guards / gates | honoured | no threshold lowered, assertion deleted or expected-failure flipped. |
| S-25-09 | honoured | no new bitmap, hash, dither, gain or luminance field; this is a data override only. |
| Donor parity | **none claimed** | universal-meadow role is PORT APPROX; no donor GPU A/B frame exists. |

### 11.5 Gate list for G04 (Y08-IMPL runs none — one Godot at a time)

Run on the post-Y08 tree with unique ids; no threshold or assertion may change:
1. `variant3d` selftest — expect **29/29**.
2. `variant3d` uitest — expect **17/17**.
3. `t_render_mode` — green.
4. `t_map_variety` — **5/5**, including `same_seed_byte_identical` (frozen tileblock hash is **not** a valid gate).
5. `assert_clean` — **CLEAN**; `script_error_lines == 0`; `non_black_fraction == 1.0`; `full_width_dark_rows == 0`; 2D `app/` gates untouched.
6. Matched-camera `--seed 20261113` real-map capture (use the y07/g04 camera pose), unique id; C04/G05 R1–R6 read for **zero nested stepped rings**, **zero olive checkerboard**, visible roads/shore/rock/mine exceptions, no new seam or black row.
7. C01 `terrain_ab_metric.py` on the identical crop for baseline and AFTER — `BV32`, `grad`, `row_periodicity`, `tile_repeat`, `coherence` are **movement indicators only**, never thresholds or parity. Expect the ground-crop light/dark ratio (§8 E14 ≈1.43) to move toward 1.0 and dark fraction (0.356) to collapse.
8. Optional `--dump-map` probe (new unique id): decode `tileblock`; ordinary cells dominated by id 79, `ground1`/sand/rock exceptions present, no out-of-atlas id; `terrain`/`blocked`/`height` byte-identical to a same-seed B0 dump.
9. **Branch B is NOT part of this gate.** If COORD grants the shader owner later, run `B2` as a *separate* matched-camera capture and compare against this `B1` frame for larger-block mottling (§9.6 item 3).

### 11.6 Rollback

```powershell
Copy-Item -LiteralPath 'inbox\backup\game.gd.bak-Y08' -Destination 'variant3d\scripts\game.gd' -Force
Get-FileHash -LiteralPath 'variant3d\scripts\game.gd','inbox\backup\game.gd.bak-Y08' -Algorithm SHA256
```
Both hashes must return `B9D07265B250BC458D4FEA703452D1CD7F6FCC7B45C4DD888C19F10FD212D890`
(256,802 bytes), restoring the exact pre-Y08 state. No other file needs rolling back.

### 11.7 Epistemic status

No Godot process, runner job, queue mutation, donor file read/copy or other source edit occurred
in this implementation step. Whether the rendered frame actually loses the rings and
checkerboard is **UNVERIFIED** until G04's matched-camera capture and a second-agent visual
read; **no donor parity and no gate PASS is claimed** (CHARTER §3/§5).

---

## 12. COORD follow-up (Y08b) — neutralise the last visible exceptions, READ-ONLY proposal

### 12.1 Mandate and answer

COORD: the Branch-A capture `...\y08\realmap.png` (matched camera, 0 script errors) still shows
the same rings around starts/mines and the blocky field. Produce a **minimal fix that makes
the VISIBLE tile ids of mine worked ground / deposit aprons / start keep-clear equal `test8`
while every gameplay array stays byte-identical**. Report only; await grant before applying.

**Answer:** three one-site edits in `game.gd`, all **tileblock-only**. The remaining rings are
exactly the exceptions Branch A kept (E21): mine aprons (`mine_mask != 0`, also `terrain 1`),
the start keep-clear disc, and the road/shore/rock roles. Remove `mine_mask` from the final
authority's skip list and write `meadow_id` there instead; make `_finalize_mine_tiles()`'s
late `g1` write use `test8`; and make the start keep-clear write apply to the whole disc
(water-guarded) instead of only `terrain==2` cells. `blocked[]`, `terrain[]`, `height[]`,
`mine_mask`, `can_place`, deposit snapping, start protection, RNG and all gates are untouched.
The field checker is **texture-level** (E20) and is Branch B's separate A/B — this proposal
does not touch the shader.

### 12.2 New evidence (all OBSERVED unless labelled)

| ID | Label | Evidence |
|---|---|---|
| E19 | OBSERVED | `y08/realmap.png` opened directly, 1280×720, `script_error_lines=0`, camera `(144.1104,58,-88.57262)` — matches y07/g04 exactly (`Y08_capture_log.md:46-86`). Concentric bands still wrap every deposit/start; tan/grey mine aprons and field checker persist. |
| E20 | OBSERVED | Pixel-aligned y07→y08 diff on clean field crops: `(1000,600)-(1270,700)`, `(470,0)-(660,80)`, left/right deposit crops → **zero changed pixels** (`frac_any=0.000`, `max diff=0`); mean Y 76.04/63.10/81.15/82.14 and light/dark ratios identical in both frames. Branch A changed **no** open-field pixel: the field was already all `test8`; its checker is **inside the atlas cell at 2 m repeat** (Branch B territory). Whole image does change (21.7 % of pixels), concentrated in forest/start/deposit bands: `top_left` 21.3 %, `bottom_mid` 8.3 %, `center_start` 0.7 %. |
| E21 | OBSERVED | Code trace of the surviving exceptions after Branch A: `game.gd:2155-2156` skips `mine_mask!=0` (apron keeps `ground1` from `:2141-2143`); `:2158-2159` skips `terrain 1/3/4/5`; `_finalize_mine_tiles():382-385` writes `ground1` again **after** `_assign_tileblocks()`; `:395-398` writes `g0` only where `terrain==2`. These four writes are the only remaining per-cell colour sources near deposits/starts. |
| E22 | OBSERVED | Horizontal luma scan through the right deposit (y=420, x=930–1280) oscillates ≈60→100→60 luma across the band stack; through the left deposit (y=180) ≈55→125→54 — the rings are large-amplitude id changes, not fine grain. |
| E23 | OBSERVED | Gameplay reads of `tileblock`: `world.gd:1195-1205` `_art_name()` is a **visual/winter art-name lookup only**; `game.gd:4211-4245` `can_place()` uses `res_nodes`/spatial grid/`terrain`, not `tileblock`. `mine_mask` is read for mask/smoothing (`game.gd:611-635`, `:2087`, `:2287`, `:2409`) and never derived from `tileblock`. Grep over `variant3d/tests/**/*.gd` and `tools/*.py` finds **no assertion** that apron tileblock equals `ground1` (T2GEN P0-1 is a terrain/mask/parity role, `game.gd:54-57`). |
| E24 | OBSERVED | Winter alias maps `test8`→`winter21` (`WINTER_ART:1831`); `winter_block_for()` at `:1852-1856` is unchanged, so re-id'd cells still alias correctly. |

### 12.3 Exact unified diff (PROPOSAL ONLY — apply after COORD grants `game.gd`)

```diff
diff --git a/variant3d/scripts/game.gd b/variant3d/scripts/game.gd
--- a/variant3d/scripts/game.gd
+++ b/variant3d/scripts/game.gd
@@ -380,6 +380,6 @@ func _finalize_mine_tiles() -> void:
 	if tileblock.size() != MAP_W * MAP_H:
 		return
-	var g1 := _blk("ground1")
+	var g1 := _blk("test8")  # Y08b PORT APPROX: visible worked ground = meadow id; mine_mask/terrain untouched
 	for mi in mine_mask.size():
 		if mine_mask[mi] != 0:
 			tileblock[mi] = g1
@@ -393,6 +393,6 @@ func _finalize_mine_tiles() -> void:
 				if Vector2(float(xx) - sc.x, float(yy) - sc.y).length() <= 16.05:
 					var ci := _t(xx, yy)
 					if terrain[ci] == 2:
 						terrain[ci] = 0
-						if tileblock.size() == MAP_W * MAP_H:
-							tileblock[ci] = g0
+				if tileblock.size() == MAP_W * MAP_H and int(tileblock[ci]) != BLK_WATER:
+					tileblock[ci] = g0  # Y08b: whole start disc visible as meadow id; water kept
 		# Keep every start walkable: stamp relief / collision can otherwise
 		# enclose an AI home slot with rock, breaking scan_map reachability.
@@ -2146,7 +2146,7 @@ func _assign_tileblocks() -> void:
 	# the mine apron, so no per-cell colour ring, spot or checkerboard survives
 	# into UV2.x. Exceptions are only donor-required roles: water, shore/sand,
-	# rock/cliff, worked road/apron. _blk() draws no RNG; no terrain/height/
+	# rock/cliff and roads. Mine worked ground is now visible-meadow too. _blk() draws no RNG; no terrain/height/
 	# blocked write. Placement BEFORE the winter alias keeps season art intact.
 	var meadow_id := _blk("test8")
@@ -2152,8 +2152,9 @@ func _assign_tileblocks() -> void:
 	for i in tileblock.size():
 		if int(tileblock[i]) == BLK_WATER:   # 255, game.gd:52
 			continue
-		if mine_mask[i] != 0:                # real worked ground wins
-			continue
+		if mine_mask[i] != 0:                # Y08b: VISIBLE id only; mask/terrain untouched
+			tileblock[i] = meadow_id
+			continue
 		var role: int = int(terrain[i])
 		if role == 1 or role == 3 or role == 4 or role == 5:
 			continue  # road / water / shore-sand / rock-cliff
```

Net effect: **7 insertions, 6 deletions** (net +1 line), four hunks in one file. No RNG token, no new id
outside the 124-name table, no shader/atlas/test/config change.

**What each hunk does (DERIVED):**
- `g1`: `_finalize_mine_tiles()` runs *after* `_assign_tileblocks()`; without this change it
  would re-paint every apron `ground1` after the final authority. Now both agree on `test8`.
- Start disc: the write is lifted out of `if terrain[ci]==2` and water-guarded; `terrain[ci]=0`
  remains gated exactly as before, so walkability/`blocked` semantics are unchanged.
- Final authority: a `mine_mask` cell (terrain 1 dirt disc, including the feathered rim that
  made the concentric bands) now receives `meadow_id`. `mine_mask` itself is **not** changed.
- `terrain 1` roads with `mine_mask==0`, `terrain 4` shore/sand and `terrain 5` rock/cliff keep
  their donor-required art; `BLK_WATER` still wins.

### 12.4 Backup command and baseline

```powershell
Copy-Item -LiteralPath 'variant3d\scripts\game.gd' -Destination 'inbox\backup\game.gd.bak-Y08B' -Force
Get-FileHash -LiteralPath 'variant3d\scripts\game.gd','inbox\backup\game.gd.bak-Y08B' -Algorithm SHA256
```
Pre-edit baseline (OBSERVED this turn): **257,818 bytes**, SHA-256
`0009F025446BFC62706FCDF5B07B33539FF628CE87AF33193954B384A12EA64C` — the exact post-Branch-A
state. `inbox/backup/game.gd.bak-Y08B` does not exist yet (`Test-Path` = False). Do **not**
overwrite `game.gd.bak-Y08` (pre-Branch-A baseline) or any earlier backup.

Rollback (if granted and applied):
```powershell
Copy-Item -LiteralPath 'inbox\backup\game.gd.bak-Y08B' -Destination 'variant3d\scripts\game.gd' -Force
```
Both hashes must return to `0009F025…EA64C`.

### 12.5 Invariant proof (DERIVED from the diff)

| Invariant | Status | Proof |
|---|---|---|
| `blocked[]` / `height[]` / `terrain[]` | **byte-identical** | no write added or removed; `terrain[ci]=0` still gated by `terrain[ci]==2`; the separate walkability loop (`:401-408`) and its `terrain=5→0` branch untouched. |
| `mine_mask` | byte-identical | only read (`mine_mask[mi]!=0`); never written in any hunk; `_paint_terrain`/`_mark_mine_mask` untouched. |
| `can_place` / deposit snapping / start protection | unchanged | E23: `can_place()` uses `res_nodes`+spatial grid+`terrain`, not `tileblock`; `_snap_free_point` and `map_starts` untouched; start keep-clear still runs on the same disc and still clears `blocked` the same way. |
| Roads / shore / rock roles | preserved | `terrain 1` with `mine_mask==0`, `terrain 4`, `terrain 5` still skip the normalisation; their donor art (`_apply_shore_cliffs`, road pick) unchanged. |
| RNG stream | byte-identical | every hunk is a lookup/value substitution; zero `randf`/`randi` added, removed or reordered; all `_tb_pick` draws, Y04/Y07 guards, `_stamp_grass_spots()` and `_smooth_tilemap()` unchanged. |
| Determinism | preserved | same seed → same bytes; `t_map_variety same_seed_byte_identical` holds. Frozen tileblock hash is not a valid gate. |
| `tileblock` contract | intact | `PackedByteArray`, size `MAP_W*MAP_H`, uint8 79 valid; `BLK_WATER=255` guarded in both the final authority and the new start-disc write. |
| Mine apron gameplay | intact | terrain=1 and `mine_mask` stay exactly as before; only the *visible* art name changes (`world.gd:_art_name`, E23). T2GEN P0-1's terrain/mask parity role preserved. |
| Season / winter | intact | normalisation still before the winter alias (`:2165`); `test8`→`winter21` via `WINTER_ART:1831`; all re-id'd cells alias correctly. |
| B03/Y03/Y05/Y07 + collision-only gradient | intact | no change to `:2008`, guards, spot pass, smoother, or the single stone-quarry `terrain=5` write (`:852`). |
| Z08 relief | intact | no mesh/prop/`world3d.gd` write; relief stays from props + real height. |
| Guards / gates | honoured | no threshold lowered, assertion deleted or expected-failure flipped. |
| S-25-09 | honoured | no noise/dither/hash/luminance field; data-only visibility change. |
| Donor parity | none claimed | universal-meadow visible id for worked ground is **PORT APPROX**; no donor GPU A/B frame exists. |

### 12.6 Acceptance (matched-camera capture + metrics; G04 owns the runner)

Branches: `B1` = current y08 frame (post-Branch-A, matched camera), `B1b` = this proposal.
Same seed 20261113, same camera `(144.1104,58,-88.57262)`, same `--screenshot-frames 10`.

1. **No rings around mines/starts** — C04/G05 R1–R6 visual read: zero nested stepped bands at
   every deposit and start; horizontal luma scans of §12.2 E22 lose their ≈60↔100 oscillation
   and approach the surrounding meadow level; radial luma profiles at ring centres flatten.
2. **No new checker from this change** — clean field crops (E20) must stay pixel-identical to
   B1 (this proposal touches only exception cells); `BV32`/`tile_repeat` there must not worsen.
   The residual texture-level checker remains Branch B's separate A/B — do not attribute it here.
3. **Exceptions still readable** — roads, shore/sand, rock/cliff remain visibly distinct;
   mine/resource entities still sit on their deposits; no new seam/black row;
   `non_black_fraction=1.0`, `full_width_dark_rows=0`, `script_error_lines=0`.
4. **Gameplay dump probe** — optional `--dump-map`: `blocked`, `terrain`, `height`, `mine_mask`
   byte-identical to the B1 same-seed dump; tileblock near deposits/starts dominated by 79;
   no out-of-atlas id. Gates: selftest 29/29, uitest 17/17, `t_render_mode`, `t_map_variety` 5/5
   incl. `same_seed_byte_identical`, `assert_clean CLEAN`, 2D `app/` untouched.
5. **Epistemic** — metrics are movement indicators only, never thresholds or donor parity.
   Whether the rings actually disappear is **UNVERIFIED** until G04 captures and a second agent
   reads. Donor parity stays **UNVERIFIED** (CHARTER §3/§5).

### 12.7 What NOT to do

1. Do not change `mine_mask`, `terrain`, `height`, `blocked`, `res_nodes` or `map_starts` to
   chase the rings — E23 proves they are gameplay sources, not the visible id.
2. Do not remove the road/shore/rock exceptions or the water guard; donor-type art and water
   rendering depend on them.
3. Do not revert Branch A (`game.gd.bak-Y08`), Y05's `:2008`, Y07's guards, B03's collision-only
   gradient or the Z08 relief path.
4. Do not edit the shader for the rings — the field checker is texture-level (E20) and belongs
   to Branch B's separate A/B; no synthetic field (S-25-09).

### 12.8 Status

**READ-ONLY PROPOSAL ONLY.** No hunk in §12.3 was applied; no backup was created; no Godot
process, runner job, queue mutation, donor file or other repo file was touched. Awaiting
COORD's explicit ownership grant for `game.gd`. **No donor parity and no gate PASS claimed.**

### 12.9 APPLIED — Y08b-IMPL (COORD exclusive-ownership grant for `game.gd`)

Status: **APPLIED**. Exactly §12.3's three sites were applied to `variant3d/scripts/game.gd`;
no other repo file was edited by this step (report section only). No runner job, no Godot
process, no queue/lock/counter mutation, no shader/atlas/asset/config/test/donor/git write.

**Backup (taken BEFORE the first edit):**

| Item | Value |
|---|---|
| Command | `Copy-Item -LiteralPath 'variant3d\scripts\game.gd' -Destination 'inbox\backup\game.gd.bak-Y08b' -Force` |
| Pre-edit `game.gd` | **257,818 bytes**, SHA-256 `0009F025446BFC62706FCDF5B07B33539FF628CE87AF33193954B384A12EA64C` — exactly §12.4's baseline, so no intervening edit existed |
| `inbox/backup/game.gd.bak-Y08b` | **257,818 bytes**, SHA-256 **identical**; did not exist beforehand; `bak-Y08`, `bak-Y05`, `bak-Y04`, `bak-Y03`, `bak-L01`, `bak-B03*` untouched |
| Post-edit `game.gd` | **258,079 bytes**, SHA-256 `E6295C02C4E235D98F4792C79668DC1F80D6A492BC3DF69EB077290E6BE17865` |

**Exact applied diff (verbatim `git diff --no-index -- inbox/backup/game.gd.bak-Y08b variant3d/scripts/game.gd`):**

```diff
diff --git a/inbox/backup/game.gd.bak-Y08b b/variant3d/scripts/game.gd
index 6d6bac8e..0a747b41 100644
--- a/inbox/backup/game.gd.bak-Y08b
+++ b/variant3d/scripts/game.gd
@@ -379,7 +379,7 @@ func _finalize_mine_tiles() -> void:
 			_mark_mine_mask(n.pos, 3.0 * TILE)
 	if tileblock.size() != MAP_W * MAP_H:
 		return
-	var g1 := _blk("ground1")
+	var g1 := _blk("test8")  # Y08b PORT APPROX: visible worked ground = meadow id; mine_mask/terrain untouched
 	for mi in mine_mask.size():
 		if mine_mask[mi] != 0:
 			tileblock[mi] = g1
@@ -394,8 +394,8 @@ func _finalize_mine_tiles() -> void:
 					var ci := _t(xx, yy)
 					if terrain[ci] == 2:
 						terrain[ci] = 0
-						if tileblock.size() == MAP_W * MAP_H:
-							tileblock[ci] = g0
+				if tileblock.size() == MAP_W * MAP_H and int(tileblock[ci]) != BLK_WATER:
+					tileblock[ci] = g0  # Y08b: whole start disc visible as meadow id; water kept
 		# Keep every start walkable: stamp relief / collision can otherwise
 		# enclose an AI home slot with rock, breaking scan_map reachability.
 		for yy in range(maxi(0, int(sc.y - 16.0)), mini(MAP_H, int(sc.y + 16.0) + 1)):
@@ -2146,13 +2146,14 @@ func _assign_tileblocks() -> void:
 	# patch (0,0) constant 1.0) AFTER smoothing, forest borders, L01 spots and
 	# the mine apron, so no per-cell colour ring, spot or checkerboard survives
 	# into UV2.x. Exceptions are only donor-required roles: water, shore/sand,
-	# rock/cliff, worked road/apron. _blk() draws no RNG; no terrain/height/
+	# rock/cliff and roads. Mine worked ground is now visible-meadow too. _blk() draws no RNG; no terrain/height/
 	# blocked write. Placement BEFORE the winter alias keeps season art intact.
 	var meadow_id := _blk("test8")
 	for i in tileblock.size():
 		if int(tileblock[i]) == BLK_WATER:   # 255, game.gd:52
 			continue
-		if mine_mask[i] != 0:                # real worked ground wins
+		if mine_mask[i] != 0:                # Y08b: VISIBLE id only; mask/terrain untouched
+			tileblock[i] = meadow_id
 			continue
 		var role: int = int(terrain[i])
 		if role == 1 or role == 3 or role == 4 or role == 5:
```

Three sites / three diff hunks: `g1` (`:382`), start-disc write (`:397-398`), final-authority
comment + `mine_mask` branch (`:2149`, `:2155-2156`). `git diff --no-index --numstat` →
**6 insertions, 5 deletions** (net +1 line). §12.3's "7/6" estimate counted the unchanged
`continue` line as removed/re-added; the **resulting source is exactly the §12.3 final state**.
No whitespace errors reported by `git diff --no-index --check`.

**Static verification (no Godot, OBSERVED):**
- `var g1 := _blk("test8")` at `:382`; `var g0 := _blk("test8")` at `:388`; water-guarded
  start write at `:397-398`; `var meadow_id` at `:2151`; `tileblock[i] = meadow_id` twice
  (`:2155` mine branch, `:2160` ordinary branch).
- Zero `randf(`/`randi(` tokens in the `_finalize_mine_tiles()` region (375–405) and in the
  final-authority region (2144–2162).
- Y05 `:2008` `test8`, four Y07 guards (`:2333/2337/2341/2345`), `_stamp_grass_spots()` `:2130`,
  `_smooth_tilemap()` `:2134` and winter alias `:2166` all present in the expected order.
- Exactly one executable `terrain[…] = 5` write (stone-quarry disc `:852`).
- Comment/string-stripped bracket balance: `()` 3740/3740, `[]` 1356/1356, `{}` 257/257.

**Invariants (DERIVED; re-check with the optional dump probe):**

| Invariant | Status | Proof |
|---|---|---|
| `blocked[]` / `height[]` / `terrain[]` | byte-identical | no write added/removed; `terrain[ci]=0` still gated by `terrain[ci]==2`; walkability loop `:401-408` untouched. |
| `mine_mask` | byte-identical | only read; `_paint_terrain`/`_mark_mine_mask` untouched. |
| `can_place` / deposit snapping / start protection | unchanged | E23: gameplay uses `res_nodes`/spatial grid/`terrain`, not `tileblock`; `map_starts` and the blocked-clearance loop untouched. |
| Roads / shore / rock / water | preserved | `terrain 1` with `mine_mask==0`, `4`, `5` still skip; new start write is `BLK_WATER`-guarded. |
| RNG stream | byte-identical | three sites are lookups/value substitutions; zero RNG tokens added, removed or reordered; all `_tb_pick` draws/guards/spot pass/smoother verbatim. |
| Determinism | preserved | same seed → same bytes; `t_map_variety same_seed_byte_identical` holds. Frozen tileblock hash is not a valid gate. |
| `tileblock` contract | intact | `PackedByteArray`, size `MAP_W*MAP_H`, uint8 79 valid; `BLK_WATER=255` never written. |
| Mine apron gameplay | intact | terrain=1 + `mine_mask` unchanged; only the visible art name changes (`world.gd:_art_name`, E23); T2GEN P0-1 terrain/mask role preserved. |
| Season / winter | intact | normalisation still before winter alias `:2166`; `test8`→`winter21` (`WINTER_ART:1831`). |
| B03/Y03/Y05/Y07/Y08 Branch A + collision-only gradient | intact | no change to `:2008`, guards, spot pass, smoother, `:852`, or the Branch-A block other than the two §12.3 lines. |
| Z08 relief | intact | no mesh/prop/`world3d.gd` write. |
| Guards / gates / S-25-09 | honoured | no threshold lowered, assertion deleted, expected-failure flipped, or synthetic field added. |
| Donor parity | none claimed | visible-id substitution is **PORT APPROX**; no donor GPU A/B frame exists. |

**G04 gate list (Y08b-IMPL runs none):**
1. selftest **29/29**; uitest **17/17**; `t_render_mode` green; `t_map_variety` **5/5** incl.
   `same_seed_byte_identical`; `assert_clean CLEAN`; `script_error_lines == 0`,
   `non_black_fraction == 1.0`, `full_width_dark_rows == 0`; 2D `app/` untouched.
2. Matched-camera `--seed 20261113` capture (camera `(144.1104,58,-88.57262)`, unique id),
   C04/G05 R1–R6 read: **no concentric rings around mines/starts**, clean field crops
   (E20) unchanged, roads/shore/rock still distinct, no new seam/black row.
3. C01 `terrain_ab_metric.py` on the identical crop — movement indicators only, never
   thresholds or donor parity; compare against the y08 (B1) frame.
4. Optional `--dump-map`: `blocked`/`terrain`/`height`/`mine_mask` byte-identical to the B1
   same-seed dump; tileblock near deposits/starts dominated by 79; no out-of-atlas id.

**Rollback:**
```powershell
Copy-Item -LiteralPath 'inbox\backup\game.gd.bak-Y08b' -Destination 'variant3d\scripts\game.gd' -Force
Get-FileHash -LiteralPath 'variant3d\scripts\game.gd','inbox\backup\game.gd.bak-Y08b' -Algorithm SHA256
```
Both hashes must return `0009F025446BFC62706FCDF5B07B33539FF628CE87AF33193954B384A12EA64C`
(257,818 bytes), restoring the exact post-Branch-A state.

**Epistemic status:** no Godot, runner job, queue mutation, donor file read/copy or other
source edit occurred in this implementation step. Whether the rings actually disappear is
**UNVERIFIED** until G04's matched-camera capture and a second-agent visual read. **No donor
parity and no gate PASS claimed** (CHARTER §3/§5).

*End of Y08 report (analysis + follow-up + Y08-IMPL + Y08b proposal + Y08b-IMPL). Stay available.*
