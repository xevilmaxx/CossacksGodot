# SP-8 / t_season_overlay.gd — 64² dump-driven season-overlay atom.
#
# Owns ONLY this file (plus docs/coord_swarm_2026-11-25/reports/
# SP_08_season_test.md). AUTHORING ONLY: never executed by this agent; no Godot
# launch, no runner ticket, no capture, no donor access, no shared-code edit.
#
# Purpose (SEASON_PLAN_01.md:193 SP-8 row, :164-174 §4.3, :202-217 blockers):
#   Run THREE season variants over the SAME 64² fixture dump, SAME stub game and
#   SAME camera: default/summer (baseline), winter (SP-5 manifest_path override
#   + SP-2 winter dictionary + SP-4 winter atlas), desert (SP-3 remap applied by
#   the SP-6 render hook). Assert UV2.x stays in range and index-preserving,
#   the atlas manifest resolves for every built variant, no internal script
#   error path fired, and capture one windowed PNG per built variant.
#
# DUMP-DRIVEN, NO HARNESS EDIT: the fixture helper's make_stub_game() supplies
# the base64 height/tileblock dump that world3d_terrain.gd:1028-1065 decodes.
# `winter_tile_names` is deliberately NOT required (SEASON_PLAN_01.md:124,
# :193: "Do not edit _smallmap_harness.gd — dump-driven design avoids needing
# winter_tile_names"). Only map size / seed are read from small_map_64.json.
#
# Sources (all read-only):
#   SEASON_PLAN_01.md:178-195 (ticket table), :159-174 (derived mapping),
#     :202-217 (B1..B10), :220-238 (PORT APPROX labels), :241-263 (Q1..Q8).
#   TEST_P0_report.md:74-107 (assertion/citation style, SKIP_CAPTURE rule),
#     :109-141 (harness consumption + embedded fallback), :219-237 (no-runner).
#   TEST_01_smallmap_harness.md:183-226 (ladder/capture), :228-255 (scaffolding),
#     :269-305 (blockers: headless cannot capture 3D, deferred quit, FIFO).
#   TEST_MATRIX.md:11-12,29-46,53-75 (same-map rule, V3D_02 refinement,
#     execution protocol: never weaken, second-agent re-check, no parity claim).
#   _template_test.gd:1-38 (one file / one verdict / deferred quit / result JSON).
#   t_terrain_only.gd:42-86,170-239,250-304,394-420,623-669 (atom skeleton,
#     check() with null status, windowed SubViewport readback, PNG metrics).
#   _smallmap_harness.gd:11-24,106-128 (StubGame shape + make_stub_game dump).
#   world3d_terrain.gd:252,461-491,1028-1065,1107-1194,1310-1401 (manifest path,
#     loader binding, dump decode, UV2.x = tile id, stats shape).
#   tile_atlas_loader.gd:66-86,99-118,310-317,389-405 (SP-5 manifest_path
#     override — PRESENT on this tree; default stays V785_MANIFEST).
#   data.gd:199,219-225,227 (BIOME, legacy flat tint, SEASON_ENUM — SP-1 landed).
#   smallmap_capture.py:21-39,50-58 (PNG metric mirror; stderr scan is external).
#
# LABELS: every structural result is PORT APPROXIMATION / internal consistency.
# No donor GPU A/B frame exists (TEST_MATRIX.md:46,73-75); no parity is claimed.
# Flat TERRAIN_TINT is legacy port art, NOT the donor swap (SEASON_PLAN B9).
extends SceneTree

const FIXTURE_PATH := "res://tests/fixtures/small_map_64.json"
const HARNESS_PATH := "res://tests/fixtures/_smallmap_harness.gd"
const TERRAIN_PATH := "res://scripts/world3d_terrain.gd"
const CAMERA_PATH := "res://scripts/camera3d.gd"
const LOADER_PATH := "res://scripts/tile_atlas_loader.gd"
const DATA_SCRIPT = preload("res://scripts/data.gd")

const SUMMER_DICT_PATH := "res://assets/terrain/structs/presets_summer.json"
const SUMMER_MANIFEST_PATH := "res://assets/terrain/atlas/tile_index_atlas.manifest.json"
const SUMMER_ATLAS_PATH := "res://assets/terrain/atlas/tile_index_atlas.png"
# SP-2/SP-3 LANDED at atlas/ (not the structs/ paths proposed in SEASON_PLAN_01):
# see SP_02_winter_dictionary.md:10 and SP_03_desert_remap.md:9 / O1.
const WINTER_DICT_PATH := "res://assets/terrain/atlas/winter_aliases.json"            # SP-2
const WINTER_MANIFEST_PATH := "res://assets/terrain/atlas/tile_index_atlas_winter.manifest.json"  # SP-4
const WINTER_ATLAS_PATH := "res://assets/terrain/atlas/tile_index_atlas_winter.png"   # SP-4
const DESERT_REMAP_PATH := "res://assets/terrain/atlas/desert_remap.json"             # SP-3
const BLOCKS_DIR := "res://assets/terrain/blocks/"

const OUT_PATH := "res://tests/results/t_season_overlay.json"
const DEFAULT_W := 64
const DEFAULT_H := 64
const DEFAULT_SEED := 20261113
const TILE_M := 2.0                 # data.gd:23
const WATER_LEVEL := -0.25          # world3d_terrain.gd:132
const CAPTURE_FRAMES := 10          # TEST_MATRIX.md:32
const WINDOW_SIZE := Vector2i(1280, 720)  # data.gd:113-114
const EXPECTED_GRID := [16, 8]      # V7-85 manifest / SP-4 spec (SEASON_PLAN_01.md:189)
const FALLBACK_NAMED := 124         # V7-85 named_cells (manifest atlas block)

