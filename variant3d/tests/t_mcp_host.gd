# GAMECRAFT-MCP — MCP server hosted directly inside the Godot game.
#
# A Streamable-HTTP MCP endpoint served by the live variant3d game process:
#   POST http://127.0.0.1:<port>/mcp  (JSON-RPC: initialize, tools/list, tools/call)
# Tools drive the REAL booted game (place buildings, pan camera, tick sim)
# and capture screenshots / frame sequences from the live viewport — so play
# commands and video capture share one process ("play + video meanwhile").
#
# Launch (through the single-door runner, WITH rendering — no --headless):
#   python variant3d\tools\godot_runner.py run --id mcp-host --timeout 3600 -- \
#     --path variant3d --script res://tests/t_mcp_host.gd -- \
#     --config "<ABS>\config_donor_capture.json" --seed 20261113 --mcp-port 8931 \
#     --screenshot "<ABS>\boot_viewport.png"
# Register in OpenCode as a remote MCP server with URL
#   http://127.0.0.1:8931/mcp
#
# No donor binary is executed. No parity claim.
extends SceneTree

const MAIN_SCENE := "res://scenes/main.tscn"
const SIM_STEP := 1.0 / 32.0
const PINNED_SEED := 20261113

# Streamable-HTTP MCP protocol versions this host speaks. The initialize reply
# echoes the client's requested version when it is in this list; otherwise the
# host negotiates its preferred (supported) version. No silent fallback to an
# unsupported value.
const SUPPORTED_PROTOCOL_VERSIONS := ["2024-11-05", "2025-03-26", "2025-06-18"]
const PREFERRED_PROTOCOL_VERSION := "2024-11-05"
const SERVER_NAME := "cossacksgodotmcp"
const SERVER_VERSION := "1.0.0"

var _cfg_arg := ""
var _seed_arg := ""
var _port := 8931
var _shot_seq := 0

var _main: Node = null
var _game = null
var _world = null
var _cam = null
var _vp: SubViewport = null
var _tcp := TCPServer.new()
var _running := false


func _arg_value(flag: String) -> String:
	for src in [OS.get_cmdline_user_args(), OS.get_cmdline_args()]:
		var args := PackedStringArray(src)
		for i in range(args.size()):
			if str(args[i]) == flag and i + 1 < args.size():
				return str(args[i + 1])
	return ""


func _fail(msg: String) -> void:
	print("GAMECRAFT-MCP FAIL " + msg)
	push_error(msg)
	quit(1)


func _parse_args() -> bool:
	_cfg_arg = _arg_value("--config")
	_seed_arg = _arg_value("--seed")
	var port_txt := _arg_value("--mcp-port")
	if port_txt != "":
		_port = clampi(int(port_txt), 1024, 65535)
	if not OS.get_cmdline_user_args().has("--screenshot"):
		# ROOT CAUSE (2026-11-26): OS.get_cmdline_user_args() returns a COPY;
		# appending a dummy flag to it has no effect on main.gd. The game then
		# boots to the menu (game/world/camera/vp all null) and the host waits
		# forever. The caller MUST pass an explicit --screenshot <dummy png>
		# in the user args; main.gd needs it to build the full game/viewport.
		_fail("need --screenshot <absolute dummy png> in user args: main.gd only builds the full game with it")
		return false
	if _cfg_arg == "" or not _cfg_arg.is_absolute_path():
		_fail("need --config <absolute json>")
		return false
	if _seed_arg != "20261113":
		_fail("need --seed 20261113")
		return false
	return true


func _init() -> void:
	if not _parse_args():
		return
	_boot_and_host()


func _temp_root() -> String:
	var t := OS.get_environment("TEMP")
	if t == "":
		t = OS.get_environment("TMP")
	return t.replace("\\", "/")


