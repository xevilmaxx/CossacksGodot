# TEST-P1 / t_terrain_trees.gd — ISOLATED terrain + trees 64x64 atom.
#
# Owns ONLY this file (plus docs/coord_swarm_2026-11-25/reports/TEST_P1_report.md).
# No source, shader, asset, config, manifest, fixture, gate-file or git edit.
# AUTHORING ONLY: this file was never executed by this agent; no Godot job was
# submitted, no runner ticket was taken (docs/COMMANDS.md runner monopoly).
#
# Design sources (all read-only):
#   TEST-01 row P1 + §Scaffolding item 1 / §Blockers 10
#     docs/coord_swarm_2026-11-25/reports/TEST_01_smallmap_harness.md:213,:228-255,:299-301
#   TEST_MATRIX.md:19 (P1), :29-46 (V3D_02 T1 refinement), :54-58 (rules)
#   DTRN_04 §8 "precise criteria" T1-T10
#     docs/coord_swarm_2026-11-25/reports/DTRN_04_donor_trees.md:304-324
#   V3D_02 §"Piece-test ladder proposal" T1
#     docs/coord_swarm_2026-11-25/reports/V3D_02_terrain_render_audit.md:145
#   P0 baseline atom (read-only mirror of the exact same stub): t_terrain_only.gd
#     :44-86,:93-143,:248-316,:331-349,:385-594,:597-643
#   Shared helper API: tests/fixtures/_smallmap_harness.gd:14-70,:117-180
#   Terrain module: world3d_terrain.gd:93-95,:408-488,:624-903
#   Entities module: world3d_entities.gd:106-118,:711-757,:944-1015,:1060-1121,
#     :1269-1315,:1334-1564
#   Stub + dynamic load + deferred quit: t_terrain3d.gd:12-14,41-46,106-127;
#     _template_test.gd:1-38; t_pick3d.gd:48-71.
#
# SAME P0 FIXTURE: synthetic deterministic 64x64 grid, all-grass tileblock 0,
# no water cells, no units/buildings/FX. The ONLY delta is N=20 wood resource
# nodes at known cells, fed through world3d_entities.add_resource()/POOL_TREE.
# The shared helper is loaded dynamically (never class_name); if it is absent a
# local stub of the same shape is used and that is recorded in the result JSON.
#
# DONOR GUARD: ENV_SCALE["tree"]=0.5 is a PORT APPROXIMATION (one size for all
# species, world3d_entities.gd:113,:326-333). Do NOT assert donor scale parity.
# The donor scale ladder (0.341-0.76 + +/-15% jitter, envscales.cfg:158-188) and
# authored yaw (DTRN_04 C10/T4) are recorded as KNOWN_GAP, never as passes.
# No donor GPU A/B exists (V3D_02 parity_guard), so no visual parity is claimed.
extends SceneTree

const MODULE_TERRAIN := "res://scripts/world3d_terrain.gd"
const MODULE_ENTITIES := "res://scripts/world3d_entities.gd"
const CAMERA_PATH := "res://scripts/camera3d.gd"
const HARNESS_PATH := "res://tests/fixtures/_smallmap_harness.gd"
const OUT_PATH := "res://tests/results/t_terrain_trees.json"

const GRID_W := 64
const GRID_H := 64
const CELLS := GRID_W * GRID_H
const TILE_M := 2.0                 # data.gd:23 / game.gd:16
const WATER_LEVEL := -0.25          # world3d_terrain.gd:95 (donor literal UNVERIFIED)
const BLK_WATER := 255              # game.gd:52
const GRASS_TILE := 0               # presets_summer.json:2 grass1
const TREE_N := 20                  # TEST-01 P1 "N=~20"; stress case per DTRN_04 T2
const HEIGHT_EPS := 1e-3            # DTRN_04 T5 tolerance (m)
const WINDOW_SIZE := Vector2i(1280, 720)  # data.gd:113-114; no CLI flag
const CAPTURE_FRAMES := 10          # TEST_MATRIX.md:32 capture after ~10 frames
const DIFF_THRESHOLD := 8.0         # 0..255 channel delta, mirrors smallmap_capture.py
const FOOTPRINT_RADIUS_PX := 160    # generous tree silhouette/shadow footprint
const MAX_OUT_MASK_FRACTION := 0.10 # ground-only region must stay essentially unchanged
const MAX_NEW_BLACK_FRACTION := 0.005  # no opaque black rectangles (DTRN_04 T7)

# Live POOL_TREE (world3d_entities.gd:114-115). Any other sid means a leaked
# category (stone/ore/stump/food/proxy) and fails category purity (DTRN_04 T2).
const EXPECTED_TREE_SIDS := [
	"tree_spruce1", "tree_pine", "tree_fir",
	"tree_oak", "tree_spruce2", "tree_pinedry1",
]

# 20 distinct central cells (x,z). Centre of the 64x64 map is cell 31.5, so
# these are inside the fixed camera's framing and are all "known positions".
const TREE_CELLS := [
	[24, 24], [27, 26], [30, 25], [33, 27], [36, 24],
	[25, 29], [28, 31], [31, 30], [34, 32], [37, 29],
	[24, 34], [27, 36], [30, 35], [33, 37], [36, 34],
	[26, 39], [29, 38], [32, 39], [35, 38], [38, 36],
]

