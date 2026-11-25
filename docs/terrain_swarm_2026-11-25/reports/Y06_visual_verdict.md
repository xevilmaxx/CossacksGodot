---
id: Y06
ticket: Y06 — SECOND-AGENT VISUAL REVIEW (post-Y03 capture)
role: READ-ONLY / INDEPENDENT VISUAL REVIEWER (not the builder of the frame)
created: 2026-11-25
status: REPORT_ONLY__NO_RUNNER__NO_CODE_OR_ASSET_EDIT__NO_DONOR_PARITY_CLAIM
scope: "Exactly one output file: docs/terrain_swarm_2026-11-25/reports/Y06_visual_verdict.md. No Godot launch, no runner submission/queue mutation, no .gd/.gdshader/config/asset/test/tool/fixture/result edit. Temporary PNG crops used for the read were written outside the repo under C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\y03\\ and are analysis artifacts only."
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED]
parity_guard: "PORT APPROX — internal consistency only. 'Reads like the reference samples' below is an INFERRED comparative judgement tied to named features, never donor-parity certification. No donor GPU A/B frame exists. Donor parity stays UNVERIFIED."
governing_sources:
  - docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md — standing rules (G04 sole runner owner; one report per agent; no donor-parity claim)
  - docs/terrain_swarm_2026-11-25/CHARTER.md — §1 symptom, §1b, §3 guardrails, §5 definition of good
  - docs/terrain_swarm_2026-11-25/reports/C04_visual_review.md — §1 labels, §2 capture integrity, §3 R1–R8 region map, §5 metric hierarchy, §7 sign-off
  - docs/terrain_swarm_2026-11-25/reports/G21_acceptance_checklist.md — §4 acceptance cards, §5 sign-off, §6 metric-never-overrides
  - docs/terrain_swarm_2026-11-25/reports/C01_metric_tool.md — field semantics
  - variant3d/tools/terrain_ab_metric.py:24-32,60-63 — CLI, SMOKE METRIC label
---

# Y06 — visual verdict on the post-Y03 real-map capture

## 0. What this review is

