# CAM-RV-01 — runtime re-verify of the world3d.view_rect half-map fix.
#
# Owns ONLY this file (plus the CAM_RV_01 report). No game code, config,
# fixture, manifest, gate, scene or shader is edited. No direct `godot`:
# all launches go through variant3d/tools/godot_runner.py.
#
# WHAT IT PROVES (unlike CAM-02's out-of-tree parse smoke, which only proved
#   the edited script loads and takes the full-map fallback):
#   1. world.view_rect in a LIVE 64x64 / render_mode=3d scene equals a rect
#      computed INDEPENDENTLY here from camera3d.get_viewport_corners() plus
#      Vector2(mw,mh)*TILE_M*0.5 (the hud3d_adapter.gd:62 half-map shift),
#      scaled by view_scale. This is the CAM-02 one-line shift at
#      world3d.gd:270-274 exercised with a real Camera3D.
#   2. Double-click select-all-of-type (input_controller.gd:733-743, the
#      post-SEL-01 numbering of the old :632-635 branch) selects all same-type
#      player-0 units inside the view and NO same-type unit outside it.
#   3. hud3d_adapter.get_minimap_box() is consistent with world.view_rect
#      (both consume the same CENTRED corners and add the same half-map offset;
#      the adapter adds it at hud3d_adapter.gd:62/109, the world3d Vector2
#      branch at world3d.gd:274).
#
# CAPTURE PATH: real res://scenes/main.tscn boot, --config <small_map_64.json>
# and --screenshot <path> used ONLY as the menu-skip flag (main.gd:206,230-244).
# After boot the HUD is re-shown and main's savers/AI are frozen so the camera
# pose stays fixed while the synthetic clicks run. No PNG is asserted; headless
# cannot render 3D (main.gd:1156-1158,1790-1800).
#
# DRIVE MODES: --drive input  -> Input.parse_input_event (real engine input
#                               phase; the t_select_rect.gd pattern).
#              --drive direct -> call _ictl._unhandled_input(ev) directly with
#                               the same InputEventMouseButton objects. Used
#                               ONLY if input parsing proves unreliable; the
#                               chosen mode is recorded in the result JSON.
#
# LAUNCH (variant runner only; Windows `python`, never `python3`):
#   python variant3d\tools\godot_runner.py run --id camrv01-smoke --timeout 90 -- ^
#     --headless --path variant3d --script res://tests/t_view_rect_rv.gd -- ^
#     --config <ABS>\small_map_64.json --screenshot <temp>\camrv01.png --drive input
#
# Self-exits via call_deferred("quit", 0/1); NEVER quit() directly in
# _initialize(). Measured values are printed as one CAMRV01_JSON line so no
# extra repository file is created.
extends SceneTree

const MAIN_SCENE := "res://scenes/main.tscn"
const ADAPTER_SCRIPT := "res://scripts/hud3d_adapter.gd"
const DATA_SCRIPT := "res://scripts/data.gd"

var _id := "t_view_rect_rv"
var _checks: Array[Dictionary] = []
var _ok := true
var _finished := false
var _stage := 0
var _stage_frames := 0
var _setup_error := ""

var Data: Script = null
var _cfg_arg := ""
var _shot_arg := ""
var _drive := "input"
var _abs_config := ""
var _main: Node = null
var _game = null
var _cam = null
var _world = null
var _hud = null
var _ictl = null
var _adapter = null

var _tile_m := 2.0
var _vs := 16.0
var _half := Vector2.ZERO
var _clicked: Dictionary = {}
var _clicked_sid := ""
var _clicked_px := Vector2.INF
var _expected_rect_px := Rect2()
var _expected_inside: Array[int] = []
var _outside_ids: Array[int] = []
var _pose0 := Vector2.INF
var _m: Dictionary = {}


func check(name: String, cond: bool, detail: String = "") -> void:
	_checks.append({"name": name, "passed": cond, "detail": detail})
	if not cond:
		_ok = false
	print("CAMRV01 %s %s - %s" % ["PASS" if cond else "FAIL", name, detail])


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


