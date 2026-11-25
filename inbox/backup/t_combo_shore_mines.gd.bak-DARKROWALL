# TEST-C3 / t_combo_shore_mines.gd — COMBO shore + mines 64x64 atom.
#
# Owns ONLY this file (plus docs/coord_swarm_2026-11-25/reports/TEST_C3_report.md).
# No source, shader, asset, config, manifest, fixture, gate-file or git edit.
# AUTHORING ONLY: this file was never executed by this agent; no Godot job was
# submitted, no runner ticket was taken (docs/COMMANDS.md runner monopoly).
#
# Design sources (all read-only):
#   TEST-01 §"Test ladder" row C3
#     (docs/coord_swarm_2026-11-25/reports/TEST_01_smallmap_harness.md:218) —
#     "P2 + P3 union; water cells + ore counts; every ore position has
#     height > WATER_LEVEL; one water plane; mines not in water; shore masking
#     unchanged"; same 64² map (:169-173), windowed stub-owned capture (:190-197),
#     scaffolding/helper API (:228-255), blockers (:269-305).
#   TEST_MATRIX.md:24 (C3 row), :29-46 (V3D_02 refinement — reuse 64² harness,
#     bounded water basin, shore ids in UV2, ONE height-aware plane, no full-width
#     dark rows, mine sid resolves, ground unchanged outside mine bbox), :53-58
#     (one Godot at a time, no donor parity claim, second-agent re-check).
#   V3D_02 §"Piece-test ladder proposal" T2/T3/T4
#     (docs/coord_swarm_2026-11-25/reports/V3D_02_terrain_render_audit.md:146-148):
#     "exactly one water plane (WaterPlane), height_aware=true, shore ids in UV2.x
#     histogram, full-width dark rows=0"; "mine sid resolves, mine Y matches
#     terrain"; "no stacked water planes".
#   DTRN-03 §6.1 S1/S4/S5, §4.3 W2/W7, §5 F2/F8
#     (docs/coord_swarm_2026-11-25/reports/DTRN_03_donor_shore_water.md:466-488,
#      :393-401, :425-448) — one height-aware plane; water cells clamped to tile 0
#     remain a KNOWN pre-fix artifact (not claimed fixed here); donor sandsea1/5/6
#     are the live shore tiles.
#   Template / stub patterns: _template_test.gd:1-38; t_terrain3d.gd:12-14,41-46,
#     106-127,161-204; t_pick3d.gd:48-71; t_smallmap_terrain.gd:42-99,400-414;
#     sibling t_terrain_only.gd:44-162,256-315,351-382,596-642.
#   Module contracts: world3d_terrain.gd:95,451-488,680-708,721-764,841-848;
#     water3d.gd:19,148-168,200-219; world3d_entities.gd:113-118,205-270,
#     966-1014,1060-1093,1269-1315,1528-1552.
#   Tile ids are DONOR ATLAS INDICES, never invented constants: sandsea1=93,
#     sandsea5=97, sandsea6=98 (tile_index_atlas.manifest.json:2283-2284,
#     2379-2380,2403-2404; game.gd:1735-1736 SECTOR_TILES sector order).
#
# Fixture: synthetic, deterministic, IN-MEMORY 64x64 grid (NOT the real-boot
# small_map_64.json path — that is the S1 row). A bounded circular water basin
# (149 cells ~3.6 % of 4,096) sits at (20,20); its land-side collar carries
# oriented sandsea tile ids; six permanent ore nodes (2 gold / 2 iron / 2 coal)
# sit on known land cells outside the basin. NO trees, NO food, NO units.
# Every visual statement is PORT APPROX / internal consistency only; no donor
# GPU A/B frame exists (V3D_02 parity_guard), so no parity is claimed.
extends SceneTree

const MODULE_PATH := "res://scripts/world3d_terrain.gd"
const CAMERA_PATH := "res://scripts/camera3d.gd"
const ENTITIES_PATH := "res://scripts/world3d_entities.gd"
# Written by a parallel owner; loaded DYNAMICALLY, never by class_name
# (TEST-01 Blockers 10; t_terrain3d.gd:12-13). A same-shape local fallback is
# embedded below and used if this file is absent (noted in the report).
const HARNESS_PATH := "res://tests/fixtures/_smallmap_harness.gd"
const OUT_PATH := "res://tests/results/t_combo_shore_mines.json"

