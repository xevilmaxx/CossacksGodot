# TERRAIN_REFERENCE_IMAGES.md — Visual Target Spec (terrain only, units ignored)

Research lane TS-1. Read-only analysis of the 12 donor images in `C:\Users\Maxym.Oboyshev\Downloads\c3\`.
All hex/RGB values below were sampled with Pillow 12.1.1 from lossless PNG crops written to
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\` (never into the repo). Crop coordinates are given in
**source-image pixels** unless the crop-name says `_zoom` (those are 2×/3× upscales of a source box).
Every finding is tagged `observed` (seen directly), `derived` (computed from pixels), or `inferred`
(interpretation). Area estimates are visual and marked UNVERIFIED for precision.

---

## 1. Images inspected

| # | Filename | Dimensions | Terrain content (observed) | Usefulness for terrain target |
|---|----------|-----------|----------------------------|-------------------------------|
| 1 | `3173885360_preview_Turkish battle 19 Light Infantry rush.jpg` | 1920×1080 | Snow-covered ground, bare/snow-laden conifers + leafless trees, exposed gray rocks, dirt patches | MEDIUM — only winter palette & bare-tree morphology; desaturated (HSV sat mean 0.088, derived) |
| 2 | `523480776.jpg` | 720×405 | Rolling green grass, two sharp-edged golden wheat fields, mill on dirt clearing | HIGH — grass/wheat palette, crisp field boundaries |
| 3 | `899956545_preview_20170411195032_1.jpg` | 1366×768 | Mostly flat open green grass with scattered small trees/bushes, HUD overlay | MEDIUM — open-field grass tone only |
| 4 | `Cossacks3AttackingVillage.webp` | 2355×1376 | Village dirt/gravel clearing, green grass strips, golden wheat, conifers + bright broadleaf trees | HIGH — highest resolution; tree species/detail + ground texture |
| 5 | `MADVBuilding1.JPG` | 485×486 | Tan/sandy dirt ground under a building, UI panel | LOW — building-centric; one dirt/sand palette sample only |
| 6 | `articolo-787.jpg` | 960×540 | Broad overview: rolling green plain, winding dark gullies, tree lines, dark river + ship at top edge, smoke | HIGH — overview scale, gully frequency, dark-water shore |
| 7 | `cossacks-3-guardians-of-the-highlands-pc-gioco-steam-wallpaper-3.jpg` | 1916×1080 | High-res forest/town: layered spruce, lime broadleaf, dead trees, tall grass, forest floor, dirt lanes | HIGH — best tree morphology/species reference; NO water in inspected corners |
| 8 | `cossacks-3-v1-498085.jpg` | 1280×720 | Grass plateau cut by a network of near-vertical earthen/rock gullies; conifers + yellow deciduous; watchtower | **PRIMARY** — cleanest ravine morphology + grass/rock/trees in one frame |
| 9 | `hqdefault.jpg` | 480×360 | Town on green rolling hills, black letterbox bars | LOW — low resolution, heavy UI |
| 10 | `images.jpg` | 588×340 | Green grass, scattered broadleaf + conifer trees, hazy rolling hill silhouettes at top | MEDIUM — atmospheric perspective / distant hills |
| 11 | `large_1.webp` | 788×377 | Dense conifer/spruce forest, dark forest floor, troop line | HIGH — conifer color + dense-clustering density |
| 12 | `maxresdefault_1.jpg` | 512×288 | Town on green grass, tan sand patch, pale shallow water at bottom-right, HUD/minimap | MEDIUM — only shallow-water/shore sample (low res) |

---

## 2. Palette table

Saturation of the non-winter images is moderate: HSV sat mean 0.34–0.50, value mean 0.25–0.42 (`derived`,
full-image 64×64 downsample). All colors are olive/green-gold, never neon.

| Role | Hex / RGB (mean of box) | Source image + crop (source px) | Area estimate (visual, UNVERIFIED) |
|------|-------------------------|---------------------------------|------------------------------------|
| Grass — sunlit | `#6B6732` (107,103,50) | #8 `c8_plateau_top.png` box (40,40,180,130) of src `(375,20,440,85)` | 15–25% of grass area |
| Grass — mid | `#616727` (97,103,39) | #8 `c8_ravine_center.png` box (100,380,250,480) of src `(610,340,685,390)` | 40–55% of grass area |
| Grass — mid-alt | `#64642F` (100,100,47) | #8 `c8_ravine_center.png` box (400,690,560,800) | — |
| Grass — dark/shadow | `#3E411F` (62,65,31) | #8 `c8_gully_left.png` box (20,265,80,325) | 10–20% of grass area |
| Grass — distant/open | `#4F5325` (79,83,37) | #2 `c2_wheat_mill.png` box (300,600,600,760) | — |
| Grass — forest floor | `#3B3F1B` (59,63,27) | #7 `c7_bottomleft.png` box (350,480,470,570) | dominates #11 forest floor |
| Rock — lit pale face | `#6C614B` (108,97,75) | #8 `c8_rockwall_zoom.png` box (70,170,170,300) | ~25% of rock area |
| Rock — mid face | `#4B4430` (75,68,48) | #8 `c8_rockwall_zoom.png` box (250,250,380,380) | ~40% of rock area |
| Rock — deep shadow | `#393424` (57,52,36) | #8 `c8_rockwall_zoom.png` box (400,180,560,300) | ~30–35% of rock area |
| Dirt / gravel path | `#4D4234` (77,66,52) | #4 `c4_grass_trees.png` box (250,150,420,300) | 45–55% of #4 clearing |
| Dirt — lighter sandy | `#6F5F38` (111,95,56) | #4 `c4_trees_brush.png` box (0,0,300,200) | — |
| Sand (shore) | `#A89E7F` (168,158,127) | #12 `c12_water.png` box (120,180,240,300) | shore band ~5–10% near water |
| Wheat — golden | `#8E6F29` (142,111,41) | #2 `c2_wheat_mill.png` box (40,60,250,220) | 10–20% in #2/#4 |
| Wheat — mid | `#83692B` (131,105,43) | #4 `c4_wheat_field.png` box (300,150,600,400) | — |
| Conifer — dark crown | `#30331B` (48,51,27) | #11 `c11_conifers.png` box (350,120,420,240) | dense forest dominant |
| Conifer — lit spruce tips | `#656937` (101,105,55) | #7 `c7_bottomleft.png` upper-65%-brightness of box (500,150,650,340) | — |
| Broadleaf — lime | `#697630` (105,118,48) | #7 `c7_bottomleft.png` upper-65%-brightness of box (200,280,330,460) | — |
| Broadleaf — yellow/autumn | `#6B6531` (107,101,49) | #8 `c8_gully_left.png` upper-65%-brightness of box (220,230,310,320) | — |
| Dead/bare tree | `#4F5625` (79,86,37) lit; dark `#2C2A15` | #7 `c7_bottomleft.png` boxes (330,300,470,470), (20,430,120,560) | rare, ~1–3 trees per gully crop |
| Water — dark river | `#3A4246` (58,66,70) | #6 `c6_water_topright.png` box (300,0,600,50) | top ~5–8% of #6 |
| Water — shallow pale | `#696B65` (105,107,101) (mixed w/ sand) | #12 `c12_water.png` box (330,120,470,260) | ~15% of #12 |
| Snow | `#F0F0FB` (240,240,251) | #1 `c1_winter_ground.png` box (100,100,300,250) | 70–80% of #1 |
| Rock+snow mix | `#B2AFB5` (178,175,181) | #1 `c1_winter_ground.png` box (90,330,330,400) | — |

