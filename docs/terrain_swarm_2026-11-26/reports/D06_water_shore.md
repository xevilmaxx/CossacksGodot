---
id: D06
wave: D (donor binary / Ghidra)
ticket: "Water level, shore smoothing, hmapTex binding, shader constants, shore-tile and bridge rules"
date: 2026-11-26
status: DELIVERED__READ_ONLY__NO_DONOR_EXECUTION__NO_SOURCE_EDIT
labels: [O, D, I, U, "PORT APPROXIMATION"]
donor: "C:\\Games\\Cossacks 3 (READ ONLY; private use; no donor binary executed, no donor file copied into repo, no git/source/Godot edit)"
target_used: "Craft Anything active target t_87f0f3c130b0 = cossacks.exe, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c, Deep mode; NO core_target_open/core_target_select was issued by this worker (the target was already active and was pinned by `document=` on every call)"
prior_art_read: "G26_water_shore.md, P13_water_fix_proposal.md, T6_S02_water_bindings.md, DTRN_03_donor_shore_water.md, RV_TRN_03_water_bindings.md, DECOMP_04_strings_config.md, CORRECTIONS.md, DE_AUDIO_UI.md index"
multi_pass: true
visual_parity_claim: false
---

# D06 — donor water / shore chain, decoded from binary + data (2026-11-26)

## Executive summary

1. **[O] Three different “water levels” exist and must not be conflated.** Generation basins use `cWaterHeight = −1.1` (`generatemap.inc:7`); generated water *fields* are added at `cOffsetY = −0.5` (`generatemap.inc:688,704`); tile classification uses `cWaterHeight = −0.25` and `cWaterShoreHeight = −0.1` (`texturemap.inc:29-31,463-472`). The shader compares the per-pixel terrain height to an engine-supplied plane Y plus a small animated perturbation (`water.dev.frag:167,170-176`). The `−0.5` field Y is a **new donor datum recovered this ticket**; it remains comment-prefixed GSC text, so its runtime execution is `[U]`.
2. **[O] Shoreline height smoothing is an exact, observable 3-pass chain**, not a generic blur: `SmoothTerrain(...,radius 3)` on mask `bsmooth` cells, one whole-map `_misc_SmoothTerrainCustom(...,power=4,lerp=0.5,h∈[0.01,100])`, then **3 passes** of `power=0.35, lerp=0.5, h∈[−100,−0.01]` on any cell whose 5×5 neighbourhood (radius `2`) contains water (`generatemap.inc:580-643`; `:218-245`). Tile smoothing is a separate **3-pass** pair of horizontal/vertical sweeps (`smoothtiles.inc:191-237`) despite `globalparams.cfg:9` advertising `TileSmoothPasses = 6` — contradiction recorded, not resolved `[U]`.
3. **[O] `hmapTex` is a *water-parameter key*, not a recovered texture.** Deep Ghidra decompiled `FUN_00853ad4` at VA `0x853ad4` (file `0x453ad4`): it assigns 30 string keys into `[obj+0x04 … +0x78]`, with `hmapTex` at `+0x54`, `hmapW +0x58`, `hmapH +0x5C`, `hmapMin +0x60`, `hmapMax +0x64`, and loads a global f32 `1.99999988` into `+0x7c`. **No texture lookup, sampler unit or GPU bind is present.** The shader uses `hmapTex.w` only for the per-pixel depth test (`water.dev.frag:70-75,170,176-199`); `heightmapwaves0.tga` has alpha 255 on all 65,536 pixels and is commented out — it cannot be `hmapTex` (`water.mat:86-106`, direct TGA decode this ticket).
4. **[O] Shore tiles are `sandsea1/5/6` only**, selected by an 8×45° height-gradient sector table on cells with `mask.b>0 ∧ (h<−0.25 ∨ h<−0.1)` (`texturemap.inc:463-528`); smoothing weights are `sandsea5=0.7`, `sandsea6=0.3` and `rock9/rock8/rock5=0.0` (`tilesmooth_scripts.cfg:5-66`). The cliff path is a *different* asymmetric 6-branch table with `|h|>2.7→rock8`, `>2.4→rock4`, `<0.1→none` (`texturemap.inc:559-609`).
5. **[O] Bridges are explicit objects plus collision painting**, not a terrain tile class: `_misc_CreateBridge` (`misc.script:5271-5346`) uses `cScale=1.15`, `cBaseHeightOffset=0.4876`, block width `2.81*scale`, end widths `1.78*scale`, offsets `1.07*scale`, collision radius `3`, step `2`, tag `10`; water-border collision uses radius `gc_WaterBorderSize=3` (`dmscript.global:819`). **`fordtyp` is a squad *formation-type* field, not a terrain ford** (`classes.script:4201`, `misc.script:2911`) — no ford-generation rule was found in `data/**` `[U]`.
6. **[O] Shader constants and composition were re-read verbatim this ticket**: coast fade 0.57, deep fade 1.07, exponents 170/120, particle 30, colours `(0.1,0.24,0.24)` / `(0,0.025,0.05)` / `(0.4,0.4,0.4)`, `m=mat2(0.72,−1.60,1.60,0.72)`, shifts `(0.32t,0.24t)` / `(0.38t,−0.26t)`. Fresnel and DeepColor/ShallowColor are **commented out** in the shipped fragment; `shaders.lib` has **zero** `water|fresnel|current|glint` matches. No donor-parity claim is made.

---

## 1. Method and multi-pass ledger

Authority: donor read-only; every claim is `[O]` (observed bytes/lines/instructions), `[D]` (arithmetic/control-flow from observations), `[I]` (interpretation) or `[U]` (UNVERIFIED). All Craft Anything calls passed `document="t_87f0f3c130b0"`; no global target was changed. Python helper scripts were written **outside the repo** (`%LOCALAPPDATA%\Temp\opencode\d06_*.py`) and read donor files with `open(...,'rb')` only.

Owner directive compliance: whenever a function, threshold or binding looked strange/contradictory, **multiple passes were run and each pass is recorded below** with the reason it was accepted or rejected. Nothing was silently skipped.

