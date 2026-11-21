# T2-WATER-1 — Independent Donor Water Re-derivation & Exact-Port Gap Audit

**Lane:** RESEARCH only. No Godot runs, no code edits, no donor assets copied into the repo.
**Date:** 2026-11-21.
**Scope:** Donor `C:\Games\Cossacks 3\data\...` (private-use, read-only) vs port
`app/shaders/water_overlay.gdshader` and `app/scripts/world.gd:_setup_water_overlay`.
**Prior pass:** `docs/audit/TERRAIN_DONOR_WATER.md` (TDR-4). That report predates the
current `water_overlay.gdshader`; where it says "port has no water shader" it is now
stale. This document re-derives the donor math from source and resolves its three
headline UNVERIFIED items (§2).

**Labels:** `observed` = directly read from a file/Pillow probe; `derived` =
arithmetic/structural conclusion from observed facts; `inferred` = plausible reading not
proven by plaintext; `UNVERIFIED` = no plaintext evidence found (binding lives in the
binary `cossacks.exe`). Shader equations quoted from source are `observed` *as text*;
runtime sampler bindings are marked separately.

---

## 1. Sources (all file:line are relative to the donor root)

| File | Used for |
|---|---|
| `data/water/water.lib` | Active water record; shader program names; all material params (`water.lib:1-71`) |
| `data/water/water.mat` | Texture slots `DiffuseWaves0/2`, commented `HeightMapWaves0` (`water.mat:1-106`) |
| `data/shaders/water/water.dev.vert` | Active vertex program (`water.lib:67`) |
| `data/shaders/water/water.dev.frag` | Active fragment program (`water.lib:68`) |
| `data/shaders/water/water.frag` / `water.vert` | Alternative (debug) variant, compared in §2.3 |
| `data/shaders/water/water.frag.bak` / `water.vert.bak` | Legacy vertex-wave variant |
| `data/shaders/shaders.lib` | Confirms object shaders live in a *separate* registry; water is bound only by `water.lib` |
| `data/materials/ref/refcubemap.mat` | Cube-map material (`tmmCubeMapReflection`) |
| `data/env/lights/light.cfg:26-31`, `data/env/time.cfg`, `data/env/env.cfg` | Light/clock source |
| `data/gui/menu.inc/eventsettings.inc:155,533-535` | `WaterReflection` engine option (observed) |
| Pillow probe | `heightmapwaves0.tga` alpha extrema, BMP formats |

Port: `app/shaders/water_overlay.gdshader:1-90`, `app/scripts/world.gd:73,766-848,1125-1135,1221-1230`,
`app/scripts/data.gd:23`.

---

## 2. Resolution of the prior UNVERIFIED questions

### 2.1 Which shader variant ships — **RESOLVED: the `.dev` pair** (`derived`, strong)

`water.lib:67-68` names exactly:
```
VertexProgramFileName   = .\data\shaders\water\water.dev.vert
FragmentProgramFileName = .\data\shaders\water\water.dev.frag
```
No other file in `data\water` or `data\shaders\shaders.lib` selects a water program
(`observed`: targeted grep found no alternate reference). The non-`.dev`
`water.frag` contains live debug controls — `vec4 iMouse` and comments "mouse to:
X - change water height / y - change water clarity" (`water.frag:12-15,183-187`) —
and a hard-coded `WATER_LEVEL = 1.5` (`water.frag:182`), i.e. a tuning/demo build,
not the shipped path (`derived`). The `.dev` fragment is the more production-shaped
one: it takes water level from geometry (`gl_TexCoord[1].z`), has shadow/fog paths,
and no `iMouse`. **Conclusion: port the `.dev` pair.** The `.frag`/`.vert` constants
differ materially (§2.3) and must NOT be mixed in.

### 2.2 `hmapTex` — **RESOLVED: engine-supplied terrain height field, NOT `heightmapwaves0.tga`** (`derived`)

Evidence chain:
1. `water.dev.frag:70-75`: `height_map(p)` reads `texture2D(hmapTex,p).w` and
   `h = hmapMin + v.w*(hmapMax-hmapMin)`. Height is in **alpha**.
2. `water.dev.vert:16-17`: `gl_TexCoord[1].xy = MultiTexCoord0.xy/hmapW - 0.5` — the
   sampler is indexed by **world position divided by `hmapW`/`hmapH`**, i.e. one texel
   per terrain grid cell, not by a water quad's UV.
3. `water.lib:60` `HeightMapEnable = True` — the engine supplies a height map.
4. Pillow probe: `heightmapwaves0.tga` is TGA RGBA 256×256 with **alpha extrema
   (255,255) — constant alpha**. Bound raw, `hmapTex.w` would be 1 everywhere and
   `height` would be constant `hmapMax`, making `height > level` true for the whole
   map → no water drawn. It cannot be the functional height source.
