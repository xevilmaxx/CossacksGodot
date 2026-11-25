---
id: QA-WHITE-PIX-02
title: "Independent pixel/colour cross-check of the white-marks tile-id attribution — dominant near-white colour is cyan, absent from all 112 terrain block PNGs"
agent: "QA-WHITE-PIX-02 (read-only QA subagent), coord swarm 2026-11-25"
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB
scope: "One new file only: this report. No source/asset/config/PNG/JSON/stderr/shader/git edit; no Godot submission; no queue mutation. All analysis scripts and JSON lived under %LOCALAPPDATA%\\Temp\\opencode\\qa_white_pix_02\\ only."
exclusive_output: "docs/coord_swarm_2026-11-25/reports/QA_WHITE_PIX_02.md"
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
target_report: "WHITE-MARKS-PIX-01 (ses_ded87c3caffeVgigeaPI51T4G0) — NOT LANDED at QA time: reports/WHITE_MARKS_PIX_01.md absent; SWARM_BOARD.md:350 still RUNNING"
tools: "python 3.14.3, Pillow 12.1.1, numpy 2.4.3; sRGB->CIE Lab (D65), Delta E76"
labels: [observed, derived, inferred, UNVERIFIED]
parity_guard: "PORT APPROX — internal consistency only. No donor GPU A/B frame exists. No donor parity is claimed anywhere in this report."
verdict: "NUMBERS CONFIRMED, ATTRIBUTION REFUTED FOR THE DOMINANT PIXELS. All 44,381 / 4.8156 % / bbox / Rec.709 luma values reproduce exactly. But 89.16 % of those pixels are two light-cyan colours (181,234,255)/(182,233,255) that occur ZERO times in any of the 112 blocks/*.png; CIELAB nearest-colour puts 97.28 % nearest winter0.png at mean Delta E76 17.07, and only 0.95 % nearest any summer/test/rock/grass/sand block (7 pixels nearest rock4). The specific quoted test8/rock4 bright colours have 0 occurrences in the frame. The tile-id-colour explanation survives only as an INFERRED, UNVERIFIED mechanism for a small non-cyan remainder. Target report not landed; its precise claims are UNVERIFIED."
---

# QA WHITE PIX 02 — independent cross-check of WHITE-MARKS-PIX-01's tile-id attribution

## 0. Mandate and boundary

Read-only QA of the tile-id attribution chain for the reproduced white marks.
I re-opened the original raw GPU PNG from disk, recomputed the published pixel
statistics from scratch, and matched its near-white palette against every
`variant3d/assets/terrain/blocks/*.png` using **two independent distance
metrics**: plain RGB Euclidean and CIE Lab ΔE76 (D65). No job was submitted, no
repo file other than this report was written, and the queue was not mutated.

Labels: **observed** = literal artifact bytes, tool output, source line or
direct image read; **derived** = arithmetic/control-flow consequence of
observed data; **inferred** = attribution without a pixel-aligned donor A/B;
**UNVERIFIED** = not established by anything read here.

**Scope limitation (observed):** `reports/WHITE_MARKS_PIX_01.md` was **absent**
at every check during this QA (glob of `reports/*PIX*` found only
`PIXEL_01_p0_capture_review.md`), and `SWARM_BOARD.md:350` still showed
`WHITE-MARKS-PIX-01 … RUNNING`. `QA_WHITE_MARKS_01.md` landed mid-QA and was
read. I therefore cannot quote or score the target report's own final numbers;
its specific tile-id claims remain **UNVERIFIED**. What I *can* score is the
attribution chain that is already published and cited as its basis:
`TERRAIN_MARKS_01.md:100,120-124,141-144` (rank-2 tile-id colour),
`RELIEF_VISUAL_01.md:240-243` (inferred preference for that rank), and
`QA_WHITE_MARKS_01.md:160-166,196` (INFERRED / UNVERIFIED).

**No donor parity claim.** Everything below is PORT APPROXIMATION and internal
consistency only.

---

## 1. Sources

