extends Node3D

# V7-84 — self-contained donor-grounded 3D water surface.
#
# Owns ONLY this file + variant3d/shaders/water3d.gdshader (per task exclusivity).
# It builds the SAME flat 4-vertex water plane as world3d_terrain.gd:175-202 and
# assigns a ShaderMaterial that ports the shipped donor fragment equations:
#   C:\Games\Cossacks 3\data\shaders\water\water.dev.frag (water.lib:67-68)
# Donor literals (all observed, all read-only):
#   texturemap.inc:29-31  cMaxHeight=2.96, cWaterHeight=-0.25, cWaterShoreHeight=-0.1
#   water.dev.frag:37,42-47,168  0.57, 170, 120, 30, colours, deep fade 1.07
#   water.lib:25,32-33  hdrMultiplier=1, TexScaleS=0.1, TexScaleT=0.01
#
# NO visual parity is claimed. No GPU A/B capture was run; the shader is a
# faithful structural port of readable equations with the UNVERIFIED engine
# bindings listed in docs/coord_swarm_2026-11-24/reports/V784_donor_water_shader.md.

# ---- Donor literals (exact values the probe reads back) --------------------
const WATER_LEVEL: float = -0.25           # texturemap.inc:30 cWaterHeight (CLASSIFICATION)
const WATER_SHORE_HEIGHT: float = -0.1     # texturemap.inc:31 cWaterShoreHeight (INERT in shipped fragment)
# TRN-WATER: the donor's WATER_LEVEL in water.dev.frag:167 is gl_TexCoord[1].z,
# i.e. the water PLANE's vertex Y (water.dev.vert:18) — engine-supplied and
# UNVERIFIED (RV-TRN-03 §2), NOT the -0.25 tile-classification literal. Decouple
# the two: this is a PORT APPROXIMATION placeholder (the only donor-readable
# number) so waveheight stays 0 under shipped constants (DTRN-03 C16). A labelled
# A/B may pass a different surface Y; it is never recovered donor truth.
const WATER_SURFACE_Y: float = -0.25       # PORT APPROX placeholder for gl_TexCoord[1].z
const MAX_HEIGHT: float = 2.96             # texturemap.inc:29 cMaxHeight
const COAST_FADE: float = 0.57             # water.dev.frag:37 coast2water_fadedepth
const DEEP_FADE: float = 1.07              # water.dev.frag:168 0.5 + 0.57
const TEX_SCALE_S: float = 0.1             # water.lib:32
const TEX_SCALE_T: float = 0.01            # water.lib:33
const HDR_MULTIPLIER: float = 1.0          # water.lib:25
const SPEC_SOFT: float = 170.0             # water.dev.frag:42 water_softlight_fact
const SPEC_GLOSSY: float = 120.0           # water.dev.frag:43 water_glossylight_fact
const PARTICLE_AMOUNT: float = 30.0        # water.dev.frag:44 particle_amount

# ---- DONOR WATER.LIB DEFAULTS — PROVEN, but deliberately NOT wired ---------
# DEEPDEC-03 §2/§6.2 (ev_6fcb07113a5beb30f35b8f11334e23cb2c84fe8b5020ef16f97cd91b6d9d27ff)
# proves these values in external water.lib. Eight of them are declared
# COMMENTED OUT in the shipped fragment (water.dev.frag:8-16; DEEPDEC-03 §4.1),
# so wiring them into the spatial material would invent donor behaviour.
# Recorded as an audit trail only; the live fragment uniforms (hdrMultiplier,
# texScaleS/T, fogEnabled) are already set on the material below.
const DONOR_WATER_LIB_PROVEN := {
	"MaxDepth": 1, "MinDepth": 0, "MaxAlpha": 1.1, "MinAlpha": 0,
	"DeepColor": [0.0, 0.0, 0.1255, 0.5],
	"ShallowColor": [0.0, 0.0, 0.0, 0.5],
	"ReflectionAmount": 1, "WaterAmount": 1,
	"FresnelPower": 1, "FresnelBias": 1,
	"WaveFreq": 0, "WaveAmp": 0, "DistFactor": 1, "BumpFactor": 1,
	"WaveDir0": [-1.0, 0.0], "WaveDir1": [-0.7, 0.7], "Speed": 1.0,
	"Offset": 0.495, "LayerCount": 1,
	"CustomTexCoord": true,
	"HeightMapEnable": true, "ShadowMapEnable": true,
}
const DONOR_WATER_LIB_COMMENTED_IN_FRAGMENT := [
	"deepColor", "shallowColor", "reflectionAmount", "waterAmount",
	"fresnelPower", "fresnelBias", "distFactor", "bumpFactor",
]
# DEEPDEC-03 §2.2 (ev_03eb161c90d6962781179abd247668f28b08f324e69e7a837b6dbd22c0ddb988,
# ev_d94dda9482a38c5a0aa3322f1eb7ffddc2f812530d8886205613ad9b23d21319):
# the 0x853ad4 block is 30 STRING-KEY assignments, not numeric defaults; the
# only static number, f32 1.9999998807907104 at 0x853eb8, is an all-keys-enable
# BITMASK (test byte [ebx+0x7c],1 / ,0x40). Never read it as a shader float.
const BINARY_CAUTION := ("0x853ad4 = string-key assignments; 0x853eb8 f32 "
	+ "1.9999998807907104 is an enable bitmask, NOT a shader constant. "
	+ "No numeric descriptor default is provable in cossacks.exe (DEEPDEC-03 §2.3).")

