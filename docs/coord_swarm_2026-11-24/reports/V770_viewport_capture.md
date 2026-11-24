---
id: V7-70
owner: V7-70 (main.gd owner)
scope: "variant3d/scripts/main.gd ONLY — P0 G1 windowed 3D viewport capture; W5-2 lossless self-snapshot; E19 journey camera handoff"
date: 2026-11-24
status: DELIVERED — windowed 3D pixels MEASURED; snapshot round-trip MEASURED; journey camera MEASURED; selftest 29/29 passed:true
verdict: "P0 G1 CLOSED for capture mechanics: a real GPU 3D frame is now saved from a dedicated SubViewport (ticket 179). Donor visual parity (composition/camera literals) remains UNVERIFIED."
files_changed: ["variant3d/scripts/main.gd", "docs/coord_swarm_2026-11-24/reports/V770_viewport_capture.md"]
files_not_touched: ["app/**", "variant3d/scripts/world3d.gd", "variant3d/scripts/camera3d.gd", "variant3d/scripts/input_controller.gd", "variant3d/scripts/hud.gd", "variant3d/scripts/picking3d.gd", "variant3d/selftest.json (rewritten only by the mandated selftest job)", "variant3d/tests/results/**"]
git_operations: none
---

# V7-70 — windowed 3D viewport capture, snapshot parity, journey camera

## 1. Capture-path evidence (path:line)

Baseline (from AUDIT3D-09, before this ticket):

- `variant3d/scripts/main.gd:1715-1725` (old numbering) — headless screenshot always calls `_render_headless_image(800,600)`; CPU map by design.
- `variant3d/scripts/main.gd:1749-1752` (old numbering) — windowed branch judged the viewport texture blank and overwrote it with the CPU map, printing `screenshot saved (fallback map render)`.
- `variant3d/scripts/main.gd:1757-1767` — `_is_blank()` luminance threshold 0.02.
- AUDIT3D-09 ticket **77** `audit3d-shot-windowed-long`: real OpenGL 3.3 context, yet stdout = `screenshot saved (fallback map render)`; artifact was the flat 2D map in `user://`.

Root cause measured in this ticket (not assumed):

1. The root-window backbuffer read through `get_viewport().get_texture()` is blank under `gl_compatibility` (reproduced with a SubViewport too — ticket 132).
2. A **coordinate mismatch** was the reason even a real render target read blank: the 3D scene is centred on origin (`world3d_entities.gd:577` → `p - w*0.5*TILE_M`; `world3d_terrain.gd:312-314`; `world3d.gd:161-162`), but `main.gd` set `camera._target` from raw map-origin sim metres. Ticket 132 measured `camera_pos=(606.1345, 39.32768, 125.8137)`, `target=(606.1345, 62.87621)` — outside the ±320 m terrain — and `p00=(0.1059, 0.1412, 0.0784)` (flat clear colour). This is a capture/render-timing **and** camera-seam problem, not missing 3D.

Final code paths (current numbering):

- `main.gd:166` `var capture_view3d: SubViewport = null`.
- `main.gd:1003-1016` `_center_camera3d_target()` — converts the clamped sim-metre focus to centred 3D metres and freezes `clamp_pos()`'s memo; called from both 3D setup seams at `main.gd:605` (async menu path) and `main.gd:1068` (synchronous test/capture path).
- `main.gd:1185-1203` windowed 3D capture setup: dedicated `SubViewport` render target, `UPDATE_ONCE`, world + camera reparented (references preserved), `camera.make_current()`.
- `main.gd:1810-1879` capture: force `UPDATE_ONCE`, `await RenderingServer.frame_post_draw`, read `Screenshot3DViewport.get_texture().get_image()`, raw image diagnostics, **no CPU fallback in 3D windowed mode**; headless branch at `main.gd:1799-1809` unchanged.
- `main.gd:1872-1876` CPU fallback retained for 2D only (existing 2D path, byte-identical).

