shader_type canvas_item;
render_mode blend_mix;

// T6-W04 — water shader re-port. Donor equations transcribed verbatim from
// docs/t6/reports/T6-W01.md §2 (water.dev.vert/frag, byte-offset pinned);
// piece gates + caveats from docs/t6/reports/T6-W02.md §4-§7.
// The Sprite2D TEXTURE is the per-tile mask baked in world.gd:
//   R = water coverage (type-3 grid; LINEAR filter feathers the shoreline)
//   G = clamp(depth / 1.07, 0, 1)  (deepwater_fadedepth)
//   B = clamp(depth / 0.57, 0, 1)  (coast2water_fadedepth)
// ONE noise sampler (donor waveMap = diffusewaves0, 256² tfLuminance,
// miLinearMipmapLinear). wave1/wave2/foam_tex were REMOVED: the donor has a
// single waveMap and foam is purely procedural (W01 §2.7; no foam asset).
// NO reflection in this grant (D3 excluded — W03 governs the future grant).

uniform sampler2D wave_noise : repeat_enable, filter_linear;

uniform float time;          // advanced EVERY frame from world.gd:sync
uniform vec2  sun_dir;       // mapped donor lightVector (world.gd:820, kept)
uniform vec2  map_size;      // (MAP_W, MAP_H) in tiles
uniform float tile_m;        // meters per tile
uniform float water_level;   // donor water-plane Y (0..2); ONLY drives waveheight
                             // = clamp(WATER_LEVEL*3-1.5,0,1). The port's
                             // -0.25 terrain-classification threshold is NOT
                             // this value (W01 §2.5, W04 change group 5).

// ---- Donor literals (observed, W01 §2) ------------------------------------
const mat2  M              = mat2(vec2(0.72, -1.60), vec2(1.60, 0.72)); // frag:83, column-major
const float COAST_FADE     = 0.57;       // frag:37
const float DEEP_FADE      = 1.07;       // 0.5 + COAST_FADE, frag:168
const float TEX_SCALE_S    = 0.1;        // water.lib:32 (observed, NOT the 0.105 comment)
const float TEX_SCALE_T    = 0.01;       // water.lib:33 (observed)
const vec2  SHIFT1         = vec2( 0.32,  0.24);  // frag:88 : (0.32t, 0.24t)
const vec2  SHIFT2         = vec2( 0.38, -0.26);  // frag:89 : (0.38t,-0.26t)
const float SWELL_K        = 0.622;      // frag:95
const float SWELL_P        = 4.269;      // frag:95
const vec3  SPEC_COL       = vec3(0.4, 0.4, 0.4); // frag:47
const float EXPSOFT        = 170.0;      // frag:42, W01 offset 1214
const float EXPGLOSSY      = 120.0;      // frag:43, W01 offset 1311
// A/B result (W04 in-engine, t6w04_water3 vs t6w04_glint_260_180):
// 170/120 => bandA 0.0623% / max 3px; 260/180 => 0.0415% / max 1px.
// Donor exponents win (closer to W02's 0.30-0.80% / 4px median); keep them.
const vec3  DONOR_SHALLOW  = vec3(0.10, 0.24, 0.24);  // frag:45 (pre-gain, documented)
const vec3  DONOR_DEEP     = vec3(0.00, 0.025, 0.05); // frag:46 (pre-gain, NOT final)
const float PARTICLE_AMOUNT= 30.0;       // frag:44

// ---- Calibrated port equivalents (inferred, measured in-engine) -----------
// Those donor tints are PRE-GAIN: the donor body is multiplied by (2.2+watershade)
// and divided by the corona, and its shallow colour also carries the bed
// intensity + projected reflection (:200,:201,:213). This 2D port has no bed
// colour sampler and reflection is excluded (D3), so the calibrated constants
// below reproduce the W02 HARD gate: shallow #C3D1CA (194,208,201) and deep
// (44,53,55) under the same 2.2 gain + corona divisor + WATERSHADE=0.
const vec3 SHALLOW_LIN  = vec3(0.56, 0.65, 0.60);  // calibrated shallow base
const vec3 DEEP_BED_SUB = vec3(0.16, 0.125, 0.095);// calibrated bed substitute;
                             // DONOR_DEEP + DEEP_BED_SUB = (0.16,0.15,0.145)
const float WATERSHADE  = 0.0;   // no shadow sampler in this 2D port
const float BODY_SWELL_AMP = 0.0; // port-art: body swell attenuated to kill the
                             // piece-scale diagonal moire (W02 re-check A:
                             // swell_amp=0 body, NORMALS keep donor full swell).
                             // Never a radial sine.
const float BODY_SPAN   = 120.0;  // port-art body noise span (donor level sample
                             // uses uv*15 in its own uv units; this 2D port's
                             // UV spans the whole map, so the body needs a
                             // wider span to reach W02's cellular scale).
