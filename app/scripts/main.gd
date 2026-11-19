# Entry point: wires the game together and handles the command line options.
#
#   --screenshot <file.png>   draw ~120 frames, save the window picture, exit
#                            (headless: saves a CPU-rendered map picture instead,
#                            so the check never needs a window and never hangs)
#   --self-test  <file.json>  drive the game with scripted input, save a report
#   --cli        [file.json]  fast headless match (no window) for quick tests
#   --cli-seconds <n>         how many simulated seconds the CLI match runs (default 60)
#   --journey                 computer plays BOTH sides (AI vs AI) in full-game
#   --seq <dir>               capture a frame sequence (gameplay video stills):
#                             windowed = real viewport frames, headless/CLI =
#                             CPU map timelapse; use with --seq-seconds/--seq-step
#   --seq-seconds <n>          capture length in sim seconds (default 60)
#   --seq-step <s>            sim seconds between frames (default 1)
#   --ui-test <file.json>     scripted user-journey UI test (menu, select,
#                             orders, build, train, squads, rally, market,
#                             research, delete, speed), saves a report
#   --config     <file.json>  read the settings from another file
#   --dump-config             print the settings the game runs with, then exit
#   --speed <n>               game speed multiplier (default 1)
#   --battle                  start in battle mode (two ready armies)
#   --timeout <seconds>       hard wall-clock limit, the process always exits
#
# The program never hangs: every test mode has a wall-clock watchdog and runs
# in small per-frame budgets, so one frame never blocks. CLI mode creates no
# window, no terrain textures and no audio - it is pure simulation.
# Cross-platform: renderer is gl_compatibility (project.godot), all paths are
# res:// / user:// or absolute, window flags are guarded by OS.get_name().
extends Node

const Data = preload("res://scripts/data.gd")
const C3ConfigScript = preload("res://scripts/config.gd")
const C3AudioScript = preload("res://scripts/audio.gd")
const C3WorldScript = preload("res://scripts/world.gd")
const C3CameraScript = preload("res://scripts/camera.gd")
const C3HUDScript = preload("res://scripts/hud.gd")
const C3InputScript = preload("res://scripts/input_controller.gd")
const C3AIScript = preload("res://scripts/ai.gd")
const C3SelfTest = preload("res://scripts/selftest.gd")
const C3UITestScript = preload("res://scripts/uitest.gd")
const C3MenuScript = preload("res://scripts/menu.gd")

var game: C3Game
var world: C3World
var camera: C3Camera
var hud: C3HUD
var input_ctl: C3Input
var ai: C3AI
var cli_ai0: C3AI
var acc := 0.0
var speed := 1.0
var frame := 0
var screenshot_path := ""
var screenshot_frames := 120
var screenshot_done := false
var selftest_path := ""
var uitest_path := ""
var uitest_only := ""
var seq_dir := ""
var seq_seconds := 60.0
var seq_step := 1.0
var seq_next := 0.0
var seq_count := 0
var seq_max := 600
var seq_saving := false
var seq_done := false
var seq_ready := false
var cli_path := ""
var cli_mode := false
var cli_seconds := 60.0
var cli_ticks_left := 0
var cli_t := 0.0
var cli_done := false
var journey_mode := false
var audio: C3Audio
var walk_snd_t := 0.0
var watchdog := 0.0
var started_ms := 0
var deadline_ms := 0
var limit_s := 0.0
var show_stats := false
var stats_t := 0.0
var frames := 0
var start_mode := "skirmish"
var battle_requested := false
var config_path := ""
var dump_config := false
var cfg = null
var is_headless := false
var menu = null
var pending_cfg: Dictionary = {}

func _ready() -> void:
	started_ms = Time.get_ticks_msec()
	_parse_args(OS.get_cmdline_args())
	_parse_args(OS.get_cmdline_user_args())
	is_headless = DisplayServer.get_name() == "headless"

	cfg = C3ConfigScript.new()
	cfg.load_all(config_path)
	cfg.apply()
	for p in cfg.problems:
		printerr("settings: ", p)
	if not battle_requested:
		start_mode = cfg.text("gameplay.mode", "skirmish")
	else:
		start_mode = "battle"
	if dump_config:
		print("settings file: ", cfg.source)
		print(cfg.dump())
		_quit(0)
		return

	var hard_limit := limit_s if limit_s > 0.0 else 120.0
	if screenshot_path != "" or selftest_path != "" or uitest_path != "" or seq_dir != "" or journey_mode or cli_mode:
		deadline_ms = started_ms + int(hard_limit * 1000.0)
		watchdog = hard_limit
	else:
		deadline_ms = 0
		watchdog = 0.0

	if cli_mode:
		_setup_cli_only()
		return

	# Test / capture modes skip the menu so they never wait for input.
	if screenshot_path != "" or selftest_path != "" or uitest_path != "" or seq_dir != "" or battle_requested:
		_setup_full_game()
		if screenshot_path != "":
			_setup_screenshot_window()
		return

	_setup_menu()

