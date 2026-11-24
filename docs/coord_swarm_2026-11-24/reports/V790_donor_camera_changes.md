---
id: V7-90
scope: "Apply donor-GROUNDED camera changes to variant3d/scripts/camera3d.gd from DEEPDEC-01 §6 items 1/2/3/5/6; no FOV, no minimap ArcTan offset"
owner: V7-90
date: 2026-11-24
status: EDITS_LANDED__PARSE_PROBE_SELFTEST_GREEN__UITEST_UNVERIFIED_QUEUE_CONTENTION
owns:
  - "variant3d/scripts/camera3d.gd"
  - "docs/coord_swarm_2026-11-24/reports/V790_donor_camera_changes.md"
sources:
  - "DEEPDEC-01_camera.md §3.1, §3.3, §6 items 1/2/3/5/6/9/10, §7"
  - "DEEPDEC-08_ui_minimap.md §2, §5, §6, §7"
rules_kept:
  - "Exactly one source file + one report edited; temp probe created then DELETED"
  - "No main.gd / hud.gd / input_controller.gd / app/ / config / tests edits"
  - "No git operations; no donor binary/text touched; no visual parity claim"
  - "All Godot runs via variant3d/tools/godot_runner.py; no direct godot invocation"
  - "Further runner launches PAUSED on coordinator instruction (queue contention)"
---

# V7-90 — donor-grounded camera changes (height/wheel/pan)

## 0. Summary

Applied four donor-grounded changes to `variant3d/scripts/camera3d.gd` only:

1. **Explicit HEIGHT state** (metres, clamped 20..58 from `SphereLengthMin`/`SphereLength`) replaces the zoom-derived height; the legacy 2D `zoom`/`zoom_target` scalar is kept as a derived compatibility view, so `zoom_step()`/`set_zoom_target()` callers are unchanged.
2. **Additive donor wheel delta** `-(Δ/60)*(wheelspeed*0.5+0.25)*2` (default `wheelspeed=0.5` → exactly 2 m per Δ=120 notch) replaces the multiplicative `1.15^(notches*2)` step. Clamped to the donor height pair.
3. **Zoom-independent pan**: `/zoom` removed from key pan; donor `Δx/60`, `Δy/45` middle-drag divisors with `(0.5+middlemousescrollspeed)` factor; key/mouse speed now literally `profile*4` (default 2.0 m/s).
4. **Old/new-height zoom anchor preserved** (V7-77 guarded sampler kept) and **tilt stays -32°**. The donor minimap `ArcTan()` offset/heading is **documented as OPEN with the donor formula cited but NOT implemented**; FOV is **unchanged** (BLOCKED).

No visual parity claim.

## 1. Evidence → change map (DEEPDEC-01 ids, exact path:line)

