---
id: V7-81
title: "V7-81 — windowed 3D minimap centre click no longer blacks out the main view"
owner: V7-81
scope: "variant3d/scripts/camera3d.gd ONLY + this report. Read-only on main.gd (V7-70 seam), hud.gd, input_controller.gd, world3d*.gd, app/, tests and config. No git operations."
date: 2026-11-24
status: PASS__PARSE_OK__PROBE_11_11__SELFTEST_29_29__NO_VISUAL_CLAIM
verdict: "Camera coordinate convention is now consistent: _target/jump_to_world stay SIM (top-left map origin), _apply_transform() subtracts the map half once to reach the origin-centred world3d mesh, clamp_pos() converts the centred viewport-corner centre back to SIM before clamping, and bind() starts at the map centre. A camera-local memo guard neutralises main.gd's read-only V7-70 seam so startup/journey paths do not double-subtract. Minimap centre click measured at camera x=320.0 -> 0.0 (focus (320,315 -> 0,-4.76) centred); corner click lands at (-297,-300) centred after clamping. Parse clean, probe 11/11, temp probe deleted, variant selftest 29/29. No visual parity claim."
godot_jobs: "206 v781-probe-before (expected FAIL 2/8 — reproduces bug), 207 v781-parse-cam3d (ok), 208 v781-probe-after (ok 8/8), 209 v781-selftest (ok 29/29, pre-guard), 210 v781-parse-final (ok), 211 v781-probe-final (ok 11/11 incl. seam sim), 212 v781-selftest-final (ok 29/29, shipped file)"
---

# V7-81 — minimap-centre click black-screen fix

## 1. Diagnosis (verified before editing)

| Finding | Path:line (pre-edit) | Consequence |
|---|---|---|
| `_target` documented as SIM metres, top-left origin | `camera3d.gd:32-33,101-102` | public/internal frame is SIM |
| `jump_to_world(world_pos)` stores the caller's SIM value verbatim | `camera3d.gd:304-312`; HUD caller `hud.gd:1445-1453`; input caller `input_controller.gd:226-233` | minimap centre passes sim `(320,320)` (320-tile map × `TILE_M=2`) |
| `_apply_transform()` built `base` straight from `_target`, no offset | `camera3d.gd:159-166` | camera focus became world `(320,320)` — the terrain **corner**, outside the centred mesh → black |
| Terrain/entities are origin-centred | `world3d_terrain.gd:307-314` `(x+0.5-w/2)*TILE_M`, `:176-177`, `:409-410`; `world3d.gd:1003-1007` V7-70 comment | centred world spans about `-320..+320` for the 320-tile config |
| `clamp_pos()` read CENTRED view corners but clamped them on `[0, limit]` and wrote the delta into SIM `_target` | `camera3d.gd:270-277` (`screen_to_world()` at `:180-189`), `:318-344` | frame mix compounded the offset |
| `bind()` initialised `_target = Vector2.ZERO` | `camera3d.gd:141` | ZERO is the map **corner** in SIM, not the centre |
| Extra hazard found during verification: V7-70 seam converts `_target` SIM→centred in `main.gd` (read-only here) | `main.gd:1008-1016`, call sites `:605`, `:1068`, `:1650-1651`; handoff in `V770_viewport_capture.md:222` | a naïve "subtract half in `_apply_transform()`" fix would double-subtract on startup/journey paths; handled in step (5) below |

Donor citations are unchanged: `camera.cfg:6-10,32-35,44-45`, `default.cameras:5-18`, `onmousewheel.inc:30-47,296-303`, `oncamera.inc:10-27`, `onmousedown.inc:116-131`. Tabs, no RNG, no invented constants.

## 2. Exact diff — `variant3d/scripts/camera3d.gd`

`--- a/variant3d/scripts/camera3d.gd` / `+++ b/variant3d/scripts/camera3d.gd`

Private memo bookkeeping (pre-edit `:102-104` → shipped `:102-110`):