const STATUS_READY := "READY"
const STATUS_PENDING := "PENDING_DEP"
const STATUS_BUILT := "BUILT"
const STATUS_FAIL := "FAIL"

# Minimal fallback stub, same shape as the landed helper / P0's embedded copy
# (_smallmap_harness.gd:11-24,118-128; t_terrain3d.gd:41-46; t_pick3d.gd:53-71).
# Inherited fields (res_dirty/entities/res_nodes) are NOT redeclared — P0's
# ATOM_REPAIR note (TEST_P0_report.md:95-96) — because they are parse errors.
class LocalStubGame extends C3Game:
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

	func resolve_mine_sid(_sid: String, _pos: Vector2) -> String:
		return ""

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

	func cmd_move(_a = null, _b = null, _c = null) -> void: _bump("cmd_move")
	func cmd_gather(_a = null, _b = null, _c = null) -> void: _bump("cmd_gather")
	func cmd_build(_a = null, _b = null, _c = null) -> void: _bump("cmd_build")

var _id := "t_season_overlay"
var _checks: Array[Dictionary] = []
var _ok := true
var _finished := false
var _setup_done := false
var _internal_error := false
var _headless := false
var _w := DEFAULT_W
var _h := DEFAULT_H
var _seed := DEFAULT_SEED
var _names: Array = []
var _heights := PackedFloat32Array()
var _tileblock := PackedByteArray()
var _tileblock_original := PackedByteArray()
var _game: Object = null
var _harness_source := ""
var _capture_view: SubViewport = null
var _camera: Camera3D = null
var _variants: Array[Dictionary] = []
var _variant_index := -1
var _variant_frames := 0
var _capturing := false
var _m: Dictionary = {}


# `cond` is Variant so a PENDING_DEP / SKIP row can carry JSON null instead of
# a misleading PASS/FAIL boolean (TEST_P0_report.md:168-177). Only explicit
# `false` flips _ok; null is counted as skipped, never as a pass.
func check(name: String, cond, detail: String = "", status: String = "") -> void:
	var st := status
	if st == "":
		st = "PASS" if cond == true else ("FAIL" if cond == false else "SKIPPED")
	_checks.append({"name": name, "passed": cond, "status": st, "detail": detail})
	if cond == false:
		_ok = false
	print("T_SEASON_OVERLAY %s %s - %s" % [st, name, detail])


func _verdict() -> String:
	if not _ok:
		return "FAIL"
	for v in _variants:
		if str(v.get("status", "")) == STATUS_PENDING:
			return "PENDING_DEP"
	if _headless:
		return "SKIP_CAPTURE"
	for v in _variants:
		if str(v.get("status", "")) != STATUS_BUILT:
			return "INCOMPLETE"
		if str(v.get("capture_status", "")) != "PASS":
			return "INCOMPLETE"
	return "PASS"


func _arg_value(flag: String) -> String:
	for src in [OS.get_cmdline_user_args(), OS.get_cmdline_args()]:
		var args := PackedStringArray(src)
		for i in range(args.size()):
			if str(args[i]) == flag and i + 1 < args.size():
				return str(args[i + 1])
	return ""


func _res_path(path: String) -> String:
	if path.begins_with("res://"):
		return ProjectSettings.globalize_path(path)
	return path


func _res_exists(path: String) -> bool:
	return FileAccess.file_exists(_res_path(path))


func _read_json_variant(path: String):
	if not _res_exists(path):
		return null
	var f := FileAccess.open(_res_path(path), FileAccess.READ)
	if f == null:
		return null
	var text := f.get_as_text()
	f.close()
	return JSON.parse_string(text)


func _read_json_dict(path: String) -> Dictionary:
	var parsed: Variant = _read_json_variant(path)
	return parsed if parsed is Dictionary else {}


func _source_has(path: String, needle: String) -> bool:
	if not _res_exists(path):
		return false
	var f := FileAccess.open(_res_path(path), FileAccess.READ)
	if f == null:
		return false
	var t := f.get_as_text()
	f.close()
	return t.contains(needle)


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


# --------------------------------------------------------------- fixture / stub
func _load_fixture() -> void:
	var path := _arg_value("--config")
	if path == "" or not FileAccess.file_exists(path):
		path = FIXTURE_PATH
	if _res_exists(path):
		var parsed: Variant = _read_json_variant(path)
		if parsed is Dictionary:
			var gp: Variant = (parsed as Dictionary).get("gameplay", {})
			if gp is Dictionary:
				_w = maxi(2, int((gp as Dictionary).get("map_width_tiles", DEFAULT_W)))
				_h = maxi(2, int((gp as Dictionary).get("map_height_tiles", DEFAULT_H)))
				_seed = int((gp as Dictionary).get("random_seed", DEFAULT_SEED))
	_m["fixture"] = path
	_m["fixture_w"] = _w
	_m["fixture_h"] = _h
	_m["fixture_seed"] = _seed


func _make_grid() -> void:
	var n := _w * _h
	var named: int = _names.size() if not _names.is_empty() else FALLBACK_NAMED
	_heights.resize(n)
	_tileblock.resize(n)
	# Deterministic tile spread over the FULL 124-cell index space. Mild relief
	# (axis delta << cDiff1=0.5, world3d_terrain.gd:161) keeps face=0 and
	# shore_gate=false (world3d_terrain.gd:1126-1128), so UV2.x is exactly the
	# dump tile id — an index-preservation check with no face/shore confounder.
	var seed_shift: int = absi(_seed) % maxi(named, 1)
	for z in range(_h):
		for x in range(_w):
			var i := z * _w + x
			_heights[i] = 1.5 + 0.03 * sin(float(x) * 0.11) + 0.02 * cos(float(z) * 0.09)
			_tileblock[i] = (x * 13 + z * 7 + seed_shift) % maxi(named, 1)
	_tileblock_original = _tileblock.duplicate()
	_m["tileblock_distinct_ids"] = _distinct_ids(_tileblock)
	_m["tileblock_min"] = _min_byte(_tileblock)
	_m["tileblock_max"] = _max_byte(_tileblock)