const CHECK_NAMES := [
	"harness_stub_shape",
	"terrain_module_api",
	"entities_module_api",
	"camera_module_api",
	"build_ok",
	"surface_count",
	"vertex_count",
	"triangle_count",
	"uv2_count",
	"uv2_y_face_modes",
	"flat_grid_promoted",
	"no_water_cells",
	"no_water_tileblock",
	"water_plane_hidden",
	"tree_nodes_bound",
	"tree_instance_count",
	"category_purity",
	"tree_height_snap",
	"trees_above_water",
	"no_non_tree_batches",
	"capture_image",
	"capture_saved",
	"png_differs_from_p0",
	"diff_confined_to_tree_footprints",
	"no_new_black_blocks",
	"no_full_width_dark_rows",
	# DARKROW-ALL-01: strict, applicable whole-frame luma gates (P0-GATE-01).
	"ground_mean_luma",
	"ground_max_luma",
	"draw_calls_recorded",
	"frame_time_recorded",
	# Donor-grounded observations, deliberately NOT asserted (KNOWN_GAP / note).
	"donor_scale_ladder",
	"donor_yaw_bins",
	"donor_passability",
	"donor_visual_review",
	"script_error_scan_external",
]

# Local fallback stub. Deliberately the same shape as the shared helper's
# StubGame (tests/fixtures/_smallmap_harness.gd:14-70): a Node with MAP_W/MAP_H,
# height/tileblock/dump, res_nodes/res_dirty/entities, cmd_* counters and a
# bilinear height_at(p). NOT used when the shared helper loads successfully.
class LocalStubGame extends Node:
	var MAP_W: int = 0
	var MAP_H: int = 0
	var map_w: int = 0
	var map_h: int = 0
	var height := PackedFloat32Array()
	var tileblock := PackedByteArray()
	var dump: Dictionary = {}
	var res_nodes: Array = []
	var res_dirty: int = 0
	var entities: Array = []
	var units: Array = []
	var buildings: Array = []
	var cmd_calls: Dictionary = {}

	func _bump(m: String) -> void:
		cmd_calls[m] = int(cmd_calls.get(m, 0)) + 1

	func total_cmd_calls() -> int:
		var n := 0
		for v in cmd_calls.values():
			n += int(v)
		return n

	func pick_radius(_e: Dictionary) -> float:
		return 1.0

	func resolve_mine_sid(_sid: String, _pos: Vector2) -> String:
		return ""

	# game.gd:1893-1907 recipe, SIM metres / top-left origin.
	func height_at(p: Vector2) -> float:
		var n: int = MAP_W * MAP_H
		if n <= 0 or height.size() < n:
			return 0.0
		var fx := clampf(p.x / TILE_M - 0.5, 0.0, float(MAP_W - 1) - 0.001)
		var fz := clampf(p.y / TILE_M - 0.5, 0.0, float(MAP_H - 1) - 0.001)
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

	func cmd_sow(_a = null, _b = null, _c = null) -> int:
		_bump("cmd_sow")
		return 0

	func cmd_move(_a = null, _b = null, _c = null) -> void:
		_bump("cmd_move")

	func cmd_attack(_a = null, _b = null, _c = null) -> void:
		_bump("cmd_attack")

	func cmd_attack_move(_a = null, _b = null, _c = null) -> void:
		_bump("cmd_attack_move")

	func cmd_gather(_a = null, _b = null, _c = null) -> void:
		_bump("cmd_gather")

	func cmd_build(_a = null, _b = null, _c = null) -> void:
		_bump("cmd_build")

	func cmd_delete(_a = null, _b = null, _c = null) -> void:
		_bump("cmd_delete")

var _id := "t_terrain_trees"
var _checks: Array[Dictionary] = []
var _ok := true
var _finished := false
var _setup_done := false
var _visual_checked := false
var _headless := false
var _png_path := ""
var _p0_png_path := ""
var _capture_view: SubViewport = null
var _terrain: Node = null
var _entities: Node = null
var _camera: Camera3D = null
var _game: Object = null
var _harness_source := ""
var _heights := PackedFloat32Array()
var _tileblock := PackedByteArray()
var _tree_nodes: Array = []
var _tree_pos_by_id: Dictionary = {}
var _tree_world: Array[Vector3] = []
var _tree_screen: Array[Vector2] = []
var _frame := 0
var _capture_pending := false
var _capturing := false
var _perf: Array = []          # [draw_calls, process_time_s, delta_s]
var _m: Dictionary = {}


# Variant `cond`: explicit null + a status string records a KNOWN_GAP / SKIP
# without flipping _ok (same convention as P0 t_terrain_only.gd:165-174).
func check(name: String, cond, detail: String = "", status: String = "") -> void:
	var st := status
	if st == "":
		st = "PASS" if cond == true else ("FAIL" if cond == false else "SKIPPED")
	_checks.append({"name": name, "passed": cond, "status": st, "detail": detail})
	if cond == false:
		_ok = false
	print("T_TERRAIN_TREES %s %s - %s" % [st, name, detail])


