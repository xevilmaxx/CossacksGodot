extends Node3D

# ---------------------------------------------------------------------------
# variant3d/scripts/terrain_donor_world.gd — I11-COMPOSER (2026-11-26)
#
# The ONE script world3d.gd loads when terrain_backend == "donor"
# (V05 §4.2 item 3 / V11 N14 / spec/12 §12.2). It owns NO terrain algorithm:
# it only composes the disjoint, independently owned modules
#   I06 terrain_donor_data.gd   — SoA container + additive dump fields
#   I07 terrain_donor_gen.gd    — stage pipeline + per-stage RNG ledger
#   I08 terrain_donor_mesh.gd   — the single ArrayMesh / water / environment
#   I09 terrain_donor_props.gd  — instanced relief / forest / stone / mine props
# and binds the I10 shader (terrain_donor_shader.gdshader).
#
# DEGRADE GRACEFULLY: every module is optional. Nothing is instantiated unless
# its resource path exists and can_instantiate() succeeds; a missing module is
# recorded in stats["missing_modules"] with a PORT APPROXIMATION label, never
# fatal, never a push_error. The legacy backend is completely unaffected: this
# file is only reachable through the exclusive ternary at world3d.gd:609.
#
# PARITY GUARD (top-level, hard-coded false): no donor binary, donor data or
# donor GPU frame was used. No donor visual parity claim. All port choices are
# PORT APPROXIMATION; stats is diagnostics only and never feeds back into sim,
# mesh, water, tile assignment or any gate threshold (CHARTER §4/§5).
# ---------------------------------------------------------------------------

# TOP-LEVEL PARITY GUARD — never set true without a real matched-seed donor A/B.
const visual_parity_claim: bool = false

# Published module paths (V11 ledger N8/N9/N11/N12/N13; no class_name anywhere).
const DATA_SCRIPT := "res://scripts/terrain_donor_data.gd"                # I06
const GEN_SCRIPT := "res://scripts/terrain_donor_gen.gd"                  # I07
const MESH_SCRIPT := "res://scripts/terrain_donor_mesh.gd"                # I08
const PROPS_SCRIPT := "res://scripts/terrain_donor_props.gd"              # I09
const DONOR_SHADER_PATH := "res://shaders/terrain_donor_shader.gdshader"  # I10 canonical
const DONOR_SHADER_ALIAS := "res://shaders/terrain_donor.gdshader"        # A06 N7 alias (labelled)

# Every donor constant cited (read-only text citations; no donor binary/data).
const TILE_M: float = 2.0                # data.gd:23; dmscript.global:171 gc_meters_to_tile=2 (DEC-05)
const TILE_ID_MAX: int = 123             # terrain.presets:6-129; spec/06:9 (124 ids 0..123)
const TILE_SENTINEL_WATER: int = 255     # game.gd:52 BLK_WATER — PORT ONLY, not a donor tile id
const WATER_DEEP: float = -0.25          # texturemap.inc:29-30 (tile classify)
const WATER_SHORE: float = -0.1          # texturemap.inc:31
const BASIN_H: float = -1.1              # generatemap.inc:7 cWaterHeight (generation basin, not plane Y)
const PLATEAU_H: float = 2.964           # generatemap.inc:4 cPlateauHeight
const HILL_H: float = 1.31733            # generatemap.inc:5 cHillHeight
const RAVINE_H: float = -2.964           # generatemap.inc:6 cRavineHeight
const R_MULT: float = 3.5                # generatemap.inc:567-574 (R-channel multiplier)
const TILE_GRID: int = 25                # dogenerate.inc:1335 cSize
const SMOOTH_PASSES: int = 3             # smoothtiles.inc:237 (cfg 6 preserved as C2)
const ROCK8_H: float = 2.7               # texturemap.inc:433-447,557-611 (|h|>2.7 -> rock8)
const ROCK4_H: float = 2.4               # texturemap.inc:433-447,557-611 (>2.4 -> rock4)
const CLIFF_NONE_H: float = 0.1          # texturemap.inc:433-447 (<0.1 -> no cliff)
const CDIFF1: float = 0.5                # texturemap.inc:63 (4-neighbour steep test)
const CDIFF2: float = 0.55               # texturemap.inc:64 (diagonal steep test)
const FIELD_STEP_CELLS: float = 1.6981   # unit.script:6468-6570 (F07 §8 mill-sown fields)
const DONOR_SIZES := [256, 320, 480, 640]  # miscext2.script:19-26; dmscript.global:132-135

