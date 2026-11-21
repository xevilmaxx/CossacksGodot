---
title: Donor shading pipeline vs port — R-ARCH-SHADER
owner: R-ARCH-SHADER
decision: D-22 (supporting evidence)
updated: 2026-11-21
status: complete
scope: READ-ONLY. No code edit, no Godot run, no donor copy. Donor accessed private-use at `C:\Games\Cossacks 3\` (read-only).
---

# Donor shading pipeline → 2D-vs-3D verdict and optional 3D-ortho shader plan

> [!IMPORTANT]
> This report answers one question with source-level evidence: **is the donor a
> 3D-geometry renderer or a 2D canvas compositor?** Every quotation below is copied
> verbatim from the named file with its line number. `observed` = direct read or
> filesystem count; `derived` = structural/arithmetic conclusion from observed
> facts; `inferred` = plausible reading not proven by plaintext (the actual
> sampler→texture bindings live in the donor binary `cossacks.exe` and were NOT
> reverse-engineered here). Where something cannot be proven it is marked
> `UNVERIFIED`, never `done`.

**Files owned/changed by this agent:** `docs/audit/RENDER_ARCH_SHADERS.md` only.
**Godot runs used:** none. **Donor assets copied:** none. **Prior art relied on:**
`docs/audit/WATER_REPORT.md` (water already re-derived), `docs/audit/RENDER.md`
(port CPU-composite pipeline).

---

## 1. Sources

### Donor (all read-only, `C:\Games\Cossacks 3\`)

| Source | Used for |
|---|---|
| `data\shaders\shaders.lib` (1813 lines) | Master shader registry: `ShadersSM20` (`:15`) and `ShadersSM30` (`:914`) program families, per-program capability flags |
| `data\shaders\shaders.ref` | Custom/per-unit program overrides (`custom.unob`, `custom.uim`, `custom.u`) |
| `data\shaders\obj\*.vert/.frag` (75 files) | Object/terrain/unit shading stages |
| `data\shaders\tone\*.vert/.frag` (26 files) | Post-processing / HDR / SSAO / DOF / FXAA stages |
| `data\shaders\water\*` (6 files) | Water (`water.dev.vert/.frag` is the shipped pair — `WATER_REPORT.md` §2.1) |
| `data\materials\**\*.mat/.lib` (16 files) | Material→shader-family and texture-slot bindings |
| `data\posteffects\posteffects.shaders`, `posteffects.lib`, `posteffects.mat` | Post chain assembly and tuned parameter values |
| `data\pfx\*` (26 files: `source.pfx`, `material.mat`, `fx.tree`, `textures\*`) | Particle emitter/shader source records |

### Port (working tree)

| Source | Used for |
|---|---|
| `app/shaders/water_overlay.gdshader` (173 lines) | The **only** `.gdshader` in the repo; `shader_type canvas_item` (`:1`) |
| `app/shaders/water_overlay.gdshader.uid` | Godot UID sidecar |
| `app/scripts/world.gd` | `Image`/`ImageTexture` chunk compositing, `Sprite2D` layers, overlay binding |
| `app/scripts/world3d.gd`, `app/scripts/terrain3d_sandbox.gd`, `app/scenes/terrain3d_sandbox.tscn` | **Concurrent M0 3D A/B sandbox** discovered during this audit (see E31/C13); experimental, not the shipping path |
| `docs/audit/RENDER.md` | Independently verified port render-graph (CPU bakes, `fx_layer`, fog `ImageTexture`) |
| `docs/audit/WATER_REPORT.md` | Prior donor-water re-derivation and port gap table |

> [!NOTE]
> A first repo-wide token search (ripgrep, which honours `.gitignore`) saw only the
> 2D path. A later filesystem sweep (`Get-ChildItem -Recurse`) found the three
> **new, untracked** 3D-sandbox files above (mtime 2026-11-21 19:13–19:14). This
> report was corrected to account for them. They post-date the task's stated
> premise ("only `water_overlay.gdshader` exists") and are a separate lane's WIP.

---

## 2. Shader / material inventory

### 2.1 `data\shaders\` — 109 files total (`observed`: recursive count)

| Directory | `.vert` | `.frag` | `.bak` | `.lib` | `.ref` | Total | Families |
|---|---:|---:|---:|---:|---:|---:|---|
| `obj\` | 41 | 34 | 0 | 0 | 0 | **75** | HeightField/Default/None/Grass/Decal/DecalCubeMap/Custom + unit/ skin / FX variants |
| `tone\` | 4 | 22 | 0 | 0 | 0 | **26** | filter, gauss, tone, tone+cont+gamma, tone+dof+..., +ssao, +fxaa, +ssao+fxaa |
| `water\` | 2 | 2 | 2 | 0 | 0 | **6** | `water.dev.*` (shipped), `water.*` (debug), `*.bak` (legacy vertex-wave) |
| root | 0 | 0 | 0 | 1 | 1 | **2** | `shaders.lib`, `shaders.ref` |
| **TOTAL** | **47** | **58** | **2** | **1** | **1** | **109** | — |

`obj\` filename families (count of files, `observed`): `b*` 15 (flat-white shadow-caster
vertices + UI), `unit*` 13, `dec*` 6, `tbn*` 6, `fx*` 6, `pvl*` 5, `def*` 4,
`tree*` 4, `hf*` 3, `rim*` 3, `env*` 3, `ppl*` 3, `test*` 2, `gr*` 2.
Free-text prefixes encode the technique: `pvl` = per-vertex lighting,
`ppl`/`ppl` = per-pixel lighting, `tbn` = tangent-space normal mapping,
`env` = cube-map environment reflection, `rim` = rim lighting, `hf` = height field,
`gr` = grass, `sm` = shadow-map variant, `smx3`/`smx9` = SM3.0/SM2.0 fragment
profiles (`shaders.lib:15,914`), `b*` = bone/skin (`NBONES 16`, `b16.id9.vert:1-3`).

### 2.2 `data\materials\` — 866 files (`observed`)

844 `.dds` (albedo/normal/height atlases: buildings, env, units, pfx), **15 `.mat`**
(`buildings\buildings.mat`, `env\env.mat`, `misc\misc.mat`, `pfx\pfx.mat`,
`units\units.mat`, and 10 `ref\*.mat` templates), **1 `.lib`**
(`materials.lib`, 695 B), 6 `.bmp` (cubemap faces). All 15 `.mat`/`.lib` files were
enumerated; none contain GLSL — they are texture/material records that reference
shader *families*, e.g. `units.mat:1-4`:

```
section.begin {refurl=.\data\materials\ref\refunit.mat}
   Material.Name = pikeman
   Material.Texture.image = .\data\materials\units\pikeman.dds