func _boot() -> bool:
	var packed: PackedScene = load(MAIN_SCENE) as PackedScene
	if packed == null:
		_fail("cannot load main scene")
		return false
	_main = packed.instantiate()
	if _main == null:
		_fail("cannot instantiate main")
		return false
	root.add_child(_main)
	# Donor 240x240 maps with the full-resolution terrain atlas can need several
	# minutes to build; 300 s booted the legacy map but timed out on the donor
	# capture config. Keep the real boot, just allow enough frames.
	var deadline := Time.get_ticks_msec() + 900000
	while Time.get_ticks_msec() < deadline:
		await process_frame
		if _main.get("game") != null and _main.get("world") != null and _main.get("camera") != null and _main.get("capture_view3d") != null:
			var g = _main.get("game")
			if g != null and int(g.get("MAP_W")) > 0:
				break
	if _main.get("game") == null or _main.get("world") == null or _main.get("camera") == null or _main.get("capture_view3d") == null or int(_main.get("game").get("MAP_W")) <= 0:
		print("GAMECRAFT-MCP BOOT DIAG game=%s world=%s camera=%s vp=%s screenshot=%s map_w=%s" % [
			str(_main.get("game") != null), str(_main.get("world") != null),
			str(_main.get("camera") != null), str(_main.get("capture_view3d") != null),
			str(_main.get("screenshot_path")), str(_main.get("game").get("MAP_W")) if _main.get("game") != null else "null",
		])
	_game = _main.get("game")
	_world = _main.get("world")
	_cam = _main.get("camera")
	_vp = _main.get("capture_view3d") as SubViewport
	if _game == null or _world == null or _cam == null or _vp == null:
		_fail("boot incomplete")
		return false
	# Keep the sim controllable from tools, not from the menu driver.
	var ais = _main.get("ais")
	if ais is Array:
		(ais as Array).clear()
	_main.set("speed", 0.0)
	_main.set("acc", 0.0)
	_main.set("screenshot_frames", 1000000)
	_main.set("screenshot_done", true)
	_cam.set_process(false)
	return true


func _boot_and_host() -> void:
	# Listen before the synchronous donor-map build. A 240x240 donor map can
	# block frame processing for minutes; clients must still be able to
	# handshake and get an exact "game not initialized" refusal instead of a
	# dead port. The port only reports READY when the real game is live.
	if _tcp.listen(_port, "127.0.0.1") != OK:
		_fail("cannot listen on 127.0.0.1:%d" % _port)
		return
	_running = true
	print("GAMECRAFT-MCP LISTENING port=%d (donor map booting)" % _port)
	_boot_async()  # fire-and-forget: resumes on process_frame independently
	while _running:
		await process_frame
		await _pump()


func _boot_async() -> void:
	if not await _boot():
		return
	print("GAMECRAFT-MCP READY port=%d map=%dx%d" % [_port, int(_game.get("MAP_W")), int(_game.get("MAP_H"))])


# --- HTTP plumbing (minimal Streamable-HTTP: POST /mcp only) ---

func _pump() -> void:
	if not _tcp.is_connection_available():
		return
	var peer: StreamPeerTCP = _tcp.take_connection()
	if peer == null:
		return
	await _handle(peer)
	peer.disconnect_from_host()


func _read_exact(peer: StreamPeerTCP, n: int, timeout_ms: int) -> PackedByteArray:
	var out := PackedByteArray()
	var start := Time.get_ticks_msec()
	while out.size() < n:
		if Time.get_ticks_msec() - start > timeout_ms:
			break
		var avail := peer.get_available_bytes()
		if avail <= 0:
			await process_frame
			continue
		var chunk: PackedByteArray = peer.get_data(mini(avail, n - out.size()))[1]
		out.append_array(chunk)
	return out