```diff
 var _target: Vector2 = Vector2.ZERO
 var _last_clamp_target: Vector2 = Vector2.INF
 var _last_clamp_zoom: float = -1.0
+# V7-81: the memo value this script last wrote itself. main.gd's read-only V7-70
+# seam (main.gd:1008-1016) writes _last_clamp_target/_last_clamp_zoom externally
+# AFTER converting _target from SIM to centred metres. Recognising that foreign
+# memo lets _apply_transform() restore SIM instead of subtracting the map half
+# twice — no edit to main.gd is needed (it is out of this ticket's ownership).
+var _own_clamp_target: Vector2 = Vector2.INF
```

`bind()` (pre-edit `:141-143` → shipped `:147-154`):

```diff
 	_zoom_anchor_screen = Vector2.INF
-	_target = Vector2.ZERO
+	# V7-81: _target is SIM metres (top-left map origin). Start at the map CENTRE,
+	# not the corner ZERO — _apply_transform() subtracts _map_half() to reach the
+	# origin-centred world3d mesh (world3d_terrain.gd:312-314). Null-safe: a stub
+	# without MAP_W/MAP_H leaves the half at ZERO.
+	_target = _map_half()
 	_last_clamp_target = Vector2.INF
 	_last_clamp_zoom = -1.0
+	_own_clamp_target = Vector2.INF
 	make_current()
 	_apply_transform()
```

New private helper + `_apply_transform()` (pre-edit `:152-161` → shipped `:163-198`):

```diff
 func _height_m() -> float:
 	var z: float = clampf(zoom, min_zoom, max_zoom)
 	return sqrt(maxf(0.0001, DONOR_HEIGHT_MIN * DONOR_HEIGHT_MAX) / maxf(0.0001, z))
 
+# V7-81 — half the map extent in SIM metres. Null-safe for stubs/test doubles
+# that expose no MAP_W/MAP_H: a missing dimension contributes ZERO. Used to
+# convert between the SIM top-left frame of _target/jump_to_world and the
+# origin-centred world3d frame of screen_to_world()/the terrain mesh.
+func _map_half() -> Vector2:
+	if game == null or not is_instance_valid(game):
+		return Vector2.ZERO
+	var mw = game.get("MAP_W")
+	var mh = game.get("MAP_H")
+	if mw == null or mh == null:
+		return Vector2.ZERO
+	return Vector2(float(mw), float(mh)) * Data.TILE_M * 0.5
+
 
 # Fixed -32 deg tilt (camera.cfg:32-35; onmousewheel.inc:43-47). Yaw 0 = look toward -Z
 # (default.cameras:DirZ=-1); exact donor yaw UNVERIFIED (G31:227).
 func _apply_transform() -> void:
 	var h: float = _height_m()
-	var base := Vector3(_target.x, 0.0, _target.y)
+	# V7-81: _target stays in SIM metres (public contract); the composed 3D
+	# scene is centred on the origin, so subtract the map half here. This makes
+	# a minimap jump to sim (320,320) focus world (0,0), not the terrain corner.
+	var half := _map_half()
+	# V7-70 seam defence: when an external writer freezes the memo to a target
+	# other than ours, it has already converted _target SIM -> centred. Restore
+	# SIM here so the subtraction below happens exactly once, whatever path set
+	# the focus (minimap jump, startup, journey mode).
+	if _target == _last_clamp_target and _target != _own_clamp_target and zoom == _last_clamp_zoom:
+		_target += half
+		_last_clamp_target = _target
+		_own_clamp_target = _target
+	var base := Vector3(_target.x - half.x, 0.0, _target.y - half.y)
```

`jump_to_world()` (shipped `:347-349`) — memo invalidation extended by one line:

```diff
 	_last_clamp_target = Vector2.INF
 	_last_clamp_zoom = -1.0
+	_own_clamp_target = Vector2.INF
 	clamp_pos()
```

`clamp_pos()` (pre-edit `:334-339` → shipped `:372-386`):

