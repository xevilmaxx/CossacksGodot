---
id: V7-76
owner: V7-76
role: "close P0 G10: forward the 2D build-ghost and selected-building rally state into world3d_fx.gd's dead draw_ghost / draw_rally APIs"
date: 2026-11-24
owned_files:
  - variant3d/scripts/world3d.gd
  - docs/coord_swarm_2026-11-24/reports/V776_ghost_rally.md
status: "DELIVERED — parse clean (ticket 145); probe passed:true with FX ghost visible false->true and rally markers 0->1 (tickets 152/155); full variant selftest passed:true 29/29 (ticket 157); NO visual parity claim"
verification_jobs: [145, 152, 155, 157]
honest_limits:
  - "No GPU/visual parity claim: harness 3D capture is a CPU map (AUDIT3D-09 §4). Only node-tree state was measured."
  - "2D app untouched; world3d_fx.gd, input_controller.gd, entities, main, app, tests, config untouched. No git operations."
  - "Ticket 152's stderr captured a TRANSIENT concurrent parse break in world3d_entities.gd:580 ('_obj_topology' called as a function), a file this agent does not own; it was fixed by its owner before ticket 155. FX assertions passed in both runs."
  - "The 2D 120 ms can_place verdict cache (world.gd:3472-3492) is a perf optimisation, not a state condition; it is deliberately NOT copied."
---

# V7-76 — ghost / rally runtime forwarding (`world3d.gd`)

## 1. What landed

`variant3d/scripts/world3d.gd` ONLY: 527 -> 682 lines, tabs, no RNG, no sprite
sheets, no `class_name`. One new report (this file). Every V7-62 composition,
entity-feed and contract slot was preserved; this atom is purely additive.
`world3d_fx.gd` was NOT edited — its existing procedural `draw_ghost` /
`draw_rally` meshes are now actually reached at runtime (AUDIT3D-06 G10, P0-2).

Closing gap: `AUDIT3D_06_fx_anim_audio.md:45-46` proved the two APIs existed but
had **no caller outside `tests/t_fx3d.gd:218-219`**; `:103` ranks it P0-2. Now
`sync()` translates the exact 2D trigger state and calls both APIs.

## 2. 2D evidence translated (path:line -> 3D code)

| 2D source (authoritative) | Condition translated | 3D code |
|---|---|---|
| `app/scripts/world.gd:3464` | `sid = hud.build_ghost_sid` (empty => no ghost) | `world3d.gd:395-403`; `main.gd:614` assigns `world.hud`, so the reference is live in 3D |
| `app/scripts/world.gd:3467-3469` | mouse screen -> canvas inverse -> `/view_scale` -> map-origin metres `wp` | `world3d.gd:350-366` uses the current `Camera3D.screen_to_world(mouse)` (`camera3d.gd:167-176`), the direct 3D analogue of that transform |
| `app/scripts/world.gd:3470` | `game.in_bounds(wp)` gate | `world3d.gd:408-412` |
| `app/scripts/world.gd:3486` | `game.resolve_mine_sid(sid, wp)` | `world3d.gd:413-415` |
| `app/scripts/world.gd:3493-3494` | unknown sid => no ghost | `world3d.gd:416-419` |
| `app/scripts/world.gd:3502-3503` | `can_place(0,sid,wp).ok AND Data.can_pay(players[0].res, def.cost)` -> green/red (`world.gd:3509`) | `world3d.gd:420-427` + `_can_pay_building()` `:369-385` using `data.gd:1549-1553` |
| `app/scripts/world.gd:3509` | colour green=ok / red=blocked | unchanged in `world3d_fx.gd:84-85` (`GHOST_OK/GHOST_BAD`); only the `ok` flag is forwarded |
| `app/scripts/world.gd:3602-3613` | one rally marker per SELECTED player-0 building that `has("rally")`; point `e.rally`, colour from `e.player` | `world3d.gd:430-452` -> `fx.draw_rally(rp, 0)`; 3D pennant colour still read from donor key JSON by the FX module (`world3d_fx.gd:609`) |
| `input_controller.gd:619/644` (2D equivalent `app/scripts/input_controller.gd`) | `mark_rally_dirty()` on right-click | `world3d.gd:618-624` now re-reads rally state before `fx.sync(0.0)` |
| `app/scripts/main.gd:1481` / `variant3d/scripts/main.gd` | `world.sync(dt)` is the per-frame hook | both forwarders called from `world3d.gd:539-540` inside `sync()` |

