shader_type canvas_item;
render_mode blend_mix;

// TB-B1c / TDR-4 W-1..W-4: per-frame GPU water for the Compatibility renderer.
// The Sprite2D's TEXTURE is the per-tile mask baked in world.gd:
//   R = water coverage (type-3 grid; LINEAR filter feathers the shoreline)
//   G = clamp(depth / 1.07, 0, 1)   (deepwater_fadedepth = 0.50 + 0.57)
//   B = clamp(depth / 0.57, 0, 1)   (coast2water_fadedepth)
// Only one full-map quad is drawn: no screen texture, no compute, no 3D effects.

// Three distinct donor wave sheets (all mirror-tileable, wrapped with fract()):
//   wave0 = diffusewaves0.png (256², active diffuse map, normalised to 1024)
//   wave1 = diffusewaves1.png (256², normalised to 1024)
//   wave2 = diffusewaves2.png (512², active normal-map slot in water.lib)
uniform sampler2D wave0 : repeat_enable, filter_linear;
uniform sampler2D wave1 : repeat_enable, filter_linear;
uniform sampler2D wave2 : repeat_enable, filter_linear;
// Second scrolling scale of wave2 feeds the coarse/fine foam noise.
uniform sampler2D foam_tex : repeat_enable, filter_linear;

uniform float time;        // advanced EVERY frame from world.gd:sync
uniform vec2  sun_dir;     // mapped light direction (light.cfg Position /4, /1)
uniform vec2  map_size;    // (MAP_W, MAP_H) in tiles
uniform float tile_m;      // meters per tile

// Measured constants from water.dev.frag (TDR-4 §3c).
const vec3  WATERCOLOR      = vec3(0.10, 0.24, 0.24);   // shallow tint
const vec3  WATERCOLOR2     = vec3(0.00, 0.025, 0.05);  // deep tint
const vec3  WATER_SPECCOLOR = vec3(0.40, 0.40, 0.40);
const float COAST_FADE      = 0.57;
const float DEEP_FADE       = 1.07;   // 0.50 + 0.57

// fBm-like crossing swells. shift1/shift2 from water.dev.frag are two
// independent time scrolls; the third octave crosses them (W-6).
float field(vec2 p) {
    vec2 s1 = vec2( 0.125,  0.090) * time;
    vec2 s2 = vec2( 0.140, -0.100) * time;
    vec2 s3 = vec2(-0.080,  0.065) * time;
    float a = texture(wave0, fract(p / 7.0 + s1)).r;
    float b = texture(wave1, fract(p / 11.0 + s2)).r;
    float c = texture(wave2, fract(p / 17.0 + s3)).r;
    return a * 0.42 + b * 0.32 + c * 0.26;
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
    float hx = field(p + vec2(0.7, 0.0));
    float hy = field(p + vec2(0.0, 0.7));
    // donor normwater = normalize(vec3(h3-h4, h1-h2, 0.15)); the slope gain
    // adapts the donor's 0.15 z to this port's wave amplitude.
    vec3 n = normalize(vec3(vec2(hx - h, hy - h) * 1.2, 0.15));

    // Depth-driven shallow -> deep colour (donor mix + smoothstep).
    vec3 col = mix(WATERCOLOR, WATERCOLOR2, smoothstep(0.0, 1.0, coastfade2));
    col *= 0.80 + 0.40 * h;              // wave-driven light/dark on the body

    // Sun-linked glints: grad = dot(normwater, rd); pow(170) soft, pow(120)
    // glossy, pow(5) corona. L is mapped from env/lights/light.cfg Position
    // (-0.3447, 0.9387, 0) -> (-0.086, 0, 0.939), i.e. almost straight up.
    vec3 L = normalize(vec3(sun_dir.x, 0.0, sun_dir.y));
    float grad = max(dot(n, L), 0.0);
    float spec    = pow(grad, 170.0) * 8.0;
    float spec2   = pow(grad, 120.0) * 4.0;
    float corona  = smoothstep(0.0, 1.0, pow(grad, 5.0));
    col += WATER_SPECCOLOR * (spec + spec2) * (0.20 + 0.80 * corona);
    col += vec3(0.10, 0.12, 0.14) * pow(grad, 24.0) * 0.35;  // broad sheen

    // Procedural foam, confined to coastfade * (1 - coastfade2): donor
    // nautic() = pow(1-f,5) over 3 octaves x18, particles() = pow(f*0.35,7)*30
    // over 3 octaves x200. Two scrolling samples stand in for those octaves.
    float band = coastfade * (1.0 - coastfade2);
    float f1 = texture(foam_tex, fract(p * 0.16 + vec2(0.05, 0.03) * time)).r;
    float f2 = texture(foam_tex, fract(p * 0.55 + vec2(-0.09, 0.07) * time)).r;
    float nautic    = pow(1.0 - f1, 5.0);
    float particles = pow(f2, 7.0) * 1.5;
    col += band * (vec3(0.5, 0.6, 0.7) * nautic * 0.9 + vec3(1.0) * particles * 0.5);

    // donor resalpha = coastfade2; coverage keeps the overlay on water cells.
    float alpha = coverage * mix(0.35, 1.0, coastfade2);
    COLOR = vec4(col, alpha);
}
