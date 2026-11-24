shader_type spatial;
// V7-84 — donor water fragment equations ported onto the existing flat 4-vertex
// plane. Donor source: C:\Games\Cossacks 3\data\shaders\water\water.dev.frag
// (shipped pair pinned by water.lib:67-68). Every donor literal below carries a
// path:line citation. See docs/coord_swarm_2026-11-24/reports/V784_donor_water_shader.md
// for the donor-vs-approximation ledger and the UNVERIFIED list.
// Cross-checked against DEEPDEC-03 §4/§6
// (ev_b284c02cf7c0727264d5d59d4ed3f2399566c0b1fb505da77f4852ab50fd3cc2).
//
// DEEPDEC-03 §4.1/§6.1: deepColor, shallowColor, reflectionAmount, waterAmount,
// fresnelPower/Bias, distFactor and bumpFactor are declared but COMMENTED OUT in
// the shipped fragment (water.dev.frag:8-16). They are deliberately NOT wired
// here; the LIVE water.lib keys this shader uses are hdrMultiplier, texScaleS/T
// and fogEnabled. Fresnel/eyeVector are likewise not wired (:203-206).
// DEEPDEC-03 §2.2: the 0x853eb8 f32 1.9999998807907104 is an enable BITMASK,
// not a shader float; no numeric descriptor default is provable in the binary.
//
// render_mode unshaded: the donor fragment assembles a FINAL colour (its own
// fake bed lighting + specular + foam), so Godot's lighting must not re-shade
// ALBEDO. blend_mix + explicit ALPHA reproduces the donor's alpha=coastfade2.
render_mode blend_mix, cull_disabled, unshaded;

// ---- Donor-derived uniforms (values set in water3d.gd) --------------------
uniform float water_level;        // -0.25  texturemap.inc:30 (cWaterHeight)
uniform float shore_height;       // -0.1   texturemap.inc:31 (cWaterShoreHeight)
uniform float max_height;         // 2.96   texturemap.inc:29 (cMaxHeight)
uniform float coast_fade_depth;   // 0.57   water.dev.frag:37
uniform float deep_fade_depth;    // 1.07   water.dev.frag:168 (0.5+0.57)
uniform float tex_scale_s;        // 0.1    water.lib:32
uniform float tex_scale_t;        // 0.01   water.lib:33
uniform vec3 shallow_color;       // (0.1,0.24,0.24)  water.dev.frag:45
uniform vec3 deep_color;          // (0,0.025,0.05)   water.dev.frag:46
uniform vec3 spec_color;          // (0.4,0.4,0.4)    water.dev.frag:47
uniform float spec_soft;          // 170    water.dev.frag:42
uniform float spec_glossy;        // 120    water.dev.frag:43
uniform float particle_amount;    // 30     water.dev.frag:44
uniform float hdr_multiplier;     // 1      water.lib:25
uniform vec3 sun_dir;             // donor lightVector (water.dev.vert:22), Y-up

// ---- Port substitutes / approximations (explicitly NOT donor bindings) ----
uniform sampler2D wave_noise : repeat_enable, filter_linear;
// wave_noise = diffusewaves0.png, 256^2, shipped in
// variant3d/assets/terrain/water_png/ (donor water.mat:7,11 tfLuminance).
uniform sampler2D height_tex : filter_linear;
// PORT SUBSTITUTE for donor hmapTex. Donor binding is UNVERIFIED
// (DECOMP-04 §8.1/§8.2: 0x853bde mov edx,0x853e0c -> call 0x405454 only
// assigns a Delphi string; no texture lookup is proven). Default is a neutral
// 1x1 alpha=0 texture => hmapMin (-max_height) => full coverage.
uniform sampler2D reflection_map : filter_linear;
// PORT APPROXIMATION of donor reflectionMap projected FBO (water.dev.frag:207-213);
// engine binding UNVERIFIED (TERRAIN2-03 UNV-2). Disabled by default.
uniform float reflection_enabled;
uniform vec2 map_size;            // port substitute for hmapW/hmapH (water.dev.vert:2-3, UNVERIFIED)
uniform float time;               // donor `time` (water.dev.frag:1), advanced in water3d.gd
uniform int fog_enabled;          // int, donor water.dev.frag:23; 0 default (colors.lib:36 FogMode=0)
uniform vec3 fog_color;           // donor palette Fog (60,100,150)/255 colors.lib:23
uniform float fog_density;        // neutral 0 while fog_enabled==0

varying vec2 v_height_uv;         // donor gl_TexCoord[1].xy (hmap UV)
varying float v_fog_depth;        // port analogue of donor fogFragCoord

const mat2 M = mat2(vec2(0.72, -1.60), vec2(1.60, 0.72)); // water.dev.frag:83

// donor noise(p) = texture2D(waveMap, p*(1./256.)).x — water.dev.frag:65-68
float noise(vec2 p) {
	return texture(wave_noise, fract(p * (1.0 / 256.0))).r;
}

