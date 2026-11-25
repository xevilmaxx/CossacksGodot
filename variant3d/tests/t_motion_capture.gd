# VID-CAP-01 — deterministic moving-unit FRAME SEQUENCE capture (3D, 64x64).
#
# Owns ONLY this file (plus docs/coord_swarm_2026-11-25/reports/VID_CAP_01_capture.md).
# No game code, config, manifest, fixture, shader, gate file or git edit.
# No donor copies. No full gates / ladder. CAPTURE ONLY — motion analysis is a
# separate ticket (VID-AN-01); this atom makes no visual-parity claim.
#
# DESIGN CHOICE: real main.tscn boot, not a stub.
#   * The windowed 3D readback path is already MEASURED end-to-end:
#     main.gd:1180-1193 creates `Screenshot3DViewport` (world+camera reparented,
#     UPDATE_ONCE, camera.make_current) and main.gd:1804-1870 reads it back after
#     `await RenderingServer.frame_post_draw` with NO CPU fallback (V7-70 ticket
#     179 / TERRAIN_SMALL ticket 308). A stub would have to duplicate that seam
#     and re-derive the SIM->centred camera convention (camera3d.gd:245-256,
#     423-430), which is a known capture trap.
#   * The real boot also supplies the real sim (game.tick, game.gd:3887), real
#     entity/anim sync (world3d.gd:682-701, world3d_entities.gd:1454-1547) and
#     the real camera, so the sidecar metadata is measured, not reconstructed.
#   * Cost (~20 s boot) is acceptable inside a >=300 s windowed runner job.
#
# Launch (Windows `python`, variant runner ONLY, NO --headless):
#   python variant3d\tools\godot_runner.py run --id vidcap01-frames --timeout 360 -- ^
#     --path variant3d --script res://tests/t_motion_capture.gd -- ^
#     --config <ABS>\variant3d\tests\fixtures\small_map_64.json ^
#     --screenshot C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/vidqa/unused_flag.png ^
#     --timeout 280
#
# `--screenshot` is used ONLY as main's menu-skip flag (main.gd:230,242-244).
# main's own PNG saver is disarmed below; this atom writes every frame itself.
# Raw frames never enter the repo: C:/Users/.../Temp/opencode/vidqa/frame_%03d.png.
extends SceneTree

const MAIN_SCENE := "res://scenes/main.tscn"
const DEFAULT_FIXTURE := "res://tests/fixtures/small_map_64.json"
const OUT_DIR := "res://tests/results"
const FRAME_DIR := "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/vidqa"
const Data = preload("res://scripts/data.gd")

const N_FRAMES := 16             # >=12 required by VIDEO_QA_PROTOCOL.md:32
const FRAME_INTERVAL := 3        # every 3 rendered frames
const SIM_STEP := 1.0 / 32.0     # canonical fixed tick 1/Data.FPS (data.gd:32, main.gd:1557)
const TICKS_PER_CAPTURE := 12    # 0.4 sim-seconds between captured frames
const UNIT_SID := "officer"      # one type, player 0 (friendly)
const PLAYER := 0
const WANT_TILES := 64
const WANT_SEED := 20261113
const BOOT_LIMIT_MS := 120000
const RUN_LIMIT_MS := 240000

var _id := "t_motion_capture"
var _checks: Array[Dictionary] = []
var _ok := true
var _finished := false

var _cfg_arg := ""
var _shot_arg := ""
var _abs_config := ""
var _start_ms := 0
var _main: Node = null
var _game = null
var _world = null
var _cam = null
var _vp: SubViewport = null
var _anim = null

var _units: Array[Dictionary] = []
var _initial_positions: Array = []
var _dest := Vector2.ZERO
var _center := Vector2.ZERO
var _move_calls := 0
var _squad_id := -1
var _rendered_frames := 0
var _frames_meta: Array[Dictionary] = []
var _m: Dictionary = {}


func check(name: String, cond: bool, detail: String) -> void:
	_checks.append({"name": name, "passed": cond, "detail": detail})
	if not cond:
		_ok = false
	print("VIDCAP01 %s %s - %s" % ["PASS" if cond else "FAIL", name, detail])