section.end
```

### 2.3 `data\posteffects\` — 3 files (`observed`)

`posteffects.shaders` (53 lines) maps 22 named stage pairs onto `tone\*` files;
`posteffects.lib` (73 lines) holds the tuned default/winter/desaturate presets;
`posteffects.mat` is **0 bytes** (`observed`: line count 0) — an empty/vestigial
material host.

### 2.4 `data\pfx\` — 26 files (`observed`)

6 root records (`source.pfx`, `source.ref`, `material.mat`, `material.ref`,
`manager.lib`, `fx.tree`) + 20 `textures\*` sprites (`*.dds`/`*.bmp`: fire, smoke,
musket flash, explosions, water blast). `source.pfx` binds emitters to *shader*
sprite managers, e.g. `:30-45`:

```
LibManagerName = aspriteshader31
LibSourceName  = musketsmoke
FrameWidth = 256
FrameHeight = 128
LibMaterialName = musketsmoke
```

— a particle-system record, not a 2D canvas blit list (`observed` text; runtime
behaviour `inferred`).

---

## 3. Evidence table — claim | file:line | status

| # | Claim (with exact quote) | Source:line | Status |
|---|---|---|---|
| E1 | Capability flags are part of every shader program record: `shadowColor`, `eyePos`, `cameraMVM`, `fogMode`, `shadowed`, `vertexColor`, `texShadow`, `texGen`, `shadowSize`, `postProc` | `shaders.lib:4-13` (Register struct) | observed |
| E2 | Two fixed-function-era profiles exist: `ShadersSM20 : struct.begin` and `ShadersSM30 : struct.begin` | `shaders.lib:15`, `:914` | observed |
| E3 | Seven program families per profile with per-program flags: `HeightField`, `Default`, `None`, `Grass`, `Decal`, `DecalCubeMap`, `Custom` — each repeats `cameraMVM = true`, `fogMode = true`, `shadowed = true`, `texShadow = true` | `shaders.lib:17-...`, same 7 at `:914-...`; family names counted at 6-space indent | observed |
| E4 | Heightfield vertex works in **view space** with a normal and a light vector: `vec4 realpos=gl_ModelViewMatrix*gl_Vertex;` / `vec3 l=normalize(gl_LightSource[0].position.xyz-realpos.xyz);` / `vec3 n=normalize(gl_NormalMatrix*gl_Normal);` | `hf.pvl.sm.vert:9,13,15` | observed |
| E5 | Terrain uses **eye-plane projected texture generation**: `gl_TexCoord[0].s=dot(realpos, gl_EyePlaneS[0]); gl_TexCoord[0].t=dot(realpos, gl_EyePlaneT[0]);` (enabled by `texGen=true` in `shaders.lib:29`) | `hf.pvl.sm.vert:30-32` | observed |
| E6 | Terrain computes **Blinn–Phong per vertex** and forwards it: `vec4 diffuse=max(dot(l, n), 0.0)*gl_FrontLightProduct[0].diffuse;` / `vec4 specular=pow(max(dot(h, n), 0.0), gl_FrontMaterial.shininess)*gl_FrontLightProduct[0].specular;` / `gl_TexCoord[4]=ambient+diffuse; gl_TexCoord[5]=specular;` | `hf.pvl.sm.vert:19,23,38-39` | observed |
| E7 | **Projected shadow coordinates** in view space: `gl_TexCoord[3]=gl_TextureMatrix[3]*cameraMVM*realpos;` | `hf.pvl.sm.vert:36`; same in `def.pvl.sm.vert:32`, `tbn.sm.id4.vert:23`, `tree.pvl.id6.vert:44`, `pvl.sm.id0.vert` | observed |
| E8 | **Hardware shadow map + 3-tap PCF** in fragment: `uniform sampler2DShadow texShadow;` / `sh+=shadow2DProj(texShadow, gl_TexCoord[3]).r<0.999?0.0:1.0;` (×3 with `of=1.0/512.0`), then `color.xyz*=(sh+shadowColor.xyz*(1.0-sh)).xyz;` | `hf.pvl.smx3.frag:3,26-30` | observed |
| E9 | Object shader multiplies vertex colour by a tuned gain: `#define VCOLOR_FACTOR 2.5` / `diffuse*=gl_Color*VCOLOR_FACTOR;` | `def.pvl.sm.vert:1,25` | observed |
| E10 | Tree shader additionally modifies vertex colour by post-process luminance: `#define VLUMIN_FACTOR 0.5` / `float lumcont=1.0+(1.0-postProc[4])*VLUMIN_FACTOR;` | `tree.pvl.id6.vert:2,35` | observed |
| E11 | **Tangent-space normal mapping** builds a TBN basis from vertex attributes: `vec3 t=normalize(gl_NormalMatrix*gl_MultiTexCoord1.xyz);` / `mat3 tbn=mat3(t, b, n);` / `vec3 l=normalize(gl_LightSource[0].position.xyz-realpos.xyz)*tbn;` | `tbn.sm.id4.vert:10-13,17` | observed |
| E12 | Bump fragment reconstructs the normal from a texture and specular mask: `vec3 n=normalize(tex1.xyz*bumpSmoothness-bumpHeight*bumpSmoothness);` / `specular=pow(max(dot(h,n),0.0), gl_FrontMaterial.shininess)*...*tex1.a*specularPower;` | `tbn.smx3.id4.frag:21,24` | observed |
| E13 | **Cube-map environment reflection**: `uniform samplerCube texUnit1;` / `vec4 tex1=textureCube(texUnit1, gl_TexCoord[1].xyz);` / `specular=...*tex1*tex0.a*specularPower;` | `env.smx9.id3.frag:2,14,22` | observed |
| E14 | **9-tap shadow PCF** on the highest-quality object shader: eight offsets around `gl_TexCoord[3]`, `sh=sh/9.0;` | `env.smx9.id3.frag:34-43` | observed |
| E15 | **Rim lighting** uses a view vector: `vec3 e=gl_TexCoord[7].xyz;` / `float edgescale=max(edgeMinScale, edgeMulScale*bias(1.0-max(dot(e, n), 0.0), edgeWidth));` with `edgeWidth=0.1`, `edgeMulScale=4.0` | `rim.smx3.id2.frag:8-13,26,31` | observed |
| E16 | **Per-pixel lighting** family recomputes l/h/n in the fragment and applies vertex colour there: `vec3 l=gl_TexCoord[4].xyz; vec3 h=gl_TexCoord[5].xyz; vec3 n=gl_TexCoord[6].xyz;` / `diffuse=max(dot(l, n), 0.0)*...` | `ppl.smx3.id1.frag:12-17` | observed |
| E17 | **Skeletal skinning in the vertex stage**: `#define NBONES 16` / `uniform mat4 boneMatrices[NBONES];` / `vec4 pos=gl_MultiTexCoord1.x*(boneMatrices[int(gl_MultiTexCoord2.x)]*gl_Vertex);`; `shaders.ref` sets `boneMatricesCount = 16` for those programs | `b16.id9.vert:1-3,7`; `shaders.ref:31-40` | observed |
| E18 | Flat-white caster fragment for shadow pass: `gl_FragColor=vec4(1.0, 1.0, 1.0, 1.0);` used by bone vertices (`uim` → `b16.id9.vert` + `b.frag`) | `b.frag:3`; `shaders.ref:33-35` | observed (+ `inferred` pass role) |
| E19 | **View-space fog with three modes** on every lit object: `LINEAR` uses `clamp((gl_Fog.end-gl_TexCoord[0].w)*gl_Fog.scale,...)`; `EXP` uses `exp2(-gl_Fog.density*gl_TexCoord[0].w*1.442695)`; `EXP2` uses `exp2(-pow(gl_Fog.density*gl_TexCoord[0].w, 2.0)*1.442695)`; `color.xyz=mix(gl_Fog.color.xyz, color.xyz, fog).xyz` | `pvl.smx3.id0.frag:29-43`; same block in `hf`, `tbn`, `rim`, `dec`, `env`, `gr`, `ppl` fragments | observed |
| E20 | Fog depth is **view-space distance** computed per vertex: `gl_TexCoord[0].w=abs(realpos.z)` (ATI) else `length(realpos)` | `def.pvl.sm.vert:38-42` | observed |
| E21 | Water vertex is a 3D transform with eye/light vectors: `gl_TexCoord[3]=gl_TextureMatrix[3]*cameraModel*gl_ModelViewMatrix*pos;` / `eyeVector=pos.xyz-eyePosition.xyz;` / `lightVector=vec3(gl_LightSource[0].position.x/4.0, gl_LightSource[0].position.z/2.0, gl_LightSource[0].position.y/1.0);` | `water.dev.vert:20-22` | observed |
| E22 | Water fragment samples a **projected reflection target**: `vec3 refuv=gl_TexCoord[0].xyw; refuv.xy-=wavejitter*refuv.z; vec4 refcol=texture2DProj(reflectionMap, refuv);` | `water.dev.frag:207-209` | observed |
| E23 | Water uses a **height field** from a texture and finite-difference normals: `float h=hmapMin+v.w*(hmapMax-hmapMin);` / `vec3 norm=normalize(vec3(h3-h4, h1-h2, 1.));` | `water.dev.frag:70-75,148-152` | observed |
| E24 | Post chain includes **HDR bloom + tone mapping**: `float yd=hdrIntencity*(hdrIntencity/brightMax+1.0)/(hdrIntencity+1.0); color0*=yd+color2*mulColor;` plus 8-tap gaussian `vec3 color=vec3(tex0+...+tex7)/8.0;` | `tone.frag:22-23`; `gauss.frag:5-13` | observed |
| E25 | Post chain includes **contrast/vignette/gamma LUT**: `const vec3 lumcoeff=vec3(0.2125, 0.7154, 0.0721);` / `r=vignetteAdjust-smoothstep(inner, outer, r);` / `float red=texture2D(colorCurveSampler, vec2(color0.x, 0.0)).x;` | `tonecontgamma.frag:55,43,88-90` | observed |
| E26 | Post chain includes **depth-buffer SSAO**: `uniform sampler2D texUnit3; // depth texture` / `float depth=ssaoDepth(gl_TexCoord[3].st);` / nested `RINGS=3`×`SAMPLES=3` loop | `tonedofcontgammassaofxaa.frag:15,112,2-3,118-129` | observed |
| E27 | Post chain includes **depth-aware DOF + FXAA**: `float depth=getDepth(gl_TexCoord[3].xy); if (depth>=focalLength) {...}` / `float d_diff=d_m-d_av; if (d_diff<FXAA_EDGE_SENS) return texture2D(buf, coord);` | `tonedofcontgammassaofxaa.frag:215-220,155-160` | observed |
| E28 | Post chain names/parameters are assembled in one config: `ToneDOFContGammaSSAOFXAAFP = .\data\shaders\tone\tonedofcontgammassaofxaa.frag` and `SSAOEnable = False`, `FocalLength = 128`, `TMHDRIntencity = 1.5` | `posteffects.shaders:51-52`; `posteffects.lib:33,30,21` | observed |
| E29 | Cross-shader token census (all 105 `.vert/.frag`): `gl_Vertex` 43 files, `gl_NormalMatrix` 31, `gl_LightSource` 33, `gl_TextureMatrix` 30, `shadow2DProj` 28 files (156 calls), `sampler2DShadow` 28, `boneMatrices` 20, `textureCube` 6, `ftransform` 26 | filesystem scan of `data\shaders\**\*.vert/.frag` | observed |
| E30 | The port has exactly one shader, a **2D canvas** shader: `shader_type canvas_item;` / `render_mode blend_mix;` / `uniform sampler2D wave0...` / `void fragment()` writing `COLOR` | `app/shaders/water_overlay.gdshader:1-2,19,93,172` | observed |
| E31 | The **shipping** port has no 3D path (2D-only `world.gd`, one `canvas_item` shader), but an **experimental M0 3D sandbox now exists**: `extends Node3D`, `Camera3D` (perspective, donor focal length 400 / tilt −32° / 40 m dolly), `MeshInstance3D` terrain with `cast_shadow = ...SHADOW_CASTING_SETTING_ON`, `DirectionalLight3D` with `shadow_enabled = true`, and an **inline** `shader_type spatial` water tint — not a `.gdshader` resource file. The only `.gdshader` FILE is still `water_overlay.gdshader` | `app/scripts/world3d.gd:1,191-195,229-250,287-296`; `app/scripts/terrain3d_sandbox.gd:1,17-25,60-74`; `app/scenes/terrain3d_sandbox.tscn:5`; `app/tests/t_smoke_fx.gd:68` (comment only) | observed (files untracked, 2026-11-21 19:13–19:14) |
| E32 | Port terrain is **CPU-composited Images**: `var terrain_chunks: Dictionary = {}` / `ImageTexture.create_from_image(...)` / `img.blend_rect_mask(...)` / `Sprite2D` layers | `world.gd:26,1102,265,850`, `RENDER.md:48-54` | observed |
| E33 | Port fog is a CPU-baked `ImageTexture` on a `Sprite2D`, not a per-fragment view-depth fog | `world.gd:18,20,264-265`; `RENDER.md:60` | observed |
| E34 | Port water shader sets `watershade = 0.0` because **no shadow sampler exists** in this path, and has no reflection term | `water_overlay.gdshader:115-119`; `WATER_REPORT.md` gap rows 7, 18 (`:315,326`) | observed |

