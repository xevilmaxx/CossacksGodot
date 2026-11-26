shader_type spatial;

// ============================================================================
// TERRAIN-SWARM-2026-11-26 / I10 — DONOR-FIRST terrain shader (fresh file).
// Owner file (ONLY repo file written by I10): variant3d/shaders/terrain_donor.gdshader
//
// PROVENANCE (all donor material READ-ONLY; no donor binary was run or copied):
//   spec/06_TILE_AND_ATLAS.md (F05 + F06 + X06)  — tile ids, atlas, alpha truth
//   spec/05_WATER_SHORE.md    (D06 + F06 + A02)  — three water levels, hmapTex key
//   reports/D08_tile_select_bin.md               — eye-plane texgen, blend factors,
//                                                   defaults, tile id dictionary
//   reports/F06_alpha_masks.md                   — alpha.bmp / alphavert / alphanull
//   reports/X11_water_translation.md             — water/shore boundary, hmapTex key
//   reports/X17_blendfunc_verification.md        — bmTransparency == framebuffer crossfade
//   variant3d/shaders/terrain_tileindex.gdshader (READ-ONLY reference) — lighting rig
//   variant3d/scripts/world3d_terrain.gd:137-141 (READ-ONLY) — sun/ambient colours
//
// visual_parity_claim:false
//   No donor GPU A/B frame exists. Every PORT APPROXIMATION / [U] below is a
//   labelled substitute, NOT donor truth (CHARTER.md:43-44,125).
//
// CONTRACT WITH I08 (terrain_donor_mesh.gd):
//   UV2.x = integer tile id, donor presets range [0,123]
//           # donor data/terrain/tiles/terrain.presets:6-129 (spec 06 §1; D08 ev_e742...)
//   UV2.y = face mode {0=ground, 1=verticalfront, 2=verticalside}
//           # donor refkeys data/terrain/ref/reftile.mat:1-170; UV2 transport is PORT APPROX
//   NORMAL = height-derived normal supplied by I08. This shader computes donor
//            Blinn-Phong from it; it does NOT bake, tilt or promote face art.
//
// BLEND CONTRACT (X17 §3.4; D08 §3.5 / §5 implications #4):
//   This shader is the MASKED OVERLAY. A base opaque layer must already be in
//   the framebuffer (composer I11/N14), else ALPHA<1 reveals sky. Godot
//   `blend_mix` == donor glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
//   # donor cossacks.exe VA 0x4ef991/0x88fba4/0x88fbb0, table 0x8fb1c4/0x8fb1c8 (X17 §3.1)
//   # donor data/terrain/ref/reftile.mat:17 (bmTransparency), enum idx 1 at cossacks.exe:949234
//   The mask enters ALPHA ONLY — the legacy `rgb * a` at
//   terrain_tileindex.gdshader:427 is deliberately NOT reproduced.
//   Number of fixed-function composite passes is [U] CONFIRMED_UNVERIFIED
//   (X17 §3.3/U-X17-1, six passes; D08 §7 #5). `blend_pass_count` is a
//   labelled telemetry uniform with NO default claim (0 = UNSET sentinel).
//
// NOT PRESENT BY DESIGN (no fakery, CHARTER.md:83-84, S-25-09):
//   no shadow sampler / PCF, no AO, no fog, no dither/noise/warp field,
//   no forced cliff promotion, no wave-height texture bound to hmapTex.
// ============================================================================

// `unshaded`: PORT render-mode decision — donor assembles final colour in-shader
// (hf.pvl.smx3.frag:17,50) so Godot must not shade ALBEDO twice (reference :31-37).
// `cull_disabled`: PORT GUARD for mesh winding (donor is fcCull, reftile.mat:18).
render_mode blend_mix, unshaded, cull_disabled;

// ----------------------------------------------------------------------------
// Samplers. Donor HeightField has TWO samplers: texUnit0 (RGB) and texUnit1 (alpha)
// bound to units 0/1 (data/shaders/shaders.lib:34-49), read at
// data/shaders/obj/hf.pvl.smx3.frag:13-14. A third sampler carries the face
// refkey's alphavert projection (data/terrain/ref/reftile.mat:122,148).
// ----------------------------------------------------------------------------
uniform sampler2D tile_atlas : filter_linear_mipmap_anisotropic, repeat_enable;
// Donor RGB blocks are 1024x1024 DXT1 with 11 mips (data/terrain/tiles/textures/grass1.dds
// header, D08 §3.1). Packed 16x8 atlas layout is PORT APPROXIMATION (spec 06 §2;
// donor packing is engine-side tsDouble/ttExtended, reftile.lib:3-12, [U]).