// donor height_map(): hmapMin + v.w*(hmapMax-hmapMin) — water.dev.frag:70-75.
// hmapMin = -max_height, hmapMax = +max_height is a PORT APPROXIMATION from the
// donor plateau/ravine span (texturemap.inc:29 cMaxHeight=2.96;
// generatemap.inc:7 cRavineHeight=-2.964). Donor hmapMin/hmapMax binding UNVERIFIED.
float height_map(vec2 p) {
	float w = texture(height_tex, p).a;
	return -max_height + w * (2.0 * max_height);
}

// donor water_map() — water.dev.frag:85-104, verbatim structure.
float water_map(vec2 p, float hgt) {
	vec2 p2 = p * 2.0;                                    // large_wavesize = 2 (:39)
	vec2 shift1 = 0.001 * vec2(time * 160.0 * 2.0, time * 120.0 * 2.0); // (:88)
	vec2 shift2 = 0.001 * vec2(time * 190.0 * 2.0, -time * 130.0 * 2.0); // (:89)

	float f = 0.6000 * noise(p);                          // (:92)
	f += 0.2500 * noise(p * M);                           // (:93)
	f += 0.1666 * noise(p * M * M);                       // (:94)
	float wave = sin(p2.x * 0.622 + p2.y * 0.622 + shift2.x * 4.269)
		* 0.50 * f * hgt * hgt;                           // (:95) large_waveheight=0.5 (:38)

	p *= 0.5;                                             // small_wavesize = .5 (:40)
	f = 0.0;
	float amp = 1.0;
	float s = 0.5;                                        // (:99)
	for (int i = 0; i < 9; i++) {                         // (:100)
		p = M * p * 0.947;                                // (:101)
		f -= amp * abs(sin((noise(p + shift1 * s) - 0.5) * 2.0)); // (:101)
		amp *= 0.59;                                      // (:101)
		s *= -1.329;                                      // (:101)
	}
	return wave + f * 0.5;                                // (:103) small_waveheight=.5 (:40)
}

// donor nautic() — water.dev.frag:106-117, verbatim.
float nautic(vec2 p) {
	p *= 18.0;
	float f = 0.0;
	float amp = 1.0;
	float s = 0.5;
	for (int i = 0; i < 3; i++) {
		p = M * p * 1.2;
		f += amp * abs(smoothstep(0.0, 1.0, noise(p + time * s)) - 0.5); // scalar broadcast, donor (:113)
		amp *= 0.5;
		s *= -1.227;
	}
	return pow(1.0 - f, 5.0);
}

// donor particles() — water.dev.frag:119-127, verbatim (30 folded via uniform).
float particles(vec2 p) {
	p *= 200.0;
	float f = 0.0;
	float amp = 1.0;
	float s = 1.5;
	for (int i = 0; i < 3; i++) {
		p = M * p * 1.2;
		f += amp * noise(p + time * s);                   // scalar broadcast, donor (:125)
		amp *= 0.5;
		s *= -1.227;
	}
	return pow(f * 0.35, 7.0) * particle_amount;
}

// donor terrain_map() bed colour — water.dev.frag:77-81 (DEEPDEC-03 §4.2).
// PORT APPROXIMATION: only the bed colour is kept. CalcTerrain's 4-tap terrain
// normal, `col *= grad + grad^8` and 3-tap PCF test_shadow (:129-160,196) are
// NOT ported — their engine sampler/FBO bindings are UNVERIFIED (DEEPDEC-03 §6.4).
vec3 terrain_map(vec2 p) {
	return vec3(0.175, 0.1375, 0.1) + texture(wave_noise, fract(p * 8.0 * (1.0 / 256.0))).rgb * 0.25;
}

void vertex() {
	v_height_uv = UV;
	vec4 view_pos = VIEW_MATRIX * MODEL_MATRIX * vec4(VERTEX, 1.0);
	v_fog_depth = -view_pos.z;                            // port analogue of donor fogFragCoord
}

