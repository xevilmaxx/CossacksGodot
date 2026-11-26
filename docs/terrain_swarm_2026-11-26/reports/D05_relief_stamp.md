---
id: D05-RELIEF-STAMP
title: "D05 — donor relief/height stamping operation decoded from cossacks.exe"
agent: D05 (binary wave, donor-first terrain swarm 2026-11-26)
date: 2026-11-26
status: LANDED
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION"]
target: "t_87f0f3c130b0 — C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c (deep/Ghidra 12.2 engine active)"
rules: "Read-only donor. No donor binary executed, copied or committed. No source/asset/config/test edited. No donor-parity claim."
---

# D05 — Relief stamp: pattern float grid → world height

## Executive summary

1. **[O]** The stamp is the engine function `sub_755f30` (`cossacks.exe` VA `0x755f30`–`0x75c187`, file offset `0x355330`–`0x35c187`), called by the DScript native `StandPattern` (registration at VA `0x6b2b60`, implementation `0x6b28d8` → `0x6b2878` → `sub_755f30`). Evidence: ev_1efd345d… (signature strings), ev_13f00ea1… (function bounds), ev_e65fb8fd… (Ghidra pseudocode), ev_dbc8c87e… (assembly).
2. **[O]** The port's model `h = clamp(h_base + grid*Scale, Min, Max)` is **not** the donor operation. In the stamp: `HeightFieldMin` is used as the **pivot** of the scale, `HeightFieldMax` is **never read at all**, and `HeightFieldOffset` (not Max) is the additive term. There is no clamp to `[Min, Max]` in the stamp function (raw-byte scan of `0x755f30`–`0x75c187` found zero references to struct offset `+0x60`). **[D]** The port line is therefore refuted for the stamp stage; it remains a `PORT APPROXIMATION` only for the unverified global height-setter clamp.
3. **[O]** Three blend modes are selected by two boolean config flags, not one enum:
   - `ReplaceForWater=true` → **Replace**: `setHeight(g*Scale + Offset)` (no base height).
   - `ReplaceForWater=false, Replace=true` → **base-add**: `setHeight(base_h + g*Scale' + Offset)`.
   - `ReplaceForWater=false, Replace=false` (the common case) → **Smooth**: `h += (base_h - h)*TerrainScale + (g - Min)*Scale + Min + Offset` (read twice so `h` is the latest height).
   where `g` is the float grid sample and `base_h` is a bilinear sample of the world height at the stamp centre.
4. **[O]** `HeightFieldScale` is taken verbatim when `HeightFieldUseRndScale=false` (all audited patterns); when true it is `rand(MinScale, MaxScale)`. A negative scale such as `-0.925` multiplies the grid value directly (or about the `Min` pivot), i.e. it **inverts the relief**, not the world height.
5. **[O]** The 8×10 float "height window" is a *downsample* of an on-disk `w×h` (loader allocates `(w+1)×(h+1)`) row-major float grid indexed `grid[row_z][col_x]`; row increases with world **z/y**, col with world **x**, rotated by `rotangle` around the stamp centre. File-row sign flip remains **[U]**.
6. **[O]** `globalparams.cfg` has **no** `HeightField*` keys (all 22 lines read); it only supplies `PatternPlayerName = pattern` (line 15) and map-generation globals. All scale/min/max/smooth/replace values come from `data\pattern\pattern.lib` section fields, parsed by `sub_75c314`.

---

## Evidence table

