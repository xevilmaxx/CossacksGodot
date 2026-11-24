extends Node3D

# V7-14 - static 3D entity meshes (units / buildings / trees / other resources).
#
# NEW FILE. Owns nothing else; world3d.gd / anim3d.gd / V7-4..V7-9 files are
# untouched. Loaded dynamically via load("res://scripts/world3d_entities.gd")
# (no class_name: a fresh global class is not in .godot's cache until an editor
# import, and every launch must go through variant3d/tools/godot_runner.py).
#
# EXACT PUBLIC API: bind(game), sync(dt), add_unit(e), add_building(e),
#                   add_resource(n), remove(id).
#
# WHAT THIS FILE DOES
#   * Reads donor-derived bind-pose geometry from
#       res://assets/models/obj/<sid>.obj  (116 sids, V7-2 report section 2.1)
#     or from res://assets/models/glb/<sid>.glb when V7-8 lands.
#   * NEVER reads the 2D bake: assets/models/anim/**, sprites/**,
#     sprites_hi/**, buildings.json or any sheet PNG are out of scope
#     (WAVE7_3D_VARIANT_CHARTER.md:40-53 "NO 2D BAKE PIPELINE"). The only PNGs
#     touched here are DDS-derived albedo PNGs in assets/models/tex/**.
#   * Bakes ONE Z-up -> Y-up rotation into each cached mesh:
#       (x, y, z)_Zup -> (x, z, -y)_Yup
#     the determinant-preserving mapping used by glTF export_yup
#     (V7-2 report section 4.1; donor OBJ is Z-up per section 2.3, sample
#     peasant.obj vertex 0 = (0.062326, -0.057036, 0.384664)).
#   * Centres X/Z and grounds Y=0 from the donor bbox in manifest.json, so
#     mounted sids with bind-pose X offsets (cossack x 1.466..2.871,
#     dragoon x 1.317..2.710) cannot be off-centre (V7-2 section 4.1).
#   * Scale comes from that SAME bbox, never from an invented constant:
#       units/buildings: s = 1.0 (donor metres are already ~1.9-3.5 m;
#         V7-2 section 4.1 "H_target = z1-z0, s=1.0 is the sane first pass").
#       env props: s = donor envscales.cfg value - mine 0.3152
#         (data/game/var/envscales.cfg:25-28), stone 0.329 (:43-46),
#         tree 0.5 (:371-374 spruce1); V7-2 section 1.1 / Table A.
#       field (ground patch): no height normalisation (V7-2 section 2.3
#         caveat: "field" is 58.5 x 51.9 x 20.5, normalising by Z is wrong).
#   * Mass armies use MultiMeshInstance3D, one batch per (class, sid), with a
#     fixed capacity and visible_instance_count (V7-1 section 2.4 mass-army
#     row: "Batch by sid/facing with MultiMesh"; V7-3 contract line 13).
#
# ANIMATION (V7-74: donor pose DATA is now consumed, still NOT donor parity)
#   Donor .oss carries per-bone tracks but NO parent hierarchy, so a
#   donor-faithful skeletal skin cannot be built from readable data
#   (V7-2 sections 3.3 / 4.3, Table B1 BLOCKED; data/actors/units/peaukr.oss
#   layout at docs/decomp/DC_FORMATS.md:46-64, evidence ev_392885a6...).
#   V7-64 added anim3d.gd.pose_for(e, action, t) -> pose["verts"]: REAL
#   donor-sampled FLAT-ROOT skinned verts at the resolved AAF frame (V764
#   report section 4). This module now calls that API per unit in sync() and
#   swaps the unit into a frame-keyed MultiMesh batch whose mesh is rebuilt
#   from those verts using this file's SAME bbox/Y-up transform (_bake_mesh).
#   Batching is preserved: units at the same (sid, player, action, frame)
#   share one draw call. The deform is flat-root because bone parents are
#   unreadable, and normals/tangents stay at bind values (not re-skinned).
#   Every batch/node keeps the honest label and visual = UNVERIFIED.
#   With no registered donor skin (shipped runtime today) the module falls
#   back to the exact static bind pose path of V7-14/V7-65 - no invented
#   keyframe, sprite sheet or RNG is ever substituted.
#   A missing mesh gets a bbox-sized box proxy, also tagged; it is a
#   placeholder, not donor fidelity.

const OBJ_DIR: String = "res://assets/models/obj/"
const GLB_DIR: String = "res://assets/models/glb/"
const TEX_DIR: String = "res://assets/models/tex/"
const MANIFEST_PATH: String = "res://assets/models/manifest.json"
# V7-65: player key colours are extracted donor text, NOT a port palette.
# classes.script:7986-8015 (formula :8012-8014), count dmscript.global:121,
# guard/misc.script:5070, application misc.script:5073. Owned by V7-61's JSON.
const KEY_COLORS_PATH: String = "res://data/donor_key_colors.json"

# C3Data.TILE_M (variant3d/scripts/data.gd:23) and C3Game.TILE (game.gd:16).
# heightmap_world3d.gd:200-202 maps tile (x,z) to world
# ((x+0.5-w/2)*TILE_M, height, (z+0.5-h/2)*TILE_M); entity sim pos is the
# same metre space (game.gd:1893-1907 height_at), so subtract half map extent.
const TILE_M: float = 2.0
const MAP_DEFAULT: float = 160.0  # game.gd:35-36 MAP_W/MAP_H default 160

const BATCH_CAPACITY: int = 4096
const HIDDEN_SCALE: float = 0.0001

# Donor numbers, NOT port inventions: see header + V7-2 section 1.1.
const ENV_SCALE := {"mine": 0.3152, "stone": 0.329, "tree": 0.5}
const POOL_TREE := ["tree_spruce1", "tree_pine", "tree_fir", "tree_oak",
	"tree_spruce2", "tree_pinedry1"]
const POOL_ROCK := ["rock", "stone", "rock_stones1", "rock_stones2", "rock_stones3"]
const POOL_BUSH := ["bush1", "bush2", "bush3", "bush4"]
const POOL_STUMP := ["tree_stump1", "tree_stump2", "tree_stump3", "tree_stump4"]

