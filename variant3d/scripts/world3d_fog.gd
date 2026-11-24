extends Node3D

# V7-16 — per-tile fog-of-war shading for the 3D variant.
# Owns ONE file. The 2D path (app/scripts/world.gd) is untouched.
#
# PORT SOURCES (read-only this session, cited):
#   app/scripts/world.gd:27-28       fog_explored / fog_vis PackedByteArray
#   app/scripts/world.gd:333-338     bind() sizes arrays to MAP_W*MAP_H, fog_img fill
#   app/scripts/world.gd:2186-2256   _update_fog(): reveal requests, search radius,
#                                    fog_counts, visible/explored transitions and the
#                                    0.78 / 0.30 / 0.00 black-alpha ladder (:2250-2255)
#   app/scripts/world.gd:2258-2272   tile_visible() / tile_explored()
#   app/scripts/game.gd:2834-2836    reveal_requests + game_reveal(pos, r)
#   variant3d/scripts/game.gd:2834-2836, :3456-3461  same sim API in the 3D project
#   variant3d/scripts/world3d.gd:215-224  centred tile-corner -> world quad mapping
#   variant3d/tests/t_fog3d.gd:37-48,150-184  stub-game shape and structural checks
#
# DONOR SOURCES OF TRUTH (read via evidence reports, NOT re-read here):
#   E19  pvl.smx3.id0.frag:29-43  view-space LINEAR/EXP/EXP2 fog  (RENDER_ARCH_SHADERS.md:150)
#   E20  def.pvl.sm.vert:38-42    fog depth = view-space distance (RENDER_ARCH_SHADERS.md:151)
#   camera.cfg:51-64 DynFog* keys; DynFogDepth=False in game mode (:59)
#        (RENDER_ARCH_CAMERA.md:59-62)
#   V71_mechanics_inventory.md:166 — fog overlay PARTIAL; donor fog<->explored
#        engine binding UNVERIFIED; "do not invent a new fog rule".
#
# HONEST LIMIT: the donor depth fog above is a *view-distance* effect and is
# disabled in the gameplay camera (DynFogDepth=False). The 2D fog-of-war arrays
# are a different mechanic. Their sim state is ported verbatim; the donor's
# binding of that state to any shader is UNVERIFIED, so no donor fog constant
# is fabricated here. The alpha ladder below is the port's own state encoding
# (world.gd:2251-2255), not a claimed donor value.
#
# Rendering: ONE transparent ArrayMesh of per-tile quads with vertex-colour
# alpha, NOT a full-map Sprite2D / ImageTexture (the 2D path at world.gd:337-347).

const Data = preload("res://scripts/data.gd")

# Verbatim from app/scripts/world.gd:2251-2255 (port state encoding).
const ALPHA_UNEXPLORED: float = 0.78
const ALPHA_EXPLORED: float = 0.30
const ALPHA_VISIBLE: float = 0.0
# PORT-SIDE, no donor source: lift the overlay a few cm above the sampled
# terrain height so it does not z-fight with the top quads.
const FOG_Y_OFFSET: float = 0.03

var game = null
# Public: HUD minimap reads these (contract V73_ATOMIC_CONTRACT.md:15,24).
var fog_explored: PackedByteArray = PackedByteArray()
var fog_vis: PackedByteArray = PackedByteArray()
var fog_counts: PackedInt32Array = PackedInt32Array()

var _map_w: int = 0
var _map_h: int = 0
var _tile_m: float = 2.0
var _built: bool = false
var _fog_timer: float = 0.0
var _fog_tick: int = 0
var _fog_last_pos: Dictionary = {}
var _fog_unit_count: int = 0
var _tile_alpha: PackedFloat32Array = PackedFloat32Array()

var _overlay: MeshInstance3D = null
var _overlay_mesh: ArrayMesh = null
var _fog_vertices: PackedVector3Array = PackedVector3Array()
var _fog_uvs: PackedVector2Array = PackedVector2Array()
var _fog_indices: PackedInt32Array = PackedInt32Array()
var _fog_colors: PackedColorArray = PackedColorArray()