## 2. Exact diff (all in `variant3d/scripts/main.gd`)

```diff
@@ near var autosave_acc (now 166)
+var capture_view3d: SubViewport = null   # V7-70 P0 G1 render target
@@ near var journey_cam_t (now 160)
+var dbg_journey := 0                     # E19 probe, first two updates
@@ _ready menu skip (now 230)
-	if bench_mode or screenshot_path != "" or selftest_path != "" or uitest_path != "" or seq_dir != "" or battle_requested:
+	if bench_mode or screenshot_path != "" or selftest_path != "" or uitest_path != "" or seq_dir != "" or battle_requested or journey_mode:
 		_setup_full_game()
@@ _dump_self_base (now 748-766)
-	var starts: Array = []
-	for s in game.map_starts: starts.append([float(s.x), float(s.y)])
-	var zones: Array = []
-	for z in game.cluster_zones:
-		var zd: Dictionary = z
-		zones.append([float(zd.pos.x), float(zd.pos.y), float(zd.r)])
 	var dump := {
-		"format": "w52-self-base-1", ...
-		"tileblock": Marshalls.raw_to_base64(game.tileblock),
-		"mine_mask": Marshalls.raw_to_base64(game.mine_mask),
-		"starts": starts, "zones": zones, "meta": game.map_meta,
+		"format": "w52-self-base-2", ...
+		"terrain": game.terrain, "blocked": game.blocked, "height": game.height,
+		"tileblock": game.tileblock, "mine_mask": game.mine_mask,
+		"starts": game.map_starts, "zones": game.cluster_zones, "meta": game.map_meta,
 	}
-	var out := _write_text(self_base_dump_path, JSON.stringify(dump))
+	var out := _write_text(self_base_dump_path, var_to_str(dump))
@@ _same_json numeric compare (now 804-811)
-		return float(a) == float(b)
+		var q := PackedFloat32Array()
+		q.append(float(a)); q.append(float(b))
+		return q[0] == q[1]
@@ new _json_rect (now 820-833) — copied from app/scripts/main.gd:778-797
+func _json_rect(v: Variant) -> Rect2:
+	if v is Rect2: return v
+	if v is String:
+		... parse "(x, y), (w, h)" into Rect2(...)
+	return Rect2()
@@ _json_diff numeric compare (now 852-856)
-		return "" if float(a) == float(b) else ...
+		var q := PackedFloat32Array()
+		q.append(float(a)); q.append(float(b))
+		return "" if q[0] == q[1] else ...
@@ _load_self_base (now 864-946)
-	var txt := FileAccess.get_file_as_string(path)
+	var resolved := _pick_target(path)
+	var txt := FileAccess.get_file_as_string(resolved)
-	var parsed = JSON.parse_string(txt)
+	var parsed = str_to_var(txt)
-	if ... "invalid JSON in " ...
+	if ... "not a Variant snapshot in " ...
-	if str(d.get("format","")) != "w52-self-base-1" ...
+	if str(d.get("format","")) != "w52-self-base-2" ...
-	g.tileblock = Marshalls.base64_to_raw(str(d.get("tileblock","")))
-	g.mine_mask = Marshalls.base64_to_raw(str(d.get("mine_mask","")))
+	if d.get("tileblock") is PackedByteArray: g.tileblock = d.tileblock
+	if d.get("mine_mask") is PackedByteArray: g.mine_mask = d.mine_mask
-	g.map_starts = [] ... Vector2(float(sa[0]), float(sa[1]))
-	g.cluster_zones = [] ... {"pos": Vector2(...), "r": ...}
+	g.map_starts = (sarr as Array).duplicate(true)
+	g.cluster_zones = (zarr as Array).duplicate(true)
+	for e in g.entities:
+		if e.has("block_rect"):
+			e["block_rect"] = _json_rect(e.block_rect)   # legacy string-form normaliser
-	if g.tileblock != Marshalls.base64_to_raw(...) ...
+	if d.get("tileblock") is PackedByteArray and g.tileblock != d.tileblock ...
+	if d.get("mine_mask") is PackedByteArray and g.mine_mask != d.mine_mask ...
@@ _setup_full_game fast-load guard (now 1040)
-	FileAccess.file_exists(self_snapshot_path)
+	FileAccess.file_exists(_pick_target(self_snapshot_path))
@@ new seam helper (now 1003-1016)
+func _center_camera3d_target() -> void:
+	if camera == null or not is_instance_valid(camera) or game == null: return
+	var sim_focus: Vector2 = camera.get("_target")
+	var centre_offset := Vector2(game.MAP_W, game.MAP_H) * 0.5 * Data.TILE_M
+	camera.set("_target", sim_focus - centre_offset)
+	camera.set("_last_clamp_target", camera.get("_target"))
+	camera.set("_last_clamp_zoom", camera.get("zoom"))
+	camera.call("_apply_transform")
@@ both 3D setup branches (now 605, 1068), after camera.clamp_pos()
+		_center_camera3d_target()   # only in render_mode=="3d"
@@ _setup_screenshot_window (now 1185-1203)
+	if render_mode == "3d" and world != null and camera != null:
+		capture_view3d = SubViewport.new()
+		capture_view3d.name = "Screenshot3DViewport"
+		capture_view3d.world_3d = World3D.new()
+		capture_view3d.size = Vector2i(Data.WINDOW_WIDTH, Data.WINDOW_HEIGHT)
+		capture_view3d.render_target_update_mode = SubViewport.UPDATE_ONCE
+		add_child(capture_view3d)
+		if world.get_parent() != null: world.get_parent().remove_child(world)
+		capture_view3d.add_child(world)
+		if camera.get_parent() != null: camera.get_parent().remove_child(camera)
+		capture_view3d.add_child(camera)
+		camera.make_current()
@@ _save_screenshot windowed branch (now 1810-1879)
-	await RenderingServer.frame_post_draw
-	if not is_instance_valid(get_viewport()): ...
-	var tex := get_viewport().get_texture()
+	if capture_view3d != null and is_instance_valid(capture_view3d):
+		capture_view3d.render_target_update_mode = SubViewport.UPDATE_ONCE
+	await RenderingServer.frame_post_draw
+	var vp = get_viewport()
+	if capture_view3d != null and is_instance_valid(capture_view3d): vp = capture_view3d
+	if vp == null or not is_instance_valid(vp): ...
+	var tex := vp.get_texture()
 	var img := tex.get_image()
-	if img == null or img.is_empty():
-		printerr("screenshot: blank image, retrying with map render")
-		img = _render_headless_image(800, 600)
+	# 3D: save raw *.raw.png + camera/viewport diagnostics (evidence)
+	if img == null or img.is_empty() or (render_mode == "3d" and _is_blank(img)):
+		if render_mode == "3d":
+			printerr("screenshot: windowed 3D capture is blank; no CPU fallback (visual parity UNVERIFIED)")
+			_quit(1); return
+		printerr("screenshot: blank image, retrying with map render")
+		img = _render_headless_image(800, 600)
+	if render_mode == "3d": print("screenshot capture source: ", vp.name, "/", ...)
-	if _is_blank(img):          # 2D fallback only
+	if render_mode != "3d" and _is_blank(img):
@@ journey camera E19 (now 1644-1661) — 2D lines (1653-1654) byte-identical
 			if n > 0:
-				var target: Vector2 = (focus / float(n)) * world.view_scale
-				camera.position = camera.position.lerp(target, 0.35)
+				if render_mode == "3d":
+					var target_m: Vector2 = focus / float(n)     # sim metres, NO view_scale
+					camera.call("jump_to_world", target_m)
+					_center_camera3d_target()
+				else:
+					var target: Vector2 = (focus / float(n)) * world.view_scale
+					camera.position = camera.position.lerp(target, 0.35)
 				var want_zoom: float = 0.75 if fighting else 1.0
 				camera.set_zoom_target(want_zoom)
+			if dbg_journey < 2: ... print("V770_JOURNEY probe mode=", ...)
```

