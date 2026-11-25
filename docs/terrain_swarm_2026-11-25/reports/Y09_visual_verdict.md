---
id: Y09
ticket: Y09 — SECOND-AGENT VISUAL REVIEW (post-Y04b CLEAN capture)
role: READ-ONLY / INDEPENDENT VISUAL REVIEWER (not the builder of the frame)
created: 2026-11-25
status: REPORT_ONLY__NO_RUNNER__NO_CODE_OR_ASSET_EDIT__NO_DONOR_PARITY_CLAIM
scope: "Exactly one output file: docs/terrain_swarm_2026-11-25/reports/Y09_visual_verdict.md. No Godot launch, no runner submission/queue mutation, no .gd/.gdshader/config/asset/test/tool/fixture/result edit, no donor-file copy into the repo. Analysis PNG crops and a one-off crop helper script were written outside the repo under C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\y04b\\ and are analysis artifacts only."
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED]
parity_guard: "PORT APPROX — internal consistency only. 'Reads like the reference samples' below is an INFERRED comparative judgement tied to named features, never donor-parity certification. No donor GPU A/B frame exists. Donor parity stays UNVERIFIED."
governing_sources:
  - docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md — standing rules (G04 sole runner owner; one report per agent; no donor-parity claim)
  - docs/terrain_swarm_2026-11-25/CHARTER.md — §1 owner symptom, §1b, §3 guardrails, §5 definition of good
  - docs/terrain_swarm_2026-11-25/reports/C04_visual_review.md — §1 labels, §2 capture integrity, §3 R1–R8 region map, §5 metric hierarchy, §7 sign-off
  - docs/terrain_swarm_2026-11-25/reports/G21_acceptance_checklist.md — §4 acceptance cards, §5 sign-off, §6 metric-never-overrides
  - docs/terrain_swarm_2026-11-25/reports/Y06_visual_verdict.md — prior verdict on the earlier y03 frame (comparison target)
  - variant3d/tools/terrain_ab_metric.py:24-32,60-63 — CLI, SMOKE METRIC label
---

# Y09 — visual verdict on the y04b CLEAN real-map capture

## 0. What this review is

