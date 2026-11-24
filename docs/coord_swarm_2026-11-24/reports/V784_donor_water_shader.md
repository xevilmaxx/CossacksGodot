---
id: V7-84
title: "Donor-grounded 3D water surface: water3d.gd + water3d.gdshader"
scope: "Self-contained Node3D water plane + Godot spatial ShaderMaterial translating the shipped donor water.dev.frag; read-only donor audit folded in (DEEPDEC-03)."
date: 2026-11-24
status: DELIVERED__PARSE_AND_PROBE_PASS__NO_VISUAL_PARITY_CLAIM
owner: V7-84
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
donor: "C:\\Games\\Cossacks 3 (READ-ONLY, private use); no donor binary run/unpacked/copied"
files_owned:
  - "variant3d/scripts/water3d.gd"
  - "variant3d/shaders/water3d.gdshader"
  - "docs/coord_swarm_2026-11-24/reports/V784_donor_water_shader.md"
godot_runs: "variant3d runner only: tickets 216,217,220,222,224 (see §7). Full gate NOT run (coordinator owns it)."
probe: "Temporary variant3d/tests/_v784_probe.gd created, run, and DELETED (10/10 PASS)."
---

# V7-84 — Donor water equations on the 3D flat water plane

## 0. Guards

- Owned **only** the two new source files plus this report. No edit to `world3d_terrain.gd` (V7-82 owns a filter line), no other module/app/config/test/git change. No donor binary executed, unpacked or copied into the repo.
- `variant3d/assets/terrain/water_png/diffusewaves0.png` **already exists** (256², shipped, `.import` sidecar present). It is bound as the wave sampler. No donor `.bmp` was copied by this agent.
- **No visual parity is claimed.** No GPU A/B capture was taken. The shader is a structural port of readable donor equations, not a proven pixel match.

## 1. Donor / DECOMP evidence

Direct read-only donor reads this session (all `C:\Games\Cossacks 3\...`):

| File:lines | Establishes |
|---|---|
| `data\shaders\water\water.dev.frag:1-48,65-75,77-83,85-104,106-127,129-160,162-235,237-262` | Full shipped fragment: uniforms, constants, all helper functions, step order, fog |
| `data\water\water.lib:25,32-33,42-45,60-61,67-68` | `HDRMultiplier=1`, `TexScaleS=0.1`, `TexScaleT=0.01`, active `DiffuseWaves0`, shipped `water.dev.vert/.frag` pair, `HeightMapEnable/ShadowMapEnable=True` |
| `data\scripts\common.inc\texturemap.inc:29-31` | `cMaxHeight=2.96`, `cWaterHeight=-0.25`, `cWaterShoreHeight=-0.1` (commented script lines) |

Prior evidence reports (cited, not re-derived here):

