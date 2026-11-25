---
id: QA-CONFIG-01
title: "QA-CONFIG-01 — read-only audit of the 21 feature getters (naming, defaults, ownership)"
date: 2026-11-25
owner: QA-CONFIG-01 (read-only audit worker)
status: COMPLETE__21_KEYS_AUDITED__NO_CODE_EDITS__NO_RUNNER_JOBS
scope: "Read-only. Sources: config.gd FEATURES_DEFAULTS + getter block, all CONFIG_WIRE_*.md reports present at audit time, CONFIG_UI_01.md, CONFIG_PLAN_01.md, CONFIG_CORE_01.md, SWARM_BOARD.md and all variant3d/**/*.gd call sites. Only output: docs/coord_swarm_2026-11-25/reports/QA_CONFIG_01_getters.md. No code/config/test/backup edit, no donor access, no Godot/runner job."
labels: [observed, derived, inferred, UNVERIFIED]
verification: "Each of the 21 keys was checked twice: (1) definition read directly in FEATURES_DEFAULTS (config.gd:46-84) AND in its getter body (config.gd:420-483); (2) call site read directly, OR absence proved by an exhaustive ripgrep of variant3d/**/*.gd for both direct `feature_*()` calls and string-form `\"feature_*\"` has_method/call names (41 total matches = 21 definitions + 19 call lines + 1 comment)."
---

# QA-CONFIG-01 — 21-getter audit

## 1. Sources

**Code read directly (path:line):**

| File | Lines used |
|---|---|
| `variant3d/scripts/config.gd` | `:42-84` (`FEATURES_DEFAULTS`, 21 keys), `:354-374` (`_copy` coercion), `:387-412` (`value/num/flag/text/section`), `:414-484` (21 getters), `:489-498` (`apply()`, `display.fog_of_war`), `:269,273` (`active`, default seeding) |
| `variant3d/scripts/input_controller.gd` | `:92-100` (marquee fallback + 2 getter calls), `:208-224` (epsilon + double-click getters), `:777` (`_double_click_s()` call) |
| `variant3d/scripts/water3d.gd` | `:3`, `:32-36`, `:154-167` (3 getter calls; `alpha_confine`/`shore_prox` audit-only) |
| `variant3d/scripts/camera3d.gd` | `:184-201` (`fov = cfg.feature_camera_fov_deg()` at `:195`; fallback `17.27`) |
| `variant3d/scripts/hud.gd` | `:6` (preload), `:270-292` (3 dynamic getter wrappers), `:321-335`, `:1412-1448` (size/inset/corner uses) |
| `variant3d/scripts/main.gd` | `:129,168-181` (`cfg` instance), `:253-371` (`_apply_menu_cfg`), `:720-771` (CONFIG-WIRE-RELIEF dynamic getter at `:758-759`) |
| `variant3d/scripts/menu.gd` | `:704-726` (Snow/Fog rows, `Data.FOG_OF_WAR` write), `:924-945` (4 emitted keys) |
| `variant3d/scripts/world3d_fx.gd` | `:161-165`, `:283`, `:325-385` (`set_weather_from_config`, getter at `:378-379`), `:767-784` |
| `variant3d/scripts/data.gd`, `world3d_terrain.gd`, `config.json` | `data.gd:23` (`TILE_M=2.0`), `world3d_terrain.gd:130`, `config.json:22` (`display.fog_of_war`; **no `features` key**) |

**Reports read:** `CONFIG_CORE_01.md`, `CONFIG_PLAN_01.md`, `CONFIG_UI_01.md`, `CONFIG_WIRE_SEL.md`, `CONFIG_WIRE_WATER.md`, `CONFIG_WIRE_CAM.md`, `QA_AUDIT_01_implementation_claims.md` (format reference), `SWARM_BOARD.md:180-193,218-219`.

**In-flight reports that do NOT exist at audit time:** `CONFIG_WIRE_HUD.md`, `CONFIG_WIRE_RELIEF.md`, `WEATHER_DRIVER_01.md` (all three tickets are `RUNNING` on `SWARM_BOARD.md:190,218-219` while their source files already contain getter calls). Their runtime/smoke claims are therefore **UNVERIFIED**; only the source call sites are **observed**.

