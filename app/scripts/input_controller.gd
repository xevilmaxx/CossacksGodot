# Mouse + keyboard control: selection, orders, build placement, hotkeys.
# Bindings follow the original data/game/var/hotkeys.cfg.
extends Node
class_name C3Input

const Data = preload("res://scripts/data.gd")
const ConfigScript = preload("res://scripts/config.gd")

var game: C3Game
var world: C3World
var hud: C3HUD
var camera: C3Camera
var selected_ids: Array = []
var drag_start := Vector2.INF
var dragging := false
var attack_move_mode := false
var ghost_sid := ""
var hotkeys: Dictionary = {}      # action -> key
var build_keys: Dictionary = {}    # building id -> key
var rally_mode := false
var cursor_tex: Dictionary = {}
var cursor_now := ""
var attack_ground_mode := false
var groups: Dictionary = {}
var last_click_t := 0.0
var last_click_sid := ""
# MICRO #6 / P-33: P waits for two route clicks; G waits for a friendly
# building. The route overlay is a child of world.fx_layer (no world.gd edit).
var patrol_mode := false
var patrol_a := Vector2.INF
var patrol_b := Vector2.INF
var guard_mode := false
var route_node: Node2D = null

func bind(g: C3Game, w: C3World, h: C3HUD, cam: C3Camera) -> void:
	game = g
	world = w
	hud = h
	camera = cam
	_read_hotkeys()
	for cn in ["default", "attack", "captureattack", "artillery", "patrol", "construct", "gainfood", "gainwood", "gainstone", "gotomine", "wait"]:
		var p := "res://assets/ui/cursor_%s.bmp" % cn
		if FileAccess.file_exists(p):
			cursor_tex[cn] = load(p)
	_set_cursor("default")
	# Draw the patrol route on the existing fx layer; a child node keeps this
	# feature entirely inside input_controller.gd (world.gd is not owned here).
	if world != null and world.fx_layer != null and route_node == null:
		route_node = Node2D.new()
		route_node.z_index = 5
		world.fx_layer.add_child(route_node)
		route_node.draw.connect(_draw_patrol_route)
	add_to_group("c3_input")

# The bindings come from the global settings file (config.json); the ones in
# the original data/game/var/hotkeys.cfg are the values it starts with.
func _read_hotkeys() -> void:
	hotkeys.clear()
	build_keys.clear()
	for action in Data.HOTKEYS:
		var spec: Variant = Data.HOTKEYS[action]
		if action == "build":
			if spec is Dictionary:
				for sid in spec:
					build_keys[sid] = ConfigScript.parse_hotkey(str(spec[sid]))
			continue
		if spec is String:
			hotkeys[action] = ConfigScript.parse_hotkey(str(spec))

# Is this key press the one bound to that action?
func _is(k: InputEventKey, action: String) -> bool:
	if not hotkeys.has(action):
		return false
	return _matches(k, hotkeys[action])

func _matches(k: InputEventKey, hk: Dictionary) -> bool:
	if hk.is_empty():
		return false
	if k.keycode != int(hk.get("key", 0)):
		return false
	if bool(hk.get("ctrl", false)) != k.ctrl_pressed:
		return false
	if bool(hk.get("shift", false)) != k.shift_pressed:
		return false
	if bool(hk.get("alt", false)) != k.alt_pressed:
		return false
	return true

func get_selected() -> Array:
	var out: Array = []
	for id in selected_ids:
		var e: Dictionary = game.by_id.get(id, {})
		if not e.is_empty() and not e.dead:
			out.append(e)
	return out

func _set_selection(arr: Array) -> void:
	for id in selected_ids:
		var e: Dictionary = game.by_id.get(id, {})
		if not e.is_empty():
			e["selected"] = false
	selected_ids = []
	for e in arr:
		selected_ids.append(e.id)
		e["selected"] = true
	game.bld_dirty += 1
	hud.refresh_selection(get_selected())