| Pass | Tool / input | Result | Accepted? and why |
|---|---|---|---|
| P1 | `native_strings_find` `XWater` (evidence `ev_9ece6185dd164e5910ef585c632942689d8d5d6c908bc7e2fed58dd33c770ae9`) | 3 `.rsrc` strings: `$XWaterShader` @ `0x958c10`, `fXWaterField` @ `0x95937b`, `XWater` @ `0x95938a` | **Accepted as RTTI only** — no code reference; not a function anchor. |
| P2 | `native_functions_search` for `XWater`, `Water`, `Shore`, `Bridge`, `Ford`, `Smooth`, `XTileSmooth`, `MapGetTileIndexByTileBlock`, `XWaterShader` (`ev_78c90e92…`, `ev_c9f669a0…`, `ev_d2ac8564…`, `ev_1d58b1a2…`, `ev_9c72157b…`, `ev_3bf471c3…`, `ev_a7b690e2…`, `ev_b830f06a…`, `ev_f63212a6…`) | 0 functions, 0 imports for all; limitation `instruction_limit` (6,000,000 instructions) | **Rejected as naming strategy** — Delphi names are stripped; name absence is not function absence. |
| P3 | `core_feature_find("hmapTex")` (`ev_eab32206dbca80e3b6115a716fe408ea66b320c4fd60812cf9e82816738ccf48`) | 0 strings / 0 functions / 0 imports | **Rejected as absence proof** — tool sees data sections only; key lives in `CODE`. |
| P4 | `native_bytes_find` text `hmapTex` over whole exe (prior `ev_1bd891e2…`) | 1 match, VA `0x853e0c`, file `0x45320c`; Delphi AnsiString header `ffffffff 07000000` immediately before it | **Accepted** — the key exists exactly once. |
| P5 | `native_function_find` at `0x452fdb`, `0x853bdb`, `0x853ad4`, and `0x452d00/2e00/2f00/3000` (`ev_e3f3a6d8…` etc.) | "not inside any discovered function" | **Accepted with caveat** — engine discovery incomplete; does *not* mean the bytes are data. |
| P6 | `native_instruction_show` at `0x853bd0/853bdb/853bde/853be3/853bf0/853c00` (`ev_8e775962…`, `ev_d560126c…`, `ev_19089834…`, `ev_cf7b42dd…`, `ev_e98a1a78…`, `ev_754ad6dc…`) | `push eax`; `lea eax,[ebx+0x54]`; `mov edx,0x853e0c`; `call 0x405454`; repeated key-assignment shape | **Accepted** — instruction-level proof of the assignment. |
| P7 | `native_bytes_show(0x853b00,400)` (`ev_5a3356c0…`) | 400 bytes of `lea eax,[ebx+NN]; mov edx,<key>; call 405454` chains plus key strings `reflectionMap`, `waveMap` | **Accepted** — reveals the whole descriptor schema. |
| P8 | Python decode of key headers/payloads and field offsets over `0x853ad4..0x853c6e` (VA→file `−0x400C00`) | 30 key assignments at `+0x04..+0x78`; global f32 @ `0x853eb8 = 1.99999988` copied to `+0x7c` | **Accepted**, independently cross-checked by P9/P10/P11. |
| P9 | `native_function_study` at `0x853ad4` and `0x853bdb` | `bad_input / function_not_found` | **Rejected as tool limitation**, not as absence of function. |
| P10 | `native_function_pseudocode("0x853ad4")` (`ev_4ddab2aaf1927d0c86177156a5a33b574679cd493b0eb4d053a95f779c2268f6`) | Ghidra 12.2 `FUN_00853ad4`: 30 `FUN_00405454(param_1+offset, "key")` calls; `*(param_1+0x7c)=DAT_00853eb8` | **Accepted** — Deep decompiler recovered what built-in discovery missed. |
| P11 | `native_function_disassemble("0x853ad4")` | `function_not_found` | **Rejected**; raw bytes (P7/P8) + instruction reads (P6) substitute. |
| P12 | `native_xrefs_list(0x853e0c)` (`ev_ef7f2203…`) and `native_xrefs_list(0x853ad4)` (`ev_6e0b4990…`) | 0 references both | **Rejected as xref limitation** — the reference is an immediate operand in an undiscovered function; P4/P6 prove it. |
| P13 | `native_bytes_find` pattern `8d 43 54 ba 0c 3e 85 00` (`ev_ac379e04cf32eaff4d2272cd5f80b49fc6ee7369473f9843c9dd8d4fb17262ce`) | exactly 1 match, VA `0x853bdb` / file `0x452fdb`, section `CODE` | **Accepted** — unique instruction site for `hmapTex`. |
| P14 | `native_function_callers_list(0x405454)` (`ev_0e681b02…`) | 1,390 direct callers | **Rejected as discriminating evidence** — string-assign helper is used everywhere; cannot identify the water object. |
| P15 | `native_bytes_find` text `hmapTex` / `waveMap` in `codex.dll` (`ev_0b787986…`, `ev_2285a79f…`) | 0 matches for both (UTF-8 + UTF-16LE) | **Accepted as independent-binary cross-check**; absence in one DLL is not proof of disuse. |
| P16 | `native_function_study` + `native_function_pseudocode(sub_7ab704)` (`ev_e57a21ab…`, `ev_acad42c1…`) | Real function (9 blocks, 335 instructions), keys `RestrictInfo`, `HeightTarget`, `SphereHeight`, `FocalLength`, `DynFogDepth` — a **camera** parser | **Rejected as water consumer** — no water key is read here; prior “config parser” attribution must be scoped. |
| P17 | `core_text_read` on `water.dev.vert/frag`, `water.lib`, `water.mat` (evidence ids in §2) | Full verbatim shader/descriptor text | **Accepted** — shipped pair pinned by `water.lib:67-68`. |
| P18 | Python TGA RLE decode of `heightmapwaves0.tga` + BMP header of `diffusewaves0.bmp` | 256×256, 32 bpp, alpha min=max=255 over 65,536 px; `diffusewaves0.bmp` 256×256 24 bpp | **Accepted** — disproves “alpha carries height”. |
| P19 | Python whole-`data/**` regex scan for `water|shore|smooth|bridge|ford|current` (`d06_scan.py`, `d06_tile.py`, `d06_wlev.py`) | Located `generatemap.inc` smoothing chain, `misc.script` bridge rules, `dmscript.global` tag values, `TileSmoothPasses` contradiction, `fordtyp` context | **Accepted** — text source of truth for generation rules. |
| P20 | `core_text_read` on `generatemap.inc` (`ev_f4f0e5d0…`), `texturemap.inc` (`ev_461b4b9d…`), `misc.script` (`ev_7bf36259…`, `ev_e04c40ed…`), `dmscript.global` (`ev_57b8cb76…`), `smoothtiles.inc` (`ev_d1d7ea48…`), `tilesmooth_scripts.cfg` (`ev_f5d967c5…`), `globalparams.cfg` (`ev_bcc394ee…`) | Numbered lines reproduced in §3–§6 | **Accepted** — evidence ids recorded. |
| P21 | `Select-String` over `data/shaders/shaders.lib` for `fresnel|water|current|glint` | **0 matches in 1,813 lines** | **Accepted with caveat** — water shaders are loaded directly by `water.lib:67-68`, not registered in `shaders.lib`. |
| P22 | Owner-directed re-check of `TileSmoothPasses=6` vs `SmoothTileMap(...,3)`; whole-tree scan for `TileSmoothPasses`, `SmoothTileMap(`, `MapGeneratorSmoothTiles` | Only `globalparams.cfg:9` (6) and `smoothtiles.inc:237` (3); `generatemap.inc:784` `MapGeneratorSmoothTiles` is commented | **Accepted as unresolved contradiction** `[U]` — no readable consumer of the 6-pass config. |

