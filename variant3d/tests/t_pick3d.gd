# T-PICK3D: contract test for res://scripts/picking3d.gd (V7-3 ATOMIC API).
# Loads the module DYNAMICALLY (no class_name needed), instantiates it, binds it
# to a stub game + stub camera, and asserts:
#   1. module loads
#   2. ground_point(screen centre) is finite
#   3. pick() returns a Dictionary
#   4. pick_res() returns a Dictionary
#   5. NO game.cmd_* calls occur (stub counts every cmd_* invocation)
# If the module is absent -> FAIL MODULE_MISSING (BLOCKED-PENDING-MODULE);
# the real assertions are kept, never weakened.
# Headless; self-exits via call_deferred; NEVER quit() directly in _initialize().
extends SceneTree

const MODULE_PATH := "res://scripts/picking3d.gd"
const OUT_DIR := "res://tests/results"
const SCREEN_CENTRE := Vector2(640.0, 360.0)

var _id := "t_pick3d"
var _checks: Array[Dictionary] = []
var _ok := true

func check(name: String, cond: bool, detail: String = "") -> void:
	_checks.append({"name": name, "passed": cond, "detail": detail})
	if not cond:
		_ok = false

func _fail_remaining(names: Array, detail: String) -> void:
	for n in names:
		check(str(n), false, detail)

func _write_result() -> void:
	var abs_dir := ProjectSettings.globalize_path(OUT_DIR)
	DirAccess.make_dir_recursive_absolute(abs_dir)
	var path := "%s/%s.json" % [abs_dir, _id]
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_error("cannot write test result: " + path)
		return
	f.store_string(JSON.stringify({
		"id": _id,
		"passed": _ok,
		"checks": _checks,
		"module_path": MODULE_PATH,
		"unix_ms": Time.get_unix_time_from_system() * 1000.0,
	}, "\t"))
	f.close()

# ---------------------------------------------------------------------------
# Stub game: minimal state a picker needs + an explicit counter for EVERY
# cmd_* method the real game.gd exposes (24 methods). Any cmd_* call from the
# module is recorded here, so "no side effects" is measured, not assumed.
# ---------------------------------------------------------------------------
class StubGame extends Node:
	var cmd_calls: Dictionary = {}
	var entities: Array = []
	var units: Array = []
	var buildings: Array = []
	var res_nodes: Array = []
	var res_dirty: int = 0

	func _bump(m: String) -> void:
		cmd_calls[m] = int(cmd_calls.get(m, 0)) + 1

	func pick_radius(_e: Dictionary) -> float:
		return 1.0

	func total_cmd_calls() -> int:
		var n := 0
		for v in cmd_calls.values():
			n += int(v)
		return n

	func cmd_sow(a = null, b = null, c = null) -> int:
		_bump("cmd_sow")
		return 0

	func cmd_move(a = null, b = null, c = null) -> void:
		_bump("cmd_move")

	func cmd_attack(a = null, b = null, c = null) -> void:
		_bump("cmd_attack")

	func cmd_attack_move(a = null, b = null, c = null) -> void:
		_bump("cmd_attack_move")

	func cmd_gather(a = null, b = null, c = null) -> void:
		_bump("cmd_gather")

	func cmd_resow(a = null, b = null, c = null) -> void:
		_bump("cmd_resow")

	func cmd_build(a = null, b = null, c = null) -> void:
		_bump("cmd_build")

	func cmd_stand_ground(a = null, b = null, c = null) -> void:
		_bump("cmd_stand_ground")

	func cmd_no_stand_ground(a = null, b = null, c = null) -> void:
		_bump("cmd_no_stand_ground")

	func cmd_hold_fire(a = null, b = null, c = null) -> void:
		_bump("cmd_hold_fire")

	func cmd_engage(a = null, b = null, c = null) -> void:
		_bump("cmd_engage")

	func cmd_stop(a = null, b = null, c = null) -> void:
		_bump("cmd_stop")

	func cmd_guard(a = null, b = null, c = null) -> void:
		_bump("cmd_guard")

	func cmd_cancel_guard(a = null, b = null, c = null) -> void:
		_bump("cmd_cancel_guard")

	func cmd_patrol(a = null, b = null, c = null) -> void:
		_bump("cmd_patrol")

	func cmd_attack_ground(a = null, b = null, c = null) -> void:
		_bump("cmd_attack_ground")

	func cmd_enter(a = null, b = null, c = null) -> void:
		_bump("cmd_enter")

	func cmd_unload(a = null, b = null, c = null) -> void:
		_bump("cmd_unload")

	func cmd_replenish(a = null, b = null, c = null) -> int:
		_bump("cmd_replenish")
		return 0

	func cmd_form_size(a = null, b = null, c = null) -> void:
		_bump("cmd_form_size")

	func cmd_make_gate(a = null, b = null, c = null) -> void:
		_bump("cmd_make_gate")

	func cmd_gate_toggle(a = null, b = null, c = null) -> void:
		_bump("cmd_gate_toggle")

	func cmd_repair(a = null, b = null, c = null) -> void:
		_bump("cmd_repair")

	func cmd_delete(a = null, b = null, c = null) -> void:
		_bump("cmd_delete")