**Grep evidence (absence proof):** `rg "feature_[a-z_]+\s*\("` and `rg '"feature_'` over `variant3d/**/*.gd`. No getter call exists outside `input_controller.gd`, `water3d.gd`, `camera3d.gd`, `hud.gd`, `main.gd`, `world3d_fx.gd`. No `features.` path string is read by any consumer; `features.*` only appears in `config.gd` plus comments in `water3d.gd`/`hud.gd`/`camera3d.gd`.

**Label legend:** `observed` = literal read with path:line; `derived` = arithmetic/enumeration/absence from observed grep; `inferred` = plausible, not proven; `UNVERIFIED` = no accessible evidence (missing report or runtime probe).

## 2. The 21-row table

Status key: **WIRED** = live getter call site in a consumer; **READER_ONLY** = getter defined, no call site; **UI_EMITTED** = menu emits an analogous value but no getter consumes it; **PENDING** = call site exists only in an uncalled helper / blocked by an in-flight ticket.

| # | Key | Default | Getter (`config.gd`) | Consumer file:line (or NONE) | Status | Issue / recommended owner | Label |
|---:|---|---|---|---|---|---|---|
| 1 | `features.selection.world_epsilon_m` | `0.005` | `feature_selection_world_epsilon_m` (`:420`) | `input_controller.gd:218` (fallback same line) | WIRED | No numeric drift. `CONFIG_PLAN_01` key is `features.input.selection.epsilon_m` — group/leaf naming conflict; COORD doc mapping owner. | observed |
| 2 | `features.selection.attack_epsilon_m` | `0.25` | `feature_selection_attack_epsilon_m` (`:423`) | `input_controller.gd:217` | WIRED | Fallback `0.25` matches. Plan key `features.input.selection.epsilon_attack_m`. | observed |
| 3 | `features.selection.marquee_color` | `[1,1,0,1]` | `feature_selection_marquee_color` (`:426`) | `input_controller.gd:98` (fallback `:94`) | WIRED | Unvalidated Array; a short/malformed array errors at painter `:100` (future JSON-validation owner). Plan group `features.input.selection.*`. | observed |
| 4 | `features.selection.marquee_width_px` | `1` (int) | `feature_selection_marquee_width_px` (`:430`) | `input_controller.gd:99` | WIRED | Consumer fallback is `1.0` float, plan default also `1.0`; getter returns int. `float(...)` at call site removes drift; type convention owner = config.gd + COORD. | observed |
| 5 | `features.selection.double_click_s` | `0.5` | `feature_selection_double_click_s` (`:433`) | `input_controller.gd:224` (call `:777`) | WIRED | Fallback `0.5` matches. Plan group conflict only. | observed |
| 6 | `features.terrain.texgen_mode` | `"world_xz"` | `feature_terrain_texgen_mode` (`:436`) | NONE | READER_ONLY | Plan `features.render.terrain.texgen_mode`; PORT APPROX; shader still hard-codes world XZ; string is unvalidated. Owner: future CONFIG-RENDER-A. | observed + derived (absence) |
| 7 | `features.terrain.m_per_tile` | `2.0` → stored as int `2` | `feature_terrain_m_per_tile` (`:439`) | NONE | READER_ONLY | `_copy()` (`:354-374`) coerces whole floats to int; getter `num()` returns `2.0`. Plan `features.render.terrain.meters_per_tile`; ≥20 hard-coded `TILE_M = 2.0` sites remain. Owner: config.gd follow-up + JSON owner. | observed + derived |
| 8 | `features.terrain.lighting` | `"donor"` | `feature_terrain_lighting` (`:442`) | NONE | READER_ONLY | Plan has no `lighting` key (it proposes `sun_position`/`ambient`/`diffuse`/`specular`/energies); unvalidated mode string. Owner: CONFIG-RENDER-A. | observed + derived |
| 9 | `features.terrain.alpha_patch_mode` | `"donor_approx"` | `feature_terrain_alpha_patch_mode` (`:445`) | NONE | READER_ONLY | Plan proposes `alpha_patch_grid`/`alpha_patch_offset`, no `mode`; PORT APPROX (tile→patch index UNVERIFIED). Owner: CONFIG-RENDER-A. | observed + derived |
| 10 | `features.terrain.relief_stamps` | `false` | `feature_terrain_relief_stamps` (`:448`) | `main.gd:758-759` (dynamic `has_method`/`call`) | WIRED | In-flight CONFIG-WIRE-RELIEF: **report absent**, smoke UNVERIFIED. Plan key `relief_stamps_enabled`. Consumer uses script member `cfg` (`main.gd:129`), not static `active`. Default false keeps dump key absent. Owner: CONFIG-WIRE-RELIEF. | observed + UNVERIFIED (report) |
| 11 | `features.terrain.tile_diversity` | `true` | `feature_terrain_tile_diversity` (`:451`) | NONE | READER_ONLY | Plan `smoothing_source`/`diversity_top5_target` instead; no consumer. Owner: CONFIG-RENDER-A / game.gd hand-off. | observed + derived |
| 12 | `features.water.surface_y` | `-0.25` | `feature_water_surface_y` (`:454`) | `water3d.gd:165` | WIRED | Plan `features.render.water.surface_y` — shipped `features.water.*` discrepancy (also `CONFIG_WIRE_WATER.md:130-132`); PORT APPROX label intact; value flows to uniform + plane vertices. | observed |
| 13 | `features.water.alpha_confine` | `true` | `feature_water_alpha_confine` (`:457`) | `water3d.gd:166` | WIRED | **Audit-only**: result goes to `stats["water_alpha_confine_config"]`; shader gate has no uniform, so a non-default value has no effect. Plan key `features.render.water.alpha_gate`. Owner: water3d.gd + shader ticket. | observed |
| 14 | `features.water.shore_prox` | `false` | `feature_water_shore_prox` (`:460`) | `water3d.gd:167` | WIRED | **Audit-only**: removed port-art multiplier cannot be restored without shader work; no plan key. Owner: water3d.gd + shader ticket. | observed |
| 15 | `features.weather.snow` | `false` | `feature_weather_snow` (`:463`) | `world3d_fx.gd:378-379`, inside uncalled `set_weather_from_config()` (`:366`) | PENDING | Menu emits `weather`/`weather_value` (`menu.gd:937-938`) but no caller reaches the helper; WEATHER-DRIVER-01 RUNNING, **report absent**. Plan numeric `features.environment.weather.value` (bool vs int). Owner: WEATHER-DRIVER-01 (main.gd/world3d.gd). | observed + UNVERIFIED |
| 16 | `features.camera.fov_deg` | `17.27` | `feature_camera_fov_deg` (`:466`) | `camera3d.gd:195` | WIRED | Plan `features.input.camera.fov_deg`; PORT APPROX / UNVERIFIED label preserved; fallback `17.27` matches. | observed |
| 17 | `features.hud.minimap_size` | `240` | `feature_hud_minimap_size` (`:470`) | `hud.gd:278-279` (used `:321`, `:1415`) | WIRED | In-flight CONFIG-WIRE-HUD: **report absent**. Plan `features.hud.minimap.size_px`; fallback `240` matches. Owner: CONFIG-WIRE-HUD. | observed + UNVERIFIED (report) |
| 18 | `features.hud.minimap_inset` | `-8` | `feature_hud_minimap_inset` (`:473`) | `hud.gd:284-285` (used `:335`, `:1444`) | WIRED | Plan `features.hud.minimap.inset_px` default `+8` — **sign drift**; consumer negates to a positive edge distance; fallback `-8` matches getter. Owner: COORD doc mapping / CONFIG-HUD. | observed + UNVERIFIED (report) |
| 19 | `features.hud.minimap_corner` | `"bottom_right"` | `feature_hud_minimap_corner` (`:476`) | `hud.gd:290-291` (used `:1434`) | WIRED | Plan `features.hud.minimap.anchor` default `"right"` — value drift; only bottom-right offsets implemented; unknown strings silently fall back. Owner: COORD / CONFIG-HUD. | observed + UNVERIFIED (report) |
| 20 | `features.render.fog` | `false` | `feature_render_fog` (`:479`) | NONE | READER_ONLY | Plan nested `features.render.fog.{enabled,color,density,start_m,end_m,interval_s}` vs shipped flat bool; DENV-01 `FogMode=0` ambiguous; no consumer. Owner: CONFIG-ENV / shader ticket. | observed + derived |
| 21 | `features.gameplay.fog_of_war` | `false` | `feature_gameplay_fog_of_war` (`:482`) | NONE (menu emits `cfg.fog_of_war` + writes `Data.FOG_OF_WAR` at `menu.gd:717-722,939`) | UI_EMITTED | **Three namespaces**: applied `display.fog_of_war` (`config.gd:498`), namespaced getter (unconsumed), menu bool. Plan row 11 uses `display.fog_of_war` only. Owner: CONFIG-UI + config.gd/main.gd decision. | observed + derived |

