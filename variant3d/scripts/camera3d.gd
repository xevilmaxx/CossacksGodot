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
# CAM-SEAM v2 (explicit handoff — no private-field writes from main.gd):
#   apply_external_target(sim_pos:Vector2), mark_external_transform()
#   _target is ALWAYS SIM (top-left map origin); the SIM->centred subtraction lives
#   only in _apply_transform() and happens exactly once per transform, regardless
#   of zoom. This replaces the v1 signature seam (camera3d.gd:233-237 old) that
#   detected a foreign centred write via `zoom == _last_clamp_zoom`.
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
#   C:\Games\Cossacks 3\data\gui\common.inc\onmousewheel.inc:296  wheelDelta =
#       -(GetGUIEventMouseWheelDelta/60)*(wheelspeed*0.5+0.25)*2 (DEEPDEC-01 E10/E16)
#   C:\Games\Cossacks 3\data\gui\menu.inc\dombtncameracontrol.inc:23-24  middle drag
#       deltaX=(prevX-curX)/60*(0.5+middlemousescrollspeed), deltaY=.../45*... (E15)
#   C:\Games\Cossacks 3\data\scripts\lib\profile.script:17-20,513-516  four profile
#       speeds default 0.5, clamped [0,1] (E16)
#   V7-90 donor-grounded camera pass = DEEPDEC-01 §6 items 1/2/3/5/6. FOV and the
#       ArcTan minimap offset/heading remain OPEN (DEEPDEC-01 #9/#10, §7; DEEPDEC-08 §2).
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
# CAM-SEAM handoff contract version. v1 = main.gd wrote centred _target and froze
# _last_clamp_*; camera detected it by a zoom/target "signature" (double-subtract
# risk). v2 = explicit apply_external_target(sim_pos): _target stays SIM and the
# single SIM->centred subtraction is unconditional. Bump on any frame-contract
# change so integration owners can see which seam a build implements.
const CAM_HANDOFF_VERSION: int = 2

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

# DEEPDEC-01 §6 item 1 (E10 `onmousewheel.inc:39-41`, E8 `camera.cfg:9-10`): donor
# stores camera HEIGHT directly and clamps it to SphereLengthMin..SphereLength
# (20..58 m). `height`/`height_target` are that explicit metre state; `zoom`/
# `zoom_target` survive only as a derived compatibility view for legacy callers.
var height: float = sqrt(DONOR_HEIGHT_MIN * DONOR_HEIGHT_MAX)
var height_target: float = sqrt(DONOR_HEIGHT_MIN * DONOR_HEIGHT_MAX)
# DEEPDEC-01 §6 item 2 / E16 (`profile.script:17-20,513-516`): the four donor
# profile speeds all default to 0.5 and are clamped to [0,1]. Read from the
# merged config with those donor names; absent keys keep the donor default.
var wheel_speed: float = 0.5
var middle_mouse_scroll_speed: float = 0.5
var key_scroll_speed_profile: float = 0.5
var mouse_scroll_speed_profile: float = 0.5

# E6 — terrain height sampler for the zoom-at-cursor anchor ONLY. Resolved from the
# bound game/world in bind() (no other file is edited, no new public API):
#   * world3d.gd:584 height_at_world(p) / world3d_terrain.gd:406 expects CENTRED
#     x/z metres — the same space screen_to_world() returns after V7-70 seam.
#   * game.gd:1893 height_at(p) expects SIM map-origin metres, so a
#     (MAP_W/2, MAP_H/2)*TILE_M offset is applied before the call.
# Empty method = no sampler reachable; _sample_height() then returns 0.0, the old
# flat Y=0 plane. NO height is invented when the sampler is absent.
var _height_sampler_obj: Object = null
var _height_sampler_method: String = ""
var _height_sampler_sim_offset: Vector2 = Vector2.ZERO

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
# V7-81: the memo value this script last wrote itself. Still used by clamp_pos()
# as a "fresh clamp" marker; it is NO LONGER a seam detector. CAM-SEAM v2 removed
# the foreign centred write in main.gd, so _target stays SIM on every path and
# _apply_transform() never needs to guess whether it was pre-converted.
var _own_clamp_target: Vector2 = Vector2.INF

