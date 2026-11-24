---
id: V7-77
title: "V7-77 — E6 terrain-height zoom-at-cursor anchor in camera3d.gd"
owner: V7-77
scope: "variant3d/scripts/camera3d.gd ONLY + this report. Read-only on main.gd (V7-70 active), input_controller.gd, world3d.gd, world3d_terrain.gd, app/, tests, config. No git operations."
date: 2026-11-24
status: CODE_FIXED__PARSE_OK__PROBE_12_12__NO_MEASURABLE_DRIFT_REDUCTION__OPEN_QUESTION
verdict: "The 3D zoom anchor now resolves the terrain SURFACE point at the cursor through an existing sampler (world3d.gd:584 height_at_world / game.gd:1893 height_at with a map-centre offset), guarded by has_method, with a flat Y=0 fallback when nothing is reachable. 2D call signatures/defaults and public APIs unchanged; jump_to_world and set_zoom_target two-arg semantics measured intact. Parse clean; 12/12 probe checks PASS; temp probe deleted. IMPORTANT honest result: on a planar slope the OLD flat anchor already preserves the whole view ray, so measured drift before 0.0001 px and after 0.0024 px — no measurable improvement; E6's premise is questioned below. No visual parity claim."
godot_jobs: "165 v777-parse-cam3d (ok), 167 v777-zoom-anchor-probe (timed out — first probe had an unhandled String() cast), 169 v777-parse-cam3d-r2 (ok), 170 v777-zoom-anchor-probe-r2 (failed — probe asserted a behaviour change that is geometrically false), 172 v777-parse-cam3d-final (ok), 174 v777-zoom-anchor-probe-final (ok, 12/12)"
---

# V7-77 — E6 zoom anchor at terrain height

## 1. Task, boundaries, source read first

Read `docs/coord_swarm_2026-11-24/reports/V775_pick_caller.md` §5 (E6 open handoff)
before editing. Only `variant3d/scripts/camera3d.gd` was modified; this report is
the second and last owned path. `main.gd`, `input_controller.gd`, `world3d.gd`,
`world3d_terrain.gd`, `app/`, config, `t_camera3d.gd` and git were not touched.
The probe lived only in `variant3d/tests/t_v777_zoom_anchor_probe.gd` and was
deleted after the final run (`Test-Path` → `False`). Tabs throughout, no RNG.

E6 as handed off (`AUDIT3D_05_camera_hud_pick.md:134-138`,
`V775_pick_caller.md:159`): `camera3d.gd`'s `_smooth_zoom()` resolved the zoom
anchor with the flat `screen_to_world()` Y=0 hit at old :380/:389; requested a
height sampler used only for the anchor, leaving `screen_to_world()` flat so
`hud3d_adapter.gd:82-88` and `picking3d._recalc_offset():64-90` keep their
contract. That contract is preserved verbatim here.

## 2. Evidence (all path:line)

| Observation | Path:line | Use in the patch |
|---|---|---|
| Flat Y=0 anchor read at old zoom and re-read at new zoom | `camera3d.gd:471,486` (pre-edit `:380,:389`) | replaced by surface hit / fixed-height re-hit |
| `screen_to_world()` flat-plane contract | `camera3d.gd:180-189` | **unchanged**; HUD/pick callers keep their contract |
| Real sampler, bilinear over the mesh's `height[]` grid, centred x/z metres | `world3d_terrain.gd:402-422` | preferred sampler, no coordinate conversion |
| World passthrough of that sampler | `world3d.gd:583-587` | reachable shape (`height_at_world(p) -> float`) |
| Live bound object is `game`, NOT `world` | `main.gd:590` `camera.bind(game, world.view_scale)` | sampler must be found dynamically on `game`; there is no `game.world` field |
| Production sampler on the bound object | `app/scripts/game.gd:1893-1907` `height_at(p)`, SIM map-origin metres | fallback path with `(MAP_W/2, MAP_H/2)*TILE_M` offset |
| `TILE_M = 2.0` matches game `TILE = 2.0` | `variant3d/scripts/data.gd:23` | offset algebra centred ↔ sim |
| V7-70 seam makes centred metres the camera's world space | `main.gd:1007-1015` `_center_camera3d_target()` | why centred `screen_to_world()` output feeds `height_at_world` directly |
| `jump_to_world` must stay intact | `camera3d.gd:304-312` | probed after the patch: target set, anchor cleared |
| Two-arg `set_zoom_target` / 2D defaults | `camera3d.gd:441-457` | signatures and defaults untouched; probed |
| Wheel position forwarding is correct (no caller fix needed) | `V775_pick_caller.md:159` (`input_controller.gd:451`) | not edited |

## 3. Exact diff

