# LOAD-PROBE-01 — load-responsiveness / post-load usability atom.
#
# AUTHORING ONLY. This file is a measurement probe, NOT a gate: it writes
# verdict "MEASUREMENT_ONLY__NO_PASS_CLAIM" and makes NO PASS claim. Anything
# that cannot be observed without editing main.gd is recorded as UNVERIFIED.
# No Godot runner job was launched by the author of this file.
#
# Owns ONLY variant3d/tests/t_load_usability.gd and
# docs/coord_swarm_2026-11-25/reports/LOAD_PROBE_01.md. main.gd belongs to
# LOAD-ASYNC-01 and hud.gd to UI-TOPBAR-01; both are read-only here.
#
# WHY THE FORCED PATH (documented limitation, no weakening):
#   main.gd:253-268 takes the staged loading path (_do_async_load, overlay)
#   ONLY when NOT headless. A headless real-game boot via --screenshot goes
#   straight through the synchronous _setup_full_game (main.gd:230-244,
#   1046-1149) and NEVER shows a loading overlay. To observe the real staged
#   path in headless, this atom instantiates res://scenes/main.tscn with only
#   --config res://tests/fixtures/small_map_64.json (so menu.gd is built and
#   no test-mode early boot happens, main.gd:206,230-246), then invokes the
#   REAL menu handlers by Object.call(): _apply_menu_cfg(cfg) (main.gd:270,
#   as _on_menu_chosen does at :256) and _do_async_load(cfg) (main.gd:530-645,
#   as _on_menu_chosen does at :268). _do_async_load has no headless gate
#   except window sizing (main.gd:544-549), so the exact staged coroutine,
#   overlay nodes and bindings run verbatim. This is a proxy for a real Start
#   click, NOT a real click; the click/signal path is UNVERIFIED.
#
# Launch (through variant3d/tools/godot_runner.py ONLY, Windows python):
#   --headless --path variant3d --script res://tests/t_load_usability.gd -- \
#     --config res://tests/fixtures/small_map_64.json
# Result: res://tests/results/t_load_usability.json (plus stdout). Hard engine
# errors are NOT observable from GDScript; the runner stderr must be scanned
# with variant3d/tools/smallmap_capture.py scan-stderr (TEST_01 report :89-92).
extends SceneTree

const MAIN_SCENE := "res://scenes/main.tscn"
const FIXTURE := "res://tests/fixtures/small_map_64.json"
const OUT_DIR := "res://tests/results"
const OUT_ID := "t_load_usability"

# Bounded windows. These are probe parameters, not donor/spec constants.
const RESPONSE_FRAMES := 30       # bounded frame count for assertion (c)
const STABILITY_FRAMES := 30      # poll length for assertion (d)
const MAX_FRAMES := 3600          # failsafe frame ceiling (no hang)
const WALL_CAP_US := 120000000    # 120 s failsafe wall ceiling
const STALL_LIMIT_US := 250000    # 250 ms heuristic inter-frame gap ceiling
const POS_TOL_M := 1.0            # camera target tolerance (metres)

const Data = preload("res://scripts/data.gd")

var _checks: Array[Dictionary] = []
var _notes: Array[String] = []
var _m: Dictionary = {}
var _main: Node = null
var _game = null
var _world = null
var _camera = null
var _hud = null
var _input = null

var _phase := 0                   # 0 boot, 1 loading, 2 probes, 3 stability, 4 done
var _frame := 0
var _finished := false
var _headless := false
var _display_server := ""
var _t_start_us := 0
var _t_last_us := 0
var _load_start_frame := 0
var _t_overlay_first_us := -1
var _t_overlay_hidden_us := -1
var _hide_frame := -1
var _max_gap_loading_us := 0
var _max_gap_post_us := 0
var _last_stage := ""
var _stage_log: Array[Dictionary] = []
var _overlay_visible := false
var _overlay_was_visible := false
var _overlay_frames := 0
var _bind_first: Dictionary = {}
var _hide_snapshot: Dictionary = {}