func rect_approx(a: Rect2, b: Rect2, tol: float = 0.01) -> bool:
	return absf(a.position.x - b.position.x) <= tol \
		and absf(a.position.y - b.position.y) <= tol \
		and absf(a.size.x - b.size.x) <= tol \
		and absf(a.size.y - b.size.y) <= tol


func vec4(v: Vector2) -> Array:
	return [v.x, v.y]


func r4(r: Rect2) -> Array:
	return [r.position.x, r.position.y, r.size.x, r.size.y]


func _initialize() -> void:
	_m["display_server"] = DisplayServer.get_name()
	Data = load(DATA_SCRIPT) as Script
	if Data == null:
		_setup_error = "cannot load " + DATA_SCRIPT
		return
	_tile_m = float(Data.TILE_M)
	_cfg_arg = _arg_value("--config")
	_shot_arg = _arg_value("--screenshot")
	var d := _arg_value("--drive")
	if d == "input" or d == "direct":
		_drive = d
	_m["config_arg"] = _cfg_arg
	_m["screenshot_arg"] = _shot_arg
	_m["drive"] = _drive
	if _cfg_arg == "" or _shot_arg == "":
		_setup_error = "need --config <small_map_64.json> and --screenshot <path> user args (menu skip)"
		return
	_abs_config = _resolve_config(_cfg_arg)
	if _abs_config == "":
		_setup_error = "config fixture not found: " + _cfg_arg
		return
	var packed := load(MAIN_SCENE) as PackedScene
	if packed == null:
		_setup_error = "cannot load " + MAIN_SCENE
		return
	_main = packed.instantiate()
	root.add_child(_main)
	_goto(0)


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
	# entity.pos is SIM top-left metres. One subtraction (camera3d.gd:267-269).
	var centred := sim - _half
	return _cam.unproject_position(Vector3(centred.x, 0.0, centred.y))


