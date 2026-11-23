# Singleplayer shell: the menu the original opens with.
# Skirmish (random map: nation / map type / start option), Historical Battles
# (battle1..8 from data/game/var/battles.cfg) and Campaigns (from
# data/game/var/campaigns.cfg) - all read from assets/missions.json built by
# tools/build_missions.py. A mission pick only changes the setup (nations,
# map type, starting army, objectives): maps themselves are generated, like
# the port's skirmish map, because the .map heightmap has no public spec.
# NOTE: no class_name here on purpose - main.gd loads this via preload so
# headless test runs never depend on the editor's global class cache.
extends CanvasLayer

signal chosen(cfg: Dictionary)

const ConfigScript = preload("res://scripts/config.gd")
const Data = preload("res://scripts/data.gd")

var data: Dictionary = {}
var root: PanelContainer
var title_label: Label
var body: VBoxContainer
var nation0 := "rus"
var nation1 := "bav"
var opponents := 1
var teams_mode := "ffa"
# T-MENU-ROSTER: donor-like skirmish roster. `players` replaces the old 1..3
# opponents pick; the four parallel arrays are the per-slot UI state so the
# rows can be rebuilt whenever the player count changes. Team -1 = free for all.
var players := 2
var team_preset := "ffa"   # ffa | 2 | 3 | 4 (number of teams)
var roster_nations: Array = []
var roster_teams: Array = []
var roster_ai: Array = []
var roster_names: Array = []
# OWNER-SPEC: donor lobby has no Human/Computer toggle - the per-player AI
# difficulty dropdown IS the control ("None" = human slot). Keep roster_ai as
# a derived bool so the sim's existing is_ai path stays untouched.
var roster_difficulty: Array = []
var roster_team_buttons: Array[OptionButton] = []
# OWNER-SPEC: donor global dropdowns, emitted as cfg keys (port gaps documented
# in the rows below).
var allies := "default"          # Default | Nearby (start-placement hint)
var start_resources := "normal"  # Normal | Rich | Thousands | Millions | Random
# OWNER-SPEC deep donor dropdowns. Ids are canonical (data.gd DONOR_* tables);
# labels are defined once in the helpers below.
var balloon := "default"
var cannons := "default"
var peace_time := 0
var century18 := "default"
var capture := "default"
var market_dip := "default"
var pop_limit := 0
var adviser := "default"
var game_speed := "normal"
var autosave := "off"
var map_type := "land"
var start_option := "default"
var mode := "skirmish"
var mission_name := ""
var difficulty := "normal"
var map_size := 320
var seed_val := Data.RANDOM_SEED
# Donor skirmish map options (RC_TERRAIN §2.1 / GUIDE4 App.B02). Map Size and
# Teams already have rows below; these four complete the donor's six-option set.
var terrain_type := "land"   # donor Map Shape; enum Data.MAP_TYPES (generator.cfg TerrainTypes)
var richness := "med"        # donor Minerals/Richness: low / med / rich
var season := "summer"       # donor Season; enum Data.BIOME = summer / winter / desert
var relief := "plain"        # donor Relief id (6 values in Data.DONOR_RELIEF)
var ui_us := 1.0
var ui_vp := Vector2(1280, 720)
var menu_scroll: ScrollContainer
var action_bar: HBoxContainer
var main_menu_active := true

func _ready() -> void:
	layer = 20
	_load_data()
	_build()
	_apply_scale()
	if is_instance_valid(get_tree()) and is_instance_valid(get_tree().root) and not get_tree().root.size_changed.is_connected(_on_vp_resize):
		get_tree().root.size_changed.connect(_on_vp_resize)

# Donor main-menu mnemonics (DE_AUDIO_UI fnd_20; hotkeys.cfg ev_cf45b67… /
# ev_7d1a569…): C Campaign / R Random map / S Settings / E Editor / L Load /
# X Exit / M Multiplayer, fired on key-up. E (editor) and M (network) have no
# port screen and are out of scope by owner charter, so they are deferred.
func _unhandled_input(event: InputEvent) -> void:
	if not main_menu_active or not (event is InputEventKey):
		return
	var k := event as InputEventKey
	if k.echo or k.pressed or k.ctrl_pressed or k.alt_pressed or k.meta_pressed:
		return
	match k.keycode:
		KEY_C: _show_campaigns()
		KEY_R: _show_skirmish()
		KEY_S: _show_options()
		KEY_L: _on_load_game()
		KEY_X: get_tree().quit()

