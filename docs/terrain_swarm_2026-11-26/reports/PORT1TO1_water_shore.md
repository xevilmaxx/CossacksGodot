---
id: PORT1TO1-WATER
wave: PORT1TO1 (NO-APPROXIMATION donor port, worker PORT1TO1-WATER)
ticket: "Exact 1:1 donor water+shore rewrite spec: descriptors, 30 uniform keys and sources, shader pairs, hmap discard, colours, field raster/plane geometry, collision discs, alpha semantics, Godot plan"
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
labels: [O, D, I, U, "PORT APPROXIMATION (prohibited here)"]
donor: "C:\\Games\\Cossacks 3 (READ ONLY; no donor binary executed; no donor file copied; no repo code/asset/config/Godot/git edit)"
targets: "Craft Anything 0.6.1, deep mode. cossacks.exe t_87f0f3c130b0 (sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c) opened read-only this ticket and kept ACTIVE for every call. editor.exe t_68474ddde43f (sha256 68474ddde43f…) opened implicitly by read-only path-scoped byte searches; global active target NEVER switched (verified core_session_show at start and after editor probes)."
prior_art: "DEC_DEEP_water_color.md, DEC_LANDSCAPE_hills_water.md, DEC_SMALL_shore_rings.md, DEC_SHORE_EDGE.md, D06_water_shore.md, X11_water_translation.md, current variant3d/scripts/water3d.gd, terrain_donor_mesh.gd, shaders/water3d.gdshader"
multi_pass: true
visual_parity_claim: false
---

# PORT1TO1-WATER — exact donor water + shore spec (read-only decompilation, 2026-11-26)

## 0. Authority, discipline and the single most important correction

Every donor statement below is `[O]` (verbatim bytes/text/decompiled instruction), `[D]` (deterministic arithmetic/control-flow from `[O]`), `[I]` (interpretation) or `[U]` (UNVERIFIED — an exact settling experiment is given in §11). All native calls were pinned with `document:"t_87f0f3c130b0"`. No donor binary was run, no asset copied, no source/shader/config/Godot/git touched.

**Correction to prior art (`DEC_DEEP_water_color.md` §port-fix):** the blue constants `(0.43,0.60,0.66)` / `(0.06,0.07,0.11)`, `coast2water_fadedepth=0.10`, `WATER_LEVEL=1.5` and the `if (gl_TexCoord[3].z>h)` discard belong to `data/shaders/water/water.frag` + `water.vert`, which are **NOT the shader pair pinned by `water.lib:67-68`**. `water.lib:67-68` pins `water.dev.vert` + `water.dev.frag`, whose live colours are `(0.1,0.24,0.24)` / `(0,0.025,0.05)`, fade `0.57`, and whose discard is `fragColor=vec4(0.0)` (no legacy hmap texel fallback). A further **third** shader pair is embedded as C string literals inside `cossacks.exe` and compiled by `FUN_00855b38`; it uses `deepColor`/`shallowColor` from `water.lib` and `alphaDepth=gl_Color.r`. Which of the three paths is live at runtime is `[U]` (§11 U1). **No port may silently choose one.** No approximation, no grey fallback, no parity claim.

---

## 1. Pass ledger (owner rule: ≤5 passes per function; all logged)

| # | Function / question | Passes | Result / accepted? |
|---|---|---|---|
| P1 | `FUN_00853ad4` @0x853ad4 (30-key descriptor init) | 1: Deep Ghidra `native_function_pseudocode` (`ev_4ddab2aa…`) | **Accepted**; re-confirms D06 verbatim. Built-in `native_function_callers_list` failed `function_not_found` — tool limitation, not absence. |
| P2 | `FUN_00852298` @0x852298 (water.lib `waters` descriptor parser) | 2: `native_function_study` (`ev_69083e8c…`, 401 insns/63 callees) + Deep pseudocode (`ev_8d7668eb…`, 264 lines) | **Accepted**: exact field offsets of the water-lib descriptor. |
| P3 | `FUN_00853150` @0x853150 (water.lib *file* keys) | 1: Deep pseudocode (`ev_68633b8d…`) | **Accepted**: +0x0c..+0x24 filenames/index/tag. |
| P4 | `sub_601d3c` @0x601d3c (DScript API registration host) | 2: study (`ev_644366df…`, 891 blocks/1641 insns) + Deep pseudocode | **Rejected as evidence**: 423,479-char garbage pseudo-C (263 gotos/476 `__asm`). Registration table recovered from raw bytes instead (P5). |
| P5 | `WaterFieldAdd` binding | 1: `native_bytes_find` pointer to its name payload + `native_bytes_show` of registration table (`ev_c987ab1b…`) + `native_function_disassemble` (`ev_626574ae…`) | **Accepted**: implementation = `FUN_00603d30` @0x603d30; record `b9 30 3d 60 00 ba a8 29 60 00`. |
| P6 | `FUN_00603d30` | 3: study (`ev_beedc5d0…`), Deep pseudo (`ev_626574ae…`), disassembly | **Accepted**: 35 insns, exact field/Y/bounds calls. |
| P7 | `FUN_0073b57c` / `FUN_0073ab50` / `FUN_0073b8e4` / `FUN_0073b8dc` | 1/1/2/1 Deep pseudo (+disasm for b8e4) | **Accepted**: plane X/Z/Y writes, width/depth fields, field construction. |
| P8 | `FUN_00890d34`, `FUN_00826b30`, `FUN_008520a8`, `FUN_0085224c`, `FUN_0085600c`, `FUN_00855fe0` | 1 study/disasm each (`FUN_00826b30` disasm full) | **Accepted**: vector writes, `glColor4f(1,1,1,1)`, `glBegin(4)`=GL_TRIANGLES, draw loop, uniform staging. |
| P9 | Embedded default shaders | 4: `native_bytes_find` of `uniform float waveFreq` @0x854b30; Python verbatim dump 0x453e40-0x455100; `native_function_pseudocode` `FUN_00854ac0` (`ev_5dc9caf1…`) and `FUN_008551d8` (`ev_ce22a2e5…`) | **Accepted**: both embedded sources recovered verbatim. |
| P10 | Shader compile/selection | 3: `FUN_00855b38` pseudo (`ev_fd9758ee…`), `FUN_00856530` pseudo (`ev_03e0dcca…`), byte-level call-site scan | **Accepted**: embedded pair compiled into program at +0x50; external pair selection remains `[U]`. |
| P11 | 30-key *binder* and enable mask | 3: Python byte scan of `f6 43 7c …` @0x85405d..0x854102; Deep pseudo `FUN_00854054` (`ev_16a55d54…`/`ev_e9e7a632…`); float-bit check | **Accepted, decisive**: +0x7c..+0x7f = 32-bit *uniform-enable bitmask*, default `0x3FFFFFFF` (all 30 keys on). NOT a shader float. |
| P12 | `FUN_00854398` @0x854398 (`ShaderUniforms` `f*` keys) | 1: Deep pseudo | **Accepted**: 30 `f*` config names + `fWaterStates` referencing `wst*` table @0x8fabb0. |
| P13 | Shader object construction | 1: Deep pseudo `FUN_00856080` (`ev_d9277ee3…`) | **Accepted**: descriptor lives at shader+0xf4; engine default colours/texture units recovered. |
| P14 | `FUN_00853ebc` / `FUN_00853ad4` call sites | 2: Deep pseudo (`ev_e93445e8…`) + Python call scan | **Accepted**: descriptor allocator; call sites 0x853ed0, 0x8562c0. |
| P15 | `FUN_00545e0c` (mesh/layer creation) | 2: study (`ev_d833c87b…`) + Deep pseudo | **Partial**: creates a render object and registers it; per-vertex quad layout still `[U]`. |
| P16 | RTTI/class identity | 3: `native_bytes_find` `TXWaterShader` (`ev_89446809…`), `XWaterShader` (4 hits), `fXWaterField` (`ev_4a895cb2…`) | **Accepted as RTTI only**; no code xref → class binding `[U]`. |
| P17 | editor.exe cross-check (`path=` only, active unchanged) | 3: `native_bytes_find` `deepColor` (3 hits), `function WaterFieldAdd` (1), `uniform sampler2D hmapTex` (**0**) | **Accepted**: editor build carries the built-in shader but not `hmapTex` shader text. |
| P18 | Native `MapDrawCollision` kernel | 1: `native_bytes_find` @0x687fca (1 hit); no implementation decompiled | **Not recovered** → `[U]` with experiment (§11 U11). Script semantics are `[O]`. |