| # | Change | Donor evidence (id / path:line) | DEEPDEC-01 §6 item |
|---|---|---|---|
| 1 | `height`/`height_target` state, clamp 20..58 | E8 `ev_f24c1aa180d3edb2fc77234ea714c83d494917a6173b16c0f9c877a5a80c25e7` — `camera.cfg:9-10` `SphereLength=58`, `SphereLengthMin=20`; E10 `ev_0212f2f7f73ba49ed7931603b29f0edf1926645940314bf15826f7e1dfbda16e` — `onmousewheel.inc:30-41` `height := Clamp(height+delta, minHeight, maxHeight)` | 1 |
| 2 | Additive wheel delta, 2 m/notch | E10 `ev_0212f2f7…` — `onmousewheel.inc:296` `wheelDelta := -(GetGUIEventMouseWheelDelta/60)*(gProfile.wheelspeed*0.5+0.25)*2`; E16 `ev_992ea3e21ae383e5aa2622fdb78af11fe3e60911ffd5bbbb70177efc1e5e2886` — `profile.script:17-20,513-516` all speeds 0.5, clamped [0,1] | 2 |
| 3 | Anchor at old/new height; tilt -32 | E10 `ev_0212f2f7…` — `onmousewheel.inc:56` `dstZ := tz + ArcTan(-angleZ)*oldHeight`, `:60` `offZ := ArcTan(angleZ)*height`, `:43-47` angle guards; E8 `camera.cfg:32-35` all four angles -32 | 3, 4 |
| 4 | Pan zoom-independent, `profile*4` | E11 `ev_da1e62c846f5346dc9a1ae9bb8ba330aa50b7ecd2ecf0b748e19a559bce3f250` — `oncamera.inc:10-11` `keySpeed=keyscrollspeed*4`, `mouseSpeed=mousescrollspeed*4`, `:60-72` absolute directions, additive | 5 |
| 5 | Middle-drag 60/45 + `(0.5+middlemousescrollspeed)` | E15 `ev_0cc3781c31ff337dd7d837505094a985d5595f49071d033a9a7d5d845acbfc27` — `dombtncameracontrol.inc:20-35`, `:23-24` divisors 60/45, `:23-50` additive drag with X clamp | 6 |
| 6 | ArcTan minimap offset/heading **LEFT OPEN** | DEEPDEC-01 §7/#10; DEEPDEC-08 §2 E3 `control.script:574-613`, §5 item 10, §7; E14 `onmousedown.inc:116-131` (path:line only); E26 `ev_b3ce43e7600490e375a257b90a074099cf259f95793a400266562f7b9d90249e`, `ev_cb8bd0f4120e06270f6849668956a8e0d35f5d0d8254c12c4d9c6561119e5f78` (offset helper absent) | 8, 10 |
| 7 | FOV **UNCHANGED** (BLOCKED) | DEEPDEC-01 §6 item 9, §7: E9 `default.cameras:17` focal 400, E25 `ev_eeb139c2b9afd4293fd8e9be2ccb733d994b191e4ba1591d4cf3af6209958209` finalizer; 2.90°/17.27° are A/B assumptions, no readable sensor/projection | 9 |

## 2. Exact diff (`variant3d/scripts/camera3d.gd`)

Line numbers below are from the ORIGINAL file read at task start. All edits are in this one file.

### 2.1 Header citations (after original `:27`)

```diff
@@ -27,3 +27,11 @@
 #       left/right/forward/backward directions; SetCameraElasticMoveDirection
+#   C:\Games\Cossacks 3\data\gui\common.inc\onmousewheel.inc:296  wheelDelta =
+#       -(GetGUIEventMouseWheelDelta/60)*(wheelspeed*0.5+0.25)*2 (DEEPDEC-01 E10/E16)
+#   C:\Games\Cossacks 3\data\gui\menu.inc\dombtncameracontrol.inc:23-24  middle drag
+#       deltaX=(prevX-curX)/60*(0.5+middlemousescrollspeed), deltaY=.../45*... (E15)
+#   C:\Games\Cossacks 3\data\scripts\lib\profile.script:17-20,513-516  four profile
+#       speeds default 0.5, clamped [0,1] (E16)
+#   V7-90 donor-grounded camera pass = DEEPDEC-01 §6 items 1/2/3/5/6. FOV and the
+#       ArcTan minimap offset/heading remain OPEN (DEEPDEC-01 #9/#10, §7; DEEPDEC-08 §2).
 #   Evidence: G31_donor_3d_truth.md:42-63, claim 1 :225; V71_mechanics_inventory.md:158-159.
```

### 2.2 Explicit height + profile state (after original `:73`)

```diff
@@ -73,2 +73,17 @@
 var _zoom_anchor_screen: Vector2 = Vector2.INF
+
+# DEEPDEC-01 §6 item 1 (E10 `onmousewheel.inc:39-41`, E8 `camera.cfg:9-10`): donor
+# stores camera HEIGHT directly and clamps it to SphereLengthMin..SphereLength
+# (20..58 m). `height`/`height_target` are that explicit metre state; `zoom`/
+# `zoom_target` survive only as a derived compatibility view for legacy callers.
+var height: float = sqrt(DONOR_HEIGHT_MIN * DONOR_HEIGHT_MAX)
+var height_target: float = sqrt(DONOR_HEIGHT_MIN * DONOR_HEIGHT_MAX)
+# DEEPDEC-01 §6 item 2 / E16 (`profile.script:17-20,513-516`): the four donor
+# profile speeds all default to 0.5 and are clamped to [0,1]. Read from the
+# merged config with those donor names; absent keys keep the donor default.
+var wheel_speed: float = 0.5
+var middle_mouse_scroll_speed: float = 0.5
+var key_scroll_speed_profile: float = 0.5
+var mouse_scroll_speed_profile: float = 0.5
```