| Kind | Source | Use |
|---|---|---|
| Target (not landed) | `docs/coord_swarm_2026-11-25/reports/WHITE_MARKS_PIX_01.md` | **ABSENT** at QA time; scoped as UNVERIFIED |
| Board | `docs/coord_swarm_2026-11-25/SWARM_BOARD.md:350-351` | Target and sibling task states (`RUNNING`) |
| Reports | `docs/coord_swarm_2026-11-25/reports/RELIEF_VISUAL_01.md` (`:159-174`, `:240-246`) | Published near-white metrics and inferential attribution |
| Reports | `docs/coord_swarm_2026-11-25/reports/TERRAIN_MARKS_01.md` (`:51-59`, `:99-104`, `:120-124`, `:141-144`) | Control-frame baseline and rank-2 tile-id colour claim, incl. quoted `test8.png`/`rock4.png` maxima |
| Reports | `docs/coord_swarm_2026-11-25/reports/QA_WHITE_MARKS_01.md` (`:52-69`, `:160-166`, `:196-197`) | Independent QA that reproduced the numbers but left attribution INFERRED |
| Artifact | `%LOCALAPPDATA%\Temp\opencode\reliefvisual\relief_on.png.raw.png` (2,450,951 B, 1280×720) | Independent pixel re-measurement and direct visual read |
| Assets | `variant3d/assets/terrain/blocks/*.png` — **112 files** (`test*`, `rock*`, `grass*`, `sand*`, `sandsea*`, `desert1`, `ground1`, `winter0-26`) | Block-art colour palettes for RGB/CIELAB matching |
| Source (context only) | `variant3d/scripts/world3d_terrain.gd:147` (`DONOR_SKY_TOP`), `variant3d/scripts/water3d.gd:80-81,190-191` (`SHALLOW_COLOR`/`DEEP_COLOR`), `variant3d/scripts/main.gd:1932-1942` (`p00` blank-detector reference) | Context for the cyan colour's likely non-tile origin; no causal claim |
| Temp outputs | `%LOCALAPPDATA%\Temp\opencode\qa_white_pix_02\{measure.py,measure2.py,measure3.py,measurements*.json}` | Reproducible method; outside repo |

---

## 2. Independent method (observed / derived)

1. **Frame.** `Image.open(...).convert("RGB")` → 921,600 px. Near-white =
   `min(R,G,B) > 180`, the exact definition used by `RELIEF_VISUAL_01.md:162`.
   Both Rec.601 (`0.299/0.587/0.114`) and Rec.709 (`0.2126/0.7152/0.0722`)
   luma were computed; Rec.709 matches `smallmap_capture.py`'s tool formula.
2. **Palettes.** For each of the 112 block PNGs I kept the 40 most frequent
   exact RGB colours **plus** the 40 most frequent colours among pixels with
   `min(R,G,B) > 140` (so rare bright speckles are represented). This yields
   6,219 palette entries; the same palette feeds both metrics, so the metric
   comparison is apples-to-apples.
3. **Metrics.** sRGB→XYZ(D65)→Lab with the standard 0.04045/0.008856
   piecewise functions; ΔE76 = Euclidean Lab distance. Plain RGB distance is
   Euclidean in 0–255 byte space. Two tests: (a) probe colours matched to the
   nearest block palette entry; (b) all 44,381 near-white pixels matched to
   their nearest block palette entry, tallying winning blocks.
4. **Limitation (derived).** Rendered 3D pixels are lit and gamma-processed, so
   an exact RGB identity with an atlas texel is not expected. A small ΔE is
   *suggestive* of a shared hue, not proof of tile identity; a large ΔE is
   stronger negative evidence. Exact-zero occurrences, however, are decisive
   for "this colour was copied from this block".

---

## 3. Cross-check table

