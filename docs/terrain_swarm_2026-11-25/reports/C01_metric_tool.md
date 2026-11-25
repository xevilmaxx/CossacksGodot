---
id: C01
ticket: "TERRAIN-SWARM-2026-11-25 / C01 (tool author)"
title: "terrain_ab_metric.py — terrain texture-statistics A/B metric"
status: IMPLEMENTED
created: 2026-11-25
labels: [observed, derived, inferred, UNVERIFIED]
---

# C01 — texture-statistics A/B metric tool

## 1. Scope and provenance

- **OBSERVED (timeline):** when this ticket first read the reports directory it
  contained only `CHARTER.md`; A09/A11 (and other reports) landed from sibling
  agents during the work. The tool was therefore designed from `CHARTER.md`
  §1–§5 plus the ticket's explicit interface, using `compare_shots.py` and
  `terrain_compare.py` as style precedent. After A09/A11 appeared, they were
  read in full and the tool/report were reconciled where compatible — see §7.
- **Files changed:** exactly one new file, `variant3d/tools/terrain_ab_metric.py`.
  This report is the only other file written. **No game code, no test code, no
  runner jobs, no Godot process.**
- **Guardrails kept:** stdlib + Pillow + numpy only; numpy import guarded with a
  clear error and exit 2; Windows-safe (`pathlib`, quoted paths, ASCII console
  output); verified on Python 3.14.3 / Pillow 12.1.1 / numpy 2.4.3.
- **UNVERIFIED:** donor parity. Nothing in this tool or report establishes that
  the port matches the donor; the charter's rule ("observed vs inferred vs
  UNVERIFIED", donor parity stays UNVERIFIED without a real donor GPU A/B
  frame) is preserved. All numbers are **SMOKE METRICS, not a fidelity gate**.

## 2. What it measures

All spatial metrics use Rec.709 luma in 0..255. Images are never compared
pixel-to-pixel, so different scenes and resolutions can be compared. Use
`--crop x,y,w,h` (same pixel box on every input) or `--crop-frac x0,y0,x1,y1`
(fractional box resolved per image, e.g. an A11 ground ROI) to restrict the
measurement to terrain-only regions.

| Group | JSON path | Meaning / units |
|---|---|---|
| Colour | `color.mean_rgb`, `std_rgb`, `mean_luma`, `std_luma`, `p05_luma`, `p95_luma`, `mean_saturation`, `std_saturation` | RGB/luma in 0..255; saturation = (max-min)/max per pixel, 0..1 |
| Multi-scale block variance | `block_variance[i].{block_px, block_count, between_block_var, within_block_var, between_share}` | `between_block_var` = variance of block **means** (large-scale mottling); `within_block_var` = mean per-block variance (fine grain); `between_share` = between/(between+within) |
| Autocorrelation | `autocorrelation."dx,dy"` | Pearson r of luma at pixel lag (dx,dy); axis and diagonal lags by default; `autocorr_summary` averages them |
| Directional gradient | `directional_gradient.{axis_gradient_energy, diag_plus_energy, diag_minus_energy, diag_plus_share, diag_minus_share, diag_excess, coherence, gradient_angle_deg, streak_angle_deg}` | Central-difference gradient; `diag_plus` = energy along (1,1) (streaks along (1,-1)); `diag_minus` = energy along (1,-1) (streaks along (1,1)); shares sum to 1; `diag_excess` = max(share)-0.5 (0 = isotropic) |
| Spectral banding | `directional_gradient.band_{anisotropy, peak_deg, peak_to_mean, peak_to_second, diagonal_share}` | 12-bin, 15°-wide directional FFT power of a 9×9 box-detrended, Hann-windowed luma in the 10..min(h,w)/4 cycle annulus. Descriptive only — see §5. |
| Seam / repetition | `seam_repetition.{row_seam, col_seam, row_periodicity, col_periodicity, tile_repeat, seam_repetition_score, driver, ...}` | `row/col_seam` = isolated one-row spike score from the max/p99 second difference of row/column mean profiles; `row/col_periodicity` = peak-vs-neighbour correlation of a quadratically detrended profile; `tile_repeat` = shifted-patch MAD relative to similar-size shifts; all in 0..1, higher = more suspect. `seam_repetition_score` is the max component and `driver` names it. |