var _post_frame := 0
var _probe_started := false
var _probe_unit = null
var _probe_dest := Vector2.ZERO
var _cam_target := Vector2.ZERO
var _cam_target_before := Vector2.ZERO
var _cam_pos_before := Vector3.ZERO
var _resp_input_frame := -1
var _resp_order_frame := -1
var _resp_camera_frame := -1
var _base_children := -1
var _base_entities := -1
var _stable_violations := 0


func _record(id: String, status: String, met, detail: String, citation: String) -> void:
	_checks.append({
		"id": id,
		"status": status,
		"met_criterion": met,
		"detail": detail,
		"citation": citation,
	})


func _note(s: String) -> void:
	_notes.append(s)


func _obj_prop(obj, prop: String):
	if not (obj is Object):
		return null
	if not is_instance_valid(obj):
		return null
	return obj.get(prop)


func _same(a, b) -> bool:
	return a != null and b != null and a == b


func _refresh_refs() -> void:
	_game = _main.get("game") if _main != null else null
	_world = _main.get("world") if _main != null else null
	_camera = _main.get("camera") if _main != null else null
	_hud = _main.get("hud") if _main != null else null
	_input = _main.get("input_ctl") if _main != null else null


# Observable "bound" state, keyed to the real bind() calls:
#   world.bind(game) / world.hud = hud   -> main.gd:580-581,614-615; world3d.gd:599-602
#   camera.bind(game, world.view_scale)  -> main.gd:589-591; camera3d.gd:171-174
#   hud.bind(game, world) + bind_3d(cam) -> main.gd:612-615,631,1039-1043; hud.gd:167-169,201-213
#   input_ctl.bind(game, world, hud, camera) + bind_3d -> main.gd:627-631;
#                                            input_controller.gd:129-134,172-185
func _binding_snapshot() -> Dictionary:
	var wg = _obj_prop(_world, "game")
	var wh = _obj_prop(_world, "hud")
	var wv = _obj_prop(_world, "view_scale")
	var cg = _obj_prop(_camera, "game")
	var cv = _obj_prop(_camera, "view_scale")
	var hg = _obj_prop(_hud, "game")
	var hw = _obj_prop(_hud, "world")
	var ha = _obj_prop(_hud, "_hud3d_adapter")
	var ig = _obj_prop(_input, "game")
	var iw = _obj_prop(_input, "world")
	var ih = _obj_prop(_input, "hud")
	var ic = _obj_prop(_input, "camera")
	var im = _obj_prop(_input, "render_mode")
	var ip = _obj_prop(_input, "picking")
	var s := {
		"game": _game != null and _game is Object and is_instance_valid(_game),
		"world": _world != null and _world is Object and is_instance_valid(_world),
		"camera": _camera != null and _camera is Object and is_instance_valid(_camera),
		"hud": _hud != null and _hud is Object and is_instance_valid(_hud),
		"input": _input != null and _input is Object and is_instance_valid(_input),
		"world_game": _same(wg, _game),
		"world_hud": _same(wh, _hud),
		"camera_game": _same(cg, _game),
		"camera_view_scale": wv != null and cv != null and absf(float(wv) - float(cv)) < 0.001,
		"hud_game": _same(hg, _game),
		"hud_world": _same(hw, _world),
		"hud_adapter_3d": ha != null and ha is Object and is_instance_valid(ha),
		"input_game": _same(ig, _game),
		"input_world": _same(iw, _world),
		"input_hud": _same(ih, _hud),
		"input_camera": _same(ic, _camera),
		"input_render_mode_3d": str(im) == "3d",
		"input_picking_3d": ip != null and ip is Object and is_instance_valid(ip),
	}
	s["all_bound"] = _all_bound(s)
	return s


