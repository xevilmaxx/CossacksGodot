---
id: TERRAIN-MARKS-01
title: "Donor-primary diagnosis — why a generated map shows pale/white marks on flat land instead of hills"
agent: "Donor-primary diagnosis worker (read-only subagent), coord swarm 2026-11-25"
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB
scope: "One new file only: this report. No source, asset, config, PNG, JSON, stderr, shader, fixture or git edit; no Godot submission; no donor access; no ladder advancement."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
image: "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\p0fresh01\\p0_final_formula.png"
labels: [observed, derived, inferred, UNVERIFIED]
parity_guard: "PORT APPROX — internal consistency only. No donor GPU A/B frame exists. No donor parity is claimed anywhere in this report."
verdict: "PRIMARY = RELIEF STAMP PATH IS OFF IN THE CAPTURED/DUMPED CONFIGURATION; PALE MARKS ARE A DOWNSTREAM TILE-ART SYMPTOM, NOT DONOR RELIEF. Image under review contains NO white marks at all."
---

# TERRAIN MARKS 01 — white marks on flat land instead of hills

## 0. Mandate and boundary

Diagnose the owner report (read-only): "generated terrain looks strange, almost as if
the pattern should represent hills, but there are no hills — only white marks on
plain land; maybe the marks are not correctly interpreted." All conclusions below
are labelled **observed** (literal source bytes/lines, published measurement, or
direct image read), **derived** (arithmetic/control-flow consequence), **inferred**
(attribution without a pixel-aligned donor A/B), or **UNVERIFIED**. No donor frame
exists; **no parity claim** is made. Nothing was edited and no runner job was
submitted.

---

## 1. Image observations — supplied P0 PNG

**Artifact opened:** `p0fresh01/p0_final_formula.png`, 1280×720, 2,129,263 B,
ticket 504 capture (RECHECK-P0-FINAL §1).

### 1.1 Direct visual read (observed)

The whole frame is a non-blank olive / yellow-green grass field with fine, fairly
even grain. No sky, horizon, water band, shoreline, tile grid, checkerboard, seam,
tree, mine or unit appears. Faint low-contrast darker mottling / streaking is
discernible roughly in the **centre-left and lower-middle** (approximately
x≈250–650, y≈350–650); it is diffuse, not grid-aligned and not a structured
object. This matches the independent reading in `RECHECK_P0_FINAL.md:160-167`
(olive field, faint mottling centre-left/lower-middle, no defect).

**Decisive observation: there are NO white marks in this frame.** No discrete
pale patch, feather edge or bright cell is visible anywhere, at any coordinate.
The owner's symptom is therefore **not present in the supplied capture**; the
image can only test the "olive field / faint mottling" state, not the reported
marks. This is a scoping fact, not a refutation of the owner's separate frame.

### 1.2 Quantitative scan (observed; inline read-only Python/PIL, no file written)

| Metric | Value |
|---|---:|
| Image luma range (0.299R+0.587G+0.114B) | min **10.36**, max **149.007**, mean **88.447** |
| Channel maxima over all pixels | R **160**, G **167**, B **59** |
| Pixels with luma > 160 / > 180 | **0 / 0** |
| Pixels with luma > 130 | **233** = 0.025% of 921,600; bbox spans (1,5)–(1277,718), i.e. scattered, not clustered |
| 4×3 quadrant mean luma | top row 86.7/85.7/85.0/84.3 → bottom row 95.3/93.3/91.0/88.8 (mild bottom-left brightening only) |

No pixel is neutral/bright enough to be called white: the maximum channel values
are olive (B ≤ 59). Bright outliers are isolated single pixels spread over the
whole frame, not marks. **Derived:** the supplied P0 PNG is a uniformly lit ground
field; its brightest pixel (149) is below RECHECK-P0-FINAL's reported JSON
`max_luma=155.163` (`RECHECK_P0_FINAL.md:104,114`) because the two use different
luma formulae — both are olive, not white.

### 1.3 Why this capture cannot contain relief or marks (observed, from source)

