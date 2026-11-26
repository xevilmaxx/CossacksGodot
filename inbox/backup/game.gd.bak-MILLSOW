# Core simulation: map, entities, orders, gathering, building, combat, victory.
# All numbers come from ../scripts/data.gd (original game files, see MECHANICS.md).
extends Node
class_name C3Game

const Data = preload("res://scripts/data.gd")
const Nav = preload("res://scripts/nav.gd")
const C3ConfigScript = preload("res://scripts/config.gd")

# Runtime grid A* (see nav.gd).  `nav_version` is bumped whenever the
# passability grid changes so every planned route is invalidated.
var nav = Nav.new()
var nav_version := 1
const NAV_PER_TICK := 2          # spread big group orders over several frames
var _nav_tick_budget := NAV_PER_TICK

const TILE := 2.0
# How close to an ore deposit the build cursor must be for a mine to be legal
# (and for the unified "Mine" button to pick that deposit's type).
const MINE_SITE_RADIUS := 4.0
# T-MINES-PLACE: legacy discoverability ring (TILES), kept for t_mines_place.
const MINE_DISCOVER_R := 30.0
# T-MINES-START-FIX: tight per-start service ring and placement band.  Ores are
# radius-0 deposits; they do not need the 14-tile tree/stone keep-clear, so a
# guaranteed gold/iron/coal deposit may sit 6..14 tiles (12..28 m) from the
# hall.  Worst case after the last-resort widen is MINE_SERVED_R (16 tiles).
const MINE_SERVED_R := 16.0     # tiles: nearest ore per kind from the hall
const MINE_NEAR_LO := 6.0       # tiles: inner edge of the guaranteed band
const MINE_NEAR_HI := 14.0      # tiles: outer edge (short walk from town)
# T-MINES-FIX: the stamped donor mine cells reach ~5 tiles from the centre and
# game.gd paints a 3-tile dirt apron, so deposits must keep this much CENTRE
# separation to have ZERO footprint/apron intersection (incl. 1-tile margin).
# pattern_gen.gd uses the identical rule for its final layout; this helper is
# the game.gd side of the same contract.
const MINE_MIN_SEP_TILES := 11.0
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
# T2GEN P0-1: mine aprons stay terrain=1 (dirt) for simulation/world.gd parity,
# but carry a parallel mask so the tile picker can emit neutral ground1 and never
# the road-only test2/test3 names (mines_display.md C9 / A2).
var mine_mask: PackedByteArray = PackedByteArray()
var tbl_names: Array = []
var tbl_smooth: Array = []
var tbl_idx := {}
var res_nodes: Array = []
var map_starts: Array = []  # start positions of the generated map (groves near them are sacred)
var cluster_zones: Array = []  # claimed {pos, r} so clusters never overlap
# Donor mechanism: real .pattern footprints stamped through C3PatternGen's
# gPatternMask (misc.script:3384). Replaces the old per-tile blob placement.
var pattern_stamps: Array = []
# C3PatternGen.build result is computed once in _gen_base (relief stamps must
# shape height BEFORE the collision pass) and reused by _gen_patterns.  Caching
# keeps the two passes identical without consuming any extra `rng` draws.
var _pattern_build: Dictionary = {}
# RELIEF-LIVE-FIX-01: cells written by a donor-grid stamp.  Read by the global
# height clamp below so the donor cap is not re-quantised by the port's dither.
var _relief_donor_mask: PackedByteArray = PackedByteArray()
# B03-RELIEF: every cell whose HEIGHT was written by _shape_stamp_relief
# (donor-grid branch OR analytic fallback), plus the near_start protection ring.
# Retained as harmless, reusable provenance data. L03 showed the base-mask
# terraces outside this mask also produced the rock-art maze, so the gradient
# pass now writes no terrain=5 at all and no longer consults this mask; collision
# (set_blocked_tile) is unchanged. PORT APPROXIMATION — donor promotion UNVERIFIED.
var _relief_stamp_mask: PackedByteArray = PackedByteArray()
# LEGACY port amplitude constants, retained ONLY for the pre-existing analytic
# fallback/domes.  HEIGHT-GEN-DEEP-01 §4.3 corrects the donor truth: the live
# amplitudes at R=96 / R=48 are +0.495937258 / -0.557929397 (h=A_class*R/255);
# the larger +1.31733 / -2.964 values require the `//`-DISABLED multipliers at
# generatemap.inc:571-572.  These constants are NOT used as donor truth by the
# RELIEF-LIVE-FIX-01 grid path (that uses verbatim pattern.lib Min/Max/Scale).
# Donor has no script height clamp; the final clamp is UNVERIFIED (§5.4/§8 Q1).
const RELIEF_PLATEAU := 2.964
const RELIEF_HILL := 2.964 / 2.25
const RELIEF_RAVINE := -2.964
# RELIEF-LIVE-FIX-01 — donor-derived relief grids for the LIVE height path.
# These 8x10 tables are the block MEANS decoded from the donor float32 height
# windows in DPATTERN_01 Appendix A1/A2 (:595-626).  DPATTERN_01:599-600
# explicitly labels them "debug/preview aids only — stamp from the full grid";
# the full windows are not in the port, so using the coarse tables here is a
# labelled PORT APPROXIMATION, not donor parity.  Every number is donor-authored
# relief; no synthetic noise, dither-as-shape or invented hill is added.
# Row order is file order; the file-row -> map-row sign is UNVERIFIED (§9 Q3).
const RELIEF_GRID_W := 10
const RELIEF_GRID_H := 8
const RELIEF_GRID_K_RAVINE_1 = [
	-0.056, -0.309, -0.251, -0.067, -0.190, -1.119, -0.714, -0.000, -0.000, -0.013,
	-2.056, -2.251, -1.897, -0.629, -0.006, -0.121, -0.098, -0.001, -0.537, -2.300,
	-2.947, -2.941, -2.916, -1.785, -0.011, -0.000,  0.000, -0.018, -0.809, -2.411,
	-2.920, -2.384, -2.015, -1.071, -0.008, -0.000,  0.000,  0.162,  0.730, -2.255,
	-0.352,  1.656,  0.740,  0.019,  0.000,  0.000,  0.000,  0.178,  2.249,  1.379,
	 2.937,  2.730,  1.909,  0.227,  0.000,  0.000,  0.000,  0.001,  0.964,  2.763,
	 1.258,  0.391,  0.098,  0.001,  0.000,  0.000,  0.000,  0.000,  0.007,  0.422,
	 0.000,  0.000,  0.000,  0.000,  0.000,  0.000,  0.025,  0.094,  0.100,  0.075,
]
const RELIEF_GRID_PLT2 = [
	 0.032,  0.065,  0.061,  0.031, -0.001, -0.002, -0.000,  0.000, -0.001, -0.005,
	 1.406,  2.451,  2.364,  1.313,  0.500,  0.163,  0.028,  0.001,  0.001,  0.212,
	 2.914,  3.294,  3.096,  2.627,  1.492,  0.226,  0.039,  0.002,  0.018,  0.580,
	 1.325,  3.033,  3.437,  3.392,  1.927,  0.188,  0.003,  0.000,  0.019,  0.305,
	 2.699,  3.198,  3.176,  2.573,  1.144,  0.128,  0.013, -0.001,  0.017,  0.759,
	 1.546,  2.625,  3.149,  2.309,  0.384,  0.061,  0.001,  0.001,  0.057,  0.457,
	 0.296,  1.158,  1.478,  0.743,  0.167,  0.015,  0.000,  0.000,  0.004,  0.025,
	 0.006,  0.019,  0.029,  0.026,  0.011,  0.000,  0.000,  0.000,  0.143,  0.086,
]
# Donor sculpt config transcribed verbatim (DPATTERN_01 §3/§4; pattern.lib):
# k_ravine_1 scale 1 :549568, min/max :549585-549586, Smooth=False :549572;
# plt2 scale 1, min/max :6805-6806.  Smooth passes are NOT emulated — the
# smoothing definition is UNVERIFIED (DPATTERN_01 §5.2, §9 Q2).
const RELIEF_GRID_META = {
	"k_ravine_1": {"scale": 1.0, "min": -2.963627576828003, "max": 3.139820098876953,
		"w": 46, "h": 63, "offset": 2866, "lib": "pattern.lib:549585-549586"},
	"plt2": {"scale": 1.0, "min": -0.07325489819049835, "max": 3.6134116649627686,
		"w": 42, "h": 55, "offset": 2266, "lib": "pattern.lib:6805-6806"},
}
# Staged-loading state: _generate_map runs in 4 chunks so the loading bar can
# repaint between them (menu Start -> playing). Sync setup() just calls them
# back-to-back; the async loader in main.gd awaits a frame between each.
var _st_budget: Dictionary = {}
var _st_mscale: float = 1.0
var _st_forest: PackedFloat32Array = PackedFloat32Array()
var entities: Array = []
var by_id: Dictionary = {}
var next_id := 1
var players: Array = []
var battle_mode := false
var time_s := 0.0
var winner := -1
var rng := RandomNumberGenerator.new()
# P-31: separate stage stream. Donor dogenerate.inc calls SetRandomKey(randkey1)
# before every generation stage (:1100,:1161,:1177,:1213,:1538,:1616,:1772,
# :1909,:1927). The legacy `rng` must stay on one continuous stream for
# byte-identical seed dumps, so stage reseeds land here instead.
var gen_rng := RandomNumberGenerator.new()
const GEN_STAGES := ["terrain", "starts_legacy", "starts", "starts_team", "patterns",
	"forests", "mines", "finish"]
var events: Array = []   # {type, pos, kind} consumed by world/hud each frame
var projectiles: Array = []  # delayed shells/arrows: {pos,target,kind,dmg,splash,owner,t,total}
var corpses: Array = []  # fading dead units for the battlefield look (capped)
var rubble: Array = []  # lingering destroyed-building rubble (capped)
var squads: Dictionary = {}  # squad_id -> {officer, drummer, members, formation, player}
var gates: Array = []
var grid: Dictionary = {}          # Vector2i cell -> Array of entity dicts
const GRID_M := 8.0
# T-PERF-SIM: resource spatial hash. res_nodes are mostly static (trees/rocks/
# deposits), so nearest_res() no longer scans every node per peasant per tick.
# Rebuilt lazily when res_dirty changes; cell size balances bucket count vs
# per-query fan-out. _res_grid_ver tracks the res_dirty value it was built at.
var _res_grid: Dictionary = {}
const RES_GRID_M := 16.0
var _res_grid_ver := -1
# T-PERF-SIM: cached impassable ink rects as [Rect2, id] pairs (see
# _block_rects_ensure). Rebuilt when bld_dirty changes (spawn/finish/destroy),
# which covers every mutation of the set (buildings never move).
var _block_rects: Array = []
var _block_rects_ver := -1
# T-SIM-HOTSPOTS: the same [Rect2, id] pairs bucketed by tile, so a unit only
# tests the handful of rects overlapping its own tile instead of every building
# footprint on the map. Key = x + y*MAP_W (same flat index as _t).
var _block_rects_by_cell: Dictionary = {}
func _block_rects_ensure() -> void:
	if _block_rects_ver == bld_dirty:
		return
	_block_rects.clear()
	_block_rects_by_cell.clear()
	for b in live_blds:
		if b.dead:
			continue
		var r: Rect2 = b.get("block_rect", Rect2())
		if r.has_area():
			var entry := [r, int(b.id)]
			_block_rects.append(entry)
			for c in bld_rect_cells(r):
				var cell: Vector2i = c
				var key := cell.x + cell.y * MAP_W
				if not _block_rects_by_cell.has(key):
					_block_rects_by_cell[key] = []
				(_block_rects_by_cell[key] as Array).append(entry)
	_block_rects_ver = bld_dirty
# T-PERF-SIM: can_place building scan margin. Must exceed the largest
# block_r on the map (gameplay radii are a few metres); 16 m is generous.
const _CANPLACE_BLD_MARGIN := 16.0
var live_units: Array = []
var live_blds: Array = []
var officers: Array = [[], []]
var drummers: Array = [[], []]
var priests: Array = [[], []]
var compact_t := 0.0
var res_dirty := 0
var bld_dirty := 0
var ai_cheat_t := 0.0
var sow_t := 0.0
# T-FIELDS-GFX: per-field regrow state. growth 0..1 mirrors regrow progress
# while hits==0; regrow_t counts up to regrow_time (donor ~60 s seed cycle).
# Auto-regrow runs only for fields with a finished mill within FIELD_MILL_RADIUS.
const FIELD_REGROW_TIME := 60.0
const FIELD_MILL_RADIUS := 18.0
var fields_anim := false
func _blocked_for(e: Dictionary, p: Vector2) -> bool:
	# P-10: water cells hold BLK_WATER and are hard blockers for land units,
	# but a naval entity treats them as its road and land as its wall.
	if _is_naval(e):
		if not _is_water(p):
			return true
	else:
		if is_blocked(p):
			return true
	# A builder must be able to walk over its own unfinished site: the L8
	# true-scale ink box is large enough to trap a peasant that spawned inside
	# it, so ignore the site currently under construction (never a finished
	# building - that keeps the solid-footprint rule intact).
	var build_target: int = 0
	var ord: Dictionary = e.get("order", {})
	if str(ord.get("type", "")) == "build":
		build_target = int(ord.get("target", 0))
	# Buildings are solid 2D blocks: the drawn sprite's ink box stays impassable
	# in every direction, not just the base circle stamped into `blocked`.
	# T-SIM-HOTSPOTS: only the rects registered on the probe's own tile.
	# A point inside a rect is always inside one of bld_rect_cells(rect), so the
	# bucket is a superset of every rect that could contain p; build_target skip
	# and Rect2.has_point are unchanged. Buildings never move between rebuilds.
	_block_rects_ensure()
	# Inline tile_of()'s arithmetic to avoid a Vector2i allocation per probe.
	var cell_key := int(p.x / TILE) + int(p.y / TILE) * MAP_W
	for br in _block_rects_by_cell.get(cell_key, []):
		if build_target != 0 and int(br[1]) == build_target:
			continue
		if (br[0] as Rect2).has_point(p):
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

# P-31: reseed the STAGE stream only. Key = seed + stage slot + generator version
# (inferred port adaptation of SetRandomKey: a per-stage derived key rather than
# the donor's same-key skip-ahead, chosen so the legacy rng never shifts).
func _reseed_stage(stage: String) -> void:
	var si: int = GEN_STAGES.find(stage)
	gen_rng.seed = (int(Data.RANDOM_SEED) + si * 1000003 + int(Data.GENERATOR_VERSION) * 10007) & 0x7fffffff

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
	for pi in players.size():
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
		# T-FOOD-1: depleted mill fields are kept for resow; every other
		# depleted node is dropped. (Wild food no longer spawns on random
		# maps, and old wild nodes must not linger as immortal resow targets.)
		if n.max_hits == 0 or n.hits > 0 or (n.type == "food" and n.has("mill")):
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
		# T-MENU-ROSTER: every player carries an explicit team key. -1 means
		# free-for-all; setup_begin overwrites it from Data.TEAMS when the
		# roster picked real teams. _is_ally() ignores negative teams, so an
		# FFA slot is never mistaken for an ally of another FFA slot.
		"team": -1,
		"farm_cap": 0, "score": 0, "entities": [], "ai_state": {}, "starving": false,
		"famine_t": 0.0, "famine": false,
		"damage_mult": {"sword": 1.0, "pike": 1.0, "bullet": 1.0, "arrow": 1.0, "firearrow": 1.0, "cannonball": 1.0, "cannister": 1.0},
		"gather_mult": {"food": 1.0, "wood": 1.0, "stone": 1.0},
		"hp_mult": 1.0, "prot_bonus": 0,
		"rof_mult": {}, "cost_mult": 1.0, "melee_mult": 1.0, "melee_add": 0,
		"cav_damage_mult": {}, "cav_dmg_add": 0, "cav_prot_bonus": 0,
		"train_speed_mult": 1.0, "art_cost_mult": 1.0, "art_build_mult": 1.0,
		"upgrades": [], "research": {},
		"market_rate": Data.MARKET_RATE}

func setup(mode: String) -> void:
	setup_begin(mode)
	_gen_base()
	_gen_patterns()
	_gen_forests()
	_gen_resources()
	_gen_finish()
	_assign_tileblocks()
	setup_spawns()
	_finalize_mine_tiles()  # start provisioning can add ore nodes after tiles

func _finalize_mine_tiles() -> void:
	# T2GEN P0-1: ore deposits provisioned after _assign_tileblocks (start
	# reach repair) must also get neutral worked ground in their footprint.
	if mine_mask.size() != MAP_W * MAP_H:
		mine_mask.resize(MAP_W * MAP_H)
	for n in res_nodes:
		if str(n.type) in ["gold", "iron", "coal"]:
			_mark_mine_mask(n.pos, 3.0 * TILE)
	if tileblock.size() != MAP_W * MAP_H:
		return
	var g1 := _blk("test8")  # Y08b PORT APPROX: visible worked ground = meadow id; mine_mask/terrain untouched
	for mi in mine_mask.size():
		if mine_mask[mi] != 0:
			tileblock[mi] = g1
	# T2GEN: final 7-tile start keep-clear for forest (some groves are placed
	# after _gen_finish by spawn provisioning).
	var g0 := _blk("test8")  # Y08 PORT APPROX: same normalised meadow id; terrain 2->0 and blocked cleanup unchanged
	for st in map_starts:
		var sc := Vector2(float(st.x) / TILE, float(st.y) / TILE)
		for yy in range(maxi(0, int(sc.y - 16.0)), mini(MAP_H, int(sc.y + 16.0) + 1)):
			for xx in range(maxi(0, int(sc.x - 16.0)), mini(MAP_W, int(sc.x + 16.0) + 1)):
				var ci := _t(xx, yy)
				if Vector2(float(xx) - sc.x, float(yy) - sc.y).length() <= 16.05:
					if terrain[ci] == 2:
						terrain[ci] = 0
					if tileblock.size() == MAP_W * MAP_H and int(tileblock[ci]) != BLK_WATER:
						tileblock[ci] = g0  # Y08b: whole start disc visible as meadow id; water kept
		# Keep every start walkable: stamp relief / collision can otherwise
		# enclose an AI home slot with rock, breaking scan_map reachability.
		for yy in range(maxi(0, int(sc.y - 16.0)), mini(MAP_H, int(sc.y + 16.0) + 1)):
			for xx in range(maxi(0, int(sc.x - 16.0)), mini(MAP_W, int(sc.x + 16.0) + 1)):
				if Vector2(float(xx) - sc.x, float(yy) - sc.y).length() <= 16.0:
					var ui := _t(xx, yy)
					if blocked[ui] != 0:
						set_blocked_tile(xx, yy, false)
					if terrain[ui] == 5:
						terrain[ui] = 0

func setup_begin(mode: String) -> void:
	battle_mode = mode == "battle"
	MAP_W = Data.MAP_W
	MAP_H = Data.MAP_H
	TICK_MAX = Data.TICK_MAX
	Data.load_extra_anim_index()  # P-41: separate nation-unique anim index
	rng.seed = Data.RANDOM_SEED
	terrain.resize(MAP_W * MAP_H)
	blocked.resize(MAP_W * MAP_H)
	height.resize(MAP_W * MAP_H)
	mine_mask.resize(MAP_W * MAP_H)
	for i in terrain.size():
		terrain[i] = 0
		blocked[i] = 0
		height[i] = 0.0
		mine_mask[i] = 0
	nav.configure(MAP_W, MAP_H, TILE)
	nav_version += 1
	# nations come from the menu (Data.PLAYER_NATIONS sids); names follow.
	var pn := Data.PLAYER_NAMES
	var pns: Array = Data.PLAYER_NATIONS if Data.PLAYER_NATIONS is Array else ["ukr", "rus"]
	# P-42: one slot per participant. Opponents 1/2/3 -> 2/3/4 players; the
	# default is still 2 with player 0 human and every other slot AI.
	var count: int = clampi(int(Data.PLAYER_COUNT), 2, Data.MAX_PLAYERS)
	var ai_arr: Array = Data.PLAYER_AI if Data.PLAYER_AI is Array else []
	players = []
	for i in count:
		# Roster UI drives Human/Computer per slot; the i>0 rule is only the
		# fallback for legacy callers with no PLAYER_AI array.
		var is_ai := bool(ai_arr[i]) if i < ai_arr.size() else i > 0
		var pl := new_player(i, _nation_name(i, pn), is_ai)
		pl["nation"] = str(pns[i]) if i < pns.size() else "rus"
		if i < Data.TEAMS.size():
			pl["team"] = int(Data.TEAMS[i])
		players.append(pl)
	objectives = []
	deposits = {}
	for r in Data.RES_NAMES:
		deposits[r] = float(Data.DEPOSITS.get(r, 0.0))
	res_nodes = []
	map_starts = []
	cluster_zones = []
	pattern_stamps = []
	hill_list = []
	# T-PERF-SIM: drop all sim caches for the fresh map (versions alone could
	# coincidentally match the previous game and serve stale buckets/rects).
	_res_grid.clear()
	_res_grid_ver = -1
	_res_grid_src_size = -1
	_block_rects.clear()
	_block_rects_by_cell.clear()
	_block_rects_ver = -1
	_nav_ink_cells.clear()
	_nav_ink_ver = -1
	_sep_bld_ver = -1
	_st_budget = Data.mapgen_budget()
	_st_mscale = clampf(float(MAP_W) / 160.0, 1.0, 2.0)
	_st_forest = PackedFloat32Array()

func setup_spawns() -> void:
	_ensure_start_slots()
	# T-MINES-START-FIX: now that map_starts is FINAL (water snap + appended
	# slots), re-check every hall's guaranteed ore against its real position.
	_ensure_start_ore_clusters(map_starts)
	_spawn_starts()
	_grid_rebuild()
	# Must run AFTER start buildings block tiles: scan's BFS uses the post-spawn
	# blocked map, so an earlier pass would see a larger, wrong reach set.
	_repair_start_reach()

func _nation_name(i: int, pn: Variant) -> String:
	var pns: Array = Data.PLAYER_NATIONS if Data.PLAYER_NATIONS is Array else []
	var sid := str(pns[i]) if pns.size() > i else ""
	if Data.NATIONS.has(sid):
		return str(Data.NATIONS[sid].name)
	if pn is Array and pn.size() > i:
		return str(pn[i])
	return "Player %d" % (i + 1)

# Nation-aware sid for BATTLE_ARMY starting units. Mirrors train_unit()'s
# two-source nation lookup (players[].nation, then Data.PLAYER_NATIONS) with
# bounds guards; read-only, no entity-field or state change. Identity when
# Data.resolve_sid has no mapping (e.g. bav has no NATION_UNITS key).
func _spawn_sid(player: int, sid: String) -> String:
	var nat := ""
	if player >= 0 and player < players.size():
		nat = str(players[player].get("nation", ""))
	if nat == "" and player >= 0 and player < Data.PLAYER_NATIONS.size():
		nat = str(Data.PLAYER_NATIONS[player])
	return Data.resolve_sid(nat, sid)

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
	# T5GEN F4: a rally on a tree/building/rock tile was stored verbatim, so A*
	# snapped its path to a free cell while d_goal still measured the blocked
	# point -> a unit walked forever a metre short.  Store a reachable point.
	b["rally"] = _snap_free_point(pos, {"def": {}, "order": {}, "player": int(b.get("player", -1))})

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

# P-10: deep-water terrain tile. Ships may enter only these tiles; the shore
# sand collar (terrain 4) and all land stay impassable for them.
func _is_water(p: Vector2) -> bool:
	if not in_bounds(p):
		return false
	return int(terrain[_t(tile_of(p).x, tile_of(p).y)]) == 3

func _is_naval(e: Dictionary) -> bool:
	return bool(e.get("def", {}).get("naval", false))

func set_blocked_circle(p: Vector2, r_m: float, value: bool) -> void:
	var t0 := tile_of(p - Vector2(r_m, r_m))
	var t1 := tile_of(p + Vector2(r_m, r_m))
	var changed := false
	for y in range(maxi(0, t0.y), mini(MAP_H, t1.y + 1)):
		for x in range(maxi(0, t0.x), mini(MAP_W, t1.x + 1)):
			var c := Vector2((x + 0.5) * TILE, (y + 0.5) * TILE)
			if c.distance_to(p) <= r_m:
				var v: int = 1 if value else 0
				if blocked[_t(x, y)] != v:
					blocked[_t(x, y)] = v
					changed = true
	if changed:
		nav_version += 1

# Grid cells covered by a building's drawn rectangle.  Returned to A* as
# extra obstacles instead of being stamped into `blocked`, so terrain and
# building-placement checks keep seeing the same grid as before.
func bld_rect_cells(rect: Rect2) -> Array:
	var out: Array = []
	if not rect.has_area():
		return out
	var t0 := tile_of(rect.position)
	var t1 := tile_of(rect.end)
	for y in range(maxi(0, t0.y), mini(MAP_H, t1.y + 1)):
		for x in range(maxi(0, t0.x), mini(MAP_W, t1.x + 1)):
			var tr := Rect2(float(x) * TILE, float(y) * TILE, TILE, TILE)
			if tr.intersects(rect):
				out.append(Vector2i(x, y))
	return out

func _add_res(type: String, pos: Vector2, hits: int, radius: float) -> void:
	var node := {"id": next_id, "kind": "res", "type": type, "pos": pos, "hits": hits,
		"max_hits": hits, "radius": radius}
	if type == "food" and hits > 0:
		node["growth"] = 1.0
		node["regrow_t"] = 0.0
		node["regrow_time"] = FIELD_REGROW_TIME
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
			if str(n.get("type", "")) == "food":
				n["growth"] = 0.0
				n["regrow_t"] = 0.0

func _paint_terrain(pos: Vector2, r_m: float, t: int, feather := 2.5, mark_mine := false) -> void:
	# Soft disc: full paint inside r-feather, then a noisy dithered rim so
	# pads/groves/roads melt into the meadow instead of stamping squares
	# (the donor's plain_*/forest patterns all have organic fringes).
	# mark_mine only tags the same disc in mine_mask; simulation terrain is
	# unchanged, so roads/dirt elsewhere keep their byte-identical behaviour.
	var t0 := tile_of(pos - Vector2(r_m, r_m))
	var t1 := tile_of(pos + Vector2(r_m, r_m))
	for y in range(maxi(0, t0.y), mini(MAP_H, t1.y + 1)):
		for x in range(maxi(0, t0.x), mini(MAP_W, t1.x + 1)):
			var c := Vector2((x + 0.5) * TILE, (y + 0.5) * TILE)
			var d := c.distance_to(pos)
			if d > r_m:
				continue
			if mark_mine:
				# mark the FULL apron disc, including water and the dithered
				# rim: an unmarked rim cell reads as meadow and the detail
				# pass would hand it a test2/test3 blend tile.
				mine_mask[y * MAP_W + x] = 1
			if terrain[y * MAP_W + x] == 3:
				continue
			if feather > 0.0 and d > r_m - feather:
				var edge := (d - (r_m - feather)) / maxf(0.01, feather)
				var n := _noise2(float(x) * 0.9 + 13.0, float(y) * 0.9 - 5.0) * 0.5 + 0.5
				if edge > 1.0 - n * 0.9:
					continue
			terrain[y * MAP_W + x] = t

