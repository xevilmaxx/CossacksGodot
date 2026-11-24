extends SceneTree

# TEMPORARY FIX-TERRAIN final probe — created, run, then DELETED.
const MODULE_PATH := "res://scripts/world3d_terrain.gd"
const DUMP_ABS := "C:/Users/Maxym.Oboyshev/Documents/Craft Anything/cossacks-3-3/app/shots/g32_dump.json"

class StubGame extends C3Game:
	var dump: Dictionary = {}

var _done := false
var _checks: Array[Dictionary] = []

func check(name: String, cond: bool, detail: String = "") -> void:
	_checks.append({"name": name, "passed": cond, "detail": detail})
	print("FIXTERRAIN_PROBE %s %s - %s" % ["PASS" if cond else "FAIL", name, detail])

func finish() -> void:
	if _done:
		return
	_done = true
	var passes := 0
	for c in _checks:
		if bool(c.get("passed", false)):
			passes += 1
	print("FIXTERRAIN_PROBE_SUMMARY %d/%d" % [passes, _checks.size()])
	call_deferred("quit", 0 if passes == _checks.size() else 1)

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var script := load(MODULE_PATH) as Script
	check("module_load", script != null and script.can_instantiate())
	if script == null:
		finish()
		return
	var f := FileAccess.open(DUMP_ABS, FileAccess.READ)
	if f == null:
		check("dump_open", false)
		finish()
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if not (parsed is Dictionary):
		check("dump_parse", false)
		finish()
		return
	var stub := StubGame.new()
	stub.dump = parsed
	var terrain: Node = script.new()
	terrain.bind(stub)
	check("build", bool(terrain.call("build")))
	var st: Dictionary = terrain.get("stats")
	check("grid_320", int((st.get("grid", {}) as Dictionary).get("cells", 0)) == 102400)
	var ti: Dictionary = st.get("tile_index", {})
	check("tile_index_live", int(ti.get("cells", 0)) == 102400, str(ti.get("source", "")))
	var fh: Dictionary = ti.get("face_hist", {})
	var f0 := int(fh.get("0", 0))
	var f1 := int(fh.get("1", 0))
	var f2 := int(fh.get("2", 0))
	check("face_hist_sum", f0 + f1 + f2 == 102400, "0=%d 1=%d 2=%d" % [f0, f1, f2])
	check("front_promoted", f1 > 0, "front=%d" % f1)
	check("side_promoted", f2 > 0, "side=%d" % f2)
	var mi: MeshInstance3D = terrain.get_node_or_null("HeightmapTerrain") as MeshInstance3D
	check("mesh_instance", mi != null)
	if mi != null and mi.mesh != null:
		var arr: Array = mi.mesh.surface_get_arrays(0)
		var uv2: PackedVector2Array = arr[Mesh.ARRAY_TEX_UV2]
		check("uv2_count", uv2.size() == 102400)
		var faces_only := {}
		for i in range(uv2.size()):
			var fv: int = int(uv2[i].y + 0.5)
			faces_only[str(fv)] = int(faces_only.get(str(fv), 0)) + 1
		check("uv2_y_matches_face_hist", int(faces_only.get("1", 0)) == f1 and int(faces_only.get("2", 0)) == f2,
			str(faces_only))
		check("uv2_x_still_tile_id", int(uv2[0].x) == 14 and int(uv2[1].x) == 0,
			"first2=%d,%d" % [int(uv2[0].x), int(uv2[1].x)])
	var mat: Material = null
	if mi != null:
		mat = mi.mesh.surface_get_material(0)
	check("shader_material", mat is ShaderMaterial)
	if mat is ShaderMaterial:
		check("mask_blend_shipped", float((mat as ShaderMaterial).get_shader_parameter("mask_to_alpha")) == 1.0)
		check("atlas_bound", (mat as ShaderMaterial).get_shader_parameter("tile_atlas") != null)
		var g: Vector2 = (mat as ShaderMaterial).get_shader_parameter("atlas_grid")
		check("grid_from_manifest", is_equal_approx(g.x, 16.0) and is_equal_approx(g.y, 8.0), str(g))
		check("shadow_off", float((mat as ShaderMaterial).get_shader_parameter("shadow_enabled")) == 0.0)
	check("one_water_plane", terrain.get_node_or_null("Water3D/WaterPlane") != null
		or terrain.get_node_or_null("WaterPlane") != null)
	check("donor_sun", terrain.get_node_or_null("DonorSun") != null)
	terrain.free()
	stub.free()
	finish()
