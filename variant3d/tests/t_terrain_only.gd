# TEST-P0 / t_terrain_only.gd — ISOLATED terrain-only 64x64 atom.
#
# Owns ONLY this file (plus docs/coord_swarm_2026-11-25/reports/TEST_P0_report.md).
# No source, shader, asset, config, manifest, fixture, gate-file or git edit.
# AUTHORING ONLY: this file was never executed by this agent; no Godot job was
# submitted, no runner ticket was taken (docs/COMMANDS.md runner monopoly).
#
# Design sources:
#   TEST-01 §"Test ladder" row P0 and §"Scaffolding needed" item 1
#     (docs/coord_swarm_2026-11-25/reports/TEST_01_smallmap_harness.md:210-212,
#      :228-255) — stub game, windowed stub-owned PNG, exact structural checks.
#   TEST_MATRIX.md:18 (T0 row) + :29-46 (V3D_02 refinement) — same 64² map,
#     no donor parity claim until F0.
#   V3D_02 §"Piece-test ladder proposal" row T0
#     (docs/coord_swarm_2026-11-25/reports/V3D_02_terrain_render_audit.md:134-153).
#   Template conventions: variant3d/tests/_template_test.gd:1-38 (one feature
#     per file, result JSON, call_deferred quit, never quit in _initialize()).
#   Stub + dynamic load pattern: t_terrain3d.gd:12-14,41-46,106-127,161-204;
#     t_pick3d.gd:48-71 (res_nodes/res_dirty/entities/pick_radius/height_at/
#     resolve_mine_sid + empty cmd_* counters).
#   Result/arg mechanics: t_smallmap_terrain.gd:42-99,150-171,271-339,353-384;
#     OS user args after the second `--` (TERRAIN_SMALL_maps.md:57-66).
#   Windowed SubViewport readback: terrain3d_sandbox.gd:50-58,139-151;
#     testbridge.gd:277-308; main.gd:1156-1193,1801-1862.
#   PNG metric mirror (READ-ONLY): smallmap_capture.py:21-39 (non-black > 8,
#     luma = 0.2126R+0.7152G+0.0722B, row dark when >90% pixels luma<20).
#   Terrain module contract: world3d_terrain.gd:93-95,624-874 (one mesh,
#     UV2.x=tile id, UV2.y=face mode, WATER_LEVEL=-0.25, atlas shadow_enabled=0,
#     WaterPlane created by _make_water3d at :762-764).
#   Camera: camera3d.gd:148-198,232-252 (bind sets make_current and centred
#     transform; _target stays SIM; no private writes from this atom).
#
# Fixture: synthetic, deterministic, IN-MEMORY 64x64 tile grid — NOT the
# real-boot `small_map_64.json` path. Height is mild (neighbour delta << the
# donor cDiff1=0.5 threshold at world3d_terrain.gd:117-118) so the fixed-grid
# face-promotion regression is exactly zero; tileblock is all grass id 0
# (presets_summer.json:2 -> atlas cell 0), so there are no shore/rock/water
# cells. res_nodes = [] — no trees, mines, food or units are bound.
#
# All visual statements here are PORT APPROX / internal-consistency only.
# No donor GPU A/B frame exists (V3D_02 parity_guard); do not claim parity.
extends SceneTree

const MODULE_PATH := "res://scripts/world3d_terrain.gd"
const CAMERA_PATH := "res://scripts/camera3d.gd"
# Written by a parallel owner; loaded dynamically, never by class_name
# (TEST-01 §Blockers 10; t_terrain3d.gd:12-13). A local stub of the same shape
# is embedded below and used if this file is absent.
const HARNESS_PATH := "res://tests/fixtures/_smallmap_harness.gd"
const OUT_PATH := "res://tests/results/t_terrain_only.json"

const GRID_W := 64
const GRID_H := 64
const CELLS := GRID_W * GRID_H
const TILE_M := 2.0                 # data.gd:23
const WATER_LEVEL := -0.25          # world3d_terrain.gd:95 (mapgen.gd:29; UNVERIFIED donor literal)
const BLK_WATER := 255              # game.gd:52
const GRASS_TILE := 0               # presets_summer.json:2 grass1
const NAMED_CELLS := 124            # V7-85 atlas manifest named_cells
const EXPECTED_GRID := Vector2(16.0, 8.0)  # V785 manifest / t_smallmap_terrain.gd:26
const WINDOW_SIZE := Vector2i(1280, 720)   # data.gd:113-114; no CLI flag (TEST-01 Blockers 3)
const CAPTURE_FRAMES := 10          # TEST_MATRIX.md:32 "capture after ~10 frames"