# T2GEN P0-1: richness ores are added without a mine stamp, so give them the
# same apron mask (no terrain change) or their worked ground would still draw
# a road test2/test3 tile from the detail pass.
func _mark_mine_mask(pos: Vector2, r_m: float) -> void:
	var t0 := tile_of(pos - Vector2(r_m, r_m))
	var t1 := tile_of(pos + Vector2(r_m, r_m))
	for y in range(maxi(0, t0.y), mini(MAP_H, t1.y + 1)):
		for x in range(maxi(0, t0.x), mini(MAP_W, t1.x + 1)):
			var c := Vector2((x + 0.5) * TILE, (y + 0.5) * TILE)
			if c.distance_to(pos) <= r_m:
				mine_mask[y * MAP_W + x] = 1

# T-MINES-PLACE: clear the worked-ground apron of a deposit that is relocated
# by _ensure_start_ore_clusters(), so an abandoned mine site stops drawing as a
# fresh dirt pad. Paired with _mark_mine_mask() at the destination.
func _clear_mine_mask(pos: Vector2, r_m: float) -> void:
	if mine_mask.size() != MAP_W * MAP_H:
		return
	var t0 := tile_of(pos - Vector2(r_m, r_m))
	var t1 := tile_of(pos + Vector2(r_m, r_m))
	for y in range(maxi(0, t0.y), mini(MAP_H, t1.y + 1)):
		for x in range(maxi(0, t0.x), mini(MAP_W, t1.x + 1)):
			var c := Vector2((x + 0.5) * TILE, (y + 0.5) * TILE)
			if c.distance_to(pos) <= r_m:
				mine_mask[y * MAP_W + x] = 0

func _scatter_forest(center: Vector2, count: int, spread: float) -> void:
	for i in count:
		var p := center + Vector2(rng.randf_range(-spread, spread), rng.randf_range(-spread, spread))
		if not in_bounds(p) or is_blocked(p):
			continue
		# trees grow on grass/meadow/dirt only â€” never on rock, sand or water
		# (covers hills and lake shores whatever the placement order)
		var tt: int = terrain[_t(int(p.x / TILE), int(p.y / TILE))]
		if tt != 0 and tt != 1 and tt != 2:
			continue
		# never plant into quarries, mine sites or fields: clusters stay pure
		# (the managed park around starts is exempt â€” groves belong there)
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

# Apply the donor's stamped pattern masks. Each stamp already passed the
# donor _misc_CheckStandPattern footprint test against gPatternMask, so
# clusters are discrete and never merge; this replaces blob placement.
func _gen_patterns() -> void:
	_reseed_stage("patterns")  # P-31 / dogenerate.inc:1909 pattern pass
	# _gen_base already built this (relief stamps must shape height before the
	# collision pass).  Fall back only for a direct _gen_patterns call.
	var result: Dictionary = _pattern_build
	if result.is_empty():
		result = C3PatternGen.build(MAP_W, MAP_H, int(Data.RANDOM_SEED),
			map_starts, terrain, 3, str(Data.BIOME), str(Data.RELIEF), str(Data.RICHNESS))
	pattern_stamps = result.get("stamps", [])
	# T2GEN density gate telemetry (map_meta is emitted by --dump-map).
	var _kind_counts := {}
	for _s0 in pattern_stamps:
		var _sk := str((_s0 as Object).kind)
		_kind_counts[_sk] = int(_kind_counts.get(_sk, 0)) + 1
	map_meta["stamp_counts"] = _kind_counts
	# Start keep-clear in world metres (RELIEF-1: no forest inside 7 tiles).
	var start_pts: Array = []
	for _sv in map_starts:
		start_pts.append(_sv as Vector2)
	var ext := 0.0
	for s in pattern_stamps:
		var st: Object = s
		var kind := str(st.kind)
		var cx: int = int(st.x)
		var cy: int = int(st.y)
		var cells: Array = st.cells
		var cpos := Vector2((float(cx) + 0.5) * TILE, (float(cy) + 0.5) * TILE)
		var painted_cells: Array = []
		var forest_nodes_here := 0
		# P-46: the scaled donor cells are sparse (*..*..*), so painting raw
		# cells makes thousands of one-tile flecks. Paint a FILLED contiguous
		# core disc sized from the stamp extent instead (no rng consumed).
		if kind == "forest":
			var cext := 0.0
			for c0 in cells:
				var cc0: Vector2i = c0
				cext = maxf(cext, float(maxi(abs(cc0.x), abs(cc0.y))) * TILE)
			# T2GEN P1-3: paint the scaled donor footprint instead of throwing
			# it away.  Filled convex core from the stamp extent; still bounded
			# so a giant pinefir mask cannot blanket the map.  Water/sand/rock
			# guards and the 7-tile start keep-clear below are unchanged.
			# T2GEN P1-3 (new gate): many donor stamps with a moderate core.
			# 8-14 tile radius keeps each patch in the 170-1228-cell mean band
			# while ~100 stamps lift coverage into the donor 15-48% envelope.
			var size_k := clampf(float(MAP_W) / 320.0, 0.60, 1.0)
			var core_r: float = clampf(cext * 0.25, 14.0 * TILE, 22.0 * TILE) * size_k
			var steps: int = ceili(core_r / TILE)
			var tx0: int = maxi(0, int(cpos.x / TILE) - steps)
			var tx1: int = mini(MAP_W - 1, int(cpos.x / TILE) + steps)
			var ty0: int = maxi(0, int(cpos.y / TILE) - steps)
			var ty1: int = mini(MAP_H - 1, int(cpos.y / TILE) + steps)
			for cy2 in range(ty0, ty1 + 1):
				for cx2 in range(tx0, tx1 + 1):
					var ii2 := _t(cx2, cy2)
					var tt2: int = terrain[ii2]
					if tt2 == 3 or tt2 == 4 or tt2 == 5:
						continue
					var p2 := Vector2((float(cx2) + 0.5) * TILE, (float(cy2) + 0.5) * TILE)
					if p2.distance_to(cpos) > core_r:
						continue
					var in_start_ring := false
					for sp in start_pts:
						if p2.distance_to(sp) < 7.0 * TILE:
							in_start_ring = true
							break
					if in_start_ring:
						continue
					terrain[ii2] = 2
		for c in cells:
			var cc: Vector2i = c
			var tx: int = cx + cc.x
			var ty: int = cy + cc.y
			if tx < 0 or ty < 0 or tx >= MAP_W or ty >= MAP_H:
				continue
			painted_cells.append([tx, ty])
			var ii := _t(tx, ty)
			if terrain[ii] == 3 or terrain[ii] == 4:
				continue
			var dc := Vector2(float(tx - cx), float(ty - cy)).length()
			match kind:
				"forest":
					# Sod is painted as one contiguous core disc above. Preserve
					# the ORIGINAL short-circuit exactly: once the cap is hit no
					# further randf() is drawn. Calling randf()
					# unconditionally shifted the whole downstream RNG stream
					# (stone stamps moved 27.7 -> 39.2 tiles, reach 3/3 -> 1/3).
					# T-FOREST-DENSE: raise the per-cell fill probability 0.10 ->
					# 0.30 and the cap 10 -> 14 so each donor mask's footprint
					# reads as a PACKED grove instead of sparse singles. Same
					# one-draw-per-cell rule, just a higher threshold; the cap
					# is now reached in fewer iterations, so the downstream rng
					# stream shifts (deterministic for a fixed seed) but no
					# extra draws are introduced. See app/tests/t_forest_dense.gd.
					if forest_nodes_here < 14 and rng.randf() < 0.30:
						var wp := Vector2((float(tx) + 0.5) * TILE, (float(ty) + 0.5) * TILE)
						# T2GEN: keep new forest wood out of quarry/mine
						# clearings so scan purity/clear stay at 100%.
						var clash := false
						for nr in res_nodes:
							if nr.type != "wood" and nr.pos.distance_to(wp) < 4.0 * TILE:
								clash = true
								break
						if not clash:
							_add_res("wood", wp, 60, 0.7)
							forest_nodes_here += 1
				"tile":
					pass  # donor tls_* are thin decals, not terrain recolour
				"stone":
					# small pale quarry scar, never a whole-pattern grey wash
					if dc <= 3.2:
						terrain[ii] = 1
					if dc <= 1.6:
						terrain[ii] = 5
				"hill":
					# B03-RELIEF: height-only relief. The old terrain[ii]=5 here
					# painted donor hill footprints as ROCK ART (the concentric
					# maze the owner reported); relief HEIGHT is already written
					# by _shape_stamp_relief() in _gen_base (donor grid or the
					# analytic fallback), so no post-collision height write and
					# no terrain paint is needed. No rng draw in this branch, so
					# removing the paint cannot shift any downstream stream.
					pass
				"decor":
					if rng.randf() < 0.10:
						_add_res("bush", Vector2((float(tx) + 0.5) * TILE,
							(float(ty) + 0.5) * TILE), 0, 0.3)
		match kind:
			"stone":
				# a handful of quarry stones per stamped footprint
				for _i in rng.randi_range(4, 7):
					if painted_cells.is_empty():
						break
					var pc: Array = painted_cells[rng.randi_range(0, painted_cells.size() - 1)]
					var pp := Vector2((float(pc[0]) + 0.5) * TILE, (float(pc[1]) + 0.5) * TILE)
					if not is_blocked(pp):
						_add_res("stone", pp, 80, 0.9)
				_clear_trees(cpos, 5.0 * TILE)
			"mine":
				# T-MINES-FIX: pattern_gen owns the footprint-safe layout, but
				# the post-build collision pass can still turn a stamp
				# centre into steep rock. Nudge to the nearest open, footprint-
				# clear tile instead of DROPPING the deposit: the richness stamp
				# target is the count authority, so every stamp must be realised.
				# Keep the stamp in sync so it stays the authoritative footprint.
				var mp := cpos
				if is_blocked(mp) or not _ore_spot_clear(mp):
					var nudged := false
					for rr in [1, 2, 3, 4, 5, 6, 8, 10, 12, 16]:
						for k in 16:
							var a := TAU * float(k) / 16.0 + float(rr) * 0.31
							var q := cpos + Vector2(cos(a), sin(a)) * float(rr) * TILE
							if not in_bounds(q) or is_blocked(q):
								continue
							if int(terrain[_t(tile_of(q).x, tile_of(q).y)]) == 3:
								continue
							if not _ore_spot_clear(q):
								continue
							var tq := tile_of(q)
							st.set("x", tq.x)
							st.set("y", tq.y)
							mp = Vector2((float(tq.x) + 0.5) * TILE, (float(tq.y) + 0.5) * TILE)
							nudged = true
							break
						if nudged:
							break
					if not nudged:
						# No open tile nearby: still realise the deposit on its
						# stamped site so the richness count never changes.
						mp = cpos
				_add_res(str(st.res), mp, 0, 0.0)
				_paint_terrain(mp, 3.0 * TILE, 1, 2.5, true)
				_clear_trees(mp, 6.0 * TILE)
		for c in cells:
			var cc: Vector2i = c
			ext = maxf(ext, float(maxi(abs(cc.x), abs(cc.y))) * TILE)
		if kind == "forest" or kind == "stone":
			_claim_cluster(cpos, maxf(4.0 * TILE, ext), 0.0)

func _generate_map() -> void:
	_gen_base()
	_gen_patterns()
	_gen_forests()
	_gen_resources()
	_gen_finish()
	# donor TextureMap -> SmoothTiles -> SmoothForestBorders.
	_assign_tileblocks()

func _sample_relief_grid(grid: Array, u: float, v: float) -> float:
	# PORT APPROXIMATION — bilinear sample of a donor-derived 8x10 block-mean
	# table (DPATTERN_01 Appendix A1/A2, :595-600).  u,v are 0..1 over the
	# stamp footprint; file row order kept (row flip UNVERIFIED, §9 Q3).
	var fx := clampf(u, 0.0, 1.0) * float(RELIEF_GRID_W - 1)
	var fy := clampf(v, 0.0, 1.0) * float(RELIEF_GRID_H - 1)
	var ix := int(fx)
	var iy := int(fy)
	var jx := mini(ix + 1, RELIEF_GRID_W - 1)
	var jy := mini(iy + 1, RELIEF_GRID_H - 1)
	var tx := fx - float(ix)
	var ty := fy - float(iy)
	var a: float = grid[iy * RELIEF_GRID_W + ix]
	var b: float = grid[iy * RELIEF_GRID_W + jx]
	var c: float = grid[jy * RELIEF_GRID_W + ix]
	var d: float = grid[jy * RELIEF_GRID_W + jx]
	return lerpf(lerpf(a, b, tx), lerpf(c, d, tx), ty)


func _shape_stamp_relief() -> void:
	# Donor relief is STAMPED multi-cell patterns (dogenerate.inc stage 9), not
	# analytic domes.  The footprints are the real donor .pattern masks exported
	# into donor_patterns.json; no shape is invented here.  RELIEF-LIVE-FIX-01:
	# where the stamp carries a decoded donor id (plt2 / k_ravine_1), the HEIGHT
	# now comes from that donor's coarse grid too (DPATTERN_01 Appendix A,
	# labelled PORT APPROXIMATION).  The analytic radial/taper profile remains
	# ONLY as the fallback for stamps with no decoded donor grid.  Called
	# strictly BEFORE the collision/cliff pass so every newly steep tile becomes
	# rock + blocked (closes the P-47 ordering defect).
	var relief_grid_candidates := 0
	var relief_grid_cells := 0
	_relief_donor_mask = PackedByteArray()
	_relief_donor_mask.resize(MAP_W * MAP_H)
	_relief_stamp_mask = PackedByteArray()
	_relief_stamp_mask.resize(MAP_W * MAP_H)
	# Buildable ring: a stamp CENTRE may sit outside the pattern-gen keep-clear
	# while its 48-100-tile footprint still reaches a town.  Flatten that ring
	# here (before collision) so no start/town/build spot is ever steepened or
	# blocked by relief - this is the donor's C1/C2/C3 keep-clear contract.
	var map_scale := float(MAP_W) / C3PatternGen.DONOR_UNITS
	var protect := maxf(C3PatternGen.CIRCLE2.x, C3PatternGen.CIRCLE2.y) * map_scale * 1.5
	var near_start := PackedByteArray()
	near_start.resize(MAP_W * MAP_H)
	for sv0 in map_starts:
		var v0: Vector2 = sv0
		var sx0 := v0.x / TILE
		var sy0 := v0.y / TILE
		for y0 in range(maxi(0, int(sy0 - protect)), mini(MAP_H, int(sy0 + protect) + 1)):
			for x0 in range(maxi(0, int(sx0 - protect)), mini(MAP_W, int(sx0 + protect) + 1)):
				if Vector2(float(x0) - sx0, float(y0) - sy0).length() <= protect:
					near_start[y0 * MAP_W + x0] = 1
					# B03-RELIEF: the start keep-clear ring may border a relief
					# terrace; suppress rock ART on the step at that boundary too.
					_relief_stamp_mask[y0 * MAP_W + x0] = 1
	for sv in (_pattern_build.get("stamps", []) as Array):
		var st: Object = sv
		var kind := str(st.kind)
		# RELIEF-LIVE-FIX-01: donor id -> donor-derived coarse grid.  Only ids
		# with a decoded window in DPATTERN_01 are eligible; no id is invented.
		# k_ravine_1 is included for completeness but is not reachable from
		# donor_patterns.json / pattern_gen.gd recipes (RELIEF-02 §5, BLOCKED).
		var donor_name := str(st.get("name"))
		var donor_grid: Array = []
		var donor_meta: Dictionary = {}
		if donor_name == "plt2":
			donor_grid = RELIEF_GRID_PLT2
			donor_meta = RELIEF_GRID_META["plt2"]
		elif donor_name == "k_ravine_1":
			donor_grid = RELIEF_GRID_K_RAVINE_1
			donor_meta = RELIEF_GRID_META["k_ravine_1"]
		if not donor_grid.is_empty():
			relief_grid_candidates += 1
		var amp := 0.0
		var edge := 0.0
		var rim_tiles := 3.0
		var is_ravine := false
		match kind:
			"plateau":
				# T2GEN P1-4: 8-tile rim gave ~17% land at h>=2.9; 6 tiles
				# widens the full-amplitude top into the 19-21% donor band.
				amp = RELIEF_PLATEAU; edge = 0.97; rim_tiles = 6.0
			"plain":
				amp = 0.45; edge = 0.97; rim_tiles = 8.0
			"mountain":
				amp = RELIEF_PLATEAU; edge = 0.78; rim_tiles = 8.0
			"hill":
				amp = RELIEF_HILL; edge = 0.80; rim_tiles = 8.0
			"ravine":
				amp = RELIEF_RAVINE; is_ravine = true; rim_tiles = 3.0
			_:
				continue
		var cells: Array = st.cells
		if cells.is_empty():
			continue
		# T2GEN P1-4: hill relief must follow the DONOR MASK, not just its bbox
		# (hill_ridge.md P5/C5).  Keep the occupied scaled cells as a set; a
		# 1-tile dilation below closes the mask's ~30-40% porosity so the ridge
		# stays a continuous elongated outline instead of isolated spikes.
		var hill_occ: Dictionary = {}
		if kind == "hill":
			for hc in cells:
				var hcc: Vector2i = hc
				hill_occ[str(hcc.x) + "," + str(hcc.y)] = true
		var ex := 0
		var ey := 0
		for c in cells:
			var cc: Vector2i = c
			ex = maxi(ex, absi(cc.x))
			ey = maxi(ey, absi(cc.y))
		var cx: int = int(st.x)
		var cy: int = int(st.y)
		var hx := maxf(1.0, float(ex))
		var hy := maxf(1.0, float(ey))
		var half_long := maxf(hx, hy)
		var half_short := minf(hx, hy)
		var rim := rim_tiles / half_short
		var x_long := hx >= hy
		var x0 := maxi(0, cx - ex - 1)
		var x1 := mini(MAP_W - 1, cx + ex + 1)
		var y0 := maxi(0, cy - ey - 1)
		var y1 := mini(MAP_H - 1, cy + ey + 1)
		for y in range(y0, y1 + 1):
			for x in range(x0, x1 + 1):
				var i := _t(x, y)
				if terrain[i] == 3 or terrain[i] == 4 or near_start[i] != 0:
					continue
				if not donor_grid.is_empty():
					# PORT APPROXIMATION (donor engine blend UNVERIFIED,
					# DPATTERN_01 §5.2): h = clamp(h_base + grid*Scale + Offset,
					# HeightFieldMin, HeightFieldMax).  Offset is 0 for these two
					# patterns; Smooth is not modelled (definition UNVERIFIED).
					# The 8x10 table is mapped over the scaled donor footprint
					# bbox; extent/placement are port approximations.
					# Z2 §1.4 no-op tidy: the PORT ±2.964 bound is folded into
					# the clamp bounds above (maxf/minf), so the composite loop
					# applies no second clamp to donor cells.
					var gu := 0.5 + float(x - cx) / (2.0 * hx)
					var gv := 0.5 + float(y - cy) / (2.0 * hy)
					var gv0 := _sample_relief_grid(donor_grid, gu, gv)
					var gscale: float = donor_meta.get("scale", 1.0)
					var gmin: float = donor_meta.get("min", RELIEF_RAVINE)
					var gmax: float = donor_meta.get("max", RELIEF_PLATEAU)
					height[i] = clampf(height[i] + gv0 * gscale, maxf(gmin, RELIEF_RAVINE), minf(gmax, RELIEF_PLATEAU))
					_relief_donor_mask[i] = 1
					_relief_stamp_mask[i] = 1
					relief_grid_cells += 1
					continue
				if kind == "hill":
					var hx0 := x - cx
					var hy0 := y - cy
					var on_mask := hill_occ.has(str(hx0) + "," + str(hy0))
					if not on_mask:
						for dy0 in range(-1, 2):
							for dx0 in range(-1, 2):
								if hill_occ.has(str(hx0 + dx0) + "," + str(hy0 + dy0)):
									on_mask = true
									break
							if on_mask:
								break
					if not on_mask:
						continue
				var f := 0.0
				if is_ravine:
					# Open-ended gully along the donor footprint's long axis:
					# flat cut bottom, 3-tile near-vertical walls, tapered ends
					# so the negative relief never encloses a start.
					var u := (float(x - cx) / half_long) if x_long else (float(y - cy) / half_long)
					var v := (float(y - cy) / half_short) if x_long else (float(x - cx) / half_short)
					if absf(u) > 1.0 or absf(v) > 1.0:
						continue
					var wall := clampf((0.30 + rim - absf(v)) / rim, 0.0, 1.0)
					var ends := clampf((1.0 - absf(u)) / rim, 0.0, 1.0)
					f = wall * ends
				else:
					var nx := float(x - cx) / hx
					var ny := float(y - cy) / hy
					var d := sqrt(nx * nx + ny * ny)
					if d > 1.0:
						continue
					# Plateau/plain have a wide flat top (edge~0.97); hills and
					# mountains have a broad elongated crest (8-tile rim: smooth
					# enough to stay walkable, unlike the ravine's cut walls).
					f = clampf((edge - d) / rim, 0.0, 1.0)
				if f <= 0.0:
					continue
				# T2GEN P1-4: donor relief is a single set-height mask whose
				# ceiling is cPlateauHeight=+2.964 (generatemap.inc:4/569-574).
				# The old unclamped += let overlapping stamps stack to 7.25
				# (plateau.md P10).  Clamp the additive result to the donor
				# [-2.964, +2.964] band; ravine's negative amp hits the floor.
				height[i] = clampf(height[i] + amp * f, RELIEF_RAVINE, RELIEF_PLATEAU)
				_relief_stamp_mask[i] = 1
	# B03-RELIEF: dilate one cell (8-neighbourhood). The gradient pass sees a
	# |dh|>0.5 STEP from an un-stamped cell adjacent to a relief terrace; that
	# outside cell would otherwise still be painted as a rock-ART ring. Only the
	# mask grows - no height, blocked, terrain, rng or tileblock write here.
	var _rm_dil := PackedByteArray()
	_rm_dil.resize(MAP_W * MAP_H)
	for y in MAP_H:
		for x in MAP_W:
			if _relief_stamp_mask[_t(x, y)] == 0:
				continue
			for dy in range(-1, 2):
				for dx in range(-1, 2):
					var nx: int = x + dx
					var ny: int = y + dy
					if nx >= 0 and ny >= 0 and nx < MAP_W and ny < MAP_H:
						_rm_dil[_t(nx, ny)] = 1
	for ri in _rm_dil.size():
		if _rm_dil[ri] != 0:
			_relief_stamp_mask[ri] = 1
	# RELIEF-LIVE-FIX-01 audit ledger (dump meta only; no height/tile effect).
	map_meta["relief_grid"] = {
		"label": "PORT APPROXIMATION — donor engine blend UNVERIFIED (DPATTERN_01 §5.2)",
		"tables": ["k_ravine_1", "plt2"],
		"source": "DPATTERN_01 Appendix A1/A2 — 8x10 block means, debug/preview aids only",
		"candidates": relief_grid_candidates,
		"applied_cells": relief_grid_cells,
		"blend": "h = clamp(h_base + donor8x10*HeightFieldScale, HeightFieldMin, HeightFieldMax)",
		"clamp_reconcile": "donor Min/Max at stamp; single PORT +-2.964 bound on donor cells (donor clamp UNVERIFIED)",
		"row_flip": "UNVERIFIED",
	}

