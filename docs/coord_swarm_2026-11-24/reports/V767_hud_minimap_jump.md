---
agent: V7-67
role: P0 fix — 3D minimap left-click/drag camera jump in the HUD
date: 2026-11-24
status: DONE (parse PASS ticket 83; variant selftest PASS 29/29 ticket 86; 2D handler byte-identical; runtime camera movement not measured here)
owns: "variant3d/scripts/hud.gd + this report ONLY — no camera3d.gd / input_controller.gd / world3d.gd / app / config / tests edits; no git operations"
runner_jobs: ["v767-hud-parse (ticket 83)", "v767-hud-minimap (ticket 86)"]
scope: "TABS; no RNG; donor/2D parity; dynamic call to a parallel-added public API; minimap image, blips and orders untouched"
handoff_to: "V7-66 (camera3d.gd owner) — land public jump_to_world(world_pos: Vector2) for the dynamic call in hud.gd:1453 to take effect"
---

# V7-67 — 3D minimap click → `jump_to_world` (P0-1 / E13)

## 1. Problem and evidence

`AUDIT3D-05:71,102-113` confirms P0-1: in 3D the HUD's `_on_minimap_input()`
called `get_viewport().get_camera_2d()` (null for `Camera3D`) but still invoked
`set_input_as_handled()` on an LMB press, swallowing the event before the 3D
fallback could run; the drag branch wrote a `Vector2` into `Camera3D.global_position`.

Donor and 2D behaviour that define the target:

- Donor `data/gui/menu.inc/eventminimap.inc:8-17,28-34` — minimap LButton
  down/repeat re-enters `OnMouseDown`.
- Donor `data/gui/menu.inc/onmousedown.inc:116-131` — under the minimap the LMB
  path calls `_control_GetMoveCameraToPositionOffset(x, y, newx, newy)` then
  `SetMainCameraMoveToTargetXZ(newx, newy)` (double-click uses
  `_control_MoveCameraToPosition(x, y, 0, False)` at `:121-122`).
- 2D `app/scripts/hud.gd:1368-1386` — minimap click/drag writes the camera and
  RMB issues `ictl.minimap_order(world_pos)`.
- 2D `app/scripts/camera.gd:92-104` — public `jump_to_world(world_pos, view_scale = 1.0)`.
- 3D `variant3d/scripts/hud3d_adapter.gd:32-76` — `get_minimap_box()` is the
  single tile↔metre mapping: world metres → minimap tiles via
  `int(p / TILE_M)` at `:57-61`, position inclusive/end exclusive at `:75-76`.
- `variant3d/scripts/world3d.gd:215-216` — game `(x,y)` maps to world `(x,z)`.
- `variant3d/scripts/input_controller.gd:222-232,459-462` — existing fallback
  already probes `camera.has_method("jump_to_world")`.

## 2. Exact diff (`variant3d/scripts/hud.gd`)

Only additions; **no existing line was deleted, renamed or re-indented**.

| Final line(s) | Change |
|---|---|
| `:1405-1410` | In `_on_minimap_input()`, a 3D-only early guard inserted immediately after `var world_pos := …` (`:1404`): 4 comment lines, `if _render_mode_3d and _minimap_jump_3d(ev, world_pos):`, `return`. |
| `:1427-1455` | Two new private helpers (blank-line separated): `_minimap_jump_3d()` at `:1428-1443` and `_cam3d_jump()` at `:1445-1454`. |

**2D path byte-identical (measured).** The unchanged 2D handler —
`variant3d/scripts/hud.gd:1402-1404` plus `:1411-1426` — was compared
character-for-character against `app/scripts/hud.gd:1368-1386`:
both **1002 chars, exact match** (`-ceq` True). The only new code in the 2D
execution path is the `_render_mode_3d and …` guard, which is false in 2D
(`bind_3d()` is never called there; `hud.gd:201-213`).

**3D behaviour:**

- `:1434-1438` — LMB press: jump, then `set_input_as_handled()` **only on
  success** (`:1436`), then `_draw_minimap_viewport_box()`.
- `:1439-1442` — LMB drag: same jump + box redraw; **never** swallowed.
- `:1443` — any other event returns false; RMB orders fall through to the
  untouched 2D order branch at `:1418-1422` (`ictl.minimap_order(world_pos)`).
- The minimap image, `minimap_base`/`minimap_img`/`minimap_view_img`, blips and
  `_mm_paint_box()` are not referenced by the new code.

## 3. Dynamic call contract

```gdscript
# hud.gd:1445-1454
func _cam3d_jump(world_pos: Vector2) -> bool:
	var cam: Object = _bound_cam3d
	if cam == null or not cam.has_method("jump_to_world"):
		return false
	cam.call("jump_to_world", world_pos)   # hud.gd:1453
	return true
```