const CHECK_NAMES := [
	"harness_stub_shape",
	"terrain_module_api",
	"camera_module_api",
	"build_ok",
	"surface_count",
	"vertex_count",
	"triangle_count",
	"uv2_count",
	"uv2_y_face_modes",
	"flat_grid_promoted",
	"res_nodes_empty",
	"no_water_cells",
	"no_water_tileblock",
	"atlas_grid_manifest",
	"atlas_material_bound",
	"shader_shadow_disabled",
	"water_plane_hidden",
	"capture_image",
	"capture_saved",
	"non_black_fraction",
	"full_width_dark_rows",
]

# Minimal local fallback stub, deliberately the same shape as the shared
# helper described in TEST-01 §Scaffolding item 1 (:230-239). It extends the
# real C3Game so a typed bind() would also work (t_terrain3d.gd:37-46).
# Only the fields actually consumed by world3d_terrain.gd / camera3d.gd are
# populated; the cmd_* counters stay empty, as in t_pick3d.gd:48-71.
class LocalStubGame extends C3Game:
	# ATOM-REPAIR: res_dirty / entities / res_nodes are inherited from C3Game
	# (game.gd:149,82,61). Redeclaring them was a parse error; the inherited
	# fields are used directly and keep the same types.
	var cmd_calls: Dictionary = {}
	var dump: Dictionary = {}
	var height_b64: String = ""
	var units: Array = []
	var buildings: Array = []

	func _bump(m: String) -> void:
		cmd_calls[m] = int(cmd_calls.get(m, 0)) + 1

	func total_cmd_calls() -> int:
		var n := 0
		for v in cmd_calls.values():
			n += int(v)
		return n

	func pick_radius(_e: Dictionary) -> float:
		return 1.0

	# ATOM-REPAIR: parent signature is resolve_mine_sid(String, Vector2) -> String
	# (game.gd:2685); the old Dictionary arity was a parse error.
	func resolve_mine_sid(_sid: String, _pos: Vector2) -> String:
		return ""

	# SIM metres, top-left map origin (game.gd:1893-1907 mirror, bilinear).
	func height_at(p: Vector2) -> float:
		if height.size() != MAP_W * MAP_H:
			return 0.0
		var fx := clampf(p.x / TILE_M - 0.5, 0.0, float(MAP_W - 1))
		var fz := clampf(p.y / TILE_M - 0.5, 0.0, float(MAP_H - 1))
		var x0 := int(fx)
		var z0 := int(fz)
		var x1: int = mini(x0 + 1, MAP_W - 1)
		var z1: int = mini(z0 + 1, MAP_H - 1)
		var tx: float = fx - float(x0)
		var tz: float = fz - float(z0)
		var h00: float = height[z0 * MAP_W + x0]
		var h10: float = height[z0 * MAP_W + x1]
		var h01: float = height[z1 * MAP_W + x0]
		var h11: float = height[z1 * MAP_W + x1]
		return h00 + (h10 - h00) * tx + (h01 - h00) * tz + (h00 - h10 - h01 + h11) * tx * tz

	func cmd_move(_a = null, _b = null, _c = null) -> void:
		_bump("cmd_move")

	func cmd_gather(_a = null, _b = null, _c = null) -> void:
		_bump("cmd_gather")

	func cmd_build(_a = null, _b = null, _c = null) -> void:
		_bump("cmd_build")

var _id := "t_terrain_only"
var _checks: Array[Dictionary] = []
var _ok := true
var _finished := false
var _setup_done := false
var _visual_checked := false
var _headless := false
var _png_path := ""
var _capture_view: SubViewport = null
var _terrain: Node = null
var _camera: Camera3D = null
var _game: Object = null
var _heights := PackedFloat32Array()
var _tileblock := PackedByteArray()
var _harness_source := ""
var _frame := 0
var _capture_pending := false
var _capturing := false
var _m: Dictionary = {}