uniform sampler2D alpha_atlas : filter_nearest, repeat_enable;
// Converted donor alpha.bmp: 512x256, 8 bpp, data@1070, 8 cols x 4 rows of 64x64
// patches. # donor data/terrain/tiles/textures/alpha.bmp header (F06-E7);
// # donor data/terrain/ref/reftile.lib:10-12 (commented AlphaRows/AlphaCols/AlphaTileSize);
// # donor data/terrain/ref/reftilealpha.mat:30-37 (imagealpha=tiaAlphaFromIntensity, tfAlpha).
// CONTRACT for I05: donor intensity MUST be written into the PNG ALPHA channel;
// exact intensity->alpha formula is [U] (F06 U-F06-3).

uniform sampler2D alphavert_atlas : filter_nearest, repeat_enable;
// Converted donor alphavert.bmp: 1024x512, 24 bpp near-grey (F06-E11).
// # donor data/terrain/tiles/textures/alphavert.bmp header (F06-E11);
// # donor data/terrain/ref/reftilealpha.mat:126-146 (tfAlpha, maNearest/miNearest).

uniform sampler2D hmapTex;
// PARAMETER KEY ONLY — do NOT sample here and NEVER bind heightmapwaves0.tga.
// # donor data/shaders/water/water.dev.frag:18 (declared sampler2D hmapTex);
// # donor cossacks.exe VA 0x853ad4 / descriptor +0x54 (D06 §4: 30 string keys,
//   NO texture lookup/sampler bind);
// # donor data/water/water.mat:86-106 (HeightMapWaves0 block fully commented);
//   heightmapwaves0.tga alpha = 255 on all 65,536 px (D06 P18) — disproved as hmapTex.
// Water rendering itself belongs to water3d.gdshader (X11); this terrain shader
// supplies only shore tile ids and the crossfade blend.

// ----------------------------------------------------------------------------
// Atlas layout. 16x8 grid of 124 preset cells is a PORT APPROXIMATION, not a
// recovered donor layout (D08 §3.1; spec 06 §2). No index remapping.
// ----------------------------------------------------------------------------
uniform vec2 atlas_grid = vec2(16.0, 8.0);
// PORT APPROX: # donor data/terrain/ref/reftile.lib:3-12 (tsDouble/ttExtended,
// sub-rect values commented); 16x8 is the port packing (spec 06 §2).

// ----------------------------------------------------------------------------
// Eye-plane texgen — exact donor EQUATIONS, defaults from binary, runtime [U].
// data/shaders/obj/hf.pvl.sm.vert:25-32:
//   s = dot(realpos, gl_EyePlaneS[0]);  t = dot(realpos, gl_EyePlaneT[0]);
//   gl_TexCoord[0] = gl_TextureMatrix[0] * gl_TexCoord[0];
// Default plane floats below are the donor BINARY DEFAULTS, not the effective
// per-frame values: those are CONFIRMED_UNVERIFIED (D08 §7 #6, six passes;
// sub_4be364 sets them at runtime from computed pointers). Rebind by I08/COORD.
// ----------------------------------------------------------------------------
uniform vec4 eye_plane_s = vec4(1.0, 0.0, 0.0, 0.0);
// # donor cossacks.exe:0x8f4aa4 (default S plane, f32)
uniform vec4 eye_plane_t = vec4(0.0, 1.0, 0.0, 0.0);
// # donor cossacks.exe:0x8f4ab4 (default T plane, f32)
uniform vec4 eye_plane_r = vec4(0.0, 0.0, 1.0, 0.0);
// # donor cossacks.exe:0x8f4ac4 (default R plane, f32); unused by HeightField ground.
uniform vec4 eye_plane_q = vec4(0.0, 0.0, 0.0, 1.0);
// # donor cossacks.exe:0x8f4ad4 (default Q plane, f32); unused by HeightField ground.
uniform mat4 texture_matrix = mat4(1.0);
// # donor data/shaders/obj/hf.pvl.sm.vert:32; GL identity default, runtime value [U]
// (D08 §7 #6). R/Q dot products are left untouched by the ground path.

uniform vec2 uv_repeat = vec2(0.5, 0.5);
// # donor data/scripts/dmscript.global:171 (gc_meters_to_tile=2 -> 1/2 m per cell).
// PORT APPROX w.r.t. the donor gl_TextureMatrix[0] scale (RV-TRN-01 verdict A);
// no donor literal equivalent to this multiplier was recovered (D08 §3.6).
uniform float alpha_uv_scale = 1.0;
// Escape hatch for the mask phase. PORT APPROX (donor MultiTexCoord1 values [U]).
uniform float mask_uv_source = 0.0;
// 0 = derive flat mask UV from tile id + eye-plane phase (PORT APPROX, F06 §5.2);
// 1 = use mesh UV as the donor gl_MultiTexCoord1 analogue
//     # donor data/shaders/obj/hf.pvl.sm.vert:34 (mesh-supplied mask UV).
// Donor tile-id+direction -> patch rule is [U] (D08 §7 #4; F06 U-F06-7).