5. Its material section is commented out in `water.mat:86-106` and its lib slot is
   commented out in `water.lib:45`.

`derived`: `hmapTex` is the engine's terrain height texture (height in alpha), sized
`hmapW×hmapH`, supplied because `HeightMapEnable=True`. `heightmapwaves0.tga` is a
disabled/debug asset. The literal C++ sampler→texture assignment is in the binary:
**UNVERIFIED** for the exact engine call, but the functional conclusion is firm.

Corollary — `waveMap` (the noise source) is `DiffuseWaves0`: `water.lib:44`
`DiffuseMapLibMaterialName = DiffuseWaves0` and `water.dev.frag:65-68` samples
`waveMap` at `p*(1/256)`, matching the 256² `diffusewaves0.bmp` (`observed` +
`derived`). `DiffuseWaves2` (512², luminance BMP) is in the *NormalMap* slot
(`water.lib:43`) but the `.dev` fragment has **no normal-map sampler** — that slot
is legacy/unused in the shipped shader (`derived`).

### 2.3 `reflectionMap` — **PARTIALLY RESOLVED: a projected reflection texture, not the static cube map** (`inferred`; literal binding UNVERIFIED)

- `water.dev.frag:6,207-210`: `reflectionMap` is sampled with
  `texture2DProj(reflectionMap, refuv)` where `refuv = gl_TexCoord[0].xyw` and
  `gl_TexCoord[0] = gl_TextureMatrix[0]*pos` (`water.dev.vert:15`) — a **projected /
  screen-space coordinate**, the signature of a live planar or screen reflection
  render target, not a `textureCube` lookup (`observed` + `derived`).
- `materials/ref/refcubemap.mat:24-33` defines the six `cubemap_c00..05.bmp` with
  `mappingmode = tmmCubeMapReflection`; `shaders.lib` uses that material for object
  `DecalCubeMap`/`env` shaders via `usedTexLevels` (`shaders.lib:157-194,1056-1093`).
  Nothing in plaintext binds it to water (`observed`). `derived`: the cube map is for
  object reflections, not the water shader.
- `data/gui/menu.inc/eventsettings.inc:155,533-535` exposes a `WaterReflection`
  video option (`observed`) — consistent with an engine-driven real-time reflection
  pass that can be toggled (`inferred`).

`UNVERIFIED`: whether the projected texture is a true planar reflection FBO or a
previous-frame screen copy; the binding is in `cossacks.exe`. **For the port this
does not matter**: a `hint_screen_texture` projected sample reproduces the visible
behaviour (§5).

### 2.4 Which constants drive glint/foam — **RESOLVED: hardcoded literals, not uniforms** (`observed`)

`water.dev.frag:37-47,83` declares every glint/foam constant as a plain `float`/`vec3`
**literal in the shader body**, not a `uniform`. The only runtime knobs from
`water.lib` that reach them are `time`, `texScaleS = 0.1`, `texScaleT = 0.01` (`water.lib:32-33`) and `hdrMultiplier = 1` (`water.lib:25`). `FresnelPower/Bias`,
`DistFactor/BumpFactor`, `ReflectionAmount/WaterAmount` are declared as uniforms but
**commented out** (`water.dev.frag:8-16,203-212`). `WaveFreq/WaveAmp = 0` (`water.lib:26-27`) disable the legacy vertex waves. So "glint/foam tuning" in the donor
is source-level, not engine config (`derived`).

### 2.5 Alternative variant constants (do not mix)

| Constant | `water.dev.frag` (SHIPPED) | `water.frag` (debug) |
|---|---|---|
| `coast2water_fadedepth` | **0.57** (`:37`) | 0.10 (`:21`) |
| `water_softlight_fact` | **170** (`:42`) | 15 (`:26`) |
| `water_glossylight_fact` | **120** (`:43`) | 120 (`:27`) |
| `particle_amount` | **30** (`:44`) | 70 (`:28`) |
| `watercolor` | **(0.1,0.24,0.24)** (`:45`) | (0.43,0.60,0.66) (`:29`) |
| `watercolor2` | **(0,0.025,0.05)** (`:46`) | (0.06,0.07,0.11) (`:30`) |
| `water_specularcolor` | **(0.4,0.4,0.4)** (`:47`) | (1.3,1.3,0.9) (`:31`) |
| `WATER_LEVEL` | `gl_TexCoord[1].z` (geometry, `:167`) | 1.5 literal (`:182`) |
| `height_map()` | `hmapTex.w` (`:70-75`) | 11-octave procedural FBM (`:55-78`) |
| `nautic()` | active 3-octave ×18 (`:106-117`) | stub `return 1.0` (`:112-123`) |
| `iglobaltime` | `time` (`:34`) | `time*3` (`:3`) |

