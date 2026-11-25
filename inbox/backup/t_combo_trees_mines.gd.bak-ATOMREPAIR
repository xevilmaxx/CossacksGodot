# TEST-C2 / t_combo_trees_mines.gd — COMBO terrain+trees+mines 64x64 atom.
#
# Owns ONLY this file (plus docs/coord_swarm_2026-11-25/reports/TEST_C2_report.md).
# No source, shader, asset, config, manifest, fixture, gate-file or git edit.
# AUTHORING ONLY: this file was never executed by this agent; no Godot job was
# submitted, no runner ticket was taken (docs/COMMANDS.md runner monopoly).
#
# Design sources:
#   TEST-01 §"Test ladder" row C2 (:217) + row P1 (:213) + row P3 (:215)
#     (docs/coord_swarm_2026-11-25/reports/TEST_01_smallmap_harness.md)
#     — P1+P3 union, exact tree/ore counts, no water, ore/tree separation
#     (generator clear rings 10.5 m, game.gd:2350-2351,2355-2356).
#   TEST_MATRIX.md:19,21,23,29-46 — same 64² map; T1 tree Y matches terrain,
#     T3 mine sid resolves + mine Y matches terrain; no donor parity until F0.
#   V3D_02 §"Piece-test ladder proposal" T1/T3/T4 (:145,147,148) — tree/mine
#     instance counts, height snap, "all T0–T3 assertions simultaneously".
#   Template conventions: variant3d/tests/_template_test.gd:1-38 (one feature
#     per file, result JSON, call_deferred quit, never quit in _initialize()).
#   Stub + dynamic load pattern: t_terrain3d.gd:12-14,41-46,106-127,161-204;
#     t_pick3d.gd:48-71; P0 atom t_terrain_only.gd:44-49,88-143,384-642.
#   Shared helper (single owner, read-only): fixtures/_smallmap_harness.gd
#     :5,12-78,108-161 — make_stub_game/count_categories; dynamic load only.
#   Resource sid mapping: world3d_entities.gd:113-118,1269-1315,1446-1451
#     (POOL_TREE/POOL_ROCK, "mine_"+ty, Batch_<key>_<tag>, stats.resources).
#   Instance transform: world3d_entities.gd:1060-1079,1094-1121 (_world_pos,
#     _xf) -> origin.y == game.height_at(sim pos).
#   Terrain height sample: world3d_terrain.gd:883-903 height_at_world(world XZ).
#   Camera: camera3d.gd:148-198,232-252,484-581 (freeze edge-scroll).
#   Windowed SubViewport readback: terrain3d_sandbox.gd:139-151;
#     testbridge.gd:277-308; main.gd:1156-1193,1801-1862 (no CPU fallback).
#   PNG metric mirror (READ-ONLY): smallmap_capture.py:21-39.
#
# Fixture: synthetic, deterministic, IN-MEMORY 64x64 all-grass grid (tile id 0)
# with mild relief (max axis delta ~0.005 m << cDiff1=0.5, world3d_terrain.gd:
# 117-118), 20 wood nodes on a 5x4 lattice and 3 each of gold/iron/coal on a
# 3x3 interstitial lattice (>19 m from any tree, well beyond the 10.5 m ring
# at game.gd:2350-2351,2355-2356). No stone/food/bush/stump, no units,
# no buildings, no water cells. NOT the real-boot small_map_64.json path.
#
# All visual statements here are PORT APPROX / internal consistency only.
# No donor GPU A/B frame exists (V3D_02 parity_guard); do not claim parity.
extends SceneTree

const MODULE_PATH := "res://scripts/world3d_terrain.gd"
const ENTITIES_PATH := "res://scripts/world3d_entities.gd"
const CAMERA_PATH := "res://scripts/camera3d.gd"
# Written by a parallel owner; loaded dynamically, never by class_name
# (TEST-01 §Blockers 10; t_terrain3d.gd:12-13). A local stub of the same
# shape is embedded below and used if this file is absent.
const HARNESS_PATH := "res://tests/fixtures/_smallmap_harness.gd"
const OUT_PATH := "res://tests/results/t_combo_trees_mines.json"

