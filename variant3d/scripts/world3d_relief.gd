extends Node3D

# Z08 — HEIGHT WAVE minimal relief-prop consumer (static, per-sid MultiMesh).
#
# SCOPE: render donor `terrainmeshN` props at the positions carried by the
# already-landed `game.pattern_stamps`. READ-ONLY on sim state: this module never
# writes `height[]`, `blocked[]`, `nav_version`, `pattern_stamps`, any RNG stream
# or any stamp object. It only instantiates visual nodes in the 3D scene tree.
#
# DATA PROVENANCE (all donor numbers derived read-only, no donor binary copied):
#   variant3d/assets/terrain/mountain_props.json — parsed from donor
#   data/pattern/pattern.lib `Objects` records (112 records / 30 sections;
#   Z06 §1-§2). Each entry carries the exact donor Position/Up/Scaling literals
#   plus the pattern.lib line number. yaw_deg = atan2(-Up.Z, Up.X), DERIVED.
#   Donor source SHA-256 is recorded in the JSON header.
#   Geometry: res://assets/models/obj/terrainmeshN.obj (+ .png), converted by
#   convert_models.py --include-relief and registered in manifest.json. Mesh
#   vertices are kept in RAW donor units (Z-up); the authored per-object Scaling
#   (0.3538637161..0.6562154889) is applied as an instance transform, NOT baked.
#
# PLACEMENT IS PORT APPROX — EVERY ENGINE-SIDE TERM IS UNVERIFIED:
#   - donor native `StandPatternWithAngle(..., angle=0)` consumes the Objects
#     list; its transform math has no plaintext consumer (Z06 §3, Z03 B4).
#   - which terrainmeshN a stamp picks at runtime is engine-side: we instantiate
#     ALL donor records of a stamp (Z06 §1 "multi-prop arrangement", INFERRED),
#     never claim donor-exact selection (Z03 B4 / Z06 §7 Q1).
#   - donor metres-per-unit is UNVERIFIED (DTRN-02 C20): NO metre factor is
#     invented. The only conversion is `s = MAP_W / DONOR_UNITS` from the
#     EXISTING port pattern generator (pattern_gen.gd:9, :92), used solely to
#     map donor pattern-cell offsets into the port's already-scaled tile grid.
#   - donor Y-yaw -> Godot Y-up yaw SIGN is UNVERIFIED; we use deg_to_rad(yaw)
#     as a documented PORT APPROX.
#   - `terrainplateau1..4` are deliberately skipped: no donor albedo, no .prop,
#     zero pattern.lib BaseName refs (Z05 §1.3 / Z03 B5). They never enter the
#     derived table, so there is nothing to place here.
#   NO DONOR PARITY CLAIM (CHARTER §3/§5): visual correctness stays UNVERIFIED
#   until G04 runs the Z07 QA atom and a human reviews the windowed PNGs.
#
# CITATIONS: Z03 §1.2/§4.1, Z05 §1.2/R2/R3, Z06 §1-§5, Z07 §2/§5,
#   WAVE_G_CHARTER.md:31 (only G04 runs Godot), CHARTER.md:55-58,66.

const PROP_TABLE := "res://assets/terrain/mountain_props.json"
const MODEL_MANIFEST := "res://assets/models/manifest.json"
# FOLD-07 — resolve relief OBJ geometry through the central manifest resolver,
# preferring the mapped `assets.obj` bucket path. The flat OBJ root stays in
# asset_paths.gd as a legacy fallback only; this module composes no flat path.
const AssetPaths = preload("res://scripts/asset_paths.gd")
const DONOR_UNITS := 160.0            # pattern_gen.gd:9 (existing port scale)
const TILE_M := 2.0                   # data.gd:23 / game.gd:16
const GROUP := "terrainmesh_props"    # Z07 §2 group name (node-level compatibility)
const RELIEF_SIDS := ["terrainmesh1", "terrainmesh2", "terrainmesh3", "terrainmesh4"]

const PLACEMENT_LABEL := "PORT APPROX — engine-side StandPatternWithAngle transform UNVERIFIED (Z06 §3)"
const SELECTION_LABEL := "PORT APPROX — engine-side terrainmeshN selection UNVERIFIED (Z03 B4 / Z06 §7 Q1)"
const SOURCE_LABEL := "derived numbers: data/pattern/pattern.lib Objects records (read-only parse, Z08)"
const PLATEAU_LABEL := "SKIPPED — terrainplateau1..4 have no donor albedo/.prop/pattern.lib link (Z05 §1.3)"

