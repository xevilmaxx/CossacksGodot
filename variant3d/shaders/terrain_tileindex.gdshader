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
// donor-block atlas; donor alpha/alphavert masks; TRN-SHADER world-ground XZ
// texgen at 2 m/cell (donor gc_meters_to_tile=2, dmscript.global:171) replacing
// the old camera-swimming eye-plane defaults; the real donor sun
// (light.cfg:2-31) replacing the zero headlight; donor vertex-packed
// Blinn-Phong, 3-/9-tap PCF and fog equations.
//
// WHAT THIS SHADER IS NOT: bit-exact donor parity. Every substitute is marked
// PORT APPROXIMATION, PORT SUBSTITUTE or PORT GUARD. Visual parity is
// UNVERIFIED — no GPU A/B was run. See V786_tileindex_shader.md.
// ============================================================================

// Donor `BlendingMode = bmTransparency` (reftile.mat:17; reftilealpha.mat:17).
// One Godot `blend_mix` pass is a PORT APPROXIMATION of the donor's multi-pass
// fixed-function blend (ENGINE, TERRAIN2-01 UNVERIFIED #4).
//
// `unshaded` CHOICE (TRN-SHADER, V3D-02 F2): KEPT. This shader reproduces the
// DONOR's own final colour — per-vertex Blinn-Phong packed at
// hf.pvl.sm.vert:37-38 and combined at hf.pvl.smx3.frag:17, then PCF (:20-30)
// and fog (:34-46), with the final write at hf.pvl.smx3.frag:50. The donor sun
// is now consumed INSIDE this shader (donor_sun_position, light.cfg:26-31), so
// Godot lighting must NOT shade ALBEDO a second time. The donor has no
// `unshaded` flag — this is a PORT render-mode decision, not a donor value.
// Shadows stay OFF (shadow_enabled=0): explicit prior A/B decision, unchanged.
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
// miNearest — no mipmaps on masks). B01 changes only the PORT hint below.
// B01 PORT APPROXIMATION (F04 §5 P0-4; Charter §2 item 3): tile_atlas now uses
// `filter_linear_mipmap` instead of `filter_nearest_mipmap`, so nearest
// magnification of the repeating cell cannot band at shallow cameras. This is
// NOT donor parity: donor maNearest/miNearestMipmapLinear stays the cited
// intent (reftile.mat:29-37); no anisotropic claim (A08 §7 #4, reftile.mat:24).
uniform sampler2D tile_atlas : filter_linear_mipmap_anisotropic, repeat_enable;
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
// Ground texgen — STABLE WORLD-GROUND XZ (TRN-SHADER; V3D-02 P2/F1).
// Donor equation shape is retained (DEEPDEC-02 §3.2, hf.pvl.sm.vert:9,25-33):
//   realpos = gl_ModelViewMatrix * gl_Vertex               :9  (kept for masks)
//   s = dot(POSITION, gl_EyePlaneS[0])                      :30
//   t = dot(POSITION, gl_EyePlaneT[0])                      :31
//   gl_TexCoord[0] = gl_TextureMatrix[0] * gl_TexCoord[0]   :32
//   texGen = true                                           shaders.lib:30
// CHANGED: POSITION is now `MODEL_MATRIX * VERTEX` (WORLD space), not
// eye-space `realpos`. The old defaults made t = eye-space Y (height mixed
// with view depth) -> camera-swimming art at a 1 m repeat (V3D-02 P2).
// World X/Z is the ground plane of the port mesh (world3d_terrain.gd:664-729;
// donor is Z-up, Godot Y-up, TERRAIN2-01 §2.5).
//
// DONOR-GROUNDED SCALE: `gc_meters_to_tile = 2` (read verbatim this agent at
// data\scripts\dmscript.global:171) => ONE atlas cell per 2 m of ground;
// `uv_repeat = 0.5` below is exactly 1/2 m. The donor `fract()` repeat and
// nearest filtering intent are kept (hf.pvl.smx3.frag:13; reftile.mat:29-37).
//
// PORT APPROXIMATION — NOT DONOR PARITY: the donor runtime
// gl_EyePlaneS/T[0] and gl_TextureMatrix[0] VALUES for the ground refkey are
// engine-bound and CONFIRMED_UNVERIFIED (RV-TRN-01 verdict A / §5;
// hf.pvl.sm.vert:921,976; reftile.mat:34,38-48 writes tmmUser S/T=(1,0,0,0),
// TextureScale=1 instead). These world-plane values are STABLE SUBSTITUTES,
// never a recovered donor literal. The face alpha planes are different: those
// ARE recovered donor literals (see fragment()).
// ----------------------------------------------------------------------------
uniform vec4 eye_plane_s = vec4(1.0, 0.0, 0.0, 0.0);        // PORT APPROX: world X
uniform vec4 eye_plane_t = vec4(0.0, 0.0, 1.0, 0.0);        // PORT APPROX: world Z
uniform mat4 texture_matrix = mat4(1.0);                    // APPROX (engine value UNVERIFIED)

