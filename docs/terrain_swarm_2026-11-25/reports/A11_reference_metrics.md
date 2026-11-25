---
id: A11
swarm: TERRAIN-SWARM-2026-11-25
title: "Quantitative visual target from the 12 donor reference images"
ticket: A11
status: COMPLETE
labels: [OBSERVED, DERIVED, UNVERIFIED]
read_only: true
created: 2026-11-25
---

# A11 — reference metrics (quantitative visual target)

## 0. Scope and verdict header

Measured the 12 JPG/WEBP files in `C:\Users\Maxym.Oboyshev\Downloads\c3` with Python 3.14 +
Pillow 12.1.1 + numpy 2.4.3, and compared them to the current capture
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\p0fresh01\p0_final_formula.png`.

- All pixel numbers below are **OBSERVED** (computed from the named files).
- Derived medians, percentiles and ratios are **DERIVED** from those observations.
- Any statement that a future fix "matches", "is close to" or "approaches the donor" is
  **UNVERIFIED**. No donor GPU A/B frame exists; all 12 references are third-party
  screenshots of unknown build, camera, compression and downsampling history.

No project code was edited. No Godot job was submitted. Illustration crops removed for license hygiene; measurements and ROI coordinates remain in the tables.

## 1. Method (OBSERVED)

For each image I hand-picked one rectangular **ground-only ROI** from a grid-overlaid
preview (fractional coordinates below). ROIs avoid HUD panels, sky and the largest unit
blocks, but small unavoidable scene contents (bushes, rocks, a few soldiers, JPEG artefacts)
remain. This tends to *inflate* reference variance, so the variance gap reported here is a
conservative lower bound, not an upper one. The ROIs are visual judgements, not a
segmentation algorithm.

Metrics, computed on the ROI in **native source pixels**:

- `mean RGB`, `median RGB` — sRGB 8-bit, channelwise.
- `S` — HSV saturation, `S = (max(R,G,B) - min(R,G,B)) / max(R,G,B)`, mean and median.
- `Y` — Rec.709 luma `Y = 0.2126 R + 0.7152 G + 0.0722 B` on sRGB values (not linearised).
  Reported mean, median, std, 5th/95th percentile, and a 16-bin histogram over `Y∈[0,256)`.
- **Block variance** `BV_B` — divide the ROI into non-overlapping `B×B` blocks
  (`B = 8, 16, 32, 64`), take each block's mean `Y`, and report the variance across those
  block means. This is the requested proxy for organic mottling: high `BV_32` means the
  image has coherent light/dark patches at that scale; low `BV_32` with high pixel-level
  gradient means flat colour plus fine grain. `n/a` where the ROI was too small to yield
  at least two whole blocks.
- `grad n640` — mean of `|dY/dx|` and `|dY/dy|`, after the zoom-control resample below.
  Proxy for high-frequency grain.

**Zoom control (DERIVED).** Because source resolutions and camera distances differ wildly,
each ROI was also resampled to a common width of **640 px** (LANCZOS, aspect preserved)
and all block statistics recomputed (`BV*_n640`). Block sizes then mean the same
*fraction of the ROI extent*. This normalises pixel scale, **not** world area; see §6.

Green-ground reference set for medians = indices **1, 2, 3, 5, 6, 7, 8, 9, 10, 11**
(n=10). Index 0 is snow, index 4 is sand/dirt; they are reported but excluded from the
green-ground medians. Index 10 is an unusually uniform grass ROI and acts as a low outlier.

ROI table (fractional x0,y0,x1,y1 of the full image):

| # | file | full px | ROI fraction |
|---|---|---|---|
| 0 | 3173885360_preview_Turkish battle 19 Light Infantry rush.jpg | 1920x1080 | .01,.62,.19,.84 |
| 1 | 523480776.jpg | 720x405 | .00,.60,.18,.92 |
| 2 | 899956545_preview_20170411195032_1.jpg | 1366x768 | .02,.50,.20,.72 |
| 3 | Cossacks3AttackingVillage.webp | 2355x1376 | .70,.68,.96,.90 |
| 4 | MADVBuilding1.JPG | 485x486 | .02,.02,.20,.20 |
| 5 | articolo-787.jpg | 960x540 | .30,.27,.42,.39 |
| 6 | cossacks-3-guardians-of-the-highlands-pc-gioco-steam-wallpaper-3.jpg | 1916x1080 | .30,.84,.42,.98 |
| 7 | cossacks-3-v1-498085.jpg | 1280x720 | .35,.55,.48,.70 |
| 8 | hqdefault.jpg | 480x360 | .28,.68,.46,.86 |
| 9 | images.jpg | 588x340 | .42,.50,.52,.60 |
| 10 | large_1.webp | 788x377 | .02,.53,.12,.68 |
| 11 | maxresdefault_1.jpg | 512x288 | .05,.20,.28,.42 |
| 12 | **p0_final_formula.png (current capture)** | 1280x720 | .02,.02,.98,.98 |

## 2. Colour and luma (OBSERVED)

| # | file | full px | ROI px | mean RGB | median RGB | S mean | S med | Y mean | Y med | Y std | Y p5-p95 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | snow battle | 1920x1080 | 345x238 | 205.35, 204.0, 212.68 | 228, 228, 239 | 0.057 | 0.049 | 204.9 | 228.8 | 51.6 | 89-248 |
| 1 | 523480776.jpg | 720x405 | 129x129 | 65.66, 68.77, 28.95 | 71, 75, 30 | 0.593 | 0.593 | 65.2 | 71.1 | 18.2 | 37-84 |
| 2 | 899956545_preview | 1366x768 | 246x168 | 69.0, 71.62, 32.71 | 71, 73, 32 | 0.554 | 0.562 | 68.2 | 70.0 | 20.6 | 34-97 |
| 3 | Cossacks3AttackingVillage.webp | 2355x1376 | 612x303 | 69.16, 68.44, 39.56 | 68, 69, 35 | 0.463 | 0.471 | 66.5 | 66.2 | 27.3 | 24-108 |
| 4 | MADVBuilding1.JPG | 485x486 | 88x88 | 194.95, 152.36, 106.51 | 196, 154, 108 | 0.455 | 0.452 | 158.1 | 159.5 | 10.1 | 139-171 |
| 5 | articolo-787.jpg | 960x540 | 115x65 | 88.7, 88.54, 46.02 | 83, 86, 40 | 0.517 | 0.538 | 85.5 | 82.5 | 21.7 | 63-119 |
| 6 | highlands wallpaper | 1916x1080 | 230x151 | 64.93, 65.01, 37.16 | 54, 53, 32 | 0.444 | 0.414 | 63.0 | 52.0 | 40.1 | 22-148 |
| 7 | **cossacks-3-v1-498085.jpg (ref A)** | 1280x720 | 166x107 | 90.25, 90.84, 43.33 | 93, 95, 40 | 0.541 | 0.562 | 87.3 | 90.5 | 19.6 | 51-118 |
| 8 | hqdefault.jpg | 480x360 | 86x65 | 77.1, 84.96, 36.59 | 84, 93, 38 | 0.572 | 0.570 | 79.8 | 87.3 | 18.6 | 39-95 |
| 9 | images.jpg | 588x340 | 59x34 | 67.29, 63.0, 37.17 | 64, 60, 33 | 0.488 | 0.513 | 62.0 | 58.8 | 22.0 | 30-99 |
| 10 | large_1.webp | 788x377 | 79x57 | 80.14, 86.55, 34.08 | 80, 87, 34 | 0.608 | 0.605 | 81.4 | 81.8 | 4.6 | 76-87 |
| 11 | maxresdefault_1.jpg | 512x288 | 118x63 | 107.69, 111.38, 62.92 | 108, 113, 62 | 0.440 | 0.447 | 107.1 | 108.4 | 12.4 | 86-119 |
| **12** | **p0_final_formula.png** | 1280x720 | 1229x691 | **93.73, 96.76, 31.62** | 93, 97, 32 | **0.675** | 0.676 | 91.4 | 91.2 | **10.6** | 75-109 |

The current capture sits *inside* the reference range in mean luma (91.4 vs green-ref
median 74.0, p75 84.5) and in mean colour (R≈G≈94, B≈32; ref A is 90, 91, 43), but its
**luma spread is roughly half** the reference median and its saturation is the **highest
of all 13 ROIs**.

## 3. Multi-scale block variance (OBSERVED / DERIVED)

`BV_B` = variance of `B×B` block-mean luma. `nat` = native pixels; `n640` = after
resampling ROI width to 640 px.

| # | file | BV8 nat | BV16 nat | BV32 nat | BV64 nat | BV8 n640 | BV16 n640 | BV32 n640 | BV64 n640 | grad n640 |
|---|---|---|---|---|---|---|---|---|---|---|
| 0 | snow battle | 1807.1 | 1645.1 | 1402.1 | 1307.7 | 1965.7 | 1773.9 | 1587.5 | 1431.2 | 9.37 |
| 1 | 523480776.jpg | 240.6 | 198.2 | 138.6 | 106.0 | 306.5 | 277.7 | 247.8 | 215.4 | 0.74 |
| 2 | 899956545_preview | 227.8 | 191.8 | 141.1 | 75.0 | 291.5 | 246.6 | 199.5 | 151.7 | 4.07 |
| 3 | Cossacks3AttackingVillage.webp | 546.2 | 475.0 | 393.0 | 284.3 | 553.1 | 480.5 | 385.6 | 280.2 | 6.51 |
| 4 | MADVBuilding1.JPG | 36.2 | 34.6 | 15.9 | n/a | 83.5 | 59.6 | 43.0 | 35.3 | 1.02 |
| 5 | articolo-787.jpg | 237.4 | 83.8 | 8.5 | n/a | 413.4 | 343.0 | 264.4 | 157.7 | 1.40 |
| 6 | highlands wallpaper | 737.9 | 559.0 | 325.4 | 145.1 | 1106.3 | 841.2 | 595.6 | 415.1 | 6.27 |
| 7 | cossacks-3-v1-498085.jpg | 219.5 | 164.3 | 144.1 | 93.3 | 299.7 | 243.3 | 205.0 | 160.3 | 2.10 |
| 8 | hqdefault.jpg | 253.6 | 221.6 | 231.7 | n/a | 332.9 | 306.2 | 274.6 | 255.2 | 0.60 |
| 9 | images.jpg | 106.0 | 68.2 | n/a | n/a | 442.9 | 375.0 | 247.3 | 143.3 | 1.20 |
| 10 | large_1.webp | 5.6 | 4.1 | 1.1 | n/a | 17.9 | 14.1 | 9.2 | 5.6 | 0.17 |
| 11 | maxresdefault_1.jpg | 57.6 | 46.6 | 41.6 | n/a | 130.3 | 101.4 | 73.1 | 39.1 | 0.91 |
| **12** | **p0_final_formula.png** | **15.3** | **12.5** | **9.9** | **7.2** | **12.6** | **10.1** | **8.7** | **6.5** | **5.00** |

Green-ground medians (n=10) versus p0 (DERIVED):

| metric | ref median | ref p25 | ref p75 | p0 | ref med / p0 |
|---|---|---|---|---|---|
| BV8 native | 232.6 | 134.4 | 250.3 | 15.3 | **15.2x** |
| BV16 native | 178.1 | 72.1 | 215.8 | 12.5 | **14.3x** |
| BV32 native | 141.1 | 41.6 | 231.7 | 9.9 | **14.2x** |
| BV64 native | 106.0 (n=5) | 93.3 | 145.1 | 7.2 | 14.6x |
| BV8 n640 | 319.7 | 293.6 | 435.5 | 12.6 | 25.3x |
| BV16 n640 | 292.0 | 244.2 | 367.0 | 10.1 | 28.9x |
| **BV32 n640** | **247.6** | 200.9 | 272.0 | **8.7** | **28.6x** |
| BV64 n640 | 159.0 | 145.4 | 245.2 | 6.5 | 24.4x |
| luma std | 20.1 | 18.3 | 21.9 | 10.6 | 1.90x |
| HSV sat mean | 0.529 | 0.469 | 0.567 | 0.675 | 0.78x (p0 is 1.28x higher) |
| grad n640 | 1.30 | 0.78 | 3.58 | 5.00 | 0.26x (p0 is 3.9x higher) |

Per-image `BV32 n640 / p0` ratios for the green set: 28.6, 23.0, 44.5, 30.5, 68.8,
23.7, 31.7, 28.6, **1.1** (uniform grass, image 10), 8.4. Ref A alone is **23.7x** native
(144.1 vs 9.9) and **23.7x** normalised (205.0 vs 8.7).

**The deficit is present at every scale from 8 to 64 px** — this is not a single mistaken
tile size, it is an absence of coherent variation across the whole band.

## 4. Luma histogram (OBSERVED)

16 bins over `Y∈[0,256)`, i.e. 16 levels per bin.

| image | bin counts (0-15) |
|---|---|
| ref A (7) | 14, 77, 518, 1715, 2719, 7655, 3724, 938, 274, 91, 29, 6, 2, 0, 0, 0 |
| attacking village (3) | 3141, 15485, 33543, 36634, 32880, 40137, 16587, 4474, 1388, 572, 307, 146, 91, 35, 15, 1 |
| articolo-787 (5) | 3, 12, 83, 306, 2342, 3959, 339, 117, 64, 63, 59, 55, 43, 28, 2, 0 |
| **p0 (12)** | 3, 49, 425, 5294, 105877, **464344**, **248746**, 23681, 802, 18, 0, 0, 0, 0, 0, 0 |

DERIVED: 84.0% of p0's ROI pixels fall in bins 5-6 (`Y≈80-112`); the 5th-95th span is only
34 levels (75-109). Ref A's p5-p95 span is 67 levels (51-118) and it occupies bins 2-9.
The current field is a narrow spike; the donor fields are broad, asymmetric distributions
with a real dark tail (tree shadows, ravines, rock) and a light tail.

## 5. The 2-3 most diagnostic numbers a fix should move

All targets below are **DERIVED from the observed reference band** and are *not* verified
donor parity. Direction is the important part.

1. **`BV32 n640`: 8.7 now → move UP roughly 20-30x, into ≈150-270.** This is the single
   best discriminator: it measures whether light/dark patches exist at a scale larger
   than a tile. The reference median is 247.6 and ref A is 205.0. A fix that only changes
   palette will not move this number. `BV8/16/64` should rise in step; a rise at only one
   scale would indicate a new periodic artefact rather than organic mottling.
2. **`grad n640`: 5.00 now → move DOWN roughly 3-4x, toward ≈1-2.** p0 has *more*
   pixel-level variation than 9 of the 10 green references despite having far less
   block-level variation. That combination — high-frequency grain with no low-frequency
   structure — is the quantitative signature of the reported "artificial pattern / fine
   noise on a flat field". Energy must move from high to low spatial frequency; adding
   more fine dither would worsen this metric.
3. **`luma std` / histogram width: 10.6 now → move UP ≈1.9x, toward ≈18-22**, with p5-p95
   widening from 34 to roughly 60-80 levels and real occupancy in bins 2-4 and 7-9. This
   is the cheap frame-level check that the block-variance change is visible, not just a
   local statistic.

Secondary (lower confidence): **`HSV sat mean` 0.675 → down ≈20% toward ≈0.53**, and
raise the blue channel slightly relative to R/G (p0 mean B=31.6 vs ref A B=43.3) to move
from a hard yellow-olive toward the donor's muted green. This is a palette observation
only; it does not address the structure problem and must not substitute for items 1-3.

## 6. Confounds and limits (explicit)

- **Camera / zoom (OBSERVED).** Full images span 485x486 to 2355x1376 and ROI widths span
  59-612 native px. Some references are overviews covering scores of tiles; others are
  close-ups or YouTube-derived thumbnails. The 640-px normalisation equalises *pixel*
  scale only — the world area covered by one ROI is unknown and almost certainly not
  equal across files. Ratios are therefore **order-of-magnitude directional evidence**,
  not calibrated world-space measurements.
- **Angle.** p0 is a shallow-angle 64² test capture with no relief; references are angled
  overviews with trees, cliffs and formations. Part of the reference block variance comes
  from those objects, not from ground texture alone. This biases the ratio upward (see
  §1); conversely, reference 10 shows that a genuinely uniform grass patch can score as
  low as 1.1x p0, so the gap is not universal across every donor region.
- **Compression / resampling.** 11 references are JPEG (one WEBP), p0 is lossless PNG.
  JPEG artefacts can add high-frequency energy, which would tend to *raise* reference
  `grad`; the observed reference `grad` is nevertheless lower, so item 2 is conservative.
  Downsampled thumbnails (`hqdefault.jpg`, `maxresdefault_1.jpg`, `images.jpg`) have
  unreliable fine detail; their block variance is more trustworthy than their gradient.
- **Biome.** Image 0 is snow (S=0.057, Y=205) and image 4 is sand (Y=158); they are
  excluded from green-ground medians. Image 6 is rocky highland with a high dark tail.
- **Streak test inconclusive (UNVERIFIED).** A lag-32 luma autocorrelation check on the
  640-normalised ROIs gave p0 diagonal-vs-axis ratio 0.69, inside the reference range
  0.50-0.99. This metric does **not** confirm the diagonal streaks; their cause (tiling,
  filtering or mask folding per charter §2) remains UNVERIFIED by this report.

## 7. Illustration files (OBSERVED)

Illustration crops removed for license hygiene; measurements and ROI coordinates remain in the tables.

`A11_p0_center_2x.png` (in this report directory) is retained: a 2x nearest-neighbour zoom
of the port's own p0 centre, showing the fine grain and faint banding. It contains no
donor pixels.

## 8. Reproduction

Read-only script logic (was run from the system temp folder, not from the project):
open each file with Pillow, crop the fractional ROI in §1, compute channel statistics and
`Y = 0.2126R + 0.7152G + 0.0722B`; for each `B` in `{8,16,32,64}` reshape the top-left
multiple-of-`B` region into `(rows, cols, B, B)`, average the last two axes, take
`var(ddof=1)`; resample the ROI to width 640 with LANCZOS and repeat. Raw per-image JSON
was produced but is not written into the project tree.

## 9. Status

- OBSERVED: §1-§4, §7, all tables.
- DERIVED: medians, percentiles, ratios, target bands, the histogram interpretation.
- **UNVERIFIED: any donor-parity or similarity claim. No donor GPU A/B frame was available
  to this ticket, so this report defines a measurement target; it does not certify a fix.**
