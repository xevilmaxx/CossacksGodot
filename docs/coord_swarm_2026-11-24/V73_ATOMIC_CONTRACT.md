# Wave 7 phase 2 — ATOMIC API CONTRACT (2026-11-24)

All `variant3d/` files use TABS. Every 3D constant cites donor `path:line` or is
marked UNVERIFIED. Scope: SINGLEPLAYER SKIRMISH ONLY (D-12). No donor binaries.

## Module ownership (ONE file per agent — never edit another module's file)

| File (all under `variant3d/scripts/`) | API the module MUST expose |
|---|---|
| `camera3d.gd` (extends Camera3D) | `bind(game, view_scale:=1.0)`, `view_scale`, `world_to_px(world:Vector2)->Vector2`, `screen_to_world(screen:Vector2)->Vector2`, `clamp_pos()`, `get_view_rect()->Rect2`, `get_viewport_corners()->Array` (4 ground corners for minimap box), `zoom_step(notches, anchor)`, `set_zoom_target(target, immediate:=false)` |
| `picking3d.gd` (extends Node) | `bind(game, cam)`, `pick(screen:Vector2)->Dictionary` (unit/building entity), `pick_res(screen:Vector2)->Dictionary` (resource node), `ground_point(screen:Vector2)->Vector2`. No cmd_* calls — return ids/entities only. |
| `world3d_terrain.gd` (extends Node3D) | `bind(game)`, `build()->bool` (ONE full-grid ArrayMesh from base64 dump height, central-difference normals, UV 0..1), `invalidate()`, `has_chunk_or_fallback()->bool` (trivially true), `height_at_world(p:Vector2)->float`. Reuse `app/scripts/heightmap_world3d.gd` as REFERENCE only (read it; do not edit app/). |
| `world3d_entities.gd` (extends Node3D) | `bind(game)`, `sync(dt)`, `add_unit(e)`, `add_building(e)`, `add_resource(n)`, `remove(id)`. Static meshes via MeshInstance3D/MultiMeshInstance3D from `variant3d/assets/models/obj/**` (already copied) or `.glb` if V7-8 lands. No 2D sprite sheets. |
| `world3d_fx.gd` (extends Node3D) | `bind(game)`, `sync(dt)`, `add_fx(pos, kind, life)`, `draw_ghost(sid, pos, ok:bool)`, `draw_rally(pos, player:int)`. Event stream from main is sim-agnostic. |
| `world3d_fog.gd` (extends Node3D) | `bind(game)`, `sync(dt)`, per-tile fog shading from `game.fog_explored`/`fog_vis`; expose `fog_explored`, `fog_vis` arrays so HUD minimap can read them. |
| `hud3d_adapter.gd` (extends Node) | `bind(cam, hud)`, `get_minimap_box()->Rect2` (project 4 ground corners into minimap pixel space), `screen_to_world(screen)`. CanvasItem HUD stays; only the box adapter is 3D. |
| `anim3d.gd` (extends Node) | `bind(game, entities)`, `play(e, action, t)`, donor `.oss` frames + `.aaf` ranges; must label pose-mesh fallback `PORT APPROXIMATION — NOT DONOR PARITY` if bone hierarchy unreadable (V7-2 BLOCKED). |

## Integration seams (SEPARATE agents, after modules land)

- `main.gd` owner: add `gameplay.render_mode` default `2d`; branch world/camera/input construction; relaxed `Node` typing instead of static `C3World/C3Camera`; keep 2D path byte-identical; expose `make_world3d()`, `make_camera3d()`.
- `input_controller.gd` owner: replace ONLY `_screen_to_world`/`_pick`/`_pick_res` internals with calls to `picking3d.gd`; all `game.cmd_*` calls untouched.
- `hud.gd` owner: minimap box uses `hud3d_adapter.get_minimap_box()` when render_mode==3d; data/minimap image unchanged.
- `world3d.gd` owner (integration): composes the five world3d_* modules and implements the FULL 2D world contract: `bind(game)`, `sync(dt)`, `view_scale`, `view_rect`, `fx_layer`, `world_to_px()`, `fog_explored`, `fog_vis`, `add_fx()`, `has_chunk_or_fallback()`, `selected` state.

## Test atoms (separate agents, new files under `variant3d/tests/`)
`t_terrain3d.gd`, `t_camera3d.gd`, `t_pick3d.gd`, `t_entities3d.gd`, `t_fx3d.gd`,
`t_fog3d.gd`, `t_render_mode.gd`. Each test loads its module dynamically via
`load("res://scripts/<module>.gd")` (no class_name needed) and asserts the API
above. `variant3d/tests/manifest.json` owner registers them LAST.

## Docs atoms
One report per agent under `docs/coord_swarm_2026-11-24/reports/V74*.md`;
a final `docs/variant3d/STATUS.md` written by the docs agent after all reports.

## Runner
ALL jobs via `python variant3d\tools\godot_runner.py run --id v<ID>-... --timeout <s> -- --headless --path variant3d --script res://tests/<name>.gd`.
Its spool is `variant3d/.godot_queue` (verified). The 2D runner is separate.
