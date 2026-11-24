extends SceneTree

# TERRAIN-SMALL — headless probe for the 64x64 / 128x128 terrain fixtures.
#
# Owns ONLY this file (plus variant3d/tests/fixtures/small_map_*.json and
# docs/coord_swarm_2026-11-24/reports/TERRAIN_SMALL_maps.md).
# No source, shader, canonical config, manifest, gate file or git edit.
#
# Boots the REAL game through res://scenes/main.tscn, with the SAME --config
# argument main.gd parses (main.gd:1278), skipping the menu via --screenshot
# (main.gd:230) so the full 3D world is built synchronously in headless mode.
# --screenshot is a TEST-ONLY runner flag; the dummy PNG is never written here.
#
# Usage (through variant3d/tools/godot_runner.py ONLY):
#   --headless --path variant3d --script res://tests/t_smallmap_terrain.gd -- \
#     --config <ABS>/small_map_64.json --screenshot <temp>/unused_64.png
#
# Every check reports measured counts. Results go to user:// (outside the repo)
# and to stdout. SCRIPT ERROR absence is verified by scanning the runner stderr
# with variant3d/tools/smallmap_capture.py scan-stderr (no GDScript stderr API).

const MAIN_SCENE := "res://scenes/main.tscn"
const TERRAIN_SCRIPT := "res://scripts/world3d_terrain.gd"
const Data = preload("res://scripts/data.gd")
const NAMED_CELLS := 124          # V7-85 manifest atlas.named_cells
const EXPECTED_GRID := Vector2(16.0, 8.0)

var _config_path := ""
var _abs_config := ""
var _want := 0
var _want_h := 0
var _gp: Dictionary = {}
var _id := "smallmap_terrain_unknown"
var _main: Node = null
var _checks: Array[Dictionary] = []
var _ok := true
var _finished := false
var _boot_pending := false
var _m: Dictionary = {}           # measured values, written to result JSON


func check(name: String, cond: bool, detail: String) -> void:
	_checks.append({"name": name, "passed": cond, "detail": detail})
	if not cond:
		_ok = false
	print("T_SMALLMAP %s %s - %s" % ["PASS" if cond else "FAIL", name, detail])


func abort_all(reason: String) -> void:
	check("boot", false, reason)
	print("T_SMALLMAP STDERR_SCAN_REQUIRED (runner stderr.txt)")
	finish()


func finish() -> void:
	if _finished:
		return
	_finished = true
	var passes := 0
	for c in _checks:
		if bool(c.get("passed", false)):
			passes += 1
	var out := {
		"id": _id,
		"passed": _ok,
		"passes": passes,
		"total": _checks.size(),
		"config": _config_path,
		"expected_tiles": _want,
		"checks": _checks,
		"measured": _m,
		"script_error_note": "verify via smallmap_capture.py scan-stderr on runner stderr.txt",
	}
	var target := "user://%s.json" % _id
	var abs_target := ProjectSettings.globalize_path(target)
	var f := FileAccess.open(abs_target, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(out, "\t"))
		f.close()
	else:
		push_error("t_smallmap_terrain: cannot write " + abs_target)
	print("T_SMALLMAP RESULT_JSON: " + abs_target)
	print("T_SMALLMAP RESULT: %s %d/%d" % ["PASS" if _ok else "FAIL", passes, _checks.size()])
	print("T_SMALLMAP STDERR_SCAN_REQUIRED (runner stderr.txt)")
	call_deferred("quit", 0 if _ok else 1)


func _failsafe() -> void:
	if not _finished:
		abort_all("probe aborted before completion")


func _arg_value(flag: String) -> String:
	for src in [OS.get_cmdline_user_args(), OS.get_cmdline_args()]:
		var args := PackedStringArray(src)
		for i in range(args.size()):
			if str(args[i]) == flag and i + 1 < args.size():
				return str(args[i + 1])
	return ""


func _resolve_config(given: String) -> String:
	if given.is_absolute_path():
		return given if FileAccess.file_exists(given) else ""
	var by_res := ProjectSettings.globalize_path("res://").path_join(given)
	if FileAccess.file_exists(by_res):
		return by_res
	if FileAccess.file_exists(given):
		return given
	return ""


func _find_named(root: Node, wanted: String) -> Node:
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n.name == wanted:
			return n
		for c in n.get_children():
			stack.append(c)
	return null


func _find_mesh(root: Node, wanted: String) -> MeshInstance3D:
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n is MeshInstance3D and (n as MeshInstance3D).name == wanted:
			return n as MeshInstance3D
		for c in n.get_children():
			stack.append(c)
	return null


