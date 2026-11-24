---
owner: V7-11
date: 2026-11-24
role: atomic builder (phase 2)
lane: Wave 7 3D variant — perspective camera module
owns: variant3d/scripts/camera3d.gd
output: docs/coord_swarm_2026-11-24/reports/V711_camera3d.md
donor: C:\Games\Cossacks 3 (private use, read-only; Python bytes + latin-1; never executed/copied)
scope: SINGLEPLAYER SKIRMISH ONLY (D-12)
governing_rule: donor-as-source-of-truth; cite path:line or UNVERIFIED; no invented constants; no RNG
status: IMPLEMENTED — parse verified (runner ticket 24, exit 0, clean stderr)
---

# V7-11 — `camera3d.gd` (perspective camera) report

## 1. Scope and ownership

Exactly one new file was created: `variant3d/scripts/camera3d.gd` (376 lines, tabs only,
no `class_name` — loaded dynamically via `load()` as required by
`V73_ATOMIC_CONTRACT.md:26-30`). This report is the only other file written. No other
`variant3d/**`, `app/**`, config, asset or doc file was edited.

Contract implemented from `docs/coord_swarm_2026-11-24/V73_ATOMIC_CONTRACT.md:10`
(`camera3d.gd extends Camera3D`).

## 2. Donor citations (all re-read this session, read-only Python bytes + latin-1)

| Constant / behaviour | Literal verified | Donor path:line | Use in `camera3d.gd` |
|---|---|---|---|
| Main view projection | perspective (no ortho extent key; focal 400, fixed tilt) | `data\cameras\camera.cfg:44-45`, `:32-35`; `default.cameras:5-18`; G31 `:40-63`, claim 1 `:225` | `projection = PROJECTION_PERSPECTIVE` in `bind()` |
| SphereHeight / SphereLength (max dolly/altitude) | `58` | `camera.cfg:6`, `:9` | `DONOR_HEIGHT_MAX = 58.0`; `max_zoom = 58/20` |
| SphereHeightMin / SphereLengthMin (min altitude) | `20` | `camera.cfg:7`, `:10` | `DONOR_HEIGHT_MIN = 20.0`; `min_zoom = 20/58` |
| Fixed tilt | all four slots `-32` | `camera.cfg:32-35`; `onmousewheel.inc:43-47` (`angleZ = -Lerp(-32,-32,...)`) | `Data.CAMERA_PITCH` (`deg_to_rad`) in `_apply_transform()` |
| Wheel zoom clamps **height** to `[minHeight, maxHeight]` | `height := Clamp(height+delta, minHeight, maxHeight)` | `data\gui\common.inc\onmousewheel.inc:30-41` (restrict info read at `:30`, clamp at `:41`) | altitude-based zoom mapping `height = sqrt(H_MIN*H_MAX/zoom)` |
| Wheel zoom keeps the wheel ground point | `SetMainCameraMoveToTargetXZ(newx, newy)` | `onmousewheel.inc:296-303` | `zoom_step(notches, anchor)` + `_zoom_anchor_screen` |
| Focal length | `400` (min = max) | `camera.cfg:44-45` | `DONOR_FOCAL` (documented; FOV itself UNVERIFIED) |
| Focal ±5 per wheel notch | `400 + fov*5` (CTRL screenshot branch only) | `onmousewheel.inc:320-337`, literals `:326,334` | `DONOR_FOCAL_STEP` (documented, NOT used for main-view dolly zoom) |
| Key / mouse scroll speed | `profile.keyscrollspeed*4` / `mousescrollspeed*4` | `data\gui\menu.inc\oncamera.inc:10-11` | `Data.CAMERA_KEY_SPEED/MOUSE_SPEED` → m/s |
| Direction from camera axes | `GetCameraAbsolute{Left,Right,Forward,Backward}Direction`, `SetCameraElasticMoveDirection` | `oncamera.inc:18-27,60-72` | `_process()` arrow-key direction |
| Ground ray API name | `ScreenToWorldRayCast(cx, cy, ...)` | `onmousewheel.inc:315` (commented call, name observable) | `screen_to_world()` ground-plane raycast |
| FOV / sensor | **UNVERIFIED** — no sensor constant in `data/**`; 2.90° and 17.27° are both assumptions | G31 `:227,262-263`; `terrain3d_sandbox.gd:24-36` | `FOV_DEG_ASSUMED = 17.27` labelled PORT ASSUMPTION; A/B vs 2.90° pending |
| Yaw | **UNVERIFIED** — `DirZ=-1` observed; absolute yaw not provable | `default.cameras:5-18`; G31 `:227`, V71 `:244-245` | yaw 0 (look toward −Z), documented assumption |
| Clipping planes | **UNVERIFIED** — no projection/clip keys in `data/**` | G31 `:40-63` | `NEAR_M/FAR_M` labelled port frustum safety, not donor numbers |
| Edge/dwell tunables | port parity, not donor literals | `variant3d/scripts/camera.gd:11-14,39-51`; `data.gd:164-167` | edge scroll depth/dwell multipliers |

## 3. Exact API implemented

