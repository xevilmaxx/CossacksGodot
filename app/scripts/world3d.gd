extends Node3D

# Loaded by terrain3d_sandbox.gd via load() (no class_name: a brand-new global
# class is not in .godot's cache until an editor import, and all Godot launches
# must go through the serialized runner). NEW FILE - world.gd is untouched.
# M0 terrain-only 3D world. NEW FILE - the 2D path (world.gd) is untouched.
# Builds a donor-faithful *block* heightfield: each tile is a flat top quad and
# every steep step gets a real vertical wall quad (donor verticalfront/side).
# All numbers below are documented assumptions; nothing here is claimed to be
# a pixel-exact donor match.

const TILE_M: float = 2.0            # C3Data.TILE_M (read-only reference)
const HEIGHT_SCALE: float = 1.0      # dump height is already in world metres
const WATER_LEVEL: float = -0.25     # C3MapGen.WATER_DEEP
const SIDE_STEP: float = 0.35        # LEGACY dead-band; M0.5 emits walls for ALL dh > SIDE_EPS
const SIDE_EPS: float = 1e-4         # M0.5: any height discontinuity > 0.1 mm gets a wall
const SKIRT_DEPTH_M: float = 0.7     # shallow lip: a deep skirt read as a giant slab face
const SUN_DONOR := Vector3(-0.3447, 0.9387, 0.0)       # light.cfg Position (X,Y,Z; Z-up)
const SUN_LIGHTVEC := Vector3(-0.086, 0.939, 0.0)      # world.gd:818-820 comment, mapped to Y-up

# --- M0.5 ART-PASS TUNABLES (measured, not guessed) -------------------------
# Before M0.5 the 1280x720 shot read 49.7 mean L in the central terrain ROI
# while the donor reads ~75 and the 2D sample ~67.  The donor block textures
# themselves average L 63-75, so the 3D lighting was losing ~30% in sRGB.
# These four constants restore that loss explicitly and are reported in stats.
const EXPOSURE: float = 1.45         # Environment.tonemap_exposure (LINEAR tonemap)
const AMBIENT_ENERGY: float = 1.10   # ambient colour energy (was 1.0)
const SUN_ENERGY: float = 1.7        # donor sun energy (was 2.0)
const EMISSION_MULT: float = 1.0     # constant emission lift so rock striations read
const ALBEDO_GAIN: float = 1.05      # slight albedo multiplier (>1 allowed by Godot)

var stats: Dictionary = {}
var _height_error: float = 0.0
var _n: int = 0
var _water_time: float = 0.0
var _water_mat: ShaderMaterial = null
var _skirt_y: float = -7.0


func _block_names() -> Array:
	var path := "res://assets/terrain/structs/presets_summer.json"
	if not FileAccess.file_exists(path):
		return []
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed if parsed is Array else []


func _albedo(nm: String) -> Material:
	var mat := StandardMaterial3D.new()
	var path := "res://assets/terrain/blocks/%s.png" % nm
	if ResourceLoader.exists(path):
		var tex := load(path) as Texture2D
		if tex != null:
			mat.albedo_texture = tex
	mat.roughness = 1.0
	mat.metallic = 0.0
	# Slight gain so donor's 63-75 L blocks land near the donor's lit 75-100 L
	# once the explicit exposure/ambient pass is applied.
	mat.albedo_color = Color(ALBEDO_GAIN, ALBEDO_GAIN, ALBEDO_GAIN * 0.96, 1.0)
	# The block-heightfield is a thin shell with no underside; disabling cull
	# keeps top faces visible even if a face-winding convention differs.
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.vertex_color_use_as_albedo = false
	# Donor-derived blocks are dark (~70/255); a constant emission lift keeps
	# the albedo legible and lets grey rock striations show on vertical faces.
	mat.emission_enabled = true
	mat.emission = Color(0.10, 0.10, 0.085)
	mat.emission_energy_multiplier = EMISSION_MULT
	return mat


