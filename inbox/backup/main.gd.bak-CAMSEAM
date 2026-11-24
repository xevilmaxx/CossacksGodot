# Entry point: wires the game together and handles the command line options.
#
#   --screenshot <file.png>   draw ~120 frames, save the window picture, exit
#                            (headless: saves a CPU-rendered map picture instead,
#                            so the check never needs a window and never hangs)
#   --self-test  <file.json>  drive the game with scripted input, save a report
#   --self-only <group[,..]>  run only named subset(s); each group restores the
#                             post-setup snapshot (diagnostics, not a gate)
#   --self-snapshot <file.json>  load a pre-baked post-setup snapshot instead of
#                             regenerating the map (only with --self-only)
#   --dump-self-base <file.json> generate that snapshot once (full mapgen), exit
#   --check-self-base <file.json> load a snapshot into a fresh game, print parity
#   --cli        [file.json]  fast headless match (no window) for quick tests
#   --cli-seconds <n>         how many simulated seconds the CLI match runs (default 60)
#   --cli-frame-ms <n>        CLI per-frame tick budget in ms (default 40); step
#                             size/order unchanged, no sim semantics change
#   --cli-ticks-per-frame <n> CLI max fixed ticks per frame (default 1500)
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
const C3TestBridgeScript = preload("res://scripts/testbridge.gd")
const C3MenuScript = preload("res://scripts/menu.gd")

var game: C3Game
# V7-50: relaxed from static C3World / C3Camera / C3Input. A literal `Node`
# type would fail GDScript static analysis at the ~25 existing world.* /
# camera.* member accesses (bind, view_scale, fog_*, set_zoom_target, ...);
# untyped (Variant) is the relaxed superset that accepts BOTH the legacy 2D
# scripts and the dynamically loaded Node3D / Camera3D factories below.
# Every legacy 2D constructor and call site is left byte-for-byte unchanged.
var world
var camera
var hud: C3HUD
var input_ctl
var ais: Array[C3AI] = []   # one AI brain per participating AI player
var acc := 0.0
var speed := 1.0
var frame := 0
var screenshot_path := ""
var screenshot_frames := 120
var screenshot_done := false
var screenshot_focus := "start"   # gameplay.screenshot_focus: start | relief
# W4-1 startup zoom: donor docreate.inc:82 clamps the start camera to max
# distance (SphereHeight 58 -> ~0.345 in port zoom units). 0.75 is the port
# compromise: 2.67x wider than the old 2.0 default, still inside 0.345..2.9.
var start_zoom := 0.75            # camera.start_zoom
var test_api_port := 0
var test_bridge: C3TestBridge = null
var selftest_path := ""
var selftest_only := ""
# W26 (T3 Scenario B): one post-setup snapshot, reused by --self-only subsets.
var selftest_baseline: Dictionary = {}
# W5-2: disk-backed pre-baked baseline. --dump-self-base writes it once; a
# --self-only run with --self-snapshot loads it instead of running mapgen.
var self_snapshot_path := ""
var self_base_dump_path := ""
var self_base_check_path := ""
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
# W26: headless-only CLI frame budget. Defaults are the historical 40 ms / 1500
# ticks. Raising them changes only how many FIXED 1/FPS ticks run per frame;
# tick size, tick order and all simulation semantics are untouched.
var cli_frame_ms := 40.0
var cli_ticks_cap := 1500
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
# V7-50 PORT ADDITION: additive renderer switch, default stays 2D. No donor
# key exists (V71 mechanics inventory :171,:176) — this is a port-side flag.
# NOTE: do not put the literal 3d value on this line; t_render_mode.gd checks
# that the declared default is unambiguously 2D.
var render_mode := "2d"

var battle_requested := false
var config_path := ""
var dump_config := false
var cfg = null
var is_headless := false
var menu = null
var pending_cfg: Dictionary = {}
var bench_mode := false
var bench_t := 0.0
var bench_frames := 0
var bench_sim_ms := 0.0
var bench_start_ms := 0
var dbg_n := 0
var dbg_tick := 0.0
var dbg_ai := 0.0
var dbg_sync := 0.0
var dbg_steps := 0
var dbg_res := 0
var dbg_bld := 0
var dbg_unit := 0
var dbg_fx := 0
var menu_overlay: CanvasLayer = null
var loading_layer: CanvasLayer = null
var loading_bar: ProgressBar = null
var loading_stage: Label = null
var loading_pct: Label = null
var loading_active := false
var loading_gen := 0
var end_panel: PanelContainer = null
var last_cfg: Dictionary = {}
var seed_arg := -1
var seed_random := false
var dump_path := ""
var journey_cam_t := 0.0
var dbg_journey := 0   # V7-70 E19 probe: first two journey camera updates
var _base_start_res: Dictionary = {}  # cached config defaults for start-stock scaling
var autosave_acc := 0.0
# V7-70 (P0 G1): windowed 3D screenshot render target. The root window
# backbuffer reads blank under gl_compatibility, so the 3D capture goes through
# an explicit SubViewport texture (the same pattern as world.gd:1894-1993).
var capture_view3d: SubViewport = null

func _ready() -> void:
	started_ms = Time.get_ticks_msec()
	add_to_group("c3_main")
	_parse_args(OS.get_cmdline_args())
	_parse_args(OS.get_cmdline_user_args())
	is_headless = DisplayServer.get_name() == "headless"

	cfg = C3ConfigScript.new()
	cfg.load_all(config_path)
	cfg.apply()
	screenshot_focus = cfg.text("gameplay.screenshot_focus", "start")
	start_zoom = cfg.num("camera.start_zoom", 0.75)
	# V7-50 PORT ADDITION: new additive key; 2D is the default when absent.
	render_mode = str(cfg.text("gameplay.render_mode", "2d")).to_lower()
	Data.RENDER_MODE = render_mode
	if seed_random:
		Data.RANDOM_SEED = int(randi())
	elif seed_arg >= 0:
		Data.RANDOM_SEED = seed_arg
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

	if test_api_port > 0:
		if not is_headless:
			get_window().size = Vector2i(Data.WINDOW_WIDTH, Data.WINDOW_HEIGHT)
		test_bridge = C3TestBridgeScript.new(test_api_port)
		add_child(test_bridge)

	var hard_limit := limit_s if limit_s > 0.0 else 120.0
	if bench_mode or screenshot_path != "" or test_api_port > 0 or selftest_path != "" or uitest_path != "" or seq_dir != "" or journey_mode or cli_mode:
		deadline_ms = started_ms + int(hard_limit * 1000.0)
		watchdog = hard_limit
	else:
		deadline_ms = 0
		watchdog = 0.0

	if cli_mode:
		_setup_cli_only()
		return

	if dump_path != "":
		_dump_map()
		return

	if self_base_dump_path != "":
		_dump_self_base()
		return

	if self_base_check_path != "":
		_check_self_base()
		return

	# Test / capture modes skip the menu so they never wait for input.
	if bench_mode or screenshot_path != "" or selftest_path != "" or uitest_path != "" or seq_dir != "" or battle_requested or journey_mode:
		_setup_full_game()
		if bench_mode:
			Data.MINIMAP_INTERVAL = 9999.0
			Data.FOG_INTERVAL = 9999.0
			for pi in 2:
				var home: Vector2 = game._start_positions()[pi]
				for i in 300:
					var sid: String = ["pikeman", "serdiuk", "archer", "cossack"][i % 4]
					game.spawn(sid, pi, home + Vector2((i % 20) * 1.2 - 12, (i / 20) * 1.2 - 12))
			bench_t = 0.0
			bench_start_ms = Time.get_ticks_msec()
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
	last_cfg = cfg
	_apply_menu_cfg(cfg)
	if is_headless:
		# Headless tests / captures stay synchronous so scripted journeys
		# (uitest menu_shell) see a ready game on the next line.
		_setup_full_game()
		_apply_menu_post(cfg)
		if menu != null and is_instance_valid(menu):
			menu.queue_free()
			menu = null
		return
	# Interactive: staged load with a progress bar so the Start click shows
	# how much is left until playing. Fire-and-forget: the coroutine owns it.
	_do_async_load(cfg)