---

## 2. Evidence table

| Evidence id | Source | What it establishes |
|---|---|---|
| `ev_4ddab2aaf1927d0c86177156a5a33b574679cd493b0eb4d053a95f779c2268f6` | `native_function_pseudocode("0x853ad4")`, Ghidra 12.2 | Decompiled `FUN_00853ad4` water-parameter key initializer, 30 string-key assignments + global f32 to `+0x7c`. |
| `ev_ac379e04cf32eaff4d2272cd5f80b49fc6ee7369473f9843c9dd8d4fb17262ce` | `native_bytes_find` pattern `8d4354ba0c3e8500` | Unique reference to the `hmapTex` key: VA `0x853bdb`, file `0x452fdb`, `CODE`. |
| `ev_5a3356c0f5944123f8ea3324f6beccff23ba74502021b8fa003b627ba6a4797b` | `native_bytes_show(0x853b00,400)` | Raw chain of key assignments; neighbouring keys `reflectionMap`, `waveMap`. |
| `ev_190898349c86f8d90a49007c79d2e593cc6278658a16928cb0c9371ae0dc6846`, `ev_cf7b42dd86b0261abebcacb0ea646d12092da5b46c61dd33f6e9be552c3a11fb`, `ev_d560126c6bc958f059d1bd8ae5e1f4673d55fc85baed2e7603b26ff294a56319`, `ev_5b97f1e7a105cfc710836dea1c2d0a4a631babc6b76953cc0092ba182cf7732d`, `ev_d94dda9482a38c5a0aa3322f1eb7ffddc2f812530d8886205613ad9b23d21319` | `native_instruction_show` | `mov edx,0x853e0c`, `call 0x405454`, prologue `push ebx` @ `0x853ad4`, epilogue load @ `0x853c5d`. |
| `ev_e3f3a6d844a80da115987d7f2cfd8ae2992e74bf51b793fa492bb9ad463586fc`, `ev_ef7f220359e627251e3fb7aed037dca009b7ebdef0a32295abfab35595d9ee72`, `ev_6e0b499054a373741ebd35caf54b198ae52a0b60d04c860812295d333775d4a4` | `native_function_find` / `native_xrefs_list` | Built-in engine sees no function and no xrefs in this region — the discrepancy resolved by P10/P13. |
| `ev_9ece6185dd164e5910ef585c632942689d8d5d6c908bc7e2fed58dd33c770ae9`, `ev_11b5c05c7606843b902514b33cc61e96b382addcd16a3c4544fbb2e81f6db9e1` | `native_strings_find` / `native_functions_search` | RTTI strings exist; no named `XWater`/`Shore` functions. |
| `ev_0b7879867d17ada565dfbec3b8fac6ae5e6cf5c4127994a8f70a69729faa4a6a`, `ev_2285a79fa25d8a7c740f250e375d35dad7f03e83858cca7ff0b775f52bff35f5` | `native_bytes_find` on `codex.dll` | 0 hits for `hmapTex` / `waveMap` in the second donor binary. |
| `ev_acad42c1706118176db3a00ab4cf524fcd835db55ff8928950dda150d9d77551`, `ev_e57a21ab1a1b4ae13f6775983d70523a06ef7467b29e22e6eabfe59e551bb196` | `native_function_pseudocode` / `native_function_study(sub_7ab704)` | `sub_7ab704` is a **camera** config parser; rejected as a water consumer. |
| `ev_642dcfbb94d624415accd6c06796b7c5a1f1f929b5357326f607e2194734b96b` | `data/shaders/water/water.dev.frag:1-50` | Sampler declarations, coast fade 0.57, wave constants, exponents 170/120, particle 30, colours. |
| `ev_a22c66b450f789163e4486ded3e2868a0af6bc6ec024fcc1470f2671229167bc` | `water.dev.frag:61-105` | `noise()` (waveMap at p/256), `height_map()` (`hmapMin+w*(max−min)`), bed colour, fBm/swell/shifts. |
| `ev_99fde295d8ee5bbd4249cb99e67408701d38aff17b17dc50950445d865ef926e` | `water.dev.frag:165-234` | Plane Y, discard rule, coastfades, normals/jitter, reflection, glints, foam, mix/alpha. |
| `ev_532af48372ada2a8491dd79f7540a3fa5886e4fe462e6e315aa8db692aa50ec3` | `water.dev.vert:1-30` | Flat vertex passthrough, `gl_TexCoord[1].z = pos.y`, hmap UVs, light mapping. (Fresh re-read after drafting removed an id-transcription hazard; P17 contains the same lines under a per-call id.) |
| `ev_53377109fe6806b0707eb3004f264f6df837db5088dc48f248af0c8859e460cc` | `data/water/water.lib:1-71` | Descriptor literals and shipped shader selection. |
| `ev_2c6662253590cd2c759fb60b23c907bcb0113e1da18402b3bb70a9dadebd3cfb` | `data/water/water.mat:1-106` | `DiffuseWaves0` active, `DiffuseWaves2` active, `HeightMapWaves0` fully commented. |
| `ev_f4f0e5d056203dc831fc717c44922a9e24250dbb54b14cf2085f92ae7b095cbb` | `generatemap.inc:686-707` | `cOffsetY = -0.5`; `WaterFieldAdd(..., cOffsetY)`. |
| `ev_461b4b9d7c82d918be8a8d26bc73f30b0caa4de257bf50e85834ece7a43fa34e` | `texturemap.inc:463-530` | Shore gate, 8×45° sectors, `sandsea1/5/6` tile map. |
| `ev_f5d967c54d94326cabda2ebbeab89ea366f1c10702ebe8d14a5db205f6afbde2` | `tilesmooth_scripts.cfg:5-36` | Smoothing probabilities: sandsea1-4=1, sandsea5=0.7, sandsea6=0.3, rock9/8/5=0. |
| `ev_d1d7ea4878ea5801629924fe6babec501a9c35a23490f384d074d7d98dba8776` | `smoothtiles.inc:190-239` | 3-pass `SmoothTileMap`; `MapGeneratorSmoothTiles` commented elsewhere. |
| `ev_bcc394eef001bba493521e260211feb0db8cb9cab3cfd27553c097ebca50e059` | `globalparams.cfg:1-22` | `TileSmoothPasses = 6`, `TileSmoothListFileName`. |
| `ev_7bf36259e8e006453e403f0bb9404918e2e706ff3bd25fbb3992c737529f6ab6` | `misc.script:5271-5346` | `_misc_CreateBridge` constants and collision painting. |
| `ev_e04c40ede2ce7534f6ce3d0638b1859ca1c7cdf2efbf07c28dcd5053501ac895` | `misc.script:5174-5211` | Water-border collision detection and tag rewriting. |
| `ev_57b8cb760afa6ef7995a869a21d8a6ff292e74934701914caac6367a2c803a57` | `dmscript.global:818-822` | `gc_WaterBorderSize = 3`. |