# Exact V7-64 PORT_LABEL text (anim3d.gd:55), kept verbatim with the em dash.
const PORT_LABEL: String = "PORT APPROXIMATION — NOT DONOR PARITY"
# Honest status: real donor flat-root morph DATA is consumed, but this is not
# donor-parity skeletal deformation and the rendered result is UNVERIFIED.
const ANIM_STATUS: String = "DONOR-SAMPLED FLAT-ROOT MORPH — " + PORT_LABEL + " (V7-2 3.3/4.3 Table B1: .oss bone parents unreadable; flat-root skin via anim3d.gd.pose_for; visual UNVERIFIED)"
const MORPH_POSE_SOURCE: String = "donor_flat_root_morph"   # anim3d.gd:96
const MORPH_ACTION_MAP: String = "dead->death / moving->walk / else idle (PORT policy over donor AAF names anim3d.gd:63-82; UNVERIFIED)"

# Deliberately UNTYPED: the integration seam passes the live C3Game (a Node)
# but atomic tests bind a RefCounted stub. V7-1 §3 "relaxed Node typing".
var game = null
var stats: Dictionary = {}
var anim_handoff: Dictionary = {"status": ANIM_STATUS, "owner": "anim3d.gd",
	"reason": "V7-2 Table B1 BLOCKED", "applied": false}

var _bbox: Dictionary = {}          # sid -> donor bbox [x0,x1,y0,y1,z0,z1]
var _mesh_cache: Dictionary = {}    # key -> {"mesh":Mesh,"source":String,"scale":float,"height":float}
var _batches: Dictionary = {}       # key -> {"node":MultiMeshInstance3D,"mm":MultiMesh,"ids":Array}
var _slot: Dictionary = {}          # entity id -> {"key":String,"index":int,"class":String}
var _refs: Dictionary = {}          # entity id -> entity Dictionary (sim object, read-only)
var _nodes: Dictionary = {}         # building id -> MeshInstance3D
var _mesh_sources: Dictionary = {}  # source label -> sid count (measured at bind)
var _anim_t: float = 0.0

# V7-74: anim3d.gd instance, discovered once among the composed world's
# children (world3d.gd:152-165 add_child's every module under one Node3D).
# No edit to world3d.gd is needed; atomic tests that bind a bare stub have no
# sibling anim module and therefore keep the static bind path.
var _anim = null
var _anim_checked: bool = false
# sid|action|frame -> {"mesh":ArrayMesh, "frame":int, "action":String, ...}
# Bounded by the distinct donor frames actually visited; shared by all units.
var _morph_meshes: Dictionary = {}
# sid -> donor OBJ v/vt/f topology, parsed once (the Godot OBJ importer
# de-indexes and reorders verts, so its 719-vertex buffer cannot be addressed
# by the 577 donor indices; the source OBJ is the common index space).
var _obj_topology: Dictionary = {}

# V7-65 donor key-colour table. Index = PLAYER SLOT (identity mapping, see
# bind() stats + report), NOT nation. _key_colors[i] is Color(rgb_godot_float,
# alpha=1.0); alpha is a PORT choice (donor alpha UNVERIFIED, V7-61 §5).
var _key_colors: Array = []
var _key_colors_loaded: bool = false
var _key_colors_error: String = ""


# ---------------------------------------------------------------- bind / stats
func bind(g) -> void:
	game = g
	_load_key_colors()
	_bbox.clear()
	_mesh_cache.clear()
	_mesh_sources.clear()
	_morph_meshes.clear()
	_obj_topology.clear()
	_anim = null
	_anim_checked = false
	var models: int = 0
	if FileAccess.file_exists(MANIFEST_PATH):
		var parsed = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST_PATH))
		if parsed is Dictionary and parsed.has("models"):
			for m in (parsed["models"] as Array):
				var sid := str(m.get("sid", ""))
				var bb = m.get("bbox", [])
				if sid != "" and bb is Array and (bb as Array).size() >= 6:
					_bbox[sid] = bb
				models += 1
	# Asset availability is MEASURED here with ResourceLoader.exists(); actual
	# load() happens lazily in _mesh_info() and is recorded in _mesh_sources.
	var obj_available: int = 0
	for sid in _bbox.keys():
		if ResourceLoader.exists(OBJ_DIR + str(sid) + ".obj"):
			obj_available += 1
	var glb_available: int = 0
	for sid in _bbox.keys():
		if ResourceLoader.exists(GLB_DIR + str(sid) + ".glb"):
			glb_available += 1
	stats = {
		"module": "V7-14 world3d_entities",
		"extends": "Node3D",
		"api": ["bind(game)", "sync(dt)", "add_unit(e)", "add_building(e)",
			"add_resource(n)", "remove(id)"],
		"manifest_sids": models,
		"bbox_sids": _bbox.size(),
		"obj_available": obj_available,
		"glb_available": glb_available,
		"obj_dir": OBJ_DIR,
		"glb_dir": GLB_DIR,
		"tex_dir": TEX_DIR,
		"mesh_sources_loaded": _mesh_sources,
		"batch_capacity": BATCH_CAPACITY,
		"batches": 0,
		"units": 0,
		"buildings": 0,
		"resources": 0,
		"axis": "Z-up to Y-up baked: (x,y,z) -> (x,z,-y); V7-2 section 4.1",
		"scale": "bbox height; units/buildings s=1, env uses envscales.cfg, field exempt; V7-2 4.1/1.1/2.3",
		"animation": ANIM_STATUS,
		# V7-74 donor morph telemetry (structural/numeric, NOT a visual claim).
		"donor_morph_api": "anim3d.gd.pose_for(e, action, t) -> pose['verts'] (V764 report section 4)",
		"donor_morph_label": PORT_LABEL,
		"donor_morph_visual": "UNVERIFIED",
		"donor_morph_rig": "BLOCKED_RIG - flat root only, donor bone parents unreadable (V7-2 Table B1)",
		"donor_morph_coord": "donor Z-up metres -> bbox/Y-up; vertex i == assets/models/obj/<sid>.obj vertex i",
		"donor_morph_action_map": MORPH_ACTION_MAP,
		"donor_morph_normals": "generated from morphed donor faces (donor .oss emits positions only); tangents unset - UNVERIFIED",
		"no_2d_sprite_sheets": true,
		"tile_m": TILE_M,
		# V7-65 donor tint telemetry (measured, not a visual-parity claim).
		"donor_key_colors_path": KEY_COLORS_PATH,
		"donor_key_colors_loaded": _key_colors_loaded,
		"donor_key_colors_slots": _key_colors.size(),
		"donor_key_colors_error": _key_colors_error,
		"donor_tint_mapping": "player slot index -> donor gKeyColor slot (identity; mercenary slot 12); NOT nation",
		"donor_tint_target": "StandardMaterial3D.albedo_color (uniform-0 analogue, multiplicative over donor albedo texture)",
		"donor_tint_alpha": 1.0,
		"donor_tint_unverified": "uniform-0 operation, alpha and >1.0 clamp are UNVERIFIED (V7-61 §5; AUDIT3D-02 Q3)",
	}
	push_warning("world3d_entities: " + ANIM_STATUS)