func _setup_menu() -> void:
	menu = C3MenuScript.new()
	add_child(menu)
	menu.chosen.connect(_on_menu_chosen)

func _on_menu_chosen(cfg: Dictionary) -> void:
	pending_cfg = cfg
	Data.PLAYER_NATIONS = [str(cfg.get("nation0", "ukr")), str(cfg.get("nation1", "rus"))]
	Data.PLAYER_NAMES = [_menu_nation_name(str(cfg.get("nation0", "ukr")), 0),
		_menu_nation_name(str(cfg.get("nation1", "rus")), 1)]
	Data.MAP_TYPE = str(cfg.get("map_type", "land"))
	Data.START_OPTION = str(cfg.get("start_option", "default"))
	if not battle_requested:
		start_mode = str(cfg.get("mode", "skirmish"))
	_setup_full_game()
	# mission objectives shown in the HUD (campaign / battle flavor)
	var descr := str(cfg.get("descr", ""))
	var mission := str(cfg.get("mission", ""))
	if descr != "" or mission != "":
		var objs := ["Destroy all enemy buildings"]
		if mission != "":
			objs.append("Mission: %s" % mission)
		if descr != "":
			objs.append(descr)
		game.set_objectives(objs)
		hud.refresh_objectives()
	if menu != null and is_instance_valid(menu):
		menu.queue_free()
		menu = null

func _menu_nation_name(sid: String, i: int) -> String:
	if Data.NATIONS.has(sid):
		return str(Data.NATIONS[sid].name)
	if Data.PLAYER_NAMES.size() > i:
		return str(Data.PLAYER_NAMES[i])
	return "Player %d" % (i + 1)

func set_speed(s: float) -> void:
	speed = clampf(s, 0.0, 8.0)
	if hud != null and hud.has_method("refresh_speed"):
		hud.refresh_speed(speed, game.paused if game != null else false)

func _setup_cli_only() -> void:
	# Fast headless match: simulation only, no rendering, no audio, no window.
	game = C3Game.new()
	add_child(game)
	game.setup(start_mode)
	ai = C3AIScript.new(game, 1)
	cli_ai0 = C3AIScript.new(game, 0)
	cli_ticks_left = int(cli_seconds * Data.FPS)
	cli_t = 0.0
	cli_done = false

func _setup_full_game() -> void:
	if not is_headless:
		get_window().size = Vector2i(Data.WINDOW_WIDTH, Data.WINDOW_HEIGHT)
		if Data.FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		DisplayServer.window_set_vsync_mode(
			DisplayServer.VSYNC_ENABLED if Data.VSYNC else DisplayServer.VSYNC_DISABLED)

	game = C3Game.new()
	add_child(game)
	game.setup(start_mode)
	game.game_over.connect(func(w: int) -> void: _on_game_over(w))

	world = C3WorldScript.new()
	world.bind(game)
	add_child(world)

	camera = C3CameraScript.new()
	add_child(camera)
	camera.bind(world)
	var homes := game.buildings_of(0)
	if not homes.is_empty():
		camera.position = homes[0].pos * world.view_scale
	else:
		camera.position = Vector2(20, 20) * Data.TILE_M * world.view_scale

	hud = C3HUDScript.new()
	add_child(hud)
	hud.bind(game, world)
	world.hud = hud
	hud.speed_cb = func(s: float) -> void:
		if s <= 0.0:
			game.paused = true
		else:
			game.paused = false
			set_speed(s)
		hud.refresh_speed(speed, game.paused)
	hud.menu_cb = func() -> void:
		get_tree().reload_current_scene()
	hud.refresh_selection([])
	hud.refresh_objectives()

	input_ctl = C3InputScript.new()
	add_child(input_ctl)
	input_ctl.bind(game, world, hud, camera)
	# start framed on the town hall with it selected, like the original
	# battle view: the bottom panel shows the building instead of empty black
	var homes2 := game.buildings_of(0)
	if not homes2.is_empty():
		input_ctl._set_selection([homes2[0]])

	ai = C3AIScript.new(game, 1)

	if journey_mode:
		# journey mode: the computer plays BOTH sides while frames record,
		# so a full match plays itself like a gameplay video
		cli_ai0 = C3AIScript.new(game, 0)

	audio = C3AudioScript.new()
	add_child(audio)
	var can_play := not is_headless
	if can_play:
		audio.start_music(str(game.players[0].get("nation", "ukr")))
	audio.set_meta("can_play", can_play)

