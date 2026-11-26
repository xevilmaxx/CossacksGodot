---
id: X07
swarm: TERRAIN-SWARM-2026-11-26
role: ANALYSIS / READ-ONLY — visual reference index for owner-facing A/B acceptance
owner_file: docs/terrain_swarm_2026-11-26/reports/X07_visual_reference_index.md
status: LANDED__NO_SOURCE_OR_ASSET_EDIT__NO_GODOT_JOB__NO_DONOR_PARITY_CLAIM
created: 2026-11-26
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, "PORT APPROXIMATION"]
parity_guard: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
reference_corpus: "C:\\Users\\Maxym.Oboyshev\\Downloads\\c3\\ (12 files, READ-ONLY)"
governing_sources:
  - docs/terrain_swarm_2026-11-26/CHARTER.md — §2 (evidence sources, labels), §4 (guardrails, multiple passes), §6 (owner-facing classes)
  - docs/terrain_swarm_2026-11-26/SWARM_BOARD.md — X07 row, integration gates
  - docs/terrain_swarm_2026-11-26/spec/12_QA_AND_INTEGRATION.md — §12.6, lines 72-78 (visual A/B protocol)
  - docs/terrain_swarm_2026-11-26/reports/A05_qa_harness.md — §4, lines 160-205; E09 at line 74
  - docs/terrain_swarm_2026-11-25/reports/A11_reference_metrics.md — §1 ROI table (lines 61-77), §6 confounds (lines 188-211)
---

# X07 — visual reference index (donor stills, read-only)

## 0. Executive summary

- **[O]** All 12 files in `C:\Users\Maxym.Oboyshev\Downloads\c3\` were opened and visually
  inspected with the `read` tool (image-capable). Dimensions, mode and full-frame mean
  RGB/saturation were independently recomputed with Pillow in a second pass. Four
  ambiguous features (shore band, distant water strip, mine, "highlands" relief) were
  re-examined via upscaled crops written only to
  `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\x07_crops\` — **no reference image,
  repo source, asset, config or test was edited; no Godot job was submitted.**
- **[D]** The corpus is a *composition/landscape-class index*, not a measurement set.
  It covers rolling hills, golden mill fields, conifer/mixed forest, stone masonry and
  boulders, one explicit gold mine, settlement decor, and one weak shore candidate.
- **[U]** **No image shows true mountains, an unmistakable river/swamp, or an identifiable
  iron/coal mine.** The file named `cossacks-3-guardians-of-the-highlands-...jpg` is a
  promotional construction scene with no visible mountain relief (two-pass confirmed) —
  its filename is not evidence of the class.
- **[U]** Per A05 E09 (`reports/A05_qa_harness.md:74`) and spec §12.6
  (`spec/12_QA_AND_INTEGRATION.md:72-78`), these are **third-party stills of unknown
  donor build, camera, zoom, world area and JPEG/WEBP compression**. They support
  **only direction of movement** on matched fractional ground ROIs — never parity,
  never a "donor match/confirmed" claim, never a numeric gate threshold.
- **[D]** Best single all-round reference: `cossacks-3-v1-498085.jpg` (rolling relief +
  pine clusters + watchtowers + the A11 "ref A" ground ROI `.35,.55,.48,.70`). Best
  mill-field reference: `523480776.jpg`. Best forest: `large_1.webp`. Best mine/stone:
  `3173885360_preview_Turkish battle 19 Light Infantry rush.jpg` (winter confound).
  Best (weak) shore: `maxresdefault_1.jpg`.
- **[I]** Recommended use: the implementation/capture worker picks the class mapping in
  §4, applies the **same fractional ROI to both candidate sides**, and records the
  visual read separately from any metric (A05 §4.2). Required reviewer line is reproduced
  verbatim in §8.

## 1. Method and admissibility (O / D)

1. `[O]` Pass 1 — `read` tool on each of the 12 images at native resolution; notes taken
   on classes, camera angle/zoom, lighting/season, HUD/sky/units.
2. `[O]` Pass 2 — Pillow 12.x: `Image.open(...).size/.mode` plus full-frame mean RGB and
   mean HSV-like saturation `(max-min)/max` over a 120×120 LANCZOS thumbnail. These
   corroborate the dimensions in `A11_reference_metrics.md:63-76` and give an objective
   light/season anchor (e.g. image 0 mean RGB 171.3/168.0/176.5, sat 0.091 = snow;
   image 4 mean 155.1/121.8/91.7 = tan/dirt).
3. `[O]` Pass 3 (ambiguity only) — LANCZOS-upscaled crops into the system temp folder:
   `shore_check.png`, `top_water_check.png`, `mine_check2.png`, `highlands_check.png`.
   A first mine crop landed on HUD and was **re-cropped**, not skipped, per charter §4.
4. `[D]` Fractional ROIs are given as `(x0,y0,x1,y1)` of the full frame, matching the
   `compare_shots.py --crop-frac` convention in A05 §4.2 / A11 §1. A11 ROIs are reused
   where they are ground-only; class-specific alternatives are marked **[I]** and must be
   visually confirmed on-screen before a comparison counts (G0-e in A05 §4.1).
5. `[D]` "Usefulness rank" is ordinal **within a class only**. No cross-image score is
   computed: camera/world-area are unknown, so scalar comparison would be spurious.

## 2. Evidence table (12 images)

Legend: `[O]` seen/computed in this pass; `[D]` ranked from those observations; `[I]`
advisory ROI or interpretation; `[U]` unverified class/water semantics.
`A#` = index in `A11_reference_metrics.md:63-76`.