func _expected_box_from_rect(r: Rect2) -> Rect2:
	# Mirror hud3d_adapter.get_minimap_box()/get_minimap_corners() mapping, but
	# feed it SIM metres recovered from world.view_rect instead of raw corners.
	# u = (x + halfW)/mapW, scaled to mw tiles; int() truncate; clamp; +1 end.
	var mw := int(_game.get("MAP_W"))
	var mh := int(_game.get("MAP_H"))
	var ext := Vector2(float(mw), float(mh)) * _tile_m
	var x0 := clampi(int((r.position.x / _vs) / ext.x * float(mw)), 0, mw - 1)
	var y0 := clampi(int((r.position.y / _vs) / ext.y * float(mh)), 0, mh - 1)
	var x1 := clampi(int((r.end.x / _vs) / ext.x * float(mw)), 0, mw - 1)
	var y1 := clampi(int((r.end.y / _vs) / ext.y * float(mh)), 0, mh - 1)
	return Rect2(float(x0), float(y0), float(x1 - x0 + 1), float(y1 - y0 + 1))


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
		str(_game.get("MAP_W")) if _game != null else "?",
		str(_game.get("MAP_H")) if _game != null else "?"])
	if not boot_ok:
		return false

	_hud.visible = true
	_main.set("screenshot_frames", 1000000)
	_main.set("screenshot_done", true)
	var ais = _main.get("ais")
	if ais is Array:
		ais.clear()
	_main.set("speed", 0.0)

	_vs = float(_world.get("view_scale"))
	_half = Vector2(float(_game.get("MAP_W")), float(_game.get("MAP_H"))) * _tile_m * 0.5
	_m["view_scale"] = _vs
	_m["tile_m"] = _tile_m
	_m["half_map_offset_m"] = vec4(_half)

	# Known camera pose: focus the map centre through the camera's public
	# handoff, then record the resulting target (clamp_pos may nudge it by the
	# frustum-AABB asymmetry; the expected rect below is computed from the
	# resulting LIVE corners, so the nudge is measured, not assumed away).
	_cam.call("jump_to_world", _half)
	# camera3d._process edge-scroll pans the target when the synthetic mouse
	# sits at (0,0) in a headless/unfocused window. Freeze it so the measured
	# pose cannot drift between configure and the final assertions.
	_cam.edge_margin = 0.0
	_cam.corner_margin = 0.0
	_pose0 = _cam.get("_target") as Vector2
	_m["camera_target_after_jump"] = vec4(_pose0)

	_clear_entities()
	_game.next_id = 10
	_spawn_units()
	var ids: Array = []
	for e in _game.entities:
		ids.append(int(e.id))
	ids.sort()
	check("test_entities_exact", ids == [10, 11, 12, 13, 14, 15],
		"ids=%s (4 peasants in view region + 2 peasants outside + 1 pikeman)" % str(ids))
	if ids != [10, 11, 12, 13, 14, 15]:
		return false

	# --- independent expected rect from the LIVE camera corners -------------
	var corners = _cam.call("get_viewport_corners")
	check("corners_from_live_camera", corners is Array and (corners as Array).size() >= 4,
		"corners=%s" % str(corners))
	if not (corners is Array) or (corners as Array).size() < 4:
		return false
	var off := Vector2(float(_game.get("MAP_W")), float(_game.get("MAP_H"))) * _tile_m * 0.5
	var raw: Array = []
	for c in (corners as Array):
		raw.append(vec4(c) if c is Vector2 else (str(c)))
	_m["raw_centred_corners"] = raw
	_m["half_map_shift_applied"] = vec4(off)
	var minv := Vector2.INF
	var maxv := Vector2(-INF, -INF)
	var saw := false
	for c in (corners as Array):
		var xy := Vector2.ZERO
		if c is Vector2:
			xy = c as Vector2
		elif c is Vector3:
			var v3 := c as Vector3
			xy = Vector2(v3.x, v3.z)
		else:
			continue
		# THE fix under test, recomputed independently: hud3d_adapter.gd:62.
		xy += off
		if not is_finite(xy.x) or not is_finite(xy.y):
			continue
		saw = true
		minv = minv.min(xy)
		maxv = maxv.max(xy)
	if saw:
		_expected_rect_px = Rect2(minv.x * _vs, minv.y * _vs,
			(maxv.x - minv.x) * _vs, (maxv.y - minv.y) * _vs)
	_m["expected_view_rect_px"] = r4(_expected_rect_px)
	var full := Rect2(0.0, 0.0, float(_game.get("MAP_W")) * _tile_m * _vs,
		float(_game.get("MAP_H")) * _tile_m * _vs)
	check("expected_rect_non_degenerate", saw and _expected_rect_px.size.x > 1.0
		and _expected_rect_px.size.y > 1.0 and is_finite(_expected_rect_px.size.x)
		and is_finite(_expected_rect_px.size.y),
		"expected=%s" % str(r4(_expected_rect_px)))
	check("expected_rect_not_full_map_fallback",
		_expected_rect_px.size.x < full.size.x * 0.95 and _expected_rect_px.size.y < full.size.y * 0.95,
		"expected=%s full_map_fallback=%s" % [str(r4(_expected_rect_px)), str(r4(full))])
	if not saw:
		return false

	# The camera must be the viewport's active 3D camera; otherwise
	# world3d._update_view_rect() would take its full-map fallback.
	var vp = _world.get_viewport()
	var active = vp.get_camera_3d() if vp != null else null
	check("camera_active_in_viewport", active != null,
		"active=%s cam=%s" % [str(active), str(_cam)])

	# Force the real consumer to recompute, then compare its output with the
	# independently derived rect. This is the CAM-02 half-map shift under test.
	_world.call("_update_view_rect")
	var vr: Rect2 = _world.get("view_rect")
	_m["world_view_rect_px"] = r4(vr)
	check("view_rect_equals_expected", rect_approx(vr, _expected_rect_px),
		"world.view_rect=%s expected=%s" % [str(r4(vr)), str(r4(_expected_rect_px))])

	# Define "inside the view" from the independent rect, never from the
	# consumer's answer (no circular assertion).
	_expected_inside.clear()
	_outside_ids.clear()
	var other_id := -1
	for e in _game.entities:
		if int(e.player) != 0 or str(e.kind) != "unit" or bool(e.dead):
			continue
		var inside := _expected_rect_px.has_point((e.pos as Vector2) * _vs)
		if str(e.sid) == _clicked_sid:
			if inside:
				_expected_inside.append(int(e.id))
			else:
				_outside_ids.append(int(e.id))
		elif inside:
			other_id = int(e.id)
	_expected_inside.sort()
	_outside_ids.sort()
	_m["expected_inside_ids"] = _expected_inside
	_m["expected_outside_ids"] = _outside_ids
	_m["other_sid_inside_id"] = other_id
	check("inside_and_outside_units_exist", _expected_inside.size() >= 2 and _outside_ids.size() >= 1,
		"inside=%s outside=%s" % [str(_expected_inside), str(_outside_ids)])
	if _expected_inside.size() < 2 or _outside_ids.size() < 1:
		return false

	_clicked_px = _project_sim(_clicked.pos as Vector2)
	# The camera's projection viewport (a Screenshot3DViewport in windowed
	# mode) is the coordinate space unproject_position() uses; the root
	# viewport is 64x64 in headless and is NOT the right space for this check.
	var vps: Vector2 = Vector2(_cam.get_viewport().size)
	_m["viewport_px"] = vec4(vps)
	_m["root_viewport_px"] = vec4(Vector2(root.size))
	_m["click_px"] = vec4(_clicked_px)
	var mm: Rect2 = _ictl.call("_minimap_screen_rect")
	_m["minimap_screen_rect"] = r4(mm)
	check("click_pixel_usable", _clicked_px.is_finite()
		and _clicked_px.x > 8.0 and _clicked_px.y > 8.0
		and _clicked_px.x < vps.x - 8.0 and _clicked_px.y < vps.y - 8.0
		and not mm.has_point(_clicked_px),
		"click=%s vp=%s minimap=%s" % [str(vec4(_clicked_px)), str(vec4(vps)), str(r4(mm))])

	# --- hud3d_adapter consistency (the second half-map consumer) -----------
	_adapter = _hud.get("_hud3d_adapter")
	if _adapter == null:
		var ad_script := load(ADAPTER_SCRIPT) as Script
		if ad_script != null:
			_adapter = ad_script.new()
			_adapter.call("bind", _cam, _hud)
	check("adapter_present", _adapter != null,
		"hud._hud3d_adapter or dynamically loaded " + ADAPTER_SCRIPT)
	if _adapter == null:
		return false
	var box: Rect2 = _adapter.call("get_minimap_box")
	var exp_box := _expected_box_from_rect(_expected_rect_px)
	_m["minimap_box"] = r4(box)
	_m["minimap_box_expected_from_view_rect"] = r4(exp_box)
	check("minimap_box_consistent_with_view_rect", rect_approx(box, exp_box, 0.0),
		"adapter=%s expected_from_view_rect=%s" % [str(r4(box)), str(r4(exp_box))])
	return true