- The P0 atom's fixture is a **synthetic, deterministic, in-memory 64×64 grid**,
  deliberately flat: `t_terrain_only.gd:36-39` (tileblock all grass id 0; height
  deltas ≈0.005 m ≪ `cDiff1=0.5`); height range in the result JSON is
  **1.450006–1.549986 m** (`variant3d/tests/results/t_terrain_only.json:159-160`).
- `uv2_y_hist={"0":4096}`, `flat_grid_promoted_cells=0`, `water_tileblock_cells=0`
  (`t_terrain_only.json:156,183-189`; RECHECK-P0-FINAL §3.1/§5): **no face
  promotion, no cliff/rock tile, no water tile** — so no rock8/rock4 and no test*
  transition id can appear in this frame's tile stream.
- The harness dump carries only `map_w/map_h/height/tileblock`
  (`variant3d/tests/fixtures/_smallmap_harness.gd:118-128`): **no
  `relief_stamps` key**, so the consumer returns 0 and no donor-grid stamp fires.
- Expected structural state (`RECHECK_P0_FINAL.md:121-129`): 1 surface, 4,096
  verts, 7,938 tris, atlas (16,8), shadow off, water plane hidden.

**Derived:** the P0 frame is a flat-grass control. It is useful to show what the
relief-off state looks like (uniform olive) and to bound which hypotheses are
testable here, but it cannot discriminate a relief-on symptom.

---

## 2. Ranked hypothesis table

Each row states the mechanism, the source evidence with `path:line`, the status
against source **and** image, and the rank. "Refuted for P0" means the supplied
capture cannot exhibit the mechanism; it does not refute the mechanism in a
different frame.