### 2.3 `bind()` — read profile speeds, seed height (original `:139-146`)

```diff
@@ -139,7 +139,17 @@
 		edge_dwell_max = cfg.num("camera.edge_dwell_max", 3.0)
 		edge_total_max = cfg.num("camera.edge_total_max", 6.0)
+		# DEEPDEC-01 §6 item 2 / E16 — donor profile names, default 0.5, clamp [0,1].
+		wheel_speed = clampf(cfg.num("camera.wheelspeed", 0.5), 0.0, 1.0)
+		middle_mouse_scroll_speed = clampf(cfg.num("camera.middlemousescrollspeed", 0.5), 0.0, 1.0)
+		key_scroll_speed_profile = clampf(cfg.num("camera.keyscrollspeed", 0.5), 0.0, 1.0)
+		mouse_scroll_speed_profile = clampf(cfg.num("camera.mousescrollspeed", 0.5), 0.0, 1.0)
 	# Donor sphere bounds -> 2D zoom interval (camera.gd:81-84).
 	min_zoom = maxf(1.0, Data.CAMERA_MIN_HEIGHT) / maxf(1.0, Data.CAMERA_MAX_HEIGHT)
 	max_zoom = maxf(1.0, Data.CAMERA_MAX_HEIGHT) / maxf(1.0, Data.CAMERA_MIN_HEIGHT)
 	zoom_target = clampf(1.0, min_zoom, max_zoom)
 	zoom = zoom_target
+	# DEEPDEC-01 §6 item 1 — seed the explicit height state from the 2D start zoom.
+	height_target = _zoom_to_height(zoom_target)
+	height = height_target
 	_zoom_anchor_screen = Vector2.INF
```

`config.json` has no `camera.wheelspeed` / `.middlemousescrollspeed` / `.keyscrollspeed` / `.mousescrollspeed` keys, so the donor 0.5 defaults apply; `C3Config.num()` returns the fallback for absent keys (`config.gd:349-351`). No config file was edited.

### 2.4 `_height_m()` + inverses (original `:159-165`)

```diff
-# Donor wheel zoom clamps HEIGHT (camera.cfg:6-7 via onmousewheel.inc:30-41), not canvas
-# scale. Map the 2D zoom scalar into those metres so the 2D zoom bounds land exactly on the
-# donor bounds: zoom=20/58 -> 58 m, zoom=58/20 -> 20 m, zoom=1 -> sqrt(20*58) m.
-# height = sqrt(H_MIN * H_MAX / zoom) — derived solely from camera.cfg:6-7.
+# DEEPDEC-01 §6 item 1 — the camera now carries an explicit HEIGHT state (metres).
+# _height_m() returns that state; the 2D zoom scalar is only a derived compatibility
+# view. The two inverses below keep legacy zoom_step/set_zoom_target callers in sync.
+# Donor bounds: zoom=20/58 -> 58 m, zoom=58/20 -> 20 m, zoom=1 -> sqrt(20*58) m
+# (camera.cfg:9-10; E8/E10).
 func _height_m() -> float:
-	var z: float = clampf(zoom, min_zoom, max_zoom)
-	return sqrt(maxf(0.0001, DONOR_HEIGHT_MIN * DONOR_HEIGHT_MAX) / maxf(0.0001, z))
+	return height
+
+
+func _zoom_to_height(z: float) -> float:
+	var zc: float = clampf(z, min_zoom, max_zoom)
+	return sqrt(maxf(0.0001, DONOR_HEIGHT_MIN * DONOR_HEIGHT_MAX) / maxf(0.0001, zc))
+
+
+func _height_to_zoom(h: float) -> float:
+	return clampf((DONOR_HEIGHT_MIN * DONOR_HEIGHT_MAX) / maxf(0.0001, h * h), min_zoom, max_zoom)
```

