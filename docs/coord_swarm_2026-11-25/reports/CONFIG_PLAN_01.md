---
id: CONFIG-PLAN-01
title: "CONFIG-PLAN-01 — complete 3D feature inventory, global JSON config schema and optional UI exposure"
date: 2026-11-25
owner: CONFIG-PLAN-01 (read-only planning micro-worker)
status: PLAN_ONLY__NO_CODE_EDITS__NO_RUNNER_JOBS
scope: "Read-only. One output file: docs/coord_swarm_2026-11-25/reports/CONFIG_PLAN_01.md. Donor READ-ONLY. No code, config, test or doc outside this report was edited; no Godot/runner job launched."
owner_directive: "make all main features of the game configurable in global json config file also and some maybe even in interface if needed"
labels: [observed, derived, inferred, UNVERIFIED, PORT_APPROXIMATION]
sources_verified_twice: "Every current location below was checked (1) by a direct file read and (2) by an independent git diff and/or grep cross-check; section 7 records the audit."
---

# CONFIG-PLAN-01 — global config inventory, schema and UI plan

## Goal

Inventory **every main 3D game feature** whose value is still a hard-coded constant in the
3D variant, and design **one nested `features` section** in `variant3d/config.json` that
makes each one tunable without changing any default. Propose a **small UI subset** with
exact `menu.gd:line` placement, a **zero-break migration** that keeps all existing keys
working, and an **ownership/sequencing plan** that respects the in-flight swarm lanes.
No code is edited by this report.

## Sources

All paths relative to the repo root unless noted. Donor root `C:\Games\Cossacks 3` was
read-only and never executed or copied.

**Primary code read this task (full or targeted):**
`variant3d/config.json`, `variant3d/scripts/config.gd`, `variant3d/scripts/data.gd`,
`variant3d/scripts/menu.gd`, `variant3d/scripts/input_controller.gd`,
`variant3d/scripts/camera3d.gd`, `variant3d/scripts/hud.gd`,
`variant3d/scripts/world3d_terrain.gd`, `variant3d/scripts/world3d_fx.gd`,
`variant3d/scripts/game.gd`, `variant3d/scripts/main.gd`,
`variant3d/scripts/tile_atlas_loader.gd`, `variant3d/scripts/selftest.gd`,
`variant3d/scripts/water3d.gd`, `variant3d/shaders/water3d.gdshader`,
`variant3d/tools/assert_clean.py`.

**Git working-tree diffs read this task:**
`camera3d.gd` (+78), `data.gd` (+16), `game.gd` (+229), `hud.gd` (14),
`main.gd` (+18), `selftest.gd` (+5), `tile_atlas_loader.gd` (+21),
`world3d_fx.gd` (+144), `world3d_terrain.gd` (+219), `assert_clean.py` (SPOOL path).

**Coordination / reports cited:**
`docs/coord_swarm_2026-11-25/GAPS.md`, `PLAN_IMPLEMENTATION.md`, `CORRECTIONS.md`,
`reports/SEL_01_implementation.md`, `RV_SEL_01_selection_reverify.md`,
`RV_CAM_01_fov_resolution.md`, `TRN_SHADER_implementation.md`,
`TRN_WATER_implementation.md`, `RELIEF_01_stamping.md`, `FX_WEATHER_01.md`,
`SP_05_loader_override.md`, `HUD_01_minimap.md`, `MMJUMP_01_minimap_jump.md`,
`DMAPGEN_01_skirmish_options.md`, `DENV_01_environment.md`, `CFG_01_skirmish_defaults.md`,
`CFG_02_no_menu_defaults.md`, `DPATTERN_01_relief_grids.md`, `RV_TRN_01_texgen_mask_reverify.md`.

**Label legend (CHARTER / GAPS.md §4):** `observed` = literal read with `path:line`;
`derived` = arithmetic/enumeration from observed; `inferred` = plausible, not proven;
`UNVERIFIED` = no accessible evidence; `PORT APPROX` = port substitute, never donor fact.

---

## 1. Full feature inventory

Columns: **feature** | **current hard-coded value + file:line** | **donor citation (or PORT APPROX)** | **proposed config.json key** | **default** | **UI?** | **owning file for the reader** | **label**.

### 1.1 Input / selection / camera

| # | Feature | Current hard-coded value + file:line | Donor citation (or PORT APPROX) | Proposed key | Default | UI? | Owning file | Label |
|---:|---|---|---|---|---|---|---|---|
| 1 | Drag epsilon (world ground) | `0.005` m default / `0.25` m attack-guard — `input_controller.gd:203-204` | `onmousemove.inc:32-34,152` (SEL-01); `0.25` attack/guard `:33-34` | `features.input.selection.epsilon_m` / `.epsilon_attack_m` | `0.005` / `0.25` | No (dev-grade) | `input_controller.gd` | observed |
| 2 | Marquee outline | `Color(1,1,0,1)`, width `1.0`, no fill/AA — `input_controller.gd:85-93` | `brushes/selection.cfg:3-14`, bound `resource.lib:47`; native rasterisation UNVERIFIED | `features.input.selection.marquee_color` / `.marquee_width_px` | `[1,1,0,1]` / `1` | No | `input_controller.gd` | observed + UNVERIFIED |
| 3 | Double-click window | `0.5` s — `input_controller.gd:735` | `menu.cfg:33 KeyDoubleDelay=0.5` (SEL-01) | `features.input.selection.double_click_s` | `0.5` | No | `input_controller.gd` | observed |
| 4 | Shift = add to selection | union branch — `input_controller.gd:716-733` (Ctrl-remove deliberately absent) | `onmousemove.inc:150-165` `spmAdd` / `spmRunTime`; `//spmRemove :159-161` | `features.input.selection.shift_add` | `true` | Maybe (advanced) | `input_controller.gd` | observed |
| 5 | Assumed vertical FOV | `FOV_DEG_ASSUMED = 17.27` — `camera3d.gd:88`, used `:176` | PORT APPROX: 216 mm horizontal sensor at 16:9, f=400 (`RV_CAM_01`); numeric FOV CONFIRMED_UNVERIFIED, never 5.15°/30.22° | `features.input.camera.fov_deg` | `17.27` | No | `camera3d.gd` | derived / UNVERIFIED |
| 6 | Minimap-jump tilt / nudge | `DONOR_JUMP_TILT_DEG = 32.0`, `DONOR_JUMP_NUDGE_M = 0.1` — `camera3d.gd:68-69` | `control.script:595-612` (`angleZ=+32`, `dz=0.1`); `ArcTan` body UNVERIFIED — `rv_cam_01` row 7/8 | `features.input.camera.jump_tilt_deg` / `.jump_nudge_m` | `32.0` / `0.1` | No | `camera3d.gd` | observed + UNVERIFIED |
| 7 | Minimap widget geometry | `240×240`, inset `−8`, right/bottom anchor — `hud.gd:297,1387-1409` | `initminimap.inc:5-7,17,29-39` (`cMinimapSize=240`, offsets −8, zoom 1); `DEC_08` C1/C2 | `features.hud.minimap.size_px` / `.inset_px` / `.anchor` | `240` / `8` / `"right"` | No (donor-fixed geometry) | `hud.gd` | observed |
| 8 | Minimap frustum box | AABB stroke of 4 corners — `hud3d_adapter.gd:85-117`, `hud.gd:1476-1514` | `GetCameraFrustumQuadrangle` (`classes.script:6030`) observed; quad-vs-AABB shape UNVERIFIED (`DEC_08` §9 Q2) | `features.hud.minimap.frustum_mode` | `"aabb"` | No | `hud3d_adapter.gd` | UNVERIFIED |
| 9 | Minimap refresh rate | `MINIMAP_INTERVAL = 0.25` (high) — `data.gd:123`; applied `config.gd:390` | no donor key — port rate, tiered `data.gd:152-163` | `features.hud.minimap.interval_s` (alias `display.minimap_interval`) | `0.25` | No | `data.gd` | inferred |
| 10 | Hotkeys | 30+ bindings — `config.json:127-170`, consumed `config.gd:557-568`, `input_controller.gd:230+` | `hotkeys.cfg:1-243` = 55 bindings (`DEC_03` C1); port subset | `controls.hotkeys.*` (existing) | as shipped | Maybe (rebinding UI future) | `config.gd` | observed |