- `cam` is `_bound_cam3d: Object`, set by `bind_3d()` at `hud.gd:212` — **no
  `camera3d.gd` class-name dependency** anywhere in the new code.
- One `Vector2` argument, sim metres in game `(x,y)` space (game y == world z,
  `world3d.gd:215-216`), the same coordinate `world_pos` that 2D uses at
  `app/scripts/hud.gd:1370`. Compatible with the 2D signature's default
  `view_scale = 1.0` (`camera.gd:96`) and with V7-66's promised one-arg method.
- `has_method()` guard makes the call safe **before** V7-66 lands: returns
  `false`, no swallow, event propagates.
- Success redraw calls `_draw_minimap_viewport_box()`, whose 3D branch reads
  `_hud3d_adapter.get_minimap_box()` at `hud.gd:1476` — so the adapter's box
  stays the single source of truth and updates on the same input frame.
- Caller consumes the event only on a successful jump; drag motion is never
  consumed.

## 4. Measured verification (variant3d runner only)

| Job id | Ticket | Command (abridged) | Result |
|---|---|---|---|
| `v767-hud-parse` | **83** | `python variant3d\tools\godot_runner.py run --id v767-hud-parse --timeout 120 -- --headless --path variant3d --check-only --script res://scripts/hud.gd` | **ok**, exit 0, run **4.73 s**; stdout = Godot 4.7.2 banner only; `stderr.txt` **0 bytes**. |
| `v767-hud-minimap` | **86** | `python variant3d\tools\godot_runner.py run --id v767-hud-minimap --timeout 300 -- --headless --path variant3d -- --self-test variant3d/selftest.json` | **ok**, exit 0, run **82.22 s**; stdout includes `self-test report: …/variant3d/selftest.json`. Regenerated `variant3d/selftest.json`: **`passed: true`, 29/29 steps passed, 0 failed**, `sim_seconds 366.5`, `shots_fired 73`. |

Additional measurement: the 2D handler byte-identity check in §2 (1002/1002
chars, exact match).

**Caveat — measured, not hidden:** ticket 86's `stderr.txt` is 3594 bytes and
contains `SCRIPT ERROR`/`ERROR` lines from `res://scripts/world3d_entities.gd:573,606`
(Variant-inferred type warnings treated as errors → script failed to load) and
`res://scripts/world3d.gd:207` (`Nonexistent 'int' constructor`), plus exit-time
ObjectDB/resource leak warnings. **None reference `hud.gd`**; both files are
outside my ownership. The selftest still reported `passed: true` 29/29. Those
errors were not diagnosed or fixed here.

**Full 2D uitest: not run.** The app uitest is ~119 s historically and does not
load `variant3d/scripts/hud.gd` (app uses its own untouched `app/scripts/hud.gd`),
so it cannot detect a regression from this diff. At submit time the variant3d
spool had **7 pending jobs and a held `godot.lock`** (parallel agents), so
contending the shared Godot binary for an uninformative job was judged not
cheap. The byte-identity measurement above is the stronger 2D-regression
evidence for this file-scoped change.

**No visual parity claim** and no measurement that the 3D camera actually
moves on a minimap click — that requires V7-66's method to land plus a runtime
probe.

## 5. Open questions

1. **Dependency on V7-66.** `grep` finds no `jump_to_world` in `camera3d.gd` at
   the time of writing. Until it lands, `_cam3d_jump()` returns false: the LMB
   press is deliberately *not* swallowed and the event reaches
   `input_controller.gd:222-232`, which also lacks the method and falls back to
   the old invalid `Vector2 → Vector3` write. The P0 fix becomes effective only
   when V7-66 ships the public method.
2. **Signature.** The task specifies `cam.call("jump_to_world", world_pos)`
   (one argument). If V7-66 requires a second, non-default `view_scale`
   argument, `hud.gd:1453` must be updated; no class-name coupling was introduced.
3. **Relief/height.** `world_pos` is the flat game-plane coordinate (Y=0
   convention), matching the 2D path and the adapter mapping. Whether the donor
   snaps minimap targets to terrain height is UNVERIFIED (audit open question 4).
4. **Donor double-click.** `onmousedown.inc:121-122` uses a distinct
   `_control_MoveCameraToPosition` on `bDouble`; the port treats press and drag
   as one jump. Donor double-click framing remains UNVERIFIED and unimplemented.
5. **Selftest stderr errors** (§4) from `world3d_entities.gd` / `world3d.gd`
   are out of scope for this ownership boundary; no conclusion drawn here.