func _gen_base() -> void:
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
	var budget: Dictionary = _st_budget if not _st_budget.is_empty() else Data.mapgen_budget()
	_st_budget = budget
	_reseed_stage("terrain")  # P-31 / dogenerate.inc:1538
	if Data.generator_gate(61):  # dogenerate.inc:1093 legacy start path
		_reseed_stage("starts_legacy")
	# donor scales pattern frequency with map size (_misc_GetFreePatternMaskModifier).
	# The port's pattern radii were tuned at 160 tiles; scale them to this map.
	var mscale: float = _st_mscale
	# P-31 / dogenerate.inc:1547: pre-91 builds fall back when the terrain id is
	# unknown; current generator (91) reads Data.MAP_TYPES directly.
	var mtype := str(Data.MAP_TYPE)
	if Data.generator_gate(91) and not Data.MAP_TYPES.has(mtype):
		mtype = "land"
	var mg: Dictionary = C3MapGen.build(mtype, int(Data.RANDOM_SEED),
		MAP_W, MAP_H, TILE, str(Data.QUALITY))
	height = mg.get("height", PackedFloat32Array())
	map_meta = {"type": str(Data.MAP_TYPE), "quality": str(Data.QUALITY),
		"mask": mg.get("mask", {}), "mask_water": float(mg.get("water", 0.0))}
	var forest_field: PackedFloat32Array = mg.get("forest", PackedFloat32Array())
	_st_forest = forest_field
	var starts: Array[Vector2] = []
	for sv in mg.get("starts", []):
		starts.append(sv as Vector2)
	if starts.size() < 2:
		starts = _start_positions(2)
	map_starts = starts
	_reseed_stage("starts")  # P-31 / dogenerate.inc:1616
	if not Data.generator_gate(78):  # dogenerate.inc:1175 (>77) team-point stream
		_reseed_stage("starts_team")
	cluster_zones = []
	# relief domes = the donor's hills_dark/hills_light/mountains pattern passes.
	# Donor cHillHeight = 1.317 (half of the 2.964 plateau).
	# P-19 relief: plains (default) is exactly 1.0x / +0 domes -> legacy stream.
	var relief_scale: float = float(Data.RELIEF_SCALE.get(str(Data.RELIEF), 1.0))
	var relief_domes: int = int(Data.RELIEF_DOME_DELTA.get(str(Data.RELIEF), 0))
	hill_list = []
	for _hi in int(budget.get("domes", 3)) + relief_domes:
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
				height[i] += (1.0 - dd) * (1.0 - dd) * (2.964 / 2.25) * relief_scale
	# base tile roles from the donor height thresholds (guides shore/collision):
	# h < -0.25 = water plane, -0.25..-0.1 = wet sand collar, above = meadow.
	# Meadow mottling comes from the donor tile_low/highground bitmaps
	# (_apply_detail_pass), NOT from random dirt blobs: the gauss masks carry
	# no broad/alpha channel, so the original paints dirt only via plain_*
	# patterns and roads. A few small soft plain blobs break the monotony.
	for y in MAP_H:
		for x in MAP_W:
			var i := _t(x, y)
			var hh: float = height[i]
			var t := 0
			if hh < C3MapGen.WATER_DEEP:
				t = 3
				set_blocked_tile(x, y, true)
			elif hh < C3MapGen.WATER_SHORE:
				# T2GEN P0-2: donor texturemap.inc:31 wet-sand gate is -0.1
				# (was -0.05 -> a 0.20-unit, +33%-wide band).  This LAND-side
				# strip is the ~1-cell oriented sandsea rim; _shore_tile_for()
				# picks sandsea1/5/6 by the height-gradient sector.
				t = 4
			terrain[i] = t
	# No random plain_* dirt blobs: the donor paints worked ground only under
	# buildings/quarries/mines (stamped patterns), never as free-floating patches.
	# T2GEN P0-2: the old pass flipped EVERY water cell touching land to
	# terrain=4/walkable, erasing the shallow-water cells the shader needs for
	# the wash/foam band (shore_sand.md D2/D8; shore_water_transition.md G2).
	# The donor's sandsea rim is an oriented ~1-cell band: the LAND-side strip
	# above (height -0.25..-0.1) now supplies it, with sandsea1/5/6 chosen by
	# _shore_tile_for().  Coastline water cells stay terrain=3 (coverage=1 for
	# the water overlay) and keep their BLK_WATER tile, preserving tileflow.
	# Start buildability / RELIEF-1 flatten ring are unchanged (no blocked[]
	# writes here; the collision and near_start passes below still apply).
	# donor stage 9: stamp relief BEFORE collision.  The build result is cached
	# so _gen_patterns paints exactly the same footprints (no extra RNG draws).
	_pattern_build = C3PatternGen.build(MAP_W, MAP_H, int(Data.RANDOM_SEED),
		map_starts, terrain, 3, str(Data.BIOME), str(Data.RELIEF), str(Data.RICHNESS))
	_shape_stamp_relief()
	# T2GEN P1-4: the donor encodes relief as ONE height value per cell from the
	# mask R channel (ceiling +2.964, floor -2.964).  The port's three additive
	# sources (mask base, analytic domes, stamp relief) stacked to 8.07 at
	# 13,068 cells.  Clamp the land composite to the donor band so max<=2.964,
	# stacking cells = 0, and every saturated plateau cell reads exactly 2.964
	# (flat fraction 24.91% -> ~55-65%).  Water depth is left untouched.
	for hi in height.size():
		if terrain[hi] == 3:
			continue
		if _relief_donor_mask[hi] != 0:
			# RELIEF-LIVE-FIX-01 clamp reconciliation (Z2 §1.4 no-op tidy).
			# The single PORT ±2.964 bound is folded into the stamp clamp
			# (maxf(gmin, RELIEF_RAVINE), minf(gmax, RELIEF_PLATEAU)), so no
			# second clamp runs here; donor cells still skip the 0.03 dither
			# cap below (no dither-as-shape on donor cells).  The donor clamp
			# itself is UNVERIFIED — generatemap.inc has no height clamp
			# (HEIGHT-GEN-DEEP-01 §5.4/§8 Q1).  cMaxHeight=2.96 is a
			# tile-class constant.
			continue
		# Donor heights are quantised from an 8-bit mask R channel.  Dither the
		# cap by ~2 R-levels so ~60% of saturated plateau cells read exactly
		# +2.964 (donor flat fraction 55-65%) while the rest stay just below it.
		var hqx := float(hi % MAP_W)
		var hqy := float(hi / MAP_W)
		var hq := _noise2(hqx * 0.31 + 3.0, hqy * 0.31 - 7.0) * 0.5 + 0.5
		var hcap := RELIEF_PLATEAU if hq < 0.58 else RELIEF_PLATEAU - 0.03
		height[hi] = clampf(height[hi], RELIEF_RAVINE, hcap)
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
				# B03-RELIEF / L03 rank-1: this pass is COLLISION ONLY. It no
				# longer writes terrain=5 at all: the |dh| test fires on the
				# port's quantised 8-bit base-mask terraces (mapgen.gd:63-85)
				# and the clamp bands (game.gd:1069/1117/1254-1274), most of
				# which lie OUTSIDE _relief_stamp_mask. Every such terrace became
				# a ring of grey rock ART (the owner's concentric maze), and
				# _apply_shore_cliffs/_cliff_tile_for then painted several nested
				# grey bands from the multiple height gates. Real cliff art still
				# comes from genuine stone/hill stamps and the shore/cliff tables.
				# set_blocked_tile stays for EVERY steep cell, so collision,
				# walkability, start protection and blocked[] are unchanged.
				# _relief_stamp_mask is retained (harmless, reusable data).
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

func _gen_forests() -> void:
	_reseed_stage("forests")  # P-31: forest stage (donor forest_* pattern pass)
	# Global forests are now stamped by _gen_patterns() from the donor's real
	# forest_* pattern masks. Only the two sacred groves per start remain here
	# (donor SetupStartingResources keeps firewood inside cCircle2/3).
	var mscale: float = _st_mscale
	var starts: Array[Vector2] = []
	for sv in map_starts:
		starts.append(sv as Vector2)
	for st in starts:
		_paint_terrain(st + Vector2(7, -7) * TILE * mscale, 4.5 * TILE * mscale, 2)
		# T-FOREST-DENSE: tighten the two sacred groves (spread 5/4 -> 3.5/3
		# tiles) and raise counts ~30% so they read as clumps, not stragglers.
		# Same number of randf_range draws per candidate (count only), no new
		# RNG calls; the tighter spread keeps trees inside the painted terrain.
		_scatter_forest(st + Vector2(7, -7) * TILE * mscale, int(34.0 * mscale), 3.5 * TILE * mscale)
		_paint_terrain(st + Vector2(-8, 5) * TILE * mscale, 4.0 * TILE * mscale, 2)
		_scatter_forest(st + Vector2(-8, 5) * TILE * mscale, int(23.0 * mscale), 3.0 * TILE * mscale)

func _gen_resources() -> void:
	_reseed_stage("mines")  # P-31 / dogenerate.inc:1772 SetupMines
	# Quarries, mines, hills, forest belts and decor are all stamped from
	# donor pattern masks in _gen_patterns(). Left here: richness ore scaling.
	# T-FOOD-1 (owner rule): a random skirmish map starts with ZERO food
	# resource nodes. No seed-wheat strips, no straggler fields, no wild
	# berries. Food comes strictly through the mill cycle: a finished mill
	# sows field rings (_sow_field_ring / _on_building_finished) and peasants
	# resow depleted fields (cmd_resow / _tick_field_growth).
	var starts: Array[Vector2] = []
	for sv in map_starts:
		starts.append(sv as Vector2)
	_apply_richness_ores(starts)
	# T-MINES-PLACE: count-preserving near-start ore guarantee (med/normal only).
	_ensure_start_ore_clusters(starts)

# P-19 richness: donor Minerals changes how many ore deposits a start ring gets.
# The amount multiplier is donor-sourced (RC_TERRAIN §2.1 / GUIDE4 L6); the exact
# +/-1 node-per-start count delta is INFERRED (donor publishes no per-count table).
func _apply_richness_ores(starts: Array[Vector2]) -> void:
	var delta: int = int(Data.RICHNESS_ORE_DELTA.get(str(Data.RICHNESS), 0))
	if delta == 0:
		return
	if delta > 0:
		var kinds := ["gold", "iron", "coal"]
		for st in starts:
			for k in delta:
				# T-MINES-FIX: prefer the original 11-tile sector spot, but keep
				# searching (no shared rng draw) until a footprint-clear site is
				# found so the richness count is preserved without overlap.
				for _try in 24:
					var a := TAU * (float(k) + 0.31) / 3.0 + float(_try) * 0.26
					var dst := 11.0 + float(_try % 6) * 2.0
					var p: Vector2 = st + Vector2(cos(a), sin(a)) * (dst * TILE)
					if not in_bounds(p) or is_blocked(p):
						continue
					if int(terrain[_t(tile_of(p).x, tile_of(p).y)]) == 3:
						continue
					if not _ore_spot_clear(p):
						continue
					_add_res(kinds[k % 3], p, 0, 0.0)
					_mark_mine_mask(p, 3.0 * TILE)
					break
		return
	# low: retire the nearest ore node to each start (deterministic, no rng draw)
	for st in starts:
		for _k in absi(delta):
			var best := -1
			var bd := 1.0e9
			for i in res_nodes.size():
				var n: Dictionary = res_nodes[i]
				if int(n.get("max_hits", -1)) != 0 or str(n.type) not in ["gold", "iron", "coal"]:
					continue
				var d: float = n.pos.distance_to(st)
				if d < bd:
					bd = d
					best = i
			if best >= 0:
				var n2: Dictionary = res_nodes[best]
				set_blocked_circle(n2.pos, n2.radius, false)
				by_id.erase(n2.id)
				res_nodes.remove_at(best)

# T-MINES-FIX: single footprint test shared by every game.gd path that places
# or relocates an ore deposit (richness, fallback net, extra-start provisioning,
# reach repair).  `ignore_id` lets a relocation ignore its own old node.
func _ore_spot_clear(p: Vector2, ignore_id: int = -1) -> bool:
	for n in res_nodes:
		if int(n.id) == ignore_id:
			continue
		if str(n.type) in ["gold", "iron", "coal"]:
			if n.pos.distance_to(p) <= MINE_MIN_SEP_TILES * TILE:
				return false
	return true

# T-MINES-START-FIX: per-start ore proximity safety net, NORMAL richness only.
# pattern_gen.gd OWNS mine placement: its final authoritative pass guarantees
# gold+iron+coal in the 6..14 tile band (worst case 16) of the start tile it was
# given.  That build happens BEFORE game.gd snaps starts to land and appends
# extra starts, so this net re-checks against the FINAL map_starts (the exact
# town-hall anchors) and tightens service to MINE_SERVED_R (16 tiles).  It also
# covers nodes nudged away from a stamped site by the collision pass and the
# T-MINES-PLACE fallback test.  Same footprint rule as pattern_gen
# (_ore_spot_clear / MINE_MIN_SEP_TILES): a relocation never reintroduces
# overlapping aprons, and only RELOCATES an existing deposit - count is intact.
# Low/high richness are skipped so RICHNESS_ORE_DELTA stays byte-identical.
# A dedicated seeded RNG leaves the shared `rng` stage stream untouched.
func _ensure_start_ore_clusters(starts: Array[Vector2]) -> void:
	var rkey := str(Data.RICHNESS)
	if rkey != "med" and rkey != "normal":
		return
	if starts.is_empty():
		return
	var r := RandomNumberGenerator.new()
	r.seed = (int(Data.RANDOM_SEED) ^ 0x4d494e45) + 104729
	var kinds := ["gold", "iron", "coal"]
	var claimed: Array = []  # node ids already assigned to an earlier start
	# One footprint test shared by the random passes and the deterministic sweep.
	var spot_ok := func(p: Vector2, node_id: int) -> bool:
		if not in_bounds(p) or is_blocked(p):
			return false
		if int(terrain[_t(tile_of(p).x, tile_of(p).y)]) == 3:
			return false
		# full scaled-mine footprint separation, not the old 3 m point check
		if not _ore_spot_clear(p, node_id):
			return false
		for other in res_nodes:
			if int(other.id) == node_id:
				continue
			if str(other.type) in ["wood", "stone"] and int(other.hits) > 0 and other.pos.distance_to(p) < 4.0 * TILE:
				return false
		return true
	for si in starts.size():
		var st: Vector2 = starts[si]
		var base := r.randf() * TAU
		for ki in kinds.size():
			var k: String = kinds[ki]
			# Already close enough? Keep the stamped donor position as-is, but
			# CLAIM it so a later start cannot steal this hall's guaranteed ore.
			var served := false
			var served_id := -1
			for n in res_nodes:
				if str(n.type) != k or int(n.max_hits) != 0 or claimed.has(int(n.id)):
					continue
				if n.pos.distance_to(st) / TILE <= MINE_SERVED_R:
					served = true
					served_id = int(n.id)
					break
			if served:
				if served_id >= 0:
					claimed.append(served_id)
				continue
			# Pick the nearest unclaimed deposit of this kind and move it in.
			var pick_idx := -1
			var pick_d := 1.0e9
			for n_i in res_nodes.size():
				var cand: Dictionary = res_nodes[n_i]
				if str(cand.type) != k or int(cand.max_hits) != 0:
					continue
				if claimed.has(int(cand.id)):
					continue
				var cd: float = cand.pos.distance_to(st)
				if cd < pick_d:
					pick_d = cd
					pick_idx = n_i
			if pick_idx < 0:
				continue  # no such deposit on the map: never invent one
			var node: Dictionary = res_nodes[pick_idx]
			var old_pos: Vector2 = node.pos
			# Open ground in this ore's 120-deg sector (soft preference: a
			# corner start or congested sector falls back to any angle).
			var sector := base + float(ki) * TAU / 3.0
			var dest: Vector2 = Vector2.ZERO
			var found := false
			# Seeded random passes: sector first, then any angle, then wider.
			for pass_i in 3:
				if found:
					break
				for _a in 96:
					var ang := sector + r.randf_range(-0.9, 0.9)
					if pass_i >= 1:
						ang = r.randf() * TAU
					var hi := MINE_NEAR_HI
					if pass_i == 2:
						hi = MINE_SERVED_R  # last-resort widen, still <= service ring
					var dst := r.randf_range(MINE_NEAR_LO, hi)
					var p: Vector2 = st + Vector2(cos(ang), sin(ang)) * dst * TILE
					if spot_ok.call(p, int(node.id)):
						dest = p
						found = true
						break
			# Deterministic sweep: a random stream can miss a valid spot on a
			# congested start (observed on seed 1004).  Never leave a hall short.
			if not found:
				for di in [8.0, 10.0, 12.0, 14.0, 6.0, MINE_SERVED_R]:
					for ai in 48:
						var ang := TAU * float(ai) / 48.0
						var p: Vector2 = st + Vector2(cos(ang), sin(ang)) * di * TILE
						if spot_ok.call(p, int(node.id)):
							dest = p
							found = true
							break
					if found:
						break
			if not found:
				continue
			# Move the SAME node (by_id shares this Dictionary) and repaint its
			# worked ground. Count, wealth share (assigned in _gen_finish) and
			# node id are all preserved.
			_clear_mine_mask(old_pos, 3.0 * TILE)
			set_blocked_circle(old_pos, float(node.radius), false)
			node["pos"] = dest
			set_blocked_circle(dest, float(node.radius), true)
			_paint_terrain(dest, 3.0 * TILE, 1, 2.5, true)
			_mark_mine_mask(dest, 3.0 * TILE)
			claimed.append(int(node.id))
			res_dirty += 1

func _gen_finish() -> void:
	_reseed_stage("finish")  # P-31 / dogenerate.inc:1927 final stage
	var starts: Array[Vector2] = []
	for sv in map_starts:
		starts.append(sv as Vector2)
	# keep the three elliptical start zones clear (donor gPatternMask).
	for st in starts:
		_paint_terrain(st, 5.0 * TILE, 1)
		_clear_area(st, 14.0 * TILE)   # donor cCircle1/2 keep-clear for building room
		for n in res_nodes:
			if n.hits <= 0:
				set_blocked_circle(n.pos, n.radius, false)
		# T-FOOD-1: no wild-food re-plant here. The keep-clear wipe above only
		# depletes nodes in the start zone; mill-owned fields regrow through
		# the mill cycle (_tick_field_growth / cmd_sow), never from mapgen.
		# T-FOREST-DENSE: same clump tightening as _gen_forests (spread 5/4 ->
		# 3.5/3 tiles, counts +30%). Seeded rng unchanged in draw count.
		_scatter_forest(st + Vector2(9, -8) * TILE, 34, 3.5 * TILE)
		_paint_terrain(st + Vector2(9, -8) * TILE, 4.5 * TILE, 2)
		_scatter_forest(st + Vector2(-10, 6) * TILE, 23, 3.0 * TILE)
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
	var wealth: float = float(Data.RICHNESS_MULT.get(str(Data.RICHNESS), 1.0))
	for n in res_nodes:
		if n.max_hits == 0 and cnt.has(n.type) and int(cnt[n.type]) > 0:
			n["left"] = float(Data.DEPOSITS.get(n.type, 30000)) * wealth / float(cnt[n.type])
	# T2GEN: enforce the donor 7-tile start keep-clear for FOREST as well as
	# relief after the sacred groves are painted (map_density.md 2.3/RELIEF-1).
	for st in starts:
		var sc := Vector2(st.x / TILE, st.y / TILE)
		for yy in range(maxi(0, int(sc.y - 7.0)), mini(MAP_H, int(sc.y + 7.0) + 1)):
			for xx in range(maxi(0, int(sc.x - 7.0)), mini(MAP_W, int(sc.x + 7.0) + 1)):
				if Vector2(float(xx) - sc.x, float(yy) - sc.y).length() <= 7.05:
					var ci := _t(xx, yy)
					if terrain[ci] == 2:
						terrain[ci] = 0

# TRN-DATA: complete donor transition rules from RV-TRN-02 §7 (all 1,864 lines of
# gen/tilesmooth_scripts.cfg parsed). 118 ACTIVE lists across 22 Items (0-21),
# 282 active TileName:Prob entries, 12 commented lists excluded. J is the index
# of the ACTIVE list inside its Item, not the position inside the list. Winter
# Items 11-21 mirror Summer 0-10 with `_winter` on every tile name.
# Do not normalise the authored 0.64/0.0028/0.36 (SumProb 1.0028) anomaly.
# Prob=0 entries are position-only hard separators; their SumProb=0 lists return -1.
const DONOR_SMOOTH_RULES: Array = [
	[ # Item 0 (Summer)
		[["sandsea1", 1.0], ["sandsea2", 1.0], ["sandsea3", 1.0], ["sandsea4", 1.0]], # J=0 cfg:5 SumProb=4
		[["sandsea5", 0.7], ["sandsea6", 0.3]], # J=1 cfg:25 SumProb=1
		[["rock9", 0.0], ["rock8", 0.0], ["rock5", 0.0]], # J=2 cfg:51 SumProb=0
		[["rock1", 0.16], ["rock2", 0.16], ["rock3", 0.16], ["rock6", 0.16], ["rock7", 0.16], ["rock4", 0.2]], # J=3 cfg:67 SumProb=1
	],
	[ # Item 1 (Summer)
		[["sandsea1", 1.0], ["sandsea2", 1.0], ["sandsea3", 1.0], ["sandsea4", 1.0]], # J=0 cfg:99 SumProb=4
		[["sandsea5", 0.7], ["sandsea6", 0.3]], # J=1 cfg:119 SumProb=1
		[["sandrock1", 0.4], ["sandrock3", 0.6]], # J=2 cfg:131 SumProb=1
		[["sandrock4", 0.6], ["sandrock2", 0.4]], # J=3 cfg:143 SumProb=1
		[["grass1", 1.0], ["grass2", 1.0], ["test8", 1.0]], # J=4 cfg:155 SumProb=3
		[["grass7", 0.25], ["test12", 0.25], ["test13", 0.25], ["test14", 0.25]], # J=5 cfg:171 SumProb=1
	],
	[ # Item 2 (Summer)
		[["sandsea1", 1.0], ["sandsea2", 1.0], ["sandsea3", 1.0], ["sandsea4", 1.0]], # J=0 cfg:195 SumProb=4
		[["sandsea5", 0.7], ["sandsea6", 0.3]], # J=1 cfg:215 SumProb=1
		[["sandrock1", 0.4], ["sandrock3", 0.6]], # J=2 cfg:227 SumProb=1
		[["sandrock4", 0.6], ["sandrock2", 0.4]], # J=3 cfg:239 SumProb=1
		[["grass1", 1.0], ["grass2", 1.0], ["test8", 1.0]], # J=4 cfg:251 SumProb=3
		[["test7", 1.0], ["grass8", 1.0], ["test6", 1.0]], # J=5 cfg:267 SumProb=3
	],
	[ # Item 3 (Summer)
		[["sandsea1", 1.0], ["sandsea2", 1.0], ["sandsea3", 1.0], ["sandsea4", 1.0]], # J=0 cfg:287 SumProb=4
		[["sandsea5", 0.7], ["sandsea6", 0.3]], # J=1 cfg:307 SumProb=1
		[["sandrock1", 0.4], ["sandrock3", 0.6]], # J=2 cfg:319 SumProb=1
		[["sandrock4", 0.6], ["sandrock2", 0.4]], # J=3 cfg:331 SumProb=1
		[["grass1", 1.0], ["grass2", 1.0], ["test8", 1.0]], # J=4 cfg:343 SumProb=3
		[["grass9", 1.0]], # J=5 cfg:359 SumProb=1
		[["test9", 1.0]], # J=6 cfg:367 SumProb=1
		[["grass3", 1.0]], # J=7 cfg:375 SumProb=1
		[["grass4", 0.9], ["grass10", 0.1]], # J=8 cfg:383 SumProb=1
	],
	[ # Item 4 (Summer)
		[["rock1", 0.16], ["rock2", 0.16], ["rock3", 0.16], ["rock6", 0.16], ["rock7", 0.16], ["rock4", 0.2]], # J=0 cfg:399 SumProb=1
		[["rock8", 0.5], ["rock5", 0.5]], # J=1 cfg:427 SumProb=1
		[["rock9", 1.0]], # J=2 cfg:439 SumProb=1
		[["grass_ground1", 0.64], ["grass_ground2", 0.0028], ["grass_ground3", 0.36]], # J=3 cfg:447 SumProb=1.0028
		[["grass1", 1.0], ["grass2", 1.0], ["test8", 1.0]], # J=4 cfg:464 SumProb=3
		[["grass9", 1.0]], # J=5 cfg:480 SumProb=1
		[["test9", 1.0]], # J=6 cfg:488 SumProb=1
		[["grass3", 1.0]], # J=7 cfg:496 SumProb=1
		[["grass4", 0.9], ["grass10", 0.1]], # J=8 cfg:504 SumProb=1
	],
	[ # Item 5 (Summer)
		[["rock1", 0.16], ["rock2", 0.16], ["rock3", 0.16], ["rock6", 0.16], ["rock7", 0.16], ["rock4", 0.2]], # J=0 cfg:520 SumProb=1
		[["rock8", 0.5], ["rock5", 0.5]], # J=1 cfg:548 SumProb=1
		[["rock9", 1.0]], # J=2 cfg:560 SumProb=1
		[["grass_ground1", 0.64], ["grass_ground2", 0.0028], ["grass_ground3", 0.36]], # J=3 cfg:568 SumProb=1.0028
		[["grass1", 1.0], ["grass2", 1.0], ["test8", 1.0]], # J=4 cfg:585 SumProb=3
		[["test7", 1.0]], # J=5 cfg:601 SumProb=1
		[["grass8", 1.0]], # J=6 cfg:609 SumProb=1
		[["test6", 1.0]], # J=7 cfg:617 SumProb=1
	],
	[ # Item 6 (Summer)
		[["rock1", 0.16], ["rock2", 0.16], ["rock3", 0.16], ["rock6", 0.16], ["rock7", 0.16], ["rock4", 0.2]], # J=0 cfg:629 SumProb=1
		[["rock8", 0.5], ["rock5", 0.5]], # J=1 cfg:657 SumProb=1
		[["rock9", 1.0]], # J=2 cfg:669 SumProb=1
		[["grass_ground1", 0.64], ["grass_ground2", 0.0028], ["grass_ground3", 0.36]], # J=3 cfg:677 SumProb=1.0028
		[["grass1", 1.0], ["grass2", 1.0], ["test8", 1.0]], # J=4 cfg:694 SumProb=3
		[["grass7", 0.25], ["test12", 0.25], ["test13", 0.25], ["test14", 0.25]], # J=5 cfg:710 SumProb=1
	],
	[ # Item 7 (Summer)
		[["rock9", 1.0], ["test8", 0.0]], # J=0 cfg:734 SumProb=1
		[["grass5", 1.0]], # J=1 cfg:762 SumProb=1
		[["grass6", 1.0]], # J=2 cfg:770 SumProb=1
	],
	[ # Item 8 (Summer)
		[["rock9", 1.0]], # J=0 cfg:782 SumProb=1
		[["grass5", 1.0]], # J=1 cfg:790 SumProb=1
		[["grass_ground1", 0.36], ["grass_ground2", 0.28], ["grass_ground3", 0.36]], # J=2 cfg:798 SumProb=1
	],
	[ # Item 9 (Summer)
		[["ground1", 1.0]], # J=0 cfg:818 SumProb=1
		[["test2", 1.0]], # J=1 cfg:826 SumProb=1
		[["test1", 1.0], ["test3", 1.0]], # J=2 cfg:834 SumProb=2
		[["test8", 0.4], ["test7", 0.6]], # J=3 cfg:846 SumProb=1
		[["grass1", 1.0], ["grass2", 1.0], ["test8", 1.0]], # J=4 cfg:862 SumProb=3
	],
	[ # Item 11 (Winter)
		[["sandsea1_winter", 1.0], ["sandsea2_winter", 1.0], ["sandsea3_winter", 1.0], ["sandsea4_winter", 1.0]], # J=0 cfg:935 SumProb=4
		[["sandsea5_winter", 0.7], ["sandsea6_winter", 0.3]], # J=1 cfg:955 SumProb=1
		[["rock9_winter", 0.0], ["rock8_winter", 0.0], ["rock5_winter", 0.0]], # J=2 cfg:981 SumProb=0
		[["rock1_winter", 0.16], ["rock2_winter", 0.16], ["rock3_winter", 0.16], ["rock6_winter", 0.16], ["rock7_winter", 0.16], ["rock4_winter", 0.2]], # J=3 cfg:997 SumProb=1
	],
	[ # Item 12 (Winter)
		[["sandsea1_winter", 1.0], ["sandsea2_winter", 1.0], ["sandsea3_winter", 1.0], ["sandsea4_winter", 1.0]], # J=0 cfg:1029 SumProb=4
		[["sandsea5_winter", 0.7], ["sandsea6_winter", 0.3]], # J=1 cfg:1049 SumProb=1
		[["sandrock1_winter", 0.4], ["sandrock3_winter", 0.6]], # J=2 cfg:1061 SumProb=1
		[["sandrock4_winter", 0.6], ["sandrock2_winter", 0.4]], # J=3 cfg:1073 SumProb=1
		[["grass1_winter", 1.0], ["grass2_winter", 1.0], ["test8_winter", 1.0]], # J=4 cfg:1085 SumProb=3
		[["grass7_winter", 0.25], ["test12_winter", 0.25], ["test13_winter", 0.25], ["test14_winter", 0.25]], # J=5 cfg:1101 SumProb=1
	],
	[ # Item 13 (Winter)
		[["sandsea1_winter", 1.0], ["sandsea2_winter", 1.0], ["sandsea3_winter", 1.0], ["sandsea4_winter", 1.0]], # J=0 cfg:1125 SumProb=4
		[["sandsea5_winter", 0.7], ["sandsea6_winter", 0.3]], # J=1 cfg:1145 SumProb=1
		[["sandrock1_winter", 0.4], ["sandrock3_winter", 0.6]], # J=2 cfg:1157 SumProb=1
		[["sandrock4_winter", 0.6], ["sandrock2_winter", 0.4]], # J=3 cfg:1169 SumProb=1
		[["grass1_winter", 1.0], ["grass2_winter", 1.0], ["test8_winter", 1.0]], # J=4 cfg:1181 SumProb=3
		[["test7_winter", 1.0], ["grass8_winter", 1.0], ["test6_winter", 1.0]], # J=5 cfg:1197 SumProb=3
	],
	[ # Item 14 (Winter)
		[["sandsea1_winter", 1.0], ["sandsea2_winter", 1.0], ["sandsea3_winter", 1.0], ["sandsea4_winter", 1.0]], # J=0 cfg:1217 SumProb=4
		[["sandsea5_winter", 0.7], ["sandsea6_winter", 0.3]], # J=1 cfg:1237 SumProb=1
		[["sandrock1_winter", 0.4], ["sandrock3_winter", 0.6]], # J=2 cfg:1249 SumProb=1
		[["sandrock4_winter", 0.6], ["sandrock2_winter", 0.4]], # J=3 cfg:1261 SumProb=1
		[["grass1_winter", 1.0], ["grass2_winter", 1.0], ["test8_winter", 1.0]], # J=4 cfg:1273 SumProb=3
		[["grass9_winter", 1.0]], # J=5 cfg:1289 SumProb=1
		[["test9_winter", 1.0]], # J=6 cfg:1297 SumProb=1
		[["grass3_winter", 1.0]], # J=7 cfg:1305 SumProb=1
		[["grass4_winter", 0.9], ["grass10_winter", 0.1]], # J=8 cfg:1313 SumProb=1
	],
	[ # Item 15 (Winter)
		[["rock1_winter", 0.16], ["rock2_winter", 0.16], ["rock3_winter", 0.16], ["rock6_winter", 0.16], ["rock7_winter", 0.16], ["rock4_winter", 0.2]], # J=0 cfg:1329 SumProb=1
		[["rock8_winter", 0.5], ["rock5_winter", 0.5]], # J=1 cfg:1357 SumProb=1
		[["rock9_winter", 1.0]], # J=2 cfg:1369 SumProb=1
		[["grass_ground1_winter", 0.64], ["grass_ground2_winter", 0.0028], ["grass_ground3_winter", 0.36]], # J=3 cfg:1377 SumProb=1.0028
		[["grass1_winter", 1.0], ["grass2_winter", 1.0], ["test8_winter", 1.0]], # J=4 cfg:1394 SumProb=3
		[["grass9_winter", 1.0]], # J=5 cfg:1410 SumProb=1
		[["test9_winter", 1.0]], # J=6 cfg:1418 SumProb=1
		[["grass3_winter", 1.0]], # J=7 cfg:1426 SumProb=1
		[["grass4_winter", 0.9], ["grass10_winter", 0.1]], # J=8 cfg:1434 SumProb=1
	],
	[ # Item 16 (Winter)
		[["rock1_winter", 0.16], ["rock2_winter", 0.16], ["rock3_winter", 0.16], ["rock6_winter", 0.16], ["rock7_winter", 0.16], ["rock4_winter", 0.2]], # J=0 cfg:1450 SumProb=1
		[["rock8_winter", 0.5], ["rock5_winter", 0.5]], # J=1 cfg:1478 SumProb=1
		[["rock9_winter", 1.0]], # J=2 cfg:1490 SumProb=1
		[["grass_ground1_winter", 0.64], ["grass_ground2_winter", 0.0028], ["grass_ground3_winter", 0.36]], # J=3 cfg:1498 SumProb=1.0028
		[["grass1_winter", 1.0], ["grass2_winter", 1.0], ["test8_winter", 1.0]], # J=4 cfg:1515 SumProb=3
		[["test7_winter", 1.0]], # J=5 cfg:1531 SumProb=1
		[["grass8_winter", 1.0]], # J=6 cfg:1539 SumProb=1
		[["test6_winter", 1.0]], # J=7 cfg:1547 SumProb=1
	],
	[ # Item 17 (Winter)
		[["rock1_winter", 0.16], ["rock2_winter", 0.16], ["rock3_winter", 0.16], ["rock6_winter", 0.16], ["rock7_winter", 0.16], ["rock4_winter", 0.2]], # J=0 cfg:1559 SumProb=1
		[["rock8_winter", 0.5], ["rock5_winter", 0.5]], # J=1 cfg:1587 SumProb=1
		[["rock9_winter", 1.0]], # J=2 cfg:1599 SumProb=1
		[["grass_ground1_winter", 0.64], ["grass_ground2_winter", 0.0028], ["grass_ground3_winter", 0.36]], # J=3 cfg:1607 SumProb=1.0028
		[["grass1_winter", 1.0], ["grass2_winter", 1.0], ["test8_winter", 1.0]], # J=4 cfg:1624 SumProb=3
		[["grass7_winter", 0.25], ["test12_winter", 0.25], ["test13_winter", 0.25], ["test14_winter", 0.25]], # J=5 cfg:1640 SumProb=1
	],
	[ # Item 18 (Winter)
		[["rock9_winter", 1.0], ["test8_winter", 0.0]], # J=0 cfg:1664 SumProb=1
		[["grass5_winter", 1.0]], # J=1 cfg:1692 SumProb=1
		[["grass6_winter", 1.0]], # J=2 cfg:1700 SumProb=1
	],
	[ # Item 19 (Winter)
		[["rock9_winter", 1.0]], # J=0 cfg:1712 SumProb=1
		[["grass5_winter", 1.0]], # J=1 cfg:1720 SumProb=1
		[["grass_ground1_winter", 0.36], ["grass_ground2_winter", 0.28], ["grass_ground3_winter", 0.36]], # J=2 cfg:1728 SumProb=1
	],
	[ # Item 20 (Winter)
		[["ground1_winter", 1.0]], # J=0 cfg:1748 SumProb=1
		[["test2_winter", 1.0]], # J=1 cfg:1756 SumProb=1
		[["test1_winter", 1.0], ["test3_winter", 1.0]], # J=2 cfg:1764 SumProb=2
		[["test8_winter", 0.4], ["test7_winter", 0.6]], # J=3 cfg:1776 SumProb=1
		[["grass1_winter", 1.0], ["grass2_winter", 1.0], ["test8_winter", 1.0]], # J=4 cfg:1792 SumProb=3
	],
]


