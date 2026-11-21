# RENDER-ARCH-REFLECTION — donor reflection/decal adjudication for M0 water

```
status: FINAL (read-only; no code edits, no Godot runs, no donor copies)
date: 2026-11-21
owner_question: "donor has decals and similar folder i think its similar to what
                you intend for reflection and so on?"
scope: reflection-related reflection/decal/sky/water folders under
       C:\Games\Cossacks 3\data (private use, read-only)
```

## 0. Short answer to the owner

**No — `data/terrain/decals/*` and `data/materials/env/*` are not used as reflections.**
They are ground overlay plates and environment vegetation/terrain-decor textures respectively
(§4, with evidence). The donor has **two different reflection systems**, neither of which is
those two folders:

1. **Water reflection** — a *live projected 2D texture*: `uniform sampler2D reflectionMap`
   sampled with `texture2DProj(reflectionMap, gl_TexCoord[0].xyw)` where
   `gl_TexCoord[0] = gl_TextureMatrix[0]*pos` (`water.dev.frag:6,207-210`;
   `water.dev.vert:15`). This is projective/screen-space reflection, driven by a toggleable
   engine video option `WaterReflection` (`eventsettings.inc:155,533-537`).
2. **Object environment reflection** — a *static 6-face cubemap* `cubemap_c00..05.bmp`
   (`materials/ref/refcubemap.mat:24-33`, `mappingmode=tmmCubeMapReflection`) sampled via
   `samplerCube`/`textureCube` in the `env` and `DecalCubeMap` shader families
   (`env.smx9.id3.frag:2,14`; `dec.ref.pvl.smx3.frag:2,12`), using a `reflect()` vector
   (`dec.ref.pvl.sm.vert:23`).

There **is** a "decal" name collision: the `DecalCubeMap` shader applies a cubemap reflection
*decal-style over a base texture* on objects — but it is an **object shader** in
`data/shaders/obj/`, unrelated to `data/terrain/decals/`.

The cubemap is defined in a **reference/template** material folder (`materials/ref/`), and no
shipped `.mat` inherits the cubemap-bearing templates (grep = 0 matches). So even the object
cubemap's *runtime* activation remains partly unverified (§3.4, §7).

---

## 1. Sources

All donor reads were direct filesystem reads (PowerShell `Get-Content`, Pillow 12.1.1 for image
metadata). No donor executable was run; no file was copied into the repo.

| # | Source | Use |
|---|--------|-----|
| S1 | `C:\Games\Cossacks 3\data\materials\ref\*.mat` (10 files) | cubemap + reference template chain |
| S2 | `C:\Games\Cossacks 3\data\materials\cubemap\cubemap_c00..05.bmp` | cubemap faces, Pillow metadata |
| S3 | `C:\Games\Cossacks 3\data\water\water.lib`, `water.mat` | active water config/material |
| S4 | `C:\Games\Cossacks 3\data\shaders\water\*` (7 files) | active/alternate/legacy water GLSL |
| S5 | `C:\Games\Cossacks 3\data\shaders\shaders.lib` | `DecalCubeMap` / `env` program uniforms & bindings |
| S6 | `C:\Games\Cossacks 3\data\shaders\obj\dec.ref.pvl.sm.vert`, `dec.ref.pvl.smx3/smx9.frag`, `env.smx9.id3.frag` | cubemap reflection shader bodies |
| S7 | `C:\Games\Cossacks 3\data\env\skydome\{skydome.cfg,skydome.mat,stars.cfg,textures\menu.dds}` | sky source check |
| S8 | `C:\Games\Cossacks 3\data\materials\env\env.mat` + folder listing | prove "env" = decor, not reflection |
| S9 | `C:\Games\Cossacks 3\data\terrain\ref\{reftile.lib,reftile.mat,reftilealpha.mat}` | prove "ref" = reference tile template |
| S10 | `C:\Games\Cossacks 3\data\posteffects\{posteffects.lib,.mat,.shaders}` | check for SSR/post reflection |
| S11 | `C:\Games\Cossacks 3\data\gui\menu.inc\eventsettings.inc:155,533-537` | `WaterReflection` engine option |
| S12 | `C:\Games\Cossacks 3\data\materials\materials.lib` | registered material-library interfaces |
| S13 | Prior repo docs: `WATER_REPORT.md §2.3`, `WATER_PERF.md`, `TERRAIN_DONOR_WATER.md`, `RENDER_ARCH_SHADERS.md` (E13/E22/E31), `TERRAIN_DONOR_ASSETS.md`, `PIECES/donor_decals_and_masks.md` | prior-evidence alignment |
| S14 | Pillow 12.1.1 `Image.open()` metadata; PowerShell `Get-ChildItem` sizes | dimensions/formats/byte sizes |