| A# | filename (in `C:\Users\Maxym.Oboyshev\Downloads\c3\`) | px (O) | classes visible (O/I) | camera / zoom (I) | light / season (O) | mean RGB, sat (O) | primary ROI (D/I) | strongest class use (D) |
|---|---|---|---|---|---|---|---|---|
| 0 | `3173885360_preview_Turkish battle 19 Light Infantry rush.jpg` | 1920×1080 | snow ground, stone castle + boulders, gold mine, harvested stubble field, snow conifers, buildings, units, HUD | high 3/4 overview, medium-far | bright cold daylight, **winter** | 171.3,168.0,176.5 / 0.091 | `.01,.62,.19,.84` (A11 snow) | **gold mine**, stone, winter fields |
| 1 | `523480776.jpg` | 720×405 | golden wheat L-field, stone windmill, wooden watchtower, rock/hay pile, 2 peasants | medium 3/4, **close** (few tiles) | warm sun, late summer / harvest | 88.6,80.2,36.7 / 0.563 | `.00,.60,.18,.92` (A11 grass) | **mill fields + windmill** |
| 2 | `899956545_preview_20170411195032_1.jpg` | 1366×768 | near-uniform grass, scattered bushes/small pines + yellow flowers, massed units, HUD | high 3/4 overview, medium-far | even daylight, summer | 69.2,69.8,35.5 / 0.507 | `.02,.50,.20,.72` (A11 green) | uniform-grass lower bound |
| 3 | `Cossacks3AttackingVillage.webp` | 2355×1376 | large rectangular golden wheat fields + windmill, pine belts, dirt/gravel lane, village houses, units, HUD | high 3/4 overview, wide | clear summer day | 86.2,78.7,48.3 / 0.435 | `.70,.68,.96,.90` (A11 ground) | **mill fields (large scale)**, forest edge |
| 4 | `MADVBuilding1.JPG` | 485×486 | tan sandy/dirt ground, cobbled plaza, stone town-hall façade, HUD panels | low 3/4, **close building** (not terrain) | flat overcast/ambient, dry season | 155.1,121.8,91.7 / 0.392 | `.02,.02,.20,.20` (A11 dirt) | sand/dirt sample only — **not a landscape reference** |
| 5 | `articolo-787.jpg` | 960×540 | rolling mottled hills, sparse pines, cannon smoke, tent camp, thin distant water + ship at top-right `[U]` | very high 3/4 overview, wide | hazy warm daylight, summer/dry | 75.9,73.1,50.6 / 0.408 | `.30,.27,.42,.39` (A11 ref B) | **rolling hills + ground mottling** |
| 6 | `cossacks-3-guardians-of-the-highlands-pc-gioco-steam-wallpaper-3.jpg` | 1916×1080 | stone masonry/castle under construction, scaffolding, carts, conifers, dense units; **no mountains** (2 passes) | medium 3/4, close-to-medium | dark shadowed daylight, summer | 74.5,67.2,48.1 / 0.363 | `.30,.84,.42,.98` (A11 ground+shadows) | **stone/building decor**; filename misleading |
| 7 | `cossacks-3-v1-498085.jpg` | 1280×720 | rolling green mounds, earthen/rocky embankment faces (ravine-like), pine clusters, 3 wooden watchtowers, huts, massed units | high 3/4 overview, medium | clear summer day, high green saturation | 81.9,77.9,45.1 / 0.458 | `.35,.55,.48,.70` (A11 ref A) | **hills + forest + decor + ground mottling** |
| 8 | `hqdefault.jpg` | 480×360 | small town/towers, green ground, scattered troops/sheep, slight slope, HUD | high 3/4 overview, wide (thumbnail) | flat daylight, summer | 53.6,54.6,31.9 / 0.362 | `.28,.68,.46,.86` (A11 ground) | decor/town silhouette only — low detail |
| 9 | `images.jpg` | 588×340 | mixed deciduous/conifer trees, green ground, distant tree-lined slope, scattered units, HUD | medium 3/4, medium-far (thumbnail) | even daylight, summer | 74.4,74.9,41.3 / 0.482 | `.42,.50,.52,.60` (A11 small patch) | mixed-forest composition, low detail |
| 10 | `large_1.webp` | 788×377 | dense conifer stand with long shadows, grass glades, dirt path, massed units, minimap | medium 3/4, medium (wide crop) | bright high-contrast sun, summer | 61.6,59.6,32.4 / 0.500 | `.02,.53,.12,.68` (A11 uniform grass) | **dense conifer forest**; uniform-grass low outlier |
| 11 | `maxresdefault_1.jpg` | 512×288 | pale sandy/gray **shore band** meeting green land `[U]` water, stone castle wall + boulders, deciduous trees, orange roofs, massed units, minimap | high 3/4 overview, wide (thumbnail) | flat daylight, summer | 104.1,98.8,72.2 / 0.342 | `.05,.20,.28,.42` (A11 green) | **best-available shore candidate** (weak) |

