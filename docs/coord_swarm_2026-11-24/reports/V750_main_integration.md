---
owner: V7-50
date: 2026-11-24
role: integration builder (main.gd / config.json / data.gd only)
lane: Wave 7 phase 2 — render-mode integration seam
output: docs/coord_swarm_2026-11-24/reports/V750_main_integration.md
owns:
  - variant3d/scripts/main.gd
  - variant3d/config.json
  - variant3d/scripts/data.gd
read_only:
  - variant3d/scripts/{camera3d,picking3d,world3d,world3d_terrain,world3d_entities,world3d_fx,world3d_fog,hud3d_adapter,anim3d,input_controller,hud}.gd
  - variant3d/tests/t_render_mode.gd
  - docs/coord_swarm_2026-11-24/V73_ATOMIC_CONTRACT.md
governing_rule: port extension, NOT donor logic — no existing simulation number changed; 2D remains default and byte-identical at every legacy call site
verification: variant runner only (no direct godot)
---

# V7-50 — main.gd render-mode integration seam (LANDED)

## 1. Result

`variant3d/tests/t_render_mode.gd` now **PASSES 10/10** where it previously
reported `SEAM_MISSING`. Full 2D selftest remains **29/29 `passed:true`**.
Both gates were run through the owned variant runner; no direct Godot launch.

| Job id | Ticket | Command purpose | Result |
|---|---|---|---|
| `v750-baseline-render-mode` | 53 | pre-edit baseline of `t_render_mode.gd` | **FAILED** — 3/10 checks; `SEAM_MISSING`: main.gd has no 3D render-mode seam (run 4.59 s) |
| `v750-render-mode` | 67 | post-edit `t_render_mode.gd` | **ok** — `T_RENDER_MODE PASS 10 checks; 3D seam present` (run 3.22 s) |
| `v750-selftest` | 68 | full `--self-test variant3d/selftest.json` | **ok** — `passed:true`, 29/29 steps, 0 failed (run 61.26 s) |

Post-edit gate stdout (ticket 67):

```
CHECK main_source_readable           PASS  res://scripts/main.gd (75849 chars)
CHECK main_script_loads              PASS  light load of res://scripts/main.gd (no _ready)
CHECK render_mode_exposed            PASS  main.gd declares/assigns render_mode
CHECK render_mode_default_2d         PASS  gameplay.render_mode fallback is "2d"
CHECK make_world3d_exposed           PASS  func make_world3d(...) present
CHECK make_camera3d_exposed          PASS  func make_camera3d(...) present
CHECK three_d_branch_present         PASS  world/camera construction gated on render_mode
CHECK three_d_helpers_wired          PASS  both make_* helpers declared AND called
CHECK two_d_path_preserved           PASS  legacy 2D world/camera constructors still present
CHECK runtime_default_2d             PASS  bare instance render_mode="2d" (expected "2d")
T_RENDER_MODE PASS 10 checks; 3D seam present
```

Baseline stdout (ticket 53) for comparison:
`T_RENDER_MODE FAIL 10 checks; SEAM_MISSING: main.gd has no 3D render-mode seam
(integration not landed)` — only `main_source_readable`, `main_script_loads`
and `two_d_path_preserved` passed.

## 2. Backups (taken BEFORE any edit)

```
inbox/backup/main.gd.bak-V750      71512 bytes  (2026-11-24 11:32:55)
inbox/backup/config.json.bak-V750  13989 bytes  (2026-11-21 06:47:26)
inbox/backup/data.gd.bak-V750      83452 bytes  (2026-11-24 10:08:14)
```

Diff stats vs those backups: `main.gd` +129/−32, `data.gd` +4/−0,
`config.json` +3/−1.

## 3. Why this key is a PORT ADDITION, not donor logic

- `V71_mechanics_inventory.md:171` — "No donor 'render mode' flag exists —
  this is a port-side switch, not a donor mechanic; mark as port addition, not
  invented donor logic."
- `V71_mechanics_inventory.md:176` — `donor render-mode flag (port addition,
  not donor mechanic)` listed under explicit UNVERIFIED items.
