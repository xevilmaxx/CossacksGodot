# Test-only remote control bridge (localhost TCP, line-delimited JSON).
# Enabled ONLY with --test-api <port>. Never active in normal runs.
# Lets an external driver exercise the REAL rendered UI end to end:
# click actual GUI controls, press keys, list clickable widgets with their
# screen rects, resize the window, capture screenshots and read basic state.
# Everything is non-blocking (bounded polls per frame) so it can never hang
# the game; --timeout still force-quits as usual.
extends Node
class_name C3TestBridge

var server := TCPServer.new()
var peer: StreamPeerTCP = null
var buf := ""
var pending_shot := ""
var wait_left := 0

func _init(port := 8123) -> void:
	var err := server.listen(port, "127.0.0.1")
	if err != OK:
		printerr("test-api: listen failed on port ", port, " err ", err)
	else:
		print("test-api: listening on 127.0.0.1:", port)

func poll() -> void:
	if wait_left > 0:
		wait_left -= 1
		if wait_left <= 0:
			_reply({"ok": true, "waited": true})
	if pending_shot != "":
		var p: String = pending_shot
		pending_shot = ""
		_do_shot(p)
	if server.is_connection_available():
		if peer != null:
			peer.disconnect_from_host()
		peer = server.take_connection()
		buf = ""
	if peer == null:
		return
	peer.poll()
	if peer.get_status() != StreamPeerTCP.STATUS_CONNECTED:
		peer = null
		buf = ""
		return
	var avail := peer.get_available_bytes()
	if avail <= 0:
		return
	var chunk := peer.get_data(mini(avail, 65536))
	if chunk[0] != OK:
		return
	buf += (chunk[1] as PackedByteArray).get_string_from_utf8()
	var lines := buf.split("\n")
	buf = lines[lines.size() - 1]
	var n := 0
	for i in range(lines.size() - 1):
		if n >= 32:
			break
		var line: String = lines[i].strip_edges()
		if line == "":
			continue
		n += 1
		_handle(line)

func _reply(d: Dictionary) -> void:
	if peer == null:
		return
	peer.poll()
	if peer.get_status() != StreamPeerTCP.STATUS_CONNECTED:
		peer = null
		return
	peer.put_data((JSON.stringify(d) + "\n").to_utf8_buffer())

func _handle(line: String) -> void:
	var v = JSON.parse_string(line)
	if not (v is Dictionary):
		_reply({"ok": false, "error": "bad json"})
		return
	var cmd: String = str(v.get("cmd", ""))
	match cmd:
		"ping":
			_reply({"ok": true, "pong": true})
		"click":
			_click(float(v.get("x", 0.0)), float(v.get("y", 0.0)), str(v.get("button", "left")))
			_reply({"ok": true})
		"key":
			_key(v)
			_reply({"ok": true})
		"buttons":
			_reply({"ok": true, "buttons": _dump_buttons()})
		"tree":
			var td := _dump_tree()
			var ws := get_tree().root.size
			_reply({"ok": true, "tree": td, "vp": _vp_size(), "win": [ws.x, ws.y]})
		"shot":
			pending_shot = str(v.get("path", ""))
		"wait":
			wait_left = maxi(1, int(v.get("frames", 10)))
		"resize":
			get_tree().root.size = Vector2i(maxi(320, int(v.get("w", 1280))), maxi(240, int(v.get("h", 720))))
			_reply({"ok": true, "size": [get_tree().root.size.x, get_tree().root.size.y]})
		"state":
			_reply(_state())
		"xform":
			_reply(_xform(str(v.get("text", ""))))
		"quit":
			_reply({"ok": true, "bye": true})
			get_tree().quit(0)
		_:
			_reply({"ok": false, "error": "unknown cmd: " + cmd})

func _mouse(pos: Vector2, button: int, pressed: bool) -> void:
	var ev := InputEventMouseButton.new()
	ev.position = pos
	ev.global_position = pos
	ev.button_index = button
	ev.pressed = pressed
	Input.parse_input_event(ev)

func _click(x: float, y: float, which: String) -> void:
	var b := MOUSE_BUTTON_LEFT
	match which:
		"right":
			b = MOUSE_BUTTON_RIGHT
		"middle":
			b = MOUSE_BUTTON_MIDDLE
	var p := Vector2(x, y)
	var mv := InputEventMouseMotion.new()
	mv.position = p
	mv.global_position = p
	Input.parse_input_event(mv)
	_mouse(p, b, true)
	_mouse(p, b, false)

func _key(v: Dictionary) -> void:
	var code := 0
	if v.has("code"):
		code = int(v.get("code", 0))
	else:
		code = OS.find_keycode_from_string(str(v.get("key", "")))
	for pressed in [true, false]:
		var k := InputEventKey.new()
		k.keycode = code
		k.physical_keycode = code
		k.pressed = pressed
		k.echo = false
		k.ctrl_pressed = bool(v.get("ctrl", false))
		k.shift_pressed = bool(v.get("shift", false))
		k.alt_pressed = bool(v.get("alt", false))
		Input.parse_input_event(k)

func _btn_text(c: Control) -> String:
	if c is OptionButton:
		var ob := c as OptionButton
		if ob.item_count > 0:
			return str(ob.get_item_text(maxi(0, ob.selected)))
		return ""
	if c is Button:
		return str((c as Button).text)
	if c is SpinBox:
		return str((c as SpinBox).value)
	if c is Label:
		return str((c as Label).text)
	return ""