func _distinct_ids(a: PackedByteArray) -> int:
	var seen := {}
	for i in range(a.size()):
		seen[str(a[i])] = true
	return seen.size()


func _min_byte(a: PackedByteArray) -> int:
	var v := 255
	for i in range(a.size()):
		v = mini(v, int(a[i]))
	return v


func _max_byte(a: PackedByteArray) -> int:
	var v := -1
	for i in range(a.size()):
		v = maxi(v, int(a[i]))
	return v


func _make_stub_game() -> Object:
	if ResourceLoader.exists(HARNESS_PATH):
		var helper: Object = load(HARNESS_PATH)
		var caller: Object = helper
		if helper != null and not helper.has_method("make_stub_game"):
			if helper is Script and (helper as Script).can_instantiate():
				caller = (helper as Script).new()
		if caller != null and caller.has_method("make_stub_game"):
			var g_v: Variant = caller.call("make_stub_game", _w, _h,
				_heights, [], _tileblock)
			if g_v is Object and is_instance_valid(g_v):
				_harness_source = "shared:" + HARNESS_PATH
				return g_v
	var local := LocalStubGame.new()
	local.MAP_W = _w
	local.MAP_H = _h
	# ATOM-REPAIR (TEST_P0_report.md:95-96): inherited fields are used directly;
	# C3Game declares MAP_W/MAP_H but not map_w/map_h (game.gd:5762,5771 are a
	# save/load dict), so do not assign undeclared properties here.
	local.height = _heights
	local.tileblock = _tileblock
	local.res_nodes = []
	local.height_b64 = Marshalls.raw_to_base64(_heights.to_byte_array())
	local.dump = {
		"map_w": _w, "map_h": _h,
		"height": local.height_b64,
		"tileblock": Marshalls.raw_to_base64(_tileblock),
	}
	_harness_source = "embedded_local_stub"
	return local


# ------------------------------------------------------------------- SP-5 probe
# SP-5 is already on disk: tile_atlas_loader.gd:77,86,99-118,313,405. Verify
# the override API directly (no winter assets required) so a later winter FAIL
# cannot be blamed on an unexercised loader override.
func _sp5_override_api_ok() -> bool:
	var scr := load(LOADER_PATH) as Script
	if scr == null or not scr.can_instantiate():
		return false
	var inst: Object = scr.new("single", {
		"manifest_path": SUMMER_MANIFEST_PATH,
		"single_atlas_path": SUMMER_ATLAS_PATH,
	})
	if inst == null:
		return false
	var ok := (str(inst.get("manifest_path")) == SUMMER_MANIFEST_PATH
		and str(inst.get("single_atlas_path")) == SUMMER_ATLAS_PATH)
	_m["sp5_manifest_path"] = str(inst.get("manifest_path"))
	_m["sp5_single_atlas_path"] = str(inst.get("single_atlas_path"))
	# RefCounted — no explicit free(); it is released when the reference drops.
	return ok


# ------------------------------------------------------------- dependency gate
func _png_arg(id: String) -> String:
	var flags := ["--%s-png" % id, "--png-%s" % id]
	if id == "summer":
		flags.append("--screenshot")   # P0/TEST-01 alias, used as summer path
	for f in flags:
		var v := _arg_value(f)
		if v != "":
			return v
	return ""


func _make_variant(id: String, biome: String, manifest: String) -> Dictionary:
	var missing: Array[String] = []
	match id:
		"summer":
			if not _res_exists(SUMMER_MANIFEST_PATH):
				missing.append("V785 summer manifest missing")
			if not _res_exists(SUMMER_DICT_PATH):
				missing.append("presets_summer.json missing")
		"winter":
			if not _res_exists(WINTER_DICT_PATH):
				missing.append("SP-2 atlas/winter_aliases.json")
			if not _res_exists(WINTER_MANIFEST_PATH):
				missing.append("SP-4 winter manifest")
			if not _res_exists(WINTER_ATLAS_PATH):
				missing.append("SP-4 winter atlas PNG")
			if not _source_has(LOADER_PATH, "manifest_path"):
				missing.append("SP-5 loader manifest_path override")
			if not _source_has(TERRAIN_PATH, "BIOME"):
				missing.append("SP-6 BIOME -> manifest selection hook")
		"desert":
			if not _res_exists(DESERT_REMAP_PATH):
				missing.append("SP-3 atlas/desert_remap.json")
			if not _source_has(TERRAIN_PATH, "desert_remap"):
				missing.append("SP-6 desert remap hook")
	var status := STATUS_READY if missing.is_empty() else STATUS_PENDING
	if id == "summer" and not missing.is_empty():
		status = STATUS_FAIL   # baseline must work; a missing baseline is a real FAIL
	return {
		"id": id,
		"biome": biome,
		"manifest": manifest,
		"png_path": _png_arg(id),
		"missing": missing,
		"status": status,
		"built": false,
		"capturing": false,
		"capture_status": ("READY" if status == STATUS_READY else "PENDING_DEP"),
		"uv2_copy": null,
		"terrain": null,
		"stats": {},
		"manifest_data": {},
		"uv2_out_of_range": -1,
		"uv2_x_min": INF,
		"uv2_x_max": -INF,
		"desert_index_map": {},
	}