func _arg_value(flag: String) -> String:
	for src in [OS.get_cmdline_user_args(), OS.get_cmdline_args()]:
		var args := PackedStringArray(src)
		for i in range(args.size()):
			if str(args[i]) == flag and i + 1 < args.size():
				return str(args[i + 1])
	return ""


func _resolve_config(given: String) -> String:
	if given.is_absolute_path():
		return given if FileAccess.file_exists(given) else ""
	var by_res := ProjectSettings.globalize_path("res://").path_join(given)
	if FileAccess.file_exists(by_res):
		return by_res
	if FileAccess.file_exists(given):
		return given
	return ""


func _ensure_dir(path: String) -> bool:
	var err := DirAccess.make_dir_recursive_absolute(path)
	return err == OK or DirAccess.dir_exists_absolute(path)


func _write_text(path: String, text: String) -> bool:
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_error("t_motion_capture: cannot write " + path)
		return false
	f.store_string(text)
	f.close()
	return true


# Same rule as main.gd:1872-1882 — a flat GPU image is never reported as a
# captured 3D frame. Kept local so this atom never edits game code.
func _image_stats(img: Image) -> Dictionary:
	var w := img.get_width()
	var h := img.get_height()
	var first := img.get_pixel(0, 0)
	var first_l := first.get_luminance()
	var varied := false
	var sig: Array[float] = []
	var sum_l := 0.0
	var n := 0
	var step_x := maxi(1, w / 8)
	var step_y := maxi(1, h / 8)
	for yy in range(0, h, step_y):
		for xx in range(0, w, step_x):
			var l := img.get_pixel(xx, yy).get_luminance()
			sum_l += l
			n += 1
			sig.append(snappedf(l, 0.01))
			if l - first_l > 0.02:
				varied = true
	return {
		"w": w,
		"h": h,
		"mean_luma": sum_l / maxf(1.0, float(n)),
		"blank": not varied,
		"signature": sig,
	}


func _skip_capture(reason: String) -> void:
	# Headless guard: SKIP_CAPTURE is written; PASS is explicitly NOT claimed.
	check("headless_guard", false, reason + " (no GPU; windowed job required)")
	_ensure_dir(FRAME_DIR)
	_write_text(FRAME_DIR + "/SKIP_CAPTURE.txt",
		"SKIP_CAPTURE\nreason: " + reason + "\nstatus: SKIP_CAPTURE\npassed: false\n")
	_m["status"] = "SKIP_CAPTURE"
	_m["reason"] = reason
	_finish()


func _abort(reason: String) -> void:
	check("capture_run", false, reason)
	_finish()


func _finish() -> void:
	if _finished:
		return
	_finished = true
	var passes := 0
	for c in _checks:
		if bool(c.get("passed", false)):
			passes += 1
	var status := "CAPTURE_OK" if _ok else "CAPTURE_FAILED"
	if str(_m.get("status", "")) == "SKIP_CAPTURE":
		status = "SKIP_CAPTURE"
	var out := {
		"id": _id,
		"passed": _ok,
		"status": status,
		"passes": passes,
		"total": _checks.size(),
		"checks": _checks,
		"measured": _m,
		"capture_mode": "windowed SubViewport readback after RenderingServer.frame_post_draw",
		"frame_dir": FRAME_DIR,
		"frames_json": FRAME_DIR + "/frames.json" if _frames_meta.size() > 0 else "",
		"frame_count": _frames_meta.size(),
		"analysis_note": "CAPTURE ONLY. Motion analysis is a separate muse-spark ticket (VID-AN-01). No donor parity claim.",
		"script_error_note": "verify via variant3d/tools/smallmap_capture.py scan-stderr on runner stderr.txt",
		"unix_ms": Time.get_unix_time_from_system() * 1000.0,
	}
	var abs_dir := ProjectSettings.globalize_path(OUT_DIR)
	_ensure_dir(abs_dir)
	var path := "%s/%s.json" % [abs_dir, _id]
	_write_text(path, JSON.stringify(out, "\t"))
	print("VIDCAP01 RESULT_JSON: " + path)
	print("VIDCAP01 RESULT: %s %s %d/%d" % [status, "PASS" if _ok else "FAIL", passes, _checks.size()])
	print("VIDCAP01 STDERR_SCAN_REQUIRED (runner stderr.txt)")
	call_deferred("quit", 0 if _ok else 1)