No image was skipped. Images 4, 8 and 9 are readable but low-value for terrain class
judging; they are retained with explicit low rankings rather than dropped.

## 3. Per-image cards

### A0 — `3173885360_preview_Turkish battle 19 Light Infantry rush.jpg` (1920×1080)
- **[O]** Winter siege overview: snow-covered ground, three gray stone castles, dense
  snow-laden conifers, a golden harvested stubble field (centre-top), and gray boulder
  clusters. Top resource bar and bottom-right chat/minimap are HUD.
- **[O]** Second-pass crop `mine_check2.png` confirms a **gold mine**: wooden minehead
  on a rocky outcrop with a gold-coin icon, purple flag, and on-screen text
  "Mine has been constructed successfully." No iron/coal mine is identifiable.
- **[I]** High 3/4, medium-far; bright cold light. Snow makes it unusable for green-ground
  colour bands but excellent for *negative-space* shape tests (rocks/mine silhouettes).
- **[D]** Rank: gold mine #1, stone #1 (with snow confound), winter field #3, forest #3.
- **[I]** ROIs: mine `.24,.62,.42,.86`; snow ground `.01,.62,.19,.84` (A11); stubble
  `.45,.20,.72,.42`; stone/castle `.30,.05,.70,.28`. Exclude right-edge HUD.

### A1 — `523480776.jpg` (720×405)
- **[O]** Close 3/4 view: L-shaped golden wheat field wraps a stone windmill; adjacent
  timber watchtower, stacked hay/rock pile, two peasants. No HUD over the field itself.
- **[I]** Warm harvest light, late summer; the only image where field *shape* and the
  windmill footprint are both legible.
- **[D]** Rank: mill fields #1, decor (windmill) #2.
- **[I]** ROIs: field `.46,.04,.90,.38` (windmill+field `.40,.02,.75,.45`); A11 grass
  `.00,.60,.18,.92`. Field ROI is **[I]** — confirm no unit overlaps on-screen.

### A2 — `899956545_preview_20170411195032_1.jpg` (1366×768)
- **[O]** Broad, nearly flat green field with faint bare-earth mottling, sparse bushes
  and small pines/yellow flowers; large blue/gold formations at centre-right; HUD bars.
- **[I]** Medium-far high 3/4; even summer daylight. Ground is relatively uniform — a
  useful *lower* comparator for A11's "uniform grass" case (A11 #10).
- **[D]** Rank: uniform ground #3; hills very low (relief barely readable).
- **[I]** ROI: `.02,.50,.20,.72` (A11), choose lower-left to avoid formations.

