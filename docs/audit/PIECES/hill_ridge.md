# PIECE: `hill_ridge` — visual truth + build recipe

**Lane:** T2-PIECE-HILL-RIDGE (research only).
**Date:** 2026-11-21.
**Method:** donor bytes read in place; reference JPEGs cropped with Pillow 12.1.1 into
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\` **only**; no donor file copied, no
Godot process run, no repo code or asset edited. This document is the only repo file written.

**Labels:** `observed` = read/measured here with citation; `derived` = computed from
observed numbers; `inferred` = best interpretation with caveat; `UNVERIFIED` = not
confirmed (no render was made).

Paths: project `C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3`;
donor `C:\Games\Cossacks 3` (private-use reference only);
reference images `C:\Users\Maxym.Oboyshev\Downloads\c3\`.

---

## 1. Donor shape and palette evidence (with crop boxes)

### 1.1 Hill-pattern geometry — the donor ridge is a long N–S strip, not a dome

`observed` — header `int32 w,h` + `w*h` occupancy bytes decoded exactly as in
`docs/audit/TERRAIN_DONOR_PATTERNS.md:67-85`; cell extents cross-checked against
`app/assets/terrain/patterns/donor_patterns.json` (`g_hil1` cells 725, x[-16,15], y[-28,25]).
`aspect` = occupied-bbox long/short; `eig_aspect` = sqrt(λ1/λ2) of the occupied-cell
covariance (a shape measure independent of axis alignment). "Mask crop box" is the
donor-cell bbox `(x0,y0,x1,y1)` of occupied cells — the pattern equivalent of a crop.

| Pattern | w×h cells | mask occ | occupied bbox | aspect | eig_aspect | long | mask crop box | qualifies >1.4 |
|---|---:|---:|---:|---:|---:|:--:|---|---|
| `g_hil1` | 32×56 | 725/1792 (0.405) | 32×54 | **1.69** | 2.22 | Y | (-16,-28,15,25) | **YES — chosen** |
| `g_hil2` | 30×57 | 549/1710 (0.321) | 30×55 | 1.83 | 2.73 | Y | (-15,-28,14,26) | YES |
| `g_hil3` | 46×56 | 1001/2576 (0.389) | 46×56 | 1.22 | 1.58 | Y | (-23,-28,22,27) | no (compact) |
| `g_hil4` | 33×59 | 759/1947 (0.390) | 33×59 | 1.79 | 2.14 | Y | (-16,-29,16,29) | YES |
| `g_hil5` | 30×48 | 582/1440 (0.404) | 30×48 | 1.60 | 2.17 | Y | (-15,-24,14,23) | YES |
| `g_hil6` | 33×50 | 526/1650 (0.319) | 33×48 | 1.45 | 1.96 | Y | (-16,-24,16,23) | YES (weak) |
| `g_hil7` | 31×52 | 521/1612 (0.323) | 31×52 | 1.68 | 2.41 | Y | (-15,-26,15,25) | YES |
| `g_hil8` | 36×45 | 632/1620 (0.390) | 36×45 | 1.25 | 1.37 | Y | (-18,-22,17,22) | no |
| `g_hil9` | 30×54 | 731/1620 (0.451) | 30×54 | 1.80 | 2.17 | Y | (-15,-27,14,26) | YES |
| `hil1` | 25×41 | 305/1025 (0.298) | 25×40 | 1.60 | 2.34 | Y | (-12,-20,12,19) | YES |
| `hil2` | 36×42 | 585/1512 (0.387) | 36×40 | 1.11 | 1.28 | Y | (-18,-20,17,19) | no (round) |
| `hil3` | 29×44 | 491/1276 (0.385) | 29×43 | 1.48 | 1.71 | Y | (-14,-22,14,20) | YES (weak) |
| `hil4` | 26×45 | 293/1170 (0.250) | 26×44 | 1.69 | 2.11 | Y | (-13,-22,12,21) | YES |
| `big_hill_1` | 51×56 | 1153/2856 (0.404) | 51×56 | 1.10 | 1.30 | Y | (-25,-28,25,27) | no — square decor mass |

`derived`: median light-hill aspect **1.68**, dark-hill **1.54**; **10 of 13** hill
patterns exceed 1.4 and every one of those has its long axis vertical (Y / N–S).
Therefore "donor aspect >1.4" is true **for the ridge subset only** — `g_hil3`,
`g_hil8`, `hil2` and the big decor hill are compact/round and must not be used as the
ridge archetype. `g_hil1` is the best match to the prior §4 brief (32×56, 725 occupied,
elongated N–S) and is the donor mask used below.

`observed` — `generator.cfg:693-753`: families `hills_dark` = `hil1..4`, `hills_light`
= `g_hil1..9`, all `Freq = 1`; `big_hill_1` sits in `decor_big` (`generator.cfg:449,775`).
`observed` — `generatemap.inc:4-6` fixes the donor height codes `cPlateauHeight=2.964`,
`cHillHeight=cPlateauHeight/2.25=1.317`, `cRavineHeight=-2.964`;
`:569-574` applies them from the mask's R-channel **terrain code**, so the pattern mask
describes the footprint/objects while the height code describes the relief. The port's
"stamp the footprint with height" is a **port adaptation** (`inferred` donor equivalence).

### 1.2 Reference-image crops — grass cap vs striated rocky flank

All crops written to temp with Pillow; boxes are **source-image pixels**; means are
Pillow `ImageStat.Stat` over the stated box; HSV from `colorsys` on the mean RGB.
`L` = 0.2126R + 0.7152G + 0.0722B (`derived`).

| Crop (temp PNG) | Source + source box | Zoom | Mean RGB | HSV | `L` | Reads as |
|---|---|---:|---|---|---:|---|
| `hr_articolo_mound1.png` | `articolo-787.jpg` (560,110,760,230) | 3× (600×360) | (78.7,76.3,52.4) | — | ~75 | elongated grassy mound, dark striated flank |
| — grass top sub-box | (655,110,755,132) | — | (66.6,65.7,49.7) | (57°,0.25,0.26) | **64.7** | sunlit olive cap |
| — rock face sub-box | (585,122,655,160) | — | (50.8,47.6,30.4) | (51°,0.40,0.20) | **47.0** | shadowed brown-grey striated wall |
| `hr_articolo_mound2.png` | `articolo-787.jpg` (300,210,470,330) | 3× (510×360) | (66.6,63.6,37.3) | — | ~63 | longer ridge, trees on rim, face 1.5–3× tree height |
| — grass top sub-box | (325,208,425,232) | — | (63.7,58.4,30.9) | (50°,0.52,0.25) | 58.7 | darker olive cap |
| — rock face sub-box | (378,242,455,302) | — | (62.8,59.2,40.8) | (50°,0.35,0.25) | 59.2 | face similar in mean, contrast is **texture/striation**, not tone |
| open plain control | `articolo-787.jpg` (120,320,240,420) | — | (78.4,75.7,39.8) | (56°,0.49,0.31) | 73.7 | brighter, uniform grass |
| `hr_images_hills_bg.png` | `images.jpg` (0,20,588,100) | 3× (1764×240) | (81.9,81.2,53.2) | — | ~80 | hazy distant hill silhouettes behind trees |
| — distant hill band | (250,20,500,60) | — | (97.4,98.7,76.2) | (63°,**0.23**,0.39) | 97.1 | **desaturated** by atmospheric haze |
| — nearer treeline | (250,60,500,95) | — | (83.4,81.8,50.1) | (57°,0.40,0.33) | 81.9 | normal olive; use this palette for a near ridge |
| `hr_highlands_hills.png` | highlands wallpaper (0,300,958,800) | 1× (958×500) | (77.7,72.3,50.4) | — | ~74 | **negative**: town/stone walls, no ridge silhouette |

`derived`: on the clean `articolo-787.jpg` mound the cap→flank luminance ratio is
64.7/47.0 = **1.38**; this agrees with the in-repo palette anchors
(`docs/audit/TERRAIN_REFERENCE_IMAGES.md:38-46`: grass mid `#616727`, grass dark
`#3E411F`, rock lit `#6C614B`, rock shadow `#393424`) and its lit/shadow 1.7–1.9 range
(`:134-135`). The 512 px piece is a **near** view, so target the saturated near palette
(HSV sat ≈0.5), not the hazy 0.23 band of `images.jpg`.

