# Core simulation: map, entities, orders, gathering, building, combat, victory.
# All numbers come from ../scripts/data.gd (original game files, see MECHANICS.md).
extends Node
class_name C3Game

const Data = preload("res://scripts/data.gd")

const TILE := 2.0
var MAP_W := 160
var MAP_H := 160
var TICK_MAX := 0.25  # clamp dt so tests never stall

signal game_over(winner: int)
signal message(text: String)

var terrain: PackedByteArray = PackedByteArray()
var blocked: PackedByteArray = PackedByteArray()
var height: PackedFloat32Array = PackedFloat32Array()
var hill_list: Array = []
var map_meta: Dictionary = {}  # donor terrain type + chosen heightmask (for the quality scan)
# Donor tile system (data/terrain/tiles + data/gen/tilesmooth_scripts.cfg):
# every map cell carries a TileBlock index (summer preset order). Base blocks
# come from biome proportions, then TextureMap-style oriented shores/cliffs,
# then the exact 3-pass SmoothTileMap transition insertion, then meadow detail.
# Water cells hold BLK_WATER (donor renders water as a separate plane).
const BLK_WATER := 255
var tileblock: PackedByteArray = PackedByteArray()
var tbl_names: Array = []
var tbl_smooth: Array = []
var tbl_idx := {}
var res_nodes: Array = []
var map_starts: Array = []  # start positions of the generated map (groves near them are sacred)
var cluster_zones: Array = []  # claimed {pos, r} so clusters never overlap
var entities: Array = []
var by_id: Dictionary = {}
var next_id := 1
var players: Array = []
var battle_mode := false
var time_s := 0.0
var winner := -1
var rng := RandomNumberGenerator.new()
var events: Array = []   # {type, pos, kind} consumed by world/hud each frame
var projectiles: Array = []  # delayed shells/arrows: {pos,target,kind,dmg,splash,owner,t,total}
var corpses: Array = []  # fading dead units for the battlefield look (capped)
var rubble: Array = []  # lingering destroyed-building rubble (capped)
var squads: Dictionary = {}  # squad_id -> {officer, drummer, members, formation, player}
var gates: Array = []
var grid: Dictionary = {}          # Vector2i cell -> Array of entity dicts
const GRID_M := 8.0
var live_units: Array = []
var live_blds: Array = []
var officers: Array = [[], []]
var drummers: Array = [[], []]
var priests: Array = [[], []]
var compact_t := 0.0
var res_dirty := 0
var bld_dirty := 0
var ai_cheat_t := 0.0
func _blocked_for(e: Dictionary, p: Vector2) -> bool:
	if is_blocked(p):
		return true
	for g in gates:
		if g.dead:
			continue
		if g.pos.distance_to(p) <= float(g.def.radius) + 0.4:
			if bool(g.get("closed", false)) or int(g.player) != int(e.player):
				return true
	return false
var next_squad := 1
var objectives: Array = []  # [{text, done}] mission objectives (menu/campaigns)
var stats := {"shots": 0, "hits": 0, "kills": 0, "gathered": {}}
var paused := false
var deposits: Dictionary = {}  # "gold"/"iron"/"coal" remaining

func _init() -> void:
	rng.seed = Data.RANDOM_SEED

func _grid_rebuild() -> void:
	grid.clear()
	live_units.clear()
	live_blds.clear()
	officers[0].clear(); officers[1].clear()
	drummers[0].clear(); drummers[1].clear()
	priests[0].clear(); priests[1].clear()
	for e in entities:
		if e.dead:
			continue
		var c := Vector2i(int(e.pos.x / GRID_M), int(e.pos.y / GRID_M))
		if not grid.has(c):
			grid[c] = []
		grid[c].append(e)
		if e.kind == "unit":
			live_units.append(e)
			var p: int = int(e.player)
			if p >= 0 and p < 2:
				if str(e.sid) in ["officer", "officer18"]:
					officers[p].append(e)
				elif str(e.sid) in ["drummer", "drummer18"]:
					drummers[p].append(e)
				elif str(e.sid) in ["priest", "pope", "padre", "mullah"]:
					priests[p].append(e)
		else:
			live_blds.append(e)

func grid_query(pos: Vector2, r: float) -> Array:
	var out: Array = []
	var c0 := Vector2i(int((pos.x - r) / GRID_M), int((pos.y - r) / GRID_M))
	var c1 := Vector2i(int((pos.x + r) / GRID_M), int((pos.y + r) / GRID_M))
	for cy in range(c0.y, c1.y + 1):
		for cx in range(c0.x, c1.x + 1):
			var cell: Array = grid.get(Vector2i(cx, cy), [])
			for e in cell:
				out.append(e)
	return out

func _compact() -> void:
	var keep: Array = []
	for e in entities:
		if e.dead:
			by_id.erase(e.id)
		else:
			keep.append(e)
	entities = keep
	for pi in 2:
		var pl: Array = []
		for id in players[pi].entities:
			var e: Dictionary = by_id.get(id, {})
			if not e.is_empty():
				pl.append(id)
		players[pi].entities = pl
	var gk: Array = []
	for g in gates:
		if not g.dead:
			gk.append(g)
	gates = gk
	var rk: Array = []
	for n in res_nodes:
		if n.max_hits == 0 or n.hits > 0 or n.type == "food":
			rk.append(n)
		else:
			by_id.erase(n.id)
	res_nodes = rk

func res_list() -> Array:
	var out: Array = []
	for r in Data.RES_NAMES:
		out.append(float(Data.START_RESOURCES.get(r, 0.0)))
	return out

func new_player(index: int, name: String, is_ai: bool) -> Dictionary:
	return {"index": index, "name": name, "res": res_list(), "is_ai": is_ai,
		"farm_cap": 0, "score": 0, "entities": [], "ai_state": {}, "starving": false,
		"famine_t": 0.0, "famine": false,
		"damage_mult": {"sword": 1.0, "pike": 1.0, "bullet": 1.0, "arrow": 1.0, "firearrow": 1.0, "cannonball": 1.0, "cannister": 1.0},
		"gather_mult": {"food": 1.0, "wood": 1.0, "stone": 1.0},
		"hp_mult": 1.0, "prot_bonus": 0,
		"upgrades": [], "research": {},
		"market_rate": Data.MARKET_RATE}

func setup(mode: String) -> void:
	battle_mode = mode == "battle"
	MAP_W = Data.MAP_W
	MAP_H = Data.MAP_H
	TICK_MAX = Data.TICK_MAX
	rng.seed = Data.RANDOM_SEED
	terrain.resize(MAP_W * MAP_H)
	blocked.resize(MAP_W * MAP_H)
	height.resize(MAP_W * MAP_H)
	for i in terrain.size():
		terrain[i] = 0
		blocked[i] = 0
		height[i] = 0.0
	# nations come from the menu (Data.PLAYER_NATIONS sids); names follow.
	var pn := Data.PLAYER_NAMES
	var pns: Array = Data.PLAYER_NATIONS if Data.PLAYER_NATIONS is Array else ["ukr", "rus"]
	players = [new_player(0, _nation_name(0, pn), false), new_player(1, _nation_name(1, pn), true)]
	players[0]["nation"] = str(pns[0]) if pns.size() > 0 else "ukr"
	players[1]["nation"] = str(pns[1]) if pns.size() > 1 else "rus"
	objectives = []
	deposits = {}
	for r in Data.RES_NAMES:
		deposits[r] = float(Data.DEPOSITS.get(r, 0.0))
	_generate_map()
	_spawn_starts()
	_grid_rebuild()

func _nation_name(i: int, pn: Variant) -> String:
	var pns: Array = Data.PLAYER_NATIONS if Data.PLAYER_NATIONS is Array else []
	var sid := str(pns[i]) if pns.size() > i else ""
	if Data.NATIONS.has(sid):
		return str(Data.NATIONS[sid].name)
	if pn is Array and pn.size() > i:
		return str(pn[i])
	return "Player %d" % (i + 1)

func set_objectives(texts: Array) -> void:
	objectives = []
	for t in texts:
		objectives.append({"text": str(t), "done": false})

func complete_objective(i: int) -> void:
	if i >= 0 and i < objectives.size():
		objectives[i].done = true
		say("Objective complete: %s" % objectives[i].text)

func set_rally(b: Dictionary, pos: Vector2) -> void:
	if b.is_empty() or b.kind != "building":
		return
	b["rally"] = pos

# ---------------------------------------------------------------- map gen
func _t(x: int, y: int) -> int:
	return y * MAP_W + x

func in_bounds(p: Vector2) -> bool:
	return p.x >= 0 and p.y >= 0 and p.x < MAP_W * TILE and p.y < MAP_H * TILE

func tile_of(p: Vector2) -> Vector2i:
	return Vector2i(int(p.x / TILE), int(p.y / TILE))

func is_blocked(p: Vector2) -> bool:
	if not in_bounds(p):
		return true
	return blocked[_t(tile_of(p).x, tile_of(p).y)] != 0

func set_blocked_circle(p: Vector2, r_m: float, value: bool) -> void:
	var t0 := tile_of(p - Vector2(r_m, r_m))
	var t1 := tile_of(p + Vector2(r_m, r_m))
	for y in range(maxi(0, t0.y), mini(MAP_H, t1.y + 1)):
		for x in range(maxi(0, t0.x), mini(MAP_W, t1.x + 1)):
			var c := Vector2((x + 0.5) * TILE, (y + 0.5) * TILE)
			if c.distance_to(p) <= r_m:
				blocked[_t(x, y)] = 1 if value else 0

func _add_res(type: String, pos: Vector2, hits: int, radius: float) -> void:
	var node := {"id": next_id, "kind": "res", "type": type, "pos": pos, "hits": hits,
		"max_hits": hits, "radius": radius}
	next_id += 1
	res_nodes.append(node)
	by_id[node.id] = node
	if type not in ["food", "bush", "stump"]:
		set_blocked_circle(pos, radius, true)
	res_dirty += 1

func _clear_area(pos: Vector2, r_m: float) -> void:
	for n in res_nodes:
		if n.pos.distance_to(pos) < r_m:
			n.hits = 0  # depleted (removed visually)

func _paint_terrain(pos: Vector2, r_m: float, t: int) -> void:
	var t0 := tile_of(pos - Vector2(r_m, r_m))
	var t1 := tile_of(pos + Vector2(r_m, r_m))
	for y in range(maxi(0, t0.y), mini(MAP_H, t1.y + 1)):
		for x in range(maxi(0, t0.x), mini(MAP_W, t1.x + 1)):
			var c := Vector2((x + 0.5) * TILE, (y + 0.5) * TILE)
			if c.distance_to(pos) <= r_m and terrain[y * MAP_W + x] != 3:
				terrain[y * MAP_W + x] = t

func _scatter_forest(center: Vector2, count: int, spread: float) -> void:
	for i in count:
		var p := center + Vector2(rng.randf_range(-spread, spread), rng.randf_range(-spread, spread))
		if not in_bounds(p) or is_blocked(p):
			continue
		# trees grow on grass/meadow/dirt only — never on rock, sand or water
		# (covers hills and lake shores whatever the placement order)
		var tt: int = terrain[_t(int(p.x / TILE), int(p.y / TILE))]
		if tt != 0 and tt != 1 and tt != 2:
			continue
		# never plant into quarries, mine sites or fields: clusters stay pure
		# (the managed park around starts is exempt — groves belong there)
		var clash := false
		var near_home := false
		for st in map_starts:
			if p.distance_to(st) < 12.0 * TILE:
				near_home = true
				break
		if not near_home:
			for n in res_nodes:
				if n.type != "wood" and n.pos.distance_to(p) < 4.0 * TILE:
					clash = true
					break
		if clash:
			continue
		_add_res("wood", p, 60, 0.7)

# Dry shrubs near quarries and on sand (donor decor dcr/str families).
# Deco only: hits 0, radius 0.3, never blocks, never gathered, never claimed.
func _scatter_bushes() -> void:
	for attempt in 40:
		var cand := Vector2(rng.randf_range(MAP_W * 0.08, MAP_W * 0.92) * TILE,
			rng.randf_range(MAP_H * 0.08, MAP_H * 0.92) * TILE)
		if not in_bounds(cand) or is_blocked(cand):
			continue
		var near_start := false
		for st in map_starts:
			if cand.distance_to(st) < 9.0 * TILE:
				near_start = true
				break
		if near_start:
			continue
		var tt: int = terrain[_t(int(cand.x / TILE), int(cand.y / TILE))]
		if tt == 3:
			continue
		var near_stone := false
		for n in res_nodes:
			if n.type == "stone" and n.pos.distance_to(cand) < 5.0 * TILE:
				near_stone = true
				break
		var want := false
		if near_stone and (tt == 1 or tt == 5) and rng.randf() < 0.5:
			want = true
		elif tt == 4 and rng.randf() < 0.3:
			want = true
		if not want:
			continue
		_add_res("bush", cand, 0, 0.3)

# Original maps keep resource kinds apart: quarries sit in rock/dirt
# clearings (never inside forest), mines on worked dirt. Wood nodes inside
# the given radius are depleted so stone never mixes trees.
# The starting groves (peasant work area) are sacred: nothing clears them
# unless ignore_home is set (final purity pass: deposits/quarries win).
func _clear_trees(pos: Vector2, r_m: float, ignore_home := false) -> void:
	for n in res_nodes:
		if n.type != "wood" or n.pos.distance_to(pos) >= r_m:
			continue
		var near_home := false
		for st in map_starts:
			if n.pos.distance_to(st) < 12.0 * TILE:
				near_home = true
				break
		if not near_home or ignore_home:
			n.hits = 0

# Cluster registry: forests, quarries, mines and fields claim ground so
# clusters sit near each other but never overlap (original map layout).
func _claim_cluster(pos: Vector2, r_m: float, margin_m := 4.0) -> bool:
	for z in cluster_zones:
		var zd: Dictionary = z
		if pos.distance_to(zd.pos) < r_m + float(zd.r) + margin_m:
			return false
	cluster_zones.append({"pos": pos, "r": r_m})
	return true

