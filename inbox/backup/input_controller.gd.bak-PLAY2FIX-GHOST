# Mouse + keyboard control: selection, orders, build placement, hotkeys.
# Bindings follow the original data/game/var/hotkeys.cfg.
extends Node
class_name C3Input

const Data = preload("res://scripts/data.gd")
const ConfigScript = preload("res://scripts/config.gd")

var game: C3Game
# V7-52: world/camera are untyped so 3D mode can receive the Node3D world and
# Camera3D that main.gd (V7-50) builds. 2D mode still binds C3World/C3Camera and
# runs byte-identically; only the static annotations are relaxed, no symbols change.
var world = null
var hud: C3HUD
var camera = null
# V7-52 integration seam (V73_ATOMIC_CONTRACT.md:22). "2d" (DEFAULT) keeps the
# original internals; "3d" routes ONLY _screen_to_world/_pick/_pick_res through
# picking3d.gd. All game.cmd_* calls, hotkeys, control groups, build ghost and
# order semantics are untouched. main.gd (V7-50) calls bind_3d(cam) after bind()
# when gameplay.render_mode == "3d"; this file does NOT edit main.gd.
var render_mode: String = "2d"
var picking = null            # picking3d instance, created by bind_3d() only
# Raw screen pixel that produced the latest _screen_to_world() result. picking3d
# takes SCREEN pixels (not sim metres), yet every inherited call site feeds the
# returned world point `pw` to _pick/_pick_res. Recording the source pixel here
# lets those internals switch adapters without editing a single call site.
var _pick_screen: Vector2 = Vector2.INF
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
# T-PERF-RENDER: hover-scan throttle state for _update_cursor().
var _cursor_mouse := Vector2.INF
var _cursor_t_ms := -100000
var _cursor_sel_n := -1
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
# FIX-SEL: 3D patrol/guard route overlay. A Node2D child of world3d.gd's Node3D
# fx_layer (world3d.gd:119,604-606) never renders; the 3D branch draws an
# ImmediateMesh in centred world metres instead. The 2D route_node path below
# stays byte-identical.
var route_mesh_node: MeshInstance3D = null
# T-NAV-RESPONSIVE: minimap geometry is cached. It only changes when the
# viewport resizes or hud.gd resizes/rebuilds its TextureRect — never on mouse
# events — so the per-event path does no Control/layout math or allocations.
var _mm_rect := Rect2()
var _mm_rect_dirty := true
var _mm_dragging := false
# W3-2: hold a refusal/confirmation hint for a couple of seconds instead of
# letting the next _process frame overwrite it with "" (or the ghost prompt).
var _hint_hold_ms := 0
# W4-2: wheel-delta accumulator. Input translation only (no tween/easing):
# coalesce fractional high-resolution wheel deltas into whole notch requests.
var _wheel_accum := 0.0

func bind(g: C3Game, w, h: C3HUD, cam) -> void:
	game = g
	world = w
	hud = h
	camera = cam
	_read_hotkeys()
	for cn in ["default", "attack", "captureattack", "artillery", "patrol", "construct", "gainfood", "gainwood", "gainstone", "gotomine", "wait"]:
		var p := "res://assets/ui/cursor_%s.bmp" % cn
		if FileAccess.file_exists(p):
			cursor_tex[cn] = load(p)
	# X1 rank 5: donor rally mode uses the crSetRallyPoint cursor. No donor art
	# is copied; tint the existing gotomine/construct cursor cyan-green instead.
	var rbase: Texture2D = cursor_tex.get("gotomine", cursor_tex.get("construct", null))
	# Imported BMPs are CompressedTexture2D, not ImageTexture; Texture2D.get_image()
	# works for both (and is null on an uninitialised placeholder).
	if rbase != null:
		var src: Image = rbase.get_image()
		if src != null and src.get_width() > 0:
			var tinted: Image = src.duplicate()
			for ty in tinted.get_height():
				for tx in tinted.get_width():
					var c: Color = tinted.get_pixel(tx, ty)
					tinted.set_pixel(tx, ty, Color(c.r * 0.35, minf(1.0, c.g * 1.15), minf(1.0, c.b * 1.25 + 0.15), c.a))
			cursor_tex["rally"] = ImageTexture.create_from_image(tinted)
	_set_cursor("default")
	# Draw the patrol route on the existing fx layer; a child node keeps this
	# feature entirely inside input_controller.gd (world.gd is not owned here).
	# FIX-SEL: the 3D world is a Node3D, so use a mesh overlay there; the 2D
	# branch is unchanged (same Node2D + draw signal as before).
	_ensure_route_overlay()
	add_to_group("c3_input")
	# T-NAV-RESPONSIVE: invalidate the cached minimap rect only on real layout
	# changes, not on every mouse-motion event.
	if get_viewport() != null:
		get_viewport().size_changed.connect(_invalidate_minimap_rect)
	if hud != null and hud.minimap_rect != null and is_instance_valid(hud.minimap_rect):
		hud.minimap_rect.resized.connect(_invalidate_minimap_rect)