func _on_vp_resize() -> void:
	ui_us = _calc_us()
	_apply_scale()

func _calc_us() -> float:
	var s := Vector2(1280, 720)
	if is_instance_valid(get_viewport()):
		s = get_viewport().get_visible_rect().size
	ui_vp = s
	return ConfigScript.ui_scale_for(s)

func _fs(base: int) -> int:
	return maxi(10, int(round(float(base) * ui_us)))

func _mh(base: float) -> float:
	return base * ui_us

# Walk the whole menu tree and apply the current scale to every widget that
# opted in via set_meta("uifs"/"uimh"/"uimw"...). Static chrome is
# tagged at build time; dynamic rows re-tag on creation. The card itself is
# bounded to the viewport (width + content-aware scroll height) so content
# can never clip, at any window size.
func _apply_scale() -> void:
	for n in find_children("*", "Control", true, false):
		var c := n as Control
		if c == null:
			continue
		if c.has_meta("uifs"):
			c.add_theme_font_size_override("font_size", _fs(int(c.get_meta("uifs"))))
		var mw := float(c.get_meta("uimw", 0.0))
		var mh := float(c.get_meta("uimh", 0.0))
		if mw > 0.0 or mh > 0.0:
			var cur: Vector2 = c.custom_minimum_size
			c.custom_minimum_size = Vector2(_mh(mw) if mw > 0.0 else cur.x, _mh(mh) if mh > 0.0 else cur.y)
	if is_instance_valid(root) and is_instance_valid(menu_scroll) and is_instance_valid(body):
		root.custom_minimum_size.x = minf(560.0 * ui_us, ui_vp.x * 0.94)
		# Deterministic content height from row types (buttons 40, option /
		# seed rows 38, labels 40 + separations): measuring combined minimums
		# is unreliable because autowrapped labels report per-character-wrap
		# heights when unconstrained (blew the card up to 2.5k px).
		var want := 0.0
		for ch in body.get_children():
			if ch is BaseButton:
				want += 40.0 * ui_us
			elif ch is HBoxContainer:
				want += 34.0 * ui_us
			elif ch is Label:
				want += 32.0 * ui_us
			want += 8.0 * ui_us
		var avail: float = maxf(120.0, ui_vp.y * 0.86 - 150.0 * ui_us)
		menu_scroll.custom_minimum_size.y = minf(want, avail)

func _load_data() -> void:
	var paths := ["res://assets/missions.json", "user://missions.json"]
	for p in paths:
		if FileAccess.file_exists(p):
			var f := FileAccess.open(p, FileAccess.READ)
			if f:
				var v: Variant = JSON.parse_string(f.get_as_text())
				f.close()
				if v is Dictionary:
					data = v
					return

func _nations() -> Array:
	if data.has("nations"):
		return data.nations
	return [{"id": "ukr", "name": "Ukraine"}, {"id": "rus", "name": "Russia"}]

# OWNER-SPEC deep: all 9 donor Map Shapes + Random (gui.txt:413-434,855-862).
# Data.DONOR_MAP_SHAPES maps each to the nearest generator mask family; the
# approximations are documented in docs/DONOR_OPTIONS_GAPS.md.
func _terrain_types() -> Array:
	var out := []
	for k in Data.DONOR_MAP_SHAPES:
		out.append({"id": str(k), "name": str(Data.DONOR_MAP_SHAPES[k].get("name", k))})
	return out

# Generic item builder for a canonical DONOR_* id table / array.
func _donor_items(ids: Array, labels: Dictionary) -> Array:
	var out := []
	for id in ids:
		out.append({"id": str(id), "name": str(labels.get(id, id))})
	return out

func _relief_types() -> Array:
	var labels := {"plain": "Plain", "low_mountains": "Low Mountains",
		"high_mountains": "High Mountains", "highlands": "Highlands",
		"plateaus": "Plateaus", "random": "Random"}
	return _donor_items(Data.DONOR_RELIEF.keys(), labels)

func _peace_items() -> Array:
	var out := []
	for m in Data.DONOR_PEACE_TIMES:
		out.append({"id": str(m), "name": "No" if int(m) == 0 else "%d min" % int(m)})
	return out

func _pop_items() -> Array:
	var out := []
	for n in Data.DONOR_POP_LIMITS:
		out.append({"id": str(n), "name": "Without limitation" if int(n) == 0 else "%d units" % int(n)})
	return out

func _section_label(text: String) -> Label:
	var l := _lbl("— %s —" % text, 12, Color(0.85, 0.72, 0.35))
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l

