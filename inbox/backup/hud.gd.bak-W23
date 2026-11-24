# HUD: resource bar, selection panel, build/train menus, minimap, messages.
extends CanvasLayer
class_name C3HUD

const Data = preload("res://scripts/data.gd")
const ConfigScript = preload("res://scripts/config.gd")

var game: C3Game
var world: C3World
var icons_tex: Texture2D
var units_tex: Texture2D
var top_panel: PanelContainer
var res_labels: Array = []
# Donor-style economy read-outs (RE gap 3 / S11): bracketed worker counts per
# resource, idle-villager + free mine-slot indicators and a gold deficit flag.
# All derived from existing game state; no sim-layer changes.
var eco_label: Label
var worker_counts: Dictionary = {}
var idle_count := 0
var free_slots_count := 0
var gold_deficit := false
var eco_t := 0.0
# T-PERF-RENDER: unit/queue counts are O(live units + buildings); refresh them
# on the same ~0.5 s cadence as the economy read-out instead of every frame.
var _cached_ucount := 0
var res_deficit: Array = [false, false, false, false, false, false]
var eco_warn := false
var sel_panel: PanelContainer
var sel_box: HBoxContainer
var build_bar: HFlowContainer
var msg_label: Label
var msg_timer := 0.0
var status_label: Label
var settings_label: Label
var minimap_tex: ImageTexture
var minimap_img: Image          # clean working image (terrain + blips, no box)
var minimap_base: Image
var minimap_view_img: Image     # displayed image (clean + viewport box)
var _mm_box_last := Vector4i(-1, -1, -1, -1)  # x0,y0,x1,y1 of last drawn box
var minimap_rect: TextureRect
var minimap_panel: PanelContainer
var mm_timer := 0.0
# T-PERF-RENDER: fog-dimmed terrain cache. The full-map dim pass (100k pixels)
# only rebuilds when world.fog_revision moves; blips still repaint every tick.
var minimap_fog_base: Image = null
var minimap_fog_rev := -1
# T-MINIMAP: mine/quarry marker centres + colours. res_nodes are mostly static,
# so the list is rebuilt only when game.res_dirty moves (never per frame/tick).
var _mm_mine_centers: Array[Vector2i] = []
var _mm_mine_colors: Array[Color] = []
var _mm_mine_ver := -1
# T-MINIMAP-EXTRA: entity blip layers. Buildings are immutable until bld_dirty;
# unit dots are refreshed once per MINIMAP_INTERVAL (their movement source).
# All buffers are reused across ticks — no per-frame/per-tick allocations.
var _mm_bld_centers: Array[Vector2i] = []
var _mm_bld_colors: Array[Color] = []
var _mm_bld_enemy: Array[bool] = []
var _mm_bld_ver := -1
var _mm_unit_tiles: Array[Vector2i] = []
var _mm_unit_colors: Array[Color] = []
var _mm_unit_players: Array[int] = []
var _mm_unit_enemy: Array[bool] = []
var _mm_unit_dots: Array[int] = []
var _mm_unit_counts := PackedInt32Array()
var _mm_cluster_map: Dictionary = {}
var _mm_cluster_sx: Array[int] = []
var _mm_cluster_sy: Array[int] = []
var _mm_cluster_cnt: Array[int] = []
var _mm_cluster_colors: Array[Color] = []
var _mm_cluster_enemy: Array[bool] = []
var _mm_cluster_cols := 0
var _mm_cluster_rows := 0
# T-PERF-RENDER: last pushed texts — Label.text assignment costs a relayout
# even when the string is identical, so every per-frame label is dirty-flagged.
var _last_res_text: Array = []
var _last_eco_text := ""
var _last_status_text := "\n"
var fps_label: Label
var fps_t := 0.0
var fps_ema := 60.0
var sel_timer := 0.75
var build_menu_open := false
var build_buttons: Dictionary = {}   # sid -> Button
var train_buttons: Dictionary = {}   # sid -> Button
var build_ghost_sid := ""
var game_over_label: Label
var audio_click: AudioStreamPlayer
var hint_label: Label
var speed_cb: Callable
var menu_cb: Callable
var speed_buttons: Array = []
var speed_label: Label
var obj_panel: PanelContainer
var obj_box: VBoxContainer
var trade_amount := 100.0
# MICRO #9: three distinct market operations over the sim's existing
# game.trade(player, give, want, amount). Gold is handled by Buy/Sell; the
# resource pair selectors feed Exchange. Data.MARKET* supplies the rate/floor.
const MARKET_TRADABLE := ["food", "wood", "stone", "iron", "coal"]
# T-MINIMAP: bright amber-family marker per mine/quarry ore (distinct hues,
# all readable on the dimmed terrain); the dark rim keeps them crisp.
const MINE_MARKER_COLORS := {
	"gold": Color(1.0, 0.86, 0.18),
	"iron": Color(1.0, 0.58, 0.18),
	"coal": Color(0.98, 0.78, 0.40),
	"stone": Color(0.94, 0.89, 0.62),
}
const MINE_MARKER_RIM := Color(0.05, 0.04, 0.03)
# T-MINIMAP-BRIGHT: player tints (0 = local player, blue; 1 = red). High
# saturation + high luminance so blips stay legible over the dark, fog-dimmed
# minimap. Static constants, so no player-colour revision is needed for caches.
# T-HUD-12: extended 8 -> 12 to match world.gd PLAYER_COLORS / menu.gd
# ROSTER_COLORS. P0..P7 keep hud's brighter variants; P8..P11 from world.gd
# (teal/amber brightened for legibility). P7 is white; wrapi handles p>=12.
const MM_PLAYER_COLORS := [
	Color(0.35, 0.75, 1.00), Color(1.00, 0.35, 0.30),
	Color(1.00, 0.85, 0.20), Color(0.35, 1.00, 0.45),
	Color(0.85, 0.50, 1.00), Color(0.30, 1.00, 1.00),
	Color(1.00, 0.50, 0.85), Color(1.00, 1.00, 1.00),
	Color(1.00, 0.60, 0.10), Color(0.55, 0.95, 0.30),
	Color(0.12, 0.88, 0.80), Color(0.88, 0.58, 0.30),
]
const MM_ENEMY_RIM := Color(0.34, 0.02, 0.02)  # dark red ring on enemy blips
const MM_OWN_RIM := Color(0.04, 0.05, 0.03)    # near-black ring on friendly blips
const MM_CLUSTER_THRESHOLD := 16   # per player: above this, group into blips
const MM_CLUSTER_CELL := 4         # tiles per cluster bucket
var market_give_idx := 1   # wood
var market_want_idx := 3   # iron
var want_rally := false
var last_ids: Array = []
var summary_label: Label
var prog_entries: Array = []  # {label, e}
var dyn_buttons: Array = []   # {b, kind, e, sid, uid}
var cmd_panel: PanelContainer
var cmd_bar: GridContainer
var top_center: CenterContainer

func bind(g: C3Game, w: C3World) -> void:
	game = g
	world = w
	ui_us = _calc_us()
	icons_tex = load("res://assets/ui/icons.bmp")
	units_tex = load("res://assets/ui/iconsunits.bmp")
	audio_click = AudioStreamPlayer.new()
	audio_click.stream = load("res://assets/sounds/btnclick.ogg")
	add_child(audio_click)
	_build_top()
	_build_bottom()
	_build_minimap()
	msg_label = _mklbl("", 15, Color(1, 0.95, 0.8))
	msg_label.position = Vector2(340, 36)
	add_child(msg_label)
	hint_label = _mklbl("", 14, Color(1, 0.9, 0.5))
	hint_label.position = Vector2(340, 58)
	add_child(hint_label)
	game_over_label = _mklbl("", 42, Color(1, 1, 1))
	game_over_label.set_anchors_preset(Control.PRESET_CENTER)
	game_over_label.visible = false
	add_child(game_over_label)
	game.message.connect(_on_message)
	_apply_scale()
	if is_instance_valid(get_tree()) and is_instance_valid(get_tree().root) and not get_tree().root.size_changed.is_connected(_on_vp_resize):
		get_tree().root.size_changed.connect(_on_vp_resize)

func atlas(src: Texture2D, region: Rect2) -> AtlasTexture:
	var at := AtlasTexture.new()
	at.atlas = src
	at.region = region
	return at

var ui_us := 1.0
var ui_vp := Vector2(1280, 720)

# UI scale: fonts, paddings and minimum sizes follow the window; the world
# view is untouched. Widgets opt in via set_meta("uifs"/"uimh"/"uimw") or the
# _mkbtn/_mklbl constructors; _apply_scale walks the subtree on resize.
func _calc_us() -> float:
	var s := Vector2(1280, 720)
	if is_instance_valid(get_viewport()):
		s = get_viewport().get_visible_rect().size
	ui_vp = s
	return ConfigScript.ui_scale_for(s)

func _fs(base: int) -> int:
	return maxi(10, int(round(float(base) * ui_us)))

func _ms(base: float) -> float:
	return base * ui_us

func _mkbtn(text: String, fs := 15, mh := 40, mw := 0) -> Button:
	var b := Button.new()
	b.text = text
	b.set_meta("uifs", fs)
	b.set_meta("uimh", mh)
	if mw > 0:
		b.set_meta("uimw", mw)
	ConfigScript.ui_style_button(b)
	return b

