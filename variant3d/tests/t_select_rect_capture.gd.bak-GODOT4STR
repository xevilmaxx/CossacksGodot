# G01 / WAVE-G — selection-marquee WINDOWED CAPTURE atom for variant3d.
#
# Owns ONLY this file (NEW). No game code, config, manifest, fixture, gate,
# runner job, result JSON or PNG was created or edited by the author. AUTHORING
# ONLY: no Godot process was started; this atom has NOT been run.
#
# Built from D03_selection_probe.md §4 "proposed atom", itself derived from the
# proven t_select_rect.gd skeleton. ALL 24 original check() sites are retained
# (same names, same thresholds 6.0 px / 0.005 m, same expected_pre_fix_failure
# markers). Only ADDITIVE checks and capture stages are appended. No assertion,
# threshold or marker is weakened (CHARTER §3; D03 §8 item 12).
#
# What this adds over t_select_rect.gd (which asserted NO pixel):
#   * A real 64x64 3D boot with FOUR peasants [10..13] + ONE player-0 building
#     [14], all inside the windowed 1280x720 camera view.
#   * THREE real windowed PNGs: BASELINE (before), DURING drag (LMB still held),
#     AFTER release, all read back from main.capture_view3d's SubViewport texture.
#   * Decisive pixel assertions: visible / position / colour / no-fill / hidden,
#     plus a logic-vs-raster cross-check of the live overlay Rect2.
#
# THE TWO TRAPS (D03 §3) — both handled explicitly:
#   Trap A: main.gd:1240-1253 reparents ONLY world + camera into
#     Screenshot3DViewport; input_ctl (and its SelectionRectOverlay) stays in
#     the root viewport. A verbatim capture_view3d.get_texture() would show NO
#     marquee and read as a false negative. This atom therefore reparents the
#     LIVE `sel_rect_overlay` node into _main.capture_view3d during configure,
#     and asserts + records the resulting parent in the result JSON.
#   Trap B: the root-window backbuffer reads blank under gl_compatibility
#     (main.gd:1235-1238,1861-1863). Only the SubViewport texture path is used;
#     root.get_texture() is NEVER substituted. A null/empty/blank frame fails
#     loudly, never a CPU fallback and never a fake PASS.
#   Trap C: main's saver fires on a frame counter and quits (main.gd:1730-1732,
#     1930); we set screenshot_frames=1000000 / screenshot_done=true and use our
#     own get_image() + _write_bytes() through main's proven saver helper.
#   Trap D: headless => literal SKIP_CAPTURE, passed=false, quit 1. No fake PASS.
#
# D03's capture helper awaited RenderingServer.frame_post_draw twice. Its two
# awaits are implemented here as TWO _process() stage frames per capture
# (set UPDATE_ONCE -> advance 2 frames -> read back). _process() MUST stay
# synchronous: an await would replace its `bool` return with a coroutine object,
# which SceneTree would read as "quit". Same guarantee, no semantic change.
#
# All sample points/colours/paths are written to the result JSON so a second
# agent can reproduce the pixel reading without rerunning Godot.
#
# PARITY LABEL: PORT APPROXIMATION — internal visual evidence only. No donor
# GPU A/B frame exists under this charter; donor parity stays UNVERIFIED.
#
# Launch form (NOT run by the author; G04 is the sole runner owner):
#   python variant3d\tools\godot_runner.py run --id g01-selquad-cap1 --timeout 300 -- `
#     --path variant3d --script res://tests/t_select_rect_capture.gd -- `
#     --config <ABS>\variant3d\tests\fixtures\small_map_64.json `
#     --screenshot <TEMP>\d03_selquad_menu_skip.png
# Result: res://tests/results/t_select_rect_capture.json
extends SceneTree

const MAIN_SCENE := "res://scenes/main.tscn"
const DEFAULT_FIXTURE := "res://tests/fixtures/small_map_64.json"  # documented, unused
const OUT_DIR := "res://tests/results"
const Data = preload("res://scripts/data.gd")
const ConfigScript = preload("res://scripts/config.gd")

# DSEL-01 claim 1 / onmousemove.inc:32-34 (donor) vs input_controller.gd:613,662-663 (port).
const DONOR_EPSILON_M := 0.005
const PORT_DRAG_PX := 6.0

const CAPTURE_W := 1280
const CAPTURE_H := 720
const PIXEL_TOL_BASELINE := 8.0 / 255.0
const PIXEL_TOL_COLOUR := 16.0 / 255.0
# With the default marquee [1,1,0,1] these are D03 §4.4's exact predicates:
# r >= 0.85, g >= 0.85, b <= 0.25, a >= 0.9. They follow the configured colour.
const MARQUEE_IS_R_TOL := 0.15
const MARQUEE_IS_B_TOL := 0.25
const MARQUEE_IS_A_TOL := 0.10

var _id := "t_select_rect_capture"
var _checks: Array[Dictionary] = []
var _ok := true
var _finished := false
var _stage := 0
var _stage_frames := 0
var _run_mode := "windowed_real_input"  # "headless_skip" | "windowed_real_input"

var _cfg_arg := ""
var _shot_arg := ""
var _abs_config := ""
var _capture_dir := ""
var _main: Node = null
var _game = null            # C3Game, real booted sim
var _spy = null             # CmdSpy, C3Game subclass, installed on input_ctl only
var _world = null
var _cam = null
var _hud = null
var _ictl = null
var _picker = null
var _ov = null              # LIVE SelectionRectOverlay (reparented into capture_view3d)

var _u10: Dictionary = {}
var _u11: Dictionary = {}
var _u12: Dictionary = {}
var _u13: Dictionary = {}
var _bld: Dictionary = {}

var _p0 := Vector2.INF
var _p1 := Vector2.INF
var _p_click := Vector2.INF
var _g0 := Vector2.INF
var _g1 := Vector2.INF
var _overlay_during: Dictionary = {}
var _overlay_after: Dictionary = {}
var _m: Dictionary = {}

var _cap_before: Dictionary = {}
var _cap_during: Dictionary = {}
var _cap_after: Dictionary = {}
var _img_before: Image = null
var _img_during: Image = null
var _img_after: Image = null

var _marquee_col: Array = [1, 1, 0, 1]
var _marquee_width := 1
var _marquee_override_declared := false
var _pixel_samples: Dictionary = {}
var _during_yellow: Array[Dictionary] = []

var _ov_during_rect := Rect2()
var _ov_during_visible := false
var _ov_after_rect := Rect2()
var _ov_after_visible := false

