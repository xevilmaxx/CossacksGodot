---
owner: V7-1
date: 2026-11-24
role: read-only recon (no code/asset/config edits, no Godot runs)
lane: Wave 7 phase 1 — mechanics inventory for the 3D variant
output: docs/coord_swarm_2026-11-24/reports/V71_mechanics_inventory.md
scope: authoritative SHARE / ADAPT / NEW / BLOCKED disposition of every 2D mechanic and test
governing_rule: leverage existing DONOR code (data/scripts, data/cameras, data/shaders, .osm/.oss/.aaf, light.cfg, env.cfg) as source of truth — translate, do not invent; UNVERIFIED where unreadable
product_scope: SINGLEPLAYER SKIRMISH ONLY (D-12) — no missions/campaigns/DLC maps/cutscenes/network; all such material documented as deferred
---

# V7-1 — Mechanics inventory for the 3D variant

## 0. Method, sources and evidence labels

Read in full this session (all paths under `C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3`):

| Source | Extent | What it gave |
|---|---|---|
| `app/selftest.json` | 1-189 (29 steps at :13-186, `passed:true` :2, 29th step `nav_detour` :182-186) | sim-mechanic proof ids + observed numbers |
| `app/uitest.json` | 1-91 (17 steps at :4-88, `passed:true` :2) | shell/UI/picking proof ids |
| `app/tests/manifest.json` | 1-196 (24 `t_*` tests at :5-195; `t_weather` `pending` :99-105) | single-feature test ids, 2 windowed gates (:40, :193) |
| `app/MECHANICS.md` | 1-729 | mechanic narrative, donor formulas, estimated flags, known gaps (:551-553), audit (:661-729) |
| `app/mechanics.json` | 1-1418, `version:2`, **189 values** (:3) | machine-readable mechanic list; 20 groups |
| `docs/audit/RENDER_ARCH_PORT_FEASIBILITY.md` | 1-300 (R-ARCH-PORT3D, 2026-11-21) | §2 subsystem targets :58-75; §3 SHARE/rewrite :81-103; §5 risks :193-244; §6 claims :250-269; §7 open questions :273-296 |
| `docs/coord_swarm_2026-11-24/WAVE7_3D_VARIANT_CHARTER.md` | 29-38 (GOVERNING RULE), 40-49 (phase owners) | donor-as-source-of-truth rule; **D-12 singleplayer-skirmish-only scope**; phase-2 owner slots V7-3…V7-9 |
| `docs/coord_swarm_2026-11-24/reports/G31_donor_3d_truth.md` | 40-63, 97-130, 193-219 | donor is **perspective**, not ortho; live skinned meshes; dump grid facts |
| `docs/audit/RENDER_ARCH_{CAMERA,UNITS,SHADERS,SYNTHESIS}.md`, `WATER_REPORT.md`, `TERRAIN_DONOR_WATER.md`, `docs/coord_swarm_2026-11-24/reports/R10_environment.md` | evidence lines per §2.4 | donor `camera.cfg`, `.oss/.osm/.aaf`, `shaders.lib`, `light.cfg`/`env.cfg`, water/env sources for §2.4 |
| `app/scripts/{world,main,hud,input_controller,camera}.gd` | read-only spot reads | exact 2D contract definitions in §3 |

**Labels:** `OBSERVED` = literal cited file line; `DERIVED` = arithmetic/control-flow consequence; `UNVERIFIED` = cannot be proven without donor visuals or a Godot/donor run.

**Governing rule and scope (coordinator directive, `WAVE7_3D_VARIANT_CHARTER.md:29-38`):** the 3D variant must **translate existing donor code/data, not invent mechanics**. Every ADAPT/NEW item is therefore mapped to a donor source of truth in §2.4. Where no readable donor source was found, the item is marked **UNVERIFIED** — no invented constant, shader, rig or algorithm is proposed. **Product scope is SINGLEPLAYER SKIRMISH ONLY (D-12)**: menu shell and nation/map/start options are in scope; campaigns, missions, DLC map files, cutscenes and network are explicitly **DEFERRED** and are not targets of any 3D test below.

**Two important corrections to the R-ARCH study, carried forward:**
1. The study's "ortho camera" premise (`RENDER_ARCH_PORT_FEASIBILITY.md:12-14`, target at :63, yaw 45° proxy at :234-237) is **superseded** for the donor: G31 re-verified the main donor view is `PROJECTION_PERSPECTIVE`, tilt −32°, focal 400, with no ortho extent key (`G31_donor_3d_truth.md:40-63`, claim 1 at :225). The WAVE7 charter already says "perspective" (`WAVE7_3D_VARIANT_CHARTER.md:22`). Keep −32°; treat yaw/FOV as assumptions awaiting A/B.
2. The study's `file:line` values were taken against the 2026-11-21 working tree and **have drifted**. Example: study `main.gd:400-430/:553-594` construction vs re-verified 2026-11-24 `main.gd:558/563/587` and `:919/923/959`; study `main.gd:1042` `world.sync` vs re-read `:1443`; study `hud.gd:1065` minimap box vs re-read `:1394`. **Quoted seam numbers below are the study's (as requested); re-verified current numbers are given alongside. Re-check before editing.**

## 1. Disposition legend

| Code | Meaning | Rule |
|---|---|---|
| **SHARE VERBATIM** | Copy unchanged into `variant3d/`; zero edits, runs in headless 3D project | study §3 `:83-90` (sim/generator/AI/orders/HUD data/minimap data/save-load/dump) |
| **ADAPT SEAM** | Same data + API; only the screen↔world / camera-derived adapter changes | study C5-C7 `:256-258`, C6 `:257`, targets :71-73 |
| **NEW 3D** | New subsystem/file; no 2D draw code is reusable | study §2 `:62-70` |
| **BLOCKED / UNVERIFIED** | Donor visual or conversion prerequisite missing; cannot be honestly claimed yet | study §5 `:212-228`; G31 `:111-130` |

Counts: **189** mechanics values (176 SHARE, 5 ADAPT, 8 SHARE+adapter/NEW modifiers), **29** selftest steps, **17** uitest steps, **24** manifest tests. No mechanic or test is omitted from §2/§4.

---

## 2. Test inventory — full disposition

Study seam codes used below (all from `RENDER_ARCH_PORT_FEASIBILITY.md`):

