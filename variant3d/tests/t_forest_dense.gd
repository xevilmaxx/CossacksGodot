# T-FOREST-DENSE: forest groves must read as PACKED clumps, not sparse singles.
#
# Owner request: forest groups more packed together. The port stamps donor
# forest masks (pattern_gen.gd) and realises each stamp with a per-cell RNG
# threshold (game.gd:_gen_patterns). Before this change that threshold was
# 0.10 with a cap of 10 trees/stamp, and the two scattered groves per start
# used spreads of 5/4 tiles -- trees were technically inside the mask but far
# apart. T-FOREST-DENSE raises the fill threshold to 0.30, the cap to 14 and
# tightens the scatter spreads to 3.5/3 tiles (+30% count).
#
# This test generates two 320x320 seeds and compares clustering against the
# BASELINE measured with the original constants (see BASELINE_* below):
#   * mean nearest-neighbour distance must drop by >= 20%
#   * % of trees within 6 m (3 tiles) of another tree must rise by >= 15 pp
#   * total live wood must grow, but stay below 2x the baseline (perf guard)
#   * no live wood within 8 m of a stone/ore node (no resource overlaps)
#   * generation must be deterministic: each seed's metrics are stable across
#     two independent builds (same RNG stream, no extra draws introduced).
#
# Run:
#   python app\tools\godot_runner.py run --id t-forest-dense --timeout 100 -- \
#       --headless --path app --script res://tests/t_forest_dense.gd
extends SceneTree

const Data = preload("res://scripts/data.gd")
const C3Game = preload("res://scripts/game.gd")

const OUT_DIR := "res://tests/results"
const SEEDS := [20261113, 12345]
const W := 320
const H := 320
const NEAR_M := 6.0          # 3 tiles at TILE = 2.0 m
const CROSS_M := 8.0         # 4 tiles: game.gd's wood/non-wood clash radius

# Baseline captured with the ORIGINAL constants (p=0.10, cap=10, scatter
# 5/4 tiles) using this exact generator path (setup_begin + _gen_* stages only;
# full setup() adds two provisioned nodes and is not used here).
const BASELINE := {
	20261113: {"wood_all": 1186, "wood_live": 1055, "mean_nn": 6.819, "within6_pct": 60.37, "max_nn": 37.95},
	12345: {"wood_all": 1113, "wood_live": 1001, "mean_nn": 7.085, "within6_pct": 58.22, "max_nn": 31.62},
}

var _id := "t_forest_dense"
var _checks: Array[Dictionary] = []
var _ok := true
var _rows: Array = []

func check(name: String, cond: bool, detail: String = "") -> void:
	_checks.append({"name": name, "passed": cond, "detail": detail})
	print(("  PASS  " if cond else "  FAIL  ") + name + " - " + detail)
	if not cond:
		_ok = false

func _write_result() -> void:
	var abs_dir := ProjectSettings.globalize_path(OUT_DIR)
	DirAccess.make_dir_recursive_absolute(abs_dir)
	var f := FileAccess.open("%s/%s.json" % [abs_dir, _id], FileAccess.WRITE)
	if f == null:
		push_error("cannot write test result")
		return
	f.store_string(JSON.stringify({
		"id": _id, "passed": _ok, "checks": _checks, "rows": _rows,
		"unix_ms": Time.get_unix_time_from_system() * 1000.0,
	}, "\t"))
	f.close()

# Build only the map-generation stages. Visual/spawn stages (_assign_tileblocks,
# setup_spawns) are skipped: they do not move resource nodes and cost ~80% of
# the runtime at 320x320. Keeps the whole test well under the 100 s runner cap.
func _build(seed: int):
	Data.RANDOM_SEED = seed
	Data.MAP_W = W
	Data.MAP_H = H
	Data.MAP_TYPE = "land"
	Data.BIOME = "summer"
	Data.RELIEF = "plains"
	Data.RICHNESS = "med"
	var g = C3Game.new()
	root.add_child(g)
	g.setup_begin("skirmish")
	g._gen_base()
	g._gen_patterns()
	g._gen_forests()
	g._gen_resources()
	g._gen_finish()
	return g