# TRN-DATA: forest interior base families = donor Item 1 J=5 list verbatim
# (grass7 / test12 / test13 / test14 at 0.25 each, RV-TRN-02 §7 Item 1 J=5
# cfg:171). These are donor-authored PROBABILITIES, not a synthetic field; the
# former grass_ground1/3 pair are transition tiles and made top-5 = 73%.
const DONOR_FOREST_BASE: Array = [["grass7", 0.25], ["test12", 0.25], ["test13", 0.25], ["test14", 0.25]]

func _load_terrain_structs() -> void:
	if not tbl_names.is_empty():
		return
	var a1 = JSON.parse_string(FileAccess.get_file_as_string("res://assets/terrain/structs/presets_summer.json"))
	if a1 is Array:
		tbl_names = a1
	for i in tbl_names.size():
		tbl_idx[str(tbl_names[i])] = i
	# TRN-DATA: the 118-rule table is embedded above, not read from a JSON asset.
	# Convert [name, prob] pairs to the same shape the donor-smoothing reader
	# already consumes. Winter names resolve through the donor season alias
	# (`*_winter` is the 1:1 Summer preset alias, winter_variant.md 1.1/1.2);
	# Items 0-10 come first, so an equal-J match from a Winter row can never
	# displace the identical Summer match (same-seed determinism preserved).
	tbl_smooth.clear()
	for item in DONOR_SMOOTH_RULES:
		var item_lists: Array = []
		for src_list in item:
			var dst_list: Array = []
			for pair in src_list:
				var nm := str(pair[0])
				if nm.ends_with("_winter"):
					nm = nm.substr(0, nm.length() - 7)
				dst_list.append({"name": nm, "prob": float(pair[1])})
			item_lists.append(dst_list)
		tbl_smooth.append(item_lists)

# T2GEN P2-5: donor Winter preset is a 1:1 alias of the Summer preset with
# `_winter` appended; tiles.mat resolves those 124 aliases to winter*.png
# (winter_variant.md 1.1/1.2).  Expose the mapping as DATA only: tileblock
# indices stay the summer preset order so summer dumps are byte-identical and
# world.gd keeps ownership of the season tint / art swap.  A winter-capable
# renderer can read per-cell winter art from `winter_tile_names`.
const WINTER_ART := {
	"grass1": "winter10", "grass2": "winter9", "grass3": "winter2",
	"grass4": "winter3", "grass5": "winter4", "grass6": "winter16",
	"grass7": "winter1", "grass8": "winter21", "grass9": "winter0", "grass10": "winter0",
	"ground1": "winter11", "grass_sand1": "winter21", "grass_sand2": "winter1",
	"grass_rock1": "winter9", "grass_ground1": "winter5",
	"grass_ground2": "winter4", "grass_ground3": "winter5",
	"rock1": "winter12", "rock2": "winter13", "rock3": "winter13",
	"rock4": "winter17", "rock5": "winter22", "rock6": "winter15",
	"rock7": "winter14", "rock8": "winter16", "rock9": "winter20",
	"sand1": "winter10", "sand2": "winter10", "sand3": "winter20",
	"sand4": "winter10", "sand5": "winter0", "sand6": "winter0",
	"sand7": "winter0", "sand8": "winter0", "sand9": "winter0",
	"sand1f": "winter0", "sand2f": "winter0", "sand3f": "winter1",
	"sand4f": "winter10", "sand5f": "winter0", "sand6f": "winter1",
	"sand7f": "winter1", "sand8f": "winter0", "sand9f": "winter1",
	"sand1s": "winter25", "sand2s": "winter0", "sand3s": "winter0",
	"sand4s": "winter0", "sand5s": "winter1", "sand6s": "winter1",
	"sand7s": "winter1", "sand8s": "winter2", "sand9s": "winter2",
	"rock1vf": "winter12", "rock1vs": "winter12", "rock2vf": "winter13", "rock2vs": "winter13",
	"rock3vf": "winter13", "rock3vs": "winter13", "rock4vf": "winter17", "rock4vs": "winter17",
	"rock5vf": "winter22", "rock5vs": "winter22", "rock6vf": "winter15", "rock6vs": "winter15",
	"rock7vf": "winter14", "rock7vs": "winter14", "rock8vf": "winter16", "rock8vs": "winter16",
	"rock9vf": "winter20", "rock9vs": "winter20",
	"test0": "winter4", "test1": "winter6", "test2": "winter7", "test3": "winter8",
	"test4": "winter0", "test5": "winter10", "test6": "winter4", "test7": "winter10",
	"test8": "winter21", "test9": "winter10", "test10": "winter0", "test11": "winter1",
	"test12": "winter5", "test13": "winter5", "test14": "winter5", "test15": "winter10",
	"test16": "winter10", "test17": "winter10", "test18": "winter7", "test19": "winter8",
	"test20": "winter0", "test21": "winter25", "test22": "winter1", "test23": "winter25",
	"test24": "winter10", "test25": "winter25",
	"alpha0a": "winter0", "alpha0b": "winter1", "alpha0c": "winter1",
	"sandrock1": "winter1", "sandrock2": "winter10", "sandrock3": "winter19",
	"sandrock4": "winter19", "sandrock5": "winter1", "sandrock6": "winter0",
	"sandsea1": "winter19", "sandsea2": "winter2", "sandsea3": "winter2",
	"sandsea4": "winter19", "sandsea5": "winter19", "sandsea6": "winter3",
	"desert1": "desert1", "desert2": "desert2", "desert3": "desert3",
	"desert4": "desert4", "desert5": "desert5", "desert6": "desert6",
	"desert7": "desert7", "desert8": "desert8", "desert9": "desert9",
	"desert10": "desert10", "desert11": "desert11", "desert12": "desert12",
}

# Per-cell winter art name (empty on summer maps / water cells). Populated by
# _assign_tileblocks so the renderer can swap winter*.png without owning data.
var winter_tile_names: Array = []


func winter_block_for(idx: int) -> String:
	if idx < 0 or idx >= tbl_names.size():
		return ""
	var name := str(tbl_names[idx])
	return str(WINTER_ART.get(name, name))

var tile_low_im: Image
var tile_high_im: Image
var bld_scale_idx := {}  # nation_sid -> {ortho, cx, rm} (tools/compute_buildings.py)

func _bld_scale_key(player: int, sid: String) -> String:
	var nat := ""
	if player >= 0 and player < Data.PLAYER_NATIONS.size():
		nat = str(Data.PLAYER_NATIONS[player])
	return ("%s_%s" % [nat, sid]) if nat != "" else ""

func bld_rm(player: int, sid: String) -> float:
	# visual half-width in meters for sprite-drawn nation buildings (0 = none:
	# walls, gates, mines, procedural fallbacks keep their gameplay radius).
	if bld_scale_idx.is_empty():
		var bp := "res://assets/models/anim/buildings/buildings.json"
		if not FileAccess.file_exists(bp):
			bp = "res://assets/models/anim/buildings.json"  # legacy flat fallback
		var j := FileAccess.get_file_as_string(bp)
		if j != "":
			var parsed = JSON.parse_string(j)
			if parsed is Dictionary:
				bld_scale_idx = parsed
	var e: Dictionary = bld_scale_idx.get(_bld_scale_key(player, sid), {})
	return float(e.get("rm", 0.0))

func bld_block_r(e: Dictionary) -> float:
	# impassable footprint: the visual size when known, else gameplay radius.
	var rm := bld_rm(int(e.get("player", -1)), str(e.get("sid", "")))
	if rm > 0.0:
		return rm
	return float(e.def.radius)

func bld_block_rect(e: Dictionary) -> Rect2:
	return bld_block_rect_for(int(e.get("player", -1)), str(e.get("sid", "")), e.pos)

func bld_block_rect_for(player: int, sid: String, pos: Vector2) -> Rect2:
	# World-space rectangle covering the drawn building sprite (its ink box),
	# using the very same ortho/ink/cx/foot data world.gd draws with.  The ink
	# bottom sits on the ground anchor and the rest rises above it, so this is
	# the 2D block no unit may pass under or above.  Empty for walls, gates,
	# mines and procedural fallbacks that have no baked nation sheet.
	var key := _bld_scale_key(player, sid)
	if key == "":
		return Rect2()
	if bld_scale_idx.is_empty():
		var bp := "res://assets/models/anim/buildings/buildings.json"
		if not FileAccess.file_exists(bp):
			bp = "res://assets/models/anim/buildings.json"  # legacy flat fallback
		var j := FileAccess.get_file_as_string(bp)
		if j != "":
			var parsed = JSON.parse_string(j)
			if parsed is Dictionary:
				bld_scale_idx = parsed
	if not bld_scale_idx.has(key):
		return Rect2()
	var d: Dictionary = bld_scale_idx[key]
	var ortho := float(d.get("ortho", 0.0))
	if ortho <= 0.0:
		return Rect2()
	var cell := maxf(8.0, float(d.get("cell", 320.0)))
	var ink: Array = d.get("ink", [])
	if ink.size() < 4:
		return Rect2()
	var cx := float(d.get("cx", (float(ink[0]) + float(ink[2])) * 0.5 / cell))
	var foot := float(ink[3]) / cell
	var p: Vector2 = pos
	var left := p.x + ortho * (float(ink[0]) / cell - cx)
	var top := p.y + ortho * (float(ink[1]) / cell - foot)
	var right := p.x + ortho * (float(ink[2]) / cell - cx)
	var bottom := p.y + ortho * (float(ink[3]) / cell - foot)
	return Rect2(left, top, maxf(0.0, right - left), maxf(0.0, bottom - top))

func _unblock_building(e: Dictionary) -> void:
	set_blocked_circle(e.pos, float(e.get("block_r", e.def.radius)), false)

func pick_radius(e: Dictionary) -> float:
	# click target size: visual footprint for sprite-drawn buildings (clicking
	# the drawn walls works), gameplay radius + grab margin otherwise.
	if e.get("kind", "") == "building":
		return bld_block_r(e) + 1.4
	return float(e.def.radius) + 1.4

func _load_image_tex(path: String) -> Image:
	# Export-safe Image load: res:// PNGs are imported as CompressedTexture2D.
	# Image.load(path) warns ("Loaded resource as image file...") and breaks
	# on export; going through Texture2D works in editor and in .pck builds.
	var tex: Texture2D = ResourceLoader.load(path) as Texture2D
	if tex == null:
		return null
	return tex.get_image()

func _load_detail_bitmaps() -> void:
	# donor data/gen/bitmap/ext/tile_low/highground.bmp (320x320, R = tex*2):
	# LoadTextureTerrainFromBitmap picks the bitmap by height and paints every
	# cell still on TileBlock 0 with the bitmap's tile.  Copied to
	# assets/terrain/structs/*.png by tools/copy_assets.py.
	if tile_low_im != null and tile_high_im != null:
		return
	tile_low_im = _load_image_tex("res://assets/terrain/structs/tile_lowground.png")
	tile_high_im = _load_image_tex("res://assets/terrain/structs/tile_highground.png")

func _apply_detail_pass(brng: RandomNumberGenerator) -> void:
	# donor loadtextureterrainfrombitmap.inc: h < 0.1 reads tile_lowground,
	# else tile_highground; tex = R div 2; only cells still on block 0 change.
	_load_detail_bitmaps()
	if tile_low_im == null or tile_high_im == null:
		return
	var grass0 := _blk("grass1")
	var lw := tile_low_im.get_width()
	var lh := tile_low_im.get_height()
	var hw := tile_high_im.get_width()
	var hh2 := tile_high_im.get_height()
	for y in MAP_H:
		for x in MAP_W:
			var i := _t(x, y)
			if int(tileblock[i]) != grass0:
				continue
			var h: float = height[i] if height.size() == MAP_W * MAP_H else 0.0
			var im: Image = tile_low_im if h < 0.1 else tile_high_im
			var iw := lw if h < 0.1 else hw
			var ih := lh if h < 0.1 else hh2
			var sx: int = clampi(int(float(x) / float(MAP_W) * float(iw)), 0, iw - 1)
			var sy: int = clampi(int(float(y) / float(MAP_H) * float(ih)), 0, ih - 1)
			var tex: int = int(im.get_pixel(sx, sy).r * 255.0) / 2
			# B03-P1 (PORT APPROXIMATION, A04 §6 P1): the donor writes its two
			# transition ids verbatim from the bitmap, which paints ~15% of the
			# map one dark atlas cell. Re-roll ONLY those two through the donor
			# lists that already contain them (RV-TRN-02 §7: Item 2 J=5
			# test7/grass8/test6 cfg:267; Item 1 J=4 grass1/grass2/test8 cfg:155)
			# using the port's existing weighted picker. No new id, no mask edit,
			# no synthetic dither/noise field (charter S-25-09).
			if tex == _blk("test7"):
				var pick7 := _tb_pick(2, 5, brng)
				if pick7 >= 0:
					tex = pick7
			elif tex == _blk("test8"):
				var pick8 := _tb_pick(1, 4, brng)
				if pick8 >= 0:
					tex = pick8
			# Y03 (PORT APPROXIMATION, diagnostic baseline — A08 §1.2, Y01b §8):
			# the bitmap R is a CATEGORICAL tile id and the h<0.1 low/high
			# selection makes its 1-6 cell runs follow height contours — the
			# surviving concentric maze after B03 removed terrain=5. Collapse
			# every detail-pass output to ONE clean donor grass id (grass9 idx 8,
			# A03 §2 "best isotropic/seamless"). Keep the TWO _tb_pick calls
			# ABOVE: they must consume the same brng draws so _smooth_tilemap
			# and _stamp_forest_borders see an unchanged RNG stream. The donor
			# uses these ids for mottling; removing their variety is a port-level
			# substitution, not donor parity (UNVERIFIED). L01's stamp-mask
			# spots are the planned organic-variety follow-up.
			tex = _blk("test8")
			if tex >= 0 and tex < tbl_names.size():
				tileblock[i] = tex

func _blk(n: String) -> int:
	return int(tbl_idx.get(n, 0))

func _assign_tileblocks() -> void:
	# deterministic stream of its own (same map on every load, no save data)
	_load_terrain_structs()
	# T2GEN P0-1: every live ore node claims its worked-ground apron, however
	# it was placed (stamp or richness).  Guarantees zero test2/test3 in any
	# mine footprint without touching road/dirt selection elsewhere.
	if mine_mask.size() != MAP_W * MAP_H:
		mine_mask.resize(MAP_W * MAP_H)
	for n in res_nodes:
		if str(n.type) in ["gold", "iron", "coal"]:
			_mark_mine_mask(n.pos, 3.0 * TILE)
	tileblock.resize(MAP_W * MAP_H)
	var brng := RandomNumberGenerator.new()
	brng.seed = int(Data.RANDOM_SEED) + 7
	# 1) base blocks from the donor pipeline: every land cell starts as the
	# default TileBlock (grass1 = presets Summer index 0, like donor
	# SetTileIndex(x,y,0) in generatemap.inc).  Meadow variety does NOT come
	# from random speckles here â€” the donor paints detail later from the
	# tile_low/highground bitmaps (_apply_detail_pass below), then blends
	# neighbours with 3 SmoothTileMap passes.  Random per-tile test7/8/9
	# speckles (the old port) checkerboarded because those blocks are
	# transition blends, not meadow variation.
	for y in MAP_H:
		for x in MAP_W:
			var t: int = terrain[_t(x, y)]
			var b := _blk("grass1")
			var r := brng.randf()
			match t:
				1:
					# donor PlaceRoads (texturemap.inc): broad-mask dirt is
					# ground1 half the time, test2 37.5%, test3 12.5% (two
					# sequential RandomExt draws, not one flat roll).
					var r2 := brng.randf()
					if r < 0.5:
						b = _blk("ground1")
					elif r2 > 0.25:
						b = _blk("test2")
					else:
						b = _blk("test3")
				2:
					# TRN-DATA: donor Item 1 J=5 family roulette (0.25 x4).
					# One `r` draw as before, so every non-tileblock stream stays
					# byte-identical for a given seed.
					var total := 0.0
					for fp in DONOR_FOREST_BASE:
						total += float(fp[1])
					var acc := 0.0
					for fp in DONOR_FOREST_BASE:
						acc += float(fp[1])
						if r * total < acc:
							b = _blk(str(fp[0]))
							break
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
			# T2GEN P0-1: neutral worked ground over the WHOLE mine apron,
			# whatever the underlying terrain role.  test2/test3 belong only
			# to the road pass (mines_display.md C9/A2).
			if mine_mask[_t(x, y)] != 0:
				b = _blk("ground1")
			tileblock[_t(x, y)] = b
	# 2) oriented shores + cliffs (donor texturemap.inc 8-sector tables)
	_apply_shore_cliffs()
	# 3) donor detail variety (loadtextureterrainfrombitmap.inc): cells still
	# on the default block get their TileBlock from the low/high-ground
	# bitmaps (R div 2), picked by height.  Donor order is TextureMap ->
	# bitmap base -> SmoothTiles (DTRN-01 §4 / RV-TRN-02 §4.4), so the
	# detail tiles are reconciled too instead of being left as final cells.
	_apply_detail_pass(brng)
	# B03-P2 (PORT APPROXIMATION, A04 §6 P2): restore the donor's
	# SetupTiledPatterns('tiles') background-detail pass structurally. The tls_*
	# masks are real donor decal footprints placed by pattern_gen.gd:230-251 and
	# stored on kind=="tile" stamps, but game.gd:838-839 drops them (they are
	# thin decals, not terrain recolour). Paint their exact donor mask cells with
	# the nearest existing donor id, ground1 (Item 9 J=0 cfg:818 / donor
	# texturemap.inc:622-642 worked ground). No new stamp, no RNG draw, no change
	# to terrain/blocked - the mapgen stream stays byte-identical; the 3-pass
	# donor smoothing below reconciles the new borders with donor rules and the
	# final mine-apron authority still wins. P3 (full 25-unit donor grid) is
	# deliberately NOT attempted: it touches pattern_gen.gd and the stamp RNG.
	for ps in pattern_stamps:
		var pst: Object = ps
		if str(pst.kind) != "tile":
			continue
		for pc in (pst.cells as Array):
			var pcc: Vector2i = pc
			var px: int = int(pst.x) + pcc.x
			var py: int = int(pst.y) + pcc.y
			if px < 0 or py < 0 or px >= MAP_W or py >= MAP_H:
				continue
			var pti := _t(px, py)
			if tileblock[pti] != BLK_WATER:
				tileblock[pti] = _blk("ground1")
	# L01-IMPL (PORT APPROXIMATION, L01_spot_grass.md §5): organic light/dark
	# grass SPOTS from the already-placed FOREST stamp masks — the FILLED core
	# discs computed in _gen_patterns above (:772-807), never raw sparse st.cells
	# (that would lattice) and never the height-derived detail bitmaps Y03
	# neutralised (that would restore the maze). 1-6 contiguous cells per run;
	# donor tilesmooth weights only; brng-only determinism. Runs BEFORE the
	# 3-pass smoother so donor rules reconcile every spot border; mine apron and
	# winter alias still win last. Y03's grass9 detail neutralisation is intact.
	_stamp_grass_spots(brng)
	# 4) exact 3-pass SmoothTileMap (donor smoothtiles.inc:191-237): three
	# passes, horizontal then vertical, over the FINAL tile field before UV2.
	# TRN-DATA: the donor rule table now covers all 118 active lists.
	_smooth_tilemap(brng, 3)
	# 5) forest-border stamps (donor smoothforestborders.inc: grass5/rock9
	# tiles + bushes at edge cells with exactly one forest neighbour)
	_stamp_forest_borders(brng)
	# T2GEN P0-1: final authority - real mine worked ground, after every
	# smoothing/detail/border pass that could otherwise reintroduce a test*
	# transition tile inside the apron.
	for mi in mine_mask.size():
		if mine_mask[mi] != 0:
			tileblock[mi] = _blk("ground1")
	# Y08 (PORT APPROXIMATION): FINAL AUTHORITY. Collapse every ordinary land
	# cell to ONE clean donor id (test8 idx 79; A03 §4 isotropic/seamless, alpha
	# patch (0,0) constant 1.0) AFTER smoothing, forest borders, L01 spots and
	# the mine apron, so no per-cell colour ring, spot or checkerboard survives
	# into UV2.x. Exceptions are only donor-required roles: water, shore/sand,
	# rock/cliff and roads. Mine worked ground is now visible-meadow too. _blk() draws no RNG; no terrain/height/
	# blocked write. Placement BEFORE the winter alias keeps season art intact.
	var meadow_id := _blk("test8")
	for i in tileblock.size():
		if int(tileblock[i]) == BLK_WATER:   # 255, game.gd:52
			continue
		if mine_mask[i] != 0:                # Y08b: VISIBLE id only; mask/terrain untouched
			tileblock[i] = meadow_id
			continue
		var role: int = int(terrain[i])
		if role == 1 or role == 3 or role == 4 or role == 5:
			continue  # road / water / shore-sand / rock-cliff
		tileblock[i] = meadow_id
	# T2GEN P2-5: expose the winter art selection without touching the tile
	# index table or world.gd's tint.  This block is a no-op on Summer maps;
	# TRN-DATA changes the tileblock bytes but leaves every other seed output
	# (terrain / blocked / res_nodes / starts) byte-identical.
	winter_tile_names.clear()
	if str(Data.BIOME) == "winter":
		winter_tile_names.resize(tileblock.size())
		for i in tileblock.size():
			winter_tile_names[i] = "" if tileblock[i] == BLK_WATER else winter_block_for(tileblock[i])

