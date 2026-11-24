# Computer opponent: quota economy, mass production, combined-arms waves.
extends RefCounted
class_name C3AI

const Data = preload("res://scripts/data.gd")

var game: C3Game
var player: int
var think_t := 0.0
var wave := 0
var raid_ids: Array = []
var retreat_t := 0.0

# T5-AI: food-safety snapshot, recomputed once per think tick and shared by the
# economy allocator, the training gate and the optional soak trace.
var ai_food_reserve := 0.0
var ai_food_ok := true
var ai_starving := false

# Documented local floors, used ONLY when a configured threshold is absent or
# zero. They mirror data.gd defaults / config.json (AI_FOOD/WOOD/STONE_THRESHOLD)
# so behaviour is unchanged when the knobs are present (C4 in AI_SURVIVAL_DIAG).
const AI_FOOD_FLOOR := 260.0
const AI_WOOD_FLOOR := 260.0
const AI_STONE_FLOOR := 160.0
# Seconds of whole-army upkeep kept as a live buffer before new soldiers train.
const AI_FOOD_HORIZON_S := 45.0

func _init(g: C3Game, p: int) -> void:
	game = g
	player = p

func tick(dt: float) -> void:
	if not Data.AI_ENABLED:
		return
	think_t -= dt
	if think_t > 0.0:
		return
	think_t = Data.AI_THINK_INTERVAL
	# T-PERF-SIM: invalidate the per-tick deposit cache.
	_dep_cache.clear()
	var p: Dictionary = game.players[player]
	var res: Dictionary = {}
	for i in 6:
		res[Data.RES_NAMES[i]] = p.res[i]
	var peasants: Array = []
	var military: Array = []
	for u in game.units_of(player):
		if u.sid == "peasant":
			peasants.append(u)
		else:
			military.append(u)
	var blds := game.buildings_of(player, false)
	var counts: Dictionary = {}
	for b in blds:
		counts[b.sid] = int(counts.get(b.sid, 0)) + 1
	var fin: Dictionary = {}
	for b in blds:
		if b.finished:
			fin[b.sid] = int(fin.get(b.sid, 0)) + 1
	if fin.is_empty():
		return
	var home: Dictionary = game.by_id.get(int(p.get("home_id", 0)), {})
	if home.is_empty():
		home = blds[0]
		p["home_id"] = home.id
	# T5-AI: read the configured prioritarian thresholds once per tick so the
	# training gate and the economy allocator act on the same food snapshot.
	var st := _res_state(res, p)
	ai_starving = bool(st.get("starving", false))
	ai_food_reserve = _food_reserve(res, peasants, military, st)
	ai_food_ok = (res.food >= ai_food_reserve) and not ai_starving
	_build(res, counts, fin, home, p)
	_resume(peasants)
	_economy(peasants, res, p, counts, fin)
	_research(res, fin)
	_train(peasants, military, res, counts, fin, p)
	_form_squads(military)
	_repair(peasants, blds)
	_trace(res, p, peasants, military, fin, counts)
	if _defense(military, home):
		return
	_raids(military, res)
	_waves(military, home, p)

# --- T5-AI helpers: prioritarian thresholds, food reserve, affordable cost ---
# Reads the configured thresholds read-only. A non-positive/missing value falls
# back to the documented floor so an absent knob cannot silently disable safety.
func _res_state(res: Dictionary, p: Dictionary) -> Dictionary:
	var food_thr := float(Data.AI_FOOD_THRESHOLD) if float(Data.AI_FOOD_THRESHOLD) > 0.0 else AI_FOOD_FLOOR
	var wood_thr := float(Data.AI_WOOD_THRESHOLD) if float(Data.AI_WOOD_THRESHOLD) > 0.0 else AI_WOOD_FLOOR
	var stone_thr := float(Data.AI_STONE_THRESHOLD) if float(Data.AI_STONE_THRESHOLD) > 0.0 else AI_STONE_FLOOR
	var famine := bool(p.get("famine", false))
	# Explicit priority: food > wood > stone > gold/iron. "starving" suppresses
	# investment in everything that is not food production.
	return {
		"food_thr": food_thr, "wood_thr": wood_thr, "stone_thr": stone_thr,
		"food_ok": (res.food >= food_thr) and not famine,
		"wood_ok": res.wood >= wood_thr,
		"stone_ok": res.stone >= stone_thr,
		"starving": famine or res.food < food_thr,
	}