### 2.5 `jump_to_world()` — OPEN ArcTan documentation only (before original `:341`)

```diff
 # back by clamp_pos() through the memo at :232-233 (the old 3D P0 failure).
+#
+# OPEN — DONOR MINIMAP OFFSET/HEADING NOT IMPLEMENTED (DEEPDEC-01 §6 item 10 /
+# DEEPDEC-08 §2, E14/E26). Donor additionally keeps the camera's pre-click offset:
+#   angleZ := -Lerp(minHeightMaxAngle, maxHeightMaxAngle,
+#                   Clamp((height-minHeight)/(maxHeight-minHeight),0,1));  // = +32
+#   dx := cx-tx; dz := 0.1; VectorRotateX(dx,dy,dz,angleZ);
+#   offZ := ArcTan(angleZ)*height; angleX := VectorAngle(0,0,1,dx,0,dz);
+#   if dx < 0 then angleX := -angleX; VectorRotateY(offX,tmp,offZ,angleX);
+#   newX := dstX+offX+dx; newZ := dstZ+offZ+dz;
+# (control.script:595-612; onmousewheel.inc:56-67). ArcTan() units (deg vs rad) and
+# its VM body are UNVERIFIED (DEEPDEC-01 #10, §7): no donor text defines it, and
+# `_control_GetMoveCameraToPositionOffset` is absent from the binary. Therefore NO
+# offset/heading is applied — V7-66's contract stays "centre the clicked sim point".
 func jump_to_world(world_pos: Vector2) -> void:
```
Function body UNCHANGED (V7-66 preserved).

### 2.6 Middle-drag (original `:398-405`)

```diff
-	# Middle-button drag: pointer delta px -> metres (camera.gd:152-160 parity).
+	# Middle-button drag. DEEPDEC-01 §6 item 6 / E15 (dombtncameracontrol.inc:23-24):
+	# deltaX=(prevX-curX)/60*(0.5+middlemousescrollspeed),
+	# deltaY=(prevY-curY)/45*(0.5+middlemousescrollspeed). Additive, zoom-INDEPENDENT,
+	# no px/m factor; default profile 0.5 -> factor 1.0. clamp_pos() supplies the clamp.
 	var middling: bool = Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE)
 	if middling:
 		if _middle_drag_last != Vector2.INF:
 			var md: Vector2 = m - _middle_drag_last
 			if md != Vector2.ZERO:
-				_target -= md / (zoom * maxf(0.0001, view_scale))
+				var drag_factor: float = 0.5 + clampf(middle_mouse_scroll_speed, 0.0, 1.0)
+				_target -= Vector2(md.x / 60.0, md.y / 45.0) * drag_factor
 		_middle_drag_last = m
```

### 2.7 Key pan (original `:473-478`)

```diff
 	if dir != Vector2.ZERO:
-		# Port profile speeds -> m/s: Data px/s / PIXELS_PER_METER (data.gd:113,166-167).
-		var key_m: float = Data.CAMERA_KEY_SPEED / maxf(1.0, Data.PIXELS_PER_METER)
-		var mouse_m: float = Data.CAMERA_MOUSE_SPEED / maxf(1.0, Data.PIXELS_PER_METER)
+		# DEEPDEC-01 §6 item 5 / E11 (oncamera.inc:10-11): keySpeed=keyscrollspeed*4,
+		# mouseSpeed=mousescrollspeed*4 (defaults 0.5 -> 2.0), ADDITIVE and
+		# zoom-INDEPENDENT. The old `/ zoom` made pan slow down when zoomed out;
+		# donor has no zoom factor, so it is removed. Edge depth/dwell (port
+		# extension) still scales the mouse component only.
+		var key_m: float = clampf(key_scroll_speed_profile, 0.0, 1.0) * 4.0
+		var mouse_m: float = clampf(mouse_scroll_speed_profile, 0.0, 1.0) * 4.0
 		var speed: float = key_m if (k_left or k_right or k_up or k_down) else mouse_m * mouse_mult
-		_target += dir.normalized() * speed * dt / zoom
+		_target += dir.normalized() * speed * dt
 		_apply_transform()
```