Failed/limitation passes are retained deliberately: built-in `native_function_find` misses 0x853ad4/0x8552c0/0x855ce0/0x85405d; `native_objdump_run` unavailable (no objdump); `native_xrefs_list` returns 0 for 0x853e0c/0x853cd0 (immediate operands in undiscovered functions).

---

## 2. Hero evidence table (new this ticket)

| Evidence id | Source | Establishes |
|---|---|---|
| `ev_8d7668eb6078e5d6b4f38748683eef0096f61f7fd38e5aea0af3321ebcd4c199` | Deep pseudo `FUN_00852298` | All 47 `water.lib` `waters` config keys → descriptor field offsets +0x04..+0xf8. |
| `ev_68633b8dbf084fecdc9055e8647afa43a1ab45edaf6dd8c132ffe4fe5a5afda6` | Deep pseudo `FUN_00853150` | File-level keys → +0x0c material lib, +0x10 default index, +0x14 tag, +0x18/+0x1c VP/FP filenames. |
| `ev_16a55d5469092dc3a559478db683fcb8481d4f6c2a3da573d2b10f2843ec581a` | Deep pseudo `FUN_00854054` | 30 uniform keys bound per bit of +0x7c..+0x7f, with exact runtime value sources. |
| `ev_626574ae222dec3a4ca1b6e81a55874c24cae0e2c0aae4b613d3f350d514f86a` | Deep pseudo + disasm `FUN_00603d30` | `WaterFieldAdd` native implementation. |
| `ev_5dc9caf177e9e66467beedfe57b31b070ff42e9f35cb7306e04b92ef603ebf80` | Deep pseudo `FUN_00854ac0` | Embedded default vertex shader source, verbatim in C literal. |
| `ev_ce22a2e5d641c6cdc1dabafffb509abfb261359938f32c5d8f42b063ade9f0db` | Deep pseudo `FUN_008551d8` | Embedded default fragment shader source, verbatim in C literal. |
| `ev_fd9758ee66f3c6bba654b99eabf9fd4bb90abb774fa51b77d5808fc139940fa2` | Deep pseudo `FUN_00855b38` | Embedded pair compiled into program at shader+0x50. |
| `ev_d9277ee31a563b52091b6bebce7877657b0d2e258139fc2e9955ec8eaa49cbca` | Deep pseudo `FUN_00856080` | Shader object defaults; 30-key descriptor at +0xf4; default colours alpha 0.5. |
| `ev_c987ab1b4f4baee2d99fe7c877a719d0194ca4f1f803e3605b32547f7dcef8d4` | `native_bytes_show(0x601660)` | DScript registration table; `WaterFieldAdd → FUN_00603d30`. |
| `ev_894468094346dd971d47c9523ecd5ee848efba7890d6551ad8621ab6db42f600` | bytes `TXWaterShader` | CODE 0x8537f3 / 0x853806; RTTI .rsrc 0x958c11. |
| `ev_116683896d284b4ecbd4f6a8a73a6afc80055399c171a42ae0854d46fceaa365` | `native_bytes_show(0x8537e0,512)` | 30 `wst*` labels + 30 plain uniform key strings. |
| `ev_774ede0ea54a878f307c9157fdf3610694cbee513d467266a7952a9d42326075` | bytes `deepColor` | 3 CODE hits: descriptor 0x853cbc + embedded shader 0x8552c0/0x855807. |
| `ev_41a9076a90a4d05eec781fb15a3a6076f0267f52554718f498071c2e004efff2` | bytes `b8 3e 85 00` | Only reference to 0x853eb8 is the epilogue copy into descriptor +0x7c. |
| `ev_f4f0e5d056203dc831fc717c44922a9e24250dbb54b14cf2085f92ae7b095cbb` | `generatemap.inc` (D06 chain) | Exact 2×2 raster and `cOffsetY=-0.5` (re-read this ticket). |
| `ev_461b4b9d7c82d918be8a8d26bc73f30b0caa4de257bf50e85834ece7a43fa34e` | `texturemap.inc` (D06 chain) | Shore gate, 8×45° sectors, `sandsea1/5/6` (re-read this ticket). |
| `ev_57b8cb760afa6ef7995a869a21d8a6ff292e74934701914caac6367a2c803a57` | `dmscript.global` (D06 chain) | `gc_WaterBorderSize=3` (re-read this ticket). |

---

## 3. Classes and field descriptors `[O]` / `[D]`

### 3.1 RTTI and object identity `[O]`

- `TXWaterShader` at CODE VA `0x8537f3` and `0x853806` (`ev_89446809…`); `XWaterShader` at CODE `0x8537f4`, `0x853807`, `0x85381e` and `.rsrc` `0x958c11`. `fXWaterField` at `.rsrc` `0x95937b`; `XWater` at `.rsrc` `0x95938a`.
- `[D]` These are **names only**: no code xref was recovered (`native_functions_search`/`native_xrefs_list` = 0, D06 P1/P2). Which concrete object owns the shader descriptor is `[U]` (§11 U2). The *functional* identity is unambiguous from code: the object built by `FUN_00856080` @0x8562c0 is the water shader/render state object; it holds the 30-key descriptor at `+0xf4`, texture units at `+0xf8/+0xfc`, program at `+0x50`, embedded VP/FP source handles at `+0x178/+0x17c`.
- `FUN_00853ebc` @0x853ed0 is the allocator wrapper: `FUN_004048ec()` then `FUN_00853ad4(obj)` (`ev_e93445e8…`). Call sites of `FUN_00853ad4`: 0x853ed0 and 0x8562c0. Call sites of the binder `FUN_00854054`: 0x8565d2 and 0x856897, both inside `FUN_00856530` — i.e. binding happens in the shader setup path.

### 3.2 `water.lib` **file** descriptor (`FUN_00853150`) `[O]`

| Offset | Field | water.lib value |
|---:|---|---|
| +0x0c | `MaterialLibraryFileName` | `.\data\water\water.mat` |
| +0x10 | `DefaultWaterIndex` | 0 |
| +0x14 | `Tag` | 512 |
| +0x18 | `VertexProgramFileName` | `.\data\shaders\water\water.dev.vert` |
| +0x1c | `FragmentProgramFileName` | `.\data\shaders\water\water.dev.frag` |
| +0x20/+0x24 | LOD VP/FP filenames | empty |

### 3.3 `waters` **layer** descriptor (`FUN_00852298`, `water.lib:4-62`) `[O]`