func _all_bound(s: Dictionary) -> bool:
	for k in s.keys():
		if str(k) == "all_bound":
			continue
		if not bool(s[k]):
			return false
	return true


func _sample_bindings() -> void:
	var s := _binding_snapshot()
	for k in s.keys():
		if str(k) == "all_bound":
			continue
		if bool(s[k]) and not _bind_first.has(str(k)):
			_bind_first[str(k)] = _frame


func _initialize() -> void:
	if _finished:
		return
	_display_server = DisplayServer.get_name()
	_headless = _display_server == "headless"
	if not _headless:
		_note("Non-headless run: atom intentionally does not drive a windowed Start click.")
		_finish()
		return
	var packed := load(MAIN_SCENE) as PackedScene
	if packed == null:
		_note("cannot load " + MAIN_SCENE)
		_finish()
		return
	_main = packed.instantiate()
	root.add_child(_main)
	# main._ready() is delivered when the loop starts, not necessarily here;
	# drive the probe from the first _process() tick (t_smallmap_terrain.gd:220-230).
	_phase = 1
	return


func _process(_delta: float) -> bool:
	if _finished:
		return false
	_frame += 1
	var now := Time.get_ticks_usec()
	var gap := 0
	if _t_last_us > 0:
		gap = now - _t_last_us
	_t_last_us = now
	if _t_start_us > 0 and now - _t_start_us > WALL_CAP_US:
		_note("wall-cap reached before completion; remaining assertions UNVERIFIED")
		_finish()
		return false
	if _frame > MAX_FRAMES:
		_note("frame ceiling reached before completion; remaining assertions UNVERIFIED")
		_finish()
		return false
	match _phase:
		1:
			_phase_boot()
		2:
			_phase_loading(now, gap)
		3:
			_phase_probes(gap)
		4:
			_phase_stability(gap)
	return false


func _phase_boot() -> void:
	_refresh_refs()
	var render_mode := str(_main.get("render_mode")).to_lower()
	var boot_ok := (render_mode == "3d" and int(Data.MAP_W) == 64
		and int(Data.MAP_H) == 64 and int(Data.RANDOM_SEED) == 20261113)
	_m["boot_render_mode"] = render_mode
	_m["boot_map_tiles"] = [int(Data.MAP_W), int(Data.MAP_H)]
	_m["boot_seed"] = int(Data.RANDOM_SEED)
	_m["boot_game_before_async"] = _game != null
	if not boot_ok:
		_record("real_64_game_boot", "OBSERVED", false,
			"render_mode=%s map=%dx%d seed=%d (fixture 64x64 seed 20261113)" % [
				render_mode, int(Data.MAP_W), int(Data.MAP_H), int(Data.RANDOM_SEED)],
			"main.gd:173-182,206,230-246; config.gd:523-525; small_map_64.json:10-15")
		_finish()
		return
	_record("real_64_game_boot", "OBSERVED", true,
		"render_mode=%s map=%dx%d seed=%d" % [render_mode, int(Data.MAP_W),
			int(Data.MAP_H), int(Data.RANDOM_SEED)],
		"main.gd:173-182,206,230-246; config.gd:523-525; small_map_64.json:10-15")

	# Replicate _on_menu_chosen's two calls (main.gd:256,268) without a click.
	var cfg := {
		"nation0": "rus", "nation1": "bav", "opponents": 1,
		"seed": 20261113, "mapsize": 64, "mode": "skirmish",
	}
	_main.call("_apply_menu_cfg", cfg)
	_main.call("_do_async_load", cfg)
	_note("Async load driven by Object.call('_apply_menu_cfg') + Object.call('_do_async_load'); "
		+ "a real Start-button click / chosen signal is NOT exercised (main.gd:251-268).")
	_t_start_us = Time.get_ticks_usec()
	_load_start_frame = _frame
	_phase = 2


