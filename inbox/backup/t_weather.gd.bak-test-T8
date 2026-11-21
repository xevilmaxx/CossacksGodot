# Small test: seasons / weather / day-night (board P-21, RE gap 4; donor
# data/env, env.cfg, time.cfg and the winter/desert season blocks).
#
# Asserts the INTENDED behaviour of the season/day-night system. The port does
# not implement it yet (Data.BIOME exists and mapgen reads it for desert_*
# patterns, but world.gd has no season terrain swap and no lighting clock), so
# several checks fail on the baseline. That is the correct result for a pending
# feature - do NOT weaken the assertions to make them green.
#
# Real APIs used: C3Config.apply/value, Data.BIOME, C3Game.setup, C3World.bind,
# C3World._build_chunk / _block_img cache, C3World.sync, game.time_s.
#
# Run with:
#   python app\tools\godot_runner.py run --id t-weather --timeout 90 -- \
#       --headless --path app --script res://tests/t_weather.gd
extends SceneTree

const Data = preload("res://scripts/data.gd")
const C3Config = preload("res://scripts/config.gd")
const C3Game = preload("res://scripts/game.gd")
const C3World = preload("res://scripts/world.gd")

const OUT_DIR := "res://tests/results"

var _id := "t_weather"
var _checks: Array[Dictionary] = []
var _ok := true
var _start_ms := 0
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

# Bake one real terrain chunk (0,0) through the renderer and return its image.
func _chunk_image() -> Image:
	if world == null:
		return null
	var sp = world._build_chunk(0, 0)
	if sp == null or not (sp is Sprite2D):
		return null
	var tex: Texture2D = (sp as Sprite2D).texture
	var img: Image = tex.get_image() if tex != null else null
	sp.queue_free()
	return img

# Season palettes are cached by block name; force a fresh bake after a change.
func _clear_block_cache() -> void:
	if world == null:
		return
	world.blk_cache.clear()
	world.blk_order.clear()
	world.gain_map = null

func _nonuniform(img: Image) -> bool:
	if img == null or img.is_empty():
		return false
	var c0 := img.get_pixel(0, 0)
	var w := img.get_width()
	var h := img.get_height()
	for xy in [Vector2i(1, 1), Vector2i(w / 2, h / 2), Vector2i(w - 1, h - 1)]:
		if img.get_pixel(xy.x, xy.y) != c0:
			return true
	return false

# Deterministic image fingerprint (PackedByteArray has no hash() in Godot 4).
func _img_hash(img: Image) -> int:
	if img == null or img.is_empty():
		return -1
	var d := img.get_data()
	var step: int = maxi(1, int(d.size() / 512))
	var h := 0
	for i in range(0, d.size(), step):
		h = (h * 131 + int(d[i])) & 0x7fffffff
	return h

# Read the real scene's ambient/lighting observable, without assuming one
# particular implementation name. A day/night system normally adds either a
# CanvasModulate layer or a named tint/brightness property on the world.
func _lighting_brightness() -> float:
	if world == null:
		return -1.0
	for c in world.get_children():
		if c is CanvasModulate:
			return (c as CanvasModulate).color.get_luminance()
	for p in world.get_property_list():
		var n := str(p.get("name", "")).to_lower()
		if n.contains("ambient") or n.contains("bright") or n.contains("light") \
				or n.contains("daynight") or n.contains("day_night") or n.contains("tint"):
			var v = world.get(str(p.get("name", "")))
			if v is Color:
				return (v as Color).get_luminance()
			if v is float or v is int:
				return float(v)
	return -1.0

func _initialize() -> void:
	_start_ms = Time.get_ticks_msec()
	Data.AI_ENABLED = false

	# 1. A season/weather setting is accepted by config AND drives the real
	#    season state used by mapgen (Data.BIOME). Baseline: apply() ignores it.
	var cfg := C3Config.new()
	cfg.data = {"gameplay": {"biome": "winter", "season": "winter", "weather": "snow"}}
	var cfg_reads := cfg.text("gameplay.biome", "") == "winter" \
		and cfg.text("gameplay.season", "") == "winter" \
		and cfg.text("gameplay.weather", "") == "snow"
	cfg.apply()
	var cfg_applies := str(Data.BIOME) == "winter"
	check("config_season_accepted", cfg_reads and cfg_applies,
		"config reads biome=%s season=%s weather=%s; Data.BIOME=%s (want winter)" % [
			cfg.text("gameplay.biome", ""), cfg.text("gameplay.season", ""),
			cfg.text("gameplay.weather", ""), str(Data.BIOME)])

	# Small terrain keeps the CPU bake fast; no changes to sim rules.
	Data.TERRAIN_PX = 4
	Data.BIOME = "summer"
	game = C3Game.new()
	root.add_child(game)
	game.setup("skirmish")
	world = C3World.new()
	root.add_child(world)
	world.bind(game)

	# 2. Headless render still works: a real chunk bakes to a non-empty,
	#    non-uniform image with no window and no GPU frame.
	var summer_img := _chunk_image()
	var render_ok := summer_img != null and not summer_img.is_empty() \
		and _nonuniform(summer_img)
	check("headless_render", render_ok,
		"chunk 0,0 bytes=%s nonuniform=%s" % [
			str(summer_img.get_data().size() if summer_img != null else 0),
			str(_nonuniform(summer_img))])

	# 3/4. The season palette actually changes the rendered terrain. Setting
	#      Data.BIOME is the real season switch mapgen/world already read.
	var summer_hash := _img_hash(summer_img)
	Data.BIOME = "winter"
	_clear_block_cache()
	var winter_img := _chunk_image()
	var winter_hash := _img_hash(winter_img)
	check("winter_terrain_change", winter_hash != summer_hash and winter_hash != -1,
		"summer hash=%d winter hash=%d (must differ)" % [summer_hash, winter_hash])

	Data.BIOME = "desert"
	_clear_block_cache()
	var desert_img := _chunk_image()
	var desert_hash := _img_hash(desert_img)
	check("desert_terrain_change", desert_hash != summer_hash and desert_hash != -1,
		"summer hash=%d desert hash=%d (must differ)" % [summer_hash, desert_hash])

	# 5. Ambient/brightness follows the clock: noon vs night must produce a
	#    different lighting value through the real world.sync() path.
	Data.BIOME = "summer"
	_clear_block_cache()
	game.time_s = 12.0 * 3600.0
	world.sync(0.016)
	var noon := _lighting_brightness()
	game.time_s = 23.0 * 3600.0
	world.sync(0.016)
	var night := _lighting_brightness()
	check("day_night_brightness", noon >= 0.0 and night >= 0.0 \
		and absf(noon - night) > 0.02,
		"noon=%.3f night=%.3f (need an ambient/tint observable driven by game.time_s)" % [noon, night])

	# 6. No new hangs: all probes completed inside the runner's hard timeout.
	var elapsed_s := float(Time.get_ticks_msec() - _start_ms) / 1000.0
	check("no_new_hangs", elapsed_s < 60.0,
		"all checks completed in %.2fs (runner hard timeout 90s)" % elapsed_s)

	_write_result()
	# Never call quit() directly from _initialize() (hangs in Godot 4.7).
	call_deferred("quit", 0 if _ok else 1)