### 1.2 Gameplay / rules / AI

| # | Feature | Current hard-coded value + file:line | Donor citation (or PORT APPROX) | Proposed key | Default | UI? | Owning file | Label |
|---:|---|---|---|---|---|---|---|---|
| 11 | Fog of war (visibility) | `display.fog_of_war = false` — `config.json:22`, `config.gd:382`, `data.gd:55` | skirmish fog toggle UNVERIFIED in readable donor scripts | `display.fog_of_war` (existing) | `false` | **YES** | `config.gd` / `data.gd` | inferred / UNVERIFIED |
| 12 | Corpse lifetime | `CORPSE_LIFE = 90.0` — `data.gd:56`, `config.gd:416` | no donor key found — port estimate | `gameplay.corpse_life` (existing) | `90.0` | No | `config.gd` | inferred |
| 13 | Build queue limit | `10` — `data.gd:50`, `config.gd:411` | port/unverified | `gameplay.build_queue_limit` (existing) | `10` | No | `config.gd` | inferred |
| 14 | Max builders per site | `8` — `data.gd:51`, `config.gd:412` | port/unverified | `gameplay.max_builders_sent` (existing) | `8` | No | `config.gd` | inferred |
| 15 | Victory / score limit | `"destroy_all"` / `5000.0` — `data.gd:52-53`, `config.gd:413-414` | donor victory rule not read | `gameplay.victory` / `.score_limit` (existing) | as shipped | No | `config.gd` | inferred |
| 16 | Logic rate / tick clamp | `FPS = 32.0` — `data.gd:32`; `TICK_MAX = 0.25` — `data.gd:54`, `config.gd:415` | `dmscript.global:174` (FPS=32 observed); tick clamp port-only | `features.gameplay.fps` / `gameplay.max_tick_seconds` | `32.0` / `0.25` | No | `data.gd` | observed + inferred |
| 17 | Map size (tiles) | `240×240` — `config.json:41-42` (MAP-SMALL-01 in flight), fallback `160` — `data.gd:33-34`; menu Tiny 240 — `menu.gd:699` | donor `donewgame.inc:42-48`: Tiny **256**, Normal 320, Large 480, Huge 640 (observed); port Tiny 240 | `gameplay.map_width_tiles` / `.map_height_tiles` (existing) | `240` (port Tiny) | **YES (already)** | `config.json` / `config.gd:407-408` | observed + port |
| 18 | Map shape / terrain type | `"land"` — `config.json:73`; alias read `config.gd:429`; menu `menu.gd:693` | `showcustomgame.inc:146-156`, `generator.cfg:3-27`: 9 shapes + Random, default Mediterranean (observed) | `gameplay.terrain_type` (alias `map_type`) | `"mediterranean"` donor default; `"land"` current file | **YES (already)** | `config.gd` | observed |
| 19 | Relief type | `"hills"` sim / `"low_mountains"` donor — `config.gd:432,472`, `data.gd:204,331-338`, `menu.gd:694` | `gui.txt:449-460` 6 values, default Low Mountains (observed) | `gameplay.relief` / `gameplay.relief_type` | `"hills"` / `"low_mountains"` | **YES (already)** | `data.gd` / `menu.gd` | observed |
| 20 | Season | `"summer"` — `config.json` absent, `data.gd:199`, `config.gd:430`, `menu.gd:695`; enum `data.gd:227` | `map.script:250` (gen.season=0), `dmscript.global:237` (3), `miscext2.script:3318-3323`; season **1 UNVERIFIED** | `gameplay.season` (existing) | `"summer"` | **YES (already)** | `data.gd` | observed + UNVERIFIED |
| 21 | Minerals / richness | `"med"` — `config.gd:431`, `menu.gd:701`, multipliers `data.gd:205-214` | `showcustomgame.inc:224-230`, `gui.txt:435-440` Poor/Medium/Rich/Random (observed) | `gameplay.richness` (existing) | `"med"` | **YES (already)** | `config.gd` | observed |
| 22 | Nations / players / teams | `nation0/nation1` `config.json:71-72`, `NATIONS` `data.gd:247-259`, roster `config.gd:434-467`, `menu.gd:637-646` | `country.script _country_GetSIDByID`; 12-slot cap is PORT EXTENSION beyond donor 8 | `gameplay.player_nations` / `nation0` / `.nation1` / `.players` / `.teams` | `["rus","bav"]`, 2, `[]` | **YES (already)** | `config.gd` | observed + port extension |
| 23 | Global AI difficulty | `"normal"` — `config.gd:129,532`; tiers `config.gd:19,34-40`; menu `menu.gd:706,859` | `dmscript.global:781-786` 6 lobby ids; PE tier literals `progresseconomicai.inc` (documented, **not applied**) | `ai.difficulty` (existing) | `"normal"` | **YES (already)** | `config.gd` | observed |
| 24 | AI tier effects (easy..impossible) | table `config.gd:34-40` documented but unused | PE:2205-2208, 2321-2326, 2349-2358, 3654-3658 (observed) | `features.ai.tier_effects` | donor table verbatim | No | `config.gd` + `ai.gd`/`game.gd` (hand-off) | observed |
| 25 | AI attack force / peasant cap | `60.0` / `14` — `config.gd:530-531` (JSON file still 120/40 — `config.json:118-119`, different layer) | port-tuned, donor threshold UNVERIFIED | `ai.attack_force` / `.max_peasants` (existing) | `60` / `14` | No | `config.gd` | inferred |
| 26 | Donor rule dropdowns (balloon, cannons, century18, capture, marketdip, pop limit, peace time, game speed, autosave, adviser, allies, start resources) | `config.gd:471-485`; menu rows `menu.gd:702-732`; defaults `data.gd:358-372` | `miscext2.script` serialized struct, `gui.txt` labels (observed, `DMAPGEN_01`) | `gameplay.<donor_id>` (existing ids) | donor defaults | **YES (already)** | `config.gd` | observed |
| 27 | Morale radii / bonuses | `12/20/10/10/20/15` — `data.gd:86-91` (only `morale_base`/`rout_threshold` exposed) | **Donor has no numeric morale** (`CORRECTIONS` row 22) — invented port mechanic | `features.gameplay.morale_officer_radius_m` / `.morale_officer_bonus` / `.morale_drummer_radius_m` / `.morale_drummer_bonus` / `.morale_low_hp_penalty` / `.morale_famine_penalty` | same values | No | `data.gd` | inferred / PORT APPROX |
| 28 | Weapon dispersion | `175/225/100` px — `data.gd:97-99` (arrow/cannon/tower) | `weapon.script` / `unit.script` (per code comment; not re-read this task) | `features.gameplay.arrow_dispersion_px` / `.cannon_dispersion_px` / `.tower_dispersion_px` | `175/225/100` | No | `data.gd` | observed (second-hand) |
| 29 | Market drift / recovery | `0.02` / `0.002` — `data.gd:103,107` | no donor cadence recovered — INFERRED (`data.gd:104-106`) | `features.economy.market_drift` / `.market_recovery_per_s` | `0.02` / `0.002` | No | `data.gd` | inferred |
| 30 | Priest heal radius | `8.0` m — `data.gd:94` (only heal/s exposed) | port estimate (video pass) | `features.economy.priest_heal_radius_m` | `8.0` | No | `data.gd` | inferred |
| 31 | Squad XP / max size | `1.0 / 2.0 / 3`, cap `403` — `data.gd:560-569` | donor `formations.cfg` caps at 400; 403 derived (officer+drummer); XP port-only | `features.gameplay.squad_xp_per_kill` / `.squad_xp_per_bonus` / `.squad_xp_cap` / `.squad_max` | `1.0/2.0/3/403` | No | `data.gd` | derived + inferred |
| 32 | Gatherers per resource node | `{food:3, wood:2, stone:3}` — `data.gd:580` | `dmscript.global:222-225 gc_gameplay_resource_maxattackers_*` (observed) | `features.economy.resource_workers` | `{3,2,3}` | No | `data.gd` | observed |

