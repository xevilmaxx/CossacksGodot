# camera3d.gd — perspective RTS camera for the SINGLEPLAYER SKIRMISH 3D variant.
# Owned by V7-11 (atomic builder). ONE new file; no other file is edited.
# Loaded dynamically via load("res://scripts/camera3d.gd") — no class_name
# (a new global class is not in .godot's cache until an editor import).
#
# API (V73_ATOMIC_CONTRACT.md:10):
#   bind(game, view_scale:=1.0), view_scale,
#   world_to_px(world:Vector2)->Vector2, screen_to_world(screen:Vector2)->Vector2,
#   clamp_pos(), get_view_rect()->Rect2, get_viewport_corners()->Array,
#   zoom_step(notches, anchor), set_zoom_target(target, immediate:=false)
#
# DONOR SOURCE OF TRUTH (private-use, read-only; Python bytes + latin-1; never run):
#   C:\Games\Cossacks 3\data\cameras\camera.cfg:6-7   SphereHeight = 58 / SphereHeightMin = 20
#   C:\Games\Cossacks 3\data\cameras\camera.cfg:9-10   SphereLength = 58 / SphereLengthMin = 20
#   C:\Games\Cossacks 3\data\cameras\camera.cfg:32-35  MinHeightMinAngle/MinHeightMaxAngle/
#                                                      MaxHeightMinAngle/MaxHeightMaxAngle = -32
#   C:\Games\Cossacks 3\data\cameras\camera.cfg:44-45  MinFocalLength = MaxFocalLength = 400
#   C:\Games\Cossacks 3\data\cameras\default.cameras:5-18 DirZ=-1, UpY=1 (world-space camera)
#   C:\Games\Cossacks 3\data\gui\common.inc\onmousewheel.inc:30-41  GetCameraRestrictInfo(sh,
#       shm, maxHeight, minHeight); wheel height := Clamp(height+delta, minHeight, maxHeight)
#   C:\Games\Cossacks 3\data\gui\common.inc\onmousewheel.inc:43-47  tilt Lerp(-32,-32) -> -32
#   C:\Games\Cossacks 3\data\gui\common.inc\onmousewheel.inc:296-303  wheel zoom = height delta,
#       then MoveToTargetXZ (zoom is at the wheel's ground point)
#   C:\Games\Cossacks 3\data\gui\menu.inc\oncamera.inc:10-11  keySpeed/mouseSpeed = profile*
#       keyscrollspeed/mousescrollspeed * 4
#   C:\Games\Cossacks 3\data\gui\menu.inc\oncamera.inc:18-27,60-72  arrow keys -> camera absolute
#       left/right/forward/backward directions; SetCameraElasticMoveDirection
#   Evidence: G31_donor_3d_truth.md:42-63, claim 1 :225; V71_mechanics_inventory.md:158-159.
# Port-side tunables are read from variant3d/scripts/data.gd (V7-3 donor-cited mirror) and the
# shipping 2D camera (variant3d/scripts/camera.gd) for byte-comparable 2D semantics.
#
# Coordination frame: ground plane is Y=0, world X/Z in metres. Ground focus (_target.x,
# _target.y) uses TOP-LEFT map origin [0..MAP_W*TILE_M] x [0..MAP_H*TILE_M], matching the 2D
# canvas/HUD minimap. Yaw = 0 (camera looks toward -Z) is a PORT ASSUMPTION: donor yaw is
# UNVERIFIED (G31_donor_3d_truth.md:227,244-245). Absolute FOV/sensor is UNVERIFIED too
# (G31:227,262-263): the 2.90 deg and 17.27 deg V-FOV figures are A/B assumptions, not donor
# literals. No RNG, no invented donor constants.
extends Camera3D

const Data = preload("res://scripts/data.gd")
const C3ConfigScript = preload("res://scripts/config.gd")

