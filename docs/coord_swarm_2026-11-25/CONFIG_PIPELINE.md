---
id: CONFIG-DOC-01
title: "CONFIG-DOC-01 — cold-readable status of the global configurability pipeline (3D variant)"
date: 2026-11-25
owner: CONFIG-DOC-01 (documentation micro-worker; read-only on code)
status: DOC_ONLY__NO_CODE_EDITS__NO_RUNNER_JOBS
scope: "Exactly one new file: docs/coord_swarm_2026-11-25/CONFIG_PIPELINE.md. Every report and config file below was read read-only; no code, config, test, asset, backup or runner job was created or edited."
labels: [observed, derived, inferred, UNVERIFIED, PORT_APPROXIMATION]
source_convention: "Report paths are relative to docs/coord_swarm_2026-11-25/reports/ unless a different folder is printed. `config.gd` = variant3d/scripts/config.gd; `config.json` = variant3d/config.json."
label_legend: "observed = literal read with file:line or report path; derived = arithmetic/enumeration from observed; inferred = plausible but unproven; UNVERIFIED = no accessible evidence; PORT APPROX = port substitute, never donor fact."
snapshot: "Working tree read on 2026-11-25. SWARM_BOARD.md is a snapshot and is stale for several CONFIG lanes; where a landed report contradicts the board, the report and the source file are authoritative (noted per row). Post-snapshot re-read (LINKS-FIX-01, 2026-11-25): reports/CONFIG_WIRE_RELIEF.md is now on disk although board :218 still says RUNNING; the 7/2/2/10 freeze, the file-ownership table and all verdicts are unchanged by that path landing."
---

# CONFIG-DOC-01 — global configurability: cold-readable pipeline status

## 0. How to read this document

This is a **status freeze**, not a plan and not a claim of completion. It answers four
questions for a reader who has no prior context:

1. What `features.*` keys actually exist in code today, and is each one **really** consumed? (§2)
2. What portion of the 55-feature plan is still unwired, and who owns each leftover? (§3)
3. What did the menu actually expose, and is each row functional or only a UI signal? (§4)
4. In what order must the remaining tickets land, and which file may each owner touch? (§5)

Risks and honesty caveats are in §6 and §7. Every substantive sentence carries a label
and a citation. Status vocabulary used in §2:

| Status | Meaning (definition used here) |
|---|---|
| **WIRED** | A typed getter is called from a consuming game file and the value reaches runtime behaviour under shipped defaults. |
| **READER_ONLY** | The getter is called, but its result only lands in `stats`/audit fields; no shader or behaviour path uses it. |
| **UI_ONLY** | The feature is surfaced in a menu row / emitted into `cfg`, but the namespaced `features.*` getter has no runtime consumer (yet). |
| **PENDING** | The getter and default exist in `config.gd`, but no consuming file calls the getter at all. |

---

## 1. Sources read (all read-only)

| Source | Role | Label |
|---|---|---|
| `CONFIG_PLAN_01.md` (459 lines) | 55-feature inventory, proposed `features` schema, UI subset, sequencing/risk plan | observed |
| `CONFIG_CORE_01.md` | 21 defaults + 21 typed getters delivered; `config.json` deliberately untouched | observed |
| `CONFIG_WIRE_SEL.md`, `CONFIG_WIRE_CAM.md`, `CONFIG_WIRE_WATER.md` | landed leaf-consumer tickets | observed |
| `CONFIG_UI_01.md` | landed menu ticket (snow / fog / season enum) | observed |
| `variant3d/scripts/config.gd` (803 lines) | authority for defaults `:46-84`, `DEFAULT.features` `:89`, getters `:420-483`, `apply()` `:489-694`, loader `:273-302` | observed |
| `variant3d/config.json` (833 lines) | authority for what is actually in the global JSON file | observed |
| `variant3d/scripts/{input_controller,camera3d,water3d,menu,world3d_fx}.gd` | current consumer call sites | observed |
| `docs/coord_swarm_2026-11-25/SWARM_BOARD.md:66,135,182-191,218-222` | ticket state / ownership snapshot | observed (stale where noted) |
| `docs/audit/CONFIG_EFFICIENCY.md`, `docs/audit/CONFIG_VERIFY.md` (both 2026-11-21) | older **2D `app/`** audit; precedent for "declared-but-unused" keys, not part of this 3D chain | observed (out-of-scope evidence) |
| `docs/coord_swarm_2026-11-24/reports/W55_visual_ab.md:27,133-137,149` | no donor same-frame screenshot; visual A/B verdicts UNVERIFIED | observed |

At snapshot time the `CONFIG*` set was the six files above; a later re-read (LINKS-FIX-01,
2026-11-25) also finds `reports/CONFIG_WIRE_HUD.md` and `reports/CONFIG_WIRE_RELIEF.md` on
disk. That is a path fact only — it does not promote either ticket to DONE/PASS. The two
`docs/audit/CONFIG_*` files are older 2D audits and are **not** additional 3D pipeline
reports. Label: observed.

### 1.1 Additional report pointers (added by LINKS-FIX-01, 2026-11-25)