func minimap_order(pos: Vector2) -> void:
	var sel := get_selected().filter(func(e): return e.player == 0 and e.kind == "unit")
	if sel.is_empty():
		return
	var any_enemy := false
	for e in game.entities:
		if not e.dead and e.player != 0 and e.pos.distance_to(pos) < 6.0:
			any_enemy = true
			break
	for e in sel:
		if any_enemy and game.has_weapon(e):
			game.cmd_attack_move(e, pos)
		else:
			game.cmd_move(e, pos)

func command_from_hud(action: String) -> void:
	var sel := get_selected()
	match action:
		"attack_move":
			attack_move_mode = true
			hud.show_hint("Attack-move: right-click the destination")
		"stand_ground":
			for e in sel:
				game.cmd_stand_ground(e)
		"hold_fire":
			for e in sel:
				game.cmd_hold_fire(e, true)
		"feuer_frei":
			for e in sel:
				game.cmd_hold_fire(e, false)
		"patrol":
			begin_patrol_waypoints()
		"guard":
			begin_guard()
		"stop":
			for e in sel:
				game.cmd_stop(e)

# --- Micro #6: patrol waypoints and guard target ----------------------------
func _clear_pending_modes() -> void:
	attack_move_mode = false
	attack_ground_mode = false
	rally_mode = false
	if hud != null:
		hud.build_ghost_sid = ""

func begin_patrol_waypoints() -> void:
	patrol_mode = true
	patrol_a = Vector2.INF
	patrol_b = Vector2.INF
	_clear_pending_modes()
	if route_node != null:
		route_node.queue_redraw()
	if hud != null:
		hud.show_hint("Patrol: click the first waypoint")

# A missing second click falls back to the port's old +/-6 m segment.
func _finish_patrol(b: Vector2) -> void:
	var ordered := 0
	for e in get_selected():
		if e.player != 0 or e.kind != "unit":
			continue
		if patrol_a != Vector2.INF and b != Vector2.INF:
			game.cmd_patrol(e, patrol_a, b)
		else:
			game.cmd_patrol(e, e.pos + Vector2(-6, 0), e.pos + Vector2(6, 0))
		ordered += 1
	patrol_mode = false
	patrol_a = Vector2.INF
	patrol_b = Vector2.INF
	if route_node != null:
		route_node.queue_redraw()
	if hud != null:
		# hint_label is cleared every frame once the mode ends; use the
		# timed message line for the confirmation instead.
		hud._on_message("Patrol order given to %d unit(s)" % ordered if ordered > 0 else "Patrol: no units selected")

# Donor hotkeys.cfg binds G to BOTH guard and cancelguard. The sim now owns
# cmd_cancel_guard (game.gd:2090); fall back to cmd_stop on an older build.
func begin_guard() -> void:
	var had_guard := false
	for e in get_selected():
		if e.player == 0 and e.kind == "unit" and str(e.order.get("type", "")) == "guard":
			if game.has_method("cmd_cancel_guard"):
				game.cmd_cancel_guard(e)
			else:
				game.cmd_stop(e)
			had_guard = true
	if guard_mode:
		guard_mode = false
		if hud != null:
			hud.show_hint("")
		return
	if had_guard:
		if hud != null:
			hud._on_message("Guard cancelled")
		return
	guard_mode = true
	_clear_pending_modes()
	if hud != null:
		hud.show_hint("Guard: click a friendly building to protect")

func _draw_patrol_route() -> void:
	if world == null or route_node == null or patrol_a == Vector2.INF:
		return
	var a := world.world_to_px(patrol_a)
	var end_world := patrol_b
	if end_world == Vector2.INF:
		end_world = _screen_to_world(get_viewport().get_mouse_position())
	var b := world.world_to_px(end_world)
	route_node.draw_line(a, b, Color(1.0, 0.86, 0.30, 0.95), 2.0)
	for p in [a, b]:
		route_node.draw_line(p, p + Vector2(0, -15), Color(0.96, 0.90, 0.70, 0.95), 1.5)
		route_node.draw_colored_polygon([p + Vector2(0, -15), p + Vector2(11, -12), p + Vector2(0, -9)],
			Color(1.0, 0.82, 0.22, 0.95))
		route_node.draw_circle(p, 3.0, Color(1, 1, 1, 0.85))

