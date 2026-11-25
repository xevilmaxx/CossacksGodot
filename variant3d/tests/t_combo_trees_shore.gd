# TEST-C1 / t_combo_trees_shore.gd — COMBO terrain + trees + shore, 64x64.
#
# Owns ONLY this file (plus docs/coord_swarm_2026-11-25/reports/TEST_C1_report.md).
# No source, shader, asset, config, manifest, fixture, gate-file or git edit.
# AUTHORING ONLY: this file was never executed by this agent; no Godot job was
# submitted, no runner ticket was taken (docs/COMMANDS.md runner monopoly).
#
# Design sources (authoritative):
#   TEST-01 §"Test ladder" row C1 + rows P0/P1/P2
#     (docs/coord_swarm_2026-11-25/reports/TEST_01_smallmap_harness.md:212-216)
#     — P1+P2 union, exact tree count, water-cell bound, single surface, both
#     parent invariant sets at once, trees never below water level.
#   TEST-01 §"Scaffolding needed" items 1/3/4 (:228-255) — dynamic load() helper,
#     one feature per file, stub-owned windowed SubViewport readback.
#   TEST_MATRIX.md:22 (C1 "no interaction regressions") + :29-46 (V3D_02
#     refinement T1/T2: Y on terrain, height-aware water, shore ids in UV2,
#     full-width dark rows = 0).
#   V3D_02 §"Piece-test ladder proposal" T1/T2/T4
#     (docs/coord_swarm_2026-11-25/reports/V3D_02_terrain_render_audit.md:145-148).
#   P0 implementation pattern: variant3d/tests/t_terrain_only.gd:42-86,
#     144-236,256-315,384-642 (stub, checks, capture, result shape).
#   Dynamic load() / no class_name: t_terrain3d.gd:12-14,161-204.
#   Stub surface: fixtures/_smallmap_harness.gd:14-40,117-180; t_pick3d.gd:53-71.
#   Resource feed: world3d_entities.gd:1269-1315 (_resource_sid POOL_TREE ->
#     _acquire -> Batch_res_<sid>_STATIC_POSE), :986-1015 (CPU xform mirror),
#     :1060-1079 (_world_pos uses game.height_at), :1334-1427 (sync applies xf).
#   Terrain contract: world3d_terrain.gd:623-874 (one mesh, UV2.x=tile id,
#     UV2.y=face mode, stats.water.height_aware, WATER_LEVEL=-0.25 at :95),
#     :528-544 (one height-aware WaterPlane, renamed from WaterPlane3D).
#   Height-aware water hook: water3d.gd:248-264 (bind_height_grid).
#   Shore fixture MIRRORS the landed P2 atom (tests/t_terrain_shore.gd:303-350,
#     report TEST_P2_report.md:55-66): r<3 water, 3..3.8 sandsea, 3.8..4.7
#     sandrock, 4.7..5.4 rock sector; tile ids from
#     assets/terrain/structs/tileblocks.json (sandrock1..6=87..92,
#     sandsea1/5/6=93/97/98, rock4/7/8=29/32/33), not invented. BLK_WATER=255
#     from game.gd:52. Basin dimensions are synthetic fixture geometry shared
#     with P2, not recovered donor literals.
#   PNG metric mirror (READ-ONLY): tools/smallmap_capture.py:21-39 (non-black
#     > 8/255, luma = 0.2126R+0.7152G+0.0722B, dark row when >90% luma<20).
#   Headless guard: t_forest_bake_render.gd:35-41; main.gd:1156-1158,1790-1800.
#   PNG readback: terrain3d_sandbox.gd:139-151; testbridge.gd:277-308.
#
# Captures: stub-owned windowed SubViewport; PNG path is a user arg
#   (--screenshot <abs.png>, or --png). Headless runs are state-only and are
#   labelled SKIP_CAPTURE, never PASS. Donor parity stays UNVERIFIED (no F0
#   donor GPU A/B frame exists — V3D_02 parity_guard).
extends SceneTree