### A3 — `Cossacks3AttackingVillage.webp` (2355×1376)
- **[O]** Highest-resolution gameplay still. Large rectangular golden wheat fields
  (top-right, left edge) with a windmill, dense pine belts (top, bottom), a wide gray
  dirt/gravel clearing, village houses, red/white units and HUD.
- **[I]** Wide high 3/4; clear summer light. Best for *field footprints at scale* and
  forest-edge transitions; A11 noted part of its ROI variance comes from units/shadows.
- **[D]** Rank: mill fields #2, forest edge #2, ground mosaic #2.
- **[I]** ROIs: field `.70,.08,.86,.28`; dirt clearing `.38,.10,.58,.30`; A11 ground
  `.70,.68,.96,.90` (contains trees — treat as mixed, not pure ground).

### A4 — `MADVBuilding1.JPG` (485×486)
- **[O]** Close isometric view of a stone town hall on tan sandy ground with a cobbled
  forecourt; bottom third is a unit-selection HUD; a red border frames the shot.
- **[I]** Two-pass review confirms this is a **building/UI close-up, not a landscape
  overview**; no hills, water, field or forest. Only sand/dirt texture is usable.
- **[D]** Rank: sand/dirt sample #1 (only one); excluded from all landscape-class ranks.
- **[I]** ROI: `.02,.02,.14,.16` (A11 `.02,.02,.20,.20` includes building edge).

### A5 — `articolo-787.jpg` (960×540)
- **[O]** Very high overview of rolling green/brown hills with dark shadowed slopes,
  scattered pines, heavy cannon smoke, a tent camp (right), and a thin pale blue-gray
  band with a ship silhouette at the very top-right `[U]` (water body unidentified).
- **[I]** Hazy warm light, dry summer. Mottled slopes make it the second-best relief
  reference; the water strip is too small to calibrate shore.
- **[D]** Rank: hills #2, ground mottling #2, shore #2 (weak).
- **[I]** ROIs: A11 ref B `.30,.27,.42,.39`; hill slope `.34,.16,.62,.34`; distant water
  `.80,.00,.98,.09` `[U]` — apply only for presence/absence, not numeric calibration.

### A6 — `cossacks-3-guardians-of-the-highlands-pc-gioco-steam-wallpaper-3.jpg` (1916×1080)
- **[O]** Promotional wallpaper: half-built stone church/castle with scaffolding,
  wooden hoarding, carts, barrels, dismounted cavalry, bright green grass and conifers.
- **[O]** Two passes (full frame + saved `highlands_check.png`) found **no mountains and
  no meaningful hills** — the "highlands" filename is marketing, not visual evidence.
