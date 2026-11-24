extends SceneTree

# G3-2 — CLI harness for the full-map heightmesh capture.
#
# WHY `extends SceneTree` (not Node3D as the M0 sandbox was):
# MEASURED runner probe `g32-cli-probe` (stdout/stderr at
# app/.godot_queue/results/00001312_g32-cli-probe/) — Godot 4.7.2 rejects a
# Node3D --script with: "Can't load the script ... as it doesn't inherit from
# SceneTree or MainLoop" (main/main.cpp:4385). Every test harness in app/tests
# is a SceneTree for the same reason. This script therefore owns a Node3D
# world instance loaded dynamically from heightmap_world3d.gd via load(),
# keeping the M0 sandbox's "load(), no class_name, capture after N frames,
# quit deferred" pattern. heightmap_world3d.gd itself IS a Node3D.
#
# Donor literals used here (read-only, singleplayer skirmish main view):
#   data/cameras/camera.cfg:32-35  tilt -32 in all four FreeRotation slots
#   data/cameras/camera.cfg:44-45  MinFocalLength = MaxFocalLength = 400
#   data/cameras/camera.cfg:6-10   SphereHeight 58 / Min 20 (world units)
#   data/cameras/default.cameras:4-18 FocalLength 400, DirZ -1, UpY 1
# UNVERIFIED: donor absolute sensor width / FOV. The 216 mm "display sensor"
# (17.27 deg V-FOV) is M0.6's visual-judgement assumption, NOT donor data.

const DUMP_PATH := "res://shots/g32_dump.json"
const WORLD_SCRIPT_PATH := "res://scripts/heightmap_world3d.gd"
const SHOT_PATH := "res://shots/hm3d_full.png"
const STATS_PATH := "res://shots/hm3d_full.json"

const CAPTURE_FRAME := 30
const WIDTH := 1280
const HEIGHT := 720

const FOCAL_LEN := 400.0              # camera.cfg:44-45 (donor focal length)
const SENSOR_W_MM := 216.0            # M0.6 display-sensor assumption: UNVERIFIED
const TILT_DEG := 32.0                # camera.cfg:32-35 (donor tilt -32)
const CAM_HEIGHT_M := 40.0            # PORT choice inside donor 20..58 (camera.cfg:6-10)
const CAM_FAR_M := 4000.0             # PORT choice (default.cameras:10 DepthOfView=1200 is not a donor far-plane constant); raised for --cam-scale overviews
const PERSPECTIVE := true            # G3-1 claim 1: donor main view is perspective

var _frame: int = 0
var _capture_started: bool = false
var _stay: bool = false
var _cam_scale: float = 1.0
var _cam_height_m: float = CAM_HEIGHT_M
var _cam_ground_dist_m: float = 0.0
var _dump_path: String = DUMP_PATH
var _draw_sum: float = 0.0
var _time_sum: float = 0.0
var _delta_sum: float = 0.0
var _samples: int = 0
var _world: Node3D = null
var _camera: Camera3D = null
var _root: Window = null
var _ready_ok: bool = false