const GRID_W := 64
const GRID_H := 64
const CELLS := GRID_W * GRID_H
const TILE_M := 2.0                 # data.gd:23
const WATER_LEVEL := -0.25          # world3d_terrain.gd:95; donor literal UNVERIFIED
const BLK_WATER := 255              # game.gd:52
const GRASS_TILE := 0               # presets_summer.json:2 grass1
const NAMED_CELLS := 124            # V7-85 atlas manifest named_cells
const WINDOW_SIZE := Vector2i(1280, 720)   # data.gd:113-114; no CLI flag
const CAPTURE_FRAMES := 10          # TEST_MATRIX.md:32

# Bounded basin geometry (synthetic but donor-shaped: submerged centre,
# 0.15-height-unit wet strip, gentle ramp back to grass).
const BASIN_CX := 20
const BASIN_CZ := 20
const BASIN_R := 7.0                # submerged core: ~149 cells (3.6 % of 4,096)
const SHORE_R := 10.0               # land-side wet strip, 0.15 height units wide
const RAMP_R := 24.0                # gentle return to 1.5 m baseline
const BASIN_DEPTH := -0.55          # strictly below WATER_LEVEL (-0.25)
const SHORE_BAND := 0.15            # DTRN-03 C05: -0.1 - (-0.25)
const BASE_HEIGHT := 1.5

# Donor atlas indices (tile_index_atlas.manifest.json:2283/2379/2403) in the
# 8x45-degree sector order of game.gd:1735-1736 / texturemap.inc:503-511.
const SANDSEA1 := 93
const SANDSEA5 := 97
const SANDSEA6 := 98
const SECTOR_TILES := [SANDSEA6, SANDSEA6, SANDSEA1, SANDSEA5,
	SANDSEA6, SANDSEA6, SANDSEA1, SANDSEA5]
const SHORE_IDS := [SANDSEA1, SANDSEA5, SANDSEA6]

# [id, type, grid_x, grid_z] — all far outside the basin, all on land.
# Expected exact counts: gold 2, iron 2, coal 2; total 6.
const ORE_SITES := [
	[100, "gold", 6, 6],
	[101, "gold", 50, 10],
	[102, "iron", 10, 52],
	[103, "iron", 54, 54],
	[104, "coal", 4, 40],
	[105, "coal", 58, 28],
]
const EXPECTED_ORE := {"gold": 2, "iron": 2, "coal": 2}

# P0 baseline anchors (TEST_MATRIX.md:33-34; TEST-01.md:148-154,212;
# V3D_02:140,144). Combo may not change ANY of them.
const P0_SURFACES := 1
const P0_VERTICES := 4096
const P0_TRIANGLES := 7938
const P0_UV2_COUNT := 4096

const CHECK_NAMES := [
	"harness_stub_shape",
	"terrain_module_api",
	"camera_module_api",
	"entities_module_api",
	"build_ok",
	"p0_mesh_counts_unchanged",
	"water_cells_bounded",
	"single_height_aware_water_plane",
	"shore_ids_present",
	"ore_height_above_water",
	"ore_counts_exact",
	"ore_category_purity",
	"capture_image",
	"capture_saved",
	"non_black_fraction",
	"full_width_dark_rows",
]

# These four are never evaluated when setup aborts or the run is headless:
# report them UNVERIFIED, never as a measured FAIL (sibling t_terrain_shore.gd:104-107).
const CAPTURE_CHECK_NAMES := [
	"capture_image", "capture_saved", "non_black_fraction", "full_width_dark_rows",
]

