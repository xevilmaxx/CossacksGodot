# DEC_U_placement — object/forest/mine/field placement rules (read-only decomp)

- id: DEC-U-PLACEMENT
- worker: DEC-U-PLACEMENT (subagent, full 1:1 Cossacks 3 donor port)
- date: 2026-11-26
- scope: READ-ONLY decomp. Donor binary never executed/copied. No code/asset/config/Godot/git edits. Exactly one repo file written (this report).
- pin: `t_87f0f3c130b0` = `C:\Games\Cossacks 3\cossacks.exe`, PE32, 5,768,048 B, sha256 `87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c`
- upstream re-read, not re-argued: `PORT1TO1_terrain_generation.md` (§A–H), `DEC_U_gen_seed.md` (§2–5), `DEC_U_vision_audit.md` (G=0 note), `DEC_DEEP_placement_755f30.md`, `DEC_DEEP_forest_generation.md`, `DEC_LANDSCAPE_item_placement.md`, `DEC_DEEP_prop_water_exclusion.md`, `DEC_DEEP_prop_efficiency.md`, spec `07_RESOURCES.md` / `08_FIELDS_AND_PROPS.md` / `03_MASK_TO_HEIGHT.md` / `10_STAGE_ORDER.md`
- labels: [O] donor text/bytes/VA re-read or carried verbatim with evidence id · [D] arithmetic/control-flow consequence · [U] UNVERIFIED (fixed-seed zero-mismatch probe given, never substituted) · PORT APPROXIMATION = port substitute
- parity: NO PARITY CLAIM. No donor GPU frame, no engine trace, no A/B comparison.

## 0. Multi-pass discipline (owner rule: ≤5 passes per oddity)

| Pass | What was done | Result |
|---|---|---|
| P1 | Re-read `PORT1TO1` §§B/F/G + `DEC_U_gen_seed` §§2/5 + `terrain_donor_gen.gd` stages 5/7/8/9 in full | placement stage order, RNG site ledger, G=0 context recovered |
| P2 | Re-read `DEC_DEEP_placement_755f30` §§1–8 + `DEC_LANDSCAPE_item_placement` §§2–7 + `DEC_DEEP_forest_generation` §§1–8 + `DEC_DEEP_prop_water_exclusion` §§[O]/[D] | pixel→class table, ring/band matrix, roulette/damping, mask-only checker, no-RNG-in-stamp carried as [O] with ids |
| P3 | Re-read `terrain_donor_gen.gd:1108-1212` (mask decode), `:2213-2450` (mines/starts), `:2456-2598` (stand), `:2920-3221` (roulette/relief/forest), `sow_field` + `field_sowing_hook_info`, shore/exclusion/entry/ledger helpers | per-function line anchors for §8; confirmed no invented density, 25-cell lattice removed from family path, 7-way draw present |
| P4 | Cross-checked donor-text line refs (`generatemap.inc`, `dogenerate.inc`, `misc.script`, `smoothforestborders.inc`, `dmscript.global`) against port constants/hooks; checked `terrain_donor_inputs.gd` compact bundle surface | object `Objects[]` still absent; `fa/broad`, S0 kernel, `minx/miny`, modifiers, Delphi seed still [U]; each gets §7 probe |
| P5 | Wrote this report only; verified no other file created/edited | single-file discipline kept |

Donor `.inc` note: no separate `object*.inc` file set was found in the audited tree. Object placement truth lives in `dogenerate.inc` + `misc.script` (`_misc_CheckStandPattern[Ext]`, `_misc_SetupPatternsByType`, `SetupMines`, `SetupStartingResources`, roulette/damping) + `pattern.lib` `Objects[]` + native `sub_755f30` family (`0x755f30`) + `sub_723748` driver (`0x723748`). That is what is cited below.

Carried pinned addresses (all `t_87f0f3c130b0`, read-only): `sub_755f30 0x755f30–0x75c187` (234 blocks / 6,751 insns / 662 callees / 5 callers, `ev_ed57855c…`); wrapper `sub_75c228` (`0x42b40000`=90.0f, `ev_370b6b…`); mask prims `0x755168/0x7550f8/0x75505c/0x764e04`; pre-transforms `0x755bc8/0x755d1c/0x755c6c`; dispatch `0x755664→0x59b8a4` / `0x755920→0x59b854`; smooth `0x755db4` (divisor `4.0 @0x755ee4`); constants `2.0 @0x75c1a4` (252 xrefs), `0.5 @0x75c1a8`, `0.0/90.0 @0x755c58/0x755c68, @0x755da0/0x755db0, @0x755d08/0x755d18`; setter `0x8326b8` (a-outer/b-inner fan-out, variant `call 0x403a0c @0x832727`); Delphi `Random(256) 0x403a0c` (`imul edx,[ebx+0x8f2008],0x8088405; inc; mov; mul; mov eax,edx`, `ev_6478320b…`); state slot `0x8f2008` (image `00…00`, `ev_0e686c8c…`/`ev_bde23e2d…`); seeder `sub_4033b8` (QPC-thunk `0x401450` else TickCount-thunk `0x401458`, `ev_78bcf9c8…`, 3 non-generation callers `ev_583b7258…`); RandomExt `0x60f64c–0x60f698` (`s=(s*0xFC0D+0x3C6EF35F) mod 2^32`, f32 out); RTTI `SetRandomKey @0x60a6b2`, `SetRandomExtKey64 @0x60a72e`, `GenerateMapRandKey @0x69f452` (0 static xrefs, `ev_9defac5a…/ev_661ef2e6…/ev_3e61f9fa…`); renderer installer `0x8177f0` (`ev_9ce28a17…`), producer `0x812e34` (`ev_58d7418c…`).