func _fail_remaining(from_index: int, tag: String, reason: String) -> void:
	for i in range(from_index, CHECK_NAMES.size()):
		check(CHECK_NAMES[i], false, tag + ": " + reason)


func _verdict() -> String:
	if not _ok:
		return "FAIL"
	# No full PASS on a headless / no-P0-baseline run: the PNG assertions were
	# not evaluated, so never present that as a visual PASS.
	return "PASS" if _visual_checked else "SKIP_CAPTURE"


func _perf_totals() -> Dictionary:
	var n := maxi(_perf.size(), 1)
	var dc := 0.0
	var pt := 0.0
	var dt := 0.0
	for s in _perf:
		dc += float(s[0])
		pt += float(s[1])
		dt += float(s[2])
	return {
		"samples": _perf.size(),
		"draw_calls_avg": dc / float(n),
		"draw_calls_last": float((_perf[_perf.size() - 1])[0]) if not _perf.is_empty() else 0.0,
		"process_time_ms_avg": pt / float(n) * 1000.0,
		"frame_delta_ms_avg": dt / float(n) * 1000.0,
	}


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
	var pf := _perf_totals()
	_m["performance"] = pf
	check("draw_calls_recorded", pf["samples"] > 0,
		"RENDER_TOTAL_DRAW_CALLS_IN_FRAME avg=%s last=%s samples=%d (windowed GPU if >0)" % [
			str(pf["draw_calls_avg"]), str(pf["draw_calls_last"]), int(pf["samples"])])
	check("frame_time_recorded", pf["samples"] > 0,
		"process_ms_avg=%s frame_delta_ms_avg=%s" % [
			str(pf["process_time_ms_avg"]), str(pf["frame_delta_ms_avg"])])
	# Re-count after the two telemetry checks.
	passes = 0
	fails = 0
	skips = 0
	for c in _checks:
		if c.get("passed") == true:
			passes += 1
		elif c.get("passed") == false:
			fails += 1
		else:
			skips += 1
	verdict = _verdict()
	var out := {
		"id": _id,
		"passed": verdict == "PASS",
		"verdict": verdict,
		"capture_status": "PASS" if _visual_checked else "SKIP_CAPTURE",
		"structural_ok": _ok,
		"passes": passes,
		"fails": fails,
		"skipped_or_notes": skips,
		"checks": _checks,
		"measured": _m,
		"harness_source": _harness_source,
		"png_path": _png_path,
		"p0_png_path": _p0_png_path,
		"skip_reason": ("" if _visual_checked else
			"headless or no comparable P0 PNG: state-only result, PNG diff not evaluated"),
		"script_error_note": "verify via smallmap_capture.py scan-stderr on runner stderr.txt",
		"parity_label": "PORT APPROX — internal consistency only; no donor GPU A/B (V3D_02 parity_guard)",
		"env_scale_note": ("ENV_SCALE['tree']=0.5 is a PORT APPROXIMATION; all POOL_TREE "
			+ "sids share one size (world3d_entities.gd:113,:326-333). Donor ladder "
			+ "0.341-0.76 with +/-15% jitter (DTRN_04 C3/C4) is NOT asserted."),
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
		push_error("t_terrain_trees: cannot write result: " + abs_path)
	print("T_TERRAIN_TREES RESULT_JSON: " + abs_path)
	print("T_TERRAIN_TREES RESULT: %s %d/%d evaluated, %d skipped/noted" % [
		verdict, passes, passes + fails, skips])
	call_deferred("quit", 0 if _ok else 1)


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


func _default_p0_png(p: String) -> String:
	if p == "":
		return ""
	var s := p
	if s.ends_with(".png"):
		s = s.substr(0, s.length() - 4)
	if s.ends_with("_terrain_trees"):
		return s.substr(0, s.length() - "_terrain_trees".length()) + "_terrain_only.png"
	if s.ends_with("_trees"):
		return s.substr(0, s.length() - "_trees".length()) + "_only.png"
	return ""


func _abs_path(p: String) -> String:
	if p == "":
		return ""
	if p.is_absolute_path() or p.begins_with("user://"):
		return p
	return ProjectSettings.globalize_path("res://").get_base_dir().path_join(p)


func _sample_perf(delta: float = 0.0) -> void:
	_perf.append([
		float(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)),
		float(Performance.get_monitor(Performance.TIME_PROCESS)),
		delta,
	])


# Exact P0 fixture (t_terrain_only.gd:257-266): mild relief, all grass id 0.
func _make_grid() -> void:
	_heights.resize(CELLS)
	_tileblock.resize(CELLS)
	for z in range(GRID_H):
		for x in range(GRID_W):
			var i := z * GRID_W + x
			_heights[i] = 1.5 + 0.03 * sin(float(x) * 0.11) + 0.02 * cos(float(z) * 0.09)
			_tileblock[i] = GRASS_TILE


