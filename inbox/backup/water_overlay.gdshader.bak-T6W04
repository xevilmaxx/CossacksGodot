shader_type canvas_item;
render_mode blend_mix;

// T2-BUILD-WATER: per-frame GPU water for the Compatibility renderer, ported
// from the donor water.dev.frag composite (docs/audit/WATER_REPORT.md §3.4).
// The Sprite2D's TEXTURE is the per-tile mask baked in world.gd:
//   R = water coverage (type-3 grid; LINEAR filter feathers the shoreline)
//   G = clamp(depth / 1.07, 0, 1)   (deepwater_fadedepth = 0.50 + 0.57)
//   B = clamp(depth / 0.57, 0, 1)   (coast2water_fadedepth)
// Only one full-map quad is drawn: no screen texture, no compute, no 3D effects.

// Wave sheets (bound in world.gd:_setup_water_overlay):
//   wave0    = diffusewaves0.png  (256² cellular/noise map; donor waveMap)
//   wave1    = diffusewaves1.png  (256², crossing octave)
//   wave2    = diffusewaves2.png  (512² bright fine dither; LOW-WEIGHT detail only)
//   foam_tex = diffusewaves0.png  (donor reuses waveMap for nautic() foam)
// All are mirror-tileable and wrapped with fract().

uniform sampler2D wave0 : repeat_enable, filter_linear;
uniform sampler2D wave1 : repeat_enable, filter_linear;
uniform sampler2D wave2 : repeat_enable, filter_linear;
uniform sampler2D foam_tex : repeat_enable, filter_linear;

uniform float time;        // advanced EVERY frame from world.gd:sync
uniform vec2  sun_dir;     // mapped light direction (light.cfg Position /4, /1)
uniform vec2  map_size;    // (MAP_W, MAP_H) in tiles
uniform float tile_m;      // meters per tile

// Tints are LINEAR pre-output values: the Compatibility renderer encodes
// COLOR to sRGB, so these land on #C3D1CA (pale shallow) / #2B3536 (deep
// slate) after the donor's 2.2 gain and corona divisor (water_deep.md §1.1,
// verdict_water.md §2.2). WATER_SPECCOLOR stays the donor literal (0.4).
const vec3  WATERCOLOR      = vec3(0.56, 0.65, 0.60);
const vec3  WATERCOLOR2     = vec3(0.16, 0.15, 0.145);
const vec3  WATER_SPECCOLOR = vec3(0.40, 0.40, 0.40);
const float COAST_FADE      = 0.57;
const float DEEP_FADE       = 1.07;   // 0.50 + 0.57

// Donor scroll directions (water.dev.frag:88-89: +4:3 and -1.46:1), slowed
// into port p-space. Direction is donor-faithful; magnitude is tuned so a
// crest crosses one tile in 3-5 s (WATER_DEEP §1.4).
const vec2 S1 = vec2( 0.010,  0.0075);
const vec2 S2 = vec2( 0.011, -0.0080);

// D1 anti-aliasing + T3 vein softening. The sheets are white noise with
// mipmaps disabled in their .import files (not owned by this lane). T2's
// four-tap cross at BLUR=0.0015 was only ~1.5 texels of the 1024² mirror-tiled
// sheet = ~0.4 source texels: sub-texel, so it never touched the 1-3 px dark
// cell boundaries of diffusewaves0 (the ONLY spatially-correlated sheet,
// ACF lag1 0.89; wave1/wave2 are white noise, ACF lag1 ~0). Those boundaries
// reached the normal derivatives as dark cellular veins. T3 widens the wave0
// fetch to an 8-tap ring and quadruples the radius so the veins are low-passed
// BEFORE hx/hy are taken, while the low-frequency swell + scroll are kept.
// wave1/wave2 stay on the cheap 4-tap cross (they carry no coherent structure).
const float BLUR = 0.0060;   // ~6.1 texels of the 1024² mirror-tiled sheet (~2.4 px)

