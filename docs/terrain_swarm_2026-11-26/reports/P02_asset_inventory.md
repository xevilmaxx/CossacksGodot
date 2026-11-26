---
id: P02
ticket: "TERRAIN-SWARM-2026-11-26 / P02 — donor-derived terrain asset inventory"
owner: "P02 (read-only port baseline worker)"
created: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_GODOT_JOB__NO_CODE_OR_ASSET_EDIT
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, "PORT APPROXIMATION", "NO_PARITY_CLAIM"]
scope: "Read-only enumeration of variant3d/assets/terrain/** and terrain-relevant parts of variant3d/assets/models/**, plus static grep of variant3d/scripts/**, shaders/** and tools/** for load sites. Prior art read first: docs/terrain_swarm_2026-11-26/{CHARTER,SWARM_BOARD}.md and docs/terrain_swarm_2026-11-25/reports/{A03_atlas_cells,E02_final_stage_assets,FOLD_02_path_audit,FOLD_03_donor_completeness,FOLD_05_all_folders,P02_draw_calls}.md."
outputs: "Exactly one repo file: docs/terrain_swarm_2026-11-26/reports/P02_asset_inventory.md. Throwaway probes live in %TEMP%\\opencode\\p02_*.py (outside the repo)."
parity_guard: "No donor GPU A/B frame was produced and no donor binary was opened or run by this worker. 'Donor-derived' denotes file/byte provenance inherited from cited prior reports, never a rendered-look claim. Every visual statement is UNVERIFIED."
tool_note: "[O] variant3d/tools/blender_py/PIL ships only cp313 natives (_imaging.cp313-win_amd64.pyd) and cannot import under the current Python 3.14 (ImportError: cannot import name '_imaging'). All Pillow measurements below use the installed Pillow 12.1.1 instead; Image.MAX_IMAGE_PIXELS=None was set only for the 16384x8192 atlas header/size read. No image in the repo was modified."
---

# P02 — Donor-derived terrain asset inventory (read-only)

## 0. Executive summary

1. **[O] The terrain asset tree is 2,358 files / 2,228,567,934 bytes (~2.23 GB).** It is dominated by four huge families: two 16384×8192 RGBA atlases (304.6 MB), the split-atlas parts (180.1 MB), 462 DXT5 building-ground decals in `decals_dds/` (635.0 MB) and their 462 PNG conversions in `decals_png/` (901.9 MB). All 2,358 files are tracked by Git (`git ls-files variant3d/assets/terrain` = 2358; tree is clean).
2. **[O] One family is fully wired into the current 3D renderer:** the atlas chain (single PNG primary → split parts fallback → block-array fallback), its two alpha masks, the season overlays, `patterns/donor_patterns.json` (via `C3PatternGen`), `masks/**` (via `C3MapGen`), `heightmap/splat_albedo.png` (fallback material only), `water_png/diffusewaves0.png` and `mountain_props.json` (via `world3d_relief.gd`, composed at `world3d.gd:614,650`).
3. **[O] Several large converted families are NOT consumed by the 3D renderer at all:** `decals/**` (6 DDS), `decals_dds/**` (462 DDS), `decals_png/**` (462 PNG — referenced only by the 2D branch `world.gd:775`), `dmask/**` (24 alpha ramps), `structs/smooth_summer.json`, `structs/water.json`, `prop_winter_materials.json`, `atlas_parts/**` (fallback only), and most of the 110 terrain-relevant model sids (ferns, reeds, flowers, plantain, gifts, christmas trees, 4 relief hills beyond the wired relief module). This is the principal "converted but unused" pool for a fresh donor-faithful terrain module.
4. **[O/D] The relief hills are the clearest ready-made win:** `terrainmesh1..4` OBJ + 2048² albedo + `mountain_props.json` are converted, registered in the manifest with `kind=relief`, and consumed by a wired module — but `world3d_terrain.gd:1515` still reports `"not_done": ["full 26-grid float32 tables", "mountain terrainmesh props", ...]`, i.e. the old terrain module does not own them. **[I]** A fresh module can reuse this exact asset set without new donor conversion.
5. **[O] Stale reference found:** `variant3d/tests/t_relief_props_qa.gd:30` points at `res://assets/terrain/terrainmesh_props.json`, which **does not exist**; the live file is `mountain_props.json` (`world3d_relief.gd:42`). **[U]** Whether that test currently fails was not checked (no Godot job permitted for this worker).
6. **[O] The 27 `winterN.png` blocks are unused by the summer atlas manifest and 77 blocks are unused by the winter atlas manifest** (`tile_index_atlas.manifest.json:unused_shipped_blocks`, `tile_index_atlas_winter.manifest.json:unused_shipped_blocks`). **[D]** Those are season-set complement entries, not lost art.
7. **No parity claim.** Every "wired" verdict below is a static code-path observation; no runtime `load()` was executed and no GPU frame captured. See §6 UNVERIFIED register.