func _phase_loading(now: int, gap: int) -> void:
	_refresh_refs()
	var active := bool(_main.get("loading_active"))
	var layer_v = _main.get("loading_layer")
	var layer_ok := layer_v != null and layer_v is Object and is_instance_valid(layer_v)
	var visible := active and layer_ok
	if visible:
		_overlay_frames += 1
		if _t_overlay_first_us < 0:
			_t_overlay_first_us = now
		if gap > _max_gap_loading_us:
			_max_gap_loading_us = gap

	var sv = _main.get("loading_stage")
	var stage := str(sv.text) if (sv is Object and is_instance_valid(sv)) else "<none>"
	var bv = _main.get("loading_bar")
	var bar := float(bv.value) if (bv is Object and is_instance_valid(bv)) else -1.0
	if stage != _last_stage:
		_stage_log.append({"stage": stage, "frame": _frame, "us": now, "bar": bar})
		_last_stage = stage

	_sample_bindings()

	if _overlay_was_visible and not visible and _t_overlay_hidden_us < 0:
		_t_overlay_hidden_us = now
		_hide_frame = _frame
		_hide_snapshot = _binding_snapshot()
		_m["overlay_visible_frames"] = _overlay_frames
		_m["overlay_first_us"] = _t_overlay_first_us
		_m["overlay_hidden_us"] = _t_overlay_hidden_us
		_m["overlay_lifetime_us"] = now - _t_overlay_first_us
		_m["hide_frame"] = _hide_frame
		_m["stage_log"] = _stage_log
		_m["max_gap_loading_us"] = _max_gap_loading_us
		_m["bind_first_frame"] = _bind_first
		_m["hide_snapshot"] = _hide_snapshot
		_begin_probes()
		_phase = 3
		_post_frame = 0
	_overlay_was_visible = visible

	if _frame - _load_start_frame > MAX_FRAMES:
		_note("loading overlay never reached hidden state within MAX_FRAMES; (a)-(e) UNVERIFIED")
		_finish()


func _begin_probes() -> void:
	_refresh_refs()
	var units: Array = []
	var units_v = _game.call("units_of", 0) if _game != null else null
	if units_v is Array:
		units = units_v
	for u in units:
		if u is Dictionary and not bool(u.get("dead", false)) and str(u.get("kind", "")) == "unit":
			_probe_unit = u
			break
	var map_lim := Vector2(float(Data.MAP_W), float(Data.MAP_H)) * float(Data.TILE_M)
	_cam_target_before = _camera.get("_target") if _camera != null else Vector2.ZERO
	_cam_pos_before = _camera.global_position if _camera != null else Vector3.ZERO
	var centre := map_lim * 0.5
	_cam_target = centre + Vector2(8.0, 0.0)
	_cam_target.x = clampf(_cam_target.x, float(Data.TILE_M), maxf(float(Data.TILE_M), map_lim.x - float(Data.TILE_M)))
	_cam_target.y = clampf(_cam_target.y, float(Data.TILE_M), maxf(float(Data.TILE_M), map_lim.y - float(Data.TILE_M)))
	if _probe_unit != null:
		var pv = _probe_unit.get("pos", Vector2.ZERO)
		var p: Vector2 = pv if pv is Vector2 else Vector2.ZERO
		_probe_dest = p + Vector2(10.0, 0.0)
		_probe_dest.x = clampf(_probe_dest.x, 0.0, map_lim.x)
		_probe_dest.y = clampf(_probe_dest.y, 0.0, map_lim.y)
		# Direct calls into the bound controller are the observable proxy:
		# real synthetic mouse events in headless are UNVERIFIED.
		_input.call("_set_selection", [_probe_unit])
		_input.call("minimap_order", _probe_dest)
	_camera.call("apply_external_target", _cam_target)
	_probe_started = true
	_m["probe_unit_found"] = _probe_unit != null
	_m["camera_target_requested"] = [_cam_target.x, _cam_target.y]
	_m["order_dest_requested"] = [_probe_dest.x, _probe_dest.y]