`--- a/variant3d/scripts/camera3d.gd` / `+++ b/variant3d/scripts/camera3d.gd`

New private state at `:75-85` (after `_zoom_anchor_screen`):

```diff
@@ -73,3 +73,16 @@
 var _zoom_anchor_screen: Vector2 = Vector2.INF
 
+# E6 — terrain height sampler for the zoom-at-cursor anchor ONLY. Resolved from the
+# bound game/world in bind() (no other file is edited, no new public API):
+#   * world3d.gd:584 height_at_world(p) / world3d_terrain.gd:406 expects CENTRED
+#     x/z metres — the same space screen_to_world() returns after V7-70 seam.
+#   * game.gd:1893 height_at(p) expects SIM map-origin metres, so a
+#     (MAP_W/2, MAP_H/2)*TILE_M offset is applied before the call.
+# Empty method = no sampler reachable; _sample_height() then returns 0.0, the old
+# flat Y=0 plane. NO height is invented when the sampler is absent.
+var _height_sampler_obj: Object = null
+var _height_sampler_method: String = ""
+var _height_sampler_sim_offset: Vector2 = Vector2.ZERO
+
 # Edge-scroll / depth / dwell tunables: port parity with the shipping 2D camera
```

`bind()` at `:109-113`:

```diff
 func bind(game: Object, view_scale: float = 1.0) -> void:
 	self.game = game
 	self.view_scale = view_scale
+	_resolve_height_sampler()
 	projection = PROJECTION_PERSPECTIVE
```

Four private helpers inserted at `:192-265` (between `screen_to_world()` and
`get_viewport_corners()`):

```diff
+# Bind an existing height sampler without touching its owner. Preference order:
+# centred-space height_at_world (world3d.gd:584 / a bound stub world), then
+# sim-space game.height_at (game.gd:1893) with the map-centre offset, then an
+# optional `world` field exposing height_at_world. Empty result = no sampler.
+func _resolve_height_sampler() -> void:
+	_height_sampler_obj = null
+	_height_sampler_method = ""
+	_height_sampler_sim_offset = Vector2.ZERO
+	if game == null or not is_instance_valid(game):
+		return
+	if game.has_method("height_at_world"):
+		_height_sampler_obj = game
+		_height_sampler_method = "height_at_world"  # centred x/z — no offset
+		return
+	if game.has_method("height_at"):
+		var mw: float = float(game.get("MAP_W")) if game.get("MAP_W") != null else 0.0
+		var mh: float = float(game.get("MAP_H")) if game.get("MAP_H") != null else 0.0
+		if mw > 0.0 and mh > 0.0:
+			_height_sampler_obj = game
+			_height_sampler_method = "height_at"
+			_height_sampler_sim_offset = Vector2(mw, mh) * 0.5 * Data.TILE_M
+			return
+	var w = game.get("world")
+	if w is Object and is_instance_valid(w) and w.has_method("height_at_world"):
+		_height_sampler_obj = w
+		_height_sampler_method = "height_at_world"
+
+
+# Terrain height in metres at an x/z point in screen_to_world()'s CENTRED metre
+# space. No sampler reachable -> 0.0, the same flat Y=0 plane as before E6; no
+# height is fabricated. The sampler is called dynamically so no typed coupling to
+# game.gd / world3d.gd is introduced here.
+func _sample_height(p: Vector2) -> float:
+	if _height_sampler_obj == null or _height_sampler_method == "":
+		return 0.0
+	if not is_instance_valid(_height_sampler_obj):
+		return 0.0
+	if not is_finite(p.x) or not is_finite(p.y):
+		return 0.0
+	return float(_height_sampler_obj.call(_height_sampler_method, p + _height_sampler_sim_offset))
+
+
+# Ray -> horizontal plane at fixed height_m. x/z in the same space as
+# screen_to_world(); INF if parallel or behind the camera.
+func _screen_to_plane(screen: Vector2, height_m: float) -> Vector2:
+	var origin: Vector3 = project_ray_origin(screen)
+	var dir: Vector3 = project_ray_normal(screen)
+	if absf(dir.y) < 0.000001:
+		return Vector2.INF
+	var t: float = (height_m - origin.y) / dir.y
+	if t < 0.0:
+		return Vector2.INF
+	var hit: Vector3 = origin + dir * t
+	return Vector2(hit.x, hit.z)
+
+
+# E6: terrain SURFACE point under a screen pixel (not the flat Y=0 point). Start
+# at the flat hit, sample its height, re-cast at that height, repeat until the
+# horizontal hit moves < 0.1 mm (max 12 passes) so the returned point really lies
+# on the sampled height field. With no sampler every pass reads 0.0, so the result
+# is exactly the old screen_to_world() point (default unchanged).
+func _screen_to_surface(screen: Vector2) -> Vector2:
+	var p: Vector2 = screen_to_world(screen)
+	for _i in range(12):
+		if not is_finite(p.x) or not is_finite(p.y):
+			return Vector2.INF
+		var q: Vector2 = _screen_to_plane(screen, _sample_height(p))
+		if not is_finite(q.x) or not is_finite(q.y):
+			return p
+		var moved: float = q.distance_squared_to(p)
+		p = q
+		if moved < 1.0e-8:
+			break
+	return p
```