- **TERRAIN2-03** (`docs/coord_swarm_2026-11-24/reports/TERRAIN2_03_water_weather.md`): D1-D3, D5-D16, D19, P1, P5-P6 — flat plane (`water.dev.vert:14-18,29`), fragment-stage detail, only `diffusewaves0` bound, `heightmapwaves0` not bound, shoreline as height contour, UNV-1/2/4.
- **TERRAIN2-01** (`.../TERRAIN2_01_donor_pipeline.md`): E24 (`texturemap.inc:29-31`), E55-E60 (water.lib / water.mat), E57-E59 (water fragment), E61 (2×2 water fields), §2.4 (many height-aware fields, not one quad), §5/UNVERIFIED #5-6.
- **DECOMP-04** (`.../DECOMP_04_strings_config.md` §8.1/§8.2, evidence `ev_190898349c86f8d90a49007c79d2e593cc6278658a16928cb0c9371ae0dc6846`, `ev_cf7b42dd86b0261abebcacb0ea646d12092da5b46c61dd33f6e9be552c3a11fb`, `ev_9c4ff7ba1fa969cabab05fcedebdae7056860c44b7455c340e7e639b55516b1d`, `ev_20196da6116c175f32b10c36cd5bc357788189fce04cdd886010608eae86bd68`): `hmapTex` string at `0x853e0c` is assigned by `0x853bde mov edx,0x853e0c` → `call 0x405454` (Delphi ref-counted string store). **Only string assignment is proven; no texture lookup or shader binding.**
- **DEEPDEC-03** (`.../DEEPDEC_03_water.md`, folded in §6 below): full fragment algorithm + PROVEN external-config defaults + binary caution. Evidence ids used: `ev_b284c02cf7c0727264d5d59d4ed3f2399566c0b1fb505da77f4852ab50fd3cc2` (frag), `ev_6fcb07113a5beb30f35b8f11334e23cb2c84fe8b5020ef16f97cd91b6d9d27ff` (water.lib), `ev_b25d35234d67c04a37050632ab684047e8a7358b465cf4e7aa2d0d9d36e03875` (water.mat), `ev_f27e2eed4f54a212363908e10dc40e960d04dcd7a22b10e36188c1dc6487758c` (texturemap.inc), `ev_ac75afae1baf334ae7010dbe246fd8344a3050b96b93b3317767632874d45788` (generatemap.inc), `ev_9918481e1585dc4c793328d7d2e5f2aaff883ff0c5397ca6c1eab5b195961a43` / `ev_1dfd1d6721390812a596d17e230155795f7c68c4a28c6a9beec1ace391af6c61` (key block), `ev_03eb161c90d6962781179abd247668f28b08f324e69e7a837b6dbd22c0ddb988` / `ev_d94dda9482a38c5a0aa3322f1eb7ffddc2f812530d8886205613ad9b23d21319` / `ev_4b10476458214c3feabc03d84ef5a2a3ad5a54f3d227e8f2bf252e9a91ee97c2` / `ev_d77442d03ae851db4276aaa2a623d27200eb02f0b39086f3dad8c5d4e1905222` (bitmask), `ev_877b1928ae1f6e5ec7fe1598ad5130ea1ffce2a267dcee1af3e31cf40da83e24` et al (absent float literals), `ev_389db76cda71cc69f3dccacd72054a6ba7ca088763471f0ead7dac8bf5c51700` (f* name table).

## 2. What was built

`variant3d/scripts/water3d.gd` (Node3D, tabs, no `class_name`) builds a `MeshInstance3D` named `WaterPlane3D` with the **existing 4-vertex plane geometry verbatim** from `world3d_terrain.gd:175-192` (two triangles, indices `[0,3,1,1,3,2]`, UV 0..1, Y = `WATER_LEVEL`) and assigns a `ShaderMaterial` using `res://shaders/water3d.gdshader`. `_process` advances the donor `time` uniform. The material exposes all donor literals as shader parameters; the probe asserts `-0.25`, `-0.1`, `2.96` read back exactly.

`variant3d/shaders/water3d.gdshader`: `shader_type spatial; render_mode blend_mix, cull_disabled, unshaded;`. `unshaded` is a **port choice** — the donor fragment assembles a final colour itself, so Godot lighting must not re-shade `ALBEDO`.

## 3. Shader translation ledger — donor vs port approximation