func _mklbl(text: String, fs := 14, col := Color(1, 1, 1)) -> Label:
	var l := Label.new()
	l.text = text
	l.set_meta("uifs", fs)
	l.add_theme_color_override("font_color", col)
	return l

func _reg(c: Control, fs := 0, mh := 0, mw := 0) -> Control:
	if fs > 0:
		c.set_meta("uifs", fs)
	if mh > 0:
		c.set_meta("uimh", mh)
	if mw > 0:
		c.set_meta("uimw", mw)
	return c

func _on_vp_resize() -> void:
	ui_us = _calc_us()
	_apply_scale()

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
			c.custom_minimum_size = Vector2(_ms(mw) if mw > 0.0 else cur.x, _ms(mh) if mh > 0.0 else cur.y)
		if c.has_meta("uoffs"):
			var o: Array = c.get_meta("uoffs")
			c.offset_left = _ms(float(o[0]))
			c.offset_right = _ms(float(o[1]))
			c.offset_top = _ms(float(o[2]))
			c.offset_bottom = _ms(float(o[3]))
	# Layout zones (never overlap, at any size):
	# - top strip: centered bar + corner FPS (bar clips instead of spilling)
	# - bottom strip, partitioned left->right: minimap | selection | orders
	if is_instance_valid(top_center):
		top_center.offset_top = _ms(8.0)
		top_center.offset_bottom = _ms(8.0) + _ms(64.0)
	var mm := minf(_ms(200.0), ui_vp.x * 0.20)
	if is_instance_valid(minimap_rect):
		minimap_rect.custom_minimum_size = Vector2(mm, mm)
	# Bottom strip partition (never overlaps): the minimap texture can be
	# larger than mm (map is 160-320px), so the rect must ignore texture
	# size and the panel gets explicit bounds: width = mm + style padding
	# (14+14 margins + 2 border), height = mm + (10+10 + 2). The selection
	# panel starts at the minimap's right edge plus a gap, by construction.
	if is_instance_valid(sel_panel) and is_instance_valid(cmd_panel):
		var cmd_w: float = minf(_ms(332.0), ui_vp.x * 0.34)
		var mm_pad_w := 30.0
		var mm_pad_h := 22.0
		var mm_right: float = _ms(4.0) + mm + mm_pad_w
		if is_instance_valid(minimap_panel):
			minimap_panel.offset_left = _ms(4.0)
			minimap_panel.offset_right = mm_right
			minimap_panel.offset_top = -(mm + mm_pad_h)
			minimap_panel.offset_bottom = 0.0
		var mm_edge: float = mm_right + _ms(8.0)
		sel_panel.offset_left = mm_edge
		sel_panel.offset_right = ui_vp.x - cmd_w - _ms(24.0)
		sel_panel.offset_bottom = 0.0
		var roomy: bool = build_menu_open or build_bar.get_child_count() > 5
		sel_panel.offset_top = -_ms(250.0 if roomy else 150.0)
		cmd_panel.offset_left = -(cmd_w + _ms(8.0))
		cmd_panel.offset_right = -_ms(8.0)
		cmd_panel.offset_bottom = 0.0
		var ncmd := cmd_bar.get_child_count()
		cmd_panel.visible = ncmd > 0
		cmd_panel.offset_top = -_ms(320.0 if ncmd > 7 else 200.0)
	# corner/edge labels keep clear of the bars
	if is_instance_valid(fps_label):
		fps_label.offset_left = -_ms(12.0) - _ms(110.0)
		fps_label.offset_right = -_ms(12.0)
		fps_label.offset_top = _ms(10.0)
		fps_label.offset_bottom = _ms(10.0) + _ms(34.0)
	if is_instance_valid(msg_label):
		msg_label.anchor_left = 0.5
		msg_label.anchor_right = 0.5
		msg_label.offset_left = -_ms(300.0)
		msg_label.offset_right = _ms(300.0)
		msg_label.offset_top = _ms(84.0)
		msg_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if is_instance_valid(hint_label):
		hint_label.anchor_left = 0.5
		hint_label.anchor_right = 0.5
		hint_label.offset_left = -_ms(300.0)
		hint_label.offset_right = _ms(300.0)
		hint_label.offset_top = _ms(106.0)
		hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if is_instance_valid(obj_panel):
		obj_panel.position = Vector2(_ms(8.0), _ms(84.0))

func _build_top() -> void:
	# centered bar like the original: a full-width strip that only forwards
	# clicks to its children, so map orders still work underneath it
	top_center = CenterContainer.new()
	top_center.anchor_right = 1.0
	top_center.offset_top = 8
	top_center.offset_bottom = 72
	top_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(top_center)
	top_panel = PanelContainer.new()
	top_panel.custom_minimum_size = Vector2(0, 0)
	top_panel.clip_contents = true
	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", 10)
	top_panel.add_child(bar)
	top_panel.add_theme_stylebox_override("panel", ConfigScript.ui_panel_style())
	for i in 6:
		var ic := TextureRect.new()
		ic.texture = atlas(icons_tex, Data.RES_ICONS[i])
		ic.custom_minimum_size = Vector2(36, 31)
		ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		bar.add_child(ic)
		var l := _mklbl("0", 17, Color(1, 0.97, 0.9))
		bar.add_child(l)
		res_labels.append(l)
	# idle villager + unused mine slots, as in the donor's top strip (S11)
	var eco_sep := VSeparator.new()
	bar.add_child(eco_sep)
	eco_label = _mklbl("idle 0  slots 0", 14, Color(0.8, 0.85, 1))
	eco_label.tooltip_text = "Idle peasants / free mine worker slots"
	bar.add_child(eco_label)
	var sep := VSeparator.new()
	bar.add_child(sep)
	status_label = _mklbl("", 15, Color(0.8, 0.85, 1))
	bar.add_child(status_label)
	# game speed + menu, like the original's top-right controls
	var sep2 := VSeparator.new()
	bar.add_child(sep2)
	for sp in [["II", 0.0], ["1x", 1.0], ["2x", 2.0], ["4x", 4.0]]:
		var sb := _mkbtn(sp[0], 14, 30, 40)
		sb.tooltip_text = "Game speed %s (Space pauses)" % sp[0]
		sb.pressed.connect(_on_speed.bind(float(sp[1])))
		bar.add_child(sb)
		speed_buttons.append(sb)
	var mb := _mkbtn("Menu", 14, 30, 60)
	mb.tooltip_text = "Back to the singleplayer menu"
	mb.pressed.connect(_on_menu)
	bar.add_child(mb)
	speed_label = _mklbl("1x", 14, Color(1, 0.9, 0.5))
	bar.add_child(speed_label)
	settings_label = _mklbl(_settings_text(), 11, Color(0.65, 0.68, 0.75))
	settings_label.tooltip_text = "Settings file in use (--dump-config shows all values)"
	bar.add_child(settings_label)
	top_center.add_child(top_panel)
	# FPS: bare 3-digit number, upper right corner (engine fps only — if the
	# number is high but play feels slow, the cost is sim, not rendering)
	fps_label = Label.new()
	fps_label.text = "060"
	fps_label.set_meta("uifs", 22)
	fps_label.tooltip_text = "Render fps (engine). High fps + slow game = sim cost: try low quality or fewer units."
	fps_label.add_theme_color_override("font_color", Color(0.55, 1, 0.55))
	fps_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	fps_label.add_theme_constant_override("shadow_offset_x", 2)
	fps_label.add_theme_constant_override("shadow_offset_y", 2)
	fps_label.anchor_left = 1.0
	fps_label.anchor_right = 1.0
	fps_label.anchor_top = 0.0
	fps_label.anchor_bottom = 0.0
	fps_label.offset_left = -90
	fps_label.offset_right = -12
	fps_label.offset_top = 10
	fps_label.offset_bottom = 40
	fps_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(fps_label)
	_build_objectives()

func _build_objectives() -> void:
	obj_panel = PanelContainer.new()
	obj_panel.position = Vector2(8, 56)
	obj_panel.visible = false
	obj_panel.add_theme_stylebox_override("panel", ConfigScript.ui_panel_style())
	obj_box = VBoxContainer.new()
	obj_panel.add_child(obj_box)
	add_child(obj_panel)

func refresh_objectives() -> void:
	if obj_box == null or game == null:
		return
	for c in obj_box.get_children():
		obj_box.remove_child(c)
		c.queue_free()
	if game.objectives.is_empty():
		obj_panel.visible = false
		return
	obj_panel.visible = true
	var head := _mklbl("Objectives", 14, Color(1, 0.9, 0.5))
	obj_box.add_child(head)
	for o in game.objectives:
		var l := _mklbl(("[x] " if bool(o.get("done", false)) else "[ ] ") + str(o.get("text", "")), 13, Color(0.85, 0.85, 0.8))
		obj_box.add_child(l)

func refresh_speed(sp: float, paused: bool) -> void:
	if speed_label != null:
		speed_label.text = "PAUSED" if paused else "%.0fx" % sp

func _on_speed(sp: float) -> void:
	audio_click.play()
	if speed_cb.is_valid():
		speed_cb.call(sp)

func _on_menu() -> void:
	audio_click.play()
	if menu_cb.is_valid():
		menu_cb.call()

func _settings_text() -> String:
	var src := "built-in defaults"
	if ConfigScript.active != null:
		src = ConfigScript.active.source
	return "settings: %s" % src.get_file()