void fragment() {
	// donor mainImage() — water.dev.frag:162-235.
	float WATER_LEVEL = water_level;                      // donor gl_TexCoord[1].z (:167)
	float deepwater_fadedepth = 0.5 + coast_fade_depth;   // (:168)
	float height = height_map(v_height_uv);               // (:170)

	// With the donor -0.25 literal this is clamp(-2.25,0,1)=0, so the coarse
	// swell term (:95) stays at zero. Kept donor-faithful; the 2D app's 1.0 is
	// a port choice and is NOT copied here.
	float waveheight = clamp(WATER_LEVEL * 3.0 - 1.5, 0.0, 1.0); // (:174)
	float level = WATER_LEVEL + 0.2 * water_map(v_height_uv * 15.0 + vec2(time * 0.1), waveheight); // (:175)
	if (height > level) {
		discard;                                          // donor fragColor=vec4(0.0) (:176-182)
	}

	vec2 uv = v_height_uv;
	vec2 dif = vec2(0.0, 0.01);                           // (:186)
	// donor pos uses engine-bound hmapW/128 (UNVERIFIED). Port substitute:
	// map_size.x is the height-grid width set by water3d.gd (water_overlay.gdshader:194-197).
	vec2 pos = uv * 15.0 / tex_scale_s * (map_size.x / 128.0) + vec2(time * 0.01); // (:187)
	float h1 = water_map(pos - dif, waveheight);          // (:188)
	float h2 = water_map(pos + dif, waveheight);          // (:189)
	float h3 = water_map(pos - dif.yx, waveheight);       // (:190)
	float h4 = water_map(pos + dif.yx, waveheight);       // (:191)
	vec3 normwater = normalize(vec3(h3 - h4, h1 - h2, 0.15)); // (:192)
	vec2 wavejitter = normwater.xy * tex_scale_t * (level - height); // (:193)
	uv += wavejitter;                                     // (:194)

	vec3 rescolor = terrain_map(uv);                      // (:196)
	float coastfade = clamp((level - height) / coast_fade_depth, 0.0, 1.0);   // (:198)
	float coastfade2 = clamp((level - height) / deepwater_fadedepth, 0.0, 1.0); // (:199)
	float intensity = dot(rescolor, vec3(0.2126, 0.7152, 0.0722)); // (:200)
	vec3 watercolor = mix(shallow_color * intensity, deep_color, smoothstep(0.0, 1.0, coastfade2)); // (:201)

	// donor projected reflection (:207-213). PORT APPROXIMATION: SCREEN_UV
	// replaces the engine's projective texture-matrix coord; disabled by default
	// and the FBO binding is UNVERIFIED (TERRAIN2-03 UNV-2 / DECOMP-04 §8).
	if (reflection_enabled > 0.5) {
		vec2 ruv = clamp(SCREEN_UV + wavejitter, vec2(0.0), vec2(1.0));
		vec3 refcol = texture(reflection_map, ruv).rgb;
		refcol *= (refcol.r + refcol.g + refcol.b) * hdr_multiplier; // (:210)
		watercolor += refcol;                             // (:213)
	}

	vec3 r0 = vec3(uv, WATER_LEVEL);                      // (:215)
	vec3 rd = normalize(sun_dir - r0);                    // (:216)
	float grad = dot(normwater, rd);                      // (:217)
	// PORT GUARD: donor pow(grad,N) is undefined for grad<0; max() guards the
	// pow() domain only, matching app/shaders/water_overlay.gdshader:245.
	float gc = max(grad, 0.0);
	float specular = pow(gc, spec_soft);                  // (:218)
	float specular2 = pow(gc, spec_glossy);               // (:219)
	float gradpos = dot(vec3(0.0, 0.0, 1.0), rd);         // (:220) donor Z-up
	float specular1 = smoothstep(0.0, 1.0, pow(max(gradpos, 0.0), 5.0)); // (:221)
	// donor test_shadow() returns 1.0 when shadowed != 1 (:129-143); this module
	// has no shadow sampler, so the unshadowed donor branch is taken verbatim.
	float watershade = 1.0;                               // (:222)
	watercolor *= 2.2 + watershade;                       // (:223)
	watercolor += (0.2 + 0.8 * watershade) * ((grad - 1.0) * 0.5 + specular) * 0.25; // (:224)
	watercolor /= (1.0 + specular1 * 1.25);               // (:225) divisor, not multiplier
	watercolor += watershade * specular2 * spec_color;    // (:226)

	// PORT ART (not a donor fragment equation): donor cWaterShoreHeight (-0.1,
	// texturemap.inc:31) is a script-stage shore CLASSIFICATION literal; the
	// shipped fragment never reads it. It is exposed and used only to bound a
	// shoreline band multiplier near the waterline so the literal is traceable.
	// shore_prox ~= 1 for all rendered fragments (height <= level ~= -0.25).
	float shore_prox = 1.0 - smoothstep(water_level, shore_height, level);
	// donor foam (:227). nautic()/particles() are donor; shore_prox is port art.
	watercolor += watershade * shore_prox * coastfade * (1.0 - coastfade2)
		* (vec3(0.5, 0.6, 0.7) * nautic(uv) + vec3(particles(uv)));

	rescolor = mix(rescolor, watercolor, coastfade);      // (:229)
	float alpha = coastfade2;                             // (:230) alpha 0 at waterline

	// donor fogmap() modes 2/3 — water.dev.frag:237-253; mode 1 needs
	// gl_Fog.end/scale, not exposed here, and is left unported. Off by default
	// (colors.lib:36 FogMode=0). v_fog_depth is a port distance, not donor view w.
	if (fog_enabled == 2) {
		float f = clamp(exp2(-fog_density * v_fog_depth * 1.442695), 0.0, 1.0); // (:246)
		rescolor = mix(fog_color, rescolor, f);           // (:250)
	} else if (fog_enabled == 3) {
		float f = clamp(exp2(-pow(fog_density * v_fog_depth, 2.0) * 1.442695), 0.0, 1.0); // (:249)
		rescolor = mix(fog_color, rescolor, f);
	}

	ALBEDO = rescolor;
	ALPHA = alpha;
}