func _read_request(peer: StreamPeerTCP) -> Dictionary:
	# Read headers.
	var head := PackedByteArray()
	var start := Time.get_ticks_msec()
	while Time.get_ticks_msec() - start < 5000:
		var avail := peer.get_available_bytes()
		if avail > 0:
			head.append_array(peer.get_data(avail)[1])
			var s := head.get_string_from_utf8()
			if s.find("\r\n\r\n") >= 0:
				break
		else:
			await process_frame
	var s := head.get_string_from_utf8()
	var hsplit := s.split("\r\n\r\n", false, 1)
	if hsplit.size() < 1:
		return {}
	var header_txt: String = hsplit[0]
	var body_start := head.size() - (hsplit[1].to_utf8_buffer().size() if hsplit.size() > 1 else 0)
	var lines := header_txt.split("\r\n")
	if lines.is_empty():
		return {}
	var parts := lines[0].split(" ", false)
	if parts.size() < 2:
		return {}
	var method: String = parts[0]
	var path: String = parts[1]
	var content_len := 0
	for ln in lines:
		var low := ln.to_lower()
		if low.begins_with("content-length:"):
			content_len = int(ln.substr(15).strip_edges())
	var body := PackedByteArray()
	if body_start < head.size():
		body = head.slice(body_start)
	while body.size() < content_len:
		var more := await _read_exact(peer, content_len - body.size(), 5000)
		if more.is_empty():
			break
		body.append_array(more)
	return {"method": method, "path": path, "body": body.get_string_from_utf8()}


func _respond(peer: StreamPeerTCP, code: int, text: String, body: String) -> void:
	var payload := body.to_utf8_buffer()
	var head := "HTTP/1.1 %d %s\r\nContent-Type: application/json\r\nContent-Length: %d\r\nConnection: close\r\n\r\n" % [code, text, payload.size()]
	peer.put_data(head.to_utf8_buffer())
	if payload.size() > 0:
		peer.put_data(payload)


func _rpc_ok(id: Variant, result: Dictionary) -> String:
	return JSON.stringify({"jsonrpc": "2.0", "id": _rpc_id(id), "result": result})


func _rpc_err(id: Variant, code: int, message: String) -> String:
	return JSON.stringify({"jsonrpc": "2.0", "id": _rpc_id(id), "error": {"code": code, "message": message}})


func _rpc_id(id: Variant) -> Variant:
	# Godot's JSON parser turns integer JSON-RPC ids into floats; strict MCP
	# clients require the original int. Preserve integral ids verbatim.
	# String ids are passed through untouched; non-integral numbers stay floats.
	if id is float and is_equal_approx(float(id), floorf(float(id))):
		return int(id)
	return id


func _negotiate_protocol(requested: String) -> String:
	# Echo a supported client version; otherwise negotiate our preferred one.
	if SUPPORTED_PROTOCOL_VERSIONS.has(requested):
		return requested
	return PREFERRED_PROTOCOL_VERSION


func _err_result(reason: String) -> Dictionary:
	# MCP tool failure: always isError with the exact reason, never a silent
	# success-looking result and never a generic "something went wrong".
	return {"content": [{"type": "text", "text": reason}], "isError": true}


func _check_number(args: Dictionary, key: String) -> String:
	if not args.has(key):
		return "missing required argument '%s'" % key
	var v: Variant = args.get(key)
	if not (v is int or v is float):
		return "argument '%s' must be a number (got %s)" % [key, str(v)]
	return ""


func _check_int(args: Dictionary, key: String) -> String:
	if not args.has(key):
		return "missing required argument '%s'" % key
	var v: Variant = args.get(key)
	if not (v is int or v is float):
		return "argument '%s' must be an integer (got %s)" % [key, str(v)]
	if not is_equal_approx(float(v), floorf(float(v))):
		return "argument '%s' must be an integer (got %s)" % [key, str(v)]
	return ""


func _check_string(args: Dictionary, key: String) -> String:
	if not args.has(key):
		return "missing required argument '%s'" % key
	var v: Variant = args.get(key)
	if not (v is String):
		return "argument '%s' must be a string (got %s)" % [key, str(v)]
	return ""


# --- MCP surface ---