# Exact per-second upkeep, mirroring game.gd:3392-3398 (eat / UPKEEP_DIVISOR).
func _upkeep_food(peasants: Array, military: Array) -> float:
	var total := 0.0
	for u in peasants:
		var ee: Dictionary = u.def.get("eat", {})
		total += float(ee.get("food", 0.0))
	for u in military:
		var ee2: Dictionary = u.def.get("eat", {})
		total += float(ee2.get("food", 0.0))
	return total / float(Data.UPKEEP_DIVISOR)

# Reserve scales with army upkeep (i.e. with unit count) and is floored by the
# configured food threshold. One pricey unit + slack covers a train tick.
func _food_reserve(res: Dictionary, peasants: Array, military: Array, st: Dictionary) -> float:
	var upkeep_s := _upkeep_food(peasants, military)
	var reserve := upkeep_s * AI_FOOD_HORIZON_S + 130.0 + 100.0
	return maxf(reserve, float(st.get("food_thr", AI_FOOD_FLOOR)))

# Read the REAL cost from Data.BUILDINGS instead of a drifted hard-coded gate.
func _can_afford(sid: String, res: Dictionary) -> bool:
	var def: Dictionary = Data.BUILDINGS.get(sid, {})
	var cost: Dictionary = def.get("cost", {})
	if cost.is_empty():
		return true
	for k in cost:
		if float(res.get(k, 0.0)) + 0.001 < float(cost[k]):
			return false
	return true

func _count_food_workers(peasants: Array) -> int:
	var c := 0
	for pe in peasants:
		if pe.inside_of != 0:
			continue
		if pe.order.type == "gather" and str(pe.order.get("res", "")) == "food":
			c += 1
	return c

# nearest_res() skips depleted fields, so the resow path needs its own lookup.
func _nearest_depleted_field(pos: Vector2) -> Dictionary:
	var best: Dictionary = {}
	var bd := 1e9
	for n in game.res_nodes:
		if str(n.type) != "food" or int(n.hits) > 0:
			continue
		var d: float = n.pos.distance_to(pos)
		if d < bd:
			bd = d
			best = n
	return best

# Optional per-tick soak trace. Set C3_AI_TRACE=1 in the environment to enable;
# silent by default so selftest/uitest stdout stays clean.
func _trace(res: Dictionary, p: Dictionary, peasants: Array, military: Array, fin: Dictionary, counts: Dictionary) -> void:
	if OS.get_environment("C3_AI_TRACE") == "":
		return
	var alive_fields := 0
	var depleted_fields := 0
	for n in game.res_nodes:
		if str(n.type) == "food":
			if int(n.hits) > 0:
				alive_fields += 1
			else:
				depleted_fields += 1
	# T6-I6-METAL: soak-only fields (the env gate means selftest/uitest stdout
	# stays byte-identical). They let a 300 s CLI run verify the metal-mine fix
	# without changing simulation state.
	var force := 0.0
	for m in military:
		force += float(m.def.aiforce)
	var jobs := {"food": 0, "wood": 0, "stone": 0, "mine": 0, "build": 0, "idle": 0, "other": 0}
	for pe in peasants:
		if pe.inside_of != 0:
			jobs["mine"] += 1
		elif pe.order.type == "gather":
			var jk: String = str(pe.order.get("res", ""))
			jobs[jk] = int(jobs.get(jk, 0)) + 1
		elif pe.order.type == "build":
			jobs["build"] += 1
		elif pe.order.type == "none":
			jobs["idle"] += 1
		else:
			jobs["other"] += 1
	var home_pos: Vector2 = p.get("home_pos", Vector2.ZERO)
	var stone_node := game.nearest_res(home_pos, "stone", 400.0)
	var stone_d := -1.0
	if not stone_node.is_empty():
		stone_d = snappedf(stone_node.pos.distance_to(home_pos), 1.0)
	var row := {
		"p": player, "t": snappedf(game.time_s, 0.1),
		"food": snappedf(res.food, 1.0), "wood": snappedf(res.wood, 1.0), "stone": snappedf(res.stone, 1.0),
		"gold": snappedf(res.gold, 1.0), "iron": snappedf(res.iron, 1.0), "coal": snappedf(res.coal, 1.0),
		"famine": bool(p.get("famine", false)), "famine_t": snappedf(float(p.get("famine_t", 0.0)), 1.0),
		"peasants": peasants.size(), "military": military.size(),
		"food_workers": _count_food_workers(peasants),
		"reserve": snappedf(ai_food_reserve, 1.0), "food_ok": ai_food_ok, "starving": ai_starving,
		"mills_fin": int(fin.get("mil", 0)), "mills_all": int(counts.get("mil", 0)),
		"mines_fin": {
			"gold": int(fin.get("mine_gold", 0)), "iron": int(fin.get("mine_iron", 0)),
			"coal": int(fin.get("mine_coal", 0)),
		},
		"force": snappedf(force, 1.0), "wave": wave,
		"jobs": jobs, "stone_d": stone_d, "blds": counts,
		"fields": alive_fields, "fields_depleted": depleted_fields,
	}
	print("C3AITrace ", JSON.stringify(row))