| Offset | Key | Value |
|---:|---|---|
| +0x04 | Name | `default` |
| +0x08/+0x0c | MaxDepth / MinDepth | 1 / 0 |
| +0x10/+0x14 | MaxAlpha / MinAlpha | 1.1 / 0 |
| +0x18,+0x1c,+0x20,+0x24 | DeepColor R,G,B,A | 0, 0, 0.1255, 0.5 |
| +0x28,+0x2c,+0x30,+0x34 | ShallowColor R,G,B,A | 0, 0, 0, 0.5 |
| +0x38/+0x3c | ReflectionAmount / WaterAmount | 1 / 1 |
| +0x40/+0x44 | FresnelPower / FresnelBias | 1 / 1 |
| +0x48 | HDRMultiplier | 1 |
| +0x4c/+0x50 | WaveFreq / WaveAmp | 0 / 0 |
| +0x54/+0x58 | DistFactor / BumpFactor | 1 / 1 |
| +0x5c/+0x60 | TexScaleS / TexScaleT | 0.1 / 0.01 |
| +0x64/+0x68 | WaveDir0 X/Y | −1 / 0 |
| +0x6c/+0x70 | WaveDir1 X/Y | −0.7 / 0.7 |
| +0x74 | Speed | 1.0 |
| +0x78/+0x7c | NormalMapLibMaterialName / DiffuseMapLibMaterialName | `DiffuseWaves2` / `DiffuseWaves0` |
| +0x80/+0x84/+0x88 | Width / Height / Offset | 1 / 1 / 0.495 |
| +0x8c | LayerCount | 1 |
| +0x90,+0x94,+0x98,+0x9c,+0xa0,+0xa4 | CustomEnable, CustomShaderID, CustomUniforms, CustomReflection, CustomReflectionUnit, CustomLibMaterialName | False, 0, —, False, 0, empty |
| +0xa8,+0xac,+0xb0,+0xb4,+0xb8 | CustomTexCoord, CustomTexCoordScale, CustomTexReflectMatrix, CustomTexReflectMatrixUnit, CustomUseUniforms | True, 1, False, 0, — |
| +0xb9 / +0xbc | HeightMapEnable / HeightMapTexUnit | True / (unset in file) |
| +0xc0 / +0xc4 | ShadowMapEnable / ShaderUniforms | True / (unset in file) |
| +0xc8,+0xcc,+0xd0 | MirrorTexUnit, NormalTexUnit, DiffuseTexUnit | unset |
| +0xd4 | BlendingMode | parsed through enum table `PTR_PTR_008fc658` index 5 |
| +0xd8…+0xf8 | DiffuseTexScale0/1, TextureCombiners | unset |

`FUN_00852298` also reads `//TexScaleS=0.115`/`//TexScaleT=0.015` as commented lines only; the live values are 0.1/0.01. `[D]` `Offset=0.495` is a *layer parameter*, not the water plane Y — the plane Y comes from `WaterFieldAdd(...,cOffsetY=-0.5)` (§7).

### 3.4 Shader object defaults (`FUN_00856080`) `[O]`

`+0x54=1, +0x55=1, +0x58=1.0, +0x5c=0, +0x60=1.0, +0x64=0`; colours at `+0x68` and `+0x78` are RGBA with **A=0.5** (`FUN_004a21e8(...,0x3f000000,...)` = 0.5f); `+0x88=0.4, +0x8c=0.3, +0x90=4.0, +0x94=0.1, +0x98=0.5, +0x9c=1.0, +0xa0=0.05, +0xa4=2.0, +0xa8=0.01, +0xac=0.4, +0xb0=0.825`; `+0xd8=0xde1 (GL_TEXTURE_2D), +0xdc=2`; descriptor at `+0xf4`; `+0xf8=0, +0xfc=1`; texture-combiner string at `+0x180 = "Tex0:=Tex1*Tex0;\r\nTex1:=Tex0+Col;"`. `[D]` The `+0x68/+0x78` RGBA slots are the engine-side values ultimately delivered as `deepColor`/`shallowColor` to the embedded fragment (binder bit4/bit5, §4). Exact per-frame numeric contents remain `[U]` (§11 U4).

---

## 4. The 30 uniform keys: names, order, enable mask, exact runtime sources

### 4.1 Three parallel name tables `[O]`

1. **`wst*` labels** (CODE `0x85382c`–`0x853abc`, `ev_11668389…`): `wstReflectTex, wstWaveTex, wstTime, wstEyePos, wstDeepColor, wstShallowColor, wstReflectAmount, wstWaterAmount, wstFresnelPower, wstFresnelBias, wstHdrMultiplier, wstWaveFreq, wstWaveAmp, wstDistFactor, wstBumpFactor, wstTexScaleS, wstTexScaleT, wstWaveDir0, wstWaveDir1, wstFogEnabled, wstHMapTex, wstHMapWidth, wstHMapHeight, wstHMapMin, wstHMapMax, wstShadowed, wstShadowTex, wstShadowSize, wstShadowColor, wstCameraModel` — exactly 30. `FUN_00898004(param,"fWaterStates",&PTR_s_wstReflectTex_008fabb0)` (`FUN_00854398`) shows these are the default table for the `fWaterStates` config block.
2. **plain uniform keys** assigned by `FUN_00853ad4` (`ev_4ddab2aa…`) at descriptor `+0x04..+0x78`, listed below.
3. **`f*` config keys** read by `FUN_00854398` from `ShaderUniforms`: `fWaterStates` plus `fReflectTex, fWaveTex, fTime, fEyePos, fDeepColor, fShallowColor, fReflectAmount, fWaterAmount, fFresnelPower, fFresnelBias, fHdrMultiplier, fWaveFreq, fWaveAmp, fDistFactor, fBumpFactor, fTexScaleS, fTexScaleT, fWaveDir0, fWaveDir1, fFogEnabled, fHMapTex, fHMapWidth, fHMapHeight, fHMapMin, fHMapMax, fShadowed, fShadowTex, fShadowSize, fShadowColor, fCameraModel` — 30 + the states table. `[D]` Each `f*` key overwrites the corresponding plain key string in the descriptor; `ShaderUniforms` is absent from shipped `water.lib`, so the plain defaults remain in the shipped configuration.

### 4.2 Enable mask `[O]` / `[D]`

`FUN_00853ad4` ends with `*(undefined4 *)(obj+0x7c) = DAT_00853eb8` where the f32 at 0x853eb8 is `1.99999988` = IEEE bits **`0x3FFFFFFF`** (verified by float-bit computation; single file reference at 0x853c5e, `ev_41a9076a…`). `FUN_00854054` tests **each of the 30 bits** of the 4-byte mask at +0x7c,+0x7d,+0x7e,+0x7f. `[D]` It is a *32-bit uniform-enable bitmask with all 30 lower bits set*, **not** a shader float and not a "1.9999" constant. Bits 30–31 have no key.

### 4.3 Exact binder table (`FUN_00854054`, `ev_16a55d54…`) `[O]`

`P`=program (shader+0x50), `C`=shader object (param_3), `V`=caller/camera object (param_2). Functions: `S(program,name,unit)=FUN_004c0fb8` (sampler/int), `K(program,name)=FUN_004c0f90` (scalar uniform location), `V3(program,name,ptr)=FUN_004c102c`, `V2(program,name,ptr)=FUN_004c0fdc`, `M(program,name,ptr)=FUN_004c1058`.