---

## 2. Asset inventory (exact names, formats, dimensions, sizes)

### 2.1 Cubemap — the only real reflection texture asset

| File | Format | Dimensions | Bytes |
|------|--------|-----------|-------|
| `materials\cubemap\cubemap_c00.bmp` | BMP, RGB (uncompressed 24-bit) | 128×128 | 49,180 |
| `materials\cubemap\cubemap_c01.bmp` | BMP, RGB | 128×128 | 49,180 |
| `materials\cubemap\cubemap_c02.bmp` | BMP, RGB | 128×128 | 49,180 |
| `materials\cubemap\cubemap_c03.bmp` | BMP, RGB | 128×128 | 49,180 |
| `materials\cubemap\cubemap_c04.bmp` | BMP, RGB | 128×128 | 49,180 |
| `materials\cubemap\cubemap_c05.bmp` | BMP, RGB | 128×128 | 49,180 |

Total 295,080 B (~288 KiB raw). 128×128 is a square power-of-two face size — directly usable
as a Godot cubemap face. Face mapping is explicit in `refcubemap.mat:24-29`:
`PX=c00, NX=c01, PY=c02, NY=c03, PZ=c04, NZ=c05`.

### 2.2 Water textures (`data\water\textures\*`)

| File | Format | Dimensions | Bytes | Used? |
|------|--------|-----------|-------|-------|
| `diffusewaves0.bmp` | BMP RGB | 256×256 | 196,662 | **Yes** — `water.mat:7`, `DiffuseWaves0`, `tfLuminance` |
| `diffusewaves1.bmp` | BMP RGB | 256×256 | 196,662 | No (section commented, `water.mat:23-30`) |
| `diffusewaves2.bmp` | BMP RGB | 512×512 | 786,486 | **Yes** — `water.mat:35,37`, `DiffuseWaves2` = `NormalMapLibMaterialName` (`water.lib:43`) |
| `diffusewaves3..7.bmp` | BMP RGB | 512×512 | 786,488 each | No (commented, `water.mat:41-84`) |
| `heightmapwaves0.tga` | TGA RGBA | 256×256 | 258,506 | No (commented, `water.mat:86-105`) |

The height-map material is commented out, yet the **active** `water.dev.frag` samples
`hmapTex` (`frag:18,70-75,170`) — the height map is supplied through the engine's terrain
height-field interface, not `water.mat` (prior `WATER_REPORT.md §2.3`, `RENDER_ARCH_SHADERS.md E22`).

### 2.3 Shaders (`data\shaders\water\*`)

| File | Bytes | Role |
|------|-------|------|
| `water.dev.frag` | 8,928 | **Active** fragment (`water.lib:68`); has projected `reflectionMap` |
| `water.dev.vert` | 928 | **Active** vertex (`water.lib:67`); `gl_TextureMatrix[0]` projected UVW |
| `water.frag` | 8,284 | Alternate, not referenced by `water.lib`; declares `reflectionMap` but never samples it (`:83` comment only) |
| `water.frag.bak` | 1,844 | Legacy: Fresnel `mix`, two-sine UV jitter, `texture2DProj` (`:2,33-35`) |
| `water.vert` | 1,364 | Legacy alternate; `gl_TexCoord[0]=gl_MultiTexCoord0*texScaleS` (`:21`) |
| `water.vert.bak` | 1,699 | Legacy vertex |

### 2.4 `materials\ref\*` (reference/template materials, 10 files)

| File | Bytes | Reflection relevance |
|------|-------|----------------------|
| `refcubemap.mat` | 1,514 | **Cubemap definition** (`Name = cubemap`, 6 faces, `tmmCubeMapReflection`) |
| `refbuildingnormal.mat` | 3,077 | Binds `LibName = cubemap` (`ShaderTexEx.List[1]`, `:24-27`) |
| `refmountainnormal.mat` | 3,099 | Binds `LibName = cubemap` (`:24-27`) |
| `refbase.mat` | 2,774 | Base template inherited by `env.mat`/others (`materials.lib` interfaces) |
| `refnormal.mat` | 1,167 | Template, `image = ` empty |
| `refnormalmap.mat` | 907 | Template |
| `refmipmap.mat` | 11,140 | Template; `image = ...\misc\mipmap1024.dds` (`:30`) |
| `refunit.mat` | 2,812 | Base for `units.mat` (120+ `refurl` matches) |
| `refbuilding.mat` | 2,780 | Building template |
| `refpfx.mat` | 260 | PFX template |

