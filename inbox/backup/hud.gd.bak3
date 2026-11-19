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
var sel_panel: PanelContainer
var sel_box: HBoxContainer
var build_bar: HBoxContainer
var msg_label: Label
var msg_timer := 0.0
var status_label: Label
var settings_label: Label
var minimap_tex: ImageTexture
var minimap_img: Image
var minimap_rect: TextureRect
var mm_timer := 0.0
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
var want_rally := false
var last_ids: Array = []
var summary_label: Label
var prog_entries: Array = []  # {label, e}
var dyn_buttons: Array = []   # {b, kind, e, sid, uid}

func bind(g: C3Game, w: C3World) -> void:
	game = g
	world = w
	icons_tex = load("res://assets/ui/icons.bmp")
	units_tex = load("res://assets/ui/iconsunits.bmp")
	audio_click = AudioStreamPlayer.new()
	audio_click.stream = load("res://assets/sounds/btnclick.ogg")
	add_child(audio_click)
	_build_top()
	_build_bottom()
	_build_minimap()
	msg_label = Label.new()
	msg_label.position = Vector2(340, 36)
	msg_label.add_theme_font_size_override("font_size", 15)
	msg_label.add_theme_color_override("font_color", Color(1, 0.95, 0.8))
	add_child(msg_label)
	hint_label = Label.new()
	hint_label.position = Vector2(340, 58)
	hint_label.add_theme_font_size_override("font_size", 14)
	hint_label.add_theme_color_override("font_color", Color(1, 0.9, 0.5))
	add_child(hint_label)
	game_over_label = Label.new()
	game_over_label.set_anchors_preset(Control.PRESET_CENTER)
	game_over_label.add_theme_font_size_override("font_size", 42)
	game_over_label.visible = false
	add_child(game_over_label)
	game.message.connect(_on_message)

func atlas(src: Texture2D, region: Rect2) -> AtlasTexture:
	var at := AtlasTexture.new()
	at.atlas = src
	at.region = region
	return at

func _build_top() -> void:
	top_panel = PanelContainer.new()
	top_panel.position = Vector2(8, 8)
	top_panel.custom_minimum_size = Vector2(0, 0)
	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", 10)
	top_panel.add_child(bar)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.10, 0.08, 0.06, 0.88)
	style.set_corner_radius_all(4)
	style.set_border_width_all(1)
	style.border_color = Color(0.72, 0.6, 0.32)
	top_panel.add_theme_stylebox_override("panel", style)
	for i in 6:
		var ic := TextureRect.new()
		ic.texture = atlas(icons_tex, Data.RES_ICONS[i])
		ic.custom_minimum_size = Vector2(36, 31)
		ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		bar.add_child(ic)
		var l := Label.new()
		l.text = "0"
		l.add_theme_font_size_override("font_size", 17)
		l.add_theme_color_override("font_color", Color(1, 0.97, 0.9))
		bar.add_child(l)
		res_labels.append(l)
	var sep := VSeparator.new()
	bar.add_child(sep)
	status_label = Label.new()
	status_label.text = ""
	status_label.add_theme_font_size_override("font_size", 15)
	status_label.add_theme_color_override("font_color", Color(0.8, 0.85, 1))
	bar.add_child(status_label)
	# game speed + menu, like the original's top-right controls
	var sep2 := VSeparator.new()
	bar.add_child(sep2)
	for sp in [["II", 0.0], ["1x", 1.0], ["2x", 2.0], ["4x", 4.0]]:
		var sb := Button.new()
		sb.text = sp[0]
		sb.tooltip_text = "Game speed %s (Space pauses)" % sp[0]
		sb.custom_minimum_size = Vector2(40, 30)
		sb.pressed.connect(_on_speed.bind(float(sp[1])))
		bar.add_child(sb)
		speed_buttons.append(sb)
	var mb := Button.new()
	mb.text = "Menu"
	mb.tooltip_text = "Back to the singleplayer menu"
	mb.custom_minimum_size = Vector2(60, 30)
	mb.pressed.connect(_on_menu)
	bar.add_child(mb)
	speed_label = Label.new()
	speed_label.text = "1x"
	speed_label.add_theme_font_size_override("font_size", 14)
	speed_label.add_theme_color_override("font_color", Color(1, 0.9, 0.5))
	bar.add_child(speed_label)
	add_child(top_panel)
	_build_objectives()
	# which settings file the game is running with, shown small in the corner
	settings_label = Label.new()
	settings_label.text = _settings_text()
	settings_label.add_theme_font_size_override("font_size", 12)
	settings_label.add_theme_color_override("font_color", Color(0.65, 0.68, 0.75))
	settings_label.anchor_left = 1.0
	settings_label.anchor_right = 1.0
	settings_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	settings_label.offset_left = -420
	settings_label.offset_top = 10
	settings_label.offset_right = -12
	add_child(settings_label)