### 2.8 `zoom_step()` / `set_zoom_target()` (original `:482-499`)

```diff
-# W4-1 public zoom API (camera.gd:246-262). notches > 0 = zoom in. anchor is the screen
-# point that stays over the same world point (wheel event position); same semantics as 2D.
+# DEEPDEC-01 §6 item 2 / E10 (`onmousewheel.inc:296`): donor wheel is an ADDITIVE
+# height delta, not a multiplicative zoom:
+#   wheelDelta = -(GetGUIEventMouseWheelDelta/60)*(wheelspeed*0.5+0.25)*2
+# with default wheelspeed=0.5 -> -(Δ/60)*1 -> 2 m per standard Δ=120 notch.
+# input_controller.gd:443 maps one standard notch to `notches = ±1`, so the port
+# substitutes Δ = notches*120. Sign convention kept (notches>0 = zoom in = height
+# down), so legacy callers still see zoom_target increase on positive notches.
+# Clamp is the donor SphereLengthMin..SphereLength pair (20..58 m; E8/E10).
 func zoom_step(notches: float, anchor: Vector2 = Vector2.INF) -> void:
 	if notches == 0.0:
 		return
-	set_zoom_target(zoom_target * pow(zoom_step_factor, notches * zoom_notch_gain), false, anchor)
+	var wheel_event_delta: float = notches * 120.0
+	var delta_h: float = -(wheel_event_delta / 60.0) * (wheel_speed * 0.5 + 0.25) * 2.0
+	height_target = clampf(height_target + delta_h, DONOR_HEIGHT_MIN, DONOR_HEIGHT_MAX)
+	set_zoom_target(_height_to_zoom(height_target), false, anchor)
@@
-# Absolute clamped zoom target. The first two parameters are the exact contract API; the
-# OPTIONAL third argument is additive (2-arg calls are unchanged) and carries the zoom-at-
-# cursor anchor set by zoom_step. immediate=true snaps (startup/reset), like camera.gd:257-262.
+# Absolute clamped zoom target (legacy 2D scalar). The first two parameters are the
+# exact contract API; the OPTIONAL third argument is additive (2-arg calls unchanged)
+# and carries the zoom-at-cursor anchor set by zoom_step. immediate=true snaps
+# (startup/reset), like camera.gd:257-262. The explicit height state is kept in
+# lockstep (DEEPDEC-01 §6 item 1).
 func set_zoom_target(target: float, immediate: bool = false, anchor: Vector2 = Vector2.INF) -> void:
 	zoom_target = clampf(target, min_zoom, max_zoom)
+	height_target = _zoom_to_height(zoom_target)
 	_zoom_anchor_screen = anchor
 	if immediate:
 		zoom = zoom_target
+		height = height_target
 		_zoom_anchor_screen = Vector2.INF
 		_apply_transform()
```

### 2.9 `_smooth_zoom()` — interpolate height, keep old/new anchor (original `:502-538`)

```diff
-# Frame-rate-independent exponential approach (camera.gd:267-284) expressed in metres:
-# hold the world point under the zoom anchor fixed across the perspective dolly.
+# Frame-rate-independent exponential approach (camera.gd:267-284), now interpolated
+# in the explicit HEIGHT state (DEEPDEC-01 §6 item 1). Hold the world point under the
+# zoom anchor fixed across the perspective dolly. The old/new-height distinction is
+# preserved: anchor_world/anchor_h are sampled at the OLD height (before the dolly),
+# then the ray is re-hit at that height after _apply_transform() moved to the NEW
+# height — the port equivalent of donor's oldHeight target shift / height camera
+# offset (onmousewheel.inc:56,60; DEEPDEC-01 §6 item 3).
 func _smooth_zoom(dt: float) -> void:
 	if absf(zoom_target - zoom) < 0.0005:
-		if zoom != zoom_target:
+		if height != height_target or zoom != zoom_target:
+			height = height_target
 			zoom = zoom_target
 			_apply_transform()
 		_zoom_anchor_screen = Vector2.INF
 		return
@@
-	var old_z: float = zoom
+	var old_h: float = height
 	var t: float = 1.0 - exp(-zoom_smooth_rate * dt)
-	var new_z: float = old_z + (zoom_target - old_z) * t
+	var new_h: float = old_h + (height_target - old_h) * t
+	var new_z: float = _height_to_zoom(new_h)
 	if absf(zoom_target - new_z) < 0.0005:
+		new_h = height_target
 		new_z = zoom_target
+	height = new_h
 	zoom = new_z
 	_apply_transform()
@@
-	if new_z == zoom_target:
+	if height == height_target:
 		_zoom_anchor_screen = Vector2.INF
```