**Derivation chain (E4+E5+E7+E8+E11+E13+E17+E19+E22+E26 ⇒ verdict):** all of these
require per-vertex 3D positions, normals, view/light vectors, a view-projection
(or texture) matrix, depth/shadow textures and a depth buffer. A 2D canvas blitter
has none of these primitives. **The donor is a 3D geometry renderer using OpenGL
fixed-function-era GLSL with a multi-pass post-processing chain.** `derived` (strong).

---

## 4. Verdict — rendering paradigm

1. **Donor = real-time 3D.** Vertex shaders consume `gl_Vertex`, `gl_Normal`,
   `gl_MultiTexCoord1/2` (tangent/bitangent), `gl_ModelViewMatrix`,
   `gl_NormalMatrix`, `gl_LightSource[0].position` and `boneMatrices[16]`
   (E4, E11, E17, E29). Lighting is Lambert + Blinn–Phong computed with 3D dot
   products against surface normals and an eye vector (E6, E16). Shadows are
   projected depth comparisons in homogeneous clip space via `sampler2DShadow`
   (E7, E8, E14). Reflections include a cube map (E13) and a projected planar
   target (E22). Fog is a function of view-space depth (E19, E20). Post-processing
   reads a **depth texture** for SSAO/DOF/FXAA (E26, E27).