## 1. Pixel/tag → object-class rules [O]

Let `fr,fg,fb,fa ∈ [0,1]` be `GetBitmapPixel` floats; `ir=floor(fr*255)`, `ig=floor(fg*255)`, `ib=floor(fb*255)`. Source: `generatemap.inc:21-32,413-495` (`ev_2d298dd2…`, PORT1TO1 §B.2).

### 1.1 R → `terrain` + `bsmooth` [O text; inert on shipped masks]

| `ir` | class | `bsmooth` | donor constant |
|---:|---|---|---|
| 255 | `cRPlateau` | False | `cRColorPlateau` |
| 191 | `cRPlateau` | True | `(255 div 2)+64` |
| 96 | `cRHill` | False | `cRColorHill` |
| 112 | `cRHill` | True | `(96 div 2)+64` |
| 48 | `cRRavine` | False | `cRColorRavine` |
| 88 | `cRRavine` | True | `(48 div 2)+64` |
| 64 | `cRNone` | True ("smooth me, no class") | `128 div 2` |
| else | `cRNone` | False | — |

Smooth codes are exactly `(base div 2)+64` [D]. Height contribution is `§1.4`, not a prop rule.

### 1.2 G → `forest` enum [O text; side data only in port]

| `ig` | donor enum | port `forest_density` side value (`terrain_donor_gen.gd:1171-1178`) |
|---:|---|---|
| 255 | `cGForest` | 1 |
| 127 (`255 div 2`) | `cGForest` **only if** `terrain ∈ {plateau,hill,ravine}`, else unchanged | 1 (port does not gate on terrain — see §8 P-PLACE-02) |
| 64 | `cGGenForest` | 2 |
| 128 | `cGStone` | 3 |
| 192 | `cGForestStone` | 4 |
| else (incl. 0) | `cGNone` | 0 |

Critical: **no free-forest/stone prop is spawned from this enum.** `G` selects the `SmoothForestBorders` dress path (post-pass, `smoothforestborders.inc:30-171`, `ev_d9f4ed1f…`), not a density. Free forests/stones come only from `SetupStartingResources` (§3) and `SetupPatternsByType` (§2/§4). Do not map `forest_density ∈ {1..4}` to a stamp count.

### 1.3 B → `water` class [O]

`ib == 255 (cBColorWater)` → `cBWater`, else `cBNone` (`generatemap.inc:486-487`). This is a discrete class, distinct from the continuous bed `fb` and from the tile tag `B>0 & h<-0.25`. Port `_mask_water` (`terrain_donor_gen.gd:1181`) matches [O].

### 1.4 `fa` → `broad` (road) [O text / runtime U]

`if (fa>0) then broad:=True` (`generatemap.inc:450-453`). All shipped `_gauss` masks are 24-bit (4,466-mask census, no alpha byte) so `fa` is a loader default on shipped data. Road tiles `ground1/test2/test3` (`texturemap.inc:622-636`, `RandomExt>0.5→ground1, >0.25→test2 else test3`) stay omitted with label. Never invent `broad=True` on shipped inputs.

### 1.5 White starts [O]

Exact `fr=fg=fb=1` (byte 255/255/255) at `generatemap.inc:413,325` is recorded as a start, then zeroed (`:440-443`) before class/height decode. Dedup: scaled branch (`srcwidth>mapwidth`) compares only the immediately previous accepted start (`:329/419-435`); equal-size branch compares all accepted starts (`:417-435`). No minimum-distance rule. Height pass skips on `(bRandomMap) and (fr=1) and (fb=1)` — `fg` ignored (`:565`) [O asymmetry]. Port implements exact equality + both dedup branches + the `fr&fb` skip (`terrain_donor_gen.gd:1121-1151,1190-1192`) [O].

### 1.6 Occupancy prefill that actually runs in skirmish [O]

- Random-map blanket `D2:491-495`: non-black, non-white mask cell → occupied [O] (port `:1182-1184`).
- Shore band `D1:1568-1581`: unoccupied cell with `height<-0.1` → occupied, runs after `GenerateMap` smoothing, before starts [O] (port `_stage_shore_exclusion`, `:2056-2066`).
- Border `_misc_FillPatternMaskMapBorder(3)` at `D1:1613`: `x<3 ∨ x>W-3 ∨ y<3 ∨ y>H-3` → occupied, **before** `RandomStartingPoints(:1615)` [O] (port `_fill_map_border` called before start loop, `:2139`).
- Three start ellipses `5×7`, `12×15`, `22×18` centred `(x,z+2)` (`D1:407-416,769,947,980-988`) [O] (port `_fill_ellipse`, `:2187-2199`, with `+2` at `:2165-2167,2409,2448`).
- The `generatemap.inc:811-850` water/bsmooth/broad/collision layer pre-mark is **editor-only** (`if (cPlaceFreeForests) and (not bRandomMap)` at `:799`, PORT1TO1 §0.2 item 4). It must not pre-mark skirmish water. Port gates it behind `not b_random_map` (`:2064-2065`, `_editor_layer_premark` `:2071-2092`) [O].
- `gc_WaterBorderSize=3` ring belongs to finalize `_misc_SetShoresCollision` (`D1:2068`), after all placement — never a placement-time blocker [O] (port `_shore_collision_ring` at finalize, `:3328-3338`).

