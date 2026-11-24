---
agent: W5-7
wave: 5
date: 2026-11-24
title: Edge-scroll depth ramp + logarithmic dwell acceleration
files_owned:
  - app/scripts/camera.gd
status: IMPLEMENTED; SMOKE + PARSE VERIFIED (retry); feel UNVERIFIED (owner review)
runner_jobs: [1304, 1309, 1313]
backup: inbox/backup/camera.gd.bak-W57
---

# W5-7 — Depth-ramped, dwell-accelerated edge scroll

## Verdict

Implemented in `app/scripts/camera.gd` only. The donor has **no** depth gradient
and **no** dwell acceleration: it uses one flat profile-derived speed selected
by a binary key-vs-mouse-zone test. This change is therefore a **PORT
IMPROVEMENT requested by the owner**, not donor parity. Arrow-key pan,
middle-drag, the 50 ms `dt` clamp, `clamp_pos()` and its memo are unchanged.

The first smoke attempt hit the shared W5 Godot startup failure (ticket 1304:
exit 1, empty stderr, banner-only stdout, zero test lines). A focused parse
check (ticket 1309) passed with zero diagnostics, and a fresh retry of the
same smoke job (ticket 1313) **passed 6/6** with empty stderr — so camera.gd
parses and the existing camera/minimap smoke assertions still hold. Note that
t_nav_smoke does **not** exercise edge scroll; this is load/regression
verification only for this change. The speed FEEL is visual and remains owner
review.

## 1. Donor truth (private-use, read-only; bytes + latin-1, never run/copied)

| Source | Literal | Meaning |
|---|---|---|
| `C:\Games\Cossacks 3\data\gui\menu.inc\cameracontrol.inc:20-21` | `const cMargin = 8;` / `const cCornerMargin = 24;` | Fixed-width hot rectangles only. |
| `cameracontrol.inc:27-30` | `CreateCameraControlLayer(..., cMargin, viewH, cTagLeft, 'crScrollLeft');` (and Right/Top/Bot) | A boolean zone hit per edge; no depth value is passed. |
| `cameracontrol.inc:32-35` | `CreateCameraControlLayer(..., cCornerMargin, cCornerMargin, cTagLeftTop, 'crScrollLeftTop');` (and other 3 corners) | Corners are four more fixed rectangles, tags 24-27. |
| `C:\Games\Cossacks 3\data\gui\menu.inc\oncamera.inc:10-11` | `var keySpeed : Float = gProfile.keyscrollspeed*4;` / `var mouseSpeed : Float = gProfile.mousescrollspeed*4;` | Flat speeds from profile settings. |
| `oncamera.inc:23-29` | `if (bLeft) or (bRight) or (bUp) or (bDown) then speed := keySpeed else if (bmouse) then speed := mouseSpeed; SetCameraElasticMoveFactor(speed);` | **Binary choice, one flat speed.** No depth, no dwell, no log. |
| `oncamera.inc:37-58` | `case tag of 20 : bLeft := True; ... 27 : bRight := True; bDown := True;` | Tags flip booleans; no intensity is read. |
| `oncamera.inc:60-73` | `GetCameraAbsoluteLeftDirection(...)`, `SetCameraElasticMoveDirection(fcx, fcy, fcz);` | Direction only; magnitude comes from the single `speed`. |
| `C:\Games\Cossacks 3\data\gui\menu.inc\dombtncameracontrol.inc:19-20` | `((prevX-curX)/60)*(0.5+gProfile.middlemousescrollspeed)` | Middle-drag is likewise a flat factor. |
| `C:\Games\Cossacks 3\data\cameras\camera.cfg:22` | `StepTimeMoveAccel = 0.00001` | Engine elastic-move acceleration (effectively instant); **not** cursor-dwell acceleration. Do not conflate. |
| `C:\Games\Cossacks 3\data\gui\menu.inc\eventsettings.inc:164-166` | `const cGameOptionsMouseScrollSpeed = 'mousescrollspeed';` etc. | Profile option names only; no values. |

**Donor conclusion:** flat speed per input source; edge depth and dwell
acceleration do not exist in the donor data. Treated as owner-directed port
improvement, explicitly permitted by the task.