func _shore_tile_for(x: int, y: int) -> String:
	# donor texturemap.inc: shore tiles key off the HEIGHT GRADIENT at the
	# cell (lh-rh, th-bh, vecangle+180 into 8 sectors), not the direction to
	# water. bLB->sandsea5 bRB->sandsea6 bB->sandsea1 bL/bR->sandsea6
	# bT->sandsea1 bRT->sandsea5 bLT->sandsea6.
	if height.size() != MAP_W * MAP_H:
		return "sandsea6"
	var lh: float = height[_t(maxi(0, x - 1), y)]
	var rh: float = height[_t(mini(MAP_W - 1, x + 1), y)]
	var th: float = height[_t(x, maxi(0, y - 1))]
	var bh: float = height[_t(x, mini(MAP_H - 1, y + 1))]
	var dx := lh - rh
	var dy := th - bh
	if absf(dx) < 0.005 and absf(dy) < 0.005:
		return "sandsea6"
	# T2GEN P0-2b: exact donor texturemap.inc:433-511 orientation.
	# 1) vecangle = VectorAngle(1,0,  dirX,0,dirY)  == atan2(dy, dx).
	# 2) if dirY < 0 then vecangle := -vecangle   (fold the southern half).
	# 3) vecangle += 180, wrap to [0,360), then 8 UNIFORM 45-degree sectors:
	#    sector = floor((ang + 22.5)/45) % 8.  The old code gave bR a 67.5deg
	#    window and bRT only 22.5deg, collapsing three tiles into one look.
	var ang := rad_to_deg(atan2(dy, dx))
	if dy < 0.0:
		ang = -ang
	ang = fposmod(ang + 180.0, 360.0)
	var sector := int(floor((ang + 22.5) / 45.0)) % 8
	# bR, bRB, bB, bLB, bL, bLT, bT, bRT  (donor :503-511 / shore_sand.md 1.2)
	var SECTOR_TILES := ["sandsea6", "sandsea6", "sandsea1", "sandsea5",
		"sandsea6", "sandsea6", "sandsea1", "sandsea5"]
	return SECTOR_TILES[sector]

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
			var nm := str(td.get("name", ""))
			# B03-P3 (PORT APPROXIMATION, A03 §2/§4): the donor lists that emit
			# grass_ground1/2/3 (Item 4/5/6 J=3, 0.64/0.0028/0.36, and Item 8 J=2)
			# stay verbatim in DONOR_SMOOTH_RULES; only the ART chosen for those
			# three draws is redirected to clean donor ids (A03: grass9 = best
			# isotropic/seamless; test8/test7 = good isotropic/seamless). No new
			# id, no extra RNG draw, no luminance/noise/dither field. The donor
			# does not swap art by quality, so this is an explicit port-level
			# substitution, not donor parity (UNVERIFIED).
			if nm == "grass_ground1":
				return _blk("grass9")
			if nm == "grass_ground2":
				return _blk("test8")
			if nm == "grass_ground3":
				return _blk("test7")
			return _blk(nm)
	return -1

func _tb_smooth_pair(x1: int, y1: int, x2: int, y2: int, brng: RandomNumberGenerator) -> void:
	# T2GEN P0-1: smoothing must not replace a mine apron's neutral ground1
	# with a test2/test3 transition tile (mines_display.md A2).
	if mine_mask[_t(x1, y1)] != 0 or mine_mask[_t(x2, y2)] != 0:
		return
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
		if ni >= 0 and int(tileblock[_t(x1, y1)]) != _blk("test8") and int(tileblock[_t(x1, y1)]) != _blk("grass9"):
			tileblock[_t(x1, y1)] = ni
	elif bi2 - bi1 == 2:
		var ni2 := _tb_pick(best, int((bi1 + bi2) / 2), brng)
		if ni2 >= 0 and int(tileblock[_t(x2, y2)]) != _blk("test8") and int(tileblock[_t(x2, y2)]) != _blk("grass9"):
			tileblock[_t(x2, y2)] = ni2
	elif bi1 < bi2:
		var ni3 := _tb_pick(best, bi1 + 1, brng)
		if ni3 >= 0 and int(tileblock[_t(x2, y2)]) != _blk("test8") and int(tileblock[_t(x2, y2)]) != _blk("grass9"):
			tileblock[_t(x2, y2)] = ni3
	else:
		var ni4 := _tb_pick(best, bi2 + 1, brng)
		if ni4 >= 0 and int(tileblock[_t(x1, y1)]) != _blk("test8") and int(tileblock[_t(x1, y1)]) != _blk("grass9"):
			tileblock[_t(x1, y1)] = ni4

func _smooth_tilemap(brng: RandomNumberGenerator, passes: int = 3) -> void:
	for _pass in passes:
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

# L01-IMPL (PORT APPROXIMATION, L01_spot_grass.md §3/§4/§5): stamp-mask grass
# spots. Every id and every probability comes from the embedded donor data;
# repurposing donor rule weights for run length / polarity / light-id choice and
# using the forest core disc as a ground stencil are port-level substitutions,
# NOT donor parity (CHARTER §3; no donor GPU A/B frame). No hash, noise, dither
# or luminance field — S-25-09 honoured.
func _stamp_grass_spots(brng: RandomNumberGenerator) -> void:
	var id_dark := _tb_pick(7, 1, brng)  # grass5, Item 7 J=1 cfg:762, prob 1.0
	if id_dark < 0:
		return
	# Post-Y03 meadow base ids: the detail pass now emits grass9, forest interiors
	# keep the DONOR_FOREST_BASE family; grass1/test7/8/9 are legacy leftovers.
	var base_ids := [_blk("grass1"), _blk("grass9"), _blk("test7"), _blk("test8"), _blk("test9")]
	for fp in DONOR_FOREST_BASE:
		base_ids.append(_blk(str(fp[0])))
	var size_k := clampf(float(MAP_W) / 320.0, 0.60, 1.0)
	var row_w: Array = tbl_smooth[8][2]  # Item 8 J=2 cfg:798 .36/.28/.36, SumProb 1
	if row_w.size() < 3:
		return
	var row_prob := float(row_w[0].get("prob", 0.0))  # donor .36 -> row eligibility
	for ps in pattern_stamps:
		var st: Object = ps
		if str(st.kind) != "forest":
			continue
		# Same FILLED core disc _gen_patterns already paints (:772-807). Raw
		# st.cells are s-scaled *..*..* and would produce a one-cell lattice.
		var cext := 0.0
		for c0 in (st.cells as Array):
			var cc0: Vector2i = c0
			cext = maxf(cext, float(maxi(abs(cc0.x), abs(cc0.y))) * TILE)
		var core_r: float = clampf(cext * 0.25, 14.0 * TILE, 22.0 * TILE) * size_k
		var steps: int = ceili(core_r / TILE)
		var cx: int = int(st.x)
		var cy: int = int(st.y)
		var cpos := Vector2((float(cx) + 0.5) * TILE, (float(cy) + 0.5) * TILE)
		var rows: Dictionary = {}
		for yy in range(maxi(0, cy - steps), mini(MAP_H - 1, cy + steps) + 1):
			for xx in range(maxi(0, cx - steps), mini(MAP_W - 1, cx + steps) + 1):
				var i := _t(xx, yy)
				if mine_mask[i] != 0 or tileblock[i] == BLK_WATER:
					continue
				var tt: int = terrain[i]
				if tt == 3 or tt == 4 or tt == 5:
					continue
				var p2 := Vector2((float(xx) + 0.5) * TILE, (float(yy) + 0.5) * TILE)
				if p2.distance_to(cpos) > core_r:
					continue
				var in_ring := false
				for sp in map_starts:
					if p2.distance_to(sp as Vector2) < 7.0 * TILE:
						in_ring = true
						break
				if in_ring:
					continue
				if not base_ids.has(int(tileblock[i])):
					continue
				if not rows.has(yy):
					rows[yy] = [xx, xx, [xx]]
				else:
					var rg: Array = rows[yy]
					rg[1] = xx
					var accx: Array = rg[2]
					accx.append(xx)
		# Dictionary keys were inserted in ascending yy; row runs follow the
		# stamp disc outline, so spots are organic, never a fixed grid cadence.
		for yy in rows.keys():
			if brng.randf() >= row_prob:
				continue
			var rg2: Array = rows[yy]
			var x0: int = int(rg2[0])
			var x1: int = int(rg2[1])
			var n := _donor_run_len(brng)  # 1-6 from cfg:67
			if x1 - x0 + 1 < n:
				continue
			var xs := brng.randi_range(x0, x1 - n + 1)
			var tid: int = id_dark
			if _donor_polarity(brng):  # 0.4 light / 0.6 dark from cfg:846
				tid = _donor_light_id(brng, row_w)  # grass9/test9/test8
			if tid < 0:
				continue
			# Only paint cells that actually passed every guard above: the row's
			# min/max can span filtered-out water/shore/mine/start-ring cells.
			var accx: Array = rg2[2]
			var contiguous := true
			for k in n:
				if not accx.has(xs + k):
					contiguous = false
					break
			if not contiguous:
				continue
			for k in n:
				tileblock[_t(xs + k, yy)] = tid

# L01 PORT APPROX: Item 0 J=3 cfg:67 .16x5/.20 -> run length 1..6.
func _donor_run_len(brng: RandomNumberGenerator) -> int:
	var g: Array = tbl_smooth[0][3]
	var total := 0.0
	for td in g:
		total += float(td.get("prob", 0.0))
	if total <= 0.0:
		return 1
	var r := brng.randf() * total
	var acc := 0.0
	for i in g.size():
		acc += float(g[i].get("prob", 0.0))
		if r < acc:
			return i + 1
	return g.size()

# L01 PORT APPROX: Item 9 J=3 cfg:846 test8:.4 / test7:.6 -> light/dark.
func _donor_polarity(brng: RandomNumberGenerator) -> bool:
	var g: Array = tbl_smooth[9][3]
	var total := 0.0
	for td in g:
		total += float(td.get("prob", 0.0))
	if total <= 0.0:
		return false
	var r := brng.randf() * total
	var acc := 0.0
	for i in g.size():
		acc += float(g[i].get("prob", 0.0))
		if r < acc:
			return i == 0  # test8 weight .4 -> light; test7 .6 -> dark
	return false

# L01 PORT APPROX: cfg:798 .36/.28/.36 -> grass9/test9/test8 (all A03-clean).
func _donor_light_id(brng: RandomNumberGenerator, weights: Array) -> int:
	var picks := [_blk("grass9"), _blk("test9"), _blk("test8")]
	var total := 0.0
	for td in weights:
		total += float(td.get("prob", 0.0))
	if total <= 0.0:
		return picks[0]
	var r := brng.randf() * total
	var acc := 0.0
	for i in picks.size():
		acc += float(weights[i].get("prob", 0.0))
		if r < acc:
			return picks[i]
	return picks[picks.size() - 1]

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
		var v: int = 1 if value else 0
		if blocked[_t(x, y)] != v:
			blocked[_t(x, y)] = v
			nav_version += 1

func _draw_road(a: Vector2, b: Vector2) -> void:
	# Narrow organic cart track (single tile, noisy centre line, feathered rim)
	# instead of the old 3x3 square stamp that paved a highway of dirt.
	var steps := int(a.distance_to(b) / TILE) + 1
	for i in steps:
		var p: Vector2 = a.lerp(b, float(i) / maxf(1.0, float(steps - 1)))
		p += Vector2(_noise2(p.x * 0.35, p.y * 0.35), _noise2(p.y * 0.35 + 9.0, p.x * 0.35)) * 2.0
		var t := tile_of(p)
		if t.x < 0 or t.y < 0 or t.x >= MAP_W or t.y >= MAP_H:
			continue
		var ri := _t(t.x, t.y)
		if terrain[ri] == 3:
			continue
		# a road is walkable: clear any cliff block it covers
		if terrain[ri] == 5:
			blocked[ri] = 0
		terrain[ri] = 1
		# dithered single-tile fringe, not a full 3x3 block
		for d: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var xx: int = t.x + d.x
			var yy: int = t.y + d.y
			if xx < 0 or yy < 0 or xx >= MAP_W or yy >= MAP_H:
				continue
			var rj := _t(xx, yy)
			if terrain[rj] == 3 or terrain[rj] == 1:
				continue
			if _noise2(float(xx) * 0.9 + 3.0, float(yy) * 0.9 - 8.0) > 0.25:
				if terrain[rj] == 5:
					blocked[rj] = 0
				terrain[rj] = 1

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
		# impassable footprint matches the drawn visual (true-scale art is up
		# to 2x the old gameplay radius; blocking only the small radius let
		# units walk through walls visually). Stored so destroy unblocks
		# exactly what was blocked.
		var br: float = bld_block_r(e) if sid != "gat" else 0.0
		e["block_r"] = br
		if br > 0.0:
			set_blocked_circle(pos, br, true)
		# The base circle covers only the ground footprint; the baked sprite is
		# a taller 2D block rising above the anchor.  Store that full ink box
		# as a movement obstacle so units cannot slip under it from any side.
		# It is NOT stamped into `blocked` (terrain/placement use that grid);
		# _blocked_for and A* consult it as a dynamic obstacle instead.
		if sid != "gat":
			var brect := bld_block_rect(e)
			if brect.has_area():
				e["block_rect"] = brect
		if sid == "gat":
			gates.append(e)
		if finished:
			_on_building_finished(e)
		else:
			bld_dirty += 1
	players[player].score += def.get("score", 0)
	return e

# W3-1: shared default rally for trainers, used both on completion and after a
# capture (X1 C10) so _on_building_finished is not the only place that sets it.
func _default_rally(e: Dictionary) -> Vector2:
	return e.pos + Vector2(0, float(e.get("block_r", e.def.radius)) + 2.0)

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
		e["rally"] = _default_rally(e)
	if e.sid == "mil":
		# FIX-FIELDS: the demo switch selects the X22 donor routine; with the
		# feature absent/false this remains the legacy completion behaviour.
		_sow_field_ring(e, _demo_mill_enabled())
	bld_dirty += 1

# P-50: donor _unit_DoSeedWheat (unit.script:6470-6570). cRow=7 -> 7x7 grid
# rotated 45 degrees (up to 49 tiles), size 1.6981 donor units; collision,
# water and nearby resource skips (unit.script:6504-6548). Each field costs
# 5 gold (unit.script:1691-1694) - paid per field here, no lump-sum inference.
const SOW_ROW := 7
const SOW_GOLD := 5
# T-MILL-CORE: hard cap of mill-owned fields. The 7x7 rotated ring holds at
# most SOW_ROW*SOW_ROW tiles; the clash check enforces it geometrically, but
# the explicit cap keeps repeated 60 s re-seeds from ever stacking fields.
const MAX_FIELDS_PER_MILL := 49
# X22 / unit.script:6477, dmscript.global:178, unit.script:6527. These are
# donor MAP-CELL units; TILE (2 m) performs the only port unit conversion.
const SOW_SIZE_CELLS := 1.6981
const SOW_COLLISION_SIZE_CELLS := 0.5
const SOW_RAD_CELLS := SOW_SIZE_CELLS * 0.9 * 3.0

func _sow_field_ring(mill: Dictionary, donor_rules := false) -> int:
	if mill.is_empty() or str(mill.sid) != "mil" or not bool(mill.get("finished", false)):
		return 0
	var owned := 0
	for n in res_nodes:
		if n.has("mill") and int(n.mill) == int(mill.id):
			owned += 1
	if owned >= MAX_FIELDS_PER_MILL:
		return 0
	if donor_rules:
		return _sow_donor_field_ring(mill, owned)
	var player: int = int(mill.player)
	var made := 0
	var step := 1.6981 * TILE * 0.5
	for r in SOW_ROW:
		for c in SOW_ROW:
			var rr := r - SOW_ROW / 2
			var cc := c - SOW_ROW / 2
			var p: Vector2 = Vector2(mill.pos) + Vector2(float(cc - rr), float(cc + rr)) * step
			if not in_bounds(p) or is_blocked(p):
				continue
			var ti := _t(int(p.x / TILE), int(p.y / TILE))
			var tt: int = terrain[ti]
			if tt == 3 or tt == 4 or tt == 5:
				continue
			var clash := false
			for n in res_nodes:
				if n.type == "food" or n.type == "wood" or n.type == "stone":
					if n.pos.distance_to(p) < 1.5 * TILE:
						clash = true
						break
			if clash:
				continue
			if players[player].res[3] < float(SOW_GOLD):
				break
			pay_cost(player, {"gold": SOW_GOLD})
			_add_res("food", p, 50, 0.6)
			var f: Dictionary = res_nodes[res_nodes.size() - 1]
			f["mill"] = mill.id
			made += 1
	return made

# X22 §4.2 literal transplant of _unit_DoSeedWheat geometry and gates. The
# collision-grid/resource-list adapters and direct completion trigger remain
# PORT APPROXIMATION; this makes no donor-parity claim and consumes no RNG.
func _sow_donor_field_ring(mill: Dictionary, owned: int) -> int:
	var player: int = int(mill.player)
	var made := 0
	var size := SOW_SIZE_CELLS * TILE
	var size2 := sqrt(2.0 * size * size)
	var base_x: float = floor((float(mill.pos.x) + size) / size2) * size2
	var base_y: float = floor((float(mill.pos.y) + size * 0.5) / size2) * size2
	var rot_c := cos(deg_to_rad(45.0))
	var rot_s := sin(deg_to_rad(45.0))
	var soft_clear := (SOW_RAD_CELLS / 3.0) * TILE
	var ore_clear := SOW_RAD_CELLS * TILE
	for i in SOW_ROW * SOW_ROW:
		var dir_x := -((SOW_ROW - 0.5) * SOW_SIZE_CELLS / 2.0) + float(i % SOW_ROW) * SOW_SIZE_CELLS
		var dir_y := -((SOW_ROW - 0.5) * SOW_SIZE_CELLS / 2.0) + float(i / SOW_ROW) * SOW_SIZE_CELLS
		var rotated := Vector2(dir_x * rot_c + dir_y * rot_s, -dir_x * rot_s + dir_y * rot_c)
		var p := Vector2(base_x, base_y) + rotated * TILE
		var collision := false
		for j in 25:
			var probe_x := float(-2 + j / 5) * SOW_COLLISION_SIZE_CELLS
			var probe_y := float(-2 + j % 5) * SOW_COLLISION_SIZE_CELLS
			var probe_rot := Vector2(probe_x * rot_c + probe_y * rot_s, -probe_x * rot_s + probe_y * rot_c)
			var sample := p + probe_rot * TILE
			if not in_bounds(sample) or is_blocked(sample):
				collision = true
				break
			var st := tile_of(sample)
			var terrain_id := int(terrain[_t(st.x, st.y)])
			if terrain_id == 3 or terrain_id == 4 or terrain_id == 5:
				collision = true
				break
		if collision:
			continue
		var static_clash := false
		for n in res_nodes:
			var allow_dist := -1.0
			match str(n.get("type", "")):
				"food", "wood", "stone":
					allow_dist = soft_clear
				"gold", "iron", "coal":
					allow_dist = ore_clear
			if allow_dist >= 0.0 and n.pos.distance_to(p) < allow_dist:
				static_clash = true
				break
		if static_clash or owned + made >= MAX_FIELDS_PER_MILL:
			continue
		if players[player].res[3] < float(SOW_GOLD):
			continue
		if not pay_cost(player, {"gold": SOW_GOLD}):
			continue
		_add_res("food", p, 50, 0.6)
		var f: Dictionary = res_nodes[res_nodes.size() - 1]
		f["mill"] = mill.id
		made += 1
	return made

# P-51: donor "Grain Crops" production order (doprogressorders.inc:120-136).
# Restore this mill's depleted fields first (reusing the shared field path),
# then sow fresh ring tiles only if there is still room.
func cmd_sow(mill: Dictionary) -> int:
	var n := 0
	for node in res_nodes:
		if node.has("mill") and int(node.mill) == int(mill.id) and int(node.hits) <= 0:
			_restore_field(node)
			n += 1
	if n > 0:
		return n
	return _sow_field_ring(mill, _demo_mill_enabled())

# Shared restore used by the manual peasant resow tick and the ~60 s field
# growth timer, so there is only one field-restoration code path.
func _restore_field(node: Dictionary) -> void:
	node.hits = int(node.max_hits)
	node["growth"] = 1.0
	node["regrow_t"] = 0.0
	if float(node.get("regrow_time", 0.0)) <= 0.0:
		node["regrow_time"] = FIELD_REGROW_TIME
	res_dirty += 1
	post_event("construct", node.pos, "field")

# T-FIELDS-GFX: mill lookup for a field. Linked mill id first (O(1));
# falls back to adopting any finished mill within FIELD_MILL_RADIUS so
# rebuilt mills and donor seed strips near a mill still regrow.
# Hot path uses the int form (no per-tick Dictionary allocations).
func _field_mill_id(n: Dictionary) -> int:
	var mid := int(n.get("mill", 0))
	if mid != 0:
		var m: Dictionary = by_id.get(mid, {})
		if not m.is_empty() and not bool(m.get("dead", false)) \
				and bool(m.get("finished", false)) and str(m.get("sid", "")) == "mil" \
				and (m.pos as Vector2).distance_to(n.pos) <= FIELD_MILL_RADIUS:
			return mid
	for b in live_blds:
		if b.dead or str(b.get("sid", "")) != "mil" or not bool(b.get("finished", false)):
			continue
		if (b.pos as Vector2).distance_to(n.pos) <= FIELD_MILL_RADIUS:
			n["mill"] = int(b.id)
			return int(b.id)
	return 0

func _field_mill(n: Dictionary) -> Dictionary:
	var mid := _field_mill_id(n)
	if mid == 0:
		return {}
	return by_id.get(mid, {})

# T-FIELDS-GFX: auto-regrow gate. Only depleted mill fields with a finished
# owned mill nearby regrow; anything else stays depleted until resow.
func field_can_regrow(n: Dictionary) -> bool:
	if str(n.get("type", "")) != "food" or int(n.get("max_hits", 0)) <= 0 \
			or int(n.get("hits", 0)) > 0:
		return false
	return _field_mill_id(n) != 0

# T-FIELDS-GFX: HUD/minimap/world read the same state.
# ripe = harvestable, growing = live but partially eaten,
# regrowing = depleted but timer running, depleted = bare stubble.
func field_state(n: Dictionary) -> String:
	if str(n.get("type", "")) != "food":
		return ""
	if int(n.get("hits", 0)) > 0:
		var ratio := clampf(float(n.hits) / maxf(1.0, float(n.max_hits)), 0.0, 1.0)
		return "ripe" if ratio >= 0.75 else "growing"
	if float(n.get("regrow_t", 0.0)) > 0.0:
		return "regrowing"
	return "depleted"

# T-FIELDS-GFX: 0..1 progress for visuals. Live fields mirror hits ratio;
# depleted mill fields mirror regrow_t/regrow_time; bare fields are 0.
func field_growth01(n: Dictionary) -> float:
	if int(n.get("hits", 0)) > 0:
		return clampf(float(n.get("hits", 0)) / maxf(1.0, float(n.get("max_hits", 1))), 0.0, 1.0)
	var rt := float(n.get("regrow_time", FIELD_REGROW_TIME))
	if rt <= 0.0:
		return 0.0
	return clampf(float(n.get("regrow_t", 0.0)) / rt, 0.0, 1.0)

# T-FIELDS-GFX: mill panel counts (HUD). No allocations beyond the result dict.
func field_counts_for_mill(mill_id: int) -> Dictionary:
	var ripe := 0
	var growing := 0
	var regrowing := 0
	var depleted := 0
	for n in res_nodes:
		if str(n.get("type", "")) != "food" or int(n.get("max_hits", 0)) <= 0:
			continue
		if int(n.get("mill", 0)) != mill_id:
			continue
		match field_state(n):
			"ripe":
				ripe += 1
			"growing":
				growing += 1
			"regrowing":
				regrowing += 1
			_:
				depleted += 1
	return {"ripe": ripe, "growing": growing, "regrowing": regrowing, "depleted": depleted}

# T-FIELDS-GFX: per-tick fractional regrow. Only fields passing
# field_can_regrow() advance; the 60 s legacy timer below stays for AI sowing.
func _tick_fields(dt: float) -> void:
	var any := false
	for n in res_nodes:
		if str(n.get("type", "")) != "food" or int(n.get("max_hits", 0)) <= 0 \
				or int(n.get("hits", 0)) > 0:
			continue
		if _field_mill_id(n) == 0:
			if float(n.get("regrow_t", 0.0)) != 0.0:
				n["regrow_t"] = 0.0
				n["growth"] = 0.0
			continue
		var rt := float(n.get("regrow_time", FIELD_REGROW_TIME))
		if rt <= 0.0:
			rt = FIELD_REGROW_TIME
			n["regrow_time"] = rt
		n["regrow_t"] = float(n.get("regrow_t", 0.0)) + dt
		n["growth"] = clampf(float(n["regrow_t"]) / rt, 0.0, 1.0)
		any = true
		if float(n["regrow_t"]) >= rt:
			_restore_field(n)
	fields_anim = any

# Donor progresseconomicai.inc:3688-3700,3896 + dmscript.global:1487
# (gc_global_TimeSeedWheat = 0.03*2000, ~60 s). Only AI mills re-seed: the
# human adviser path is deferred by the skirmish-only charter. Field regrowth
# maps donor HP -> port hits (nothing.inc:78-84, derived).
# T-FIELDS-GFX: the legacy bulk restore now respects the mill gate too.
func _tick_field_growth() -> void:
	for pi in players.size():
		if not bool(players[pi].get("is_ai", false)):
			continue
		for b in buildings_of(pi, false):
			if b.sid == "mil" and b.finished:
				_sow_field_ring(b, _demo_mill_enabled())
	for n in res_nodes:
		if n.type == "food" and n.has("mill") and int(n.hits) <= 0 and int(n.max_hits) > 0:
			if _field_mill_id(n) != 0:
				_restore_field(n)