func _apply_menu_cfg(cfg: Dictionary) -> void:
	var n0 := str(cfg.get("nation0", "ukr"))
	var n1 := str(cfg.get("nation1", "rus"))
	# T-MENU-ROSTER / T-MENU-MORE-PLAYERS: the skirmish lobby emits a full
	# per-slot roster. When present it is authoritative (2..12 slots, explicit
	# nation / team / control pick); otherwise the legacy path below keeps old
	# callers (uitest / selftest / saved loads) byte-stable.
	var roster: Array = cfg.get("players", []) if cfg.get("players") is Array else []
	if not roster.is_empty():
		_apply_roster_cfg(roster, n0, n1)
	else:
		_apply_legacy_roster_cfg(cfg, n0, n1)
	# PORT-SIM FP-1 hand-off + T-MENU-ROSTER DEEP: resolve the full donor option
	# struct onto Data statics. Legacy keys stay as fallbacks so old callers are
	# byte-stable; unknown donor ids fall back to the donor default.
	var eff_seed := int(cfg.get("seed", Data.RANDOM_SEED))
	var rng := RandomNumberGenerator.new()
	rng.seed = eff_seed

	# Map shape: donor ids -> nearest generator mask family (see DONOR_MAP_SHAPES
	# and docs/DONOR_OPTIONS_GAPS.md). "random" picks a real generator family.
	var shape := _donor_cfg(cfg, ["terraintype", "terrain_type", "map_type"],
		Data.DONOR_MAP_SHAPES.keys(), "land")
	Data.DONOR_MAP_SHAPE = shape
	var gen := str(Data.DONOR_MAP_SHAPES[shape].get("generator", "land"))
	if gen == "random":
		var gens := Data.MAP_TYPES.keys()
		gen = str(gens[rng.randi() % gens.size()])
	Data.MAP_TYPE = gen

	# Relief: donor ids -> the 3 sim relief tiers; legacy plains/hills/mountains
	# pass straight through. "random" picks a supported tier from the seed.
	var rdon := str(cfg.get("relieftype", cfg.get("relief", "plain")))
	var rg := ""
	if Data.DONOR_RELIEF.has(rdon):
		rg = str(Data.DONOR_RELIEF[rdon].get("relief", "plains"))
	elif ["plains", "hills", "mountains"].has(rdon):
		rg = rdon  # legacy caller
	else:
		rdon = "plain"
		rg = "plains"
	Data.DONOR_RELIEF_TYPE = rdon
	if rg == "random":
		var tiers := ["plains", "hills", "mountains"]
		rg = str(tiers[rng.randi() % tiers.size()])
	Data.RELIEF = rg

	Data.BIOME = str(cfg.get("season", cfg.get("biome", "summer")))
	# Minerals: donor 4th option "Random" resolves to low/med/rich from the seed.
	var mines := _donor_cfg(cfg, ["resourcemines", "richness"], Data.DONOR_MINERALS, "med")
	Data.DONOR_RES_MINES = mines
	if mines == "random":
		var pool := ["low", "med", "rich"]
		mines = str(pool[rng.randi() % pool.size()])
	Data.RICHNESS = mines

	# Starting resources: donor tiers scale the config's base stock. "Random"
	# resolves to one of the named tiers from the seed.
	var rs := _donor_cfg(cfg, ["resourcestart", "start_resources"],
		Data.DONOR_RES_START_MULT.keys(), "normal")
	Data.DONOR_RES_START = rs
	if rs == "random":
		var rs_pool := ["normal", "rich", "thousands", "millions"]
		rs = str(rs_pool[rng.randi() % rs_pool.size()])
		Data.DONOR_RES_START = rs
	if _base_start_res.is_empty():
		_base_start_res = Data.START_RESOURCES.duplicate()
	var mult := float(Data.DONOR_RES_START_MULT.get(rs, 1.0))
	var stock := {}
	for r in _base_start_res.keys():
		stock[r] = float(_base_start_res[r]) * mult
	Data.START_RESOURCES = stock

	Data.BALLOON_MODE = _donor_cfg(cfg, ["balloon"], Data.DONOR_BALLOON, "default")
	Data.CANNON_MODE = _donor_cfg(cfg, ["cannons"], Data.DONOR_CANNONS, "default")
	Data.CENTURY18_MODE = _donor_cfg(cfg, ["century18"], Data.DONOR_CENTURY18, "default")
	Data.CAPTURE_MODE = _donor_cfg(cfg, ["capture"], Data.DONOR_CAPTURE, "default")
	Data.MARKET_DIP_MODE = _donor_cfg(cfg, ["marketdip"], Data.DONOR_MARKET_DIP, "default")
	Data.POP_LIMIT = clampi(int(cfg.get("limit", Data.POP_LIMIT)), 0, 500)
	Data.PEACE_TIME = clampf(float(cfg.get("peacetime", Data.PEACE_TIME)), 0.0, 240.0 * 60.0)
	Data.GAME_SPEED = _donor_cfg(cfg, ["gamespeed"], Data.DONOR_GAME_SPEED.keys(), "normal")
	Data.AUTOSAVE_MODE = _donor_cfg(cfg, ["autosave"], Data.DONOR_AUTOSAVE, "off")
	Data.ADVISER_MODE = _donor_cfg(cfg, ["adviserassistant"], Data.DONOR_ADVISER, "default")
	Data.ALLIES_MODE = _donor_cfg(cfg, ["allies"], ["default", "nearby"], "default")
	# Peasant conversion follows the donor capture rule.
	Data.CAPTURE_ENABLED = Data.CAPTURE_MODE == "default"
	# Game speed is wired only when the command line did not force one.
	if speed == 1.0:
		speed = clampf(float(Data.DONOR_GAME_SPEED.get(Data.GAME_SPEED, 1.0)), 0.1, 8.0)
	autosave_acc = 0.0

	Data.START_OPTION = str(cfg.get("startingunits", cfg.get("start_option", "default")))
	if cfg.has("difficulty"):
		Data.AI_DIFFICULTY = str(cfg.get("difficulty", "normal"))
	if cfg.has("mapsize") or cfg.has("map_size"):
		var sz := int(cfg.get("mapsize", cfg.get("map_size", 320)))
		Data.MAP_W = sz
		Data.MAP_H = sz
	if cfg.has("seed"):
		Data.RANDOM_SEED = eff_seed
	if not battle_requested:
		start_mode = str(cfg.get("mode", "skirmish"))

# T-MENU-ROSTER: map the lobby's [{nation, team, ai, name}, ...] onto the Data
# statics the sim reads. Team -1 is free-for-all; game.gd's _is_ally ignores
# it, so an FFA lobby never accidentally turns into one big alliance.
func _apply_roster_cfg(roster: Array, n0: String, n1: String) -> void:
	var count := clampi(roster.size(), 2, Data.MAX_PLAYERS)
	var nations := []
	var names := []
	var teams := []
	var ai := []
	var ai_diff := []
	# W5-2 / R06 C1: the raw per-slot donor id is authoritative. AI_DIFFICULTIES
	# is the five-tier sim whitelist; "none" is the donor's human-slot marker and
	# is stored verbatim so the array stays index-aligned with PLAYER_AI/NATIONS.
	var allowed: Array = C3ConfigScript.AI_DIFFICULTIES.duplicate()
	allowed.append("none")
	for i in count:
		var entry: Dictionary = roster[i] if roster[i] is Dictionary else {}
		var fallback := n0 if i == 0 else n1
		var sid := str(entry.get("nation", fallback))
		if not Data.NATIONS.has(sid):
			sid = fallback
		nations.append(sid)
		names.append(str(entry.get("name", _menu_nation_name(sid, i))))
		teams.append(int(entry.get("team", -1)))
		ai.append(bool(entry.get("ai", i > 0)))
		# Prefer the menu's "ai_difficulty" (raw donor id) over the legacy
		# collapsed "difficulty" key so veryhard/impossible reach ai.gd (W5-1).
		# Old configs without the new key fall back byte-identically to normal.
		var mapped := str(entry.get("ai_difficulty", entry.get("difficulty", "normal")))
		if not allowed.has(mapped):
			mapped = "normal"
		ai_diff.append(mapped)
	Data.PLAYER_COUNT = count
	Data.PLAYER_NATIONS = nations
	Data.PLAYER_NAMES = names
	Data.TEAMS = teams
	Data.PLAYER_AI = ai
	Data.PLAYER_AI_DIFFICULTY = ai_diff

# Legacy 1..3 opponents path: no PLAYER_AI is published, so game.gd falls back
# to slot 0 human / the rest AI, exactly as before.
func _apply_legacy_roster_cfg(cfg: Dictionary, n0: String, n1: String) -> void:
	var opponents := clampi(int(cfg.get("opponents", 1)), 1, 3)
	Data.PLAYER_COUNT = opponents + 1
	Data.TEAMS = [0, 0, 1] if str(cfg.get("teams", "ffa")) == "2v1" else []
	Data.PLAYER_AI = []
	Data.PLAYER_AI_DIFFICULTY = []
	var nations := [n0, n1]
	if opponents > 1:
		for code in Data.NATIONS.keys():
			if nations.size() >= opponents + 1:
				break
			var sid := str(code)
			if not nations.has(sid):
				nations.append(sid)
	Data.PLAYER_NATIONS = nations
	Data.PLAYER_NAMES = [_menu_nation_name(nations[0], 0), _menu_nation_name(nations[1], 1)]
	for i in range(2, nations.size()):
		Data.PLAYER_NAMES.append(_menu_nation_name(nations[i], i))

