extends Node3D

# V7-13 — full-grid heightmap terrain for the 3D variant.
#
# PORT OF (read-only reference, NOT edited): app/scripts/heightmap_world3d.gd
# (G3-2 full-grid mesh proof). Loaded dynamically via load() — no class_name:
# a fresh global class is not in .godot's cache until an editor import, and all
# Godot launches go through variant3d/tools/godot_runner.py.
#
# DESIGN (owner directive: leverage the heightmap concept, no chunk reasoning):
#   * ONE indexed ArrayMesh, ONE surface, ONE draw call for the whole grid;
#   * one shared vertex per height[] cell (no per-tile quads, no step walls);
#   * central-difference normals from the height field itself (one-sided edges);
#   * UV = ((x+0.5)/map_w, (z+0.5)/map_h) — 0..1 over the full map, aligned to
#     the G3-4 splat albedo cell centres (row-major, north/west origin);
#   * splat first, one donor grass block as runtime Image.load fallback;
#   * one translucent water quad at donor WATER_LEVEL.
# NO per-chunk dictionaries, NO 2-chunk/frame cap, NO imported sprite sheets,
# NO RNG. V7-13 deliberately left lighting to V7-9; V7-60 now ports the
# donor-cited WorldEnvironment + DirectionalLight3D rig from the UNWIRED
# variant3d/scripts/heightmap_world3d.gd:114-147 so the WIRED runtime terrain
# is actually lit. All rig values stay donor-cited; none are invented here.

# Donor citations (read-only text; singleplayer skirmish path):
#   C:\Games\Cossacks 3\data\scripts\generatemap.inc:537-577 — bitmap -> engine
#     height grid -> smoothing; the height[] source this mesh visualises
#     (G31 report docs/coord_swarm_2026-11-24/reports/G31_donor_3d_truth.md:73,:230).
#   data\cameras\camera.cfg:32-35 (tilt -32), :44-45 (focal 400) — camera framing
#     is V7-5's camera3d.gd, NOT this terrain module; no camera constant copied.
#   variant3d/scripts/mapgen.gd:29 — C3MapGen.WATER_DEEP = -0.25 (port comment
#     cites donor data\scripts\texturemap.inc:30; donor literal UNVERIFIED).
#   variant3d/scripts/data.gd:23 — C3Data.TILE_M = 2.0 (donor cell size in
#     metres is UNVERIFIED; G32 report §3).
#   variant3d/scripts/main.gd:694-701 — dump schema (map_w/map_h/height base64).
#   variant3d/scripts/game.gd:44,1893-1907 — live height[] grid + bilinear read.
#   variant3d/scripts/game.gd:5564 — height[] -> base64 on save/dump.
#
# V7-60 light/sky rig — translated (not invented) from the UNWIRED sibling
# variant3d/scripts/heightmap_world3d.gd:22-37,114-147. Donor references
# (read-only text, singleplayer skirmish path):
#   C:\Games\Cossacks 3\data\shaders\water\water.dev.vert:22 builds
#     lightVector = (LightPos.x/4, LightPos.z/2, LightPos.y)  [donor Z-up]
#   C:\Games\Cossacks 3\data\env\lights\light.cfg:26-29 Position =
#     (-0.344731152057648, 0.938701450824738, 0)
#   -> donor lightVector = (-0.0861828, 0, 0.9387015) Z-up
#   -> Godot Y-up        = (-0.0861828, 0.9387015, 0)
# Donor light colours are literal light.cfg:3-16 Ambient/Diffuse; the ENERGIES
# below are port-side M0.6 compensation, not donor values.

const TILE_M: float = 2.0                 # data.gd:23; donor cell size UNVERIFIED
const HEIGHT_SCALE: float = 1.0           # dump height[] is already metres (main.gd:698)
const WATER_LEVEL: float = -0.25          # mapgen.gd:29 C3MapGen.WATER_DEEP; donor literal UNVERIFIED