A second-agent visual read of the capture supplied at
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\y03\realmap.png`, applying C04's
R1–R6 region protocol and G21's acceptance cards. Each region is **described in words
before a verdict is given** (C04:56). Pixel descriptions are OBSERVED; causes and
"reads like the samples" are INFERRED; anything not in the supplied evidence is
UNVERIFIED and is never converted to PASS (C04:49,52,57).

C01's `terrain_ab_metric.py` was run locally on file paths **as corroboration only**.
No number below overrides the visual read (C04:138, G21 §6). No Godot was run and no
runner job was submitted (WAVE_G_CHARTER.md:31).

Reference samples opened: `C:\Users\Maxym.Oboyshev\Downloads\c3\cossacks-3-v1-498085.jpg`
(ref A: rolling green ground with large soft mottling, dark/light patches, grey ravine
cliff faces with vertical striations, trees; no grid, streaks or repetition),
`...\articolo-787.jpg` (ref B: rolling relief, patchy grass, natural transitions), and
`...\maxresdefault_1.jpg` (natural grass → sand → water shore). These are descriptions
of donor stills, **not** a donor GPU A/B frame.

---

## 1. Evidence and admissibility

| Item | Finding |
|---|---|
| Candidate frame | `...\opencode\y03\realmap.png` — image opens, 1280×720, non-blank, real scene content (building, units, trees, terrain). Frame fill is terrain; there is **no sky/horizon band** in this camera pose — the whole frame is ground plus objects. |
| Sidecar | `...\y03\realmap.png.raw.png` present, same byte length as the final PNG (1,385,801 bytes). No `screenshot capture diag` text was supplied alongside it, so a raw-sidecar acceptance reason is UNVERIFIED. |
| y03 folder contents | Only `realmap.png` and `realmap.png.raw.png`. **No** `stdout.txt`, `stderr.txt`, `config.json`, `frames.json`, or `screenshot capture diag`. Therefore `script_error_lines: 0`, seed/harness/camera pinning, and windowed/no-headless launch are **UNVERIFIED** for this frame (C04 §2 items 1,3,4; G21 G0-a…e). This is recorded, not papered over. |
| Quad / ghost | No `before|during|after.png` or `ghost_valid|ghost_invalid.png`, no `frames.json`, and no result JSON with an asserted `input_ctl`-inclusive capture path exists for Y03. Adjacent `y04` holds only `before_*`/`after_*` terrain crops, not quad/ghost interaction frames. **R7 and R8 are UNVERIFIED (NO CAP-3 FRAMES)** — a capture-completeness finding, not a claim that the quad or ghost is broken (C04:108-109, G21:178-190). |
| Prior baselines opened | `...\opencode\g04\realmap.png` and `...\opencode\l07c\realmap.png`, both 1280×720. |

**Camera caveat (binding).** The Y03 pose differs from both baselines: the main building
sits at roughly **x500–790 / y110–350** in Y03 versus roughly **x620–820 / y150–370** in
g04 and l07c — a leftward shift of ~120 px and an upward shift of ~40 px, with at most a
small zoom change. No camera matrix or seed was supplied for any of the three frames.
Therefore **cross-capture attribution is UNVERIFIED** (C04:79, G21 §2 step 4): the
comparison below is direction-of-change description only, never a controlled A/B.

---

## 2. Region-by-region read — description first, then verdict

All boxes are approximate pixels in the 1280×720 frame, y down. Crops were taken from
the same PNG (outside the repo) to scan each box closely; boxes were not shrunk to avoid
an artifact (C04:98).

### Frame fill, boundary, tonal range (described before items)

**R0 / y03 realmap / OBSERVED** — The frame is entirely ground viewed from a steep
three-quarter/top-down angle; no sky or horizon. Terrain is dark olive/khaki green with
tan-grey patches; mean luma is lower than both baselines (see §3). Three lighter
blocky patches around grey rubble/resource clusters sit at upper-left (~x275–470/y110–225),
left-middle (~x245–455/y390–505), centre-right (~x950–1210/y305–455). A large wooden
church/hall dominates the centre (~x500–790/y110–350) with two smaller huts and units;
trees occupy a clearing at upper-right (~x900–1200/y50–290) and scattered trees at
lower-left (~x0–240/y390–720). No cyan water appears anywhere in the frame.

---

### R1 — tiling periodicity / grid / checker

**R1 / y03 / OBSERVED** — Scanned full ground band (x120–1160/y60–640) in three strips
(y40–220, y220–500, y500–690) and in close crops of the upper-left and centre. The
ground carries a **regular corrugation of thin horizontal light/dark lines**, at roughly
4–7 px spacing, running across nearly the whole field. Superimposed on it are
**brick-like checker patches**: small alternating olive rectangles of near-equal size,
visible at ~x180–420/y100–200, ~x300–560/y420–520 and ~x900–1210/y305–455. In the
resource patches the rectangles alternate light tan and dark olive in a clear grid.
C01 beside this read: `tile_repeat 0.796493`, `tile_period_px 45`, `tile_axis "x"`,
`seam_repetition_driver "tile_repeat"`, `col_periodicity 0.319515`, `row_periodicity
0.222709`.

**R1 / DERIVED** — `tile_best_mad 3.698389` versus `tile_baseline_mad 20.289406` is a
~5.5× drop at the detected 45 px period; the metric independently finds a repeated
patch at that cadence.

**R1 / INFERRED (caveated)** — The corrugation and rectangular cells are consistent with
a repeated atlas cell / mask patch being sampled at a shallow camera angle, but this
frame alone does not prove the cause; a different harness or camera could change the
appearance.

**R1 / UNVERIFIED** — Exact world tile cadence and camera transform at capture time.

**R1 verdict: FAIL.** A visible regular repeating band and checker mosaic are present in
the named boxes. Per C04:138 and G21:142, a low neighbouring metric would not close
this; here the metric agrees.

---

### R2 — diagonal streaks / moiré

**R2 / y03 / OBSERVED** — In x200–720/y200–480 (densest x300–620/y300–450) the dominant
signal is **long, near-horizontal parallel strokes**, evenly spaced, alternating a few
luma counts above and below the field, continuing uninterrupted across hundreds of
pixels. In the right half (x640–1280/y0–340) the same horizontal banding is visible
behind the trees and around the nested outlines. The lower-left curved band
(x0–430/y500–690) is partly a flat green clearing with trees and partly nested contour
lines; it is not a moiré stroke field. The strokes are **not** diagonal in this frame —
they are screen-horizontal — but they are regular, parallel and non-organic, and they
read as repetition. C01 beside this read: `streak_angle_deg 176.11654`,
`gradient_angle_deg 86.11654`, `band_peak_deg 90`, `coherence 0.311491`,
`diag_excess 0.021048`, `diag_minus_axis -0.079185`.

**R2 / DERIVED** — `coherence 0.311491` against the donor-still median `0.054378`
(z `+10.995572`) is ~5.7× the reference median; the tool flags
`gradient_anisotropy: candidate 0.3115 is > 2x the reference 0.05438`.

**R2 / INFERRED (caveated)** — Consistent with camera-dependent texgen/minification
aliasing; not proven by this single frame, and no second camera pose was supplied to
test whether the strokes move with the camera.

**R2 / UNVERIFIED** — Whether the same strokes appear at another camera pose; donor
parity.

**R2 verdict: FAIL.** The named boxes contain regular parallel banding that reads as
moiré/repetition. The protocol's "curved organic band or true cliff edge is not
automatically a streak" carve-out does not apply to these straight, evenly spaced
lines; the nested contour bands are counted under R5 instead. The direction is
horizontal rather than the baseline's diagonal, so the *orientation changed*, not the
presence of a regular stroke artifact.

---

### R3 — dark blotches / repeated dark patches

**R3 / y03 / OBSERVED** — Lower-middle x350–950/y480–620: the dark regions are the
lower halves of the horizontal stripes and a **blocky checker of alternating dark olive
rectangles** around x560–850/y500–600; the same rectangular dark cells recur in the
resource patches at x300–560/y420–520 and x950–1210/y305–455. They are similarly shaped
and repeat at a regular cadence. No full-width dark row was seen in the scanned ground
band, and no cyan-water band exists in this frame. The larger dark green area at
x0–240/y500–720 is a single flat clearing under trees, non-repeating.

**R3 / DERIVED** — `color.p05_luma 53.0438` and `p95_luma 103.517601` give a
~50.5-level span; `color.std_luma 19.535994`. No `full_width_dark_rows` value was
produced by C01; none is asserted here.

**R3 / INFERRED (caveated)** — The dark cells look like repeated mask-patch units rather
than organic shadow; the cause is not established by one frame.

**R3 / UNVERIFIED** — Donor parity; any dark band outside the scanned boxes.

**R3 verdict: FAIL.** Repeated, similarly shaped dark patches (rectangular cells at a
regular cadence) are present in the named box. The single non-repeating dark clearing is
recorded but is not the basis of the verdict.

---

### R4 — multi-scale organic colour variation

**R4 / y03 / OBSERVED** — Whole ground band scanned. Fine grain (the ~4–7 px stripes)
dominates the surface. At ≥32 px scale there are coherent patches, but they are
**geometric**: the light tan/olive rectangular blocks around resource clusters, the flat
uniform green clearings at x0–240/y390–720 and x900–1200/y50–290, and the nested
contour bands. There is **no soft organic mottling** of the kind seen in ref A
(large irregular green dark/light clouds), no scattered natural hue/luma drift across
the field, and **no grey rock face with vertical striations** comparable to the ravine
walls in ref A or the rolling transitions in ref B. Luma range is modest and the palette
stays olive/khaki throughout.

**R4 / DERIVED** — `block_variance[32].between_share 0.251713` against donor-still median
`0.441282` (z `-1.321095`); `block_variance[32].between_block_var 96.602341` against
donor median `538.089447`. C01 flags `flat_large_scale: large-block luma variance far
below reference` and `low_fine_variation: candidate 280.1 is < half the reference 1029`.

**R4 / INFERRED (caveated)** — Compared to the named sample features, the surface does
**not** read like them: coarse variation exists but as repeated geometry, and the fine
scale is a regular stripe rather than subordinate grain. What would disprove this: a
frame showing broad irregular green/light clouds and rock faces with the stripes gone.

**R4 / UNVERIFIED** — Donor parity; any off-screen area.

**R4 verdict: FAIL.** INFERRED comparative judgement only — no donor-parity claim.

---

### R5 — relief / cliffs / seams

**R5 / y03 / OBSERVED** — Ground band y40–690 scanned. Prominent at the historical
boxes are **nested, stepped, grid-aligned band sets**: upper-left x0–440/y0–330 shows a
grey/tan concentric stepped outline; right x700–1280/y0–500 shows the same nested
outlines wrapping the tree clearing and along the top-right edge; bottom-centre
~x320–500/y480–600 shows another nested set; bottom-right x850–1280/y530–720 shows no
nested set but dense horizontal striping. The bands are tan/grey, multi-line and
stepped at right angles — the same *class* of artifact as the historical "white stepped
nested outlines", recoloured. Around them the terrain is effectively flat: there are no
grey cliff faces with vertical striations and no non-flat silhouettes like ref A's
ravines. No black rows and no z-fighting shimmer were seen in the scanned boxes; no new
straight seam was observed beyond the nested bands themselves.

**R5 / DERIVED** — `seam_repetition_score 0.796493`, `tile_repeat 0.796493` — the
repetition driver is reported as `tile_repeat`, not a row/col seam spike (`row_seam
0.0`, `col_seam 0.677767`).

**R5 / INFERRED (caveated)** — The nested bands are consistent with a relief/mask layer
being drawn as albedo contours rather than as shaded rock; cause not proven by one frame.

**R5 / UNVERIFIED** — Actual relief grid values; off-screen slopes; donor parity.

**R5 verdict: FAIL.** Stepped nested outline bands remain present in the named boxes,
and relief does not read like the sample cliff/ravine features. No new black row or
z-fighting was observed — that absence is stated with the scanned boxes, not generalised.

---

### R6 — shore / water boundary

**R6 / y03 / OBSERVED** — Cyan water was located first by scanning the prior real-map
boxes (right x1050–1280/y420–470, bottom-right x850–1280/y610–720, bottom-left
x0–95/y560–600) and then the whole frame. **No cyan water is present**: a pixel scan of
the full 1280×720 frame found 0 pixels satisfying `b > r*1.05 && g > r*1.05 && b > 60`.
Consequently there is no water/grass boundary, no 20–60 px shore band to inspect, no
water-on-grass tint and no dark row attributable to water. The lower-left green clearing
and the lower-right striped field are ground, not water.

**R6 / DERIVED** — 0 of 921,600 pixels water-like; no boundary exists in this frame.

**R6 / INFERRED** — None. A shore comparison cannot be made from this frame.

**R6 / UNVERIFIED** — Shore naturalness, water-on-grass tint, repeated bands parallel to
shore, and the applicable dark-row gate: all require a water-bearing capture, which was
not supplied.

**R6 verdict: FAIL as a required item, on missing evidence — UNVERIFIED (NO WATER IN
FRAME), never a negative PASS.** This is a capture-completeness finding, not a finding
that the game's shore is broken.

---

## 3. C01 metric reading — CORROBORATION ONLY, separate field

Command (read-only, local file paths, no Godot):

```
python "C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\variant3d\tools\terrain_ab_metric.py" "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\y03\realmap.png" --compare-ref "C:\Users\Maxym.Oboyshev\Downloads\c3" --json
```

Tool label, verbatim: `SMOKE METRIC - heuristic only, NOT a fidelity gate or donor proof`.

Candidate numbers copied verbatim:

| Field | y03 value |
|---|---|
| `color.mean_rgb` | `[83.49929, 80.065575, 32.109718]` |
| `color.mean_luma` / `std_luma` | `77.345398` / `19.535994` |
| `color.p05_luma` / `p95_luma` | `53.0438` / `103.517601` |
| `color.mean_saturation` | `0.620382` |
| `block_variance[2].between_share` | `0.733864` |
| `block_variance[32].between_share` / `between_block_var` | `0.251713` / `96.602341` |
| `block_variance[64].between_share` | `0.161727` |
| `directional_gradient.coherence` | `0.311491` (donor median `0.054378`, z `+10.995572`) |
| `directional_gradient.band_peak_deg` / `streak_angle_deg` | `90` / `176.11654` |
| `directional_gradient.diag_excess` | `0.021048` |
| `seam_repetition.tile_repeat` | `0.796493` |
| `seam_repetition.tile_period_px` / `tile_axis` | `45` / `"x"` |
| `seam_repetition.row_seam` / `col_seam` | `0.0` / `0.677767` |

Flags, verbatim: `flat_large_scale`, `low_fine_variation`, `gradient_anisotropy`,
`seam_repetition.tile_repeat`, and
`compare_ref: donor stills include UI/units/rock/water; treat all deltas as scene-context SMOKE only`.

These numbers **corroborate** R1 (tile repeat), R2 (band anisotropy/coherence), R3 (narrow
luma span), R4 (flat large scale). They do not decide any item. Donor-folder z-scores and
`outside_donor_range` are calibration hints only; no donor GPU A/B frame exists, so no
parity is implied (C04:141).

---

## 4. Comparison with the prior baselines (camera differences noted)

Both baselines were opened visually and scored with the same tool in candidate-only mode
(`terrain_ab_metric.py <path> --json`). Same-crop PNG-vs-PNG attribution is not attempted
because the camera pose differs (§1).

| Read / number | y03 | g04 | l07c |
|---|---|---|---|
| Visual artifact character | Dense **horizontal corrugation** over most of the ground, plus remaining nested stepped bands and blocky checker patches | Broad, high-contrast **nested contour maze** bands spread widely over bright olive ground; flatter plain areas | Very similar to g04; same maze bands, slightly different contrast |
| Nested stepped bands | Still present (top-left, right, around building, bottom-centre) | Present, more extensive/broader | Present, more extensive/broader |
| Large soft green mottling / rock faces (sample features) | Absent | Absent | Absent |
| `color.mean_luma` | `77.345398` | `83.82766` | `83.859879` |
| `color.std_luma` | `19.535994` | `20.945499` | `20.797991` |
| `block_variance[32].between_share` | `0.251713` | `0.221014` | `0.22657` |
| `directional_gradient.coherence` | `0.311491` | `0.152287` | `0.155551` |
| `directional_gradient.streak_angle_deg` | `176.11654` | `163.29049` | `161.692678` |
| `directional_gradient.band_peak_deg` | `90` | `0` | `0` |
| `seam_repetition.tile_repeat` | `0.796493` | `0.353766` | `0.853047` |
| `seam_repetition.tile_period_px` | `45` | `7` | `11` |

**Direction of change (UNVERIFIED as controlled attribution):** the artifact is
*different*, not gone. The broad g04/l07c maze bands are still visible in Y03, while
fine horizontal banding has become the dominant surface signal — `coherence` is roughly
twice the baseline value and `tile_repeat` is between the two baselines. Mid-scale
variation (`block_variance[32].between_share`) edges up slightly but remains far below
the donor-still median. Luma is darker and slightly less spread. Nothing in either the
visual read or the metric supports "now matches the samples".

---

## 5. Explicit verdicts (C04 §3 / G21 §4)

| Item | Result | Basis (one line) |
|---|:--:|---|
| **R1** tiling periodicity / grid / checker | **FAIL** | Regular horizontal corrugation and brick/checker cells in the scanned ground band; `tile_repeat 0.796493`, period 45 px. |
| **R2** diagonal streaks / moiré | **FAIL** | Regular parallel screen-horizontal strokes in x200–720/y200–480 and right half; `coherence 0.311491`, `streak_angle_deg 176.11654`. Orientation differs from the baselines' diagonal; presence of a regular artifact does not. |
| **R3** dark blotches / repeated dark patches | **FAIL** | Repeated rectangular dark cells at regular cadence in lower-middle and resource patches; no full-width dark row, no water band. |
| **R4** multi-scale organic colour variation | **FAIL** | Fine stripes dominate; ≥32 px patches are geometric; no soft mottling or grey rock faces. INFERRED comparative only. |
| **R5** relief / cliffs / seams | **FAIL** | Nested stepped grid-aligned bands still visible in the named boxes; no donor-like cliff faces. No new black row/z-fighting observed in those boxes. |
| **R6** shore / water | **FAIL (UNVERIFIED — NO WATER IN FRAME)** | 0 cyan pixels; no boundary to inspect. Required item fails for missing evidence, not as a shore defect finding. |
| **R7** selection quad during drag | **UNVERIFIED (NO CAP-3 FRAMES)** | No `before/during/after.png`, `frames.json`, or asserted `input_ctl`-inclusive capture path. Not PASS; not a claim the quad is broken. |
| **R8** ghost final stage | **UNVERIFIED (NO CAP-3 FRAMES)** | No `ghost_valid|ghost_invalid.png`; no frame in which the stage can be identified. Not PASS; not a claim the ghost is broken. |

Charter §5 rows 7 and 8 cannot PASS on this evidence; per G21:214-219 the honest overall
result for this evidence set is **RESULT IS NOT GOOD**. This is an evidence-completeness
statement plus five observed visual failures, not a certification of any gate.

---

## 6. Plain answer

**Is the terrain now "good" versus the samples? No.** The ground in the post-Y03 capture
is still visibly synthetic. Compared with ref A and ref B — organic rolling grass with
large soft light/dark mottling and grey vertically striated ravine faces — Y03 shows a
dark olive field covered in fine, evenly spaced horizontal stripes, brick-like checker
patches, blocky tan rectangles around resource clusters, and grey/tan **nested stepped
contour bands** that are the same artifact class the charter set out to remove. It is a
different-looking artifact from the g04/l07c maze bands, but it is still an artifact;
there is no donor-like relief and no multi-scale organic colour variation.

**What remains:**
1. The horizontal corrugation / moiré field (R2) and the checker/tiling repetition (R1)
   are the dominant remaining defects.
2. The nested stepped bands (R5) persist in the historical boxes; relief still does not
   read as rock faces.
3. Mid-scale variation is still flat relative to the samples (`block_variance[32]`
   `between_share 0.251713` vs donor-still median `0.441282`), and the tonal/HSV spread
   stays narrow and saturated (R3/R4).
4. Shore/water (R6) was not captured at all — needs a water-bearing real-map frame.
5. Quad and ghost (R7/R8) need CAP-3 frames from an `input_ctl`-inclusive path with
   `frames.json`; nothing in Y03 evidences them.
6. Integrity sidecars (`stderr.txt`, config/camera diag) are absent for Y03, so the
   capture's seed/harness/`script_error_lines` status is UNVERIFIED; a strict §1 gate
   would not admit this frame as clean evidence on its own.

No code, asset, gate or capture was changed by this review. No donor-parity claim is made
and no fix is applied here; routing of R1–R5 is to whichever file owns the terrain shader,
atlas/tile data and relief presentation, and R6–R8 to the capture owner — COORD decides.

---

## 7. Reviewer block and required statement

- Reviewer / agent id: Y06 (second agent, independent of the frame builder)  Date: 2026-11-25
- Frame reviewed: `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\y03\realmap.png` (1280×720; sidecar `realmap.png.raw.png`; no `script_error_lines` available)
- Baselines: `...\opencode\g04\realmap.png`, `...\opencode\l07c\realmap.png` (camera differs — attribution UNVERIFIED)
- Reference stills opened: `...\Downloads\c3\cossacks-3-v1-498085.jpg`, `...\articolo-787.jpg`, `...\maxresdefault_1.jpg`
- C01 output path: command and verbatim numbers in §3 (SMOKE METRIC, corroboration only)
- Second-agent visual reading (separate from metrics): §2, with explicit verdicts in §5
- Overall: **RESULT IS NOT GOOD — five FAIL (R1–R5), one FAIL-on-missing-evidence (R6), two UNVERIFIED (R7/R8)**

**Required statement (verbatim):** **"PORT APPROX — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."**

---

*End of Y06. One report written; no Godot run, no runner submission, no source/config/asset/test/tool/result edit, no donor image copied into the repo, no donor-parity certification.*
