# TEMPORARY probe for V7-84 — DELETE after verification.
extends SceneTree

const MODULE := "res://scripts/water3d.gd"
const OUT := "res://tests/results/_v784_probe.json"

var _checks: Array[Dictionary] = []
var _ok := true


func check(name: String, cond: bool, detail: String = "") -> void:
	_checks.append({"name": name, "passed": cond, "detail": detail})
	if not cond:
		_ok = false
	print("V784_PROBE %s %s - %s" % ["PASS" if cond else "FAIL", name, detail])


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var script := load(MODULE) as Script
	check("module_load", script != null and script.can_instantiate(), MODULE)
	if script == null:
		_finish()
		return
	var inst: Object = script.new()
	get_root().add_child(inst)

	# _ready() builds the plane; guard for the case it did not run.
	var mi: MeshInstance3D = null
	for child in (inst as Node).get_children():
		if child is MeshInstance3D:
			mi = child as MeshInstance3D
	if mi == null and inst.has_method("build"):
		inst.call("build", 64, 64)
		for child in (inst as Node).get_children():
			if child is MeshInstance3D:
				mi = child as MeshInstance3D

	check("mesh_instance_exists", mi != null, "mi=" + str(mi))
	var mat: Material = null
	if mi != null:
		mat = mi.material_override
	check("shader_material_exists", mat is ShaderMaterial,
		"material=" + str(mat.get_class() if mat != null else "<null>"))

	if mat is ShaderMaterial:
		var sm := mat as ShaderMaterial
		var wl = sm.get_shader_parameter("water_level")
		var sh = sm.get_shader_parameter("shore_height")
		var mh = sm.get_shader_parameter("max_height")
		check("uniform_water_level_-0.25", is_equal_approx(float(wl), -0.25), "got=" + str(wl))
		check("uniform_shore_height_-0.1", is_equal_approx(float(sh), -0.1), "got=" + str(sh))
		check("uniform_max_height_2.96", is_equal_approx(float(mh), 2.96), "got=" + str(mh))
		var wn = sm.get_shader_parameter("wave_noise")
		check("wave_noise_bound", wn != null, "wave_noise=" + str(wn))
		var ht = sm.get_shader_parameter("height_tex")
		check("height_tex_fallback_bound", ht != null, "height_tex=" + str(ht))
		var shdr = sm.shader
		check("shader_resource_bound", shdr != null, "shader=" + str(shdr))
		var arr: Array = mi.mesh.surface_get_arrays(0)
		var vs = arr[Mesh.ARRAY_VERTEX]
		check("plane_has_4_vertices", vs != null and vs.size() == 4,
			"vertices=" + str(vs.size() if vs != null else -1))
	_finish()


func _finish() -> void:
	var passes := 0
	for c in _checks:
		if bool(c.get("passed", false)):
			passes += 1
	var abs_dir := ProjectSettings.globalize_path(OUT.get_base_dir())
	DirAccess.make_dir_recursive_absolute(abs_dir)
	var f := FileAccess.open(ProjectSettings.globalize_path(OUT), FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify({
			"id": "_v784_probe", "passed": _ok,
			"passes": passes, "total": _checks.size(), "checks": _checks,
		}, "\t"))
		f.close()
	print("V784_PROBE RESULT: %s %d/%d" % ["PASS" if _ok else "FAIL", passes, _checks.size()])
	call_deferred("quit", 0 if _ok else 1)