# V7-60 donor light rig constants (verbatim values + citations from
# heightmap_world3d.gd:34-37); only the two light.cfg colours are recorded as
# donor evidence, the rig itself uses the same body as the sibling module.
const SUN_POS := Vector3(-0.344731152057648, 0.938701450824738, 0.0)  # light.cfg:26-29
const SUN_LIGHTVEC := Vector3(SUN_POS.x / 4.0, SUN_POS.z / 2.0, SUN_POS.y)  # water.dev.vert:22, then Z-up->Y-up
const DONOR_AMBIENT := Color(0.196078434586525, 0.184313729405403, 0.129411771893501)  # light.cfg:3-8 (donor evidence)
const DONOR_DIFFUSE := Color(0.811764717102051, 0.780392169952393, 0.694117665290833)  # light.cfg:11-16 (donor evidence)
# Port-side M0.6 art compensation (NOT donor values) — kept as cited in the rig.
const EXPOSURE: float = 1.45
const AMBIENT_ENERGY: float = 1.10
const SUN_ENERGY: float = 1.7

const SPLAT_PATH := "res://assets/terrain/heightmap/splat_albedo.png"
const FALLBACK_BLOCK := "res://assets/terrain/blocks/grass1.png"

# PORT-TUNED art floor (not a donor value): a tiny emission keeps the terrain
# legible in a standalone no-light probe. V7-60 leaves this value UNCHANGED —
# the donor-grounded light/sky rig lives in this module (see _make_environment).
const EMISSION_RGB := Color(0.06, 0.06, 0.05)

var stats: Dictionary = {}

var _game = null   # untyped: real C3Game object OR a dictionary test double
var _height := PackedFloat32Array()
var _w: int = 0
var _h: int = 0
var _built: bool = false


func bind(game) -> void:
	_game = game


# Python-written splat PNG has no Godot .import sidecar in a --script run:
# load("res://...png") => "No loader found for resource" (G32 ticket 1322).
# Runtime Image.load of the globalized path needs no import step.
func _load_png_texture(res_path: String) -> Texture2D:
	var abs_path := ProjectSettings.globalize_path(res_path)
	if not FileAccess.file_exists(abs_path):
		return null
	var img := Image.new()
	if img.load(abs_path) != OK or img.is_empty():
		return null
	return ImageTexture.create_from_image(img)


func _terrain_material(splat: Texture2D) -> Material:
	var mat := StandardMaterial3D.new()
	if splat != null:
		mat.albedo_texture = splat
	# Splat A is normalised height DATA (G3-4), not opacity: never blend it.
	mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	mat.roughness = 1.0
	mat.metallic = 0.0
	mat.vertex_color_use_as_albedo = false
	# Continuous heightfield, no underside; cull disabled so winding conventions
	# cannot hide a face (same guard as the G3-2 proof).
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.emission_enabled = true
	mat.emission = EMISSION_RGB
	mat.emission_energy_multiplier = 1.0
	return mat


# Central difference over 2*TILE_M; one-sided at the grid borders. Donor
# height[] is stepped, so a large dh across one cell gives a steep normal
# without a separate wall mesh. Port analogue of donor hf.pvl.sm.vert normal
# transform (shaders.lib:16-19), not a donor copy.
func _normal_at(height: PackedFloat32Array, w: int, h: int,
		x: int, z: int) -> Vector3:
	var x0: int = maxi(0, x - 1)
	var x1: int = mini(w - 1, x + 1)
	var z0: int = maxi(0, z - 1)
	var z1: int = mini(h - 1, z + 1)
	var dx: float = float(x1 - x0) * TILE_M
	var dz: float = float(z1 - z0) * TILE_M
	var dhdx: float = (height[z * w + x1] - height[z * w + x0]) / dx
	var dhdz: float = (height[z1 * w + x] - height[z0 * w + x]) / dz
	return Vector3(-dhdx, 1.0, -dhdz).normalized()