# Active skirmish light.cfg literals (X35 E3-E6). The terrain shader keeps its
# own manual Blinn-Phong; this rig lights ordinary spatial entity/prop materials.
const DONOR_SUN_POS := Vector3(-0.344731152057648, 0.938701450824738, 0.0)  # light.cfg:26-30
const DONOR_AMBIENT := Color(0.196078434586525, 0.184313729405403, 0.129411771893501)  # light.cfg:3-6
const DONOR_DIFFUSE := Color(0.811764717102051, 0.780392169952393, 0.694117665290833)  # light.cfg:10-13
const DONOR_SPECULAR := Color(0.278431385755539, 0.266666680574417, 0.211764708161354)  # light.cfg:20-23
# Existing port compensation, NOT donor literals (X35 E27; world3d_terrain.gd:149-151).
# PORT APPROXIMATION — owner visual usability request: modest energy increase so
# ordinary spatial entity/prop materials are readable. Sun direction and every
# donor colour remain byte-exact; no new hue, no shadows, no AO, no shader edit.
const AMBIENT_ENERGY: float = 1.40
const SUN_ENERGY: float = 2.00
const ENERGY_LABEL := "PORT APPROXIMATION — owner visual usability request"

const PORT_LABEL := "PORT APPROXIMATION — no donor GPU A/B frame; parity UNVERIFIED"

# --- state (all additive; no global class_name, no sim writes) --------------
var game = null
var stats: Dictionary = {}

var _data = null
var _gen = null
var _mesh = null
var _props = null
var _shader: Shader = null
var _shader_path_used: String = "NONE"
var _shader_label: String = ""
var _missing: Array[String] = []
var _built: bool = false
var _gen_applied: bool = false
var _props_applied: bool = false
var _environment: WorldEnvironment = null
var _sun: DirectionalLight3D = null
var _stamps_seen: int = 0
var _stamps_accepted: int = 0
var _stamps_skipped: int = 0
var _stamp_source: String = "legacy fallback"
var _stamp_conversion_notes: Array[String] = []


# ---------------------------------------------------------------------------
# Untyped property read: works for a C3Game Object, a Dictionary test double
# and the I06 container without importing any legacy script (read-only).
# ---------------------------------------------------------------------------
func _prop(src, key: String):
	if src == null:
		return null
	if src is Dictionary:
		return (src as Dictionary).get(key, null)
	if src is Object:
		return (src as Object).get(key)
	return null


# C3PatternGen.Stamp (pattern_gen.gd:66-73) exposes family/name/kind/res/x/y/cells.
# It has no height or sid property; do not synthesize either. Dictionary stamps
# remain accepted for headless callers, while live Stamp Objects are adapted here.
func _stamp_to_dictionary(p_raw, p_index: int) -> Dictionary:
	if p_raw is Dictionary:
		return (p_raw as Dictionary).duplicate(true)
	if not (p_raw is Object):
		_stamp_conversion_notes.append("stamp[%d] skipped: unsupported non-Object value" % p_index)
		return {}
	var src: Object = p_raw as Object
	var name_v: Variant = _prop(src, "name")
	var name: String = "" if name_v == null else str(name_v).strip_edges()
	if name.is_empty():
		name_v = _prop(src, "pattern")
		name = "" if name_v == null else str(name_v).strip_edges()
	if name.is_empty():
		name_v = _prop(src, "pattern_name")
		name = "" if name_v == null else str(name_v).strip_edges()
	var x_v: Variant = _prop(src, "x")
	var y_v: Variant = _prop(src, "y")
	if name.is_empty() or not ((x_v is int or x_v is float) and (y_v is int or y_v is float)):
		_stamp_conversion_notes.append(
			"stamp[%d] skipped: Object cannot be converted (requires name/pattern and numeric x/y)" % p_index)
		return {}
	var out: Dictionary = {"name": name, "pattern": name, "x": x_v, "y": y_v}
	for key in ["family", "kind", "res"]:
		var value: Variant = _prop(src, key)
		if value != null:
			out[key] = value
	var cells: Variant = _prop(src, "cells")
	if cells is Array:
		out["cells"] = (cells as Array).duplicate(true)
	return out


