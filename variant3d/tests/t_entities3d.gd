# V7-34 atomic test — world3d_entities API (V73_ATOMIC_CONTRACT.md:13,26-30).
#
# Scope: dynamic load, instantiate, bind a STUB game with deterministic
# unit/building/resource dictionaries, add/sync/remove, node-count lifecycle,
# and NO sprite-sheet texture loads.
#
# Sprite-sheet method (LABEL): GDScript cannot intercept the global load() /
# ResourceLoader, so this test uses a STRUCTURAL SOURCE SCAN of the module
# (comment-stripped) plus a RUNTIME NODE SCAN of the instance subtree. This is
# a static detection method, not a runtime ResourceLoader spy.
#
# Headless, self-exiting via call_deferred("quit", ...). Never bare quit().
extends SceneTree

const OUT_DIR := "res://tests/results"
const MODULE_PATH := "res://scripts/world3d_entities.gd"
const RESULT_ID := "v734_entities3d"

var _id := RESULT_ID
var _checks: Array[Dictionary] = []
var _ok := true
var _internal_errors := 0

# Minimal sim stand-in: only fields the entities module is contractually
# allowed to read. Unknown property reads return null instead of erroring.
class StubGame extends RefCounted:
	var entities: Array[Dictionary] = []
	var res_nodes: Array[Dictionary] = []
	var by_id: Dictionary = {}
	var players: Array = [{"id": 0, "entities": []}]
	var fog_explored: Array = []
	var fog_vis: Array = []
	var map_w: int = 64
	var map_h: int = 64
	var tile: float = 1.0
	var time_s: float = 0.0
	var res_dirty: int = 0
	var selected: Dictionary = {}

	func _get(_property: StringName) -> Variant:
		# Unknown probes are harmless; the test never mutates game state.
		return null

	func tile_visible(_p: Vector2) -> bool:
		return true

	func has_chunk_or_fallback() -> bool:
		return true

func check(name: String, cond: bool, detail: String = "") -> void:
	_checks.append({"name": name, "passed": cond, "detail": detail})
	if not cond:
		_ok = false
	print("CHECK ", "PASS" if cond else "FAIL", " ", name, " :: ", detail)

func _write_result(extra: Dictionary = {}) -> void:
	var abs_dir := ProjectSettings.globalize_path(OUT_DIR)
	DirAccess.make_dir_recursive_absolute(abs_dir)
	var path := "%s/%s.json" % [abs_dir, _id]
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_error("cannot write test result: " + path)
		return
	var payload := {
		"id": _id,
		"passed": _ok,
		"checks": _checks,
		"module": MODULE_PATH,
		"sprite_check_method": "structural source scan (comment-stripped) + runtime node scan; no runtime ResourceLoader interception in GDScript",
		"internal_errors": _internal_errors,
		"unix_ms": Time.get_unix_time_from_system() * 1000.0,
	}
	for k in extra.keys():
		payload[k] = extra[k]
	f.store_string(JSON.stringify(payload, "\t"))
	f.close()

func _count_nodes(n: Node) -> int:
	if n == null:
		return 0
	var c := 1
	for ch in n.get_children():
		c += _count_nodes(ch)
	return c

func _scan_sprite_nodes(n: Node, found: Array[String]) -> void:
	if n == null:
		return
	if n is Sprite2D or n is AnimatedSprite2D or n is Sprite3D or n is AnimatedSprite3D:
		found.append(str(n.name))
	for ch in n.get_children():
		_scan_sprite_nodes(ch, found)

func _strip_comments(src: String) -> String:
	var out := PackedStringArray()
	for line in src.split("\n"):
		out.append(line.split("#", false, 1)[0])
	return "\n".join(out)

func _call_if(inst: Object, method: String, arg: Variant = null, has_arg: bool = false) -> bool:
	if inst == null or not inst.has_method(method):
		_internal_errors += 1
		check("api_" + method, false, "missing method " + method)
		return false
	if has_arg:
		inst.call(method, arg)
	else:
		inst.call(method)
	return true

func _make_entities() -> Array[Dictionary]:
	var u1 := {
		"id": 9001, "kind": "unit", "player": 0, "sid": "peasant",
		"def": {"hp": 60, "radius": 0.45, "height": 1.9, "speed": 3.0,
			"model": "peasant", "tex": "peasant", "build_time": 0.0},
		"pos": Vector2(10.0, 10.0), "hp": 60, "max_hp": 60, "dead": false,
		"moving": false, "face": 0.0, "finished": true, "selected": false,
	}
	var u2 := {
		"id": 9002, "kind": "unit", "player": 0, "sid": "archer",
		"def": {"hp": 45, "radius": 0.42, "height": 1.9, "speed": 3.2,
			"model": "archer", "tex": "archer", "build_time": 0.0},
		"pos": Vector2(12.0, 10.0), "hp": 45, "max_hp": 45, "dead": false,
		"moving": true, "face": 1.5708, "finished": true, "selected": false,
	}
	var b1 := {
		"id": 9003, "kind": "building", "player": 0, "sid": "hou",
		"def": {"hp": 500, "radius": 2.0, "height": 5.5, "speed": 0.0,
			"model": "hou", "tex": "hou", "build_time": 1.0},
		"pos": Vector2(24.0, 24.0), "hp": 500, "max_hp": 500, "dead": false,
		"finished": true, "progress": 1.0, "face": 0.0, "selected": false,
	}
	return [u1, u2, b1]