---

## 3. Donor equation — full transcription with constants and source lines

### 3.1 Uniforms, varyings, globals (`water.dev.vert`, `water.dev.frag`)

| Symbol | Value / source | Line |
|---|---|---|
| `time`, `texScaleS`, `texScaleT` | uniforms; `texScaleS=0.1`, `texScaleT=0.01` | frag:1-3; lib:32-33 |
| `waveMap`, `reflectionMap`, `hmapTex`, `shadowMap` | samplers | frag:5-6,18,26 |
| `hdrMultiplier` | 1 (from lib) | frag:14; lib:25 |
| `hmapMin`, `hmapMax`, `hmapW`, `hmapH`, `shadowSize`, `shadowColor`, `fogEnabled`, `shadowed` | engine uniforms | frag:19-28 |
| `eyeVector`, `lightVector`, `fogFragCoord` | varyings | frag:30-32 |
| `iglobaltime` | `time` | frag:34 |
| `light` | `vec3(lightVector)` | frag:48 |
| `m` | `mat2(0.72, -1.60, 1.60, 0.72)` | frag:83 |
| `WATER_LEVEL` | `gl_TexCoord[1].z` = water-plane world Y | frag:167; vert:18 |
| `waveheight` | `clamp(WATER_LEVEL*3.0 - 1.5, 0, 1)` | frag:174 |
| `level` | `WATER_LEVEL + 0.2*water_map(uv*15 + vec2(t*0.1), waveheight)` | frag:175 |
| `deepwater_fadedepth` | `0.5 + 0.57 = 1.07` | frag:168 |

Vertex mapping (`water.dev.vert:15-27`): `gl_TexCoord[0]=TextureMatrix[0]*pos`
(projected reflection UVW); `gl_TexCoord[1].xy=MultiTexCoord0.xy/hmapW - 0.5`,
`.z=pos.y`; `gl_TexCoord[3]=TextureMatrix[3]*cameraModel*MV*pos` (shadow);
`lightVector = vec3(lightPos.x/4, lightPos.z/2, lightPos.y/1)` with
`lightPos=(-0.3447,0.9387,0,1)` (`light.cfg:26-31`) →
**`lightVector = (-0.08618, 0, 0.9387)`** (`observed`+`derived`);
`fogFragCoord = ATI ? abs((MV*pos).z) : length(MV*pos)`.

### 3.2 Noise kernel (`water.dev.frag:51-104`)

```
noise(p)      = waveMap(p * 1/256).x                                  (frag:65-68)
height_map(p) = hmapMin + hmapTex(p).w * (hmapMax-hmapMin)            (frag:70-75)
terrain_map(p)= vec3(0.175,0.1375,0.1) + waveMap(p*8).rgb*0.25       (frag:77-81)

water_map(p,height):
  p2 = p * large_wavesize(2.0)                                       (frag:39,87)
  shift1 = 0.001*(t*160*2, t*120*2) = (0.32t, 0.24t)                 (frag:88)
  shift2 = 0.001*(t*190*2, -t*130*2) = (0.38t, -0.26t)               (frag:89)
  f = 0.6000*noise(p) + 0.2500*noise(p*m) + 0.1666*noise(p*m*m)      (frag:92-94)
  wave = sin(p2.x*0.622 + p2.y*0.622 + shift2.x*4.269)
         * large_waveheight(0.50) * f * height*height                 (frag:38,95)
  p *= small_wavesize(0.5); f=0; amp=1; s=0.5                        (frag:40,97-99)
  repeat 9×: p = m*p*0.947;
             f -= amp*abs(sin((noise(p+shift1*s)-0.5)*2.0));
             amp *= 0.59; s *= -1.329                                 (frag:100-101)
  return wave + f*small_waveheight(0.5)                              (frag:40,103)
```

### 3.3 Foam kernels (`water.dev.frag:106-127`)

```
nautic(p):   p*=18; f=0; amp=1; s=0.5
             repeat 3×: p=m*p*1.2; f+=amp*abs(smoothstep(0,1,noise(p+t*s))-0.5);
                        amp*=0.5; s*=-1.227
             return pow(1-f, 5)                                      (frag:109-114)

particles(p):p*=200; f=0; amp=1; s=1.5
             repeat 3×: p=m*p*1.2; f+=amp*noise(p+t*s);
                        amp*=0.5; s*=-1.227
             return pow(f*0.35, 7)*particle_amount(30)               (frag:121-126)
```

