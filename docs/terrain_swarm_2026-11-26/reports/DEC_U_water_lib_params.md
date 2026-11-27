---
id: DEC-U-WATER-LIB-PARAMS
worker: DEC-U-WATER-LIB (subagent in full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
ticket: "Statically recover exact shipped numeric values for deep/shallow colours, 11 scalars, wave dirs, Speed, MaxHeight, HeightMapEnable, CustomEnable; file-present vs engine-default; U-settling GL captures; port diff list"
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
labels: [O, D, I, U]
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. Donor text files read (water.lib, water.mat, water.dev.vert/frag, generatemap.inc, texturemap.inc) via repo-side file reads only. No donor binary executed, copied, committed, or written. No donor file modified."
scope_guard: "No repo code/asset/config/shader/Godot/git edit. Exactly one repo file written: this report."
multi_pass: true
visual_parity_claim: false
upstream: "DEC_U_water_runtime.md §§4/5; DEC_U_final_register.md W-U1/U3/U4*/U5/U6/U12 (P0-1/P0-2); PORT1TO1_water_shore.md §§3/4/5; DEC_U_water_mesh_uv.md; DEC_U_water_fbo.md"
---

# DEC-U-WATER-LIB-PARAMS — exact shipped water.lib numerics: file-present vs engine-default (2026-11-26)

## 0. Authority and discipline (read first)

Every statement below is `[O]` (verbatim donor bytes/text or verbatim port file line), `[D]` (deterministic control-flow/arithmetic from `[O]`), `[I]` (interpretation) or `[U]` (UNVERIFIED — a concrete zero-mismatch settling capture is given in §6; the port must **hard-fail, never invent a scalar**). Pin `t_87f0f3c130b0` throughout.

This worker issued **no Craft Anything native calls** (subagent context: only repo/doc/donor-text reads via default tools). All binary addresses, VA cites and evidence ids below are **re-cited pinned records** from `DEC_U_water_runtime.md` / `PORT1TO1_water_shore.md` / `DEC_U_water_mesh_uv.md` / `DEC_U_water_fbo.md`, each originally pinned `document:"t_87f0f3c130b0"`, Deep mode (Ghidra 12.2 pseudocode + built-in 0.6.1 bytes). No new decompilation lift was performed by this worker; no donor binary was executed; no GPU frame was captured; no parity claim is made. Active donor target was never opened/selected/closed by this worker.

**Single most important result:** all 11 layer scalars + colours + wave dirs + `Speed` + `CustomEnable` + `HeightMapEnable` are recovered **verbatim from `data/water/water.lib`** with file:line cites below, and both construction paths (`FUN_00856080` ctor defaults vs `FUN_00852f5c` layer copy) are enumerated. Colours and `Speed` converge on both paths → `[D]` settled. The 11 scalars **diverge** between ctor engine-defaults and layer file values → `[U]` pending U4* (which construction path retail uses). `MaxHeight` is **not in water.lib at all** — the only donor `MaxHeight` literal is `texturemap.inc:29 cMaxHeight=2.96` (classification), while live `hmapMin/Max` come from engine getters — so any port `±2.96` hmap span is a labelled substitute, not a recovered value. `CustomEnable=False` forces `C+0x184=0` on both paths → CUSTOM branch unreachable `[D]`.

---

## 1. Pass ledger (owner rule ≤5 passes/function; every pass logged)

| # | Function / question | Passes this ticket | Result / accepted? |
|---|---|---|---|
| P1 | `data/water/water.lib` full re-read (file:line) | 1 repo-side read (71 lines) | **Accepted**: all layer/file values verbatim (§2) |
| P2 | `data/water/water.mat` re-read | 1 repo-side read | **Accepted**: `DiffuseWaves0/2` live, `HeightMapWaves0` commented `[O]` |
| P3 | `data/shaders/water/water.dev.vert` + `water.dev.frag` re-read | 1 repo-side read each | **Accepted**: VP UV equation, FP live constants/colours, commented-out uniforms (§2.5) |
| P4 | `data/scripts/common.inc/generatemap.inc:647-704` + `texturemap.inc:29-31` re-read | 1 repo-side grep each | **Accepted**: `cOffsetY=-0.5`, `cMaxHeight=2.96`, `cWaterHeight=-0.25`, `cWaterShoreHeight=-0.1` (§2.6) |
| P5 | `FUN_00852298` @0x852298 (layer descriptor parser) | 1 re-read: `ev_8d7668eb6078e5d6b4f38748683eef0096f61f7fd38e5aea0af3321ebcd4c199` | **Accepted**: 47 `waters` keys → field offsets +0x04..+0xf8 |
| P6 | `FUN_00853150` @0x853150 (file keys) | 1 re-read: `ev_68633b8db084fecdc9055e8647afa43a1ab45edaf6dd8c132ffe4fe5a5afda` | **Accepted**: +0x0c/+0x10/+0x14/+0x18/+0x1c |
| P7 | `FUN_00856080` @0x856080 (ctor) | 1 re-read: `ev_5aaec0315458ec67490ef87ee4c2c2f70f72e65aef9fbaaacdfbc718ac2de3787` + `ev_d9277ee31a563b52091b6bebce7877657b0d2e258139fc2e9955ec8eaa49cbca` | **Accepted**: engine defaults incl. `+0x184=0`, `+0xe0/+0xec=0`, `+0xc8..0xcf=0`, scalars `0.4/0.3/4/.1/.5/1/.05/2/.01/.4/.825`, `+0xc4=1.0f` |
| P8 | `FUN_00852f5c` @0x852f5c (layer copy) | 1 re-read: `ev_513eeafe38634fbcdc522d1db8484a0f84f018b6e59a0f58983d37c7202338` | **Accepted, decisive**: `CustomEnable→C+0x184`, colours/waves/scalars/Speed map |
| P9 | `FUN_00854054` @0x854054 (binder) | 1 re-read: `ev_ab751f818e4b8839b5f6d60152283cfd960776db078f0ed7cea91aed7cba91b0641` + raw bytes 0x854080–0x8542f0 `ev_bbdba234fcbb85df996f0f2e5ed4b1df1aaa00f02c95c3861160cc201851db7a` | **Accepted, decisive**: per-bit value sources; time `fld/fmul/fstp` at 0x854091 |
| P10 | `FUN_00851bdc` @0x851bdc + `FUN_00856530` @0x856530 (path select) | 1 re-read: `ev_67a5083d1de168ff448c44405a905f4d010e3f873fcb249547cac621a03c28b` + `ev_8218b0f1aa21aefba779cac21107bff799438a4c5245953770eab6bcbc8642` | **Accepted**: layer==0→ctor else layer copy; CUSTOM needs `C+0x184!=0 && [0x8fc6b8]!=0` |
| P11 | `FUN_008520a8` @0x8520a8 (hmap staging) | 1 re-read: `ev_ada19843eaa6b989e47f1d8dd8a5c512875c5ef290b66241b73905af4e63852b` | **Accepted**: hmap gate/fields |
| P12 | Port files `variant3d/scripts/water3d.gd` + `variant3d/shaders/water3d.gdshader` | 1 repo read each (this ticket, repo HEAD) | **Accepted as `[O]`**: line intents for §7 diff |

No function exceeded prior + current pass budget. No `sub_8519f4` re-lift (prior `ev_d41c…` rejected as garbled; not used).

---

## 2. Shipped file values `[O]` — verbatim with file:line

Donor root in all cites: `C:\Games\Cossacks 3\data\`.

### 2.1 `water/water.lib` layer block (file lines 4–61)

| Param (this report) | water.lib key | water.lib line | Verbatim value `[O]` | Descriptor offset `[O]` (`ev_8d76…`, `FUN_00852298`) |
|---|---|---|---|---|
| DeepColor RGBA | `DeepColor.Red/Green/Blue/Alpha` | :9–:13 | **0 / 0 / 0.1255 / 0.5** | `+0x18/+0x1c/+0x20/+0x24` |
| ShallowColor RGBA | `ShallowColor.Red/Green/Blue/Alpha` | :15–:19 | **0 / 0 / 0 / 0.5** | `+0x28/+0x2c/+0x30/+0x34` |
| S1 ReflectionAmount | `ReflectionAmount` | :21 | **1** | `+0x38` |
| S2 WaterAmount | `WaterAmount` | :22 | **1** | `+0x3c` |
| S3 FresnelPower | `FresnelPower` | :23 | **1** | `+0x40` |
| S4 FresnelBias | `FresnelBias` | :24 | **1** | `+0x44` |
| S5 HDRMultiplier | `HDRMultiplier` | :25 | **1** | `+0x48` |
| S6 WaveFreq | `WaveFreq` | :26 | **0** | `+0x4c` |
| S7 WaveAmp | `WaveAmp` | :27 | **0** | `+0x50` |
| S8 DistFactor | `DistFactor` | :28 | **1** | `+0x54` |
| S9 BumpFactor | `BumpFactor` | :29 | **1** | `+0x58` |
| S10 TexScaleS | `TexScaleS` | :32 | **0.1** (commented `//TexScaleS = 0.115` at :30 is inert) | `+0x5c` |
| S11 TexScaleT | `TexScaleT` | :33 | **0.01** (commented `//TexScaleT = 0.015` at :31 is inert) | `+0x60` |
| WaveDir0 XY | `WaveDir0.X/Y` | :34–:36 | **−1 / 0** | `+0x64/+0x68` |
| WaveDir1 XY | `WaveDir1.X/Y` | :38–:40 | **−0.7 / 0.7** | `+0x6c/+0x70` |
| Speed | `Speed` | :42 | **1.0** | `+0x74` |
| Width / Height / Offset | `Width/Height/Offset` | :47–:49 | **1 / 1 / 0.495** | `+0x80/+0x84/+0x88` |
| LayerCount | `LayerCount` | :50 | **1** | `+0x8c` |
| CustomEnable | `CustomEnable` | :51 | **False** | `+0x90` → `C+0x184` (`ev_513e…`) |
| CustomShaderID | `CustomShaderID` | :52 | **0** | `+0x94` → `C+0x188` |
| CustomReflection | `CustomReflection` | :53 | **False** | `+0x9c` → `C+0x191` |
| CustomReflectionUnit | `CustomReflectionUnit` | :54 | **0** | `+0xa0` |
| CustomTexCoord / Scale | `CustomTexCoord/CustomTexCoordScale` | :56–:57 | **True / 1** | `+0xa8/+0xac` |
| CustomTexReflectMatrix / Unit | `CustomTexReflectMatrix/CustomTexReflectMatrixUnit` | :58–:59 | **False / 0** | `+0xb0/+0xb4` → `C+0x1a8` (`ev_513e…`) |
| HeightMapEnable | `HeightMapEnable` | :60 | **True** | `+0xb9` (gate in `FUN_008520a8`, `ev_ada1…`) |
| ShadowMapEnable | `ShadowMapEnable` | :61 | **True** | `+0xc0` (gate in binder 0x8542d2, `ev_bbdb…`) |
| MaxDepth / MinDepth | `MaxDepth/MinDepth` | :5–:6 | **1 / 0** | `+0x08/+0x0c` |
| MaxAlpha / MinAlpha | `MaxAlpha/MinAlpha` | :7–:8 | **1.1 / 0** | `+0x10/+0x14` |
| Normal/DiffuseMapLibMaterialName | `NormalMapLibMaterialName/DiffuseMapLibMaterialName` | :43–:44 | **`DiffuseWaves2` / `DiffuseWaves0`** (commented `HeightMapWaves0` at :45 inert) | `+0x78/+0x7c` |

### 2.2 `water/water.lib` file block (lines 64–70)

| Param | Line | Value `[O]` | Offset `[O]` (`ev_6863…`, `FUN_00853150`) |
|---|---|---|---|
| MaterialLibraryFileName | :64 | `.\data\water\water.mat` | `+0x0c` |
| DefaultWaterIndex | :65 | **0** | `+0x10` |
| Tag | :66 | **512** | `+0x14` |
| VertexProgramFileName | :67 | `.\data\shaders\water\water.dev.vert` | `+0x18` |
| FragmentProgramFileName | :68 | `.\data\shaders\water\water.dev.frag` | `+0x1c` |
| LOD VP/FP | :69–:70 | empty | `+0x20/+0x24` |

### 2.3 `water/water.mat` texture provenance `[O]`

Live: `Name = DiffuseWaves0`, `Image = .\data\water\textures\diffusewaves0.bmp`, `TextureFormat = tfLuminance`, `TextureWrap = twBoth`; `Name = DiffuseWaves2`, `Image = .\data\water\textures\diffusewaves2.bmp` (refkey=base override). Commented-out (inert, `//`-prefixed): `DiffuseWaves1/3/4/5/6/7` and the entire `HeightMapWaves0` (`heightmapwaves0.tga`, `tfNormalMap`) block. `[D]` No live height/wave texture binding for `hmapTex` is proven by this file; `heightmapwaves0.tga` must not be substituted (D06 P18: alpha 255 everywhere).

### 2.4 Constructor `FUN_00856080` @0x856080 engine defaults `[O]` (`ev_5aae…`, `ev_d927…`)

`C+0x184=0`, `C+0x190=0`, `C+0xe0=0`, `C+0xec=0`, `C+0xc8..0xcf=0` (time double = 0 at construction); colours at `C+0x68`/`C+0x78` RGBA with A=0.5; scalars: `C+0x88=0.4, +0x8c=0.3, +0x90=4.0, +0x94=0.1, +0x98=0.5, +0x9c=1.0, +0xa0=0.05, +0xa4=2.0, +0xa8=0.01, +0xac=0.4, +0xb0=0.825`; `C+0xc4=1.0f` (Speed slot); `C+0xd8=0xde1` (`GL_TEXTURE_2D`), `C+0xdc=2`, `C+0xf8=0`, `C+0xfc=1`.

### 2.5 Shader text cross-check `[O]`

- `water.dev.vert:16-18`: `gl_TexCoord[1].x=gl_MultiTexCoord0.x/hmapW-0.5`, `.y=.../hmapH-0.5`, `.z=pos.y` (plane Y = donor `WATER_LEVEL`). `water.dev.vert:6`: `cameraModel` mat4; `:22`: `lightVector=(x/4, z/2, y/1)`.
- `water.dev.frag:8-16`: `deepColor/shallowColor/reflectionAmount/waterAmount/fresnelPower/fresnelBias/distFactor/bumpFactor` are **commented out** (dead in shipped pair); live: `hdrMultiplier` (:14), `texScaleS/T` (:2–3), `fogEnabled` (:23). Live constants: `:37` coast `0.57`, `:38-44` `0.50/2.0/0.5/0.5/170.0/120.0/30.0`, `:45` `(0.1,0.24,0.24)`, `:46` `(0,0.025,0.05)`, `:47` `(0.4,0.4,0.4)`, `:168` deep fade `0.5+0.57=1.07`.
- Embedded pair (`FUN_00854ac0` `ev_5dc9…` VA 0x8552xx / `FUN_008551d8` `ev_ce22…` VA 0x8557xx; compiled by `FUN_00855b38` @0x855b38 `ev_a66a…` into program `C+0x50`): VP defaults `texScaleS 0.01 / texScaleT 0.02`, `wave[0]=(waveFreq,waveAmp,0.5,waveDir0)`, `wave[1]=(3*waveFreq,0.33*waveAmp,1.7,waveDir1)` — these are **pre-bind source defaults**, not live uniforms after `FUN_00854054` binds.

### 2.6 Script constants (NOT water.lib) `[O]`

- `generatemap.inc:688`: `const cOffsetY = -0.5` (plane Y arg to `WaterFieldAdd` at :704). `:649-650`: `cWaterFieldSize=2`, `cWaterMapArrSize=(640 div 2)=320`. `:689`: `mapsizemod=(cWaterMapArrSize/((640/mapheight)*2))*cWaterFieldSize` (float outer division; integer variant commented).
- `texturemap.inc:29-31`: `cMaxHeight=2.96`, `cWaterHeight=-0.25` (classification), `cWaterShoreHeight=-0.1` (classification gate). These are **script-stage classification literals**, never `hmapMin/Max` or plane Y.

---

## 3. File-present vs engine-default ledger (the task's core table)

`File` = `water.lib` verbatim (§2.1–2.2). `Engine` = `FUN_00856080` ctor slot (§2.4). `Live` = value after `FUN_00851bdc` branch (`ev_67a5…`: layer==0→ctor, else `FUN_00852f5c` layer copy `ev_513e…`). Binder row = `FUN_00854054` bit (`ev_ab75…`).

| # | Uniform / param | Binder bit/type `[O]` | File-present `[O]` | Engine-default (ctor) `[O]` | Live verdict |
|---|---|---|---|---|---|
| C1 | deepColor RGBA | 7c.10 `V3(C+0x68)` | **(0,0,0.1255,0.5)** lib :9–13 | (0,0,0.1255,0.5) | **`[D]` settled 0,0,0.1255,0.5** — converges both paths |
| C2 | shallowColor RGBA | 7c.20 `V3(C+0x78)` | **(0,0,0,0.5)** lib :15–19 | (0,0,0,0.5) | **`[D]` settled 0,0,0,0.5** — converges both paths |
| S1 | reflectionAmount | 7c.40 `1f(C+0x88)` | **1** lib :21 | 0.4 | `[U]` → U4* |
| S2 | waterAmount | 7c.80 `1f(C+0x8c)` | **1** lib :22 | 0.3 | `[U]` → U4* |
| S3 | fresnelPower | 7d.01 `1f(C+0x90)` | **1** lib :23 | 4.0 | `[U]` → U4* |
| S4 | fresnelBias | 7d.02 `1f(C+0x94)` | **1** lib :24 | 0.1 | `[U]` → U4* |
| S5 | hdrMultiplier | 7d.04 `1f(C+0x98)` | **1** lib :25 | 0.5 | `[U]` → U4* |
| S6 | waveFreq | 7d.08 `1f(C+0x9c)` | **0** lib :26 | 1.0 | `[U]` → U4* |
| S7 | waveAmp | 7d.10 `1f(C+0xa0)` | **0** lib :27 | 0.05 | `[U]` → U4* |
| S8 | distFactor | 7d.20 `1f(C+0xa4)` | **1** lib :28 | 2.0 | `[U]` → U4* |
| S9 | bumpFactor | 7d.40 `1f(C+0xa8)` | **1** lib :29 | 0.01 | `[U]` → U4* |
| S10 | texScaleS | 7d.80 `1f(C+0xac)` | **0.1** lib :32 | 0.4 | `[U]` → U4* |
| S11 | texScaleT | 7e.01 `1f(C+0xb0)` | **0.01** lib :33 | 0.825 | `[U]` → U4* |
| W0 | waveDir0 XY | 7e.02 `2f(C+0xb4)` | **(−1,0)** lib :34–36 | not enumerated in `ev_5aae…`/`ev_d927…` | `[U]` file value; engine slot unknown → U4* |
| W1 | waveDir1 XY | 7e.04 `2f(C+0xbc)` | **(−0.7,0.7)** lib :38–40 | not enumerated | `[U]` file value; engine slot unknown → U4* |
| SP | Speed | — (`C+0xc4`, time factor) | **1.0** lib :42 | 1.0f | **`[D]` settled 1.0** — converges both paths; `time_uniform=(float)(dbl[+0xc8]*dbl[+0xc4])` at 0x854091 (`ev_bbdb…`) |
| HE | HeightMapEnable | gate `C+0xe0` (`FUN_008520a8`) | **True** lib :60 | `C+0xe0=0` (no height object until draw staging) | `[D]` file True; runtime gate proven, numeric hmap values `[U]` → U3 |
| CE | CustomEnable | `C+0x184=layer+0x90` | **False** lib :51 | `C+0x184=0` | **`[D]` settled: `C+0x184=0` on both paths → CUSTOM branch (`FUN_00856530` needs `C+0x184!=0 && [0x8fc6b8]!=0`) unreachable from shipped config** |
| MH | MaxHeight | — (absent from water.lib) | **absent** (no `MaxHeight` key in 71-line file) | n/a | `[U]` → U3. Only donor literal is `texturemap.inc:29 cMaxHeight=2.96` (classification, NOT hmapMin/Max). `hmapMin/Max` live in `C+0xe4/+0xe8` via `FUN_0082f060/0082f114` on `+0x200` object (`ev_ada1…`); `hmapW/H` = terrain `+8/+0xc` |
| FI | DefaultWaterIndex / Tag / programs | — | **0 / 512 / water.dev.vert+frag** lib :65–68 | n/a | `[D]` file values; program selection still `[U]` → U1 (global `[0x8fc6b8]` + `FUN_00855fe8` globals unproven) |

`[D]` No value above is guessed: every file number carries its line; every engine number carries its ctor evidence id; every divergence is labelled `[U]` with its §6 capture.

---

## 4. Which construction path retail uses (U4*) `[D]`-bounded, `[U]`-residual

`FUN_00851bdc` (`ev_67a5…`): `layerPtr==0 → FUN_00856080` (ctor/engine defaults); else `FUN_00852f5c(layerPtr, C)` (layer copy: `C+0x68..+0xc4 ← layer+0x18..+0x74`, `C+0x184 ← layer+0x90`, `C+0x188 ← +0x94`, `C+0x191 ← +0x9c`, `C+0x190 ← +0xb8`, `C+0x1a8 ← +0xb4`; `ev_513e…`). Shipped `water.lib` has exactly one layer (`LayerCount=1` lib :50, `DefaultWaterIndex=0` lib :65), so the layer-copy source is the §2.1 block **iff** the caller passes a nonzero layer pointer. Whether retail's water-draw call passes 0 or the parsed layer is **not statically proven** — that single pointer is U4*. Consequence: C1/C2/SP/CE are path-insensitive (`[D]` above); S1–S11/W0/W1 are path-sensitive (`[U]`, exactly two candidate tuples enumerated, no third option).

---

## 5. Time accumulator writer (U5) `[D]` formula, `[U]` writer

Raw bytes at 0x854091 (`ev_bbdb…`): `fld qword [esi+0xc8]; fmul qword [esi+0xc4]; fstp dword [esp]` → `glUniform1f(time)`. `[D]` `time_uniform = (float)(*(double*)(C+0xc8) * *(double*)(C+0xc4))`, `C+0xc4 = Speed = 1.0` file-present (lib :42) and ctor 1.0f (converged). Ctor zeroes `C+0xc8..0xcf` (`ev_5aae…`) so `time=0` at construction. The only `fstp qword [reg+0xc8]` hits in the binary (0x50b255/0x50b269/0x50b37a) belong to an unrelated object (DEC_U_water_runtime §5.3). Writer of water `C+0xc8` is `[U]` → §6 U5. Same double feeds texture scroll in `FUN_00856530` (`(float)*dbl[+0xc8] * float[+0x110]`).

---

## 6. `[U]` register — GL uniform-capture experiments with zero-mismatch termination

Owner-authorised donor GPU session only (RenderDoc/apitrace/Nsight-GL or debugger + GL hooks). Forbidden to workers. Every row: break site + trace + byte-exact comparison. **Zero-mismatch rule**: the stated tuple must repeat with **0 differing bits/elements** across the stated sample; any mismatch or missing dump leaves the item `[U]` and the port keeps hard-failing / keeps the labelled substitute. Never invent a scalar. Gating precondition for every row: a water field visible (break `FUN_00603d30` @0x603d30, read `[ebp+0x1c]`) and the live path identified first (U1: hook `glShaderSource`; `hmapTex` present = DEV file pair, `alphaDepth`/`deepColor` = BUILTIN embedded pair).

| # | Still-`[U]` value | Static state after this ticket | Capture experiment (break + trace) | Termination |
|---|---|---|---|---|
| U1 | Live path DEV/BUILTIN/LEGACY; globals `[0x8fc6b8]`, `FUN_00855fe8` triple (`0x8fcdb0/0x8fbd28/0x8fc748`), `C+0x184` | `[D]` shipped config → `C+0x184=0` → CUSTOM unreachable; compile path `FUN_00855b38` @0x855b38 proven | Break `FUN_00855b38` + `FUN_00856530` @0x856530; record `C+0x184`, `C+0xf0`, `C+0x50`, globals; hook `glShaderSource`/`glCompileShader`, record source text + program hash; GPU frame capture of one water field names the drawn program | `(PATH, C+0x184, globals, program-hash)` identical, 0 mismatches, 2 draws + 1 camera move |
| U4* | Which tuple is live: engine S1–S11/W0/W1 (ctor) vs file S1–S11/W0/W1 (§3) | `[D]` exactly two candidate tuples, no third | Break `FUN_00851bdc` @0x851bdc; record `param_2` layer pointer; then dump `C+0x88..+0xc4` scalar block + `C+0xb4/+0xbc` dirs; hook `glUniform1f` S1–S11 + `glUniform2f` W0/W1 on the U1 program, record floats across first water draw | Layer-ptr nonzero + uniform tuple == §2.1 file tuple bit-exact, OR layer-ptr zero + tuple == §2.4 engine tuple; identical 0-ULP across 2 frames + move. Until then port exposes both tuples labelled, defaults to neither silently |
| U3-NUM | Numeric `hmapMin/Max/W/H` at live frame | `[D]` sources: `W/H` = terrain `+8/+0xc`, `Min/Max` = `FUN_0082f060/0082f114` on `+0x200` obj; gate `C+0xe0!=0 && [C+0xe0+8]!=0` | Break `FUN_00854054` bits 7e.10–7f.1 with field visible; record 4 pushed values (`C+0xd0/+0xd4` ints, `C+0xe4/+0xe8` floats) + gate values | Same 4-tuple, 0 differing bits, 2 frames + move. Then those 4 numbers (not `map_size/±2.96`) become the port parameters |
| U3-TEX | `hmapTex` GL identity (name/target/provenance) | `[O]` unit `C+0xdc` (ctor 2), target `C+0xd8` (ctor `0xde1`); `[U]` bound name | Same break: `glActiveTexture(GL_TEXTURE0+u)` at unit `C+0xdc`, `glBindTexture`, `glGetTexLevelParameteriv(name,0,WIDTH/HEIGHT/INTERNAL_FORMAT)`; FBO-attachment vs upload history | Same `(target,name,w,h)`, 0 mismatches, 2 frames. Unknown provenance ⇒ keep `bind_height_grid` substitute labelled `[U3]`, never art/`heightmapwaves0.tga`/neutral texel |
| U5 | `C+0xc8` writer + live `time` values | `[D]` formula + `Speed=1.0`; `[U]` writer | Hook `glUniform1f(time)` ≥3 frames over ≥2 s; if non-constant, HW write-watchpoint on shader `+0xc8` (8 B) → writer EIP + disassembly | Constant `0.0` (0 differing samples, 10 s window, watchpoint never fires) → `time=0 [D]`-by-capture; else single writer EIP every frame, 0 missed frames, formula reproduces uniform with 0 ULP error |
| U6-UV | Dividend behind `MultiTexCoord0/(hmapW,H)−0.5` (`water.dev.vert:16-17`) | `[D]` divisor + verbatim −0.5; `[U]` dividend array | Break virtual `+0x98` from `FUN_00826b30` @0x826b30 (loop `ev_0510…`); dump `MultiTexCoord0` array (4 verts, float32) + `hmapW/H` uniforms same frame; read back `gl_TexCoord[1].xy` | `max\|uv_pred−uv_actual\|==0.0` bit-exact, 4 verts, ≥2 fields + move |
| U6-WIND | Triangle winding/diagonal/culling | `[O]` `glBegin(4)`=TRIANGLES, 2 tris/quad; `[U]` order + cull | Same `+0x98` break: dump index array (or `glDrawArrays` first/count) + `glGetIntegerv(GL_CULL_FACE/GL_FRONT_FACE)` trace | Index sequence 0 mismatches ≥2 fields; cull state identical 2 frames |
| U12 | Reflection provenance / unit `C+0xf8` / matrix (`FUN_0085756c` +0x60) / `DiffuseWaves2` alias / pbuffer | `[O]` object `C+0x4c` (id `+8`), bind gate `FUN_00855fe0()+C+0x4c`, FBO names (`ev_c380…` 0x4b98xx); `[U]` provenance/size/matrix | Apply `DEC_U_water_fbo.md` §8 U12-A/B/C/T/S/P verbatim (FBO-attachment vs copy-dst vs static-upload test, unit hook, `+0x60` matrix + viewport dump, waves-alias check, `wglMakeCurrent`/pbuffer sweep) | Identical `(provenance_class,name,w,h,unit,matrix)`, 0 mismatches, 2 frames + move; any gap ⇒ keep `water3d.gd:520-527` hard-fail + `reflectionMapBound=false` |

U7–U11/U13–U16 use `DEC_U_final_register.md` §§1–5 experiments verbatim (plane-Y `[ebp+0x1c]` read, DScript thunk trace, smooth-pass count, blend-factor hook, `MapDrawCollision` xref, donor A/B frame, FogMode sweep, `fWaterStates` dump, editor literal diff). This worker captured no donor frame and executed no donor binary.

---

## 7. Exact port change list — `water3d.gd` / `water3d.gdshader` (file:line; NO edits made — owner applies)

All lines verified by repo read this ticket (HEAD with local modifications present; paths below are the shipped files). Wire only captured reals. Preserve the BUILTIN labelled default and the U12 hard-fail in every diff. `visual_parity_claim=false` stays.

1. **`variant3d/scripts/water3d.gd:85-87` (`LIB_DEEP_COLOR/LIB_SHALLOW_COLOR`) + `:638-639` (BUILTIN bind)** — KEEP AS-IS. Values `(0,0,0.1255,0.5)` / `(0,0,0,0.5)` are `[D]` path-insensitive settled (§3 C1/C2: lib :9–19 = ctor). No change required beyond retaining cites.
2. **`variant3d/scripts/water3d.gd:640-647` (S1–S9 binds) + `water3d.gdshader:112-119`** — LABEL, DO NOT SILENTLY KEEP. Current `1/1/1/1/1/0/0/1/1` + `waveDir0/1 (-1,0)/(-0.7,0.7)` equal the **file tuple** (lib :21–29/:34–40) but the **engine tuple** (0.4/0.3/4/0.1/0.5/1/0.05/2/0.01) is equally live until U4*. Required diff: add a `water_scalar_source` enum (`FILE`/`ENGINE`, no default; unset ⇒ `push_error` + no water) and select the tuple from §3; record the U4* capture id in `stats`. Never hard-code one tuple as "the" donor value.
3. **`variant3d/scripts/water3d.gd:650-651` (`texScaleS/T`) + `water3d.gdshader:122-123`** — CORRECT AFTER U4*. Current BUILTIN `0.01/0.02` are the **embedded VP pre-bind source defaults** (§2.5), NOT live uniforms under either construction path (file `0.1/0.01` lib :32–33 vs engine `0.4/0.825`). Required diff: after the U4* capture, bind the captured tuple's S10/S11 (`0.1/0.01` if FILE wins); until then keep current values but re-label them `EMBEDDED-SOURCE-DEFAULT [U4*]`, never present as recovered live uniforms. Same for DEV `TEX_SCALE_S/T` at `water3d.gd:71-72` + shader `:53-54` (DEV shader reads `texScaleS/T` live — file tuple applies iff U4*=FILE).
4. **`variant3d/scripts/water3d.gd:648-649` (`waveDir0/1`) + `water3d.gdshader:120-121`** — KEEP VALUES, ADD LABEL. `(-1,0)/(-0.7,0.7)` = file tuple (lib :34–40); engine slots unenumerated → keep values but gate on U4*=FILE; if U4*=ENGINE, replace with captured engine dirs (no invention).
5. **`variant3d/scripts/water3d.gd:251` (`_time += delta`) + `water3d.gdshader:78` (`time`)** — KEEP SCAFFOLDING, ADD FORMULA COMMENT. After U5 capture only: replace with captured writer (or freeze `0.0` if U5 terminates constant) while keeping comment `time=(float)(dbl[+0xc8]*dbl[+0xc4]), Speed=1.0 (lib :42; 0x854091 ev_bbdb…)`. Until then keep `_time` + `[U5]` labels (`water3d.gd:120/218-219/719`). Cross-ref `water3d.gdshader:177/248` (`time*0.1/0.01` scroll uses same accumulator).
6. **`variant3d/scripts/water3d.gd:508-511` (`hmapW/H/Min/Max`) + `water3d.gdshader:126-129,168-171,187,276,400-401`** — KEEP SUBSTITUTE, KEEP `[U3]` LABELS. `_grid_w/_grid_h`, `-MAX_HEIGHT/+MAX_HEIGHT` are port substitutes; `MAX_HEIGHT=2.96` cites `texturemap.inc:29` (classification), NOT water.lib. After U3-NUM/TEX capture only: replace divisor with captured `hmapW/H`, span with captured `hmapMin/Max`, `height_tex`/`hmapTex` alias with captured `(target,name)` (FBO import or captured copy target — never generated solid-colour, never `diffusewaves`/`heightmapwaves0` art unless U12-S proves identity). Forbidden lines stay: `water3d.gd:138-145/216-217/502-511/717/755`, shader `:68-72/:77`.
7. **`variant3d/scripts/water3d.gd:163` + `water3d.gdshader:102` (BUILTIN labelled default)** — KEEP AS-IS. Basis `[D]` §3 CE (`CustomEnable=False` lib :51 → `C+0x184=0` both paths → CUSTOM unreachable at `FUN_00856530` @0x856530). Do not flip to DEV/LEGACY without the U1 capture; `set_shader_path()` (`water3d.gd:290-303`) stays the explicit authority.
8. **`variant3d/scripts/water3d.gd:343-353` + `:520-527` + `water3d.gdshader:107-108,365-366` (U12 hard-fail)** — KEEP AS-IS until U12-A/B/C/T all captured. Then extend `bind_reflection_map` to validate captured `(w,h,unit)` and require matrix U12-T; keep `reflectionMapBound=false` default + `discard`. Never call `bind_reflection_map()` from `_make_water3d` with a non-captured texture.
9. **`variant3d/scripts/water3d.gd:740-751` (`donor_water_lib_proven`)** — EXTEND WITH §2 CITES. Current block already matches §2.1 values; required diff: append per-key `water.lib:<line>` cites + `MaxDepth=1/MinDepth=0/MaxAlpha=1.1/MinAlpha=0` (lib :5–8) + `Width/Height=1/1, Offset=0.495` (lib :47–49, with comment "NOT plane Y") + `HeightMapEnable=True` (lib :60) + `CustomEnable=False` (lib :51) + note `MaxHeight ABSENT from water.lib; 2.96 = texturemap.inc:29 classification`.
10. **FORBIDDEN (violates donor faithfulness):** presenting `0.01/0.02` as live `texScaleS/T`; presenting `±2.96` or `map_size/128` as `hmapMin/Max/W/H`; aliasing `reflectionMap`/`hmapTex` to `diffusewaves*`/`heightmapwaves0`/neutral texel; inventing a winding order, `fract(world*0.5)` dividend, `*0.5+0.5` bias, viewport-sized target, pbuffer, or time source; flipping the default off BUILTIN to "make water appear"; adding a water node when any required `[U]` binding is missing.

---

## 8. Explicit non-claims and file discipline

- **No parity claim.** No donor binary executed, no GPU frame captured, no port capture compared by this worker. All readings are `[O]/[D]` re-cited or repo-side donor-text `[O]`; all unsettled values are `[U]` with §6 captures.
- **No approximation substituted.** Every previously guessed scalar is either replaced by its recovered file/engine source (§3) or left as an explicitly labelled `[U]` with a zero-mismatch capture (§6). `Speed=1.0`, colours, `CustomEnable`, file `HeightMapEnable` are the only numerics promoted to `[D]`; all else stays gated.
- **Read-only compliance.** Exactly one repo file written: `docs/terrain_swarm_2026-11-26/reports/DEC_U_water_lib_params.md`. No code/shader/asset/config/Godot/git change. No donor file opened for write or executed. No Craft Anything investigation memory written. Donor text reads used repo-side file access only (`water.lib:1-71`, `water.mat`, `water.dev.vert:1-30`, `water.dev.frag:1-80`, `generatemap.inc:647-704`, `texturemap.inc:29-31`).

*End of DEC-U-WATER-LIB-PARAMS.*