func _make_resources() -> Array[Dictionary]:
	var n1 := {"id": 9004, "kind": "res", "type": "wood", "pos": Vector2(30.0, 18.0),
		"hits": 60, "max_hits": 60, "radius": 0.7}
	var n2 := {"id": 9005, "kind": "res", "type": "stone", "pos": Vector2(34.0, 20.0),
		"hits": 80, "max_hits": 80, "radius": 0.9}
	return [n1, n2]

func _initialize() -> void:
	# MODULE_MISSING is an explicit terminal check (report status BLOCKED).
	if not ResourceLoader.exists(MODULE_PATH):
		check("MODULE_MISSING", false, MODULE_PATH + " not found under --path variant3d")
		_write_result({"status": "BLOCKED", "reason": "MODULE_MISSING"})
		call_deferred("quit", 1)
		return

	var script_res: Resource = load(MODULE_PATH)
	var ok_script: bool = script_res != null and script_res is GDScript
	check("module_loads", ok_script, "load(%s) -> %s" % [MODULE_PATH,
		"GDScript" if ok_script else str(script_res)])
	if not ok_script:
		check("MODULE_MISSING", false, "module did not load as GDScript")
		_write_result({"status": "BLOCKED", "reason": "MODULE_MISSING"})
		call_deferred("quit", 1)
		return

	var inst: Object = (script_res as GDScript).new()
	var ok_inst: bool = inst != null and inst is Node
	check("instantiates", ok_inst, "new() -> " + str(inst))
	if not ok_inst:
		_internal_errors += 1
		_write_result({"status": "BLOCKED", "reason": "MODULE_NOT_NODE"})
		call_deferred("quit", 1)
		return

	root.add_child(inst as Node)

	var required := ["bind", "sync", "add_unit", "add_building", "add_resource", "remove"]
	var missing: Array[String] = []
	for m in required:
		if not inst.has_method(m):
			missing.append(m)
	check("api_surface", missing.is_empty(), "missing=" + str(missing))
	_internal_errors += missing.size()
	if not missing.is_empty():
		_write_result({"status": "BLOCKED", "reason": "API_MISMATCH"})
		call_deferred("quit", 1)
		return

	var game := StubGame.new()
	var units := _make_entities()
	var res_nodes := _make_resources()
	for u in units:
		game.entities.append(u)
		game.by_id[int(u["id"])] = u
	for n in res_nodes:
		game.res_nodes.append(n)
		game.by_id[int(n["id"])] = n

	_call_if(inst, "bind", game, true)
	var before := _count_nodes(inst as Node)

	for u in units:
		if str(u["kind"]) == "unit":
			_call_if(inst, "add_unit", u, true)
		else:
			_call_if(inst, "add_building", u, true)
	for n in res_nodes:
		_call_if(inst, "add_resource", n, true)
	_call_if(inst, "sync", 0.016, true)

	var peak := _count_nodes(inst as Node)
	check("node_count_grows", peak > before, "before=%d after_add_and_sync=%d" % [before, peak])

	# remove() is one id at a time; all ids must be accepted deterministically.
	for k in [9001, 9002, 9003, 9004, 9005]:
		_call_if(inst, "remove", k, true)
	var after := _count_nodes(inst as Node)
	check("node_count_shrinks", after < peak, "peak=%d after_remove=%d" % [peak, after])
	check("remove_below_baseline", after <= before, "before=%d after_remove=%d" % [before, after])

	# LABEL: structural source scan (GDScript cannot spy ResourceLoader).
	var forbidden := [
		"res://assets/models/anim", "assets/models/anim", "models/anim/",
		"sprites_hi", "models/sprites", "Sprite2D", "AnimatedSprite2D",
		"SpriteFrames", "AtlasTexture", "AnimatedSprite3D",
	]
	var src := ""
	var f := FileAccess.open(ProjectSettings.globalize_path(MODULE_PATH), FileAccess.READ)
	if f != null:
		src = _strip_comments(f.get_as_text())
		f.close()
	var hits: Array[String] = []
	for pat in forbidden:
		if src.find(pat) >= 0:
			hits.append(str(pat))
	var sprite_nodes: Array[String] = []
	_scan_sprite_nodes(inst as Node, sprite_nodes)
	var no_sheets: bool = hits.is_empty() and sprite_nodes.is_empty()
	check("no_sprite_sheet_loads", no_sheets,
		"METHOD: structural source scan + runtime node scan; forbidden_patterns=%s sprite_nodes=%s" % [str(hits), str(sprite_nodes)])

	check("no_internal_errors", _internal_errors == 0, "count=%d" % _internal_errors)

	_write_result({"status": "DONE", "counts": {"before": before, "peak": peak, "after": after}})
	call_deferred("quit", 0 if _ok else 1)