func _grid_size() -> Vector2i:
	var wv = _prop(game, "MAP_W")
	if wv == null:
		wv = _prop(game, "map_w")
	var hv = _prop(game, "MAP_H")
	if hv == null:
		hv = _prop(game, "map_h")
	if not (wv is int or wv is float) or not (hv is int or hv is float):
		return Vector2i.ZERO
	return Vector2i(int(wv), int(hv))


# --- optional module loading ------------------------------------------------

func _load_module(path: String, as_child: bool):
	if not ResourceLoader.exists(path):
		_missing.append(path)      # staged rollout: absence is expected, not fatal
		return null
	var script := load(path) as Script
	if script == null or not script.can_instantiate():
		push_warning("terrain_donor_world: present but uninstantiable " + path)
		return null
	var inst = script.new()
	if inst == null:
		return null
	if as_child and inst is Node:
		add_child(inst as Node)
	return inst


# One donor-backed rig for this composer. Reuse the nodes on rebind/rebuild so
# WorldEnvironment and DirectionalLight3D cannot stack. Shadows/AO stay off.
func _ensure_light_rig() -> void:
	if _environment == null or not is_instance_valid(_environment):
		var env := Environment.new()
		env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		env.ambient_light_color = DONOR_AMBIENT
		env.ambient_light_energy = AMBIENT_ENERGY
		env.set_meta("donor_ambient", DONOR_AMBIENT)
		# The raised AMBIENT_ENERGY is the mild ambient fill; it uses DONOR_AMBIENT
		# itself, so no second hue or extra scene node is introduced.
		env.set_meta("energy_label", ENERGY_LABEL)
		_environment = WorldEnvironment.new()
		_environment.name = "WorldEnvironment"
		_environment.environment = env
		add_child(_environment)
	if _sun == null or not is_instance_valid(_sun):
		_sun = DirectionalLight3D.new()
		_sun.name = "DonorSun"
		_sun.light_color = DONOR_DIFFUSE
		_sun.light_energy = SUN_ENERGY
		_sun.shadow_enabled = false
		# light.cfg Position is a Y-up parallel direction (X35 C1-C3). Light3D
		# has no separate specular-colour slot; retain the cited literal in meta
		# and telemetry while the terrain shader remains unchanged.
		_sun.set_meta("donor_sun_position", DONOR_SUN_POS)
		_sun.set_meta("donor_specular", DONOR_SPECULAR)
		_sun.set_meta("energy_label", ENERGY_LABEL)
		_sun.look_at_from_position(DONOR_SUN_POS.normalized() * 120.0, Vector3.ZERO, Vector3.FORWARD)
		add_child(_sun)


# Call a method with the right arity from a candidate argument list. This keeps
# the composer compatible with a module that lands with a narrower signature.
func _method_arg_count(obj: Object, method: String) -> int:
	for m in obj.get_method_list():
		var info: Dictionary = m as Dictionary
		if str(info.get("name", "")) == method:
			var a = info.get("args", [])
			return (a as Array).size()
	return -1


func _call_adapt(obj, method: String, args: Array) -> bool:
	if obj == null or not (obj is Object):
		return false
	var target: Object = obj as Object
	if not target.has_method(method):
		return false
	var argc := _method_arg_count(target, method)
	if argc < 0 or argc > args.size():
		return false
	target.callv(method, args.slice(0, argc))
	return true


# --- I10 shader binding ----------------------------------------------------

func _bind_shader() -> void:
	_shader = null
	_shader_path_used = "NONE"
	for path in [DONOR_SHADER_PATH, DONOR_SHADER_ALIAS]:
		if not ResourceLoader.exists(path):
			continue
		var res = load(path)
		if res is Shader:
			_shader = res as Shader
			_shader_path_used = path
			break
	if _shader == null:
		_shader_label = PORT_LABEL + " — I10 shader absent; mesh keeps its labelled fallback"
		return
	# Prefer the mesh module's explicit hook; otherwise bind the one surface.
	if _call_adapt(_mesh, "set_donor_shader", [_shader]):
		_shader_label = "I10 shader bound via mesh.set_donor_shader()"
		return
	var surface_mesh = null
	if _mesh != null and _mesh is Object:
		surface_mesh = (_mesh as Object).get("mesh")
	if surface_mesh is ArrayMesh and (surface_mesh as ArrayMesh).get_surface_count() > 0:
		var mat = (surface_mesh as ArrayMesh).surface_get_material(0)
		if mat is ShaderMaterial:
			(mat as ShaderMaterial).shader = _shader
			_shader_label = "I10 shader bound to the single mesh surface material"
			return
	_shader_label = PORT_LABEL + " — I10 shader loaded, mesh surface material not ready yet"