2. **The 2D elements are a layer *on top of* the 3D renderer, not the renderer.**
   `data\pfx\*` sprite emitters (§2.4), HUD/cursor assets, and the flat-white
   `b.frag` shadow-caster pass are 2D/simple stages, but they are outnumbered by
   geometry-shading families and are bound through the same material/shader
   registry. `inferred` (the binary binding is not plaintext).
3. **The shipping port = 2D canvas + CPU Image compositing.** One `canvas_item`
   shader file, `Sprite2D` layers, `Image.blend_rect_mask` chunk bakes, CPU fog
   texture (E30, E32–E34, `RENDER.md`): no depth buffer, no normal attribute, no
   light vector, no projection matrix and no render-target chain. This is a
   **different rendering paradigm**, not an incomplete version of the donor's.
4. **Qualification — an M0 3D A/B sandbox was added concurrently** (E31, C13). It
   proves Godot can host donor-like terrain geometry, a shadow-casting sun and a
   Spatial water tint, so "3D is impossible in this project" is FALSE. It does
   **not** change the shipping path or the shader gap: the sandbox is terrain +
   water only, uses a **perspective** camera (not the ortho mode in §6), uses
   `StandardMaterial3D` rather than the donor shading families, and its water
   explicitly omits refraction, screen texture, reflection and shadow sampling
   (`world3d.gd:233-249`). The gap analysis in §5 therefore applies to the
   **shipping 2D path**, which is what the port actually renders.

