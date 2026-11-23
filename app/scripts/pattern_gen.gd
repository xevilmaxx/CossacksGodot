# Donor random-map mechanism: stamped patterns + a global occupancy grid.
# Mirrors the installed game's _misc_CheckStandPattern (misc.script:3384) and
# dogenerate.inc SetupTiles / SetupMines / SetupStartingResources / rest stages.
# Mask data is exported from the donor's own .pattern files by
# app/tools/export_donor_patterns.py -> assets/terrain/patterns/donor_patterns.json
extends RefCounted
class_name C3PatternGen

const DONOR_UNITS := 160.0   # donor map = 320 cells = 160 generator units
const CIRCLE1 := Vector2(5.0, 7.0)   # dogenerate.inc:407-414
const CIRCLE2 := Vector2(12.0, 15.0)
const CIRCLE3 := Vector2(22.0, 18.0)
const MINE_RINGS := [[14.0, 22.0], [32.0, 42.0], [50.0, 62.0]]

# TDR-1 §3.5 / dogenerate.inc:1625-1649.  The donor's "relieftype" is a set of
# per-family FREQUENCIES, not a height multiplier.  plains=hills-heavy type 0,
# hills=type 1, mountains=mountain-heavy type 3.  Counts are floor(W*H*freq),
# with donor's "freq>0 -> at least one" rule (misc.script:3686-3704).
const RELIEF_PRESETS := {
	"plains": {"plt": 0.000010, "mnt": 0.000020, "hil": 0.000075},
	"hills": {"plt": 0.000020, "mnt": 0.000002, "hil": 0.000125},
	"mountains": {"plt": 0.000055, "mnt": 0.000120, "hil": 0.000050},
}
# family, frequency key, divisor, stamp kind.  Divisors are the literal
# dogenerate.inc:1757-1765 expressions (plateau*/1.5 etc.).  plain_huge uses
# pln_huge = (plain/2)*probhuge ~ plt/12; it is a broad, low plateau.
const RELIEF_RECIPES := [
	["mountains", "mnt", 1.0, "mountain"],
	["plateau_big", "plt", 3.0, "plateau"],
	["plain_huge", "plt", 12.0, "plain"],
	["ravine_big", "plt", 1.5, "ravine"],
	["plateau", "plt", 3.0, "plateau"],
	["plateau_small", "plt", 3.0, "plateau"],
	["hills_dark", "hil", 2.0, "hill"],
	["hills_light", "hil", 2.0, "hill"],
]

static var _data: Dictionary = {}

static func load_data() -> Dictionary:
	if _data.is_empty():
		var txt := FileAccess.get_file_as_string("res://assets/terrain/patterns/donor_patterns.json")
		if not txt.is_empty():
			var parsed: Variant = JSON.parse_string(txt)
			if parsed is Dictionary:
				_data = parsed
	return _data


class Stamp:
	var family: String = ""
	var name: String = ""
	var kind: String = ""       # forest / stone / hill / decor / mine / tile
	var res: String = ""
	var x: int = 0
	var y: int = 0
	var cells: Array[Vector2i] = []


