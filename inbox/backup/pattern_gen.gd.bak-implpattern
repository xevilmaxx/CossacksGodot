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
		terrain: PackedByteArray, water_id: int, biome: String) -> Dictionary:
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

	var can_stand := func(cells: Array, cx: int, cy: int) -> bool:
		for c in cells:
			var cc: Vector2i = c
			var tx: int = cx + cc.x
			var ty: int = cy + cc.y
			if tx < 0 or ty < 0 or tx >= map_w or ty >= map_h:
				return false
			if occupied[ty * map_w + tx] != 0:
				return false
		return true

	var stand := func(cells: Array, cx: int, cy: int) -> void:
		for c in cells:
			var cc: Vector2i = c
			var tx: int = cx + cc.x
			var ty: int = cy + cc.y
			if tx >= 0 and ty >= 0 and tx < map_w and ty < map_h:
				occupied[ty * map_w + tx] = 1

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
			kind: String, region_idx: int = -1) -> int:
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
				if can_stand.call(cells, cx, cy):
					stand.call(cells, cx, cy)
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
	var mark_ellipse := func(st: Vector2, r: Vector2) -> void:
		var cx: int = int(st.x)
		var cy: int = int(st.y)
		var rx := maxf(1.0, r.x * s)
		var ry := maxf(1.0, r.y * s)
		for y in range(maxi(0, cy - int(ry)), mini(map_h, cy + int(ry) + 1)):
			for x in range(maxi(0, cx - int(rx)), mini(map_w, cx + int(rx) + 1)):
				var nx := (float(x) - float(cx)) / rx
				var ny := (float(y) - float(cy)) / ry
				if nx * nx + ny * ny <= 1.0:
					occupied[y * map_w + x] = 1

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
		stamp_family.call("forests_pine_small", 2, 128, "forest", si)
		stamp_family.call("forests_mixed_medium", 1, 128, "forest", si)
		for st in start_tiles:
			mark_ellipse.call(st, CIRCLE2)

	# rest stage: weighted forest/stone/hill/decor families across the map
	var area_scale := float(map_w * map_h) / (160.0 * 160.0)
	var recipes := [
		["forests_pinefir_big", 2, "forest"],
		["forests_pine_medium", 2, "forest"],
		["forests_spruce_big", 1, "forest"],
		["forests_leaf_medium", 1, "forest"],
		["forests_mixed_big", 1, "forest"],
		["forests_pine_small", 2, "forest"],
		["forests_leaf_small", 1, "forest"],
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

	return {"stamps": stamps, "occupied": occupied, "scale": s}