| # | `wst*` | plain key | `f*` key | off | bit | bind | runtime source `[O]` |
|---:|---|---|---|---:|---:|---|---|
| 1 | wstReflectTex | reflectionMap | fReflectTex | +04 | 7c.1 | S(P,key,C+0xf8) | reflection sampler unit stored on shader object |
| 2 | wstWaveTex | waveMap | fWaveTex | +08 | 7c.2 | S(P,key,C+0xfc) | wave sampler unit (=1 by default) |
| 3 | wstTime | time | fTime | +0c | 7c.4 | K(P,key) | scalar; numeric source `[U]` (§11 U5) |
| 4 | wstEyePos | eyePosition | fEyePos | +10 | 7c.8 | V3(P,key,V+8) | caller/camera eye vector |
| 5 | wstDeepColor | deepColor | fDeepColor | +14 | 7c.10 | V3(P,key,C+0x68) | shader-object deep RGBA (§3.4) |
| 6 | wstShallowColor | shallowColor | fShallowColor | +18 | 7c.20 | V3(P,key,C+0x78) | shader-object shallow RGBA |
| 7 | wstReflectAmount | reflectionAmount | fReflectAmount | +1c | 7c.40 | K(P,key) | scalar `[U]` |
| 8 | wstWaterAmount | waterAmount | fWaterAmount | +20 | 7c.80 | K(P,key) | scalar `[U]` |
| 9 | wstFresnelPower | fresnelPower | fFresnelPower | +24 | 7d.1 | K(P,key) | scalar `[U]` |
| 10 | wstFresnelBias | fresnelBias | fFresnelBias | +28 | 7d.2 | K(P,key) | scalar `[U]` |
| 11 | wstHdrMultiplier | hdrMultiplier | fHdrMultiplier | +2c | 7d.4 | K(P,key) | scalar `[U]` |
| 12 | wstWaveFreq | waveFreq | fWaveFreq | +30 | 7d.8 | K(P,key) | scalar `[U]` |
| 13 | wstWaveAmp | waveAmp | fWaveAmp | +34 | 7d.10 | K(P,key) | scalar `[U]` |
| 14 | wstDistFactor | distFactor | fDistFactor | +38 | 7d.20 | K(P,key) | scalar `[U]` |
| 15 | wstBumpFactor | bumpFactor | fBumpFactor | +3c | 7d.40 | K(P,key) | scalar `[U]` |
| 16 | wstTexScaleS | texScaleS | fTexScaleS | +40 | 7d.80 | K(P,key) | scalar `[U]` |
| 17 | wstTexScaleT | texScaleT | fTexScaleT | +44 | 7e.1 | K(P,key) | scalar `[U]` |
| 18 | wstWaveDir0 | waveDir0 | fWaveDir0 | +48 | 7e.2 | V2(P,key,C+0xb4) | shader-object vec2 |
| 19 | wstWaveDir1 | waveDir1 | fWaveDir1 | +4c | 7e.4 | V2(P,key,C+0xbc) | shader-object vec2 |
| 20 | wstFogEnabled | fogEnabled | fFogEnabled | +50 | 7e.8 | S(P,key, 0 or device-byte+1) | computed from capability byte `V+100+0x8c & 0x80` |
| 21 | wstHMapTex | hmapTex | fHMapTex | +54 | 7e.10 | S(P,key,C+0xdc) | **only if** height object `C+0xe0` exists; unit from `C+0xdc` |
| 22 | wstHMapWidth | hmapW | fHMapWidth | +58 | 7e.20 | S(P,key,C+0xd0) | height-object width (gated as above) |
| 23 | wstHMapHeight | hmapH | fHMapHeight | +5c | 7e.40 | S(P,key,C+0xd4) | height-object height (gated as above) |
| 24 | wstHMapMin | hmapMin | fHMapMin | +60 | 7e.80 | K(P,key) | scalar (gated as above) |
| 25 | wstHMapMax | hmapMax | fHMapMax | +64 | 7f.1 | K(P,key) | scalar (gated as above) |
| 26 | wstShadowed | shadowed | fShadowed | +68 | 7f.2 | S(P,key,0/1) | **only if** shadow object `C+0xec` exists; 1 iff shadow texture valid |
| 27 | wstShadowTex | shadowMap | fShadowTex | +6c | 7f.4 | S(P,key,shadowobj unit) | shadow object (`FUN_0081ea4c`) |
| 28 | wstShadowSize | shadowSize | fShadowSize | +70 | 7f.8 | S(P,key,shadowobj+0xb4) | shadow object size |
| 29 | wstShadowColor | shadowColor | fShadowColor | +74 | 7f.10 | V3(P,key,shadowobj+0xe0+0x18) | shadow object colour |
| 30 | wstCameraModel | cameraModel | fCameraModel | +78 | 7f.20 | M(P,key,camera+0xc0+0x24) | camera model matrix |

`FUN_00854054` is called from `FUN_00856530` only in the shader-enabled branch (`FUN_0085600c(C)` true), immediately after `FUN_004c0f5c(P)` and before texture setup. `[D]` This is the **single place** where the 30 key *strings* become GL uniforms; `hmapTex` is bound only when the height object exists — and the height object is an engine-side structure, not `heightmapwaves0.tga` (D06 P18: alpha 255 everywhere; `water.mat:86-106` fully commented).

---

## 5. Shader pair and all varyings / uniforms / textures

### 5.1 Shipped pair — `water.dev.vert` + `water.dev.frag` (pinned by `water.lib:67-68`) `[O]` (verbatim re-read)

`water.dev.vert` uniforms: `eyePosition` (vec4), `hmapW`, `hmapH` (int), `cameraModel` (mat4). Varyings: `eyeVector`, `lightVector` (vec3), `fogFragCoord` (float). Body:

```
gl_TexCoord[0] = gl_TextureMatrix[0]*pos;
gl_TexCoord[1].xy = gl_MultiTexCoord0.xy / vec2(hmapW,hmapH) - 0.5;
gl_TexCoord[1].z  = pos.y;                       // PLANE Y
gl_TexCoord[3]    = gl_TextureMatrix[3]*cameraModel*gl_ModelViewMatrix*pos;
eyeVector  = pos.xyz - eyePosition.xyz;
lightVector= vec3(LightSource[0].position.x/4.0, .z/2.0, .y/1.0);
fogFragCoord = ATI ? abs((MV*pos).z) : length(MV*pos);
gl_Position = ftransform();
```

No displacement. `[D]` The vertex shader is a flat passthrough; the plane's own vertex Y is the water level.

`water.dev.frag` uniforms: `time, texScaleS, texScaleT` (float); `waveMap, reflectionMap, hmapTex` (sampler2D); `hdrMultiplier` (float); `hmapMin, hmapMax` (float), `hmapW` (int); `fogEnabled` (int); `shadowed` (int), `shadowMap` (sampler2DShadow), `shadowSize` (int), `shadowColor` (vec4). Vertex varyings consumed: `eyeVector, lightVector, fogFragCoord`. Commented-out (dead): `deepColor, shallowColor, reflectionAmount, waterAmount, fresnelPower, fresnelBias, distFactor, bumpFactor`.

Live constants (verbatim): `coast2water_fadedepth=0.57`, `large_waveheight=0.50`, `large_wavesize=2.`, `small_waveheight=.5`, `small_wavesize=.5`, `water_softlight_fact=170.`, `water_glossylight_fact=120.`, `particle_amount=30.`, `watercolor=(0.1,0.24,0.24)`, `watercolor2=(0,0.025,0.05)`, `water_specularcolor=(0.4,0.4,0.4)`, `mat2 m=mat2(0.72,-1.60,1.60,0.72)`, shifts `(0.32t,0.24t)` and `(0.38t,-0.26t)`. Textures: waveMap (`diffusewaves0.bmp`, `tfLuminance`, `tmReplace`, `twBoth`), reflectionMap (projected FBO, provenance `[U]`), hmapTex (engine height object, `[U]`).

`main()` (verbatim semantics):
```
fragcoord = gl_TexCoord[1].xy;                    // NOT gl_FragCoord
mainImage(fragColor, fragcoord);
fragcolor = fogmap(fragcolor);
gl_FragColor = fragcolor;
```
`mainImage()` exact wet/dry + colour:
```
WATER_LEVEL = gl_TexCoord[1].z;
deepwater_fadedepth = 0.5 + coast2water_fadedepth;      // 1.07
height = height_map(uv) = hmapMin + texture2D(hmapTex,uv).w*(hmapMax-hmapMin);
waveheight = clamp(WATER_LEVEL*3.0 - 1.5, 0.0, 1.0);
level = WATER_LEVEL + 0.2*water_map(uv*15.0 + time*0.1, waveheight);
if (height > level) { fragColor = vec4(0.0); return; }   // <-- DISCARD EQUATION
// (redundant `if (height<=level)` encloses the rest)
dif=(0,0.01); pos=uv*15.0/texScaleS*(hmapW/128.0)+time*0.01;
normwater=normalize(vec3(h3-h4, h1-h2, 0.15));           // 4 water_map taps
uv += normwater.xy*texScaleT*(level-height);
rescolor = CalcTerrain(uv,height);                       // bed: (0.175,.1375,.1)+waveMap(p*8).rgb*.25, 4 hmap taps, grad+grad^8, shadow mix
coastfade  = clamp((level-height)/0.57, 0, 1);
coastfade2 = clamp((level-height)/1.07, 0, 1);
intensity  = rescolor.r*.2126 + g*.7152 + b*.0722;
watercolor = mix(watercolor*intensity, watercolor2, smoothstep(0.,1.,coastfade2));
refuv = gl_TexCoord[0].xyw; refuv.xy -= wavejitter*refuv.z;
refcol = texture2DProj(reflectionMap, refuv); refcol.xyz *= (r+g+b)*hdrMultiplier;
watercolor += refcol.xyz;
grad=dot(normwater,rd); specular=pow(grad,170); specular2=pow(grad,120);
specular1=smoothstep(0,1,pow(dot(vec3(0,0,1),rd),5));
watershade=test_shadow(uv,level);                        // 3-tap PCF if shadowed==1
watercolor*=2.2+watershade;
watercolor+=(.2+.8*watershade)*((grad-1.)*.5+specular)*.25;
watercolor/=(1.+specular1*1.25);
watercolor+=watershade*specular2*water_specularcolor;
watercolor+=watershade*coastfade*(1.-coastfade2)*(vec3(.5,.6,.7)*nautic(uv)+vec3(1,1,1)*particles(uv));
rescolor=mix(rescolor,watercolor,coastfade);
resalpha=coastfade2;
fragColor=vec4(rescolor, resalpha*1.0);
```
`fogmap`: mode 1 linear `clamp((gl_Fog.end-fogFragCoord)*gl_Fog.scale,0,1)`; mode 2 `exp2(-density*d*1.442695)`; mode 3 `exp2(-pow(density*d,2)*1.442695)`; default 0 = no fog.

