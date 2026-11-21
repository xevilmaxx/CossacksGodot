# verdict_grass_relief.md — T2-VERIFY-RELIEF, upgraded-renderer re-verdict

Lane: **T2-VERIFY-RELIEF** (+ sixth piece T2-PIECE-WINTER). Date 2026-11-21 (second pass).
Scope: six research specs → six headless renderer runs → Pillow acceptance measurement, **before and
after** the `terrain_piece_render.py` upgrade. **No Godot run. No donor binary copied.
No criterion was weakened to obtain a pass.**

## 0. Method, artifacts, hashes

- Tool: `app/tools/terrain_piece_render.py` (Pillow 12.1.1, Python 3.14.3, numpy 2.4.3).
- Luma = `Image.convert("L")` (ITU-R 601-2); hi-freq = mean |L − GaussianBlur(5)|; 8×32 histograms;
  circular HSV hue over sat>0.12/val>0.1; MEDIANCUT 16-colour palette.
- Probe scripts/crops are **temp-only**: `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\`
  (`t2_metrics.py`, `t2_measure_all.py`, `t2_results.json` = before, `t2_results_after.json` = after,
  `t2v2_harness.py`, `t2v2_exp_*.py`, `t2_tree_diff.py`, no-sprite baselines).
- Winter reference workaround **retained and documented**: `_safe_name`
  (`terrain_piece_render.py:271-275`) rejects spaces in `3173885360_preview_Turkish battle 19 Light
  Infantry rush.jpg`, so a byte copy as `winter_snow_reference.jpg` in a TEMP ref dir was used only for
  the comparison tile via `--reference-dir`; the original filename stays in the spec metadata.
- Tree centroids measured by diffing against regenerated no-sprite baselines.
- Geometry criteria (plateau flat-top %, footprint, amplitude, keep-clear; ravine face slope/height/mouth,
  rim profile, `blocked[]`) remain **UNVERIFIABLE from a PNG**: `face`/`patches` are 2D visual proxies
  with no height channel, no collision, no buildability output (renderer docstring :191-194).

| Spec | PNG + compare tile | sha256 before → after |
|---|---|---|
| `app/tools/piece_specs/grass_plain.json` | `app/shots/pieces/grass_plain.png`, `grass_plain_compare.png` | `8193c2ab4884` → **`75e587b0d436`** |
| `app/tools/piece_specs/grass_mottled.json` | `app/shots/pieces/grass_mottled.png`, `grass_mottled_compare.png` | `cab5e0d2c62a` → **`3fbf82aad62e`** |
| `app/tools/piece_specs/plateau.json` | `app/shots/pieces/plateau.png`, `plateau_compare.png` | `d26810971803` → **`878e6aa92391`** |
| `app/tools/piece_specs/hill_ridge.json` | `app/shots/pieces/hill_ridge.png`, `hill_ridge_compare.png` | `b7e046b9827c` → **`5a58af7e5ef1`** |
| `app/tools/piece_specs/ravine_face.json` | `app/shots/pieces/ravine_face.png`, `ravine_face_compare.png` | `c2f286c5b4ef` → **`09185db828ac`** |
| `app/tools/piece_specs/winter_variant.json` | `app/shots/pieces/winter_variant.png`, `winter_variant_compare.png` | `d0f92eaa3a60` → **`f1f4df81a709`** |

All six also produced `<name>.manifest.json`; all PNGs 512×512 RGB.

### Verdict counts (47 criteria, identical gate set)

| Piece | Before P/F/U/A | After P/F/U/A |
|---|---|---|
| grass_plain | 8 / 2 / 0 / 0 | **10 / 0 / 0 / 0** |
| grass_mottled | 1 / 7 / 0 / 0 | **4 / 4 / 0 / 0** |
| plateau | 0 / 2 / 6 / 0 | **1 / 1 / 6 / 0** |
| hill_ridge | 0 / 6 / 1 / 1 | **2 / 5 / 0 / 1** |
| ravine_face | 0 / 5 / 3 / 0 | **2 / 3 / 3 / 0** |
| winter_variant | 3 / 2 / 0 / 0 | **3 / 2 / 0 / 0** |
| **Total** | **12 / 24 / 10 / 1** | **22 / 15 / 9 / 1** |

(P=PASS, F=FAIL, U=UNVERIFIABLE-from-PNG, A=advisory unmet. All original numeric thresholds preserved.)

---

## 1. `grass_plain` — corrected recipe retained, now fully passing

Mandated `grass6+grass9@0.3` is still rejected (documented L 54.7, fails A1/A2/A10); the corrected
`grass1` base + `grass9@0.3` + sun lift is still used, but the old olive-water-tint proxy was replaced by
the upgraded renderer's real `brightness` field, and two mirror-symmetric masked gain patches populate
the histogram bins. Native rendering restores donor-scale grain.

| # | Target | Before | After | Verdict |
|---|---|---|---|---|
| A1 L mean 78–95 | 86 | 89.36 | **85.82** | **PASS** (was PASS) |
| A2 bins: ≥3 ≥3%; bin2 45–75%; bin3 8–35% | `[1,12,62,22,3,0,0,0]` | `[0,0,91.77,8.23,…]`, 2 bins | `[0,5.67,69.79,24.53,0.01,…]`, 3 bins | **PASS** (was FAIL) |
| A3 L std 8–14 | 10 | 4.86 | **13.50** | **PASS** (was FAIL) |
| A4 hi-freq 3–9 | 5 | 3.80 | **3.83** | **PASS** |
| A5 hue 58–68° | 63° | 65.95° | **66.69°** | **PASS** |
| A6 sat 0.45–0.65; val 0.30–0.40 | 0.55 / 0.35 | 0.600 / 0.384 | **0.611 / 0.369** | **PASS** |
| A7 top-6 all in `#4A501D`–`#767448`; ≥1 in `#5C5E28`–`#767448` | — | 4/6, 1 bright | **6/6, 5 bright** | **PASS** (was FAIL) |
| A8 noise d1 3–7, d5 4–9, d12 5–10 | — | 4.96 / 5.20 / 5.26 | **4.77 / 6.01 / 8.08** | **PASS** |
| A9 tile seam ≤1.5× interior | ≤1.5 | 1.11 | **1.08** | **PASS** |
| A10 dark-base guard L>70 | >70 | 89.36 | **85.82** | **PASS** |