# Donor literals. Never written as bare magic numbers without a citation.
const DONOR_HEIGHT_MAX: float = 58.0  # camera.cfg:6 SphereHeight; :9 SphereLength
const DONOR_HEIGHT_MIN: float = 20.0  # camera.cfg:7 SphereHeightMin; :10 SphereLengthMin
const DONOR_FOCAL: float = 400.0      # camera.cfg:44-45 Min/MaxFocalLength
const DONOR_FOCAL_STEP: float = 5.0   # onmousewheel.inc:326,334 (CTRL screenshot zoom only)
# PORT ASSUMPTION — NOT a donor literal. M0.6 "display sensor" V-FOV used to keep vertical
# faces visible; A/B candidate 2.90 deg (36 mm sensor) still pending. G31:227,262-263;
# terrain3d_sandbox.gd:24-36; SWARM_BOARD.md:415-420.
const FOV_DEG_ASSUMED: float = 17.27
# Donor clipping planes are UNVERIFIED (G31:40-63: no projection/clip keys in data/**).
# These are port frustum-safety values, explicitly NOT donor numbers.
const NEAR_M: float = 0.1
const FAR_M: float = 4096.0

var game: Object = null
# Metres -> canvas px scalar, kept for HUD/minimap parity (Data.PIXELS_PER_METER = 16,
# variant3d/scripts/data.gd:113). Do not reinterpret this scalar for 3D callers
# (V71_mechanics_inventory.md:188, open question :262).
var view_scale: float = 1.0

# 2D zoom semantics preserved exactly in metres (variant3d/scripts/camera.gd:17-27,
# :81-86, :250-262). min_zoom/max_zoom are derived ONLY from donor height bounds:
# min = 20/58, max = 58/20 (camera.gd:82-84).
var min_zoom: float = 1.0
var max_zoom: float = 2.9
var zoom: float = 1.0                  # Camera3D has no built-in zoom property
var zoom_target: float = 1.0
var zoom_step_factor: float = 1.15     # Data.CAMERA_ZOOM_STEP (data.gd:168)
var zoom_notch_gain: float = 2.0       # camera.gd:22 (port parity)
var zoom_smooth_rate: float = 18.0     # camera.gd:25 (port parity)
var _zoom_anchor_screen: Vector2 = Vector2.INF

# Edge-scroll / depth / dwell tunables: port parity with the shipping 2D camera
# (camera.gd:11-14, :39-51) and Data.CAMERA_{EDGE,CORNER,KEY,MOUSE} (data.gd:164-167).
var edge_margin: float = 8.0
var corner_margin: float = 24.0
var edge_depth_gain: float = 3.0
var edge_depth_max: float = 4.0
var edge_dwell_gain: float = 1.0
var edge_dwell_tau: float = 0.5
var edge_dwell_max: float = 3.0
var edge_total_max: float = 6.0
var _edge_dwell_dir: Vector2 = Vector2.ZERO
var _edge_dwell_time: float = 0.0
var _middle_drag_last: Vector2 = Vector2.INF

# Ground focus in metres (top-left map origin). All camera transforms derive from it.
var _target: Vector2 = Vector2.ZERO
var _last_clamp_target: Vector2 = Vector2.INF
var _last_clamp_zoom: float = -1.0

const PROCESS_PRIORITY: int = -100  # camera.gd:36 — pan before world.sync()/HUD box


func bind(game: Object, view_scale: float = 1.0) -> void:
	self.game = game
	self.view_scale = view_scale
	projection = PROJECTION_PERSPECTIVE  # G31:225 — donor main view is perspective, not ortho
	fov = FOV_DEG_ASSUMED
	near = NEAR_M
	far = FAR_M
	process_priority = PROCESS_PRIORITY
	_middle_drag_last = Vector2.INF
	_edge_dwell_dir = Vector2.ZERO
	_edge_dwell_time = 0.0
	# Port parity settings, read null-safe like camera.gd:59-78.
	edge_margin = Data.CAMERA_EDGE_MARGIN
	corner_margin = Data.CAMERA_CORNER_MARGIN
	zoom_step_factor = Data.CAMERA_ZOOM_STEP
	var cfg = C3ConfigScript.active
	if cfg != null:
		zoom_notch_gain = cfg.num("camera.zoom_notch_gain", 2.0)
		zoom_smooth_rate = cfg.num("camera.zoom_smooth_rate", 18.0)
		edge_depth_gain = cfg.num("camera.edge_depth_gain", 3.0)
		edge_depth_max = cfg.num("camera.edge_depth_max", 4.0)
		edge_dwell_gain = cfg.num("camera.edge_dwell_gain", 1.0)
		edge_dwell_tau = cfg.num("camera.edge_dwell_tau", 0.5)
		edge_dwell_max = cfg.num("camera.edge_dwell_max", 3.0)
		edge_total_max = cfg.num("camera.edge_total_max", 6.0)
	# Donor sphere bounds -> 2D zoom interval (camera.gd:81-84).
	min_zoom = maxf(1.0, Data.CAMERA_MIN_HEIGHT) / maxf(1.0, Data.CAMERA_MAX_HEIGHT)
	max_zoom = maxf(1.0, Data.CAMERA_MAX_HEIGHT) / maxf(1.0, Data.CAMERA_MIN_HEIGHT)
	zoom_target = clampf(1.0, min_zoom, max_zoom)
	zoom = zoom_target
	_zoom_anchor_screen = Vector2.INF
	_target = Vector2.ZERO
	_last_clamp_target = Vector2.INF
	_last_clamp_zoom = -1.0
	make_current()
	_apply_transform()