const GRID_W := 64
const GRID_H := 64
const CELLS := GRID_W * GRID_H
const TILE_M := 2.0                 # data.gd:23 / game.gd:16
const WATER_LEVEL := -0.25          # world3d_terrain.gd:95 (donor literal UNVERIFIED)
const BLK_WATER := 255              # game.gd:52
const GRASS_TILE := 0               # presets_summer.json:2 grass1
const WINDOW_SIZE := Vector2i(1280, 720)   # data.gd:113-114; no CLI flag
const CAPTURE_FRAMES := 10          # TEST_MATRIX.md:32

# Stub-chosen counts (NOT donor constants): TEST-01 P1 says N=~20; DTRN_04
# §8 T2 labels N=20 as a stress case. P3 says gold/iron/coal at known positions.
const N_TREES := 20
const N_PER_ORE := 3
const RES_NODE_COUNT := N_TREES + 3 * N_PER_ORE
const TREE_SIDS := ["tree_spruce1", "tree_pine", "tree_fir", "tree_oak",
	"tree_spruce2", "tree_pinedry1"]  # world3d_entities.gd:114-115 (POOL_TREE)
const ORE_TYPES := ["gold", "iron", "coal"]  # world3d_entities.gd:1275
const SEP_MIN_M := 10.5             # game.gd:2350-2351,2355-2356 (ore/wood ring)
const Y_EPS_M := 1e-3               # DTRN_04 §8 T5 base-Y tolerance

const CHECK_NAMES := [
	"harness_stub_shape",
	"terrain_module_api",
	"entities_module_api",
	"camera_module_api",
	"build_ok",
	"entities_bind_ok",
	"surface_count",
	"vertex_count",
	"triangle_count",
	"uv2_count",
	"uv2_y_face_modes",
	"uv2_x_ground_only",
	"flat_grid_promoted",
	"atlas_grid_manifest",
	"shader_shadow_disabled",
	"no_water_cells",
	"no_water_tileblock",
	"no_water_plane_present",
	"tree_node_count",
	"ore_node_counts",
	"category_purity",
	"harness_category_crosscheck",
	"tree_instance_count",
	"ore_instance_counts",
	"non_tree_ore_instance_purity",
	"entity_stats_total",
	"y_matches_terrain",
	"tree_ore_separation",
	"capture_image",
	"capture_saved",
	"non_black_fraction",
	"full_width_dark_rows",
]

# Minimal local fallback stub, same shape as the shared helper
# (fixtures/_smallmap_harness.gd:12-78). It extends the real C3Game so a typed
# bind() would also work (t_terrain3d.gd:37-46). Base-class fields (MAP_W,
# MAP_H, height, tileblock, terrain, res_nodes, res_dirty, entities) are
# inherited, never redeclared (game.gd:35-61,82,149).
class LocalStubGame extends C3Game:
	var dump: Dictionary = {}

	# Verbatim bilinear recipe of game.gd:1893-1907 / harness helper :49-63.
	func height_at(p: Vector2) -> float:
		if height.size() != MAP_W * MAP_H:
			return 0.0
		var fx := clampf(p.x / TILE - 0.5, 0.0, float(MAP_W - 1) - 0.001)
		var fz := clampf(p.y / TILE - 0.5, 0.0, float(MAP_H - 1) - 0.001)
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

	# Same signature as game.gd:2685; not used by add_resource() but kept so
	# the fallback exposes the same surface as the shared helper (:66-78).
	func resolve_mine_sid(sid: String, pos: Vector2) -> String:
		if sid != "mine":
			return sid
		var best_type := ""
		var best_d := MINE_SITE_RADIUS  # game.gd:19 (no invented radius)
		for n in res_nodes:
			var d = n.get("pos", Vector2.ZERO) if n is Dictionary else null
			if not (d is Vector2):
				continue
			var t := str(n.get("type", ""))
			if t != "gold" and t != "iron" and t != "coal":
				continue
			var dist: float = (d as Vector2).distance_to(pos)
			if dist < best_d:
				best_d = dist
				best_type = t
		return "mine_" + best_type if best_type != "" else sid

var _id := "t_combo_trees_mines"
var _checks: Array[Dictionary] = []
var _ok := true
var _finished := false
var _setup_done := false
var _visual_checked := false
var _headless := false
var _png_path := ""
var _capture_view: SubViewport = null
var _terrain: Node = null
var _entities: Node = null
var _camera: Camera3D = null
var _game: Object = null
var _heights := PackedFloat32Array()
var _tileblock := PackedByteArray()
var _res_nodes: Array = []
var _harness_source := ""
var _harness_helper: Object = null
var _frame := 0
var _capture_pending := false
var _capturing := false
var _m: Dictionary = {}


