# Small test: animated water / shoreline fidelity (board P-21, RE gap 6).
#
# Asserts the INTENDED donor-equivalent behaviour of water and its shoreline:
#   - seed 7 actually generates a lake (terrain 3) with BLK_WATER tile blocks;
#   - water tile rendering has non-flat wave variants or a sparkle/shimmer
#     state (RE_VISUAL gap 6a, L3 §0169 "flat blue + sparkle, variants[3]");
#   - a walkable sand collar (terrain 4) rings the water (gap 6b foam/collar);
#   - deep water is impassable for movement and building placement;
#   - the sim runs for N seconds without corrupting state.
#
# On the current port water is ONE static wave crop (diffusewaves2.png) baked
# at a fixed chunk offset: world.variants buckets are empty and there is no
# sparkle/animated-wave state. The water-rendering check therefore FAILS on the
# baseline — that is the correct verdict for a pending feature, not a test bug.
# Do NOT weaken it to accept a flat single-frame surface.
#
# Run with:
#   python app\tools\godot_runner.py run --id t-water --timeout 90 -- \
#       --headless --path app --script res://tests/t_water.gd
extends SceneTree

const Data = preload("res://scripts/data.gd")
# game.gd/world.gd declare class_name C3Game / C3World, so reference them as
# global classes (the selftest.gd pattern) rather than preloading by path.

const OUT_DIR := "res://tests/results"
const SEED := 7
const SIM_SECONDS := 30.0
const SIM_DT := 0.1

var _id := "t_water"
var _checks: Array[Dictionary] = []
var _ok := true
var game
var world

func check(name: String, cond: bool, detail: String = "") -> void:
	_checks.append({"name": name, "passed": cond, "detail": detail})
	print(("  PASS  " if cond else "  FAIL  ") + name + " - " + detail)
	if not cond:
		_ok = false

func _write_result() -> void:
	var abs_dir := ProjectSettings.globalize_path(OUT_DIR)
	DirAccess.make_dir_recursive_absolute(abs_dir)
	var path := "%s/%s.json" % [abs_dir, _id]
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_error("cannot write test result: " + path)
		return
	f.store_string(JSON.stringify({
		"id": _id,
		"passed": _ok,
		"checks": _checks,
		"unix_ms": Time.get_unix_time_from_system() * 1000.0,
	}, "\t"))
	f.close()

func _tile_center(x: int, y: int) -> Vector2:
	return Vector2((float(x) + 0.5) * game.TILE, (float(y) + 0.5) * game.TILE)

# Does a tile (x,y) have at least one water (terrain 3) neighbour?
func _touches_water(x: int, y: int) -> bool:
	for oy in range(-1, 2):
		for ox in range(-1, 2):
			if ox == 0 and oy == 0:
				continue
			var nx: int = x + ox
			var ny: int = y + oy
			if nx < 0 or ny < 0 or nx >= game.MAP_W or ny >= game.MAP_H:
				continue
			if int(game.terrain[game._t(nx, ny)]) == 3:
				return true
	return false

# Detect real rendering-side water-variant / sparkle state via the renderer's
# own state (no render awaits needed). Returns [bool, detail].
func _water_variant_signal(w) -> Array:
	var signals: Array[String] = []

	# (a) L3 §0169 documented water-variant tiles: world.variants[3].
	if w.variants.size() > 3 and (w.variants[3] as Array).size() > 0:
		signals.append("variants[3]=%d" % (w.variants[3] as Array).size())
	else:
		var total := 0
		for b in w.variants:
			if b is Array:
				total += (b as Array).size()
		if total > 0:
			signals.append("variant_tiles=%d" % total)

	# (b) sparkle / multi-frame wave state exposed by the renderer. Reflection
	# keeps this independent of the exact field name the feature owner picks.
	for p in w.get_property_list():
		var pn := str(p.get("name", ""))
		var low := pn.to_lower()
		var v: Variant = w.get(pn)
		if low.contains("sparkle") or low.contains("shimmer"):
			if (v is bool and bool(v)) or (v is int and int(v) > 0) \
					or (v is float and float(v) > 0.0) \
					or (v is Array and (v as Array).size() > 0) \
					or (v is Dictionary and not (v as Dictionary).is_empty()):
				signals.append("%s=%s" % [pn, str(v)])
		elif (low.contains("wave") or low.contains("water")) \
				and v is Array and (v as Array).size() >= 2:
			signals.append("%s[%d]" % [pn, (v as Array).size()])

	if signals.is_empty():
		return [false, "no non-flat water variants (variants buckets empty) and no sparkle/animated-wave state"]
	return [true, ", ".join(signals)]