func bind(g) -> void:
	game = g
	if game == null:
		return
	_map_w = int(game.get("MAP_W"))
	_map_h = int(game.get("MAP_H"))
	if _map_w <= 0 or _map_h <= 0:
		push_error("world3d_fog: game has no usable MAP_W/MAP_H")
		return
	_tile_m = float(Data.TILE_M)
	var n: int = _map_w * _map_h

	# Mirror game-owned arrays when present and correctly sized (the stub game
	# in t_fog3d.gd:40-48 pre-fills them); otherwise start clean like 2D bind()
	# at world.gd:333-335.
	var src_exp = game.get("fog_explored")
	if src_exp is PackedByteArray and (src_exp as PackedByteArray).size() == n:
		fog_explored = (src_exp as PackedByteArray).duplicate()
	else:
		fog_explored = PackedByteArray()
		fog_explored.resize(n)
	var src_vis = game.get("fog_vis")
	if src_vis is PackedByteArray and (src_vis as PackedByteArray).size() == n:
		fog_vis = (src_vis as PackedByteArray).duplicate()
	else:
		fog_vis = PackedByteArray()
		fog_vis.resize(n)
	fog_counts = PackedInt32Array()
	fog_counts.resize(n)
	_tile_alpha = PackedFloat32Array()
	_tile_alpha.resize(n)

	_fog_timer = float(Data.FOG_INTERVAL)
	_fog_tick = 0
	_fog_last_pos.clear()
	_fog_unit_count = 0
	_built = _build_overlay()
	if not _built:
		return
	for i in n:
		_tile_alpha[i] = _alpha_for(i)
		_set_tile_color(i, _tile_alpha[i])
	_refresh_mesh()
	_update_fog()


func sync(dt: float) -> void:
	if game == null or not _built:
		return
	# 2D gates the recount on FOG_INTERVAL (world.gd:833-836, :336). dt is
	# sim-agnostic; this accumulator keeps the same cadence.
	_fog_timer -= dt
	if _fog_timer > 0.0:
		return
	_fog_timer = float(Data.FOG_INTERVAL)
	_update_fog()


func _alpha_for(i: int) -> float:
	if fog_vis[i] == 1:
		return ALPHA_VISIBLE
	if fog_explored[i] == 1:
		return ALPHA_EXPLORED
	return ALPHA_UNEXPLORED


func _set_tile_color(i: int, a: float) -> void:
	var base: int = i * 4
	if base + 3 >= _fog_colors.size():
		return
	var c := Color(0.0, 0.0, 0.0, a)
	_fog_colors[base] = c
	_fog_colors[base + 1] = c
	_fog_colors[base + 2] = c
	_fog_colors[base + 3] = c


func _make_fog_material() -> ShaderMaterial:
	# Spatial port of the 2D fog overlay: multiply black by per-tile alpha.
	# No donor shader is claimed: donor E19 depth fog is a different effect and
	# is off in the gameplay camera (camera.cfg:59).
	var sh := Shader.new()
	sh.code = """
shader_type spatial;
render_mode blend_mix, unshaded, cull_disabled, depth_draw_never;
// Per-tile fog-of-war tint. COLOR.a is the port's 0.78 / 0.30 / 0.00 ladder
// (app/scripts/world.gd:2251-2255); COLOR.rgb is black. Deliberately NOT a
// port of donor view-depth fog (E19/E20) - that binding is UNVERIFIED.
void fragment() {
	ALBEDO = COLOR.rgb;
	ALPHA = COLOR.a;
}
"""
	var mat := ShaderMaterial.new()
	mat.shader = sh
	return mat


func _build_overlay() -> bool:
	_fog_vertices = PackedVector3Array()
	_fog_uvs = PackedVector2Array()
	_fog_indices = PackedInt32Array()
	_fog_colors = PackedColorArray()
	var n: int = _map_w * _map_h

	# game.height is optional: the t_fog3d.gd stub has no such field. Use a
	# flat y=0 overlay there; in a real game sample the generated height grid
	# (variant3d/scripts/game.gd:44, :364). Alignment with world3d_terrain.gd's
	# dump-derived heights is an OPEN QUESTION (see report).
	var hs = game.get("height")
	var h: PackedFloat32Array = PackedFloat32Array()
	if hs is PackedFloat32Array and (hs as PackedFloat32Array).size() == n:
		h = hs

	for ty in range(_map_h):
		for tx in range(_map_w):
			var i: int = ty * _map_w + tx
			var wy: float = (h[i] if h.size() == n else 0.0) + FOG_Y_OFFSET
			# Centred tile-corner mapping mirrors variant3d/scripts/world3d.gd:215-220.
			var wx: float = (float(tx) - float(_map_w) * 0.5) * _tile_m
			var wz: float = (float(ty) - float(_map_h) * 0.5) * _tile_m
			var base: int = _fog_vertices.size()
			_fog_vertices.append(Vector3(wx, wy, wz))
			_fog_vertices.append(Vector3(wx + _tile_m, wy, wz))
			_fog_vertices.append(Vector3(wx + _tile_m, wy, wz + _tile_m))
			_fog_vertices.append(Vector3(wx, wy, wz + _tile_m))
			_fog_uvs.append(Vector2(0.0, 0.0))
			_fog_uvs.append(Vector2(1.0, 0.0))
			_fog_uvs.append(Vector2(1.0, 1.0))
			_fog_uvs.append(Vector2(0.0, 1.0))
			_fog_indices.append_array([base, base + 2, base + 1, base, base + 3, base + 2])
			var a: float = _alpha_for(i)
			for k in 4:
				_fog_colors.append(Color(0.0, 0.0, 0.0, a))

	_overlay_mesh = ArrayMesh.new()
	_overlay = MeshInstance3D.new()
	_overlay.name = "FogOverlay"
	_overlay.mesh = _overlay_mesh
	_overlay.material_override = _make_fog_material()
	# 2D draws fog above units at world.gd:346 (z_index = 10).
	_overlay.render_priority = 10
	_overlay.visible = bool(Data.FOG_OF_WAR)
	add_child(_overlay)
	return true


