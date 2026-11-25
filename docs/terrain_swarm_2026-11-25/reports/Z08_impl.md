---
id: Z08
ticket: "HEIGHT WAVE / Z08-IMPL — relief OBJ + pattern-derived props consumer integration"
agent: "Z08 (integration subagent; Python derivation only, NO Godot, NO runner job)"
date: 2026-11-25
status: DELIVERED__IMPLEMENTATION__NO_GODOT__NO_RUNNER_JOB__NO_PARITY_CLAIM
scope: "Created ONLY variant3d/scripts/world3d_relief.gd, variant3d/tests/t_relief_props_qa.gd, variant3d/assets/terrain/mountain_props.json and this report; edited ONLY variant3d/scripts/world3d.gd (exclusive owner). Backup inbox/backup/world3d.gd.bak-Z08 taken BEFORE edit. No other repo file, no donor file copied, no Godot process, no runner job, no generated .import/PNG."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
donor_root: "C:\\Games\\Cossacks 3 (private use, read in place only)"
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, "PORT APPROX"]
parity_guard: "No donor GPU A/B frame exists (CHARTER §3/§5). Engine-side prop selection and transform are UNVERIFIED. NO DONOR PARITY CLAIM."
sha256:
  world3d_relief_gd: ea3cc506e58ba809cdc0181a7e6189473545b75cd4a3c90d4d3b49d0e37cf775
  world3d_gd_after_edit: 44ee96c0dcfb35558f6ea3e0493e8f8faa1cadf6e155beb38031a9b11e1ab07a
  t_relief_props_qa_gd: b3c7d1436f8eaa9035129625b483a73dc4adbd321463a05a460a6122c383c524
  mountain_props_json: d21237f43d2fd95ddd8fcd7a3ad14290c789df1f1f3881df8f35676053a0e500
  backup_world3d_gd_bak_Z08: def3a2e7766698387796b6a86b9c22d70e24251c8d9dbb8ec713732e6bc0cdd0
---

# Z08 — HEIGHT WAVE integration: donor-driven relief props

> [!IMPORTANT]
> **Boundary.** Exactly four repo files were authored/edited (three new sources + one
> implementation edit) plus this report. The donor `pattern.lib` was parsed **read-only**
> by a local Python script in `%TEMP%\opencode\z08_derive_props.py` (NOT committed, NOT a
> Godot job). **No Godot process, no runner job, no `--headless`, no PNG and no `.import`
> file was produced by Z08** (`WAVE_G_CHARTER.md:31`: only G04 runs jobs). All placement
> semantics that depend on the donor native consumer are **PORT APPROX / UNVERIFIED**;
> there is **no donor parity claim**.

## 0. Documents read first (as instructed)

`WAVE_G_CHARTER.md`, `docs/terrain_swarm_2026-11-25/CHARTER.md`, and reports
`Z03_donor_relief_props.md`, `Z05_relief_prop_conversion.md`, `Z06_prop_placement.md`,
`Z07_relief_props_qa.md` were read in full before any edit.

**`C01_asset_impl.md` was not on disk at initial read time** (the first recursive search
found only `reports/C01_metric_tool.md`) and **landed concurrently during this ticket**;
it was then read in full and is consistent with Z08's assumptions. Its §0/§3/§6.3 confirm
that `obj/terrainmesh{1..4}.obj` + `.mtl`, `tex/terrainmesh{1..4}.png` and 4 appended
`manifest.json` entries (`kind: "relief"`, full donor bboxes) exist, that OBJ vertices stay
in **raw donor units**, and that the authored `Scaling` is deliberately left as placement
data for a later consumer — exactly the contract this module implements. Its §6.3 asks for
a dedicated placement path bypassing entity bbox normalisation; Z06 §5's sibling module
under `world3d.gd:129-134` is that path, and this ticket holds the exclusive `world3d.gd`
ownership grant. Its §6.3 item 4 (Godot `.import` sidecars on the next editor pass) is
carried into this report's G2 gate. No missing file was fabricated.

---

## 1. What Z08 landed

