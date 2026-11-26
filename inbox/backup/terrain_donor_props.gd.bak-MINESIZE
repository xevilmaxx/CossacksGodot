# ---------------------------------------------------------------------------
# variant3d/scripts/terrain_donor_props.gd — I09 owner file (2026-11-26)
# DONOR-FIRST terrain swarm / prop + landscape-class instancer.
#
# PROVENANCE / PARITY GUARD (binding)
#   Donor material is READ ONLY at C:\Games\Cossacks 3. No donor binary was run,
#   copied or committed by this ticket; no Godot process, runner job, gate, git
#   operation, asset, shader, test or app/ file was touched. This file is the
#   ONLY repo file written by I09 (V11 ledger N12, V11_ownership_ledger.md:104).
#   NO DONOR PARITY CLAIM: no donor GPU A/B frame exists
#   (docs/terrain_swarm_2026-11-26/CHARTER.md:43-44, :122-130).
#   Every visual statement here is PORT APPROXIMATION or UNVERIFIED.
#
#   Donor channel model (spec/08_FIELDS_AND_PROPS.md:6-15):
#     H = authored float32 height windows  -> owned by I07/I08, NOT by this file;
#     P = pattern.lib `Objects` 3D props    -> THIS FILE;
#     T = tile/decal/shader art             -> owned by I08/I10, NOT by this file.
#   A flat height field cannot supply mountain silhouettes: g_mnt_* has a zero
#   height grid and carries terrainmeshN props (pattern.lib:337491-337492,
#   :338480-338507; A04_landscape_props.md:81, :225-235).
#
#   V08 COORDINATE/SCALE CONTRACT (binding; COORD correction 2026-11-26):
#   [D] 1 donor generator distance unit = 1 MAP CELL. The old port
#   `DONOR_UNITS=160`, `s = MAP_W/160`, "1 unit = 2 cells" is REFUTED by V08
#   (reports/V08_coordinate_scale.md:40-51, :155-176, E23 :142): donor radii,
#   ellipses 5x7/12x15/22x18 (dogenerate.inc:407-414), forest pass radii and
#   the field step 1.6981 cells (unit.script:6480) are all CELLS, 1:1.
#   `TILE_M=2.0` is donor-grounded *horizontal metres per cell* ONLY
#   (donor dmscript.global:170-173, gc_meters_to_tile=2; V08 C2 :182-193) and
#   is used here solely to place a prop in world space. It is NEVER a generator
#   distance multiplier and no footprint is doubled at 320². Sampling a
#   fractional donor Position to an integer cell is an explicit PORT APPROX.
#
#   Inputs consumed:
#     * I06 container C3TerrainData (terrain_donor_data.gd:27-28, :151-159,
#       :252-264) — READ ONLY. No height/tex/collision/props/resource write.
#     * I07 stamp output (IMPLEMENTATION_PLAN.md:15): an ordered Array of stamp
#       dictionaries/objects (name + cell) passed to build(), or the same array
#       under container.meta["pattern_stamps"] / dump["fields"]["pattern_stamps"].
#     * I03 compact props feed, when present:
#       res://assets/terrain_new/props/props_index.json + only the family bundles
#       named by accepted stamps. The 55.8 MB lib/pattern_lib_index.json monolith
#       remains a labelled fallback walker. Both feeds carry pattern -> Objects[];
#       absent => UNVERIFIED, never guessed. The committed Z08-derived table
#       res://assets/terrain/mountain_props.json is the clearly labelled
#       PORT APPROX fallback for transforms; if neither feed has a record, the
#       record is SKIPPED, not synthesised. No synthetic scatter, no noise field,
#       no RNG draw, no invented transform.
#
#   Citation convention: `# donor <path>:<line>` = read-only donor observation;
#   `# port <path>:<line>` = port/spec/report line used as implementation input.
# ---------------------------------------------------------------------------
extends Node3D
class_name C3TerrainDonorProps

const MODULE_ID: String = "I09/terrain_donor_props"
const GROUP: String = "terrain_donor_props"

# --- decoded feeds / fallback (I03 output, V11 ledger G3/G5) ----------------
const FEED_PROPS_DIR: String = "res://assets/terrain_new/props"
const FEED_PROPS_INDEX: String = "res://assets/terrain_new/props/props_index.json"  # PERF-FEED compact index; preferred when valid
const FEED_PROPS_SCHEMA: String = "terrain_new/props_preindex/v1"
const FEED_LIB_INDEX: String = "res://assets/terrain_new/lib/pattern_lib_index.json"     # legacy monolith walker fallback (V64/V66; V11's patterns/ path is stale)
const FEED_FAMILY_INDEX: String = "res://assets/terrain_new/lib/pattern_lib_index.json"  # legacy alias of the same monolith; not parsed twice
const FEED_FALLBACK: String = "res://assets/terrain/mountain_props.json"                    # port world3d_relief.gd:42; V07 E03
const MODEL_MANIFEST: String = "res://assets/models/manifest.json"                           # port asset_paths.gd:15

# --- exact converted asset paths used / inventoried ------------------------
const BLOCK_PNG_DIR: String = "res://assets/terrain/blocks"                                 # port V07 E08 (112 PNGs)
const FIELD_OBJ: String = "res://assets/models/obj/shared/terrain/field.obj"                # port F07 §3.3 / V07 E13
const FIELD_DECALS: Array[String] = [
	"res://assets/terrain/deco_png/envfieldd.png",                                           # port F07 E9 / V07 E13
	"res://assets/terrain/deco_png/envfielddw.png",                                          # port F07 E9 / V07 E13
]
const MINE_MESH_PATHS: Dictionary = {
	"mine_gold": "res://assets/models/obj/shared/buildings/mine_gold.obj",                   # port manifest.json:2210-2232 (donor minegold.osm)
	"mine_iron": "res://assets/models/obj/shared/buildings/mine_iron.obj",                   # port manifest.json:2235-2257 (donor mineiron.osm)
	"mine_coal": "res://assets/models/obj/shared/buildings/mine_coal.obj",                   # port manifest.json:2260-2282 (donor minecoal.osm)
}
const WAVE_SHEETS: Array[String] = [
	"res://assets/terrain/water_png/diffusewaves0.png",                                      # port V07 E14 / F08 water inventory
	"res://assets/terrain/water_png/diffusewaves1.png",
	"res://assets/terrain/water_png/diffusewaves2.png",
	"res://assets/terrain/water_png/diffusewaves3.png",
	"res://assets/terrain/water_png/diffusewaves4.png",
	"res://assets/terrain/water_png/diffusewaves5.png",
	"res://assets/terrain/water_png/diffusewaves6.png",
	"res://assets/terrain/water_png/diffusewaves7.png",
]

# --- donor-cited constants (no new donor constant is invented) -------------
# DONOR_UNITS=160 / s=MAP_W/160 is REFUTED — removed deliberately (V08 :40-51, E23 :142).
const TILE_M: float = 2.0                           # donor dmscript.global:170-173 (metres/cell); V08 C2 :182-193 — world placement ONLY
const MOUNTAIN_RECORDS_TOTAL: int = 112             # donor pattern.lib:338480+; port V07 E03 / mountain_props.json:2596
const MOUNTAIN_STAMPABLE_SECTIONS: int = 20         # donor pattern.lib; port V07 E03 / mountain_props.json:2597
const MOUNTAIN_STAMPABLE_RECORDS: int = 45          # donor pattern.lib; port V07 E03 / A04 E08
const FRS_BIG: float = 0.0009                       # donor data/scripts/common.inc/dogenerate.inc:1688
const FRS_MID: float = 0.0009                       # donor data/scripts/common.inc/dogenerate.inc:1689
const FRS_SMALL: float = 0.00054                    # donor data/scripts/common.inc/dogenerate.inc:1690
const STN1: float = 0.00016                         # donor data/scripts/common.inc/dogenerate.inc:1692
const STN2: float = 0.00012                         # donor data/scripts/common.inc/dogenerate.inc:1693
const FOREST_TYPE_CONIFER: int = 0                  # donor data/scripts/common.inc/dogenerate.inc:5-6 (foreststype forced 0)
const MINE_STAMP_W: int = 8                         # donor data/game/var/generator.cfg:69 (mng_1 8x10)
const MINE_STAMP_H: int = 10                        # donor data/game/var/generator.cfg:69
const MINE_RING_MIN: int = 3                        # donor data/scripts/common.inc/dogenerate.inc:528-534 (density 0)
const MINE_RING_MAX: int = 5                        # donor data/scripts/common.inc/dogenerate.inc:528-534 (density 2)
const MINE_ORES: Array[String] = ["mng", "mni", "mnc"]  # donor data/scripts/common.inc/dogenerate.inc:547-551
const KEEP_CLEAR_ELLIPSES_CELLS: Array = [[5, 7], [12, 15], [22, 18]]  # donor dogenerate.inc:407-414; CELLS 1:1 (V08 C1)
const FIELD_ROWS: int = 7                           # donor data/scripts/lib/unit.script:6475-6476 (cRow=7, cCount=49)
const FIELD_NODES: int = 49                         # donor data/scripts/lib/unit.script:6476
const FIELD_STEP_CELLS: float = 1.6981              # donor data/scripts/lib/unit.script:6480 (size); CELLS not metres (V08 C1)
const FIELD_ANGLE_DEG: float = 45.0                  # donor data/scripts/lib/unit.script:6494 (VectorRotateY 45)
const FIELD_SNAP_CELLS: float = 2.401476            # [D] sqrt(2)*size; donor data/scripts/lib/unit.script:6497-6499
const FIELD_FOOD_CLEAR_CELLS: float = 1.52829       # donor data/scripts/lib/unit.script:6536-6538 (rad/3)
const FIELD_ORE_CLEAR_CELLS: float = 4.58487        # donor data/scripts/lib/unit.script:6527-6528 (rad)
const FIELD_COST_GOLD: int = 5                      # donor data/scripts/lib/unit.script:1691-1693
const WATER_DEPTH_TERM: float = -1.1                # donor data/scripts/common.inc/generatemap.inc:567-574
const WATER_CLASSIFY_H: float = -0.25               # donor data/scripts/common.inc/texturemap.inc:29-31
const SHORE_CLASSIFY_H: float = -0.1                # donor data/scripts/common.inc/texturemap.inc:29-31
const SHORE_TILE_IDS: Array[int] = [93, 97, 98]     # port atlas manifest.json:2284,2380,2404 (sandsea1/5/6)
const DONOR_MESH_LOD_MAX: float = 150.0             # donor data/actors/ref/refobj.actor:46-49,93-95 ([U] metres) — per-object MESH LOD
const DONOR_SHADER_LOD_MAX: float = 2500.0          # donor data/actors/ref/refobj.actor:93-95 ([U] metres) — SHADER/distance LOD, distinct control
const FOREST_BORDER_LITE_PROB: float = 0.6          # donor data/scripts/common.inc/smoothforestborders.inc:100-113 (via X03:1200)