`--json` emits one object with `schema: terrain_ab_metric/1`, `mode`
(`single`, `compare-ref` or `candidate-only`), `candidate`/`reference` metric
trees, plus:

- **candidate-only mode** (one path, no reference): candidate metrics only and a
  `candidate_only` flag note — this is the form C02's gate plan uses;
- single mode: `delta` — flat dotted keys mapped to
  `{candidate, reference, diff, ratio}`;
- compare-ref mode: `reference_distribution` (mean/median/min/max/std per
  metric over every readable image in the folder), `distribution` (candidate
  value, donor median/min/max, z-score, `outside_donor_range` per metric) and
  `reference_files` (paths/sizes; full metrics with `--per-file`).

`flags` is a list of **heuristic prompts**, never a verdict. Exit 0 = computed,
2 = bad invocation / unreadable input / missing numpy.

## 3. Usage (run from project root, `python` not `python3`)

PowerShell-safe quoting examples; replace the candidate path with the frame
under test.

```powershell
# 1. Candidate vs one reference still (human-readable table)
python variant3d\tools\terrain_ab_metric.py `
  "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\p0fresh01\p0_final_formula.png" `
  "C:\Users\Maxym.Oboyshev\Downloads\c3\cossacks-3-v1-498085.jpg"

# 2. Same pair, machine-readable JSON
python variant3d\tools\terrain_ab_metric.py <candidate.png> <reference.png> --json

# 3. Candidate vs the whole donor folder (12 images found at time of writing)
python variant3d\tools\terrain_ab_metric.py <candidate.png> --compare-ref `
  "C:\Users\Maxym.Oboyshev\Downloads\c3"

# 4. Distribution mode with every donor file's metrics in the JSON
python variant3d\tools\terrain_ab_metric.py <candidate.png> --compare-ref `
  "C:\Users\Maxym.Oboyshev\Downloads\c3" --json --per-file

# 5. Single-image smoke metrics (the form C02's gate plan invokes)
python variant3d\tools\terrain_ab_metric.py <candidate.png> --json

# 6. A11 ground ROI as a fractional crop (per-image, no pixel math needed)
python variant3d\tools\terrain_ab_metric.py `
  "C:\Users\Maxym.Oboyshev\Downloads\c3\cossacks-3-v1-498085.jpg" `
  --crop-frac .35,.55,.48,.70 --json

# 7. Terrain-only comparison: pixel crop must be meaningful on BOTH images
python variant3d\tools\terrain_ab_metric.py <candidate.png> <reference.png> `
  --crop 200,150,800,500 --json

# 8. Custom scales and lags (blocks in px; lags in px, semicolon-separated)
python variant3d\tools\terrain_ab_metric.py <candidate.png> <reference.png> `
  --blocks 8,16,32,64,128 --lags "1,0;0,1;1,1;1,-1;32,0;0,32"
```

`--crop` and `--crop-frac` are mutually exclusive; the latter resolves against
each image's own dimensions, so it is the right choice for donor stills with
different native resolutions.

The tool reads any Pillow-readable image (PNG/JPG/WebP/BMP/TIFF); the candidate
is normally a PNG capture. Images under 8×8 after crop are rejected.

## 4. Verification performed (OBSERVED)

