---
id: AUDIT3D-04
owner: AUDIT3D-04
scope: Gameplay/simulation parity — variant3d/scripts/ vs app/scripts/ (+ selftest/config manifests)
date: 2026-11-24
status: AUDIT COMPLETE — runtime consequences marked UNVERIFIED
---

# AUDIT3D-04 — 3D/2D simulation parity

## Scope and method

- Enumerated every `.gd` under `variant3d/scripts/` (29) and `app/scripts/` (21): 21 common names, 8 variant3d-only new modules, 0 app-only.
- MD5-compared all 21 common files, then generated unified diffs (`difflib`, context 0–2) for the 7 that differ.
- Structurally compared `app/config.json` vs `variant3d/config.json`, `app/selftest.json` vs `variant3d/selftest.json`, and `tests/manifest.json`.
- Scanned the 8 new 3D modules for simulation mutations (`cmd_*`, resource/hp writes, RNG, `serialize`).
- Read-only. No source edits, no git commands, one report file written.

**Verdict:** Core simulation is byte-identical. 14/21 common scripts match exactly, including `game.gd`, `ai.gd`, `world.gd`, `mapgen.gd`, `nav.gd`, `selftest.gd`. All 29 selftest step details match. The remaining 7 files are mostly documented renderer seams, but there are **three real drift clusters**: an incomplete 3D world-contract surface, a 3D picking adapter that drops `players_only=false` semantics, and a self-snapshot format regression that reintroduces the `block_rect` corruption app had fixed.

## Evidence table