# ---------------------------------------------------------------------------
# cmd_* spy. Extends C3Game so the typed `var game: C3Game` on C3Input
# (input_controller.gd:9) accepts it. Only cmd_* methods are overridden; every
# non-cmd field is copied by reference from the real booted game, so the drag
# and pick paths still operate on the live sim dictionaries.
# Signatures mirror game.gd:2152,2839-2999,3124,3157,4187-4247.
# ---------------------------------------------------------------------------
class CmdSpy extends C3Game:
	var calls: Dictionary = {}

	func _bump(n: String) -> void:
		calls[n] = int(calls.get(n, 0)) + 1

	func total() -> int:
		var n := 0
		for v in calls.values():
			n += int(v)
		return n

	func cmd_sow(mill: Dictionary) -> int:
		_bump("cmd_sow")
		return 0

	func cmd_move(e: Dictionary, pos: Vector2) -> void:
		_bump("cmd_move")

	func cmd_attack(e: Dictionary, target: Dictionary) -> void:
		_bump("cmd_attack")

	func cmd_attack_move(e: Dictionary, pos: Vector2) -> void:
		_bump("cmd_attack_move")

	func cmd_gather(e: Dictionary, res_node: Dictionary) -> void:
		_bump("cmd_gather")

	func cmd_resow(e: Dictionary, node: Dictionary) -> void:
		_bump("cmd_resow")

	func cmd_build(e: Dictionary, site: Dictionary) -> void:
		_bump("cmd_build")

	func cmd_stand_ground(e: Dictionary) -> void:
		_bump("cmd_stand_ground")

	func cmd_no_stand_ground(e: Dictionary) -> void:
		_bump("cmd_no_stand_ground")

	func cmd_hold_fire(e: Dictionary, on: bool) -> void:
		_bump("cmd_hold_fire")

	func cmd_engage(e: Dictionary) -> void:
		_bump("cmd_engage")

	func cmd_stop(e: Dictionary) -> void:
		_bump("cmd_stop")

	func cmd_guard(e: Dictionary, target: Dictionary) -> void:
		_bump("cmd_guard")

	func cmd_cancel_guard(e: Dictionary) -> void:
		_bump("cmd_cancel_guard")

	func cmd_patrol(e: Dictionary, a: Vector2, b: Vector2) -> void:
		_bump("cmd_patrol")

	func cmd_attack_ground(e: Dictionary, pos: Vector2) -> void:
		_bump("cmd_attack_ground")

	func cmd_enter(e: Dictionary, b: Dictionary) -> void:
		_bump("cmd_enter")

	func cmd_unload(b: Dictionary) -> void:
		_bump("cmd_unload")

	func cmd_replenish(off: Dictionary) -> int:
		_bump("cmd_replenish")
		return 0

	func cmd_form_size(off: Dictionary, size: int) -> void:
		_bump("cmd_form_size")

	func cmd_make_gate(w: Dictionary) -> void:
		_bump("cmd_make_gate")

	func cmd_gate_toggle(g: Dictionary) -> void:
		_bump("cmd_gate_toggle")

	func cmd_repair(pe: Dictionary, b: Dictionary) -> void:
		_bump("cmd_repair")

	func cmd_delete(e: Dictionary) -> void:
		_bump("cmd_delete")


func check(name: String, cond: bool, detail: String = "", expected_pre_fix_failure: bool = false) -> void:
	_checks.append({
		"name": name,
		"passed": cond,
		"detail": detail,
		"expected_pre_fix_failure": expected_pre_fix_failure,
	})
	if not cond:
		_ok = false
	print("T_SELECT_RECT_CAPTURE %s %s - %s%s" % ["PASS" if cond else "FAIL", name, detail,
		" [EXPECTED_FAILURE_PRE_FIX]" if expected_pre_fix_failure else ""])


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


func _goto(s: int) -> void:
	_stage = s
	_stage_frames = 0


func _finish() -> void:
	if _finished:
		return
	_finished = true
	var passes := 0
	for c in _checks:
		if bool(c.get("passed", false)):
			passes += 1
	var cap_desc := ""
	if _run_mode == "headless_skip":
		cap_desc = "SKIP_CAPTURE (headless): real-input drag and all three PNG assertions require windowed mode; no fake PASS"
	else:
		cap_desc = "windowed real-input: three PNGs from main.capture_view3d SubViewport texture"
	var out := {
		"id": _id,
		"passed": _ok,
		"passes": passes,
		"total": _checks.size(),
		"checks": _checks,
		"measured": _m,
		"capture_path": cap_desc,
		"captures": {
			"before": _cap_before,
			"during": _cap_during,
			"after": _cap_after,
		},
		"capture_dir": _capture_dir,
		"overlay_parent": str(_m.get("overlay_parent", "")),
		"overlay_parent_is_capture_view3d": bool(_m.get("overlay_parent_is_capture_view3d", false)),
		"marquee_color": _marquee_col,
		"marquee_width_px": _marquee_width,
		"marquee_override_declared": _marquee_override_declared,
		"pixel_samples": _pixel_samples,
		"during_yellow_hits": _during_yellow,
		"run_mode": _run_mode,
		"donor_semantics": {
			"world_epsilon_m": DONOR_EPSILON_M,
			"drag_start": "first LMB-held move (DSEL-01 claim 3)",
			"shift": "add / spmAdd (DSEL-01 claim 4) — port drag ignores Shift (claim 27); declared divergence, not asserted here",
			"port_screen_threshold_px": PORT_DRAG_PX,
			"drag_crosses_both": true,
		},
		"capture_method": "SubViewport texture path ONLY (main.capture_view3d); root-window texture rejected under gl_compatibility (Trap B)",
		"runner_declaration": "G01/WAVE-G: to be executed by G04 (sole runner owner), windowed, unique job id; see D03_selection_probe.md §5/§8",
		"parity_label": "PORT APPROXIMATION — internal visual evidence only; no donor GPU A/B frame; donor parity UNVERIFIED",
		"unix_ms": Time.get_unix_time_from_system() * 1000.0,
	}
	var abs_dir := ProjectSettings.globalize_path(OUT_DIR)
	DirAccess.make_dir_recursive_absolute(abs_dir)
	var path := "%s/%s.json" % [abs_dir, _id]
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(out, "\t"))
		f.close()
	else:
		push_error("t_select_rect_capture: cannot write " + path)
	print("T_SELECT_RECT_CAPTURE RESULT_JSON: " + path)
	print("T_SELECT_RECT_CAPTURE RESULT: %s %d/%d" % ["PASS" if _ok else "FAIL", passes, _checks.size()])
	print("T_SELECT_RECT_CAPTURE STDERR_SCAN_REQUIRED (runner stderr.txt)")
	call_deferred("quit", 0 if _ok else 1)