| Donor equation / feature | `water.dev.frag` lines | Status in `water3d.gdshader` |
|---|---|---|
| `noise(p)=texture2D(waveMap,p/256).x`; one 256² luminance sheet | 5,65-68 | **DONOR** structure/constant; `texture(...,fract(p/256)).r` (Godot syntax, repeat). `wave_noise = diffusewaves0.png`, already shipped, 256² |
| `height_map(p)=hmapMin+tex.w*(hmapMax-hmapMin)` | 18-21,70-75,170 | **DONOR structure**; `.a` read (donor `.w`). Values `hmapMin=-max_height`, `hmapMax=+max_height` are **PORT APPROXIMATION** from `texturemap.inc:29` (2.96) + `generatemap.inc:7` (−2.964); binary `hmapMin/Max` defaults UNVERIFIED |
| `WATER_LEVEL=gl_TexCoord[1].z`; `deepwater_fadedepth=0.5+0.57=1.07`; `waveheight=clamp(WATER_LEVEL*3-1.5,0,1)`; `level=WATER_LEVEL+0.2*water_map(...)` | 167-175 | **DONOR VERBATIM** (uniform substitutes the vertex varying). With `-0.25`, `waveheight=0` — a donor-faithful consequence; the 2D app's `water_level=1.0` port choice is **not** copied |
| Land discard `if height>level` → `vec4(0)` | 176-183 | **DONOR** (`discard` is the Godot equivalent) |
| 4-tap `water_map` finite-difference normal, `normwater=normalize(vec3(h3-h4,h1-h2,0.15))`, `wavejitter=normwater.xy*texScaleT*(level-height)`, `uv+=wavejitter` | 186-194 | **DONOR VERBATIM**, including `dif=(0,0.01)`, `pos=uv*15/texScaleS*(map_size.x/128)+time*0.01` where `map_size.x` is a **PORT SUBSTITUTE** for engine-bound `hmapW` (DEEPDEC-03 §6.4) |
| `terrain_map(p)=vec3(0.175,0.1375,0.1)+texture(waveMap,p*8).rgb*0.25` | 77-81 | **DONOR VERBATIM** colour. `CalcTerrain`'s 4 height taps, `col*=grad+grad^8` and 3-tap PCF shadow (129-160,196) are **OMITTED (PORT APPROXIMATION)** — sampler/FBO bindings UNVERIFIED |
| `coastfade=(level-height)/0.57`, `coastfade2=(level-height)/1.07`, intensity luma weights, `mix(watercolor*intensity, watercolor2, smoothstep(0,1,coastfade2))` | 198-201 | **DONOR VERBATIM** (shader-local `watercolor=(0.1,0.24,0.24)`, `watercolor2=(0,0.025,0.05)`, `:45-46`) |
| Projected reflection `refcol*= (R+G+B)*hdrMultiplier; watercolor+=refcol` | 203-213 | **Equation DONOR, mechanism PORT APPROXIMATION**: `SCREEN_UV` replaces the projective texture coord; `reflection_enabled=0` by default; FBO binding UNVERIFIED. Fresnel block (203-206) is **commented in the donor and not wired** |
| `rd=normalize(light-r0)`, `grad=dot(normwater,rd)`, `pow(grad,170/120)`, `specular1=smoothstep(0,1,pow(gradpos,5))`, `/=1+specular1*1.25`, `+= watershade*specular2*spec_color` | 215-226 | **DONOR VERBATIM** structure/constants. `max(grad,0)`/`max(gradpos,0)` are **PORT GUARDS** for `pow()` domain. `watershade=1.0` is the donor's own unshadowed branch (`test_shadow` returns 1 when `shadowed!=1`, :129-143) |
| Foam `watershade*coastfade*(1-coastfade2)*((0.5,0.6,0.7)*nautic(uv)+(1,1,1)*particles(uv))` | 106-127,227 | `nautic()`/`particles()` **DONOR VERBATIM** (incl. scalar `time*s` broadcast, `p*=18/200`, `m*p*1.2`, `pow(1-f,5)`, `pow(f*0.35,7)*30`). Extra `shore_prox` multiplier from `shore_height` is **PORT ART** (donor fragment never reads that literal) |
| `rescolor=mix(rescolor,watercolor,coastfade)`; `resalpha=coastfade2` | 229-232 | **DONOR VERBATIM**: alpha 0 at waterline, 1 at 1.07 m |
| `fogmap()` EXP/EXP2 `exp2(-density*w*1.442695)`, `exp2(-pow(density*w,2)*1.442695)` | 237-253 | **DONOR VERBATIM math** for modes 2/3, gated `fog_enabled=0` (`colors.lib:36` FogMode=0). `v_fog_depth` is a **PORT SUBSTITUTE** for donor view-space `fogFragCoord`; mode 1 LINEAR **not ported** (needs `gl_Fog.end/scale`) |

Donor constants fed from `water3d.gd` (all observed): `-0.25`/`-0.1`/`2.96` (`texturemap.inc:29-31`), `0.57`/`1.07` (`:37,:168`), `170`/`120`/`30` (`:42-44`), colours `:45-47`, `TexScaleS/T=0.1/0.01` (`water.lib:32-33`), `HDRMultiplier=1` (`water.lib:25`), `fogEnabled` int (`frag:23`), sun vector from `light.cfg:26-29` → `water.dev.vert:22` → Y-up (as in `world3d_terrain.gd:57-58`).

## 4. Wave / height textures

- `wave_noise` ← `res://assets/terrain/water_png/diffusewaves0.png` — **donor-derived and already shipped** (`water.mat:7,11`: `diffusewaves0.bmp`, `tfLuminance`, 256²; `water.lib:44`). If the file were missing the code falls back to a 1×1 neutral texture and labels it `UNVERIFIED`; the fallback did **not** trigger in verification.
- `height_tex` ← neutral 1×1 alpha=0 `ImageTexture` by default (decodes to `hmapMin`, full coverage). `bind_height_grid()` can replace it with an `ImageTexture` built from the port `height[]` grid, alpha channel carrying normalised height so `height_map()` reads `.a` as the donor reads `.w`. This is a **PORT SUBSTITUTE for the UNVERIFIED `hmapTex` engine binding**, not a donor asset.
- `heightmapwaves0.tga`, `diffusewaves1/2/3-7` are **not bound** (`water.mat:26,35-41,86-106` commented / no matching sampler; TERRAIN2-03 §2.1, DEEPDEC-03 §5). No foam texture exists in the donor — foam is procedural (`nautic`/`particles`) as implemented.