func _tool_defs() -> Array:
	return [
		{"name": "game.status", "description": "Live game state: map, entities, sim time, camera.", "inputSchema": {"type": "object", "properties": {}}},
		{"name": "game.tick", "description": "Advance the sim clock by N seconds (frozen driver; deterministic fixed steps).", "inputSchema": {"type": "object", "properties": {"seconds": {"type": "number"}}, "required": ["seconds"]}},
		{"name": "camera.pan_to", "description": "Move the capture camera to a world target (sim metres) and report the settled target.", "inputSchema": {"type": "object", "properties": {"x": {"type": "number"}, "y": {"type": "number"}}, "required": ["x", "y"]}},
		{"name": "game.screenshot", "description": "Render the live viewport once and return the PNG (saved to TEMP, base64 inline).", "inputSchema": {"type": "object", "properties": {}}},
		{"name": "game.place_building", "description": "Place a finished=false building site for player 0 at sim metres (does not assign builders).", "inputSchema": {"type": "object", "properties": {"sid": {"type": "string"}, "x": {"type": "number"}, "y": {"type": "number"}}, "required": ["sid", "x", "y"]}},
		{"name": "video.record_frames", "description": "Advance the sim in fixed steps, capturing N live viewport frames (meanwhile-video). Returns PNG paths.", "inputSchema": {"type": "object", "properties": {"frames": {"type": "integer"}, "sim_step": {"type": "number"}}, "required": ["frames"]}},
	]


func _status_text() -> String:
	var ents := (_game.get("entities") as Array).size()
	var res := (_game.get("res_nodes") as Array).size()
	return JSON.stringify({
		"map": [int(_game.get("MAP_W")), int(_game.get("MAP_H"))],
		"seed": PINNED_SEED,
		"entities": ents, "res_nodes": res,
		"time_s": float(_game.get("time_s")),
		"camera_target": [float((_cam.get("_target") as Vector2).x), float((_cam.get("_target") as Vector2).y)],
		"terrain_backend": str(_world.get("terrain_backend")),
	})


func _render_once() -> Dictionary:
	# Returns {"ok": true, "image": Image} or {"ok": false, "reason": String}.
	if _vp == null:
		return {"ok": false, "reason": "capture viewport is not initialized"}
	if _world == null:
		return {"ok": false, "reason": "world is not initialized"}
	_world.sync(0.0)
	_vp.render_target_update_mode = SubViewport.UPDATE_ONCE
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var tex = _vp.get_texture()
	if tex == null:
		return {"ok": false, "reason": "capture viewport texture is null"}
	var img := tex.get_image()
	if img == null:
		return {"ok": false, "reason": "capture viewport image is null"}
	if img.is_empty():
		return {"ok": false, "reason": "capture viewport image is empty"}
	return {"ok": true, "image": img}


func _save_shot(img: Image, tag: String) -> Dictionary:
	# Returns {"ok": true, "path": String} or {"ok": false, "reason": String}.
	_shot_seq += 1
	var root := _temp_root()
	var dir := root.path_join("opencode/v42/mcp_gamecraft")
	var mk_err := DirAccess.make_dir_recursive_absolute(dir)
	if mk_err != OK:
		return {"ok": false, "reason": "cannot create screenshot dir (%d): %s" % [mk_err, dir]}
	var path := dir.path_join("%s_%04d.png" % [tag, _shot_seq])
	var save_err := img.save_png(path)
	if save_err != OK:
		return {"ok": false, "reason": "cannot save PNG (%d) to %s" % [save_err, path]}
	return {"ok": true, "path": path}