func _generate_map() -> void:
	# DONOR PIPELINE (data/scripts/common.inc/generatemap.inc -> dogenerate.inc):
	# 1. pick a hand-authored RGB terrain mask (R relief, G forest/stone,
	#    B water, white = start) from data/gen/terrainmasks/<terrain>/.
	# 2. SetHeightData: h = -1.1*b*(1+r*3.5) + relief(r); water < -0.25,
	#    shore < -0.1; 3 coastal smoothing passes.
	# 3. pattern passes: relief domes, mines at start rings, forests, stones,
	#    decor, fields.  We keep the port's pattern equivalents below but the
	#    SHAPE of every map (coast, lakes, start positions) now comes from the
	#    donor mask, not from per-seed blobs.
	# 4. TextureMap + SmoothTiles runs at the end (_assign_tileblocks).
	var budget: Dictionary = Data.mapgen_budget()
	# donor scales pattern frequency with map size (_misc_GetFreePatternMaskModifier).
	# The port's pattern radii were tuned at 160 tiles; scale them to this map.
	var mscale: float = clampf(float(MAP_W) / 160.0, 1.0, 2.0)
	var mg: Dictionary = C3MapGen.build(str(Data.MAP_TYPE), int(Data.RANDOM_SEED),
		MAP_W, MAP_H, TILE, str(Data.QUALITY))
	height = mg.get("height", PackedFloat32Array())
	map_meta = {"type": str(Data.MAP_TYPE), "quality": str(Data.QUALITY),
		"mask": mg.get("mask", {}), "mask_water": float(mg.get("water", 0.0))}
	var forest_field: PackedFloat32Array = mg.get("forest", PackedFloat32Array())
	var starts: Array[Vector2] = []
	for sv in mg.get("starts", []):
		starts.append(sv as Vector2)
	if starts.size() < 2:
		starts = _start_positions()
	map_starts = starts
	cluster_zones = []
	# relief domes = the donor's hills_dark/hills_light/mountains pattern passes.
	# Donor cHillHeight = 1.317 (half of the 2.964 plateau).
	hill_list = []
	for _hi in int(budget.get("domes", 3)):
		var cx := rng.randf_range(MAP_W * 0.2, MAP_W * 0.8)
		var cy := rng.randf_range(MAP_H * 0.2, MAP_H * 0.8)
		var rr := rng.randf_range(7.0, 13.0)
		hill_list.append({"x": cx, "y": cy, "rr": rr})
		for y in range(maxi(0, int(cy - rr)), mini(MAP_H, int(cy + rr) + 1)):
			for x in range(maxi(0, int(cx - rr)), mini(MAP_W, int(cx + rr) + 1)):
				var dd: float = Vector2(x - cx, y - cy).length() / rr
				if dd >= 1.0:
					continue
				var i := _t(x, y)
				if height[i] < C3MapGen.WATER_SHORE:
					continue
				height[i] += (1.0 - dd) * (1.0 - dd) * (2.964 / 2.25)
	# base tile roles from the donor height thresholds (guides shore/collision):
	# h < -0.25 = water plane, -0.25..-0.1 = wet sand collar, above = meadow
	# (with broad dirt expanses from low-frequency noise).
	for y in MAP_H:
		for x in MAP_W:
			var i := _t(x, y)
			var hh: float = height[i]
			var t := 0
			if hh < C3MapGen.WATER_DEEP:
				t = 3
				set_blocked_tile(x, y, true)
			elif hh < -0.05:
				t = 4  # donor sandsea collar: Mask B gradient makes a ~2-3 tile band
			else:
				var n := _noise2(x * 0.012 + float(Data.RANDOM_SEED % 997) * 0.01,
					y * 0.012 - float(Data.RANDOM_SEED % 991) * 0.01)
				var n2 := _noise2(x * 0.05 + 57.0, y * 0.05 - 31.0)
				if n > 0.22 and n2 > -0.15:
					t = 1
			terrain[i] = t
	# donor TextureMap paints the wet sandsea* rim ON the water cells that
	# touch land (orientation = ripple direction).  Port equivalent: turn the
	# outermost water ring into walkable sand.  This gives every lake/sea a
	# continuous collar instead of a one-pixel hairline.
	var shore_ring := PackedByteArray()
	shore_ring.resize(MAP_W * MAP_H)
	for y in MAP_H:
		for x in MAP_W:
			var i := _t(x, y)
			if terrain[i] != 3:
				continue
			var touches := false
			for oy in range(-1, 2):
				for ox in range(-1, 2):
					var nx: int = x + ox
					var ny: int = y + oy
					if nx < 0 or ny < 0 or nx >= MAP_W or ny >= MAP_H:
						continue
					if terrain[_t(nx, ny)] != 3:
						touches = true
						break
				if touches:
					break
			if touches:
				shore_ring[i] = 1
	for i in shore_ring.size():
		if shore_ring[i] == 1:
			terrain[i] = 4
			blocked[i] = 0
	# collision pass of donor texturemap.inc: cardinal |dh|>0.5 or diagonal
	# |dh|>0.55 becomes impassable rock (cDiff1 / cDiff2).  Skip water AND sand
	# so the shore collar keeps its sand art and stays walkable.
	for y in MAP_H:
		for x in MAP_W:
			var i := _t(x, y)
			if terrain[i] == 3 or terrain[i] == 4:
				continue
			var h0: float = height[i]
			var steep := false
			if x + 1 < MAP_W and absf(height[i + 1] - h0) > 0.5:
				steep = true
			if x > 0 and absf(height[i - 1] - h0) > 0.5:
				steep = true
			if y + 1 < MAP_H and absf(height[i + MAP_W] - h0) > 0.5:
				steep = true
			if y > 0 and absf(height[i - MAP_W] - h0) > 0.5:
				steep = true
			if x > 0 and y > 0 and absf(height[i - MAP_W + 1] - h0) > 0.55:
				steep = true
			if x + 1 < MAP_W and y + 1 < MAP_H and absf(height[i + MAP_W + 1] - h0) > 0.55:
				steep = true
			if steep:
				terrain[i] = 5
				set_blocked_tile(x, y, true)
	# Starts can land in shallow water on a mask edge: snap to the nearest land.
	for si in starts.size():
		var st: Vector2 = starts[si]
		if terrain[_t(int(st.x / TILE), int(st.y / TILE))] != 3:
			continue
		var best := st
		var bd := 1.0e9
		for y in MAP_H:
			for x in MAP_W:
				if terrain[_t(x, y)] == 3:
					continue
				var d: float = Vector2(float(x) + 0.5, float(y) + 0.5).distance_to(st / TILE)
				if d < bd:
					bd = d
					best = Vector2(float(x) + 0.5, float(y) + 0.5) * TILE
		starts[si] = best
	map_starts = starts
	# dirt road between the two starts through the centre (donor broad mask
	# alpha -> ground1/test2/test3; port keeps one simple road).
	_draw_road(starts[0], (starts[0] + starts[1]) * 0.5)
	_draw_road((starts[0] + starts[1]) * 0.5, starts[1])
	# forests: the donor places forest_* pattern families globally, but never
	# in the three elliptical keep-clear zones around a start.  The G channel
	# of the mask (where present) biases belt centres to natural woodland.
	var belts: Array = budget.get("belts", [6, 8])
	var trees: Array = budget.get("trees", [34, 60])
	var forest_centers: Array = []
	for _f in rng.randi_range(int(belts[0]), int(belts[1])):
		var c := Vector2(-1, -1)
		var best_bias := -1.0
		for attempt in 14:
			var cand := Vector2(rng.randf_range(MAP_W * 0.08, MAP_W * 0.92) * TILE,
				rng.randf_range(MAP_H * 0.08, MAP_H * 0.92) * TILE)
			var too_close := false
			for st in starts:
				if cand.distance_to(st) < 22.0 * TILE:
					too_close = true
					break
			if too_close or not in_bounds(cand) or is_blocked(cand):
				continue
			var tt := tile_of(cand)
			var bias: float = forest_field[_t(tt.x, tt.y)] if forest_field.size() == MAP_W * MAP_H else 0.0
			if bias > best_bias and _claim_cluster(cand, 7.0 * TILE * mscale):
				best_bias = bias
				c = cand
				if bias > 0.5:
					break
		if c.x < 0.0:
			continue
		forest_centers.append(c)
		_paint_terrain(c, 5.5 * TILE * mscale, 2)
		_scatter_forest(c, int(float(rng.randi_range(int(trees[0]), int(trees[1]))) * mscale), 5.0 * TILE * mscale)
	# two groves per start (donor cCircle1 keep-clear outer ring = firewood).
	for st in starts:
		_paint_terrain(st + Vector2(7, -7) * TILE * mscale, 4.5 * TILE * mscale, 2)
		_scatter_forest(st + Vector2(7, -7) * TILE * mscale, int(26.0 * mscale), 5.0 * TILE * mscale)
		_paint_terrain(st + Vector2(-8, 5) * TILE * mscale, 4.0 * TILE * mscale, 2)
		_scatter_forest(st + Vector2(-8, 5) * TILE * mscale, int(18.0 * mscale), 4.0 * TILE * mscale)
	# quarries: donor stones/stoneforests patterns, always clear of woodland.
	for _s in int(budget.get("quarries", 7)):
		var c := Vector2(-1, -1)
		for attempt in 8:
			var cand := Vector2(rng.randf_range(MAP_W * 0.09, MAP_W * 0.91) * TILE,
				rng.randf_range(MAP_H * 0.09, MAP_H * 0.91) * TILE)
			if not in_bounds(cand) or is_blocked(cand):
				continue
			if _claim_cluster(cand, 7.0 * TILE, 6.0):
				c = cand
				break
		if c.x < 0.0:
			continue
		for i in rng.randi_range(5, 8):
			var p := c + Vector2(rng.randf_range(-4, 4), rng.randf_range(-4, 4)) * TILE
			if in_bounds(p) and not is_blocked(p):
				_add_res("stone", p, 80, 0.9)
		_paint_terrain(c, 6.0 * TILE, 1)
		_paint_terrain(c, 3.5 * TILE, 5)
		_clear_trees(c, 7.0 * TILE)
	# guaranteed stone near each start (SetupStartingResources cCircle2 ring).
	for st in starts:
		for attempt in 8:
			var ang0 := rng.randf() * TAU
			var cc := st + Vector2(cos(ang0), sin(ang0)) * 16.0 * TILE
			if in_bounds(cc) and not is_blocked(cc):
				for i in 3:
					var p := cc + Vector2(rng.randf_range(-1, 1), rng.randf_range(-1, 1)) * TILE
					if in_bounds(p) and not is_blocked(p):
						_add_res("stone", p, 80, 0.9)
				_paint_terrain(cc, 4.0 * TILE, 1)
				_paint_terrain(cc, 2.0 * TILE, 5)
				_clear_trees(cc, 5.0 * TILE)
				break
	# seed wheat (donor cSeedWheat): rectangular farm strips by each town.
	for st in starts:
		for g in 2:
			var origin := st + Vector2(-10 + g * 7.0, 7.0) * TILE
			for ix in 5:
				for iy in 4:
					var p := origin + Vector2(ix * 1.5, iy * 1.5) * TILE
					if in_bounds(p) and not is_blocked(p):
						_add_res("food", p, 50, 0.6)
	# straggler fields: small claimed patches, never inside other clusters.
	for st in starts:
		for attempt in 6:
			var c := st + Vector2(rng.randf_range(-6, 6), rng.randf_range(-6, 6)) * TILE
			if not in_bounds(c) or is_blocked(c):
				continue
			if not _claim_cluster(c, 4.0 * TILE):
				continue
			for i in 6:
				var p := c + Vector2(rng.randf_range(-2.5, 2.5), rng.randf_range(-2.5, 2.5)) * TILE
				if in_bounds(p) and not is_blocked(p):
					_add_res("food", p, 50, 0.6)
			break
	# mines: donor SetupMines distance bands (mng/mni/mnc) + 1/kind guaranteed
	# per start. Each sits on its own dirt pad, clear of trees.
	var kinds := ["gold", "iron", "coal"]
	for k in kinds:
		for m in 2:
			var p := Vector2(-1, -1)
			for attempt in 8:
				var cand := Vector2(rng.randf_range(MAP_W * 0.15, MAP_W * 0.85),
					rng.randf_range(MAP_H * 0.15, MAP_H * 0.85)) * TILE + Vector2(1, 1)
				if not in_bounds(cand) or is_blocked(cand):
					continue
				if _claim_cluster(cand, 6.0 * TILE, 8.0):
					p = cand
					break
			if p.x < 0.0:
				continue
			_add_res(k, p, 0, 0.0)
			_paint_terrain(p, 4.0 * TILE, 1)
			_clear_trees(p, 6.0 * TILE)
	if bool(budget.get("decor", true)):
		_scatter_bushes()
	# keep the three elliptical start zones clear (donor gPatternMask).
	for st in starts:
		_paint_terrain(st, 5.0 * TILE, 1)
		_clear_area(st, 9.0 * TILE)
		for n in res_nodes:
			if n.hits <= 0:
				set_blocked_circle(n.pos, n.radius, false)
		for ki in kinds.size():
			var dist: float = (14.0 + ki * 5.0) * TILE
			for attempt in 8:
				var ang := rng.randf() * TAU
				var dp := st + Vector2(cos(ang), sin(ang)) * dist
				dp = Vector2(floor(dp.x / TILE) * TILE + 1.0, floor(dp.y / TILE) * TILE + 1.0)
				if in_bounds(dp) and not is_blocked(dp):
					_add_res(kinds[ki], dp, 0, 0.0)
					_paint_terrain(dp, 4.0 * TILE, 1)
					_clear_trees(dp, 6.0 * TILE)
					break
		# re-plant what the keep-clear wiped: wheat + firewood in reach.
		for g in 2:
			var origin := st + Vector2(-9 + g * 8.0, 8.5) * TILE
			for ix in 5:
				for iy in 4:
					var p := origin + Vector2(ix * 1.5, iy * 1.5) * TILE
					if in_bounds(p) and not is_blocked(p):
						_add_res("food", p, 50, 0.6)
		_scatter_forest(st + Vector2(9, -8) * TILE, 26, 5.0 * TILE)
		_paint_terrain(st + Vector2(9, -8) * TILE, 4.5 * TILE, 2)
		_scatter_forest(st + Vector2(-10, 6) * TILE, 18, 4.0 * TILE)
		_paint_terrain(st + Vector2(-10, 6) * TILE, 4.0 * TILE, 2)
	# purity pass: late groves must not invade quarries or mine pads.
	for n in res_nodes:
		if n.type == "stone" or (n.max_hits == 0 and str(n.type) in ["gold", "iron", "coal"]):
			_clear_trees(n.pos, 5.0 * TILE, true)
	for st in starts:
		_clear_area(st, 4.0 * TILE)
	# per-node deposit split: each deposit holds its share of the global pool.
	var cnt := {"gold": 0, "iron": 0, "coal": 0}
	for n in res_nodes:
		if n.max_hits == 0 and cnt.has(n.type):
			cnt[n.type] = int(cnt[n.type]) + 1
	for n in res_nodes:
		if n.max_hits == 0 and cnt.has(n.type) and int(cnt[n.type]) > 0:
			n["left"] = float(Data.DEPOSITS.get(n.type, 30000)) / float(cnt[n.type])
	# donor TextureMap -> SmoothTiles -> SmoothForestBorders.
	_assign_tileblocks()

func _load_terrain_structs() -> void:
	if not tbl_names.is_empty():
		return
	var a1 = JSON.parse_string(FileAccess.get_file_as_string("res://assets/terrain/structs/presets_summer.json"))
	if a1 is Array:
		tbl_names = a1
	for i in tbl_names.size():
		tbl_idx[str(tbl_names[i])] = i
	var a2 = JSON.parse_string(FileAccess.get_file_as_string("res://assets/terrain/structs/smooth_summer.json"))
	if a2 is Array:
		tbl_smooth = a2

func _blk(n: String) -> int:
	return int(tbl_idx.get(n, 0))

func _assign_tileblocks() -> void:
	# deterministic stream of its own (same map on every load, no save data)
	_load_terrain_structs()
	tileblock.resize(MAP_W * MAP_H)
	var brng := RandomNumberGenerator.new()
	brng.seed = int(Data.RANDOM_SEED) + 7
	# 1) base blocks from biome proportions (donor tile_low/highground stats:
	# meadow = grass1 + test7/8/9 worn patches + grass variety speckles)
	for y in MAP_H:
		for x in MAP_W:
			var t: int = terrain[_t(x, y)]
			var b := _blk("grass1")
			var r := brng.randf()
			match t:
				0:
					var hh := height_at(Vector2((float(x) + 0.5) * TILE, (float(y) + 0.5) * TILE))
					if hh > 0.6:
						if r < 0.40:
							b = _blk("test7")
						elif r < 0.65:
							b = _blk("test8")
						elif r < 0.85:
							b = _blk("test9")
						elif r < 0.95:
							b = _blk("grass8")
						else:
							b = _blk("grass2")
					else:
						if r < 0.50:
							b = _blk("grass1")
						elif r < 0.60:
							b = _blk("test7")
						elif r < 0.70:
							b = _blk("test8")
						elif r < 0.80:
							b = _blk("test9")
						elif r < 0.84:
							b = _blk("grass2")
						elif r < 0.88:
							b = _blk("grass8")
						elif r < 0.92:
							b = _blk("grass10")
						elif r < 0.96:
							b = _blk("grass7")
						else:
							b = _blk("grass9")
				1:
					b = _blk("ground1")
				2:
					if r < 0.64:
						b = _blk("grass_ground1")
					elif r < 0.6428:
						b = _blk("grass_ground2")
					else:
						b = _blk("grass_ground3")
				3:
					b = BLK_WATER
				4:
					b = _blk(["sand1", "sand2", "sand7"][brng.randi() % 3])
				5:
					if r < 0.16:
						b = _blk("rock1")
					elif r < 0.32:
						b = _blk("rock2")
					elif r < 0.48:
						b = _blk("rock3")
					elif r < 0.64:
						b = _blk("rock6")
					elif r < 0.80:
						b = _blk("rock7")
					else:
						b = _blk("rock4")
			tileblock[_t(x, y)] = b
	# 2) oriented shores + cliffs (donor texturemap.inc 8-sector tables)
	_apply_shore_cliffs()
	# 3) exact 3-pass SmoothTileMap (donor smoothtiles.inc)
	_smooth_tilemap(brng)
	# 4) forest-border stamps (donor smoothforestborders.inc: grass5/rock9
	# tiles + bushes at edge cells with exactly one forest neighbour)
	_stamp_forest_borders(brng)

func _shore_tile_for(x: int, y: int) -> String:
	var dx := 0.0
	var dy := 0.0
	for oy in [-1, 0, 1]:
		for ox in [-1, 0, 1]:
			if ox == 0 and oy == 0:
				continue
			var nx: int = x + ox
			var ny: int = y + oy
			if nx < 0 or ny < 0 or nx >= MAP_W or ny >= MAP_H:
				continue
			if int(terrain[_t(nx, ny)]) == 3:
				dx += float(x - nx)
				dy += float(y - ny)
	if dx == 0.0 and dy == 0.0:
		return ""
	var ang := fposmod(rad_to_deg(atan2(dy, dx)), 360.0)
	if ang >= 337.5 or ang < 22.5:
		return "sandsea6"
	if ang < 67.5:
		return "sandsea6"
	if ang < 112.5:
		return "sandsea1"
	if ang < 157.5:
		return "sandsea5"
	if ang < 202.5:
		return "sandsea6"
	if ang < 247.5:
		return "sandsea6"
	if ang < 292.5:
		return "sandsea1"
	return "sandsea5"