func _setup_screenshot_window() -> void:
	if is_headless:
		return
	# Open the window without taking focus, so a check never gets in the way
	# of what the person is doing. Keep drawing while unfocused.
	var os_name := OS.get_name()
	get_window().size = Vector2i(Data.WINDOW_WIDTH, Data.WINDOW_HEIGHT)
	get_window().always_on_top = false
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_NO_FOCUS, true)
	if os_name == "Windows":
		# A covered window still draws on Windows, so it may stay behind.
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, false)
	else:
		# On macOS/Linux lowering the window may stop it drawing - keep it
		# raised but unfocused instead.
		pass
	# No waiting for the screen refresh: a covered window must not block.
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

# Read the options. Unknown words are skipped, so the engine's own arguments
# (--path, --headless, ...) do no harm.
func _parse_args(args: PackedStringArray) -> void:
	var i := 0
	while i < args.size():
		var a: String = args[i]
		match a:
			"--screenshot":
				screenshot_path = args[i + 1] if i + 1 < args.size() else ""
				i += 2
				continue
			"--screenshot-frames":
				screenshot_frames = maxi(10, int(args[i + 1])) if i + 1 < args.size() else 120
				i += 2
				continue
			"--self-test":
				selftest_path = args[i + 1] if i + 1 < args.size() else "selftest.json"
				i += 2
				continue
			"--ui-test":
				uitest_path = args[i + 1] if i + 1 < args.size() else "uitest.json"
				i += 2
				continue
			"--ui-only":
				uitest_only = args[i + 1] if i + 1 < args.size() else ""
				i += 2
				continue
			"--seq":
				seq_dir = args[i + 1] if i + 1 < args.size() else "seq"
				i += 2
				continue
			"--seq-seconds":
				seq_seconds = clampf(float(args[i + 1]) if i + 1 < args.size() else 60.0, 1.0, 600.0)
				i += 2
				continue
			"--seq-step":
				seq_step = clampf(float(args[i + 1]) if i + 1 < args.size() else 1.0, 0.25, 30.0)
				i += 2
				continue
			"--cli":
				cli_mode = true
				if i + 1 < args.size() and not str(args[i + 1]).begins_with("--"):
					cli_path = str(args[i + 1])
					i += 2
					continue
			"--cli-seconds":
				cli_seconds = clampf(float(args[i + 1]) if i + 1 < args.size() else 60.0, 1.0, 600.0)
				i += 2
				continue
			"--journey":
				journey_mode = true
			"--timeout":
				limit_s = maxf(1.0, float(args[i + 1])) if i + 1 < args.size() else 0.0
				i += 2
				continue
			"--config":
				config_path = args[i + 1] if i + 1 < args.size() else ""
				i += 2
				continue
			"--dump-config":
				dump_config = true
			"--battle":
				battle_requested = true
			"--stats":
				show_stats = true
			"--fast":
				speed = 8.0
			"--speed":
				speed = maxf(0.1, float(args[i + 1])) if i + 1 < args.size() else 1.0
				i += 2
				continue
			"--seed":
				i += 2
				continue
			_:
				i += 1
				continue
		i += 1

func _stop_sounds() -> void:
	if audio != null and is_instance_valid(audio):
		audio.stop_all()
		audio.free()
		audio = null

func _quit(code: int) -> void:
	_stop_sounds()
	get_tree().quit(code)

func _on_game_over(w: int) -> void:
	if hud != null and is_instance_valid(hud):
		hud.game_over(w)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_stop_sounds()