The following six reports exist in `docs/coord_swarm_2026-11-25/reports/` but are hidden
behind the ellipsis ranges in `README.md` §6 (or omitted from its implementation list), so
they are listed here explicitly for a cold reader. This is a **pointer list only**: no gate,
verdict or status is promoted by being cited. [observed — file existence; orphan status from
`reports/QA_LINKS_02.md` Table B]

| Report | Explicit path |
|---|---|
| SP-05 loader override | `reports/SP_05_loader_override.md` |
| TEST-P1 | `reports/TEST_P1_report.md` |
| TEST-P2 | `reports/TEST_P2_report.md` |
| TEST-C2 | `reports/TEST_C2_report.md` |
| TEST-C3 | `reports/TEST_C3_report.md` |
| TRN-DATA implementation | `reports/TRN_DATA_implementation.md` |

Evidence: 2026-11-25 directory listing of `docs/coord_swarm_2026-11-25/reports/`; the six
orphans and their `README.md` §6 ellipsis ranges are recorded in
`docs/coord_swarm_2026-11-25/reports/QA_LINKS_02.md` Table B. [observed]

---

## 2. (a) Actually implemented `features.*` key table

### 2.1 Ground truth

- `FEATURES_DEFAULTS` declares **21 keys** in `config.gd:46-84`, merged as the new
  top-level `"features"` table at `config.gd:89` (`CONFIG_CORE_01.md:23-25`). [observed]
- **21 typed getters** exist at `config.gd:420-483`. All use `value()`/`num()`/`flag()`/
  `text()` (`config.gd:387-406`), so a missing key — or a missing `features` section —
  returns the literal fallback (`CONFIG_CORE_01.md:31-35`). [observed]
- A repo-wide grep of `variant3d/**/*.gd` found getter calls in **only four files**:
  `input_controller.gd`, `camera3d.gd`, `water3d.gd`, and a reflective `has_method`/
  `call` inside `world3d_fx.gd:378-381`. No getter call exists in `hud.gd`, `main.gd`,
  `game.gd`, `data.gd`, `world3d_terrain.gd` or any shader. [observed]
- `apply()` (`config.gd:489-694`) is byte-unchanged by CONFIG-CORE-01 and reads **none**
  of the new keys; the only namespaced concept it touches is the legacy
  `display.fog_of_war` at `config.gd:498` (`CONFIG_CORE_01.md:27,104-106`). [observed]

### 2.2 Key table (21 keys — all defaults in `config.gd:46-84`)