func _build_objectives() -> void:
	obj_panel = PanelContainer.new()
	obj_panel.position = Vector2(8, 56)
	obj_panel.visible = false
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.10, 0.08, 0.06, 0.85)
	style.set_corner_radius_all(4)
	style.set_border_width_all(1)
	style.border_color = Color(0.72, 0.6, 0.32)
	obj_panel.add_theme_stylebox_override("panel", style)
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
	var head := Label.new()
	head.text = "Objectives"
	head.add_theme_font_size_override("font_size", 14)
	head.add_theme_color_override("font_color", Color(1, 0.9, 0.5))
	obj_box.add_child(head)
	for o in game.objectives:
		var l := Label.new()
		l.text = ("[x] " if bool(o.get("done", false)) else "[ ] ") + str(o.get("text", ""))
		l.add_theme_font_size_override("font_size", 13)
		l.add_theme_color_override("font_color", Color(0.85, 0.85, 0.8))
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
	sel_panel.offset_top = -128
	sel_panel.offset_left = 8
	sel_panel.offset_right = 560
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.10, 0.08, 0.06, 0.88)
	style.set_corner_radius_all(4)
	style.set_border_width_all(1)
	style.border_color = Color(0.72, 0.6, 0.32)
	sel_panel.add_theme_stylebox_override("panel", style)
	var vb := VBoxContainer.new()
	sel_panel.add_child(vb)
	sel_box = HBoxContainer.new()
	sel_box.add_theme_constant_override("separation", 4)
	vb.add_child(sel_box)
	build_bar = HBoxContainer.new()
	build_bar.add_theme_constant_override("separation", 4)
	vb.add_child(build_bar)
	add_child(sel_panel)

func _unit_button(tex: Texture2D, region: Rect2, tip: String) -> Button:
	var b := Button.new()
	b.icon = atlas(tex, region)
	b.custom_minimum_size = Vector2(52, 52)
	b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	b.expand_icon = true
	b.tooltip_text = tip
	b.pressed.connect(func(): audio_click.play())
	return b

func _clear_row(row: HBoxContainer) -> void:
	for c in row.get_children():
		row.remove_child(c)
		c.queue_free()