---

## 3. Morphology / decor / ground / water / lighting (with crop evidence)

### 3.1 Height & rock morphology — PRIMARY evidence #8
`observed` in `c8_rockwall_zoom.png` (src #8 `(560,150,1000,560)` sub-box) and `c8_boundary_zoom.png`
(src #8 box `(0,600,210,720)`):
- Ravines are a **branching network of narrow winding gullies** cut into an otherwise flat grass plateau. The
  plateau top is smooth and near-planar (`c8_plateau_top.png`).
- Rock faces are **near-vertical**: in the zoom the exposed wall runs top-to-bottom with side-to-side drift of
  only ~10–20% of its height (apparent slope ≈ 75–85° from horizontal). Face height in source ≈ 60–90 px of
  720 px image height (≈ 8–12% of screen height); gully mouth width ≈ 30–100 px.
- Faces carry **fine vertical/wavy erosion striations** running straight down the wall (`c8_rockwall_zoom.png`,
  pale strips at x≈70–170 and x≈710–800 of the 1000×480 zoom).
- **Rock meets grass abruptly**: the rim is a 1–3 px transition, with grass tufts visibly overhanging the edge
  (`c8_boundary_zoom.png`, src x≈350–480). No soft grass→dirt gradient on the cliff top.
- **Shadowing is intrinsic to the morphology**: north/attic faces are 2× darker. Lit `#6C614B` vs shadow
  `#393424` → luminance ratio ≈ 108/57 ≈ 1.9 (`derived`). Striated faces catch light as pale vertical strips;
  recesses read as dark slits.
- `derived` from `c8_ravine_center_grid.png`: a face is typically **1.5–3× the height of an adjacent conifer**
  (conifer ≈ 40 px source, face ≈ 60–90 px source).
- In overview #6 `c6_overview.png`, the same gullies read as dark winding slits covering roughly **5–10% of the
  visible terrain** (visual estimate, UNVERIFIED); in #8 the figure is roughly **10–18%**.

### 3.2 Trees & bush decor
`observed` species families (≥4 distinguishable):
1. **Spruce/conifer** — tall narrow layered triangle, dark green `#30331B`–`#4C4A26`, lit tips `#656937`
   (#11 `c11_conifers.png`, #7 `c7_bottomleft.png` box `(520,180,640,360)`, #8).
2. **Broadleaf deciduous** — rounded clumpy crown, lime `#697630` to yellow `#6B6531` (#7 box
   `(200,280,330,460)`, #8 `c8_gully_left.png` x≈220–310,y≈230–320).
3. **Dead/bare tree** — gray-brown leafless trunk + few twigs, `#4F5625`/`#2C2A15` (#7 box `(20,430,120,560)`).
4. **White-flowering bush / tall grass tufts** — white blossoms and reed-like tufts (#8 `c8_gully_left.png`
   x≈20–120,y≈400–440; #7 box `(300,60,380,130)`).

Size buckets (`observed`, source-px tree heights at 1280×720 / 1916×1080 scale):
- small sapling 15–30 px; medium broadleaf/conifer 40–60 px; large spruce 70–100 px (≈ 14% of 720p screen
  height); in 1080p #7 the largest spruces reach ~180 px (≈ 17% of screen height).

Density — reproducible grid counts (`derived`, grid overlays `*_grid.png`, ±~25%):
- `c8_gully_left_grid.png` (840×840 crop = 420×420 src px): **≈ 30–40 trees** → ~170–230 trees / MP.
- `c11_conifers_grid.png` (976×754 crop = 488×377 src px): **≈ 120–180 trees** → ~650–980 trees / MP (dense forest).
- `c8_ravine_center_grid.png` (880×820 crop = 440×410 src px): **≈ 15–20 trees** → ~85–110 trees / MP.
- `c4_trees_brush_grid.png` (900×676 crop = 900×676 src px, village dirt): **≈ 4–6 trees** → ~7–10 trees / MP.

Placement (`observed`): trees cluster along **gully rims and plateau edges** and form dense woods on flats; they
rarely stand inside the gully floor. Open plains carry isolated singles or small clumps. In #6, conifers line the
river bank.

### 3.3 Ground texture
- `derived` clean grass (`c8_ravine_center.png` box `(0,350,350,700)`): luminance mean 91.8, std **8.6**,
  hi-frequency energy (image − 5px Gaussian blur) mean **2.96** → very fine, low-amplitude mottling, 2–5 px scale.
- Relief-containing grass (`c6_overview.png` box `(250,220,450,420)`, 200×200): luminance std **37.6**,
  hi-freq **11.36** → shading patches dominate at 20–80 px scale.
- Luminance histogram of a 200×200 terrain crop (`derived`, 8 bins of 32 levels): clean plateau occupies 2 bins,
  gully-mixed 3 bins, overview-with-relief **4 bins** at ≥3% area → 3–4 readable grass tonal patches.
- `observed` dirt (`c4_trees_brush.png`): gray-brown pebble speckle, 2–4 px stones, crisp boundary where it meets
  grass; wheat fields (`c2_wheat_mill.png`, `c4_wheat_field.png`) have **sharp straight rectangular edges** and
  dense vertical-stalk texture in golden `#8E6F29`–`#B18A33`.
- Grass→rock/sand blending is **abrupt**, not a smooth gradient.

### 3.4 Water & shore
- `observed` #6 `c6_water_topright.png` (src `(600,0,960,160)`): dark slate-blue river `#3A4246`, relatively
  smooth with faint horizontal ripple bands, green bank meets water directly with little foam.
- `observed` #12 `c12_water.png` (src `(300,150,512,288)`, 3× zoom): shallow pale gray-cyan water ~`#696B65`
  with **concentric arc ripples**; shore is a 3-band transition sand `#A89E7F` → pale washed band → water. Foam
  is weak/absent. LOW confidence: source is only 512×288 and the crop is upscaled (UNVERIFIED detail).
- #7 inspected corners contain **no water**.

### 3.5 Lighting / atmosphere
- `observed`: consistent **directional sun from upper-right**; tree and building shadows fall to the **lower-left**
  in #8 (`c8_gully_left_grid.png`, e.g. tree at x≈240,y≈280 casts shadow toward x≈200,y≈320) and #4
  (`c4_trees_brush.png`, house shadow to lower-left). Shadow length ≈ 1–2× object height.
- `derived`: lit/shadow luminance ratio ≥ 1.7–1.9 for both grass (`#6B6732`=103 vs `#3E411F`=65) and rock
  (`#6C614B`=108 vs `#393424`=57) → strong but not crushed contrast.
- `observed`: pronounced **ambient occlusion** in gully bottoms and under tree canopies; #10 `c10_hills_bg.png`
  shows bluish-gray **atmospheric haze** on distant hills.
- `derived` full-image HSV: sat 0.34–0.50, value 0.25–0.42 → muted olive/gold, high saturation only in wheat.

---

## 4. Claim table

| Claim | Evidence (image + crop) | Method | Verdict | Correction / caveat |
|-------|-------------------------|--------|---------|----------------------|
| Ravine faces are near-vertical (≈75–85°) | #8 `c8_rockwall_zoom.png` src `(560,150,1000,560)` | Visual wall-width vs height in zoom | observed | Angle is apparent 2.5D projection, not a true 3D slope |
| Rock carries vertical erosion striations | #8 `c8_rockwall_zoom.png` x≈70–170, 710–800 | Visual zoom | observed | — |
| Lit rock ≈ `#6C614B`, shadow ≈ `#393424` | same crop, boxes (70,170,170,300) & (400,180,560,300) | Pillow mean RGB of boxes | derived | Small boxes; ±10 RGB from JPEG artifacts |
| Grass→rock transition ≤3 px, tufts overhang | #8 `c8_boundary_zoom.png` src `(0,600,210,720)` | Visual zoom | observed | — |
| Rock = 10–18% of #8 terrain; 5–10% of #6 | #8 `c8_ravine_center.png`, #6 `c6_overview.png` | Visual area estimate | inferred | UNVERIFIED precision; threshold classifier too crude to confirm |
| Four tree/bush species families present | #7 `c7_bottomleft.png`, #11 `c11_conifers.png`, #8 `c8_gully_left.png` | Visual + lit-pixel sampling | observed | Dead-tree count is rare (1–3 per crop) |
| Dense forest ≈120–180 trees per 488×377 px | #11 `c11_conifers_grid.png` | 100 px grid overlay count | derived | ±25%; overlapping crowns may be double-counted |
| Gully-edge ≈30–40 trees per 420×420 px | #8 `c8_gully_left_grid.png` | 100 px grid overlay count | derived | Excludes small bushes and hidden trees |
| Clean grass luminance std ≈ 8.6, hi-freq 2.96 | #8 `c8_ravine_center.png` box (0,350,350,700) | Pillow L-std + 5px-blur difference | derived | Crop is an unusually uniform plateau |
| 200×200 relief grass spans ≥3 luminance bins | #6 `c6_overview.png` box (250,220,450,420) | 8×32-level histogram | derived | Bin count depends on crop placement |
| Wheat has sharp rectangular edges | #2 `c2_wheat_mill.png`, #4 `c4_wheat_field.png` | Visual | observed | Field decor, not natural terrain |
| Water dark `#3A4246` (#6) / pale `#696B65` (#12) | #6 `c6_water_topright.png`, #12 `c12_water.png` | Pillow mean RGB | derived | #12 is low-res + upscaled → UNVERIFIED ripple detail |
| Sun from upper-right, shadows lower-left | #8 `c8_gully_left_grid.png`, #4 `c4_trees_brush.png` | Visual shadow direction | observed | — |
| Lit/shadow luminance ratio ≈1.7–1.9 | palette pairs above | Arithmetic of sampled means | derived | — |
| Mean HSV sat 0.34–0.50 (non-winter) | all images, 64×64 downsample | colorsys.rgb_to_hsv | derived | #1 winter is an outlier at 0.088 |
| #7 contains water | contact sheet at thumbnail scale | — | inferred | **CORRECTION:** inspected full-res corners `(0,500,700,1080)` and `(1200,400,1916,1080)` show NO water; reject |
| #8 is a mountain/rock-wall map | filename "highlands" association | — | inferred | **CORRECTION:** #8 is grass plateau + earthen gullies; the "highlands" image is #7, which is a forested town. Use morphology, not title |

---

## 5. Measured target spec — ranked acceptance criteria

Each is measurable from a rendered PNG with Pillow or a side-by-side crop. Targets are derived from the crops
above. "Screen" means the terrain area excluding HUD/units.

| Rank | Criterion | Metric | Target value | How to measure from a PNG |
|------|-----------|--------|--------------|---------------------------|
| **1** | Ravine rock morphology | % of terrain area that is gray-brown rock face (R≈G>B, low sat) AND apparent face slope | **8–18%** area; faces near-vertical (edge drift <20% of height); face height 8–12% of frame | Threshold-classify rock vs olive grass on a 400×400 downsample; manually verify 3 faces; measure face top/bottom x-offset vs height on a crop |
| **2** | Grass palette correctness | Dominant grass hex + hue/luma spread | ≥4 tonal patches per 200×200 terrain crop; hues olive 45–75°; means within `#4F5325`–`#7B724E`; luminance ≥3 of 8 bins at ≥3% | HSV transform + 8-bin luminance histogram; compare top quantized colors to palette table |
| **3** | Tree species & size variety | Distinct crown color families + size buckets | ≥3 families (dark conifer `#30331B`–`#656937`, lime/yellow broadleaf `#697630`/`#6B6531`, dead/dry) AND ≥3 size buckets (small 15–30, mid 40–60, large 70–100 px at 720p) | Segment green components; sample upper-65%-brightness crown pixels; measure component bounding-box heights |
| **4** | Tree density by biome | Trees per megapixel in matched biome | sparse plain 20–60/MP; gully rim 150–250/MP; dense forest 650–1000/MP | 100 px grid overlay + manual crown count on matched-resolution crops |
| **5** | Directional lighting & contrast | Shadow direction, length, lit/shadow ratio | shadows toward lower-left; length 1–2× object height; lit/shadow luma ratio **≥1.5** (target 1.7–1.9) | Sample paired lit/shadow pixels on one tree/rock; compute luminance ratio; check shadow centroid offset |
| **6** | Rock/grass edge treatment | Transition width at rim | **≤3 px** hard edge with tuft overhang, not a smooth gradient | Sample a 1-px-wide profile line perpendicular to a rim; count pixels to go from grass hue to rock hue |
| **7** | Ground micro-texture | Hi-frequency energy + noise scale | image−5px-blur mean **3–12** luma levels; speckle 2–5 px; relief crops std 25–40 | Pillow GaussianBlur(5) difference mean; luminance stddev on 200×200 clean/relief crops |
| **8** | Water & shore (conditional) / field decor | Water color + shore band structure OR wheat edge | water dark `#3A4246` or shallow `#696B65` with ripple arcs; shore = sand→wash→water 3 bands; wheat fields sharp-edged gold `#8E6F29` | Sample water/shore band means; count distinct bands along a shoreline profile; check wheat edge gradient width |

Global gate (supporting, not ranked): mean HSV saturation **0.30–0.55** and value **0.25–0.45** for temperate
shots; snow shots excluded.

---

## 6. Recommended primary comparison image(s) + crop coordinates

**Primary: #8 `cossacks-3-v1-498085.jpg` (1280×720).** Reason: it is the only frame where ravine morphology,
grass palette, rock striations, tree species/size variety and directional shadows all appear together with
minimal building clutter, at a convenient 720p size that matches a mini-map render. `derived` dimensions and all
palette anchors above come from it.

Suggested side-by-side crops (source px, crop out HUD/units where possible):
- **A — primary morphology crop:** `(560,150,1000,560)` — ravine + plateau + trees + watchtower (this is
  `c8_ravine_center.png`). Best single 440×410 comparison tile.
- **B — gully + tree crop:** `(0,300,420,720)` — winding gullies, conifers/broadleaf, white bushes
  (`c8_gully_left.png`).
- **C — plateau/grass crop:** `(350,0,850,300)` — grass top + rock wall + tree line (`c8_plateau_top.png`).

**Secondary: #4 `Cossacks3AttackingVillage.webp` (2355×1376)** for high-resolution tree/ground detail — crop
`(900,600,1600,1100)` (grass/dirt/trees) and `(1300,0,2355,600)` (wheat + conifers).
**Secondary: #6 `articolo-787.jpg`** for overview/water — full frame `(0,0,960,540)` and water
`(600,0,960,160)`.
Use #7 crop `(0,500,700,1080)` only for tree-species close-up, and #1 for a separate winter palette test.

---

## 7. Open questions

1. **Exact game/theme target:** no owner statement of which biome the mini-map should be (temperate green
   ravines vs winter vs sandy). This spec assumes the temperate ravine look of #8/#6; confirm before locking
   the palette (UNVERIFIED).
2. **Render resolution & camera angle:** the apparent 75–85° slope and tree-height percentages assume the donor
   isometric camera. A different camera would change every %-of-screen criterion — need target camera params.
3. **Rock area precise measurement:** the threshold classifier is too crude (buildings/units contaminate it).
   A hand-labeled mask over crop A is needed to confirm the 8–18% figure (UNVERIFIED).
4. **Water importance:** only two low-quality water samples exist; if water is mandatory, a higher-res donor is
   needed. #12 ripple/foam detail remains UNVERIFIED.
5. **Shadow softness:** crops show defined but slightly soft shadows; PCF filter radius not measurable from JPG
   compression — needs side-by-side visual judgment.
6. **Tree counts** in dense forest are ±25% because overlapping crowns cannot be separated reliably at 788 px
   resolution.