- **NONE-SHARE** — study §3 `:83-90`; no seam. C8 `:259` ("Sim/generator/AI/save/load carry no 3D dependency").
- **SEAM-MAIN** — `main.gd:400-430,553-594` + static typing `main.gd:44-46` (study `:24,:61,:252,:258`).
- **SEAM-WORLD** — common world contract / "world_base.gd or relaxed Node typing" (study `:61`), 2D outputs not reusable (study `:26,:94`, C2 `:253`).
- **SEAM-CAM** — `camera.gd:2,20,38,77` (study `:27,:63`, C7 `:258`).
- **SEAM-INPUT** — `input_controller.gd:10-12,226,234,258,453` (study `:30,:71,:96`, C5 `:256`).
- **SEAM-HUD** — `hud.gd:9,992,1039,1065,1072` (study `:31,:72,:73`, C6 `:257`).
- **SEAM-CONVERT** — `convert_models.py:43,69,109,135,143-147` (study `:32,:66,:68,:262`, C11 `:262`).
- **SEAM-TEST** — test/capture tooling (study `:74,:98,:244`, C16 `:267`).

### 2.1 `app/selftest.json` — 29 steps (`selftest.json:13-186`)

| # | step (`selftest.json` line) | mechanic | source file(s) | disposition | study seam | risk |
|---:|---|---|---|---|---|---|
| 1 | `move` :14-18 | continuous movement 1.5 m/s | `game.gd`, `data.gd` | **SHARE VERBATIM** | NONE-SHARE | low |
| 2 | `act` :20-24 | gather 45/load, 22 hits, deposit | `game.gd` | **SHARE VERBATIM** | NONE-SHARE | low |
| 3 | `fight` :26-30 | melee damage 8/1.25 s | `game.gd`, `data.gd` | **SHARE VERBATIM** | NONE-SHARE | low |
| 4 | `build` :32-36 | house built, 120 wood, 0.359 s/hit | `game.gd` | **SHARE VERBATIM** | NONE-SHARE | low |
| 5 | `train` :38-42 | peasant 100 food / 12.5 s | `game.gd` | **SHARE VERBATIM** | NONE-SHARE | low |
| 6 | `mine` :44-48 | mine 1.664/s per peasant, slots | `game.gd` | **SHARE VERBATIM** | NONE-SHARE | low |
| 7 | `hud` :50-54 | resource bar / minimap / selection panel / status drawn | `hud.gd`, `world.gd` | **ADAPT SEAM** (panels share data; minimap/draw need 3D) | SEAM-HUD, SEAM-WORLD | medium — 2D draw assertions must be replaced by 3D-specific assertions |
| 8 | `no_overlap` :56-60 | separation gap ≥ −0.25 m | `game.gd` | **SHARE VERBATIM** | NONE-SHARE | low |
| 9 | `volley` :62-66 | 2 shots, target hp 74; "smoke missing" | `game.gd` (sim) + `world.gd` FX | **SHARE sim / ADAPT FX** — dedicated 3D FX test required | SEAM-WORLD, SEAM-TEST | medium-high — 2D step passes *without* smoke; FX is unproven |
| 10 | `heal` :68-72 | priest 30→59 hp, 5 hp/s | `game.gd` | **SHARE VERBATIM** | NONE-SHARE | low |
| 11 | `morale` :74-78 | morale 70 near officer, no rout | `game.gd` | **SHARE VERBATIM** | NONE-SHARE | low |
| 12 | `upgrade` :80-84 | bla_sword1 researched | `game.gd`, `data.gd` | **SHARE VERBATIM** | NONE-SHARE | low |
| 13 | `market` :86-90 | 100 wood → 65 gold, rate 0.65 | `game.gd` | **SHARE VERBATIM** | NONE-SHARE | low |
| 14 | `capture` :92-96 | 3 peasants capture hall | `game.gd` | **SHARE VERBATIM** | NONE-SHARE | low |
| 15 | `squad` :98-102 | squad 2 soldiers, 2 line targets | `game.gd` | **SHARE VERBATIM** | NONE-SHARE | low |
| 16 | `formation` :104-108 | column set / disband | `game.gd` | **SHARE VERBATIM** | NONE-SHARE | low |
| 17 | `wall` :110-114 | stone wall built | `game.gd` | **SHARE VERBATIM** | NONE-SHARE | low |
| 18 | `shell` :116-120 | wall ok, rally set, objectives 2 | `game.gd`, `hud.gd` | **SHARE rule / ADAPT flag render** | SEAM-WORLD, SEAM-HUD | low-medium — flag is visual (study target :73, `:469` MECHANICS.md) |
| 19 | `formation_bonus` :122-126 | +2 atk / +7 hold bonus | `game.gd` | **SHARE VERBATIM** | NONE-SHARE | low |
| 20 | `replenish` :128-132 | 2 losses refilled within radius | `game.gd` | **SHARE VERBATIM** | NONE-SHARE | low |
| 21 | `flee` :134-138 | serdiuk falls back 3.0→3.9 m | `game.gd` | **SHARE VERBATIM** | NONE-SHARE | low |
| 22 | `garrison` :140-144 | 3 hidden / unload restored | `game.gd` | **SHARE VERBATIM** | NONE-SHARE | low |
| 23 | `peasant_capture` :146-150 | peasant captured: player 0 | `game.gd` | **SHARE VERBATIM** | NONE-SHARE | low |
| 24 | `resow` :152-156 | fields re-sown, mill auto=18 | `game.gd`, `ai.gd` | **SHARE VERBATIM** | NONE-SHARE | low |
| 25 | `attack_ground` :158-162 | cannon shells ground 56→65 | `game.gd` | **SHARE VERBATIM** | NONE-SHARE | low |
| 26 | `save_load` :164-168 | 69 entities serialize round-trip | `game.gd` (`serialize` `:4744`/`deserialize` `:4781`) | **SHARE VERBATIM** (fog reset adapter only) | SEAM-MAIN (`main.gd:836-838` study; re-read `:1223-1224`) | low |
| 27 | `grid_equiv` :170-174 | grid vs brute force 10 points | `game.gd` | **SHARE VERBATIM** | NONE-SHARE | low |
| 28 | `farm_cap` :176-180 | farm 500→525→500 | `game.gd` | **SHARE VERBATIM** | NONE-SHARE | low |
| 29 | `nav_detour` :182-186 | walked around 24 m wall | `game.gd`, `nav.gd` | **SHARE VERBATIM** | NONE-SHARE (study §3 `:84`) | low |