func refresh_selection(selected: Array) -> void:
	_clear_row(sel_box)
	_clear_row(build_bar)
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
		var hint := Label.new()
		hint.text = "Nothing selected. Left-click or drag to select."
		hint.add_theme_color_override("font_color", Color(0.75, 0.72, 0.65))
		sel_box.add_child(hint)
		return
	var mine := selected.filter(func(e): return e.player == 0)
	if mine.is_empty():
		var l := Label.new()
		l.text = "Enemy %s  HP %d/%d" % [_name_of(selected[0]), maxi(0, selected[0].hp), selected[0].max_hp]
		l.add_theme_color_override("font_color", Color(1, 0.6, 0.55))
		sel_box.add_child(l)
		var atk := Button.new()
		atk.text = "Attack"
		atk.tooltip_text = "Select your units, then right-click the enemy"
		atk.pressed.connect(_on_attack_hint)
		build_bar.add_child(atk)
		return
	# summary line: what is picked, its health and its current order
	var first: Dictionary = mine[0]
	summary_label = Label.new()
	summary_label.text = _selection_summary(mine)
	summary_label.add_theme_color_override("font_color", Color(1, 0.97, 0.9))
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
				var prog := Label.new()
				var kp: float = clampf(e.progress / maxf(1.0, e.def.build_time), 0.0, 1.0)
				prog.text = "building %d%%" % int(kp * 100.0)
				prog.add_theme_color_override("font_color", Color(0.7, 0.9, 0.7))
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
					if e.queue.size() > 0:
						tb.text = str(e.queue.size()) if rsid == e.queue[0].sid else ("+%d" % q if q > 0 else "")
					elif q > 0:
						tb.text = str(q)
					tb.pressed.connect(_on_train.bind(e, rsid))
					train_buttons[rsid] = tb
					build_bar.add_child(tb)
					dyn_buttons.append({"b": tb, "kind": "train", "e": e, "sid": rsid, "uid": ""})
				# research buttons (blacksmith / academy): video shows the
				# upgrade rows next to the unit queue
				for uid in Data.UPGRADES:
					var u: Dictionary = Data.UPGRADES[uid]
					if u.building != e.sid:
						continue
					var rb := Button.new()
					var done: bool = game.players[0].upgrades.has(uid)
					var researching: bool = e.get("research") != null and e.research.uid == uid
					rb.text = ("[x] " if done else ("... " if researching else "")) + str(u.name)
					rb.tooltip_text = "%s - %s%s" % [u.name, _price_text(u.cost), " (researched)" if done else ""]
					rb.disabled = done or researching
					rb.custom_minimum_size = Vector2(120, 50)
					rb.pressed.connect(_on_research.bind(e, uid))
					build_bar.add_child(rb)
					dyn_buttons.append({"b": rb, "kind": "research", "e": e, "sid": "", "uid": uid})
				if e.sid == "wal" and e.finished:
					var gb := Button.new()
					gb.text = "Gate"
					gb.tooltip_text = "Convert this wall segment into a gate"
					gb.custom_minimum_size = Vector2(56, 50)
					gb.pressed.connect(_on_make_gate.bind(e))
					build_bar.add_child(gb)
				if e.sid == "gat":
					var ob := Button.new()
					ob.text = "Open" if bool(e.get("closed", false)) else "Close"
					ob.custom_minimum_size = Vector2(56, 50)
					ob.pressed.connect(_on_gate_toggle.bind(e))
					build_bar.add_child(ob)
				if str(e.sid) in ["officer", "officer18"] and e.player == 0:
					for fs in [15, 36, 72, 120, 196, 400]:
						var fb := Button.new()
						fb.text = str(fs)
						fb.tooltip_text = "Form a %d-man formation from nearby troops" % fs
						fb.custom_minimum_size = Vector2(40, 50)
						fb.pressed.connect(_on_form_size.bind(e, fs))
						build_bar.add_child(fb)
				# market barter (video: the exchange sliders in the market)
				if e.sid == "mar":
					var amt := Button.new()
					amt.text = "%d" % int(trade_amount)
					amt.tooltip_text = "Trade amount per click (100/500)"
					amt.custom_minimum_size = Vector2(56, 50)
					amt.pressed.connect(_on_trade_amount)
					build_bar.add_child(amt)
					for pair in [["wood", "gold"], ["food", "iron"], ["stone", "coal"], ["gold", "food"]]:
						var mb := Button.new()
						mb.text = "%s>%s" % [pair[0].substr(0, 1).to_upper(), pair[1].substr(0, 1).to_upper()]
						mb.tooltip_text = "Trade %d %s for %s (rate %d%%)" % [int(trade_amount), pair[0], pair[1], int(game.players[0].market_rate * 100.0)]
						mb.custom_minimum_size = Vector2(56, 50)
						mb.pressed.connect(_on_trade.bind(e, pair[0], pair[1]))
						build_bar.add_child(mb)
				# rally point: one click enters the mode, right-click then sets it
				if e.def.get("trains", []).size() > 0:
					var ral := Button.new()
					ral.text = "Rally [R]"
					ral.tooltip_text = "Set rally point: click, then right-click the map"
					ral.custom_minimum_size = Vector2(64, 50)
					ral.pressed.connect(_on_rally_mode)
					build_bar.add_child(ral)
	# squad panel: officer + soldiers -> Form [F], Line [J], Column [K], Square [L]
	var offs: Array = mine.filter(func(e): return e.kind == "unit" and (e.sid == "officer" or e.sid == "officer18"))
	var soldiers: Array = mine.filter(func(e): return e.kind == "unit" and e.sid != "peasant" and not e.def.get("support", false) and e.sid != "officer" and e.sid != "officer18")
	if not offs.is_empty() and mine.all(func(e): return e.kind == "unit" and e.player == 0):
		for o in offs:
			var sq: Dictionary = game.squad_of_unit(o.id)
			var label := "Form [F]" if sq.is_empty() else "Squad %d (%s)" % [int(sq.squad_id), str(sq.get("formation", "line"))]
			var fb := Button.new()
			fb.text = label
			fb.tooltip_text = "Form a squad around this officer (F). Soldiers keep formation."
			fb.custom_minimum_size = Vector2(110, 50)
			fb.pressed.connect(_on_squad_form.bind(mine))
			build_bar.add_child(fb)
			if not sq.is_empty():
				for form in ["line", "column", "square"]:
					var fob := Button.new()
					fob.text = form.substr(0, 3).to_upper()
					fob.tooltip_text = "%s formation (%s)" % [form, "J" if form == "line" else ("K" if form == "column" else "L")]
					fob.disabled = str(sq.get("formation", "")) == form
					fob.custom_minimum_size = Vector2(48, 50)
					fob.pressed.connect(_on_squad_form_set.bind(int(sq.squad_id), form))
					build_bar.add_child(fob)
				var db := Button.new()
				db.text = "Disband"
				db.tooltip_text = "Disband the squad (Shift+F)"
				db.custom_minimum_size = Vector2(80, 50)
				db.pressed.connect(_on_squad_disband.bind(int(sq.squad_id)))
				build_bar.add_child(db)
	if mine.size() > 0 and mine.all(func(e): return e.kind == "unit" and e.sid == "peasant"):
		build_menu_open = true
		_refresh_build_menu(mine)
	elif build_menu_open:
		build_menu_open = false