`[D]` Derived: foam band `b(d)=clamp(d/0.57,0,1)*(1-clamp(d/1.07,0,1))`, zero at d=0 and d≥1.07, peak at **d=0.535** (≈0.4693). Alpha `=clamp(d/1.07,0,1)`; there is **no white rim at the mathematical waterline** (d=0 ⇒ alpha 0, bed shown). `waveheight=0` for `WATER_LEVEL≤0.5`, so the coarse swell term is exactly zero for any plausible generated plane Y (−0.5 or −0.25).

### 5.2 Legacy pair — `water.vert` + `water.frag` (NOT pinned by `water.lib`) `[O]` (verbatim re-read)

`water.vert` varyings: `eyeVector`, `alphaDepth=gl_Color.r`, `fogFragCoord`. Tex coords: `T0=MultiTexCoord0*texScaleS`, `T1=realpos*texScaleS+time*0.02`, `T2=realpos*texScaleT+time*0.02`, `T3.xy=MultiTexCoord0.xy/(hmapW,hmapH)-0.5`, `T3.z=gl_Vertex.y`; fog `abs(realpos.z)` (ATI) else `length(realpos)`; `ftransform()`.

`water.frag` constants: `coast2water_fadedepth=0.10`, `small_waveheight=.6`, `soft=15`, `particle_amount=70`, `watercolor=(0.43,0.60,0.66)`, `watercolor2=(0.06,0.07,0.11)`, `specularcolor=(1.3,1.3,0.9)`, `WATER_LEVEL=1.5/*0.94*/`, `iglobaltime=time*3.0`, `terrain_map=vec3(0)`, `nautic=1`, `test_shadow=1`. `height_map()` is a procedural fBm (not hmapTex) with `flat_level=0.525`. **Discard equation** (verbatim):
```
fragColor = texture2D(hmapTex, gl_TexCoord[3].xy);
h = hmapMin + fragColor.w*(hmapMax-hmapMin);
if (gl_TexCoord[3].z > h) { mainImage(fragColor, gl_TexCoord[0].xy); }
gl_FragColor = fragColor;
```
`mainImage` final `fragColor=vec4(col,1.0)` — **opaque**; dry pixels keep the raw `hmapTex` texel (this is the literal "grey fallback" path if hmapTex is wrong). `[D]` This pair is a development/tuning shader; do **not** use its colours, 1.5 plane, or discard in a 1:1 port of the shipped configuration. Its presence explains why earlier reports described blue #6E99A8 water.

### 5.3 Embedded built-in pair (inside `cossacks.exe`) `[O]`

Recovered verbatim from C literals in `FUN_00854ac0` (`ev_5dc9caf1…`, VA 0x8552xx) and `FUN_008551d8` (`ev_ce22a2e5…`, VA 0x8557xx); compiled by `FUN_00855b38` (`ev_fd9758ee…`). Uniforms/varyings:

- VP: `eyePosition, time, waveFreq, waveAmp, texScaleS /*0.01*/, texScaleT /*0.02*/, waveDir0 /*(-1,0)*/, waveDir1 /*(-0.7,0.7)*/, fogEnabled`; varyings `eyeVector, alphaDepth, fogFragCoord`; struct `Wave{freq,amp,phase,dir}`, `NWAVES=2`: `wave[0]=(waveFreq,waveAmp,0.5,waveDir0)`, `wave[1]=(3*waveFreq,0.33*waveAmp,1.7,waveDir1)`; `angle=dot(dir,P.xz)*freq+time*phase; P.y+=amp*sin(angle); deriv=freq*amp*cos(angle)`; `T0=TextureMatrix0*P`, `T1=P*texScaleS+time*0.02`, `T2=P*texScaleT+time*0.02`, `eyeVector=P.xyz-eyePosition.xyz`, `ftransform()`, `alphaDepth=gl_Color.r`.
- FP: `waveMap, reflectionMap, deepColor, shallowColor, reflectionAmount, waterAmount, fresnelPower, fresnelBias, hdrMultiplier, distFactor, bumpFactor, fogEnabled`; varyings as VP. Exact body:
```
t0=texture2D(waveMap,T1.xz).xyz; t1=texture2D(waveMap,T2.xz).xyz;
t=normalize(t0+t1-vec3(1,1,0)); fDist=distFactor/length(eyeVector);
facing=1.0+eyeVector.y*fDist*(0.1-t.y*bumpFactor);
fresnel=clamp(fresnelBias+pow(facing,fresnelPower),0,1);
waveJitter=t.xy*fDist; waveJitter.y=abs(waveJitter.y);
refuv=gl_TexCoord[0].xyw; refuv.xy-=waveJitter*refuv.z;
refcol=texture2DProj(reflectionMap,refuv);
refcol.rgb*=(r+g+b)*hdrMultiplier;
waterColor=mix(shallowColor,deepColor,facing)*waterAmount;
reflecColor=mix(waterColor,refcol,fresnel)*reflectionAmount;
gl_FragColor=waterColor+reflecColor;
gl_FragColor.a=alphaDepth;
fog = modes 1/2/3 same 1.442695 constants;
gl_FragColor=vec4(mix(vec3(gl_Fog.color),vec3(gl_FragColor),fog), gl_FragColor.a);
```
`[D]` With `fresnelBias=1` and `facing>0`, `fresnel=1`, so the reflected colour dominates; with `deepColor=(0,0,0.1255)`/`shallowColor=(0,0,0)` and an unbound reflection target the result is near-black/grey — a second concrete grey-failure mechanism distinct from the legacy hmap texel path. `[O]` editor.exe contains `deepColor` (3 hits) and `function WaterFieldAdd` but **zero** `uniform sampler2D hmapTex` — the editor build carries the built-in shader, not the `.dev` pair (P17).

---

## 6. hmap discard equation and depth semantics — all three forms `[O]/[D]`

| Pair | Wet/dry test | Dry result | Alpha |
|---|---|---|---|
| shipped `.dev` | `height = hmapMin+w*(hmapMax-hmapMin); level = gl_TexCoord[1].z + 0.2*water_map(...); if (height>level)` | `fragColor=vec4(0.0)` → **transparent black**, never a grey texel | `coastfade2=clamp((level-height)/1.07,0,1)` |
| legacy `water.frag` | `if (gl_TexCoord[3].z > h)` then `mainImage` | **keeps raw hmapTex texel** (grey if misbound) | `1.0` (opaque) |
| embedded built-in | **no hmap test at all** | always draws field | `gl_FragColor.a = alphaDepth = gl_Color.r` |

`[D]` The `.dev` discard is an *inequality against the animated level*, not against a fixed plane: `level = Y + 0.2*water_map(uv*15+0.1t, waveheight)`, and the 9-octave ridged chop subtracts `amp*abs(sin(...))` with `amp>0`, so `water_map≤0` when `waveheight=0` ⇒ `level≤Y`. With `Y=-0.5` and terrain basin `h≈-1.1..0` (generatemap.inc:7), the test `h>level` passes (dry) on shore cells and fails (wet) in the basin, producing the blue ring. Exact engine `hmapMin/hmapMax/hmapW/hmapH` and hmap texture identity are `[U]` (§11 U3).

