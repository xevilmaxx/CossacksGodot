extends SceneTree

# Temporary probe for the main.gd:1592 PERF debug counters (delete after run).
func _initialize() -> void:
	var script = load("res://scripts/world3d.gd")
	var ok := script != null
	var w = null
	if ok:
		w = script.new()
		ok = w != null
	if ok:
		for k in ["dbg_res", "dbg_bld", "dbg_unit", "dbg_fx"]:
			var v = w.get(k)
			if v == null or not (v is int):
				ok = false
				print("CHECK %s MISSING_OR_NOT_INT %s" % [k, str(v)])
			w.set(k, 7)
			if int(w.get(k)) != 7:
				ok = false
				print("CHECK %s NOT_WRITABLE %s" % [k, str(w.get(k))])
	if w != null:
		w.free()
	print("DBG_PROBE ", "PASS" if ok else "FAIL")
	quit(0 if ok else 1)