`_misc_CheckStandPattern[Ext]` has no water/collision/topology test inside (`misc.script:3384-3521`, `ev_926b544d…`; native `0x755168/0x7550f8/0x75505c/0x764e04`, `+0x80 & maskByte` gate). Water/shore rejection is emergent from the above pre-marks [O/D].

## 2. Forest/tree density formula, including the `G=0` case

### 2.1 `G=0` verdict: zero mask-driven density [O, do not invent]

On all 1,331 shipped vanilla `_gauss` masks (X18/X19 full census, carried), `R=G=0` on every non-start pixel; the only 255s are 5,125 single-pixel white starts. Hence `ig=0 → cGNone → forest_density=0` on every placeable cell. **There is no donor density derivation from `G` on shipped data.** Any port formula of the form `count = f(G)` on vanilla masks is invented. The live density dials are exclusively:

1. `SetupStartingResources` ring probes (§3), and
2. `_misc_SetupPatternsByType` global passes (§2.2) with roulette + damping + occupancy reject (clumps/glades emerge from rejection, not from an explicit clearing pass).

`DEC_U_vision_audit.md` §-style note applied here: keep the R/G enum decode as schema intent + raw-channel preservation, never map G→count.

### 2.2 Global forest/stone density formula [O] (`misc.script:3681-3729`, `dogenerate.inc:1688-1725`)

Per family call `SetupPatternsByType(str, freq)`:

```
mapsizeoptimise = (320*320)/(W*H); if <1: *=0.65          (D9:3687-3688)
needed = floor(W*H*freq)                                   (D9:3696)
if needed==0 and freq>0: needed = round(W*H*freq)           (D9:3696-3700; may stay 0)
trycount = floor(256*mapsizeoptimise)                       (D9:3701)
for i:=0..needed-1:
  name = Roulette(str)                                      (D9:3709; §6.1)
  for j:=0..trycount-1:
    x = floor(x0+RandomExt*W); y = floor(y0+RandomExt*H)    (D9:3703-3704)
    x0=-(W div 2); y0=-(H div 2)
    if CheckStandPatternExt(env,name,x,y,True): damp(name); break
```

Port `_setup_patterns_by_type` (`terrain_donor_gen.gd:3098-3171`) reproduces `needed` (`:3104-3106`), `mapsizeoptimise` (`:3107-3109`), `trycount` (`:3110`), uniform centred draws (`:3150-3154`), name-once-per-`i` then position loop (`:3134-3168`), damp-only-on-accept (`:3162`) [O]. At 320² with modifiers ≡1: big-conifer ≈11/family ×4, mid ≈15×3, small ≈13×2, stones 16+12 (DEC_DEEP_forest §4).

Base rates [O] (`dogenerate.inc:1688-1693`): `frs_big=0.0009`, `frs_mid=0.0009`, `frs_small=0.00054`, `dcr=0.0005`, `stn1=0.00016`, `stn2=0.00012`. Modifiers `probsmall/mid/large/huge` from `_misc_GetFreePatternMaskModifier` + size rescale `640/((W+H)/2)` (`D1:1715-1724`) are engine-side [U]; port takes caller `pattern_modifiers` verbatim with label (`:3044-3053,3180-3182`) — never invent values.

Non-desert fan-out [O] (conifer-only, `foreststype` forced 0 at `D1:5-6`, one `RandomExt` draw consumed at `D3:146` scope, port `:997-1003`):

```
forests_pinefir_big / spruce_big / pine_big / pine_big_2 : frs_big/8 each   (D1:1838-1845)
stones stn1                                                              (D1:1846)
pump/christmas event gates only                                          (D1:1848-1851)
plain_big/small/medium                                                   (D1:1853-1854,1906)
forests_spruce_medium / pinefir_medium / pine_medium : frs_mid/6 each     (D1:1855-1861)
stones stn2                                                              (D1:1862)
forests_pinefir_small / pine_small : frs_small/4 each                     (D1:1866+)
swamp_big/medium/small, lake_big=0 (desert lake_big=plain*35)             (D1:1899-1906)
```

Desert halves `frs_*` (`D1:1781-1785`); desert family names switch (`desert_forests_*`, `desert_stones`) with `bDesert=(season==3)` outer gate [O]. Port desert branch (`:3188-3191,3214-3216`) is present but the full desert family fan-out is partial — see §8.

Relief-family fan-out [O] (`D1:1747-1766`, port `:3068-3082`): `mountains mnt`, `plateau_big plt/3`, `plain_huge`, `ravine_big plt/1.5`, `plateau plt/3`, `plateau_small plt/3`, `hills_dark/light hil/2` (+ desert mirrors). `relieftype>4 → floor(RandomExt*5)` at `D1:1621-1622` (port `:3038-3039`).

### 2.3 Border dress (not density) [O] (`smoothforestborders.inc:36-148`)

`count=floor(1+RandomExt*16)` but unconditional `break` at `:151` → **one stamp per eligible cell**; `rad=1.5`, `pind=floor(1+RandomExt*53)`, corner `fb_*` + tiles `grass5/rock9` (`_winter` suffix), `grid=3` cells dress only with `p=0.025` (`RandomExt>0.975`); only the `count==1` single-neighbour edge enters. Only the pine path (`forestType=0`) dresses `fb_1..53` in visible text; leaf/mixed pools are absent [U]. Port has no border dress stage — §8 P-PLACE-11.