| # | Evidence id / citation | Class | What it establishes |
|---|---|---|---|
| E1 | `ev_60b49743…` (`core_overview_show`) | [O] | PE32 x86, 18,918 functions, stripped, `.bind` high-entropy section; function discovery incomplete — motivates multiple independent passes. |
| E2 | `ev_a643d13e…` (`native_strings_find`) | [O] | Only `HXHeightField` in data sections; no `HeightFieldScale` string there. **Does not** mean no code consumer. |
| E3 | `cossacks.exe` file `0x35bb2c`–`0x35be30` (VA `0x75c72c`–`0x75ca30`) | [O] | Delphi constant AnsiString table with every `pattern.lib` sculpt field name, including `HeightFieldReplace`, `HeightFieldReplaceForWater`, `HeightFieldMin/Max/Offset`. |
| E4 | `ev_44c61fad…` (`native_function_instructions_list` of `sub_75c314`) | [O] | Config-field → struct-offset map (parser), 237 instructions; `cossacks.exe` VA `0x75c314`–`0x75c6a0` / file `0x35b714`–`0x35baa0`. |
| E5 | `editor.exe` file `0x4cbbae`–`0x4cbd1f` (VA `0x8cc7ae`–`0x8cc91f`) | [O] | Independent binary cross-check: identical struct offsets for Stand/Replace/ReplaceForWater/Scale/Min/Max/Offset/Smooth. |
| E6 | DScript native registration `sub_69a70c`, VA `0x69bd71`–`0x69bd7f` | [O] | `StandPattern` signature at `0x6a3474` is implemented by `0x6b28d8`. |
| E7 | `ev_ef2b141c…`, `ev_e65fb8fd…` | [O]/[D] | `sub_6b2b60` (`StandPatternWithAngleAdv`) is a group wrapper; its call `FUN_00755f30(p, player, 0, standx, standz, rotangle, minangle, maxangle)` reaches the stamp. |
| E8 | `ev_13f00ea1…`, `ev_371d3b6a…`, `ev_dbc8c87e…` | [O] | `sub_755f30`: 25,175 B, 234 blocks, 6,751 instructions, 32 callees; assembly of the height loop `0x7563e8`–`0x7566e9`. |
| E9 | `ev_3c1cac6e…` / cossacks.exe `0x75660d`, `0x756616`, `0x7566ab`, `0x7566b4` | [O] | `- Min`, `* scale`, `+ Min`, `* TerrainScale`, `+ Offset` x87 ops. |
| E10 | `ev_32b5f7f1…`, `ev_dfd5cff8…` | [O] | Smooth kernel `sub_755db4`: 4-neighbour mean divided by constant `4.0` at VA `0x755ee4`. |
| E11 | `ev_f3919238…`, `ev_4c42e921…` | [O] | Constants `2.0` @`0x75c1a4`, `0.5` @`0x75c1a8` (half-cell / rotation arithmetic). |
| E12 | `data\gen\globalparams.cfg:1-22` (`ev_38b552b9…`) | [O] | No height-field keys; `PatternPlayerName = pattern` at line 15; `Size=512`, `FrequencyFactor=0.000013`, `TileSmoothPasses=6`. |
| E13 | `data\pattern\pattern.lib` file offsets `0x0d89b20` (`k_ravine_1`), `0x0d0894` (`hil1`), `0x339` (first pattern) | [O] | Scale/Min/Max/flags literals, including `0.649999976158142`, `-2.963627576828` / `3.13982009887695`. |
| E14 | `DPATTERN_01_relief_grids.md:83-124,497-500,595-600` | [O]/[D] | `.pattern` header, row-major `w×h` float window, derived 8×10 block-mean tables, row-sign flip still UNVERIFIED. |
| E15 | raw-byte scan of VA `0x755f30`–`0x75c187` for `[eax+0x60]` / `[ebx+0x60]` encodings | [O] | **Zero** accesses to `HeightFieldMax` in the stamp; Min/Offset are accessed (`d8 40 5c`, `d8 40 64`). |

---

## Method and pass register (owner directive: multiple passes; no silent skips)