func _clear_sim_entities() -> void:
	# Isolate the four spawned units; the full generator otherwise leaves
	# hundreds of units/buildings that would dominate the frame.
	_game.entities.clear()
	_game.by_id.clear()
	_game.live_units.clear()
	_game.live_blds.clear()
	_game.grid.clear()
	_game.events.clear()
	_game.set("squads", {})
	_game.set("projectiles", [])
	_game.set("corpses", [])
	_game.set("rubble", [])
	_game.set("winner", -1)
	_game.set("paused", false)
	for p in _game.players:
		p["entities"] = []
	# These three are per-player arrays of arrays (game.gd:145-147); spawn()
	# indexes officers[player] directly (game.gd:2034), so keep both slots.
	_game.set("officers", [[], []])
	_game.set("drummers", [[], []])
	_game.set("priests", [[], []])
	_game.next_id = 10


func _unit_meta(e: Dictionary) -> Dictionary:
	var pos: Vector2 = e.get("pos", Vector2.ZERO)
	var face := float(e.get("face", 0.0))
	var action := "idle"
	if bool(e.get("moving", false)):
		action = "walk"
	var pose: Dictionary = {}
	if _anim != null and _anim.has_method("pose_for"):
		var pv = _anim.call("pose_for", e, action, float(_m.get("anim_clock_s", 0.0)))
		if pv is Dictionary:
			var pd: Dictionary = pv
			pose = {
				"action": str(pd.get("action", "")),
				"frame": int(pd.get("frame", -1)),
				"donor": str(pd.get("donor", "")),
				"pose_source": str(pd.get("pose_source", "")),
				"visual": str(pd.get("visual", "UNVERIFIED")),
			}
	return {
		"id": int(e.get("id", -1)),
		"sid": str(e.get("sid", "")),
		"player": int(e.get("player", -1)),
		"pos_sim_m": [pos.x, pos.y],
		"face_rad": face,
		"azimuth_deg": rad_to_deg(face),
		"moving": bool(e.get("moving", false)),
		"order": str((e.get("order", {}) as Dictionary).get("type", "")),
		"pose": pose,
	}


func _camera_meta() -> Dictionary:
	var cam_pos: Vector3 = _cam.global_position if _cam != null else Vector3.ZERO
	var target: Vector2 = _cam.get("_target") if _cam != null else Vector2.ZERO
	var current := false
	if _cam != null and _cam.get_viewport() != null:
		current = _cam.get_viewport().get_camera_3d() == _cam
	return {
		"target_sim_m": [target.x, target.y],
		"position_world_m": [cam_pos.x, cam_pos.y, cam_pos.z],
		"zoom": float(_cam.get("zoom")) if _cam != null else -1.0,
		"height_m": float(_cam.get("height")) if _cam != null else -1.0,
		"viewport": _vp.name if _vp != null else "<none>",
		"camera_current": current,
	}