## 5. Integration hook for `world3d_terrain.gd` (NOT wired by this agent)

`world3d_terrain.gd` is owned by V7-82, so this module cannot edit it. To make coverage donor-style height-aware, the integrating agent must, after `world3d_terrain.gd:346 _make_water(w, h)`:

1. Build this node with the same grid dims: `water3d.build(w, h)`.
2. Feed the decoded `height[]` grid: `water3d.bind_height_grid(height, w, h)`.
3. Replace (not stack with) the existing `WaterPlane` quad at `world3d_terrain.gd:175-202`, so only one water surface is submitted.

Until then the neutral height texture keeps full coverage, preserving current port behaviour. If only the material is swapped onto the existing quad, the height-aware `discard`/shore fade will not engage until step 2 is done.

## 6. Correction / fold-in — DEEPDEC-03 (new evidence, applied)

DEEPDEC-03 landed after this module's first draft. The following corrections were applied to **both** owned source files and this report (no second report created):

1. **PROVEN `water.lib` defaults recorded, deliberately not wired.** `DONOR_WATER_LIB_PROVEN` in `water3d.gd` stores `MaxDepth=1, MinDepth=0, MaxAlpha=1.1, MinAlpha=0`, `DeepColor=(0,0,0.1255,0.5)`, `ShallowColor=(0,0,0,0.5)`, `ReflectionAmount=1, WaterAmount=1, FresnelPower/Bias=1, WaveFreq/Amp=0, DistFactor/BumpFactor=1`, `WaveDir0=(-1,0)`, `WaveDir1=(-0.7,0.7)`, `Speed=1.0`, `Offset=0.495`, `LayerCount=1`, `CustomTexCoord=True`, `HeightMapEnable/ShadowMapEnable=True` (DEEPDEC-03 §6.2, `ev_6fcb0711…`). These are exposed in `stats` as an audit trail. The shader does **not** wire `deepColor/shallowColor/reflectionAmount/waterAmount/fresnelPower/fresnelBias/distFactor/bumpFactor`: DEEPDEC-03 §4.1/§6.1 proves they are **commented out** in the shipped fragment (`water.dev.frag:8-16`), and §4.3 step 8 proves the Fresnel block (`:203-206`) is commented. Wiring them would invent donor behaviour. The live keys — `hdrMultiplier`, `texScaleS/T`, `fogEnabled` — were already wired before this correction.
2. **Binary caution adopted.** The `0x853ad4` block is 30 **string-key assignments**, not numeric defaults (`ev_9918481e…`, `ev_1dfd1d67…`). The sole static number, f32 `1.9999998807907104` at `0x853eb8` (`ev_03eb161c…`), is stored to `+0x7C` (`ev_d94dda94…`) and tested as bits `1`/`0x40` (`ev_4b104764…`, `ev_d77442d0…`) — an all-keys-enable **bitmask**, **not** a shader float. `BINARY_CAUTION` records this in code and `stats`. No numeric descriptor default is provable in `cossacks.exe` (DEEPDEC-03 §2.3; absent 0.495/0.57/2.96/−0.1 float patterns).
3. **Distinct constants kept separate.** `texturemap.inc:29-31` −0.25/−0.1/2.96 are the values fed to the shader; `generatemap.inc:5-7` −1.1/2.964/−2.964 are generation-basin constants and are **not** used as water-plane literals. The ±`max_height` decode range is labelled a port approximation derived from the texturemap/ravine pair, not a recovered binary default.
4. **Step-order confirmation.** DEEPDEC-03 §4.2-§4.4 confirms the exact order implemented in §3 above (hmap decode → WATER_LEVEL/waveheight/level → land discard → 4-tap normals/jitter → CalcTerrain → coastfades → reflection → specular/corona/foam → composite/alpha → fog). `waveheight=0` under the donor −0.25 literal is explicitly recorded in `stats["waveheight_from_donor_literal"]`.
5. **Omission made explicit in code comments.** `CalcTerrain` lighting + 3-tap PCF shadow (`:129-160,196`) and LINEAR fog (`:242-243`) remain unported because their bindings/uniforms are UNVERIFIED (DEEPDEC-03 §6.4) or engine-supplied; the shader comments now say so.
6. **Verification after correction:** parse ticket 222 `ok` (stderr 0 B); probe ticket 224 `ok`, **10/10 PASS**, stderr 0 B. (An earlier probe, ticket 217, exposed a shader compile error — `fog_enabled` was `float` but donor declares it `int` at `frag:23`; fixed to `uniform int`, re-run ticket 220 clean, then final re-verify as above.)