---

## 7. World-space field generation: 2×2 raster, `cOffsetY`, exact plane geometry

### 7.1 Script raster (verbatim, GSC `;`-prefixed → runtime `[U]`) `[O]`

`generatemap.inc:647-707` (re-read this ticket):

```
if cPlaceWater then
  const cWaterFieldSize = 2;
  const cWaterMapArrSize = (640 div cWaterFieldSize);          // 320
  var bWaterMap[0..320,0..320] : Boolean;
  for wmy:=0 to cWaterMapArrSize-1 do
  for wmx:=0 to cWaterMapArrSize-1 do
    for y:=wmy*2 .. Min((wmy+1)*2, mapheight-1) do
    for x:=wmx*2 .. Min((wmx+1)*2, mapwidth-1) do
      if (gMapMask[x,y].b>0) and ((gMapMask[x,y].r<1) or (gMapMask[x,y].b<1)) then
        bWaterMap[wmx,wmy] := True; break(CELL);
  WaterFieldsClear;
  const cOffsetY = -0.5;
  var mapsizemod : Float =
      (cWaterMapArrSize/((640/mapheight)*2))*cWaterFieldSize;   // float division live; integer variant commented
  for each true bWaterMap[wmx,wmy]:
    tx = wmx*2 - mapsizemod;   tz = wmy*2 - mapsizemod;
    bx = (wmx+1)*2 - mapsizemod; bz = (wmy+1)*2 - mapsizemod;
    WaterFieldAdd('x'+IntToStr(wmx)+'y'+IntToStr(wmy), tx,tz,bx,bz, cOffsetY);
```
`[D]` Gate is **per 2×2 block**: any masked-blue cell that is not the pure-white start (`r<1 or b<1`) marks the whole block. The neighbour-fill expansion immediately after is `{…}`-commented → inert. `mapsizemod` centres the 320×320 raster at the origin; with `mapheight=640` it is `(320/((640/640)*2))*2 = 320`, so coordinates run `−320..+320`. Field name is exactly `x<wmx>y<wmy>`.

### 7.2 Native `WaterFieldAdd` (`FUN_00603d30`, disassembly + pseudo) `[O]/[D]`

```
push ebp; mov ebp,esp; push ebx
call FUN_00705944                       // global manager
cmp dword [eax+0x4c],0 ; je → return -1
call FUN_00705944
mov eax,[eax+0x4c]; mov eax,[eax+0x5c]; mov eax,[eax+0x24]
call FUN_0073b8e4                       // construct field object → ebx
lea eax,[ebx+0xa0]; mov edx,[ebp+8]; call FUN_00405454   // name
push [ebp+0xc]; push [ebp+0x10]; push [ebp+0x14]; push [ebp+0x18]
mov eax,ebx; call FUN_0073b57c          // (tx,tz,bx,bz)
push [ebp+0x1c]; mov eax,ebx; call FUN_0073ab50   // offsety
call FUN_00705944; … call FUN_0073b8dc; dec eax    // return index-1
ret 0x18
```
`FUN_0073b57c` (exact):
```
*(float*)(field+0xa8) = ABS(bz - tz);        // depth/extent along script z
*(float*)(field+0xa4) = ABS(bx - tx);        // width/extent along script x
FUN_00890d34(field+0x44, 0, ?, (tz+bz)*0.5f);  // vector index 0 = X
FUN_00890d34(field+0x44, 2, ?, (tx+bx)*0.5f);  // vector index 2 = Z
```
`DAT_0073b5e4 = 0x3f000000 = 0.5f` (bytes `00 00 00 3f` at 0x73b5e4). `FUN_00890d34(obj,i,?,v)` writes `obj[7+i]=v` (i.e. X at +0x1c, Y at +0x20, Z at +0x24) then calls virtual `+0x10`. `FUN_0073ab50`: `if (offsety != *(float*)(vec+0x20)) FUN_00890d34(vec,1,vec,offsety)` → **plane Y = offsety exactly**.

`FUN_0073ab88` (constructor, `ev_…`/P7) allocates the field, default name `WaterField%d`, defaults `+0xa8=1.0`, `+0xa4=1.0`.

`[D]` **Plane geometry contract**: one flat 4-corner field per `bWaterMap[wmx,wmy]`, centred at
```
worldX = (tz + bz)*0.5      // script z maps to engine X
worldZ = (tx + bx)*0.5      // script x maps to engine Z
worldY = cOffsetY = -0.5
extentZ (field+0xa8) = |bz-tz| = 2
extentX (field+0xa4) = |bx-tx| = 2
```
so each field is a **2×2 world-unit quad at Y=−0.5**, centred on the 2×2 cell block. The x/z swap is a recovered engine convention, not a guess.

### 7.3 Draw path (`FUN_00826b30`, full disassembly) `[O]/[D]`

```
glMatrixMode(0x1700=GL_PROJECTION); glPushMatrix();
glLoadMatrixf([caller+0]+0x50+0x68);
FUN_008520a8(shaderCtx, field, caller);        // stages uniforms/colour state
if !(shaderActive && secondShaderFlag): glColor4f(1,1,1,1);
glBegin(4);                                    // GL_TRIANGLES
for each mesh group … (**(vtable+0x98))(group, caller, 1, 1);   // draw 2 triangles
glEnd(); FUN_0085224c(...); glPopMatrix();
```
`[D]` Water is drawn as explicit GL_TRIANGLES with **uniform vertex colour (1,1,1,1)** when no custom shader path is active; therefore `alphaDepth=gl_Color.r=1` in the embedded vertex shader — the donor does **not** get depth-varying alpha from this path. `FUN_008520a8` stages `+0x174 = field+0xa4` (field width) into the shader context and gates height-map/shadow texture units on `water.lib` `HeightMapEnable` (`+0xb9`) / `ShadowMapEnable` (`+0xc0`). Per-vertex quad layout/UVs inside the mesh template created by `FUN_00545e0c` remain `[U]` (§11 U6) — do not invent them.

---

## 8. Shore collision tags and radius-3 border discs `[O]` (verbatim scripts, runtime `[U]`)

`dmscript.global:82-91`: `gc_collisiontag_none=0`, `bridge=10`, `building=80`, `terrain=101`, `water=87`, `waterborder=110`, `landborder=109`, `stretchland=85`, `wall=95`; `:819` `gc_WaterBorderSize=3`.

`misc.script:5174-5211` `_misc_SetShoresCollisionInArea(minX,minY,maxX,maxY)` (verbatim algorithm):
1. Sample collision at **half-cell resolution**: `for i:=0..2*w-1, j:=0..2*h-1`, `x=(i-w)/2`, `y=(j-h)/2`.
2. If `GetMapCollisionTag(x,y,false) = 87` (water), scan the 3×3 half-cell neighbourhood `i1,j1 ∈ {−1,0,1}` at `(x+i1/2, y+j1/2)`; if any in-bounds neighbour has tag **0 or 10 (bridge)**, set `border := true`.
3. For `rad = gc_WaterBorderSize = 3`, sweep `i1 := −3..3`; `minJ := MathCeil(Sqrt(9−i1*i1))`; `j1 := −minJ..minJ`; **keep only if `i1*i1 + j1*j1 < 9`** (strict — the boundary circle itself is excluded) and in bounds. Then:
   - `tag=0 → MapDrawCollision(x+i1/2, y+j1/2, gc_collisiontag_landborder=109, 0, false)`
   - `tag=87 → MapDrawCollision(..., gc_collisiontag_waterborder=110, 0, false)`
4. `_misc_SetShoresCollision` calls the above over `(0,0,2*w−1,2*h−1)`.

`texturemap.inc:463-472`: a cell is tagged/painted only when `gMapMask[ix,iy].b>0 ∧ (height<−0.25 → bWater ∨ height<−0.1 → bWaterShore)`. `[D]` Wet-shore classification band width = `0.15` height units — classification only, **not** plane Y.