func _process(dt: float) -> void:
	# Hard wall-clock watchdog in every mode that must exit on its own.
	if deadline_ms > 0 and Time.get_ticks_msec() >= deadline_ms:
		printerr("watchdog: wall-clock limit reached, forced exit")
		_quit(1)
		return
	if game == null or ai == null:
		return
	if cli_mode:
		_run_cli_incremental()
		return
	if watchdog > 0.0:
		watchdog -= dt
		if watchdog <= 0.0:
			printerr("watchdog: forced exit")
			_quit(1)
			return
	# Clamp dt so a slow frame never spirals (cross-platform hitch guard).
	dt = minf(dt, 0.25)
	acc += dt * speed
	var step := 1.0 / Data.FPS
	var steps := 0
	while acc >= step and steps < 64:
		acc -= step
		steps += 1
		game.tick(step)
		ai.tick(step)
		if journey_mode and cli_ai0 != null:
			cli_ai0.tick(step)
		# Never block inside the loop: bail out if the frame budget is spent.
		if steps % 16 == 0 and Time.get_ticks_msec() >= deadline_ms - 500 and deadline_ms > 0:
			break
	if world != null and is_instance_valid(world):
		world.sync(dt)
	_consume_events()
	walk_snd_t -= dt
	if walk_snd_t <= 0.0:
		walk_snd_t = 1.25
		if audio != null and is_instance_valid(audio) and bool(audio.get_meta("can_play", false)):
			for e in game.entities:
				if not e.dead and e.kind == "unit" and e.moving and e.player == 0:
					_play(audio.walk_sound(e.sid))
					break
	frame += 1
	frames += 1
	if show_stats:
		stats_t += dt
		if stats_t >= 1.0:
			stats_t = 0.0
			print("frames %d  fps %.1f  units %d  entities %d" % [frames,
				Performance.get_monitor(Performance.TIME_FPS), game.unit_count(0), game.entities.size()])
	if screenshot_path != "" and not screenshot_done and frame >= screenshot_frames:
		screenshot_done = true
		_save_screenshot()
	elif selftest_path != "" and frame > 4:
		_run_selftest()
	elif uitest_path != "" and frame > 4:
		_run_uitest()
	if seq_dir != "" and not seq_done:
		if not seq_ready:
			seq_ready = true
			_seq_ensure_dir()
		if game != null and not seq_saving and game.time_s >= seq_next:
			seq_next = game.time_s + seq_step
			_save_seq_frame()

func _consume_events() -> void:
	if world == null or not is_instance_valid(world):
		game.events.clear()
		return
	for ev in game.events:
		match ev.type:
			"shot":
				world.add_fx("shot", ev.pos)
				match ev.kind:
					"bullet":
						_play(["musket1", "musket2"])
					"arrow", "firearrow":
						_play(["arrow1"])
					"cannonball":
						_play(["shotcannon1"])
					_:
						_play(["sabre1"])
			"smoke":
				world.add_fx("smoke", ev.pos)
			"heal":
				world.add_fx("heal", ev.pos)
			"rout":
				world.add_fx("rout", ev.pos)
				_play(["alarm"], -6.0)
			"crater":
				world.add_fx("crater", ev.pos)
			"research":
				_play(["construct"], -4.0)
			"upgraded":
				_play(["alarm"], -4.0)
			"trade":
				_play(["btnclick"], -4.0)
			"hit":
				if ev.kind == "bullet":
					_play(["arrowimpact1"], -8.0)
			"explode":
				world.add_fx("explode", ev.pos)
				_play(["cannonexpl1"])
			"chop":
				world.add_fx("chop", ev.pos)
			"death":
				if ev.kind == "building":
					_play(["deathbuilding1"])
				else:
					_play(["deathinf1", "deathinf2"])
			"capture":
				_play(["alarm"])
			"done":
				_play(audio.building_sound(ev.kind), -6.0)
	game.events.clear()

func _play(names: Array, vol := 0.0) -> void:
	if audio != null and is_instance_valid(audio) and bool(audio.get_meta("can_play", false)):
		audio.play(names, vol)

# ------------------------------------------------------------------ outputs
func _candidate_paths(given: String) -> Array:
	if given.begins_with("res://") or given.begins_with("user://"):
		return [given]
	if given.is_absolute_path():
		return [given]
	var proj := ProjectSettings.globalize_path("res://").trim_suffix("/")
	var ws := proj.get_base_dir()
	var out: Array = []
	var parts := given.replace("\\", "/").split("/")
	if parts.size() > 0 and parts[0] == proj.get_file():
		out.append(ws.path_join(given))
	out.append(proj.path_join(given))
	out.append(given)
	out.append("user://" + given.get_file())
	return out