func _starts() -> Array:
	if data.has("start_options"):
		return data.start_options
	return [{"id": "default", "name": "Town + peasants", "descr": ""}]

func _campaigns() -> Array:
	return data.get("campaigns", [])

func _battles() -> Array:
	return data.get("battles", [])

func _build() -> void:
	ui_us = _calc_us()
	# Full-rect centering + a card that can never outgrow the window: the
	# body scrolls instead of clipping, at any window size or aspect.
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	root = PanelContainer.new()
	root.add_theme_stylebox_override("panel", ConfigScript.ui_panel_style())
	center.add_child(root)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 10)
	root.add_child(vb)
	title_label = Label.new()
	title_label.text = "CossacksGodot — singleplayer"
	title_label.set_meta("uifs", 30)
	title_label.add_theme_color_override("font_color", Color(1, 0.9, 0.5))
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(title_label)
	var sub := Label.new()
	sub.text = "Skirmish · historical battles · campaigns"
	sub.set_meta("uifs", 14)
	sub.add_theme_color_override("font_color", Color(0.8, 0.78, 0.7))
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(sub)
	menu_scroll = ScrollContainer.new()
	menu_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vb.add_child(menu_scroll)
	body = VBoxContainer.new()
	body.add_theme_constant_override("separation", 8)
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	menu_scroll.add_child(body)
	# Pinned action row: a sibling of the scroll area, never inside it, so
	# Start/Back stay clickable even when the option rows need scrolling.
	action_bar = HBoxContainer.new()
	action_bar.add_theme_constant_override("separation", 8)
	action_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.add_child(action_bar)
	_show_main()

func _clear() -> void:
	main_menu_active = false
	for c in body.get_children():
		body.remove_child(c)
		c.queue_free()
	for c in action_bar.get_children():
		action_bar.remove_child(c)
		c.queue_free()

func _btn(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, 40)
	b.set_meta("uimh", 40.0)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.set_meta("uifs", 15)
	ConfigScript.ui_style_button(b)
	return b

func _lbl(text: String, fs := 13, col := Color(0.75, 0.72, 0.65)) -> Label:
	var l := Label.new()
	l.text = text
	l.set_meta("uifs", fs)
	l.add_theme_color_override("font_color", col)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l

func _show_main() -> void:
	_clear()
	main_menu_active = true
	var b1 := _btn("Skirmish - random map")
	b1.pressed.connect(_show_skirmish)
	body.add_child(b1)
	var b2 := _btn("Historical battles (%d)" % _battles().size())
	b2.pressed.connect(_show_battles)
	body.add_child(b2)
	var b3 := _btn("Campaigns (%d)" % _campaigns().size())
	b3.pressed.connect(_show_campaigns)
	body.add_child(b3)
	var lb := _btn("Load game")
	lb.pressed.connect(_on_load_game)
	body.add_child(lb)
	var ob := _btn("Options")
	ob.pressed.connect(_show_options)
	body.add_child(ob)
	var qb := _btn("Quit")
	qb.pressed.connect(func(): get_tree().quit())
	body.add_child(qb)
	var hint := _lbl("Maps are generated in the original's style (open plains, forest belts, hills, lakes). Picks change nations, armies and objectives.", 12, Color(0.7, 0.7, 0.65))
	body.add_child(hint)
	_apply_scale()

func _opt_row(label_text: String, items: Array, current: String, on_pick: Callable) -> HBoxContainer:
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 10)
	var l := Label.new()
	l.text = label_text
	l.custom_minimum_size = Vector2(150, 0)
	l.set_meta("uimw", 150.0)
	l.set_meta("uifs", 14)
	hb.add_child(l)
	var ob := OptionButton.new()
	ob.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ConfigScript.ui_style_button(ob)
	ob.set_meta("uifs", 14)
	var sel := 0
	for i in items.size():
		var it: Dictionary = items[i]
		ob.add_item(str(it.get("name", it.get("id", "?"))), i)
		if str(it.get("id", "")) == current:
			sel = i
	ob.selected = sel
	ob.item_selected.connect(func(i: int): on_pick.call(str(items[i].get("id", ""))))
	hb.add_child(ob)
	return hb

# ------------------------------------------------------------------- roster UI
# The donor lobby's per-player list layout is inferred, not byte-verified:
# the readable build exposes 2..8 slots, faction 0..3 and the team presets,
# but not the exact widget arrangement. This reproduces the information in a
# compact row that still fits the 1280x720 scaled card.