### 3.4 Fragment composite (`water.dev.frag:162-235`, `main` at `:255-262`)

```
uv = gl_TexCoord[1].xy
height = height_map(uv)
if (height > level) -> fragColor = vec4(0); return                    (frag:176-183)
else:
  dif=(0,0.01)
  pos = uv*15/texScaleS*(hmapW/128) + vec2(t*0.01)                   (frag:187)
  h1=water_map(pos-dif); h2=water_map(pos+dif);
  h3=water_map(pos-dif.yx); h4=water_map(pos+dif.yx)                 (frag:188-191)
  normwater = normalize(vec3(h3-h4, h1-h2, 0.15))                    (frag:192)
  wavejitter = normwater.xy * texScaleT(0.01) * (level-height)       (frag:193)
  uv += wavejitter                                                   (frag:194)
  rescolor = CalcTerrain(uv, height)                                 (frag:196)

  coastfade  = clamp((level-height)/0.57, 0, 1)                      (frag:198)
  coastfade2 = clamp((level-height)/1.07, 0, 1)                      (frag:199)
  intensity  = dot(rescolor, vec3(0.2126,0.7152,0.0722))             (frag:200)
  watercolor = mix(watercolor(0.1,0.24,0.24)*intensity,
                   watercolor2(0,0.025,0.05), smoothstep(0,1,coastfade2))  (frag:201)

  refuv = gl_TexCoord[0].xyw; refuv.xy -= wavejitter*refuv.z         (frag:207-208)
  refcol = texture2DProj(reflectionMap, refuv)                       (frag:209)
  refcol.rgb *= (refcol.r+refcol.g+refcol.b)*hdrMultiplier(1)         (frag:210)
  watercolor += refcol.rgb                                           (frag:213)

  r0 = vec3(uv, WATER_LEVEL); rd = normalize(light - r0)              (frag:215-216)
  grad = dot(normwater, rd)                                          (frag:217)
  specular  = pow(grad, 170)                                         (frag:42,218)
  specular2 = pow(grad, 120)                                         (frag:43,219)
  gradpos   = dot(vec3(0,0,1), rd)                                   (frag:220)
  specular1 = smoothstep(0,1, pow(gradpos, 5))                       (frag:221)
  watershade= test_shadow(uv, level)   // 3-tap shadow2DProj          (frag:129-143,222)
  watercolor *= 2.2 + watershade                                     (frag:223)
  watercolor += (0.2+0.8*watershade)*((grad-1.0)*0.5 + specular)*0.25(frag:224)
  watercolor /= (1.0 + specular1*1.25)                               (frag:225)
  watercolor += watershade*specular2*vec3(0.4,0.4,0.4)               (frag:47,226)
  watercolor += watershade*coastfade*(1-coastfade2)
                *(vec3(.5,.6,.7)*nautic(uv) + vec3(1)*particles(uv))  (frag:227)

  rescolor = mix(rescolor, watercolor, coastfade)                    (frag:229)
  resalpha = coastfade2                                              (frag:230)
fragColor = vec4(rescolor, resalpha)                                 (frag:232)
fragColor = fogmap(fragColor)  // linear/exp/exp2                     (frag:237-253,260)
```

`CalcTerrain` (`frag:145-160`): `col = terrain_map(uv)`; finite-diff normal
`normalize(vec3(h3-h4,h1-h2,1))` from `height_map`; `col *= grad + pow(grad,8)`;
`col = mix(col*0.25, col, terrainshade)`.

---

## 4. Current port equation — side-by-side

### 4.1 Shader (`app/shaders/water_overlay.gdshader`)