A second-agent visual read of the capture supplied at
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\y04b\realmap.png`, applying C04's
R1–R6 region protocol and G21's acceptance cards. Each region is **described in words
before a verdict is given** (C04:56). Pixel descriptions are OBSERVED; causes and
"reads like the samples" are INFERRED; anything not in the supplied evidence is
UNVERIFIED and is never converted to PASS (C04:49,52,57).

C01's `terrain_ab_metric.py` was run locally on file paths **as corroboration only**.
No number below overrides the visual read (C04:138, G21 §6). No Godot was run and no
runner job was submitted (WAVE_G_CHARTER.md:31).

Reference stills opened: `C:\Users\Maxym.Oboyshev\Downloads\c3\cossacks-3-v1-498085.jpg`
(ref A: rolling green ground with large soft mottling, dark/light patches, grey ravine
cliff faces with vertical striations, trees; no grid, streaks or repetition),
`...\articolo-787.jpg` (ref B: rolling relief, patchy grass, natural transitions), and
`...\maxresdefault_1.jpg` (natural grass → sand → cyan water shore). These are donor
stills, **not** a donor GPU A/B frame.

The earlier frame was also opened directly for the comparison in §4:
`...\opencode\y03\realmap.png`, the subject of Y06.

---

## 1. Evidence and admissibility

| Item | Finding |
|---|---|
| Candidate frame | `...\opencode\y04b\realmap.png` — opens as 1280×720, non-blank, real scene content (church/hall, two huts, units, trees, terrain). Whole frame is ground plus objects; **no sky/horizon band** in this camera pose. Dimension and non-blankness independently confirmed with PIL. |
| Sidecar | `...\y04b\realmap.png.raw.png` present, same byte length as the final PNG (1,553,208 bytes each). No `screenshot capture diag` text was supplied, so a raw-sidecar acceptance reason is UNVERIFIED. Not needed: the final PNG is valid on its own. |
| Folder contents | Only `realmap.png` and `realmap.png.raw.png`. **No** `stdout.txt`, `stderr.txt`, `config.json`, `frames.json`, or result JSON in this folder. The ticket states this is the latest CLEAN capture with **0 script errors**; that value is accepted from the ticket (G21 G0-c), but cannot be independently re-verified from a `stderr.txt` here. Seed/harness pinning and windowed/no-headless launch are **UNVERIFIED** from this folder alone (C04 §2 items 1,3,4). |
| Quad / ghost | No `before|during|after.png`, `ghost_valid|ghost_invalid.png`, `frames.json`, or result JSON with an asserted `input_ctl`-inclusive capture path exists for Y04b. **R7 and R8 are UNVERIFIED (NO CAP-3 FRAMES)** — a capture-completeness finding, not a claim that the quad or ghost is broken (C04:108-109, G21:178-190). |
| Camera caveat (binding) | No camera matrix or seed was supplied. The y04b pose appears close to y03 (church roughly x600–790/y110–360 in both), but that is a visual estimate, not a matrix. Therefore **cross-capture attribution is UNVERIFIED** (C04:79, G21 §2 step 4): §4 is direction-of-change description only, never a controlled A/B. |

---

## 2. Region-by-region read — description first, then verdict

All boxes are approximate pixels in the 1280×720 frame, y down. Crops were taken from
the same PNG (outside the repo) to scan each box closely; boxes were not shrunk to
avoid an artifact (C04:98).

### Frame fill, boundary, tonal range (described before items)

**R0 / y04b / OBSERVED** — The frame is entirely ground viewed from a steep three-quarter
top-down angle; no sky or horizon. The field is olive/khaki green with tan-grey
rectangular patches. A large dark-brown wooden church/hall dominates the centre
(≈x600–790/y110–360), flanked by two smaller thatched huts (≈x540–620/y320–450 and
≈x780–870/y320–450) with units scattered around their base. Trees occupy a clearing at
upper-right (≈x900–1200/y50–290) and scatter across the lower-left (≈x0–240/y390–720).
Four lighter blocky patches around grey rubble/resource clusters sit at upper-left
(≈x280–500/y130–230), mid-left (≈x300–510/y390–510), centre-right (≈x960–1210/y300–460),
and lower-centre (≈x480–580/y460–550). The whole field carries thin horizontal lineation
and a rectangular block mosaic. No cyan water appears anywhere in the frame. Luma spans
≈53–106 (p05–p95, C01 §3); the palette stays olive/khaki throughout.

---

### R1 — tiling periodicity / grid / checker

**R1 / y04b / OBSERVED** — Scanned the full ground band in three strips (y0–240,
y220–500, y480–720) and in close crops of the upper-left, centre and lower-middle. The
ground carries a **rectangular brick-like checker mosaic**: alternating olive and
tan-grey rectangles of near-equal size laid on a regular grid, plainly visible at
≈x0–420/y0–260 (tile_detail crop), ≈x200–720/y200–480, and across the lower strip.
Around the resource clusters the rectangles alternate light tan and dark olive in a
clear grid. Superimposed are **stepped, nested, grid-aligned outline bands** (counted
under R5) that trace right-angle loops. C01 beside this read: `tile_repeat 0.830436`,
`tile_period_px 45`, `tile_axis "x"`, `seam_repetition_driver "tile_repeat"`,
`row_periodicity 0.292058`, `col_periodicity 0.281173`,
`seam_repetition_score 0.830436`.

**R1 / DERIVED** — `tile_best_mad 3.067083` versus `tile_baseline_mad 19.428501` is a
~6.3× drop at the detected 45 px period; the metric independently finds a repeated
patch at that cadence. `tile_repeat` is above the donor-still median `0.522615`
(z `+1.47508`).

**R1 / INFERRED (caveated)** — The rectangular cells and repeated bands are consistent
with a repeated atlas cell / mask patch sampled at a shallow camera angle, but this
frame alone does not prove the cause; a different harness or camera could change the
appearance.

**R1 / UNVERIFIED** — Exact world tile cadence and camera transform at capture time.

**R1 verdict: FAIL.** A visible regular checker mosaic and repeated rectangular patches
are present in the named boxes. Per C04:138 and G21:142 a low neighbouring metric would
not close this; here the metric agrees.

---

### R2 — diagonal streaks / moiré

**R2 / y04b / OBSERVED** — In x200–720/y200–480 (densest x300–620/y300–450) the dominant
signal is **long, near-horizontal parallel strokes**: thin evenly spaced light/dark
lines, a few luma counts above and below the field, continuing uninterrupted across
hundreds of pixels. The same lineation is visible across the top strip (y0–240), the
right half behind the trees (x640–1280/y0–340), and the lower-right field
(x640–1280/y500–690). The lower-left curved band (x0–430/y500–690) is a flat green
clearing with trees and a stepped contour band, not a moiré stroke field. The strokes are
**screen-horizontal, not diagonal** in this frame, but they are regular, parallel and
non-organic, and read as repetition. C01 beside this read: `streak_angle_deg 172.966142`,
`gradient_angle_deg 82.966142`, `band_peak_deg 90`, `coherence 0.231085`,
`diag_excess 0.028085`, `diag_minus_axis -0.075171`.

**R2 / DERIVED** — `coherence 0.231085` against the donor-still median `0.054378`
(z `+7.46519`) is ~4.25× that median; C01 flags
`gradient_anisotropy: candidate 0.2311 is > 2x the reference 0.05438`.

**R2 / INFERRED (caveated)** — Consistent with camera-dependent texgen/minification
aliasing; not proven by this single frame, and no second camera pose was supplied to
test whether the strokes move with the camera.

**R2 / UNVERIFIED** — Whether the same strokes appear at another camera pose; donor parity.

**R2 verdict: FAIL.** The named boxes contain regular parallel banding that reads as
moiré/repetition. The protocol's "curved organic band or true cliff edge is not
automatically a streak" carve-out does not apply to these straight, evenly spaced lines;
the stepped contour bands are counted under R5 instead. As in Y06, the orientation is
horizontal rather than the baseline's diagonal — the *orientation* changed, not the
presence of a regular stroke artifact.

---

### R3 — dark blotches / repeated dark patches

**R3 / y04b / OBSERVED** — Lower-middle x350–950/y480–620: the dark regions are the lower
halves of the horizontal strokes and a **checker of alternating dark olive rectangular
cells** (r3_lowermid crop), with the same rectangular cells recurring at regular cadence
in the resource patches at ≈x280–500/y130–230, ≈x300–510/y390–510 and ≈x960–1210/y300–460.
They are similarly shaped and sit on a regular grid. There is also a single larger dark
green stepped wedge at ≈x520–900/y500–700, which is a non-repeating region and is not the
basis of the verdict. A direct pixel scan found **0 full-width dark rows** (>90% of row at
luma<20; max dark pixels in any row = 96), and no cyan-water band exists in the frame.
The lower-left green clearing is flat ground, not a repeated blotch.

**R3 / DERIVED** — `color.p05_luma 53.177803` and `p95_luma 106.462456` give a ~53.3-level
span; `color.std_luma 19.897495`. No `full_width_dark_rows` value was produced by C01;
none is asserted from it — the row count above is a separate PIL pixel scan.

**R3 / INFERRED (caveated)** — The dark cells look like repeated mask-patch units rather
than organic shadow; the cause is not established by one frame.

**R3 / UNVERIFIED** — Donor parity; any dark band outside the scanned boxes.

**R3 verdict: FAIL.** Repeated, similarly shaped dark patches (rectangular cells at a
regular cadence) are present in the named box. The single non-repeating dark wedge is
recorded but is not the basis of the verdict.

---

### R4 — multi-scale organic colour variation

**R4 / y04b / OBSERVED** — Whole ground band scanned. Fine grain (the ~4–7 px horizontal
stripes) dominates the surface. At ≥32 px scale there are coherent patches, but they are
**geometric**: the light tan/olive rectangular blocks around resource clusters, the flat
uniform green clearings at x0–240/y390–720 and x900–1200/y50–290, and the stepped nested
contour bands. There is **no soft organic mottling** of the kind seen in ref A (large
irregular green dark/light clouds), no scattered natural hue/luma drift across the field,
and **no grey rock face with vertical striations** comparable to ref A's ravine walls or
ref B's rolling transitions. The small grey rubble heaps at resource clusters are not
cliff faces. Luma range is modest and the palette stays olive/khaki throughout.

**R4 / DERIVED** — `block_variance[32].between_share 0.268132` against donor-still median
`0.441282` (z `-1.210348`); `block_variance[32].between_block_var 106.922928` against
donor median `538.089447`. C01 flags `flat_large_scale: large-block luma variance far
below reference` and `low_fine_variation: candidate 294.1 is < half the reference 1029`.

**R4 / INFERRED (caveated)** — Compared to the named sample features, the surface does
**not** read like them: coarse variation exists as repeated geometry, and the fine scale
is a regular stripe rather than subordinate grain. What would disprove this: a frame
showing broad irregular green/light clouds and rock faces with the stripes gone.

**R4 / UNVERIFIED** — Donor parity; any off-screen area.

**R4 verdict: FAIL.** INFERRED comparative judgement only — no donor-parity claim.

---

### R5 — relief / cliffs / seams

**R5 / y04b / OBSERVED** — Ground band y40–690 scanned. Prominent at the historical boxes
are **nested, stepped, grid-aligned band sets**: upper-left x0–440/y0–330 shows tan/grey
concentric stepped outlines wrapping the resource cluster; right x700–1280/y0–500 shows
the same nested outlines around the tree clearing and along the top-right edge;
bottom-centre ~x320–620/y480–700 shows a long snaking nested set with multiple parallel
right-angle steps (r3_lowermid crop); bottom-right x850–1280/y530–720 shows dense
horizontal striping and a hard stepped diagonal boundary between darker and lighter
field. The bands are tan/grey, multi-line and stepped at right angles — the same *class*
of artifact as the historical "white stepped nested outlines", recoloured. Around them
the terrain is effectively flat: there are no grey cliff faces with vertical striations
and no non-flat silhouettes like ref A's ravines. No black rows and no z-fighting shimmer
were seen in the scanned boxes; no new straight seam was observed beyond the nested
bands themselves. The pixel scan found 0 full-width dark rows (max 96 dark pixels/row).

**R5 / DERIVED** — `seam_repetition_score 0.830436`, `tile_repeat 0.830436` — the
repetition driver is reported as `tile_repeat`, not a row/col seam spike (`row_seam
0.440704`, `col_seam 0.626207`).

**R5 / INFERRED (caveated)** — The nested bands are consistent with a relief/mask layer
being drawn as albedo contours rather than as shaded rock; cause not proven by one frame.

**R5 / UNVERIFIED** — Actual relief grid values; off-screen slopes; donor parity.

**R5 verdict: FAIL.** Stepped nested outline bands remain present in the named boxes, and
relief does not read like the sample cliff/ravine features. No new black row or
z-fighting was observed — that absence is stated with the scanned boxes, not generalised.

---

### R6 — shore / water boundary

**R6 / y04b / OBSERVED** — Cyan water was located first by scanning the prior real-map
boxes (right x1050–1280/y420–470, bottom-right x850–1280/y610–720, bottom-left
x0–95/y560–600) and then the whole frame. **No cyan water is present**: a pixel scan of
the full 1280×720 frame found 0 pixels satisfying
`b > r*1.05 && g > r*1.05 && b > 60`. Consequently there is no water/grass boundary, no
20–60 px shore band to inspect, no water-on-grass tint and no dark row attributable to
water. The lower-left green clearing and the lower-right striped field are ground, not
water.

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
python "C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\variant3d\tools\terrain_ab_metric.py" "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\y04b\realmap.png" --compare-ref "C:\Users\Maxym.Oboyshev\Downloads\c3" --json
```