| File | Action | Purpose |
|---|---|---|
| `variant3d/assets/terrain/mountain_props.json` | NEW (derived by local Python) | Exact donor `pattern.lib` per-stamp prop name / Position / Up-yaw / Scaling, keyed by pattern name, with pattern.lib line numbers. Numbers only — no donor binary, no invented metres/unit. |
| `variant3d/scripts/world3d_relief.gd` | NEW | Static, per-sid `MultiMeshInstance3D` layer built from `game.pattern_stamps` + the derived table. No RNG, no stamp mutation. |
| `variant3d/scripts/world3d.gd` | EDIT (exclusive owner) | Instantiate the new module once in `bind()`, call `relief.bind(game, terrain)` after terrain build, expose `stats.relief_props`. Backup taken first. |
| `variant3d/tests/t_relief_props_qa.gd` | NEW (verbatim Z07 §4) | Full proposed QA atom materialised for hand-off / inspection only. NOT run, NOT modified. See §6 for its known interface gap. |

Backup: `inbox/backup/world3d.gd.bak-Z08` (copy of the pre-edit file, SHA below).

---

## 2. Derivation of `mountain_props.json` (read-only Python, no Godot)

### 2.1 Method (OBSERVED / DERIVED)

Helper script: `%TEMP%\opencode\z08_derive_props.py` (not committed). It opens
`C:\Games\Cossacks 3\data\pattern\pattern.lib` with `encoding='latin-1'` (1,172,416 lines,
SHA-256 `f7b421b179dee5ad2b28e025c6b776d8eeccfbec74a93a13c3d1c9d9f10dc1c0`) and runs a
line-wise `section.begin` / `struct.begin` / `struct.end` stack machine. For every record
whose parent struct is `Objects` and whose `BaseName` starts with `terrainmesh`, it captures
`Position`, `Direction`, `Up`, `Scaling` (X/Y/Z/W literals), the record's `pattern.lib` line,
and the enclosing section's `Name`, `Width`, `Height`, `ObjectsScale`, `RotationAngle`.

`yaw_deg` is **DERIVED** as `degrees(atan2(-Up.Z, Up.X))` (Z06 §2.2). Because the donor
stores float32 cos/sin, the raw result carries ~1e-5° noise (`100.000004`, `-179.999994`);
the JSON keeps **both** `yaw_deg_raw` (full precision, audit) and `yaw_deg` (rounded to 3
decimals, runtime). The clean set is `{-180,-170,-160,-150,-130,-120,-100,-80,-60,-30,-20,-10,0,10,...,160}`
— exact 10° multiples up to atan2's (-180,180] convention (Z06 §2.2). No angle was invented.

### 2.2 Exactness checks against Z06 / Z05 (all OBSERVED)

| Check | Z08 derivation | Z06/Z05 reference | Result |
|---|---|---|---|
| Records with `BaseName = terrainmesh*` | **112** | Z06 §1: 112 | MATCH |
| Sections containing them | **30** | Z06 §1: 30 | MATCH |
| Base-name census | mesh3×29, mesh4×25, mesh2×21, mesh1×14, desert4×9, desert3×7, desert2×5, desert1×2 | Z06 §1: identical | MATCH |
| `Scaling` uniform X=Y=Z, range | **0.353863716125488 … 0.656215488910675** | Z05 §1.2 / Z06 §2.1: 0.3539…0.6562 | MATCH |
| `g_mnt_1` first prop | `terrainmesh4`, pos `(-8.98600006103516, 0, 5.62277603149414)`, scale `0.575703918933868`, yaw `20.0°`, line `338480` | Z06 §2 worked example (`pattern.lib:338480-338507`) | MATCH |
| `g_mnt_1` yaw set | `[20, 0, 0, 140, -150]` (= 210°) | Z06 §2.2: `[20°, 0°, 0°, 140°, 210°]` | MATCH (atan2 wrap) |
| `g_mnt_3` scales / yaws | `0.484/0.609/0.539/0.484`, yaws `[90,0,0,0]` | Z06 §2.1/§2.2 | MATCH |
| `terrainplateau*` records | **0** | Z03 §1.2 / Z05 §1.3 / Z06 §1: zero | MATCH — plateau props skipped, no donor albedo |
| Port-stampable sections | 20 (`g_mnt_1..7` + `desert_mnt_1..13`), 45 records | `donor_patterns.json` families `mountains`/`desert_mountains`; Z06 §4.1 | DERIVED |

