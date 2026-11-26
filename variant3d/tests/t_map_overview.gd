# MAP-OVERVIEW — whole-map dump with all drawn assets.
# Single image mode (zoomable):
#   --config <ABS>.json --screenshot <ABS>.png --seed 20261113
#   [--overview-size 4096]
# Sequence mode for high-res videos (frames share the same ortho rig):
#   --config <ABS>.json --out-dir <ABS-dir> --seed 20261113
#   [--overview-size 2048] [--frames 24] [--sim-step 1.0]
# Sequence advances the sim between frames so growth/construction can be
# reviewed later as video. Single and sequence modes share one Godot run.
extends SceneTree

const MAIN_SCENE := "res://scenes/main.tscn"
const Data = preload("res://scripts/data.gd")

var _cfg_arg := ""
var _shot_arg := ""
var _seed_arg := ""
var _size_arg := 4096
var _out_dir := ""
var _frames := 1
var _sim_step := 1.0

var _main: Node = null
var _game = null
var _world = null
var _vp: SubViewport = null
var _old_cam = null

func _arg_value(flag: String) -> String:
	for src in [OS.get_cmdline_user_args(), OS.get_cmdline_args()]:
		var args := PackedStringArray(src)
		for i in range(args.size()):
			if str(args[i]) == flag and i + 1 < args.size():
				return str(args[i + 1])
	return ""

func _fail(msg: String) -> int:
	print("MAPOVERVIEW FAIL " + msg)
	push_error(msg)
	quit(1)
	return 1

func _parse_args() -> bool:
	_cfg_arg = _arg_value("--config")
	_shot_arg = _arg_value("--screenshot")
	_seed_arg = _arg_value("--seed")
	_out_dir = _arg_value("--out-dir")
	var frames_txt := _arg_value("--frames")
	if frames_txt != "":
		_frames = clampi(int(frames_txt), 1, 240)
	var step_txt := _arg_value("--sim-step")
	if step_txt != "":
		_sim_step = clampf(float(step_txt), 0.0, 60.0)
	var size_txt := _arg_value("--overview-size")
	if size_txt != "":
		_size_arg = clampi(int(size_txt), 1024, 8192)
	if _cfg_arg == "" or not _cfg_arg.is_absolute_path():
		_fail("need --config <absolute json>")
		return false
	if _seed_arg != "20261113":
		_fail("need --seed 20261113")
		return false
	if _out_dir != "":
		if not _out_dir.is_absolute_path():
			_fail("need --out-dir absolute")
			return false
		_frames = maxi(_frames, 2)
		return true
	if _shot_arg == "" or not _shot_arg.is_absolute_path():
		_fail("need --screenshot <absolute png> or --out-dir <absolute dir>")
		return false
	_frames = 1
	return true

func _boot() -> bool:
	var packed: PackedScene = load(MAIN_SCENE) as PackedScene
	if packed == null:
		_fail("cannot load main scene")
		return false
	_main = packed.instantiate()
	if _main == null:
		_fail("cannot instantiate main")
		return false
	root.add_child(_main)
	# Let main _ready run; wait for boot similar to motion capture.
	var deadline := Time.get_ticks_msec() + 300000
	while Time.get_ticks_msec() < deadline:
		await process_frame
		if _main.get("game") != null and _main.get("world") != null and _main.get("camera") != null and _main.get("capture_view3d") != null:
			var g = _main.get("game")
			if g != null and int(g.get("MAP_W")) > 0:
				break
	_game = _main.get("game")
	_world = _main.get("world")
	_old_cam = _main.get("camera")
	_vp = _main.get("capture_view3d") as SubViewport
	if _game == null or _world == null or _old_cam == null or _vp == null:
		_fail("boot incomplete")
		return false
	# Freeze sim like motion capture.
	var ais = _main.get("ais")
	if ais is Array:
		(ais as Array).clear()
	_main.set("speed", 0.0)
	_main.set("acc", 0.0)
	_main.set("screenshot_frames", 1000000)
	_main.set("screenshot_done", true)
	_old_cam.set_process(false)
	return true

func _dump() -> bool:
	var map_w := int(_game.get("MAP_W"))
	var map_h := int(_game.get("MAP_H"))
	if map_w <= 0 or map_h <= 0:
		_fail("bad map size")
		return false
	var tile_m := 2.0
	var extent_m := float(maxi(map_w, map_h)) * tile_m
	# Square high-res viewport.
	_vp.size = Vector2i(_size_arg, _size_arg)
	_vp.render_target_update_mode = SubViewport.UPDATE_ONCE
	await RenderingServer.frame_post_draw
	# Overview camera: orthographic top-down, centered at world origin
	# (donor mesh is centered at 0,0 per terrain_donor_mesh.gd build).
	var cam := Camera3D.new()
	cam.name = "OverviewOrthoCam"
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = extent_m + 20.0
	cam.near = 1.0
	cam.far = 1000.0
	# Top-down: position above center, look straight down.
	cam.position = Vector3(0, 300, 0)
	cam.rotation = Vector3(deg_to_rad(-90.0), 0, 0)
	_vp.add_child(cam)
	cam.make_current()
	if _out_dir == "":
		_world.sync(0.0)
		_vp.render_target_update_mode = SubViewport.UPDATE_ONCE
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		var tex_once = _vp.get_texture()
		var img_once: Image = tex_once.get_image() if tex_once != null else null
		if img_once == null or img_once.is_empty():
			_fail("empty overview image")
			return false
		var err_once := img_once.save_png(_shot_arg)
		if err_once != OK:
			_fail("save_png failed")
			return false
		print("MAPOVERVIEW OK size=%dx%d map=%dx%d extent=%.1fm file=%s" % [img_once.get_width(), img_once.get_height(), map_w, map_h, extent_m, _shot_arg])
		return true
	DirAccess.make_dir_recursive_absolute(_out_dir)
	for i in range(_frames):
		if _sim_step > 0.0:
			_game.tick(_sim_step)
		_world.sync(0.0)
		_vp.render_target_update_mode = SubViewport.UPDATE_ONCE
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		var tex_seq = _vp.get_texture()
		var img_seq: Image = tex_seq.get_image() if tex_seq != null else null
		if img_seq == null or img_seq.is_empty():
			_fail("empty overview frame %d" % i)
			return false
		var path := _out_dir.path_join("overview_%04d.png" % i)
		if img_seq.save_png(path) != OK:
			_fail("save_png failed " + path)
			return false
		print("MAPOVERVIEW FRAME %02d/%02d sim=%.2f file=%s" % [i + 1, _frames, float(_game.get("time_s")), path])
	print("MAPOVERVIEW SEQ OK frames=%d size=%d map=%dx%d filedir=%s" % [_frames, _size_arg, map_w, map_h, _out_dir])
	return true

func _init() -> void:
	if not _parse_args():
		return
	_boot_and_dump()

func _boot_and_dump() -> void:
	var ok := await _boot()
	if not ok:
		return
	var done := await _dump()
	if not done:
		return
	quit(0)
