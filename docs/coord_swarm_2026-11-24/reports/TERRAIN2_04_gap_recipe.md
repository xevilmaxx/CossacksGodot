---
id: TERRAIN2-04
title: "TERRAIN2-04 — donor-grounded gap recipe for variant3d/world3d_terrain.gd"
owner: TERRAIN2-04
scope: "Compare current variant3d terrain module + splat tool + g32_dump.json against actually-present donor data; rank fixes by visual impact per unit effort"
date: 2026-11-24
status: RESEARCH_COMPLETE__RENDER_PARITY_UNVERIFIED
verdict: "Most of the flat look is self-inflicted: a 1024x1024 donor block is collapsed to one mean texel per 2 m cell, and a constant water quad floods 2,359 cells the dump does not classify as water. Both are fixable with assets/data already in the repo. Forest/stone painting and cliff art remain engine-side and UNVERIFIED."
---

# TERRAIN2-04 — Gap recipe

## 1. Method and limits

Read-only audit: no source, config, asset, test or git edits; no donor binary copied or executed.
Sources read: the wired module `variant3d/scripts/world3d_terrain.gd` (all 422 lines), the
splat generator `app/tools/heightmap_splat.py` (all 434 lines) and its manifest, the decoded
`app/shots/g32_dump.json` (base64 grids decoded with Python/NumPy for counts), donor text under
`C:\Games\Cossacks 3\data\...`, the two prior reports named in the assignment
(`G32_heightmap_world.md`, `V713_world3d_terrain.md`, plus `G34_heightmap_splat.md` and
`AUDIT3D_03_terrain.md`), and the 2D port's texture/water implementation
(`app/scripts/world.gd`, `app/shaders/water_overlay.gdshader`, `app/tools/copy_assets.py`).

Peer reports TERRAIN2-01/02/03 did not exist in `docs/coord_swarm_2026-11-24/reports/` at write
time; per charter I did **not** wait or poll for them. Where their lanes overlap (donor
pipeline, texture semantics, water/weather), this report uses only evidence I read directly.

`OBSERVATION` = read/measured directly. `INFERENCE` = reasoned from those observations.
`UNVERIFIED` = no readable evidence found. No visual-parity claim is made: all predicted
effects need a GPU A/B frame (AUDIT3D-09 lane).

## 2. Evidence table