# --- economy: target quotas instead of threshold ping-pong ---
func _economy(peasants: Array, res: Dictionary, p: Dictionary, counts: Dictionary, fin: Dictionary) -> void:
	var n := peasants.size()
	if n == 0:
		return
	# T5-AI: donor-like food priority. Ceil (never truncate) so small squads do
	# not starve, and tilt further to food while the configured threshold says
	# we are starving. Mines only get the leftover after food/wood/stone.
	var food_share := 0.5
	var wood_share := 0.25
	var stone_share := 0.15
	if ai_starving:
		food_share = 0.62
		wood_share = 0.18
		stone_share = 0.10
	var want := {
		"food": maxi(1, ceili(float(n) * food_share)),
		"wood": maxi(1, int(float(n) * wood_share)),
		"stone": maxi(1, int(float(n) * stone_share)),
	}
	# T6-I6-METAL: the flat 0.15 stone quota never gets a worker while builders
	# eat the idle pool, so stone reaches 0 and the second metal mine is never
	# affordable. Give stone a guaranteed, first-served slot until both mines
	# exist (no RNG, no resource cheat, no threshold changes).
	var metal_pending: bool = int(counts.get("mine_iron", 0)) == 0 or int(counts.get("mine_coal", 0)) == 0
	var stone_first: bool = metal_pending and float(res.stone) < 100.0
	if stone_first:
		want["stone"] = maxi(want["stone"], 3 if n < 16 else 5)
	var kinds: Array = ["stone", "food", "wood"] if stone_first else ["food", "wood", "stone"]
	var on := {"food": 0, "wood": 0, "stone": 0, "mine": 0}
	var by_res := {"food": [], "wood": [], "stone": []}
	var idle: Array = []
	for pe in peasants:
		if pe.inside_of != 0:
			on["mine"] += 1
			continue
		if pe.order.type == "gather":
			var r: String = str(pe.order.get("res", ""))
			if r == "food" and pe.order.get("node", 0) != 0:
				var nd: Dictionary = game.by_id.get(int(pe.order.get("node", 0)), {})
				if not nd.is_empty() and nd.hits <= 0:
					game.cmd_resow(pe, nd)
					continue
			if on.has(r):
				on[r] += 1
				(by_res[r] as Array).append(pe)
				continue
		if pe.order.type == "none":
			idle.append(pe)
	# reassign only idle + surplus workers, never interrupt carriers
	for kind in kinds:
		var deficit: int = int(want[kind]) - int(on[kind])
		while deficit > 0 and not idle.is_empty():
			var pe: Dictionary = idle.pop_front()
			var node := game.nearest_res(pe.pos, kind, 80.0)
			if node.is_empty():
				break
			game.cmd_gather(pe, node)
			deficit -= 1
	# surplus gatherers (no load) rotate onto mines with free slots
	for kind in kinds:
		var surplus: Array = []
		for pe3 in by_res[kind]:
			if int(pe3.get("carry", 0)) == 0 and pe3.inside_of == 0 and pe3.order.type == "gather":
				surplus.append(pe3)
		while int(on[kind]) > int(want[kind]) and not surplus.is_empty():
			var pe2: Dictionary = surplus.pop_back()
			if pe2.order.type != "gather" or int(pe2.get("carry", 0)) != 0:
				continue
			var dep2 := _mine_for(pe2)
			if dep2 == "":
				break
			var node2 := _deposit_node(dep2)
			if node2.is_empty():
				break
			game.cmd_gather(pe2, node2)
			on[kind] -= 1
			on["mine"] += 1
	for pe in idle:
		# T5-AI: leftover hands go to food first while starving; the old code
		# sent them to mines, which compounded the foodShortfall.
		if ai_starving:
			var fs := game.nearest_res(pe.pos, "food", 120.0)
			if not fs.is_empty():
				game.cmd_gather(pe, fs)
				continue
		var dep := _mine_for(pe)
		if dep != "":
			var node := _deposit_node(dep)
			if not node.is_empty():
				game.cmd_gather(pe, node)
				continue
		var f := game.nearest_res(pe.pos, "food", 80.0)
		if not f.is_empty():
			game.cmd_gather(pe, f)
	# T5-AI: food-first safety override. On a real famine every free peasant and
	# every miner goes to food; on a predictive shortfall (food below the
	# configured threshold) only miners are recalled, so wood/stone gathering
	# continues and the mill can still be afforded. cmd_gather() leaves mines.
	var famine := bool(p.get("famine", false))
	if ai_starving:
		for pe in peasants:
			if pe.order.type == "resow" or (not famine and pe.inside_of == 0):
				continue
			var f2 := game.nearest_res(pe.pos, "food", 120.0)
			if not f2.is_empty():
				game.cmd_gather(pe, f2)
				continue
			# No live field: resow the nearest depleted one (20 food). A finished
			# mill then regrows it for free instead of paying to reseed each time.
			var dead_field := _nearest_depleted_field(pe.pos)
			if not dead_field.is_empty() and res.food >= 20.0:
				game.cmd_resow(pe, dead_field)

