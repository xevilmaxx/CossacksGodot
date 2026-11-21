# TDR-4 — Donor Water Deep-Dive (Cossacks 3 → Godot port)

**Lane:** RESEARCH/DEEP-DIVE (read-only). No Godot runs, no code edits, no donor assets copied into the repo.
**Date:** 2026-11-21. **Ticket context:** P-21 ("water DONE — partial"), N-07 perf gate (< 250 ms hitch).

---

## 1. Sources / method

All donor paths are under `C:\Games\Cossacks 3\data\...` (private-use only; nothing copied here). All port paths are relative to the repo root `C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3`.

| Method | What was done |
|---|---|
| Plaintext read | `water\water.mat`, `water\water.lib`, six files in `shaders\water\`, `env\env.cfg`, `env\time.cfg`, `env\lights\light.cfg`, `materials\ref\refcubemap.mat` were opened as text (PowerShell `Get-Content -Encoding Default`). These are ASCII config/shader files, not binaries — no hex decoding was required. |
| Binary probe | Pillow (`PIL.Image.open`) read format/mode/dimensions of every image in `water\textures\` and `app\assets\terrain\water_png\`. No pixel data was exported. |
| Grep | `Select-String` over `scripts\common.inc\*.inc` for `water|shore|foam|coast|Wave|waterlevel|depth`; `grep` over `app\scripts\world.gd` for `water|wave|anim_t|chunk`. |
| Targeted read | `app\scripts\world.gd` lines 20–79, 660–889, 889–958; `texturemap.inc` 925–954; `postprocess.inc` 55–119. |

**Labels used below:** `observed` = directly read from a file/Pillow; `derived` = simple arithmetic from observed constants; `inferred` = interpretation that is plausible but not proven by plaintext; `UNVERIFIED` = no evidence found. Shader math is quoted from source, so "rendering equation" is `observed` as *text*; what a given uniform is bound to at runtime is `inferred`/`UNVERIFIED` where the binding is not in plaintext.

**Important scoping note (`observed`):** `water.lib` points the shader at the **`.dev`** variants (`water\water.lib`: `VertexProgramFileName = .\data\shaders\water\water.dev.vert`, `FragmentProgramFileName = ...\water.dev.frag`). The non-`.dev` `water.frag`/`water.vert` are a plausible alternative build and the `.bak` pair is a legacy vertex-wave version. This report treats `water.dev.frag` + `water.dev.vert` as the primary donor water shader and flags differences in the others separately.

---

## 2. Donor water asset table

All rows `observed` via Pillow unless noted.

| File | Format | Dimensions | Role (evidence) |
|---|---|---|---|
| `water\textures\diffusewaves0.bmp` | BMP, RGB | 256×256 | Active **diffuse/wave-noise** map. `water.mat` `base` section: `Image = .\data\water\textures\diffusewaves0.bmp`, `TextureFormat = tfLuminance`, `TextureWrap = twBoth`, `MinFilter = miLinearMipmapLinear`. Bound in `water.lib` as `DiffuseMapLibMaterialName = DiffuseWaves0`. Shader `noise(vec2 p)` samples `waveMap` at `p*vec2(1./256.)` (matches 256²). |
| `water\textures\diffusewaves1.bmp` | BMP, RGB | 256×256 | Unused variant — its `water.mat` section is commented out (`//section.begin ... DiffuseWaves1`). |
| `water\textures\diffusewaves2.bmp` | BMP, RGB | 512×512 | Active **normal-map slot** material: `water.mat` `DiffuseWaves2` section (only `refkey=base`, overrides Image + Name); `water.lib` `NormalMapLibMaterialName = DiffuseWaves2`. Note: despite the slot name, the file is the same `tfLuminance` diffuse format, not a true normal map (`water.mat`, inherited from `base`). |
| `water\textures\diffusewaves3.bmp` … `diffusewaves7.bmp` | BMP, RGB | 512×512 each | Unused variants — all `water.mat` sections commented out. |
| `water\textures\heightmapwaves0.tga` | TGA, RGBA | 256×256 | Dedicated **height / normal-map** asset. `water.mat` commented section: `Name = HeightMapWaves0`, `Image = ...heightmapwaves0.tga`, `TextureFormat = tfNormalMap`, `twBoth`. `water.lib` has it **commented out** (`//NormalMapLibMaterialName = HeightMapWaves0`), replaced by `DiffuseWaves2`. `water.dev.frag` `height_map(vec2 p)` reads a sampler `hmapTex`, taking `v.w` (alpha) as normalized height: `float h=hmapMin+v.w*(hmapMax-hmapMin)`. **UNVERIFIED:** the plaintext never explicitly binds `heightmapwaves0.tga` to the shader's `hmapTex` uniform; the name/format/alpha-height behaviour is consistent with it being the water/terrain height field used for depth + coastline, but the binding is `inferred`. |
| Port `app\assets\terrain\water_png\diffusewaves0..7.png` | PNG, RGB | 0/1: 256×256; 2–7: 512×512 | All eight donor BMPs already converted 1:1 (dimensions and RGB match donor exactly). **Only `diffusewaves2.png` is read by the port** (`world.gd:675`). |
| Port heightmap | — | — | **Absent.** No `heightmapwaves0` file in `water_png/`. |

