---
id: V7-66
title: "V7-66 — P0 minimap camera-jump fix (camera3d.jump_to_world + input_controller 3D fallback)"
owner: V7-66
scope: "variant3d/scripts/camera3d.gd and variant3d/scripts/input_controller.gd ONLY + this report"
date: 2026-11-24
status: PASS__RUNTIME_PROBE_11_11
verdict: "Minimap LMB click/drag now routes to a new Camera3D.jump_to_world() that sets _target and the transform together, invalidates the clamp memo and cancels the zoom anchor. 2D path byte-identical and still default. Parse clean; runtime probe 11/11. No visual parity claim."
godot_runs: "tickets 85, 87 (--check-only, both exit 0); 96/99 (harness tree-timing failure, pre-existing); 106 (out-of-map probe coords); 114 (PASS 11/11)"
---

# V7-66 — P0 minimap camera jump

## 1. Root cause and citations

- **Donor:** minimap LMB moves the main camera on press: `GetGUIMinimapUnderMouse` →
  `SetMainCameraMoveToTargetXZ(newx, newy)` at
  `C:\Games\Cossacks 3\data\gui\menu.inc\onmousedown.inc:116-131` (read-only Latin-1;
  `_control_MoveCameraToPosition` on double-click at `:121-122`). The same event is
  cited by AUDIT3D-05 E13/P0-1 (`AUDIT3D_05_camera_hud_pick.md:71,102-113`).
- **2D port:** `app/scripts/camera.gd:96-104` `jump_to_world(world_pos, view_scale=1.0)`
  writes `position` immediately, cancels `_zoom_anchor_screen`, calls `mark_dirty()`
  to invalidate the clamp memo, then `clamp_pos()`. Its caller
  `app/scripts/input_controller.gd:192-193` uses `camera.jump_to_world(wp, world.view_scale)`.
  `variant3d/scripts/camera.gd:96` is byte-equivalent, and
  `variant3d/scripts/input_controller.gd:226-227` already had that 2D-style call.
- **3D gap (pre-fix):** `camera3d.gd` had no `jump_to_world`, so the `has_method` test
  failed and the `else` fallback at `input_controller.gd:228-232` executed:
  `camera.global_position = wp * world.view_scale` — a Vector2 written into a Camera3D,
  with `world.view_scale = 16.0 px/m` (`world3d.gd:79`) corrupting metre coordinates.
  It bypassed `_target`/`_apply_transform()` (`camera3d.gd:146-153`) and the memoised
  `clamp_pos()` (`camera3d.gd:214-215` pre-fix), so the next `_apply_transform()` snapped
  the camera back. This is the P0 no-op confirmed in AUDIT3D-05 §3 E13 and §5 P0-1.

## 2. Exact diff (file:line)

### `variant3d/scripts/camera3d.gd` — inserted at `:208-223`

Added a public method between `get_view_rect()` and `clamp_pos()`; the pre-existing
`clamp_pos()` block shifted from `:208-237` to `:226-255`. No existing API was changed.

```gdscript
208 # T-NAV-RESPONSIVE — minimap click/drag jump. 2D parity: app/scripts/camera.gd:96-104
209 # (jump_to_world) and donor onmousedown.inc:116-131 (SetMainCameraMoveToTargetXZ).
210 # `world_pos` is sim metres in the top-left map origin — the SAME space as `_target` — so
211 # NO view_scale factor is applied here (3D view_scale = 16 px/m, world3d.gd:79).
212 # Writes the smoothed target AND the current Camera3D transform together: a target-only
213 # write is overwritten by the next _apply_transform(), a transform-only write is snapped
214 # back by clamp_pos() through the memo at :232-233 (the old 3D P0 failure).
215 func jump_to_world(world_pos: Vector2) -> void:
216     _zoom_anchor_screen = Vector2.INF  # a jump cancels any in-flight zoom anchor (camera.gd:97)
217     _target = world_pos
218     _apply_transform()
219     # Fresh memo, like 2D mark_dirty() (camera.gd:110-121): otherwise the stale memo
220     # makes the following clamp_pos() a no-op and the jump stays unclamped.
221     _last_clamp_target = Vector2.INF
222     _last_clamp_zoom = -1.0
223     clamp_pos()
```

Rationale: `_target` is the smoothed focus consumed by `_process()`/`_smooth_zoom()`,
while `global_position` is derived from it in `_apply_transform()`. Writing both keeps
them coherent; resetting the memo forces `clamp_pos()` to actually re-clamp; clearing
`_zoom_anchor_screen` prevents an in-flight zoom-at-cursor dolly from pulling the new
focus back (2D `camera.gd:97`).