# M0.5: wall faces are seen almost edge-on under a near-vertical sun. With the
# top material they blew out to thin white "seams". A darker, low-emission
# rock material makes them read as shadowed striated cliff faces like the donor.
func _wall_material() -> Material:
	var mat := StandardMaterial3D.new()
	var path := "res://assets/terrain/blocks/rock4.png"
	if ResourceLoader.exists(path):
		var tex := load(path) as Texture2D
		if tex != null:
			mat.albedo_texture = tex
	# M0.6: donor ravine faces are pale striated grey, not near-black. Lighter
	# albedo + a constant emission floor "feathers" the darkest faces so they
	# never read as flat horizontal bands.
	mat.albedo_color = Color(0.95, 0.93, 0.88, 1.0)
	mat.roughness = 1.0
	mat.metallic = 0.0
	# Keep culling DISABLED: with a step wall, the face the camera needs to see
	# depends on which side of the step it is on, and CULL_BACK removed real
	# cliff quads (34,902 px of see-through holes in the mask render). Correct
	# per-face normals now give proper lighting without relying on culling.
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.emission_enabled = true
	mat.emission = Color(0.085, 0.082, 0.075)
	mat.emission_energy_multiplier = 1.0
	return mat


func _record_vertex(verts: Array, norms: Array, uvs: Array,
		p: Vector3, normal: Vector3, uv: Vector2, expected_y: float) -> void:
	verts.append(p)
	norms.append(normal)
	uvs.append(uv)
	_height_error = maxf(_height_error, absf(p.y - expected_y))


func _quad(arrays_group: Dictionary, p0: Vector3, p1: Vector3, p2: Vector3, p3: Vector3,
		normal: Vector3, uv0: Vector2, uv1: Vector2, uv2: Vector2, uv3: Vector2,
		expected: Array, flip: bool = false) -> void:
	var base: int = arrays_group["verts"].size()
	_record_vertex(arrays_group["verts"], arrays_group["norms"], arrays_group["uvs"],
		p0, normal, uv0, expected[0])
	_record_vertex(arrays_group["verts"], arrays_group["norms"], arrays_group["uvs"],
		p1, normal, uv1, expected[1])
	_record_vertex(arrays_group["verts"], arrays_group["norms"], arrays_group["uvs"],
		p2, normal, uv2, expected[2])
	_record_vertex(arrays_group["verts"], arrays_group["norms"], arrays_group["uvs"],
		p3, normal, uv3, expected[3])
	if flip:
		# reversed winding: p0,p2,p1 / p0,p3,p2
		arrays_group["inds"].append_array([base, base + 2, base + 1, base, base + 3, base + 2])
	else:
		# forward winding: p0,p1,p2 / p0,p2,p3
		arrays_group["inds"].append_array([base, base + 1, base + 2, base, base + 2, base + 3])


func _new_group() -> Dictionary:
	return {"verts": [], "norms": [], "uvs": [], "inds": []}


func _min_height(height: PackedFloat32Array) -> float:
	var m: float = INF
	for v in height:
		m = minf(m, v)
	return m


# M0.6: one wall quad along an X-normal edge. `normal` is the direction of the
# EXPOSED face (the side the camera can see) and `flip` gives that face the
# winding that makes it front-facing. Previously every X-wall used +X as its
# normal regardless of which side was exposed; with CULL_BACK that lit half the
# ravine faces from the wrong side and produced flat dark horizontal bands.
func _emit_x_wall(sides: Dictionary, ex: float, wz: float,
		lo: float, hi: float, flip: bool, normal: Vector3) -> void:
	var a := Vector3(ex, lo, wz)
	var b := Vector3(ex, lo, wz + TILE_M)
	var c := Vector3(ex, hi, wz + TILE_M)
	var d := Vector3(ex, hi, wz)
	_quad(sides, a, b, c, d, normal,
		Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1),
		[lo, lo, hi, hi], flip)


