shader_type spatial;

// ============================================================================
// V7-86 / TERRAIN2-06 atom A2 — DONOR-REPRESENTATION terrain shader.
//
// Implements the representation audited in
//   docs/coord_swarm_2026-11-24/reports/TERRAIN2_06_tileindex_architecture.md
//   (E01-E15, section 3.4), TERRAIN2_01_donor_pipeline.md (E34-E45) and the
//   exact shader equations transcribed in
//   docs/coord_swarm_2026-11-24/reports/DEEPDEC_02_terrain_render.md §3.2/§3.3.
// Every donor equation/behaviour below carries a read-only donor path:line.
// Donor root: C:\Games\Cossacks 3\ (latin-1 text; nothing copied or executed).
//
// WHAT THIS SHADER IS: ONE per-cell integer tile index (donor
// TMapTerrainDataTile `.tex`, dmscript.global:2026-2035) selecting a cell of a
// donor-block atlas; donor alpha/alphavert masks; eye-plane projected UVs;
// donor vertex-packed Blinn-Phong, 3-/9-tap PCF and fog equations.
//
// WHAT THIS SHADER IS NOT: bit-exact donor parity. Every substitute is marked
// PORT APPROXIMATION, PORT SUBSTITUTE or PORT GUARD. Visual parity is
// UNVERIFIED — no GPU A/B was run. See V786_tileindex_shader.md.
// ============================================================================

// Donor `BlendingMode = bmTransparency` (reftile.mat:17; reftilealpha.mat:17).
// One Godot `blend_mix` pass is a PORT APPROXIMATION of the donor's multi-pass
// fixed-function blend (ENGINE, TERRAIN2-01 UNVERIFIED #4).
//
// `unshaded` is a PORT decision: this shader now reproduces the DONOR's own
// lighting/fog (hf.pvl.sm.vert:18-23,37-45; hf.pvl.smx3.frag:17,34-46) and
// writes a FINAL colour at hf.pvl.smx3.frag:50. Godot lighting must not shade
// ALBEDO a second time. The donor has no `unshaded` flag — this is not a donor
// configuration value.
//
// `cull_disabled` is a PORT GUARD for the existing mesh winding, not donor
// behaviour: donor is `FaceCulling = fcCull` (reftile.mat:18), while the port
// terrain disables culling deliberately (world3d_terrain.gd:110-112).
render_mode blend_mix, unshaded, cull_disabled;

// ----------------------------------------------------------------------------
// Textures. Donor is a two-sampler shader: texUnit0 (RGB) + texUnit1 (alpha),
// bound to units 0 and 1 (shaders.lib:34-49), sampled at
// hf.pvl.smx3.frag:13-14. We expose THREE samplers because donor swaps texUnit1
// from `alpha` to `alphavert` per face refkey (reftile.mat:6 vs :122/:148).
// A hypothetical fourth sampler (`texShadow`) is a PORT SUBSTITUTE, see below.
//
// Filtering mirrors reftile.mat:29-37 (tfIsotropic, maNearest,
// miNearestMipmapLinear) and reftilealpha.mat:29-36 / :138-146 (maNearest,
// miNearest — no mipmaps on masks).
// PORT APPROXIMATION: Godot 4 has no single hint for donor's mixed
// nearest-mag / nearest-mipmap-linear-min; `filter_nearest_mipmap` is the
// closest expressible hint. A3 may set the remaining filter flags on the
// Texture2D itself if a closer match is needed.
// ----------------------------------------------------------------------------
uniform sampler2D tile_atlas : filter_nearest_mipmap, repeat_enable;
// V7-85 asset: donor block atlas, one preset per cell. Cell = preset index
// (presets_summer.json:2-125), row-major from top-left, grid in `atlas_grid`.
// RGB only: no normal map — donor tangentSpace=false (shaders.lib:19) and
// heightfield uses gl_Normal (hf.pvl.sm.vert:15), never a tangent-space map.