float field(vec2 p) {
    vec2 u0 = fract(p / 28.0 + S1 * time);
    vec2 u1 = fract(p / 44.0 + S2 * time);
    vec2 u2 = fract(p / 68.0 + S2 * time * 0.5);
    // wave0: 8-tap ring low-pass -- kills the thin caustic cell walls that
    // previously aliased into dark veins, without removing the large cells.
    float a = 0.125 * (
        texture(wave0, u0 + vec2( BLUR, 0.0)).r +
        texture(wave0, u0 + vec2(-BLUR, 0.0)).r +
        texture(wave0, u0 + vec2(0.0,  BLUR)).r +
        texture(wave0, u0 + vec2(0.0, -BLUR)).r +
        texture(wave0, u0 + vec2( BLUR,  BLUR)).r +
        texture(wave0, u0 + vec2(-BLUR,  BLUR)).r +
        texture(wave0, u0 + vec2( BLUR, -BLUR)).r +
        texture(wave0, u0 + vec2(-BLUR, -BLUR)).r);
    float b = 0.25 * (
        texture(wave1, u1 + vec2( BLUR, 0.0)).r +
        texture(wave1, u1 + vec2(-BLUR, 0.0)).r +
        texture(wave1, u1 + vec2(0.0,  BLUR)).r +
        texture(wave1, u1 + vec2(0.0, -BLUR)).r);
    // waves2 (bright fine dither) is deliberately a LOW-weight detail only:
    // the donor's glints come from the cellular diffusewaves0 sheet, not from
    // the 43%-clipped fine sheet the old port used as both wave2 and foam.
    float c = 0.25 * (
        texture(wave2, u2 + vec2( BLUR, 0.0)).r +
        texture(wave2, u2 + vec2(-BLUR, 0.0)).r +
        texture(wave2, u2 + vec2(0.0,  BLUR)).r +
        texture(wave2, u2 + vec2(0.0, -BLUR)).r);
    // T3: shift weight toward the coherent (now vein-free) wave0 field. The
    // old 0.52/0.40/0.08 mix let the two white-noise sheets (wave1/wave2,
    // ACF lag1 ~0) carry 48% of the variance, so once the veins were blurred
    // away the residual luminance was uncorrelated (ACF lag1 fell to 0.4).
    // 0.92/0.06/0.02 keeps swell/scroll but restores lag1 toward 0.73-0.80.
    return a * 0.92 + b * 0.06 + c * 0.02;
}

