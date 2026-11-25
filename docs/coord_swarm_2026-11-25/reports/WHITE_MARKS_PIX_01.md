---
id: WHITE-MARKS-PIX-01
title: "Pixel/tile analysis of the reproduced white marks — dominant cyan is the rendered sky showing through grid-stepped transparency, not donor tile albedo"
agent: "WHITE-MARKS-PIX-01 (image/pixel analyst subagent), coord swarm 2026-11-25"
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB
scope: "One new file only: this report. No source/asset/config/shader/fixture/git edit, no Godot runner job, no queue mutation. All measurement scripts and crops were written under %LOCALAPPDATA%\\Temp\\opencode\\whitemarks\\ only."
exclusive_output: "docs/coord_swarm_2026-11-25/reports/WHITE_MARKS_PIX_01.md"
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
image: "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\reliefvisual\\relief_on.png.raw.png (2,450,951 B, 1280x720, ticket 532 raw GPU sidecar)"
dump: "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\reliefenabl01_dump.json (54,137 B; seed 20261113, 64x64, ticket 527)"
labels: [observed, derived, inferred, UNVERIFIED]
parity_guard: "PORT APPROXIMATION — internal consistency only. No donor GPU A/B frame exists. No donor parity is claimed anywhere in this report. Donor bytes were read only through prior decoded reports; no donor binary was run or copied."
verdict: "PUBLISHED PIXEL NUMBERS CONFIRMED; TILE-ALBEDO ATTRIBUTION REFUTED FOR 89.16% OF NEAR-WHITE PIXELS. Dominant colour (181,234,255)/(182,233,255) is the rendered sky clear-colour, present frame-wide in 11,738 isolated connected components; alpha-mask transparency on grid-stepped transition cells is the best-supported mechanism (INFERRED, not donor-proven). Water shader and tile albedo cannot produce that exact cyan; relief stamps are empty for this seed. No parity claim."
---

# WHITE MARKS PIX 01 — image/pixel identification of the pale stepped bands

## 0. Mandate and boundary

Identify the terrain feature that produces the pale, stepped, grid-aligned bands in
the **real generated 64² map** captured by `RELIEF_VISUAL_01.md` (ticket 532,
seed 20261113). Everything below is labelled **observed** (literal artifact
bytes, source line, or direct image read), **derived** (arithmetic/control-flow
consequence), **inferred** (attribution without a pixel-aligned donor A/B) or
**UNVERIFIED**. The correlated `QA_WHITE_PIX_02.md` cross-check arrived during
this analysis; its refutation of the tile-albedo attribution is adopted here and
was independently reproduced from the same PNG before its arrival (§3, §4).
Nothing was edited in the repo; no runner job was submitted; no donor frame was
read; **no donor parity claim** is made.

Sources read: the raw PNG; `reports/RELIEF_VISUAL_01.md`, `TERRAIN_MARKS_01.md`,
`DPATTERN_01_relief_grids.md`, `RELIEF_ENABLE_01.md`, `QA_RELIEF_DUMP_01.md`,
`QA_WHITE_MARKS_01.md`, `QA_WHITE_PIX_02.md`; `variant3d/scripts/world3d_terrain.gd`
(`:140-157`, `:590-644`, `:660-711`), `variant3d/shaders/terrain_tileindex.gdshader`
(`:326-376`, `:386-470`), `variant3d/scripts/water3d.gd:74-89`;
`variant3d/assets/terrain/structs/presets_summer.json`,
`variant3d/assets/terrain/atlas/alpha.png`,
`variant3d/assets/terrain/blocks/*.png` (112 files, read only); the temp dump
`reliefenabl01_dump.json` and the capture stdout quoted in `RELIEF_VISUAL_01.md:104-106`.

---

## 1. Image observations (direct `read` of the raw PNG)

- 1280×720, full-frame content. A cyan sky strip occupies y≈0–13; the ground is
  olive/yellow-green with fine grain. No rounded elevation silhouette, ridge,
  slope shading or self-shadowing is visible anywhere — the ground reads flat.