`_screen_to_surface()`, `_sample_height()`, `_screen_to_plane()` and their `is_finite`/fallback guards are **byte-unchanged** (V7-77).

## 3. Verification — job ids and measured numbers

All launches via `python variant3d\tools\godot_runner.py run …`, never direct `godot`. Godot 4.7.2.stable.

| Ticket | Job id | Command | Result |
|---|---|---|---|
| **229** | `v790-parse` | `--headless --path variant3d --check-only --script res://scripts/camera3d.gd` | **ok**, exit 0, run 6.05 s — clean parse |
| 231 | `v790-probe` | temp `res://tests/_v790_camera_probe.gd` | failed 6/8 — probe-harness defects only (reused one `InputEventKey` → Godot warning `input.cpp:1540`; jump target 2560 m was outside the 640 m map, so `clamp_pos()` correctly clamped it). No camera defect found. |
| 236 | `v790-probe2` | same probe, fresh key events + diagnostics | failed 6/8 — same wrong jump target; magnitude tolerance 1e-6 too tight (0.100006 vs 0.1). |
| **238** | `v790-probe3` | corrected temp probe | **ok, 8/8 PASS**, run 3.58 s. Probe DELETED afterwards (`Test-Path` = False). |
| **241** | `v790-selftest` | `--headless --path variant3d -- --self-test variant3d/selftest.json` | **ok**, exit 0, run 55.04 s; `variant3d/selftest.json` `passed=true`, **29/29**, 0 failures (fresh mtime 15:39:25) |
| 240 | `v790-uitest` | `--headless --path variant3d -- --ui-test variant3d/uitest.json` | **failed**, exit 1, run 16.65 s; stdout only the Godot banner, no `ui-test report` line, stderr empty. `variant3d/uitest.json` still reads `passed=true`, **17/17**, but its mtime is 14:29:26 (stale, pre-dating this run) — **NOT fresh evidence**. Consistent with the coordinator's queue-contention report. Not re-run per pause instruction. |

`res://tests/t_camera3d.gd` was **not run** — runner launches are paused.

### Probe measurements (ticket 238, all PASS)

| Check | Measured |
|---|---|
| wheel delta | `height_target 34.058773 → 32.058773`, **Δ = 2.000000 m** for one +1 notch |
| height follows wheel | `height 34.058773 → 32.058773`, **Δ = 2.000000 m** after smoothing |
| pan zoom-independent | near (`z=58/20`) `(0.100006, 0.0)` m vs far (`z=20/58`) `(0.100006, 0.0)` m for the same `dt=0.05` key press — **identical** |
| pan magnitude | 0.100006 m / 0.05 s ≈ **2.0 m/s** = `profile 0.5 × 4` |
| minimap-centre jump | jump to sim `(320, 320)` (= `MAP_W*TILE_M/2`, TILE_M=2) → `global_position = (0.0, 34.05877, 54.50543)`, back = `h/tan(32°)` = 54.505 → **world centre**, not a corner |
| tilt | forward `(0.0, -0.529919, -0.848048)` → **-32°** unchanged |
| FOV | `17.270000` unchanged |

### Before/after (before values are analytic from the pre-change source, not measured)