## 1. Method and evidence classes

| Step | Instrument | Result |
|---|---|---|
| Whole-tree census | `os.walk` over `variant3d/assets/terrain/**` and `variant3d/assets/models/**`, `stat().st_size` | 2,358 terrain files; 1,910 model files; per-subdir counts in §2 |
| Image format/dimension | Pillow `Image.open()` (IHDR only, no full decode for the big atlas), `ImageStat`, `getextrema()`, raw first-16-byte header hex | §2 and §3 sample table |
| DDS format | Pillow DDS decoder on sampled files (DXT5, 1024² RGBA) | §3 |
| Duplicate/pixel check | `hashlib.sha256` on file bytes; `crop(cell).tobytes() == block.tobytes()` over 121 manifest cells | §3 F3 |
| Load-site grep | `grep`/Python token scan over `variant3d/scripts/*.gd`, `variant3d/shaders/*.gdshader`, `variant3d/tools/*.py`, `variant3d/tests/*.gd`; token set includes every folder/asset name | §4 table |
| Composition check | literal read of `world3d.gd:604-661`, `world3d_terrain.gd:573-659,1277-1284,1430-1446`, `asset_paths.gd` header | §4 |

**Label convention:** **[O]** = literal file:line, on-disk count, or decoded byte read this pass. **[D]** = deterministic consequence of observed code/data (counts, set differences, branch reachability). **[I]** = reasonable reading without an engine run. **[U]** = cannot be proven without Godot/a donor GPU frame. **PORT APPROXIMATION** = explicit port substitute, not donor truth. Prior-report donor facts are inherited with citation and are not re-verified here.

## 2. Exhaustive family inventory

All counts in this section are **[O]** from this pass. "Size" is total on-disk bytes of the folder, including `.import`/`.uid` sidecars where present.