**Key disambiguation:** `ref` here means **reference/template**, not `reflection`. Proof:
`materials\env\env.mat:1` and `materials\units\units.mat:1` etc. use `{refurl=.\data\materials\ref\refbase.mat}`
/ `...\refunit.mat`. `materials.lib` registers interfaces `buildings/units/pfx/env/misc` —
**no** `reflection` interface. The cubemap is a named material *inside* this template folder.

### 2.5 Sky / env / decals / postfx (checked and excluded as reflection sources)

| Folder | Content | Verdict |
|--------|---------|---------|
| `env\skydome\` | `skydome.cfg` (1,454 B), `skydome.mat` (2,789 B), `stars.cfg` (161 B), `textures\menu.dds` (DDS RGBA, **2048×512**, 524,416 B) | Sky dome: procedural colour bands (`skydome.cfg:7-46`), stars (`:1-9` of `stars.cfg`), one `menu` texture (`skydome.mat:3,30`, `tmmUser`, no cube/reflection). **Not a reflection map.** |
| `env\clouds\` | `clouds.cfg/.mat/.presets/.weather` + 12 cloud DDS (all 87,536 B) | Cloud billboards; no samplerCube/cubemap reference. |
| `materials\env\` | `env.mat` (70,044 B) + ~140 DDS: trees/bushes/rocks/field/terrainmesh/mines, incl. 5.59 MB mine/terrainmesh DDS | Environment **decor** (`env.mat:2-55`: `fir1`, `stones`, `field`… all `{refurl=refbase.mat}`). **Not sky, not reflection.** |
| `terrain\ref\` | `reftile.lib` (262 B), `reftile.mat` (4,206 B), `reftilealpha.mat` (8,765 B) | `TileBlockName = ` empty (`reftile.lib:2`) — placeholder **reference tile template**, not reflection. |
| `terrain\decals\` | 462 DDS under `buildings\` (this audit) + env field/scorch masks; prior audit: 469 DXT5 ground overlays with coverage alpha | **Ground overlays only** — see §4. |
| `posteffects\` | `posteffects.lib` (2,010 B), `posteffects.mat` (**0 B**), `posteffects.shaders` (2,762 B) | HDR/blur/tone/contrast/DOF/SSAO/FXAA/gamma (`posteffects.lib:5-60`, `.shaders:3-51`). **No SSR / reflection pass.** |

---

## 3. Binding-chain evidence (what the donor actually uses)

### 3.1 Water = projected/screen-space 2D reflection (primary finding)

`water.lib` → shaders:

```
water.lib:64-68   MaterialLibraryFileName = .\data\water\water.mat
                  VertexProgramFileName   = .\data\shaders\water\water.dev.vert
                  FragmentProgramFileName = .\data\shaders\water\water.dev.frag
water.lib:21      ReflectionAmount = 1
water.lib:53-59   CustomReflection = False / CustomReflectionUnit = 0
                  CustomTexReflectMatrix = False / CustomTexReflectMatrixUnit = 0
```

Vertex side establishes a projective UVW:

```
water.dev.vert:15   gl_TexCoord[0]=gl_TextureMatrix[0]*pos;
```

Fragment side consumes it as a **projected 2D** texture (not a cube):

```
water.dev.frag:5-6    uniform sampler2D waveMap;
                      uniform sampler2D reflectionMap;
water.dev.frag:192-194 vec3 normwater=normalize(vec3(h3-h4, h1-h2, 0.15));
                      vec2 wavejitter=normwater.xy*texScaleT*(level-height);
                      uv+=wavejitter;
water.dev.frag:207-210 vec3 refuv=gl_TexCoord[0].xyw;
                      refuv.xy-=wavejitter*refuv.z;
                      vec4 refcol=texture2DProj(reflectionMap, refuv);
                      refcol.xyz*=(refcol.x+refcol.y+refcol.z)*hdrMultiplier;