func _pick_target(given: String) -> String:
	var list := _candidate_paths(given)
	for t in list:
		var p: String = t
		if p.begins_with("res://") or p.begins_with("user://"):
			p = ProjectSettings.globalize_path(p)
		var dir := p.get_base_dir()
		if dir == "" or DirAccess.dir_exists_absolute(dir):
			return p
	return list[0]

func _write_text(given: String, text: String) -> String:
	var p := _pick_target(given)
	var dir := p.get_base_dir()
	if dir != "" and not DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_recursive_absolute(dir)
	var f := FileAccess.open(p, FileAccess.WRITE)
	if f:
		f.store_string(text)
		f.close()
		return p
	var alt := ProjectSettings.globalize_path("user://" + given.get_file())
	var f2 := FileAccess.open(alt, FileAccess.WRITE)
	if f2:
		f2.store_string(text)
		f2.close()
		return alt
	return ""

func _save_screenshot() -> void:
	if is_headless:
		# No GPU in headless: render a map picture on the CPU instead.
		var img := _render_headless_image(800, 600)
		var out := _write_bytes(screenshot_path, img)
		if out == "":
			printerr("screenshot: could not write ", screenshot_path)
			_quit(1)
			return
		print("screenshot saved (headless map render): ", out)
		_quit(0)
		return
	# Windowed: capture the real viewport (waits for the GPU frame first).
	await RenderingServer.frame_post_draw
	# The window may have been closed while waiting - exit cleanly.
	if not is_instance_valid(get_viewport()):
		printerr("screenshot: viewport gone")
		_quit(1)
		return
	var tex := get_viewport().get_texture()
	if tex == null:
		printerr("screenshot: no viewport texture")
		_quit(1)
		return
	var img := tex.get_image()
	if img == null or img.is_empty():
		printerr("screenshot: blank image, retrying with map render")
		img = _render_headless_image(800, 600)
	var out2 := _write_bytes(screenshot_path, img)
	if out2 == "":
		printerr("screenshot: could not write ", screenshot_path)
		_quit(1)
		return
	# A blank picture never passes: fall back to the map render instead.
	if _is_blank(img):
		var fb := _render_headless_image(800, 600)
		out2 = _write_bytes(screenshot_path, fb)
		print("screenshot saved (fallback map render): ", out2)
	else:
		print("screenshot saved: ", out2)
	_quit(0)

func _is_blank(img: Image) -> bool:
	if img == null or img.is_empty():
		return true
	var w := mini(img.get_width(), 64)
	var h := mini(img.get_height(), 64)
	var first := img.get_pixel(0, 0)
	for y in range(0, img.get_height(), maxi(1, img.get_height() / h)):
		for x in range(0, img.get_width(), maxi(1, img.get_width() / w)):
			if img.get_pixel(x, y).get_luminance() - first.get_luminance() > 0.02:
				return false
	return true