---

## 5. Port gap — donor effects structurally impossible on the current 2D path

"Categorically impossible" means the **shipping 2D path's** data model cannot
represent the input the effect needs (no mesh, no depth, no second render target),
not that Godot could never do it with a different path. The concurrent M0 3D
sandbox (E31) already supplies a separate geometry/depth path for terrain and
water; it is a proof of feasibility for §6, not a port of the donor shader
families. Each row below should be read as "impossible on `world.gd`'s 2D path",
not "impossible in this repository".

| Donor effect | Required input | Why the 2D path cannot produce it | Status |
|---|---|---|---|
| Per-pixel Blinn–Phong on geometry (E6, E16) | per-vertex normal + view/light vectors | Sprite quads have a single face normal; no `NORMAL`/`LIGHT` in `canvas_item` | impossible now |
| Shadow mapping + PCF (E7, E8, E14) | depth render target + light-space matrix | no depth buffer, no light matrix, no `sampler2DShadow` in 2D | impossible now |
| Tangent-space normal/bump mapping (E11, E12) | tangent/bitangent vertex attributes | no mesh attributes; port fakes a 2D normal from a height *derivative* only in water (`water_overlay.gdshader:104-112`) | impossible now |
| Cube-map reflections (E13) | `samplerCube`, reflect vector | no 3D view vector or cube sampler in `canvas_item` | impossible now |
| Projected planar reflection (E22) | projected UVW + reflection FBO | port has no `hint_screen_texture`/SubViewport and explicitly draws "no screen texture" (`water_overlay.gdshader:10`) | impossible now |
| Rim lighting (E15) | eye·normal per pixel | no per-pixel 3D normal on sprites | impossible now |
| Vertex skinning (E17) | bone matrices + skinned mesh | port bakes frames into 2D sheets (`RENDER.md:37-44`) | impossible now (baked approximation exists) |
| Height-field texgen / eye-plane projection (E5) | `gl_EyePlaneS/T` + modelview | no 3D transform | impossible now |
| View-depth fog (E19, E20) | per-pixel view-space depth | port fog is a pre-baked `ImageTexture` (E33) | impossible now (flat approximation exists) |
| Depth-based SSAO (E26) | scene depth texture | no depth output from the 2D composite | impossible now |
| Depth-based DOF and depth-aware FXAA (E27) | scene depth texture | same | impossible now |
| HDR bloom + tone mapping + vignette + gamma LUT (E24, E25, E28) | multi-pass colour render targets | possible in principle with SubViewport + `canvas_item` shaders, but **no post chain exists** in the port — infrastructure gap, not primitive gap | absent, buildable in 2D |
| Gaussian multi-pass blur (E24) | ping-pong render targets | same — absent, buildable in 2D | absent, buildable in 2D |