func _call_tool(name: String, args: Dictionary) -> Dictionary:
	match name:
		"game.status":
			if _game == null or _world == null or _cam == null:
				return _err_result("game.status: game/world/camera not initialized")
			return {"content": [{"type": "text", "text": _status_text()}]}
		"game.tick":
			var why := _check_number(args, "seconds")
			if why != "":
				return _err_result("game.tick: " + why)
			var secs := float(args.get("seconds"))
			if secs < 0.0 or secs > 120.0:
				return _err_result("game.tick: argument 'seconds' out of range [0,120] (got %s)" % str(secs))
			if _game == null or not _game.has_method("tick"):
				return _err_result("game.tick: game object has no tick() method")
			var n := int(round(secs / SIM_STEP))
			_game.set("winner", -1)
			_game.set("paused", false)
			for i in range(n):
				_game.tick(SIM_STEP)
			return {"content": [{"type": "text", "text": JSON.stringify({"advanced_s": n * SIM_STEP, "time_s": float(_game.get("time_s"))})}]}
		"camera.pan_to":
			var why_x := _check_number(args, "x")
			if why_x != "":
				return _err_result("camera.pan_to: " + why_x)
			var why_y := _check_number(args, "y")
			if why_y != "":
				return _err_result("camera.pan_to: " + why_y)
			if _cam == null or not _cam.has_method("jump_to_world"):
				return _err_result("camera.pan_to: camera has no jump_to_world() method")
			var t := Vector2(float(args.get("x")), float(args.get("y")))
			_cam.call("jump_to_world", t)
			_cam.set_process(false)
			var actual: Vector2 = _cam.get("_target")
			return {"content": [{"type": "text", "text": JSON.stringify({"requested": [t.x, t.y], "settled": [actual.x, actual.y]})}]}
		"game.screenshot":
			var r: Dictionary = await _render_once()
			if not bool(r.get("ok", false)):
				return _err_result("game.screenshot: " + str(r.get("reason", "unknown render failure")))
			var img := r.get("image") as Image
			var sr: Dictionary = _save_shot(img, "shot")
			if not bool(sr.get("ok", false)):
				return _err_result("game.screenshot: " + str(sr.get("reason", "unknown save failure")))
			var path := str(sr.get("path"))
			var png: PackedByteArray = FileAccess.get_file_as_bytes(path)
			if png.is_empty():
				return _err_result("game.screenshot: PNG file is empty: " + path)
			return {"content": [
				{"type": "text", "text": JSON.stringify({"file": path, "w": img.get_width(), "h": img.get_height()})},
				{"type": "image", "data": Marshalls.raw_to_base64(png), "mimeType": "image/png"},
			]}
		"game.place_building":
			var why_sid := _check_string(args, "sid")
			if why_sid != "":
				return _err_result("game.place_building: " + why_sid)
			var why_x2 := _check_number(args, "x")
			if why_x2 != "":
				return _err_result("game.place_building: " + why_x2)
			var why_y2 := _check_number(args, "y")
			if why_y2 != "":
				return _err_result("game.place_building: " + why_y2)
			if _game == null or not _game.has_method("place_building"):
				return _err_result("game.place_building: game object has no place_building() method")
			var sid := str(args.get("sid"))
			var pos := Vector2(float(args.get("x")), float(args.get("y")))
			var site_v: Variant = _game.call("place_building", 0, sid, pos, false, [])
			if not (site_v is Dictionary) or (site_v as Dictionary).is_empty():
				return _err_result("game.place_building: place_building refused (returned %s)" % str(site_v))
			var site := site_v as Dictionary
			return {"content": [{"type": "text", "text": JSON.stringify({"site_id": int(site.get("id", -1)), "sid": sid, "pos": [pos.x, pos.y]})}]}
		"video.record_frames":
			var why_n := _check_int(args, "frames")
			if why_n != "":
				return _err_result("video.record_frames: " + why_n)
			var n := int(args.get("frames"))
			if n < 1 or n > 120:
				return _err_result("video.record_frames: argument 'frames' out of range [1,120] (got %d)" % n)
			var step := SIM_STEP
			if args.has("sim_step"):
				var why_step := _check_number(args, "sim_step")
				if why_step != "":
					return _err_result("video.record_frames: " + why_step)
				step = float(args.get("sim_step"))
				if step < 0.0 or step > 5.0:
					return _err_result("video.record_frames: argument 'sim_step' out of range [0,5] (got %s)" % str(step))
			if _game == null or not _game.has_method("tick"):
				return _err_result("video.record_frames: game object has no tick() method")
			var files: Array = []
			_game.set("winner", -1)
			_game.set("paused", false)
			for i in range(n):
				if step > 0.0:
					_game.tick(step)
				var rf: Dictionary = await _render_once()
				if not bool(rf.get("ok", false)):
					return _err_result("video.record_frames: frame %d: %s" % [i, str(rf.get("reason", "unknown render failure"))])
				var fimg := rf.get("image") as Image
				var sf: Dictionary = _save_shot(fimg, "vid")
				if not bool(sf.get("ok", false)):
					return _err_result("video.record_frames: frame %d: %s" % [i, str(sf.get("reason", "unknown save failure"))])
				files.append(str(sf.get("path")))
			return {"content": [{"type": "text", "text": JSON.stringify({"frames": files, "time_s": float(_game.get("time_s"))})}]}
	return _err_result("unknown tool '" + name + "'")