// Face alpha projection (second sampler swap). Donor values are recovered;
// the Z-up -> Godot Y-up axis remap is an INFERRED PORT APPROX.
uniform float face_scale = 0.125;
// # donor data/terrain/ref/reftile.mat:124-126 (verticalfront TextureScale XYZ),
// # donor data/terrain/ref/reftile.mat:150-152 (verticalside TextureScale XYZ).
// front planes S=(1,0,0,0) T=(0,0,1,0) # donor reftile.mat:130-141 (tmmEyeLinear :129)
// side  planes S=(0,1,0,0) T=(0,0,1,0) # donor reftile.mat:156-167 (tmmEyeLinear :155)
// Godot Y-up: donor T(Z)=height -> v_eye.y, donor S(Y) -> v_eye.z
// # donor variant3d/scripts/world3d_terrain.gd:57-58 (TERRAIN2-01 §2.5) [I] PORT APPROX.

// ----------------------------------------------------------------------------
// Blend telemetry — pass count is [U]; ZERO default claim.
// ----------------------------------------------------------------------------
uniform int blend_pass_count = 0;
// 0 = UNSET sentinel, NOT a donor value and NOT a claim. Shader does not use it.
// # donor bmTransparency enum idx 1 at cossacks.exe:949234 (X17 §3.1);
//   composite draw-pass count CONFIRMED_UNVERIFIED (X17 §3.3/U-X17-1, D08 §7 #5).

// ----------------------------------------------------------------------------
// Donor Blinn-Phong constants, from the port's existing world3d_terrain path
// (READ-ONLY) with donor citations. Vertex-packed at
// # donor data/shaders/obj/hf.pvl.sm.vert:12-15,18-22,37-38;
// combined at # donor data/shaders/obj/hf.pvl.smx3.frag:17.
// ----------------------------------------------------------------------------
uniform vec3 donor_sun_position = vec3(-0.344731152057648, 0.938701450824738, 0.0);
// # donor variant3d/scripts/world3d_terrain.gd:137 -> data/env/lights/light.cfg:26-29
// lsParallel (light.cfg:17): consumed as a constant DIRECTION, not a point.
uniform vec3 ambient_rgb = vec3(0.196078434586525, 0.184313729405403, 0.129411771893501);
// # donor variant3d/scripts/world3d_terrain.gd:139 -> light.cfg:3-8 (Ambient)
uniform vec3 diffuse_rgb = vec3(0.811764717102051, 0.780392169952393, 0.694117665290833);
// # donor variant3d/scripts/world3d_terrain.gd:140 -> light.cfg:11-16 (Diffuse)
uniform vec3 specular_rgb = vec3(0.278431385755539, 0.266666680574417, 0.211764708161354);
// # donor variant3d/scripts/world3d_terrain.gd:141 -> light.cfg:20-23 (Specular).
// PRESERVED CONTRADICTION (not resolved here): the read-only legacy shader sets
// specular_rgb = vec3(0) via material specular = 0 (reftile.mat:98-102,70-74).
// I08/COORD may bind zero; default follows the world3d_terrain path as ticketed.
uniform float shininess = 16.0;
// # donor data/terrain/ref/reftile.mat:76,104 (cited by read-only reference shader :165);
// material/runtime binding UNVERIFIED — no world3d_terrain constant exists for it.

// ----------------------------------------------------------------------------
// Shore / water levels — THREE DISTINCT LEVELS, never conflated, never used as
// the shader plane Y (which belongs to water3d.gdshader and is [U], X11 §7.1).
// Shore tiles are selected on the CPU by texturemap.inc:463-529 (sandsea1/5/6,
// 8x45-degree sectors); I07/I08 supply the resulting UV2.x. This shader only
// consumes that id and supplies the blend — no tile id is fabricated here.
// ----------------------------------------------------------------------------
uniform float water_height_basin = -1.1;
// # donor data/scripts/common.inc/generatemap.inc:7 (cWaterHeight generation basin)
uniform float water_field_offset_y = -0.5;
// # donor data/scripts/common.inc/generatemap.inc:688,704 (cOffsetY -> WaterFieldAdd)
// [U] runtime: GSC line is comment-prefixed (spec 05 §1; X11 §7.1).
uniform float water_height_classify = -0.25;
// # donor data/scripts/common.inc/texturemap.inc:29-30,466-467 (cWaterHeight -> bWater)
uniform float water_shore_height = -0.1;
// # donor data/scripts/common.inc/texturemap.inc:31,463-472 (cWaterShoreHeight)
// shore band width [D] = 0.15; smoothing gate is mask.b + height, not height alone
// (spec 05 §2; texturemap.inc:580-643). No shading threshold is invented below.

