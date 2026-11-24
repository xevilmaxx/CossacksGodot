# T-SIM-HOTSPOTS: numbers-only scaling probe (no pass/fail assertions).
#
# Measures two isolated per-tick costs across N = 300 / 1000 / 3000 units:
#   move_ms  - N simulation ticks (separation + _blocked_for building rects)
#   squad_ms - one squad_of_unit() lookup per live unit
# Each number is the MEDIAN of 3 reps. Env toggles:
#   C3_PERF_MOVE=0  skip the move/tick measurement
#   C3_PERF_SQUAD=0 skip the squad-lookup measurement
# Deferred quit only (never quit() from _initialize() -- hangs in Godot 4.7).
#
# Run:
#   python app\tools\godot_runner.py run --id t-perf-scale --timeout 100 -- \
#       --headless --path app --script res://tests/t_perf_scale.gd
extends SceneTree

const Data = preload("res://scripts/data.gd")
const C3Game = preload("res://scripts/game.gd")

const OUT_DIR := "res://tests/results"
const NS := [300, 1000, 3000]
const REPS := 3
const TICKS := 5

var _do_move := true
var _do_squad := true
var _rows: Array = []

func _median(a: Array) -> float:
	var s: Array = a.duplicate()
	s.sort()
	return float(s[s.size() / 2])

func _env_on(key: String) -> bool:
	var v := OS.get_environment(key)
	return v == "" or v == "1" or v.to_lower() == "true"

func _initialize() -> void:
	_do_move = _env_on("C3_PERF_MOVE")
	_do_squad = _env_on("C3_PERF_SQUAD")
	Data.AI_ENABLED = false
	for n in NS:
		var g = C3Game.new()
		root.add_child(g)
		g.setup_begin("skirmish")
		g.players[0].res[0] = 1.0e6
		g.players[1].res[0] = 1.0e6
		# Victory anchors: a building and a unit per side.
		g.spawn("cen", 0, Vector2(40.0, 40.0))
		g.spawn("cen", 1, Vector2(g.MAP_W * g.TILE - 40.0, g.MAP_H * g.TILE - 40.0))
		# Dense but in-bounds grid of units, shared by both measurements.
		var side := ceili(sqrt(float(n)))
		for i in n:
			var px := 60.0 + float(i % side) * 1.6
			var py := 60.0 + float(i / side) * 1.6
			g.spawn("pikeman", 0, Vector2(px, py))
		# One squad so squad_of_unit() has both fast and fallback paths.
		var off = g.spawn("officer", 1, Vector2(90.0, 90.0))
		var dru = g.spawn("drummer", 1, Vector2(94.0, 90.0))
		var mem: Array = []
		for k in 12:
			mem.append(g.spawn("pikeman", 1, Vector2(98.0 + k * 1.6, 90.0)))
		g.squad_form([off, dru] + mem)

		var move_samples: Array = []
		var squad_samples: Array = []
		for rep in REPS:
			if _do_move:
				var t0 := Time.get_ticks_usec()
				for _t in TICKS:
					g.tick(0.25)
				move_samples.append(float(Time.get_ticks_usec() - t0) / 1000.0)
			if _do_squad:
				var t1 := Time.get_ticks_usec()
				for u in g.live_units:
					g.squad_of_unit(int(u.id))
				squad_samples.append(float(Time.get_ticks_usec() - t1) / 1000.0)
		var row := {
			"n": n,
			"units": g.live_units.size(),
			"move_ms": _median(move_samples) if _do_move else -1.0,
			"squad_ms": _median(squad_samples) if _do_squad else -1.0,
			"ticks": TICKS,
			"reps": REPS,
		}
		_rows.append(row)
		print("PERF n=%d units=%d move_ms=%.3f squad_ms=%.3f (%d ticks, median of %d)" % [
			n, int(row.units), float(row.move_ms), float(row.squad_ms), TICKS, REPS])

	var abs_dir := ProjectSettings.globalize_path(OUT_DIR)
	DirAccess.make_dir_recursive_absolute(abs_dir)
	var path := "%s/t_perf_scale.json" % abs_dir
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify({
			"id": "t_perf_scale",
			"move_on": _do_move,
			"squad_on": _do_squad,
			"rows": _rows,
		}, "\t"))
		f.close()
	call_deferred("quit", 0)