All snapshot/compare logic is a direct translation of `app/scripts/main.gd:710-926` (V7-69 diagnosis); no donor values were invented. The `_center_camera3d_target()` and journey changes are port-side seams in `main.gd` only; `camera3d.gd` was not opened for writing.

## 3. Measured results — exact runner job ids

All launches used `python variant3d\tools\godot_runner.py run --id <id> ...` only.

| Ticket | Job id | Result | Measurement |
|---|---|---|---|
| 77 (AUDIT3D-09, before) | `audit3d-shot-windowed-long` | ok | `screenshot saved (fallback map render)` — CPU 2D map, no 3D pixels |
| 102 | `v770-main-parse` | ok | `--check-only --script res://scripts/main.gd`, stderr empty |
| 108 | `v770-shot-windowed` | failed (exit 1) | New code, SubViewport present but camera still off-map → `windowed 3D capture is blank`, no image substituted (honest failure) |
| 120, 131, 137 | `v770-main-parse2/3/4` | ok | syntax checks during diagnosis |
| 123 | `v770-shot-windowed-diag` | failed | `viewport=Screenshot3DViewport image=1280x720 p00=(0.1059,0.1412,0.0784) camera_current=true world_parent=Screenshot3DViewport`; raw image = flat clear colour |
| 132 | `v770-shot-windowed-diag2` | failed | `camera_pos=(606.1345,39.32768,125.8137) target=(606.1345,62.87621)` — root cause: sim metres vs ±320 m centred terrain |
| 138 | `v770-shot-windowed-fixed` | **ok** | `screenshot capture source: Screenshot3DViewport/1280x720`; `screenshot saved:`; raw image inspected: perspective terrain, trees, rock, fog/water edge — genuine 3D pixels |
| 143 | `v770-viewport` | ok | mandated full selftest: `passed: true`, 29/29 steps |
| 147 | `v770-selfbase-check` | ok | `SELF-SNAPSHOT fast load parity: OK (320x320, 18 ents, seed 20261113)`; `SELF-SNAPSHOT check: OK` |
| 148 | `v770-selfbase-dump` | ok | `SELF-SNAPSHOT dump round-trip: OK`; fresh dump is `w52-self-base-2` with `"block_rect": Rect2(591.98944, 30.532219, 13.1562, 12.470982)` |
| 153 | `v770-selfbase-fast` | ok | `--self-snapshot` + `--self-only core_movement`: fast load `OK`, restore parity `OK`, report `passed:true` (move/no_overlap/nav_detour) |
| 158, 164, 171 | `v770-main-final-parse`, `v770-main-parse5/6` | ok | final syntax checks after every edit set |
| 166, 168 | `v770-journey3d`, `v770-journey3d-long` | failed | `--journey` idled in menu (journey_mode missing from menu-skip condition); no probe lines — led to the one-line menu-skip fix |
| 173 | `v770-journey3d-probe` | failed (watchdog exit) | `V770_JOURNEY probe mode=3d focus_m=(601.0,43.0032) camera=(281.0,-276.9968)` = focus − (320,320): correct centred 3D target |
| 175 | `v770-journey2d-probe` | failed (watchdog exit) | `mode=2d focus_m=(601.0,43.0032) camera=(9466.934,795.4846) → (9452.139,690.9146)`: lerp toward `focus*16` unchanged |
| 177 | `v770-viewport-final` | ok | final full selftest after all edits: `passed: true`, 29/29 |
| 179 | `v770-shot-windowed-final` | **ok** | final code: `viewport=Screenshot3DViewport image=1280x720 camera_current=true world_parent=Screenshot3DViewport`, `screenshot saved:` — final artifact verified |