**Evidence-id hygiene note (method honesty):** a first draft of the `water.dev.vert` row contained a mistyped evidence id; it was replaced with a fresh, verbatim `core_text_read` id (`ev_532af48372ada2a8491dd79f7540a3fa5886e4fe462e6e315aa8db692aa50ec3`). Evidence ids are per-call; the donor path `data/shaders/water/water.dev.vert:1-30` remains the primary citation. No claim in this report depends on the discarded id.

---

## 3. Finding 1 — water level and classification of height cells

### 3.1 Three distinct levels `[O]`

| Name | Value | Donor source | Role |
|---|---:|---|---|
| Generation basin constant | `cWaterHeight = −1.1` | `generatemap.inc:7` | Depth of carved basins, *not* plane Y. |
| Generated water-field Y | `cOffsetY = −0.5` | `generatemap.inc:688,704` | Height passed to `WaterFieldAdd` for each 2×2 water field. |
| Tile water threshold | `cWaterHeight = −0.25` | `texturemap.inc:29-30,466-467` | Classifies a masked cell as `bWater`. |
| Tile wet-shore threshold | `cWaterShoreHeight = −0.1` | `texturemap.inc:31,469-470`; independent `dogenerate.inc:1576-1579` | Classifies a masked cell as `bWaterShore`; also gates pattern placement. |
| Shader plane Y | `gl_TexCoord[1].z = pos.y` | `water.dev.vert:18`; `water.dev.frag:167` | Engine/geometry-supplied; numeric runtime value `[U]`. |
| Inactive debug plane Y | `1.5 /*0.94*/` | `water.frag:182` | Not pinned by `water.lib:67-68`; tuning hint only. |

`[D]` Wet-shore tile band width in height units: `−0.1 − (−0.25) = 0.15`. This is a **classification band**, not a screen-space or metre measurement.

### 3.2 Basin height and water-field placement (verbatim-derived pseudocode) `[O]/[D]`

```
// generatemap.inc:560-574
for each mask cell (x,y):
    fr = gMapMask[x,y].r ; fb = gMapMask[x,y].b
    if random-map and fr=1 and fb=1: continue          // keep start cell
    hwater   = -1.1 * fb * (1 + fr*3.5)
    hterrain = { plateau  2.964*fr ; hill 2.964/2.25*fr ; ravine -2.964*fr }
    SetHeightData(realx, realy, hwater + hterrain)

// generatemap.inc:646-709
cWaterFieldSize = 2 ; cWaterMapArrSize = 640/2 = 320 ; cOffsetY = -0.5
for each 2x2 field:
    if any cell has gMapMask.b>0 and (gMapMask.r<1 or gMapMask.b<1):
        bWaterMap[wmx,wmy] = true
WaterFieldsClear()
for each true field:
    WaterFieldAdd(name, tx,tz,bx,bz, -0.5)
```

`[I]` The `−0.5` plane sits roughly in the middle of the generated basin depth range, which is consistent with a shallow-water ring; but because every cited line carries the GSC `;` prefix, **runtime execution of this branch is `[U]`**. It is still the only plaintext water-plane Y found in the whole donor tree (P19: single `WaterFieldAdd` call).

### 3.3 Shader wet/dry decision `[O]`

```
// water.dev.frag:70-75, 167-199, 229-232
h   = hmapMin + texture2D(hmapTex, uv).w * (hmapMax - hmapMin)
Y   = gl_TexCoord[1].z                                   // plane vertex Y
wh  = clamp(Y*3 - 1.5, 0, 1)
lvl = Y + 0.2 * water_map(uv*15 + time*0.1, wh)
if (h > lvl) { fragColor = vec4(0.0); return; }          // dry: discard
d   = lvl - h
cf  = clamp(d/0.57, 0, 1) ; cf2 = clamp(d/1.07, 0, 1)
... fragColor = vec4(mix(bed, watercolor, cf), cf2)
```

`[D]` `waveheight = clamp(3Y−1.5,0,1)` is 0 for `Y ≤ 0.5` and 1 for `Y ≥ 0.8333…`. With the recovered generated field Y `−0.5` (or the classification literal `−0.25`) the coarse swell term (`water.dev.frag:95`, scaled by `wh²`) is **exactly zero**; the debug `1.5` would make it 1 but is not the shipped path. `[D]` The 9-octave small-wave loop subtracts `amp*abs(sin(...))` with `amp>0`, so `water_map ≤ 0` when `wh=0` ⇒ `lvl ≤ Y`.

Collision-level classification (separate from rendering): `misc.script:5175-5207` scans cells at half-cell resolution, treats tag `0` or `gc_collisiontag_bridge=10` as shore-adjacent to tag `gc_collisiontag_water=87`, then repaints a radius-`gc_WaterBorderSize=3` disc: `0 → landborder=109`, `87 → waterborder=110` (`dmscript.global:84-91,819`).

---

## 4. Finding 2 — shoreline smoothing passes and exact thresholds

### 4.1 Height smoothing `[O]`

```
// generatemap.inc:218-245 — helper
_misc_SmoothTerrainCustom(x,y,times,power,lerp,minh,maxh):
    if power=0: return
    repeat times:
        lt=GetHeightData(x-1,y-1); rt=GetHeightData(x+1,y-1)
        lb=GetHeightData(x-1,y+1); rb=GetHeightData(x+1,y+1)
        h =GetHeightData(x,y)
        if (h!=lt or h!=rt or h!=lb or h!=rb) and minh<=h<=maxh:
            z1=(lt+rt)/2 ; z2=(lb+rb)/2
            res = h + ((z1+z2)/2 - h)/power
            SetHeightData(x,y, Lerp(h,res,lerp))
```

**Pass chain (in stage order):**

| # | Trigger | Call | Exact numbers | Source |
|---|---|---|---|---|
| S0 | Mask relief transitions `bsmooth` (plateau/hill/ravine smooth colours, `generatemap.inc:24-27,353-367,455-469`) | `SmoothTerrain(realx, -realy, False, 3)` | radius/parameter **3**, applied once per flagged cell | `generatemap.inc:580-595` |
| S1 | Every map cell | `_misc_SmoothTerrainCustom(realx, realy, 1, 4, 0.5, 0.01, 100)` | times=1, power=4, lerp=0.5, h∈[0.01,100] | `generatemap.inc:598-608` |
| S2 | Cells with water in 5×5 neighbourhood | `_misc_SmoothTerrainCustom(realx, realy, 1, 0.35, 0.5, -100, -0.01)` | **3 passes**, radius `rad=2` (5×5), times=1, power=0.35, lerp=0.5, h∈[−100,−0.01] | `generatemap.inc:611-640` |