func _mine_for(pe: Dictionary) -> String:
	for k in ["gold", "iron", "coal"]:
		var m := game.nearest_mine(pe.pos, k, player)
		if not m.is_empty() and int(m.workers) < int(m.get("slots", m.def.get("slots", 5))):
			return k
	return ""

func _deposit_node(kind: String) -> Dictionary:
	# T-PERF-SIM: per-think-tick cache (cleared in tick()). Deposits never move
	# and this lookup ignores hits, so results are identical within a tick.
	if _dep_cache.has(kind):
		return _dep_cache[kind]
	var best: Dictionary = {}
	var bd := 1e9
	for n in game.res_nodes:
		if n.type == kind and n.max_hits == 0:
			var d: float = n.pos.distance_to(game.players[player].get("home_pos", Vector2.ZERO))
			if d < bd:
				bd = d
				best = n
	_dep_cache[kind] = best
	return best

# T-PERF-SIM: per-tick deposit cache (see _deposit_node).
var _dep_cache := {}

# --- build order with expansion ---
func _build(res: Dictionary, counts: Dictionary, fin: Dictionary, home: Dictionary, p: Dictionary) -> void:
	var p0: Vector2 = home.pos
	p["home_pos"] = p0
	var unfin := 0
	for b in game.buildings_of(player, false):
		if not b.finished and not b.dead:
			unfin += 1
	if res.wood >= 120 and game.unit_count(player) + game.queue_count(player) + 3 >= int(p.farm_cap):
		_try_build("hou", home)
	# T5-AI: mill is the only food-sustainability building in this port (fields
	# regrow free only with a finished mill). Build it FIRST, before mines and
	# barracks, at the REAL Data.BUILDINGS cost, and exempt it from the
	# "finish what you started" guard so the initial batch cannot block it.
	# T-MILL-CORE: strict mill-first. Until a mill exists nothing below runs,
	# so wood/stone cannot be spent on barracks/mines while the mill is
	# still unaffordable; gatherers keep working and the mill is placed as
	# soon as its cost (wood 30 / stone 150) is covered.
	if int(counts.get("mil", 0)) == 0:
		if _can_afford("mil", res):
			_try_build("mil", home)
		return
	if unfin >= 3:
		return
	# T5-AI: guarantee ONE barracks before the mine batch. With a mill (150)
	# plus three mines (3x100) the 400 starting stone is gone before any
	# barracks, leaving the AI with 0 military; observed in a 240 s soak.
	if int(counts.get("bar", 0)) == 0 and res.wood >= 150 and res.stone >= 150:
		_try_build("bar", home)
	# T6-I6-METAL: iron/coal FIRST. The old gold,iron,coal order let the gold
	# mine eat the last 100 of the 400 starting stone (mill 150 + bar 150 +
	# gold 100), so neither metal mine was ever affordable and no metal income
	# could reach the army (force < AI_ATTACK_FORCE => _waves never fired).
	for k in ["iron", "coal", "gold"]:
		var sid: String = "mine_" + k
		if int(counts.get(sid, 0)) == 0 and res.wood >= 100 and res.stone >= 100:
			_build_mine(k, home)
	# T6-I6-METAL: reserve 200 stone for the two metal mines while either is
	# missing; extra barracks may only spend that stone once both are placed.
	var metal_ready := int(counts.get("mine_iron", 0)) > 0 and int(counts.get("mine_coal", 0)) > 0
	var bar_stone := 150.0 if metal_ready else 300.0
	if int(counts.get("bar", 0)) < 3 and res.wood >= 150 and res.stone >= bar_stone:
		_try_build("bar", home)
	# T6-I6-METAL: every other stone sink waits until both metal mines exist;
	# the flat gates below used to eat the trickle that funds mine_coal.
	if metal_ready:
		if int(counts.get("sto", 0)) == 0 and res.wood >= 50 and res.stone >= 20:
			_try_build("sto", home)
		if int(counts.get("bla", 0)) == 0 and res.wood >= 100 and res.stone >= 30:
			_try_build("bla", home)
	# T5-AI: configured thresholds are the explicit priority switch. Food is
	# first (starving => no luxury building at all); wood and stone must also
	# clear their configured buffers before non-food investment. Priority:
	# food > wood > stone > gold/iron. Essentials above are never deferred.
	var st := _res_state(res, p)
	if (not bool(st.get("starving", false))) and bool(st.get("wood_ok", false)) and bool(st.get("stone_ok", false)):
		if int(counts.get("mar", 0)) == 0 and res.wood >= 450:
			_try_build("mar", home)
		if int(counts.get("aca", 0)) == 0 and res.wood >= 1350 and res.stone >= 1200:
			_try_build("aca", home)
		if int(counts.get("sta", 0)) < 2 and res.wood >= 3200 and res.stone >= 850 and res.gold >= 850:
			_try_build("sta", home)
		if bool(p.get("has18c", false)) and int(counts.get("bar18", 0)) == 0 and res.wood >= 300 and res.stone >= 300:
			_try_build("bar18", home)
		if int(counts.get("dip", 0)) == 0 and res.wood >= 400 and res.gold >= 200:
			_try_build("dip", home)
		# expansion: second town hall when booming (cost escalation x3 aware)
		if int(fin.get("cen", 0)) >= 1 and int(counts.get("cen", 0)) < 2 and res.wood >= 2000 and res.stone >= 1500 and res.gold >= 1000:
			_try_build("cen", home, 30.0, 60.0)
		# wall ring: 6 segments max, placed wide so the base stays reachable
		if metal_ready and int(counts.get("wal", 0)) < 6 and res.stone >= 200 and res.wood >= 60:
			_try_build("wal", home, 20.0, 30.0)
		if metal_ready and int(counts.get("tow", 0)) < 2 and res.wood >= 300 and res.stone >= 400 and int(fin.get("bar", 0)) > 0:
			_try_build("tow", home, 16.0, 24.0)
	for b in game.buildings_of(player):
		if b.sid == "mar" and b.finished:
			_market_balance(b)

