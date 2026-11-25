---
id: G05
ticket: "TERRAIN-SWARM-WAVE-G / G05 — second-agent visual review, BASELINE"
title: "G05 — pre-fix baseline visual review of p0_final_formula.png vs 12 donor samples (C04 R1–R8 + C01 metric)"
role: "QA / READ-ONLY / SECOND AGENT (independent of the six implementation owners)"
owner: G05
date: 2026-11-25
status: BASELINE_ESTABLISHED__NO_PASS_VERDICT__DONOR_PARITY_UNVERIFIED__NO_RUNNER_JOB__NO_CODE_EDIT
scope: "Exactly one output file: docs/terrain_swarm_2026-11-25/reports/G05_visual_review.md. No .gd/.gdshader/config/asset/test/tool/fixture/result/donor edit, no Godot process, no runner submission or queue mutation. C01 tool invoked locally on file paths (per ticket) — NOT a Godot job."
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED]
parity_guard: "PORT APPROX — internal consistency only. No donor GPU A/B frame exists. Donor parity stays UNVERIFIED; this report certifies neither donor fidelity nor a gate PASS."
governing_sources:
  - docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md:31,43 (G05 scope; only G04 submits jobs)
  - docs/terrain_swarm_2026-11-25/CHARTER.md:12-27,55-69,122-130 (symptom, guardrails, §5 definition of good)
  - docs/terrain_swarm_2026-11-25/reports/C04_visual_review.md:43-60,96-109,131-144,147-196 (labels, R1–R8 region protocol, metric rules, claim ledger, sign-off)
  - docs/terrain_swarm_2026-11-25/reports/C01_metric_tool.md:31-46,48-61,127-175,176-189 (metric schema and interpretation)
---

# G05 — second-agent visual review (BASELINE, pre-fix)

## 0. Purpose and honesty statement

Per ticket G05, this is a **second-agent baseline review** of the CURRENT pre-fix frame
`p0_final_formula.png` against the **12 reference samples** in `C:\Users\Maxym.Oboyshev\Downloads\c3`,
using C04's R1–R8 region protocol and C01's `variant3d/tools/terrain_ab_metric.py` run **locally on
file paths** (a local Python invocation, not a Godot runner job). The purpose is to **freeze baseline
numbers before G04's new captures land**, so COORD can measure improvement.