# V7-52 PUBLIC HANDOFF for main.gd (V7-50). Call AFTER bind(game, world, hud, cam).
# `cam` is the Camera3D returned by make_camera3d(); the 3D world is the Node3D
# already passed as `world`. This method ONLY wires the picking adapter and flips
# render_mode — it does not touch any cmd_*, hotkey, group or build-ghost code.
# Loading is dynamic (no class_name), per V712 report §5.
func bind_3d(cam) -> void:
	var PickingScript = load("res://scripts/picking3d.gd")
	if PickingScript == null:
		push_error("V7-52: res://scripts/picking3d.gd missing; keeping 2D internals")
		return
	if picking == null:
		picking = PickingScript.new()
		add_child(picking)
	# Keep the shared `camera` handle on the 3D cam so zoom/minimap/group code
	# keeps working (those call sites are unchanged).
	camera = cam
	picking.bind(game, cam)
	render_mode = "3d"

# FIX-SEL: attach the route overlay to the world's FX layer. 2D (Node2D world)
# keeps the original Node2D + draw-signal path byte-for-byte; 3D (Node3D world)
# gets a MeshInstance3D/ImmediateMesh because a Node2D child of a Node3D tree
# never renders. Called from bind(); also callable by tests directly.
func _ensure_route_overlay() -> void:
	if world == null or world.fx_layer == null:
		return
	if world is Node3D and world.fx_layer is Node3D:
		if route_mesh_node == null or not is_instance_valid(route_mesh_node):
			route_mesh_node = MeshInstance3D.new()
			route_mesh_node.name = "PatrolRoute3D"
			var mat := StandardMaterial3D.new()
			mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			mat.albedo_color = Color(1.0, 0.86, 0.30, 0.95)
			route_mesh_node.material_override = mat
			world.fx_layer.add_child(route_mesh_node)
	elif route_node == null:
		route_node = Node2D.new()
		route_node.z_index = 5
		world.fx_layer.add_child(route_node)
		route_node.draw.connect(_draw_patrol_route)

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

# W3-2: show a HUD hint and stop the idle _process pass from erasing it on the
# very next frame, so "Need 40 stone" / refund notes are actually readable.
func _hint(text: String, hold_s := 2.5) -> void:
	if hud != null and hud.has_method("show_hint"):
		hud.show_hint(text)
		_hint_hold_ms = Time.get_ticks_msec() + int(hold_s * 1000.0)

func _price_hint(cost: Dictionary) -> String:
	var parts: Array = []
	for k in Data.RES_NAMES:
		var rk := str(k)
		if int(cost.get(rk, 0)) > 0:
			parts.append("%d %s" % [int(cost[rk]), rk])
	return ", ".join(parts)

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

# --- T-NAV-RESPONSIVE: minimap navigation ------------------------------------
func _invalidate_minimap_rect() -> void:
	_mm_rect_dirty = true

# Cached screen-space rect of the minimap texture. hud.gd owns the live node;
# we only read its global rect when a resize signal says it changed.
func _minimap_screen_rect() -> Rect2:
	if _mm_rect_dirty:
		_mm_rect_dirty = false
		_mm_rect = Rect2()
		if hud != null and hud.minimap_rect != null and is_instance_valid(hud.minimap_rect) \
				and hud.minimap_rect.is_visible_in_tree():
			_mm_rect = hud.minimap_rect.get_global_rect()
	return _mm_rect

