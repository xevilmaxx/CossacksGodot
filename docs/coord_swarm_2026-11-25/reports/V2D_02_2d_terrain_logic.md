---
id: V2D-02
title: "Shipping 2D port's logical terrain/decor features — SECONDARY helper for the 3D terrain swarm"
date: 2026-11-25
owner: V2D-02
status: DELIVERED__READ_ONLY__NO_CODE_EDITS
role: SECONDARY_EVIDENCE_ONLY
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
output: "docs/coord_swarm_2026-11-25/reports/V2D_02_2d_terrain_logic.md"
donor: "C:\\Games\\Cossacks 3 — NOT read by this agent; donor truth here is SECONDARY via cited reports"
labels:
  - OBSERVED_CURRENT_SOURCE
  - DERIVED_FROM_SOURCE
  - INFERRED_WITH_CAVEAT
  - SECONDARY_2D_EVIDENCE
  - NO_VISUAL_PARITY_CLAIM
guards:
  - "No source/asset/config/test/git edit; this file is the only write."
  - "No Godot job, no donor file read/executed/copied, no GPU A/B."
  - "2D evidence is SECONDARY to a direct donor read; it tells us what the port already LOGICALLY does, not what the donor looks like."
---

# V2D-02 — 2D logical terrain/decor features (SECONDARY helper)

## Goal

Give the 3D terrain workers a read-only inventory of the **logical** terrain/decor
features that the **shipping 2D port** (`app/`) already implements from the
donor: tile types, tile-index/blend logic, height→relief, shore/water handling,
tree placement, mine placement, and the small-map test pattern. Cite current
`path:line` so a 3D owner can decide which 2D ideas are worth translating
*logically* into `variant3d/`. All 2D evidence is labelled **SECONDARY**: it is a
port reconstruction, not an independent donor read. No visual parity is claimed
anywhere in this report.

## Sources

**Read directly this session (`app/` shipping 2D, OBSERVED):** `scripts/mapgen.gd`,
`scripts/pattern_gen.gd`, targeted ranges of `scripts/game.gd` (generation,
tileblock, shore/cliff, smoothing, resource realisation), targeted ranges of
`scripts/world.gd` (water overlay, block compositor, shore bed, face collar,
forest/resource draw, chunk bake), `shaders/water_overlay.gdshader`,
`tools/copy_assets.py`, `tools/heightmap_splat.py`, `tools/terrain_sample_shot.py`,
`tests/t_map_variety.gd`, `tests/t_shore_smoke.gd`, `tests/t_water.gd`,
`shots/terrain_sample.json`.

**Read directly for parity comparison (`variant3d/`, OBSERVED):** `scripts/world3d_terrain.gd`,
`scripts/water3d.gd`, `scripts/world3d_entities.gd`, `scripts/world3d_fog.gd`,
`tests/t_smallmap_terrain.gd`, `tests/fixtures/small_map_64.json`.

**Orientation docs (SECONDARY, cited as such):** `COMPLETENESS_02_vs_2d.md`,
`TERRAIN2_01_donor_pipeline.md` … `TERRAIN2_06_tileindex_architecture.md`,
`TERRAIN_SMALL_maps.md`, `docs/audit/TERRAIN_PORT_{ASSETS,DECOR,HILLS,RENDER}.md`,
`docs/audit/TERRAIN_BEAUTY_TRIAGE.md`, `FIXTERRAIN_visual_quality.md`. These
contain older line numbers in places; every port claim below was re-checked
against current source. Where a doc is stale, this report says so.

**Labels:** `OBS` = read directly from the cited current `path:line`;
`DERIVED` = consequence of cited code; `INF` = reading with a stated caveat;
`SEC` = taken from an orientation doc without re-reading donor bytes.
"secondary" applies to the entire 2D lane by charter of this task.

---

## 1. 2D logical feature table (all 2D evidence SECONDARY)