# Donor colours (water.dev.frag:45-47).
const SHALLOW_COLOR := Color(0.1, 0.24, 0.24)
const DEEP_COLOR := Color(0.0, 0.025, 0.05)
const SPEC_COLOR := Color(0.4, 0.4, 0.4)
# Donor parallel-light vector: light.cfg:26-29 (-0.344731,0.938701,0) ->
# water.dev.vert:22 (x/4, z/2, y) Z-up -> Godot Y-up (world3d_terrain.gd:57-58).
const SUN_LIGHTVEC := Vector3(-0.0861828, 0.9387015, 0.0)
# Donor palette Fog (60,100,150)/255 — colors.lib:23. Fog is off by default.
const FOG_COLOR := Color(0.235294, 0.392157, 0.588235)

# ---- Port-only constants (declared, never presented as donor) --------------
const TILE_M: float = 2.0                  # data.gd:23; donor cell size UNVERIFIED (G32 §3)
const DEFAULT_GRID: int = 320              # port test-grid size (t_terrain3d.gd:22); integration passes real w/h
const SHADER_PATH := "res://shaders/water3d.gdshader"
# DONOR-DERIVED, ALREADY SHIPPED in variant3d: diffusewaves0.png (256^2) is the
# only sampler in water.dev.frag:5,65-68; donor water.mat:7,11 tfLuminance.
# heightmapwaves0.tga is deliberately NOT bound (water.mat:86-106 commented;
# TERRAIN2-03 §2.1 / UNV-1). No donor binary was copied here.
const WAVE_TEX_PATH := "res://assets/terrain/water_png/diffusewaves0.png"

var stats: Dictionary = {}
var _material: ShaderMaterial = null
var _water: MeshInstance3D = null
var _built: bool = false
var _time: float = 0.0


func _ready() -> void:
	if not _built:
		build(DEFAULT_GRID, DEFAULT_GRID)


func _process(delta: float) -> void:
	if _material == null:
		return
	_time += delta
	_material.set_shader_parameter("time", _time)


# Runtime PNG load needs no editor .import step (world3d_terrain.gd:87-97).
func _load_png_texture(res_path: String) -> Texture2D:
	var abs_path := ProjectSettings.globalize_path(res_path)
	if not FileAccess.file_exists(abs_path):
		return null
	var img := Image.new()
	if img.load(abs_path) != OK or img.is_empty():
		return null
	return ImageTexture.create_from_image(img)


# NEUTRAL FALLBACK — NOT a donor texture, NOT a 2D bake output. A 1x1 alpha=0
# texture decodes through height_map() to hmapMin (-MAX_HEIGHT), so every
# fragment stays below water and the plane keeps full coverage until a real
# height grid is bound. This stands in for the donor hmapTex whose binding is
# UNVERIFIED (DECOMP-04 §8.1/§8.2). Labelled as such in the report.
func _neutral_height_texture() -> Texture2D:
	var img := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.0, 0.0, 0.0, 0.0))
	return ImageTexture.create_from_image(img)


func invalidate() -> void:
	for child in get_children():
		remove_child(child)
		child.free()
	_material = null
	_water = null
	_built = false
	_time = 0.0
	stats = {}


