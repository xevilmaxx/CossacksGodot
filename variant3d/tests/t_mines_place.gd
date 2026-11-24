# T-MINES-PLACE: verify near-start ore discoverability on normal richness.
# Small, headless, self-exiting. Run with:
#   python app\tools\godot_runner.py run --id t-mines-place --timeout 100 -- \
#       --headless --path app --script res://tests/t_mines_place.gd
extends SceneTree

const Data = preload("res://scripts/data.gd")
const C3Game = preload("res://scripts/game.gd")

const OUT_DIR := "res://tests/results"

var _id := "t_mines_place"
var _checks: Array[Dictionary] = []
var _ok := true

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
		"unix_ms": Time.get_unix_time_from_system() * 1000.0,
	}, "\t"))
	f.close()

func _ores(g) -> Array:
	var out: Array = []
	for n in g.res_nodes:
		if int(n.max_hits) == 0 and str(n.type) in ["gold", "iron", "coal"]:
			out.append(n)
	return out

func _signature(g) -> String:
	var parts: Array = []
	for n in _ores(g):
		parts.append("%s:%.3f:%.3f" % [str(n.type), n.pos.x, n.pos.y])
	parts.sort()
	return ";".join(parts)

func _initialize() -> void:
	Data.AI_ENABLED = false
	var seed_count := 6

	# 1. Across seeds every start already has all three ores nearby (donor
	#    pattern stamps). This is the baseline the T-MINES-PLACE net must keep.
	var failures: Array[Dictionary] = []
	var worst := 0.0
	for s in seed_count:
		Data.RANDOM_SEED = 1000 + s
		Data.RICHNESS = "normal"
		var g = C3Game.new()
		g.setup("skirmish")
		for si in g.map_starts.size():
			var st: Vector2 = g.map_starts[si]
			for k in ["gold", "iron", "coal"]:
				var dmin := 1.0e9
				for n in _ores(g):
					if str(n.type) == k:
						dmin = minf(dmin, n.pos.distance_to(st) / g.TILE)
				worst = maxf(worst, dmin)
				if dmin > 40.0:
					failures.append({"seed": 1000 + s, "start": si, "kind": k, "d": dmin})
		g.free()
	check("all_starts_served_across_%d_seeds" % seed_count, failures.is_empty(),
		"worst_nearest_tiles=%.1f failures=%s" % [worst, str(failures)])

	# 2. Determinism: same seed + richness => byte-identical ore layout.
	Data.RANDOM_SEED = 4242
	Data.RICHNESS = "med"
	var g1 = C3Game.new()
	g1.setup("skirmish")
	var sig1 := _signature(g1)
	g1.free()
	var g2 = C3Game.new()
	g2.setup("skirmish")
	var sig2 := _signature(g2)
	check("same_seed_same_ore_layout", sig1 == sig2,
		"ores=%d sig_match=%s" % [sig1.split(";").size(), str(sig1 == sig2)])
	g2.free()

	# 3. Exercise the FALLBACK path directly: strip every ore near start 0,
	#    run the T-MINES-PLACE pass, and assert all three ores return WITHOUT
	#    changing the ore count (relocation, not creation).
	Data.RANDOM_SEED = 4242
	Data.RICHNESS = "normal"
	var g3 = C3Game.new()
	g3.setup("skirmish")
	var st0: Vector2 = g3.map_starts[0]
	var before := _ores(g3).size()
	for n in _ores(g3):
		if n.pos.distance_to(st0) / g3.TILE <= 40.0:
			n["pos"] = Vector2(-9999.0, -9999.0)  # park it far away
	var stripped := 0
	for n in _ores(g3):
		if n.pos.x < 0.0:
			stripped += 1
	g3._ensure_start_ore_clusters([st0])
	var after := _ores(g3).size()
	var served := true
	var mind: Dictionary = {}
	for k in ["gold", "iron", "coal"]:
		var dmin := 1.0e9
		for n in _ores(g3):
			if str(n.type) == k:
				dmin = minf(dmin, n.pos.distance_to(st0) / g3.TILE)
		mind[k] = dmin
		if dmin > g3.MINE_DISCOVER_R:
			served = false
	check("fallback_restores_cluster_without_adding_ores",
		served and after == before and stripped > 0,
		"before=%d stripped=%d after=%d nearest_tiles=%s" % [before, stripped, after, str(mind)])
	g3.free()

	_write_result()
	call_deferred("quit", 0 if _ok else 1)