func _all_nations() -> Array:
	var keys := Data.NATIONS.keys()
	keys.sort()
	var out := []
	for k in keys:
		var sid := str(k)
		out.append({"id": sid, "name": str(Data.NATIONS[sid].get("name", sid))})
	return out

func _nation_display_name(sid: String, i: int) -> String:
	if Data.NATIONS.has(sid):
		return str(Data.NATIONS[sid].get("name", sid))
	return "Player %d" % (i + 1)

func _player_items() -> Array:
	var out := []
	for n in range(2, Data.MAX_PLAYERS + 1):
		out.append({"id": str(n), "name": str(n)})
	return out

# OWNER-SPEC (showcustomgame.inc:685-689): exactly '-' | 1 | 2 | 3 | 4 - five
# entries, max four teams. '-' is stored as team -1 (free for all).
func _team_items() -> Array:
	var out := [{"id": "-1", "name": "-"}]
	for t in range(1, 5):
		out.append({"id": str(t - 1), "name": str(t)})
	return out

# OWNER-SPEC (en\gui.txt:153-162, showcustomgame.inc:73-86): per-player AI
# difficulty replaces the plain Human/Computer pick. "None" => human slot.
func _ai_items() -> Array:
	return [{"id": "none", "name": "None"},
		{"id": "normal", "name": "Normal"}, {"id": "hard", "name": "Hard"},
		{"id": "veryhard", "name": "Very Hard"},
		{"id": "impossible", "name": "Impossible"}]

# The sim only knows easy/normal/hard globally; collapse the two hardest donor
# tiers onto "hard" and keep the donor id alongside for config/UI fidelity.
func _sim_difficulty(donor_id: String) -> String:
	match donor_id:
		"none": return "none"
		"hard", "veryhard", "impossible": return "hard"
		_: return "normal"

# Read-only copy of hud.gd MM_PLAYER_COLORS (that lane owns the palette); used
# only for the donor's per-player Color swatch, never for gameplay logic.
const ROSTER_COLORS := [
	Color(0.30, 0.62, 1.00), Color(1.00, 0.32, 0.26),
	Color(1.00, 0.78, 0.22), Color(0.42, 0.85, 0.42),
	Color(0.70, 0.45, 1.00), Color(0.25, 0.85, 0.85),
	Color(1.00, 0.55, 0.72), Color(0.85, 0.85, 0.85),
]

func _team_preset_items() -> Array:
	return [{"id": "ffa", "name": "Free for all"},
		{"id": "2", "name": "2 teams"}, {"id": "3", "name": "3 teams"},
		{"id": "4", "name": "4 teams"}]

# Small OptionButton used inside a roster row. Metadata carries the id so the
# callback receives a stable string even when the list is rebuilt. uifs/uimw
# tags keep it inside _apply_scale's scaling pass.
func _mini_option(items: Array, current: String, cb: Callable, minw: float, expand := false) -> OptionButton:
	var ob := OptionButton.new()
	ob.set_meta("uifs", 12)
	ob.set_meta("uimw", minw)
	ob.custom_minimum_size = Vector2(_mh(minw), 0)
	ob.size_flags_horizontal = Control.SIZE_EXPAND_FILL if expand else Control.SIZE_SHRINK_END
	ConfigScript.ui_style_button(ob)
	for i in items.size():
		var it: Dictionary = items[i]
		var id := str(it.get("id", ""))
		ob.add_item(str(it.get("name", id)))
		ob.set_item_metadata(ob.item_count - 1, id)
		if id == current:
			ob.selected = i
	ob.item_selected.connect(func(idx: int): cb.call(str(ob.get_item_metadata(idx))))
	return ob

func _sync_legacy() -> void:
	# Keep the legacy keys consistent if a caller falls back to the old path.
	if roster_nations.size() > 0:
		nation0 = str(roster_nations[0])
	if roster_nations.size() > 1:
		nation1 = str(roster_nations[1])
	opponents = maxi(0, players - 1)