# `cond` is Variant so a SKIP_CAPTURE row can carry JSON null instead of a
# misleading PASS/FAIL boolean. Only an explicit `false` flips _ok.
func check(name: String, cond, detail: String = "", status: String = "") -> void:
	var st := status
	if st == "":
		st = "PASS" if cond == true else ("FAIL" if cond == false else "SKIPPED")
	_checks.append({"name": name, "passed": cond, "status": st, "detail": detail})
	if cond == false:
		_ok = false
	print("T_TERRAIN_ONLY %s %s - %s" % [st, name, detail])


func _fail_remaining(from_index: int, tag: String, reason: String) -> void:
	for i in range(from_index, CHECK_NAMES.size()):
		check(CHECK_NAMES[i], false, tag + ": " + reason)


func _verdict() -> String:
	if not _ok:
		return "FAIL"
	return "PASS" if _visual_checked else "SKIP_CAPTURE"


func finish() -> void:
	if _finished:
		return
	_finished = true
	var verdict := _verdict()
	var passes := 0
	var fails := 0
	var skips := 0
	for c in _checks:
		if c.get("passed") == true:
			passes += 1
		elif c.get("passed") == false:
			fails += 1
		else:
			skips += 1
	var out := {
		"id": _id,
		# No full PASS is claimed on the headless/skip path.
		"passed": verdict == "PASS",
		"verdict": verdict,
		"capture_status": ("PASS" if _visual_checked else "SKIP_CAPTURE"),
		"structural_ok": _ok,
		"passes": passes,
		"fails": fails,
		"skipped_or_skip_capture": skips,
		"checks": _checks,
		"measured": _m,
		"harness_source": _harness_source,
		"png_path": _png_path,
		"skip_reason": ("" if _visual_checked else
			"DisplayServer.get_name()==headless: state-only result, PNG not captured"),
		"script_error_note": "verify via smallmap_capture.py scan-stderr on runner stderr.txt",
		"parity_label": "PORT APPROX — internal consistency only; no donor GPU A/B (V3D_02 parity_guard)",
		"unix_ms": Time.get_unix_time_from_system() * 1000.0,
	}
	var abs_dir := ProjectSettings.globalize_path(OUT_PATH.get_base_dir())
	DirAccess.make_dir_recursive_absolute(abs_dir)
	var abs_path := ProjectSettings.globalize_path(OUT_PATH)
	var f := FileAccess.open(abs_path, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(out, "\t"))
		f.close()
	else:
		push_error("t_terrain_only: cannot write result: " + abs_path)
	print("T_TERRAIN_ONLY RESULT_JSON: " + abs_path)
	# SKIP_CAPTURE is not a failure of the atom, but it is never reported as
	# PASS. Exit 0 only when no evaluated check failed.
	print("T_TERRAIN_ONLY RESULT: %s %d/%d evaluated, %d skipped" % [verdict, passes, passes + fails, skips])
	call_deferred("quit", 0 if _ok else 1)


# Safety net for an exception inside _initialize(); inert once setup finished.
func _failsafe() -> void:
	if _finished or _setup_done:
		return
	_fail_remaining(0, "ABORTED", "test aborted before setup completed")
	finish()


func _arg_value(flag: String) -> String:
	for src in [OS.get_cmdline_user_args(), OS.get_cmdline_args()]:
		var args := PackedStringArray(src)
		for i in range(args.size()):
			if str(args[i]) == flag and i + 1 < args.size():
				return str(args[i + 1])
	return ""


func _make_grid() -> void:
	_heights.resize(CELLS)
	_tileblock.resize(CELLS)
	for z in range(GRID_H):
		for x in range(GRID_W):
			var i := z * GRID_W + x
			# Mild relief: max axis delta ~0.005 m << cDiff1=0.5, so no face
			# promotion, while the field is not a bare constant.
			_heights[i] = 1.5 + 0.03 * sin(float(x) * 0.11) + 0.02 * cos(float(z) * 0.09)
			_tileblock[i] = GRASS_TILE


