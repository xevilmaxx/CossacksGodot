# V7-37 atomic test: integration seam for the optional 3D render mode.
# Deterministic: source inspection of scripts/main.gd + a light load (no game
# bootstrap, no _ready). Fails loudly with SEAM_MISSING until the integration
# owner lands gameplay.render_mode / make_world3d() / make_camera3d().
# Do NOT weaken this test: the 2D default is a hard gate.
extends SceneTree

const MAIN := "res://scripts/main.gd"
const OUT_DIR := "res://tests/results"
const ID := "t_render_mode"

var _checks: Array[Dictionary] = []
var _ok := true

func _has(pattern: String, text: String) -> bool:
	var re := RegEx.new()
	var err := re.compile(pattern)
	if err != OK:
		push_error("t_render_mode: bad regex %s (err %d)" % [pattern, err])
		return false
	return re.search(text) != null

func check(name: String, cond: bool, detail: String = "") -> void:
	_checks.append({
		"name": name,
		"result": "PASS" if cond else "FAIL",
		"passed": cond,
		"detail": detail,
	})
	if not cond:
		_ok = false
	print("CHECK %-30s %s  %s" % [name, "PASS" if cond else "FAIL", detail])

func _default_is_2d(src: String) -> bool:
	var g1 := _has(r"(?m)^\s*var\s+render_mode\b[^\n]*\"2d\"", src)
	var g2 := _has(r"(?m)^\s*render_mode\s*(?::=|=)\s*\"2d\"", src)
	var g3 := _has(r"\"gameplay\.render_mode\"\s*,\s*\"2d\"", src)
	var g4 := _has(r"\brender_mode\b[^\n]{0,120}(?:cfg\.text|cfg\.str)[^\n]{0,120}\"2d\"", src)
	var b1 := _has(r"(?m)^\s*var\s+render_mode\b[^\n]*\"3d\"", src)
	var b2 := _has(r"(?m)^\s*render_mode\s*(?::=|=)\s*\"3d\"", src)
	var b3 := _has(r"\"gameplay\.render_mode\"\s*,\s*\"3d\"", src)
	return (g1 or g2 or g3 or g4) and not (b1 or b2 or b3)

func _write_result(seam: bool) -> void:
	var abs_dir := ProjectSettings.globalize_path(OUT_DIR)
	DirAccess.make_dir_recursive_absolute(abs_dir)
	var path := "%s/%s.json" % [abs_dir, ID]
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_error("cannot write test result: " + path)
		return
	f.store_string(JSON.stringify({
		"id": ID,
		"passed": _ok,
		"result": "PASS" if _ok else "FAIL",
		"status": "BLOCKED-PENDING-INTEGRATION" if not seam else ("PASS" if _ok else "FAIL"),
		"seam_missing": not seam,
		"checks": _checks,
		"unix_ms": Time.get_unix_time_from_system() * 1000.0,
	}, "\t"))
	f.close()

func _initialize() -> void:
	var src := ""
	var f := FileAccess.open(MAIN, FileAccess.READ)
	if f != null:
		src = f.get_as_text()
		f.close()
	check("main_source_readable", not src.is_empty(), "%s (%d chars)" % [MAIN, src.length()])

	var script = load(MAIN)
	check("main_script_loads", script != null, "light load of %s (no _ready)" % MAIN)

	var decl1 := _has(r"(?m)^\s*(?:@\w+\s+)*var\s+render_mode\b", src)
	var decl2 := _has(r"\brender_mode\s*=", src)
	var declared := decl1 or decl2
	check("render_mode_exposed", declared, "main.gd declares/assigns render_mode")

	var default_2d := _default_is_2d(src)
	check("render_mode_default_2d", default_2d, "gameplay.render_mode fallback is \"2d\"")

	var w3d := _has(r"(?m)^\s*func\s+make_world3d\s*\(", src)
	var c3d := _has(r"(?m)^\s*func\s+make_camera3d\s*\(", src)
	check("make_world3d_exposed", w3d, "func make_world3d(...) present")
	check("make_camera3d_exposed", c3d, "func make_camera3d(...) present")

	var br1 := _has(r"(?m)^\s*(?:if|elif)\s+[^\n]*\brender_mode\b", src)
	var br2 := _has(r"(?m)^\s*match\s+render_mode\b", src)
	var br3 := _has(r"\brender_mode\s*==\s*\"3d\"", src)
	var branch := br1 or br2 or br3
	check("three_d_branch_present", branch, "world/camera construction gated on render_mode")

	var wired := src.count("make_world3d") >= 2 and src.count("make_camera3d") >= 2
	check("three_d_helpers_wired", wired, "both make_* helpers declared AND called")

	var legacy_world := src.find("C3WorldScript.new()") >= 0
	var legacy_camera := src.find("C3CameraScript.new()") >= 0
	var legacy_bind := src.find("world.bind(game)") >= 0 and src.find("camera.bind(world)") >= 0
	var legacy := legacy_world and legacy_camera and legacy_bind
	check("two_d_path_preserved", legacy, "legacy 2D world/camera constructors still present")

	# Bare instance: reads the declared default without running _ready().
	var rm_val = null
	if script != null and declared:
		var inst = script.new()
		if inst != null:
			rm_val = inst.get("render_mode")
	var rm_text := str(rm_val) if rm_val != null else ""
	var runtime_ok := false
	var runtime_detail := "SEAM_MISSING: no render_mode property on main.gd instance"
	if declared:
		if rm_val == null or rm_text.is_empty():
			runtime_ok = true
			runtime_detail = "render_mode not initialised before _ready; source fallback \"2d\" governs"
		else:
			runtime_ok = rm_text == "2d"
			runtime_detail = "bare instance render_mode=\"%s\" (expected \"2d\")" % rm_text
	check("runtime_default_2d", runtime_ok, runtime_detail)

	var seam := declared and default_2d and w3d and c3d and branch and wired
	var seam_note := "SEAM_MISSING: main.gd has no 3D render-mode seam (integration not landed)" if not seam else "3D seam present"
	if not seam:
		print("SEAM_MISSING  ", seam_note)
	print("T_RENDER_MODE ", "PASS" if _ok else "FAIL", " ", _checks.size(), " checks; ", seam_note)
	_write_result(seam)
	call_deferred("quit", 0 if _ok else 1)