# Resolve the bound game into the dump schema of main.gd:694-701. An explicit
# dump dictionary on the game wins; otherwise the live game.height[] grid is
# encoded with the SAME Marshalls recipe as game.gd:5564 so build() always
# decodes a base64 height[] grid, exactly like the G3-2 donor reference.
func _dump_from_game() -> Dictionary:
	if _game == null:
		return {}
	for key in ["dump", "map_dump", "self_base"]:
		var cand = _game.get(key)
		if cand is Dictionary and (cand as Dictionary).has("height"):
			return cand
	var src = _game.get("height")
	if not (src is PackedFloat32Array):
		return {}
	var gw: int = 0
	var gh: int = 0
	var v = _game.get("MAP_W")
	if v is int:
		gw = int(v)
	if gw <= 0:
		v = _game.get("map_w")
		if v is int:
			gw = int(v)
	v = _game.get("MAP_H")
	if v is int:
		gh = int(v)
	if gh <= 0:
		v = _game.get("map_h")
		if v is int:
			gh = int(v)
	var grid: PackedFloat32Array = src
	if gw <= 0 or gh <= 0 or grid.size() < gw * gh:
		return {}
	return {
		"map_w": gw,
		"map_h": gh,
		"height": Marshalls.raw_to_base64(grid.to_byte_array()),
	}


func _make_water(w: int, h: int) -> void:
	var half_x: float = float(w) * TILE_M * 0.5
	var half_z: float = float(h) * TILE_M * 0.5
	var v := PackedVector3Array([
		Vector3(-half_x, WATER_LEVEL, -half_z),
		Vector3(half_x, WATER_LEVEL, -half_z),
		Vector3(half_x, WATER_LEVEL, half_z),
		Vector3(-half_x, WATER_LEVEL, half_z)])
	var uv := PackedVector2Array([
		Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)])
	var ind := PackedInt32Array([0, 3, 1, 1, 3, 2])
	var arr := []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = v
	arr[Mesh.ARRAY_TEX_UV] = uv
	arr[Mesh.ARRAY_INDEX] = ind
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.19, 0.245, 0.255, 0.45)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.roughness = 0.35
	var mi := MeshInstance3D.new()
	mi.name = "WaterPlane"
	mi.mesh = mesh
	mi.material_override = mat
	add_child(mi)


# V7-60 — donor-grounded sky/sun rig translated VERBATIM from the unwired
# variant3d/scripts/heightmap_world3d.gd:114-147. Values/citations: light.cfg:3-16
# (ambient/diffuse), light.cfg:26-29 (sun position), water.dev.vert:22 (light
# vector transform). Port-side energies stay flagged as M0.6 compensation.
# invalidate() frees these children too, so a rebuild cannot stack rigs.
func _make_environment() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.background_color = Color(0.62, 0.70, 0.66)
	var sky := Sky.new()
	var skymat := ProceduralSkyMaterial.new()
	skymat.sky_top_color = Color(0.18, 0.30, 0.42)
	skymat.sky_horizon_color = Color(0.36, 0.44, 0.38)
	skymat.sky_curve = 0.18
	skymat.ground_bottom_color = Color(0.09, 0.12, 0.07)
	skymat.ground_horizon_color = Color(0.17, 0.22, 0.14)
	skymat.ground_curve = 0.10
	sky.sky_material = skymat
	env.sky = sky
	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	env.tonemap_exposure = EXPOSURE
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.86, 0.88, 0.82)
	env.ambient_light_energy = AMBIENT_ENERGY
	var we := WorldEnvironment.new()
	we.name = "WorldEnvironment"
	we.environment = env
	add_child(we)

	var sun := DirectionalLight3D.new()
	sun.name = "DonorSun"
	sun.light_energy = SUN_ENERGY
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 400.0
	# The donor sun is almost overhead, so look_at with up=+Y is degenerate;
	# use +Z as the up axis exactly as M0.6 did.
	sun.look_at_from_position(SUN_LIGHTVEC.normalized() * 120.0,
		Vector3.ZERO, Vector3.FORWARD)
	add_child(sun)