- **The pale bands are present and stepped.** Bright light-cyan/near-white bands
  with concentric/nested outlines cover:
  - top-left ≈x0–440, y0–330 (dense stepped maze);
  - right half ≈x700–1280, y0–500, with the largest concentric patch
    ≈x1000–1280, y≈198–376 and an isolated pale ring ≈x1080–1180, y≈279–310;
  - bottom-left ≈x180–470, y≈540–720; bottom-right ≈x820–1280, y≈480–720.
- Zoomed crops (`crop_right.png`, `crop_band_edge.png`, written to temp only)
  resolve the structure: the bands are **nested, tile-grid-sized steps** running
  around water patches and around map/terrain boundaries, with tan/grey striped
  interiors between cyan lines; the stripes are much finer than a whole tile and
  repeat at a fixed phase. They do **not** look like lit cliff geometry.
- Olive areas between bands remain: centre-left ≈x0–700, y≈300–540; conifer
  cluster ≈x450–670, y≈140–280; buildings ≈x830–1100, y≈0–170.
- Critical colour observation: the bright bands are **light blue-cyan**, the same
  hue as the sky strip. Pixel sampling at (1100,250) = `(176,224,243)` and
  (1000,470) = `(181,234,255)`; the sky strip at (5,5)/(640,4) is
  `(181,234,255)`; the frame corner (0,0) is `(182,233,255)`. The top-left corner
  is exactly the `p00=(0.7137,0.9137,1.0)` value that defeated the old
  blank-detector (`RELIEF_VISUAL_01.md:105,111-123`).

---

## 2. Pixel statistics (observed; inline Pillow/numpy, read-only)

Definitions: **strict near-white** = `min(R,G,B) > 180` (the metric published in
`RELIEF_VISUAL_01.md:162-166`); **Rec.709 luma** = `0.2126R+0.7152G+0.0722B`
(the `smallmap_capture.py` formula); Rec.601 luma = `0.299R+0.587G+0.114B` is
shown for transparency against the earlier report.

| Metric | Value | Status |
|---|---:|---|
| Strict near-white pixels | **44,381** = **4.8156 %** of 921,600 | CONFIRMED (own read + `QA_WHITE_PIX_02.md:94`) |
| Strict near-white bbox | **(0,0)–(1279,719)**, frame-wide | CONFIRMED |
| Rec.709 luma min / max / mean | **0.0 / 253.845 / 115.039** | CONFIRMED (`QA_WHITE_PIX_02.md:95`) |
| Pixels with Rec.709 luma > 180 | **122,932** | CONFIRMED |
| Rec.601 luma min / max / mean; >180 count | 0.0 / 253.176 / 112.638; **119,879** | derived, own read |
| Pixels with all channels > 150 | **138,712** = 15.05 % | observed, own read |
| 16-cell spatial grid, strict near-white (row-major) | `[6390,4039,3787,3797] / [1753,1162,2216,4051] / [47,0,2995,2289] / [3650,2967,1770,3468]` | CONFIRMED; **label is 4×4, not 4×3** (`QA_WHITE_PIX_02.md:96`) |
| Exact cyan `(181,234,255)` | **21,750** px | observed |
| Exact cyan `(182,233,255)` | **17,819** px | observed |
| Those two colours combined | **39,569 px = 89.16 %** of strict near-white | observed; matches `QA_WHITE_PIX_02.md:98` |
| Sky strip y<12 containing those two colours | **6,825 of 15,360** px | observed |
| Connected components of the exact-cyan mask (4-neighbour) | **11,740**; **2** touch y=0; **11,738** are isolated below the sky | observed, own BFS |
| Largest isolated cyan component | 1,309 px at bbox (0,570)–(43,617); others 862 px (285,599)–(347,651), 532 px (1138,281)–(1181,308) … | observed |
| Strict near-white remainder (not the two cyan colours) | **4,812 px**; dominant buckets `(176,232,248)`×2,357, `(176,224,240)`×851, `(176,224,248)`×619, `(176,224,232)`×237 | observed |
| Frame-wide channel maxima | R 255 / G 255 / B 255 | observed |

