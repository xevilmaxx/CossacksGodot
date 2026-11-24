# Small test: true random skirmish maps + skirmish options
# (board P-19, GUIDE4 L6 — random-map variety and start fairness).
#
# Asserts the INTENDED behaviour of the seed/option driven map generator:
#   * two different seeds produce different terrain + resource layouts;
#   * the same seed reproduces a byte-identical map summary;
#   * map type changes the water fraction (nowater2 vs islands);
#   * the menu map_size option sets both grid dimensions;
#   * every start has reachable stone / wood within 25 tiles plus open room
#     for a mill + field ring (T-FOOD-1: food comes from mills, L6).
#
# Options may still be PENDING: a failing check is the correct baseline for a
# missing feature, not a test bug.  Do NOT weaken the assertions to make green.
#
# Run with:
#   python app\tools\godot_runner.py run --id t-map-variety --timeout 120 -- \
#       --headless --path app --script res://tests/t_map_variety.gd
extends SceneTree

const Data = preload("res://scripts/data.gd")
const C3Game = preload("res://scripts/game.gd")

const OUT_DIR := "res://tests/results"

var _id := "t_map_variety"
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

# ---------------------------------------------------------------- map helpers
func _make(seed: int, mtype: String, w: int, h: int) -> C3Game:
	Data.RANDOM_SEED = seed
	Data.MAP_TYPE = mtype
	Data.MAP_W = w
	Data.MAP_H = h
	var g = C3Game.new()
	root.add_child(g)
	g.setup("skirmish")
	return g

func _dispose(g) -> void:
	if g == null:
		return
	if g.get_parent() != null:
		g.get_parent().remove_child(g)
	g.free()

# Byte-oriented summary of everything the generator produces.  Deliberately
# EXCLUDES the seed value so two different seeds can be compared by layout.
func _summary(g) -> String:
	var res: Array = []
	for n in g.res_nodes:
		res.append([str(n.type), int(n.hits), int(n.max_hits),
			snappedf(float(n.pos.x), 0.001), snappedf(float(n.pos.y), 0.001)])
	var starts: Array = []
	for s in g.map_starts:
		starts.append([snappedf(float(s.x), 0.001), snappedf(float(s.y), 0.001)])
	var d := {
		"map_type": str(Data.MAP_TYPE),
		"w": int(g.MAP_W), "h": int(g.MAP_H),
		"terrain": Marshalls.raw_to_base64(g.terrain),
		"blocked": Marshalls.raw_to_base64(g.blocked),
		"tileblock": Marshalls.raw_to_base64(g.tileblock),
		"res": res,
		"starts": starts,
		"meta": g.map_meta,
	}
	return JSON.stringify(d, "\t")

func _water_frac(g) -> float:
	if g.terrain.is_empty():
		return 0.0
	var n := 0
	for t in g.terrain:
		if int(t) == 3:   # terrain type 3 = deep water (game.gd / scan_map.py)
			n += 1
	return float(n) / float(g.terrain.size())

# GUIDE4 L6 reachability: from each start, BFS the unblocked grid out to 25
# tiles, then require at least one stone and wood node whose tile (or a
# neighbour within +/-2 tiles) is in the reached set. T-FOOD-1: food is NOT
# a map node anymore (mill cycle only) - a large reachable open set proves
# mill+field room, so "food" is satisfied by open ground, not by a node.
func _reachable_resources(g) -> Dictionary:
	var w := int(g.MAP_W)
	var h := int(g.MAP_H)
	var blocked = g.blocked
	var wanted := {"stone": ["stone"], "wood": ["wood"]}
	var nodes := {"stone": [], "wood": []}
	for n in g.res_nodes:
		var tp := str(n.type)
		for k in nodes:
			if tp in wanted[k]:
				nodes[k].append(Vector2(float(n.pos.x) / 2.0, float(n.pos.y) / 2.0))
	var out := {}
	for pi in g.map_starts.size():
		var st: Vector2 = g.map_starts[pi]
		var stx := int(st.x / 2.0)
		var sty := int(st.y / 2.0)
		if stx < 0 or sty < 0 or stx >= w or sty >= h or int(blocked[sty * w + stx]) != 0:
			var found := false
			for r in range(1, 8):
				for dy in range(-r, r + 1):
					for dx in range(-r, r + 1):
						var nx := stx + dx
						var ny := sty + dy
						if nx >= 0 and ny >= 0 and nx < w and ny < h and int(blocked[ny * w + nx]) == 0:
							stx = nx
							sty = ny
							found = true
							break
					if found:
						break
				if found:
					break
			if not found:
				out[pi] = {"food": false, "stone": false, "wood": false}
				continue
		var seen := {}
		var reach := {}
		var q: Array = [[stx, sty, 0]]
		seen[Vector2i(stx, sty)] = true
		while not q.is_empty():
			var cur: Array = q.pop_front()
			var x := int(cur[0])
			var y := int(cur[1])
			var d := int(cur[2])
			reach[Vector2i(x, y)] = true
			if d >= 25:
				continue
			for nb in [Vector2i(x + 1, y), Vector2i(x - 1, y), Vector2i(x, y + 1), Vector2i(x, y - 1)]:
				var nx := int(nb.x)
				var ny := int(nb.y)
				if nx < 0 or ny < 0 or nx >= w or ny >= h:
					continue
				if seen.has(nb) or int(blocked[ny * w + nx]) != 0:
					continue
				seen[nb] = true
				q.append([nx, ny, d + 1])
		var per := {}
		for k in nodes:
			var ok := false
			for rp in nodes[k]:
				var tx := int(rp.x)
				var ty := int(rp.y)
				for yy in range(ty - 2, ty + 3):
					for xx in range(tx - 2, tx + 3):
						if reach.has(Vector2i(xx, yy)):
							ok = true
							break
					if ok:
						break
				if ok:
					break
			per[k] = ok
		# T-FOOD-1: no food nodes exist on the map (mill cycle only). A big
		# reachable open set proves there is mill+field room near the start.
		per["food"] = reach.size() > 50
		out[pi] = per
	return out