func _cliff_tile_for(x: int, y: int) -> String:
	# exact donor texturemap.inc:426-447,557-609 cliff orientation
	var lh: float = height[_t(maxi(0, x - 1), y)]
	var rh: float = height[_t(mini(MAP_W - 1, x + 1), y)]
	var th: float = height[_t(x, maxi(0, y - 1))]
	var bh: float = height[_t(x, mini(MAP_H - 1, y + 1))]
	var dir_x := lh - rh
	var dir_y := th - bh
	if absf(dir_x) < 0.01 and absf(dir_y) < 0.01:
		return ""
	var ang := rad_to_deg(atan2(dir_y, dir_x))
	if dir_y < 0.0:
		ang = -ang
	var nt := ""
	if ang >= 22.5 and ang <= 67.5:
		nt = "rock4"       # bRB
	elif ang >= 120.0 and ang <= 170.0:
		nt = "rock7"       # bLB
	elif ang >= -45.0 and ang <= 45.0:
		nt = "rock4"       # bR (donor commented out rock2)
	elif ang >= 45.0 and ang <= 135.0:
		nt = "rock1"       # bB
	elif ang >= -135.0 and ang <= -45.0:
		nt = "rock4"       # bT
	else:
		nt = "rock3"       # bL
	var h0: float = height[_t(x, y)]
	if absf(h0) > 2.7:
		nt = "rock8"
	elif absf(h0) > 2.4:
		nt = "rock4"
	elif absf(h0) < 0.1:
		return ""
	return nt

func _apply_shore_cliffs() -> void:
	for y in MAP_H:
		for x in MAP_W:
			var t: int = terrain[_t(x, y)]
			if t == 4:
				var s := _shore_tile_for(x, y)
				if s != "":
					tileblock[_t(x, y)] = _blk(s)
			elif t == 5:
				var c := _cliff_tile_for(x, y)
				if c != "":
					tileblock[_t(x, y)] = _blk(c)

func _tb_pick(li: int, gi: int, brng: RandomNumberGenerator) -> int:
	var chain: Array = tbl_smooth[li]
	if gi < 0 or gi >= chain.size():
		return -1
	var group: Array = chain[gi]
	var total := 0.0
	for td in group:
		total += float(td.get("prob", 0.0))
	if total <= 0.0:
		return -1
	var r := brng.randf() * total
	var acc := 0.0
	for td in group:
		var p := float(td.get("prob", 0.0))
		acc += p
		if p > 0.0 and r < acc:
			return _blk(str(td.get("name", "")))
	return -1

func _tb_smooth_pair(x1: int, y1: int, x2: int, y2: int, brng: RandomNumberGenerator) -> void:
	var i1: int = tileblock[_t(x1, y1)]
	var i2: int = tileblock[_t(x2, y2)]
	if i1 == BLK_WATER or i2 == BLK_WATER or i1 == i2:
		return
	if i1 >= tbl_names.size() or i2 >= tbl_names.size():
		return
	var n1 := str(tbl_names[i1])
	var n2 := str(tbl_names[i2])
	var best := -1
	var bi1 := -1
	var bi2 := -1
	var az_best := false
	var bz_best := false
	var md := 1000000
	for li in tbl_smooth.size():
		var chain: Array = tbl_smooth[li]
		var a := -1
		var b := -1
		var az := false
		var bz := false
		for gi in chain.size():
			for td in chain[gi]:
				var nm := str(td.get("name", ""))
				if nm == n1:
					a = gi
					az = float(td.get("prob", 1.0)) <= 0.0
				if nm == n2:
					b = gi
					bz = float(td.get("prob", 1.0)) <= 0.0
		if a >= 0 and b >= 0 and a != b and absi(a - b) < md:
			md = absi(a - b)
			best = li
			bi1 = a
			bi2 = b
			az_best = az
			bz_best = bz
	if best < 0:
		return
	# donor: adjacent groups are compatible only if at least one has prob>0
	if absi(bi1 - bi2) == 1 and not (az_best and bz_best):
		return
	if bi1 - bi2 == 2:
		var ni := _tb_pick(best, int((bi1 + bi2) / 2), brng)
		if ni >= 0:
			tileblock[_t(x1, y1)] = ni
	elif bi2 - bi1 == 2:
		var ni2 := _tb_pick(best, int((bi1 + bi2) / 2), brng)
		if ni2 >= 0:
			tileblock[_t(x2, y2)] = ni2
	elif bi1 < bi2:
		var ni3 := _tb_pick(best, bi1 + 1, brng)
		if ni3 >= 0:
			tileblock[_t(x2, y2)] = ni3
	else:
		var ni4 := _tb_pick(best, bi2 + 1, brng)
		if ni4 >= 0:
			tileblock[_t(x1, y1)] = ni4

func _smooth_tilemap(brng: RandomNumberGenerator) -> void:
	for _pass in 3:
		for y in MAP_H:
			for x in range(0, MAP_W - 1):
				_tb_smooth_pair(x, y, x + 1, y, brng)
		for x in MAP_W:
			for y in range(0, MAP_H - 1):
				_tb_smooth_pair(x, y, x, y + 1, brng)

func _stamp_forest_borders(brng: RandomNumberGenerator) -> void:
	for y in MAP_H:
		for x in MAP_W:
			if int(terrain[_t(x, y)]) != 2:
				continue
			var n := 0
			for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var nx: int = x + d.x
				var ny: int = y + d.y
				if nx >= 0 and ny >= 0 and nx < MAP_W and ny < MAP_H and int(terrain[_t(nx, ny)]) == 2:
					n += 1
			if n == 1:
				tileblock[_t(x, y)] = _blk("grass5") if brng.randf() < 0.34 else _blk("rock9")

# stored height field (filled in _generate_map); bilinear read for smooth slopes
func height_at(p: Vector2) -> float:
	if height.size() != MAP_W * MAP_H:
		var t := tile_of(p)
		return _noise2(float(t.x) * 0.07, float(t.y) * 0.07) * 2.0
	var fx := clampf(p.x / TILE - 0.5, 0.0, float(MAP_W - 1) - 0.001)
	var fy := clampf(p.y / TILE - 0.5, 0.0, float(MAP_H - 1) - 0.001)
	var x0 := int(fx)
	var y0 := int(fy)
	var tx := fx - x0
	var ty := fy - y0
	var h00: float = height[_t(x0, y0)]
	var h10: float = height[_t(x0 + 1, y0)]
	var h01: float = height[_t(x0, y0 + 1)]
	var h11: float = height[_t(x0 + 1, y0 + 1)]
	return h00 + (h10 - h00) * tx + (h01 - h00) * ty + (h00 - h10 - h01 + h11) * tx * ty

func slope_to(a: Vector2, b: Vector2) -> float:
	var d := a.distance_to(b)
	if d < 0.001:
		return 0.0
	return absf(height_at(b) - height_at(a)) / d

const TARGET_TABLE := {
	"melee": {"melee": 1.0, "ranged": 0.6, "cavalry": 1.4, "artillery": 0.3, "building": 0.5},
	"ranged": {"melee": 1.4, "ranged": 1.0, "cavalry": 0.6, "artillery": 0.3, "building": 0.8},
	"cavalry": {"melee": 0.6, "ranged": 1.8, "cavalry": 1.0, "artillery": 1.8, "building": 0.4},
	"artillery": {"melee": 1.6, "ranged": 1.6, "cavalry": 0.4, "artillery": 1.0, "building": 1.6},
}

static func _hash2(ix: int, iy: int) -> float:
	# seed-folding: every random map gets its own meadow/mottle pattern
	var s := ix * 374761393 + iy * 668265263 + (int(Data.RANDOM_SEED) * 2246822519)
	s = (s ^ (s >> 13)) * 1274126177
	s = s ^ (s >> 16)
	return float(s & 65535) / 65535.0 * 2.0 - 1.0

func _noise2(x: float, y: float) -> float:
	var xi := int(floor(x))
	var yi := int(floor(y))
	var xf: float = x - floor(x)
	var yf: float = y - floor(y)
	var a: float = _hash2(xi, yi)
	var b: float = _hash2(xi + 1, yi)
	var c: float = _hash2(xi, yi + 1)
	var d: float = _hash2(xi + 1, yi + 1)
	var u: float = xf * xf * (3.0 - 2.0 * xf)
	var v: float = yf * yf * (3.0 - 2.0 * yf)
	return a + (b - a) * u + (c - a) * v + (a - b - c + d) * u * v

func set_blocked_tile(x: int, y: int, value: bool) -> void:
	if x >= 0 and y >= 0 and x < MAP_W and y < MAP_H:
		blocked[_t(x, y)] = 1 if value else 0

func _draw_road(a: Vector2, b: Vector2) -> void:
	var steps := int(a.distance_to(b) / TILE) + 1
	for i in steps:
		var p: Vector2 = a.lerp(b, float(i) / maxf(1.0, float(steps - 1)))
		p += Vector2(_noise2(p.x * 0.5, p.y * 0.5), _noise2(p.y * 0.5 + 9.0, p.x * 0.5)) * 1.2
		var t := tile_of(p)
		for dy in range(-1, 2):
			for dx in range(-1, 2):
				var xx := t.x + dx
				var yy := t.y + dy
				if xx >= 0 and yy >= 0 and xx < MAP_W and yy < MAP_H:
					var ri := _t(xx, yy)
					if terrain[ri] != 3:
						# a road is walkable: clear any cliff block it covers
						if terrain[ri] == 5:
							blocked[ri] = 0
						terrain[ri] = 1

func mine_deposits(kinds: Array) -> Array:
	var out: Array = []
	for n in res_nodes:
		if n.type in kinds and n.hits == 0 and n.max_hits == 0:
			out.append(n)
	return out

# ---------------------------------------------------------------- spawning
func spawn(sid: String, player: int, pos: Vector2, finished := true) -> Dictionary:
	var is_unit: bool = Data.UNITS.has(sid)
	var def: Dictionary = Data.UNITS[sid] if is_unit else Data.BUILDINGS[sid]
	var e := {
		"id": next_id, "kind": "unit" if is_unit else "building", "player": player, "sid": sid,
		"def": def, "pos": pos, "hp": def.hp, "max_hp": def.hp, "dead": false,
		"order": {"type": "none"}, "cooldown": 0.0, "carry": 0, "carry_type": "",
		"inside_of": 0, "moving": false, "finished": finished, "progress": def.build_time if finished else 0.0,
		"queue": [], "workers": 0, "capture_t": 0.0, "hold": false, "hold_fire": false, "face": 0.0,
		"morale": Data.MORALE_BASE, "routing": false, "deploy_t": 0.0, "stuck_t": 0.0, "hit_t": 0.0,
		"death_t": -1.0, "fire_t": -1.0, "acq_t": 0.0, "aur_off": false, "aur_dru": false,
	}
	if is_unit:
		e["hp"] = int(float(def.hp) * players[player].get("hp_mult", 1.0))
		e["max_hp"] = e["hp"]
		var pp: Dictionary = players[player]
		var kind := "unit"
		if def.get("artillery", false):
			e.max_hp = int(e.max_hp * float(pp.get("art_hp", 1.0)))
			e.hp = e.max_hp
	if not is_unit:
		var pp2: Dictionary = players[player]
		var kind2 := "building"
		if true:
			var add: int = int(pp2.get("fort_hp_add", 0)) if sid in ["wal", "tow", "gat"] else int(pp2.get("bld_hp_add", 0))
			e.max_hp += add
			e.hp += add
	if is_unit:
		e["shield"] = def.get("shield", 0)
		e["prot"] = def.prot
		e["cavalry"] = def.get("cavalry", "")
	else:
		e["shield"] = 0
	next_id += 1
	entities.append(e)
	by_id[e.id] = e
	players[player].entities.append(e.id)
	# keep grid/cached lists fresh for commands issued between ticks (selftest)
	var gc := Vector2i(int(e.pos.x / GRID_M), int(e.pos.y / GRID_M))
	if not grid.has(gc):
		grid[gc] = []
	grid[gc].append(e)
	if e.kind == "unit":
		live_units.append(e)
		if player >= 0 and player < 2:
			if str(e.sid) in ["officer", "officer18"]:
				officers[player].append(e)
			elif str(e.sid) in ["drummer", "drummer18"]:
				drummers[player].append(e)
			elif str(e.sid) in ["priest", "pope", "padre", "mullah"]:
				priests[player].append(e)
	else:
		live_blds.append(e)
	if e.kind == "building":
		set_blocked_circle(pos, def.radius, true)
		if sid == "gat":
			set_blocked_circle(pos, def.radius, false)
			gates.append(e)
		if finished:
			_on_building_finished(e)
		else:
			bld_dirty += 1
	players[player].score += def.get("score", 0)
	return e

func _on_building_finished(e: Dictionary) -> void:
	var p: Dictionary = players[e.player]
	if e.def.has("farm"):
		p.farm_cap += e.def.farm
	if e.sid.begins_with("mine_"):
		e["deposit_type"] = e.def.mine
		var node: Dictionary = {}
		var bd := 1e9
		for n in res_nodes:
			if n.type == e.def.mine and n.max_hits == 0:
				var dd: float = n.pos.distance_to(e.pos)
				if dd < bd:
					bd = dd
					node = n
		if not node.is_empty():
			e["deposit_node"] = node.id
			e["deposit_left"] = float(node.get("left", 0.0))
		else:
			e["deposit_left"] = deposits.get(e.def.mine, 0)
	if e.def.has("trains"):
		e["rally"] = e.pos + Vector2(0, e.def.radius + 2.0)
	bld_dirty += 1

func _start_positions() -> Array[Vector2]:
	# the two corners of the map where the players start
	return [Vector2(MAP_W * 0.125, MAP_H * 0.125) * TILE,
		Vector2(MAP_W * 0.875, MAP_H * 0.875) * TILE]

func _spawn_starts() -> void:
	# The donor reads startx/starty from the chosen mask's white markers;
	# spawning at fixed corners would leave the player far from its guaranteed
	# grove/fields/deposits (the exact "something is wrong" symptom).
	var starts: Array[Vector2] = map_starts if map_starts.size() >= 2 else _start_positions()
	var opt: Dictionary = Data.START_OPTIONS.get(Data.START_OPTION, {"army_mult": 0.0, "food": 0, "towers": 0, "cannons": 0})
	for i in 2:
		var c := starts[i]
		var cen := spawn("cen", i, c)
		players[i].res[0] += float(opt.get("food", 0))
		for k in Data.START_PEASANTS:
			var a := TAU * k / maxf(1.0, float(Data.START_PEASANTS))
			var pe := spawn("peasant", i, c + Vector2(cos(a), sin(a)) * (cen.def.radius + 1.5))
			pe.order = {"type": "none"}
		# starting option extras: towers / cannons near the town
		for t in int(opt.get("towers", 0)):
			spawn("tow", i, c + Vector2(6.0 + t * 3.0, -5.0))
		for cc in int(opt.get("cannons", 0)):
			spawn("cannon", i, c + Vector2(-6.0 - cc * 3.0, 5.0))
		var mult := float(opt.get("army_mult", 0.0))
		if battle_mode or mult > 0.0:
			var army: Dictionary = Data.BATTLE_ARMY
			var scale := 1.0 if battle_mode else mult
			var total := 0
			for sid in army:
				total += int(round(float(army[sid]) * scale))
			var ring := 0
			for sid in army:
				for k in int(round(float(army[sid]) * scale)):
					var a := TAU * ring / maxf(1.0, float(total))
					spawn(sid, i, c + Vector2(cos(a), sin(a)) * (6.0 + (ring % 4) * 1.5))
					ring += 1

# ---------------------------------------------------------------- helpers
func unit_count(player: int) -> int:
	var n := 0
	for e in live_units:
		if not e.dead and e.kind == "unit" and e.player == player:
			n += 1
	return n

func buildings_of(player: int, only_finished := true) -> Array:
	var out: Array = []
	for e in live_blds:
		if not e.dead and e.kind == "building" and e.player == player and (not only_finished or e.finished):
			out.append(e)
	return out

func units_of(player: int) -> Array:
	var out: Array = []
	for e in live_units:
		if not e.dead and e.kind == "unit" and e.player == player:
			out.append(e)
	return out

# Everything the player has selected (used by the HUD's buttons).
func get_selected() -> Array:
	var out: Array = []
	for e in entities:
		if e.get("selected", false) and not e.dead:
			out.append(e)
	return out

func _bad_id(e: Dictionary, key: String, tkey: String) -> int:
	if time_s - float(e.get(tkey, -9999.0)) < 120.0:
		return int(e.get(key, 0))
	return 0

func nearest_drop(e: Dictionary, res: String) -> Dictionary:
	var best: Dictionary = {}
	var best_d := 1e9
	var avoid := _bad_id(e, "bad_store", "bad_t")
	for b in buildings_of(e.player):
		if not b.finished:
			continue
		if int(b.id) == avoid:
			continue
		if Data.BUILDINGS[b.sid].get("stores", []).has(res):
			var d: float = b.pos.distance_to(e.pos)
			if d < best_d:
				best_d = d
				best = b
	return best

func nearest_res(pos: Vector2, type: String, max_r := 40.0, exclude_blocked := true, avoid := 0) -> Dictionary:
	var best: Dictionary = {}
	var best_d := max_r
	for n in res_nodes:
		if n.type != type or n.hits <= 0:
			continue
		if avoid != 0 and int(n.id) == avoid:
			continue
		var d: float = n.pos.distance_to(pos)
		if d < best_d:
			best_d = d
			best = n
	return best