func _phase_probes(gap: int) -> void:
	_post_frame += 1
	if gap > _max_gap_post_us:
		_max_gap_post_us = gap
	_refresh_refs()
	_sample_bindings()
	if _probe_started:
		if _resp_input_frame < 0 and _probe_unit != null:
			var ids_v = _input.get("selected_ids")
			var ids: Array = ids_v if ids_v is Array else []
			if ids.has(_probe_unit.get("id", -1)):
				_resp_input_frame = _post_frame
		if _resp_order_frame < 0 and _probe_unit != null:
			var od_v = _probe_unit.get("order", {})
			var od: Dictionary = od_v if od_v is Dictionary else {}
			var ty := str(od.get("type", ""))
			if ty == "move" or ty == "attack_move":
				_resp_order_frame = _post_frame
		if _resp_camera_frame < 0 and _camera != null:
			var tgt_v = _camera.get("_target")
			var tgt: Vector2 = tgt_v if tgt_v is Vector2 else Vector2.ZERO
			var pos: Vector3 = _camera.global_position
			var moved_tgt := tgt.is_finite() and tgt.distance_to(_cam_target_before) > POS_TOL_M
			var moved_pos := pos.is_finite() and pos.distance_to(_cam_pos_before) > 0.01
			if moved_tgt and moved_pos:
				_resp_camera_frame = _post_frame
	var done := _resp_camera_frame >= 0 and (_probe_unit == null or (_resp_input_frame >= 0 and _resp_order_frame >= 0))
	if done or _post_frame >= RESPONSE_FRAMES:
		_m["response_frames"] = {
			"input": _resp_input_frame,
			"order": _resp_order_frame,
			"camera": _resp_camera_frame,
			"window": RESPONSE_FRAMES,
		}
		_begin_stability()


func _begin_stability() -> void:
	_refresh_refs()
	_base_children = _main.get_child_count()
	var ents_v = _game.get("entities") if _game != null else null
	_base_entities = (ents_v as Array).size() if ents_v is Array else -1
	_post_frame = 0
	_phase = 4


func _phase_stability(gap: int) -> void:
	_post_frame += 1
	if gap > _max_gap_post_us:
		_max_gap_post_us = gap
	_refresh_refs()
	_sample_bindings()
	var active := bool(_main.get("loading_active"))
	var layer_v = _main.get("loading_layer")
	var layer_ok := layer_v != null and layer_v is Object and is_instance_valid(layer_v)
	if active or layer_ok:
		_stable_violations += 1
	if _main.get_child_count() != _base_children:
		_stable_violations += 1
	var ents_v = _game.get("entities") if _game != null else null
	var ec := (ents_v as Array).size() if ents_v is Array else -1
	if ec != _base_entities:
		_stable_violations += 1
	if gap > STALL_LIMIT_US:
		_stable_violations += 1
	_m["stability_violations"] = _stable_violations
	_m["max_gap_post_us"] = _max_gap_post_us
	if _post_frame >= STABILITY_FRAMES:
		_finish()