# --- DEC-VIS-02 §6.2/§6.3 donor-literal terrainmesh placement ----------------
# [O] pattern.lib fields (read-only): every relief pattern whose Objects[] carry
# terrainmesh1..4 shares these values; only Width/Height differ. Sources:
# pattern_lib_index.json sections[g_mnt_* / i_mnt_* / desert_mnt_*].fields;
# donor misc.script:3387-3390 computes angleRad = angle*pi/180 and every
# caller (dogenerate.inc:1349,1796; generatemap.inc:956; texturemap.inc:216,
# :287, :323; smoothforestborders.inc:123) passes angle=0 -> rotangle=0 rad.
# [U] The final-turn helper's rotation axis is not pinned by DEC-VIS-02; with
# rotangle=0 the turn is identity, so no axis sign is invented here.
const DONOR_TM_OBJECTS_SCALE: float = 1.0           # donor pattern.lib ObjectsScale +0x6c
const DONOR_TM_OFFSET_X: float = 0.0                # donor pattern.lib OffsetX +0x74
const DONOR_TM_OFFSET_Z: float = 0.0                # donor pattern.lib OffsetZ +0x78
const DONOR_TM_ROTANGLE: float = 0.0                # donor misc.script:3390 angleRad, radians
const DONOR_TM_HEIGHT_SCALE: float = 1.0            # donor pattern.lib HeightFieldScale +0x48
const DONOR_TM_OBJECTS_OFFSET: bool = false         # donor pattern.lib ObjectsOffset +0x7c
const DONOR_TM_HEIGHT_OFFSET: bool = false          # donor pattern.lib ObjectsHeightOffset +0x7d
const DONOR_TM_AUTO_OFFSET: bool = false            # donor pattern.lib ObjAutoOffset +0x7f
const DONOR_TM_IGNORE_MATRIX: bool = false          # donor pattern.lib IgnoreMatrix +0x7e

# [O] donor pattern.lib fields Width/Height for the 31 relief patterns that
# actually carry terrainmesh records in the I03 compact bundles. Absent pattern
# => no donor-derived transform is invented; the legacy PORT APPROX path stays.
const DONOR_TM_PATTERN_DIMS: Dictionary = {
	"g_mnt_1": Vector2i(43, 38), "g_mnt_2": Vector2i(43, 29),
	"g_mnt_3": Vector2i(32, 37), "g_mnt_4": Vector2i(31, 26),
	"g_mnt_5": Vector2i(38, 43), "g_mnt_6": Vector2i(40, 38),
	"g_mnt_7": Vector2i(44, 50),
	"i_mnt_big_1": Vector2i(51, 55), "i_mnt_big_2": Vector2i(61, 56),
	"i_mnt_big_3": Vector2i(64, 43), "i_mnt_big_4": Vector2i(50, 72),
	"i_mnt_big_5": Vector2i(58, 51),
	"i_mnt_long_1": Vector2i(61, 64), "i_mnt_long_2": Vector2i(58, 58),
	"i_mnt_long_3": Vector2i(64, 53), "i_mnt_long_4": Vector2i(53, 60),
	"i_mnt_long_5": Vector2i(48, 67),
	"desert_mnt_1": Vector2i(30, 29), "desert_mnt_2": Vector2i(29, 25),
	"desert_mnt_3": Vector2i(28, 26), "desert_mnt_4": Vector2i(27, 25),
	"desert_mnt_5": Vector2i(24, 27), "desert_mnt_6": Vector2i(25, 24),
	"desert_mnt_7": Vector2i(31, 28), "desert_mnt_8": Vector2i(31, 25),
	"desert_mnt_9": Vector2i(23, 24), "desert_mnt_10": Vector2i(25, 23),
	"desert_mnt_11": Vector2i(28, 20), "desert_mnt_12": Vector2i(23, 20),
	"desert_mnt_13": Vector2i(22, 21),
}
const DONOR_TM_LABEL: String = ("DEC-VIS-02 §6.2/§6.3 donor-order terrainmesh placement; "
	+ "PORT APPROX half-cell -> world mapping; parity UNVERIFIED")
const FOREST_BORDER_FB_P: float = 0.025             # donor data/scripts/common.inc/smoothforestborders.inc:36-148 (via X03:1200)
const FOREST_BORDER_FB_RAD: float = 1.5             # donor data/scripts/common.inc/smoothforestborders.inc:36-148 (via X03:1200)

# spec/10_STAGE_ORDER.md:1 item 8 (relief+mines) -> item 9 (forest/stone/decor)
# -> item 10 (units/scale). Mill fields are script-sown, so their hook is last.
const CLASS_PASS_ORDER: Array[String] = [
	"hills_mountains", "mines", "shore", "forests", "stone_quarries",
	"swamps_lakes", "decor", "mill_fields",
]

const RELIEF_SIDS: Array[String] = [
	"terrainmesh1", "terrainmesh2", "terrainmesh3", "terrainmesh4",   # donor actors.lib:1200-1213
]

# 19 forest families catalogued by F08 §3.1 (reports/F08_flora_minerals.md:125-145).
const EXPECTED_FOREST_FAMILIES: Array[String] = [
	"forests_pinefir_big", "forests_pinefir_medium", "forests_pinefir_small",
	"forests_spruce_big", "forests_spruce_medium", "forests_pinedrygreen_small",
	"forests_pine_small", "forests_pine_medium", "forests_pine_big",
	"forests_pine_big_2", "forests_mixed_big", "forests_mixed_medium",
	"forests_leaf_big", "forests_leaf_medium", "forests_leaf_small",
	"desert_forests_medium", "desert_forests_small", "desert_forests_unique",
	"desert_forests_big",
]

# Static UNVERIFIED register. Each entry is a missing/unproven item; nothing
# here is promoted to a donor fact and no missing asset is fabricated.
const UNVERIFIED_BASE: Dictionary = {
	"PARITY": "UNVERIFIED — no donor GPU A/B frame (CHARTER.md:43-44,125)",
	"TRANSFORM_MATH": "DEC-VIS-02 §6 recovered donor order (rotate PI-rotangle -> ObjectsScale -> centre; Y/Direction/Up/Scaling/final turn); [U] half-cell->world mapping, matrix slot mapping and final-turn axis remain unverified; no parity claim",
	"TERRAINMESH_HALF_CELL": "UNVERIFIED — [U] donor centre already carries +0.5; port maps donor cell-centre to world without a second +0.5 (DEC-VIS-02 §6.2)",
	"TERRAINMESH_TURN_AXIS": "UNVERIFIED — [U] sub_7cca74 final-turn axis not pinned by DEC-VIS-02; donor rotangle=0 makes it identity here; unit discontinuity preserved, not corrected",
	"YAW_SIGN": "UNVERIFIED — donor Y-yaw -> Godot Y-up sign (DTRN-02 C20; world3d_relief.gd:21-35)",
	"METRES_PER_CELL": "DONOR-GROUNDED horizontal 2 m/cell (dmscript.global:170-173; V08 C2), world placement only; height float unit [U]; generator distances stay CELLS 1:1 (V08 C1)",
	"ROW_SIGN": "UNVERIFIED — donor pattern row sign (DPATTERN_01 §2.2 / terrain_donor_data.gd:39)",
	"FLOAT_WINDOWS": "UNVERIFIED — relief float windows not exported; I02 owns them (V07 E06/E17)",
	"X16_COVERAGE": "UNVERIFIED — X16_prop_mesh_coverage report not landed at this write; mesh coverage unproven",
	"DESERT_SIDS": "UNVERIFIED — 23 desert_mnt records have no converted sid; skipped_unknown_sid (V07 M4 / world3d_relief.gd:166-167)",
	"WINTER_RELIEF": "UNVERIFIED — winter terrainmeshNw / winter trees have no second sid (Z05 §1.3; A04 §8 item 5)",
	"PLATEAU_PROPS": "UNVERIFIED — terrainplateau1..4 have no albedo/.prop/BaseName link (Z05 §1.3)",
	"MILL_DEATH_STAGES": "UNVERIFIED — eurmil_death1/2 + scaffolds not converted (F07 §3.1)",
	"RUS_TUR_MILLS": "UNVERIFIED — rusmil/turmil bodies, props, textures not converted (F07 §3.1)",
	"ROTOR_OSS_AAF": "UNVERIFIED — eurmilanim.oss/.aaf and rusmilanim not converted; baked PNG is PORT APPROX (F07 §3.2)",
	"WINTER_CROPS": "UNVERIFIED — fieldw/field1w..4w not converted (F07 §3.3)",
	"FIELD_VARIANTS": "UNVERIFIED — field2/field3 meshes and field2..4 albedos not converted (F07 §3.3)",
	"PUMPS": "UNVERIFIED — k_pump_* 15 patterns and pump meshes/texture not converted (F07 §3.4; F08 E15)",
	"FIELD_DECAL_UV": "UNVERIFIED — 3D UV/epsilon binding of envfieldd/w (world3d_entities.gd:315; F07 E5)",
	"MINE_RECORD_BINDING": "UNVERIFIED — mine stamp record-id -> prop mapping (DTRN-05 Q1/Q2; A04 §8 item 11)",
	"SHORE_SUBSTRATE": "UNVERIFIED — donor mask.b>0 shore substrate binding (G26-5; A04 §8 item 10)",
	"SWAMP_LAKE_EXPORT": "UNVERIFIED — swamp/lake families absent from donor_patterns.json (V07 E16)",
	"LAKE_BIG_ANOMALY": "UNVERIFIED — lake_big := plain*2*0 literal zero preserved (A04 E20 / spec/10 §5 A3)",
	"ACTIVATION": "UNVERIFIED — all cited .inc callers are commented [*] = ; text (F07 §1; F08 §0)",
	"LOD_UNITS": "UNVERIFIED — donor LOD literals 0..150 / 0..2500 have [U] metre meaning (refobj.actor:46-49,93-95)",
	"WEEKLY_CONSTANT": "UNVERIFIED — no donor 'weekly' constant found in X03/D06; none invented; X03/D06 forest-border literals used instead",
	"FAMILY_INDEX": "UNVERIFIED — compact section_family is derived bundle grouping; authoritative generator_families membership is not carried",
}