func _screen_to_world(p: Vector2) -> Vector2:
	# Screen pixels -> map meters through the camera (position + zoom),
	# otherwise clicks only line up near the map origin.
	if world == null:
		return p / 16.0
	var xform := get_viewport().get_canvas_transform().affine_inverse()
	return (xform * p) / world.view_scale

func _pick(pw: Vector2, players_only := true) -> Dictionary:
	var best: Dictionary = {}
	var best_d := 1e9
	for e in game.entities:
		if e.dead:
			continue
		if players_only and e.player != 0:
			continue
		var d: float = e.pos.distance_to(pw)
		var r: float = game.pick_radius(e)
		if d < r and d < best_d:
			best_d = d
			best = e
	# fall back: any entity close by (enemies selectable for info/attack)
	if best.is_empty():
		for e in game.entities:
			if e.dead:
				continue
			var d: float = e.pos.distance_to(pw)
			if d < 2.0 and d < best_d:
				best_d = d
				best = e
	return best

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		var pw := _screen_to_world(mb.position)
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				if patrol_mode:
					if patrol_a == Vector2.INF:
						patrol_a = pw
						if hud != null:
							hud.show_hint("Patrol: click the second waypoint")
					else:
						_finish_patrol(pw)
					if route_node != null:
						route_node.queue_redraw()
					return
				if guard_mode:
					var gtarget := _pick(pw, true)
					if not gtarget.is_empty() and gtarget.player == 0 and gtarget.kind == "building":
						for gu in get_selected():
							if gu.player == 0 and gu.kind == "unit":
								game.cmd_guard(gu, gtarget)
						guard_mode = false
						if hud != null:
							hud._on_message("Guarding %s" % ConfigScript.building_name(str(gtarget.sid)))
					elif hud != null:
						hud.show_hint("Guard: click a friendly building to protect")
					return
				if hud.build_ghost_sid != "":
					var pos := pw
					var sel_peasants: Array = []
					for su in game.get_selected():
						if not su.is_empty() and str(su.get("sid", "")) == "peasant":
							sel_peasants.append(su)
					# DO-L8.04: echo the central can_place reason on the HUD hint
					# line before committing. Do NOT block the click: place_building
					# re-validates (and handles mine-snap), shift-queue still works.
					var echo_sid := game.resolve_mine_sid(hud.build_ghost_sid, pos)
					var chk0: Dictionary = game.can_place(0, echo_sid, pos)
					if not bool(chk0.get("ok", false)) and hud.has_method("show_hint"):
						hud.show_hint(str(chk0.get("reason", "Cannot build here.")))
					var b: Dictionary = game.place_building(0, hud.build_ghost_sid, pos, true, sel_peasants)
					if not b.is_empty() and not Input.is_key_pressed(KEY_SHIFT):
						hud.build_ghost_sid = ""
						_set_selection([b])
					return
				drag_start = mb.position
				dragging = false
			else:
				if drag_start == Vector2.INF:
					return
				var moved := (mb.position - drag_start).length() > 6.0
				if moved:
					var a := _screen_to_world(drag_start)
					var bp := _screen_to_world(mb.position)
					var rect := Rect2(minf(a.x, bp.x), minf(a.y, bp.y), absf(a.x - bp.x), absf(a.y - bp.y))
					var arr: Array = []
					for e in game.entities:
						if e.dead or e.player != 0 or e.kind != "unit":
							continue
						if rect.has_point(e.pos):
							arr.append(e)
					_set_selection(arr)
				else:
					var e := _pick(pw, false)
					var now := Time.get_ticks_msec() / 1000.0
					if not e.is_empty() and e.sid == last_click_sid and now - last_click_t < 0.35:
						# double click: all same-type units on screen (original behaviour)
						var arr2: Array = []
						var vp := world.view_rect
						for u in game.entities:
							if not u.dead and u.player == 0 and u.kind == "unit" and u.sid == e.sid and vp.has_point(u.pos * world.view_scale):
								arr2.append(u)
						_set_selection(arr2)
					elif not e.is_empty() and Input.is_key_pressed(KEY_SHIFT):
						var cur := get_selected()
						if not cur.has(e):
							cur.append(e)
						_set_selection(cur)
					else:
						_set_selection([e] if not e.is_empty() else [])
					last_click_t = now
					last_click_sid = str(e.sid) if not e.is_empty() else ""
				drag_start = Vector2.INF
				dragging = false
		elif mb.button_index == MOUSE_BUTTON_RIGHT and mb.pressed:
			_right_order(pw)
	elif event is InputEventMouseMotion:
		if drag_start != Vector2.INF and (event.position - drag_start).length() > 6.0:
			dragging = true
	elif event is InputEventKey and event.pressed and not event.echo:
		_handle_key(event as InputEventKey)

