---
agent: W4-1
wave: 4
date: 2026-11-24
title: Camera zoom speed/fluidity + wider startup default
files_owned:
  - app/scripts/camera.gd
  - app/scripts/main.gd
status: IMPLEMENTED AND HEADLESS-VERIFIED; visual feel UNVERIFIED
runner_jobs: [1283, 1284, 1286, 1287]
---

# W4-1 — Zoom fluidity and more-zoomed-out start

## Verdict

Done within the sharp boundary: `camera.gd` owns zoom state, target, clamp and all
smoothing; `main.gd` owns the startup default; `input_controller.gd` was **not edited**
(read-only hand-off below). Wheel/key event translation is W4-2's, and W4-2 has
landed a guarded dynamic call to the API below. Headless verification passes
(jobs 1286/1287). Visual A/B of zoom feel is for owner/coordinator review.

## VERIFIED-ALREADY (unchanged, re-verified in current source)

| Item | Evidence |
|---|---|
| Zoom clamp derived from donor heights | `app/scripts/camera.gd:58-61`: `min_zoom = h_min / h_max`, `max_zoom = h_max / h_min`, with `Data.CAMERA_MIN_HEIGHT/MAX_HEIGHT` (`app/scripts/data.gd:162-163`) from `config.gd:396-397`. Donor `camera.cfg:6-7`: `SphereHeight = 58`, `SphereHeightMin = 20` → 0.345..2.9. Unchanged. |
| Camera steps before `world.sync()` | `camera.gd:35-37` `PROCESS_PRIORITY := -100`, assigned in `bind()`; job 1286 `camera_early_priority ... -100` PASS. |
| Jump / dirty / clamp memo | `camera.gd:74-99` `jump_to_world`, `mark_dirty`, `clamp_pos` still work; job 1286 `camera_jump_immediate`, `camera_mark_dirty` PASS. |
| Minimap rect / world math and drag clamp | job 1286 `minimap_center`, `minimap_drag_clamped`, `minimap_rect_cached` PASS. Frustum *drawing* not asserted — see NOT-DONE. |
| Screenshot focus sourcing | `main.gd:148` `screenshot_focus = cfg.text("gameplay.screenshot_focus", "start")` untouched; `main.gd:713-716` relief/start focus position logic untouched. |
| Donor zoom-to-cursor idea | Old `camera.gd` `_zoom_at_cursor` (backup `:157-167`) anchored the world point under the mouse; preserved via `anchor_screen` in the new API. |

## FIXED (exact diffs)

### `app/scripts/camera.gd` (was clean before W4-1; diff is all mine)

Header/state (current `camera.gd:1-26`):

```gdscript
+# W4-1: the zoom state, smoothing and public zoom API live here. Event
+# translation (wheel/key -> zoom_step) belongs to W4-2 in input_controller.gd.
+const C3ConfigScript = preload("res://scripts/config.gd")
-const DEFAULT_ZOOM := 2.0
-var zoom_step := 1.15
+var zoom_step_factor := 1.15    # Data.CAMERA_ZOOM_STEP — donor-style base step
+var zoom_notch_gain := 2.0      # camera.zoom_notch_gain
+var zoom_smooth_rate := 18.0    # camera.zoom_smooth_rate
+var zoom_target := 1.0
+var _zoom_anchor_screen := Vector2.INF
```

Config read and startup state in `bind()` (`camera.gd:49-64`):

```gdscript
-	zoom_step = Data.CAMERA_ZOOM_STEP
+	zoom_step_factor = Data.CAMERA_ZOOM_STEP
+	var cfg = C3ConfigScript.active
+	if cfg != null:
+		zoom_notch_gain = cfg.num("camera.zoom_notch_gain", 2.0)
+		zoom_smooth_rate = cfg.num("camera.zoom_smooth_rate", 18.0)
...
-	zoom = Vector2.ONE * clampf(DEFAULT_ZOOM, min_zoom, max_zoom)
+	zoom_target = clampf(1.0, min_zoom, max_zoom)
+	zoom = Vector2.ONE * zoom_target
+	_zoom_anchor_screen = Vector2.INF
```