# The ONLY delta vs P0: N wood nodes at known cells (DTRN_04 T2/T5/T6).
func _make_tree_nodes() -> void:
	_tree_nodes.clear()
	_tree_pos_by_id.clear()
	for i in range(TREE_N):
		var cell: Array = TREE_CELLS[i]
		var cx := int(cell[0])
		var cz := int(cell[1])
		var p := Vector2((float(cx) + 0.5) * TILE_M, (float(cz) + 0.5) * TILE_M)
		var id := 9000 + i
		var node := {
			"id": id,
			"kind": "res",
			"type": "wood",            # world3d_entities.gd:1271 -> POOL_TREE
			"pos": p,
			"hits": 1,
			"max_hits": 1,             # _is_hidden() false (:1082-1091)
			"dead": false,
			"hidden": false,
		}
		_tree_nodes.append(node)
		_tree_pos_by_id[id] = p
	# The stub is built after this function (see _make_stub_game); both the
	# shared helper and the embedded fallback receive this exact array.


# TEST-01 §Scaffolding: use the shared helper via dynamic load(); fall back to
# the embedded stub and record which path was taken (Blockers 10: no class_name).
func _make_stub_game() -> Object:
	if ResourceLoader.exists(HARNESS_PATH):
		var helper: Object = load(HARNESS_PATH)
		if helper != null and helper.has_method("make_stub_game"):
			var g: Object = helper.call("make_stub_game", GRID_W, GRID_H,
				_heights, _tree_nodes, _tileblock)
			if g != null and is_instance_valid(g):
				_harness_source = "shared:" + HARNESS_PATH
				return g
	var local := LocalStubGame.new()
	local.MAP_W = GRID_W
	local.MAP_H = GRID_H
	local.map_w = GRID_W
	local.map_h = GRID_H
	local.height = _heights
	local.tileblock = _tileblock
	local.res_nodes = _tree_nodes
	local.dump = {
		"map_w": GRID_W,
		"map_h": GRID_H,
		"height": Marshalls.raw_to_base64(_heights.to_byte_array()),
		"tileblock": Marshalls.raw_to_base64(_tileblock),
	}
	_harness_source = "embedded_local_stub"
	return local


func _probe_flat_promotions() -> int:
	var scr := load(MODULE_TERRAIN) as Script
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


func _api_ok(script_path: String, methods: Array) -> bool:
	var scr := load(script_path) as Script
	if scr == null or not scr.can_instantiate():
		return false
	var probe: Object = scr.new()
	if probe == null:
		return false
	var missing: Array[String] = []
	for meth in methods:
		if not probe.has_method(meth):
			missing.append(str(meth))
	probe.free()
	_m["api_missing_" + script_path.get_file()] = missing
	return missing.is_empty()


# P1's structural core: find the resident full-grid terrain mesh by vertex
# count; the water quad is only 4 verts so it can never win (t_terrain3d.gd:130-151).
func _find_terrain_mesh(root: Node) -> MeshInstance3D:
	var best: MeshInstance3D = null
	var best_verts := -1
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n is MeshInstance3D:
			var mi := n as MeshInstance3D
			var m: Mesh = mi.mesh
			if m is ArrayMesh and m.get_surface_count() > 0:
				var arr: Array = m.surface_get_arrays(0)
				var vs: Variant = arr[Mesh.ARRAY_VERTEX] if arr.size() > Mesh.ARRAY_VERTEX else null
				var count: int = (vs as PackedVector3Array).size() if vs is PackedVector3Array else 0
				if count > best_verts:
					best_verts = count
					best = mi
		for c in n.get_children():
			stack.append(c)
	return best


# Count `Batch_res_*` MultiMesh instances and verify every sid is a POOL_TREE
# member (category purity, DTRN_04 T2). The multi-mesh node name is built at
# world3d_entities.gd:966 ("Batch_" + key.replace("|","_") + "_" + tag).
func _inspect_batches() -> Dictionary:
	var total := 0
	var sids: Array[String] = []
	var non_tree: Array[String] = []
	var other_batches: Array[String] = []
	for n in _entities.get_children():
		var nm := str(n.name)
		if not (n is MultiMeshInstance3D):
			continue
		if nm.begins_with("Batch_unit_") or nm.begins_with("Batch_building_"):
			other_batches.append(nm)
			continue
		if not nm.begins_with("Batch_res_"):
			other_batches.append(nm)
			continue
		var rest := nm.trim_prefix("Batch_res_")
		var cut := rest.rfind("_STATIC_POSE")
		var sid := rest.substr(0, cut) if cut >= 0 else rest
		sids.append(sid)
		if not EXPECTED_TREE_SIDS.has(sid):
			non_tree.append(sid)
		var mm: MultiMesh = (n as MultiMeshInstance3D).multimesh
		total += int(mm.visible_instance_count) if mm != null else 0
	return {"instances": total, "sids": sids, "non_tree_sids": non_tree,
		"other_batches": other_batches}