Artifacts (outside the workspace, requested path was absolute in the approved temp dir):

- `C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v770_windowed_fixed.png` (ticket 138)
- `C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v770_windowed_final.png` (ticket 179) + `*.raw.png` unfiltered GPU copy for both
- Blank before-fix GPU capture: `.../v770_windowed_diag2.png.raw.png` (flat clear colour, ticket 132)
- Snapshot: `.../v770_self_base.json`, subset report `.../v770_selfonly.json`, 2D config `.../v770_2d_config.json`

### Snapshot before/after (W5-2 regression)

- Before (V7-69 evidence): `variant3d/tests/results/w52_self_base.json:1` `"block_rect":"[P: (591.9894, 30.53222), S: (13.1562, 12.47098)]"` — lossy string, incompatible with canonical `Rect2(591.98944, 30.532219, 13.1562, 12.470982)` at `app/tests/results/w52_self_base.json:19`.
- After (ticket 148 dump, inspected directly): format `w52-self-base-2`, `"block_rect": Rect2(591.98944, 30.532219, 13.1562, 12.470982)` — byte-for-byte the canonical value; round-trip/check/subset all OK.
- Note: the on-disk `variant3d/tests/results/w52_self_base.json` was already a v2 Variant dump when inspected during this ticket (line 19 showed `Rect2(...)`), i.e. another worker had regenerated it; I did not edit that file. The before-value above is V7-69's quoted evidence, not a fresh measurement by me.