| Claim | Report | Independent result | Status |
|---|---|---|---|
| `WHITE_MARKS_PIX_01.md` is landed and can be cross-checked | `SWARM_BOARD.md:350` scope "pixel/tile-id analysis of reproduced white marks", state RUNNING | No such report file at initial read, mid-QA read, or final check; only `QA_WHITE_MARKS_01.md` landed | **UNVERIFIED** (observed) |
| Near-white count = 44,381 (4.8156 % of 921,600), bbox (0,0)–(1279,719) | `RELIEF_VISUAL_01.md:163-164`; reproduced verbatim in `QA_WHITE_MARKS_01.md:56-58` | 44,381; 4.815647 %; bbox `[0,0,1279,719]` — bit-identical | **CONFIRMED** (observed) |
| Luma min/max/mean = 0.0 / 253.845 / 115.039; 122,932 px with luma > 180 | `RELIEF_VISUAL_01.md:165-166`; `QA_WHITE_MARKS_01.md:59-60` | Rec.709 gives exactly 0.0 / 253.845 / 115.039 and 122,932. Rec.601 gives 0.0 / 253.176 / 112.638 and 119,879, so the reported formula is the tool's Rec.709 | **CONFIRMED** (observed + derived) |
| "4×3 quadrant near-white counts" with 16 values | `RELIEF_VISUAL_01.md:167`; `QA_WHITE_MARKS_01.md:66` flags the defect | The 16 values reproduce exactly but form a **4×4** grid; a true 4×3 grid yields `[7443,4579,4597,4888]/[700,622,3536,4385]/[3697,2967,2635,4332]` | **PARTIAL** — numbers confirmed, label refuted (observed) |
| Visual character: flat, stepped/concentric grid-aligned pale bands; no hills | `RELIEF_VISUAL_01.md:134-157`; `QA_WHITE_MARKS_01.md:71-77` | Direct image read agrees: extensive light-cyan/white stepped bands, olive flat ground, no silhouette or self-shadowing | **CONFIRMED** (observed; cause not established) |
| Tile-id colour (`test*`/`rock*`) is the best available explanation of the pale marks | `TERRAIN_MARKS_01.md:100,120-124,141-144`; `RELIEF_VISUAL_01.md:240-243` (inferred); `QA_WHITE_MARKS_01.md:160-166` (INFERRED/UNVERIFIED) | **89.16 %** of near-white pixels are exactly two colours — `(181,234,255)` ×21,750 and `(182,233,255)` ×17,819 — and **neither occurs in any of the 112 block PNGs**. Per-pixel CIELAB: 97.28 % nearest `winter0.png` (mean ΔE76 17.07), only **0.95 %** nearest any summer/test/rock/grass/sand/desert block, **7 px** nearest `rock4.png`. Dominant cyan is ΔE76 **53.05** from `test8.png`, **33.62** from `rock4.png`, **31.84** from `sandsea1.png` | **REFUTED** for the dominant near-white pixels of this frame (observed + derived); tile-id mechanism for the small non-cyan remainder **UNVERIFIED** |
| Quoted `test8.png` bright colour `(222,231,148)` matches `test8` tile art | `TERRAIN_MARKS_01.md:100` ("test8.png max RGB (222,231,148)") | Colour association reproduced under CIELAB: nearest block `test8.png`, ΔE76 **2.98** (plain RGB nearest was `grass_sand2.png`, dist 8.0). But this colour has **0 occurrences** in the frame | **PARTIAL** — block association CONFIRMED by a different method; frame link REFUTED (observed + derived) |
| Quoted `rock4.png` max `(255,239,189)` matches `rock4` tile art | `TERRAIN_MARKS_01.md:100` ("rock4.png max (255,239,189)") | It is a **per-channel maximum**, not a pixel: exact `(255,239,189)` occurs **0 times** in `rock4.png` (2 times in `winter17.png`). CIELAB nearest is `winter17.png` ΔE **0.0**; `rock4.png` ΔE **6.28**. The colour has **0 occurrences** in the frame | **PARTIAL** — per-channel-max label defect; tile and frame attribution REFUTED (observed + derived) |
| A CIELAB-vs-RGB colour match can be reproduced against `blocks/*.png` | Task requirement (not a report claim) | Yes: probe `(222,231,148)` → CIELAB `test8.png` ΔE 2.98 vs RGB `grass_sand2.png` 8.0; probe `(181,234,255)` → both metrics `winter5.png` (RGB 22.85; ΔE 10.41); probe `(255,239,189)` → `winter17.png` exact under both. Changing the metric changes the rank order, so the method is genuinely independent | **CONFIRMED** (derived) |
| Cyan marks plausibly come from a sky/water colour path rather than terrain tile art | No report claims this; contextual source read | `(182,233,255)` is exactly the raw PNG's `(0,0)` colour and equals diag `p00=(0.7137,0.9137,1.0)` in `RELIEF_VISUAL_01.md:105`; the cyan occurs frame-wide. Source constants do not give an exact cyan: sky top `(0,0.141,0.808)` (`world3d_terrain.gd:147`), water shallow `(0.1,0.24,0.24)` / deep `(0,0.025,0.05)` (`water3d.gd:80-81`) | **INFERRED / UNVERIFIED** — plausible non-tile origin, no shader-level proof |
| No donor parity claim is made | `RELIEF_VISUAL_01.md:16`; `QA_WHITE_MARKS_01.md:11`; `TERRAIN_MARKS_01.md:11` | This QA makes none; no donor GPU A/B frame was read or produced | **CONFIRMED** (observed) |