func _spawn_units() -> void:
	_clicked = _game.spawn("peasant", 0, _half + Vector2(0.0, 0.0))
	_clicked_sid = str(_clicked.sid)
	_game.spawn("peasant", 0, _half + Vector2(5.0, 3.0))
	_game.spawn("peasant", 0, _half + Vector2(-6.0, -3.0))
	_game.spawn("peasant", 0, _half + Vector2(55.0, 55.0))
	_game.spawn("peasant", 0, _half + Vector2(-55.0, -55.0))
	_game.spawn("pikeman", 0, _half + Vector2(12.0, 0.0))
	_m["clicked_sid"] = _clicked_sid
	_m["clicked_id"] = int(_clicked.id)
	_m["entity_sim_positions"] = {}
	for e in _game.entities:
		_m["entity_sim_positions"][str(int(e.id))] = vec4(e.pos)


func _send_button(p: Vector2, pressed: bool) -> void:
	var ev := InputEventMouseButton.new()
	ev.position = p
	ev.global_position = p
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = pressed
	if _drive == "direct":
		_ictl._unhandled_input(ev)
	else:
		Input.parse_input_event(ev)


func _selected_ids() -> Array[int]:
	var out: Array[int] = []
	for e in _game.entities:
		if bool(e.get("selected", false)):
			out.append(int(e.id))
	out.sort()
	return out


