extends SceneTree

# Final integrated gate after the full swarm wave. Fast, read-only checks.

func _init() -> void:
	var checks := 0
	var bad := 0
	var scripts := [
		"res://scripts/world.gd", "res://scripts/hud.gd", "res://scripts/camera.gd",
		"res://scripts/input_controller.gd", "res://scripts/game.gd",
		"res://scripts/mapgen.gd", "res://scripts/pattern_gen.gd",
		"res://scripts/menu.gd", "res://scripts/main.gd", "res://scripts/data.gd",
		"res://scripts/config.gd",
	]
	for p in scripts:
		checks += 1
		if load(p) == null:
			bad += 1
			print("GATE FAIL load ", p)
	# Key features present in source.
	var probes := [
		["res://scripts/world.gd", "func _nation_sheet"],
		["res://scripts/world.gd", "SHORE_WASH_DEPTH := 0.48"],
		["res://scripts/pattern_gen.gd", "mf_occ"],
		["res://scripts/menu.gd", "cfg[\"players\"]"],
		["res://scripts/data.gd", "PLAYER_AI"],
		["res://scripts/camera.gd", "func jump_to_world"],
		["res://scripts/hud.gd", "MINE_MARKER_COLORS"],
	]
	for pr in probes:
		checks += 1
		var f := FileAccess.open(pr[0], FileAccess.READ)
		if f == null:
			bad += 1
			continue
		var txt: String = f.get_as_text()
		f.close()
		if txt.find(str(pr[1])) < 0:
			bad += 1
			print("GATE FAIL probe ", pr[0], " :: ", pr[1])
	# Docs present.
	for d in [
		"res://../docs/REPORT_FOOD_MILL_PERF.md", "res://../docs/REPORT_ASSETS_BAKING.md",
		"res://../docs/REPORT_NAV_MINIMAP_SHORE.md", "res://../docs/REPORT_DONOR_MENU.md",
		"res://../docs/DONOR_OPTIONS_GAPS.md",
	]:
		checks += 1
		var fp := ProjectSettings.globalize_path(d)
		if not FileAccess.file_exists(d):
			bad += 1
			print("GATE FAIL doc ", d)
	print("FINAL_GATE ", checks - bad, "/", checks)
	quit(0 if bad == 0 else 1)