### 1.3 Port block art that must supply the grass/rock read

`observed` — 1024×1024 PNGs downsampled to 64×64 (or 128×128) with Pillow; fractions
are from `R>G+3` (brown/dry-rock scuffs) and an HSV rock test (sat<0.40, B>0.55R).

| Block | Mean RGB | Std | brown `R>G+3` | rock (HSV) | Visual (`observed` from downsample crop) |
|---|---|---:|---:|---:|---|
| `grass1.png` | (76.0,82.5,30.4) | (3.2,3.5,1.5) | 0.00 | 0.000 | uniform olive turf, almost no variation |
| `grass_rock1.png` | (71.7,69.3,33.9) | (5.3,5.8,4.8) | **0.34** | 0.007 | olive turf with brown dry/rock scuffs — the "steeper side" overlay |
| `rock1.png` | (76.9,67.5,53.5) | (20.6,17.8,14.4) | — | **0.996** | dark grey-brown with **vertical striations** — donor face texture |

`derived`: `grass_rock1` carries 34% brown pixels vs 0% in `grass1`, so at the spec's
opacity 0.4 it contributes ≈0.4×0.34 = **13.6% brown coverage of whatever area it
covers**. `inferred`: its scuffs are dry-brown earth, not the grey striated `rock1`;
the spec omits `rock1`, so a faithful striated rock face is **not** in the layer stack
— this is a documented recipe limitation, not a claim of fidelity.