func _finish() -> void:
	if _finished:
		return
	_finished = true

	_m["display_server"] = _display_server
	_m["headless"] = _headless
	_m["frames"] = _frame
	_m["fixture"] = FIXTURE
	_m["boot_mode"] = "atom-forced _do_async_load via Object.call (proxy for menu Start)"
	_m["source_revision_note"] = "main.gd read-only; LOAD-ASYNC-01 owns it and may change stage layout"

	_record("headless_guard", "OBSERVED" if _headless else "UNVERIFIED", _headless,
		"display_server=%s; probe is headless-only" % _display_server,
		"tests/README.md:77-78; TEST_01_smallmap_harness.md:79; t_forest_bake_render.gd:36-41")

	# Supporting observation: the staged overlay really existed and repainted.
	var overlay_seen := _overlay_frames > 0 and _stage_log.size() >= 2
	_record("staged_overlay_observed", "OBSERVED" if overlay_seen else "UNVERIFIED", overlay_seen,
		"overlay_frames=%d stage_transitions=%d first=%s last=%s" % [
			_overlay_frames, _stage_log.size(),
			str(_stage_log[0].get("stage", "<none>")) if _stage_log.size() > 0 else "<none>",
			str(_stage_log[_stage_log.size() - 1].get("stage", "<none>")) if _stage_log.size() > 0 else "<none>"],
		"main.gd:458-501,530-645 (_show_loading/_set_loading/_do_async_load)")

	# (a) exact main-thread stall around _loading_tick stages is NOT observable
	# from a sibling SceneTree: we cannot bracket the per-stage calls inside
	# main.gd, and there is no signal/timing field. Report proxies only.
	var max_stage_us := -1
	if _stage_log.size() >= 2:
		for i in range(1, _stage_log.size()):
			var d := int(_stage_log[i].get("us", 0)) - int(_stage_log[i - 1].get("us", 0))
			if d > max_stage_us:
				max_stage_us = d
	_m["max_stage_to_stage_us"] = max_stage_us
	_record("a_longest_main_thread_stall", "UNVERIFIED", null,
		"Exact per-stage stall UNVERIFIED (requires instrumentation inside main.gd/_loading_tick, "
		+ "owned by LOAD-ASYNC-01). Proxies: max_inter_frame_gap_loading_us=%d, max_stage_to_stage_us=%d" % [
			_max_gap_loading_us, max_stage_us],
		"main.gd:521-528,550-576; PROGRESS.md:104-113; UX_LOADING.md:54-55")

	# (b) overlay hidden only after world/camera/HUD/input are bound.
	if _hide_snapshot.is_empty():
		_record("b_bindings_before_overlay_hide", "UNVERIFIED", null,
			"No overlay-hidden transition observed; cannot check binding order.",
			"main.gd:512-519,576-645")
	else:
		var all_bound_before := bool(_hide_snapshot.get("all_bound", false))
		for k in _bind_first.keys():
			if int(_bind_first[k]) > _hide_frame:
				all_bound_before = false
		for k in _hide_snapshot.keys():
			if str(k) == "all_bound":
				continue
			if not _bind_first.has(str(k)):
				all_bound_before = false
		_record("b_bindings_before_overlay_hide", "OBSERVED", all_bound_before,
			"hide_frame=%d all_bound_at_hide=%s missing_or_late=%s" % [
				_hide_frame, str(_hide_snapshot.get("all_bound", false)),
				str(_late_bindings())],
			"main.gd:512-519,576-645; world3d.gd:599-602; camera3d.gd:171-174; "
			+ "hud.gd:167-169,201-213; input_controller.gd:129-134,172-185; UX_LOADING.md:56,70")

	# (c) post-hide responsiveness within a bounded frame count.
	if _probe_unit == null:
		_record("c_input_response", "UNVERIFIED", null,
			"No live player-0 unit found for a selection/order probe.", "input_controller.gd:297-315,387-400")
		_record("c_order_response", "UNVERIFIED", null,
			"No live player-0 unit found for an order probe.", "input_controller.gd:297-315,387-400")
	else:
		_record("c_input_response", "OBSERVED",
			_resp_input_frame >= 0 and _resp_input_frame <= RESPONSE_FRAMES,
			"selected_ids contained probe unit at frame %d (window=%d); proxy: direct _set_selection call "
			+ "in headless, real mouse events UNVERIFIED" % [_resp_input_frame, RESPONSE_FRAMES],
			"main.gd:627-634; input_controller.gd:305-315")
		_record("c_order_response", "OBSERVED",
			_resp_order_frame >= 0 and _resp_order_frame <= RESPONSE_FRAMES,
			"unit.order.type in {move,attack_move} at frame %d (window=%d)" % [
				_resp_order_frame, RESPONSE_FRAMES],
			"main.gd:627-629; input_controller.gd:387-400")
	_record("c_camera_response", "OBSERVED",
		_resp_camera_frame >= 0 and _resp_camera_frame <= RESPONSE_FRAMES,
		"apply_external_target -> _target/global_position changed at frame %d (window=%d)" % [
			_resp_camera_frame, RESPONSE_FRAMES],
		"main.gd:605,643-645; camera3d.gd:444-452,511-519")

	# (d) literal "no deferred heavy stage still running" is UNVERIFIED: main.gd
	# exposes no deferred-stage flag. Only bounded post-hide stability is observed.
	_record("d_no_deferred_heavy_stage", "UNVERIFIED", null,
		"No deferred-stage API exists to inspect. Proxies over %d frames: violations=%d, "
		+ "max_inter_frame_gap_post_us=%d (heuristic ceiling %d)" % [
			STABILITY_FRAMES, _stable_violations, _max_gap_post_us, STALL_LIMIT_US],
		"main.gd:512-519,643-645; tests/README.md:3-33; UX_LOADING.md:71,92-97")

	# (e) hard engine errors cannot be read from GDScript (no stderr API).
	_record("e_no_hard_engine_errors", "UNVERIFIED", null,
		"GDScript cannot read runner stderr; scan the job stderr with "
		+ "smallmap_capture.py scan-stderr and require script_error_lines == 0.",
		"TEST_01_smallmap_harness.md:89-92,298; t_smallmap_terrain.gd:19-20,72")

	_record("no_pass_claim", "OBSERVED", true,
		"verdict=MEASUREMENT_ONLY__NO_PASS_CLAIM; this atom is not a gate.",
		"docs/coord_swarm_2026-11-25/CHARTER.md:75-86")

	var out := {
		"id": OUT_ID,
		"verdict": "MEASUREMENT_ONLY__NO_PASS_CLAIM",
		"gate_claim": "NONE",
		"pass_claim": false,
		"checks": _checks,
		"measured": _m,
		"notes": _notes,
		"limitations": [
			"Async overlay is reached by calling main.gd's private handlers, not by a real Start click.",
			"Assertion (a) exact per-stage main-thread stall requires instrumentation in main.gd (LOAD-ASYNC-01).",
			"Inter-frame gaps are wall-clock proxies, not isolated main-thread busy time.",
			"Assertion (d) has no literal observable; only bounded stability proxies were measured.",
			"Assertion (e) needs an external runner stderr scan (no GDScript stderr API).",
			"Windowed window-freeze/paint responsiveness cannot be reproduced headless; UNVERIFIED.",
		],
		"script_error_note": "verify via smallmap_capture.py scan-stderr on runner stderr.txt",
		"unix_ms": Time.get_unix_time_from_system() * 1000.0,
	}
	_write(out)
	print("T_LOAD_USABILITY VERDICT: MEASUREMENT_ONLY__NO_PASS_CLAIM")
	call_deferred("quit", 0)


func _late_bindings() -> Array[String]:
	var late: Array[String] = []
	for k in _hide_snapshot.keys():
		if str(k) == "all_bound":
			continue
		if not bool(_hide_snapshot[k]) or not _bind_first.has(str(k)) or int(_bind_first[str(k)]) > _hide_frame:
			late.append(str(k))
	return late


func _write(out: Dictionary) -> void:
	var abs_dir := ProjectSettings.globalize_path(OUT_DIR)
	DirAccess.make_dir_recursive_absolute(abs_dir)
	var path := "%s/%s.json" % [abs_dir, OUT_ID]
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_error("t_load_usability: cannot write " + path)
		return
	f.store_string(JSON.stringify(out, "\t"))
	f.close()
	print("T_LOAD_USABILITY RESULT_JSON: " + path)