**10/10 PASS.** The A7 bright-tail overflow was removed by damping the light-patch olive weights to
`[0.85,0.82,0.60]`; mirror-symmetric patch grids keep A9 at 1.08 despite the new gain layers.

---

## 2. `grass_mottled` — terrain-driven gain now present

`patches` (terrain-driven ±L olive gain, `patch_px 20–80`, `gain 80`) supplies the mandatory gain driver,
while the three named block layers are unchanged (C7 still 3). Stats on the 200² downsample.

| # | Target | Before | After | Verdict |
|---|---|---|---|---|
| C1 L std 30–40 | 37.55 | 2.73 | **32.40** | **PASS** (was FAIL) |
| C2 ≥4 bins ≥3%, ≥3 in bins 0–3 | — | 2 / 2 | **4 / 3** (`[1.7,48.2,27.7,15.4,6.1,1.0,0,0]`) | **PASS** (was FAIL) |
| C3 hi-freq 8–12 | 11.17 | 1.40 | **15.94** | **FAIL** (overshoot; was 1.40 FAIL) |
| C4 patch 20–80 px; 40² spread ≥15 L | — | 6.57 | spread **27.79**; sub-box p90/p10 **1.295** (<1.7?) | **FAIL** (partly resolved) |
| C5 patch hexes in `#3E411F`–`#6B6732`; sat 0.30–0.55, val 0.25–0.45 | — | 0/25, sat 0.755, val 0.254 | **23/25**, sat **0.523**, val **0.298** | **PASS** (was FAIL) |
| C6 light/dark patch ratio 1.7–2.4 | ~2.2 | 1.059 | **1.295** | **FAIL** |
| C7 exactly 3 block layers | 3 | 3 | **3** | **PASS** |
| C8 histogram L1 ≤25 pp | ≤25 | 114.75 | **47.2** | **FAIL** (improved) |