# Embedded fallback with the SAME shape as res://tests/fixtures/_smallmap_harness.gd
# (TEST-01.md:230-239; helper StubGame :14-114, make_stub_game :134-149).
# Extends the real C3Game so a typed bind() would also work (t_terrain3d.gd:37-46).
class LocalStubGame extends C3Game:
	# ATOM-REPAIR: res_dirty / entities / res_nodes are inherited from C3Game
	# (game.gd:149,82,61). Redeclaring them was a parse error; the inherited
	# fields are used directly and keep the same types. resolve_mine_sid below
	# already matches the parent signature (game.gd:2685).
	var cmd_calls: Dictionary = {}
	var dump: Dictionary = {}
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

	# game.gd:2685-2702 mirror of the shared helper's resolve_mine_sid.
	func resolve_mine_sid(sid: String, pos: Vector2) -> String:
		if sid != "mine":
			return sid
		var best_type := ""
		var best_d := 4.0          # MINE_SITE_RADIUS, helper :10
		for n in res_nodes:
			var nd := n as Dictionary
			if nd == null or int(nd.get("max_hits", 0)) != 0:
				continue
			var t := str(nd.get("type", ""))
			if t != "gold" and t != "iron" and t != "coal":
				continue
			var p: Vector2 = nd.get("pos", Vector2.ZERO)
			var d: float = p.distance_to(pos)
			if d < best_d:
				best_d = d
				best_type = t
		return "mine_" + best_type if best_type != "" else "mine_gold"

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

var _id := "t_combo_shore_mines"
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
var _entities: Node = null
var _game: Object = null
var _heights := PackedFloat32Array()
var _tileblock := PackedByteArray()
var _res_nodes: Array = []
var _harness_source := ""
var _frame := 0
var _capture_pending := false
var _capturing := false
var _m: Dictionary = {}


# Variant `cond` lets a SKIP_CAPTURE row carry JSON null; only explicit false
# flips _ok (sibling t_terrain_only.gd:165-174).
func check(name: String, cond, detail: String = "", status: String = "") -> void:
	var st := status
	if st == "":
		st = "PASS" if cond == true else ("FAIL" if cond == false else "SKIPPED")
	_checks.append({"name": name, "passed": cond, "status": st, "detail": detail})
	if cond == false:
		_ok = false
	print("T_COMBO_SHORE_MINES %s %s - %s" % [st, name, detail])


