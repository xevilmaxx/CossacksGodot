# T-PICK-RES: _pick_res spatial-hash regression test.
# Builds a map, picks at a known tree position (must return that tree), picks
# far away (must be null), and verifies the cached grid invalidates after a
# harvest bumps game.res_dirty (the depleted tree becomes a stump and is skipped).
extends SceneTree

const Data = preload("res://scripts/data.gd")
const C3Game = preload("res://scripts/game.gd")
const C3Input = preload("res://scripts/input_controller.gd")

const OUT_DIR := "res://tests/results"

var _id := "t_pick_res"
var _checks: Array[Dictionary] = []
var _ok := true

func check(name: String, cond: bool, detail: String = "") -> void:
	_checks.append({"name": name, "passed": cond, "detail": detail})
	if not cond:
		_ok = false

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
		"unix_ms": Time.get_unix_time_from_system() * 1000.0,
	}, "\t"))
	f.close()

func _initialize() -> void:
	Data.AI_ENABLED = false
	var game = C3Game.new()
	root.add_child(game)
	game.setup("skirmish")

	var inp = C3Input.new()
	inp.game = game

	# First live wood tree (radius 0.7, type "wood") is our known target.
	var tree: Dictionary = {}
	for n in game.res_nodes:
		if str(n.get("type", "")) == "wood" and int(n.get("hits", 0)) > 0:
			tree = n
			break
	check("live tree exists", not tree.is_empty(), "res_nodes=%d" % game.res_nodes.size())

	var pw: Vector2 = tree.get("pos", Vector2.ZERO)

	# Nothing built before the first pick (lazy).
	check("grid not built before first pick", inp._pick_res_ver == -1,
		"ver=%d" % inp._pick_res_ver)

	# Pick at the exact tree position -> that tree.
	var got: Dictionary = inp._pick_res(pw)
	check("pick returns known tree", not got.is_empty() and int(got.get("id", -1)) == int(tree.get("id", -2)),
		"got=%s want=%s" % [str(got.get("id")), str(tree.get("id"))])

	# First pick built the grid at the current res_dirty / array size.
	check("grid built lazily", inp._pick_res_ver == game.res_dirty and inp._pick_res_size == game.res_nodes.size(),
		"ver=%d dirty=%d size=%d" % [inp._pick_res_ver, game.res_dirty, inp._pick_res_size])

	# Pick far away -> null.
	var far: Dictionary = inp._pick_res(Vector2(-100000.0, -100000.0))
	check("far pick returns null", far.is_empty(), "got=%s" % str(far.get("id")))

	# Harvest: deplete the tree into a stump and bump res_dirty (as game does).
	var ver_before: int = inp._pick_res_ver
	tree["hits"] = 0
	tree["type"] = "stump"
	game.res_dirty += 1
	var after: Dictionary = inp._pick_res(pw)
	check("depleted stump skipped", after.is_empty(), "got=%s" % str(after.get("id")))
	check("grid invalidated on res_dirty", inp._pick_res_ver == game.res_dirty and inp._pick_res_ver != ver_before,
		"ver_before=%d ver_after=%d dirty=%d" % [ver_before, inp._pick_res_ver, game.res_dirty])

	# Shrinking the node set also invalidates (size guard), no stale cells.
	game.res_nodes.clear()
	game.res_dirty += 1
	var empty: Dictionary = inp._pick_res(pw)
	check("size change rebuilds empty grid", empty.is_empty() and inp._pick_res_size == 0,
		"size=%d got=%s" % [inp._pick_res_size, str(empty.get("id"))])

	_write_result()
	call_deferred("quit", 0 if _ok else 1)
