extends SceneTree

# TEST-C4 — last combination row of the smallest-map piece/combo ladder.
#
# what this atom is
# -----------------
# A 64x64 STUB scene: P0 (terrain) + ~20 trees (P1) + a bounded water / sand /
# rock shore (P2) + gold / iron / coal mines (P3). No units, no buildings, no
# real game boot, no generator. Every P0-P3 structural invariant is asserted in
# the SAME run, together with the T4-only guards (no stacked water planes, no
# new seam class, non-black > 0.9, mean luma recorded, draw calls recorded).
#
# ownership / authority
# ---------------------
# Owns ONLY this file plus
# docs/coord_swarm_2026-11-25/reports/TEST_C4_report.md.
# No Godot run, no runner ticket, no shared code, manifest, config or gate edit.
# This row is the LAST combination row (P0->P1->P2->P3->C1->C2->C3->C4->S1->FINAL)
# and is the ONLY combo whose PNG may feed final visual review — still subject
# to the mandatory second-agent capture re-check (TEST_MATRIX.md:58).
# No donor parity is claimed: there is no donor GPU A/B frame in this project
# (V3D_02 report parity_guard, line 14; TEST_MATRIX.md:32-34,56-57).
#
# harness helper
# --------------
# TEST_01_smallmap_harness.md:228-239 proposes a shared, single-owner helper
# variant3d/tests/fixtures/_smallmap_harness.gd with make_stub_game(
# w, h, height, res_nodes, tileblock). It is loaded DYNAMICALLY here (no
# class_name — .godot class cache rule, TEST_01 blockers #10, t_terrain3d.gd:12-13).
# It was absent when this atom was designed, but a parallel owner landed it
# during authoring as `extends RefCounted` with a STATIC make_stub_game()
# (_smallmap_harness.gd:118-128). That factory is called on the Script object
# first; an embedded minimal fallback stays available if the helper is absent
# or incompatible. Which path was used is recorded in the result JSON
# ("harness.mode": "dynamic_load" | "embedded_fallback").
#
# launch form (launch itself is NOT performed by this authoring task)
# ------------------------------------------------------------------
#   python variant3d\tools\godot_runner.py run --id TEST-01-C4 --timeout 25 -- \
#     -- --path variant3d --script res://tests/t_combo_all.gd -- \
#       --png <ABS>/smallmap64_combo_all.png --frames 10
# Windowed (no --headless) is MANDATORY: headless has no GPU canvas and the
# capture branch returns a SKIPPED_HEADLESS result instead of a fake PASS.
# Layer toggles (user args, after the second --):
#   --no-trees   omit the 20 wood resource nodes
#   --no-shore   flatten the basin + omit sandsea*/sandrock* tile ids
#                (the terrain module still creates ONE water plane — see
#                 world3d_terrain.gd:760-765; this flag edits stub construction
#                 only, never module code)
#   --no-mines   omit the 9 gold/iron/coal resource nodes
#   --png PATH   absolute output PNG (default: user://t_combo_all.png)
#   --frames N   capture after N post-draw frames (default 10, TEST_MATRIX.md:32)
#   --width N / --height N  override the capture size (default Data window)
# If a runner cannot pass user args, the same toggles are achieved by editing
# _with_trees / _with_shore / _with_mines and the spot tables below.

const TERRAIN_PATH := "res://scripts/world3d_terrain.gd"
const ENTITIES_PATH := "res://scripts/world3d_entities.gd"
const HARNESS_PATH := "res://tests/fixtures/_smallmap_harness.gd"
const ATLAS_MANIFEST := "res://assets/terrain/atlas/tile_index_atlas.manifest.json"
const PRESETS_PATH := "res://assets/terrain/structs/presets_summer.json"
const OUT_PATH := "res://tests/results/t_combo_all.json"

const Data = preload("res://scripts/data.gd")

const GRID := 64                       # TERRAIN_SMALL_maps 64^2 ladder map
const CELLS := GRID * GRID             # 4096
const TILE_M := 2.0                    # data.gd:23 / world3d_terrain.gd:93
const BLK_WATER := 255                 # game.gd:52 (port constant, not a donor value)
const TREE_COUNT := 20                 # TEST_01 C4 row / P1 "N=~20"
const MINES_PER_KIND := 3              # gold / iron / coal
const MINE_KINDS := ["gold", "iron", "coal"]
const BASIN_TILE := Vector2(16.0, 44.0)  # stub geometry, test-only
const BASIN_R := 7.0
const SHORE_R := 9.0
const EPS_M := 0.02
const U8_8 := 8.0 / 255.0             # smallmap_capture.py:26 threshold, normalised
const U8_20 := 20.0 / 255.0           # smallmap_capture.py:28 threshold, normalised
const SAMPLE_STEP := 4                # in-atom image sampling stride