func _apply_menu_post(cfg: Dictionary) -> void:
	if game == null:
		return
	if cfg.has("load_save"):
		var pth := str(cfg.get("load_save", ""))
		if pth != "" and FileAccess.file_exists(pth):
			var d = JSON.parse_string(FileAccess.get_file_as_string(pth))
			if d is Dictionary:
				game.deserialize(d)
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
		if hud != null and is_instance_valid(hud):
			hud.refresh_objectives()

# ---------------------------------------------------------------- loading bar
# Shown the moment Start is clicked; updated between mapgen stages so the
# player sees how much is left until the match is playable.
func _show_loading() -> void:
	_hide_loading()
	loading_layer = CanvasLayer.new()
	loading_layer.layer = 30
	add_child(loading_layer)
	var dim := ColorRect.new()
	dim.color = Color(0.03, 0.03, 0.03, 0.85)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	loading_layer.add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	loading_layer.add_child(center)
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", C3ConfigScript.ui_panel_style())
	center.add_child(card)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 10)
	vb.custom_minimum_size = Vector2(460, 0)
	card.add_child(vb)
	var title := Label.new()
	title.text = "Loading battle..."
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(1, 0.9, 0.5))
	vb.add_child(title)
	loading_stage = Label.new()
	loading_stage.text = "Preparing..."
	loading_stage.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	loading_stage.add_theme_font_size_override("font_size", 14)
	loading_stage.add_theme_color_override("font_color", Color(0.85, 0.82, 0.72))
	vb.add_child(loading_stage)
	loading_bar = ProgressBar.new()
	loading_bar.min_value = 0.0
	loading_bar.max_value = 100.0
	loading_bar.value = 0.0
	loading_bar.show_percentage = false
	loading_bar.custom_minimum_size = Vector2(420, 22)
	vb.add_child(loading_bar)
	loading_pct = Label.new()
	loading_pct.text = "0%"
	loading_pct.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	loading_pct.add_theme_font_size_override("font_size", 14)
	loading_pct.add_theme_color_override("font_color", Color(1, 0.95, 0.8))
	vb.add_child(loading_pct)

func _set_loading(frac: float, stage: String) -> void:
	var f := clampf(frac, 0.0, 1.0)
	if loading_bar != null and is_instance_valid(loading_bar):
		loading_bar.value = f * 100.0
	if loading_stage != null and is_instance_valid(loading_stage):
		loading_stage.text = stage
	if loading_pct != null and is_instance_valid(loading_pct):
		loading_pct.text = "%d%%  %s" % [int(round(f * 100.0)), stage]

func _hide_loading() -> void:
	loading_active = false
	if loading_layer != null and is_instance_valid(loading_layer):
		loading_layer.queue_free()
	loading_layer = null
	loading_bar = null
	loading_stage = null
	loading_pct = null

func _loading_tick(frac: float, stage: String, gen: int) -> bool:
	# Returns false if this load was superseded (a newer Start click won).
	if gen != loading_gen:
		return false
	_set_loading(frac, stage)
	await get_tree().process_frame
	await get_tree().process_frame
	return gen == loading_gen

func _do_async_load(cfg: Dictionary) -> void:
	loading_gen += 1
	var gen := loading_gen
	loading_active = true
	# Hide the menu at once so a second Start click cannot queue.
	if menu != null and is_instance_valid(menu):
		menu.queue_free()
		menu = null
	_show_loading()
	_set_loading(0.02, "Preparing...")
	await get_tree().process_frame
	await get_tree().process_frame
	if gen != loading_gen:
		return
	if not is_headless:
		get_window().size = Vector2i(Data.WINDOW_WIDTH, Data.WINDOW_HEIGHT)
		if Data.FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		DisplayServer.window_set_vsync_mode(
			DisplayServer.VSYNC_ENABLED if Data.VSYNC else DisplayServer.VSYNC_DISABLED)
	# --- sim stages (each awaits so the bar repaints between them) ---
	game = C3Game.new()
	add_child(game)
	if not await _loading_tick(0.06, "Starting simulation...", gen):
		return
	game.setup_begin(start_mode)
	if not await _loading_tick(0.14, "Shaping land and water...", gen):
		return
	game._gen_base()
	if not await _loading_tick(0.34, "Growing forests...", gen):
		return
	game._gen_forests()
	if not await _loading_tick(0.52, "Placing stone and mines...", gen):
		return
	game._gen_resources()
	if not await _loading_tick(0.66, "Raising towns...", gen):
		return
	game._gen_finish()
	if not await _loading_tick(0.76, "Painting terrain...", gen):
		return
	game._assign_tileblocks()
	if not await _loading_tick(0.86, "Mustering armies...", gen):
		return
	game.setup_spawns()
	game.game_over.connect(func(w: int) -> void: _on_game_over(w))
	_apply_menu_post_loadsave(cfg)
	if not await _loading_tick(0.90, "Loading art...", gen):
		return
	if render_mode == "3d":
		world = make_world3d()
		world.bind(game)
		add_child(world)
	else:
		world = C3WorldScript.new()
		world.bind(game)
		add_child(world)
	if not await _loading_tick(0.94, "Building interface...", gen):
		return
	if render_mode == "3d":
		camera = make_camera3d()
		add_child(camera)
		camera.bind(game, world.view_scale)  # camera3d.gd contract: bind(game, view_scale)
	else:
		camera = C3CameraScript.new()
		add_child(camera)
		camera.bind(world)
	var homes := game.buildings_of(0)
	if render_mode == "3d":
		# camera3d.gd's set_zoom_target(target, immediate, anchor) differs from
		# the 2D camera's 3-arg call; keep the 2D call verbatim in the else leg.
		camera.set_zoom_target(start_zoom, true)
		var focus3: Vector2 = homes[0].pos if not homes.is_empty() \
			else Vector2(game.MAP_W, game.MAP_H) * 0.5 * Data.TILE_M
		camera.set("_target", focus3)  # camera3d.gd:90 _target is sim metres
		camera.clamp_pos()
		_center_camera3d_target()  # V7-70: sim map-origin -> centred 3D metres
	else:
		camera.set_zoom_target(start_zoom, Vector2.INF, true)  # W4-1: wide start
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
	if render_mode == "3d":
		_apply_3d_hooks(hud, camera, input_ctl)  # V7-53 HUD + V7-52 picking hooks
	var homes2 := game.buildings_of(0)
	if not homes2.is_empty():
		input_ctl._set_selection([homes2[0]])
	_create_ai_brains(journey_mode)
	audio = C3AudioScript.new()
	add_child(audio)
	var can_play := not is_headless
	if can_play:
		audio.start_music(str(game.players[0].get("nation", "ukr")))
	audio.set_meta("can_play", can_play)
	_apply_menu_post_objectives(cfg)
	if not await _loading_tick(1.0, "Ready!", gen):
		return
	_hide_loading()

func _apply_menu_post_loadsave(cfg: Dictionary) -> void:
	if game == null:
		return
	if cfg.has("load_save"):
		var pth := str(cfg.get("load_save", ""))
		if pth != "" and FileAccess.file_exists(pth):
			var d = JSON.parse_string(FileAccess.get_file_as_string(pth))
			if d is Dictionary:
				game.deserialize(d)

func _apply_menu_post_objectives(cfg: Dictionary) -> void:
	if game == null:
		return
	var descr := str(cfg.get("descr", ""))
	var mission := str(cfg.get("mission", ""))
	if descr != "" or mission != "":
		var objs := ["Destroy all enemy buildings"]
		if mission != "":
			objs.append("Mission: %s" % mission)
		if descr != "":
			objs.append(descr)
		game.set_objectives(objs)
		if hud != null and is_instance_valid(hud):
			hud.refresh_objectives()

# First present cfg key that holds a valid donor id wins; unknown values fall
# back to the donor default instead of reaching the sim.
func _donor_cfg(cfg: Dictionary, keys: Array, allowed: Array, default: String) -> String:
	for k in keys:
		if cfg.has(k):
			var v := str(cfg.get(k, default))
			if allowed.has(v):
				return v
			break
	return default

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