func _abort(reason: String) -> void:
	check("boot_and_setup", false, reason)
	_finish()


func _initialize() -> void:
	# Trap D: headless root is 64x64 while camera projection is 1280x720, so
	# Input.parse_input_event never reaches _unhandled_input (CAM-RV-01:159-166,
	# SEL-01 probe 324). Literal SKIP_CAPTURE, passed=false, exit 1. No fake PASS.
	if DisplayServer.get_name() == "headless":
		_run_mode = "headless_skip"
		_abort("SKIP_CAPTURE: windowed real-input drag + three windowed PNGs required; headless root viewport is 64x64 while camera projection is 1280x720, so Input.parse_input_event cannot reach _unhandled_input (CAM-RV-01:159-166, SEL-01 probe 324). No fake PASS.")
		return
	_run_mode = "windowed_real_input"
	_cfg_arg = _arg_value("--config")
	_shot_arg = _arg_value("--screenshot")
	if _cfg_arg == "" or _shot_arg == "":
		_abort("need --config <small_map_64.json> and --screenshot <path> user args (menu skip)")
		return
	_abs_config = _resolve_config(_cfg_arg)
	if _abs_config == "":
		_abort("config fixture not found: " + _cfg_arg)
		return
	# Write the three unique PNGs beside the menu-skip flag path (G04 passes a
	# unique Temp folder); never reuse an S1 filename (RECHECK_S1.md:121-130).
	var shot_dir := _shot_arg.get_base_dir()
	if shot_dir == "" or not shot_dir.is_absolute_path():
		shot_dir = OS.get_user_data_dir()
	_capture_dir = shot_dir
	_m["config"] = _abs_config
	_m["screenshot_arg"] = _shot_arg
	_m["capture_dir"] = _capture_dir
	_m["headless"] = DisplayServer.get_name() == "headless"  # windowed real-input path
	var packed := load(MAIN_SCENE) as PackedScene
	if packed == null:
		_abort("cannot load " + MAIN_SCENE)
		return
	_main = packed.instantiate()
	root.add_child(_main)
	_goto(0)  # wait for scene _ready / full 3D boot before inspecting


func _clear_entities() -> void:
	_game.entities.clear()
	_game.by_id.clear()
	_game.live_units.clear()
	_game.live_blds.clear()
	_game.grid.clear()
	_game.events.clear()
	for p in _game.players:
		p["entities"] = []
	for key in ["officers", "drummers", "priests"]:
		var arr = _game.get(key)
		if arr is Array:
			arr.clear()


func _project_sim(sim: Vector2) -> Vector2:
	# camera3d.world_to_px()/unproject_position() take CENTRED world metres;
	# e.pos is SIM top-left metres. One subtraction, as in camera3d.gd:222-229,246.
	var half := Vector2(float(_game.get("MAP_W")), float(_game.get("MAP_H"))) * Data.TILE_M * 0.5
	var centred := sim - half
	return _cam.unproject_position(Vector3(centred.x, 0.0, centred.y))


func _to_event_coord(p: Vector2) -> Vector2:
	# Input.parse_input_event() delivers ev.position in ROOT-WINDOW viewport
	# coordinates, while camera3d.unproject_position() returns pixels in the
	# camera's projection viewport. Identity at windowed 1280x720 (CAM-RV-01
	# job 381); both viewports and the scale are asserted in _configure().
	var proj: Vector2 = Vector2(_cam.get_viewport().size)
	var win: Vector2 = Vector2(root.size)
	_m["projection_viewport_px"] = [proj.x, proj.y]
	_m["root_viewport_px"] = [win.x, win.y]
	_m["event_coord_scale"] = [win.x / proj.x if proj.x > 0.0 else -1.0,
		win.y / proj.y if proj.y > 0.0 else -1.0]
	if proj.x <= 0.0 or proj.y <= 0.0 or win.x <= 0.0 or win.y <= 0.0:
		return p
	return Vector2(p.x * win.x / proj.x, p.y * win.y / proj.y)


func _marquee_differs_from_default(col: Array, width: int) -> bool:
	# C3Config.DEFAULT itself declares [1,1,0,1]/1, so mere key presence is not
	# an override. Record an override only when the ACTIVE values differ from
	# the documented donor-marquee default (config.gd:50-51,431-436).
	return col != [1, 1, 0, 1] or width != 1