func _count_named(root: Node, wanted: String) -> int:
	var n := 0
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var cur: Node = stack.pop_back()
		if cur.name == wanted:
			n += 1
		for c in cur.get_children():
			stack.append(c)
	return n


# Regression guard from FIX-TERRAIN §8: on a perfectly flat height grid the
# donor cDiff1/cDiff2 promotion must produce ZERO face cells at EVERY size.
# Calls the same private function build() uses, without rebuilding the atlas.
func _flat_face_check(w: int, h: int) -> void:
	var scr := load(TERRAIN_SCRIPT) as Script
	if scr == null or not scr.can_instantiate():
		check("flat_face_zero", false, "cannot load " + TERRAIN_SCRIPT)
		return
	var inst: Node = scr.new() as Node
	if inst == null:
		check("flat_face_zero", false, "script.new() returned null")
		return
	var flat := PackedFloat32Array()
	flat.resize(w * h)
	flat.fill(1.5)
	var promoted := 0
	for z in range(h):
		for x in range(w):
			var mode := int(inst.call("_face_mode_at", flat, w, h, x, z))
			if mode != 0:
				promoted += 1
	inst.free()
	_m["flat_grid_promoted_cells"] = promoted
	check("flat_face_zero", promoted == 0,
		"flat %dx%d grid: promoted=%d (expected 0)" % [w, h, promoted])


func _initialize() -> void:
	if _finished:
		return

	_config_path = _arg_value("--config")
	if _config_path == "":
		abort_all("missing --config <fixture.json> in user args")
		return
	_abs_config = _resolve_config(_config_path)
	if _abs_config == "":
		abort_all("config fixture not found: " + _config_path)
		return
	var f := FileAccess.open(_abs_config, FileAccess.READ)
	if f == null:
		abort_all("cannot read " + _abs_config)
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if not (parsed is Dictionary):
		abort_all("fixture is not a JSON object: " + _abs_config)
		return
	var gp_v: Variant = (parsed as Dictionary).get("gameplay", {})
	if not (gp_v is Dictionary):
		abort_all("fixture has no gameplay object")
		return
	_gp = gp_v
	_want = int(_gp.get("map_width_tiles", 0))
	_want_h = int(_gp.get("map_height_tiles", 0))
	if _want != _want_h or _want < 16:
		abort_all("fixture map size invalid: %dx%d" % [_want, _want_h])
		return
	_id = "smallmap_terrain_%d" % _want
	_m["config"] = _abs_config
	_m["fixture_map_tiles"] = [_want, _want_h]
	_m["fixture_render_mode"] = str(_gp.get("render_mode", "<inherited>"))
	_m["fixture_seed"] = int(_gp.get("random_seed", -1))
	check("fixture_map_size", _want == 64 or _want == 128,
		"expected 64 or 128, got %d" % _want)

	# Boot the real game with the fixture. main.gd re-reads the same --config.
	var packed := load(MAIN_SCENE) as PackedScene
	if packed == null:
		abort_all("cannot load " + MAIN_SCENE)
		return
	_main = packed.instantiate()
	root.add_child(_main)
	# Under a custom SceneTree main loop the scene's _ready() is delivered when
	# the loop starts, not necessarily inside _initialize(). Inspect on the
	# first _process() tick so the config has actually been applied.
	_boot_pending = true
	return


func _process(_delta: float) -> bool:
	if not _finished and _boot_pending:
		_boot_pending = false
		_run_checks()
	return false