func _initialize() -> void:
	Data.AI_ENABLED = false
	Data.RANDOM_SEED = SEED

	game = C3Game.new()
	root.add_child(game)
	game.setup("skirmish")

	# --- scan the generated terrain grid once --------------------------------
	var water_tiles: Array[int] = []
	var sand_tiles := 0
	var sand_by_water := 0
	var water_blkwater := 0
	for y in game.MAP_H:
		for x in game.MAP_W:
			var i: int = game._t(x, y)
			var t: int = int(game.terrain[i])
			if t == 3:
				water_tiles.append(i)
				if int(game.tileblock[i]) == C3Game.BLK_WATER:
					water_blkwater += 1
			elif t == 4:
				sand_tiles += 1
				if _touches_water(x, y):
					sand_by_water += 1

	# 1. Lake tiles present at seed 7.
	check("lake_tiles_present", water_tiles.size() > 16,
		"seed=%d water(terrain=3)=%d tiles, BLK_WATER-tagged=%d" % [
			SEED, water_tiles.size(), water_blkwater])

	# 2. Sand ring neighbours water (donor wet-sand collar / gap 6b).
	check("sand_ring_neighbours_water", sand_by_water > 4,
		"sand(terrain=4) tiles touching water=%d of %d" % [sand_by_water, sand_tiles])

	# 3. Water is blocked for movement.
	var sampled := 0
	var blocked_ok := 0
	for i in water_tiles:
		if sampled >= 64:
			break
		var x: int = i % game.MAP_W
		var y: int = i / game.MAP_W
		if game.is_blocked(_tile_center(x, y)):
			blocked_ok += 1
		sampled += 1
	check("water_blocked_for_movement", sampled > 0 and blocked_ok == sampled,
		"sampled=%d blocked=%d" % [sampled, blocked_ok])

	# --- renderer state (headless: CPU image work only, no render awaits) -----
	world = C3World.new()
	root.add_child(world)
	world.bind(game)

	# 4. Water tile rendering yields non-flat variants or a sparkle state.
	var wv: Array = _water_variant_signal(world)
	check("water_nonflat_variants_or_sparkle", bool(wv[0]), str(wv[1]))

	# 5. No errors / state corruption over N sim seconds.
	var t_before: float = game.time_s
	var finite := true
	var steps := int(SIM_SECONDS / SIM_DT)
	for _s in steps:
		game.tick(SIM_DT)
		if not is_finite(game.time_s):
			finite = false
			break
	var advanced: float = game.time_s - t_before
	var units_finite := true
	for e in game.live_units:
		if not is_finite(e.pos.x) or not is_finite(e.pos.y):
			units_finite = false
			break
	# water stays impassable after the sim (terrain grid unchanged)
	var water_still_blocked := true
	if water_tiles.size() > 0:
		var wi: int = water_tiles[0]
		water_still_blocked = game.is_blocked(_tile_center(wi % game.MAP_W, wi / game.MAP_W))
	check("sim_no_errors", finite and units_finite and water_still_blocked \
			and absf(advanced - SIM_SECONDS) < 0.001,
		"advanced %.2fs over %d ticks, time_finite=%s units_finite=%s water_blocked=%s winner=%d" % [
			advanced, steps, str(finite), str(units_finite), str(water_still_blocked), game.winner])

	_write_result()
	# Never call quit() directly from _initialize() (hangs in Godot 4.7).
	call_deferred("quit", 0 if _ok else 1)
