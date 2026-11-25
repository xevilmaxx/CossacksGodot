# Donor terrain-mask sampler (Cossacks 3 data/gen/terrainmasks/*.tga).
# The real game builds EVERY random map from one hand-authored RGB heightmask:
#   R = relief (255 plateau, 96 hill, 48 ravine), G = forest/stone, B = water,
#   pure white = player start marker.  Height is assigned in generatemap.inc:
#     h = cWaterHeight*(b*(1+r*3.5)) + relief(r)     (cWaterHeight = -1.1)
#   water < -0.25, shore < -0.1 (texturemap.inc).  Coast is smoothed 3 passes.
# This file does exactly that, at the port's map resolution, and nothing else:
# it produces the height/forest fields and the two start positions.  All
# resource/pattern placement stays in game.gd (the donor's pattern passes).
#
# T-MINES-FIX: ore deposits are NOT placed here.  They are stamped as "mine"
# pattern masks by C3PatternGen.SetupMines (pattern_gen.gd, donor D1:522-717)
# and realised as radius-0 resource nodes by game.gd:_gen_patterns().
# pattern_gen.gd's final authoritative pass OWNS the layout: it relocates the
# same stamps (count unchanged) so every start gets gold+iron+coal in the
# 6..14 tile band (worst case 16) with ZERO footprint intersection, and so all
# map-wide mines are footprint-disjoint.  game.gd:_ensure_start_ore_clusters()
# re-checks against the FINAL map_starts (water snap / appended slots) with the
# same _ore_spot_clear footprint rule; it never adds or removes a deposit.
# C3MapGen stays deterministic: pick() uses its own seed+type-hash stream and
# never touches game.gd's `rng`.
extends RefCounted
class_name C3MapGen

const C_WATER := -1.1       # generatemap.inc:7
const C_PLATEAU := 2.964    # generatemap.inc:4
const C_HILL := 2.964 / 2.25 # generatemap.inc:5
const C_RAVINE := -2.964    # generatemap.inc:6
const WATER_DEEP := -0.25   # texturemap.inc:30
const WATER_SHORE := -0.1   # texturemap.inc:31

static var _manifest: Dictionary = {}

static func manifest() -> Dictionary:
	if _manifest.is_empty():
		var txt := FileAccess.get_file_as_string("res://assets/terrain/masks/manifest.json")
		var parsed: Variant = JSON.parse_string(txt)
		if parsed is Dictionary:
			_manifest = parsed
	return _manifest

static func types() -> Array:
	var m := manifest()
	return (m.get("types", {}) as Dictionary).keys()

static func mask_count(type: String) -> int:
	var types_d: Dictionary = manifest().get("types", {})
	var t: Dictionary = types_d.get(type, {})
	return (t.get("masks", []) as Array).size()

static func pick(type: String, seed: int) -> Dictionary:
	var types_d: Dictionary = manifest().get("types", {})
	if not types_d.has(type):
		type = "land"
	var list: Array = (types_d.get(type, {}) as Dictionary).get("masks", [])
	if list.is_empty():
		return {}
	# Independent, deterministic stream: same seed+type always picks same mask.
	var r := RandomNumberGenerator.new()
	r.seed = (int(seed) ^ int(type.hash())) + 104729
	return list[r.randi() % list.size()]

# RCODE-FIX-01: exact donor 8-code decode (port approximation of the authored
# bitmap sampler; no bands, no invented ramp).  Donor generatemap.inc:342-370
# decodes the byte with `ir = floor(fr*255)` and classes ONLY the exact codes
# 255/191 (plateau), 96/112 (hill), 48/88 (ravine); everything else,
# including 64 and 250-254, is cRNone.  Height is class x fr
# (generatemap.inc:569-573: cPlateauHeight*fr / cHillHeight*fr /
# cRavineHeight*fr); the `//*(255/cRColorHill)` / `//*(255/cRColorRavine)`
# suffixes on :571-572 are //-disabled, so the live amplitudes at R=96 and
# R=48 are +0.495937 and -0.557929, NOT +1.317333 / -2.964.
# roundi() recovers the authored 8-bit byte from the float channel: exact
# code bytes round-trip; the port's multi-pixel cell average is a pre-existing
# port approximation, not a donor class (HEIGHT-GEN-DEEP-01 §6 row 3).
static func relief(v: float) -> float:
	var code := roundi(v)
	match code:
		255, 191:
			return C_PLATEAU * (float(code) / 255.0)
		96, 112:
			return C_HILL * (float(code) / 255.0)
		48, 88:
			return C_RAVINE * (float(code) / 255.0)
		_:
			return 0.0

# Donor `bsmooth` flag (generatemap.inc:354,358,362,367): true for the three
# smooth relief codes and for code 64.  The donor then calls
# SmoothTerrain(realx,-realy,False,3) on those cells (:587-592); its native
# kernel is UNVERIFIED, so this port exposes the flag as data only and does
# NOT invent a smoothing operator here (follow-up: wire the flag downstream).
static func relief_smooth(v: float) -> bool:
	var code := roundi(v)
	return code == 64 or code == 88 or code == 112 or code == 191