# Resize / fill the parallel roster arrays without touching the widgets. New
# slots inherit the legacy nation picks, then unused donor nations; P1 starts
# Human and the rest Computer.
func _ensure_roster() -> void:
	players = clampi(players, 2, Data.MAX_PLAYERS)
	roster_nations.resize(players)
	roster_teams.resize(players)
	roster_ai.resize(players)
	roster_names.resize(players)
	roster_difficulty.resize(players)
	roster_team_buttons.resize(players)
	var fallback := _all_nations()
	for i in players:
		var sid := str(roster_nations[i])
		if sid == "" or not Data.NATIONS.has(sid):
			if i == 0 and Data.NATIONS.has(nation0):
				sid = nation0
			elif i == 1 and Data.NATIONS.has(nation1):
				sid = nation1
			else:
				for nd in fallback:
					var cand := str(nd.get("id", ""))
					if not roster_nations.has(cand):
						sid = cand
						break
			if sid == "":
				sid = str(fallback[0].get("id", "rus"))
			roster_nations[i] = sid
		# P1 defaults to "None" (human); the rest to Normal computer.
		var diff := str(roster_difficulty[i])
		if diff == "" or not ["none", "normal", "hard", "veryhard", "impossible"].has(diff):
			diff = "none" if i == 0 else "normal"
		roster_difficulty[i] = diff
		roster_ai[i] = diff != "none"
		if str(roster_names[i]) == "":
			roster_names[i] = _nation_display_name(str(roster_nations[i]), i)
		if not (roster_teams[i] is int):
			roster_teams[i] = -1
	_sync_legacy()

# Spread k teams evenly over the roster: 4 players / 2 teams -> 0,0,1,1.
func _apply_team_preset() -> void:
	var k := 0 if team_preset == "ffa" else clampi(int(team_preset), 2, 4)
	for i in players:
		roster_teams[i] = -1 if k <= 0 else int(i * k / players)
	_sync_legacy()

# Tear down and recreate the P1..Pn rows after a player-count or preset change.
func _rebuild_roster() -> void:
	for c in body.get_children():
		if c.has_meta("roster_row"):
			body.remove_child(c)
			c.queue_free()
	roster_team_buttons.clear()
	_ensure_roster()
	_apply_team_preset()
	# Re-insert directly after the "Team preset" row.
	var at := 0
	for c in body.get_children():
		if c.has_meta("team_preset_row"):
			at = c.get_index() + 1
			break
	for i in players:
		var row := _roster_row(i)
		body.add_child(row)
		body.move_child(row, at)
		at += 1
	_apply_scale()

func _roster_row(i: int) -> HBoxContainer:
	var hb := HBoxContainer.new()
	hb.set_meta("roster_row", true)
	hb.add_theme_constant_override("separation", 4)
	var tag := _lbl("P%d" % (i + 1), 12, Color(0.95, 0.88, 0.65))
	tag.custom_minimum_size = Vector2(_mh(26.0), 0)
	tag.set_meta("uimw", 26.0)
	hb.add_child(tag)
	var on_nation := func(id: String, pi: int) -> void:
		roster_nations[pi] = id
		roster_names[pi] = _nation_display_name(id, pi)
		_sync_legacy()
	hb.add_child(_mini_option(_all_nations(), str(roster_nations[i]), on_nation.bind(i), 132.0, true))
	var on_team := func(id: String, pi: int): roster_teams[pi] = int(id)
	var team_ob := _mini_option(_team_items(), str(roster_teams[i]), on_team.bind(i), 76.0)
	hb.add_child(team_ob)
	roster_team_buttons[i] = team_ob
	var on_ctrl := func(id: String, pi: int):
		roster_difficulty[pi] = id
		roster_ai[pi] = id != "none"
	hb.add_child(_mini_option(_ai_items(), str(roster_difficulty[i]), on_ctrl.bind(i), 100.0))
	# OWNER-SPEC donor column "Color": read-only swatch matching the player's
	# slot tint (same palette as world.gd _player_color / hud.gd minimap).
	var swatch := ColorRect.new()
	swatch.color = ROSTER_COLORS[wrapi(i, 0, ROSTER_COLORS.size())]
	swatch.custom_minimum_size = Vector2(_mh(18.0), _mh(16.0))
	swatch.set_meta("uimw", 18.0)
	swatch.set_meta("uimh", 16.0)
	swatch.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hb.add_child(swatch)
	return hb

func _roster_cfg() -> Array:
	_ensure_roster()
	var out := []
	for i in players:
		var diff := str(roster_difficulty[i])
		out.append({"nation": str(roster_nations[i]), "team": int(roster_teams[i]),
			"ai": bool(roster_ai[i]), "name": str(roster_names[i]),
			"ai_difficulty": diff, "difficulty": _sim_difficulty(diff)})
	return out