| ID | OBSERVATION with `path:line` | Classification | Rating |
|---|---|---|---|
| E01 | Byte-identical (MD5): `app/scripts/game.gd:1` = `variant3d/scripts/game.gd:1`; same for `ai.gd`, `world.gd`, `config.gd`, `audio.gd`, `camera.gd`, `mapgen.gd`, `menu.gd`, `nav.gd`, `pattern_gen.gd`, `selftest.gd`, `terrain3d_sandbox.gd`, `testbridge.gd`, `uitest.gd` (14 files). Economy/capture/combat/hotkey/AI logic is literally unchanged. | INTENTIONAL (no change) | — |
| E02 | `variant3d/scripts/data.gd:58-61` adds only `static var RENDER_MODE := "2d"`. Diff has no other hunk; no numeric/default change. | INTENTIONAL-3D (additive port extension) | — |
| E03 | Structured config diff: only `variant3d/config.json:38` `"render_mode": "3d"` added (plus readme line `:13`). Every numeric key (`build_progress_per_hit 0.359375`, `mine_income_per_second 1.664`, morale/famine/market/hotkeys, all unit/building stats) is identical. | INTENTIONAL-3D | — |
| E04 | `variant3d/scripts/main.gd:53-58` relaxes typed `world/camera/input_ctl` to Variant; `:119-126`, `:174-176` add `render_mode` and read `gameplay.render_mode`; `:572-606`, `:1005-1044` add 3D construction branches; `:623-624`, `:1061-1062` call `_apply_3d_hooks`; `:937-970` add factories. 2D legs keep app's verbatim calls. | INTENTIONAL-3D (renderer adapter) | — |
| E05 | `variant3d/scripts/input_controller.gd:21-27,111-123,378-380,393-396,722-725` adds `bind_3d`, `_pick_screen`, and 3D branches for `_screen_to_world/_pick/_pick_res`; all `cmd_*`, hotkeys, groups, build ghost untouched. | INTENTIONAL-3D (renderer adapter) | — |
| E06 | `variant3d/scripts/hud.gd:48-56,187-209,1430-1442` adds `bind_3d` and switches only the minimap viewport box source. Minimap image/data/orders unchanged. | INTENTIONAL-3D (renderer adapter) | — |
| E07 | `variant3d/scripts/world3d.gd:1-331` is a new composition root (5 owned modules) replacing app's legacy M0 terrain-only world (`app/scripts/world3d.gd:1-498`); backup documented at its header. Terrain constants TILE_M 2.0 / HEIGHT_SCALE 1.0 / WATER_LEVEL -0.25 survive in `variant3d/scripts/world3d_terrain.gd:50-52`. | INTENTIONAL-3D (composition) | — |
| E08 | 3D world lacks members the shared callers use: `app/scripts/world.gd:24,32,137,155,163,164,501,1039,1044,1882,2186` defines `fog_sprite`, `terrain_chunks`, `fog_revision`, `mark_rally_dirty`, `anim_index`, `anim_tex`, `_anim_dir`, `_bake_px`, `_build_masks`, `invalidate_forest_bake`, `_update_fog`. `variant3d/scripts/world3d.gd:78-99,279-331` defines none of them (grep: 0 matches). `variant3d/scripts/world3d_fog.gd` has no `fog_revision`. Callers: `main.gd:1331` (F9 load), `:1418-1431` (quality options), `:1442` (fog toggle); `input_controller.gd:609,634` (rally), `:361,365` (patrol route); `hud.gd:1741,1748` (minimap fog cache). These lines are byte-identical to 2D — not gated by `render_mode`. | **DRIFT (incomplete adapter)** | **P0** |
| E09 | `app/scripts/input_controller.gd:345-369` `_pick(pw, players_only)` applies `pick_radius` to all entities when `players_only=false`; call sites `:492` (left click), `:585` (right-click order), `:1089` (cursor) pass `false`; only `:434` passes `true`. `variant3d/scripts/input_controller.gd:393-396` calls `picking.pick(_pick_screen)` with no flag; `variant3d/scripts/picking3d.gd:208-236` hardcodes `if e.player == 0` for the radius branch, so enemies are only selectable through the 2 m fallback at `:218` (`FALLBACK_REACH_M * _ppm(30.0)` — fixed 30 m depth, not per-entity). `picking3d.gd:5-14` comment claims the distinction is absorbed, but it is not. | **DRIFT (gameplay: enemy select/attack order/cursor)** | **P1** |
| E10 | `app/scripts/main.gd:716-730,751-926` uses format `w52-self-base-2`, `var_to_str`, native `PackedByteArray`/`Rect2`, `_pick_target()` resolution, `_json_rect()` normaliser (`:778-797`, used `:900-904`), and float32-quantised compare (`:768-775,816-820`). `variant3d/scripts/main.gd:752-769,790-835,837-935` uses `w52-self-base-1`, `JSON.stringify`, base64 blobs, no `_pick_target` (`:838`), no `_json_rect`, and plain `float(a) == float(b)` (`:807-808,828-829`). Top-level `terrain/blocked/height` copies dropped (they were redundant; real source is `base`, handled at `:881-886`) — that part is harmless. | **DRIFT (test/fast-path infrastructure)** | **P1** |
| E11 | Consequence of E10: `app/scripts/game.gd:5499-5512` `_vec_enc` does not encode `Rect2`; app snapshot `app/tests/results/w52_self_base.json` stores `"block_rect": Rect2(591.98944, 30.532219, 13.1562, 12.470982)`. Variant3d JSON snapshot stores the lossy string `"block_rect":"[P: (591.9894, 30.53222), S: (13.1562, 12.47098)]"` (`variant3d/tests/results/w52_self_base.json`), and `game.gd:129` expects `var r: Rect2 = b.get("block_rect", Rect2())`. INFERENCE (runtime UNVERIFIED — no parity log found): `_same_json` string compare at `variant3d/main.gd:809` will flag MISMATCH, so `--self-only` fast load falls back to full mapgen. | DRIFT (functional, fallback likely masks it) | P1 |
| E12 | `app/scripts/input_controller.gd:666-690` `_pick_res` uses world distance, strict `<`, exact-distance tie → lowest id. `variant3d/scripts/picking3d.gd:242-279` uses screen distance, 0.5 px tie epsilon and camera-depth ordering; reach converted at `_depth_of(sim,0)` while projected at `BODY_LIFT_M*0.5`. Filter rules (skip stump/bush, skip depleted except food, 2.5+radius) preserved. | INTENTIONAL-3D approximation (documented) but not exact parity | P2 |
| E13 | `app/selftest.json:1-…` vs `variant3d/selftest.json`: identical `passed:true`, `resources_gathered` (food 45 / wood 712 / stone 120 / gold 245.023999999998 / trade 65), `shots_fired 73`, all 29 step names/details/exact numbers; only `wall_ms` values and `sim_seconds` (366.71875 → 366.90625, +0.1875 s = `game.time_s` per `selftest.gd:114`) differ. Cause of the extra end-of-run sim time UNVERIFIED. | PARITY OK (timing noise only) | P2 note |
| E14 | `app/tests/manifest.json:1-196` vs `variant3d/tests/manifest.json:1-252`: 56 pre-existing entries byte-identical; 7 appended 3D tests (`t_terrain3d`, `t_camera3d`, `t_pick3d`, `t_entities3d`, `t_fx3d`, `t_fog3d`, `t_render_mode`). All 67 common test scripts MD5-identical. | INTENTIONAL-3D (additive) | — |
| E15 | Renderer-art numeric drift (out of sim scope, cross-ref AUDIT3D-02/03): `app/scripts/heightmap_world3d.gd:38-56,131-140` EXPOSURE 2.4 / AMBIENT_ENERGY 2.5 / SUN_ENERGY 2.2 / ALBEDO_GAIN 1.15 / `EMISSION_RGB(0.12,0.12,0.10)` / donor `DONOR_AMBIENT`+`DONOR_DIFFUSE`; `variant3d/scripts/heightmap_world3d.gd:35-50,140-143` EXPOSURE 1.45 / AMBIENT 1.10 / SUN 1.7 / ALBEDO 1.05 / `Color(0.10,0.10,0.085)` / invented `Color(0.86,0.88,0.82)` and no donor diffuse. `SUN_LIGHTVEC` axis mapping also differs (`:35`). | DRIFT (renderer, donor data dropped) | P2 |
| E16 | `app/scripts/heightmap3d_sandbox.gd:1-238` full `extends SceneTree` CLI capture harness; `variant3d/scripts/heightmap3d_sandbox.gd:1-6` is a 6-line `extends Node3D` probe ("G32_PROBE"). App's header explicitly says `--script` requires `SceneTree`. | DRIFT (test harness lost; cross-ref AUDIT3D-09) | P2 |
| E17 | No new module issues: grep across all 8 variant3d-only modules found only reads of `Data`/game fields (`picking3d.gd:6`, `hud3d_adapter.gd:39-61`, `camera3d.gd:109-124,149,229,324-325`, `world3d_fog.gd:79-317`, `world3d_fx.gd:588,627-628`); zero `cmd_*` calls, resource/hp writes or RNG calls. | INTENTIONAL-3D (read-only adapters) | — |