# Embedded fallback stub. Extends the REAL C3Game so its height_at() (game.gd:
# 1893-1907) is the same bilinear reference the entities module uses, and so a
# typed bind(game: C3Game) would still work. All cmd_* methods are overridden
# with counters so "no side effects" is measured, not assumed (t_pick3d.gd:53-146).
class StubGame extends C3Game:
	# ATOM-REPAIR: res_dirty is inherited from C3Game (game.gd:149); redeclaring
	# it was a parse error. The inherited field is used directly.
	var cmd_calls: Dictionary = {}
	var dump: Dictionary = {}
	var map_w: int = 0
	var map_h: int = 0

	func _bump(m: String) -> void:
		cmd_calls[m] = int(cmd_calls.get(m, 0)) + 1

	func total_cmd_calls() -> int:
		var n := 0
		for v in cmd_calls.values():
			n += int(v)
		return n

	func pick_radius(_e) -> float:
		return 1.0

	# Exact signatures from game.gd:2152,2839-4239 — overriding with a different
	# arity is a GDScript error, so each one mirrors the real method.
	func cmd_sow(mill: Dictionary) -> int:
		_bump("cmd_sow")
		return 0
	func cmd_move(e: Dictionary, pos: Vector2) -> void:
		_bump("cmd_move")
	func cmd_attack(e: Dictionary, target: Dictionary) -> void:
		_bump("cmd_attack")
	func cmd_attack_move(e: Dictionary, pos: Vector2) -> void:
		_bump("cmd_attack_move")
	func cmd_gather(e: Dictionary, res_node: Dictionary) -> void:
		_bump("cmd_gather")
	func cmd_resow(e: Dictionary, node: Dictionary) -> void:
		_bump("cmd_resow")
	func cmd_build(e: Dictionary, site: Dictionary) -> void:
		_bump("cmd_build")
	func cmd_stand_ground(e: Dictionary) -> void:
		_bump("cmd_stand_ground")
	func cmd_no_stand_ground(e: Dictionary) -> void:
		_bump("cmd_no_stand_ground")
	func cmd_hold_fire(e: Dictionary, on: bool) -> void:
		_bump("cmd_hold_fire")
	func cmd_engage(e: Dictionary) -> void:
		_bump("cmd_engage")
	func cmd_stop(e: Dictionary) -> void:
		_bump("cmd_stop")
	func cmd_guard(e: Dictionary, target: Dictionary) -> void:
		_bump("cmd_guard")
	func cmd_cancel_guard(e: Dictionary) -> void:
		_bump("cmd_cancel_guard")
	func cmd_patrol(e: Dictionary, a: Vector2, b: Vector2) -> void:
		_bump("cmd_patrol")
	func cmd_attack_ground(e: Dictionary, pos: Vector2) -> void:
		_bump("cmd_attack_ground")
	func cmd_enter(e: Dictionary, b: Dictionary) -> void:
		_bump("cmd_enter")
	func cmd_unload(b: Dictionary) -> void:
		_bump("cmd_unload")
	func cmd_replenish(off: Dictionary) -> int:
		_bump("cmd_replenish")
		return 0
	func cmd_form_size(off: Dictionary, size: int) -> void:
		_bump("cmd_form_size")
	func cmd_make_gate(w: Dictionary) -> void:
		_bump("cmd_make_gate")
	func cmd_gate_toggle(g: Dictionary) -> void:
		_bump("cmd_gate_toggle")
	func cmd_repair(pe: Dictionary, b: Dictionary) -> void:
		_bump("cmd_repair")
	func cmd_delete(e: Dictionary) -> void:
		_bump("cmd_delete")

var _id := "t_combo_all"
var _checks: Array[Dictionary] = []
var _ok := true
var _finished := false
var _status := "NOT_RUN"

var _with_trees := true
var _with_shore := true
var _with_mines := true
var _frames := 10
var _png_path := ""
var _capture_w := Data.WINDOW_WIDTH
var _capture_h := Data.WINDOW_HEIGHT

var _harness_script: Script = null
var _harness_mode := "embedded_fallback"
var _harness_note := ""

var _heights := PackedFloat32Array()
var _tileblock := PackedByteArray()
var _water_cells := 0
var _shore_cells := 0
var _tile_ids := {"grass": 0, "sandsea": -1, "sandrock": -1, "manifest_ok": false}
var _water_level := -0.25
var _nodes: Array[Dictionary] = []
var _expected_sids := {}          # id -> sid, resolved from the entities module
var _measured := {}


func check(name: String, cond: bool, detail: String = "") -> void:
	_checks.append({"name": name, "passed": cond, "detail": detail})
	if not cond:
		_ok = false
	print("T_COMBO_ALL %s %s - %s" % ["PASS" if cond else "FAIL", name, detail])


func _arg_value(flag: String) -> String:
	for src in [OS.get_cmdline_user_args(), OS.get_cmdline_args()]:
		var args := PackedStringArray(src)
		for i in range(args.size()):
			if str(args[i]) == flag and i + 1 < args.size():
				return str(args[i + 1])
	return ""


func _has_flag(flag: String) -> bool:
	for src in [OS.get_cmdline_user_args(), OS.get_cmdline_args()]:
		for a in PackedStringArray(src):
			if str(a) == flag:
				return true
	return false


func _read_json(path: String) -> Variant:
	var abs_path := ProjectSettings.globalize_path(path)
	if not FileAccess.file_exists(abs_path):
		return null
	var f := FileAccess.open(abs_path, FileAccess.READ)
	if f == null:
		return null
	var text := f.get_as_text()
	f.close()
	return JSON.parse_string(text)