| Quantity | Before | After (measured where available) |
|---|---|---|
| height | derived `sqrt(H_MIN*H_MAX/zoom)` each frame | explicit `height` state; **2.000000 m** per notch |
| one wheel notch at `zoom=1` | `zoom_target *= 1.15² = 1.3225` → height 34.064 → 29.617 m, **−4.447 m** (zoom-dependent) | **−2.000 m**, constant at all zoom levels |
| key pan speed at `zoom=1` / `2.9` / `0.345` | 6.0 / 2.07 / 17.4 m/s (`96/16/zoom`) | **2.0 / 2.0 / 2.0 m/s** (0.100006 m per 0.05 s at both extremes) |
| middle drag `md=(60,45)px` at `zoom=1` | `md/(zoom*view_scale)` → (60,45) m at `view_scale=1`, or (3.75, 2.8125) m at `view_scale=16` | `(60/60, 45/45)*1.0 = (1, 1)` m (donor divisors, default factor 1.0) |
| minimap jump to map centre | centred at world (0,0) (V7-81) | centred at world (0,0), measured — unchanged |

## 4. Preserved-fix checks

- **V7-81 coordinate fix**: `_apply_transform()` map-centre subtraction and the `_own_clamp_target` seam guard are unchanged (`camera3d.gd:225-237`); `clamp_pos()` centred→SIM conversion and `_own_clamp_target` memo are unchanged (`:405-439`). Probe check `minimap_centre_jump_world_centre` PASS: jump to sim centre → camera x=0.0, back=54.505 m, i.e. the minimap black-screen regression did not recur.
- **V7-77 guarded terrain sampler**: `_resolve_height_sampler`, `_sample_height` (returns 0.0 with no sampler / non-finite input), `_screen_to_surface`, `_screen_to_plane` unchanged; `_smooth_zoom()` still calls `_screen_to_surface(anchor)`, freezes `anchor_h`, re-hits `_screen_to_plane(anchor, anchor_h)` after the dolly, and falls back to flat `screen_to_world()` if the sampled plane is missed. No new height constant invented.
- **V7-66 public contract**: `jump_to_world(world_pos: Vector2)` still one argument, sim metres, no `view_scale`; only comment lines were added above it.
- **Tilt / FOV**: `Data.CAMERA_PITCH = -32` untouched; measured forward y=-0.529919 → -32°. `FOV_DEG_ASSUMED = 17.27`, `projection`, `near`, `far` untouched; measured fov=17.270000.
- **Legacy zoom API**: `zoom_step(notches, anchor)` and `set_zoom_target(target, immediate, anchor)` signatures unchanged; `set_zoom_target` 2-arg calls from `main.gd:600` / `:1060` and dynamic `zoom_step` from `input_controller.gd:451` still valid. Positive notches still increase `zoom_target` (so `t_camera3d.gd:218-232` monotonicity assertion is preserved analytically: base 1.622414 → 1.7508 → 1.8866 → 2.058 after three +0.5 notches).

## 5. Open questions (NOT implemented)

1. **`ArcTan()` units and minimap offset/heading — UNVERIFIED (DEEPDEC-01 #10, §7; DEEPDEC-08 §2/#5/§7)**. Donor formula is quoted verbatim in `camera3d.gd:381-392`; no numeric offset applied. `ArcTan` is defined in no donor script and `_control_GetMoveCameraToPositionOffset` is absent from the binary (E26), so degrees-vs-radians cannot be settled statically. Needs runtime A/B or recovery of the packed script body. The port therefore still centres the clicked sim point (a donor-grounded framing difference, not a proven bug).
2. **FOV / projection / sensor — BLOCKED (DEEPDEC-01 §6 item 9, §7)**. `2.90°` and `17.27°` are both A/B assumptions; donor `FocalLength=400` is a config value, not a FOV derivation. No change made.
3. **Wheel delta sign convention** of `GetGUIEventMouseWheelDelta` was not read (DEEPDEC-01 §3.1 "sign convention not read"). Port convention `notches>0 = zoom in = height down` was kept to preserve legacy callers; the donor sign itself remains unverified.
4. **Elastic per-frame update loop / donor `MoveVelocity`/`StepTime*` values** (DEEPDEC-01 §6 item 10, §7) were not implemented — out of this ticket's scope.
5. **Variant uitest 17/17 not freshly verified** — ticket 240 failed under queue contention and left a stale report. Re-run only when the coordinator declares the queue free.

No donor parity or visual-parity claim is made. No donor binary, text, source outside the two owned files, config, tests or git state was modified by me. The temp probe file was created for verification and deleted.
