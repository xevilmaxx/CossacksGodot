# TEMPLATE for a small, single-feature test. Copy to t_<feature>.gd.
# Rules: one feature per file; headless; self-exiting via call_deferred;
# write a result JSON; NEVER call quit() directly from _initialize().
extends SceneTree

const OUT_DIR := "res://tests/results"

var _id := "t_template"
var _checks: Array[Dictionary] = []
var _ok := true

func check(name: String, cond: bool, detail: String = "") -> void:
	_checks.append({"name": name, "passed": cond, "detail": detail})
	if not cond:
		_ok = false

func _write_result() -> void:
	var abs_dir := ProjectSettings.globalize_path(OUT_DIR)
	DirAccess.make_dir_recursive_absolute(abs_dir)
	var path := "%s/%s.json" % [abs_dir, _id]
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_error("cannot write test result: " + path)
		return
	f.store_string(JSON.stringify({
		"id": _id,
		"passed": _ok,
		"checks": _checks,
		"unix_ms": Time.get_unix_time_from_system() * 1000.0,
	}, "\t"))
	f.close()

func _initialize() -> void:
	# TODO: construct only the minimum game/world state this feature needs.
	# Do NOT import or run the whole selftest: keep tests small and independent.
	check("placeholder", true, "replace with a real feature assertion")
	_write_result()
	call_deferred("quit", 0 if _ok else 1)