func _refresh_mesh() -> void:
	if _overlay_mesh == null or _fog_vertices.is_empty():
		return
	_overlay_mesh.clear_surfaces()
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = _fog_vertices
	arrays[Mesh.ARRAY_TEX_UV] = _fog_uvs
	arrays[Mesh.ARRAY_COLOR] = _fog_colors
	arrays[Mesh.ARRAY_INDEX] = _fog_indices
	_overlay_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)


func _update_fog() -> void:
	if game == null or not _built:
		return
	if not bool(Data.FOG_OF_WAR):
		return
	if not game.has_method("tile_of"):
		return

	# Cheap change gate, structure verbatim from world.gd:2191-2211.
	_fog_tick += 1
	var forced: bool = _fog_tick % 6 == 0
	var reqs = game.get("reveal_requests")
	var has_reveals: bool = reqs is Array and not (reqs as Array).is_empty()
	var any_moved: bool = forced or has_reveals
	if not any_moved:
		var ents = game.get("entities")
		if not (ents is Array):
			return
		var live_n: int = 0
		for e in ents:
			if e.dead or int(e.player) != 0:
				continue
			live_n += 1
			var lp: Vector2 = _fog_last_pos.get(int(e.id), Vector2.INF)
			if lp == Vector2.INF or lp.distance_squared_to(e.pos) > 0.25:
				any_moved = true
				break
		if not any_moved and live_n != _fog_unit_count:
			any_moved = true
	if not any_moved:
		return
	_fog_last_pos.clear()
	var ents2 = game.get("entities")
	if ents2 is Array:
		for e in ents2:
			if e.dead or int(e.player) != 0:
				continue
			_fog_last_pos[int(e.id)] = e.pos
	_fog_unit_count = _fog_last_pos.size()

	# Explicit reveal requests from sim abilities — game.gd:2834-2836,
	# world.gd:2218-2227. game_reveal(Vector2(MAP_W,MAP_H), 1e9) is the
	# "reveal whole map" call at game.gd:3461 and is handled by this same loop.
	if has_reveals:
		for rq in reqs:
			var c: Vector2 = rq.pos
			var rr: float = rq.r
			var t0: Vector2i = game.tile_of(c - Vector2(rr, rr))
			var t1: Vector2i = game.tile_of(c + Vector2(rr, rr))
			for ty in range(maxi(0, t0.y), mini(_map_h, t1.y + 1)):
				for tx in range(maxi(0, t0.x), mini(_map_w, t1.x + 1)):
					# world.gd:2225 uses tx*2+1 (TILE_M=2 tile centre).
					var centre := Vector2((float(tx) + 0.5) * _tile_m, (float(ty) + 0.5) * _tile_m)
					if centre.distance_to(c) <= rr:
						fog_explored[ty * _map_w + tx] = 1
		(reqs as Array).clear()

	fog_counts.fill(0)
	var ents3 = game.get("entities")
	if ents3 is Array:
		for e in ents3:
			if e.dead or e.player != 0:
				continue
			var r: float = e.def.get("search", 24.0) if e.kind == "unit" else e.def.get("radius", 2.0) * 6.0
			var t0: Vector2i = game.tile_of(e.pos - Vector2(r, r))
			var t1: Vector2i = game.tile_of(e.pos + Vector2(r, r))
			for y in range(maxi(0, t0.y), mini(_map_h, t1.y + 1)):
				for x in range(maxi(0, t0.x), mini(_map_w, t1.x + 1)):
					var c := Vector2((float(x) + 0.5) * _tile_m, (float(y) + 0.5) * _tile_m)
					if c.distance_to(e.pos) <= r:
						fog_counts[y * _map_w + x] += 1

	var changed: bool = false
	for i in _map_w * _map_h:
		var v: int = 1 if fog_counts[i] > 0 else 0
		if v == 1:
			fog_explored[i] = 1
		if fog_vis[i] == v:
			continue
		fog_vis[i] = v
		var a: float = _alpha_for(i)
		_tile_alpha[i] = a
		_set_tile_color(i, a)
		changed = true
	if changed:
		if _overlay != null:
			_overlay.visible = bool(Data.FOG_OF_WAR)
		_refresh_mesh()