const AssetPaths = preload("res://scripts/asset_paths.gd")

var _container: Object = null
var _terrain: Object = null
var _stamps: Array = []

var _records: Dictionary = {}          # pattern name -> Array[Dictionary] (feed order)
var _family_of_pattern: Dictionary = {}
var _feed_source: String = ""
var _feed_kind: String = ""
var _feed_metrics: Dictionary = {}
var _fallback_used: bool = false
var _known_sids: Dictionary = {}
var _meshes: Dictionary = {}
var _bboxes: Dictionary = {}
var _batches: Dictionary = {}
var _props: Array[Dictionary] = []
var _unverified: Array[String] = []
var _stats: Dictionary = {}
var _lod_enabled: bool = false
var _built: bool = false


func _ready() -> void:
	if _stats.is_empty():
		_stats = _fresh_stats("UNBUILT")


# ---------------------------------------------------------------------------
# Public API for I11 (composer) / I12 (determinism + telemetry atom).
#   build(container, stamps, options) -> stats     main entry, render-only
#   rebuild() -> stats                             rebuild from bound inputs
#   stats() / unverified() / props()               read-only telemetry
#   set_props_visible(bool)                        props ON/OFF internal A/B
#   set_lod_enabled(bool) / update_lod(camera)     donor-cited LOD only
#   mill_field_hook(cell)                          script-sow hook, no stamping
#   asset_inventory() / clear()
# ---------------------------------------------------------------------------
func build(p_container: Object, p_stamps: Array, p_options: Dictionary = {}) -> Dictionary:
	_container = p_container
	_stamps = p_stamps.duplicate(true)
	_terrain = p_options.get("terrain", null) as Object
	if p_options.has("lod_enabled"):
		_lod_enabled = bool(p_options["lod_enabled"])
	return rebuild()


func rebuild() -> Dictionary:
	_clear_batches()
	_props.clear()
	_built = false
	var st: Dictionary = _fresh_stats("BUILT")
	_unverified = []
	for key in UNVERIFIED_BASE.keys():
		_unverified.append(str(UNVERIFIED_BASE[key]))

	_load_manifest()

	var placements: Array[Dictionary] = []
	var stamp_list: Array = _stamps
	if stamp_list.is_empty() and _container != null:
		var cmeta: Variant = _container.get("meta")
		if cmeta is Dictionary and (cmeta as Dictionary).has("pattern_stamps"):
			var sv: Variant = (cmeta as Dictionary)["pattern_stamps"]
			if sv is Array:
				stamp_list = sv as Array
	if stamp_list.is_empty():
		_unverified.append("NO_I07_STAMP_LIST — build() got no stamps and I06 container carried none")
	var counts: Dictionary = st["counts"]
	counts["stamps_seen"] = stamp_list.size()
	_load_feed(st, stamp_list)

	# Collect in I07 stamp order; every Objects record is visited in donor feed
	# order (no sort, no RNG). Then emit in the donor stage order of spec §10 §1.
	for raw_stamp in stamp_list:
		_collect_stamp(raw_stamp, placements, st)

	for cls in CLASS_PASS_ORDER:
		for raw_p in placements:
			var p: Dictionary = raw_p as Dictionary
			if str(p.get("class", "")) == cls:
				_props.append(p)
				_add_to_batch(p, st)

	for key in _batches.keys():
		var holder: MultiMeshInstance3D = _batches[key] as MultiMeshInstance3D
		if holder == null:
			continue
		var mm: MultiMesh = holder.multimesh
		if mm != null:
			mm.instance_count = holder.get_meta("instance_count", 0)
		holder.visible = not _lod_enabled
		holder.set_meta("lod_enabled", _lod_enabled)

	counts["props_total"] = _props.size()
	counts["batches"] = _batches.size()
	counts["matched_stamps"] = int(counts["matched_stamps"])
	st["counts"] = counts
	st["sids"] = _batches.keys()
	var props_total: int = int(counts["props_total"])
	var donor_objects_instanced: bool = (
		props_total > 0 and not _fallback_used
		and (_feed_kind == "compact_preindex" or _feed_kind == "monolith_fallback"))
	var feed_label: String
	if donor_objects_instanced:
		feed_label = "DONOR LITERALS (I03 compact Objects[])" if _feed_kind == "compact_preindex" else "DONOR LITERALS (I03 Objects[]; monolith fallback)"
	elif props_total == 0:
		feed_label = "ZERO PROPS — feed/stamp/shape UNVERIFIED"
	elif _fallback_used:
		feed_label = "PORT APPROX — Z08 fallback table"
	else:
		feed_label = "UNVERIFIED — non-canonical object source"
	var feed_stats: Dictionary = {
		"source": _feed_source,
		"kind": _feed_kind,
		"fallback_used": _fallback_used,
		"label": feed_label,
	}
	for key in _feed_metrics.keys():
		feed_stats[key] = _feed_metrics[key]
	st["feed"] = feed_stats
	st["lod"] = {
		"enabled": _lod_enabled,
		"mesh_max": DONOR_MESH_LOD_MAX,
		"shader_max": DONOR_SHADER_LOD_MAX,
		"mesh": {
			"min": 0, "max": DONOR_MESH_LOD_MAX, "per_instance": false,
			"label": "PORT APPROX — donor mesh LOD 0..150 (refobj.actor:46-49); not applied: unit meaning [U], no threshold invented",
		},
		"shader": {
			"min": 0, "max": DONOR_SHADER_LOD_MAX, "per_instance": false,
			"label": "PORT APPROX — donor shader/distance LOD 0..2500 (refobj.actor:93-95); batch-origin only; unit meaning [U]",
		},
		"label": "PORT APPROX — mesh 0..150 and shader 0..2500 are DISTINCT donor controls; both [U] metres",
	}
	st["unverified"] = _unverified.duplicate()
	st["built"] = true
	_built = true
	_stats = st
	return st.duplicate(true)


func stats() -> Dictionary:
	if _stats.is_empty():
		return _fresh_stats("UNBUILT").duplicate(true)
	return _stats.duplicate(true)


func unverified() -> Array[String]:
	return _unverified.duplicate()


func props() -> Array:
	return _props.duplicate(true)


func set_props_visible(p_visible: bool) -> void:
	for key in _batches.keys():
		var holder: MultiMeshInstance3D = _batches[key] as MultiMeshInstance3D
		if holder != null:
			holder.visible = p_visible


# Donor-cited LOD only. The mesh LOD 0..150 and shader/distance LOD 0..2500 are
# DISTINCT controls (refobj.actor:46-49,93-95). Their metre meaning is [U], so
# no per-instance mesh threshold is invented; the batch-level check below is
# the existing PORT APPROX shader/distance rule and stays off by default.
func set_lod_enabled(p_enabled: bool) -> void:
	_lod_enabled = p_enabled
	for key in _batches.keys():
		var holder: MultiMeshInstance3D = _batches[key] as MultiMeshInstance3D
		if holder != null:
			holder.visible = not p_enabled
			holder.set_meta("lod_enabled", p_enabled)
			holder.set_meta("mesh_lod_max", DONOR_MESH_LOD_MAX)
			holder.set_meta("shader_lod_max", DONOR_SHADER_LOD_MAX)
			holder.set_meta("lod_units", "PORT APPROX — donor LOD literals [U] metres; mesh LOD not applied")
	if not _stats.is_empty():
		var lod: Dictionary = _stats.get("lod", {})
		lod["enabled"] = p_enabled
		_stats["lod"] = lod


func update_lod(p_camera: Camera3D) -> void:
	if not _lod_enabled or p_camera == null:
		return
	var eye: Vector3 = p_camera.global_position
	for key in _batches.keys():
		var holder: MultiMeshInstance3D = _batches[key] as MultiMeshInstance3D
		if holder == null:
			continue
		var d: float = eye.distance_to(holder.global_position)
		# Only the shader/distance 0..2500 control is exercised, and only at
		# whole-batch origin. The donor per-object mesh 0..150 is telemetry
		# only until the [U] unit conversion is settled.
		holder.visible = d <= DONOR_SHADER_LOD_MAX
		holder.set_meta("lod_distance", d)
		holder.set_meta("lod_rule", "shader/distance 0..2500 (PORT APPROX, batch origin); mesh 0..150 [U] not applied")


# Mill fields are SCRIPT-SOWN, never a pattern stamp (F07 §1, §4.4). This hook
# computes the donor 49-node lattice deterministically and returns a plan; it
# adds no node, no MultiMesh and no terrain write. Activation stays [U].
func mill_field_hook(p_mill_cell: Vector2) -> Dictionary:
	var size: float = FIELD_STEP_CELLS
	var size2: float = FIELD_SNAP_CELLS
	var ca: float = cos(deg_to_rad(FIELD_ANGLE_DEG))
	var sa: float = sin(deg_to_rad(FIELD_ANGLE_DEG))
	var px: float = floorf((p_mill_cell.x + size) / size2) * size2   # donor unit.script:6497
	var pz: float = floorf((p_mill_cell.y + size * 0.5) / size2) * size2  # donor unit.script:6498
	var nodes: Array[Dictionary] = []
	for i in range(FIELD_NODES):
		var col: int = i % FIELD_ROWS
		var row: int = i / FIELD_ROWS
		var dx: float = -((float(FIELD_ROWS) - 0.5) * size * 0.5) + float(col) * size  # donor unit.script:6491-6493
		var dz: float = -((float(FIELD_ROWS) - 0.5) * size * 0.5) + float(row) * size
		var rx: float = dx * ca - dz * sa                                             # donor unit.script:6494
		var rz: float = dx * sa + dz * ca
		nodes.append({"i": i, "cell": Vector2(px + rx, pz + rz)})
	if not _stats.is_empty():
		var classes: Dictionary = _stats["classes"]
		var cls: Dictionary = classes["mill_fields"]
		cls["hook_calls"] = int(cls.get("hook_calls", 0)) + 1
		cls["planned_nodes"] = FIELD_NODES
		classes["mill_fields"] = cls
		_stats["classes"] = classes
	return {
		"stamped": false,
		"hook_only": true,
		"rows": FIELD_ROWS,
		"nodes": FIELD_NODES,
		"step_cells": FIELD_STEP_CELLS,
		"angle_deg": FIELD_ANGLE_DEG,
		"snap_cells": FIELD_SNAP_CELLS,
		"food_clear_cells": FIELD_FOOD_CLEAR_CELLS,
		"ore_clear_cells": FIELD_ORE_CLEAR_CELLS,
		"cost_gold": FIELD_COST_GOLD,
		"lattice": nodes,
		"label": "PORT APPROX — script-sown mill field, activation [U]; no pattern stamp (F07 §1/§5)",
	}