# One brain per AI player. CLI and journey modes also drive player 0, which the
# sim always creates as a human slot, so those modes opt the first slot in too.
func _create_ai_brains(include_player0: bool) -> void:
	ais.clear()
	if game == null:
		return
	for p in game.players:
		var idx := int(p.get("index", -1))
		if idx < 0:
			continue
		var drive_human := include_player0 and idx == 0
		if not drive_human and not bool(p.get("is_ai", false)):
			continue
		ais.append(C3AIScript.new(game, idx))

func _setup_cli_only() -> void:
	# Fast headless match: simulation only, no rendering, no audio, no window.
	game = C3Game.new()
	add_child(game)
	game.setup(start_mode)
	_create_ai_brains(true)
	cli_ticks_left = int(cli_seconds * Data.FPS)
	cli_t = 0.0
	cli_done = false

func _dump_map() -> void:
	# Headless map dump for the L6 quality scan: sim only, no world/hud/audio.
	game = C3Game.new()
	add_child(game)
	game.setup(start_mode)
	var res: Array = []
	for n in game.res_nodes:
		res.append({"t": str(n.type), "x": float(n.pos.x), "y": float(n.pos.y),
			"hits": int(n.hits), "r": float(n.radius)})
	var starts: Array = []
	for s in game.map_starts:
		starts.append({"x": float(s.x), "y": float(s.y)})
	var zones: Array = []
	for z in game.cluster_zones:
		var zd: Dictionary = z
		zones.append({"x": float(zd.pos.x), "y": float(zd.pos.y), "r": float(zd.r)})
	var dump := {
		"seed": Data.RANDOM_SEED, "map_w": game.MAP_W, "map_h": game.MAP_H,
		"terrain": Marshalls.raw_to_base64(game.terrain),
		"blocked": Marshalls.raw_to_base64(game.blocked),
		"height": Marshalls.raw_to_base64(game.height.to_byte_array()),
		"tileblock": Marshalls.raw_to_base64(game.tileblock),
		"starts": starts, "clusters": zones, "res": res, "meta": game.map_meta,
	}
	var out := _write_text(dump_path, JSON.stringify(dump))
	if out == "":
		printerr("dump-map: could not write ", dump_path)
		_quit(1)
		return
	print("map dump: ", out)
	_quit(0)

# W5-2: write ONE post-setup snapshot (full mapgen paid once). Later
# --self-only processes load it via _load_self_base() and skip mapgen entirely.
func _dump_self_base() -> void:
	game = C3Game.new()
	add_child(game)
	game.setup(start_mode)
	# var_to_str preserves Variant types exactly (JSON.parse_string turns every
	# number into a float and Rect2 into a String, which corrupts entity ids and
	# building block_rects on load). The inner "base" blob is game.serialize()'s
	# own base64 form, which deserialize() expects verbatim.
	var dump := {
		"format": "w52-self-base-2", "seed": int(Data.RANDOM_SEED),
		"map_w": int(Data.MAP_W), "map_h": int(Data.MAP_H),
		"base": game.serialize(),
		"terrain": game.terrain, "blocked": game.blocked, "height": game.height,
		"tileblock": game.tileblock, "mine_mask": game.mine_mask,
		"starts": game.map_starts, "zones": game.cluster_zones, "meta": game.map_meta,
		"rng_state": game.rng.get("state"), "gen_rng_state": game.gen_rng.get("state"),
		"sow_t": game.sow_t, "ai_enabled": Data.AI_ENABLED,
	}
	var out := _write_text(self_base_dump_path, var_to_str(dump))
	if out == "":
		printerr("dump-self-base: could not write ", self_base_dump_path)
		_quit(1)
		return
	print("self-base dump: ", out)
	# Round-trip proof: load into a second game and require exact parity with
	# the just-generated world before declaring the snapshot usable.
	var probe := C3Game.new()
	add_child(probe)
	var ok := _load_self_base(probe, out)
	print("SELF-SNAPSHOT dump round-trip: ", "OK" if ok else "MISMATCH")
	_quit(0 if ok else 1)

func _check_self_base() -> void:
	var probe := C3Game.new()
	add_child(probe)
	var ok := _load_self_base(probe, self_base_check_path)
	print("SELF-SNAPSHOT check: ", "OK" if ok else "MISMATCH")
	_quit(0 if ok else 1)

# Numeric types survive JSON as floats, so compare recursively with numeric
# coercion (ints/floats are equal by value, everything else by string form).
func _same_json(a: Variant, b: Variant) -> bool:
	if a is Dictionary and b is Dictionary:
		if (a as Dictionary).size() != (b as Dictionary).size():
			return false
		for k in (a as Dictionary):
			if not (b as Dictionary).has(k) or not _same_json((a as Dictionary)[k], (b as Dictionary)[k]):
				return false
		return true
	if a is Array and b is Array:
		if (a as Array).size() != (b as Array).size():
			return false
		for i in (a as Array).size():
			if not _same_json((a as Array)[i], (b as Array)[i]):
				return false
		return true
	if (a is int or a is float) and (b is int or b is float):
		# Sim positions are float32 (Vector2); JSON keeps float64 text, so the
		# same Vector2 can print as two distinct float64 values. Compare after
		# quantising both through float32 - that is the sim's actual precision.
		var q := PackedFloat32Array()
		q.append(float(a))
		q.append(float(b))
		return q[0] == q[1]
	return str(a) == str(b)

func _json_rect(v: Variant) -> Rect2:
	if v is Rect2:
		return v
	if v is String:
		var s := str(v)
		var p0 := s.find("(")
		var p1 := s.find(")", p0 + 1)
		var p2 := s.find("(", p1 + 1)
		var p3 := s.find(")", p2 + 1)
		if p0 >= 0 and p1 > p0 and p2 > p1 and p3 > p2:
			var a := s.substr(p0 + 1, p1 - p0 - 1).split(",")
			var b := s.substr(p2 + 1, p3 - p2 - 1).split(",")
			for i in a.size():
				a[i] = str(a[i]).strip_edges()
			for i in b.size():
				b[i] = str(b[i]).strip_edges()
			if a.size() == 2 and b.size() == 2 and a[0].is_valid_float() and a[1].is_valid_float() \
				and b[0].is_valid_float() and b[1].is_valid_float():
				return Rect2(float(a[0]), float(a[1]), float(b[0]), float(b[1]))
	return Rect2()

func _json_diff(a: Variant, b: Variant, path: String) -> String:
	if a is Dictionary and b is Dictionary:
		if (a as Dictionary).size() != (b as Dictionary).size():
			return path + ".size " + str((a as Dictionary).size()) + "!=" + str((b as Dictionary).size())
		for k in (a as Dictionary):
			var s := _json_diff((a as Dictionary)[k], (b as Dictionary)[k], path + "." + str(k))
			if s != "":
				return s
		return ""
	if a is Array and b is Array:
		if (a as Array).size() != (b as Array).size():
			return path + ".size " + str((a as Array).size()) + "!=" + str((b as Array).size())
		for i in (a as Array).size():
			var s := _json_diff((a as Array)[i], (b as Array)[i], path + "[" + str(i) + "]")
			if s != "":
				return s
		return ""
	if (a is int or a is float) and (b is int or b is float):
		var q := PackedFloat32Array()
		q.append(float(a))
		q.append(float(b))
		return "" if q[0] == q[1] else path + " " + str(b) + "->" + str(a)
	return "" if str(a) == str(b) else path + " " + str(b).substr(0, 100) + "->" + str(a).substr(0, 100)

