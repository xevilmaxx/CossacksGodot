extends SceneTree

# Fast smoke test after the anim-folder migration: confirm representative
# sheets from each new subfolder resolve through Godot's import cache.

func _init() -> void:
	var paths := [
		"res://assets/models/anim/rus/units/rus_peasant_idle.png",
		"res://assets/models/anim/aus/buildings/aus_cen.png",
		"res://assets/models/anim/common/units/archer_walk.png",
		"res://assets/models/anim/common/naval/yacht_hull.png",
		"res://assets/models/anim/sco/units/sco_peasant_walk.png",
	]
	var bad := 0
	for p in paths:
		var ok: bool = ResourceLoader.exists(p)
		var tex: Resource = load(p) if ok else null
		var good: bool = (tex != null) and ((tex as Texture2D).get_width() > 0)
		if not good:
			bad += 1
		print("SHEET ", "OK" if good else "FAIL", " ", p)
	print("SHEET_SMOKE ", paths.size() - bad, "/", paths.size())
	quit(0 if bad == 0 else 1)
