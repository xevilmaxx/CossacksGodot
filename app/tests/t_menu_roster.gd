# T-MENU-ROSTER: skirmish roster (2..8 players, per-player nation/team/AI)
# mapping through the real main.gd apply path, plus the world.gd colour OOB fix.
# Small, headless, self-exiting; no whole-game selftest.
#
# Run with:
#   python app\tools\godot_runner.py run --id t-menu-roster --timeout 100 -- \
#       --headless --path app --script res://tests/t_menu_roster.gd
extends SceneTree

const Data = preload("res://scripts/data.gd")
const C3Main = preload("res://scripts/main.gd")
const C3Game = preload("res://scripts/game.gd")
const C3World = preload("res://scripts/world.gd")
const C3Menu = preload("res://scripts/menu.gd")

const OUT_DIR := "res://tests/results"

var _id := "t_menu_roster"
var _checks: Array[Dictionary] = []
var _ok := true

func check(name: String, cond: bool, detail: String = "") -> void:
	_checks.append({"name": name, "passed": cond, "detail": detail})
	print(("  PASS  " if cond else "  FAIL  ") + name + " - " + detail)
	if not cond:
		_ok = false

func _write_result() -> void:
	var abs_dir := ProjectSettings.globalize_path(OUT_DIR)
	DirAccess.make_dir_recursive_absolute(abs_dir)
	var path := "%s/%s.json" % [abs_dir, _id]
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_error("cannot write test result: " + path)
		return
	f.store_string(JSON.stringify({
		"id": _id,
		"passed": _ok,
		"checks": _checks,
		"unix_ms": Time.get_unix_time_from_system() * 1000.0,
	}, "\t"))
	f.close()

func _roster_cfg(teams: Array) -> Dictionary:
	var nations := ["rus", "bav", "pol", "swe", "pru", "fra"]
	var players := []
	for i in 6:
		players.append({"nation": nations[i], "team": int(teams[i]),
			"ai": i > 0, "name": "P%d" % (i + 1),
			"ai_difficulty": "normal" if i > 0 else "none",
			"difficulty": "normal"})
	return {"mode": "skirmish", "players": players, "nation0": "rus",
		"nation1": "bav", "opponents": 5, "teams": "4",
		"map_size": 320, "seed": 12345}