---

## 2. Port state (file:line, read-only)

| # | State | file:line | Detail / number |
|---|---|---|---|
| P1 | **New stamped relief exists** | `app/scripts/game.gd:610-703` `_shape_stamp_relief()` | Iterates `C3PatternGen.build(...).stamps` (called at `game.gd:816-818`), applies height inside each stamp's extent. |
| P2 | Called **before** collision | `game.gd:814-843` | Stamp relief at `:818`; cliff/collision pass at `:822-843` (cardinal `|dh|>0.5`, diagonal `>0.55`). Ordering defect P-47 closed. |
| P3 | Hill profile | `game.gd:640-648` | `amp = RELIEF_HILL`, `edge = 0.80`, `rim_tiles = 8.0` for `kind=="hill"`; `RELIEF_HILL = 2.964/2.25 = 1.317` (`game.gd:55`; donor `generatemap.inc:5`). Plateau/mountain `edge` 0.97/0.78; ravine negative amp (`:650`). |
| P4 | Height formula | `game.gd:653-703` | `ex=max|cell.x|`, `ey=max|cell.y|` (`:656-661`); `hx,hy=max(1,ex/ey)` (`:664-665`); `half_long=max(hx,hy)`, `half_short=min(hx,hy)`; `rim = 8.0/half_short` (`:668`); `d = sqrt((dx/hx)^2+(dy/hy)^2)`; skip `d>1`; `f = clamp((0.80-d)/rim, 0, 1)`; `height[i] += amp*f` (`:692-703`). **Derived:** flat crest for `d ≤ 0.80-rim`, linear falloff to `d=0.80`. |
| P5 | **Mask occupancy discarded for relief** | `game.gd:653-695` | The loop tests only the **bounding box** (`x0..x1`, `y0..y1` at `:670-675`) and the ellipse `d`; there is **no `st.cells` membership test**. The comment at `:612-613` ("footprints are the real donor masks") holds for placement/collision, **not** for the raised shape: the relief is an analytic ellipse through the bbox extents. `observed`. |
| P6 | Start keep-clear | `game.gd:621-632` | `protect = max(CIRCLE2)*map_scale*1.5 = 15*2*1.5 = 45 tiles` (CIRCLE2 at `pattern_gen.gd:11`); relief inside 45 tiles of any start is skipped (`:677`). |
| P7 | Hill footprints come from donor JSON, scaled | `pattern_gen.gd:89-107` `scale_cells`, `:71` `s = map_w/160 = 2.0` at 320 | `g_hil1` cells x[-16,15] → tiles x[-32,30], y[-56,50]; **63×107 occupied tiles (126×214 m)**; loop bbox 65×113 tiles. |
| P8 | Hill placement | `pattern_gen.gd:34-35, 282-283, 358-366` | families `hills_dark`/`hills_light` → `kind="hill"`; attempted stamps `int(320² × (hil_freq/2))` = **3+3 on default `plains`** (`hil=0.000075`, `:20`), 6+6 on `hills`, 2+2 on `mountains`; actual count ≤ attempted (no-overlap `relief_can_stand` `:313-322`). |
| P9 | Residual round domes | `game.gd:746-765`, `data.gd:134-138,184,187-188` | 4 domes on `high` quality; centres `rng.randf_range(0.2,0.8)·MAP`, radius `rr∈[7,13]` tiles, `(1-dd)²·1.317·scale` paraboloid. Still present; the stamped ridge is now a **second**, elongated relief source. |
| P10 | Hill art paint is still a tiny disc | `game.gd:568-574` `"hill"` branch | Only `if dc <= 2.2: terrain[ii]=5` (dc in tiles) — ≈15 tiles, **not** the ≈2,900-tile scaled donor footprint (725 cells × s²=4). No rock-on-slope painting. |
| P11 | Why flanks stay green | `derived` from P3/P4 + `game.gd:829-840` | crest→base drop 1.317 over `rim` = 8 tiles ⇒ **0.165/tile** on the short axis (0.094/tile on the long axis), well under the 0.5 cliff threshold. The collision pass therefore paints **no** rock on the stamped hill flank; only the P10 disc is rocky. Art overlay is required. |
| P12 | Materials available | `app/assets/terrain/blocks/grass1.png`, `grass_rock1.png`; `app/assets/models/sprites/tree_spruce1.png` (12,634 B) | All three spec assets exist read-only; `rock1.png` exists but is **not** in the spec stack. |