| # | Logical feature (donor origin) | Current 2D evidence `path:line` | Observed mechanism | Fidelity / where docs say 2D is imperfect |
|---|---|---|---|---|
| F1 | **Height mask → relief → water classification** (donor `generatemap.inc`, `texturemap.inc`). | `app/scripts/mapgen.gd:1-9` (donor semantics comment), `:25-30` (constants `-1.1 / 2.964 / 1.3173 / -2.964 / -0.25 / -0.1`), `:51-61` deterministic mask pick, `:137-188` mask decode + `height[i] = -1.1*(b/255)*(1+3.5*r/255) + relief(r)`, `forest[i]=g/255`, `:189-190` water count, `:191-208` 3 coastal smoothing passes (quality 1/2/3). | OBS. R channel classifies plateau/hill/ravine, G forest, B water; pure-white start pixels skipped (`:173-175`). | **Donor-faithful formula**, but `relief()`'s `±12` tolerance and `0.5*r/255` fallback are port-authored (`mapgen.gd:67-72`; `TERRAIN_PORT_HILLS.md:62-65` SEC). Shipped masks are `*gauss.png`, so discrete plateaus/ravines rarely appear (`TERRAIN_PORT_HILLS.md:82-84` SEC). |
| F2 | **Tile types / terrain[] grid** (donor per-cell terrain roles + collision tags). | `app/scripts/game.gd:1050-1064` (`h<-0.25`→type 3 water+blocked; `-0.25..-0.1`→type 4 wet sand; else 0 meadow), `:1098-1122` collision pass cardinal `|dh|>0.5` / diagonal `>0.55` → type 5 rock+blocked, `:1140-1143` road between starts, `:740` forest paint type 2, `:530-560` worked-ground paint type 1. | OBS + DERIVED. Five logical roles: 0 meadow, 1 dirt/road, 2 forest, 3 deep/shallow water, 4 sand collar, 5 cliff/rock. | **Donor-grounded thresholds**; the sand collar is deliberately the LAND-side `-0.25..-0.1` strip so water cells stay covered for the shader (`game.gd:1065-1075`). Exact collision constants are donor-readable (`TERRAIN2_01` SEC). |
| F3 | **Stamped relief (plateau/hill/mountain/ravine)** (donor `dogenerate.inc` stage 9). | `app/scripts/pattern_gen.gd:15-36` donor frequencies + recipes, `:474-549` separate relief occupancy grid + `needed=floor(W*H*freq)`, `game.gd:858-981` donor footprint cells → height: ravine gully profile `wall*ends` (`:954-963`), plateau/mountain `f=(edge-d)/rim` (`:965-973`), clamp to `[-2.964,+2.964]` (`:981`), `:1076-1080` stamps applied **before** collision, `:1087-1097` quantised plateau cap. | OBS. Footprints are exported donor `.pattern` masks; start keep-clear ring flattened before collision (`:865-880`). | **Shape donor-faithful (mask), profile PORT ADAPTATION** (`game.gd:859-864` explicitly says donor per-cell height fields are undecoded). `TERRAIN_PORT_HILLS.md:78-88` SEC still describes the pre-fix round domes; current source uses stamped footprints. |
| F4 | **Tile-index buffer (`tileblock`) / donor preset + smoothing chain** (donor `texturemap.inc`, `smoothtiles.inc`, `loadtextureterrainfrombitmap.inc`). | `game.gd:1409-1419` loads `presets_summer.json` + `smooth_summer.json`; `:1610-1621` mine aprons first; `:1632-1678` base index per terrain role (roads `ground1/test2/test3` `:1639-1648`; rock families `:1660-1672`; water `BLK_WATER` `:1657`); `:1679-1682` shore/cliff + **3-pass** `_smooth_tilemap`; `:1683-1689` detail pass; `:1690-1692` forest-border stamp; `:1696-1698` final mine authority. Exact passes at `:1787-1876`, detail at `:1571-1605`, borders at `:1878-1890`. | OBS. One uint8 per cell; index→name dictionary from donor preset order; weighted pair smoothing from donor cfg. | **Donor-faithful reconstruction**; random `test7/8/9` meadow speckles were deliberately removed because they checkerboarded (`game.gd:1624-1631`). The port *computes* this data fully — the historical 2D failure was that the renderer discarded it (`TERRAIN_PORT_RENDER.md:84-91` B1/B2 SEC, now fixed in current source). |
| F5 | **8-sector shore/cliff orientation** (donor `texturemap.inc:426-511,557-609`). | `game.gd:1708-1737` shore: `dx=lh-rh, dy=th-bh`, `atan2`, fold `dy<0`, `+180`, 8×45° sectors → `sandsea1/5/6`; `:1739-1772` cliff: `rock4/7/1/3` by aspect, `|h|>2.7→rock8`, `>2.4→rock4`, `<0.1→none`; `:1774-1785` applies to terrain roles 4/5. | OBS. | **Literal donor thresholds**; winter aliases applied at render time (`world.gd:1157-1172`, `game.gd:1427-1478`). `rockNvf/vs` *face promotion* is not written by the port generator (`TERRAIN2_06:38,85` SEC). |
| F6 | **Terrain texture / blend compositing** (donor tiled block art + alpha atlas). | `world.gd:1012-1034` `_block_img`: load donor block PNG, mirror-tile to 1024, `adjust_bcs(1,1.12,1)`, LRU 32; `:1039-1042` 64 px per 2 m cell; `:1086-1093` alpha-mask uses **alpha** channel (not red); `:1179-1209` rank distinct block names per chunk; `:1218-1253` exact per-cell coverage + bilinear feather + wrap-crop + `blend_rect_mask`; `:1543-1581` base = chunk-dominant donor block, ≤6 distinct blocks; `:1583-1628` role overlays (dirt/forest single crop; sand `sandsea*` with alpha 0.55/falloff 1.7; rock per-cell; water bed); `:1668-1679` bilinear supersample resolve; `:1691-1715` real 1-texel/cell LOD using sampled donor block centres. | OBS. Distinct donor named blocks are actually drawn at full grain now. | **Donor art, port compositing approximation.** `TERRAIN_PORT_RENDER.md:57-96` SEC documents the earlier one-grass/role-wash state; `TERRAIN_BEAUTY_TRIAGE.md:56-60` SEC marks B1a/B1b DONE. `TERRAIN_SMALL_maps.md:152-159` SEC reports a repeated "maze"/stepped tile pattern at 64² from data-level tile concentration — an art/data limitation, not a shader bug. |
| F7 | **Shore substrate / face collar** (donor rock face art; wet-sand wash). | `world.gd:1320-1387` `_shore_substrate`: 3-pass shore-distance relaxation, pale `#BDBDA9..#C3D1CA` with `sandsea6` grain within ~1 tile and depth ≤0.48, deep teal offshore, muted ground on land; `:1396-1532` `_face_collar`: render-only slope magnitude threshold **0.25** (below the 0.5 collision threshold), `FACE_LIT/FACE_SHADOW`, `rock8` fill + stretched `rock1` flutes + ≤3 px `grass1` rim; no `terrain[]`/`blocked[]`/RNG writes. | OBS. | **PORT ART with donor-derived art sources.** `world.gd:1389-1396` says it exists because donor rock is 17.3–17.9% of frame vs port 2.3–3.7%; making more cells rock would shrink buildable land. `TERRAIN2-01:392-393` SEC says exact face-tile promotion is ENGINE/UNVERIFIED. |
| F8 | **Animated height-aware water** (donor `water.dev.vert/frag`, `water.lib`). | `world.gd:911-938` loads 3 donor wave sheets (`diffusewaves0/1/2`); `:945-1010` one full-map canvas overlay with 4 samples/tile mask: R=`smoothstep(-0.10,0.15, WATER_LEVEL-height_at)`, G=`depth/1.07`, B=`depth/0.57`, dry land guard `:996-997`; `sync()` advances `time` per frame (`:157`, shader `:973`); `water_overlay.gdshader:50-68` donor literals (`0.57/1.07/0.1/0.01/170/120/30`, colours), `:70-100` explicitly calibrated **port-art** constants, `:14` reflection excluded; `world.gd:965-968` `water_level=1.0` is a port choice distinct from `-0.25`. | OBS. | **Donor equations + calibrated port art.** `TERRAIN2_03:127-137` SEC calls the 2D file a "near-verbatim donor equation set" but warns not to copy the calibrated constants as donor. `t_water.gd:11-15` is **stale** — it still says the check fails on a static wave crop; current source has the shader. |
| F9 | **Tree placement / forest look** (donor `forest_*` pattern families + `envscales.cfg`). | `pattern_gen.gd:71` scale `s=map_w/160`, `:407-465` near-start 1 pine stamp/start + 9 weighted forest families with **own** occupancy grid and density falloff for ≤160 maps (`:455-461`); `game.gd:705-740` scaled donor cells → filled convex core disc with 7-tile start keep-clear; `:752-777` wood nodes at 30% per cell, cap 14, avoid quarry/mine nodes; `world.gd:2391-2448` deterministic hashed species/size/yaw/flip trees + understory, `:1894-2072` per-chunk forest bake; `:2751-2773` harvestable tree draw with size buckets and foot-anchored yaw. | OBS + DERIVED. Harvestable wood and decorative forest detail are separate layers; positions are stamped from donor masks, visual jitter is position-hash (no sim RNG). | **Placement donor-derived; visuals PORT APPROXIMATION.** `TERRAIN_PORT_DECOR.md:128-144` SEC (G1–G13) still reports 3 static billboards/no sway/no yaw — those specific gaps are now mitigated in current source (`world.gd:2370-2382`, `2751-2773`), but there is still no time-sway and understory is sprite-based, not donor mesh. |
| F10 | **Mines placement** (donor `SetupMines`: 3 ore families × 3 rings × rejection sampling). | `pattern_gen.gd:11-21` documents that ore is **not** placed in `mapgen.gd`; `:232-277` count-preserving RNG replay; `:279-405` donor-style clusters (per-start guaranteed one-of-each in a 6..14 tile band, 120° preference, map-wide richness-scaled clusters); `:551-719` final authority relocates the *same* stamps to guarantee every start gold+iron+coal and zero footprint intersection; `game.gd:808-842` realisation nudges blocked centres to open ground, `_add_res`, paints terrain=1, clears trees; `:1164-1178` richness ore delta; `:1251-1360` final per-start service net on snapped starts. | OBS. All draws use dedicated RNG streams so downstream terrain RNG stays byte-identical. | **Donor algorithm + port fairness layout** (explicitly `INF` for per-count deltas: `game.gd:1180-1182`). `TERRAIN_PORT_DECOR.md:83` SEC describes stumps as resource flags; current source keeps that. `world.gd:2643-2694` strips a port-bake olive disc from mine markers — a port artefact, not donor art. |
| F11 | **Fields / crop visuals and season art** (donor field decals, winter tile set). | `world.gd:2529-2539` `envfieldd/w` decal load, `:2541-2633` four stages from `game.field_state()/field_growth01()` (growing/ripe/depleted/regrowing, timer bar); `game.gd:1427-1478` winter alias table + `:1702-1706` per-cell `winter_tile_names`; `world.gd:1143-1172` winter map consumes those names, winter tint reduced from 0.34 to 0.10 (`:1121-1132`). | OBS. | **Donor art names, port mapping.** `TERRAIN_PORT_ASSETS.md:78,133` SEC called winter art "unwired" — current source wires it; the number→name alias is still a port mapping (`winter_variant` inference at `game.gd:1421-1426`). `TERRAIN_PORT_DECOR.md:141` SEC called crops procedural sticks; current source uses decals with stalk fallback. |
| F12 | **Small-map generation for tests** (port test tooling, not a donor feature). | `tests/t_map_variety.gd:52-60` sets `Data.MAP_W/H` in-process and calls `game.setup()`; `:213-236` compares `nowater2` vs `islands` water fraction at 160² and asserts a **non-square 110×90** map resizes all arrays; `tools/terrain_sample_shot.py:42-81` 128² sample config + seed candidates + real-renderer gate; `:209-266` headless `--config` + `--dump-map` + percentage gates (water≥5%, forest≥4%, rock≥1%); `shots/terrain_sample.json:11-18` 128² overlay; `tests/t_shore_smoke.gd:56-111` chooses the worst shoreline chunk and asserts non-flat + two-bake determinism; `t_water.gd:120-168` grid scan + blocked check + sim soak. | OBS. | Test-only; explicitly **not** a full-map beauty claim (`terrain_sample_shot.py:46-56`). `TERRAIN_SMALL_maps.md:49-51` SEC explains why 128² (not 64²) is used for readably stamped forests. |

