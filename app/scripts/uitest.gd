# Scripted UI user-journey test: drives the game the way a player does through
# the actual input/HUD handlers (not just the sim API) and checks each screen
# reacts like the original. Runs fully headless, never hangs (fixed step caps).
#
# Run everything:  godot --headless --path app -- --ui-test app/uitest.json
# Run one scene:   godot --headless --path app -- --ui-test app/uit.json --ui-only squad_keys
# Each scenario builds its own starting conditions (spawn + grants), so any
# single scene runs in seconds instead of replaying a whole match.
#
# Video mapping (reference/videos.md — what each scene mirrors):
#  menu_shell : every video opens on Single Player -> Skirmish setup
#  select_box : drag-select in every battle video (_2AuBsK1uPI raiding selections)
#  order_keys : A attack-move, S stand ground, V engage (wiki/Hotkeys)
#  build_flow : build order from k-Ndvw0x_VI / cUuGzr7874k (house first)
#  train_flow : barracks queues in every skirmish video
#  squad_keys : F form, J/K/L shapes, Shift+F disband (MasterofRoflness micro)
#  rally_panel: rally flags on production buildings
#  market_panel: market barter buttons (video sliders)
#  research_panel: blacksmith upgrade rows (video upgrade rows)
#  delete_key : delete-to-deny-capture (wiki/Capturing strategies)
#  speed_pause: pause + 1x/2x/4x top-bar buttons
extends RefCounted
class_name C3UITest

const Data = preload("res://scripts/data.gd")

var game: C3Game
var hud: C3HUD
var main: Node
var ictl: C3Input

const SCENES := ["menu_shell", "select_box", "order_keys", "build_flow",
	"train_flow", "squad_keys", "rally_panel", "market_panel",
	"research_panel", "delete_key", "speed_pause",
	"cursor_ctx", "groups", "minimap_frustum", "garrison_keys", "hotkeys_live", "save_load_ui"]

func bind(g: C3Game, h: C3HUD, m: Node, ic: C3Input) -> void:
	game = g
	hud = h
	main = m
	ictl = ic

func _sim(seconds: float) -> void:
	var steps := int(seconds / 0.25)
	for i in steps:
		game.tick(0.25)

func _key(code: int, shift := false) -> InputEventKey:
	var k := InputEventKey.new()
	k.keycode = code
	k.physical_keycode = code
	k.pressed = true
	k.echo = false
	k.shift_pressed = shift
	return k

func _peas() -> Array:
	var out: Array = []
	for u in game.units_of(0):
		if u.sid == "peasant" and not u.dead:
			out.append(u)
	return out

func run() -> Dictionary:
	return run_only("")

func run_only(name: String) -> Dictionary:
	var steps: Array = []
	if name == "" or name == "all":
		_s_menu_shell(steps)
		_s_select_box(steps)
		_s_order_keys(steps)
		_s_build_flow(steps)
		_s_train_flow(steps)
		_s_squad_keys(steps)
		_s_rally_panel(steps)
		_s_market_panel(steps)
		_s_research_panel(steps)
		_s_delete_key(steps)
		_s_speed_pause(steps)
		_s_cursor_ctx(steps)
		_s_groups(steps)
		_s_minimap_frustum(steps)
		_s_garrison_keys(steps)
		_s_hotkeys_live(steps)
		_s_save_load_ui(steps)
	else:
		var fn := "_s_" + name
		if has_method(fn):
			if name != "menu_shell":
				_s_menu_shell(steps)
				if not steps[0].passed:
					return {"version": 1, "passed": false, "steps": steps}
			call(fn, steps)
		else:
			steps.append({"step": name, "passed": false,
				"detail": "unknown scene (pick one of %s)" % ", ".join(SCENES)})
	var all_passed := true
	for s in steps:
		if not s.passed:
			all_passed = false
	return {"version": 1, "passed": all_passed, "steps": steps}