func _handle(peer: StreamPeerTCP) -> void:
	var req := await _read_request(peer)
	if req.is_empty():
		return
	if not str(req.get("path", "")).begins_with("/mcp"):
		_respond(peer, 404, "Not Found", _rpc_err(null, -32601, "unknown path"))
		return
	var http_method := str(req.get("method", "")).to_upper()
	if http_method == "GET" or http_method == "DELETE":
		# Streamable-HTTP clients probe with GET and terminate a session with
		# DELETE. Tolerate both with an empty 2xx reply (never a JSON-RPC error).
		_respond(peer, 202, "Accepted", "")
		return
	if http_method != "POST":
		_respond(peer, 405, "Method Not Allowed", _rpc_err(null, -32601, "POST only"))
		return
	var parsed: Variant = JSON.parse_string(str(req.get("body", "")))
	if not (parsed is Dictionary):
		_respond(peer, 400, "Bad Request", _rpc_err(null, -32700, "bad JSON"))
		return
	var msg := parsed as Dictionary
	var id: Variant = msg.get("id", null)
	var method := str(msg.get("method", ""))
	# JSON-RPC notifications (including initialized) get 202 with an empty body.
	if method == "notifications/initialized" or method.begins_with("notifications/") or not msg.has("id"):
		_respond(peer, 202, "Accepted", "")
		return
	if method == "initialize":
		var params_v: Variant = msg.get("params", null)
		var params := {}
		if params_v is Dictionary:
			params = params_v as Dictionary
		var requested := ""
		if params.has("protocolVersion"):
			requested = str(params.get("protocolVersion"))
		_respond(peer, 200, "OK", _rpc_ok(id, {
			"protocolVersion": _negotiate_protocol(requested),
			"capabilities": {"tools": {"listChanged": false}},
			"serverInfo": {"name": SERVER_NAME, "version": SERVER_VERSION},
		}))
		return
	if method == "tools/list":
		_respond(peer, 200, "OK", _rpc_ok(id, {"tools": _tool_defs()}))
		return
	if method == "tools/call":
		var call_params_v: Variant = msg.get("params", null)
		if not (call_params_v is Dictionary):
			_respond(peer, 200, "OK", _rpc_ok(id, _err_result("tools/call: params must be an object")))
			return
		var call_params := call_params_v as Dictionary
		if not call_params.has("name") or not (call_params.get("name") is String) or str(call_params.get("name")) == "":
			_respond(peer, 200, "OK", _rpc_ok(id, _err_result("tools/call: missing required 'name'")))
			return
		var args_v: Variant = call_params.get("arguments", {})
		if not (args_v is Dictionary):
			_respond(peer, 200, "OK", _rpc_ok(id, _err_result("tools/call: 'arguments' must be an object")))
			return
		var out: Dictionary = await _call_tool(str(call_params.get("name")), args_v as Dictionary)
		_respond(peer, 200, "OK", _rpc_ok(id, out))
		return
	# JSON-RPC-level errors still carry an HTTP 200 and a response body.
	_respond(peer, 200, "OK", _rpc_err(id, -32601, "unknown method " + method))
