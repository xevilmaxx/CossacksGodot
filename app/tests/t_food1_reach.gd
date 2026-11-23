# T-FOOD-1: per-field resow reachability probe.
# Sows a mill ring, then tries a paid resow on EVERY field, recording geometry.
extends SceneTree

const Data = preload("res://scripts/data.gd")
const C3Game = preload("res://scripts/game.gd")

var game

func _initialize() -> void:
	game = C3Game.new()
	root.add_child(game)
	Data.AI_ENABLED = false
	game.setup("skirmish")
	var p0: Vector2 = game.map_starts[0]
	game.players[0].res[3] += 2000.0
	var mill = game.spawn("mil", 0, p0 + Vector2(6, 6), true)
	game._on_building_finished(mill)
	var fields: Array = []
	for n in game.res_nodes:
		if n.has("mill") and int(n.mill) == int(mill.id):
			fields.append(n)
	print("FIELDS n=%d" % fields.size())
	var fails := 0
	for f in fields:
		f.hits = 0
		var sp: Vector2 = f.pos + Vector2(1, 0)
		var rp = game.spawn("peasant", 0, sp)
		game.players[0].res[0] += 500.0
		game.cmd_resow(rp, f)
		for i in 60:
			game.tick(0.25)
		var ok: bool = int(f.hits) > 0
		if not ok:
			fails += 1
		var ti: int = game.terrain[game._t(int(sp.x / game.TILE), int(sp.y / game.TILE))]
		print("FIELD pos=%s ok=%s rp_end=%s dist_slot=%.2f spawn_blocked=%s spawn_terr=%d slope=%.3f" % [
			str(f.pos), str(ok), str(rp.pos),
			rp.pos.distance_to(game._work_slot(rp, f.pos, float(f.radius) + 0.7)),
			str(game.is_blocked(sp)), ti, game.slope_to(rp.pos, f.pos)])
	print("RESULT fails=%d/%d" % [fails, fields.size()])
	quit(0)