The 2D `_fx_static_ok` dirty gate (`world.gd:3586,3605`) is a redraw optimisation;
the 3D FX module already refreshes rally every `sync()` (`world3d_fx.gd:269`) and
expires unseen markers after `RALLY_TTL` (`:102`, `:695-707`), so a fresh draw
per frame is the faithful behaviour, not an invented state.

## 3. Exact diff (`world3d.gd` final `file:line`)

| # | Location | Change |
|---|---|---|
| D1 | `:49-52` (new) | Composition-map entry: ghost/rally translation in `sync()`; states no 2D file is edited and FX meshes already exist. |
| D2 | `:74-81` (new) | Citation block: 2D ghost trigger `world.gd:3460-3509`, rally `world.gd:3602-3613`, gap `AUDIT3D_06...:45-46,103`, camera ground ray `camera3d.gd:167-176`. |
| D3 | `:143-149` (new) | State `_ghost_pos: Vector2 = Vector2.INF` and `_ghost_pos_override: bool = false` for the optional handoff/camera-cache. |
| D4 | `:345-366` (new) | `_ghost_world_pos()`: explicit handoff first, then `get_viewport().get_camera_3d()` + `screen_to_world(get_mouse_position())`; returns `Vector2.INF` when neither is usable. Guarded with `is_inside_tree()` and `has_method`, matching `_update_view_rect()`'s camera pattern. |
| D5 | `:369-385` (new) | `_can_pay_building(def)`: null-safe mirror of `world.gd:3503` affordability via `Data.can_pay` (`data.gd:1549-1553`); missing treasury does not block the preview. |
| D6 | `:388-427` (new) | `_sync_build_ghost()`: reads `hud.build_ghost_sid`, applies in_bounds / resolve_mine_sid / BUILDINGS / can_place / can_pay, then `fx.draw_ghost(sid, wp, ok)`. All early exits actively clear the ghost because the FX ghost has no TTL. |
| D7 | `:430-452` (new) | `_sync_rally()`: walks `game.entities`, skips dead / non-building / player!=0 / unselected / no-rally, calls `fx.draw_rally(rp, 0)` for each survivor. Uses the existing `_prop` / `_int_prop` readers from V7-62. |
| D8 | `:539-540` (new) | `sync()` calls `_sync_build_ghost()` and `_sync_rally()` after `_sync_selection()`, before `entities.sync(dt)` / `fx.sync(dt)`, so same-frame pulse + TTL aging still applies. |
| D9 | `:618-624` (edit) | `mark_rally_dirty()` calls `_sync_rally()` before the existing `fx.sync(0.0)` so a right-click shows the new marker immediately; original `_rally_dirty = true` and `fx.sync(0.0)` preserved. |
| D10 | `:627-642` (new) | Public `set_build_ghost_pos(p)` handoff + exact documented caller snippet; no call site added in `input_controller.gd`. |

No other member was removed or changed; V7-62's `stats`, `view_rect`, entity
feed, fog revision and contract no-ops are byte-preserved.

## 4. Measured before / after node counts

Probe: temporary `variant3d/tests/_v776_probe.gd` (SceneTree, self-exiting,
result JSON), bound a RefCounted stub game (`MAP_W/H=8`, 4 entities: one selected
player-0 building with `rally`, one unselected, one player-1 selected, one
selected unit), a stub HUD with `build_ghost_sid = "hou"`, fed the ghost ground
point through `set_build_ghost_pos(Vector2(12,14))`, called `sync(0.016)`, then
recursively counted nodes under the FX module. Probe and result JSON deleted
after the run (`Test-Path = False` for both).

| Metric (FX module tree) | Before `sync()` | After `sync()` |
|---|---|---|
| `BuildGhost3D.visible` | `false` | `true` |
| nodes named `RallyP*` | 0 | 1 |
| `MeshInstance3D` under FX | 1 (footprint only) | 5 (footprint + pole/finial/foot/flag) |
| `fx.stats.ghost_shown` | 0 | 1 |
| `fx.stats.rally_active` | 0 | 1 |
| `fx._ghost_sid` / `fx._ghost_ok` | — / — | `"hou"` / `true` |
| `fx.world_offset` (stub 8x8 tiles) | — | `(8.0, 8.0)` |

The three non-qualifying stub entities created **no** extra markers (only one
`RallyP0` node), confirming the `dead`/`kind`/`player`/`selected`/`rally` gates
were translated, not widened.