func _run_checks() -> void:
	var game_v: Variant = _main.get("game") if _main != null else null
	var boot_ok: bool = (_main != null and game_v != null
		and str(_main.get("render_mode")).to_lower() == "3d"
		and int(Data.MAP_W) == _want and int(Data.MAP_H) == _want
		and int(Data.RANDOM_SEED) == int(_gp.get("random_seed", -1)))
	_m["boot_render_mode"] = str(_main.get("render_mode")) if _main != null else "<none>"
	_m["boot_map_tiles"] = [int(Data.MAP_W), int(Data.MAP_H)]
	_m["boot_seed"] = int(Data.RANDOM_SEED)
	check("real_game_boot", boot_ok,
		"render_mode=%s map=%dx%d seed=%d (fixture %dx%d seed=%d)" % [
			str(_main.get("render_mode")) if _main != null else "<none>",
			int(Data.MAP_W), int(Data.MAP_H), int(Data.RANDOM_SEED),
			_want, _want_h, int(_gp.get("random_seed", -1))])
	if not boot_ok:
		abort_all("game did not boot with the fixture")
		return

	var mi := _find_mesh(_main, "HeightmapTerrain")
	if mi == null:
		check("terrain_mesh_present", false, "HeightmapTerrain not found")
		abort_all("terrain mesh missing")
		return
	var terrain: Node = mi.get_parent()
	var mesh: Mesh = mi.mesh
	check("terrain_mesh_present", terrain != null and mesh != null
		and terrain.has_method("has_chunk_or_fallback"),
		"HeightmapTerrain parent=%s mesh=%s" % [
			terrain.name if terrain != null else "<none>",
			"present" if mesh != null else "<none>"])

	var stats_v: Variant = terrain.get("stats")
	var stats: Dictionary = stats_v if stats_v is Dictionary else {}
	_m["terrain_stats_present"] = not stats.is_empty()
	check("terrain_stats_present", not stats.is_empty(),
		"stats keys=%d" % stats.size())

	var surfaces := mesh.get_surface_count() if mesh != null else -1
	var arrays: Array = mesh.surface_get_arrays(0) if surfaces > 0 else []
	var vv: Variant = arrays[Mesh.ARRAY_VERTEX] if arrays.size() > Mesh.ARRAY_VERTEX else null
	var iv: Variant = arrays[Mesh.ARRAY_INDEX] if arrays.size() > Mesh.ARRAY_INDEX else null
	var uv2v: Variant = arrays[Mesh.ARRAY_TEX_UV2] if arrays.size() > Mesh.ARRAY_TEX_UV2 else null
	var vertices: int = (vv as PackedVector3Array).size() if vv is PackedVector3Array else -1
	var triangles: int = ((iv as PackedInt32Array).size() / 3) if iv is PackedInt32Array else -1
	var uv2_count: int = (uv2v as PackedVector2Array).size() if uv2v is PackedVector2Array else -1
	_m["mesh_surfaces"] = surfaces
	_m["mesh_vertices"] = vertices
	_m["mesh_triangles"] = triangles
	_m["uv2_count"] = uv2_count
	var cells: int = _want * _want
	check("single_surface", surfaces == 1, "surfaces=%d (expected 1)" % surfaces)
	check("vertex_count", vertices == cells,
		"vertices=%d expected=%d" % [vertices, cells])
	check("triangle_count", triangles == (_want - 1) * (_want - 1) * 2,
		"triangles=%d expected=%d" % [triangles, (_want - 1) * (_want - 1) * 2])
	check("uv2_count", uv2_count == cells,
		"UV2 entries=%d expected=%d" % [uv2_count, cells])

	# UV2.x = donor tile id; UV2.y = face mode 0/1/2 (FIX-TERRAIN).
	var min_x := INF
	var max_x := -INF
	var out_of_range := 0
	var face_hist := {}
	var bad_y := 0
	if uv2v is PackedVector2Array:
		var uv2: PackedVector2Array = uv2v
		for i in range(uv2.size()):
			var t: Vector2 = uv2[i]
			min_x = minf(min_x, t.x)
			max_x = maxf(max_x, t.x)
			if t.x < 0.0 or t.x > float(NAMED_CELLS - 1):
				out_of_range += 1
			var y := int(t.y)
			if y < 0 or y > 2 or absf(t.y - float(y)) > 0.001:
				bad_y += 1
			face_hist[str(y)] = int(face_hist.get(str(y), 0)) + 1
	_m["uv2_x_min"] = min_x
	_m["uv2_x_max"] = max_x
	_m["uv2_x_out_of_atlas"] = out_of_range
	_m["uv2_y_hist"] = face_hist
	check("uv2_x_donor_range", out_of_range == 0 and uv2_count == cells,
		"x in [%s,%s], out_of_[0,%d]=%d" % [
			str(min_x), str(max_x), NAMED_CELLS - 1, out_of_range])
	check("uv2_y_face_modes", bad_y == 0,
		"non 0/1/2 UV2.y=%d hist=%s" % [bad_y, str(face_hist)])

	# stats.face_hist must sum to the full grid and match the measured UV2.hist.
	var ti_fh_v: Variant = stats.get("tile_index", {})
	var ti_fh: Dictionary = ti_fh_v if ti_fh_v is Dictionary else {}
	var fh_v: Variant = ti_fh.get("face_hist", {})
	var fh: Dictionary = fh_v if fh_v is Dictionary else {}
	var fh_sum := 0
	for k in fh:
		fh_sum += int(fh[k])
	_m["face_hist"] = fh
	_m["face_hist_sum"] = fh_sum
	check("face_hist_sum", fh_sum == cells,
		"face_hist=%s sum=%d expected=%d" % [str(fh), fh_sum, cells])
	var hist_match := fh.size() == face_hist.size()
	if hist_match:
		for k in face_hist:
			if int(fh.get(str(k), -1)) != int(face_hist[k]):
				hist_match = false
	check("face_hist_matches_uv2", hist_match,
		"stats=%s measured=%s" % [str(fh), str(face_hist)])
	_flat_face_check(_want, _want_h)

	# Tile indices come from the live donor tileblock, not a constant fallback.
	var ti_v: Variant = stats.get("tile_index", {})
	var ti: Dictionary = ti_v if ti_v is Dictionary else {}
	var ti_cells := int(ti.get("cells", -1))
	var clamped := int(ti.get("out_of_atlas_cells_clamped", -1))
	_m["tile_index_cells"] = ti_cells
	_m["tile_index_source"] = str(ti.get("source", ""))
	_m["tile_index_out_of_atlas_clamped"] = clamped
	_m["tile_index_hist_top"] = str(ti.get("hist", {})).substr(0, 400)
	check("tile_index_cells", ti_cells == cells,
		"cells=%d expected=%d source=%s" % [ti_cells, cells, str(ti.get("source", ""))])

	# Atlas material: grid from V7-85 manifest, three samplers, shadow off.
	var mat: Material = mesh.surface_get_material(0) if mesh != null else null
	var at_v: Variant = stats.get("atlas", {})
	var at: Dictionary = at_v if at_v is Dictionary else {}
	var grid_v: Variant = at.get("grid", [])
	var grid: Array = grid_v if grid_v is Array else []
	var grid_ok: bool = grid.size() == 2 and int(grid[0]) == 16 and int(grid[1]) == 8
	var shader_ok := false
	var grid_param: Variant = null
	var samplers_ok := false
	var shader_shadow: Variant = null
	if mat is ShaderMaterial:
		var sm := mat as ShaderMaterial
		grid_param = sm.get_shader_parameter("atlas_grid")
		shader_shadow = sm.get_shader_parameter("shadow_enabled")
		shader_ok = grid_param is Vector2 and (grid_param as Vector2).is_equal_approx(EXPECTED_GRID)
		samplers_ok = (sm.get_shader_parameter("tile_atlas") != null
			and sm.get_shader_parameter("alpha_atlas") != null
			and sm.get_shader_parameter("alphavert_atlas") != null)
	_m["atlas_grid"] = grid
	_m["atlas_grid_shader_param"] = str(grid_param)
	_m["atlas_mode"] = str(stats.get("atlas_mode", ""))
	_m["material_model"] = str(stats.get("material_model", "")).substr(0, 200)
	_m["shader_shadow_enabled"] = str(shader_shadow)
	check("atlas_grid_manifest", grid_ok and shader_ok,
		"stats.grid=%s shader.atlas_grid=%s (expected [16,8] / (16,8))" % [
			str(grid), str(grid_param)])
	check("atlas_material_bound", mat is ShaderMaterial and samplers_ok,
		"material=%s tile/alpha/alphavert bound=%s" % [
			mat.get_class() if mat != null else "<none>", str(samplers_ok)])
	check("shader_shadow_disabled", str(shader_shadow) == "0" or str(shader_shadow) == "0.0",
		"shadow_enabled=%s (expected 0)" % str(shader_shadow))

	# FIX-TERRAIN §8 — explicit shadow-map regression gate at BOTH sizes.
	var sun := _find_named(terrain, "DonorSun")
	var sun_shadow: Variant = sun.get("shadow_enabled") if sun != null else null
	_m["donor_sun_present"] = sun != null
	_m["donor_sun_shadow_enabled"] = str(sun_shadow)
	check("donor_sun_present", sun is DirectionalLight3D,
		"node=%s class=%s" % [sun.name if sun != null else "<none>",
			sun.get_class() if sun != null else "<none>"])
	check("donor_sun_shadow_off", sun != null and bool(sun_shadow) == false,
		"DonorSun.shadow_enabled=%s (expected false)" % str(sun_shadow))
	check("terrain_cast_shadow_off", mi.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF,
		"cast_shadow=%d expected=%d" % [mi.cast_shadow,
			GeometryInstance3D.SHADOW_CASTING_SETTING_OFF])

	# V7-84 water module (height-driven dark bands, NOT shadows).
	var water_v: Variant = stats.get("water", {})
	var water: Dictionary = water_v if water_v is Dictionary else {}
	var water_mod := str(water.get("module", ""))
	var water_node := _find_named(terrain, "Water3D")
	var plane_count := _count_named(terrain, "WaterPlane")
	_m["water_module"] = water_mod
	_m["water_height_aware"] = str(water.get("height_aware", false))
	_m["water_plane_count"] = plane_count
	check("water_module_present", water_node != null and plane_count == 1
		and water_mod.ends_with("water3d.gd")
		and bool(water.get("height_aware", false)),
		"module=%s node=%s planes=%d height_aware=%s" % [
			water_mod, water_node.name if water_node != null else "<none>",
			plane_count, str(water.get("height_aware", false))])

	finish()
