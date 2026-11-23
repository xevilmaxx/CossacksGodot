# T-SIM-HOTSPOTS: behaviour-preservation checks for the three sim hot paths.
#  (a) tiled building-rect index agrees with the brute-force _blocked_for loop
#      for 200 deterministic probe points, with and without build_target skip.
#  (b) half-neighbourhood separation produces exactly the same positions as a
#      local copy of the legacy 9-cell algorithm on a 300-unit dense spawn,
#      and leaves no overlapping pairs.
#  (c) squad_of_unit() takes the O(1) unit.squad path and keeps the legacy
#      membership-scan fallback.
#
# Run:
#   python app\tools\godot_runner.py run --id t-sim-hotspots --timeout 100 -- \
#       --headless --path app --script res://tests/t_sim_hotspots.gd
extends SceneTree

const Data = preload("res://scripts/data.gd")
const C3Game = preload("res://scripts/game.gd")

const OUT_DIR := "res://tests/results"
const _id := "t_sim_hotspots"

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
	var f := FileAccess.open("%s/%s.json" % [abs_dir, _id], FileAccess.WRITE)
	if f == null:
		push_error("cannot write test result")
		return
	f.store_string(JSON.stringify({
		"id": _id, "passed": _ok, "checks": _checks,
		"unix_ms": Time.get_unix_time_from_system() * 1000.0,
	}, "\t"))
	f.close()

# Verbatim copy of the pre-change pair loop (9 cells, Vector2i keys, id dedup)
# used as the behavioural oracle. Building-push is omitted: the test spawns no
# buildings, so that pass is a no-op in the real implementation too.
func _legacy_separate(units: Array, g) -> void:
	var cell := 2.0
	var lgrid: Dictionary = {}
	for e in units:
		var cx := int(floor(e.pos.x / cell))
		var cy := int(floor(e.pos.y / cell))
		var key := Vector2i(cx, cy)
		if not lgrid.has(key):
			lgrid[key] = []
		lgrid[key].append(e)
	for _pass in 2:
		for e in units:
			if e.dead:
				continue
			var cx := int(floor(e.pos.x / cell))
			var cy := int(floor(e.pos.y / cell))
			for oy in range(-1, 2):
				for ox in range(-1, 2):
					var key := Vector2i(cx + ox, cy + oy)
					if not lgrid.has(key):
						continue
					for o in lgrid[key]:
						if o == e or o.dead:
							continue
						if o.id < e.id:
							continue
						var delta: Vector2 = o.pos - e.pos
						var d := delta.length()
						var want: float = e.def.radius + o.def.radius + Data.PERSONAL_SPACE
						if d < 0.001:
							delta = Vector2(0.01 * float((e.id % 7) - 3), 0.01 * float((o.id % 7) - 3))
							if delta.length() < 0.001:
								delta = Vector2(0.01, 0.0)
							d = delta.length()
						if d < want:
							var push: Vector2 = delta / d * (want - d) * 0.5
							var np_e: Vector2 = e.pos - push
							var np_o: Vector2 = o.pos + push
							if g.in_bounds(np_e) and not g.is_blocked(np_e):
								e.pos = np_e
							if g.in_bounds(np_o) and not g.is_blocked(np_o):
								o.pos = np_o