# M0.6: one wall quad along a Z-normal edge; `normal` is the exposed face.
func _emit_z_wall(sides: Dictionary, ez: float, wx: float,
		lo: float, hi: float, flip: bool, normal: Vector3) -> void:
	var a := Vector3(wx, lo, ez)
	var b := Vector3(wx + TILE_M, lo, ez)
	var c := Vector3(wx + TILE_M, hi, ez)
	var d := Vector3(wx, hi, ez)
	_quad(sides, a, b, c, d, normal,
		Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1),
		[lo, lo, hi, hi], flip)


func _to_mesh(group: Dictionary, mat: Material, mesh: ArrayMesh) -> void:
	if group["verts"].is_empty():
		return
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array(group["verts"])
	arrays[Mesh.ARRAY_NORMAL] = PackedVector3Array(group["norms"])
	arrays[Mesh.ARRAY_TEX_UV] = PackedVector2Array(group["uvs"])
	arrays[Mesh.ARRAY_INDEX] = PackedInt32Array(group["inds"])
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.surface_set_material(mesh.get_surface_count() - 1, mat)


func build_from_dump(dump: Dictionary, x0: int, y0: int, n: int) -> bool:
	_n = n
	_height_error = 0.0
	var w := int(dump.get("map_w", 0))
	var h := int(dump.get("map_h", 0))
	var raw := Marshalls.base64_to_raw(str(dump.get("height", "")))
	var rawtb := Marshalls.base64_to_raw(str(dump.get("tileblock", "")))
	if w <= 0 or h <= 0 or raw.size() < w * h * 4 or rawtb.size() < w * h:
		push_error("terrain3d: bad dump dimensions")
		return false
	if x0 < 0 or y0 < 0 or x0 + n > w or y0 + n > h:
		push_error("terrain3d: window out of bounds")
		return false

	var names := _block_names()
	var height := PackedFloat32Array()
	height.resize(n * n)
	var tbidx := PackedByteArray()
	tbidx.resize(n * n)
	for z in range(n):
		for x in range(n):
			var src := (y0 + z) * w + (x0 + x)
			height[z * n + x] = raw.decode_float(src * 4)
			tbidx[z * n + x] = rawtb[src]

	# Group top quads by donor TileBlock name -> one material/draw call per name.
	var groups := {}
	var used_names := {}
	for z in range(n):
		for x in range(n):
			var bi := int(tbidx[z * n + x])
			var nm := str(names[bi]) if bi >= 0 and bi < names.size() else "grass1"
			if not groups.has(nm):
				groups[nm] = _new_group()
			used_names[nm] = true
			var y: float = height[z * n + x] * HEIGHT_SCALE
			var wx: float = (float(x) - float(n) * 0.5) * TILE_M
			var wz: float = (float(z) - float(n) * 0.5) * TILE_M
			var p0 := Vector3(wx, y, wz)
			var p1 := Vector3(wx + TILE_M, y, wz)
			var p2 := Vector3(wx + TILE_M, y, wz + TILE_M)
			var p3 := Vector3(wx, y, wz + TILE_M)
			# +Y facing uses reversed winding relative to the p0..p3 ring.
			_quad(groups[nm], p0, p1, p2, p3, Vector3.UP,
				Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1),
				[y, y, y, y], true)

	# M0.5 SEAM FIX. The old code only emitted a wall when |dh| > SIDE_STEP
	# (0.35 m), so sub-0.35 m steps left literal cracks, and the map perimeter
	# had no wall at all. Both let the flat background show through as thin
	# light slivers. Now EVERY discontinuity > SIDE_EPS gets a wall, and every
	# outer edge gets a shallow local lip (a deep global skirt produced a huge
	# black cliff at this dump window's near edge). The distant ground plane
	# sits at _skirt_y, below the whole patch.
	_skirt_y = minf(WATER_LEVEL, _min_height(height) * HEIGHT_SCALE) - SKIRT_DEPTH_M
	var sides := _new_group()       # real cliffs (|dh| > SIDE_STEP): dark rock
	var small := _new_group()       # sub-step cracks: grass, so they vanish visually
	var walls := 0
	var small_walls := 0
	var perimeter := 0
	for z in range(n):
		for x in range(n):
			var ha: float = height[z * n + x] * HEIGHT_SCALE
			var wx: float = (float(x) - float(n) * 0.5) * TILE_M
			var wz: float = (float(z) - float(n) * 0.5) * TILE_M
			# --- +X edge: interior neighbour, or outer skirt on the east border
			if x + 1 < n:
				var hb: float = height[z * n + x + 1] * HEIGHT_SCALE
				if absf(hb - ha) > SIDE_EPS:
					var g: Dictionary = sides if absf(hb - ha) > SIDE_STEP else small
					_emit_x_wall(g, wx + TILE_M, wz, minf(ha, hb), maxf(ha, hb), ha > hb,
						Vector3.RIGHT if ha > hb else Vector3.LEFT)
					if g == sides:
						walls += 1
					else:
						small_walls += 1
			else:
				# Shallow LOCAL lip. A global skirt down to the lowest tile made
				# a 6 m black cliff across the near edge at this dump window
				# (edge heights +0.7..+2.9, min -2.8). Below the lip the distant
				# grass ground simply continues - like a low terrace edge.
				_emit_x_wall(sides, wx + TILE_M, wz, ha - SKIRT_DEPTH_M, ha, true, Vector3.RIGHT)
				walls += 1
				perimeter += 1
			# --- -X edge: outer lip on the west border only
			if x == 0:
				_emit_x_wall(sides, wx, wz, ha - SKIRT_DEPTH_M, ha, false, Vector3.LEFT)
				walls += 1
				perimeter += 1
			# --- +Z edge: interior neighbour, or outer skirt on the north border
			if z + 1 < n:
				var hc: float = height[(z + 1) * n + x] * HEIGHT_SCALE
				if absf(hc - ha) > SIDE_EPS:
					var g: Dictionary = sides if absf(hc - ha) > SIDE_STEP else small
					_emit_z_wall(g, wz + TILE_M, wx, minf(ha, hc), maxf(ha, hc), ha <= hc,
						Vector3.FORWARD if ha > hc else Vector3.BACK)
					if g == sides:
						walls += 1
					else:
						small_walls += 1
			else:
				_emit_z_wall(sides, wz + TILE_M, wx, ha - SKIRT_DEPTH_M, ha, false, Vector3.FORWARD)
				walls += 1
				perimeter += 1
			# --- -Z edge: outer lip on the south border only
			if z == 0:
				_emit_z_wall(sides, wz, wx, ha - SKIRT_DEPTH_M, ha, true, Vector3.BACK)
				walls += 1
				perimeter += 1

	var mesh := ArrayMesh.new()
	var vertex_total := 0
	var triangle_total := 0
	for nm in groups.keys():
		_to_mesh(groups[nm], _albedo(str(nm)), mesh)
		vertex_total += groups[nm]["verts"].size()
		triangle_total += groups[nm]["inds"].size() / 3
	# M0.5: real cliffs use dark striated rock; sub-0.35 m cracks use grass so
	# the seam is closed geometrically but does not read as a black stripe.
	_to_mesh(sides, _wall_material(), mesh)
	vertex_total += sides["verts"].size()
	triangle_total += sides["inds"].size() / 3
	_to_mesh(small, _albedo("grass_ground1"), mesh)
	vertex_total += small["verts"].size()
	triangle_total += small["inds"].size() / 3
	var mi := MeshInstance3D.new()
	mi.name = "TerrainMesh"
	mi.mesh = mesh
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(mi)

	_make_water(height, n)
	_make_environment()

	stats = {
		"dump_window": {"x0": x0, "y0": y0, "n": n},
		"tile_m": TILE_M,
		"height_scale": HEIGHT_SCALE,
		"mesh_vertices": vertex_total,
		"top_surface_vertices": n * n * 4,
		"side_quads": walls,
		"cliff_wall_quads": walls,
		"grass_crack_quads": small_walls,
		"side_vertices": sides["verts"].size() + small["verts"].size(),
		"surfaces": mesh.get_surface_count(),
		"triangles": triangle_total,
		"height_error_max_m": _height_error,
		"block_names": used_names.keys(),
		"water_level_m": WATER_LEVEL,
		"seam_policy": "wall on EVERY |dh|>SIDE_EPS + shallow local edge lip (M0.5)",
		"side_epsilon_m": SIDE_EPS,
		"perimeter_wall_quads": perimeter,
		"skirt_y_m": _skirt_y,
		"art_pass": {
			"exposure": EXPOSURE,
			"tonemap": "LINEAR",
			"ambient_energy": AMBIENT_ENERGY,
			"sun_energy": SUN_ENERGY,
			"emission_mult": EMISSION_MULT,
			"albedo_gain": ALBEDO_GAIN,
			"background": "ProceduralSky + distant grass ground plane",
		},
	}
	return true