```
TEXTURE = mask: R=coverage, G=clamp(depth/1.07), B=clamp(depth/0.57)  (shader:5-8)
coverage = texture(TEXTURE, UV).r; discard if < 0.004                 (shader:46-48)
coastfade=m.b; coastfade2=m.g                                        (shader:51-52)
p = UV * map_size * tile_m            // meters                       (shader:54)

field(p):
  s1=(0.125,0.090)*t; s2=(0.140,-0.100)*t; s3=(-0.080,0.065)*t      (shader:36-38)
  a=wave0(fract(p/7 +s1)).r; b=wave1(fract(p/11+s2)).r;
  c=wave2(fract(p/17+s3)).r                                          (shader:39-41)
  return 0.42a + 0.32b + 0.26c                                       (shader:42)

h = field(p); hx = field(p+(0.7,0)); hy = field(p+(0,0.7))            (shader:55-57)
n = normalize(vec3(vec2(hx-h, hy-h)*1.2, 0.15))                       (shader:60)
col = mix((0.10,0.24,0.24), (0,0.025,0.05), smoothstep(0,1,coastfade2))(shader:27-28,63)
col *= 0.80 + 0.40*h                                                  (shader:64)
L = normalize(vec3(sun_dir.x, 0, sun_dir.y)); grad = max(dot(n,L),0)  (shader:69-70)
spec=pow(grad,170)*8; spec2=pow(grad,120)*4;
corona=smoothstep(0,1,pow(grad,5))                                    (shader:71-73)
col += (0.4,0.4,0.4)*(spec+spec2)*(0.2+0.8*corona)                    (shader:29,74)
col += (0.10,0.12,0.14)*pow(grad,24)*0.35                             (shader:75)
band = coastfade*(1-coastfade2)                                       (shader:80)
f1=foam_tex(fract(p*0.16+(0.05,0.03)*t)).r;
f2=foam_tex(fract(p*0.55+(-0.09,0.07)*t)).r                          (shader:81-82)
nautic=pow(1-f1,5); particles=pow(f2,7)*1.5                           (shader:83-84)
col += band*((0.5,0.6,0.7)*nautic*0.9 + (1)*particles*0.5)           (shader:85)
alpha = coverage * mix(0.35, 1.0, coastfade2)                         (shader:88)
COLOR = vec4(col, alpha)                                              (shader:89)
```

### 4.2 Binding & mask (`app/scripts/world.gd`)

| Item | Value | Line |
|---|---|---|
| `WATER_LEVEL` | `-0.25` (mapgen `WATER_DEEP` classification threshold, **not** donor surface Y) | 73 |
| `TILE_M` | `2.0` | `data.gd:23` |
| `sun_dir` | `Vector2(-0.3447/4, 0.9387) = (-0.08618, 0.9387)` → `L≈(-0.0913,0,0.9958)` | 820 |
| `map_size`, `tile_m` | `(MAP_W, MAP_H)`, `2.0` | 821-822 |
| `wave0`, `wave1` | `diffusewaves0.png`, `diffusewaves1.png`, 256² → `_wave_sheet()` mirror-tiled to 1024 | 782-783,769-775 |
| `wave2`, `foam_tex` | both `ter_water` = `diffusewaves2.png`, 512² → tiled to 1024 | 781,825-826 |
| mask | per tile: `wet = terrain==3`, `dep = max(0, -0.25 - height_at(x*2,y*2))`, `G=dep/1.07`, `B=dep/0.57` | 831-837 |
| overlay | `Sprite2D`, scale `TILE_M*view_scale`, LINEAR, z-index −9, `blend_mix` | 840-848 |
| time | `anim_t += dt` and `set_shader_parameter("time", anim_t)` **every frame** | 1226,1229-1230 |

`derived`: the port correctly advances `time` per frame (fixing TDR-4's "frozen water"
caveat), correctly maps the donor light vector direction, and uses the correct donor
tint constants. Everything else in the equation diverges (§5).

---

## 5. Gap table — one row per divergence