# ---------------------------------------------------------------- mesh loading
func _first_mesh(n: Node) -> Mesh:
	if n is MeshInstance3D:
		var mi := n as MeshInstance3D
		if mi.mesh != null:
			return mi.mesh
	for c in n.get_children():
		var m := _first_mesh(c)
		if m != null:
			return m
	return null


func _env_group(sid: String) -> String:
	if sid.begins_with("mine"):
		return "mine"
	if sid.begins_with("rock") or sid == "stone":
		return "stone"
	if sid.begins_with("tree"):
		return "tree"
	return ""


func _default_material(sid: String, kind: String) -> Material:
	var mat := StandardMaterial3D.new()
	var tex_path := TEX_DIR + sid + ".png"
	if ResourceLoader.exists(tex_path):
		var tex := load(tex_path) as Texture2D
		if tex != null:
			mat.albedo_texture = tex
	mat.roughness = 1.0
	mat.metallic = 0.0
	# Donor env PNGs are RGBA (V7-2 section 2.3). Cut-out is a PORT
	# APPROXIMATION: donor GLB alphaMode is UNVERIFIED (V7-2 Table B1).
	if kind == "res" and sid != "field":
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
		mat.alpha_scissor_threshold = 0.5
	# The OBJ importer keeps donor winding; disable culling so a convention
	# mismatch cannot make a whole silhouette disappear (V7-2 4.1 warns not
	# to double-swap winding).
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	return mat


# --- V7-65 donor player-slot key colours -----------------------------------
# Loads res://data/donor_key_colors.json (V7-61) at runtime. On ANY failure it
# pushes an error and leaves bodies UNTINTED: no invented fallback palette is
# ever substituted. rgb_godot_float is the exact donor formula output; alpha
# 1.0 is an explicit port choice (donor alpha UNVERIFIED).
func _load_key_colors() -> void:
	_key_colors.clear()
	_key_colors_loaded = false
	_key_colors_error = ""
	if not FileAccess.file_exists(KEY_COLORS_PATH):
		_key_colors_error = "missing file " + KEY_COLORS_PATH
		push_error("world3d_entities: donor key colours unavailable (" + _key_colors_error + "); bodies left UNTINTED - no fallback palette")
		return
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(KEY_COLORS_PATH))
	if not (parsed is Dictionary) or not (parsed as Dictionary).has("slots") \
			or not ((parsed as Dictionary)["slots"] is Array):
		_key_colors_error = "malformed JSON or missing slots array"
		push_error("world3d_entities: donor key colours unavailable (" + _key_colors_error + "); bodies left UNTINTED - no fallback palette")
		return
	for entry in ((parsed as Dictionary)["slots"] as Array):
		if not (entry is Dictionary):
			continue
		var d := entry as Dictionary
		var idx := int(d.get("index", -1))
		var rgb = d.get("rgb_godot_float", [])
		if idx < 0 or not (rgb is Array) or (rgb as Array).size() < 3:
			continue
		var arr = rgb
		var c := Color(float(arr[0]), float(arr[1]), float(arr[2]), 1.0)
		if _key_colors.size() <= idx:
			_key_colors.resize(idx + 1)
		_key_colors[idx] = c
	_key_colors_loaded = _key_colors.size() > 0
	if not _key_colors_loaded:
		_key_colors_error = "no usable slot entries"
		push_error("world3d_entities: donor key colours unavailable (" + _key_colors_error + "); bodies left UNTINTED - no fallback palette")


# Donor guard misc.script:5070: only 0 <= colorInd < gc_MaxColorCount (13) is
# applied. Anything else returns null = no tint, never a made-up colour.
func _player_tint(player: int) -> Variant:
	if not _key_colors_loaded or player < 0 or player >= _key_colors.size():
		return null
	return _key_colors[player]


func _player_index(ed: Dictionary) -> int:
	var pv = ed.get("player", -1)
	if pv is int:
		return int(pv)
	if pv is float:
		return int(pv)
	return -1


# Clone a surface material and set albedo_color to the donor key colour. The
# donor albedo TEXTURE is preserved (surface_get_material comes from the same
# donor-derived material), matching "tint on top of albedo" from V7-61 §6.5.
func _tinted_material(base: Material, tint: Color, sid: String, kind: String) -> Material:
	var dup = base.duplicate() if base != null else null
	var m: Material = dup as Material
	if m == null:
		m = _default_material(sid, kind)
	if m is StandardMaterial3D:
		(m as StandardMaterial3D).albedo_color = tint
	else:
		push_warning("world3d_entities: non-Standard material for " + sid + " cannot carry donor uniform-0 tint")
	return m


# Per-instance tint, still sharing the baked donor mesh.
# Godot 4: MultiMeshInstance3D derives from GeometryInstance3D, NOT from
# MeshInstance3D, so it has no set_surface_override_material(). Use the
# GeometryInstance3D.material_override on batches (built from the donor
# albedo material of surface 0, so the donor texture is kept) and the normal
# surface overrides on building MeshInstance3Ds. One override per batch means
# the player slot is part of the batch key (see add_unit), as batching allows.
func _apply_tint(instance: GeometryInstance3D, mesh: Mesh, tint: Color,
		sid: String, kind: String) -> void:
	if mesh == null:
		return
	if instance is MultiMeshInstance3D:
		var base: Material = null
		if mesh.get_surface_count() > 0:
			base = mesh.surface_get_material(0)
		instance.material_override = _tinted_material(base, tint, sid, kind)
		return
	if instance is MeshInstance3D:
		for s in range(mesh.get_surface_count()):
			var base_m: Material = mesh.surface_get_material(s)
			(instance as MeshInstance3D).set_surface_override_material(
				s, _tinted_material(base_m, tint, sid, kind))