---

## 2. 2D-logical-feature → 3D-equivalent parity matrix

`variant3d/` read-only. "SHARED" below is independently corroborated by
`COMPLETENESS_02_vs_2d.md:22-32,54-89` (SEC): `mapgen.gd`, `pattern_gen.gd`,
`game.gd`, `nav.gd` are byte-identical between `app/` and `variant3d/`.

| 2D logical feature | 2D implementation (SECONDARY) | 3D current equivalent (OBSERVED) | Parity verdict | Worth translating logically into 3D? |
|---|---|---|---|---|
| F1 mask→height→water/shore classification | `mapgen.gd:25-30,186-208` | `variant3d/scripts/mapgen.gd` byte-identical; consumed by shared `game.gd` | **FULL (SHARED)** | Nothing to translate. Preserve byte identity; any change breaks seed dumps. |
| F2 terrain[] roles, collision tags, relief stamps | `game.gd:1050-1122,858-981` | `variant3d/scripts/game.gd` byte-identical; `_shape_stamp_relief` / collision pass identical | **FULL (SHARED)** | No. The sim's logical terrain is already identical. |
| F3 stamped relief visual cue | `world.gd:1653-1666` (relief tint from `height_at`, gated off for `plains`) | `world3d_terrain.gd:688` mesh normals from `height[]`; no season/relief shading path | **PARTIAL** — geometry shared, visual cue 2D-only | **Yes, low priority and explicitly PORT ART**: a render-only slope-tint layer can make relief legible without touching shared data. Gate on `render_mode`, never on `terrain[]`. Note 3D tile shader is `unshaded` (`FIXTERRAIN_visual_quality.md:77-80` SEC). |
| F4 tile-index chain (`tileblock`) | `game.gd:1610-1699`, exact 3-pass smoothing | shared `game.gd` producer; `world3d_terrain.gd:408-491` decodes, `:691-708` UV2.x=id/UV2.y=face, `:731-747` binds `ShaderMaterial` | **FULL data / wired render** | No new generation logic. Keep consuming live `tileblock` rather than a baked splat (`world3d_terrain.gd:742-746` fallback already labelled approximation). |
| F5 per-cell named-block compositing (full donor art) | `world.gd:1012-1034,1218-1253,1543-1581` | `world3d_terrain.gd:221-283` atlas + mask load, `:303-326` tile-index material, shader uses eye-plane UV and alpha/alphavert masks | **EQUIVALENT BY DIFFERENT MEANS**: 2D CPU composite of 1024² crops; 3D GPU atlas | **Yes, as an audit idea**: verify 3D atlas cell→name mapping matches 2D `_art_name` (`world.gd:1157-1165`) including winter names; reuse the 2D per-cell coverage rule as a shader-side transition mask rather than copying the CPU baker. |
| F5b oriented shore/cliff tiles | `game.gd:1708-1785` | same shared producer; 3D renders those ids from the atlas; `_face_mode_at` `world3d_terrain.gd:360-387` derives 0/1/2 face from donor slope | **PARTIAL**: ids present, face promotion is `PORT APPROXIMATION` (`world3d_terrain.gd:691-696,813-816`) | **Yes, highest terrain value**: translate 2D's render-only face collar (`world.gd:1396-1532`) as a *separate* labelled face pass using `rock8`/`rock1` donor art; do **not** rewrite `tileblock`. |
| F6/F7 wet-sand bed + waterline wash | `world.gd:1320-1387` (sandsea6 grain, shore-distance relaxation) | `water3d.gd:138-262` donor-equation shader, `height_tex` via `bind_height_grid`; no shore-grain substrate pass | **PARTIAL** — 3D is height-aware but visually plainer at the waterline | **Yes**: feed a 1-tile shore-distance/grain mask into the 3D water shader; keep donor `0.57/1.07` constants from `water3d.gd:22-23`. |
| F8 animated water | `world.gd:945-1010` sub-tile coverage mask + `water_overlay.gdshader` (donor equations, port-calibrated colours) | `water3d.gd:19-29,138-233` donor literals + `water3d.gdshader`, `time` in `_process` (`:95-99`); reflection disabled (`water3d.gd:168`) | **EQUIVALENT STRUCTURE, DIFFERENT TUNING**: 2D has calibrated shallow bed, 3D keeps donor pre-gain colours | **Selectively**: reuse the 2D *coverage-mask bake idea* (4 samples/tile, `world.gd:984-999`) and the shore wash; do **not** copy `SHALLOW_LIN`/`FOAM_GAIN`/`SLOPE_GAIN` (`water_overlay.gdshader:77-100`) as donor. |
| F9 trees / forests | `pattern_gen.gd:407-465`, `game.gd:705-777`, `world.gd:2391-2448` + bake `:1894-2072` | shared placement; `world3d_entities.gd:113-118` pools, `:1269-1315` position-hash sid pick + `add_resource`; no understory pass | **FULL placement / PARTIAL visuals** | **Yes for detail only**: translate the position-hashed size/yaw/flip buckets (`world.gd:2370-2382`) into instance transforms; optionally add sparse donor-mesh understory. No sim RNG. |
| F10 mines | `pattern_gen.gd:279-405,551-719`; `game.gd:808-842,1251-1360` | shared placement; `world3d_entities.gd:1275-1276` `mine_<ore>` meshes, `:1294-1315` batched instances | **FULL placement / visual simple** | No logic to translate. Optionally reuse the 2D "worked ground apron" idea as a tile-index override (already in shared `game.gd`, so present). |
| F11 fields / season art | `world.gd:2529-2633` field decal + 4 stages; winter names `:1143-1172` | `world3d_entities.gd:1465-1528` field stage tint/scale from **same** sim methods; donor decal paths recorded but 3D UV `UNVERIFIED` (`:218-220,151-153`) | **PARTIAL, better than SEC docs claim** (`COMPLETENESS_02_vs_2d.md:88` SEC is stale for fields) | **Yes, small**: port 2D's stage-specific decal/tint mapping if 3D UV mapping can be measured; otherwise retain instance-colour approximation with the existing label. |
| F12 small-map tests | `t_map_variety.gd`, `terrain_sample_shot.py`, `t_shore_smoke.gd` | `tests/fixtures/small_map_{64,128}.json`, `tests/t_smallmap_terrain.gd`, `tools/smallmap_capture.py` already exist; 64² probe 21/21 (SEC `TERRAIN_SMALL_maps.md:99-121`) | **EQUIVALENT HARNESS, slightly narrower 3D coverage** | **Yes**: add the 2D-style non-square 110×90 case and seed-scan percentage gates to 3D fixtures (§3). |