---

## 3. Build spec + geometry numbers

### 3.1 Spec (verbatim shape, with `reference` filled from §1)

```json
{"name":"hill_ridge","size_px":[512,512],"seed":7,"layers":[{"type":"block","name":"grass1","tile":true},{"type":"block","name":"grass_rock1","opacity":0.4},{"type":"sprite","name":"tree_spruce1","pos":[0.4,0.5],"scale":1.2}],"reference":{"primary":{"image":"articolo-787.jpg","box":[300,210,470,330],"note":"elongated grass-capped ridge, striated dark flank"},"tonal":{"image":"articolo-787.jpg","grass_box":[655,110,755,132],"rock_box":[585,122,655,160]},"distant":{"image":"images.jpg","box":[250,20,500,60],"note":"hazy desaturated rolling hills"},"donor_mask":{"pattern":"g_hil1.pattern","box_cells":[-16,-28,15,25],"occupied":725,"aspect":1.69}}}
```

### 3.2 Geometry numbers for the 512×512 piece

`derived` from `g_hil1` (§1.1), port scale `s=2` (P7) and profile (P4). Mapping chosen so
the whole ridge fits the piece: **1 donor cell = 2 port tiles = 8 px** (i.e. 1 tile = 4 px).

| Quantity | Value | Derivation |
|---|---:|---|
| Donor mask bbox | 32×54 cells | occupied x[-16,15], y[-28,25] |
| Piece footprint box | **256×432 px** at `[128,40,384,472]` | ×8; margins 128 px L/R, 40 px T/B |
| Footprint aspect | **1.69** (Y/N–S long) | 432/256 |
| Raised-relief region (`d≤0.80`) | **205×346 px**, box `[154,77,358,435]` | radii `0.8·(32,56)` tiles ×4 px |
| Flat crest (`d≤0.55`) | **141×246 px**, box `[186,133,327,379]` | `d≤edge−rim = 0.80−0.25` |
| Flank/rim band (short E–W side) | **8 tiles = 32 px** | `rim_tiles=8` at 4 px/tile |
| Flank/rim band (long N–S end) | **14 tiles = 56 px** | `rim·hy = 0.25·56` tiles |
| Crest amplitude | **+1.317 donor height units** | `cHillHeight`, `game.gd:55` |
| Slope, short / long flank | **0.165 / 0.094 per tile** (= 0.041 / 0.024 per px) | `amp/(rim·hx)`, `amp/(rim·hy)` |
| Collision-rock disc (P10) | radius 2.2 tiles = **8.8 px**, ≈243 px² = **0.09%** of piece | π·(8.8)² / 512² |
| Expected brown-patch coverage from overlay (§1.3) | 0.34×0.4 = **13.6% of masked flank area** | art fraction × opacity |