**Derived significance of the component counts.** Only two cyan components are
the sky strip itself; 11,738 separate, isolated cyan patches are scattered
through the banded terrain. This is the signature of **background showing
through many small gaps**, not of one contiguous water body or of a large
sky-coloured surface. The reference olive ground rectangle x400–650/y300–540
has mean RGB `(97.3,100.2,34.4)` (own read), i.e. the normal land albedo is dark
olive, not pale.

---

## 3. Colour-match table — near-white palette vs 112 terrain blocks

Methods: exact RGB occurrence counts in the frame and in every PNG under
`variant3d/assets/terrain/blocks/`; per-pixel CIELAB ΔE76 (D65) nearest-block
tally taken from `QA_WHITE_PIX_02.md:121-138` and independently checked here by
exact colour counts and by the block means computed with Pillow.

| Probe / population | Frame count | Nearest block(s), ΔE76 | Exact occurrence in any block? | Verdict |
|---|---:|---|---|---|
| `(181,234,255)` | 21,750 | `winter*` family, poor ΔE ≈10–17 | **0 in all 112 blocks** | NOT tile albedo; equals rendered sky pixel |
| `(182,233,255)` | 17,819 | same | **0 in all 112 blocks** | NOT tile albedo; equals frame corner `p00` |
| All strict near-white pixels | 44,381 | 97.28 % nearest `winter0.png` (mean ΔE 17.07); only **0.95 %** nearest any summer/test/rock/grass/sand/desert; **7 px** nearest `rock4` | — | Dominant cyan matches **no** terrain block |
| `(222,231,148)` quoted as `test8.png` bright colour in `TERRAIN_MARKS_01.md:100` | **0** | nearest `test8.png` ΔE 2.98 (colour association valid) | 0 in frame | block association CONFIRMED, frame link REFUTED |
| `(255,239,189)` quoted as `rock4.png` max in `TERRAIN_MARKS_01.md:100` | **0** | nearest `winter17.png` ΔE 0.0; `rock4.png` ΔE 6.28 | 0 in `rock4.png` (per-channel max, not a pixel); 0 in frame | label defect; attribution REFUTED |
| `rock4.png` mean / max | — | mean `(70.8,61.5,49.9)`, per-channel max `(255,239,189)` | — | olive/red, opposite hue to the cyan marks |
| `test8.png` mean / max | — | mean `(73.0,77.9,27.9)`, per-channel max `(222,231,148)` | — | olive/yellow, B ≪ R,G |
| Remainder 4,812 near-white px | 4,812 | slightly darker cyan `(176,232,248)` etc. | no exact block match tested | consistent with **partial** sky/tile blend; tile albedo INFERRED/UNVERIFIED only here |

Source constants are also inconsistent with a direct water/tile cyan:
`world3d_terrain.gd:146-147` gives `DONOR_SKY_HORIZON=(0.6,0.776,0.992)` and
`DONOR_SKY_TOP=(0.0,0.141,0.808)`; `water3d.gd:80-81,87` gives
`SHALLOW=(0.1,0.24,0.24)`, `DEEP=(0.0,0.025,0.05)`, `FOG=(0.235,0.392,0.588)`.
None is the exact rendered cyan `(181,234,255)`; the rendered sky strip *is*.

---

## 4. Correlated tileblock dump (seed 20261113) — EXISTS, correlation PARTIAL

The task's precondition is met: `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\reliefenabl01_dump.json`
(54,137 B, ticket 527) is a real dump of the **same seed 20261113 and same 64²
fixture** used by the capture (`RELIEF_VISUAL_01.md:83-85`;
`small_map_64.json:10-15`). It was read only.

- Schema: `['blocked','clusters','height','map_h','map_w','meta','relief_stamps','res','seed','starts','terrain','tileblock']`;
  `seed=20261113`, 64×64. `tileblock` and `height` are base64 strings; decoding
  `tileblock` yields exactly 4,096 bytes (tile ids, 0-based index into
  `presets_summer.json`), `height` yields 4,096 little-endian float32.