# Box sized from the donor bbox. Used only when neither OBJ nor GLB exists.
# Its geometry is still donor-BBOX-DERIVED, never an invented size.
func _proxy_mesh_raw(bbox: Array) -> Mesh:
	if bbox.size() < 6:
		bbox = [-0.5, 0.5, -0.5, 0.5, 0.0, 1.0]
	var x0 := float(bbox[0]); var x1 := float(bbox[1])
	var y0 := float(bbox[2]); var y1 := float(bbox[3])
	var z0 := float(bbox[4]); var z1 := float(bbox[5])
	var box := BoxMesh.new()
	box.size = Vector3(maxf(x1 - x0, 0.05), maxf(y1 - y0, 0.05), maxf(z1 - z0, 0.05))
	var src: Array = box.surface_get_arrays(0)
	var verts: PackedVector3Array = src[Mesh.ARRAY_VERTEX]
	var centre := Vector3((x0 + x1) * 0.5, (y0 + y1) * 0.5, (z0 + z1) * 0.5)
	for i in range(verts.size()):
		verts[i] += centre
	var dst: Array = []
	dst.resize(Mesh.ARRAY_MAX)
	for i in range(Mesh.ARRAY_MAX):
		dst[i] = src[i] if i < src.size() else null
	dst[Mesh.ARRAY_VERTEX] = verts
	var out := ArrayMesh.new()
	out.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, dst)
	return out


# Bake Z-up -> Y-up, bbox centring and bbox-derived scale into a cached mesh.
func _bake_mesh(src_mesh: Mesh, bbox: Array, scale: float, target_h: float,
		pre_normalised: bool, sid: String, kind: String) -> Dictionary:
	if pre_normalised:
		# V7-8 GLB is expected to be exported Y-up and bbox-normalised already.
		# That is an UNVERIFIED assumption until T-V72-1; recorded in stats.
		return {"mesh": src_mesh, "source": "glb_assumed_yup",
			"scale": scale, "height": target_h}
	if bbox.size() < 6:
		bbox = [-0.5, 0.5, -0.5, 0.5, 0.0, 1.0]
	var cx := (float(bbox[0]) + float(bbox[1])) * 0.5
	var cy := (float(bbox[2]) + float(bbox[3])) * 0.5
	var z0 := float(bbox[4])
	var out := ArrayMesh.new()
	for s in range(src_mesh.get_surface_count()):
		var src: Array = src_mesh.surface_get_arrays(s)
		var dst: Array = []
		dst.resize(Mesh.ARRAY_MAX)
		for i in range(Mesh.ARRAY_MAX):
			dst[i] = src[i] if i < src.size() else null
		var vs = src[Mesh.ARRAY_VERTEX]
		if vs is PackedVector3Array:
			var nv := PackedVector3Array()
			nv.resize((vs as PackedVector3Array).size())
			for i in range((vs as PackedVector3Array).size()):
				var v: Vector3 = (vs as PackedVector3Array)[i]
				nv[i] = Vector3((v.x - cx) * scale,
					(v.z - z0) * scale,
					-(v.y - cy) * scale)
			dst[Mesh.ARRAY_VERTEX] = nv
		var ns = src[Mesh.ARRAY_NORMAL]
		if ns is PackedVector3Array:
			var nn := PackedVector3Array()
			nn.resize((ns as PackedVector3Array).size())
			for i in range((ns as PackedVector3Array).size()):
				var n: Vector3 = (ns as PackedVector3Array)[i]
				nn[i] = Vector3(n.x, n.z, -n.y).normalized()
			dst[Mesh.ARRAY_NORMAL] = nn
		var ts = src[Mesh.ARRAY_TANGENT]
		if ts is PackedFloat32Array:
			var nt := PackedFloat32Array()
			nt.resize((ts as PackedFloat32Array).size())
			for i in range(0, (ts as PackedFloat32Array).size(), 4):
				nt[i] = (ts as PackedFloat32Array)[i]
				nt[i + 1] = (ts as PackedFloat32Array)[i + 2]
				nt[i + 2] = -(ts as PackedFloat32Array)[i + 1]
				nt[i + 3] = (ts as PackedFloat32Array)[i + 3]
			dst[Mesh.ARRAY_TANGENT] = nt
		out.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, dst)
		var mat: Material = src_mesh.surface_get_material(s)
		if mat == null:
			mat = _default_material(sid, kind)
		out.surface_set_material(out.get_surface_count() - 1, mat)
	return {"mesh": out, "source": "converted", "scale": scale,
		"height": target_h}


func _mesh_info(sid: String, kind: String) -> Dictionary:
	var key := kind + "|" + sid
	if _mesh_cache.has(key):
		return _mesh_cache[key]
	var bbox: Array = _bbox.get(sid, [])
	var native_h: float = 1.0
	if bbox.size() >= 6:
		native_h = float(bbox[5]) - float(bbox[4])
	if native_h <= 0.0:
		native_h = 1.0
	# bbox-derived scale. Env scale is the donor per-instance multiplier, not
	# a new size guess; field is exempt (ground patch caveat, V7-2 2.3).
	var factor: float = 1.0
	if kind == "res":
		factor = float(ENV_SCALE.get(_env_group(sid), 1.0))
	var target_h: float = native_h * factor
	var scale: float = target_h / native_h
	var src_mesh: Mesh = null
	var pre_normalised := false
	var source := "donor_bbox_proxy"
	var glb := GLB_DIR + sid + ".glb"
	if ResourceLoader.exists(glb):
		var packed = load(glb)
		if packed is PackedScene:
			var inst: Node = (packed as PackedScene).instantiate()
			src_mesh = _first_mesh(inst)
			inst.free()
		elif packed is Mesh:
			src_mesh = packed as Mesh
		if src_mesh != null:
			pre_normalised = true
			source = "glb_assumed_yup"
	var obj := OBJ_DIR + sid + ".obj"
	if src_mesh == null and ResourceLoader.exists(obj):
		src_mesh = load(obj) as Mesh
		if src_mesh != null:
			source = "obj_zup_bbox_normalised"
	if src_mesh == null:
		src_mesh = _proxy_mesh_raw(bbox)
	var info := _bake_mesh(src_mesh, bbox, scale, target_h, pre_normalised, sid, kind)
	info["source"] = source
	info["sid"] = sid       # V7-65: needed by per-player material cloning
	info["kind"] = kind
	_mesh_cache[key] = info
	_mesh_sources[source] = int(_mesh_sources.get(source, 0)) + 1
	stats["mesh_sources_loaded"] = _mesh_sources
	return info