The other 10 sections (`i_mnt_big_1..5`, `i_mnt_long_1..5`, 67 records) are kept in the
derived table as **donor truth** but are absent from `donor_patterns.json`, so the port can
never stamp them; the consumer simply never sees a matching stamp name. Desert props carry
sids `terrainmeshdesert1..4` which were **not** converted (only summer `terrainmesh1..4`
are in `manifest.json`); the consumer skips them with `skipped_unknown_sid` rather than
fabricating a mesh or albedo.

### 2.3 JSON schema (exact top-level keys)

```
version, source, source_sha256, selection, labels, bbox_m, bbox_m_note,
by_pattern, pattern_meta, props, derived_stats
```

- `props[<pattern_name>]` → list of `{base, sid, px, py, pz, dx, dy, dz, ux, uy, uz,
  yaw_deg, yaw_deg_raw, sx, sy, sz, line}`. Values are donor literals / DERIVED yaw.
- `by_pattern[<pattern_name>]` → list of sids (kept for Z07 atom's `prop_manifest_loaded`).
- `bbox_m` → Z03 §1.2 decoded donor-unit Z spans
  `{mesh1:7.38, mesh2:8.06, mesh3:9.54, mesh4:6.92}`; the key name is retained only for
  Z07 atom compatibility and `bbox_m_note` states explicitly **NOT metres**.
- `selection` and `labels` carry the required **PORT APPROX / UNVERIFIED** label and the
  "raw donor units only — NO metres-per-unit factor is invented" rule.

**No donor `.osm` / `.dds` was copied into the repo; only derived numbers enter the JSON.**

---

## 3. Exact code landed

### 3.1 `variant3d/scripts/world3d_relief.gd` (complete file, SHA-256 `ea3cc506e58ba809cdc0181a7e6189473545b75cd4a3c90d4d3b49d0e37cf775`)

```gdscript
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
const OBJ_DIR := "res://assets/models/obj/"
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
	_load_table()
	_load_manifest_bboxes()
	_load_meshes()
	rebuild()


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
		var path := OBJ_DIR + sid + ".obj"
		# Without a Godot import pass no .import exists; load() then returns null.
		# Skip with a warning rather than crash any existing gate (Z05 R11).
		if not ResourceLoader.exists(path):
			push_warning("world3d_relief: OBJ not imported yet: " + path + " (G04 must run Godot once)")
			continue
		var res: Resource = load(path) as Resource
		if res is Mesh:
			_meshes[sid] = res
		else:
			push_warning("world3d_relief: " + path + " did not import as Mesh")
```

### 3.2 `variant3d/scripts/world3d.gd` (exact hunks, SHA after edit `44ee96c0dcfb35558f6ea3e0493e8f8faa1cadf6e155beb38031a9b11e1ab07a`)

```diff
@@ -110,6 +110,10 @@ const ENTITIES_SCRIPT := "res://scripts/world3d_entities.gd"
 const FX_SCRIPT := "res://scripts/world3d_fx.gd"
 const FOG_SCRIPT := "res://scripts/world3d_fog.gd"
 const ANIM_SCRIPT := "res://scripts/anim3d.gd"
+# Z08 — HEIGHT WAVE relief props: static per-sid MultiMesh layer. New sibling
+# module; no edit to pattern_gen.gd / game.gd / world3d_terrain.gd, so no stamp,
+# RNG, height[] or blocked[] stream is touched.
+const RELIEF_SCRIPT := "res://scripts/world3d_relief.gd"
 
@@ -132,6 +136,7 @@ var entities = null  # world3d_entities.gd : bind/sync/add_*/remove
 var anim = null      # anim3d.gd           : bind(game, entities)/play
+var relief = null    # world3d_relief.gd   : bind(game, terrain) -> static prop MultiMeshes (Z08)
 
@@ -606,6 +611,7 @@ func bind(g, h = null) -> void:
 		anim = _instantiate(ANIM_SCRIPT)
+		relief = _instantiate(RELIEF_SCRIPT)
 
@@ -637,6 +643,11 @@ func bind(g, h = null) -> void:
 		if _has_height_source(game):
 			terrain.build()   # ONE full-grid mesh; no chunk scheduling
+	# Z08: relief props are STATIC — build once here, after terrain.height_at_world
+	# is live, from the already-generated game.pattern_stamps. Read-only on all
+	# sim state; no per-frame work in sync().
+	if relief != null:
+		relief.bind(game, terrain)
 
@@ -668,12 +679,16 @@ func bind(g, h = null) -> void:
 			"anim": anim != null,
+			"relief": relief != null,
 		},
 		"contract": "V71_mechanics_inventory.md:180-199 / V73_ATOMIC_CONTRACT.md:24",
+		"relief_props": relief.stats if relief != null else {},
 	}
```

**Backup taken before edit:** `inbox/backup/world3d.gd.bak-Z08`, SHA-256
`def3a2e7766698387796b6a86b9c22d70e24251c8d9dbb8ec713732e6bc0cdd0`.

### 3.3 `variant3d/tests/t_relief_props_qa.gd`

The body is **byte-for-byte** the fenced GDScript from Z07 §4 (780 lines; SHA of whole file
`b3c7d1436f8eaa9035129625b483a73dc4adbd321463a05a460a6122c383c524`). A 15-line Z08 provenance preamble was prepended; no assertion,
threshold, constant or function was altered. **Parsing/validation was by inspection only —
no Godot run (G04 owns jobs).**

---

## 4. Invariants preserved (DERIVED from code paths, to be re-verified by G04)

1. **No stamp/RNG change.** `pattern_gen.gd`, `game.gd`, `world3d_terrain.gd`,
   `world3d_entities.gd` are untouched. The module reads `game.pattern_stamps` only;
   `git diff` for those files is empty in Z08's change set.
2. **No sim-state write.** No assignment to `height`, `blocked`, `nav_version`,
   `pattern_stamps`, `res_nodes`, `entities`, or any `RandomNumberGenerator`. Height is
   read via `terrain.height_at_world()` only.
3. **No per-frame cost.** `world3d.sync()` is not modified; the layer is built once in
   `bind()` and is static. One `MultiMeshInstance3D` per sid (≤4 draw calls) instead of one
   node per prop (Z06 §5 Step 4, P02/P11 concern).
4. **Raw donor units.** OBJ vertices are never rescaled/baked; axis swap, authored
   `Scaling` and yaw are per-instance `Transform3D` only. No metres-per-unit factor is
   invented (DTRN-02 C20). The sole scale `cell_scale = MAP_W / DONOR_UNITS` is copied from
   the existing port generator (`pattern_gen.gd:9,92`) and applied only to pattern-local
   position offsets.
5. **Plateau exclusion.** Zero `terrainplateau*` records in the derived table; no albedo
   fabrication (Z05 §1.3). Desert sids are passed over when no converted mesh exists.
6. **Fail-soft.** Missing JSON / manifest / un-imported OBJ produce `push_warning` + honest
   `stats` counters, never a crash or a fake prop count. Existing gates are not weakened.
7. **Determinism.** For a fixed seed and map size, `props()` is identical on every rebuild;
   instance order follows `pattern_stamps` order and the JSON's record order.

---

## 5. Label register (binding)

| Item | Label | Evidence |
|---|---|---|
| Donor prop numbers (Position/Up/Scaling) | **OBSERVED** donor literals | `pattern.lib` direct read, SHA above |
| `yaw_deg = atan2(-Up.Z, Up.X)` | **DERIVED** (float32 noise cleaned) | Z06 §2.2 |
| "all N records of a stamp instantiate" | **INFERRED** | Z06 §1 correction; native consumer not observed |
| Placement formula (cell→tile, centre, Y-up yaw sign) | **PORT APPROX** — engine terms **UNVERIFIED** | Z06 §3/§5 Step 3; DTRN-02 C3/C20 |
| Runtime sid choice among several `terrainmeshN` | **UNVERIFIED**, labelled PORT APPROX in JSON + node meta + stats | Z03 B4 / Z06 §7 Q1 |
| Visual silhouette / donor likeness | **UNVERIFIED** — no donor GPU A/B | CHARTER §3/§5 |
| Plateau props | **SKIPPED** (no donor albedo/.prop/BaseName) | Z05 §1.3 / Z03 B5 |

---

## 6. Honest interface gap with the Z07 atom (NOT weakened)

Z07's atom was authored **before** Z05/Z06 landed and prints a contract that Z08 could not
satisfy verbatim while honouring the Z08 directive:

1. **Node type:** Z07 §2 requires one `MeshInstance3D` per prop in group
   `terrainmesh_props`; Z08 lands one `MultiMeshInstance3D` **batch per sid** (the
   directive's explicit "static per-sid MultiMeshInstance3D layer"). `MultiMeshInstance3D`
   is a sibling of `MeshInstance3D`, so Z07's `_collect_props()` will collect zero nodes.
2. **Expected count:** Z07 §3 check 5 counts **1 prop per donor-linked stamp** (Z07's
   `by_pattern` treated sids as alternatives). Z06 §1 corrected this: a stamp carries **N
   distinct props** (e.g. `g_mnt_1` = 5). Z08 instantiates all N.
3. **Manifest path:** Z07's `PROP_MANIFEST` is `res://assets/terrain/terrainmesh_props.json`;
   the Z08 directive names `variant3d/assets/terrain/mountain_props.json`. Only the latter
   was created (file restriction). Z08's JSON nevertheless includes `by_pattern` and
   `bbox_m` so the atom's `prop_manifest_loaded` shape is available once the path is
   reconciled.
4. **Scale:** Z07 §1.1/`SCALE_WANT = 1.0` ("authored scale 1") is the pre-Z05 reading;
   Z05/Z06 proved non-unit `Scaling` 0.354…0.656. Z08 applies the authored value.

The atom was **copied verbatim, not adapted** — per "no test weakening". The QA owner / G04
must reconcile the collector, expected count, manifest path and scale constant **by
strengthening or re-deriving checks, never by lowering a threshold or deleting an
assertion**. The Z08 module exposes `set_props_visible(v)` and `props()` as additive seams
to make that reconciliation possible. This gap is an **UNVERIFIED integration item**, not a
claim that the atom passes.

---

## 7. G04 gate list (G04 ONLY runs Godot / jobs; Z08 did not)

| Gate | Check | Accept / reject |
|---|---|---|
| G0 | Pre-flight `python variant3d\tools\godot_runner.py status` | `pending=0`, `godot.lock=free`, `now_serving==next_ticket`, 0 live Godot processes |
| G1 | Static SHA of the 5 files in frontmatter + `git diff` ownership | hashes match; only the 4 authorised files changed; backup exists |
| G2 | **Godot import pass** (first run after Z08) | `obj/terrainmesh{1..4}.obj.import` and `tex/terrainmesh{1..4}.png.import` generated; `load()` returns `Mesh` for all four; `skipped_missing_mesh == 0` on a mountains map |
| G3 | Parse / selftest / uitest / `t_render_mode` / `assert_clean` | selftest 29/29, uitest 17/17, no new script-error lines (`scan-stderr`: `script_error_lines: 0`), no threshold lowered |
| G4 | Derived-table re-derivation (read-only Python) | re-run `%TEMP%\opencode\z08_derive_props.py`; 112 records / 30 sections / scale 0.3538637161…0.6562154889 / JSON SHA identical |
| G5 | Fixed-seed sim-state regression (64² and 320², relief=mountains) | `height[]`, `blocked[]`, `map_meta.stamp_counts`, all RNG draws byte-identical to a pre-Z08 baseline; `git diff` shows no sim file touched |
| G6 | Observability | `world.stats.relief_props.prop_count > 0` on a 320² mountains map; `placement_label`/`selection_label` carry PORT APPROX; `plateau_label` present |
| G7 | Fixtures (prerequisite, NOT created by Z08) | `variant3d/tests/fixtures/small_map_64_mountains.json` and `small_map_320_mountains.json` must be created by COORD/G04 from Z07 §1.3 before the atom can run |
| G8 | QA atom reconciliation (§6) then windowed run | collector/expected/path/scale fixed by stronger checks; `status=ok`, `exit=0`, `result.passed=true`; headless control refuses (`SKIP_CAPTURE`, `passed=false`, exit 1) |
| G9 | Internal props-ON/OFF A/B + two PNGs | `z07_wide_props_on.png`, `z07_skyline_props_on.png` 1280×720 non-blank; `frames.json` 3 frames; outside-change fraction <1%; **port-visible silhouette only — NOT donor parity** |
| G10 | Human review (C04/G05 protocol) | "does it read as a hill" is **INFERRED**; any donor-hue/silhouette fidelity statement stays UNVERIFIED |

**Do not** treat a green G2/G6 as proof of donor correctness: no donor GPU A/B exists.

---

## 8. Z07 QA command (exact, for G04 only — NOT executed by Z08)

Pre-flight: `python variant3d\tools\godot_runner.py status` (require the G0 state).
Create the artifact dir first:

```
New-Item -ItemType Directory -Force -Path "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\z07_relief_props" | Out-Null
```

**Primary — 64², unique id `z07-relief-props-64-r1`:**

```
python variant3d\tools\godot_runner.py run --id z07-relief-props-64-r1 --timeout 420 -- --path variant3d --script res://tests/t_relief_props_qa.gd -- --config "C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\variant3d\tests\fixtures\small_map_64_mountains.json" --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/z07_relief_props/z07_flag.png" --map-size 64
```

**Optional — 320²:** same line with `--id z07-relief-props-320-r1`,
`small_map_320_mountains.json`, `--map-size 320`.

**Headless control (must be refused):** add `--headless` after the runner's `--`, id
`z07-relief-props-headless-neg`; expect `SKIP_CAPTURE.txt` with `passed: false`, no PNG,
exit 1.

**Read-only verification after the run:**

```
python variant3d\tools\smallmap_capture.py stats "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\z07_relief_props\z07_wide_props_on.png"
python variant3d\tools\smallmap_capture.py stats "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\z07_relief_props\z07_skyline_props_on.png"
python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\<ticket>_z07-relief-props-64-r1\stderr.txt
```

Accept only `script_error_lines: 0`, `status=ok`, `exit=0` for the real run. **Note §6: the
atom must first be reconciled to the landed MultiMesh implementation; running it unchanged
will fail closed on node discovery, which is an honest FAIL, not a Z08 regression.**

---

## 9. Claim register

| # | Claim | Evidence | Label |
|---|---|---|---|
| 1 | 112 donor `terrainmesh*` records in 30 sections, derived read-only | Z08 Python parse, source SHA above; Z06 §1 | **OBSERVED** |
| 2 | Scale 0.3539…0.6562, uniform; yaw pure 10° multiples | derived JSON `derived_stats`; Z05 §1.2 / Z06 §2 | **OBSERVED** values / **DERIVED** yaw |
| 3 | `g_mnt_1` / `g_mnt_3` exact per-stamp numbers match Z06 worked examples | §2.2 table | **OBSERVED** |
| 4 | Plateau props skipped; 0 records | derived JSON; Z05 §1.3 | **OBSERVED** (negative) |
| 5 | Static per-sid MultiMesh layer wired from `world3d.gd`, no sim write | §3 code; `git diff` | **DERIVED** (port control flow) |
| 6 | Visual/hill correctness, donor likeness | no donor GPU A/B; G04 not run | **UNVERIFIED** — **no parity claim** |
| 7 | QA atom verbatim but interface-gapped | §3.3 SHA + §6 | **OBSERVED** (this ticket) / **UNVERIFIED** runtime |

---

*End of Z08. Three new source files + one exclusive-owner edit + this report; backup before
edit. Python derivation only — no Godot, no runner job, no donor copy, no test weakening,
no donor parity claim. Staying available for COORD follow-up.*