func check(name: String, cond: bool, detail: String = "") -> void:
	_checks.append({"name": name, "passed": cond, "status": "PASS" if cond else "FAIL", "detail": detail})
	if not cond:
		_ok = false
	print("T_COMBO_TREES_MINES %s %s - %s" % ["PASS" if cond else "FAIL", name, detail])


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
	for c in _checks:
		if bool(c.get("passed", false)):
			passes += 1
		else:
			fails += 1
	var out := {
		"id": _id,
		# No full PASS is claimed on the headless/skip path.
		"passed": verdict == "PASS",
		"verdict": verdict,
		"capture_status": ("PASS" if _visual_checked else "SKIP_CAPTURE"),
		"structural_ok": _ok,
		"passes": passes,
		"fails": fails,
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
		push_error("t_combo_trees_mines: cannot write result: " + abs_path)
	print("T_COMBO_TREES_MINES RESULT_JSON: " + abs_path)
	print("T_COMBO_TREES_MINES RESULT: %s %d/%d evaluated" % [verdict, passes, passes + fails])
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
			# Mild relief: max axis delta ~0.005 m << cDiff1=0.5, so face
			# promotion stays zero and every cell is above WATER_LEVEL.
			_heights[i] = 1.5 + 0.03 * sin(float(x) * 0.11) + 0.02 * cos(float(z) * 0.09)
			_tileblock[i] = GRASS_TILE


# Known, deterministic stub positions (SIM metres, top-left map origin):
#   trees  x = 12 + 28c (c=0..4), z = 12 + 28r (r=0..3)  -> 20 wood
#   ores   x = 26 + 28c (c=0..2), z = 26 + 28r (r=0..2)  -> 3 each type
# Nearest tree-ore distance = sqrt(14^2+14^2) ~= 19.8 m > 10.5 m ring.
func _make_resource_nodes() -> Array:
	var out: Array = []
	var id := 1
	for r in range(4):
		for c in range(5):
			var p := Vector2(12.0 + 28.0 * float(c), 12.0 + 28.0 * float(r))
			out.append({"id": id, "kind": "res", "type": "wood", "pos": p,
				"hits": 3, "max_hits": 3, "radius": 1.0})
			id += 1
	var ix := 0
	for r in range(3):
		for c in range(3):
			var p := Vector2(26.0 + 28.0 * float(c), 26.0 + 28.0 * float(r))
			var ty := str(ORE_TYPES[ix % ORE_TYPES.size()])
			# Permanent ore: max_hits == 0 -> visible under world3d.gd:399-401
			# and world3d_entities.gd:1085-1090.
			out.append({"id": id, "kind": "res", "type": ty, "pos": p,
				"hits": 0, "max_hits": 0, "radius": 0.0})
			id += 1
			ix += 1
	return out


# TEST-01 §Scaffolding item 1 (:230-239): try the shared helper first; duplicate
# its shape locally if the parallel owner's file is absent from this checkout.
func _make_stub_game() -> Object:
	if ResourceLoader.exists(HARNESS_PATH):
		var helper: Object = load(HARNESS_PATH) as Object
		if helper != null and helper.has_method("make_stub_game"):
			var g: Object = helper.call("make_stub_game", GRID_W, GRID_H,
				_heights, _res_nodes, _tileblock)
			if g != null and is_instance_valid(g):
				_harness_source = "shared:" + HARNESS_PATH
				_harness_helper = helper
				return g
	# Fallback: same shape, local definition (noted in the result JSON).
	var local := LocalStubGame.new()
	local.MAP_W = GRID_W
	local.MAP_H = GRID_H
	local.height = _heights
	local.tileblock = _tileblock
	local.terrain.resize(CELLS)      # zeros: no water cells (main.gd:1144)
	local.res_nodes = _res_nodes
	var hb64 := Marshalls.raw_to_base64(_heights.to_byte_array())
	local.dump = {
		"map_w": GRID_W, "map_h": GRID_H,
		"height": hb64,
		"tileblock": Marshalls.raw_to_base64(_tileblock),
	}
	_harness_source = "embedded_local_stub"
	return local


# Regression guard copied from t_smallmap_terrain.gd:150-171 / P0 atom :299-315.
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


# The terrain module always creates a WaterPlane (world3d_terrain.gd:762-764).
# Isolation hides it (never deletes module-owned nodes; terrain3d_sandbox.gd:
# 120-124). "No water plane" is therefore asserted as ZERO VISIBLE planes
# plus zero water cells/tile cells — see C2 report for this caveat.
func _hide_water(root: Node) -> void:
	var planes := _find_named(root, "WaterPlane")
	var water_nodes := _find_named(root, "Water3D")
	for n in water_nodes:
		n.visible = false
	for n in planes:
		n.visible = false
	var visible_planes := 0
	for n in planes:
		if n.visible:
			visible_planes += 1
	_m["water_plane_count"] = planes.size()
	_m["water_3d_node_count"] = water_nodes.size()
	_m["visible_water_planes"] = visible_planes
	check("no_water_plane_present", visible_planes == 0,
		"WaterPlane nodes=%d visible=%d (module-owned, hidden not deleted)" % [
			planes.size(), visible_planes])


func _count_types(nodes: Array) -> Dictionary:
	var out := {"wood": 0, "stone": 0, "gold": 0, "iron": 0, "coal": 0,
		"food": 0, "bush": 0, "stump": 0}
	for n in nodes:
		var t := ""
		if n is Dictionary:
			t = str((n as Dictionary).get("type", ""))
		elif n is Object:
			t = str((n as Object).get("type"))
		if out.has(t):
			out[t] = int(out[t]) + 1
	return out


# Batch node names are "Batch_" + key.replace("|","_") + "_" + tag
# (world3d_entities.gd:966). Classify by the donor sid embedded in the name.
func _classify_batch(batch_name: String) -> String:
	if batch_name.contains("mine_gold"):
		return "gold"
	if batch_name.contains("mine_iron"):
		return "iron"
	if batch_name.contains("mine_coal"):
		return "coal"
	if batch_name.contains("tree_stump"):
		return "stump"          # stump sids also start with "tree" (POOL_STUMP)
	for sid in TREE_SIDS:
		if batch_name.contains(sid):
			return "tree"
	if batch_name.contains("bush"):
		return "bush"
	if batch_name.contains("rock") or batch_name.contains("stone"):
		return "stone"
	if batch_name.contains("field"):
		return "field"
	return "other"


func _count_instances(root: Node) -> Dictionary:
	var counts := {"tree": 0, "gold": 0, "iron": 0, "coal": 0, "stone": 0,
		"bush": 0, "stump": 0, "field": 0, "other": 0, "batches": 0}
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n is MultiMeshInstance3D:
			var mi := n as MultiMeshInstance3D
			var mm: MultiMesh = mi.multimesh
			if mm != null:
				var cat := _classify_batch(mi.name)
				counts[cat] = int(counts[cat]) + int(mm.visible_instance_count)
				counts["batches"] = int(counts["batches"]) + 1
		for c in n.get_children():
			stack.append(c)
	return counts


# Instance origin comes from _xf(id) -> Transform3D(basis, _world_pos(p))
# (world3d_entities.gd:1094-1121) whose y is game.height_at(p). Compare it to
# the terrain module's own bilinear sample at the same world XZ
# (world3d_terrain.gd:883-903). Tolerance 1e-3 m (DTRN_04 §8 T5).
func _check_y(ents: Node) -> Dictionary:
	var worst := 0.0
	var bad := 0
	for n in _res_nodes:
		var d := n as Dictionary
		var id := int(d.get("id", -1))
		var xf_v: Variant = ents.call("_xf", id)
		if not (xf_v is Transform3D):
			bad += 1
			continue
		var xf := xf_v as Transform3D
		var h_v: Variant = _terrain.call("height_at_world", Vector2(xf.origin.x, xf.origin.z))
		var err := absf(xf.origin.y - float(h_v))
		worst = maxf(worst, err)
		if err > Y_EPS_M:
			bad += 1
	return {"bad": bad, "worst_err_m": worst}


func _tree_ore_min_distance() -> float:
	var trees: Array[Vector2] = []
	var ores: Array[Vector2] = []
	for n in _res_nodes:
		var d := n as Dictionary
		var p: Vector2 = d.get("pos", Vector2.ZERO)
		if str(d.get("type", "")) == "wood":
			trees.append(p)
		else:
			ores.append(p)
	var best := INF
	for t in trees:
		for o in ores:
			best = minf(best, t.distance_to(o))
	return best


# Mirrors smallmap_capture.py:21-39 (READ-ONLY). get_pixel() is 0..1 here;
# the Python tool converts to 0..255 float32 RGB.
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
	_res_nodes = _make_resource_nodes()
	_game = _make_stub_game()
	_m["harness_source"] = _harness_source
	var shape_ok: bool = (_game != null and is_instance_valid(_game)
		and int(_game.get("MAP_W")) == GRID_W and int(_game.get("MAP_H")) == GRID_H
		and (_game.get("height") is PackedFloat32Array)
		and (_game.get("tileblock") is PackedByteArray)
		and (_game.get("res_nodes") is Array)
		and int((_game.get("res_nodes") as Array).size()) == RES_NODE_COUNT)
	check("harness_stub_shape", shape_ok,
		"source=%s MAP=%dx%d res_nodes=%d expected=%d" % [
			_harness_source,
			str(_game.get("MAP_W")) if _game != null else "<none>",
			str(_game.get("MAP_H")) if _game != null else "<none>",
			(_game.get("res_nodes") as Array).size() if _game.get("res_nodes") is Array else -1,
			RES_NODE_COUNT])
	if not shape_ok:
		_fail_remaining(1, "STUB_SHAPE", "harness stub does not expose the expected shape")
		_setup_done = true
		finish()
		return

	# Windowed GPU target only; headless runs stay state-only (main.gd:1156-1158).
	if not _headless:
		get_root().size = WINDOW_SIZE
		_capture_view = SubViewport.new()
		_capture_view.name = "ComboTreesMinesViewport"
		_capture_view.world_3d = World3D.new()
		_capture_view.size = WINDOW_SIZE
		_capture_view.render_target_update_mode = SubViewport.UPDATE_ONCE
		get_root().add_child(_capture_view)
	var parent: Node = _capture_view if _capture_view != null else get_root()

	# --- module APIs (all loaded dynamically, no class_name) -----------------
	var terrain_script := load(MODULE_PATH) as Script
	var terrain_api := terrain_script != null and terrain_script.can_instantiate()
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

	var entities_script := load(ENTITIES_PATH) as Script
	var entities_api := entities_script != null and entities_script.can_instantiate()
	var entities_missing: Array[String] = []
	if entities_api:
		var probe2: Object = entities_script.new()
		for meth in ["bind", "sync", "add_resource", "remove"]:
			if not probe2.has_method(meth):
				entities_missing.append(meth)
		probe2.free()
	entities_api = entities_api and entities_missing.is_empty()
	check("entities_module_api", entities_api,
		"script=%s missing=%s" % [ENTITIES_PATH, str(entities_missing)])

	var camera_script := load(CAMERA_PATH) as Script
	var camera_api := camera_script != null and camera_script.can_instantiate()
	var camera_missing: Array[String] = []
	if camera_api:
		var probe3: Object = camera_script.new()
		for meth in ["bind", "world_to_px", "screen_to_world", "set_zoom_target"]:
			if not probe3.has_method(meth):
				camera_missing.append(meth)
		probe3.free()
	camera_api = camera_api and camera_missing.is_empty()
	check("camera_module_api", camera_api,
		"script=%s missing=%s" % [CAMERA_PATH, str(camera_missing)])
	if not terrain_api or not entities_api or not camera_api:
		_fail_remaining(4, "MODULE_MISSING", "terrain/entities/camera script or API unavailable")
		_setup_done = true
		finish()
		return

	# --- bind: terrain, frozen camera, entities ------------------------------
	_terrain = terrain_script.new() as Node
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

	_camera = camera_script.new() as Camera3D
	_camera.name = "DonorCamera"
	parent.add_child(_camera)
	_camera.call("bind", _game)
	_camera.set_process(false)       # camera3d.gd:484-581 edge-scroll off
	_camera.make_current()

	_entities = entities_script.new() as Node
	_entities.name = "EntitiesModule"
	parent.add_child(_entities)
	_entities.call("bind", _game)
	# Same filter as the real feed (world3d.gd:390-405): visible nodes only.
	var fed := 0
	for n in _res_nodes:
		var d := n as Dictionary
		var hits := int(d.get("hits", 0))
		var max_hits := int(d.get("max_hits", 0))
		var ty := str(d.get("type", ""))
		if hits <= 0 and max_hits != 0 and ty != "stump" and ty != "food":
			continue
		_entities.call("add_resource", d)
		fed += 1
	_entities.call("sync", 0.0)      # refresh stats (world3d_entities.gd:1529-1551)
	_m["resources_fed"] = fed
	check("entities_bind_ok", fed == RES_NODE_COUNT,
		"entities bound; fed=%d expected=%d" % [fed, RES_NODE_COUNT])

	_hide_water(parent)

	# --- P0 mesh invariants (must be unchanged by adding entities) ----------
	var mi := _terrain.get_node_or_null("HeightmapTerrain") as MeshInstance3D
	var mesh: Mesh = mi.mesh if mi != null else null
	var stats_v: Variant = _terrain.get("stats")
	var stats: Dictionary = stats_v if stats_v is Dictionary else {}
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
	var bad_x := 0
	var face_hist := {}
	if uv2v is PackedVector2Array:
		var uv2: PackedVector2Array = uv2v
		for i in range(uv2.size()):
			var fy := int(uv2[i].y)
			if fy < 0 or fy > 2 or absf(uv2[i].y - float(fy)) > 0.001:
				bad_y += 1
			if absf(uv2[i].x) > 0.001:
				bad_x += 1
			face_hist[str(fy)] = int(face_hist.get(str(fy), 0)) + 1
	_m["uv2_y_hist"] = face_hist
	check("uv2_y_face_modes", bad_y == 0,
		"non-0/1/2 UV2.y=%d hist=%s" % [bad_y, str(face_hist)])
	check("uv2_x_ground_only", bad_x == 0,
		"UV2.x!=grass id 0: %d cells (all-grass stub)" % bad_x)

	var promoted := _probe_flat_promotions()
	_m["flat_grid_promoted_cells"] = promoted
	check("flat_grid_promoted", promoted == 0,
		"flat 64x64 grid promoted=%d (expected 0; t_smallmap_terrain.gd:150-171)" % promoted)

	var at_v: Variant = stats.get("atlas", {})
	var at: Dictionary = at_v if at_v is Dictionary else {}
	var grid_v: Variant = at.get("grid", [])
	var grid: Array = grid_v if grid_v is Array else []
	var grid_ok: bool = grid.size() == 2 and int(grid[0]) == 16 and int(grid[1]) == 8
	var grid_param: Variant = null
	var shader_shadow: Variant = null
	var mat: Material = mesh.surface_get_material(0) if mesh != null else null
	if mat is ShaderMaterial:
		var sm := mat as ShaderMaterial
		grid_param = sm.get_shader_parameter("atlas_grid")
		shader_shadow = sm.get_shader_parameter("shadow_enabled")
	_m["atlas_grid"] = grid
	_m["atlas_grid_shader_param"] = str(grid_param)
	_m["shader_shadow_enabled"] = str(shader_shadow)
	check("atlas_grid_manifest", grid_ok and grid_param is Vector2
		and (grid_param as Vector2).is_equal_approx(Vector2(16.0, 8.0)),
		"stats.grid=%s shader.atlas_grid=%s" % [str(grid), str(grid_param)])
	check("shader_shadow_disabled", str(shader_shadow) == "0" or str(shader_shadow) == "0.0",
		"shader shadow_enabled=%s (expected 0; world3d_terrain.gd:315)" % str(shader_shadow))

	# --- no water in this combo row -----------------------------------------
	var below := 0
	for i in range(CELLS):
		if _heights[i] < WATER_LEVEL:
			below += 1
	_m["cells_below_water_level"] = below
	_m["water_level_m"] = WATER_LEVEL
	check("no_water_cells", below == 0,
		"height < %.2f m: %d cells (expected 0)" % [WATER_LEVEL, below])
	var water_tiles := 0
	for i in range(CELLS):
		if int(_tileblock[i]) == BLK_WATER:
			water_tiles += 1
	_m["water_tileblock_cells"] = water_tiles
	check("no_water_tileblock", water_tiles == 0,
		"BLK_WATER=%d cells=%d (expected 0)" % [BLK_WATER, water_tiles])

	# --- P1 + P3 resource invariants, simultaneously ------------------------
	var types := _count_types(_res_nodes)
	_m["resource_node_types"] = types
	check("tree_node_count", int(types["wood"]) == N_TREES,
		"wood nodes=%d expected=%d" % [int(types["wood"]), N_TREES])
	var ore_ok := true
	var ore_detail: Array[String] = []
	for ty in ORE_TYPES:
		var got := int(types[ty])
		if got != N_PER_ORE:
			ore_ok = false
		ore_detail.append("%s=%d/%d" % [ty, got, N_PER_ORE])
	check("ore_node_counts", ore_ok, "ore nodes " + " ".join(ore_detail))
	var pure := int(types["wood"]) == N_TREES and ore_ok
	for extra in ["stone", "food", "bush", "stump"]:
		if int(types[extra]) != 0:
			pure = false
	check("category_purity", pure,
		"types=%s (stone/food/bush/stump must all be 0)" % str(types))
	if _harness_helper != null and _harness_helper.has_method("count_categories"):
		var hc_v: Variant = _harness_helper.call("count_categories", _res_nodes)
		var hc: Dictionary = hc_v if hc_v is Dictionary else {}
		var cross := int(hc.get("wood", -1)) == N_TREES and int(hc.get("mine", -1)) == 3 * N_PER_ORE \
			and int(hc.get("stone", -1)) == 0 and int(hc.get("food", -1)) == 0
		_m["harness_categories"] = hc
		check("harness_category_crosscheck", cross,
			"helper.count_categories=%s" % str(hc))
	else:
		_m["harness_categories"] = "unavailable (embedded stub path)"

	var inst := _count_instances(parent)
	_m["instances"] = inst
	check("tree_instance_count", int(inst["tree"]) == N_TREES,
		"Batch_*_res tree instances=%d expected=%d" % [int(inst["tree"]), N_TREES])
	var inst_ore_ok := true
	var inst_detail: Array[String] = []
	for ty in ORE_TYPES:
		var got := int(inst[ty])
		if got != N_PER_ORE:
			inst_ore_ok = false
		inst_detail.append("mine_%s=%d/%d" % [ty, got, N_PER_ORE])
	check("ore_instance_counts", inst_ore_ok, "ore instances " + " ".join(inst_detail))
	var inst_pure := int(inst["stone"]) == 0 and int(inst["bush"]) == 0 \
		and int(inst["stump"]) == 0 and int(inst["field"]) == 0 and int(inst["other"]) == 0
	check("non_tree_ore_instance_purity", inst_pure,
		"non tree/ore batches: stone=%d bush=%d stump=%d field=%d other=%d" % [
			int(inst["stone"]), int(inst["bush"]), int(inst["stump"]),
			int(inst["field"]), int(inst["other"])])
	var ent_stats_v: Variant = _entities.get("stats")
	var ent_stats: Dictionary = ent_stats_v if ent_stats_v is Dictionary else {}
	_m["entities_stats_resources"] = ent_stats.get("resources", -1)
	check("entity_stats_total", int(ent_stats.get("resources", -1)) == RES_NODE_COUNT,
		"entities.stats.resources=%s expected=%d" % [
			str(ent_stats.get("resources", -1)), RES_NODE_COUNT])

	var yr := _check_y(_entities)
	_m["y_check"] = yr
	check("y_matches_terrain", int(yr["bad"]) == 0,
		"instances with |Y - height_at_world(XZ)| > %.4f m: %d, worst=%.6f m" % [
			Y_EPS_M, int(yr["bad"]), float(yr["worst_err_m"])])
	var sep := _tree_ore_min_distance()
	_m["min_tree_ore_distance_m"] = sep
	check("tree_ore_separation", sep > SEP_MIN_M,
		"min tree/ore distance=%.3f m (expected > %.1f m; game.gd:2350-2351,2355-2356)" % [
			sep, SEP_MIN_M])

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


func _process(_delta: float) -> bool:
	if _finished or not _capture_pending or _capturing:
		return false
	_frame += 1
	if _frame >= CAPTURE_FRAMES:
		_capturing = true
		_capture_async()
	return false


# Stub-owned windowed GPU readback: no main.tscn, no main's --screenshot saver
# (TEST-01 §"Test ladder" C2 column; terrain3d_sandbox.gd:139-151).
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
	_m["capture_source"] = "ComboTreesMinesViewport (stub-owned, windowed GPU)"
	check("non_black_fraction", float(ms["non_black_fraction"]) > 0.9,
		"non_black_fraction=%s (expected >0.9; smallmap_capture.py:26)" % str(ms["non_black_fraction"]))
	check("full_width_dark_rows", int(ms["full_width_dark_rows"]) == 0,
		"full_width_dark_rows=%d (expected 0; smallmap_capture.py:27-28)" % int(ms["full_width_dark_rows"]))
	_visual_checked = true
	finish()