## 7. Verification (variant3d runner only)

All launches: `python -X utf8 variant3d\tools\godot_runner.py run --id <id> --timeout <s> -- --headless --path variant3d …`. No direct `godot` invocation. Full gate **not** run.

| Ticket | id | argv tail | Result |
|---|---|---|---|
| 216 | `v784-water-parse` | `--check-only --script res://scripts/water3d.gd` | `ok`, exit 0, run 6.72 s, stderr 0 B |
| 217 | `v784-water-probe` | `--script res://tests/_v784_probe.gd` | `ok`, 10/10 checks, but stderr exposed `fog_enabled` float/int shader compile error → fixed |
| 220 | `v784-water-probe2` | same probe | `ok`, 10/10 PASS, run 9.23 s, **stderr 0 B** (shader compiles) |
| **222** | **`v784-water-parse-final`** | `--check-only --script res://scripts/water3d.gd` | **`ok`, exit 0, run 4.48 s, stderr 0 B** — final file parses clean |
| **224** | **`v784-water-probe-final`** | `--script res://tests/_v784_probe.gd` | **`ok`, exit 0, run 6.14 s, stderr 0 B, 10/10 PASS** |

Final probe assertions and measured values:

- `module_load` — `res://scripts/water3d.gd` loads/instantiates ✅
- `mesh_instance_exists` — `WaterPlane3D` `MeshInstance3D` present ✅
- `shader_material_exists` — `material_override` class `ShaderMaterial` ✅
- `uniform_water_level_-0.25` — read back **`−0.25`** ✅
- `uniform_shore_height_-0.1` — read back **`−0.1`** ✅
- `uniform_max_height_2.96` — read back **`2.96`** ✅
- `wave_noise_bound` — `diffusewaves0.png` `ImageTexture` bound ✅
- `height_tex_fallback_bound` — neutral `ImageTexture` bound ✅
- `shader_resource_bound` — `res://shaders/water3d.gdshader` `Shader` bound ✅
- `plane_has_4_vertices` — `ARRAY_VERTEX.size() == 4` ✅

The temporary probe `variant3d/tests/_v784_probe.gd` and its result JSON were **deleted** after verification. No `.uid` files were generated for the two new files.

## 8. UNVERIFIED list (must stay labelled)

1. `hmapTex` literal engine binding — only a Delphi string assignment is proven (DECOMP-04 §8.2; DEEPDEC-03 §6.4). `height_tex` is a port substitute.
2. `reflectionMap` projected FBO / `texture2DProj` coord binding (TERRAIN2-03 UNV-2; DEEPDEC-03 §6.4).
3. `shadowMap` / `shadowSize` / `shadowColor` binding and 3-tap PCF upload (DEEPDEC-03 §6.4) — `watershade=1.0` uses the donor's unshadowed branch.
4. Numeric descriptor defaults **in the binary** — none provable; only external `water.lib`/`water.dev.frag` literals are PROVEN (DEEPDEC-03 §2.3). `1.99999988` is a bitmask, not a float constant.
5. Containing function for `0x853ad4` and `0x854051` — function discovery misses the whole region (DEEPDEC-03 §3).
6. Active execution of the commented `texturemap.inc` / `generatemap.inc` branches (TERRAIN2-03 UNV-4; DEEPDEC-03 §6.4 #6).
7. Water-plane topology (one quad vs strips/camera-following) — inferred from the passthrough vertex stage (TERRAIN2-03 UNV-5).
8. Whether `DiffuseWaves2` is uploaded to a normal-map sampler (DEEPDEC-03 §6.4 #4).
9. Meaning of the `f*`/`wst*` name tables beyond being name pools (DEEPDEC-03 §6.4 #7).
10. **Visual parity** — requires a GPU A/B capture; explicitly not claimed.

---

*End of report. Two source files added; probe deleted; no visual parity claimed; full gate left to coordinator.*