func _build_bottom() -> void:
	sel_panel = PanelContainer.new()
	sel_panel.anchor_top = 1.0
	sel_panel.anchor_bottom = 1.0
	sel_panel.offset_top = -140
	sel_panel.offset_left = 220
	sel_panel.offset_right = 780
	sel_panel.clip_contents = true
	sel_panel.add_theme_stylebox_override("panel", ConfigScript.ui_panel_style())
	var vb := VBoxContainer.new()
	sel_panel.add_child(vb)
	sel_box = HBoxContainer.new()
	sel_box.add_theme_constant_override("separation", 4)
	vb.add_child(sel_box)
	build_bar = HFlowContainer.new()
	build_bar.add_theme_constant_override("h_separation", 4)
	build_bar.add_theme_constant_override("v_separation", 4)
	vb.add_child(build_bar)
	add_child(sel_panel)
	cmd_panel = PanelContainer.new()
	cmd_panel.anchor_left = 1.0
	cmd_panel.anchor_right = 1.0
	cmd_panel.anchor_top = 1.0
	cmd_panel.anchor_bottom = 1.0
	cmd_panel.offset_left = -320
	cmd_panel.offset_right = -8
	cmd_panel.offset_top = -140
	cmd_panel.clip_contents = true
	cmd_panel.add_theme_stylebox_override("panel", ConfigScript.ui_panel_style())
	cmd_bar = GridContainer.new()
	cmd_bar.columns = 3
	cmd_bar.add_theme_constant_override("h_separation", 4)
	cmd_bar.add_theme_constant_override("v_separation", 4)
	cmd_panel.add_child(cmd_bar)
	add_child(cmd_panel)

func _unit_button(tex: Texture2D, region: Rect2, tip: String) -> Button:
	var b := Button.new()
	b.icon = atlas(tex, region)
	b.set_meta("uimw", 52.0)
	b.set_meta("uimh", 52.0)
	b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	b.expand_icon = true
	b.tooltip_text = tip
	ConfigScript.ui_style_button(b)
	b.pressed.connect(func(): audio_click.play())
	return b

func _clear_row(row: Container) -> void:
	for c in row.get_children():
		row.remove_child(c)
		c.queue_free()

func refresh_selection(selected: Array) -> void:
	_clear_row(sel_box)
	_clear_row(build_bar)
	_clear_row(cmd_bar)
	cmd_panel.visible = false
	train_buttons.clear()
	build_buttons.clear()
	summary_label = null
	prog_entries.clear()
	dyn_buttons.clear()
	last_ids = []
	for e in selected:
		if not e.dead:
			last_ids.append(e.id)
	if selected.is_empty():
		var hint := _mklbl("Nothing selected. Left-click or drag to select.", 14, Color(0.75, 0.72, 0.65))
		sel_box.add_child(hint)
		_apply_scale()
		return
	var mine := selected.filter(func(e): return e.player == 0)
	if mine.is_empty():
		var l := _mklbl("Enemy %s  HP %d/%d" % [_name_of(selected[0]), maxi(0, selected[0].hp), selected[0].max_hp], 14, Color(1, 0.6, 0.55))
		sel_box.add_child(l)
		var atk := _mkbtn("Attack", 14, 40)
		atk.tooltip_text = "Select your units, then right-click the enemy"
		atk.pressed.connect(_on_attack_hint)
		build_bar.add_child(atk)
		_apply_scale()
		return
	# summary line: what is picked, its health and its current order
	var first: Dictionary = mine[0]
	summary_label = _mklbl(_selection_summary(mine), 15, Color(1, 0.97, 0.9))
	summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sel_box.add_child(summary_label)
	# unit icons row (max 24)
	var shown := 0
	var counts := {}
	for e in mine:
		if e.kind == "unit":
			counts[e.sid] = int(counts.get(e.sid, 0)) + 1
	for sid in counts:
		var b := _unit_button(units_tex, Data.UNITS[sid].icon, "%s  ×%d" % [ConfigScript.unit_name(sid), counts[sid]])
		b.text = "×%d" % counts[sid] if counts[sid] > 1 else ""
		sel_box.add_child(b)
		shown += 1
		if shown >= 8:
			break
	for e in mine:
		if e.kind == "building":
			var b := _unit_button(icons_tex, Data.BUILDINGS[e.sid].icon, "%s  HP %d/%d" % [ConfigScript.building_name(e.sid), maxi(0, e.hp), e.max_hp])
			sel_box.add_child(b)
			if not e.finished:
				var prog := _mklbl("", 13, Color(0.7, 0.9, 0.7))
				var kp: float = clampf(e.progress / maxf(1.0, e.def.build_time), 0.0, 1.0)
				prog.text = "building %d%%" % int(kp * 100.0)
				sel_box.add_child(prog)
				prog_entries.append({"label": prog, "e": e})
			# train buttons
			if e.finished and e.player == 0:
				var tnat := str(Data.PLAYER_NATIONS[e.player]) if e.player >= 0 and e.player < Data.PLAYER_NATIONS.size() else ""
				for sid in e.def.get("trains", []):
					var rsid := Data.resolve_sid(tnat, sid)
					if not Data.UNITS.has(rsid):
						continue
					var tb := _unit_button(units_tex, Data.UNITS[rsid].icon, "%s - %s" % [ConfigScript.unit_name(rsid), _price_text(Data.UNITS[rsid].price)])
					var q: int = e.queue.filter(func(j): return j.sid == rsid).size()
					if e.queue.size() > 0 or q > 0:
						tb.text = _queue_label(e, rsid, q)
					tb.pressed.connect(_on_train.bind(e, rsid))
					tb.gui_input.connect(_on_train_gui.bind(e, rsid))
					train_buttons[rsid] = tb
					build_bar.add_child(tb)
					dyn_buttons.append({"b": tb, "kind": "train", "e": e, "sid": rsid, "uid": ""})
				# research buttons (blacksmith / academy): video shows the
				# upgrade rows next to the unit queue
				for uid in Data.UPGRADES:
					var u: Dictionary = Data.UPGRADES[uid]
					if u.building != e.sid:
						continue
					var done: bool = game.players[0].upgrades.has(uid)
					var researching: bool = e.get("research") != null and e.research.uid == uid
					var rb := _mkbtn(("[x] " if done else ("... " if researching else "")) + str(u.name), 13, 50, 120)
					rb.tooltip_text = "%s - %s%s" % [u.name, _price_text(u.cost), " (researched)" if done else ""]
					rb.disabled = done or researching
					rb.pressed.connect(_on_research.bind(e, uid))
					build_bar.add_child(rb)
					dyn_buttons.append({"b": rb, "kind": "research", "e": e, "sid": "", "uid": uid})
				if e.sid == "wal" and e.finished:
					var gb := _mkbtn("Gate", 14, 50, 56)
					gb.tooltip_text = "Convert this wall segment into a gate"
					gb.pressed.connect(_on_make_gate.bind(e))
					build_bar.add_child(gb)
				if e.sid == "gat":
					var ob := _mkbtn("Open" if bool(e.get("closed", false)) else "Close", 14, 50, 56)
					ob.pressed.connect(_on_gate_toggle.bind(e))
					build_bar.add_child(ob)
				if str(e.sid) in ["tow", "cen"] and int(e.get("garrison", 0)) > 0:
					var ub := _mkbtn("Unload [U]", 14, 50, 80)
					ub.tooltip_text = "Unload garrison"
					ub.pressed.connect(_on_unload.bind(e))
					build_bar.add_child(ub)
				if str(e.sid) in ["officer", "officer18"] and e.player == 0:
					for fs in [15, 36, 72, 120, 196, 400]:
						var fb := _mkbtn(str(fs), 14, 50, 40)
						fb.tooltip_text = "Form a %d-man formation from nearby troops" % fs
						fb.pressed.connect(_on_form_size.bind(e, fs))
						build_bar.add_child(fb)
				# P-51: donor mill "Grain Crops" production order.
				if e.sid == "mil" and e.finished and e.player == 0:
					var gb := _mkbtn("Grain Crops", 14, 50, 88)
					gb.tooltip_text = "Sow a 7x7 field ring around this mill (5 gold per field)"
					gb.pressed.connect(_on_grain_crops.bind(e))
					build_bar.add_child(gb)
					# T-FIELDS-GFX: mill field state line (same states as map).
					if game.has_method("field_counts_for_mill"):
						var fc: Dictionary = game.field_counts_for_mill(int(e.id))
						var fl := _mklbl("Fields ripe %d / growing %d / regrowing %d / bare %d" % [
							int(fc.get("ripe", 0)), int(fc.get("growing", 0)),
							int(fc.get("regrowing", 0)), int(fc.get("depleted", 0))],
							13, Color(0.85, 0.80, 0.60))
						fl.tooltip_text = "Ripe = golden harvestable. Growing = green partial. Regrowing = timer to ripe (finished mill nearby). Bare = needs resow (20 food via peasant) or Grain Crops."
						sel_box.add_child(fl)
				# MICRO #9: market Buy / Sell / Exchange (three distinct modes)
				if e.sid == "mar":
					var give_res: String = str(MARKET_TRADABLE[market_give_idx])
					var want_res: String = str(MARKET_TRADABLE[market_want_idx])
					var rate_pct: int = int(float(game.players[0].get("market_rate", Data.MARKET_RATE)) * 100.0)
					var amt := _mkbtn("%d" % int(trade_amount), 14, 50, 56)
					amt.tooltip_text = "Trade amount per click (100/500)"
					amt.pressed.connect(_on_trade_amount)
					build_bar.add_child(amt)
					var gb := _mkbtn("Give: %s" % give_res, 14, 50, 92)
					gb.tooltip_text = "Resource to sell / exchange (click to cycle)"
					gb.pressed.connect(_on_market_give)
					build_bar.add_child(gb)
					var wb := _mkbtn("For: %s" % want_res, 14, 50, 92)
					wb.tooltip_text = "Resource received by Exchange (click to cycle)"
					wb.pressed.connect(_on_market_want)
					build_bar.add_child(wb)
					var buy := _mkbtn("Buy %s" % give_res, 14, 50, 92)
					buy.tooltip_text = "Pay %d gold, receive %s (rate %d%%, floor 35%%)" % [int(trade_amount), give_res, rate_pct]
					buy.pressed.connect(_on_market_buy.bind(e, give_res, trade_amount))
					build_bar.add_child(buy)
					var sell := _mkbtn("Sell %s" % give_res, 14, 50, 92)
					sell.tooltip_text = "Give %d %s, receive gold (rate %d%%, floor 35%%)" % [int(trade_amount), give_res, rate_pct]
					sell.pressed.connect(_on_market_sell.bind(e, give_res, trade_amount))
					build_bar.add_child(sell)
					var ex := _mkbtn("Xchg %s" % want_res, 14, 50, 92)
					ex.tooltip_text = "Exchange %d %s for %s (rate %d%%)" % [int(trade_amount), give_res, want_res, rate_pct]
					ex.pressed.connect(_on_trade.bind(e, give_res, want_res))
					build_bar.add_child(ex)
				# rally point: one click enters the mode, right-click then sets it
				if e.def.get("trains", []).size() > 0:
					var ral := _mkbtn("Rally [R]", 14, 50, 64)
					ral.tooltip_text = "Set rally point: click, then right-click the map"
					ral.pressed.connect(_on_rally_mode)
					build_bar.add_child(ral)
	# squad panel: officer + soldiers -> Form [F], Line [J], Column [K], Square [L]
	var offs: Array = mine.filter(func(e): return e.kind == "unit" and (e.sid == "officer" or e.sid == "officer18"))
	var soldiers: Array = mine.filter(func(e): return e.kind == "unit" and e.sid != "peasant" and not e.def.get("support", false) and e.sid != "officer" and e.sid != "officer18")
	if not offs.is_empty() and mine.all(func(e): return e.kind == "unit" and e.player == 0):
		for o in offs:
			var sq: Dictionary = game.squad_of_unit(o.id)
			var label := "Form [F]" if sq.is_empty() else "Squad %d (%s)" % [int(sq.squad_id), str(sq.get("formation", "line"))]
			var fb := _mkbtn(label, 14, 50, 110)
			fb.tooltip_text = "Form a squad around this officer (F). Soldiers keep formation."
			fb.pressed.connect(_on_squad_form.bind(mine))
			build_bar.add_child(fb)
			if not sq.is_empty():
				for form in ["line", "column", "square"]:
					var fob := _mkbtn(form.substr(0, 3).to_upper(), 14, 50, 48)
					fob.tooltip_text = "%s formation (%s)" % [form, "J" if form == "line" else ("K" if form == "column" else "L")]
					fob.disabled = str(sq.get("formation", "")) == form
					fob.pressed.connect(_on_squad_form_set.bind(int(sq.squad_id), form))
					build_bar.add_child(fob)
				var db := _mkbtn("Disband", 14, 50, 80)
				db.tooltip_text = "Disband the squad (Shift+F)"
				db.pressed.connect(_on_squad_disband.bind(int(sq.squad_id)))
				build_bar.add_child(db)
	if mine.size() > 0 and mine.all(func(e): return e.kind == "unit" and e.player == 0):
		for spec in [["Attack-move", "attack_move", "A"], ["Stand", "stand_ground", "S"], ["Hold fire", "hold_fire", "D"], ["Feuer frei", "feuer_frei", "E"], ["Patrol", "patrol", "P"], ["Guard", "guard", "G"], ["Stop", "stop", "Ctrl+S"]]:
			var cb := _mkbtn("%s\n[%s]" % [spec[0], spec[2]], 12, 56, 96)
			cb.pressed.connect(_on_cmd_button.bind(str(spec[1])))
			cmd_bar.add_child(cb)
		if mine.any(func(e): return str(e.sid) in ["officer", "officer18"]):
			for form in ["line", "column", "square", "wedge"]:
				var fb2 := _mkbtn(form.substr(0, 3).to_upper(), 13, 56, 96)
				fb2.pressed.connect(_on_cmd_form.bind(form))
				cmd_bar.add_child(fb2)
		cmd_panel.visible = true
	if mine.size() > 0 and mine.all(func(e): return e.kind == "unit" and e.sid == "peasant"):
		build_menu_open = true
		_refresh_build_menu(mine)
	elif build_menu_open:
		build_menu_open = false
	_apply_scale()