func _assert_final() -> void:
	var sel := _selected_ids()
	_m["selected_ids_after_double_click"] = sel
	_m["last_click_sid"] = str(_ictl.get("last_click_sid"))
	_m["last_click_t"] = float(_ictl.get("last_click_t"))
	_m["now_s"] = Time.get_ticks_msec() / 1000.0
	_m["double_click_window_s"] = _m["now_s"] - float(_m["last_click_t"])
	check("double_click_selected_exact", sel == _expected_inside,
		"selected=%s expected_inside=%s" % [str(sel), str(_expected_inside)])
	check("multi_select_proves_double_click_branch", sel.size() >= 2,
		"selected=%s (a single click would select only [%d])" % [str(sel), int(_clicked.id)])
	for oid in _outside_ids:
		check("outside_%d_not_selected" % oid, not sel.has(oid),
			"outside id %d selected=%s" % [oid, str(sel.has(oid))])
	var other := int(_m.get("other_sid_inside_id", -1))
	if other >= 0:
		check("other_sid_not_selected", not sel.has(other),
			"other-sid id %d inside view but selected=%s" % [other, str(sel.has(other))])
	var vr2: Rect2 = _world.get("view_rect")
	check("view_rect_stable_after_clicks", rect_approx(vr2, _expected_rect_px),
		"view_rect=%s expected=%s" % [str(r4(vr2)), str(r4(_expected_rect_px))])
	if _adapter != null:
		var box2: Rect2 = _adapter.call("get_minimap_box")
		check("minimap_box_stable_after_clicks",
			rect_approx(box2, _expected_box_from_rect(_expected_rect_px), 0.0),
			"adapter=%s expected=%s" % [str(r4(box2)),
			str(r4(_expected_box_from_rect(_expected_rect_px)))])
	var pose1: Vector2 = _cam.get("_target") as Vector2
	check("camera_pose_stable", pose1 != Vector2.INF and pose1.distance_to(_pose0) < 0.5,
		"pose0=%s pose1=%s" % [str(vec4(_pose0)), str(vec4(pose1))])


func _finish() -> void:
	if _finished:
		return
	_finished = true
	var passes := 0
	for c in _checks:
		if bool(c.get("passed", false)):
			passes += 1
	var out := {
		"id": _id,
		"passed": _ok,
		"passes": passes,
		"total": _checks.size(),
		"checks": _checks,
		"measured": _m,
		"scope": "CAM-RV-01 runtime re-verify of world3d.view_rect half-map shift via double-click select-all-of-type",
		"note": "No repo file edited by this atom; result printed to stdout only.",
	}
	print("CAMRV01_JSON: " + JSON.stringify(out))
	print("CAMRV01_RESULT: %s %d/%d" % ["PASS" if _ok else "FAIL", passes, _checks.size()])
	if _ok:
		print("CAMRV01_SMOKE_OK")
	print("CAMRV01_STDERR_SCAN_REQUIRED (runner stderr.txt: count SCRIPT ERROR)")
	call_deferred("quit", 0 if _ok else 1)


func _process(_dt: float) -> bool:
	if _finished:
		return false
	_stage_frames += 1
	if _setup_error != "":
		check("boot_and_setup", false, _setup_error)
		_finish()
		return false
	match _stage:
		0:  # real game boot
			if _stage_frames >= 3:
				if not _configure():
					_m["configure_failed_at"] = "checks above"
				_goto(1)
		1:  # first click press
			if _stage_frames >= 2:
				_send_button(_clicked_px, true)
				_goto(2)
		2:  # first click release
			if _stage_frames >= 2:
				_send_button(_clicked_px, false)
				_goto(3)
		3:  # read the FIRST click's result one frame later (Input.parse_input_event
			# is delivered on the next input frame), then press again within the
			# 0.5 s double-click window.
			if _stage_frames >= 1:
				_m["last_click_sid_after_first"] = str(_ictl.get("last_click_sid"))
				check("first_click_picked_intended_unit",
					str(_ictl.get("last_click_sid")) == _clicked_sid,
					"last_click_sid=%s clicked_sid=%s" % [str(_ictl.get("last_click_sid")), _clicked_sid])
				_send_button(_clicked_px, true)
				_goto(4)
		4:  # second click release -> input_controller.gd:733-743 branch
			if _stage_frames >= 1:
				_send_button(_clicked_px, false)
				_goto(5)
		5:
			if _stage_frames >= 2:
				_assert_final()
				_finish()
	return false