**Derived conclusion:** the 3D port already inherits *all logical generation*
because `game.gd`/`mapgen.gd`/`pattern_gen.gd` are byte-identical SHARED. The
2D side's extra value is **presentation logic** that the shared sim never owned:
per-cell block compositing, shore-grain substrate, render-only face collar,
height-derived water coverage mask, hashed prop variety, and a mature small-map
test discipline. None of it requires changing shared data.

---

## 3. Reusable small-map test approach

**What 2D does (OBS):**

1. **In-process size override for unit tests.** `tests/t_map_variety.gd:52-60`
   sets `Data.MAP_W/MAP_H/RANDOM_SEED/MAP_TYPE` and calls `game.setup("skirmish")`;
   no config file needed. `:226-236` verifies a **non-square 110×90** map resizes
   `terrain`, `blocked`, `tileblock` to 9900 cells — a cheap edge-case guard that
   3D square-only fixtures do not cover.
2. **Config overlay + real game boot for visual tests.** `tools/terrain_sample_shot.py:42-81`
   uses a minimal `shots/terrain_sample.json` overlay (`shots/terrain_sample.json:11-18`:
   128×128, hills, rich, seed 20261113, AI off) through the one legal Godot door
   (`godot_runner.py`, `:92-117`), runs a headless **seed scan** (`--config` +
   `--dump-map`, `:209-216`) and decodes base64 grids to percentage gates
   (`:243-259`), then a windowed capture rejected unless 1280×720, >100 KB and
   multi-luma (`:76-81`). SECONDARY note: `tests/t_water.gd:11-15` still describes
   the obsolete static-water baseline — do not treat that header as current.