# T5MOD: donor recruitment modifiers (eventunitcontrol.inc:514-533).
const TRAIN_BATCH := 5
const TRAIN_BIG_BATCH := 100
# Donor default (config.res:798/989) is "Repeating unit production with
# left-click" OFF: plain=1, Ctrl=endless.  The settings toggle is not wired in
# this port; this flag is the single place to invert the XOR if it is added.
var repeat_on_left_click: bool = false
var _train_last_ms: int = -1000

func _queue_label(bld: Dictionary, sid: String, q: int) -> String:
	if bld.queue.is_empty():
		return str(q) if q > 0 else ""
	var front: Dictionary = bld.queue[0]
	if str(front.get("sid", "")) == sid:
		if bool(front.get("infinite", false)):
			return "∞"
		var c: int = maxi(1, int(front.get("count", 1)))
		return str(c)
	return "+%d" % q if q > 0 else ""

func _train_amount(bld: Dictionary, sid: String) -> void:
	var ctrl := Input.is_key_pressed(KEY_CTRL)
	var shift := Input.is_key_pressed(KEY_SHIFT)
	var alt := Input.is_key_pressed(KEY_ALT)
	if ctrl and alt:
		game.train_unit(0, bld, sid, TRAIN_BIG_BATCH)            # 100 (AltGr = Ctrl+Alt)
	elif ctrl and shift:
		game.train_unit(0, bld, sid, TRAIN_BATCH, true)         # 5x endless
	elif shift:
		game.train_unit(0, bld, sid, TRAIN_BATCH)               # 5 units
	elif ctrl != repeat_on_left_click:
		game.train_unit(0, bld, sid, 1, true)                   # endless
	else:
		game.train_unit(0, bld, sid, 1)                         # plain 1
	refresh_selection(game.get_selected())

func _on_train(bld: Dictionary, sid: String) -> void:
	# Keyboard/Device activation.  GUI mouse input handles clicks itself; the
	# short dedup window prevents a Shift+LMB double-fire across pressed+gui_input.
	var now := Time.get_ticks_msec()
	if now - _train_last_ms < 80:
		return
	_train_last_ms = now
	audio_click.play()
	_train_amount(bld, sid)

func _on_train_gui(ev: InputEvent, bld: Dictionary, sid: String) -> void:
	if not (ev is InputEventMouseButton):
		return
	var now := Time.get_ticks_msec()
	if ev.button_index == MOUSE_BUTTON_RIGHT and ev.pressed:
		_train_last_ms = now
		game.cancel_train(bld, sid)
		get_viewport().set_input_as_handled()
		refresh_selection(game.get_selected())
		return
	if ev.button_index == MOUSE_BUTTON_LEFT and ev.pressed:
		if now - _train_last_ms < 80:
			return
		_train_last_ms = now
		audio_click.play()
		_train_amount(bld, sid)
		get_viewport().set_input_as_handled()

func _on_research(bld: Dictionary, uid: String) -> void:
	audio_click.play()
	game.research(0, bld, uid)
	refresh_selection(game.get_selected())

func _on_make_gate(b: Dictionary) -> void:
	audio_click.play()
	game.cmd_make_gate(b)
	refresh_selection(game.get_selected())

func _on_gate_toggle(b: Dictionary) -> void:
	audio_click.play()
	game.cmd_gate_toggle(b)
	refresh_selection([b])

func _on_unload(b: Dictionary) -> void:
	audio_click.play()
	game.cmd_unload(b)
	refresh_selection([b])

func _on_form_size(off: Dictionary, size: int) -> void:
	audio_click.play()
	game.cmd_form_size(off, size)
	refresh_selection([off])

func _on_grain_crops(mill: Dictionary) -> void:
	audio_click.play()
	var n: int = game.cmd_sow(mill)
	if n > 0:
		show_hint("Sowed %d grain fields (-%d gold)" % [n, n * 5])
	else:
		show_hint("No room or not enough gold to sow grain fields")
	refresh_selection(game.get_selected())

func _on_market_give() -> void:
	audio_click.play()
	market_give_idx = (market_give_idx + 1) % MARKET_TRADABLE.size()
	if market_give_idx == market_want_idx:
		market_want_idx = (market_want_idx + 1) % MARKET_TRADABLE.size()
	refresh_selection(game.get_selected())

func _on_market_want() -> void:
	audio_click.play()
	market_want_idx = (market_want_idx + 1) % MARKET_TRADABLE.size()
	if market_want_idx == market_give_idx:
		market_want_idx = (market_want_idx + 1) % MARKET_TRADABLE.size()
	refresh_selection(game.get_selected())

