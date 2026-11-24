extends Node3D

# G3-2 — ONE full-map heightmap mesh, built from every height[] cell in the dump.
# NEW FILE: world3d.gd / terrain3d_sandbox.gd are untouched. Loaded dynamically
# by heightmap3d_sandbox.gd via load() (no class_name: a new global class is not
# in .godot's cache until an editor import, and all launches go through runner).
#
# DESIGN (owner directive: "leverage heightmap concept", no per-chunk reasoning):
#   * one indexed ArrayMesh, one surface, one draw call for the whole height grid;
#   * shared grid vertices (one per height cell) instead of M0's per-tile quads
#     plus per-step walls;
#   * per-vertex normals from central finite differences of the height field;
#   * UVs = (x+0.5)/w, (z+0.5)/h, i.e. 0..1 over the full map, aligned to the
#     G3-4 splat texture (RGB = donor block albedo, A = normalised height DATA,
#     deliberately NOT transparency);
#   * donor albedo from res://assets/terrain/heightmap/splat_albedo.png, with a
#     single donor grass block as fallback;
#   * one translucent water quad at C3MapGen.WATER_DEEP, donor sun + ambient.
#
# All constants below are read-only donor/port references, not donor copies.

# Donor references (read-only, singleplayer skirmish path):
#   C:\Games\Cossacks 3\data\shaders\water\water.dev.vert:22 builds
#     lightVector = (LightPos.x/4, LightPos.z/2, LightPos.y)  [donor Z-up]
#   C:\Games\Cossacks 3\data\env\lights\light.cfg:26-29 Position =
#     (-0.344731152057648, 0.938701450824738, 0)
#   -> donor lightVector = (-0.0861828, 0, 0.9387015) Z-up
#   -> Godot Y-up        = (-0.0861828, 0.9387015, 0)
# Donor light colours are literal light.cfg:3-16 Ambient/Diffuse; the ENERGIES
# below are port-side M0.6 compensation, not donor values.
const TILE_M: float = 2.0              # C3Data.TILE_M (app/scripts/data.gd:23); donor cell size UNVERIFIED
const HEIGHT_SCALE: float = 1.0        # dump height[] is metres (world3d.gd:12-14, main.gd:692)
const WATER_LEVEL: float = -0.25       # C3MapGen.WATER_DEEP (app/scripts/mapgen.gd:29); donor literal UNVERIFIED
const SUN_POS := Vector3(-0.344731152057648, 0.938701450824738, 0.0)  # light.cfg:26-29
const SUN_LIGHTVEC := Vector3(SUN_POS.x / 4.0, SUN_POS.z / 2.0, SUN_POS.y)  # water.dev.vert:22, then Z-up->Y-up
const DONOR_AMBIENT := Color(0.196078434586525, 0.184313729405403, 0.129411771893501)  # light.cfg:3-8
const DONOR_DIFFUSE := Color(0.811764717102051, 0.780392169952393, 0.694117665290833)  # light.cfg:11-16

const SPLAT_PATH := "res://assets/terrain/heightmap/splat_albedo.png"
const FALLBACK_BLOCK := "res://assets/terrain/blocks/grass1.png"

# Art pass constants inherited from the M0.6 visual review (world3d.gd:24-30).
# They are explicit lifts, not claimed donor fidelity.
const EXPOSURE: float = 1.45
const AMBIENT_ENERGY: float = 1.10
const SUN_ENERGY: float = 1.7
const EMISSION_MULT: float = 1.0
const ALBEDO_GAIN: float = 1.05

var stats: Dictionary = {}


func _terrain_material(splat: Texture2D) -> Material:
	var mat := StandardMaterial3D.new()
	if splat != null:
		mat.albedo_texture = splat
	# A channel of the splat is normalised height DATA, not opacity: keep
	# blending disabled so the height mask is never read as transparency.
	mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	mat.roughness = 1.0
	mat.metallic = 0.0
	mat.albedo_color = Color(ALBEDO_GAIN, ALBEDO_GAIN, ALBEDO_GAIN * 0.96, 1.0)
	# A continuous heightfield has no underside; disable culling so winding
	# conventions cannot hide a face (M0 needed the same guard on step walls).
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.emission_enabled = true
	mat.emission = Color(0.10, 0.10, 0.085)
	mat.emission_energy_multiplier = EMISSION_MULT
	return mat


# Finite-difference normal from the height field itself. Interior cells get a
# central difference over 2*TILE_M; edges use a one-sided difference. Donor
# height[] is a stepped field, so a large dh across one cell produces a steep
# (near-vertical) normal without a separate wall mesh.
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


func _make_water(w: int, h: int) -> void:
	var half_x: float = float(w) * TILE_M * 0.5
	var half_z: float = float(h) * TILE_M * 0.5
	var v := PackedVector3Array([
		Vector3(-half_x, WATER_LEVEL, -half_z),
		Vector3(half_x, WATER_LEVEL, -half_z),
		Vector3(half_x, WATER_LEVEL, half_z),
		Vector3(-half_x, WATER_LEVEL, half_z)])
	var arr := []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = v
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


func build_from_dump(dump: Dictionary) -> bool:
	var t_total := Time.get_ticks_usec()
	var w := int(dump.get("map_w", 0))
	var h := int(dump.get("map_h", 0))
	var raw := Marshalls.base64_to_raw(str(dump.get("height", "")))
	if w <= 0 or h <= 0 or raw.size() < w * h * 4:
		push_error("heightmap_world3d: bad dump dimensions / height grid")
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

	# Albedo: G3-4 splat first (full-map donor-block blends + height in A),
	# single donor grass block as a deterministic fallback.
	var splat_path := SPLAT_PATH
	var splat := load(splat_path) as Texture2D
	if splat == null and ResourceLoader.exists(FALLBACK_BLOCK):
		splat = load(FALLBACK_BLOCK) as Texture2D
		splat_path = FALLBACK_BLOCK
	if splat == null:
		push_error("heightmap_world3d: no albedo texture available")
		return false
	var splat_size: Vector2i = splat.get_size()

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
		"albedo_size": [splat_size.x, splat_size.y],
		"albedo_channels": "RGB = donor block albedo; A = normalised height DATA (not opacity)",
		"alpha_as_transparency": false,
		"water_level_m": WATER_LEVEL,
		"sun_direction_yup": [SUN_LIGHTVEC.x, SUN_LIGHTVEC.y, SUN_LIGHTVEC.z],
		"art_pass": {"exposure": EXPOSURE, "tonemap": "LINEAR",
			"ambient_energy": AMBIENT_ENERGY, "sun_energy": SUN_ENERGY,
			"emission_mult": EMISSION_MULT, "albedo_gain": ALBEDO_GAIN},
		"timing_ms": {
			"parse_dump": float(t_parsed - t_total) / 1000.0,
			"decode_heights": float(t_heights - t_parsed) / 1000.0,
			"mesh_build": float(t_mesh - t_heights) / 1000.0,
			"total_build": float(Time.get_ticks_usec() - t_total) / 1000.0,
		},
	}
	return true
