---
id: DEC-U-WATER-MESH-UV
worker: DEC-U-WATER-MESH (subagent in full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
ticket: "Statically recover water mesh UV/winding, hmapTex identity + hmapMin/Max/W/H sources, and C+0xc8 time writer; zero-mismatch GPU captures; port diff list"
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
labels: [O, D, I, U]
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. No donor binary executed, copied or committed. No donor file written."
scope_guard: "No repo code/asset/config/shader/Godot/git edit. Exactly one repo file written: this report."
multi_pass: true
visual_parity_claim: false
upstream: "DEC_U_water_runtime.md §§5/6/7 (U3/U5/U6/U12); DEC_U_water_fbo.md §§3/4/8 (U12); PORT1TO1_water_shore.md §§4/5/7/11 (U1-U6,U12); variant3d/scripts/water3d.gd; variant3d/shaders/water3d.gdshader"
---

# DEC-U-WATER-MESH-UV — mesh callback, hmap identity/sources, time writer (static, read-only)

## 0. Authority and discipline (read first)

Every statement below is `[O]` (verbatim bytes/text/decompiled instruction or verbatim port file line), `[D]` (deterministic control-flow/arithmetic from `[O]`), `[I]` (interpretation) or `[U]` (UNVERIFIED — a concrete settling capture with a zero-mismatch termination criterion is given in §8; the port must **hard-fail, never invent a texture/matrix/UV**). This worker issued **no Craft Anything native calls** (only repo/doc reads via default tools in this subagent context); all donor addresses/evidence ids below are **re-cited pinned records** from `DEC_U_water_runtime.md` / `DEC_U_water_fbo.md` / `PORT1TO1_water_shore.md`, each pinned `document:"t_87f0f3c130b0"`, Deep mode (Ghidra 12.2 + built-in 0.6.1 engine). No donor binary was executed, no GPU frame was captured by this worker, and no parity claim is made. Active donor target was never opened/selected/closed by this worker. No helper script was written or run by this worker beyond repo reads.

`[D]` The load-bearing port fact is unchanged: `variant3d/scripts/water3d.gd:520-527` hard-fails BUILTIN water draw when `_reflection_map == null`, and `water3d.gdshader:102` keeps `water_shader_path = 1` (BUILTIN) as the **labelled `[D]` default** with `water3d.gdshader:365-366` (`if (!reflectionMapBound) { discard; }`) as the shader-side guard. This report tells the owner exactly what donor-faithful mesh/UV/hmap/time wiring is allowed (captured reals only) without inventing any of them, and preserves both the default and the hard-fail.

---

## 1. Pass ledger (owner rule ≤5 passes/function; every pass logged)

This ticket performed **document/byte-record re-analysis passes only** (no new native lifts). Each pass re-reads one cited record and checks reachability to the water draw. No function exceeded 5 prior + current passes.

| # | Question / function | Passes this ticket | Result |
|---|---|---|---|
| R1 | Draw path `FUN_00826b30` @0x826b30 + virtual `+0x98` | 1 re-read: Deep pseudo `ev_0510b30f6767e9fa46c81bc3020848d160cb9be348bd2b3b5224f4a02c437c` + PORT1TO1 §7.3 disassembly | **Accepted as localized**: `glBegin(4)`=TRIANGLES, `glColor4f(1,1,1,1)`, per-group `vtable+0x98(group,caller,1,1)`, `glEnd` |
| R2 | Mesh cache `FUN_00545e0c` / `FUN_00545d64` / `FUN_00545bd8` | 1 re-read each: `ev_74d8287020a8c15d25f45118d6923ee1ac4fb4650d43cdc6fbeba5919e7f6f` / `ev_f2c0d585211380b35c22863e85b145d1d34930c1085fbfabeda74aba2cfa56` / `ev_31d8677f31fa432c8990f7ab4194f092a0975230073f55ce2446d27296b7ad7b` | **Accepted as narrowing**: keyed cache by size, allocation via `FUN_0089dd0c`; **no per-vertex UV/winding writer in water code** |
| R3 | Field callback `FUN_00603d30` @0x603d30 + `FUN_0073b57c` / `FUN_0073ab50` geometry | 1 re-read: `ev_626574ae222dec3a4ca1b6e81a55874c24cae2c0e2c4b613d3f350d514f86a` + PORT1TO1 §7.2 disassembly + `ev_c987ab1b4f4baee2d99fe7c877a719d0194ca4f1f803e3605b32547f7dcef8d4f` | **Accepted**: 2×2 quad at Y=`cOffsetY`, centre/extent contract; no UV/FBO writer |
| R4 | Binder `FUN_00854054` @0x854054 hmap rows (bits 7e.10–7f.1) | 1 re-read: `ev_ab751f818e4b8839b5f6d60152283cfd960778f0ed7cea91aed7cba91b0641` + raw bytes 0x854080–0x8542f0 `ev_bbdba234fcbb85df996f0f2e5ed4b1df1aaa00f02c95c3861160cc201851db7a` | **Accepted, decisive**: gating on `C+0xe0` + field sources `C+0xd0/+0xd4/+0xe4/+0xe8`, sampler unit `C+0xdc` |
| R5 | Height staging `FUN_008520a8` @0x8520a8 | 1 re-read: `ev_ada19843eaa6b989e47f1d8dd8a5c512875c5ef290b66241b73905af4e63852b` | **Accepted**: `hmapW=C_obj+8`-chain, `hmapH=+0xc`-chain, `hmapMin/Max` via `FUN_0082f060/0082f114` on `+0x200` object; gate on `+0xb9/+0xc0` |
| R6 | Time expression `FUN_00854054` bit 7c.4 (0x854091) | 1 re-read: same `ev_bbdb…` raw bytes + `ev_ab75…` | **Accepted**: `fld qword [C+0xc8]` / `fmul qword [C+0xc4]` / `fstp dword [esp]` → `glUniform1f` |
| R7 | Time-writer search (`fstp qword [reg+0xc8]`) + ctor `FUN_00856080` | 1 re-read: `ev_5aaec0315458ec67490ef87ee4c2c2f70f72e65aef9fbaaacdfbc718ac2de3787` + DEC_U §5.3 writer scan note (0x50b255/0x50b269/0x50b37a unrelated) | **Accepted as `[U]`**: ctor zeroes `C+0xc8..0xcf`; no water-anchored writer found |
| R8 | Reflection state `FUN_0085756c` / `FUN_0085787c` + `FUN_004cdd9c/FUN_004cdbdc` + FBO name table | 1 re-read: `ev_2b512f029199e31de846bb803fa47db8e45e1c64a0757b792b2a58512a19eb49` + `ev_c380af4afa1f8d45c00409005eb167c5abde0a1dc989495d481d2f01b71ef0c2` | **Accepted as localized / `[U]` provenance**: object `C+0x4c` (id at `+8`), matrix via `004cdd9c(…,0x60,…)`; FBO names only |
| R9 | Donor shader texts (`water.dev.vert/frag`, embedded pair, `water.lib`) | 1 re-read: PORT1TO1 §§3.3/5.1/5.3 + `ev_2eb06d2413a38b3fcbb43c22048de75750d09258b357b82724f1253c587483d`, `ev_227e118e2e2af6e3438913898c1823ce94d1154bed056b99beb99c60db37d84b`, `ev_5dc9caf177e9e66467beedfe57b31b070ff42e9f35cb30e6b04b92ef603ebf80`, `ev_ce22a2e5d641c6cdc1dabafffb509abfb261359938f32c5d8f42b063ade9f0db` | **Accepted**: UV `-0.5` centring verbatim in DEV VP; embedded pair has **no hmap test**; `water.lib` pins DEV filenames |
| R10 | Port files `water3d.gd` / `water3d.gdshader` / `_make_water3d` | 1 read each (this ticket, repo HEAD) | **Accepted as `[O]`**: line intents for §9 diff; BUILTIN default + U12 hard-fail verified present |

No `wglMakeCurrent`/pbuffer water-anchored hit exists in the re-read corpus → `[U]`, fenced to §8.

---

## 2. Evidence register (all pinned `t_87f0f3c130b0`; re-cited, not re-lifted)

| Evidence id | Source (prior ticket) | Establishes (re-verified by re-read) |
|---|---|---|
| `ev_0510b30f6767e9fa46c81bc3020848d160cb9be348bd2b3b5224f4a02c437c` | Deep pseudo `FUN_00826b30` | `glBegin(TRIANGLES)` + virtual `+0x98` draw loop; `glColor4f` gating |
| `ev_74d8287020a8c15d25f45118d6923ee1ac4fb4650d43cdc6fbeba5919e7f6f`, `ev_f2c0d585211380b35c22863e85b145d1d34930c1085fbfabeda74aba2cfa56`, `ev_31d8677f31fa432c8990f7ab4194f092a0975230073f55ce2446d27296b7ad7b` | Deep pseudo mesh helpers | Mesh cached by key (w/h), allocation via `FUN_0089dd0c`; no per-vertex UV writer in water code |
| `ev_626574ae222dec3a4ca1b6e81a55874c24cae2c0e2c4b613d3f350d514f86a` | Deep pseudo + disasm `FUN_00603d30` | `WaterFieldAdd` impl; 35 insns; field/Y/bounds calls; no UV/FBO writer |
| `ev_c987ab1b4f4baee2d99fe7c877a719d0194ca4f1f803e3605b32547f7dcef8d4f` | `native_bytes_show(0x601660)` | DScript registration; `WaterFieldAdd → FUN_00603d30` |
| `ev_ab751f818e4b8839b5f6d60152283cfd960778f0ed7cea91aed7cba91b0641` | Deep pseudo `FUN_00854054` | 30-key bitmask binder; per-bit sampler/value sources |
| `ev_bbdba234fcbb85df996f0f2e5ed4b1df1aaa00f02c95c3861160cc201851db7a` | `native_bytes_show(0x854080,624)` | Value pushes at each binder call; `C+0xec` shadow gate at 0x8542d2; time `fld/fmul/fstp` at 0x854091 |
| `ev_ada19843eaa6b989e47f1d8dd8a5c512875c5ef290b66241b73905af4e63852b` | Deep pseudo `FUN_008520a8` | `hmapW/H/Min/Max` + height-object derivation; gates on `+0xb9/+0xc0` |
| `ev_5aaec0315458ec67490ef87ee4c2c2f70f72e65aef9fbaaacdfbc718ac2de3787` | Deep pseudo `FUN_00856080` | Ctor defaults incl. `+0x184=0`, `+0xe0/+0xec=0`, `C+0xc8..0xcf=0`, scalars, `+0xc4=1.0f` |
| `ev_513eeafe38634fbcdc522d1db8484a0f84f018b6e59a0f58983d37c7202338` | Deep pseudo `FUN_00852f5c` | Layer→shader map incl. `CustomEnable→+0x184`, `Speed→+0xc4`, colours/waves/scales |
| `ev_2b512f029199e31de846bb803fa47db8e45e1c64a0757b792b2a58512a19eb49` | Deep pseudo `FUN_0085756c` | Reflection texture matrix via `FUN_004cdd9c(FBO/caller+0x4c,…,0x60,…)` + `FUN_004cdbdc` |
| `ev_2eb06d2413a38b3fcbb43c22048de75750d09258b357b82724f1253c587483d`, `ev_227e118e2e2af6e3438913898c1823ce94d1154bed056b99beb99c60db37d84b` | `core_text_read water.lib` | `CustomEnable=False`, `Speed=1.0`, `HeightMapEnable=True`, `DefaultWaterIndex=0`, VP/FP filenames |
| `ev_c380af4afa1f8d45c00409005eb167c5abde0a1dc989495d481d2f01b71ef0c2` | `native_bytes_find("Framebuffer")` | 32 CODE hits; EXT + core/ARB spellings; **names only** |
| `ev_257c8a429a8bd195d6e14eb934118c493e48f3bdacbd1a25717aff7fceb95f5` | thunk scan | `glCopyTexImage2D@thunk` 0x4afb3c (import 0x907d7c); call at 0x4ed44c generic |
| `ev_8096d5d90140786d5b7e0196e1a996a52c8c964d828c825902a879a8264e5cd7` | Deep pseudo `FUN_004ed38c` | Generic texture-image loader; one copy branch; not water-specific |
| `ev_5dc9caf177e9e66467beedfe57b31b070ff42e9f35cb30e6b04b92ef603ebf80`, `ev_ce22a2e5d641c6cdc1dabafffb509abfb261359938f32c5d8f42b063ade9f0db` | Deep pseudo `FUN_00854ac0` / `FUN_008551d8` | Embedded VP/FP verbatim; no hmap uniforms |
| `ev_8218b0f1aa21aefba779cac21107bff799438a4c5245953770eab6bcbc8642` | Deep pseudo `FUN_00856530` | 3-way selector; binder at 0x856897/0x8565d2; reflection gate on `FUN_00855fe0()` + `C+0x4c` |

`[D]` No evidence id in the re-read corpus anchors a per-vertex UV writer, an FBO-create/`glCopyTexImage2D`/pbuffer call, or a `C+0xc8` writer **inside** `FUN_00603d30`, `FUN_00854054`, `FUN_00856530`, `FUN_0085756c`/`FUN_0085787c`, or `FUN_00855b38`. The absence is bounded by the searched records (thunk/name-table/caller scans), not a whole-binary proof.

---

## 3. Vtable `+0x98` mesh callback — what is and is not in it `[O]/[D]`

- `[O]` `FUN_00826b30` (`ev_0510…`, PORT1TO1 §7.3 disassembly): `glMatrixMode(0x1700=GL_PROJECTION)` / `glPushMatrix` / `glLoadMatrixf(caller+0x50+0x68)` → `FUN_008520a8(shaderCtx, field, caller)` stages uniforms/colour state → `if !(shaderActive && secondShaderFlag): glColor4f(1,1,1,1)` → `glBegin(4)` (**GL_TRIANGLES**) → per-mesh-group loop `(**(vtable+0x98))(group, caller, 1, 1)` → `glEnd` → `FUN_0085224c` → `glPopMatrix`.
- `[O]` Mesh cache (`ev_74d8…`/`ev_f2c0…`/`ev_31d8…`): `FUN_00545e0c` asks `FUN_00545d64` for a cached mesh keyed by `(param_2, param_3, float@+0x10, float@+0x18)`; on miss `FUN_00545bd8` allocates the mesh record (`+8/+0xc` = key, `+0x28/+0x2c` = size) via `FUN_0089dd0c`. **There is no water-specific vertex writer.**
- `[D]` Therefore UVs, positions, triangle winding and culling for water live inside the **generic mesh-renderer vtable `+0x98`**, shared by all engine meshes, not in water code. Recovering them statically requires identifying the concrete class behind that vtable (RTTI walk + xref), which earlier passes failed to do (PORT1TO1 P15/P16). The donor implementation site is localized but its array contents are `[U]` (§8 U6 experiments).
- `[D]` The callback signature observed at every call site is `(group, caller, 1, 1)` — two trailing `1` args (verbatim in `ev_0510…` disassembly). Their semantic (e.g. UV-set / detail flags) is `[U]`; the port must not assign them meaning without the §8 U6 dump.

---

## 4. Vertex layout, UV convention (incl. `-0.5` centring), winding/culling `[O]/[D]/[U]`

### 4.1 Field geometry feeding the callback `[O]/[D]`

`FUN_00603d30` (`ev_626574…`) + `FUN_0073b57c` / `FUN_0073ab50` (PORT1TO1 §7.2, re-read R3): one flat 4-corner field per `bWaterMap[wmx,wmy]`, centred at `worldX=(tz+bz)*0.5`, `worldZ=(tx+bx)*0.5`, `worldY=cOffsetY=-0.5` (`generatemap.inc:654`), extents `|bx-tx|=|bz-tz|=2`. The x/z swap (script z → engine X) is a recovered engine convention `[D]`, not a guess.

### 4.2 UV convention — the only verbatim donor UV equation `[O]/[D]`

`water.dev.vert` (PORT1TO1 §5.1, re-read R9), verbatim:

```
gl_TexCoord[0] = gl_TextureMatrix[0]*pos;
gl_TexCoord[1].xy = gl_MultiTexCoord0.xy / vec2(hmapW,hmapH) - 0.5;
gl_TexCoord[1].z  = pos.y;                       // PLANE Y = donor WATER_LEVEL
gl_TexCoord[3]    = gl_TextureMatrix[3]*cameraModel*gl_ModelViewMatrix*pos;
```

Legacy `water.vert` (PORT1TO1 §5.2): `T3.xy=MultiTexCoord0.xy/(hmapW,hmapH)-0.5`, `T3.z=gl_Vertex.y`. `[D]` The donor hmap UV is therefore **`MultiTexCoord0/(hmapW,hmapH) − 0.5`** — the `-0.5` centring is donor verbatim, not a port invention. What `MultiTexCoord0` contains per vertex (grid coords vs 0..1 vs pixel coords) is `[U]` because the attribute array is filled inside the generic `+0x98` callback (§3): the divisor (`hmapW/H`) is known structurally (§5) but the dividend's numeric range is not statically proven. **Do not substitute `fract(world*0.5)`, `(x+0.5)/w`, or any grid-derived dividend without the §8 U6-UV capture.**

The embedded BUILTIN pair has **no hmap UV at all** (`ev_5dc9…`/`ev_ce22…`): `T1=P.xz*texScaleS+time*0.02`, `T2=P.xz*texScaleT+time*0.02` with `texScaleS/T` = 0.01/0.02 defaults. `[D]` Under the labelled BUILTIN default the hmap-UV question is inert for drawing; it becomes load-bearing only if U1 ever selects DEV/LEGACY.

### 4.3 Triangle winding / culling `[U]`

- `[O]` Draw mode is `glBegin(4)` = `GL_TRIANGLES` (PORT1TO1 §7.3 disassembly); one quad = 2 triangles. No `glFrontFace`, `glCullFace`, `glDisable(GL_CULL_FACE)`, or vertex-order literal was recovered in the re-read bytes for `FUN_00826b30` / `FUN_00603d30` / `FUN_00545bd8`.
- `[U]` Winding order (CW vs CCW, diagonal choice) and whether culling is disabled for water are **unsettled**. The port's current index order `water3d.gd:475-480` (`0,3,1 / 1,3,2`) and `water3d.gdshader:37` (`cull_disabled`) are **port scaffolding**, not donor. §8 U6-WIND gives the zero-mismatch capture that settles them. Until then the port must expose winding/cull as labelled `[U6]` parameters, never present the current order as donor.

---

## 5. hmapTex identity and hmapMin/Max/W/H numeric sources `[O]/[D]/[U]`

### 5.1 Numeric sources `[O]/[D]`

`FUN_008520a8(shaderCtx, layerObj, field)` (`ev_ada1…`) at draw time, verbatim re-read R5:

```
if (layerObj==0 || waterDesc==0 || layerDesc+0xb9 == 0)  // HeightMapEnable
    C+0xe0 = 0;                                  // no height object -> hmap* not bound
else:
    h = FUN_00739bf8(layerObj)
    C+0xe0 = FUN_0082f86c(*(h+0x200))             // engine height object
    C+0xd8 = *(h+0x50)                            // texture target (ctor default 0xde1 = GL_TEXTURE_2D)
    C+0xd0 = *(layerObj+8)                        // <-- hmapW (uniform 7e.20)
    C+0xd4 = *(layerObj+0xc)                      // <-- hmapH (uniform 7e.40)
    C+0xe4 = (float) FUN_0082f060(*(h+0x200))     // <-- hmapMin (7e.80)
    C+0xe8 = (float) FUN_0082f114(*(h+0x200))     // <-- hmapMax (7f.1)
```

`[D]` The binder gates bits 7e.10–7f.1 on `C+0xe0 != 0 && [C+0xe0+8] != 0` (`ev_ab75…` / `ev_bbdb…` at 0x854250). So donor `hmapW/H` are the engine terrain object's `+8/+0xc` and `hmapMin/Max` come from two getters on that object's `+0x200` sub-object. The old port guesses (`map_size/128`, `±2.96`) have **no native basis**. `water.lib` ships `HeightMapEnable=True`, `HeightMapTexUnit` unset (`ev_2eb0…`).

### 5.2 Texture identity `[U]`

`[O]` The bound sampler integer is `C+0xdc` (ctor default 2, `ev_5aae…`) and the height object lives at `C+0xe0`; texture target default `C+0xd8=0xde1`. `[U]` Which GL texture name / FBO attachment backs `C+0xe0` at a live frame, and the numeric `hmapW/H/Min/Max` there, remain unsettled → §8 U3 experiments. **Do not substitute `heightmapwaves0.tga`** (D06 P18: alpha 255 everywhere; `water.mat:86-106` fully commented) **or a 1×1 neutral texture.**

---

## 6. Writer of the `C+0xc8` time accumulator `[O]/[D]/[U]`

Raw bytes at 0x854091 (`ev_bbdb…`), re-read R6:

```
dd 86 c8 00 00 00   fld  qword [esi+0xc8]     ; shader-object double
d8 8e c4 00 00 00   fmul qword [esi+0xc4]     ; shader-object double = water.lib Speed (1.0)
83 c4 fc            add  esp,-4
d9 1c 24 9b         fstp dword [esp]          ; -> glUniform1f value
```

**[D] `time_uniform = (float)( *(double*)(C+0xc8) * *(double*)(C+0xc4) )`, with `*(double*)(C+0xc4) = Speed = 1.0` from `water.lib`** (`ev_513e…`, `ev_227e…`). The same double is reused for texture scrolling in `FUN_00856530` (`(float)*(double *)(C+200) * *(float *)(C+0x110)`).

`[U]` The writer of the double at `C+0xc8` was not found: the only `fstp qword [reg+0xc8]` instructions in the binary are at 0x50b255/0x50b269/0x50b37a (unrelated object, DEC_U §5.3). Constructor zeroes `C+0xc8..0xcf` (`ev_5aae…`), so at construction `time=0`. **Do not guess a time source (wall clock, frame count, `Time.get_ticks_msec`); run the §8 U5 experiment.** The port's `_time += delta` (`water3d.gd:250`) is labelled scaffolding, not donor.

---

## 7. What the port currently does (verbatim lines, `[O]`)

- Geometry: `water3d.gd:458-487` builds one 4-vertex / 2-triangle quad per field record (`verts[b..b+3]`, `uvs[b..b+3]`, `inds` `0,3,1 / 1,3,2`), `cOffsetY=-0.5` at line 58/429/464, extents `2*TILE_M`. UV space `water3d.gd:432-438` (`u0/u1/v0/v1` from grid coords) is explicitly labelled as absorbing the donor `-0.5` centring via `bind_height_grid`'s `(x+0.5)/w` encoding — that absorption is `[U6]` scaffolding.
- hmap substitute: `water3d.gd:489-511` uploads the real decoded height grid as `height_tex` (alpha `(h+2.96)/(2*2.96)`) and, only for LEGACY, aliases the same image to `hmapTex` with `hmapW=_grid_w`, `hmapH=_grid_h`, `hmapMin=-MAX_HEIGHT`, `hmapMax=+MAX_HEIGHT` — all labelled `[U3]` substitutes, never presented as recovered.
- Time: `water3d.gd:229/250-251` (`_time=0.0`, `_time += delta`, `set_shader_parameter("time", _time)`).
- BUILTIN guard: `water3d.gd:520-527` hard-fails without `_reflection_map`; `water3d.gdshader:365-366` discards when `!reflectionMapBound`. BUILTIN default: `water3d.gd:163` (`DEFAULT_WATER_SHADER_PATH = BUILTIN`), `water3d.gdshader:102` (`water_shader_path = 1`).
- Shader UV/winding scaffolding: `water3d.gdshader:37` (`cull_disabled`), `:77` (`map_size` substitute for `hmapW/H`), `:126-129` (`hmapW/H/Min/Max` labelled `[U3]`), `:168-171` (`height_map` with `±max_height`), `:334-358` (vertex; `v_screen_uv = clip*0.5+0.5` labelled `[U12]` at `:335/:348/:354`), `:376-378` (BUILTIN `refuv` screen-space substitute labelled `[U12]`).

---

## 8. `[U]` register — concrete GL/GPU capture experiments with zero-mismatch termination

Each row names the **break site + trace + byte-exact comparison**. Owner-authorised GPU capture only (RenderDoc/apitrace/Nsight-GL or equivalent; debugger breakpoints as named). **Zero-mismatch rule**: the capture output must equal the stated donor artefact with **0 differing elements** across the stated sample; any mismatch (or missing capture) leaves the item `[U]` and the port keeps hard-failing / keeps the labelled substitute. No donor binary work was done by this worker.

| # | Still-`[U]` item | Static state after this pass | Capture experiment (break + trace + termination) |
|---|---|---|---|
| U6-UV | Per-vertex dividend behind `MultiTexCoord0/(hmapW,H)-0.5`, and `-0.5` placement | `[D]` divisor = `C+0xd0/+0xd4`, minus-0.5 verbatim in DEV VP; `[U]` dividend array contents | Break on virtual `+0x98` from `FUN_00826b30` for one 2×2 field with a water draw. Dump the bound `GL_TEXTURE_COORD_ARRAY` / `glVertexAttribPointer(0)` `MultiTexCoord0` array (all 4 verts, float32) **and** the `glUniform1i hmapW/H` values from the same frame. Compute `uv_pred = attr/(W,H)-0.5` per vertex; read back the vertex-shader `gl_TexCoord[1].xy` (or `v_height_uv`) from the same draw. **Terminate `[U]` iff `max|uv_pred - uv_actual| == 0.0` (bit-exact float32) for all 4 verts across ≥2 fields + 1 camera move;** record which attribute (grid 0..1, pixels, world XZ) the dividend is. Until then the port UV stays `[U6]` scaffolding. |
| U6-WIND | Triangle winding / diagonal / culling | `[O]` `GL_TRIANGLES`, 2 triangles/quad; `[U]` order + cull state | Same `+0x98` break: dump the bound element/index array (or `glDrawArrays` first/count) for one field + `glGetIntegerv(GL_CULL_FACE)` / `glGetIntegerv(GL_FRONT_FACE)` / `glFrontFace` trace at the draw. Compare index order against port `0,3,1 / 1,3,2` element-wise. **Terminate `[U]` iff index sequence matches with 0 differing indices across ≥2 fields and cull/front state is identical across ≥2 frames;** record diagonal + CW/CCW explicitly. Until then `cull_disabled` + current indices stay labelled `[U6]` scaffolding. |
| U3-NUM | Numeric `hmapMin/Max/W/H` at a live frame | `[D]` sources = terrain `+8/+0xc`, getters `FUN_0082f060/0082f114` on `+0x200` object; gate on `C+0xe0` | Break on `FUN_00854054` bits 7e.10–7f.1 with a field visible. Record the 4 pushed values (`C+0xd0/+0xd4` ints, `C+0xe4/+0xe8` floats) + `C+0xe0` / `[C+0xe0+8]` gate values. **Terminate `[U]` iff the same 4-tuple repeats with 0 differing bits across ≥2 frames + 1 camera move;** then those 4 numbers (not `map_size/±2.96`) become the port parameters. |
| U3-TEX | `hmapTex` GL identity (name/target/provenance) | `[O]` unit `C+0xdc` (ctor 2), target `C+0xd8` (ctor `0xde1`); `[U]` bound name | At the same break, record `glActiveTexture(GL_TEXTURE0+u)` at unit `C+0xdc`, `glBindTexture(target,name)`, `glGetTexLevelParameteriv(name,0,GL_TEXTURE_WIDTH/HEIGHT/INTERNAL_FORMAT)`, and whether `name` appears as an FBO attachment or `glTexImage2D` upload earlier in the frame. **Terminate `[U]` iff the same `(target,name,w,h)` 4-tuple is observed with 0 mismatches across ≥2 frames;** unknown provenance ⇒ keep `bind_height_grid` substitute labelled `[U3]`, never promote art/`heightmapwaves0.tga`/neutral texel. |
| U5 | `C+0xc8` writer + live `time` values | `[D]` formula `(float)(double[+0xc8]*double[+0xc4])`, `+0xc4=Speed=1.0`; `[U]` writer of `+0xc8` | Hook `glUniform1f` on the `time` location (program identified per U1: `hmapTex` present = DEV, `alphaDepth` = BUILTIN). Sample the float across ≥3 frames spanning ≥2 s. If non-constant, set a hardware write-watchpoint on shader `+0xc8` (8 bytes) and record the writing `EIP` + disassembly; resolve to nearest symbol. **Terminate `[U]` iff either (a) constant `0.0` with 0 differing samples and watchpoint never fires across a 10 s water-visible window (then `time=0` is `[D]`-by-capture), or (b) animated with a single writer `EIP` firing every frame with 0 missed frames and the formula `float(+0xc8 * +0xc4)` reproducing the uniform with 0 ULP error.** Until then `_time += delta` stays labelled `[U5]` scaffolding. |
| U12 | Reflection provenance / sampler unit / matrix (carried, not re-settled here) | `[O]` object `C+0x4c` (id `+8`), unit `C+0xf8`, matrix via `FUN_0085756c`; FBO names only | Apply `DEC_U_water_fbo.md` §8 U12-A/B/C/T/S/P verbatim (FBO-attachment vs copy-dst vs static-upload test, unit hook, `FUN_0085756c` `+0x60` matrix dump + viewport state, `DiffuseWaves2` alias check, pbuffer sweep). **Same zero-mismatch rule: identical `(provenance_class, name, w, h, unit, matrix)` with 0 mismatches across ≥2 frames + 1 camera move;** any gap ⇒ keep `water3d.gd:520-527` hard-fail + `reflectionMapBound=false` default. |

General gating: every experiment requires a water field visible (break on `FUN_00603d30`, read `[ebp+0x1c]`) and the live shader path identified first (U1: hook `glShaderSource`; `hmapTex` present = DEV file pair, `alphaDepth`/`deepColor` = BUILTIN embedded pair). Captures on the wrong path do not settle any row above.

---

## 9. Exact port change list (file/line; NO edits made — owner applies)

All lines verified by repo read this ticket. **Wire only captured reals. Preserve the BUILTIN `[D]` default and the U12 hard-fail in every diff.**

1. **`variant3d/scripts/water3d.gd:163`, `water3d.gdshader:102`** — KEEP `DEFAULT_WATER_SHADER_PATH = BUILTIN` / `water_shader_path = 1` as-is (labelled `[D]` per DEC_U_water_runtime §4.3 `CustomEnable=False → C+0x184=0 → CUSTOM unreachable`). Do not flip to DEV/LEGACY without the U1 capture.
2. **`variant3d/scripts/water3d.gd:520-527` + `water3d.gdshader:107-108,365-366`** — KEEP the U12 hard-fail as-is (`bind_reflection_map(null)` refused; `_finalize_water_node` returns `false` + `push_error` when `_reflection_map == null`; shader `reflectionMapBound=false` default + `discard`). After a §8 U12 capture only, extend `bind_reflection_map` (`water3d.gd:343-353`) to validate captured `(w,h,unit)` and extend the gate to require matrix U12-T; never auto-resize/substitute.
3. **`variant3d/scripts/water3d.gd:432-438` (`u0/u1/v0/v1`) + `466-480` (verts/uvs/inds) + `water3d.gdshader:37,322-358`** — after §8 U6-UV/U6-WIND capture only: set the dividend to the captured attribute domain (grid/pixel/world) with the verbatim `-0.5` after division (`water.dev.vert:14`), set index order to the captured 6-element sequence, and set `render_mode cull_*` to the captured cull/front state. Until then keep current order + `cull_disabled` but keep the `[U6]` labels at `water3d.gd:215-223` (`vertex_uv_layout`) and shader `:341-344` comment. Never present current order as donor.
4. **`variant3d/scripts/water3d.gd:489-511` + `water3d.gdshader:68-72,77,126-129,168-171,187,276,400-401`** — after §8 U3-NUM/U3-TEX capture only: replace `map_size.x/y` dividend divisor with captured `hmapW/H`, `±MAX_HEIGHT` span with captured `hmapMin/Max`, and the decoded-grid `height_tex`/`hmapTex` alias with the captured `(target,name)` texture (FBO attachment import or captured copy target — never generated solid-colour, never `diffusewaves` art unless U12-S proves identity). Until then keep the substitute + `[U3]` labels (`water3d.gd:138-145,216-217,502-511,717,755`).
5. **`variant3d/scripts/water3d.gd:229,247-251` + `water3d.gdshader:78,177,248`** — after §8 U5 capture only: replace `_time += delta` with the captured writer (or freeze at `0.0` if U5 terminates constant) while keeping the formula `float(double[+0xc8]*double[+0xc4])` in a comment and the `time` uniform name. Until then keep `_time` + `[U5]` labels (`water3d.gd:120,218-219,719`).
6. **FORBIDDEN (violates donor faithfulness):** inventing a winding order, a `fract(world*0.5)` / `(x+0.5)/w` dividend, a `map_size/128` divisor, a `±2.96` span, a `*0.5+0.5` bias or mirror matrix, a viewport-sized reflection target, a neutral/grey texture, or aliasing `reflectionMap`/`hmapTex` to `diffusewaves`/`heightmapwaves` art; calling `bind_reflection_map()` from `_make_water3d` with any non-captured texture; flipping the default off BUILTIN to "make water appear".

---

## 10. Explicit non-claims and file discipline

- **No parity claim.** No donor binary executed, no GPU frame captured, no port capture compared by this worker. All readings are re-cited `[O]/[D]`; all unsettled values are `[U]` with §8 captures.
- **No approximation substituted.** No UV dividend, winding order, cull state, texture name/size, matrix, viewport, or time source is supplied in this report. The port's current behaviour (BUILTIN labelled default + hard-fail without a real reflection target + labelled `[U3]/[U5]/[U6]` substitutes) is endorsed as the donor-faithful behaviour until the corresponding zero-mismatch capture lands.
- **Read-only compliance.** Exactly one repo file written: `docs/terrain_swarm_2026-11-26/reports/DEC_U_water_mesh_uv.md`. No code/shader/asset/config/Godot/git change. No donor file opened for write or executed. No other worker target touched.

*End of DEC-U-WATER-MESH-UV.*