const float BODY_TAPER  = 0.17;   // high-octave attenuation for the BODY only,
                             // emulating donor miLinearMipmapLinear (the
                             // repo PNG has mipmaps/generate=false). Normals
                             // keep the full donor 9-octave spectrum.
const float FOAM_GAIN   = 0.15;  // W02 FOAM_WEAK_GAIN (port-art, not donor)
const float SUN_DIST    = 6.0;   // point-light analogue for per-pixel rd (W02)
const float SLOPE_GAIN  = 30.0;  // W02-calibrated port-art normal xy gain. The
                             // donor has none, but its mipmapped noise gives
                             // sparse glints; this un-mipmapped 2D port needs
                             // W02's measured gain to avoid 32 px tilt plateaus
                             // (D-GA-max) and broad sheen. A/B 170/120 vs the
                             // 260/180 retune is part of this grant's gates.

// donor noise(p) = texture2D(waveMap, p/256).x (:65-68). One 256² sheet.
float noise(vec2 p) {
    return texture(wave_noise, fract(p / 256.0)).r;
}

// donor water_map (frag:85-104, W01 §2.4) — 3-term fBm base + crossing swell +
// 9-octave ridged loop. swell_amp scales ONLY the visible body swell; normals
// always call with 1.0 so the donor tilt spectrum (and sparse glints) survives.
float water_map(vec2 p, float height, float swell_amp, float octave_taper) {
    vec2 p2 = p * 2.0;                       // large_wavesize = 2.0 (:87)
    vec2 shift1 = SHIFT1 * time;
    vec2 shift2 = SHIFT2 * time;

    float f = 0.6000  * noise(p)
            + 0.2500  * noise(M * p)
            + 0.1666  * noise(M * M * p);     // :92-94

    // Crossing swell (never radial): p2.x*0.622+p2.y*0.622+shift2.x*4.269 (:95)
    float wave = sin(p2.x * SWELL_K + p2.y * SWELL_K + shift2.x * SWELL_P)
                 * 0.50 * swell_amp * f * height * height;

    p *= 0.5;                                // small_wavesize = 0.5 (:97)
    f = 0.0;
    float amp = 1.0;
    float s = 0.5;                           // :98-99
    for (int i = 0; i < 9; i++) {            // literal i<9 (:100)
        p = M * p * 0.947;                   // :101
        // octave_taper=0 keeps the donor loops verbatim (normals/level).
        // BODY_TAPER>0 emulates mipmap attenuation of the high octaves.
        float g = clamp(1.0 - octave_taper * float(i), 0.0, 1.0);
        f -= amp * g * abs(sin((noise(p + shift1 * s) - 0.5) * 2.0));
        amp *= 0.59;                         // :101
        s  *= -1.329;                        // :101
    }
    return wave + f * 0.5;                   // small_waveheight = 0.5 (:103)
}

// donor nautic() (frag:106-114, W01 §2.7): p*=18, 3 octaves M*p*1.2,
// f+=amp*|smoothstep(0,1,noise(p+t*s))-0.5|, amp*=0.5, s*=-1.227, pow(1-f,5).
float nautic(vec2 p) {
    p *= 18.0;
    float f = 0.0;
    float amp = 1.0;
    float s = 0.5;
    for (int i = 0; i < 3; i++) {
        p = M * p * 1.2;
        float v = clamp(noise(p + vec2(time * SHIFT1.x * s, time * SHIFT1.y * s)), 0.0, 1.0);
        v = v * v * (3.0 - 2.0 * v);          // smoothstep(0,1,x)
        f += amp * abs(v - 0.5);
        amp *= 0.5;
        s  *= -1.227;
    }
    return pow(clamp(1.0 - f, 0.0, 1.0), 5.0);
}

// donor particles() (frag:119-126, W01 §2.7): p*=200, 3 octaves M*p*1.2,
// f+=amp*noise(p+t*s), amp*=0.5, s*=-1.227, pow(f*0.35,7)*30.
float particles(vec2 p) {
    p *= 200.0;
    float f = 0.0;
    float amp = 1.0;
    float s = 1.5;                           // W02 baker s0=1.5 for particles
    for (int i = 0; i < 3; i++) {
        p = M * p * 1.2;
        f += amp * noise(p + vec2(time * SHIFT1.x * s, time * SHIFT1.y * s));
        amp *= 0.5;
        s  *= -1.227;
    }
    return pow(clamp(f * 0.35, 0.0, 1.0), 7.0) * PARTICLE_AMOUNT;
}