## 3. Targeted checks (a–d)

**(a) Every getter call resolves to a real method — PASS.** All 19 call lines use one of the 21 exact names defined at `config.gd:420-483`. Direct calls (`cfg.feature_*()`) in input_controller/water3d/camera3d and dynamic `has_method("feature_*")`/`call("feature_*")` in hud/main/world3d_fx match the definitions character-for-character. No misspelled or missing getter found. Caveat: three call sites belong to in-flight tickets with no report, so parse/smoke evidence is **UNVERIFIED** (finding F-05).

**(b) No consumer hard-codes a different default — PASS (with two minor conventions).** Literal fallbacks: `0.005`/`0.25`/`0.5`/`[1,1,0,1]`/`1.0` (input_controller), `-0.25`/`true`/`false` (water3d), `17.27` (camera3d), `240`/`-8`/`"bottom_right"` (hud), `false` (main.gd relief), `40` for snow-off (world3d_fx). All equal the getter defaults semantically. Minor: `marquee_width_px` consumer fallback is a float `1.0` vs an int getter; `CONFIG_PLAN` also lists `1.0`. No numeric drift.

**(c) Menu-emitted keys reaching a getter — FAIL (contract gap).** `season_enum`, `weather`, `weather_value`, `fog_of_war` are emitted at `menu.gd:936-939`. `main.gd:_apply_menu_cfg()` (`:270-371`) consumes none of them; repo-wide grep finds no other `.gd` reader. `weather_value`/`weather` can reach `world3d_fx.set_weather_from_config()` **only if called explicitly**, and that helper has no caller; the getter path inside it (`:378-379`) is therefore dormant. `fog_of_war` bypasses config entirely via `Data.FOG_OF_WAR` (`menu.gd:722`). `season_enum` has no feature getter at all. All four are **PENDING/UI_EMITTED**, not wired.