| `features.*` key | Default | Getter (`config.gd`) | Consuming file / line | Status | Label / caveat |
|---|---|---|---|---|---|
| `selection.world_epsilon_m` | `0.005` | `feature_selection_world_epsilon_m()` `:420-421` | `input_controller.gd:218` | **WIRED** | observed; donor `onmousemove.inc:32` (`CONFIG_CORE_01.md:38`) |
| `selection.attack_epsilon_m` | `0.25` | `feature_selection_attack_epsilon_m()` `:423-424` | `input_controller.gd:217` | **WIRED** | observed; donor `onmousemove.inc:33-34` (`:39`) |
| `selection.marquee_color` | `[1,1,0,1]` | `feature_selection_marquee_color()` `:426-428` | `input_controller.gd:98` | **WIRED** | observed; donor `selection.cfg:3-14` (`:40`) |
| `selection.marquee_width_px` | `1` | `feature_selection_marquee_width_px()` `:430-431` | `input_controller.gd:99` | **WIRED** | observed; `LineWidth=1` (`:41`) |
| `selection.double_click_s` | `0.5` | `feature_selection_double_click_s()` `:433-434` | `input_controller.gd:224` | **WIRED** | observed; `menu.cfg:33` (`:42`) |
| `camera.fov_deg` | `17.27` | `feature_camera_fov_deg()` `:466-468` | `camera3d.gd:195` | **WIRED** | PORT APPROX / UNVERIFIED (`RV_CAM_01` via `CONFIG_WIRE_CAM.md:30,40`) |
| `water.surface_y` | `-0.25` | `feature_water_surface_y()` `:454-455` | `water3d.gd:165` (uniform + plane verts) | **WIRED** | PORT APPROX / UNVERIFIED (`CONFIG_CORE_01.md:49`; `CONFIG_WIRE_WATER.md:33,122-126`) |
| `water.alpha_confine` | `true` | `feature_water_alpha_confine()` `:457-458` | `water3d.gd:166` → `stats` only (`:277`) | **READER_ONLY** | inferred; shader gate has no uniform (`CONFIG_WIRE_WATER.md:34,113-117`) |
| `water.shore_prox` | `false` | `feature_water_shore_prox()` `:460-461` | `water3d.gd:167` → `stats` only (`:278`) | **READER_ONLY** | inferred; multiplier was removed, needs shader work (`:118-121`) |
| `weather.snow` | `false` | `feature_weather_snow()` `:463-464` | none directly; reflective call in `world3d_fx.gd:378-381` inside an uncalled helper (`:366-385`) | **UI_ONLY** | observed; menu emits `weather_value` instead (`menu.gd:937-938`); `CONFIG_UI_01.md:66-70` |
| `gameplay.fog_of_war` | `false` | `feature_gameplay_fog_of_war()` `:482-483` | none; menu writes `Data.FOG_OF_WAR` directly (`menu.gd:722`) | **UI_ONLY** | inferred; parallel namespaced key is a dead knob (`CONFIG_CORE_01.md:61-63`; `CONFIG_UI_01.md:143-146`) |
| `terrain.texgen_mode` | `"world_xz"` | `feature_terrain_texgen_mode()` `:436-437` | none | **PENDING** | PORT APPROX; eye planes infeasible (`CONFIG_PLAN_01.md:110`; `CONFIG_CORE_01.md:43`) |
| `terrain.m_per_tile` | `2.0` | `feature_terrain_m_per_tile()` `:439-440` | none | **PENDING** | observed donor `dmscript.global:171` (`CONFIG_CORE_01.md:44`) |
| `terrain.lighting` | `"donor"` | `feature_terrain_lighting()` `:442-443` | none | **PENDING** | observed mode string; sun/colour literals not exposed (`CONFIG_PLAN_01.md:111`) |
| `terrain.alpha_patch_mode` | `"donor_approx"` | `feature_terrain_alpha_patch_mode()` `:445-446` | none | **PENDING** | PORT APPROX; tile→patch index UNVERIFIED (`CONFIG_CORE_01.md:46`) |
| `terrain.relief_stamps` | `false` | `feature_terrain_relief_stamps()` `:448-449` | none | **PENDING** | observed opt-in marker; `CONFIG-WIRE-RELIEF` RUNNING (`SWARM_BOARD.md:218`) |
| `terrain.tile_diversity` | `true` | `feature_terrain_tile_diversity()` `:451-452` | none | **PENDING** | inferred; current port behaviour (`CONFIG_CORE_01.md:48`) |
| `hud.minimap_size` | `240` | `feature_hud_minimap_size()` `:470-471` | none | **PENDING** | observed donor `initminimap.inc:5-7`; `CONFIG-WIRE-HUD` RUNNING (`SWARM_BOARD.md:190`) |
| `hud.minimap_inset` | `-8` | `feature_hud_minimap_inset()` `:473-474` | none | **PENDING** | observed donor `initminimap.inc:5-7` (`CONFIG_CORE_01.md:55`) |
| `hud.minimap_corner` | `"bottom_right"` | `feature_hud_minimap_corner()` `:476-477` | none | **PENDING** | observed donor `initminimap.inc:17` (`:56`) |
| `render.fog` | `false` | `feature_render_fog()` `:479-480` | none | **PENDING** | UNVERIFIED: donor `FogMode=0` ambiguous (`CONFIG_CORE_01.md:57`; `DENV_01 §3.9` via `CONFIG_UI_01.md:38`) |

**Roll-up** [derived from the table]: 21 keys = **7 WIRED + 2 READER_ONLY + 2 UI_ONLY +
10 PENDING**. Only 7 of 21 (33%) change runtime behaviour today; 12 of 21 (57%) have no
consumer call at all (10 PENDING + 2 UI_ONLY). [derived]

**Naming drift** [observed]: `CONFIG_PLAN_01.md:161-261` proposed a richer schema
(`features.input.selection.*`, `features.render.water.*`, `features.gameplay.*`, etc.).
The shipped schema is shorter and renamed (`features.selection.*`, `features.water.*`,
`features.terrain.*`). `CONFIG_WIRE_WATER.md:130-132` explicitly follows the shipped
getters. Readers of the plan must not assume its key paths exist in code. [observed]

---

## 3. (b) The unwired remainder of the 55-feature plan

### 3.1 Headline and honest reconciliation

- **34** = 55 plan features (`CONFIG_PLAN_01.md:138`) − 21 shipped keys
  (`config.gd:46-84`). This is the arithmetic figure carried in the task. Label: **derived**.
- **Row-level truth** [observed + derived]: the shipped schema is **not** a 1:1
  restatement of the plan. Mapping plan rows to shipped getters gives **12 rows fully
  covered**, **4 rows partially covered**, and **39 rows with no shipped getter**
  (12 + 4 + 39 = 55). The 21 getters exceed the 16 addressed rows by 5 because plan
  row 1 holds two keys, row 2 holds two, row 7 holds three, and `shore_prox` has no
  plan row at all (`CONFIG_PLAN_01.md:67,68,73`; `config.gd:46-84`). Hence **"34" is an
  arithmetic headline, not a row count**: the strict row-level unwired set is **39
  no-getter rows + 4 partial rows = 43**. Both numbers are reported so nobody mistakes
  the headline for a verified row tally. Label: derived (headline 34), observed
  (row-level enumeration below).
- All rows below cite the plan row number and the plan's proposed key/owner
  (`CONFIG_PLAN_01.md:59-138`); "no getter" means no `feature_*` accessor exists in
  `config.gd:420-483`. [observed]

### 3.2 No getter at all — grouped by owning file (39 rows)

**`config.gd` (legacy/existing keys, 13 rows)** — these need a namespaced reader or a
decision to keep the legacy key only. [observed]