| # | Evidence (path:line or file key) | Observation / inference | Relevance |
|---|---|---|---|
| E1 | `variant3d/scripts/world3d_terrain.gd:66-67,90-97,100-115` | OBS: runtime `Image.load` of 320×320 splat; StandardMaterial3D, `roughness=1`, `TRANSPARENCY_DISABLED`, emission floor `:72,112-114` | Albedo path and material are the only terrain shading |
| E2 | `world3d_terrain.gd:122-132` | OBS: normals = central differences of `height[]` over `2*TILE_M`, one-sided at borders | Normal fidelity is bounded by the port height grid |
| E3 | `world3d_terrain.gd:139-172` | OBS: `_dump_from_game()` encodes **only** `map_w/map_h/height`; `terrain`/`tileblock` never reach the module | Dump classification data is unavailable at runtime even though it exists in the dump |
| E4 | `world3d_terrain.gd:175-202` | OBS: one flat full-map quad at `WATER_LEVEL=-0.25`, constant `Color(.19,.245,.255,.45)`, `roughness=0.35`, no texture/shader | Water is a single translucent wash over every low cell |
| E5 | `world3d_terrain.gd:295-317` | OBS: one vertex per cell at `(x+.5-w/2)*TILE_M`, UV `((x+.5)/w,(z+.5)/h)`, 0..1 over map | One splat texel ↔ one 2 m cell; no in-cell grain |
| E6 | `world3d_terrain.gd:210-243,346-347` | OBS: `_make_environment()` **is** defined and called from `build()` (V7-60) | Corrects AUDIT3D-03 P0-1: the donor light/sky rig is now wired; do not re-propose |
| E7 | `app/tools/heightmap_splat.py:4-6,68-71,360` | OBS: tool reads **no donor file**; samples port block PNGs; "No donor file read" | Art lineage is donor-derived one step removed |
| E8 | `heightmap_splat.py:191-208,230-297` | OBS: each block PNG is LANCZOS-resized to `n×n`; default `n=1` ⇒ a single mean RGB per cell; family/height neighbour blend `:244-249` | Direct cause of flat colour patches |
| E9 | `heightmap_splat.py:164-165` | OBS: dump `terrain` grid is parsed then **unused**; only `height`/`tileblock` drive output | Existing donor-classified water/rock data is discarded |
| E10 | `heightmap_splat.py:277-288,383-384` | OBS: A = normalised height; `--texels-per-cell` flag exists, default 1 | `N>1` regeneration needs no new art or tool change |
| E11 | `variant3d/assets/terrain/heightmap/splat_albedo.manifest.json:10-16,421-431` | OBS: seed 20261113, 320×320, sha `79f93c…`, `output_size [320,320]`, `texels_per_cell 1`, `water_block sandsea6` | Provenance and the exact knob to change |
| E12 | `app/shots/g32_dump.json` keys `seed,map_w,map_h,height,tileblock,terrain,blocked,meta.mask,meta.quality,meta.type` (decoded) | OBS: 320²; `height` ±2.964 m; `terrain` has 4 values (0:48102, 1:673, 2:46658, 5:6967) and **no value 3** (water); `tileblock` has **no 255** (water sentinel); 2,359 cells have `height < -0.25` | The dump itself proves the flat quad floods dry land |
| E13 | `g32_dump.json:meta.mask.file = "land/4pl_mask_land_176_gauss.png"`; donor `data\gen\terrainmasks\land\4pl_mask_land_176_gauss.tga`, app/variant3d copies of the PNG (measured) | OBS: all three are 320×320 RGB with only **4** ON pixels at (300,21),(31,29),(35,290),(294,295) = the four `meta.mask.starts` positions scaled by 320. INFERENCE: this mask is a start-marker bitmap, **not** a relief/forest/water class map | Rules out "just bind the donor mask PNG" as a texture-painting fix |
| E14 | donor `data\scripts\common.inc\generatemap.inc:322-347,353-387,544-570` | OBS: engine reads `fr/fg/fb` from a source bitmap; `(1,1,1)` = player start; R→plateau/hill/ravine, G→forest/stone, B→water; height = `cWaterHeight*(fb*(1+fr*3.5)) + terrain height` | Donor mask semantics are readable, but the shipped mask asset here carries only starts |
| E15 | donor `data\scripts\common.inc\texturemap.inc:16-27,29-31,34-38` | OBS: `cMaxHeight=2.96`, `cWaterHeight=-0.25`, `cWaterShoreHeight=-0.1`, colour constants 255/96/48 (relief) and 255/64/128/192 (forest/stone), `cPaintEnvironmentTextures`, `cSmoothForestBorders`, `cTextureTerrain` | Exact donor classification constants; 2.96 matches dump ±2.964 (E12) |
| E16 | donor `data\scripts\common.inc\loadtextureterrainfrombitmap.inc:4-6,20-40`; port `app\scripts\game.gd:1578-1583,1689`; assets `app\assets\terrain\structs\tile_lowground.png`, `tile_highground.png` | OBS: donor picks `tile_lowground`/`tile_highground` at `h<0.1`, `tex=R div 2`; port has both PNGs and applies the pass before dump | Donor detail variation is already folded into `tileblock`; the 3D splat only flattens it |
| E17 | donor `data\terrain\tiles\tiles.lib:1-56` (`TileBlockName`, `TileSize=64`, `Rows=2`, `Cols=2`); `tiles.mat:7,15`; donor `data\terrain\tiles\textures\grass1.dds` header 1024×1024 (measured); `copy_assets.py:160-199` | OBS: donor tile art is 1024² and carries tiling/sub-tile metadata; port `app\assets\terrain\blocks\grass1.png` is 1024×1024 | Full-resolution donor grain exists on disk; the splat throws 99.9% of it away |
| E18 | donor `data\terrain\ref\reftile.mat:6,17,30-37,122,148`; `reftilealpha.mat:30-33,139-140`; textures `alpha.bmp`, `alphavert.bmp`, `alphanull.bmp` | OBS: donor tiles blend via `Texture2Name=alpha`, `bmTransparency`, `tmModulate`-style wrapping `twBoth`; a separate `alphavert` variant exists for vertical faces | Donor blend/cliff masks exist as art; binding to a heightfield mesh is not proven |
| E19 | `app\scripts\world.gd:817-836,1012-1034` | OBS: 2D shipping path mirror-tiles the same donor block PNG to 1024 and lifts grain with `adjust_bcs(1,1.12,1)`; LRU 24 chunks | A working donor-art detail recipe already exists in the port |
| E20 | donor `data\water\water.lib:7-45`, `water.mat:7,35`, `data\water\textures\diffusewaves0-7.bmp` + `heightmapwaves0.tga`, `water.dev.vert:22`, `water.dev.frag:37,42-47,174,186-194,198-201,223-230` | OBS: donor water has wave/noise maps, `COAST_FADE=0.57`, `DEEP_FADE=1.07`, shallow/deep colours, 4-tap normals, foam and glints; `waveMap=diffusewaves0` | All donor water art and equations are readable |
| E21 | `app\scripts\world.gd:919-925,945-1010`; `app\shaders\water_overlay.gdshader:51-68,176-277`; `copy_assets.py:214-219` | OBS: 2D port already converted `diffusewaves0/2` to PNG, bakes a per-tile coverage/depth mask from `terrain==3` + `height_at()`, and runs the donor equations per frame | A donor-grounded water implementation exists to port, not to invent |
| E22 | `docs/.../G32_heightmap_world.md:30-34,205-216` | OBS: captured frame is a near-uniform dark olive trapezoid; donor-valid 40 m view luminance span 0.0059 | The flat look is measured, not assumed |
| E23 | `docs/.../AUDIT3D_03_terrain.md:91-120,138-151` | OBS: prior gaps (static albedo, flat water, no donor fog, no forest/stone paint) and its smallest-fix proposal | Baseline; this report refines it with dump/donor measurements |
| E24 | `docs/.../G34_heightmap_splat.md:80-97,166-171`; `V713_world3d_terrain.md:44-56,114-127` | OBS: tool smoke-tested `--texels-per-cell 2` (640²); A-channel/height blend and texel density left as open questions | Confirms the detail fix is a flag, not new code |
| E25 | donor `data\env\colors\colors.lib:20-40` | OBS: `Fog=60,100,150`, `FogStart=390`, `FogEnd=490`, `FogDepthFactor=0.8`, ambient/diffuse tables | Donor fog numbers are readable; port-unit applicability is not proven |
| E26 | `variant3d/config.json:38-41,71`; `variant3d/scripts/main.gd:694-701` | OBS: defaults (320², seed 20261113, land) match the dump, but no runtime comparison exists | Default is plausibly aligned; non-default silently drifts |