---

## 3. Decoded water material / shader params table

### 3a. `water.lib` (active `waters[*]` record, `Name = default`)

| Param | Value | Source | Port equivalent |
|---|---|---|---|
| MinDepth / MaxDepth | 0 / 1 | `water.lib` | None (port has no depth concept; water = tile type 3, `world.gd:842,860`). |
| MinAlpha / MaxAlpha | 0 / 1.1 | `water.lib` | None; port blends water via binary tile mask (`world.gd:858-875`). |
| DeepColor | RGBA (0, 0, 0.1255, 0.5) | `water.lib` | Approximated by `ter_blue = Color(0.16, 0.36, 0.44)` (`world.gd:740`). |
| ShallowColor | RGBA (0, 0, 0, 0.5) | `water.lib` | None. |
| ReflectionAmount / WaterAmount | 1 / 1 | `water.lib` | None (no reflection in port). |
| FresnelPower / FresnelBias | 1 / 1 | `water.lib` | None (uniforms commented out in `water.dev.frag`). |
| HDRMultiplier | 1 | `water.lib` | None; used in `water.dev.frag`: `refcol.rgb*=(refcol.x+refcol.y+refcol.z)*hdrMultiplier`. |
| WaveFreq / WaveAmp | 0 / 0 (disabled) | `water.lib` | N/A — legacy vertex-wave synthesis (`water.vert.bak`: `wave[0].freq=waveFreq`, `wave[1].freq=3*waveFreq`). |
| DistFactor / BumpFactor | 1 / 1 | `water.lib` | None; commented out in `water.dev.frag`. |
| TexScaleS / TexScaleT | 0.1 / 0.01 (commented alt: 0.115 / 0.015) | `water.lib` | None; port uses raw pixel crop offset `cx*S+300+phase, cy*S+700` (`world.gd:865`). |
| WaveDir0 / WaveDir1 | (−1, 0) / (−0.7, 0.7) | `water.lib` | None (legacy vertex waves only). |
| Speed | 1.0 | `water.lib` | Port scroll rate `phase = int(anim_t * 12.0) % 1024` (`world.gd:864`) — `derived`: 12 px/s at 1× zoom. |
| NormalMapLibMaterialName | `DiffuseWaves2` | `water.lib` | Port reads `diffusewaves2.png` (`world.gd:675`) — same source file, different use. |
| DiffuseMapLibMaterialName | `DiffuseWaves0` | `water.lib` | Port never reads `diffusewaves0.png`. |
| Width / Height / Offset / LayerCount | 1 / 1 / 0.495 / 1 | `water.lib` | None. |
| HeightMapEnable / ShadowMapEnable | True / True | `water.lib` | None. |
| CustomEnable / CustomReflection / CustomTexCoord | False / False / True | `water.lib` | N/A. |
| MaterialLibraryFileName | `.\data\water\water.mat` | `water.lib` | N/A. |
| DefaultWaterIndex / Tag | 0 / 512 | `water.lib` | N/A. |
| Vertex / Fragment program | `water.dev.vert` / `water.dev.frag` | `water.lib` | Port has **no water shader**; terrain is baked CPU images (`world.gd:909-917`). |