# Donor wheel zoom clamps HEIGHT (camera.cfg:6-7 via onmousewheel.inc:30-41), not canvas
# scale. Map the 2D zoom scalar into those metres so the 2D zoom bounds land exactly on the
# donor bounds: zoom=20/58 -> 58 m, zoom=58/20 -> 20 m, zoom=1 -> sqrt(20*58) m.
# height = sqrt(H_MIN * H_MAX / zoom) — derived solely from camera.cfg:6-7.
func _height_m() -> float:
	var z: float = clampf(zoom, min_zoom, max_zoom)
	return sqrt(maxf(0.0001, DONOR_HEIGHT_MIN * DONOR_HEIGHT_MAX) / maxf(0.0001, z))


# Fixed -32 deg tilt (camera.cfg:32-35; onmousewheel.inc:43-47). Yaw 0 = look toward -Z
# (default.cameras:DirZ=-1); exact donor yaw UNVERIFIED (G31:227).
func _apply_transform() -> void:
	var h: float = _height_m()
	var base := Vector3(_target.x, 0.0, _target.y)
	var pitch: float = deg_to_rad(Data.CAMERA_PITCH)
	# Camera sits behind+above the ground focus: offset.y = h, offset.z = h/tan(|pitch|).
	var back: float = h * cos(pitch) / maxf(0.0001, -sin(pitch))
	global_position = base + Vector3(0.0, h, back)
	look_at(base, Vector3.UP)


# Ground world point (metres, X/Z) -> viewport screen pixels. Camera3D.unproject_position
# already returns viewport pixel coordinates (top-left origin), matching the 2D contract's
# "screen px" output meaning (V71:189, open question :262).
func world_to_px(world: Vector2) -> Vector2:
	var p: Vector2 = unproject_position(Vector3(world.x, 0.0, world.y))
	return p


# Screen pixel -> ground (Y=0) raycast. Donor API name ScreenToWorldRayCast:
# onmousewheel.inc:315 (V71:159). Returns Vector2 world X/Z in metres; INF when the ray
# misses the ground (points above the horizon). Entity/resource hit-tests stay in picking3d.
func screen_to_world(screen: Vector2) -> Vector2:
	var origin: Vector3 = project_ray_origin(screen)
	var dir: Vector3 = project_ray_normal(screen)
	if absf(dir.y) < 0.000001:
		return Vector2.INF
	var t: float = -origin.y / dir.y
	if t < 0.0:
		return Vector2.INF
	var hit: Vector3 = origin + dir * t
	return Vector2(hit.x, hit.z)


# Four GROUND corners in screen order TL, TR, BR, BL (metres, top-left map origin).
# The HUD minimap box adapter projects these into minimap pixel space (contract :16).
func get_viewport_corners() -> Array:
	var vp: Vector2 = get_viewport().get_visible_rect().size
	var out: Array = []
	out.append(screen_to_world(Vector2(0.0, 0.0)))
	out.append(screen_to_world(Vector2(vp.x, 0.0)))
	out.append(screen_to_world(vp))
	out.append(screen_to_world(Vector2(0.0, vp.y)))
	return out


# Axis-aligned bounding rect of the visible ground quad, in METRES (2D view_rect was in
# canvas px: camera.gd:130 / world.gd:2075; here it must not mix px and m — V71:191).
func get_view_rect() -> Rect2:
	var corners: Array = get_viewport_corners()
	var min_v := Vector2.INF
	var max_v := Vector2(-INF, -INF)
	var seen: int = 0
	for c in corners:
		if c is Vector2 and is_finite(c.x) and is_finite(c.y):
			min_v = min_v.min(c)
			max_v = max_v.max(c)
			seen += 1
	if seen == 0:
		return Rect2()
	return Rect2(min_v, max_v - min_v)