| # | Divergence (donor → port) | Visual symptom | Exact proposed fix |
|---|---|---|---|
| 1 | Noise source/scale: donor `noise(p)=waveMap(p/256).x` on ONE 256² luminance sheet (`frag:65-68`); port mixes THREE sheets at `p/7,p/11,p/17` in metres with weights 0.42/0.32/0.26 (`shader:39-42`) and upscales them to 1024 (`world.gd:775`) | Wave pattern/frequency wrong; not donor-like; extra visual noise | Bind only `diffusewaves0.png` as `wave_noise`; sample `texture(wave_noise, fract(p*SC)).r` with `SC` set so one sheet = donor's 256-unit domain; implement `f=0.6*n(p)+0.25*n(p*m)+0.1666*n(p*m*m)` with `m=mat2(0.72,-1.60,1.60,0.72)` |
| 2 | Missing directional swell: donor `sin(p2.x*0.622+p2.y*0.622+shift2.x*4.269)*0.5*f*height²`, `p2=p*2` (`frag:87,95`); port `field()` has no sine term | No rolling cross-swells; water reads as scrolling noise, not waves | Add swell term verbatim with `large_waveheight=0.5`, `large_wavesize=2`, `shift2=(0.38t,-0.26t)`, `0.622`, `4.269`, multiply by `waveheight²` |
| 3 | Time scroll: donor `shift1=(0.32t,0.24t)`, `shift2=(0.38t,-0.26t)`, `pos+=t*0.01`, `uv*15+t*0.1` (`frag:88-89,175,187`); port arbitrary `(0.125,0.09)/(0.14,-0.1)/(-0.08,0.065)` per second (`shader:36-38`) | Animation speed/direction wrong | Replace port scroll vectors with donor shifts scaled into port p-space; use `t*0.01` for the finite-difference position and `t*0.1` for the level sample |
| 4 | Missing 9-octave ridged FBM: donor loop `f-=amp*abs(sin((noise(p+shift1*s)-0.5)*2))`, `amp*=0.59`, `s*=-1.329`, `p=m*p*0.947` ×9 (`frag:100-101`); port = 3 linear texture samples | Missing fine choppy detail / characteristic ridge look | Implement the 9-iteration loop exactly; return `wave + f*0.5` |
| 5 | Normwater: donor 4 central differences of `water_map` at `dif=(0,0.01)` in donor p-space, `normalize(vec3(h3-h4,h1-h2,0.15))` (`frag:186-192`); port forward differences at +0.7 m with gain 1.2 (`shader:56-60`) | Glint density too high/low; slope scale wrong | Recompute `h1..h4` from the ported `water_map(pos±dif)`/`dif.yx`, z exactly 0.15, no 1.2 gain |
| 6 | Wave jitter/refraction: donor `wavejitter=normwater.xy*0.01*(level-height)` displaces terrain UV and reflection UV (`frag:193-194,208`); port none | Flat colour; no refraction shimmer | Compute donor `wavejitter` and offset both terrain-colour sample and reflection sample coords by it |
| 7 | Reflection: donor `refcol=texture2DProj(reflectionMap,refuv); rgb*=(r+g+b)*1; watercolor+=rgb` (`frag:207-213`); port none | Flat colour; no sky/world reflection | Add `uniform sampler2D reflection_tex : hint_screen_texture`, projected UV `refuv.xy -= wavejitter*refuv.w`, multiply by luminance and `hdrMultiplier=1`, add to body (see N-07 perf note) |
| 8 | Under-water luminance: donor `intensity=dot(rescolor,(0.2126,0.7152,0.0722))`, shallow tint multiplied by it, `rescolor=CalcTerrain(...)` (`frag:196,200-201`); port `col*=0.80+0.40*h` (noise) (`shader:64`) | Brightness not tied to bed; wrong shallow tint; flat colour | Sample bed colour (donor `terrain_map` ≈ `(0.175,0.1375,0.1)+waveMap(uv*8)*0.25`) or baked terrain colour, compute Rec.709 luminance, multiply shallow tint before the `mix` |
| 9 | Body/glint chain: donor `*=2.2+shade; +=(0.2+0.8*shade)*((grad-1)*.5+spec)*.25; /=(1+specular1*1.25); += shade*spec2*speccol` (`frag:223-226`); port `*8, *4, *(0.2+0.8*corona)` plus `pow(grad,24)*0.35` extra sheen (`shader:71-75`) | Too-dense / too-bright glints; missing dark corona | Reproduce donor chain exactly: gain `2.2`, additive `0.25*((grad-1)*0.5+pow(grad,170))`, divide by `(1+1.25*corona)`, add `0.4*pow(grad,120)`; delete the `pow(grad,24)*0.35` term |
| 10 | Corona input: donor `gradpos=dot(vec3(0,0,1),rd)` (`frag:220`); port reuses `grad=dot(n,L)` (`shader:73`) | Glint halo shape wrong | Compute separate `gradpos` from the per-pixel ray `rd`; `corona=smoothstep(0,1,pow(gradpos,5))` |
| 11 | Light ray: donor `rd=normalize(light-r0)`, `r0=vec3(uv,WATER_LEVEL)` — varies per pixel (`frag:215-216`); port constant directional `L` (`shader:69`) with `max(dot,0)` clamp (`shader:70`) | Glints uniform instead of position-dependent; wrong density | Use `light_vector=(-0.08618,0,0.9387)`, `rd=normalize(light_vector-vec3(p,water_level))`, `grad=dot(n,rd)` (no clamp); keep donor Z-up convention consistent with port axis mapping |
| 12 | Foam kernels: donor `nautic` 3 octaves ×18 with `amp*=0.5,s*=-1.227`, `pow(1-f,5)` (`frag:109-114`); `particles` ×200, `pow(f*0.35,7)*30` (`frag:121-126`); port single texture fetch `pow(1-f1,5)`, `pow(f2,7)*1.5` (`shader:81-84`) | Wrong foam (absent, or wrong scale/density) | Port both loops verbatim using `wave_noise` as `noise()` source; `nautic=pow(1-f,5)` from 3 octaves, `particles=pow(f*0.35,7)*30` |
| 13 | Foam texture binding: port `foam_tex=diffusewaves2.png` (`world.gd:826`), a separate 512² sheet; donor foam reuses `waveMap` (diffusewaves0) at ×18/×200 | Foam uncorrelated with waves; wrong scale | Bind foam to the same `wave_noise` sampler (diffusewaves0); remove `foam_tex` |
| 14 | Depth resolution: donor depth per **pixel** from `height_map` at every fragment (`frag:170,198-199`); port depth baked **per tile** (1 px = 2 m) and LINEAR-filtered (`world.gd:831-837,845`) | Stepped shoreline / hard edge; 0.57 m foam band aliases at 2 m sampling | Bake a higher-res height texture (e.g., 4 samples/tile) into a `height_tex` uniform and compute `level-height` per fragment in the shader; or, minimum fix, widen the band and keep LINEAR feather |
| 15 | Water level semantics: donor `WATER_LEVEL` = surface world Y with `waveheight=clamp(WATER_LEVEL*3-1.5,0,1)` (`frag:167,174`); port `-0.25` = classification threshold → `waveheight=0` (`world.gd:73`) | Swell amplitude kills itself; depth underestimated → water too shallow/light | Introduce separate `water_level` uniform with donor semantics (surface Y), compute `waveheight` from it; keep `-0.25` only for the mask wet/dry test |
| 16 | Alpha: donor `resalpha=coastfade2` and `rescolor=mix(rescolor,watercolor,coastfade)` (`frag:229-230`); port `alpha=coverage*mix(0.35,1,coastfade2)` (`shader:88`) | Hard edge / shallow water too opaque; no translucent shallow band | Use `alpha = coverage*coastfade2` (optionally `coastfade` for shallows); remove the 0.35 floor |
| 17 | Fog on water: donor `fogmap()` linear/exp/exp2 on final colour (`frag:237-253,260`); port overlay has no fog term | Water doesn't fade with distance; hard edge at fog boundary | Apply the port's existing fog factor to `col` (and alpha) in the overlay shader with donor-equivalent linear/exp/exp2 modes |
| 18 | Shadow on water: donor 3-tap `shadow2DProj`, `watershade` in body/specular/foam (`frag:129-143,222-227`); port none | Glints/foam ignore shadows | Optional: sample a shadow texture and reproduce `watershade`; low priority, gate on N-07 |