## 3. Findings — why the current 3D terrain reads as poor

**F1 — Albedo is a 320×320 colour lookup, not a terrain texture.** (E5, E8, E11, E17, E19).
Each 2 m cell gets one LANCZOS mean of a 1024² donor block; neighbouring cells blend only
inside a family or within 0.25 m of height. At donor-valid zoom a cell is tens of pixels wide,
so the player sees flat polygons of near-identical olive. The donor art that would supply grain
is present on disk in both donor DDS and port PNG form, and the 2D path already uses it. This is
the single largest, cheapest self-inflicted defect.

**F2 — The water quad ignores the dump's own classification.** (E3, E4, E12, E20, E21).
The dump has no water terrain cells (value 3 absent) and no water tileblock sentinel (255
absent), yet 2,359 cells sit below −0.25. A single translucent plane tints all of them; the
result is a constant washed band unrelated to the shoreline. Donor classification uses
`cWaterHeight=-0.25` **plus** a water mask channel (`fb`) and a shore threshold −0.1 (E15), and
the 2D port already bakes a continuous, bilinear-height-derived coverage ramp (E21). The 3D
path uses none of it.

**F3 — Relief looks flat mostly because of the source grid, not the mesh.** (E2, E12, E22).
±2.964 m across 640 m is under 1% grade; central-difference normals reproduce that faithfully.
Donor relief also uses separate `terrainmesh1..4.osm` props (G32 E22/G32 §3), which this module
does not own. Do not promise "donor relief" from a normals tweak: no donor heightfield normal
map or mesh LOD connector is readable.