| Check | Result |
|---|---|
| `python -m py_compile variant3d\tools\terrain_ab_metric.py` | clean |
| Single-reference run, P0 frame vs `cossacks-3-v1-498085.jpg` | exit 0, all groups printed |
| `--compare-ref "C:\Users\Maxym.Oboyshev\Downloads\c3"` | exit 0, 12 donor images aggregated |
| `--json`, `--per-file` | parses as one JSON object; 95 flat distribution keys, 12 per-file entries |
| `--crop 100,100,512,512 --blocks 8,32,128 --lags '...'` | exit 0, custom values reflected in JSON |
| Candidate-only (`<candidate.png> --json`, C02 form) | exit 0, `mode=candidate-only`, `reference=null` |
| `--crop-frac .35,.55,.48,.70` on A11 ref A | exit 0, 166×108 ROI, mean luma 87.19 (A11 reports 87.3); BV8 218.65 (A11 219.5) |
| Both reference and `--compare-ref`, both `--crop` and `--crop-frac`, missing file/folder | exit 2 with a clear message |
| Simulated missing numpy (import blocker) | exit 2, actionable install message, no traceback |

No runner job was submitted (`godot_runner.py status` was not needed: this is a
docs/tool-only ticket, zero Godot jobs per `AGENT_PROTOCOL.md` §1b).

## 5. Interpretation guidance

### 5.1 Strongest discriminator in the current gap (OBSERVED from the runs)

For the charter's P0 frame (`p0_final_formula.png`) against the donor folder
median:

| Metric | Candidate | Donor median | Reading |
|---|---|---|---|
| `block_variance` 128 px `between_block_var` | 6.96 | 222.98 | **DERIVED:** almost no large-scale organic colour mottling — matches charter §1 "flat uniform olive field ... no large-scale organic variation" |
| `std_luma` | 10.60 | 35.02 | flat luma distribution |
| `std_saturation` | 0.0297 | 0.1892 | uniform olive instead of patchy grass/rock |
| `autocorrelation."1,0"` | 0.17 | 0.84 | pixel-scale grain dominates; little spatial structure |

These are the numbers to watch for a fix: a genuine improvement should raise
large-block between-variance, luma/saturation spread and short-lag
autocorrelation **toward** the donor distribution. Because the two scenes are
different, use the same terrain-only `--crop` on both sides and compare
**relative movement across A/B frames** rather than chasing exact donor values.

### 5.2 Directional / banding metrics (INFERRED, UNVERIFIED)

- The P0 frame's pixel-gradient `diag_excess` is ~0.0005 (essentially isotropic)
  and `coherence` ~0.013, while the donor median is ~0.017/~0.054. The
  "diagonal streaks" in the charter are **not** visible in first-derivative
  diagonal energy on this frame — do not claim they are proven by this metric.
- The detrended-FFT view gives the P0 frame `band_peak_deg = 90` (horizontal
  banding direction) and `band_peak_to_second = 1.65`, versus donor medians
  165 and 1.23. **INFERRED:** the artefact reads as axis-aligned/shallow
  striping at mid frequencies, not a clean ±45° diagonal; this needs a visual
  crop check before being cited as cause.
- Donor stills contain unit rows, cliffs and trees that dominate directional
  statistics. `band_*` values are **descriptive**, never a standalone gate.

### 5.3 Seam / repetition metrics (INFERRED)

- P0 `row_seam`/`col_seam` ≈ 0.05/0.10 vs donor medians ≈ 0.76/0.71: the P0
  frame has **no** isolated one-row seam. The donor's higher values come from
  legitimate sharp features (rock faces, unit edges), which is why these are
  scored relative to the 99th percentile rather than to the median.
- P0 `row_periodicity` ≈ 0.69 vs donor median ≈ 0.23 — the one "artificiality"
  flag that fires on the repetition group. **INFERRED:** periodic row structure
  consistent with repeated bands; confirm visually.
- `tile_repeat` is 0.085 (P0) vs 0.52 (donor median). **Counter-intuitive but
  expected:** the donor screenshots repeat their terrain texture many times,
  whereas the P0 frame is per-pixel noise. A high `tile_repeat` is *not*
  automatically bad — it must be read together with block variance (a repeated
  cell is much more visible on a flat field). Do not gate on it alone.