# Screen point -> map metres, using the same rect math as hud.gd. UVs are
# clamped so a drag that slips off the minimap cannot keep pulling the camera.
func _minimap_world(screen_pos: Vector2) -> Vector2:
	var mm := _minimap_screen_rect()
	if mm.size.x <= 0.0 or mm.size.y <= 0.0 or game == null:
		return Vector2.INF
	var u := clampf((screen_pos.x - mm.position.x) / mm.size.x, 0.0, 1.0)
	var v := clampf((screen_pos.y - mm.position.y) / mm.size.y, 0.0, 1.0)
	return Vector2(u * game.MAP_W, v * game.MAP_H) * Data.TILE_M

# Instant click/drag reposition: one direct camera write + explicit dirty
# hop, then camera.process_priority puts the move in front of world.sync() on
# this very frame (no sim tick / MINIMAP_INTERVAL wait).
func _minimap_reposition(screen_pos: Vector2) -> void:
	var wp := _minimap_world(screen_pos)
	if wp == Vector2.INF or camera == null or world == null:
		return
	# V7-66 P0: the 3D camera exposes a metre-space jump_to_world (camera3d.gd); call it
	# dynamically so the 2D Camera2D path below stays byte-identical and is still the
	# default (render_mode defaults to "2d" at :21). The old fallback wrote a Vector2
	# into Camera3D.global_position and scaled metres by 16 px/m, bypassing _target and
	# the clamp memo — a 3D no-op that snaps back on the next _apply_transform().
	if render_mode == "3d":
		camera.call("jump_to_world", wp)
		return
	if camera.has_method("jump_to_world"):
		camera.jump_to_world(wp, world.view_scale)
	else:
		camera.global_position = wp * world.view_scale
		camera.clamp_pos()
		if camera.has_method("mark_dirty"):
			camera.mark_dirty()

func minimap_order(pos: Vector2) -> void:
	var sel := get_selected().filter(func(e): return e.player == 0 and e.kind == "unit")
	if sel.is_empty():
		return
	var any_enemy := false
	for e in game.entities:
		if not e.dead and e.player != 0 and e.pos.distance_to(pos) < 6.0:
			any_enemy = true
			break  # T-PERF-RENDER: one enemy is enough to pick attack-move
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
		"select_idle_peasants":
			select_idle_peasants()
		"select_idle_mines":
			select_idle_mines()

# HUD top-bar buttons (donor eventresourcepanel.inc:35-36) reuse the same
# select handlers as the idle-peasant / idle-mine hotkeys below.
func select_idle_peasants() -> void:
	var arr: Array = []
	for e in game.units_of(0):
		if e.sid == "peasant" and e.order.type == "none" and e.inside_of == 0:
			arr.append(e)
	_set_selection(arr)

func select_idle_mines() -> void:
	var arrm: Array = []
	for b in game.buildings_of(0):
		if b.sid.begins_with("mine_") and b.finished and int(b.workers) < int(b.get("slots", b.def.get("slots", 5))):
			arrm.append(b)
	_set_selection(arrm)

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
	_route_redraw()
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
	_route_redraw()
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
	# V7-52: explicit type guards — `world` is untyped (V71:197 relaxed-typing
	# seam), so `:=` cannot infer these members; the values/behaviour are unchanged.
	var a: Vector2 = world.world_to_px(patrol_a)
	var end_world := patrol_b
	if end_world == Vector2.INF:
		end_world = _screen_to_world(get_viewport().get_mouse_position())
	var b: Vector2 = world.world_to_px(end_world)
	route_node.draw_line(a, b, Color(1.0, 0.86, 0.30, 0.95), 2.0)
	for p in [a, b]:
		route_node.draw_line(p, p + Vector2(0, -15), Color(0.96, 0.90, 0.70, 0.95), 1.5)
		route_node.draw_colored_polygon([p + Vector2(0, -15), p + Vector2(11, -12), p + Vector2(0, -9)],
			Color(1.0, 0.82, 0.22, 0.95))
		route_node.draw_circle(p, 3.0, Color(1, 1, 1, 0.85))