func _make_water(height: PackedFloat32Array, n: int) -> void:
	var img := Image.create(n, n, false, Image.FORMAT_RGBA8)
	for z in range(n):
		for x in range(n):
			var d: float = WATER_LEVEL - height[z * n + x]
			var cov: float = 1.0 if d > 0.0 else 0.0
			var coast: float = clampf(d / 0.57, 0.0, 1.0)
			var deep: float = clampf(d / 1.07, 0.0, 1.0)
			img.set_pixel(x, z, Color(cov, deep, coast, 1.0))
	var tex := ImageTexture.create_from_image(img)
	# Filtering is requested by the shader uniform hint (filter_linear).

	var sh := Shader.new()
	sh.code = """
shader_type spatial;
render_mode blend_mix, depth_draw_never, cull_back;
// Spatial port of the port's canvas_item water tint (water_overlay.gdshader):
// same WATERCOLOR / WATERCOLOR2 / 2.2 body gain / coast->deep mix. No screen
// texture and no refraction (Compatibility); alpha uses donor resalpha.
uniform sampler2D mask : repeat_enable, filter_linear;
uniform float time;
// M0.5: donor slate water. Old WATERCOLOR (0.56,0.65,0.60)*2.2 clipped to a
// bright mint that read as "light-blue slivers" in the capture; the donor's
// water is a deep desaturated slate. Keep the spatial mask+swell, drop gain,
// and fade alpha at the shore (m.b = normalised depth) instead of a hard edge.
const vec3 WATERCOLOR = vec3(0.19, 0.245, 0.255);
const vec3 WATERCOLOR2 = vec3(0.050, 0.065, 0.080);
void fragment() {
    vec4 m = texture(mask, UV);
    float coverage = m.r;
    if (coverage < 0.001) discard;
    vec3 col = mix(WATERCOLOR, WATERCOLOR2, smoothstep(0.0, 1.0, m.g));
    float swell = sin(UV.x * 42.0 + time * 0.6) + sin(UV.y * 57.0 - time * 0.4);
    col *= 1.15 * (0.93 + 0.05 * swell);
    float shore = smoothstep(0.0, 0.32, m.b);
    ALBEDO = clamp(col, 0.0, 1.0);
    ALPHA = coverage * (0.28 + 0.72 * shore);   // subtle shoreline fade
}
"""
	_water_mat = ShaderMaterial.new()
	_water_mat.shader = sh
	_water_mat.set_shader_parameter("mask", tex)
	_water_mat.set_shader_parameter("time", 0.0)

	var half: float = float(n) * TILE_M * 0.5
	var wmesh := ArrayMesh.new()
	var v := PackedVector3Array([
		Vector3(-half, WATER_LEVEL, -half), Vector3(half, WATER_LEVEL, -half),
		Vector3(half, WATER_LEVEL, half), Vector3(-half, WATER_LEVEL, half)])
	var uv := PackedVector2Array([Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)])
	var ind := PackedInt32Array([0, 3, 1, 1, 3, 2])
	var arr := []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = v
	arr[Mesh.ARRAY_TEX_UV] = uv
	arr[Mesh.ARRAY_INDEX] = ind
	wmesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	var wmi := MeshInstance3D.new()
	wmi.name = "WaterPlane"
	wmi.mesh = wmesh
	wmi.material_override = _water_mat
	add_child(wmi)