func _right_order(pw: Vector2) -> void:
	if patrol_mode:
		_finish_patrol(Vector2.INF)
		return
	if guard_mode:
		guard_mode = false
		if hud != null:
			hud.show_hint("")
		return
	if hud.build_ghost_sid != "":
		hud.build_ghost_sid = ""
		return
	if attack_ground_mode:
		attack_ground_mode = false
		for e in get_selected():
			if e.player == 0 and e.def.get("artillery", false):
				game.cmd_attack_ground(e, pw)
		return
	if rally_mode:
		rally_mode = false
		for e in get_selected():
			if e.player == 0 and e.kind == "building" and e.def.get("trains", []).size() > 0:
				game.set_rally(e, pw)
				hud.show_hint("Rally set")
		return
	var sel_units := get_selected().filter(func(e): return e.player == 0 and e.kind == "unit")
	# Production buildings selected on their own: right-click sets the rally
	# point, like the original (no need to press R first).
	var sel_blds := get_selected().filter(func(e): return e.player == 0 and e.kind == "building" and e.def.get("trains", []).size() > 0)
	# Damaged friendly building selected + only peasants in the unit
	# selection: right-click repairs it instead of rallying.
	var sel_dmg := get_selected().filter(func(e): return e.player == 0 and e.kind == "building" and e.finished and not e.dead and e.hp < e.max_hp)
	if not sel_dmg.is_empty() and not sel_units.is_empty():
		var all_peas := true
		for u in sel_units:
			if u.sid != "peasant":
				all_peas = false
				break
		if all_peas:
			for u in sel_units:
				game.cmd_repair(u, sel_dmg[0])
			return
	if sel_units.is_empty():
		if not sel_blds.is_empty():
			for b in sel_blds:
				game.set_rally(b, pw)
			hud.show_hint("Rally set")
		return
	var sel := sel_units
	var target := _pick(pw, false)
	# Resource spots are not entities, so look them up directly: right-clicking
	# a tree/rock/field/deposit with peasants selected orders harvesting.
	var res := _pick_res(pw) if target.is_empty() or (target.player == 0 and target.kind == "unit") else {}
	# group orders use the squad formation when the officer leads, else a box
	var form := _sel_formation(sel)
	var formation: Array = game.formation_targets(sel, pw, form) if target.is_empty() else []
	var fi := 0
	for e in sel:
		if not res.is_empty() and e.sid == "peasant" and not attack_move_mode:
			if int(res.get("hits", 1)) <= 0 and str(res.get("type", "")) == "food":
				game.cmd_resow(e, res)
			else:
				game.cmd_gather(e, res)
		elif target.is_empty():
			var dest: Vector2 = formation[fi] if fi < formation.size() else pw
			fi += 1
			if game.has_weapon(e) and e.sid != "peasant" and attack_move_mode:
				game.cmd_attack_move(e, dest)
			else:
				game.cmd_move(e, dest)
		elif target.player != 0:
			game.cmd_attack(e, target)
		elif target.kind == "building":
			if target.finished and str(target.sid) in ["tow", "cen"] and e.kind == "unit" and not e.def.get("artillery", false) and e.def.get("cavalry", "") == "":
				game.cmd_enter(e, target)
				continue
			if target.sid.begins_with("mine_") and e.sid == "peasant" and target.finished:
				var nd := _deposit_near(target)
				if not nd.is_empty():
					game.cmd_gather(e, nd)
				else:
					game.cmd_move(e, target.pos)
			elif not target.finished and e.sid == "peasant":
				game.cmd_build(e, target)
			else:
				game.cmd_move(e, target.pos)
		elif target.kind == "res":
			if e.sid == "peasant":
				game.cmd_gather(e, target)
			else:
				game.cmd_move(e, target.pos)
	attack_move_mode = false