### 1.3 Render / terrain / water / environment

| # | Feature | Current hard-coded value + file:line | Donor citation (or PORT APPROX) | Proposed key | Default | UI? | Owning file | Label |
|---:|---|---|---|---|---|---|---|---|
| 33 | Metres per tile / texgen repeat | `TILE_M = 2.0` — `data.gd:23`, `world3d_terrain.gd:130`; shader `uv_repeat = 0.5` | `dmscript.global:171 gc_meters_to_tile = 2` (`DEC_05`, `CORRECTIONS` row 10) — observed; shader application PORT APPROX | `features.render.terrain.meters_per_tile` | `2.0` | No | shader / `data.gd` | observed |
| 34 | Terrain texgen mode | world-ground XZ planes `S=(1,0,0,0) T=(0,0,1,0)` — shader A1 (`TRN_SHADER` §1) | donor `gl_EyePlaneS/T` CONFIRMED_INFEASIBLE (`DBIND_01`); world substitute never a donor literal | `features.render.terrain.texgen_mode` | `"world_xz"` | No | shader | UNVERIFIED / PORT APPROX |
| 35 | Sun direction + light colours | `SUN_POS (-0.3447,0.9387,0)`, ambient/diffuse/specular — `world3d_terrain.gd:137-141`; shader B1/B3 | `light.cfg:2-31` observed; eye-space/axis treatment UNVERIFIED | `features.render.terrain.sun_position` / `.ambient` / `.diffuse` / `.specular` | donor literals | No | `world3d_terrain.gd` + shader | observed + UNVERIFIED |
| 36 | Port light energies | exposure `1.45`, ambient `1.10`, sun `1.7` — `world3d_terrain.gd:149-151` | no donor equivalent — art compensation | `features.render.terrain.exposure` / `.ambient_energy` / `.sun_energy` | `1.45/1.10/1.7` | No | `world3d_terrain.gd` | inferred |
| 37 | Sky band colours | horizon `(0.6,0.7765,0.9922)`, top `(0,0.1412,0.8078)` — `world3d_terrain.gd:146-147` | `skydome.cfg:11-20` observed (labels corrected in `DENV_01` C1); band→gradient mapping PORT APPROX | `features.render.sky.horizon_color` / `.top_color` | donor literals | No | `world3d_terrain.gd` | observed + UNVERIFIED |
| 38 | Alpha patch grid + tile→patch map | 8×4×64 grid, `5 + mod(tile,22)`, inset `0.5/64` — shader C1/C2 (`TRN_SHADER`) | `reftile.lib:10-12` + pixel seam proof (`RV_TRN_01`); tile→patch index UNVERIFIED | `features.render.terrain.alpha_patch_grid` / `.alpha_patch_offset` | `[8,4,64]` / `5` | No | shader | derived + UNVERIFIED |
| 39 | Cliff thresholds / face tilt | `cDiff1=0.5`, `cDiff2=0.55`, tilt `25°`, rock8 `2.7`, rock4 `2.4`, none `0.1`, face scale `0.125` — `world3d_terrain.gd:161-175,179-181` | `texturemap.inc:63-64,594-601`; `tiles.mat:142-210`; tilt application UNVERIFIED (`RV_TRN_01` C) | `features.render.terrain.face_tilt_deg` / `.cliff_diff1` / `.cliff_diff2` / `.rock8_h` / `.rock4_h` / `.face_scale` | as listed | No | `world3d_terrain.gd` | observed + UNVERIFIED |
| 40 | Relief-grid stamps (coarse tables + blend) | two 8×10 tables, `scale/min/max`, `RELIEF_BLEND_LABEL` — `world3d_terrain.gd:193-243`; opt-in reader `:363-455` | `DPATTERN_01` Appendix A1/A2 + `pattern.lib` literals (numbers observed); engine blend UNVERIFIED | `features.render.terrain.relief_stamps_enabled` / `.relief_footprint` / `.relief_blend` | `false` / `[10,8]` / `"additive_clamp_port_approx"` | No | `world3d_terrain.gd` | derived + UNVERIFIED |
| 41 | Water classification / fade literals | `level -0.25`, `shore -0.1`, `max_height 2.96`, fade `0.57 / 1.07` — `water3d.gd:19-20,34-36`; shader `:26-36` | `texturemap.inc:29-31`; `water.dev.frag:37,168` (observed) | `features.render.water.level` / `.shore_height` / `.max_height` / `.coast_fade_depth` / `.deep_fade_depth` | as listed | No | `water3d.gd` + shader | observed |
| 42 | Water surface Y (swell driver) | `WATER_SURFACE_Y = -0.25` — `water3d.gd:27` (plane vertices `:197-200`) | PORT APPROX for `gl_TexCoord[1].z` (`water.dev.frag:167`), engine value UNVERIFIED; A/B `>0.8333` restores swell | `features.render.water.surface_y` | `-0.25` | No | `water3d.gd` | UNVERIFIED |
| 43 | Water glints / foam literals | spec powers `170/120`, particles `30`, shallow/deep/spec colours, HDR `1` — shader `:39-45,219-226` | `water.dev.frag:42-47` (observed) | `features.render.water.spec_soft` / `.spec_glossy` / `.particle_amount` / `.shallow_color` / `.deep_color` / `.spec_color` / `.hdr_multiplier` | donor literals | No | shader | observed |
| 44 | Water alpha gate + shore id | `water_cell = 1-step(level,height)` — shader `:182,246`; `BLK_WATER→grass1` clamp `world3d_terrain.gd` UV2 site | gate PORT GUARD (no donor `mask.B` grid); donor shore ids `sandsea1/5/6` = 93/97/98 (`DEC_05` §5.1, observed) | `features.render.water.alpha_gate` / `.shore_tile_id` | `true` / `"sandsea1"` (or keep `"grass1"` until integration) | No | shader + `world3d_terrain.gd` | inferred + observed |
| 45 | Render fog (shader) | `fog_enabled = 0`, `fog_color (60,100,150)/255`, density `0`; terrain fog inert — shader `:63-65` | `colors.lib:23,34-43 FogMode=0` **ambiguous**; GL writer maps 0→LINEAR, bridge UNVERIFIED (`CORRECTIONS` row 28) | `features.render.fog.enabled` / `.color` / `.density` / `.start_m` / `.end_m` / `.interval_s` | `false` / donor colour / `0` / `390` / `490` / `0.5` | No (gameplay-only toggle in UI) | shader / `data.gd:122` | UNVERIFIED |
| 46 | Quality preset + FX cap | `QUALITY="high"`, `TERRAIN_PX=16`, `SPRITE_CELL=160`, `FX_CAP=220`, fog/minimap `0.5/0.25` — `data.gd:119-123,152-163`; applied `config.gd:385-390` | no donor key — port render budget | `display.quality` (existing) + `features.render.quality.terrain_px` / `.sprite_cell` / `.fx_cap` | `"high"` / `16` / `160` / `220` | Maybe (preset dropdown) | `data.gd` / `config.gd` | inferred |
| 47 | Atlas manifest path (season swap hook) | `V785_MANIFEST` default — `tile_atlas_loader.gd:71,74,86,115,408`; `manifest_path` already consumed from ctor dict (SP-5) | no donor key — port index-preserving swap hook | `features.render.terrain.atlas_manifest_path` | `res://assets/terrain/atlas/tile_index_atlas.manifest.json` | No | `tile_atlas_loader.gd` (consumer already exposed) | inferred |
| 48 | Tile smoothing rules / diversity target | `DONOR_SMOOTH_RULES` 118 lists — `game.gd:1416`; `DONOR_FOREST_BASE` `:1582`; diversity goal top-5 <73% — `GAPS.md §2` | `tilesmooth_scripts.cfg` all 1,864 lines parsed (`RV_TRN_02 §7`, observed) | `features.render.terrain.smoothing_source` / `.diversity_top5_target` | `"embedded"` / `0.73` | No | `game.gd` | observed + derived |
| 49 | Weather value / snow gate | `40 / 0 / 99 / 70 / 100 / 1 / 12` — `world3d_fx.gd:140-146`; gate `:644-664`; API `set_weather` `:240-253` | `clouds.weather:3,21-22`; `particles.snow.cfg:32-35` (observed); default OFF derived (40<70) | `features.environment.weather.value` / `.month` / `.snow_band` | `40` / `1` / `[70,100]` | **YES** (simple snow on/off) | `world3d_fx.gd` | observed |
| 50 | Snow emitter values | speeds `0.041..0.1`, counts `100/100/100/200`, sizes `0.0015..0.003`, alpha `0.5`, cube `±0.5`, dir `(0,-1,0)`, lifetime `8.0` PORT ONLY — `world3d_fx.gd:149-157` | `particles.snow.cfg` literals (observed); unit conversion UNVERIFIED; lifetime no donor key | `features.environment.weather.snow_speeds` / `.snow_counts` / `.snow_sizes` / `.snow_alpha` / `.snow_lifetime_s` | donor literals / `8.0` | No | `world3d_fx.gd` | observed + UNVERIFIED |
| 51 | FX rally TTL | `RALLY_TTL = 2.0` — `world3d_fx.gd:134` | no donor key — port choice | `features.fx.rally_ttl_s` | `2.0` | No | `world3d_fx.gd` | inferred |
| 52 | Season tint table (legacy flat tint) | summer `[1,1,1,1]`, winter `[0.86,0.91,1,1]`, desert `[1,0.9,0.7,1]` — `data.gd:235-239` | donor swaps tile SETS + `colors.lib` tables (`DENV_01` §4/§5.2), not a colour multiply — PORT APPROX kept for 2D sibling | `features.season.tint_summer` / `.tint_winter` / `.tint_desert` | as listed | No | `data.gd` | inferred / PORT APPROX |