func _show_skirmish() -> void:
	_clear()
	mode = "skirmish"
	# OWNER-SPEC: donor player list is Player | Nation | Team | Color with a
	# per-player AI-difficulty dropdown; 8 slots, min 2 inferred. The rows below
	# are rebuilt whenever the player count or team preset changes.
	_ensure_roster()
	body.add_child(_opt_row("Players", _player_items(), str(players), func(id: String):
		players = int(id)
		_rebuild_roster()))
	var tp := _opt_row("Team preset", _team_preset_items(), team_preset, func(id: String):
		team_preset = id
		_rebuild_roster())
	tp.set_meta("team_preset_row", true)
	body.add_child(tp)
	_rebuild_roster()
	# OWNER-SPEC deep donor lobby. Rows are grouped by labelled section headers;
	# the scroll container keeps all of them reachable at 1280x720. Exact donor
	# support status for every row is in docs/DONOR_OPTIONS_GAPS.md.
	body.add_child(_section_label("Map"))
	body.add_child(_opt_row("Map shape", _terrain_types(), terrain_type, func(id: String): terrain_type = id; map_type = id))
	body.add_child(_opt_row("Relief", _relief_types(), relief, func(id: String): relief = id))
	body.add_child(_opt_row("Season", [{"id": "summer", "name": "Summer"}, {"id": "desert", "name": "Desert"}, {"id": "winter", "name": "Winter"}], season, func(id: String): season = id))
	# OWNER-SPEC: donor Map Size = Tiny | Normal | Large 2x | Huge 4x.
	# Port metric mapping is an inference (generator takes raw tile counts):
	# Tiny=240, Normal=320, Large 2x=400, Huge 4x=480.
	body.add_child(_opt_row("Map size", [{"id": "240", "name": "Tiny"}, {"id": "320", "name": "Normal"}, {"id": "400", "name": "Large 2x"}, {"id": "480", "name": "Huge 4x"}], str(map_size), func(id: String): map_size = int(id)))
	body.add_child(_section_label("Resources & placement"))
	body.add_child(_opt_row("Minerals", [{"id": "low", "name": "Poor"}, {"id": "med", "name": "Medium"}, {"id": "rich", "name": "Rich"}, {"id": "random", "name": "Random"}], richness, func(id: String): richness = id))
	body.add_child(_opt_row("Starting resources", [{"id": "normal", "name": "Normal"}, {"id": "rich", "name": "Rich"}, {"id": "thousands", "name": "Thousands"}, {"id": "millions", "name": "Millions"}, {"id": "random", "name": "Random"}], start_resources, func(id: String): start_resources = id))
	body.add_child(_opt_row("Allies", [{"id": "default", "name": "Default"}, {"id": "nearby", "name": "Nearby"}], allies, func(id: String): allies = id))
	body.add_child(_section_label("Rules"))
	body.add_child(_opt_row("Starting", _starts(), start_option, func(id: String): start_option = id))
	body.add_child(_opt_row("Difficulty", [{"id": "easy", "name": "Easy"}, {"id": "normal", "name": "Normal"}, {"id": "hard", "name": "Hard"}], difficulty, func(id: String): difficulty = id))
	body.add_child(_opt_row("Balloon", _donor_items(Data.DONOR_BALLOON,
		{"default": "Default", "no_balloons": "No Balloons", "balloons": "Balloons"}),
		balloon, func(id: String): balloon = id))
	body.add_child(_opt_row("Cannons", _donor_items(Data.DONOR_CANNONS,
		{"default": "Default", "no_cannons_towers_walls": "No Cannons Towers Walls", "expensive_cannons": "Expensive Cannons"}),
		cannons, func(id: String): cannons = id))
	body.add_child(_opt_row("Peace time", _peace_items(), str(peace_time), func(id: String): peace_time = int(id)))
	body.add_child(_opt_row("18th century", _donor_items(Data.DONOR_CENTURY18,
		{"default": "Default", "never": "Never", "immediately": "Immediately"}),
		century18, func(id: String): century18 = id))
	body.add_child(_opt_row("Capture", _donor_items(Data.DONOR_CAPTURE,
		{"default": "Default", "no_peasants": "No Capturing Peasants",
		"no_peasants_or_centres": "No Peasants or Centres", "artillery_only": "Artillery Only"}),
		capture, func(id: String): capture = id))
	body.add_child(_opt_row("Dip.center & market", _donor_items(Data.DONOR_MARKET_DIP,
		{"default": "Default", "without_dip_center": "Without dip.center",
		"without_market": "Without market", "without_both": "Without both"}),
		market_dip, func(id: String): market_dip = id))
	body.add_child(_opt_row("Pop limit", _pop_items(), str(pop_limit), func(id: String): pop_limit = int(id)))
	body.add_child(_opt_row("Adviser", _donor_items(Data.DONOR_ADVISER,
		{"default": "Default", "with": "With", "without": "Without"}), adviser, func(id: String): adviser = id))
	body.add_child(_opt_row("Autosave", _donor_items(Data.DONOR_AUTOSAVE,
		{"off": "Off", "on": "On", "every_5_min": "Every 5 min"}), autosave, func(id: String): autosave = id))
	body.add_child(_opt_row("Game speed", _donor_items(Data.DONOR_GAME_SPEED.keys(),
		{"slow": "Slow", "normal": "Normal", "fast": "Fast", "very_fast": "Very fast"}),
		game_speed, func(id: String): game_speed = id))
	var shb := HBoxContainer.new()
	shb.add_theme_constant_override("separation", 10)
	var sl := Label.new()
	sl.text = "Seed"
	sl.custom_minimum_size = Vector2(150, 0)
	sl.set_meta("uimw", 150.0)
	sl.set_meta("uifs", 14)
	shb.add_child(sl)
	var seedbox := SpinBox.new()
	seedbox.min_value = 0
	seedbox.max_value = 99999999
	seedbox.value = seed_val
	seedbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	seedbox.set_meta("uifs", 14)
	seedbox.value_changed.connect(func(v: float): seed_val = int(v))
	shb.add_child(seedbox)
	body.add_child(shb)
	var go := _btn("Start skirmish")
	go.pressed.connect(func(): _emit_start("Skirmish"))
	action_bar.add_child(go)
	var back := _btn("Back")
	back.pressed.connect(_show_main)
	action_bar.add_child(back)
	_apply_scale()