- **`relief_stamps = []`** (key present, array empty), confirming the capture
  cannot be showing donor-grid relief (`RELIEF_ENABLE_01.md:124-149`).
- Decoded height grid is *not* flat: min −1.1, max +2.964, mean 0.205 m,
  percentiles `[−1.1,−0.885,0,0,0.216,1.973,2.964]` — the port's own analytic
  relief is present; no donor stamp fired.
- Tile histogram (count, id → name): `1086× grass1`, `500× id255 (water sentinel)`,
  `398× ground1`, `181× test12`, `164× test8`, `160× test14`, `158× rock9`,
  `154× test13`, `129× rock4`, `127× grass7`, `113× rock7`, `110× test2`,
  `99× grass_ground1`, `76× rock8`, `71× test7`, `64× rock5`, `58× sandsea6`,
  plus smaller `rock1/2/3/6`, `sandrock1-4`, `sandsea1/5`, `test1/3/6/9`,
  `grass2/5/8/9`, `grass_ground3`. **No `alpha0*` tile id occurs.**
- Grid positions: an ASCII raster of the dump shows `test*`/`rock*`/`sand*`
  ids forming **rings around the central water body** (≈grid x20–50, y12–42)
  and along terrain boundaries, with `grass1` in the open interior. The
  screenshot's nested bands likewise surround water patches and boundaries —
  a **qualitative spatial correlation** of transition-id rings with band rings.
- **Exact cell-by-cell screen↔grid correlation is UNVERIFIED.** The capture is a
  steep oblique perspective view (camera `(21.98215,58.0,70.25505)`, sim target
  `(85.98215,41.43565)`, `fov≈17.27°` per `camera3d.gd:88,175-195`), showing
  only part of the 64² map; no per-cell projection ground truth was published.
  No numerical pixel-to-tile-id correlation coefficient is claimed.
- Exact reproduction command for this dump (read-only; owner-only if repeated),
  from `RELIEF_ENABLE_01.md:117-118`:

```bat
python variant3d\tools\godot_runner.py run --id <unique-id> --timeout 300 -- ^
  --headless --path variant3d -- --config "C:/Users/Maxym.Oboyshev/Documents/Craft Anything/cossacks-3-3/variant3d/tests/fixtures/small_map_64.json" ^
  --dump-map "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/<unique>_dump.json"
```

The 320² unbounded form at `QA_RELIEF_DUMP_01.md:89` needed >180 s and was
killed; the 64² fixture form completed in 20.58 s (ticket 527).

---

## 5. Hypothesis ranking (evidence-led)