# FIX-SEL: 3D route redraw dispatch. 2D keeps its draw-signal path; 3D writes
# an ImmediateMesh in the centred world frame used by world3d.gd/camera3d.gd.
func _route_redraw() -> void:
	if route_node != null and is_instance_valid(route_node):
		route_node.queue_redraw()
	elif route_mesh_node != null and is_instance_valid(route_mesh_node):
		_draw_patrol_route3d()

func _route_world(p: Vector2) -> Vector3:
	# sim -> centred metres (world3d_entities.gd:783). Keep the marker just
	# above the sampled ground so it is not z-fighting with the terrain.
	var y := 0.18
	if game != null and game.has_method("height_at"):
		y += float(game.call("height_at", p))
	return Vector3(p.x - float(game.MAP_W) * Data.TILE_M * 0.5,
		y, p.y - float(game.MAP_H) * Data.TILE_M * 0.5)

func _draw_patrol_route3d() -> void:
	if route_mesh_node == null or not is_instance_valid(route_mesh_node) or game == null:
		return
	var im := route_mesh_node.mesh as ImmediateMesh
	if im == null:
		im = ImmediateMesh.new()
		route_mesh_node.mesh = im
	im.clear_surfaces()
	if patrol_a == Vector2.INF:
		return
	var end_world := patrol_b
	if end_world == Vector2.INF:
		end_world = _screen_to_world(get_viewport().get_mouse_position())
	if not is_finite(end_world.x) or not is_finite(end_world.y):
		return
	var a := _route_world(patrol_a)
	var b := _route_world(end_world)
	im.surface_begin(Mesh.PRIMITIVE_LINES)
	im.surface_add_vertex(a)
	im.surface_add_vertex(b)
	# End ticks + a small arrow head, matching the 2D route markers.
	for p in [a, b]:
		im.surface_add_vertex(p)
		im.surface_add_vertex(p + Vector3(0.0, 2.0, 0.0))
	var back: Vector3 = a - b
	if back.length() > 0.001:
		back = back.normalized()
		var side := Vector3(-back.z, 0.0, back.x)
		im.surface_add_vertex(b)
		im.surface_add_vertex(b + back * 3.0 + side * 1.5)
		im.surface_add_vertex(b)
		im.surface_add_vertex(b + back * 3.0 - side * 1.5)
	im.surface_end()

func _screen_to_world(p: Vector2) -> Vector2:
	# V7-52 3D seam: ground unprojection moves to picking3d.ground_point(screen),
	# which ray-marches the height field and returns the SAME sim-metre `pw` the
	# 2D inverse below produced. Record the source pixel so _pick/_pick_res (which
	# call sites feed `pw`, not the screen point) can use the adapter unchanged.
	if render_mode == "3d" and picking != null:
		_pick_screen = p
		return picking.ground_point(p)
	# Screen pixels -> map meters through the camera (position + zoom),
	# otherwise clicks only line up near the map origin.
	if world == null:
		return p / 16.0
	var xform := get_viewport().get_canvas_transform().affine_inverse()
	return (xform * p) / world.view_scale

func _pick(pw: Vector2, players_only := true) -> Dictionary:
	# V7-52 3D seam. picking3d.pick(screen, players_only) applies the SAME
	# radius/fallback rule as the 2D loop below (V7-68): `true` restricts the
	# radius test to player-0 entities, `false` lets every entity compete, and
	# the 2 m any-entity fallback is unconditional in both modes. Forward the
	# caller's flag verbatim so the guard site (:493 true) and the left-click,
	# right-order and cursor sites (:551/:645/:1156 false) keep 2D parity.
	if render_mode == "3d" and picking != null:
		if not is_finite(_pick_screen.x) or not is_finite(_pick_screen.y):
			return {}
		return picking.pick(_pick_screen, players_only)
	# T-PERF-RENDER: single pass. The old code scanned all entities twice on
	# every miss (the common case: clicking empty ground) — once for the
	# radius test, once for the 2 m fallback. Both best-candidates are tracked
	# in one loop with identical hit semantics.
	var best: Dictionary = {}
	var best_d := 1e9
	var fb: Dictionary = {}
	var fb_d := 1e9
	for e in game.entities:
		if e.dead:
			continue
		var d: float = e.pos.distance_to(pw)
		if not players_only or e.player == 0:
			var r: float = game.pick_radius(e)
			if d < r and d < best_d:
				best_d = d
				best = e
		if d < 2.0 and d < fb_d:
			fb_d = d
			fb = e
	# fall back: any entity close by (enemies selectable for info/attack)
	if best.is_empty():
		return fb
	return best