### 1.4 Audio / tests / tooling

| # | Feature | Current hard-coded value + file:line | Donor citation (or PORT APPROX) | Proposed key | Default | UI? | Owning file | Label |
|---:|---|---|---|---|---|---|---|---|
| 53 | Audio master / ambient volume | `0.0 dB / -12.0 dB`, enabled — `config.json:121-125`, `config.gd:543-546`, `data.gd:109-111` | no donor dB key read — port defaults | `audio.enabled` / `.master_volume_db` / `.ambient_volume_db` (existing) | as shipped | Maybe (volume sliders future) | `config.gd` | inferred |
| 54 | Test spot clearance | `ink.grow(Data.TILE_M + 0.75)` — `selftest.gd:154-155` (was `0.6`, widened to fix 240² build placement) | port-only harness fix, no donor equivalent | `features.tests.spot_clearance_m` (JSON-only; test consumer) | `2.75` | No | `selftest.gd` | inferred |
| 55 | Godot queue spool root | `SPOOL = ROOT/"variant3d"/".godot_queue"` — `tools/assert_clean.py:34` (CLEAN-02 changed from `app/`) | port tooling, no donor equivalent | **do NOT expose** — keep as tool constant | n/a | No | `assert_clean.py` (CLEAN-02 owns) | observed / port |

