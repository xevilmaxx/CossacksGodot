# Small test: mass-army scale (board P-22, RE gap 2).
#
# Asserts INTENDED behaviour of large standing armies: a 400-strong formation
# plus several squads can be spawned, units stay distinct / non-overlapping,
# corpses and rubble age out, and the simulation advances without stalling.
# A wall-clock sim time is recorded in the result JSON as a performance metric.
# Feature may be PENDING/PARTIAL: baseline FAIL is correct, do not weaken.
#
# Run with:
#   python app\tools\godot_runner.py run --id t-mass-army --timeout 120 -- \
#       --headless --path app --script res://tests/t_mass_army.gd
extends SceneTree

const Data = preload("res://scripts/data.gd")
const C3Game = preload("res://scripts/game.gd")

const OUT_DIR := "res://tests/results"

const ARMY_N := 400           # infantry grid (wiki 400-man formation label)
const SQUAD_COUNT := 4
const SQUAD_SIZE := 36        # infantry label tier
const MASS_TICKS := 40        # 10 simulated seconds at dt = 0.25
const AGE_TICKS := 400        # 100 simulated seconds (corpse life = 90 s)

var _id := "t_mass_army"
var _checks: Array[Dictionary] = []
var _ok := true
var _sim_ms := 0.0
var _unit_count := 0

func check(name: String, cond: bool, detail: String = "") -> void:
	_checks.append({"name": name, "passed": cond, "detail": detail})
	print(("  PASS  " if cond else "  FAIL  ") + name + " - " + detail)
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
		"sim_ms": _sim_ms,
		"units": _unit_count,
		"unix_ms": Time.get_unix_time_from_system() * 1000.0,
	}, "\t"))
	f.close()

# Lay out a grid using the game's real formation helper (stub entities carry
# only the fields formation_targets reads: id and def.radius).
func _formation_spots(center: Vector2, n: int, form: String) -> Array:
	var stubs: Array = []
	for i in n:
		stubs.append({"id": i, "def": {"radius": 0.35, "artillery": false}})
	return game.formation_targets(stubs, center, form)

var game