# ---------------------------------------------------------------------------
# Contract surface consumed by world3d.gd (P01 E14 / V05 §4.2 item 3).
# ---------------------------------------------------------------------------

func bind(g, _h = null) -> void:
	game = g
	_missing.clear()
	_data = _load_module(DATA_SCRIPT, false)
	_gen = _load_module(GEN_SCRIPT, false)
	_mesh = _load_module(MESH_SCRIPT, true)
	_props = _load_module(PROPS_SCRIPT, true)
	_ensure_light_rig()
	var size := _grid_size()
	if _data != null and game != null:
		var ok := false
		if _data is Object and (_data as Object).has_method("from_live_object"):
			ok = bool((_data as Object).call("from_live_object", game))
		if not ok and size.x > 0 and size.y > 0:
			_call_adapt(_data, "configure_grid", [size.x, size.y])
	_bind_shader()


func build() -> bool:
	_built = false
	_gen_applied = false
	_props_applied = false
	_stamps_seen = 0
	_stamps_accepted = 0
	_stamps_skipped = 0
	_stamp_source = "legacy fallback"
	_stamp_conversion_notes.clear()
	var size := _grid_size()
	if size.x <= 0 or size.y <= 0:
		stats = _make_stats(false, "no game grid; build skipped (read-only, no fallback mesh)")
		return false
	_ensure_light_rig()
	# I06: refresh the read-only SoA view of the live dump keys.
	if _data != null:
		var ok := false
		if _data is Object and (_data as Object).has_method("from_live_object"):
			ok = bool((_data as Object).call("from_live_object", game))
		if not ok:
			_call_adapt(_data, "configure_grid", [size.x, size.y])
	# I07: optional stage pipeline; never writes sim state or draws RNG.
	# V48 patch (a): I07's typed surface is generate(C3TerrainData, Dictionary)
	# (gen.gd:420). The game Object is NOT a settings Dictionary; decoded donor
	# inputs arrive in p. Empty p => missing inputs stay labelled/skipped,
	# never invented (gen.gd:400-419, :443-446). No gate, no parity claim.
	if _gen != null and _data != null:
		var gen_params: Dictionary = {}
		# I17 (COORD): optional donor-derived inputs provider. It supplies I07's
		# `p` from derived terrain_new assets only. Absent/uninstantiable module
		# keeps the legacy empty-dict fallback — a missing provider can never
		# break the legacy backend or invent donor values (no parity claim).
		var inputs_path := "res://scripts/terrain_donor_inputs.gd"
		if ResourceLoader.exists(inputs_path):
			var inputs_script := load(inputs_path) as Script
			if inputs_script != null and inputs_script.can_instantiate():
				var inputs = inputs_script.new()
				if inputs != null and inputs is Object and (inputs as Object).has_method("build"):
					var built: Variant = (inputs as Object).call("build", game, size.x, size.y)
					if built is Dictionary:
						gen_params = built as Dictionary
				else:
					_missing.append(inputs_path)
			else:
				_missing.append(inputs_path)
		else:
			_missing.append(inputs_path)
		_gen_applied = _call_adapt(_gen, "generate", [_data, gen_params])
		if not _gen_applied:
			_gen_applied = _call_adapt(_gen, "run", [_data, gen_params])
	# I08: the known contract — bind(game, data), build() -> bool, ONE mesh.
	var mesh_ok := false
	if _mesh != null and _mesh is Object:
		var target: Object = _mesh as Object
		if target.has_method("bind"):
			# V48 patch (c): I08's ingest is Dictionary-only (mesh.gd:196-213);
			# an I06 Object carries no `fields` and is skipped. Hand over I06's
			# read-only live view (data.gd:456-475), or the byte snapshot
			# (data.gd:563-592) as fallback. Typed arrays, no base64 copy on the
			# live path, no sim write, no new constant, no parity claim.
			var mesh_src: Variant = _data
			if _data != null and _data is Object and (_data as Object).has_method("to_live"):
				mesh_src = (_data as Object).call("to_live")
			elif _data != null and _data is Object and (_data as Object).has_method("to_dump"):
				mesh_src = (_data as Object).call("to_dump")
			target.callv("bind", [game, mesh_src])
		if target.has_method("build"):
			mesh_ok = bool(target.call("build"))
	# COORD addendum: I07's donor stamp Dictionaries take precedence. Legacy
	# game.pattern_stamps remain the fallback and still use Stamp Object adaption.
	var stamps_v: Variant = _prop(game, "pattern_stamps")
	var donor_stamps_v: Variant = null
	var data_meta: Variant = _prop(_data, "meta")
	if data_meta is Dictionary:
		donor_stamps_v = (data_meta as Dictionary).get("pattern_stamps", null)
	if donor_stamps_v is Array and not (donor_stamps_v as Array).is_empty():
		stamps_v = donor_stamps_v
		_stamp_source = "I07 donor"
	else:
		_stamp_source = "legacy fallback"
	# I09: optional, built after the mesh/height source is live.
	# V48 patch (b): I09 has no bind(); its single entry is
	# build(Object, Array, Dictionary) (props.gd:210), which binds
	# container/terrain itself (props.gd:211-213).
	if _props != null and _props is Object:
		var ptarget: Object = _props as Object
		if ptarget.has_method("build"):
			var stamps: Array = []
			if stamps_v is Array:
				for i in (stamps_v as Array).size():
					_stamps_seen += 1
					var stamp: Dictionary = _stamp_to_dictionary((stamps_v as Array)[i], i)
					if stamp.is_empty():
						_stamps_skipped += 1
					else:
						stamps.append(stamp)
						_stamps_accepted += 1
			var pres: Variant = ptarget.call("build", _data, stamps, {"terrain": _mesh})
			var props_result: Dictionary = {}
			if pres is Dictionary:
				props_result = pres as Dictionary
			var props_counts: Variant = props_result.get("counts", {})
			_props_applied = bool(props_result.get("built", false)) \
				and props_counts is Dictionary \
				and int((props_counts as Dictionary).get("props_total", 0)) > 0
	_bind_shader()
	_built = mesh_ok
	stats = _make_stats(mesh_ok, "")
	return mesh_ok