| Asset family (`variant3d/assets/...`) | Files | Format / dimensions (Pillow) | Size (bytes) | Naming |
|---|---:|---|---:|---|
| `terrain/` root (loose) | 42 = 20 PNG + 20 `.import` + 2 JSON | 7×1024² RGBA, 13×256² RGBA | 13,149,142 | `grass1..10`, `dirt1`, `rock1..3`, `rockgrass1`, `ground1..3`, `grasssand1/2`; `mountain_props.json`, `prop_winter_materials.json` |
| `terrain/blocks/**` | 224 = 112 PNG + 112 `.import` | 110×1024² RGB, 2×256² RGB (`sand1/2`) | 174,228,604 | 112 stems: `grassN`10, `desertN`12, `winterN`27, `testN`26, `sandN`9 + `sandrockN`6 + `sandseaN`6, `rockN`9, `grass_*`6, `ground1` |
| `terrain/atlas/**` | 12 = 4 PNG + 4 `.import` + 4 JSON | 2×16384×8192 RGBA (summer+winter), `alpha.png` 512×256 **L**, `alphavert.png` 1024×512 **L** | 304,844,245 | `tile_index_atlas{,_winter}.{png,manifest.json}`, `alpha.png`, `alphavert.png`, `winter_aliases.json`, `desert_remap.json` |
| `terrain/atlas_parts/**` | 7 = 2 raw parts + 2 PNG + 2 `.import` + 1 JSON | `part000` 90,000,000 B; `part001` 89,912,941 B; mask copies L-mode | 180,141,102 | `tile_index_atlas.part000/.part001`, `split_manifest.json`, `alpha.png`, `alphavert.png` |
| `terrain/heightmap/**` | 3 = 1 PNG + 1 `.import` + 1 JSON | `splat_albedo.png` 1280² RGBA | 1,159,746 | `splat_albedo.{png,manifest.json}` |
| `terrain/masks/**` | 113 = 56 PNG + 56 `.import` + 1 JSON | all 320² RGB | 913,631 | 7 types × 8 masks: `land, nowater2, mediterranean, peninsulas, islands, continents, continent`; pattern `<N>pl_mask_<type>_<seed>_gauss.png` |
| `terrain/dmask/**` | 48 = 24 PNG + 24 `.import` | all 64² RGBA, RGB=(255,255,255), alpha varies 0..255 | 105,371 | `d_00.png … d_23.png` |
| `terrain/patterns/**` | 1 JSON | `donor_patterns.json`: 43 families, 282 patterns | 982,264 | single derived JSON |
| `terrain/structs/**` | 8 = 4 JSON + 2 PNG + 2 `.import` | `tile_lowground.png`/`tile_highground.png` 320² RGB (R-only; means 66.29 / 142.88) | 96,748 | `presets_summer.json`(124 names), `tileblocks.json`(245 entries), `smooth_summer.json`(10 rows), `water.json` |
| `terrain/decals/**` | 13 = 6 DDS + 6 `.uid` + `.gdignore` | 6×1024² DXT5 RGBA (sample `eurgold.dds`) | 8,389,765 | `eurgold`, `ruscend`, `ukrbard`, `ukrcend`, `ukrhoud`, `ukrstad` + `w` variants absent here |
| `terrain/decals_dds/**` | 933 = 462 DDS + 462 `.uid` + 4 `.lib` + 4 `.mat` + `.gdignore` | 462×1024² DXT5 RGBA (sampled 5, all 1,398,256 B) | 635,045,712 | `<nat><sid>d.dds` / `<nat><sid>dw.dds`; `decals_dlc{1..3}`, `decals_exp1` libs/mats |
| `terrain/decals_png/**` | 924 = 462 PNG + 462 `.import` | 430×1024² RGBA, 24×512² RGBA, 8×128² RGBA | 901,912,125 | same stems as `decals_dds/**`, PNG conversion |
| `terrain/deco_png/**` | 14 = 7 PNG + 7 `.import` | 1×1024² RGBA, 6×512² RGBA | 4,848,293 | `envfieldd`, `envfielddw`, `christmastreed`, `groundexp0..3` |
| `terrain/water_png/**` | 16 = 8 PNG + 8 `.import` | 2×256² RGB (`diffusewaves0/1`), 6×512² RGB (`diffusewaves2..7`) | 2,751,186 | `diffusewaves0..7.png` |
| **terrain total** | **2,358** | PNG 698, DDS 468, `.import` 698, `.uid` 468, JSON 14, raw parts 2, lib/mat 8, gdignore 2 | **2,228,567,934** | — |
| `models/**` (whole tree) | 1,910 = 299 OBJ + 299 MTL + 761 `.import` + 475 PNG + 73 JSON + 19 anim + 3 no-ext | OBJ+MTL Z-up; albedo PNG 512²–2048² | 339,918,009 | manifest 299 entries: building 129, unit 73, **env 93, relief 4**; buckets `obj/shared/terrain/`, `obj/shared/buildings/`, per-nation `obj/<nat>/…` |
| `models/**` terrain-relevant | **110 manifest sids** (+ mesh/MTL/sprite/skin companions) | see §3 model sample | not isolated | trees 23 (incl 4 stumps), rocks/stones 44, bushes 4, ferns 4, reeds 3, plantain 3, flowers 3, gifts 6, christmas 2, field/mill 11, mines 3, relief hills 4 |

**Model-tree layout [O].** `assets/models/obj/`, `tex/` and sprite roots are now split into nation buckets: `alg aus bav eng fra pie pol rus sco shared swe tur ukr` (verified `Get-ChildItem -Directory`); `asset_paths.gd` resolves mapped `assets.obj`/`assets.tex` first, legacy flat paths second. This supersedes the flat-tree description in `FOLD_05_all_folders.md` and `FOLD_02_path_audit.md` (which were pre-migration snapshots).

## 3. Byte-level samples and duplicate structure

All rows **[O]**, Pillow 12.1.1, raw header = first 16 file bytes.