### `variant3d/scripts/input_controller.gd` — `_minimap_reposition()` at `:222-240`

Added 8 lines at `:226-233` (comment + guarded dynamic call + early return). The original
2D block (former `:226-232`) is **byte-identical**, now at `:234-240`; `render_mode`
defaults to `"2d"` (`:21`), so the 2D path is unchanged and remains the default.

```gdscript
222 func _minimap_reposition(screen_pos: Vector2) -> void:
223     var wp := _minimap_world(screen_pos)
224     if wp == Vector2.INF or camera == null or world == null:
225         return
226     # V7-66 P0: the 3D camera exposes a metre-space jump_to_world (camera3d.gd); call it
227     # dynamically so the 2D Camera2D path below stays byte-identical and is still the
228     # default (render_mode defaults to "2d" at :21). The old fallback wrote a Vector2
229     # into Camera3D.global_position and scaled metres by 16 px/m, bypassing _target and
230     # the clamp memo — a 3D no-op that snaps back on the next _apply_transform().
231     if render_mode == "3d":
232         camera.call("jump_to_world", wp)
233         return
234     if camera.has_method("jump_to_world"):
235         camera.jump_to_world(wp, world.view_scale)
236     else:
237         camera.global_position = wp * world.view_scale
238         camera.clamp_pos()
239         if camera.has_method("mark_dirty"):
240             camera.mark_dirty()
```

`wp` comes from `_minimap_world()` (`:211-217`), which returns `Vector2(u*MAP_W, v*MAP_H) *
TILE_M` — sim metres, the same unit `jump_to_world()` expects. The 3D branch is placed
*before* the `has_method` test so the 2-arg 2D call can never reach the 1-arg 3D method.
No `bind`, `bind_3d`, `cmd_*`, hotkey, group or build-ghost code was touched.

## 3. API signature for V7-67's HUD call

```
camera3d.jump_to_world(world_pos: Vector2) -> void
```

- `world_pos` is **sim metres, top-left map origin** (`hud.gd`'s donor-derived `world_pos`,
  AUDIT3D-05 §5 P0-1); the same space as `camera3d._target`.
- **One argument only.** Do **not** pass `view_scale`: in 3D it is `16.0 px/m`
  (`world3d.gd:79`), and scaling metres by it is the original bug.
- Suggested HUD call: `cam3d.call("jump_to_world", world_pos)` (dynamic is fine; the
  method is public). V7-67 still owns the HUD press-handler `set_input_as_handled()` fix
  at `hud.gd:1397-1415`; this job does not edit `hud.gd`.
- The 2D `camera.gd:96-104` signature `(Vector2, float=1.0)` is unchanged; two-arg calls
  continue to hit the 2D camera only.

## 4. Verification (variant3d runner only)

All Godot launches went through `python -X utf8 variant3d\tools\godot_runner.py run ...`.

| Ticket | Job id | Command | Result |
|---|---|---|---|
| 85 | `v766-parse-cam3d` | `--headless --path variant3d --check-only --script res://scripts/camera3d.gd` | **ok**, exit 0, wait 0.00 s, run 3.70 s, stderr 0 bytes |
| 87 | `v766-parse-input` | `--headless --path variant3d --check-only --script res://scripts/input_controller.gd` | **ok**, exit 0, wait 78.76 s, run 5.76 s, stderr 0 bytes |
| 96 | `v766-jump-probe` | probe, first attempt | failed — harness: camera not settled in scene tree during `_initialize()` |
| 99 | `v766-t-camera3d` | existing `t_camera3d.gd` | failed 8/14 — same pre-existing `_initialize()` tree-timing issue; every failure backtrace is in `bind`/`_apply_transform`/`project_*`, none enters `jump_to_world` |
| 106 | `v766-jump-probe2` | probe, deferred | failed 8/11 — probe used out-of-map coords (map is 320 tiles × `TILE_M=2` = 640 m); clamp correctly rejected them |
| **114** | **`v766-jump-probe3`** | `--headless --path variant3d --script res://tests/t_v766_jump_probe.gd` | **ok**, exit 0, wait 209.61 s, run 3.35 s, **PASS 11/11** |

### Measured probe (ticket 114)

Temp file `variant3d/tests/t_v766_jump_probe.gd` bound `camera3d.gd` to a stub game
(`MAP_W=MAP_H=320`), added the camera to the deferred scene-tree, and measured:

```
PASS HAS_METHOD          camera3d exposes jump_to_world
PASS JUMP1_TARGET        target=(100.0, 200.0) want=(100.0, 200.0)
PASS JUMP1_X_MATCH       cam.x=100.000 target.x=100.000
PASS JUMP2_TARGET        target=(400.0, 300.0) want=(400.0, 300.0)
PASS JUMP2_MOVED         cam delta=316.2 m (a=(100.0, 34.05877, 254.5054) b=(400.0, 34.05877, 354.5054))
PASS JUMP2_X_MATCH       cam.x=400.000 target.x=400.000
PASS MEMO_STABLE         target before=(400.0, 300.0) after re-clamp=(400.0, 300.0)
PASS ANCHOR_CANCELLED    anchor=(inf, inf)
PASS CLAMP_CENTRE_IN_MAP view centre=(22.92252, 620.4254) map=[0,0]..(640.0, 640.0)
PASS CLAMP_TARGET_PUSHED_IN far=(-300.0, 940.0) clamped target=(22.92252, 625.1826)
PASS CLAMP_X_MATCH       cam.x=22.923 target.x=22.923
V766_JUMP_PROBE PASS 11/11 checks
```

Two distinct jumps moved both `_target` and the real `global_position` (316.2 m apart);
the memo held the second target steady; an injected zoom anchor was cleared; a jump far
outside the map was clamped back with its view centre inside `[0, 640]²` m. The probe was
**deleted after the run** (`Test-Path` returns false); no test file is left behind.

## 5. Required confirmations

- **`t_camera3d.gd` expectations checked before changing anything.** Its required API
  list at `tests/t_camera3d.gd:132-133` is the 8 existing methods
  (`bind, world_to_px, screen_to_world, clamp_pos, get_view_rect, get_viewport_corners,
  zoom_step, set_zoom_target`). `jump_to_world` is additive; no signature, return type or
  constant changed. No existing API was altered. (The test's runtime failure in this
  environment is the documented `_initialize()` tree-timing harness issue, not a
  regression: its backtrace never reaches the new method.)
- **No double-binding.** This diff does not touch `bind_3d()` (`input_controller.gd:111-123`)
  or the `_apply_3d_hooks()` call sites in `main.gd`. AUDIT3D-05 §4 conclusion — one call
  per mutually exclusive startup path, both `bind_3d()` implementations idempotent —
  still holds. Adding a camera method creates no adapter or child node.
- **No `cmd_*` changes.** Neither diff hunk contains a `cmd_*` symbol; all `game.cmd_*`
  order paths, hotkeys and build-ghost logic remain as audited in AUDIT3D-05 §2/E7.
- **2D byte-identical and default.** The 2D branch text at new `:234-240` equals the old
  `:226-232`; `render_mode` defaults to `"2d"` (`:21`).

## 6. Open questions / handoffs

1. **V7-67 (HUD) must still fix the press path.** `hud.gd:1397-1415` currently consumes
   the minimap press with `set_input_as_handled()` while its 2D `cam` is null. Until V7-67
   adds the 3D branch and calls `jump_to_world` there, the *press* is still swallowed;
   this job only makes the input-controller fallback (drag / unconsumed events) valid.
   Use the one-arg, metre-space signature in §3.
2. **E18/E19 remain open and out of scope.** Shift+number recentre
   (`input_controller.gd:826`) and journey-mode camera writes (`main.gd:1553-1578`) still
   write `camera.global_position` directly and can snap back. They are separate gaps from
   AUDIT3D-05 §5 P1-6/P2-4; not modified here (same file ownership for E18, but not tasked).
3. **`t_camera3d.gd` harness.** Its `_initialize()` tree-timing failure is pre-existing and
   unrelated. If a clean green gate is required, a future owner should defer its body like
   `t_nav_smoke.gd:19-23`; this job does not own that test.
4. **Coordinate-space split (AUDIT3D-05 §6 Q4).** `screen_to_world()` stays flat Y=0 while
   picking uses the height field. `jump_to_world()` deliberately takes already-computed
   sim-metre XZ, so it is unaffected by that split.
5. **Donor yaw / projection remain UNVERIFIED** (`default.cameras` yaw, FOV); this fix is a
   port seam, not a donor-fidelity claim.
6. **No visual parity claim.** Verification is parse + headless numeric probe only;
   no screenshot, A/B or rendering comparison was performed.

## 7. Verdict

The P0 minimap camera-jump is fixed at the camera and input-controller seam: a 3D minimap
click/drag now sets `_target` and the Camera3D transform coherently, survives the clamp
memo, respects clamps and cancels zoom anchors. Parse clean on both owned files; runtime
probe 11/11. Acceptance remains gated on V7-67's HUD press-handler change and the other
AUDIT3D P1 items; visual parity is unverified.