const PROCESS_PRIORITY: int = -100  # camera.gd:36 — pan before world.sync()/HUD box


func bind(game: Object, view_scale: float = 1.0) -> void:
	self.game = game
	self.view_scale = view_scale
	_resolve_height_sampler()
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
		# DEEPDEC-01 §6 item 2 / E16 — donor profile names, default 0.5, clamp [0,1].
		wheel_speed = clampf(cfg.num("camera.wheelspeed", 0.5), 0.0, 1.0)
		middle_mouse_scroll_speed = clampf(cfg.num("camera.middlemousescrollspeed", 0.5), 0.0, 1.0)
		key_scroll_speed_profile = clampf(cfg.num("camera.keyscrollspeed", 0.5), 0.0, 1.0)
		mouse_scroll_speed_profile = clampf(cfg.num("camera.mousescrollspeed", 0.5), 0.0, 1.0)
	# Donor sphere bounds -> 2D zoom interval (camera.gd:81-84).
	min_zoom = maxf(1.0, Data.CAMERA_MIN_HEIGHT) / maxf(1.0, Data.CAMERA_MAX_HEIGHT)
	max_zoom = maxf(1.0, Data.CAMERA_MAX_HEIGHT) / maxf(1.0, Data.CAMERA_MIN_HEIGHT)
	zoom_target = clampf(1.0, min_zoom, max_zoom)
	zoom = zoom_target
	# DEEPDEC-01 §6 item 1 — seed the explicit height state from the 2D start zoom.
	height_target = _zoom_to_height(zoom_target)
	height = height_target
	_zoom_anchor_screen = Vector2.INF
	# V7-81: _target is SIM metres (top-left map origin). Start at the map CENTRE,
	# not the corner ZERO — _apply_transform() subtracts _map_half() to reach the
	# origin-centred world3d mesh (world3d_terrain.gd:312-314). Null-safe: a stub
	# without MAP_W/MAP_H leaves the half at ZERO.
	_target = _map_half()
	_last_clamp_target = Vector2.INF
	_last_clamp_zoom = -1.0
	_own_clamp_target = Vector2.INF
	make_current()
	_apply_transform()


# DEEPDEC-01 §6 item 1 — the camera now carries an explicit HEIGHT state (metres).
# _height_m() returns that state; the 2D zoom scalar is only a derived compatibility
# view. The two inverses below keep legacy zoom_step/set_zoom_target callers in sync.
# Donor bounds: zoom=20/58 -> 58 m, zoom=58/20 -> 20 m, zoom=1 -> sqrt(20*58) m
# (camera.cfg:9-10; E8/E10).
func _height_m() -> float:
	return height


func _zoom_to_height(z: float) -> float:
	var zc: float = clampf(z, min_zoom, max_zoom)
	return sqrt(maxf(0.0001, DONOR_HEIGHT_MIN * DONOR_HEIGHT_MAX) / maxf(0.0001, zc))


func _height_to_zoom(h: float) -> float:
	return clampf((DONOR_HEIGHT_MIN * DONOR_HEIGHT_MAX) / maxf(0.0001, h * h), min_zoom, max_zoom)


# V7-81 — half the map extent in SIM metres. Null-safe for stubs/test doubles
# that expose no MAP_W/MAP_H: a missing dimension contributes ZERO. Used to
# convert between the SIM top-left frame of _target/jump_to_world and the
# origin-centred world3d frame of screen_to_world()/the terrain mesh.
func _map_half() -> Vector2:
	if game == null or not is_instance_valid(game):
		return Vector2.ZERO
	var mw = game.get("MAP_W")
	var mh = game.get("MAP_H")
	if mw == null or mh == null:
		return Vector2.ZERO
	return Vector2(float(mw), float(mh)) * Data.TILE_M * 0.5