| Pass | Tool / evidence | Result | Acceptance reasoning |
|---|---|---|---|
| P1 | `native_strings_find` + `core_feature_find` for `HeightField`, `HeightFieldScale`, `ReplaceForWater`, `StandPattern` | `HeightFieldScale`: 0 matches; `StandPattern`: 0; only `HXHeightField` @`0x958aa2` | **Rejected as incomplete**: tool searches data sections; a zero is not proof. Prior DPATTERN_01:366-382 concluded "no plaintext consumer" from `.cfg/.script/.lib` — correct for those files, not for EXE CODE. |
| P2 | Python raw-byte scan of both EXEs (read-only) | Found RTTI (`THeightFieldGetHeightEvent` @file `0x140d8b`), DScript declaration table (`procedure StandPattern` @`0x2a2874`, `SetHeightData` @`0x2a30e0`), and config-name table @`0x35bb2c`; `editor.exe` equivalents @`0x154b3f`, `0x36d5c2`, `0x4cb820` | **Accepted**: literal bytes with unambiguous ASCII context in both binaries; RTTI signature confirms `x,y,z: Single`. |
| P3 | Parse `sub_69a70c` `mov ecx,<impl>; mov edx,<signature>; call [esi+0x30]` pairs (635 pairs) | `StandPattern → 0x6b28d8`, `StandPatternWithAngleAdv → 0x6b2b60`, `LoadPatterns → 0x6b27e4`, `SetHeightData → 0x6b3300`, `GetHeightData → 0x6b31c4` | **Accepted**: deterministic pattern with direct function-prologue bytes at each ECX target (`55 8b ec …`). |
| P4 | `native_function_pseudocode` + `native_function_show` on `0x6b2b60` | Ghidra output is group/creation boilerplate: calls `FUN_00755f30(...)` then manipulates `group.` names | **Accepted as wrapper, not stamp** (ev_e65fb8fd…); followed the callee rather than declaring "garbled". |
| P5 | `native_function_study` (summary) + `native_function_callees_list` + Ghidra pseudocode on `sub_755f30` | 234 blocks / 6,751 instructions; x87 `float10` locals make pseudocode hard to read but branches on `[p+0x3a]`, `[p+0x3b]`, `[p+0x48]`, `[p+0x5c]`, `[p+0x64]`, `[p+0x68]` are visible | **Provisional**: derived branch hypotheses here, then verified in P6. |
| P6 | `native_function_instructions_list` raw assembly `0x7563e8`–`0x7566e9` (ev_dbc8c87e…) | Exact opcodes: `cmp [p+0x3b]`, `fsub [p+0x5c]`, `fmul [ebp-0x20]`, `fadd [p+0x5c]`, `fsubr [ebp-0x10]`, `fmul [p+0x68]`, `fadd [p+0x64]` | **Accepted**: independent of Ghidra's x87 naming; confirms both branch polarity and operand order. |
| P7 | Raw assembly of config parser `sub_75c314` (ev_44c61fad…) | Each config literal pointer (`mov edx,0x75c7xx`) followed by `mov/fstp [ebx+offset]`; e.g. `HeightFieldMin → +0x5c`, `Max → +0x60`, `Offset → +0x64`, `Replace → +0x3a`, `ReplaceForWater → +0x3b` | **Accepted**: this removes all guesswork about which flag is which. |
| P8 | Same parse in `editor.exe` @`0x8cc7ae`–`0x8cc91f` | Identical offsets (+0x39/+0x3a/+0x3b/+0x3c/+0x40/+0x44/+0x48/+0x68/+0x6c/+0x4c/+0x50/+0x54/+0x58/+0x5c/+0x60/+0x64/+0x74/+0x78/+0x80/+0x81/+0x82) | **Accepted**: independent binary corroboration; no single-pass misread survives. |
| P9 | `pattern.lib` literals + `.pattern` decode cross-check (E13/E14) | `hil1 Scale=0.649999976158142`, `k_ravine_1 Min=-2.963627576828 Max=3.13982009887695`, both grids match those literals bit-exactly (DPATTERN_01 §4.7) | **Accepted**: config values are the exact floats fed into `+0x48/+0x5c/+0x60`. |
| P10 | Raw-byte scan for `Max` accesses inside the stamp + helper study (`sub_755db4`, `sub_7551a8`, `sub_7553a0`, `sub_810498`) | No `+0x60` access in stamp; setters wrap coordinates; getter reads current height; `0x810498` is a bilinear terrain sampler | **Accepted**: clamp-to-Max claim refuted for this function; global setter clamp remains **[U]**. |

---

## Findings

### F1 — Call chain and payload load [O]

```
DScript StandPattern(plhandle, patternname, standx, standz, rotangle)
  → 0x6b28d8 (native wrapper)
  → 0x6b2878 StandPatternWithAngle(minangle=maxangle=rotangle)
  → sub_6b2b60 StandPatternWithAngleAdv  [wrapper/group bookkeeping only]
  → sub_755f30(pattern*, player*, 0, standx, standz, rotangle, minangle, maxangle)
```

`sub_755f30` first calls lazy loaders: `sub_75ca34` (`if +0x89 == 0`) reads the `.pattern` binary into arrays; `sub_75cf6c`, `sub_75cfb8`, `sub_75d004` load the other three payloads (`+0x8a/+0x8b/+0x8c` flags). `sub_75ca34` (VA `0x75ca34`–`0x75cf09`, Ghidra pseudocode + raw assembly) shows the on-disk sizes exactly:

| Struct offset | Payload | Allocated size |
|---|---|---|
| `+0x24` | byte mask / stamp-occupancy | `w * h` bytes |
| `+0x28` | **float32 height grid** | `(w + 1) * (h + 1)` floats (loader decrements `Width`/`Height` first, then allocates `Height-1+2` × `Width-1+2`) |
| `+0x2c` | object records | `w * h * 0x18` bytes each |
| `+0x30` | decal records | `w * h * 0x10` bytes each |
| `+0x34` | tag/collision records | `w * h * 0x0d` bytes each |

This is consistent with DPATTERN_01 §2.1/§2.3 (`k_ravine_1 w=46 h=63`, 24-byte records) and explains why its 8×10 tables are *downsamples* rather than the stamped payload.

### F2 — Exact config-field → struct-offset map [O] (P7/P8)

Parsed from `sub_75c314` (`cossacks.exe` VA `0x75c314`; `editor.exe` VA `0x8cc79d` region). Defaults shown are the literal pushed before each getter (`0x3f800000` = 1.0f, `0` = 0.0f).

| `pattern.lib` field | Offset | Default | Evidence (VA→store) |
|---|---|---|---|
| `Name` | `+0x14` | — | `0x75c3b8` |
| `Width` / `Height` | `+0x1c` / `+0x20` | — | `0x75c3dd`, `0x75c3ee` |
| `TilesStand` / `GameObjectsStand` / `DecalsStand` | `+0x18/+0x19/+0x1a` | true | `0x75c3ff`, `0x75c410`, `0x75c421` |
| **`HeightFieldStand`** | **`+0x39`** | true | `0x75c432` |
| **`HeightFieldReplace`** | **`+0x3a`** | false | `0x75c443` |
| **`HeightFieldReplaceForWater`** | **`+0x3b`** | false | `0x75c454` |
| `HeightFieldUseRndScale` | `+0x3c` | false | `0x75c465` |
| `HeightFieldMinScale` / `MaxScale` | `+0x40` / `+0x44` | 1.0f | `0x75c479`, `0x75c48e` |
| **`HeightFieldScale`** | **`+0x48`** | 1.0f | `0x75c4a3` |
| **`TerrainScale`** | **`+0x68`** | 1.0f | `0x75c4b8` |
| `ObjectsScale` / `RotationAngle` | `+0x6c` / `+0x70` | 1.0f / 1.0f | `0x75c4cd`, `0x75c4e2` |
| `HeightFieldSmooth` | `+0x4c` | false | `0x75c4f4` |
| `HeightFieldSmoothRadius` / `Factor` / `Offset` | `+0x50` / `+0x54` / `+0x58` | 0 / 0 / **2** | `0x75c505`, `0x75c516`, `0x75c52a` |
| `PatternMaskStand` / `PatternMaskReverceStand` / `CollisionStand` | `+0x80/+0x81/+0x82` | false/false/true | `0x75c53b`, `0x75c54f`, `0x75c563` |
| `OffsetX` / `OffsetZ` | `+0x74` / `+0x78` | 0 | `0x75c577`, `0x75c589` |
| **`HeightFieldMin`** | **`+0x5c`** | 1.0f | `0x75c5e2` |
| **`HeightFieldMax`** | **`+0x60`** | 1.0f | `0x75c5f7` |
| **`HeightFieldOffset`** | **`+0x64`** | 0 | `0x75c60c` |

The parser calls three generic getters: `0x8967b4` (Bool), `0x896a8c` (Int), `0x896b1c` (Float with default). No other module in the EXE contains these field names as plaintext (E2/P1), which is why previous waves found "no consumer".

### F3 — Scale / random scale [O]

`sub_755f30` VA `0x7563e8`–`0x75641a` (file `0x3557e8`–`0x35581a`):

```
if (p.UseRndScale)                         // +0x3c != 0
    scale = random_between(p.MinScale, p.MaxScale);   // call 0x403a28 (LCG: x=x*0x8088405+1) then 0x4a2b6c
else
    scale = p.HeightFieldScale;            // +0x48, e.g. 0.65 or -0.925
```

Constants observed: `0.649999976158142` (`hil1`), `-0.925000011920929` (brush patterns), `1.0` (669/680 patterns).

