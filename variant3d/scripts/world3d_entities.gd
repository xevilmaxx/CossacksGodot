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
# ANIMATION HANDOFF (explicit, not a silent fallback)
#   Donor .oss carries per-bone tracks but NO parent hierarchy, so a
#   donor-faithful skin cannot be built from readable data
#   (V7-2 sections 3.3 / 4.3, Table B1 BLOCKED; data/actors/units/peaukr.oss
#   layout at docs/decomp/DC_FORMATS.md:46-64, evidence ev_392885a6...).
#   This module therefore renders a STATIC BIND POSE only. Every batch/node is
#   tagged with `anim_status`; the anim3d.gd agent (V7-3 contract line 17)
#   must replace/augment these with sampled pose meshes or a donor-backed rig.
#   A missing mesh gets a bbox-sized box proxy, also tagged; it is a
#   placeholder, not donor fidelity.

const OBJ_DIR: String = "res://assets/models/obj/"
const GLB_DIR: String = "res://assets/models/glb/"
const TEX_DIR: String = "res://assets/models/tex/"
const MANIFEST_PATH: String = "res://assets/models/manifest.json"

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

const ANIM_STATUS: String = "STATIC BIND POSE - PORT APPROXIMATION - NOT DONOR PARITY (V7-2 3.3/4.3 Table B1: .oss bone parents unreadable; hand off to anim3d.gd)"

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


# ---------------------------------------------------------------- bind / stats
func bind(g) -> void:
	game = g
	_bbox.clear()
	_mesh_cache.clear()
	_mesh_sources.clear()
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
		"no_2d_sprite_sheets": true,
		"tile_m": TILE_M,
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
	_mesh_cache[key] = info
	_mesh_sources[source] = int(_mesh_sources.get(source, 0)) + 1
	stats["mesh_sources_loaded"] = _mesh_sources
	return info


# ---------------------------------------------------------------- batching
func _new_batch(key: String, info: Dictionary, cls: String) -> Dictionary:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = info["mesh"]
	mm.instance_count = BATCH_CAPACITY
	mm.visible_instance_count = 0
	var mmi := MultiMeshInstance3D.new()
	mmi.name = "Batch_" + key.replace("|", "_") + "_STATIC_POSE"
	mmi.set_meta("anim_status", ANIM_STATUS)
	mmi.set_meta("mesh_source", str(info.get("source", "?")))
	mmi.multimesh = mm
	add_child(mmi)
	# xforms is a CPU mirror. Headless Godot 4.7 dummy RenderingServer makes
	# MultiMesh.get_instance_transform() return identity for every slot, so a
	# mirror is needed for O(1) swap-removal and headless verification.
	return {"node": mmi, "mm": mm, "ids": [], "xforms": [], "class": cls, "key": key}


func _acquire(key: String, id: int, info: Dictionary, cls: String) -> int:
	var b = _batches.get(key)
	if not (b is Dictionary):
		b = _new_batch(key, info, cls)
		_batches[key] = b
	var ids: Array = b["ids"]
	if ids.size() >= BATCH_CAPACITY:
		push_warning("world3d_entities: batch full " + key + " (cap " + str(BATCH_CAPACITY) + ")")
		return -1
	var ix: int = ids.size()
	ids.append(id)
	(b as Dictionary)["xforms"].append(Transform3D())
	_slot[id] = {"key": key, "index": ix, "class": cls}
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
		# An empty batch has no reason to keep a node/draw call alive; free it
		# synchronously so same-frame node counts return to baseline. The baked
		# mesh stays cached in _mesh_cache for a cheap later re-create.
		if ids.is_empty():
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
	var key := "unit|" + sid
	var ix := _acquire(key, id, info, "unit")
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
	# Static bind pose: dt only feeds the anim3d handoff clock, no mesh morph.
	_anim_t += maxf(dt, 0.0)
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
	for key in _batches.keys():
		var cls := str((_batches[key] as Dictionary).get("class", ""))
		var n: int = (_batches[key] as Dictionary)["ids"].size()
		if cls == "unit":
			units += n
		else:
			ress += n
	stats["batches"] = _batches.size()
	stats["units"] = units
	stats["resources"] = ress
	stats["buildings"] = _nodes.size()
	stats["anim_clock_s"] = _anim_t
	anim_handoff["applied"] = false