func nearest_mine(pos: Vector2, res: String, player := -1) -> Dictionary:
	var best: Dictionary = {}
	var best_d := 1e9
	for b in buildings_of(0, false) + buildings_of(1, false):
		if player >= 0 and b.player != player:
			continue
		if b.sid == "mine_" + res and not b.dead:
			var has_deposit: bool = (b.finished and b.get("deposit_left", 0) > 0) or not b.finished
			if not has_deposit:
				continue
			var d: float = b.pos.distance_to(pos)
			if d < best_d:
				best_d = d
				best = b
	return best

func _mine_debug(res: String) -> String:
	var out: Array = []
	for b in buildings_of(0, false) + buildings_of(1, false):
		out.append("%s/%s fin=%s dep=%s dead=%s" % [b.sid, b.player, b.finished, b.get("deposit_left", -1), b.dead])
	return "[" + ", ".join(out) + "]"

func enemies_in_radius(pos: Vector2, player: int, r: float, military_only := true) -> Dictionary:
	var best: Dictionary = {}
	var best_d := r
	for e in grid_query(pos, r):
		if e.dead or e.player == player:
			continue
		if military_only and (e.kind == "building" or e.sid == "peasant"):
			continue
		var d: float = e.pos.distance_to(pos)
		if d < best_d:
			best_d = d
			best = e
	return best

func _kind_class(e: Dictionary) -> String:
	if e.kind == "building":
		return "building"
	if e.def.get("artillery", false):
		return "artillery"
	if e.def.get("cavalry", "") != "":
		return "cavalry"
	var w := weapon_of(e)
	if w.is_empty():
		return "melee"
	if str(w.kind) in ["bullet", "arrow", "firearrow", "cannister"]:
		return "ranged"
	return "melee"

func _target_score(a: Dictionary, t: Dictionary) -> float:
	var ac := _kind_class(a)
	var tc := _kind_class(t)
	var row: Dictionary = TARGET_TABLE.get(ac, {})
	return float(row.get(tc, 1.0))

func enemies_preferred(pos: Vector2, player: int, r: float, a: Dictionary) -> Dictionary:
	var best: Dictionary = {}
	var best_s := -1.0
	for e in grid_query(pos, r):
		if e.dead or e.player == player or e.kind == "building" or e.sid == "peasant":
			continue
		var d: float = e.pos.distance_to(pos)
		if d > r:
			continue
		var s: float = _target_score(a, e) * (1.0 - 0.3 * d / maxf(1.0, r))
		if s > best_s:
			best_s = s
			best = e
	return best

func has_weapon(e: Dictionary) -> bool:
	return e.def.has("weapons") and e.def.weapons.size() > 0

func weapon_of(e: Dictionary) -> Dictionary:
	return e.def.weapons[0] if has_weapon(e) else {}

func pay_cost(player: int, cost: Dictionary) -> bool:
	if Data.can_pay(players[player].res, cost):
		Data.pay(players[player].res, cost)
		return true
	return false

func post_event(type: String, pos: Vector2, kind := "", extra := "") -> void:
	if events.size() < 256:
		events.append({"type": type, "pos": pos, "kind": kind, "extra": extra})

func say(text: String) -> void:
	message.emit(text)

var reveal_requests: Array = []
func game_reveal(pos: Vector2, r: float) -> void:
	reveal_requests.append({"pos": pos, "r": r})

# ---------------------------------------------------------------- commands
func cmd_move(e: Dictionary, pos: Vector2) -> void:
	if e.kind != "unit" or e.dead:
		return
	_leave_building(e)
	e.order = {"type": "move", "pos": pos}
	e.move_target = pos
	e.moving = true
	# officer leads: the squad marches in formation behind him
	_squad_order_members(e.id, pos, false)

func cmd_attack(e: Dictionary, target: Dictionary) -> void:
	if e.kind != "unit" or e.dead or target.dead:
		return
	_leave_building(e)
	e.order = {"type": "attack", "target": target.id}
	e.moving = true

func cmd_attack_move(e: Dictionary, pos: Vector2) -> void:
	if e.kind != "unit" or e.dead:
		return
	_leave_building(e)
	e.order = {"type": "attackmove", "pos": pos}
	e.moving = true
	_squad_order_members(e.id, pos, true)

func cmd_gather(e: Dictionary, res_node: Dictionary) -> void:
	if e.kind != "unit" or e.dead or e.sid != "peasant":
		return
	_leave_building(e)
	# a load of something else is dropped when the peasant changes its mind
	e.carry = 0
	e.carry_type = ""
	if res_node.type in ["gold", "iron", "coal"]:
		var mine := nearest_mine(e.pos, res_node.type)
		if mine.is_empty():
			say("No %s mine - build one on a deposit." % res_node.type)
			return
		e.order = {"type": "gather", "res": res_node.type, "node": mine.id}
	else:
		e.order = {"type": "gather", "res": res_node.type, "node": res_node.id}
	e.moving = true

func cmd_resow(e: Dictionary, node: Dictionary) -> void:
	if e.dead or str(e.sid) != "peasant" or node.is_empty() or str(node.type) != "food":
		return
	if node.hits > 0:
		cmd_gather(e, node)
		return
	e.order = {"type": "resow", "node": node.id}

func cmd_build(e: Dictionary, site: Dictionary) -> void:
	if e.kind != "unit" or e.dead or e.sid != "peasant":
		return
	_leave_building(e)
	e.order = {"type": "build", "target": site.id}
	e.moving = true

func cmd_stand_ground(e: Dictionary) -> void:
	e["hold"] = true
	e.order = {"type": "none"}
	e.moving = false

func cmd_no_stand_ground(e: Dictionary) -> void:
	e["hold"] = false

func cmd_hold_fire(e: Dictionary, on: bool) -> void:
	if e.kind == "unit":
		e["hold_fire"] = on

func cmd_engage(e: Dictionary) -> void:
	if e.kind == "unit":
		e["hold"] = false
		e["hold_fire"] = false

func cmd_stop(e: Dictionary) -> void:
	e.order = {"type": "none"}
	e.moving = false
	e.move_target = null
	e["routing"] = false

func cmd_guard(e: Dictionary, target: Dictionary) -> void:
	if e.kind != "unit" or e.dead or target.get("dead", false):
		return
	_leave_building(e)
	e.order = {"type": "guard", "target": target.id}
	e.moving = true

func cmd_patrol(e: Dictionary, a: Vector2, b: Vector2) -> void:
	if e.kind != "unit" or e.dead:
		return
	_leave_building(e)
	e.order = {"type": "patrol", "a": a, "b": b, "leg": 0}
	e.moving = true

func cmd_attack_ground(e: Dictionary, pos: Vector2) -> void:
	if e.dead or not e.def.get("artillery", false):
		return
	e.order = {"type": "attackground", "pos": pos}

func cmd_enter(e: Dictionary, b: Dictionary) -> void:
	if e.dead or e.kind != "unit" or e.player != b.player or b.dead or not b.finished:
		return
	if not str(b.sid) in ["tow", "cen"]:
		return
	if e.def.get("artillery", false) or e.def.get("cavalry", "") != "":
		return
	if int(b.get("garrison", 0)) >= 10:
		return
	_leave_building(e)
	e.inside_of = b.id
	e.order = {"type": "none"}
	e["hidden"] = true
	b["garrison"] = int(b.get("garrison", 0)) + 1

func cmd_unload(b: Dictionary) -> void:
	if b.dead or b.kind != "building":
		return
	var k := 0
	for e in live_units:
		if e.dead or e.inside_of != b.id or not bool(e.get("hidden", false)):
			continue
		e.inside_of = 0
		e["hidden"] = false
		e.pos = b.pos + Vector2(cos(k * 2.4), sin(k * 2.4)) * (b.def.radius + 1.0)
		e.order = {"type": "none"}
		k += 1
	b["garrison"] = 0

# Squads: officer (slot 0) + drummer (slot 1) + soldiers, like squad.script.
# A squad is a sticky group: orders to the officer fan out to the members in
# the squad's formation (line / column / square from formations.cfg).
func squad_of_unit(uid: int) -> Dictionary:
	for sid in squads:
		var s: Dictionary = squads[sid]
		if int(s.officer) == uid or int(s.get("drummer", 0)) == uid or uid in s.members:
			return s
	return {}

# Formation sizes from the wiki (infantry 15/36/72/120/196/400, cavalry
# 40/90/160): the label is the largest fitting size, else 0. Small bands and
# drummer-less mobs still form and fight, just without the formation bonus.
func _squad_cavalry(s: Dictionary) -> bool:
	for uid in s.members:
		var u: Dictionary = by_id.get(uid, {})
		if not u.is_empty():
			return u.def.get("cavalry", "") != ""
	return false

func _squad_label(s: Dictionary) -> int:
	if s.is_empty():
		return 0
	var n: int = s.members.size()
	var sizes := [40, 90, 160] if _squad_cavalry(s) else [15, 36, 72, 120, 196, 400]
	var label := 0
	for z in sizes:
		if n >= z:
			label = z
	return label

func _formation_atk(e: Dictionary, kind: String) -> int:
	var s := squad_of_unit(int(e.id))
	if _squad_label(s) == 0:
		return 0
	var melee := kind == "pike" or kind == "sword"
	var cav := _squad_cavalry(s)
	if not cav and int(s.get("drummer", 0)) == 0:
		return 0
	# wiki: heavy cavalry formations give +1 attack and defense
	if cav:
		if bool(e.get("hold", false)):
			return 5 if melee else 2
		return 1
	if bool(e.get("hold", false)):
		return 9 if melee else 2
	return 2

func _formation_def(t: Dictionary) -> int:
	var s := squad_of_unit(int(t.id))
	if _squad_label(s) == 0:
		return 0
	var cav := _squad_cavalry(s)
	if not cav and int(s.get("drummer", 0)) == 0:
		return 0
	if bool(t.get("hold", false)):
		return 4 if cav else 9
	return 1 if cav else 3

func _pick_weapon(e: Dictionary, d: float) -> Dictionary:
	# 18th-century bayonet: muskets and grenades fight back up close
	var ws: Array = e.def.get("weapons", [])
	if ws.is_empty():
		return {}
	if ws.size() > 1 and d < float(ws[0].min):
		return ws[1]
	return ws[0]

# Replenish: loose same-type units near the officer join his squad, up to its
# formation label (wiki: move fresh troops to the officer and absorb them).
func cmd_replenish(off: Dictionary) -> int:
	var s := squad_of_unit(int(off.id))
	if s.is_empty() or int(s.officer) != int(off.id):
		return 0
	var label := _squad_label(s)
	var want_sid := ""
	for uid in s.members:
		var m: Dictionary = by_id.get(uid, {})
		if not m.is_empty():
			want_sid = str(m.sid)
			break
	if want_sid == "":
		return 0
	var need: int = maxi(label, int(s.get("target", 0))) - int(s.members.size())
	if need <= 0:
		return 0
	var got := 0
	for u in entities:
		if got >= need or u.dead or u.kind != "unit" or u.player != off.player:
			continue
		if str(u.sid) != want_sid or u.id == off.id:
			continue
		if not squad_of_unit(int(u.id)).is_empty():
			continue
		if u.pos.distance_to(off.pos) > 6.0:
			continue
		u["squad"] = int(s.squad_id)
		s.members.append(u.id)
		got += 1
	if got > 0:
		say("Squad replenished (+%d)." % got)
	return got

func cmd_form_size(off: Dictionary, size: int) -> void:
	if off.dead or not str(off.sid) in ["officer", "officer18"]:
		return
	var loose: Array = []
	for u in entities:
		if u.dead or u.kind != "unit" or u.player != off.player or u.id == off.id:
			continue
		if u.sid == "peasant" or u.def.get("support", false):
			continue
		if not squad_of_unit(u.id).is_empty():
			continue
		if u.pos.distance_to(off.pos) <= 12.0:
			loose.append(u)
	if loose.is_empty():
		say("No loose troops near the officer.")
		return
	loose.sort_custom(func(x, y): return x.pos.distance_to(off.pos) < y.pos.distance_to(off.pos))
	var want: String = str(loose[0].sid)
	var pick: Array = []
	for u in loose:
		if str(u.sid) == want and pick.size() < size:
			pick.append(u)
	var dru: Dictionary = {}
	for u in entities:
		if not u.dead and u.player == off.player and str(u.sid) in ["drummer", "drummer18"] and u.pos.distance_to(off.pos) <= 12.0:
			dru = u
			break
	var members: Array = [off]
	if not dru.is_empty():
		members.append(dru)
	members += pick
	squad_form(members)

func squads_of(player: int) -> Array:
	var out: Array = []
	for sid in squads:
		if int(squads[sid].player) == player:
			out.append(squads[sid])
	return out

func squad_form(members: Array) -> Dictionary:
	# members: Array of unit dicts, same player, first officer leads.
	var off := 0
	var dru := 0
	var ids: Array = []
	var pl := -1
	for u in members:
		if u.is_empty() or u.dead or u.kind != "unit":
			continue
		if pl < 0:
			pl = u.player
		if u.player != pl:
			continue
		if u.sid == "peasant" or u.def.get("support", false) and u.sid != "drummer":
			continue
		if (u.sid == "officer" or u.sid == "officer18") and off == 0:
			off = u.id
		elif u.sid == "drummer" and dru == 0:
			dru = u.id
		else:
			ids.append(u.id)
		if ids.size() + (1 if off else 0) + (1 if dru else 0) >= Data.SQUAD_MAX:
			break
	if off == 0:
		say("A squad needs an officer - train one in the barracks.")
		return {}
	# leave old squads
	for uid in [off, dru] + ids:
		if uid == 0:
			continue
		var old := squad_of_unit(uid)
		if not old.is_empty():
			squad_remove(old.squad_id, uid)
	var sid := next_squad
	next_squad += 1
	var s := {"squad_id": sid, "officer": off, "drummer": dru, "members": ids,
		"formation": "line", "player": pl}
	s["target"] = maxi(_squad_label(s), ids.size())
	if not ids.is_empty():
		var first: Dictionary = by_id.get(ids[0], {})
		if not first.is_empty() and first.def.get("cavalry", "") != "" and Data.FORMATIONS.has("wedge"):
			s.formation = "wedge"
	squads[sid] = s
	for uid in [off, dru] + ids:
		if uid == 0:
			continue
		var u: Dictionary = by_id.get(uid, {})
		if not u.is_empty():
			u["squad"] = sid
	post_event("squad", by_id[off].pos, "line")
	say("Squad formed (%d soldiers)." % ids.size())
	return s

func squad_remove(sid: int, uid: int) -> void:
	var s: Dictionary = squads.get(sid, {})
	if s.is_empty():
		return
	if int(s.officer) == uid:
		s.officer = 0
	if int(s.get("drummer", 0)) == uid:
		s["drummer"] = 0
	s.members.erase(uid)
	var u: Dictionary = by_id.get(uid, {})
	if not u.is_empty():
		u.erase("squad")

func squad_disband(sid: int) -> void:
	var s: Dictionary = squads.get(sid, {})
	if s.is_empty():
		return
	for uid in [int(s.officer), int(s.get("drummer", 0))] + s.members:
		if uid == 0:
			continue
		var u: Dictionary = by_id.get(uid, {})
		if not u.is_empty():
			u.erase("squad")
	squads.erase(sid)
	say("Squad disbanded.")

func squad_set_formation(sid: int, form: String) -> void:
	var s: Dictionary = squads.get(sid, {})
	if s.is_empty() or not Data.FORMATIONS.has(form):
		return
	s.formation = form
	post_event("squad", by_id.get(int(s.officer), {"pos": Vector2.ZERO}).pos, form)

func _squad_order_members(off_id: int, dest: Vector2, attack: bool) -> void:
	for sid in squads:
		var s: Dictionary = squads[sid]
		if int(s.officer) != off_id:
			continue
		var off: Dictionary = by_id.get(off_id, {})
		if not off.is_empty():
			s["face"] = (dest - off.pos).angle()
		var all: Array = []
		for uid in s.members:
			var u: Dictionary = by_id.get(uid, {})
			if not u.is_empty() and not u.dead:
				all.append(u)
		var du: Dictionary = by_id.get(int(s.get("drummer", 0)), {})
		if not du.is_empty() and not du.dead:
			all.append(du)
		var targets := formation_targets(all, dest, str(s.get("formation", "line")))
		var fi := 0
		for u in all:
			var d: Vector2 = targets[fi] if fi < targets.size() else dest
			fi += 1
			_leave_building(u)
			if attack:
				u.order = {"type": "attackmove", "pos": d}
			else:
				u.order = {"type": "move", "pos": d}
			u.move_target = d
			u.moving = true