NOT-DONE (donor): a full data-tree byte scan was attempted but aborted mid-output
on a Windows cp1252 console encode error; the camera-specific files above were
read in full and are authoritative for this change.

## 2. VERIFIED-ALREADY (unchanged, re-read before edit)

- `camera.gd:11-14` margins/speeds from `Data` (donor `cMargin`/`cCornerMargin`,
  `mousescrollspeed*4`/`keyscrollspeed*4`).
- `camera.gd:79-88` zoom clamp from donor `camera.cfg:6-7` (`SphereHeight = 58`,
  `SphereHeightMin = 20`) — untouched.
- `camera.gd:100-114` `clamp_pos()` and its `_last_clamp_pos` / `_last_clamp_zoom`
  memo — untouched.
- `camera.gd:73-98` `jump_to_world()` / `mark_dirty()` — untouched.
- `camera.gd:144` 50 ms `dt` clamp — untouched.
- `camera.gd:149-160` middle-drag raw-delta pan and its INF cache — untouched.
- `camera.gd:226-237` arrow-key reads and fixed `key_speed` branch — untouched
  in behaviour (the speed expression now multiplies only the *mouse* branch).

## 3. FIXED — exact diff

Backup: `inbox/backup/camera.gd.bak-W57` (SHA256 prefix `46C65FEE85EB7B55C5404B1`,
byte-identical to pre-W5-7 camera.gd). Tabs preserved; no called-symbol renames;
no files other than `camera.gd` edited.

### State + tunables (`camera.gd:39-51`)

```gdscript
+# W5-7: edge-scroll acceleration state. _edge_dwell_dir holds the EDGE-ONLY
+# direction (arrow keys excluded); the dwell clock resets instantly whenever
+# the direction changes or the cursor leaves the edge band.
+var _edge_dwell_dir := Vector2.ZERO
+var _edge_dwell_time := 0.0
+# W5-7: tunables read from camera.* settings at bind(). The defaults below
+# reproduce the old flat mouse_speed when no keys exist (bind(null) safe).
+var edge_depth_gain := 3.0      # camera.edge_depth_gain — k in 1 + k*depth^2
+var edge_depth_max := 4.0       # camera.edge_depth_max — cap of depth multiplier
+var edge_dwell_gain := 1.0      # camera.edge_dwell_gain — k in log ramp
+var edge_dwell_tau := 0.5       # camera.edge_dwell_tau — seconds time constant
+var edge_dwell_max := 3.0       # camera.edge_dwell_max — cap of dwell multiplier
+var edge_total_max := 6.0       # camera.edge_total_max — cap of combined multiplier
```

### `bind()` (`camera.gd:57-58`, `camera.gd:71-78`)

```gdscript
+	_edge_dwell_dir = Vector2.ZERO
+	_edge_dwell_time = 0.0
 	...
 		zoom_smooth_rate = cfg.num("camera.zoom_smooth_rate", 18.0)
+		# W5-7: edge acceleration keys are read the same way (the merged
+		# settings may carry them even though config.gd's DEFAULT does not).
+		edge_depth_gain = cfg.num("camera.edge_depth_gain", 3.0)
+		edge_depth_max = cfg.num("camera.edge_depth_max", 4.0)
+		edge_dwell_gain = cfg.num("camera.edge_dwell_gain", 1.0)
+		edge_dwell_tau = cfg.num("camera.edge_dwell_tau", 0.5)
+		edge_dwell_max = cfg.num("camera.edge_dwell_max", 3.0)
+		edge_total_max = cfg.num("camera.edge_total_max", 6.0)
```

### `_process()` — depth ramp + dwell (`camera.gd:142-143`, `161-220`)

