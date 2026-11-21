# Focused regression test for the mill + field (food) loop.
# Run with:
#   godot --headless --path app --script res://tests/mill_logic_test.gd
extends SceneTree

const Data = preload("res://scripts/data.gd")
const C3Game = preload("res://scripts/game.gd")

var game
var checks: Array = []

func _check(name: String, ok: bool, detail: String) -> void:
	checks.append({"name": name, "ok": ok, "detail": detail})
	print(("  PASS  " if ok else "  FAIL  ") + name + " - " + detail)

func _initialize() -> void:
	game = C3Game.new()
	root.add_child(game)
	Data.AI_ENABLED = false
	game.setup("skirmish")

	# Find a food field and a clear spot for a mill nearby.
	var field: Dictionary = {}
	for n in game.res_nodes:
		if n.type == "food" and n.hits > 0:
			field = n
			break
	if field.is_empty():
		_check("setup", false, "no food field on the map")
		return _finish()

	# --- no drop point: a carrier must keep its load --------------------
	var p0 = game.spawn("peasant", 0, field.pos + Vector2(2, 0))
	game.cmd_gather(p0, field)
	print("DEBUG start pos=%s slot=%s food=%s gathered=%s" % [str(p0.pos), str(game._work_slot(p0, field.pos, float(field.radius)+1.1)), str(game.players[0].res[0]), str(game.stats.gathered)])
	var drop = game.nearest_drop(p0, "food")
	print("DEBUG drop=%s" % str(drop))
	for i in 240:
		game.tick(0.25)
		if i in [0, 1, 4, 20, 100, 239]:
			print("DEBUG t=%.1f pos=%s carry=%d order=%s deliv=%s food=%.1f gathered=%s" % [
				game.time_s, str(p0.pos), int(p0.carry), str(p0.order.get("type","")),
				str(p0.get("delivering", false)), game.players[0].res[0], str(game.stats.gathered)])
	var held: bool = int(p0.get("carry", 0)) > 0
	var slot = game._work_slot(p0, field.pos, float(field.radius) + 1.1)
	print("DEBUG self=%.2f slot=%.2f slope=%.2f hself=%.2f hslot=%.2f blockedFor=%s" % [
		game.height_at(p0.pos), game.height_at(slot), game.slope_to(p0.pos, slot),
		game.height_at(p0.pos), game.height_at(slot), str(game._blocked_for(p0, slot))])
	_check("no_mill_holds_load", held,
		"carry=%d order=%s node=%s moving=%s pos=%s slot=%s field=%s hits=%d stuck=%s nav=%s" % [
			int(p0.get("carry", 0)), str(p0.order.get("type", "")), str(p0.order.get("node", 0)),
			str(p0.get("moving", false)), str(p0.pos), str(slot),
			str(field.pos), int(field.hits), str(p0.get("stuck_t", 0.0)), str(p0.get("nav_path", []))])

	# --- build a finished mill next to the field ------------------------
	var mill = game.spawn("mil", 0, field.pos + Vector2(6, 0), true)
	_check("mill_is_drop", Data.BUILDINGS["mil"].get("stores", []).has("food"),
		"mill stores food")
	var f0: float = game.players[0].res[0]
	var g0: float = float(game.stats.gathered.get("food", 0.0))
	for i in 400:
		game.tick(0.25)
	var delivered: bool = game.players[0].res[0] > f0
	_check("food_reaches_mill", delivered,
		"food %.1f -> %.1f, gathered %.1f -> %.1f" % [
			f0, game.players[0].res[0], g0, float(game.stats.gathered.get("food", 0.0))])

	# --- field depletion + resow ---------------------------------------
	var depleted: Dictionary = {}
	for n in game.res_nodes:
		if n.type == "food":
			depleted = n
			break
	var h0: int = int(depleted.hits)
	depleted.hits = 0
	var rp = game.spawn("peasant", 0, depleted.pos + Vector2(1, 0))
	game.players[0].res[0] += 500.0
	game.cmd_resow(rp, depleted)
	for i in 160:
		game.tick(0.25)
	_check("resow_restores_field", int(depleted.hits) > 0,
		"hits %d -> 0 -> %d" % [h0, int(depleted.hits)])

	_finish()

func _finish() -> void:
	var ok := true
	for c in checks:
		if not c.ok:
			ok = false
	print("mill_logic_test: %d/%d checks passed" % [
		checks.filter(func(c): return c.ok).size(), checks.size()])
	call_deferred("quit", 0 if ok else 1)
