---
id: DEC-U-HMAP-NUM-DEEP
worker: DEC-U-HMAP-NUM-DEEP (subagent in full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
ticket: "NUMBERS deep: static attack on shipped-map hmapMin/Max/W/H; new angles on *.map bytes, caller scan, water.mat/lib/inc literals, height formula vs port substitute; GL/map byte-dump zero-mismatch experiments; no parity claim"
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
labels: [O, D, I, U]
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. No donor binary executed, copied or committed. No donor file written."
scope_guard: "No repo code/asset/config/shader/Godot/git edit. Exactly one repo file written: this report."
multi_pass: true
visual_parity_claim: false
upstream: "DEC_U_hmap_identity.md (identity chain FUN_008520a8 -> FUN_00739bf8 -> FUN_0082f86c(*(h+0x200)), C+0xdc/d8/e0, gates +0xb9/+0xc0); D04_map_format.md (TerrainMapBegin layout, height clamp, count anomaly); D03_mask_pipeline.md (generatemap.inc formula); DEC_U_water_runtime.md §5 / DEC_U_water_capture.md Phase 4 (caller scan); DEC_U_water_lib_params.md (MaxHeight absent); variant3d/scripts/water3d.gd + water3d.gdshader (port substitute)"
---

# DEC-U-HMAP-NUM-DEEP — shipped-map hmapMin/Max/W/H numbers, new static angles (read-only)

## 0. Authority and discipline (read first)

Every statement is `[O]` (verbatim bytes/text/decompiled instruction or verbatim port/donor file line re-read this ticket), `[D]` (deterministic control-flow/arithmetic from `[O]`), `[I]` (interpretation) or `[U]` (UNVERIFIED — settling experiment in §6; port must **hard-fail, never invent a number or texture**). This worker issued **no Craft Anything native lifts** (subagent context: only repo/doc/donor-text reads via default tools); all donor VAs/evidence ids below are **re-cited pinned records** from `DEC_U_hmap_identity.md` / `D04_map_format.md` / `D03_mask_pipeline.md` / `DEC_U_water_runtime.md` / `DEC_U_water_capture.md`, each pinned `document:"t_87f0f3c130b0"`, Deep mode. No donor binary executed, no GPU frame captured, no parity claimed. Donor `*.map` files were listed and donor `.inc/.lib/.mat` files were read as text only; no donor file written. One repo file written: this report.

`[D]` load-bearing result: **no shipped-map hmapMin/Max/W/H number can be promoted to `[D]`**. All four live values remain `[U]` per map. The port `±2.96` span stays a labelled substitute. Only byte-proven literals below are `[D]`; everything numeric about a live draw is `[U]` with §6 zero-mismatch experiments.

---

## 1. Pass ledger (owner rule ≤5 passes/function; every pass logged)

New passes this ticket are document/text/byte-record re-analysis only. No function exceeded budget.

| # | New angle | Passes this ticket | Result |
|---|---|---|---|
| N1 | Shipped `*.map` directory + D04 byte layout re-read for embedded height-map objects near `+0x200`/`+8`/`+0xc` | 1 re-read: donor `data/maps/missions/` listing + `D04_map_format.md` §§2–5 | **Accepted**: 31 `.map` + 31 `.aix` present incl. `ausmis1.map`, `battle1.map`; terrain block = W/H headers + `(2W)^2` tag grid + f32 heights + `W*H*37` records; **no** embedded dimension/min/max object header found — numbers live in engine objects, not in map bytes (§2) |
| N2 | `FUN_0082f060` / `FUN_0082f114` caller scan beyond `FUN_008520a8` + literal-argument check | 1 re-read: `DEC_U_hmap_identity.md` §§4.3/5 + `DEC_U_water_runtime.md` §5 + `DEC_U_water_capture.md` Phase 4 + `PORT1TO1_water_shore.md` §§4/7 | **Accepted as bounded**: only recovered caller is `FUN_008520a8`; no second caller, no literal min/max argument in re-read corpus → whole-binary list stays `[U]` (§3) |
| N3 | `water.mat` + `water.lib` + `texturemap.inc` numeric-candidate triage (live vs classification) | 1 fresh text read each: donor `data/water/water.lib` (71 lines), `data/water/water.mat` (106 lines), `data/scripts/common.inc/texturemap.inc:1-963` | **Accepted**: exhaustive candidate table in §4; no `MaxHeight`/`HeightMapTexUnit`/min/max key in `water.lib`; `HeightMapWaves0` fully commented in both files; `cMaxHeight=2.96` is classification-only |
| N4 | Donor height formula vs port substitute relation | 1 fresh text read: donor `data/scripts/common.inc/generatemap.inc:4-7,567-574` + re-read `variant3d/scripts/water3d.gd:68,652,668-669,763` | **Accepted**: formula `hwater+hterrain` is real DScript text; it does **not** flow through `C+0xe4/+0xe8`; port `±2.96` cites `texturemap.inc:29`, not the getters (§5) |
| N5 | Port substitute line verification (repo HEAD) | 1 grep+read: `variant3d/scripts/water3d.gd` hmap/MAX_HEIGHT lines | **Accepted as `[O]`**: `MAX_HEIGHT=2.96`, encode `(hval+MAX)/(2*MAX)`, binds `hmapMin=-MAX_HEIGHT`, `hmapMax=+MAX_HEIGHT`, all labelled `[U3]` (§5) |

No `wgl`/FBO/`glTexImage2D` water-anchored hit is added by N1–N5; that absence is bounded by the re-read corpus, not a whole-binary proof.

---

## 2. Angle (a) — shipped `*.map` artifacts: no byte-proven hmapMin/Max/W/H [O]/[D]/[U]

### 2.1 What was inspected [O]

- Donor mission directory listing (read-only, this ticket): `C:\Games\Cossacks 3\data\maps\missions\` contains 31 `.map` + 31 `.aix`, including the ticket-named `ausmis1.map` and `battle1.map` alongside `bonmis1.map`, `engmis4.map`, etc.
- Byte-verified layout re-read from `D04_map_format.md` (specimens `bonmis1.map` 23,447,543 B W=320, `engmis4.map` W=320, `battle1.map` 56,117,715 B W=384): serializer `sub_739d3c` (`0x739d3c`) / loader `sub_73a0b8` (`0x73a0b8`), markers `TerrainMapBegin … TerrainMapEnd`, stream API (`+0xc` read / `+0x10` write).
- On-disk terrain block (file offsets for `bonmis1.map`: marker `mk=0x8d8a7d`, `mk+15` W/H, `mk+31` tag grid, `grid_off=0xa68acd` heights, `tile_off=0xacd4c9` records): `u32 W, u32 H, u8 sub=4, u32 tilepx=64` → `(2W)×(2H)` u32 tag grid → 41-byte gap (`u32 256` + 37 zeros) → `u32 W, u32 H` second header → LE `f32` height grid → `W×H` 37-byte tile records → MergeCamera/Modules sub-streams.

### 2.2 Negative result on the `+0x200` / `+8` / `+0xc` offsets [D]

`[D]` The recovered engine offsets `layerObj+8` (hmapW source), `layerObj+0xc` (hmapH source), `h+0x50` (target source), `h+0x200` (height sub-object) are **runtime object-field offsets** in `FUN_008520a8`, not map-file field offsets. The `.map` terrain block contains **no object header with dimension/min/max fields at those relative positions**:

- `mk+15` / second-header W/H are plain `u32` grid extents (320 / 384 in specimens), not the engine `layerObj+8/+0xc` words — no static link from map bytes to the live `layerObj` words is recovered.
- The height grid is a flat LE `f32` array (observed count `(W+1)^2−2` vs writer loop `(W+1)^2`; D04 U1). It carries **no per-grid min/max header**; min/max are computed by engine getters `FUN_0082f060/0082f114` at draw time, not stored alongside the grid.
- The 37-byte tile records are `24 B + 13 B` (`stride 0x18` + `0xd`); bytes 8–11 are four `u8` tile ordinals, bytes 16–31 are four `1.0f` weights, byte 36 is loader-set `1`. No float min/max pair and no `(W,H)` dimension pair sits at any record-relative `+8/+0xc`/`+0x200` position.
- `ausmis1.map` was **not** among the D04 byte-decoded specimens (specimens: bonmis1/engmis4/battle1). No `ausmis1.map`-specific height min/max, W/H header, or clamp value is stated here; citing D04 numbers for `ausmis1.map` would be invention.

### 2.3 Only byte-proven height numbers [D] vs live-uniform numbers [U]

`[D]` byte-proven from D04 specimens (do **not** wire as uniforms): heights are LE `f32`, row-major, stride `W+1`; observed clamp `±2.9639999866`; dominant values `0.0`, `-1.1`, `+2.964` in bonmis1/engmis4; `FFFF` marker in 102,399/102,400 (bonmis1) and 147,455/147,456 (battle1) records with record 0 zero.

`[U]` The live draw tuple `(hmapW, hmapH, hmapMin, hmapMax)` for **any** named shipped map (`ausmis1.map`, `battle1.map`, or retail default) is not derivable from the map bytes statically: `hmapW/H` are `layerObj+8/+0xc` int32 copies and `hmapMin/Max` are getter returns on the loaded `+0x200` object (§3 of `DEC_U_hmap_identity.md`), and the loader internals mapping file bytes → those words are unrecovered. §6 U-NUM/U-MAP experiments settle per-map values.

---

## 3. Angle (b) — callers of `FUN_0082f060` / `FUN_0082f114` and literal arguments [O]/[D]/[U]

`[O]` Re-read corpus standing (unchanged by N2): the **only recovered caller** of both VAs `0x82f060` / `0x82f114` is `FUN_008520a8` (`0x8520a8`):

```
C+0xe4 = (float) FUN_0082f060(*(h+0x200))   // hmapMin → 7e.80
C+0xe8 = (float) FUN_0082f114(*(h+0x200))   // hmapMax → 7f.1
```

with gates `layerObj==0 || waterDesc==0 || layerDesc+0xb9==0 → C+0xe0=0` (`ev_ada1…`; `DEC_U_hmap_identity.md` §4.1).

`[D]` In the recovered call sites there are **no literal min/max arguments**: both takes are single-pointer calls (`*(h+0x200)`); the `(float)` cast and the `push [C+0xe4]/[C+0xe8]` to the `glUniform1f` wrapper `FUN_004c0f90` (ptr `0x8fc724`) are identity passthroughs with no scale/bias operand. No `push 2.96`, `push -1.1`, or map-size literal appears at these call sites in the re-read pseudo/bytes (`ev_ada1…`, `ev_bbdb…` 0x854080–0x8542f0).

`[U]` Whole-binary caller enumeration of `0x82f060` / `0x82f114` (plus callee identification of `FUN_00739bf8` / `FUN_0082f86c`: who writes `h+0x50`, `h+0x200`, and any `glTexImage2D` upload reachable from the height object) is **not** in the re-read corpus. `DEC_U_water_runtime.md` §5 / `DEC_U_water_capture.md` Phase 4 contain no map-loader/terrain-generator/texture-registry caller; that bounded absence is not a whole-binary proof. §6 U-REG sweep (static-only, ≤5 passes per new caller) terminates it. No second caller is invented here.

---

## 4. Angle (c) — `water.mat` / `water.lib` / `texturemap.inc` numeric triage [O]/[D]

Fresh text reads this ticket. Only exact verbatim values are `[O]`; classification-vs-live separation is `[D]`.

### 4.1 `water.lib` (71 lines) — exhaustive [O]

| Line(s) | Verbatim `[O]` | Standing `[D]` |
|---|---|---|
| :5–8 | `MaxDepth = 1`, `MinDepth = 0`, `MaxAlpha = 1.1`, `MinAlpha = 0` | Depth/alpha envelope, not hmap span; never flows to `C+0xe4/+0xe8` |
| :9–20 | `DeepColor = (0, 0, 0.1255, Alpha 0.5)`; `ShallowColor = (0, 0, 0, Alpha 0.5)` | Water colour; unrelated to height object |
| :21–25 | `ReflectionAmount = 1`, `WaterAmount = 1`, `FresnelPower = 1`, `FresnelBias = 1`, `HDRMultiplier = 1` | Scalar ones; not dimensions or min/max |
| :26–29 | `WaveFreq = 0`, `WaveAmp = 0`, `DistFactor = 1`, `BumpFactor = 1` | Wave/noise envelope; not hmap numerics |
| :32–33 | `TexScaleS = 0.1`, `TexScaleT = 0.01` | UV scales for wave samplers; not hmap W/H |
| :34–37 | `WaveDir0 = (-1, 0)`; `WaveDir1 = (-0.7, 0.7)` | Directions; not heights |
| :42 | `Speed = 1.0` | Time rate; not min/max |
| :43–46 | `NormalMapLibMaterialName = DiffuseWaves2`, `DiffuseMapLibMaterialName = DiffuseWaves0`; `//NormalMapLibMaterialName = HeightMapWaves0`, `//DiffuseMapLibMaterialName = DiffuseWaves0` | Live samplers are wave maps; `HeightMapWaves0` is **commented, inert** |
| :47–50 | `Width = 1`, `Height = 1`, `Offset = 0.495`, `LayerCount = 1` | Layer descriptor scalars; `Width/Height = 1` are **not** hmapW/H (live hmapW/H come from `layerObj+8/+0xc`) |
| :51–59 | `CustomEnable = False`, `CustomTexCoord = True`, `CustomTexCoordScale = 1`, rest unset/False/0 | Custom path disabled; no override |
| :60–61 | `HeightMapEnable = True`, `ShadowMapEnable = True` | **Only live HeightMap fact**: gate bit `layer+0xb9`; no number |
| :64–70 | `MaterialLibraryFileName = .\data\water\water.mat`, `DefaultWaterIndex = 0`, `Tag = 512`, shaders `water.dev.vert/frag` | Registry pointer; no min/max/dims |
| absent | No `MaxHeight`, no `HeightMapTexUnit`, no other `HeightMap*` key in 71 lines | `[D]` No numeric span, no unit, no texture filename comes from `water.lib` |

### 4.2 `water.mat` (106 lines) — exhaustive [O]

| Lines | Verbatim `[O]` | Standing `[D]` |
|---|---|---|
| :1–21 | live `DiffuseWaves0`: `Image = .\data\water\textures\diffusewaves0.bmp`, `tfLuminance`, `twBoth`, `miLinearMipmapLinear` | Wave sampler; unrelated to hmap path (`waveMap = C+0xfc`) |
| :32–39 | live `DiffuseWaves2`: `Image = .\data\water\textures\diffusewaves2.bmp` (refkey=base) | Normal-slot holder is luminance art; not a heightfield |
| :23–30, :41–84 | `DiffuseWaves1/3/4/5/6/7` blocks, every line `//`-commented | Inert |
| :86–106 | `HeightMapWaves0` block (`Image = .\data\water\textures\heightmapwaves0.tga`, `tfNormalMap`), **every line `//`-commented** | `[D]` Inert: names no live texture; D06 P18 alpha-255 disproves height substitution |

`[D]` `water.mat` contributes **zero** live numbers to `hmapW/H/Min/Max` or `hmapTex`.

### 4.3 `texturemap.inc` classification literals — distinguished [O]/[D]

| Line | Verbatim `[O]` | Standing `[D]` |
|---|---|---|
| :29 | `const cMaxHeight = 2.96;` | Script-stage **classification** literal; absent from `water.lib`; never flows through `C+0xe4/+0xe8`; port substitute source only |
| :30–31 | `const cWaterHeight = -0.25;` (= render threshold), `const cWaterShoreHeight = -0.1;` | Shore/ water classification thresholds (used with `gMapMask.b>0`, `:68-75`); **not** hmapMin/Max |
| :14, :27 | `cBWater = 1`, `cBColorWater = 255` | Mask codes; not heights |
| `:53-130` etc. | `cDiff1 = 0.5`, `cDiff2 = 0.55`, angle `cAngle = 45`, rock `2.7/2.4/0.1` | Collision/tile art thresholds; not hmap numerics |

`[D]` None of the §4 literals is a donor `hmapMin/Max/W/H` value. Wiring any of them (`2.96`, `-0.25`, `-0.1`, `1`, `0.495`, `0.1/0.01`, `512`) as a uniform would conflate classification/script text with engine getter outputs.

---

## 5. Angle (d) — donor height formula vs port `±2.96` substitute [O]/[D]/[U]

### 5.1 Donor formula, verbatim [O]

Donor `data/scripts/common.inc/generatemap.inc` (fresh read, DScript text, every donor code line stored `[*] = ;…`):

- `:4-7`: `const cPlateauHeight = 2.964;` `const cHillHeight = cPlateauHeight/2.25;` (= 1.31733…), `const cRavineHeight = -2.964;` `const cWaterHeight = -1.1;`
- `:567-574`: `var hwater : Float = cWaterHeight*(fb*(1+fr*3.5));` with `case terrain of cRPlateau: hterrain := cPlateauHeight*fr; cRHill: hterrain := cHillHeight*fr; cRRavine: hterrain := cRavineHeight*fr;` then `SetHeightData(realx, realy, hwater+hterrain)` where `fr/fb ∈ [0,1]` are mask channels.

`[D]` Combined intended shape: `h = -1.1*fb*(1+3.5*fr) + {2.964 / 1.31733… / -2.964}*fr`. Per `D03_mask_pipeline.md`, the `2.964/1.317/-2.964/3.5` f32/f64 byte patterns do **not** occur in `cossacks.exe`/`editor.exe` — the formula is DScript text parsed at runtime, and shipped `.map` heights additionally carry pattern stamps and smoothing that the mask formula alone does not explain. It is therefore a **generation-stage intent**, not a measured live-uniform value.

### 5.2 Port substitute, verbatim [O]

Repo HEAD `variant3d/scripts/water3d.gd`:

- `:68`: `const MAX_HEIGHT: float = 2.96  # texturemap.inc:29 cMaxHeight — … Port span [-2.96,+2.96] is a [U3] SUBSTITUTE, NOT a donor-recovered hmapMin/hmapMax`.
- `:652`: `var a: float = clampf((hval + MAX_HEIGHT) / (2.0 * MAX_HEIGHT), 0.0, 1.0)` (alpha encode).
- `:668-669`: `_material.set_shader_parameter("hmapMin", -MAX_HEIGHT)` / `("hmapMax", MAX_HEIGHT)`; `:763`: `("max_height", MAX_HEIGHT)`.
- `:143,146-147,305,346,909,913,940`: every hmap row carries an explicit `[U3]` source tag citing the engine chain and the substitute status.

`[D]` Relation: the port encode/decode mirrors the DEV shader formula shape `hmapMin + w*(hmapMax-hmapMin)` (`water.dev.frag:70-75`, re-cited in `water3d.gdshader:182-191`) with the **substitute span** `(−2.96, +2.96)`. The `2.96` cites `texturemap.inc:29` (classification), **not** `generatemap.inc:4-7` (`2.964`/`1.31733…`/`-1.1`) and **not** the engine getters `FUN_0082f060/0082f114`. The 0.004 gap (`2.96` vs `2.964`) alone proves they are distinct literals; neither is a measured uniform.

`[U]` Whether the live engine `(hmapMin, hmapMax)` for a shipped map numerically coincides with `(−2.96, +2.96)`, `(−2.964, +2.964)`, the D04 clamp `±2.9639999866`, the `k_ravine_1` stamp range `(−2.9636, +3.1398)`, or none of these is unsettled — §6 U-NUM measures it per map. The port must keep the `[U3]` labels and must not re-label `±2.96` as recovered.

---

## 6. `[U]` register — zero-mismatch experiments (owner-authorised donor session only; forbidden to workers)

Gating precondition for **every** row: water field visible (break `FUN_00603d30` @ `0x603d30`, read `[ebp+0x1c]`); live path identified first (hook `glShaderSource`: `hmapTex` present = DEV file pair, `alphaDepth`/`deepColor` = BUILTIN embedded pair); height gate open at `0x854250` (`C+0xe0 != 0 && [C+0xe0+8] != 0` — closed gate voids the frame).

| # | Still-`[U]` item | Static state after this pass | Experiment (break + trace + byte comparison) | Zero-mismatch termination |
|---|---|---|---|---|
| U-NUM | Live `(hmapW, hmapH, hmapMin, hmapMax)` for a named shipped map (`ausmis1.map`, then `battle1.map`) | `[D]` sources: `layerObj+8/+0xc` int32 copies; `(float)FUN_0082f060/0082f114(*(h+0x200))` identity passthrough; gate proven. Values per-map `[U]` | Break `FUN_00854054` bits 7e.10–7f.1 (`0x854250–0x8542f0`) with the named map loaded + field visible. Record pushed `C+0xd0/+0xd4` ints, `C+0xe4/+0xe8` floats **plus** chain pointers (`layerObj`, `h`, `h+0x200`, `C+0xe0`, `[C+0xe0+8]`) and same-draw `glUniform1i/1f` hook values on `hmapW/H/Min/Max` locations. Log map name + `water.lib` hash | **Terminate iff the same 4-tuple repeats with 0 differing bits across ≥2 frames + 1 camera move** on that map; those 4 numbers (not `map_size`/`±2.96`/`±2.964`) become the port parameters for that map only. A second map needs its own row |
| U-MAP | Map byte-dump vs live-tuple linkage (does file W/H or height min/max predict the uniform?) | `[D]` file W/H headers + flat f32 grid + clamp `±2.9639999866` (D04 specimens); `[U]` file→engine-word mapping | With the same map loaded, dump the terrain-block W/H headers + full f32 grid (min, max, mean, histogram) from the file bytes per D04 §5 recipe, then compare against the U-NUM live tuple from the same session. Test hypotheses in order: (i) `hmapW/H == file W/H`; (ii) `hmapMin/Max == file grid min/max`; (iii) neither | **Terminate iff one hypothesis holds with 0 mismatching bits/floats across the dumped map + U-NUM frames**, else record `neither` and keep the port substitute. Never overwrite file bytes to force a match |
| U-TEX | `hmapTex` GL identity `(target, name, w, h)` + provenance (upload vs copy vs FBO) | `[O]` unit `C+0xdc` (ctor 2), target `C+0xd8` (ctor `0xde1`); `[U]` name/provenance/size | At the same break record `glActiveTexture(GL_TEXTURE0+u)`, `glBindTexture(target,name)`, `glGetTexLevelParameteriv(name,0,{WIDTH,HEIGHT,INTERNAL_FORMAT})` + sampler state, and full-frame history of `name`: (a) FBO attachment, (b) `glCopyTexImage2D/SubImage2D` dst, (c) `glTexImage2D` upload-only. Dump 8×8 texel block + channel carrying height | **Terminate iff the same `(target,name,w,h)` repeats with 0 mismatches across ≥2 frames** and exactly one provenance class accounts for `name` with 0 counter-examples across frames + move. Else keep `bind_height_grid` substitute labelled `[U3]` |
| U-REG | Whole-binary callers of `0x82f060`/`0x82f114` + writers of `h+0x50`/`h+0x200` (loader/registry internals) | `[O]` one caller (`FUN_008520a8`); loader/registry `[U]` | Static-only sweep (no GPU): xref `0x82f060/0x82f114/0x739bf8/0x82f86c`; decompile each new caller (≤5 passes each); record VA + sampled disassembly + which caller writes `h+0x50`/`h+0x200` and any reachable `glTexImage2D`/FBO writer | **Terminate iff every xref is visited with 0 unvisited xrefs remaining** in tool output. Until then loader prose stays `[U]` |

General rule: captures on the BUILTIN path (no hmap uniforms) settle nothing. Any mismatch or closed gate leaves the item `[U]`; the port keeps the labelled substitute + hard-fail posture. No parity claim follows from termination — termination only authorises wiring the captured reals for the captured map.

---

## 7. Exact port stance (file:line; NO edits made — owner applies)

All lines verified at repo HEAD this ticket. **Wire only captured reals.**

1. `variant3d/scripts/water3d.gd:68,652,668-669,763` (`MAX_HEIGHT=2.96`, encode, `hmapMin/Max`, `max_height`) — KEEP SUBSTITUTE + `[U3]` LABELS. After U-NUM on the target map only: replace `∓MAX_HEIGHT` in both encode and decode with the captured `(hmapMin,hmapMax)`, keeping DEV shape `hmapMin + w*(hmapMax-hmapMin)`. FORBIDDEN: presenting `±2.96`/`±2.964`/clamp/`k_ravine_1` numbers as recovered.
2. `variant3d/scripts/water3d.gd:486+` (`bind_height_grid`), `:655` (`height_tex`), hmap binds `:663-669` — KEEP SUBSTITUTE. After U-TEX only: add `bind_engine_hmap(real_texture, target_enum)` from captured provenance; never generated solid-colour, never `diffusewaves*`/`heightmapwaves0` art unless captured.
3. Uniform-table `:143,146-147`, stats `:305,346`, ledger `:909,913,940` — LABEL-ONLY (no capture needed): keep `[U3]` tags + engine-chain citations (`FUN_008520a8 → FUN_00739bf8 → FUN_0082f86c → FUN_0082f060/114`; unit `C+0xdc` ctor 2; target `C+0xd8` ctor `0xde1`; gate `0x854250`).
4. FORBIDDEN: hard-coding any shipped-map `(W,H,Min,Max)` from `map_size`, `128`, `2.96`, `2.964`, `±2.9639999866`, `−1.1`, `3.5`, `1.31733`, `0.495`, `0.1/0.01`, `512`, or forum values; inventing a `HeightMapTexUnit` number; emulating `[C+0xe0+8]` as a GL name; adding a scale/bias between getters and uniforms.

---

## 8. Explicit non-claims and file discipline

- **No parity claim.** No donor binary executed, no GPU/map-live capture performed by this worker. All live numbers stay `[U]` pending §6.
- **No approximation substituted.** No shipped-map `(W,H,Min,Max)` tuple, no texture name/size, no conversion factor is supplied. The port's decoded-grid `height_tex`/`hmapTex` + `±2.96` span, both explicitly labelled `[U3]`, is endorsed as the donor-faithful behaviour until the corresponding zero-mismatch capture lands.
- **Read-only compliance.** Exactly one repo file written: `docs/terrain_swarm_2026-11-26/reports/DEC_U_hmap_num_deep.md`. No code/shader/asset/config/Godot/git change. No donor file opened for write or executed. No other worker target touched.

*End of DEC-U-HMAP-NUM-DEEP.*
