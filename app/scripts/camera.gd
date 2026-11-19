# Camera: edge scroll + arrow keys + mouse wheel zoom, clamped like the original.
extends Camera2D
class_name C3Camera

const Data = preload("res://scripts/data.gd")

var world: C3World
var edge_margin := 8.0          # cameracontrol.inc cMargin
var corner_margin := 24.0       # cCornerMargin
var key_speed := 24.0 * 4.0     # profile keyscrollspeed*4 (default ~24) — estimated default
var mouse_speed := 16.0 * 4.0   # profile mousescrollspeed*4 — estimated default
var min_zoom := 1.0             # camera height 58
var max_zoom := 2.9             # camera height 20 (58/20)
var zoom_step := 1.15

func bind(w: C3World) -> void:
	world = w
	# the settings file decides how the camera behaves
	edge_margin = Data.CAMERA_EDGE_MARGIN
	corner_margin = Data.CAMERA_CORNER_MARGIN
	key_speed = Data.CAMERA_KEY_SPEED
	mouse_speed = Data.CAMERA_MOUSE_SPEED
	zoom_step = Data.CAMERA_ZOOM_STEP
	# the original keeps the camera between two heights (camera.cfg
	# SphereHeightMin 20 and SphereHeight 58)
	var h_min: float = maxf(1.0, Data.CAMERA_MIN_HEIGHT)
	var h_max: float = maxf(h_min, Data.CAMERA_MAX_HEIGHT)
	min_zoom = h_min / h_max
	max_zoom = h_max / h_min
	make_current()
	position = Vector2(0, 0)

func clamp_pos() -> void:
	var half := get_viewport_rect().size / zoom / 2.0
	var limit := Vector2(world.game.MAP_W, world.game.MAP_H) * Data.TILE_M * world.view_scale
	position.x = clampf(position.x, half.x, limit.x - half.x)
	position.y = clampf(position.y, half.y, limit.y - half.y)

func _process(dt: float) -> void:
	var vp := get_viewport().get_visible_rect().size
	var m := get_viewport().get_mouse_position()
	var dir := Vector2.ZERO
	var at_left := m.x < edge_margin or (m.x < corner_margin and m.y < corner_margin)
	var at_right := m.x > vp.x - edge_margin or (m.x > vp.x - corner_margin and m.y < corner_margin)
	var at_top := m.y < edge_margin
	var at_bot := m.y > vp.y - edge_margin
	if at_left:
		dir.x -= 1
	if at_right:
		dir.x += 1
	if at_top:
		dir.y -= 1
	if at_bot:
		dir.y += 1
	if Input.is_key_pressed(KEY_LEFT):
		dir.x -= 1
	if Input.is_key_pressed(KEY_RIGHT):
		dir.x += 1
	if Input.is_key_pressed(KEY_UP):
		dir.y -= 1
	if Input.is_key_pressed(KEY_DOWN):
		dir.y += 1
	if dir != Vector2.ZERO:
		position += dir.normalized() * (key_speed if Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_RIGHT) \
			or Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_DOWN) else mouse_speed) * dt / zoom
		clamp_pos()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
		zoom = Vector2.ONE * clampf(zoom.x * zoom_step, min_zoom, max_zoom)
		clamp_pos()
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		zoom = Vector2.ONE * clampf(zoom.x / zoom_step, min_zoom, max_zoom)
		clamp_pos()
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion:
		clamp_pos()