func _on_market_buy(bld: Dictionary, give: String, amount: float) -> void:
	audio_click.play()
	if game.trade(0, "gold", give, amount):
		_on_message("Bought %s with gold" % give)
	refresh_selection(game.get_selected())

func _on_market_sell(bld: Dictionary, give: String, amount: float) -> void:
	audio_click.play()
	if game.trade(0, give, "gold", amount):
		_on_message("Sold %s for gold" % give)
	refresh_selection(game.get_selected())

func _on_trade(bld: Dictionary, give: String, want: String) -> void:
	audio_click.play()
	if game.trade(0, give, want, trade_amount):
		_on_message("Exchanged %s for %s" % [give, want])
	refresh_selection(game.get_selected())

func _on_trade_amount() -> void:
	audio_click.play()
	trade_amount = 500.0 if trade_amount < 500.0 else 100.0
	refresh_selection(game.get_selected())

func _on_rally_mode() -> void:
	audio_click.play()
	want_rally = true
	show_hint("Rally: right-click the map to set the gather point")

func _on_squad_form(sel: Array) -> void:
	audio_click.play()
	game.squad_form(sel)
	refresh_selection(game.get_selected())

func _on_squad_form_set(sid: int, form: String) -> void:
	audio_click.play()
	game.squad_set_formation(sid, form)
	refresh_selection(game.get_selected())

func _on_squad_disband(sid: int) -> void:
	audio_click.play()
	game.squad_disband(sid)
	refresh_selection(game.get_selected())

func _on_cmd_button(action: String) -> void:
	audio_click.play()
	var ictl = get_tree().get_first_node_in_group("c3_input")
	if ictl != null:
		ictl.command_from_hud(action)

func _on_cmd_form(form: String) -> void:
	audio_click.play()
	for e in game.get_selected():
		var sq: Dictionary = game.squad_of_unit(e.id)
		if not sq.is_empty():
			game.squad_set_formation(int(sq.squad_id), form)
			break
	refresh_selection(game.get_selected())

func _on_attack_hint() -> void:
	audio_click.play()

func _on_build_pick(sid: String) -> void:
	audio_click.play()
	build_ghost_sid = sid
	build_menu_open = false
	refresh_selection(game.get_selected())

func _on_cancel_build_menu() -> void:
	build_menu_open = false
	refresh_selection(game.get_selected())

func _selection_summary(mine: Array) -> String:
	var units := 0
	var blds := 0
	for e in mine:
		if e.kind == "unit":
			units += 1
		else:
			blds += 1
	var first: Dictionary = mine[0]
	var s := _name_of(first)
	if mine.size() > 1:
		s += "  x%d (%d units" % [mine.size(), units]
		if blds > 0:
			s += ", %d bldg" % blds
		s += ")"
	if first.kind == "unit":
		s += "  HP %d/%d" % [maxi(0, first.hp), first.max_hp]
		if not first.def.get("support", false) and first.sid != "peasant":
			s += "  morale %d" % int(first.get("morale", 70.0))
			if first.get("routing", false):
				s += " ROUTING!"
		var o: String = str(first.order.get("type", "none"))
		if o != "none":
			s += "  " + o
			if first.order.has("res"):
				s += " " + str(first.order.res)
	else:
		s += "  HP %d/%d" % [maxi(0, first.hp), first.max_hp]
		if not first.finished:
			s += "  under construction"
		elif first.queue.size() > 0:
			var jf: Dictionary = first.queue[0]
			var cnt: String = "∞" if bool(jf.get("infinite", false)) else str(maxi(1, int(jf.get("count", 1))))
			s += "  training %s (%s)" % [jf.sid, cnt]
		if first.get("research") != null:
			s += "  researching %s" % first.research.uid
		if float(first.get("capture_t", 0.0)) > 0.1:
			s += "  CAPTURE %.0f%%" % (float(first.capture_t) / 8.0 * 100.0)
		if game.players[0].get("famine", false):
			s += "  FAMINE!"
	return s

func _price_text(cost: Dictionary) -> String:
	var parts: Array = []
	for k in Data.RES_NAMES:
		if cost.get(k, 0) > 0:
			parts.append("%d %s" % [cost[k], k])
	return " ".join(parts) if parts.size() > 0 else "free"

# The name of a unit or a building, as the settings file gives it.
func _name_of(e: Dictionary) -> String:
	if e.kind == "building":
		return ConfigScript.building_name(e.sid)
	return ConfigScript.unit_name(e.sid)

func _refresh_build_menu(peasants: Array) -> void:
	var order := ["cen", "hou", "wal", "bar", "sta", "bla", "aca", "sto", "mil", "mar", "art", "tow", "mine"]
	for sid in order:
		# One generic Mine button: all three mine types share the same icon,
		# cost and build time, so the gold def is just the display template.
		# The deposit under the cursor decides which mine actually gets built.
		var def: Dictionary = Data.BUILDINGS["mine_gold" if sid == "mine" else sid]
		var b := _unit_button(icons_tex, def.icon, "")
		var tip := "%s  [%s]  %s  Time: %ds" % [ConfigScript.building_name(sid), _key_text(sid),
			_price_text(def.cost), int(round(float(def.get("build_time", 0.0))))]
		if sid == "mine":
			tip += "  - type follows the ore deposit"
		b.tooltip_text = tip
		b.disabled = not Data.can_pay(game.players[0].res, def.cost)
		b.pressed.connect(_on_build_pick.bind(sid))
		build_buttons[sid] = b
		build_bar.add_child(b)
		dyn_buttons.append({"b": b, "kind": "build", "e": {}, "sid": sid, "uid": ""})
	var cancel := _mkbtn("Cancel build menu (Esc)", 13, 40)
	cancel.pressed.connect(_on_cancel_build_menu)
	build_bar.add_child(cancel)

# The letter the building is built with, as the settings file says.
func _key_text(sid: String) -> String:
	var keys: Dictionary = Data.HOTKEYS.get("build", {})
	if sid == "mine" or sid.begins_with("mine_"):
		return str(keys.get("mine", "N"))
	return str(keys.get(sid, "-"))

func _update_dynamic() -> void:
	# Cheap live pass: texts and affordable states only. Buttons are never
	# freed here, so a click in flight always lands (full rebuilds happen in
	# refresh_selection, called on selection and order changes).
	if game == null or sel_box == null:
		return
	var cur := game.get_selected()
	var ids: Array = []
	for e in cur:
		ids.append(e.id)
	if ids != last_ids:
		refresh_selection(cur)
		return
	if summary_label != null and is_instance_valid(summary_label):
		var mine0 := cur.filter(func(e): return e.player == 0)
		if not mine0.is_empty():
			summary_label.text = _selection_summary(mine0)
	for p in prog_entries:
		var l: Label = p.label
		var be: Dictionary = p.e
		if is_instance_valid(l) and not be.dead:
			var kp: float = clampf(be.progress / maxf(1.0, be.def.build_time), 0.0, 1.0)
			l.text = "building %d%%" % int(kp * 100.0)
	for d in dyn_buttons:
		var b: Button = d.b
		if not is_instance_valid(b):
			continue
		var be2: Dictionary = d.e
		if d.kind == "train":
			if be2.dead:
				b.disabled = true
				continue
			var q: int = be2.queue.filter(func(j): return j.sid == d.sid).size()
			if be2.queue.size() > 0 or q > 0:
				b.text = _queue_label(be2, d.sid, q)
			b.disabled = not Data.can_pay(game.players[0].res, Data.UNITS[d.sid].price)
		elif d.kind == "research":
			var u: Dictionary = Data.UPGRADES.get(d.uid, {})
			if u.is_empty():
				continue
			var done: bool = game.players[0].upgrades.has(d.uid)
			var researching: bool = false
			if not be2.is_empty() and not be2.dead:
				researching = be2.get("research") != null and be2.research.uid == d.uid
			b.disabled = done or researching
			b.text = ("[x] " if done else ("... " if researching else "")) + str(u.name)
		elif d.kind == "build":
			var def: Dictionary = Data.BUILDINGS.get("mine_gold" if d.sid == "mine" else d.sid, {})
			if not def.is_empty():
				b.disabled = not Data.can_pay(game.players[0].res, def.cost)

func show_hint(text: String) -> void:
	# T-PERF-RENDER: input_controller calls this every frame with "" when idle;
	# assigning the same text still triggers a Control relayout, so no-op.
	if hint_label != null and hint_label.text != text:
		hint_label.text = text

func _on_message(text: String) -> void:
	msg_label.text = text
	msg_timer = 4.0

func game_over(winner: int) -> void:
	game_over_label.visible = true
	game_over_label.text = ("Victory!" if winner == 0 else "Defeat")
	game_over_label.add_theme_color_override("font_color", Color(1, 0.9, 0.3) if winner == 0 else Color(1, 0.4, 0.3))

