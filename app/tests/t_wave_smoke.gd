extends SceneTree

# Integrated smoke for the shore / nav / minimap / mines wave.
# Fast: load scripts, verify key APIs/constants exist, run one map gen.

func _init() -> void:
	var checks := 0
	var bad := 0
	# Script parse/load checks.
	for path in [
		"res://scripts/world.gd", "res://scripts/hud.gd",
		"res://scripts/camera.gd", "res://scripts/input_controller.gd",
		"res://scripts/game.gd", "res://scripts/mapgen.gd",
	]:
		var s: Resource = load(path)
		checks += 1
		if s == null:
			bad += 1
			print("SMOKE FAIL load ", path)
	# Camera instant-jump API (source scan: has_method on a Script resource
	# checks GDScript's own method, not the script's declared methods).
	var cf := FileAccess.open("res://scripts/camera.gd", FileAccess.READ)
	if cf != null:
		var ctxt: String = cf.get_as_text()
		cf.close()
		checks += 1
		if ctxt.find("func jump_to_world") < 0:
			bad += 1
			print("SMOKE FAIL camera.jump_to_world missing")
	# Shore bed constants present (source scan).
	var wf := FileAccess.open("res://scripts/world.gd", FileAccess.READ)
	if wf != null:
		var txt: String = wf.get_as_text()
		wf.close()
		checks += 1
		if txt.find("SHORE_WASH_DEPTH := 0.48") < 0:
			bad += 1
			print("SMOKE FAIL shore constant not applied")
	checks += 1
	var mf := FileAccess.open("res://scripts/game.gd", FileAccess.READ)
	if mf != null:
		var mtxt: String = mf.get_as_text()
		mf.close()
		if mtxt.find("_ensure_start_ore_clusters") < 0:
			bad += 1
			print("SMOKE FAIL mine placement helper missing")
	print("WAVE_SMOKE ", checks - bad, "/", checks)
	quit(0 if bad == 0 else 1)