## 3. Mine placement and spacing [O]

Skeleton (`dogenerate.inc:522-717`, `ev_a33507f9…`): `trycount=256`; `rounds=3/4/5` for `minesdensity 0/1/2` (`:528-534`); `if maxround>0 and rounds>maxround: rounds:=maxround`; `for i:=minround..rounds-1` (RING) → `for j:=0..2` (ORE `mng/mni/mnc`, `desert_` prefix on desert) → `for k:=0..255` (ANGLE ATTEMPTS). Near call `(minround=0,maxround=1)` at `:985`; global call `(1,0)` at `:1769-1770` **per start** (port `:3090-3093` loops starts [O]; single-centre call is gone).

Bands are ring radii in **map cells 1:1** (V08; never ×2), shared by all three ores [O]. Live branch on shipping `gDataVersion=92` (`serial.script:27`, V01) with `v>=80`:

- `mapsize>2` (=256-cell TINY per `donewgame.inc:46`, V01) `v>=80`: `0:14+8R, 1:32+10R, 2:70+12R, 3:22+16R`, ring 4 skipped (`:595-601`).
- Default 320/480/640 maps use `mapsize<=2` rows (`:608-654`): for `spcount<=4,v>=80` labels `0,1,3,4,5` with **no `case i of 2`** — ring 2 inherits stale/zero `dst` (VM init [U]); ring 5 `continue` (`:639-645`). Full matrix incl. `v<70/<75/<77/<80` and `spcount>4` in port `_band_id` (`:2272-2346`) [O].
- Anomaly preserved: port keeps zero-init `dst` + `gap_reproduced` flag + `ring2_dst_mode` telemetry (`:2222-2223,2231-2237,2253-2255`), never silently repairs [O].

Per-attempt draw order [O]: (1) `_misc_GetPatternNameByParser` name roulette (1 `RandomExt` draw even when the family list is empty — port `:2947-2955` preserves it); (2) `dst = base+span*RandomExt` **only when the donor case assigns** (port `_mine_band` draws only on `band>=0`, `:2263-2269`); on `continue` rings the name draw is still consumed (256× per ore) and **no angle draw occurs**; (3) `angle=RandomExt*360`, `VectorRotateY`, `round(centre+px/pz)` (port `:2240-2244`); (4) `CheckStandPatternExt(...,True)` + `PatternIncreaseFreq` + `break` on first success (port `:2247-2252`). Far-ring relocation (`i=2,spcount<=4,mapsize>2,v>=90`) snaps centre to quadrant corner `±(maphW-24),±(maphH-24)` in centred coords (port `_mine_centre`, `:2376-2387`) [O].

Spacing: there is **no explicit mine↔mine minimum distance**. Spacing is emergent: ring-band radii + per-ore 256 first-accept + occupancy stamp + damping (`Freq*=0.2`, floor `0.0001`, `FreqSum` fixup). Weighting: `_misc_GetPatternNameByParser` `freqrnd=RandomExt*FreqSum`, first `freqrnd<Freq` (`misc.script:3634-3653`); missing `Freq` defaults 1 [O] (port `:2938-2968,2971-2987`).

## 4. Field placement [O]

Mill fields are **not a generation stage**. Routine `_unit_DoSeedWheat` (`unit.script:6470-6570`, X22): 7×7=49 nodes, step `1.6981` **cells** (=3.3962 m at 2 m/cell), 45° rotation, snap `size2=√2·size=2.401476` with asymmetric `+size / +size*0.5`, half-diagonal ≈7.8 cells; per-node gates: 25-cell `gc_collision_size=0.5` rotated probe rejects on `GetMapCollisionTag>0` or outside `maphalfW/H`; env scan `rad=size*0.9*3=4.58487`, food/wood/stone `allowdst=rad/3=1.52829`, gold/iron/coal `allowdst=rad`; cost gate + 5 gold per node; `WriteNewP/ApplyCostID`. **Sow routine draws no RNG** (X22 X-C1/E16) — port `sow_field` records `rng_draws=0` and stays out of `generate()` (`:773-786`) [O]. Downstream RNG only: decal `Random>0.5→60/45 else 45/225` + `field.prop RandomMeshName` 7-entry seasonal materials (`misc.script:4286-4306`) [O]. Triggers (mill-completion produce→reseed; map-start `cSeedWheat and not bRandomMap`; AI mill loop) are `[*] = ;` text — activation [U]. Port correctly exposes `sow_field` as a mill-trigger hook, never stamps fields in `generate()`.

## 5. Prop (pattern-object) placement [O]

Contents live in `pattern.lib` `Objects[]` (`BaseName/RaceName/Position/Direction/Up/Scaling`; e.g. `mng_1` 11 records incl. `minegold` scale `0.3152`; `d_frt_big_1` 124 trees), **not** in the `.pattern` 24-byte tail (counts 63/2072/323 vs 11/124/34, F08 E11) [O]. Per-record transform order (carried DEC-VIS-02 fnd_44, consistent with `sub_755f30` frame): `translate(C) * rotate_y(PI-rotangle) * scale(ObjectsScale) * translate(record.xz)`, then `y` from `record.y` / `ObjectsHeightOffset` / `ObjAutoOffset` terrain sample; `Direction/Up/Scaling*ObjectsScale` before final `sub_7cca74→sub_4cb27c` submit [D]. Only `0.0/90.0/2.0/0.5/4.0` (+`75.0/2.0` generator scale/divide) are CODE constants to port; `tbyte` extended values (`0x75c198/0x755c5c/…`, raw `21 68 C2 35…`) stay `[U] DONOR_TBYTE_UNVERIFIED` — never hard-code as PI [O].