# ---------------------------------------------------------------- V7-74 morph
# The anim module is a SIBLING of this module under world3d.gd (both are
# add_child'd at world3d.gd:152-165). Discover it once by its handoff methods;
# never fabricate pose data when it is absent (atomic stub tests, shipped
# runtime without a registered skin).
func _find_anim():
	if _anim != null and is_instance_valid(_anim):
		return _anim
	if _anim_checked:
		return null
	_anim_checked = true
	var parent := get_parent()
	if parent == null:
		return null
	for child in parent.get_children():
		if child == self:
			continue
		if child.has_method("pose_for") and child.has_method("has_skin"):
			_anim = child
			break
	return _anim


# PORT-LEVEL state -> donor AAF name policy, NOT a donor statement. All three
# names exist in anim3d.gd AAF_ACTIONS (:64 idle, :66 walk, :67 death) and are
# taken from data/animations/aaf/peaukr.aaf:3-5. The sim fields are the same
# ones the 2D renderer reads (t_entities3d.gd:118/124, game.gd entities).
# No keyframe is invented: the actual frame and verts come from pose_for().
func _unit_action(ed: Dictionary) -> String:
	if bool(ed.get("dead", false)):
		return "death"
	if bool(ed.get("moving", false)):
		return "walk"
	return "idle"


# Parse the DONOR-CONVERTED OBJ (convert_models.py:43-66, :109-125) once per
# sid. Its vertex i is the donor .oss vertex i == pose vert i (V764 section 4),
# and its f/vt rows are the donor faces/UVs. The Godot importer may de-index
# and reorder vertices (measured: 719 imported vs 577 donor for peasant), so
# this source topology - not the imported buffer - is the shared index space.
func _load_obj_topology(sid: String) -> Dictionary:
	if _obj_topology.has(sid):
		return _obj_topology[sid]
	var result: Dictionary = {"verts": [], "uvs": [], "tris": []}
	var path := OBJ_DIR + sid + ".obj"
	if not FileAccess.file_exists(path):
		_obj_topology[sid] = result
		return result
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		_obj_topology[sid] = result
		return result
	var vv: Array = []
	var uu: Array = []
	var tt: Array = []
	while not f.eof_reached():
		var line := f.get_line().strip_edges()
		if line.begins_with("v "):
			var p := line.split(" ", false)
			if p.size() >= 4:
				vv.append(Vector3(float(p[1]), float(p[2]), float(p[3])))
		elif line.begins_with("vt "):
			var p := line.split(" ", false)
			if p.size() >= 3:
				uu.append(Vector2(float(p[1]), float(p[2])))
		elif line.begins_with("f "):
			var corners: Array = []
			var p := line.split(" ", false)
			for token in p.slice(1):
				var sub := token.split("/", false)
				if sub.is_empty():
					continue
				var vi: int = int(sub[0]) - 1
				var ui: int = int(sub[1]) - 1 if sub.size() > 1 and sub[1] != "" else -1
				corners.append([vi, ui])
			# Fan-triangulate any non-triangle face (this donor OBJ is all tris).
			for j in range(1, corners.size() - 1):
				tt.append([corners[0], corners[j], corners[j + 1]])
	f.close()
	result = {"verts": vv, "uvs": uu, "tris": tt}
	_obj_topology[sid] = result
	return result


# Rebuild the mesh from donor flat-root verts + donor OBJ topology using the
# EXACT transform of _bake_mesh (:341-360): (x-cx, z-z0, -(y-cy)) * scale.
# On any structural mismatch return no mesh and the caller keeps the static
# bind pose - never a filled/guessed vertex. Normals are generated from the
# morphed donor geometry (the donor skin emits positions only); UVs keep the
# donor vt values with the standard Godot V flip, both UNVERIFIED vs a render.
func _morph_mesh(sid: String, info: Dictionary, frame: int, action: String,
		verts: PackedVector3Array) -> Dictionary:
	var key := sid + "|" + action + "|f" + str(frame)
	if _morph_meshes.has(key):
		return _morph_meshes[key]
	var result: Dictionary = {"mesh": null, "reason": ""}
	var base := info.get("mesh") as Mesh
	if base == null or base.get_surface_count() < 1 or verts.is_empty():
		result["reason"] = "no source mesh or empty donor verts"
		_morph_meshes[key] = result
		return result
	var topo: Dictionary = _load_obj_topology(sid)
	var bind_verts: Array = topo.get("verts", [])
	var uvs: Array = topo.get("uvs", [])
	var tris: Array = topo.get("tris", [])
	if bind_verts.is_empty() or tris.is_empty() or bind_verts.size() != verts.size():
		result["reason"] = "no donor OBJ topology or vertex count mismatch: obj=%d donor=%d" % [bind_verts.size(), verts.size()]
		_morph_meshes[key] = result
		return result
	var bbox: Array = _bbox.get(sid, [])
	var cx := 0.0
	var cy := 0.0
	var z0 := 0.0
	if bbox.size() >= 6:
		cx = (float(bbox[0]) + float(bbox[1])) * 0.5
		cy = (float(bbox[2]) + float(bbox[3])) * 0.5
		z0 = float(bbox[4])
	var sc := float(info.get("scale", 1.0))
	var out_v := PackedVector3Array()
	var out_uv := PackedVector2Array()
	var out_idx := PackedInt32Array()
	var corner_map: Dictionary = {}
	for tri in tris:
		for corner in tri:
			var vi: int = int(corner[0])
			var ui: int = int(corner[1])
			if vi < 0 or vi >= verts.size():
				result["reason"] = "OBJ face index out of range: %d" % vi
				_morph_meshes[key] = result
				return result
			var ck := str(vi) + "," + str(ui)
			var ni: int = int(corner_map.get(ck, -1))
			if ni < 0:
				ni = out_v.size()
				corner_map[ck] = ni
				var mv: Vector3 = verts[vi]
				out_v.append(Vector3((mv.x - cx) * sc, (mv.z - z0) * sc, -(mv.y - cy) * sc))
				if ui >= 0 and ui < uvs.size():
					var uv: Vector2 = uvs[ui]
					out_uv.append(Vector2(uv.x, 1.0 - uv.y))
				else:
					out_uv.append(Vector2.ZERO)
			out_idx.append(ni)
	var dst: Array = []
	dst.resize(Mesh.ARRAY_MAX)
	for i in range(Mesh.ARRAY_MAX):
		dst[i] = null
	dst[Mesh.ARRAY_VERTEX] = out_v
	dst[Mesh.ARRAY_TEX_UV] = out_uv
	dst[Mesh.ARRAY_INDEX] = out_idx
	# ArrayMesh has no generate_normals() in Godot 4.7; accumulate face normals
	# from the morphed donor geometry (no donor normals exist in the .oss).
	var norms := PackedVector3Array()
	norms.resize(out_v.size())
	for i in range(0, out_idx.size(), 3):
		var i0: int = out_idx[i]
		var i1: int = out_idx[i + 1]
		var i2: int = out_idx[i + 2]
		var a: Vector3 = out_v[i0]
		var b: Vector3 = out_v[i1]
		var c: Vector3 = out_v[i2]
		var n: Vector3 = (b - a).cross(c - a)
		norms[i0] += n
		norms[i1] += n
		norms[i2] += n
	for i in range(norms.size()):
		norms[i] = norms[i].normalized()
	dst[Mesh.ARRAY_NORMAL] = norms
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, dst)
	var mat: Material = base.surface_get_material(0)
	if mat == null:
		mat = _default_material(sid, "unit")
	mesh.surface_set_material(0, mat)
	result = {"mesh": mesh, "frame": frame, "action": action,
		"verts": out_v.size(), "source": "donor_flat_root_morph",
		"coord": "donor Z-up -> bbox/Y-up (V764 section 4)",
		"label": PORT_LABEL, "visual": "UNVERIFIED"}
	_morph_meshes[key] = result
	return result