`inferred` recipe reading: tile `grass1` over the whole 512×512; mask `grass_rock1`
(opacity 0.4) to the **one steep flank band** ~32 px wide on the E or W side (the donor
reference shows rock on one face, not both); place `tree_spruce1` at normalized
(0.4,0.5) — i.e. piece px (205,256), inside the footprint near the W rim, scale 1.2 —
consistent with donor trees clustering on gully/plateau rims
(`TERRAIN_REFERENCE_IMAGES.md:106-108`). `rock1.png` is deliberately **not** used by
the given spec; see claim C8.

---

## 4. Measurable criteria from a rendered PNG

Each can be computed from the 512×512 output with Pillow; none was measured in this
lane because no render was produced (`UNVERIFIED` until a render exists).

| # | Criterion | Metric / how to measure | Target (from §1–§3) |
|---|---|---|---|
| M1 | **Ridge aspect (no dome)** | Threshold the piece into "ridge" vs background (crest+flank via luminance/rock mask); take bbox, `aspect = max(w,h)/min(w,h)`; also PCA eigenvalue ratio of the segmented pixels. | bbox aspect **≥1.4** (expect 1.6–1.8; g_hil1 = 1.69); PCA ratio **≥1.9** (g_hil1 = 2.22); long axis vertical. FAIL if aspect <1.4 or crest is near-circular. |
| M2 | **Elongated flat crest** | Within the ridge bbox, count pixels above the 75th-percentile luminance; bbox aspect of that crest set. | crest aspect **≥1.4**, crest area **30–45%** of ridge bbox (derived crest `141×246 / 256×432 = 31%`). FAIL if crest is a compact blob. |
| M3 | **Tonal gradient cap→flank** | Split ridge into inner crest ellipse and outer flank ring; mean `L` of each; ratio and delta; sample a 1-px profile across the 32 px short-axis band. | `L_crest − L_flank ≥ 12` (8-bit) and ratio **1.25–1.8** (donor mound 1.38); monotonic decrease across ≤32 px; no sign flip. |
| M4 | **Rock fraction on steep side** | Classify pixels with HSV sat<0.4 and B>0.55R (grey-brown) **inside the ridge bbox**; also report whole-piece fraction. | ridge-bbox rock **5–15%**; whole-piece **2–7%**. Reference: donor screenshots ~8–18% terrain rock (`TERRAIN_REFERENCE_IMAGES.md:173`, visual estimate, UNVERIFIED precision). Port stamping alone gives ~0.1–0.2% (P10/P11) → **FAIL without overlay**. |
| M5 | **Rock placement asymmetry** | Centroid of rock-classified pixels relative to ridge centroid; require offset toward one short-axis side. | Offset_x ≥ 0.15×ridge width; rock on one flank, not symmetric on both. |
| M6 | **Palette / saturation** | HSV mean and dominant quantized colors of grass pixels. | hue **45–75°**, sat **0.40–0.55**, near `grass1` (76,82,30) / open plain (78,76,40); exclude hazy sat 0.23 band. |
| M7 | **Striation cue (advisory)** | High-frequency vertical energy on flank crop (image − 5px Gaussian blur). | ≥2× the crest's hi-freq energy; only achievable with `rock1`-like art — spec omits it, so record as an unmet advisory, not a hard FAIL. |
| M8 | **Tree anchor** | Segment `tree_spruce1` dark-conifer pixels; report centroid and height. | centroid near (0.4,0.5)±0.05; height 40–100 px at this scale; crown dark olive `#30331B`–`#656937` (`TERRAIN_REFERENCE_IMAGES.md:52,88`). |