# Shared box/line/column/square layout for group orders.
func formation_targets(sel: Array, center: Vector2, formation := "none") -> Array:
	var n := sel.size()
	if n == 0:
		return []
	if n == 1:
		return [center]
	var fa := 0.0
	if not sel.is_empty():
		var s0: Dictionary = squad_of_unit(int(sel[0].id))
		if not s0.is_empty():
			fa = float(s0.get("face", 0.0))
	var f: Dictionary = Data.FORMATIONS.get(formation, {"cols_mult": 1.0, "rows_mult": 1.0})
	var cols := maxi(1, int(ceil(sqrt(float(n)) * float(f.get("cols_mult", 1.0)))))
	var spacing := float(Data.FORMATION_SPACING)
	for e in sel:
		spacing = maxf(spacing, e.def.radius * 2.0 + 0.5)
	# artillery batteries spread out (wiki: spaced line vs enemy guns)
	var all_art := not sel.is_empty()
	for e in sel:
		if not bool(e.def.get("artillery", false)):
			all_art = false
			break
	if all_art:
		spacing *= 3.0
	var out: Array = []
	var rows := int(ceil(float(n) / float(cols)))
	var hollow: bool = bool(f.get("hollow", false))
	var cx := (float(cols) - 1.0) * 0.5
	var cy := (float(rows) - 1.0) * 0.5
	var idx := 0
	for r in rows:
		for c in cols:
			if idx >= n:
				break
			if hollow and r > 0 and r < rows - 1 and c > 0 and c < cols - 1:
				continue  # square: ring only, officers inside
			var off := Vector2((float(c) - cx) * spacing / maxf(0.6, float(f.get("cols_mult", 1.0)) + 0.4),
				(float(r) - cy) * spacing / maxf(0.6, float(f.get("rows_mult", 1.0)) + 0.4))
			var p := center + off.rotated(fa)
			if not in_bounds(p):
				p = center
			out.append(p)
			idx += 1
			if idx >= n:
				break
	while out.size() < n:
		var k := out.size()
		var ang := float(k) * 2.399963
		var pad := center + Vector2(cos(ang), sin(ang)) * spacing * 0.5
		out.append(pad if in_bounds(pad) else center)
	return out

# Research an upgrade at a finished blacksmith/academy. One at a time per
# building; effects apply when the timer finishes (see _tick_building).
func research(player: int, building: Dictionary, uid: String) -> bool:
	if building.dead or not building.finished or building.player != player:
		return false
	var u: Dictionary = Data.UPGRADES.get(uid, {})
	if u.is_empty() or u.building != building.sid:
		return false
	# Ukraine/Turkey/Algeria cannot advance to the 18th century (wiki nations)
	if uid == "cen_18c" or uid == "art_multi1":
		var nnat := str(Data.PLAYER_NATIONS[player]) if player >= 0 and player < Data.PLAYER_NATIONS.size() else ""
		if bool(Data.NATIONS.get(nnat, {}).get("no18c", false)):
			if player == 0:
				say("This nation cannot advance to the 18th century.")
			return false
	if uid == "cen_18c":
		var need := ["hou", "bar", "sta", "bla", "aca", "art", "sto", "mil", "mar"]
		for ns in need:
			var have := false
			for b in buildings_of(player):
				if b.sid == ns:
					have = true
					break
			if not have:
				if player == 0:
					say("Build every building type before advancing to the 18th century.")
				return false
	var per_bld: bool = str(uid).begins_with("mine_") or str(uid).begins_with("tow_rof")
	if (not per_bld and players[player].upgrades.has(uid)) or building.get("research") != null:
		return false
	if per_bld and building.get("done_ups", []).has(uid):
		return false
	if not pay_cost(player, u.cost):
		say("Not enough resources for %s." % u.name)
		return false
	building["research"] = {"uid": uid, "t": float(u.time)}
	post_event("research", building.pos, uid)
	return true

func apply_upgrade(player: int, uid: String) -> void:
	var u: Dictionary = Data.UPGRADES.get(uid, {})
	if u.is_empty():
		return
	var p: Dictionary = players[player]
	if p.upgrades.has(uid):
		return
	p.upgrades.append(uid)
	var eff: Dictionary = u.get("effect", {})
	for k in eff.get("damage_mult", {}):
		p.damage_mult[k] = float(p.damage_mult.get(k, 1.0)) * float(eff.damage_mult[k])
	for k in eff.get("gather_mult", {}):
		p.gather_mult[k] = float(p.gather_mult.get(k, 1.0)) * float(eff.gather_mult[k])
	if eff.has("mine_mult"):
		p.mine_mult = float(p.get("mine_mult", 1.0)) * float(eff.mine_mult)
	p.prot_bonus = int(p.get("prot_bonus", 0)) + int(eff.get("prot_bonus", 0))
	if eff.has("hp_mult"):
		p.hp_mult = float(p.get("hp_mult", 1.0)) * float(eff.hp_mult)
		for e in entities:
			if not e.dead and e.player == player and e.kind == "unit":
				var add := int(float(e.def.hp) * (float(eff.hp_mult) - 1.0))
				e.max_hp += add
				e.hp += add
	if eff.has("unlock18c"):
		p["has18c"] = true
	if eff.has("field_cap"):
		p.field_cap = float(p.get("field_cap", 1.0)) * float(eff.field_cap)
		for n in res_nodes:
			if n.type == "food" and n.max_hits > 0:
				n.max_hits = int(n.max_hits * float(eff.field_cap))
				n.hits = int(n.hits * float(eff.field_cap))
	if eff.has("build_mult"):
		p.build_mult = float(p.get("build_mult", 1.0)) * float(eff.build_mult)
	if eff.has("bld_hp_add"):
		for e in entities:
			if not e.dead and e.kind == "building" and e.player == player and not e.sid in ["wal", "tow"]:
				e.max_hp += int(eff.bld_hp_add); e.hp += int(eff.bld_hp_add)
		p.bld_hp_add = int(p.get("bld_hp_add", 0)) + int(eff.bld_hp_add)
	if eff.has("fort_hp_add"):
		for e in entities:
			if not e.dead and e.kind == "building" and e.player == player and e.sid in ["wal", "tow"]:
				e.max_hp += int(eff.fort_hp_add); e.hp += int(eff.fort_hp_add)
		p.fort_hp_add = int(p.get("fort_hp_add", 0)) + int(eff.fort_hp_add)
	if eff.has("art_range"):
		p.art_range = float(p.get("art_range", 1.0)) * float(eff.art_range)
	if eff.has("art_hp"):
		p.art_hp = float(p.get("art_hp", 1.0)) * float(eff.art_hp)
		for au in entities:
			if not au.dead and au.player == player and au.def.get("artillery", false):
				au.max_hp = int(au.max_hp * float(eff.art_hp)); au.hp = au.max_hp
	if eff.has("art_acc"):
		p.art_acc = float(p.get("art_acc", 1.0)) * float(eff.art_acc)
	if eff.has("reveal_deposits"):
		for n in res_nodes:
			if n.max_hits == 0:
				game_reveal(n.pos, 6.0)
	if eff.has("reveal_map"):
		game_reveal(Vector2(Data.MAP_W, Data.MAP_H), 1e9)
	if eff.has("unlock_multi"):
		p["has_multi"] = true
	post_event("upgraded", Vector2.ZERO, uid)
	say("%s researched %s." % [p.name, u.name])

func apply_upgrade_to_building(b: Dictionary, uid: String) -> void:
	var eff: Dictionary = Data.UPGRADES[uid].get("effect", {})
	if eff.has("mine_slots"):
		b["slots"] = int(b.get("slots", b.def.get("slots", 5))) + int(eff.mine_slots)
	if eff.has("tower_rof"):
		b["rof_mult"] = float(b.get("rof_mult", 1.0)) * float(eff.tower_rof)
	post_event("upgraded", b.pos, uid)

# Market barter: give 100 of one resource, receive rate-adjusted amount of
# another. The rate drifts down as you dump one resource (video-visible
# exchange with commission).
func trade(player: int, give: String, want: String, amount := 100.0) -> bool:
	if not Data.BUILDINGS.has("mar"):
		return false
	var has_market := false
	for b in buildings_of(player):
		if b.sid == "mar" and b.finished:
			has_market = true
	if not has_market:
		say("Build a market to trade.")
		return false
	var gi: int = Data.RES_NAMES.find(give)
	var wi: int = Data.RES_NAMES.find(want)
	if gi < 0 or wi < 0 or give == want:
		return false
	var p: Dictionary = players[player]
	if float(p.res[gi]) < amount:
		say("Not enough %s to trade." % give)
		return false
	var rate: float = float(p.get("market_rate", Data.MARKET_RATE))
	var got := amount * rate
	p.res[gi] = float(p.res[gi]) - amount
	p.res[wi] = float(p.res[wi]) + got
	p.market_rate = maxf(0.35, rate - Data.MARKET_DRIFT * amount / 100.0)
	stats.gathered["trade"] = int(stats.gathered.get("trade", 0)) + int(got)
	post_event("trade", Vector2.ZERO, give + ">" + want)
	return true

# Officer aura: nearby officer raises damage, drummer raises speed/morale.
func officer_near(pos: Vector2, player: int) -> bool:
	if player < 0 or player > 1:
		return false
	for e in officers[player]:
		if e.dead:
			continue
		if e.pos.distance_to(pos) <= Data.MORALE_OFFICER_RADIUS:
			return true
	return false

func drummer_near(pos: Vector2, player: int) -> bool:
	if player < 0 or player > 1:
		return false
	for e in drummers[player]:
		if e.dead:
			continue
		if e.pos.distance_to(pos) <= Data.MORALE_DRUMMER_RADIUS:
			return true
	return false

func effective_speed(e: Dictionary) -> float:
	var s: float = e.def.speed
	if bool(e.get("aur_dru", false)):
		s *= 1.0 + Data.DRUMMER_SPEED_BONUS
	if e.get("routing", false):
		s *= 1.35  # routing troops run
	return s

func effective_damage(player: int, kind: String, pos: Vector2) -> float:
	var m: float = float(players[player].damage_mult.get(kind, 1.0))
	if officer_near(pos, player):
		m *= 1.0 + Data.OFFICER_DAMAGE_BONUS
	return m

func can_place(player: int, sid: String, pos: Vector2) -> Dictionary:
	# Single source of truth for build legality. Returns {ok, reason}.
	var def: Dictionary = Data.BUILDINGS[sid]
	if not in_bounds(pos):
		return {"ok": false, "reason": "Outside the map."}
	if sid.begins_with("mine_"):
		var dep := false
		for n in res_nodes:
			if n.type == def.mine and n.max_hits == 0 and n.pos.distance_to(pos) < 4.0:
				dep = true
				break
		if not dep:
			return {"ok": false, "reason": "Mines must be built on a %s deposit." % def.mine}
		return {"ok": true, "reason": ""}
	var t := tile_of(pos)
	var terr: int = terrain[_t(t.x, t.y)]
	if terr == 3:
		return {"ok": false, "reason": "Too wet - cannot build on water."}
	# footprint vs resources (stone fields, trees, groves; deco/stumps excluded)
	for n in res_nodes:
		if str(n.get("type", "")) in ["bush", "stump"]:
			continue
		if int(n.get("hits", 0)) <= 0 and int(n.get("max_hits", 0)) != 0:
			continue
		var rr: float = float(def.radius) + float(n.get("radius", 0.5))
		if n.pos.distance_to(pos) < rr:
			match str(n.get("type", "")):
				"wood":
					return {"ok": false, "reason": "Trees in the way - clear them first."}
				"stone":
					return {"ok": false, "reason": "Stone field - pick open dirt."}
				"food":
					return {"ok": false, "reason": "Cornfield - pick open dirt."}
				_:
					return {"ok": false, "reason": "Deposit - build the right mine here."}
	# footprint vs live buildings (own + enemy + unfinished sites)
	for b in live_blds:
		if b.dead:
			continue
		var rr2: float = float(def.radius) + float(b.def.radius) + 0.3
		if b.pos.distance_to(pos) < rr2:
			if (sid == "wal" or sid == "gat") and str(b.sid) in ["wal", "gat"] and b.player == player:
				continue
			return {"ok": false, "reason": "Too close to %s." % str(b.sid)}
	if is_blocked(pos) and not (sid in ["wal", "gat"]):
		return {"ok": false, "reason": "Blocked ground (rock/forest/water)."}
	return {"ok": true, "reason": ""}

func place_building(player: int, sid: String, pos: Vector2, send := true) -> Dictionary:
	var def: Dictionary = Data.BUILDINGS[sid]
	if sid == "bar18" and not bool(players[player].get("has18c", false)):
		say("Research the 18th century at the Town Hall first.")
		return {}
	if sid == "multicannon" and not bool(players[player].get("has_multi", false)):
		say("Research the multi-barrelled cannon at the artillery depot first.")
		return {}
	var chk := can_place(player, sid, pos)
	if not bool(chk.get("ok", false)):
		if player == 0:
			say(str(chk.get("reason", "Cannot build here.")))
		return {}
	if sid.begins_with("mine_"):
		for n in res_nodes:
			if n.type == def.mine and n.max_hits == 0 and n.pos.distance_to(pos) < 4.0:
				pos = n.pos
				break
	var mult := 1.0
	if not sid.begins_with("mine_") and sid != "wal" and sid != "gat":
		var cnt := 0
		for b in buildings_of(player):
			if b.sid == sid:
				cnt += 1
		mult = pow(3.0, cnt) if sid == "cen" else pow(1.5, cnt)
	var esc_cost := {}
	for k in def.cost:
		esc_cost[k] = int(round(float(def.cost[k]) * mult))
	if not pay_cost(player, esc_cost):
		say("Not enough resources.")
		return {}
	var b := spawn(sid, player, pos, false)
	b.hp = maxi(1, int(def.hp * 0.25))
	post_event("construct", pos, sid)
	if not send:
		return b
	# send nearby peasants to build (the original allows up to 30 builders,
	# dmscript.global:159; the port sends 8 at a time)
	var idle: Array = []
	var busy: Array = []
	for u in units_of(player):
		if u.sid != "peasant":
			continue
		if u.order.type == "none":
			idle.append(u)
		elif u.order.type == "gather":
			busy.append(u)
	var sent := 0
	for u in idle + busy:
		if sent >= Data.MAX_BUILDERS_SENT:
			break
		cmd_build(u, b)
		sent += 1
	return b

func train_unit(player: int, building: Dictionary, sid: String) -> bool:
	if not building.finished:
		return false
	var nat := str(Data.PLAYER_NATIONS[player]) if player >= 0 and player < Data.PLAYER_NATIONS.size() else ""
	var rsid := Data.resolve_sid(nat, sid)
	if not building.def.get("trains", []).has(sid) and not building.def.get("trains", []).has(rsid):
		return false
	# officers and drummers need a finished academy (wiki: formation gate)
	if rsid in ["officer", "officer18", "drummer", "drummer18"]:
		var aca_ok := false
		for b in buildings_of(player):
			if b.sid == "aca":
				aca_ok = true
				break
		if not aca_ok:
			if player == 0:
				say("Build an academy first (officers need it).")
			return false
	if building.queue.size() >= Data.BUILD_QUEUE_LIMIT:
		return false
	if unit_count(player) + queue_count(player) >= players[player].farm_cap:
		say("Need more houses — unit limit reached.")
		return false
	var cost: Dictionary = Data.UNITS[rsid].price
	if not pay_cost(player, cost):
		say("Not enough resources for %s." % rsid)
		return false
	building.queue.append({"sid": rsid, "t": Data.UNITS[rsid].build_time})
	return true

func queue_count(player: int) -> int:
	var n := 0
	for b in buildings_of(player):
		n += b.queue.size()
	return n

func _leave_building(e: Dictionary) -> void:
	if e.inside_of != 0:
		var m: Dictionary = by_id.get(e.inside_of, {})
		if not m.is_empty():
			m.workers = maxi(0, m.workers - 1)
		e.inside_of = 0

# ---------------------------------------------------------------- tick
func tick(dt: float) -> void:
	if paused or winner != -1:
		return
	dt = minf(dt, TICK_MAX)
	time_s += dt
	ai_cheat_t += dt
	if ai_cheat_t >= 1.0 and Data.AI_DIFFICULTY == "hard":
		ai_cheat_t = 0.0
		players[1].res[0] += 1.5
		players[1].res[1] += 1.5
		players[1].res[2] += 1.5
		players[1].res[3] += 0.8
		players[1].res[4] += 0.8
		players[1].res[5] += 0.8
	_grid_rebuild()
	compact_t += dt
	if compact_t >= 5.0:
		compact_t = 0.0
		_compact()
	for e in entities:
		if e.dead:
			continue
		if e.kind == "unit":
			_tick_unit(e, dt)
		else:
			_tick_building(e, dt)
	_tick_projectiles(dt)
	for c in corpses:
		c.t += dt
	for i in range(corpses.size() - 1, -1, -1):
		if float(corpses[i].t) >= float(corpses[i].life):
			corpses.remove_at(i)
	for rb in rubble:
		rb.t += dt
	for i in range(rubble.size() - 1, -1, -1):
		if float(rubble[i].t) >= float(rubble[i].life):
			rubble.remove_at(i)
	for n in res_nodes:
		if str(n.get("type", "")) == "stump":
			n["stump_t"] = float(n.get("stump_t", 0.0)) + dt
	for i in range(res_nodes.size() - 1, -1, -1):
		var nn: Dictionary = res_nodes[i]
		if str(nn.get("type", "")) == "stump" and float(nn.get("stump_t", 0.0)) > 60.0:
			set_blocked_circle(nn.pos, nn.radius, false)
			by_id.erase(nn.id)
			res_nodes.remove_at(i)
			res_dirty += 1
	_separate_units()
	_tick_cleanup(dt)
	_tick_upkeep(dt)
	_check_victory()