uniform sampler2D alpha_atlas : filter_nearest, repeat_enable;
// Converted donor `alpha.bmp` (reftilealpha.mat:30, imagealpha
// tiaAlphaFromIntensity :31/34, textureformat tfAlpha :35, 512x256 per
// TERRAIN2-06 E07). CONTRACT: A1 must write donor intensity into the PNG's
// ALPHA channel; this shader reads `.a` as donor hf.pvl.smx3.frag:14 does.

uniform sampler2D alphavert_atlas : filter_nearest, repeat_enable;
// Converted donor `alphavert.bmp` (reftilealpha.mat:139, tiaAlphaFromIntensity
// :140/142, tfAlpha :144, 1024x512 per TERRAIN2-06 §3.3). Same alpha contract.
// Bound to refkeys `verticalfront`/`verticalside` (reftile.mat:122/:148;
// tiles.mat:142-213).

// PORT SUBSTITUTE for donor `uniform sampler2DShadow texShadow`
// (hf.pvl.smx3.frag:3; hf.pvl.smx9.frag:3), unit 3 per DEEPDEC-02 §4 step 5.
// Godot does not expose that sampler type here, so we sample a regular depth
// PNG/RGBA and compare `.r >= 0.999` (donor shadow2DProj threshold, smx3:26-28,
// smx9:25-33). Binding and projective coord are ENGINE/UNVERIFIED.
uniform sampler2D shadow_map : filter_nearest, repeat_enable;

// ----------------------------------------------------------------------------
// Atlas layout. PORT APPROXIMATION: donor packing lives in `tsDouble` /
// `ttExtended` and the engine (reftile.lib:3-12, sub-rect values commented
// :7-12). V7-85 defines the port packing; no donor dimension is invented.
// `atlas_grid` MUST be set by A3 from the V7-85 manifest.
// ----------------------------------------------------------------------------
uniform vec2 atlas_grid;                 // (cols, rows); NO donor default

// ----------------------------------------------------------------------------
// Eye-plane texture generation (DEEPDEC-02 §3.2, hf.pvl.sm.vert:9,25-33):
//   realpos = gl_ModelViewMatrix * gl_Vertex               :9
//   s = dot(realpos, gl_EyePlaneS[0])                       :30  (:28 in DEC-02 numbering)
//   t = dot(realpos, gl_EyePlaneT[0])                       :31  (:29)
//   gl_TexCoord[0] = gl_TextureMatrix[0] * gl_TexCoord[0]   :32  (:30)
//   texGen = true                                           shaders.lib:30
// READ-ONLY DONOR TRUTH: the exact face planes are S=(1,0,0,0),T=(0,0,1,0)
// (front, reftile.mat:130-141) and S=(0,1,0,0),T=(0,0,1,0) (side,
// reftile.mat:156-167), tmmEyeLinear (:129/:155).
//
// PORT APPROXIMATION: runtime gl_EyePlaneS/T[0] and gl_TextureMatrix[0] VALUES
// are engine-bound and NOT readable (DEEPDEC-02 UNVERIFIED #4/#6;
// TERRAIN2-06 UNVERIFIED #1). Identity-like plane defaults are NEUTRAL
// substitutes, NOT donor measurements; A3 must override them.
// ----------------------------------------------------------------------------
uniform vec4 eye_plane_s = vec4(1.0, 0.0, 0.0, 0.0);        // APPROX
uniform vec4 eye_plane_t = vec4(0.0, 1.0, 0.0, 0.0);        // APPROX
uniform mat4 texture_matrix = mat4(1.0);                    // APPROX (identity)

// Donor-cited constant. `TextureScale X/Y/Z = 0.125` on BOTH face refkeys:
// verticalfront reftile.mat:124-126; verticalside reftile.mat:150-152.
// How it propagates into gl_TextureMatrix[0] is UNVERIFIED (DEEPDEC-02 #6).
uniform float face_scale = 0.125;