`misc.script:5271-5346` `_misc_CreateBridge`: `cScale=1.15`, `cBaseHeightOffset=0.4876`, block `2.81*scale`, ends `1.78*scale`, offsets `1.07*scale`, `cCollisionRad=3`, `cCollisionStep=2`; collision loop `MapDrawCollision(colX,colZ, gc_collisiontag_bridge=10, 3, true)` for `colCount=ceil(dist/2)+1` steps; then `_misc_SetShoresCollisionInArea(minX,minY,maxX,maxY)` with `2.5*startWidth` padding and `_misc_BaseTopologyUpdate`. `[D]` Bridges are spawned objects + collision overlay, not terrain tiles; `fordtyp` is a squad formation field, not a ford (D06 §8.2). Native `MapDrawCollision` kernel was **not** decompiled (P18) → exact radius/shape semantics of the C++ call are `[U]` (§11 U11); the script above is authoritative for tag values and the strict disc.

---

## 9. Alpha / crossfade semantics `[O]/[D]`

1. **Shipped `.dev` water**: `ALPHA = coastfade2 = clamp((level−height)/1.07, 0, 1)`. At the shoreline alpha→0 (bed visible); at depth ≥1.07 alpha→1. Nothing else modulates water alpha. No alpha floor, no `water_cell` gate, no `shore_prox` in the donor fragment.
2. **Embedded built-in water**: `gl_FragColor.a = alphaDepth = gl_Color.r`; draw callback issues `glColor4f(1,1,1,1)` unless a shader path is active (§7.3) ⇒ **opaque** in the common path.
3. **Legacy `water.frag`**: final `vec4(col, 1.0)` — opaque, and keeps the raw hmap texel on dry pixels (the grey-fallback mechanism).
4. **Shore tiles**: `sandsea1/5/6` use `reftile.mat` `normal` refkey: `Texture2Name=alpha`, `bmTransparency`, `maNearest/miNearestMipmapLinear` (DEC_SMALL §3, DEC_SHORE_EDGE §1). `alpha.bmp` is a 512×256 8-bpp patch atlas of 8×4 64² patches; the RGB comes from ground UV `sandseaN.dds`, the alpha patch is a coverage weight for `bmTransparency`, **not** an albedo multiplier. Exact GL blend factors/pass count are `[U]` (§11 U12).
5. `[D]` **No grey fallback is donor behaviour**: grey blobs in the port = a substituted/broken binding (unbound `hmapTex` showing its texel, or near-black embedded shader with no reflection target), not a donor look. A 1:1 port must *fail visibly or not draw water* when a required binding is missing — never substitute a neutral texture and render a grey quad.

---

## 10. Exact Godot implementation plan (no grey fallback, no invented constants)

Rules: (a) every literal below is donor-cited in §§2-9; (b) any `[U]` value is exposed as a **named, explicitly-labelled runtime parameter with no hidden default** — if the integrating owner cannot supply it, water must not be drawn rather than drawn grey; (c) the three shader paths are mutually exclusive and selected by an **explicit** `water_shader_path` enum (`DEV` / `BUILTIN` / `LEGACY`) whose runtime selection is `[U]` until U1 is settled; (d) no `PORT APPROXIMATION` placeholder may be presented as donor truth.