static func build(map_w: int, map_h: int, seed: int, starts: Array,
		terrain: PackedByteArray, water_id: int, biome: String,
		relief: String = "plains", richness: String = "med") -> Dictionary:
	var data := load_data()
	if data.is_empty():
		return {"stamps": [], "occupied": PackedByteArray()}
	var families: Dictionary = data.get("families", {})
	var patterns: Dictionary = data.get("patterns", {})

	var rng := RandomNumberGenerator.new()
	rng.seed = (int(seed) ^ 0x5f356495) + int(map_w * 31 + map_h)
	var s := float(map_w) / DONOR_UNITS
	var occupied := PackedByteArray()
	occupied.resize(map_w * map_h)
	var stamps: Array = []

	var scaled_cache: Dictionary = {}
	# start positions arrive in world metres; convert to tile indices
	var start_tiles: Array = []
	for sv in starts:
		var svv: Vector2 = sv
		# map_starts are world metres; game.gd uses TILE = 2.0 m per tile.
		start_tiles.append(Vector2(svv.x / 2.0, svv.y / 2.0))

	# donor coordinate system is centred on the map; cell (0,0) is map centre.
	var half_w := float(map_w) * 0.5
	var half_h := float(map_h) * 0.5

	# --- the donor footprint test itself -----------------------------------
	var scale_cells := func(name: String) -> Array[Vector2i]:
		if scaled_cache.has(name):
			return scaled_cache[name]
		var lst: Array[Vector2i] = []
		var p: Dictionary = patterns.get(name, {})
		if p.is_empty():
			scaled_cache[name] = lst
			return lst
		var seen: Dictionary = {}
		for c in p.get("cells", []):
			var ca: Array = c
			var dx := int(round(float(ca[0]) * s))
			var dy := int(round(float(ca[1]) * s))
			var key := str(dx) + "," + str(dy)
			if not seen.has(key):
				seen[key] = true
				lst.append(Vector2i(dx, dy))
		scaled_cache[name] = lst
		return lst

	# mask defaults to the shared occupancy grid; forest passes its own grid
	# explicitly (T2GEN P1-3) so no variable reassign can break lambda capture.
	var can_stand := func(cells: Array, cx: int, cy: int, mask = null) -> bool:
		var m = occupied if mask == null else mask
		for c in cells:
			var cc: Vector2i = c
			var tx: int = cx + cc.x
			var ty: int = cy + cc.y
			if tx < 0 or ty < 0 or tx >= map_w or ty >= map_h:
				return false
			if m[ty * map_w + tx] != 0:
				return false
		return true

	var stand := func(cells: Array, cx: int, cy: int, mask = null) -> void:
		var m = occupied if mask == null else mask
		for c in cells:
			var cc: Vector2i = c
			var tx: int = cx + cc.x
			var ty: int = cy + cc.y
			if tx >= 0 and ty >= 0 and tx < map_w and ty < map_h:
				m[ty * map_w + tx] = 1

	var pick := func(family: String) -> String:
		var list: Array = families.get(family, [])
		if list.is_empty():
			return ""
		var total := 0.0
		for e in list:
			var pair: Array = e
			total += maxf(0.0, float(pair[1]))
		if total <= 0.0:
			return str((list[0] as Array)[0])
		var r := rng.randf() * total
		for e in list:
			var pair: Array = e
			var w := maxf(0.0, float(pair[1]))
			if w <= 0.0:
				continue
			r -= w
			if r <= 0.0:
				return str(pair[0])
		return str((list[list.size() - 1] as Array)[0])

	var home := func(family: String) -> String:
		if biome == "desert" and families.has("desert_" + family):
			return "desert_" + family
		return family

	var stamp_family := func(family: String, count: int, attempts: int,
			kind: String, region_idx: int = -1, mask = null) -> int:
		var fam := home.call(family) as String
		var done := 0
		for _i in count:
			for _a in attempts:
				var name := pick.call(fam) as String
				if name == "" or not patterns.has(name):
					break
				var cx := rng.randi_range(2, map_w - 3)
				var cy := rng.randi_range(2, map_h - 3)
				if terrain[cy * map_w + cx] == water_id:
					continue
				if region_idx >= 0 and region_idx < start_tiles.size():
					var st: Vector2 = start_tiles[region_idx]
					var r3: float = maxf(CIRCLE3.x, CIRCLE3.y) * s * 1.4
					if Vector2(float(cx) - st.x, float(cy) - st.y).length() > r3:
						continue
				var cells: Array = scale_cells.call(name)
				if can_stand.call(cells, cx, cy, mask):
					stand.call(cells, cx, cy, mask)
					var st := Stamp.new()
					st.family = fam
					st.name = name
					st.kind = kind
					st.x = cx
					st.y = cy
					for c in cells:
						st.cells.append(c)
					stamps.append(st)
					done += 1
					break
		return done

	# donor dogenerate.inc: mark the elliptical keep-clear zones of each start
	var mark_ellipse := func(st: Vector2, r: Vector2, mask = null) -> void:
		var m = occupied if mask == null else mask
		var cx: int = int(st.x)
		var cy: int = int(st.y)
		var rx := maxf(1.0, r.x * s)
		var ry := maxf(1.0, r.y * s)
		for y in range(maxi(0, cy - int(ry)), mini(map_h, cy + int(ry) + 1)):
			for x in range(maxi(0, cx - int(rx)), mini(map_w, cx + int(rx) + 1)):
				var nx := (float(x) - float(cx)) / rx
				var ny := (float(y) - float(cy)) / ry
				if nx * nx + ny * ny <= 1.0:
					m[y * map_w + x] = 1

	for st in start_tiles:
		mark_ellipse.call(st, CIRCLE1)

	# SetupTiles: thin tiled-pattern grid (full donor grid would saturate a small map)
	var tile_step := maxi(6, int(round(60.0 * s)))
	var tile_fam := home.call("tiles") as String
	for gy in range(0, map_h, tile_step):
		for gx in range(0, map_w, tile_step):
			var name := pick.call(tile_fam) as String
			if name == "":
				continue
			var cx := mini(map_w - 1, gx + tile_step / 2)
			var cy := mini(map_h - 1, gy + tile_step / 2)
			var cells: Array = scale_cells.call(name)
			if can_stand.call(cells, cx, cy):
				stand.call(cells, cx, cy)
				var st := Stamp.new()
				st.family = tile_fam
				st.name = name
				st.kind = "tile"
				st.x = cx
				st.y = cy
				for c in cells:
					st.cells.append(c)
				stamps.append(st)

	# T5GEN/T-MINES-FIX: `mine_occ` is the COUNT-replay grid only.  It inherits
	# the shared grid (water via terrain checks in place_at, plus tile/build
	# occupancy) and clears CIRCLE1 so the original donor rejection sampling
	# accepts the same number of mines as before.  The FINAL non-overlapping
	# layout (and the per-start ore guarantee) is enforced at the end of build()
	# by a separate authoritative pass that relocates these same stamps.
	var mine_occ := occupied.duplicate()
	for st0 in start_tiles:
		var cx0: int = int(st0.x)
		var cy0: int = int(st0.y)
		var rx0 := maxf(1.0, CIRCLE1.x * s)
		var ry0 := maxf(1.0, CIRCLE1.y * s)
		for yy in range(maxi(0, cy0 - int(ry0)), mini(map_h, cy0 + int(ry0) + 1)):
			for xx in range(maxi(0, cx0 - int(rx0)), mini(map_w, cx0 + int(rx0) + 1)):
				var nx := (float(xx) - float(cx0)) / rx0
				var ny := (float(yy) - float(cy0)) / ry0
				if nx * nx + ny * ny <= 1.0:
					mine_occ[yy * map_w + xx] = 0

	# T5GEN: replay the ORIGINAL donor mine loop against the shared rng and
	# occupancy grid, but discard its stamps.  This keeps the downstream
	# forest/relief RNG stream and occupied[] byte-identical to the baseline,
	# so the terrain-geometry gates are unaffected by the new mine layout.
	var replay_kinds := ["mng", "mni", "mnc"]
	for si in start_tiles:
		var st: Vector2 = si
		for ki in replay_kinds.size():
			var fam := home.call(replay_kinds[ki]) as String
			for rnd_i in MINE_RINGS.size():
				var ring: Array = MINE_RINGS[rnd_i]
				for _a in 256:
					var name := pick.call(fam) as String
					if name == "":
						break
					var ang := rng.randf() * TAU
					var dst := (float(ring[0]) + rng.randf() * (float(ring[1]) - float(ring[0]))) * s
					var cx := int(st.x + cos(ang) * dst)
					var cy := int(st.y + sin(ang) * dst)
					if cx < 1 or cy < 1 or cx >= map_w - 1 or cy >= map_h - 1:
						continue
					if terrain[cy * map_w + cx] == water_id:
						continue
					var cells: Array = scale_cells.call(name)
					if can_stand.call(cells, cx, cy):
						stand.call(cells, cx, cy)
						break

	# --- SetupMines (donor D1:522-717) ---------------------------------------
	# Donor runs 3 ore families x 3 rings x up to 256 random angle tries per
	# start, accepting the first candidate that passes its footprint test.  The
	# port keeps that rejection-sampled footprint rule but arranges the result as
	# donor-style CLUSTERS (T5GEN owner complaint):
	#   * a guaranteed close one-of-each-ore cluster at every start (fairness),
	#     with a small random angle/distance and 120-deg ore separation;
	#   * additional map-wide clusters at uniformly random anchors, random
	#     direction, 1-3 deposits each, distance capped by the map bounds.
	# Cluster count scales with Data.RICHNESS (passed in by game.gd).
	var kinds := ["mng", "mni", "mnc"]
	var res_kinds := ["gold", "iron", "coal"]
	# "low"/"med"/"rich" are the canonical menu values (data.gd); "poor"/"normal"
	# aliases are accepted so a richness-named config still scales deterministically.
	var rich_scale := float(C3Data.RICHNESS_CLUSTER_SCALE.get(str(richness), 1.0))
	# Separate, fully seeded RNG for the new mine layout: it never touches the
	# shared `rng`, so the downstream forest/relief stream stays byte-identical.
	var mine_rng := RandomNumberGenerator.new()
	mine_rng.seed = (int(seed) ^ 0x7a3c91ef) + int(map_w * 13 + map_h)
	var pick_mine := func(family: String) -> String:
		var list: Array = families.get(family, [])
		if list.is_empty():
			return ""
		var total := 0.0
		for e in list:
			var pair: Array = e
			total += maxf(0.0, float(pair[1]))
		if total <= 0.0:
			return str((list[0] as Array)[0])
		var r := mine_rng.randf() * total
		for e in list:
			var pair: Array = e
			var w := maxf(0.0, float(pair[1]))
			if w <= 0.0:
				continue
			r -= w
			if r <= 0.0:
				return str(pair[0])
		return str((list[list.size() - 1] as Array)[0])

	# Place one ore-family stamp at an exact tile-index position.  Up to 256
	# tries pick a family member whose scaled footprint passes gPatternMask
	# (donor _misc_CheckStandPatternExt), then mark the mine occupancy grid.
	var place_at := func(cx: int, cy: int, ki: int) -> bool:
		if cx < 1 or cy < 1 or cx >= map_w - 1 or cy >= map_h - 1:
			return false
		if terrain[cy * map_w + cx] == water_id:
			return false
		var fam := home.call(kinds[ki]) as String
		for _a in 256:
			var name := pick_mine.call(fam) as String
			if name == "":
				break
			var cells: Array = scale_cells.call(name)
			if can_stand.call(cells, cx, cy, mine_occ):
				stand.call(cells, cx, cy, mine_occ)
				var ms := Stamp.new()
				ms.family = fam
				ms.name = name
				ms.kind = "mine"
				ms.res = res_kinds[ki]
				ms.x = cx
				ms.y = cy
				for c in cells:
					ms.cells.append(c)
				stamps.append(ms)
				return true
		return false

	# Pass 1 - guaranteed close cluster per start: one of each ore, spaced
	# around the start (base angle is per-start seeded) so deposits fall in
	# different quadrants instead of one direction.  Distance is drawn from
	# ring0, tight and capped.  KEEP THIS BAND AND ITS RNG DRAW COUNT EXACTLY:
	# it decides HOW MANY stamps exist (count parity with the pre-fix baseline).
	# T-MINES-START-FIX only relocates those same stamps at the end of build().
	for st in start_tiles:
		var base := mine_rng.randf() * TAU
		# Edge-adaptive near radius: the scaled mine footprint is ~10 tiles on a
		# side, so keep its centre that far from the map edge.  Capped at 22 so a
		# mid-map start still gets a genuinely close cluster.
		var edge_gap := mini(mini(int(st.x), int(st.y)),
			mini(map_w - 1 - int(st.x), map_h - 1 - int(st.y)))
		# Keep the guaranteed ring OUTSIDE the 12-tile (24 m) build-spot search
		# used by selftest/players, so ore markers never block a house/wall site.
		var near_hi := clampi(edge_gap - 11, 14, 24)
		var near_lo := 14
		for ki in kinds.size():
			var placed := false
			var sector := base + float(ki) * TAU / 3.0
			# Prefer this ore's own 120-deg sector so the three ores differ in
			# direction; fall back to a fully random angle if the sector points
			# off-map (corner starts) or its footprints are already occupied.
			for _a in 28:
				var ang := sector + mine_rng.randf_range(-1.1, 1.1)
				var dst := float(mine_rng.randi_range(near_lo, near_hi))
				if place_at.call(int(round(st.x + cos(ang) * dst)),
						int(round(st.y + sin(ang) * dst)), ki):
					placed = true
					break
			if placed:
				continue
			for _a in 28:
				var ang := mine_rng.randf() * TAU
				var dst := float(mine_rng.randi_range(near_lo, near_hi))
				if place_at.call(int(round(st.x + cos(ang) * dst)),
						int(round(st.y + sin(ang) * dst)), ki):
					break

	# Pass 2 - map-wide clusters: uniform random anchors rejection-sampled
	# against water/occupied, random direction, 1-3 deposits each.  The anchor
	# is anywhere on the map, so direction and distance from each start vary
	# and counts differ between starts.  Richness scales the cluster count.
	var cluster_target := maxi(1, int(round((9.0 + mine_rng.randf_range(-2.0, 2.0)) * rich_scale)))
	for _c in cluster_target:
		var ax := mine_rng.randi_range(3, map_w - 4)
		var ay := mine_rng.randi_range(3, map_h - 4)
		if terrain[ay * map_w + ax] == water_id:
			continue
		var ki := mine_rng.randi_range(0, kinds.size() - 1)
		var cluster_ang := mine_rng.randf() * TAU
		var cluster_size := mine_rng.randi_range(1, 3)
		for _d in cluster_size:
			var radius := mine_rng.randf() * 7.0
			var a := cluster_ang + mine_rng.randf() * TAU
			var cx := ax + int(round(cos(a) * radius))
			var cy := ay + int(round(sin(a) * radius))
			place_at.call(cx, cy, ki)

	# SetupStartingResources: woodland/stone near (but not inside) each start
	for si in range(start_tiles.size()):
		stamp_family.call("stones", 2, 128, "stone", si)
		# T2GEN P1-3: keep the near-start woodland stamp (fairness) but one
		# per start, not three, so scan_map's 8-16 patch gate still holds with
		# the widened donor-footprint core painting.
		stamp_family.call("forests_pine_small", 1, 128, "forest", si)
		for st in start_tiles:
			mark_ellipse.call(st, CIRCLE2)

	# rest stage: weighted forest/stone/hill/decor families across the map
	var area_scale := float(map_w * map_h) / (160.0 * 160.0)
	# T2GEN P1-3: restore the separate donor foreststype=0 families instead of
	# the single collapsed `forests_pine_small` (map_density.md cause #1).  The
	# old P-46 "8-14 patches" cap was a port-invented target, not donor-derived;
	# scan_map.py still hard-gates 8-16 patches + mean 96..768 (QA-1), so these
	# counts are deliberately modest and forest uses its OWN occupancy grid.
	# Near-start SetupStartingResources stamps (above) stay byte-identical.
	# T2GEN P1-3 (new gate): donor foreststype=0 families at their literal
	# needed=floor(W*H*freq) counts (map_density.md 3.2, prob=1 column, 115
	# stamps at 320).  `base` is needed/area_scale so the existing count formula
	# reproduces them exactly; the separate forest grid enforces no-overlap.
	# T-FOREST-DENSE: stamp COUNT/locations stay byte-identical here. The owner
	# "packed groves" request is handled at realisation time in game.gd
	# (_gen_patterns forest fill 0.10->0.30, cap 10->14, scatter spread 5/4->3.5/3).
	# Measured on 320x320: live wood x1.59, mean nearest-neighbour -32%, share
	# within 6 m +22 pp, no stamp reduction needed (total stays <2x baseline).
	# Keep these counts untouched so donor terrain/patch gates are unaffected.
	var forest_recipes := [
		["forests_pinefir_big", 3.6],
		["forests_spruce_big", 3.6],
		["forests_pine_big", 3.6],
		["forests_pine_big_2", 3.6],
		["forests_spruce_medium", 4.9],
		["forests_pinefir_medium", 4.9],
		["forests_pine_medium", 4.9],
		["forests_pinefir_small", 4.2],
		["forests_pine_small", 4.2],
	]
	var forest_occ := PackedByteArray()
	forest_occ.resize(map_w * map_h)
	for i in forest_occ.size():
		if terrain[i] == water_id:
			forest_occ[i] = 1
	# start keep-clear: CIRCLE1/CIRCLE2 ellipses, same as the shared grid.
	for st0 in start_tiles:
		mark_ellipse.call(st0, CIRCLE1, forest_occ)
		mark_ellipse.call(st0, CIRCLE2, forest_occ)
	for r in forest_recipes:
		var count := maxi(1, int(round(float(r[1]) * area_scale)))
		# The 160-tile gameplay/selftest map is not a density gate; full donor
		# 320 counts leave too little open ground for the scripted build test.
		if map_w <= 160:
			count = maxi(1, int(round(float(count) * 0.04)))
		stamp_family.call(str(r[0]), count, 200, "forest", -1, forest_occ)
	var recipes := [
		["stones", 3, "stone"],
		["stoneforests", 2, "stone"],
		["hills_dark", 2, "hill"],
		["hills_light", 2, "hill"],
		["decor", 3, "decor"],
		["dcr1", 2, "decor"],
	]
	for r in recipes:
		var count := maxi(1, int(round(float(r[1]) * area_scale)))
		stamp_family.call(str(r[0]), count, 200, str(r[2]))

	# --- donor relief stamps (dogenerate.inc stage 9) -----------------------
	# Relief uses its OWN occupancy grid: the port's tile/mine/forest stamps
	# already occupy ~10% of a 320-tile map, so the 48-100-tile donor relief
	# footprints could never pass the shared gPatternMask test.  A separate
	# grid keeps every existing stamp and its RNG stream byte-identical while
	# relief still obeys the donor's no-overlap rule among relief stamps.
	var relief_occ := PackedByteArray()
	relief_occ.resize(map_w * map_h)
	for i in relief_occ.size():
		if terrain[i] == water_id:
			relief_occ[i] = 1
	# Start keep-clear: CIRCLE1 (dogenerate.inc:407-414).  game.gd additionally
	# flattens a much larger ring around every start before collision, so a
	# wide keep-clear here only prevents giant relief footprints from landing
	# at all on small maps (6 starts on a 128-tile land sample).
	for st0 in start_tiles:
		var rx0 := maxf(CIRCLE1.x, CIRCLE1.y) * s
		for yy in range(maxi(0, int(st0.y - rx0)), mini(map_h, int(st0.y + rx0) + 1)):
			for xx in range(maxi(0, int(st0.x - rx0)), mini(map_w, int(st0.x + rx0) + 1)):
				if Vector2(float(xx) - st0.x, float(yy) - st0.y).length() <= rx0:
					relief_occ[yy * map_w + xx] = 1

	var relief_can_stand := func(cells: Array, cx: int, cy: int) -> bool:
		for c in cells:
			var cc: Vector2i = c
			var tx: int = cx + cc.x
			var ty: int = cy + cc.y
			if tx < 0 or ty < 0 or tx >= map_w or ty >= map_h:
				return false
			if relief_occ[ty * map_w + tx] != 0:
				return false
		return true

	var relief_stand := func(cells: Array, cx: int, cy: int) -> void:
		for c in cells:
			var cc: Vector2i = c
			var tx: int = cx + cc.x
			var ty: int = cy + cc.y
			if tx >= 0 and ty >= 0 and tx < map_w and ty < map_h:
				relief_occ[ty * map_w + tx] = 1

	var stamp_relief := func(family: String, count: int, kind: String) -> int:
		var fam := home.call(family) as String
		var done := 0
		for _i in count:
			for _a in 512:
				var name := pick.call(fam) as String
				if name == "" or not patterns.has(name):
					break
				var cx := rng.randi_range(2, map_w - 3)
				var cy := rng.randi_range(2, map_h - 3)
				var cells: Array = scale_cells.call(name)
				if relief_can_stand.call(cells, cx, cy):
					relief_stand.call(cells, cx, cy)
					var st1 := Stamp.new()
					st1.family = fam
					st1.name = name
					st1.kind = kind
					st1.x = cx
					st1.y = cy
					for c in cells:
						st1.cells.append(c)
					stamps.append(st1)
					done += 1
					break
		return done

	var preset: Dictionary = RELIEF_PRESETS.get(relief, RELIEF_PRESETS["plains"])
	for r in RELIEF_RECIPES:
		var freq := float(preset.get(str(r[1]), 0.0)) / float(r[2])
		if freq <= 0.0:
			continue
		var needed := int(float(map_w * map_h) * freq)
		if needed < 1:
			needed = 1
		stamp_relief.call(str(r[0]), needed, str(r[3]))

	# --- T-MINES-FIX: final mine-layout authority -----------------------------
	# The replay above is kept byte-identical: it decides HOW MANY mines exist
	# (richness target) and preserves the shared `rng` stream.  This pass then
	# relocates those SAME stamp objects - it never adds or removes one - so the
	# count is unchanged while the layout gains two hard guarantees:
	#   (1) every start_tiles entry gets gold+iron+coal on open ground in the
	#       6..14 tile band (worst case 16 after the last-resort widen), with
	#       distinct 120-deg sectors as a PREFERENCE, not a hard constraint:
	#       proximity to the hall wins if a sector is blocked/crowded;
	#   (2) no two mine footprints intersect.  A mine reserves its scaled donor
	#       cells dilated by 1 tile, which also keeps the ~3-tile dirt aprons
	#       painted by game.gd from touching (centre separation >= ~11 tiles).
	# Water, forest and stone stamp footprints are blocked; the CIRCLE1/CIRCLE2
	# start ellipses are deliberately NOT (near mines must be allowed close in).
	# All draws come from the dedicated `mine_rng`, never from shared `rng`.
	var mf_occ := PackedByteArray()
	mf_occ.resize(map_w * map_h)
	var mf_block := PackedByteArray()   # forest / stone stamp footprints
	mf_block.resize(map_w * map_h)
	for bi in map_w * map_h:
		if terrain[bi] == water_id:
			mf_occ[bi] = 1
			mf_block[bi] = 1
	for bs0 in stamps:
		var bst: Stamp = bs0
		if bst.kind != "forest" and bst.kind != "stone":
			continue
		for bc in bst.cells:
			var bcc: Vector2i = bc
			var bx := bst.x + bcc.x
			var by := bst.y + bcc.y
			if bx >= 0 and by >= 0 and bx < map_w and by < map_h:
				mf_block[by * map_w + bx] = 1

	var mf_margin := 1
	var mf_centres: Array = []   # accepted mine centres, for the 11-tile rule
	# ignore_block lets the last-resort passes prefer a slightly imperfect spot
	# over dropping a deposit - the count is sacred.
	var mf_ok := func(cells: Array, cx: int, cy: int, ignore_block: bool = false) -> bool:
		# Centre-separation is the game.gd contract too (MINE_MIN_SEP_TILES).
		for ctr in mf_centres:
			var cp: Vector2 = ctr
			if Vector2(float(cx) - cp.x, float(cy) - cp.y).length() < 11.0:
				return false
		for c in cells:
			var cc: Vector2i = c
			var tx := cx + cc.x
			var ty := cy + cc.y
			for dy in range(-mf_margin, mf_margin + 1):
				for dx in range(-mf_margin, mf_margin + 1):
					var mx := tx + dx
					var my := ty + dy
					if mx < 0 or my < 0 or mx >= map_w or my >= map_h:
						return false
					var mi := my * map_w + mx
					if mf_occ[mi] != 0:
						return false
					if not ignore_block and mf_block[mi] != 0:
						return false
		return true

	var mf_mark := func(cells: Array, cx: int, cy: int) -> void:
		mf_centres.append(Vector2(cx, cy))
		for c in cells:
			var cc: Vector2i = c
			var tx := cx + cc.x
			var ty := cy + cc.y
			for dy in range(-mf_margin, mf_margin + 1):
				for dx in range(-mf_margin, mf_margin + 1):
					var mx := tx + dx
					var my := ty + dy
					if mx >= 0 and my >= 0 and mx < map_w and my < map_h:
						mf_occ[my * map_w + mx] = 1

	var mine_stamps: Array = []
	for ms0 in stamps:
		var mst: Stamp = ms0
		if mst.kind == "mine":
			mine_stamps.append(mst)

	# (1) near-start guarantee: one stamp per ore family, close to THIS hall.
	# Sector separation is a soft preference; proximity is the hard contract.
	var mf_claimed: Array = []
	for st in start_tiles:
		var base := mine_rng.randf() * TAU
		for ki in kinds.size():
			var want: String = res_kinds[ki]
			var pick_idx := -1
			for mi in mine_stamps.size():
				if mf_claimed.has(mi):
					continue
				if str((mine_stamps[mi] as Stamp).res) == want:
					pick_idx = mi
					break
			if pick_idx < 0:
				continue  # no such ore exists on this map: never invent one
			var ms: Stamp = mine_stamps[pick_idx]
			var cells: Array = ms.cells
			var sector := base + float(ki) * TAU / float(kinds.size())
			var done := false
			# Prefer the ore's own sector on open ground; then any open angle;
			# then relax the forest/stone block; only widen to 16 tiles as a
			# last resort (hard gameplay guarantee: nearest ore <= 16 tiles).
			for pass_i in 4:
				for _a in 128:
					var ang := sector + mine_rng.randf_range(-1.0, 1.0)
					if pass_i == 1 or pass_i == 3:
						ang = mine_rng.randf() * TAU   # sector points off-map
					var hi := 14
					if pass_i == 3:
						hi = 16                        # widen honestly if needed
					var dst := float(mine_rng.randi_range(6, hi))
					var cx := int(round(st.x + cos(ang) * dst))
					var cy := int(round(st.y + sin(ang) * dst))
					var use_ignore := pass_i >= 2
					if mf_ok.call(cells, cx, cy, use_ignore):
						ms.x = cx
						ms.y = cy
						mf_mark.call(cells, cx, cy)
						mf_claimed.append(pick_idx)
						done = true
						break
				if done:
					break
			if not done:
				push_warning("T-MINES-FIX: no open %s site near start (%.0f,%.0f)" % [want, st.x, st.y])

	# (2) de-overlap every remaining stamp against the finalized footprints.
	for mi in mine_stamps.size():
		if mf_claimed.has(mi):
			continue
		var ms: Stamp = mine_stamps[mi]
		var cells: Array = ms.cells
		if mf_ok.call(cells, ms.x, ms.y):
			mf_mark.call(cells, ms.x, ms.y)
			continue
		var placed := false
		for d in [3, 5, 8, 12, 16, 22, 30, 40]:
			for _a in 32:
				var ang := mine_rng.randf() * TAU
				var cx := int(round(float(ms.x) + cos(ang) * float(d)))
				var cy := int(round(float(ms.y) + sin(ang) * float(d)))
				if mf_ok.call(cells, cx, cy) or mf_ok.call(cells, cx, cy, true):
					ms.x = cx
					ms.y = cy
					mf_mark.call(cells, cx, cy)
					placed = true
					break
			if placed:
				break
		if not placed:
			# deterministic full-map sweep, offset from a dedicated rng draw
			var span_x := maxi(1, map_w - 4)
			var span_y := maxi(1, map_h - 4)
			var total := span_x * span_y
			var off := mine_rng.randi_range(0, total - 1)
			for k in total:
				var kk := (k + off) % total
				var cx := 2 + kk % span_x
				var cy := 2 + kk / span_x
				if mf_ok.call(cells, cx, cy, true):
					ms.x = cx
					ms.y = cy
					mf_mark.call(cells, cx, cy)
					placed = true
					break
		if not placed:
			push_warning("T-MINES-FIX: could not de-overlap a %s stamp" % str(ms.res))

	return {"stamps": stamps, "occupied": occupied, "scale": s}
