---
id: DEC-U-HMAP-IDENTITY
worker: DEC-U-HMAP-ID (subagent in full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
ticket: "Recover statically which texture object is bound as hmapTex at water draw time, and exact hmapMin/Max for a shipped map; GL capture with zero-mismatch termination; port diff list"
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
labels: [O, D, I, U]
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. No donor binary executed, copied or committed. No donor file written."
scope_guard: "No repo code/asset/config/shader/Godot/git edit. Exactly one repo file written: this report."
multi_pass: true
visual_parity_claim: false
upstream: "DEC_U_water_mesh_uv.md §§5/8/9 (U3); DEC_U_water_runtime.md §§5/6/9 (U3/U4*); DEC_U_water_lib_params.md §§2/3/6/7 (HeightMap keys, MaxHeight absent); DEC_U_final_register.md W-U3-NUM/W-U3-TEX (P0-2); DEC_U_water_capture.md Phase 4; PORT1TO1_water_shore.md §§3/4/7/11 (U3); variant3d/scripts/water3d.gd; variant3d/shaders/water3d.gdshader"
---

# DEC-U-HMAP-IDENTITY — hmapTex object identity + hmapMin/Max numeric chain (static, read-only)

## 0. Authority and discipline (read first)

Every statement below is `[O]` (verbatim bytes/text/decompiled instruction or verbatim port file line), `[D]` (deterministic control-flow/arithmetic from `[O]`), `[I]` (interpretation) or `[U]` (UNVERIFIED — a concrete GL capture with a zero-mismatch termination criterion is given in §6; the port must **hard-fail, never invent a texture or number**). This worker issued **no Craft Anything native calls** (subagent context: only repo/doc reads via default tools); all donor addresses/evidence ids below are **re-cited pinned records** from `DEC_U_water_runtime.md` / `DEC_U_water_mesh_uv.md` / `DEC_U_water_lib_params.md` / `DEC_U_water_capture.md` / `PORT1TO1_water_shore.md`, each pinned `document:"t_87f0f3c130b0"`, Deep mode (Ghidra 12.2 + built-in 0.6.1 engine). No donor binary was executed, no GPU frame was captured by this worker, and no parity claim is made. Active donor target was never opened/selected/closed by this worker. No helper script was written or run by this worker.

`[D]` The load-bearing port fact is unchanged: the decoded height grid bound in `variant3d/scripts/water3d.gd:450-458,611-633` as `height_tex`/`hmapTex` with `hmapW=_grid_w`, `hmapH=_grid_h`, `hmapMin=-MAX_HEIGHT`, `hmapMax=+MAX_HEIGHT` is a **labelled `[U3]` substitute**, and `variant3d/shaders/water3d.gdshader:144-147,150-151,182-191,414-422` keeps the matching `[U3]` labels. This report tells the owner exactly which donor object/uniform slots feed the live bind, why no shipped-map number can be stated statically, and which capture settles each residual.

---

## 1. Pass ledger (owner rule ≤5 passes/function; every pass logged)

This ticket performed **document/byte-record re-analysis passes only** (no new native lifts). Each pass re-reads one cited record and checks reachability to the water draw. No function exceeded 5 prior + current passes.

| # | Question / function | Passes this ticket | Result |
|---|---|---|---|
| R1 | `water.lib` HeightMap* keys full re-read | 1 re-read: `ev_2eb0…` + `ev_227e…` (71-line file) + `DEC_U_water_lib_params.md` §2 | **Accepted**: `HeightMapEnable=True` (:60) only live HeightMap key; `HeightMapTexUnit` unset; no `MaxHeight` key; `HeightMapWaves0` commented |
| R2 | `water.mat` texture registry re-read | 1 re-read: `ev_2c66…` + `DEC_U_water_lib_params.md` §2.3 / D06 P18 | **Accepted**: `DiffuseWaves0/2` live; `HeightMapWaves0` block `water.mat:86-106` fully commented; `heightmapwaves0.tga` alpha-255 disproves substitution |
| R3 | Height staging `FUN_008520a8` @0x8520a8 | 1 re-read: Deep pseudo `ev_ada19843eaa6b989e47f1d8dd8a5c512875c5ef290b66241b73905af4e63852b` | **Accepted, decisive**: full numeric-source chain + gates on `+0xb9/+0xc0` |
| R4 | Binder `FUN_00854054` @0x854054 hmap rows (bits 7e.10–7f.1) | 1 re-read: Deep pseudo `ev_ab751f818e4b8839b5f6d60152283cfd960776db078f970aed7cea91b0641` + raw bytes 0x854080–0x8542f0 `ev_bbdba234fcbb85df996f0f2e5ed4b1df1aaa00f02c95c3861160cc201851db7a` | **Accepted, decisive**: unit `C+0xdc`, target `C+0xd8`, gate at 0x854250, value pushes |
| R5 | Ctor `FUN_00856080` @0x856080 sampler/target defaults | 1 re-read: `ev_5aaec0315458ec67490ef87ee4c2c2f70f72e65aef9fbaaacdfbc718ac2de3787` | **Accepted**: `C+0xd8=0xde1`, `C+0xdc=2`, `C+0xe0=0`, `C+0xf8=0`, `C+0xfc=1` |
| R6 | `FUN_0082f060` @0x82f060 / `FUN_0082f114` @0x82f114 caller search in re-read corpus | 1 re-read of caller-scan records in `DEC_U_water_runtime.md` §5 / `DEC_U_water_capture.md` Phase 4 | **Accepted as bounded**: only recovered caller is `FUN_008520a8`; no map/terrain-loader caller in re-read corpus → whole-binary caller list stays `[U]` (§4) |
| R7 | Map/terrain loader `FUN_00739bf8` + `FUN_0082f86c` role | 1 re-read: same `ev_ada1…` + PORT1TO1 §7.2 / `ev_626574…` (`FUN_00603d30`) | **Accepted as localized**: `h=FUN_00739bf8(layerObj)` then `C+0xe0=FUN_0082f86c(*(h+0x200))`; loader internals `[U]` |
| R8 | Port files `water3d.gd` / `water3d.gdshader` | 1 read each (this ticket, repo HEAD) | **Accepted as `[O]`**: substitute lines for §7 diff; BUILTIN default + hard-fail verified present |

No `wgl`/FBO/pbuffer water-anchored hit exists in the re-read corpus; that absence is bounded by the searched records (thunk/name-table/caller scans), not a whole-binary proof.

---

## 2. Evidence register (all pinned `t_87f0f3c130b0`; re-cited, not re-lifted)

| Evidence id | Source (prior ticket) | Establishes (re-verified by re-read) |
|---|---|---|
| `ev_ada19843eaa6b989e47f1d8dd8a5c512875c5ef290b66241b73905af4e63852b` | Deep pseudo `FUN_008520a8` | hmapW/H/Min/Max + height-object derivation; gates on `+0xb9/+0xc0` |
| `ev_ab751f818e4b8839b5f6d60152283cfd960776db078f970aed7cea91b0641` | Deep pseudo `FUN_00854054` | 30-key bitmask binder; per-bit sampler/value sources incl. hmap rows |
| `ev_bbdba234fcbb85df996f0f2e5ed4b1df1aaa00f02c95c3861160cc201851db7a` | `native_bytes_show(0x854080,624)` | Value pushes at each binder call; hmap gate at 0x854250; shadow gate at 0x8542d2 |
| `ev_5aaec0315458ec67490ef87ee4c2c2f70f72e65aef9fbaaacdfbc718ac2de3787` | Deep pseudo `FUN_00856080` | Ctor defaults incl. `C+0xd8=0xde1`, `C+0xdc=2`, `C+0xe0=0`, `C+0xec=0` |
| `ev_513eeafe38634fbcdc522d1db8484a0f84f018b6e59a0f58983d37c7202338` | Deep pseudo `FUN_00852f5c` | Layer→shader map; `HeightMapEnable` source `layer+0xb9` (via descriptor `ev_8d76…`) |
| `ev_2eb06d2413a38b3fcbb43c22048de75750d09258b357b82724f1253c587483d`, `ev_227e118e2e2af6e3438913898c1823ce94d1154bed056b99beb99c60db37d84b` | `core_text_read water.lib` | `HeightMapEnable=True`, `HeightMapTexUnit` unset, `CustomEnable=False`, `Speed=1.0`, no `MaxHeight` key |
| `ev_2c6662253590cd2c759fb60b23c907bcb0113e1da18402b3bb7d9dadebd3cfb` | `data/water/water.mat:1-106` | `DiffuseWaves0/2` live; `HeightMapWaves0` block commented |
| `ev_8d7668eb6078e5d6b4f38748683eef0096f61f7fd38e5aea0af3321ebcd4c199` | Deep pseudo `FUN_00852298` | 47 `waters` keys → descriptor offsets incl. `HeightMapEnable +0xb9` |
| `ev_626574ae222dec3a4ca1b6e81a55874c24cae0e2c0aae4b613d3f350d514f86a` | Deep pseudo `FUN_00603d30` | `WaterFieldAdd` impl; no texture/height writer inside field callback |

`[D]` No evidence id in the re-read corpus anchors a second static caller of `FUN_0082f060`/`FUN_0082f114`, a map-file height-table address, or a `glTexImage2D`/FBO-attachment call **inside** `FUN_008520a8` / `FUN_00854054` / `FUN_00603d30`.

---

## 3. `water.lib` HeightMap* keys — exhaustive `[O]`

Donor root in all cites: `C:\Games\Cossacks 3\data\`. File is 71 lines (`ev_2eb0…` + tail `ev_227e…`).

| Key | Line | Verbatim value `[O]` | Native meaning `[D]` |
|---|---|---|---|
| `HeightMapEnable` | :60 | **True** | Gate bit: `layer+0xb9` (`ev_8d76…`); tested in `FUN_008520a8` — if 0, `C+0xe0=0` and hmap* not bound |
| `HeightMapTexUnit` | — (absent) | **unset in file** | No static unit override recovered; live unit is ctor default `C+0xdc=2` (`ev_5aae…`) unless overwritten by code not in corpus |
| `HeightMapWaves0` / `MaxHeight` / `HeightMap*` other | :45 (`//NormalMapLibMaterialName = HeightMapWaves0` commented); no `MaxHeight` key anywhere in 71 lines | **absent / inert** | `[D]` No height-texture filename, no numeric span, no unit comes from `water.lib`. `MaxHeight` exists only as `texturemap.inc:29 cMaxHeight=2.96` (script-stage classification, NOT water.lib) |
| `NormalMapLibMaterialName` / `DiffuseMapLibMaterialName` | :43–:44 | **`DiffuseWaves2` / `DiffuseWaves0`** | Live wave samplers; unrelated to hmap path (`waveMap=C+0xfc` bit 7c.02) |
| `MaterialLibraryFileName` / `DefaultWaterIndex` | :64–:65 | `.\data\water\water.mat` / **0** | Registry file pointer; single layer (`LayerCount=1` :50) |

`[D]` `water.lib` contributes exactly one live fact to the hmap bind: the **enable gate** (`True`). It names **no texture object, no GL name, no dimensions, no min/max**.

---

## 4. Texture-object identity at water draw time `[O]/[D]/[U]`

### 4.1 The object, its VA-adjacent slots, and the bind mechanism `[O]/[D]`

`FUN_008520a8(shaderCtx=C, layerObj, field)` (`ev_ada1…`), verbatim re-read R3:

```
if (layerObj==0 || waterDesc==0 || layerDesc+0xb9 == 0)  // HeightMapEnable
    C+0xe0 = 0;                                  // height path closed
else:
    h = FUN_00739bf8(layerObj)                   // VA 0x739bf8: terrain/layer handle lookup
    C+0xe0 = FUN_0082f86c(*(h+0x200))             // VA 0x82f86c: engine height object
    C+0xd8 = *(h+0x50)                            // texture target (ctor default 0xde1)
    C+0xd0 = *(layerObj+8)                        // hmapW (uniform 7e.20)
    C+0xd4 = *(layerObj+0xc)                      // hmapH (uniform 7e.40)
    C+0xe4 = (float) FUN_0082f060(*(h+0x200))     // VA 0x82f060: hmapMin (7e.80)
    C+0xe8 = (float) FUN_0082f114(*(h+0x200))     // VA 0x82f114: hmapMax (7f.1)
```

`FUN_00854054` hmap rows (`ev_ab75…` / `ev_bbdb…` at VA 0x854054–0x8542f0), re-read R4:

```
7e.10 hmapTex: glUniform1i(loc, C+0xdc)   // sampler UNIT, ctor default 2
7e.20 hmapW:   glUniform1i(loc, C+0xd0)
7e.40 hmapH:   glUniform1i(loc, C+0xd4)
7e.80 hmapMin: glUniform1f(loc, C+0xe4)
7f.01 hmapMax: glUniform1f(loc, C+0xe8)
gate at VA 0x854250: bind 7e.10–7f.01 ONLY IF C+0xe0 != 0 && [C+0xe0+8] != 0
```

`[D]` The texture object bound as `hmapTex` at water draw time is therefore:

- **Object:** the engine height object at shader-slot `C+0xe0`, produced per-draw by `FUN_0082f86c(*(FUN_00739bf8(layerObj)+0x200))` — **not** `heightmapwaves0.tga`, not `DiffuseWaves0/2`, not a port `ImageTexture`.
- **Sampler unit:** integer at `C+0xdc` (ctor default **2**, VA 0x856080 `ev_5aae…`); bound via `glActiveTexture(GL_TEXTURE0 + C+0xdc)` + `glUniform1i(hmapTex, C+0xdc)`.
- **Target:** integer at `C+0xd8` (ctor default **0xde1 = GL_TEXTURE_2D**, overwritten per-draw from `*(h+0x50)`).
- **Liveness gate:** `C+0xe0 != 0 && [C+0xe0+8] != 0` at VA 0x854250; a zero gate means hmap* is **not bound that draw** and any captured tuple from such a frame is void.

### 4.2 What is still `[U]` about the identity

`[U]` The **live GL texture name** (the integer `glBindTexture` receives at unit `C+0xdc`), its **pixel size / internal format**, and its **provenance class** (pre-uploaded heightfield vs per-frame terrain render vs FBO attachment) are not in the re-read corpus: no `glTexImage2D`/`glBindTexture`/FBO-attachment call inside `FUN_008520a8`/`FUN_00854054` was recovered, and `water.mat` names no live height texture (§3). `[I]` `[C+0xe0+8]` is most plausibly the GL name or a pointer whose validity gates the bind, but its exact type is not proven without the §6 U3-TEX capture — the port must not dereference or emulate it. **Never invent a name, never substitute `heightmapwaves0.tga`** (D06 P18: 256×256 TGA type 10 RLE, alpha 255 for all 65,536 pixels; block `water.mat:86-106` all `//`-commented) **or a 1×1 neutral texel** (the removed grey-fallback bug, `water3d.gd:48`).

### 4.3 `FUN_0082f060` / `FUN_0082f114` caller standing

`[O]` The **only recovered caller** of both getters in the re-read corpus is `FUN_008520a8` @ VA 0x8520a8 (lines above). No map-loader, terrain-generator, or texture-registry caller of VA 0x82f060 / 0x82f114 appears in `DEC_U_water_runtime.md` §5 / `DEC_U_water_capture.md` Phase 4 / PORT1TO1 §§4/7. `[U]` A whole-binary xref of both VAs (each ≤5 passes) plus identification of `FUN_00739bf8` / `FUN_0082f86c` callees remains for a future native pass; until then the numeric-source chain terminates at `+0x200`-object getters with unknown siblings. No caller is invented here.

---

## 5. Numeric-source chain and unit conversion `[O]/[D]/[U]`

### 5.1 Chain (draw-time, per field)

```
shipped map ──(map/terrain loader, [U] internals)──> terrain object h = FUN_00739bf8(layerObj)
h+0x200 ──> height sub-object ──> FUN_0082f86c ──> C+0xe0 (height object)
                             ├──> FUN_0082f060 ──(float)──> C+0xe4 = hmapMin ──glUniform1f──> DEV hmapMin
                             └──> FUN_0082f114 ──(float)──> C+0xe8 = hmapMax ──glUniform1f──> DEV hmapMax
layerObj+8 ──(int32 copy)──> C+0xd0 = hmapW ──glUniform1i──> DEV hmapW
layerObj+0xc ──(int32 copy)──> C+0xd4 = hmapH ──glUniform1i──> DEV hmapH
water.lib:60 HeightMapEnable=True ──> layerDesc+0xb9 != 0 ──> gate open (else C+0xe0=0)
```

`[D]` `hmapW/H` are **verbatim int32 copies** of the terrain object's `+8/+0xc` (no arithmetic). `[D]` `hmapMin/Max` are **verbatim float passthroughs** of the two getter returns (`(float)` cast at the call site, then `push [C+0xe4]/[C+0xe8]` straight to the `glUniform1f` wrapper `FUN_004c0f90`, ptr `0x8fc724`, `ev_84eb…`). There is **no donor-side scale, bias, or metres↔texel conversion** between the getter and the uniform in the recovered code.

### 5.2 Unit conversion

- `[D]` Donor bind conversion is **identity**: `uniform = engine float as-is`. The DEV shader then applies `height_map() = hmapMin + w*(hmapMax-hmapMin)` (`water.dev.frag:70-75`, re-cited in `water3d.gdshader:182-191`) where `w` is the sampled height texel.
- `[D]` The port's `alpha = (h+2.96)/(2*2.96)` encode (`water3d.gd:611-617`) and `height_map()` decode (`water3d.gdshader:188-191`) are **port scaffolding that mirrors the DEV formula shape**, not a recovered donor conversion: the `±2.96` span cites `texturemap.inc:29 cMaxHeight=2.96` (script-stage CLASSIFICATION literal; `generatemap.inc:7 cRavineHeight=-2.964` is the sibling literal), which is **absent from `water.lib`** and never flows through `C+0xe4/+0xe8`.
- `[U]` The engine-internal unit of the getter returns (metres, normalised 0..1, fixed-point-derived float) and the texel encoding of the live `C+0xe0` texture (float vs UNORM, which channel carries height) are unsettled — the §6 U3-NUM/U3-TEX capture reads both ends (uniform floats + `glGetTexLevelParameteriv` + texel dump) so the conversion, if any, is measured rather than assumed. **Never invent a ` /128`, `*2.96`, or `±2.96` donor conversion.**

### 5.3 Why no shipped-map number can be stated statically

`[D]` All four live values are **per-draw reads of the loaded terrain**: `+8/+0xc` and the `+0x200`-object getters depend on which map the retail loader built. The re-read corpus contains **no static per-map height table, no map-file byte layout yielding `+8/+0xc`, and no recorded live tuple** for any named shipped map. Stating e.g. `hmapMin=-2.96` for a shipped map would therefore conflate the `texturemap.inc:29` classification literal with the engine getter outputs — explicitly disproved by `DEC_U_water_lib_params.md` §3 MH. All four numerics for a shipped map remain `[U]` pending the §6 U3-NUM capture on that map.

---

## 6. `[U]` register — GL texture-binding/uniform captures with zero-mismatch termination

Owner-authorised donor GPU session only (RenderDoc/apitrace/Nsight-GL or debugger + GL hooks). Forbidden to workers. Gating precondition for **every** row: a water field visible (break `FUN_00603d30` @ VA 0x603d30, read `[ebp+0x1c]`), the live path identified first (U1: hook `glShaderSource`; `hmapTex` present = DEV file pair, `alphaDepth`/`deepColor` = BUILTIN embedded pair), and the height gate open (`C+0xe0 != 0 && [C+0xe0+8] != 0` at VA 0x854250 — closed gate voids the frame).

| # | Still-`[U]` item | Static state after this pass | Capture experiment (break + trace + byte comparison) | Zero-mismatch termination |
|---|---|---|---|---|
| U3-NUM | Numeric `hmapMin/Max/W/H` for a named shipped map (e.g. retail default map under shipped `water.lib`) | `[D]` sources = terrain `+8/+0xc`, getters `FUN_0082f060/0082f114` on `+0x200` object; gate proven; values per-map `[U]` | Break `FUN_00854054` bits 7e.10–7f.1 (VAs 0x854250–0x8542f0) with the named map loaded and a field visible. Record the 4 pushed values (`C+0xd0/+0xd4` ints, `C+0xe4/+0xe8` floats) **plus** the chain pointers (`layerObj`, `h=FUN_00739bf8(layer)`, `h+0x200`, `C+0xe0`, `[C+0xe0+8]`) and the `glUniform1i/1f` hook values on the `hmapW/H/Min/Max` locations from the same draw. Name the map + `water.lib` hash in the log | **Terminate `[U]` iff the same 4-tuple repeats with 0 differing bits across ≥2 frames + 1 camera move** on that map; the 4 numbers (not `map_size/±2.96`) become the port parameters for that map. A different map needs its own capture row |
| U3-TEX | `hmapTex` GL identity: `(target, name, w, h)` + provenance class | `[O]` unit `C+0xdc` (ctor 2), target `C+0xd8` (ctor `0xde1`); `[U]` bound name/provenance | At the same break, record `glActiveTexture(GL_TEXTURE0+u)` at unit `C+0xdc`, `glBindTexture(target,name)`, `glGetTexLevelParameteriv(name,0,{WIDTH,HEIGHT,INTERNAL_FORMAT})` + sampler state, and the full-frame history of `name`: (a) FBO attachment (`glFramebufferTexture2D*` with that name), (b) copy dst (`glCopyTexImage2D/SubImage2D` with that name), (c) upload-only (`glTexImage2D` with that name/size). Dump one texel block (e.g. 8×8 floats/raw) alongside the `height_tex` substitute encoding to test the channel/unit hypothesis | **Terminate `[U]` iff the same `(target,name,w,h)` 4-tuple is observed with 0 mismatches across ≥2 frames**, and exactly one provenance class (a/b/c) accounts for `name` with 0 counter-examples across those frames + 1 camera move. Unknown/mixed provenance ⇒ keep `bind_height_grid` substitute labelled `[U3]`, never promote art/`heightmapwaves0.tga`/neutral texel |
| U3-REG (sweep) | Whole-binary callers of `FUN_0082f060`/`FUN_0082f114` + internals of `FUN_00739bf8`/`FUN_0082f86c` (map/terrain loader + texture registry) | `[O]` one caller (`FUN_008520a8`); loader/registry internals `[U]` | Static-only sweep (no GPU needed, still owner-authorised native session): xref VAs 0x82f060/0x82f114/0x739bf8/0x82f86c; decompile each caller (≤5 passes each); record which caller writes `h+0x50` (target), `h+0x200`, and any `glTexImage2D` upload reachable from the height object | **Terminate iff every caller is enumerated with VA + sampled disassembly and the `h+0x50`/`h+0x200` writers are identified with 0 unvisited xrefs remaining** in the xref tool output. Until then loader/registry prose stays `[U]` |

General rule: captures on the wrong shader path (BUILTIN embedded pair has **no** hmap uniforms, `ev_5dc9…`/`ev_ce22…`) do not settle any row above. Any mismatch, or a closed height gate, leaves the item `[U]` and the port keeps the labelled substitute + hard-fail posture.

---

## 7. Exact port change list — `water3d.gd` / `water3d.gdshader` (file:line; NO edits made — owner applies)

All lines verified by repo read this ticket. **Wire only captured reals. Preserve the BUILTIN `[D]` default and the U12 hard-fail in every diff. `visual_parity_claim=false` stays.**

1. **`variant3d/scripts/water3d.gd:68` (`MAX_HEIGHT=2.96`) + `:611-617` (alpha encode) + `water3d.gdshader:50` (`max_height`) / `:182-191` (`height_map`)** — KEEP SUBSTITUTE + LABELS. After a §6 U3-NUM capture on the target map only: replace the `±MAX_HEIGHT` span in both encode (`(hval+MAX)/(2*MAX)`) and decode (`-max_height + w*(2*max_height)`) with the captured `(hmapMin,hmapMax)` pair, keeping the `hmapMin + w*(hmapMax-hmapMin)` DEV formula shape verbatim. Until then keep `±2.96` but keep the `texturemap.inc:29 classification, NOT donor hmapMin/Max (DEC-U §3 MH)` comments. FORBIDDEN: presenting `±2.96` as recovered.
2. **`variant3d/scripts/water3d.gd:450-458` (`bind_height_grid`) + `:619-620` (`height_tex`, `map_size`) + `water3d.gdshader:68-69`** — KEEP SUBSTITUTE. After §6 U3-TEX capture only: add a `bind_engine_hmap(real_texture, target_enum)` path that imports the captured `(target,name)` provenance (FBO attachment import or captured copy target — never generated solid-colour, never `diffusewaves*`/`heightmapwaves0` art unless a capture proves identity) and routes it to the `hmapTex` sampler; keep `bind_height_grid` as the explicitly-labelled fallback grid source with its `(x+0.5)/w` `[U6]` encoding note (`water3d.gd:554-555`, shader `:362`). Until then `height_tex` stays `[U3]`.
3. **`variant3d/scripts/water3d.gd:624-633` (LEGACY `hmapTex/hmapW/hmapH/hmapMin/hmapMax`) + `water3d.gdshader:144-151`** — KEEP GATED SUBSTITUTE. After §6 U3-NUM/U3-TEX captures only: set `hmapW/H` to the captured ints (not `_grid_w/_grid_h`), `hmapMin/Max` to the captured floats (not `∓MAX_HEIGHT`), `hmapTex`/`hmapTexBound` from the captured texture (not `height_img`). Until then keep current binds + the `engine values are [U3]` comment at `:627-629` and the `[U3]` suffixes at shader `:144-147,151`. Extend the gate to require the §6 height-gate replica (`engine_hmap_valid = (obj != null) and gl_name_valid`) before setting `hmapTexBound=true`; closed ⇒ `push_error` + no LEGACY water, never a neutral texel.
4. **`variant3d/scripts/water3d.gd:143-147` (uniform-table `hmapTex/W/H/Min/Max` rows) + `:305` (`hmapMin_hmapMax` stats) + `:857-877` (variant/uncertainty ledger)** — LABEL-ONLY diff (no capture needed): cite this report's chain (`FUN_008520a8 → FUN_00739bf8 → FUN_0082f86c → FUN_0082f060/114`; unit `C+0xdc` ctor 2; target `C+0xd8` ctor `0xde1`; gate VA 0x854250) in each row's `source` field; keep every `[U3]` tag until §6 terminates.
5. **`variant3d/scripts/water3d.gd:163` + `water3d.gdshader:102` (BUILTIN labelled default) and `:520-527`/`343-353` + shader `:107-108,365-366` (U12 hard-fail)** — KEEP AS-IS. Unrelated to hmap but load-bearing for the same draws: do not flip to DEV/LEGACY to "make hmap appear", and do not call any new `bind_engine_hmap()` from `_make_water3d` with a non-captured texture.
6. **FORBIDDEN (violates donor faithfulness):** binding `heightmapwaves0.tga` / `diffusewaves0/2` / a 1×1 neutral texture as `hmapTex`; hard-coding a shipped-map `(W,H,Min,Max)` tuple from `map_size`, `128`, `2.96`, or any forum/guess value; inventing a `HeightMapTexUnit` number for `water.lib`; emulating `[C+0xe0+8]` as a GL name without the U3-TEX capture; adding a scale/bias conversion between the getters and the uniforms.

---

## 8. Explicit non-claims and file discipline

- **No parity claim.** No donor binary executed, no GPU frame captured, no port capture compared by this worker. All readings are re-cited `[O]/[D]`; all unsettled values are `[U]` with §6 captures.
- **No approximation substituted.** No texture name/size, no unit override, no shipped-map `(W,H,Min,Max)` tuple, no conversion factor is supplied in this report. The port's current behaviour (decoded-grid `height_tex`/`hmapTex` substitute explicitly labelled `[U3]`, `±2.96` span explicitly labelled `[U3]`, no invented texture) is endorsed as the donor-faithful behaviour until the corresponding zero-mismatch capture lands.
- **Read-only compliance.** Exactly one repo file written: `docs/terrain_swarm_2026-11-26/reports/DEC_U_hmap_identity.md`. No code/shader/asset/config/Godot/git change. No donor file opened for write or executed. No other worker target touched.

*End of DEC-U-HMAP-IDENTITY.*