# ---------------------------------------------------------------- batching
func _new_batch(key: String, info: Dictionary, cls: String,
		pose: Dictionary = {}) -> Dictionary:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = info["mesh"]
	mm.instance_count = BATCH_CAPACITY
	mm.visible_instance_count = 0
	var mmi := MultiMeshInstance3D.new()
	var is_morph: bool = not pose.is_empty()
	var tag := "MORPH_a" + str(pose.get("action", "?")) + "_f" + str(pose.get("frame", -1)) \
		if is_morph else "STATIC_POSE"
	mmi.name = "Batch_" + key.replace("|", "_") + "_" + tag
	mmi.set_meta("anim_status", ANIM_STATUS)
	mmi.set_meta("mesh_source", str(info.get("source", "?")))
	if is_morph:
		mmi.set_meta("donor_pose_source", MORPH_POSE_SOURCE)
		mmi.set_meta("donor_frame", int(pose.get("frame", -1)))
		mmi.set_meta("donor_action", str(pose.get("action", "")))
		mmi.set_meta("donor_label", PORT_LABEL)
		mmi.set_meta("donor_visual", "UNVERIFIED")
	mmi.multimesh = mm
	add_child(mmi)
	# xforms is a CPU mirror. Headless Godot 4.7 dummy RenderingServer makes
	# MultiMesh.get_instance_transform() return identity for every slot, so a
	# mirror is needed for O(1) swap-removal and headless verification.
	return {"node": mmi, "mm": mm, "ids": [], "xforms": [], "class": cls,
		"key": key, "morph": is_morph}


# V7-65: `tint` / `player` are INTERNAL batching-key extensions only; the six
# public signatures are unchanged. Resources pass tint=null and stay untinted.
func _acquire(key: String, id: int, info: Dictionary, cls: String,
		tint: Variant = null, player: int = -1,
		pose: Dictionary = {}) -> int:
	var b = _batches.get(key)
	if not (b is Dictionary):
		b = _new_batch(key, info, cls, pose)
		_batches[key] = b
		(b as Dictionary)["tint"] = tint
		(b as Dictionary)["player"] = player
		if tint is Color:
			_apply_tint((b as Dictionary)["node"], info["mesh"], tint,
				str(info.get("sid", "")), str(info.get("kind", cls)))
	var ids: Array = b["ids"]
	if ids.size() >= BATCH_CAPACITY:
		push_warning("world3d_entities: batch full " + key + " (cap " + str(BATCH_CAPACITY) + ")")
		return -1
	var ix: int = ids.size()
	ids.append(id)
	(b as Dictionary)["xforms"].append(Transform3D())
	# Keep tint/player/pose on the slot so a frame change can re-acquire the
	# matching batch without re-reading sim state or guessing a key.
	_slot[id] = {"key": key, "index": ix, "class": cls, "tint": tint,
		"player": player, "pose_source": str(pose.get("pose_source", "static_bind_pose")),
		"frame": int(pose.get("frame", -1)), "action": str(pose.get("action", ""))}
	var mm: MultiMesh = b["mm"]
	mm.visible_instance_count = ids.size()
	return ix


func _release(id: int) -> void:
	var sl = _slot.get(id)
	if not (sl is Dictionary):
		return
	var key := str((sl as Dictionary).get("key", ""))
	var b = _batches.get(key)
	if not (b is Dictionary):
		_slot.erase(id)
		return
	var ids: Array = (b as Dictionary)["ids"]
	var mm: MultiMesh = (b as Dictionary)["mm"]
	var xforms: Array = (b as Dictionary)["xforms"]
	var ix: int = int((sl as Dictionary).get("index", 0))
	var last: int = ids.size() - 1
	if ix >= 0 and last >= 0:
		if ix != last:
			# swap-remove keeps the instance array dense; O(1) removal.
			# Use the CPU mirror, not MultiMesh.get_instance_transform()
			# (identity under the headless dummy RenderingServer).
			var xf: Transform3D = xforms[last]
			xforms[ix] = xf
			mm.set_instance_transform(ix, xf)
			var moved = ids[last]
			ids[ix] = moved
			if _slot.has(moved):
				(_slot[moved] as Dictionary)["index"] = ix
		ids.pop_back()
		mm.visible_instance_count = ids.size()
		# An empty STATIC batch has no reason to keep a node/draw call alive;
		# free it synchronously so same-frame node counts return to baseline.
		# V7-74: keep EMPTY MORPH batches alive so a unit oscillating between
		# donor frames reuses the node instead of free/create churn; they draw
		# nothing (visible_instance_count == 0) and are bounded by visited frames.
		if ids.is_empty() and not bool((b as Dictionary).get("morph", false)):
			var node = (b as Dictionary).get("node")
			if is_instance_valid(node):
				(node as Node).free()
			_batches.erase(key)
	_slot.erase(id)