| Rank | Hypothesis | Evidence (`path:line`) | Status |
|---:|---|---|---|
| **1** | **(a) `relief_stamps` opt-in is false, so no donor heights are stamped.** | `config.gd:54-61` (`"relief_stamps": false` default), `config.gd:448-449` (`flag("features.terrain.relief_stamps", false)`); `main.gd:741-761` (producer built but gated), `main.gd:762-777` (key emitted **only** when `relief_enabled`); no `features` block in `variant3d/config.json` or `app/config.json` (grep: no match) → default false is effective; `world3d_terrain.gd:518-522,1185-1189` (reader returns 0 with no key); `_smallmap_harness.gd:123-127` (no key in P0 dump). | **CONFIRMED (observed)** for the dump/P0 path: the RELIEF-01/02 donor-grid path is provably inert. **Explains the absence of donor-grid hills; does not itself create white marks.** Image: consistent — flat uniform field, no stamp patch. |
| **2** | **(c) Tile-index/colour mapping of `rock8`/`rock4` or `test*` renders pale marks without relief.** | `game.gd:1771-1795` (`_apply_detail_pass`: donor `tile_low/highground` R÷2 writes tile ids on flat cells, h<0.1 selects lowground); `game.gd:1420-1494` (donor smoothing lists place `test7/8/9`, `rock4/8`); `game.gd:1937-1970` (`_cliff_tile_for`: `rock8` if `abs(h)>2.7`, `rock4` if `>2.4`, none if `<0.1`); `world3d_terrain.gd:1263-1293` (face promotion maps to `rockNvf/vs` ids); `shader:330-335` (`tile_rgb` samples whole atlas cell per tile id); block art: `test8.png` max RGB (222,231,148), `rock4.png` max (255,239,189) but olive/brown means ≈(73,78,28)/(71,62,50) (read-only PIL). `TRN_DATA_implementation.md:54-64`: `test7+test8` ≈14.9% and `test9` ≈0.84% of cells offline; `V3D_02_terrain_render_audit.md:86` (P1). | **PARTIALLY CONFIRMED as a mechanism, REFUTED for this PNG.** `test*` ids truly can land on flat land from donor bitmap bytes (no height gate), and their art contains bright speckles that can read as pale marks; `rock8/rock4` **require** real height (h>2.4/2.7) so they cannot explain marks on genuinely flat cells. Image: `tileblock` is all id 0 and `face_hist` has no promoted cells → no such tile in frame. **Best available explanation for the owner's pale marks if their frame is a real generated map.** |
| **3** | **(b) `plt2` marker present, but additive-clamp coarse-grid downsample yields flat pale decal-like cells rather than hills.** | `world3d_terrain.gd:185-243` (8×10 block-mean tables from DPATTERN-01 Appendix A, flagged debug/preview only), `:461-509` (`height[idx] = clampf(height[idx] + coarse[...]*scale, lo, hi)` — **writes geometry**, not colour), `:518-553` (marker reader); `DPATTERN_01_relief_grids.md:615-626` (A2 `plt2` means: a ≈3.0–3.4 plateau cap spanning several adjacent coarse cells), `:595-600` ("debug/preview aids only — stamp from the full grid"), `:348-382` (engine blend UNVERIFIED); `RELIEF_01_stamping.md:117-131,166-184` (additive-clamp is PORT APPROXIMATION; `plt2` max +3.6134 exceeds port cap +2.964). | **CONFIRMED mechanism when enabled, REFUTED for this PNG.** The code does change `height[]` (so "decal instead of geometry" is wrong); but block means + per-pattern clamp produce a flat-topped, 10×8-cell saturated patch — visually a flat colour patch, not a rounded hill. Requires flag on + a marker; P0 has neither (rank-1 evidence). Also note `game.gd:1087-1097` later clamps land to ±2.964, which would cap the +3.6134 cap and flatten it further. |
| **4** | **(e) Donor height grid clamped/zero (32–64% exactly 0.0), so marks are authored colour not geometry.** | `DTRN_02_donor_terrain_geometry.md:102-106` (C6/C7: `.pattern` float32 grids **are** height geometry; C10: baked `.map` 31.97%/64.31% at exactly 0.0); `DPATTERN_01_relief_grids.md:142,154,237-249,562-584` (decoded non-zero grids; `plt2` min −0.07325/max +3.61341; engine sculpt UNVERIFIED); `GAPS.md:33` (geometry/relief row: "MESH CORRECT, SOURCE WRONG"). | **REFUTED as stated (observed).** The zero fraction describes *base flat land*, not the relief stamps; donor relief is authored height geometry plus optional 3D props. The port-side correlate of the observation is real but different: the P0 fixture is flat by construction (§1.3), and the live map's relief must come from stamps that are gated off (rank 1). |
| **5** | **(d) `alpha.bmp` patch selection producing white feather seams.** | `shader:338-375` (8×4 alpha grid, tile-id-derived patch; constant patches (0,0)/(4,0)=255 "no transition", (3,3)/(7,3)=0 "full cut"; exact tile→patch rule CONFIRMED_UNVERIFIED), `:417` (sample `.a`), `:469` (`ALPHA = mix(1.0, a, mask_to_alpha)`); `V3D_02_terrain_render_audit.md:89` (P4, mask sub-rect APPROX/UNVERIFIED); `DALPHA` citations inside shader. | **REFUTED for P0; UNVERIFIED generally.** P0's tile id is 0 ⇒ patch cell (0,0) = constant 255 ⇒ fully opaque; no feather, and the image shows no seam or bright edge. In a real generated map a wrong patch could expose bright sky through low alpha, but that would be 2 m grid-aligned and is not demonstrated by any frame here. |

### 2.1 Cross-checks that sharpen ranks 1–3

- **`plt2` is genuinely producible but only when the flag is on.** `main.gd:751-757`
  filters `game.pattern_stamps` to `plt2`/`k_ravine_1`; `k_ravine_1` is absent from
  `donor_patterns.json` and unreachable (`RELIEF_02_stamp_marker.md:68-84,144-160`),
  so at most one relief id can ever be stamped. With the flag off, even that array
  is never attached to the dump.
- **The live simulation has a *parallel*, non-gated relief path.**
  `game.gd:858-981` (`_shape_stamp_relief`) still stamps analytic plateau/hill/ravine
  profiles from donor pattern footprints, called at `:1080`; heights are clamped at
  `:1087-1097`. **Derived:** "no hills" in a normal game is *not* solely the flag —
  those analytic shapes exist but are ≤2.964 m over a 640 m map (≈0.46%), and
  normals/face promotion smooth them (`V3D_02` P8 `:93`, P14 `:99` already resolved
  scale as internally consistent). The RELIEF-01/02 opt-in path is the *donor-grid*
  replacement that is off.