func _fail_remaining(from_index: int, tag: String, reason: String) -> void:
	for i in range(from_index, CHECK_NAMES.size()):
		var n: String = CHECK_NAMES[i]  # ATOM-REPAIR: explicit type (Array is untyped)
		if CAPTURE_CHECK_NAMES.has(n):
			check(n, null, tag + ": capture UNVERIFIED — " + reason, "UNVERIFIED")
		else:
			check(n, false, tag + ": " + reason)


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
			"DisplayServer.get_name()==headless or no PNG user arg: state-only result"),
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
		push_error("t_combo_shore_mines: cannot write result: " + abs_path)
	print("T_COMBO_SHORE_MINES RESULT_JSON: " + abs_path)
	print("T_COMBO_SHORE_MINES RESULT: %s %d/%d evaluated, %d skipped" % [
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


# --------------------------------------------------------------- synthetic map
func _cell_pos(x: int, z: int) -> Vector2:
	return Vector2((float(x) + 0.5 - float(GRID_W) * 0.5) * TILE_M,
		(float(z) + 0.5 - float(GRID_H) * 0.5) * TILE_M)


func _shore_sector_id(dx: float, dz: float) -> int:
	# Donor vecangle +180 then 8 uniform 45° sectors (game.gd:1711-1736,
	# texturemap.inc:474-511). No RNG, no invented palette.
	var sector: int = int(floor((atan2(dz, dx) + PI) / (PI / 4.0))) % 8
	return int(SECTOR_TILES[sector])


func _make_grid() -> void:
	_heights.resize(CELLS)
	_tileblock.resize(CELLS)
	for z in range(GRID_H):
		for x in range(GRID_W):
			var i := z * GRID_W + x
			var dx := float(x) - float(BASIN_CX)
			var dz := float(z) - float(BASIN_CZ)
			var d := sqrt(dx * dx + dz * dz)
			var h := BASE_HEIGHT + 0.03 * sin(float(x) * 0.11) + 0.02 * cos(float(z) * 0.09)
			var tile: int = GRASS_TILE
			if d <= BASIN_R:
				h = BASIN_DEPTH
				tile = BLK_WATER            # game.gd:52; clamped to 0 by terrain
			elif d <= SHORE_R:
				h = WATER_LEVEL + SHORE_BAND * (d - BASIN_R) / (SHORE_R - BASIN_R)
				tile = _shore_sector_id(dx, dz)
			elif d <= RAMP_R:
				h = lerpf(WATER_LEVEL + SHORE_BAND, BASE_HEIGHT,
					(d - SHORE_R) / (RAMP_R - SHORE_R))
			_heights[i] = h
			_tileblock[i] = tile


func _make_ores() -> void:
	_res_nodes.clear()
	for s in ORE_SITES:
		var site: Array = s
		var x: int = int(site[2])
		var z: int = int(site[3])
		_res_nodes.append({
			"id": int(site[0]),
			"type": str(site[1]),
			"pos": _cell_pos(x, z),
			"kind": "res",
			"hits": 0,
			"max_hits": 0,              # permanent ore -> visible (_is_hidden, :1082)
		})


func _cell_of(p: Vector2) -> Vector2i:
	var x := clampi(roundi(p.x / TILE_M + float(GRID_W) * 0.5 - 0.5), 0, GRID_W - 1)
	var z := clampi(roundi(p.y / TILE_M + float(GRID_H) * 0.5 - 0.5), 0, GRID_H - 1)
	return Vector2i(x, z)


func _count_categories(nodes: Array) -> Dictionary:
	var out := {"wood": 0, "stone": 0, "mine": 0, "food": 0}
	for n in nodes:
		var t := ""
		if n is Dictionary:
			t = str((n as Dictionary).get("type", ""))
		elif n is Object:
			t = str((n as Object).get("type"))
		match t:
			"wood": out["wood"] = int(out["wood"]) + 1
			"stone": out["stone"] = int(out["stone"]) + 1
			"gold", "iron", "coal": out["mine"] = int(out["mine"]) + 1
			"food": out["food"] = int(out["food"]) + 1
	return out


# TEST-01 §Scaffolding item 1: prefer the shared helper; duplicate its shape
# locally if the parallel owner's file is absent.
func _make_stub_game() -> Object:
	if ResourceLoader.exists(HARNESS_PATH):
		var helper: Object = load(HARNESS_PATH)
		if helper != null and helper.has_method("make_stub_game"):
			var g: Object = helper.call("make_stub_game", GRID_W, GRID_H,
				_heights, _res_nodes, _tileblock)
			if g != null and is_instance_valid(g):
				_harness_source = "shared:" + HARNESS_PATH
				return g
	var local := LocalStubGame.new()
	local.MAP_W = GRID_W
	local.MAP_H = GRID_H
	local.height = _heights
	local.tileblock = _tileblock
	local.res_nodes = _res_nodes
	local.dump = {
		"map_w": GRID_W,
		"map_h": GRID_H,
		"height": Marshalls.raw_to_base64(_heights.to_byte_array()),
		"tileblock": Marshalls.raw_to_base64(_tileblock),
	}
	_harness_source = "embedded_local_stub"
	return local


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


func _api_ok(script: Script, methods: Array, tag: String) -> bool:
	if script == null or not script.can_instantiate():
		_m["api_missing_" + tag] = ["<script missing>"]
		return false
	var probe: Object = script.new()
	if probe == null:
		_m["api_missing_" + tag] = ["<new() failed>"]
		return false
	var missing: Array[String] = []
	for m in methods:
		if not probe.has_method(str(m)):
			missing.append(str(m))
	probe.free()
	_m["api_missing_" + tag] = missing
	return missing.is_empty()


# Mirrors smallmap_capture.py:21-39 (READ-ONLY) exactly as t_terrain_only.gd:351-381.
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
	_make_ores()
	_game = _make_stub_game()
	_m["harness_source"] = _harness_source
	var g_w: int = int(_game.get("MAP_W")) if _game != null else 0
	var g_h: int = int(_game.get("MAP_H")) if _game != null else 0
	var g_res: Array = _game.get("res_nodes") as Array if _game.get("res_nodes") is Array else []
	var shape_ok: bool = (_game != null and is_instance_valid(_game)
		and g_w == GRID_W and g_h == GRID_H
		and (_game.get("height") is PackedFloat32Array)
		and (_game.get("tileblock") is PackedByteArray)
		and g_res.size() == _res_nodes.size())
	check("harness_stub_shape", shape_ok,
		"source=%s MAP=%dx%d height/tileblock present=%s res_nodes=%d" % [
			_harness_source, str(g_w), str(g_h), str(shape_ok), g_res.size()])
	if not shape_ok:
		_fail_remaining(1, "STUB_SHAPE", "harness stub does not expose the expected shape")
		_setup_done = true
		finish()
		return

	# Windowed GPU target only; headless runs stay state-only (main.gd:1156-1158,
	# 1790-1800). Unlike P0, the WaterPlane is NOT hidden: shore is a measured layer.
	if not _headless:
		get_root().size = WINDOW_SIZE
		_capture_view = SubViewport.new()
		_capture_view.name = "ComboShoreMinesViewport"
		_capture_view.world_3d = World3D.new()
		_capture_view.size = WINDOW_SIZE
		_capture_view.render_target_update_mode = SubViewport.UPDATE_ONCE
		get_root().add_child(_capture_view)
	var parent: Node = _capture_view if _capture_view != null else get_root()

	var terrain_script := load(MODULE_PATH) as Script
	var camera_script := load(CAMERA_PATH) as Script
	var entities_script := load(ENTITIES_PATH) as Script
	var terrain_api := _api_ok(terrain_script,
		["bind", "build", "invalidate", "has_chunk_or_fallback", "height_at_world"], "terrain")
	check("terrain_module_api", terrain_api,
		"script=%s missing=%s" % [MODULE_PATH, str(_m.get("api_missing_terrain", []))])
	var camera_api := _api_ok(camera_script,
		["bind", "world_to_px", "screen_to_world", "set_zoom_target"], "camera")
	check("camera_module_api", camera_api,
		"script=%s missing=%s" % [CAMERA_PATH, str(_m.get("api_missing_camera", []))])
	var entities_api := _api_ok(entities_script,
		["bind", "sync", "add_resource", "remove"], "entities")
	check("entities_module_api", entities_api,
		"script=%s missing=%s" % [ENTITIES_PATH, str(_m.get("api_missing_entities", []))])
	if not terrain_api or not camera_api or not entities_api:
		_fail_remaining(4, "MODULE_MISSING", "terrain/camera/entities script or API unavailable")
		_setup_done = true
		finish()
		return

	# P2 + P3 union: terrain + real camera + entities(mines only). No world3d.gd,
	# no picking, no FX, no main.tscn boot, no trees/food/units.
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
	_camera.set_process(false)          # no edge-scroll mid-capture (camera3d.gd:484-581)
	_camera.make_current()

	_entities = entities_script.new() as Node
	_entities.name = "ResourceEntities"
	parent.add_child(_entities)
	_entities.call("bind", _game)
	for n in _res_nodes:
		_entities.call("add_resource", n)
	_entities.call("sync", 0.016)       # populates stats.resources/batches

	# ---- P0 mesh invariants must survive the combo (C3 = P2 + P3, no regression)
	var mi := _terrain.get_node_or_null("HeightmapTerrain") as MeshInstance3D
	var mesh: Mesh = mi.mesh if mi != null else null
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
	_m["p0_baseline"] = {"surfaces": P0_SURFACES, "vertices": P0_VERTICES,
		"triangles": P0_TRIANGLES, "uv2_count": P0_UV2_COUNT,
		"source": "TEST_MATRIX.md:33-34; TEST_01.md:148-154,212"}
	check("p0_mesh_counts_unchanged",
		surfaces == P0_SURFACES and vertices == P0_VERTICES
		and triangles == P0_TRIANGLES and uv2_count == P0_UV2_COUNT,
		"surf=%d verts=%d tris=%d uv2=%d (P0 %d/%d/%d/%d)" % [
			surfaces, vertices, triangles, uv2_count,
			P0_SURFACES, P0_VERTICES, P0_TRIANGLES, P0_UV2_COUNT])

	# ---- P2: bounded water basin, one height-aware plane, shore ids in UV2
	var water_cells := 0
	var water_tileblock := 0
	for i in range(CELLS):
		if _heights[i] < WATER_LEVEL:
			water_cells += 1
		if int(_tileblock[i]) == BLK_WATER:
			water_tileblock += 1
	_m["water_cells"] = water_cells
	_m["water_cell_fraction"] = float(water_cells) / float(CELLS)
	_m["water_tileblock_cells"] = water_tileblock
	_m["water_level_m"] = WATER_LEVEL
	check("water_cells_bounded", water_cells > 0 and water_cells * 10 < CELLS,
		"cells=%d (%.4f%% of %d), expected >0 and <10%%" % [
			water_cells, 100.0 * float(water_cells) / float(CELLS), CELLS])

	var planes := _find_named(parent, "WaterPlane")
	var water_nodes := _find_named(parent, "Water3D")
	var stats_v: Variant = _terrain.get("stats")
	var stats: Dictionary = stats_v if stats_v is Dictionary else {}
	var water_v: Variant = stats.get("water", {})
	var water: Dictionary = water_v if water_v is Dictionary else {}
	var wmod := str(water.get("module", ""))
	var height_aware := bool(water.get("height_aware", false))
	_m["water_plane_count"] = planes.size()
	_m["water_3d_node_count"] = water_nodes.size()
	_m["water_module"] = wmod
	_m["water_height_aware"] = height_aware
	_m["water_level_from_stats"] = stats.get("water_level_m", -1.0)
	check("single_height_aware_water_plane",
		planes.size() == 1 and water_nodes.size() == 1
		and wmod.ends_with("water3d.gd") and height_aware,
		"planes=%d Water3D=%d module=%s height_aware=%s" % [
			planes.size(), water_nodes.size(), wmod, str(height_aware)])

	var shore_hist := {}
	var uv2_x_min := INF
	var uv2_x_max := -INF
	var out_of_atlas := 0
	if uv2v is PackedVector2Array:
		var uv2: PackedVector2Array = uv2v
		for i in range(uv2.size()):
			var t: Vector2 = uv2[i]
			var tid := int(t.x)
			uv2_x_min = minf(uv2_x_min, t.x)
			uv2_x_max = maxf(uv2_x_max, t.x)
			if tid < 0 or tid > NAMED_CELLS - 1:
				out_of_atlas += 1
			shore_hist[str(tid)] = int(shore_hist.get(str(tid), 0)) + 1
	var shore_seen := {}
	var shore_cells := 0
	for sid in SHORE_IDS:
		var n: int = int(shore_hist.get(str(sid), 0))
		shore_seen[str(sid)] = n
		shore_cells += n
	_m["uv2_x_min"] = uv2_x_min
	_m["uv2_x_max"] = uv2_x_max
	_m["uv2_x_out_of_atlas"] = out_of_atlas
	_m["shore_id_hist"] = shore_seen
	_m["shore_id_cells"] = shore_cells
	_m["tile_index_hist_top"] = str(stats.get("tile_index", {})).substr(0, 400)
	check("shore_ids_present", shore_cells > 0 and out_of_atlas == 0,
		"sandsea1/5/6 (93/97/98) cells=%d hist=%s out_of_atlas=%d" % [
			shore_cells, str(shore_seen), out_of_atlas])

	# ---- P3: every ore position on land; exact counts; category purity
	var ore_heights := {}
	var ore_below := 0
	for n in _res_nodes:
		var nd := n as Dictionary
		var p: Vector2 = nd.get("pos", Vector2.ZERO)
		var cell := _cell_of(p)
		var h: float = _heights[cell.y * GRID_W + cell.x]
		ore_heights[str(nd.get("id", -1))] = {
			"type": str(nd.get("type", "")), "cell": [cell.x, cell.y],
			"height_m": h, "above_water": h > WATER_LEVEL,
		}
		if h <= WATER_LEVEL:
			ore_below += 1
	_m["ore_heights"] = ore_heights
	_m["ore_below_water"] = ore_below
	check("ore_height_above_water", ore_below == 0,
		"mines with height <= %.2f m: %d of %d (C3: mines not in water)" % [
			WATER_LEVEL, ore_below, _res_nodes.size()])

	var cats := _count_categories(_res_nodes)
	_m["res_node_categories"] = cats
	_m["res_node_total"] = _res_nodes.size()

	# Instance counts come from the batches world3d_entities actually built
	# (node names at :966, visible_instance_count at :961/:1014), not from the
	# input list alone. Tree/stone/food batches must not exist at all.
	var counts := {"gold": 0, "iron": 0, "coal": 0}
	var other_batches: Array[String] = []
	var all_batch_nodes: Array[Node] = []
	var stack: Array[Node] = [_entities]
	while not stack.is_empty():
		var cur: Node = stack.pop_back()
		if cur is MultiMeshInstance3D:
			all_batch_nodes.append(cur)
		for c in cur.get_children():
			stack.append(c)
	for b in all_batch_nodes:
		var mmi := b as MultiMeshInstance3D
		var nm := mmi.name
		var vis: int = mmi.multimesh.visible_instance_count if mmi.multimesh != null else -1
		var matched := false
		for ty in EXPECTED_ORE:
			var prefix := "Batch_res_mine_" + str(ty)
			if nm.begins_with(prefix):
				counts[str(ty)] = int(counts[str(ty)]) + vis
				matched = true
		if not matched and nm.begins_with("Batch_res_"):
			other_batches.append(nm)
	var ent_stats_v: Variant = _entities.get("stats")
	var ent_stats: Dictionary = ent_stats_v if ent_stats_v is Dictionary else {}
	_m["mine_instance_counts"] = counts
	_m["mine_total_instances"] = (int(counts["gold"]) + int(counts["iron"]) + int(counts["coal"]))
	_m["unexpected_res_batches"] = other_batches
	_m["entities_stats"] = {"resources": ent_stats.get("resources", -1),
		"units": ent_stats.get("units", -1), "buildings": ent_stats.get("buildings", -1)}
	var exact := true
	for ty in EXPECTED_ORE:
		if int(counts[str(ty)]) != int(EXPECTED_ORE[str(ty)]):
			exact = false
	check("ore_counts_exact", exact
		and int(ent_stats.get("resources", -1)) == int(_res_nodes.size())
		and int(ent_stats.get("units", -1)) == 0
		and int(ent_stats.get("buildings", -1)) == 0,
		"gold=%d iron=%d coal=%d expected=%s stats.resources=%s units=%s buildings=%s" % [
			int(counts["gold"]), int(counts["iron"]), int(counts["coal"]),
			str(EXPECTED_ORE), str(ent_stats.get("resources", -1)),
			str(ent_stats.get("units", -1)), str(ent_stats.get("buildings", -1))])

	# Category purity measured twice: on the input res_nodes AND on the render
	# batches (no tree/stone/food/field batch may exist in a C3 combo).
	_m["foreign_res_batches"] = other_batches
	check("ore_category_purity",
		int(cats["wood"]) == 0 and int(cats["stone"]) == 0
		and int(cats["food"]) == 0 and int(cats["mine"]) == _res_nodes.size()
		and other_batches.is_empty(),
		"wood=%d stone=%d food=%d mine=%d; foreign_batches=%s (expected only mine_* )" % [
			int(cats["wood"]), int(cats["stone"]), int(cats["food"]),
			int(cats["mine"]), str(other_batches)])

	_setup_done = true
	if _headless:
		finish()                # state-only; SKIP_CAPTURE, never a visual PASS
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
# (TEST-01 §"Test ladder" P0-C4 capture column; terrain3d_sandbox.gd:139-151;
# testbridge.gd:277-308). No CPU fallback on a blank frame (main.gd:1846-1853).
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
	_m["capture_source"] = "ComboShoreMinesViewport (stub-owned, windowed GPU)"
	check("non_black_fraction", float(ms["non_black_fraction"]) > 0.9,
		"non_black_fraction=%s (expected >0.9; smallmap_capture.py:26)" % str(ms["non_black_fraction"]))
	check("full_width_dark_rows", int(ms["full_width_dark_rows"]) == 0,
		"full_width_dark_rows=%d (expected 0; smallmap_capture.py:27-28)" % int(ms["full_width_dark_rows"]))
	_visual_checked = true
	finish()