# Economy read-outs derived entirely from existing game state (no sim edits):
#  - bracketed worker count per resource = peasants gathering that resource,
#    or miners inside a mine (inside_of -> "mine_<res>" building)
#  - idle peasants + free mine slots = the donor's two top-bar warnings (S11)
#  - gold upkeep rate vs mine income rate = the donor's red-negative-upkeep
#    signal, using the sim's own UPKEEP_DIVISOR / MINE_INCOME_PER_S constants.
func _recompute_eco() -> void:
	if game == null:
		return
	var counts := {}
	for r in Data.RES_NAMES:
		counts[str(r)] = 0
	var idle := 0
	var slots := 0
	var gold_upkeep := 0.0
	var gold_income := 0.0
	var p: Dictionary = game.players[0]
	for e in game.live_units:
		if e.dead or int(e.player) != 0:
			continue
		var eat: Dictionary = e.def.get("eat", {})
		if eat.has("gold"):
			gold_upkeep += float(eat["gold"]) / Data.UPKEEP_DIVISOR
		if str(e.sid) != "peasant":
			continue
		var o: Dictionary = e.get("order", {})
		var rname: String = str(o.get("res", ""))
		var inside: int = int(e.get("inside_of", 0))
		if inside != 0:
			var m: Dictionary = game.by_id.get(inside, {})
			var msid: String = str(m.get("sid", ""))
			if msid.begins_with("mine_"):
				rname = msid.substr(5)
		if counts.has(rname):
			counts[rname] = int(counts[rname]) + 1
		elif str(o.get("type", "none")) == "none":
			idle += 1
	for b in game.live_blds:
		if b.dead or int(b.player) != 0:
			continue
		var eat2: Dictionary = b.def.get("eat", {})
		if eat2.has("gold"):
			gold_upkeep += float(eat2["gold"]) / Data.UPKEEP_DIVISOR
		var bsid: String = str(b.sid)
		if bsid.begins_with("mine_") and bool(b.finished):
			var used: int = int(b.get("workers", 0))
			slots += maxi(0, int(b.get("slots", b.def.get("slots", 5))) - used)
			if bsid.substr(5) == "gold":
				gold_income += float(used) * Data.MINE_INCOME_PER_S * float(p.get("mine_mult", 1.0))
	worker_counts = counts
	idle_count = idle
	free_slots_count = slots
	gold_deficit = gold_upkeep > gold_income + 0.0001

func _process(dt: float) -> void:
	if game == null:
		return
	# fps readout: engine fps + frame-time EMA + live units. If fps is high
	# but the game feels slow, the cost is sim/design (ticks, AI, upkeep),
	# not rendering — check low quality preset next.
	if dt > 0.0:
		fps_ema = lerpf(fps_ema, 1.0 / maxf(dt, 0.0001), 0.05)
	fps_t -= dt
	if fps_t <= 0.0 and fps_label != null:
		fps_t = 0.5
		fps_label.text = "%03d" % int(Performance.get_monitor(Performance.TIME_FPS))
	eco_t -= dt
	if eco_t <= 0.0:
		eco_t = 0.5
		_recompute_eco()
		_cached_ucount = game.unit_count(0) + game.queue_count(0)
	for i in 6:
		var rname: String = str(Data.RES_NAMES[i])
		var rt := "%d [%d]" % [int(game.players[0].res[i]), int(worker_counts.get(rname, 0))]
		# T-PERF-RENDER: dirty-flagged text (same-string assignment relayouts).
		while _last_res_text.size() < 6:
			_last_res_text.append("")
		if rt != str(_last_res_text[i]):
			_last_res_text[i] = rt
			res_labels[i].text = rt
		# donor colours a resource red when upkeep outruns income/stock
		var deficit := false
		if i == 0:
			deficit = bool(game.players[0].famine)
		elif i == 3:
			deficit = gold_deficit or float(game.players[0].get("gold_famine_t", 0.0)) > 0.0
		if deficit != bool(res_deficit[i]):
			res_deficit[i] = deficit
			res_labels[i].add_theme_color_override("font_color", Color(1, 0.42, 0.38) if deficit else Color(1, 0.97, 0.9))
	if eco_label != null:
		var et := "idle %d  slots %d" % [idle_count, free_slots_count]
		if et != _last_eco_text:
			_last_eco_text = et
			eco_label.text = et
		var warn: bool = idle_count > 0
		if warn != eco_warn:
			eco_warn = warn
			eco_label.add_theme_color_override("font_color", Color(1, 0.45, 0.4) if warn else Color(0.8, 0.85, 1))
	var ucount := _cached_ucount  # throttled on eco_t (~0.5 s); other fields stay live
	# the hint line carries placement text; the status line keeps units/score
	if hint_label == null or hint_label.text == "":
		var st := "units %d/%d    score %d    %s" % [ucount, game.players[0].farm_cap,
			game.players[0].score, ("PAUSED" if game.paused else "")]
		if st != _last_status_text:
			_last_status_text = st
			status_label.text = st
	if msg_timer > 0.0:
		msg_timer -= dt
		if msg_timer <= 0.0:
			msg_label.text = ""
	mm_timer -= dt
	if mm_timer <= 0.0:
		mm_timer = Data.MINIMAP_INTERVAL
		_update_minimap()
	# F3: the white viewport box follows the camera every frame, not just on
	# the (0.25 s / 0.5 s) minimap timer. The draw is change-gated, so this is
	# O(1) while the camera is still. This also covers arrow/edge scroll + zoom.
	_draw_minimap_viewport_box()
	# live refresh: texts and affordable states only (never frees buttons,
	# so a click in flight always lands). Structural changes rebuild above.
	sel_timer -= dt
	if sel_timer <= 0.0:
		sel_timer = 0.75
		if build_ghost_sid == "":
			_update_dynamic()

func _build_minimap() -> void:
	# T-MINIMAP: new game -> new res_nodes, so drop the cached marker list and
	# any stale viewport box before the first rebuild.
	_mm_mine_centers.clear()
	_mm_mine_colors.clear()
	_mm_mine_ver = -1
	_mm_box_last = Vector4i(-1, -1, -1, -1)
	# T-MINIMAP-EXTRA: drop entity caches from the previous game too.
	_mm_bld_centers.clear()
	_mm_bld_colors.clear()
	_mm_bld_enemy.clear()
	_mm_bld_ver = -1
	_mm_unit_counts = PackedInt32Array()
	_mm_unit_counts.resize(maxi(MM_PLAYER_COLORS.size(), game.players.size()))
	_mm_cluster_cols = int(ceili(float(game.MAP_W) / float(MM_CLUSTER_CELL))) + 1
	_mm_cluster_rows = int(ceili(float(game.MAP_H) / float(MM_CLUSTER_CELL))) + 1
	minimap_base = Image.create(game.MAP_W, game.MAP_H, false, Image.FORMAT_RGBA8)
	for y in game.MAP_H:
		for x in game.MAP_W:
			var i := y * game.MAP_W + x
			var c := Color(0.29, 0.42, 0.2)
			match int(game.terrain[i]):
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
			minimap_base.set_pixel(x, y, c)
	minimap_img = minimap_base.duplicate()
	minimap_view_img = minimap_img.duplicate()
	minimap_tex = ImageTexture.create_from_image(minimap_view_img)
	minimap_rect = TextureRect.new()
	minimap_rect.texture = minimap_tex
	minimap_rect.custom_minimum_size = Vector2(200, 200)
	minimap_rect.set_meta("uimw", 200.0)
	minimap_rect.set_meta("uimh", 200.0)
	minimap_rect.stretch_mode = TextureRect.STRETCH_SCALE
	minimap_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	minimap_rect.anchor_left = 0.0
	minimap_rect.anchor_right = 0.0
	minimap_rect.anchor_top = 1.0
	minimap_rect.anchor_bottom = 1.0
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", ConfigScript.ui_panel_style())
	panel.add_child(minimap_rect)
	panel.anchor_left = 0.0
	panel.anchor_right = 0.0
	panel.anchor_top = 1.0
	panel.anchor_bottom = 1.0
	panel.offset_left = 4
	panel.offset_top = -212
	panel.offset_right = 234
	panel.offset_bottom = 0
	minimap_panel = panel
	add_child(panel)
	minimap_rect.gui_input.connect(_on_minimap_input)

func _on_minimap_input(ev: InputEvent) -> void:
	var mp := minimap_rect.get_local_mouse_position() / minimap_rect.size
	var world_pos := Vector2(mp.x * game.MAP_W, mp.y * game.MAP_H) * Data.TILE_M
	var cam := get_viewport().get_camera_2d() as C3Camera
	if ev is InputEventMouseButton and ev.pressed:
		get_viewport().set_input_as_handled()
		if ev.button_index == MOUSE_BUTTON_LEFT and cam:
			cam.global_position = world_pos * world.view_scale
			cam.clamp_pos()  # F2: no blank border at map corners
			_draw_minimap_viewport_box()  # F3: box moves on this very frame
		elif ev.button_index == MOUSE_BUTTON_RIGHT:
			# right-click on minimap = move/attack-move order for the selection
			var ictl = get_tree().get_first_node_in_group("c3_input")
			if ictl != null:
				ictl.minimap_order(world_pos)
	elif ev is InputEventMouseMotion and ev.button_mask & MOUSE_BUTTON_MASK_LEFT and cam:
		cam.global_position = world_pos * world.view_scale
		cam.clamp_pos()  # F2
		_draw_minimap_viewport_box()  # F3