func _try_build(sid: String, home: Dictionary, min_d := 0.0, max_d := 18.0) -> void:
	var def: Dictionary = Data.BUILDINGS[sid]
	var vr: float = game.bld_rm(player, sid)
	var lo: float = min_d if min_d > 0.0 else (vr if vr > 0.0 else def.radius) + 2.5
	var pos := _find_spot(home, def, sid, lo, max_d)
	if pos == Vector2.INF:
		return
	game.place_building(player, sid, pos, false)

func _build_mine(kind: String, home: Dictionary) -> void:
	var best: Dictionary = {}
	var best_d := 1e9
	for n in game.res_nodes:
		if n.type == kind and n.max_hits == 0:
			var d: float = n.pos.distance_to(home.pos)
			if d < best_d and d > 6.0:
				best_d = d
				best = n
	if best.is_empty():
		return
	game.place_building(player, "mine_" + kind, best.pos, false)

func _resume(peasants: Array) -> void:
	var idle: Array = []
	var crew_total := 0
	for pe in peasants:
		if pe.order.type == "build" and pe.inside_of == 0:
			crew_total += 1
		elif pe.order.type == "none" and pe.inside_of == 0:
			idle.append(pe)
	if idle.is_empty():
		return
	# T5-AI: prioritise an unfinished mill and give it enough builders to finish
	# before the mine/barracks batch competes for the same small peasant pool.
	var sites: Array = []
	var mill_unfin := false
	for b in game.buildings_of(player, false):
		if b.finished or b.dead:
			continue
		if b.sid == "mil":
			mill_unfin = true
			sites.insert(0, b)
		else:
			sites.append(b)
	var budget: int = maxi(2, peasants.size() / 3)
	if mill_unfin:
		budget = maxi(3, peasants.size() / 2)
	for b in sites:
		if crew_total >= budget:
			break
		var crew := 0
		for pe in peasants:
			if pe.order.type == "build" and int(pe.order.get("target", 0)) == b.id:
				crew += 1
		var crew_need := 3 if b.sid == "mil" else 2
		while crew < crew_need and crew_total < budget and not idle.is_empty():
			var pe2: Dictionary = idle.pop_front()
			game.cmd_build(pe2, b)
			crew += 1
			crew_total += 1
		if idle.is_empty():
			break