| Contract member | Signature in file | Implementation |
|---|---|---|
| `bind` | `func bind(game: Object, view_scale: float = 1.0) -> void` | stores game + view_scale, sets perspective/FOV/clip, reads port config null-safe, derives zoom bounds from donor heights, `make_current()` |
| `view_scale` | `var view_scale: float = 1.0` | metres→canvas-px scalar kept for HUD/minimap parity; not reinterpreted |
| `world_to_px` | `func world_to_px(world: Vector2) -> Vector2` | `unproject_position(Vector3(x,0,z))` → viewport screen px |
| `screen_to_world` | `func screen_to_world(screen: Vector2) -> Vector2` | `project_ray_origin/normal` ∩ ground plane Y=0 → Vector2(x,z) metres; `Vector2.INF` above horizon |
| `clamp_pos` | `func clamp_pos() -> void` | bounding rect of 4 ground corners clamped to map in metres; centres axis when view wider than map (2D `camera.gd:123-137` semantics); memoized |
| `get_view_rect` | `func get_view_rect() -> Rect2` | AABB of visible ground quad in **metres** (not canvas px) |
| `get_viewport_corners` | `func get_viewport_corners() -> Array` | 4 ground corners TL,TR,BR,BL in screen order (metres, top-left map origin) for the minimap box adapter |
| `zoom_step` | `func zoom_step(notches: float, anchor: Vector2 = Vector2.INF) -> void` | `zoom_target *= zoom_step_factor^(notches*zoom_notch_gain)`, anchor held |
| `set_zoom_target` | `func set_zoom_target(target: float, immediate: bool = false, anchor: Vector2 = Vector2.INF) -> void` | first two params are the exact contract; the OPTIONAL third is additive (2-arg calls unchanged) and carries zoom-at-cursor; `immediate` snaps |

Preserved 2D semantics: `min_zoom=20/58`, `max_zoom=58/20`, `zoom_step_factor=1.15`,
`zoom_notch_gain=2`, `zoom_smooth_rate=18`, frame-rate-independent exponential smoothing,
zoom-at-cursor anchor, arrow-key + edge-scroll (depth ramp/dwell), middle-drag, 50 ms hitch
guard, `process_priority=-100` (pan before `world.sync()`/HUD box).
Zoom→metres maps the 2D bounds exactly onto donor altitude bounds:
`height = sqrt(DONOR_HEIGHT_MIN * DONOR_HEIGHT_MAX / zoom)` — zoom `20/58` → 58 m,
zoom `58/20` → 20 m, zoom 1 → 34.06 m. Camera offset `y = height`, `z = height/tan(32°)`
so the view axis sits at the donor −32° tilt. No RNG. All tabs.

## 4. Runner jobs and result

`t_camera3d.gd` does **not** exist (`variant3d/**/t_camera3d.gd` glob returned no files), so
per the task instruction the fallback parse check was used. Both jobs went through the
variant runner's own spool (`variant3d/.godot_queue`), Godot 4.7.2 headless.

| Job | Command | Ticket | Result |
|---|---|---:|---|
| `v711-camera-parse` | `python variant3d\tools\godot_runner.py run --id v711-camera-parse --timeout 120 -- --headless --path variant3d --check-only --script res://scripts/camera3d.gd` | 14 | **FAILED** — two genuine parse errors in my file (`deg2rad()` not found → use `deg_to_rad()` at :149; `unproject_position()` returns `Vector2`, not `Vector3`, at :160). Both fixed. |
| `v711-camera-parse2` | same with `--id v711-camera-parse2` | 24 | **PASSED** — `exit=0`, `status=ok`, run 4.39 s (waited 233 s in queue), clean stderr, stdout only the Godot 4.7.2 banner. Script parses. |

Parse-only verification is honest scope: no `t_camera3d.gd` exists yet, so no runtime/API assertions were executed.

## 5. Open questions

1. **FOV/sensor**: 17.27° is a port assumption (M0.6 216 mm display sensor); 2.90° (36 mm) is the A/B alternative. Donor absolute sensor is UNVERIFIED without running/RE. A visual A/B must sign off before claiming donor parity (G31 `:262-263`).
2. **Yaw**: 0 used; donor `DirZ=-1` observed but absolute yaw UNVERIFIED. Minimap box rotation is also UNVERIFIED (V71 `:160`).
3. **Coordinate origin**: this camera uses top-left map origin `[0..MAP_W*TILE_M]`, matching the 2D canvas/minimap. `world3d.gd:215-217` currently builds its mesh centred on the world origin; the integration owner must reconcile the two frames (documented, not changed here).
4. **`world_to_px` units**: returns viewport screen px (natural 3D meaning). The 2D contract returns canvas px; V71 `:262` flags this ambiguity. The HUD adapter should convert px→minimap coordinates.
5. **`view_scale`**: default 1.0 per contract signature; callers should pass `Data.PIXELS_PER_METER` (16) for 2D-parity pan conversion. Pan speed itself is derived in m/s from `Data.CAMERA_*` so it is independent of this argument.
6. **Terrain-aware picking**: `screen_to_world` intersects the Y=0 plane; exact heightfield intersection and entity/resource hit-tests belong to `picking3d.gd` (contract `:11`).
7. **Wheel notch metres**: donor notch delta depends on `gProfile.wheelspeed` (`onmousewheel.inc:296`); profile value was not read, so the port keeps the 2D `1.15^notch` step. Exact donor metres/notch UNVERIFIED.
8. **`t_camera3d.gd`** is not present yet (owned by V7-7). Once it lands, a targeted `--script res://tests/t_camera3d.gd` run should replace the parse-only check.

---

**End of report. No donor file was executed or copied; no other repo file was edited.**