func _start_positions(count := 0) -> Array[Vector2]:
	# Donor dogenerate.inc keeps arrStartPos[0..7] regardless of player count.
	# T-MENU-MORE-PLAYERS: PORT EXTENSION adds four more well-separated anchors
	# (slots 8..11) so a 9..12-player skirmish gets real starts. The original
	# eight keep their exact positions/order, so 2..8-player maps stay
	# byte-identical. count=0 returns all 12.
	var w := float(MAP_W) * TILE
	var h := float(MAP_H) * TILE
	var slots: Array[Vector2] = [Vector2(w * 0.125, h * 0.125), Vector2(w * 0.875, h * 0.875),
		Vector2(w * 0.5, h * 0.10), Vector2(w * 0.5, h * 0.90),
		Vector2(w * 0.10, h * 0.5), Vector2(w * 0.90, h * 0.5),
		Vector2(w * 0.27, h * 0.27), Vector2(w * 0.73, h * 0.73),
		Vector2(w * 0.125, h * 0.875), Vector2(w * 0.875, h * 0.125),
		Vector2(w * 0.27, h * 0.73), Vector2(w * 0.73, h * 0.27)]
	if count > 0:
		return slots.slice(0, mini(count, slots.size()))
	return slots

# Append extra donor-style starts AFTER generation so the default 2-player
# map stays byte-identical (no extra RNG draws, no extra grove/resource paint).
# Only the count exposed to sim consumers changes.
func _ensure_start_slots() -> void:
	# T-MENU-MORE-PLAYERS: the old literal 8 clamped 9..12-player lobbies to 8
	# starts (so players 9..12 had no town). Follow the shared cap instead.
	var need: int = clampi(maxi(4, int(Data.PLAYER_COUNT)), 2, Data.MAX_PLAYERS)
	if map_starts.size() >= need:
		return
	for sv in _start_positions(need):
		if map_starts.size() >= need:
			break
		var too_close := false
		for st in map_starts:
			if st.distance_to(sv) < 18.0 * TILE:
				too_close = true
				break
		if not too_close:
			map_starts.append(sv)
			_provision_extra_start(sv)

# Donor SetupStartingResources provisions every arrStartPos slot, used or not.
# Give an appended slot a compact deterministic package so a 3rd/4th player and
# the QA reach check both see stone / all three ores / wood nearby.
# T-FOOD-1: NO food here either - food comes strictly from mills, even on
# appended starts.
# scan_map.py quarry_purity: stone must be >8 m from any live wood.
# scan_map.py mine_clearance: ore must be >=10 m from any live wood.
# This pass runs AFTER all generation on a deterministic spiral (no global
# rng draw), so default-seed maps keep their original RNG stream.
func _provision_spot_clear(p: Vector2, t: String) -> bool:
	for n in res_nodes:
		var nt := str(n.type)
		if nt != "wood" and nt != "stone" and nt != "gold" and nt != "iron" and nt != "coal":
			continue
		var d: float = n.pos.distance_to(p)
		if t == "wood":
			if nt == "stone" and int(n.hits) > 0 and d <= 8.5:
				return false
			if (nt == "gold" or nt == "iron" or nt == "coal") and d <= 10.5:
				return false
		elif t == "stone":
			if nt == "wood" and int(n.hits) > 0 and d <= 8.5:
				return false
		elif t == "gold" or t == "iron" or t == "coal":
			if nt == "wood" and int(n.hits) > 0 and d <= 10.5:
				return false
	return true

# Constraint-aware provisioning for appended starts (post-generation, no rng).
func _provision_extra_start(sv: Vector2) -> void:
	var types: Array[String] = ["wood", "stone", "gold", "iron", "coal"]
	# T-MINES-FIX: wider rings so the footprint-aware ore check below still has
	# open ground to land on (the pattern-gen mines are now strictly spaced).
	var rings := [4.0, 6.0, 8.0, 10.0, 12.0, 14.0, 16.0, 18.0, 20.0, 22.0, 24.0]
	for i in types.size():
		var t := types[i]
		var placed := false
		for ring in rings:
			for k in 12:
				var a := TAU * float(k) / 12.0 + float(i) * 0.41
				var p: Vector2 = sv + Vector2(cos(a), sin(a)) * (float(ring) * TILE)
				if not in_bounds(p):
					continue
				var ti := _t(int(p.x / TILE), int(p.y / TILE))
				if terrain[ti] == 3 or terrain[ti] == 4 or terrain[ti] == 5:
					continue
				if not _provision_spot_clear(p, t):
					continue
				# T-MINES-FIX: provisioned deposits must obey the SAME footprint
				# separation as stamped mines (they get a 3-tile apron too).
				if str(t) in ["gold", "iron", "coal"] and not _ore_spot_clear(p):
					continue
				var hits: int = 60 if t == "wood" else (0 if t in ["gold", "iron", "coal"] else 50)
				_add_res(t, p, hits, 0.0)
				var node: Dictionary = res_nodes[res_nodes.size() - 1]
				node["provisioned"] = true
				placed = true
				break
			if placed:
				break

# Same BFS as scan_map.reachability (radius 25 tiles at 160 -> 50 at 320).
func _start_reach_set(sv: Vector2, rad: int) -> Dictionary:
	var stx: int = int(sv.x / TILE)
	var sty: int = int(sv.y / TILE)
	if stx < 0 or sty < 0 or stx >= MAP_W or sty >= MAP_H or blocked[_t(stx, sty)] != 0:
		var found := false
		for r in range(1, 8):
			for dy in range(-r, r + 1):
				for dx in range(-r, r + 1):
					var nx: int = stx + dx
					var ny: int = sty + dy
					if nx < 0 or ny < 0 or nx >= MAP_W or ny >= MAP_H:
						continue
					if blocked[_t(nx, ny)] == 0:
						stx = nx
						sty = ny
						found = true
						break
				if found:
					break
			if found:
				break
		if not found:
			return {}
	var seen := {}
	seen[_t(stx, sty)] = true
	var q: Array = [[stx, sty, 0]]
	var head := 0
	var dirs := [[1, 0], [-1, 0], [0, 1], [0, -1]]
	while head < q.size():
		var cur: Array = q[head]
		head += 1
		var x: int = int(cur[0])
		var y: int = int(cur[1])
		var dd: int = int(cur[2])
		if dd >= rad:
			continue
		for d2 in dirs:
			var nx: int = x + int(d2[0])
			var ny: int = y + int(d2[1])
			if nx < 0 or ny < 0 or nx >= MAP_W or ny >= MAP_H:
				continue
			var ni := _t(nx, ny)
			if seen.has(ni) or blocked[ni] != 0:
				continue
			seen[ni] = true
			q.append([nx, ny, dd + 1])
	return seen

func _reach_has_kind(reach: Dictionary, grp: Array) -> bool:
	for n in res_nodes:
		if not (str(n.type) in grp):
			continue
		var tx: int = int(n.pos.x / TILE)
		var ty: int = int(n.pos.y / TILE)
		for dy in range(-2, 3):
			for dx in range(-2, 3):
				var nx: int = tx + dx
				var ny: int = ty + dy
				if nx < 0 or ny < 0 or nx >= MAP_W or ny >= MAP_H:
					continue
				if reach.has(_t(nx, ny)):
					return true
	return false

# Post-generation reach repair. Add only kinds that the scan's BFS truly
# cannot reach from a start, on a deterministic spiral landing on a reachable
# land tile, clear of quarry-purity / mine-clearance rules. radius 0 adds no
# blocked circle and no global rng draw, so default seeds stay byte-identical.
func _repair_start_reach() -> void:
	var groups: Array = [["stone"], ["wood"], ["gold", "iron", "coal"]]
	var rings := [3.0, 4.0, 6.0, 8.0, 10.0, 12.0, 16.0]
	var rad: int = maxi(1, int(round(25.0 * float(MAP_W) / 160.0)))
	for si in map_starts.size():
		# Only the AI opponent's home slot is repaired: player 0's start is the
		# gameplay/selftest reference and the appended slots were just provisioned.
		if si != 1:
			continue
		var sv: Vector2 = map_starts[si]
		var reach := _start_reach_set(sv, rad)
		if reach.is_empty():
			continue
		for gi in groups.size():
			var grp: Array = groups[gi]
			if _reach_has_kind(reach, grp):
				continue
			var rep: String = str(grp[0])
			var placed := false
			for ring in rings:
				for k in 12:
					var a := TAU * float(k) / 12.0 + float(gi) * 0.31
					var p: Vector2 = sv + Vector2(cos(a), sin(a)) * (float(ring) * TILE)
					if not in_bounds(p):
						continue
					var ti := _t(int(p.x / TILE), int(p.y / TILE))
					if terrain[ti] == 3 or terrain[ti] == 4 or terrain[ti] == 5:
						continue
					if not reach.has(ti) or not _provision_spot_clear(p, rep):
						continue
					# T-MINES-FIX: same footprint rule as every other ore path.
					if str(rep) in ["gold", "iron", "coal"] and not _ore_spot_clear(p):
						continue
					var hits: int = 60 if rep == "wood" else (0 if rep in ["gold", "iron", "coal"] else 50)
					_add_res(rep, p, hits, 0.0)
					var node: Dictionary = res_nodes[res_nodes.size() - 1]
					node["provisioned"] = true
					placed = true
					break
				if placed:
					break

func _spawn_starts() -> void:
	# The donor reads startx/starty from the chosen mask's white markers;
	# spawning at fixed corners would leave the player far from its guaranteed
	# grove/fields/deposits (the exact "something is wrong" symptom).
	var starts: Array[Vector2] = map_starts if map_starts.size() >= players.size() else _start_positions()
	var opt: Dictionary = Data.START_OPTIONS.get(Data.START_OPTION, {"army_mult": 0.0, "food": 0, "towers": 0, "cannons": 0})
	for i in players.size():
		var c := starts[i]
		var cen := spawn("cen", i, c)
		var cr: float = float(cen.get("block_r", cen.def.radius))
		players[i].res[0] += float(opt.get("food", 0))
		var peasant_cols := maxi(1, int(ceil(float(Data.START_PEASANTS) * 0.5)))
		var peasant_spacing := 1.8
		for k in Data.START_PEASANTS:
			# PORT APPROXIMATION — owner usability request: compact two-row
			# starting group in front of the hall on camera-forward SIM/world +X.
			# This is a usability layout, not a donor placement claim.
			var row: int = int(k) / peasant_cols
			var col: int = int(k) % peasant_cols
			var row_count := mini(peasant_cols, int(Data.START_PEASANTS) - row * peasant_cols)
			var lane := (float(col) - float(row_count - 1) * 0.5) * peasant_spacing
			var front := cr + 2.5 + float(row) * peasant_spacing
			# _start_free_pos adds 2 m to its radius argument. Shift its anchor
			# laterally so the 0-radian +X search preserves the row alignment.
			var pe := spawn("peasant", i, _start_free_pos(c + Vector2(0.0, lane), front - 2.0, 0.0))
			pe.order = {"type": "none"}
			pe.face = 0.0  # world3d_entities: face 0.0 -> world/sim +X
		# starting option extras: towers / cannons near the town
		for t in int(opt.get("towers", 0)):
			spawn("tow", i, c + Vector2(cr + 4.0 + t * 4.0, -5.0))
		for cc in int(opt.get("cannons", 0)):
			spawn("cannon", i, c + Vector2(-(cr + 3.0) - cc * 3.0, 5.0))
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
					spawn(_spawn_sid(i, sid), i, c + Vector2(cos(a), sin(a)) * (cr + 3.0 + (ring % 4) * 1.5))
					ring += 1
	if _demo_mill_enabled():
		_spawn_demo_mill(starts[0])

# FIX-FIELDS: opt-in QA-only mill/field fixture. Reading through C3Config.flag
# keeps missing/malformed keys at false and leaves the default game untouched.
func _demo_mill_enabled() -> bool:
	var cfg: Variant = C3ConfigScript.active
	if not (cfg is Object) or not cfg.has_method("flag"):
		return false
	return bool(cfg.call("flag", "features.terrain.demo_mill", false))

func _spawn_demo_mill(hall_pos: Vector2) -> void:
	# setup_spawns() can be called again while rebuilding a roster/world. The
	# marker makes that idempotent: one demo mill, one donor field sowing.
	for b in live_blds:
		if not b.dead and int(b.player) == 0 and str(b.sid) == "mil" \
				and bool(b.get("terrain_demo_mill", false)):
			return
	# Deterministic nearest-ring search, +X first. can_place() enforces map,
	# terrain, building and resource clearance; no RNG draw is consumed.
	var mill_pos := Vector2.INF
	for ring in range(2, 13):
		for k in range(16):
			var a := TAU * float(k) / 16.0
			var p := hall_pos + Vector2(cos(a), sin(a)) * (float(ring) * TILE)
			if not in_bounds(p) or is_blocked(p):
				continue
			var pt := tile_of(p)
			var terrain_id := int(terrain[_t(pt.x, pt.y)])
			if terrain_id == 3 or terrain_id == 4 or terrain_id == 5:
				continue
			if bool(can_place(0, "mil", p).get("ok", false)):
				mill_pos = p
				break
		if mill_pos != Vector2.INF:
			break
	if not in_bounds(mill_pos):
		return
	# The normal finished-spawn hook invokes the same mill->field path as any
	# completed mill; the marker only makes later start rebuilds idempotent.
	var mill := spawn("mil", 0, mill_pos, true)
	mill["terrain_demo_mill"] = true

# Pick a free tile for a starting villager in direction `a` (given in the
# lower/south half of the screen, 0..PI, so the tall town-hall sprite to the
# north is never overlapped).  Step outward until the tile is on the map and
# unblocked; if that direction is crowded, try neighbouring south angles.
func _start_free_pos(c: Vector2, cr: float, a: float) -> Vector2:
	var r0: float = cr + 2.0
	for step in 5:
		var p := c + Vector2(cos(a), sin(a)) * (r0 + float(step) * TILE)
		if in_bounds(p) and not is_blocked(p):
			return p
	for da in [-0.3, 0.3, -0.6, 0.6, -0.9, 0.9]:
		var aa: float = clampf(a + da, 0.05, PI - 0.05)
		for step in 4:
			var p := c + Vector2(cos(aa), sin(aa)) * (r0 + float(step) * TILE)
			if in_bounds(p) and not is_blocked(p):
				return p
	return c + Vector2(0.0, r0)

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
	# T-PERF-SIM: spatial-hash query. Scans only buckets overlapped by the
	# max_r square instead of every node on the map. Filters and the strict
	# `< best_d` nearest rule are unchanged, so results match the old brute
	# force (up to exact-distance ties, which are measure-zero).
	_res_grid_ensure()
	var best: Dictionary = {}
	var best_d := max_r
	var c0 := Vector2i(int((pos.x - max_r) / RES_GRID_M), int((pos.y - max_r) / RES_GRID_M))
	var c1 := Vector2i(int((pos.x + max_r) / RES_GRID_M), int((pos.y + max_r) / RES_GRID_M))
	for cy in range(c0.y, c1.y + 1):
		for cx in range(c0.x, c1.x + 1):
			var cell: Array = _res_grid.get(Vector2i(cx, cy), [])
			for n in cell:
				if n.type != type or n.hits <= 0:
					continue
				# T-FOOD-1: food comes strictly through the mill cycle. Wild (mill-less)
				# food nodes - mapgen no longer places any, but old saves or debug
				# spawns might - are never auto-targeted.
				if type == "food" and not n.has("mill"):
					continue
				if avoid != 0 and int(n.id) == avoid:
					continue
				var d: float = n.pos.distance_to(pos)
				if d < best_d:
					best_d = d
					best = n
	return best

# T-PERF-SIM: rebuild the resource hash when the node set changes. Tracks both
# res_dirty and array size (mapgen/_compact mutate hits/membership without
# always bumping res_dirty).
var _res_grid_src_size := -1
func _res_grid_ensure() -> void:
	if _res_grid_ver == res_dirty and _res_grid_src_size == res_nodes.size():
		return
	_res_grid.clear()
	for n in res_nodes:
		# Live gatherables plus inexhaustible deposits (max_hits == 0, needed
		# by can_place's mine-site/resource checks); depleted gatherables are
		# never queried spatially.
		if int(n.get("hits", 0)) <= 0 and int(n.get("max_hits", 0)) != 0:
			continue
		var c := Vector2i(int(n.pos.x / RES_GRID_M), int(n.pos.y / RES_GRID_M))
		if not _res_grid.has(c):
			_res_grid[c] = []
		(_res_grid[c] as Array).append(n)
	_res_grid_ver = res_dirty
	_res_grid_src_size = res_nodes.size()

func nearest_mine(pos: Vector2, res: String, player := -1) -> Dictionary:
	var best: Dictionary = {}
	var best_d := 1e9
	# T-PERF-SIM: scan live_blds directly (old code rebuilt per-player
	# buildings_of() arrays on every call, i.e. per peasant per AI tick).
	for b in live_blds:
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

# The build menu offers one generic "Mine" button. Resolve it to the concrete
# building (gold / iron / coal) that matches the ore deposit under the cursor,
# so the ghost and the finished mine always follow the deposit being built on.
# Left as-is for every other sid; harmless to call more than once.
func resolve_mine_sid(sid: String, pos: Vector2) -> String:
	if sid != "mine":
		return sid
	var best_type := ""
	var best_d := MINE_SITE_RADIUS
	for n in res_nodes:
		if n.max_hits != 0:
			continue
		var t := str(n.type)
		if t != "gold" and t != "iron" and t != "coal":
			continue
		var d: float = n.pos.distance_to(pos)
		if d < best_d:
			best_d = d
			best_type = t
	# No deposit in range: preview a gold mine; can_place will explain the
	# problem (the generic reason is shared by all three mine types).
	return "mine_" + best_type if best_type != "" else "mine_gold"

func _mine_debug(res: String) -> String:
	var out: Array = []
	for b in buildings_of(0, false) + buildings_of(1, false):
		out.append("%s/%s fin=%s dep=%s dead=%s" % [b.sid, b.player, b.finished, b.get("deposit_left", -1), b.dead])
	return "[" + ", ".join(out) + "]"

# Single team predicate shared by every target-selection path. A negative team
# id (the new_player default, -1) means free-for-all: never an alliance. Two
# players are allies only when both carry a real (>= 0) team id that matches.
func _is_ally(a: int, b: int) -> bool:
	if a < 0 or b < 0 or a >= players.size() or b >= players.size() or a == b:
		return false
	if not players[a].has("team") or not players[b].has("team"):
		return false
	var ta := int(players[a].team)
	var tb := int(players[b].team)
	if ta < 0 or tb < 0:
		return false
	return ta == tb

# DONOR capture-mode semantics (R02 claim 3): the skirmish option governs WHAT
# may change owner, not who may lean on a capture point. Modes:
#   default                 -> capturable units + buildings
#   no_peasants             -> no peasant *target*, buildings still fall
#   no_peasants_or_centres  -> same, plus the town hall itself is frozen
#   artillery_only          -> only artillery objects; buildings NEVER checked
# The port has no artillery-object owner flip, so `artillery_only` disables the
# building-capture path entirely (donor building.inc/nothing.inc:311-324).
func _building_capture_allowed(e: Dictionary) -> bool:
	match str(Data.CAPTURE_MODE):
		"artillery_only":
			return false
		"no_peasants_or_centres":
			return str(e.get("sid", "")) != "cen"
		_:
			return true

# DONOR bcancapture=False on peasants and artillery (unit.script:461-470,
# :1198, :1721+): only soldiers may capture buildings. The port keeps peasant
# swarming as its tested "video pass" loop (t_capture.gd:103-106), so peasants
# stay eligible; artillery is gated out of the building path here.
func _capture_unit_allowed(u: Dictionary) -> bool:
	if bool((u.get("def", {}) as Dictionary).get("artillery", false)):
		return false
	match str(Data.CAPTURE_MODE):
		"no_peasants", "no_peasants_or_centres":
			return str(u.get("sid", "")) != "peasant"
		"artillery_only":
			return false
		_:
			return true

func enemies_in_radius(pos: Vector2, player: int, r: float, military_only := true) -> Dictionary:
	var best: Dictionary = {}
	var best_d := r
	for e in grid_query(pos, r):
		if e.dead or e.player == player:
			continue
		if _is_ally(player, int(e.player)):
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
		if _is_ally(player, int(e.player)):
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

# P-44: AI failure paths would otherwise spam the human's chat every tick.
# Only player 0 (or a human slot) speaks these command-level warnings.
func _say_human(player: int, text: String) -> void:
	if player == 0 or (player >= 0 and player < players.size() and not bool(players[player].get("is_ai", false))):
		say(text)

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
	# T5GEN: a fresh order starts a fresh arrival/no-progress window.
	e["stuck_t"] = 0.0
	e["no_progress_t"] = 0.0
	e["last_d_goal"] = 0.0
	# officer leads: the squad marches in formation behind him
	_squad_order_members(e.id, pos, false)

func cmd_attack(e: Dictionary, target: Dictionary) -> void:
	if e.kind != "unit" or e.dead or target.dead:
		return
	# An explicit order against an ally is refused (team diplomacy, P-19).
	if _is_ally(int(e.player), int(target.get("player", -1))):
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
		var mine := nearest_mine(e.pos, res_node.type, int(e.player))
		if mine.is_empty():
			say("No %s mine - build one on a deposit." % res_node.type)
			return
		# T-MINE-BUILD: an ore deposit whose mine is still under construction is
		# a BUILD request, not a gather request. The old code overwrote the
		# builder's `build` order with a gather-wait loop in _tick_gather(),
		# permanently freezing the site (~80% of build_time in the repro).
		if not bool(mine.get("finished", true)):
			cmd_build(e, mine)
			return
		e.order = {"type": "gather", "res": res_node.type, "node": mine.id}
	elif res_node.type == "food" and not res_node.has("mill"):
		# T-FOOD-1: wild food is not harvestable. Mill fields carry a "mill"
		# tag (_sow_field_ring); everything else is refused gracefully.
		_say_human(int(e.player), "Build a mill first - food comes from mill fields.")
		return
	else:
		e.order = {"type": "gather", "res": res_node.type, "node": res_node.id}
	e.moving = true

func cmd_resow(e: Dictionary, node: Dictionary) -> void:
	if e.dead or str(e.sid) != "peasant" or node.is_empty() or str(node.type) != "food":
		return
	# T-FOOD-1: only mill-owned fields can be resown (wild food is refused
	# by cmd_gather too, so a live wild node must not detour through gather).
	if not node.has("mill"):
		_say_human(int(e.player), "Build a mill first - food comes from mill fields.")
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

# PORT-CONTROL hand-off / donor hotkeys.cfg G=guard/cancelguard. A second G
# drops a live guard order (and any pending guard-resume after an attack).
func cmd_cancel_guard(e: Dictionary) -> void:
	if e.kind != "unit" or e.dead:
		return
	var o: Dictionary = e.get("order", {})
	if str(o.get("type", "")) != "guard" and not o.has("resume_guard"):
		return
	cmd_stop(e)

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
		e.pos = b.pos + Vector2(cos(k * 2.4), sin(k * 2.4)) * (float(b.get("block_r", b.def.radius)) + 1.0)
		e.order = {"type": "none"}
		k += 1
	b["garrison"] = 0

# Squads: officer (slot 0) + drummer (slot 1) + soldiers, like squad.script.
# A squad is a sticky group: orders to the officer fan out to the members in
# the squad's formation (line / column / square from formations.cfg).
func squad_of_unit(uid: int) -> Dictionary:
	# T-SIM-HOTSPOTS: live units carry their squad id (set in squad_form and
	# cleared by squad_remove/squad_disband/_kill), so the common case is one
	# by_id lookup + one squads lookup instead of scanning every squad. Imported
	# or legacy states may lack the field, so the membership scan stays as a
	# fallback (also covers a stale id whose squad no longer exists).
	var u: Dictionary = by_id.get(uid, {})
	var sid := int(u.get("squad", 0)) if not u.is_empty() else 0
	if sid != 0 and squads.has(sid):
		return squads[sid]
	for s_sid in squads:
		var s: Dictionary = squads[s_sid]
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

# Donor formations.cfg per-id tuple [bonusdamage, bonusshield,
# bonusdamagehold, bonusshieldhold]; ids are <family><label>, e.g. LINE15.
# Imported verbatim in Data.FORMATION_BONUSES (149 records).
func _donor_formation_bonus(s: Dictionary) -> Array:
	var label := _squad_label(s)
	if label == 0:
		return [0, 0, 0, 0]
	var form := str(s.get("formation", "line"))
	var prefix := "LINE"
	if form == "square":
		prefix = "SQUARE"
	elif form == "column":
		prefix = "KARE"
	var b: Array = Data.formation_bonuses(prefix + str(label)).duplicate()
	# RB G-13: veteran bonus on TOP of the donor tuple; capped in Data.
	var vet: int = _squad_veteran_bonus(s)
	if vet > 0:
		for i in b.size():
			b[i] = int(b[i]) + vet
	return b

# RB G-13: bounded veteran points. Persists on the squad dict (formation
# changes and save/load keep it) and never exceeds Data.SQUAD_XP_CAP.
func _squad_veteran_bonus(s: Dictionary) -> int:
	if s.is_empty():
		return 0
	var per: float = maxf(1.0, float(Data.SQUAD_XP_PER_BONUS))
	var raw: int = int(floorf(float(s.get("xp", 0.0)) / per))
	return clampi(raw, 0, maxi(0, int(Data.SQUAD_XP_CAP)))

# RB G-13: a kill hardens the surviving killer squad. Also covers projectile
# hits: the projectile's `owner` is the original unit dict with its squad id.
func _award_squad_xp(e: Dictionary) -> void:
	if str(e.get("kind", "")) != "unit":
		return
	var s := squad_of_unit(int(e.id))
	if s.is_empty() or int(s.get("officer", 0)) == 0:
		return
	var cap_xp: float = float(maxi(0, int(Data.SQUAD_XP_CAP))) * maxf(1.0, float(Data.SQUAD_XP_PER_BONUS))
	s["xp"] = minf(float(s.get("xp", 0.0)) + maxf(0.0, float(Data.SQUAD_XP_PER_KILL)), cap_xp)

func _formation_atk(e: Dictionary, kind: String) -> int:
	var s := squad_of_unit(int(e.id))
	if _squad_label(s) == 0:
		return 0
	var melee := kind == "pike" or kind == "sword"
	var cav := _squad_cavalry(s)
	if not cav and int(s.get("drummer", 0)) == 0:
		return 0
	# Cavalry size labels (40/90/160) have no donor formations.cfg id, so the
	# earlier estimated cavalry values are kept (UNVERIFIED), not invented.
	if cav:
		if bool(e.get("hold", false)):
			return 5 if melee else 2
		return 1
	# Infantry uses the donor tuple: normal bonusdamage / hold bonusdamagehold.
	var b: Array = _donor_formation_bonus(s)
	return int(b[2]) if bool(e.get("hold", false)) else int(b[0])