## 5. Verification jobs (variant3d runner only)

All launches through `python variant3d/tools/godot_runner.py run --id ...`
(`variant3d/tools/godot_runner.py:349-437`), never a direct `godot` call.

| Ticket | Job id | Command (abridged) | Wait / run | Result |
|---|---|---|---|---|
| 145 | `v776-parse` | `--headless --path variant3d --check-only --script res://scripts/world3d.gd` | 47.35 s / 2.70 s | `END ok`; stdout only the Godot banner, stderr empty -> **parse clean**. |
| 152 | `v776-probe` | `--headless --path variant3d --script res://tests/_v776_probe.gd` | 0.27 s / 3.39 s | `END ok`; probe `passed:true`, counts as §4. stderr also contained a transient concurrent `world3d_entities.gd:580` parse break (not this agent's file, since fixed); FX assertions still passed. |
| 155 | `v776-probe2` | same probe, after the concurrent fix | 0.00 s / 3.60 s | `END ok`; `passed:true`, identical counts; stderr only the intentional `world3d_entities` bind-pose warning. |
| 157 | `v776-selftest` | `--headless --path variant3d -- --self-test variant3d/selftest.json` | 0.00 s / 47.09 s | `END ok`; `variant3d/selftest.json` **`passed: true`, 29 steps, 0 failed**. stderr only bind-pose warning + pre-existing exit leaks (`AUDIT3D-09 §5`). |

## 6. Handoffs

1. **Ghost point (optional).** A live 3D run needs no handoff: `sync()` reads the
   current `Camera3D` and its `screen_to_world(mouse)` exactly as 2D reads the
   canvas inverse. `set_build_ghost_pos(p)` (`world3d.gd:640`) is exposed for
   headless callers and for an input owner that prefers the height-field-accurate
   `picking3d.ground_point()`. Exact caller handoff, documented in code at
   `world3d.gd:627-639`, NOT implemented here (input_controller.gd is V7-75-owned):
   in `C3Input._process()`, immediately after
   `_screen_to_world(get_viewport().get_mouse_position())`
   (`input_controller.gd:1095`, also `:372`), add
   `if world != null and world.has_method("set_build_ghost_pos"): world.set_build_ghost_pos(pw)`.
   `pw` is already sim-metre map-origin coordinates.
2. **FX origin (G9)** is owned by V7-73 in `world3d_fx.gd` (`bind()` derives
   `world_offset` from `game.MAP_W/MAP_H`); this atom relies on it and measured
   `(8.0, 8.0)` for the 8x8 stub. No edit there.
3. **Rally colour** remains the FX module's donor-key-colour JSON path
   (`world3d_fx.gd:87,609`); this atom forwards only `e.player` as 2D does.

## 7. Open questions

1. **No visual parity / GPU claim.** The harness cannot obtain 3D pixels
   (AUDIT3D-09 §4); only node-tree state and counters were measured. Whether the
   ghost footprint and pennant are legible under the real camera is UNVERIFIED.
2. **Camera ground point vs height field.** `_ghost_world_pos()` uses the
   `Camera3D.screen_to_world()` flat Y=0 ray (`camera3d.gd:164-176`), while
   `picking3d.ground_point()` ray-marches the height field. On steep terrain the
   ghost point may differ from the click point; the optional handoff (§6.1)
   resolves this when the input owner adopts it. Not measured here.
3. **2D verdict cache not copied.** `world.gd:3472-3492` throttles `can_place`
   to >2 px mouse movement / sid change / 120 ms. `sync()` currently evaluates
   `can_place` every frame. That is a sim collision scan; a perf decision for a
   later atom, deliberately out of scope here.
4. **Rally TTL vs dirty gate.** 2D gates rally lines behind `_fx_static_ok`
   (`world.gd:3586,3605`); 3D redraws every sync and expires unseen markers after
   2 s (`world3d_fx.gd:102`). Equivalent visibility, different mechanism — not
   latency-measured.
5. **Concurrent-owner parse break** captured in ticket 152's stderr
   (`world3d_entities.gd:580`) was transient and outside this atom's ownership;
   tickets 155/157 are clean of it. No action taken by this agent.
6. **`mark_rally_dirty()` now calls `_sync_rally()`** before ageing; the runtime
   F9/Options/rally menu smoke path was not individually exercised (same open
   question as V7-62 §7 Q1) — only selftest + probe were run.

*End of V7-76 report.*