func _find_spot(home: Dictionary, def: Dictionary, sid: String, min_d: float, max_d: float) -> Vector2:
	# T-PERF-SIM: fetch the building list once (old code rebuilt it via
	# buildings_of() on every one of the 24 attempts).
	var mine: Array = game.buildings_of(player, false)
	for attempt in 24:
		var a := game.rng.randf() * TAU
		var r := game.rng.randf_range(min_d, max_d)
		var pos: Vector2 = home.pos + Vector2(cos(a), sin(a)) * r
		# Use the same placement rules the human UI uses: is_blocked() alone
		# misses trees/stone/deposits overlapping the building footprint.
		if not bool(game.can_place(player, sid, pos).get("ok", false)):
			continue
		var vr: float = game.bld_rm(player, sid)
		var my_r: float = vr if vr > 0.0 else def.radius
		var ok := true
		for b in mine:
			if b.pos.distance_to(pos) < float(b.get("block_r", b.def.radius)) + my_r + 1.0:
				ok = false
				break
		if ok:
			return pos
	return Vector2.INF

func _market_balance(market: Dictionary) -> void:
	var p: Dictionary = game.players[player]
	var res: Dictionary = {}
	for i in 6:
		res[Data.RES_NAMES[i]] = p.res[i]
	var rich := ""
	var best := 1500.0
	for k in ["wood", "stone", "food", "gold", "iron", "coal"]:
		if res.get(k, 0.0) > best:
			best = res.get(k, 0.0)
			rich = k
	if rich == "":
		return
	for k in ["iron", "coal", "gold", "food"]:
		if res.get(k, 0.0) < 800.0 and k != rich:
			game.trade(player, rich, k, 100.0)
			return

func _research(res: Dictionary, fin: Dictionary) -> void:
	var order := ["aca_bread1", "bla_sword1", "bla_armor1", "aca_wood1", "bla_bullet1", "sta_horse1", "art_caliber1", "mil_food1", "aca_field1", "cen_18c", "art_range1", "art_hp1"]
	for uid in order:
		var u: Dictionary = Data.UPGRADES.get(uid, {})
		if u.is_empty() or game.players[player].upgrades.has(uid):
			continue
		for b in game.buildings_of(player):
			if b.sid == u.building and b.finished and b.get("research") == null:
				if game.research(player, b, uid):
					return