# Fixed -32 deg tilt (camera.cfg:32-35; onmousewheel.inc:43-47). Yaw 0 = look toward -Z
# (default.cameras:DirZ=-1); exact donor yaw UNVERIFIED (G31:227).
func _apply_transform() -> void:
	var h: float = _height_m()
	# V7-81: _target stays in SIM metres (public contract); the composed 3D
	# scene is centred on the origin, so subtract the map half here. This makes
	# a minimap jump to sim (320,320) focus world (0,0), not the terrain corner.
	# CAM-SEAM v2: _target is canonical SIM metres (top-left map origin) on EVERY
	# path — bind(), jump_to_world(), _process pan/zoom and apply_external_target()
	# all keep it in SIM. The composed 3D scene is centred on the origin, so this
	# ONE subtraction maps SIM -> centred. It is unconditional and idempotent:
	# no memo/zoom signature is consulted, so a wheel zoom at the handoff frame
	# can never turn it into a double subtraction. Re-running with the same
	# _target yields the same base, whatever zoom does between calls.
	var half := _map_half()
	var base := Vector3(_target.x - half.x, 0.0, _target.y - half.y)
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


# Bind an existing height sampler without touching its owner. Preference order:
# centred-space height_at_world (world3d.gd:584 / a bound stub world), then
# sim-space game.height_at (game.gd:1893) with the map-centre offset, then an
# optional `world` field exposing height_at_world. Empty result = no sampler.
func _resolve_height_sampler() -> void:
	_height_sampler_obj = null
	_height_sampler_method = ""
	_height_sampler_sim_offset = Vector2.ZERO
	if game == null or not is_instance_valid(game):
		return
	if game.has_method("height_at_world"):
		_height_sampler_obj = game
		_height_sampler_method = "height_at_world"  # centred x/z — no offset
		return
	if game.has_method("height_at"):
		var mw: float = float(game.get("MAP_W")) if game.get("MAP_W") != null else 0.0
		var mh: float = float(game.get("MAP_H")) if game.get("MAP_H") != null else 0.0
		if mw > 0.0 and mh > 0.0:
			_height_sampler_obj = game
			_height_sampler_method = "height_at"
			_height_sampler_sim_offset = Vector2(mw, mh) * 0.5 * Data.TILE_M
			return
	var w = game.get("world")
	if w is Object and is_instance_valid(w) and w.has_method("height_at_world"):
		_height_sampler_obj = w
		_height_sampler_method = "height_at_world"


# Terrain height in metres at an x/z point in screen_to_world()'s CENTRED metre
# space. No sampler reachable -> 0.0, the same flat Y=0 plane as before E6; no
# height is fabricated. The sampler is called dynamically so no typed coupling to
# game.gd / world3d.gd is introduced here.
func _sample_height(p: Vector2) -> float:
	if _height_sampler_obj == null or _height_sampler_method == "":
		return 0.0
	if not is_instance_valid(_height_sampler_obj):
		return 0.0
	if not is_finite(p.x) or not is_finite(p.y):
		return 0.0
	return float(_height_sampler_obj.call(_height_sampler_method, p + _height_sampler_sim_offset))


# Ray -> horizontal plane at fixed height_m. x/z in the same space as
# screen_to_world(); INF if parallel or behind the camera.
func _screen_to_plane(screen: Vector2, height_m: float) -> Vector2:
	var origin: Vector3 = project_ray_origin(screen)
	var dir: Vector3 = project_ray_normal(screen)
	if absf(dir.y) < 0.000001:
		return Vector2.INF
	var t: float = (height_m - origin.y) / dir.y
	if t < 0.0:
		return Vector2.INF
	var hit: Vector3 = origin + dir * t
	return Vector2(hit.x, hit.z)


# E6: terrain SURFACE point under a screen pixel (not the flat Y=0 point). Start
# at the flat hit, sample its height, re-cast at that height, repeat until the
# horizontal hit moves < 0.1 mm (max 12 passes) so the returned point really lies
# on the sampled height field. With no sampler every pass reads 0.0, so the result
# is exactly the old screen_to_world() point (default unchanged).
func _screen_to_surface(screen: Vector2) -> Vector2:
	var p: Vector2 = screen_to_world(screen)
	for _i in range(12):
		if not is_finite(p.x) or not is_finite(p.y):
			return Vector2.INF
		var q: Vector2 = _screen_to_plane(screen, _sample_height(p))
		if not is_finite(q.x) or not is_finite(q.y):
			return p
		var moved: float = q.distance_squared_to(p)
		p = q
		if moved < 1.0e-8:
			break
	return p


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