**F4 — Forest/stone environment painting cannot be recovered from the shipped mask asset.**
(E13, E14, E15, E18). Donor `gMapMask` R/G/B classes are engine-computed from a source bitmap,
but `4pl_mask_land_176_gauss.*` in this repo is a 4-pixel start-position marker. The donor
painting step calls engine states `SaveEnvironmentToBitmap` / `LoadEnvironmentFromBitmap` /
`SmoothForestBorders` (texturemap.inc:340-359) — no readable texture list. Honest verdict:
UNVERIFIED / engine-side, not a data-availability fix.

**F5 — Static albedo has no seed/size guard.** (E3, E11, E26). `build()` decodes the *live*
height grid but loads a PNG baked from one dump. Any change to seed, size or map type keeps new
relief with old colours. The manifest already contains everything needed for a guard
(`input_seed`, `map_w/map_h`, `input_dump_sha256`).

**F6 — What is already fixed.** (E6). The V7-60 donor light/sky rig (`_make_environment()`)
is present and called at `world3d_terrain.gd:347`. AUDIT3D-03's P0-1 ("unwired rig") is closed
in the current file; only the port-tuned energies and the non-donor ProceduralSky remain
approximations.

## 4. Ranked donor-grounded recipe (visual impact per unit effort)

### P0-1 — Restore in-cell donor grain by regenerating the splat at N texels/cell
- **Donor grounding:** E17 (donor grass1.dds 1024²; `copy_assets.py:160-199` conversion),
  E19 (2D port mirror-tiles the same 1024² art), E8/E10/E24 (`--texels-per-cell` exists; N=2
  smoke-tested). No new colour, texture or constant is invented.
- **Smallest change:** re-run the existing tool `app/tools/heightmap_splat.py` against
  `app/shots/g32_dump.json` with `--texels-per-cell 4` (or 2 for a first probe), writing both
  `splat_albedo.png` and its manifest into `variant3d/assets/terrain/heightmap/`. In
  `world3d_terrain.gd::_load_png_texture()`, explicitly set the generated `ImageTexture` filter
  to LINEAR (do not let nearest filtering re-pixelate the N×N samples); `build()`'s
  `albedo_size` stat then reports the new size. No mesh/UV change: 0..1 UVs still map N texels
  per cell.
- **Expected visual effect:** grass/rock/dirt stop reading as uniform fills; close-range terrain
  gains the donor's authored mottling. Does not add new geometry and does not change silhouette.
- **Effort:** minutes; highest impact per unit effort in this list.

### P0-2 — Make water coverage follow the dump instead of flooding dry land
- **Donor grounding:** E15 (`cWaterHeight=-0.25`, `cWaterShoreHeight=-0.1`), E12 (2,359
  low-but-not-water cells, zero water cells), E21 (2D port's continuous height-derived
  coverage) and E20 (donor depth ramps 0.57/1.07).
- **Smallest change:** in `world3d_terrain.gd::_dump_from_game()`, also surface `game.terrain`
  (and optionally `game.tileblock`) to the module; in `_make_water(w,h)`, build one
  coverage/depth `ImageTexture` from those grids plus `game.height_at()`/the decoded height
  array, and bind it as the quad's alpha so dry cells contribute no water. Keep the quad's Y at
  the existing donor-cited −0.25; the *coverage* threshold, not the plane height, is what is
  missing. Skip creating the quad if coverage is empty.
- **Expected visual effect:** the wash disappears from the 2,359 mis-tinted cells; the shoreline
  follows the height contour rather than the tile grid. This is a correctness fix that removes a
  very visible artefact.