Tool label, verbatim: `SMOKE METRIC - heuristic only, NOT a fidelity gate or donor proof`.
Mode `compare-ref`, `reference_file_count 12`.

Candidate numbers copied verbatim:

| Field | y04b value |
|---|---|
| `color.mean_rgb` | `[85.863281, 83.041435, 35.116085]` |
| `color.mean_luma` / `std_luma` | `80.166534` / `19.897495` |
| `color.p05_luma` / `p95_luma` | `53.177803` / `106.462456` |
| `color.mean_saturation` | `0.598193` |
| `block_variance[2].between_share` / `between_block_var` | `0.742847` / `294.100983` |
| `block_variance[32].between_share` / `between_block_var` | `0.268132` / `106.922928` (donor medians `0.441282` / `538.089447`) |
| `block_variance[64].between_share` | `0.171882` |
| `directional_gradient.coherence` | `0.231085` (donor median `0.054378`, z `+7.46519`) |
| `directional_gradient.band_peak_deg` / `streak_angle_deg` / `gradient_angle_deg` | `90` / `172.966142` / `82.966142` |
| `directional_gradient.diag_excess` / `diag_minus_axis` | `0.028085` / `-0.075171` |
| `seam_repetition.tile_repeat` / `seam_repetition_score` | `0.830436` / `0.830436` (donor median tile_repeat `0.522615`, z `+1.47508`) |
| `seam_repetition.tile_period_px` / `tile_axis` | `45` / `"x"` |
| `seam_repetition.tile_best_mad` / `tile_baseline_mad` | `3.067083` / `19.428501` |
| `seam_repetition.row_seam` / `col_seam` | `0.440704` / `0.626207` |
| `seam_repetition.row_periodicity` / `col_periodicity` | `0.292058` / `0.281173` |
| `seam_repetition.seam_repetition_driver` | `"tile_repeat"` |