| Plan # | Feature | Proposed key / existing key (plan) | Citation |
|---:|---|---|---|
| 10 | Hotkeys | `controls.hotkeys.*` (existing) | `CONFIG_PLAN_01.md:76` |
| 12 | Corpse lifetime | `gameplay.corpse_life` (existing) | `:83` |
| 13 | Build queue limit | `gameplay.build_queue_limit` (existing) | `:84` |
| 14 | Max builders per site | `gameplay.max_builders_sent` (existing) | `:85` |
| 15 | Victory / score limit | `gameplay.victory` / `.score_limit` (existing) | `:86` |
| 17 | Map size (tiles) | `gameplay.map_width_tiles` / `.map_height_tiles` (existing) | `:88` |
| 18 | Map shape / terrain type | `gameplay.terrain_type` (alias `map_type`) | `:89` |
| 21 | Minerals / richness | `gameplay.richness` (existing) | `:92` |
| 22 | Nations / players / teams | `gameplay.player_nations` / `nation0/1` / `.players` / `.teams` | `:93` |
| 23 | Global AI difficulty | `ai.difficulty` (existing) | `:94` |
| 25 | AI attack force / peasant cap | `ai.attack_force` / `.max_peasants` (existing) | `:96` |
| 26 | Donor rule dropdowns (12 values) | `gameplay.<donor_id>` (existing ids) | `:97` |
| 53 | Audio master / ambient volume | `audio.enabled` / `.master_volume_db` / `.ambient_volume_db` | `:134` |

**`data.gd` (12 rows)** — mostly gameplay constants still hard-coded. [observed]

| Plan # | Feature | Proposed key | Citation |
|---:|---|---|---|
| 9 | Minimap refresh interval | `features.hud.minimap.interval_s` | `CONFIG_PLAN_01.md:75` |
| 16 | Logic rate / tick clamp | `features.gameplay.fps` / `gameplay.max_tick_seconds` | `:87` |
| 19 | Relief type | `gameplay.relief` / `gameplay.relief_type` (existing) | `:90` |
| 20 | Season | `gameplay.season` (existing) | `:91` |
| 27 | Morale radii / bonuses (6) | `features.gameplay.morale_*` | `:98` |
| 28 | Weapon dispersion (arrow/cannon/tower) | `features.gameplay.*_dispersion_px` | `:99` |
| 29 | Market drift / recovery | `features.economy.market_drift` / `.market_recovery_per_s` | `:100` |
| 30 | Priest heal radius | `features.economy.priest_heal_radius_m` | `:101` |
| 31 | Squad XP / max size | `features.gameplay.squad_xp_*` / `.squad_max` | `:102` |
| 32 | Gatherers per resource node | `features.economy.resource_workers` | `:103` |
| 46 | Quality preset + FX cap (shared with `config.gd`) | `display.quality` + `features.render.quality.*` | `:122` |
| 52 | Season tint table (legacy flat tint) | `features.season.tint_*` | `:128` |

**`world3d_terrain.gd` (+ terrain shader, 3 rows)** [observed]

| Plan # | Feature | Proposed key | Citation |
|---:|---|---|---|
| 36 | Port light energies (exposure/ambient/sun) | `features.render.terrain.*energy` | `CONFIG_PLAN_01.md:112` |
| 37 | Sky band colours | `features.render.sky.horizon_color` / `.top_color` | `:113` |
| 39 | Cliff thresholds / face tilt | `features.render.terrain.face_tilt_deg` / `.cliff_*` / `.rock*` | `:115` |

**Leaf / shader / tooling owners (11 rows)** [observed]

| Plan # | Feature | Owning file | Proposed key | Citation |
|---:|---|---|---|---|
| 4 | Shift = add to selection | `input_controller.gd` | `features.input.selection.shift_add` | `CONFIG_PLAN_01.md:70` |
| 6 | Minimap-jump tilt / nudge | `camera3d.gd` | `features.input.camera.jump_*` | `:72` |
| 8 | Minimap frustum box shape | `hud3d_adapter.gd` (+ `hud.gd`) | `features.hud.minimap.frustum_mode` | `:74` |
| 24 | AI tier effects (hand-off) | `config.gd` + `ai.gd`/`game.gd` | `features.ai.tier_effects` | `:95` |
| 41 | Water classification / fade literals | `water3d.gd` + shader | `features.render.water.level` / `.shore_height` / `.max_height` / fade depths | `:117` |
| 43 | Water glints / foam literals | shader | `features.render.water.spec_*` / colours / HDR | `:119` |
| 47 | Atlas manifest path | `tile_atlas_loader.gd` (consumer already exposed) | `features.render.terrain.atlas_manifest_path` | `:123` |
| 50 | Snow emitter values | `world3d_fx.gd` | `features.environment.weather.snow_*` | `:126` |
| 51 | FX rally TTL | `world3d_fx.gd` | `features.fx.rally_ttl_s` | `:127` |
| 54 | Test spot clearance | `selftest.gd` | `features.tests.spot_clearance_m` (JSON-only) | `:135` |
| 55 | Godot queue spool root | `assert_clean.py` (CLEAN-02) | **do NOT expose** — tool constant | `:136` |