Anchor cancellation and per-frame smoothing hook (`camera.gd:74,91,122`):

```gdscript
+	_zoom_anchor_screen = Vector2.INF  # a jump cancels any in-flight zoom anchor  (jump_to_world)
+	_zoom_anchor_screen = Vector2.INF                                              (mark_dirty)
+	_smooth_zoom(dt)  # frame-rate-independent zoom, before pan and clamp         (_process)
```

Tail replaced: old `_zoom_at_cursor()` and camera-side wheel branches removed
(they were input-side handling; W4-2 now owns events). New API at
`camera.gd:178-216`:

```gdscript
func zoom_step(notches: float, anchor_screen: Vector2 = Vector2.INF) -> void:
	if notches == 0.0:
		return
	set_zoom_target(zoom_target * pow(zoom_step_factor, notches * zoom_notch_gain), anchor_screen)

func set_zoom_target(target: float, anchor_screen: Vector2 = Vector2.INF, immediate: bool = false) -> void:
	zoom_target = clampf(target, min_zoom, max_zoom)
	_zoom_anchor_screen = anchor_screen
	if immediate:
		zoom = Vector2.ONE * zoom_target
		_zoom_anchor_screen = Vector2.INF

func _smooth_zoom(dt: float) -> void:
	if absf(zoom_target - zoom.x) < 0.0005:
		if zoom.x != zoom_target:
			zoom = Vector2.ONE * zoom_target
		_zoom_anchor_screen = Vector2.INF
		return
	var old_z := zoom.x
	var t := 1.0 - exp(-zoom_smooth_rate * dt)
	var new_z := old_z + (zoom_target - old_z) * t
	if absf(zoom_target - new_z) < 0.0005:
		new_z = zoom_target
	zoom = Vector2.ONE * new_z
	if _zoom_anchor_screen != Vector2.INF and new_z != old_z:
		var vp_size := get_viewport().get_visible_rect().size
		var off := (_zoom_anchor_screen - vp_size * 0.5) / old_z
		position += off * (1.0 - old_z / new_z)
	if new_z == zoom_target:
		_zoom_anchor_screen = Vector2.INF
```

Why this is faster/fluid: one notch moves the **target** by
`1.15^2 = 1.3225` (≈2× the log-speed of the old flat 1.15 factor); `zoom`
approaches the target with `t = 1 - exp(-18·dt)`, i.e. ~95% of a step in
~0.17 s, independent of frame rate. `dt` is already capped at 50 ms
(`camera.gd:121`), so a hitch cannot teleport the zoom. Anchor correction is
incremental (`position += off·(1 - old_z/new_z)`), so it composes with pan
instead of overriding it, and resets on `jump_to_world`/`mark_dirty`.

The internal `zoom_step` **variable** was renamed to `zoom_step_factor` to
resolve a Godot parse error (function and variable cannot share a name).
This is not a called-symbol rename: no external site used the variable.

### `app/scripts/main.gd` (W4-1 hunks only; see note below)

```gdscript
+var start_zoom := 0.75            # camera.start_zoom                    (main.gd:65)
+	start_zoom = cfg.num("camera.start_zoom", 0.75)                       (main.gd:153)
+	camera.set_zoom_target(start_zoom, Vector2.INF, true)  # W4-1: wide start (main.gd:541, :710)
-				camera.zoom = camera.zoom.lerp(Vector2(want_zoom, want_zoom), 0.2)
+				camera.set_zoom_target(want_zoom)  # W4-1 smoothing owns the lerp (main.gd:1246)
```

`immediate=true` makes the startup zoom deterministic and snap before the first
drawn frame; `screenshot_focus` position logic is untouched, so screenshot
framing and `clamp_pos()` still apply at the new zoom. Journey mode now drives
the same target API, so it no longer fights the new smoothing.