# T-NAV-RESPONSIVE — minimap click/drag jump. 2D parity: app/scripts/camera.gd:96-104
# (jump_to_world) and donor onmousedown.inc:116-131 (SetMainCameraMoveToTargetXZ).
# `world_pos` is sim metres in the top-left map origin — the SAME space as `_target` — so
# NO view_scale factor is applied here (3D view_scale = 16 px/m, world3d.gd:79).
# Writes the smoothed target AND the current Camera3D transform together: a target-only
# write is overwritten by the next _apply_transform(), a transform-only write is snapped
# back by clamp_pos() through the memo at :232-233 (the old 3D P0 failure).
#
# OPEN — DONOR MINIMAP OFFSET/HEADING NOT IMPLEMENTED (DEEPDEC-01 §6 item 10 /
# DEEPDEC-08 §2, E14/E26). Donor additionally keeps the camera's pre-click offset:
#   angleZ := -Lerp(minHeightMaxAngle, maxHeightMaxAngle,
#                   Clamp((height-minHeight)/(maxHeight-minHeight),0,1));  // = +32
#   dx := cx-tx; dz := 0.1; VectorRotateX(dx,dy,dz,angleZ);
#   offZ := ArcTan(angleZ)*height; angleX := VectorAngle(0,0,1,dx,0,dz);
#   if dx < 0 then angleX := -angleX; VectorRotateY(offX,tmp,offZ,angleX);
#   newX := dstX+offX+dx; newZ := dstZ+offZ+dz;
# (control.script:595-612; onmousewheel.inc:56-67). ArcTan() units (deg vs rad) and
# its VM body are UNVERIFIED (DEEPDEC-01 #10, §7): no donor text defines it, and
# `_control_GetMoveCameraToPositionOffset` is absent from the binary. Therefore NO
# offset/heading is applied — V7-66's contract stays "centre the clicked sim point".
func jump_to_world(world_pos: Vector2) -> void:
	_zoom_anchor_screen = Vector2.INF  # a jump cancels any in-flight zoom anchor (camera.gd:97)
	_target = world_pos
	_apply_transform()
	# Fresh memo, like 2D mark_dirty() (camera.gd:110-121): otherwise the stale memo
	# makes the following clamp_pos() a no-op and the jump stays unclamped.
	# CAM-SEAM v2: same explicit invalidation the external handoff uses.
	mark_external_transform()
	clamp_pos()


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
	# V7-81: get_viewport_corners()/screen_to_world() return CENTRED world metres,
	# while _target and the clamp limit are SIM metres. Convert the observed view
	# centre back to SIM before clamping; the delta then applies to SIM _target.
	var centre_sim: Vector2 = centre + _map_half()
	var limit := Vector2(game.MAP_W, game.MAP_H) * Data.TILE_M
	var nx: float = limit.x * 0.5 if limit.x <= half.x * 2.0 else clampf(centre_sim.x, half.x, limit.x - half.x)
	var nz: float = limit.y * 0.5 if limit.y <= half.y * 2.0 else clampf(centre_sim.y, half.y, limit.y - half.y)
	var delta := Vector2(nx - centre_sim.x, nz - centre_sim.y)
	if delta != Vector2.ZERO:
		_target += delta
		_apply_transform()
	_last_clamp_target = _target
	_last_clamp_zoom = zoom
	_own_clamp_target = _target


# CAM-SEAM v2 — explicit, versioned handoff contract (see CAM_HANDOFF_VERSION).
# Invalidate the clamp memos after ANY external focus write so the next
# clamp_pos() re-evaluates it instead of early-returning on a stale signature.
# Public so no caller has to write private fields. Zoom-independent by
# construction: no zoom value is recorded or compared here.
func mark_external_transform() -> void:
	_last_clamp_target = Vector2.INF
	_last_clamp_zoom = -1.0
	_own_clamp_target = Vector2.INF