**N-07 guard:** rows 7/8/14 need extra texture fetches. Keep the single full-map quad,
no per-frame chunk re-bake, 2-chunk/frame cap and LRU 24 untouched (`world.gd:934-945`).
If reflection pushes frame time over 250 ms, ship rows 1–6,8–18 without row 7.

---

## 6. Concrete replacement shader plan

**Uniforms (names + values to pass from `world.gd:_setup_water_overlay`):**

| Uniform | Type | Value / source |
|---|---|---|
| `wave_noise` | `sampler2D` (`repeat_enable,filter_linear`) | `diffusewaves0.png` (256² luminance) — donor `waveMap` |
| `reflection_tex` | `sampler2D` (`hint_screen_texture`) | screen texture (row 7, optional) |
| `height_tex` | `sampler2D` (`filter_linear`) | higher-res height in R/A from `game.height_at()` (row 14) |
| `time` | `float` | `anim_t`, advanced every frame (`world.gd:1226,1230`) |
| `water_level` | `float` | donor surface Y (separate from `-0.25`) |
| `light_vector` | `vec3` | `(-0.08618, 0.0, 0.9387)` = `light.cfg` x/4, z/2, y/1 |
| `map_size` | `vec2` | `(MAP_W, MAP_H)` |
| `tile_m` | `float` | `2.0` |
| `texScaleS`, `texScaleT` | `float` | `0.1`, `0.01` (`water.lib:32-33`) |
| `hdrMultiplier` | `float` | `1.0` (`water.lib:25`) |
| `fog_color`, `fog_density`, `fog_mode` | `vec3/float/int` | port fog, donor-equivalent modes |

**Constants to declare as `const` (never uniforms — donor hardcodes them):**

```
const vec2  SHIFT1 = vec2(0.32, 0.24);      // = 0.001*(160*2, 120*2)  frag:88
const vec2  SHIFT2 = vec2(0.38,-0.26);      // = 0.001*(190*2,-130*2) frag:89
const mat2  M = mat2(0.72,-1.60, 1.60,0.72);                    // frag:83
const float LARGE_WAVEHEIGHT=0.50, LARGE_WAVESIZE=2.0;          // frag:38-39
const float SMALL_WAVEHEIGHT=0.50, SMALL_WAVESIZE=0.50;         // frag:40-41
const float SOFT=170.0, GLOSSY=120.0, PARTICLE_AMOUNT=30.0;     // frag:42-44
const float COAST_FADE=0.57, DEEP_FADE=1.07;                    // frag:37,168
const vec3  WATERCOLOR=vec3(0.10,0.24,0.24), WATERCOLOR2=vec3(0.0,0.025,0.05);
const vec3  SPECCOLOR=vec3(0.4,0.4,0.4);                        // frag:45-47
const vec2  DIF=vec2(0.0,0.01);                                 // frag:186
const vec3  LUMA=vec3(0.2126,0.7152,0.0722);                    // frag:200
```