**(d) `m_per_tile: 2.0` coercion — CONFIRMED as flagged.** `FEATURES_DEFAULTS` stores `2.0` (`config.gd:56`), but `_copy()` (`:354-374`) converts whole-number floats to int while seeding `data` from `DEFAULT` (`:273-274`), so raw `data.features.terrain.m_per_tile` is int `2`. The typed getter `num(..., 2.0)` (`:439-440`) returns float `2.0`. No consumer uses the raw path today, so behaviour is unchanged; the risk is for a future raw reader or a JSON override. Also `CONFIG_CORE_01.md:117-121`, `CONFIG_WIRE_SEL.md:137-139`.

**(e) `features.render.water.*` vs `features.water.*` — CONFIRMED drift.** `CONFIG_PLAN_01.md:118-120,234-242` proposes `features.render.water.*` (including `surface_y`, `alpha_gate`); `CONFIG-CORE-01` shipped `features.water.*` (`config.gd:62-66,454-461`). `CONFIG_WIRE_WATER.md:130-132` explicitly notes the discrepancy and followed the shipped getters. Recommendation: freeze `features.water.*` as canonical and publish a mapping; do not rename without a migration.

## 4. Cross-cutting issues, ranked

| # | Severity | Finding | Evidence | Recommended owner / file |
|---:|---|---|---|---|
| F-01 | HIGH | **No `features` object in `config.json`.** All 21 keys currently resolve to built-in defaults; the global-JSON goal is only half delivered. `CONFIG_PLAN_01.md:275-277` expected CONFIG-CORE to add it, but CONFIG-CORE's scope excluded `config.json` (`CONFIG_CORE_01.md:101-106`). | `config.json` grep for `features` → 0 matches; `config.gd:273-274`; `CONFIG_WIRE_CAM.md:33` | COORD + successor to MAP-SMALL-01; new `CONFIG-JSON-01` owning `variant3d/config.json` |
| F-02 | HIGH | **Schema/naming conflict: 21/21 shipped paths differ from `CONFIG_PLAN_01` §2** (group moves, leaf renames, nested-vs-flat shapes, sign/value drift). Examples: `features.input.selection.*` vs `features.selection.*`; `features.render.terrain.*` vs `features.terrain.*`; `render.fog` bool vs object; minimap `inset_px=8`/`anchor="right"` vs shipped `-8`/`"bottom_right"`. | table rows 1-21; `CONFIG_PLAN_01.md:159-262`; `CONFIG_WIRE_WATER.md:130-132` | COORD (docs-only mapping ticket); any actual rename needs `config.gd` + all consumers in one coordinated lane |
| F-03 | HIGH | **`fog_of_war` has three namespaces.** Applied `display.fog_of_war`; getter `features.gameplay.fog_of_war` unconsumed; menu emits top-level `cfg.fog_of_war` and writes `Data.FOG_OF_WAR` directly. Config and menu can disagree with no single source of truth. | `config.gd:82,96,482-483,498`; `menu.gd:717-722,939`; `CONFIG_UI_01.md:143-146`; `CONFIG_PLAN_01.md:82` | Decision owner: COORD; implementation across `config.gd` + `menu.gd` + `main.gd` (CONFIG-FOG-01) |
| F-04 | HIGH | **UI-emitted values cannot reach a getter.** `season_enum`, `weather`, `weather_value`, `fog_of_war` have no consumer; the weather helper is uncalled. Snow row remains PORT-UI-ONLY. | `menu.gd:936-939`; `main.gd:270-371`; `world3d_fx.gd:366-385`; `CONFIG_UI_01.md:66-70,133-138`; `SWARM_BOARD.md:219` | WEATHER-DRIVER-01 (`world3d_fx.gd` + `main.gd`/`world3d.gd`); separate decision for `season_enum` |
| F-05 | MEDIUM | **Three in-flight code changes have no report.** HUD (3 getters), relief (1 getter), weather (1 getter) are present in source, but `CONFIG_WIRE_HUD.md`, `CONFIG_WIRE_RELIEF.md`, `WEATHER_DRIVER_01.md` do not exist; their smoke/ownership claims are UNVERIFIED. Board also stale: CONFIG-UI-01 and CONFIG-WIRE-SEL are `RUNNING` although their reports say DONE. | `SWARM_BOARD.md:184,188,190,218-219`; backups `hud.gd.bak-CONFIGWIREH`, `main.gd.bak-CONFIGWIRER`; reports dir listing | CONFIG-WIRE-HUD / CONFIG-WIRE-RELIEF / WEATHER-DRIVER-01 owners; COORD for board state |
| F-06 | MEDIUM | **`m_per_tile` type coercion** (see check d): raw data int vs typed getter float, with many hard-coded `TILE_M=2.0` consumers. | `config.gd:56,354-374,439-440`; `data.gd:23`; `world3d_terrain.gd:130` | config.gd owner (CONFIG-CORE follow-up) + JSON schema owner |
| F-07 | MEDIUM | **Water booleans are audit-only.** `alpha_confine=false` and `shore_prox=true` cannot change the shader; both getters are WIRED but inert outside `stats`. | `water3d.gd:161-167,272-278`; `CONFIG_WIRE_WATER.md:111-121` | water3d.gd + `variant3d/shaders/water3d.gdshader` (one owner) |
| F-08 | LOW | **Unvalidated string modes / array shape.** `texgen_mode`, `lighting`, `alpha_patch_mode`, `minimap_corner` pass through as-is; a short marquee array can error at draw time. No allow-list analogous to `_donor_id()` (`config.gd:706-711`). | `config.gd:426-428,436-446,476-477`; `hud.gd:1434-1436`; `CONFIG_CORE_01.md:122-124`; `CONFIG_WIRE_SEL.md:140-144` | Future consumer tickets (CONFIG-RENDER-A / CONFIG-HUD) + JSON validation owner |