Global gate (from `TERRAIN_REFERENCE_IMAGES.md:182`): mean HSV sat 0.30–0.55, value
0.25–0.45 on terrain pixels.

---

## 5. Claim table

| # | Claim | Evidence | Method | Verdict | Correction / caveat |
|---|---|---|---|---|---|
| C1 | `g_hil1` is an elongated N–S ridge, aspect >1.4 | 32×56 cells, 725 occ, bbox 32×54 → 1.69, eig 2.22 | donor bytes + JSON cross-check | **CONFIRMED** | — |
| C2 | "Donor aspect >1.4" holds for the hill families generally | median light 1.68 / dark 1.54; 10/13 exceed 1.4 | full 13-pattern decode | **PARTIAL** | `g_hil3` 1.22, `g_hil8` 1.25, `hil2` 1.11, `big_hill_1` 1.10 are compact; restrict to ridge subset. |
| C3 | Donor height comes from the pattern stamp | `generatemap.inc:569-574` uses mask R-code (`cRHill`→1.317), not pattern records | donor text read | **CORRECTED** | Pattern mask = footprint/objects; height = mask code. Port stamping height on the footprint is a port adaptation (`inferred`). |
| C4 | Port hills are still round domes | domes remain `game.gd:746-765`, but stamped relief added `:610-703` called at `:818` | code read | **PARTIAL / CHANGED** | Two mechanisms now coexist; the *new* relief is an elongated flat-crested ellipse, not a dome — but it is analytic, not donor-shaped (C5). |
| C5 | Stamped relief uses the real donor mask shape | `game.gd:653-695` uses only `ex/ey` extents + ellipse `d`; no cell-membership test | code read | **REFUTED** | Raised shape is an ellipse through the bbox; donor mask gaps/outline are discarded. Comment at `:612-613` overstates fidelity. |
| C6 | Port hill flanks get rock from collision | slope 1.317/8 tiles = 0.165 < 0.5 threshold (`game.gd:829-840`) | arithmetic of P3/P4 | **REFUTED** | Only the 2.2-tile disc (`game.gd:573-574`) is rock; ≈0.09% of the piece. Rock must come from art. |
| C7 | `grass_rock1` supplies rock patches | 34% brown pixels vs 0% `grass1`; opacity 0.4 → 13.6% brown coverage | Pillow downsample + classifier | **CONFIRMED with caveat** | It is dry-brown scuff art; the grey striated `rock1` (rock frac 0.996) is not in the spec stack. |
| C8 | Reference supports a grass-cap/striated-flank ridge | `articolo-787.jpg` mound crops; cap `L`64.7 vs face `L`47.0 (1.38×) | Pillow crop + mean RGB | **CONFIRMED** | Shape/gradient is clear; exact face area % remains a visual estimate (UNVERIFIED precision, as prior doc :150 notes). |
| C9 | `images.jpg` gives the ridge palette | distant hill band sat 0.23 vs near treeline 0.40 | Pillow HSV | **CORRECTED** | Distant hills are hazed/desaturated; use the near olive palette for a 512 px near-view piece. |
| C10 | Highlands wallpaper shows ridges | crop (0,300,958,800) shows town/stone walls | visual crop | **REFUTED** | Do not use it as ridge silhouette evidence; prior doc :162 already corrected the "highlands = mountains" assumption. |
| C11 | All three spec assets exist | blocks `grass1.png`, `grass_rock1.png`; sprites `tree_spruce1.png` | filesystem listing | **CONFIRMED** | `tree_spruce1` placement at (0.4,0.5) is `inferred` from donor rim-clustering, not rendered here. |
| C12 | No donor copy / no Godot run / no repo edit | all donor reads in place; crops only in temp dir | lane method | **CONFIRMED** | This doc is the sole repo file written; M1–M8 remain `UNVERIFIED` until a render exists. |