| File | Header (hex, first 16 B) | Pillow | Bytes | Notes |
|---|---|---|---:|---|
| `blocks/grass1.png` | `89504e470d0a1a0a0000000d49484452` (PNG) | 1024² RGB | 1,355,043 | RGBA mean 76.0/82.5/30.4/255 |
| `blocks/sand1.png` | same PNG magic | 256² RGB | 107,243 | one of 2 un-upscaled blocks |
| `structs/tile_lowground.png` | PNG magic | 320² RGB | 11,692 | mean R=66.29, G=B=0 |
| `structs/tile_highground.png` | PNG magic | 320² RGB | 50,050 | mean R=142.88, G=B=0 |
| `dmask/d_00.png` | PNG magic | 64² RGBA | 3,449 | RGB=255; alpha extrema (0,255), mean 38.59 |
| `dmask/d_23.png` | PNG magic | 64² RGBA | 4,230 | alpha mean 216.74 |
| `masks/land/4pl_mask_land_0_gauss.png` | PNG magic | 320² RGB | 2,762 | mean 0.01/0.01/4.66 — **B channel carries the signal** |
| `water_png/diffusewaves0.png` | PNG magic | 256² RGB | 106,943 | grey (63.3/63.3/63.4) |
| `water_png/diffusewaves2.png` | PNG magic | 512² RGB | 405,187 | grey (198.8) |
| `deco_png/envfieldd.png` | PNG magic | 512² RGBA | 615,507 | alpha mean 148.1 |
| `decals_png/eurmard.png` | PNG magic | 512² RGBA | 442,091 | alpha mean 132.1 |
| `atlas/alpha.png` | PNG magic | 512×256 **L** | 55,242 | intensity mean 139.9 |
| `atlas/alphavert.png` | PNG magic | 1024×512 **L** | 167,954 | intensity mean 77.4 |
| `heightmap/splat_albedo.png` | PNG magic | 1280² RGBA | 1,150,428 | 4 texels/cell for 320² map |
| `decals/eurgold.dds` | `44445320…` (`DDS `) | 1024² RGBA | 1,398,256 | fourCC DXT5, Pillow-decoded |
| `decals_dds/algcend.dds` | `DDS ` | 1024² RGBA | 1,398,256 | mean RGBA 86.1/73.9/52.4/79.7 |
| `models/tex/shared/terrain/tree_fir.png` | PNG magic | 1024² RGBA | 989,832 | donor `fir1.dds` conversion |
| `models/tex/shared/terrain/rock_sea1.png` | PNG magic | 2048² RGBA | 6,531,253 | shore rock albedo |
| `models/tex/shared/terrain/field.png` | PNG magic | 512×256 RGBA | 48,365 | field crop cut-out |
| `models/tex/shared/buildings/mine_gold.png` | PNG magic | 2048² RGB | 5,306,512 | donor olive/beige cracked disc already baked in (cf. `world3d_entities.gd:190`) |
| `models/tex/shared/terrain/terrainmesh1.png` | PNG magic | 2048² RGBA | 7,758,343 | relief-hill albedo |
| `models/sprites_hi/shared/terrain/rock_sea1.png` | PNG magic | 512² RGBA | 255,090 | 2D bake companion |

**F1 — Root PNGs are pixel-duplicates of `blocks/`, not byte duplicates. [O/D]** `root/grass1..5.png` are 1024² RGBA while `blocks/grass1..5.png` are 1024² RGB; `tobytes()` of the RGBA conversions is **identical** for all 5, raw SHA-256 differs. `root/rock1.png` is 256² and **not** equal to `blocks/rock1.png` (1024²). `root/dirt1.png`, `grasssand1/2`, `ground2/3`, `rockgrass1` have no same-named block. **[I]** The root copies are the original donor-converted RGBA set; `blocks/` is the atlas-feed RGB set with a few renames/normalisations. This is a low-cost dedupe opportunity for a fresh module, not new art.

**F2 — The atlas really is the block art. [O]** Over the 121 cells with an existing block source, **115 are pixel-identical**; the 6 mismatches are exactly `sand1`, `sand2` and their 4 `FACE_BASE_REUSE` cells, which `tile_index_atlas.manifest.json` records as 256→1024 `NEAREST` upscales. The winter atlas matches **121/121** cells. This independently corroborates `A03_atlas_cells.md:18-23` (E01/E02) on a pixel-array basis.

**F3 — `dmask/**` is an unused alpha ramp family. [O/I]** All 24 files are 64² RGBA with constant white RGB and a graded alpha channel (means from 38.59 at `d_00` to 216.74 at `d_23`), i.e. a 24-step transparency ramp generated from donor `alpha.bmp` (`tools/copy_assets.py:222`). No runtime `.gd` references `dmask/`; the only mention is a historical comment at `world.gd:1085`. **[I]** A fresh module could reuse these as authored donor fade steps instead of inventing new alpha.

**F4 — Mask channel semantics are present in the bytes. [O/I]** `masks/manifest.json` states `R=relief, G=forest/stone, B=water, white=start`; the sampled `land/…_gauss.png` has signal only in B (mean 4.66) with R/G ≈0, consistent with a water-dominated land mask instance. **[U]** Channel meaning was not re-derived from donor TGA here (F04 territory).