- `V73_ATOMIC_CONTRACT.md:21` — main.gd owner must "add
  `gameplay.render_mode` default `2d`; branch world/camera/input construction;
  relaxed `Node` typing instead of static `C3World/C3Camera`; keep 2D path
  byte-identical; expose `make_world3d()`, `make_camera3d()`".
- `V741_atomic_supervision.md:37-40,166,183-186` — the `SEAM_MISSING` blocker
  this report closes.

No donor path:line is quoted for the flag because none exists. No existing
simulation number, table, config value or 2D constructor was changed; the new
key is purely additive.

## 4. Exact diff (file:line against the shipped files)

### `variant3d/scripts/data.gd` (new line 60, after `CAPTURE_ENABLED`)

```gdscript
# V7-50 PORT ADDITION — there is no donor render-mode key (V71 mechanics
# inventory :171,:176: "No donor 'render mode' flag exists — port-side switch").
# Additive only: no existing simulation number or default is changed.
static var RENDER_MODE := "2d"      # gameplay.render_mode; 2d default, 3d opt-in
```

### `variant3d/config.json`

- line 13 (`_readme`): added
  `"gameplay.render_mode: port-side renderer switch (2d default, 3d opt-in); no donor key exists."`
- line 38 (`gameplay`): added `"render_mode": "2d",` after `"mode": "skirmish",`

### `variant3d/scripts/main.gd`

| New line | Change |
|---|---|
| 54-60 | `var world: C3World` → `var world`, `var camera: C3Camera` → `var camera`, `var input_ctl: C3Input` → `var input_ctl`, with rationale comment |
| 120-124 | Added `var render_mode := "2d"` (+ comment). The `3d` literal is deliberately NOT on that line: `t_render_mode.gd:39-42` rejects a declared 3D default. |
| 176-177 | In `_ready()`: `render_mode = str(cfg.text("gameplay.render_mode", "2d")).to_lower()` and `Data.RENDER_MODE = render_mode` |
| 573-600 | Staged-load site (`_do_async_load`): world + camera construction branch on `render_mode`; 2D leg keeps `C3WorldScript.new()`, `world.bind(game)`, `C3CameraScript.new()`, `camera.bind(world)` and the original `set_zoom_target(start_zoom, Vector2.INF, true)` / position lines verbatim |
| 624-625 | Staged-load site: `if render_mode == "3d": _apply_3d_hooks(hud, camera, input_ctl)` after `input_ctl.bind(...)` |
| 938-975 | New `make_world3d() -> Node` and `make_camera3d() -> Node`, both using `load("res://scripts/...gd").new()` (no `class_name`, per contract) + null guards |
| 967-974 | New `_apply_3d_hooks(p_hud, p_cam, p_input)` calling `hud.bind_3d(cam)` (V7-53) and `input_ctl.bind_3d(cam)` (V7-52) |
| 1003-1041 | Full-game site (`_setup_full_game`): same branch; 2D leg byte-identical to the original construction/focus block |
| 1062-1063 | Full-game site: `_apply_3d_hooks(...)` after `input_ctl.bind(...)` |
| 1427-1429 | Parse fix relayed by V7-52: `var idx_path := world._anim_dir() + ...` → `var idx_path: String = String(world.call("_anim_dir")) + ...` |

#### The two construction branches (full-game site, `main.gd:1003-1041`)

```gdscript
	if render_mode == "3d":
		world = make_world3d()
		world.bind(game)
		add_child(world)

		camera = make_camera3d()
		add_child(camera)
		camera.bind(game, world.view_scale)
		camera.set_zoom_target(start_zoom, true)
		var focus3: Vector2 = Vector2(game.MAP_W, game.MAP_H) * 0.5 * Data.TILE_M
		if not homes.is_empty():
			focus3 = homes[0].pos
		if screenshot_path != "" and screenshot_focus == "relief":
			focus3 = _relief_focus_position() / world.view_scale
		camera.set("_target", focus3)
		camera.clamp_pos()
	else:
		world = C3WorldScript.new()
		world.bind(game)
		add_child(world)

		camera = C3CameraScript.new()
		add_child(camera)
		camera.bind(world)
		camera.set_zoom_target(start_zoom, Vector2.INF, true)  # W4-1: wide start
		...
```