**4/8 PASS (was 1/8).** Residual C3/C4/C6/C8 are gain-distribution shaping issues inside the new patch
layer (the grid's smoothed extremes overshoot hi-freq while the 40² patch ratio stays ~1.3).

---

## 3. `plateau` — rock face restored; geometry still needs a dump

Two `face` layers (height-field proxy, `rim_px 3`, lit/shadow ramp) are confined to top/bottom bands so
the flat-top crop stays level; a small `patches` gain adds tonal variety.

| # | Target | Before | After | Verdict |
|---|---|---|---|---|
| 1 Flat-top % of land 19–21 | 19–21% | no height channel | no height channel | **UNVERIFIABLE** |
| 2 Flat-top within stamp 55–65% | 55–65% | n/a | n/a | **UNVERIFIABLE** |
| 3 Edge ramp ≤8 tiles / rim ≤3 px | ≤3 px rim | no rim | 2D rim proxy only (no height ramp) | **UNVERIFIABLE** |
| 4 Rock fraction 8–18% (donor visual) | 8–18% | **0.00%** | **8.55%** | **PASS** (was FAIL) |
| 5 Flat top: L std ≤10; ≥4 bins; hi-freq ~3 | 8.1 / 4 / 3 | std 4.22, 2 bins, hf 2.35 | std **6.22** ✓, hf **3.15** ✓, **2 bins** ✗ | **FAIL** (2 of 3 sub-criteria now pass) |
| 6 Amplitude ceiling / stacking >2.964 | ≤2.964 | no height | no height | **UNVERIFIABLE** |
| 7 Footprint scale / anisotropy | 38–93 cells | no height | no height | **UNVERIFIABLE** |
| 8 Start keep-clear | 0 cells | no stamp mask | no stamp mask | **UNVERIFIABLE** |

**1 PASS / 1 FAIL / 6 UNVERIFIABLE** on measurable PNG criteria (was 0/2/6).

---

## 4. `hill_ridge` — ridge shape and rock cap now segmented

A `face` polyline extrusion (N–S zigzag, `rock1` flutes, lit/shadow ramp, 3 px rim) replaces the flat
global blend, and sprite `stretch` replaces `scale 1.2` to meet M8's height band.

| # | Target | Before | After | Verdict |
|---|---|---|---|---|
| M1 bbox aspect ≥1.4, PCA ≥1.9, long axis Y | 1.69 / 2.22 / Y | 1.00 / 1.082 | rock mask **4.60 / 3.56 / Y** | **PASS** (was FAIL) |
| M2 crest aspect ≥1.4; area 30–45% of bbox | — | aspect 1.00 | top-quartile bbox still 1.00 (whole canvas) | **FAIL** |
| M3 L_crest − L_flank ≥12; ratio 1.25–1.8 | Δ≥12 | Δ 5.14 | Δ **−5.51**, ratio 0.908 | **FAIL** (inverted ramp) |
| M4 rock: bbox 5–15%; whole 2–7% | — | whole 0.32% | whole **2.05%** ✓; inside rock bbox ≈11% ✓ | **PASS** (was FAIL) |
| M5 rock centroid offset ≥0.15× ridge width | — | no flank | rock centroid x **0.502** vs ridge centre 0.499 → ~0.015 | **FAIL** (rock symmetric on both sides) |
| M6 hue 45–75°; sat 0.40–0.55 | — | 62.95° / 0.723 | 63.23° / **0.708** | **FAIL** |
| M7 striation cue ≥2× crest (advisory) | ≥2× | 0.99× | flank/crest anisotropy **0.948×** | **UNMET (advisory)** |
| M8 tree centroid (0.4,0.5)±0.05; height 40–100 px | — | (0.401,0.178), 255 px | **(0.399,0.425)** (y off 0.075), height **79 px** ✓ | **FAIL** (height fixed, centroid y still off) |

**2 PASS / 5 FAIL / 1 advisory (was 0/6/1).** M7 is still advisory only; the flutes exist but their
anisotropy is not amplified by the 2D proxy.

---

## 5. `ravine_face` — the visual-height-step proxy is now available

The upgraded `face` layer delivers the documented `rock8` fill + stretched `rock1` flutes, lit/shadow
ramp and hard rim. PNG-unmeasurable geometry criteria stay UNVERIFIABLE.

| # | Target | Before | After | Verdict |
|---|---|---|---|---|
| C1 rock area 8–18% | 8–18% | **0.00%** | **8.67%** (strict), 9.37% (hill classifier) | **PASS** (was FAIL) |
| C2 drift <20%; height 8–12% frame; mouth 30–100 px | — | no face | 2D proxy polyline only | **UNVERIFIABLE** |
| C3 flute anisotropy dx/dy ≥1.3 | ≥1.3 | 0.991 | **1.001** | **FAIL** |
| C4 lit `#6C614B`±10, shadow `#393424`±10; ratio ≥1.5 | ratio ≥1.5 | lit (77,82,24), shad (61,65,17), ratio 1.289 | lit **(91,101,26)**, shad **(32,31,22)**, ratio **2.561** ✓ | **FAIL** (ratio met, hexes not) |
| C5 rim transition ≤3 px, no ramp | ≤3 px | no rim | hard rim proxy present, no height profile to measure | **UNVERIFIABLE** |
| C6 hi-freq 8–14; L std 20–30 | — | 2.92 / 4.77 | **8.44** ✓ / **16.36** ✗ | **FAIL** (hi-freq fixed) |
| C7 ≥3 distinct 128 px rock windows | — | adjacent abs-diff 4.86 | **14.29**, independent seeded crops per face | **PASS** (was FAIL) |
| G `blocked[]` byte-identical | — | no dump | no dump | **UNVERIFIABLE** |

**2 PASS / 3 FAIL / 3 UNVERIFIABLE (was 0/5/3).** The lit/shadow HEX values are recorded in the manifest
but the actual ramp is a luminance gain with olive weights — a renderer-proxy limitation, not a spec typo.

---

## 6. `winter_variant` — exact-white + cool bias now coexist

`glaze` with `white_floor 246` forces bright snow to exact `#FFFFFF` and cool-tints the rest; it is
placed below the conifer sprite. The reference filename workaround is unchanged (§0).

| # | Target | Before | After | Verdict |
|---|---|---|---|---|
| C1 snow area 85–95% | 85–95% | 87.16% | **94.19%** | **PASS** |
| C2 exact `#FFFFFF` ≥25% | ≥25% | 2.27% | **65.94%** | sub-criterion **PASS** |
| C2 ≥3 near-white hexes in top-5 | ≥3 | 0 | **0** (`#ECF0F5`,`#F7F9FC`,`#FDFDFE` are not exact matches) | sub-criterion **FAIL** |
| C2 cool bias ≥80% (§0 test B≥R) | ≥80% | 5.12% (strict) | **100.0% inclusive B≥R**; strict B>R 27.27% | inclusive **PASS**, strict **FAIL** |
| C2 **compound verdict** | all three | FAIL | exact-white ✓, B≥R ✓, near-white ✗, strict-B>R ✗ | **FAIL** (unchanged; thresholds not relaxed) |
| C3 0 bare trees (V1 generated mode); conifer present | — | conifer 11.76%, 0 bare | conifer **3.87%**, centroid **(0.401,0.315)**, 0 bare | **PASS** |
| C4 winter tile wiring (non-PNG) | ≥1 winter block loaded | FAIL (`data.gd:193` only) | unchanged; no `presets_winter.json`, no winter block load | **FAIL** |
| C5 `winter10.png` = donor RGB | 1024² RGB identical | diff bbox `None` | **diff bbox `None`**, means `[0,0,0]` | **PASS** |

**3 PASS / 2 FAIL (unchanged count, but C2's exact-white and B≥R sub-criteria are newly resolved).**
Strict `B>R` on forced-white pixels is arithmetically impossible (B=R=255); the renderer docstring
(:177-178) defines the glaze gate as **B≥R**, which is what the §0 snow test uses. Both numbers are
reported so no reading is hidden.

---

## 7. Former tool limitation — now resolved

1. **No exposure/brightness control** → real `brightness` field on blocks (:75-76, :350-363). Removed the
   olive water-tint proxy; grass_plain A1/A6/A7 now pass at true donor colour.
2. **1024²→512² grain loss** → `native_render` + `final_resample` + `grain_lift` (:54-61, :1229-1242,
   :1291-1296). grass_plain A3 4.86→13.50; ravine C6 hi-freq 2.92→8.44.
3. **Flat global opacity, no masked patches** → `patches` layer (:139-155, :973-1037) with `patch_px
   20–80`, ±`gain`, `olive_weights`, `opacity_mask`. grass_mottled C1/C2/C5 newly pass; grass_plain A2
   populated bins 1 and 3.
4. **No height-step / face geometry** → `face` layer (:157-171, :672-722, :1040-1087) with rock8 fill,
   rock1 flutes, `stretch 2.0`, lit/shadow ramp, hard `rim_px` and per-face seeded crops. Plateau C4
   0%→8.55%; ravine C1 0%→8.67% and C7 newly passes; hill M1/M4 newly pass.
5. **No luminance-masked cool glaze** → `glaze` with `white_floor` (:173-179, :1090-1121). Winter exact
   white 2.27%→65.94% and inclusive cool bias 5.12%→100%.
6. **Sprite scale could not meet the tree-height gate** → `stretch` (:106-110, :810-837). Hill M8 height
   255 px→79 px (within 40–100).
7. **Patch seams broke tileability** → mirror-symmetric explicit patch grids keep grass_plain A9 at 1.08.

## 8. Genuine port/renderer-proxy defects still requiring build work

These are **not** closed by the upgrade; none was converted to a pass.

| # | Residual defect | Target file:line |
|---|---|---|
| 1 | Mottled gain **distribution**: 200² hi-freq 15.94 overshoots 8–12 while patch ratio 1.295 <1.7 and L1 47.2 >25. Needs a terrain-driven driver with calibrated spatial spectrum, not a uniform random grid. | `app/tools/terrain_piece_render.py:973-1037` (patch grid/gain); port driver `app/scripts/world.gd:998-1046` |
| 2 | Ravine flute **anisotropy** 1.001 <1.3 and L std 16.36 <20: `face` flutes are stretched but the final 512² downsample and olive-weight ramp flatten horizontal-gradient energy. | `app/tools/terrain_piece_render.py:697-722`, `:1040-1087` |
| 3 | `face` lit/shadow **palette** is a luminance gain with olive weights, so the mandated hexes (`#6C614B` / `#393424`) are not reproduced even though they appear in the manifest. | `app/tools/terrain_piece_render.py:1040-1062` (ramp) vs `docs/audit/PIECES/ravine_face.md:191-193` |
| 4 | Hill **cap→flank gradient inverted** (ΔL −5.51) and rock symmetric on both flanks (M5); the polyline face is a zigzag, not the donor's one-sided slope. | `app/tools/piece_specs/hill_ridge.json` face `geometry.points`; profile source `app/scripts/game.gd:610-703,640-648` |
| 5 | Hill **saturation** 0.708 >0.55 and tree centroid y 0.425 vs 0.5±0.05 (M6/M8). Spec-vs-criterion reconciliation still open. | `app/tools/piece_specs/hill_ridge.json` layers; criterion `docs/audit/PIECES/hill_ridge.md:176,178` |
| 6 | Plateau flat-top **tonal patches** still 2 bins <4. | `app/tools/piece_specs/plateau.json` `patches` layer; `docs/audit/PIECES/plateau.md:270` |
| 7 | Winter **near-white exact hexes** consumed by `white_floor`; strict `B>R` impossible on forced-white pixels. Need a per-pixel glaze that preserves donor hexes outside the forced-white set. | `app/tools/terrain_piece_render.py:1090-1121`; criterion `docs/audit/PIECES/winter_variant.md:215` |
| 8 | Winter **wiring** unchanged: only a flat tint in the engine, no `presets_winter.json`, no winter block load. | `app/scripts/game.gd:988-998`, `app/scripts/data.gd:191-197`, `app/scripts/world.gd:939-951,1141-1151` |
| 9 | All **geometry/buildability gates** still need a real height/dump verifier: plateau 1,2,3,6,7,8; ravine 2,5,G; hill M1/M2 are only 2D-proxy segmentations. | `app/tools/terrain_piece_render.py:1297-1315` (manifest); new dump-verifier lane; `app/scripts/game.gd:822-843,829-840` (`blocked[]` untouched) |

## 9. Bottom line

- Six specs updated to the upgraded schema and re-rendered deterministically; new hashes in §0.
- **Before 12 PASS / 24 FAIL / 10 UNVERIFIABLE / 1 advisory → After 22 PASS / 15 FAIL / 9 UNVERIFIABLE /
  1 advisory** across the same 47 unweakened criteria. `grass_plain` now passes all 10.
- Every resolved item traces to a new renderer capability (§7); every remaining failure is either a
  gain-distribution/palette-shaping shortfall inside the new proxies or a genuine engine/build defect
  (§8). Geometry criteria were deliberately left UNVERIFIABLE rather than promoted to passes.
- No threshold was relaxed, no Godot process was run, and no donor asset was copied.