void fragment() {
    vec4 m = texture(TEXTURE, UV);
    float coverage = m.r;
    if (coverage < 0.004) discard;   // dry land: no overlay work at all

    // depth proxies baked once per tile into the mask's G/B channels
    float coastfade  = clamp(m.b, 0.0, 1.0);   // depth / 0.57
    float coastfade2 = clamp(m.g, 0.0, 1.0);   // depth / 1.07

    vec2 p = UV * map_size * tile_m;           // map position in meters
    float h  = field(p);
    float hx = field(p + vec2(0.35, 0.0));
    float hy = field(p + vec2(0.0, 0.35));
    // Slope gain/z chosen so the SMOOTHED field (much smaller gradients than
    // the old aliased one) still produces donor-like, non-uniform glints:
    // grad≈1 only at rare coherent crests, not at every 1-px flat spot.
    // T3: lower the slope gain slightly (3.0 -> 2.5) so the normal stays less
    // tilted after the wider blur; grad keeps the donor high-exponent spec
    // terms at ~0 (glints stay 0%) while the soft-shadow term varies less.
    vec3 n = normalize(vec3(vec2(hx - h, hy - h) * 2.5, 0.05));

    // Depth-driven shallow -> deep colour (donor mix + smoothstep). The
    // donor's 2.2 + watershade body gain is applied here; no shadow sampler
    // exists in this port so watershade = 0. A 0.88+0.30*h term plus the
    // coherent swell below keeps body shading (D3) without pixel speckle.
    vec3 col = mix(WATERCOLOR, WATERCOLOR2, smoothstep(0.0, 1.0, coastfade2));
    float watershade = 0.0;
    // Keep the donor body gain intact. The vein fix is purely in the wave0
    // fetch (below): damping this coherent swell term as well would remove
    // the large-scale luminance structure that gives ACF lag1 ~0.75.
    col *= (2.2 + watershade) * (0.88 + 0.30 * h);
    // T3 coherent swell: the donor's deep body carries faint, slowly drifting
    // tonal bands (water_deep.md §1.3, ACF lag1 0.73-0.80) that the cellular
    // sheet's veins only faked. With the veins low-passed away, two very slow
    // low-frequency sines in world space restore that smooth large-scale
    // correlation without reintroducing any cell/wall structure. Uses only
    // existing p/time (no new texture or uniform); scroll is donor-paced.
    float swell = sin(p.x * 0.20 + p.y * 0.06 - time * 0.12)
                + sin(p.x * -0.045 + p.y * 0.17 + time * 0.08);
    col *= 1.0 + 0.050 * swell;

    // Shallow radial-sine ripple arcs (verdict_water G2/M6/M7): faint,
    // coherent crest/trough lines, ~6 px at 16 px/m, confined to the band.
    float band = coastfade * (1.0 - coastfade2);
    vec2 arc_centre = vec2(map_size.x, map_size.y) * tile_m * 0.5;
    float r = length(p - arc_centre);
    float arc = sin(r * 16.0 - time * 2.0);
    col += vec3(0.04, 0.045, 0.04) * arc * band;

    // Sun-linked glints: donor water.dev.frag:215-226. r0 is a per-pixel
    // surface point (small XY scale keeps rd near the mapped sun, avoiding a
    // hard vignette); rd = normalize(sun - r0) varies across the surface.
    vec3 sun = normalize(vec3(sun_dir.x, 0.0, sun_dir.y));
    vec3 r0  = vec3((UV - 0.5) * 0.5, 0.0);
    vec3 rd  = normalize(sun - r0);
    float grad = dot(n, rd);                    // no max() clamp (donor :217)
    float spec  = pow(grad, 170.0);             // no x8 boost (donor :218)
    float spec2 = pow(grad, 120.0);             // no x4 boost (donor :219)
    float gradpos = dot(vec3(0.0, 0.0, 1.0), rd);
    float corona  = smoothstep(0.0, 1.0, pow(gradpos, 5.0));  // from rd (:220-221)
    // Soft term damped by 0.25 (donor value). The coherent grad variation
    // across the large cells is what carries ACF lag1 ~0.75, so it is kept;
    // the fine dark veins were removed upstream by the wave0 8-tap blur.
    // corona DIVIDES (darkens) not multiplies; glossy add capped at 0.4 linear
    // by WATER_SPECCOLOR. No x8/x4 boosts. Broad sheen deleted.
    col += (0.2 + 0.8 * watershade) * ((grad - 1.0) * 0.5 + spec) * 0.25;
    col /= (1.0 + corona * 1.25);
    col += WATER_SPECCOLOR * spec2;

    // Procedural foam (donor nautic()/particles(), water.dev.frag:109-126).
    // particle_amount = 0 (deep-water glint/foam must be absent); nautic is
    // reduced and strictly gated by band = coastfade*(1-coastfade2).
    float f1 = texture(foam_tex, fract(p * 0.03 + vec2(0.05, 0.03) * time)).r;
    float nautic = pow(1.0 - f1, 5.0);
    col += band * vec3(0.5, 0.6, 0.7) * nautic * 0.15;

    // donor resalpha = coastfade2: alpha 0 at the waterline, 1 at 1.07 m.
    // No 0.35 floor -> the flat teal ring is gone.
    float alpha = coverage * coastfade2;
    COLOR = vec4(col, alpha);
}