static func _starts_from_mask(m: Dictionary, w: int, h: int, tile: float) -> Array:
	var raw: Array = m.get("starts", [])
	var pts: Array = []
	for s in raw:
		if s is Array and s.size() >= 2:
			pts.append(Vector2(float(s[0]) * float(w) + 0.5, float(s[1]) * float(h) + 0.5))
	if pts.size() >= 2:
		# Four-player masks are common in the donor even for 2-player games;
		# take the farthest pair so the two lobbies start on opposite shores.
		var bi := 0
		var bj := 1
		var bd := -1.0
		for i in pts.size():
			for j in range(i + 1, pts.size()):
				var d: float = (pts[i] - pts[j]).length_squared()
				if d > bd:
					bd = d
					bi = i
					bj = j
		return [pts[bi] * tile, pts[bj] * tile]
	return [Vector2(float(w) * 0.125 * tile, float(h) * 0.125 * tile),
		Vector2(float(w) * 0.875 * tile, float(h) * 0.875 * tile)]

static func _near_water(height: PackedFloat32Array, w: int, h: int) -> PackedByteArray:
	var near := PackedByteArray()
	near.resize(w * h)
	for y in h:
		for x in w:
			var i := y * w + x
			var low := false
			if height[i] < 0.8:
				low = true
			else:
				for oy in range(-2, 3):
					var ny := y + oy
					if ny < 0 or ny >= h:
						continue
					for ox in range(-2, 3):
						var nx := x + ox
						if nx < 0 or nx >= w:
							continue
						if height[ny * w + nx] < -0.1:
							low = true
							break
					if low:
						break
			near[i] = 1 if low else 0
	return near

static func build(map_type: String, seed: int, w: int, h: int, tile: float,
		quality: String, depth: int = 0) -> Dictionary:
	var m := pick(map_type, seed)
	var height := PackedFloat32Array()
	height.resize(w * h)
	var forest := PackedFloat32Array()
	forest.resize(w * h)
	# RCODE-FIX-01: donor bsmooth flag carried as data, no kernel invented.
	var smooth := PackedByteArray()
	smooth.resize(w * h)
	if m.is_empty():
		for i in height.size():
			height[i] = 0.0
			forest[i] = 0.0
		return {"height": height, "forest": forest,
			"starts": _starts_from_mask({}, w, h, tile), "mask": {}, "water": 0.0,
			"relief_smooth": smooth}
	var path := "res://assets/terrain/masks/" + str(m.get("file", ""))
	# Export-safe: masks are imported as Texture2D (CompressedTexture2D).
	# Image.load() on res:// works in-editor but warns and fails on export
	# (raw PNG not shipped). Load via Texture2D and read the Image instead.
	var mtex: Texture2D = ResourceLoader.load(path) as Texture2D
	if mtex == null:
		push_warning("mapgen: missing mask ", path)
		# Fall back to a land mask once; if that is missing too (or retries pile
		# up) return a flat empty map. Never recurse without a bound: with a
		# missing asset this looped forever and hung map generation.
		if map_type == "land" or depth >= 4:
			for i in height.size():
				height[i] = 0.0
				forest[i] = 0.0
			return {"height": height, "forest": forest,
				"starts": _starts_from_mask({}, w, h, tile), "mask": {}, "water": 0.0,
				"relief_smooth": smooth}
		return build("land", seed + 1, w, h, tile, quality, depth + 1)
	var im: Image = mtex.get_image()
	if im.get_format() != Image.FORMAT_RGB8:
		im.convert(Image.FORMAT_RGB8)
	var iw := im.get_width()
	var ih := im.get_height()
	var water := 0
	for y in h:
		var sy0: int = int(float(y) / float(h) * ih)
		var sy1: int = maxi(sy0 + 1, int(float(y + 1) / float(h) * ih))
		for x in w:
			var sx0: int = int(float(x) / float(w) * iw)
			var sx1: int = maxi(sx0 + 1, int(float(x + 1) / float(w) * iw))
			var cr := 0.0
			var cg := 0.0
			var cb := 0.0
			var n := 0
			for sy in range(sy0, sy1):
				for sx in range(sx0, sx1):
					var c: Color = im.get_pixel(sx, sy)
					# donor skips the pure-white start markers when writing height
					if c.r > 0.99 and c.g > 0.99 and c.b > 0.99:
						continue
					cr += c.r * 255.0
					cg += c.g * 255.0
					cb += c.b * 255.0
					n += 1
			if n == 0:
				continue
			cr /= float(n)
			cg /= float(n)
			cb /= float(n)
			var i := y * w + x
			var hw: float = C_WATER * (cb / 255.0) * (1.0 + (cr / 255.0) * 3.5)
			height[i] = hw + relief(cr)
			smooth[i] = 1 if relief_smooth(cr) else 0
			forest[i] = cg / 255.0
			if height[i] < WATER_DEEP:
				water += 1
	# donor: 3 coastal smoothing passes (generatemap.inc 611-640).
	# low quality uses 1: same coastline, slightly crisper shore height.
	var passes := 3
	if quality == "low":
		passes = 1
	elif quality == "medium":
		passes = 2
	var near := _near_water(height, w, h)
	for _p in passes:
		var src := height.duplicate()
		for y in range(1, h - 1):
			for x in range(1, w - 1):
				var i := y * w + x
				if near[i] == 0:
					continue
				var avg: float = (src[i - w - 1] + src[i - w + 1] + src[i + w - 1]
					+ src[i + w + 1]) * 0.25
				height[i] = src[i] + (avg - src[i]) * 0.5
	return {"height": height, "forest": forest,
		"starts": _starts_from_mask(m, w, h, tile), "mask": m,
		"water": float(water) / float(w * h), "relief_smooth": smooth}