func _deposit_near(mine: Dictionary) -> Dictionary:
	for n in game.res_nodes:
		if n.type == mine.def.get("mine", "") and n.max_hits == 0 and n.pos.distance_to(mine.pos) < 4.0:
			return n
	return {}

# Resource spots (trees, rocks, fields, mine deposits) live outside the entity
# list, so right-click harvest needs its own lookup. Deposits (max_hits == 0)
# count too: cmd_gather routes them to a finished mine on the spot.
func _pick_res(pw: Vector2) -> Dictionary:
	var best: Dictionary = {}
	var best_d := 2.5
	for n in game.res_nodes:
		if str(n.get("type", "")) in ["stump", "bush"]:
			continue
		if n.max_hits > 0 and n.hits <= 0 and n.type != "food":
			continue
		var d: float = n.pos.distance_to(pw)
		var reach: float = 2.5 + n.radius
		if d < reach and d < best_d:
			best_d = d
			best = n
	return best

# Box/line/column/square layout around a point, via the game (squad-aware).
func _sel_formation(sel: Array) -> String:
	for e in sel:
		var s: Dictionary = game.squad_of_unit(e.id)
		if not s.is_empty():
			return str(s.get("formation", "line"))
	return "none"

# Box formation around a point: rows x cols grid, step 1.2 m (FORMATION_SPACING),
# centered on the click. Single unit keeps the exact click point.
func _formation_targets(sel: Array, center: Vector2) -> Array:
	return game.formation_targets(sel, center, _sel_formation(sel))

# --- P-33: donor hotkeys.cfg parity ----------------------------------------
# PORT-SIM owns config.gd/config.json, so the donor-only combos below cannot be
# added to Data.HOTKEYS here. If a matching action is added there later it
# wins; otherwise the literal donor binding from hotkeys.cfg is used.
func _donor_combo(k: InputEventKey, action: String, fallbacks: Array) -> bool:
	if hotkeys.has(action) and _matches(k, hotkeys[action]):
		return true
	for spec in fallbacks:
		if _matches(k, ConfigScript.parse_hotkey(str(spec))):
			return true
	return false

func _select_military() -> void:
	var arr: Array = []
	for u in game.units_of(0):
		if u.sid != "peasant":
			arr.append(u)
	_set_selection(arr)
	if hud != null:
		hud._on_message("Selected %d military units" % arr.size())

func _select_ships() -> void:
	var arr: Array = []
	for u in game.units_of(0):
		if u.def.get("ship", false) or str(u.sid).contains("ship") or str(u.sid) in ["yacht", "galley", "cog", "frigate"]:
			arr.append(u)
	_set_selection(arr)
	if hud != null:
		hud._on_message("Selected %d ships" % arr.size() if not arr.is_empty() else "No naval units in this skirmish")

func _all_same_type(add: bool) -> void:
	var cur: Array = get_selected() if add else []
	if cur.is_empty():
		if hud != null:
			hud.show_hint("Select a unit first")
		return
	var sid: String = str(cur[0].sid)
	for u in game.units_of(0):
		if u.sid == sid and not cur.has(u):
			cur.append(u)
	_set_selection(cur)
	if hud != null:
		hud._on_message("Selected %d %s" % [cur.size(), sid])