func _configure() -> bool:
	_game = _main.get("game")
	_cam = _main.get("camera")
	_world = _main.get("world")
	_hud = _main.get("hud")
	_ictl = _main.get("input_ctl")
	var boot_ok := (_game != null and _cam != null and _world != null
		and _hud != null and _ictl != null
		and str(_main.get("render_mode")).to_lower() == "3d"
		and int(_game.get("MAP_W")) == 64 and int(_game.get("MAP_H")) == 64)
	check("boot_real_64_3d_game", boot_ok,
		"render_mode=%s MAP=%sx%s" % [str(_main.get("render_mode")),
		str(_game.get("MAP_W")) if _game != null else "?", str(_game.get("MAP_H")) if _game != null else "?"])
	if not boot_ok:
		return false

	# --screenshot hides the HUD (main.gd:1096-1097); restore it for real input.
	_hud.visible = true
	check("hud_visible", bool(_hud.visible), "hud.visible restored after --screenshot boot")
	# Stop the savers/AI so main cannot quit or retarget the camera mid-drag
	# (Trap C: main.gd:1730-1732,1930 must never fire during our three captures).
	_main.set("screenshot_frames", 1000000)
	_main.set("screenshot_done", true)
	var ais = _main.get("ais")
	if ais is Array:
		ais.clear()
	_main.set("speed", 0.0)

	# Proven CAM-RV-01 job 381 setup: focus map centre, freeze edge scroll.
	_cam.call("jump_to_world", Vector2(float(_game.get("MAP_W")), float(_game.get("MAP_H"))) * Data.TILE_M * 0.5)
	_cam.edge_margin = 0.0
	_cam.corner_margin = 0.0
	_m["camera_target_after_jump"] = str(_cam.get("_target"))

	# Windowed capture integrity: both viewports 1280x720, event scale [1,1].
	# Never "fix" coordinates — abort if the geometry is not the proven pose.
	var proj_px: Vector2 = Vector2(_cam.get_viewport().size)
	var root_px: Vector2 = Vector2(root.size)
	var cv: Variant = _main.get("capture_view3d")
	var cv_px := Vector2(-1, -1)
	if cv is SubViewport:
		cv_px = Vector2((cv as SubViewport).size)
	var geom_ok := (int(proj_px.x) == CAPTURE_W and int(proj_px.y) == CAPTURE_H
		and int(root_px.x) == CAPTURE_W and int(root_px.y) == CAPTURE_H
		and int(cv_px.x) == CAPTURE_W and int(cv_px.y) == CAPTURE_H)
	_m["projection_viewport_px"] = [proj_px.x, proj_px.y]
	_m["root_viewport_px"] = [root_px.x, root_px.y]
	_m["capture_view3d_px"] = [cv_px.x, cv_px.y]
	_m["event_coord_scale"] = [root_px.x / proj_px.x if proj_px.x > 0.0 else -1.0,
		root_px.y / proj_px.y if proj_px.y > 0.0 else -1.0]
	check("windowed_capture_geometry", geom_ok,
		"projection=%s root=%s capture_view3d=%s scale=%s" % [str(proj_px), str(root_px),
		str(cv_px), str(_m["event_coord_scale"])])
	if not geom_ok:
		return false

	# Trap A FIX (harness-only, no game code edit): reparent the LIVE overlay
	# into main.capture_view3d. main reparents only world+camera (main.gd:1240-1253),
	# so without this the marquee would be absent from the captured frame.
	_ov = _ictl.get("sel_rect_overlay")
	var reparent_ok := false
	if _ov != null and is_instance_valid(_ov) and cv is SubViewport:
		var old_parent: Node = (_ov as Node).get_parent()
		if old_parent != null:
			old_parent.remove_child(_ov)
		(cv as SubViewport).add_child(_ov)
		reparent_ok = ((_ov as Node).get_parent() == cv)
	var ov_parent_name := ""
	if _ov != null and is_instance_valid(_ov) and (_ov as Node).get_parent() != null:
		ov_parent_name = str((_ov as Node).get_parent().name)
	_m["overlay_name"] = str((_ov as Node).name) if _ov != null and is_instance_valid(_ov) else ""
	_m["overlay_parent"] = ov_parent_name
	_m["overlay_parent_is_capture_view3d"] = reparent_ok
	check("overlay_reparented_into_capture_view3d", reparent_ok,
		"overlay_parent=%s capture_view3d=%s" % [ov_parent_name,
		"Screenshot3DViewport" if cv is SubViewport else "MISSING"])
	if not reparent_ok:
		return false

	# Marquee colour/width actually used by SelectionRectPainter._draw().
	var cfg = ConfigScript.active
	if cfg != null:
		_marquee_col = cfg.feature_selection_marquee_color()
		_marquee_width = cfg.feature_selection_marquee_width_px()
	_marquee_override_declared = _marquee_differs_from_default(_marquee_col, _marquee_width)
	_m["marquee_color"] = _marquee_col
	_m["marquee_width_px"] = _marquee_width
	_m["marquee_override_declared"] = _marquee_override_declared
	var marquee_cfg_ok := ((not _marquee_override_declared and _marquee_col == [1, 1, 0, 1]
			and _marquee_width == 1)
		or (_marquee_override_declared and _marquee_col.size() == 4 and _marquee_width > 0))
	check("marquee_config_default_or_declared", marquee_cfg_ok,
		"color=%s width=%s override_declared=%s" % [str(_marquee_col),
		str(_marquee_width), str(_marquee_override_declared)])

	_clear_entities()
	_game.next_id = 10
	var half := Vector2(float(_game.get("MAP_W")), float(_game.get("MAP_H"))) * Data.TILE_M * 0.5
	var box_a := half + Vector2(-12.0, -8.0)
	var box_b := half + Vector2(12.0, 8.0)
	# D03 §4.2 scene content: 4 peasants + 1 building, all in the camera view.
	# 12/13 are just OUTSIDE the box in y (y=-9 and y=+9 vs box ±8), while the
	# player-0 building at centre is INSIDE but excluded by kind — the deliberate
	# anti-donor-bug control (we do NOT copy "box select fails after a wall").
	var sim10 := half + Vector2(-6.0, -2.0)
	var sim11 := half + Vector2(4.0, 4.0)
	var sim12 := half + Vector2(10.0, -9.0)
	var sim13 := half + Vector2(-10.0, 9.0)
	var sim_bld := half + Vector2(0.0, 0.0)
	_u10 = _game.spawn("peasant", 0, sim10)
	_u11 = _game.spawn("peasant", 0, sim11)
	_u12 = _game.spawn("peasant", 0, sim12)
	_u13 = _game.spawn("peasant", 0, sim13)
	_bld = _game.spawn("cen", 0, sim_bld)
	var ids := []
	for e in _game.entities:
		ids.append(int(e.id))
	ids.sort()
	check("test_entities_exact", ids == [10, 11, 12, 13, 14],
		"ids=%s (4 friendly units + 1 non-unit building)" % str(ids))
	_m["entity_sim_positions"] = {
		"10": [sim10.x, sim10.y], "11": [sim11.x, sim11.y],
		"12": [sim12.x, sim12.y], "13": [sim13.x, sim13.y],
		"14_building": [sim_bld.x, sim_bld.y],
	}

	# cmd spy: typed C3Game subclass, only cmd_* overridden; all live state shared.
	_spy = CmdSpy.new()
	_spy.entities = _game.entities
	_spy.by_id = _game.by_id
	_spy.players = _game.players
	_spy.res_nodes = _game.res_nodes
	_spy.grid = _game.grid
	_spy.live_units = _game.live_units
	_spy.live_blds = _game.live_blds
	_spy.next_id = _game.next_id
	_spy.bld_dirty = _game.bld_dirty
	_spy.MAP_W = _game.MAP_W
	_spy.MAP_H = _game.MAP_H
	_ictl.game = _spy
	check("cmd_spy_installed", _ictl.game == _spy, "input_ctl.game is CmdSpy subclass of C3Game")

	_picker = _ictl.get("picking")
	check("picking3d_bound", _picker != null, "bind_3d() must create the picking3d adapter")
	if _picker == null:
		return false
	_p0 = _project_sim(box_a)
	_p1 = _project_sim(box_b)
	_p_click = _project_sim(sim10)
	var vp: Vector2 = Vector2(_cam.get_viewport().size)
	_m["viewport_px"] = [vp.x, vp.y]
	_m["p0_px"] = [_p0.x, _p0.y]
	_m["p1_px"] = [_p1.x, _p1.y]
	_m["click_px"] = [_p_click.x, _p_click.y]
	var pixels_ok := (_p0.is_finite() and _p1.is_finite() and _p_click.is_finite()
		and _p0.x > 8.0 and _p0.y > 8.0 and _p0.x < vp.x - 8.0 and _p0.y < vp.y - 8.0
		and _p1.x > 8.0 and _p1.y > 8.0 and _p1.x < vp.x - 8.0 and _p1.y < vp.y - 8.0
		and _p_click.x > 8.0 and _p_click.y > 8.0 and _p_click.x < vp.x - 8.0 and _p_click.y < vp.y - 8.0)
	check("projected_pixels_in_viewport", pixels_ok,
		"p0=%s p1=%s click=%s vp=%s" % [str(_p0), str(_p1), str(_p_click), str(vp)])
	if not pixels_ok:
		return false
	# camera3d.world_to_px() must agree with the direct unproject call.
	var via_helper: Vector2 = _cam.world_to_px(box_a - half)
	check("unproject_matches_world_to_px", via_helper.distance_to(_p0) < 0.5,
		"unproject=%s world_to_px=%s" % [str(_p0), str(via_helper)])

	# D03 §4.2: assert ALL FIVE projected entities are inside the window before
	# any event is sent (CAM-RV-01 view rect SIM x 24.96..103.04, y 22.56..89.23).
	var ent_px := {}
	var all_ent_ok := true
	for e in _game.entities:
		var ep := _project_sim(e.pos)
		ent_px[str(int(e.id))] = [ep.x, ep.y]
		if not (ep.x > 8.0 and ep.y > 8.0 and ep.x < vp.x - 8.0 and ep.y < vp.y - 8.0):
			all_ent_ok = false
	_m["entity_projected_px"] = ent_px
	check("all_entities_projected_in_viewport", all_ent_ok,
		"all five projected entities inside vp=%s: %s" % [str(vp), str(ent_px)])

	var px_dist := (_p1 - _p0).length()
	check("drag_crosses_port_6px_threshold", px_dist > PORT_DRAG_PX,
		"|p1-p0|=%.2f px > %.1f px (input_controller.gd:613,662-663)" % [px_dist, PORT_DRAG_PX])
	var g0v: Variant = _picker.call("ground_point", _p0)
	var g1v: Variant = _picker.call("ground_point", _p1)
	check("ground_endpoints_finite", g0v is Vector2 and g1v is Vector2
		and (g0v as Vector2).is_finite() and (g1v as Vector2).is_finite(),
		"ground_point(p0)=%s ground_point(p1)=%s" % [str(g0v), str(g1v)])
	if not (g0v is Vector2 and g1v is Vector2):
		return false
	_g0 = g0v
	_g1 = g1v
	var world_delta := maxf(absf(_g1.x - _g0.x), absf(_g1.y - _g0.y))
	_m["measured_ground_rect"] = [_g0.x, _g0.y, _g1.x, _g1.y]
	_m["drag_px_distance"] = px_dist
	_m["drag_world_delta_m"] = world_delta
	check("drag_crosses_donor_0.005m_epsilon", world_delta > DONOR_EPSILON_M,
		"world delta=%.4f m > %.3f m (DSEL-01 claim 1 / onmousemove.inc:32-34)" % [world_delta, DONOR_EPSILON_M])
	return true