func _note_dependency(v: Dictionary) -> void:
	var id := str(v.get("id", ""))
	var status := str(v.get("status", ""))
	if status == STATUS_READY:
		check(id + "_dependency_state", true,
			"all required dependency files/hooks present for " + id)
	elif status == STATUS_FAIL:
		# Baseline is mandatory: a missing Summer input is a real FAIL, not a
		# PENDING_DEP excuse (TEST_MATRIX.md:60-61,67-68).
		check(id + "_dependency_state", false,
			"mandatory baseline deps missing: " + str(v.get("missing", [])))
	else:
		check(id + "_dependency_state", null,
			"%s deps missing: %s" % [id, str(v.get("missing", []))], STATUS_PENDING)


# ------------------------------------------------------------------- manifests
func _manifest_ok(man: Dictionary) -> bool:
	if man.is_empty():
		return false
	var at: Variant = man.get("atlas", null)
	if not (at is Dictionary):
		return false
	var named := int((at as Dictionary).get("named_cells", 0))
	var layout: Variant = man.get("layout", null)
	return named > 0 and (layout is Array) and (layout as Array).size() > 0


func _manifest_named(man: Dictionary) -> int:
	var at: Variant = man.get("atlas", null)
	if not (at is Dictionary):
		return FALLBACK_NAMED
	return maxi(1, int((at as Dictionary).get("named_cells", FALLBACK_NAMED)))


func _layout_name_to_index(man: Dictionary) -> Dictionary:
	var out := {}
	var layout: Variant = man.get("layout", [])
	if not (layout is Array):
		return out
	for e in layout:
		if e is Dictionary:
			var nm := str((e as Dictionary).get("name", ""))
			if nm != "" and (e as Dictionary).get("index") is int:
				out[nm] = int((e as Dictionary).get("index"))
	return out


# SP-2 landed as atlas/winter_aliases.json (NOT presets_winter.json): a Dictionary
# with `entries[]` of {index, name, winter_alias, source_png, kind, status,
# shared_alpha, donor_evidence}. SP_02 report §4 / §8: 124 contiguous indices,
# names in presets_summer order, every source_png on disk (23 winter PNGs +
# 12 reused desert PNGs). No index is inferred from a winterN filename.
func _check_winter_dictionary(_v: Dictionary) -> void:
	var parsed: Variant = _read_json_variant(WINTER_DICT_PATH)
	var entries: Array = []
	if parsed is Dictionary:
		var ev: Variant = (parsed as Dictionary).get("entries", [])
		entries = ev if ev is Array else []
	var expected: int = int(_m.get("summer_names", FALLBACK_NAMED))
	check("winter_dict_124_entries", entries.size() == expected,
		"SP-2 entries=%d expected=%d (SP_02 report §4 / §8)" % [entries.size(), expected])
	var order_ok := true
	var alias_ok := true
	var unresolved: Array[String] = []
	var kinds := {}
	var idx := 0
	for item in entries:
		if not (item is Dictionary):
			order_ok = false
			continue
		var d := item as Dictionary
		if int(d.get("index", -1)) != idx:
			order_ok = false
		var nm := str(d.get("name", ""))
		if idx >= expected or nm != str(_names[idx]):
			order_ok = false
		if str(d.get("winter_alias", "")) != nm + "_winter":
			alias_ok = false
		var png := str(d.get("source_png", ""))
		var png_path := png if (png.begins_with("res://") or png.is_absolute_path()) else (BLOCKS_DIR + png)
		if png == "" or not _res_exists(png_path):
			unresolved.append(nm + ":" + png_path)
		var kind := str(d.get("kind", ""))
		kinds[kind] = int(kinds.get(kind, 0)) + 1
		idx += 1
	check("winter_entries_index_and_names", order_ok and alias_ok and idx == expected,
		"indices 0..%d contiguous, names == presets_summer order, winter_alias == name+'_winter': %s" % [
			expected - 1, str(order_ok and alias_ok)])
	_m["winter_entries"] = idx
	_m["winter_kinds"] = kinds
	_m["winter_png_missing"] = unresolved
	check("winter_names_resolve", unresolved.is_empty(),
		"unresolved SP-2 source_png=%d (expected 0; SP_02 report §8)" % unresolved.size())