I am independent of the six implementation owners. I wrote only this report. I submitted no Godot
job, made no code/asset/test/tool/config edit, copied no donor file into the repo, and mutated no
queue state. I created three scratch zoom crops and three scratch metric JSON dumps in
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\` (outside the repo) to support the read; they
are not evidence artifacts and are not part of the deliverable.

**Explicit statement (required by C04 §7):** PORT APPROX — internal consistency only; donor parity
UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate
pass. **No PASS verdict is claimed anywhere in this report.**

## 1. Provenance and capture-status record

### 1.1 Candidate under review — OBSERVED

| Field | Value |
|---|---|
| Path | `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\p0fresh01\p0_final_formula.png` |
| Size / mode | 1280×720, RGBA (confirmed by Pillow `Image.open`) |
| File timestamp | 2026-11-25 11:41:11 (pre-fix P0 stub frame) |
| Bytes | 2,129,263 |

This is the **flat synthetic P0 all-grass stub**, not a generated 64² or real-map capture. Under C04 §2
it is at best an **auxiliary control** and is **not a substitute for CAP-1/CAP-2/CAP-3**. All R-item
findings below therefore describe this baseline stub only; they are not findings about the post-fix
game build.

### 1.2 Reference folder — OBSERVED

`C:\Users\Maxym.Oboyshev\Downloads\c3\` contains exactly **12** readable images
(verified by the C01 tool: `reference_files` length 12). Names and native sizes:

| # | File | Size |
|---|---|---|
| 1 | `3173885360_preview_Turkish battle 19 Light Infantry rush.jpg` | 1920×1080 |
| 2 | `523480776.jpg` | 720×405 |
| 3 | `899956545_preview_20170411195032_1.jpg` | 1366×768 |
| 4 | `articolo-787.jpg` | 960×540 |
| 5 | `cossacks-3-guardians-of-the-highlands-pc-gioco-steam-wallpaper-3.jpg` | 1916×1080 |
| 6 | `cossacks-3-v1-498085.jpg` | 1280×720 |
| 7 | `Cossacks3AttackingVillage.webp` | 2355×1376 |
| 8 | `hqdefault.jpg` | 480×360 |
| 9 | `images.jpg` | 588×340 |
| 10 | `large_1.webp` | 788×377 |
| 11 | `MADVBuilding1.JPG` | 485×486 |
| 12 | `maxresdefault_1.jpg` | 512×288 |

All 12 were opened and described in words in §2.2 below.

### 1.3 G04 new captures — UNVERIFIED / not present at review time

At the moment of this review:

- `docs/terrain_swarm_2026-11-25/reports/G04_gate_log.md` **exists** (timestamp 14:44). It records
  **BLOCKED_AT_PREFLIGHT**: `pending = 1 [582]` failed the `pending=0` pre-flight criterion, so
  **zero runner jobs were submitted**, and no ticket, status, PNG path or `stats` output exists.
- The directory `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\g04\` exists but is **empty** —
  no `p0_64.png`, no `realmap.png`, no raw sidecars, no `frames.json`.
- A directory scan of `...\Temp\opencode` for PNGs written after 13:00 returned only scratch crops
  from other agents (`a06_*`, `a07_rois\*`, `a01_streak_contrast.png`, `c01_crop_zoom.png`) and this
  worker's own scratch crops. **No G04 capture PNG exists.**

Therefore **no provisional new-capture comparison can be made in this baseline**. Provenance note
for COORD: when G04's PNGs land, this baseline is the BEFORE arm; any AFTER comparison must name
its exact file paths and timestamps and must not be silently mixed with this stub frame.

## 2. Describe regions before verdicts

### 2.1 Candidate frame — whole-frame description (OBSERVED)

The entire 1280×720 frame is a single uninterrupted field of muted olive-green. There is **no sky,
no horizon, no water, no HUD, no unit, no building, no tree, no relief silhouette and no shore**
anywhere in the frame; the corners and the centre have the same olive fill. Fine per-pixel grain is
present everywhere (a slightly darker/lighter speckle), and there are very subtle, low-amplitude
soft mottles only a few luma counts above the field. In the upper-left/centre there are faint,
near-horizontal, short soft streaks (not crisp 45° lines); they are easier to see in a bicubic zoom
than in the native frame. No grid lines, no cell boundaries, no nested stepped outlines and no
repeated identical patches are distinguishable at native scale. The lower band (y480–620) is the
same olive field; no distinct dark blotches occur there. No full-width dark rows are visible.

### 2.2 The 12 donor samples — comparative description in words (OBSERVED)

All 12 were opened directly. The recurring features, relevant to C04 R4/R5/R6, are:

- **Large-scale organic mottling:** multi-hue green ground with soft dark/light patches spanning tens
  of pixels — visible in `cossacks-3-v1-498085.jpg` (irregular light-green clearings and darker
  patches), `articolo-787.jpg` (rolling patchwork), the highlands wallpaper (grass/dirt/rock
  transitions), `899956545_preview…jpg` (dirt/grass mottling behind the formations), `523480776.jpg`
  (pixelated grass/dirt patches), `Cossacks3AttackingVillage.webp` (wheat/grass/dirt blocks),
  `images.jpg`, `large_1.webp`, `maxresdefault_1.jpg` (grass/dirt/rock), `hqdefault.jpg` (green
  plain with shrubs), `MADVBuilding1.JPG` (dry tan ground with rock).
- **Relief / rock faces / ravines:** clear grey-brown cliff walls with vertical striation and
  shadowed ravine floors in `cossacks-3-v1-498085.jpg` and `articolo-787.jpg`; grey boulder fields in
  the winter sample `3173885360_preview…jpg`; rocky outcrops in `images.jpg` and
  `maxresdefault_1.jpg`. These are irregular, non-grid-aligned, and break the ground silhouette.
- **Vegetation and scene objects:** conifers/deciduous trees, wheat fields, buildings, units, HUD
  panels — in nearly every sample. `cossacks-3-v1-498085.jpg` and `articolo-787.jpg` are the closest
  matches to the charter's stated target (grass + cliffs + trees, no grid/streak/repetition).
- **Seasonal variety:** `3173885360_preview…jpg` is a snow scene (white ground, blue-grey shadows,
  frost trees); `Cossacks3AttackingVillage.webp` and `MADVBuilding1.JPG` are dry/tan; the rest are
  green. This diversity is part of the target's "multi-scale variation" character.
- **No donor sample** shows a uniform olive field with only per-pixel grain — that is the gap
  between the candidate and every reference (INFERRED comparative judgement, not parity).

### 2.3 Region-by-region application of C04's protocol to the candidate

Coordinates follow C04 §3, relocated where the candidate has no corresponding feature (e.g. no
water). Zoom crops used (scratch, bicubic/nearest): `g05_r2_zoom.png` (native box x200–720/y200–480
→ 1040×560), `g05_r3_zoom.png` (x350–950/y480–620 → 1200×280), `g05_r1_pixel.png`
(x120–376/y60–316 → 768×768 nearest-neighbour pixel view).

**R1 — tiling periodicity / grid / checker.** Scanned the ground band x120–1160/y60–640 and the
full-band row/column profile sense via C01. No cell boundary, checker mosaic, repeated identical
patch or stepped/nested outline is visible at native scale. The nearest-neighbour pixel view shows
uniform per-pixel grain with no repeating block structure at 2 m tile cadence. C01 row-periodicity
is 0.688919 (elevated) and `tile_period_px=64`, which are diagnostic hints only; they do not
corroborate a *visible* grid on this frame. (OBSERVED for visual; metric numbers copied verbatim in §3.)

**R2 — diagonal streaks / moiré.** Scanned x200–720/y200–480 (densest x300–620/y300–450), the
right half x640–1280/y0–340, and the lower-left x0–430/y500–690. In the bicubic zoom of
x200–720/y200–480, there are faint, short, near-horizontal soft strokes, a few luma counts above
the field, spacing irregular (not a clean 45° parallel set). No crisp diagonal lines and no classic
moiré bands are distinguishable. The right half and lower-left are the same uniform olive field.
Only one camera pose exists for this stub, so camera-dependence of the strokes is UNVERIFIED.

**R3 — dark blotches / repeated dark patches.** Scanned x350–950/y480–620 plus the whole ground
band. No repeated dark patches or identically shaped blotches are visible; no full-width dark rows
(`full_width_dark_rows=0` from `smallmap_capture.py stats`). The field is uniformly olive with fine
grain. C01 `block_variance` large-scale `between_block_var=6.957941` (128 px) is corroboration only.

**R4 — multi-scale organic colour variation.** Whole ground band. At large scale (tens of px) the
frame is effectively flat olive; only fine per-pixel grain and very low-amplitude soft mottle are
present. No grey rock faces, no dark/light patchwork, no multi-hue green variation. Compared *in
words* to the charter §23–24 feature list (soft green mottling, dark/light patches, ravines/cliffs),
this frame does **not read like** the reference samples. This is an INFERRED comparative judgement,
not donor parity.

**R5 — relief / cliffs / seams.** Candidate is a flat stub with no relief, no cliff silhouette and
no grey rock face anywhere in y40–690. No white stepped/nested grid bands, no black rows, no
z-fighting shimmer and no new seams are visible in the scanned regions. The historical artifact boxes
from C04 §3 (top-left x0–440/y0–330; right x700–1280/y0–500; bottom-left x200–470/y540–720;
bottom-right x850–1280/y530–720) were included in the whole-band scan and show only the olive
field — so those specific historical patches are **not observed in this frame**. Absence of relief
here is expected for the P0 stub, not a finding about the game build.

**R6 — shore / water boundary.** No cyan water anywhere in the 1280×720 frame (whole frame scanned).
The prior real-map water boxes (right ≈x1050–1280/y420–470; bottom-right ≈x850–1280/y610–720;
bottom-left ≈x0–95/y560–600) contain only olive ground. Shore transition, water tint and
water-related dark rows are therefore **UNVERIFIED on this frame** (no water to inspect); the dark-row
predicate is recorded-diagnostic here, not applicable to a water-free frame (C04 §5 rule 3).

**R7 — selection quad during drag.** CAP-3 interaction frames A/B/C do not exist (G04 submitted no
jobs; the `g04/` directory is empty). No `frames.json`, no before/during/after PNGs. The target is
**UNVERIFIED (NO PNG)** for this baseline; no quad claim is made, and no PASS is implied.

**R8 — ghost final stage.** CAP-3 frames D/E do not exist. Ghost silhouette stage, validity colour,
translucency, footprint honesty and clear-on-cancel are all **UNVERIFIED (NO PNG)**. No PASS is
implied; the prior stage-1 substitution defect (`world3d_fx.gd:645`, A12 K8) is neither confirmed
nor cleared by this review.

## 3. C01 metric reading (verbatim numbers — corroboration only)

Commands run locally from the repo root with Windows `python` (no Godot process, no runner job):

```
python variant3d\tools\terrain_ab_metric.py "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\p0fresh01\p0_final_formula.png" --json
python variant3d\tools\terrain_ab_metric.py "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\p0fresh01\p0_final_formula.png" --compare-ref "C:\Users\Maxym.Oboyshev\Downloads\c3" --json
python variant3d\tools\terrain_ab_metric.py "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\p0fresh01\p0_final_formula.png" --crop 120,60,1040,580 --json
python variant3d\tools\smallmap_capture.py stats "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\p0fresh01\p0_final_formula.png"
```

All three C01 invocations exited 0. Scratch JSON outputs (outside the repo, for COORD's reference):
`...\Temp\opencode\g05_baseline_candidate.json`, `g05_baseline_vs_donors.json`,
`g05_baseline_crop.json`.

### 3.1 Candidate-only, full frame (`mode=candidate-only`) — OBSERVED numbers

| Group | Key | Value |
|---|---|---|
| color | mean_rgb | [93.748695, 96.783409, 31.642731] |
| color | mean_luma / std_luma | 91.432076 / 10.595727 |
| color | p05_luma / p95_luma | 74.884605 / 108.884201 |
| color | mean_saturation / std_saturation | 0.674427 / 0.029662 |
| block_variance | 128 px between_block_var / between_share | 6.957941 / 0.063301 |
| block_variance | 8 px between_block_var / between_share | 16.137232 / 0.143737 |
| autocorrelation | "1,0" | 0.173512 |
| autocorr_summary | axis_mean / diag_mean / diag_minus_axis | 0.121601 / 0.11203 / −0.009571 |
| directional_gradient | diag_excess / coherence | 0.000479 / 0.013329 |
| directional_gradient | streak_angle_deg | 177.938354 |
| directional_gradient | band_peak_deg / band_peak_to_second | 90 / 1.650943 |
| seam_repetition | row_seam / col_seam | 0.052926 / 0.098393 |
| seam_repetition | row_periodicity / col_periodicity | 0.688919 / 0.244287 |
| seam_repetition | tile_repeat / tile_period_px | 0.085161 / 64 |
| seam_repetition | seam_repetition_score | 0.688919 |

### 3.2 Candidate vs donor folder (`mode=compare-ref`, 12 files) — OBSERVED numbers

The tool's `flags` (heuristic prompts, not verdicts), verbatim:

```
flat_large_scale: large-block luma variance far below reference
low_fine_variation: candidate 41.63 is < half the reference 1029
seam_repetition.row_periodicity: candidate 0.689 exceeds reference 0.232
compare_ref: donor stills include UI/units/rock/water; treat all deltas as scene-context SMOKE only
```

Key distribution values (`candidate` | donor median [min..max] | z | `outside_donor_range`):

| Metric | Candidate | Donor median [min..max] | z | outside |
|---|---|---|---|---|
| color.std_luma | 10.595727 | 35.017412 [24.176443..79.225838] | −2.128948 | True |
| color.std_saturation | 0.029662 | 0.189215 [0.150090..0.283303] | −4.813305 | True |
| color.mean_saturation | 0.674427 | 0.442793 [0.106415..0.583963] | 2.028283 | True |
| color.mean_luma | 91.432076 | 74.375896 [52.765949..169.258514] | 0.212716 | False |
| color.mean_rgb.2 (blue) | 31.642731 | 46.563 (min 31.847) | −0.702734 | True |
| block_variance.2.between_share (8 px) | 0.143737 | 0.629230 [0.442896..0.888854] | −4.064340 | True |
| block_variance.6.between_block_var (128 px) | 6.957941 | 222.977013 [35.101391..3561.938965] | −0.536228 | True |
| autocorr_summary.axis_mean | 0.121601 | 0.533925 [0.394850..0.799444] | −3.623434 | True |
| autocorrelation."1,0" | 0.173512 | 0.837152 [0.682030..0.937667] | −7.704499 | True |
| directional_gradient.coherence | 0.013329 | 0.054378 [0.036518..0.115455] | −2.095903 | True |
| directional_gradient.diag_excess | 0.000479 | 0.016832 [0.000289..0.047297] | −1.358043 | False |
| directional_gradient.band_peak_deg | 90 | 165 | −0.472377 | False |
| directional_gradient.band_peak_to_second | 1.650943 | 1.226 | 2.067465 | False |
| seam_repetition.row_seam | 0.052926 | 0.757 | −2.272100 | False |
| seam_repetition.col_seam | 0.098393 | 0.709 | −4.267037 | True |
| seam_repetition.row_periodicity | 0.688919 | 0.232149 [0.074461..0.441786] | 3.879365 | True |
| seam_repetition.tile_repeat | 0.085161 | 0.523 | −2.555168 | True |
| seam_repetition.tile_period_px | 64 | 7 [7..45] | 5.021667 | True |

### 3.3 Ground-band crop (`--crop 120,60,1040,580`, 1040×580) — OBSERVED numbers

mean_rgb [93.476562, 96.519455, 31.416187]; mean_luma 91.171379; std_luma 10.422171;
mean_saturation 0.675714; std_saturation 0.027752; BV128 between_block_var 4.417590 /
between_share 0.041325; autocorrelation "1,0" 0.145275, axis_mean 0.093691;
diag_excess 0.000926, coherence 0.014512, band_peak_deg 90, band_peak_to_second 1.677783;
row_periodicity 0.686838, row_seam 0.486011, col_seam 0.178275, tile_repeat 0.060105,
tile_period_px 7.

### 3.4 `smallmap_capture.py stats` — OBSERVED numbers

1280×720; bytes 2129263; `non_black_fraction: 1.0`; mean_rgb [93.749, 96.783, 31.643];
mean_luma 91.432; `full_width_dark_rows: 0`; `full_width_dark_row_fraction: 0.0`.
The tool prints: `NOTE: qualitative comparison only. No donor parity is claimed.`

### 3.5 Metric interpretation (DERIVED / INFERRED — never a gate)

- **DERIVED:** donor median `block_variance.6.between_block_var` is 222.977013 vs candidate
  6.957941, i.e. the candidate's 128-px large-scale mottling is roughly 1/32 of the donor median.
  This is arithmetic on the copied numbers; it corroborates the visual flat-field read in R4.
- **DERIVED:** donor median `std_luma` 35.017412 vs candidate 10.595727 (≈1/3.3); donor median
  `std_saturation` 0.189215 vs candidate 0.029662 (≈1/6.4); donor median `autocorr."1,0"` 0.837152
  vs candidate 0.173512 (≈1/4.8). Together they quantify the "uniform olive, pixel-grain dominates"
  reading.
- **DERIVED:** `full_width_dark_rows=0` on a 720-row frame means zero rows met the >90%-luma<20
  predicate (this frame is water-free, so the predicate is recorded as diagnostic only).
- **INFERRED (caveated):** the elevated `row_periodicity=0.688919` and `tile_period_px=64` are
  consistent with the faint near-horizontal soft striping described in R2, but no cause is proven by
  this one stub frame; the donor stills contain units/rock/UI and are not matched-camera frames.
- **INFERRED (caveated):** `diag_excess≈0.0005` is essentially isotropic, so the charter's "faint
  diagonal streaks" are **not** proven by first-derivative diagonal energy on this frame — consistent
  with C01 §5.2. The FFT view (`band_peak_deg=90`) points to axis-aligned/shallow striping, but this
  needs a crop-level visual check and a true A/B frame before being cited as a cause.
- **INFERRED (caveated):** donor z-scores and `outside_donor_range` are calibration hints computed
  against a folder of 12 unmatched stills (JPEG/WebP compression, units, UI, cliffs, trees, water).
  They are **not** donor parity and cannot promote any R-item to PASS.

## 4. Claim ledger (one row per R-item, C04 §6)

| Item / capture | Scanned region | OBSERVED | DERIVED | INFERRED (caveated) | UNVERIFIED | Evidence id | Item result |
|---|---|---|---|---|---|---|---|
| R1 / P0 stub | x120–1160/y60–640; NN pixel crop x120–376/y60–316 | Uniform olive grain; no cell boundary, checker, repeated identical patch or stepped/nested outline at native scale | `row_periodicity=0.688919`, `tile_period_px=64` are metric hints, not visible grid proof | Faint striping may reflect texgen aliasing; cause unproven from one pose | Donor-matched camera; real-map grid behaviour | `p0_final_formula.png`; `g05_baseline_candidate.json`; `g05_r1_pixel.png` | Not PASS (baseline only; CAP-1/CAP-2 missing) |
| R2 / P0 stub | x200–720/y200–480; right x640–1280/y0–340; lower-left x0–430/y500–690 | Faint short near-horizontal soft strokes a few luma above field in the zoom; no crisp 45° diagonals or classic moiré; right/lower-left uniform | `diag_excess=0.000479` ≈ isotropic | Elevated `row_periodicity` consistent with shallow striping; disproof = an A/B frame where strokes vanish | Camera-dependence of strokes (one pose only) | `g05_r2_zoom.png`; `g05_baseline_candidate.json` | Not PASS (baseline only; CAP-1/CAP-2 missing) |
| R3 / P0 stub | x350–950/y480–620 + whole band | No identical dark blotches; uniform olive; no dark rows | `full_width_dark_rows=0`; BV128 between=6.957941 corroborates flat field | None offered | Water-band applicability (water-free frame) | `g05_r3_zoom.png`; `smallmap_capture.py stats` | Not PASS (baseline only; CAP-1/CAP-2 missing) |
| R4 / P0 stub | Whole ground band | Flat olive; fine grain + very low-amplitude soft mottle; no grey rock or dark/light patchwork | Donor median BV128 222.977 vs cand 6.958 (≈1/32); std_luma 10.596 vs 35.017 (≈1/3.3) | Does **not read like** the `CHARTER.md:23-24` samples (comparative judgement); disproof = a post-fix capture with named mottling/rock features | Donor parity (no GPU A/B frame) | `p0_final_formula.png`; `g05_baseline_vs_donors.json`; 12 donor files listed §1.2 | Not PASS (baseline only) |
| R5 / P0 stub | y40–690 + C04 historical artifact boxes | No relief/cliff silhouette, no grey rock faces; no white stepped bands, black rows, z-fighting or new seams in scanned boxes | Historical patch boxes contain only olive field | Absence of relief expected for P0 stub, not a game-build finding | Real-map relief behaviour | `p0_final_formula.png` (whole frame) | Not PASS (baseline only; CAP-2 missing) |
| R6 / P0 stub | Whole frame; prior water boxes | No cyan water anywhere; prior water boxes contain olive ground | Dark-row predicate diagnostic (0 rows) on water-free frame | None offered | Shore transition, water tint, water dark rows | `p0_final_formula.png`; `smallmap_capture.py stats` | UNVERIFIED (no water in frame); not PASS |
| R7 / CAP-3 | N/A | No PNGs | N/A | N/A | Quad during drag, capture path, wall-selected drag | `G04_gate_log.md` §1-2; empty `g04/` dir | UNVERIFIED (NO PNG) → not PASS |
| R8 / CAP-3 | N/A | No PNGs | N/A | N/A | Ghost stage/colour/footprint/clear | `G04_gate_log.md` §1-2; empty `g04/` dir | UNVERIFIED (NO PNG) → not PASS |

## 5. Baseline numbers COORD can measure against (summary)

Freeze these as the **BEFORE** arm; record the exact AFTER file path and timestamp when G04's jobs run:

| Baseline metric | Value | Source |
|---|---|---|
| mean_rgb | [93.748695, 96.783409, 31.642731] | C01 `--json`, full frame |
| mean_luma / std_luma | 91.432076 / 10.595727 | C01 `--json`, full frame |
| std_saturation | 0.029662 | C01 `--json`, full frame |
| BV128 between_block_var / between_share | 6.957941 / 0.063301 | C01 `--json`, full frame |
| BV128 ground-crop between_block_var | 4.417590 | C01 `--crop 120,60,1040,580` |
| autocorrelation "1,0" | 0.173512 | C01 `--json`, full frame |
| diag_excess / coherence | 0.000479 / 0.013329 | C01 `--json`, full frame |
| row_periodicity | 0.688919 | C01 `--json`, full frame |
| tile_repeat / tile_period_px | 0.085161 / 64 | C01 `--json`, full frame |
| full_width_dark_rows | 0 | `smallmap_capture.py stats` |
| non_black_fraction | 1.0 | `smallmap_capture.py stats` |

A genuine improvement should move `BV128 between_block_var`, `std_luma`, `std_saturation` and short-lag
autocorrelation **toward** the donor distributions listed in §3.2 while `row_periodicity` should fall
toward the donor median. These are **movement indicators only**, not thresholds and not a fidelity
gate (C01 §5.1, C04 §5). Use the same terrain-only crop on both arms.

## 6. No PASS verdict — sign-off status

C04 §7 sign-off is **not filled as PASS**. Applying its rules to this baseline:

| C04 §7 item | Status in this baseline | Reason |
|---|---|---|
| 1 — three capture sets exist/integrity-clean | FAIL (missing evidence) | CAP-1/2/3 absent; G04 pre-flight blocked, empty `g04/` dir |
| 2 — no repeating diagonal streaks | Not passable (baseline only) | R2 on stub described; required CAP-1/CAP-2 missing |
| 3 — no grid/checker/tiling | Not passable (baseline only) | R1 on stub described; required CAP-1/CAP-2 missing |
| 4 — no repeated dark blotches | Not passable (baseline only) | R3 on stub described; required CAP-1/CAP-2 missing |
| 5 — multi-scale organic colour variation | FAIL as observed on stub | R4: flat olive field, no large-scale variation (INFERRED comparative) |
| 6 — relief/cliffs/shore; no seams/black rows | Not passable (baseline only) | R5/R6 on stub; CAP-2 missing, no water in stub |
| 7 — selection quad during drag | FAIL (missing evidence) | R7 UNVERIFIED (NO PNG) |
| 8 — ghost final stage | FAIL (missing evidence) | R8 UNVERIFIED (NO PNG) |
| 9 — gates stay green | UNVERIFIED (not read here) | G04 submitted no jobs; gate reports not re-evaluated by G05 |
| 10 — provenance labels | Not assessed (out of baseline scope) | No new change under review in this baseline |
| 11 — no donor-parity certification | SATISFIED (report honesty only — no terrain PASS claimed) | Every parity reference marked UNVERIFIED/PORT APPROX |

**Overall verdict:** `RESULT IS NOT GOOD` for this pre-fix baseline (missing required captures + flat
field). This is a **baseline observation**, not a verdict on the post-fix game build, and **not a PASS**
of any charter §5 item. Item 11 is the only row this review satisfies, and it is a statement about the
report's own honesty, not about terrain quality.

## 7. Hand-off to COORD

1. **Baseline is frozen** in §3 and §5 with exact command lines and scratch JSON paths. Compare any
   future G04 PNG against these numbers using the same `--crop 120,60,1040,580` ground ROI where
   meaningful, and pin seed/camera/zoom across arms.
2. **G04 is blocked** at pre-flight by stale ticket 582 (`pending=1`). Until COORD clears it and G04
   submits jobs, CAP-1/CAP-2/CAP-3 do not exist; no §5 PASS is possible.
3. **No provisional after-comparison** was possible: `...\Temp\opencode\g04\` was empty at review time.
   If new PNGs land later, open them as a separate, provenance-labelled AFTER arm — do not fold them
   into this baseline.
4. Donor parity stays **UNVERIFIED**. Every donor z-score here is a scene-context smoke hint only.

---

*End of G05 baseline review. One report written; no code, config, asset, test, tool, fixture, result, gate or donor file edited; no Godot job submitted; no PASS verdict recorded.*