Flags, verbatim: `flat_large_scale: large-block luma variance far below reference`,
`low_fine_variation: candidate 294.1 is < half the reference 1029`,
`gradient_anisotropy: candidate 0.2311 is > 2x the reference 0.05438`,
`seam_repetition.tile_repeat: candidate 0.830 exceeds reference 0.523`, and
`compare_ref: donor stills include UI/units/rock/water; treat all deltas as scene-context SMOKE only`.

These numbers **corroborate** R1 (tile repeat), R2 (band anisotropy/coherence), R3 (narrow
luma span), R4 (flat large scale). They do not decide any item. Donor-folder z-scores and
`outside_donor_range` are calibration hints only; no donor GPU A/B frame exists, so no
parity is implied (C04:141).

---

## 4. Honest comparison with Y06's verdict on the y03 frame

Y06 reviewed `...\opencode\y03\realmap.png` and returned five FAIL (R1–R5), one
FAIL-on-missing-evidence (R6), and two UNVERIFIED (R7/R8); overall **RESULT IS NOT GOOD**.
That frame was opened directly for this comparison. Camera poses look close, but with no
matrix or seed supplied the comparison is direction-of-change only (§1 caveat).

| Read / number | y03 (Y06) | y04b (Y09) | Direction |
|---|---|---|---|
| Visual artifact character | Dense horizontal corrugation over most ground, blocky checker cells, tan/grey nested stepped bands | Same class: horizontal corrugation + rectangular checker mosaic + tan/grey nested stepped bands, bands extensive and multi-line | **Unchanged in kind** |
| Nested stepped bands | Present (top-left, right, around building, bottom-centre) | Present in the same boxes, with many parallel right-angle steps | **Not removed; at least as prominent** |
| Large soft green mottling / grey rock faces | Absent | Absent | **Unchanged** |
| Cyan water | 0 pixels | 0 pixels | **Unchanged (still missing)** |
| `color.mean_luma` | `77.345398` | `80.166534` | Slightly brighter (+2.82) |
| `color.std_luma` | `19.535994` | `19.897495` | Essentially flat (+0.36) |
| `color.p05_luma` / `p95_luma` | `53.0438` / `103.517601` | `53.177803` / `106.462456` | Span +2.81 levels (~50.5 → ~53.3) |
| `color.mean_saturation` | `0.620382` | `0.598193` | Slight decrease (−0.022) |
| `block_variance[32].between_share` | `0.251713` | `0.268132` | Slight rise (+0.0164), still ~61% of donor-still median `0.441282` |
| `block_variance[32].between_block_var` | `96.602341` | `106.922928` | Slight rise (+10.3), still ~20% of donor median `538.089447` |
| `directional_gradient.coherence` | `0.311491` | `0.231085` | **Down ~26%** — the one clear movement; still ~4.25× donor-still median `0.054378` |
| `directional_gradient.band_peak_deg` / `streak_angle_deg` | `90` / `176.11654` | `90` / `172.966142` | Still screen-horizontal |
| `seam_repetition.tile_repeat` / `tile_period_px` | `0.796493` / `45` | `0.830436` / `45` | Slight **increase** (+0.034); same 45 px period |
| `row_seam` / `col_seam` | `0.0` / `0.677767` | `0.440704` / `0.626207` | row_seam now non-zero |

