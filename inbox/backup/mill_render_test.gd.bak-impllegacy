# Render a finished windmill (with its spinning rotor) to a PNG for visual
# inspection.  Windowed so the real GPU canvas path is used:
#   godot --path app --script res://tests/mill_render_test.gd
extends SceneTree

const Data = preload("res://scripts/data.gd")
const C3Game = preload("res://scripts/game.gd")
const C3World = preload("res://scripts/world.gd")

func _initialize() -> void:
	# Headless has no real GPU canvas: process_frame / frame_post_draw do not
	# resolve reliably there, so the coroutine never reaches the exit calls. Skip
	# before building the world. The windowed render path below is unchanged.
	if DisplayServer.get_name() == "headless":
		print("mill_render_test: headless, skipping PNG render (ok)")
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
		call_deferred("quit", 1)
		return
	var img = tex.get_image()
	var out = "res://shots/mill_rotor_check.png"
	img.save_png(ProjectSettings.globalize_path(out))
	print("saved ", out, " ", img.get_size())
	call_deferred("quit", 0)