| Rank | Hypothesis | Evidence | Status for the dominant bands |
|---:|---|---|---|
| **1** | **(a) Sky/background showing through transparent gaps, produced by (b) donor alpha-mask sampling on grid-stepped transition cells.** | `terrain_tileindex.gdshader:363-376` deterministically maps each tile id to one 8×4 `alpha.png` patch; world3d_terrain.gd:626-630 repacks the donor grayscale intensity into `.a`; `:469` writes `ALPHA=mix(1.0,a,mask_to_alpha)` with `mask_to_alpha=1.0` default (`:235`), and `:702-710` explicitly notes the semi-transparent ground lets the brighter port sky through. Read-only patch decode: `(0,0)=255` opaque, `(3,3)`/`(7,3)=0` full cut, many patches 45–60 % of texels with intensity <8. Decoded tile ids then pick those patches: `grass1→(0,0)` opaque; `test7→(1,0)` mean α 56.5 (55.8 % <8); `rock4→(0,5)` mean 77.7 (47.8 % <8); `rock8→(0,6)` mean 72.7 (48.7 % <8); `ground1→(2,2)` mean 134.2 (22.1 % <8). Own blend model (`α·tile_albedo+(1−α)·sky`) predicts weakly-to-strongly cyan pixels on exactly those ids, e.g. `test7` 74.0 %, `rock8` 66.2 %, `test8` 0 % because it maps to the opaque patch. Measured frame: 89.16 % of strict near-white px are the exact sky colour, in 11,738 isolated components. | **OBSERVED** that the cyan equals the rendered sky and is isolated-gap shaped; **INFERRED** (high confidence, PORT APPROXIMATION) that the port's tile-id→alpha-patch rule opens those gaps on stepped transition cells. Exact donor tile→patch rule is UNVERIFIED (`shader:343-362`), and no flag-off A/B exists, so the causal link is not promoted to CONFIRMED. |
| **2** | **(c) Water shader / water surface colour.** | `water3d.gd:80-81,87` (`SHALLOW`, `DEEP`, `FOG`) and `water_overlay.gdshader:276` (`alpha=coverage*coastfade2`) cannot by themselves emit the exact `(181,234,255)`; the dump has 500 water cells, but the cyan forms 11,738 tiny isolated components, not one contiguous water body. Water could only contribute if its plane is transparent and reveals the same sky, or via foam/reflection, neither demonstrated. | **LOW / largely REFUTED** as the source of the dominant cyan; transparency-through-water variant **UNVERIFIED**. |
| **3** | **Transition-tile albedo (`test*`/`rock*`) from the donor BMP detail pass.** | The dump proves those ids exist on this map and form rings around water; but 89.16 % of near-white pixels are a cyan that occurs **zero** times in all 112 blocks, ΔE76 33.6–53 from `rock4`/`test8`/`sandsea1`; only 0.95 % nearest a summer block, 7 px nearest `rock4`; the quoted bright `test8`/`rock4` colours have 0 occurrences in the frame. | **REFUTED for the dominant pixels**; mechanism for the 4,812 px remainder is **INFERRED / UNVERIFIED**. |
| **4** | **Height-gated cliff/rock art (`rock4`/`rock8`) creates the steps.** | `game.gd:1937-1970` gates `rock8/rock4` on `abs(h)>2.7/2.4`; dump heights do reach +2.964 and `rock4/rock8/rock9` are present, so these ids can occur. But their albedo is olive/brown, cannot produce cyan, and the bands' colour is dominated by sky. Height can explain *where* steps are, not their pale colour. | **PARTIAL**: geometry/step placement plausible, colour mechanism **REFUTED**. |
| **5** | **Relief stamps (`plt2`) produce the pale marks.** | `relief_stamps=[]` in the same-seed dump; the stamp writes `height[]` only (`world3d_terrain.gd:461-509`), not colour; `RELIEF_VISUAL_01.md:236-243` and `QA_RELIEF_DUMP_01.md:138-146` already record no donor-grid relief. | **REFUTED for this frame**. |

No synthetic-noise proposal is made; donor truth only. No parity claim.

---

## 6. Discriminating dump / capture (proposed only — NOT run)

1. **Alpha-path isolation at fixed camera.** Two captures of the same seed/fixture
   with `features.terrain.relief_stamps` unchanged and a temporary config
   overriding only `terrain_tileindex.gdshader`'s `mask_to_alpha` to `0` versus
   its shipped `1.0`. Prediction if rank 1 is right: the exact cyan count
   (39,569 px) collapses toward zero and the stepped bands become dark olive
   tile art at identical geometry. Requires an owner with shader/config and
   runner permission; **not submitted here**.
2. **Per-tile-id colour isolation.** Using the existing dump, build a terrain-only
   capture whose tile stream is replaced by (i) all `grass1` (id 0 → opaque
   patch) and (ii) the real dump. Prediction: (i) has ~0 strict near-white px,
   (ii) reproduces the rings. This separates alpha-patch from tile-albedo causes
   without changing lighting or camera.
3. **Water-plane A/B.** Hide the water plane with the same camera (`water3d.gd`
   is separately owned). If the cyan persists on the non-water stepped bands,
   hypothesis 2 is refuted; if it vanishes only over water cells, hypothesis 2
   is promoted. No such capture exists.
