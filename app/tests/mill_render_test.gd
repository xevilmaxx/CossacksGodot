# Render a finished windmill (with its spinning rotor) to a PNG for visual
# inspection.  Windowed so the real GPU canvas path is used:
#   godot --path app --script res://tests/mill_render_test.gd
extends SceneTree

const Data = preload("res://scripts/data.gd")
const C3Game = preload("res://scripts/game.gd")
const C3World = preload("res://scripts/world.gd")
const OUT_DIR := "res://tests/results"

var _id := "t_mill_rotor"
var checks: Array = []

func check(name: String, passed: bool, detail: String = "") -> void:
	checks.append({"name": name, "passed": passed, "detail": detail})
	print(("  PASS  " if passed else "  FAIL  ") + name + " - " + detail)

func _write_result(passed: bool) -> void:
	var abs_dir := ProjectSettings.globalize_path(OUT_DIR)
	DirAccess.make_dir_recursive_absolute(abs_dir)
	var path := "%s/%s.json" % [abs_dir, _id]
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_error("cannot write test result: " + path)
		return
	f.store_string(JSON.stringify({
		"id": _id,
		"passed": passed,
		"checks": checks,
		"unix_ms": Time.get_unix_time_from_system() * 1000.0,
	}, "\t"))
	f.close()

func _initialize() -> void:
	# Headless has no real GPU canvas: process_frame / frame_post_draw do not
	# resolve reliably there, so the coroutine never reaches the exit calls. Skip
	# before building the world. The windowed render path below is unchanged;
	# both paths write their result JSON before the deferred quit.
	if DisplayServer.get_name() == "headless":
		print("mill_render_test: headless, skipping PNG render (ok)")
		check("headless_skip", true, "no GPU canvas in headless mode; PNG render skipped")
		_write_result(true)
		call_deferred("quit", 0)
		return
	var game = C3Game.new()
	root.add_child(game)
	Data.AI_ENABLED = false
	game.setup("skirmish")
	var world = C3World.new()
	root.add_child(world)
	world.bind(game)

	var mill = game.spawn("mil", 0, Vector2(160, 160), true)
	var peer = game.spawn("peasant", 0, Vector2(166, 164))
	var mp = world.world_to_px(mill.pos)
	world.position = Vector2(640, 360) - mp
	world.view_rect = Rect2(mp.x - 150, mp.y - 150, 300, 300)
	world.anim_t = 1.2
	world.queue_redraw()
	await process_frame
	await RenderingServer.frame_post_draw
	var tex = root.get_texture()
	if tex == null:
		print("no viewport texture")
		check("viewport_texture", false, "root.get_texture() returned null")
		_write_result(false)
		call_deferred("quit", 1)
		return
	check("viewport_texture", true, "root viewport texture acquired")
	var img = tex.get_image()
	var out = "res://shots/mill_rotor_check.png"
	var err = img.save_png(ProjectSettings.globalize_path(out))
	check("png_saved", err == OK, "%s %s (save error=%d)" % [out, str(img.get_size()), err])
	print("saved ", out, " ", img.get_size())
	_write_result(err == OK)
	call_deferred("quit", 0)