# SP-3 landed as atlas/desert_remap.json with `remap` (11 direct name->record
# pairs) and `height_gated` (1 record). The height gate is DATA_ONLY_NOT_EXECUTED
# per SP_03 §3.1, so only the 11 direct pairs enter the UV2 consistency map.
func _check_desert_remap(v: Dictionary) -> void:
	var parsed: Variant = _read_json_variant(DESERT_REMAP_PATH)
	var remap: Dictionary = {}
	var gated: Array = []
	if parsed is Dictionary:
		var rv: Variant = (parsed as Dictionary).get("remap", {})
		remap = rv if rv is Dictionary else {}
		var gv: Variant = (parsed as Dictionary).get("height_gated", [])
		gated = gv if gv is Array else []
	var name_to_idx := _layout_name_to_index(_read_json_dict(SUMMER_MANIFEST_PATH))
	var idx_map := {}
	var unresolved: Array[String] = []

	# Direct pairs: feed the strict UV2 remap check.
	for src in remap.keys():
		var ev: Variant = remap[src]
		if not (ev is Dictionary):
			unresolved.append(str(src) + ":not-a-record")
			continue
		var e := ev as Dictionary
		var src_i := int(e.get("source_index", -1))
		var tgt_i := int(e.get("atlas_index", -1))
		var tgt := str(e.get("target", ""))
		if src_i < 0 or src_i >= _names.size() or str(_names[src_i]) != str(src):
			unresolved.append("src:" + str(src) + ":index/name-mismatch")
		if tgt_i < 0 or tgt_i >= _names.size() or str(_names[tgt_i]) != tgt:
			unresolved.append("dst:" + tgt + ":index/name-mismatch")
		if not name_to_idx.has(tgt) or int(name_to_idx[tgt]) != tgt_i:
			unresolved.append("dst:" + tgt + ":not-packed-at-" + str(tgt_i))
		idx_map[str(src_i)] = tgt_i

	# Height-gated record: resolve and report, but do NOT feed idx_map — SP-6 is
	# index-only and explicitly does not apply height gating (SP_03 §3.1 / §5.3).
	for item in gated:
		if not (item is Dictionary):
			unresolved.append("height_gated:not-a-record")
			continue
		var g := item as Dictionary
		var gsrc := str(g.get("source", ""))
		var gsrc_i := int(g.get("source_index", -1))
		var gtgt := str(g.get("target", ""))
		var gtgt_i := int(g.get("atlas_index", -1))
		if gsrc_i < 0 or gsrc_i >= _names.size() or str(_names[gsrc_i]) != gsrc:
			unresolved.append("gated-src:" + gsrc + ":index/name-mismatch")
		if gtgt_i < 0 or gtgt_i >= _names.size() or str(_names[gtgt_i]) != gtgt:
			unresolved.append("gated-dst:" + gtgt + ":index/name-mismatch")
		if not name_to_idx.has(gtgt) or int(name_to_idx[gtgt]) != gtgt_i:
			unresolved.append("gated-dst:" + gtgt + ":not-packed-at-" + str(gtgt_i))

	v["desert_index_map"] = idx_map
	_m["desert_remap_direct_pairs"] = remap.size()
	_m["desert_remap_height_gated_pairs"] = gated.size()
	_m["desert_remap_indices"] = idx_map
	_m["desert_remap_unresolved"] = unresolved
	check("desert_remap_parsed", remap.size() == 11 and gated.size() == 1,
		"SP-3 direct=%d (expected 11) height_gated=%d (expected 1, DATA_ONLY_NOT_EXECUTED)" % [
			remap.size(), gated.size()])
	check("desert_remap_targets_resolve", unresolved.is_empty(),
		"unresolved SP-3 source/target records=%d (expected 0)" % unresolved.size())


# --------------------------------------------------------------------- building
func _build_variant(v: Dictionary) -> void:
	var id := str(v.get("id", ""))
	DATA_SCRIPT.BIOME = str(v.get("biome", "summer"))
	var scr := load(TERRAIN_PATH) as Script
	if scr == null or not scr.can_instantiate():
		_internal_error = true
		check(id + "_build_ok", false, "cannot load " + TERRAIN_PATH)
		v["status"] = STATUS_FAIL
		return
	var t: Node = scr.new() as Node
	if t == null:
		_internal_error = true
		check(id + "_build_ok", false, "cannot instantiate " + TERRAIN_PATH)
		v["status"] = STATUS_FAIL
		return
	var parent: Node = _capture_view if _capture_view != null else get_root()
	t.name = "SeasonTerrain_" + id
	parent.add_child(t)
	t.call("bind", _game)
	var built := bool(t.call("build"))
	check(id + "_build_ok", built, "world3d_terrain.build() -> " + str(built))
	if not built:
		_internal_error = true
		v["status"] = STATUS_FAIL
		t.queue_free()
		return

	v["status"] = STATUS_BUILT
	v["built"] = true
	v["terrain"] = t
	var stats_v: Variant = t.get("stats")
	var stats: Dictionary = stats_v if stats_v is Dictionary else {}
	v["stats"] = stats
	_m[id + "_atlas_mode"] = str(stats.get("atlas_mode", ""))

	# Manifest resolution for THIS variant (summer/desert -> V785, winter -> SP-4).
	var man := _read_json_dict(str(v.get("manifest", "")))
	v["manifest_data"] = man
	check(id + "_manifest_resolves", _manifest_ok(man),
		"manifest=%s parsed=%s named_cells=%d layout=%d" % [
			str(v.get("manifest", "")), str(not man.is_empty()),
			_manifest_named(man),
			((man.get("layout", []) as Array).size() if man.get("layout", []) is Array else -1)])
	var grid: Variant = (man.get("atlas", {}) as Dictionary).get("grid", []) if man.get("atlas") is Dictionary else []
	var grid_ok: bool = (grid is Array and (grid as Array).size() == 2
		and int((grid as Array)[0]) == EXPECTED_GRID[0]
		and int((grid as Array)[1]) == EXPECTED_GRID[1])
	check(id + "_manifest_grid", grid_ok,
		"grid=%s expected=%s (SEASON_PLAN_01.md:189)" % [str(grid), str(EXPECTED_GRID)])

	# SP-6 selection hook: stats must report the season's manifest path.
	var atlas_v: Variant = stats.get("atlas", {})
	var atlas: Dictionary = atlas_v if atlas_v is Dictionary else {}
	var reported := str(stats.get("atlas_path", "")) + " " + str(atlas.get("manifest", ""))
	var expect_manifest := str(v.get("manifest", ""))
	check(id + "_atlas_selection", reported.contains(expect_manifest),
		"stats atlas_path/manifest=%s expected-to-contain=%s" % [reported, expect_manifest])

	# Mesh / UV2.x contract (world3d_terrain.gd:1093-1107,1194).
	var mi := _find_named(t, "HeightmapTerrain")
	var mesh: Mesh = (mi[0] as MeshInstance3D).mesh if not mi.is_empty() and mi[0] is MeshInstance3D else null
	var surfaces := mesh.get_surface_count() if mesh != null else -1
	var arrays: Array = mesh.surface_get_arrays(0) if surfaces > 0 else []
	var uv2_v: Variant = arrays[Mesh.ARRAY_TEX_UV2] if arrays.size() > Mesh.ARRAY_TEX_UV2 else null
	var uv2 := PackedVector2Array()
	if uv2_v is PackedVector2Array:
		uv2 = (uv2_v as PackedVector2Array).duplicate()
	v["uv2_copy"] = uv2
	_m[id + "_mesh_surfaces"] = surfaces
	_m[id + "_uv2_entries"] = uv2.size()
	check(id + "_uv2_entry_count", surfaces == 1 and uv2.size() == _w * _h,
		"surfaces=%d uv2=%d expected=%d" % [surfaces, uv2.size(), _w * _h])

	var named := _manifest_named(man)
	var bad := 0
	var min_x := INF
	var max_x := -INF
	for i in range(uv2.size()):
		var x: float = uv2[i].x
		min_x = minf(min_x, x)
		max_x = maxf(max_x, x)
		if x < 0.0 or x > float(named - 1) or absf(x - floorf(x)) > 0.001:
			bad += 1
	v["uv2_out_of_range"] = bad
	v["uv2_x_min"] = min_x
	v["uv2_x_max"] = max_x
	_m[id + "_uv2_x_min"] = min_x
	_m[id + "_uv2_x_max"] = max_x
	_m[id + "_uv2_out_of_range"] = bad
	check(id + "_uv2_x_in_range", bad == 0,
		"out-of-range/non-integral UV2.x=%d range=[%s,%s] named=%d" % [
			bad, str(min_x), str(max_x), named])

	if id == "winter":
		_check_winter_dictionary(v)
	elif id == "desert":
		_check_desert_remap(v)

	if _headless:
		v["capture_status"] = "SKIP_CAPTURE"
		_free_variant_terrain(v)
		call_deferred("_advance_variant")