var game = null
var terrain = null

var stats: Dictionary = {}

var _table: Dictionary = {}
var _bboxes: Dictionary = {}
var _meshes: Dictionary = {}
var _props: Array[Dictionary] = []
var _built: bool = false


func _ready() -> void:
	# The composition owner (world3d.gd) calls bind(); keep a defensive default
	# so a standalone test scene never shows a stale/empty layer as "loaded".
	if stats.is_empty():
		stats = {
			"module": "Z08 world3d_relief",
			"built": false,
			"placement_source": SOURCE_LABEL,
			"placement_label": PLACEMENT_LABEL,
			"selection_label": SELECTION_LABEL,
			"plateau_label": PLATEAU_LABEL,
		}


# --- public API ---------------------------------------------------------------

func bind(g, terrain_module) -> void:
	game = g
	terrain = terrain_module
	C3Log.info("world", "relief.bind begin")
	_load_table()
	_load_manifest_bboxes()
	_load_meshes()
	rebuild()
	C3Log.info("world", "relief.bind done props=%d batches=%d stamps=%d matched=%d missing_mesh=%d unknown_sid=%d" % [int(stats.get("prop_count", 0)), int(stats.get("batch_count", 0)), int(stats.get("stamp_count", 0)), int(stats.get("matched_stamps", 0)), int(stats.get("skipped_missing_mesh", 0)), int(stats.get("skipped_unknown_sid", 0))])