### 3b. `water.mat` texture state (`base` section)

`Compression = tcNone`, `FilteringQuality = tfIsotropic`, `MagFilter = maLinear`, `MinFilter = miLinearMipmapLinear`, `MappingMode = tmmUser`, `TextureFormat = tfLuminance`, `TextureMode = tmReplace`, `TextureWrap = twBoth`, `FaceCulling = fcCull`, `Shader = [nil]`, `Tag = -1`. `HeightMapWaves0` overrides `TextureFormat = tfNormalMap` (commented out). Port import (`diffusewaves2.png.import`): `compress/mode=0`, `mipmaps/generate=false`, `compress/normal_map=0` — i.e. port keeps raw RGB, no mipmaps, no normal-map interpretation.

### 3c. Primary fragment shader constants (`shaders\water\water.dev.frag`)

| Param | Value | Role |
|---|---|---|
| `iglobaltime` | `time` (vertex uses `time*0.02` UV scroll) | animation clock |
| `coast2water_fadedepth` | `0.57` | shoreline fade distance |
| `large_waveheight` / `large_wavesize` | `0.50` / `2.0` | coarse crossing swells |
| `small_waveheight` / `small_wavesize` | `0.5` / `0.5` | small random waves, 9 octaves |
| `water_softlight_fact` / `water_glossylight_fact` | `170` / `120` | soft + glossy highlight exponents (comment: range 1..200) |
| `particle_amount` | `30` | foam sparkle intensity |
| `watercolor` | (0.1, 0.24, 0.24) | shallow water tint |
| `watercolor2` | (0, 0.025, 0.05) | deep water tint |
| `water_specularcolor` | (0.4, 0.4, 0.4) | glint colour |
| `m` | `mat2(0.72, -1.60, 1.60, 0.72)` | FBM rotation/scale matrix |
| wave phase shifts | `shift1 = 0.001*(t*160*2, t*120*2)`, `shift2 = 0.001*(t*190*2, -t*130*2)` | two scroll directions |
| `normwater` | `normalize(vec3(h3-h4, h1-h2, 0.15))` | per-pixel wave normal from finite differences |
| `wavejitter` | `normwater.xy * texScaleT * (level-height)` | depth-scaled refraction offset |

**Alternate shader (`water.frag`, not referenced by `water.lib`):** `coast2water_fadedepth = 0.10`, `softlight = 15`, `glossylight = 120`, `particle_amount = 70`, `watercolor = (0.43, 0.60, 0.66)`, `watercolor2 = (0.06, 0.07, 0.11)`, `water_specularcolor = (1.3, 1.3, 0.9)`, `WATER_LEVEL = 1.5`, `flat_level = 0.525`, 11-octave procedural `height_map` FBM (uses `noise1`, no `hmapTex`). Legacy `.bak` pair: two-sine vertex displacement with `waveFreq/waveAmp/waveDir0/1`, `NWAVES 2`, fresnel `mix` of shallow/deep colour and reflection. These are real files but not the active pipeline per `water.lib`.

**Light source (`env\lights\light.cfg`, observed):** `LightStyle = lsParallel`, `Position = (-0.344731152057648, 0.938701450824738, 0, 1)`, `Diffuse = (0.812, 0.780, 0.694)`, `Specular = (0.278, 0.267, 0.212)`, `Ambient = (0.196, 0.184, 0.129)`. The shaders derive light direction from `gl_LightSource[0].position` scaled (`water.dev.vert`: `lightVector = vec3(lightPos.x/4.0, lightPos.z/2.0, lightPos.y/1.0)`), i.e. water glints follow the same sun as the rest of the scene. `env.cfg`/`time.cfg` contain no water-specific keys. **No water/current parameter exists in any env config** (`UNVERIFIED` for "current arrows" — see §6).

**Reflection source:** `water.dev.frag` samples `uniform sampler2D reflectionMap` via `texture2DProj` (screen/projected reflection). `materials\ref\refcubemap.mat` defines a cube map `cubemap_c00..c05.bmp` with `mappingmode = tmmCubeMapReflection`; **UNVERIFIED** whether that cube map is bound to `reflectionMap` or whether a live screen reflection is used.