`_smooth_zoom()` at `:468-495`:

```diff
 	var anchored: bool = is_finite(_zoom_anchor_screen.x) and is_finite(_zoom_anchor_screen.y)
-	var anchor_world: Vector2 = screen_to_world(_zoom_anchor_screen) if anchored else Vector2.INF
+	# E6: hold the TERRAIN surface point under the cursor, not its Y=0 shadow.
+	# With no sampler _screen_to_surface() == screen_to_world() (flat default).
+	var anchor_world: Vector2 = _screen_to_surface(_zoom_anchor_screen) if anchored else Vector2.INF
+	# Freeze the anchor's sampled height: after the dolly, the same world point must
+	# stay under the cursor, so re-hit the ray at THIS height (not a re-sampled one,
+	# which would track a different surface point on a slope).
+	var anchor_h: float = _sample_height(anchor_world) if is_finite(anchor_world.x) and is_finite(anchor_world.y) else 0.0
 	var old_z: float = zoom
@@
 	if anchored and is_finite(anchor_world.x) and is_finite(anchor_world.y):
-		var after: Vector2 = screen_to_world(_zoom_anchor_screen)
+		# Same-height ray hit at the NEW zoom; with no sampler anchor_h == 0.0 and
+		# this is byte-equivalent to the old flat screen_to_world() correction.
+		var after: Vector2 = _screen_to_plane(_zoom_anchor_screen, anchor_h)
+		if not is_finite(after.x) or not is_finite(after.y):
+			# Steep hill above the dolly position: the sampled plane is not hit.
+			# Fall back to the old flat hit rather than dropping the anchor.
+			after = screen_to_world(_zoom_anchor_screen)
 		if is_finite(after.x) and is_finite(after.y):
 			_target += anchor_world - after
 			_apply_transform()
```

Functional surface change: two `_smooth_zoom()` lines plus additive private
helpers; no public signature, default, constant or 2D behaviour changed.
`screen_to_world()` remains the flat Y=0 raycast.

## 4. Verification — variant3d runner only

All launches:
`python -X utf8 variant3d\tools\godot_runner.py run --id <id> --timeout 120 -- --headless --path variant3d …`
Telemetry from `variant3d/.godot_queue`; stdout/stderr under
`variant3d/.godot_queue/results/<padded-ticket>_<id>/`.

| Ticket | Job id | Command tail | Result |
|---|---|---|---|
| 165 | `v777-parse-cam3d` | `--check-only --script res://scripts/camera3d.gd` | ok, exit 0, run 3.23 s |
| 167 | `v777-zoom-anchor-probe` | probe v1 | **timed out** — `String()` cast of a Vector2 raised a script error so `quit()` was never reached; killed at 120 s |
| 169 | `v777-parse-cam3d-r2` | parse after convergence change | ok, exit 0, run 2.36 s |
| 170 | `v777-zoom-anchor-probe-r2` | probe v2 | failed 11/12 — one probe assertion (`SHADOW_NO_LONGER_ANCHORED`) was geometrically false; camera checks all passed |
| **172** | **`v777-parse-cam3d-final`** | parse of shipped file | **ok**, exit 0, run 2.18 s, stderr 0 bytes |
| **174** | **`v777-zoom-anchor-probe-final`** | `--script res://tests/t_v777_zoom_anchor_probe.gd` | **ok**, exit 0, wait 62.33 s, run 2.26 s, **stderr 0 bytes**, **12/12 checks PASS** |

### 4.1 Probe design (ticket 174)

Two `Camera3D` instances loaded from `res://scripts/camera3d.gd` on a
`1280×720` root, both `_target=(0,0)`, `zoom=1`, anchor pixel `(320,540)`,
zoomed to `1.8` by 900 `_smooth_zoom(1/60)` steps. `SlopeStub` exposes
`height_at_world(p) = 0.25*p.x - 0.12*p.y + 1.5` (non-zero, sloped) with a call
counter; `NoSamplerStub` exposes no sampler at all. `before` = the no-sampler
camera, whose math is the old flat `screen_to_world()` path (measured equal to
`_screen_to_surface()` to `0.00000000 m`). `after` = the terrain-sampler camera.
Both cameras are driven by the SAME shipped script; only the reachable sampler
differs. Drift is measured by `unproject_position()` of the true surface point
`(p0, h0)` found before zoom, and by a same-height ray re-hit in metres.