# --- production: always fill queues, respect limits (uses train_unit!) ---
func _train(peasants: Array, military: Array, res: Dictionary, counts: Dictionary, fin: Dictionary, p: Dictionary) -> void:
	# T5-AI: one reserve/income margin shared by all training. Peasants pay the
	# same 100 food up front, so they respect the reserve too (with their cost
	# on top); soldiers are gated below before ANY queue slot is consumed.
	var food_workers := _count_food_workers(peasants)
	var min_food_workers := maxi(1, ceili(float(peasants.size()) * 0.4))
	var can_train_military := ai_food_ok and not ai_starving and food_workers >= min_food_workers
	if int(fin.get("cen", 0)) > 0 and peasants.size() < Data.AI_MAX_PEASANTS and res.food >= maxf(ai_food_reserve, 100.0) + 100.0:
		for b in game.buildings_of(player):
			if b.sid == "cen" and b.finished and b.queue.size() < 3:
				game.train_unit(player, b, "peasant")
				break
	var priests := 0
	var drums := 0
	var offs := 0
	for u in military:
		if str(u.sid) in ["priest", "pope", "padre", "mullah"]:
			priests += 1
		elif str(u.sid) in ["drummer", "drummer18"]:
			drums += 1
		elif str(u.sid) in ["officer", "officer18"]:
			offs += 1
	var force := 0.0
	var cls := {"melee": 0, "ranged": 0, "cavalry": 0, "artillery": 0}
	for m in military:
		force += float(m.def.aiforce)
		cls[game._kind_class(m)] = int(cls.get(game._kind_class(m), 0)) + 1
	for b in game.buildings_of(player):
		if not b.finished or not b.def.has("trains") or b.queue.size() >= 6:
			continue
		# T5-AI: PRIMARY starvation fix — pause military production whenever the
		# food reserve or the positive-income margin fails. The force cap below
		# is unchanged, so the AI still attacks once food can pay for it.
		if not can_train_military:
			continue
		if b.sid == "bar" or b.sid == "bar18" or b.sid == "sta" or b.sid == "dip" or b.sid == "art":
			# support first
			if b.sid == "bar" and int(fin.get("aca", 0)) > 0:
				if drums < 1 + int(fin.get("bar", 0)) / 2 and game.train_unit(player, b, "drummer"):
					continue
				if offs < 1 + int(fin.get("bar", 0)) / 2 and game.train_unit(player, b, "officer"):
					continue
				if priests < 1 and game.train_unit(player, b, "priest"):
					continue
			if force >= float(Data.AI_ATTACK_FORCE) * 2.0:
				continue
			var want := "melee"
			if cls["ranged"] < cls["melee"]:
				want = "ranged"
			elif cls["cavalry"] < cls["melee"] / 2:
				want = "cavalry"
			elif cls["artillery"] < 3 and b.sid == "art":
				want = "artillery"
			var pick := ""
			for o in b.def.trains:
				var rs: String = Data.resolve_sid(str(Data.PLAYER_NATIONS[player]), str(o))
				if not Data.UNITS.has(rs):
					continue
				if game._kind_class({"def": Data.UNITS[rs], "kind": "unit"}) == want:
					pick = rs
					break
			if pick == "":
				continue
			if game.train_unit(player, b, pick):
				force += float(Data.UNITS[pick].aiforce)

func _form_squads(military: Array) -> void:
	if int(game.buildings_of(player).size()) == 0:
		return
	for u in military:
		if str(u.sid) in ["officer", "officer18"] and game.squad_of_unit(u.id).is_empty():
			# cmd_form_size() emits "No loose troops near the officer." on every
			# failed call. Only ask it when there really are loose troops close
			# enough to form from, so the AI does not spam chat every think tick.
			var have_loose := false
			for m in military:
				if m.id == u.id or str(m.sid) == "peasant" or bool(m.def.get("support", false)):
					continue
				if not game.squad_of_unit(m.id).is_empty():
					continue
				if m.pos.distance_to(u.pos) <= 12.0:
					have_loose = true
					break
			if have_loose:
				game.cmd_form_size(u, 72 if military.size() > 90 else 36)

func _repair(peasants: Array, blds: Array) -> void:
	for b in blds:
		if b.finished and b.hp < b.max_hp * 0.7 and b.player == player:
			var sent := 0
			for pe in peasants:
				if sent >= 2:
					break
				if pe.order.type == "none" and pe.inside_of == 0:
					game.cmd_repair(pe, b)
					sent += 1

func _defense(military: Array, home: Dictionary) -> bool:
	var threat := game.enemies_in_radius(home.pos, player, 45.0, false)
	if threat.is_empty():
		return false
	for m in military:
		if m.order.type == "none" or m.order.type == "attackmove" or m.order.type == "attackground":
			if game._kind_class(m) == "ranged" and threat.pos.distance_to(home.pos) <= 25.0:
				game.cmd_stand_ground(m)
			elif game._kind_class(m) == "artillery":
				game.cmd_attack_ground(m, threat.pos)
			else:
				game.cmd_attack(m, threat)
	return true