Gates [O]: `+0x18` (24 B stream) / `+0x82` (16 B) / `+0x38` (13 B) enable streams; `+0x80 & standMaskByte` required-stand gate before any height/object work; stand-mask test per cell; `-halfW<dx<+halfW`, `-halfH<dy<+halfH` + `0<=x<W,0<=y<H` for mask writes; 24/16/13 B streams keep separate pre-transforms (`sub_755bc8/755d1c/755c6c`: `fcomp 0.0 + fadd TBX + fdiv 90.0` + corner-byte permute) and 8-way `sub_59b8a4/59b854` quadrant dispatch with `+0x83`-gated `sub_755578` fixups. **No RNG in the stamp**: 662-callee list contains only converts/trig/stamp helpers, no `RandomExt`/Delphi-`Random`/QPC import; object loops visit every record in order [O] (`ev_4a342…`). Per-instance variation is authored (record bytes via permute/fixups), not rolled [D]. `minangle/maxangle` field offsets and WithAngle `+0x34/+0x38` use stay [U].

## 6. Per-object RNG draw order and stream [O/D]

Single `RandomExt` stream (`s=(s*0xFC0D+0x3C6EF35F) mod 2^32`, f32 out, `0x60f64c`). All 11 `SetRandomKey(randkey1)` + 3 `SetRandomExtKey64(randkey0,randkey1)` sites consume **`randkey1` only**; `key0` discarded mod 2^32 (X21 §4.3, `ev_661ef2e6…`). Port `_stage_begin` routes all through `_rng` (`:857-899`) with idle `_rng_map/_rng_world` diagnostics [O]. Delphi `Random(256)` (`0x403a0c`, slot `0x8f2008`) is a **separate free-running stream** seeded once at process start by `sub_4033b8` (QPC-low else TickCount), never reseeded by generation; it feeds only the `0x8326b8` tile-variant `+4` byte [O/D] (GENSEED §2). Never wire `_stage_begin` to `_rng_delphi`.

Draw order per stage (each `next_f()` in call order; discarded draws still recorded in the ledger):

1. Base tiles (inherits `D3:146`): name roulette draw + damping update per cell; no position draw (grid) [O].
2. `D2:190`: `floor(RandomExt*count)` mask pick **before** `D2:216` on inherited `D1:1538` stream; exact seed [U] (port `_enter_inherited_site` + one `next_int`, `:1081-1086`) [O shape / U seed].
3. Settings: `terraintype` iff out of range (`<91→*6` else `*MaxTypes`); `minesdensity>2 → floor(RandomExt*3)` (1 draw) [O].
4. Starts: `foreststype` 1 draw (forced 0); `v61` branch `floor(RandomExt*(maxind+1))`; scattered `for j:=0..i+8: RandomExt`; **per start** (§3 order): near-mine triple (§3), then starting-resource steps each: name roulette (1 draw) + optional 7-way family draw (`floor(RandomExt*7)`, 1 draw, conifer only) + per-`i` angle (1 draw) + per-`(i,j)` dst (1 draw + `(i+j)*0.5`) (port `:2390-2450`) [O].
5. Relief/global mines: `relieftype` iff `>4` (1 draw); per family (§2.2): name (1 draw per `i`) + 2 draws (`x`, then `y`) per `j` attempt; global `SetupMines(1,0)` per start (§3) [O].
6. Forest/stone: same per-family discipline as (5) with §2.2 fan-out [O].
7. Peasants: 18/player, `(0.5-RandomExt)*0.25` ×2 per peasant (port records counts only; unit work, not terrain) [O].
8. Object-scale jitter (`D1:1990-2021`, midpoint-lerp, 5% dead-band, skip `terrainmesh`/`stones`, winter deletes `leaftree`): **separate object RNG stream [U]** — port keeps `object_scale_rng_hook` NULL/skip (`:3232-3238`), never substitutes `RandomExt` [O shape / U stream].
9. Tile smoothing `FindRandomTileIndex`: `rnd=RandomExt*sumProb`, first `prob>0 ∧ rnd<tmp` (`smoothtiles.inc:63-76`); `sumProb` init [U] (port `0.0` labelled, `:2029-2045`) [O shape / U init].
10. Forest borders: `count=floor(1+RandomExt*16)`, `pind=floor(1+RandomExt*53)`, `grid=3` gate `RandomExt>0.975`, tile `floor(1+RandomExt*3)` [O; no port stage].
11. Variant byte: one Delphi `Random(256)` per accepted `0x8326b8` target; final = last writer [O; generation-time seed U].

## 7. Still-[U] register — each with a fixed-seed zero-mismatch probe

Common harness for every probe below (never invent): pin `t_87f0f3c130b0`; fix `randkey0=0, randkey1=<K>` (primary `K=1`; repeat `K=12345`), `W=H=320` (repeat 256/640 once), `shape=nowater2`, `version=92`, `minesdensity=1`, `spcount=4`, `season=0`, `b_random_map=true`, `foreststype=0`, caller `pattern_modifiers={small:1,mid:1,large:1,huge:1}`, fixed `families/patterns` bundle. Run the port `generate()` twice; diff the named arrays/counts. **Terminate the item only on zero mismatches across the stated repeats; otherwise it stays [U].** No density or draw is invented to force a match.