### 2.2 `app/uitest.json` — 17 steps (`uitest.json:4-88`)

| # | step (`uitest.json` line) | mechanic | source file(s) | disposition | study seam | risk |
|---:|---|---|---|---|---|---|
| 1 | `menu_shell` :5-8 | tur vs rus applied, hall present | `menu.gd`, `main.gd`, `game.gd` | **SHARE + ADAPT** (mode OptionButton new) | SEAM-MAIN (study `:60`, `menu.gd:274-310,459`) | low-medium |
| 2 | `select_box` :10-13 | 3 peasants in selection box | `input_controller.gd`, `world.gd` | **ADAPT SEAM** (`_pick` internals; aura visual) | SEAM-INPUT, SEAM-WORLD | medium — selection state shared, hit-test 3D |
| 3 | `order_keys` :15-18 | attack-move / stand / engage / pause | `input_controller.gd`, `game.gd` | **SHARE rule / ADAPT screen→world** | SEAM-INPUT | medium |
| 4 | `build_flow` :20-23 | site placed, builders 1 | `input_controller.gd`, `game.gd`, `world.gd` ghost | **SHARE rule / ADAPT ghost** | SEAM-INPUT, SEAM-WORLD (ghost at study `:73`) | medium |
| 5 | `train_flow` :25-28 | buttons listed, queue 0→1 | `hud.gd`, `game.gd` | **SHARE VERBATIM** | NONE-SHARE (study `:88`) | low |
| 6 | `squad_keys` :30-33 | F form, J/K/L shapes, disband | `input_controller.gd`, `game.gd` | **SHARE VERBATIM** | NONE-SHARE | low |
| 7 | `rally_panel` :35-38 | rally flag set | `input_controller.gd`, `world.gd`, `game.gd` | **ADAPT SEAM** (flag is a visual) | SEAM-WORLD, SEAM-INPUT | low-medium |
| 8 | `market_panel` :40-43 | 100 wood→65 gold | `hud.gd`, `game.gd` | **SHARE VERBATIM** | NONE-SHARE | low |
| 9 | `research_panel` :45-48 | buttons listed, bla_sword1 done | `hud.gd`, `game.gd` | **SHARE VERBATIM** | NONE-SHARE | low |
| 10 | `delete_key` :50-53 | own selection deleted, score kept | `input_controller.gd`, `game.gd` | **SHARE VERBATIM** | NONE-SHARE | low |
| 11 | `speed_pause` :55-58 | 2x speed | `main.gd`, `game.gd` | **SHARE VERBATIM** | NONE-SHARE | low |
| 12 | `cursor_ctx` :60-63 | 12 cursors loaded, default set | `assets/ui/cursors`, `input_controller.gd` | **ADAPT SEAM** (cursor layer/windowing) | SEAM-INPUT | low |
| 13 | `groups` :65-68 | Ctrl+1 store, 1 recall 2 | `input_controller.gd`, `game.gd` | **SHARE VERBATIM** | NONE-SHARE | low |
| 14 | `minimap_frustum` :70-73 | minimap bottom-left + view box | `hud.gd` | **ADAPT SEAM** | SEAM-HUD (study `:72`, C6 `:257`) | medium — `get_camera_2d()` null in 3D |
| 15 | `garrison_keys` :75-78 | U unloads | `input_controller.gd`, `game.gd` | **SHARE VERBATIM** | NONE-SHARE | low |
| 16 | `hotkeys_live` :80-83 | hold_fire/engage/attack_ground live | `input_controller.gd`, `game.gd` | **SHARE rule / ADAPT screen→world** | SEAM-INPUT | medium |
| 17 | `save_load_ui` :85-88 | F5/F9 round-trip | `main.gd`, `game.gd` | **SHARE VERBATIM** (fog adapter) | SEAM-MAIN (study `:74`, `:90`) | low |

### 2.3 `app/tests/manifest.json` — all 24 `t_*` tests (`:5-195`)