## Ranked gaps and smallest fixes

### P0-1 — 3D world does not expose the 2D world contract (E08)
Shared, unbranched code in `main.gd`/`hud.gd`/`input_controller.gd` calls 2D-only members on the composed 3D world. On 3D mode (now the default) F9 load, Options→quality, Options→fog toggle, right-click rally and patrol-route drawing will hit missing members. Runtime errors are an **INFERENCE** (no 3D smoke log found — UNVERIFIED).
**Smallest fix:** add thin aliases/no-ops to `variant3d/scripts/world3d.gd` using `app/scripts/world.gd` as the verbatim source: `func _update_fog() -> void: pass` (fog module already syncs at `world3d.gd:288`), `func mark_rally_dirty() -> void: pass`, `var fog_revision := 0` (bump in `sync` when `fog.sync` changes), `var fog_sprite` → a visibility proxy, and guard the Options quality lambda (`main.gd:1418-1436`) with `if render_mode == "2d"` since those are sprite-chunk-only. No new numeric values.

### P1-1 — 3D picking drops `players_only=false` (E09)
Enemy units/buildings become ~2 m-screen-pickable instead of `pick_radius`-pickable, breaking attack orders, capture-attack cursor and enemy info selection at `input_controller.gd:492,585,1089`.
**Smallest fix:** change `variant3d/scripts/input_controller.gd:396` to `picking.pick(_pick_screen, players_only)` and in `picking3d.gd:208` accept the flag, applying the radius test to all entities when false (mirror `app/scripts/input_controller.gd:357-365`); replace the fixed `_ppm(30.0)` fallback at `:218` with per-entity `_ppm(depth)`. Donor rule itself is engine-side and UNVERIFIED (`C:\Games\Cossacks 3\data\scripts\lib\misc.script:7-27` per `picking3d.gd:21-26`), so use app as authority.

### P1-2 — self-snapshot reverted to lossy format (E10/E11)
`w52-self-base-1` + JSON turns `Rect2 block_rect` into a truncated string; app deliberately fixed this in `w52-self-base-2`. Fast subset load likely falls back to full mapgen.
**Smallest fix:** copy `app/scripts/main.gd:716-730` and `:751-926` verbatim into `variant3d/scripts/main.gd` (format marker, `var_to_str`, `_pick_target`, `_json_rect`, float32-quantised compare), keeping only V7-50 3D additions outside these functions. Re-dump `tests/results/w52_self_base.json` and require `SELF-SNAPSHOT dump round-trip: OK`.

### P2 — renderer/test drift (E15/E16)
Restore `app/scripts/heightmap_world3d.gd` donor light constants (donor data, no invention) and the `SceneTree` harness of `app/scripts/heightmap3d_sandbox.gd`. Coordinate with AUDIT3D-02/03/09.

### P2 — `pick_res` tie rule (E12) and final `sim_seconds` (E13)
Document the 0.5 px/depth tie as a declared 3D approximation, or reproduce app's exact-distance + lowest-id rule. Re-run selftest to confirm the +0.1875 s is only a terminal-tick artefact.

## Open questions

1. Was `variant3d/selftest.json` produced with `render_mode="3d"` or with a 2D override? No log records it (UNVERIFIED). This determines whether E08 already blocked the selftest HUD step.
2. Any captured runtime log of F9 load / Options / rally / patrol in 3D mode? None found; E08 remains static-analysis-only (UNVERIFIED).
3. Does `--check-self-base` actually print MISMATCH on the variant3d JSON snapshot? No log found (UNVERIFIED); check before ranking E11 as P0.
4. Donor pick radius, overlap depth and absolute FOV are engine-side / UNVERIFIED; app is the only available authority for E09/E12.
5. Is the loss of app's M0 terrain implementation in `variant3d/scripts/world3d.gd` fully covered by `world3d_terrain.gd` for every caller, or does any 2D-only test still load `res://scripts/world3d.gd` expecting M0 methods?