- **Effort:** small (one mask image + alpha binding).

### P1-1 — Port the already-transcribed donor water shader to the 3D quad
- **Donor grounding:** E20 (wave maps and exact constants), E21 (`app/shaders/water_overlay.gdshader`
  is a line-by-line donor transcription using `diffusewaves0.png`, already converted by
  `copy_assets.py:214-219`), E4 (current constant material).
- **Smallest change:** in `world3d_terrain.gd::_make_water()`, replace `StandardMaterial3D` with a
  `ShaderMaterial` using a spatial version of `app/shaders/water_overlay.gdshader`; reuse its
  uniforms and donor constants (`COAST_FADE=0.57`, `DEEP_FADE=1.07`, wave noise
  `diffusewaves0.png`, donor sun vector from `light.cfg:26-29`). Feed the P0-2 coverage/depth
  mask as its texture. Keep the 2D port's separate `water_level` (1.0) distinct from the −0.25
  terrain threshold (AUDIT3D-03 open question 3).
- **Expected visual effect:** animated waves, depth-tinted shallows, sparse foam/glints — the
  largest single "looks like the donor" jump for water, at medium effort.
- **Effort:** medium (canvas_item → spatial shader port), hence P1 not P0.

### P1-2 — Add a seed/size consistency guard before binding the albedo
- **Donor grounding:** E11 (manifest carries seed/size/sha), E26 (defaults match today), E3/E5
  (live relief vs baked colour), AUDIT3D-03:91-98.
- **Smallest change:** in `world3d_terrain.gd::build()`, read
  `res://assets/terrain/heightmap/splat_albedo.manifest.json` and compare `input_seed`,
  `map_w/map_h` and `input_dump_sha256` with the live config/dump; on mismatch, push a warning
  and fall back to the donor `grass1.png` block material (or block release until the documented
  `heightmap_splat.py` regeneration has been run). Surface the check result in `stats`.
- **Expected visual effect:** no silent whole-map colour/relief mismatch after a seed, size or
  map-type change. Affects correctness across configurations more than the default frame.
- **Effort:** small.

### P1-3 — Use the dump's `terrain` grid for water/shore block identity in the splat
- **Donor grounding:** E9 (`terrain` parsed but unused), E15/E16 (donor relief/height classes and
  oriented `sandsea*` shore selection in `texturemap.inc` cTextureTerrain block), E12 (water
  class absent in this dump).
- **Smallest change:** in `app/tools/heightmap_splat.py::build_splat()`, consult
  `dump["terrain"]` when assigning the water sentinel/shore family instead of the flat
  `--water-block sandsea6` default for every submerged cell; keep the existing family-gated
  neighbour blend. This changes only block *selection*, not colours.
- **Expected visual effect:** when water-bearing seeds are used, shore cells read as oriented
  sand/shore bands rather than one uniform underwater colour; for this dump it mainly removes
  a wrong assumption, not a visible change.
- **Effort:** small-medium.

### P2-1 — Donor fog from `colors.lib` (coordinate with TERRAIN2-03)
- **Donor grounding:** E25 (`Fog 60,100,150; FogStart 390; FogEnd 490; FogDepthFactor 0.8`),
  AUDIT3D-03:125 (no donor fog depth in 3D).
- **Smallest change:** in `world3d_terrain.gd::_make_environment()`, add the donor fog colour
  and linear range from `colors.lib` to the `Environment`. **Do not** treat the numbers as
  port-space metres: the overview camera in G32 sits at 600 m, so a 390–490 range may fog the
  entire diagnostic view. Mark as UNVERIFIED until an in-engine A/B.
- **Expected visual effect:** distance cue at donor-valid framing; risk of a washed-out full-map
  overview.
- **Effort:** small code, non-trivial verification.

### P2-2 — Donor alpha-blend / vertical-face masks: research only
- **Donor grounding:** E18 (`alpha.bmp`, `alphavert.bmp`, `bmTransparency`, `twBoth`).
- **Smallest change:** none implementable yet — first prove how donor binds these masks to the
  heightfield mesh. Do not bake `alphavert` into the splat on speculation.