- **[I]** Medium 3/4, close-to-medium; dark shadows produce a high dark tail (A11 Y std
  40.1). Useful for stone/*decor*, not for relief.
- **[D]** Rank: stone/building decor #1, forest #5, hills **not usable**.
- **[I]** ROIs: A11 `.30,.84,.42,.98` (ground+shadow); stone `.34,.12,.62,.42`;
  forest `.02,.62,.28,.98`.

### A7 — `cossacks-3-v1-498085.jpg` (1280×720)
- **[O]** High overview of rolling green mounds cut by steep earthen/rocky embankment
  faces, three wooden watchtowers, pine clusters in small groves, wood huts, red/blue
  formations. A11 "ref A" ROI `.35,.55,.48,.70` is ground+pines.
- **[I]** Clear summer day, saturated green. The combination of readable relief shape,
  natural tree spacing and ground mottling makes this the **best single all-round
  landscape reference**. Embankments are earthworks, **not mountains**.
- **[D]** Rank: hills #1, forest-on-hill #1, decor #1, ground mottling #1.
- **[I]** ROIs: A11 `.35,.55,.48,.70`; embankments `.36,.16,.66,.38`; pines
  `.30,.02,.52,.24`; watchtower `.62,.10,.82,.32`.

### A8 — `hqdefault.jpg` (480×360)
- **[O]** Low-resolution YouTube thumbnail: compact town with several towers, green
  ground, scattered troops and sheep, slight slope; HUD strip top/bottom.
- **[I]** Wide high 3/4. Fine detail is unreliable; composition/decor silhouette only.
- **[D]** Rank: decor #4, ground #6 — advisory at best.
- **[I]** ROI: `.28,.68,.46,.86` (A11). Treat block variance as more trustworthy than
  gradient (A11 §6).

### A9 — `images.jpg` (588×340)
- **[O]** Low-resolution combat shot: green ground, scattered red/blue groups, mixed
  deciduous/conifer trees, a tree-lined slope in the distance, HUD bottom-left/right.
- **[I]** Medium 3/4; even summer light. Tree *distribution* readable, individual
  canopy detail is not.
- **[D]** Rank: mixed forest #4, hills #4 (distant only).
- **[I]** ROIs: A11 `.42,.50,.52,.60` (small ground patch); tree line `.66,.06,.90,.30`.

### A10 — `large_1.webp` (788×377)
- **[O]** Wide, short crop: dense spruce/pine stand with long ground shadows, irregular
  green glades, a dirt path, red/white formations, unit card bottom-left and minimap
  bottom-right.
- **[I]** Medium 3/4, bright sun. Best tree silhouette + shadow reference; its A11 ROI
  (`.02,.53,.12,.68`) is an unusually uniform grass patch and is an intentional
  **low outlier** (A11 BV32 n640 9.2 vs green median 247.6).
- **[D]** Rank: dense conifer forest #1; uniform-grass lower bound #1.
- **[I]** ROIs: forest `.62,.04,.78,.60` (avoids minimap); uniform grass `.02,.53,.12,.68`.

### A11 — `maxresdefault_1.jpg` (512×288)
- **[O]** YouTube thumbnail: green land meeting a pale tan→gray-blue band on the right
  (second-pass `shore_check.png`), stone castle wall and boulders at lower-left,
  deciduous trees, orange roofs, large red formation, minimap bottom-right.
- **[U]** Water semantics: the pale band reads as a beach/shoreline gradient and the
  minimap shows dark blue water bodies, but the image is too small to certify sea vs.
  riverbank vs. exposed wet sand. Use as **best-available shore candidate**, not proof.
- **[I]** High 3/4, wide; flat daylight.
- **[D]** Rank: shore #1 (weak), stone #3, decor #3.
- **[I]** ROIs: shore `.60,.44,.84,.68` (above minimap); A11 green `.05,.20,.28,.42`.

## 4. Class → best-image mapping (D / I)

| Landscape class (charter §6) | Best image | Runner-up | Confidence | Note |
|---|---|---|---|---|
| **Hills / rolling relief** | `cossacks-3-v1-498085.jpg` (A7) | `articolo-787.jpg` (A5) | `[D]` moderate | earthworks/embankments in A7 are *not* mountains |
| **Mountains** | **none in corpus** | "highlands" wallpaper (A6) is a false positive | `[U]` | no donor visual reference; two-pass confirmed absence |
| **Mill fields (wheat / stubble)** | `523480776.jpg` (A1) | `Cossacks3AttackingVillage.webp` (A3) | `[D]` high | A1 close footprint+windmill; A3 large rectangular parcels |
| **Sea** | **none reliable** | `maxresdefault_1.jpg` (A11) `[U]` | `[U]` | water body not certifiable from stills |
| **Shore / beach** | `maxresdefault_1.jpg` (A11) | `articolo-787.jpg` (A5, distant strip) | `[I]` low | pale gradient band; verify semantics before naming sea |
| **Forest — conifer** | `large_1.webp` (A10) | `cossacks-3-v1-498085.jpg` (A7) | `[D]` high | A10 silhouettes/shadows; A7 grove placement on hills |
| **Forest — mixed/deciduous** | `images.jpg` (A9) | `Cossacks3AttackingVillage.webp` (A3) | `[I]` low | A9 low detail; distribution only |
| **Stone (boulders / quarry / masonry)** | `3173885360_...Turkish battle...jpg` (A0) | `cossacks-3-guardians-...wallpaper-3.jpg` (A6) | `[D]` moderate | A0 snow confound; A6 is built masonry, not a quarry |
| **Gold mine** | `3173885360_...Turkish battle...jpg` (A0) | — | `[D]` high (icon+text) | second-pass crop confirms; see UNVERIFIED U8 |
| **Iron / coal mine** | **none identifiable** | A0 shows one unclassified wooden minehead | `[U]` | resource family must come from F08/D07, stills insufficient |
| **Rivers / swamps** | **none identifiable** | A5 top-right strip `[U]` | `[U]` | no donor visual reference in this corpus |
| **Decor (towers / windmill / village / camp)** | `cossacks-3-v1-498085.jpg` (A7, watchtowers) | A6 (stone structures), A1 (windmill), A5 (tents) | `[D]` high | decor is over-represented vs. terrain in this corpus |
| **Green-ground mottling (BV32 direction)** | `cossacks-3-v1-498085.jpg` (A7, ref A) | `articolo-787.jpg` (A5, ref B) | `[D]` high for direction | A11 advisory band only; not a gate (A05 §4.2) |
| **Uniform grass lower bound** | `large_1.webp` (A10) | `899956545_preview_20170411195032_1.jpg` (A2) | `[D]` moderate | shows gap is not universal (A11 §6) |
| **Sand / dirt ground** | `MADVBuilding1.JPG` (A4) | A3 dirt clearing | `[D]` high for colour only | A4 is a building close-up, not a landscape |

## 5. ROI table (fractional `x0,y0,x1,y1` of full frame)

ROIs marked **A11** are taken verbatim from `A11_reference_metrics.md:63-76` and are the
safest starting points (they were hand-picked as ground-only). ROIs marked **[I]** are new
class-focused suggestions from this pass and require on-screen confirmation before use.
**The same fractional ROI must be applied to both candidate sides** (A05 §4.1 G0-e).

| id | filename | A11 ROI (D) | class ROI suggestion (I) | avoid |
|---|---|---|---|---|
| A0 | `3173885360_...Turkish battle...jpg` | `.01,.62,.19,.84` | mine `.24,.62,.42,.86`; stubble `.45,.20,.72,.42`; stone `.30,.05,.70,.28` | right HUD, snow if green band intended |
| A1 | `523480776.jpg` | `.00,.60,.18,.92` | wheat `.46,.04,.90,.38`; mill+field `.40,.02,.75,.45` | peasants, lower-left timber |
| A2 | `899956545_preview_20170411195032_1.jpg` | `.02,.50,.20,.72` | — | centre-right formations, HUD |
| A3 | `Cossacks3AttackingVillage.webp` | `.70,.68,.96,.90` | field `.70,.08,.86,.28`; dirt `.38,.10,.58,.30` | red units, houses, top HUD |
| A4 | `MADVBuilding1.JPG` | `.02,.02,.20,.20` | dirt `.02,.02,.14,.16` | building, bottom HUD |
| A5 | `articolo-787.jpg` | `.30,.27,.42,.39` | hill `.34,.16,.62,.34`; water `.80,.00,.98,.09` `[U]` | smoke plumes, tent camp |
| A6 | `cossacks-3-guardians-...wallpaper-3.jpg` | `.30,.84,.42,.98` | stone `.34,.12,.62,.42`; trees `.02,.62,.28,.98` | dense units, scaffolding |
| A7 | `cossacks-3-v1-498085.jpg` | `.35,.55,.48,.70` | embankment `.36,.16,.66,.38`; pines `.30,.02,.52,.24`; tower `.62,.10,.82,.32` | large formations |
| A8 | `hqdefault.jpg` | `.28,.68,.46,.86` | — | thumbnail blur, HUD |
| A9 | `images.jpg` | `.42,.50,.52,.60` | tree line `.66,.06,.90,.30` | HUD, scattered units |
| A10 | `large_1.webp` | `.02,.53,.12,.68` | forest `.62,.04,.78,.60` | minimap bottom-right, unit card |
| A11 | `maxresdefault_1.jpg` | `.05,.20,.28,.42` | shore `.60,.44,.84,.68` | minimap bottom-right, massed formation |

## 6. Risks / confounds (D / U)

1. **`[U]` E09 admissibility ceiling (A05 `reports/A05_qa_harness.md:74`).** Unknown donor
   build, camera, zoom, world area per pixel, and JPEG/WEBP compression (11 JPEG, 1 WEBP,
   several YouTube-derived thumbnails). No ROIs here are calibrated world-space regions;
   **direction of movement only**. Never claim parity, "matches", "close to donor" or a
   percentage similarity from these stills.
2. **`[U]` No donor GPU A/B frame exists.** SSIM/MAD via `compare_shots.py` is legitimate
   only for candidate-A vs candidate-B determinism at a pinned camera (A05 §4.2.3), never
   donor-vs-candidate.
3. **`[I]` Class imbalance.** Decor/units dominate the corpus; mountains, sea/rivers,
   swamps and iron/coal mines have no clean reference. The index must not be read as
   "all classes covered".
4. **`[I]` Snow and season confound (A0).** Mean RGB 171/168/177, sat 0.091 — excluded
   from green-ground bands in A11; use only for shape/silhouette classes.
5. **`[I]` Promotional/threshold confound (A6).** Wallpaper with heavy shadow/UI-free
   marketing composition; high dark tail; filename "highlands" does not mean mountains.
6. **`[I]` Resolution confound (A4, A8, A9, A11).** 485² down to 512×288; fine gradient
   unreliable, block variance comparatively more trustworthy (A11 §6).
7. **`[I]` ROI transfer risk.** A fractional ROI chosen on an angled overview may cover a
   different *feature* at the pinned candidate camera. G0-e requires the identical ROI on
   both sides; if it lands on sky/HUD/units, the comparison is UNVERIFIED, not retried
   until green (A05 §4.1/§4.2).
8. **`[I]` Metric must not override the eye.** A green number cannot erase a visible
   grid/streak/blotch; a red number cannot invent one (A05 §4.2.4, G21:241-250).
9. **`[D]` No repo/Godot side effects from this worker.** Derivative crops live only in
   `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\x07_crops\`.

## 7. UNVERIFIED register

| id | item | basis | consequence |
|---|---|---|---|
| U1 | Donor parity of any port capture | no donor GPU A/B frame; A05 E09 line 74, spec §12.6 lines 72-78 | always `parity.status = "UNVERIFIED"` |
| U2 | Whether A11's pale band is sea, river or wet sand | `maxresdefault_1.jpg` crop `shore_check.png` | shore used as weak candidate only; sea class unevidenced |
| U3 | Mountains class | no image shows mountains; A6 false positive on two passes | class has no visual acceptance reference |
| U4 | Iron / coal mine families | no identifiable icon/structure in corpus | defer to F08/D07 donor data, not stills |
| U5 | Rivers / swamps | none identifiable; A5 strip unresolved | no visual acceptance reference |
| U6 | A6 "highlands" filename vs. content | two-pass visual review | filename must not be cited as mountain evidence |
| U7 | Camera parameters / world area per ROI | third-party thumbnails and overviews | ratios are order-of-magnitude direction only (A11 §6) |
| U8 | A0 mine type | gold-coin icon + on-screen text seen; family not cross-checked | label "gold" as visual inference; confirm with F08/D07 |
| U9 | A5 top-right water strip identity | `top_water_check.png` shows pale strip + ship silhouette | not used for numeric bands |
| U10 | New [I] class ROIs transferability | not yet tested on a pinned candidate camera | G0-e must confirm before counting |
| U11 | A4 usefulness as a landscape reference | close building shot with HUD | retained for sand/dirt only, excluded from landscape ranks |

## 8. Required reviewer wording (verbatim, A05 §4.2)

> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU
> A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

## 9. Open questions (for COORD / implementation-capture worker)

1. **Q1 (COORD/capture):** pin the ROI set for owner A/B — reuse the 12 A11 ground ROIs
   verbatim, or adopt the class ROIs in §5? If both, declare which is the primary gate
   observer before capture.
2. **Q2 (COORD):** who supplies a genuine donor GPU A/B frame, if anyone? Until then the
   parity guard cannot be lifted and this index stays advisory only.
3. **Q3 (D06/F08):** is the pale band in `maxresdefault_1.jpg` sea, riverbank or exposed
   sand? Donor water/shore data must decide, not the still.
4. **Q4 (D05/A04):** with no mountain reference in the corpus, is an almanac/manual still
   required to accept the mountains class, or is donor `.pattern`/height-field evidence
   alone sufficient?
5. **Q5 (capture):** confirm `compare_shots.py --crop-frac` uses the same `(x0,y0,x1,y1)`
   ordering as A11/§5 on both candidate sides, and that ROIs are checked after the camera
   is pinned.
6. **Q6 (A05):** should snow/sand refs (A0, A4) stay excluded from the green-ground
   direction bands for all classes, or only for green-ground mottling?
7. **Q7 (F08/D07):** confirm the resource family behind A0's gold-coin minehead and the
   donor's iron/coal site visuals; stills cannot resolve this.
8. **Q8 (COORD):** should `large_1.webp`'s uniform-grass ROI keep its role as an explicit
   low outlier in the advisory band, so a fix that produces flat grass is not mistaken
   for a universal failure?

*End of X07 report. One report written; no other file modified.*
