# Camera: edge scroll + arrow keys + mouse wheel zoom, clamped like the original.
extends Camera2D
class_name C3Camera

const Data = preload("res://scripts/data.gd")

var world: C3World
var edge_margin := 8.0          # cameracontrol.inc cMargin
var corner_margin := 24.0       # cCornerMargin
var key_speed := 24.0 * 4.0     # profile keyscrollspeed*4 (default ~24) — estimated default
var mouse_speed := 16.0 * 4.0   # profile mousescrollspeed*4 — estimated default
# T5-RENDER: ~2x closer than the old 1.0 default. This is a camera-only change;
# Data.TILE_M and all world coordinates are untouched. 2.0 sits inside the
# donor-derived 0.34-2.9 clamp range below, so wheel zoom still works both ways.
const DEFAULT_ZOOM := 2.0
var min_zoom := 1.0             # camera height 58
var max_zoom := 2.9             # camera height 20 (58/20)
var zoom_step := 1.15
# T-PERF-RENDER: clamp_pos memo — edge scroll calls it every frame and the
# minimap calls it on each jump; skip the viewport math when nothing moved.
var _last_clamp_pos := Vector2.INF
var _last_clamp_zoom := Vector2.INF
# T-NAV-RESPONSIVE: the camera must step BEFORE main.gd's world.sync() and the
# HUD's minimap-box redraw. Otherwise every pan (edge, key, drag or minimap
# jump) is captured one frame late, because sync() reads the canvas transform
# first. Lower process_priority runs earlier in the _process pass.
const PROCESS_PRIORITY := -100
# Middle-button drag: previous pointer position in screen space; INF = idle.
var _middle_drag_last := Vector2.INF

func bind(w: C3World) -> void:
	world = w
	process_priority = PROCESS_PRIORITY
	_middle_drag_last = Vector2.INF
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
	zoom = Vector2.ONE * clampf(DEFAULT_ZOOM, min_zoom, max_zoom)
	make_current()
	position = Vector2(0, 0)

# T-NAV-RESPONSIVE: instant reposition (minimap click/drag). Writes position
# now, re-clamps with a fresh memo and nudges the world redraw — no waiting
# for a sim tick or MINIMAP_INTERVAL. hud.gd writes global_position directly
# today; callers can switch to this helper to get the same one-frame path.
func jump_to_world(world_pos: Vector2, view_scale: float = 1.0) -> void:
	if world != null:
		view_scale = world.view_scale
	var target := world_pos * view_scale
	if position != target:
		position = target
		mark_dirty()
	clamp_pos()

# T-NAV-RESPONSIVE: call after ANY external write to position/zoom (hud.gd's
# minimap handler, a scripted focus, etc.). Invalidates the clamp memo so the
# next clamp_pos() re-evaluates, and pokes the world's redraw hook if that
# lane ever adds one.
func mark_dirty() -> void:
	_last_clamp_pos = Vector2.INF
	_last_clamp_zoom = Vector2.INF
	if world == null:
		return
	# world.gd has no camera-dirty hook today: sync() derives its "moved" flag
	# from the canvas transform every frame. Forward-compatible nudge only;
	# with process_priority set above, the next sync() still sees this move
	# on the same frame even when no hook exists.
	if world.has_method("mark_camera_dirty"):
		world.mark_camera_dirty()

func clamp_pos() -> void:
	if world == null:
		return
	# T-PERF-RENDER: idempotent clamp — mouse-motion events and idle frames
	# re-enter here constantly; bail out when position and zoom are settled.
	if position == _last_clamp_pos and zoom == _last_clamp_zoom:
		return
	var half := get_viewport_rect().size / zoom / 2.0
	var limit := Vector2(world.game.MAP_W, world.game.MAP_H) * Data.TILE_M * world.view_scale
	# If the view is wider/taller than the map, clampf()'s min exceeds its max
	# and pins the camera past the map edge; centre that axis instead.
	position.x = limit.x * 0.5 if limit.x <= half.x * 2.0 else clampf(position.x, half.x, limit.x - half.x)
	position.y = limit.y * 0.5 if limit.y <= half.y * 2.0 else clampf(position.y, half.y, limit.y - half.y)
	_last_clamp_pos = position
	_last_clamp_zoom = zoom

func _process(dt: float) -> void:
	# T-PERF-RENDER: hitch guard — a 250 ms stall (load, GC, alt-tab) must not
	# teleport the camera across the map; 50 ms keeps 60 fps panning smooth.
	# The clamped dt is used UNSCALED: no extra speed factor sits between input
	# and camera movement, so edge/key pan matches the profile speeds exactly.
	dt = minf(dt, 0.05)
	var vp := get_viewport().get_visible_rect().size
	var m := get_viewport().get_mouse_position()
	var dir := Vector2.ZERO
	# T-NAV-RESPONSIVE: middle-drag pans by raw pointer delta, independent of
	# edge detection. Cache the previous point so the first frame of a drag
	# cannot teleport the camera from a stale mouse position.
	var middling := Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE)
	if middling:
		if _middle_drag_last != Vector2.INF:
			var md := m - _middle_drag_last
			if md != Vector2.ZERO:
				position -= md / zoom
		_middle_drag_last = m
	else:
		_middle_drag_last = Vector2.INF
	# Edge scroll is suspended while middle-dragging so the two pan sources
	# cannot fight over the same position write.
	if not middling:
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
	# Arrow keys only: WASD is owned by the donor order/build hotkeys (A attack,
	# S stand, D hold-fire, W wall, ...) and must not double as camera pan.
	# T-NAV-RESPONSIVE: query each key once (the old code asked twice — once
	# for direction, once for the speed branch) and use one speed decision,
	# so diagonal and mixed key+edge panning stay frame-consistent.
	var k_left := Input.is_key_pressed(KEY_LEFT)
	var k_right := Input.is_key_pressed(KEY_RIGHT)
	var k_up := Input.is_key_pressed(KEY_UP)
	var k_down := Input.is_key_pressed(KEY_DOWN)
	if k_left:
		dir.x -= 1
	if k_right:
		dir.x += 1
	if k_up:
		dir.y -= 1
	if k_down:
		dir.y += 1
	if dir != Vector2.ZERO:
		var speed := key_speed if (k_left or k_right or k_up or k_down) else mouse_speed
		position += dir.normalized() * speed * dt / zoom
	# One memoized clamp per frame, after every writer above. Mouse-motion no
	# longer clamps per event: this runs before main.gd's world.sync(), so the
	# new position is drawn on THIS frame instead of the next one.
	clamp_pos()

func _zoom_at_cursor(factor: float) -> void:
	# zoom keeps the world point under the mouse fixed (donor-style: zoom
	# happens where you point, not at the screen centre). Camera2D position
	# is the view centre (see clamp_pos), so re-anchor it around the cursor.
	var vp_size := get_viewport().get_visible_rect().size
	var m := get_viewport().get_mouse_position()
	var off: Vector2 = (m - vp_size * 0.5) / zoom.x
	var w: Vector2 = position + off
	zoom = Vector2.ONE * clampf(zoom.x * factor, min_zoom, max_zoom)
	position = w - (m - vp_size * 0.5) / zoom.x
	clamp_pos()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
		_zoom_at_cursor(zoom_step)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		_zoom_at_cursor(1.0 / zoom_step)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion:
		# T-NAV-RESPONSIVE: no per-event viewport math here. The single
		# memoized clamp in _process() (now ordered before world.sync()) covers
		# every camera writer, including hud.gd's minimap jump.
		pass