# Keep the whole visible ground quad inside the map. Mirrors 2D clamp_pos (camera.gd:123-137):
# clamp the view centre to [half_extent, map_limit - half_extent], and CENTRE the axis when
# the view is wider than the map (the 2D inverted-clampf guard).
func clamp_pos() -> void:
	if game == null:
		return
	if _target == _last_clamp_target and zoom == _last_clamp_zoom:
		return
	var corners: Array = get_viewport_corners()
	var min_v := Vector2.INF
	var max_v := Vector2(-INF, -INF)
	var seen: int = 0
	for c in corners:
		if c is Vector2 and is_finite(c.x) and is_finite(c.y):
			min_v = min_v.min(c)
			max_v = max_v.max(c)
			seen += 1
	if seen < 4:
		return
	var centre: Vector2 = (min_v + max_v) * 0.5
	var half: Vector2 = (max_v - min_v) * 0.5
	var limit := Vector2(game.MAP_W, game.MAP_H) * Data.TILE_M
	var nx: float = limit.x * 0.5 if limit.x <= half.x * 2.0 else clampf(centre.x, half.x, limit.x - half.x)
	var nz: float = limit.y * 0.5 if limit.y <= half.y * 2.0 else clampf(centre.y, half.y, limit.y - half.y)
	var delta := Vector2(nx - centre.x, nz - centre.y)
	if delta != Vector2.ZERO:
		_target += delta
		_apply_transform()
	_last_clamp_target = _target
	_last_clamp_zoom = zoom


func _process(dt: float) -> void:
	# Hitch guard (camera.gd:144): a stall must not teleport the camera.
	dt = minf(dt, 0.05)
	_smooth_zoom(dt)  # zoom before pan/clamp, like 2D camera.gd:145
	var vp: Vector2 = get_viewport().get_visible_rect().size
	var m: Vector2 = get_viewport().get_mouse_position()
	var dir := Vector2.ZERO

	# Middle-button drag: pointer delta px -> metres (camera.gd:152-160 parity).
	var middling: bool = Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE)
	if middling:
		if _middle_drag_last != Vector2.INF:
			var md: Vector2 = m - _middle_drag_last
			if md != Vector2.ZERO:
				_target -= md / (zoom * maxf(0.0001, view_scale))
		_middle_drag_last = m
	else:
		_middle_drag_last = Vector2.INF

	# Edge scroll (oncamera.inc:15-27,60-72) + 2D depth/dwell acceleration.
	var mouse_mult: float = 1.0
	if not middling:
		var at_left: bool = m.x < edge_margin or (m.x < corner_margin and m.y < corner_margin)
		var at_right: bool = m.x > vp.x - edge_margin or (m.x > vp.x - corner_margin and m.y < corner_margin)
		var at_top: bool = m.y < edge_margin
		var at_bot: bool = m.y > vp.y - edge_margin
		var edge_dir := Vector2.ZERO
		if at_left:
			dir.x -= 1.0
			edge_dir.x -= 1.0
		if at_right:
			dir.x += 1.0
			edge_dir.x += 1.0
		if at_top:
			dir.y -= 1.0
			edge_dir.y -= 1.0
		if at_bot:
			dir.y += 1.0
			edge_dir.y += 1.0
		var em: float = maxf(edge_margin, 0.001)
		var cm: float = maxf(corner_margin, em)
		var depth: float = 0.0
		if at_left:
			var l_extent: float = cm if m.y < corner_margin else em
			depth = maxf(depth, clampf((l_extent - m.x) / l_extent, 0.0, 1.0))
		if at_right:
			var r_extent: float = cm if m.y < corner_margin else em
			depth = maxf(depth, clampf((m.x - (vp.x - r_extent)) / r_extent, 0.0, 1.0))
		if at_top:
			depth = maxf(depth, clampf((em - m.y) / em, 0.0, 1.0))
		if at_bot:
			depth = maxf(depth, clampf((m.y - (vp.y - em)) / em, 0.0, 1.0))
		var depth_mult: float = clampf(1.0 + edge_depth_gain * depth * depth, 1.0, edge_depth_max)
		if edge_dir == Vector2.ZERO:
			_edge_dwell_dir = Vector2.ZERO
			_edge_dwell_time = 0.0
		else:
			if edge_dir != _edge_dwell_dir:
				_edge_dwell_dir = edge_dir
				_edge_dwell_time = 0.0
			_edge_dwell_time += dt
		var dwell_mult: float = 1.0
		if _edge_dwell_time > 0.0:
			dwell_mult = clampf(1.0 + edge_dwell_gain * log(1.0 + _edge_dwell_time / maxf(edge_dwell_tau, 0.001)), 1.0, edge_dwell_max)
		mouse_mult = clampf(depth_mult * dwell_mult, 1.0, edge_total_max)
	else:
		_edge_dwell_dir = Vector2.ZERO
		_edge_dwell_time = 0.0

	# Arrow keys only (A/S/D/W are donor order hotkeys — camera.gd:221-229).
	var k_left: bool = Input.is_key_pressed(KEY_LEFT)
	var k_right: bool = Input.is_key_pressed(KEY_RIGHT)
	var k_up: bool = Input.is_key_pressed(KEY_UP)
	var k_down: bool = Input.is_key_pressed(KEY_DOWN)
	if k_left:
		dir.x -= 1.0
	if k_right:
		dir.x += 1.0
	if k_up:
		dir.y -= 1.0
	if k_down:
		dir.y += 1.0
	if dir != Vector2.ZERO:
		# Port profile speeds -> m/s: Data px/s / PIXELS_PER_METER (data.gd:113,166-167).
		var key_m: float = Data.CAMERA_KEY_SPEED / maxf(1.0, Data.PIXELS_PER_METER)
		var mouse_m: float = Data.CAMERA_MOUSE_SPEED / maxf(1.0, Data.PIXELS_PER_METER)
		var speed: float = key_m if (k_left or k_right or k_up or k_down) else mouse_m * mouse_mult
		_target += dir.normalized() * speed * dt / zoom
		_apply_transform()
	clamp_pos()