# Build the plane + donor-equation material. w/h are the height-grid dims; the
# integration hook in world3d_terrain.gd passes its decoded dump dims so the
# water quad keeps its existing full-map extent.
func build(w: int = DEFAULT_GRID, h: int = DEFAULT_GRID) -> bool:
	invalidate()
	var shader := load(SHADER_PATH) as Shader
	if shader == null:
		push_error("water3d: cannot load " + SHADER_PATH)
		return false

	_material = ShaderMaterial.new()
	_material.shader = shader
	# Donor literals -> uniforms (the probe asserts the first three).
	_material.set_shader_parameter("water_level", WATER_LEVEL)          # classification threshold
	# TRN-WATER: separate plane surface Y (donor gl_TexCoord[1].z), no longer the
	# -0.25 classification literal. Default keeps waveheight=0 (DTRN-03 C16).
	_material.set_shader_parameter("water_surface_y", WATER_SURFACE_Y)
	_material.set_shader_parameter("shore_height", WATER_SHORE_HEIGHT)
	_material.set_shader_parameter("max_height", MAX_HEIGHT)
	_material.set_shader_parameter("coast_fade_depth", COAST_FADE)
	_material.set_shader_parameter("deep_fade_depth", DEEP_FADE)
	_material.set_shader_parameter("tex_scale_s", TEX_SCALE_S)
	_material.set_shader_parameter("tex_scale_t", TEX_SCALE_T)
	_material.set_shader_parameter("hdr_multiplier", HDR_MULTIPLIER)
	_material.set_shader_parameter("spec_soft", SPEC_SOFT)
	_material.set_shader_parameter("spec_glossy", SPEC_GLOSSY)
	_material.set_shader_parameter("particle_amount", PARTICLE_AMOUNT)
	_material.set_shader_parameter("shallow_color", SHALLOW_COLOR)
	_material.set_shader_parameter("deep_color", DEEP_COLOR)
	_material.set_shader_parameter("spec_color", SPEC_COLOR)
	_material.set_shader_parameter("sun_dir", SUN_LIGHTVEC)
	_material.set_shader_parameter("fog_color", FOG_COLOR)
	_material.set_shader_parameter("fog_density", 0.0)
	_material.set_shader_parameter("fog_enabled", 0)      # colors.lib:36 FogMode=0
	_material.set_shader_parameter("map_size", Vector2(float(w), float(h)))
	_material.set_shader_parameter("time", 0.0)
	_material.set_shader_parameter("reflection_enabled", 0.0)

	# Wave noise: donor-derived, already shipped. If missing, fall back to a
	# neutral texture and label it UNVERIFIED rather than inventing an asset.
	var wave := _load_png_texture(WAVE_TEX_PATH)
	var wave_path := WAVE_TEX_PATH
	if wave == null:
		wave = _neutral_height_texture()
		wave_path = "NEUTRAL FALLBACK (diffusewaves0.png missing — UNVERIFIED)"
	_material.set_shader_parameter("wave_noise", wave)
	_material.set_shader_parameter("reflection_map", _neutral_height_texture())
	_material.set_shader_parameter("height_tex", _neutral_height_texture())

	# Existing 4-vertex plane geometry, verbatim from world3d_terrain.gd:175-192.
	var half_x: float = float(w) * TILE_M * 0.5
	var half_z: float = float(h) * TILE_M * 0.5
	# TRN-WATER: the plane Y is the surface Y (donor gl_TexCoord[1].z), not the
	# cWaterHeight classification literal; shader and geometry stay in sync.
	var v := PackedVector3Array([
		Vector3(-half_x, WATER_SURFACE_Y, -half_z),
		Vector3(half_x, WATER_SURFACE_Y, -half_z),
		Vector3(half_x, WATER_SURFACE_Y, half_z),
		Vector3(-half_x, WATER_SURFACE_Y, half_z)])
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

	_water = MeshInstance3D.new()
	_water.name = "WaterPlane3D"
	_water.mesh = mesh
	_water.material_override = _material
	add_child(_water)

	_built = true
	stats = {
		"module": "res://scripts/water3d.gd",
		"shader": SHADER_PATH,
		"plane_vertices": 4,
		"plane_triangles": 2,
		"grid": {"w": w, "h": h},
		"wave_tex_path": wave_path,
		"donor_literals": {
			"water_level": WATER_LEVEL,
			"shore_height": WATER_SHORE_HEIGHT,
			"max_height": MAX_HEIGHT,
			"coast_fade_depth": COAST_FADE,
			"deep_fade_depth": DEEP_FADE,
			"tex_scale_s": TEX_SCALE_S,
			"tex_scale_t": TEX_SCALE_T,
		},
		"height_aware": false,
		"visual_parity_claimed": false,
		"donor_water_lib_proven": DONOR_WATER_LIB_PROVEN,
		"water_lib_keys_commented_in_fragment": DONOR_WATER_LIB_COMMENTED_IN_FRAGMENT,
		"binary_caution": BINARY_CAUTION,
		"hmap_min_max": "PORT APPROXIMATION -max_height/+max_height; binary defaults UNVERIFIED (DEEPDEC-03 §2.3)",
		# clamp(-0.25*3-1.5,0,1)=0: the donor swell term is zeroed under the
		# -0.25 threshold literal. Kept donor-faithful, not retuned to the 2D app's 1.0.
		"waveheight_from_donor_literal": clampf(WATER_LEVEL * 3.0 - 1.5, 0.0, 1.0),
		# TRN-WATER audit trail: surface Y decoupled from the classification literal.
		"water_surface_y": WATER_SURFACE_Y,
		"water_surface_y_source": ("PORT APPROXIMATION placeholder = classification literal -0.25; "
			+ "donor gl_TexCoord[1].z plane Y UNVERIFIED (water.dev.vert:18; RV-TRN-03 §2). "
			+ "waveheight=0 under this default (DTRN-03 C16); A/B >0.8333 restores swell."),
		"waveheight_from_surface_y": clampf(WATER_SURFACE_Y * 3.0 - 1.5, 0.0, 1.0),
		"water_alpha_gate": ("PORT GUARD: alpha = coastfade2 * (1 - step(water_level, height)); "
			+ "donor ramp coastfade/coastfade2 unchanged (texturemap.inc:30; water.dev.frag:198-199,230)"),
		"shore_prox": ("REMOVED — RV-TRN-03 §5.2 proved it INERT (=1) under shipped "
			+ "literals; PORT ART absent from the donor fragment (water.dev.frag:227)"),
	}
	return true