// Donor-cited constant. `TextureScale X/Y/Z = 0.125` on BOTH face refkeys:
// verticalfront reftile.mat:124-126; verticalside reftile.mat:150-152.
// How it propagates into gl_TextureMatrix[0] is UNVERIFIED (DEEPDEC-02 #6).
uniform float face_scale = 0.125;

// ----------------------------------------------------------------------------
// TRN-SHADER — REAL DONOR SUN (V3D-02 P3/F2), replacing the `light_position_eye
// = 0` headlight. Every value below was re-read verbatim this agent from
// `data\env\lights\light.cfg`:
//   Position X/Y/Z/W = -0.344731152057648 / 0.938701450824738 / 0 / 1 (:26-31)
//   Ambient  RGB     = 0.196078434586525 / 0.184313729405403 / 0.129411771893501 (:2-7)
//   Diffuse  RGB     = 0.811764717102051 / 0.780392169952393 / 0.694117665290833 (:9-14)
// Donor `LightStyle = lsParallel` (light.cfg:17): the vector is a CONSTANT
// DIRECTION, never an eye-space point to subtract `realpos` from (that was
// the headlight). TERRAIN-DARK-FIX2 — LIGHT-02 (`reports/LIGHT_02_light_space.md`
// §3.1-§3.4, §5.4) re-derived donor light space: light.cfg Position is a
// WORLD-oriented sun DIRECTION in a Y-UP world; Y=0.938701 is the elevation.
// Donor Y-up -> Godot Y-up is the IDENTITY on axes — map P.xyz directly.
// The earlier TERRAIN-DARK-FIX axis swap was correct but kept the water-local
// /4,/2 art scales (LIGHT-02 §3.3, §5.6); those are now dropped. The engine's
// GL `w` / modelview submission of gl_LightSource[0].position stays UNVERIFIED
// (LIGHT-02 §7.1; RV-TRN-01 A; DEEPDEC-02 #4/#7). The former material energies
// (ambient 0.15686 reftile.mat:52-56/:80-84; diffuse 0.78125 :58-62/:86-90)
// are deliberately NOT used as defaults now that the light colours are known.
// No visual parity is claimed: a prior raw-swap A/B measured only +0.9 luma.
// ----------------------------------------------------------------------------
uniform vec3 donor_sun_position = vec3(-0.344731152057648, 0.938701450824738, 0.0);
// Donor light.cfg:26-31 Position.xyz. W=1 in the donor config; `lsParallel`
// (light.cfg:17) is why it is consumed as a direction here, not a point.

uniform vec3 ambient_rgb = vec3(0.196078434586525, 0.184313729405403, 0.129411771893501);
// Donor light.cfg:2-7 Ambient (was the material ambient 0.15686).

uniform vec3 diffuse_rgb = vec3(0.811764717102051, 0.780392169952393, 0.694117665290833);
// Donor light.cfg:9-14 Diffuse (was the material diffuse 0.78125).

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
uniform vec2 uv_repeat = vec2(0.5, 0.5);
// TRN-SHADER: 0.5 = 1 / 2 m — donor `gc_meters_to_tile = 2`
// (dmscript.global:171, read verbatim). Multiplier on fract(s,t) AFTER the
// world-ground XZ projection, so one atlas cell repeats every 2 m of ground.
// The old (1,1) on eye-space realpos gave a camera-dependent 1 m repeat.
// NOTE: donor `TextureScale = 1` (terrain.lib:5-10) is a different quantity;
// no donor TextureMatrix scale was ever readable (RV-TRN-01 verdict A).