# W4-1 public zoom API (camera.gd:246-262). notches > 0 = zoom in. anchor is the screen
# point that stays over the same world point (wheel event position); same semantics as 2D.
func zoom_step(notches: float, anchor: Vector2 = Vector2.INF) -> void:
	if notches == 0.0:
		return
	set_zoom_target(zoom_target * pow(zoom_step_factor, notches * zoom_notch_gain), false, anchor)


# Absolute clamped zoom target. The first two parameters are the exact contract API; the
# OPTIONAL third argument is additive (2-arg calls are unchanged) and carries the zoom-at-
# cursor anchor set by zoom_step. immediate=true snaps (startup/reset), like camera.gd:257-262.
func set_zoom_target(target: float, immediate: bool = false, anchor: Vector2 = Vector2.INF) -> void:
	zoom_target = clampf(target, min_zoom, max_zoom)
	_zoom_anchor_screen = anchor
	if immediate:
		zoom = zoom_target
		_zoom_anchor_screen = Vector2.INF
		_apply_transform()


# Frame-rate-independent exponential approach (camera.gd:267-284) expressed in metres:
# hold the world point under the zoom anchor fixed across the perspective dolly.
func _smooth_zoom(dt: float) -> void:
	if absf(zoom_target - zoom) < 0.0005:
		if zoom != zoom_target:
			zoom = zoom_target
			_apply_transform()
		_zoom_anchor_screen = Vector2.INF
		return
	var anchored: bool = is_finite(_zoom_anchor_screen.x) and is_finite(_zoom_anchor_screen.y)
	var anchor_world: Vector2 = screen_to_world(_zoom_anchor_screen) if anchored else Vector2.INF
	var old_z: float = zoom
	var t: float = 1.0 - exp(-zoom_smooth_rate * dt)
	var new_z: float = old_z + (zoom_target - old_z) * t
	if absf(zoom_target - new_z) < 0.0005:
		new_z = zoom_target
	zoom = new_z
	_apply_transform()
	if anchored and is_finite(anchor_world.x) and is_finite(anchor_world.y):
		var after: Vector2 = screen_to_world(_zoom_anchor_screen)
		if is_finite(after.x) and is_finite(after.y):
			_target += anchor_world - after
			_apply_transform()
	if new_z == zoom_target:
		_zoom_anchor_screen = Vector2.INF