**Net:** the port reproduces (a subset of) the donor's *water fragment equations*
on a flat mask, but it cannot reproduce the donor's **shading paradigm**. The
missing primitive is not a constant or a texture — it is the 3D geometry/depth
path itself.

---

## 6. Optional 3D-ortho mode in Godot 4 — prioritized shader port plan

Target: Godot 4 **Spatial** shaders on the **Compatibility** renderer, with an
orthographic `Camera3D` to preserve the donor's fixed RTS camera framing.
**Already underway:** the concurrent M0 sandbox (E31/C13) demonstrates P0 terrain
geometry, a shadow-casting `DirectionalLight3D`, and a simplified inline Spatial
water tint. It uses `StandardMaterial3D` (not a re-expression of donor lighting),
a **perspective** camera, and no donor post chain — so the list below remains the
full gap. Coordinate with that lane rather than duplicating it (open question 7).
Legacy
GLSL fixed-function builtins (`ftransform`, `gl_FrontLightProduct`,
`gl_TextureMatrix`, `gl_EyePlaneS/T`, `gl_LightSource`, `sampler2DShadow`) do not
exist in Godot's shading language and must be replaced by explicit uniforms /
builtins (`MODELVIEW_MATRIX`, `NORMAL`, `VIEW`, `LIGHT`, `VIEW_DEPTH`,
`SCREEN_UV`, `hint_screen_texture`).

### P0 — direct Spatial ports (highest fidelity / lowest risk)

1. **Lit object shader family** (`def*`, `pvl*`, `ppl*`, `dec*`, `fx*`, `hf*`,
   `gr*`, `tree*`; E4–E10, E16, E19–E20). `shader_type spatial;` with
   `render_mode cull_back` (trees `-nocull` as donor), explicit ambient/diffuse/
   specular in `fragment()`, `ALBEDO`, `SPECULAR`, `ROUGHNESS` from
   `gl_FrontMaterial.shininess → roughness = sqrt(2/(shininess+2))` (derived),
   `COLOR` varying for vertex colour with the donor **2.5** gain, tree luminance
   floor with **0.5** factor. Fog: donor LINEAR/EXP/EXP2 modes are not a 1:1
   match to Godot's environment fog — implement manually from a view-depth
   varying using the exact `1.442695` constants (E19).