- **Expected visual effect:** potentially donor-like forest/stone and cliff striations; today
  UNVERIFIED (F4).

### P2-3 — Hygiene: stale citations and unused splat A channel
- **Donor grounding:** E15 (`texturemap.inc:30` is readable) vs `world3d_terrain.gd:30-31,52,379`
  calling the −0.25 literal UNVERIFIED; E10 (A = normalised height, unused).
- **Smallest change:** in `world3d_terrain.gd`, correct those comments; optionally expose A as a
  wetness/rock-blend scalar in `_terrain_material()` — but do **not** treat the roughness bytes
  from `heightmap_splat.py:77-91` as donor data (they are admitted proxies, AUDIT3D-03 E24).
- **Expected visual effect:** no immediate visual change; prevents future agents from chasing a
  solved question and keeps the A channel available for a donor-grounded shader pass.

### P2-4 — Normals: do not tune for "more relief"
- **Donor grounding:** E2, F3; donor `hf.pvl.sm.vert` uses engine normals and there is no donor
  heightfield normal map. A wider stencil would be port art, not donor fidelity.
- **Smallest change:** none recommended; document the limitation in `stats.norms`.
- **Expected visual effect:** none guaranteed; the flatness is bounded by ±2.964 m over 640 m.

## 5. Honest UNVERIFIED list

1. **Donor height-grid → mesh connector and cell size in metres.** Only `terrainmesh1..4.osm`
   props are observed; `TILE_M=2.0` is a port constant (G32 §3, V713 §4, AUDIT3D-03 E12).
2. **Forest/stone environment painting.** Donor uses engine states
   `SaveEnvironmentToBitmap` / `LoadEnvironmentFromBitmap` / `SmoothForestBorders`
   (`texturemap.inc:340-359`); the shipped mask PNG is a 4-pixel start marker (E13). No donor
   texture list or painted result is readable here.
3. **Water geometry height vs shader level.** Donor `cWaterHeight=-0.25` is readable
   (`texturemap.inc:30`), but the 2D port deliberately uses `water_level=1.0`
   (`world.gd:965-968`) for `waveheight=clamp(WL*3-1.5,0,1)` (`water.dev.frag:174`). Which value
   drives the real 3D water plane is unknown.
4. **Donor fog ↔ terrain shader binding.** Donor fog constants are readable (E25) but
   `camera.cfg:59` disables depth fog in the gameplay camera (AUDIT3D-03 Q5); port-unit
   compatibility of 390–490 is unproven.
5. **Donor roughness/specular.** No donor roughness map exists; `ROUGHNESS_BY_FAMILY` is an
   admitted proxy (`heightmap_splat.py:77-91`). `light.cfg:17-24` specular and `reftile.mat`
   shininess are readable but unwired.
6. **Cliff/vertical-face art binding.** `alphavert.bmp` and `reftile.mat:122,148` exist, but
   donor striated-face placement on a smooth heightfield is not proven (G32 §7, G34 Q3).
7. **Tile sub-atlas semantics.** `tiles.lib:54-56` (`TileSize=64`, `Rows=2`, `Cols=2`) and
   `loadtextureterrainfrombitmap.inc` (`tex=R div 2`) are readable, but donor UV origin and
   mesh binding are not confirmed; do not invent a UV offset.
8. **Seed/menu reproducibility.** No runtime check proves current menu options reproduce
   `g32_dump.json` byte-for-byte (AUDIT3D-03 Q1). The sha match proves only the tool's input.
9. **Donor sky asset.** No donor sky DDS was found; `ProceduralSkyMaterial`
   (`world3d_terrain.gd:215-222`) is a port approximation (AUDIT3D-03 Q4).
10. **Render proof.** No GPU A/B frame was captured for any recommendation. All "expected
    visual effect" statements are predictions from static evidence, not observed results.
11. **Peer lanes.** TERRAIN2-01/02/03 reports were absent at write time; their findings may
    refine or contradict the donor-pipeline/texture/water framing here. This report was not
    held back for them.