const MODULE_TERRAIN := "res://scripts/world3d_terrain.gd"
const MODULE_ENTITIES := "res://scripts/world3d_entities.gd"
const MODULE_CAMERA := "res://scripts/camera3d.gd"
const HARNESS_PATH := "res://tests/fixtures/_smallmap_harness.gd"
const P0_RESULT_PATH := "res://tests/results/t_terrain_only.json"
const OUT_PATH := "res://tests/results/t_combo_trees_shore.json"

const GRID_W := 64
const GRID_H := 64
const CELLS := GRID_W * GRID_H
const TILE_M := 2.0                 # data.gd:23; game.gd:16
const WATER_LEVEL := -0.25          # world3d_terrain.gd:95 (mapgen.gd:29; donor literal UNVERIFIED)
const BLK_WATER := 255              # game.gd:52
const WATER_TILE := 3               # main.gd:1144; _smallmap_harness.gd:11
const GRASS_TILE := 0               # tileblocks.json:0 (grass1)
const SANDSEA_IDS := [93, 97, 98]   # tileblocks.json:93,97,98 (sandsea1/5/6)
const SANDROCK_IDS := [87, 88, 89, 90, 91, 92]  # tileblocks.json:87-92
const ROCK_IDS := [29, 32, 33]      # tileblocks.json:29,32,33 (rock4/7/8)
const SANDSEA_BY_SECTOR := [98, 98, 93, 97, 98, 98, 93, 97]  # t_terrain_shore.gd:74; game.gd:1735
const NAMED_CELLS := 124            # tile_index_atlas.manifest.json atlas.named_cells
const EXPECTED_GRID := Vector2(16.0, 8.0)  # V7-85 manifest / t_smallmap_terrain.gd:26
const WINDOW_SIZE := Vector2i(1280, 720)   # data.gd:113-114; no CLI flag (TEST-01 Blocker 3)
const CAPTURE_FRAMES := 10          # TEST_MATRIX.md:32 "capture after ~10 frames"

# Synthetic fixture geometry — chosen for isolation, NOT recovered donor values.
const BASIN_CX := 31.5              # P2 fixture centre (t_terrain_shore.gd:316-317)
const BASIN_CZ := 31.5
const WATER_R := 3.0                # ~28 cells = 0.7% of 4096 (<10% bound)
const COLLAR_R := 5.4               # sandsea 3..3.8, sandrock 3.8..4.7, rock sector 4.7..5.4
const TREE_COUNT := 20              # TEST-01 row P1 "N=~20"
const TREE_COLS := 10
const TREE_X0 := 18
const TREE_X_STEP := 3
const TREE_Z0 := 20
const TREE_Z_STEP := 24
const TREE_Z1 := TREE_Z0 + TREE_Z_STEP
const TREE_HITS := 60               # same visible-resource shape as t_entities3d.gd:135-140
const SAMPLE_EPS := 1e-4            # float32 grid tolerance (t_terrain3d.gd:25)

# Donor-derived sid pools, COPIED (not invented) from world3d_entities.gd.
const TREE_SIDS := ["tree_spruce1", "tree_pine", "tree_fir", "tree_oak",
	"tree_spruce2", "tree_pinedry1"]                                   # :114-115
const ROCK_SIDS := ["rock", "stone", "rock_stones1", "rock_stones2", "rock_stones3"]  # :116
const BUSH_SIDS := ["bush1", "bush2", "bush3", "bush4"]                # :117
const STUMP_SIDS := ["tree_stump1", "tree_stump2", "tree_stump3", "tree_stump4"]  # :118
const MINE_SIDS := ["mine_gold", "mine_iron", "mine_coal"]             # :1276
const FIELD_SIDS := ["field"]                                          # :1278

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
	"atlas_grid_manifest",
	"atlas_material_bound",
	"shader_shadow_disabled",
	"p0_mesh_counts_unchanged",
	"tree_res_nodes_exact",
	"tree_category_purity",
	"tree_batch_instances_exact",
	"tree_y_on_terrain",
	"trees_not_below_water",
	"no_mines_added",
	"water_cells_bounded",
	"water_plane_single_height_aware",
	"shore_ids_in_uv2_hist",
	# DARKROW-ALL-01: strict, applicable whole-frame luma gates (P0-GATE-01).
	# Inserted BEFORE the four capture checks so the size()-4 headless/abort
	# window in _fail_remaining keeps pointing at the same existing checks.
	"ground_mean_luma",
	"ground_max_luma",
	"capture_image",
	"capture_saved",
	"non_black_fraction",
	"full_width_dark_rows",
]

