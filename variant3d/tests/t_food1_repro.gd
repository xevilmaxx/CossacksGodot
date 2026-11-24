# T-FOOD-1 repro: does zero wild food break selftest's peasant_capture + resow?
# Run: godot --headless --path app --script res://tests/t_food1_repro.gd
# Part A: mirror selftest capture step WITH player-1 AI thinking; trace efoe.
# Part B: mirror resow economy (long AI soak, then mill+resow); trace food/orders.
extends SceneTree

const Data = preload("res://scripts/data.gd")
const C3Game = preload("res://scripts/game.gd")
const C3AI = preload("res://scripts/ai.gd")

var game
var ai1

func _tick_all(dt: float) -> void:
	game.tick(dt)
	if ai1 != null:
		ai1.tick(dt)

func _initialize() -> void:
	game = C3Game.new()
	root.add_child(game)
	Data.AI_ENABLED = true
	game.setup("skirmish")
	ai1 = C3AI.new(game, 1)

	# warm soak like the suite (scripted steps take ~250 sim-s before capture)
	for i in 1000:
		_tick_all(0.25)

	# ---- Part A: capture ----
	var peasant: Dictionary = {}
	for u in game.units_of(0):
		if u.sid == "peasant":
			peasant = u
			break
	var epos := Vector2.INF
	for tr in range(8, 60):
		var cand: Vector2 = (peasant.pos as Vector2) + Vector2(cos(tr * 2.399), sin(tr * 2.399)) * (8.0 + tr)
		if game.in_bounds(cand) and not game.is_blocked(cand):
			epos = cand
			break
	var efoe = game.spawn("peasant", 1, epos)
	var epike = game.spawn("pikeman", 0, epos + Vector2(1, 0))
	game.cmd_attack(epike, efoe)
	for i in 20:
		_tick_all(0.25)
		if i % 4 == 0:
			print("CAP t=%.1f efoe_order=%s efoe_pos=%s dist=%.2f efoe_player=%d pike_order=%s" % [
				game.time_s, str(efoe.order.get("type", "")), str(efoe.pos),
				efoe.pos.distance_to(epike.pos), int(efoe.player), str(epike.order.get("type", ""))])
	print("CAPTURE_RESULT player=%d (want 0)" % int(efoe.player))

	# ---- Part B: resow ----
	var wild_food := 0
	for n in game.res_nodes:
		if n.type == "food" and not n.has("mill"):
			wild_food += 1
	print("RESOW wild_food=%d p0food=%.1f famine=%s" % [wild_food, game.players[0].res[0], str(game.players[0].get("famine", false))])
	game.players[0].res[3] += 1000.0
	var mill = game.spawn("mil", 0, peasant.pos + Vector2(-20, -20))
	game._on_building_finished(mill)
	var fields: Array = []
	for n in game.res_nodes:
		if n.has("mill") and int(n.mill) == int(mill.id):
			fields.append(n)
	print("RESOW mill_fields=%d" % fields.size())
	var fnode: Dictionary = fields[0] if not fields.is_empty() else {}
	if not fnode.is_empty():
		fnode.hits = 0
		var rp = game.spawn("peasant", 0, fnode.pos + Vector2(1, 0))
		game.players[0].res[0] += 500.0
		game.cmd_resow(rp, fnode)
		for i in 120:
			_tick_all(0.25)
			if i % 24 == 0:
				print("RESOW t=%.1f rp_order=%s fnode_hits=%d p0food=%.1f" % [
					game.time_s, str(rp.order.get("type", "")), int(fnode.hits), game.players[0].res[0]])
		print("RESOW_RESULT hits=%d (want >0)" % int(fnode.hits))
	quit(0)
