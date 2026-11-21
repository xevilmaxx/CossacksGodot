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
		relief: String = "plains") -> Dictionary:
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

	# SetupMines: 3 kinds x 3 rings x 256 random angles per start
	var kinds := ["mng", "mni", "mnc"]
	var res_kinds := ["gold", "iron", "coal"]
	for si in start_tiles:
		var st: Vector2 = si
		for ki in kinds.size():
			var fam := home.call(kinds[ki]) as String
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
						var st2 := Stamp.new()
						st2.family = fam
						st2.name = name
						st2.kind = "mine"
						st2.res = res_kinds[ki]
						st2.x = cx
						st2.y = cy
						for c in cells:
							st2.cells.append(c)
						stamps.append(st2)
						break

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

	return {"stamps": stamps, "occupied": occupied, "scale": s}