func _on_train(bld: Dictionary, sid: String) -> void:
	audio_click.play()
	game.train_unit(0, bld, sid)
	refresh_selection(game.get_selected())

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

func _on_form_size(off: Dictionary, size: int) -> void:
	audio_click.play()
	game.cmd_form_size(off, size)
	refresh_selection([off])

func _on_trade(bld: Dictionary, give: String, want: String) -> void:
	audio_click.play()
	game.trade(0, give, want, trade_amount)
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
			s += "  training %s (%d)" % [first.queue[0].sid, first.queue.size()]
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
	var order := ["cen", "hou", "wal", "bar", "sta", "bla", "aca", "sto", "mil", "mar", "art", "tow", "mine_gold", "mine_iron", "mine_coal"]
	for sid in order:
		var def: Dictionary = Data.BUILDINGS[sid]
		var b := Button.new()
		b.icon = atlas(icons_tex, def.icon)
		b.custom_minimum_size = Vector2(50, 50)
		b.expand_icon = true
		b.tooltip_text = "%s  [%s]  %s" % [ConfigScript.building_name(sid), _key_text(sid),
			_price_text(def.cost)]
		b.disabled = not Data.can_pay(game.players[0].res, def.cost)
		b.pressed.connect(_on_build_pick.bind(sid))
		build_buttons[sid] = b
		build_bar.add_child(b)
		dyn_buttons.append({"b": b, "kind": "build", "e": {}, "sid": sid, "uid": ""})
	var cancel := Button.new()
	cancel.text = "Cancel build menu (Esc)"
	cancel.pressed.connect(_on_cancel_build_menu)
	build_bar.add_child(cancel)

# The letter the building is built with, as the settings file says.
func _key_text(sid: String) -> String:
	var keys: Dictionary = Data.HOTKEYS.get("build", {})
	if sid.begins_with("mine_"):
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
			if be2.queue.size() > 0:
				b.text = str(be2.queue.size()) if d.sid == be2.queue[0].sid else (("+%d" % q) if q > 0 else "")
			elif q > 0:
				b.text = str(q)
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
			var def: Dictionary = Data.BUILDINGS.get(d.sid, {})
			if not def.is_empty():
				b.disabled = not Data.can_pay(game.players[0].res, def.cost)

func show_hint(text: String) -> void:
	if hint_label != null:
		hint_label.text = text

func _on_message(text: String) -> void:
	msg_label.text = text
	msg_timer = 4.0

func game_over(winner: int) -> void:
	game_over_label.visible = true
	game_over_label.text = ("Victory!" if winner == 0 else "Defeat")
	game_over_label.add_theme_color_override("font_color", Color(1, 0.9, 0.3) if winner == 0 else Color(1, 0.4, 0.3))