func _handle_key(k: InputEventKey) -> void:
	if k.keycode >= KEY_1 and k.keycode <= KEY_9:
		var gi: int = k.keycode - KEY_1 + 1
		if k.ctrl_pressed:
			var ids: Array = []
			for e in get_selected():
				ids.append(e.id)
			groups[gi] = ids
			hud.show_hint("Group %d stored (%d)" % [gi, ids.size()])
		else:
			var arr: Array = []
			for id in groups.get(gi, []):
				var e: Dictionary = game.by_id.get(id, {})
				if not e.is_empty() and not e.dead:
					arr.append(e)
			if not arr.is_empty():
				_set_selection(arr)
				if k.shift_pressed and camera != null:
					camera.global_position = arr[0].pos * world.view_scale
		return
	# Donor select family (hotkeys.cfg): Ctrl+Alt+A / Ctrl+Shift+A military,
	# Ctrl+Q ships, Ctrl+Z / Ctrl+Shift+Z all-of-same-type, backtick idle
	# peasants. None of these actions exists in Data.HOTKEYS yet (P-33).
	if _donor_combo(k, "select_military_units", ["Ctrl+Alt+A", "Ctrl+Shift+A"]):
		_select_military()
		return
	if _donor_combo(k, "select_all_ships", ["Ctrl+Q"]):
		_select_ships()
		return
	if _donor_combo(k, "select_all_same_type", ["Ctrl+Z"]):
		_all_same_type(false)
		return
	if _donor_combo(k, "add_all_same_type", ["Ctrl+Shift+Z"]):
		_all_same_type(true)
		return
	# Godot 4.7 names the backtick key KEY_QUOTELEFT (96); donor alternative
	# for select|idlepeasants. Ctrl+` (all peasants) is handled below.
	if k.keycode == KEY_QUOTELEFT and not k.ctrl_pressed and not k.shift_pressed and not k.alt_pressed:
		var idle: Array = []
		for iu in game.units_of(0):
			if iu.sid == "peasant" and iu.order.type == "none" and iu.inside_of == 0:
				idle.append(iu)
		_set_selection(idle)
		if hud != null:
			hud._on_message("Selected %d idle peasants" % idle.size())
		return
	if k.keycode == KEY_F5:
		var m = get_tree().get_first_node_in_group("c3_main")
		if m != null:
			m.game_save()
		return
	if k.keycode == KEY_F9:
		var m2 = get_tree().get_first_node_in_group("c3_main")
		if m2 != null:
			m2.game_load()
		return
	# P starts a two-click patrol route (Q stays the instant +/-6 m patrol).
	# Neither config.gd nor config.json binds P today, so there is no clash.
	if k.keycode == KEY_P and not k.ctrl_pressed and not k.shift_pressed and not k.alt_pressed:
		begin_patrol_waypoints()
		return
	if k.keycode == KEY_ESCAPE:
		if patrol_mode:
			_finish_patrol(Vector2.INF)
			return
		if guard_mode:
			guard_mode = false
			if hud != null:
				hud.show_hint("")
			return
		if hud.build_ghost_sid != "" or hud.build_menu_open:
			hud.build_ghost_sid = ""
			hud.build_menu_open = false
			hud.refresh_selection(get_selected())
		else:
			var m3 = get_tree().get_first_node_in_group("c3_main")
			if m3 != null:
				m3.toggle_menu_overlay()
		return
	if k.keycode == KEY_DELETE:
		var wiped := false
		for e in get_selected():
			if e.player == 0 and not e.dead:
				game.cmd_delete(e)
				wiped = true
		if wiped:
			hud.refresh_selection(get_selected())
		return
	if _is(k, "pause"):
		game.paused = not game.paused
		return
	if _is(k, "hold_fire"):
		for e in get_selected():
			if e.player == 0:
				game.cmd_hold_fire(e, true)
		return
	if _is(k, "feuer_frei"):
		for e in get_selected():
			if e.player == 0:
				game.cmd_hold_fire(e, false)
		return
	if _is(k, "engage"):
		for e in get_selected():
			if e.player == 0:
				game.cmd_engage(e)
		return
	# the build menu comes first: the original shows it when a peasant is
	# picked, and the building keys are the same letters as the unit orders
	if hud.build_menu_open:
		for sid in build_keys:
			if _matches(k, build_keys[sid]):
				# "mine" is a single button; the deposit under the cursor
				# picks gold / iron / coal automatically when placing it.
				hud.build_ghost_sid = sid
				return
	# unit orders
	if _is(k, "attack_move"):
		attack_move_mode = true
	elif _is(k, "squad_form"):
		if k.shift_pressed:
			for e in get_selected():
				var sq: Dictionary = game.squad_of_unit(e.id)
				if not sq.is_empty():
					game.squad_disband(int(sq.squad_id))
					break
			hud.refresh_selection(get_selected())
		else:
			# F on an officer who already leads a squad tops it up first
			var topped := false
			for e in get_selected():
				var sq0: Dictionary = game.squad_of_unit(e.id)
				if e.player == 0 and not sq0.is_empty() and int(sq0.officer) == e.id:
					if game.cmd_replenish(e) > 0:
						topped = true
						break
			if not topped:
				game.squad_form(get_selected())
			hud.refresh_selection(get_selected())
	elif _is(k, "squad_disband"):
		for e in get_selected():
			var sq2: Dictionary = game.squad_of_unit(e.id)
			if not sq2.is_empty():
				game.squad_disband(int(sq2.squad_id))
				break
		hud.refresh_selection(get_selected())
	elif _is(k, "squad_line") or _is(k, "squad_column") or _is(k, "squad_square"):
		var form := "line" if _is(k, "squad_line") else ("column" if _is(k, "squad_column") else "square")
		for e in get_selected():
			var sq3: Dictionary = game.squad_of_unit(e.id)
			if not sq3.is_empty():
				game.squad_set_formation(int(sq3.squad_id), form)
				break
		hud.refresh_selection(get_selected())
	elif _is(k, "attack_ground"):
		var has_arty := false
		for e in get_selected():
			if e.player == 0 and e.def.get("artillery", false):
				has_arty = true
		if has_arty:
			attack_ground_mode = true
			hud.show_hint("Bombard: right-click the ground (artillery only)")
		else:
			rally_mode = true
			hud.show_hint("Rally: right-click the map to set the gather point")
	elif _is(k, "unload"):
		for e in get_selected():
			if e.player == 0 and e.kind == "building":
				game.cmd_unload(e)
	elif _is(k, "sow_fields"):
		# P-51: same "Grain Crops" order as the mill button; right-click resow
		# of depleted fields is unchanged (cmd_resow).
		for e in get_selected():
			if e.player == 0 and e.kind == "building" and e.sid == "mil" and e.finished:
				var n: int = game.cmd_sow(e)
				hud.show_hint("Sowed %d grain fields" % n if n > 0 else "No room or gold to sow fields")
				break
	elif _is(k, "select_all_peasants"):
		var arrp: Array = []
		for e in game.units_of(0):
			if e.sid == "peasant":
				arrp.append(e)
		_set_selection(arrp)
	elif _is(k, "select_idle_mines"):
		var arrm: Array = []
		for b in game.buildings_of(0):
			if b.sid.begins_with("mine_") and b.finished and int(b.workers) < int(b.get("slots", b.def.get("slots", 5))):
				arrm.append(b)
		_set_selection(arrm)
	elif _is(k, "add_same_type"):
		var sel2 := get_selected()
		if not sel2.is_empty():
			var sid2: String = sel2[0].sid
			var cur2 := sel2.duplicate()
			for e in game.units_of(0):
				if e.sid == sid2 and not cur2.has(e):
					cur2.append(e)
			_set_selection(cur2)
	elif _is(k, "minimap_toggle"):
		if hud != null and hud.minimap_rect != null:
			hud.minimap_rect.get_parent().visible = not hud.minimap_rect.get_parent().visible
	elif _is(k, "patrol"):
		# Q is the donor-style instant patrol; P asks for player waypoints.
		for e in get_selected():
			if e.player == 0 and e.kind == "unit":
				game.cmd_patrol(e, e.pos + Vector2(-6, 0), e.pos + Vector2(6, 0))
	elif _is(k, "stand_ground"):
		for e in get_selected():
			game.cmd_stand_ground(e)
	elif _is(k, "no_stand_ground"):
		for e in get_selected():
			game.cmd_no_stand_ground(e)
	elif _is(k, "guard"):
		begin_guard()
	elif _is(k, "stop"):
		for e in get_selected():
			game.cmd_stop(e)
	elif _is(k, "select_all"):
		var arr: Array = []
		for e in game.units_of(0):
			arr.append(e)
		_set_selection(arr)
	elif _is(k, "select_idle_peasants"):
		var arr: Array = []
		for e in game.units_of(0):
			if e.sid == "peasant" and e.order.type == "none" and e.inside_of == 0:
				arr.append(e)
		_set_selection(arr)
	elif _is(k, "select_all_buildings"):
		var arr: Array = []
		for e in game.buildings_of(0):
			arr.append(e)
		_set_selection(arr)
	elif _is(k, "select_same_type"):
		var sel := get_selected()
		if not sel.is_empty():
			var sid: String = sel[0].sid
			var arr: Array = []
			for e in game.units_of(0):
				if e.sid == sid:
					arr.append(e)
			_set_selection(arr)