func _configure() -> bool:
	_game = _main.get("game")
	_world = _main.get("world")
	_cam = _main.get("camera")
	_vp = _main.get("capture_view3d") as SubViewport
	var boot_ok := (_game != null and _world != null and _cam != null and _vp != null
		and str(_main.get("render_mode")).to_lower() == "3d"
		and int(_game.get("MAP_W")) == WANT_TILES and int(_game.get("MAP_H")) == WANT_TILES
		and int(Data.RANDOM_SEED) == WANT_SEED)
	_m["boot_render_mode"] = str(_main.get("render_mode"))
	_m["boot_map_tiles"] = [int(_game.get("MAP_W")), int(_game.get("MAP_H"))] if _game != null else []
	_m["boot_seed"] = int(Data.RANDOM_SEED)
	check("real_game_boot", boot_ok,
		"render_mode=%s map=%s seed=%d" % [str(_main.get("render_mode")),
		str(_m["boot_map_tiles"]), int(Data.RANDOM_SEED)])
	if not boot_ok:
		return false

	var vps := Vector2i(0, 0)
	if _vp != null:
		vps = _vp.size
	check("capture_viewport_ready", _vp != null and vps.x == 1280 and vps.y == 720,
		"viewport=%s size=%dx%d" % [_vp.name if _vp != null else "<none>", vps.x, vps.y])
	if _vp == null:
		return false

	# Freeze the main loop's automatic stepping and its own screenshot saver.
	# main.gd:1543 returns early when ais is empty, so no game.tick/world.sync
	# and no main-side quit can happen while this atom drives the sim.
	var ais = _main.get("ais")
	if ais is Array:
		(ais as Array).clear()
	_main.set("speed", 0.0)
	_main.set("acc", 0.0)
	_main.set("screenshot_frames", 1000000)
	_main.set("screenshot_done", true)
	var frozen := (absf(float(_main.get("speed"))) < 0.0001
		and (_main.get("ais") is Array) and (_main.get("ais") as Array).is_empty())
	_m["main_speed"] = float(_main.get("speed"))
	_m["main_ais_count"] = (_main.get("ais") as Array).size() if _main.get("ais") is Array else -1
	check("sim_clock_frozen", frozen,
		"speed=%f ais=%d; sim advanced only by atom-side fixed ticks" % [
			float(_main.get("speed")), _m["main_ais_count"]])
	if not frozen:
		return false

	_clear_sim_entities()
	_center = Vector2(float(WANT_TILES), float(WANT_TILES)) * Data.TILE_M * 0.5
	var offsets: Array = [Vector2(-3.0, -2.0), Vector2(3.0, -2.0),
		Vector2(-3.0, 2.0), Vector2(3.0, 2.0)]
	_units = []
	_initial_positions = []
	for off in offsets:
		var p: Vector2 = _center + off
		_initial_positions.append([p.x, p.y])
		_units.append(_game.spawn(UNIT_SID, PLAYER, p))
	var same_type := true
	var friendly := true
	for e in _units:
		if str(e.get("sid", "")) != UNIT_SID or str(e.get("kind", "")) != "unit":
			same_type = false
		if int(e.get("player", -1)) != PLAYER:
			friendly = false
	check("four_friendly_units", _units.size() == 4 and same_type and friendly,
		"count=%d sid=%s player=%d ids=%s" % [_units.size(), UNIT_SID, PLAYER,
		str(_game.entities.size())])
	if _units.size() != 4 or not same_type or not friendly:
		return false
	_m["units_initial_sim"] = _initial_positions
	_m["unit_sid"] = UNIT_SID

	# ONE group move order: 4 same-type units form one squad, so a single
	# cmd_move(officer, dest) propagates to every member (game.gd:3283-3310).
	_dest = _center + Vector2(14.0, 5.0)
	var sq: Dictionary = _game.squad_form(_units)
	if not sq.is_empty():
		_squad_id = int(sq.get("squad_id", -1))
		_game.cmd_move(_units[0], _dest)
		_move_calls = 1
	else:
		# Honest fallback so the capture still has motion if squad_form is
		# unavailable in this build; recorded in the sidecar and result JSON.
		for e in _units:
			_game.cmd_move(e, _dest)
			_move_calls += 1
	var all_ordered := true
	for e in _units:
		if str((e.get("order", {}) as Dictionary).get("type", "")) != "move":
			all_ordered = false
	_m["move_dest_sim"] = [_dest.x, _dest.y]
	_m["move_calls"] = _move_calls
	_m["squad_id"] = _squad_id
	_m["sim_time_at_order_s"] = float(_game.get("time_s"))
	check("one_move_order", all_ordered,
		"cmd_move calls=%d, squad_id=%d, dest=%s, all 4 have move order=%s" % [
			_move_calls, _squad_id, str(_m["move_dest_sim"]), str(all_ordered)])
	if not all_ordered:
		return false

	# Fixed camera: aim at the spawn centroid and snap to the closest donor
	# height (camera3d.gd:189-195,626-634). No camera motion during capture.
	_cam.call("jump_to_world", _center)
	var max_zoom := float(_cam.get("max_zoom"))
	_cam.call("set_zoom_target", max_zoom, true)
	# camera3d.gd:_process() keeps applying edge-scroll/clamp smoothing even
	# with no input; disable it after the snap so the camera pose is FIXED for
	# the whole sequence (VIDEO_QA_PROTOCOL.md:32).
	_cam.set_process(false)
	_m["camera_zoom"] = max_zoom
	_m["camera_process_enabled"] = bool(_cam.is_processing())
	_m["camera_meta_at_order"] = _camera_meta()
	_anim = _world.get("anim")
	_world.sync(0.0)
	return true