# Read the CPU transform mirror at world3d_entities.gd:977-981,1047-1048.
# MultiMesh.get_instance_transform() is identity under the headless dummy
# RenderingServer, so the mirror is the only same-frame source of tree Y and
# world position (DTRN_04 T5).
func _inspect_tree_y() -> Dictionary:
	var batches_v: Variant = _entities.get("_batches")
	if not (batches_v is Dictionary):
		return {"ok": false, "reason": "_batches CPU mirror unavailable", "max_err": -1.0}
	var batches: Dictionary = batches_v
	var max_err := 0.0
	var worst := ""
	var below := 0
	_tree_world.clear()
	for key in batches.keys():
		var b: Dictionary = batches[key]
		var ids: Array = b["ids"]
		var xforms: Array = b["xforms"]
		for i in range(ids.size()):
			var id := int(ids[i])
			if not _tree_pos_by_id.has(id):
				continue
			var xf: Transform3D = xforms[i]
			var y := xf.origin.y
			var pos: Vector2 = _tree_pos_by_id[id]
			var y_sim := float(_game.call("height_at", pos))
			var world := Vector2(pos.x - float(GRID_W) * TILE_M * 0.5,
				pos.y - float(GRID_H) * TILE_M * 0.5)
			var y_terrain := float(_terrain.call("height_at_world", world))
			var err := maxf(absf(y - y_sim), absf(y - y_terrain))
			if err > max_err:
				max_err = err
				worst = "id=%d y=%s height_at=%s height_at_world=%s" % [
					id, str(y), str(y_sim), str(y_terrain)]
			if y <= WATER_LEVEL:
				below += 1
			_tree_world.append(xf.origin)
	return {"ok": true, "max_err": max_err, "worst": worst,
		"below_water": below, "count": _tree_world.size()}


func _project_tree_centres() -> void:
	_tree_screen.clear()
	if _camera == null:
		return
	for w in _tree_world:
		var s: Variant = _camera.unproject_position(w)
		if s is Vector2:
			_tree_screen.append(s as Vector2)


# Pixel diff against the P0 PNG. "ground-only mask" = complement of a dilated
# tree-silhouette mask. differences outside it must be negligible (DTRN_04 T7);
# differences inside it prove the trees actually rendered (TEST-01 P1).
func _compare_png(p1_path: String, p0_path: String) -> void:
	var p1 := Image.new()
	var p0 := Image.new()
	var e1 := p1.load(p1_path)
	var e0 := p0.load(p0_path)
	_m["png_load_errors"] = {"p1": int(e1), "p0": int(e0)}
	if e1 != OK or e0 != OK:
		check("png_differs_from_p0", null,
			"PNG load failed p1=%d p0=%d" % [int(e1), int(e0)], "SKIPPED_NO_BASELINE")
		return
	if p0.get_width() != p1.get_width() or p0.get_height() != p1.get_height():
		p0.resize(p1.get_width(), p1.get_height(), Image.INTERPOLATE_BILINEAR)
		_m["p0_resized_to_match"] = true
	var w := p1.get_width()
	var h := p1.get_height()
	var mask := PackedByteArray()
	mask.resize(w * h)   # PackedByteArray initialises to 0 = ground-only
	var r := FOOTPRINT_RADIUS_PX
	for c in _tree_screen:
		var ccx := int(c.x)
		var ccy := int(c.y)
		for dy in range(-r, r + 1):
			for dx in range(-r, r + 1):
				if dx * dx + dy * dy > r * r:
					continue
				var px := ccx + dx
				var py := ccy + dy
				if px >= 0 and px < w and py >= 0 and py < h:
					mask[py * w + px] = 1
	var changed := 0
	var changed_in := 0
	var changed_out := 0
	var new_black := 0
	var dark_rows := 0
	var luma_sum := 0.0
	var max_luma := 0.0
	for y in range(h):
		var row_dark := 0
		for x in range(w):
			var a := p1.get_pixel(x, y)
			var b := p0.get_pixel(x, y)
			var d := maxf(absf(a.r - b.r),
				maxf(absf(a.g - b.g), absf(a.b - b.b))) * 255.0
			var i := y * w + x
			if d > DIFF_THRESHOLD:
				changed += 1
				if mask[i] == 1:
					changed_in += 1
				else:
					changed_out += 1
			var l1 := 0.2126 * a.r * 255.0 + 0.7152 * a.g * 255.0 + 0.0722 * a.b * 255.0
			var l0 := 0.2126 * b.r * 255.0 + 0.7152 * b.g * 255.0 + 0.0722 * b.b * 255.0
			luma_sum += l1
			if l1 > max_luma:
				max_luma = l1
			if l1 < 8.0 and l0 >= 8.0:
				new_black += 1
			if l1 < 20.0:
				row_dark += 1
		if float(row_dark) / float(maxi(w, 1)) > 0.90:
			dark_rows += 1
	var total := float(maxi(w * h, 1))
	var out_frac := float(changed_out) / total
	var black_frac := float(new_black) / total
	_m["png_diff"] = {
		"p1": p1_path, "p0": p0_path, "width": w, "height": h,
		"changed_pixels": changed, "changed_fraction": float(changed) / total,
		"changed_in_tree_footprint": changed_in,
		"changed_outside_ground_only_mask": changed_out,
		"changed_outside_fraction": out_frac,
		"new_black_pixels": new_black, "new_black_fraction": black_frac,
		"full_width_dark_rows": dark_rows,
		"mean_luma": luma_sum / total,
		"max_luma": max_luma,
		"footprint_radius_px": r, "threshold_0_255": DIFF_THRESHOLD,
		"mask_model": "complement of dilated per-tree silhouette circles (PORT APPROX)",
	}
	check("png_differs_from_p0", changed > 0,
		"changed=%d of %d (%.4f), inside_footprint=%d — trees rendered vs P0" % [
			changed, w * h, float(changed) / total, changed_in])
	check("diff_confined_to_tree_footprints",
		changed_in > 0 and out_frac <= MAX_OUT_MASK_FRACTION,
		"inside=%d outside=%d outside_fraction=%.5f (cap %.3f); ground-only region unchanged" % [
			changed_in, changed_out, out_frac, MAX_OUT_MASK_FRACTION])
	check("no_new_black_blocks", black_frac <= MAX_NEW_BLACK_FRACTION,
		"new_black=%d fraction=%.5f (cap %.4f) — no opaque black rectangles" % [
			new_black, black_frac, MAX_NEW_BLACK_FRACTION])
	# DARKROW-ALL-01 — P0-GATE-01 applicability correction. P1 is ground+trees
	# with no water layer; the row predicate was authored to detect water bands
	# (V3D_02 P6/F6; DTRN_03 W2/M5), so it is recorded, not a pass/fail gate.
	check("no_full_width_dark_rows", null,
		"full_width_dark_rows=%d RECORDED_NOT_APPLICABLE (no water layer in P1; diagnostic only, not a pass/fail gate)" % dark_rows,
		"RECORDED_NOT_APPLICABLE")
	# Strict, applicable whole-frame luma gates (P0-GATE-01). PORT APPROX —
	# no donor GPU A/B exists. Thresholds are NOT lowered to fit a dark frame.
	check("ground_mean_luma", luma_sum / total >= 40.0,
		"mean_luma=%.3f (strict >=40; PORT APPROX — no donor GPU A/B exists)" % (luma_sum / total))
	check("ground_max_luma", max_luma >= 100.0,
		"max_luma=%.3f (strict >=100; PORT APPROX — no donor GPU A/B exists)" % max_luma)
	_visual_checked = true


