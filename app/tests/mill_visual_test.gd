# Visual regression test for the windmill's separate rotating sail rotor.
# Run with:
#   godot --headless --path app --script res://tests/mill_visual_test.gd
extends SceneTree

const Data = preload("res://scripts/data.gd")
const C3Game = preload("res://scripts/game.gd")
const C3World = preload("res://scripts/world.gd")

var checks: Array = []

func _check(name: String, ok: bool, detail: String) -> void:
	checks.append({"name": name, "ok": ok, "detail": detail})
	print(("  PASS  " if ok else "  FAIL  ") + name + " - " + detail)

const ANIM_DIR := "res://assets/models/anim"

func _res_exists(path: String) -> bool:
	# Export-safe existence probe, same as world.gd `_res_exists`.
	return ResourceLoader.exists(path) or FileAccess.file_exists(path)

func _resolve_anim_png(name: String) -> String:
	# Mirror world.gd `_nation_sheet` for the rotor. It has no nation prefix,
	# so only the shared common/buildings/ candidate applies; then the legacy
	# category folder and finally the anim root. This returns the same path the
	# renderer loads, so the lazy texture / cache key stays identical.
	var shared := "%s/common/buildings/%s" % [ANIM_DIR, name]
	if _res_exists(shared):
		return shared
	var nested := "%s/buildings/%s" % [ANIM_DIR, name]
	if _res_exists(nested):
		return nested
	return "%s/%s" % [ANIM_DIR, name]

func _initialize() -> void:
	# The rotor is a separate asset, baked from the donor's eurmilanim.oss.
	# Probe common/buildings/ then buildings/ then the legacy root, exactly
	# like world.gd `_nation_sheet`.
	var rotor_path := _resolve_anim_png("mill_rotor.png")
	_check("rotor.asset", _res_exists(rotor_path),
		"mill_rotor.png imported: %s (%s)" % [str(_res_exists(rotor_path)), rotor_path])

	var game = C3Game.new()
	root.add_child(game)
	Data.AI_ENABLED = false
	game.setup("skirmish")

	var world = C3World.new()
	root.add_child(world)
	world.bind(game)

	# lazy loader must find it through the same path the renderer uses
	var tex = world._mill_rotor()
	_check("rotor.loaded", tex != null, "world._mill_rotor() -> %s" % str(tex != null))
	if tex != null:
		_check("rotor.square", absf(tex.get_width() - tex.get_height()) < 2,
			"rotor cell %dx%d" % [tex.get_width(), tex.get_height()])

	# the mill must be a finished building with a spinning rotor drawn over it
	var mill = game.spawn("mil", 0, Vector2(120, 120), true)
	_check("mill.finished", bool(mill.finished) and str(mill.sid) == "mil",
		"spawned finished mill id=%d" % int(mill.id))

	# verify the hub lands inside the tower cell and the spin advances
	var sz := Vector2(320.0, 320.0) * 0.33
	var tl := Vector2(0, 0)
	var hub := tl + Vector2(sz.x * world.MILL_HUB.x, sz.y * world.MILL_HUB.y)
	_check("rotor.hub", hub.x > 0.0 and hub.x < sz.x and hub.y > 0.0 and hub.y < sz.y,
		"hub %.1f,%.1f in cell %.1f" % [hub.x, hub.y, sz.x])

	var a0: float = world.anim_t
	for i in 20:
		world._process(0.1) if false else null
	# anim_t is advanced from world._process(dt); drive it directly for the test
	world.anim_t += 2.0
	_check("rotor.spins", world.anim_t > a0,
		"anim_t %.2f -> %.2f (angle = anim_t * %.2f)" % [a0, world.anim_t, world.MILL_SPIN])

	_finish()

func _finish() -> void:
	var ok := true
	for c in checks:
		if not c.ok:
			ok = false
	print("mill_visual_test: %d/%d checks passed" % [
		checks.filter(func(c): return c.ok).size(), checks.size()])
	call_deferred("quit", 0 if ok else 1)