# TEST-01 §Scaffolding item 1: try the shared helper first; duplicate its
# shape locally if the parallel owner has not landed it yet.
func _make_stub_game() -> Object:
	if ResourceLoader.exists(HARNESS_PATH):
		var helper: Object = load(HARNESS_PATH)
		var caller: Object = helper
		# The landed helper exposes static factories (extends RefCounted);
		# tolerate an instance-method shape too without weakening the stub
		# shape check that follows.
		if helper != null and not helper.has_method("make_stub_game"):
			if helper is Script and (helper as Script).can_instantiate():
				caller = (helper as Script).new()
		if caller != null and caller.has_method("make_stub_game"):
			var g_v: Variant = caller.call("make_stub_game", GRID_W, GRID_H,
				_heights, [], _tileblock)
			if g_v is Object and is_instance_valid(g_v):
				_harness_source = "shared:" + HARNESS_PATH
				return g_v
	# Fallback: same shape, local definition (noted in the report).
	var local := LocalStubGame.new()
	local.MAP_W = GRID_W
	local.MAP_H = GRID_H
	local.height = _heights
	local.tileblock = _tileblock
	local.res_nodes = []
	local.height_b64 = Marshalls.raw_to_base64(_heights.to_byte_array())
	local.dump = {
		"map_w": GRID_W,
		"map_h": GRID_H,
		"height": local.height_b64,
		"tileblock": Marshalls.raw_to_base64(_tileblock),
	}
	_harness_source = "embedded_local_stub"
	return local


# Regression guard copied from t_smallmap_terrain.gd:150-171: call the SAME
# private function build() uses on a perfectly flat grid, at this map size.
func _probe_flat_promotions() -> int:
	var scr := load(MODULE_PATH) as Script
	if scr == null or not scr.can_instantiate():
		return -1
	var probe: Object = scr.new()
	if probe == null:
		return -1
	var flat := PackedFloat32Array()
	flat.resize(CELLS)
	flat.fill(1.5)
	var promoted := 0
	for z in range(GRID_H):
		for x in range(GRID_W):
			if int(probe.call("_face_mode_at", flat, GRID_W, GRID_H, x, z)) != 0:
				promoted += 1
	probe.free()
	return promoted


func _find_named(root: Node, wanted: String) -> Array[Node]:
	var found: Array[Node] = []
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n.name == wanted:
			found.append(n)
		for c in n.get_children():
			stack.append(c)
	return found


func _hide_water(root: Node) -> void:
	# Isolation: P0 has no shore/water layer. The terrain module always builds
	# one WaterPlane (world3d_terrain.gd:762-764); hide it rather than deleting
	# module-owned nodes (terrain3d_sandbox.gd:120-124 precedent).
	var planes := _find_named(root, "WaterPlane")
	var water_nodes := _find_named(root, "Water3D")
	for n in water_nodes:
		n.visible = false
	for n in planes:
		n.visible = false
	var all_hidden := true
	for n in planes:
		if n.visible:
			all_hidden = false
	_m["water_plane_count"] = planes.size()
	_m["water_3d_node_count"] = water_nodes.size()
	check("water_plane_hidden", all_hidden,
		"WaterPlane nodes=%d all_hidden=%s (module-owned, hidden not deleted)" % [
			planes.size(), str(all_hidden)])


# Mirrors smallmap_capture.py:21-39 (READ-ONLY). get_pixel() returns 0..1
# factors; the Python tool converts to 0..255 float32 RGB.
func _image_metrics(img: Image) -> Dictionary:
	var w := img.get_width()
	var h := img.get_height()
	var non_black := 0
	var dark_rows := 0
	var luma_sum := 0.0
	for y in range(h):
		var row_dark := 0
		for x in range(w):
			var c := img.get_pixel(x, y)
			var r := c.r * 255.0
			var g := c.g * 255.0
			var b := c.b * 255.0
			if r > 8.0 or g > 8.0 or b > 8.0:
				non_black += 1
			var l := 0.2126 * r + 0.7152 * g + 0.0722 * b
			luma_sum += l
			if l < 20.0:
				row_dark += 1
		if float(row_dark) / float(maxi(w, 1)) > 0.90:
			dark_rows += 1
	var n := float(maxi(w * h, 1))
	return {
		"width": w,
		"height": h,
		"non_black_fraction": float(non_black) / n,
		"mean_luma": luma_sum / n,
		"full_width_dark_rows": dark_rows,
	}