func _initialize() -> void:
	Data.AI_ENABLED = false
	game = C3Game.new()
	root.add_child(game)
	# Minimum world state: players, arrays and nav configured; no map-gen cost.
	game.setup_begin("skirmish")
	var center := Vector2(game.MAP_W * game.TILE * 0.40, game.MAP_H * game.TILE * 0.50)
	game.players[0].res[0] = 1.0e6
	game.players[1].res[0] = 1.0e6
	# Victory now requires a side to hold BOTH a building and a unit. Without
	# these anchors the corrected team-aware victory logic ends the sim at
	# the first tick even though both armies are still standing.
	game.spawn("cen", 0, center + Vector2(-70.0, 0.0))
	game.spawn("cen", 1, center + Vector2(140.0, -60.0))

	# --- the 400-strong infantry formation ---------------------------------
	var spots: Array = _formation_spots(center, ARMY_N, "none")
	for p in spots:
		game.spawn("pikeman", 0, p as Vector2)

	# --- several squads (officer + drummer + soldiers) for the other side ---
	var expected := ARMY_N
	for s in SQUAD_COUNT:
		var scenter := center + Vector2(60.0 + s * 20.0, -30.0)
		var members: Array = []
		members.append(game.spawn("officer", 1, scenter + Vector2(-6.0, 0.0)))
		members.append(game.spawn("drummer", 1, scenter + Vector2(-4.0, 0.0)))
		for k in SQUAD_SIZE:
			var col := k % 8
			var row := k / 8
			var pp := scenter + Vector2(float(col) * 1.4, float(row) * 1.4)
			members.append(game.spawn("pikeman", 1, pp))
		game.squad_form(members)
		expected += SQUAD_SIZE + 2

	# 1) mass spawn: every unit has its own id, nothing was dropped.
	var all_units: Array = game.live_units
	var ids := {}
	for u in all_units:
		ids[int(u.id)] = true
	_unit_count = all_units.size()
	check("mass_spawn_distinct",
		all_units.size() == expected and ids.size() == expected,
		"spawned %d units / %d distinct ids (want %d = %d army + %d squads x %d)" % [
			all_units.size(), ids.size(), expected, ARMY_N, SQUAD_COUNT, SQUAD_SIZE + 2])

	# 2) squads exist and the real formation command changes their shape.
	var formed: Array = game.squads_of(1)
	var formation_ok := false
	if formed.size() > 0:
		var sid := int(formed[0].squad_id)
		game.squad_set_formation(sid, "column")
		formation_ok = str(game.squads[sid].formation) == "column"
	check("squads_formed",
		formed.size() == SQUAD_COUNT and formation_ok,
		"squads for player 1 = %d (want %d), formation command applied = %s" % [
			formed.size(), SQUAD_COUNT, str(formation_ok)])

	# 3) sim advances N seconds; record wall-clock sim cost as a perf metric.
	var t0 := Time.get_ticks_usec()
	var start_t: float = game.time_s
	for i in MASS_TICKS:
		game.tick(0.25)
	_sim_ms = float(Time.get_ticks_usec() - t0) / 1000.0
	var advanced: float = game.time_s - start_t
	check("sim_advances",
		advanced >= float(MASS_TICKS) * 0.25 - 0.01 and game.winner == -1,
		"sim %.2fs -> %.2fs (+%.2f) over %d ticks, winner=%d" % [
			start_t, game.time_s, advanced, MASS_TICKS, game.winner])

	# 4) units remain distinct / non-overlapping after separation passes.
	var overlap := 0
	var min_d := 1.0e9
	for i in all_units.size():
		var a = all_units[i]
		if a.dead:
			continue
		for j in range(i + 1, all_units.size()):
			var b = all_units[j]
			if b.dead:
				continue
			var d := (a.pos as Vector2).distance_to(b.pos as Vector2)
			if d < min_d:
				min_d = d
			if d < float(a.def.radius) + float(b.def.radius) - 0.05:
				overlap += 1
	check("no_unit_overlap", overlap == 0,
		"min centre gap %.3f m, overlapping pairs %d among %d units" % [
			min_d, overlap, _unit_count])

	# 5) performance metric actually captured (also fails on a NaN/hang).
	check("perf_metric_recorded", _sim_ms > 0.0 and is_finite(_sim_ms),
		"mass sim wall time %.2f ms for %d units / %.1f sim-seconds" % [
			_sim_ms, _unit_count, advanced])

	# 6) corpses and rubble age out. Small isolated game keeps this bounded
	# while still ticking past the real 90 s corpse lifetime.
	var g2 = C3Game.new()
	root.add_child(g2)
	g2.setup_begin("skirmish")
	g2.players[0].res[0] = 1.0e6
	g2.players[1].res[0] = 1.0e6
	var victim = g2.spawn("pikeman", 0, Vector2(60.0, 60.0))
	var hall = g2.spawn("cen", 0, Vector2(80.0, 60.0))
	# Survivors for both sides (a unit AND a building each) so the aging
	# phase keeps ticking past the 90 s corpse lifetime.
	g2.spawn("pikeman", 0, Vector2(64.0, 64.0))
	g2.spawn("cen", 0, Vector2(100.0, 60.0))
	g2.spawn("pikeman", 1, Vector2(120.0, 60.0))
	g2.spawn("cen", 1, Vector2(140.0, 60.0))
	var c0: int = g2.corpses.size()
	var r0: int = g2.rubble.size()
	g2.cmd_delete(victim)
	g2.cmd_delete(hall)
	var c1: int = g2.corpses.size()
	var r1: int = g2.rubble.size()
	for i in AGE_TICKS:
		g2.tick(0.25)
	var c2: int = g2.corpses.size()
	var r2: int = g2.rubble.size()
	check("corpses_rubble_age_out",
		c1 > c0 and r1 > r0 and c2 == 0 and r2 == 0,
		"corpses %d->%d->%d, rubble %d->%d->%d after %.0f sim-s (life %.0f/20)" % [
			c0, c1, c2, r0, r1, r2, g2.time_s, float(Data.CORPSE_LIFE)])

	_write_result()
	# Never call quit() directly from _initialize() (hangs in Godot 4.7).
	call_deferred("quit", 0 if _ok else 1)