uniform vec2 alpha_uv_scale = vec2(1.0);
// Donor mask UV is a SECOND per-vertex coordinate set:
// `gl_TexCoord[1] = gl_MultiTexCoord1` (hf.pvl.sm.vert:34) sampled at
// hf.pvl.smx3.frag:14. Flat tiles use tmmUser with s-plane (1,0,0,0) and
// t-plane (1,0,0,0) (reftile.mat:39-50) whose engine expansion is UNVERIFIED.
// We substitute fract(s,t) (TERRAIN2-06 §3.4); this is an escape hatch.

uniform float face_mode_override = -1.0;
// -1 = use per-vertex `UV2.y` face mode. >=0 forces 0=ground / 1=front /
// 2=side for every cell. Port-only, for A3 before A5 face flags exist.
// FIX-TERRAIN: world3d_terrain.gd now WRITES 1/2 on donor-slope cells, so
// the per-vertex path is live; the override stays a diagnostic escape hatch.

uniform float mask_to_alpha = 1.0;
// MASK-ALPHA-FIX-01 — DIAGNOSTIC KNOB, SHIPPED VALUE KEPT AT 1.0.
// Donor `bmTransparency` (reftile.mat:17) blends texUnit1.a over a SECOND
// base-tile pass (DTRN-01 C17; hf.pvl.smx3.frag:13-17); the port has only ONE
// blend_mix pass. FIX-TERRAIN wrote the whole-mask intensity to framebuffer
// ALPHA, so low-mask transition cells became semi-transparent and let the
// bright port sky bleed through (WHITE_MARKS_PIX_01: 89.16 % of near-white px
// are exactly the rendered sky cyan, in 11,738 isolated components). The port
// now keeps terrain OPAQUE and folds the same mask into RGB as a shading
// factor in fragment() instead. This is a PORT APPROXIMATION of the donor
// multi-pass blend (ENGINE/UNVERIFIED, DTRN-01 C17); the exact donor mask
// semantics are UNVERIFIED. 1.0 = shipped mask modulation; 0.0 = no modulation.

// ----------------------------------------------------------------------------
// VERTEX ATTRIBUTE CONTRACT (transport only; donor has no such stream).
//   UV2.x = float(tile_index)  — donor `.tex` id, 0..85 in the shipped dump
//                               (dmscript.global:2026-2035, TERRAIN2-06 E01)
//   UV2.y = face mode: 0=ground (normal refkey, reftile.mat:1-108),
//                      1=verticalfront (reftile.mat:120-144),
//                      2=verticalside  (reftile.mat:146-170).
//           FIX-TERRAIN: world3d_terrain.gd now promotes donor-slope cells to
//           1/2 from texturemap.inc:63-64/438-447/559-575 — PORT APPROXIMATION,
//           NOT DONOR PARITY. Flat cells remain 0 (TERRAIN2-06 §3.1).
// No COLOR / vertex-colour array: donor has zero glColorPointer references
// (DEEPDEC-02 §3.1, verified 0 hits over donor text); `shaders.lib:27` and
// hf.pvl.sm.vert:20-21 read a colour CHANNEL, not a mesh buffer. Do not bind
// COLOR here — use `vertex_color_substitute` if a colour term is wanted.
// ----------------------------------------------------------------------------

varying vec2 v_st;        // donor gl_TexCoord[0].xy (after texture matrix)
varying vec2 v_alpha_uv;  // PORT APPROX gl_TexCoord[1].xy; UNWRAPPED phase (A06-F2)
varying float v_tile;     // integer-valued float index from UV2.x
varying float v_face;     // 0 / 1 / 2
varying vec3 v_eye;       // donor realpos.xyz, for eye-linear face masks
varying vec3 v_packed;    // donor gl_TexCoord[4].xyz = ambient+diffuse
varying vec3 v_specular;  // donor gl_TexCoord[5].xyz = specular
varying vec4 v_shadow;    // donor gl_TexCoord[3] (projective shadow coord)
varying float v_fog_depth;// donor gl_TexCoord[0].w (fog distance)