# CAM-SEAM v2 — the single public entry point for external (main.gd) focus writes.
# `sim_pos` is SIM metres (top-left map origin), the SAME space as _target,
# jump_to_world() and the HUD minimap; no view_scale factor and no Vector3 here.
# IDEMPOTENT by construction: the focus is stored ONCE in SIM, clamp_pos() runs in
# SIM, and the SIM->centred subtraction in _apply_transform() happens exactly once.
# Calling this twice with the same sim_pos — with or without a wheel zoom in
# between — yields the same camera transform. There is no centred-target state
# that a later _apply_transform() could subtract a second time.
func apply_external_target(sim_pos: Vector2) -> void:
	_target = sim_pos
	_zoom_anchor_screen = Vector2.INF  # a focus handoff cancels any zoom anchor
	mark_external_transform()
	# PLAY2-01 RC2: the transform MUST come first. clamp_pos() derives its
	# clamp centre from get_viewport_corners() of the CURRENT camera transform;
	# clamping before the new transform measured the OLD view and then froze
	# _last_clamp_* for the unclamped focus, so the next _process early-returned
	# and the new focus was never clamped (off-terrain / black edges at startup).
	# Same order as jump_to_world(): transform :406, clamp :411.
	_apply_transform()  # unconditional, single SIM->centred subtraction
	clamp_pos()         # now measures the NEW view's corners, clamps in SIM space


func _process(dt: float) -> void:
	# Hitch guard (camera.gd:144): a stall must not teleport the camera.
	dt = minf(dt, 0.05)
	_smooth_zoom(dt)  # zoom before pan/clamp, like 2D camera.gd:145
	var vp: Vector2 = get_viewport().get_visible_rect().size
	var m: Vector2 = get_viewport().get_mouse_position()
	var dir := Vector2.ZERO

	# Middle-button drag. DEEPDEC-01 §6 item 6 / E15 (dombtncameracontrol.inc:23-24):
	# deltaX=(prevX-curX)/60*(0.5+middlemousescrollspeed),
	# deltaY=(prevY-curY)/45*(0.5+middlemousescrollspeed). Additive, zoom-INDEPENDENT,
	# no px/m factor; default profile 0.5 -> factor 1.0. clamp_pos() supplies the clamp.
	var middling: bool = Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE)
	if middling:
		if _middle_drag_last != Vector2.INF:
			var md: Vector2 = m - _middle_drag_last
			if md != Vector2.ZERO:
				var drag_factor: float = 0.5 + clampf(middle_mouse_scroll_speed, 0.0, 1.0)
				_target -= Vector2(md.x / 60.0, md.y / 45.0) * drag_factor
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
		# DEEPDEC-01 §6 item 5 / E11 (oncamera.inc:10-11): keySpeed=keyscrollspeed*4,
		# mouseSpeed=mousescrollspeed*4 (defaults 0.5 -> 2.0), ADDITIVE and
		# zoom-INDEPENDENT. The old `/ zoom` made pan slow down when zoomed out;
		# donor has no zoom factor, so it is removed. Edge depth/dwell (port
		# extension) still scales the mouse component only.
		var key_m: float = clampf(key_scroll_speed_profile, 0.0, 1.0) * 4.0
		var mouse_m: float = clampf(mouse_scroll_speed_profile, 0.0, 1.0) * 4.0
		var speed: float = key_m if (k_left or k_right or k_up or k_down) else mouse_m * mouse_mult
		_target += dir.normalized() * speed * dt
		_apply_transform()
	clamp_pos()


# DEEPDEC-01 §6 item 2 / E10 (`onmousewheel.inc:296`): donor wheel is an ADDITIVE
# height delta, not a multiplicative zoom:
#   wheelDelta = -(GetGUIEventMouseWheelDelta/60)*(wheelspeed*0.5+0.25)*2
# with default wheelspeed=0.5 -> -(Δ/60)*1 -> 2 m per standard Δ=120 notch.
# input_controller.gd:443 maps one standard notch to `notches = ±1`, so the port
# substitutes Δ = notches*120. Sign convention kept (notches>0 = zoom in = height
# down), so legacy callers still see zoom_target increase on positive notches.
# Clamp is the donor SphereLengthMin..SphereLength pair (20..58 m; E8/E10).
func zoom_step(notches: float, anchor: Vector2 = Vector2.INF) -> void:
	if notches == 0.0:
		return
	var wheel_event_delta: float = notches * 120.0
	var delta_h: float = -(wheel_event_delta / 60.0) * (wheel_speed * 0.5 + 0.25) * 2.0
	height_target = clampf(height_target + delta_h, DONOR_HEIGHT_MIN, DONOR_HEIGHT_MAX)
	set_zoom_target(_height_to_zoom(height_target), false, anchor)