```diff
 	var centre: Vector2 = (min_v + max_v) * 0.5
 	var half: Vector2 = (max_v - min_v) * 0.5
+	# V7-81: get_viewport_corners()/screen_to_world() return CENTRED world metres,
+	# while _target and the clamp limit are SIM metres. Convert the observed view
+	# centre back to SIM before clamping; the delta then applies to SIM _target.
+	var centre_sim: Vector2 = centre + _map_half()
 	var limit := Vector2(game.MAP_W, game.MAP_H) * Data.TILE_M
-	var nx: float = limit.x * 0.5 if limit.x <= half.x * 2.0 else clampf(centre.x, half.x, limit.x - half.x)
-	var nz: float = limit.y * 0.5 if limit.y <= half.y * 2.0 else clampf(centre.y, half.y, limit.y - half.y)
-	var delta := Vector2(nx - centre.x, nz - centre.y)
+	var nx: float = limit.x * 0.5 if limit.x <= half.x * 2.0 else clampf(centre_sim.x, half.x, limit.x - half.x)
+	var nz: float = limit.y * 0.5 if limit.y <= half.y * 2.0 else clampf(centre_sim.y, half.y, limit.y - half.y)
+	var delta := Vector2(nx - centre_sim.x, nz - centre_sim.y)
 	if delta != Vector2.ZERO:
 		_target += delta
 		_apply_transform()
 	_last_clamp_target = _target
 	_last_clamp_zoom = zoom
+	_own_clamp_target = _target
```

No public method, signature, default, constant or donor citation changed. `jump_to_world(world_pos: Vector2)` still takes SIM metres; `screen_to_world()` still returns CENTRED world metres; `get_viewport_corners()`/`get_view_rect()` still return CENTRED metres (their doc comments at `:268,280` were already correct for the raycast output and are unchanged). No `world3d.gd`, `hud.gd`, `main.gd`, test or config edit.

## 3. Verification — variant3d runner only

All launches: `python -X utf8 variant3d\tools\godot_runner.py run --id <id> --timeout <n> -- --headless --path variant3d …`
Results under `variant3d/.godot_queue/results/<ticket>_<id>/`.

| Ticket | Job id | Command tail | Result |
|---|---|---|---|
| 206 | `v781-probe-before` | `--script res://tests/_v781_probe.gd` (unfixed file) | **failed 2/8 as expected** — reproduces the bug; stderr 0 B |
| 207 | `v781-parse-cam3d` | `--check-only --script res://scripts/camera3d.gd` | ok, exit 0, 2.57 s, stderr 0 B |
| 208 | `v781-probe-after` | probe, core fix | ok, exit 0, **8/8**, stderr 0 B |
| 209 | `v781-selftest` | `--self-test variant3d/selftest.json` (pre-guard) | ok, 29/29 |
| 210 | `v781-parse-final` | parse of shipped file | ok, exit 0, 5.89 s, stderr 0 B |
| **211** | **`v781-probe-final`** | probe + V7-70 seam simulation | ok, exit 0, 3.08 s, stderr 0 B, **11/11** |
| **212** | **`v781-selftest-final`** | full variant selftest on shipped file | ok, exit 0, 75.98 s, `passed=true`, **29/29**, 0 failed |

Probe: `variant3d/tests/_v781_probe.gd` bound `camera3d.gd` to a 320×320-tile stub game (`MAP_W=MAP_H=320`, `TILE_M=2` → sim limit 640 m, map half 320 m) on a 1280×720 root, deferred one frame via `call_deferred("_run")`, and was **deleted after the runs** (`Test-Path` → `False`). It measured `global_position`, the flat-Y=0 view centre from `get_viewport_corners()`, the view half-extent, `_target`, and the sim round-trip `view_centre + (320,320)`.

### 3.1 Measured camera positions — before vs after

`global_position` = `(x, height, z)`; height is unchanged at `34.05877 m` (donor sphere bounds). View half-extent measured `(22.9225, 19.5747) m`.