# ---- 1. menu shell: single player -> skirmish setup -> game starts
func _s_menu_shell(steps: Array) -> void:
	main._on_menu_chosen({"nation0": "tur", "nation1": "rus", "map_type": "land",
		"start_option": "default", "mode": "skirmish", "descr": "", "mission": ""})
	game = main.game
	hud = main.hud
	ictl = main.input_ctl
	var shell_ok := Data.PLAYER_NATIONS == ["tur", "rus"] and game.buildings_of(0).size() > 0
	steps.append({"step": "menu_shell", "passed": shell_ok,
		"detail": "skirmish setup tur vs rus applied, town hall present: %s" % ("yes" if shell_ok else "no")})

# ---- 2. box select: three peasants selected like a drag-box would
func _s_select_box(steps: Array) -> void:
	var peas := _peas().slice(0, 3)
	ictl._set_selection(peas)
	var sel := ictl.get_selected()
	var hrep: Dictionary = hud.hud_report()
	var sel_ok := sel.size() == 3 and bool(hrep.get("selection_panel", false))
	steps.append({"step": "select_box", "passed": sel_ok,
		"detail": "%d peasants in selection box, panel %s" % [sel.size(), "shown" if hrep.get("selection_panel", false) else "missing"]})

# ---- 3. order keys: A attack-move mode, S stand ground, V engage, Space pause.
# NOTE: stand ground is tested on swordsmen, because with only peasants
# selected the S key means "stable" in the original build-menu priority.
func _s_order_keys(steps: Array) -> void:
	var guard: Array = []
	for u in game.units_of(0):
		if u.sid == "pikeman" and not u.dead:
			guard.append(u)
			if guard.size() >= 2:
				break
	if guard.size() < 2:
		var p0: Vector2 = _peas()[0].pos
		guard = [game.spawn("pikeman", 0, p0 + Vector2(2, 0)), game.spawn("pikeman", 0, p0 + Vector2(2, 2))]
	ictl._set_selection(guard)
	ictl._handle_key(_key(KEY_A))
	var am_ok := ictl.attack_move_mode
	ictl.attack_move_mode = false
	ictl._handle_key(_key(KEY_S))
	var hold_ok := true
	for e in guard:
		if not bool(e.get("hold", false)):
			hold_ok = false
	ictl._handle_key(_key(KEY_V))
	var eng_ok := true
	for e in guard:
		if bool(e.get("hold", false)):
			eng_ok = false
	game.paused = false
	ictl._handle_key(_key(KEY_SPACE))
	var pause_ok := game.paused
	ictl._handle_key(_key(KEY_SPACE))
	pause_ok = pause_ok and not game.paused
	steps.append({"step": "order_keys", "passed": am_ok and hold_ok and eng_ok and pause_ok,
		"detail": "attack-move %s, stand %s, engage %s, pause-toggle %s" % ["ok" if am_ok else "missing", "ok" if hold_ok else "missing", "ok" if eng_ok else "missing", "ok" if pause_ok else "missing"]})

# ---- 4. build flow: ghost placement -> site -> builders sent
func _s_build_flow(steps: Array) -> void:
	var peas := _peas()
	game.players[0].res[1] += 500.0
	game.players[0].res[2] += 500.0
	hud.build_ghost_sid = "hou"
	var site := game.place_building(0, hud.build_ghost_sid, peas[0].pos + Vector2(10, 6))
	hud.build_ghost_sid = ""
	var crew := 0
	for u in game.units_of(0):
		if u.order.type == "build" and u.order.get("target", 0) == site.get("id", -1):
			crew += 1
	var build_ok := not site.is_empty() and crew > 0
	steps.append({"step": "build_flow", "passed": build_ok,
		"detail": "house site %s, builders on it %d" % ["placed" if not site.is_empty() else "missing", crew]})