# CPU map render used for headless screenshots and as a blank fallback.
# No GPU, no window, no textures: pure Image fills, fast and cross-platform.
func _render_headless_image(w: int, h: int) -> Image:
	var img := Image.create(w, h, false, Image.FORMAT_RGB8)
	img.fill(Color(0.09, 0.11, 0.08))
	if game == null:
		return img
	# Map area: keep aspect, letterbox.
	var map_w := float(game.MAP_W)
	var map_h := float(game.MAP_H)
	var s := minf(float(w) / map_w, float(h) / map_h)
	var ox := (float(w) - map_w * s) * 0.5
	var oy := (float(h) - map_h * s) * 0.5
	# Terrain tiles (0 grass, 1 dirt/road, 2 meadow, 3 water, 4 sand, 5 rock).
	for y in game.MAP_H:
		for x in game.MAP_W:
			var t: int = game.terrain[y * game.MAP_W + x]
			var c := Color(0.29, 0.42, 0.2)
			match t:
				1:
					c = Color(0.45, 0.35, 0.22)
				2:
					c = Color(0.22, 0.34, 0.17)
				3:
					c = Color(0.16, 0.34, 0.55)
				4:
					c = Color(0.72, 0.64, 0.42)
				5:
					c = Color(0.45, 0.44, 0.4)
			var px0 := int(ox + x * s)
			var py0 := int(oy + y * s)
			var px1 := int(ox + (x + 1) * s)
			var py1 := int(oy + (y + 1) * s)
			for py in range(py0, maxi(py0 + 1, py1)):
				for px in range(px0, maxi(px0 + 1, px1)):
					if px >= 0 and py >= 0 and px < w and py < h:
						img.set_pixel(px, py, c)
	# Resources.
	for n in game.res_nodes:
		if n.hits <= 0 and n.max_hits > 0:
			continue
		var p := Vector2(ox + n.pos.x / Data.TILE_M * s, oy + n.pos.y / Data.TILE_M * s)
		var c2 := Color(0.85, 0.72, 0.25)
		match n.type:
			"wood":
				c2 = Color(0.12, 0.35, 0.12)
			"stone":
				c2 = Color(0.6, 0.6, 0.58)
			"gold":
				c2 = Color(0.9, 0.75, 0.2)
			"iron":
				c2 = Color(0.7, 0.45, 0.3)
			"coal":
				c2 = Color(0.3, 0.3, 0.32)
		_paint_dot(img, int(p.x), int(p.y), 3, c2)
	# Buildings and units.
	if game != null:
		for e in game.entities:
			if e.dead:
				continue
			var p2 := Vector2(ox + e.pos.x / Data.TILE_M * s, oy + e.pos.y / Data.TILE_M * s)
			var col := Color(0.3, 0.55, 1.0) if e.player == 0 else Color(1.0, 0.32, 0.25)
			if e.kind == "building":
				_paint_rect(img, int(p2.x) - 4, int(p2.y) - 4, 8, 8, col)
			else:
				_paint_dot(img, int(p2.x), int(p2.y), 2, col)
	# Title bar so a human sees it is the game.
	return img

func _paint_dot(img: Image, cx: int, cy: int, r: int, c: Color) -> void:
	for y in range(cy - r, cy + r + 1):
		for x in range(cx - r, cx + r + 1):
			if (x - cx) * (x - cx) + (y - cy) * (y - cy) <= r * r:
				if x >= 0 and y >= 0 and x < img.get_width() and y < img.get_height():
					img.set_pixel(x, y, c)

func _paint_rect(img: Image, x0: int, y0: int, w: int, h: int, c: Color) -> void:
	for y in range(y0, y0 + h):
		for x in range(x0, x0 + w):
			if x >= 0 and y >= 0 and x < img.get_width() and y < img.get_height():
				img.set_pixel(x, y, c)

func _write_bytes(given: String, img: Image) -> String:
	var p := _pick_target(given)
	var dir := p.get_base_dir()
	if dir != "" and not DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_recursive_absolute(dir)
	if img.save_png(p) == OK:
		return p
	var alt := ProjectSettings.globalize_path("user://" + given.get_file())
	if img.save_png(alt) == OK:
		return alt
	return ""

func _run_selftest() -> void:
	# Self-test runs synchronously (about 1 s wall time, ~230 sim seconds).
	# It is guarded by the wall-clock watchdog above, and every loop inside
	# game.tick/selftest has a fixed step cap, so it cannot hang.
	var st := C3SelfTest.new()
	st.bind(game, hud, self)
	var report: Dictionary = st.run()
	var out := _write_text(selftest_path, JSON.stringify(report, "  "))
	if out == "":
		printerr("self-test: could not write ", selftest_path)
		_quit(1)
		return
	print("self-test report: ", out)
	_quit(0 if report.get("passed", false) else 1)

func _run_uitest() -> void:
	# UI user-journey test: same synchronous, watchdog-guarded style.
	var ut := C3UITestScript.new()
	ut.bind(game, hud, self, input_ctl)
	var report: Dictionary = ut.run_only(uitest_only) if uitest_only != "" else ut.run()
	var out := _write_text(uitest_path, JSON.stringify(report, "  "))
	if out == "":
		printerr("ui-test: could not write ", uitest_path)
		_quit(1)
		return
	print("ui-test report: ", out)
	_quit(0 if report.get("passed", false) else 1)

# Sequence output must land in the project (app/shots/...) even when the
# folder does not exist yet: _pick_target skips missing dirs and would
# otherwise fall back to a flat user:// folder.
func _seq_ensure_dir() -> void:
	var d := seq_dir
	if d.begins_with("res://"):
		d = ProjectSettings.globalize_path(d)
	elif not d.is_absolute_path() and not d.begins_with("user://"):
		d = ProjectSettings.globalize_path("res://").get_base_dir().path_join(seq_dir)
	if d != "" and not DirAccess.dir_exists_absolute(d):
		DirAccess.make_dir_recursive_absolute(d)