# W4-2: pure input translation — a wheel event becomes one or more camera
# zoom requests. No interpolation, easing, clamp or cursor math is computed
# here; camera.gd (W4-1) owns all of that. The accumulator only coalesces
# fractional high-resolution wheel deltas into whole notches, which removes
# one-notch jitter on trackpad-style wheels without changing normal wheels.
func _zoom_wheel(ev: InputEventMouseButton, sign: float) -> void:
	if camera == null:
		return
	var fv: Variant = ev.get("factor")
	var f: float = clampf(float(fv), 0.01, 8.0) if fv != null else 1.0
	_wheel_accum += f
	var notches: int = int(_wheel_accum)
	if notches > 0:
		_wheel_accum -= float(notches)
		if camera.has_method("zoom_step"):
			# W4-1 authoritative API: camera owns step size, smoothing and
			# the clamp. Dynamic call: camera.gd has a float `zoom_step`
			# member, so a literal call would not compile. Pass the wheel
			# event position as the zoom-to-cursor anchor.
			camera.call("zoom_step", sign * float(notches), ev.position)
	get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		# W4-2: wheel translation lives here; set_input_as_handled() makes this
		# and camera.gd's legacy wheel branch mutually exclusive, so one notch
		# can never zoom twice regardless of scene-tree order.
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP or mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_wheel(mb, 1.0 if mb.button_index == MOUSE_BUTTON_WHEEL_UP else -1.0)
			return
		var mm := _minimap_screen_rect()
		# T-NAV-RESPONSIVE: hud.gd's gui_input normally consumes minimap button
		# presses first. These branches are the same-path fallback so minimap
		# click = instant jump, left drag = continuous follow and right click =
		# order, all confined to the cached rect. _screen_to_world() is now
		# lazy: it is only paid for world-map events, not minimap events.
		if mb.button_index == MOUSE_BUTTON_LEFT and mm.has_point(mb.position):
			_mm_dragging = mb.pressed
			_minimap_reposition(mb.position)
			return
		if mb.button_index == MOUSE_BUTTON_RIGHT and mb.pressed and mm.has_point(mb.position):
			var mw := _minimap_world(mb.position)
			if mw != Vector2.INF:
				minimap_order(mw)
			return
		if mb.button_index == MOUSE_BUTTON_LEFT and not mb.pressed and _mm_dragging:
			_mm_dragging = false
			return
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
					_route_redraw()
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
					# W3-2 / X1 C2-C5: refuse the click BEFORE the sim call when no
					# peasant is selected or the escalated cost cannot be paid.
					# Donor onshortcut.inc:270-276 / unit.script:10164-10177.
					if sel_peasants.is_empty():
						_hint("Select at least one peasant to build (right-click cancels)")
						return
					if hud.has_method("build_gate"):
						var cg: Dictionary = hud.build_gate(hud.build_ghost_sid, pos)
						if not bool(cg.get("ok", false)):
							_hint(str(cg.get("reason", "Cannot build here.")))
							return
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
						# V7-52: explicit type guard for the untyped `world` seam (V71:197).
						var vp: Rect2 = world.view_rect
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
		var mm := _minimap_screen_rect()
		# T-NAV-RESPONSIVE: continuous minimap drag. While the left button is
		# held the camera follows the pointer every frame; the rect test also
		# ends an active drag when the pointer leaves the minimap, so it can
		# never leak into the world selection-drag logic below.
		if _mm_dragging or ((event.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0 and mm.has_point(event.position)):
			if mm.has_point(event.position):
				_minimap_reposition(event.position)
			else:
				_mm_dragging = false
			return
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
				_hint("Rally set (%.1f, %.1f)" % [pw.x, pw.y])
		if world != null:
			world.mark_rally_dirty()
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
			_hint("Rally set (%.1f, %.1f)" % [pw.x, pw.y])
			if world != null:
				world.mark_rally_dirty()
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

# T-PICK-RES: cached spatial hash over game.res_nodes. Right-click harvest used
# to scan all ~530 resource nodes per click; the hash touches only the cells a
# click's reach can span. Built lazily (first pick after a change) and invalidated
# on game.res_dirty / array-size change, so there is no per-frame work. Every
# node is inserted with NO filtering, which keeps the _pick_res filters and the
# strict nearest rule byte-for-byte identical to the old brute-force scan.
# (game's own _res_grid is private and skips depleted nodes, so it cannot be
# reused without changing behaviour — notably for depleted food nodes.)
const _PICK_RES_GRID_M := 16.0
var _pick_res_grid: Dictionary = {}       # Vector2i cell -> Array of res node dicts
var _pick_res_ver := -1                   # game.res_dirty value this grid was built at
var _pick_res_size := -1                  # res_nodes size at build time
var _pick_res_max_reach := 2.5            # widest 2.5 + radius over all nodes

func _pick_res_grid_ensure() -> void:
	if _pick_res_ver == game.res_dirty and _pick_res_size == game.res_nodes.size():
		return
	_pick_res_grid.clear()
	_pick_res_max_reach = 2.5
	for n in game.res_nodes:
		_pick_res_max_reach = maxf(_pick_res_max_reach, 2.5 + float(n.radius))
		var c := Vector2i(int(n.pos.x / _PICK_RES_GRID_M), int(n.pos.y / _PICK_RES_GRID_M))
		if not _pick_res_grid.has(c):
			_pick_res_grid[c] = []
		(_pick_res_grid[c] as Array).append(n)
	_pick_res_ver = game.res_dirty
	_pick_res_size = game.res_nodes.size()

# Resource spots (trees, rocks, fields, mine deposits) live outside the entity
# list, so right-click harvest needs its own lookup. Deposits (max_hits == 0)
# count too: cmd_gather routes them to a finished mine on the spot.
func _pick_res(pw: Vector2) -> Dictionary:
	# V7-52 3D seam. picking3d.pick_res(screen) preserves the donor port's exact
	# resource filters (skip stump/bush, skip depleted except food, 2.5 + radius,
	# strict '<', lowest id on tie) and adds camera-depth ordering for overlaps.
	if render_mode == "3d" and picking != null:
		if not is_finite(_pick_screen.x) or not is_finite(_pick_screen.y):
			return {}
		return picking.pick_res(_pick_screen)
	_pick_res_grid_ensure()
	var best: Dictionary = {}
	var best_d := 2.5
	var r := _pick_res_max_reach
	var c0 := Vector2i(int((pw.x - r) / _PICK_RES_GRID_M), int((pw.y - r) / _PICK_RES_GRID_M))
	var c1 := Vector2i(int((pw.x + r) / _PICK_RES_GRID_M), int((pw.y + r) / _PICK_RES_GRID_M))
	for cy in range(c0.y, c1.y + 1):
		for cx in range(c0.x, c1.x + 1):
			for n in (_pick_res_grid.get(Vector2i(cx, cy), []) as Array):
				if str(n.get("type", "")) in ["stump", "bush"]:
					continue
				if n.max_hits > 0 and n.hits <= 0 and n.type != "food":
					continue
				var d: float = n.pos.distance_to(pw)
				var reach: float = 2.5 + n.radius
				# Strict `<` as before. res_nodes is append-only (id grows with
				# index), so an exact-distance tie still resolves to the same
				# first node the old full-array order would have chosen.
				var closer: bool = d < reach and d < best_d
				var tie_first: bool = (d < reach and not best.is_empty() and d == best_d and int(n.id) < int(best.id))
				if closer or tie_first:
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
					# E18 (AUDIT3D-05): the Camera3D branch must not take the
					# 2D Camera2D write — `arr[0].pos * world.view_scale` is a
					# Vector2 assigned to a Vector3 global_position, and it
					# bypasses `_target`/clamp_pos() so the next
					# _apply_transform() snaps back. Route through the same
					# metre-space `jump_to_world` API as the minimap at :232.
					# The 2D line below is unchanged (byte-identical text).
					if render_mode == "3d" and camera.has_method("jump_to_world"):
						camera.call("jump_to_world", arr[0].pos)
					else:
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
			# X1 rank 10: the ghost was never paid for, so say so explicitly.
			_hint("Build cancelled - no resources spent")
		else:
			var m3 = get_tree().get_first_node_in_group("c3_main")
			if m3 != null:
				m3.toggle_menu_overlay()
		return
	if k.keycode == KEY_DELETE:
		var wiped := false
		var site_note := ""
		for e in get_selected():
			if e.player == 0 and not e.dead:
				# W3-1 owns the refund: cmd_delete() already calls
				# cancel_build_site() (game.gd:4222/4239). Only the hint is ours.
				if e.kind == "building" and not bool(e.get("finished", false)):
					var paid: Dictionary = e.get("paid_cost", {})
					site_note = "Site cancelled - %s refunded" % (_price_hint(paid) if not paid.is_empty() else "resources")
				game.cmd_delete(e)
				wiped = true
		if wiped:
			hud.refresh_selection(get_selected())
			if site_note != "":
				_hint(site_note + " (full before work, half once work starts)")
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
				# X1 C4 / donor onshortcut.inc:276: refuse before opening the
				# ghost, naming the missing resource instead of a silent no-op.
				var hk_gate: Dictionary = hud.build_gate(sid)
				if not bool(hk_gate.get("ok", false)):
					_hint(str(hk_gate.get("reason", "Cannot build.")))
					return
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
		select_idle_mines()
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
		select_idle_peasants()
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

# X1 rank 5: a selected trainer advertises the right-click rally gesture.
func _has_selected_trainer() -> bool:
	for e in get_selected():
		if e.player == 0 and e.kind == "building" and e.def.get("trains", []).size() > 0:
			return true
	return false

func _process(_dt: float) -> void:
	# the Rally button hands over to keyboard mode: next right-click sets it
	if hud != null and hud.want_rally:
		hud.want_rally = false
		rally_mode = true
		_hint("Rally: right-click the map to set the gather point")
	# drag rectangle overlay (drawn by the world in map space)
	if world != null:
		if dragging and drag_start != Vector2.INF:
			var a := _screen_to_world(drag_start)
			var bp := _screen_to_world(get_viewport().get_mouse_position())
			world.sel_rect = Rect2(minf(a.x, bp.x), minf(a.y, bp.y), absf(a.x - bp.x), absf(a.y - bp.y))
			world.sel_active = true
		else:
			world.sel_active = false
	if patrol_mode and patrol_a != Vector2.INF:
		_route_redraw()
	# build ghost hint uses the message line, not the units/score label.
	# A held refusal/confirmation hint wins over the idle modes for a moment.
	if Time.get_ticks_msec() >= _hint_hold_ms:
		if hud != null and hud.build_ghost_sid != "" and hud.has_method("show_hint"):
			hud.show_hint("Placing %s - left-click to build, right-click to cancel" % hud.build_ghost_sid)
		elif hud != null and patrol_mode and hud.has_method("show_hint"):
			hud.show_hint("Patrol: click the first waypoint" if patrol_a == Vector2.INF else "Patrol: click the second waypoint")
		elif hud != null and guard_mode and hud.has_method("show_hint"):
			# keep the guard prompt set by begin_guard()
			pass
		elif hud != null and hud.has_method("show_hint") and _has_selected_trainer():
			hud.show_hint("Rally: right-click the map to set the gather point [R]")
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
		# W3-2: cyan-tinted donor-style rally cursor, generated in bind().
		_set_cursor("rally" if cursor_tex.has("rally") else "gotomine")
		return
	# T-PERF-RENDER: the hover scan below walks every entity plus every res
	# node. Throttle it: recompute on mouse moves (>3 px), selection-size
	# changes, or age (>80 ms bounds staleness when units walk under a still
	# cursor). Mode switches above stay instant (<100 ms click feedback).
	var mp := get_viewport().get_mouse_position()
	var now_ms := Time.get_ticks_msec()
	var sel_key := selected_ids.size()
	if mp.distance_to(_cursor_mouse) < 3.0 and now_ms - _cursor_t_ms < 80 \
			and sel_key == _cursor_sel_n:
		return
	_cursor_mouse = mp
	_cursor_t_ms = now_ms
	_cursor_sel_n = sel_key
	var pw := _screen_to_world(mp)
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