func invalidate() -> void:
	for obj in [_gen, _mesh, _props]:
		_call_adapt(obj, "invalidate", [])
	_built = false
	_gen_applied = false
	_props_applied = false
	stats = {}


func has_chunk_or_fallback() -> bool:
	# One full-grid mesh, or the read-only height fallback sampler — never chunks.
	return true


func height_at_world(p: Vector2) -> float:
	if _mesh != null and _mesh is Object and (_mesh as Object).has_method("height_at_world"):
		return float((_mesh as Object).call("height_at_world", p))
	return _sample_fallback(p)


# Nearest-cell read of game.height when no mesh module is present. Never writes.
func _sample_fallback(p: Vector2) -> float:
	var hv = _prop(game, "height")
	if not (hv is PackedFloat32Array):
		return 0.0
	var size := _grid_size()
	if size.x <= 0 or size.y <= 0:
		return 0.0
	var arr: PackedFloat32Array = hv as PackedFloat32Array
	if arr.size() < size.x * size.y:
		return 0.0
	var fx := clampf(p.x / TILE_M + float(size.x) * 0.5 - 0.5, 0.0, float(size.x - 1))
	var fz := clampf(p.y / TILE_M + float(size.y) * 0.5 - 0.5, 0.0, float(size.y - 1))
	return arr[int(fz) * size.x + int(fx)]


# --- donor constants, all cited; diagnostics only --------------------------