func _show_battles() -> void:
	_clear()
	for b in _battles():
		var bd: Dictionary = b
		var bb := _btn("Battle %s" % str(bd.get("id", "?")).replace("battle", ""))
		bb.tooltip_text = str(bd.get("name", ""))
		bb.pressed.connect(_on_battle.bind(bd))
		body.add_child(bb)
	var back := _btn("Back")
	back.pressed.connect(_show_main)
	action_bar.add_child(back)
	_apply_scale()

func _on_battle(bd: Dictionary) -> void:
	mode = "battle"
	mission_name = str(bd.get("id", "battle1"))
	start_option = "armylarge"
	_emit_start("Historical battle %s" % mission_name)

func _show_campaigns() -> void:
	_clear()
	var prog := {}
	if FileAccess.file_exists("user://campaign_progress.json"):
		var v = JSON.parse_string(FileAccess.get_file_as_string("user://campaign_progress.json"))
		if v is Dictionary:
			prog = v
	for c in _campaigns():
		var cd: Dictionary = c
		var missions: Array = cd.get("missions", [])
		for mi in missions.size():
			var mid := str(missions[mi])
			var mb := _btn("%s - %s" % [str(cd.get("id", "?")), mid])
			var locked := mi > 0 and not bool(prog.get(str(missions[mi - 1]), false))
			mb.disabled = locked
			if locked:
				mb.tooltip_text = "Win the previous mission to unlock"
			else:
				mb.tooltip_text = mid
			mb.pressed.connect(_on_mission.bind(cd, mid))
			body.add_child(mb)
	var back := _btn("Back")
	back.pressed.connect(_show_main)
	action_bar.add_child(back)
	_apply_scale()

func _on_mission(cd: Dictionary, mid: String) -> void:
	mode = "campaign"
	mission_name = mid
	start_option = "default"
	_emit_start("Campaign %s - %s" % [str(cd.get("id", "")), mission_name])

func _on_campaign(cd: Dictionary) -> void:
	var missions: Array = cd.get("missions", [])
	mode = "skirmish" if missions.is_empty() else "campaign"
	mission_name = str(missions[0]) if not missions.is_empty() else str(cd.get("id", ""))
	start_option = "default"
	_emit_start("Campaign %s - %s" % [str(cd.get("id", "")), mission_name])

func _on_load_game() -> void:
	_clear()
	var found: Array = []
	if FileAccess.file_exists("user://quicksave.json"):
		found.append("user://quicksave.json")
	for i in 5:
		var p := "user://save_%d.json" % i
		if FileAccess.file_exists(p):
			found.append(p)
	if found.is_empty():
		var l := _lbl("No saves found")
		body.add_child(l)
	else:
		for p in found:
			var b := _btn(p.get_file())
			b.pressed.connect(func(): chosen.emit({"mode": mode, "nation0": nation0, "nation1": nation1, "map_type": map_type, "start_option": start_option, "mission": mission_name, "descr": "loaded", "load_save": p, "difficulty": difficulty, "map_size": map_size, "seed": seed_val}))
			body.add_child(b)
	var back := _btn("Back")
	back.pressed.connect(_show_main)
	action_bar.add_child(back)
	_apply_scale()

