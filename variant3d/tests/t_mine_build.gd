# T-MINE-BUILD-BUG: reproduce the "mine construction stalls at ~80%" bug.
# Headless, self-exiting. Run with:
#   python app\tools\godot_runner.py run --id t-mine-build --timeout 100 -- \
#       --headless --path app --script res://tests/t_mine_build.gd
#
# Spawns a map, finds a gold ore node, places a mine there with a peasant,
# ticks 300 steps and asserts the mine finishes. Also prints the message log
# and the progress trajectory so the ACTUAL failure is visible.
extends SceneTree

const Data = preload("res://scripts/data.gd")
const C3Game = preload("res://scripts/game.gd")

const OUT_DIR := "res://tests/results"
const DT := 0.25
const STEPS := 300

var _id := "t_mine_build"
var _checks: Array[Dictionary] = []
var _ok := true
var _msgs: Array[String] = []

func check(name: String, cond: bool, detail: String = "") -> void:
	_checks.append({"name": name, "passed": cond, "detail": detail})
	print(("  PASS  " if cond else "  FAIL  ") + name + " - " + detail)
	if not cond:
		_ok = false

func _write_result(extra: Dictionary = {}) -> void:
	var abs_dir := ProjectSettings.globalize_path(OUT_DIR)
	DirAccess.make_dir_recursive_absolute(abs_dir)
	var path := "%s/%s.json" % [abs_dir, _id]
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_error("cannot write test result: " + path)
		return
	var d := {
		"id": _id,
		"passed": _ok,
		"checks": _checks,
		"messages": _msgs,
		"unix_ms": Time.get_unix_time_from_system() * 1000.0,
	}
	for k in extra:
		d[k] = extra[k]
	f.store_string(JSON.stringify(d, "\t"))
	f.close()

func _on_message(text: String) -> void:
	_msgs.append(text)
	print("    [msg] " + text)

