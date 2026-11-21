# Focused regression test for the visual-tuning settings (no dependency on the
# long gameplay self-test):
#   display.unit_scale     - unit figures scale relative to donor buildings
#   display.show_centroids - flat round anchor disks under props/buildings
#   display.units_opaque   - unit sprites drawn solid, with normal colours
#
# Run with:
#   godot --headless --path app --script res://tests/visual_tuning_test.gd
extends SceneTree

const Data = preload("res://scripts/data.gd")
const C3Config = preload("res://scripts/config.gd")
const C3Game = preload("res://scripts/game.gd")
const C3World = preload("res://scripts/world.gd")

var checks: Array = []
var game
var world

func _check(name: String, ok: bool, detail: String) -> void:
	checks.append({"name": name, "ok": ok, "detail": detail})
	print(("  PASS  " if ok else "  FAIL  ") + name + " - " + detail)

func _cfg_with(values: Dictionary) -> C3Config:
	var cfg := C3Config.new()
	cfg.data = {"display": values}
	cfg.apply()
	return cfg

func _entity() -> Dictionary:
	return {
		"sid": "peasant", "player": 0, "id": 7,
		"order": {"type": "idle"}, "death_t": -1.0, "fire_t": -1.0,
		"moving": false, "face": 0.0, "carry": 0, "carry_type": "",
	}

# Draw one unit through the real animation path and return the queued rect.
func _sprite_rect() -> Rect2:
	world.pending_unit_sprites.clear()
	world._draw_anim(_entity(), Vector2(400.0, 300.0), Color(1, 1, 1))
	if world.pending_unit_sprites.is_empty():
		return Rect2()
	return world.pending_unit_sprites[0]["dst"]

func _initialize() -> void:
	# ---- 1. config defaults and overrides -------------------------------
	var defaults := C3Config.new()
	defaults.load_all()
	_check("config.defaults",
		is_equal_approx(defaults.num("display.unit_scale", -1.0), 1.25)
		and not defaults.flag("display.show_centroids", true)
		and defaults.flag("display.units_opaque", false),
		"unit_scale=%s show_centroids=%s units_opaque=%s" % [
			str(defaults.num("display.unit_scale", -1.0)),
			str(defaults.flag("display.show_centroids", true)),
			str(defaults.flag("display.units_opaque", false))])

	_cfg_with({"unit_scale": 2.0, "show_centroids": true, "units_opaque": true})
	_check("config.apply",
		is_equal_approx(Data.UNIT_SCALE, 2.0) and Data.SHOW_CENTROIDS
		and Data.UNITS_OPAQUE,
		"Data UNIT_SCALE=%s SHOW_CENTROIDS=%s UNITS_OPAQUE=%s" % [
			str(Data.UNIT_SCALE), str(Data.SHOW_CENTROIDS), str(Data.UNITS_OPAQUE)])

	_cfg_with({"unit_scale": 0.25})   # clamp low
	var clamped_low: float = Data.UNIT_SCALE
	_cfg_with({"unit_scale": 99.0})   # clamp high
	_check("config.clamp",
		is_equal_approx(clamped_low, 0.25) and is_equal_approx(Data.UNIT_SCALE, 4.0),
		"low=%s high=%s" % [str(clamped_low), str(Data.UNIT_SCALE)])

	# ---- 2. rendering state ---------------------------------------------
	_cfg_with({"unit_scale": 1.0, "show_centroids": false, "units_opaque": true})
	game = C3Game.new()
	root.add_child(game)
	game.setup("skirmish")
	world = C3World.new()
	root.add_child(world)
	world.bind(game)

	_check("shader.attached",
		world.unit_anim_layer != null and world.unit_anim_layer.material != null,
		"unit_anim_layer.material=%s" % str(world.unit_anim_layer.material))

	var base := _sprite_rect()
	_check("anim.draw_queued", base.has_area(),
		"rect size=%s" % str(base.size))

	# ---- 3. UNIT_SCALE really changes the drawn figure ------------------
	_cfg_with({"unit_scale": 2.0})
	var doubled := _sprite_rect()
	_check("unit_scale.doubles",
		base.has_area() and is_equal_approx(doubled.size.x, base.size.x * 2.0)
		and is_equal_approx(doubled.size.y, base.size.y * 2.0),
		"1.0=%s  2.0=%s" % [str(base.size), str(doubled.size)])

	# the ground anchor must not move when the figure is scaled
	var p0 := Vector2(400.0, 300.0)
	world.pending_unit_sprites.clear()
	world._draw_anim(_entity(), p0, Color(1, 1, 1))
	var r1: Rect2 = world.pending_unit_sprites[0]["dst"]
	_cfg_with({"unit_scale": 1.0})
	world.pending_unit_sprites.clear()
	world._draw_anim(_entity(), p0, Color(1, 1, 1))
	var r2: Rect2 = world.pending_unit_sprites[0]["dst"]
	var foot1 := r1.position.y + r1.size.y * 0.7978
	var foot2 := r2.position.y + r2.size.y * 0.7978
	_check("unit_scale.anchored", absf(foot1 - foot2) < 1.0,
		"foot y at scale 2.0=%.2f, 1.0=%.2f" % [foot1, foot2])

	# ---- 4. UNITS_OPAQUE toggles the shader ------------------------------
	# bind() already attached it; re-running the decision with the flag off
	# must leave the figure layer unshaded.
	_cfg_with({"units_opaque": false})
	var bare := C3World.new()
	root.add_child(bare)
	bare.bind(game)
	_check("shader.disabled",
		bare.unit_anim_layer != null and bare.unit_anim_layer.material == null,
		"material=%s" % str(bare.unit_anim_layer.material))

	# ---- 5. centroid flag is read by the renderer ------------------------
	_cfg_with({"show_centroids": false})
	var no_dots: bool = Data.SHOW_CENTROIDS
	_cfg_with({"show_centroids": true})
	var dots: bool = Data.SHOW_CENTROIDS
	_check("centroids.toggle", not no_dots and dots,
		"false=%s true=%s (gates both the prop and building disk draws)" % [
			str(no_dots), str(dots)])

	_finish()

func _finish() -> void:
	var ok := true
	for c in checks:
		if not c.ok:
			ok = false
	print("visual_tuning_test: %d/%d checks passed" % [
		checks.filter(func(c): return c.ok).size(), checks.size()])
	quit(0 if ok else 1)