**What improved (honestly, modest):** `directional_gradient.coherence` fell from 0.311 to
0.231 (~26%), mean luma rose slightly (77.3 → 80.2), the p5–p95 span widened by ~2.8
levels, and mid-scale `between_share` edged from 0.2517 to 0.2681. These are small,
mostly metric-side movements; they do **not** change the visual character of the frame.
C01 still raises the same four flags as y03 (`flat_large_scale`, `low_fine_variation`,
`gradient_anisotropy`, `tile_repeat`).

**What remains:** the horizontal corrugation/moiré field (R2), the rectangular
checker/tiling grid (R1), repeated dark rectangular cells (R3), geometric rather than
organic large-scale patches with no grey rock faces (R4), the nested stepped contour
bands that stand in for relief (R5), the absence of any water-bearing frame (R6), and the
absence of CAP-3 quad/ghost frames (R7/R8). `tile_repeat` is slightly worse than y03.
Nothing in either the visual read or the metric supports "now matches the samples".

**Verdict implication:** Y09 reaches the same structural verdict as Y06 on the terrain
half — five FAIL (R1–R5), one FAIL-on-missing-evidence (R6), two UNVERIFIED (R7/R8).

---

## 5. Explicit verdicts (C04 §3 / G21 §4)

| Item | Result | Basis (one line) |
|---|:--:|---|
| **R1** tiling periodicity / grid / checker | **FAIL** | Regular rectangular checker mosaic and repeated patches in the scanned ground band; `tile_repeat 0.830436`, period 45 px. |
| **R2** diagonal streaks / moiré | **FAIL** | Regular parallel screen-horizontal strokes in x200–720/y200–480, right half and lower-right field; `coherence 0.231085`, `streak_angle_deg 172.966142`. Orientation differs from the baseline's diagonal; presence of a regular artifact does not. |
| **R3** dark blotches / repeated dark patches | **FAIL** | Repeated rectangular dark cells at regular cadence in lower-middle and resource patches; 0 full-width dark rows, no water band. |
| **R4** multi-scale organic colour variation | **FAIL** | Fine stripes dominate; ≥32 px patches are geometric; no soft mottling or grey rock faces. INFERRED comparative only. |
| **R5** relief / cliffs / seams | **FAIL** | Nested stepped grid-aligned bands still visible in the named boxes; no donor-like cliff faces. No new black row/z-fighting observed in those boxes. |
| **R6** shore / water | **FAIL (UNVERIFIED — NO WATER IN FRAME)** | 0 cyan pixels; no boundary to inspect. Required item fails for missing evidence, not as a shore defect finding. |
| **R7** selection quad during drag | **UNVERIFIED (NO CAP-3 FRAMES)** | No `before/during/after.png`, `frames.json`, or asserted `input_ctl`-inclusive capture path. Not PASS; not a claim the quad is broken. |
| **R8** ghost final stage | **UNVERIFIED (NO CAP-3 FRAMES)** | No `ghost_valid|ghost_invalid.png`; no frame in which the stage can be identified. Not PASS; not a claim the ghost is broken. |