---

## 4. Colour-match detail (derived)

**Exact near-white palette (top 3, frame):** `(181,234,255)` ×21,750;
`(182,233,255)` ×17,819; `(181,233,255)` ×2,244. These three alone are
41,813 of 44,381 pixels (94.2 %). The near-white channel mean is
`(181.56, 232.91, 253.64)` — blue-dominant (`B ≈ 1.0`, `R ≈ 0.71`).
By contrast `test8.png` has mean `(73.0,77.9,27.9)` and per-channel max
`(222,231,148)` (green/yellow-dominant, `B ≪ R,G`), and `rock4.png` mean
`(70.8,61.5,49.9)`, max `(255,239,189)` (red/yellow-dominant). The hue
direction is opposite: the marks are blue-cyan, summer/rock tile art is
olive/yellow. The winter tiles are the only blocks with near-neutral bright
palettes, which is why every nearest-neighbour method picks them — but even
there the best ΔE76 is ~10–17, i.e. **no true colour match**.

**Per-pixel CIELAB attribution of all 44,381 near-white pixels** (6,219 palette
entries, ΔE76, nearest block per pixel):

| Winning block | Pixels | Share | Mean ΔE76 |
|---|---:|---:|---:|
| `winter0.png` | 43,172 | 97.28 % | 17.07 |
| `winter1.png` | 527 | 1.19 % | 13.71 |
| `winter11.png` | 227 | 0.51 % | 6.76 |
| `test18.png` | 133 | 0.30 % | 7.48 |
| `sandrock1.png` | 121 | 0.27 % | 7.00 |
| `grass10.png` | 109 | 0.25 % | 6.79 |
| `rock4.png` | **7** | **0.02 %** | 7.15 |

Aggregate: winter-family winners 43,956 (99.04 %); all
summer/test/rock/grass/sand/desert families combined 422 (0.95 %). Nearest-match
ΔE76 percentiles (0/10/50/90/100) = 0.52 / 16.97 / 17.22 / 17.23 / 17.23 —
the bulk sit at a uniformly large ~17, confirming that these pixels match
*no* block palette closely.

**Interpretation guard (inferred):** the numbers establish a *colour*
mismatch with the cited tile art; they do not distinguish within the
non-cyan 0.95 % remainder, nor do they identify what actually renders the
cyan (sky reflection, water foam, fog or a shader bug are all plausible and
all UNVERIFIED). No mechanism is promoted by this QA.

---

## 5. Verdict

**NUMBERS CONFIRMED; TILE-ID COLOUR ATTRIBUTION REFUTED FOR THE DOMINANT NEAR-WHITE PIXELS; TARGET REPORT UNVERIFIED.**

- **observed / derived:** all published pixel statistics reproduce exactly
  under Pillow/numpy, including the 16-value 4×4 grid mislabelled "4×3" —
  matching `QA_WHITE_MARKS_01.md`'s independent finding. No numeric defect
  in `RELIEF_VISUAL_01.md`.