# Absolute clamped zoom target (legacy 2D scalar). The first two parameters are the
# exact contract API; the OPTIONAL third argument is additive (2-arg calls unchanged)
# and carries the zoom-at-cursor anchor set by zoom_step. immediate=true snaps
# (startup/reset), like camera.gd:257-262. The explicit height state is kept in
# lockstep (DEEPDEC-01 §6 item 1).
func set_zoom_target(target: float, immediate: bool = false, anchor: Vector2 = Vector2.INF) -> void:
	zoom_target = clampf(target, min_zoom, max_zoom)
	height_target = _zoom_to_height(zoom_target)
	_zoom_anchor_screen = anchor
	if immediate:
		zoom = zoom_target
		height = height_target
		_zoom_anchor_screen = Vector2.INF
		_apply_transform()


# Frame-rate-independent exponential approach (camera.gd:267-284), now interpolated
# in the explicit HEIGHT state (DEEPDEC-01 §6 item 1). Hold the world point under the
# zoom anchor fixed across the perspective dolly. The old/new-height distinction is
# preserved: anchor_world/anchor_h are sampled at the OLD height (before the dolly),
# then the ray is re-hit at that height after _apply_transform() moved to the NEW
# height — the port equivalent of donor's oldHeight target shift / height camera
# offset (onmousewheel.inc:56,60; DEEPDEC-01 §6 item 3).
func _smooth_zoom(dt: float) -> void:
	if absf(zoom_target - zoom) < 0.0005:
		if height != height_target or zoom != zoom_target:
			height = height_target
			zoom = zoom_target
			_apply_transform()
		_zoom_anchor_screen = Vector2.INF
		return
	var anchored: bool = is_finite(_zoom_anchor_screen.x) and is_finite(_zoom_anchor_screen.y)
	# E6 / V7-77: hold the TERRAIN surface point under the cursor, not its Y=0 shadow.
	# With no sampler _screen_to_surface() == screen_to_world() (flat default).
	var anchor_world: Vector2 = _screen_to_surface(_zoom_anchor_screen) if anchored else Vector2.INF
	# Freeze the anchor's sampled height: after the dolly, the same world point must
	# stay under the cursor, so re-hit the ray at THIS height (not a re-sampled one,
	# which would track a different surface point on a slope).
	var anchor_h: float = _sample_height(anchor_world) if is_finite(anchor_world.x) and is_finite(anchor_world.y) else 0.0
	var old_h: float = height
	var t: float = 1.0 - exp(-zoom_smooth_rate * dt)
	var new_h: float = old_h + (height_target - old_h) * t
	var new_z: float = _height_to_zoom(new_h)
	if absf(zoom_target - new_z) < 0.0005:
		new_h = height_target
		new_z = zoom_target
	height = new_h
	zoom = new_z
	_apply_transform()
	if anchored and is_finite(anchor_world.x) and is_finite(anchor_world.y):
		# Same-height ray hit at the NEW height/zoom; with no sampler anchor_h == 0.0
		# and this is byte-equivalent to the old flat screen_to_world() correction.
		var after: Vector2 = _screen_to_plane(_zoom_anchor_screen, anchor_h)
		if not is_finite(after.x) or not is_finite(after.y):
			# Steep hill above the dolly position: the sampled plane is not hit.
			# Fall back to the old flat hit rather than dropping the anchor.
			after = screen_to_world(_zoom_anchor_screen)
		if is_finite(after.x) and is_finite(after.y):
			_target += anchor_world - after
			_apply_transform()
	if height == height_target:
		_zoom_anchor_screen = Vector2.INF