func _process(_dt: float) -> void:
	# the Rally button hands over to keyboard mode: next right-click sets it
	if hud != null and hud.want_rally:
		hud.want_rally = false
		rally_mode = true
		hud.show_hint("Rally: right-click the map to set the gather point")
	# drag rectangle overlay (drawn by the world in map space)
	if world != null:
		if dragging and drag_start != Vector2.INF:
			var a := _screen_to_world(drag_start)
			var bp := _screen_to_world(get_viewport().get_mouse_position())
			world.sel_rect = Rect2(minf(a.x, bp.x), minf(a.y, bp.y), absf(a.x - bp.x), absf(a.y - bp.y))
			world.sel_active = true
		else:
			world.sel_active = false
	if patrol_mode and patrol_a != Vector2.INF and route_node != null:
		route_node.queue_redraw()
	# build ghost hint uses the message line, not the units/score label
	if hud != null and hud.build_ghost_sid != "" and hud.has_method("show_hint"):
		hud.show_hint("Placing %s - left-click to build, right-click to cancel" % hud.build_ghost_sid)
	elif hud != null and patrol_mode and hud.has_method("show_hint"):
		hud.show_hint("Patrol: click the first waypoint" if patrol_a == Vector2.INF else "Patrol: click the second waypoint")
	elif hud != null and guard_mode and hud.has_method("show_hint"):
		# keep the guard prompt set by begin_guard()
		pass
	elif hud != null and hud.has_method("show_hint"):
		hud.show_hint("")
	_update_cursor()