# ------------------------------------------------------------------ the test
func _initialize() -> void:
	Data.AI_ENABLED = false

	# 1. True seed variety: two different seeds must give different terrain and
	#    resource layouts (seed value itself is excluded from the summary).
	var seed_a := 11111
	var seed_b := 98765
	var ga = _make(seed_a, "land", 160, 160)
	var sum_a: String = _summary(ga)
	var terrain_a: PackedByteArray = ga.terrain.duplicate()
	var gb = _make(seed_b, "land", 160, 160)
	var sum_b: String = _summary(gb)
	var terrain_b: PackedByteArray = gb.terrain.duplicate()
	var terrain_diff: bool = terrain_a != terrain_b
	var layout_diff := sum_a != sum_b
	check("different_seeds_different_layout", terrain_diff and layout_diff,
		"seed %d vs %d: terrain differs=%s, layout summary differs=%s (%d vs %d bytes)" %
		[seed_a, seed_b, str(terrain_diff), str(layout_diff), sum_a.length(), sum_b.length()])
	_dispose(gb)

	# 2. Determinism: same seed (+ same options) => byte-identical map summary.
	var gc = _make(seed_a, "land", 160, 160)
	var sum_c := _summary(gc)
	check("same_seed_byte_identical", sum_a == sum_c,
		"seed %d generated twice: byte-identical summary=%s (%d vs %d bytes)" %
		[seed_a, str(sum_a == sum_c), sum_a.length(), sum_c.length()])
	_dispose(ga)
	_dispose(gc)

	# 3. Map type option: a dry map and an island map at the same seed must have
	#    visibly different water fractions.
	var gd = _make(seed_a, "nowater2", 160, 160)
	var dry := _water_frac(gd)
	_dispose(gd)
	var ge = _make(seed_a, "islands", 160, 160)
	var wet := _water_frac(ge)
	var water_ok := wet > dry + 0.10 and wet > 0.15
	check("map_type_changes_water", water_ok,
		"same seed nowater2 water=%.1f%% vs islands water=%.1f%% (need >+10pt and >15%%)" %
		[dry * 100.0, wet * 100.0])
	_dispose(ge)

	# 4. Map size option: the menu's map_size sets BOTH grid dimensions, and the
	#    terrain/blocked/tileblock arrays must be resized to match.
	var gf = _make(seed_a, "land", 110, 90)
	var size_ok: bool = gf.MAP_W == 110 and gf.MAP_H == 90 \
		and gf.terrain.size() == 110 * 90 \
		and gf.blocked.size() == 110 * 90 \
		and gf.tileblock.size() == 110 * 90
	check("map_size_option_respected", size_ok,
		"requested 110x90: got %dx%d, terrain=%d blocked=%d tileblock=%d (want 9900)" %
		[gf.MAP_W, gf.MAP_H, gf.terrain.size(), gf.blocked.size(), gf.tileblock.size()])
	_dispose(gf)

	# 5. GUIDE4 L6: each start must reach stone and wood within 25 tiles, with
	#    open room for a mill + field ring (T-FOOD-1: food comes from mills,
	#    not from map nodes, so "food" = reachable open ground).
	var gg = _make(20261113, "land", 160, 160)
	var reach := _reachable_resources(gg)
	var all_ok := reach.size() >= 2
	var detail: Array[String] = []
	for pi in reach:
		var per: Dictionary = reach[pi]
		var pok := bool(per.get("food", false)) and bool(per.get("stone", false)) \
			and bool(per.get("wood", false))
		if not pok:
			all_ok = false
		detail.append("P%d(food=%s,stone=%s,wood=%s)" %
			[pi, str(per.get("food", false)), str(per.get("stone", false)), str(per.get("wood", false))])
	check("starts_have_reachable_resources", all_ok,
		"BFS<=25 tiles from each start: " + ", ".join(detail))
	_dispose(gg)

	_write_result()
	# Never call quit() directly from _initialize() (hangs in Godot 4.7).
	call_deferred("quit", 0 if _ok else 1)