---

*End of T2 research section.* No donor binary was copied into the repository; no Godot process was run; no code
or asset was edited. All crop PNGs are in `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\`.

---

## 6. T6-T06 render addendum (micro-worker T6-T06, 2026-11-23)

**Scope.** Append-only. Backup `inbox\backup\hill_ridge.md.bak-T6-T06` (sha256
`dafc7b0306de…`, identical to this file before the append). The single piece was rendered by
the NEW owned file `app/tools/pieces/t6_hill_ridge.py` (headless Python 3.14 / Pillow / NumPy,
seed 7; `terrain_piece_render.py` imported READ-ONLY). No spec JSON, generator, `world.gd`,
`game.gd` or shared tool was edited; no Godot job; no donor binary copied. Full claim table,
hash table and open questions are in `docs/t6/reports/T6-T06.md`.

**Donor truth re-measured (observed/derived).** From `articolo-787.jpg`: mound1 grass cap
`(66.6,65.7,49.7)` L64.7 vs face `(50.8,47.6,30.4)` L47.0 (ratio 1.38); mound2 cap
`(63.7,58.4,30.9)` L57.5 vs face `(62.8,59.2,40.8)` L58.6; open-plain control
`(78.4,75.7,39.8)` L73.7. The donor face is a **low-contrast, curved-striated dark earth
mass**, not a striped diagram. `g_hil1.pattern`: 32×56, 725 occupied (0.405), bbox 32×54 →
aspect 1.688, eig 2.215, long axis Y — independently re-decoded here.

**Render outcome (derived).** `app/shots/pieces/t6_hill_ridge.png` 512×512 RGB, sha256
`73195aebfebf…`; compare sheet `t6_hill_ridge_compare.png`. Geometry: footprint
`[113,41,379,471]` = 266×431 px, aspect **1.62** (headline target ≈1.69). Flank L 59.16 vs
crest L 73.41 → Δ **14.26**, ratio **1.24** (M3 PASS). Grass hue **62.3°**, sat **0.420**
(M6 PASS). Main-tree centroid **(0.399,0.501)**, height **76 px** (M8 PASS) measured by exact
difference against a no-tree render. Global gate sat 0.426 / val 0.319 (PASS). M1/M2-area,
M4, M5 remain FAIL under the legacy thresholds (details in report §3); M7 advisory unmet
(1.69× vs ≥2×).

**Honest visual verdict: FAIL.** Reading the compare sheet, the port side is a clean, smooth
dark loaf with a thin bright rim and six small conifers on uniform grass. The donor shows a
broad, deeply and irregularly striated escarpment with dense clustered trees, dark recesses
and organic grass contact. The piece has contact shadow and no uniform pattern, but its flank
texture is too subtle and its rim too clean to read as an eroded 3D landscape. Metrics do not
override this visual judgement (`SWARM_OPS.md` §7.6 / R-ARCH process rule).

The renderer was iterated from (a) an S-shaped ribbon with straight uniform striations and a
hard outline, through (b) a regular striped panel, to (c) the current rounded loaf with
warped irregular banding, AO collar and cast shadow; each stage was read back from its PNG.
Two consecutive renders are byte-identical.

*End T6-T06 addendum.*
