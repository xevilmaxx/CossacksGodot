---
agent: W4-2
wave: 4
date: 2026-11-24
title: Wheel/key zoom input translation (event-only)
files_owned:
  - app/scripts/input_controller.gd
status: FIXED AND HEADLESS-VERIFIED (17/17 ui-test); wheel feel UNVERIFIED in a live window
runner_jobs: [1282, 1285, 1288]
backup: inbox/backup/input_controller.gd.bak-W42
handoff_to: W4-1
---

# W4-2 — Zoom input translation

## Boundary (coordinator ruling, honoured)

W4-1 (`camera.gd` + `main.gd`) is **authoritative** for zoom state, step size,
smoothing/interpolation, clamp bounds and the more-zoomed-out startup default.
This worker owns **only** the input translation inside `input_controller.gd`:
wheel delta -> one or more `camera.zoom_step()` calls with the event position as
the zoom-to-cursor anchor. No tween, easing, clamp math, default zoom, or
camera/main edits are present in this diff.

## VERIFIED-ALREADY (read-only, current source)

| Item | Evidence |
|---|---|
| `input_controller.gd` had no wheel/zoom handler at all | `app/scripts/input_controller.gd:368` (pre-edit) `_unhandled_input()` handled left/right button, motion, keys only; grep for `WHEEL|zoom_to_cursor|set_zoom|zoom_step` in that file returned zero matches. |
| Zoom input lived in `camera.gd` (W4-1's file) | old `camera.gd:169-175`: `_unhandled_input` handled `MOUSE_BUTTON_WHEEL_UP` -> `_zoom_at_cursor(zoom_step)` and `MOUSE_BUTTON_WHEEL_DOWN` -> `_zoom_at_cursor(1.0 / zoom_step)`, each calling `get_viewport().set_input_as_handled()`. Current `camera.gd` no longer contains any `MOUSE_BUTTON_WHEEL` / `_unhandled_input` handler — W4-1 removed it for the API split. |
| W3-2's diff is zoom-neutral | `git diff -- app/scripts/input_controller.gd` (read-only): additions are `_hint_hold_ms`, rally-cursor tinting, `_hint`/`_price_hint`, idle peasant/mine selection helpers, build-gate refusals, refund note; no wheel/zoom/camera calls added or removed. Its only `_unhandled_input` change is the peasant/build-gate refusal block inside the LEFT-button branch. |
| No key zoom binding exists in donor or port | `C:\Games\Cossacks 3\data\game\var\hotkeys.cfg` has no zoom/wheel entry; `app/scripts/data.gd` has no zoom action (only `CAMERA_ZOOM_STEP` at `:168`). Therefore **no key zoom was added**. |
| Control-group / edge-scroll / minimap behaviour untouched | The new wheel early-return sits before the existing minimap and left/right-button branches; no existing branch body was edited. `camera.gd:96-176` still owns edge scroll and `clamp_pos()`; `input_controller.gd:756-757` Ctrl+number group recall unchanged. |

## DONOR TRUTH

- `C:\Games\Cossacks 3\data\cameras\camera.cfg:6-10`: `SphereHeight = 58`,
  `SphereHeightMin = 20`, `SphereLength = 58`, `SphereLengthMin = 20` — the
  height bounds that W4-1 maps to zoom clamp (port `camera.gd:58-61`).
- `camera.cfg:14-16`: `MoveVelocity = 0.125`, `HeightVelocityFactor = 0.05`,
  `RotationVelocity = 0.05` — donor elastic feel constants; port analogues are
  W4-1's `zoom_smooth_rate`/`zoom_notch_gain` (not touched here).
- `C:\Games\Cossacks 3\data\gui\common.inc\onmousewheel.inc:296-303` — the
  authoritative wheel-to-zoom translation:
  `var wheelDelta : Float = -(GetGUIEventMouseWheelDelta/60)*(gProfile.wheelspeed*0.5+0.25)*2;`
  then `ZoomCamera(0, wheelDelta, newx, newy, True)` -> `SetCameraElasticTargetObject(0)`
  -> `SetMainCameraMoveToTargetXZ(newx, newy)`. This is a **signed, delta-scaled**
  target change driven by the *profile wheel speed*, not a fixed one-notch step.
- `C:\Games\Cossacks 3\data\scripts\lib\profile.script:20,253,516` and
  `data\resources\config.res:790`: `wheelspeed := 0.5` default, clamped 0..1;
  `onmousewheel.inc:229` uses `(0.15+gProfile.wheelspeed*0.75)` for list scroll.
- `onmousewheel.inc:320-338`: screenshot-camera mode uses Ctrl+wheel to change
  `SetCameraFocalLengthInfo(400+fov*5, ...)`; not part of skirmish camera control
  and not ported here.
- No wheel invert key was found; the donor sign is the explicit `-` on
  `GetGUIEventMouseWheelDelta` at `onmousewheel.inc:296`.
- `C:\Games\Cossacks 3\data\cameras\config.cdx`: **NOT PRESENT** (directory has
  only `camera.cfg`, `cameradebug.cfg`, `camerascreenshot.cfg`, `default.cameras`).
  Marked UNVERIFIED/N-A.
- Donor `ZoomCamera()` implementation itself (engine-side, likely binary) was
  **UNVERIFIED**; only its call site and signed delta scaling were read.

## FIXED (exact W4-2 diff, input_controller.gd only)

State added after `_hint_hold_ms` (`input_controller.gd:47-49`):

```gdscript
+# W4-2: wheel-delta accumulator. Input translation only (no tween/easing):
+# coalesce fractional high-resolution wheel deltas into whole notch requests.
+var _wheel_accum := 0.0
```

New helper and early wheel branch at the top of `_unhandled_input()`
(`input_controller.gd:372-401`; `func _zoom_wheel` at `:376`, wheel test at `:399-400`):

```gdscript
+# W4-2: pure input translation — a wheel event becomes one or more camera
+# zoom requests. No interpolation, easing, clamp or cursor math is computed
+# here; camera.gd (W4-1) owns all of that. The accumulator only coalesces
+# fractional high-resolution wheel deltas into whole notches, which removes
+# one-notch jitter on trackpad-style wheels without changing normal wheels.
+func _zoom_wheel(ev: InputEventMouseButton, sign: float) -> void:
+	if camera == null:
+		return
+	var fv: Variant = ev.get("factor")
+	var f: float = clampf(float(fv), 0.01, 8.0) if fv != null else 1.0
+	_wheel_accum += f
+	var notches: int = int(_wheel_accum)
+	if notches > 0:
+		_wheel_accum -= float(notches)
+		if camera.has_method("zoom_step"):
+			# W4-1 authoritative API: camera owns step size, smoothing and
+			# the clamp. Dynamic call: camera.gd has a float `zoom_step`
+			# member, so a literal call would not compile. Pass the wheel
+			# event position as the zoom-to-cursor anchor.
+			camera.call("zoom_step", sign * float(notches), ev.position)
+	get_viewport().set_input_as_handled()
+
 func _unhandled_input(event: InputEvent) -> void:
 	if event is InputEventMouseButton:
 		var mb := event as InputEventMouseButton
+		# W4-2: wheel translation lives here; set_input_as_handled() makes this
+		# and camera.gd's legacy wheel branch mutually exclusive, so one notch
+		# can never zoom twice regardless of scene-tree order.
+		if mb.button_index == MOUSE_BUTTON_WHEEL_UP or mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
+			_zoom_wheel(mb, 1.0 if mb.button_index == MOUSE_BUTTON_WHEEL_UP else -1.0)
+			return
 		var mm := _minimap_screen_rect()
```

Why this is faster/fluid: `factor > 1` high-resolution wheel events accumulate
instead of being discarded, so no fractional notch is lost; whole notches are
forwarded to W4-1's `zoom_step()` which applies the larger `zoom_notch_gain`
target step and its smoothing, and the event position is passed through so the
world point under the cursor stays fixed. `set_input_as_handled()` prevents any
double zoom if an older `camera.gd` wheel branch is also present. No smoothing,
step constant, or default zoom is owned here.

## W4-1 API consumed (hand-off, no camera/main edits)

Current `app/scripts/camera.gd:182-190`:

```gdscript
func zoom_step(notches: float, anchor_screen: Vector2 = Vector2.INF) -> void:
func set_zoom_target(target: float, anchor_screen: Vector2 = Vector2.INF, immediate: bool = false) -> void:
```

`input_controller.gd` calls `camera.call("zoom_step", sign * float(notches), ev.position)`
behind `camera.has_method("zoom_step")`. The `.call()` is mandatory: a literal
`camera.zoom_step(...)` does not compile because `camera.gd` also has a float
member named `zoom_step_factor` (renamed by W4-1 from `zoom_step` after job 1282
caught the collision). If W4-1 later changes the signature, only this one call
site needs updating; if it adds a `wheel_zoom(delta, screen)`-style API, the
accumulator line can forward the raw delta instead. W4-1's `set_zoom_target()`
and `_smooth_zoom()` remain authoritative for clamp and easing.

## Backup

`Copy-Item app\scripts\input_controller.gd inbox\backup\input_controller.gd.bak-W42`
— done before any edit. Verified size 41262 bytes.

## Runner jobs (honest)

| Job | Result | Cause |
|---|---|---|
| 1282 `w42-zoom-input` | **failed** (123.34 s) | Mid-edit snapshot: my literal `camera.zoom_step(dir)` collided with camera's float `zoom_step` member (`input_controller.gd:389` parse error), plus W4-1's in-flight `DEFAULT_ZOOM` error in `camera.gd:56`. Both reconciled before the next job. |
| 1285 `w42-zoom-input2` | **failed** (124.92 s) | W4-1 was still refactoring `camera.gd`: `camera.gd:49` "Cannot assign a new value to a constant" and `:185` `pow()` argument Callable. No error in `input_controller.gd`. |
| 1288 `w42-zoom-input3` | **ok** (125.78 s, exit 0) | Current tree. `app/uitest.json`: `passed: true`, **17/17 steps passed** (menu_shell, select_box, order_keys, build_flow, train_flow, squad_keys, rally_panel, market_panel, research_panel, delete_key, speed_pause, cursor_ctx, groups, minimap_frustum, garrison_keys, hotkeys_live, save_load_ui). |

No full selftest was run (per directive). `t_forest_bake` was not used.

## Determinism note

No RNG added. `_wheel_accum` is a deterministic float accumulator: with the
same wheel factor sequence it produces the same integer notch count and the
same camera calls every run. Only the number of `_unhandled_input` events and
their `factor` values matter; wall-clock time and frame rate do not enter the
translation. Camera smoothing itself is W4-1's and uses `dt`, not this layer.

## NOT-DONE / OPEN QUESTIONS

- **NOT-DONE:** live visual A/B of wheel feel and zoom-to-cursor tracking —
  headless runner cannot exercise a physical wheel; only parse + 17-step UI
  journey were verified.
- **NOT-DONE:** key zoom — no donor or port binding exists; deliberately not
  invented. Add only if W4-1 exposes a key action and the coordinator assigns it.
- **UNVERIFIED:** donor `config.cdx` (file absent); donor `ZoomCamera()` engine
  implementation and the exact internal mapping from `wheelDelta` to height.
- **OPEN:** `factor` semantics in Godot 4.7 `InputEventMouseButton` — the helper
  treats `factor > 1` as more wheel movement (standard notch = 1). If a device
  reports sub-unit deltas, the accumulator silently drops them; confirm with a
  real high-resolution wheel before relying on the fluidity gain.
- **OPEN:** W4-1's `zoom_notch_gain` (2.0) plus this notch forwarding may be
  faster than the owner expects; tuning belongs in `camera.gd`, not here.