Charter §5 rows 7 and 8 cannot PASS on this evidence; per G21:214-219 the honest
overall result for this evidence set is **RESULT IS NOT GOOD**. This is an
evidence-completeness statement plus five observed visual failures, not a certification
of any gate. Gate items (selftest/uitest/`t_render_mode`/`assert_clean`, 2D `app/`
untouched) were **not** re-read here and are not inferred from this PNG or C01.

---

## 6. Plain answer

**Is the terrain good versus the samples now? No.** The y04b ground still reads as
synthetic. Compared with ref A and ref B — organic rolling grass with large soft
light/dark mottling and grey vertically striated ravine faces — this frame shows a dark
olive field covered in fine, evenly spaced horizontal stripes, a brick-like rectangular
checker grid, blocky tan rectangles around resource clusters, and grey/tan **nested
stepped contour bands** that are the same artifact class the charter set out to remove.
It is essentially the same artifact class Y06 found in y03; the one measurable movement
( coherence 0.311 → 0.231 ) does not change how the surface reads. There is no donor-like
relief and no multi-scale organic colour variation.

**Top 2 remaining defects, in priority order:**

1. **Pervasive repeating surface pattern — horizontal corrugation plus the
   rectangular checker/tiling grid (R1 + R2).** This covers essentially the entire
   ground band and is the dominant "synthetic" signal: `tile_repeat 0.830436` at a
   45 px period, `coherence 0.231085` (~4.25× the donor-still median), and visible
   regular strokes and equal-size rectangles in every scanned strip. Nothing in the
   samples has this regularity.