func asset_inventory() -> Dictionary:
	var blocks: int = 0
	var dir: DirAccess = DirAccess.open(BLOCK_PNG_DIR)
	if dir != null:
		for name in dir.get_files():
			if str(name).ends_with(".png"):
				blocks += 1
	var missing: Array[String] = []
	for path in FIELD_DECALS:
		if not FileAccess.file_exists(path):
			missing.append(path)
	for key in MINE_MESH_PATHS.keys():
		if not FileAccess.file_exists(str(MINE_MESH_PATHS[key])):
			missing.append(str(MINE_MESH_PATHS[key]))
	for path in WAVE_SHEETS:
		if not FileAccess.file_exists(path):
			missing.append(path)
	return {
		"block_pngs": blocks,
		"block_png_expected": 112,                                   # port V07 E08
		"field_obj": FIELD_OBJ,
		"field_decals": FIELD_DECALS.duplicate(),
		"mine_meshes": MINE_MESH_PATHS.duplicate(),
		"wave_sheets": WAVE_SHEETS.duplicate(),
		"feed_props_dir": FEED_PROPS_DIR,
		"feed_props_index": FEED_PROPS_INDEX,
		"feed_lib_index": FEED_LIB_INDEX,
		"feed_family_index": FEED_FAMILY_INDEX,
		"missing": missing,
		"label": "PORT APPROX — path/availability only; no visual parity claim",
	}


func clear() -> void:
	_clear_batches()
	_props.clear()
	_built = false
	_stats = _fresh_stats("CLEARED")


# ---------------------------------------------------------------------------
# Internals
# ---------------------------------------------------------------------------
func _fresh_stats(state: String) -> Dictionary:
	var classes: Dictionary = {}
	for cls in CLASS_PASS_ORDER:
		classes[cls] = {
			"records": 0, "instances": 0, "batches": 0,
			"skipped_unknown_sid": 0, "skipped_missing_mesh": 0,
			"skipped_no_transform": 0, "hook_calls": 0, "planned_nodes": 0,
		}
	return {
		"module": MODULE_ID,
		"state": state,
		"built": false,
		"visual_parity_claim": false,
		"parity": "UNVERIFIED — no donor GPU A/B frame (CHARTER.md:43-44,125)",
		"provenance": {
			"donor_root": "C:\\Games\\Cossacks 3 (READ ONLY; no binary run/copy)",
			"labels": "[O] observed / [D] derived / [I] inferred / [U] UNVERIFIED / PORT APPROXIMATION",
			"no_synthetic_scatter": true,
			"no_noise_field": true,
			"no_rng_draw": true,
			"render_only": true,
			"inputs": "I06 container + I07 ordered stamps + I03 decoded Objects feed (V11 ledger N12)",
		},
		"counts": {
			"stamps_seen": 0, "matched_stamps": 0, "props_total": 0, "batches": 0,
			"skipped_unknown_stamp": 0, "skipped_no_records": 0,
			"skipped_non_dictionary_stamp": 0,
			"skipped_no_transform": 0, "skipped_unknown_sid": 0,
			"skipped_missing_mesh": 0, "skipped_unknown_class": 0,
		},
		"classes": classes,
		"families": {},
		"sids": [],
		"expected_forest_families": EXPECTED_FOREST_FAMILIES.duplicate(),
		"forest_pass_rates": {
			"frs_big": FRS_BIG, "frs_mid": FRS_MID, "frs_small": FRS_SMALL,
			"source": "donor data/scripts/common.inc/dogenerate.inc:1688-1690",
		},
		"stone_pass_rates": {
			"stn1": STN1, "stn2": STN2,
			"source": "donor data/scripts/common.inc/dogenerate.inc:1692-1693",
		},
		"mine_recipe": {
			"ores": MINE_ORES.duplicate(), "stamp_w": MINE_STAMP_W, "stamp_h": MINE_STAMP_H,
			"rings_min": MINE_RING_MIN, "rings_max": MINE_RING_MAX,
			"unit": "MAP CELLS 1:1 — no DONOR_UNITS=160 multiplier (V08 C1)",
			"source": "donor dogenerate.inc:528-551 / generator.cfg:69-153",
		},
		"keep_clear_ellipses_cells": {
			"radii": KEEP_CLEAR_ELLIPSES_CELLS.duplicate(true),
			"source": "donor dogenerate.inc:407-414; V08 C1 — cells, not scaled units",
		},
		"scale_contract": {
			"generator_distance_unit": "1 donor unit = 1 map cell (V08 C1; dogenerate.inc:402-405,521,559-655)",
			"horizontal_metres_per_cell": TILE_M,
			"horizontal_source": "donor dmscript.global:170-173; V08 C2 — visual world placement only",
			"no_donor_units_multiplier": true,
			"no_synthetic_scatter": true,
			"visual_parity_claim": false,
		},
		"mountain_ledger": {
			"records_total": MOUNTAIN_RECORDS_TOTAL,
			"port_stampable_sections": MOUNTAIN_STAMPABLE_SECTIONS,
			"port_stampable_records": MOUNTAIN_STAMPABLE_RECORDS,
			"label": "donor pattern.lib Objects; port V07 E03 / mountain_props.json:2594-2596",
		},
		"shore": {
			"tile_ids": SHORE_TILE_IDS.duplicate(),
			"label": "PORT tile ids 93/97/98 (atlas manifest.json:2284,2380,2404); donor sandsea1/5/6 texturemap.inc:504-608",
		},
		"water": {
			"depth_term": WATER_DEPTH_TERM,
			"classify": WATER_CLASSIFY_H,
			"shore_classify": SHORE_CLASSIFY_H,
			"source": "donor generatemap.inc:567-574 / texturemap.inc:29-31 (I08/I10 own the surface)",
		},
		"forest_border": {
			"lite_prob": FOREST_BORDER_LITE_PROB, "fb_p": FOREST_BORDER_FB_P,
			"fb_radius": FOREST_BORDER_FB_RAD, "foreststype": FOREST_TYPE_CONIFER,
			"source": "donor smoothforestborders.inc:36-148 via X03:1200 / dogenerate.inc:5-6",
		},
		"lod": {
			"enabled": false,
			"mesh_max": DONOR_MESH_LOD_MAX,
			"shader_max": DONOR_SHADER_LOD_MAX,
			"mesh": {
				"min": 0, "max": DONOR_MESH_LOD_MAX, "per_instance": false,
				"label": "PORT APPROX — donor mesh LOD 0..150 (refobj.actor:46-49); NOT applied: unit meaning [U], no threshold invented",
			},
			"shader": {
				"min": 0, "max": DONOR_SHADER_LOD_MAX, "per_instance": false,
				"label": "PORT APPROX — donor shader/distance LOD 0..2500 (refobj.actor:93-95); batch-origin distance only; unit meaning [U]",
			},
			"label": "PORT APPROX; two DISTINCT donor controls 0..150 mesh / 0..2500 shader; both [U] metres",
		},
		"terrainmesh_xform": {
			"records": 0, "donor_records": 0, "legacy_records": 0,
			"patterns_used": [],
			"label": DONOR_TM_LABEL,
		},
		"unverified": [],
	}


func _load_manifest() -> void:
	_known_sids = {}
	_bboxes = {}
	if not FileAccess.file_exists(MODEL_MANIFEST):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(MODEL_MANIFEST))
	if not (parsed is Dictionary) or not (parsed as Dictionary).has("models"):
		return
	var models: Variant = (parsed as Dictionary)["models"]
	if not (models is Array):
		return
	for item in (models as Array):
		if not (item is Dictionary):
			continue
		var md: Dictionary = item
		var sid: String = str(md.get("sid", ""))
		if sid.is_empty():
			continue
		_known_sids[sid] = true
		if md.get("bbox") is Array:
			_bboxes[sid] = (md["bbox"] as Array).duplicate()


func _load_feed(p_stats: Dictionary, p_stamps: Array) -> void:
	_records = {}
	_family_of_pattern = {}
	_feed_source = ""
	_feed_kind = ""
	_fallback_used = false
	_feed_metrics = {
		"files_read": 0,
		"bytes_read": 0,
		"json_parse_calls": 0,
		"json_parse_successes": 0,
		"json_parse_failures": 0,
		"family_bundle_parse_calls": 0,
		"family_bundles_parsed": 0,
		"bundle_paths": [],
		"index_source_bytes": 0,
		"index_record_count": 0,
		"patterns_loaded": 0,
		"records_loaded": 0,
	}
	var accepted_names: Array[String] = _accepted_stamp_names(p_stamps)
	if _try_compact_feed(accepted_names):
		_feed_source = FEED_PROPS_INDEX
		_feed_kind = "compact_preindex"
	else:
		# The compact bundle is an optimization, not a new semantic source. Any
		# absent/invalid compact input falls back to the legacy monolith walker.
		if _try_feed(FEED_LIB_INDEX, p_stats):
			_feed_source = FEED_LIB_INDEX
			_feed_kind = "monolith_fallback"
		elif _try_feed(FEED_FALLBACK, p_stats):
			_feed_source = FEED_FALLBACK
			_feed_kind = "z08_fallback"
			_fallback_used = true
			_unverified.append("TRANSFORM_FALLBACK — I03 feed absent; using Z08 derived table; engine transform PORT APPROX")
	if _feed_source.is_empty():
		_unverified.append("NO_OBJECT_FEED — no I03 feed or Z08 fallback; zero props instanced, none invented")
	var records_loaded: int = 0
	for recs in _records.values():
		if recs is Array:
			records_loaded += (recs as Array).size()
	_feed_metrics["patterns_loaded"] = _records.size()
	_feed_metrics["records_loaded"] = records_loaded


func _accepted_stamp_names(p_stamps: Array) -> Array[String]:
	# Mirror _collect_stamp's current Dictionary/name gate; rejected stamps must
	# never cause a family bundle read.
	var names: Array[String] = []
	var seen: Dictionary = {}
	for raw_stamp in p_stamps:
		if not (raw_stamp is Dictionary):
			continue
		var name: String = _s(raw_stamp as Dictionary, "name",
			_s(raw_stamp as Dictionary, "pattern", _s(raw_stamp as Dictionary, "pattern_name", "")))
		if name.is_empty() or seen.has(name):
			continue
		seen[name] = true
		names.append(name)
	return names