- **Tile art is the only plausible source of literal pale/white pixels.**
  No source path writes white colour from a height stamp: the stamp writes
  `height[]` only (`world3d_terrain.gd:495`); pale pixels must enter through the
  atlas (`tile_rgb`, shader `:330-335`) or alpha/sky blend (shader `:469`). This
  is why rank 2 is preferred for the *marks* and rank 1 for the *missing hills*.

---

## 3. Verdict

**observed / derived:**
1. The supplied P0 PNG contains **no white marks**; it is an olive, uniformly
   grained, deliberately flat 64² control frame. The owner's symptom must come
   from a different frame (a real generated map), not from this artifact.
2. In the captured/dumped configuration the donor relief-grid path is **off**:
   `features.terrain.relief_stamps` defaults to `false` (`config.gd:59,448-449`),
   `main.gd` omits the marker key, and the consumer stamps nothing. This is the
   primary, source-confirmed reason donor-authored grid hills do not appear.
3. The port still has its own analytic relief (`game.gd:858-981`); it is not zero,
   but it is a labelled geometric approximation and is flattened by the later
   ±2.964 clamp (`:1087-1097`).
4. Pale marks without hills are best explained by **tile-id colour**: donor
   bitmap/smoothing rules can place `test*` transition ids on flat cells
   (`game.gd:1771-1795`, `TRN_DATA` §2), and their art contains bright speckles;
   `rock8/rock4` are height-gated and cannot be the cause on truly flat land.
5. The `plt2` additive-clamp helper is real geometry, not a decal, but its
   coarse 8×10 block means and per-pattern clamp would give a flat-topped
   10×8-cell patch rather than a hill **if** enabled — a plausible contributor to
   "pattern looks like a flat mark", not to the supplied P0 frame.

**inferred / UNVERIFIED:** which of these mechanisms produced the owner's exact
frame cannot be settled from this artifact. No donor GPU A/B exists; all visual
attribution is PORT APPROXIMATION and donor parity is UNVERIFIED.

---

## 4. Exact discriminating test (proposed, NOT run)

One controlled A/B on the existing dump + capture path, same seed and camera:

1. **Flag:** override `features.terrain.relief_stamps` to `true` in a temporary
   config passed via `--config <abs>/relief_on.json` (config merge is documented at
   `config.gd:1-10,86-89`). Leave all other config identical; keep the same
   `64²` or `320²` fixture and seed. Controlled counterpart: the same run with the
   flag `false` (current default).
2. **Dump assertion (cheapest first):** run the `--dump-map` path (`main.gd:725-784`)
   and inspect the produced JSON.
   - `relief_stamps` key **absent** ⇒ flag/producer is the cause (rank 1 confirmed).
   - Key present with a `plt2` entry ⇒ producer works; go to step 3.
   - Key present but empty ⇒ the seed placed no `plt2` stamp
     (`RELIEF_02` open question 1) — still no hills, no producer bug.
3. **Consumer assertion:** load that dump into the terrain module and read
   `stats["relief_grid"]` (`world3d_terrain.gd:1441-1454`): `applied > 0`,
   `stamps` non-empty, and `height_min_m`/`height_max_m` shifted versus the
   flag-off dump (`:1189-1195`). If `applied == 0` while markers exist, the fault
   is in the name/footprint reader (`:518-553`), not the flag.
4. **Capture:** use the existing fixed-camera terrain-only capture
   (`t_terrain_only.gd` / `smallmap_capture.py`); **replace the harness stub dump**
   at `_smallmap_harness.gd:123-127` with the real dump from step 2 — the current
   stub has no `relief_stamps` key, so the P0 atom will always show the flat state.
   Compare the two PNGs by (i) presence of a discrete patch at the stamp centre
   `(cx,cy)` from the dump, (ii) changed-pixel count / luma delta, and (iii) whether
   the pale marks coincide with the height-changed cells. Record
   `SCRIPT ERROR == 0` on both stderrs.
5. **Tile-id isolation (only if marks persist with relief off):** in the dump,
   histogram `tileblock` for `test7/8/9` and `rock4/8` over the marked cells and
   check them against the local `height[]` gradient; if the ids appear where
   `|dh| < 0.5`, marks are tile-art-only (rank 2).

