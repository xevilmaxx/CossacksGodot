extends Node3D

# M0 terrain-only 3D A/B sandbox entry. NEW FILE - never `quit()` in _ready or
# _initialize(); capture after ~30 rendered frames and quit deferred.

const DUMP_PATH := "res://shots/final_fullmap_dump.json"
# M0.6: pad the old 16-tile window with neighbours so the mesh runs past every
# frame edge (176 = 184-8, 146 = 154-8; the old centre (192,162) is preserved).
const WIN_X := 176
const WIN_Y := 146
const WIN_N := 32
const SHOT_PATH := "res://shots/terrain3d_m06.png"
const STATS_PATH := "res://shots/terrain3d_m06.json"
# --seam-mask: solid magenta background + hidden distant ground, so any pixel
# of the patch interior showing magenta is a true see-through seam gap.
const MASK_SHOT_PATH := "res://shots/terrain3d_m06_seammask.png"
const MASK_STATS_PATH := "res://shots/terrain3d_m06_seammask.json"

const CAPTURE_FRAME := 30
const WIDTH := 1280
const HEIGHT := 720

# --- M0.6 CAMERA (visual judgement over unverified derivation) ---------------
# DONOR SENSOR CONSTANT IS UNKNOWN -> exact FOV REMAINS UNVERIFIED.
# M0.5 shipped the "physically sane" 36 mm/f-400 derivation: 2.90 deg V-FOV at
# 240 m height / 384 m dolly. It framed the same patch but compressed depth so
# hard the result read as TOP-DOWN - the reviewer rejected it. M0.6 RESTORES the
# M0 216 mm "display sensor" -> 17.27 deg V-FOV at 40 m / 64 m (tilt -32 deg),
# where the 32 m patch subtends a large angle and vertical faces are visible.
# The 36 mm derivation is recorded as UNVERIFIED; visual judgement won.
const FOCAL_LEN := 400.0
const SENSOR_W_MM := 216.0
const FULLFRAME_SENSOR_W_MM := 36.0    # unverified derivation, reported for A/B
const SENSOR_SCALE: float = 1.0        # M0.6: no distance scaling
const CAM_HEIGHT_M := 40.0
const TILT_DEG := 32.0

var _frame: int = 0
var _capture_started: bool = false
var _seam_mask: bool = false
var _draw_sum: float = 0.0
var _time_sum: float = 0.0
var _delta_sum: float = 0.0
var _samples: int = 0
var _world: Node3D = null
var _camera: Camera3D = null


func _ready() -> void:
	get_window().size = Vector2i(WIDTH, HEIGHT)
	var dump_path := DUMP_PATH
	# Optional override: -- --dump res://shots/foo.json (still through runner).
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--dump="):
			dump_path = arg.substr(7)
		if arg == "--seam-mask":
			_seam_mask = true
	if not FileAccess.file_exists(dump_path):
		push_error("terrain3d: dump not found: " + dump_path)
		get_tree().call_deferred("quit", 1)
		return
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(dump_path))
	if not (parsed is Dictionary):
		push_error("terrain3d: dump JSON is not an object")
		get_tree().call_deferred("quit", 1)
		return

	# Loaded dynamically: a brand-new class_name is not in .godot's global
	# class cache until an editor import, and all Godot launches go via runner.
	var world_script := load("res://scripts/world3d.gd") as Script
	if world_script == null:
		push_error("terrain3d: cannot load world3d.gd")
		get_tree().call_deferred("quit", 1)
		return
	_world = world_script.new() as Node3D
	_world.name = "TerrainWorld"
	add_child(_world)
	if not bool(_world.call("build_from_dump", parsed, WIN_X, WIN_Y, WIN_N)):
		get_tree().call_deferred("quit", 1)
		return
	if _seam_mask:
		_configure_seam_mask()

	_camera = Camera3D.new()
	_camera.name = "DonorCamera"
	_camera.projection = Camera3D.PROJECTION_PERSPECTIVE
	var sensor_h: float = SENSOR_W_MM * float(HEIGHT) / float(WIDTH)
	var fov_v: float = rad_to_deg(2.0 * atan(sensor_h / (2.0 * FOCAL_LEN)))
	_camera.fov = fov_v
	_camera.near = 0.1
	_camera.far = 600.0
	var tilt := deg_to_rad(TILT_DEG)
	var ground_dist: float = CAM_HEIGHT_M / tan(tilt)
	# M0.6: set the tilt EXPLICITLY instead of deriving it via look_at. Godot's
	# Camera3D looks down its local -Z; rotation.x = -tilt points the view
	# downward at `tilt` degrees below horizontal while +Z stays "into screen".
	_camera.position = Vector3(0.0, CAM_HEIGHT_M, ground_dist)
	_camera.rotation = Vector3(-tilt, 0.0, 0.0)
	add_child(_camera)
	_camera.make_current()

	var wstats: Dictionary = _world.get("stats") if _world != null else {}
	print("terrain3d: ready; fov_v=", fov_v, " pos=", _camera.position,
		" surfaces=", wstats.get("surfaces", -1))


func _configure_seam_mask() -> void:
	var we := _world.get_node_or_null("WorldEnvironment") as WorldEnvironment
	if we != null and we.environment != null:
		we.environment.background_mode = Environment.BG_COLOR
		we.environment.background_color = Color(1.0, 0.0, 1.0, 1.0)
		we.environment.tonemap_exposure = 1.0  # keep magenta exactly detectable
	var ground := _world.get_node_or_null("DistantGround")
	if ground != null:
		ground.visible = false
	# Shallow water is intentionally translucent; over a magenta debug
	# background it would look like a gap. Hide it so only missing geometry is
	# counted as a seam.
	var water := _world.get_node_or_null("WaterPlane")
	if water != null:
		water.visible = false