water.dev.frag:213    watercolor=watercolor+refcol.xyz;
```

The `.bak` shader shows the same construction with explicit Fresnel and `hdrMultiplier`
(`water.frag.bak:2,33-45`). `uniform sampler2D` + `texture2DProj` + `gl_TextureMatrix[0]` is
the signature of a **live planar/screen-space reflection render target whose UVs are jittered by
the wave normal** — *not* a `samplerCube` lookup and *not* a decal. The `WaterReflection` video
option (`eventsettings.inc:155,533-537`) confirms this is an engine-driven, user-toggleable
real-time feature.

### 3.2 Cubemap = object environment reflection (separate system)

```
refcubemap.mat:3        Name = cubemap
refcubemap.mat:24-29    PicturePX..NZ = .\data\materials\cubemap\cubemap_c00..05.bmp
refcubemap.mat:33       mappingmode = tmmCubeMapReflection
refcubemap.mat:31-32    magfilter = maNearest / minfilter = miNearestMipmapNearest

refbuildingnormal.mat:23-27   ShaderTexEx.List[1].LibName = cubemap; TexIndex = 2
refmountainnormal.mat:23-27   ShaderTexEx.List[1].LibName = cubemap; TexIndex = 2

shaders.lib:157-194,1056-1093  DecalCubeMap program:
   vertex   = .\data\shaders\obj\dec.ref.pvl.sm.vert
   fragment = .\data\shaders\obj\dec.ref.pvl.smx3.frag / smx9.frag
   uniforms: texUnit0 -> value 0 ; texUnit1 -> value 1   (:176-191, :1075-1090)

dec.ref.pvl.sm.vert:21-23   gl_TexCoord[0]=gl_TextureMatrix[0]*gl_MultiTexCoord0;
                            gl_TexCoord[1]=vec4(reflect(vec3(realpos), n), 1.0);
dec.ref.pvl.smx3.frag:1-2   uniform sampler2D texUnit0; uniform samplerCube texUnit1;
dec.ref.pvl.smx3.frag:11-15 tex0=texture2D(texUnit0, ...); cub0=textureCube(texUnit1, gl_TexCoord[1].xyz);
                            color=tex0*cub0*gl_TexCoord[4]+gl_TexCoord[5];

shaders.lib:1173-1252  `env` program env.sm.id3.vert + env.smx9.id3.frag:
   texUnit0 -> value 0 ; texUnit1 -> value 1 (:1225-1242); specularPower (:1243-1251)
env.smx9.id3.frag:1-2,13-14,22   samplerCube texUnit1; textureCube(...);
                                 specular = pow(...)*...*tex1*tex0.a*specularPower;
```

So the cubemap is wired for **object specular/environment reflection modulated over a base
texture** (`tex0*cub0`), using the hardware `reflect()` vector. `DecalCubeMap` is the "decal-like"
variant; `env` is the specular variant. Neither path appears in the water shaders.

### 3.3 What remains UNVERIFIED — and what would settle it

- The **literal sampler→texture-unit binding** of `reflectionMap`, `waveMap`, `hmapTex` lives in
  `cossacks.exe` (the water shaders are loaded directly by `water.lib:67-68`, not via
  `shaders.lib` — grep for `water.dev.frag`/`reflectionMap` in `shaders.lib` = 0 matches).
  Plaintext cannot show whether `reflectionMap` is (a) a mirrored-camera planar FBO, (b) a
  previous-frame screen copy, or (c) something else. Prior docs (
  `WATER_REPORT.md §2.3`, `TERRAIN_DONOR_WATER.md:94,225`) already mark this UNVERIFIED; this
  audit **does not resolve it** — the shader form (projective UVW + `gl_TextureMatrix`) only
  proves it is a *projected texture*, not its provenance.
- The cubemap is defined only in **reference templates**: grep for `refcubemap.mat`,
  `refbuildingnormal.mat`, `refmountainnormal.mat` across all of `data` returns **0 matches** —
  no shipped `.mat` inherits them. The `env`/`DecalCubeMap` shader families exist and bind
  `texUnit1`, but whether the retail game instantiates a cubemap reflect probe at runtime is
  not provable from plaintext.
- **What would settle it:** Deep-mode craftanything xref of the sampler-uniform names to the
  engine's texture-binding calls, or static disassembly of `cossacks.exe` for the
  `reflectionMap`/`WaterReflection` symbol and the FBO setup. A donor run is forbidden by the
  task; hence these stay open (§7).

### 3.4 Binding-chain summary

```
WATER:  water.lib:67-68 → water.dev.vert:15 (TextureMatrix[0] UVW)
        → water.dev.frag:6,207-213 sampler2D reflectionMap + texture2DProj + wavejitter
        → [C++ binding in cossacks.exe: UNVERIFIED whether planar FBO or screen copy]
        → engine toggle WaterReflection (eventsettings.inc:155,533-537)