func _set_cursor(name: String) -> void:
	if name == cursor_now:
		return
	cursor_now = name
	var t: Texture2D = cursor_tex.get(name, cursor_tex.get("default", null))
	if t == null:
		return
	# donor cursors are 32x32 with the hot spot at top-left tip (8,4)
	Input.set_custom_mouse_cursor(t, Input.CURSOR_ARROW, Vector2(8, 4))

func _update_cursor() -> void:
	if game == null or world == null:
		return
	if hud != null and hud.build_ghost_sid != "":
		_set_cursor("construct")
		return
	if attack_move_mode:
		_set_cursor("attack")
		return
	if attack_ground_mode:
		_set_cursor("artillery")
		return
	if rally_mode:
		_set_cursor("gotomine")
		return
	var pw := _screen_to_world(get_viewport().get_mouse_position())
	var sel := get_selected()
	var peas := false
	var military := false
	for e in sel:
		if e.player != 0 or e.kind != "unit":
			continue
		if e.sid == "peasant":
			peas = true
		else:
			military = true
	var tgt := _pick(pw, false)
	if not tgt.is_empty():
		if tgt.player != 0 and tgt.kind == "building" and military:
			_set_cursor("captureattack" if bool(Data.CAPTURE_ENABLED) else "attack")
			return
		if tgt.player != 0:
			_set_cursor("attack")
			return
		if peas and tgt.kind == "building" and (not tgt.finished or tgt.hp < tgt.max_hp):
			_set_cursor("construct")
			return
		if peas and tgt.kind == "building" and tgt.sid.begins_with("mine_") and tgt.finished:
			_set_cursor("gotomine")
			return
		if military and tgt.kind == "building" and tgt.finished and (tgt.sid == "tow" or tgt.sid == "cen"):
			_set_cursor("gotomine")
			return
	if peas:
		var r := _pick_res(pw)
		if not r.is_empty():
			match str(r.type):
				"food":
					_set_cursor("gainfood")
					return
				"wood":
					_set_cursor("gainwood")
					return
				"stone":
					_set_cursor("gainstone")
					return
				"gold", "iron", "coal":
					_set_cursor("gotomine")
					return
	_set_cursor("default")