# W5-2: restore a pre-baked snapshot into a FRESH C3Game without running
# mapgen. The canonical deserializer restores entities/players/stats; it is
# called with a 1x1 stub map so its own _assign_tileblocks() pass touches one
# cell, then the real arrays are installed verbatim from the Variant dump. Returns
# false (caller falls back to full setup) on any validation or parity failure.
func _load_self_base(g: C3Game, path: String) -> bool:
	var resolved := _pick_target(path)
	var txt := FileAccess.get_file_as_string(resolved)
	if txt == "":
		printerr("self-snapshot: cannot read ", resolved)
		return false
	var parsed = str_to_var(txt)
	if not parsed is Dictionary:
		printerr("self-snapshot: not a Variant snapshot in ", path)
		return false
	var d: Dictionary = parsed
	if str(d.get("format", "")) != "w52-self-base-2" or not d.has("base"):
		printerr("self-snapshot: bad format in ", path)
		return false
	var bs = d["base"]
	if not bs is Dictionary:
		return false
	var b: Dictionary = bs
	if int(b.get("version", 0)) not in [3, 4]:
		return false
	if int(b.get("seed", -1)) != int(Data.RANDOM_SEED):
		printerr("self-snapshot: seed mismatch (dump ", b.get("seed"),
			", current ", Data.RANDOM_SEED, ")")
		return false
	if int(b.get("map_w", -1)) != int(Data.MAP_W) or int(b.get("map_h", -1)) != int(Data.MAP_H):
		printerr("self-snapshot: map-size mismatch (dump ", b.get("map_w"), "x",
			b.get("map_h"), ", current ", Data.MAP_W, "x", Data.MAP_H, ")")
		return false
	# A 1x1 stub keeps the canonical deserializer's own tile pass trivial while
	# avoiding empty-PackedByteArray encoding warnings. Real arrays are set below.
	var stub := PackedByteArray()
	stub.resize(1)
	var stub_h := PackedByteArray()
	stub_h.resize(4)
	var thin := b.duplicate(true)
	thin["map_w"] = 1
	thin["map_h"] = 1
	thin["terrain"] = Marshalls.raw_to_base64(stub)
	thin["blocked"] = Marshalls.raw_to_base64(stub)
	thin["height"] = Marshalls.raw_to_base64(stub_h)
	if not g.deserialize(thin):
		printerr("self-snapshot: deserialize failed")
		return false
	g.MAP_W = int(b.map_w)
	g.MAP_H = int(b.map_h)
	g.terrain = Marshalls.base64_to_raw(str(b.terrain))
	g.blocked = Marshalls.base64_to_raw(str(b.blocked))
	var raw := Marshalls.base64_to_raw(str(b.height))
	g.height.resize(g.MAP_W * g.MAP_H)
	for i in mini(g.height.size(), int(raw.size() / 4)):
		g.height[i] = raw.decode_float(i * 4)
	if d.get("tileblock") is PackedByteArray:
		g.tileblock = d.tileblock
	if d.get("mine_mask") is PackedByteArray:
		g.mine_mask = d.mine_mask
	var sarr = d.get("starts", [])
	if sarr is Array:
		g.map_starts = (sarr as Array).duplicate(true)
	var zarr = d.get("zones", [])
	if zarr is Array:
		g.cluster_zones = (zarr as Array).duplicate(true)
	var meta = d.get("meta", {})
	g.map_meta = meta.duplicate(true) if meta is Dictionary else {}
	g.nav.configure(g.MAP_W, g.MAP_H, g.TILE)
	g.nav_version += 1
	Data.load_extra_anim_index()
	if d.has("rng_state"):
		g.rng.set("state", int(d.rng_state))
	if d.has("gen_rng_state"):
		g.gen_rng.set("state", int(d.gen_rng_state))
	Data.AI_ENABLED = bool(d.get("ai_enabled", true))
	g.sow_t = float(d.get("sow_t", 0.0))
	# Defensive: the Variant snapshot preserves Rect2 natively; this only
	# normalises any legacy string-form block_rect from an older dump.
	for e in g.entities:
		if e.has("block_rect"):
			e["block_rect"] = _json_rect(e.block_rect)
	g.events.clear()
	g.projectiles.clear()
	g.corpses.clear()
	g.rubble.clear()
	# Parity gate: refuse the fast path unless the loaded game reproduces every
	# serialized field and the non-serialized map arrays byte-for-byte.
	var now := g.serialize()
	var same := _same_json(now, b)
	if not same:
		var dpath := _json_diff(now, b, "root")
		printerr("self-snapshot: first difference at ", dpath)
	if d.get("tileblock") is PackedByteArray and g.tileblock != d.tileblock:
		same = false
	if d.get("mine_mask") is PackedByteArray and g.mine_mask != d.mine_mask:
		same = false
	if g.map_starts.size() != (sarr as Array).size():
		same = false
	if g.cluster_zones.size() != (zarr as Array).size():
		same = false
	print("SELF-SNAPSHOT fast load parity: ", "OK" if same else "MISMATCH",
		" (", g.MAP_W, "x", g.MAP_H, ", ", g.entities.size(), " ents, seed ", b.seed, ")")
	return same

# --- V7-50 render-mode seam ---------------------------------------------------
# PORT ADDITION: no donor "render mode" key exists (V71 :171,:176). The 3D
# modules are loaded dynamically (no class_name: .godot's global-class cache is
# only rebuilt by the serialized runner), so these factories are the single
# construction point for the 3D world and camera. Both legacy C3WorldScript /
# C3CameraScript constructors remain in the 2D branches below, unchanged.

func make_world3d() -> Node:
	var script = load("res://scripts/world3d.gd")
	if script == null:
		push_error("V7-50: res://scripts/world3d.gd is missing")
		return null
	var node = script.new()
	if node == null:
		push_error("V7-50: world3d.gd.new() failed")
	return node


func make_camera3d() -> Node:
	var script = load("res://scripts/camera3d.gd")
	if script == null:
		push_error("V7-50: res://scripts/camera3d.gd is missing")
		return null
	var node = script.new()
	if node == null:
		push_error("V7-50: camera3d.gd.new() failed")
	return node


# V7-52 / V7-53 documented hooks. Called only from the 3D branches, after the
# ordinary bind(game, world, hud, cam) calls. bind_3d(cam) on the input
# controller creates/binds picking3d.gd internally — never make a second
# adapter here (that was the duplicate-binding risk of an earlier draft).
# V7-70: the composed 3D scene is centred on origin (world3d_entities.gd:577,
# world3d_terrain.gd:312-314, world3d.gd:161-162), but camera3d.gd:148 feeds
# _target straight into a world Vector3. main.gd owns the seam that sets
# _target, so convert the clamped map-origin focus into centred metres here.
# clamp_pos() still uses map-origin limits: freeze its memo afterwards.
func _center_camera3d_target() -> void:
	if camera == null or not is_instance_valid(camera) or game == null:
		return
	var sim_focus: Vector2 = camera.get("_target")
	var centre_offset := Vector2(game.MAP_W, game.MAP_H) * 0.5 * Data.TILE_M
	camera.set("_target", sim_focus - centre_offset)
	camera.set("_last_clamp_target", camera.get("_target"))
	camera.set("_last_clamp_zoom", camera.get("zoom"))
	camera.call("_apply_transform")


func _apply_3d_hooks(p_hud, p_cam, p_input) -> void:
	if p_hud != null and p_hud.has_method("bind_3d"):
		p_hud.bind_3d(p_cam)          # V7-53: minimap viewport box via hud3d_adapter
	if p_input != null and p_input.has_method("bind_3d"):
		p_input.bind_3d(p_cam)        # V7-52: picking3d wiring, cmd_* untouched


func _setup_full_game() -> void:
	if not is_headless:
		get_window().size = Vector2i(Data.WINDOW_WIDTH, Data.WINDOW_HEIGHT)
		if Data.FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		DisplayServer.window_set_vsync_mode(
			DisplayServer.VSYNC_ENABLED if Data.VSYNC else DisplayServer.VSYNC_DISABLED)

	game = C3Game.new()
	add_child(game)
	# W5-2: a standalone subset may skip the expensive mapgen entirely when a
	# pre-baked post-setup snapshot is supplied and passes validation/parity.
	# Canonical runs (no --self-only) never take this path.
	var loaded_fast := false
	if selftest_only != "" and self_snapshot_path != "" and FileAccess.file_exists(_pick_target(self_snapshot_path)):
		loaded_fast = _load_self_base(game, self_snapshot_path)
	if not loaded_fast:
		game.setup(start_mode)
	game.game_over.connect(func(w: int) -> void: _on_game_over(w))
	# W26 (T3 Scenario B): snapshot the freshly generated world ONCE. Subsets
	# restore this instead of relying on cross-step side effects. Gates (no
	# --self-only) never restore, so their byte-stable behaviour is unchanged.
	if selftest_path != "":
		selftest_baseline = game.serialize()

	var homes := game.buildings_of(0)
	if render_mode == "3d":
		world = make_world3d()
		world.bind(game)
		add_child(world)

		camera = make_camera3d()
		add_child(camera)
		camera.bind(game, world.view_scale)  # camera3d.gd contract: bind(game, view_scale)
		camera.set_zoom_target(start_zoom, true)
		var focus3: Vector2 = Vector2(game.MAP_W, game.MAP_H) * 0.5 * Data.TILE_M
		if not homes.is_empty():
			focus3 = homes[0].pos
		if screenshot_path != "" and screenshot_focus == "relief":
			focus3 = _relief_focus_position() / world.view_scale
		camera.set("_target", focus3)  # camera3d.gd:90 _target is sim metres
		camera.clamp_pos()
		_center_camera3d_target()  # V7-70: sim map-origin -> centred 3D metres
	else:
		world = C3WorldScript.new()
		world.bind(game)
		add_child(world)

		camera = C3CameraScript.new()
		add_child(camera)
		camera.bind(world)
		camera.set_zoom_target(start_zoom, Vector2.INF, true)  # W4-1: wide start
		# Small samples need the map centre to avoid an off-screen void; larger maps
		# frame the first town hall (where starts/resources cluster), as in normal play.
		# An explicit "relief" focus overrides both in screenshot mode only.
		if screenshot_path != "" and screenshot_focus == "relief":
			camera.position = _relief_focus_position()
			camera.clamp_pos()
		elif screenshot_path != "" and game.MAP_W < 96:
			camera.position = Vector2(game.MAP_W, game.MAP_H) * 0.5 * Data.TILE_M * world.view_scale
		elif not homes.is_empty():
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
	if screenshot_path != "":
		hud.visible = false

	input_ctl = C3InputScript.new()
	add_child(input_ctl)
	input_ctl.bind(game, world, hud, camera)
	if render_mode == "3d":
		_apply_3d_hooks(hud, camera, input_ctl)  # V7-53 HUD + V7-52 picking hooks
	# start framed on the town hall with it selected, like the original
	# battle view: the bottom panel shows the building instead of empty black
	if screenshot_path == "":
		var homes2 := game.buildings_of(0)
		if not homes2.is_empty():
			input_ctl._set_selection([homes2[0]])

	# In journey mode the computer plays the human slot too, so the match
	# plays itself like a gameplay video.
	_create_ai_brains(journey_mode)

	audio = C3AudioScript.new()
	add_child(audio)
	var can_play := not is_headless
	if can_play:
		audio.start_music(str(game.players[0].get("nation", "ukr")))
	audio.set_meta("can_play", can_play)