func _donor_constants() -> Dictionary:
	return {
		"cell_m": {"value": TILE_M, "cite": "data.gd:23; dmscript.global:171 gc_meters_to_tile=2 (DEC-05)"},
		"tile_id_max": {"value": TILE_ID_MAX, "cite": "terrain.presets:6-129; spec/06:9"},
		"water_sentinel": {"value": TILE_SENTINEL_WATER, "cite": "game.gd:52 BLK_WATER; PORT ONLY, not a donor id"},
		"water_deep": {"value": WATER_DEEP, "cite": "texturemap.inc:29-30"},
		"water_shore": {"value": WATER_SHORE, "cite": "texturemap.inc:31"},
		"basin_h": {"value": BASIN_H, "cite": "generatemap.inc:7 cWaterHeight (generation basin)"},
		"plateau_h": {"value": PLATEAU_H, "cite": "generatemap.inc:4"},
		"hill_h": {"value": HILL_H, "cite": "generatemap.inc:5"},
		"ravine_h": {"value": RAVINE_H, "cite": "generatemap.inc:6"},
		"r_multiplier": {"value": R_MULT, "cite": "generatemap.inc:567-574"},
		"tile_grid_csize": {"value": TILE_GRID, "cite": "dogenerate.inc:1335"},
		"tile_smooth_passes": {"value": SMOOTH_PASSES, "cite": "smoothtiles.inc:237 (cfg 6 preserved as C2)"},
		"rock8_h": {"value": ROCK8_H, "cite": "texturemap.inc:433-447,557-611"},
		"rock4_h": {"value": ROCK4_H, "cite": "texturemap.inc:433-447,557-611"},
		"cliff_none_h": {"value": CLIFF_NONE_H, "cite": "texturemap.inc:433-447"},
		"cdiff1": {"value": CDIFF1, "cite": "texturemap.inc:63"},
		"cdiff2": {"value": CDIFF2, "cite": "texturemap.inc:64"},
		"field_step_cells": {"value": FIELD_STEP_CELLS, "cite": "unit.script:6468-6570 (F07 §8)"},
		"donor_sizes": {"value": DONOR_SIZES.duplicate(), "cite": "miscext2.script:19-26; dmscript.global:132-135"},
	}


func _lighting_stats() -> Dictionary:
	return {
		"source": "donor data/env/lights/light.cfg:3-6,10-13,20-23,26-30 (X35 E3-E6)",
		"sun_position": [DONOR_SUN_POS.x, DONOR_SUN_POS.y, DONOR_SUN_POS.z],
		"ambient": [DONOR_AMBIENT.r, DONOR_AMBIENT.g, DONOR_AMBIENT.b],
		"diffuse": [DONOR_DIFFUSE.r, DONOR_DIFFUSE.g, DONOR_DIFFUSE.b],
		"specular": [DONOR_SPECULAR.r, DONOR_SPECULAR.g, DONOR_SPECULAR.b],
		"ambient_energy": AMBIENT_ENERGY,
		"sun_energy": SUN_ENERGY,
		"energy_label": ENERGY_LABEL,
		"ambient_fill": "Environment.AMBIENT_SOURCE_COLOR with DONOR_AMBIENT (same colour, no new hue); fill comes from the raised AMBIENT_ENERGY only",
		"specular_binding": "Light3D has no separate specular-colour slot; literal kept in node meta/telemetry; terrain shader unchanged",
		"shadows_enabled": false,
		"terrain_shader": "manual Blinn-Phong unchanged; unshaded terrain does not consume this scene rig",
		"visual_parity_claim": false,
	}


func _make_stats(mesh_ok: bool, note: String) -> Dictionary:
	var module_stats: Dictionary = {}
	if _mesh != null and _mesh is Object:
		var s = (_mesh as Object).get("stats")
		if s is Dictionary:
			module_stats = s as Dictionary
	var out: Dictionary = {
		"module": "res://scripts/terrain_donor_world.gd",
		"ticket": "I11-COMPOSER",
		"backend": "donor",
		"built": _built,
		"mesh_built": mesh_ok,
		"gen_applied": _gen_applied,
		"props_applied": _props_applied,
		"modules": {
			"data": _data != null,
			"gen": _gen != null,
			"mesh": _mesh != null,
			"props": _props != null,
			"shader": _shader != null,
			"environment": _environment != null,
			"sun": _sun != null,
		},
		"missing_modules": _missing.duplicate(),
		"degrade_label": PORT_LABEL,
		"shader_path": _shader_path_used,
		"shader_binding": _shader_label,
		"stamp_source": _stamp_source,
		"stamp_conversion": {
			"seen": _stamps_seen,
			"accepted": _stamps_accepted,
			"skipped": _stamps_skipped,
			"notes": _stamp_conversion_notes.duplicate(),
		},
		"lighting": _lighting_stats(),
		"height_fallback": "read-only game.height nearest-cell sample; PORT APPROXIMATION",
		"mesh_stats": module_stats,
		"visual_parity_claim": visual_parity_claim,
		"fed_back_into_sim": false,
		"donor_constants": _donor_constants(),
	}
	if not note.is_empty():
		out["note"] = note
	return out