### 4.2 Measured drift

```text
V777 DRIFT terrain-point before(flat)=0.0001 px / 0.00000 m ; after(terrain)=0.0024 px / 0.00008 m
V777 PROJ flat=(320.0, 539.9999) slope=(320.0, 539.9976) anchor=(320.0, 540.0) p0=(-8.027232, 6.467655) h0=-1.2829
V777 SHADOW-DRIFT before(flat)=0.0000 px ; after(terrain)=0.0025 px (gap=1.7680 m)
V777_ZOOM_ANCHOR_PROBE PASS 12/12 checks
```

Supporting checks: `SLOPE_SAMPLER_BOUND` (`height_at_world` selected),
`SLOPE_SAMPLER_NONZERO` (`h(3,-2)=2.4900`, calls > 0),
`DEFAULT_FLAT_UNCHANGED` (surface hit == flat hit, delta `0.00000000 m`),
`SLOPE_SEPARATES_FROM_FLAT` (`1.7680 m` between surface and Y=0 shadow at the
cursor), `SURFACE_UNDER_CURSOR_BEFORE` (`0.0001 px`), `ZOOM_CONVERGED`,
`JUMP_TO_WORLD_INTACT` (V7-66 API intact: target `(300,300)`, anchor cleared),
`TWO_ARG_IMMEDIATE_CLEARS_ANCHOR` (2D/default semantics intact),
`FLAT_SHADOW_ALSO_STAYS` (both anchors < 1 px drift).

**Interpretation (honest):** the terrain point stays under the cursor after the
fix (`0.0024 px`, `0.00008 m`), which satisfies the assignment's anchor
assertion, but the old flat anchor also stayed (`0.0001 px`). On a planar slope
the flat correction `Δ = f_old - f_new` maps the new pixel ray exactly onto the
old ray line, so *every* point on that ray — terrain surface included — remains
under the cursor. Consequently there is **no measured drift reduction** on this
slope; the extra `0.0023 px` is the residual of the iterative surface solve, not
a regression of the anchor. The change makes the anchor explicitly terrain-based
and adds a fixed-height re-hit plus a fallback for a sampled plane above the
dolly, but E6's stated mechanism is not reproduced by this probe.

### 4.3 Cleanup

Probe deleted immediately after ticket 174; `Test-Path` returned `False`. No
other file in `variant3d/tests/` was added or modified. No `cmd_*` call, RNG,
visual screenshot or A/B comparison was performed. No visual parity claim is
made.

## 5. Explicit "no sampler" behaviour

When neither `height_at_world`, nor `height_at` with positive `MAP_W/MAP_H`, nor
a `world` field with `height_at_world` is reachable on the bound object (measured
in `NO_SAMPLER_FALLBACK`: `_height_sampler_method == ""`, sample at `(10,10)` =
`0.0`), the camera **says so structurally** — an empty sampler method — and
`_sample_height()` returns `0.0`, the pre-existing flat Y=0 plane. It does not
invent a height, and no warning is spammed per frame. In the real runtime
`main.gd:590` binds `game`, which has `height_at` but not `height_at_world`; the
map-centre offset path is therefore the production sampler (not exercised by
this probe’s stub).

## 6. Open questions / residual risk

1. **E6 premise questioned.** The measured planar slope shows the old flat
   anchor already preserves the entire view ray, hence zero terrain-point drift.
   A future audit should re-check whether the reported "drift on hilly terrain"
   came from another seam (e.g. `clamp_pos()` after `_smooth_zoom`, or the
   HUD/pick flat-plane split) rather than `_smooth_zoom()` alone. The requested
   terrain-height anchor is implemented, but no drift improvement was observed.
2. **`game.height_at` path unprobed.** Production binds `game` (`main.gd:590`);
   the sim-map-offset branch (`game.gd:1893`, `data.gd:23`) was reasoned about and
   parsed but not runtime-tested here, because this assignment forbids editing
   `main.gd` to bind a stub world and the probe used `height_at_world` directly.
3. **`world` field path unprobed.** The `game.get("world")` fallback is
   defensive only; no current object is known to expose it.
4. **Iterative solve robustness.** Twelve damped-by-convergence passes assume a
   gentle bilinear lattice (`HEIGHT_SCALE = 1.0`, `world3d_terrain.gd:51`); a
   slope steeper than the −32° view ray could fail to converge, in which case the
   last finite hit is used. Not stressed by this probe.
5. **No visual parity claim** — parse + headless numeric probe only.
6. E19 (`main.gd` journey-mode camera) remains untouched and open; out of scope.