# Rebuild from the CURRENT game.pattern_stamps. Deterministic: no RNG is touched
# and no stamp object is modified. Safe to call again after a new game binds.
func rebuild() -> void:
	_clear_batches()
	_props.clear()
	var result := {
		"module": "Z08 world3d_relief",
		"built": false,
		"table_loaded": not _table.is_empty(),
		"placement_source": SOURCE_LABEL,
		"placement_label": PLACEMENT_LABEL,
		"selection_label": SELECTION_LABEL,
		"plateau_label": PLATEAU_LABEL,
		"prop_count": 0,
		"stamp_count": 0,
		"matched_stamps": 0,
		"skipped_missing_mesh": 0,
		"skipped_unknown_sid": 0,
		"batch_count": 0,
		"sids": [],
	}
	if game == null or _table.is_empty():
		stats = result
		return

	var stamp_list: Array = []
	var ps = game.get("pattern_stamps")
	if ps is Array:
		stamp_list = ps as Array
	elif game.get("_pattern_build") is Dictionary:
		var pb: Dictionary = game.get("_pattern_build")
		var sv: Variant = pb.get("stamps", [])
		if sv is Array:
			stamp_list = sv as Array
	result["stamp_count"] = stamp_list.size()

	var map_w := int(game.get("MAP_W")) if game.get("MAP_W") != null else 0
	var map_h := int(game.get("MAP_H")) if game.get("MAP_H") != null else 0
	if map_w <= 0 or map_h <= 0:
		stats = result
		return
	# EXISTING port scale (pattern_gen.gd:92) — NOT an invented metres/unit.
	var cell_scale := float(map_w) / DONOR_UNITS
	var half_w := float(map_w) * TILE_M * 0.5
	var half_h := float(map_h) * TILE_M * 0.5

	# Group instances by sid; one MultiMesh per sid keeps draw calls minimal
	# (Z06 §5 Step 4, P02/P11 concern). `props` is the derived donor table keyed
	# by pattern name; every record of a matched stamp is instantiated.
	var by_sid: Dictionary = {}
	var props_table: Variant = _table.get("props", {})
	if not (props_table is Dictionary):
		stats = result
		return
	for st in stamp_list:
		if st == null:
			continue
		var st_name := str(_g(st, "name", ""))
		if st_name.is_empty() or not (props_table as Dictionary).has(st_name):
			continue
		result["matched_stamps"] = int(result["matched_stamps"]) + 1
		var st_x := int(_g(st, "x", 0))
		var st_y := int(_g(st, "y", 0))
		var recs: Variant = (props_table as Dictionary)[st_name]
		if not (recs is Array):
			continue
		for raw in (recs as Array):
			if not (raw is Dictionary):
				continue
			var pm: Dictionary = raw
			var sid := str(pm.get("sid", pm.get("base", "")))
			if not RELIEF_SIDS.has(sid):
				result["skipped_unknown_sid"] = int(result["skipped_unknown_sid"]) + 1
				continue
			if not _meshes.has(sid):
				result["skipped_missing_mesh"] = int(result["skipped_missing_mesh"]) + 1
				continue

			# pattern-local donor-cell offset -> port tile offset, using the SAME
			# rounding as pattern_gen.gd:121-122. PORT APPROX for placement.
			var dx := int(round(float(pm.get("px", 0.0)) * cell_scale))
			var dy := int(round(float(pm.get("pz", 0.0)) * cell_scale))
			# Stamp centre tile convention: game.gd:766 ((cx+0.5)*TILE).
			# Scene is centred on the origin, so subtract the half-map offset
			# (world3d_terrain.gd:1720, Z07 §2).
			var wx := (float(st_x) + float(dx) + 0.5) * TILE_M - half_w
			var wz := (float(st_y) + float(dy) + 0.5) * TILE_M - half_h
			var wy := 0.0
			if terrain != null and terrain.has_method("height_at_world"):
				wy = float(terrain.call("height_at_world", Vector2(wx, wz)))

			# Authored, uniform donor Scaling (0.3539..0.6562); NO random rescale
			# (dogenerate.inc:1984-1985) and NO metre factor (DTRN-02 C20).
			var sc := float(pm.get("sx", 1.0))
			var yaw_deg := float(pm.get("yaw_deg", 0.0))
			_props.append({
				"sid": sid,
				"stamp_name": st_name,
				"stamp_cell": Vector2i(st_x, st_y),
				"prop_cell": Vector2i(st_x + dx, st_y + dy),
				"world_pos": Vector3(wx, wy, wz),
				"scale": sc,
				"yaw_deg": yaw_deg,
				"donor_line": int(pm.get("line", -1)),
				"placement_source": SOURCE_LABEL,
				"selection_rule": "PORT APPROX",
			})
			if not by_sid.has(sid):
				by_sid[sid] = []
			(by_sid[sid] as Array).append(_props[_props.size() - 1])

	# Build one static MultiMeshInstance3D per sid.
	for sid in by_sid.keys():
		var items: Array = by_sid[sid]
		if items.is_empty():
			continue
		var mm := MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		mm.mesh = _meshes[sid] as Mesh
		mm.instance_count = items.size()
		var bb: Array = _bboxes.get(sid, [])
		if bb.size() < 6:
			bb = [0.0, 0.0, 0.0, 0.0, 0.0, 1.0]
		# Donor OBJ is raw Z-up (manifest bbox is [xmin,xmax,ymin,ymax,zmin,zmax]).
		# Re-centre X/Y and zero the base Z before the axis swap, mirroring
		# world3d_entities.gd:_bake_mesh (:1117-1119) exactly, but as a per-instance
		# Transform3D so the shared mesh stays in raw donor units.
		var cx := (float(bb[0]) + float(bb[1])) * 0.5
		var cy := (float(bb[2]) + float(bb[3])) * 0.5
		var z0 := float(bb[4])
		for i in range(items.size()):
			var p: Dictionary = items[i]
			var yaw_rad := deg_to_rad(float(p.get("yaw_deg", 0.0)))
			# donor Z-up -> Y-up: (x,y,z) -> (x,z,-y), i.e. -90 deg about X.
			var basis := Basis().rotated(Vector3(1.0, 0.0, 0.0), -PI * 0.5)
			# Yaw sign is UNVERIFIED (DTRN-02 C3); direct deg_to_rad is PORT APPROX.
			basis = Basis().rotated(Vector3(0.0, 1.0, 0.0), yaw_rad) * basis
			basis = basis.scaled(Vector3(sc_of(p), sc_of(p), sc_of(p)))
			var origin: Vector3 = (p.get("world_pos") as Vector3) + basis * Vector3(-cx, -cy, -z0)
			mm.set_instance_transform(i, Transform3D(basis, origin))

		var holder := MultiMeshInstance3D.new()
		holder.name = "TerrainmeshProps_" + sid
		holder.multimesh = mm
		holder.add_to_group(GROUP)
		holder.set_meta("terrainmesh_sid", sid)
		holder.set_meta("stamp_names", _unique_stamp_names(items))
		holder.set_meta("placement_source", SOURCE_LABEL)
		holder.set_meta("scale_authored", true)
		holder.set_meta("selection_rule", SELECTION_LABEL)
		holder.set_meta("prop_count", items.size())
		add_child(holder)

	result["prop_count"] = _props.size()
	result["batch_count"] = by_sid.size()
	result["sids"] = by_sid.keys()
	result["built"] = true
	result["props"] = _props.duplicate(true)
	stats = result