**Inventory totals:** 55 features — gameplay 22, render/environment 20, input/camera/HUD 10, audio/tests/tooling 3 (some rows span two domains). All 55 were located twice (§7).

---

## 2. Proposed global JSON schema

Design rules:

1. **Additive only.** Existing sections (`display`, `camera`, `gameplay`, `economy`, `ai`,
   `audio`, `controls`, `names`, `units`, `buildings`) keep every current key and meaning.
2. **One new top-level `features` object** groups the formerly hard-coded constants. Its
   defaults equal today's values *exactly*, so deleting the section changes nothing.
3. **Reader-side fallbacks preserve legacy keys**: each new reader uses
   `num("features.x.y", <current literal>)`, and where a legacy key already exists the
   reader prefers the legacy key when the new one is absent (no renames, no removals).
4. **Labels travel with the values.** `config.json` has no comments, so the `_readme`
   array (currently `config.json:2-15`) is extended with one line per caveated group
   (FOV, texgen, alpha patch map, fog bridge, weather units, relief blend).
5. **UI writes remain in `user://options.json`** (`config.gd:250-256` already merges it
   last), never by mutating `config.json`.

```jsonc
// variant3d/config.json — ADDITIVE excerpt; existing sections unchanged above.
"features": {
  "input": {
    "selection": {
      "epsilon_m": 0.005,              // onmousemove.inc:32,152 (observed)
      "epsilon_attack_m": 0.25,        // onmousemove.inc:33-34
      "double_click_s": 0.5,           // menu.cfg:33
      "marquee_color": [1.0, 1.0, 0.0, 1.0],
      "marquee_width_px": 1.0,
      "shift_add": true
    },
    "camera": {
      "fov_deg": 17.27,                // PORT APPROX - do not claim donor parity
      "jump_tilt_deg": 32.0,
      "jump_nudge_m": 0.1
    }
  },
  "hud": {
    "minimap": {
      "size_px": 240, "inset_px": 8, "anchor": "right",
      "frustum_mode": "aabb",          // quad-vs-AABB UNVERIFIED
      "interval_s": 0.25
    }
  },
  "gameplay": {
    "fps": 32.0,
    "morale_officer_radius_m": 12.0, "morale_officer_bonus": 20.0,
    "morale_drummer_radius_m": 10.0, "morale_drummer_bonus": 10.0,
    "morale_low_hp_penalty": 20.0, "morale_famine_penalty": 15.0,
    "arrow_dispersion_px": 175.0, "cannon_dispersion_px": 225.0,
    "tower_dispersion_px": 100.0,
    "squad_xp_per_kill": 1.0, "squad_xp_per_bonus": 2.0,
    "squad_xp_cap": 3, "squad_max": 403,
    "corpse_life_s": 90.0              // mirrors gameplay.corpse_life
  },
  "economy": {
    "resource_workers": {"food": 3, "wood": 2, "stone": 3},
    "priest_heal_radius_m": 8.0,
    "market_drift": 0.02, "market_recovery_per_s": 0.002
  },
  "ai": {
    "tier_effects": {                  // documented in config.gd:34-40, not yet applied
      "easy":       {"max_level_att": 0, "max_level_def": 0, "divers": 0, "mine_maxlevel": 2},
      "normal":     {"max_level_att": 2, "max_level_def": 3, "divers": 0, "mine_maxlevel": 3},
      "hard":       {"max_level_att": 7, "max_level_def": 7, "divers": 2, "mine_maxlevel": 4},
      "veryhard":   {"max_level_att": 7, "max_level_def": 7, "divers": 4, "mine_maxlevel": 5},
      "impossible": {"max_level_att": 7, "max_level_def": 7, "divers": 4, "mine_maxlevel": 5}
    }
  },
  "render": {
    "terrain": {
      "meters_per_tile": 2.0,          // donor-grounded (dmscript.global:171)
      "texgen_mode": "world_xz",       // PORT APPROX; eye planes infeasible
      "sun_position": [-0.344731152057648, 0.938701450824738, 0.0],
      "ambient":     [0.196078434586525, 0.184313729405403, 0.129411771893501],
      "diffuse":     [0.811764717102051, 0.780392169952393, 0.694117665290833],
      "specular":    [0.278431385755539, 0.266666680574417, 0.211764708161354],
      "exposure": 1.45, "ambient_energy": 1.10, "sun_energy": 1.7,
      "alpha_patch_grid": [8, 4, 64], "alpha_patch_offset": 5,
      "face_tilt_deg": 25.0, "cliff_diff1": 0.5, "cliff_diff2": 0.55,
      "rock8_h": 2.7, "rock4_h": 2.4, "face_scale": 0.125,
      "relief_stamps_enabled": false, "relief_footprint": [10, 8],
      "relief_blend": "additive_clamp_port_approx",
      "atlas_manifest_path": "res://assets/terrain/atlas/tile_index_atlas.manifest.json",
      "smoothing_source": "embedded", "diversity_top5_target": 0.73
    },
    "sky": {
      "horizon_color": [0.600000023841858, 0.776470601558685, 0.992156863212585],
      "top_color":     [0.0, 0.141176477074623, 0.807843148708344]
    },
    "fog": {
      "enabled": false, "color": [0.2352941176, 0.3921568627, 0.5882352941],
      "density": 0.0, "start_m": 390.0, "end_m": 490.0, "interval_s": 0.5
    },
    "water": {
      "level": -0.25, "shore_height": -0.1, "max_height": 2.96,
      "coast_fade_depth": 0.57, "deep_fade_depth": 1.07,
      "surface_y": -0.25,              // PORT APPROX; engine plane Y UNVERIFIED
      "spec_soft": 170.0, "spec_glossy": 120.0, "particle_amount": 30.0,
      "shallow_color": [0.1, 0.24, 0.24], "deep_color": [0.0, 0.025, 0.05],
      "spec_color": [0.4, 0.4, 0.4], "hdr_multiplier": 1.0,
      "alpha_gate": true, "shore_tile_id": "sandsea1"
    },
    "quality": {"terrain_px": 16, "sprite_cell": 160, "fx_cap": 220}
  },
  "season": {
    "tint_summer": [1.0, 1.0, 1.0, 1.0],
    "tint_winter": [0.86, 0.91, 1.0, 1.0],
    "tint_desert": [1.0, 0.90, 0.70, 1.0]
  },
  "environment": {
    "weather": {
      "value": 40, "month": 1, "snow_band": [70, 100],
      "snow_speeds": [0.041, 0.061, 0.08, 0.1],
      "snow_counts": [100, 100, 100, 200],
      "snow_sizes": [0.0015, 0.002, 0.00251, 0.003],
      "snow_alpha": 0.5, "snow_lifetime_s": 8.0   // PORT ONLY lifetime
    }
  },
  "fx": {"rally_ttl_s": 2.0},
  "tests": {"spot_clearance_m": 2.75}
}
```