**Checks that passed (no finding):** all 21 definitions have exactly one matching getter; all 19 call lines resolve to real methods (no wrong name); all consumer fallback literals match getter defaults; no duplicate getter name; no getter added or removed since CONFIG-CORE-01; no `features` key read outside `config.gd`.

## 5. Recommended ticket list (documents/owners, not patches)

| Ticket | Scope | Owner / exclusive file(s) | Gate / evidence |
|---|---|---|---|
| CONFIG-JSON-01 | Add `features` object with the **21 shipped names/defaults** to `config.json` + `_readme` caveats (FOV, texgen, alpha patch, fog mode, weather, relief blend) | successor to MAP-SMALL-01; `variant3d/config.json` | `--dump-config` diff + selftest/uitest unchanged |
| CONFIG-NAMES-01 (docs) | Freeze canonical key list; publish `CONFIG_PLAN → shipped` mapping; update `CONFIG_PLAN_01.md` appendix and stale "remaining 20 unwired" notes in wire reports | COORD; docs only | no code |
| CONFIG-WIRE-HUD (finish) | Land report + smoke artifact for the three minimap getters | CONFIG-WIRE-HUD; `hud.gd` + report | parse smoke + anchor test |
| CONFIG-WIRE-RELIEF (finish) | Land report + smoke for `feature_terrain_relief_stamps` gate in `_dump_map()` | CONFIG-WIRE-RELIEF; `main.gd` + report | dump with/without flag |
| WEATHER-DRIVER-01 (finish) | Call `set_weather_from_config(cfg.weather_value)` from the menu-config hand-off; choose string enum vs numeric contract; land report | WEATHER-DRIVER-01; `main.gd`/`world3d.gd`, `world3d_fx.gd` | `stats["weather_driver_*"]` assertion |
| CONFIG-FOG-01 | Pick one fog-of-war namespace and make menu, `apply()` and the getter agree | COORD decision; `config.gd` + `menu.gd` + `main.gd` (one builder) | config/UI round-trip test |
| CONFIG-COERCE-01 | Decide whether `m_per_tile` stays float in `data` (or document int as canonical); keep `num()` getter authoritative | config.gd owner; `variant3d/scripts/config.gd` | dump-config type check |
| CONFIG-VALIDATE-01 | Allow-lists for string modes + marquee array length | future consumer owners; `world3d_terrain.gd`, `hud.gd`, `config.gd` validation helper | invalid-value fallback test |
| CONFIG-WATER-EFFECT-01 | Add shader uniforms if `alpha_confine`/`shore_prox` must have runtime effect | water3d.gd + shader owner (one builder) | water smoke + A/B |
| CONFIG-SEASON-01 | Decide whether `season_enum` needs a getter/consumer or should be dropped from `_emit_start()` | CONFIG-UI successor; `menu.gd` + `main.gd` | menu cfg contract test |
| COORD board sync | Mark CONFIG-UI-01 / CONFIG-WIRE-SEL DONE; add HUD/RELIEF/WEATHER-DRIVER outcomes | COORD; `SWARM_BOARD.md` only | board matches reports |