# ---- INTEGRATION HOOK (documented, NOT wired by this module) ---------------
# world3d_terrain.gd owns the height[] grid and is owned by V7-82, so this module
# cannot edit it. To enable donor-style height-aware coverage, the integrating
# agent must, after world3d_terrain.gd:346 `_make_water(w, h)`:
#   1. build this node with the same dims:  water3d.build(w, h)
#   2. feed the decoded height[] grid:
#        water3d.bind_height_grid(height, w, h)
#   3. replace/replace-on-top of the existing WaterPlane quad so only one water
#      surface is submitted (do not stack both planes).
# Until then the neutral height texture keeps full coverage (current port look).
# The donor hmapTex literal binding itself is UNVERIFIED (DECOMP-04 §8) — this
# is a port substitute, not a recovered donor binding.
#
# TRN-WATER CROSS-OWNER NOTE (NOT editable in this file): the near-zero-alpha
# waterline currently reveals grass1 because the terrain module clamps BLK_WATER
# (game.gd:52,255) to atlas tile 0 / grass1 in its UV2 build
# (world3d_terrain.gd:697-702 — owned by another builder). The donor paints
# oriented wet-sand sandsea1/5/6 on masked water cells
# (texturemap.inc:463-472,503-511; DEC-05 §5.1 ids 93/97/98), with sandrock*
# also present in the port atlas. The terrain owner must remap those water cells
# to a donor shore id instead of tile 0; this water module cannot do it. See
# docs/coord_swarm_2026-11-25/reports/TRN_WATER_implementation.md.
func bind_height_grid(height: PackedFloat32Array, gw: int, gh: int) -> bool:
	if _material == null or gw <= 0 or gh <= 0 or height.size() < gw * gh:
		return false
	# Normalise the port height[] into the ALPHA channel (donor height_map reads
	# v.w, water.dev.frag:72-73) over [-MAX_HEIGHT, +MAX_HEIGHT].
	var img := Image.create(gw, gh, false, Image.FORMAT_RGBA8)
	for z in range(gh):
		for x in range(gw):
			var y: float = height[z * gw + x]
			var a: float = clampf((y + MAX_HEIGHT) / (2.0 * MAX_HEIGHT), 0.0, 1.0)
			img.set_pixel(x, z, Color(0.0, 0.0, 0.0, a))
	var tex := ImageTexture.create_from_image(img)
	_material.set_shader_parameter("height_tex", tex)
	_material.set_shader_parameter("map_size", Vector2(float(gw), float(gh)))
	stats["height_aware"] = true
	stats["height_grid"] = {"w": gw, "h": gh}
	return true