func _free_variant_terrain(v: Dictionary) -> void:
	var t_v: Variant = v.get("terrain", null)
	if t_v is Node and is_instance_valid(t_v):
		var n := t_v as Node
		if n.get_parent() != null:
			n.get_parent().remove_child(n)
		n.queue_free()
	v["terrain"] = null


# ------------------------------------------------------------------- PNG metrics
# Mirror of smallmap_capture.py:21-39 (READ-ONLY), as in t_terrain_only.gd:361-391.
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
		"width": w, "height": h,
		"non_black_fraction": float(non_black) / n,
		"mean_luma": luma_sum / n,
		"full_width_dark_rows": dark_rows,
	}


func _capture_variant(v: Dictionary) -> void:
	var id := str(v.get("id", ""))
	if _capture_view != null:
		_capture_view.render_target_update_mode = SubViewport.UPDATE_ONCE
	await RenderingServer.frame_post_draw
	if _finished:
		return
	var tex := _capture_view.get_texture() if _capture_view != null else null
	var img: Image = tex.get_image() if tex != null else null
	if img == null or img.is_empty():
		check(id + "_capture_image", false,
			"blank SubViewport texture — no CPU fallback (main.gd:1846-1853)")
		v["capture_status"] = "FAIL"
		_internal_error = true
		_free_variant_terrain(v)
		call_deferred("_advance_variant")
		return
	check(id + "_capture_image", true, "SubViewport texture %dx%d" % [img.get_width(), img.get_height()])
	var abs_png := str(v.get("png_path", ""))
	if abs_png == "":
		check(id + "_capture_saved", false,
			"windowed run needs --%s-png <abs.png> user arg" % id)
		v["capture_status"] = "FAIL"
		_internal_error = true
		_free_variant_terrain(v)
		call_deferred("_advance_variant")
		return
	if not abs_png.is_absolute_path() and not abs_png.begins_with("user://"):
		abs_png = ProjectSettings.globalize_path("res://").get_base_dir().path_join(abs_png)
	var dir := abs_png.get_base_dir()
	if dir != "" and not DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_recursive_absolute(dir)
	var err := img.save_png(abs_png)
	check(id + "_capture_saved", err == OK, "save_png(%s) err=%d" % [abs_png, err])
	if err != OK:
		v["capture_status"] = "FAIL"
		_internal_error = true
		_free_variant_terrain(v)
		call_deferred("_advance_variant")
		return
	var ms := _image_metrics(img)
	ms["png_path"] = abs_png
	ms["bytes"] = FileAccess.get_file_as_bytes(abs_png).size()
	_m[id + "_png_metrics"] = ms
	check(id + "_non_black_fraction", float(ms["non_black_fraction"]) > 0.9,
		"non_black_fraction=%s (expected >0.9; smallmap_capture.py:26)" % str(ms["non_black_fraction"]))
	check(id + "_full_width_dark_rows", int(ms["full_width_dark_rows"]) == 0,
		"full_width_dark_rows=%d (expected 0; smallmap_capture.py:27-28)" % int(ms["full_width_dark_rows"]))
	v["capture_status"] = "PASS"
	_free_variant_terrain(v)
	call_deferred("_advance_variant")