void fragment() {
    vec4 msk = texture(TEXTURE, UV);
    float coverage = msk.r;
    if (coverage < 0.004) discard;   // dry land: no overlay work at all

    // depth ramps baked (sub-tile) into the mask G/B channels
    float coastfade  = clamp(msk.b, 0.0, 1.0);          // depth / 0.57
    float coastfade2 = clamp(msk.g, 0.0, 1.0);          // depth / 1.07
    float depth_m    = coastfade2 * DEEP_FADE;          // (level - height) in m

    float waveheight = clamp(water_level * 3.0 - 1.5, 0.0, 1.0);  // frag:174

    // donor level sample (frag:175): WATER_LEVEL + 0.2*water_map(uv*15+t*0.1)
    vec2 luv = UV * 15.0 + vec2(time * 0.1);
    float level_h = water_map(luv, waveheight, 1.0, 0.0);    // full donor swell
    vec2 buv = UV * BODY_SPAN + vec2(time * 0.01);
    float body_h = water_map(buv, waveheight, BODY_SWELL_AMP, BODY_TAPER);

    // donor normals (frag:186-194): pos = uv*15/TEX_SCALE_S*(hmapW/128)+t*0.01.
    // hmapW has no plaintext default (W01 U5); the port height grid IS map_size,
    // so hmapW <- map_size.x (declared, not invented as a donor literal).
    vec2 pos = UV * (15.0 / TEX_SCALE_S) * (map_size.x / 128.0) + vec2(time * 0.01);
    vec2 dif = vec2(0.0, 0.01);                          // frag:186
    float h1 = water_map(pos - dif,     waveheight, 1.0, 0.0);
    float h2 = water_map(pos + dif,     waveheight, 1.0, 0.0);
    float h3 = water_map(pos - dif.yx,  waveheight, 1.0, 0.0);
    float h4 = water_map(pos + dif.yx,  waveheight, 1.0, 0.0);
    // donor 4 central differences, NO slope gain, NO forward 0.7 m diffs.
    vec3 n = normalize(vec3(vec2(h3 - h4, h1 - h2) * SLOPE_GAIN, 0.15)); // frag:192 + W02 gain

    // donor wavejitter (frag:193-194): normwater.xy*TEX_SCALE_T*(level-height).
    // Offsets BOTH the bed sample coord (juv) and the reflection coord (the
    // latter is intentionally absent in this grant — D3 excluded).
    vec2 wavejitter = n.xy * TEX_SCALE_T * depth_m;
    vec2 juv = UV + wavejitter;

    // ---- depth colour (donor frag:198-201, 223-227) ----
    // Calibrated equivalent of mix(watercolor*intensity, watercolor2,
    // smoothstep(0,1,coastfade2)) followed by *= (2.2+watershade).
    vec3 deep_cal = DONOR_DEEP + DEEP_BED_SUB;           // (0.16,0.15,0.145)
    vec3 col = mix(SHALLOW_LIN, deep_cal, smoothstep(0.0, 1.0, coastfade2));
    col *= (2.2 + WATERSHADE) * (0.92 + 0.16 * body_h);
    // Soft coherent body shading only: the donor's large-scale tone structure
    // is carried by the fBm field above. NO radial sines (W02 FIX-2).

    // ---- glints (donor frag:215-226, verbatim; no x8/x4, no pow(grad,24)) ----
    vec3 light = vec3(sun_dir.x, 0.0, sun_dir.y) * SUN_DIST;  // (-0.08618,0,0.9387)*6
    vec3 r0    = vec3((UV - 0.5) * 4.0, 0.0);       // piece-analogue surface point
    vec3 rd    = normalize(light - r0);             // per-pixel ray (:215-216)
    float grad = dot(n, rd);                        // UNCLAMPED (:217)
    float gc   = max(grad, 0.0);                    // pow() domain guard only
    float spec  = pow(gc, EXPSOFT);                  // :218
    float spec2 = pow(gc, EXPGLOSSY);                // :219
    float gradpos = dot(vec3(0.0, 0.0, 1.0), rd);    // :220
    float corona  = smoothstep(0.0, 1.0, pow(max(gradpos, 0.0), 5.0)); // :220-221
    col += (0.2 + 0.8 * WATERSHADE) * ((grad - 1.0) * 0.5 + spec) * 0.25; // :224
    col /= (1.0 + corona * 1.25);                    // :225 DIVISOR (not multiplier)
    // :226 glossy add. The port has no shadow sampler (WATERSHADE=0), so the
    // donor's watershade factor is folded into the gain; the sparse glints stay.
    col += spec2 * SPEC_COL;                         // :226

    // ---- foam (donor frag:227; nautic()/particles() on wave_noise) ----
    float band = coastfade * (1.0 - coastfade2);     // zero beyond 1.07 m
    vec2 fp = juv * 230.0;                            // W02 P_SPAN analogue
    float foam_n = nautic(fp);
    float foam_p = particles(fp);
    col += band * (vec3(0.5, 0.6, 0.7) * foam_n + foam_p * 0.02)
         * FOAM_GAIN * 8.0;

    // donor resalpha = coastfade2 (:230). Alpha 0 at the waterline, 1 at 1.07 m;
    // no 0.35 floor. coverage gate keeps dry land out. This IS the soft
    // sand -> wash -> water alpha fade (30-50 px source / 60-90 px @720p).
    float alpha = coverage * coastfade2;
    COLOR = vec4(col, alpha);
}