3. **Deterministic local probes.** `tests/t_shore_smoke.gd:56-111` picks the
   worst shoreline chunk, bakes twice and asserts byte-identical output + >8
   distinct colours; `tests/t_water.gd:120-168` scans the grid, checks sand ring,
   blocked water and a 30 s sim soak.
4. **Why 128² rather than 64²:** `terrain_sample_shot.py:49-51` —
   `pattern_gen.gd` floors stamp counts at `maxi(1, base*area_scale)`, so at 64²
   every family gets exactly one stamp (no readable forests); at 128² counts are
   5–8 per family. SEC cross-check: `TERRAIN_SMALL_maps.md:49-51,101-121`.

**What 3D already has (OBS / SEC):** `variant3d/tests/fixtures/small_map_64.json:10-15`
and `small_map_128.json` are minimal overlays; `config.gd` merges them over
`res://config.json` (`TERRAIN_SMALL_maps.md:33-41` SEC). `t_smallmap_terrain.gd:1-20,42-86`
boots the real `main.tscn` with `--config` + test-only `--screenshot`, checks
21 counts (mesh vertices/triangles/UV2, tile index range, face histogram,
atlas grid, shadow-disable gate, water module), writes result JSON to `user://`,
and requires a separate stderr scan for `SCRIPT ERROR`s.