# ------------------------------------------------------------------- state loop
func _advance_variant() -> void:
	if _finished:
		return
	_variant_index += 1
	if _variant_index >= _variants.size():
		_finalize()
		return
	var v: Dictionary = _variants[_variant_index]
	var id := str(v.get("id", ""))
	_note_dependency(v)
	var status := str(v.get("status", ""))
	if status == STATUS_PENDING:
		# No build, no PNG, no fake PASS: the atom reports the unmet dependency.
		check(id + "_build_ok", null, "skipped: dependencies not on disk", STATUS_PENDING)
		check(id + "_uv2_x_in_range", null, "skipped: dependencies not on disk", STATUS_PENDING)
		check(id + "_atlas_selection", null, "skipped: dependencies not on disk", STATUS_PENDING)
		check(id + "_capture_image", null, "skipped: dependencies not on disk", STATUS_PENDING)
		call_deferred("_advance_variant")
		return
	if status == STATUS_FAIL:
		call_deferred("_advance_variant")
		return
	_variant_frames = 0
	_capturing = false
	_build_variant(v)
	if str(v.get("status", "")) != STATUS_BUILT:
		call_deferred("_advance_variant")


func _process(_delta: float) -> bool:
	if _finished or _variant_index < 0 or _variant_index >= _variants.size():
		return false
	if _headless or _capturing:
		return false
	var v: Dictionary = _variants[_variant_index]
	if str(v.get("status", "")) != STATUS_BUILT:
		return false
	if bool(v.get("capturing", false)):
		return false
	_variant_frames += 1
	if _variant_frames >= CAPTURE_FRAMES:
		v["capturing"] = true
		_capturing = true
		_capture_variant(v)
	return false


func _variant_by_id(id: String) -> Dictionary:
	for v in _variants:
		if str(v.get("id", "")) == id:
			return v
	return {}


func _uv2_equal(a: PackedVector2Array, b: PackedVector2Array) -> bool:
	if a.size() != b.size():
		return false
	for i in range(a.size()):
		if absf(a[i].x - b[i].x) > 0.001 or absf(a[i].y - b[i].y) > 0.001:
			return false
	return true


func _cross_variant_checks() -> void:
	var summer := _variant_by_id("summer")
	var winter := _variant_by_id("winter")
	var desert := _variant_by_id("desert")

	# The fixture dump must never be mutated by a season hook (SEASON_PLAN_01.md:164,
	# :191 "Summer dump byte-identical"). The stub game carries the same tileblock
	# for all three builds; verify the bytes are unchanged at the end.
	var now_v: Variant = _game.get("tileblock") if _game != null else null
	var unchanged: bool = (now_v is PackedByteArray
		and (now_v as PackedByteArray) == _tileblock_original)
	check("tileblock_index_preserved", unchanged,
		"dump tileblock byte-identical after all variants=%s (same input for every season)" % str(unchanged))

	# Winter is a texture-only swap in the derived port mapping (SEASON_PLAN_01.md:
	# 161-166, :211 B4): UV2.x must be element-for-element identical to Summer.
	var su: Variant = summer.get("uv2_copy", null)
	var wi: Variant = winter.get("uv2_copy", null)
	if su is PackedVector2Array and wi is PackedVector2Array:
		check("uv2_x_summer_winter_identical", _uv2_equal(su, wi),
			"summer/winter UV2.x array equality (index-preserving atlas swap; B4)")
	else:
		check("uv2_x_summer_winter_identical", null,
			"skipped: winter variant %s" % str(winter.get("status", "missing")), STATUS_PENDING)

	# Desert is a name remap, not a palette swap (SEASON_PLAN_01.md:149,:168-170).
	# Require every desert UV2.x to equal SP-3's index remap of the summer value
	# at the same cell: strict, deterministic, 1:1 consistency — no weakening.
	var de: Variant = desert.get("uv2_copy", null)
	if su is PackedVector2Array and de is PackedVector2Array:
		var idx_map: Dictionary = desert.get("desert_index_map", {})
		var mismatches := 0
		for i in range((su as PackedVector2Array).size()):
			var sx := int((su as PackedVector2Array)[i].x)
			var expected := int(idx_map.get(str(sx), sx))
			if int((de as PackedVector2Array)[i].x) != expected:
				mismatches += 1
		_m["desert_uv2_mismatches"] = mismatches
		check("uv2_x_desert_remap_consistent", mismatches == 0,
			"desert UV2.x != SP-3 remap(summer UV2.x) at %d cells (expected 0)" % mismatches)
	else:
		check("uv2_x_desert_remap_consistent", null,
			"skipped: desert variant %s" % str(desert.get("status", "missing")), STATUS_PENDING)

	# Internal error path: no failed build, no failed manifest parse, no
	# exception-handled abort. External stderr scan stays explicitly pending —
	# GDScript has no stderr API (TEST_P0_report.md:89, :160-163).
	check("no_script_errors_internal", not _internal_error,
		"internal error paths fired=%s (external scan still required)" % str(_internal_error))
	check("script_error_scan_external", null,
		"run: python variant3d\\tools\\smallmap_capture.py scan-stderr <runner stderr.txt>",
		"PENDING_EXTERNAL_SCAN")