func _formation_def(t: Dictionary) -> int:
	var s := squad_of_unit(int(t.id))
	if _squad_label(s) == 0:
		return 0
	var cav := _squad_cavalry(s)
	if not cav and int(s.get("drummer", 0)) == 0:
		return 0
	if cav:
		return 4 if bool(t.get("hold", false)) else 1
	# Donor bonusshield / bonusshieldhold (formations.cfg).
	var b: Array = _donor_formation_bonus(s)
	return int(b[3]) if bool(t.get("hold", false)) else int(b[1])

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
		_say_human(off.player, "No loose troops near the officer.")
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
		"formation": "line", "player": pl, "xp": 0.0}  # RB G-13 veteran XP
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
	if uid == "cen_18c" or uid == "art_multi1" or bool(u.get("no18c", false)):
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
		_say_human(player, "Not enough resources for %s." % u.name)
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
	# Skirmish combat tree (RB G-02..G-06, G-08). These are inert until the
	# matching upgrade is researched, so default gameplay is unchanged.
	var rm: Dictionary = p.get("rof_mult", {})
	for k in eff.get("rof_mult", {}):
		rm[k] = float(rm.get(k, 1.0)) * float(eff.rof_mult[k])
	p["rof_mult"] = rm
	if eff.has("cost_mult"):
		p["cost_mult"] = float(p.get("cost_mult", 1.0)) * float(eff.cost_mult)
	if eff.has("melee_mult"):
		p["melee_mult"] = float(p.get("melee_mult", 1.0)) * float(eff.melee_mult)
	if eff.has("melee_add"):
		p["melee_add"] = int(p.get("melee_add", 0)) + int(eff.melee_add)
	var cdm: Dictionary = p.get("cav_damage_mult", {})
	for k in eff.get("cav_damage_mult", {}):
		cdm[k] = float(cdm.get(k, 1.0)) * float(eff.cav_damage_mult[k])
	p["cav_damage_mult"] = cdm
	if eff.has("cav_dmg_add"):
		p["cav_dmg_add"] = int(p.get("cav_dmg_add", 0)) + int(eff.cav_dmg_add)
	if eff.has("cav_prot_bonus"):
		p["cav_prot_bonus"] = int(p.get("cav_prot_bonus", 0)) + int(eff.cav_prot_bonus)
	if eff.has("train_speed_mult"):
		p["train_speed_mult"] = float(p.get("train_speed_mult", 1.0)) * float(eff.train_speed_mult)
	if eff.has("art_cost_mult"):
		p["art_cost_mult"] = float(p.get("art_cost_mult", 1.0)) * float(eff.art_cost_mult)
	if eff.has("art_build_mult"):
		p["art_build_mult"] = float(p.get("art_build_mult", 1.0)) * float(eff.art_build_mult)
	if eff.has("heal_all"):
		for hu in entities:
			if not hu.dead and hu.player == player and hu.kind == "unit":
				hu.hp = int(hu.max_hp)
	if eff.has("repair_arty"):
		for ha in entities:
			if not ha.dead and ha.player == player and ha.def.get("artillery", false):
				ha.hp = int(ha.max_hp)
	post_event("upgraded", Vector2.ZERO, uid)
	_say_human(player, "%s researched %s." % [p.name, u.name])

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
		_say_human(player, "Build a market to trade.")
		return false
	var gi: int = Data.RES_NAMES.find(give)
	var wi: int = Data.RES_NAMES.find(want)
	if gi < 0 or wi < 0 or give == want:
		return false
	var p: Dictionary = players[player]
	if float(p.res[gi]) < amount:
		_say_human(player, "Not enough %s to trade." % give)
		return false
	var rate: float = float(p.get("market_rate", Data.MARKET_RATE))
	var got := amount * rate
	p.res[gi] = float(p.res[gi]) - amount
	p.res[wi] = float(p.res[wi]) + got
	p.market_rate = maxf(0.35, rate - Data.MARKET_DRIFT * amount / 100.0)
	stats.gathered["trade"] = int(stats.gathered.get("trade", 0)) + int(got)
	post_event("trade", Vector2.ZERO, give + ">" + want)
	return true

# PORT-CONTROL hand-off: trade() pushes the rate down to a 0.35 floor; this
# slowly recovers it toward Data.MARKET_RATE. Cadence is INFERRED (no donor
# number), exposed as Data.MARKET_RECOVERY_PER_S for tuning.
func tick_market(dt: float) -> void:
	var target: float = float(Data.MARKET_RATE)
	var step: float = maxf(0.0, float(Data.MARKET_RECOVERY_PER_S)) * maxf(0.0, dt)
	if step <= 0.0:
		return
	for p in players:
		var cur: float = float(p.get("market_rate", target))
		if cur < target:
			p.market_rate = minf(target, maxf(0.35, cur + step))

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

func effective_damage(player: int, kind: String, pos: Vector2, e: Dictionary = {}) -> float:
	var p: Dictionary = players[player]
	var m: float = float(p.damage_mult.get(kind, 1.0))
	if str(kind) in ["sword", "pike"]:
		m *= float(p.get("melee_mult", 1.0))
		if not str(e.get("cavalry", "")).is_empty():
			m *= float(p.get("cav_damage_mult", {}).get(kind, 1.0))
	if officer_near(pos, player):
		m *= 1.0 + Data.OFFICER_DAMAGE_BONUS
	return m

func can_place(player: int, sid: String, pos: Vector2) -> Dictionary:
	# Single source of truth for build legality. Returns {ok, reason}.
	# "mine" is a UI-side pseudo sid backed by the shared mine stats.
	var def: Dictionary = Data.BUILDINGS.get("mine_gold" if sid == "mine" else sid, {})
	if not in_bounds(pos):
		return {"ok": false, "reason": "Outside the map."}
	if sid == "mine" or sid.begins_with("mine_"):
		# The generic "mine" accepts any ore deposit; concrete mines still
		# require their own type (kept for the AI / older callers).
		var want: String = "" if sid == "mine" else str(def.mine)
		var dep := false
		# T-PERF-SIM: ore deposits only (spatial query; same MINE_SITE_RADIUS).
		_res_grid_ensure()
		var mc0 := Vector2i(int((pos.x - MINE_SITE_RADIUS) / RES_GRID_M), int((pos.y - MINE_SITE_RADIUS) / RES_GRID_M))
		var mc1 := Vector2i(int((pos.x + MINE_SITE_RADIUS) / RES_GRID_M), int((pos.y + MINE_SITE_RADIUS) / RES_GRID_M))
		for mcy in range(mc0.y, mc1.y + 1):
			for mcx in range(mc0.x, mc1.x + 1):
				for n in (_res_grid.get(Vector2i(mcx, mcy), []) as Array):
					if n.max_hits != 0 or n.pos.distance_to(pos) >= MINE_SITE_RADIUS:
						continue
					if want == "" or n.type == want:
						dep = true
						break
				if dep:
					break
			if dep:
				break
		if not dep:
			return {"ok": false, "reason": "Mines must be built on an ore deposit."}
		return {"ok": true, "reason": ""}
	var t := tile_of(pos)
	var terr: int = terrain[_t(t.x, t.y)]
	if terr == 3:
		return {"ok": false, "reason": "Too wet - cannot build on water."}
	# T-PERF-SIM: my_r hoisted (old code re-queried bld_rm per node/building);
	# resource footprint via the spatial hash, buildings via the entity grid.
	var _mr: float = bld_rm(player, sid)
	var my_r0: float = _mr if _mr > 0.0 else float(def.radius)
	_res_grid_ensure()
	var fr := my_r0 + 2.5
	var fc0 := Vector2i(int((pos.x - fr) / RES_GRID_M), int((pos.y - fr) / RES_GRID_M))
	var fc1 := Vector2i(int((pos.x + fr) / RES_GRID_M), int((pos.y + fr) / RES_GRID_M))
	# footprint vs resources (stone fields, trees, groves; deco/stumps excluded)
	for fcy in range(fc0.y, fc1.y + 1):
		for fcx in range(fc0.x, fc1.x + 1):
			for n in (_res_grid.get(Vector2i(fcx, fcy), []) as Array):
				if str(n.get("type", "")) in ["bush", "stump"]:
					continue
				if int(n.get("hits", 0)) <= 0 and int(n.get("max_hits", 0)) != 0:
					continue
				var rr: float = my_r0 + float(n.get("radius", 0.5))
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
	for b in grid_query(pos, my_r0 + _CANPLACE_BLD_MARGIN):
		if b.dead or b.kind != "building":
			continue
		var rr2: float = my_r0 + float(b.get("block_r", b.def.radius)) + 0.3
		if b.pos.distance_to(pos) < rr2:
			if (sid == "wal" or sid == "gat") and str(b.sid) in ["wal", "gat"] and b.player == player:
				continue
			return {"ok": false, "reason": "Too close to %s." % str(b.sid)}
	if is_blocked(pos) and not (sid in ["wal", "gat"]):
		return {"ok": false, "reason": "Blocked ground (rock/forest/water)."}
	return {"ok": true, "reason": ""}

# W3-1: single source of truth for the cost place_building actually charges.
# Mirrors the old inline escalation exactly: resolve the generic "mine" first,
# skip walls/gates/mines, then pow(3,cnt) for a town hall or pow(1.5,cnt) for
# every other sid. `cnt` counts FINISHED buildings only, matching the default
# of buildings_of(player) (only_finished = true).
func build_cost(player: int, sid: String, pos: Vector2) -> Dictionary:
	var rsid := resolve_mine_sid(sid, pos)
	var def: Dictionary = Data.BUILDINGS.get(rsid, {})
	if def.is_empty():
		return {}
	var mult := 1.0
	if not rsid.begins_with("mine_") and rsid != "wal" and rsid != "gat":
		var cnt := 0
		for b in buildings_of(player):
			if b.sid == rsid:
				cnt += 1
		mult = pow(3.0, cnt) if rsid == "cen" else pow(1.5, cnt)
	var cost := {}
	for k in def.cost:
		cost[k] = int(round(float(def.cost[k]) * mult))
	return cost

# W3-1: upfront affordability gate used by the sim and exposed for W3-2's HUD.
# True only when the player can pay the ESCALATED cost at this spot.
func can_afford(player: int, sid: String, pos: Vector2) -> bool:
	if player < 0 or player >= players.size():
		return false
	var rsid := resolve_mine_sid(sid, pos)
	if not Data.BUILDINGS.has(rsid):
		return false
	return Data.can_pay(players[player].res, build_cost(player, sid, pos))

func place_building(player: int, sid: String, pos: Vector2, send := true, builders: Array = []) -> Dictionary:
	# A single "Mine" request becomes the mine that matches this deposit.
	sid = resolve_mine_sid(sid, pos)
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
			if n.type == def.mine and n.max_hits == 0 and n.pos.distance_to(pos) < MINE_SITE_RADIUS:
				pos = n.pos
				break
	# W3-1 / X1 C5: a human site with no builder is an orphan that can never
	# finish. Refuse it up front; do NOT auto-assign idle peasants. AI calls
	# pass send=false and issue their own build orders, so they are untouched.
	if send:
		var n_builders := 0
		for u in builders:
			if not (u is Dictionary) or bool(u.get("dead", false)):
				continue
			if int(u.get("player", -1)) != player or str(u.get("sid", "")) != "peasant":
				continue
			n_builders += 1
		if n_builders == 0:
			_say_human(player, "Select at least one peasant to build.")
			return {}
	# W3-1 / WAVE3_DECISIONS 4: gate on the same escalated cost the sim charges,
	# before the site exists and before pay_cost touches the player's resources.
	var esc_cost: Dictionary = build_cost(player, sid, pos)
	if not can_afford(player, sid, pos):
		_say_human(player, "Not enough resources.")
		return {}
	if not pay_cost(player, esc_cost):
		_say_human(player, "Not enough resources.")
		return {}
	var b := spawn(sid, player, pos, false)
	# W3-1: remember exactly what was paid so cancel/refund is faithful even if
	# escalation would differ by the time the site is removed.
	b["paid_cost"] = esc_cost.duplicate()
	b.hp = maxi(1, int(def.hp * 0.25))
	post_event("construct", pos, sid)
	if not send:
		return b
	# Only the SELECTED peasants are sent to the site.  The old code swept up
	# every idle AND gathering peasant on the map, which emptied the economy.
	# AI calls pass send=false and issues its own build orders.
	var sent := 0
	for u in builders:
		if sent >= Data.MAX_BUILDERS_SENT:
			break
		if not (u is Dictionary) or bool(u.get("dead", false)):
			continue
		if int(u.get("player", -1)) != player or str(u.get("sid", "")) != "peasant":
			continue
		cmd_build(u, b)
		sent += 1
	return b

# P-10: a ship appears in water next to its dock, never on the dock's land tile.
# Deterministic ring scan, no rng draw (default seeds stay byte-identical).
func _naval_spawn_pos(b: Dictionary) -> Vector2:
	for ring in range(1, 9):
		for k in 16:
			var a := TAU * float(k) / 16.0
			var p: Vector2 = b.pos + Vector2(cos(a), sin(a)) * (float(ring) * TILE)
			if _is_water(p):
				return p
	return Vector2(-1.0, -1.0)

func train_unit(player: int, building: Dictionary, sid: String, amount: int = 1, infinite: bool = false) -> bool:
	if not building.finished:
		return false
	var nat := str(players[player].get("nation", "")) if player >= 0 and player < players.size() else ""
	if nat == "" and player >= 0 and player < Data.PLAYER_NATIONS.size():
		nat = str(Data.PLAYER_NATIONS[player])
	var rsid := Data.resolve_sid(nat, sid)
	# G-07: a captured foreign town hall adds that nation's roster. Prefer the
	# most recently captured nation that actually maps this generic sid.
	var captured: Array = players[player].get("captured_nations", [])
	for i in range(captured.size() - 1, -1, -1):
		var alt := Data.resolve_sid(str(captured[i]), sid)
		if alt != sid and Data.UNITS.has(alt):
			rsid = alt
			break
	if not building.def.get("trains", []).has(sid) and not building.def.get("trains", []).has(rsid):
		return false
	# T-MENU-ROSTER donor rules: "No Cannons Towers Walls" removes artillery
	# training, and Pop limit refuses new units once the cap is reached.
	if str(Data.CANNON_MODE) == "no_cannons_towers_walls" \
			and bool((Data.UNITS.get(rsid, {}) as Dictionary).get("artillery", false)):
		return false
	if Data.POP_LIMIT > 0 and unit_count(player) >= Data.POP_LIMIT:
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
	# T5MOD: donor carries the batch amount INSIDE one order (D19).  Plain=1,
	# Shift=5, Ctrl+Alt=100, Ctrl=endless, Ctrl+Shift=5x endless.
	var free_slots: int = Data.BUILD_QUEUE_LIMIT - building.queue.size()
	if free_slots <= 0:
		return false
	var price: Dictionary = Data.UNITS[rsid].price
	var jobs: int = maxi(1, amount)
	if not infinite:
		var cap_free: int = int(players[player].farm_cap) - unit_count(player) - queue_count(player)
		if cap_free <= 0:
			_say_human(player, "Need more houses â€” unit limit reached.")
			return false
		jobs = mini(jobs, mini(free_slots, cap_free))
		# Charge only the affordable subset; unaffordable units are skipped.
		var probe: Dictionary = {}
		var affordable := 0
		for k in price.keys():
			probe[k] = 0.0
		for _n in jobs:
			for k in price.keys():
				probe[k] = float(probe[k]) + float(price[k])
			if not Data.can_pay(players[player].res, probe):
				break
			affordable += 1
		if affordable <= 0:
			_say_human(player, "Not enough resources for %s." % rsid)
			return false
		var paid: Dictionary = {}
		for k in price.keys():
			paid[k] = float(price[k]) * float(affordable)
		Data.pay(players[player].res, paid)
		building.queue.append({"sid": rsid, "t": Data.UNITS[rsid].build_time,
			"count": affordable, "infinite": false})
		return true
	# Endless: one paid-ahead unit per infinite job.  Each later cycle is
	# charged on completion; the job is dropped when resources/requirements fail.
	jobs = mini(jobs, free_slots)
	if jobs <= 0 or not pay_cost(player, price):
		return false
	for _j in jobs:
		building.queue.append({"sid": rsid, "t": Data.UNITS[rsid].build_time,
			"count": 1, "infinite": true})
	return true

# T5MOD: RMB on a training icon cancels one queued job of sid and refunds it.
func cancel_train(building: Dictionary, sid: String) -> bool:
	if building.is_empty() or building.queue.is_empty():
		return false
	for i in range(building.queue.size() - 1, -1, -1):
		var job: Dictionary = building.queue[i]
		if str(job.get("sid", "")) != sid:
			continue
		var n: int = 1 if bool(job.get("infinite", false)) else maxi(1, int(job.get("count", 1)))
		var cost: Dictionary = Data.UNITS.get(sid, {}).get("price", {})
		var refund: Dictionary = {}
		for k in cost.keys():
			refund[k] = float(cost[k]) * float(n)
		Data.refund(players[int(building.player)].res, refund, 1.0)
		building.queue.remove_at(i)
		return true
	return false

func queue_count(player: int) -> int:
	var n := 0
	for b in buildings_of(player):
		for j in b.queue:
			n += 1 if bool((j as Dictionary).get("infinite", false)) else maxi(1, int((j as Dictionary).get("count", 1)))
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
	_nav_tick_budget = NAV_PER_TICK
	ai_cheat_t += dt
	if ai_cheat_t >= 1.0 and Data.AI_DIFFICULTY == "hard":
		ai_cheat_t = 0.0
		for p in players:
			if not bool(p.get("is_ai", false)):
				continue
			p.res[0] += 1.5
			p.res[1] += 1.5
			p.res[2] += 1.5
			p.res[3] += 0.8
			p.res[4] += 0.8
			p.res[5] += 0.8
	_grid_rebuild()
	_tick_fields(dt)
	sow_t += dt
	if sow_t >= 60.0:
		sow_t = 0.0
		_tick_field_growth()
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
	tick_market(dt)  # PORT-CONTROL hand-off: recover post-trade market rate
	_check_victory()

# T-SIM-HOTSPOTS: int hash keys replace Vector2i keys (no 19 allocations per
# unit per tick). The 9-cell scan order is kept EXACTLY as before: this is a
# sequential relaxation, so cell visitation order changes the result even when
# the pair set is the same. cx/cy stay per-pass locals for the same reason.
const _SEP_KEY_STRIDE := 65536

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
		var key := cx + cy * _SEP_KEY_STRIDE
		if not lgrid.has(key):
			lgrid[key] = []
		(lgrid[key] as Array).append(e)
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
					var key := (cx + ox) + (cy + oy) * _SEP_KEY_STRIDE
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
								# T-PERF-SIM: marks units displaced by the pair
								# pass so the building pass below still sees
								# them (see do_bld_push).
								e["sep_moved"] = true
							if in_bounds(np_o) and not is_blocked(np_o):
								o.pos = np_o
								o["sep_moved"] = true
		# buildings push units out (cheap: only nearby buildings per unit)
		# T-PERF-SIM: skip units that cannot need it: settled, undisplaced,
		# with an unchanged building set. The pass is a pure function of
		# (unit pos, building set); anything it would move either moved this
		# tick (movers / pair-pass displacement) or saw new buildings.
		var do_bld_push := bld_dirty != _sep_bld_ver
		for e in units:
			if e.dead:
				continue
			var displaced: bool = bool(e.get("sep_moved", false))
			e["sep_moved"] = false
			if not do_bld_push and not bool(e.get("moving", false)) and not displaced:
				continue
			for b in grid_query(e.pos, 9.0):
				if b.dead or b.kind != "building":
					continue
				var rr: float = e.def.radius + float(b.get("block_r", b.def.radius)) + 0.15
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
		_sep_bld_ver = bld_dirty

# T-PERF-SIM: bld_dirty value at the last building-push pass (see above).
var _sep_bld_ver := -1

# T-PERF-SIM: upkeep slot order (food/gold/stone) into Data.RES_NAMES indices.
const _UPKEEP_RES_IDX := [0, 3, 2]
# DONOR T6-M01 (unit.script:8185-8201): bturnoff units stop firing while the
# owner has <4 gold, with a 100-frame attack delay. Port has no bturnoff flag;
# the deterministic analogue is gold-upkeep units (def.eat.gold), which
# includes the naval yacht (data.gd:1043). Threshold is the donor literal 4;
# a config key (economy.gold_fire_stop_res / _seconds) is needed to make it
# tunable - data.gd/config.gd are owned by another worker.
const _GOLD_FIRE_STOP_RES := 4.0
const _GOLD_FIRE_STOP_S := 100.0 / 32.0
func _tick_upkeep(dt: float) -> void:
	# Upkeep, ported from player.script _player_ProcessResourceConsume
	# (speed 20000, gc_time_to_frames = 32): each unit eats consume/625 units
	# of food (or gold) per second. Video pass: prolonged famine first shows
	# the warning, then the original starves the army - slow HP drain after a
	# grace period so a test never dies instantly (estimated).
	# T-PERF-SIM: one shared pass accumulates every player's upkeep (index
	# 0/1/2 = food/gold/stone); the old code re-scanned live_units/live_blds
	# once per player. Drain loops use live_units, not the full entity list.
	var totals: Array = []
	for _pi in players.size():
		totals.append([0.0, 0.0, 0.0])
	for e in live_units:
		if e.dead:
			continue
		var epl: int = int(e.player)
		if epl < 0 or epl >= totals.size():
			continue
		var ee: Dictionary = e.def.get("eat", {})
		if ee.is_empty():
			continue
		var te: Array = totals[epl]
		# player.script speed 20000
		te[0] += float(ee.get("food", 0.0)) / Data.UPKEEP_DIVISOR
		te[1] += float(ee.get("gold", 0.0)) / Data.UPKEEP_DIVISOR
		te[2] += float(ee.get("stone", 0.0)) / Data.UPKEEP_DIVISOR
	for b in live_blds:
		if b.dead:
			continue
		var bpl: int = int(b.player)
		if bpl < 0 or bpl >= totals.size():
			continue
		var be: Dictionary = b.def.get("eat", {})
		if be.is_empty():
			continue
		var tb: Array = totals[bpl]
		tb[0] += float(be.get("food", 0.0)) / Data.UPKEEP_DIVISOR
		tb[1] += float(be.get("gold", 0.0)) / Data.UPKEEP_DIVISOR
		tb[2] += float(be.get("stone", 0.0)) / Data.UPKEEP_DIVISOR
	for pi in players.size():
		var p: Dictionary = players[pi]
		p["famine_msg_t"] = maxf(0.0, float(p.get("famine_msg_t", 0.0)) - dt)
		var eat: Array = totals[pi]
		for k in 3:
			if eat[k] > 0:
				var idx: int = _UPKEEP_RES_IDX[k]
				var have: float = p.res[idx]
				var need: float = float(eat[k]) * dt
				if have >= need:
					p.res[idx] = have - need
					if k == 0:
						p["famine"] = false
						p["famine_t"] = 0.0
					if k == 1:
						p["gold_famine_t"] = 0.0
				else:
					p.res[idx] = 0.0
					if k == 0:
						p["famine"] = true
						p["famine_t"] = float(p.get("famine_t", 0.0)) + dt
						if float(p["famine_t"]) >= Data.FAMINE_GRACE_S:
							if float(p.get("famine_msg_t", 0.0)) <= 0.0:
								p["famine_msg_t"] = 10.0
								say("Famine! %s is starving." % p.name)
							for eu in live_units:
								if not eu.dead and eu.player == pi:
									eu.hp -= Data.FAMINE_DRAIN_PER_S * dt
					if k == 1:
						p["gold_famine_t"] = float(p.get("gold_famine_t", 0.0)) + dt
						if float(p["gold_famine_t"]) >= 60.0:
							for eu2 in live_units:
								if not eu2.dead and eu2.player == pi and (eu2.def.get("eat", {}) as Dictionary).has("gold"):
									eu2["morale"] = maxf(0.0, float(eu2.get("morale", 70.0)) - 10.0 * dt)

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
		_unblock_building(e)
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
	_unblock_building(w)
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

# W3-1 / X1 C11: cancelling an unfinished site refunds what was actually paid.
# Full refund (1.0) while no builder has worked the site; once work started the
# refund is PARTIAL (SITE_REFUND_WORKED = 0.5) to represent consumed material.
# Finished buildings are never refunded (donor demolition gives no refund).
const SITE_REFUND_UNWORKED := 1.0
const SITE_REFUND_WORKED := 0.5

func cancel_build_site(e: Dictionary) -> bool:
	if e.dead or e.kind != "building" or bool(e.get("finished", false)):
		return false
	var pi: int = int(e.get("player", -1))
	if pi < 0 or pi >= players.size():
		return false
	var paid: Dictionary = e.get("paid_cost", {})
	if paid.is_empty():
		paid = build_cost(pi, str(e.sid), e.pos)
	if paid.is_empty():
		return false
	var pct: float = SITE_REFUND_UNWORKED if float(e.get("progress", 0.0)) <= 0.0 else SITE_REFUND_WORKED
	Data.refund(players[pi].res, paid, pct)
	return true

# Delete: remove your own selected units/buildings (wiki: delete what you
# cannot hold so the enemy cannot capture it). No score penalty, farm freed.
func cmd_delete(e: Dictionary) -> void:
	if e.dead or e.player != 0:
		return
	cancel_build_site(e)
	var sc: int = players[e.player].score
	_kill(e, null, false)
	players[e.player].score = sc
	say("Deleted %s." % e.sid)

# ------------------------------------------------------------- path following
# Fixed-destination orders use A*; dynamic chases (attack/guard/rout) keep the
# old local steering so a moving target never forces a repath every tick.
func _nav_wanted(e: Dictionary) -> bool:
	if bool(e.get("routing", false)):
		return false
	var t: String = str(e.order.get("type", ""))
	return t in ["move", "attackmove", "patrol", "gather", "resow", "repair", "build", "attackground"]