## 6. Open questions

1. Who inherits `variant3d/config.json` ownership after MAP-SMALL-01, and when does CONFIG-JSON-01 land?
2. Are `CONFIG-WIRE-HUD`, `CONFIG-WIRE-RELIEF` and `WEATHER-DRIVER-01` still mid-flight? Their reports were absent at audit time, so their claims are UNVERIFIED.
3. Are the shipped 21 names canonical, or should `CONFIG_PLAN_01` names be adopted with a migration? Recommendation: shipped names; plan is a proposal.
4. Which `fog_of_war` namespace wins: `display.fog_of_war`, `features.gameplay.fog_of_war`, or the menu's top-level bool?
5. Is `cfg.weather` (string) or `cfg.weather_value` (40/70) the UI contract (`CONFIG_UI_01.md:139-142`)? The helper currently accepts both.
6. Does `season_enum` need a consumer at all, or is it additive debug data forever?
7. Should `m_per_tile` remain float in `data` despite `_copy()`'s whole-float→int rule?
8. Should `alpha_confine`/`shore_prox` ever become live shader switches, or stay audit-only?
9. Should unknown string modes be rejected with a `problems` entry like `_donor_id()`, or silently fall back as today?

## 7. Summary

- **21/21** keys have a matching typed getter in `config.gd:420-483`; **21/21** definitions verified in `FEATURES_DEFAULTS` (`config.gd:46-84`). No wrong-name call, no duplicate getter, no missing method.
- Call-site coverage: **13 WIRED** (selection 5, water 3, camera 1, HUD 3, relief 1 — the last four belong to in-flight tickets with no report), **1 PENDING** (`weather.snow`, call exists only in an uncalled helper), **1 UI_EMITTED** (`gameplay.fog_of_war`), **6 READER_ONLY** (terrain texgen/m_per_tile/lighting/alpha_patch/tile_diversity and `render.fog`).
- **No consumer hard-codes a different default**; fallbacks match getters (one int-vs-float convention on `marquee_width_px`).
- Main inconsistencies: no `features` object in `config.json`; full naming/schema drift from `CONFIG_PLAN_01`; `fog_of_war` triple namespace; UI-emitted keys with no getter path; `m_per_tile` int coercion; audit-only water booleans; three missing in-flight reports.
- All findings carry a recommended owner/file above. **No code, config, test, backup or other report was edited; no Godot/runner job was launched by this audit.**
