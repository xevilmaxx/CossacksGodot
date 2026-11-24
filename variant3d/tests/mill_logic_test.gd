# Focused regression test for the strict mill + field (food) loop.
# Run with:
#   godot --headless --path app --script res://tests/mill_logic_test.gd
extends SceneTree

const Data = preload("res://scripts/data.gd")
const C3Game = preload("res://scripts/game.gd")
const OUT_DIR := "res://tests/results"

var _id := "t_mill_logic"
var game
var checks: Array = []

func _check(name: String, ok: bool, detail: String) -> void:
	checks.append({"name": name, "passed": ok, "detail": detail})
	print(("  PASS  " if ok else "  FAIL  ") + name + " - " + detail)

func _initialize() -> void:
	game = C3Game.new()
	root.add_child(game)
	Data.AI_ENABLED = false
	game.setup("skirmish")

	# T-MILL-CORE strict cycle: a fresh map carries ZERO wild food.
	# Food exists only as mill-owned fields.
	var wild := 0
	for n in game.res_nodes:
		if str(n.type) == "food":
			wild += 1
	_check("no_wild_food", wild == 0, "wild food nodes=%d" % wild)

	# Build a finished mill on clear ground by the town center (the start
	# zone is keep-clear, so the drop point is always reachable).
	var anchor := Vector2.ZERO
	for e in game.entities:
		if not e.dead and str(e.get("kind", "")) == "building" and int(e.get("player", -1)) == 0:
			anchor = e.pos
			break
	var mill_pos := anchor + Vector2(8, 0)
	for cand in [Vector2(8, 0), Vector2(-8, 0), Vector2(0, 8), Vector2(0, -8), Vector2(8, 8)]:
		if game.in_bounds(anchor + cand) and not game.is_blocked(anchor + cand):
			mill_pos = anchor + cand
			break
	game.players[0].res[3] += 1000.0
	var mill = game.spawn("mil", 0, mill_pos, true)
	_check("mill_is_drop", Data.BUILDINGS["mil"].get("stores", []).has("food"),
		"mill stores food")
	var fields: Array = []
	for n in game.res_nodes:
		if n.has("mill") and int(n.mill) == int(mill.id):
			fields.append(n)
	_check("mill_sows_ring", fields.size() > 0,
		"mill-owned fields=%d (cap %d)" % [fields.size(), game.MAX_FIELDS_PER_MILL])
	if fields.is_empty():
		return _finish()
	# Gather from the field nearest the mill: shortest delivery walk.
	var field: Dictionary = fields[0]
	var best_d := 1e9
	for n in fields:
		var d: float = (n.pos as Vector2).distance_to(mill.pos)
		if d < best_d:
			best_d = d
			field = n

	# --- gather from a mill field reaches the player ------------------
	var p0 = game.spawn("peasant", 0, field.pos + Vector2(2, 0))
	game.cmd_gather(p0, field)
	var f0: float = game.players[0].res[0]
	for i in 400:
		game.tick(0.25)
	_check("food_reaches_mill", game.players[0].res[0] > f0,
		"food %.1f -> %.1f" % [f0, game.players[0].res[0]])

	# --- depleted mill field: paid resow (20 food / 2 s) --------------
	var resow_field: Dictionary = fields[1] if fields.size() > 1 else fields[0]
	resow_field.hits = 0
	var rp = game.spawn("peasant", 0, resow_field.pos + Vector2(1, 0))
	game.players[0].res[0] += 500.0
	game.cmd_resow(rp, resow_field)
	for i in 160:
		game.tick(0.25)
	_check("resow_restores_field", int(resow_field.hits) > 0,
		"paid resow hits 0 -> %d" % int(resow_field.hits))

	# --- depleted mill field: FREE regrow with finished mill -----------
	var free_field: Dictionary = fields[2] if fields.size() > 2 else fields[0]
	free_field.hits = 0
	var food_before: float = game.players[0].res[0]
	for i in 280:
		game.tick(0.25)
	_check("mill_regrows_free", int(free_field.hits) > 0,
		"free regrow hits 0 -> %d (food %.0f -> %.0f, no resow order)" % [
			int(free_field.hits), food_before, game.players[0].res[0]])

	_finish()

func _finish() -> void:
	var ok := true
	for c in checks:
		if not c.passed:
			ok = false
	print("mill_logic_test: %d/%d checks passed" % [
		checks.filter(func(c): return c.passed).size(), checks.size()])
	_write_result(ok)
	call_deferred("quit", 0 if ok else 1)

func _write_result(ok: bool) -> void:
	var abs_dir := ProjectSettings.globalize_path(OUT_DIR)
	DirAccess.make_dir_recursive_absolute(abs_dir)
	var path := "%s/%s.json" % [abs_dir, _id]
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_error("cannot write test result: " + path)
		return
	f.store_string(JSON.stringify({
		"id": _id,
		"passed": ok,
		"checks": checks,
		"unix_ms": Time.get_unix_time_from_system() * 1000.0,
	}, "\t"))
	f.close()