**Note on `git diff HEAD`:** `main.gd` was already modified by W26 before W4-1
(the `--self-only`, CLI budget and selftest-baseline hunks). Those are not mine.
The backup below is the exact pre-W4-1 state; only the five hunks above are W4-1.

## Donor-vs-port starting zoom and speed

| Source | Literal | Zoom units / effect |
|---|---|---|
| Donor `data/cameras/camera.cfg:6-7` | `SphereHeight = 58`, `SphereHeightMin = 20` | Clamp 20/58 = 0.345 .. 58/20 = 2.9 (same formula at `camera.gd:58-61`). |
| Donor `data/gui/menu.inc/docreate.inc:82` | `SetCameraElasticDistance(100); // camera will clamp this value to maximum` | Start camera forced to **max distance / widest view** (height 58 → 0.345 in port units). Derived, not a literal zoom value. |
| Donor `data/cameras/camera.cfg:27` | `StepTimeCameraDistance = 0.005` | Engine-side elastic damping for distance changes. |
| Donor `data/gui/menu.inc/onshortcut.inc:1094,1103` | `step := 5;` | PGUP/PGDN elastic-distance step (0.25 in screenshot mode, `:1092,1101`). |
| Donor `data/gui/common.inc/onmousewheel.inc:296,298` | `wheelDelta := -(GetGUIEventMouseWheelDelta/60)*(gProfile.wheelspeed*0.5+0.25)*2;` then `ZoomCamera(0, wheelDelta, ...)` | Wheel zoom is **instant**: `time=0` means `SetCameraInfoSmoothingTime(0)` / `SetCameraInfoSmoothingChange(false)` at `onmousewheel.inc:16-17`. |
| Port BEFORE (backup `camera.gd:15`) | `const DEFAULT_ZOOM := 2.0` | ~2× closer than the earlier 1.0 default. |
| Port AFTER (`main.gd:65,153,541,710`) | `start_zoom = cfg.num("camera.start_zoom", 0.75)` | **2.67× wider** than 2.0; 0.75 inside 0.345..2.9. |
| Port step/smoothing (`camera.gd:19-25`) | `zoom_step_factor=1.15`, `zoom_notch_gain=2`, `zoom_smooth_rate=18` | 1.3225× target per notch, exponential approach; deliberately faster and fluider than donor's instant step (owner directive), retaining donor clamp and zoom-at-cursor. |

`config.cdx` contains only compiled function-name strings (e.g.
`SetCameraEventWheelDelta`, `SetCameraMouseDistanceSpeed`); no zoom/wheel
value literals were found there. `cossacks.ini` has only save/log settings.
`gProfile.wheelspeed` default: **UNVERIFIED** (slider at
`showsettings.inc:1042`; no numeric default found in donor files).

## Exact API contract for W4-2 (input_controller.gd, read-only)

W4-1 is authoritative for step size, clamp and smoothing speed. W4-2 must only
translate events:

- `zoom_step(notches: float, anchor_screen: Vector2 = Vector2.INF)` — `notches > 0`
  zooms in, `< 0` zooms out. Pass the wheel event's screen position as
  `anchor_screen` for zoom-to-cursor. Implemented at `camera.gd:182-185`.
- `set_zoom_target(target: float, anchor_screen: Vector2 = Vector2.INF, immediate: bool = false)`
  — absolute clamped target; `INF` anchor = zoom about view centre;
  `immediate=true` snaps. `camera.gd:189-194`.
- `zoom_target` / `zoom` are readable. `zoom_notch_gain` and `zoom_smooth_rate`
  come from `camera.zoom_notch_gain` / `camera.zoom_smooth_rate` via
  `C3ConfigScript.active.num(...)` at `camera.gd:53-55`.

Observed W4-2 call sites (already landed; I did not touch them):
`input_controller.gd:376-391` `_zoom_wheel()` accumulates `factor`, and at
`:385` guards with `camera.has_method("zoom_step")`, then at `:390`:

```gdscript
camera.call("zoom_step", sign * float(notches), ev.position)
```