(That sub-table lists 11 rows; 13 + 12 + 3 + 11 = 39. [derived])

### 3.3 Partially covered plan rows (4 rows — getters exist but the plan's values do not)

| Plan # | Feature | Shipped partial key | Missing from config | Owning file | Citation |
|---:|---|---|---|---|---|
| 35 | Sun direction + light colours | `terrain.lighting` (`"donor"` mode string, `config.gd:442`) | `sun_position` / `ambient` / `diffuse` / `specular` literals | `world3d_terrain.gd` + shader | `CONFIG_PLAN_01.md:111`; `config.gd:57` |
| 38 | Alpha patch grid + tile→patch map | `terrain.alpha_patch_mode` (`config.gd:445`) | `alpha_patch_grid` `[8,4,64]` / `alpha_patch_offset` `5` | shader | `CONFIG_PLAN_01.md:114` |
| 44 | Water alpha gate + shore id | `water.alpha_confine` (`config.gd:457`, audit-only) | `shore_tile_id`, live gate uniform | shader + `world3d_terrain.gd` | `CONFIG_PLAN_01.md:120`; `CONFIG_WIRE_WATER.md:113-117` |
| 48 | Tile smoothing / diversity target | `terrain.tile_diversity` (`config.gd:451`) | `smoothing_source` / `diversity_top5_target` (118 lists at `game.gd:1416`) | `game.gd` | `CONFIG_PLAN_01.md:124`; `CONFIG_WIRE_WATER.md:130-132` (schema drift) |

Status of all §3 rows: **PENDING** unless a ticket in §5 has landed. [derived]

---

## 4. (c) Menu-exposed subset — functional vs PORT-UI-ONLY

Landing ticket: `CONFIG_UI_01.md:155-170` (report landed; `SWARM_BOARD.md:184` still says
RUNNING — stale). Current call sites verified directly in `menu.gd`. [observed]

| Menu row | Source / emitted key | Status | Evidence | Label |
|---|---|---|---|---|
| **Season** (pre-existing) | `menu.gd:709`; `cfg.season` + new `cfg.season_enum` at `:936` | **FUNCTIONAL** (existing path; `cfg.season` → `Data.BIOME` per report) | `CONFIG_UI_01.md:36,64`; `CONFIG_PLAN_01.md:301` | observed via report; end-to-end re-render UNVERIFIED |
| **Relief** (pre-existing, unchanged) | `menu.gd:708`; `cfg.relief` / `cfg.relieftype` at `:928,:945` per report | **FUNCTIONAL** (donor-complete, PORT-WIRED) | `CONFIG_UI_01.md:39,71`; `CONFIG_PLAN_01.md:302` | observed via report |
| **Map shape / Map size** (pre-existing) | `menu.gd:726` (Tiny 240 / Normal 320 / Large 400 / Huge 480) | **FUNCTIONAL** | `CONFIG_PLAN_01.md:303`; `menu.gd:723-726` | observed |
| **Difficulty** (pre-existing) | skirmish Rules + Options rows | **FUNCTIONAL with caveat** — pre-existing wiring, not re-verified in this 3D pass | `CONFIG_PLAN_01.md:304`; older 2D audit calls it PARTIAL (`CONFIG_VERIFY.md:215`) | UNVERIFIED for variant3d |
| **Fog of war** (NEW) | `menu.gd:717-722`; callback writes `Data.FOG_OF_WAR` at `:722`; emits `cfg.fog_of_war` at `:939` | **FUNCTIONAL** — live readers exist: `world.gd:345,2189,2259,2267`, `hud.gd:1605,1635,1827`, `world3d_fog.gd:213,234,317`, `main.gd:1530-1531` | `CONFIG_UI_01.md:38,60-63`; direct grep | observed |
| **Snow (weather)** (NEW) | `menu.gd:716`; emits `cfg.weather` `"off"/"snow"` and `cfg.weather_value` `40/70` at `:937-938` | **PORT-UI-ONLY** — no driver call; helper `set_weather_from_config()` exists at `world3d_fx.gd:366-385` but is **not called anywhere**; `WEATHER-DRIVER-01` RUNNING (`SWARM_BOARD.md:219`) | `CONFIG_UI_01.md:37,66-70,135-138`; direct grep | observed |
| `season_enum` (data mirror) | `menu.gd:936` (0/2/3) | **DATA-ONLY** — additive emission for a future consumer | `CONFIG_UI_01.md:36,64`; `CONFIG_UI_01.md:139-142` | inferred |
| `cfg.fog_of_war` bool mirror | `menu.gd:939` | **DATA-ONLY** — top-level bool, not the namespaced `features.gameplay.fog_of_war` key | `CONFIG_UI_01.md:143-146`; `config.gd:498` | inferred |

**Key point** [observed]: none of the menu rows calls a `feature_*` getter. The two live
rows (Season, Fog) work through pre-existing `Data.*` paths; the Snow row emits values
and waits for a driver. The menu is therefore **not** evidence that `features.*` is
player-configurable. [derived]