func _read_feed_json(p_path: String) -> Variant:
	var file: FileAccess = FileAccess.open(p_path, FileAccess.READ)
	if file == null:
		return null
	var byte_count: int = file.get_length()
	var text: String = file.get_as_text()
	file.close()
	_feed_metrics["files_read"] = int(_feed_metrics["files_read"]) + 1
	_feed_metrics["bytes_read"] = int(_feed_metrics["bytes_read"]) + byte_count
	_feed_metrics["json_parse_calls"] = int(_feed_metrics["json_parse_calls"]) + 1
	var parsed: Variant = JSON.parse_string(text)
	if parsed == null:
		_feed_metrics["json_parse_failures"] = int(_feed_metrics["json_parse_failures"]) + 1
		return null
	_feed_metrics["json_parse_successes"] = int(_feed_metrics["json_parse_successes"]) + 1
	return parsed


func _compact_bundle_path(p_relative: Variant) -> String:
	if not (p_relative is String):
		return ""
	var relative: String = (p_relative as String).replace("\\", "/")
	if relative.is_empty() or relative.begins_with("/") or relative.begins_with("res:") or relative.contains(".."):
		return ""
	return FEED_PROPS_DIR + "/" + relative


func _try_compact_feed(p_names: Array[String]) -> bool:
	var parsed: Variant = _read_feed_json(FEED_PROPS_INDEX)
	if not (parsed is Dictionary):
		return false
	var root: Dictionary = parsed
	if str(root.get("schema", "")) != FEED_PROPS_SCHEMA:
		return false
	if bool(root.get("visual_parity_claim", true)):
		return false
	var files_v: Variant = root.get("files", null)
	var families_v: Variant = root.get("families", null)
	var section_family_v: Variant = root.get("section_family", null)
	if not (files_v is Dictionary) or not (families_v is Dictionary) or not (section_family_v is Dictionary):
		return false
	var files: Dictionary = files_v
	var family_files: Dictionary = families_v
	var section_family: Dictionary = section_family_v
	_feed_metrics["index_source_bytes"] = int(root.get("source_bytes", 0))
	_feed_metrics["index_record_count"] = int(root.get("record_count", 0))

	# Resolve only accepted stamp names. Multiple stamps in one derived bundle
	# share one parse; no unrelated family file is opened.
	var bundle_names: Dictionary = {}
	var bundle_family: Dictionary = {}
	var loaded_families: Dictionary = {}
	# section_family is the bundle's derived grouping key, not the monolith's
	# authoritative generator_families membership (kept UNVERIFIED in stats).
	for name in p_names:
		if not files.has(name):
			continue
		var bundle_path: String = _compact_bundle_path(files[name])
		var family: String = str(section_family.get(name, ""))
		if bundle_path.is_empty() or family.is_empty():
			return false
		if _compact_bundle_path(family_files.get(family, null)) != bundle_path:
			return false
		loaded_families[name] = family
		bundle_family[bundle_path] = family
		if not bundle_names.has(bundle_path):
			bundle_names[bundle_path] = []
		var names_for_bundle: Array = bundle_names[bundle_path]
		names_for_bundle.append(name)
		bundle_names[bundle_path] = names_for_bundle

	var loaded_records: Dictionary = {}
	for path_v in bundle_names.keys():
		var bundle_path: String = str(path_v)
		_feed_metrics["family_bundle_parse_calls"] = int(_feed_metrics["family_bundle_parse_calls"]) + 1
		var bundle_parsed: Variant = _read_feed_json(bundle_path)
		if not (bundle_parsed is Dictionary):
			return false
		var bundle: Dictionary = bundle_parsed
		if str(bundle.get("family", "")) != str(bundle_family[bundle_path]):
			return false
		var sections_v: Variant = bundle.get("sections", null)
		if not (sections_v is Dictionary):
			return false
		var sections: Dictionary = sections_v
		for name_v in (bundle_names[bundle_path] as Array):
			var name: String = str(name_v)
			if not sections.has(name):
				return false
			var records_v: Variant = sections[name]
			if not (records_v is Array):
				return false
			var normalised: Array[Dictionary] = []
			for raw_v in (records_v as Array):
				if raw_v is Dictionary:
					# Shallow-copy the record but retain every nested vector dict,
					# including Position/Scaling/Up/Direction W components.
					normalised.append(_copy_feed_record(raw_v as Dictionary))
			loaded_records[name] = normalised
		_feed_metrics["family_bundles_parsed"] = int(_feed_metrics["family_bundles_parsed"]) + 1
		var parsed_paths: Array = _feed_metrics["bundle_paths"]
		if not parsed_paths.has(bundle_path):
			parsed_paths.append(bundle_path)
		_feed_metrics["bundle_paths"] = parsed_paths
	_records = loaded_records
	_family_of_pattern = loaded_families
	return true


func _copy_feed_record(p_raw: Dictionary) -> Dictionary:
	var rec: Dictionary = p_raw.duplicate(false)
	rec["BaseName"] = _record_base_name(rec)
	return rec


func _try_feed(p_path: String, p_stats: Dictionary) -> bool:
	var parsed: Variant = _read_feed_json(p_path)
	if not (parsed is Dictionary):
		return false
	var root: Dictionary = parsed
	var source_map: Dictionary = {}

	# Family index (I03 G3) supplies pattern -> family membership when present.
	var fams: Variant = root.get("families", null)
	if fams is Dictionary:
		for fam in (fams as Dictionary).keys():
			var members: Variant = (fams as Dictionary)[fam]
			if members is Array:
				for m in (members as Array):
					_family_of_pattern[str(m)] = str(fam)
	# I03 canonical index uses generator_families: [{family, patterns:[{pattern,...}]}]
	# (decode_pattern_lib.py:770-777, :816). V66-F1: without this branch the feed is
	# accepted but keyed wrong -> zero props with a false "DONOR LITERALS" label.
	var gen_fams: Variant = root.get("generator_families", null)
	if gen_fams is Array:
		for gf in (gen_fams as Array):
			if not (gf is Dictionary):
				continue
			var fname: String = str((gf as Dictionary).get("family", ""))
			var pats: Variant = (gf as Dictionary).get("patterns", null)
			if pats is Array:
				for pd in (pats as Array):
					if pd is Dictionary:
						var pname: String = str((pd as Dictionary).get("pattern", ""))
						if not pname.is_empty():
							_family_of_pattern[pname] = fname

	var found: int = 0

	# I03 canonical shape: pattern_lib.sections[].blocks[].records[]. Only
	# Objects blocks carry prop transforms; family/grid metadata is not a record.
	# Key by the parsed section.name because blocks may precede name in the JSON.
	var pattern_lib: Variant = root.get("pattern_lib", null)
	if pattern_lib is Dictionary:
		var sections_v: Variant = (pattern_lib as Dictionary).get("sections", [])
		if sections_v is Array:
			for section_v in (sections_v as Array):
				if not (section_v is Dictionary):
					continue
				var section: Dictionary = section_v as Dictionary
				var pattern_name: String = str(section.get("name", "")).strip_edges()
				if pattern_name.is_empty():
					continue
				var blocks_v: Variant = section.get("blocks", [])
				if not (blocks_v is Array):
					continue
				for block_v in (blocks_v as Array):
					if not (block_v is Dictionary):
						continue
					var block: Dictionary = block_v as Dictionary
					if str(block.get("block", "")) != "Objects":
						continue
					var records_v: Variant = block.get("records", [])
					if not (records_v is Array):
						continue
					var normalised: Array[Dictionary] = []
					for raw_v in (records_v as Array):
						if not (raw_v is Dictionary):
							continue
						var rec: Dictionary = _copy_feed_record(raw_v as Dictionary)
						normalised.append(rec)
					if not normalised.is_empty():
						var dst: Array = _records.get(pattern_name, [])
						dst.append_array(normalised)
						_records[pattern_name] = dst
						found += normalised.size()

	# Z08-style `props` map is preferred; other I03 shapes are accepted too.
	# Never treat generator_families metadata as Objects records.
	if found == 0:
		for key in ["props", "objects", "Objects", "records", "by_pattern"]:
			var v: Variant = root.get(key, null)
			if v is Dictionary:
				source_map = v as Dictionary
				break
		if source_map.is_empty():
			for key in root.keys():
				if key in ["version", "source", "source_sha256", "selection", "labels",
						"derived_stats", "families", "fields", "stats", "family_index",
						"pattern_index", "note", "donor_units", "generator_families"]:
					continue
				if root[key] is Array:
					source_map[str(key)] = true

	if not source_map.is_empty():
		for name in source_map.keys():
			var arr: Variant = source_map[name]
			var recs: Array[Dictionary] = []
			if arr is Array:
				for raw in (arr as Array):
					if raw is Dictionary and not (raw as Dictionary).is_empty():
						recs.append(_copy_feed_record(raw as Dictionary))
			elif arr == true:
				# Top-level keyed-by-pattern shape: records live under the key.
				var nested: Variant = root.get(str(name), null)
				if nested is Array:
					for raw in (nested as Array):
						if raw is Dictionary:
							recs.append(_copy_feed_record(raw as Dictionary))
			if not recs.is_empty():
				_records[str(name)] = recs
				found += recs.size()
	if found == 0:
		var fc: Dictionary = p_stats["counts"]
		fc["skipped_no_records"] = int(fc["skipped_no_records"]) + 1
		p_stats["counts"] = fc
		return false
	return true