func _finish(status: String) -> void:
	if _finished:
		return
	_finished = true
	_status = status
	var passes := 0
	for c in _checks:
		if bool(c.get("passed", false)):
			passes += 1
	var out := {
		"id": _id,
		"passed": _ok if status == "COMPLETED" else false,
		"status": status,
		"passes": passes,
		"total": _checks.size(),
		"checks": _checks,
		"measured": _measured,
		"harness": {
			"path": HARNESS_PATH,
			"mode": _harness_mode,
			"note": _harness_note,
		},
		"toggles": {
			"trees": _with_trees,
			"shore": _with_shore,
			"mines": _with_mines,
		},
		"ladder_position": "C4 — LAST combination row; the only combo that may feed final visual review",
		"png": _png_path,
		"script_error_note": "external-only: python variant3d\\tools\\smallmap_capture.py scan-stderr <runner stderr.txt>",
		"visual_parity": "UNVERIFIED — no donor GPU A/B frame; second-agent capture re-check required",
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
		push_error("t_combo_all: cannot write result " + abs_path)
	print("T_COMBO_ALL RESULT_JSON: " + abs_path)
	print("T_COMBO_ALL RESULT: %s %s %d/%d" % [status, "PASS" if _ok else "FAIL", passes, _checks.size()])
	# Deferred quit always — never a bare quit() from _initialize() (README.md:3-33).
	# A skipped headless run exits 0 (deliberate skip, not a PASS claim).
	call_deferred("quit", 0 if (status == "SKIPPED_HEADLESS" or _ok) else 1)


# ------------------------------------------------------------------ harness
func _load_harness() -> void:
	if ResourceLoader.exists(HARNESS_PATH):
		var s := load(HARNESS_PATH) as Script
		if s != null and s.can_instantiate():
			_harness_script = s
			_harness_mode = "dynamic_load"
			_harness_note = "loaded " + HARNESS_PATH
			return
	_harness_mode = "embedded_fallback"
	_harness_note = ("helper absent or unusable at " + HARNESS_PATH
		+ "; using the minimal embedded StubGame builder in this atom "
		+ "(helper is owned by another slot — not edited here)")
	print("T_COMBO_ALL NOTE: " + _harness_note)


func _valid_stub(g) -> bool:
	if not (g is Node):
		return false
	if int(g.get("MAP_W") if g.get("MAP_W") != null else 0) != GRID:
		return false
	if int(g.get("MAP_H") if g.get("MAP_H") != null else 0) != GRID:
		return false
	if not (g.get("height") is PackedFloat32Array):
		return false
	if not (g.get("tileblock") is PackedByteArray):
		return false
	if not g.has_method("height_at"):
		return false
	return true


func _resolve_tile_ids() -> void:
	var parsed: Variant = _read_json(PRESETS_PATH)  # ATOM-REPAIR: _read_json returns Variant
	if parsed is Array:
		var names: Array = parsed
		_tile_ids["grass"] = maxi(0, names.find("grass1"))
		_tile_ids["sandsea"] = names.find("sandsea1")
		_tile_ids["sandrock"] = names.find("sandrock1")
		_tile_ids["manifest_ok"] = true
	_tile_ids["source"] = PRESETS_PATH + " (manifest:index_dictionary, lines 2-125)"
	print("T_COMBO_ALL TILE_IDS: " + str(_tile_ids))


func _make_heights_and_tiles() -> void:
	_heights = PackedFloat32Array()
	_heights.resize(CELLS)
	_tileblock = PackedByteArray()
	_tileblock.resize(CELLS)
	var grass := int(_tile_ids.get("grass", 0))
	var sandsea := int(_tile_ids.get("sandsea", -1))
	var sandrock := int(_tile_ids.get("sandrock", -1))
	_water_cells = 0
	_shore_cells = 0
	for z in range(GRID):
		for x in range(GRID):
			var i := z * GRID + x
			var base := 1.0 + 0.45 * sin(float(x) * 0.11) * cos(float(z) * 0.09) \
				+ 0.12 * sin(float(x + z) * 0.23)
			var d := Vector2(float(x), float(z)).distance_to(BASIN_TILE)
			var y := base
			var tid := grass
			if _with_shore and d <= BASIN_R:
				y = _water_level - 1.0
				tid = BLK_WATER
				_water_cells += 1
			elif _with_shore and d <= SHORE_R:
				y = base + 0.30
				if sandsea >= 0 and d <= BASIN_R + 1.0:
					tid = sandsea
				elif sandrock >= 0:
					tid = sandrock
				_shore_cells += 1
			if tid < 0:
				tid = grass
			_heights[i] = y
			_tileblock[i] = tid


func _make_nodes() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var next_id := 1
	if _with_trees:
		for z in [6, 12, 18, 24, 56]:
			for x in [8, 20, 32, 44]:
				out.append({
					"id": next_id, "kind": "res", "type": "wood",
					"pos": Vector2((float(x) + 0.5) * TILE_M,
						(float(z) + 0.5) * TILE_M),
					"hits": 1, "max_hits": 0,
				})
				next_id += 1
	if _with_mines:
		var spots := {
			"gold": [[50, 10], [54, 12], [58, 10]],
			"iron": [[50, 30], [54, 32], [58, 30]],
			"coal": [[50, 48], [54, 50], [58, 48]],
		}
		for kind in MINE_KINDS:
			for s in spots[kind]:
				out.append({
					"id": next_id, "kind": "res", "type": str(kind),
					"pos": Vector2((float(s[0]) + 0.5) * TILE_M,
						(float(s[1]) + 0.5) * TILE_M),
					"hits": 1, "max_hits": 0,
				})
				next_id += 1
	return out


func _make_game() -> Node:
	if _harness_script != null:
		# The landed helper is `extends RefCounted` with STATIC factories
		# (_smallmap_harness.gd:118-128); call on the Script object first, then
		# tolerate an instance-method shape. Same pattern as t_terrain_only.gd:271-286.
		var caller: Object = _harness_script
		if not caller.has_method("make_stub_game"):
			var inst: Object = _harness_script.new()
			if inst != null and inst.has_method("make_stub_game"):
				caller = inst
		if caller != null and caller.has_method("make_stub_game"):
			# Signature: make_stub_game(w, h, height, res_nodes, tileblock)
			var g = caller.call("make_stub_game", GRID, GRID,
				_heights, Array(_nodes), _tileblock)
			if _valid_stub(g):
				_harness_note += "; shared make_stub_game() returned a valid stub"
				return g as Node
			_harness_note += "; make_stub_game() incompatible -> embedded fallback"
		else:
			_harness_note += "; helper has no make_stub_game() -> embedded fallback"
	var g2 := StubGame.new()
	g2.MAP_W = GRID
	g2.MAP_H = GRID
	g2.map_w = GRID
	g2.map_h = GRID
	g2.height = _heights
	g2.tileblock = _tileblock
	g2.res_nodes = Array(_nodes)
	g2.res_dirty = 1
	var b64 := Marshalls.raw_to_base64(_heights.to_byte_array())
	var tb64 := Marshalls.raw_to_base64(_tileblock)
	g2.dump = {"map_w": GRID, "map_h": GRID, "height": b64, "tileblock": tb64}
	return g2


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


func _count_class(root: Node, cls: String) -> int:
	var n := 0
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var cur: Node = stack.pop_back()
		if cur.is_class(cls):
			n += 1
		for c in cur.get_children():
			stack.append(c)
	return n


func _find_full_mesh(root: Node) -> Array:
	var found: Array = []
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n is MeshInstance3D:
			var m: Mesh = (n as MeshInstance3D).mesh
			if m is ArrayMesh and m.get_surface_count() > 0:
				var arr: Array = m.surface_get_arrays(0)
				if arr.size() > Mesh.ARRAY_VERTEX:
					var vs = arr[Mesh.ARRAY_VERTEX]
					if vs != null and int(vs.size()) == CELLS:
						found.append(n)
		for c in n.get_children():
			stack.append(c)
	return found


func _grid_y_at(pos: Vector2) -> float:
	var fx := clampf(pos.x / TILE_M - 0.5, 0.0, float(GRID - 1))
	var fz := clampf(pos.y / TILE_M - 0.5, 0.0, float(GRID - 1))
	var x0 := int(fx)
	var z0 := int(fz)
	var x1 := mini(x0 + 1, GRID - 1)
	var z1 := mini(z0 + 1, GRID - 1)
	var tx := fx - float(x0)
	var tz := fz - float(z0)
	var h00 := _heights[z0 * GRID + x0]
	var h10 := _heights[z0 * GRID + x1]
	var h01 := _heights[z1 * GRID + x0]
	var h11 := _heights[z1 * GRID + x1]
	return h00 + (h10 - h00) * tx + (h01 - h00) * tz + (h00 - h10 - h01 + h11) * tx * tz


func _world_of(pos: Vector2) -> Vector2:
	return pos - Vector2(float(GRID) * TILE_M * 0.5, float(GRID) * TILE_M * 0.5)


func _image_metrics(img: Image) -> Dictionary:
	var w := img.get_width()
	var h := img.get_height()
	var samples := 0
	var non_black := 0
	var luma_sum := 0.0
	var row_hits := PackedInt32Array()
	var col_hits := PackedInt32Array()
	row_hits.resize(h)
	col_hits.resize(w)
	row_hits.fill(0)
	col_hits.fill(0)
	var row_samples := 0
	var col_samples := 0
	for y in range(0, h, SAMPLE_STEP):
		row_samples += 1
		for x in range(0, w, SAMPLE_STEP):
			var c := img.get_pixel(x, y)
			var lum := 0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b
			samples += 1
			luma_sum += lum
			if c.r > U8_8 or c.g > U8_8 or c.b > U8_8:
				non_black += 1
			if lum < U8_20:
				row_hits[y] += 1
				col_hits[x] += 1
	col_samples = int(ceil(float(h) / float(SAMPLE_STEP)))
	var dark_rows := 0
	for y in range(h):
		if row_samples > 0 and float(row_hits[y]) / float(row_samples) > 0.90:
			dark_rows += 1
	var dark_cols := 0
	for x in range(w):
		if col_samples > 0 and float(col_hits[x]) / float(col_samples) > 0.90:
			dark_cols += 1
	var mean_luma := luma_sum / float(maxi(1, samples))
	return {
		"width": w, "height": h,
		"sampled_pixels": samples,
		"non_black_fraction": float(non_black) / float(maxi(1, samples)),
		"mean_luma_0_1": mean_luma,
		"mean_luma_0_255": mean_luma * 255.0,
		"full_width_dark_rows": dark_rows,
		"full_height_dark_cols": dark_cols,
		"sample_stride": SAMPLE_STEP,
		"note": "in-atom approximation of smallmap_capture.py:21-39; external stats command remains authoritative",
	}


# ---------------------------------------------------------------- main body
func _initialize() -> void:
	if _finished:
		return
	_with_trees = not _has_flag("--no-trees")
	_with_shore = not _has_flag("--no-shore")
	_with_mines = not _has_flag("--no-mines")
	var farg := _arg_value("--frames")
	if farg != "":
		_frames = clampi(int(farg), 1, 240)
	var warg := _arg_value("--width")
	var harg := _arg_value("--height")
	if warg != "":
		_capture_w = clampi(int(warg), 64, 4096)
	if harg != "":
		_capture_h = clampi(int(harg), 64, 4096)
	_png_path = _arg_value("--png")
	if _png_path == "":
		_png_path = ProjectSettings.globalize_path("user://t_combo_all.png")
	elif _png_path.begins_with("res://"):
		_png_path = ProjectSettings.globalize_path(_png_path)

	# Headless guard — the 3D PNG path needs a real GPU canvas (TEST_01
	# blockers #2, t_forest_bake_render.gd:35-41, main.gd:1156-1158).
	if DisplayServer.get_name() == "headless":
		print("T_COMBO_ALL: headless — 3D capture skipped; re-run WINDOWED (no --headless)")
		check("headless_guard", false,
			"no GPU canvas; SKIPPED_HEADLESS is not a PASS and writes no PNG")
		_finish("SKIPPED_HEADLESS")
		return

	_load_harness()
	_resolve_tile_ids()

	# Water level is READ from the terrain module's own stats, never invented.
	var terrain_script := load(TERRAIN_PATH) as Script
	check("terrain_module_load", terrain_script != null and terrain_script.can_instantiate(),
		TERRAIN_PATH)
	if terrain_script == null:
		_finish("ABORTED_MODULE_MISSING")
		return
	var entities_script := load(ENTITIES_PATH) as Script
	check("entities_module_load", entities_script != null and entities_script.can_instantiate(),
		ENTITIES_PATH)
	if entities_script == null:
		_finish("ABORTED_MODULE_MISSING")
		return
	var manifest: Variant = _read_json(ATLAS_MANIFEST)  # ATOM-REPAIR: _read_json returns Variant
	var atlas_grid: Array = []
	var named_cells := 124
	if manifest is Dictionary:
		var at: Dictionary = (manifest as Dictionary).get("atlas", {})
		atlas_grid = at.get("grid", [])
		named_cells = int(at.get("named_cells", 124))
	check("atlas_manifest_read", manifest is Dictionary and atlas_grid.size() == 2,
		ATLAS_MANIFEST + " grid=" + str(atlas_grid) + " named_cells=" + str(named_cells))

	var probe: Node = terrain_script.new() as Node
	if probe != null:
		probe.free()
	_water_level = float(terrain_script.get_script_constant_map().get("WATER_LEVEL", -0.25))
	_measured["water_level_m_from_module"] = _water_level
	_measured["water_level_source"] = TERRAIN_PATH + ":95 (mapgen.gd:29 port literal, donor UNVERIFIED)"

	_make_heights_and_tiles()
	_nodes = _make_nodes()
	var game := _make_game()
	root.add_child(game)
	check("stub_game_valid", _valid_stub(game),
		"64x64 stub; res_nodes=%d; harness=%s" % [_nodes.size(), _harness_mode])

	var terrain: Node = terrain_script.new() as Node
	if terrain == null:
		check("terrain_instantiate", false, "terrain script.new() returned null")
		_finish("ABORTED_SETUP_FAILED")
		return
	root.add_child(terrain)
	terrain.call("bind", game)
	var built := bool(terrain.call("build"))
	check("build_ok", built, "world3d_terrain.build() returned " + str(built))
	if not built:
		_finish("ABORTED_SETUP_FAILED")
		return

	var ents: Node = entities_script.new() as Node
	if ents == null:
		check("entities_instantiate", false, "entities script.new() returned null")
		_finish("ABORTED_SETUP_FAILED")
		return
	root.add_child(ents)
	ents.call("bind", game)
	for n in _nodes:
		var sid := str(ents.call("_resource_sid", str(n.get("type", "")), n.get("pos", Vector2.ZERO)))
		_expected_sids[int(n.get("id", -1))] = sid
		ents.call("add_resource", n)
	ents.call("sync", 0.0)

	# ---- P0: terrain mesh / atlas / shader / height -------------------------
	var meshes := _find_full_mesh(terrain)
	_measured["full_grid_mesh_count"] = meshes.size()
	check("single_terrain_mesh", meshes.size() == 1,
		"full-grid MeshInstance3D nodes=%d (expected 1)" % meshes.size())
	var mi: MeshInstance3D = null
	if meshes.size() == 1:
		mi = meshes[0] as MeshInstance3D
	var mesh: Mesh = null
	if mi != null:
		mesh = mi.mesh
	var surfaces := -1
	if mesh != null:
		surfaces = mesh.get_surface_count()
	check("mesh_single_surface", surfaces == 1, "surfaces=%d (expected 1)" % surfaces)
	var arrs: Array = []
	if surfaces > 0:
		arrs = mesh.surface_get_arrays(0)
	var vv = null
	if arrs.size() > Mesh.ARRAY_VERTEX:
		vv = arrs[Mesh.ARRAY_VERTEX]
	var iv = null
	if arrs.size() > Mesh.ARRAY_INDEX:
		iv = arrs[Mesh.ARRAY_INDEX]
	var uv2v = null
	if arrs.size() > Mesh.ARRAY_TEX_UV2:
		uv2v = arrs[Mesh.ARRAY_TEX_UV2]
	var nverts := -1
	if vv != null:
		nverts = int(vv.size())
	var ntris := -1
	if iv != null:
		ntris = int(iv.size()) / 3
	var nuv2 := -1
	if uv2v != null:
		nuv2 = int(uv2v.size())
	_measured["mesh_vertices"] = nverts
	_measured["mesh_triangles"] = ntris
	_measured["mesh_uv2"] = nuv2
	check("mesh_vertex_count", nverts == CELLS, "vertices=%d expected=%d" % [nverts, CELLS])
	check("mesh_triangle_count", ntris == (GRID - 1) * (GRID - 1) * 2,
		"triangles=%d expected=%d" % [ntris, (GRID - 1) * (GRID - 1) * 2])
	check("mesh_uv2_count", nuv2 == CELLS, "UV2=%d expected=%d" % [nuv2, CELLS])

	var uv2_hist := {}
	var out_of_atlas := 0
	var bad_face := 0
	if uv2v is PackedVector2Array:
		for uv in (uv2v as PackedVector2Array):
			if uv.x < 0.0 or uv.x > float(named_cells - 1) or absf(uv.x - float(int(uv.x))) > 0.001:
				out_of_atlas += 1
			var fy := int(uv.y)
			if fy < 0 or fy > 2 or absf(uv.y - float(fy)) > 0.001:
				bad_face += 1
			uv2_hist[str(int(uv.x))] = int(uv2_hist.get(str(int(uv.x)), 0)) + 1
	_measured["uv2_x_out_of_atlas"] = out_of_atlas
	_measured["uv2_y_invalid"] = bad_face
	check("uv2_x_in_atlas", out_of_atlas == 0,
		"ids outside [0,%d]=%d" % [named_cells - 1, out_of_atlas])
	check("uv2_y_face_modes", bad_face == 0, "UV2.y not 0/1/2: %d" % bad_face)

	var stats_v: Variant = terrain.get("stats")
	var stats: Dictionary = stats_v if stats_v is Dictionary else {}
	var ti_v: Variant = stats.get("tile_index", {})
	var ti: Dictionary = ti_v if ti_v is Dictionary else {}
	var fh_v: Variant = ti.get("face_hist", {})
	var fh: Dictionary = fh_v if fh_v is Dictionary else {}
	var fh_sum := 0
	for k in fh:
		fh_sum += int(fh[k])
	_measured["face_hist_sum"] = fh_sum
	check("face_hist_sum", fh_sum == CELLS,
		"face_hist sum=%d expected=%d" % [fh_sum, CELLS])
	check("tile_index_cells", int(ti.get("cells", -1)) == CELLS,
		"tile_index.cells=%s expected=%d source=%s" % [
			str(ti.get("cells", -1)), CELLS, str(ti.get("source", ""))])

	# Flat-grid regression (FIX-TERRAIN §8; t_smallmap_terrain.gd:147-171).
	var flat := PackedFloat32Array()
	flat.resize(CELLS)
	flat.fill(1.5)
	var promoted := 0
	for z in range(GRID):
		for x in range(GRID):
			if int(terrain.call("_face_mode_at", flat, GRID, GRID, x, z)) != 0:
				promoted += 1
	_measured["flat_grid_promoted_cells"] = promoted
	check("flat_face_zero", promoted == 0, "flat 64x64 promoted=%d (expected 0)" % promoted)

	var mat: Material = null
	if mesh != null:
		mat = mesh.surface_get_material(0)
	var at_v: Variant = stats.get("atlas", {})
	var at: Dictionary = at_v if at_v is Dictionary else {}
	var grid_v: Variant = at.get("grid", [])
	var grid: Array = grid_v if grid_v is Array else []
	var grid_param = null
	var samplers_ok := false
	var shader_shadow = null
	if mat is ShaderMaterial:
		var sm := mat as ShaderMaterial
		grid_param = sm.get_shader_parameter("atlas_grid")
		shader_shadow = sm.get_shader_parameter("shadow_enabled")
		samplers_ok = (sm.get_shader_parameter("tile_atlas") != null
			and sm.get_shader_parameter("alpha_atlas") != null
			and sm.get_shader_parameter("alphavert_atlas") != null)
	var grid_ok := grid.size() == 2 and grid_param is Vector2 \
		and int(grid[0]) == int((grid_param as Vector2).x) \
		and int(grid[1]) == int((grid_param as Vector2).y) \
		and grid.size() == atlas_grid.size() \
		and int(grid[0]) == int(atlas_grid[0]) and int(grid[1]) == int(atlas_grid[1])
	_measured["atlas_grid"] = grid
	_measured["atlas_grid_from_manifest"] = atlas_grid
	_measured["atlas_mode"] = str(stats.get("atlas_mode", ""))
	_measured["material_model"] = str(stats.get("material_model", "")).substr(0, 180)
	check("atlas_grid_manifest", grid_ok,
		"stats=%s shader=%s manifest=%s" % [str(grid), str(grid_param), str(atlas_grid)])
	check("atlas_samplers_bound", mat is ShaderMaterial and samplers_ok,
		"material=%s three samplers=%s" % [mat.get_class() if mat != null else "<none>", str(samplers_ok)])
	check("shader_shadow_disabled", str(shader_shadow) == "0" or str(shader_shadow) == "0.0",
		"shadow_enabled=%s (expected 0)" % str(shader_shadow))
	var sun := _find_first_class(terrain, "DirectionalLight3D")
	var sun_ok := sun != null and bool(sun.get("shadow_enabled")) == false
	var sun_detail := "no sun"
	if sun != null:
		sun_detail = "DonorSun.shadow_enabled=%s" % str(sun.get("shadow_enabled"))
	check("sun_shadow_off", sun_ok, sun_detail)
	var shadow_detail := "no terrain mesh"
	if mi != null:
		shadow_detail = "cast_shadow=%d" % mi.cast_shadow
	check("terrain_cast_shadow_off", mi != null
		and mi.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF,
		shadow_detail)

	var samples_ok := true
	var sample_detail := []
	for s in [[5, 5], [40, 40], [60, 60]]:
		var x := int(s[0])
		var z := int(s[1])
		var wp := _world_of(Vector2((float(x) + 0.5) * TILE_M, (float(z) + 0.5) * TILE_M))
		var got := float(terrain.call("height_at_world", wp))
		var want := _heights[z * GRID + x]
		if absf(got - want) > 0.001:
			samples_ok = false
		sample_detail.append("(%d,%d) got=%.4f want=%.4f" % [x, z, got, want])
	check("height_at_world_samples", samples_ok, " | ".join(sample_detail))

	# ---- P2: bounded water / sand / rock shore -----------------------------
	check("water_cells_bounded",
		(_water_cells == 0) if not _with_shore else (_water_cells > 0 and _water_cells < CELLS / 10),
		"water_cells=%d shore_cells=%d of %d (bound <10%%, TEST_01 P2 row)" % [
			_water_cells, _shore_cells, CELLS])
	var shore_ids := []
	for cand in ["sandsea", "sandrock"]:
		var tid := int(_tile_ids.get(cand, -1))
		if tid >= 0:
			shore_ids.append(str(tid))
	_measured["shore_tile_ids"] = shore_ids
	_measured["shore_uv2_hist_entries"] = str(uv2_hist).substr(0, 300)
	var shore_seen := false
	for sid_key in shore_ids:
		if int(uv2_hist.get(sid_key, 0)) > 0:
			shore_seen = true
	check("shore_ids_in_hist", (not _with_shore) or shore_seen,
		"shore ids %s in UV2.x hist=%s" % [str(shore_ids), str(uv2_hist).substr(0, 220)])

	var water_v: Variant = stats.get("water", {})
	var water: Dictionary = water_v if water_v is Dictionary else {}
	var water_mod := str(water.get("module", ""))
	_measured["water_module"] = water_mod
	_measured["water_height_aware"] = str(water.get("height_aware", false))
	_measured["water_donor_literals"] = str(water.get("donor_literals", {}))
	check("water_module_height_aware", water_mod.ends_with("water3d.gd")
		and bool(water.get("height_aware", false)),
		"module=%s height_aware=%s" % [water_mod, str(water.get("height_aware", false))])
	var plane_count := _count_named(terrain, "WaterPlane")
	var water3d_count := _count_named(terrain, "Water3D")
	_measured["water_plane_count"] = plane_count
	_measured["water3d_node_count"] = water3d_count
	check("single_water_plane", plane_count == 1 and water3d_count == 1,
		"WaterPlane=%d Water3D=%d (no stacked water planes)" % [plane_count, water3d_count])

	# ---- P1 / P3: resource counts, purity, Y placement ---------------------
	var env_v: Variant = ents.get("stats")
	var estats: Dictionary = env_v if env_v is Dictionary else {}
	_measured["entity_stats"] = {
		"units": estats.get("units", -1),
		"buildings": estats.get("buildings", -1),
		"resources": estats.get("resources", -1),
		"batches": estats.get("batches", -1),
	}
	check("no_units_or_buildings", int(estats.get("units", -1)) == 0
		and int(estats.get("buildings", -1)) == 0,
		"units=%s buildings=%s" % [str(estats.get("units", -1)), str(estats.get("buildings", -1))])

	var batches_v: Variant = ents.get("_batches")
	var batches: Dictionary = batches_v if batches_v is Dictionary else {}
	var sid_counts := {}
	for key in batches:
		var bd: Dictionary = {}
		if batches[key] is Dictionary:
			bd = batches[key]
		var ids: Array = []
		if bd.get("ids", []) is Array:
			ids = bd.get("ids", [])
		if ids.size() > 0:
			sid_counts[str(key)] = ids.size()
	_measured["batch_sid_counts"] = sid_counts
	var expected_sid_values := {}
	for id in _expected_sids:
		expected_sid_values[str(_expected_sids[id])] = true
	var tree_sids := {}
	var mine_sids := {}
	for n in _nodes:
		var sid := str(_expected_sids.get(int(n.get("id", -1)), ""))
		if str(n.get("type", "")) == "wood":
			tree_sids[sid] = true
		elif MINE_KINDS.has(str(n.get("type", ""))):
			mine_sids[sid] = true
	var tree_instances := 0
	var mine_instances := 0
	var foreign := 0
	for k in sid_counts:
		var bare := str(k).substr(4) if str(k).begins_with("res|") else str(k)
		var c := int(sid_counts[k])
		if tree_sids.has(bare):
			tree_instances += c
		elif mine_sids.has(bare):
			mine_instances += c
		elif expected_sid_values.has(bare):
			pass
		else:
			foreign += c
	_measured["tree_instances"] = tree_instances
	_measured["mine_instances"] = mine_instances
	_measured["foreign_instances"] = foreign
	check("tree_instances", tree_instances == (TREE_COUNT if _with_trees else 0),
		"tree instances=%d expected=%d" % [tree_instances, TREE_COUNT if _with_trees else 0])
	check("mine_instances", mine_instances == (MINES_PER_KIND * MINE_KINDS.size() if _with_mines else 0),
		"mine instances=%d expected=%d" % [
			mine_instances, MINES_PER_KIND * MINE_KINDS.size() if _with_mines else 0])
	check("category_purity", foreign == 0,
		"unexpected sid instances=%d (stone/food/stump/other prohibited)" % foreign)

	var sid_ok := true
	for n in _nodes:
		if MINE_KINDS.has(str(n.get("type", ""))):
			if str(_expected_sids.get(int(n.get("id", -1)), "")) != "mine_" + str(n.get("type", "")):
				sid_ok = false
	check("mine_sid_resolves", sid_ok,
		"world3d_entities._resource_sid: gold/iron/coal -> mine_<ty> (world3d_entities.gd:1269-1277)")

	# Y placement and above-water checks, read straight from the instance transforms.
	var y_errors := 0
	var min_mine_tree_dist := INF
	var above_water_ok := true
	for n in _nodes:
		var pos: Vector2 = n.get("pos", Vector2.ZERO)
		if _grid_y_at(pos) <= _water_level:
			above_water_ok = false
	for key in batches:
		var bd: Dictionary = {}
		if batches[key] is Dictionary:
			bd = batches[key]
		var ids: Array = []
		if bd.get("ids", []) is Array:
			ids = bd.get("ids", [])
		var xforms: Array = []
		if bd.get("xforms", []) is Array:
			xforms = bd.get("xforms", [])
		for j in range(ids.size()):
			var id := int(ids[j])
			var pos: Vector2 = Vector2.ZERO
			for n in _nodes:
				if int(n.get("id", -1)) == id:
					pos = n.get("pos", Vector2.ZERO)
					break
			if j >= xforms.size() or not (xforms[j] is Transform3D):
				y_errors += 1
				continue
			var xf: Transform3D = xforms[j]
			var want_y := float(terrain.call("height_at_world", _world_of(pos)))
			if absf(xf.origin.y - want_y) > EPS_M:
				y_errors += 1
	check("resource_y_matches_terrain", y_errors == 0,
		"transform Y mismatches=%d tol=%.3fm (%d resource instances)" % [y_errors, EPS_M, _nodes.size()])
	check("resources_above_water", above_water_ok,
		"every stub tree/mine cell height > water level %.2f" % _water_level)
	if _with_trees and _with_mines:
		for n in _nodes:
			if str(n.get("type", "")) != "wood":
				continue
			for m in _nodes:
				if MINE_KINDS.has(str(m.get("type", ""))):
					min_mine_tree_dist = minf(min_mine_tree_dist,
						(n.get("pos", Vector2.ZERO) as Vector2).distance_to(m.get("pos", Vector2.ZERO)))
		_measured["min_mine_tree_distance_m"] = min_mine_tree_dist
	check("mine_tree_separation", (not (_with_trees and _with_mines)) or min_mine_tree_dist > 0.0,
		"min tree<->mine distance=%.2f m (stub fixture geometry, not a donor constant)" % min_mine_tree_dist)

	# no cmd_* side effects: instrumented in the embedded stub; helper stubs must
	# expose the same counter or this check fails loudly (no weakening).
	if game.has_method("total_cmd_calls"):
		var calls := int(game.call("total_cmd_calls"))
		_measured["cmd_calls"] = str(game.get("cmd_calls"))
		check("no_cmd_calls", calls == 0, "cmd_calls=%d" % calls)
	else:
		check("no_cmd_calls", false,
			"helper stub has no total_cmd_calls(); use the embedded fallback stub")

	# ---- T4-only seam-class rig checks ------------------------------------
	var we_count := _count_class(terrain, "WorldEnvironment")
	var sun_count := _count_class(terrain, "DirectionalLight3D")
	_measured["world_environment_count"] = we_count
	_measured["sun_count"] = sun_count
	check("single_environment_rig", we_count == 1 and sun_count == 1,
		"WorldEnvironment=%d DirectionalLight3D=%d" % [we_count, sun_count])

	# ---- windowed capture -------------------------------------------------
	var cam := Camera3D.new()
	cam.name = "ComboCamera"
	cam.fov = 50.0
	cam.position = Vector3(0.0, 95.0, 105.0)
	cam.look_at(Vector3.ZERO, Vector3.UP)
	cam.current = true
	var vp := SubViewport.new()
	vp.name = "ComboCaptureViewport"
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	vp.size = Vector2i(_capture_w, _capture_h)
	root.add_child(vp)
	for node_to_move in [game, terrain, ents, cam]:
		vp.add_child(node_to_move)   # add_child reparents from root

	var draw_samples: Array[float] = []
	for i in range(_frames):
		await RenderingServer.frame_post_draw
		draw_samples.append(float(Performance.get_monitor(
			Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)))
	var img: Image = vp.get_texture().get_image()
	var source := "SubViewport"
	if img == null or img.is_empty():
		img = root.get_texture().get_image()
		source = "root viewport fallback"
	_measured["capture_source"] = source
	var shot_w := -1
	var shot_h := -1
	if img != null:
		shot_w = img.get_width()
		shot_h = img.get_height()
	check("png_captured", img != null and not img.is_empty(),
		"source=%s size=%dx%d" % [source, shot_w, shot_h])
	if img == null or img.is_empty():
		_finish("ABORTED_CAPTURE_EMPTY")
		return

	var metrics := _image_metrics(img)
	_measured["image"] = metrics
	var draw_sum := 0.0
	for d in draw_samples:
		draw_sum += d
	var draw_mean := draw_sum / float(maxi(1, draw_samples.size()))
	_measured["draw_calls_mean"] = draw_mean
	_measured["draw_calls_samples"] = draw_samples.size()
	var nonblack := float(metrics.get("non_black_fraction", 0.0))
	var dark_rows := int(metrics.get("full_width_dark_rows", -1))
	var dark_cols := int(metrics.get("full_height_dark_cols", -1))
	var mluma01 := float(metrics.get("mean_luma_0_1", 0.0))
	var mluma255 := float(metrics.get("mean_luma_0_255", 0.0))
	check("nonblack_over_090", nonblack > 0.9,
		"non-black=%.4f (expected >0.9)" % nonblack)
	check("full_width_dark_rows_zero", dark_rows == 0,
		"dark rows=%d (smallmap_capture.py:27-28)" % dark_rows)
	check("no_full_height_dark_cols", dark_cols == 0,
		"full-height dark cols=%d (vertical seam guard)" % dark_cols)
	check("mean_luma_recorded", is_finite(mluma01) and mluma01 > 0.0,
		"mean luma=%.3f (0..255) / %.4f (0..1); recorded, NOT compared to a donor frame" % [
			mluma255, mluma01])
	check("draw_calls_recorded", draw_samples.size() > 0,
		"mean draw calls=%.2f over %d frames" % [draw_mean, draw_samples.size()])
	check("no_new_seam_class", meshes.size() == 1 and plane_count == 1
		and we_count == 1 and sun_count == 1
		and dark_rows == 0 and dark_cols == 0 and nonblack > 0.9,
		"structural single-mesh/single-plane/single-rig + zero dark row/col bands; "
		+ "qualitative seam review still requires a second agent")

	var dir := _png_path.get_base_dir()
	if dir != "":
		DirAccess.make_dir_recursive_absolute(dir)
	var err := img.save_png(_png_path)
	var png_bytes := 0
	if FileAccess.file_exists(_png_path):
		png_bytes = FileAccess.get_file_as_bytes(_png_path).size()
	_measured["png_save_error"] = int(err)
	_measured["png_bytes"] = png_bytes
	check("png_saved", err == OK and png_bytes > 0,
		"path=%s err=%d bytes=%d" % [_png_path, err, png_bytes])
	print("T_COMBO_ALL PNG: " + _png_path)
	print("T_COMBO_ALL STDERR_SCAN_REQUIRED (runner stderr.txt, smallmap_capture.py scan-stderr)")
	_finish("COMPLETED")


func _find_first_class(root: Node, cls: String) -> Node:
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n.is_class(cls):
			return n
		for c in n.get_children():
			stack.append(c)
	return null