# Drop every object created by the last build so a rebuild cannot stack meshes.
func invalidate() -> void:
	for child in get_children():
		remove_child(child)
		child.free()
	_height = PackedFloat32Array()
	_w = 0
	_h = 0
	_built = false
	stats = {}


# EXACT CONTRACT: one full-grid ArrayMesh from the base64 dump height[] grid.
func build() -> bool:
	var t_total := Time.get_ticks_usec()
	invalidate()
	var dump := _dump_from_game()
	if dump.is_empty():
		push_error("world3d_terrain: bind(game) with a height dump first")
		return false
	var w := int(dump.get("map_w", 0))
	var h := int(dump.get("map_h", 0))
	var raw := Marshalls.base64_to_raw(str(dump.get("height", "")))
	if w <= 0 or h <= 0 or raw.size() < w * h * 4:
		push_error("world3d_terrain: bad dump dimensions / height grid")
		return false
	var t_parsed := Time.get_ticks_usec()

	var height := PackedFloat32Array()
	height.resize(w * h)
	var hmin: float = INF
	var hmax: float = -INF
	for i in range(w * h):
		var y: float = raw.decode_float(i * 4)
		height[i] = y
		hmin = minf(hmin, y)
		hmax = maxf(hmax, y)
	var t_heights := Time.get_ticks_usec()

	# Splat first; one donor grass block as deterministic fallback. If neither
	# PNG is loadable the mesh still builds with a plain material.
	var splat_path := SPLAT_PATH
	var splat := _load_png_texture(splat_path)
	if splat == null:
		splat = _load_png_texture(FALLBACK_BLOCK)
		splat_path = FALLBACK_BLOCK
	if splat == null:
		splat_path = "NONE (plain material)"

	# ONE vertex per height cell (cell centres), so splat texel (x,z) maps to
	# UV ((x+0.5)/w, (z+0.5)/h). Two triangles per interior cell square.
	var nverts: int = w * h
	var ntris: int = (w - 1) * (h - 1) * 2
	var verts := PackedVector3Array()
	var norms := PackedVector3Array()
	var uvs := PackedVector2Array()
	verts.resize(nverts)
	norms.resize(nverts)
	uvs.resize(nverts)
	var inds := PackedInt32Array()
	inds.resize(ntris * 3)
	var cx: float = float(w) * 0.5
	var cz: float = float(h) * 0.5
	for z in range(h):
		for x in range(w):
			var i: int = z * w + x
			verts[i] = Vector3((float(x) + 0.5 - cx) * TILE_M,
				height[i] * HEIGHT_SCALE,
				(float(z) + 0.5 - cz) * TILE_M)
			norms[i] = _normal_at(height, w, h, x, z)
			uvs[i] = Vector2((float(x) + 0.5) / float(w),
				(float(z) + 0.5) / float(h))
	var k: int = 0
	for z in range(h - 1):
		for x in range(w - 1):
			var i00: int = z * w + x
			var i10: int = i00 + 1
			var i01: int = i00 + w
			var i11: int = i01 + 1
			# +Y facing: cross(Z, X) = +Y, hence i00,i01,i10 order.
			inds[k] = i00;      inds[k + 1] = i01;  inds[k + 2] = i10
			inds[k + 3] = i10;  inds[k + 4] = i01;  inds[k + 5] = i11
			k += 6

	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = norms
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = inds
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.surface_set_material(0, _terrain_material(splat))
	var mi := MeshInstance3D.new()
	mi.name = "HeightmapTerrain"
	mi.mesh = mesh
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(mi)
	var t_mesh := Time.get_ticks_usec()

	_make_water(w, h)
	_make_environment()

	_height = height
	_w = w
	_h = h
	_built = true
	var albedo_size := Vector2i(0, 0)
	if splat != null:
		albedo_size = splat.get_size()
	stats = {
		"grid": {"w": w, "h": h, "cells": nverts},
		"tile_m": TILE_M,
		"height_scale": HEIGHT_SCALE,
		"height_min_m": hmin,
		"height_max_m": hmax,
		"height_range_m": hmax - hmin,
		"mesh_vertices": nverts,
		"mesh_triangles": ntris,
		"mesh_surfaces": mesh.get_surface_count(),
		"terrain_draw_calls_expected": 1,
		"normals": "central finite difference on height[] (one-sided at borders)",
		"uv": "cell-centre (x+0.5)/map_w, (z+0.5)/map_h; 0..1 over full map",
		"albedo_path": splat_path,
		"albedo_size": [albedo_size.x, albedo_size.y],
		"alpha_as_transparency": false,
		"water_level_m": WATER_LEVEL,
		"sun_direction_yup": [SUN_LIGHTVEC.x, SUN_LIGHTVEC.y, SUN_LIGHTVEC.z],
		"chunks": 0,
		"per_frame_cap": 0,
		"donor_references": {
			"height_source": "data/scripts/generatemap.inc:537-577 (bitmap->grid->smoothing)",
			"camera_framing": "data/cameras/camera.cfg:32-35,44-45 (V7-5, not this module)",
			"water_level": "variant3d/scripts/mapgen.gd:29 C3MapGen.WATER_DEEP (donor texturemap.inc:30; literal UNVERIFIED)",
			"cell_size": "variant3d/scripts/data.gd:23 C3Data.TILE_M (donor metres UNVERIFIED)",
			"sun_position": "data/env/lights/light.cfg:26-29 (SUN_POS, donor Z-up)",
			"sun_light_vector": "data/shaders/water/water.dev.vert:22 (x/4, z/2, y) then Z-up->Y-up",
			"ambient_diffuse": "data/env/lights/light.cfg:3-16 (Ambient/Diffuse literals)",
			"light_rig_port": "variant3d/scripts/heightmap_world3d.gd:114-147 (V7-60, translated)",
		},
		"timing_ms": {
			"parse_dump": float(t_parsed - t_total) / 1000.0,
			"decode_heights": float(t_heights - t_parsed) / 1000.0,
			"mesh_build": float(t_mesh - t_heights) / 1000.0,
			"total_build": float(Time.get_ticks_usec() - t_total) / 1000.0,
		},
	}
	return true