1. **Descriptors (data layer).** Define a `WaterLayer` resource mirroring §3.3 offsets/values exactly: `DeepColor=(0,0,0.1255,0.5)`, `ShallowColor=(0,0,0,0.5)`, `TexScaleS=0.1`, `TexScaleT=0.01`, `WaveDir0=(-1,0)`, `WaveDir1=(-0.7,0.7)`, `WaveFreq=WaveAmp=0`, all amounts/Fresnel/HDR/dist/bump = 1, `Offset=0.495`, `HeightMapEnable=true`, `ShadowMapEnable=true`, shader filenames = `water.dev.vert/frag`. A second resource mirrors §3.1 file keys (`Tag=512`, `DefaultWaterIndex=0`). Do **not** treat `Offset=0.495` as plane Y.
2. **Uniform-key table (30 rows).** Use §4.3 verbatim: key string, `wst*` label, `f*` config key, enable bit. Implement the enable mask as a real 32-bit flag field defaulting to `0x3FFFFFFF`; bind only enabled keys. For `hmapTex/hmapW/hmapH` bind only when a real height object exists; for `shadow*` only when a real shadow object exists; for `fogEnabled` compute from the capability flag exactly as `FUN_00854054`. Any key that cannot be bound must raise an error and disable the water draw — **no neutral 1×1 texture**.
3. **Shader (`DEV` path).** Port `water.dev.vert` → Godot vertex: `UV` for `gl_TexCoord[1].xy` via `MultiTexCoord0/(hmapW,hmapH)−0.5`; pass `plane_y = VERTEX.y` as a flat varying (this is `gl_TexCoord[1].z`, the donor's `WATER_LEVEL`); pass `eyeVector`, `lightVector` from `light.cfg:26-29` through the donor's `(x/4, z/2, y)` remap, and `fogFragCoord`. Port `water.dev.frag` fragment exactly: `height = hmapMin + texture(hmapTex, hmapUV).a*(hmapMax−hmapMin)`; `waveheight = clamp(plane_y*3−1.5,0,1)`; `level = plane_y + 0.2*water_map(hmapUV*15 + time*0.1, waveheight)`; **`if (height > level) discard;`** (never sample a fallback texel); 4-tap `waveMap` normal with z=0.15; `coastfade=clamp((level−height)/0.57,0,1)`, `coastfade2=clamp((level−height)/1.07,0,1)`; `mix(watercolor*luma, watercolor2, smoothstep(0,1,coastfade2))`; projected reflection; exponents 170/120 and the exact corona divides; foam `watershade*coastfade*(1−coastfade2)*(vec3(.5,.6,.7)*nautic + particles)`; `ALBEDO=mix(bed,watercolor,coastfade)`, `ALPHA=coastfade2`. Constants exactly §5.1. Do not add Fresnel/current/alpha-floor/water_cell guards.
4. **Shader (`BUILTIN` path).** Separate shader with §5.3 verbatim embedded equations: 2-wave displacement with `phase=0.5/1.7`, `angle=dot(dir,P.xz)*freq+time*phase`; `t=normalize(t0+t1−vec3(1,1,0))`; `facing=1+eyeVector.y*(distFactor/|eyeVector|)*(0.1−t.y*bumpFactor)`; `fresnel=clamp(fresnelBias+pow(facing,fresnelPower),0,1)`; `waterColor=mix(shallowColor,deepColor,facing)*waterAmount`; `refcol.rgb*=(r+g+b)*hdrMultiplier`; `refcol=mix(waterColor,refcol,fresnel)*reflectionAmount`; final `ALBEDO=waterColor+refcol`, `ALPHA=vertex color r` (set vertex colour to (1,1,1,1)). This path must reject a missing reflection target (error, no draw).
5. **Shader (`LEGACY` path).** Only if explicitly selected: port the §5.2 discard `if (plane_y > height) else keep hmap texel` and opaque alpha. Never substitute a neutral texel here — that is precisely the grey bug.
6. **Field raster.** Generate the 2×2 block array exactly per §7.1: 320×320, gate `mask.b>0 ∧ (mask.r<1 ∨ mask.b<1)`, `mapsizemod=(320/((640/mapH)*2))*2`, name `x{wmx}y{wmy}`, `cOffsetY=−0.5`. Clear old fields first. Do not generate one quad per terrain cell; do not expand neighbours (commented in donor).
7. **Plane geometry.** One flat 4-vertex / 2-triangle quad per field, centred `( (tz+bz)*0.5, −0.5, (tx+bx)*0.5 )`, extents `2×2`, with the donor's x/z swap (§7.2). UVs must be the donor `hmapUV = MultiTexCoord0/(hmapW,hmapH)−0.5` space; until U3/U6 are settled, expose `hmapW/hmapH` as required parameters (no `map_size/128` guess, no `±2.96` guess, no `fract(world*0.5)` substitute).
8. **Terrain/shore seam.** Keep height basin `hwater=−1.1*fb*(1+3.5*fr)` and the exact S0/S1/S2 smoothing chain from DEC_LANDSCAPE §3-§4; paint `sandsea1/5/6` by the exact 8×45° table on `mask.b>0 ∧ (h<−0.25 ∨ h<−0.1)`; use `0.7/0.3` smoothing weights and `rock9=0`; keep the cliff 6-branch table separate (D06 §7.2). Do not recolour submerged terrain grey — donor ground shows through `coastfade`.
9. **Collision.** Tags 0/10/87/109/110 exactly per §8; half-cell sampling; strict disc `i1²+j1²<9` with `rad=3`; `_misc_SetShoresCollisionInArea` semantics. Native `MapDrawCollision` kernel stays `[U]` until U11; keep the script as the only source of truth.
10. **Failure behaviour (mandatory).** Missing shader file → hard error, no water node. Missing `waveMap`/`hmapTex`/height object → hard error, no water node. No 1×1 neutral texture, no `#6E99A8` colour from the unselected legacy shader, no grey terrain under water, no "looks close" tuning. `visual_parity_claim=false` in telemetry.
11. **Verification (structural only, no parity claim).** Static assertions: field count equals `bWaterMap` true count; plane Y = −0.5 for every field; alpha at `d=0` = 0 and at `d≥1.07` = 1; foam peak depth 0.535; `waveheight=0` at Y=−0.5; enable mask = 0x3FFFFFFF; tag/disc constants exact. A visual A/B requires an owner-authorised donor GPU frame (U13), which this worker did not capture.

---

## 11. `[U]` register — every unresolved item and the exact experiment that settles it

| # | `[U]` item | What is known | Exact settling experiment (no approximation) |
|---|---|---|---|
| U1 | Which shader pair/path is live in retail (`DEV` vs `BUILTIN` vs `LEGACY`), and the `CustomEnable`/shader-active flags | All three sources recovered verbatim; `water.lib` pins `.dev`; embedded pair compiled by `FUN_00855b38`; shader-enabled branch in `FUN_00856530` | Debugger on `glShaderSource`/`glCompileShader`: record the source string and whether it contains `hmapTex` (DEV) or `alphaDepth` (BUILTIN). Break on `FUN_00855b38` and on `FUN_0085600c`; read shader+0x184/+0x50 and `water.lib` descriptor +0x90 (`CustomEnable`). GPU frame capture confirms the program actually drawn for a water field. |
| U2 | Concrete RTTI class owning the 30-key descriptor; `fXWaterField` vs `XWater` roles | RTTI strings only, no code xref | Deep Ghidra: recover the vtable at shader object address, walk RTTI `typeinfo` pointers, and xref `FUN_00853ebc`; or at runtime break on `FUN_00853ebc`, inspect the object's vtable and class name. |
| U3 | Runtime `hmapMin/hmapMax/hmapW/hmapH` and the actual texture/FBO bound to `hmapTex` | Binder source fields (C+0xdc/+0xd0/+0xd4) and gating on C+0xe0 proven; `heightmapwaves0.tga` disproved | Break on `FUN_00854054` bit 20–24; read the four bound values and `glActiveTexture`/`glBindTexture` calls at that unit. GPU frame capture with a water field visible shows the exact sampler. Do **not** substitute `±2.96`, `map_size/128`, or a 1×1 texture. |
| U4 | Numeric per-frame values of `deepColor/shallowColor` and all scalar uniforms bound by `FUN_004c0f90` | water.lib defaults + shader-object defaults recovered; pointer sources for deep/shallow recovered | Hook `glUniform4fv/glUniform1f` on the program from U1, record values on the first water draw; correlate with water.lib descriptor +0x18/+0x28. |
| U5 | Whether `time` (bit 2) is actually animated/scalar source | Bind mode `K(P,key)` proven; mask enables it | Break on `FUN_00854054` bit2, then sample the `time` uniform across two frames; if constant, identify the writer via a write-watchpoint on the uniform location. |
| U6 | Water field mesh vertex layout / UVs / triangle winding created via `FUN_00545e0c` | Field centre/extent/Y and `glBegin(4)` proven; template not decompiled | Break on the virtual `+0x98` draw callback in `FUN_00826b30` and dump the bound vertex/UV attribute arrays for one field; or Deep-decompile the mesh builder reached from `FUN_00545e0c` (`FUN_00545d64`/`FUN_00545bd8`) with full `study` + `pseudocode` (passes 3–5 still available). |
| U7 | Runtime plane Y actually delivered (does retail call `WaterFieldAdd(...,−0.5)`?) | Script literal −0.5 is the only donor number; native `FUN_0073ab50` writes offsety verbatim | Break on `FUN_00603d30` entry, read `[ebp+0x1c]`; then read field+0x20. Cross-check scenario `.map` files for a different override. |
| U8 | Runtime execution of `;`-prefixed GSC blocks (`generatemap.inc`, `texturemap.inc`, `misc.script`) | Text is `[O]`, execution `[U]` | DScript VM trace: breakpoint on the registered `WaterFieldAdd`/`MapDrawCollision` thunks and confirm the call sequence during skirmish map generation. |
| U9 | `TileSmoothPasses=6` (config) vs `SmoothTileMap(...,3)` (script) | Both literals re-read; no readable consumer of config key | Break on `SmoothTileMap` during generation and count loop iterations; search compiled code for a reference to the config key string `TileSmoothPasses`. |
| U10 | `bmTransparency` GL blend factors and pass count for shore tiles | Enum index 1 in binary; factors inferred in prior reports | GPU frame capture / `glBlendFunc` hook on the shore-tile draw; record src/dst factors and number of passes. |
| U11 | Native `MapDrawCollision` kernel (radius/shape semantics) | Only registration string at 0x687fca; script semantics recovered | Deep-decompile the function pointer in the DScript registration record adjacent to 0x687fca (same `b9 <ptr> ba <name>` pattern as P5), then verify by breakpoint on actual collision painting. |
| U12 | `reflectionMap` FBO provenance and GPU sampler units; whether `DiffuseWaves2` is uploaded | Binder units recovered; provenance not | GPU capture at the water draw; record the framebuffer object bound to the reflection sampler and the uploaded texture names. |
| U13 | Donor visual parity / metres-per-cell | No donor GPU frame exists; depth-space numbers exact | Owner-authorised fixed-camera donor frame + port frame, same map/camera, compare ROIs. This worker is forbidden to capture/execute the donor. |
| U14 | `FogMode` → `fogEnabled` int mapping | Default 0 observed; computed capability path recovered in binder | Break on `FUN_00854054` bit 19 with each palette `FogMode` value and record the bound integer. |
| U15 | `FUN_00898004`/`fWaterStates` `wst*` table semantics at runtime | Static table pointer @0x8fabb0 | Dump the table at runtime and confirm each `wst*` label maps to the same-index plain key used by `FUN_00854054`. |
| U16 | editor.exe vs cossacks.exe shader divergence | editor has `deepColor` but no `hmapTex` shader text | Read the editor's embedded VP/FP C literals (analogous `FUN_00854ac0` equivalents at the `deepColor` hits 0x9d0ac4 etc.) and diff against §5.3; confirms target-specific pair. |

---

## 12. Explicit non-claims and file discipline

- **No parity claim.** No donor binary was executed, no donor asset copied, no GPU frame captured, no port capture compared. All visual readings are structural `[I]`.
- **No approximation substituted.** Where the port currently uses `water_surface_y=-0.25`, `max_height=2.96`, `map_size/128`, a 1×1 neutral `height_tex`, a `water_cell` alpha gate, or legacy-shader blue `#6E99A8`, this spec marks them as prohibited placeholders and requires either the recovered donor value or an explicit `[U]` experiment.
- **Read-only compliance.** Exactly one file written (`docs/terrain_swarm_2026-11-26/reports/PORT1TO1_water_shore.md`). No code/asset/config/Godot/git change. Craft Anything active target remained `t_87f0f3c130b0` for every pinned call; `t_68474ddde43f` was probed only with read-only `path=` byte searches.

*End of PORT1TO1-WATER report.*