# Screenshot-only: frame the deepest relief window (a ravine cut) instead of
# the start. Scans game.height with the generator's y*MAP_W+x indexing; water
# is skipped so an ocean floor is never mistaken for a land ravine. The tile
# is converted exactly like the town-hall position, then camera.clamp_pos()
# keeps the view inside the map.
func _relief_focus_position() -> Vector2:
	var r := 3
	var best := Vector2i(game.MAP_W >> 1, game.MAP_H >> 1)
	var best_mean := INF
	for y in range(game.MAP_H):
		for x in range(game.MAP_W):
			var sum := 0.0
			var n := 0
			for dy in range(-r, r + 1):
				var yy := y + dy
				if yy < 0 or yy >= game.MAP_H:
					continue
				for dx in range(-r, r + 1):
					var xx := x + dx
					if xx < 0 or xx >= game.MAP_W:
						continue
					var idx := yy * game.MAP_W + xx
					if game.terrain[idx] == 3:
						continue
					sum += game.height[idx]
					n += 1
			if n == 0:
				continue
			var mean := sum / float(n)
			if mean < best_mean:
				best_mean = mean
				best = Vector2i(x, y)
	return Vector2(best.x, best.y) * Data.TILE_M * world.view_scale

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

	# V7-70: 3D mode captures a real GPU pass into an explicit render target.
	# The root window texture reads blank in gl_compatibility, which is why the
	# old harness silently swapped in a CPU map image. The world and camera keep
	# their existing references; only their parent viewport changes. 2D mode is
	# left byte-for-byte unchanged.
	if render_mode == "3d" and world != null and camera != null:
		capture_view3d = SubViewport.new()
		capture_view3d.name = "Screenshot3DViewport"
		capture_view3d.world_3d = World3D.new()
		capture_view3d.size = Vector2i(Data.WINDOW_WIDTH, Data.WINDOW_HEIGHT)
		capture_view3d.render_target_update_mode = SubViewport.UPDATE_ONCE
		add_child(capture_view3d)
		if world.get_parent() != null:
			world.get_parent().remove_child(world)
		capture_view3d.add_child(world)
		if camera.get_parent() != null:
			camera.get_parent().remove_child(camera)
		capture_view3d.add_child(camera)
		camera.make_current()

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
			"--test-api":
				test_api_port = int(args[i + 1]) if i + 1 < args.size() else 8123
				i += 2
				continue
			"--self-test":
				selftest_path = args[i + 1] if i + 1 < args.size() else "selftest.json"
				i += 2
				continue
			"--self-only":
				selftest_only = args[i + 1] if i + 1 < args.size() else ""
				i += 2
				continue
			"--self-snapshot":
				self_snapshot_path = args[i + 1] if i + 1 < args.size() else ""
				i += 2
				continue
			"--dump-self-base":
				self_base_dump_path = args[i + 1] if i + 1 < args.size() else ""
				i += 2
				continue
			"--check-self-base":
				self_base_check_path = args[i + 1] if i + 1 < args.size() else ""
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
			"--cli-frame-ms":
				cli_frame_ms = clampf(float(args[i + 1]) if i + 1 < args.size() else 40.0, 1.0, 60000.0)
				i += 2
				continue
			"--cli-ticks-per-frame":
				cli_ticks_cap = clampi(int(args[i + 1]) if i + 1 < args.size() else 1500, 1, 100000)
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
			"--bench":
				bench_mode = true
			"--stats":
				show_stats = true
			"--fast":
				speed = 8.0
			"--speed":
				speed = maxf(0.1, float(args[i + 1])) if i + 1 < args.size() else 1.0
				i += 2
				continue
			"--seed":
				var sv := str(args[i + 1]) if i + 1 < args.size() else ""
				if sv == "random":
					seed_random = true
				elif sv.is_valid_int():
					seed_arg = int(sv)
				i += 2
				continue
			"--dump-map":
				dump_path = args[i + 1] if i + 1 < args.size() else ""
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
	if end_panel != null and is_instance_valid(end_panel):
		end_panel.queue_free()
	end_panel = PanelContainer.new()
	end_panel.set_anchors_preset(Control.PRESET_CENTER)
	end_panel.add_theme_stylebox_override("panel", C3ConfigScript.ui_panel_style())
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", maxi(6, int(8 * _menu_us())))
	end_panel.add_child(vb)
	var title := Label.new()
	title.text = "Victory!" if w == 0 else "Defeat"
	title.add_theme_font_size_override("font_size", maxi(24, int(36 * _menu_us())))
	vb.add_child(title)
	var lines := "time %.0fs  shots %d  hits %d  kills %d" % [game.time_s, game.stats.shots, game.stats.hits, game.stats.kills]
	var sl := Label.new()
	sl.text = lines
	sl.add_theme_font_size_override("font_size", maxi(12, int(15 * _menu_us())))
	vb.add_child(sl)
	for pi in game.players.size():
		var l := Label.new()
		l.text = "P%d units %d bldgs %d score %d" % [pi, game.unit_count(pi), game.buildings_of(pi).size(), game.players[pi].score]
		l.add_theme_font_size_override("font_size", maxi(12, int(14 * _menu_us())))
		vb.add_child(l)
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", maxi(6, int(8 * _menu_us())))
	vb.add_child(hb)
	var rb := _menu_btn("Restart")
	rb.pressed.connect(func(): last_cfg = pending_cfg; get_tree().reload_current_scene())
	hb.add_child(rb)
	var qb := _menu_btn("Quit to menu")
	qb.pressed.connect(func(): get_tree().reload_current_scene())
	hb.add_child(qb)
	var sv := _menu_btn("Save replay")
	sv.pressed.connect(func(): var f := FileAccess.open("user://lastgame.json", FileAccess.WRITE); if f: f.store_string(JSON.stringify(game.serialize())); f.close())
	hb.add_child(sv)
	add_child(end_panel)
	if start_mode == "campaign" or str(pending_cfg.get("mode", "")) == "campaign":
		var prog := {}
		if FileAccess.file_exists("user://campaign_progress.json"):
			prog = JSON.parse_string(FileAccess.get_file_as_string("user://campaign_progress.json"))
			if not prog is Dictionary:
				prog = {}
		if w == 0:
			prog[str(pending_cfg.get("mission", "m1"))] = true
			var f2 := FileAccess.open("user://campaign_progress.json", FileAccess.WRITE)
			if f2:
				f2.store_string(JSON.stringify(prog))
				f2.close()

func game_save() -> void:
	if game == null:
		return
	var f := FileAccess.open("user://quicksave.json", FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(game.serialize()))
		f.close()
		if hud:
			hud.show_hint("Game saved (F9 loads)")

func game_load() -> void:
	if not FileAccess.file_exists("user://quicksave.json"):
		return
	var d = JSON.parse_string(FileAccess.get_file_as_string("user://quicksave.json"))
	if d is Dictionary and game.deserialize(d):
		world.fog_explored.fill(0)
		world.fog_vis.fill(0)
		world._update_fog()
		if hud:
			hud.refresh_selection([])
			hud.show_hint("Game loaded")