## 4. Loaded-by / wired matrix

"Wired" = a static path from a composed runtime module (`world3d.gd`, `game.gd`, `water3d.gd`, `world3d_entities.gd`) reaches the asset. Tools/tests/data-only references do not count as wired.

| Asset family | Loaded by (file:line) | Wired in current 3D renderer? | Gap / note |
|---|---|---|---|
| `atlas/tile_index_atlas.png` (summer) | `world3d_terrain.gd:273,597-619,649`; `tile_atlas_loader.gd:66,80` (**MODE_SINGLE default**) | **YES — primary** | 179,912,941 B single texture; `tile_atlas_loader.gd:19-22` notes GitHub 100 MB caveat |
| `atlas/tile_index_atlas_winter.png` | `world3d_terrain.gd:277-278`, season table `:282`, override `:610-614` | **YES — season=winter** | index-preserving alias swap via `winter_aliases.json` |
| `atlas/alpha.png`, `alphavert.png` | `tile_atlas_loader.gd:485`; `world3d_terrain.gd:632-640`, `:690-691` | **YES** | intensity repacked R→A at `:662-675` for the V7-86 `.a` sampler |
| `atlas/winter_aliases.json`, `desert_remap.json` | `world3d_terrain.gd:279,440-463,596`; tests `t_season_overlay.gd:58-61` | **YES** | desert remap loaded every season, consumed by desert branch **[I]** |
| `atlas_parts/**` (split parts) | `tile_atlas_loader.gd:67,70,360`; fallback sampler `world3d_terrain.gd:651-655` | **FALLBACK ONLY** | 180 MB duplicated transport of the same atlas; not primary |
| `blocks/**` (112 PNG) | `tile_atlas_loader.gd:69` (**MODE_ARRAY fallback**, 112 blocks); `world3d_terrain.gd:251,1281` (`FALLBACK_BLOCK grass1`); `world.gd:1059` (2D) | **FALLBACK + 2D** | 27 winter blocks unused by summer atlas manifest; 77 unused by winter manifest **[O]** |
| `heightmap/splat_albedo.png` | `world3d_terrain.gd:250,1278-1284`; `_terrain_material()` `:724-728`; chosen at `:1441-1446` | **FALLBACK ONLY** | used only when `tiles_available and atlas_ready` fails; primary path is the V7-86 tile-index shader |
| `masks/**` (56 PNG) | `mapgen.gd:36` (manifest), `:162` (PNG), `:168` (missing-mask warn); `game.gd:1174` calls `C3MapGen.build` | **YES — sim mapgen** | feeds height/water/forest-stone base; not a renderer sampler |
| `patterns/donor_patterns.json` | `pattern_gen.gd:56-63,84`; `game.gd:746,1245` calls `C3PatternGen.build` | **YES — sim stamps** | 282 donor patterns drive relief/mine/forest stamps; `world3d_relief.gd` then renders stamps |
| `structs/presets_summer.json` | `game.gd:1775`; `world3d_terrain.gd:337,789,1264`; atlas manifest `index_dictionary` | **YES** | 124 donor tile ids, index 0 = `grass1` |
| `structs/tileblocks.json` (245) | offline `tools/import_donor_map.py:65,212`; no `.gd` reads it (A03 E04) | **NO (data/offline only)** | donor `rows/cols/anglex/anglez` fields unconsumed **[O]** |
| `structs/smooth_summer.json` (10 rows) | only tool comments (`tools/copy_assets.py:221`) | **NO** | converted smoothing probability table, no consumer |
| `structs/water.json` | no reference found in `scripts/**` | **NO** | `{"active":["DiffuseWaves0"],…}` never read |
| `structs/tile_lowground.png`, `tile_highground.png` | `game.gd:1956-1957,1966-1976` (2D texture pass) | **NO in 3D** | donor h<0.1 / h≥0.1 masks; 3D shader uses `alpha/alphavert` instead |
| `dmask/**` (24) | `world.gd:1085` comment only | **NO** | 24-step donor alpha ramp; unused |
| `patterns/**` (above) | see above | YES | — |
| `root/mountain_props.json` | `world3d_relief.gd:42`; module composed `world3d.gd:116,614,650` | **YES** | 30 sections / 112 records; placement = **PORT APPROXIMATION** (`world3d_relief.gd:21-35`) |
| `root/prop_winter_materials.json` | no reference found | **NO** | 79 winter material aliases, data-only |
| `decals/**` (6 DDS) | `tools/copy_assets.py` generation only | **NO** | donor building dirt plates |
| `decals_dds/**` (462 DDS) | no runtime reference; `.uid` sidecars | **NO** | 1.4 MB each; 635 MB dormant |
| `decals_png/**` (462 PNG) | `world.gd:775` (`res://assets/terrain/decals_png/%s%sd.png`) | **2D BRANCH ONLY** | **[U]** whether 2D path executes in 3D mode; 901.9 MB dormant for 3D |
| `deco_png/envfieldd|w.png` | `world3d_entities.gd:313-314,446-449` (availability **stats only**); `winter_field_decal.gd:67-68` (**unwired**); `world.gd:2573-2574` (2D) | **NO as 3D decal** | `:444-449` explicitly says 3D UV UNVERIFIED; field keeps own albedo + per-instance tint |
| `deco_png/{christmastreed,groundexp0..3}.png` | no runtime reference | **NO** | 6 of 7 `deco_png` files unused |
| `water_png/diffusewaves0.png` | `water3d.gd:97`; `water3d.gdshader:50-51` | **YES** | 3D water `wave_noise`; `water3d.gd:207` neutral fallback if missing |
| `water_png/diffusewaves1..7.png` | `world.gd:963-965` uses 0/1/2 (2D); tools only for 3..7 | **NO in 3D** | 6 of 8 wave sheets unused by 3D water |
| Models: trees (23), rocks/stones (44), bushes (4), stumps (4) | `world3d_entities.gd:178-184` pools + `asset_paths.gd`; manifest `assets` map | **YES (subset)** | only pool sids are placed: 18 tree + 4 stump + 5 rock + 4 bush; others only 2D sprites |
| Models: ferns 4, reeds 3, plantain 3, flowers 3, gifts 6, christmas 2 | manifest/OBJ/PNG/sprites present; **no sim placement reference** (grep over `game.gd`, `data.gd`) | **NO** | 21 converted env families with no 3D consumer — prime fresh-module pool |
| Models: `field` (1), `mil`+stages (10) | `world3d_entities.gd:1498-1519` (field tint/tex), `:257+` rotor, `add_building("mil")` | **YES** | field decal not used in 3D; mill rotor uses `anim/common/buildings/mill_rotor.png` |
| Models: `mine_gold/iron/coal` (3) | `_mesh_info(sid,"building")` (`world3d_entities.gd:1110-1160`), E02 §4 | **YES** | base OBJ only, no stages; disc already in albedo (`world3d_entities.gd:190`) |
| Models: `terrainmesh1..4` (4, `kind=relief`) | `world3d_relief.gd:16,42,51,86-92`; manifest `assets.obj` | **YES via relief module** | old terrain module still reports them `not_done` (`world3d_terrain.gd:1515`) |

