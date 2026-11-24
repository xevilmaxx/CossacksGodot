extends SceneTree

# TEMPORARY probe for V7-16 — deleted after the run. Not a manifest test.

const MODULE_PATH := "res://scripts/world3d_fog.gd"
const RESULT_PATH := "res://tests/results/v716_probe.json"

class StubGame extends RefCounted:
	var MAP_W: int = 4
	var MAP_H: int = 3
	var fog_explored: PackedByteArray = PackedByteArray()
	var fog_vis: PackedByteArray = PackedByteArray()
	func _init() -> void:
		fog_explored.resize(12)
		fog_vis.resize(12)

func _initialize() -> void:
	var report := {}
	var probe := MeshInstance3D.new()
	var names: Array[String] = []
	for p in probe.get_property_list():
		names.append(str(p.get("name")))
	report["has_sorting_offset"] = names.has("sorting_offset")
	report["has_render_priority"] = names.has("render_priority")
	probe.free()

	var script_res: Resource = load(MODULE_PATH)
	var inst = (script_res as GDScript).new()
	root.add_child(inst)
	inst.call("bind", StubGame.new())
	inst.call("sync", 0.016)
	var child = inst.get_node_or_null("FogOverlay")
	report["overlay_child_attached"] = child != null
	report["overlay_is_meshinstance3d"] = child is MeshInstance3D
	if child is MeshInstance3D:
		report["overlay_sorting_offset"] = child.get("sorting_offset")
		report["overlay_mesh_surface_count"] = (child as MeshInstance3D).mesh.get_surface_count()
	else:
		report["overlay_sorting_offset"] = -1.0
		report["overlay_mesh_surface_count"] = -1

	var f := FileAccess.open(RESULT_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(report, "\t"))
		f.close()
	print("V716 PROBE ", JSON.stringify(report))
	var ok: bool = bool(report["has_sorting_offset"]) and bool(report["overlay_child_attached"]) and bool(report["overlay_is_meshinstance3d"])
	call_deferred("quit", 0 if ok else 1)