# ---------------------------------------------------------------- coordinates
func _world_pos(p: Vector2) -> Vector3:
	var w := MAP_DEFAULT
	var h := MAP_DEFAULT
	if game != null:
		# RefCounted stubs in atomic tests return null for unknown properties;
		# float(null) is an invalid constructor in GDScript 4.7.
		var wv = game.get("MAP_W")
		var hv = game.get("MAP_H")
		if wv != null:
			w = float(wv)
		if hv != null:
			h = float(hv)
	if w <= 0.0:
		w = MAP_DEFAULT
	if h <= 0.0:
		h = MAP_DEFAULT
	var y := 0.0
	if game != null and game.has_method("height_at"):
		y = float(game.call("height_at", p))
	return Vector3(p.x - w * 0.5 * TILE_M, y, p.y - h * 0.5 * TILE_M)


func _is_hidden(e: Dictionary) -> bool:
	if bool(e.get("dead", false)) or bool(e.get("hidden", false)):
		return true
	if str(e.get("kind", "")) == "res":
		# Mirrors world.gd:2712-2713: permanent ore nodes (max_hits == 0)
		# stay visible; exhausted finite nodes do not.
		if int(e.get("hits", 0)) <= 0 and int(e.get("max_hits", 0)) != 0 \
				and str(e.get("type", "")) != "stump" and str(e.get("type", "")) != "food":
			return true
	return false


func _xf(id: int) -> Transform3D:
	var e = _refs.get(id)
	if not (e is Dictionary):
		return Transform3D()
	var ed := e as Dictionary
	var p: Vector2 = ed.get("pos", Vector2.ZERO)
	var yaw := 0.0
	var sl = _slot.get(id)
	if sl is Dictionary and str((sl as Dictionary).get("class", "")) == "unit":
		# PORT APPROXIMATION: donor yaw is a renderer transform (V7-2 3.3.3;
		# V7-1 C4: zero turn actions in 246 .aaf). Sim face is in the same
		# X/Y ground space, so map it to XZ with a negative Y rotation.
		yaw = -float(ed.get("face", 0.0))
	var s := HIDDEN_SCALE if _is_hidden(ed) else 1.0
	var basis := Basis().rotated(Vector3.UP, yaw).scaled(Vector3(s, s, s))
	return Transform3D(basis, _world_pos(p))


# ---------------------------------------------------------------- public API
func add_unit(e) -> void:
	if e == null or game == null:
		return
	var ed := e as Dictionary
	var id := int(ed.get("id", -1))
	if id < 0:
		return
	_refs[id] = ed
	if _slot.has(id):
		return
	var sid := str(ed.get("sid", ""))
	var info := _mesh_info(sid, "unit")
	var player: int = _player_index(ed)
	# Explicit Variant type: `:=` from a Variant-returning helper is an
	# INFERRED_DECLARATION warning, which this project treats as an error.
	var tint: Variant = _player_tint(player)
	var key := "unit|" + sid
	if tint is Color:
		# Internal batch-key extension: one MultiMesh per (sid, player slot).
		# Without this, two players' units would share one material/tint.
		key += "|p" + str(player)
	var ix := _acquire(key, id, info, "unit", tint, player)
	if ix >= 0:
		var b: Dictionary = _batches[key]
		var xf := _xf(id)
		(b["xforms"] as Array)[ix] = xf
		(b["mm"] as MultiMesh).set_instance_transform(ix, xf)


func add_building(e) -> void:
	if e == null or game == null:
		return
	var ed := e as Dictionary
	var id := int(ed.get("id", -1))
	if id < 0 or _nodes.has(id):
		return
	_refs[id] = ed
	var sid := str(ed.get("sid", ""))
	var info := _mesh_info(sid, "building")
	var mi := MeshInstance3D.new()
	mi.name = "Building_" + sid + "_" + str(id) + "_STATIC_POSE"
	mi.mesh = info["mesh"]
	mi.set_meta("anim_status", ANIM_STATUS)
	mi.set_meta("mesh_source", str(info.get("source", "?")))
	# V7-65: per-building tint (each building owns its own MeshInstance3D, so
	# no batching-key change is needed here; surface overrides keep siblings
	# of other players independent while sharing the baked donor mesh).
	var player: int = _player_index(ed)
	# Explicit Variant type (see add_unit): `:=` here is a treated-as-error warning.
	var tint: Variant = _player_tint(player)
	if tint is Color:
		_apply_tint(mi, info["mesh"], tint, sid, "building")
		mi.set_meta("donor_tint_slot", player)
		mi.set_meta("donor_tint_rgb", [tint.r, tint.g, tint.b])
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(mi)
	_nodes[id] = mi
	mi.transform = _xf(id)


func _resource_sid(ty: String, pos: Vector2) -> String:
	match ty:
		"wood":
			return _pick_sid(POOL_TREE, pos)
		"stone":
			return _pick_sid(POOL_ROCK, pos)
		"gold", "iron", "coal":
			return "mine_" + ty
		"food":
			return "field"
		"bush":
			return _pick_sid(POOL_BUSH, pos)
		"stump":
			return _pick_sid(POOL_STUMP, pos)
	return ""


# Deterministic choice by world position, never RNG (owner: "No RNG").
func _pick_sid(pool: Array, pos: Vector2) -> String:
	if pool.is_empty():
		return ""
	var ix: int = (int(absf(pos.x) * 10.0) * 7 + int(absf(pos.y) * 10.0) * 13) % pool.size()
	return str(pool[ix])