func _finalize() -> void:
	if _finished:
		return
	DATA_SCRIPT.BIOME = "summer"   # restore global static after all variants
	_cross_variant_checks()
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
	var summary: Array[Dictionary] = []
	for v in _variants:
		summary.append({
			"id": v.get("id", ""),
			"biome": v.get("biome", ""),
			"status": v.get("status", ""),
			"missing": v.get("missing", []),
			"manifest": v.get("manifest", ""),
			"png_path": v.get("png_path", ""),
			"capture_status": v.get("capture_status", ""),
			"uv2_out_of_range": v.get("uv2_out_of_range", -1),
			"atlas_mode": str((v.get("stats", {}) as Dictionary).get("atlas_mode", "")),
		})
	var out := {
		"id": _id,
		"passed": verdict == "PASS",
		"verdict": verdict,
		"passes": passes,
		"fails": fails,
		"skipped_or_pending": skips,
		"checks": _checks,
		"variants": summary,
		"measured": _m,
		"harness_source": _harness_source,
		"headless": _headless,
		"capture_status": ("SKIP_CAPTURE" if _headless else "see variants[].capture_status"),
		"skip_reason": ("" if not _headless else
			"DisplayServer.get_name()==headless: 3D PNG not available; state-only result"),
		"script_error_note": "verify via smallmap_capture.py scan-stderr on runner stderr.txt",
		"parity_label": ("PORT APPROXIMATION — internal consistency only; "
			+ "no donor GPU A/B (TEST_MATRIX.md:46,73-75); flat TERRAIN_TINT "
			+ "is legacy art, not the donor swap (SEASON_PLAN_01.md:215 B9)"),
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
		_internal_error = true
		push_error("t_season_overlay: cannot write result: " + abs_path)
	print("T_SEASON_OVERLAY RESULT_JSON: " + abs_path)
	print("T_SEASON_OVERLAY RESULT: %s %d evaluated-true / %d false / %d skipped-or-pending"
		% [verdict, passes, fails, skips])
	print("T_SEASON_OVERLAY STDERR_SCAN_REQUIRED (runner stderr.txt)")
	# SKIP_CAPTURE / PENDING_DEP are never a full PASS; exit 0 only when no
	# evaluated check failed (TEST_P0_report.md:236-239 precedent).
	call_deferred("quit", 0 if _ok else 1)


func _failsafe() -> void:
	if _finished or _setup_done:
		return
	check("setup", false, "atom aborted before setup completed")
	_finished = true
	call_deferred("quit", 1)


func _initialize() -> void:
	if _finished:
		return
	call_deferred("_failsafe")
	_headless = DisplayServer.get_name() == "headless"
	_m["display_server"] = DisplayServer.get_name()
	_m["headless"] = _headless

	_load_fixture()
	var summer_names: Variant = _read_json_variant(SUMMER_DICT_PATH)
	_names = summer_names if summer_names is Array else []
	_m["summer_names"] = _names.size()
	if _names.is_empty():
		_internal_error = true
		check("summer_dictionary", false, "cannot parse " + SUMMER_DICT_PATH)
		_setup_done = true
		_finished = true
		call_deferred("quit", 1)
		return
	check("summer_dictionary", true, "presets_summer.json entries=%d" % _names.size())
	_make_grid()

	_game = _make_stub_game()
	_m["harness_source"] = _harness_source
	var shape_ok: bool = (_game != null and is_instance_valid(_game)
		and int(_game.get("MAP_W")) == _w and int(_game.get("MAP_H")) == _h
		and (_game.get("height") is PackedFloat32Array)
		and (_game.get("tileblock") is PackedByteArray)
		and (_game.get("res_nodes") is Array))
	check("harness_stub_shape", shape_ok,
		"source=%s MAP=%dx%d dump shape present=%s" % [
			_harness_source, _w, _h, str(shape_ok)])
	if not shape_ok:
		_internal_error = true
		_setup_done = true
		_finished = true
		call_deferred("quit", 1)
		return

	# SP-5 is on disk on this tree; exercise its override API regardless of
	# whether winter assets exist, so a later winter failure is attributable.
	check("sp5_manifest_override_api", _sp5_override_api_ok(),
		"TileAtlasLoader.new('single', {'manifest_path':…,'single_atlas_path':…}) "
		+ "exposes both overrides (tile_atlas_loader.gd:77,86,99-118)")

	# Camera + module API probes before any variant build.
	var terrain_script := load(TERRAIN_PATH) as Script
	var terrain_api := (terrain_script != null and terrain_script.can_instantiate())
	var camera_script := load(CAMERA_PATH) as Script
	var camera_api := (camera_script != null and camera_script.can_instantiate())
	check("terrain_camera_scripts", terrain_api and camera_api,
		"terrain=%s camera=%s" % [str(terrain_api), str(camera_api)])
	if not terrain_api or not camera_api:
		_internal_error = true
		_setup_done = true
		_finished = true
		call_deferred("quit", 1)
		return

	if not _headless:
		get_root().size = WINDOW_SIZE
		_capture_view = SubViewport.new()
		_capture_view.name = "SeasonOverlayViewport"
		_capture_view.world_3d = World3D.new()
		_capture_view.size = WINDOW_SIZE
		_capture_view.render_target_update_mode = SubViewport.UPDATE_ONCE
		get_root().add_child(_capture_view)
	var parent: Node = _capture_view if _capture_view != null else get_root()
	_camera = camera_script.new() as Camera3D
	_camera.name = "SeasonCamera"
	parent.add_child(_camera)
	_camera.call("bind", _game)
	_camera.set_process(false)   # freeze edge-scroll (camera3d.gd:484-581)
	_camera.make_current()

	_variants = [
		_make_variant("summer", "summer", SUMMER_MANIFEST_PATH),
		_make_variant("winter", "winter", WINTER_MANIFEST_PATH),
		_make_variant("desert", "desert", SUMMER_MANIFEST_PATH),
	]
	_m["camera"] = "camera3d.gd (single instance, bound once, process disabled)"
	_m["dependency_note"] = ("SP-1, SP-2 (atlas/winter_aliases.json), SP-3 "
		+ "(atlas/desert_remap.json) and SP-5 manifest_path are on disk; SP-4 "
		+ "winter atlas files are gated by FileAccess.file_exists and the SP-6 "
		+ "render hook by a source-text probe.")
	_setup_done = true
	_variant_index = -1
	call_deferred("_advance_variant")