**Recommended reuse for 3D piece tests (no code written here):**

- Add a **110×90 non-square fixture** alongside 64²/128² and assert
  `w*h` vertices, `(w-1)²*2` triangles, UV2 count and tile-id bounds.
- Add **seed-scan percentage gates** from `terrain_sample_shot.py:57-61`
  (water/forest/rock share) to choose a readable 3D sample seed before a GPU
  capture; keep them sample-only, not full-map beauty gates.
- Add a **two-bake determinism + non-flat colour** assertion for any new 3D
  face/wash layer, mirroring `t_shore_smoke.gd:95-111`.
- Keep the 64² probe's **shadow-disable and water-module checks** as a regression
  gate; the dark bands are height-driven water, not shadows
  (`TERRAIN_SMALL_maps.md:27-29,160-165` SEC).
- Keep the real-renderer gate: reject 800×600 CPU fallback frames
  (`terrain_sample_shot.py:21-22,78-81`).

---

## 4. Recommendations (which 2D ideas to translate, logically, into 3D)

1. **P0 — treat `game.gd` as the single logical truth.** All generation logic is
   SHARED; any "fix" to terrain types, relief, mines or trees must stay in the
   shared file or be render-only in `variant3d/`. This is the strongest result of
   the parity matrix and prevents duplicate work.