func _collect_stamp(p_raw, p_out: Array[Dictionary], p_stats: Dictionary) -> void:
	if not (p_raw is Dictionary):
		var c0: Dictionary = p_stats["counts"]
		c0["skipped_non_dictionary_stamp"] = int(c0.get("skipped_non_dictionary_stamp", 0)) + 1
		p_stats["counts"] = c0
		return
	var counts: Dictionary = p_stats["counts"]
	var name: String = _s(p_raw, "name", _s(p_raw, "pattern", _s(p_raw, "pattern_name", "")))
	if name.is_empty():
		counts["skipped_unknown_stamp"] = int(counts["skipped_unknown_stamp"]) + 1
		p_stats["counts"] = counts
		return
	var cell: Vector2i = _stamp_cell(p_raw)
	var recs: Variant = _records.get(name, null)
	if not (recs is Array) or (recs as Array).is_empty():
		counts["skipped_no_records"] = int(counts["skipped_no_records"]) + 1
		p_stats["counts"] = counts
		return
	counts["matched_stamps"] = int(counts["matched_stamps"]) + 1
	p_stats["counts"] = counts

	for raw in (recs as Array):
		if not (raw is Dictionary):
			continue
		var rec: Dictionary = _normalize_record(raw as Dictionary, name, p_stats)
		if rec.is_empty():
			continue
		# DEC-VIS-02 §6: only converted terrainmesh1..4 records take the donor-
		# derived transform. Every other prop class keeps the legacy path below
		# byte-for-byte (no RNG, no sorting, no synthetic transform).
		if RELIEF_SIDS.has(str(rec["sid"])) and not _donor_tm_params(name).is_empty():
			_place_terrainmesh_record(rec, name, cell, p_stats)
		else:
			if RELIEF_SIDS.has(str(rec["sid"])):
				_append_unverified_once("TERRAINMESH_PATTERN_DIMS_UNVERIFIED pattern=" + name
					+ " — no donor Width/Height literal; legacy PORT APPROX placement kept")
				_tm_count(p_stats, "records", 1)
				_tm_count(p_stats, "legacy_records", 1)
			var cls: String = str(rec["class"])
			var dim: Vector2i = _grid_dim()
			# V08 C1: donor Position/footprints are MAP CELLS 1:1 — no W/160, no x2.
			# Integer sampling of a fractional donor cell is PORT APPROX only.
			var dx: int = int(roundf(float(rec["px"])))
			var dz: int = int(roundf(float(rec["pz"])))
			var pc: Vector2i = Vector2i(cell.x + dx, cell.y + dz)
			var wx: float = (float(pc.x) + 0.5 - float(dim.x) * 0.5) * TILE_M
			var wz: float = (float(pc.y) + 0.5 - float(dim.y) * 0.5) * TILE_M
			var wy: float = _ground_y(wx, wz, pc)
			rec["world_pos"] = Vector3(wx, wy, wz)
			rec["stamp_cell"] = cell
			rec["prop_cell"] = pc
			rec["order"] = p_out.size()
		p_out.append(rec)


func _normalize_record(p_raw: Dictionary, p_stamp: String, p_stats: Dictionary) -> Dictionary:
	var counts: Dictionary = p_stats["counts"]
	var classes: Dictionary = p_stats["classes"]
	var families: Dictionary = p_stats["families"]
	var base: String = _record_base_name(p_raw)
	var pos: Vector3 = _vec3(p_raw.get("Position", p_raw.get("position", null)))
	if not _finite3(pos):
		pos = Vector3(float(p_raw.get("px", NAN)), float(p_raw.get("py", 0.0)), float(p_raw.get("pz", NAN)))
	var scale: Vector3 = _vec3(p_raw.get("Scaling", p_raw.get("scaling", null)))
	if not _finite3(scale):
		scale = Vector3(float(p_raw.get("sx", NAN)), float(p_raw.get("sy", NAN)), float(p_raw.get("sz", NAN)))
	var up: Vector3 = _vec3(p_raw.get("Up", p_raw.get("up", null)))
	if not _finite3(up):
		up = Vector3(float(p_raw.get("ux", NAN)), float(p_raw.get("uy", NAN)), float(p_raw.get("uz", NAN)))
	var yaw_v: Variant = p_raw.get("yaw_deg", null)
	var yaw: float = float(yaw_v) if yaw_v != null and _is_finite(float(yaw_v)) else (
		rad_to_deg(atan2(-up.z, up.x)) if _finite3(up) else NAN)

	if not _finite3(pos) or not _finite3(scale) or not _is_finite(yaw):
		counts["skipped_no_transform"] = int(counts["skipped_no_transform"]) + 1
		p_stats["counts"] = counts
		return {}

	var sid: String = _sid_for_base(base)
	if sid.is_empty():
		counts["skipped_unknown_sid"] = int(counts["skipped_unknown_sid"]) + 1
		p_stats["counts"] = counts
		var cls_a: String = _class_for(p_stamp, base)
		var ca: Dictionary = classes.get(cls_a, {})
		ca["skipped_unknown_sid"] = int(ca.get("skipped_unknown_sid", 0)) + 1
		classes[cls_a] = ca
		p_stats["classes"] = classes
		return {}
	if not ResourceLoader.exists(AssetPaths.existing(sid, "obj")):
		counts["skipped_missing_mesh"] = int(counts["skipped_missing_mesh"]) + 1
		p_stats["counts"] = counts
		var cls_b: String = _class_for(p_stamp, base)
		var cb: Dictionary = classes.get(cls_b, {})
		cb["skipped_missing_mesh"] = int(cb.get("skipped_missing_mesh", 0)) + 1
		classes[cls_b] = cb
		p_stats["classes"] = classes
		return {}

	var cls: String = _class_for(p_stamp, base)
	if cls == "other":
		counts["skipped_unknown_class"] = int(counts["skipped_unknown_class"]) + 1
		p_stats["counts"] = counts
		_unverified.append("UNKNOWN_CLASS pattern=%s base=%s — no class assigned, not instanced" % [p_stamp, base])
		return {}
	var family: String = str(_family_of_pattern.get(p_stamp, ""))
	if family.is_empty():
		family = "UNVERIFIED:" + cls

	var ce: Dictionary = classes.get(cls, {})
	ce["records"] = int(ce.get("records", 0)) + 1
	classes[cls] = ce
	p_stats["classes"] = classes
	var fe: Dictionary = families.get(family, {"records": 0, "instances": 0, "sids": []})
	fe["records"] = int(fe.get("records", 0)) + 1
	families[family] = fe
	p_stats["families"] = families

	return {
		"base": base,
		"sid": sid,
		"stamp_name": p_stamp,
		"class": cls,
		"family": family,
		"px": pos.x,
		"py": pos.y,
		"pz": pos.z,
		"yaw_deg": yaw,
		"scale": scale.x,                 # legacy classes keep the uniform x-only collapse
		"full_scale": scale,              # DEC-VIS-02 §9.1 item 4: preserve all XYZ for the donor terrainmesh path
		"position": pos,                  # raw float Position, never pre-rounded in the donor path
		"direction": _vec3(p_raw.get("Direction", p_raw.get("direction", null))),
		"up": up,
		"donor_line": int(p_raw.get("line", p_raw.get("donor_line", -1))),
		"transform_source": "DONOR LITERAL (Objects[])" if not _fallback_used else "PORT APPROX FALLBACK (Z08 table)",
	}


func _add_to_batch(p_rec: Dictionary, p_stats: Dictionary) -> void:
	var sid: String = str(p_rec["sid"])
	var cls: String = str(p_rec["class"])
	var family: String = str(p_rec["family"])
	var key: String = cls + "|" + family + "|" + sid
	if not _batches.has(key):
		var path: String = AssetPaths.existing(sid, "obj")
		if not ResourceLoader.exists(path):
			return
		var res: Resource = load(path) as Resource
		if not (res is Mesh):
			return
		var mm := MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		mm.mesh = res as Mesh
		var holder := MultiMeshInstance3D.new()
		holder.name = "DonorProps_" + sid
		holder.multimesh = mm
		# Converted donor OBJs declare mtllib but no usemtl (for example
		# terrainmesh1.obj:2-3); their MTL map_Kd is therefore not a reliable
		# imported surface binding. Bind the manifest/AssetPaths albedo only
		# when the imported mesh has no usable material. Donor UVs stay intact.
		# The broad square footprint is triangulated donor relief geometry, not
		# an editor grid (terrainmesh3.obj:4,6-8,8004-8005,8650-8656); keep it.
		if sid == "field":
			# field.obj is the converted field1.osm cut-out: it names field.mtl,
			# but has no usemtl (and no vertex normals). Force its explicit
			# AssetPaths field.png binding instead of trusting an importer
			# default/opaque surface. envfieldd is the separate lit, alpha-
			# blended ground decal (decals.mat:17,110-115), not crop albedo.
			_bind_donor_albedo(holder, sid)
			var field_material := holder.material_override as StandardMaterial3D
			if field_material != null:
				# Donor crop materials are emissive (env.mat:58-69). The tint is
				# donor-grounded; 0.22 remains the existing PORT APPROX energy.
				field_material.emission_enabled = true
				field_material.emission = Color(232.0 / 255.0, 218.0 / 255.0, 195.0 / 255.0)
				field_material.emission_energy_multiplier = 0.22
				holder.set_meta("material_binding",
					"PORT APPROXIMATION — donor field1 crop albedo + alpha scissor + emissive lift; parity UNVERIFIED")
		elif not _mesh_has_usable_material(res as Mesh):
			_bind_donor_albedo(holder, sid)
		holder.add_to_group(GROUP)
		holder.set_meta("terrain_sid", sid)
		holder.set_meta("prop_class", cls)
		holder.set_meta("family", family)
		holder.set_meta("placement_source", str(p_rec["transform_source"]))
		if p_rec.has("donor_placement"):
			holder.set_meta("terrainmesh_placement", str((p_rec["donor_placement"] as Dictionary).get("label", "")))
		holder.set_meta("scale_authored", true)
		holder.set_meta("selection_rule", "PORT APPROX — all donor records instantiated (Z06 §1/§7 Q1)")
		holder.set_meta("instance_count", 0)
		add_child(holder)
		_batches[key] = holder

	var holder2: MultiMeshInstance3D = _batches[key] as MultiMeshInstance3D
	var mm2: MultiMesh = holder2.multimesh
	var idx: int = int(holder2.get_meta("instance_count", 0))
	mm2.instance_count = idx + 1
	holder2.set_meta("instance_count", idx + 1)

	if p_rec.has("donor_placement"):
		# DEC-VIS-02 §4/§9.1 item 5: refobj.actor macCenter*=false and
		# macUseBarycenter=false — keep the OSM origin and the square base. No
		# bbox recentering and no uniform scale collapse. The donor basis is
		# Direction / Up / cross + Scaling*ObjectsScale, then the separate final
		# turn, all converted from donor Z-up to Godot Y-up.
		var donor_basis: Basis = _donor_tm_basis(p_rec)
		var donor_origin: Vector3 = p_rec["world_pos"]   # instance origin == donor object position
		mm2.set_instance_transform(idx, Transform3D(donor_basis, donor_origin))
	else:
		var bb: Array = _bboxes.get(sid, [])
		if bb.size() < 6:
			bb = [0.0, 0.0, 0.0, 0.0, 0.0, 1.0]
		var cx: float = (float(bb[0]) + float(bb[1])) * 0.5
		var cy: float = (float(bb[2]) + float(bb[3])) * 0.5
		var z0: float = float(bb[4])
		var base_basis: Basis = Basis().rotated(Vector3(1.0, 0.0, 0.0), -PI * 0.5)  # donor Z-up -> Y-up, PORT APPROX
		var basis: Basis = Basis().rotated(Vector3(0.0, 1.0, 0.0), deg_to_rad(float(p_rec["yaw_deg"]))) * base_basis
		var sc: float = float(p_rec["scale"])
		basis = basis.scaled(Vector3(sc, sc, sc))
		var origin: Vector3 = (p_rec["world_pos"] as Vector3) + basis * Vector3(-cx, -cy, -z0)
		mm2.set_instance_transform(idx, Transform3D(basis, origin))

	var classes: Dictionary = p_stats["classes"]
	var families: Dictionary = p_stats["families"]
	var ce: Dictionary = classes.get(cls, {})
	ce["instances"] = int(ce.get("instances", 0)) + 1
	ce["batches"] = len(_batch_classes(cls))
	classes[cls] = ce
	p_stats["classes"] = classes
	var fe: Dictionary = families.get(family, {"records": 0, "instances": 0, "sids": []})
	fe["instances"] = int(fe.get("instances", 0)) + 1
	var sids: Array = fe.get("sids", [])
	if not sids.has(sid):
		sids.append(sid)
	fe["sids"] = sids
	families[family] = fe
	p_stats["families"] = families