# Local fallback with the SAME surface as fixtures/_smallmap_harness.gd:14-40
# (used only if that parallel-owned helper has not landed). Extends the real
# C3Game so a typed bind() also works (t_terrain3d.gd:37-46).
class LocalStubGame extends C3Game:
	# ATOM-REPAIR: res_dirty is inherited from C3Game (game.gd:149); redeclaring
	# it was a parse error. resolve_mine_sid already matches game.gd:2685.
	var dump: Dictionary = {}
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

	# SIM metres, map-origin top-left; exact bilinear recipe of game.gd:1893-1907.
	func height_at(p: Vector2) -> float:
		if height.size() != MAP_W * MAP_H:
			return 0.0
		var fx := clampf(p.x / TILE - 0.5, 0.0, float(MAP_W - 1))
		var fz := clampf(p.y / TILE - 0.5, 0.0, float(MAP_H - 1))
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

	func cmd_sow(_a = null, _b = null, _c = null) -> int: _bump("cmd_sow"); return 0
	func cmd_move(_a = null, _b = null, _c = null) -> void: _bump("cmd_move")
	func cmd_gather(_a = null, _b = null, _c = null) -> void: _bump("cmd_gather")
	func cmd_build(_a = null, _b = null, _c = null) -> void: _bump("cmd_build")

var _id := "t_combo_trees_shore"
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
var _tree_nodes: Array[Dictionary] = []
var _harness_source := ""
var _frame := 0
var _capture_pending := false
var _capturing := false
var _m: Dictionary = {}


# `cond` is Variant so SKIP_CAPTURE checks carry JSON null, not a false verdict.
func check(name: String, cond, detail: String = "", status: String = "") -> void:
	var st := status
	if st == "":
		st = "PASS" if cond == true else ("FAIL" if cond == false else "SKIPPED")
	_checks.append({"name": name, "passed": cond, "status": st, "detail": detail})
	if cond == false:
		_ok = false
	print("T_COMBO_TREES_SHORE %s %s - %s" % [st, name, detail])


func _fail_remaining(from_index: int, tag: String, reason: String) -> void:
	for i in range(from_index, CHECK_NAMES.size()):
		var skip := i >= CHECK_NAMES.size() - 4 and _headless
		if skip:
			check(CHECK_NAMES[i], null, "headless: GPU capture skipped", "SKIPPED")
		else:
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
		push_error("t_combo_trees_shore: cannot write result: " + abs_path)
	print("T_COMBO_TREES_SHORE RESULT_JSON: " + abs_path)
	print("T_COMBO_TREES_SHORE RESULT: %s %d/%d evaluated, %d skipped"
		% [verdict, passes, passes + fails, skips])
	# Deferred quit — never call quit() from _initialize() (tests/README.md:3-33).
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


# Donor 8x45-degree sector table, copied from t_terrain_shore.gd:308-310.
func _sector(dx: float, dz: float) -> int:
	var ang: float = atan2(dz, dx)
	return int(floor((ang + PI) / (PI / 4.0))) % 8