# F3: draw the white viewport rectangle into a DISPLAY image and upload it.
# The box is derived straight from the camera transform, so it reflects a jump
# on the same input event instead of waiting for world.sync()/MINIMAP_INTERVAL.
# T-PERF-RENDER: instead of duplicating the whole ~100k-pixel image whenever
# the camera scrolls, only the previous/new 1px borders are rewritten. The
# clean image is the restore source, so no ghost rectangles can be left behind.
func _draw_minimap_viewport_box(force: bool = false) -> void:
	if minimap_img == null or minimap_view_img == null or minimap_tex == null or game == null:
		return
	var x0 := 0
	var y0 := 0
	var x1 := game.MAP_W - 1
	var y1 := game.MAP_H - 1
	var cam := get_viewport().get_camera_2d()
	if cam != null and world != null:
		# view_rect is canvas pixels (metres * view_scale); screen = canvas * zoom
		var pxm: float = Data.TILE_M * world.view_scale
		var vp: Vector2 = get_viewport().get_visible_rect().size
		var extent: Vector2 = vp / maxf(cam.zoom.x, 0.0001)
		var view_pos: Vector2 = cam.global_position - extent * 0.5
		var view_end: Vector2 = view_pos + extent
		x0 = clampi(int(view_pos.x / pxm), 0, game.MAP_W - 1)
		y0 = clampi(int(view_pos.y / pxm), 0, game.MAP_H - 1)
		x1 = clampi(int(view_end.x / pxm), 0, game.MAP_W - 1)
		y1 = clampi(int(view_end.y / pxm), 0, game.MAP_H - 1)
	var box := Vector4i(x0, y0, x1, y1)
	if not force and box == _mm_box_last:
		return
	# restore the old border from the clean image, then paint the new one
	if _mm_box_last.x >= 0:
		_mm_paint_box(_mm_box_last, true)
	_mm_box_last = box
	_mm_paint_box(box, false)
	minimap_tex.update(minimap_view_img)

func _mm_paint_box(b: Vector4i, restore: bool) -> void:
	# b = x0,y0,x1,y1. restore=true copies the clean pixel back (no ghost).
	var bc := Color(1, 1, 1, 0.9)
	for xi in b.z - b.x + 1:
		var x := b.x + xi
		minimap_view_img.set_pixel(x, b.y, minimap_img.get_pixel(x, b.y) if restore else bc)
		minimap_view_img.set_pixel(x, b.w, minimap_img.get_pixel(x, b.w) if restore else bc)
	for yi in b.w - b.y - 1:
		var y := b.y + 1 + yi
		minimap_view_img.set_pixel(b.x, y, minimap_img.get_pixel(b.x, y) if restore else bc)
		minimap_view_img.set_pixel(b.z, y, minimap_img.get_pixel(b.z, y) if restore else bc)

func _mm_plot(t: Vector2i, c: Color, big: bool) -> void:
	# minimap blip with map-bounds guard; deposits and forests draw 2x2 so
	# they read as landmarks like in the original, units stay 1px dots
	if t.x < 0 or t.y < 0 or t.x >= game.MAP_W or t.y >= game.MAP_H:
		return
	minimap_img.set_pixel(t.x, t.y, c)
	if big:
		if t.x + 1 < game.MAP_W:
			minimap_img.set_pixel(t.x + 1, t.y, c)
		if t.y + 1 < game.MAP_H:
			minimap_img.set_pixel(t.x, t.y + 1, c)
		if t.x + 1 < game.MAP_W and t.y + 1 < game.MAP_H:
			minimap_img.set_pixel(t.x + 1, t.y + 1, c)

func _rebuild_mine_markers() -> void:
	# Called only when game.res_dirty moves (or on a new game), never per frame.
	# Ore deposits are inexhaustible mine sites (max_hits == 0, hits == 0);
	# live ore/stone quarry nodes still have hits. Spent finite nodes are
	# dropped from res_nodes by the sim, so none can linger as false markers.
	_mm_mine_centers.clear()
	_mm_mine_colors.clear()
	for n in game.res_nodes:
		var ty := str(n.get("type", ""))
		if not MINE_MARKER_COLORS.has(ty):
			continue
		if int(n.get("hits", 0)) <= 0 and int(n.get("max_hits", 0)) != 0:
			continue
		var t := game.tile_of(n.pos)
		if t.x < 0 or t.y < 0 or t.x >= game.MAP_W or t.y >= game.MAP_H:
			continue
		_mm_mine_centers.append(t)
		_mm_mine_colors.append(MINE_MARKER_COLORS[ty])
	_mm_mine_ver = game.res_dirty

func _draw_mine_markers() -> void:
	# One pass over the cached centres. Unexplored tiles are skipped so the
	# markers never reveal fog; explored-but-not-visible tiles keep theirs.
	# 7x7 diamond: bright ore core (Manhattan <= 2) + 1px dark rim (== 3).
	var has_fog := Data.FOG_OF_WAR
	var fog: PackedByteArray = world.fog_explored
	var mw := game.MAP_W
	var mh := game.MAP_H
	for i in _mm_mine_centers.size():
		var t: Vector2i = _mm_mine_centers[i]
		if has_fog and fog[t.y * mw + t.x] == 0:
			continue
		var c: Color = _mm_mine_colors[i]
		for dyi in 7:
			var py := t.y + dyi - 3
			if py < 0 or py >= mh:
				continue
			for dxi in 7:
				var px := t.x + dxi - 3
				if px < 0 or px >= mw:
					continue
				var d := absi(dxi - 3) + absi(dyi - 3)
				if d > 3:
					continue
				minimap_img.set_pixel(px, py, MINE_MARKER_RIM if d == 3 else c)

func _mm_player_color(p: int) -> Color:
	# T-MINIMAP-BRIGHT: wrap instead of falling back to gray, so P8+ recycle
	# the bright palette (mirrors world.gd PLAYER_COLORS wrapi behaviour).
	return MM_PLAYER_COLORS[wrapi(p, 0, MM_PLAYER_COLORS.size())]

func _mm_enemy_visible(t: Vector2i) -> bool:
	# T-MINIMAP-EXTRA: an enemy needs BOTH explored history and current
	# player-0 sight (fog_vis). With fog off everything is visible upstream.
	if not Data.FOG_OF_WAR:
		return true
	if t.x < 0 or t.y < 0 or t.x >= game.MAP_W or t.y >= game.MAP_H:
		return false
	var i := t.y * game.MAP_W + t.x
	return world.fog_explored[i] != 0 and world.fog_vis[i] != 0

func _rebuild_bld_blips() -> void:
	# T-MINIMAP-EXTRA: buildings never move, so rebuild only when bld_dirty
	# moves (spawn/finish/destroy). Fog is applied at stamp time, not cached.
	_mm_bld_centers.clear()
	_mm_bld_colors.clear()
	_mm_bld_enemy.clear()
	for e in game.live_blds:
		if e.dead:
			continue
		var t := game.tile_of(e.pos)
		if t.x < 0 or t.y < 0 or t.x >= game.MAP_W or t.y >= game.MAP_H:
			continue
		var p := wrapi(int(e.player), 0, MM_PLAYER_COLORS.size())
		_mm_bld_centers.append(t)
		_mm_bld_colors.append(_mm_player_color(p))
		_mm_bld_enemy.append(int(e.player) != 0)
	_mm_bld_ver = game.bld_dirty

func _draw_bld_blips() -> void:
	# T-MINIMAP-EXTRA: own = 2x2 player tint; enemy = 3x3 dark-red rim with a
	# bright player-tint core. Enemy buildings need current visibility too.
	var mw := game.MAP_W
	var mh := game.MAP_H
	for i in _mm_bld_centers.size():
		var t: Vector2i = _mm_bld_centers[i]
		var enemy := _mm_bld_enemy[i]
		if enemy and not _mm_enemy_visible(t):
			continue
		var c: Color = _mm_bld_colors[i]
		if enemy:
			for dxi in 3:
				for dyi in 3:
					var px := t.x + dxi - 1
					var py := t.y + dyi - 1
					if px < 0 or py < 0 or px >= mw or py >= mh:
						continue
					minimap_img.set_pixel(px, py, c if dxi == 1 and dyi == 1 else MM_ENEMY_RIM)
		else:
			for dxi in 2:
				for dyi in 2:
					minimap_img.set_pixel(mini(mw - 1, t.x + dxi), mini(mh - 1, t.y + dyi), c)

func _rebuild_unit_blips() -> void:
	# T-MINIMAP-EXTRA: one scan of live_units per minimap tick (movement is the
	# only reason these positions change). Small armies get 1px dots; above
	# MM_CLUSTER_THRESHOLD per player they collapse into coarse cluster blips,
	# so a 1000-unit army costs a handful of set_pixel calls, not 1000.
	_mm_unit_tiles.clear()
	_mm_unit_colors.clear()
	_mm_unit_players.clear()
	_mm_unit_enemy.clear()
	_mm_unit_dots.clear()
	_mm_cluster_map.clear()
	_mm_cluster_sx.clear()
	_mm_cluster_sy.clear()
	_mm_cluster_cnt.clear()
	_mm_cluster_colors.clear()
	_mm_cluster_enemy.clear()
	_mm_unit_counts.fill(0)
	var mw := game.MAP_W
	var mh := game.MAP_H
	for e in game.live_units:
		if e.dead:
			continue
		var p := int(e.player)
		var pi := wrapi(p, 0, MM_PLAYER_COLORS.size())
		var own := p == 0
		var t := game.tile_of(e.pos)
		if t.x < 0 or t.y < 0 or t.x >= mw or t.y >= mh:
			continue
		if not own and not _mm_enemy_visible(t):
			continue
		var c := _mm_player_color(pi)
		if own and bool(e.get("selected", false)):
			c = Color(1, 1, 1)
		_mm_unit_counts[pi] += 1
		_mm_unit_tiles.append(t)
		_mm_unit_colors.append(c)
		_mm_unit_players.append(pi)
		_mm_unit_enemy.append(not own)
	for i in _mm_unit_tiles.size():
		var pi: int = _mm_unit_players[i]
		if _mm_unit_counts[pi] <= MM_CLUSTER_THRESHOLD:
			_mm_unit_dots.append(i)
			continue
		var t: Vector2i = _mm_unit_tiles[i]
		# player is part of the key so a cluster never mixes two owners' colours
		var key := (pi * _mm_cluster_rows + int(t.y / MM_CLUSTER_CELL)) * _mm_cluster_cols + int(t.x / MM_CLUSTER_CELL)
		var ci: int = _mm_cluster_map.get(key, -1)
		if ci < 0:
			ci = _mm_cluster_sx.size()
			_mm_cluster_map[key] = ci
			_mm_cluster_sx.append(0)
			_mm_cluster_sy.append(0)
			_mm_cluster_cnt.append(0)
			_mm_cluster_colors.append(_mm_unit_colors[i])
			_mm_cluster_enemy.append(_mm_unit_enemy[i])
		_mm_cluster_sx[ci] += t.x
		_mm_cluster_sy[ci] += t.y
		_mm_cluster_cnt[ci] += 1