---

## 5. (d) Sequencing and file-ownership boundaries for remaining tickets

### 5.1 Hard ownership boundaries (do not cross)

| File | Owner / constraint | State | Evidence |
|---|---|---|---|
| `variant3d/config.json` | **MAP-SMALL-01** until landed. Nobody else edits it. | RUNNING; file currently has **no `features` section** and map `240×240` | `SWARM_BOARD.md:66`; `CONFIG_PLAN_01.md:332-333,343`; `config.json:41-42`; grep found no `features` key |
| `variant3d/scripts/config.gd` | CONFIG-CORE-01 landed; `apply()` intentionally unchanged. QA-CONFIG-01 audits it. | DONE / QA RUNNING | `CONFIG_CORE_01.md:18-27,101`; `SWARM_BOARD.md:183,222` |
| `variant3d/scripts/camera3d.gd` | MMJUMP-02 DONE, then CONFIG-WIRE-CAM DONE. `jump_to_world()` (CAM-RV-01 20/20) and `jump_to_world_donor_offset()` must stay byte-identical. | DONE; further edits need hand-off | `SWARM_BOARD.md:135,191`; `CONFIG_WIRE_CAM.md:83-88,139-141` |
| `variant3d/scripts/hud.gd` (+ `hud3d_adapter.gd`) | MMJUMP-02 DONE; CONFIG-WIRE-HUD RUNNING (no report landed). `uitest.gd:304-307` asserts old minimap geometry. | RUNNING | `SWARM_BOARD.md:135,190`; `CONFIG_PLAN_01.md:349,367-369` |
| `variant3d/scripts/input_controller.gd` | CONFIG-WIRE-SEL landed (report present; board stale) | DONE | `CONFIG_WIRE_SEL.md:152-166`; `SWARM_BOARD.md:188` |
| `variant3d/scripts/water3d.gd` / `water3d.gdshader` | CONFIG-WIRE-WATER landed **for `water3d.gd` only**; shader byte-identical | DONE (partial feature coverage) | `CONFIG_WIRE_WATER.md:103-109` |
| `variant3d/scripts/world3d_fx.gd` | FX-WEATHER-01 DONE; WEATHER-DRIVER-01 RUNNING (helper landed, caller missing) | RUNNING | `SWARM_BOARD.md:137,219`; `world3d_fx.gd:347-385` |
| `variant3d/scripts/main.gd` | CONFIG-WIRE-RELIEF RUNNING (relief dump gate) | RUNNING | `SWARM_BOARD.md:218` |
| `variant3d/scripts/menu.gd` | CONFIG-UI-01 landed (board stale) | DONE | `CONFIG_UI_01.md:167-170`; `SWARM_BOARD.md:184` |
| `variant3d/scripts/tile_atlas_loader.gd` | SP-5 landed; `manifest_path` consumer already exposed — adding the key needs **no edit** | DONE | `CONFIG_PLAN_01.md:335,123`; `CONFIG_WIRE_SEL.md:126-130` (general rule) |
| `variant3d/tools/assert_clean.py` | CLEAN-02; feature #55 explicitly **not exposed** | DONE / protected | `CONFIG_PLAN_01.md:333,136` |

### 5.2 Recommended landing order

One file per owner, a backup at `inbox/backup/<name>.bak-<TICKET>`, one unique runner id,
one `reports/<TICKET>.md`, per `CONFIG_PLAN_01.md:353-355`. [observed]

| Order | Ticket | Exclusive file(s) | Work / gate | Current state |
|---:|---|---|---|---|
| 0 | **MAP-SMALL-01** | `config.json` (+ `selftest.gd`) | Land the 240² no-menu default and harness fix; prove 29/29. Releases the JSON lock. | RUNNING (`SWARM_BOARD.md:66`; integrated selftest not green per `:142`) |
| 1 | **CONFIG-JSON** (new; not yet a ticket) | `config.json` **only after step 0** | Add the additive `features` object + `_readme` caveats at `config.json:2-15`; `DEFAULT` already has identical values (`config.gd:89`). Gate: `--dump-config` diff, selftest 29/29, uitest 17/17. | Not landed — no `features` key in file [observed] |
| 2a | CONFIG-INPUT | `input_controller.gd` | epsilon / double-click / marquee readers | LANDED (`CONFIG_WIRE_SEL.md`) |
| 2b | CONFIG-RENDER-A | `world3d_terrain.gd` + `terrain_tileindex.gdshader` | sun/colour/face/relief/alpha-patch readers; one owner for both files or an explicit hand-off. Gate: t_terrain3d smoke. | PENDING (`CONFIG_PLAN_01.md:346`) |
| 2c | CONFIG-RENDER-B | `water3d.gd` + `water3d.gdshader` | level/fade/alpha-gate/shore-id readers; **shore id lives in `world3d_terrain.gd`**, so sequence after 2b or hand off. Gate: t_water3d smoke. | `water3d.gd` LANDED; shader PENDING (`CONFIG_WIRE_WATER.md:111-121`; `CONFIG_PLAN_01.md:347,378-380`) |
| 2d | CONFIG-ENV / WEATHER-DRIVER-01 | `world3d_fx.gd` then `main.gd`/`world3d.gd` | consume `feature_weather_snow()` or `cfg.weather_value` via the existing uncalled helper; gate t_fx3d 13/13 | RUNNING: helper present, caller missing (`SWARM_BOARD.md:219`; `world3d_fx.gd:347-385`) |
| 2e | CONFIG-HUD | `hud.gd` + `hud3d_adapter.gd` (+ `camera3d.gd` only with hand-off) | minimap size/inset/corner/frustum readers after MMJUMP-02; keep CAM-RV-01 byte-identity; flip `uitest.gd:304-307` in the same lane. Gate CAM-RV-01 20/20. | RUNNING, no report (`SWARM_BOARD.md:190`) |
| 2f | CONFIG-WIRE-RELIEF | `main.gd` | opt-in `relief_stamps` dump gate only | RUNNING (`SWARM_BOARD.md:218`) |
| 3 | CONFIG-UI | `menu.gd` (separate owner if `main.gd` pass-through is needed) | weather/fog/season-enum rows | LANDED (`CONFIG_UI_01.md`) |
| 4 | QA-CONFIG-01 | docs only | audit 21 getters' names/defaults/ownership | RUNNING (`SWARM_BOARD.md:222`) |
| 5 | COORD | docs only | update GAPS/CORRECTIONS with shipped keys and labels; final gate | PENDING (`CONFIG_PLAN_01.md:351`) |