| ID | Item | Donor [O] | Why [U] | Fixed-seed comparison + termination |
|---|---|---|---|---|
| U-G0 | `G=0` density | `ig=0→cGNone→fdens=0` on every vanilla non-start pixel (X18/X19 census) [O] | closed as zero: no formula exists to verify | Port `forest_density` all-zero on a shipped `_gauss` mask with starts masked; **terminate** when `fdens==0` everywhere off starts on 3 shipped masks, zero mismatches. Never add a `G→count` map. |
| U-S0 | `SmoothTerrain(x,-y,False,3)` kernel | call shape on bsmooth cells [O] (D2:591) | kernel body native, undiscovered high VA | Keep `bsmooth_kernel` NULL/SKIP with telemetry. **Terminate** only on a byte-proven kernel dump reproducing the hook signature; never substitute a blur. Comparison: `bsmooth_pass` telemetry == `SKIPPED` on all fixed seeds. |
| U-MM | `minx/miny` numerics | producer `_misc_GetMapLeftTopPos` [O] (`generatemap.inc:218-228`, `ev_b7759b44…`); literal gate `x>minx∧x<W/2∧y>miny∧y<W/2` (W used for y too) [O] | numeric pair absent from text | Keep `smooth_custom_min_hook` NULL (no gate, never hard-code 0). **Terminate** when logged helper out-args reproduce the in/out gate for every S1/S2 cell with zero mismatches on 320² + 640². |
| U-MOD | `probsmall/mid/large/huge`, `pln_*/swamp_*/lake_*` application | relief base table + `GetFreePatternMaskModifier` + `640/((W+H)/2)` rescale [O] | modifier body engine-side | Keep caller values verbatim with `[U]` label. **Terminate** when logged modifiers recompute `needed=floor(W·H·freq)` trip counts exactly on ≥3 sizes. |
| U-SEED | `GenerateMapRandKey` derivation | consumers `gen.randkey0/1` [O]; RTTI names, 0 xrefs [O] | formula never in readable text | Keep two-word verbatim input. **Terminate** when `key0`-only changes are bit-identical and `key1±1` changes the `D2:190` pick + first three `RandomExt` floats (GENSEED §2.4.2). |
| U-DELPHI | Delphi generation-time state | algorithm `state=(state*0x8088405+1) mod 2^32, out=state>>>24` [O]; image `0`; seeder QPC-else-TickCount, 3 non-generation callers [O] | per-run value wall-clock | Keep image-0 placeholder + NULL hook. **Terminate** on authorised-trace `0x83272f` dump: every byte == `state>>>24`, zero mismatches, restart changes seed (GENSEED §2.4.1). |
| U-VER | `gc_MaxTerrainTypeCount`, shipping `gRecordGeneratorVersion`, `mapsize` enum | `v<91→6` branch [O]; `gDataVersion=92`, `mapsize>2`=256 TINY [O] (V01) | live menu/record values per setup | Dump live settings on authorised host. **Terminate** when dumped integers select the observed branch (6- vs N-way) on both sides of v91 and reproduce the §3 band row. |
| U-MDEN | `minesdensity` runtime + `maxround/rounds` | `rounds=3/4/5`, `>2→1 draw` [O] | live menu input | Vary menu 0/1/2. **Terminate** when ring trip counts =3/4/5 exactly and `>2` consumes exactly one draw. |
| U-HF | per-pattern `HeightFieldScale/Min/Max/Offset/TerrainScale`, `minangle/maxangle`, WithAngle use | field offsets `+0x3a/+0x3b/+0x48/+0x4c/+0x5c/+0x60/+0x64/+0x68/+0x74/+0x78/+0x80-82` [O]; `Max` never read (0/6751) [O] | concretes in `pattern.lib Objects[]`, not exported | Keep caller fields + `STAMP_SMOOTH_PARAMS` census only. **Terminate** when dumped floats reproduce X13 vectors 19/19 on `g_mnt_1/g_hil4`. Never invent floats. |
| U-OBJ | `pattern.lib Objects[]→mesh` index binding | 8-way dispatch + fixup chain structure [O]; mesh names only in data [O] | binding data/engine-side | Keep mesh key opaque. **Terminate** on a per-pattern `Objects[]` export diff (counts/positions/scales) with zero mismatches; until then instancer stays missing by design. |
| U-FA | `fa`/`broad` + road tiles | `fa>0→broad` text [O]; 24-bit census [O] | loader default unobserved | Keep omitted with label. **Terminate** when a donor-loader dump shows `fa==0` everywhere (road branch dead) or a nonzero map (then implement `>0.5/>0.25` branch). |
| U-SUM | `FindRandomTileIndex sumProb` init | selection loop [O] | init word unrecovered | Keep deterministic `0.0` labelled. **Terminate** on a native `sumProb` slot dump; until then never claim equivalence. |
| U-WATER | water plane Y / bridge/waterborder binding, `VectorAngle` convention | `cWaterHeight=-1.1`, `cOffsetY=-0.5`, classify `-0.25/-0.1` [O] | plane Y engine-side | Keep descriptors only. **Terminate** on a `WaterFieldAdd` registration dump (name/tx/tz/bx/bz/-0.5) with zero gaps. |
| U-CLIFF | steep/cliff collision tag value | gates `cDiff1=0.5/cDiff2=0.55` [O] | tag value absent from text | Keep `collision_tag_cliff=null`, record steep cells only. **Terminate** on a named donor steep-tag cite. |
| U-TILE6 | `TileSmoothPasses=6` consumer | script uses 3 [O] (`smoothtiles.inc:237`) | cfg consumer unread | Skirmish follows script 3. **Terminate** on the cfg-key reader call-site address. |
| U-ACT | runtime activation of all `[*] = ;` DScript text | text [O] | execution never traced | No claim; port change list adds labels only. **Terminate** only on an authorised execution trace, never on a tuned visual. |