OBJECT: refcubemap.mat:24-33 (6 faces, tmmCubeMapReflection)
        → refbuildingnormal/refmountainnormal.mat:24-27 (LibName=cubemap)
        → shaders.lib DecalCubeMap / env programs (texUnit1=unit 1)
        → dec.ref.pvl.sm.vert:23 reflect() → dec.ref.pvl.smx*.frag / env.smx9.id3.frag samplerCube
        → [runtime instantiation of the template: UNVERIFIED]
```

---

## 4. Explicit answer to the decal question

**Q: Are `data/terrain/decals/*` or `data/materials/env/*` used as reflections anywhere?**

**A: NO — both are NO.** Evidence:

| Folder | Answer | Evidence |
|--------|--------|----------|
| `data/terrain/decals/*` | **NO** | 469 DXT5 **ground overlays** (building plates `d`/`dw`, `groundexp*`, `envfieldd/w`) with coverage alpha (`TERRAIN_DONOR_ASSETS.md`, `PIECES/donor_decals_and_masks.md`; 462 building DDS counted this audit). Their consumer is terrain decal placement, not any shader with `samplerCube`/`reflectionMap`. The only "decal" reflection is a **different** thing: the `DecalCubeMap` *object shader family* (`shaders.lib:157,1056`) which multiplies a cubemap over a base texture on buildings/mountains; it does not read terrain decal files. |
| `data/materials/env/*` | **NO** | `env.mat` (70,044 B) defines decor materials (`fir1`, `stones`, `field`… at `:2-55`), all `{refurl=refbase.mat}`; the folder holds tree/bush/rock/terrainmesh/mine DDS. No cubemap, no `samplerCube`, no reflection uniform. The **sky** lives elsewhere (`data/env/skydome/`), and it is a procedural dome + one `menu.dds`, not a reflection. Note the name collision: the `env*` **shader family** (`env.smx9.id3.frag`) does use `samplerCube` — but that is object reflection shading in `data/shaders/obj/`, unrelated to the `materials/env/` textures. |

**Owner's intuition adjudicated:** partly right in spirit — the donor *does* apply reflection as a
decal-style overlay (`DecalCubeMap`) and *does* have a "ref"-named material folder — but the
specific `decals`/`materials/env` folders are **ground cover and scenery**, not the reflection
source. The water reflection is a projected live texture; the object reflection is a 128² cube map.

---

## 5. Portability assessment for the M0 3D sandbox

### 5.1 Can `cubemap_c00..05.bmp` become a Godot `Cubemap`? — **Yes, mechanically**

| Step | Exact requirement |
|------|-------------------|
| Convert | 6 × 128×128 **RGB** BMP → 6 PNG (or load BMP via `Image.load()` in a build tool). Faces are power-of-two and square → valid cubemap faces. |
| Assemble | Godot 4 editor Cubemap creation is regressed (issue #65665); build-time `Cubemap.create(128,128,Image.FORMAT_RGBA8,true)` + `set_side(SIDE_+X … SIDE_-Z, image)` + `ResourceSaver` (prior `WATER_PERF.md:78`). Convert RGB→RGBA; sRGB import / `source_color` hint for correct linear lighting. |
| Face order | `cubemap_c00=PX(+X)`, `c01=NX(-X)`, `c02=PY(+Y)`, `c03=NY(-Y)`, `c04=PZ(+Z)`, `c05=NZ(-Z)` per `refcubemap.mat:24-29`. |
| Shader | `shader_type spatial`; `uniform samplerCube reflection_cube : source_color;` and sample `texture(reflection_cube, reflect(-VIEW, NORMAL))` (Godot 4 shading language uses `texture()`, not GLSL `textureCube`). `~6×128×128×4 ≈ 393 KiB` GPU; one cubemap fetch/pixel, no per-frame copy. |
| Legal | Private-use conversion only; a licence review is required before any shipping/distribution (prior `WATER_PERF.md:78`). |

### 5.2 Is a screen-space alternative more faithful? — **Yes, for water**

Because the donor's **water** shader samples a *projected* `sampler2D` reflectionMap, not the
cube map (§3.1), a screen-space proxy is closer to observed donor water behaviour than a static
cube map:

- `uniform sampler2D screen_tex : hint_screen_texture, repeat_disable, filter_linear;`
- sample `SCREEN_UV` offset by wave-normal-derived jitter (donor `wavejitter`, `frag:193-194,208`);
- multiply by luminance + `hdrMultiplier=1` and add to the body (`frag:210,213`).

Caveats: `hint_screen_texture` is supported in Compatibility but costs a screen copy; a true
donor-style mirror would need a `Camera3D` flipped across the water plane rendering into a
`SubViewport` (higher cost, most faithful to a planar reflection FBO). In the **M0 3D sandbox**
(`world3d.gd` inline `shader_type spatial` water; `RENDER_ARCH_SHADERS.md E31`) screen-space is
architecturally plausible — unlike the shipping 2D overlay, where prior `WATER_PERF.md:78`
showed it would contain only terrain due to z-order.

### 5.3 Trade-off table

| Approach | Donor fidelity | Cost | Donor asset needed | M0 verdict |
|----------|----------------|------|--------------------|------------|
| Screen-texture proxy (`hint_screen_texture` + wave jitter) | **Closest to donor water** (projected reflection, wave-distorted); proxy, not a true mirror | +1 screen copy + 1 fetch/px | None | **Add first** |
| Mirrored `Camera3D` → `SubViewport` planar reflection | Highest (live reflected geometry, matches FBO hypothesis) | Highest (second scene render) | None | Only if A/B needs true reflections |
| Converted donor `Cubemap` (`cubemap_c*.bmp`) | Static **sky/object env** reflection; **not** donor water behaviour | Cheapest per frame; build-time tool + licence review | 6 donor BMPs | Defer / optional, label clearly |

---

## 6. Recommendation for M0 water

**Add the screen-space projected reflection proxy first** in the M0 3D sandbox water shader
(the inline `shader_type spatial` in `app/scripts/world3d.gd`, or a `.gdshader` for clarity):

1. `uniform sampler2D screen_tex : hint_screen_texture, repeat_disable, filter_linear;`
2. derive `wavejitter` from the same wave-normal used by the sandbox water; sample
   `SCREEN_UV - jitter`;
3. `refcol.rgb *= (refcol.r+refcol.g+refcol.b)*hdrMultiplier /* =1 */;` and add to the body
   (mirror `water.dev.frag:207-213`);
4. expose a `reflection_enabled` uniform toggling 0/1 to reproduce the donor `WaterReflection`
   option and give an A/B control.

Rationale: it is the cheapest change that matches the *observed* donor water path (projected,
wave-distorted texture); it needs no donor asset copy, no conversion tool, no licence review,
and touches only rendering. Defer the cubemap conversion to a separate, licence-reviewed ticket
labelled "static sky/object reflection" — do not present it as donor water fidelity. Escalate to
a mirrored-Camera3D SubViewport only if the owner requires reflected scene geometry.

### Measurable acceptance

| # | Gate | Measurement | Threshold |
|---|------|-------------|-----------|
| A1 | Reflection present & wave-driven | Fixed camera; capture with `reflection_enabled=0` and `=1`, and two times 1 s apart. Diff the water region; with jitter on, the reflected pattern shifts measurably (target ≥3–5 px in the strongest-jitter patch) vs the jitter-off control; no reflection when toggled off. | Visible, measurable shift; clean A/B |
| A2 | No N-07 regression | Re-run `BAKE_BENCH` (`app/shots/perf.md:215-239`) and record max/mean frame. Water change is GPU-only, so bake must not change; compare to pre-change baseline. | ≤250 ms gate; **not worse than baseline** (current FAIL is 645.24 ms — fix is separate; do not mask it). Record frame-time delta of the screen copy |
| A3 | Sim determinism | Same seed, `--dump-map` JSON / selftest 29/29 + uitest 17/17 before and after (M4 rule, `RENDER_ARCH_SYNTHESIS.md:60`). Water is render-only: 0 changed `terrain[]`/`blocked[]`, 0 new RNG draws | Byte-identical dumps; all tests green |
| A4 | M0 visual gate intact | Non-blank 3D capture of ravine+shore patch; height error | <0.05 m; side-by-side with `cossacks-3-v1-498085.jpg` still acceptable |
| A5 | Provenance | Confirm no donor file copied into `app/`; cubemap, if later, via conversion tool with licence note | 0 donor copies this ticket |

---

## 7. Claim table (observed / derived / inferred / UNVERIFIED)

| ID | Claim | Evidence | Method | Status |
|----|-------|----------|--------|--------|
| C1 | Water reflection source is a `sampler2D` projected texture, not a cubemap | `water.dev.frag:6,207-210`; `water.dev.vert:15` | Direct read | **Observed / CONFIRMED** |
| C2 | Cubemap faces are 6 × 128×128 RGB BMP, 49,180 B each | Pillow + `Get-ChildItem` | Metadata | **Observed / CONFIRMED** |
| C3 | Cubemap face order PX..NZ = c00..c05, `tmmCubeMapReflection` | `refcubemap.mat:24-33` | Direct read | **Observed / CONFIRMED** |
| C4 | `materials/ref/` is a reference/template folder, not a reflection-named system | `env.mat:1`, `units.mat:1`, `materials.lib:1-24` | Direct read | **Observed / CONFIRMED** |
| C5 | `materials/env/*` = decor textures; `terrain/decals/*` = ground overlays; neither is a reflection | `env.mat:2-55`; prior `PIECES/donor_decals_and_masks.md` | Direct read + prior evidence | **Observed / CONFIRMED** |
| C6 | `DecalCubeMap`/`env` object shaders apply a cubemap with `reflect()`/`textureCube` | `shaders.lib:157-194,1056-1093,1173-1252`; `dec.ref.pvl.sm.vert:23`; `env.smx9.id3.frag:14` | Direct read | **Observed / CONFIRMED** |
| C7 | `WaterReflection` engine option exists | `eventsettings.inc:155,533-537` | Direct read | **Observed / CONFIRMED** |
| C8 | posteffects has no SSR/reflection pass | `posteffects.lib`, `.shaders` | Direct read | **Observed / CONFIRMED** |
| C9 | Water reflection is wave-jitter-distorted | `frag:193-194,208` (`wavejitter` offsets reflection UVW) | Direct read | **Derived / CONFIRMED** |
| C10 | Screen-space proxy is more faithful to donor water than the cubemap | C1 vs C3/C6 + donor shader form | Comparison | **Inferred** (faithful in *form*; source pixels unknown) |
| C11 | Cubemap is wired for object environment reflection | C3 + C6 + `texUnit1` bound to unit 1 | Chained read | **Inferred** (runtime instantiation not proven) |
| C12 | `reflectionMap` = mirrored-camera planar FBO (vs screen copy) | Projective UVW + `WaterReflection` option | Prior `WATER_REPORT.md §2.3` | **UNVERIFIED** — needs Deep-mode xref / disassembly |
| C13 | Which texture unit the cubemap binds to at runtime (`TexIndex=2` vs shader `texUnit1=1`) | `refbuildingnormal.mat:25` vs `shaders.lib:1235-1241` | Chained read | **UNVERIFIED** — unit numbering mismatch unresolved in plaintext |
| C14 | Donor cubemap is usable as a Godot `Cubemap` | 128² POT faces, explicit side order | Conversion path | **Derived / feasible** (licence + tool pending) |

---

## 8. Open questions

1. **O1.** What exactly is bound to `reflectionMap` — a live mirrored-camera FBO, a
   previous-frame screen copy, or something else? (Needs Deep-mode xref of the sampler uniform
   in `cossacks.exe`, or disassembly of the `WaterReflection` setup.)
2. **O2.** Does the retail game instantiate the `cubemap` reference template at runtime, and on
   which objects (buildings, mountains, units)? No shipped `.mat` inherits the cubemap-bearing
   templates; the shader families exist but instantiation is unproven.
3. **O3.** Why does `refbuildingnormal.mat:25` use `TexIndex = 2` while the `DecalCubeMap`/`env`
   shaders declare `texUnit1 -> value = 1`? Likely an engine-side offset/indexing convention —
   unresolved in plaintext.
4. **O4.** Colour space/gamma of `cubemap_c*.bmp` (authored sRGB vs linear) — confirm before
   setting `source_color`/import flags in Godot (refcubemap.mat:19-20 sets brightness/gamma = 1).
5. **O5.** Owner decision: screen-space proxy vs mirrored-Camera3D planar reflection for the
   M0 visual gate; cubemap deferred to a separate licence-reviewed ticket.

**End of document.**