`[D]` S2 is the actual shoreline smoother: it only touches cells below `−0.01` and only within 2 cells of a water-mask cell, iterated 3 times; the alternative positive-height variant at `generatemap.inc:607` is commented out. This is a *height* smooth, distinct from tile-block smoothing.

### 4.2 Tile smoothing `[O]/[U]`

- `generatemap.inc:781-788`: `cSmoothTile=True` → `ExecuteState('SmoothTiles')`; the C++ call `MapGeneratorSmoothTiles` at `:784` is commented out.
- `smoothtiles.inc:191-237`: `SmoothTileMap(mini,minj,maxi,maxj,passes)` does `passes` iterations, each a horizontal sweep then a vertical sweep; the live call is `SmoothTileMap(0,0,GetMapWidth,GetMapHeight,3)` — **3 passes**, then `SetTileIndex` for every cell (`:240-242`).
- `GetNeighbourTiles` (`smoothtiles.inc:84-187`) maps the two tile names to indices in a compatibility list, chooses the list with minimal `Abs(ind1−ind2)`, then:
  - `|i1−i2| = 1` and at least one non-zero Prob → no change (`outtile1=outtile2=-1`);
  - `i1−i2 = 2` → replace tile 1 with a random tile from list `(i1+i2)/2`;
  - `i2−i1 = 2` → replace tile 2 likewise;
  - otherwise replace the farther-from-water tile with a random tile from list `min(i1,i2)+1`;
  - `FindRandomTileIndex`: `rnd = RandomExt * SumProb`; first entry with `Prob>0` and `rnd < cumulative` wins (`:63-80`).
- `[O]` Contradiction: `data/gen/globalparams.cfg:9` says `TileSmoothPasses = 6`, but a whole-tree scan (P22) finds **no consumer** of that key in readable donor text; the active GSC call hardcodes 3. **Status `[U]`** — do not claim 6 is executed.

### 4.3 Shore-transition probability table `[O]`

`data/gen/tilesmooth_scripts.cfg:5-36` (summer) and `:934-966` (winter):

| Compatibility list | Tiles and Prob |
|---|---|
| Wet sand family 1 | `sandsea1=1`, `sandsea2=1`, `sandsea3=1`, `sandsea4=1` |
| Wet sand family 2 | `sandsea5=0.7`, `sandsea6=0.3` |
| Rock family (cliff) | `rock1=0.16`, `rock2=0.16`, `rock3=0.16`, `rock6=0.16`, `rock7=0.16`, `rock4=0.20` |
| Excluded from smoothing | `rock9=0.0`, `rock8=0.0`, `rock5=0.0` |
| `sandrock1/3` list | commented out (`:37-50`) |

`[D]` The live shore table (`texturemap.inc:503-511`) paints only `1/5/6`; `sandsea2/3/4` appear **only** as smoothing intermediates. `rock9` is excluded both from live shore selection (DTRN-03 C24, `:934-954` commented) and from smoothing (Prob 0) — so “rockNvf/vs shore tiles” are not part of the wet-sand rim.

---

## 5. Finding 3 — `hmapTex` / `heightmapwaves0.tga` binding, resolved by Deep decompilation

### 5.1 Decompiled descriptor initializer `[O]`

`native_function_pseudocode("0x853ad4")` returned (Ghidra engine, evidence `ev_4ddab2…`):

```c
void FUN_00853ad4(int param_1) {
  FUN_00405454(param_1 + 0x04, "reflectionMap");
  FUN_00405454(param_1 + 0x08, "waveMap");
  FUN_00405454(param_1 + 0x0c, &DAT_00853c98);   // "time"
  FUN_00405454(param_1 + 0x10, "eyePosition");
  FUN_00405454(param_1 + 0x14, "deepColor");
  FUN_00405454(param_1 + 0x18, "shallowColor");
  FUN_00405454(param_1 + 0x1c, "reflectionAmount");
  FUN_00405454(param_1 + 0x20, "waterAmount");
  FUN_00405454(param_1 + 0x24, "fresnelPower");
  FUN_00405454(param_1 + 0x28, "fresnelBias");
  FUN_00405454(param_1 + 0x2c, "hdrMultiplier");
  FUN_00405454(param_1 + 0x30, "waveFreq");
  FUN_00405454(param_1 + 0x34, "waveAmp");
  FUN_00405454(param_1 + 0x38, "distFactor");
  FUN_00405454(param_1 + 0x3c, "bumpFactor");
  FUN_00405454(param_1 + 0x40, "texScaleS");
  FUN_00405454(param_1 + 0x44, "texScaleT");
  FUN_00405454(param_1 + 0x48, "waveDir0");
  FUN_00405454(param_1 + 0x4c, "waveDir1");
  FUN_00405454(param_1 + 0x50, "fogEnabled");
  FUN_00405454(param_1 + 0x54, "hmapTex");
  FUN_00405454(param_1 + 0x58, "hmapW");
  FUN_00405454(param_1 + 0x5c, "hmapH");
  FUN_00405454(param_1 + 0x60, "hmapMin");
  FUN_00405454(param_1 + 0x64, "hmapMax");
  FUN_00405454(param_1 + 0x68, "shadowed");
  FUN_00405454(param_1 + 0x6c, "shadowMap");
  FUN_00405454(param_1 + 0x70, "shadowSize");
  FUN_00405454(param_1 + 0x74, "shadowColor");
  FUN_00405454(param_1 + 0x78, "cameraModel");
  *(undefined4 *)(param_1 + 0x7c) = DAT_00853eb8;   // f32 1.99999988
  return;
}
```

Raw-byte cross-check (P6-P8, P13): prologue `push ebx; mov ebx,eax` at `0x853ad4` (file `0x453ad4`); assignment sites `0x853ad7…0x853c50`; the `hmapTex` key pointer `0x853E0C` (file `0x45320C`, Delphi AnsiString refcount `−1`, length 7) is referenced exactly once by `lea eax,[ebx+0x54]; mov edx,0x853e0c; call 0x405454` at VA `0x853bdb` (file `0x452fdb`); epilogue `mov eax,[0x853eb8]; mov [ebx+0x7c],eax; pop ebx; ret` at `0x853c5d…0x853c66`.