2. **Nested stepped, grid-aligned contour bands standing in for relief (R5).** These
   multi-line right-angle loops recur in all four historical boxes and are the most
   high-contrast, most sample-alien feature in the frame; they are albedo contours, not
   grey rock faces or organic slopes, and the ground between them is flat. This is the
   direct blocker for "relief/cliffs read like the samples".

Downstream of these: R3 (repeated dark cells) and R4 (no soft mottling / no rock faces)
would improve if the two above were fixed. R6 still needs a water-bearing real-map
frame; R7/R8 still need CAP-3 frames from an `input_ctl`-inclusive path with
`frames.json`. None of that was captured here.

No code, asset, gate or capture was changed by this review. No donor-parity claim is
made and no fix is applied here; routing of the terrain items is to whichever file owns
the terrain shader, atlas/tile data and relief presentation, and the capture gaps to
the capture owner — COORD decides.

---

## 7. Reviewer block and required statement

- Reviewer / agent id: Y09 (second agent, independent of the frame builder)  Date: 2026-11-25
- Frame reviewed: `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\y04b\realmap.png` (1280×720; raw sidecar present; `script_error_lines: 0` per ticket, no `stderr.txt` in folder for independent re-check)
- Prior verdict compared: `...\opencode\y03\realmap.png` (Y06)
- Reference stills opened: `...\Downloads\c3\cossacks-3-v1-498085.jpg`, `...\articolo-787.jpg`, `...\maxresdefault_1.jpg`
- C01 output path: command and verbatim numbers in §3 (SMOKE METRIC, corroboration only)
- Second-agent visual reading (separate from metrics): §2, with explicit verdicts in §5
- Overall: **RESULT IS NOT GOOD — five FAIL (R1–R5), one FAIL-on-missing-evidence (R6), two UNVERIFIED (R7/R8)**

**Required statement (verbatim):** **"PORT APPROX — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."**

---

*End of Y09. One report written; no Godot run, no runner submission, no source/config/asset/test/tool/result edit, no donor image copied into the repo, no donor-parity certification.*