func _initialize() -> void:
	_root = get_root()
	_root.size = Vector2i(WIDTH, HEIGHT)
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--dump="):
			_dump_path = arg.substr(7)
		elif arg.begins_with("--cam-scale="):
			_cam_scale = maxf(0.1, float(arg.substr(12)))
		elif arg == "--stay":
			_stay = true
	if not FileAccess.file_exists(_dump_path):
		push_error("heightmap3d: dump not found: " + _dump_path)
		call_deferred("quit", 1)
		return
	var t0 := Time.get_ticks_usec()
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(_dump_path))
	if not (parsed is Dictionary):
		push_error("heightmap3d: dump JSON is not an object")
		call_deferred("quit", 1)
		return
	var parse_ms: float = float(Time.get_ticks_usec() - t0) / 1000.0

	# Dynamic load: a brand-new class_name is not in .godot's global cache
	# until an editor import, and all Godot launches go through the runner.
	var world_script := load(WORLD_SCRIPT_PATH) as Script
	if world_script == null:
		push_error("heightmap3d: cannot load heightmap_world3d.gd")
		call_deferred("quit", 1)
		return
	_world = world_script.new() as Node3D
	if _world == null:
		push_error("heightmap3d: world script is not a Node3D")
		call_deferred("quit", 1)
		return
	_world.name = "HeightmapWorld"
	_root.add_child(_world)
	var t_build := Time.get_ticks_usec()
	if not bool(_world.call("build_from_dump", parsed)):
		call_deferred("quit", 1)
		return
	var build_call_ms: float = float(Time.get_ticks_usec() - t_build) / 1000.0

	_camera = Camera3D.new()
	_camera.name = "DonorCamera"
	_camera.projection = Camera3D.PROJECTION_PERSPECTIVE
	var sensor_h: float = SENSOR_W_MM * float(HEIGHT) / float(WIDTH)
	_camera.fov = rad_to_deg(2.0 * atan(sensor_h / (2.0 * FOCAL_LEN)))
	_camera.near = 0.1
	_camera.far = CAM_FAR_M
	var tilt: float = deg_to_rad(TILT_DEG)
	var height_m: float = CAM_HEIGHT_M * _cam_scale
	var ground_dist: float = height_m / tan(tilt)   # camera tilt reaches ground at map centre
	_cam_height_m = height_m
	_cam_ground_dist_m = ground_dist
	_camera.position = Vector3(0.0, height_m, ground_dist)
	# Godot Camera3D looks down local -Z: explicit -tilt rotation.x points the
	# view down by TILT_DEG below horizontal (M0.6 pattern, donor camera.cfg:32-35).
	_camera.rotation = Vector3(-tilt, 0.0, 0.0)
	_root.add_child(_camera)
	_camera.make_current()

	_ready_ok = true
	var wstats: Dictionary = _world.get("stats") if _world != null else {}
	print("heightmap3d: ready grid=", wstats.get("grid", {}),
		" verts=", wstats.get("mesh_vertices", -1),
		" tris=", wstats.get("mesh_triangles", -1),
		" fov_v=", _camera.fov, " pos=", _camera.position,
		" dump_parse_ms=", parse_ms, " build_call_ms=", build_call_ms)