### 3d. Shore thresholds in generator scripts (`observed`)

| Param | Value | Source |
|---|---|---|
| `cWaterHeight` (texture pass) | `-0.25` | `scripts\common.inc\texturemap.inc:30` |
| `cWaterShoreHeight` | `-0.1` | `texturemap.inc:31` (also `dogenerate.inc:1576`) |
| `cWaterHeight` (map generation) | `-1.1` | `generatemap.inc:7` |
| `cBWater` / `cBColorWater` | 1 / 255 | `texturemap.inc:14,27`; `generatemap.inc:19,32` |
| `cIsWaterMin` / `cIsWaterMax` | 0.1 / 0.95 | `postprocess.inc:81-82` |
| Shore tile treatment | `bWaterShore` selects `rock9`; `bWater` selects `sand1`/`sand2` — **but this block is commented out** | `texturemap.inc:934-954` |
| `IsBorderBlackWater*` | border detection between water/non-water mask cells for noise smoothing | `postprocess.inc:95-114,330-343` |

`derived`: the shore band is the height interval `[-0.25, -0.1)` (0.15 m) in the texture pass; the shader-side `coast2water_fadedepth = 0.57` is a separate, larger visual fade distance. No standalone foam/foam-band texture exists in `water\textures\` (`observed` from the directory listing); foam is **procedural** in-shader (`nautic()` + `particles()`).

---

## 4. Donor water rendering model

### Observed (verbatim behaviour from `water.dev.frag` + `water.dev.vert`)

1. **Geometry/UV setup (`water.dev.vert`):** `gl_TexCoord[0] = gl_TextureMatrix[0]*pos` (projected reflection coords); `gl_TexCoord[1].xy = pos.xz/hmapW-0.5`, `.z = pos.y` (heightmap lookup + world height); `gl_TexCoord[3] = shadow matrix`. `lightVector` and eyeVector are forwarded. `fogFragCoord` computed for ATI vs other vendors.
2. **Where water exists (`water.dev.frag:main`):** `fragColor = texture2D(hmapTex, gl_TexCoord[3].xy); float h = hmapMin + fragColor.w*(hmapMax-hmapMin); if (gl_TexCoord[3].z > h) { mainImage(...) }`. Water is only shaded where the surface height exceeds the sampled terrain height.
3. **Wave field (`water_map`):** fBm from `noise()` (a `waveMap` texture lookup, `p*1/256`) with 3 coarse octaves (`0.6, 0.25, 0.1666`) forming a `sin(p2.x*0.622 + p2.y*0.622 + shift2.x*4.269) * large_waveheight * f * height²` swell, then 9 octaves `p = m*p*0.947; f -= amp*abs(sin((noise(p+shift1*s)-0.5)*2.)); amp *= 0.59; s *= -1.329`. Two time-shifted scroll directions (`shift1`, `shift2`).
4. **Surface normal:** finite differences of `water_map` at `dif = (0,0.01)` and swapped `.yx`, giving `normwater = normalize(vec3(h3-h4, h1-h2, 0.15))`. Refraction offset: `wavejitter = normwater.xy * texScaleT * (level-height)`; UV is displaced by jitter scaled by depth.
5. **Depth/coastline:** `level = WATER_LEVEL + 0.2*water_map(...)`; `coastfade = clamp((level-height)/0.57, 0, 1)`; `deepwater_fadedepth = 0.5+0.57 = 1.07`; `coastfade2 = clamp((level-height)/1.07, 0, 1)`. Colour: `watercolor = mix(watercolor*intensity, watercolor2, smoothstep(0,1,coastfade2))` where `intensity = dot(rescolor, (0.2126,0.7152,0.0722))` (Rec.709 luminance of the refracted terrain colour).
6. **Reflection:** `refuv = gl_TexCoord[0].xyw; refuv.xy -= wavejitter*refuv.z; refcol = texture2DProj(reflectionMap, refuv); refcol.rgb *= (r+g+b)*hdrMultiplier; watercolor += refcol.rgb`. Fresnel terms exist but are commented out in the active shader.
7. **Specular/glints:** `grad = dot(normwater, rd)` with `rd = normalize(light-r0)`; `specular = pow(grad, 170)` (soft), `specular2 = pow(grad, 120)` (glossy), `specular1 = smoothstep(0,1,pow(gradpos,5))` corona; `watercolor *= 2.2+watershade`, then `+= (.2+.8*watershade)*((grad-1)*.5+specular)*.25`, `/= (1.+specular1*1.25)`, `+= watershade*specular2*water_specularcolor`. Shadow via 3-tap `shadow2DProj`.
8. **Foam:** `watercolor += watershade*coastfade*(1.-coastfade2)*(vec3(.5,.6,.7)*nautic(uv) + vec3(1,1,1)*particles(uv))`, where `nautic = pow(1-f, 5)` over 3 noise octaves scaled ×18 and `particles = pow(f*0.35, 7)*30` over 3 octaves scaled ×200. Foam exists **only in the coast band**, driven by time (`iglobaltime*s` inside the noise).
9. **Composite/alpha/fog:** `rescolor = mix(rescolor, watercolor, coastfade)`, `resalpha = coastfade2`; final `fogmap()` applies linear/exp/exp2 fog.

### Inferred

- The donor's "beauty" comes from (a) **per-frame GPU animation** — `time` is a shader uniform, so every frame has new phase shifts and new glints with no CPU work; (b) **depth-driven colour** — shallow→deep tint and alpha from `level-height`; (c) **screen-projected reflection distorted by wave normals**; (d) **specular glints keyed to the same directional sun as terrain**; (e) **procedural foam confined to the coast fade**. These five together explain why the donor reads as "animated waves with glints and shoreline" while the port reads as "flat blue + sparkle".
- `heightmapwaves0.tga` is probably the source of `hmapTex` and hence of depth/coastline, but this binding is not explicit in the plaintext files inspected (`UNVERIFIED`).
- "Current arrows" are **not present** in any donor water source inspected (no shader, config, or generator symbol for a directional current overlay); do not treat as a donor feature to replicate.

---

## 5. Port water today — file:line evidence + gap table

### How the port renders water (`app\scripts\world.gd`)

- `world.gd:50-52` — state: `ter_water`, `ter_blue`, `ter_blueA` images.
- `world.gd:672-693` (`_prep_variants`) — loads **only** `res://assets/terrain/water_png/diffusewaves2.png` (`:675`), converts to `FORMAT_RGB8` (`:677-678`), mirror-tiles to 1024 px into `ter_water` (`:679`). Builds `variants[3]` = four 256×256 crops at offsets `i*256` (`:689-691`) with comment "P-21 / RE gap 6 … four phase-shifted wave variants … re-baked water chunk catches a different frame". **Observed:** the operative water draw reads `ter_water` directly (`:865`), not `variants[3]`; whether `variants[3]` is consumed anywhere else is `UNVERIFIED` (grep found no later read of `variants` for water).
- `world.gd:739-750` (`_build_masks`) — `ter_blue = Color(0.16, 0.36, 0.44)` RGB (`:740`); `ter_blueA` RGBA with a 4×4 Bayer dither at 60% density (`:744-749`) — a fixed blue glaze, the only "water colour".
- `world.gd:798-875` (`_build_chunk`) — for terrain role `t == 3` (water, from `role_block` map at `:841`): `var phase = int(anim_t * 12.0) % 1024` (`:864`); `overlay = _wrap_crop(ter_water, cx*S + 300 + phase, cy*S + 700, S)` (`:865`); blue glaze `blend_rect_mask(blue_big, blueA_big, ...)` (`:866-870`); then `img.blend_rect_mask(overlay, mask, full, origin)` (`:875`) where `mask` is a one-tile bilinear feather of the binary type-3 grid (`:843-858`). Water is thus a **static baked image per chunk**, blended between tile types, no depth.
- `world.gd:906-918` — chunk finished with optional supersample resize, `ImageTexture.create_from_image`, assigned to a `Sprite2D`, z-index −10.
- `world.gd:920-945` (`_sync_terrain_chunks`) — chunks are **cached** in `terrain_chunks`; only missing chunks build, max 2 per frame (`:934-939`), LRU 24 (`:940-945`).
- `world.gd:947-952` (`sync`) — `anim_t += dt` **every frame** (`:952`), but the wave `phase` is sampled only when a chunk is (re-)built.