func add_resource(n) -> void:
	if n == null or game == null:
		return
	var nd := n as Dictionary
	var id := int(nd.get("id", -1))
	if id < 0:
		return
	_refs[id] = nd
	if _slot.has(id):
		return
	var ty := str(nd.get("type", ""))
	var sid := _resource_sid(ty, nd.get("pos", Vector2.ZERO))
	if sid == "":
		sid = "__proxy_" + ty           # no donor sid: bbox proxy, tagged in stats
	var info := _mesh_info(sid, "res")
	var key := "res|" + sid
	var ix := _acquire(key, id, info, "res")
	if ix >= 0:
		var b: Dictionary = _batches[key]
		var xf := _xf(id)
		(b["xforms"] as Array)[ix] = xf
		(b["mm"] as MultiMesh).set_instance_transform(ix, xf)


func remove(id) -> void:
	var eid := int(id)
	if _slot.has(eid):
		_release(eid)
	if _nodes.has(eid):
		var mi = _nodes[eid]
		if is_instance_valid(mi):
			# free(), not queue_free(): callers/tests can count nodes in the
			# same frame as remove(); a deferred free would leave a ghost node.
			mi.free()
		_nodes.erase(eid)
	_refs.erase(eid)


func sync(dt: float) -> void:
	# V7-74: the sim clock drives a deterministic donor AAF frame through
	# anim3d.gd.pose_for() (donor 30 fps, fposmod loop - anim3d.gd:514-520).
	# No RNG, no sprite sheet, no invented keyframe. With no anim module or no
	# registered donor skin this is exactly the V7-14/V7-65 static bind path.
	_anim_t += maxf(dt, 0.0)
	var anim = _find_anim()
	var morph_units := 0
	var static_units := 0
	var frame_changes := 0
	var pose_sources: Dictionary = {}
	var seen_frames: Dictionary = {}
	var morph_rejects: Dictionary = {}
	# Pass 1: sample the donor pose per unit and migrate it to a frame-keyed
	# (sid, player, action, frame) batch when a real donor morph is available.
	for id in _slot.keys():
		var sl = _slot[id]
		if not (sl is Dictionary):
			continue
		if str((sl as Dictionary).get("class", "")) != "unit":
			continue
		var e = _refs.get(int(id))
		if not (e is Dictionary):
			continue
		var ed := e as Dictionary
		var sid := str(ed.get("sid", ""))
		var old_key := str((sl as Dictionary).get("key", ""))
		var action := _unit_action(ed)
		var pose: Dictionary = {}
		var morphed: Dictionary = {}
		if anim != null and anim.has_method("pose_for") \
				and bool(anim.call("has_skin", sid)):
			var p = anim.call("pose_for", ed, action, _anim_t)
			if p is Dictionary:
				pose = p as Dictionary
				var verts = pose.get("verts", null)
				if verts is PackedVector3Array and not (verts as PackedVector3Array).is_empty() \
						and str(pose.get("pose_source", "")) == MORPH_POSE_SOURCE:
					var info: Dictionary = _mesh_info(sid, "unit")
					morphed = _morph_mesh(sid, info, int(pose.get("frame", -1)),
						action, verts as PackedVector3Array)
					if morphed["mesh"] == null:
						var why := str(morphed.get("reason", "?"))
						morph_rejects[why] = int(morph_rejects.get(why, 0)) + 1
		if morphed.has("mesh") and morphed["mesh"] != null:
			var tint = (sl as Dictionary).get("tint", null)
			var player := int((sl as Dictionary).get("player", -1))
			var new_key := "unit|" + sid
			if tint is Color:
				new_key += "|p" + str(player)
			new_key += "|a" + action + "|f" + str(int(pose.get("frame", -1)))
			if new_key != old_key:
				_release(int(id))
				var pose_info: Dictionary = {"mesh": morphed["mesh"],
					"source": "donor_flat_root_morph", "sid": sid, "kind": "unit",
					"scale": float((_mesh_info(sid, "unit")).get("scale", 1.0))}
				_acquire(new_key, int(id), pose_info, "unit", tint, player, pose)
				frame_changes += 1
			pose_sources[MORPH_POSE_SOURCE] = int(pose_sources.get(MORPH_POSE_SOURCE, 0)) + 1
			seen_frames[int(pose.get("frame", -1))] = true
			morph_units += 1
		else:
			static_units += 1
	# Pass 2: unchanged transform contract for morphed, static and resource slots.
	for id in _slot.keys():
		var sl = _slot[id]
		if not (sl is Dictionary):
			continue
		var b = _batches.get(str((sl as Dictionary).get("key", "")))
		if not (b is Dictionary):
			continue
		var mm: MultiMesh = (b as Dictionary)["mm"]
		var xf := _xf(int(id))
		var ix: int = int((sl as Dictionary).get("index", 0))
		var xforms: Array = (b as Dictionary)["xforms"]
		if ix < xforms.size():
			xforms[ix] = xf
		mm.set_instance_transform(ix, xf)
	for id in _nodes.keys():
		var mi = _nodes[id]
		if is_instance_valid(mi):
			mi.transform = _xf(int(id))
	var units := 0
	var ress := 0
	var tinted_batches := 0
	for key in _batches.keys():
		var bd := _batches[key] as Dictionary
		var cls := str(bd.get("class", ""))
		var n: int = bd["ids"].size()
		if bd.get("tint") is Color:
			tinted_batches += 1
		if cls == "unit":
			units += n
		else:
			ress += n
	var tinted_buildings := 0
	for id in _nodes.keys():
		if (_nodes[id] as Node).has_meta("donor_tint_rgb"):
			tinted_buildings += 1
	stats["tinted_batches"] = tinted_batches
	stats["tinted_buildings"] = tinted_buildings
	stats["batches"] = _batches.size()
	stats["units"] = units
	stats["resources"] = ress
	stats["buildings"] = _nodes.size()
	stats["anim_clock_s"] = _anim_t
	# V7-74 measured morph telemetry (never a visual-parity claim).
	stats["donor_morph_units"] = morph_units
	stats["donor_morph_static_units"] = static_units
	stats["donor_morph_frame_changes"] = frame_changes
	stats["donor_morph_meshes_cached"] = _morph_meshes.size()
	stats["donor_morph_frames"] = seen_frames.keys()
	stats["donor_morph_pose_sources"] = pose_sources
	stats["donor_morph_rejects"] = morph_rejects
	stats["donor_morph_anim_available"] = anim != null
	anim_handoff["applied"] = morph_units > 0
	anim_handoff["morph_units"] = morph_units
	anim_handoff["label"] = PORT_LABEL
	anim_handoff["visual"] = "UNVERIFIED"