func _send_mouse_button(p: Vector2, pressed: bool) -> void:
	var ev := InputEventMouseButton.new()
	var evp := _to_event_coord(p)  # stretch convention (identity windowed)
	ev.position = evp
	ev.global_position = evp
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = pressed
	ev.shift_pressed = false  # donor Shift=add recorded in JSON; port drag ignores it
	Input.parse_input_event(ev)


func _send_mouse_motion(p: Vector2, left_held: bool) -> void:
	var ev := InputEventMouseMotion.new()
	var evp := _to_event_coord(p)  # stretch convention (identity windowed)
	ev.position = evp
	ev.global_position = evp
	if left_held:
		ev.button_mask = MOUSE_BUTTON_MASK_LEFT
	Input.parse_input_event(ev)


func _overlay_probe() -> Dictionary:
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		var lname := str(n.name).to_lower()
		var tagged := bool(n.get_meta("sel_rect_overlay", false))
		var named := lname.contains("select") and lname.contains("rect")
		if n is CanvasLayer and (tagged or named):
			var has_api := (n.has_method("get_selection_rect") or n.has_method("selection_rect")
				or n.has_method("get_rect") or n.get("selection_rect") is Rect2)
			var r: Rect2 = Rect2()
			if n.has_method("get_selection_rect"):
				r = n.call("get_selection_rect")
			elif n.has_method("selection_rect"):
				r = n.call("selection_rect")
			elif n.has_method("get_rect"):
				r = n.call("get_rect")
			elif n.get("selection_rect") is Rect2:
				r = n.get("selection_rect")
			return {"found": true, "node": n.name, "has_api": has_api, "visible": n.visible,
				"rect": [r.position.x, r.position.y, r.size.x, r.size.y]}
		for c in n.get_children():
			stack.append(c)
	return {"found": false, "node": "", "has_api": false, "visible": false, "rect": [0.0, 0.0, 0.0, 0.0]}


func _probe_rect(probe: Dictionary) -> Rect2:
	var a = probe.get("rect", [])
	if a is Array and (a as Array).size() == 4:
		return Rect2(float(a[0]), float(a[1]), float(a[2]), float(a[3]))
	return Rect2()


func _assert_overlay(probe: Dictionary, want_visible: bool, label: String) -> void:
	# B05/COORD :525 — Rect2(position, size) takes SECOND arg as a SIZE, not an
	# end point. Expectation ends at the cursor; marker retained verbatim.
	var expected := Rect2(_p0, _p1 - _p0).abs()
	var got := _probe_rect(probe)
	var found := bool(probe.get("found", false))
	var api := bool(probe.get("has_api", false))
	var visible := bool(probe.get("visible", false))
	var ok := found and api
	if want_visible:
		ok = ok and visible and got.is_equal_approx(expected)
	else:
		# Rect2 has no is_empty() in this Godot version; use has_area().
		ok = (not found) or (ok and (not visible or not got.has_area()))
	check(label, ok, "node=%s api=%s visible=%s rect=%s expected=%s" % [
		str(probe.get("node", "")), str(api), str(visible), str(got), str(expected)], true)


func _selected_ids() -> Array:
	var out := []
	for e in _game.entities:
		if bool(e.get("selected", false)):
			out.append(int(e.id))
	out.sort()
	return out