```gdscript
-	# The clamped dt is used UNSCALED: no extra speed factor sits between input
-	# and camera movement, so edge/key pan matches the profile speeds exactly.
+	# dt is UNSCALED. W5-7 folds its depth/dwell factor into mouse_speed only;
+	# arrow-key and middle-drag pan still match the profile speeds exactly.
 	dt = minf(dt, 0.05)
 	...
+	# W5-7: multiplier applied ONLY to mouse edge scroll; arrow keys keep the
+	# fixed key_speed and middle-drag is untouched. 1.0 = old flat behaviour.
+	var mouse_mult := 1.0
 	if not middling:
 		var at_left := ...
 		var at_right := ...
 		var at_top := ...
 		var at_bot := ...
+		var edge_dir := Vector2.ZERO
 		if at_left:
 			dir.x -= 1
+			edge_dir.x -= 1
 		... (same for right/top/bot) ...
+		# W5-7 DEPTH RAMP: 0 at the inner boundary of the active band, 1 at the
+		# physical screen edge (corner zones use the wider corner_margin).
+		# Smooth quadratic growth, capped — faster the closer to the edge.
+		var em := maxf(edge_margin, 0.001)
+		var cm := maxf(corner_margin, em)
+		var depth := 0.0
+		if at_left:
+			var l_extent := cm if m.y < corner_margin else em
+			depth = maxf(depth, clampf((l_extent - m.x) / l_extent, 0.0, 1.0))
+		if at_right:
+			var r_extent := cm if m.y < corner_margin else em
+			depth = maxf(depth, clampf((m.x - (vp.x - r_extent)) / r_extent, 0.0, 1.0))
+		if at_top:
+			depth = maxf(depth, clampf((em - m.y) / em, 0.0, 1.0))
+		if at_bot:
+			depth = maxf(depth, clampf((m.y - (vp.y - em)) / em, 0.0, 1.0))
+		var depth_mult := clampf(1.0 + edge_depth_gain * depth * depth, 1.0, edge_depth_max)
+		# W5-7 DWELL: accumulate clamped dt while the SAME edge direction is
+		# held, reset instantly on a direction change or when leaving the edge.
+		# Logarithmic ramp -> fast early, gently decelerating, hard-capped.
+		if edge_dir == Vector2.ZERO:
+			_edge_dwell_dir = Vector2.ZERO
+			_edge_dwell_time = 0.0
+		else:
+			if edge_dir != _edge_dwell_dir:
+				_edge_dwell_dir = edge_dir
+				_edge_dwell_time = 0.0
+			_edge_dwell_time += dt
+		var dwell_mult := 1.0
+		if _edge_dwell_time > 0.0:
+			dwell_mult = clampf(1.0 + edge_dwell_gain * log(1.0 + _edge_dwell_time / maxf(edge_dwell_tau, 0.001)), 1.0, edge_dwell_max)
+		mouse_mult = clampf(depth_mult * dwell_mult, 1.0, edge_total_max)
+	else:
+		# Middle-drag suspends edge scroll: drop any accumulated dwell so a
+		# later edge entry starts at the flat speed again.
+		_edge_dwell_dir = Vector2.ZERO
+		_edge_dwell_time = 0.0
```

### `_process()` — speed branch (`camera.gd:239`)

```gdscript
-		var speed := key_speed if (k_left or k_right or k_up or k_down) else mouse_speed
+		var speed := key_speed if (k_left or k_right or k_up or k_down) else mouse_speed * mouse_mult
```

Full unified diff: `git diff --no-index -- inbox/backup/camera.gd.bak-W57 app/scripts/camera.gd`.

### How the acceleration behaves at defaults

- Depth `d`: 0 at the inner boundary of the active zone, 1 at the physical
  screen edge (corner zones use the wider `corner_margin`). Non-corner edges
  use `edge_margin`; left/right extent widens to `corner_margin` when
  `m.y < corner_margin`, preserving the existing corner trigger.
- Depth factor: `clamp(1 + 3·d², 1, 4)` → 1× at the zone boundary, 1.75× at
  half depth, 4× at the very edge.
- Dwell factor: `clamp(1 + 1·ln(1 + t/0.5), 1, 3)` → 1× at t=0,
  ≈2.10× at t=0.5 s, ≈2.61× at t=1 s, capped at 3× after ≈3.19 s.
- Combined factor is capped at 6× (`edge_total_max`), so with the default
  `mouse_speed = 64` the peak pan rate is bounded (384 port units/s at zoom 1).
  The cursor must be at the very edge *and* dwell there to reach the cap.

## 4. Exact config keys for W5-2 / coordinator

Read at `bind()` via `C3ConfigScript.active.num(key, default)` — identical
pattern to W4-1's zoom keys. **No config change is required**; every default
is baked into `camera.gd` and also into the member initialisers, so
`bind(null)` (used by the smoke test) is safe.