### F4 — The exact stamp (height loop) [O]

`sub_755f30` VA `0x756441`–`0x7566e9` (file `0x355841`–`0x355ae9`). `h[x,z]` denotes the world height field; `p` is the parsed pattern object.

```c
if (!p.HeightFieldStand) goto done_height;          // 0x756441: cmp [p+0x39],0 → je 0x7566ff

float base_h = bilinear_sample_world_height(world, stamp_centre);  // 0x810498 @0x756435
                                                    // params include -z, x and centre offsets
for (int r = r0; r <= r1; r++)                      // world z / pattern row
  for (int c = c0; c <= c1; c++)                    // world x / pattern col
  {
     if (occupancy[r][c] != 0) continue;            // 0x756638 (mask at +0x24)
     float g = p.heightGrid[r - r0][c - c0];        // 0x7565e6..0x7565fb, pointer +0x28, float stride 4

     if (!p.ReplaceForWater)                        // 0x756601 cmp [p+0x3b],0
         g = (g - p.HeightFieldMin) * scale + p.HeightFieldMin;   // 0x756607..0x756619
     else
         g = g * scale;                             // 0x75661f..0x756625

     if (p.ReplaceForWater) {                       // 0x756645 jne
         setHeight(c, r, g + p.HeightFieldOffset);                        // 0x75664b..0x756664
     } else if (p.Replace) {                        // 0x75666e cmp [p+0x3a],0
         setHeight(c, r, base_h + g + p.HeightFieldOffset);               // 0x756674..0x756690
     } else {                                       // "Smooth" / default
         float h0 = getHeight(c, r);                // 0x7553a0 @0x7566a0
         float t  = (base_h - h0) * p.TerrainScale  // fsubr @0x7566a5, fmul [p+0x68] @0x7566ab
                  + g + p.HeightFieldOffset;        // fadd @0x7566ae, @0x7566b4
         float h1 = getHeight(c, r);                // second read @0x7566c7
         setHeight(c, r, t + h1);                   // faddp @0x7566d2, setter @0x7566e4
     }
  }
```

Notes on each question posed in the assignment:

- **(2) Exact blend modes.** Three paths as above. `ReplaceForWater` dominates `Replace`; all audited patterns have `Replace=false`, so only ReplaceForWater and Smooth occur in the skirmish set (85/680 have ReplaceForWater=true).
- **(3) Order of operations.** RNG scale → grid fetch → (`g-Min`)*scale+Min or `g*scale` → mask gate → mode-dependent add with `HeightFieldOffset` → setter. `HeightFieldMin` is applied **before** the blend; `HeightFieldMax` is not applied here.
- **(4) Compared to which previous value.** There is **no comparison against Min/Max** in the stamp. Min is a subtract/add pivot; Max is unused. The only "previous value" read is the **current world height at the same cell** (`getHeight` twice, for `h0` and `h1`), plus the **bilinear world height at the stamp centre** (`base_h`). With the universal `TerrainScale=1`, the Smooth branch reduces algebraically to `h_new ≈ base_h + g + Offset` (exact when `h1 == h0`).
- **(5) Sign / row orientation.** `0x7565e6`: row index = `ebx - esi` (world z loop counter), `0x7565f8`: col index = `ebx - esi` (world x loop counter). Storage is `float**` rows of width `+0x1c` (Width). Row increases with map y/z, column with map x; stamp coordinates are rotated by `sin/cos(rotangle)` (`0x403404`/`0x40342c`) around the centre `standx + OffsetX(+0x74)`, `standz + OffsetZ(+0x78)`. Centre offsets: `+0x74/+0x78`, half-cell divisor constant `2.0` @`0x75c1a4`, half offset `0.5` @`0x75c1a8`. **Which file row corresponds to negative world y remains [U]** (DPATTERN_01:121-124). Negative `HeightFieldScale=-0.925` inverts grid values around 0 (ReplaceForWater branch) or around `Min` (other branch); it never negates the world height directly.
- **(6) globalparams.cfg.** Read in full (`ev_38b552b9…`, 22/22 lines): no `HeightFieldScale/Min/Max` keys. Line 15 `PatternPlayerName = pattern` is the only pattern hook; other globals (`Size=512`, `Sharpness=0.6`, `FrequencyFactor=0.000013`, `TileSmoothPasses=6`) feed terrain generation/smoothing, not the stamp's sculpt fields. All sculpt constants arrive from `data\pattern\pattern.lib` via `sub_75c314`.