**Sequencing rule** [derived from `CONFIG_PLAN_01.md:326-355`]: no two agents edit one
file; MAP-SMALL-01's `config.json` lock is the critical path for making the whole system
actually JSON-configurable. Until step 1 lands, the honest description is "reader-side
defaults exist; global JSON override does not." [observed + derived]

---

## 6. (e) Risks

| # | Risk | Evidence | Label |
|---:|---|---|---|
| 1 | **No donor GPU A/B.** Donor values come from readable scripts/INI/CFG, not a matching donor frame buffer; no donor same-frame screenshot exists. Visual-parity claims for any new `features.*` value stay UNVERIFIED. | `W55_visual_ab.md:27,133-137,149`; `CONFIG_PLAN_01.md:361-363`; `RV_CAM_01` verdict via `CONFIG_WIRE_CAM.md:30` | observed / UNVERIFIED |
| 2 | **PORT APPROX values can be laundered into "donor truth" by giving them a config key.** FOV `17.27`, `texgen_mode "world_xz"`, `alpha_patch_mode "donor_approx"`, `surface_y -0.25`, sky-band mapping, relief blend, snow units are all substitutes. | `config.gd:55,58,63,71`; `CONFIG_CORE_01.md:43,46,49,53`; `CONFIG_PLAN_01.md:110,113,116,118,126` | observed |
| 3 | **Non-default modes need shader/engine work that does not exist yet.** `alpha_confine=false` has no uniform; `shore_prox=true` cannot restore a removed multiplier; `texgen_mode` alternatives need eye planes (CONFIRMED_INFEASIBLE); fog bridge and tile→patch map are UNVERIFIED; relief blend is a port approximation. | `CONFIG_WIRE_WATER.md:113-121`; `CONFIG_PLAN_01.md:110,114,116,120-121`; `config.gd:55,58` | observed / inferred |
| 4 | **No hot reload.** Config is loaded once (`load_all()` `:273-302`, `apply()` `:489-694`); consumers read at bind time (`camera3d.gd:195`) or build time (`water3d.gd:165`). A JSON edit requires a restart; a menu pick writes `Data.*` or `user://options.json` but does not re-run `apply()`. | `config.gd:273-302,489`; `CONFIG_WIRE_CAM.md:161-164`; `config.gd:295-301` | observed / inferred |
| 5 | **`config.json` has no `features` section.** All 21 defaults live only in `config.gd:46-84`. Changing the global JSON cannot yet tune any of them, so owner-facing "global config" claims are premature. | direct grep of `config.json` (0 matches for `features`); `config.json:2-15`; `CONFIG_CORE_01.md:101-106` | observed |
| 6 | **`--check-only` proves parsing, not runtime getter execution.** Jobs 419, 426, 429, 433 all report `SCRIPT ERROR == 0` from a parse/validate run only. Only CONFIG-WIRE-SEL added a real windowed drag test (job 438, PASS 23/23), and even that used default values, not a non-default override. | `CONFIG_CORE_01.md:94-97`; `CONFIG_WIRE_CAM.md:123-126`; `CONFIG_WIRE_WATER.md:86-90`; `CONFIG_UI_01.md:107-108`; `CONFIG_WIRE_SEL.md:95,102-111,134-136` | observed |
| 7 | **A menu toggle can still need a driver.** Snow row emits `40/70` but no caller invokes `set_weather()`; a helper was added (`world3d_fx.gd:366-385`) and is itself uncalled. `WEATHER-DRIVER-01` is RUNNING. | `CONFIG_UI_01.md:66-70,135-138`; `world3d_fx.gd:347-385`; direct grep; `SWARM_BOARD.md:219` | observed |
| 8 | **Layer precedence.** `user://options.json` is merged **after** `config.json` (`config.gd:295-301`), so a UI pick silently wins. UI must never write `config.json` directly. | `config.gd:295-301`; `CONFIG_PLAN_01.md:259,364-366` | observed |
| 9 | **Coercion / unvalidated strings.** `_copy()` turns whole floats into ints (`config.gd:354-374`); typed getters coerce back but raw `data.features` readers would see ints. String modes (`"world_xz"`, `"donor"`, `"donor_approx"`, `"bottom_right"`) have no allow-list, unlike `_donor_id()` (`config.gd:706-711`). | `CONFIG_CORE_01.md:117-124`; `config.gd:404-406,436-477,706-711` | observed |
| 10 | **Test-literal coupling.** Minimap geometry default changes can break `uitest.gd:304-307`; `_spot()` clearance was widened for 240². Flip assertions in the owning lane; never weaken a correct test. | `CONFIG_PLAN_01.md:367-369`; `CONFIG_UI_01.md:124`; `SWARM_BOARD.md:142` | observed / inferred |
| 11 | **Dead-knob precedent.** The older 2D audit confirmed five declared-but-unused keys (`camera.pitch_degrees`, `economy.max_builders`, `ai.*_threshold`). A shipped getter without a consumer is the same pattern; §2's 12 unconsumed keys should not be reported as "done". | `CONFIG_VERIFY.md:60,65-132,277-282`; `CONFIG_EFFICIENCY.md:132-137` | observed (2D precedent, mapped by inference) |

