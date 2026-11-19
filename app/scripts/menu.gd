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

var data: Dictionary = {}
var root: PanelContainer
var title_label: Label
var body: VBoxContainer
var nation0 := "ukr"
var nation1 := "rus"
var map_type := "land"
var start_option := "default"
var mode := "skirmish"
var mission_name := ""

func _ready() -> void:
	layer = 20
	_load_data()
	_build()

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

func _map_types() -> Array:
	if data.has("map_types"):
		return data.map_types
	return [{"id": "land", "name": "Land", "descr": ""}]

func _starts() -> Array:
	if data.has("start_options"):
		return data.start_options
	return [{"id": "default", "name": "Town + peasants", "descr": ""}]

func _campaigns() -> Array:
	return data.get("campaigns", [])

func _battles() -> Array:
	return data.get("battles", [])

func _build() -> void:
	root = PanelContainer.new()
	root.set_anchors_preset(Control.PRESET_CENTER)
	root.custom_minimum_size = Vector2(560, 0)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.09, 0.07, 0.05, 0.96)
	style.set_corner_radius_all(6)
	style.set_border_width_all(2)
	style.border_color = Color(0.72, 0.6, 0.32)
	root.add_theme_stylebox_override("panel", style)
	add_child(root)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 8)
	root.add_child(vb)
	title_label = Label.new()
	title_label.text = "COSSACKS 3 - singleplayer port"
	title_label.add_theme_font_size_override("font_size", 26)
	title_label.add_theme_color_override("font_color", Color(1, 0.9, 0.5))
	vb.add_child(title_label)
	var sub := Label.new()
	sub.text = "Skirmish, historical battles and campaigns (original names from campaigns.cfg / battles.cfg)"
	sub.add_theme_font_size_override("font_size", 13)
	sub.add_theme_color_override("font_color", Color(0.8, 0.78, 0.7))
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(sub)
	body = VBoxContainer.new()
	body.add_theme_constant_override("separation", 6)
	vb.add_child(body)
	_show_main()

func _clear() -> void:
	for c in body.get_children():
		body.remove_child(c)
		c.queue_free()

func _btn(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, 36)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return b

func _show_main() -> void:
	_clear()
	var b1 := _btn("Skirmish - random map")
	b1.pressed.connect(_show_skirmish)
	body.add_child(b1)
	var b2 := _btn("Historical battles (%d)" % _battles().size())
	b2.pressed.connect(_show_battles)
	body.add_child(b2)
	var b3 := _btn("Campaigns (%d)" % _campaigns().size())
	b3.pressed.connect(_show_campaigns)
	body.add_child(b3)
	var hint := Label.new()
	hint.text = "Maps are generated in the original's style (open plains, forest belts, hills, lakes). Picks change nations, armies and objectives."
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_font_size_override("font_size", 12)
	hint.add_theme_color_override("font_color", Color(0.7, 0.7, 0.65))
	body.add_child(hint)

func _opt_row(label_text: String, items: Array, current: String, on_pick: Callable) -> HBoxContainer:
	var hb := HBoxContainer.new()
	var l := Label.new()
	l.text = label_text
	l.custom_minimum_size = Vector2(150, 0)
	hb.add_child(l)
	var ob := OptionButton.new()
	ob.size_flags_horizontal = Control.SIZE_EXPAND_FILL
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

func _show_skirmish() -> void:
	_clear()
	mode = "skirmish"
	body.add_child(_opt_row("Your nation", _nations(), nation0, func(id: String): nation0 = id))
	body.add_child(_opt_row("Enemy nation", _nations(), nation1, func(id: String): nation1 = id))
	body.add_child(_opt_row("Map type", _map_types(), map_type, func(id: String): map_type = id))
	body.add_child(_opt_row("Starting", _starts(), start_option, func(id: String): start_option = id))
	var go := _btn("Start skirmish")
	go.pressed.connect(func(): _emit_start("Skirmish"))
	body.add_child(go)
	var back := _btn("Back")
	back.pressed.connect(_show_main)
	body.add_child(back)

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
	body.add_child(back)

func _on_battle(bd: Dictionary) -> void:
	mode = "battle"
	mission_name = str(bd.get("id", "battle1"))
	start_option = "armylarge"
	_emit_start("Historical battle %s" % mission_name)

func _show_campaigns() -> void:
	_clear()
	for c in _campaigns():
		var cd: Dictionary = c
		var missions: Array = cd.get("missions", [])
		var cb := _btn("%s (%d missions)" % [str(cd.get("id", "?")), missions.size()])
		cb.tooltip_text = ", ".join(missions.slice(0, 5))
		cb.pressed.connect(_on_campaign.bind(cd))
		body.add_child(cb)
	var back := _btn("Back")
	back.pressed.connect(_show_main)
	body.add_child(back)

func _on_campaign(cd: Dictionary) -> void:
	var missions: Array = cd.get("missions", [])
	mode = "skirmish" if missions.is_empty() else "campaign"
	mission_name = str(missions[0]) if not missions.is_empty() else str(cd.get("id", ""))
	start_option = "default"
	_emit_start("Campaign %s - %s" % [str(cd.get("id", "")), mission_name])

func _emit_start(descr: String) -> void:
	var cfg := {"mode": mode, "nation0": nation0, "nation1": nation1,
		"map_type": map_type, "start_option": start_option,
		"mission": mission_name, "descr": descr}
	chosen.emit(cfg)