// ----------------------------------------------------------------------------
// Exact donor vertex-lighting parameters (DEEPDEC-02 §3.2, hf.pvl.sm.vert).
// The DONOR expressions use engine-bound gl_FrontLightModelProduct /
// gl_FrontLightProduct / gl_FrontMaterial / gl_LightSource. We expose their
// resulting TERMS as uniforms. Values below are the readable donor MATERIAL
// literals (reftile.mat), not the unreadable light-product energies.
// ----------------------------------------------------------------------------
uniform vec3 light_position_eye = vec3(0.0);
// PORT SUBSTITUTE for `gl_LightSource[0].position.xyz` (hf.pvl.sm.vert:13).
// No eye-space value is readable (DEEPDEC-02 UNVERIFIED #4/#7); neutral 0.

uniform vec3 ambient_rgb = vec3(0.15686);
// Donor material Ambient 0.15686 (reftile.mat:52-56, :80-84). The donor term
// is sceneColor + FrontLightProduct[0].ambient (:18); energies are APPROX.

uniform vec3 diffuse_rgb = vec3(0.78125);
// Donor material Diffuse 0.78125 (reftile.mat:58-62, :86-90); donor term is
// FrontLightProduct[0].diffuse (:19); energies are APPROX.

uniform vec3 specular_rgb = vec3(0.0);
// Donor front-material Specular = 0 (reftile.mat:98-102, :70-74), so the
// light-product specular (hf.pvl.sm.vert:22) is zero for the normal refkey.
// light.cfg:17-20 has a light specular colour, but the material kills it.

uniform float shininess = 16.0;          // reftile.mat:76, :104
uniform float vertex_color_enabled = 0.0;
// Donor config `vertexColor = true` (shaders.lib:27) and hf.pvl.sm.vert:20-21
// multiply DIFFUSE by gl_Color. DEEPDEC-02 §3.1: no vertex-colour array exists
// in the analysed draw paths (glColorPointer 0 refs, UNVERIFIED #7). We do NOT
// bind Godot COLOR; this uniform is a PORT SUBSTITUTE for that channel.

uniform vec3 vertex_color_substitute = vec3(1.0);
// Neutral stand-in for gl_Color (hf.pvl.sm.vert:20-21), PORT SUBSTITUTE.
// NOTE: VCOLOR_FACTOR 2.5 (def.pvl.sm.vert:1, :21-25) belongs to the Default
// shader, NOT HeightField; deliberately not applied here.

// ----------------------------------------------------------------------------
// Shadow parameters (hf.pvl.smx3.frag / smx9.frag).
// ----------------------------------------------------------------------------
uniform float shadow_enabled = 0.0;
// Donor config `shadowed = true` (shaders.lib:26), but no shadow texture is
// shipped in the port; default OFF is a PORT APPROXIMATION.
uniform mat4 shadow_matrix = mat4(1.0);
// PORT SUBSTITUTE folding donor `gl_TextureMatrix[3] * cameraMVM * realpos`
// (hf.pvl.sm.vert:35) into one uniform; both engine matrices are UNVERIFIED.
uniform float shadow_offset = 0.001953125;  // donor `of` = 1/512, smx3:23, smx9:22
uniform float shadow_taps = 3.0;
// Donor profile split: SM20 uses hf.pvl.smx3.frag (3 taps, shaders.lib:15-52),
// SM30 uses hf.pvl.smx9.frag (9 taps, shaders.lib:914-949). Which is selected
// at runtime is UNVERIFIED (DEEPDEC-02 UNVERIFIED #4); exposed, not assumed.
uniform vec4 shadow_color = vec4(0.0);
// PORT APPROXIMATION of donor engine-bound `shadowColor` (smx3:6, :30;
// smx9:6, :35). Neutral default; not a donor measurement.