# Like the original, units never stand inside each other: every tick each
# pair is pushed apart until the gap is r1 + r2 + personal space, and units
# are pushed out of building footprints. Two relaxation passes, spatial
# hash so 200+ units stay cheap (no O(n^2) stall on any platform).
func _separate_units() -> void:
	var cell := 2.0
	var lgrid: Dictionary = {}
	var units: Array = []
	for e in entities:
		if e.dead or e.kind != "unit":
			continue
		if e.inside_of != 0:
			continue
		units.append(e)
		var cx := int(floor(e.pos.x / cell))
		var cy := int(floor(e.pos.y / cell))
		var key := Vector2i(cx, cy)
		if not lgrid.has(key):
			lgrid[key] = []
		lgrid[key].append(e)
	if units.is_empty():
		return
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
						# order the pair once (avoid double push jitter)
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
							if in_bounds(np_e) and not is_blocked(np_e):
								e.pos = np_e
							if in_bounds(np_o) and not is_blocked(np_o):
								o.pos = np_o
		# buildings push units out (cheap: only nearby buildings per unit)
		for e in units:
			if e.dead:
				continue
			for b in grid_query(e.pos, 6.0):
				if b.dead or b.kind != "building":
					continue
				var rr: float = e.def.radius + b.def.radius + 0.15
				var delta: Vector2 = e.pos - b.pos
				var d := delta.length()
				if d < rr and d > 0.001:
					var np: Vector2 = b.pos + delta / d * rr
					if in_bounds(np) and not is_blocked(np):
						# blocked map says building tiles are blocked; allow the
						# ring right outside the footprint (unblock-tested below)
						e.pos = np
					else:
						# try sliding around the footprint
						var side := Vector2(-delta.y, delta.x).normalized()
						var alt: Vector2 = e.pos + side * 0.3
						if in_bounds(alt) and not is_blocked(alt):
							e.pos = alt

func _tick_upkeep(dt: float) -> void:
	# Upkeep, ported from player.script _player_ProcessResourceConsume
	# (speed 20000, gc_time_to_frames = 32): each unit eats consume/625 units
	# of food (or gold) per second. Video pass: prolonged famine first shows
	# the warning, then the original starves the army - slow HP drain after a
	# grace period so a test never dies instantly (estimated).
	for pi in 2:
		var p: Dictionary = players[pi]
		p["famine_msg_t"] = maxf(0.0, float(p.get("famine_msg_t", 0.0)) - dt)
		var eat := {"food": 0.0, "gold": 0.0, "stone": 0.0}
		for e in live_units:
			if e.dead or e.player != pi:
				continue
			var ee: Dictionary = e.def.get("eat", {})
			for k in ee:
				if eat.has(k):
					eat[k] += ee[k] / Data.UPKEEP_DIVISOR  # player.script speed 20000
		for e in live_blds:
			if e.dead or e.player != pi:
				continue
			var ee2: Dictionary = e.def.get("eat", {})
			for k in ee2:
				if eat.has(k):
					eat[k] += ee2[k] / Data.UPKEEP_DIVISOR
		for k in eat:
			if eat[k] > 0:
				var idx: int = Data.RES_NAMES.find(k)
				var have: float = p.res[idx]
				var need: float = eat[k] * dt
				if have >= need:
					p.res[idx] = have - need
					if k == "food":
						p["famine"] = false
						p["famine_t"] = 0.0
					if k == "gold":
						p["gold_famine_t"] = 0.0
				else:
					p.res[idx] = 0.0
					if k == "food":
						p["famine"] = true
						p["famine_t"] = float(p.get("famine_t", 0.0)) + dt
						if float(p["famine_t"]) >= Data.FAMINE_GRACE_S:
							if float(p.get("famine_msg_t", 0.0)) <= 0.0:
								p["famine_msg_t"] = 10.0
								say("Famine! %s is starving." % p.name)
							for e in entities:
								if not e.dead and e.player == pi and e.kind == "unit":
									e.hp -= Data.FAMINE_DRAIN_PER_S * dt
					if k == "gold":
						p["gold_famine_t"] = float(p.get("gold_famine_t", 0.0)) + dt
						if float(p["gold_famine_t"]) >= 60.0:
							for e in entities:
								if not e.dead and e.player == pi and e.kind == "unit" and e.def.get("eat", {}).has("gold"):
									e["morale"] = maxf(0.0, float(e.get("morale", 70.0)) - 10.0 * dt)

func _tick_cleanup(dt: float) -> void:
	for e in entities:
		if e.dead:
			continue
		if e.hp <= 0:
			_kill(e, null)

func _kill(e: Dictionary, killer = null, loud := true) -> void:
	if e.dead:
		return
	e.dead = true
	# squads drop the fallen so a dead officer does not hold the squad
	if e.kind == "unit" and e.has("squad"):
		var s: Dictionary = squads.get(int(e.squad), {})
		if not s.is_empty():
			squad_remove(int(e.squad), e.id)
			if int(s.get("officer", 0)) == 0 and s.members.is_empty():
				squads.erase(int(e.squad))
		e.erase("squad")
	players[e.player].score -= e.def.get("score", 0)
	if e.kind == "building" and bool(e.get("finished", true)):
		players[e.player].farm_cap = maxi(0, int(players[e.player].farm_cap) - int(e.def.get("farm", 0)))
	if e.kind == "unit":
		_leave_building(e)
		post_event("death", e.pos, e.sid, e.sid)
		corpses.append({"pos": e.pos, "sid": e.sid, "player": e.player, "t": 0.0, "life": float(Data.CORPSE_LIFE), "death_t": time_s, "face": e.get("face", 0.0)})
		if corpses.size() > 600:
			corpses.pop_front()
		if killer != null and not killer.is_empty():
			stats.kills += 1
	else:
		# garrison dies with the building (siege feel); unload first to find them
		var hid: Array = []
		for u in live_units:
			if not u.dead and int(u.get("inside_of", 0)) == e.id and bool(u.get("hidden", false)):
				hid.append(u)
		for u in hid:
			_kill(u, killer, false)
		set_blocked_circle(e.pos, e.def.radius, false)
		if e.get("workers", 0) > 0:
			for u in entities:
				if not u.dead and u.inside_of == e.id:
					u.inside_of = 0
					u.order = {"type": "none"}
		post_event("death", e.pos, "building")
		if loud:
			say("%s lost a %s." % [players[e.player].name, e.sid])
		rubble.append({"pos": e.pos, "sid": e.sid, "player": e.player, "t": 0.0, "life": 20.0})
		if rubble.size() > 60:
			rubble.pop_front()
		bld_dirty += 1

func cmd_make_gate(w: Dictionary) -> void:
	if w.dead or w.sid != "wal" or not w.finished or w.player < 0:
		return
	set_blocked_circle(w.pos, w.def.radius, false)
	w.sid = "gat"
	w.def = Data.BUILDINGS["gat"]
	w["closed"] = false
	gates.append(w)
	bld_dirty += 1
	say("Wall segment converted to a gate.")

func cmd_gate_toggle(g: Dictionary) -> void:
	if g.dead or g.sid != "gat":
		return
	if g.player != 0:
		return
	g["closed"] = not bool(g.get("closed", false))
	bld_dirty += 1
	say("Gate %s." % ("closed" if g["closed"] else "open"))

func cmd_repair(pe: Dictionary, b: Dictionary) -> void:
	if pe.dead or pe.sid != "peasant" or b.dead or b.player != pe.player:
		return
	if b.hp >= b.max_hp:
		return
	_leave_building(pe)
	pe.order = {"type": "repair", "target": b.id}

# Delete: remove your own selected units/buildings (wiki: delete what you
# cannot hold so the enemy cannot capture it). No score penalty, farm freed.
func cmd_delete(e: Dictionary) -> void:
	if e.dead or e.player != 0:
		return
	var sc: int = players[e.player].score
	_kill(e, null, false)
	players[e.player].score = sc
	say("Deleted %s." % e.sid)

func _step_move(e: Dictionary, target: Vector2, speed: float, dt: float, arrive := 0.15) -> bool:
	# Walk one step towards the target. When the direct line is blocked we try
	# progressively rotated directions (15..90 degrees) so units slide around
	# forests and buildings instead of sticking to their edge.
	var to: Vector2 = target - e.pos
	var d: float = to.length()
	if d <= arrive:
		e.moving = false
		e["stuck_t"] = 0.0
		return true
	var step: float = minf(speed * dt, d)
	var dir: Vector2 = to / d
	for i in 13:
		var ang := 0.0
		if i > 0:
			var step_i: int = (i + 1) / 2 + 1
			ang = (PI / 12.0) * float(step_i) * (1.0 if i % 2 == 0 else -1.0)
		var d2: Vector2 = dir.rotated(ang)
		var np: Vector2 = e.pos + d2 * step
		if not _blocked_for(e, np) and not _blocked_for(e, np + d2 * 0.45):
			var sl := slope_to(e.pos, np)
			if sl > 0.55:
				continue
			var esp := speed
			if height_at(np) > height_at(e.pos) + 0.05 and sl > 0.25:
				esp *= 0.6
				if esp * dt < step:
					np = e.pos + d2 * esp * dt
			e.pos = np
			e.face = d2.angle()
			e["stuck_t"] = 0.0
			return d - step < arrive
	# boxed in on every side: stay put and let the caller give up
	e.moving = false
	e["stuck_t"] = e.get("stuck_t", 0.0) + dt
	return false

# Deterministic slot around a work point (tree, rock, build site): golden-angle
# spiral so N workers fan into a ring instead of stacking. Same unit always
# takes the same slot, so orders are stable and neighbours do not jitter.
func _work_slot(e: Dictionary, center: Vector2, ring_r: float) -> Vector2:
	var ang := float(e.id) * 2.399963 + center.x * 0.13 + center.y * 0.07
	var rr := ring_r + float(e.id % 3) * 0.35
	var p := center + Vector2(cos(ang), sin(ang)) * rr
	if in_bounds(p) and not is_blocked(p):
		return p
	# blocked side of the ring: try the opposite side
	var p2 := center - Vector2(cos(ang), sin(ang)) * rr
	if in_bounds(p2) and not is_blocked(p2):
		return p2
	return center

func _tick_unit(e: Dictionary, dt: float) -> void:
	e.cooldown = maxf(0.0, e.cooldown - dt)
	e.acq_t = float(e.get("acq_t", 0.0)) - dt
	if e.acq_t <= 0.0:
		e.acq_t = 0.125
		e["acq_now"] = true
		e.aur_off = officer_near(e.pos, e.player)
		e.aur_dru = drummer_near(e.pos, e.player)
	else:
		e["acq_now"] = false
	# deployed crews: standing still readies the gun
	if e.moving:
		e["deploy_t"] = 0.0
	else:
		e["deploy_t"] = float(e.get("deploy_t", 0.0)) + dt
	# video pass: morale. Officers/drumers hold the line, wounds and famine
	# break it, broken troops rout (run from the enemy, cannot fight).
	_update_morale(e, dt)
	if e.get("routing", false):
		_tick_rout(e, dt)
		return
	# video pass: priests heal the line around them every tick
	if e.sid == "priest" and not e.moving:
		_priest_heal(e, dt)
	var o: Dictionary = e.order
	match o.type:
		"move":
			e.moving = true
			_step_move(e, o.pos, effective_speed(e), dt)
			var sqm: Dictionary = squad_of_unit(e.id)
			if not sqm.is_empty() and int(sqm.get("officer", 0)) == e.id:
				sqm["face"] = (o.pos - e.pos).angle()
			if not e.moving:
				e.order = {"type": "none"}
		"attackmove":
			e.moving = true
			var en: Dictionary = {}
			if bool(e.get("acq_now", false)):
				en = enemies_preferred(e.pos, e.player, float(e.def.search), e)
				e["acq_target"] = en.id if not en.is_empty() else 0
			else:
				en = by_id.get(int(e.get("acq_target", 0)), {})
				if not en.is_empty() and (en.dead or en.player == e.player or en.pos.distance_to(e.pos) > float(e.def.search)):
					en = {}
			if not en.is_empty() and not bool(e.get("hold_fire", false)):
				e.order = {"type": "attack", "target": en.id, "resume": o.pos}
				return
			_step_move(e, o.pos, effective_speed(e), dt)
			if not e.moving:
				e.order = {"type": "none"}
		"attack":
			var t: Dictionary = by_id.get(o.get("target", 0), {})
			if t.is_empty() or t.dead:
				var resume: Vector2 = o.get("resume", Vector2.INF)
				if resume != Vector2.INF:
					e.order = {"type": "attackmove", "pos": resume}
					e.moving = true
				elif o.has("resume_guard"):
					e.order = {"type": "guard", "target": o.resume_guard}
					e.moving = true
				elif o.has("resume_patrol"):
					var pa: Vector2 = o.get("a", e.pos)
					var pb2: Vector2 = o.get("b", e.pos)
					e.order = {"type": "patrol", "a": pa, "b": pb2, "leg": 0}
					e.moving = true
				else:
					e.order = {"type": "none"}
					e.moving = false
				return
			var w0 := weapon_of(e)
			if w0.is_empty():
				e.order = {"type": "none"}
				return
			var d: float = e.pos.distance_to(t.pos)
			var tr: float = t.def.radius
			e.face = (t.pos - e.pos).angle()
			var w := _pick_weapon(e, d)
			if w.get("only_buildings", false) and t.kind != "building":
				# mortars can only attack buildings: hold fire, keep the order
				e.moving = false
				return
			if d > w.max + tr:
				e.moving = true
				_step_move(e, t.pos, effective_speed(e), dt)
				if not e.moving:
					e.stuck_t = float(e.get("stuck_t", 0.0)) + dt
					if e.stuck_t > 6.0:
						e.stuck_t = 0.0
						e.order = {"type": "attackmove", "pos": t.pos}
				else:
					e.stuck_t = 0.0
			elif d < w.min:
				if bool(e.def.get("no_melee", false)):
					# 17th-century shooters have no bayonet: fall back out of
					# reach instead of standing under pikes (wiki combat basics)
					e.moving = false
					e.order = {"type": "move", "pos": e.pos + (e.pos - t.pos).normalized() * 4.0}
				else:
					# too close: step back (original backs away from melee for shooters)
					var away: Vector2 = (e.pos - t.pos).normalized() * 1.0
					e.moving = true
					_step_move(e, e.pos + away, effective_speed(e), dt)
			else:
				e.moving = false
				if e.cooldown <= 0:
					if e.def.get("artillery", false):
						w = w.duplicate()
						w["max"] = float(w.max) * float(players[e.player].get("art_range", 1.0))
					var hd: float = height_at(e.pos) - height_at(t.pos)
					if hd > 0.6 and str(w.kind) in ["bullet", "arrow", "firearrow", "cannonball", "cannister"]:
						w = w.duplicate()
						w["max"] = float(w.max) * 1.25
					_fire(e, t, w)
		"guard":
			var gt: Dictionary = by_id.get(o.get("target", 0), {})
			if gt.is_empty() or gt.dead:
				e.order = {"type": "none"}
				e.moving = false
				return
			var gd: float = e.pos.distance_to(gt.pos)
			var foe: Dictionary = {}
			if bool(e.get("acq_now", false)):
				foe = enemies_preferred(e.pos, e.player, float(e.def.search), e)
				e["acq_target"] = foe.id if not foe.is_empty() else 0
			else:
				foe = by_id.get(int(e.get("acq_target", 0)), {})
				if not foe.is_empty() and (foe.dead or foe.player == e.player or foe.pos.distance_to(e.pos) > float(e.def.search)):
					foe = {}
			if not foe.is_empty() and has_weapon(e) and not bool(e.get("hold_fire", false)):
				e.order = {"type": "attack", "target": foe.id, "resume_guard": gt.id}
				return
			if gd > 3.0:
				e.moving = true
				_step_move(e, gt.pos, effective_speed(e), dt, 2.0)
			else:
				e.moving = false
		"patrol":
			var a: Vector2 = o.get("a", e.pos)
			var b: Vector2 = o.get("b", e.pos)
			var foe2: Dictionary = {}
			if bool(e.get("acq_now", false)):
				foe2 = enemies_preferred(e.pos, e.player, float(e.def.search), e)
				e["acq_target"] = foe2.id if not foe2.is_empty() else 0
			else:
				foe2 = by_id.get(int(e.get("acq_target", 0)), {})
				if not foe2.is_empty() and (foe2.dead or foe2.player == e.player or foe2.pos.distance_to(e.pos) > float(e.def.search)):
					foe2 = {}
			if not foe2.is_empty() and has_weapon(e) and not bool(e.get("hold_fire", false)):
				e.order = {"type": "attack", "target": foe2.id, "resume_patrol": true, "a": a, "b": b}
				return
			var dest: Vector2 = b if int(o.get("leg", 0)) == 0 else a
			e.moving = true
			_step_move(e, dest, effective_speed(e), dt, 1.0)
			if not e.moving:
				o.leg = 1 - int(o.get("leg", 0))
		"gather":
			_tick_gather(e, dt)
		"resow":
			var fn: Dictionary = by_id.get(o.get("node", 0), {})
			if fn.is_empty() or fn.hits > 0:
				e.order = {"type": "none"}
				return
			var fslot := _work_slot(e, fn.pos, fn.radius + 0.7)
			if e.pos.distance_to(fslot) > 0.6:
				e.moving = true
				_step_move(e, fslot, effective_speed(e), dt, 0.35)
			else:
				e.moving = false
				e.face = (fn.pos - e.pos).angle()
				e["hit_t"] = float(e.get("hit_t", 0.0)) + dt
				if e.hit_t >= 2.0:
					e.hit_t = 0.0
					if not pay_cost(e.player, {"food": 20}):
						e.order = {"type": "none"}
						return
					fn.hits = int(fn.max_hits)
					res_dirty += 1
					post_event("construct", fn.pos, "field")
					e.order = {"type": "gather", "node": fn.id, "res": "food"}
		"repair":
			var rb: Dictionary = by_id.get(o.get("target", 0), {})
			if rb.is_empty() or rb.dead or rb.hp >= rb.max_hp:
				e.order = {"type": "none"}
				return
			var rslot := _work_slot(e, rb.pos, rb.def.radius + 0.7)
			if e.pos.distance_to(rslot) > 0.6:
				e.moving = true
				_step_move(e, rslot, effective_speed(e), dt, 0.35)
			else:
				e.moving = false
				e["hit_t"] = (e.get("hit_t", 0.0) + dt)
				if e.hit_t >= Data.BUILD_HIT_INTERVAL:
					e.hit_t = 0.0
					var add := int(rb.max_hp * Data.BUILD_PROGRESS_PER_HIT / maxf(1.0, rb.def.build_time))
					rb.hp = mini(rb.max_hp, rb.hp + maxi(1, add))
					if not pay_cost(e.player, {"stone": 1}):
						e.order = {"type": "none"}
		"attackground":
			var gp: Vector2 = o.get("pos", e.pos)
			var gd: float = e.pos.distance_to(gp)
			var gw := _pick_weapon(e, gd)
			if gw.is_empty():
				e.order = {"type": "none"}
				return
			if gd > float(gw.max):
				e.moving = true
				_step_move(e, gp, effective_speed(e), dt, 0.5)
			else:
				e.moving = false
				e.face = (gp - e.pos).angle()
				e.deploy_t = float(e.get("deploy_t", 0.0)) + dt
				e.cooldown = float(e.get("cooldown", 0.0)) - dt
				if e.cooldown <= 0.0 and e.deploy_t >= Data.ARTILLERY_DEPLOY_S:
					e.cooldown = float(gw.cd)
					var fake := {"pos": gp, "kind": "unit", "player": -1, "dead": false, "hp": 1, "max_hp": 1, "def": {"radius": 0.5}, "prot": [0, 0, 0, 0, 0, 0]}
					_fire(e, fake, gw)
		"build":
			var site: Dictionary = by_id.get(o.get("target", 0), {})
			if site.is_empty() or site.dead or site.finished:
				e.order = {"type": "none"}
				return
			# each builder takes its own slot around the site so the crew
			# rings the foundations instead of stacking on one point
			var slot_b := _work_slot(e, site.pos, site.def.radius + 0.7)
			var d: float = e.pos.distance_to(slot_b)
			if d > 0.6:
				e.moving = true
				_step_move(e, slot_b, effective_speed(e), dt, 0.35)
				if e.get("stuck_t", 0.0) > 8.0:
					e["stuck_t"] = 0.0
					e.order = {"type": "none"}
					e.moving = false
			else:
				e.moving = false
				e.face = (site.pos - e.pos).angle()
				e["hit_t"] = (e.get("hit_t", 0.0) + dt)
				if e.hit_t >= Data.BUILD_HIT_INTERVAL:
					e.hit_t = 0.0
					site.progress += Data.BUILD_PROGRESS_PER_HIT / float(players[site.player].get("build_mult", 1.0))
					site.hp = mini(site.max_hp, site.hp + int(site.max_hp * Data.BUILD_PROGRESS_PER_HIT / site.def.build_time * 0.75))
					bld_dirty += 1
					if site.progress >= site.def.build_time:
						site.progress = site.def.build_time
						site.finished = true
						_on_building_finished(site)
						post_event("done", site.pos, site.sid)
						e.order = {"type": "none"}
		_:
			# idle: military auto-acquire (support troops stay out of it)
			if e.hold:
				return
			if e.def.get("support", false):
				return
			if has_weapon(e) and e.sid != "peasant":
				var en: Dictionary = {}
				if bool(e.get("acq_now", false)):
					en = enemies_in_radius(e.pos, e.player, float(e.def.search))
					e["acq_target"] = en.id if not en.is_empty() else 0
				else:
					en = by_id.get(int(e.get("acq_target", 0)), {})
					if not en.is_empty() and (en.dead or en.player == e.player or en.pos.distance_to(e.pos) > float(e.def.search)):
						en = {}
				if not en.is_empty():
					e.order = {"type": "attack", "target": en.id}