func _mesh_has_usable_material(p_mesh: Mesh) -> bool:
	if p_mesh == null:
		return false
	for surface in range(p_mesh.get_surface_count()):
		var surface_material: Material = p_mesh.surface_get_material(surface)
		if surface_material == null:
			continue
		# Preserve imported shader materials and any non-BaseMaterial3D
		# material rather than replacing an intentional donor binding.
		if surface_material is ShaderMaterial:
			return true
		if surface_material is BaseMaterial3D:
			var base_material := surface_material as BaseMaterial3D
			# The converted MTL carries Kd/map_Kd only. A textured but opaque
			# or back-culled import still lacks the donor refbase alpha/cull state.
			if (base_material.albedo_texture != null
					and base_material.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
					and is_equal_approx(base_material.alpha_scissor_threshold, 0.5)
					and base_material.cull_mode == BaseMaterial3D.CULL_DISABLED):
				return true
			continue
		return true
	return false


func _bind_donor_albedo(p_holder: MultiMeshInstance3D, p_sid: String) -> void:
	var texture_path: String = AssetPaths.existing(p_sid, "tex")
	var texture: Texture2D = null
	if ResourceLoader.exists(texture_path):
		texture = load(texture_path) as Texture2D
	var mat := StandardMaterial3D.new()
	mat.roughness = 1.0
	mat.metallic = 0.0
	# Match the donor-prop entity fallback: keep imported winding visible and
	# remain lit so the scene's donor light rig, not an unshaded tint, drives it.
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	if texture != null:
		mat.albedo_texture = texture
		p_holder.set_meta("material_binding",
			"PORT APPROXIMATION — donor albedo " + texture_path)
	else:
		# Only reached if a manifest/legacy donor albedo is absent. This is a
		# labelled neutral PORT fallback, never a bright-white invented material.
		mat.albedo_color = Color(0.2, 0.2, 0.2)
		p_holder.set_meta("material_binding",
			"PORT APPROXIMATION — neutral untextured fallback; donor albedo unavailable "
			+ texture_path)
	# Donor refbase.mat:17 uses bmAlphaTest50 and :18 uses fcNoCull for
	# these converted env props. The 0.5 cut-out also prevents fully
	# transparent white RGB texels in the relief RGBA from painting a tile.
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	mat.alpha_scissor_threshold = 0.5
	p_holder.material_override = mat


func _batch_classes(p_cls: String) -> Array[String]:
	var out: Array[String] = []
	for key in _batches.keys():
		if str(key).begins_with(p_cls + "|"):
			out.append(str(key))
	return out


func _sid_for_base(p_base: String) -> String:
	var b: String = p_base.strip_edges()
	if b.is_empty():
		return ""
	# Mesh/material variant suffix `.1..4` is a variant selector (F08 §3.5),
	# engine-side binding [U]; strip it and collapse to the converted OBJ.
	var dot: int = b.find(".")
	if dot > 0:
		b = b.substr(0, dot)
	if RELIEF_SIDS.has(b):
		return b
	match b:
		"minegold": return "mine_gold"
		"mineiron": return "mine_iron"
		"minecoal": return "mine_coal"
		"minegolds", "mineirons", "minecoals":
			_unverified.append("DESERT_ORE_PROP " + b + " — not converted (F08 R7)")
			return ""
		"field": return "field"
		"pump", "pump1", "pump2", "pump3":
			_unverified.append("PUMP_PROP " + b + " — pump family not converted (F07 §3.4)")
			return ""
		"bushes", "drybushes": return _has_sid("bush1")
		"plantain": return _has_sid("plantain1")
		"christmastree": return _has_sid("christmastree")
		"christmas": return _has_sid("christmastree")
		"stones": return _has_sid("stone")
		"rock": return _has_sid("rock")
	if (b.begins_with("gift") or b.begins_with("reed") or b.begins_with("fern")
			or b.begins_with("flower") or b.begins_with("plantain")):
		return _has_sid(b)
	if b.begins_with("christmastree"):
		return _has_sid(b)
	if b.begins_with("tree_"):
		return _has_sid(b)

	var digits: String = ""
	for c in b:
		if c >= "0" and c <= "9":
			digits += c
	var stem: String = b
	for c in digits:
		stem = stem.replace(str(c), "")
	stem = stem.trim_suffix("s")

	# Forest props: port OBJ sids are `tree_<donor base>` (F08 §6 R5).
	var tree_sid: String = "tree_" + b
	if _known_sids.has(tree_sid):
		return tree_sid
	if (b.begins_with("pine") or b.begins_with("fir") or b.begins_with("spruce")
			or b.begins_with("oak") or b.begins_with("pinedry") or b.begins_with("leaftree")
			or b.begins_with("drytree")):
		if _known_sids.has("tree_" + stem):
			return "tree_" + stem
		if _known_sids.has("tree_" + stem + "1"):
			return "tree_" + stem + "1"
		_unverified.append("TREE_SID_UNRESOLVED " + b + " — no converted mesh; skipped")
		return ""

	# Stone / shore props (F08 §3.2, E10/E17).
	if b.begins_with("smallstonessea"):
		return _clamped_sid("rock_smallstonesea", digits, 6)
	if b.begins_with("stonessea"):
		return _clamped_sid("rock_stonessea", digits, 10)
	if b.begins_with("rocksea"):
		return _clamped_sid("rock_sea", digits, 6)
	if b.begins_with("smallstones"):
		return _clamped_sid("rock_smallstones", digits, 6)
	if b.begins_with("stones"):
		if digits.is_empty():
			return _has_sid("stone")
		return _clamped_sid("rock_stones", digits, 10)

	# Understory weeds have converted PNG/OBJ for bush/fern/reed/plantain/flower
	# only; grass.* / horseradish / plant have no converted prop mesh.
	_unverified.append("BASE_UNRESOLVED " + b + " — no converted sid; skipped (no mesh fabricated)")
	return ""


func _has_sid(p_sid: String) -> String:
	return p_sid if _known_sids.has(p_sid) else ""


func _clamped_sid(p_prefix: String, p_digits: String, p_max: int) -> String:
	var n: int = 1 if p_digits.is_empty() else clampi(int(p_digits), 1, p_max)
	return _has_sid(p_prefix + str(n))


func _class_for(p_stamp: String, p_base: String) -> String:
	var n: String = p_stamp.to_lower()
	var b: String = p_base.to_lower()
	if (n.begins_with("g_mnt") or n.begins_with("i_mnt") or n.begins_with("desert_mnt")
			or b.begins_with("terrainmesh")):
		return "hills_mountains"
	if (n.begins_with("mng") or n.begins_with("mni") or n.begins_with("mnc")
			or b.begins_with("mine")):
		return "mines"
	if (n.begins_with("k_rock") or b.begins_with("rocksea")
			or b.begins_with("stonessea") or b.begins_with("smallstonessea")):
		return "shore"
	if n.contains("swamp") or n.contains("lake"):
		return "swamps_lakes"
	if (n.begins_with("d_stn") or n.begins_with("str_new") or n.begins_with("desert_stn")
			or n.begins_with("stoneforests") or n.begins_with("stones")):
		return "stone_quarries"
	if n.contains("field") or n.contains("mil") or b == "field":
		return "mill_fields"
	if (n.begins_with("dcr") or n.begins_with("d_tls") or n.begins_with("big_hill")
			or b.begins_with("fern") or b.begins_with("reed") or b.begins_with("flower")
			or b.begins_with("gift") or b.begins_with("christmas")):
		return "decor"
	if (n.contains("frt") or b.contains("pine") or b.contains("fir") or b.contains("spruce")
			or b.contains("oak") or b.contains("palm") or b.contains("plantain") or b.contains("bush")):
		return "forests"
	return "other"


func _grid_dim() -> Vector2i:
	if _container == null:
		return Vector2i(0, 0)
	var wv: Variant = _container.get("w")
	var hv: Variant = _container.get("h")
	if wv == null or hv == null:
		return Vector2i(0, 0)
	return Vector2i(int(wv), int(hv))


func _ground_y(p_wx: float, p_wz: float, p_cell: Vector2i) -> float:
	if _terrain != null and _terrain.has_method("height_at_world"):
		return float(_terrain.call("height_at_world", Vector2(p_wx, p_wz)))
	if _container != null:
		var hv: Variant = _container.get("height")
		if hv is PackedFloat32Array:
			var arr: PackedFloat32Array = hv
			var dim: Vector2i = _grid_dim()
			if (dim.x > 0 and dim.y > 0 and p_cell.x >= 0 and p_cell.y >= 0
					and p_cell.x < dim.x and p_cell.y < dim.y):
				var i: int = p_cell.y * dim.x + p_cell.x   # I06 idx(), terrain_donor_data.gd:244-245
				if i < arr.size():
					return arr[i]
	return 0.0


func _stamp_cell(p_src) -> Vector2i:
	var pos: Variant = _g(p_src, "pos", null)
	if pos is Vector2:
		return Vector2i(pos as Vector2)
	if pos is Vector2i:
		return pos as Vector2i
	if pos is Array and (pos as Array).size() >= 2:
		return Vector2i(int((pos as Array)[0]), int((pos as Array)[1]))
	var cx: Variant = _g(p_src, "x", _g(p_src, "cx", _g(p_src, "px", 0)))
	var cy: Variant = _g(p_src, "y", _g(p_src, "cy", _g(p_src, "py", 0)))
	return Vector2i(int(cx), int(cy))


# --- DEC-VIS-02 §6 donor-order terrainmesh placement (terrainmesh1..4 only) ---