Ranges recommended for the reader (`config.gd` already clamps several):
epsilon `0..1`; FOV `5..60` (_default only_ — do not offer 5.15° as a V-FOV); water
`level/shore/surface_y −3..3`; fade depths `0.05..3`; spec powers `1..512`;
quality `terrain_px 1..64` (already clamped `config.gd:386`), `fx_cap 0..2000`;
minimap size `120..400`; weather `value 0..99` (already clamped `world3d_fx.gd:241`),
`month 1..12`; relief footprint `2..64`. Enum values must be validated against the
donor id tables (`DONOR_*` in `data.gd`) before reaching the sim, exactly as `_donor_id()`
does today (`config.gd:590-595`).

### Migration path (zero break)

1. **COORD merges MAP-SMALL-01's `config.json` first.** Only then does a CONFIG-CORE
   builder add the `features` object with all defaults above. `config.gd`'s `DEFAULT`
   gains an identical `features` subtree so a file that omits it is unchanged.
2. No existing key is renamed, moved or removed. `config.gd:apply()` keeps writing the
   same `Data.*` fields from the old keys. New `*FromFeatures()` reader calls are added
   **after** the existing assignments, each with the current literal as fallback, e.g.
   `Data.FOV_ASSET = num("features.input.camera.fov_deg", 17.27)`; for shared values the
   reader uses legacy-first logic: `value("features.gameplay.corpselife", value("gameplay.corpse_life", 90.0))`.
3. Leaf consumers (input controller, shaders, FX module) are changed one file per owner
   to read the new `Data.*`/config value instead of the `const`. Every changed `const`
   keeps its numeric literal as the reader's fallback, so a missing key cannot crash.
4. `--dump-config` (`config.gd:627-628`) automatically prints the new section; the
   `_readme` array records the UNVERIFIED/PORT APPROX caveats.
5. UI rows write `user://options.json` (already merged last at `config.gd:250-256`),
   so a UI pick overrides the global file without editing it — existing behaviour for
   `ai.difficulty` is the template (`menu.gd:891-895`).

---

## 3. UI exposure — small, donor-meaningful subset

Only options with a clear donor/skirmish meaning and a safe enum range should reach the
interface. Everything else stays JSON-only (see rationale below).

| UI option | Exact placement in `variant3d/scripts/menu.gd` | How it is emitted / read | Donor basis |
|---|---|---|---|
| **Season** (already present) | `menu.gd:695` — `options_body.add_child(_opt_row("Season", …))`, in the **Map** section opened at `:692` | `cfg["season"]` at `:901`; `config.gd:430` → `Data.BIOME`; `data.gd:227 SEASON_ENUM` | `map.script:250`, `miscext2.script:3318-3323`; season 1 deliberately not offered (UNVERIFIED) |
| **Relief** (already present) | `menu.gd:694` — `options_body.add_child(_opt_row("Relief", _relief_types(), …))` | `cfg["relief"]`/`cfg["relieftype"]` at `:901,907`; `config.gd:432,472` → `Data.RELIEF`, `DONOR_RELIEF_TYPE` | `gui.txt:449-460` 6 values; default Low Mountains |
| **Map shape / Map size** (already present) | `menu.gd:693` Map shape; `menu.gd:696-699` Map size (Tiny/Normal/Large 2x/Huge 4x) | `cfg["terrain_type"]`/`["mapsize"]` at `:900,909`; `config.gd:429` | `showcustomgame.inc:146-156,244-247`; `donewgame.inc:42-48`. Port Tiny 240 vs donor 256 — keep port value |
| **Difficulty** (already present) | `menu.gd:706` skirmish **Rules** row; `menu.gd:859` **Options** panel row | `cfg["difficulty"]` at `:903`; `_save_options()` `:891-895` writes `user://options.json` → `config.gd:532` | `dmscript.global:781-786`; two extra donor tiers appended (`R06 C1`) |
| **Weather / snow** (NEW) | insert one row immediately after `menu.gd:695` (still in the **Map** section), using `_opt_row("Weather", [{"id":"off","name":"Off"},{"id":"40","name":"Clear"},{"id":"70","name":"Snow"}], …)`. Default `"40"`; `"70"` calls `set_weather(70)` via the existing public API `world3d_fx.gd:240-253` | add `"weather"` to `_emit_start()` cfg (`:897-914`) and persist in `_save_options()` (`:891-895`); reader `features.environment.weather.value` | `clouds.weather:3` = 40; `particles.snow.cfg:32-33` band 70..100. Visual form stays PORT APPROX / units UNVERIFIED |
| **Fog of war** (NEW) | insert one row in the **Rules** section right after `menu.gd:706` Difficulty (before Balloon at `:707`), e.g. `_opt_row("Fog of war", [{"id":"0","name":"Off"},{"id":"1","name":"On"}], …)` | add `cfg["fog_of_war"]` at `:897-914` and include it in `_save_options()`; existing reader `display.fog_of_war` (`config.gd:382`) | donor skirmish toggle UNVERIFIED — label as port option, do not claim donor parity |
| **Selection assistance** (NEW, optional) | one row in `_show_options()` at `menu.gd:857-889`, after the Difficulty row `:859` — a single "Drag select: donor / relaxed" toggle mapping to epsilon `0.005` vs `0.25` | persist to `user://options.json` via `_save_options()`; reader `features.input.selection.epsilon_m` | `onmousemove.inc:32-34,152` gives both donor literals; safe even though the relaxed value is a donor *mode*, not a difficulty |