func _assert_drag_result() -> void:
	var ids := _selected_ids()
	check("selected_ids_exact", ids == [10, 11],
		"selected=%s expected=[10,11] (12/13 outside; building 14 excluded by kind)" % str(ids))
	check("unit10_selected", bool(_u10.get("selected", false)), "e10.selected=%s" % str(_u10.get("selected", false)))
	check("unit11_selected", bool(_u11.get("selected", false)), "e11.selected=%s" % str(_u11.get("selected", false)))
	check("unit12_not_selected", not bool(_u12.get("selected", false)), "e12.selected=%s" % str(_u12.get("selected", false)))
	check("unit13_not_selected", not bool(_u13.get("selected", false)), "e13.selected=%s" % str(_u13.get("selected", false)))
	check("building_not_selected", not bool(_bld.get("selected", false)),
		"building id=%s kind=%s player=%s selected=%s" % [str(_bld.id), str(_bld.kind),
		str(_bld.player), str(_bld.get("selected", false))])
	# G03: same Rect2(position, size) misuse as the other atoms — use drag delta.
	var ground_rect := Rect2(_g0, _g1 - _g0).abs()
	check("building_inside_rect_but_excluded_by_kind", ground_rect.has_point(_bld.pos),
		"building pos=%s in ground rect=%s yet not selected (kind filter)" % [str(_bld.pos), str(ground_rect)])
	check("cmd_counter_zero_after_drag", _spy.total() == 0, "cmd_calls=%s" % str(_spy.calls))


func _assert_click_result() -> void:
	var ids := _selected_ids()
	check("short_click_selects_single_unit", ids == [10],
		"selected=%s expected=[10] (no click-pick regression)" % str(ids))
	check("cmd_counter_zero_after_click", _spy.total() == 0, "cmd_calls=%s" % str(_spy.calls))


# ---------------------------------------------------------------------------
# Capture — SubViewport texture path ONLY (Trap B). Two _process stage frames
# between _prepare_capture() and _capture_now() replace D03's two awaits.
# ---------------------------------------------------------------------------
func _prepare_capture() -> void:
	var vp: Variant = _main.get("capture_view3d")
	if vp is SubViewport:
		(vp as SubViewport).render_target_update_mode = SubViewport.UPDATE_ONCE


func _capture_now(path: String, slot: String) -> Dictionary:
	var vp: Variant = _main.get("capture_view3d")
	var rec := {"ok": false, "path": path, "reason": "", "w": 0, "h": 0, "p00": "", "center": ""}
	if not (vp is SubViewport):
		rec["reason"] = "capture_view3d is not a SubViewport (Trap A/B)"
		_store_capture(slot, rec, null)
		return rec
	# Trap B: ONLY the SubViewport texture is read. root.get_texture() is never
	# used; under gl_compatibility it reads blank and would be a fake frame.
	var tex: ViewportTexture = (vp as SubViewport).get_texture()
	var img: Image = tex.get_image() if tex != null else null
	if img == null or img.is_empty():
		rec["reason"] = "null/empty image from capture_view3d texture (root-texture trap)"
		_store_capture(slot, rec, null)
		return rec
	var w := img.get_width()
	var h := img.get_height()
	rec["w"] = w
	rec["h"] = h
	if w != CAPTURE_W or h != CAPTURE_H:
		rec["reason"] = "wrong size %dx%d (expected %dx%d)" % [w, h, CAPTURE_W, CAPTURE_H]
		_store_capture(slot, rec, null)
		return rec
	var p00 := img.get_pixel(0, 0)
	rec["p00"] = p00.to_string()
	rec["center"] = img.get_pixel(int(w / 2), int(h / 2)).to_string()
	if p00.a < 0.5:
		rec["reason"] = "blank frame: corner alpha < 0.5 (no CPU fallback — fail loudly)"
		_store_capture(slot, rec, null)
		return rec
	# Dynamic call: _main is typed Node, so use call() for main.gd-only helpers.
	if bool(_main.call("_is_blank", img)):
		rec["reason"] = "blank frame per main._is_blank (root-texture trap / no GPU)"
		_store_capture(slot, rec, null)
		return rec
	var written: String = str(_main.call("_write_bytes", path, img))
	rec["ok"] = written != ""
	rec["path"] = written
	rec["reason"] = "written" if written != "" else "_write_bytes failed"
	_store_capture(slot, rec, img if written != "" else null)
	return rec


func _store_capture(slot: String, rec: Dictionary, img: Image) -> void:
	if slot == "before":
		_cap_before = rec
		_img_before = img
	elif slot == "during":
		_cap_during = rec
		_img_during = img
	else:
		_cap_after = rec
		_img_after = img


func _is_marquee(c: Color) -> bool:
	# D03 §4.4 predicate, parameterised by the ACTUAL configured marquee colour.
	# Defaults [1,1,0,1] -> r>=0.85, g>=0.85, b<=0.25, a>=0.9.
	return (c.r >= float(_marquee_col[0]) - MARQUEE_IS_R_TOL
		and c.g >= float(_marquee_col[1]) - MARQUEE_IS_R_TOL
		and c.b <= float(_marquee_col[2]) + MARQUEE_IS_B_TOL
		and c.a >= float(_marquee_col[3]) - MARQUEE_IS_A_TOL)


func _channel_delta(a: Color, b: Color) -> float:
	return maxf(maxf(absf(a.r - b.r), absf(a.g - b.g)),
		maxf(absf(a.b - b.b), absf(a.a - b.a)))


func _near_marquee(img: Image, q: Vector2i) -> Dictionary:
	# ±1 px neighbourhood absorbs line-centre rounding of a 1 px solid outline;
	# the line must still be at the expected edge within 1 px (no weakening).
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			var x := q.x + dx
			var y := q.y + dy
			if x < 0 or y < 0 or x >= img.get_width() or y >= img.get_height():
				continue
			var c := img.get_pixel(x, y)
			if _is_marquee(c):
				return {"hit": true, "x": x, "y": y,
					"rgba": [c.r, c.g, c.b, c.a]}
	return {"hit": false, "x": q.x, "y": q.y, "rgba": []}