---

## 7. Honesty constraints (read before quoting this document)

1. **Defaults exist; the global JSON override does not.** `FEATURES_DEFAULTS` at
   `config.gd:46-84` and `DEFAULT.features` at `:89` are real. `config.json` contains **no**
   `features` key at this snapshot (direct read + grep). Any claim that "all main
   features are configurable in the global JSON file" is **not yet true**. [observed]
2. **Parse smoke ≠ runtime proof.** All cited smoke jobs used `--check-only`; they
   confirm the scripts compile with the getter calls, not that a getter returned a
   non-default value at runtime. The one real-input job (438) exercised defaults only.
   [observed; `CONFIG_CORE_01.md:94-97`, `CONFIG_WIRE_SEL.md:134-136`]
3. **A menu toggle may still need a driver.** The Snow row is PORT-UI-ONLY; the helper
   exists but has no caller; `WEATHER-DRIVER-01` is RUNNING. [observed]
4. **Board vs reports.** `SWARM_BOARD.md:184,188` mark CONFIG-UI-01 and CONFIG-WIRE-SEL
   RUNNING although their reports have landed; the reports and source files win.
   Conversely CONFIG-WIRE-HUD and WEATHER-DRIVER-01 have **no landed
   report** at this snapshot and are not claimed as done here. `reports/CONFIG_WIRE_RELIEF.md`
   was absent then but is on disk at the LINKS-FIX-01 re-read (2026-11-25); no done/PASS
   claim is made for it here. [observed]
5. **"34" is derived, not a row count.** See §3.1 for the reconciliation. [derived]
6. **No donor file was read for this task; no visual-parity claim is made.** Donor
   citations are inherited from the cited reports, not re-verified here. [UNVERIFIED for
   independent confirmation]

---

## 8. Summary

- **Implemented:** 21 `features.*` keys with 21 typed getters in `config.gd:46-84,420-483`.
  Status: **7 WIRED** (5 selection + camera FOV + water surface Y), **2 READER_ONLY**
  (water `alpha_confine`, `shore_prox` — audit-only), **2 UI_ONLY** (`weather.snow`,
  `gameplay.fog_of_war`), **10 PENDING** (6 terrain, 3 HUD, 1 render fog). [observed/derived]
- **Not yet in JSON:** `config.json` has no `features` section; all behaviour-preserving
  values live only in `config.gd.DEFAULT`. The JSON step is blocked behind MAP-SMALL-01's
  file ownership. [observed]
- **Unwired plan remainder:** headline **34** (55 − 21) [derived]; strict row-level
  **39 no-getter rows + 4 partial rows**, grouped by owning file in §3. [observed/derived]
- **Menu:** 6 exposed options; Season, Relief, Map shape/size and Fog are functional,
  Difficulty is functional but not re-verified here, **Snow is PORT-UI-ONLY**; two extra
  emitted mirrors are data-only. No menu row calls a `feature_*` getter. [observed/inferred]
- **Critical path:** MAP-SMALL-01 releases `config.json` → CONFIG-JSON writes the additive
  object → per-file wiring owners (shader work for non-default modes) → weather driver →
  QA/COORD docs. One file per owner; no concurrent edits. [derived from
  `CONFIG_PLAN_01.md:326-355`]
- **Top risks:** no donor GPU A/B, PORT APPROX laundering, non-default modes needing
  shader work, no hot reload, parse-only smokes, and uncalled menu drivers (§6). [observed]
- **This task:** produced this file only; no code, config, test, backup or runner job was
  created or edited. [observed]
