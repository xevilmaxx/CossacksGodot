extends SceneTree
# TEMPORARY AUDIT3D-09 runtime probe. Deleted after the run.
# Instantiates the real world3d.gd composition + camera3d.gd, binds a stub game,
# and prints the actual Node3D/MeshInstance3D/Camera3D tree created at runtime.

const WORLD := "res://scripts/world3d.gd"
const CAMERA := "res://scripts/camera3d.gd"

class StubGame extends RefCounted:
	var MAP_W: int = 16
	var MAP_H: int = 16
	var height: PackedFloat32Array = PackedFloat32Array()
	var terrain: PackedByteArray = PackedByteArray()
	var entities: Array[Dictionary] = []
	var res_nodes: Array[Dictionary] = []
	var by_id: Dictionary = {}
	var players: Array = [{"id": 0, "entities": []}]
	var fog_explored: PackedByteArray = PackedByteArray()
	var fog_vis: PackedByteArray = PackedByteArray()
	var time_s: float = 0.0
	var selected: Dictionary = {}
	var tile: float = 2.0

	func _init() -> void:
		height.resize(MAP_W * MAP_H)
		for z in MAP_H:
			for x in MAP_W:
				height[z * MAP_W + x] = 2.0 + sin(float(x) * 0.5) + cos(float(z) * 0.4)
		terrain.resize(MAP_W * MAP_H)
		terrain.fill(0)
		fog_explored.resize(MAP_W * MAP_H)
		fog_vis.resize(MAP_W * MAP_H)

	func _get(_property: StringName) -> Variant:
		return null

	func tile_visible(_p: Vector2) -> bool:
		return true

	func has_chunk_or_fallback() -> bool:
		return true


func _count(n: Node, out: Dictionary) -> void:
	if n == null:
		return
	var k := n.get_class()
	out[k] = int(out.get(k, 0)) + 1
	for c in n.get_children():
		_count(c, out)


func _dump(n: Node, prefix: String, out: Array[String], depth: int) -> void:
	if depth > 3 or out.size() >= 60:
		return
	out.append(prefix + str(n.name) + " [" + n.get_class() + "]")
	for c in n.get_children():
		_dump(c, prefix + "  ", out, depth + 1)


func _initialize() -> void:
	var report := {"probe": "AUDIT3D-09", "engine": Engine.get_version_info().get("string", "")}
	var ws = load(WORLD)
	var cs = load(CAMERA)
	report["world_script_loads"] = ws != null
	report["camera_script_loads"] = cs != null
	if ws == null or cs == null:
		print("AUDIT3D_RUNTIME ", JSON.stringify(report))
		call_deferred("quit", 1)
		return

	var game := StubGame.new()
	var world: Node = (ws as GDScript).new()
	report["world_is_Node3D"] = world is Node3D
	root.add_child(world)
	world.call("bind", game)
	world.call("sync", 0.016)

	var cam: Node = (cs as GDScript).new()
	report["camera_is_Camera3D"] = cam is Camera3D
	root.add_child(cam)
	if cam.has_method("bind"):
		cam.call("bind", game, world.get("view_scale"))
	if cam.has_method("set_zoom_target"):
		cam.call("set_zoom_target", 0.75, true)

	var counts := {}
	_count(root, counts)
	report["class_counts"] = counts
	var tree: Array[String] = []
	_dump(world, "", tree, 0)
	report["world_tree"] = tree
	var stats := {}
	for key in ["stats", "get_stats"]:
		for objname in ["world", "terrain", "entities"]:
			var obj: Object = world
			if objname == "terrain":
				obj = world.get("terrain")
			elif objname == "entities":
				obj = world.get("entities")
			if obj != null and obj.has_method(key):
				stats[objname] = obj.call(key)
	report["module_stats"] = stats
	report["view_scale"] = world.get("view_scale")
	report["mesh_count"] = int(counts.get("MeshInstance3D", 0))
	report["multimesh_count"] = int(counts.get("MultiMeshInstance3D", 0))
	report["node3d_count"] = int(counts.get("Node3D", 0))
	report["camera3d_count"] = int(counts.get("Camera3D", 0))
	print("AUDIT3D_RUNTIME ", JSON.stringify(report))
	call_deferred("quit", 0 if (report["world_is_Node3D"] and report["camera_is_Camera3D"] and report["mesh_count"] > 0) else 1)