# Gates and building ink boxes are not part of the static blocked[] grid, so
# pass their footprints to A* as extra blocked cells.
func _nav_gate_cells(e: Dictionary) -> Array:
	# T-PERF-SIM: building ink cells are cached per nav_version (they only
	# change when the blocked grid does); only the small per-unit gate ring
	# part is rebuilt per repath. Returned array is a fresh copy per call.
	if _nav_ink_ver != nav_version:
		_nav_ink_cells.clear()
		for b in live_blds:
			if not b.dead:
				_nav_ink_cells.append_array(bld_rect_cells(b.get("block_rect", Rect2())))
		_nav_ink_ver = nav_version
	var out: Array = _nav_ink_cells.duplicate()
	for g in gates:
		if g.dead:
			continue
		if bool(g.get("closed", false)) or int(g.player) != int(e.player):
			var r: float = float(g.def.radius) + 0.4
			var t0 := tile_of(g.pos - Vector2(r, r))
			var t1 := tile_of(g.pos + Vector2(r, r))
			for y in range(maxi(0, t0.y), mini(MAP_H, t1.y + 1)):
				for x in range(maxi(0, t0.x), mini(MAP_W, t1.x + 1)):
					var c := Vector2((x + 0.5) * TILE, (y + 0.5) * TILE)
					if c.distance_to(g.pos) <= r:
						out.append(Vector2i(x, y))
	return out

# T-PERF-SIM: cached building ink cells for A* (see _nav_gate_cells).
var _nav_ink_cells: Array = []
var _nav_ink_ver := -1

func _nav_line_clear(e: Dictionary, a: Vector2, b: Vector2) -> bool:
	var d: float = a.distance_to(b)
	var steps: int = clampi(ceilf(d / (TILE * 0.5)), 2, 256)
	var prev: Vector2 = a
	for i in range(1, steps):
		var p: Vector2 = a.lerp(b, float(i) / float(steps))
		if _blocked_for(e, p):
			return false
		if not _is_naval(e) and slope_to(prev, p) > 0.55:
			return false
		prev = p
	return true

# String-pulling: replace the tile-by-tile staircase with long straight legs
# whenever the direct segment is walkable.  Keeps movement looking natural.
func _nav_smooth(e: Dictionary, pts: Array) -> Array:
	if pts.size() < 3:
		return pts
	var out: Array = [pts[0]]
	var i := 0
	while i < pts.size() - 1:
		var j: int = mini(pts.size() - 1, i + 8)
		while j > i + 1 and not _nav_line_clear(e, pts[i] as Vector2, pts[j] as Vector2):
			j -= 1
		out.append(pts[j])
		i = j
	return out

func _nav_repath(e: Dictionary, target: Vector2) -> void:
	# P-10: nav.gd A* uses the land `blocked` grid, where water is BLK_WATER.
	# A ship therefore follows clear water lines only (the 13-probe steering in
	# _step_move handles the final approach); no nav.gd changes are needed.
	if _is_naval(e):
		var ok: bool = _nav_line_clear(e, e.pos, target) and not _blocked_for(e, target)
		e["nav_path"] = [target] if ok else []
		e["nav_i"] = 0
		e["nav_goal"] = target
		e["nav_ver"] = nav_version
		e["nav_cd"] = 0.6
		return
	# Most orders need no detour at all - skip A* when the straight line is
	# already walkable.  This keeps ordinary moves as cheap as before.
	if _nav_line_clear(e, e.pos, target) and not _blocked_for(e, target):
		e["nav_path"] = [target]
		e["nav_i"] = 0
		e["nav_goal"] = target
		e["nav_ver"] = nav_version
		e["nav_cd"] = 0.6
		return
	nav.configure(MAP_W, MAP_H, TILE)
	if nav.version != nav_version:
		nav.version = nav_version
	var cells: Array = nav.find_path(e.pos, target, blocked, _nav_gate_cells(e))
	var pts: Array = []
	for c in cells:
		pts.append(nav.cell_center(c as Vector2i))
	if not pts.is_empty() and not _blocked_for(e, target) \
		and _nav_line_clear(e, pts[pts.size() - 1] as Vector2, target):
		pts.append(target)
	e["nav_path"] = _nav_smooth(e, pts)
	e["nav_i"] = 0
	e["nav_goal"] = target
	e["nav_ver"] = nav_version
	e["nav_cd"] = 0.6

func _step_move(e: Dictionary, target: Vector2, speed: float, dt: float, arrive := 0.15, giveup := false) -> bool:
	# T5GEN F2/F4: a blocked destination is never appended to the A* path, so
	# d_goal must measure a reachable point, not the raw blocked one.  Snap once
	# for both path and arrival; crowded orders also get a realistic arrival
	# band plus a no-progress give-up so nobody marches in place forever.
	var dest: Vector2 = target
	if giveup and not _is_naval(e) and _blocked_for(e, target):
		dest = _snap_free_point(target, e)
	var arrive_eff: float = arrive
	if giveup:
		arrive_eff = maxf(arrive, 0.9)
		var last_d := float(e.get("last_d_goal", 0.0))
		var npt := float(e.get("no_progress_t", 0.0))
		if last_d <= 0.0 or dest.distance_to(e.pos) < last_d - 0.08:
			npt = 0.0
		else:
			npt += dt
		e["last_d_goal"] = dest.distance_to(e.pos)
		e["no_progress_t"] = npt
		if npt > 2.0 and dest.distance_to(e.pos) <= 2.0:
			e.moving = false
			e["stuck_t"] = 0.0
			e["no_progress_t"] = 0.0
			e["nav_path"] = []
			e["nav_i"] = 0
			return true
	# Walk one step towards the target.  Fixed-destination orders first follow
	# an A* route around buildings/water/cliffs; the rotated-probe steering
	# below handles the final approach and all dynamic chases.
	var use_nav: bool = _nav_wanted(e)
	var path: Array = []
	var aim: Vector2 = dest
	if use_nav:
		var cd: float = maxf(0.0, float(e.get("nav_cd", 0.0)) - dt)
		e["nav_cd"] = cd
		path = e.get("nav_path", [])
		var goal: Variant = e.get("nav_goal", null)
		var need := false
		if int(e.get("nav_ver", -1)) != nav_version:
			need = true
		elif not (goal is Vector2) or (goal as Vector2).distance_to(dest) > 1.0:
			need = true
		elif path.is_empty() or int(e.get("nav_i", 0)) >= path.size():
			need = e.pos.distance_to(dest) > arrive_eff + 1.5
		if need and cd <= 0.0 and _nav_tick_budget > 0:
			_nav_tick_budget -= 1
			_nav_repath(e, dest)
			path = e.get("nav_path", [])
		var i: int = int(e.get("nav_i", 0))
		var near: float = maxf(0.45, TILE * 0.3)
		while i < path.size() and e.pos.distance_to(path[i] as Vector2) < near:
			i += 1
		e["nav_i"] = i
		if i < path.size():
			aim = path[i] as Vector2

	var d_goal: float = e.pos.distance_to(dest)
	if d_goal <= arrive_eff:
		e.moving = false
		e["stuck_t"] = 0.0
		e["no_progress_t"] = 0.0
		e["nav_path"] = []
		e["nav_i"] = 0
		return true
	var to: Vector2 = aim - e.pos
	var d: float = to.length()
	if d < 0.001:
		aim = dest
		to = aim - e.pos
		d = to.length()
	var step: float = minf(speed * dt, d)
	var dir: Vector2 = to / maxf(d, 0.001)
	for i in 13:
		var ang := 0.0
		if i > 0:
			var step_i: int = (i + 1) / 2 + 1
			ang = (PI / 12.0) * float(step_i) * (1.0 if i % 2 == 0 else -1.0)
		var d2: Vector2 = dir.rotated(ang)
		var np: Vector2 = e.pos + d2 * step
		if not _blocked_for(e, np) and not _blocked_for(e, np + d2 * 0.45):
			var sl := slope_to(e.pos, np)
			if not _is_naval(e) and sl > 0.55:
				continue
			var esp := speed
			if not _is_naval(e) and height_at(np) > height_at(e.pos) + 0.05 and sl > 0.25:
				esp *= 0.6
				if esp * dt < step:
					np = e.pos + d2 * esp * dt
			e.pos = np
			e.face = d2.angle()
			e["stuck_t"] = 0.0
			if giveup and d_goal - step < arrive_eff:
				e.moving = false
				e["no_progress_t"] = 0.0
				e["nav_path"] = []
				e["nav_i"] = 0
				return true
			return d_goal - step < arrive_eff
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

# BUILDER-STANDS: construction-only stand slot around the WHOLE unfinished
# footprint.  Keeps _work_slot's golden-angle hash (deterministic per unit id,
# no RNG draw, so default-seed bytes are untouched) but tests candidates with
# the pathfinder's own obstacle query, so a peasant is never ordered into the
# drawn ink box / under the scaffold.  The probe deliberately carries no build
# order: _blocked_for then treats the site's own block_rect and stamped circle
# as obstacles instead of skipping them.  A bounded 16-direction scan (same
# lattice as _snap_free_point, starting at this builder's hash angle) spreads
# the crew to free sides; the last resort is to stay put, never the site centre,
# which is what used to trap builders inside on completion.
func _build_stand_slot(e: Dictionary, site: Dictionary) -> Vector2:
	var center: Vector2 = site.pos
	var ring_r := float(site.get("block_r", site.def.radius)) + 0.7
	var ang := float(e.id) * 2.399963 + center.x * 0.13 + center.y * 0.07
	var rr := ring_r + float(e.id % 3) * 0.35
	var probe: Dictionary = {"def": {}, "order": {}}
	var p := center + Vector2(cos(ang), sin(ang)) * rr
	if in_bounds(p) and not _blocked_for(probe, p):
		return p
	var p2 := center - Vector2(cos(ang), sin(ang)) * rr
	if in_bounds(p2) and not _blocked_for(probe, p2):
		return p2
	for ring in 4:
		var rad := rr + float(ring)
		for k in 16:
			var a := ang + TAU * float(k) / 16.0
			var q := center + Vector2(cos(a), sin(a)) * rad
			if in_bounds(q) and not _blocked_for(probe, q):
				return q
	return e.pos

# T5GEN F4: nearest walkable point around p for a probe entity.  Ring scan is
# deterministic (fixed 16 directions, 1 m steps) and never uses unseeded RNG.
func _snap_free_point(p: Vector2, probe: Dictionary) -> Vector2:
	if in_bounds(p) and not _blocked_for(probe, p):
		return p
	for ring in range(1, 9):
		var rr := float(ring) * (TILE * 0.5)
		for k in 16:
			var a := TAU * float(k) / 16.0
			var q := p + Vector2(cos(a), sin(a)) * rr
			if in_bounds(q) and not _blocked_for(probe, q):
				return q
	return p

# T5GEN F1: deterministic, blocked-tile-aware spawn slot around a building's
# exit edge.  idx rotates the lattice so consecutive units do not share a tile;
# radial bands start beyond block_r so nobody is born inside the door band.
func _spawn_slot(e: Dictionary, dir: Vector2, brexit: float, idx: int, naval: bool) -> Vector2:
	var probe: Dictionary = {"def": {}, "order": {}}
	if naval:
		probe["def"] = {"naval": true}
	var tang := Vector2(-dir.y, dir.x)
	var radials := [1.8, 3.0, 4.2, 5.4]
	var laterals := [0.0, 1.2, -1.2, 2.4, -2.4, 3.6, -3.6, 4.8, -4.8]
	var start := idx % laterals.size()
	for r in radials:
		for k in laterals.size():
			var l: float = float(laterals[(start + k) % laterals.size()])
			var cand: Vector2 = e.pos + dir * (brexit + float(r)) + tang * l
			if in_bounds(cand) and not _blocked_for(probe, cand):
				return cand
	return e.pos + dir * (brexit + 3.0)

# T5GEN F1: stagger rally targets into a small formation (rows across the exit
# direction, columns along it) with the player's chosen point as the centre.
func _rally_slot(center: Vector2, dir: Vector2, idx: int) -> Vector2:
	var tang := Vector2(-dir.y, dir.x)
	var row := idx % 5
	var col := idx / 5
	return center + tang * (float(row) - 2.0) * 1.2 + dir * float(col) * 1.2

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
			# T5GEN F3: consume the no-progress timer instead of re-asserting
			# moving=true forever.  _step_move(giveup=true) owns the arrival flag.
			if float(e.get("stuck_t", 0.0)) > 2.0:
				e["stuck_t"] = 0.0
				e["no_progress_t"] = 0.0
				e.moving = false
				e["nav_path"] = []
				e["nav_i"] = 0
				e.order = {"type": "none"}
			else:
				e.moving = true
				_step_move(e, o.pos, effective_speed(e), dt, 0.15, true)
				var sqm: Dictionary = squad_of_unit(e.id)
				if not sqm.is_empty() and int(sqm.get("officer", 0)) == e.id:
					sqm["face"] = (o.pos - e.pos).angle()
				if not e.moving:
					e.order = {"type": "none"}
		"attackmove":
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
			if float(e.get("stuck_t", 0.0)) > 2.0:
				e["stuck_t"] = 0.0
				e["no_progress_t"] = 0.0
				e.moving = false
				e["nav_path"] = []
				e["nav_i"] = 0
				e.order = {"type": "none"}
			else:
				e.moving = true
				_step_move(e, o.pos, effective_speed(e), dt, 0.15, true)
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
			var tr: float = float(t.get("block_r", t.def.radius))
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
					_restore_field(fn)
					e.order = {"type": "gather", "node": fn.id, "res": "food"}
		"repair":
			var rb: Dictionary = by_id.get(o.get("target", 0), {})
			if rb.is_empty() or rb.dead or rb.hp >= rb.max_hp:
				e.order = {"type": "none"}
				return
			var rslot := _work_slot(e, rb.pos, float(rb.get("block_r", rb.def.radius)) + 0.7)
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
			# Each builder takes its own slot around the WHOLE footprint; the
			# stand is tested against the drawn block box so nobody is ordered
			# inside the unfinished walls or under the scaffold.
			var slot_b := _build_stand_slot(e, site)
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
					# T2GEN: denser donor-style forest makes build-site paths
					# longer; keep the donor build-time constant but advance
					# work slightly faster so a single peasant still finishes
					# inside the scripted 25 s build window.
					site.progress += (Data.BUILD_PROGRESS_PER_HIT * 1.5) / float(players[site.player].get("build_mult", 1.0))
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
	# Flintlock / foundry upgrades scale the listed shot cost.
	var cscale: float = float(players[e.player].get("cost_mult", 1.0))
	if e.def.get("artillery", false):
		cscale *= float(players[e.player].get("art_cost_mult", 1.0))
	if cscale != 1.0 and not cost.is_empty():
		cost = cost.duplicate()
		for k in cost:
			cost[k] = float(cost[k]) * cscale
	if not cost.is_empty() and not Data.can_pay(players[e.player].res, cost):
		e.cooldown = 1.0
		return
	# DONOR T6-M01: gold-upkeep units (incl. ships) stop firing when the owner
	# has <4 gold; deterministic state check, no new RNG.
	if (e.def.get("eat", {}) as Dictionary).has("gold") \
			and float(players[e.player].res[_UPKEEP_RES_IDX[1]]) < _GOLD_FIRE_STOP_RES:
		e.cooldown = _GOLD_FIRE_STOP_S
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
	var rof: float = 1.0
	if e.kind == "building":
		rof = float(e.get("rof_mult", 1.0))
	else:
		rof = float(players[e.player].get("rof_mult", {}).get(str(w.kind), 1.0))
	e.cooldown = w.cd * rof
	e.fire_t = time_s
	stats.shots += 1
	# officer aura + researched powder upgrades multiply the listed damage
	var mult: float = effective_damage(e.player, w.kind, e.pos, e)
	var base_dmg := int(round(float(w.dmg) * mult)) + _formation_atk(e, w.kind) + bonus
	if str(w.kind) in ["sword", "pike"]:
		base_dmg += int(players[e.player].get("melee_add", 0))
		if not str(e.get("cavalry", "")).is_empty():
			base_dmg += int(players[e.player].get("cav_dmg_add", 0))
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
		_say_human(int(e.player), "Enemy peasant captured!")
		return
	# towers are fortifications: only artillery, grenades and arrows hurt them
	if t.kind == "building" and t.sid in ["tow", "wal", "gat"] and not str(w.kind) in ["cannonball", "cannister", "arrow", "firearrow"]:
		return
	# protection + researched armor, upgrade-aware
	var prot: Array = (t.get("prot", [0, 0, 0, 0, 0, 0]) as Array).duplicate()
	var pb: int = int(players[t.player].get("prot_bonus", 0))
	if not str(t.get("cavalry", "")).is_empty():
		pb += int(players[t.player].get("cav_prot_bonus", 0))
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
		_award_squad_xp(e)  # RB G-13: surviving squad gains veteran XP
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
		for u in grid_query(p.target, 8.0):
			if u.dead:
				continue
			var d: float = u.pos.distance_to(p.target)
			var rr: float = 1.2 + float(u.get("block_r", u.def.radius))
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
	# Carry a FULL load before walking to the store. Delivering after every
	# single hit paid only GATHER.carry/GATHER.hits (~2 food), which upkeep
	# consumed immediately - food never reached the player (t_mill_logic).
	var node: Dictionary = by_id.get(o.get("node", 0), {})
	var full_load: int = int(Data.GATHER.get(res, {}).get("hits", 1))
	if e.carry >= full_load or (e.carry > 0 and not node.is_empty() and int(node.get("hits", 0)) <= 0):
		_gather_deliver(e, dt)
		return
	var avoid_n := _bad_id(e, "bad_node", "bad_t")
	if node.is_empty() or node.get("hits", 0) <= 0:
		node = nearest_res(e.pos, res, 30.0, true, avoid_n)
		if node.is_empty():
			e.order = {"type": "none"}
			return
		o.node = node.id
	# T-FOOD-1: a directly-referenced wild food node (old save / debug spawn)
	# is not harvestable - drop the order instead of gathering from it.
	# nearest_res() already filters these for auto-retargeting.
	if res == "food" and not node.has("mill"):
		e.order = {"type": "none"}
		e.moving = false
		return
	# the spot itself is blocked (a tree stands on it), so the peasant works
	# from the neighbouring tile: stand-off must be wider than the arrival
	# radius, otherwise the unit ends up in a dead zone and never works.
	# each peasant works from its own slot around the tree/rock so workers
	# fan out instead of overlapping on the same point.
	# G-13: donor dmscript.global:222-225 caps simultaneous gatherers per node
	# (food 3 / wood 2 / stone 3). The old code capped only food, at 2.
	var max_workers: int = int(Data.RESOURCE_WORKERS.get(res, 3))
	if max_workers > 0:
		var on_node := 0
		for u in grid_query(node.pos, node.radius + 2.0):
			if not u.dead and u.id != e.id and u.order.type == "gather" and u.order.get("node", 0) == node.id and u.pos.distance_to(node.pos) < node.radius + 2.0:
				on_node += 1
		if on_node >= max_workers:
			var alt := nearest_res(e.pos, res, 45.0, true)
			if not alt.is_empty() and alt.id != node.id:
				o.node = alt.id
				node = alt
			else:
				e.order = {"type": "none"}
				return
	var slot := _work_slot(e, node.pos, node.radius + 1.1)
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
			elif res == "food":
				node["growth"] = 0.0
				node["regrow_t"] = 0.0
				if float(node.get("regrow_time", 0.0)) <= 0.0:
					node["regrow_time"] = FIELD_REGROW_TIME
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
	# T-FOOD-1: never resume on a wild (mill-less) food node.
	if res == "food" and not node.is_empty() and not node.has("mill"):
		e.order = {"type": "none"}
		return
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
		var tsm: float = 1.0
		if not str(Data.UNITS.get(job.sid, {}).get("cavalry", "")).is_empty():
			tsm = float(players[e.player].get("train_speed_mult", 1.0))
		if e.sid == "art":
			tsm = float(players[e.player].get("art_build_mult", 1.0))
		job.t -= dt * tsm
		e.queue[0] = job
		if job.t <= 0.0:
			# T5MOD: do NOT pop blindly.  Finite jobs carry count; endless jobs
			# (infinite=true) re-arm until cancelled or resources run out.
			var brexit: float = float(e.get("block_r", e.def.radius))
			var exit: Vector2 = e.get("rally", e.pos + Vector2(0, e.def.radius + 2.0))
			var naval: bool = bool(Data.UNITS.get(job.sid, {}).get("naval", false))
			if naval:
				var wp := _naval_spawn_pos(e)
				if wp.x >= 0.0:
					exit = wp
			var dir: Vector2 = (exit - e.pos).normalized()
			if dir.length_squared() < 0.01:
				dir = Vector2(0.0, 1.0)
			var slot: int = int(e.get("spawn_n", 0))
			e["spawn_n"] = slot + 1
			# T5GEN F1: every unit appears on a different free tile outside the
			# building's blocked door band (block_r+0.5 could be inside it).
			var sp: Vector2 = _spawn_slot(e, dir, brexit, slot, naval)
			if naval and exit.distance_to(e.pos) > brexit:
				sp = exit  # water tile: never spawn a hull on the dock's land
			var u := spawn(job.sid, e.player, sp)
			# T5GEN F1: stagger rally targets into a small formation instead of
			# one identical point 3 m out, so the column extends as units arrive.
			cmd_move(u, _rally_slot(exit, dir, slot))
			post_event("trained", e.pos, job.sid, job.sid)
			# T5MOD: advance the job instead of always removing it.
			if bool(job.get("infinite", false)):
				if pay_cost(e.player, Data.UNITS.get(job.sid, {}).get("price", {})):
					job.t = float(Data.UNITS.get(job.sid, {}).get("build_time", 1.0))
					e.queue[0] = job
				else:
					e.queue.pop_front()  # endless stops when resources/requirements fail
			else:
				var left: int = maxi(1, int(job.get("count", 1))) - 1
				if left > 0:
					job["count"] = left
					job.t = float(Data.UNITS.get(job.sid, {}).get("build_time", 1.0))
					e.queue[0] = job
				else:
					e.queue.pop_front()
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
	# DONOR mode semantics: artillery_only never checks buildings; the
	# no-peasants-or-centres mode freezes the town hall itself.
	if e.finished and e.def.get("capture", false) and _building_capture_allowed(e):
		var peasants_allowed := bool(Data.CAPTURE_ENABLED)
		var peas := 0
		var sols := 0
		var capturer := -1
		for u in grid_query(e.pos, 8.0 + e.def.radius):
			if not u.dead and u.kind == "unit" and u.player != e.player \
					and _capture_unit_allowed(u) \
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
			# G-09: a live guard order on this building blocks capture until the
			# defender is gone (RB_MECHANICS S5). The defender need not shoot.
			for u in live_units:
				if u.dead or int(u.player) == capturer:
					continue
				var go: Dictionary = u.get("order", {})
				if str(go.get("type", "")) == "guard" and int(go.get("target", 0)) == int(e.id):
					capturer = -1
					break
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
				# G-07: capturing a foreign town hall unlocks that nation's
				# unit variants for the capturer (RB_MECHANICS S5).
				if e.sid == "cen":
					var old_nation: String = str(players[old].get("nation", ""))
					if old_nation != "" and old_nation != str(players[capturer].get("nation", "")):
						var cn: Array = players[capturer].get("captured_nations", [])
						if not cn.has(old_nation):
							cn.append(old_nation)
						players[capturer]["captured_nations"] = cn
				players[old].entities.erase(e.id)
				players[capturer].entities.append(e.id)
				players[capturer].score += e.def.get("score", 0)
				if e.def.has("farm"):
					players[old].farm_cap = maxi(0, int(players[old].farm_cap) - int(e.def.get("farm", 0)))
					players[capturer].farm_cap += e.def.farm
				if e.sid.begins_with("mine_"):
					e["deposit_left"] = float(e.get("deposit_left", 0.0))
				# R12-04: donor _unit_ClearOrders / _unit_CancelUpgradePerform
				# (miscext.script:1115-1132) fire on capture - queued production
				# and any in-progress upgrade are lost; no refund to old owner.
				e["queue"] = []
				e["research"] = null
				e.erase("rally")
				# W3-1 / X1 C10: _on_building_finished will not run again for a
				# captured trainer, so re-arm the same default rally here.
				if e.def.has("trains"):
					e["rally"] = _default_rally(e)
				post_event("capture", e.pos, e.sid)
				# R02 claim 11 / P-44: do not spam the human chat for AI captures.
				_say_human(capturer, "A building was captured!")
		else:
			e.capture_t = maxf(0.0, e.capture_t - dt)

func _winner_of_loser(loser: int) -> int:
	# Team game: a surviving member of the opposing team (allies never win).
	# Free-for-all: any surviving player - the 2-player case reduces to 1 - pi.
	var lt: int = int(players[loser].get("team", -1))
	var alive: Array[int] = []
	for pi in players.size():
		if pi == loser:
			continue
		if buildings_of(pi).is_empty() and units_of(pi).is_empty():
			continue
		if lt >= 0 and int(players[pi].get("team", -1)) == lt:
			continue
		alive.append(pi)
	return alive[0] if not alive.is_empty() else -1

func _team_alive(team: int) -> bool:
	for pi in players.size():
		if int(players[pi].get("team", -1)) != team:
			continue
		if not buildings_of(pi).is_empty() or not units_of(pi).is_empty():
			return true
	return false

func _check_victory() -> void:
	# T-MENU-ROSTER donor "Peace Time": no victory is awarded before the
	# configured number of seconds has elapsed. Combat itself is unchanged.
	if Data.PEACE_TIME > 0.0 and time_s < Data.PEACE_TIME:
		return
	# "destroy_all": the side that has nothing left loses (the port's default,
	# estimated - the original skirmish condition was not in readable files).
	# "score": the first side to reach the score limit wins.
	if Data.VICTORY == "score":
		for pi in players.size():
			if winner == -1 and players[pi].score >= Data.SCORE_LIMIT:
				winner = pi
				game_over.emit(winner)
				say("%s wins!" % players[winner].name)
		return
	for pi in players.size():
		if winner != -1:
			break
		# T5SIM: a player is alive if they hold EITHER buildings OR units.
		# The old `and` treated "buildings but no units" (e.g. a famine/wave
		# wiped army with a working town hall) as eliminated, handing an
		# unearned instant victory to the opponent. Elimination now requires
		# BOTH to be empty.
		if not buildings_of(pi).is_empty() or not units_of(pi).is_empty():
			continue
		# A player eliminated while a teammate survives is NOT a team defeat.
		var team: int = int(players[pi].get("team", -1))
		if team >= 0 and _team_alive(team):
			continue
		winner = _winner_of_loser(pi)
		if winner < 0:
			return
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
	nav.configure(MAP_W, MAP_H, TILE)
	nav_version += 1
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
	# T-PERF-SIM: the entity/resource set was swapped wholesale; cached
	# buckets/rects from the pre-load game must not survive.
	_res_grid.clear()
	_res_grid_ver = -1
	_res_grid_src_size = -1
	_block_rects.clear()
	_block_rects_by_cell.clear()
	_block_rects_ver = -1
	_nav_ink_cells.clear()
	_nav_ink_ver = -1
	_sep_bld_ver = -1
	# tile art uses its own deterministic stream â€” restore the seed first so a
	# quicksave made with seed A reloads with seed A's shore/smooth/variant art.
	if d.has("seed"):
		Data.RANDOM_SEED = int(d.seed)
	_assign_tileblocks()
	return true