// ----------------------------------------------------------------------------
// Fog parameters (hf.pvl.smx3.frag:34-46, hf.pvl.smx9.frag:39-51).
// ----------------------------------------------------------------------------
uniform float fog_mode = 0.0;
// Donor `FogMode = 0` on the default palette (colors.lib:36, TERRAIN2-01 E65).
uniform vec3 fog_color = vec3(0.2352941176, 0.3921568627, 0.5882352941);
// Donor default palette Fog (60,100,150,1) colors.lib:23 (TERRAIN2-01 E65);
// decimals are 60/255, 100/255, 150/255 written literally (Godot defaults
// require constant expressions, not divisions).
uniform float fog_density = 0.0;         // gl_Fog.density, engine-bound APPROX
uniform float fog_end = 0.0;             // gl_Fog.end, engine-bound APPROX
uniform float fog_scale = 0.0;           // gl_Fog.scale, engine-bound APPROX
uniform float fog_use_abs_z = 0.0;
// Donor vendor branch: 0 -> `length(realpos)` (hf.pvl.sm.vert:45, non-ATI),
// 1 -> `abs(realpos.z)` (hf.pvl.sm.vert:43, #vendor_ifdef ATI). Exposed.

// ----------------------------------------------------------------------------
// PORT APPROXIMATION knobs (no donor constant exists for any of them).
// ----------------------------------------------------------------------------
uniform vec2 uv_repeat = vec2(1.0);
// Multiplier on fract(s,t). Donor `TextureScale = 1` (terrain.lib:5-10) has no
// metres-per-tile; port TILE_M = 2.0 is port-only (world3d_terrain.gd:50).

uniform vec2 alpha_uv_scale = vec2(1.0);
// Donor mask UV is a SECOND per-vertex coordinate set:
// `gl_TexCoord[1] = gl_MultiTexCoord1` (hf.pvl.sm.vert:34) sampled at
// hf.pvl.smx3.frag:14. Flat tiles use tmmUser with s-plane (1,0,0,0) and
// t-plane (1,0,0,0) (reftile.mat:39-50) whose engine expansion is UNVERIFIED.
// We substitute fract(s,t) (TERRAIN2-06 §3.4); this is an escape hatch.

uniform float face_mode_override = -1.0;
// -1 = use per-vertex `UV2.y` face mode. >=0 forces 0=ground / 1=front /
// 2=side for every cell. Port-only, for A3 before A5 face flags exist.

// ----------------------------------------------------------------------------
// VERTEX ATTRIBUTE CONTRACT (transport only; donor has no such stream).
//   UV2.x = float(tile_index)  — donor `.tex` id, 0..85 in the shipped dump
//                               (dmscript.global:2026-2035, TERRAIN2-06 E01)
//   UV2.y = face mode: 0=ground (normal refkey, reftile.mat:1-108),
//                      1=verticalfront (reftile.mat:120-144),
//                      2=verticalside  (reftile.mat:146-170).
//           Default 0 keeps TERRAIN2-06 §3.1 (UV2.y = 0) valid.
// No COLOR / vertex-colour array: donor has zero glColorPointer references
// (DEEPDEC-02 §3.1, verified 0 hits over donor text); `shaders.lib:27` and
// hf.pvl.sm.vert:20-21 read a colour CHANNEL, not a mesh buffer. Do not bind
// COLOR here — use `vertex_color_substitute` if a colour term is wanted.
// ----------------------------------------------------------------------------

varying vec2 v_st;        // donor gl_TexCoord[0].xy (after texture matrix)
varying vec2 v_alpha_uv;  // PORT APPROX of donor gl_TexCoord[1].xy
varying float v_tile;     // integer-valued float index from UV2.x
varying float v_face;     // 0 / 1 / 2
varying vec3 v_eye;       // donor realpos.xyz, for eye-linear face masks
varying vec3 v_packed;    // donor gl_TexCoord[4].xyz = ambient+diffuse
varying vec3 v_specular;  // donor gl_TexCoord[5].xyz = specular
varying vec4 v_shadow;    // donor gl_TexCoord[3] (projective shadow coord)
varying float v_fog_depth;// donor gl_TexCoord[0].w (fog distance)