func _initialize() -> void:
	if _finished:
		return
	call_deferred("_failsafe")

	_headless = DisplayServer.get_name() == "headless"
	_png_path = _arg_value("--screenshot")
	if _png_path == "":
		_png_path = _arg_value("--png")
	_p0_png_path = _arg_value("--p0-png")
	if _p0_png_path == "":
		_p0_png_path = _default_p0_png(_png_path)
	_m["display_server"] = DisplayServer.get_name()
	_m["headless"] = _headless
	_m["requested_png"] = _png_path
	_m["requested_p0_png"] = _p0_png_path

	_make_grid()
	_make_tree_nodes()
	_game = _make_stub_game()
	_m["harness_source"] = _harness_source
	var shape_ok: bool = (_game != null and is_instance_valid(_game)
		and int(_game.get("MAP_W")) == GRID_W and int(_game.get("MAP_H")) == GRID_H
		and (_game.get("height") is PackedFloat32Array)
		and (_game.get("tileblock") is PackedByteArray)
		and (_game.get("res_nodes") is Array)
		and int((_game.get("res_nodes") as Array).size()) == TREE_N)
	check("harness_stub_shape", shape_ok,
		"source=%s MAP=%dx%d res_nodes=%d height/tileblock/dump present=%s" % [
			_harness_source,
			str(_game.get("MAP_W")) if _game != null else "<none>",
			str(_game.get("MAP_H")) if _game != null else "<none>",
			int((_game.get("res_nodes") as Array).size()) if _game != null and _game.get("res_nodes") is Array else -1,
			str(shape_ok)])
	_m["input_categories"] = {}
	if ResourceLoader.exists(HARNESS_PATH):
		var helper: Object = load(HARNESS_PATH)
		if helper != null and helper.has_method("count_categories"):
			_m["input_categories"] = helper.call("count_categories", _tree_nodes)
	if not shape_ok:
		_fail_remaining(1, "STUB_SHAPE", "harness stub does not expose the expected shape")
		_setup_done = true
		finish()
		return

	var terrain_api := _api_ok(MODULE_TERRAIN,
		["bind", "build", "invalidate", "has_chunk_or_fallback", "height_at_world"])
	check("terrain_module_api", terrain_api,
		"script=%s missing=%s" % [MODULE_TERRAIN, str(_m.get("api_missing_world3d_terrain.gd", []))])
	var entities_api := _api_ok(MODULE_ENTITIES,
		["bind", "sync", "add_unit", "add_building", "add_resource", "remove"])
	check("entities_module_api", entities_api,
		"script=%s missing=%s" % [MODULE_ENTITIES, str(_m.get("api_missing_world3d_entities.gd", []))])
	var camera_api := _api_ok(CAMERA_PATH,
		["bind", "world_to_px", "screen_to_world", "set_zoom_target"])
	check("camera_module_api", camera_api,
		"script=%s missing=%s" % [CAMERA_PATH, str(_m.get("api_missing_camera3d.gd", []))])
	if not terrain_api or not entities_api or not camera_api:
		_fail_remaining(4, "MODULE_MISSING", "terrain/entities/camera script or API unavailable")
		_setup_done = true
		finish()
		return

	# Same stub-owned windowed SubViewport as P0 (t_terrain_only.gd:418-428).
	if not _headless:
		get_root().size = WINDOW_SIZE
		_capture_view = SubViewport.new()
		_capture_view.name = "TerrainTreesViewport"
		_capture_view.world_3d = World3D.new()
		_capture_view.size = WINDOW_SIZE
		_capture_view.render_target_update_mode = SubViewport.UPDATE_ONCE
		get_root().add_child(_capture_view)
	var parent: Node = _capture_view if _capture_view != null else get_root()

	var tscr := load(MODULE_TERRAIN) as Script
	_terrain = tscr.new() as Node
	_terrain.name = "HeightmapTerrainModule"
	parent.add_child(_terrain)
	_terrain.call("bind", _game)
	var built := bool(_terrain.call("build"))
	check("build_ok", built, "world3d_terrain.build() returned " + str(built))
	if not built:
		_fail_remaining(5, "SETUP_FAILED", "build() returned false")
		_setup_done = true
		finish()
		return

	var esrc := load(MODULE_ENTITIES) as Script
	_entities = esrc.new() as Node
	_entities.name = "EntitiesModule"
	parent.add_child(_entities)
	_entities.call("bind", _game)
	for n in _tree_nodes:
		_entities.call("add_resource", n)
	_entities.call("sync", 0.0)   # populates stats["resources"], no animation needed
	_m["entities_stats_resources"] = int((_entities.get("stats") as Dictionary).get("resources", -1))

	var cscr := load(CAMERA_PATH) as Script
	_camera = cscr.new() as Camera3D
	_camera.name = "DonorCamera"
	parent.add_child(_camera)
	_camera.call("bind", _game)
	_camera.set_process(false)   # freeze framing (camera3d.gd:484-581)
	_camera.make_current()
	_hide_water(parent)

	# --- P0 mesh invariants must be byte-for-byte unchanged -------------------
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
	var bad_y := 0
	var face_hist := {}
	if uv2v is PackedVector2Array:
		var uv2: PackedVector2Array = uv2v
		for i in range(uv2.size()):
			var y := int(uv2[i].y)
			if y < 0 or y > 2 or absf(uv2[i].y - float(y)) > 0.001:
				bad_y += 1
			face_hist[str(y)] = int(face_hist.get(str(y), 0)) + 1
	_m["uv2_y_hist"] = face_hist
	check("uv2_y_face_modes", bad_y == 0,
		"non-0/1/2 UV2.y=%d hist=%s" % [bad_y, str(face_hist)])
	var promoted := _probe_flat_promotions()
	_m["flat_grid_promoted_cells"] = promoted
	check("flat_grid_promoted", promoted == 0,
		"perfectly flat %dx%d grid promoted=%d (expected 0)" % [GRID_W, GRID_H, promoted])
	var below := 0
	for i in range(CELLS):
		if _heights[i] < WATER_LEVEL:
			below += 1
	_m["cells_below_water_level"] = below
	check("no_water_cells", below == 0, "cells below %.2f m = %d (expected 0)" % [WATER_LEVEL, below])
	var water_tiles := 0
	for i in range(CELLS):
		if int(_tileblock[i]) == BLK_WATER:
			water_tiles += 1
	_m["water_tileblock_cells"] = water_tiles
	check("no_water_tileblock", water_tiles == 0, "BLK_WATER cells=%d" % water_tiles)

	# --- P1 delta: tree instances, purity, height snap ------------------------
	check("tree_nodes_bound", int((_game.get("res_nodes") as Array).size()) == TREE_N,
		"res_nodes=%d (expected %d wood nodes)" % [
			int((_game.get("res_nodes") as Array).size()), TREE_N])
	var bd := _inspect_batches()
	_m["tree_batch_sids"] = bd["sids"]
	_m["tree_batch_count"] = bd["sids"].size()
	_m["tree_batch_instances"] = bd["instances"]
	check("tree_instance_count", int(bd["instances"]) == TREE_N,
		"visible tree instances=%d expected=%d; sids=%s" % [
			int(bd["instances"]), TREE_N, str(bd["sids"])])
	check("category_purity",
		bd["non_tree_sids"].is_empty() and not bd["sids"].is_empty(),
		"non-POOL_TREE sids=%s (stone/ore/stump/food/proxy forbidden); pools=%s" % [
			str(bd["non_tree_sids"]), str(EXPECTED_TREE_SIDS)])
	check("no_non_tree_batches", (bd["other_batches"] as Array).is_empty(),
		"unit/building/other batches=%s (P1 has no units/buildings)" % str(bd["other_batches"]))
	var yrep := _inspect_tree_y()
	_m["tree_height_snap"] = yrep
	check("tree_height_snap", bool(yrep.get("ok", false))
		and int(yrep.get("count", 0)) == TREE_N
		and float(yrep.get("max_err", -1.0)) <= HEIGHT_EPS,
		"max |Y - height_at / height_at_world| = %s m (eps=%s), instances=%d, worst=%s" % [
			str(yrep.get("max_err", -1.0)), str(HEIGHT_EPS),
			int(yrep.get("count", 0)), str(yrep.get("worst", ""))])
	check("trees_above_water", int(yrep.get("below_water", -1)) == 0,
		"trees at/below %.2f m = %d (expected 0)" % [WATER_LEVEL, int(yrep.get("below_water", -1))])

	# --- donor-grounded observations that are NOT assertions (DTRN_04 §8) -----
	check("donor_scale_ladder", null,
		"KNOWN_GAP: ENV_SCALE['tree']=0.5 collapses all species (world3d_entities.gd:113,:326-333); "
		+ "donor 0.341-0.76 + +/-15% jitter (DTRN_04 C3/C4) NOT asserted for parity", "KNOWN_GAP")
	check("donor_yaw_bins", null,
		"KNOWN_GAP: resource _xf() yaw is always 0 (world3d_entities.gd:1094-1121); "
		+ "donor >=6 distinct 30-deg bins (DTRN_04 T4) NOT asserted", "KNOWN_GAP")
	check("donor_passability", null,
		"NOT_ASSERTED: stub has no is_blocked(); DTRN_04 T6 reserved for real-game row", "NOT_ASSERTED")
	check("donor_visual_review", null,
		"SECOND_AGENT_REQUIRED: silhouette/canopy/shadow review (DTRN_04 T10); "
		+ "no donor GPU A/B exists (V3D_02 parity_guard)", "SECOND_AGENT_REQUIRED")
	check("script_error_scan_external", null,
		"verify via smallmap_capture.py scan-stderr on runner stderr.txt (DTRN_04 T9)", "EXTERNAL")

	_sample_perf(0.0)
	_setup_done = true
	if _headless:
		check("capture_image", null,
			"DisplayServer.get_name()==headless: GPU readback skipped (TEST-01 Blockers 2)",
			"SKIP_CAPTURE_HEADLESS")
		check("png_differs_from_p0", null, "headless: no P1 PNG to diff", "SKIP_CAPTURE_HEADLESS")
		check("diff_confined_to_tree_footprints", null, "headless", "SKIP_CAPTURE_HEADLESS")
		check("no_new_black_blocks", null, "headless", "SKIP_CAPTURE_HEADLESS")
		check("no_full_width_dark_rows", null, "headless", "SKIP_CAPTURE_HEADLESS")
		check("ground_mean_luma", null, "headless", "SKIP_CAPTURE_HEADLESS")
		check("ground_max_luma", null, "headless", "SKIP_CAPTURE_HEADLESS")
		finish()
		return
	if _png_path == "":
		check("capture_image", null,
			"windowed run needs --screenshot <abs.png> or --png <abs.png> user arg",
			"SKIP_CAPTURE_NO_PATH")
		check("png_differs_from_p0", null, "no P1 PNG", "SKIP_CAPTURE_NO_PATH")
		check("diff_confined_to_tree_footprints", null, "no P1 PNG", "SKIP_CAPTURE_NO_PATH")
		check("no_new_black_blocks", null, "no P1 PNG", "SKIP_CAPTURE_NO_PATH")
		check("no_full_width_dark_rows", null, "no P1 PNG", "SKIP_CAPTURE_NO_PATH")
		check("ground_mean_luma", null, "no P1 PNG", "SKIP_CAPTURE_NO_PATH")
		check("ground_max_luma", null, "no P1 PNG", "SKIP_CAPTURE_NO_PATH")
		finish()
		return
	_project_tree_centres()
	_m["tree_screen_centres"] = _tree_screen
	_capture_pending = true