### F5 — Smooth post-pass [O]

`sub_755f30` VA `0x756eb3`–`0x757286` (file `0x3562b3`–`0x356686`): only if `HeightFieldStand && HeightFieldSmooth` (`+0x39`, `+0x4c`). For interior cells whose own byte and all eight neighbours in the mask are 0 (`0x757077`–`0x757161`):

```
d  = sqrt((x-cx)^2 + (z-cz)^2)
tx = round(cx + (x-cx) * (Radius - Offset) / d)       // 0x75717a..0x7571ce
tz = round(cz + (z-cz) * (Radius - Offset) / d)       // 0x7571ef..0x757243
repeat Factor times:                                  // 0x757167, +0x54
    for (u,v) inside circle |(u,v)-(tx,tz)|^2 < Radius^2   // +0x50, 0x755db4
        h(u,v) = (h(u-1,v)+h(u+1,v)+h(u,v-1)+h(u,v+1)) / 4.0f   // const @0x755ee4
```

`k_ravine_big_stone_1` uses Radius=3, Factor=4, Offset=0; brush patterns use Radius=1, Factor=4, Offset=1 (values observed in `pattern.lib`, first section at file `0x339`). `[D]` The `/4.0` divisor matches `HeightFieldSmoothFactor=4` numerically, but the binary uses the hardcoded constant `4.0`; the config `Factor` is consumed as the **iteration count**, not the divisor. This is a concrete correction to the port's "radius/factor/offset semantics UNVERIFIED" note.

### F6 — Pixel/data cross-check of the quoted constants [O]

| Constant | Binary / data location | Value |
|---|---|---|
| `HeightFieldScale` (`hil1`) | `pattern.lib` file `0x0d0894` section | `0.649999976158142` (float32 0.65) |
| `HeightFieldMin` (`k_ravine_1`) | `pattern.lib` file `0x0d89b20` section | `-2.963627576828` (= float32 `-2.963627576828003`) |
| `HeightFieldMax` (`k_ravine_1`) | same | `3.13982009887695` |
| `HeightFieldScale` (brush) | `pattern.lib` file `0x339` | `-0.925000011920929` |
| half-cell / half-offset | `cossacks.exe` VA `0x75c1a4` / `0x75c1a8` | `2.0f` / `0.5f` |
| smooth divisor | `cossacks.exe` VA `0x755ee4` | `4.0f` |
| LCG random multiplier | `sub_403a28` (`0x403a28`) | `0x8088405` (`x = x*0x8088405 + 1`) |
| bilinear half-cell | `sub_810498` VA `0x810964` | `0.5f` |

---

## Implications for the port (no source changed by D05)

1. **Replace the labelled approximation.** `PORT APPROXIMATION ADDITIVE_CLAMP` (`DPATTERN_01:373-378`, `G07_relief_plan.md:366-368`, `A05_relief_visibility.md:313`) should be replaced in the spec by the three donor branches of F4. Label the implementation `DONOR-DERIVED` only for the operations above; still label row-flip and global clamp as approximations.
2. **Min/Max semantics change.** Do **not** clamp stamped heights to `[Min, Max]`; Min participates in `g = (g-Min)*Scale + Min` for `ReplaceForWater=false`; Max is unused in this stage. Export both literals verbatim (they remain exact metadata from `pattern.lib`).
3. **Use the grid, not coarse means.** The 8×10 tables are preview aids (`DPATTERN_01:599-600`); the engine consumes the full `(w+1)*(h+1)` float plane at `+0x28` with mask gating at `+0x24`.
4. **Water/replace patterns differ.** For `ReplaceForWater=true`, `new = g*Scale + Offset` (no base height, no TerrainScale, no current height read). This is a different visual result from additive stamping and should be a separate branch in the fresh module.
5. **Smoothing is an ordered post-pass**, not part of the per-cell blend: interior-only, 8-neighbour mask test, radial remap by `(Radius-Offset)/d`, `Factor` repetitions of a 4-neighbour mean divided by 4.0.
6. **`globalparams.cfg` cannot be the source of stamp scale**; the decoder must read `pattern.lib` sections. Keep `PatternPlayerName` as the lookup hook.
7. **No parity claim.** All of the above is static analysis of donor bytes; no donor frame was rendered, so no donor visual parity is asserted.