## 4. Honest visual-parity verdict

- **VERIFIED (mechanics):** windowed screenshot now contains genuine GPU-rendered 3D pixels (tickets 138, 179). The image shows perspective ground grid, conifers, a rock and a fog/water boundary — not the flat CPU map. `camera_current=true`, `world_parent=Screenshot3DViewport`, source viewport named in stdout. Blank 3D captures now fail loudly; they are never replaced by a 2D map. Headless capture remains CPU-map by design.
- **UNVERIFIED (visual parity to donor):** no donor screenshot comparison was performed; camera FOV/yaw remain port assumptions (`camera3d.gd:32-37`, G31), entities still log `DONOR-SAMPLED FLAT-ROOT MORPH ... NOT DONOR PARITY` (ticket 179 stderr), and the captured frame does not show the town hall/units. Composition/framing parity is therefore not claimed.
- **Headless CI:** impossible to prove 3D pixels in headless runs (no GPU); the fix is windowed-only by construction. No headless screenshot was relabelled as 3D.

## 5. Open questions / residual risk

1. Should `camera3d.gd` own the centred-space conversion instead of `main.gd`'s `_center_camera3d_target()`? The helper freezes `clamp_pos()`'s memo; any future camera edit that unfreezes it would push the focus off-map again. E6 (zoom-at-cursor) and E18/E19 callee work remain outside this file.
2. `--seq` capture (`main.gd:2044-2065`, windowed branch) still uses the root viewport and can fall back to the CPU map. Applying the same SubViewport target there is a follow-up, not part of this ticket.
3. Escape-key/picking jump paths that call `camera3d.jump_to_world(sim metres)` directly would land off-map under the centred convention; `picking3d.gd:64-90` recalibrates its own offset, but the HUD minimap box and `world.view_rect` interaction were not re-measured after the camera seam fix.
4. Journey probe jobs exited 1 only because the in-game watchdog ended a non-terminating journey; the probe lines were captured before exit. No journey-mode assertion exists in `selftest.json`.
5. Exit-time leaks (ObjectDB/resources/GLES3 texture RID) and `anim3d.gd` parse errors seen in ticket 173 are pre-existing/concurrent-work noise, not introduced here.
6. The `journey_mode` addition to the menu-skip condition is a port-side behaviour fix (documented intent at `main.gd:18`); it was required to make a journey frame measurable and does not touch the 2D branch or selftest modes.