// ----------------------------------------------------------------------------
// Vertex contract (transport only; donor has no such mesh stream):
//   UV2.x = tile id [0,123]  # donor terrain.presets:6-129
//   UV2.y = face {0,1,2}     # donor reftile.mat:1-170 refkeys; PORT APPROX transport
// ----------------------------------------------------------------------------
varying vec2 v_st;         // donor gl_TexCoord[0].xy after texture matrix
varying vec2 v_alpha_uv;   // donor gl_TexCoord[1].xy analogue (PORT APPROX phase)
varying float v_tile;      // integer-valued tile id from UV2.x
varying float v_face;      // 0 / 1 / 2
varying vec3 v_eye;        // donor realpos.xyz (eye space)
varying vec3 v_packed;     // donor gl_TexCoord[4].xyz = ambient + diffuse
varying vec3 v_specular;   // donor gl_TexCoord[5].xyz = specular

void vertex() {
	// # donor data/shaders/obj/hf.pvl.sm.vert:9 — realpos = ModelView * vertex.
	vec4 realpos = VIEW_MATRIX * MODEL_MATRIX * vec4(VERTEX, 1.0);
	v_eye = realpos.xyz;

	// # donor hf.pvl.sm.vert:30-32 — eye-plane texgen (s, t, texture matrix).
	vec2 st = vec2(dot(realpos, eye_plane_s), dot(realpos, eye_plane_t));
	v_st = (texture_matrix * vec4(st, 0.0, 1.0)).xy;

	// # donor hf.pvl.sm.vert:34 — mask UV is a second mesh-supplied coordinate.
	// The donor per-tile MultiTexCoord1 writer is [U] (D08 §7 #4); phase below is
	// a labelled PORT APPROXIMATION, overridable to mesh UV via mask_uv_source.
	v_alpha_uv = st * uv_repeat * alpha_uv_scale;

	// # donor hf.pvl.sm.vert:12-15,18-22 — Blinn-Phong from the supplied NORMAL.
	vec3 e = normalize(-realpos.xyz);                                   // :12
	// lsParallel: constant donor sun direction (# donor light.cfg:17), no realpos
	// subtraction. VIEW_MATRIX rotates the world direction into eye space:
	// PORT APPROX of gl_LightSource modelview (engine-side, UNVERIFIED).
	vec3 sun_world = normalize(donor_sun_position);                      // :13
	vec3 l = normalize((VIEW_MATRIX * vec4(sun_world, 0.0)).xyz);        // :13
	vec3 h = normalize(l + e);                                           // :14
	vec3 n = normalize((VIEW_MATRIX * MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz); // :15
	// PORT APPROX of gl_NormalMatrix (inverse-transpose is engine-side, UNVERIFIED).

	vec3 diffuse = max(dot(l, n), 0.0) * diffuse_rgb;                    // :19
	v_packed = ambient_rgb + diffuse;                                    // :18,:37
	v_specular = pow(max(dot(h, n), 0.0), shininess) * specular_rgb;     // :22,:38

	v_tile = UV2.x;
	v_face = UV2.y;
}

// Atlas cell lookup: cell i -> (i mod 16, floor(i / 16)) (spec 06 §2).
// PORT APPROX packing; no donor remap, no warp/noise (CHARTER S-25-09).
vec3 tile_rgb(float idx, vec2 local_uv) {
	vec2 grid = max(atlas_grid, vec2(1.0));
	vec2 cell = vec2(mod(idx, grid.x), floor(idx / grid.x));
	// Half-texel inset from the cell border (PORT GUARD against atlas bleeding).
	vec2 inset = 0.5 / max(vec2(textureSize(tile_atlas, 0)) / grid, vec2(1.0));
	vec2 uv = mix(inset, vec2(1.0) - inset, clamp(local_uv, 0.0, 1.0));
	return texture(tile_atlas, (cell + uv) / grid).rgb;
	// # donor data/shaders/obj/hf.pvl.smx3.frag:13 (RGB from texUnit0)
}

// alpha.bmp sub-rect sampling. Geometry is donor-observed:
// # donor data/terrain/tiles/textures/alpha.bmp (F06-E7/E9/E10: 8x4 patches of 64x64)
// # donor data/terrain/ref/reftile.lib:10-12 (commented AlphaRows=8/AlphaCols=4/AlphaTileSize=64)
// The tile-id bit decomposition below is a PORT APPROXIMATION: the donor
// tile-id+direction -> patch rule is [U] CONFIRMED_UNVERIFIED (D08 §7 #4,
// F06 §5.2 / U-F06-7). Constant patches (0,0)/(4,0)=255 and (3,3)/(7,3)=0 are
// donor-authored (F06 §3.2); they are sampled as-is, never neutralised by a guard.
vec2 alpha_patch_uv(float tile, vec2 local) {
	float id = floor(abs(tile));
	float dir = mod(id, 4.0);                        // PORT APPROX stand-in for edge direction
	float variant = mod(floor(id / 4.0), 4.0);       // PORT APPROX column variant
	float half = mod(floor(id / 16.0), 2.0);         // PORT APPROX half (cols 0-3 / 4-7)
	float opposite = mod(floor(id / 64.0), 2.0);     // PORT APPROX opposite-tile stand-in
	float row = mix(dir, 3.0 - dir, opposite);       // PORT APPROX 180-degree counterpart
	variant = mix(variant, 3.0 - variant, opposite); // PORT APPROX same-half counterpart
	vec2 cell = vec2(half * 4.0 + variant, row);
	// Half-texel inset inside each 64x64 patch (# donor reftile.lib:10-12 commented;
	// # donor alpha.bmp 512x256 data@1070, F06-E7/E9/E10).
	vec2 t = clamp(local, 0.5 / 64.0, 1.0 - 0.5 / 64.0);
	return (cell + t) / vec2(8.0, 4.0);
}

void fragment() {
	// # donor data/shaders/obj/hf.pvl.smx3.frag:13 — RGB from texUnit0.
	vec3 rgb = tile_rgb(v_tile, fract(v_st * uv_repeat));

	// # donor data/shaders/obj/hf.pvl.smx3.frag:14 — alpha from texUnit1.
	float a;
	int face = int(v_face + 0.5);
	if (face == 1 || face == 2) {
		// Face refkeys swap texUnit1 to alphavert:
		// # donor data/terrain/ref/reftile.mat:122,148 (Texture2Name=alphavert)
		// front S=(1,0,0,0) T=(0,0,1,0) # donor reftile.mat:130-141
		// side  S=(0,1,0,0) T=(0,0,1,0) # donor reftile.mat:156-167
		// Scale 0.125 # donor reftile.mat:124-126,150-152.
		// Z-up -> Godot Y-up remap is [I] PORT APPROX (world3d_terrain.gd:57-58).
		vec2 mask_uv = (face == 1)
			? vec2(v_eye.x, v_eye.y) * face_scale
			: vec2(v_eye.z, v_eye.y) * face_scale;
		a = texture(alphavert_atlas, mask_uv).a;
	} else {
		vec2 local = mask_uv_source > 0.5 ? UV : fract(v_alpha_uv);
		// alphanull: zero coverage on exactly three donor ids.
		// # donor data/terrain/tiles/tiles.mat:346-359 (alpha0a/b/c -> alphanull);
		// # donor data/terrain/tiles/terrain.presets:6-129 (ids 86/110/123),
		// # donor data/terrain/tiles/textures/alphanull.bmp (all pixel indices 0, F06-E14).
		bool is_alphanull = (abs(v_tile - 86.0) < 0.5)
			|| (abs(v_tile - 110.0) < 0.5)
			|| (abs(v_tile - 123.0) < 0.5);
		a = is_alphanull ? 0.0 : texture(alpha_atlas, alpha_patch_uv(v_tile, local)).a;
	}

	// # donor data/shaders/obj/hf.pvl.smx3.frag:17 — packed lighting + specular.
	// NO mask multiply: the legacy terrain_tileindex.gdshader:427 `rgb * a` is a
	// PORT APPROXIMATION and is deliberately not reproduced (D08 §3.5, X17 §3.2).
	rgb = rgb * v_packed + v_specular;

	// # donor hf.pvl.smx3.frag:50 — gl_FragColor = color (mask alpha intact).
	// Framebuffer crossfade, not albedo modulation:
	// dst.rgb' = src.rgb*src.a + dst.rgb*(1-src.a), GL_FUNC_ADD
	// # donor cossacks.exe VA 0x4ef991/0x88fba4/0x88fbb0, table 0x8fb1c4/0x8fb1c8
	ALBEDO = rgb;
	ALPHA = a;
}