func _process(delta: float) -> bool:
	# MainLoop._process returns bool: true ends the loop. We quit explicitly.
	if not _ready_ok:
		return false
	_frame += 1
	if _frame >= 5:
		_draw_sum += float(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
		_time_sum += float(Performance.get_monitor(Performance.TIME_PROCESS))
		_delta_sum += delta
		_samples += 1
	if not _stay and _frame >= CAPTURE_FRAME and not _capture_started:
		_capture_started = true
		_capture_async()
	return false


func _image_stats(img: Image) -> Dictionary:
	if img == null or img.is_empty():
		return {"non_blank": false, "mean_luminance": -1.0, "luminance_span": 0.0}
	var first: float = img.get_pixel(0, 0).get_luminance()
	var lo: float = first
	var hi: float = first
	var sum: float = 0.0
	var n: int = 0
	var step_y: int = maxi(1, img.get_height() / 64)
	var step_x: int = maxi(1, img.get_width() / 64)
	for y in range(0, img.get_height(), step_y):
		for x in range(0, img.get_width(), step_x):
			var l: float = img.get_pixel(x, y).get_luminance()
			lo = minf(lo, l)
			hi = maxf(hi, l)
			sum += l
			n += 1
	return {"non_blank": (hi - lo) > 0.02, "mean_luminance": sum / float(n),
		"luminance_span": hi - lo, "samples": n}


func _capture_async() -> void:
	await RenderingServer.frame_post_draw
	var img: Image = _root.get_texture().get_image()
	var src_w: int = img.get_width() if img != null else 0
	var src_h: int = img.get_height() if img != null else 0
	var resized: bool = false
	if img != null and (src_w != WIDTH or src_h != HEIGHT):
		img.resize(WIDTH, HEIGHT, Image.INTERPOLATE_BILINEAR)
		resized = true
	var pix: Dictionary = _image_stats(img)
	var save_err: int = ERR_UNAVAILABLE
	if img != null:
		save_err = img.save_png(SHOT_PATH)
	if save_err != OK:
		push_error("heightmap3d: save_png failed: " + str(save_err))

	var wstats: Dictionary = _world.get("stats") if _world != null else {}
	var st: Dictionary = wstats.duplicate(true)
	st["shot"] = SHOT_PATH
	st["shot_size"] = {"w": WIDTH, "h": HEIGHT, "source_w": src_w,
		"source_h": src_h, "resized": resized}
	st["capture"] = pix
	st["capture_saved"] = save_err == OK
	st["camera"] = {
		"projection": "perspective",
		"focal_length_mm": FOCAL_LEN,
		"tilt_deg": -TILT_DEG,
		"height_m": _cam_height_m,
		"ground_dist_m": _cam_ground_dist_m,
		"position": [_camera.position.x, _camera.position.y, _camera.position.z],
		"rotation_deg": [rad_to_deg(_camera.rotation.x), rad_to_deg(_camera.rotation.y),
			rad_to_deg(_camera.rotation.z)],
		"sensor_width_mm_assumed": SENSOR_W_MM,
		"fov_vertical_deg": _camera.fov,
		"sensor_is_donor": false,
		"fov_verified": false,
		"cam_scale": _cam_scale,
		"donor_height_range_ok": _cam_height_m >= 20.0 and _cam_height_m <= 58.0,
		"donor_literals": ["camera.cfg:32-35 tilt -32", "camera.cfg:44-45 focal 400",
			"camera.cfg:6-10 height 20..58"],
		"framing": ("full grid in ONE mesh; --cam-scale=" + str(_cam_scale)
			+ " -> height " + str(_cam_height_m) + " m / dolly " + str(_cam_ground_dist_m)
			+ " m. Default scale 1.0 is donor-valid (40 m) and frames a local "
			+ "patch; scales >1 exit the donor 20..58 m range and are DIAGNOSTIC "
			+ "OVERVIEWS that keep only donor tilt/focal/sensor."),
	}
	st["sandbox"] = {
		"extends": "SceneTree (CLI --script requirement; see file header)",
		"world_extends": "Node3D",
		"world_load": "load('res://scripts/heightmap_world3d.gd')",
		"capture_frame": CAPTURE_FRAME,
		"dump": _dump_path,
		"scene_content": "terrain + water + sky/light only; no units/buildings/trees/HUD",
		"no_donor_copy": true,
	}
	st["performance"] = {
		"frames_sampled": _samples,
		"mean_draw_calls": (_draw_sum / float(_samples)) if _samples > 0 else -1.0,
		"mean_frame_process_ms": (_time_sum / float(_samples)) * 1000.0 if _samples > 0 else -1.0,
		"mean_frame_delta_ms": (_delta_sum / float(_samples)) * 1000.0 if _samples > 0 else -1.0,
	}
	st["missing"] = [
		"units/buildings/trees/decor", "HUD/minimap/fog of war",
		"donor HeightField shader PCF/fog (hf.pvl.sm.vert/hf.pvl.smx3.frag)",
		"donor terrainmesh1..4.osm relief LOD props",
		"donor verticalfront/verticalside oriented cliff face art",
		"verified donor sensor/FOV and height-grid mesh LOD",
	]
	var f := FileAccess.open(STATS_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(st, "  "))
		f.close()
	else:
		push_error("heightmap3d: cannot write stats")
	print("heightmap3d: captured ", SHOT_PATH, " non_blank=", pix.get("non_blank", false))
	call_deferred("quit", 0)