`input_controller.gd:399-400` routes wheel-up/down into `_zoom_wheel(±1)`.
There is no smoothing/tween/default in `input_controller.gd`. Minor stale
comment at `input_controller.gd:387-388` says camera.gd has a float `zoom_step`
member — after the rename to `zoom_step_factor` a literal
`camera.zoom_step(...)` would now compile; the dynamic call remains correct.

## Backups

- `inbox/backup/camera.gd.bak-W41` — byte-identical to pre-W4-1 `camera.gd` (sha256 prefix `d060e7c272cee124`).
- `inbox/backup/main.gd.bak-W41` — byte-identical to pre-W4-1 `main.gd` (sha256 prefix `12929b8c0265abe1`, includes the earlier W26 changes).

Tabs and line endings preserved; no called-symbol renames; no new RNG.

## Runner jobs and results

Command used (exact targeted job from the task):

```
python app\tools\godot_runner.py run --id w41-zoom --timeout 180 -- --headless --path app --script res://tests/t_nav_smoke.gd
```

`app/tests/t_nav_smoke.gd` exists (`app/tests/` listing) and is the documented
camera/minimap smoke test (`app/tests/manifest.json` has no entry for it, but
the task named it explicitly and its header documents the same command).
No full selftest was run (coordinator gate).

| Ticket | Id | Command | Result |
|---|---|---|---|
| 1283 | `w41-zoom` | t_nav_smoke | FAILED — mid-edit parse error (`Could not preload camera.gd`). |
| 1284 | `w41-syntax` | `--check-only --script camera.gd` | FAILED — exact diagnostic: `Function "zoom_step" has the same name as a previously declared variable` at `camera.gd:182`. Fixed by renaming the var to `zoom_step_factor`. |
| 1286 | `w41-zoom` | t_nav_smoke | **OK**, exit 0, 8.76 s, 6/6 PASS: `camera_early_priority`, `camera_jump_immediate`, `camera_mark_dirty`, `minimap_center`, `minimap_drag_clamped`, `minimap_rect_cached`; stderr empty. |
| 1287 | `w41-parse` | `--check-only --script camera.gd` | **OK**, exit 0, stderr empty — current `camera.gd` parses. |

Result JSON: `app/.godot_queue/status.json` history entries 1283/1284/1286/1287;
stdout/stderr under `app/.godot_queue/results/0000128{3,4,6,7}_*/`.

## Determinism note

No RNG added. Startup uses `set_zoom_target(..., immediate=true)`, so the
initial zoom is a clamped config value applied synchronously before the first
frame — deterministic for screenshots and selftests regardless of frame timing.
Smoothing uses `exp(-rate·dt)` with `dt` capped at 0.05 s; the decay is
frame-rate-independent in the exponential sense, though exact intermediate
values depend on per-frame `dt`. Journey camera writes a fixed target
(`0.75` fighting / `1.0` otherwise) at `main.gd:1244-1246`. No called-symbol
rename; existing sim tick order unchanged.

## NOT-DONE / UNVERIFIED / open questions

- **Visual feel A/B** (faster/smoothier wheel, wider start): UNVERIFIED by me — owner/coordinator review.
- **Minimap frustum box drawing** at zoom 0.75: not asserted by t_nav_smoke; the underlying rect/world math passed, but visual check is UNVERIFIED.
- **Donor wheelspeed default** and exact donor numeric start zoom: UNVERIFIED (derived from clamp logic, not a literal).
- **Keyboard zoom translation**: W4-2 currently wires only wheel (`input_controller.gd:399-400`); no key calls to the new API. W4-2 owns this decision.
- **Interim gap during mid-edit**: jobs 1283/1284 failed before the rename fix; final 1286/1287 are the authoritative results.
- **Full selftest**: not run (coordinator gate).
- Open: should `camera.start_zoom` also be added to `config.gd`'s `DEFAULT` table (W2-owned file) so `--dump-config` shows it? Currently it is read directly from the merged settings at `main.gd:153` and works with the built-in fallback 0.75.