func _menu_btn(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(maxi(200, int(240 * _menu_us())), maxi(34, int(40 * _menu_us())))
	b.add_theme_font_size_override("font_size", maxi(13, int(15 * _menu_us())))
	C3ConfigScript.ui_style_button(b)
	return b

func _menu_us() -> float:
	var s := Vector2(1280, 720)
	if is_instance_valid(get_viewport()):
		s = get_viewport().get_visible_rect().size
	return C3ConfigScript.ui_scale_for(s)

func _overlay_base(min_w: float) -> VBoxContainer:
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	menu_overlay.add_child(center)
	var card := PanelContainer.new()
	var vw := 1280.0
	if is_instance_valid(get_viewport()):
		vw = get_viewport().get_visible_rect().size.x
	card.custom_minimum_size = Vector2(minf(min_w * _menu_us(), vw * 0.94), 0)
	card.add_theme_stylebox_override("panel", C3ConfigScript.ui_panel_style())
	center.add_child(card)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", maxi(6, int(8 * _menu_us())))
	card.add_child(vb)
	return vb

func toggle_menu_overlay() -> void:
	if menu_overlay != null and is_instance_valid(menu_overlay):
		menu_overlay.queue_free()
		menu_overlay = null
		return
	menu_overlay = CanvasLayer.new()
	add_child(menu_overlay)
	var vb := _overlay_base(340.0)
	var resume := _menu_btn("Resume")
	resume.pressed.connect(toggle_menu_overlay)
	vb.add_child(resume)
	var sb := _menu_btn("Save (F5)")
	sb.pressed.connect(game_save)
	vb.add_child(sb)
	var lb := _menu_btn("Load (F9)")
	lb.pressed.connect(game_load)
	vb.add_child(lb)
	var ob := _menu_btn("Options")
	ob.pressed.connect(_show_options.bind(vb))
	vb.add_child(ob)
	var qb := _menu_btn("Quit to menu")
	qb.pressed.connect(func(): get_tree().reload_current_scene())
	vb.add_child(qb)
	var rb := _menu_btn("Restart")
	rb.pressed.connect(func(): get_tree().reload_current_scene())
	vb.add_child(rb)

func _show_options(parent: VBoxContainer) -> void:
	for c in parent.get_children():
		parent.remove_child(c)
		c.queue_free()
	var vol := HSlider.new()
	vol.min_value = -24
	vol.max_value = 6
	vol.value = Data.MASTER_VOLUME_DB
	vol.value_changed.connect(func(v: float): Data.MASTER_VOLUME_DB = v)
	parent.add_child(vol)
	var amb := HSlider.new()
	amb.min_value = -24
	amb.max_value = 6
	amb.value = Data.AMBIENT_VOLUME_DB
	amb.value_changed.connect(func(v: float): Data.AMBIENT_VOLUME_DB = v)
	parent.add_child(amb)
	var qopt := OptionButton.new()
	for q in ["high", "medium", "low"]:
		qopt.add_item(q)
	qopt.selected = ["high", "medium", "low"].find(Data.QUALITY)
	C3ConfigScript.ui_style_button(qopt)
	qopt.add_theme_font_size_override("font_size", maxi(13, int(15 * _menu_us())))
	qopt.item_selected.connect(func(i: int):
		var q2: String = ["high", "medium", "low"][i]
		Data.set_quality(q2)
		for k in world.terrain_chunks.values():
			(k as Sprite2D).queue_free()
		world.terrain_chunks.clear()
		world.terrain_order.clear()
		world.terrain_px = Data.TERRAIN_PX
		world.invalidate_forest_bake()  # T-FOREST-BAKE: quality change rebuilds cached forest chunks
		world.terrain_masks = world._build_masks(world._bake_px())
		world.anim_tex.clear()
		world.anim_index = {}
		# V7-50: explicit type — `world` is intentionally untyped for the 3D
		# factory, and GDScript cannot infer `:=` from a Variant member call.
		var idx_path: String = String(world.call("_anim_dir")) + "/land_units/index.json"
		if not FileAccess.file_exists(idx_path):
			idx_path = world._anim_dir() + "/index.json"  # legacy flat fallback
		var j := FileAccess.get_file_as_string(idx_path)
		if j != "":
			var parsed = JSON.parse_string(j)
			if parsed is Dictionary:
				world.anim_index = parsed
	)
	parent.add_child(qopt)
	var fogb := CheckButton.new()
	fogb.text = "Fog of war"
	fogb.button_pressed = Data.FOG_OF_WAR
	fogb.toggled.connect(func(on: bool): Data.FOG_OF_WAR = on; world.fog_sprite.visible = on)
	fogb.add_theme_font_size_override("font_size", maxi(13, int(15 * _menu_us())))
	parent.add_child(fogb)
	var capb := CheckButton.new()
	capb.text = "Peasant capture"
	capb.button_pressed = Data.CAPTURE_ENABLED
	capb.toggled.connect(func(on: bool): Data.CAPTURE_ENABLED = on)
	capb.add_theme_font_size_override("font_size", maxi(13, int(15 * _menu_us())))
	parent.add_child(capb)
	var dopt := OptionButton.new()
	for d in ["easy", "normal", "hard"]:
		dopt.add_item(d)
	dopt.selected = ["easy", "normal", "hard"].find(Data.AI_DIFFICULTY)
	dopt.item_selected.connect(func(i: int): Data.AI_DIFFICULTY = ["easy", "normal", "hard"][i])
	C3ConfigScript.ui_style_button(dopt)
	dopt.add_theme_font_size_override("font_size", maxi(13, int(15 * _menu_us())))
	parent.add_child(dopt)
	var back := _menu_btn("Back")
	back.pressed.connect(toggle_menu_overlay)
	parent.add_child(back)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_stop_sounds()

func _process(dt: float) -> void:
	# Hard wall-clock watchdog in every mode that must exit on its own.
	if deadline_ms > 0 and Time.get_ticks_msec() >= deadline_ms:
		printerr("watchdog: wall-clock limit reached, forced exit")
		_quit(1)
		return
	if test_bridge != null:
		test_bridge.poll()
	# T-MENU-ROSTER donor "Autosave": "on" ~ 10 min, "every_5_min" 5 min.
	# Labels are unverified English guesses (see gaps doc); the timer is wired.
	if game != null and not cli_mode and Data.AUTOSAVE_MODE != "off":
		var interval := 600.0 if Data.AUTOSAVE_MODE == "on" else 300.0
		autosave_acc += dt
		if autosave_acc >= interval:
			autosave_acc = 0.0
			game_save()
	if game == null or ais.is_empty():
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
	var t_tick := 0.0
	var t_ai := 0.0
	while acc >= step and steps < 64:
		acc -= step
		steps += 1
		var t0 := Time.get_ticks_usec()
		game.tick(step)
		bench_sim_ms += float(Time.get_ticks_usec() - t0) / 1000.0
		t_tick += float(Time.get_ticks_usec() - t0) / 1000.0
		t0 = Time.get_ticks_usec()
		for brain in ais:
			brain.tick(step)
		t_ai += float(Time.get_ticks_usec() - t0) / 1000.0
		# Never block inside the loop: bail out if the frame budget is spent.
		if steps % 16 == 0 and Time.get_ticks_msec() >= deadline_ms - 500 and deadline_ms > 0:
			break
	dbg_n += 1
	dbg_tick += t_tick
	dbg_ai += t_ai
	dbg_sync += 0.0
	dbg_steps += steps
	if dbg_n >= 120:
		var _wr = world
		print("PERF tick_ms=%.2f ai_ms=%.2f sync_ms=%.2f steps_per_frame=%.1f redraws r/b/u/f=%d/%d/%d/%d" % [dbg_tick / maxf(1.0, float(dbg_n)), dbg_ai / maxf(1.0, float(dbg_n)), dbg_sync / maxf(1.0, float(dbg_n)), float(dbg_steps) / maxf(1.0, float(dbg_n)), _wr.dbg_res if _wr != null else -1, _wr.dbg_bld if _wr != null else -1, _wr.dbg_unit if _wr != null else -1, _wr.dbg_fx if _wr != null else -1])
		dbg_n = 0
		dbg_tick = 0.0
		dbg_ai = 0.0
		dbg_sync = 0.0
		dbg_steps = 0
		if _wr != null:
			_wr.dbg_res = 0
			_wr.dbg_bld = 0
			_wr.dbg_unit = 0
			_wr.dbg_fx = 0
	if bench_mode:
		bench_frames += 1
		bench_t += float(steps) * step
		if bench_t >= 30.0:
			var wall_s := maxf(1.0, float(Time.get_ticks_msec() - bench_start_ms) / 1000.0)
			var rep := {"fps": float(bench_frames) / wall_s, "sim_ms_per_tick": bench_sim_ms / maxf(1.0, bench_t * Data.FPS), "units": game.entities.size(), "sim_seconds": bench_t, "wall_seconds": wall_s, "headless_sim_only": is_headless}
			var bp := ProjectSettings.globalize_path("res://shots/bench.json")
			var bf := FileAccess.open(bp, FileAccess.WRITE)
			if bf != null:
				bf.store_string(JSON.stringify(rep, "  "))
				bf.close()
				print("bench report: ", bp)
			else:
				print(JSON.stringify(rep))
			_quit(0)
			return
	if world != null and is_instance_valid(world) and not (bench_mode and is_headless):
		var t1 := Time.get_ticks_usec()
		world.sync(dt)
		dbg_sync += float(Time.get_ticks_usec() - t1) / 1000.0
	if journey_mode and camera != null and game != null:
		journey_cam_t -= dt
		if journey_cam_t <= 0.0:
			journey_cam_t = 1.0
			var focus := Vector2.ZERO
			var n := 0
			var fighting := false
			for e in game.live_units:
				if e.player != 0:
					continue
				if str(e.sid) == "peasant":
					continue
				focus += e.pos
				n += 1
				if e.order.type == "attack":
					fighting = true
			if n == 0:
				for b in game.buildings_of(0):
					focus = b.pos
					n = 1
					break
			if n > 0:
				if render_mode == "3d":
					# V7-70 E19: Camera3D's canonical API takes sim metres
					# (top-left origin); no view_scale and no Vector2->Vector3
					# lerp into global_position (the V7-75 handoff).
					var target_m: Vector2 = focus / float(n)
					camera.call("jump_to_world", target_m)
					_center_camera3d_target()  # sim metres -> centred 3D metres
				else:
					var target: Vector2 = (focus / float(n)) * world.view_scale
					camera.position = camera.position.lerp(target, 0.35)
				var want_zoom: float = 0.75 if fighting else 1.0
				camera.set_zoom_target(want_zoom)  # W4-1 smoothing owns the lerp
			if dbg_journey < 2:
				dbg_journey += 1
				print("V770_JOURNEY probe mode=", render_mode,
					" focus_m=", (focus / float(n)) if n > 0 else Vector2.ZERO,
					" camera=", (camera.get("_target") if render_mode == "3d" else camera.position))
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
						_play(["musket1", "musket2"], 0.0, ev.pos)
					"arrow", "firearrow":
						_play(["arrow1"], 0.0, ev.pos)
					"cannonball":
						_play(["shotcannon1"], 0.0, ev.pos)
					_:
						_play(["sabre1"], 0.0, ev.pos)
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
					_play(["arrowimpact1"], -8.0, ev.pos)
			"explode":
				world.add_fx("explode", ev.pos)
				_play(["cannonexpl1"], 0.0, ev.pos)
			"chop":
				world.add_fx("chop", ev.pos)
				_play(["workwood"], -8.0, ev.pos)
			"death":
				if ev.kind == "building":
					_play(["deathbuilding1"], 0.0, ev.pos)
				else:
					_play(["deathinf1", "deathinf2"], 0.0, ev.pos)
			"capture":
				_play(["alarm"])
			"done":
				_play(audio.building_sound(ev.kind), -6.0)
	game.events.clear()

func _play(names: Array, vol := 0.0, at := Vector2.INF) -> void:
	if audio != null and is_instance_valid(audio) and bool(audio.get_meta("can_play", false)):
		audio.play(names, vol, at)

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
	if parts.size() > 0:
		# Relative output paths are workspace-root based, whether they start
		# with the project folder ("app/shots/x.png") or not ("scans/scan_7.json").
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
	# Windowed: capture a real GPU frame. In 3D mode the dedicated render target
	# is authoritative: the window backbuffer read blank under gl_compatibility,
	# which is why the old harness silently substituted a CPU map image.
	if capture_view3d != null and is_instance_valid(capture_view3d):
		capture_view3d.render_target_update_mode = SubViewport.UPDATE_ONCE
	await RenderingServer.frame_post_draw
	var vp = get_viewport()
	if capture_view3d != null and is_instance_valid(capture_view3d):
		vp = capture_view3d
	# The window may have been closed while waiting - exit cleanly.
	if vp == null or not is_instance_valid(vp):
		printerr("screenshot: viewport gone")
		_quit(1)
		return
	var tex := vp.get_texture()
	if tex == null:
		printerr("screenshot: no viewport texture")
		_quit(1)
		return
	var img := tex.get_image()
	if render_mode == "3d":
		# V7-70 diagnostics: always keep the unfiltered GPU image so a blank
		# result can be distinguished from "2D map substituted for 3D".
		var raw_path := _write_bytes(screenshot_path + ".raw.png", img) if img != null else ""
		print("screenshot raw capture: ", raw_path)
		var wimg := 0
		var himg := 0
		var p00 := Color(-1.0, -1.0, -1.0)
		var pcenter := Color(-1.0, -1.0, -1.0)
		if img != null and not img.is_empty():
			wimg = img.get_width()
			himg = img.get_height()
			p00 = img.get_pixel(0, 0)
			pcenter = img.get_pixel(int(wimg / 2), int(himg / 2))
		var cam_ok := false
		if camera != null and is_instance_valid(camera) and camera.get_viewport() != null:
			cam_ok = camera.get_viewport().get_camera_3d() == camera
		var wp := "none"
		if world != null and is_instance_valid(world) and world.get_parent() != null:
			wp = world.get_parent().name
		var cam_pos = camera.global_position if camera != null and is_instance_valid(camera) else "none"
		var cam_target = camera.get("_target") if camera != null and is_instance_valid(camera) else "none"
		print("screenshot capture diag: viewport=", vp.name, " image=", wimg, "x", himg,
			" p00=", p00, " pcenter=", pcenter, " camera_current=", cam_ok,
			" world_parent=", wp, " camera_pos=", cam_pos, " target=", cam_target)
	if img == null or img.is_empty() or (render_mode == "3d" and _is_blank(img)):
		if render_mode == "3d":
			# No CPU fallback outside headless: a blank 3D capture must never
			# be presented as visual proof. Fail loudly instead.
			printerr("screenshot: windowed 3D capture is blank; no CPU fallback "
				+ "(visual parity UNVERIFIED)")
			_quit(1)
			return
		printerr("screenshot: blank image, retrying with map render")
		img = _render_headless_image(800, 600)
	var out2 := _write_bytes(screenshot_path, img)
	if out2 == "":
		printerr("screenshot: could not write ", screenshot_path)
		_quit(1)
		return
	if render_mode == "3d":
		print("screenshot capture source: ", vp.name, "/", img.get_width(), "x", img.get_height())
	# A blank picture never passes: fall back to the map render instead (2D only).
	if render_mode != "3d" and _is_blank(img):
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
			"stump":
				c2 = Color(0.42, 0.32, 0.2)
			"bush":
				c2 = Color(0.3, 0.42, 0.2)
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
	# Self-test runs synchronously. Real wall time is per-step `wall_ms` in the
	# report (T3 measured ~89 s for the full 29-step gate, not ~1 s).
	# It is guarded by the wall-clock watchdog above, and every loop inside
	# game.tick/selftest has a fixed step cap, so it cannot hang.
	var st := C3SelfTest.new()
	st.bind(game, hud, self)
	st.set_baseline(selftest_baseline)
	var report: Dictionary
	if selftest_only == "":
		report = st.run()                       # canonical 29-step gate: unchanged
	elif selftest_only.find(",") >= 0:
		report = st.run_groups(selftest_only)   # one process, baseline per group
	else:
		report = st.run_only(selftest_only)
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
# video assembly (see tools/seq_to_mp4.py + docs/COMMANDS.md ffmpeg line).
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
	while cli_ticks_left > 0 and game.winner == -1 and ticks_this_frame < cli_ticks_cap:
		game.tick(step)
		for brain in ais:
			brain.tick(step)
		cli_t += step
		cli_ticks_left -= 1
		ticks_this_frame += 1
		# Per-frame budget (default 40 ms): return to the main loop, never block.
		# Only the budget changes; game.tick(step) still uses the same fixed step
		# and the same order relative to brain.tick(step). No sim semantics change.
		if Time.get_ticks_msec() - frame_start > cli_frame_ms:
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
