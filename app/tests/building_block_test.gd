# Dedicated regression test: a building is a solid 2D block.
# Units must not be able to walk into the drawn sprite from ANY direction,
# including the tall part that rises above the ground anchor ("under/above").
#
# Run with:
#   godot --headless --path app --script res://tests/building_block_test.gd
extends SceneTree

const Data = preload("res://scripts/data.gd")
const C3Game = preload("res://scripts/game.gd")
const OUT_DIR := "res://tests/results"

var _id := "t_build_flow"
var game
var checks: Array = []

func _check(name: String, ok: bool, detail: String) -> void:
	checks.append({"name": name, "passed": ok, "detail": detail})
	print(("  PASS  " if ok else "  FAIL  ") + name + " - " + detail)

func _find_clear_patch() -> Vector2i:
	# a rectangle of tiles with no static blocker (terrain/rock/water)
	for py in range(12, game.MAP_H - 24):
		for px in range(12, game.MAP_W - 24):
			var clear := true
			for dy in 24:
				if not clear:
					break
				for dx in 16:
					if game.blocked[game._t(px + dx, py + dy)] != 0:
						clear = false
						break
			if clear:
				return Vector2i(px, py)
	return Vector2i(-1, -1)

func _initialize() -> void:
	game = C3Game.new()
	root.add_child(game)
	game.setup("skirmish")

	var patch := _find_clear_patch()
	if patch.x < 0:
		_check("setup", false, "no clear patch on the map")
		return _finish()

	var c: Vector2 = (Vector2(patch.x + 8, patch.y + 12) + Vector2(0.5, 0.5)) * game.TILE
	var hall = game.spawn("cen", 0, c)
	var r: Rect2 = hall.get("block_rect", Rect2())

	# --- the drawn rectangle reaches well above the ground anchor -----------
	_check("rect_above_anchor", r.has_area() and r.position.y < c.y - 4.0,
		"anchor (%.1f, %.1f) block y %.1f..%.1f" % [c.x, c.y, r.position.y, r.end.y])

	# --- the whole drawn block is impassable to units -----------------------
	# the top probe sits ~1 m below the top edge of the hall: it is far north
	# of the old base circle, i.e. exactly where units used to slip "under".
	var north_probe := Vector2(r.position.x + r.size.x * 0.5, r.position.y + 1.0)
	var probes := [north_probe,
		Vector2(r.position.x + r.size.x * 0.5, r.end.y - 1.0),
		Vector2(r.position.x + 1.0, r.position.y + 1.0),
		Vector2(r.end.x - 1.0, r.position.y + 1.0)]
	var dummy = game.spawn("peasant", 0, c + Vector2(0, r.size.y + 8.0))
	var covered := true
	for p in probes:
		if not game._blocked_for(dummy, p):
			covered = false
	_check("block_impassable", covered, "all 4 probes inside the drawn block reject movement")
	# placement/terrain code still sees the original grid: the far-north strip is
	# above the base circle, so only the dynamic obstacle can be blocking it.
	_check("static_grid_unchanged", not game.is_blocked(north_probe),
		"north strip is outside the base circle in blocked[] (dynamic obstacle only)")

	# --- a unit ordered from south to north cannot cross the sprite ---------
	var start := c + Vector2(0, r.size.y + 8.0)
	var goal := c + Vector2(0, -(r.size.y + 8.0))
	var walker = game.spawn("peasant", 0, start)
	game.cmd_move(walker, goal)
	var slipped := false
	for i in 260:
		game.tick(0.25)
		if r.has_point(walker.pos):
			slipped = true
		if walker.pos.distance_to(goal) < 2.0:
			break
	var reached: bool = walker.pos.y < c.y - r.size.y
	_check("no_crossing", not slipped, "unit never entered the drawn block")
	_check("routes_around", reached, "unit went around it and reached the north side")

	# --- demolishing the building frees the block ---------------------------
	game._kill(hall, null, false)
	_check("unblock_on_destroy", not game._blocked_for(dummy, north_probe),
		"north strip walkable again after demolition")

	_finish()

func _finish() -> void:
	var ok := true
	for c in checks:
		if not c.passed:
			ok = false
	print("building_block_test: %d/%d checks passed" % [
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