---

## Risks

- **R1 — Ghidra x87 noise.** PASS 5's `float10` locals (`in_ST1`, `fVar13`, …) are unreliable for operand naming; every conclusion in F4 was re-derived from raw x87 opcodes in PASS 6. Any future re-decompile must repeat that cross-check.
- **R2 — Function discovery incomplete** (`ev_60b49743…`: 6,000,000-instruction cap, 1,238 unresolved indirect jumps). D05's anchors are direct-call reachable and were found via the native registration table, so the gap does not affect F1–F5, but other workers should not assume exhaustive coverage.
- **R3 — `.bind` section entropy 7.96** (packed/unanalysed code). If any secondary stamp path lives there, D05 did not observe it; absence is not proof.
- **R4 — Global setter clamp.** `setHeight` (`sub_7551a8`) delegates to `sub_0059b934`; whether that applies a map-wide height ceiling (DPATTERN_01 §9 Q8 mentions a baked −2.964 ceiling) is outside this pass.
- **R5 — Rotation/jitter arithmetic.** The sin/cos centring block (`0x75646e`–`0x7565d5`) is decoded only at opcode level; exact sub-cell rounding of stamp coordinates is **[U]**.
- **R6 — Beta risk of defaults.** Parser defaults (`Min=Max=1.0f`, `SmoothOffset=2`) are observed, but all real sections override them, so they matter only for malformed configs.

---

## UNVERIFIED register

| Id | Claim | Status / passes attempted |
|---|---|---|
| U1 | File row `v` → sign of centred world y (flip flag) | **[U]** P9 data-only decode cannot bind sign; P6 assembly shows row→z but not file row→centre sign. Keep `PORT APPROXIMATION` for flip. |
| U2 | Any clamp to `HeightFieldMin/Max` after blending | **[U]/refuted for stamp** — P6 + P10 found no `+0x60` read in `sub_755f30`; global setter `sub_0059b934` not studied. |
| U3 | Exact rounding of rotated sub-cell coordinates | **[U]** P6 saw `sin/cos` and `/2.0` but did not prove integer rounding rule. |
| U4 | `HeightFieldSmooth` `Offset` sign in radial remap | **[D]** `(Radius - Offset)/d` read from opcodes `0x7571a4`–`0x7571bb`; effect on authored patterns not runtime-tested. |
| U5 | Exact float-plane byte boundary in `.pattern` (±24–160 B ambiguity) | **[U]** inherited from `DPATTERN_01:110-118,542`; loader sizes clarify allocation but not on-disk start for all patterns. |
| U6 | Runtime effect of `PatternMaskStand` / `PatternMaskReverceStand` on the occupancy byte used at `0x756638` | **[U]** P6 shows `sub_755168` writing that array early in the stamp; the flag semantics need a separate pass. |
| U7 | `Replace=true` behaviour on a real pattern (all 680 audited have `Replace=false`) | **[O] code path** / **[U] observable incidence**. |
| U8 | Visual parity with donor | **[U]** no donor GPU A/B frame; no parity claim. |

---

## Open questions

1. Does `sub_0059b934` (global height setter) clamp to a map-wide ceiling/floor, and is that ceiling the reason `k_ravine_4 min −3.06597` sits below the baked −2.964 (`DPATTERN_01:553`)?
2. What exact rotation/jitter does `0x75646e`–`0x7565d5` apply to the loop origin (the `FUN_004a6aa0` random calls and `0.5` offsets)?
3. Is `HeightFieldMax` consumed by any *other* engine path (editor preview, brush tools) outside `sub_755f30`?
4. Does `PatternMaskReverceStand` invert the occupancy byte before the height gate for any active skirmish pattern?
5. Are the 8×10 downsample rows in `DPATTERN_01` Appendix A aligned with the world z sign once Q3/U1 is resolved?
6. Does the same stamp function serve map generation and the terrain editor differently via `plhandle`/`param_3` (the `0` passed at `0x755f30` call site)?

---

*End of D05 report. One Markdown report written; donor read-only throughout; no donor bytes copied into the repository; no source, asset, config, test or git change; no donor visual parity claimed.*