- **observed / derived:** the near-white population is overwhelmingly
  light-cyan, a colour absent from all 112 terrain blocks, with CIELAB
  distances of 33–53 to the very `test8`/`rock4`/`sandsea` art cited by the
  rank-2 hypothesis. Only 7 of 44,381 pixels are nearest `rock4`.
- **observed:** the specific test8/rock4 bright colours quoted in
  `TERRAIN_MARKS_01.md:100` occur **zero** times in the frame; one of them
  is not even a real pixel colour in `rock4.png` (per-channel max only).
- **inferred / UNVERIFIED:** whether some *other*, small tile-id population
  contributes to the pale tan minority, and what renders the cyan bands, are
  open. No flag-off A/B, dump tile histogram or donor frame was available.
- **UNVERIFIED:** all specific claims of `WHITE-MARKS-PIX-01` itself, because
  that report was not on disk at QA time. If it lands later with a colour
  match based on `test*`/`rock*` palette values, §4 above is the evidence to
  re-score it against.
- **PORT APPROXIMATION only. No donor parity claim.**

---

## 6. Open questions (UNVERIFIED — do not guess)

1. Does `reports/WHITE_MARKS_PIX_01.md` land, and what exact tile ids /
   colour-distance thresholds does it report? Until then its claims cannot be
   scored line by line.
2. What shader/material path paints `(181,234,255)` across the stepped bands?
   The colour equals the frame's top-left pixel and diag `p00`, but the
   source's sky-top and water constants are not this exact cyan; a frame
   with per-region shader isolation is needed.
3. Would a dump histogram of the reproduced frame show `test7/8/9` or
   `rock4/8` tile ids at the marked cells? Colour evidence says they cannot
   explain the dominant pixels, but a direct histogram has not been taken.
4. Are the 422 near-white pixels whose nearest block is a summer tile
   genuinely tile-art pixels, or compressed/lit variants of the cyan? Needs a
   rendered-colour model (lighting gain + tone mapping), not just ΔE.
5. Do the pale *tan* outlines (non-near-white, e.g. `min(R,G,B) ≤ 180`) match
   `rock4`/`sandsea` art? This QA deliberately scored only the published
   near-white population.
6. Would a flag-off capture with the same seed/camera change the near-white
   count or hue? UNVERIFIED — no second successful capture exists.
7. Donor parity of hue, grain, relief silhouette or luma remains blocked: no
   donor GPU A/B frame exists.

---

## 7. Summary

Independent read-only QA of the white-marks tile-id attribution. The target
`WHITE-MARKS-PIX-01` report is **not landed** (board: RUNNING), so its own
claims are UNVERIFIED; I cross-checked the published attribution chain
instead. Re-reading `relief_on.png.raw.png` with Pillow 12.1.1 reproduces every
cited statistic exactly (44,381 near-white px = 4.8156 %, bbox frame-wide,
Rec.709 luma 0.0/253.845/115.039, 122,932 px > 180), with the known "4×3"
label defect that is really a 4×4 grid. A new CIELAB ΔE76 match against all
112 `blocks/*.png`, run alongside plain RGB, shows that **89.16 %** of those
near-white pixels are two cyan colours with **zero** exact occurrences in any
block; 97.28 % land nearest `winter0.png` at a poor ΔE76 ≈ 17, only 0.95 %
nearest any summer/test/rock/grass/sand block, and 7 px nearest `rock4`.
The quoted `test8`/`rock4` bright colours have zero occurrences in the frame
(and the "rock4 max" is a per-channel maximum, not an actual pixel colour).
**Verdict: pixel numbers CONFIRMED; tile-id-colour attribution REFUTED for the
dominant near-white pixels; mechanism for the remainder and the target report's
specific claims UNVERIFIED; no donor parity claim.** One file written; no code,
asset, config, PNG, job or queue change.

---

*End of QA WHITE PIX 02. Read-only; PORT APPROXIMATION; no donor parity claim.*