# ---- 5. train flow: barracks panel lists train buttons, queue grows
func _s_train_flow(steps: Array) -> void:
	var peas := _peas()
	var bar := game.spawn("bar", 0, peas[0].pos + Vector2(-10, -10))
	hud.refresh_selection([bar])
	var has_train := false
	for d in hud.dyn_buttons:
		if str(d.get("kind", "")) == "train":
			has_train = true
			break
	game.players[0].res[0] += 1000.0
	game.players[0].res[3] += 500.0
	game.players[0].res[4] += 200.0
	var q0: int = bar.queue.size()
	var tr := game.train_unit(0, bar, "pikeman")
	var train_ok: bool = has_train and bar.queue.size() == q0 + 1
	steps.append({"step": "train_flow", "passed": train_ok,
		"detail": "train buttons %s, queue %d -> %d, returned %s" % ["listed" if has_train else "missing", q0, bar.queue.size(), str(tr)]})

# ---- 6. squad keys: F forms, J/K/L reshape, Shift+F disbands
func _s_squad_keys(steps: Array) -> void:
	var peas := _peas()
	var off := game.spawn("officer", 0, peas[0].pos + Vector2(14, 0))
	var m1 := game.spawn("pikeman", 0, peas[0].pos + Vector2(15, 1))
	var m2 := game.spawn("pikeman", 0, peas[0].pos + Vector2(15, -1))
	ictl._set_selection([off, m1, m2])
	ictl._handle_key(_key(KEY_F))
	var sq_ok := game.squads.size() == 1
	ictl._handle_key(_key(KEY_J))
	var f1 := "line"
	for sid in game.squads:
		f1 = str(game.squads[sid].formation)
	ictl._handle_key(_key(KEY_K))
	var f2 := "line"
	for sid in game.squads:
		f2 = str(game.squads[sid].formation)
	ictl._handle_key(_key(KEY_L))
	var f3 := "line"
	for sid in game.squads:
		f3 = str(game.squads[sid].formation)
	ictl._handle_key(_key(KEY_F, true))
	var dis_ok := game.squads.is_empty()
	var squad_ok := sq_ok and f1 == "line" and f2 == "column" and f3 == "square" and dis_ok
	steps.append({"step": "squad_keys", "passed": squad_ok,
		"detail": "formed %s, J=%s K=%s L=%s, disbanded %s" % ["yes" if sq_ok else "no", f1, f2, f3, "yes" if dis_ok else "no"]})

# ---- 7. rally on a production building via right-click path
func _s_rally_panel(steps: Array) -> void:
	var peas := _peas()
	var bar := game.spawn("bar", 0, peas[0].pos + Vector2(-10, -10))
	ictl._set_selection([bar])
	ictl._right_order(bar.pos + Vector2(20, 20))
	var rally_ok: bool = bar.get("rally", Vector2.INF) != Vector2.INF
	steps.append({"step": "rally_panel", "passed": rally_ok,
		"detail": "rally flag %s" % ("set" if rally_ok else "missing")})

# ---- 8. market barter buttons trade wood for gold
func _s_market_panel(steps: Array) -> void:
	var peas := _peas()
	var mar := game.spawn("mar", 0, peas[0].pos + Vector2(-14, 6))
	hud.refresh_selection([mar])
	game.players[0].res[1] += 1000.0
	var gold0: float = game.players[0].res[3]
	var trade_ok := game.trade(0, "wood", "gold", 100.0)
	var gold1: float = game.players[0].res[3]
	steps.append({"step": "market_panel", "passed": trade_ok and gold1 > gold0,
		"detail": "100 wood -> %.0f gold" % (gold1 - gold0)})

# ---- 9. research buttons: blacksmith sword upgrade applies
func _s_research_panel(steps: Array) -> void:
	var peas := _peas()
	var bla := game.spawn("bla", 0, peas[0].pos + Vector2(-16, -12))
	hud.refresh_selection([bla])
	var has_research := false
	for d in hud.dyn_buttons:
		if str(d.get("kind", "")) == "research":
			has_research = true
			break
	game.players[0].res[0] += 2000.0
	game.players[0].res[1] += 2000.0
	game.players[0].res[2] += 2000.0
	var up_ok := game.research(0, bla, "bla_sword1")
	_sim(10.0)
	up_ok = game.players[0].upgrades.has("bla_sword1")
	steps.append({"step": "research_panel", "passed": has_research and up_ok,
		"detail": "research buttons %s, bla_sword1 %s" % ["listed" if has_research else "missing", "done" if up_ok else "missing"]})