func _initialize() -> void:
	var main := C3Main.new()
	# Real apply path: 6 slots, teams [0,0,1,1,2,2], P1 human rest computer.
	main._apply_menu_cfg(_roster_cfg([0, 0, 1, 1, 2, 2]))
	check("player_count", Data.PLAYER_COUNT == 6,
		"PLAYER_COUNT=%d (want 6)" % Data.PLAYER_COUNT)
	check("teams", Data.TEAMS == [0, 0, 1, 1, 2, 2],
		"TEAMS=%s (want [0,0,1,1,2,2])" % str(Data.TEAMS))
	check("ai_flags", Data.PLAYER_AI.size() == 6 and not bool(Data.PLAYER_AI[0]) \
		and bool(Data.PLAYER_AI[5]),
		"PLAYER_AI=%s (want 6 entries, slot0 human)" % str(Data.PLAYER_AI))
	check("nations", Data.PLAYER_NATIONS.size() == 6 and str(Data.PLAYER_NATIONS[5]) == "fra",
		"PLAYER_NATIONS=%s" % str(Data.PLAYER_NATIONS))
	check("per_slot_difficulty", Data.PLAYER_AI_DIFFICULTY.size() == 6 \
		and str(Data.PLAYER_AI_DIFFICULTY[0]) == "normal",
		"PLAYER_AI_DIFFICULTY=%s" % str(Data.PLAYER_AI_DIFFICULTY))

	# The sim must actually build six players with those teams / AI flags.
	var game := C3Game.new()
	root.add_child(game)
	game.setup_begin("skirmish")
	var built_teams := []
	var built_ai := []
	for p in game.players:
		built_teams.append(int(p.get("team", -1)))
		built_ai.append(bool(p.get("is_ai", false)))
	check("sim_players", game.players.size() == 6 and built_teams == [0, 0, 1, 1, 2, 2] \
		and built_ai == [false, true, true, true, true, true],
		"sim players=%d teams=%s ai=%s" % [game.players.size(), str(built_teams), str(built_ai)])

	# FFA must stay free-for-all even though every player now has a team key.
	main._apply_menu_cfg(_roster_cfg([-1, -1, -1, -1, -1, -1]))
	game.setup_begin("skirmish")  # rebuild players with the new teams
	var ffa_allies := 0
	for a in 6:
		for b in 6:
			if a != b and game._is_ally(a, b):
				ffa_allies += 1
	check("ffa_not_allied", ffa_allies == 0,
		"ally pairs with team=-1: %d (want 0)" % ffa_allies)

	# Legacy path (no roster) still caps 1..3 opponents and "2v1".
	main._apply_menu_cfg({"opponents": 2, "teams": "2v1", "nation0": "rus", "nation1": "bav"})
	check("legacy_path", Data.PLAYER_COUNT == 3 and Data.TEAMS == [0, 0, 1] \
		and (Data.PLAYER_AI as Array).is_empty(),
		"legacy count=%d teams=%s ai=%s" % [Data.PLAYER_COUNT, str(Data.TEAMS), str(Data.PLAYER_AI)])

	# Donor "Random" minerals resolve deterministically from the seed.
	var cfg_r := {"richness": "random", "seed": 777, "map_size": 320}
	main._apply_menu_cfg(cfg_r)
	var first := str(Data.RICHNESS)
	main._apply_menu_cfg(cfg_r)
	check("random_richness", ["low", "med", "rich"].has(first) and str(Data.RICHNESS) == first,
		"seed 777 -> %s / %s" % [first, str(Data.RICHNESS)])

	# Menu team-preset math: 4 players / 2 teams -> 0,0,1,1.
	var menu := C3Menu.new()
	menu.players = 4
	menu.team_preset = "2"
	menu.roster_nations = ["rus", "bav", "pol", "swe"]
	menu.roster_teams = [-1, -1, -1, -1]
	menu._ensure_roster()
	menu._apply_team_preset()
	check("team_preset", menu.roster_teams == [0, 0, 1, 1],
		"4 players / 2 teams -> %s" % str(menu.roster_teams))
	menu.free()

	# DEEP donor option struct: canonical ids map onto the port, Random is
	# seed-resolved, and rule options are published as Data statics.
	# Headless tests have no settings file loaded, so seed the cached base stock
	# explicitly; otherwise a 0 * 25 = 0 check would pass vacuously.
	main._base_start_res = {"food": 800.0, "wood": 800.0, "stone": 400.0,
		"gold": 200.0, "iron": 150.0, "coal": 150.0}
	var base_stock := 800.0
	main._apply_menu_cfg({"terraintype": "coastal", "relieftype": "plateaus",
		"resourcestart": "thousands", "resourcemines": "random", "seed": 4242,
		"peacetime": 600, "capture": "artillery_only", "limit": 100,
		"cannons": "no_cannons_towers_walls", "gamespeed": "fast",
		"autosave": "every_5_min", "allies": "nearby", "balloon": "balloons",
		"century18": "never", "marketdip": "without_both", "adviserassistant": "with"})
	check("donor_shape_relief", str(Data.DONOR_MAP_SHAPE) == "coastal" \
		and str(Data.MAP_TYPE) == "mediterranean" \
		and str(Data.DONOR_RELIEF_TYPE) == "plateaus" and str(Data.RELIEF) == "mountains",
		"shape=%s->%s relief=%s->%s" % [str(Data.DONOR_MAP_SHAPE), str(Data.MAP_TYPE),
		str(Data.DONOR_RELIEF_TYPE), str(Data.RELIEF)])
	check("donor_stock", absf(float(Data.START_RESOURCES.get("food", 0.0)) - base_stock * 25.0) < 0.01,
		"food %f -> %f (want 25x)" % [base_stock, float(Data.START_RESOURCES.get("food", 0.0))])
	check("donor_rules", int(Data.PEACE_TIME) == 600 and int(Data.POP_LIMIT) == 100 \
		and str(Data.CAPTURE_MODE) == "artillery_only" \
		and str(Data.CANNON_MODE) == "no_cannons_towers_walls" \
		and str(Data.GAME_SPEED) == "fast" and absf(main.speed - 2.0) < 0.01 \
		and str(Data.AUTOSAVE_MODE) == "every_5_min" and str(Data.ALLIES_MODE) == "nearby",
		"peace=%d pop=%d capture=%s cannons=%s speed=%s" % [int(Data.PEACE_TIME),
		int(Data.POP_LIMIT), str(Data.CAPTURE_MODE), str(Data.CANNON_MODE), str(main.speed)])
	check("donor_ui_only_recorded", str(Data.BALLOON_MODE) == "balloons" \
		and str(Data.CENTURY18_MODE) == "never" and str(Data.MARKET_DIP_MODE) == "without_both" \
		and str(Data.ADVISER_MODE) == "with",
		"balloon=%s century=%s market=%s adviser=%s" % [str(Data.BALLOON_MODE),
		str(Data.CENTURY18_MODE), str(Data.MARKET_DIP_MODE), str(Data.ADVISER_MODE)])

	# UI smoke: build the real skirmish screen headlessly, rebuild the rows for
	# 6 players and verify the emitted cfg carries the full roster.
	var ui := C3Menu.new()
	root.add_child(ui)
	ui._build()  # _ready is deferred inside SceneTree._initialize; build by hand
	ui._show_skirmish()
	var rows2 := 0
	var option_rows := 0
	var headers := 0
	for c in ui.body.get_children():
		if c.has_meta("roster_row"):
			rows2 += 1
		elif c is HBoxContainer:
			option_rows += 1
		elif c is Label and str(c.text).begins_with("—"):
			headers += 1
	check("ui_option_rows", option_rows >= 20 and headers >= 3,
		"option rows=%d, section headers=%d" % [option_rows, headers])
	ui.players = 6
	ui._rebuild_roster()
	var rows6 := 0
	for c in ui.body.get_children():
		if c.has_meta("roster_row"):
			rows6 += 1
	check("ui_roster_rows", rows2 == 2 and rows6 == 6,
		"rows after default=%d, after Players=6 -> %d (want 2 / 6)" % [rows2, rows6])
	var emitted := []
	ui.chosen.connect(func(cfg: Dictionary): emitted.append(cfg))
	ui._emit_start("Skirmish")
	var cfg_emitted: Dictionary = emitted[0] if not emitted.is_empty() else {}
	var pl: Array = cfg_emitted.get("players", []) if cfg_emitted.get("players") is Array else []
	check("ui_emit_roster", pl.size() == 6 and int(pl[0].get("team", -99)) == -1 \
		and not bool(pl[0].get("ai", true)) and bool(pl[5].get("ai", false)) \
		and str(cfg_emitted.get("allies", "")) == "default",
		"emitted players=%d, P1 team/ai=%s/%s, allies=%s" % [pl.size(),
		str(pl[0].get("team", -99)) if not pl.is_empty() else "?",
		str(pl[0].get("ai", true)) if not pl.is_empty() else "?",
		str(cfg_emitted.get("allies", ""))])
	var donor_keys := ["terraintype", "relieftype", "resourcestart", "resourcemines",
		"mapsize", "startingunits", "balloon", "cannons", "peacetime", "century18",
		"capture", "marketdip", "autosave", "limit", "gamespeed", "adviserassistant"]
	var missing := []
	for k in donor_keys:
		if not cfg_emitted.has(k):
			missing.append(k)
	check("ui_emit_donor_keys", missing.is_empty(),
		"missing donor keys: %s" % str(missing))
	ui.queue_free()

	# The critical OOB crash: p>=2 used to index a 2-element array.
	var world := C3World.new()
	var c5: Color = world._player_color(5)
	var c8: Color = world._player_color(8)
	check("player_color_oob", c5 is Color and c8 is Color and c5 != c8,
		"color(5)=%s color(8)=%s (modulo fallback)" % [str(c5), str(c8)])
	world.free()

	main.free()
	_write_result()
	call_deferred("quit", 0 if _ok else 1)