func _make_environment() -> void:
	var env := Environment.new()
	# M0.5 SKY: the patch was a floating island in flat grey-green. A procedural
	# sky plus a distant grass plane below gives the terrain a horizon/context.
	env.background_mode = Environment.BG_SKY
	env.background_color = Color(0.62, 0.70, 0.66)  # fallback if sky is unavailable
	var sky := Sky.new()
	var skymat := ProceduralSkyMaterial.new()
	skymat.sky_top_color = Color(0.18, 0.30, 0.42)
	skymat.sky_horizon_color = Color(0.36, 0.44, 0.38)
	skymat.sky_curve = 0.18
	skymat.ground_bottom_color = Color(0.09, 0.12, 0.07)
	skymat.ground_horizon_color = Color(0.17, 0.22, 0.14)
	skymat.ground_curve = 0.10
	skymat.sun_angle_max = 18.0
	sky.sky_material = skymat
	env.sky = sky

	# M0.5 EXPOSURE/TONEMAP: donor blocks are L 63-75 but the un-tonemapped 3D
	# shot read 49.7. An explicit LINEAR tonemap exposure + stronger ambient
	# lifts lit grass toward the donor's L 75-100 and reveals rock striations.
	# Godot 4.7 renamed the enum to TONE_MAPPER_*; LINEAR is value 0 and simply
	# applies tonemap_exposure without a filmic curve (verified via API probe).
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
	sun.directional_shadow_max_distance = 220.0
	# light.cfg Position (-0.3447,0.9387,0) -> donor lightVector (-0.086,0,0.939)
	# (Z-up, world.gd:818-820) -> Godot Y-up (-0.086,0.939,0).
	# The donor sun is almost straight up, so look_at up=+Y is degenerate here;
	# use +Z as the look-at up axis for a well-defined rotation.
	var sun_pos := SUN_LIGHTVEC.normalized() * 90.0
	sun.look_at_from_position(sun_pos, Vector3.ZERO, Vector3.FORWARD)
	add_child(sun)

	_make_distant_ground()