`camera3d.gd` was not edited: its contract is `bind(game, view_scale:=1.0)`
and `set_zoom_target(target, immediate:=false, anchor:=INF)`, which is why the
3D leg uses `bind(game, world.view_scale)` and the 2-arg zoom call while the
2D leg keeps its original 3-arg call unchanged.

### Relaxed typing — why untyped rather than literal `Node`

A literal `var world: Node` / `var camera: Node` would make GDScript reject the
~25 existing `world.*` / `camera.*` member accesses (`bind`, `view_scale`,
`fog_explored`, `terrain_chunks`, `set_zoom_target`, `clamp_pos`, ...) at parse
time. Untyped (Variant) is the relaxed superset that accepts both the legacy
2D scripts and the dynamically loaded `Node3D`/`Camera3D` factories, and it
keeps every 2D call site textually identical.

One consequence was found and fixed: `var idx_path := world._anim_dir() + ...`
(`main.gd:1429` in the shipped file) could no longer infer a type. **All**
`:= ...world.` / `:= ...camera.` sites were audited — that was the only one;
it now uses an explicit `var idx_path: String = String(world.call("_anim_dir")) + ...`.
This was the exact parse failure that broke V7-52's `v7-52-input-uitest`
(job 62); the successful `v750-selftest` run proves `main.gd` now parses and
executes in the real game path.

### Duplicate-adapter hazard removed

An earlier draft declared `var picker3d` and intended to instantiate
`picking3d.gd` in main. Since V7-52's `input_controller.bind_3d(cam)`
(`input_controller.gd:111-123`) already creates and binds the single picking
adapter, that field was **removed** and main only calls the documented peer
hooks. There is exactly one `picking3d` instance in the 3D path.

## 5. Handoffs

- **V7-51 (world3d composition):** `make_world3d()` loads the current
  `world3d.gd`, which was re-checked at integration time and now exposes the
  full contract (`bind(g, h=null)` :214, `sync(dt)` :279, `view_scale` :79,
  `fx_layer` :81, `fog_explored`/`fog_vis` :82-83, `world_to_px` :293,
  `add_fx` :300, `has_chunk_or_fallback` :313). No stub work was needed here.
  Please keep `bind` / `view_scale` stable: the factory calls `world.bind(game)`
  and passes `world.view_scale` to the 3D camera.
- **V7-52 (input seam):** main calls `input_ctl.bind_3d(cam)` from
  `_apply_3d_hooks()` in **both** construction sites, after the normal
  `input_ctl.bind(game, world, hud, camera)`. No `cmd_*` code touched.
- **V7-53 (HUD minimap box):** main calls `hud.bind_3d(cam)` from the same
  helper, after `hud.bind(game, world)`. HUD/minimap data path untouched.
- **V7-11 / camera owner (optional):** 3D focus uses
  `camera.set("_target", focus3)` because `camera3d.gd` exposes no public
  focus setter (`_target` at `camera3d.gd:90`). If a public `set_focus()`
  lands, main should switch to it; no change required for the gate.
- **config owner (optional):** `config.gd` is not mine, so `main._ready()`
  reads the new key directly with `cfg.text("gameplay.render_mode", "2d")`
  and mirrors it to `Data.RENDER_MODE`. `config.gd:apply()` may later map it
  too; behaviour is already correct and additive.

## 6. Open questions

1. No end-to-end **3D-mode** runtime job has been run — the two green gates
   prove the seam's source/load/default and that the 2D game still works.
   A full `--config` run with `gameplay.render_mode=3d` is the natural next
   gate once all 3D modules are frozen.
2. `render_mode` is normalised with `to_lower()`; any other value than `3d`
   falls back to the 2D path. Whether an invalid value should warn is a
   config-owner decision.
3. The 3D camera focus relies on the semi-private `_target` field; see the
   V7-11 handoff above.
4. `t_render_mode.gd` is a source-inspection gate; it does not execute the 3D
   branch. Its PASS should not be read as proof of 3D rendering parity.

---

**End of report. V7-50 edited only its three owned files plus this report.**