`[D]` This is a **water-parameter descriptor** initializer. It assigns *uniform key names*, not values, textures, sampler units or FBOs. Class attribution (`XWaterShader` vs another water holder) remains `[U]`: the RTTI string `$XWaterShader` exists at `0x958c11` but has no code xref (P1/P2).

### 5.2 Answer to the task question `[O]/[D]`

`hmapTex` is sampled **only** in `height_map()` (`water.dev.frag:70-75`) and supplies `h = hmapMin + w*(hmapMax−hmapMin)`. That `h` is compared to the animated water level (`:170,176-199`) and used for the depth fades. It is **not** used for vertex displacement (the shipped vertex shader is a flat passthrough, `water.dev.vert:13-29`) and **not** used for normals: the 4-tap wave normal comes from `waveMap` at `:186-192`. Therefore: **height-field lookup for per-pixel depth/wet-dry classification and fades only**; displacement lives only in the inactive `.vert.bak` pair, and `WaveFreq=0/WaveAmp=0` (`water.lib:26-27`) disable it even there.

`heightmapwaves0.tga`: 256×256, 32 bpp, TGA type 10 RLE; direct decode gives **alpha 255 for all 65,536 pixels** (min=max=255). Its material block is **all commented** (`water.mat:86-106`, 21 lines beginning `//`), and `water.lib:45` `//NormalMapLibMaterialName = HeightMapWaves0` is commented. Byte scans: 0 hits in `cossacks.exe` and `codex.dll` (P15, prior RV-TRN-03). `[D]` If bound raw, `hmapTex.w` would be constant ⇒ either constant height or universal discard; either way it cannot be the height source. `[U]` The literal engine texture/FBO that feeds `hmapTex` is not provable statically (uniform names are external GLSL strings resolved through `wglGetProcAddress`; see T6-S02).

---

## 6. Finding 4 — shader constants, currents/direction grid, Fresnel, glints

### 6.1 Live constants `[O]` (re-read this session, `water.dev.frag:37-47` and `:168-232`)

| Constant | Value | Role |
|---|---:|---|
| `coast2water_fadedepth` | `0.57` | colour fade depth |
| `deepwater_fadedepth` | `0.5+0.57 = 1.07` | alpha/deep-tint fade depth |
| `large_waveheight`, `large_wavesize` | `0.50`, `2.0` | crossing swell, scaled by `waveheight²` |
| `small_waveheight`, `small_wavesize` | `0.5`, `0.5` | 9-octave ridged chop |
| `water_softlight_fact`, `water_glossylight_fact` | `170`, `120` | glint exponents (`pow(grad,N)`) |
| `particle_amount` | `30` | foam sparkle gain |
| `watercolor`, `watercolor2`, `water_specularcolor` | `(0.1,0.24,0.24)`, `(0,0.025,0.05)`, `(0.4,0.4,0.4)` | linear pre-composite inputs |
| `m` | `mat2(0.72,−1.60,1.60,0.72)` | fBm rotation/scale |
| coarse octave weights | `0.6000`, `0.2500`, `0.1666` | fBm before swell |
| small-wave loop | 9 iterations, `p=m*p*0.947`, `amp*=0.59`, `s*=-1.329`, result `wave+f*0.5` | chop |
| `dif`, normal Z | `(0,0.01)`, `0.15` | 4-tap normal |
| `wavejitter` | `normwater.xy * texScaleT * (level−height)` | refraction of bed/reflection UV |
| bed colour | `(0.175,0.1375,0.1) + waveMap(p*8).rgb*0.25` | underwater substrate |
| luma weights | `0.2126,0.7152,0.0722` | intensity for shallow tint |
| glint composite | `*2.2+shade`; `+=(.2+.8*shade)*((grad−1)*.5+spec)*.25`; `/=1+specular1*1.25`; `+=shade*spec2*speccol` | same as DTRN-03 §3.4 |
| `nautic`/`particles` | `p*=18` / `p*=200`, 3 octaves, `pow(1−f,5)` / `pow(f*0.35,7)*30` | procedural foam, **no foam texture exists** |
| foam band | `watershade*coastfade*(1−coastfade2)*((.5,.6,.7)*nautic + particles)` | `:227` |

`[D]` Foam band `b(d)=clamp(d/0.57,0,1)*(1−clamp(d/1.07,0,1))` is exactly zero at `d=0` and `d≥1.07`, and peaks at **`d = 1.07/2 = 0.535 m`** with value `≈0.4693`. Alpha `=d/1.07` reaches 0.5 at the same depth. There is **no white rim at the mathematical waterline**: `cf=cf2=0` and the fragment shows bed only.

`[O]` Descriptor values (`water.lib:5-60`): `MaxDepth=1`, `MinDepth=0`, `MaxAlpha=1.1`, `MinAlpha=0`, `DeepColor=(0,0,0.1255,0.5)`, `ShallowColor=(0,0,0,0.5)`, `ReflectionAmount=1`, `WaterAmount=1`, `FresnelPower=1`, `FresnelBias=1`, `HDRMultiplier=1`, `WaveFreq=0`, `WaveAmp=0`, `DistFactor=1`, `BumpFactor=1`, `TexScaleS=0.1`, `TexScaleT=0.01`, `WaveDir0=(−1,0)`, `WaveDir1=(−0.7,0.7)`, `Speed=1.0`, `Width=1`, `Height=1`, `Offset=0.495`, `LayerCount=1`, `CustomEnable=False`, `CustomReflection=False`, `CustomReflectionUnit=0`, `CustomTexCoord=True`, `CustomTexReflectMatrix=False`, `HeightMapEnable=True`, `ShadowMapEnable=True`.

### 6.2 Currents / direction grid / Fresnel `[O]/[D]`