# Exact P2 basin recipe (t_terrain_shore.gd:313-350), so C1's shore layer is
# the same layer as its parent; only the tree layer is added.
func _make_grid() -> void:
	_heights.resize(CELLS)
	_tileblock.resize(CELLS)
	_m["water_cells"] = 0
	for z in range(GRID_H):
		for x in range(GRID_W):
			var i := z * GRID_W + x
			var dx: float = float(x) - BASIN_CX
			var dz: float = float(z) - BASIN_CZ
			var r: float = sqrt(dx * dx + dz * dz)
			var s := _sector(dx, dz)
			var h: float
			var tid: int
			if r < WATER_R:
				h = -0.55                      # below WATER_LEVEL (-0.25)
				tid = BLK_WATER
				_m["water_cells"] = int(_m["water_cells"]) + 1
			elif r < 3.8:
				h = -0.18                      # wet shore between -0.25 and -0.1
				tid = int(SANDSEA_BY_SECTOR[s])
			elif r < 4.7:
				h = 0.02
				tid = int(SANDROCK_IDS[s % SANDROCK_IDS.size()])
			elif r < COLLAR_R and s == 0:
				h = 0.08
				tid = int(ROCK_IDS[0])
			else:
				# Dry grass; relief steps << donor cDiff1=0.5 (world3d_terrain.gd:117-118).
				h = 0.55 + 0.02 * sin(float(x) * 0.13) + 0.01 * cos(float(z) * 0.11)
				tid = GRASS_TILE
			_heights[i] = h
			_tileblock[i] = tid
	_m["water_fraction"] = float(_m["water_cells"]) / float(CELLS)


# SIM-metre resource dictionaries; the two rows sit well outside P2's collar
# (|dz| >= 12.5 tiles > COLLAR_R = 5.4), so no tree can be submerged.
func _make_tree_nodes() -> void:
	_tree_nodes.clear()
	for i in range(TREE_COUNT):
		var col: int = i % TREE_COLS
		var row: int = int(i / TREE_COLS)
		var gx: int = TREE_X0 + col * TREE_X_STEP
		var gz: int = (TREE_Z0 if row == 0 else TREE_Z1)
		var sim := Vector2((float(gx) + 0.5) * TILE_M, (float(gz) + 0.5) * TILE_M)
		_tree_nodes.append({
			"id": 5000 + i,
			"kind": "res",
			"type": "wood",
			"pos": sim,
			"hits": TREE_HITS,
			"max_hits": TREE_HITS,
			"radius": 0.7,
		})
	var tree_cells: Array = []
	for n in _tree_nodes:
		var p: Vector2 = n["pos"]
		tree_cells.append([int(p.x / TILE_M - 0.5), int(p.y / TILE_M - 0.5)])
	_m["tree_cells"] = tree_cells


func _make_stub_game() -> Object:
	if ResourceLoader.exists(HARNESS_PATH):
		var helper: Object = load(HARNESS_PATH)
		if helper != null and helper.has_method("make_stub_game"):
			var g: Object = helper.call("make_stub_game", GRID_W, GRID_H,
				_heights, _tree_nodes, _tileblock)
			if g != null and is_instance_valid(g):
				_harness_source = "shared:" + HARNESS_PATH
				_tag_water_terrain(g)
				return g
	# Embedded fallback (noted in result JSON + report).
	var local := LocalStubGame.new()
	local.MAP_W = GRID_W
	local.MAP_H = GRID_H
	local.height = _heights
	local.tileblock = _tileblock
	local.terrain.resize(CELLS)
	local.res_nodes = []
	for n in _tree_nodes:
		local.res_nodes.append(n)
	local.dump = {
		"map_w": GRID_W,
		"map_h": GRID_H,
		"height": Marshalls.raw_to_base64(_heights.to_byte_array()),
		"tileblock": Marshalls.raw_to_base64(_tileblock),
	}
	_harness_source = "embedded_local_stub"
	_tag_water_terrain(local)
	return local


func _tag_water_terrain(g: Object) -> void:
	var tv: Variant = g.get("terrain")
	if tv is PackedByteArray:
		var terr: PackedByteArray = tv
		if terr.size() == CELLS:
			for i in range(CELLS):
				if _heights[i] < WATER_LEVEL:
					terr[i] = WATER_TILE
			g.set("terrain", terr)


func _count_categories(nodes: Array) -> Dictionary:
	if ResourceLoader.exists(HARNESS_PATH):
		var helper: Object = load(HARNESS_PATH)
		if helper != null and helper.has_method("count_categories"):
			var v: Variant = helper.call("count_categories", nodes)
			if v is Dictionary:
				return v
	var out := {"wood": 0, "stone": 0, "mine": 0, "food": 0}
	for n in nodes:
		var t := str((n as Dictionary).get("type", ""))
		match t:
			"wood": out["wood"] = int(out["wood"]) + 1
			"stone": out["stone"] = int(out["stone"]) + 1
			"gold", "iron", "coal": out["mine"] = int(out["mine"]) + 1
			"food": out["food"] = int(out["food"]) + 1
	return out


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