# Public QA/capture seam: hide/show the whole static layer without touching sim
# state. G04's props-ON/props-OFF A/B (Z07 §6.1) can call this on one frozen
# camera; it never deletes or rebuilds a mesh.
func set_props_visible(v: bool) -> void:
	for c in get_children():
		if c is MultiMeshInstance3D:
			(c as MultiMeshInstance3D).visible = v


# Read-only per-prop descriptors for QA reconciliation (Z07 §2/§3).
func props() -> Array:
	return _props.duplicate(true)


# --- internals ----------------------------------------------------------------

func sc_of(p: Dictionary) -> float:
	return float(p.get("scale", 1.0))


# Stamp objects are C3PatternGen.Stamp (Object) but Dictionary doubles are used
# by headless tests. Object.get() takes ONE argument, Dictionary.get() takes two
# — keep the call shape explicit so neither form raises "too many arguments".
func _g(src, key: String, fallback):
	if src is Dictionary:
		return (src as Dictionary).get(key, fallback)
	if src is Object:
		var v: Variant = (src as Object).get(key)
		return fallback if v == null else v
	return fallback


func _unique_stamp_names(items: Array) -> Array[String]:
	var out: Array[String] = []
	for p in items:
		var n := str((p as Dictionary).get("stamp_name", ""))
		if not out.has(n):
			out.append(n)
	return out


func _clear_batches() -> void:
	for c in get_children().duplicate():
		if c is MultiMeshInstance3D:
			remove_child(c)
			(c as Node).free()


func _load_table() -> void:
	_table = {}
	if not FileAccess.file_exists(PROP_TABLE):
		push_warning("world3d_relief: missing " + PROP_TABLE + " (Z08 derived table)")
		return
	var f := FileAccess.open(PROP_TABLE, FileAccess.READ)
	if f == null:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if parsed is Dictionary:
		_table = parsed as Dictionary


func _load_manifest_bboxes() -> void:
	_bboxes = {}
	if not FileAccess.file_exists(MODEL_MANIFEST):
		return
	var f := FileAccess.open(MODEL_MANIFEST, FileAccess.READ)
	if f == null:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if not (parsed is Dictionary):
		return
	var models: Variant = (parsed as Dictionary).get("models", [])
	if not (models is Array):
		return
	for m in (models as Array):
		if not (m is Dictionary):
			continue
		var md: Dictionary = m
		var sid := str(md.get("sid", ""))
		if RELIEF_SIDS.has(sid) and md.get("bbox") is Array:
			_bboxes[sid] = md["bbox"]


func _load_meshes() -> void:
	_meshes = {}
	for sid in RELIEF_SIDS:
		# FOLD-07 — mapped `assets.obj` bucket path first via the central
		# resolver; flat original is only a diagnostic fallback (never relied
		# on). COORD's typed `var path: String` form is preserved.
		var path: String = AssetPaths.existing(sid, "obj")
		# FOLD-07-PREFIX-FIX: a begins_with(LEGACY_OBJ_DIR) test also matched the
		# healthy mapped bucket .../obj/shared/terrain/<sid>.obj (flagged by
		# FLATMAP_relief_obj.md). Compare against the exact legacy path instead.
		if path == AssetPaths.legacy_for(sid, "obj"):
			push_warning("world3d_relief: relief OBJ map miss for %s — flat diagnostic fallback %s" % [sid, path])
		C3Log.debug("world", "relief mesh sid=%s path=%s legacy_fallback=%s" % [sid, path, str(path == AssetPaths.legacy_for(sid, "obj"))])
		# Without a Godot import pass no .import exists; load() then returns null.
		# Skip with a warning rather than crash any existing gate (Z05 R11).
		if not ResourceLoader.exists(path):
			push_warning("world3d_relief: OBJ not imported yet: " + path + " (G04 must run Godot once)")
			C3Log.debug("world", "relief mesh MISS sid=%s path=%s not-imported" % [sid, path])
			continue
		var res: Resource = load(path) as Resource
		if res is Mesh:
			_meshes[sid] = res
		else:
			push_warning("world3d_relief: " + path + " did not import as Mesh")
			C3Log.debug("world", "relief mesh SKIP sid=%s path=%s not-a-mesh" % [sid, path])
	C3Log.info("world", "relief meshes loaded=%d/%d sids=%s" % [_meshes.size(), RELIEF_SIDS.size(), str(_meshes.keys())])