func _assert_pixels() -> void:
	var ready := (_img_before != null and _img_during != null and _img_after != null
		and not _img_before.is_empty() and not _img_during.is_empty() and not _img_after.is_empty())
	# D03 §4.4 uses p0/p1 as CORNERS: Rect2(p0, p1 - p0).abs() (COORD :525 fix).
	# D03 prose's Rect2(_p0,_p1).abs() shorthand would treat p1 as a SIZE and
	# contradict both the game's overlay and its own edge-midpoint formulas.
	var expected := Rect2(_p0, _p1 - _p0).abs()
	var cx := int(round((_p0.x + _p1.x) * 0.5))
	var cy := int(round((_p0.y + _p1.y) * 0.5))
	var l := int(round(expected.position.x))
	var t := int(round(expected.position.y))
	var r := int(round(expected.end.x))
	var b := int(round(expected.end.y))
	var edge_names := ["top", "bottom", "left", "right"]
	var edge_pts := [Vector2i(cx, t), Vector2i(cx, b), Vector2i(l, cy), Vector2i(r, cy)]
	var corner_names := ["top_left", "top_right", "bottom_left", "bottom_right"]
	var corner_pts := [Vector2i(l, t), Vector2i(r, t), Vector2i(l, b), Vector2i(r, b)]

	var edge_hits := 0
	var corner_hits := 0
	var edge_records := []
	var corner_records := []
	if ready:
		for i in range(4):
			var h := _near_marquee(_img_during, edge_pts[i])
			if bool(h["hit"]):
				edge_hits += 1
			edge_records.append({"name": edge_names[i], "probe": [edge_pts[i].x, edge_pts[i].y],
				"hit": h["hit"], "x": h["x"], "y": h["y"], "rgba": h["rgba"]})
		for i in range(4):
			var h2 := _near_marquee(_img_during, corner_pts[i])
			if bool(h2["hit"]):
				corner_hits += 1
			corner_records.append({"name": corner_names[i], "probe": [corner_pts[i].x, corner_pts[i].y],
				"hit": h2["hit"], "x": h2["x"], "y": h2["y"], "rgba": h2["rgba"]})
	_pixel_samples["expected_rect"] = [expected.position.x, expected.position.y, expected.size.x, expected.size.y]
	_pixel_samples["edge_midpoints"] = edge_records
	_pixel_samples["corners"] = corner_records
	_pixel_samples["centre"] = [cx, cy]

	# DECISIVE 1 — visible: >=3/4 edge midpoints AND >=2/4 corners yellow.
	check("quad_visible_during_pixels", ready and edge_hits >= 3 and corner_hits >= 2,
		"edge_hits=%d/4 corner_hits=%d/4 (need >=3 and >=2); rect=%s" % [edge_hits, corner_hits, str(expected)])

	# Collect only real yellow hits for the geometry/colour/hidden checks.
	var hits: Array[Dictionary] = []
	for rec in edge_records:
		if bool(rec["hit"]):
			hits.append(rec as Dictionary)
	for rec in corner_records:
		if bool(rec["hit"]):
			hits.append(rec as Dictionary)
	_during_yellow = hits

	# DECISIVE 2 — position: every yellow hit inside expected.grow(2); no NEW
	# yellow pixel outside expected.grow(width+2) on the three scanned rows.
	var in_grow2 := true
	for h3 in hits:
		var hp := Vector2(float(int(h3["x"])), float(int(h3["y"])))
		if not expected.grow(2.0).has_point(hp):
			in_grow2 = false
	var scan_rows := [t, cy, b]
	var stray: Array = []
	var row_counts := []
	if ready:
		for sy in scan_rows:
			var yy: int = clampi(sy, 0, _img_during.get_height() - 1)
			var n_yellow := 0
			for sx in range(_img_during.get_width()):
				if _is_marquee(_img_during.get_pixel(sx, yy)):
					n_yellow += 1
					var q := Vector2(float(sx), float(yy))
					if not expected.grow(float(_marquee_width) + 2.0).has_point(q):
						stray.append([sx, yy])
			row_counts.append(n_yellow)
	_pixel_samples["scanned_rows"] = scan_rows
	_pixel_samples["row_yellow_counts"] = row_counts
	_pixel_samples["stray_yellow"] = stray
	check("quad_position_pixels", ready and in_grow2 and stray.is_empty(),
		"all_hits_in_grow2=%s stray=%s rows=%s" % [str(in_grow2), str(stray), str(scan_rows)])

	# DECISIVE 3 — no fill: rect centre not yellow and equals BASELINE within
	# 8/255 per channel (SEL-01: solid outline, no fill, no AA).
	var centre_c := Color(-1, -1, -1, -1)
	var centre_base := Color(-1, -1, -1, -1)
	var centre_delta := 99.0
	if ready:
		centre_c = _img_during.get_pixel(clampi(cx, 0, _img_during.get_width() - 1),
			clampi(cy, 0, _img_during.get_height() - 1))
		centre_base = _img_before.get_pixel(clampi(cx, 0, _img_before.get_width() - 1),
			clampi(cy, 0, _img_before.get_height() - 1))
		centre_delta = _channel_delta(centre_c, centre_base)
	_pixel_samples["centre_during"] = centre_c.to_string() if ready else ""
	_pixel_samples["centre_baseline"] = centre_base.to_string() if ready else ""
	_pixel_samples["centre_delta"] = centre_delta
	check("quad_no_fill_pixels", ready and not _is_marquee(centre_c)
		and centre_delta <= PIXEL_TOL_BASELINE,
		"centre_during=%s baseline=%s delta=%.4f (limit %.4f)" % [centre_c.to_string(),
		centre_base.to_string(), centre_delta, PIXEL_TOL_BASELINE])

	# DECISIVE 4 — colour: every yellow hit matches the configured RGBA within
	# 16/255 per channel; default [1,1,0,1] unless a config override is declared.
	var max_col_delta := -1.0
	for h4 in hits:
		var a4: Array = h4["rgba"]
		if a4.size() != 4:
			continue
		var got_col := Color(float(a4[0]), float(a4[1]), float(a4[2]), float(a4[3]))
		var want_col := Color(float(_marquee_col[0]), float(_marquee_col[1]),
			float(_marquee_col[2]), float(_marquee_col[3]))
		max_col_delta = maxf(max_col_delta, _channel_delta(got_col, want_col))
	_pixel_samples["max_colour_delta"] = max_col_delta
	check("quad_colour_pixels", ready and hits.size() > 0 and max_col_delta >= 0.0
		and max_col_delta <= PIXEL_TOL_COLOUR,
		"hits=%d max_delta=%.4f limit=%.4f configured=%s override_declared=%s" % [hits.size(),
		max_col_delta, PIXEL_TOL_COLOUR, str(_marquee_col), str(_marquee_override_declared)])

	# DECISIVE 5 — hidden AFTER: every DURING yellow coordinate is no longer
	# yellow and matches BASELINE within 8/255 per channel.
	var hidden_ok := ready and hits.size() > 0
	var after_records := []
	for h5 in hits:
		var hx: int = clampi(int(h5["x"]), 0, _img_after.get_width() - 1) if ready else 0
		var hy: int = clampi(int(h5["y"]), 0, _img_after.get_height() - 1) if ready else 0
		var ac := Color(-1, -1, -1, -1)
		var bc := Color(-1, -1, -1, -1)
		var d := 99.0
		if ready:
			ac = _img_after.get_pixel(hx, hy)
			bc = _img_before.get_pixel(hx, hy)
			d = _channel_delta(ac, bc)
		if ready and (_is_marquee(ac) or d > PIXEL_TOL_BASELINE):
			hidden_ok = false
		after_records.append({"x": h5["x"], "y": h5["y"], "after": ac.to_string(),
			"baseline": bc.to_string(), "delta": d})
	_pixel_samples["after_vs_baseline"] = after_records
	check("quad_hidden_after_pixels", hidden_ok,
		"checked=%d all_clear=%s (not yellow and <=8/255 vs baseline)" % [hits.size(), str(hidden_ok)])

	# DECISIVE 6 — logic vs raster cross-check on the LIVE reparented overlay.
	# Probe values were captured while dragging and just after release.
	var logic_during := _ov_during_visible and _ov_during_rect.is_equal_approx(expected)
	var logic_after := (not _ov_after_visible) and (not _ov_after_rect.has_area())
	var logic_ok := ready and logic_during and logic_after
	_pixel_samples["overlay_logic_during"] = {"visible": _ov_during_visible,
		"rect": [_ov_during_rect.position.x, _ov_during_rect.position.y,
		_ov_during_rect.size.x, _ov_during_rect.size.y]}
	_pixel_samples["overlay_logic_after"] = {"visible": _ov_after_visible,
		"rect": [_ov_after_rect.position.x, _ov_after_rect.position.y,
		_ov_after_rect.size.x, _ov_after_rect.size.y]}
	check("overlay_rect_matches_pixels", logic_ok,
		"during(visible=%s rect=%s) after(visible=%s rect=%s) expected=%s" % [
		str(_ov_during_visible), str(_ov_during_rect), str(_ov_after_visible),
		str(_ov_after_rect), str(expected)])