**Interpretation guard:** this A/B tests the port's own opt-in path only. It does
not validate the donor engine blend (`Replace`/`Smooth` order UNVERIFIED,
`DPATTERN_01 §5.2`) and yields **no donor parity claim**.

### Single owner file most likely responsible

**`variant3d/scripts/config.gd`** — specifically `FEATURES_DEFAULTS.terrain.relief_stamps = false`
at `:59` and the accessor `feature_terrain_relief_stamps()` at `:448-449`. It is the
one switch that keeps the entire donor-grid relief path out of the dump and out of
the mesh; flipping it is the discriminating test above. Secondary (pale marks, not
missing hills): `variant3d/scripts/game.gd:1771-1795` (tile-id from donor bitmap on
flat cells). Neither file was edited by this worker.

---

## 5. Open questions (UNVERIFIED — do not guess)

1. Which frame/seed/config produced the owner's white marks? The supplied P0 PNG
   does not contain them; without that artifact the visual attribution stays
   **inferred**.
2. Does any real generated 320² map place a `plt2` stamp at all? The producer can
   emit it (`main.gd:751-757`) but no runtime dump-content assertion exists
   (`RELIEF_02` §7 Q1).
3. If the flag is enabled, does the later global cap (`game.gd:1096-1097`, +2.964)
   interact with `plt2` max +3.6134 (`world3d_terrain.gd:238`) — and does the
   coarse 8×10 mean produce a flat plateau a viewer would call a "mark"?
4. Are the owner's marks grid-aligned (tile/alpha patch) or free-form (height-driven
   cliff art)? This single observation separates rank 2 from rank 3/5.
5. Is the exact donor tile→alpha-patch rule recoverable? Currently
   CONFIRMED_UNVERIFIED (`shader:343-362`; `V3D_02` P4/F4).
6. Does the live game's analytic relief (`game.gd:858-981`) actually read as hills at
   the port's fixed camera? Local 1-cell normals are now used
   (`world3d_terrain.gd:1459`), but no matched camera A/B exists.
7. Donor parity of hue, grain, relief silhouette and luma remains blocked: no donor
   GPU A/B terrain frame exists (`RECHECK_P0_FINAL.md:232-235`).

---

## 6. Summary

Read-only diagnosis of TERRAIN-MARKS-01. Direct image inspection plus an inline
pixel scan show the supplied `p0_final_formula.png` is a flat, uniformly olive
64² control frame with **no white marks** (max luma 149; zero pixels above 160;
brightest outliers scattered, not clustered) — consistent with
`RECHECK_P0_FINAL.md`'s olive-field/faint-mottling description. Source tracing
establishes that the donor relief-grid path is off in this configuration:
`config.gd:59,448-449` defaults `features.terrain.relief_stamps` to false,
`main.gd:762-777` then omits `relief_stamps` from the dump, and
`world3d_terrain.gd:518-522,1185-1189` consequently stamps no heights; the P0
harness dump (`_smallmap_harness.gd:123-127`) has no marker key at all. The live
simulation's separate analytic relief (`game.gd:858-981`) still runs, but is a
labelled geometric approximation later flattened to ±2.964 (`:1087-1097`).
Ranked causes: (1) opt-in flag off — confirmed, explains missing donor-grid hills;
(2) `test*`/`rock*` tile-id colour on flat cells — partial mechanism, best
explanation for pale marks in a real map, refuted for this PNG; (3) `plt2`
coarse-grid additive clamp — real geometry but flat-topped patch when enabled,
refuted for this PNG; (4) donor zero-heights-are-colour — refuted from donor
truth; (5) alpha patch feather seams — refuted for tile id 0, UNVERIFIED
otherwise. Discriminating test: flag-on vs flag-off `--dump-map` plus fixed-camera
capture with the harness stub dump replaced by the real dump, asserting marker
presence, `stats.relief_grid.applied`, and height-range change. Single owner file
most likely responsible: `variant3d/scripts/config.gd`. **No donor parity claim;
donor parity UNVERIFIED. No file was edited; no runner job was submitted.**

---

*End of TERRAIN MARKS 01. Read-only diagnosis; no code/asset/config/PNG edit, no Godot job, no donor access, no ladder advancement.*