void vertex() {
	// hf.pvl.sm.vert:9 — gl_ModelViewMatrix * gl_Vertex (eye space).
	vec4 realpos = VIEW_MATRIX * MODEL_MATRIX * vec4(VERTEX, 1.0);
	v_eye = realpos.xyz;

	// hf.pvl.sm.vert:12-15 — donor Blinn-Phong inputs. `NORMAL` is object
	// space in Godot's vertex(); VIEW_MATRIX*MODEL_MATRIX is the PORT ANALOGUE
	// of gl_NormalMatrix (inverse-transpose is engine-side, UNVERIFIED).
	vec3 e = normalize(-realpos.xyz);                 // :12 eye=vec3(0) at :4
	vec3 l = normalize(light_position_eye - realpos.xyz); // :13
	vec3 h = normalize(l + e);                        // :14
	vec3 n = normalize((VIEW_MATRIX * MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz); // :15

	// hf.pvl.sm.vert:18-22, gl_TexCoord[4]/[5] at :37-38.
	vec3 diffuse = max(dot(l, n), 0.0) * diffuse_rgb;              // :19
	if (vertex_color_enabled > 0.5) {
		diffuse *= vertex_color_substitute;                         // :20-21
	}
	v_packed = ambient_rgb + diffuse;                               // :18 + :37
	v_specular = pow(max(dot(h, n), 0.0), shininess) * specular_rgb; // :22, :38

	// hf.pvl.sm.vert:30-32 — eye-plane dot products (texGen=true, shaders.lib:30).
	vec2 st = vec2(dot(realpos, eye_plane_s), dot(realpos, eye_plane_t));
	// hf.pvl.sm.vert:32; r/q set to (0,1). Donor leaves them untouched =>
	// PORT APPROXIMATION of undefined fixed-function state.
	v_st = (texture_matrix * vec4(st, 0.0, 1.0)).xy;
	v_alpha_uv = fract(v_st) * alpha_uv_scale;

	// hf.pvl.sm.vert:35 — shadow coordinate (both engine matrices folded).
	v_shadow = shadow_matrix * realpos;

	// hf.pvl.sm.vert:41-45 — fog distance, vendor branch exposed.
	v_fog_depth = fog_use_abs_z > 0.5 ? abs(realpos.z) : length(realpos);

	v_tile = UV2.x;
	v_face = face_mode_override >= 0.0 ? face_mode_override : UV2.y;
}

// Atlas cell lookup. PORT APPROXIMATION: whole-preset-per-cell packing
// (TERRAIN2-06 §3.2); donor tsDouble/ttExtended sub-tiles are engine-side
// (reftile.lib:3-12). No tile-name -> id table is embedded: the id comes
// verbatim from UV2.x / presets_summer.json:2-125.
vec3 tile_rgb(float idx, vec2 local_uv) {
	float cols = max(atlas_grid.x, 1.0);       // PORT GUARD against unset grid
	float col = mod(idx, cols);
	float row = floor(idx / cols);
	vec2 uv = (vec2(col, row) + local_uv) / atlas_grid;
	return texture(tile_atlas, uv).rgb;         // donor hf.pvl.smx3.frag:13
}

// PORT SUBSTITUTE for donor `shadow2DProj(texShadow, coord).r < 0.999`
// (hf.pvl.smx3.frag:26-28, hf.pvl.smx9.frag:25-33). Projective divide + guard.
float shadow_tap(vec2 delta) {
	vec4 sc = v_shadow;
	vec2 uv = (sc.xy + delta) / max(abs(sc.w), 0.0001); // PORT GUARD
	return texture(shadow_map, uv).r < 0.999 ? 0.0 : 1.0;
}

void fragment() {
	// Donor hf.pvl.smx3.frag:13 — RGB from texUnit0 at gl_TexCoord[0].xy.
	// fract() is the PORT APPROX repeat period (TERRAIN2-06 §3.4 (b)).
	vec3 rgb = tile_rgb(v_tile, fract(v_st * uv_repeat));

	// Donor hf.pvl.smx3.frag:14 — alpha from texUnit1 at gl_TexCoord[1].xy.
	float a;
	int face = int(v_face + 0.5);
	if (face == 1 || face == 2) {
		// Face refkeys swap texUnit1 to alphavert (reftile.mat:122, :148;
		// tiles.mat:142-213). RGB deliberately stays the base rock/sand block:
		// rock1vf/rock1vs bind the SAME rock1.dds (tiles.mat:142-148).
		// READ-ONLY DONOR PLANES: front S=(1,0,0,0), T=(0,0,1,0)
		// (reftile.mat:130-141); side S=(0,1,0,0), T=(0,0,1,0)
		// (reftile.mat:156-167); tmmEyeLinear (:129/:155); scale 0.125
		// (:124-126/:150-152). Donor is Z-up, Godot Y-up: donor T(Z,height)
		// -> v_eye.y, donor side S(Y) -> v_eye.z (world3d_terrain.gd:57-58,
		// TERRAIN2-01 §2.5 INFERRED). Axis conversion is PORT APPROXIMATION.
		vec2 mask_uv = (face == 1)
			? vec2(v_eye.x, v_eye.y) * face_scale   // S=X,          T=height
			: vec2(v_eye.z, v_eye.y) * face_scale;  // S=Y (donor),  T=height
		a = texture(alphavert_atlas, mask_uv).a;
	} else {
		// Flat tiles: Texture2Name=alpha (reftile.mat:6), bmTransparency (:17),
		// tmmUser s/t planes (1,0,0,0)/(1,0,0,0) (:39-50, engine expansion
		// UNVERIFIED). PORT APPROX: MultiTexCoord1 -> fract(s,t).
		a = texture(alpha_atlas, v_alpha_uv).a;
	}

	// Donor hf.pvl.smx3.frag:17 — albedo * packed(ambient+diffuse) + specular.
	// gl_Color affects DIFFUSE only (hf.pvl.sm.vert:20-21), never raw albedo.
	rgb = rgb * v_packed + v_specular;

	// Donor hf.pvl.smx3.frag:20-30 / hf.pvl.smx9.frag:20-35 — PCF shadow.
	if (shadow_enabled > 0.5) {
		float of = shadow_offset;                       // 1/512 donor literal
		float sh = 0.0;
		if (shadow_taps < 3.5) {
			// smx3:26-28 — 3 taps, /3.0 (:29), multiply (:30).
			sh += shadow_tap(vec2(0.0));
			sh += shadow_tap(vec2(of, of));
			sh += shadow_tap(vec2(-of, -of));
			sh /= 3.0;
		} else {
			// smx9:25-33 — 9 taps, /9.0 (:34), multiply (:35).
			sh += shadow_tap(vec2(0.0));
			sh += shadow_tap(vec2(of, of));
			sh += shadow_tap(vec2(of, -of));
			sh += shadow_tap(vec2(-of, of));
			sh += shadow_tap(vec2(-of, -of));
			sh += shadow_tap(vec2(0.0, of));
			sh += shadow_tap(vec2(of, 0.0));
			sh += shadow_tap(vec2(0.0, -of));
			sh += shadow_tap(vec2(-of, 0.0));
			sh /= 9.0;
		}
		rgb *= (sh + shadow_color.rgb * (1.0 - sh));    // smx3:30, smx9:35
	}

	// Donor hf.pvl.smx3.frag:34-46 / hf.pvl.smx9.frag:39-51 — fog modes 1/2/3.
	if (fog_mode > 0.0) {
		float fog = 1.0;
		if (fog_mode < 1.5) {
			fog = clamp((fog_end - v_fog_depth) * fog_scale, 0.0, 1.0); // smx3:39 LINEAR
		} else if (fog_mode < 2.5) {
			fog = clamp(exp2(-fog_density * v_fog_depth * 1.442695), 0.0, 1.0); // smx3:42 EXP
		} else {
			fog = clamp(exp2(-pow(fog_density * v_fog_depth, 2.0) * 1.442695), 0.0, 1.0); // smx3:45 EXP2
		}
		rgb = mix(fog_color, rgb, fog);
	}

	// hf.pvl.smx3.frag:50 / hf.pvl.smx9.frag:55 writes the final `vec4 color`.
	// No 25-degree rotation: AngleX/AngleZ = 25 (tiles.lib:119-136) is tile
	// metadata whose path into geometry/texgen is UNVERIFIED (DEEPDEC-02 #5;
	// TERRAIN2-06 UNVERIFIED #2) and is deliberately NOT applied.
	ALBEDO = rgb;
	ALPHA = a;
}