**Composition evidence [O].** `world3d.gd:108-116` declares six module scripts plus `RELIEF_SCRIPT`; `:604-661` instantiates and binds terrain, entities, fx, fog, anim and relief. `water3d.gd` is instantiated inside terrain at `world3d_terrain.gd:1089-1105,1461`. `heightmap_world3d.gd` is a read-only reference file (no instantiation site; all mentions are comments — corroborates `P02_draw_calls.md:44`). `winter_field_decal.gd` likewise has no instantiation site.

## 5. Findings

### F5 — Four usable tiers of "converted but unused" assets [D/I]

Sorted by readiness for a **fresh donor-faithful terrain module** (no new donor conversion needed):

1. **Hills / mountains — ready.** `terrainmesh1..4` OBJ (2,177–2,662 verts; `p02_models_out`), 2048² albedos (7.76 MB each for mesh1), manifest `kind=relief` + `assets` map, and `mountain_props.json` with 30 pattern sections / 112 donor `Objects` records including exact Position/Up/Scaling literals. Consumer `world3d_relief.gd` is already composed. **[I]** A fresh module can adopt these as-is; selection rule remains **PORT APPROXIMATION**.
2. **Shore rocks / stones — ready, largely unplaced.** 44 rock/stone sids including `rock_sea1..6`, `rock_stonessea1..10`, `rock_smallstonesea1..6`, `rock_landstone1..4`, with 2048² albedos. Only 5 are in `POOL_ROCK` (`world3d_entities.gd:182`). **[I]** The remaining ~39 are converted shore/littoral variety with no placement consumer.
3. **Field textures / crop cut-outs — partially ready.** `field.obj` + 512×256 `field.png` + `deco_png/envfieldd|w.png` (512² RGBA alpha envelopes) + field growth state already mirrored in `world3d_entities.gd:2351-2417`. **[I]** The 3D placement deliberately ignores the donor decal UV; a fresh module could bind the existing envelopes instead of inventing new art, but UV mapping is **UNVERIFIED**.
4. **Water — ready but under-used.** 8 donor wave sheets; only `diffusewaves0` reaches the 3D shader (`water3d.gd:97`) while waves 1–7 sit idle (2 of them 256², six 512²). **[I]** A fresh shore/current module can select among them without conversion.