| id (`manifest.json` line) | feature | source file(s) | disposition | study seam | risk |
|---|---|---|---|---|---|
| `t_build_flow` :6-12 | placement/blocking | `tests/building_block_test.gd`, `game.gd`, `input_controller.gd` | **SHARE rule / ADAPT click→metres, ghost** | SEAM-INPUT, SEAM-WORLD | medium |
| `t_mill_logic` :13-19 | windmill production | `tests/mill_logic_test.gd`, `game.gd` | **SHARE VERBATIM** | NONE-SHARE | low |
| `t_mine_unified` :20-26 | mine income/upgrades | `tests/unified_mine_test.gd`, `game.gd` | **SHARE VERBATIM** | NONE-SHARE | low |
| `t_visual_tuning` :27-33 | visual metrics (2D sprite metrics) | `tests/visual_tuning_test.gd`, `world.gd` | **NEW 3D test** (2D metric target not applicable) | SEAM-WORLD, SEAM-TEST | medium-high |
| `t_mill_rotor` :34-41 | rotor render, `windowed:true` | `tests/mill_render_test.gd`, `world.gd` | **NEW 3D test** (re-bind rotor to mesh/rig) | SEAM-WORLD, SEAM-CONVERT | high |
| `t_upgrades` :42-49 | upgrade tree depth | `tests/t_upgrades.gd`, `game.gd`, `data.gd` | **SHARE VERBATIM** | NONE-SHARE | low |
| `t_roster_scotland` :50-57 | Scotland + nation-unique units | `tests/t_roster_scotland.gd`, `game.gd`, `data.gd` | **SHARE rule / NEW 3D per-nation meshes** | SEAM-CONVERT (study `:66`) | medium-high |
| `t_squads` :58-65 | formation/replenish/disband | `tests/t_squads.gd`, `game.gd` | **SHARE VERBATIM** | NONE-SHARE | low |
| `t_multi_ai` :66-73 | 2+ AI opponents | `tests/t_multi_ai.gd`, `ai.gd` | **SHARE VERBATIM** | NONE-SHARE (study `:85`) | low |
| `t_teams` :74-81 | teams/diplomacy | `tests/t_teams.gd`, `game.gd` | **SHARE VERBATIM** | NONE-SHARE | low |
| `t_smoke_fx` :82-89 | smoke/muzzle/arrow trails | `tests/t_smoke_fx.gd`, `world.gd` FX | **NEW 3D test** | SEAM-WORLD (study `:73`, `:178`) | high — 2D `volley` admits smoke missing |
| `t_water` :90-97 | animated water/shoreline | `tests/t_water.gd`, `world.gd` water overlay | **NEW 3D test** (canvas_item→spatial) | SEAM-WORLD (study `:69`) | medium-high |
| `t_weather` :98-105 | seasons/weather/day-night, **`pending`** | `tests/t_weather.gd`, `world.gd` | **NEW 3D test** (still pending in 2D) | SEAM-TEST (study `:74`) | high — no 2D baseline |
| `t_hud_fidelity` :106-113 | HUD information fidelity | `tests/t_hud_fidelity.gd`, `hud.gd` | **SHARE data / ADAPT capture** | SEAM-HUD, SEAM-TEST | medium |
| `t_anim_metrics` :114-121 | animation duration/metrics | `tests/t_anim_metrics.gd`, `world.gd`, `assets/models/anim` | **BLOCKED / NEW 3D** (2D sheet metrics only) | SEAM-CONVERT (study `:67`, C11 `:262`) | high |
| `t_naval` :122-129 | yacht sprite + hull composite | `tests/t_naval.gd`, `assets/models/sprites` | **NEW 3D test** (yacht .oss is 311f/20 bones) | SEAM-CONVERT; G31 `:113-118` | high |
| `t_mass_army` :130-137 | large army performance/corpses | `tests/t_mass_army.gd`, `game.gd`, `world.gd` | **SHARE sim / NEW 3D perf gate** | SEAM-TEST (study `:75`, `:204-207`) | high — MultiMesh mandatory |
| `t_map_variety` :138-145 | seed variety / skirmish options | `tests/t_map_variety.gd`, `game.gd`, `mapgen.gd` | **SHARE VERBATIM** | NONE-SHARE (study `:84`) | low |
| `t_capture` :146-153 | building/unit capture rules | `tests/t_capture.gd`, `game.gd` | **SHARE VERBATIM** | NONE-SHARE | low |
| `t_audio_events` :154-161 | audio event→file mapping | `tests/t_audio_events.gd`, `audio.gd`, `main.gd` | **SHARE VERBATIM** | NONE-SHARE (event stream :1104) | low |
| `t_pick_res` :162-169 | `_pick_res` harvest lookup | `tests/t_pick_res.gd`, `input_controller.gd` | **ADAPT SEAM** (grid lookup shared, raycast new) | SEAM-INPUT (study `:71`) | medium |
| `t_forest_dense` :170-177 | packed forest groves | `tests/t_forest_dense.gd`, `game.gd`, `world.gd` | **SHARE generator / NEW 3D tree meshes** | SEAM-CONVERT | medium-high |
| `t_forest_bake` :178-185 | forest-detail chunk baking | `tests/t_forest_bake.gd`, `world.gd` | **NEW 3D** (2D CPU bake not reusable) | SEAM-WORLD (study `:94`, `:97`) | high |
| `t_forest_bake_render` :186-194 | forest bake GPU readback, `windowed:true` | `tests/t_forest_bake_render.gd`, `world.gd` | **NEW 3D windowed gate** | SEAM-TEST (study `:244`) | high |

---

## 2.4 DONOR SOURCE OF TRUTH for every ADAPT / NEW / BLOCKED 3D item

Governing rule (`WAVE7_3D_VARIANT_CHARTER.md:29-38`): **translate donor, do not invent.** This section covers every row in §2.1-§2.3 marked ADAPT, NEW or BLOCKED, plus the render-side members of §3. "Readable" means a donor path:line or evidence id was re-read in a cited report; **no readable donor source ⇒ UNVERIFIED, no proposed substitute value.** Donor reads are read-only (Python bytes + latin-1); no donor file was run or copied.

