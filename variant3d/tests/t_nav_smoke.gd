# T-NAV-RESPONSIVE smoke: camera jump/dirty API + minimap rect math/cache.
# Short, headless, no sim. Run:
#   python app\tools\godot_runner.py run --id t-nav-smoke --timeout 60 -- \
#       --headless --path app --script res://tests/t_nav_smoke.gd
extends SceneTree

const Data = preload("res://scripts/data.gd")
const C3Game = preload("res://scripts/game.gd")
const C3Camera = preload("res://scripts/camera.gd")
const C3Input = preload("res://scripts/input_controller.gd")

var _ok := true

func check(name: String, cond: bool, detail: String) -> void:
	print(("  PASS  " if cond else "  FAIL  ") + name + " - " + detail)
	if not cond:
		_ok = false

func _initialize() -> void:
	# Defer one frame: Camera2D.make_current() in bind() needs the camera to
	# be fully inside the tree, which is not true yet inside _initialize().
	call_deferred("_run")

func _run() -> void:
	Data.AI_ENABLED = false
	var game = C3Game.new()
	root.add_child(game)
	game.setup("skirmish")

	var cam = C3Camera.new()
	root.add_child(cam)
	cam.bind(null)
	check("camera_early_priority", cam.process_priority == -100,
		"process_priority=%d (must run before world.sync)" % cam.process_priority)
	cam.jump_to_world(Vector2(100.0, 200.0), 2.0)
	check("camera_jump_immediate", cam.position == Vector2(200.0, 400.0),
		"position=%s" % str(cam.position))
	cam.mark_dirty()
	check("camera_mark_dirty", cam._last_clamp_pos == Vector2.INF,
		"clamp memo invalidated=%s" % str(cam._last_clamp_pos == Vector2.INF))

	var ictl = C3Input.new()
	root.add_child(ictl)
	ictl.game = game
	ictl._mm_rect = Rect2(10.0, 10.0, 200.0, 200.0)
	ictl._mm_rect_dirty = false
	var mid := ictl._minimap_world(Vector2(110.0, 110.0))
	check("minimap_center", mid == Vector2(game.MAP_W, game.MAP_H) * 0.5 * Data.TILE_M,
		"world=%s" % str(mid))
	var far := ictl._minimap_world(Vector2(900.0, 900.0))
	check("minimap_drag_clamped", far.x <= game.MAP_W * Data.TILE_M and far.y <= game.MAP_H * Data.TILE_M,
		"outside point clamped to map corner=%s" % str(far))
	check("minimap_rect_cached", not ictl._minimap_screen_rect().size == Vector2.ZERO,
		"cached rect=%s" % str(ictl._minimap_screen_rect()))

	call_deferred("quit", 0 if _ok else 1)