4. **Exact grid correlation.** Publish a fixed-camera top-down (or orthographic)
   terrain-only capture plus the dump, so each of the 4,096 cell centres can be
   sampled and a Pearson correlation computed between per-cell near-white
   fraction and per-cell predicted alpha. The oblique ticket-532 frame cannot
   support that coefficient without a projection ground truth.
5. **Flag-off dump/capture A/B** with the same seed/camera remains open
   (`RELIEF_VISUAL_01.md:252-253`); it tests relief, not the alpha path, and is
   the least discriminating of the five for this specific symptom.

---

## 7. Open questions (UNVERIFIED — do not guess)

1. What is the exact donor tile-pair → alpha-patch rule? The port's arithmetic
   decomposition is explicitly a PORT APPROXIMATION (`shader:343-362`); no donor
   enum was readable.
2. Which of the 11,738 isolated cyan components are alpha gaps on steep cells
   versus alpha gaps on shoreline cells? Needs the per-cell capture of §6.4.
3. Do the 4,812 near-white remainder pixels come from partial alpha blend,
   anti-aliasing/tone mapping, or a genuinely bright tile? No rendered-colour
   model (lighting gain, exposure 1.45, tone map) was fitted.
4. Do the pale *tan* outlines with `min(R,G,B) ≤ 180` match `rock4`/`sandsea`
   art? This report scored only the published strict near-white population, as
   did `QA_WHITE_PIX_02.md`.
5. Does the water plane contribute any of the cyan over the 500 water cells,
   or is it fully transparent there too? No water-isolation capture exists.
6. Would a flag-off capture change the near-white count or hue? UNVERIFIED; no
   second successful capture exists.
7. Donor parity of hue, grain, relief silhouette and luma remains blocked:
   no donor GPU A/B frame exists.

---

## 8. Summary

The raw 1280×720 GPU frame from ticket 532 reproduces the published numbers
exactly: **44,381** strict near-white pixels (**4.8156 %**, bbox frame-wide),
Rec.709 luma **0.0 / 253.845 / 115.039**, **122,932** pixels above luma 180, and
the 16-cell count grid (properly labelled **4×4**, not 4×3). Direct inspection
shows flat olive ground with pale, stepped, concentric grid-aligned bands and
no visible hills. The dominant bright colour is not pale tile art: **89.16 %**
of those pixels are exactly `(181,234,255)`/`(182,233,255)`, the rendered sky
colour, with **zero** occurrences in all 112 `blocks/*.png` and poor CIELAB
matches (97.28 % nearest `winter0` at ΔE≈17; 0.95 % any summer block; 7 px
`rock4`). Those cyan pixels form **11,738 isolated components** below the sky
strip — the signature of background showing through many small gaps.

A real same-seed tileblock dump exists and was decoded: `relief_stamps=[]`,
non-flat port heights, and tile ids whose `test*`/`rock*`/`sand*` values form
rings around the central water body, matching the screenshot's band geometry.
The read-only port code supplies a concrete mechanism: the terrain shader maps
tile ids to donor alpha-atlas patches and writes that mask to framebuffer alpha;
`grass1` maps to the fully opaque patch while `test7`/`rock4`/`rock8`/`ground1`
map to patches with 22–56 % near-zero texels, so stepped transition cells become
semi-transparent and blend with the bright sky. Ranking: **(1) sky through
alpha-mask gaps on stepped transition cells** (observation CONFIRMED, mechanism
INFERRED); (2) water shader LOW/UNVERIFIED; (3) transition-tile albedo REFUTED
for the dominant pixels, UNVERIFIED for the small remainder; (4) height-gated
rock explains step placement, not cyan colour; (5) relief stamps REFUTED for this
seed. Discriminating tests are specified in §6 but were not run. **PORT
APPROXIMATION only; no donor parity claim.** No code, asset, config, queue or
git state was changed; this report is the sole repo write.

---

*End of WHITE MARKS PIX 01. Read-only on repo; no runner job; no donor access; no ladder advancement; no donor parity claim.*