# Team-aware enemy test. `team` is optional on a player dict; without it every
# other player is hostile (the original two-player behaviour is unchanged).
func _is_enemy(other: int) -> bool:
	if other == player or other < 0 or other >= game.players.size():
		return false
	var my_team := int(game.players[player].get("team", -1))
	if my_team >= 0 and int(game.players[other].get("team", -1)) == my_team:
		return false
	return true

# --- cavalry raids on enemy economy (video 1) ---
func _raids(military: Array, res: Dictionary) -> void:
	var cav: Array = []
	for m in military:
		if game._kind_class(m) == "cavalry" and m.order.type == "none":
			cav.append(m)
	if cav.size() < 6:
		return
	# A wiped raid leaves raid_ids pointing only at dead units; without this
	# cleanup those stale ids are never replaced and fresh cavalry never raids.
	var any_alive := false
	for id in raid_ids:
		var old: Dictionary = game.by_id.get(int(id), {})
		if not old.is_empty() and not bool(old.get("dead", false)):
			any_alive = true
			break
	if not any_alive:
		raid_ids.clear()
	if raid_ids.is_empty():
		for i in range(0, mini(cav.size(), 12)):
			raid_ids.append(cav[i].id)
	var target: Dictionary = {}
	var bd := 1e9
	# T-PERF-SIM: collect enemy peasants once (old code re-scanned every entity
	# for every food node: O(nodes * entities) per think tick). Order and the
	# first-match break are preserved, so the chosen target is unchanged.
	var foe_peas: Array = []
	for e in game.entities:
		if not e.dead and _is_enemy(int(e.player)) and e.kind == "unit" and str(e.sid) == "peasant":
			foe_peas.append(e)
	for n in game.res_nodes:
		if n.type == "food" and n.hits > 0:
			for e in foe_peas:
				if e.pos.distance_to(n.pos) < 8.0:
					var d: float = n.pos.distance_to(game.players[player].get("home_pos", Vector2.ZERO))
					if d < bd:
						bd = d
						target = e
					break
	if target.is_empty():
		raid_ids.clear()
		return
	for id in raid_ids:
		var u: Dictionary = game.by_id.get(id, {})
		if u.is_empty() or u.dead:
			continue
		if u.order.type == "none" or u.order.type == "attack":
			game.cmd_attack(u, target)

# --- waves: combined arms, retreat when broken ---
func _waves(military: Array, home: Dictionary, p: Dictionary) -> void:
	var force := 0.0
	var routing := 0
	for m in military:
		force += float(m.def.aiforce)
		if bool(m.get("routing", false)):
			routing += 1
	if routing > maxi(3, military.size() / 4):
		retreat_t = 20.0
	if retreat_t > 0.0:
		retreat_t -= Data.AI_THINK_INTERVAL
		for m in military:
			if m.order.type == "attack" or m.order.type == "attackmove":
				game.cmd_move(m, home.pos + Vector2(0, 6))
		return
	if force < float(Data.AI_ATTACK_FORCE) and not (game.battle_mode and military.size() >= 6):
		return
	var enemy_home: Dictionary = {}
	var bd := 1e9
	for other in game.players.size():
		if not _is_enemy(other):
			continue
		for b in game.buildings_of(other):
			var d: float = b.pos.distance_to(home.pos)
			if d < bd:
				bd = d
				enemy_home = b
	if enemy_home.is_empty():
		return
	wave += 1
	for m in military:
		if m.order.type != "none" and m.order.type != "attackmove":
			continue
		var sq := game.squad_of_unit(m.id)
		if not sq.is_empty():
			var off: Dictionary = game.by_id.get(int(sq.officer), {})
			if not off.is_empty() and not off.dead and off.order.type == "none":
				game.cmd_attack_move(off, enemy_home.pos)
			continue
		var kc := game._kind_class(m)
		if kc == "artillery":
			game.cmd_attack_ground(m, enemy_home.pos)
		elif kc == "ranged":
			game.cmd_attack_move(m, enemy_home.pos + (home.pos - enemy_home.pos).normalized() * 14.0)
		elif kc == "cavalry":
			game.cmd_attack_move(m, enemy_home.pos + Vector2(10, -10))
		else:
			game.cmd_attack_move(m, enemy_home.pos)