| Key | Default | Role |
|---|---|---|
| `camera.edge_depth_gain` | `3.0` | k in `1 + k·depth²` |
| `camera.edge_depth_max` | `4.0` | cap of depth multiplier |
| `camera.edge_dwell_gain` | `1.0` | k in `1 + k·log(1 + t/tau)` |
| `camera.edge_dwell_tau` | `0.5` | dwell time constant (seconds) |
| `camera.edge_dwell_max` | `3.0` | cap of dwell multiplier |
| `camera.edge_total_max` | `6.0` | cap of combined multiplier |

`data.gd` / `main.gd` / `config.json` were NOT edited (not mine). If W5-2 wants
these surfaced in `--dump-config`, add them to `config.gd`'s DEFAULT table.

## 5. Runner jobs and results

Exact command for both smoke attempts (per task):

```
python app\tools\godot_runner.py run --id <id> --timeout 180 -- --headless --path app --script res://tests/t_nav_smoke.gd
```

| Ticket | Id | Result |
|---|---|---|
| 1304 | `w57-edge` | **FAILED** — exit 1, run 6.95 s (waited 255.09 s), `stdout.txt` contains only the Godot v4.7.2 banner, `stderr.txt` 0 bytes, **no** PASS/FAIL lines. This is the shared W5 empty-stderr banner-only startup failure, not a GDScript diagnostic. |
| 1309 | `w57-parse` | **OK** — exit 0, run 9.97 s, `--check-only --script res://scripts/camera.gd`; stdout banner only, stderr empty. **camera.gd parses with zero errors.** |
| 1313 | `w57-edge-retry` | **OK** — exit 0, run 8.35 s, **6/6 PASS**: `camera_early_priority`, `camera_jump_immediate`, `camera_mark_dirty`, `minimap_center`, `minimap_drag_clamped`, `minimap_rect_cached`; stderr empty. |

Result files: `app/.godot_queue/results/00001304_w57-edge/`,
`00001309_w57-parse/`, `00001313_w57-edge-retry/`; metadata in
`app/.godot_queue/status.json`.

**Verdict: VERIFIED for parse + existing camera/minimap smoke (1313, 1309),
NOT VERIFIED for edge-scroll behaviour.** t_nav_smoke asserts jump/dirty,
minimap math and priority only — it does not move the mouse into an edge band,
so this is parse/load/regression verification, **not** a measured speed gain.
The acceleration FEEL is visual and is explicitly left to owner review; no
speed-gain claim is made. Ticket 1304's failure was environmental and is
superseded by the clean retry.

## 6. Determinism note

No RNG added. Depth is a pure function of mouse position and the fixed margins;
dwell is an accumulation of the already-clamped `dt`, reset to zero whenever
the edge-only direction changes, the cursor leaves the edge, or middle-drag
starts. The log ramp is frame-rate-independent in continuous time; exact
intermediate values depend on per-frame `dt`, but the hard caps make the
result bounded and reproducible. Startup, zoom smoothing, `clamp_pos()` memo
and sim tick order are untouched, so screenshots and selftests are unaffected
when the cursor is away from the edges (multiplier = 1.0).

## 7. NOT-DONE / open questions (feel tuning)

- Visual A/B of the ramp: UNVERIFIED — owner review. Is 4× at the very edge
  and 6× combined too aggressive at 1920×1080 vs 1280×720?
- Should dwell reset *gradually* (fast decay) instead of instantly when the
  cursor leaves the edge? Currently instant, per task wording "reset quickly".
- Should corners combine x and y depth (e.g. `sqrt(dx²+dy²)`) rather than
  `max(dx, dy)`? Current `max` keeps the code simple and preserves existing
  corner triggering.
- Should the new keys be added to `config.gd`'s DEFAULT table and
  `Data/CAMERA_*` statics for `--dump-config` visibility? Owner/W5-2 decision.
- The original donor bottom-left/bottom-right corner tags exist but the
  pre-existing port `at_left`/`at_right` only test the *top* corner condition;
  preserved deliberately (minimal diff) — flag if parity is wanted later.
- Full selftest: not run (coordinator gate).