**Function order:** `noise(p)` → `water_map(p,height)` (swell + 9-octave loop) →
`nautic(p)`/`particles(p)` (3-octave loops) → `normal_from_water_map()` (4 taps) →
`fragment()` composite in the exact order of §3.4. Use `fract()`-wrapped UVs with
`repeat_enable` (Compatibility-safe); no compute, no SDFGI, no 3D-only effects.

**Mask channels to keep:** `R=coverage` (wet/dry), `G=clamp(depth/1.07)`,
`B=clamp(depth/0.57)` — but replace `depth` with a higher-resolution height source
(row 14) and drop the `mix(0.35,1.0,...)` alpha floor (row 16).

---

## 7. Claim table

| Claim | Evidence | Method | Verdict |
|---|---|---|---|
| Shipped water shader is `water.dev.vert/frag` | `water.lib:67-68`; no alternate selector; `.frag` has `iMouse` debug | Read + grep | **derived** (strong); literal binary load UNVERIFIED |
| `reflectionMap` is a projected texture, not the cube map | `texture2DProj` + `TextureMatrix[0]` (`frag:6,207-210`; vert:15); `refcubemap.mat:33` used by object shaders in `shaders.lib` | Read | **inferred**; exact binding **UNVERIFIED** |
| `hmapTex` = engine terrain height field, not `heightmapwaves0.tga` | `.w` height (`frag:70-75`), world/`hmapW` indexing (vert:16-17), `HeightMapEnable=True` (lib:60), TGA alpha constant 255 (Pillow) | Read + Pillow | **derived**; literal engine binding UNVERIFIED |
| `heightmapwaves0.tga` alpha carries height | Commented `tfNormalMap` slot (`water.mat:96`); Pillow alpha (255,255) | Pillow | **refuted**: constant alpha cannot encode height under raw sampling |
| `waveMap` = `DiffuseWaves0` (256²) | `water.lib:44`, `noise` scale `1/256` (`frag:67`), 256² BMP | Read + derived | **derived** |
| `DiffuseWaves2` (normal slot) is unused by shipped water shader | `water.lib:43`; `.dev.frag` has no normal sampler | Read | **derived** |
| Glint/foam constants are hardcoded, not engine config | `frag:37-47,83` are literals; only `time/texScaleS/T/hdrMultiplier` are uniforms | Read | **observed** |
| Donor sun vector → `(-0.08618, 0, 0.9387)` | `light.cfg:26-31` + `vert:22` mapping | Read + derived | **derived** |
| Port light mapping is directionally correct | `world.gd:820` + `shader:69-70` | Read | **observed** (but ray is constant, row 11) |
| Port advances `time` every frame | `world.gd:1226,1229-1230` | Read | **observed** |
| Port exposes a water shader at all | `app/shaders/water_overlay.gdshader` exists | Read | **observed** (TDR-4 §5 claim "no port shader" is stale) |
| Port foam uses `diffusewaves2.png`, single-fetch kernels | `world.gd:826`, `shader:81-84` | Read | **observed** |
| Port depth baked per tile, 2 m resolution | `world.gd:831-837`, `data.gd:23` | Read | **observed** |
| Donor has current arrows | No `current` symbol in water shader/lib/mat/env | Search | **UNVERIFIED / no evidence** — do not schedule |
| Reflection cube map is bound to water | `refcubemap.mat` + `texture2DProj` mismatch | Read | **refuted as inferred binding**; UNVERIFIED at binary level |
| `WaterReflection` engine option exists | `eventsettings.inc:155,533-535` | Read | **observed** |

---

## 8. Bottom line

The port has the right *intent* (per-frame GPU clock, correct tint constants, correct
sun direction) but reproduces almost none of the donor's actual **wave synthesis**:
it swaps the donor's single 256² fBm + sine swell + 9-octave ridge loop for three
linearly-mixed textures, drops refraction/reflection, replaces the donor's calibrated
glint chain with ad-hoc ×8/×4 gains and an extra sheen term, and replaces the donor's
3-octave ×18/×200 foam with single texture fetches at the wrong scale. Depth is baked
at 2 m per tile instead of per pixel. The highest-value corrections are gap rows
1–6 and 8–13 (flat colour / too-dense glints / wrong foam); rows 7, 14, 17–18 are
conditional on the N-07 250 ms gate. No code was changed and no donor asset copied.