func _capture_all() -> void:
	for i in range(N_FRAMES):
		if Time.get_ticks_msec() - _start_ms > RUN_LIMIT_MS:
			_abort("capture deadline exceeded at frame %d" % i)
			return
		# Deterministic fixed-step sim; no wall-clock dt feeds the sim here.
		# The cleared AI player has no entities, so game._check_victory() can
		# set `winner` and make tick() a no-op; clear it before each fixed step
		# so all TICKS_PER_CAPTURE ticks really run (harness-only clock control).
		for _t in range(TICKS_PER_CAPTURE):
			_game.set("winner", -1)
			_game.set("paused", false)
			_game.tick(SIM_STEP)
		var dt := float(TICKS_PER_CAPTURE) * SIM_STEP
		_world.sync(dt)
		# FRAME_INTERVAL rendered frames between captures; the last one is the
		# UPDATE_ONCE readback frame, matching main.gd:1804-1806.
		for _j in range(FRAME_INTERVAL - 1):
			await RenderingServer.frame_post_draw
			_rendered_frames += 1
		_vp.render_target_update_mode = SubViewport.UPDATE_ONCE
		await RenderingServer.frame_post_draw
		_rendered_frames += 1

		if not is_instance_valid(_vp):
			_abort("capture viewport gone at frame %d" % i)
			return
		var img: Image = _vp.get_texture().get_image()
		var stats := _image_stats(img) if img != null and not img.is_empty() else {"blank": true}
		var retries := 0
		# UPDATE_ONCE can occasionally be sampled before the render lands. A
		# transparent/flat read is retried with a fresh UPDATE_ONCE pass; a
		# genuinely blank frame still fails loudly (no CPU fallback, ever).
		while bool(stats.get("blank", true)) and retries < 4:
			_vp.render_target_update_mode = SubViewport.UPDATE_ONCE
			await RenderingServer.frame_post_draw
			_rendered_frames += 1
			img = _vp.get_texture().get_image()
			stats = _image_stats(img) if img != null and not img.is_empty() else {"blank": true}
			retries += 1
		if img == null or img.is_empty() or bool(stats.get("blank", true)):
			_abort("flat/blank 3D image at frame %d after %d retries (no CPU fallback)" % [i, retries])
			return
		_m["blank_read_retries"] = int(_m.get("blank_read_retries", 0)) + retries
		var name := "frame_%03d.png" % i
		var path := FRAME_DIR + "/" + name
		img.save_png(path)
		var ents = _world.get("entities")
		var ac := 0.0
		if ents != null:
			var st = ents.get("stats")
			if st is Dictionary:
				ac = float((st as Dictionary).get("anim_clock_s", -1.0))
		_m["anim_clock_s"] = ac
		var umeta: Array[Dictionary] = []
		for e in _units:
			umeta.append(_unit_meta(e))
		var frame_meta := {
			"frame": i,
			"png": name,
			"png_abs": path,
			"bytes": -1,
			"rendered_frame_index": _rendered_frames,
			"sim_time_s": float(_game.get("time_s")),
			"anim_clock_s": ac,
			"units": umeta,
			"camera": _camera_meta(),
			"image": stats,
		}
		# byte size without a second parse of the PNG text
		var f := FileAccess.open(path, FileAccess.READ)
		if f != null:
			frame_meta["bytes"] = f.get_length()
			f.close()
		_frames_meta.append(frame_meta)
		print("VIDCAP01 FRAME %02d/%02d sim=%.3fs rendered=%d pos0=%s bytes=%d" % [
			i + 1, N_FRAMES, float(_game.get("time_s")), _rendered_frames,
			str(umeta[0].get("pos_sim_m", [])), int(frame_meta["bytes"])])

	check("frames_captured", _frames_meta.size() >= 12,
		"captured=%d (required >=12), rendered_frames=%d, interval=%d" % [
			_frames_meta.size(), _rendered_frames, FRAME_INTERVAL])
	var all_nonblank := true
	var sigs: Dictionary = {}
	for fm in _frames_meta:
		var im: Dictionary = fm.get("image", {})
		if bool(im.get("blank", true)):
			all_nonblank = false
		sigs[str(im.get("signature", []))] = true
	check("frames_nonblank", all_nonblank,
		"blank frames=%d of %d" % [0 if all_nonblank else 1, _frames_meta.size()])
	check("frames_distinct", sigs.size() > 1,
		"distinct image signatures=%d of %d (factual only; no motion verdict)" % [
			sigs.size(), _frames_meta.size()])
	_m["distinct_image_signatures"] = sigs.size()
	_m["rendered_frames"] = _rendered_frames

	if _frames_meta.size() > 0:
		var fdata := {
			"format": "vidcap01-frames-1",
			"id": "vidcap01-frames",
			"capture": "windowed Screenshot3DViewport readback after RenderingServer.frame_post_draw",
			"config": _abs_config,
			"frame_interval_rendered_frames": FRAME_INTERVAL,
			"sim_step_s": SIM_STEP,
			"ticks_per_capture": TICKS_PER_CAPTURE,
			"unit_sid": UNIT_SID,
			"units_initial_sim": _initial_positions,
			"move_destination_sim": [_dest.x, _dest.y],
			"move_calls": _move_calls,
			"analysis_note": "CAPTURE ONLY - no donor parity or motion verdict in this file",
			"frames": _frames_meta,
		}
		var ok_json := _write_text(FRAME_DIR + "/frames.json", JSON.stringify(fdata, "\t"))
		check("frames_json_written", ok_json, FRAME_DIR + "/frames.json")
		_m["frames_json"] = FRAME_DIR + "/frames.json"


