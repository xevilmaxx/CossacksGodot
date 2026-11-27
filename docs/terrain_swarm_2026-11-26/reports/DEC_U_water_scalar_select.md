---
id: DEC-U-WATER-SCALAR-SELECT
worker: DEC-U-WATER-SCALAR (subagent in full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
ticket: "Statically settle U4* — which scalar tuple (or per-scalar mix) is actually bound at draw time in retail skirmish"
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
labels: [O, D, I, U]
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. Donor text files read via repo-side reads only. Donor binary never executed, copied, committed, or written. No donor file modified."
scope_guard: "No repo code/asset/config/shader/Godot/git edit. Exactly one repo file written: this report."
multi_pass: true
visual_parity_claim: false
upstream: "DEC_U_water_lib_params.md (FILE 1/1/1/1/1/0/0/1/1/0.1/0.01 vs ENGINE 0.4/0.3/4/0.1/0.5/1/0.05/2/0.01/0.4/0.825); DEC_U_water_runtime.md (FUN_00851bdc / FUN_00854054 / FUN_00856530 / FUN_008520a8); IMPL-WATER-LIB (set_water_scalar_source FILE|ENGINE, refusal until U4* captured)"
---

# DEC-U-WATER-SCALAR-SELECT — statically settle U4*: FILE vs ENGINE vs per-scalar mix (2026-11-26)

## 0. Authority and discipline (read first)

Every statement is `[O]` (verbatim donor bytes/text or verbatim port file line), `[D]` (deterministic control-flow/arithmetic from `[O]`), `[I]` (interpretation) or `[U]` (UNVERIFIED — a concrete single-session zero-mismatch GL capture is given in §5; the port must **hard-fail, never invent a scalar, never default FILE or ENGINE**). Pin `t_87f0f3c130b0` throughout.

This worker issued **no Craft Anything native calls** (subagent context: repo/doc reads only). All binary addresses, VA cites and evidence ids below are **re-cited pinned records** from `DEC_U_water_lib_params.md` / `DEC_U_water_runtime.md` / `PORT1TO1_water_shore.md`, each originally pinned `document:"t_87f0f3c130b0"`, Deep mode (Ghidra 12.2 pseudocode + built-in 0.6.1 bytes). No new decompilation lift was performed by this worker; no donor binary was executed; no GPU frame was captured; no parity claim is made. Active donor target was never opened/selected/closed by this worker.

**Single most important result:** U4* is **not statically settable** — the branch that decides FILE vs ENGINE is a single caller-supplied layer pointer at `FUN_00851bdc @0x851bdc`, and neither arm mixes scalars per-field (each arm writes the whole block atomically). So the only live outcomes are exactly two tuples (FILE §2.1 vs ENGINE §2.4), **no per-scalar mix is reachable** through shipped code. Colours/Speed/CustomEnable converge `[D]`; all 11 scalars + 2 wave-dir vectors diverge `[U]` → §5 captures. `texScaleS/T` live values are `0.1/0.01` (FILE) vs `0.4/0.825` (ENGINE) — the `0.01/0.02` in the embedded VP source and in the port BUILTIN path are pre-bind source defaults, not live uniforms.

---

## 1. Pass ledger (owner rule ≤5 passes/function; every pass logged)

| # | Function / question | Passes this ticket | Result / accepted? |
|---|---|---|---|
| P1 | `data/water/water.lib` layer block (:21–:40) + file block (:64–:68) | 1 repo-side re-read (via DEC-U-WATER-LIB-PARAMS §2.1–2.2) | **Accepted**: FILE tuple verbatim §3 |
| P2 | `FUN_00856080` @0x856080 (ctor engine defaults) | 1 re-cite: `ev_5aaec0315458ec67490ef87ee4c2c2f70f72e65ae9fbaaacdfbc718ac2de3787` + `ev_d9277ee31a563b52091b6bebce7877657b0d2e139fc2e9955ec8eaa49cbca` | **Accepted**: ENGINE tuple verbatim §3; `C+0x184=0`, `C+0xc4=1.0f`, `C+0xc8..0xcf=0` |
| P3 | `FUN_00852f5c` @0x852f5c (layer copy) | 1 re-cite: `ev_513eeafe38634fbdc522d1db078484a80f84f018b6e59a0f58983d37c7202338` | **Accepted, decisive**: whole-block copy, no per-scalar select; `CustomEnable→C+0x184` |
| P4 | `FUN_00851bdc` @0x851bdc (path select) | 1 re-cite: `ev_67a5083d1de168ff448c44405a905f4d010e3f873fcb249547cac621a03c28b` | **Accepted, decisive**: `layerPtr==0→ctor` else `layer copy` — single-pointer branch |
| P5 | `FUN_00854054` @0x854054 (binder bitmask) | 1 re-cite: `ev_ab751f818e4b8839b359f3da00152283cfd960776db078f970aed7cea91b0641` + raw `ev_bbdba234fcbb85df996f0f2e5ed4b1df1aaa00f02c95c3861160cc201851db7a` (0x854080–0x8542f0) | **Accepted, decisive**: per-bit `push [C+off]` / `lea` sources; time `fld/fmul/fstp` at 0x854091 |
| P6 | `FUN_00856530` @0x856530 (CUSTOM gate) + `FUN_00855b38` @0x855b38 (compile) | 1 re-cite each: `ev_8218b0f1aa21aefba779cac21107bff799438a4c52459533477079bebcbc8642` + `ev_a66a956b6a994521c1060ff03d8490b4284f2b7e15bb4aaebcefc6d7c73984f6` | **Accepted**: CUSTOM needs `C+0x184!=0 && [0x8fc6b8]!=0`; shipped `C+0x184=0` → unreachable `[D]` |
| P7 | Water `.lib` loader keys (`FUN_00852298` @0x852298 + `FUN_00853150` @0x853150) + `FUN_008520a8` @0x8520a8 (hmap staging) | 1 re-cite each: `ev_8d7668eb6078e5d6b4f38748683eef0096f61f7fd38e5aea0af3321ebcd4c199` + `ev_68633b8db084fecdc9055e8647afa43a1ab45edaf6ddc132ffe4fe5a5afda` + `ev_ada19843eaa6b98947f1d8dd8a5c512875c5ef66241b73905af4e63852b` | **Accepted**: 47 `waters` keys → `+0x08..+0xf8`; file keys → `+0x0c..+0x1c`; hmap gate on `+0xb9` |
| P8 | Port files `variant3d/scripts/water3d.gd` + `variant3d/shaders/water3d.gdshader` | 1 repo read each (HEAD, this ticket) | **Accepted as `[O]`**: line intents for §6 diff |

No function exceeded prior + current pass budget. No `sub_8519f4` re-lift (prior `ev_d41c…` rejected as garbled, not used).

---

## 2. Branch condition `[D]` — the single pointer that decides U4*

`FUN_00851bdc(wrapper, layerPtr)` (`ev_67a5…`, VA 0x851bdc):

```
if (layerPtr == 0)  FUN_00856080(shaderObj);        // ctor → ENGINE tuple (§3)
else                FUN_00852f5c(layerPtr, shaderObj); // layer copy → FILE tuple (§3)
```

`FUN_00852f5c` (`ev_513e…`, VA 0x852f5c) writes verbatim, no conditionals between scalar stores:

```
C+0x68/6c/70/74 ← layer+0x18/1c/20/24  (DeepColor)
C+0x78/7c/80/84 ← layer+0x28/2c/30/34  (ShallowColor)
C+0x88 ← layer+0x38  (S1)   C+0x8c ← +0x3c (S2)   C+0x90 ← +0x40 (S3)
C+0x94 ← +0x44 (S4)  C+0x98 ← +0x48 (S5)  C+0x9c ← +0x4c (S6)
C+0xa0 ← +0x50 (S7)  C+0xa4 ← +0x54 (S8)  C+0xa8 ← +0x58 (S9)
C+0xac ← +0x5c (S10 texScaleS)  C+0xb0 ← +0x60 (S11 texScaleT)
C+0xb4/0xb8 ← +0x64/0x68 (W0)   C+0xbc/0xc0 ← +0x6c/0x70 (W1)
C+0xc4 ← layer+0x74 (Speed)     C+0x184 ← layer+0x90 (CustomEnable)
C+0x188 ← +0x94  C+0x191 ← +0x9c  C+0x190 ← +0xb8  C+0x1a8 ← +0xb4
```

`[D]` consequences:

1. **Atomic arms, no mix.** Each arm writes the entire `C+0x88..+0xc4` scalar block plus `C+0xb4/+0xbc` dirs from one source. There is no per-scalar branch, no clamp, no post-copy overwrite of any scalar slot in either `FUN_00851bdc`, `FUN_00852f5c`, `FUN_00856080`, or the `FUN_00854054` binder (binder only reads `C+off`, never selects). A per-scalar FILE/ENGINE mix is therefore **unreachable through shipped code** — the live outcome is exactly one of the two tuples in §3.
2. **Shipped descriptor favours the FILE arm structurally but does not prove it.** `water.lib` ships `LayerCount=1` (lib :50) + `DefaultWaterIndex=0` (lib :65), so a nonzero parsed layer exists **iff** the caller passes it. Whether retail's water-draw call passes `0` or the parsed layer pointer is the single unproven pointer → U4*.
3. **CUSTOM is off on both arms `[D]`.** Ctor sets `C+0x184=0` (`ev_5aae…`); layer copy sets `C+0x184=layer+0x90=False` (lib :51). `FUN_00856530` CUSTOM arm requires `C+0x184!=0 && [0x8fc6b8]!=0` (bytes `80 bb 84 01 00 00 00 / 0f 84 … / a1 b8 c6 8f 00 / 80 38 00`, `ev_8218…`), so CUSTOM is unreachable from shipped config on either path. The drawn program is BUILTIN-vs-FIXED (`FUN_0085600c` + `[0x8fc6b8]` globals `[U]` → U1), never CUSTOM.

---

## 3. Exact source per scalar `[O]/[D]` + live verdict

`File` = `water.lib` verbatim (§2.1 LIB-PARAMS). `Engine` = `FUN_00856080` ctor slot (§2.4). `Bind` = `FUN_00854054` bit (`ev_ab75…`/`ev_bbdb…`). `Live` = value after the §2 branch.

| # | Param | Binder bit / type `[O]` | FILE `[O]` (lib:line → desc. off → shader off) | ENGINE `[O]` (ctor slot) | Live verdict |
|---|---|---|---|---|---|
| C1 | DeepColor RGBA | 7c.10 `V3(C+0x68)` | **(0,0,0.1255,0.5)** :9–13 → `+0x18..+0x24` → `C+0x68` | (0,0,0.1255,0.5) `C+0x68` | **`[D]` settled 0,0,0.1255,0.5** — converges |
| C2 | ShallowColor RGBA | 7c.20 `V3(C+0x78)` | **(0,0,0,0.5)** :15–19 → `+0x28..+0x34` → `C+0x78` | (0,0,0,0.5) `C+0x78` | **`[D]` settled 0,0,0,0.5** — converges |
| S1 | ReflectionAmount | 7c.40 `1f(C+0x88)` | **1** :21 → `+0x38` → `C+0x88` | 0.4 `C+0x88` | `[U]` → U4*-S1 |
| S2 | WaterAmount | 7c.80 `1f(C+0x8c)` | **1** :22 → `+0x3c` → `C+0x8c` | 0.3 `C+0x8c` | `[U]` → U4*-S2 |
| S3 | FresnelPower | 7d.01 `1f(C+0x90)` | **1** :23 → `+0x40` → `C+0x90` | 4.0 `C+0x90` | `[U]` → U4*-S3 |
| S4 | FresnelBias | 7d.02 `1f(C+0x94)` | **1** :24 → `+0x44` → `C+0x94` | 0.1 `C+0x94` | `[U]` → U4*-S4 |
| S5 | HDRMultiplier | 7d.04 `1f(C+0x98)` | **1** :25 → `+0x48` → `C+0x98` | 0.5 `C+0x98` | `[U]` → U4*-S5 |
| S6 | WaveFreq | 7d.08 `1f(C+0x9c)` | **0** :26 → `+0x4c` → `C+0x9c` | 1.0 `C+0x9c` | `[U]` → U4*-S6 |
| S7 | WaveAmp | 7d.10 `1f(C+0xa0)` | **0** :27 → `+0x50` → `C+0xa0` | 0.05 `C+0xa0` | `[U]` → U4*-S7 |
| S8 | DistFactor | 7d.20 `1f(C+0xa4)` | **1** :28 → `+0x54` → `C+0xa4` | 2.0 `C+0xa4` | `[U]` → U4*-S8 |
| S9 | BumpFactor | 7d.40 `1f(C+0xa8)` | **1** :29 → `+0x58` → `C+0xa8` | 0.01 `C+0xa8` | `[U]` → U4*-S9 |
| S10 | TexScaleS | 7d.80 `1f(C+0xac)` | **0.1** :32 → `+0x5c` → `C+0xac` (`//TexScaleS=0.115` :30 inert) | 0.4 `C+0xac` | `[U]` → U4*-S10. `0.01` (embedded VP default / port `BUILTIN_TEX_SCALE_S`) is pre-bind source default, NOT live |
| S11 | TexScaleT | 7e.01 `1f(C+0xb0)` | **0.01** :33 → `+0x60` → `C+0xb0` (`//TexScaleT=0.015` :31 inert) | 0.825 `C+0xb0` | `[U]` → U4*-S11. `0.02` (embedded VP default / port `BUILTIN_TEX_SCALE_T`) is pre-bind source default, NOT live |
| W0 | WaveDir0 XY | 7e.02 `2f(C+0xb4)` | **(−1,0)** :34–36 → `+0x64/+0x68` → `C+0xb4` | unenumerated in `ev_5aae…`/`ev_d927…` | `[U]` → U4*-W0 (FILE value; ENGINE slot unknown) |
| W1 | WaveDir1 XY | 7e.04 `2f(C+0xbc)` | **(−0.7,0.7)** :38–40 → `+0x6c/+0x70` → `C+0xbc` | unenumerated | `[U]` → U4*-W1 (FILE value; ENGINE slot unknown) |
| SP | Speed | — (`C+0xc4`, time factor `fld [C+0xc8]; fmul [C+0xc4]` at 0x854091) | **1.0** :42 → `+0x74` → `C+0xc4` | 1.0f `C+0xc4` | **`[D]` settled 1.0** — converges; `time=(float)(dbl[+0xc8]*dbl[+0xc4])` |
| CE | CustomEnable | `C+0x184=layer+0x90` | **False** :51 → `+0x90` → `C+0x184=0` | `C+0x184=0` | **`[D]` settled 0** — CUSTOM unreachable both paths |
| HE | HeightMapEnable | gate `C+0xe0` (`FUN_008520a8`) | **True** :60 → `+0xb9` | `C+0xe0=0` at construction | `[D]` file True; numeric hmap values `[U]` → U3 |

`[D]` No third tuple and no mixed tuple is reachable: the only writer of `C+0x88..+0xc4`/`C+0xb4/+0xbc` before the binder is the §2 branch, and each arm is unconditional within itself.

---

## 4. Why texScaleS/T need explicit call-out

The embedded VP source (compiled by `FUN_00855b38`, `ev_a66a…`) carries pre-bind defaults `texScaleS 0.01 / texScaleT 0.02` (LIB-PARAMS §2.5). These are **source-text literals replaced by the `FUN_00854054` binds** (`push [C+0xac]` / `push [C+0xb0]`) whenever bits 7d.80/7e.01 are set — they are never the live uniforms under either construction path. The port currently keeps `BUILTIN_TEX_SCALE_S/T = 0.01/0.02` as a labelled `[U4*]` embedded-source default (`water3d.gd:107-108`, shader `:129-130`) — that labelling is correct and must stay until U4* captures the winner (`0.1/0.01` iff FILE, `0.4/0.825` iff ENGINE). Presenting `0.01/0.02` as recovered live values would violate donor faithfulness.

---

## 5. `[U]` register — single-session GL uniform captures with zero-mismatch termination

Gating precondition for every row: retail skirmish with at least one water field visible (break `FUN_00603d30` @0x603d30, read `[ebp+0x1c]` plane-Y record per FINAL-REGISTER), live path identified first (U1: hook `glShaderSource`; `hmapTex` present = DEV file pair, `alphaDepth`/`deepColor` = BUILTIN embedded pair). Owner-authorised donor GPU session only (RenderDoc/apitrace/Nsight-GL or debugger + GL hooks). Forbidden to workers. **Never assume FILE or ENGINE by default — every row below terminates only on a bit-exact 0-mismatch repeat.**

| # | Still-`[U]` value | Static state after this ticket | Single-session capture (break + trace) | Zero-mismatch termination (else stays `[U]`, port keeps hard-failing) |
|---|---|---|---|---|
| U4*-CORE | Which tuple is live: ENGINE S1–S11 (0.4/0.3/4/0.1/0.5/1/0.05/2/0.01/0.4/0.825) vs FILE S1–S11 (1/1/1/1/1/0/0/1/1/0.1/0.01) | `[D]` exactly two candidates, no mix (§2/§3) | Break `FUN_00851bdc` @0x851bdc; record `param_2` layer pointer (0 vs nonzero). Then dump `C+0x88..+0xc4` scalar block. Hook `glUniform1f` on S1–S11 locations on the U1 program; record floats across first water draw | Layer-ptr nonzero + uniform tuple bit-exact == FILE tuple, OR layer-ptr zero + tuple bit-exact == ENGINE tuple; identical 0-ULP across 2 frames + 1 camera move. Any element mismatch or missing dump → stays `[U]`; `set_water_scalar_source` stays UNSET |
| U4*-W0/W1 | WaveDir0/1 live pair: FILE (−1,0)/(−0.7,0.7) vs ENGINE (unenumerated) | `[D]` FILE values proven; ENGINE slots unknown | Same session as U4*-CORE: hook `glUniform2f` on W0/W1 locations; record pairs with the S1–S11 floats in the same draw | Same draw's W0/W1 identical 0-ULP across 2 frames + move AND consistent with the winning CORE tuple (FILE win → (−1,0)/(−0.7,0.7) bit-exact; ENGINE win → captured pair becomes the new ENGINE enum, no invention). Any divergence → stays `[U]`; ENGINE selection keeps hard-failing on null dirs |
| U4*-S10/S11 | TexScaleS/T live pair: FILE (0.1/0.01) vs ENGINE (0.4/0.825) | `[D]` both candidates enumerated; `0.01/0.02` is source-default, never live | Same session/draw as U4*-CORE: record `glUniform1f` texScaleS/T alongside S1–S9 | Bit-exact match to the winning tuple's S10/S11, 0 mismatches over the same 2 frames + move. Until then port keeps `0.01/0.02` labelled `EMBEDDED-SOURCE-DEFAULT [U4*]`, never as live |
| U1 | Live path DEV/BUILTIN/LEGACY; globals `[0x8fc6b8]`, `FUN_00855fe8` triple (`0x8fcdb0/0x8fbd28/0x8fc748`), `C+0x184` | `[D]` shipped → `C+0x184=0` → CUSTOM off; compile path `FUN_00855b38` proven | Break `FUN_00855b38` @0x855b38 + `FUN_00856530` @0x856530; record `C+0x184`, `C+0xf0`, `C+0x50`, globals; hook `glShaderSource`/`glCompileShader`, record source text + program hash; GPU frame capture of one water field names the drawn program | `(PATH, C+0x184, globals, program-hash)` identical, 0 mismatches, 2 draws + 1 camera move |
| U3-NUM | Numeric `hmapMin/Max/W/H` at live frame | `[D]` sources: `W/H` = terrain `+8/+0xc`, `Min/Max` = `FUN_0082f060/0082f114` on `+0x200` obj; gate `C+0xe0!=0 && [C+0xe0+8]!=0` | Break `FUN_00854054` bits 7e.10–7f.1 with field visible; record 4 pushed values (`C+0xd0/+0xd4` ints, `C+0xe4/+0xe8` floats) + gate values | Same 4-tuple, 0 differing bits, 2 frames + move. Then those 4 numbers (not `map_size`/`±2.96`) become the port parameters |
| U3-TEX | `hmapTex` GL identity (name/target/provenance) | `[O]` unit `C+0xdc` (ctor 2), target `C+0xd8` (ctor `0xde1`); `[U]` bound name | Same break: `glActiveTexture(GL_TEXTURE0+u)` at unit `C+0xdc`, `glBindTexture`, `glGetTexLevelParameteriv(name,0,WIDTH/HEIGHT/INTERNAL_FORMAT)`; FBO-attachment vs upload history | Same `(target,name,w,h)`, 0 mismatches, 2 frames. Unknown provenance ⇒ keep `bind_height_grid` substitute labelled `[U3]`, never `heightmapwaves0.tga`/neutral texel |
| U5 | `C+0xc8` writer + live `time` values | `[D]` formula + `Speed=1.0`; `[U]` writer | Hook `glUniform1f(time)` ≥3 frames over ≥2 s; if non-constant, HW write-watchpoint on shader `+0xc8` (8 B) → writer EIP + disassembly | Constant `0.0` (0 differing samples, 10 s window, watchpoint never fires) → `time=0 [D]`-by-capture; else single writer EIP every frame, 0 missed frames, formula reproduces uniform with 0 ULP error |
| U6-UV | Dividend behind `MultiTexCoord0/(hmapW,H)−0.5` (`water.dev.vert:16-17`) | `[D]` divisor + verbatim −0.5; `[U]` dividend array | Break virtual `+0x98` from `FUN_00826b30` @0x826b30 (loop `ev_0510…`); dump `MultiTexCoord0` array (4 verts, float32) + `hmapW/H` uniforms same frame; read back `gl_TexCoord[1].xy` | `max\|uv_pred−uv_actual\|==0.0` bit-exact, 4 verts, ≥2 fields + move |
| U6-WIND | Triangle winding/diagonal/culling | `[O]` `glBegin(4)`=TRIANGLES, 2 tris/quad; `[U]` order + cull | Same `+0x98` break: dump index array (or `glDrawArrays` first/count) + `glGetIntegerv(GL_CULL_FACE/GL_FRONT_FACE)` trace | Index sequence 0 mismatches ≥2 fields; cull state identical 2 frames |
| U12 | Reflection provenance / unit `C+0xf8` / matrix (`FUN_0085756c` +0x60) / `DiffuseWaves2` alias / pbuffer | `[O]` object `C+0x4c` (id `+8`), bind gate `FUN_00855fe0()+C+0x4c`, FBO names (`ev_c380…` 0x4b98xx); `[U]` provenance/size/matrix | Apply `DEC_U_water_fbo.md` §8 U12-A/B/C/T/S/P verbatim (FBO-attachment vs copy-dst vs static-upload test, unit hook, `+0x60` matrix + viewport dump, waves-alias check, `wglMakeCurrent`/pbuffer sweep) | Identical `(provenance_class,name,w,h,unit,matrix)`, 0 mismatches, 2 frames + move; any gap ⇒ keep `water3d.gd:520-527` hard-fail + `reflectionMapBound=false` |

U7–U11/U13–U16 use `DEC_U_final_register.md` §§1–5 experiments verbatim (plane-Y `[ebp+0x1c]` read, DScript thunk trace, smooth-pass count, blend-factor hook, `MapDrawCollision` xref, donor A/B frame, FogMode sweep, `fWaterStates` dump, editor literal diff). This worker captured no donor frame and executed no donor binary.

---

## 6. Exact port change list — `water3d.gd` / `water3d.gdshader` (file:line; NO edits made — owner applies)

All lines verified by repo read this ticket (HEAD). Wire only captured reals. Preserve the BUILTIN labelled default and the U12 hard-fail in every diff. `visual_parity_claim=false` stays.

1. **`variant3d/scripts/water3d.gd:217-257` (`WATER_SCALARS_FILE` / `WATER_SCALARS_ENGINE`) + `:375-393` (`set_water_scalar_source`) + `:674-678` (UNSET refusal)** — KEEP AS-IS. Both tuples are verbatim §3 enumerations with per-key cites; UNSET refusal (`push_error` + no water) is the required `IMPL-WATER-LIB` gate. Required diff: none to values; append the U4*-CORE/W0/W1/S10 capture id to `stats` (already present as `U4_CAPTURE_ID` at `:220-222` / `:792`) — do not add a default argument.
2. **`variant3d/scripts/water3d.gd:733-760` (BUILTIN S1–S11 + waveDir binds) + `water3d.gdshader:119-130`** — LABEL, DO NOT SILENTLY KEEP VALUES. Shader literals `1/1/1/1/1/0/0/1/1` + `(-1,0)/(-0.7,0.7)` equal the FILE tuple but the ENGINE tuple is equally live until U4*-CORE/W0. Required diff after capture: if FILE wins, keep literals and re-label `[D]`-by-capture with the capture id; if ENGINE wins, replace S1–S11 with `0.4/0.3/4/0.1/0.5/1/0.05/2/0.01` + captured S10/S11/W0/W1 and re-label; until then keep current literals with `[U4*]` labels (already present). Never hard-code one tuple as "the" donor value.
3. **`variant3d/scripts/water3d.gd:107-108` (`BUILTIN_TEX_SCALE_S/T`) + `:758-760` (bind) + `water3d.gdshader:129-130`** — CORRECT AFTER U4*-S10/S11 ONLY. Current `0.01/0.02` are the embedded VP pre-bind source defaults (§4), NOT live uniforms under either path. Required diff after capture: bind the winning tuple's S10/S11 (`0.1/0.01` iff FILE; captured `0.4/0.825` iff ENGINE — note ENGINE S10/S11 come from ctor slots `C+0xac/+0xb0`, not from any capture of the VP text). Until then keep `0.01/0.02` with `EMBEDDED-SOURCE-DEFAULT [U4*]` labels, never presented as recovered live uniforms. Same for DEV `TEX_SCALE_S/T` at `water3d.gd:71-72` + shader `:53-54` (DEV frag reads them live — FILE values apply iff U4*=FILE).
4. **`variant3d/scripts/water3d.gd:750-757` (waveDir null-guard + bind)** — KEEP AS-IS. ENGINE dirs are `null` (slots unenumerated §3 W0/W1) and selecting ENGINE hard-fails rather than inventing — this is the correct per-§5 U4*-W0/W1 behaviour. After an ENGINE win, replace `null` with the captured pair + capture id; never with `(-1,0)/(-0.7,0.7)` carried over from FILE.
5. **`variant3d/scripts/water3d.gd:251` (`_time += delta`) + shader `:78` (`time`)** — KEEP SCAFFOLDING, ADD FORMULA COMMENT. After U5 capture only: replace with captured writer (or freeze `0.0` if U5 terminates constant) while keeping comment `time=(float)(dbl[+0xc8]*dbl[+0xc4]), Speed=1.0 (water.lib:42; 0x854091 ev_bbdb…)`. Until then keep `_time` + `[U5]` labels (`water3d.gd:120/218-219/719`). Cross-ref shader `:177/248` (`time*0.1/0.01` scroll uses same accumulator).
6. **`variant3d/scripts/water3d.gd:508-511` (`hmapW/H/Min/Max`) + shader `:133-136,168-171,187,276,400-401`** — KEEP SUBSTITUTE, KEEP `[U3]` LABELS. `_grid_w/_grid_h`, `-MAX_HEIGHT/+MAX_HEIGHT` are port substitutes; `MAX_HEIGHT=2.96` cites `texturemap.inc:29` (classification), NOT water.lib. After U3-NUM/TEX capture only: replace divisor with captured `hmapW/H`, span with captured `hmapMin/Max`, `height_tex`/`hmapTex` alias with captured `(target,name)` (FBO import or captured copy target — never generated solid-colour, never `diffusewaves*`/`heightmapwaves0` art unless U12-S proves identity). Forbidden lines stay: `water3d.gd:138-145/216-217/502-511/717/755`, shader `:68-72/:77`.
7. **`variant3d/scripts/water3d.gd:168` (`DEFAULT_WATER_SHADER_PATH`) + shader `:102` (BUILTIN labelled default)** — KEEP AS-IS. Basis `[D]` §2 CE (`CustomEnable=False` lib :51 → `C+0x184=0` both paths → CUSTOM unreachable at `FUN_00856530` @0x856530). Do not flip to DEV/LEGACY without the U1 capture; `set_shader_path()` (`water3d.gd:290-303`) stays the explicit authority.
8. **`variant3d/scripts/water3d.gd:343-353` + `:520-527` + shader `:115,365-366` (U12 hard-fail)** — KEEP AS-IS until U12-A/B/C/T all captured. Then extend `bind_reflection_map` to validate captured `(w,h,unit)` and require matrix U12-T; keep `reflectionMapBound=false` default + `discard`. Never call `bind_reflection_map()` from `_make_water3d` with a non-captured texture.
9. **`variant3d/scripts/water3d.gd:740-751` (`donor_water_lib_proven`) + `:862-889`** — KEEP, EXTEND WITH §3 CITES. Current block already matches §2.1 values; required diff: none to numbers; per-key `water.lib:<line>` cites already present — retain `Width/Height=1/1, Offset=0.495` (lib :47–49, with "NOT plane Y" comment), `HeightMapEnable=True` (lib :60), `CustomEnable=False` (lib :51), and `MaxHeight ABSENT from water.lib; 2.96 = texturemap.inc:29 classification` note.
10. **FORBIDDEN (violates donor faithfulness):** presenting `0.01/0.02` as live `texScaleS/T`; presenting `±2.96` or `map_size/128` as `hmapMin/Max/W/H`; aliasing `reflectionMap`/`hmapTex` to `diffusewaves*`/`heightmapwaves0`/neutral texel; inventing ENGINE waveDirs, a winding order, a `fract(world*0.5)` dividend, a `*0.5+0.5` bias, a viewport-sized target, a pbuffer, or a time source; flipping the default off BUILTIN to "make water appear"; adding a water node when any required `[U]` binding is missing; defaulting `set_water_scalar_source` to either `"FILE"` or `"ENGINE"`.

---

## 7. Explicit non-claims and file discipline

- **No parity claim.** No donor binary executed, no GPU frame captured, no port capture compared by this worker. All readings are `[O]/[D]` re-cited or repo-side donor-text `[O]`; all unsettled values are `[U]` with §5 captures.
- **No approximation substituted.** No scalar is guessed: colours/Speed/CustomEnable are `[D]` path-insensitive (§3); S1–S11/W0/W1/S10/S11 are exactly two donor-enumerated tuples with no third option and no mix, gated on the explicit `set_water_scalar_source()` choice which has no default.
- **No FILE-or-ENGINE default.** The port refuses water while `_water_scalar_source==UNSET` (`water3d.gd:674-678`); this report does not change that gate and does not recommend a winner.
- **Read-only compliance.** Exactly one repo file written: `docs/terrain_swarm_2026-11-26/reports/DEC_U_water_scalar_select.md`. No code/shader/asset/config/Godot/git change. No donor file opened for write or executed. No Craft Anything investigation memory written. Active donor target never opened/selected/closed by this worker.

*End of DEC-U-WATER-SCALAR-SELECT.*