### 5.4 General caveats (binding)

1. Donor images contain UI, units, trees and cliffs; the tool measures the
   whole frame unless `--crop` / `--crop-frac` is given. Never call a
   full-frame delta proof.
2. JPEG/WebP compression changes the high-frequency metrics. Compare like with
   like (PNG captures vs PNG captures) where possible.
3. `flags` use fixed heuristics (half/double ratios, >0.55 absolute for
   repetition). They are triage hints, **not thresholds**; no assertion in the
   repo is tied to them.
4. A09/A11 now exist; their calibration and world-scale framing differ from
   this tool's pixel-domain schema. §7 states the mapping; do not silently
   reinterpret either report's numbers.
5. Adding this tool as a red gate would require a known-good A/B pair and an
   explicit decision — out of scope for C01 and **not done here**. C02 cites
   this tool as a **smoke metric only** (its gate plan §2 G2/G3), which matches.

## 7. Reconciliation with A09 and A11 (OBSERVED / DERIVED)

- **A09's proposed file was not created.** A09 §3 specifies a separate
  `variant3d/tools/terrain_repetition_metrics.py` with `--px-per-m`,
  2/8/32 m autocorrelations, a 2 m tile-boundary phase contrast, and an
  `ARI` score. C01's binding scope allows **one** new tool file at
  `terrain_ab_metric.py`, so those features were not duplicated. The pixel-domain
  equivalents here are `--lags` (default includes 1/4/16/64 px axis and 1/2/8/32
  px diagonal lags), `--blocks`, `seam_repetition` and `delta`/`distribution`.
  At A09's PORT APPROX 35.9 px/m, 2 m ≈ 72 px and 8 m ≈ 287 px; feed those as
  `--lags 72,0;0,72;72,72;72,-72` if a world-scale reading is wanted. The ARI
  formula (A09 §4.1) and `--baseline` ranking mode are **not implemented** — no pass/fail index is emitted.
- **A11's ROI method is supported.** `--crop-frac .35,.55,.48,.70` on ref A
  reproduces A11's ground ROI (166×108 here vs 166×107 in A11): mean luma
  87.19 vs A11 87.3; BV8 218.65 vs A11 219.5; BV16 161.6 vs 164.3. BV32/BV64
  differ slightly because A11 uses `ddof=1`, a differently rounded ROI and a
  640-px normalisation this tool does not apply. Use `--crop-frac` per image for
  A11-style ROIs; never compare a whole P0 frame against a cropped donor ROI
  (C02 G4 explicitly forbids that).
- **A11's diagnostic targets map onto this tool as directions, not thresholds:**
  `block_variance` between-variance UP at 8–64 px, `std_luma` UP toward ≈18–22,
  `mean_saturation` DOWN toward ≈0.53, and fine pixel gradient energy DOWN.
  A11's `grad n640` is a normalised first-derivative mean; this tool reports raw
  `directional_gradient.axis_gradient_energy` instead — compare A/B frames on
  the same crop, not to A11's absolute numbers.
- **A09's own streak test was inconclusive and A11 agrees**: diagonal-vs-axis
  luma autocorrelation did not confirm the streaks. This tool's spectral
  `band_*` values are likewise descriptive (§5.2); none of the three reports
  confirms diagonal streaks numerically.

## 8. Open questions

- Does the charter's "faint diagonal streaks" refer to the horizontal banding
  the FFT sees at `band_peak_deg = 90`, or to a different scale/orientation
  absent from this capture? Needs a visual crop + A/B frame.
- Should `--compare-ref` default to the canonical donor folder when omitted?
  Kept explicit to avoid silently scoring against untrusted files.
- No numeric threshold is calibrated; C03/C04 verification should use the
  deltas as evidence, not as pass/fail.