func _process(dt: float) -> void:
	if game == null:
		return
	for i in 6:
		res_labels[i].text = str(int(game.players[0].res[i]))
	var ucount := game.unit_count(0) + game.queue_count(0)
	# the hint line carries placement text; the status line keeps units/score
	if hint_label == null or hint_label.text == "":
		status_label.text = "units %d/%d    score %d    %s" % [ucount, game.players[0].farm_cap,
			game.players[0].score, ("PAUSED" if game.paused else "")]
	if msg_timer > 0.0:
		msg_timer -= dt
		if msg_timer <= 0.0:
			msg_label.text = ""
	mm_timer -= dt
	if mm_timer <= 0.0:
		mm_timer = 0.25
		_update_minimap()
	# live refresh: texts and affordable states only (never frees buttons,
	# so a click in flight always lands). Structural changes rebuild above.
	sel_timer -= dt
	if sel_timer <= 0.0:
		sel_timer = 0.75
		if build_ghost_sid == "":
			_update_dynamic()

func _build_minimap() -> void:
	minimap_img = Image.create(game.MAP_W, game.MAP_H, false, Image.FORMAT_RGBA8)
	minimap_tex = ImageTexture.create_from_image(minimap_img)
	minimap_rect = TextureRect.new()
	minimap_rect.texture = minimap_tex
	minimap_rect.custom_minimum_size = Vector2(160, 160)
	minimap_rect.stretch_mode = TextureRect.STRETCH_SCALE
	minimap_rect.anchor_left = 1.0
	minimap_rect.anchor_right = 1.0
	minimap_rect.anchor_top = 1.0
	minimap_rect.anchor_bottom = 1.0
	minimap_rect.offset_left = -176
	minimap_rect.offset_top = -176
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.07, 0.05, 0.9)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", style)
	panel.add_child(minimap_rect)
	panel.anchor_left = 1.0
	panel.anchor_right = 1.0
	panel.anchor_top = 1.0
	panel.anchor_bottom = 1.0
	panel.offset_left = -184
	panel.offset_top = -184
	add_child(panel)
	minimap_rect.gui_input.connect(_on_minimap_input)

func _on_minimap_input(ev: InputEvent) -> void:
	if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
		var mp := minimap_rect.get_local_mouse_position() / minimap_rect.size
		var world_pos := Vector2(mp.x * game.MAP_W, mp.y * game.MAP_H) * Data.TILE_M
		get_viewport().set_input_as_handled()
		var cam := get_viewport().get_camera_2d()
		if cam:
			cam.global_position = world_pos * world.view_scale

func _update_minimap() -> void:
	if world == null:
		return
	for y in game.MAP_H:
		for x in game.MAP_W:
			var i := y * game.MAP_W + x
			var c := Color(0.29, 0.42, 0.2)
			var t: int = game.terrain[i]
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
			minimap_img.set_pixel(x, y, c)
	for n in game.res_nodes:
		if n.hits <= 0:
			continue
		var t := game.tile_of(n.pos)
		match n.type:
			"wood":
				minimap_img.set_pixel(t.x, t.y, Color(0.05, 0.2, 0.05))
			"stone":
				minimap_img.set_pixel(t.x, t.y, Color(0.6, 0.6, 0.55))
			"food":
				minimap_img.set_pixel(t.x, t.y, Color(0.85, 0.75, 0.3))
			"gold":
				minimap_img.set_pixel(t.x, t.y, Color(0.9, 0.75, 0.2))
			"iron":
				minimap_img.set_pixel(t.x, t.y, Color(0.7, 0.45, 0.3))
			"coal":
				minimap_img.set_pixel(t.x, t.y, Color(0.25, 0.25, 0.28))
	for e in game.entities:
		if e.dead:
			continue
		var t := game.tile_of(e.pos)
		if e.kind == "building":
			for dy in 2:
				for dx in 2:
					var px := mini(game.MAP_W - 1, t.x + dx)
					var py := mini(game.MAP_H - 1, t.y + dy)
					minimap_img.set_pixel(px, py, Color(1, 1, 1) if e.player == 0 else Color(1, 0.2, 0.2))
		else:
			if t.x >= 0 and t.y >= 0 and t.x < game.MAP_W and t.y < game.MAP_H:
				minimap_img.set_pixel(t.x, t.y, Color(0.4, 0.7, 1) if e.player == 0 else Color(1, 0.3, 0.25))
	# fog
	for y in game.MAP_H:
		for x in game.MAP_W:
			var i := y * game.MAP_W + x
			if world.fog_explored[i] == 0:
				var c: Color = minimap_img.get_pixel(x, y)
				minimap_img.set_pixel(x, y, Color(c.r * 0.25, c.g * 0.25, c.b * 0.25))
	minimap_tex.update(minimap_img)

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
	}