## 8. Port change list — `terrain_donor_gen.gd` (and one inputs row); no edits made

`P-PLACE-xx` ids are new in this ticket for the applier. All line numbers are 1-based as read.

| ID | Donor rule [O] | Port location | Current behaviour | Required replacement (additive, labelled) |
|---|---|---|---|---|
| P-PLACE-01 | G-enum conditional: `ig=127→cGForest` only if `terrain∈{plateau,hill,ravine}` (`generatemap.inc:473-482`) | `:1171-1178` (`C_GCOLOR_FOREST/2: dens=1` unconditional) | unconditional `127→1` | Gate `127` on already-decoded `terrain∈{1,2,3}`; else leave unchanged. Cite `generatemap.inc:473-482`. |
| P-PLACE-02 | `G` never drives a stamp count; border dress only on `count==1` edge, `grid=3` at 2.5%, `fb_1..53` pine-only | no border stage; `forest_density` side array only (`:1118-1120,1200-1201`) | correct omission, but unlabeled for forests | Add comment on `:1171-1178/:1200-1201`: "`forest_density` is side data; free-stand counts come from §2.2 passes, never from this enum (U-G0)". No logic change. |
| P-PLACE-03 | Desert forest fan-out halves `frs_*` and switches families (`desert_forests_big/medium/small/unique`, `desert_stones`) with `v<77` gate | `:3188-3191` halves rates; `:2399-2406` temperate-only start steps; `:3193-3218` temperate-only globals | desert rates halved but desert families never called | Add desert global calls mirroring the temperate divisors (`/4 /6 /8`, small `/2` desert) behind `b_desert`, plus start-ring `desert_stoneforests (v<77) else desert_forests_big` and `floor(RandomExt*2)` medium choice. Cite `dogenerate.inc:736-940,1780-1785`. Extra draws must be ledgered; never reuse temperate draws. |
| P-PLACE-04 | `CheckStandPattern` fast step-4 pre-scan is a pure reject accelerator; full box upper bound is exclusive (`i=vMinY..vMaxY-1`) | `_test_stand_footprint` (`:2551-2570`, `range(0,mw,step)` exclusive) + `_check_stand` test-then-stamp (`:2573-2598`) | matches [O] | Keep. Add cite `misc.script:3384-3521 (D9:3441)` on `:2552-2554`; no behaviour change. |
| P-PLACE-05 | Stand predicate is exactly `(mask & maskStand) \| (~mask & maskInvStand)` on exposed bytes | `_resolve_stand_mask` (`:2502-2524`) builds it only when both masks present; else nonzero-cell fallback with label | correct fallback, label present | Keep fallback. Add probe ref: terminate fallback removal only on a both-masks-present bundle diff with zero mismatches. |
| P-PLACE-06 | Start probes: `trycount=128 × trycount2=3`, `dst=mindst+R*3+(i+j)*0.5` (stones second ring `+R*2`), per-`i` angle, `round()` coords; `mindst=Min(maskX,maskY)` of the just-stamped/next circle | `:2426-2445` (`C_TRYCOUNT_START=128`, `:724`; `C_TRYCOUNT_INNER=3`, `:725`; `dst` `:2430`; angle `:2428`; round `:2433-2434`) | matches [O] | Keep. Fix comment: second `stones` span is `2.0` (`+R*2` form, D1:880-range) — already `2.0` at `:2405`; add cite `dogenerate.inc:720-947`. No draw change. |
| P-PLACE-07 | Six start placements only (stoneforests×1, stones×1, forest×2, stones×1, forest×1) + `12×15` after stoneforests + `22×18` at end; no food rects; `C3` dead text | `:2399-2406` steps + `:2408-2409` ellipse2 + `:2448` ellipse3 + `:2449-2450` note | matches [O] | Keep. No change except cite `X22 X-C6` alongside the existing note. |
| P-PLACE-08 | Mine per-attempt order: name → conditional dst → angle → rotate → round → test/stamp/break; `continue` rings consume name draws, no angle draw | `:2227-2252` with `_mine_band` conditional draw (`:2263-2269`) | matches [O] incl. missing-`i=2` flag | Keep. Add cite `dogenerate.inc:544-557,704-713` on `:2228/:2240`. |
| P-PLACE-09 | Global mines per start `(1,0)` (`D1:1769-1770`); relief families before them in donor call order | `:3068-3082` relief then `:3087-3093` per-start globals | matches [O] | Keep. No change. |
| P-PLACE-10 | Per-family draw ledger: 1 name + 2 per position attempt; damping only on accept | `:3134-3168` (`name_draws` `:3137`, `position_draws+2` `:3152`, `_damp_freq` only at `:3162`) | matches [O] | Keep. No change. |
| P-PLACE-11 | `SmoothForestBorders` post-pass: `count==1` edge only, `fb_*` + `grass5/rock9`, `rad=1.5`, `1+floor(R*16)`, winter suffix | absent (no stage) | MISSING by design (data pool unverified) | Add a labelled NULL stage stub (telemetry `forest_borders=SKIPPED — fb_*/grass5 pool [U]`) after `_stage_forest_stone`; never synthesise `fb_*` props. Cite `smoothforestborders.inc:30-171`. |
| P-PLACE-12 | Mill fields runtime-only, 49 nodes, `1.6981` cells, 45°, asymmetric snap, 25-cell probe, ore `rad` vs soft `rad/3`, 5 gold, no sow RNG | `sow_field` (`:773-786`) + `field_sowing_hook_info` (`:824-836`) + `generate()` never calls it | matches [O] | Keep. Correct stale `spec/10` food-rect rows by reference (do not edit spec here); add cite `unit.script:6470-6570,1691-1693` on `:773` (already present — keep). |
| P-PLACE-13 | Object-scale jitter is a separate stream [U]; skip `terrainmesh`/`stones`; winter deletes `leaftree` | `:3232-3238` hook-NULL skip with TODO | correct skip | Keep skip. Amend note to name the winter-`leaftree` delete (`D1:1990-2021`) so a future hook implements all three branches together. |
| P-PLACE-14 | No RNG inside `sub_755f30` stamp (662 callees contain no RandomExt/Delphi draw) | `_stamp_pattern` + `_stamp_smooth_post` (`:2601-2914`): no `_active_rng`/`_rng_delphi` calls | matches [O] | Keep. Add one-line guard comment on `:2601`: "no RNG draws in this function (ev_4a342…); record bytes only". |
| P-PLACE-15 | `pattern.lib Objects[]` per-pattern instancing (positions/scales/material keys) | `_record_pattern_stamp` (`:3003-3020`) records name/family/x/y/kind only; compact bundle carries `{w,h,grid,flags,occupancy}` | MISSING (largest fidelity gap, F08 §7.1) | Export per-pattern `Objects[]` from the decoder bundle and add an instancer consuming `pattern_stamps`; never synthesise members. Cite `pattern.lib:713285+` example. Until then keep the current handoff with a `objects_missing` telemetry flag. |
| P-PLACE-16 | `terrain_donor_inputs.gd`: mask pick must be `floor(RandomExt*count)` on the inherited `D1:1538` stream, not a hash | `terrain_donor_inputs.gd` mask-select path (GENSEED §5.2.1; PORT1TO1 §G.6 row 2) | hash draw, labelled PORT APPROXIMATION | Move the draw into the generator (`D2:190`, already at `:1081-1086`); inputs exposes `mask_count` only. Keep `nearest` default, `land→nowater2` alias, conifer gate as-is. |