2. **P1 — translate the 2D shore/face presentation as a labelled render pass.**
   `world.gd:1320-1387` (graded sandsea wash keyed off shore distance + depth)
   and `:1396-1532` (render-only `rock8`/`rock1` face collar with a visual
   threshold below collision) give 3D a donor-art-grounded way to improve cliff
   and waterline legibility without touching `terrain[]`/`blocked[]`. Label as
   `PORT APPROXIMATION` because donor vf/vs promotion is ENGINE/UNVERIFIED
   (`TERRAIN2_01:392-393` SEC).
3. **P1 — reuse the 2D sub-tile coverage mask idea for 3D water.**
   `world.gd:975-999` derives a continuous waterline ramp from bilinear
   `height_at()` at 4 samples per tile, with a dry-land guard; 3D's
   `bind_height_grid()` (`water3d.gd:248-262`) already feeds height into the
   shader, so the missing piece is coverage resolution, not a new donor constant.
4. **P2 — borrow the deterministic hashed prop variation pattern.**
   `world.gd:2370-2382` and `:2751-2773` (size buckets, foot-anchored yaw/mirror,
   species pools, no RNG) maps directly onto `world3d_entities.gd:1286-1291`
   instance transforms and could make 3D forests less uniform at zero sim cost.
5. **P2 — extend 3D small-map fixtures with the 2D non-square + seed-scan
   discipline** (§3). This is cheap and catches size-coupling bugs before a
   full 320² bake.