**Mines** are a fifth, smaller tier: 3 mine sids with 2048² albedos are wired as buildings; the donor olive/beige deposit disc is already baked into the albedo (`world3d_entities.gd:190`), so no separate terrain apron asset exists and none was invented.

### F6 — The two 180 MB atlases are the same art, twice [O/D]

`atlas/tile_index_atlas.png` (179,912,941 B) and `atlas/tile_index_atlas_winter.png` (124,463,306 B) are the summer/winter cell packs; `atlas_parts/tile_index_atlas.part000/.part001` (90,000,000 + 89,912,941 B) are a lossless byte split of the summer atlas (`split_manifest.json:verification.matches=true`). **[D]** A fresh module needs at most one transport; carrying both is redundant. **[U]** Whether the current single-mode load actually succeeds on this machine (180 MB decode under Godot) was not executed.

### F7 — Dormant decal mass is ~1.54 GB [O/D]

`decals/**` 8.4 MB + `decals_dds/**` 635.0 MB + `decals_png/**` 901.9 MB = **1,545,347,602 bytes**, with no 3D load site. `decals_dds` and `decals_png` are paired conversions of the same 462 donor `<nat><sid>d/w` building-ground plates. **[I]** This is the largest single recoverable footprint, but it is *not* terrain-surface art — it is building dirt plates — so a fresh terrain module should not be expected to consume it wholesale.

### F8 — Stale QA path [O/U]

`t_relief_props_qa.gd:30` declares `PROP_MANIFEST := "res://assets/terrain/terrainmesh_props.json"`; that file is absent (`Test-Path` = False). The live table is `mountain_props.json`. **[U]** Test outcome not checked (analysis worker submits no runner job). Flag to P03/COORD.

### F9 — No source file was edited [O]

`git status --porcelain -- variant3d/assets/terrain` and the model tree are clean; all probe scripts were written to `%TEMP%\opencode\p02_*.py`. Only this report was written into the repo.

## 6. Implications

1. **A fresh donor-faithful terrain module need not convert new donor art for hills, shore stones, fields, mines or water** — all five classes already have derived PNG/OBJ assets with provenance labels in the repo (§F5). The correct first action is to bind existing families, not to re-run converters.
2. **The legacy renderer and the fresh module can be separated cleanly at the asset boundary:** the wired set is atlas + alpha masks + patterns + masks + splat fallback + wave0 + relief table; everything else is dormant. A switch can prefer the new module without touching dormant files.
3. **Do not treat "file exists" as "feature implemented".** `world3d_terrain.gd:1515` still lists mountain terrainmesh props as `not_done` even though the assets and a consumer exist. No parity claim follows from inventory.
4. **Gate risk:** any migration that renames `mountain_props.json` or the model bucket paths must update `world3d_relief.gd:42`, `asset_paths.gd`, and the stale test constant together (FOLD-02 C1–C7 applies to the model resolver).
5. **Storage/transport decision needed** for the two atlases and their split parts (§F6) before a fresh module fixes a transport mode.

## 7. Risks

| # | Risk | Evidence | Label |
|---|---|---|---|
| R1 | Parity misreading: "converted" ≠ "looks like donor" — no donor GPU A/B exists | CHARTER §2/§6; this report §0 | [U] |
| R2 | 180 MB single atlas decode may fail on clone/limited GPU; fallback chain unverified at runtime | `tile_atlas_loader.gd:19-22,80`; `world3d_terrain.gd:619-622` | [U] |
| R3 | Winter atlas manifest labels cite donor paths second-hand (`DONOR_INDEX_CITED_SECOND_HAND`) | `tile_index_atlas_winter.manifest.json:labels` | [O] |
| R4 | Stale test constant (F8) could mask relief-props regression | `t_relief_props_qa.gd:30` | [O]/[U] |
| R5 | Model tree was reorganised into nation buckets; older reports describe a flat tree | `obj/`,`tex/` subdir listing; `asset_paths.gd` header | [O]/[D] |
| R6 | Pillow version mismatch: bundled `blender_py` PIL is cp313-only, measurements used system Pillow 12.1.1 | frontmatter `tool_note` | [O] |
| R7 | `decals_png` 2D branch may or may not execute in 3D mode — dormant 902 MB classified conservatively | `world.gd:775`; no 3D reference | [U] |
| R8 | Donor channel semantics (masks, dmask ramp) inherited from prior reports, not re-derived from donor bytes | `masks/manifest.json:note`; `tools/copy_assets.py:222` | [O]/[U] |