# Sequence capture: one frame every seq_step sim-seconds until seq_seconds.
# Windowed it grabs the real viewport (a gameplay video in stills); headless
# it saves the CPU map render (a sim-progression timelapse). Bounded by
# seq_max frames so disk can never fill; index lists sim time per frame for
# video assembly (see tools/seq_contact.py + COMMANDS.md ffmpeg line).
func _save_seq_frame() -> void:
	seq_saving = true
	var idx := seq_count
	seq_count += 1
	var img: Image = null
	if not is_headless:
		await RenderingServer.frame_post_draw
		if is_instance_valid(get_viewport()):
			var tex := get_viewport().get_texture()
			if tex != null:
				img = tex.get_image()
	if img == null or img.is_empty() or _is_blank(img):
		img = _render_headless_image(800, 600)
	_write_bytes(seq_dir.path_join("frame_%04d.png" % idx), img)
	seq_saving = false
	if seq_count >= seq_max or game.time_s >= seq_seconds or game.winner != -1:
		seq_done = true
		var index := {"seconds": seq_seconds, "step": seq_step, "frames": seq_count,
			"sim_seconds": game.time_s, "mode": "headless" if is_headless else "window"}
		_write_text(seq_dir.path_join("seq_index.json"), JSON.stringify(index, "  "))
		print("sequence saved: %d frames in %s" % [seq_count, seq_dir])
		_quit(0)

# ------------------------------------------------------------------ cli mode
# Fast, window-less match for quick checks. Runs incrementally (a few hundred
# ticks per frame) so the watchdog stays alive and the process never looks
# hung. Both sides are AI-driven; the report matches --self-test JSON style.
func _run_cli_incremental() -> void:
	if cli_done:
		return
	var step := 1.0 / Data.FPS
	var frame_start := Time.get_ticks_msec()
	var ticks_this_frame := 0
	while cli_ticks_left > 0 and game.winner == -1 and ticks_this_frame < 1500:
		game.tick(step)
		if ai != null:
			ai.tick(step)
		if cli_ai0 != null:
			cli_ai0.tick(step)
		cli_t += step
		cli_ticks_left -= 1
		ticks_this_frame += 1
		# 40 ms per-frame budget: return to the main loop, never block.
		if Time.get_ticks_msec() - frame_start > 40:
			break
		if deadline_ms > 0 and Time.get_ticks_msec() >= deadline_ms - 200:
			printerr("cli: wall-clock limit reached")
			break
	if seq_dir != "" and not seq_done and not cli_done:
		if not seq_ready:
			seq_ready = true
			_seq_ensure_dir()
		# journey timelapse in CLI mode: at most one map frame per real
		# frame (never blocks the budget); cadence kept by sim time
		if cli_t >= seq_next:
			seq_next = cli_t + seq_step
			var cimg := _render_headless_image(800, 450)
			_write_bytes(seq_dir.path_join("frame_%04d.png" % seq_count), cimg)
			seq_count += 1
			if seq_count >= seq_max or cli_t >= seq_seconds:
				seq_done = true
				_write_text(seq_dir.path_join("seq_index.json"), JSON.stringify({"seconds": seq_seconds, "step": seq_step, "frames": seq_count, "sim_seconds": cli_t, "mode": "cli"}, "  "))
				print("sequence saved: %d frames in %s" % [seq_count, seq_dir])
	if cli_ticks_left <= 0 or game.winner != -1 or (deadline_ms > 0 and Time.get_ticks_msec() >= deadline_ms - 200):
		cli_done = true
		_finish_cli()

func _finish_cli() -> void:
	var report := {
		"version": 1,
		"mode": "cli",
		"sim_seconds": cli_t,
		"winner": game.winner,
		"shots_fired": game.stats.shots,
		"kills": game.stats.kills,
		"resources_gathered": game.stats.gathered,
		"player0_units": game.unit_count(0),
		"player1_units": game.unit_count(1),
		"player0_squads": game.squads_of(0).size(),
		"player1_squads": game.squads_of(1).size(),
		"player0_buildings": game.buildings_of(0).size(),
		"player1_buildings": game.buildings_of(1).size(),
	}
	var text := JSON.stringify(report, "  ")
	print(text)
	if cli_path != "":
		var out := _write_text(cli_path, text)
		if out != "":
			print("cli report: ", out)
	_quit(0)