6. **P3 — consider a render-only relief/season visual layer** (`world.gd:1653-1666`,
   winter names `:1143-1172`), but only after a donor A/B; `FIXTERRAIN_visual_quality.md:82-97`
   SEC warns donor ambient/diffuse and eye-plane values are engine-bound — do not
   relabel tuned substitutes as donor.
7. **Do NOT translate:** 2D chunk caching/LRU (`world.gd:31-55`, `:1764+`) — 3D
   is intentionally one full-grid mesh (`world3d_terrain.gd:11-13,803-804`);
   2D's calibrated water colours (`water_overlay.gdshader:77-100`); the old
   static "single wave crop" behaviour described in stale tests.

---

## 5. Open questions / caveats

- **2D evidence is SECONDARY.** No donor file was read this session; donor-faithful
  labels rest on cited donor audits (`TERRAIN2_01…06`), not fresh donor bytes.
- **No donor GPU A/B exists** for either 2D or 3D (`TERRAIN_SMALL_maps.md:206-209`
  SEC, `FIXTERRAIN_visual_quality.md:35-38` SEC). Every "looks better" claim is a
  prediction, not a measurement.
- **Donor vf/vs face promotion, `gl_EyePlaneS/T`, `hmapTex` binding and
  `bmTransparency` pass count** remain ENGINE/UNVERIFIED (`TERRAIN2_01:385-413`
  SEC; `TERRAIN2_06:128-139` SEC). 2D's face collar and 3D's `_face_mode_at`
  are both approximations of the same unknown rule.
- **Doc drift:** several SEC audits predate current source — `TERRAIN_PORT_RENDER.md`
  (tileblock discarded), `TERRAIN_PORT_DECOR.md` (3 static sprites/no yaw),
  `TERRAIN_PORT_ASSETS.md` (winter art unwired), `TERRAIN_PORT_HILLS.md`
  (round domes), `t_water.gd:11-15` (static water). They are useful as *history*
  of what was missing, not as current-state assertions.
- **Small-map limit:** at 64² stamp counts floor to 1 per family, so forest
  richness is not representative (`terrain_sample_shot.py:49-51`); 128² is the
  minimum meaningful sample for decor/forest checks.
- **Winter/desert name mapping** in `game.gd:1427-1478` is a port-authored alias
  table; whether it matches donor season palettes pixel-for-pixel is UNVERIFIED.
- **3D field visuals are better than the SEC parity doc says** — current
  `world3d_entities.gd:1465-1528` uses the same sim methods as 2D for stage
  tint/scale; the remaining gap is donor decal UV mapping, explicitly labelled
  UNVERIFIED at `:153,218-220`.
- **No code, asset, config, test or git state was changed** by this agent; the
  single written artifact is this report.

---

## 6. Summary

**Observed:** the shipping 2D port computes the full donor logical terrain
pipeline — mask→height→terrain roles→stamped relief→per-cell tile index with
8-sector shore/cliff orientation and 3-pass smoothing — and its renderer now
draws the named donor block art with exact per-cell coverage, a graded sandsea
shore bed, a render-only rock face collar and a per-frame height-aware water
shader. Trees and ore are placed from exported donor pattern footprints with
separate, seeded occupancy grids; winter art, field decals and hashed prop
variety are wired.

**Derived:** because `game.gd`, `mapgen.gd` and `pattern_gen.gd` are byte-identical
SHARED, the 3D variant already has every one of these *logical* features. The
real 3D gap is presentation translation, not simulation.

**Inferred:** the most transferable 2D ideas are the shore-distance/grain wash,
the render-only face collar, the sub-tile water coverage ramp, hashed prop
variation, and the small-map test discipline — each portable as a labelled
`PORT APPROXIMATION` render-side change with no shared-data edit.

**Bottom line:** use this report as a SECONDARY checklist of *what the port
already knows how to do*, not as a donor truth source and not as a visual-parity
claim.

---

*End of V2D-02 report. Read-only; no donor binary read or executed; no Godot job;
no source/asset/config/test/git change.*