## 8. UNVERIFIED register

1. **[U]** No Godot run, no `load()`/`.import` verification, no FPS/capture. Every "wired" claim is static reachability only.
2. **[U]** Whether the three big atlas transports (single / split / array) actually resolve at runtime on this machine and which mode `current_mode` reports.
3. **[U]** Whether `decals_png/**` is loaded in 3D mode through the 2D compatibility branch (`world.gd:775`).
4. **[U]** Whether `t_relief_props_qa.gd` currently fails because of the stale `terrainmesh_props.json` path.
5. **[U]** Donor-derived provenance of every asset is inherited from prior reports; no donor file was opened this pass, so no donor byte was re-verified.
6. **[U]** Runtime engine-side selection of which `terrainmeshN` a stamp uses (`world3d_relief.gd:24-26`); yaw sign and metres-per-unit remain **PORT APPROXIMATION**.
7. **[U]** Exact visual consequence of any dormant asset on the current frame; no A/B frame exists.
8. **[U]** Whether `splat_albedo.png`'s fallback material is ever selected in a shipped run (depends on `tiles_available and atlas_ready`, `world3d_terrain.gd:1434`).
9. **[U]** Whether the 19 sidecar-less historical OBJs (FOLD-02/FOLD-05) are now imported after the bucket migration; not re-checked.

## 9. Open questions

1. **COORD:** for the fresh module, should the summer/winter atlas pair be kept (season parity) or collapsed to one transport plus alias dictionaries? (§F6)
2. **A03/A04 owners:** which dormant families should be bound first — shore rocks (39 spare sids), 21 unused env-prop families, or the 6 extra wave sheets? (§F5)
3. **P03/QA:** confirm and fix or intentionally retire `t_relief_props_qa.gd:30` (§F8).
4. **A05/QA:** define a capture that exercises the fallback branches so "wired" becomes runtime-proven rather than static.
5. **Owner:** should the ~1.54 GB dormant building-ground decal mass be retained in-tree or moved to an external asset store? Purely a storage decision; no visual consequence proven.

## 10. Claim register

| # | Claim | Evidence | Label |
|---|---|---|---|
| 1 | 2,358 terrain files / 2,228,567,934 bytes; 14 named subfamilies | `os.walk` census §2 | [O] |
| 2 | 698 PNG / 468 DDS with dimensions sampled by Pillow | §3 sample table | [O] |
| 3 | 121 atlas cells compared, 115 pixel-identical; 6 sand upscales; winter 121/121 | §F2 | [O] |
| 4 | Root grass1..5 are pixel-duplicates of blocks, byte-different | §F1 | [O]/[D] |
| 5 | Atlas+alpha masks+patterns+masks+wave0+relief table are wired; dmask/smooth/water.json/decals/unused env props are not | §4 matrix | [O]/[D] |
| 6 | `world3d_relief.gd` composed at `world3d.gd:614,650`; old terrain still says `not_done` | `world3d.gd:614,650`; `world3d_terrain.gd:1515` | [O] |
| 7 | `terrainmesh_props.json` absent; `mountain_props.json` is live | `Test-Path`; `world3d_relief.gd:42` | [O] |
| 8 | Model tree bucketed by nation; 110 terrain-relevant sids | subdir listing; manifest tally | [O]/[D] |
| 9 | 1.545 GB dormant building-ground decals with no 3D load site | §F7; §4 | [O]/[D] |
| 10 | Any visual/donor parity result | none | [U] |

## 11. Attestation

- **Read-only:** no `.gd`, `.py`, `.json`, `.import`, asset, manifest, config, test or Git state was modified. No file was copied from the donor; no donor binary was opened or executed. No Godot process or runner job was started.
- **One repo file written:** `docs/terrain_swarm_2026-11-26/reports/P02_asset_inventory.md`.
- **Labels observed:** OBSERVED / DERIVED / INFERRED / UNVERIFIED / PORT APPROXIMATION used throughout; no donor-parity claim.

*End of P02 report.*