Explicit non-changes (already [O], do not touch): R/G/B enum values and water `B>=58` boundary (`:165-185`); height formula `h=-1.1·fb·(1+3.5·fr)+class·fr` + `fr&fb` skip (`:1190-1199`); `needed/trycount/mapSizeOptimise` arithmetic (`:3104-3110`); uniform centred draws (`:3150-3154`); mine band matrix + zero-init `dst` + `continue` draw discipline (`:2263-2373`); 7-way conifer draw + family-local roulette (`:2418-2422,2938-2968`); damping `×0.2` floor `0.0001` from authored `Freq` (`:2971-2987`); shore/cliff literal windows + unguarded `bRT` catch-all (`:1852-1941`); smoothing land/coast arithmetic + `mapwidth-1` both-axes anomaly (`:1298-1342`); water-field inclusive bounds + `mapsizemod` float div + four corners + `-0.5` (`:1353-1406`); `0x8326b8` fan-out + Delphi `+4` byte + renderer-chain annotation (`:1413+`, `:574-584,742-756`).

## 9. Bottom line

- Pixel→class decode is fully recovered (§1); on shipped masks it yields `terrain=cRNone`, `forest=cGNone`, `water=(B==255)`, plus white starts — relief amplitude and prop counts never come from R/G on those inputs.
- Forest/tree density is `needed/trycount` + uniform draws + roulette/damping + occupancy reject (§2.2); the `G=0` case is exactly zero mask-driven stamps (U-G0). Mine spacing is ring bands + first-accept (§3); fields are a mill-triggered 49-node sow with no sow RNG (§4); per-instance stamp variation is authored, not rolled (§5).
- Per-object RNG order is name → conditional dst → angle → centred uniform pair, all on the single `RandomExt` stream under the 11+3 reseed ledger; Delphi variant and object-scale jitter are separate streams (§6).
- Every remaining numeric is isolated in §7 with a fixed-seed zero-mismatch probe. No density or draw was invented anywhere in this report.
- The applier owns §8 (`P-PLACE-01..16`); the two functional gaps are the desert family fan-out (P-PLACE-03) and `Objects[]` instancing (P-PLACE-15), plus the `127`-gate correction (P-PLACE-01) and the border-dress stub (P-PLACE-11). Everything else is keep-with-cite.

*End of DEC_U_placement. Files written: this report only. Donor read-only; no binary executed, copied or committed; no code, shader, config, asset, test, git, Godot or investigation-memory state changed. No parity claimed.*
