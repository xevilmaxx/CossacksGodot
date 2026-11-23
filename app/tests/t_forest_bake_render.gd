# T-FOREST-BAKE render-path check (windowed, real GPU canvas).
#
# The headless t_forest_bake.gd exercises the cache/LRU logic with placeholder
# textures. This companion test verifies the REAL SubViewport bake: it bakes
# chunks around a forest, reads back each cached ImageTexture and asserts it
# contains non-transparent prop pixels. Also saves a PNG for visual inspection.
#
# Run with:
#   python app\tools\godot_runner.py run --id t-forest-bake-render --timeout 90 -- \
#       -- --path app --script res://tests/t_forest_bake_render.gd
extends SceneTree

const Data = preload("res://scripts/data.gd")
const OUT_DIR := "res://tests/results"

var _id := "t_forest_bake_render"
var _checks: Array[Dictionary] = []
var _ok := true

func check(name: String, cond: bool, detail: String = "") -> void:
	_checks.append({"name": name, "passed": cond, "detail": detail})
	print(("  PASS  " if cond else "  FAIL  ") + name + " - " + detail)
	if not cond:
		_ok = false

func _write_result() -> void:
	var abs_dir := ProjectSettings.globalize_path(OUT_DIR)
	DirAccess.make_dir_recursive_absolute(abs_dir)
	var f := FileAccess.open("%s/%s.json" % [abs_dir, _id], FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify({"id": _id, "passed": _ok,
			"checks": _checks}, "\t"))
		f.close()

func _initialize() -> void:
	if DisplayServer.get_name() == "headless":
		print("t_forest_bake_render: headless, GPU path skipped (ok)")
		check("headless_skip", true, "no GPU canvas; use t_forest_bake.gd instead")
		_write_result()
		call_deferred("quit", 0)
		return

	Data.AI_ENABLED = false
	Data.RANDOM_SEED = 7
	var game = C3Game.new()
	root.add_child(game)
	game.setup("skirmish")
	var world = C3World.new()
	root.add_child(world)
	world.bind(game)

	# Aim the view at a real forest cell so the bake has something to draw.
	var fx := -1
	var fy := -1
	for y in range(game.MAP_H):
		for x in range(game.MAP_W):
			if int(game.terrain[game._t(x, y)]) == 2:
				fx = x
				fy = y
				break
		if fx >= 0:
			break
	check("forest_cell_found", fx >= 0, "first forest tile=(%d,%d)" % [fx, fy])
	var fp := world.world_to_px(Vector2(float(fx) * Data.TILE_M, float(fy) * Data.TILE_M))
	world.position = Vector2(640, 360) - fp
	world.view_rect = Rect2(fp.x - 256, fp.y - 256, 512, 512)

	# Let sync's forest hook bake each visible chunk (one per frame, awaited).
	for _i in 14:
		world._sync_forest_chunks()
		await RenderingServer.frame_post_draw

	check("real_chunks_baked", world.forest_chunks.size() > 0,
		"baked chunks=%d (busy=%s)" % [world.forest_chunks.size(), str(world._forest_bake_busy)])

	# Non-transparent pixels in any cached image prove the viewport draw ran.
	var opaque := 0
	var sampled := 0
	for sp in world.forest_chunks.values():
		var it: ImageTexture = sp.texture as ImageTexture
		if it == null:
			continue
		var img: Image = it.get_image()
		if img == null:
			continue
		for yy in range(0, img.get_height(), 8):
			for xx in range(0, img.get_width(), 8):
				sampled += 1
				if img.get_pixel(xx, yy).a > 0.06:
					opaque += 1
	check("baked_detail_pixels", opaque > 0,
		"opaque samples=%d / %d from %d chunk textures" % [
			opaque, sampled, world.forest_chunks.size()])

	var shot: Image = root.get_texture().get_image()
	if shot != null:
		shot.save_png(ProjectSettings.globalize_path(OUT_DIR) + "/t_forest_bake_render.png")

	_write_result()
	call_deferred("quit", 0 if _ok else 1)