func _initialize() -> void:
	if _finished:
		return
	_start_ms = Time.get_ticks_msec()
	if DisplayServer.get_name() == "headless":
		_skip_capture("DisplayServer is headless")
		return

	_cfg_arg = _arg_value("--config")
	_shot_arg = _arg_value("--screenshot")
	if _cfg_arg == "" or _shot_arg == "":
		_abort("need --config <small_map_64.json> and --screenshot <flag> user args")
		return
	_abs_config = _resolve_config(_cfg_arg)
	if _abs_config == "":
		_abort("config fixture not found: " + _cfg_arg)
		return
	_m["config"] = _abs_config
	_m["screenshot_flag"] = _shot_arg
	_m["display_server"] = DisplayServer.get_name()
	_ensure_dir(FRAME_DIR)

	# Fixture guard, read before boot (the real main.gd applies the same file).
	var f := FileAccess.open(_abs_config, FileAccess.READ)
	if f == null:
		_abort("cannot read fixture " + _abs_config)
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if not (parsed is Dictionary) or not ((parsed as Dictionary).get("gameplay", {}) is Dictionary):
		_abort("fixture is not a JSON object with gameplay")
		return
	var gp: Dictionary = (parsed as Dictionary).get("gameplay", {})
	var fixture_ok := (int(gp.get("map_width_tiles", 0)) == WANT_TILES
		and int(gp.get("map_height_tiles", 0)) == WANT_TILES
		and str(gp.get("render_mode", "")).to_lower() == "3d"
		and int(gp.get("random_seed", -1)) == WANT_SEED)
	check("fixture_64_3d", fixture_ok,
		"fixture=%dx%d mode=%s seed=%d" % [int(gp.get("map_width_tiles", 0)),
			int(gp.get("map_height_tiles", 0)), str(gp.get("render_mode", "")),
			int(gp.get("random_seed", -1))])
	if not fixture_ok:
		return

	var packed := load(MAIN_SCENE) as PackedScene
	if packed == null:
		_abort("cannot load " + MAIN_SCENE)
		return
	_main = packed.instantiate()
	root.add_child(_main)

	# Under a custom SceneTree main loop the child scene's _ready() is delivered
	# once the loop starts (t_smallmap_terrain.gd:220-223). Await real frames
	# until game + SubViewport exist, with a hard local deadline.
	var ready := false
	for _i in range(240):
		await RenderingServer.frame_post_draw
		if _main != null and is_instance_valid(_main) \
				and _main.get("game") != null and _main.get("capture_view3d") != null:
			ready = true
			break
		if Time.get_ticks_msec() - _start_ms > BOOT_LIMIT_MS:
			break
	if not ready:
		_abort("real game boot did not expose game + capture_view3d in time")
		return
	_m["boot_wall_ms"] = Time.get_ticks_msec() - _start_ms

	if not _configure():
		_finish()
		return
	await _capture_all()
	_finish()