func _initialize() -> void:
	Data.AI_ENABLED = false

	# ---------------- (a) building rect tile index --------------------------
	var g = C3Game.new()
	root.add_child(g)
	g.setup_begin("skirmish")
	# Three overlapping/non-overlapping ink boxes plus one build_target to skip.
	var rects := [
		Rect2(100.0, 100.0, 30.0, 40.0),
		Rect2(118.0, 128.0, 26.0, 18.0),
		Rect2(200.0, 90.0, 14.0, 60.0),
	]
	for i in rects.size():
		g.live_blds.append({"id": 100 + i, "dead": false, "block_rect": rects[i],
			"pos": rects[i].position})
	g.live_blds.append({"id": 999, "dead": false,
		"block_rect": Rect2(300.0, 100.0, 40.0, 40.0), "pos": Vector2(300.0, 100.0)})
	g.bld_dirty += 1
	g._block_rects_ensure()
	var probe := {"player": 0, "order": {}, "def": {}}
	var mismatches := 0
	var indexed_only := 0
	var legacy_only := 0
	for i in 200:
		# deterministic, no RNG: a LCG over the box field
		var x := 90.0 + float((i * 37) % 180)
		var y := 80.0 + float((i * 53) % 100)
		var p := Vector2(x, y)
		for target in [0, 999]:
			var e := probe.duplicate()
			e["order"] = {"type": "build", "target": target}
			var brute := false
			for br in g._block_rects:
				if target != 0 and int(br[1]) == target:
					continue
				if (br[0] as Rect2).has_point(p):
					brute = true
					break
			var t := g.tile_of(p)
			var indexed := false
			for br in g._block_rects_by_cell.get(t.x + t.y * g.MAP_W, []):
				if target != 0 and int(br[1]) == target:
					continue
				if (br[0] as Rect2).has_point(p):
					indexed = true
					break
			var actual := g._blocked_for(e, p)
			if brute != indexed or brute != actual:
				mismatches += 1
			elif indexed and not brute:
				indexed_only += 1
			elif brute and not indexed:
				legacy_only += 1
	check("block_rect_index_parity",
		mismatches == 0 and indexed_only == 0 and legacy_only == 0,
		"200 points x 2 targets: %d mismatches, %d indexed-only, %d brute-only; index cells=%d" % [
			mismatches, indexed_only, legacy_only, g._block_rects_by_cell.size()])
	check("block_rect_index_populated", g._block_rects_by_cell.size() > 0,
		"%d rects in %d tile buckets" % [g._block_rects.size(), g._block_rects_by_cell.size()])

	# ---------------- (b) separation equivalence ----------------------------
	var g2 = C3Game.new()
	root.add_child(g2)
	g2.setup_begin("skirmish")
	var ga = C3Game.new()
	root.add_child(ga)
	ga.setup_begin("skirmish")
	# 300 deliberately overlapping units on a 20x15 lattice (spacing 0.6 m).
	var units_a: Array = []
	var units_b: Array = []
	for i in 300:
		var pp := Vector2(60.0 + float(i % 20) * 0.6, 60.0 + float(i / 20) * 0.6)
		var stub := {"id": i + 1, "kind": "unit", "dead": false, "pos": pp,
			"inside_of": 0, "def": {"radius": 0.35}}
		units_a.append(stub.duplicate())
		units_b.append(stub.duplicate())
	g2.entities = units_b
	g2.live_units = units_b
	_legacy_separate(units_a, g2)
	g2._separate_units()
	var max_delta := 0.0
	for i in units_a.size():
		max_delta = maxf(max_delta,
			(units_a[i].pos as Vector2).distance_to(units_b[i].pos as Vector2))
	check("separation_matches_legacy", max_delta < 0.0001,
		"300 units: max position delta %.7f m vs legacy 9-cell algorithm" % max_delta)

	# The legacy 2-pass relaxation cannot fully resolve a 0.6 m lattice in one
	# call either; give the (behaviour-identical) implementation enough passes
	# to converge, then assert the separation invariant holds.
	for _more in 40:
		g2._separate_units()
	var overlap := 0
	var min_d := 1.0e9
	for i in units_b.size():
		for j in range(i + 1, units_b.size()):
			var d: float = (units_b[i].pos as Vector2).distance_to(units_b[j].pos as Vector2)
			min_d = minf(min_d, d)
			if d < 0.35 + 0.35 - 0.05:
				overlap += 1
	check("separation_no_overlap", overlap == 0,
		"min gap %.3f m, overlapping pairs %d among 300 units" % [min_d, overlap])

	# ---------------- (c) squad_of_unit fast path + fallback ----------------
	var g3 = C3Game.new()
	root.add_child(g3)
	g3.setup_begin("skirmish")
	var off = g3.spawn("officer", 1, Vector2(100.0, 100.0))
	var dru = g3.spawn("drummer", 1, Vector2(104.0, 100.0))
	var mem: Array = []
	for k in 4:
		mem.append(g3.spawn("pikeman", 1, Vector2(108.0 + k * 1.5, 100.0)))
	var s = g3.squad_form([off, dru] + mem)
	var sid := int(s.squad_id)
	var all_ok := not g3.squad_of_unit(int(off.id)).is_empty() \
		and not g3.squad_of_unit(int(dru.id)).is_empty()
	for m in mem:
		all_ok = all_ok and int(g3.squad_of_unit(int(m.id)).get("squad_id", 0)) == sid
	check("squad_fast_path", all_ok and int(g3.by_id[int(mem[0].id)].get("squad", 0)) == sid,
		"officer/drummer/%d members resolve to squad %d via unit.squad" % [mem.size(), sid])

	# Legacy state: squad exists but the unit has no `squad` field.
	var outsider = g3.spawn("pikeman", 1, Vector2(150.0, 150.0))
	g3.squads[77] = {"squad_id": 77, "officer": 0, "drummer": 0,
		"members": [int(outsider.id)], "formation": "line", "player": 1}
	var fb = g3.squad_of_unit(int(outsider.id))
	check("squad_legacy_fallback", int(fb.get("squad_id", 0)) == 77,
		"member without unit.squad still found by membership scan (got %d)" % int(fb.get("squad_id", 0)))
	check("squad_nonmember_empty", g3.squad_of_unit(int(off.id) + 90000).is_empty(),
		"unrelated id returns empty dictionary")

	_write_result()
	call_deferred("quit", 0 if _ok else 1)
