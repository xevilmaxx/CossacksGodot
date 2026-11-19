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
	_economy(peasants, res, p, counts, fin)
	_build(res, counts, fin, home, p)
	_research(res, fin)
	_train(peasants, military, res, counts, fin, p)
	_form_squads(military)
	_repair(peasants, blds)
	if _defense(military, home):
		return
	_raids(military, res)
	_waves(military, home, p)

# --- economy: target quotas instead of threshold ping-pong ---
func _economy(peasants: Array, res: Dictionary, p: Dictionary, counts: Dictionary, fin: Dictionary) -> void:
	var n := peasants.size()
	if n == 0:
		return
	# desired distribution: food 35%, wood 25%, stone 15%, mines 25%
	var want := {"food": int(n * 0.35), "wood": int(n * 0.25), "stone": int(n * 0.15)}
	var on := {"food": 0, "wood": 0, "stone": 0, "mine": 0}
	var idle: Array = []
	for pe in peasants:
		if pe.inside_of != 0:
			on["mine"] += 1
			continue
		if pe.order.type == "gather":
			var r: String = str(pe.order.get("res", ""))
			if r == "food" and pe.order.get("node", 0) != 0:
				var nd: Dictionary = game.by_id.get(int(pe.order.node), {})
				if not nd.is_empty() and nd.hits <= 0:
					game.cmd_resow(pe, nd)
					continue
			if on.has(r):
				on[r] += 1
				continue
		if pe.order.type == "none":
			idle.append(pe)
	# reassign only idle + surplus workers, never interrupt carriers
	for kind in ["food", "wood", "stone"]:
		var deficit: int = int(want[kind]) - int(on[kind])
		while deficit > 0 and not idle.is_empty():
			var pe: Dictionary = idle.pop_front()
			var node := game.nearest_res(pe.pos, kind, 80.0)
			if node.is_empty():
				break
			game.cmd_gather(pe, node)
			deficit -= 1
	for pe in idle:
		var dep := _mine_for(pe)
		if dep != "":
			var node := _deposit_node(dep)
			if not node.is_empty():
				game.cmd_gather(pe, node)
				continue
		var f := game.nearest_res(pe.pos, "food", 80.0)
		if not f.is_empty():
			game.cmd_gather(pe, f)
	# famine override: everyone to food
	if bool(p.get("famine", false)):
		for pe in peasants:
			if pe.inside_of == 0 and pe.order.type != "resow":
				var f2 := game.nearest_res(pe.pos, "food", 120.0)
				if not f2.is_empty():
					game.cmd_gather(pe, f2)

func _mine_for(pe: Dictionary) -> String:
	for k in ["gold", "iron", "coal"]:
		var m := game.nearest_mine(pe.pos, k, player)
		if not m.is_empty() and int(m.workers) < int(m.get("slots", m.def.get("slots", 5))):
			return k
	return ""

func _deposit_node(kind: String) -> Dictionary:
	var best: Dictionary = {}
	var bd := 1e9
	for n in game.res_nodes:
		if n.type == kind and n.max_hits == 0:
			var d: float = n.pos.distance_to(game.players[player].get("home_pos", Vector2.ZERO))
			if d < bd:
				bd = d
				best = n
	return best

# --- build order with expansion ---
func _build(res: Dictionary, counts: Dictionary, fin: Dictionary, home: Dictionary, p: Dictionary) -> void:
	var p0: Vector2 = home.pos
	p["home_pos"] = p0
	if res.wood >= 120 and game.unit_count(player) + game.queue_count(player) + 3 >= int(p.farm_cap):
		_try_build("hou", home)
	for k in ["gold", "iron", "coal"]:
		var sid: String = "mine_" + k
		if int(counts.get(sid, 0)) == 0 and res.wood >= 100 and res.stone >= 100:
			_build_mine(k, home)
	if int(counts.get("bar", 0)) < 3 and res.wood >= 150 and res.stone >= 150:
		_try_build("bar", home)
	if int(counts.get("sto", 0)) == 0 and res.wood >= 50 and res.stone >= 20:
		_try_build("sto", home)
	if int(counts.get("bla", 0)) == 0 and res.wood >= 100 and res.stone >= 30:
		_try_build("bla", home)
	if int(counts.get("mil", 0)) == 0 and res.wood >= 200 and res.stone >= 100:
		_try_build("mil", home)
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
	# wall ring: 12 segments, not 4
	if int(counts.get("wal", 0)) < 12 and res.stone >= 200 and res.wood >= 60:
		_try_build("wal", home, 14.0, 22.0)
	if int(counts.get("tow", 0)) < 2 and res.wood >= 300 and res.stone >= 400 and int(fin.get("bar", 0)) > 0:
		_try_build("tow", home, 16.0, 24.0)
	for b in game.buildings_of(player):
		if b.sid == "mar" and b.finished:
			_market_balance(b)

func _try_build(sid: String, home: Dictionary, min_d := 0.0, max_d := 18.0) -> void:
	var def: Dictionary = Data.BUILDINGS[sid]
	var lo: float = min_d if min_d > 0.0 else def.radius + 2.5
	var pos := _find_spot(home, def, lo, max_d)
	if pos == Vector2.INF:
		return
	game.place_building(player, sid, pos)

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
	game.place_building(player, "mine_" + kind, best.pos)

func _find_spot(home: Dictionary, def: Dictionary, min_d: float, max_d: float) -> Vector2:
	for attempt in 24:
		var a := game.rng.randf() * TAU
		var r := game.rng.randf_range(min_d, max_d)
		var pos: Vector2 = home.pos + Vector2(cos(a), sin(a)) * r
		if not game.in_bounds(pos) or game.is_blocked(pos):
			continue
		var ok := true
		for b in game.buildings_of(player, false):
			if b.pos.distance_to(pos) < b.def.radius + def.radius + 1.0:
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
	if int(fin.get("cen", 0)) > 0 and peasants.size() < Data.AI_MAX_PEASANTS and res.food >= 100:
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

# --- cavalry raids on enemy economy (video 1) ---
func _raids(military: Array, res: Dictionary) -> void:
	var cav: Array = []
	for m in military:
		if game._kind_class(m) == "cavalry" and m.order.type == "none":
			cav.append(m)
	if cav.size() < 6:
		return
	if raid_ids.is_empty():
		for i in range(0, mini(cav.size(), 12)):
			raid_ids.append(cav[i].id)
	var target: Dictionary = {}
	var bd := 1e9
	for n in game.res_nodes:
		if n.type == "food" and n.hits > 0:
			for e in game.entities:
				if not e.dead and e.player != player and e.kind == "unit" and str(e.sid) == "peasant" and e.pos.distance_to(n.pos) < 8.0:
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
	for b in game.buildings_of(1 - player):
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