2. **Shadow reception** (E7, E8, E14). Do **not** hand-port `sampler2DShadow`:
   use DirectionalLight3D shadows + Godot's built-in shadow filter. The donor's
   3-tap (grass/decal) and 9-tap (env) PCF kernels map to
   `SHADOW_FILTER_PCF3X3`/`PCF5X5`; exact 9-offset pattern needs a custom shadow
   shader (workaround, low visual priority). Compatibility supports shadow maps
   but not contact-hardening/PCSS (Vulkan-only).
3. **Terrain / height field** (`hf*`). Replace `gl_EyePlaneS/T` (E5) with a
   world-position varying and an explicit projection matrix uniform; port the
   normal-from-height finite differences (E23) directly. Do **not** import donor
   shaders as text — re-express math.

### P1 — feature ports needing a Godot asset/attribute workaround

4. **Normal / bump mapping** (`tbn*`, E11–E12). Rebuild TBN from mesh tangents
   (Godot needs `Mesh.generate_tangents()` or imported tangents); feed bump height
   into a normal map. Workaround if tangents are unavailable: derive TBN in the
   fragment from `dpdx/dpdy` of world position and UV (Compatibility-safe).
5. **Rim lighting** (`rim*`, E15). Straightforward in Spatial using `VIEW` and
   `NORMAL`; port `edgeWidth=0.1`, `edgeMulScale=4.0`, `bias()` verbatim.
6. **Skeletal animation** (`b*.id*.vert`, E17). Use Godot `Skeleton3D` +
   built-in 4-weight skinning; donor data is 1-weight/16-bone, so a conversion
   step is required (workaround outside shading). The flat caster `b.frag` (E18)
   is replaced by Godot's shadow pass.