**Why the rest stay JSON-only**

- **Donor-engine or engine-unknown values** (FOV, eye planes, alpha tile→patch, fog-mode
  bridge, water surface Y, minimap frustum shape, donor rule dropdowns that already have
  UI): exposing them as player-facing choices would imply parity or understanding we do
  not have (`CORRECTIONS` rows 8/28/42/44/50).
- **Developer/tuning granularity** (snow counts/sizes/speeds, cliff thresholds, light
  energies, morale radii, dispersion, test clearance): no meaningful player facing label
  and no donor UI control; changing them needs the visual A/B ladder first.
- **Donor-fixed geometry** (240 px minimap, −8 inset) and **representation constants**
  (`PROT_SLOT`, atlas grid, `TILE_M`): exposing invites regressions such as the 2D
  checkerboard or seams watchlist (`GAPS.md §3` rows 5/9).
- **Already-present legacy keys** (audio, hotkeys, quality) remain reachable via config;
  full rebinding/volume sliders are a separate UI ticket, not part of this small subset.

---

## 4. Ownership / sequencing plan (no two agents edit one file)

### In-flight conflicts observed at planning time

| Ticket / lane | Owns (exclusive) | Conflict effect on this plan |
|---|---|---|
| **MAP-SMALL-01** | `variant3d/config.json` | config.json is currently 240×240 (`config.json:41-42`, see CFG-02's reverted 320 baseline). **Do not edit config.json until MAP-SMALL-01 lands.** CONFIG-CORE queues after it; COORD merges the file then hands ownership. |
| **CLEAN-02** | `variant3d/tools/assert_clean.py` | Already changed SPOOL to `variant3d/.godot_queue` (`assert_clean.py:34`). Do not touch or revert; feature #55 is explicitly NOT exposed. |
| **MMJUMP-02** | `variant3d/scripts/hud.gd`, `variant3d/scripts/camera3d.gd` | Rerouted `_cam3d_jump` to `jump_to_world_donor_offset` (`hud.gd:1460-1468`) and added the 32°/0.1 API (`camera3d.gd:68-69,515-580`). Any minimap geometry / FOV / jump consumer change must wait for MMJUMP-02 or be done by that owner. |
| **SP-5** | `variant3d/scripts/tile_atlas_loader.gd` (landed) | Added `manifest_path` already consumed by ctor dict (`tile_atlas_loader.gd:74,86,115,408`). Config work needs **no edit here** — just add the key. |
| **SEL-01** | `variant3d/scripts/input_controller.gd` (landed) | Selection constants are in this file; a new CONFIG-INPUT owner must take it after SEL-01 is merged, with a fresh backup. |
| **TRN-SHADER / TRN-WATER / RELIEF-01 / RELIEF-02 / FX-WEATHER-01 / SP-1** | shader, `water3d.*`, `world3d_terrain.gd`, `main.gd`, `world3d_fx.gd`, `data.gd` (all landed) | Readers can be added by new owners only after those lanes merge; keep the `PORT APPROX` comments when replacing literals. |

### Proposed follow-up tickets (each one file per owner)

| Order | Ticket | Exclusive file(s) | Work | Gate |
|---:|---|---|---|---|
| 0 | MAP-SMALL-01 | `config.json` | land the small-map change | existing selftest/uitest |
| 1 | CONFIG-CORE | `config.json` + `config.gd` (after step 0) | add `features` defaults + readers + `_readme` caveats; legacy-first fallbacks | --dump-config diff, selftest 29/29, uitest 17/17 |
| 2a | CONFIG-INPUT | `input_controller.gd` | epsilon / double-click / marquee / Shift readers | S1 atom + probe 326/329 |
| 2b | CONFIG-RENDER-A | `world3d_terrain.gd` + `terrain_tileindex.gdshader` | sun/colour/face/relief/alpha patch readers (one owner for both, or split with a hand-off) | t_terrain3d smoke |
| 2c | CONFIG-RENDER-B | `water3d.gd` + `water3d.gdshader` | level/surface/fade/alpha gate readers; shore id needs terrain-owner coordination | t_water3d smoke |
| 2d | CONFIG-ENV | `world3d_fx.gd` | weather/snow/rally readers via existing `set_weather` API | t_fx3d smoke 13/13 |
| 2e | CONFIG-HUD | `hud.gd` + `hud3d_adapter.gd` + `camera3d.gd` | **only after MMJUMP-02**; minimap size/inset/frustum/FOV/jump readers | CAM_RV-01 20/20 |
| 3 | CONFIG-UI | `menu.gd` | 3 new rows (weather, fog-of-war, optional selection) + extend `_save_options()`; main.gd `_apply_menu_cfg()` key pass-through needs a separate owner if required | uitest 17/17 (update `uitest.gd:304-307` minimap assertion in the same lane) |
| 4 | COORD | docs only | update GAPS/CORRECTIONS with the new keys and labels; no code | final whole-system gate |

Every builder backs up to `inbox/backup/<name>.bak-CONFIG-*` before editing, uses one
runner id `<ticket>-<purpose>`, and writes one `reports/<TICKET>.md` with the claim table —
per `PLAN_IMPLEMENTATION.md §3`.

---

## 5. Risks

1. **Label laundering.** Turning a `PORT APPROXIMATION` into a config key can make it look
   donor-authoritative. Mitigation: keep every existing `path:line`/`UNVERIFIED` comment
   in the consumer and add a `_readme` caveat line per caveated group.
2. **Layer precedence confusion.** `user://options.json` is merged **after** `config.json`
   (`config.gd:250-256`), so a UI pick silently wins over the global file. Document this;
   never have UI write `config.json` directly.
3. **Test literal coupling.** `uitest.gd:304-307` asserts the old bottom-left minimap;
   `selftest.gd:_spot` was just widened for 240². Changing minimap/clearance defaults can
   break green gates — flip assertions in the owning lane, never weaken a correct test.
4. **Default drift via concurrent lanes.** MAP-SMALL-01 owns config.json; MMJUMP-02 owns
   camera/HUD. Reads of "current" values in this report are time-stamped to the observed
   working tree; re-read immediately before coding.
5. **Donor option ids vs generator ids.** `terrain_type`, `relief`, `map_type`, `season`
   have legacy aliases (`config.gd:429-494`). New `features.*` keys must not bypass
   `_donor_id()` validation (`config.gd:590-595`) or the sim will receive an unknown id.
6. **Snow enabled by config while units are UNVERIFIED.** Exposing only on/off in UI is
   safe; exposing speeds/sizes invites false visual-parity claims without the donor A/B.
7. **Water shore-id cross-owner fix.** `TRN-WATER §2.3` proves the `grass1` clamp lives in
   `world3d_terrain.gd`, not in the water module. Adding `shore_tile_id` to config without
   moving the UV2 consumer leaves the key inert — sequence CONFIG-RENDER-A before 2c/T2.
8. **AI tier effects are documented but not applied** (`config.gd:533-541`). Adding them
   to JSON without `ai.gd`/`game.gd` wiring creates a dead knob; keep the caveat in
   `_readme` or defer to W2-4.
9. **Config file size / startup.** Adding ~100 keys is trivial for JSON parsing, but
   `--dump-config` output grows; readers should validate enums and clamp numbers as today.

---

## 6. Open questions

1. Does the owner want the `features` section **added to `config.json`** (explicit,
   discoverable, grows the file) or only to `config.gd.DEFAULT` (invisible until a value
   is overridden)? This plan recommends both, with the JSON copy written by CONFIG-CORE.
2. Who inherits `config.json` ownership after MAP-SMALL-01 — COORD or CONFIG-CORE?
3. Should UI options write `user://options.json` for all three new rows, or should
   map/rule picks stay in the per-game `cfg` dictionary only? (Current `ai.difficulty`
   precedent favours options.json.)
4. Is a donor skirmish **fog-of-war** toggle actually present? No readable script was
   found; if UNVERIFIED persists, label the UI row "port option" forever.
5. Should season 1 (`gc_MaxSeasonCount=3` implies 0/1/2) ever be exposed? It is
   deliberately UNVERIFIED (`DENV-01` Q5 / `SEASON-PLAN-01` B7) — this plan says no.
6. Does enabling snow require `config.gd` to call `set_weather()` on the FX node, and
   who owns that driver ticket (`FX_WEATHER_01` Q2)? The layer currently has no caller.
7. Should `features.tests.*` exist at all, or should test constants stay source-only?
   Recommendation: JSON-only and lowest priority; they are harness aids, not game features.
8. Should `shore_tile_id` default to `"grass1"` (byte-identical today) or straight to
   `"sandsea1"` (donor-faithful intent)? Recommendation: keep `"grass1"` until the T2
   visual gate proves the new shore tile, then flip the default in one reviewed commit.
9. Is the AABB minimap frustum acceptable as a configurable `"aabb"`/`"quad"` choice when
   the donor shape itself is UNVERIFIED? Recommendation: expose the key but document that
   only `"aabb"` is currently implemented.

---

## 7. Twice-verification audit

Each inventory row's **current location** was checked by two independent methods:

| Method A (direct read) | Method B (independent cross-check) |
|---|---|
| `config.json` read in full (833 lines) | `git diff -- config.json` context + `CFG_02` report key table (`:27-30`) |
| `config.gd` read in full (687 lines) | `grep` of reader lines `:407-408,429-432,530-532` + `CFG_02` line citations |
| `data.gd` read in full (1,084+ lines) | `git diff -- data.gd` (SP-1 +16 block at `:217-241`) + targeted `grep` |
| `menu.gd` read in full (927 lines) | `_emit_start()` re-read at `:897-914` + `HUD_01`/`DMAPGEN_01` line citations |
| `input_controller.gd:175-234` read | `grep` for `epsilon/0.35/marquee/spmAdd` + `SEL_01` before→after table `:58-63` |
| `camera3d.gd` diff (+78) read | targeted `grep`: FOV `:88`, jump `:68-69` |
| `hud.gd` diff (14) read | `grep` minimap: `:297,1387-1409` + `HUD_01` before→after table `:48-58` |
| `world3d_terrain.gd:130-194` + diff read | `grep` `DONOR_*` constants + `RELIEF_01` §3 ledger `:101-109` |
| `world3d_fx.gd:134-157` + diff read | `grep` `SNOW_*`: `:140-157,196,644-698` + `FX_WEATHER_01` §3 ledger |
| `game.gd` diff (+229) read | `grep`: `DONOR_SMOOTH_RULES :1416`, `DONOR_FOREST_BASE :1582` |
| `water3d.gd` + shader `grep` read | `TRN_WATER` §2.1-2.4 before→after table |
| `tile_atlas_loader.gd` diff read | `SP_05` §3.1-3.2 exact before/after quoting |
| `selftest.gd` diff read | `CFG_02` §caveat 2 describing `_spot()` ring |
| `assert_clean.py` diff read | `git status` confirms CLEAN-02 ownership + backup file present |

No location in the table rests on a single observation.

---

## Summary

- **55 hard-coded features** were inventoried across gameplay (22), render/environment
  (20), input/camera/HUD (10) and audio/tests/tooling (3), each with current value +
  `file:line`, donor citation or explicit `PORT APPROX`/`UNVERIFIED` label, proposed
  `features.*` key, default, UI disposition and owning file.
- The proposal is **one additive `features` object** in `config.json` plus identical
  defaults in `config.gd.DEFAULT`; **no existing key is renamed or removed**, and every
  reader falls back to today's literal, so deletion of the section is a no-op.
- **Six UI rows** are recommended: three already present (season, relief, map shape/size,
  difficulty counted), three new (**weather/snow**, **fog-of-war**, optional **selection
  assistance**), all placed at exact `menu.gd:694-706,857-859` coordinates with writes to
  `user://options.json`.
- The remaining ~49 options stay JSON-only because they are engine-side UNVERIFIED,
  developer-granularity, donor-fixed geometry, or representation constants.
- Sequencing respects all in-flight lanes: **MAP-SMALL-01 → CONFIG-CORE → leaf readers →
  CONFIG-UI**, with `assert_clean.py` (CLEAN-02), `hud.gd`/`camera3d.gd` (MMJUMP-02) and
  `config.json` (MAP-SMALL-01) untouched by this plan.
- **No code, config, test, asset or runner job was created or edited** by this report; all
  donor material remained read-only and no visual-parity claim is made.