func _initialize() -> void:
	if _finished:
		return
	call_deferred("_failsafe")

	_headless = DisplayServer.get_name() == "headless"
	_png_path = _arg_value("--screenshot")
	if _png_path == "":
		_png_path = _arg_value("--png")
	_m["display_server"] = DisplayServer.get_name()
	_m["headless"] = _headless
	_m["requested_png"] = _png_path

	_make_grid()
	_game = _make_stub_game()
	_m["harness_source"] = _harness_source
	var shape_ok: bool = (_game != null and is_instance_valid(_game)
		and int(_game.get("MAP_W")) == GRID_W and int(_game.get("MAP_H")) == GRID_H
		and (_game.get("height") is PackedFloat32Array)
		and (_game.get("tileblock") is PackedByteArray)
		and (_game.get("res_nodes") is Array)
		and int((_game.get("res_nodes") as Array).size()) == 0)
	check("harness_stub_shape", shape_ok,
		"source=%s MAP=%dx%d height/tileblock/res_nodes present=%s" % [
			_harness_source,
			str(_game.get("MAP_W")) if _game != null else "<none>",
			str(_game.get("MAP_H")) if _game != null else "<none>", str(shape_ok)])
	if not shape_ok:
		_fail_remaining(1, "STUB_SHAPE", "harness stub does not expose the expected shape")
		_setup_done = true
		finish()
		return

	# Windowed GPU target. Created in windowed mode only; headless runs stay
	# state-only and never attempt a 3D readback (main.gd:1156-1158,1790-1800).
	if not _headless:
		get_root().size = WINDOW_SIZE
		_capture_view = SubViewport.new()
		_capture_view.name = "TerrainOnlyViewport"
		_capture_view.world_3d = World3D.new()
		_capture_view.size = WINDOW_SIZE
		_capture_view.render_target_update_mode = SubViewport.UPDATE_ONCE
		get_root().add_child(_capture_view)
	var parent: Node = _capture_view if _capture_view != null else get_root()

	var terrain_script := load(MODULE_PATH) as Script
	var terrain_api := (terrain_script != null and terrain_script.can_instantiate())
	var terrain_missing: Array[String] = []
	if terrain_api:
		var probe: Object = terrain_script.new()
		for meth in ["bind", "build", "invalidate", "has_chunk_or_fallback", "height_at_world"]:
			if not probe.has_method(meth):
				terrain_missing.append(meth)
		probe.free()
	terrain_api = terrain_api and terrain_missing.is_empty()
	check("terrain_module_api", terrain_api,
		"script=%s missing=%s" % [MODULE_PATH, str(terrain_missing)])
	var camera_script := load(CAMERA_PATH) as Script
	var camera_api := (camera_script != null and camera_script.can_instantiate())
	var camera_missing: Array[String] = []
	if camera_api:
		var probe2: Object = camera_script.new()
		for meth in ["bind", "world_to_px", "screen_to_world", "set_zoom_target"]:
			if not probe2.has_method(meth):
				camera_missing.append(meth)
		probe2.free()
	camera_api = camera_api and camera_missing.is_empty()
	check("camera_module_api", camera_api,
		"script=%s missing=%s" % [CAMERA_PATH, str(camera_missing)])
	if not terrain_api or not camera_api:
		_fail_remaining(3, "MODULE_MISSING", "terrain/camera script or API unavailable")
		_setup_done = true
		finish()
		return

	# Bind ONLY the terrain module and a real camera3d.gd. No entities/FX/
	# picking modules, no world3d.gd, no main.tscn boot.
	_terrain = terrain_script.new() as Node
	_terrain.name = "HeightmapTerrainModule"
	parent.add_child(_terrain)
	_terrain.call("bind", _game)
	var built := bool(_terrain.call("build"))
	check("build_ok", built, "world3d_terrain.build() returned " + str(built))
	if not built:
		_fail_remaining(4, "SETUP_FAILED", "build() returned false")
		_setup_done = true
		finish()
		return

	_camera = camera_script.new() as Camera3D
	_camera.name = "DonorCamera"
	parent.add_child(_camera)
	_camera.call("bind", _game)
	# Freeze the framing: camera3d._process() edge-scrolls on mouse position
	# (camera3d.gd:484-581); a fixed capture must not pan mid-run.
	_camera.set_process(false)
	_camera.make_current()

	var mi := _terrain.get_node_or_null("HeightmapTerrain") as MeshInstance3D
	var mesh: Mesh = mi.mesh if mi != null else null
	var stats_v: Variant = _terrain.get("stats")
	var stats: Dictionary = stats_v if stats_v is Dictionary else {}
	_m["terrain_stats_present"] = not stats.is_empty()
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
	check("surface_count", surfaces == 1, "surfaces=%d (expected 1)" % surfaces)
	check("vertex_count", vertices == CELLS, "vertices=%d expected=%d" % [vertices, CELLS])
	check("triangle_count", triangles == (GRID_W - 1) * (GRID_H - 1) * 2,
		"triangles=%d expected=%d" % [triangles, (GRID_W - 1) * (GRID_H - 1) * 2])
	check("uv2_count", uv2_count == CELLS, "UV2 entries=%d expected=%d" % [uv2_count, CELLS])

	# UV2.x = donor tile id, UV2.y = face mode 0/1/2
	# (world3d_terrain.gd:691-708); no other face value is allowed.
	var bad_y := 0
	var min_x := INF
	var max_x := -INF
	var out_of_atlas := 0
	var face_hist := {}
	if uv2v is PackedVector2Array:
		var uv2: PackedVector2Array = uv2v
		for i in range(uv2.size()):
			var t: Vector2 = uv2[i]
			min_x = minf(min_x, t.x)
			max_x = maxf(max_x, t.x)
			if t.x < 0.0 or t.x > float(NAMED_CELLS - 1):
				out_of_atlas += 1
			var y := int(t.y)
			if y < 0 or y > 2 or absf(t.y - float(y)) > 0.001:
				bad_y += 1
			face_hist[str(y)] = int(face_hist.get(str(y), 0)) + 1
	_m["uv2_y_hist"] = face_hist
	_m["uv2_x_min"] = min_x
	_m["uv2_x_max"] = max_x
	_m["uv2_x_out_of_atlas"] = out_of_atlas
	check("uv2_y_face_modes", bad_y == 0,
		"non-0/1/2 UV2.y=%d hist=%s" % [bad_y, str(face_hist)])

	var promoted := _probe_flat_promotions()
	_m["flat_grid_promoted_cells"] = promoted
	check("flat_grid_promoted", promoted == 0,
		"perfectly flat %dx%d grid: promoted=%d (expected 0; t_smallmap_terrain.gd:150-171)" % [
			GRID_W, GRID_H, promoted])

	var res_nodes_v: Variant = _game.get("res_nodes") if _game != null else null
	var res_nodes: Array = res_nodes_v if res_nodes_v is Array else []
	_m["res_nodes_count"] = res_nodes.size()
	check("res_nodes_empty", res_nodes.is_empty(),
		"res_nodes=%d (expected 0 — no trees/mines/units in P0)" % res_nodes.size())

	var below := 0
	for i in range(CELLS):
		if _heights[i] < WATER_LEVEL:
			below += 1
	_m["cells_below_water_level"] = below
	_m["water_level_m"] = WATER_LEVEL
	_m["height_min_m"] = stats.get("height_min_m", -1.0)
	_m["height_max_m"] = stats.get("height_max_m", -1.0)
	check("no_water_cells", below == 0,
		"height < %.2f m: %d cells (expected 0)" % [WATER_LEVEL, below])

	var water_tiles := 0
	for i in range(CELLS):
		if int(_tileblock[i]) == BLK_WATER:
			water_tiles += 1
	_m["water_tileblock_cells"] = water_tiles
	check("no_water_tileblock", water_tiles == 0,
		"BLK_WATER=%d cells=%d (expected 0)" % [BLK_WATER, water_tiles])

	# Atlas grid from V7-85 manifest must match the shader parameter
	# (t_smallmap_terrain.gd:353-384); all three samplers must be bound.
	var at_v: Variant = stats.get("atlas", {})
	var at: Dictionary = at_v if at_v is Dictionary else {}
	var grid_v: Variant = at.get("grid", [])
	var grid: Array = grid_v if grid_v is Array else []
	var grid_ok: bool = grid.size() == 2 and int(grid[0]) == 16 and int(grid[1]) == 8
	var grid_param: Variant = null
	var samplers_ok := false
	var shader_shadow: Variant = null
	var mat: Material = mesh.surface_get_material(0) if mesh != null else null
	if mat is ShaderMaterial:
		var sm := mat as ShaderMaterial
		grid_param = sm.get_shader_parameter("atlas_grid")
		shader_shadow = sm.get_shader_parameter("shadow_enabled")
		samplers_ok = (sm.get_shader_parameter("tile_atlas") != null
			and sm.get_shader_parameter("alpha_atlas") != null
			and sm.get_shader_parameter("alphavert_atlas") != null)
	_m["atlas_grid"] = grid
	_m["atlas_grid_shader_param"] = str(grid_param)
	_m["atlas_mode"] = str(stats.get("atlas_mode", ""))
	_m["material_model"] = str(stats.get("material_model", "")).substr(0, 240)
	check("atlas_grid_manifest", grid_ok and grid_param is Vector2
		and (grid_param as Vector2).is_equal_approx(EXPECTED_GRID),
		"stats.grid=%s shader.atlas_grid=%s (expected [16,8] / (16,8))" % [
			str(grid), str(grid_param)])
	check("atlas_material_bound", mat is ShaderMaterial and samplers_ok,
		"material=%s tile/alpha/alphavert bound=%s" % [
			mat.get_class() if mat != null else "<none>", str(samplers_ok)])
	_m["shader_shadow_enabled"] = str(shader_shadow)
	check("shader_shadow_disabled", str(shader_shadow) == "0" or str(shader_shadow) == "0.0",
		"shader shadow_enabled=%s (expected 0; world3d_terrain.gd:315)" % str(shader_shadow))

	# Isolation step last: the module always creates a WaterPlane, but P0 must
	# not render a water layer (no shore row yet). Check order now matches
	# CHECK_NAMES (water_plane_hidden is index 16).
	_hide_water(parent)

	_setup_done = true
	if _headless:
		# State-only result. SKIP_CAPTURE is never presented as a visual PASS.
		finish()
		return
	if _png_path == "":
		check("capture_image", false, "windowed run needs --screenshot <abs.png> user arg")
		finish()
		return
	_capture_pending = true
	return