func _api_ok(script_path: String, methods: Array[String]) -> bool:
	var script := load(script_path) as Script
	if script == null or not script.can_instantiate():
		return false
	var probe: Object = script.new()
	if probe == null:
		return false
	var missing: Array[String] = []
	for meth in methods:
		if not probe.has_method(meth):
			missing.append(meth)
	probe.free()
	if not missing.is_empty():
		print("T_COMBO_TREES_SHORE API_MISSING " + script_path + " " + str(missing))
	return missing.is_empty()


# Mirror of smallmap_capture.py:21-39 (read-only tool, not invoked here).
func _image_metrics(img: Image) -> Dictionary:
	var w := img.get_width()
	var h := img.get_height()
	var non_black := 0
	var dark_rows := 0
	var luma_sum := 0.0
	var max_luma := 0.0
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
			if l > max_luma:
				max_luma = l
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
		# DARKROW-ALL-01: whole-frame peak for the strict ground-visibility
		# gate. PORT APPROX — no donor GPU A/B exists (V3D_02 parity_guard).
		"max_luma": max_luma,
		"full_width_dark_rows": dark_rows,
	}


func _read_optional_p0_baseline() -> void:
	var abs := ProjectSettings.globalize_path(P0_RESULT_PATH)
	if not FileAccess.file_exists(abs):
		_m["p0_baseline"] = "ABSENT — hard-coded P0 expected counts used"
		return
	var f := FileAccess.open(abs, FileAccess.READ)
	if f == null:
		_m["p0_baseline"] = "UNREADABLE — hard-coded P0 expected counts used"
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if parsed is Dictionary:
		var m_v: Variant = (parsed as Dictionary).get("measured", {})
		var bm: Dictionary = m_v if m_v is Dictionary else {}
		_m["p0_baseline"] = {
			"surfaces": bm.get("mesh_surfaces", null),
			"vertices": bm.get("mesh_vertices", null),
			"triangles": bm.get("mesh_triangles", null),
			"uv2": bm.get("uv2_count", null),
		}
	else:
		_m["p0_baseline"] = "UNPARSEABLE — hard-coded P0 expected counts used"


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
	_make_tree_nodes()
	_game = _make_stub_game()
	var shape_ok: bool = (_game != null and is_instance_valid(_game)
		and int(_game.get("MAP_W")) == GRID_W and int(_game.get("MAP_H")) == GRID_H
		and (_game.get("height") is PackedFloat32Array)
		and (_game.get("tileblock") is PackedByteArray)
		and (_game.get("res_nodes") is Array)
		and int((_game.get("res_nodes") as Array).size()) == TREE_COUNT)
	check("harness_stub_shape", shape_ok,
		"source=%s MAP=%dx%d res_nodes=%d" % [
			_harness_source,
			str(_game.get("MAP_W")) if _game != null else "<none>",
			str(_game.get("MAP_H")) if _game != null else "<none>",
			str(_tree_nodes.size())])
	if not shape_ok:
		_fail_remaining(1, "STUB_SHAPE", "harness stub does not expose the expected shape")
		_setup_done = true
		finish()
		return

	# Windowed GPU target; headless stays state-only (main.gd:1156-1158).
	if not _headless:
		get_root().size = WINDOW_SIZE
		_capture_view = SubViewport.new()
		_capture_view.name = "ComboTreesShoreViewport"
		_capture_view.world_3d = World3D.new()
		_capture_view.size = WINDOW_SIZE
		_capture_view.render_target_update_mode = SubViewport.UPDATE_ONCE
		get_root().add_child(_capture_view)
	var parent: Node = _capture_view if _capture_view != null else get_root()

	var terrain_api := _api_ok(MODULE_TERRAIN,
		["bind", "build", "invalidate", "has_chunk_or_fallback", "height_at_world"])
	check("terrain_module_api", terrain_api, "script=" + MODULE_TERRAIN)
	var entities_api := _api_ok(MODULE_ENTITIES,
		["bind", "sync", "add_resource", "remove"])
	check("entities_module_api", entities_api, "script=" + MODULE_ENTITIES)
	var camera_api := _api_ok(MODULE_CAMERA,
		["bind", "world_to_px", "screen_to_world", "set_zoom_target"])
	check("camera_module_api", camera_api, "script=" + MODULE_CAMERA)
	if not (terrain_api and entities_api and camera_api):
		_fail_remaining(4, "MODULE_MISSING", "terrain/entities/camera script or API unavailable")
		_setup_done = true
		finish()
		return

	# No world3d.gd, no FX, no picking, no main.tscn boot: only three modules.
	_terrain = (load(MODULE_TERRAIN) as Script).new() as Node
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

	_entities = (load(MODULE_ENTITIES) as Script).new() as Node
	_entities.name = "TreeEntitiesModule"
	parent.add_child(_entities)
	_entities.call("bind", _game)
	for n in _tree_nodes:
		_entities.call("add_resource", n)
	# sync() applies the CPU-mirrored xforms (world3d_entities.gd:1413-1427).
	_entities.call("sync", 0.0)

	_camera = (load(MODULE_CAMERA) as Script).new() as Camera3D
	_camera.name = "DonorCamera"
	parent.add_child(_camera)
	_camera.call("bind", _game)
	_camera.set_process(false)   # no edge scroll mid-capture (camera3d.gd:484-581)
	_camera.make_current()

	# ---- P0 mesh invariants must survive the P1 + P2 union --------------------
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
	var uv2_hist_x := {}
	if uv2v is PackedVector2Array:
		var uv2: PackedVector2Array = uv2v
		for i in range(uv2.size()):
			var y := int(uv2[i].y)
			if y < 0 or y > 2 or absf(uv2[i].y - float(y)) > 0.001:
				bad_y += 1
			face_hist[str(y)] = int(face_hist.get(str(y), 0)) + 1
			var tid := int(uv2[i].x)
			uv2_hist_x[str(tid)] = int(uv2_hist_x.get(str(tid), 0)) + 1
	_m["uv2_y_hist"] = face_hist
	_m["uv2_x_hist"] = uv2_hist_x
	check("uv2_y_face_modes", bad_y == 0,
		"non-0/1/2 UV2.y=%d hist=%s" % [bad_y, str(face_hist)])

	var promoted := _probe_flat_promotions()
	_m["flat_grid_promoted_cells"] = promoted
	check("flat_grid_promoted", promoted == 0,
		"perfectly flat %dx%d grid: promoted=%d (t_smallmap_terrain.gd:150-171)" % [
			GRID_W, GRID_H, promoted])

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
	_read_optional_p0_baseline()
	check("p0_mesh_counts_unchanged", surfaces == 1 and vertices == CELLS
		and triangles == (GRID_W - 1) * (GRID_H - 1) * 2 and uv2_count == CELLS,
		"surfaces=%d vertices=%d triangles=%d uv2=%d; baseline=%s" % [
			surfaces, vertices, triangles, uv2_count, str(_m["p0_baseline"])])

	# ---- P1: exact tree count + category purity + Y on terrain ----------------
	var res_nodes: Array = _game.get("res_nodes") as Array if _game.get("res_nodes") is Array else []
	var cats := _count_categories(res_nodes)
	_m["category_counts"] = cats
	check("tree_res_nodes_exact", res_nodes.size() == TREE_COUNT
		and int(cats.get("wood", 0)) == TREE_COUNT,
		"res_nodes=%d wood=%d (expected %d)" % [res_nodes.size(),
			int(cats.get("wood", 0)), TREE_COUNT])
	var pure_cats: bool = (int(cats.get("stone", 0)) == 0
		and int(cats.get("mine", 0)) == 0 and int(cats.get("food", 0)) == 0)
	check("tree_category_purity", pure_cats, "counts=%s (stone/mine/food must be 0)" % str(cats))

	# Batch purity is measured from the entities module's own CPU mirror:
	# world3d_entities.gd:164-166,977-981,986-1015.
	var batches_v: Variant = _entities.get("_batches")
	var batches: Dictionary = batches_v if batches_v is Dictionary else {}
	var refs_v: Variant = _entities.get("_refs")
	var refs: Dictionary = refs_v if refs_v is Dictionary else {}
	var tree_instances := 0
	var forbidden_sids: Array[String] = []
	var sid_counts := {}
	var y_max_err := 0.0
	var min_tree_y := INF
	for key_v in batches.keys():
		var key := str(key_v)
		if not key.begins_with("res|"):
			continue
		var sid := key.substr(4)
		sid_counts[sid] = int(sid_counts.get(sid, 0)) + 1
		if not (TREE_SIDS.has(sid)):
			forbidden_sids.append(sid)
		var b_v: Variant = batches[key_v]
		if not (b_v is Dictionary):
			continue
		var b: Dictionary = b_v
		var ids: Array = b.get("ids", [])
		var xforms: Array = b.get("xforms", [])
		for ix in range(ids.size()):
			var eid: int = int(ids[ix])
			var ed_v: Variant = refs.get(eid, {})
			var ed: Dictionary = ed_v if ed_v is Dictionary else {}
			var p: Vector2 = ed.get("pos", Vector2.ZERO)
			var expected: float = float(_game.call("height_at", p))
			var actual := 0.0
			if ix < xforms.size() and xforms[ix] is Transform3D:
				actual = (xforms[ix] as Transform3D).origin.y
			y_max_err = maxf(y_max_err, absf(actual - expected))
			min_tree_y = minf(min_tree_y, actual)
			tree_instances += 1
	_m["tree_batch_keys"] = str(batches.keys())
	_m["tree_sid_counts"] = sid_counts
	_m["tree_instances"] = tree_instances
	_m["tree_y_max_error_m"] = y_max_err
	_m["tree_min_y_m"] = min_tree_y
	check("tree_batch_instances_exact", tree_instances == TREE_COUNT,
		"Batch_*_res visible instances=%d expected=%d keys=%s" % [
			tree_instances, TREE_COUNT, str(batches.keys())])
	check("tree_y_on_terrain", tree_instances > 0 and y_max_err <= SAMPLE_EPS,
		"max |tree.y - game.height_at(pos)|=%s m eps=%s" % [str(y_max_err), str(SAMPLE_EPS)])
	check("trees_not_below_water", tree_instances > 0 and min_tree_y > WATER_LEVEL,
		"min tree y=%s m WATER_LEVEL=%s; fixture rows z=%d/%d are outside collar r=%s"
		% [str(min_tree_y), str(WATER_LEVEL), TREE_Z0, TREE_Z1, str(COLLAR_R)])

	var mine_nodes := 0
	for n in res_nodes:
		var t := str((n as Dictionary).get("type", ""))
		if t == "gold" or t == "iron" or t == "coal":
			mine_nodes += 1
	_m["mine_nodes"] = mine_nodes
	check("no_mines_added", mine_nodes == 0 and forbidden_sids.is_empty(),
		"mine res_nodes=%d non-tree res sids=%s (expected 0 / [])" % [
			mine_nodes, str(forbidden_sids)])

	# ---- P2: bounded basin, one height-aware plane, shore ids in UV2 ----------
	var water_cells: int = int(_m["water_cells"])
	check("water_cells_bounded", water_cells > 0 and water_cells < CELLS / 10,
		"height < %.2f m: %d cells / %d = %.4f (expected >0 and <10%%)" % [
			WATER_LEVEL, water_cells, CELLS, float(_m["water_fraction"])])
	var planes := _find_named(_terrain, "WaterPlane")
	var water3d_nodes := _find_named(_terrain, "Water3D")
	var water_v: Variant = stats.get("water", {})
	var water: Dictionary = water_v if water_v is Dictionary else {}
	var water_mod := str(water.get("module", ""))
	var height_aware := bool(water.get("height_aware", false))
	_m["water_module"] = water_mod
	_m["water_height_aware"] = height_aware
	_m["water_plane_count"] = planes.size()
	_m["water_3d_node_count"] = water3d_nodes.size()
	check("water_plane_single_height_aware", planes.size() == 1
		and water3d_nodes.size() == 1 and height_aware
		and water_mod.ends_with("water3d.gd"),
		"planes=%d Water3D=%d module=%s height_aware=%s" % [
			planes.size(), water3d_nodes.size(), water_mod, str(height_aware)])
	var has_sandsea := false
	var has_sandrock_or_rock := false
	for tid in SANDSEA_IDS:
		if int(uv2_hist_x.get(str(tid), 0)) > 0:
			has_sandsea = true
	for tid in SANDROCK_IDS + ROCK_IDS:
		if int(uv2_hist_x.get(str(tid), 0)) > 0:
			has_sandrock_or_rock = true
	_m["shore_sandsea_present"] = has_sandsea
	_m["shore_sandrock_or_rock_present"] = has_sandrock_or_rock
	check("shore_ids_in_uv2_hist", has_sandsea and has_sandrock_or_rock,
		"sandsea1/5/6 present=%s sandrock*/rock* present=%s hist=%s" % [
			str(has_sandsea), str(has_sandrock_or_rock), str(uv2_hist_x)])

	_setup_done = true
	if _headless:
		check("capture_image", null, "headless: GPU capture skipped", "SKIPPED")
		check("capture_saved", null, "headless: no PNG written", "SKIPPED")
		check("non_black_fraction", null, "headless: no PNG metrics", "SKIPPED")
		check("full_width_dark_rows", null, "headless: no PNG metrics", "SKIPPED")
		check("ground_mean_luma", null, "headless: no PNG metrics", "SKIPPED")
		check("ground_max_luma", null, "headless: no PNG metrics", "SKIPPED")
		finish()
		return
	if _png_path == "":
		check("capture_image", false, "windowed run needs --screenshot <abs.png> user arg")
		_fail_remaining(CHECK_NAMES.size() - 3, "NO_PNG_ARG", "no PNG user arg")
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