func _update_morale(e: Dictionary, dt: float) -> void:
	if e.kind != "unit" or e.def.get("support", false):
		return
	var m := float(e.get("morale", Data.MORALE_BASE))
	# recover towards base, faster near leaders
	var want := Data.MORALE_BASE
	if bool(e.get("aur_off", false)):
		want += Data.MORALE_OFFICER_BONUS
	if bool(e.get("aur_dru", false)):
		want += Data.MORALE_DRUMMER_BONUS
	if e.hp < e.max_hp * 0.3:
		want -= Data.MORALE_LOW_HP_PENALTY
	if bool(players[e.player].get("famine", false)):
		want -= Data.MORALE_FAMINE_PENALTY
	var rate := 6.0 if want > m else 3.0
	m += clampf(want - m, -rate * dt, rate * dt)
	e["morale"] = m
	if not e.get("routing", false) and m < Data.MORALE_ROUT_THRESHOLD and e.sid != "peasant":
		e["routing"] = true
		e["routing_t"] = 0.0
		post_event("rout", e.pos, e.sid, "")
	elif e.get("routing", false) and m > Data.MORALE_ROUT_THRESHOLD + 25.0:
		e["routing"] = false

func _tick_rout(e: Dictionary, dt: float) -> void:
	# run away from the nearest enemy towards home, then recover
	e["routing_t"] = float(e.get("routing_t", 0.0)) + dt
	var foe: Dictionary = enemies_in_radius(e.pos, e.player, 25.0, false)
	var best_hd := 1e9
	var home_pos: Vector2 = e.pos
	for b in live_blds:
		if b.dead or b.player != e.player:
			continue
		var d: float = b.pos.distance_to(e.pos)
		if d < best_hd:
			best_hd = d
			home_pos = b.pos
	var dir := Vector2.ZERO
	if not foe.is_empty():
		dir = (e.pos - foe.pos).normalized()
	else:
		dir = (home_pos - e.pos).normalized()
		if e.pos.distance_to(home_pos) < 4.0:
			e["routing"] = false
			e.moving = false
			return
	e.moving = true
	_step_move(e, e.pos + dir * 6.0, effective_speed(e), dt)
	if float(e.get("routing_t", 0.0)) > 12.0:
		e["routing"] = false

func _priest_heal(e: Dictionary, dt: float) -> void:
	for u in grid_query(e.pos, 8.0):
		if u.dead or u.kind != "unit" or u.player != e.player:
			continue
		if u.id == e.id:
			continue
		if u.hp >= u.max_hp:
			continue
		if u.pos.distance_to(e.pos) <= Data.PRIEST_HEAL_RADIUS:
			u.hp = mini(u.max_hp, int(u.hp + Data.PRIEST_HEAL_PER_S * dt + 0.5))
			if rng.randf() < dt * 2.0:
				post_event("heal", u.pos, "priest", "")

func _dispersion_px(kind: String, sid: String) -> float:
	# Video pass: musket volleys puff smoke and land tight, arrows scatter,
	# cannonballs scream across half the screen and throw dirt everywhere.
	if kind == "arrow" or kind == "firearrow":
		return Data.ARROW_DISPERSION_PX * Data.PX_TO_M
	if kind == "cannonball":
		if sid == "tow":
			return Data.TOWER_DISPERSION_PX * Data.PX_TO_M
		return Data.CANNON_DISPERSION_PX * Data.PX_TO_M
	return 0.0

# Walls block direct fire: flat-trajectory shots stop at the first segment
# between shooter and target (howitzers/mortars arc over; wiki Wall).
func _wall_between(a: Vector2, b: Vector2) -> bool:
	for e in grid_query((a + b) * 0.5, a.distance_to(b) * 0.5 + 4.0):
		if e.dead or e.kind != "building":
			continue
		if e.sid != "wal" and not (e.sid == "gat" and bool(e.get("closed", false))):
			continue
		var ab: Vector2 = b - a
		var L: float = ab.length()
		if L < 0.01:
			continue
		var t: float = clampf((e.pos - a).dot(ab) / (L * L), 0.0, 1.0)
		if (a + ab * t).distance_to(e.pos) <= float(e.def.radius):
			return true
	return false

func _fire(e: Dictionary, t: Dictionary, w: Dictionary, bonus := 0) -> void:
	var cost: Dictionary = w.get("cost", {})
	if not cost.is_empty() and not Data.can_pay(players[e.player].res, cost):
		e.cooldown = 1.0
		return
	# artillery must be deployed: the crew unlimbers before the first shot
	if e.def.get("artillery", false) and float(e.get("deploy_t", 0.0)) < Data.ARTILLERY_DEPLOY_S:
		e.cooldown = 0.25
		return
	if str(w.kind) in ["bullet", "arrow", "firearrow", "cannonball"] \
			and not str(e.sid) in ["howitzer", "mortar"] \
			and _wall_between(e.pos, t.pos):
		e.cooldown = 0.5
		return
	if str(w.kind) == "cannonball" and not str(e.sid) in ["howitzer", "mortar"]:
		var mid: Vector2 = (e.pos + t.pos) * 0.5
		if height_at(mid) > maxf(height_at(e.pos), height_at(t.pos)) + 0.8:
			e.cooldown = 0.5
			return
	Data.pay(players[e.player].res, cost)
	e.cooldown = w.cd * (float(e.get("rof_mult", 1.0)) if e.kind == "building" else 1.0)
	e.fire_t = time_s
	stats.shots += 1
	# officer aura + researched powder upgrades multiply the listed damage
	var mult: float = effective_damage(e.player, w.kind, e.pos)
	var base_dmg := int(round(float(w.dmg) * mult)) + _formation_atk(e, w.kind) + bonus
	post_event("shot", e.pos, w.kind, e.sid)
	if int(t.get("player", 0)) == -1:
		var disp := _dispersion_px("cannonball", e.sid) * float(players[e.player].get("art_acc", 1.0))
		var aim: Vector2 = t.pos + Vector2(rng.randf_range(-disp, disp), rng.randf_range(-disp, disp)) * 0.5
		var dist: float = e.pos.distance_to(aim)
		var flight := clampf(dist / 30.0, 0.5, 1.6)
		projectiles.append({"pos": e.pos, "target": aim, "kind": "cannonball",
			"dmg": base_dmg, "splash": float(w.get("splash", 0.0)),
			"owner": e.id, "player": e.player, "t": 0.0, "total": flight})
		if projectiles.size() > 512:
			projectiles.pop_front()
		return
	if w.kind == "bullet":
		post_event("smoke", e.pos, w.kind, e.sid)
		_apply_hit(e, t, w, base_dmg, t.pos)
	elif w.kind == "cannonball":
		# lobbed shell: lands after a flight, scatters, hurts everyone
		var disp := _dispersion_px(w.kind, e.sid) * float(players[e.player].get("art_acc", 1.0))
		var aim: Vector2 = t.pos + Vector2(rng.randf_range(-disp, disp), rng.randf_range(-disp, disp)) * 0.5
		var dist: float = e.pos.distance_to(aim)
		var flight := clampf(dist / 30.0, 0.5, 1.6)
		projectiles.append({"pos": e.pos, "target": aim, "kind": w.kind,
			"dmg": base_dmg, "splash": float(w.get("splash", 0.0)),
			"owner": e.id, "player": e.player, "t": 0.0, "total": flight})
		if projectiles.size() > 512:
			projectiles.pop_front()
	elif w.kind == "arrow" or w.kind == "firearrow":
		var disp2 := _dispersion_px(w.kind, e.sid) * float(players[e.player].get("art_acc", 1.0))
		var aim2: Vector2 = t.pos + Vector2(rng.randf_range(-disp2, disp2), rng.randf_range(-disp2, disp2)) * 0.4
		projectiles.append({"pos": e.pos, "target": aim2, "kind": w.kind,
			"dmg": base_dmg, "splash": float(w.get("splash", 0.0)),
			"owner": e.id, "player": e.player, "t": 0.0, "total": 0.45})
		if projectiles.size() > 512:
			projectiles.pop_front()
	else:
		_apply_hit(e, t, w, base_dmg, t.pos)

func _apply_hit(e: Dictionary, t: Dictionary, w: Dictionary, dmg: int, at: Vector2) -> void:
	if t.is_empty() or t.dead:
		return
	if t.kind == "unit" and str(t.sid) == "peasant" and e.kind == "unit" \
			and e.player != t.player and not e.def.get("support", false) \
			and bool(Data.CAPTURE_ENABLED) and str(e.sid) != "peasant":
		var oldp: int = int(t.player)
		t.player = e.player
		t.order = {"type": "none"}
		t.inside_of = 0
		t["morale"] = 70.0
		players[oldp].entities.erase(t.id)
		players[int(e.player)].entities.append(t.id)
		post_event("capture", t.pos, "unit")
		if e.player == 0:
			say("Enemy peasant captured!")
		return
	# towers are fortifications: only artillery, grenades and arrows hurt them
	if t.kind == "building" and t.sid in ["tow", "wal", "gat"] and not str(w.kind) in ["cannonball", "cannister", "arrow", "firearrow"]:
		return
	# protection + researched armor, upgrade-aware
	var prot: Array = (t.get("prot", [0, 0, 0, 0, 0, 0]) as Array).duplicate()
	var pb: int = int(players[t.player].get("prot_bonus", 0))
	if pb != 0:
		for i in prot.size():
			prot[i] = int(prot[i]) + pb
	var fb := _formation_def(t)
	if fb != 0:
		for i in prot.size():
			prot[i] = int(prot[i]) + fb
	var tmp := {"cavalry": t.get("cavalry", ""), "moving": t.get("moving", false),
		"shield": t.get("shield", 0), "finished": t.get("finished", true), "prot": prot}
	var dealt: int = C3Data.apply_damage(dmg, w.kind, tmp)
	t.hp -= dealt
	if t.kind == "building":
		bld_dirty += 1
	# morale shock when hit
	if t.kind == "unit":
		t["morale"] = float(t.get("morale", Data.MORALE_BASE)) - 4.0
	stats.hits += 1
	if killer_pair(e, t):
		stats.kills += 1
		_morale_shock(t.pos, t.player)
	# splash hurts everyone (video: friendly fire is real), half to the rim
	if float(w.get("splash", 0.0)) > 0.0:
		post_event("explode", at, w.kind, e.sid)
		for u in grid_query(at, float(w.get("splash", 0.0)) + 2.0):
			if u.dead or u.id == t.id:
				continue
			var rr: float = float(w.splash) + (float(u.def.radius) if u.kind == "building" else 0.0)
			if u.pos.distance_to(at) <= rr:
				var vp: Array = u.prot.duplicate()
				for k in 6:
					vp[k] = int(vp[k]) + int(players[u.player].get("prot_bonus", 0)) + _formation_def(u)
				var utmp := {"cavalry": u.get("cavalry", ""), "moving": u.get("moving", false),
					"shield": u.get("shield", 0), "finished": u.get("finished", true), "prot": vp}
				var sd: int = C3Data.apply_damage(int(float(dmg) * 0.5), w.kind, utmp)
				u.hp -= sd
				if u.kind == "building":
					bld_dirty += 1
	post_event("hit", at, w.kind, e.sid)

func _morale_shock(pos: Vector2, player: int) -> void:
	for u in grid_query(pos, 10.0):
		if u.dead or u.kind != "unit" or u.player != player:
			continue
		if u.pos.distance_to(pos) <= 10.0:
			u["morale"] = float(u.get("morale", Data.MORALE_BASE)) - 6.0

func _tick_projectiles(dt: float) -> void:
	if projectiles.is_empty():
		return
	var keep: Array = []
	for p in projectiles:
		p.t += dt
		if p.t < float(p.total):
			keep.append(p)
			continue
		var owner: Dictionary = by_id.get(p.get("owner", 0), {})
		# find who is actually at the impact point (friendly fire included)
		var victim: Dictionary = {}
		var best_d := 2.0
		for u in grid_query(p.target, 3.0):
			if u.dead:
				continue
			var d: float = u.pos.distance_to(p.target)
			var rr: float = 1.2 + float(u.def.radius)
			if d <= rr and d < best_d:
				best_d = d
				victim = u
		if victim.is_empty():
			post_event("explode" if p.kind == "cannonball" else "hit", p.target, p.kind, "")
		else:
			if owner.is_empty():
				owner = {"id": 0, "player": p.player, "pos": p.pos}
			_apply_hit(owner, victim, {"kind": p.kind, "splash": p.splash}, int(p.dmg), p.target)
		post_event("crater" if p.kind == "cannonball" else "hit", p.target, p.kind, "")
	projectiles = keep