# Menu-side seed UI. The value always travels through cfg["seed"] as an int:
# main.gd applies it with int(cfg.seed), so a literal "random" string cannot be
# passed through the menu (that would need a main.gd change). The Random button
# generates a fresh int instead - the same thing main.gd's --seed random does.
func _random_seed_value() -> int:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	return rng.randi_range(0, 99999999)

func _on_seed_text_changed(text: String, field: LineEdit) -> void:
	var s := text.strip_edges()
	if s.is_valid_int():
		seed_val = int(s)
		Data.RANDOM_SEED = seed_val
	elif s.to_lower() == "random":
		seed_val = _random_seed_value()
		Data.RANDOM_SEED = seed_val
		field.text = str(seed_val)  # re-enters as a valid int; no loop

func _show_options() -> void:
	_clear()
	body.add_child(_opt_row("Difficulty", [{"id": "easy", "name": "Easy"}, {"id": "normal", "name": "Normal"}, {"id": "hard", "name": "Hard"}], difficulty, func(id: String): difficulty = id; _save_options()))
	var shb := HBoxContainer.new()
	shb.add_theme_constant_override("separation", 10)
	var sl := Label.new()
	sl.text = "Map seed"
	sl.custom_minimum_size = Vector2(150, 0)
	sl.set_meta("uimw", 150.0)
	sl.set_meta("uifs", 14)
	shb.add_child(sl)
	var seedbox := LineEdit.new()
	seedbox.text = str(seed_val)
	seedbox.set_meta("uifs", 14)
	seedbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var st := ConfigScript.ui_button_styles()
	seedbox.add_theme_stylebox_override("normal", st["normal"] as StyleBoxFlat)
	seedbox.text_changed.connect(_on_seed_text_changed.bind(seedbox))
	shb.add_child(seedbox)
	var rb := _btn("Random")
	rb.custom_minimum_size = Vector2(90, 40)
	rb.size_flags_horizontal = Control.SIZE_SHRINK_END
	rb.pressed.connect(func():
		seed_val = _random_seed_value()
		Data.RANDOM_SEED = seed_val
		seedbox.text = str(seed_val)
	)
	shb.add_child(rb)
	body.add_child(shb)
	var back := _btn("Back")
	back.pressed.connect(_show_main)
	action_bar.add_child(back)
	_apply_scale()

func _save_options() -> void:
	var f := FileAccess.open("user://options.json", FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({"ai": {"difficulty": difficulty}}))
		f.close()

func _emit_start(descr: String) -> void:
	var cfg := {"mode": mode, "nation0": nation0, "nation1": nation1,
		"opponents": opponents, "teams": teams_mode,
		"map_type": map_type, "terrain_type": terrain_type,
		"richness": richness, "season": season, "relief": relief,
		"start_option": start_option,
		"mission": mission_name, "descr": descr,
		"difficulty": difficulty, "map_size": map_size, "seed": seed_val,
		# OWNER-SPEC full donor serialized struct (miscext2.script). Legacy keys
		# above are kept for old callers; main.gd prefers these canonical keys.
		"terraintype": terrain_type, "relieftype": relief,
		"resourcestart": start_resources, "resourcemines": richness,
		"mapsize": map_size, "startingunits": start_option,
		"balloon": balloon, "cannons": cannons, "peacetime": peace_time,
		"century18": century18, "capture": capture, "marketdip": market_dip,
		"autosave": autosave, "limit": pop_limit,
		"gamespeed": game_speed, "adviserassistant": adviser,
		"allies": allies}
	# Only skirmish emits the roster: historical battles / campaigns keep their
	# mission-driven nations and therefore stay on the legacy path in main.gd.
	if mode == "skirmish":
		var roster := _roster_cfg()
		if not roster.is_empty():
			cfg["players"] = roster
			# Preserve legacy keys for old callers, mirrored from the roster.
			cfg["nation0"] = str(roster[0].get("nation", nation0))
			if roster.size() > 1:
				cfg["nation1"] = str(roster[1].get("nation", nation1))
			cfg["opponents"] = maxi(0, roster.size() - 1)
			cfg["teams"] = team_preset
	chosen.emit(cfg)