# M0.5: a wide grass plane just below the perimeter skirt so the patch reads
# as a piece of a larger landmass instead of a tile quilt in an empty void.
func _make_distant_ground() -> void:
	var pm := PlaneMesh.new()
	pm.size = Vector2(1600.0, 1600.0)
	var gp := MeshInstance3D.new()
	gp.name = "DistantGround"
	gp.mesh = pm
	# Godot 4.7 Texture2D has no repeat_mode property; tiling is explicit in a
	# tiny spatial shader with a repeat_enable sampler hint (same pattern the
	# water shader uses). This avoids depending on the PNG import flags.
	var sh := Shader.new()
	sh.code = """
shader_type spatial;
render_mode unshaded;
uniform sampler2D ground_tex : repeat_enable, filter_linear;
uniform vec3 tint = vec3(0.92, 0.92, 0.88);
void fragment() {
    vec3 c = texture(ground_tex, UV * 120.0).rgb;
    // Unshaded so the surrounding land stays at donor grass brightness
    // (the lit version blew out to L~185 against an L~75 patch).
    ALBEDO = clamp(c * tint, 0.0, 1.0);
}
"""
	var gmat := ShaderMaterial.new()
	gmat.shader = sh
	var path := "res://assets/terrain/blocks/grass_ground1.png"
	if ResourceLoader.exists(path):
		var src := load(path) as Texture2D
		if src != null:
			gmat.set_shader_parameter("ground_tex", src)
	gmat.set_shader_parameter("tint", Vector3(0.92, 0.92, 0.88))
	gp.material_override = gmat
	gp.position.y = _skirt_y - 0.1
	add_child(gp)


func _process(delta: float) -> void:
	_water_time += delta
	if _water_mat != null:
		_water_mat.set_shader_parameter("time", _water_time)