func _mm_rim_cross(x: int, y: int, rim: Color) -> void:
	# 1px cross rim around a single-pixel unit dot; map-bounds guarded.
	var w := game.MAP_W
	var h := game.MAP_H
	if x > 0:
		minimap_img.set_pixel(x - 1, y, rim)
	if x + 1 < w:
		minimap_img.set_pixel(x + 1, y, rim)
	if y > 0:
		minimap_img.set_pixel(x, y - 1, rim)
	if y + 1 < h:
		minimap_img.set_pixel(x, y + 1, rim)

func _mm_rim_ring3(x: int, y: int, rim: Color, corners_only: bool) -> void:
	# 3x3 rim around a cluster blip. Enemy clusters ring all 8 cells; own
	# clusters are a bright plus, so only the 4 diagonal corners get rimmed.
	var w := game.MAP_W
	var h := game.MAP_H
	for dxi in 3:
		for dyi in 3:
			if dxi == 1 and dyi == 1:
				continue  # centre: bright core is painted in pass 2
			if corners_only and (dxi == 1 or dyi == 1):
				continue  # leave the 4 orthogonal cells to the own plus-core
			var px := x + dxi - 1
			var py := y + dyi - 1
			if px < 0 or py < 0 or px >= w or py >= h:
				continue
			minimap_img.set_pixel(px, py, rim)

func _draw_unit_blips() -> void:
	# T-MINIMAP-BRIGHT: two passes — every dark rim goes down first, then every
	# bright player-tinted core. A neighbour's rim can therefore never dim an
	# adjacent blip's colour, and every dot/cluster gets a near-black (own) or
	# dark-red (enemy) outline so the tint reads on the dark fogged terrain.
	# Layering (last wins) = mines < buildings < rims < cores.
	var mw := game.MAP_W
	var mh := game.MAP_H
	# Pass 1: rims.
	for i in _mm_unit_dots.size():
		var ui: int = _mm_unit_dots[i]
		var t: Vector2i = _mm_unit_tiles[ui]
		if t.x < 0 or t.y < 0 or t.x >= mw or t.y >= mh:
			continue
		_mm_rim_cross(t.x, t.y, MM_ENEMY_RIM if _mm_unit_enemy[ui] else MM_OWN_RIM)
	for ci in _mm_cluster_sx.size():
		var cn := maxi(1, _mm_cluster_cnt[ci])
		var ccx := clampi(int(_mm_cluster_sx[ci] / cn), 0, mw - 1)
		var ccy := clampi(int(_mm_cluster_sy[ci] / cn), 0, mh - 1)
		_mm_rim_ring3(ccx, ccy, MM_ENEMY_RIM if _mm_cluster_enemy[ci] else MM_OWN_RIM, not _mm_cluster_enemy[ci])
	# Pass 2: bright cores (always win over any rim painted above).
	for i2 in _mm_unit_dots.size():
		var ui2: int = _mm_unit_dots[i2]
		var t2: Vector2i = _mm_unit_tiles[ui2]
		if t2.x < 0 or t2.y < 0 or t2.x >= mw or t2.y >= mh:
			continue
		minimap_img.set_pixel(t2.x, t2.y, _mm_unit_colors[ui2])
	for ci2 in _mm_cluster_sx.size():
		var n := maxi(1, _mm_cluster_cnt[ci2])
		var cx := clampi(int(_mm_cluster_sx[ci2] / n), 0, mw - 1)
		var cy := clampi(int(_mm_cluster_sy[ci2] / n), 0, mh - 1)
		var cc: Color = _mm_cluster_colors[ci2]
		minimap_img.set_pixel(cx, cy, cc)
		if not _mm_cluster_enemy[ci2]:
			# own cluster = bright plus; enemy core stays 1px inside its rim
			if cx > 0:
				minimap_img.set_pixel(cx - 1, cy, cc)
			if cx + 1 < mw:
				minimap_img.set_pixel(cx + 1, cy, cc)
			if cy > 0:
				minimap_img.set_pixel(cx, cy - 1, cc)
			if cy + 1 < mh:
				minimap_img.set_pixel(cx, cy + 1, cc)

func _update_minimap() -> void:
	if world == null:
		return
	# T-PERF-RENDER: hidden minimap needs no pixels; it refreshes on the next
	# tick after being reshown (bounded by MINIMAP_INTERVAL staleness).
	if minimap_panel != null and not minimap_panel.visible:
		return
	# terrain base is static: duplicate the cached image (C++ fast) instead
	# of repainting 100k tiles every update. The fog dim is cached separately
	# and only rebuilt when the world's fog revision moves.
	if Data.FOG_OF_WAR:
		if minimap_fog_base == null or minimap_fog_rev != world.fog_revision:
			minimap_fog_base = minimap_base.duplicate()
			for y in game.MAP_H:
				for x in game.MAP_W:
					if world.fog_explored[y * game.MAP_W + x] == 0:
						var c: Color = minimap_fog_base.get_pixel(x, y)
						minimap_fog_base.set_pixel(x, y, Color(c.r * 0.25, c.g * 0.25, c.b * 0.25))
			minimap_fog_rev = world.fog_revision
		minimap_img = minimap_fog_base.duplicate()
	else:
		minimap_img = minimap_base.duplicate()
	# T-MINIMAP: mine/quarry blips come from a cached centre list, rebuilt only
	# when res_dirty changes. One small fog-gated pass per minimap tick.
	if game.res_dirty != _mm_mine_ver:
		_rebuild_mine_markers()
	_draw_mine_markers()
	for n in game.res_nodes:
		var ty := str(n.get("type", ""))
		# ore deposits + stone quarries are already handled by the marker pass
		if ty == "gold" or ty == "iron" or ty == "coal" or ty == "stone":
			continue
		var t := game.tile_of(n.pos)
		if n.hits <= 0:
			# T-FIELDS-GFX: depleted fields stay on the minimap (brown
			# stubble); regrowing ones read olive. Other spent nodes vanish.
			if ty == "food" and int(n.get("max_hits", 0)) > 0:
				var fst := str(game.field_state(n)) if game.has_method("field_state") else "depleted"
				if fst == "regrowing":
					_mm_plot(t, Color(0.55, 0.58, 0.25), false)
				else:
					_mm_plot(t, Color(0.32, 0.26, 0.17), false)
			continue
		match ty:
			"wood":
				_mm_plot(t, Color(0.05, 0.2, 0.05), true)
			"food":
				# T-FIELDS-GFX: ripe = gold, growing = green.
				var fst2 := str(game.field_state(n)) if game.has_method("field_state") else "ripe"
				if fst2 == "growing":
					_mm_plot(t, Color(0.35, 0.62, 0.22), false)
				else:
					_mm_plot(t, Color(0.85, 0.75, 0.3), false)
	# T-MINIMAP-EXTRA: entity blips layered above terrain/resource markers.
	# Buildings cache on bld_dirty; unit dots refresh once per MINIMAP_INTERVAL
	# tick (that cadence is what shows movement). Enemy pixels are stamped last.
	if game.bld_dirty != _mm_bld_ver:
		_rebuild_bld_blips()
	_draw_bld_blips()
	_rebuild_unit_blips()
	_draw_unit_blips()
	# T-PERF-RENDER: fog dimming now lives in the cached minimap_fog_base, so
	# no full-map pass is needed here. Refresh the display image from the
	# freshly rebuilt clean image ONCE per tick; camera scrolling afterwards
	# only repaints the thin box borders (no per-frame full-image duplicate).
	minimap_view_img = minimap_img.duplicate()
	_mm_box_last = Vector4i(-1, -1, -1, -1)
	_draw_minimap_viewport_box(true)

func hud_report() -> Dictionary:
	# used by --self-test
	var res_ok := true
	for l in res_labels:
		if l.text.strip_edges() == "":
			res_ok = false
	return {
		"resource_labels": res_ok,
		"minimap": minimap_tex != null and minimap_img != null,
		"selection_panel": sel_panel != null and sel_panel.visible,
		"top_bar": top_panel != null and top_panel.visible,
		"status_text": status_label.text,
		"worker_counts": worker_counts.duplicate(true),
		"idle_peasants": idle_count,
		"free_mine_slots": free_slots_count,
		"gold_deficit": gold_deficit,
		"score": game.players[0].score if game != null else -1,
	}