func killer_pair(attacker: Dictionary, target: Dictionary) -> bool:
	return target.hp <= 0 and not target.dead

func _tick_gather(e: Dictionary, dt: float) -> void:
	var o: Dictionary = e.order
	var res: String = o.res
	if e.carry_type != "" and e.carry_type != res:
		# deliver first
		_gather_deliver(e, dt)
		return
	if res in ["gold", "iron", "coal"]:
		var mine: Dictionary = by_id.get(o.get("node", 0), {})
		var valid: bool = not mine.is_empty() and not mine.dead and mine.sid == "mine_" + res \
			and mine.player == e.player \
			and ((mine.finished and mine.get("deposit_left", 0) > 0) or not mine.finished)
		if not valid:
			mine = nearest_mine(e.pos, res, e.player)
			if mine.is_empty():
				e.order = {"type": "none"}
				return
			o.node = mine.id
		if not mine.finished:
			# walk to the mine site and wait for the builders (with a
			# timeout so a stalled site never pins peasants forever)
			e.moving = true
			_step_move(e, mine.pos, e.def.speed, dt, mine.def.radius + 1.2)
			e["wait_t"] = float(e.get("wait_t", 0.0)) + dt
			if float(e.get("wait_t", 0.0)) > 60.0:
				e["wait_t"] = 0.0
				e.order = {"type": "none"}
			return
		e["wait_t"] = 0.0
		var d: float = e.pos.distance_to(mine.pos)
		if d > mine.def.radius + 1.8:
			e.moving = true
			_step_move(e, mine.pos, e.def.speed, dt, mine.def.radius + 0.9)
		else:
			e.moving = false
			if e.inside_of != mine.id:
				if mine.workers >= int(mine.get("slots", mine.def.get("slots", 5))):
					e.order = {"type": "none"}
					return
				_leave_building(e)
				mine.workers += 1
				e.inside_of = mine.id
		return
	# field resource (food/wood/stone)
	# a loaded peasant walks the load to the storehouse first, then goes back
	var node: Dictionary = by_id.get(o.get("node", 0), {})
	if e.carry > 0:
		_gather_deliver(e, dt)
		return
	var avoid_n := _bad_id(e, "bad_node", "bad_t")
	if node.is_empty() or node.get("hits", 0) <= 0:
		node = nearest_res(e.pos, res, 30.0, true, avoid_n)
		if node.is_empty():
			e.order = {"type": "none"}
			return
		o.node = node.id
	# the spot itself is blocked (a tree stands on it), so the peasant works
	# from the neighbouring tile: stand-off must be wider than the arrival
	# radius, otherwise the unit ends up in a dead zone and never works.
	# each peasant works from its own slot around the tree/rock so workers
	# fan out instead of overlapping on the same point.
	var slot := _work_slot(e, node.pos, node.radius + 1.1)
	if res == "food":
		var on_node := 0
		for u in grid_query(node.pos, node.radius + 2.0):
			if not u.dead and u.id != e.id and u.order.type == "gather" and u.order.get("node", 0) == node.id and u.pos.distance_to(node.pos) < node.radius + 2.0:
				on_node += 1
		if on_node >= 2:
			var altf := nearest_res(e.pos, "food", 45.0, true)
			if not altf.is_empty() and altf.id != node.id:
				o.node = altf.id
				node = altf
			else:
				e.order = {"type": "none"}
				return
	var reach: float = 1.4
	if e.pos.distance_to(slot) > reach:
		e.moving = true
		_step_move(e, slot, e.def.speed, dt, 0.5)
		if e.get("stuck_t", 0.0) > 4.0:
			# boxed in: remember the node and look for another spot of the
			# same kind (avoids re-picking the same unreachable node)
			e["stuck_t"] = 0.0
			e["bad_node"] = node.id
			e["bad_t"] = time_s
			var alt := nearest_res(e.pos, res, 45.0, true, node.id)
			if not alt.is_empty() and alt.id != node.id:
				o.node = alt.id
		return
	e.moving = false
	e.face = (node.pos - e.pos).angle()
	e["hit_t"] = (e.get("hit_t", 0.0) + dt)
	if e.hit_t < Data.GATHER[res].interval:
		return
	e.hit_t = 0.0
	if node.hits > 0:
		node.hits -= 1
		e.carry += 1
		e.carry_type = res
		post_event("chop", node.pos, res)
		if node.hits <= 0:
			if res == "wood":
				node.type = "stump"
				node["stump_t"] = 0.0
				node["max_hits"] = 0
				set_blocked_circle(node.pos, node.radius, false)
			elif res != "food":
				set_blocked_circle(node.pos, node.radius, false)
			post_event("depleted", node.pos, res)
			res_dirty += 1
	if e.carry >= Data.GATHER[res].hits or node.hits <= 0:
		_gather_deliver(e, dt)

func _gather_deliver(e: Dictionary, dt: float) -> void:
	var res: String = e.carry_type
	if res == "":
		res = e.order.get("res", "wood")
	var store := nearest_drop(e, res)
	if store.is_empty():
		if e.carry > 0:
			# no reachable store right now: hold the load, don't delete it
			e.moving = false
			return
		e.order = {"type": "none"}
		e.carry = 0
		e.carry_type = ""
		return
	var d: float = e.pos.distance_to(store.pos)
	if d > Data.DELIVERY_RADIUS_M + store.def.radius:
		e.moving = true
		e["delivering"] = true
		_step_move(e, store.pos, e.def.speed, dt)
		if float(e.get("stuck_t", 0.0)) > 8.0:
			# store unreachable from here: try another one next tick
			e["stuck_t"] = 0.0
			e["bad_store"] = store.id
			e["bad_t"] = time_s
		return
	e.moving = false
	e["delivering"] = false
	var portion: int = Data.GATHER.get(res, {}).get("carry", 20)
	var hits: int = Data.GATHER.get(res, {}).get("hits", 1)
	var mult_g: float = float(players[e.player].gather_mult.get(res, 1.0))
	var amount := int(round(float(portion) * minf(e.carry, hits) / hits * mult_g))
	if amount > 0:
		players[e.player].res[Data.RES_NAMES.find(res)] += amount
		stats.gathered[res] = int(stats.gathered.get(res, 0)) + amount
	e.carry = 0
	e.carry_type = ""
	# resume gathering at the last node if it still has resources, but never
	# overrule an order the peasant was given while it was walking here
	if e.order.get("res", res) != res:
		return
	var node: Dictionary = by_id.get(e.order.get("node", 0), {})
	if not node.is_empty() and node.get("hits", 0) > 0:
		e.order = {"type": "gather", "res": res, "node": node.id}
		e.moving = true
	else:
		var nxt := nearest_res(e.pos, res, 30.0)
		if not nxt.is_empty():
			e.order = {"type": "gather", "res": res, "node": nxt.id}
			e.moving = true
		else:
			e.order = {"type": "none"}

func _tick_building(e: Dictionary, dt: float) -> void:
	# production queue
	if e.finished and e.queue.size() > 0:
		var job: Dictionary = e.queue[0]
		job.t -= dt
		e.queue[0] = job
		if job.t <= 0.0:
			e.queue.pop_front()
			var exit: Vector2 = e.get("rally", e.pos + Vector2(0, e.def.radius + 2.0))
			var u := spawn(job.sid, e.player, e.pos + (exit - e.pos).normalized() * (e.def.radius + 0.5))
			cmd_move(u, exit + (exit - e.pos).normalized() * 1.5)
			post_event("trained", e.pos, job.sid, job.sid)
	# research queue (one upgrade at a time per blacksmith/academy)
	if e.finished and e.get("research") != null:
		var r: Dictionary = e.research
		r.t -= dt
		if r.t <= 0.0:
			e["research"] = null
			if str(r.uid).begins_with("mine_") or str(r.uid).begins_with("tow_rof"):
				var du: Array = e.get("done_ups", [])
				du.append(r.uid)
				e["done_ups"] = du
				apply_upgrade_to_building(e, r.uid)
			else:
				apply_upgrade(e.player, r.uid)
	# mine income
	if e.finished and e.sid.begins_with("mine_") and e.workers > 0:
		var amount: float = e.workers * Data.MINE_INCOME_PER_S * float(players[e.player].get("mine_mult", 1.0)) * dt
		var dt_dep: float = e.deposit_left
		amount = minf(amount, dt_dep)
		e.deposit_left = e.deposit_left - amount
		var nd: Dictionary = by_id.get(int(e.get("deposit_node", 0)), {})
		if not nd.is_empty():
			nd["left"] = maxf(0.0, float(nd.get("left", 0.0)) - amount)
		var idx: int = Data.RES_NAMES.find(e.def.mine)
		players[e.player].res[idx] += amount
		stats.gathered[e.def.mine] = float(stats.gathered.get(e.def.mine, 0.0)) + amount
		if e.deposit_left <= 0:
			_kill(e, null)
			say("A %s mine is exhausted." % e.def.mine)
	# tower weapon
	if e.finished and e.def.has("weapons"):
		e.cooldown = maxf(0.0, e.cooldown - dt)
		var w0: Dictionary = e.def.weapons[0]
		if e.cooldown <= 0 and e.get("active", true) and not bool(e.get("hold_fire", false)):
			var en := enemies_in_radius(e.pos, e.player, w0.max, false)
			if not en.is_empty():
				var w := _pick_weapon(e, en.pos.distance_to(e.pos))
				if w.get("only_buildings", false) and en.kind != "building":
					return
				if en.pos.distance_to(e.pos) >= w.min:
					_fire(e, en, w, 2 * int(e.get("garrison", 0)))
	# garrisoned units heal while inside
	if int(e.get("garrison", 0)) > 0:
		for u in live_units:
			if not u.dead and int(u.get("inside_of", 0)) == e.id and bool(u.get("hidden", false)):
				u.hp = mini(u.max_hp, int(u.hp + 2.0 * dt))
	# capture: peasants do it properly, soldiers only lean on it.
	# Video pass: a white flag goes up and the bar fills while peasants swarm
	# an empty building; garrisoned towers resist.
	if e.finished and e.def.get("capture", false):
		var peasants_allowed := bool(Data.CAPTURE_ENABLED)
		var peas := 0
		var sols := 0
		var capturer := -1
		for u in grid_query(e.pos, 8.0 + e.def.radius):
			if not u.dead and u.kind == "unit" and u.player != e.player \
					and u.pos.distance_to(e.pos) < 8.0 + e.def.radius:
				if u.sid == "peasant":
					if peasants_allowed:
						peas += 1
					else:
						continue
				else:
					sols += 1
				capturer = u.player
		if capturer >= 0:
			var speed_c: float = float(peas) * 1.0 + float(sols) * 0.25
			if int(e.get("garrison", 0)) > 0:
				speed_c *= 0.5
			e.capture_t += dt * speed_c
			e["cap_evt_t"] = float(e.get("cap_evt_t", 0.0)) - dt
			if float(e.get("cap_evt_t", 0.0)) <= 0.0 and peas > 0:
				e["cap_evt_t"] = 0.5
				post_event("capture", e.pos, e.sid)
			var need: float = 5.0 + float(e.max_hp) / 2500.0
			if e.capture_t >= need:
				var old: int = e.player
				e.capture_t = 0.0
				e.player = capturer
				players[old].entities.erase(e.id)
				players[capturer].entities.append(e.id)
				players[capturer].score += e.def.get("score", 0)
				if e.def.has("farm"):
					players[old].farm_cap = maxi(0, int(players[old].farm_cap) - int(e.def.get("farm", 0)))
					players[capturer].farm_cap += e.def.farm
				if e.sid.begins_with("mine_"):
					e["deposit_left"] = float(e.get("deposit_left", 0.0))
				e.erase("rally")
				post_event("capture", e.pos, e.sid)
				say("A building was captured!")
		else:
			e.capture_t = maxf(0.0, e.capture_t - dt)

func _check_victory() -> void:
	# "destroy_all": the side that has nothing left loses (the port's default,
	# estimated - the original skirmish condition was not in readable files).
	# "score": the first side to reach the score limit wins.
	if Data.VICTORY == "score":
		for pi in 2:
			if winner == -1 and players[pi].score >= Data.SCORE_LIMIT:
				winner = pi
				game_over.emit(winner)
				say("%s wins!" % players[winner].name)
		return
	for pi in 2:
		if winner == -1 and buildings_of(pi).is_empty() and units_of(pi).is_empty():
			winner = 1 - pi
			game_over.emit(winner)
			say("%s wins!" % players[winner].name)

func _vec_enc(v: Variant) -> Variant:
	if v is Vector2:
		return [v.x, v.y]
	if v is Dictionary:
		var o := {}
		for k in v:
			o[k] = _vec_enc(v[k])
		return o
	if v is Array:
		var a := []
		for x in v:
			a.append(_vec_enc(x))
		return a
	return v

func _vec_dec(v: Variant) -> Variant:
	if v is Array and v.size() == 2 and (v[0] is float or v[0] is int) and (v[1] is float or v[1] is int):
		return Vector2(float(v[0]), float(v[1]))
	if v is String and v.begins_with("(") and v.ends_with(")"):
		var s: String = v.substr(1, v.length() - 2).replace(" ", "")
		var p: PackedStringArray = s.split(",")
		if p.size() == 2 and p[0].is_valid_float() and p[1].is_valid_float():
			return Vector2(float(p[0]), float(p[1]))
	if v is Dictionary:
		var o := {}
		for k in v:
			o[k] = _vec_dec(v[k])
		return o
	if v is Array:
		var a := []
		for x in v:
			a.append(_vec_dec(x))
		return a
	return v

func serialize() -> Dictionary:
	var ents: Array = []
	for e in entities:
		if e.dead:
			continue
		var d: Dictionary = {}
		for k in e:
			if k in ["def", "order", "queue"]:
				continue
			d[k] = _vec_enc(e[k])
		d["order"] = _vec_enc(e.order.duplicate(true))
		d["queue"] = _vec_enc(e.queue.duplicate(true))
		ents.append(d)
	var nodes: Array = []
	for n in res_nodes:
		var nd: Dictionary = {}
		for k in n:
			nd[k] = _vec_enc(n[k])
		nodes.append(nd)
	var pls: Array = []
	for p in players:
		var pd: Dictionary = {}
		for k in p:
			pd[k] = _vec_enc(p[k])
		pls.append(pd)
	return {
		"version": 4, "seed": int(Data.RANDOM_SEED),
		"time_s": time_s, "winner": winner, "next_id": next_id,
		"next_squad": next_squad, "battle_mode": battle_mode,
		"terrain": Marshalls.raw_to_base64(terrain), "blocked": Marshalls.raw_to_base64(blocked),
		"height": Marshalls.raw_to_base64(height.to_byte_array()),
		"map_w": MAP_W, "map_h": MAP_H,
		"entities": ents, "res_nodes": nodes, "players": pls,
		"squads": squads.duplicate(true), "deposits": deposits.duplicate(),
		"stats": stats.duplicate(true), "objectives": objectives.duplicate(true),
	}

func deserialize(d: Dictionary) -> bool:
	if int(d.get("version", 0)) not in [3, 4]:
		return false
	MAP_W = int(d.map_w); MAP_H = int(d.map_h)
	terrain = Marshalls.base64_to_raw(str(d.terrain))
	blocked = Marshalls.base64_to_raw(str(d.blocked))
	if int(d.get("version", 0)) == 4 and d.has("height"):
		var raw := Marshalls.base64_to_raw(str(d.height))
		height.resize(MAP_W * MAP_H)
		for i in mini(height.size(), int(raw.size() / 4)):
			height[i] = raw.decode_float(i * 4)
	else:
		height.resize(MAP_W * MAP_H)
		for i in height.size():
			height[i] = 0.0
	time_s = float(d.time_s); winner = int(d.winner)
	next_id = int(d.next_id); next_squad = int(d.next_squad)
	battle_mode = bool(d.battle_mode)
	entities.clear(); by_id.clear()
	for ed in d.entities:
		var e: Dictionary = (_vec_dec(ed) as Dictionary).duplicate(true)
		var sid: String = str(e.sid)
		e["def"] = Data.UNITS[sid] if e.kind == "unit" else Data.BUILDINGS[sid]
		entities.append(e)
		by_id[int(e.id)] = e
	res_nodes = []
	for n in d.res_nodes:
		var nn: Dictionary = (_vec_dec(n) as Dictionary).duplicate(true)
		res_nodes.append(nn)
		by_id[int(nn.id)] = nn
	players = []
	for p in d.players:
		players.append((_vec_dec(p) as Dictionary).duplicate(true))
	squads = d.squads.duplicate(true)
	deposits = d.deposits.duplicate()
	stats = d.stats.duplicate(true)
	objectives = d.objectives.duplicate(true)
	gates.clear()
	for e in entities:
		if e.kind == "building" and str(e.sid) == "gat":
			gates.append(e)
	_grid_rebuild()
	# tile art uses its own deterministic stream — restore the seed first so a
	# quicksave made with seed A reloads with seed A's shore/smooth/variant art.
	if d.has("seed"):
		Data.RANDOM_SEED = int(d.seed)
	_assign_tileblocks()
	return true