func _process(delta: float) -> bool:
	if _finished or not _capture_pending or _capturing:
		return false
	_frame += 1
	_sample_perf(delta)
	if _frame >= CAPTURE_FRAMES:
		_capturing = true
		_capture_async()
	return false


# Stub-owned windowed GPU readback (P0 t_terrain_only.gd:607-643;
# terrain3d_sandbox.gd:139-151; testbridge.gd:277-308). No main.tscn boot.
func _capture_async() -> void:
	if _capture_view != null:
		_capture_view.render_target_update_mode = SubViewport.UPDATE_ONCE
	await RenderingServer.frame_post_draw
	if _finished:
		return
	var tex := _capture_view.get_texture() if _capture_view != null else null
	var img: Image = tex.get_image() if tex != null else null
	if img == null or img.is_empty():
		check("capture_image", false,
			"blank SubViewport texture — no CPU fallback (main.gd:1846-1853)")
		finish()
		return
	check("capture_image", true, "SubViewport texture %dx%d" % [img.get_width(), img.get_height()])
	var abs_png := _abs_path(_png_path)
	var dir := abs_png.get_base_dir()
	if dir != "" and not DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_recursive_absolute(dir)
	var err := img.save_png(abs_png)
	check("capture_saved", err == OK, "save_png(%s) err=%d" % [abs_png, err])
	if err != OK:
		finish()
		return
	_m["png_path_absolute"] = abs_png
	_m["capture_source"] = "TerrainTreesViewport (stub-owned, windowed GPU)"
	_m["capture_frame"] = _frame
	var p0_abs := _abs_path(_p0_png_path)
	if p0_abs == "" or not FileAccess.file_exists(p0_abs):
		for n in ["png_differs_from_p0", "diff_confined_to_tree_footprints",
				"no_new_black_blocks", "no_full_width_dark_rows"]:
			check(n, null,
				"SKIPPED_NO_BASELINE: P0 PNG not found at '%s' (supply --p0-png <abs.png>)" % p0_abs,
				"SKIPPED_NO_BASELINE")
	else:
		_compare_png(abs_png, p0_abs)
	finish()