| 3D item (all affected test ids) | Owner | Donor source of truth — path:line / evidence id | Readable? | Translation duty / honest limit |
|---|---|---|---|---|
| **Camera**: perspective not ortho; tilt −32°; dolly 20…58; focal 400; zoom wheel = focal ±5; edge/key scroll (`uitest minimap_frustum`, `cursor_ctx`; `mechanics.json` camera group #9-13; contract `view_rect`) | V7-5 / V7-3 | `data\cameras\camera.cfg:6-10` (SphereHeight 58/min 20), `:32-35` (all tilt −32), `:44-45` (focal 400), `:51-64` (DOF/DynFog); `data\cameras\default.cameras:5-18`; `data\gui\menu.inc\onresize.inc:77-110,119-126`; `onmousewheel.inc:315,322-336`; `docreate.inc:59,86-94`; evidence `RENDER_ARCH_CAMERA.md:46-56,128-148,175-184`, G31 `:42-63`, claim 1 `:225` | **YES** | Use `PROJECTION_PERSPECTIVE` + tilt −32° + dolly. **Yaw and absolute FOV/sensor are UNVERIFIED** (`G31:227,262-263`; 2.90° vs 17.27° V-FOV are assumptions) — record as A/B candidates, not constants. |
| **Picking / screen→world / drag selection** (`uitest select_box`, `order_keys`, `build_flow`, `hotkeys_live`, `t_pick_res`, `t_build_flow`; contract selection state) | V7-5 | Donor ray API name `ScreenToWorldRayCast` at `onresize.inc:66-69`, `onmousewheel.inc:315` (`RENDER_ARCH_CAMERA.md:143-146,221`); world-space camera `default.cameras:5-16` (`DirZ=-1`, `UpY=1`) | **PARTIAL** | Ground-plane ray ∩ heightfield follows the donor API name. Exact donor hit-test radius/depth-order algorithm: **UNVERIFIED** (no readable donor source); do not invent a new selection rule — reuse `game.pick_radius` and `input_controller._pick` semantics. |
| **Minimap viewport box** (`uitest minimap_frustum`, `t_hud_fidelity`; contract `view_rect`, `world_to_px`) | V7-6 | No donor path:line re-read for the box itself. `RENDER_ARCH_CAMERA.md:223-226` derives the need to project through the 3D frustum; `MECHANICS.md:625` names donor `data/gui/minimap.cfg` (bottom-left zone) but no line was re-read here. | **UNVERIFIED** | Keep minimap *data* verbatim (study `:89`); camera-derived box must be measured in 3D. Whether donor minimap rotates with yaw: **UNVERIFIED** (study Q9 `:293-294`). |
| **FX / smoke / muzzle / trails / projectiles / ghost / rally flag** (`selftest volley` #9 "smoke missing", `shell` #18; `t_smoke_fx`; contract `fx_layer`, `add_fx`) | V7-4 | No readable donor FX config found in the cited evidence. 2D `volley` passes with smoke absent (`selftest.json:62`); `mechanics.json` FX numbers are estimated (e.g. corpse life :1377-1384). | **UNVERIFIED** | Do not invent particle counts/timings. Represent every `main._consume_events` (`main.gd:1503`) type in 3D; accept "no donor config" as an explicit gap, not a fabricated value. |
| **Terrain heightfield mesh + vertex/texture splat** (`mechanics.json` hills #177; `t_visual_tuning`; contract `has_chunk_or_fallback`) | V7-4 | `data\scripts\lib\miscext2.script:19-26,45` (grid 256/320/480/640); `dmscript.global:132-135`; `generatemap.inc:230-243,537-577` (bitmap→height→smooth); `texturemap.inc:433-437`; `loadtextureterrainfrombitmap.inc:8-42`; `data\gen\mapcover.cfg:5-18`; `data\pattern\pattern.lib:8-33`; evidence G31 `:67-96`, claims 5-6 `:229-230`, dump mapping `:211-217` | **YES** | One vertex per `height[idx=y*W+x]`, smooth normals, splat by `tileblock`/height. **Height-grid→mesh LOD connector is UNVERIFIED** (`G31:36,105,265`); do not invent a decimation scheme. |
| **Relief props / steep-face art** (`t_forest_dense`, terrain visual gates) | V7-4 / V7-9 | `data\actors\env\terrainmesh{1,2,3,4}.osm` header-decoded 2662/5305, 2272/4532, 2177/4323, 2509/5002 v/f; `terrainmesh1.actor:1-5`; `actors.lib:1200-1213`; summer/winter DDS albedo (`G31:97-105`, claim 7 `:231`) | **YES** | Donor uses discrete LOD relief meshes; a smooth heightmap alone cannot supply them. Add as deferred M1+ props, not invented face art. |
| **Lighting / shadows / env palette** (`t_mass_army` visual, `t_weather`; contract fog shading) | V7-9 | `data\env\lights\light.cfg:17,26-30` `Position=(-0.3447,0.9387,0,1)`, palette `:3-16` Ambient (.196,.184,.129) / Diffuse (.812,.780,.694) / Specular (.278,.267,.212), `LightStyle=lsParallel`; mapping via `water.dev.vert:22` → `(-0.08618,0,0.9387)` (`WATER_REPORT.md:159,345,390`, `TERRAIN_DONOR_WATER.md:92`, `R10_environment.md:30`); shadow shaders `shaders.lib:15-52`, `hf.pvl.smx3.frag:3,26-30`, `smx9.frag:25-34` (`G31:89-96`) | **YES** | Translate donor sun/palette and PCF-style shadows; `gl_compatibility` budget must be measured (study `:195-200`). Time-of-day override of the static sun: **UNVERIFIED** (`TERRAIN_DONOR_WATER.md:228`). |
| **Seasons / weather / day-night** (`t_weather` — `pending` in 2D, `manifest.json:98-105`) | V7-9 | `data\env\env.cfg:15-26` loaders (time/colours/sky/clouds/flares/lights/PFX), `env\time.cfg:5-9`, `env\lights\light.presets`, `stars.cfg:7-8`; **day/night manager disabled**: `scripts\lib\init.script:99 SetDateTimeManagerEnabled(false)`, `light.ref:116 DateTimeEnable=False` (`R10_environment.md:12,28`) | **YES (but skirmish-disabled)** | Translate donor env *pieces* only; do not add a donor-disabled day/night cycle. No 2D baseline (test pending) and rain is **not** a donor skirmish feature (`R10:12`) — leave deferred, no invented weather. |
| **Fog of war overlay** (contract `fog_explored`/`fog_vis`; M3 parity gate `:176-178`) | V7-4 | Donor per-fragment view-depth fog: `pvl.smx3.id0.frag:29-43` LINEAR/EXP/EXP2; `def.pvl.sm.vert:38-42` (`RENDER_ARCH_SHADERS.md:150-151`, E19/E20); camera `DynFog*` keys `camera.cfg:51-64`; **engine binding to `fog_explored`/`fog_vis` not readable** | **PARTIAL** | Keep the sim arrays verbatim; port the donor fog *math* as spatial shading. Exact donor fog↔explored-state mapping: **UNVERIFIED** — do not invent a new fog rule. |
| **Water plane / spatial shader** (`t_water`) | V7-9 | `data\water\water.lib:45,60` (HeightMapEnable=True, waves commented); `shaders\water\water.dev.frag:42,43,47` (glint exponents/specular), `water.dev.vert:22`; sun from `light.cfg:26-30`; `env\env.cfg`/`time.cfg` have no water keys (`TERRAIN_DONOR_WATER.md:14,92,198`, `WATER_REPORT.md:32,390`) | **PARTIAL** | Translate donor wave/glint equations to `shader_type spatial`. Literal engine binding of `hmapTex`: **UNVERIFIED** (`G31:106-109,269`) — do not bind `heightmapwaves0.tga` as a substitute. |
| **Meshes: units / buildings / trees / naval** (`t_roster_scotland` visual, `t_naval`, `t_forest_dense`, `t_forest_bake`, `t_forest_bake_render`, `t_mill_rotor`) | V7-8 | `.oss` `<6i k,fps,b,v,fc,t>` + bind verts + per-vertex weights + `b×k×7f` bone tracks (`RENDER_ARCH_UNITS.md:10-11,22`); `peaukr.oss` 20 bones / **483** frames @30 fps, `yacht.oss` 20 bones / 311 frames (`:63-65`, D2); `.osm` IDP2 (68-byte header) for buildings/props; donor inventory 3,897 `.osm` + 335 `.oss` (`:76-77`, D8); trees `spruce1.osm`/`pine1.osm` have a second vertex frame (`:53-57`, C3) | **YES** | Re-convert to `.glb`: Y-up, normals/tangents, alpha preserved, scale from manifest/donor bbox. 3,897 mesh figure is donor-side evidence D8 (R-ARCH study C13 `:264` called it owner-supplied/unverified — treat as donor-reported, not in-repo). Second tree-frame meaning: **UNVERIFIED** (`RENDER_ARCH_UNITS.md:242-243`). |
| **Skinning / animation / rig** (`t_anim_metrics`, `t_mill_rotor`; `mechanics.json` art #129-132) | V7-8 | Donor skinning `v_pose = Σ w(R(f)v+p(f))`, frame 0 identity (`mechanics.json:946-950`, measured from `.oss`); `boneMatrices[16]` in all shader programs (`RENDER_ARCH_SYNTHESIS.md:19`); `.aaf` action ranges `peaukr.aaf walk 1..20, idle 64..113, construct 186..198, idlewood 354..403, reaction 456..481` (`RENDER_ARCH_UNITS.md:97-99`, D3); zero `turn/rotat/scale` actions in 246 `.aaf` (`:101-102`, C4) | **YES** | Arbitrary yaw is a renderer transform, not stored frames (C4). New rig export pass required (`RENDER_ARCH_UNITS.md:179-184`): donor skinned frames are discarded by `convert_models.py:109`. Exact per-frame bone-to-Godot mapping: **UNVERIFIED** until V7-2 report. |
| **Construction stages / rubble** (`selftest build` 2D fallback; `mechanics.json:1308-1313`) | V7-8 / V7-9 | Donor `<nat><bld>1..4.osm` + `_death2.osm` exist (`mechanics.json:1308-1313`); donor mesh files readable | **PARTIAL** | Meshes exist; 2D skipped stages on vertex-count mismatch (`MECHANICS.md:593-596`). Per-frame skinning/stage switching path in 3D: **UNVERIFIED** — do not invent a stage shader. |
| **Render mode flag / skirmish menu shell** (`uitest menu_shell`, `selftest shell`; study targets `:60`, `:111-116`) | V7-3 | Skirmish subset: `data\game\var\generator.cfg` TerrainTypes, `startingsettings.cfg` gc_mapsettings (`mechanics.json:794-808`), `menu.cfg`; campaigns/battles cfg are **D-12 deferred** | **PARTIAL** | Add mode OptionButton default `2d`; only singleplayer skirmish options in scope. No donor "render mode" flag exists — this is a port-side switch, not a donor mechanic; mark as port addition, not invented donor logic. |
| **HUD capture / panel fidelity** (`t_hud_fidelity`, `uitest train_flow`/`market_panel`/`research_panel` data SHARE) | V7-6 / V7-7 | Donor HUD zones per `MECHANICS.md:623-629` (top bar, minimap bottom-left, portraits bottom-center, command grid bottom-right); no donor 3D HUD path:line re-read | **PARTIAL** | Panels read sim dictionaries verbatim; only capture/box adapter changes. Exact donor 3D HUD overlay layout: **UNVERIFIED**. |
| **Save/load render reset** (`selftest save_load`, `uitest save_load_ui`) | V7-3 | Donor N/A — render-state adapter only; sim `serialize`/`deserialize` shared (study `:90`) | **N/A** | Keep `game_load` fog reset (`main.gd:1223-1224`; study `:836-838`); no donor value needed. |
| **Mass-army performance gate** (`t_mass_army`; study `:75`, `:204-207`) | V7-7 / V7-8 | Donor EXE RTTI includes `Billboard` ×7 (`G31:58`); no readable budget/config | **UNVERIFIED** | Batch by sid/facing with `MultiMesh` (study `:206`) but **measure**, do not assert a donor draw-call target. |

**Summary of UNVERIFIED items (explicit, no invented substitutes):** camera yaw/FOV sensor; minimap box rotation; FX particle constants; height→mesh LOD connector; donor fog↔explored binding; water `hmapTex` binding & time-of-day sun override; second tree vertex frame; per-frame bone export mapping; 3D stage/rubble switching; 3D HUD overlay layout; mass-army budget; donor render-mode flag (port addition, not donor mechanic).

---

## 3. World contract the 3D renderer must implement

The study names the required members at `RENDER_ARCH_PORT_FEASIBILITY.md:61` (subsystem 2, risk Medium) and explains the blocking static types at `:131-135`, C7 `:258`. Exact 2D definitions re-read 2026-11-24:

| Contract member | Exact 2D definition (file:line) | Data-only vs rendering | 3D implementation duty |
|---|---|---|---|
| `bind(game)` | `world.gd:237-348` `func bind(g: C3Game, h: CanvasLayer = null)`; sets `game`, `hud`, `view_scale = Data.PIXELS_PER_METER` :240; creates layers incl. `fx_layer` :310-316; sizes fog arrays :333-347. Input controller twin: `input_controller.gd:51` `bind(g, w, h, cam)`. | **Both**: takes data (game/hud) but constructs render nodes | `C3World3D.bind` keeps signature; creates `Node3D` layers / `WorldEnvironment` instead of `Node2D`; no sim mutation |
| `sync(dt)` | `world.gd:2072-2081` `func sync(dt)`; `view_rect = get_viewport().get_canvas_transform().affine_inverse() * get_viewport_rect()` :2075; derives chunk bounds :2078; `fx_layer.queue_redraw()` :2124. Driver: `main.gd:1443` (study cited `:1042`). | **Both**: derives data (`view_rect`) and redraws | Compute visible ground quad via `Camera3D` ray/frustum; update terrain chunks, fog shading, FX; keep `dt` sim-agnostic |
| `view_scale` | `world.gd:22` `var view_scale := 16.0 # screen px per meter`; set to `Data.PIXELS_PER_METER` at :240; `data.gd:113` = 16. | **Data-only scalar** (metres → canvas px) | Keep for minimap/FX parity; define a separate metres→viewport-px factor if needed. Do not change the scalar's meaning for shared callers. |
| `world_to_px(p)` | `world.gd:350-351` `return p * view_scale`; called by `input_controller.gd:325,329` (patrol path) and FX lines :3601. | **Pure data function**; output is canvas px | Keep signature; implement as camera projection+viewport transform if callers expect screen px. Study target :61. |
| `fx_layer` | `world.gd:126` `var fx_layer: Node2D`; created :310-312, `draw` connected :316; ghost drawing :3520-3537; `_draw_fx` :3563-3661. | **Rendering node** | Provide an equivalent node/group that accepts ghost + FX draws; kept behind the same API for `main._consume_events` (`main.gd:1503`, study `:1104`) |
| `view_rect` | `world.gd:129` `var view_rect := Rect2(0,0,1,1)`; assigned :2075, consumed :1753-1755 (px→m at :1754), :2490-2498, :2705, :2841, :3236, :3440. | **Data** derived from camera, but in 2D canvas px | Must be produced from the 3D camera's visible ground area (axis-aligned rect under yaw is an approximation — study open Q9 `:293-294`). Pixel/metre mix-up is a recorded bug (`MECHANICS.md:605`). |
| `fog_explored` / `fog_vis` | `world.gd:27-28` `PackedByteArray`; sized :333-334; filled :2226-2246; `tile_visible` :2264, `tile_explored` :2272; reset on load `main.gd:1223-1224` (study `:836-838`). | **Data-only arrays** (sim-derived) | Keep arrays verbatim; replace the full-map `Sprite2D` overlay (study `:70`, `:70` risk Medium) with per-tile vertex-colour/shader shading; entity visibility filter must read the same arrays |
| `add_fx(kind,pos)` | `world.gd:3563-3568` `func add_fx(kind: String, pos: Vector2)` (life by kind); emitted by `main._consume_events` :1503. | **API data / rendering result** | Same signature; spawn spatial quads/particles. Study :73 "3D quads/particles" |
| `has_chunk_or_fallback(k)` | `world.gd:1746-1747` `return terrain_chunks.has(k) or fallback_chunks.has(k)`; used by forest-bake tests; bounds helper :1752-1759. | **Data query** (test hook) | Implement over 3D chunk dictionary or return `true` when the full mesh is resident (M1 builds whole 320², so this is trivially true — record in 3D test) |
| selection state | `input_controller.gd:13-15` `selected_ids`, `drag_start`, `dragging`; `_set_selection` :148-158 writes `e["selected"]` and calls `hud.refresh_selection`; `game.get_selected()` at :448; entity flag consumed by `world.gd` selection collar (e.g. :2864, :3017). | **Data on entities** (`selected` bool) + controller-local ids; ring/aura is rendering | Keep `selected_ids` + `e["selected"]` untouched; draw a 3D selection ring/aura from the same flag. Dragged box (`_screen_to_world` endpoints) is the only new geometry. |

**Typed seams that block drop-in assignment** (study C7 `:258`): `main.gd:43-46` (`C3WorldScript`, `C3CameraScript`, `C3InputScript` preloads), `input_controller.gd:10-12` (`var world: C3World`, `camera: C3Camera`), `hud.gd:9` (`var world: C3World`), `camera.gd:10` (`var world: C3World`). Chosen fix per study `:131-135`: a tiny shared base/interface node (or relaxed `Node` typing with guarded access) in `variant3d/`.

**Data-only vs rendering — one-line rule:** every member above except `fx_layer`, the fog *overlay*, the selection *aura*, the ghost and the chunk *meshes* is data/API and must not change semantics; if a 3D implementation changes a data member's meaning, the shared sim/tests break.

---

## 4. Minimal phase-2 file ownership plan (disjoint files)

Refines `WAVE7_3D_VARIANT_CHARTER.md:36-38`. Assumption: `variant3d/` scaffold (V7-0) has landed first. **No file appears in two rows.**

| Owner | Files owned (all under `variant3d/`) | Scope / boundary |
|---|---|---|
| **V7-3** | `project.godot`, `scripts/main.gd`, `scripts/config.gd`, `scripts/data.gd`, `scripts/menu.gd` | `render_mode` flag (study `:60`, `:111-116`); world/camera/input dispatch at re-read `main.gd:558/563/587` and `:919/923/959`; relax static types; add 3D camera constants without touching sim numbers; **perspective** camera (G31 `:225`) |
| **V7-4** | `scripts/world3d.gd` (new), `scripts/world3d_terrain.gd` (new) | Full §3 contract; heightfield `ArrayMesh` from `game.height` `idx=y*W+x` (G31 `:211-217`); chunking `CHUNK_T=32`; fog shading; FX/ghost draws; **no** shader/scene files |
| **V7-5** | `scripts/camera3d.gd` (new), `scripts/input_controller.gd` | `PROJECTION_PERSPECTIVE`, tilt −32°, clamp/zoom-at-cursor; `_screen_to_world3d` ground-ray ∩ heightfield + screen-space entity pick; `game.cmd_*` calls unchanged (study `:71`) |
| **V7-6** | `scripts/hud.gd` | Only the camera-derived viewport box (re-read `:1394-1403`; study `:1065-1096`); minimap image + orders stay verbatim |
| **V7-7** | `tests/**` (all `t_*.gd`, `selftest.json`, `uitest.json`, new `t_3d_*`), `tools/godot_runner.py` (3D capture branch only) | 3D-specific gates for `hud`, `volley`, water, FX, picking, mass army; keep 2D gates intact (study `:98`, `:244`) |
| **V7-8** | `tools/convert_models_3d.py` (new), `tools/convert_terrain_3d.py` (new), `scripts/anim3d.gd` (new), `assets/models/glb/**` (new) | Y-up + normals/tangents + alpha, `.glb`, skin clips or per-frame meshes (study `:66-68`, C11 `:262`); **BLOCKED** until donor rig/alpha verified — do not touch `assets/models/obj/**` |
| **V7-9** | `scenes/*.tscn` (incl. `world3d.tscn`), `shaders/*.gdshader`, `docs/variant3d/**` | `WorldEnvironment` + `DirectionalLight3D`, spatial water material, fog material, quality budget; visual A/B anchors from `docs/audit/TERRAIN_REFERENCE_IMAGES.md:23` |

V7-1 owns **only** `docs/coord_swarm_2026-11-24/reports/V71_mechanics_inventory.md` (this file); V7-2 owns `V72_mesh_conversion_feasibility.md`. No phase-2 worker edits `app/**` or another worker's `variant3d` file.

---

## 5. Honest risks — what the 29 selftest steps can and cannot prove in 3D

### 5.1 Headless in 3D variant, unchanged (27 of 29)

Steps 1-6, 8, 10-29 of §2.1: `move`, `act`, `fight`, `build`, `train`, `mine`, `no_overlap`, `heal`, `morale`, `upgrade`, `market`, `capture`, `squad`, `formation`, `wall`, `shell`, `formation_bonus`, `replenish`, `flee`, `garrison`, `peasant_capture`, `resow`, `attack_ground`, `save_load`, `grid_equiv`, `farm_cap`, `nav_detour`.

Rationale: all drive `game.cmd_*` / sim arrays and read sim results; study C8 `:259`, §3 `:83-90` ("no render types referenced"). `save_load` needs the one documented fog-reset adapter (`main.gd:1223-1224`; study `:836-838`). Headless/CLI/`--dump-map` build no world (`study :43, :187-189`), so these are *sim-only* passes — they do **not** prove any 3D rendering.

### 5.2 Need a 3D-specific test (2 of 29 + new gates)

- `hud` (#7) — asserts "resource bar / minimap / selection panel / status text drawn"; `hud.gd` minimap box uses `get_camera_2d()` (re-read `:1401`; study C6 `:257`) which is null in 3D. Requires V7-6 adapter + V7-7 new assertion.
- `volley` (#9) — `selftest.json:62` literally says "smoke missing"; the 2D suite passes with FX absent. A 3D FX representation must be proven by a new `t_3d_fx` gate, not by this step.
- Additional 3D-only gates not derivable from any of the 29: terrain mesh vertex/bbox parity (study M1 criterion 1 `:154-157`), camera projection/tilt (`:158-160`), non-blank capture/shoreline quadrant (`:161-164`), picking agreement ≥95% (M2 `:171-174`), fog visibility parity (M3 `:176-178`), draw-call/frame budget (M4 `:181-183`, C16 `:267`).

### 5.3 Cannot be proven without donor visuals (UNVERIFIED)

Per the governing rule, none of these receives an invented constant, shader or rig in this inventory — see §2.4 for the donor source (or explicit UNVERIFIED marker) behind each.

| Claim | Why blocked | Evidence |
|---|---|---|
| Exact donor unit/building/tree mesh look | 116 converted `.obj` only; no normals, no animation, Z-up, alpha forced RGB; donor has 3,897 meshes claimed but unverified | study `:212-221`, C11 `:262`, C12/C13 `:263-264` |
| Donor skinned `.oss` animation frames in 3D | Reader parses bone weights/frames but `write_obj` discards them; donor renders live `boneMatrices[16]` per frame | study `:67`, `:213-214`, C11 `:262`; G31 `:111-130` |
| Material/texture conversion fidelity | `.dds→.png` alpha flattened for units/buildings; sprite cell sizes (256/512/160 px) are port bake artifacts, not mesh resolution | study `:215-228`, C15 `:266`; `MECHANICS.md:491-493` |
| Donor camera yaw / absolute FOV | −32° tilt observed; yaw 45° inferred; focal 400 with unknown sensor → 2.90° vs 17.27° V-FOV assumptions | study `:234-237`; G31 `:225-227`, `:262-263` |
| Donor lighting/shadow/face-art appearance | `gl_compatibility` lacks SDFGI/VoxelGI/SSAO/SSR/volumetric fog; donor uses PCF3/9 + heightfield Blinn–Phong; M0.6 metrics passed while visual verdict failed | study `:195-200`, C16 `:267`; G31 `:150-164`, `:228-234` |
| Water/fog visual parity | donut shader is `canvas_item`; donor water `hmapTex` binding unverified; fog overlay replacement has no visual anchor | study `:69-70`; G31 `:106-109`, `:269` |
| Construction stages s1-s4 / rubble | 2D skipped them (vertex-count mismatch); donor `<nat><bld>1..4.osm` exist but no per-frame skinning path proven | `MECHANICS.md:593-596`; `mechanics.json:1308-1313`; study `:68` |

### 5.4 Other cross-cutting risks

- **No 3D precedent**: repo-wide grep for `MeshInstance3D|Camera3D|ArrayMesh|SurfaceTool|Node3D` = 0 functional hits; `world.gd` ~2,936 lines of CanvasItem code (study `:201-203`, C10 `:261`).
- **Mass army**: one `MeshInstance3D` per entity will not scale; `MultiMesh` mandatory and must be measured, not assumed (study `:204-207`).
- **Line drift**: study seam lines are from 2026-11-21; re-verified 2026-11-24 numbers differ (§0). Any worker copying study line numbers into code should re-read first.
- **Donor paradigm correction**: build a perspective camera, not the study's ortho target (G31 `:225`); otherwise M1 acceptance criterion 2 (`:158-160`) encodes the wrong projection.
- **Scope guard (D-12)**: `menu_shell`'s skirmish path (`uitest.json:5-8`) is in scope; Historical Battles / Campaigns / DLC maps / cutscenes / network from `MECHANICS.md:440-445` and `mechanics.json:922-935` are **deferred**, not 3D targets. Do not let a 3D test assert against those.

---

## 6. Open questions

1. Should the shared contract be a real base class (`world_base.gd`, study `:61`) or relaxed `Node` typing (`:131-135`)? V7-3 owns the decision; it changes four files' declarations.
2. Does `world_to_px`/`view_rect` stay in canvas px for 3D callers, or become viewport px? The 2D code mixes metres and canvas px and already caused a black-map bug (`MECHANICS.md:605`).
3. Who signs off the visual A/B anchors for terrain (study `:295-296`; G31 `:275`)? Metrics alone must not pass the gate (G31 `:234`).
4. Can donor skinned `.oss` frames be reconstructed for 3D (V7-2 report), or is per-frame baked mesh the only tractable path? This decides whether `t_anim_metrics` is NEW or permanently BLOCKED.
5. Is the minimap viewport box a projected ground quad or an axis-aligned approximation under yaw, and does the donor minimap rotate (study open Q9 `:293-294`)?
6. Does `render_mode` live only in the skirmish screen or also the persistent Options menu (study Q8 `:291-292`)?
7. Should the 3D variant keep the 2D `selftest.json` step *names* but different assertions, or add a separate `selftest3d.json`? V7-7 owns this; the 27 sim-only steps should stay byte-comparable either way.
8. The study's "512px baked" phrasing is about `sprites_hi`, not mesh pixel resolution (`:222-228`); confirm the owner's intent before treating it as a 3D texture requirement.

---

**End of inventory. Read-only recon: no `app/**` file, `variant3d/**` file, config, asset or Godot run was created or modified by V7-1.**