**Derived consequence:** for a stationary camera the water image is frozen; the "time-based shimmer" only changes when a chunk enters/leaves view or on a rebuild. There is no per-frame pixel update, no shader, no reflection, no specular, no foam, no depth colour. Judgement P-21's own caveat ("updates on chunk re-bake not per frame") matches the code exactly.

### Gap table

| Feature | Donor evidence | Port evidence | Status |
|---|---|---|---|
| Per-frame wave scroll | `water.dev.vert` `time*0.02`; `water.dev.frag` `shift1/shift2`, 9-octave `water_map` | `world.gd:864-865` phase sampled at bake only; `:934-939` chunk cache | **MISSING (partial)** |
| Depth-based colour | `coastfade/coastfade2`, `watercolor2`, `resalpha` | `world.gd:740` single flat `Color(0.16,0.36,0.44)` | **MISSING** |
| Shoreline foam | `nautic()` + `particles()` in coast band | none | **MISSING** |
| Reflection | `reflectionMap`, `texture2DProj`, `refcol` | none | **MISSING** |
| Specular glints | `pow(grad,170/120)`, `water_specularcolor`, sun-linked `lightVector` | none (the port "sparkle" is the wave PNG's own bright pixels) | **MISSING** |
| Wave normals / refraction | `normwater`, `wavejitter` from finite differences | none | **MISSING** |
| Vertex wave displacement | `.bak` vertex (legacy; disabled via `WaveFreq=0`) | none | Not applicable (disabled in donor too) |
| Current arrows | no donor feature found | none | **UNVERIFIED / N/A** |
| Tileable wave art | 8 BMPs; active `DiffuseWaves0`+`DiffuseWaves2` | 8 PNGs converted; only `diffusewaves2.png` used (`world.gd:675`) | **Present, underused** |
| Height/normal asset | `heightmapwaves0.tga` (256² RGBA, `tfNormalMap`) | not converted, not used | **MISSING** |
| Shadow on water | `shadow2DProj` 3-tap, `ShadowMapEnable=True` | none | **MISSING** |
| Fog on water | `fogmap()` linear/exp/exp2 | port fog exists separately (`world.gd:24,953-956`) but not water-tied | Partial |

---

## 6. Claim table

| Claim | Evidence | Method | Verdict | Correction |
|---|---|---|---|---|
| P-21: "4 phase-shifted wave variants" | `world.gd:689-691` creates `variants[3]` with 4 crops at `i*256` | Read | **Accurate as code**, but the operative water draw uses `ter_water` directly (`:865`), so the 4 variants do not visibly contribute per-frame | Clarify: four crops exist but are apparently vestigial; the visible wave motion comes from a single scrolled crop at re-bake. Verify with a runtime read of `variants` (not done here). |
| P-21: "time-based shimmer" | `world.gd:864` `phase = int(anim_t*12.0)%1024`; `:952` `anim_t += dt` | Read + derived | **Partial / accurate with caveat** | Shimmer is 12 px/s sampled at bake time, not a true per-frame animation. |
| P-21: "updates on chunk re-bake not per frame" | `world.gd:934-939` builds only missing chunks, max 2/frame; `:940-945` LRU 24 | Read | **Confirmed** | No change needed. |
| "Port water is flat blue + sparkle" | `world.gd:740` flat blue glaze; `:865` single wave crop; no shader | Read | **Confirmed** | The "sparkle" is static bright pixels in `diffusewaves2.png`, not specular highlights. |
| "Donor water is animated with waves, glints, shoreline" | `water.dev.frag` `shift1/shift2`, `specular`, `nautic()`/`particles()`, `coastfade` | Read | **Confirmed** | Animation is GPU-per-frame via `time` uniform. |
| "Donor uses the heightmap as a normal map for waves" | `water.mat` `HeightMapWaves0` has `TextureFormat = tfNormalMap` but is commented out; `water.lib` active `NormalMapLibMaterialName = DiffuseWaves2` | Read | **Corrected** | In the shipped config the "normal map" slot actually holds `diffusewaves2.bmp` (luminance). `heightmapwaves0.tga` is disabled. |
| "Donor has current arrows" | No `current` param in `water.lib`/`water.mat`/shaders/env; no such texture | Search | **UNVERIFIED / no evidence** | Drop from requirements; do not fabricate a donor feature. |
| "Port already has all donor water art converted" | 8 PNGs match donor BMP dimensions/formats (Pillow); heightmap absent | Pillow + read | **Partial** | All 8 diffuse PNGs converted; `heightmapwaves0.tga` is not. |
| Reflection cube map is the water reflection source | `refcubemap.mat` defines `cubemap_c00..05.bmp`, `tmmCubeMapReflection`; `water.dev.frag` uses projected `reflectionMap` | Read | **UNVERIFIED** | Plaintext does not bind the cube map to the water shader; projected reflection is the observed shader path. |

---

## 7. Recommendations — concrete build tickets

All target file `app\scripts\world.gd` unless noted; new shader files belong in `app\shaders\`. Every ticket must respect **N-07: no frame > 250 ms**. The unifying recommendation is to move water from **CPU chunk-baked pixels** to a **single GPU `canvas_item` overlay shader** so `time` advances per frame with near-zero CPU cost, leaving `_build_chunk` (a GDScript per-pixel mask baker) untouched for non-water terrain.

### W-1 — Animated water overlay shader (highest value)
- **Change:** add `app\shaders\water_overlay.gdshader` (`shader_type canvas_item`) sampling `res://assets/terrain/water_png/diffusewaves2.png` (and optionally `diffusewaves0.png`) with two scroll UVs, `uniform float time` advanced in `world.gd:sync` (`:952`). Add a transparent `Sprite2D`/`ColorRect` overlay node masked by a precomputed water alpha image derived from `game.terrain` type 3 (reuse the grid built at `world.gd:843-858`, baked once). Keep the baked chunk as the substrate; overlay alpha = water mask.
- **Port of donor math:** 2–3 octave fBm noise scrolled by `shift1/shift2` (`water.dev.frag`), recompute `normwater` from finite differences of the height field, tint by depth using `game.height_at()` (already available at `world.gd:898`).
- **Compatibility renderer note:** `canvas_item` shaders with `uniform sampler2D` and `hint_screen_texture` (for W-4) are supported in Godot 4 Compatibility; avoid compute, SDFGI, and 3D-only screen-space effects. One full-viewport quad + 2–4 texture fetches is cheap.
- **Acceptance criteria:** (a) with water covering ≥ 25% of a 1920×1080 viewport at 60 fps, mean frame time increases < 2 ms and **no frame exceeds 250 ms** over a 10 s capture; (b) visible wave phase advances ≥ 1 px per rendered frame at `view_scale=1` (compare two screenshots 100 ms apart); (c) camera stationary for 5 s still shows moving water; (d) zero new resource loads per frame (`anim_tex` pattern at `world.gd:361-368` shows the intended cache).

### W-2 — Depth-driven shallow/deep colour + alpha
- **Change:** in the overlay shader compute `depth = water_level - game.height_at(...)` baked into the water mask's second channel; reproduce `watercolor = mix(shallow(0.1,0.24,0.24), deep(0,0.025,0.05), smoothstep(0,1,depth/1.07))` and `alpha = clamp(depth/1.07,0,1)` with donor constants from `water.dev.frag`. No donor conversion needed — `game.height_at()` is already used (`world.gd:898`).
- **Acceptance:** a known shallow cell (height within 0.15 m of level) renders measurably brighter/bluer than a deep cell (> 1 m below level); sampled pixel RGB difference ≥ 20/255 in at least one channel.

### W-3 — Sun-linked specular glints
- **Change:** port `specular = pow(grad,170)`, `specular2 = pow(grad,120)`, `specular1 = smoothstep(0,1,pow(gradpos,5))`, `water_specularcolor = (0.4,0.4,0.4)`; feed light direction from `env\lights\light.cfg` `Position = (-0.3447,0.9387,0)` (or the port's existing sun direction if one exists — verify). Glints must move as wave normals animate, not be baked into the PNG.
- **Acceptance:** two frames 0.5 s apart on the same deep-water pixel differ in luminance by ≥ 0.1 (glints travel); glint density increases when the light direction is rotated toward the camera.

### W-4 — Procedural shoreline foam band
- **Change:** port `nautic()` (`pow(1-f,5)`, 3 octaves ×18) and `particles()` (`pow(f*0.35,7)*30`, 3 octaves ×200); multiply by `coastfade*(1-coastfade2)` with `coast2water_fadedepth = 0.57`. Use the same wave texture as noise source; no foam image conversion needed (donor has none).
- **Acceptance:** a 0.57 m-wide band adjacent to land shows visible white foam pixels that animate; zero foam pixels at depth > 1.07 m; band width scales with `TexScaleT`/zoom as expected.

### W-5 — Optional reflection / current
- **Change (reflection):** sample a scrolled `hint_screen_texture` with `wavejitter` offset, scaled by `hdrMultiplier = 1`; only if measured GPU cost stays inside N-07. If using the donor cube map, `materials\cubemap\cubemap_c00..05.bmp` must first be converted (not present in repo) — out of scope for read-only lane.
- **Change (current):** none — no donor current feature exists (§6). Do not schedule.
- **Acceptance:** reflection visibly distorts with wave normals; frame budget still < 250 ms; if not, ship without reflection (W-1..W-4 already close the main gap).

### W-6 — Use the six unused converted PNGs
- **Change:** `diffusewaves0/1/3/4/5/6/7.png` are already in `water_png/` (Pillow-verified) and unread. Feed them as additional noise octaves/frames in the overlay shader (e.g. alternate octave source by `int(time)`) to increase motion richness at zero conversion cost.
- **Acceptance:** ≥ 3 distinct wave PNGs are bound in the shader; motion shows no 1 s repeat cycle; no new assets copied from donor.

### W-7 — Heightmap conversion (only if depth fidelity insufficient)
- **Change:** if `game.height_at()` is too coarse, convert `water\textures\heightmapwaves0.tga` (256×256 RGBA, alpha-height) to `water_png\heightmapwaves0.png` in a separate, licensed-asset-reviewed task — **not** by this agent (read-only lane). Bind to overlay's depth channel.
- **Acceptance:** conversion preserves RGBA and alpha-channel height; shader samples `.a` exactly as `water.dev.frag` samples `hmapTex.w`.

**Perf guard for all tickets:** keep `_sync_terrain_chunks` at `built >= 2` (`world.gd:935-936`) and the LRU 24 (`:940-945`). Do **not** re-bake water chunks per frame — that would multiply the GDScript mask loops at `world.gd:746-749,820-858` by 60 and risk the 250 ms gate. The overlay shader is the compatible path.

---

## 8. Open questions

1. Is `heightmapwaves0.tga` actually bound to the shader's `hmapTex`, or is `hmapTex` a per-map engine-supplied terrain height texture? No plaintext binding found (`UNVERIFIED`).
2. What is bound to `reflectionMap` — the `refcubemap.mat` cube map or a live projected/screen reflection? Not stated in the files inspected.
3. Are `variants[3]` four crops (`world.gd:689-691`) read by any code path (e.g. main.gd quality switching)? Only the assignment was found; `UNVERIFIED`.
4. Which of `water.dev.frag` vs `water.frag` ships in the retail binary? `water.lib` names `.dev`, but the non-`.dev` pair has materially different constants (e.g. fade 0.10 vs 0.57); needs runtime/binary confirmation.
5. Which donor sun-direction value does the game engine actually pass to `gl_LightSource[0]` (the `light.cfg` Position vs a time-of-day-driven value from `env.cfg`/`time.cfg`)? Only the static config was inspected.
6. Does the donor apply a separate foam/sand tile in the shore band at runtime, given `texturemap.inc:934-954` is commented out? The shader-side foam may be the only foam.
7. Are there donor water settings in a binary config (e.g. a `.pkg`/packed archive) not exposed as plaintext under `data\`? Out of scope for this read-only deep-dive.