func _process(delta: float) -> void:
	_frame += 1
	if _frame >= 5:
		_draw_sum += float(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
		_time_sum += float(Performance.get_monitor(Performance.TIME_PROCESS))
		_delta_sum += delta           # real frame-to-frame time, not CPU process time
		_samples += 1
	if _frame >= CAPTURE_FRAME and not _capture_started:
		_capture_started = true
		_capture_async()


func _capture_async() -> void:
	await RenderingServer.frame_post_draw
	var vp := get_viewport()
	var img: Image = vp.get_texture().get_image()
	var src_w := img.get_width()
	var src_h := img.get_height()
	var resized := false
	if src_w != WIDTH or src_h != HEIGHT:
		# Only a format normalisation; recorded honestly in the stats.
		img.resize(WIDTH, HEIGHT, Image.INTERPOLATE_BILINEAR)
		resized = true
	var shot_path := MASK_SHOT_PATH if _seam_mask else SHOT_PATH
	var err := img.save_png(shot_path)
	if err != OK:
		push_error("terrain3d: save_png failed: " + str(err))

	var sensor_h_ship: float = SENSOR_W_MM * float(HEIGHT) / float(WIDTH)
	var fov_ship: float = rad_to_deg(2.0 * atan(sensor_h_ship / (2.0 * FOCAL_LEN)))
	var sensor_h_ff: float = FULLFRAME_SENSOR_W_MM * float(HEIGHT) / float(WIDTH)
	var fov_ff: float = rad_to_deg(2.0 * atan(sensor_h_ff / (2.0 * FOCAL_LEN)))
	var wstats: Dictionary = _world.get("stats") if _world != null else {}
	var st: Dictionary = wstats.duplicate(true)
	st["shot"] = shot_path
	st["seam_mask_mode"] = _seam_mask
	st["shot_size"] = {"w": WIDTH, "h": HEIGHT,
		"source_w": src_w, "source_h": src_h, "resized": resized}
	st["camera"] = {
		"projection": "perspective",
		"focal_length_mm": FOCAL_LEN,
		"tilt_deg": -TILT_DEG,
		"height_m": CAM_HEIGHT_M,
		"ground_dist_m": CAM_HEIGHT_M / tan(deg_to_rad(TILT_DEG)),
		"position": [_camera.position.x, _camera.position.y, _camera.position.z],
		"rotation_deg": [rad_to_deg(_camera.rotation.x), rad_to_deg(_camera.rotation.y), rad_to_deg(_camera.rotation.z)],
		"sensor_width_mm_shipped": SENSOR_W_MM,
		"fov_vertical_deg_shipped": fov_ship,
		"fov_horizontal_deg_shipped": rad_to_deg(2.0 * atan(SENSOR_W_MM / (2.0 * FOCAL_LEN))),
		"unverified_fullframe_sensor_mm": FULLFRAME_SENSOR_W_MM,
		"unverified_fullframe_fov_vertical_deg": fov_ff,
		"tilt_is_explicit_rotation": true,
		"patch_tiles": WIN_N,
		"framing": ("32-tile (64 m) mesh padded past every frame edge; camera "
			+ "40 m high / 64 m dolly looking down an explicit -32 deg tilt"),
		"fov_verified": false,
		"fov_note": ("Exact donor FOV UNVERIFIED (donor sensor constant unknown). "
			+ "M0.5's 'physically sane' 36 mm/f-400 derivation gave 2.90 deg V-FOV "
			+ "at 240 m/384 m but flattened depth into a top-down mosaic and was "
			+ "REJECTED on visual review. M0.6 restores the 216 mm display sensor "
			+ "(17.27 deg V-FOV) at 40 m/64 m; visual judgement won over the "
			+ "unverified derivation."),
	}
	st["sun"] = {
		"light_cfg_position": [-0.3447, 0.9387, 0.0],
		"donor_lightvector_zyup": [-0.086, 0.0, 0.939],
		"godot_direction_yup": [-0.086, 0.939, 0.0],
		"shadows": true,
		"ambient_light": true,
	}
	st["performance"] = {
		"frames_sampled": _samples,
		"mean_draw_calls": (_draw_sum / float(_samples)) if _samples > 0 else -1.0,
		"mean_frame_process_ms": (_time_sum / float(_samples)) * 1000.0 if _samples > 0 else -1.0,
		"mean_frame_delta_ms": (_delta_sum / float(_samples)) * 1000.0 if _samples > 0 else -1.0,
	}
	st["missing"] = [
		"units/buildings/trees/decor", "HUD/minimap/fog of war",
		"water refraction/screen-space depth", "DOF/fog",
		"donor sub-atlas UV seams and 25deg oriented face art",
		"verified donor FOV / sensor constant",
		"donor tiles.mat art for 'test*' placeholder block names (flat fallback)",
	]
	st["reflection"] = {
		"status": "deferred to M1 water fidelity",
		"reason": ("Water occupies only thin shoreline slivers (<2% of the M0 frame), so a "
			+ "hint_screen_texture wave-jitter proxy cannot be measured against the "
			+ ">=3-5 px crest-shift gate without changing the M0 scene; Compatibility "
			+ "screen-copy cost is also unverified. Donor decals/cubemap were NOT copied. "
			+ "Donor water reflection is a live projected texture (water.dev.frag), "
			+ "not the cubemap and not the decals."),
	}
	var stats_path := MASK_STATS_PATH if _seam_mask else STATS_PATH
	var f := FileAccess.open(stats_path, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(st, "  "))
		f.close()
	else:
		push_error("terrain3d: cannot write stats")
	print("terrain3d: captured ", shot_path)
	get_tree().call_deferred("quit", 0)