void vertex() {
	// hf.pvl.sm.vert:9 — gl_ModelViewMatrix * gl_Vertex (eye space). Kept for
	// the recovered face-alpha eye planes and fog; NOT for ground texgen.
	vec4 realpos = VIEW_MATRIX * MODEL_MATRIX * vec4(VERTEX, 1.0);
	v_eye = realpos.xyz;

	// TRN-SHADER — stable WORLD position for RGB texgen (donor model matrix).
	vec4 worldpos = MODEL_MATRIX * vec4(VERTEX, 1.0);

	// hf.pvl.sm.vert:12-15 — donor Blinn-Phong inputs. `NORMAL` is object
	// space in Godot's vertex(); VIEW_MATRIX*MODEL_MATRIX is the PORT ANALOGUE
	// of gl_NormalMatrix (inverse-transpose is engine-side, UNVERIFIED).
	vec3 e = normalize(-realpos.xyz);                 // :12 eye=vec3(0) at :4
	// lsParallel (light.cfg:17): constant donor sun DIRECTION, no subtraction
	// of realpos — this is what removes the old zero-position headlight.
	// TERRAIN-DARK-FIX2 / LIGHT-02 §3.4, §5.4: donor world and Godot world are
	// both Y-up, so map the raw light.cfg Position.xyz straight through. No
	// /4,/2 compression: those are water-local art scales (LIGHT-02 §3.3).
	// VIEW_MATRIX rotates this world direction into the same eye space as `n`
	// (PORT APPROX of the engine's gl_LightSource modelview, UNVERIFIED).
	vec3 sun_world = normalize(vec3(donor_sun_position.x,
		donor_sun_position.y, donor_sun_position.z));
	vec3 l = normalize((VIEW_MATRIX * vec4(sun_world, 0.0)).xyz); // :13
	vec3 h = normalize(l + e);                        // :14
	vec3 n = normalize((VIEW_MATRIX * MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz); // :15

	// hf.pvl.sm.vert:18-22, gl_TexCoord[4]/[5] at :37-38.
	vec3 diffuse = max(dot(l, n), 0.0) * diffuse_rgb;              // :19
	if (vertex_color_enabled > 0.5) {
		diffuse *= vertex_color_substitute;                         // :20-21
	}
	v_packed = ambient_rgb + diffuse;                               // :18 + :37
	v_specular = pow(max(dot(h, n), 0.0), shininess) * specular_rgb; // :22, :38

	// hf.pvl.sm.vert:30-32 — texGen dot products (texGen=true, shaders.lib:30).
	// TRN-SHADER: WORLD-ground XZ, not eye-space realpos; 2 m/cell via
	// uv_repeat=0.5 (donor gc_meters_to_tile=2, dmscript.global:171).
	vec2 st = vec2(dot(worldpos, eye_plane_s), dot(worldpos, eye_plane_t));
	// hf.pvl.sm.vert:32; r/q set to (0,1). Donor leaves them untouched =>
	// PORT APPROXIMATION of undefined fixed-function state.
	v_st = (texture_matrix * vec4(st, 0.0, 1.0)).xy;
	// A06-F2: unwrapped 2 m phase; fract() moved to fragment so mask is not per-cell constant.
	v_alpha_uv = v_st * uv_repeat * alpha_uv_scale;

	// hf.pvl.sm.vert:35 — shadow coordinate (both engine matrices folded).
	v_shadow = shadow_matrix * realpos;

	// hf.pvl.sm.vert:41-45 — fog distance, vendor branch exposed.
	v_fog_depth = fog_use_abs_z > 0.5 ? abs(realpos.z) : length(realpos);

	v_tile = UV2.x;
	v_face = face_mode_override >= 0.0 ? face_mode_override : UV2.y;
}

// Atlas cell lookup. PORT APPROX (TERRAIN2-06 §3.2; reftile.lib:3-12); id = UV2.x / presets_summer.json:2-125.
vec3 tile_rgb(float idx, vec2 local_uv) {
	float cols = max(atlas_grid.x, 1.0);       // PORT GUARD against unset grid
	vec2 cell = vec2(mod(idx, cols), floor(idx / cols));
	// B01 REVISION (owner verdict g04): per-cell mirror variant REMOVED — 2 m axis-aligned
	// flips read as a chessboard. No lattice variant; tile-ID diversity belongs to B03.
	vec2 warp = 0.125 * vec2(sin(dot(v_st, vec2(0.13, 0.07))), cos(dot(v_st, vec2(0.09, 0.11))));
	vec2 inset = 0.5 / max(vec2(textureSize(tile_atlas, 0)) / max(atlas_grid, vec2(1.0)), vec2(1.0)); // A06-F2 half-texel inset
	vec2 uv = mix(inset, 1.0 - inset, fract(local_uv + warp)); // continuous warp only; no luminance field (S-25-09)
	return textureGrad(tile_atlas, (cell + uv) / atlas_grid, dFdx(v_st * uv_repeat) / atlas_grid, dFdy(v_st * uv_repeat) / atlas_grid).rgb; // donor hf.pvl.smx3.frag:13; A06-F2 unwrapped gradients
}

// TRN-SHADER — donor alpha-atlas SUB-RECT sampling (V3D-02 P4/F4).
// DONOR-GROUNDED GEOMETRY: alpha.bmp is 512x256 = 8 cols x 4 rows of 64x64
// patches. Seam deltas jump 64..185 only at x/y multiples of 64 and are ~8
// inside (RV-TRN-01 §4.1, pixel decode; DTRN-06 C15), matching the commented
// `AlphaRows=8, AlphaCols=4, AlphaTileSize=64` (reftile.lib:10-12).
// PORT APPROXIMATION — donor engine rule UNVERIFIED (DALPHA-01 §5 item 5, §6).
// DONOR-GROUNDED STRUCTURE ONLY. Which patch a tile selects is engine-side
// (`tsDouble`/`ttExtended`, reftile.lib:3-12; TileXOffset=0.1/TileYOffset=0.2
// :5-6) and NOT statically readable: 17,237-file scan + packed .bind proof
// (DALPHA-01 §4). We now use the report's derived structure instead of the
// old arbitrary `5 + mod(tile,22)`:
//   * row = boundary direction, measured dark-edge rank N/W/E/S = 0/1/2/3
//     (DALPHA-01 §3.4 / §6.2, DERIVED — not a donor enum);
//   * columns 0-3 / 4-7 are two organic variants of the same four roles
//     (DALPHA-01 §3.3 / §6.5, INFERRED); `variant` is the column within the half;
//   * the opposite tile's mask is the 180-degree counterpart
//     (r,c) <-> (3-r,3-c) within the same half (DALPHA-01 §3.3 / §6.3, DERIVED),
//     only approximately complementary (MAD 9.8-17.6), never asserted exact.
// The port mesh carries ONE tile id per cell (UV2.x) and no neighbour
// direction, so a deterministic decomposition of the tile id stands in for
// direction / half / variant / opposite tile. Constant patches
// (0,0)/(4,0)=255 and (3,3)/(7,3)=0 are donor-authored "no transition"/"full
// cut" roles (§6.4), not a pinning bug. NO donor parity is claimed; the exact
// tile-pair -> patch rule remains CONFIRMED_UNVERIFIED. Sampling below is the
// donor-grounded ((c+u)/8, (r+v)/4) of §6.1 with the 2 m fract phase as (u,v).
vec2 alpha_patch_uv(float tile, vec2 local) {
	float id = floor(abs(tile));
	float dir = mod(id, 4.0);                           // tile-id stand-in for boundary direction
	float row = dir;                                    // N/W/E/S = 0/1/2/3 (DALPHA-01 §3.4)
	float variant = mod(floor(id / 4.0), 4.0);          // 4 column variants within the half
	float half = mod(floor(id / 16.0), 2.0);            // 0 -> cols 0-3, 1 -> cols 4-7
	float opposite = mod(floor(id / 64.0), 2.0);        // stable stand-in for the opposite tile
	row = mix(row, 3.0 - row, opposite);                // counterpart (r,c) -> (3-r,3-c), §6.3
	variant = mix(variant, 3.0 - variant, opposite);    // local column counterpart in same half
	vec2 cell = vec2(half * 4.0 + variant, row);
	// Half-texel inset from the 64² sub-rect border (donor AlphaTileSize=64).
	vec2 t = clamp(local, 0.0078125, 0.9921875);       // 0.5/64 .. 1-0.5/64
	return (cell + t) / vec2(8.0, 4.0);
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
	// TRN-SHADER: `v_st` is world-ground XZ; fract(v_st*0.5) repeats one
	// atlas cell per 2 m (donor gc_meters_to_tile=2, dmscript.global:171).
	vec3 rgb = tile_rgb(v_tile, fract(v_st * uv_repeat));

	// Donor hf.pvl.smx3.frag:14 — alpha from texUnit1 at gl_TexCoord[1].xy.
	float a;
	int face = int(v_face + 0.5);
	if (face == 1 || face == 2) {
		// Face refkeys swap texUnit1 to alphavert (reftile.mat:122,:148; tiles.mat:142-213);
		// RGB stays base rock/sand: rock1vf/vs bind SAME rock1.dds (tiles.mat:142-148).
		// Face-alpha eye planes RESTORED (RV-TRN-01 C/§4.3; reftile.mat:130-141,156-167):
		// front S=X,T=height; side S=Y(donor),T=height; tmmEyeLinear (:129/:155), scale .125
		// (:124-126/:150-152). Donor Z-up->Godot Y-up: T(Z)->v_eye.y, S(Y)->v_eye.z
		// (world3d_terrain.gd:57-58, TERRAIN2-01 §2.5 INFERRED). Axis swap PORT APPROX.
		vec2 mask_uv = (face == 1)
			? vec2(v_eye.x, v_eye.y) * face_scale   // S=X,          T=height
			: vec2(v_eye.z, v_eye.y) * face_scale;  // S=Y (donor),  T=height
		a = texture(alphavert_atlas, mask_uv).a;
	} else {
		// Flat tiles: alpha (reftile.mat:6/:17/:39-50, UNVERIFIED); one 64² sub-rect (:365-378).
		// B01/A02-P1 GUARD (PORT APPROX): (3,3)/(7,3) constant-0 sentinels (DALPHA-01 §6.4;
		// A02-E4 mean 0/255) would make :427 pure black; bypass via the same id decomposition.
		float sid = floor(abs(v_tile));
		float sop = mod(floor(sid / 64.0), 2.0);
		float srow = mix(mod(sid, 4.0), 3.0 - mod(sid, 4.0), sop);
		float sv = mod(floor(sid / 4.0), 4.0);
		float scol = mod(floor(sid / 16.0), 2.0) * 4.0 + mix(sv, 3.0 - sv, sop);
		a = texture(alpha_atlas, alpha_patch_uv(v_tile, fract(v_alpha_uv))).a; // A06-F2: fragment-stage wrap
		// A02-P4 PORT APPROX: compress mask contrast (no dither/noise, S-25-09).
		a = mix(mix(1.0, clamp(a, 0.35, 1.0), 0.5), 1.0, step(2.5, scol) * step(2.5, srow));
	}

	// Donor hf.pvl.smx3.frag:17 — albedo * packed(ambient+diffuse) + specular.
	// gl_Color affects DIFFUSE only (hf.pvl.sm.vert:20-21), never raw albedo.
	// MASK-ALPHA-FIX-01: fold the donor mask into the albedo instead of writing
	// it to framebuffer ALPHA (DTRN-01 C17, donor multi-pass -> one opaque pass).
	// Low-mask cells now shade darker terrain, never sky-coloured gaps.
	rgb = rgb * mix(1.0, a, mask_to_alpha) * v_packed + v_specular;

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
	// MASK-ALPHA-FIX-01: terrain stays OPAQUE — no sky bleed through mask gaps.
	// The donor mask's modulation is now carried by RGB above (DTRN-01 C17).
	ALPHA = 1.0;
}

// ============================================================================
// B-SHADER-AB (Z3_VISUAL_BLEED.md §5.1/§5.3) — PUBLISHED A/B CONTRACT.
// COMMENT-ONLY and additive: no shader behaviour, line or label above changed.
// Every cited line above keeps its number; this block starts after :476.
//
// Exact uniform name for consumer binding by name (terrain-gd owner B):
//     mask_to_alpha
//   Declared at :235 as `uniform float mask_to_alpha = 1.0;`. B binds with
//   set_shader_parameter("mask_to_alpha", <float>) — that exact spelling.
// Range: 0.0 .. 1.0 (float). BOTH endpoints are runtime values of the SAME
//   compiled shader program: no second variant, sampler, branch, patch rule,
//   floor, art or donor claim is introduced here.
//
// A/B pair at IDENTICAL camera (verifier C):
//   1.0 = SHIPPED DEFAULT, unchanged — `rgb = rgb * mix(1.0,a,1.0)
//         * v_packed + v_specular` at :427 (mask folded into RGB); ALPHA=1.0
//         at :475. This is the shipped mask-modulation path.
//   0.0 = flat opaque terrain — `mix(1.0,a,0.0) == 1.0`, so no RGB mask
//         modulation; ALPHA still 1.0 at :475. Only the mask factor differs.
//
// Default, albedo (:392), patch decomposition (:365-378), unshaded rationale
// (:31-38) and all PORT APPROXIMATION / PORT GUARD / PORT SUBSTITUTE /
// UNVERIFIED labels remain untouched. No donor GPU A/B is claimed here.
// Procedure and validation record: reports/B_SHADER_AB.md.
// ============================================================================