func _process(_dt: float) -> bool:
	if _finished:
		return false
	_stage_frames += 1
	match _stage:
		0:  # real 64x64 3D game boot
			if _stage_frames >= 3:
				if not _configure():
					_abort("real boot/configure failed; see preceding checks")
				else:
					_goto(1)
		1:  # prepare BASELINE SubViewport render (2 frames = D03's 2 awaits)
			if _stage_frames >= 2:
				_prepare_capture()
				_goto(2)
		2:  # read BASELINE PNG, then press at p0
			if _stage_frames >= 2:
				var cap := _capture_now(_capture_dir.path_join("d03_selquad_before.png"), "before")
				check("capture_before_ok", bool(cap.get("ok", false)),
					"path=%s w=%s h=%s reason=%s" % [str(cap.get("path", "")), str(cap.get("w", 0)),
					str(cap.get("h", 0)), str(cap.get("reason", ""))])
				_send_mouse_button(_p0, true)
				_goto(3)
		3:  # press landed; motion at p1 with the left button mask
			if _stage_frames >= 2:
				check("drag_start_from_real_event", (_ictl.drag_start - _p0).length() < 0.5,
					"input_ctl.drag_start=%s p0=%s" % [str(_ictl.drag_start), str(_p0)])
				_send_mouse_motion(_p1, true)
				_goto(4)
		4:  # overlay DURING + prepare DURING render; LMB still held
			if _stage_frames >= 2:
				_overlay_during = _overlay_probe()
				_m["overlay_during"] = _overlay_during
				_m["world_sel_rect_during"] = [_world.sel_rect.position.x, _world.sel_rect.position.y,
					_world.sel_rect.size.x, _world.sel_rect.size.y]
				_m["world_sel_active_during"] = bool(_world.sel_active)
				check("world_sel_active_during_drag", bool(_world.sel_active),
					"world.sel_rect mirror from input_controller.gd:1164-1172")
				if _ov != null and is_instance_valid(_ov):
					_ov_during_visible = bool(_ov.visible)
					_ov_during_rect = _ov.call("get_selection_rect") as Rect2
				_prepare_capture()
				_goto(5)
		5:  # read DURING PNG while the drag is still active, then release
			if _stage_frames >= 2:
				var cap2 := _capture_now(_capture_dir.path_join("d03_selquad_during.png"), "during")
				check("capture_during_ok", bool(cap2.get("ok", false)),
					"path=%s w=%s h=%s reason=%s" % [str(cap2.get("path", "")), str(cap2.get("w", 0)),
					str(cap2.get("h", 0)), str(cap2.get("reason", ""))])
				_send_mouse_button(_p1, false)
				_goto(6)
		6:  # overlay AFTER + logic assertions + prepare AFTER render
			if _stage_frames >= 2:
				_overlay_after = _overlay_probe()
				_m["overlay_after"] = _overlay_after
				_m["world_sel_active_after"] = bool(_world.sel_active)
				if _ov != null and is_instance_valid(_ov):
					_ov_after_visible = bool(_ov.visible)
					_ov_after_rect = _ov.call("get_selection_rect") as Rect2
				_assert_overlay(_overlay_during, true, "overlay_rect_during_drag")
				_assert_overlay(_overlay_after, false, "overlay_hidden_after_release")
				_assert_drag_result()
				_prepare_capture()
				_goto(7)
		7:  # read AFTER PNG, run all decisive pixel assertions
			if _stage_frames >= 2:
				var cap3 := _capture_now(_capture_dir.path_join("d03_selquad_after.png"), "after")
				check("capture_after_ok", bool(cap3.get("ok", false)),
					"path=%s w=%s h=%s reason=%s" % [str(cap3.get("path", "")), str(cap3.get("w", 0)),
					str(cap3.get("h", 0)), str(cap3.get("reason", ""))])
				_assert_pixels()
				_send_mouse_motion(_p_click, false)
				_goto(8)
		8:  # short-click press (click-pick regression retained)
			if _stage_frames >= 1:
				_send_mouse_button(_p_click, true)
				_goto(9)
		9:  # short-click release
			if _stage_frames >= 2:
				_send_mouse_button(_p_click, false)
				_goto(10)
		10:  # finish
			if _stage_frames >= 2:
				_assert_click_result()
				_finish()
	return false