func _ctl_rect(c: Control) -> Array:
	# Canvas coordinates (Control.get_global_rect space): this is the same
	# space synthetic InputEventMouseButton positions live in, so dumped
	# rects are directly clickable, and screenshots are the canvas minified
	# by the window stretch factor. Verified end to end: full menu-driven
	# runs navigate and start games with these rects.
	var r := c.get_global_rect()
	return [r.position.x, r.position.y, r.size.x, r.size.y]

func _vp_size() -> Array:
	if not is_instance_valid(get_viewport()):
		return [0, 0]
	var s := get_viewport().get_visible_rect().size
	return [s.x, s.y]

func _dump_buttons() -> Array:
	var out: Array = []
	_walk_buttons(get_tree().root, out)
	return out

func _walk_buttons(n: Node, out: Array) -> void:
	if out.size() >= 200:
		return
	for ch in n.get_children():
		if ch is BaseButton or ch is SpinBox:
			var c := ch as Control
			if c.is_visible_in_tree():
				out.append({"class": ch.get_class(), "text": _btn_text(c),
					"rect": _ctl_rect(c)})
		_walk_buttons(ch, out)

func _dump_tree() -> Array:
	var out: Array = []
	_walk_tree(get_tree().root, out)
	return out

func _walk_tree(n: Node, out: Array) -> void:
	if out.size() >= 300:
		return
	for ch in n.get_children():
		if ch is Control:
			var c := ch as Control
			if c.is_visible_in_tree():
				var t := _btn_text(c)
				out.append({"class": ch.get_class(), "text": t,
					"rect": _ctl_rect(c)})
		_walk_tree(ch, out)

func _state() -> Dictionary:
	var m: Node = get_parent()
	var g = m.get("game") if m != null else null
	var h: Dictionary = {}
	if g != null:
		var gg = g as C3Game
		var unfin := 0
		for b in gg.buildings_of(0):
			if not bool(b.get("finished", true)):
				unfin += 1
		h = {"units0": gg.unit_count(0), "units1": gg.unit_count(1),
			"blds0": gg.buildings_of(0).size(), "unfin0": unfin, "time": gg.time_s,
			"winner": gg.winner, "selected": gg.get_selected().size()}
	var hud = m.get("hud") if m != null else null
	var lay := {}
	if hud != null:
		lay = {"us": hud.get("ui_us"), "vp": [hud.get("ui_vp").x, hud.get("ui_vp").y] if hud.get("ui_vp") != null else null,
			"sel_l": hud.sel_panel.offset_left if hud.get("sel_panel") != null else -1,
			"sel_r": hud.sel_panel.offset_right if hud.get("sel_panel") != null else -1,
			"win": [get_tree().root.size.x, get_tree().root.size.y]}
	return {"ok": true, "fps": Performance.get_monitor(Performance.TIME_FPS),
		"frame": int(m.get("frame")) if m != null else -1,
		"has_game": g != null, "menu": m.get("menu") != null if m != null else false,
		"game": h, "layout": lay}

func _xform(text: String) -> Dictionary:
	var vp := get_viewport()
	var out := {"window": [vp.get_window().size.x, vp.get_window().size.y] if is_instance_valid(vp.get_window()) else [0, 0],
		"visible": [vp.get_visible_rect().size.x, vp.get_visible_rect().size.y],
		"canvas": [vp.get_canvas_transform().x.x, vp.get_canvas_transform().x.y, vp.get_canvas_transform().y.x, vp.get_canvas_transform().y.y, vp.get_canvas_transform().origin.x, vp.get_canvas_transform().origin.y],
		"final": [vp.get_final_transform().x.x, vp.get_final_transform().x.y, vp.get_final_transform().y.x, vp.get_final_transform().y.y, vp.get_final_transform().origin.x, vp.get_final_transform().origin.y]}
	var found := {}
	_find_text(get_tree().root, text, found)
	out["found"] = found
	return {"ok": true, "xform": out}

func _find_text(n: Node, text: String, out: Dictionary) -> bool:
	if n is Button and text in str((n as Button).text):
		var c := n as Control
		var r := c.get_global_rect()
		out["rect"] = [r.position.x, r.position.y, r.size.x, r.size.y]
		var xf := c.get_global_transform_with_canvas()
		out["with_canvas"] = [xf.x.x, xf.x.y, xf.y.x, xf.y.y, xf.origin.x, xf.origin.y]
		out["class"] = c.get_class()
		return true
	for ch in n.get_children():
		if _find_text(ch, text, out):
			return true
	return false

func _do_shot(path: String) -> void:
	if path == "":
		_reply({"ok": false, "error": "empty path"})
		return
	if not is_instance_valid(get_viewport()):
		_reply({"ok": false, "error": "no viewport"})
		return
	var tex := get_viewport().get_texture()
	if tex == null:
		_reply({"ok": false, "error": "no texture"})
		return
	var img := tex.get_image()
	if img == null or img.is_empty():
		_reply({"ok": false, "error": "blank image"})
		return
	var p := path
	if p.begins_with("res://"):
		p = ProjectSettings.globalize_path(p)
	elif not p.is_absolute_path() and not p.begins_with("user://"):
		p = ProjectSettings.globalize_path("res://").get_base_dir().path_join(p)
	var dir := p.get_base_dir()
	if dir != "" and not DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_recursive_absolute(dir)
	var f := FileAccess.open(p, FileAccess.WRITE)
	if f == null:
		_reply({"ok": false, "error": "cannot write"})
		return
	if img.save_png(p) != OK:
		_reply({"ok": false, "error": "save failed"})
		return
	_reply({"ok": true, "path": p, "size": [img.get_width(), img.get_height()]})