7. **Cube-map reflections** (`env*`, E13). Convert the six `cubemap_c00..05.bmp`
   (`materials\cubemap\`, 6 `.bmp` observed) into a Godot Cubemap; sample with
   `texture(cube, reflect(-VIEW, NORMAL))` and multiply by alpha and
   `specularPower` as in `:22`.

### P2 — post chain (infrastructure, 2D-or-3D host)

8. **HDR/bloom/tone/contrast/vignette/gamma** (E24, E25, E28). Port into a
   full-screen `canvas_item` shader over a `SubViewport` colour target, using the
   tuned defaults from `posteffects.lib:20-28` (`TMHDRIntencity=1.5`,
   `TMBlurOpacity=0.0390625`, `BlurNumPasses=5`, `ContrastContrast=0.95`,
   vignette inner/outer 0.9/1.9). Godot's `Compositor` is **Vulkan/Forward-only**
   and is therefore NOT available on Compatibility — use explicit SubViewport
   ping-pong (workaround).
9. **SSAO / DOF / depth-aware FXAA** (E26, E27). Need a depth texture: render the
   3D scene into a `SubViewport` and sample `hint_depth_texture` in the post
   quad (Compatibility supports depth textures; exact availability must be
   verified on target — `UNVERIFIED`). Port `getDepth()`, `ssaoDepth()`,
   `ssaoCompareDepths()` (`:85-108`) and the `FXAA_EDGE_SENS=1/64`,
   `FXAA_SPAN_MAX=8.0`, `FXAA_REDUCE_MIN=1/128` constants (`:139-164`). If depth
   sampling is unavailable in Compatibility, worst-case workaround = baked AO
   or no SSAO; DOF/FXAA degrade to colour-only blur/edge filter.
10. **Planar water reflection** (E22). Use a mirrored `Camera3D` into a
    `SubViewport` + projected UV (or `hint_screen_texture` with `SCREEN_UV` and
    the wave jitter from `water.dev.frag:208`). Workaround required: the donor's
    exact FBO binding is in the binary (`WATER_REPORT.md` §2.3, `UNVERIFIED`),
    but the projected *behaviour* is reproducible.

### P3 — deliberately do not port

- The 9-offset PCF exact kernel, `VCOLOR_FACTOR` ATI branches, and the donor's
  `#vendor_ifdef ATI` workarounds — hardware-specific, no fidelity value in Godot.
- `water.frag` debug variant and `*.bak` legacy vertex-wave files — not shipped
  (`WATER_REPORT.md` §2.1).

---

## 7. Claim table

| # | Claim | Evidence | Method | Verdict |
|---|---|---|---|---|
| C1 | Donor shaders are overwhelmingly 3D-geometry stages, not canvas effects | E4-E17, E19-E23, E29 | direct source read + token census | **CONFIRMED** (observed) |
| C2 | Donor provides a complete per-object shading stack: ambient/diffuse/specular, vertex colour, fog, shadow map | E6, E8, E9, E19 | direct read | **CONFIRMED** (observed) |
| C3 | Donor has advanced material families: tangent-space normal, cube reflection, rim, skinning, height field | E11-E15, E17 | direct read | **CONFIRMED** (observed) |
| C4 | Donor post-processing is depth-aware (SSAO, DOF, FXAA) and HDR | E24-E28 | direct read | **CONFIRMED** (observed) |
| C5 | Donor exposes two shader model profiles and seven program families | E2, E3 | config read | **CONFIRMED** (observed) |
| C6 | 2D elements exist but are subordinate to the 3D renderer | §2.4, E18, E29 | read + count | **inferred** (binary binding UNVERIFIED) |
| C7 | The exact C++ sampler→texture / light-matrix bindings are in `cossacks.exe` | `WATER_REPORT.md` §2.2-2.3; this report §3 | no binary analysis performed | **UNVERIFIED** (binding), behaviour `derived` |
| C8 | Shipping path has one 2D shader file and no 3D scene path | E30, E31 | repo grep + listing | **CONFIRMED for shipping path** (observed); see C13 |
| C9 | Port terrain/fog are CPU Image composites | E32, E33 | source read + `RENDER.md` | **CONFIRMED** (observed) |
| C10 | Most donor visual effects are structurally impossible on the port's current 2D path | §5 | structural comparison | **CONFIRMED** (derived) |
| C11 | Optional Godot 4 Spatial/Compatibility mode can port donor shading math, but needs workarounds for depth post, cube conversion and skinning | §6 | Godot API knowledge + donor feature list | **inferred** (feasibility; Compatibility depth-texture support needs runtime verification) |
| C12 | `posteffects.mat` is vestigial | §2.3 (0 bytes) | filesystem stat | **observed** |
| C13 | An experimental M0 3D sandbox exists (Node3D/Camera3D/MeshInstance3D/shadows/inline spatial water), but it is terrain+water only, perspective, and not the shipping path | E31; `world3d.gd:191-195,229-250,287-296`; `terrain3d_sandbox.gd:60-74` | direct read + git status (untracked) | **CONFIRMED** (observed); owner lane and eventual integration `UNVERIFIED` |

---

## 8. Open questions

1. **Exact bindings (C7).** Which `sampler2DShadow`/`reflectionMap`/`hmapTex` texture
   and which light-space matrix the donor engine binds — only `cossacks.exe` knows.
   Behaviour is derived; do not claim literal FBO identity.
2. **Compatibility renderer depth textures (P2/9).** Confirm `hint_depth_texture`
   works in a `canvas_item` post quad on the target Godot 4 build/backend; if not,
   SSAO/DOF need the baked/inferred fallback. No Godot run was performed here.
3. **Light count.** Donor shaders hard-code `gl_LightSource[0]` — a single sun. Godot
   Compatibility has a limited light limit; decide whether to force one
   DirectionalLight3D to match the donor or allow extra local lights (would
   diverge from donor look).
4. **Ortho scale/tile mapping.** The donor's `cameraMVM` and texgen assume a specific
   world-tile scale; the port uses `TILE_M=2.0` (`data.gd:23`). The world→ortho
   conversion constants need a dedicated calibration pass (out of this task's scope).
5. **PFX translation.** Donor particle emitters are shader-driven sprite managers
   (`source.pfx`, `aspriteshader30/31`); the port's FX layer is `fx_layer.draw_*`
   (`RENDER.md:55-60`). Mapping sprite-manager records to Godot `GPUParticles3D`
   vs sprite sheets needs its own audit.
6. **Right-to-exist.** Coordinator decision: is an optional 3D-ortho mode in scope
   at all? This report establishes *feasibility and cost*, not a recommendation to
   switch the shipping 2D path.
7. **M0 sandbox ownership/integration (C13).** `world3d.gd`,
   `terrain3d_sandbox.gd` and `terrain3d_sandbox.tscn` are untracked WIP from
   another lane (mtime 19:13–19:14 on 2026-11-21), discovered mid-audit. Is this
   the seed of the §6 3D mode, or a throwaway A/B? Its camera is perspective, not
   ortho, and its water is a simplified tint; decide who extends it with the donor
   shading families so this report's plan is not duplicated. Its `fov_v` already
   flags the donor sensor constant as `UNVERIFIED` (`terrain3d_sandbox.gd:19-22`).

---

## Files changed

- `docs/audit/RENDER_ARCH_SHADERS.md` (new) — this report only.

No code, script, index, asset, screenshot or status document was modified. No
donor asset was copied into the repository. No Godot process was launched.