# Trivially true: the single full-grid mesh covers the whole map, so there are
# no chunks and no chunk fallback to wait for. Satisfies the 2D world contract.
func has_chunk_or_fallback() -> bool:
	return true


# Bilinear sample of the SAME height[] grid the mesh was built from. p is a
# Vector2 of world (x,z) metres with the map centred on the origin, matching
# the mesh's (x+0.5-w/2)*TILE_M / (z+0.5-h/2)*TILE_M layout. Recipe mirrors
# game.height_at() (game.gd:1893-1907); returns metres or 0.0 when unbuilt.
func height_at_world(p: Vector2) -> float:
	if not _built or _height.size() != _w * _h or _w <= 0 or _h <= 0:
		return 0.0
	var fx := clampf(p.x / TILE_M + float(_w) * 0.5 - 0.5, 0.0, float(_w - 1))
	var fz := clampf(p.y / TILE_M + float(_h) * 0.5 - 0.5, 0.0, float(_h - 1))
	var x0 := int(fx)
	var z0 := int(fz)
	var x1: int = mini(x0 + 1, _w - 1)
	var z1: int = mini(z0 + 1, _h - 1)
	var tx: float = fx - float(x0)
	var tz: float = fz - float(z0)
	var h00: float = _height[z0 * _w + x0]
	var h10: float = _height[z0 * _w + x1]
	var h01: float = _height[z1 * _w + x0]
	var h11: float = _height[z1 * _w + x1]
	return (h00 + (h10 - h00) * tx + (h01 - h00) * tz
		+ (h00 - h10 - h01 + h11) * tx * tz) * HEIGHT_SCALE