- **Currents**: no `current` uniform or grid in the shipped fragment. The only advection terms are `shift1=(0.32t,0.24t)`, `shift2=(0.38t,−0.26t)` (`water.dev.frag:88-89`), level UV `+0.1t` (`:175`), normal UV `+0.01t` (`:187`), and foam-time inside `nautic`/`particles`. `[D]` Direction ratios are `+4:3` and `−1.46:1`.
- **Direction grid**: `WaveDir0/1` and `Speed` exist only in `water.lib:34-42` and in the water descriptor key table (§5.1); the `.dev` fragment declares no such uniforms. They are consumed by the **legacy** `.vert.bak` two-sine path (`waveFreq/waveAmp/waveDir0/1`, prior RV-TRN-03 §6 #3), which is not selected. Do not port a “direction grid” as if the shipped shader used one.
- **Fresnel**: declared in `water.lib:23-24` (power/bias 1) and assigned as a *key* in the descriptor (`+0x24/+0x28`), but the shipped fragment's Fresnel lines are commented (`:8-13,203-206`). `shaders.lib` contains **zero** `fresnel|water|current|glint` matches (P21). A live Fresnel exists only in the embedded legacy `.bak` shader (prior RV-TRN_03). `[D]` Not wiring Fresnel is faithful to the selected `.dev` pair.
- **Reflection**: `texture2DProj(reflectionMap, refuv)`, `refuv` from `gl_TextureMatrix[0]*pos` (`water.dev.vert:15`), jitter subtracted by `refuv.z`, then `refcol *= (R+G+B)*hdrMultiplier` and added to water colour (`water.dev.frag:207-213`). Provenance of the projected target is `[U]`.
- **Shadow/fog**: `test_shadow()` is 3-tap PCF (`:129-143,222`); fog is applied *after* composite with modes 1/2/3 and `1.442695` (`:237-253`), default `FogMode=0` (`colors.lib:36`).

---

## 7. Finding 5 — shore tile selection and collision gate

### 7.1 Active wet-sand rim `[O]`

```
// texturemap.inc:426-447 (gradient)
lh=GetHeightData(realx-1,realy); rh=GetHeightData(realx+1,realy)
th=GetHeightData(realx,realy-1); bh=GetHeightData(realx,realy+1)
dirX=lh-rh ; dirY=th-bh
if VectorLength(dirX,0,dirY)>0.01:
    normalize ; vecangle=VectorAngle(1,0,0,dirX,0,dirY)
    if dirY<0: vecangle=-vecangle

// texturemap.inc:463-529 (gate, sectors, tile)
if gMapMask[ix,iy].b>0:
    if height < -0.25: bWater=True
    elif height < -0.1: bWaterShore=True
if bWater or bWaterShore:
    vecangle += 180 ; cAngle=45
    sector = floor((vecangle+22.5)/45)   // equivalent to the 8 explicit windows :479-501
    newtile = { bR:sandsea6, bRB:sandsea6, bB:sandsea1, bLB:sandsea5,
                bL:sandsea6, bLT:sandsea6, bT:sandsea1, bRT:sandsea5 }
    if GetSeasonType=2: newtile += '_winter'
    SetTileIndex(x,y, MapGetTileIndexByTileBlock(newtile))
```

`[D]` Exactly **three** live textures: `sandsea1` (bB/bT), `sandsea5` (bLB/bRT), `sandsea6` (bR/bRB/bL/bLT). `sandsea2/3/4` survive only in the commented alternatives on the same lines and in the smoothing list. `[O]` The `rock9`/`sand1`/`sand2` shore-replacement block is commented (`:934-954`); `rock9` has smoothing Prob 0 (§4.3). The rim is painted on **masked water and wet-shore cells**, not dry land.

### 7.2 Cliff faces are a separate rule `[O]`

`texturemap.inc:557-610` triggers when the cell is at the map edge or `GetMapCollisionTagInRadius(realx,realy,0,False)>0`, then uses an **asymmetric 6-branch** angle table: `bRB` `[22.5,67.5]`, `bLB` `[120,170]`, `bR` `[−45,45]`, `bB` `[45,135]`, `bT` `[−135,−45]`, `bL` else; tiles `bLB→rock7`, `bB→rock1`, `bL→rock3`, `bR→rock4`, `bT→rock4`, `bRB→rock4`; `rock6`/`rock2` alternatives are commented (`:579,582`). Height overrides: `Abs(h)>2.7→rock8`, `>2.4→rock4`, `Abs(h)<0.1→no tile`; winter suffix and `MapGetTileIndexByTileBlock` as above. `[D]` Do not “fix” this table to the 8×45° shore sectors — they are different donor rules.

---

## 8. Finding 6 — bridge / ford rules

### 8.1 Bridge construction `[O]`

`_misc_CreateBridge(x1,y1,x2,y2,height)` (`misc.script:5271-5346`):

```
cScale=1.15 ; cBaseHeightOffset=0.4876   (old -0.0818 commented)
cBlockWidth=2.81*scale (=3.2315)
cStartWidth=cEndWidth=1.78*scale (=2.047)
cStartOffset=cEndOffset=1.07*scale (=1.2305)
cCollisionRad=3 ; cCollisionStep=2
dist=VectorDistance(x1,0,y1,x2,0,y2)
blockcount=floor((dist - cStartWidth/2 - cEndWidth/2)/cBlockWidth)+2
angle=_misc_GetDirAngleToXVector(normalized dir)
spawn 'misbridge4' at start, blockcount x 'misbridge'+IntToStr(2+floor(random*2)),
       'misbridge1' at end; all rolled -45-angle, auto-offset off,
       Y = height + cBaseHeightOffset*cScale, scaled by cScale on xyz
collision: colCount=ceil(dist/cCollisionStep)+1
           MapDrawCollision(colX,colZ,gc_collisiontag_bridge=10,3,true) each step
then _misc_SetShoresCollisionInArea(minX,minY,maxX,maxY) with 2.5*cStartWidth padding
     and _misc_BaseTopologyUpdate(...)
```

`_misc_CreateBridgeExt(px,pz,length,angle,height)` (`:5350-5358`) rotates `(1,0,0)` by `−angle` and calls `_misc_CreateBridge`. `[D]` Bridges are spawned objects + collision overlay + topology refresh, not a terrain tile substitution; after construction the shore-collision pass treats tag 10 like land when detecting water borders (`misc.script:5185`).

### 8.2 Ford `[O]/[U]`

No terrain ford generator was found. The token `fordtyp` (`classes.script:4201`; `misc.script:2911`, `player.script:603,878,986,1082`) is a **squad formation/action-type field** — it is assigned `gc_playersquad_action_*` constants and sits beside `fform`, `ftarget`, `fintlst` — not a river crossing. Water crossing is handled by movement/pathfinding (`RayCastWater`, `gc_collisiontag_water=87`, `gc_collisiontag_bridge=10`, `gc_collisiontag_waterborder=110`). `[U]` Any “ford depth/width threshold” would be invented; none is readable in `data/**`.

---

## 9. Implications for the port (spec inputs, not edits)

All items below are **inputs to COORD’s spec**; this worker changed no source, shader, config, asset, test or git state.

| # | Donor-grounded rule | Port implication | Label |
|---|---|---|---|
| I1 | Classification `−0.25 / −0.1`, width 0.15 | Keep as tile/collision classification only; never use as water-plane Y. | `[O]` |
| I2 | Generated field Y `−0.5` | Candidate A/B surface Y from real donor text (still GSC-commented ⇒ `[U]` runtime). It also gives `waveheight=0`, so it does **not** justify claiming a visible coarse swell. | `[O]` text / `[U]` runtime |
| I3 | Height smoothing S0/S1/S2 exact constants | Implement stage order and numbers (radius 3; 1× power4/0.5/[0.01,100]; **3×** power0.35/0.5/[−100,−0.01], 5×5 radius 2) before any visual tuning. | `[O]` |
| I4 | Tile smoothing 3 vs config 6 | Record contradiction; do not silently adopt 6. | `[U]` |
| I5 | 8×45° sandsea table + mask gate + Prob 0.7/0.3 | Use exact sectors, three tiles, winter suffix, and Prob weights; keep `rock9` out of wet rim. | `[O]` |
| I6 | Cliff 6-branch table and `|h|` overrides | Separate rule; do not merge with shore sectors. | `[O]` |
| I7 | Water height is classification/fades only; flat vertex; normals from `waveMap` | Port's height-grid substitute is a **PORT APPROXIMATION**, not a recovered `hmapTex` bind; do not bind `heightmapwaves0.tga`. | `[O]` + PORT APPROX |
| I8 | Foam peak at depth 0.535, zero at 0 and ≥1.07; alpha=`d/1.07` | Donor-derived metrics; no foam texture, no `shore_prox` multiplier, no alpha floor. | `[O]/[D]` |
| I9 | Glints exponents 170/120, corona divides; no live Fresnel/current grid | Port should keep exponents and omit Fresnel; `WaveDir0/1` descriptor-only. | `[O]` |
| I10 | Bridge constants + collision tag 10, border radius 3 | If bridges are in scope, model as objects + collision overlay, not shore tiles. | `[O]` |
| I11 | No ford rule; `fordtyp` is formation type | Do not invent a ford threshold. | `[D]/[U]` |

---

## 10. Risks

1. **GSC comment prefixes.** Nearly every generation/shore rule lives behind `;` (`[*] = ;`). Text is observed; execution context is `[U]`. Porting the numbers is safe; claiming runtime parity is not.
2. **Tool disagreement.** Built-in discovery, xrefs and `native_function_study` fail on `FUN_00853ad4`; only Ghidra pseudocode plus raw bytes recover it. Any later worker using only the built-in engine may wrongly conclude “no function”. Keep P5-P13 in the ledger.
3. **Evidence-id transcription.** One vertex-shader id in §2 was mistyped during drafting and replaced with a fresh verbatim read; the donor path remains authoritative and no finding rests on the discarded id.
4. **Two binaries.** `hmapTex`/`waveMap` are absent from `codex.dll`, but absence from one DLL is not evidence of disuse elsewhere.
5. **Names are not semantics.** `XWater*` are RTTI strings with no code xref; `fordtyp` is not a ford; `waveDir0/1` are not consumed by the shipped fragment. Each was resolved by multiple passes, not by name matching.
6. **Scale uncertainty.** Donor metres-per-cell remains `[U]`; screen-space foam/beach widths cannot be asserted, only depth-space numbers (0.57/1.07/0.535).
7. **No visual evidence.** No donor GPU A/B frame and no port capture were produced by this worker; all visual readings are structural `[I]`.

---

## 11. UNVERIFIED register (do not promote)

1. Runtime numeric values of `hmapMin/hmapMax/hmapW/hmapH` and the actual texture/FBO bound to `hmapTex` — key names and field offsets proven; binding not (P3-P15). Port `±2.96` and `map_size/128` are PORT APPROXIMATION.
2. Class identity of the descriptor object (`XWaterShader` RTTI exists but has no code xref) — `[U]`.
3. Runtime execution of `generatemap.inc`/`texturemap.inc` GSC blocks, including the recovered `−0.5` field Y — `[U]`.
4. Whether `TileSmoothPasses=6` is consumed by compiled code — `[U]`; active script hardcodes 3.
5. `reflectionMap` provenance (planar FBO vs screen copy) and GPU sampler-unit numbers — `[U]`; no `glUniform1i`/`glActiveTexture` imports (prior T6-S02).
6. Whether `DiffuseWaves2` (active config, no `.dev` sampler) is uploaded — `[U]`.
7. Exact engine mapping of palette `FogMode` → `fogEnabled` int; default `0` is text-observed — `[U]`.
8. Any ford-generation or shallow-crossing threshold — no readable donor rule found — `[U]`.
9. Donor metres-per-cell and therefore screen-space shore-band width — `[U]`.
10. Visual parity of any port water/shore frame — no donor A/B capture exists — `[U]`.

---

## 12. Open questions

1. Can a later Deep session attach `FUN_00853ad4` to its caller (object class) and find the generic routine that turns `+0x54`’s string key into a uniform/sampler bind? That is the last static route to an `hmapTex` texture identity.
2. Is `globalparams.cfg:TileSmoothPasses=6` read by compiled C++ code (no readable consumer found), or is 3 the true retail pass count?
3. Does the retail skirmish generator actually call `WaterFieldAdd(...,−0.5)`, or do scenario `.map` files supply a different plane Y? (The only other Y hints are inactive shaders.)
4. Are `rockNvf/vs` face tiles ever applied to the water-side rim by a compiled path not represented in `texturemap.inc`, or only to collision-marked cliff cells as the script shows?
5. Is there a ford/bridge *placement* rule in a DLC/expansion data set not covered by `data/scripts/**` (worker F10 scope)?
6. Can a donor GPU frame with fixed camera be captured (owner decision, forbidden for this worker) to convert the depth-space foam metrics into pixel metrics?

---

## 13. Summary

- Recovered, with Deep decompilation corroborated by raw instruction bytes, the donor water-parameter initializer `FUN_00853ad4` (`cossacks.exe` VA `0x853ad4`, file `0x453ad4`): 30 uniform **key names** assigned to descriptor offsets `+0x04…+0x78` (`hmapTex=+0x54`), plus a global f32 `1.99999988` at `+0x7c`. No texture bind is present; `hmapTex` is a **height lookup for per-pixel depth**, not displacement and not normals.
- Recovered three distinct water levels (`−1.1` basin, `−0.5` generated field, `−0.25/−0.1` classification) and the exact shoreline smoothing chain (radius-3 `SmoothTerrain`; 1× `power4/0.5/[0.01,100]`; **3×** `power0.35/0.5/[−100,−0.01]` with 5×5 water-neighbourhood detection).
- Re-verified the full shipped shader constant/equation set: 0.57/1.07 fades, alpha ramp, foam peak depth 0.535, 170/120 glints with dividing corona, procedural foam, no live Fresnel/current grid, no `shaders.lib` water entries.
- Re-verified shore tile rules (`sandsea1/5/6`, 8×45°, Prob 0.7/0.3, `rock9=0`) and the separate cliff table; recovered bridge constants and established that `fordtyp` is not a ford.
- Every contradiction was multi-passed and logged (P1–P22); unresolved items are `[U]` with passes attempted. **No donor visual parity is claimed**, no donor binary was executed, no donor file copied, and no repo source/Godot/git state was touched.

*End of D06 report. Exactly one file written: `docs/terrain_swarm_2026-11-26/reports/D06_water_shore.md`.*
