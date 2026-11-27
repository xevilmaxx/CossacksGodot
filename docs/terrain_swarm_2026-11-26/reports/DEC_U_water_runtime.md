---
id: DEC-U-WATER-RUNTIME
worker: DEC-U-WATER-RUNTIME (subagent in full 1:1 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
ticket: "Static recovery of the still-[U] water runtime values from native code; hard-fails or capture experiments, no silent fallback"
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
labels: [O, D, I, U]
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. No donor binary executed, copied or committed. No donor file written."
scope_guard: "No repo code/asset/config/shader/Godot/git change. Exactly one repo file written: this report. Shared Craft Anything investigation memory (owned by PORT1TO1-ENTITIES) was read only; NOT overwritten."
multi_pass: true
visual_parity_claim: false
upstream: "PORT1TO1_water_shore.md §11 U1/U3/U4/U5/U6/U12; D06_water_shore.md; DEC_DEEP_water_color.md"
---

# DEC-U-WATER-RUNTIME — native recovery of remaining water runtime `[U]`s (2026-11-26)

## 0. Authority and discipline (read first)

Every statement below is `[O]` (verbatim bytes/decompiled instruction/text), `[D]` (deterministic arithmetic/control-flow from `[O]`), `[I]` (interpretation) or `[U]` (UNVERIFIED — a concrete settling experiment is given in §9, and the port must **hard-fail**, never pick a silent fallback). All Craft Anything native calls were pinned `document:"t_87f0f3c130b0"`; `core_session_show` at start reported active target `t_87f0f3c130b0`, deep mode (Ghidra 12.2 engine for pseudocode, built-in 0.6.1 engine for bytes/imports); no target-open/select/close call was issued by this worker. `editor.exe` (`t_68474ddde43f`) was **not** touched by this worker.

Read-only helper scripts lived outside the repo (`%LOCALAPPDATA%\Temp\opencode\decu_water_*.py`) and did only `open(path,'rb').read()` on `cossacks.exe`; they computed VA→file-offset as `VA − 0x400C00` (calibrated from `native_bytes_show`: VA `0x4c0f90` → file `0xc0390`, `0x4b5160` → `0xb4560`). No donor code was run.

**Single most important new result:** three of the six remaining `[U]`s are now *structurally closed or tightly bounded* by native code: U4 (all 21 scalar/vector uniform value sources), U5 (the exact `time` expression), and the numeric part of U3 (`hmapW/hmapH/hmapMin/hmapMax` source fields). U1 is narrowed to two flag reads plus a global; U6 and U12 remain `[U]` but their donor implementation site is now localized. **No parity claim is made anywhere.**

---

## 1. Pass ledger (owner rule ≤5 passes/function; every pass logged)

| # | Function / question | Passes this ticket | Result / accepted? |
|---|---|---|---|
| P1 | `FUN_00855b38` @0x855b38 (compile) | 1 Deep pseudo (`ev_a66a…`) + 1 raw bytes 0x855b60–0x855c60 (`ev_fdac…`(prior)/byte scan) | **Accepted**: embedded VP/FP compiled into program at `+0x50`; hard error on link fail. |
| P2 | `FUN_0085600c` / `FUN_00855fe8` / `FUN_00855fe0` | 1 Deep pseudo each (`ev_30ba…`, `ev_49ac…`, `ev_7fc0…`) | **Accepted**: shader-active = 3 engine globals AND byte `+0x54`. |
| P3 | `FUN_00856530` @0x856530 (3-way selector) | 1 Deep pseudo (`ev_8218…`) + 1 raw bytes 0x856530–0x8565e0 | **Accepted, decisive**: custom branch condition is `C+0x184 != 0 AND [0x8fc6b8] != 0`; verified against machine code. |
| P4 | `FUN_00851bdc` @0x851bdc (layer→shader init) | 1 Deep pseudo (`ev_67a5…`) + 1 built-in clean-room decompile (`ev_5116…`, agrees) | **Accepted**: layer pointer 0 → constructor; nonzero → `FUN_00852f5c`. |
| P5 | `FUN_00852f5c` @0x852f5c (layer copy) | 1 Deep pseudo (`ev_513e…`) | **Accepted, decisive**: `CustomEnable → C+0x184`, `water.lib` scalar/colour/wave values → `C+0x58..+0xc4`. |
| P6 | `FUN_00854054` @0x854054 (binder) | 1 Deep pseudo (`ev_ab75…`) + 1 raw bytes 0x854080–0x8542f0 (`ev_bbdb…`) + 1 `e8` call-site scan | **Accepted, decisive**: every scalar value is an explicit stack push from a named shader-object field. |
| P7 | GL dispatch wrappers `FUN_004c0f3c/0f90/0fb8/0fdc/102c/1058` | 1 Deep pseudo each + 1 raw byte dump 0x4c0f90–0x4c1110 (`ev_84eb…`) + 1 extension-name table dump (`ev_6eec…`) | **Accepted**: arg counts/order identify `glUniform1f/1i/2f/3f/Matrix4fv`; names resolved via `wglGetProcAddress`. |
| P8 | `FUN_00856080` @0x856080 (ctor) | 1 Deep pseudo (`ev_5aae…`) | **Accepted**: all defaults incl. `+0x184=0`, `+0xe0/+0xec=0`, scalars `0.4/0.3/4/.1/.5/1/.05/2/.01/.4/.825`, `+0xc4=1.0f`. |
| P9 | `FUN_008520a8` @0x8520a8 (draw staging) | 1 Deep pseudo (`ev_ada1…`) | **Accepted**: `hmapW/H/Min/Max` and height/shadow object fields derived here. |
| P10 | `FUN_00545e0c`/`0x545d64`/`0x545bd8` (mesh cache) | 1 Deep pseudo each (`ev_74d8…`, `ev_f2c0…`, `ev_31d8…`) | **Accepted as narrowing**: mesh cached by size; per-vertex UV/winding live in generic vtable `+0x98`, not water code. |
| P11 | `FUN_00826b30` @0x826b30 (draw) | 1 Deep pseudo (`ev_0510…`) + 1 caller scan | **Accepted**: `glBegin(GL_TRIANGLES)`, `glColor4f(1,1,1,1)`, virtual `+0x98` per group. |
| P12 | `FUN_0085756c`/`FUN_0085787c` (reflection matrix/state) | 1 Deep pseudo each (`ev_2b51…`, `ev_0348…`) + 1 caller scan | **Accepted**: reflection texture object is `C+0x4c` (GL texture id at `+8`); matrix built by `FUN_004cdd9c/FUN_004cdbdc`. |
| P13 | Reflection FBO creation | 1 import search (`ev_8c94…`, `ev_05c9…`) + 1 CODE name-table scan (`ev_c380…`) + 1 call-site scan of `glCopyTexImage2D` thunk (`ev_257c…`) + 1 Deep pseudo `FUN_004ed38c` (`ev_8096…`) | **Partial → `[U]`**: FBO extension names present, but no water-specific FBO creation recovered; only a generic texture loader uses `glCopyTexImage2D`. |
| P14 | `sub_8519f4` @0x8519f4 (layer lookup caller) | 1 clean-room decompile (`ev_d41c…`) — 221 lines, 7 gotos, 26 `__asm`, `deep_engine_unavailable` | **Rejected as evidence** (garbled); raw-byte call contexts used instead. No further pass consumed. |
| P15 | `water.lib` re-read | 1 `core_text_read` full (`ev_2eb0…`) + 1 tail (`ev_227e…`) | **Accepted**: `CustomEnable=False`, `Speed=1.0`, `DefaultWaterIndex=0`, `water.dev.vert/frag`. |

---

## 2. Evidence register (new this ticket, all pinned `t_87f0f3c130b0` unless noted)

| Evidence id | Source | Establishes |
|---|---|---|
| `ev_a66a956b6a994521c1060ff03d8490b4284f2b7e15bb4aaebcefc6d7c73984f6` | Deep pseudo `FUN_00855b38` | Program created at `+0x50`; embedded VP/FP generated by `FUN_00854ac0`/`FUN_008551d8`; sources attached via `FUN_004c0c9c`; link check `FUN_004c0eb4` → hard error `FUN_004b03b8`. |
| `ev_8218b0f1aa21aefba779cac21107bff799438a4c52459533477079bebcbc8642` | Deep pseudo `FUN_00856530` | Three-way branch; binder called from built-in branch (0x856897) and custom branch (0x8565d2). |
| `ev_ab751f818e4b8839b359f3da00152283cfd960776db078f970aed7cea91b0641` | Deep pseudo `FUN_00854054` | 30-key bitmask binder; exact field sources per bit. |
| `ev_bbdba234fcbb85df996f0f2e5ed4b1df1aaa00f02c95c3861160cc201851db7a` | `native_bytes_show(0x854080,624)` | Value pushes at each binder call (`ff b6 <off>`, `fld/fmul qword`, `lea` vectors). |
| `ev_5aaec0315458ec67490ef87ee4c2c2f70f72e65ae9fbaaacdfbc718ac2de3787` | Deep pseudo `FUN_00856080` | Constructor defaults and all zeroed object pointers. |
| `ev_ada19843eaa6b989e47f1d8dd8a5c512875c5ef290b66241b73905af4e63852b` | Deep pseudo `FUN_008520a8` | `hmapW=C_obj+8`, `hmapH=C_obj+0xc`, `hmapMin/Max` via `FUN_0082f060/0082f114`, gates on `+0xb9`/`+0xc0`. |
| `ev_513eeafe38634fbdc522d1db078484a80f84f018b6e59a0f58983d37c7202338` | Deep pseudo `FUN_00852f5c` | **Layer descriptor → shader field map**, including `CustomEnable→+0x184` and all 21 uniform sources. |
| `ev_67a5083d1de168ff4483c44405a905f4d010e3f873fcb249547cac621a03c28b` | Deep pseudo `FUN_00851bdc` | layer==0 → `FUN_00856080`; else → `FUN_00852f5c`. |
| `ev_84eb83bef1d668abb4da268019246e5e45def6585098b0785f8f328cbd993114` | `native_bytes_show(0x4c0f90,384)` | Exact GL-wrapper call sequences and pointer globals `0x8fc724/0x8fcb0c/0x8fc7f0/0x8fbc34/0x8fc7c0`. |
| `ev_6eec1ce1633753bbf5d98a4a018c32ef3244689a7372b45ea284169ff84db2be` | `native_bytes_show(0x4b5140,96)` | CODE-resident GL 2.0 extension-name table (`glAttachShader`, `glCompileShader`, `glCreateProgram/Shader`, …). |
| `ev_711e2a981266b3cb2edb487ce33b08fbd32826dffd3ac4b28ff70d8dd0da6673` | `native_bytes_find("glUniform")` | 82 raw CODE hits, incl. `glUniform1f/2f/3f/4f/1i/…/Matrix4fv` at 0x4b5388–0x4b5490. |
| `ev_c380af4afa1f8d45c00409005eb167c5abde0a1dc989495d481d2f01b71ef0c2` | `native_bytes_find("Framebuffer")` | 32 CODE hits incl. `glGenFramebuffersEXT` (0x4b98d0), `glFramebufferTexture2DEXT` (0x4b9920), `glCheckFramebufferStatusEXT` (0x4b98e8). |
| `ev_257c8a429a8bd195d6e14eb934118c4933e48f3bdacbd1a25717aff7fceb95f5` | `native_bytes_find("ff 25 7c 7d 90 00")` | `glCopyTexImage2D@thunk` at 0x4afb3c (import 0x907d7c). |
| `ev_8096d5d90140786d5b7e0196e1a996a52c8c964d828c825902a879a8264e5cd7` | Deep pseudo `FUN_004ed38c` | Generic texture-image loader; one `glCopyTexImage2D` branch at 0x4ed44c; not water-specific. |
| `ev_2b512f029199e31de846bb803fa47db8e45e1c64a0757b792b2a58512a19eb49` | Deep pseudo `FUN_0085756c` | Reflection texture matrix via `FUN_004cdd9c(FBO/caller+0x4c, …,0x60,…)` + `FUN_004cdbdc`. |
| `ev_2eb06d2413a38b3fcbb43c22048de75750d09258b357b82724f12563f587483d`, `ev_227e118d2e2af7e6434913898c1823ce94d1154bed056d99beb99c60db37d84b` | `core_text_read water.lib` (path-scoped) | `CustomEnable=False`, `Speed=1.0`, `HeightMapEnable=True`, `DefaultWaterIndex=0`, VP/FP filenames. |
| `ev_74d8287020a8c15d25dfa65118d6923ee1ac4fb4650d43cdc6fbeba5919e7f6f`, `ev_f2c0d585211380b35c22863e85b1452d1d34930c10815fbfabeda74aba2cfa56`, `ev_31d8677f31fa432c8990f7ab4194f092a0975230073f55ce2446d27296b7ad7b` | Deep pseudo mesh helpers | Mesh cached by key (w/h), allocation via `FUN_0089dd0c`; no per-vertex UV writer in water code. |
| `ev_0510b30f6767e9fa46c81bc3020848d160cb9be348bd2b3b2b5224f4a02c437c` | Deep pseudo `FUN_00826b30` | `glBegin` + virtual `+0x98` draw loop; `glColor4f` gating. |
| `ev_d41c427e5217c6e5286bb2a3907a3fb6bd421ddb6d3f6239dd6443cfe72f36eb` | built-in decompile `sub_8519f4` | **Rejected**: garbled; not used as evidence. |

---

## 3. GL dispatch layer — what the `glUniform` wrappers actually call (new `[O]/[D]`)

The binary has **no** imported `glUniform*`, `glShaderSource`, `glCreateShader/Program`, `glGenFramebuffers` or `glActiveTexture` (`native_functions_search` = 0 each, e.g. `ev_05c9…`, `ev_13c1…`). Instead it imports only `wglGetProcAddress` (`0x907bbc`, `ev_31d7…`) and resolves OpenGL 2.0/ARB/EXT entry points from a **CODE-resident null-separated name table** (`ev_6eec…`, 0x4b5140+: `glAttachShader, glCompileShader, glCreateProgram, glCreateShader, …, glShaderSource, glUseProgram, glUniform1f/2f/3f/4f/1i/…/1fv/…/Matrix4fv`, plus ARB variants at 0x4b6cd0+ and FBO EXT/core variants at 0x4b70xx–0x4b72xx and 0x4b98xx–0x4b99xx). The dynamic-pointer wrappers were decompiled and their machine code read:

| Wrapper | Pointer global | Args pushed | GL call `[D]` |
|---|---|---|---|
| `FUN_004c0f3c` @0x4c0f3c | `0x8fbb8c` | name string → `FUN_004058c0(name)` | `glGetUniformLocation` (returns location in EAX) |
| `FUN_004c0f90` @0x4c0f90 | `0x8fc724` | location + **1 float** (stack) | `glUniform1f` |
| `FUN_004c0fb8` @0x4c0fb8 | `0x8fcb0c` | location + **1 int** | `glUniform1i` (sampler/int uniforms) |
| `FUN_004c0fdc` @0x4c0fdc | `0x8fc7f0` | location + **2 floats** (`*p, p[1]`) | `glUniform2f` |
| `FUN_004c102c` @0x4c102c | `0x8fbc34` | location + **3 floats** (`*p,p[1],p[2]`) | `glUniform3f` |
| `FUN_004c1058` @0x4c1058 | `0x8fc7c0` | location + `count=1` + `transpose=0` + matrix ptr | `glUniformMatrix4fv` |
| `FUN_004c0c9c` | `0x4bf5c8`/`0x4bf63c` class refs | program + shader-type class ref + source | `glShaderSource`+attach (compile pipeline) |
| `FUN_004c0eb4` / `FUN_004c0ee8` | `0x8fcb04`/`0x8fc110` | program handle (program+8) | link-status / info-log query |
| `FUN_004c0f5c` | `0x8fc7ec` | — | `glUseProgram` |

`[I]` The mapping is by argument count/order plus the verbatim name table; the *runtime* pointer values are resolved by `wglGetProcAddress`, so which of the core vs ARB spelling is active is a driver-time fact, not statically fixed. **Port invariant:** this is a 1-float/1-int/2f/3f/Mat4 API, not a "pass everything as vec4" API.

---

## 4. U1 — which shader path is live: narrowed, not settled

### 4.1 The selection is a two-flag test in machine code `[O]/[D]`

`FUN_00856530` bytes at 0x856530 (`ev_8218…` + raw dump):
```
80 bb 84 01 00 00 00      cmp  byte [ebx+0x184], 0     ; C = shader object
0f 84 fd 02 00 00         je   0x856846                ; -> built-in/fixed branch
a1 b8 c6 8f 00            mov  eax, [0x008fc6b8]       ; global shader-enable byte ptr
80 38 00                  cmp  byte [eax], 0
0f 84 ef 02 00 00         je   0x856846
; inline here = CUSTOM branch: +0x188/+0xf0 objects, vtable+0x3c, binder if C+0x190 != 0
```
`FUN_0085600c` (`ev_30ba…`) = `FUN_00855fe8()` (three engine globals `0x8fcdb0`, `0x8fbd28`, `0x8fc748` all nonzero) **AND** byte `C+0x54 != 0`.

Three paths:
| Branch | Condition | Program used |
|---|---|---|
| CUSTOM | `C+0x184 != 0 && [0x8fc6b8] != 0` | external shader object at `C+0xf0`, vtable `+0x3c`; binder only if `C+0x190 != 0` |
| BUILTIN | not custom **and** `FUN_0085600c(C)!=0` and `[0x8fc6b8]!=0` | program at `C+0x50`, compiled by `FUN_00855b38`, binder at 0x856897 |
| FIXED | otherwise | legacy `glMatrixMode/glLight*` path; no custom uniforms |

### 4.2 The flags come from `water.lib` `[O]/[D]`

`FUN_00851bdc(wrapper, layerPtr)` (`ev_67a5…`): layerPtr==0 → `FUN_00856080(shaderObj)` (constructor); else `FUN_00852f5c(layerPtr, shaderObj)`. `FUN_00852f5c` (`ev_513e…`) does:
```
C+0x184 = layer+0x90    // CustomEnable
C+0x188 = layer+0x94    // CustomShaderID
C+0x191 = layer+0x9c    // CustomReflection
C+0x190 = layer+0xb8    // CustomUseUniforms
C+0x1a8 = layer+0xb4    // CustomTexReflectMatrixUnit
```
`water.lib` ships `CustomEnable=False`, `CustomShaderID=0`, `CustomReflection=False`, `LayerCount=1`, `DefaultWaterIndex=0` (`ev_2eb0…`, `ev_227e…`). The constructor also sets `C+0x184=0`, `C+0x190=0` (`ev_5aae…`). **`[D]` Both construction paths therefore leave `C+0x184=0` for the shipped configuration → the CUSTOM branch cannot be entered from `water.lib` as shipped.**

### 4.3 Compile path `[O]`

`FUN_00855b38` (`ev_a66a…`) only builds the **embedded** pair: `FUN_004c05e0(PTR_PTR_004bf6b4,1,1)` → program at `C+0x50`; `FUN_00854ac0` + `FUN_00848410(C+0x178)` = embedded VP; `FUN_008551d8` + `FUN_00848410(C+0x17c)` = embedded FP; `FUN_004c0c9c(program, 0x4bf5c8→class, C+0x178)` and `(0x4bf63c→class, C+0x17c)` attach sources; `FUN_004c0eb4` link-check, on failure `FUN_004c0ee8` + `FUN_004b03b8` (hard error). The file names `water.dev.vert/frag` in `water.lib:67-68` are parsed into descriptor `+0x18/+0x1c` but **no static code path from those strings to `FUN_00855b38` was recovered**.

**Verdict:** `[D]` shipped configuration strongly implies **BUILTIN** (the embedded pair compiled by `FUN_00855b38`), with `water.dev.vert/frag` and `water.vert/frag` *not* the programs drawn. `[U]` the runtime values of global `[0x8fc6b8]` and `FUN_00855fe8`'s three globals, and whether a map/mod overrides `CustomEnable`, are not statically provable. **Do not silently choose a path in the port:** keep the explicit `DEV/BUILTIN/LEGACY` enum and require the §9 U1 capture.

---

## 5. U4 + U5 — uniform value sources (structurally recovered)

### 5.1 Binder call-site table `[O]/[D]`

From `ev_ab75…` (Ghidra) plus `ev_bbdb…` (raw bytes at 0x854080–0x8542f0) and the `e8` call-site scan. `C` = shader object (`param_3`), `D` = 30-key descriptor (`param_1`), `P = C+0x50`, `K` = key string `D+off`.

| bit | uniform key | GL wrapper | **value pushed by caller** `[O]` | donor shipped value `[D]` |
|---|---|---|---|---|
| 7c.1 | reflectionMap | `1i` | `mov ecx,[C+0xf8]` | reflection sampler unit (engine) |
| 7c.2 | waveMap | `1i` | `mov ecx,[C+0xfc]` | 1 (ctor) |
| 7c.4 | **time** | `1f` | `fld qword [C+0xc8]; fmul qword [C+0xc4]; fstp dword [esp]` | see §5.3 |
| 7c.8 | eyePosition | `3f` | `lea ecx,[V+8]` (caller/camera vector) | runtime camera |
| 7c.10 | deepColor | `3f` | `lea ecx,[C+0x68]` | (0,0,0.1255) layer / (0,0,0.1255) ctor |
| 7c.20 | shallowColor | `3f` | `lea ecx,[C+0x78]` | (0,0,0) |
| 7c.40 | reflectionAmount | `1f` | `push [C+0x88]` | 1 (layer) / 0.4 (ctor) |
| 7c.80 | waterAmount | `1f` | `push [C+0x8c]` | 1 / 0.3 |
| 7d.1 | fresnelPower | `1f` | `push [C+0x90]` | 1 / 4.0 |
| 7d.2 | fresnelBias | `1f` | `push [C+0x94]` | 1 / 0.1 |
| 7d.4 | hdrMultiplier | `1f` | `push [C+0x98]` | 1 / 0.5 |
| 7d.8 | waveFreq | `1f` | `push [C+0x9c]` | 0 / 1.0 |
| 7d.10 | waveAmp | `1f` | `push [C+0xa0]` | 0 / 0.05 |
| 7d.20 | distFactor | `1f` | `push [C+0xa4]` | 1 / 2.0 |
| 7d.40 | bumpFactor | `1f` | `push [C+0xa8]` | 1 / 0.01 |
| 7d.80 | texScaleS | `1f` | `push [C+0xac]` | 0.1 / 0.4 |
| 7e.1 | texScaleT | `1f` | `push [C+0xb0]` | 0.01 / 0.825 |
| 7e.2 | waveDir0 | `2f` | `lea ecx,[C+0xb4]` | (−1,0) |
| 7e.4 | waveDir1 | `2f` | `lea ecx,[C+0xbc]` | (−0.7,0.7) |
| 7e.8 | fogEnabled | `1i` | `0` if device byte `V+100+0x8c & 0x80 == 0`, else `byte [ [V+4]+300 +0x28 ] + 1` | computed |
| 7e.10 | hmapTex | `1i` | `mov ecx,[C+0xdc]` | **only if `C+0xe0 != 0 && [C+0xe0+8] != 0`** |
| 7e.20 | hmapW | `1i` | `mov ecx,[C+0xd0]` | same gate |
| 7e.40 | hmapH | `1i` | `mov ecx,[C+0xd4]` | same gate |
| 7e.80 | hmapMin | `1f` | `push [C+0xe4]` | same gate |
| 7f.1 | hmapMax | `1f` | `push [C+0xe8]` | same gate |
| 7f.2 | shadowed | `1i` | 0/1 from `FUN_0081c014/FUN_0081ea54` | shadow-object gate |
| 7f.4 | shadowMap | `1i` | `FUN_0081ea4c(shadowObj)` | shadow-object gate |
| 7f.8 | shadowSize | `1i` | `[shadowObj+0xb4]` | shadow-object gate |
| 7f.10 | shadowColor | `3f` | `lea ecx,[shadowObj+0xe0+0x18]` | shadow-object gate |
| 7f.20 | cameraModel | `Mat4fv` | `mov eax,[C+0xf0]; mov eax,[eax+0xc0]; lea ecx,[eax+0x24]` | custom-shader object matrix |

**Correction to prior art:** `cameraModel` is read from the **custom-shader object** `C+0xf0 → +0xc0 → +0x24`, not from a camera object, and its bind is **inside the `C+0xec != 0` (shadow-object) gate** (`ev_bbdb…` bytes at 0x8542d2 `83 be ec 00 00 00 00 0f 84 …`). This is `[O]`; it matters because with no shadow object the matrix uniform is never bound.

### 5.2 Where the values are written `[O]/[D]`

`FUN_00852f5c(layer, C)` (`ev_513e…`) writes, verbatim:
`C+0x68/6c/70/74 ← layer+0x18/1c/20/24` (DeepColor RGBA); `C+0x78/7c/80/84 ← layer+0x28/2c/30/34` (ShallowColor RGBA); `C+0x88 ← layer+0x38` (reflectionAmount), `+0x8c ← +0x3c` (waterAmount), `+0x90 ← +0x40`, `+0x94 ← +0x44`, `+0x98 ← +0x48`, `+0x9c ← +0x4c`, `+0xa0 ← +0x50`, `+0xa4 ← +0x54`, `+0xa8 ← +0x58`, `+0xac ← +0x5c` (texScaleS), `+0xb0 ← +0x60` (texScaleT), `+0xb4/0xb8 ← +0x64/0x68` (waveDir0), `+0xbc/0xc0 ← +0x6c/0x70` (waveDir1), `+0xc4 ← layer+0x74` (**Speed**). Constructor path default values are listed in §4.2 and `ev_5aae…`. Thus U4 is **closed statically up to which construction path retail uses** (both paths enumerated exactly above).

### 5.3 U5 `time` `[O]/[D]/[U]`

Raw bytes at 0x854091 (`ev_bbdb…`):
```
dd 86 c8 00 00 00   fld  qword [esi+0xc8]     ; shader-object double
d8 8e c4 00 00 00   fmul qword [esi+0xc4]     ; shader-object double = water.lib Speed (1.0)
83 c4 fc            add  esp,-4
d9 1c 24 9b         fstp dword [esp]          ; -> glUniform1f value
```
**[D] `time_uniform = (float)( *(double*)(C+0xc8) * *(double*)(C+0xc4) )`, with `*(float*)(C+0xc4) = Speed = 1.0` from `water.lib` (`ev_513e…`, `ev_227e…`).** `[U]` the writer of the double at `C+0xc8` was not found: the only `fstp qword [reg+0xc8]` instructions in the binary are at 0x50b255/0x50b269/0x50b37a (unrelated object). Constructor zeroes `C+0xc8..0xcf` (`ev_5aae…`), so at construction `time=0`. The same double is used for texture scrolling in `FUN_00856530` (`(float)*(double *)(C+200) * *(float *)(C+0x110)`). **Do not guess a time source; run the §9 U5 experiment.**

---

## 6. U3 — hmap values and `hmapTex` identity

### 6.1 Numeric sources `[O]/[D]`

`FUN_008520a8(shaderCtx, layerObj, field)` (`ev_ada1…`) at draw time:
```
if (layerObj==0 || waterDesc==0 || layerDesc+0xb9 == 0)  // HeightMapEnable
    C+0xe0 = 0;                                  // no height object -> hmap* not bound
else:
    h = FUN_00739bf8(layerObj)
    C+0xe0 = FUN_0082f86c(*(h+0x200))             // engine height object
    C+0xd8 = *(h+0x50)                            // texture target (ctor default 0xde1)
    C+0xd0 = *(layerObj+8)                        // <-- hmapW (uniform 7e.20)
    C+0xd4 = *(layerObj+0xc)                      // <-- hmapH (uniform 7e.40)
    C+0xe4 = (float) FUN_0082f060(*(h+0x200))     // <-- hmapMin (7e.80)
    C+0xe8 = (float) FUN_0082f114(*(h+0x200))     // <-- hmapMax (7f.1)
```
`[D]` The binder gates bits 7e.10–7f.1 on `C+0xe0 != 0 && [C+0xe0+8] != 0` (`ev_ab75…` / `ev_bbdb…` at 0x854250). So the donor's `hmapW/hmapH` are the engine terrain object's `+8/+0xc` and `hmapMin/hmapMax` come from two getters on that object's `+0x200` sub-object. The old port guesses (`map_size/128`, `±2.96`) have **no native basis**.

### 6.2 Texture identity `[U]`

`[O]` the bound sampler integer is `C+0xdc` (ctor default 2) and the height object lives at `C+0xe0`; `FUN_008520a8` gates on `water.lib HeightMapEnable=True`. `[U]` which GL texture name / FBO is attached to that unit, and the numeric `hmapW/H/Min/Max` at a live frame, remain unsettled → §9 U3 experiment. **Do not substitute `heightmapwaves0.tga` or a 1×1 neutral texture.**

---

## 7. U6 — field mesh UV / winding: localized, still `[U]`

- `FUN_00603d30` (`ev_626574ae…`, prior + this ticket) constructs/centres the field and writes Y=offsety; no per-vertex data.
- `FUN_00545e0c` (`ev_74d8…`) asks `FUN_00545d64` (`ev_f2c0…`) for a cached mesh keyed by `(param_2, param_3, float@+0x10, float@+0x18)`; on miss `FUN_00545bd8` (`ev_31d8…`) allocates the mesh record (`+8/+0xc` = key, `+0x28/+0x2c` = size). **There is no water-specific vertex writer.**
- `FUN_00826b30` (`ev_0510…`) issues `glBegin()` + one virtual call `+0x98` per mesh group with args `(caller,1,1)`, then `glEnd`; `glColor4f(1,1,1,1)` when the shader path is inactive.

`[D]` Therefore UVs and triangle winding are inside the **generic mesh-renderer vtable `+0x98`**, shared by all engine meshes, not in water code. Recovering them statically requires identifying the concrete class behind that vtable (RTTI walk + xref), which earlier passes failed to do (PORT1TO1 P15/P16). **Verdict `[U]`; §9 U6 gives the GPU experiment. Port must require the donor UV convention as an explicit parameter, not invent one.**

---

## 8. U12 — reflection FBO: extension support proven, creation path `[U]`

- `[O]` FBO API names are present in CODE: `glGenFramebuffersEXT` 0x4b98d0, `glBindFramebufferEXT` 0x4b98a0, `glFramebufferTexture2DEXT` 0x4b9920, `glCheckFramebufferStatusEXT` 0x4b98e8, `glGenerateMipmapEXT` 0x4b99a4 (`ev_c380…`); also core/ARB spellings 0x4b7080–0x4b7218. There are **no direct FBO imports** — all via `wglGetProcAddress` like the uniform wrappers.
- `[O]` water reflection uses an engine texture object at `C+0x4c` (GL id at `+8`), bound at unit `C+0xf8` only when `FUN_00855fe0()` and `C+0x4c` are valid (`FUN_00856530`, `ev_8218…`); its projective texture matrix is built by `FUN_0085756c` (`ev_2b51…`) using `FUN_004cdd9c(…,0x60,…)`/`FUN_004cdbdc`.
- `[O]` the only `glCopyTexImage2D` call in the binary is inside the **generic** texture-image loader `FUN_004ed38c` @0x4ed44c (`ev_8096…`, thunk `ev_257c…`); many `glCopyTexSubImage2D` calls are generic render-to-texture helpers (0x581444, 0x582b56, 0x5db443, 0x81e66d …). No water-specific FBO creation call was recovered in `FUN_00855b38`/`FUN_00856530`/`FUN_0085756c`.
- `[D]` Hence the reflection target is *an engine texture backing store*, provenance unknown; whether it is an FBO attachment or a `glCopyTexImage2D` framebuffer copy, its dimensions/sampler unit, and whether `DiffuseWaves2` is actually uploaded, are `[U]`.

**Verdict `[U]`; §9 U12 experiment. Port must reject a missing reflection target (error/no water draw), never bind a neutral texture.**

---

## 9. `[U]` register — exact settling experiments (no approximation)

| # | Still-`[U]` item | Static state after this pass | Concrete runtime GPU-capture experiment (owner-authorised) |
|---|---|---|---|
| U1 | Live path (`DEV`/`BUILTIN`/`LEGACY`) and flags | `[D]` shipped config → `C+0x184=0` → CUSTOM off → BUILTIN likely; compile path proven | Break on `FUN_00855b38` (0x855b38) and `FUN_00856530` (0x856530); read `C+0x184`, `C+0xf0`, global `[0x8fc6b8]`, `FUN_00855fe8` globals; hook `glShaderSource` and record whether the source contains `hmapTex` (DEV) or `alphaDepth`/`deepColor` (BUILTIN). GPU frame capture of one water field names the program actually drawn. |
| U3 | Numeric `hmapMin/Max/W/H` + `hmapTex` identity | `[D]` sources = terrain object `+8/+0xc` and getters `FUN_0082f060/0082f114` on `+0x200` object; gate on `C+0xe0` proven | Break on `FUN_00854054` bits 7e.10–7f.1; record the four uniform values, `glActiveTexture`/`glBindTexture` at unit `C+0xdc`, and the GL texture name/FBO attachment. Capture with a field visible. |
| U5 | `time` writer | `[D]` formula = `(float)(double[C+0xc8]*double[C+0xc4])`, `C+0xc4=Speed=1.0`; writer of `C+0xc8` not found | Hook `glUniform1f` on the `time` location from U1; sample across ≥2 frames; if constant, set a write-watchpoint on shader+0xc8 to catch the writer (candidate: per-frame animation updater). |
| U6 | Mesh UV/winding | `[D]` lives in generic vtable `+0x98`, mesh cached by size | Break on virtual `+0x98` from `FUN_00826b30`; dump vertex position/UV arrays and index order for one 2×2 field; or RTTI-walk the concrete mesh class and decompile its `+0x98` method (passes 3–5 still available). |
| U12 | Reflection FBO provenance / sampler units / `DiffuseWaves2` upload | `[O]` FBO names present; reflection object at `C+0x4c`, matrix via `FUN_0085756c`; no water-specific creation found | GPU frame capture at a water draw: record bound framebuffer object, texture name attached to reflection sampler, `glViewport`/matrix from `FUN_004cdd9c`, and uploaded texture names (`DiffuseWaves0/2`). |
| U4* | Which construction path retail uses (ctor defaults vs `water.lib` values) | `[D]` both paths enumerated exactly (§5.1/§5.2) | Break on `FUN_00851bdc` (0x851bdc); record `param_2` (layer pointer) and then `C+0x88..+0xc4`; distinguishes engine defaults from `water.lib` values. |
| U7–U11, U13–U16 | Unchanged from `PORT1TO1_water_shore.md §11` | No new static evidence this ticket | Use those experiments verbatim; this worker captured no donor GPU frame and executed no donor binary. |

**Every one of these is a labelled parameter with no hidden default in the port. Missing value ⇒ error + no water node; never a neutral texture or a guessed constant.**

---

## 10. Exact port changes needed (no edits made — owner/COORD applies)

`[D]` The following are line-level intents for the existing files; this worker only wrote this report.

1. **`variant3d/scripts/water3d.gd`** — replace the "pick a path" logic with an explicit `water_shader_path` enum (`DEV`/`BUILTIN`/`LEGACY`) that has **no default**; if the value is unset or U1's capture is absent, emit an error and **do not add the water node**. Add labelled, unset-by-default parameters for `hmapMin/hmapMax/hmapW/hmapH` and `hmapTex` (U3), `time_source` (U5), reflection target (U12) and mesh UV convention (U6). Delete any `map_size/128`, `±2.96`, `water_surface_y=-0.25`, `water_cell` alpha gate, or `#6E99A8` legacy colour used as a "close enough" value.
2. **`variant3d/shaders/water3d.gdshader`** — keep exactly three mutually exclusive variants per `PORT1TO1_water_shore.md §10.3–5`. For BUILTIN, bind the recovered source fields: `deepColor=mix` inputs from layer `+0x18/+0x28`, `reflectionAmount/waterAmount/fresnelPower/fresnelBias/hdrMultiplier/distFactor/bumpFactor` from shader-object fields `+0x88..+0xa8`, `texScaleS/T` from `+0xac/+0xb0`, `waveDir0/1` from `+0xb4/+0xbc`, `time = float(double[+0xc8]*double[+0xc4])` (U5). Use the `glUniform1f/1i/2f/3f/Mat4fv` semantics of §3; do not collapse to vec4.
3. **`variant3d/scripts/terrain_donor_mesh.gd`** (and the field generator) — compute `hmapW/hmapH` from the engine terrain object's cell dimensions (native `layerObj+8/+0xc`) **only after U3 capture**; until then require them as explicit parameters. Keep field Y = `−0.5`, extents 2×2, one quad per `bWaterMap[wmx,wmy]` per `PORT1TO1_water_shore.md §7`.
4. **Uniform binder** (script or shader-side) — implement the 32-bit enable mask `0x3FFFFFFF` with per-bit gating exactly as §5.1: hmap bits only when a real height object exists; shadow bits only when a real shadow object exists; `fogEnabled` from the device capability byte; `cameraModel` from the custom-shader object matrix and **inside the shadow-object gate** (§5.1 correction). A missing required object ⇒ hard error, no draw.
5. **Reflection** — require an explicit reflection texture/FBO parameter (U12); on absence, error and skip water. Do not bind a generated solid-colour image.
6. **Telemetry** — keep `visual_parity_claim=false`, and record `unresolved=[U1,U3,U5,U6,U12,U4*]` until the corresponding capture is supplied.
7. **QA** (`variant3d/tests/t_water.gd`) — add structural assertions only: mask `0x3FFFFFFF`; scalar field values match §5.2 for the chosen construction path; `time` formula matches §5.3 (value itself unchecked until U5); `cameraModel` bind gated by shadow object; no fallback texture path reachable.

---

## 11. Explicit non-claims and file discipline

- **No parity claim.** No donor binary executed, no GPU frame captured, no port capture compared. All readings are `[O]/[D]/[I]`; all unsettled values are `[U]`.
- **No approximation substituted.** Every previously guessed value is either replaced by a recovered field source (§5) or left as an explicitly labelled `[U]` with a capture experiment (§9).
- **Read-only compliance.** Exactly one repo file written: `docs/terrain_swarm_2026-11-26/reports/DEC_U_water_runtime.md`. No code/shader/asset/config/Godot/git change. Donor helper scripts were written only under `%LOCALAPPDATA%\Temp\opencode\` and only read `cossacks.exe` bytes. Shared Craft Anything investigation memory was read but **not** edited (no brief/plan/hypothesis/finding/handoff writes by this worker). Active target remained `t_87f0f3c130b0` throughout.

*End of DEC-U-WATER-RUNTIME.*