# ---------------------------------------------------------------------------
# Stub camera: the camera3d.gd API from the contract. screen_to_world() is
# deliberately finite/identity so a correct ground_point() is measurable.
# ---------------------------------------------------------------------------
class StubCam extends Camera3D:
	var view_scale: float = 1.0

	func bind(game = null, view_scale: float = 1.0) -> void:
		self.view_scale = view_scale

	func world_to_px(world: Vector2) -> Vector2:
		return world

	func screen_to_world(screen: Vector2) -> Vector2:
		return screen

	func clamp_pos() -> void:
		pass

	func get_view_rect() -> Rect2:
		return Rect2(-640.0, -360.0, 1280.0, 720.0)

	func get_viewport_corners() -> Array:
		return [
			Vector2(-640.0, -360.0), Vector2(640.0, -360.0),
			Vector2(640.0, 360.0), Vector2(-640.0, 360.0),
		]

	func zoom_step(notches = 0, anchor = null) -> void:
		pass

	func set_zoom_target(target = null, immediate: bool = false) -> void:
		pass

func _initialize() -> void:
	var remaining := [
		"instantiates", "ground_point finite", "pick returns Dictionary",
		"pick_res returns Dictionary", "no cmd_* calls",
	]

	# 1. Module must exist AND load. Missing file -> explicit FAIL MODULE_MISSING.
	if not ResourceLoader.exists(MODULE_PATH):
		check("module loads", false, "MODULE_MISSING")
		_fail_remaining(remaining, "NOT_RUN: MODULE_MISSING")
		_write_result()
		call_deferred("quit", 1)
		return

	var script: Script = load(MODULE_PATH) as Script
	check("module loads", script != null, "load() returned null (parse error?)")
	if script == null:
		_fail_remaining(remaining, "NOT_RUN: module load failed")
		_write_result()
		call_deferred("quit", 1)
		return

	# 2. Instantiate + bind to stubs (module is a Node per the contract).
	var inst: Variant = script.new()
	var picker: Node = inst as Node
	check("instantiates", picker != null, "script.new() did not return a Node")
	if picker == null:
		_fail_remaining(remaining.slice(1), "NOT_RUN: instantiation failed")
		_write_result()
		call_deferred("quit", 1)
		return
	root.add_child(picker)

	var stub_game := StubGame.new()
	var stub_cam := StubCam.new()
	root.add_child(stub_game)
	root.add_child(stub_cam)
	if picker.has_method("bind"):
		picker.call("bind", stub_game, stub_cam)

	# 3. ground_point(screen centre) must be a finite Vector2.
	var gp: Variant = picker.call("ground_point", SCREEN_CENTRE)
	var gp_ok: bool = gp is Vector2 and (gp as Vector2).is_finite()
	check("ground_point finite", gp_ok, "ground_point=%s" % str(gp))

	# 4. pick() -> Dictionary (empty Dictionary is the legal "nothing hit").
	var pk: Variant = picker.call("pick", SCREEN_CENTRE)
	check("pick returns Dictionary", pk is Dictionary, "pick=%s" % str(pk))

	# 5. pick_res() -> Dictionary (empty Dictionary is the legal "nothing hit").
	var pr: Variant = picker.call("pick_res", SCREEN_CENTRE)
	check("pick_res returns Dictionary", pr is Dictionary, "pick_res=%s" % str(pr))

	# 6. No side effects: every cmd_* call on the stub game is a failure.
	var calls: int = stub_game.total_cmd_calls()
	check("no cmd_* calls", calls == 0, "cmd_calls=%s" % str(stub_game.cmd_calls))

	_write_result()
	call_deferred("quit", 0 if _ok else 1)