func _initialize() -> void:
	Data.AI_ENABLED = false
	Data.RANDOM_SEED = 20261113
	Data.RICHNESS = "normal"

	var g = C3Game.new()
	root.add_child(g)
	g.message.connect(_on_message)
	g.setup("skirmish")

	# generous resources so cost is never the blocker
	g.players[0].res[0] = 100000.0  # gold
	g.players[0].res[1] = 100000.0  # wood
	g.players[0].res[2] = 100000.0  # stone
	g.players[0].res[3] = 100000.0  # food

	# Find a gold deposit.
	var dep: Dictionary = {}
	for n in g.res_nodes:
		if str(n.type) == "gold" and int(n.max_hits) == 0:
			dep = n
			break
	if dep.is_empty():
		check("gold_deposit_exists", false, "no gold deposit on test map")
		_write_result()
		call_deferred("quit", 1)
		return
	var dpos: Vector2 = dep.pos
	print("deposit gold id=%d pos=%s left=%.1f blocked=%s" % [
		int(dep.id), str(dpos), float(dep.get("left", 0.0)), str(g.is_blocked(dpos))])

	# Spawn a peasant a few metres away on free ground.
	var ppos: Vector2 = dpos + Vector2(6.0, 0.0)
	if g.is_blocked(ppos) or not g.in_bounds(ppos):
		ppos = g._snap_free_point(ppos, {"kind": "unit", "def": {"radius": 0.4}})
	var peas: Dictionary = g.spawn("peasant", 0, ppos)
	print("peasant id=%d pos=%s" % [int(peas.id), str(peas.pos)])

	# What the UI does: click NEAR (not exactly on) the deposit; place_building
	# must snap the site to the deposit centre automatically.
	var click: Vector2 = dpos + Vector2(1.5, 0.0)
	var resolved: String = str(g.resolve_mine_sid("mine", click))
	var chk: Dictionary = g.can_place(0, "mine", click)
	print("click=%s resolved=%s can_place=%s" % [
		str(click), resolved, str(chk)])
	check("can_place_mine", bool(chk.get("ok", false)), str(chk.get("reason", "")))

	var site: Dictionary = g.place_building(0, "mine", click, true, [peas])
	if site.is_empty():
		check("mine_site_created", false, "place_building returned {}")
		_write_result()
		call_deferred("quit", 1)
		return
	check("snapped_to_deposit", site.pos.distance_to(dpos) < 0.01,
		"site=%s dep=%s dist=%.3f" % [str(site.pos), str(dpos), site.pos.distance_to(dpos)])
	check("builder_ordered", str(peas.get("order", {}).get("type", "")) == "build",
		"order=%s" % str(peas.get("order", {})))
	check("build_started_unfinished", not bool(site.get("finished", true)),
		"finished=%s progress=%.3f/%.3f" % [
			str(site.finished), float(site.progress), float(site.def.build_time)])

	var slot := g._work_slot(peas, site.pos, float(site.get("block_r", site.def.radius)) + 0.7)
	print("site block_r=%.2f work_slot=%s (blocked=%s)" % [
		float(site.get("block_r", site.def.radius)), str(slot), str(g.is_blocked(slot))])

	var traj: Array = []
	var max_prog := 0.0
	for i in STEPS:
		g.tick(DT)
		if site.dead:
			break
		var prog: float = float(site.progress) / maxf(0.001, float(site.def.build_time))
		max_prog = maxf(max_prog, prog)
		if i % 20 == 0 or site.finished:
			var o: Dictionary = peas.get("order", {})
			var od: float = peas.pos.distance_to(slot)
			traj.append({
				"step": i, "t": i * DT,
				"prog": snappedf(prog, 0.001),
				"finished": site.finished,
				"peasant_order": str(o.get("type", "")),
				"peasant_dist_to_slot": snappedf(od, 0.01),
				"peasant_blocked": g.is_blocked(peas.pos),
			})
			print("  step=%3d t=%6.1f prog=%.3f fin=%s order=%-8s dslot=%.2f pblocked=%s" % [
				i, i * DT, prog, str(site.finished), str(o.get("type", "")),
				od, str(g.is_blocked(peas.pos))])
		if site.finished:
			break

	print("RESULT finished=%s max_prog=%.3f progress=%.3f/%.3f dead=%s msgs=%d" % [
		str(site.finished), max_prog, float(site.progress), float(site.def.build_time),
		str(site.dead), _msgs.size()])
	check("mine_finished", bool(site.finished),
		"max_progress=%.3f final=%.3f/%.3f dead=%s msgs=%s" % [
			max_prog, float(site.progress), float(site.def.build_time),
			str(site.dead), str(_msgs)])

	# ---- Scenario B: right-click the ore deposit during construction.
	# The UI's _right_order() routes a deposit click to cmd_gather(); if the
	# nearest mine is unfinished, _tick_gather() parks the peasant in a wait
	# loop instead of building. If that is the BUILDER, construction stalls.
	var g2 = C3Game.new()
	root.add_child(g2)
	g2.message.connect(_on_message)
	g2.setup("skirmish")
	g2.players[0].res[0] = 100000.0
	g2.players[0].res[1] = 100000.0
	g2.players[0].res[2] = 100000.0
	g2.players[0].res[3] = 100000.0
	var dep2: Dictionary = {}
	for n in g2.res_nodes:
		if str(n.type) == "gold" and int(n.max_hits) == 0:
			dep2 = n
			break
	var p2pos: Vector2 = dep2.pos + Vector2(6.0, 0.0)
	if g2.is_blocked(p2pos):
		p2pos = g2._snap_free_point(p2pos, {"kind": "unit", "def": {"radius": 0.4}})
	var peas2: Dictionary = g2.spawn("peasant", 0, p2pos)
	var site2: Dictionary = g2.place_building(0, "mine", dep2.pos + Vector2(1.5, 0.0), true, [peas2])
	# Tick until ~80% then right-click the SAME deposit (the natural thing a
	# player does to assign the miner once the mine looks nearly done).
	while float(site2.progress) < float(site2.def.build_time) * 0.8 and not site2.finished:
		g2.tick(DT)
	var before: float = float(site2.progress)
	g2.cmd_gather(peas2, dep2)
	var order_after: String = str(peas2.get("order", {}).get("type", ""))
	print("[B] at %.1f%% right-clicked deposit -> order=%s (was build)" % [
		before / float(site2.def.build_time) * 100.0, order_after])
	for i in 200:
		g2.tick(DT)
		if site2.finished:
			break
	check("B_gather_interrupt_did_not_stall_build", bool(site2.finished),
		"progress at interrupt=%.3f order_after=%s final=%.3f/%.3f finished=%s msgs=%s" % [
			before, order_after, float(site2.progress), float(site2.def.build_time),
			str(site2.finished), str(_msgs)])

	# ---- Scenario B2: validate the proposed fix WITHOUT editing game.gd.
	# If cmd_gather() routed an ore-deposit click on an UNFINISHED mine to
	# cmd_build() instead of the gather-wait loop, construction completes.
	var g2b = C3Game.new()
	root.add_child(g2b)
	g2b.message.connect(_on_message)
	g2b.setup("skirmish")
	g2b.players[0].res[0] = 100000.0
	g2b.players[0].res[1] = 100000.0
	g2b.players[0].res[2] = 100000.0
	g2b.players[0].res[3] = 100000.0
	var dep2b: Dictionary = {}
	for n in g2b.res_nodes:
		if str(n.type) == "gold" and int(n.max_hits) == 0:
			dep2b = n
			break
	var p2bpos: Vector2 = dep2b.pos + Vector2(6.0, 0.0)
	if g2b.is_blocked(p2bpos):
		p2bpos = g2b._snap_free_point(p2bpos, {"kind": "unit", "def": {"radius": 0.4}})
	var peas2b: Dictionary = g2b.spawn("peasant", 0, p2bpos)
	var site2b: Dictionary = g2b.place_building(0, "mine", dep2b.pos + Vector2(1.5, 0.0), true, [peas2b])
	while float(site2b.progress) < float(site2b.def.build_time) * 0.8 and not site2b.finished:
		g2b.tick(DT)
	# This is exactly what the proposed T-MINE-BUILD fix does in cmd_gather().
	g2b.cmd_build(peas2b, site2b)
	for i in 200:
		g2b.tick(DT)
		if site2b.finished:
			break
	check("B2_proposed_fix_completes_build", bool(site2b.finished),
		"rerouted interrupt to cmd_build -> final=%.3f/%.3f finished=%s" % [
			float(site2b.progress), float(site2b.def.build_time), str(site2b.finished)])

	# ---- Scenario C: builder spawns at the town hall (~far from the deposit).
	var g3 = C3Game.new()
	root.add_child(g3)
	g3.message.connect(_on_message)
	g3.setup("skirmish")
	g3.players[0].res[0] = 100000.0
	g3.players[0].res[1] = 100000.0
	g3.players[0].res[2] = 100000.0
	g3.players[0].res[3] = 100000.0
	var dep3: Dictionary = {}
	for n in g3.res_nodes:
		if str(n.type) == "gold" and int(n.max_hits) == 0:
			dep3 = n
			break
	var hall: Dictionary = {}
	for b in g3.buildings_of(0, false):
		if b.sid == "cen":
			hall = b
			break
	var peas3: Dictionary = g3.spawn("peasant", 0, hall.pos + Vector2(3.0, 3.0))
	var site3: Dictionary = g3.place_building(0, "mine", dep3.pos + Vector2(1.5, 0.0), true, [peas3])
	for i in STEPS:
		g3.tick(DT)
		if site3.finished or site3.dead:
			break
	check("C_far_builder_finishes", bool(site3.finished),
		"dist=%.1f progress=%.3f/%.3f dead=%s order=%s" % [
			hall.pos.distance_to(dep3.pos), float(site3.progress),
			float(site3.def.build_time), str(site3.dead),
			str(peas3.get("order", {}).get("type", ""))])

	_write_result({
		"trajectory": traj,
		"max_progress": max_prog,
		"site_pos": str(site.pos),
		"site_finished": bool(site.finished),
		"site_dead": bool(site.dead),
		"final_progress": float(site.progress),
		"build_time": float(site.def.build_time),
	})
	call_deferred("quit", 0 if _ok else 1)