func _dispose(g) -> void:
	if g == null:
		return
	if g.get_parent() != null:
		g.get_parent().remove_child(g)
	g.free()

# Nearest-neighbour stats over ALL wood nodes (type == "wood", live or stump),
# plus the minimum live-wood <-> stone/ore distance for the purity guard.
func _metrics(g) -> Dictionary:
	var wood: Array[Vector2] = []
	var other: Array[Vector2] = []
	var live_wood: Array[Vector2] = []
	for n in g.res_nodes:
		var tp := str(n.get("type", ""))
		var p: Vector2 = n.get("pos", Vector2.ZERO)
		if tp == "wood":
			wood.append(p)
			if int(n.get("hits", 0)) > 0:
				live_wood.append(p)
		elif tp in ["stone", "gold", "iron", "coal"]:
			other.append(p)
	var nn_sum := 0.0
	var nn_max := 0.0
	var within := 0
	for i in wood.size():
		var p: Vector2 = wood[i]
		var best := 1.0e12
		for j in wood.size():
			if i == j:
				continue
			var d := p.distance_to(wood[j])
			if d < best:
				best = d
		nn_sum += best
		nn_max = maxf(nn_max, best)
		if best <= NEAR_M:
			within += 1
	var min_cross := 1.0e12
	for w in live_wood:
		for o in other:
			min_cross = minf(min_cross, w.distance_to(o))
	return {
		"wood_all": wood.size(),
		"wood_live": live_wood.size(),
		"mean_nn": snappedf(nn_sum / maxf(1.0, float(wood.size())), 0.001),
		"within6_pct": snappedf(100.0 * float(within) / maxf(1.0, float(wood.size())), 0.02),
		"max_nn": snappedf(nn_max, 0.02),
		"min_cross": snappedf(min_cross, 0.01),
	}

func _initialize() -> void:
	Data.AI_ENABLED = false
	for sd in SEEDS:
		var g = _build(sd)
		var m := _metrics(g)
		_dispose(g)
		# Determinism: rebuild the same seed and require identical metrics.
		var g2 = _build(sd)
		var m2 := _metrics(g2)
		_dispose(g2)
		var b: Dictionary = BASELINE[sd]
		var row := m.duplicate()
		row["seed"] = sd
		row["baseline"] = b
		_rows.append(row)

		check("seed %d deterministic" % sd, JSON.stringify(m) == JSON.stringify(m2),
			"first=%s second=%s" % [JSON.stringify(m), JSON.stringify(m2)])
		check("seed %d wood count grew but <2x" % sd,
			int(m.wood_live) > int(b.wood_live) and float(m.wood_live) < 2.0 * float(b.wood_live),
			"live %d -> %d (x%.2f)" % [int(b.wood_live), int(m.wood_live),
				float(m.wood_live) / float(b.wood_live)])
		var nn_gain := (float(b.mean_nn) - float(m.mean_nn)) / float(b.mean_nn) * 100.0
		check("seed %d mean NN distance >=20%% lower" % sd, nn_gain >= 20.0,
			"%.3f m -> %.3f m (-%.1f%%)" % [float(b.mean_nn), float(m.mean_nn), nn_gain])
		var pp_gain := float(m.within6_pct) - float(b.within6_pct)
		check("seed %d within-6m share >=15pp higher" % sd, pp_gain >= 15.0,
			"%.2f%% -> %.2f%% (+%.2f pp)" % [float(b.within6_pct), float(m.within6_pct), pp_gain])
		check("seed %d no wood/mine overlap" % sd,
			float(m.min_cross) >= CROSS_M - 0.01,
			"min live-wood <-> stone/ore = %.2f m (need >= %.1f)" % [float(m.min_cross), CROSS_M])
		check("seed %d max isolated gap shrank" % sd,
			float(m.max_nn) < float(b.max_nn),
			"max NN %.2f m -> %.2f m" % [float(b.max_nn), float(m.max_nn)])

	_write_result()
	call_deferred("quit", 0 if _ok else 1)