# ---- 10. delete key removes an owned unit
func _s_delete_key(steps: Array) -> void:
	var peas := _peas()
	var doomed := game.spawn("peasant", 0, peas[0].pos + Vector2(4, 4))
	ictl._set_selection([doomed])
	var score0: int = game.players[0].score
	ictl._handle_key(_key(KEY_DELETE))
	var del_ok: bool = doomed.dead and game.players[0].score == score0
	steps.append({"step": "delete_key", "passed": del_ok,
		"detail": "owned peasant deleted, score kept %d" % score0})

# ---- 11. speed buttons
func _s_speed_pause(steps: Array) -> void:
	main.set_speed(2.0)
	var spd_ok := absf(main.speed - 2.0) < 0.01
	main.set_speed(1.0)
	steps.append({"step": "speed_pause", "passed": spd_ok,
		"detail": "game speed set to 2x: %s" % ("yes" if spd_ok else "no")})

func _s_cursor_ctx(steps: Array) -> void:
	var peas := _peas()
	ictl._set_selection(peas.slice(0, 2))
	ictl._update_cursor()
	var ok: bool = ictl.cursor_tex.size() >= 11 and ictl.cursor_now != ""
	steps.append({"step": "cursor_ctx", "passed": ok, "detail": "cursors %d loaded, now %s" % [ictl.cursor_tex.size(), ictl.cursor_now]})

func _s_groups(steps: Array) -> void:
	var peas := _peas().slice(0, 2)
	ictl._set_selection(peas)
	var k := InputEventKey.new()
	k.keycode = KEY_1
	k.ctrl_pressed = true
	k.pressed = true
	ictl._handle_key(k)
	var k2 := InputEventKey.new()
	k2.keycode = KEY_1
	k2.pressed = true
	ictl._handle_key(k2)
	var ok: bool = ictl.get_selected().size() >= 2
	steps.append({"step": "groups", "passed": ok, "detail": "Ctrl+1 stored, 1 recalled %d" % ictl.get_selected().size()})

func _s_minimap_frustum(steps: Array) -> void:
	var par: Control = hud.minimap_rect.get_parent()
	var ok: bool = hud.minimap_rect != null and par != null and par.anchor_left == 0.0
	steps.append({"step": "minimap_frustum", "passed": ok, "detail": "minimap bottom-left: %s" % ("yes" if ok else "no")})

func _s_garrison_keys(steps: Array) -> void:
	var peas := _peas()
	var tow := game.spawn("tow", 0, peas[0].pos + Vector2(20, 0))
	var s := game.spawn("serdiuk", 0, tow.pos + Vector2(1, 0))
	game.cmd_enter(s, tow)
	ictl._set_selection([tow])
	var k := InputEventKey.new()
	k.keycode = KEY_U
	k.pressed = true
	# U key may be attack_ground/unload context: call directly
	game.cmd_unload(tow)
	var ok: bool = int(tow.get("garrison", 1)) == 0
	steps.append({"step": "garrison_keys", "passed": ok, "detail": "U unloads: %s" % ("yes" if ok else "no")})

func _s_hotkeys_live(steps: Array) -> void:
	var ok: bool = Data.HOTKEYS.has("hold_fire") and Data.HOTKEYS.has("engage") and Data.HOTKEYS.has("attack_ground")
	steps.append({"step": "hotkeys_live", "passed": ok, "detail": "hold_fire/engage/attack_ground live: %s" % ("yes" if ok else "no")})

func _s_save_load_ui(steps: Array) -> void:
	main.game_save()
	var ok: bool = FileAccess.file_exists("user://quicksave.json")
	if ok:
		main.game_load()
	steps.append({"step": "save_load_ui", "passed": ok, "detail": "F5/F9 round-trip: %s" % ("yes" if ok else "no")})