func _append_unverified_once(p_text: String) -> void:
	if not _unverified.has(p_text):
		_unverified.append(p_text)


func _tm_count(p_stats: Dictionary, p_key: String, p_delta: int) -> void:
	if not p_stats.has("terrainmesh_xform"):
		return
	var tm: Dictionary = p_stats["terrainmesh_xform"]
	tm[p_key] = int(tm.get(p_key, 0)) + p_delta
	p_stats["terrainmesh_xform"] = tm


func _donor_tm_params(p_pattern: String) -> Dictionary:
	if not DONOR_TM_PATTERN_DIMS.has(p_pattern):
		return {}
	var dims: Vector2i = DONOR_TM_PATTERN_DIMS[p_pattern]
	return {
		"w": dims.x, "h": dims.y,
		"objects_scale": DONOR_TM_OBJECTS_SCALE,
		"offset_x": DONOR_TM_OFFSET_X, "offset_z": DONOR_TM_OFFSET_Z,
		"rotangle": DONOR_TM_ROTANGLE,
		"height_scale": DONOR_TM_HEIGHT_SCALE,
		"objects_offset": DONOR_TM_OBJECTS_OFFSET,
		"height_offset": DONOR_TM_HEIGHT_OFFSET,
		"auto_offset": DONOR_TM_AUTO_OFFSET,
		"ignore_matrix": DONOR_TM_IGNORE_MATRIX,
	}


# DEC-VIS-02 §6.1: sub_4a3c7c / sub_4a3b9c out-of-place donor Y rotation.
func _donor_rotate_y(p_v: Vector3, p_angle: float) -> Vector3:
	var sa: float = sin(p_angle)
	var ca: float = cos(p_angle)
	return Vector3(sa * p_v.x + ca * p_v.z, p_v.y, sa * p_v.z - ca * p_v.x)


# DEC-VIS-02 §6.2: pattern-size-rounded half-cell centre, including nested
# Round, the +0.5 cell and the PI - rotangle correction. No term is omitted.
func _donor_base_centre(p_w: int, p_h: int, p_cx: float, p_cz: float, p_rotangle: float) -> Vector2:
	var r0: float = roundf((float(p_w) - 1.0) * 0.5 - p_cx)
	var r1: float = roundf((float(p_h) - 1.0) * 0.5 - p_cz)
	var x1: float = float(p_w) + r0 - 1.0
	var z1: float = float(p_h) + r1 - 1.0
	var mx: float = roundf((x1 + r0) * 0.5) + 0.5
	var mz: float = roundf((z1 + r1) * 0.5) + 0.5
	var dx: float = (x1 + r0) * 0.5 - mx
	var dz: float = (z1 + r1) * 0.5 - mz
	var rotated: Vector3 = _donor_rotate_y(Vector3(dx, 0.0, dz), PI - p_rotangle)
	return Vector2(rotated.x + mx, rotated.z + mz)


# DEC-VIS-02 §6.3, object block 0x75b66d..0x75b733: rotate raw float XZ by
# PI - rotangle, multiply by ObjectsScale, add raw or pattern-rounded centre;
# Y stays zero unless ObjectsHeightOffset; terrain snap only with ObjAutoOffset.
func _place_terrainmesh_record(p_rec: Dictionary, p_pattern: String,
		p_cell: Vector2i, p_stats: Dictionary) -> void:
	var par: Dictionary = _donor_tm_params(p_pattern)
	if par.is_empty():
		return
	var pos: Vector3 = p_rec["position"]       # raw float Position; never pre-rounded
	var objects_scale: float = float(par["objects_scale"])
	var rotangle: float = float(par["rotangle"])
	var local: Vector3 = _donor_rotate_y(Vector3(pos.x, 0.0, pos.z), PI - rotangle)
	local *= objects_scale

	var raw_x: float = float(p_cell.x) + float(par["offset_x"])
	var raw_z: float = float(p_cell.y) + float(par["offset_z"])
	var use_raw: bool = bool(par["objects_offset"])
	var centre: Vector2
	if use_raw:
		centre = Vector2(raw_x, raw_z)
	else:
		centre = _donor_base_centre(int(par["w"]), int(par["h"]), raw_x, raw_z, rotangle)
	var pos2: Vector2 = centre + Vector2(local.x, local.z)

	# [U] Half-cell convention: the donor centre already carries +0.5 for the
	# pattern-rounded branch; therefore the port cell->world conversion here
	# does NOT add another 0.5. This is a labelled PORT APPROX mapping, not a
	# new donor threshold.
	var dim: Vector2i = _grid_dim()
	var wx: float = (pos2.x - float(dim.x) * 0.5) * TILE_M
	var wz: float = (pos2.y - float(dim.y) * 0.5) * TILE_M

	var wy: float = 0.0
	if bool(par["height_offset"]):
		wy = pos.y * objects_scale * float(par["height_scale"])
	if bool(par["auto_offset"]):
		wy += _ground_y(wx, wz, p_cell)

	p_rec["world_pos"] = Vector3(wx, wy, wz)
	p_rec["stamp_cell"] = p_cell
	p_rec["prop_cell"] = Vector2i(int(roundf(pos2.x)), int(roundf(pos2.y)))
	p_rec["order"] = int(p_rec.get("order", 0))
	p_rec["donor_placement"] = {
		"pattern": p_pattern,
		"label": DONOR_TM_LABEL,
		"objects_scale": objects_scale,
		"rotangle_rad": rotangle,
		"width": int(par["w"]), "height": int(par["h"]),
		"offset_x": float(par["offset_x"]), "offset_z": float(par["offset_z"]),
		"centre_branch": "ObjectsOffset raw" if use_raw else "pattern-size-rounded half-cell",
		"height_offset": bool(par["height_offset"]),
		"auto_offset": bool(par["auto_offset"]),
		"ignore_matrix": bool(par["ignore_matrix"]),
		"height_scale": float(par["height_scale"]),
	}
	_tm_count(p_stats, "records", 1)
	_tm_count(p_stats, "donor_records", 1)
	var tm: Dictionary = p_stats["terrainmesh_xform"]
	var pats: Array = tm.get("patterns_used", [])
	if not pats.has(p_pattern):
		pats.append(p_pattern)
		tm["patterns_used"] = pats
		p_stats["terrainmesh_xform"] = tm


# DEC-VIS-02 §6.3 final matrix block 0x75bd08..0x75bddf: install Direction,
# Up and Scaling*ObjectsScale, then the separate donor final turn. The turn
# helper (sub_7cca74 -> sub_4cb27c -> sub_4a64e4) multiplies its argument by
# PI/180 before rotating the basis; that unit discontinuity is preserved, not
# silently corrected. Its axis is [U]; rotangle=0 makes the turn identity here.
func _donor_tm_basis(p_rec: Dictionary) -> Basis:
	var dp: Dictionary = p_rec["donor_placement"]
	var to_godot: Basis = Basis().rotated(Vector3(1.0, 0.0, 0.0), -PI * 0.5)  # donor Z-up -> Godot Y-up, PORT APPROX
	var scl: Vector3 = p_rec["full_scale"] * float(dp["objects_scale"])
	if bool(dp["ignore_matrix"]):
		return to_godot * Basis().scaled(scl)

	var direction: Vector3 = p_rec["direction"]
	var up: Vector3 = p_rec["up"]
	if not _finite3(direction) or not _finite3(up) or direction.length_squared() < 0.000001 or up.length_squared() < 0.000001:
		return to_godot * Basis().scaled(scl)
	var fwd: Vector3 = direction.normalized()
	var upd: Vector3 = up.normalized()
	var third: Vector3 = fwd.cross(upd)
	if third.length_squared() < 0.000001:
		return to_godot * Basis().scaled(scl)
	var orient: Basis = Basis(fwd, upd, third.normalized())
	orient = orient * Basis().scaled(scl)
	var turn: Basis = Basis().rotated(Vector3(0.0, 0.0, 1.0), float(dp["rotangle_rad"]) * PI / 180.0)
	return to_godot * (turn * orient)


func _g(p_src, p_key: String, p_fallback):
	if p_src is Dictionary:
		return (p_src as Dictionary).get(p_key, p_fallback)
	if p_src is Object:
		var v: Variant = (p_src as Object).get(p_key)
		return p_fallback if v == null else v
	return p_fallback


func _record_base_name(p_raw: Dictionary) -> String:
	for key in ["base", "BaseName", "base_name"]:
		var value: Variant = p_raw.get(key, null)
		if value is Dictionary:
			value = (value as Dictionary).get("value", "")
		if value == null:
			continue
		var text: String = str(value).strip_edges()
		if not text.is_empty():
			return text
	return ""


func _s(p_src: Dictionary, p_key: String, p_fallback: String) -> String:
	var v: Variant = p_src.get(p_key, null)
	if v == null:
		return p_fallback
	var s: String = str(v).strip_edges()
	return s if not s.is_empty() else p_fallback


func _vec3(p_src: Variant) -> Vector3:
	if p_src is Vector3:
		return p_src as Vector3
	if p_src is Array and (p_src as Array).size() >= 3:
		var a: Array = p_src as Array
		return Vector3(_to_f(a[0]), _to_f(a[1]), _to_f(a[2]))
	if p_src is Dictionary:
		var d: Dictionary = p_src as Dictionary
		return Vector3(_to_f(d.get("x", d.get("X", NAN))),
				_to_f(d.get("y", d.get("Y", NAN))),
				_to_f(d.get("z", d.get("Z", NAN))))
	if p_src is String:
		var cleaned: String = (p_src as String).replace("(", " ").replace(")", " ")
		cleaned = cleaned.replace(",", " ").replace(";", " ")
		var parts: PackedStringArray = cleaned.split(" ", false)
		var vals: Array[float] = []
		for token in parts:
			if str(token).is_empty():
				continue
			vals.append(str(token).to_float())
		if vals.size() >= 3:
			return Vector3(vals[0], vals[1], vals[2])
	return Vector3(NAN, NAN, NAN)


func _to_f(p_v: Variant) -> float:
	if p_v is float or p_v is int:
		return float(p_v)
	if p_v is String:
		return str(p_v).to_float()
	return NAN


func _is_finite(p_v: float) -> bool:
	return not is_nan(p_v) and not is_inf(p_v)


func _finite3(p_v: Vector3) -> bool:
	return _is_finite(p_v.x) and _is_finite(p_v.y) and _is_finite(p_v.z)


func _clear_batches() -> void:
	for key in _batches.keys():
		var node: Node = _batches[key] as Node
		if node != null and is_instance_valid(node):
			remove_child(node)
			node.free()
	_batches = {}