# Stub-owned windowed GPU readback; no main.tscn, no main's --screenshot saver
# (TEST-01 capture column for P0-C4; terrain3d_sandbox.gd:139-151).
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
		_fail_remaining(CHECK_NAMES.size() - 3, "BLANK_CAPTURE", "blank GPU texture")
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
		_fail_remaining(CHECK_NAMES.size() - 2, "SAVE_FAILED", "save_png failed")
		finish()
		return
	var ms := _image_metrics(img)
	ms["png_path"] = abs_png
	ms["bytes"] = FileAccess.get_file_as_bytes(abs_png).size()
	_m["png_metrics"] = ms
	_m["capture_source"] = "ComboTreesShoreViewport (stub-owned, windowed GPU)"
	check("non_black_fraction", float(ms["non_black_fraction"]) > 0.9,
		"non_black_fraction=%s (expected >0.9; smallmap_capture.py:26)" % str(ms["non_black_fraction"]))
	check("full_width_dark_rows", int(ms["full_width_dark_rows"]) == 0,
		"full_width_dark_rows=%d (expected 0; smallmap_capture.py:27-28, V3D_02 T2)" % int(ms["full_width_dark_rows"]))
	# DARKROW-ALL-01: water-bearing row (shore present) — the dark-row assert
	# above stays STRICT. Add P0-GATE-01's strict whole-frame luma gates too;
	# neither is weakened. PORT APPROX — no donor GPU A/B exists.
	check("ground_mean_luma", float(ms["mean_luma"]) >= 40.0,
		"mean_luma=%.3f (strict >=40; PORT APPROX — no donor GPU A/B exists)" % float(ms["mean_luma"]))
	check("ground_max_luma", float(ms["max_luma"]) >= 100.0,
		"max_luma=%.3f (strict >=100; PORT APPROX — no donor GPU A/B exists)" % float(ms["max_luma"]))
	_visual_checked = true
	finish()