func _process(_delta: float) -> bool:
	if _finished or not _capture_pending or _capturing:
		return false
	_frame += 1
	if _frame >= CAPTURE_FRAMES:
		_capturing = true
		_capture_async()
	return false


# Stub-owned windowed GPU readback: no main.tscn, no main's --screenshot saver
# (TEST-01 §"Test ladder" P0 capture column; terrain3d_sandbox.gd:139-151).
func _capture_async() -> void:
	if _capture_view != null:
		_capture_view.render_target_update_mode = SubViewport.UPDATE_ONCE
	await RenderingServer.frame_post_draw
	if _finished:
		return
	var tex := _capture_view.get_texture() if _capture_view != null else null
	var img: Image = tex.get_image() if tex != null else null
	if img == null or img.is_empty():
		check("capture_image", false, "blank SubViewport texture — no CPU fallback (main.gd:1846-1853)")
		finish()
		return
	check("capture_image", true, "SubViewport texture %dx%d" % [img.get_width(), img.get_height()])
	var abs_png := _png_path
	if not abs_png.is_absolute_path() and not abs_png.begins_with("user://"):
		abs_png = ProjectSettings.globalize_path("res://").get_base_dir().path_join(abs_png)
	var dir := abs_png.get_base_dir()
	if dir != "" and not DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_recursive_absolute(dir)
	var err := img.save_png(abs_png)
	check("capture_saved", err == OK, "save_png(%s) err=%d" % [abs_png, err])
	if err != OK:
		finish()
		return
	var ms := _image_metrics(img)
	ms["png_path"] = abs_png
	ms["bytes"] = FileAccess.get_file_as_bytes(abs_png).size()
	_m["png_metrics"] = ms
	_m["capture_source"] = "TerrainOnlyViewport (stub-owned, windowed GPU)"
	check("non_black_fraction", float(ms["non_black_fraction"]) > 0.9,
		"non_black_fraction=%s (expected >0.9; smallmap_capture.py:26)" % str(ms["non_black_fraction"]))
	check("full_width_dark_rows", int(ms["full_width_dark_rows"]) == 0,
		"full_width_dark_rows=%d (expected 0; smallmap_capture.py:27-28)" % int(ms["full_width_dark_rows"]))
	_visual_checked = true
	finish()