| Case | BEFORE (ticket 206) | AFTER (ticket 211) |
|---|---|---|
| `bind()` | `gp=(0.0, 34.05877, 54.50543)`, `_target=(0,0)` (sim corner, focused centre only by accident) | `gp=(0.0, 34.05877, 54.50543)`, `_target=(320,320)` (sim centre, explicitly) |
| minimap **centre** click `jump_to_world(320,320)` | **`gp=(320.0, 34.05877, 374.5054)`**, view centre centred `(320.0, 315.2428)`, sim round-trip `(640.0, 635.2428)` → off-terrain → **black** | **`gp=(0.0, 34.05877, 54.50543)`**, view centre centred `(0.0, -4.757189)`, sim round-trip `(320.0, 315.2428)` ≈ `(320,320)`; `_target` still SIM `(320,320)` |
| **corner** click `jump_to_world(0,0)` after clamp | `gp=(22.92251, 34.05877, 78.83727)`, view centre centred `(22.92251, 19.57466)` | `gp=(-297.0775, 34.05877, -241.1627)`, view centre centred `(-297.0775, -300.4254)` ≈ SW corner `(-320,-320)` within one half-extent; `_target` SIM `(22.92252, 24.33186)` |
| simulated V7-70 seam after jump (`main.gd:1008-1016`) | not applicable (seam used to *supply* the missing conversion) | `gp=(0.0, 34.05877, 54.50543)`, `_target` restored SIM `(320,320)` — no double subtraction |
| simulated startup direct SIM write `(100,200)` → `clamp_pos()` → seam | n/a | view centre centred `(-220.0, -124.7572)`, expected `(-220,-120)` — within the 19.57 m y half-extent |

The constant `-4.757 m` view-centre y offset is perspective ray-to-Y=0 geometry, present before and after (before: `315.2428` for a 320 m focus; after: `-4.757189` for a 0 m focus). It is not a regression.

### 3.2 Probe checks (ticket 211)

`BIND_FOCUS_AT_CENTRE`, `CENTRE_GP_X_NEAR_ZERO`, `CENTRE_GP_NOT_CORNER`, `CENTRE_VIEW_FOCUS_ZERO`, `CENTRE_SIM_ROUNDTRIP`, `TARGET_REMAINS_SIM`, `CORNER_LANDS_NEAR_SW`, `CORNER_GP_NEGATIVE`, `SEAM_NO_DOUBLE_OFFSET`, `SEAM_TARGET_RESTORED_SIM`, `SEAM_STARTUP_FOCUS` — **11/11 PASS**.

Selftest stderr (ticket 212) contains the pre-existing `world3d_entities` donor-morph warning and the usual exit leak warnings; no camera error, no new failure.

## 4. Open questions / residual risk

1. **V7-70 seam guard is signature-based.** `main.gd` is read-only here and still converts `_target` SIM→centred at `:605`, `:1068`, `:1651`. The camera detects that foreign conversion by "memo frozen to a target other than the one we wrote" (`_own_clamp_target`). If a future main.gd change freezes the memo with an already-SIM value, that write would be falsely treated as a seam and add one half. **Recommended follow-up for the main.gd owner:** remove `_center_camera3d_target()` and its three call sites now that camera3d.gd owns the SIM→centred conversion, or expose an explicit `camera.apply_sim_focus()` seam and stop writing private fields. Not done here (file ownership).
2. **Null-safe half assumes numeric `MAP_W`/`MAP_H`.** A stub exposing non-numeric values would reach `float()` and error; no such caller exists in the repo, and the 320×320 stub plus the real `game.gd:35-36` were exercised.
3. **Flat-plane reads unchanged.** `screen_to_world()` remains the Y=0 raycast, so its perspective y skew versus the terrain surface persists (AUDIT3D-05 §6 Q4; E6's surface anchor in `V777_zoom_anchor_height.md` is separate). Not in scope.
4. **No windowed/visual reproduction.** Verification is parse + headless numeric probe + selftest only. The user's "goes black" symptom is explained by the measured off-terrain focus and its correction, but **no screenshot or A/B visual parity claim** is made.
5. **Donor yaw / absolute FOV remain UNVERIFIED** (G31:227,244-245,262-263); this is a port-side frame fix, not a donor-fidelity claim.

## 5. Verdict

The reported bug is a coordinate-frame mismatch, not a rendering fault: the minimap supplies SIM metres, the camera consumed them as if already centred. Frames are now consistent inside `camera3d.gd` and compatible with the read-only V7-70 seam. Parse clean; probe 11/11; full variant selftest 29/29; temp probe deleted. Handoff in open question 1 remains for the `main.gd` owner.
