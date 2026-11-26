# DEC_LANDSCAPE_item_placement — donor item placement order and gates

Target: pinned `t_87f0f3c130b0` (`cossacks.exe`, sha256 `87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c`).
Mode: DEEP, donor READ-ONLY. No code/Godot/git/donor-binary execution. No parity claim.
Scope: exactly one repo file written (this report). Prior docs re-read first (D07/F08/F07/X22/VIDEO_BUILDER_STANDS/DEC_DEEP_placement_755f30); native helpers + callers re-observed this pass (max 5 passes).

Labels: [O]=observed donor byte/line/VA this session or carried verbatim prior [O] with citation; [D]=deterministic arithmetic/inference over [O]; [U]=UNVERIFIED. PORT APPROXIMATION=port substitute, not donor-verified.

---

## 0. Executive answer

1. [O] Donor order is: clear `gPatternMask` (640 fixed) → `SetupTiledPatterns` → water/shore pre-mark (`height < -0.1`) → per-start `CreateStartPoint` (ellipse 5x7 + `SetupMines(0,1)` + `SetupStartingResources`) → relief patterns → global `SetupMines(1,0)` → global `SetupPatternsByType` forest/stone/swamp/lake/plain → peasants → scale-fix → `FillOwnerMap` + borders + shore collision (D07 §3.10; `ev_a33507f9…`, `ev_7733cb43…`, `ev_5200df4f…`).
2. [O] `SetupMines` gates are ring → ore → 256 angle attempts. Bands `14/32/70/22` are **ring radii shared by gold/iron/coal**, not per-ore radii. Current large-map band (`v>=80`, `mapsize>2`): `14+8R / 32+10R / 70+12R / 22+16R`, ring 4 skipped (D07 §3.2–3.3).
3. [O] `SetupStartingResources` gates are 128 outer tries x 3 radial steps, 6 placements (stoneforests x1 → stones x1 → forest x2 → stones x1 → forest x1), with three nested keep-clear ellipses 5x7 (before mines), 12x15 (after stoneforests), 22x18 (end), all at `(x, z+2)`. No food/field rects (D07 §3.6; X22 X-C6).
4. [O] `SetupPatternsByType` gate is roulette `Freq` pick + `Freq*=0.2` damping, `needed=floor(W*H*freq)`, `trycount=floor(256*mapsizeoptimise)`, uniform `(x,y)` draw, accept-first-pass via `_misc_CheckStandPatternExt` (F08 §4; native driver `sub_723748` §3 below).
5. [O] `_misc_CheckStandPattern(Ext)` tests **only** `gPatternMask` occupancy + map bounds (fast step-4 then full box); water/rock semantics enter earlier via pre-mark, not inside the checker (D07 §3.7; native `sub_755168/764e04/7550f8/75505c`, `+0x80` gate §4).
6. [O] Relief stamps go through the same `sub_755f30` frame (rotate → `/2.0` → `+0.5` → centre); height lattice is `(W-1)x(H-1)` + blocked last row/col, Smooth is boundary-only with divisor 4.0; `terrainmeshN` silhouettes are props, ground integration is zero-stamp + Smooth (DEC_DEEP_placement §§2–5,7; fnd_51–54).
7. [O] Mill fields are **not** a pattern stage. `_unit_DoSeedWheat` sows 7x7=49 nodes, step 1.6981 cells rotated 45°, snap `size2=√2·size` with +size / +size*0.5 asymmetry, 25-cell collision probe + food/wood/stone `rad/3` / ore `rad` clearance, 5 gold each. Sow routine draws **no RNG**; RNG is downstream decal 45/225 + prop mesh/material pick (X22 §3–4).
8. [O] Donor builder stands are **outside** the footprint (arc / 1–2 sides, ~1 width out, 1 typical / ~4–5 max observed); never under scaffold. Port `game.gd:_work_slot` can order centre when both ring points test blocked (VIDEO_BUILDER_STANDS §1–2). Donor mine-build snap is nearest deposit within 1.5 map cells (F08 §5 step 6).

---

## 1. Pass log (5 passes max)

| Pass | Instrument | Result |
|---|---|---|
| P1 | re-read D07, F08, F07, X22, VIDEO_BUILDER_STANDS, DEC_DEEP_placement_755f30 | starting points + carried [O] tabled below |
| P2 | `native_function_show` `sub_755f30` (234 blocks/6751 insn/662 callees/5 callers) + `sub_723748` (101 blocks/624 insn/2 callers) + `native_bytes_find` `CheckStandPattern/mng_1/stoneforests` (0 hits in exe) | confirms placement constants live in data, not CODE; stamp frame + driver shape re-observed |
| P3 | `native_api_show` `sub_755f30` (full 662-callee list: only `4a6a5c/4a6aa0` converts, `403404/40342c` cos/sin, `755bc8/755664/755d1c/755920/755c6c/755010/75505c/7550f8/755db4` stamp helpers; no RandomExt/Delphi-Random import) + `sub_723748` (48 internal calls incl. `755f30` x2, `75c228` x2, `722b48`, `72344c`, `7226c8/7227ec`, `7231b8/7233b8`, `728200/7281bc/730944`) | no-RNG-in-stamp re-confirmed; `+0x41` fork (`75c228` vs `755f30`) re-confirmed |
| P4 | `native_function_pseudocode` `sub_723748` (Ghidra `FUN_00723748`): `+0x44/0x48` vs `+0x4c/0x50` bounds loop, `722b48` double-test, `72344c` rect test, `71e200` height sample, `7231b8/7226c8/7227ec` gates, `7233b8` stamp, `+0x41` branch to `75c228`/`755f30` | driver gate order recovered structurally; field offsets stay opaque |
| P5 | cross-check relief/smooth constants + builder/mine anchors against prior ev | close-out; no new execution, report written |

Acceptance: [O] only for bytes/lines/VAs read (this pass or cited prior ev); [D] for arithmetic over them; everything else [U].

---

## 2. SetupMines — rings, not ores [O/D]

- [O] Skeleton (`dogenerate.inc:522-717`, `ev_a33507f9…`, D07 §3.2): `rounds=3/4/5` for density 0/1/2, clamp `maxround`; `for i:=minround..rounds-1` (ring) → `for j:=0..2` (`mng/mni/mnc`, `desert_` prefix on desert) → `for k:=0..255` angle attempts: `RandomExt*360`, `VectorRotateY`, `CheckStandPatternExt(...,True,...)`, on success `PatternIncreaseFreq` + break. Upper bound [D]: `256 x 3 ores x (rounds-minround)` per start call.
- [O] Bands are per-ring (`:559-701`, D07 §3.3). Current large map (`v>=80`, `mapsize>2`, `:595-601`): ring0 `14+8R`, ring1 `32+10R`, ring2 `70+12R`, ring3 `22+16R`, ring4 skipped. `R=RandomExt`. Units are map cells (`gc_meters_to_tile=2` → band0 = 28–44 m) [D].
- [O] Anomaly (multi-pass accepted, `ev_a33507f9…`, D07 §3.3): small-map `spcount<=4` bands (`:617-625`, `:630-636`, `:639-645`) label `0,1,3,4(,5:continue)` — ring 2 has **no assignment**, inherits stale `dst` (uninitialised on first attempt). [U] VM zero-init semantics.
- [O] Far-ring relocation (`:658-697`): `i=2, spcount<=4, mapsize>2, v>=90` snaps centre to quadrant corner `±(maphW-24), ±(maphH-24)` (e.g. 160-cell half-map → ±136); wrong-position logs `SetupMines wrong position` and falls back.
- [O] Weighting (`generator.cfg:69-204`, `misc.script:3568-3653/3588-3632`, F08 E2/E7): families `mng/mni/mnc` = 5 live members `Freq=1` + legacy `*_4` `Freq=0`; pick `freqrnd=RandomExt*FreqSum`, first `freqrnd<Freq`; on success `newfreq=max(old*0.2,0.0001)` + `UsedCount/TotalCount/FreqSum` update. Missing `Freq` defaults to 1.
- [O] Native anchor (this pass P2): 0 hits for `CheckStandPattern/mng_1/stoneforests` in `cossacks.exe` bytes; `XMapGenerator` (17 hits from `0x71c0a5`) / `XCastleGenerator` (19 hits from `0x72835c`) are CODE-embedded ASCII (`0x58='X'` misread as `pop eax`), `sub_71c0b4` has 0 direct callers / 30 address-taken (registration thunk, not placement loop) — `ev_43fb1f88…`, `ev_7f22818c…`, `ev_f4a62967…`, `ev_85467957…`. So [D] ring/band truth lives in DScript + cfg, not in a recovered native `SetupMines`.
- [D] Near call uses `(minround=0,maxround=1)` (1 ring), global call `(1,0)` → `1..rounds-1` (2/3/4 rings) (`:985`, `:1769-1770`).

## 3. SetupStartingResources — ellipses + 128x3 probes [O/D]

- [O] Counts/radii (`dogenerate.inc:720-947`, `ev_7733cb43…`, `ev_5200df4f…`, D07 §3.6): `trycount=128`, `trycount2=3`; `mindst=Min(cCircle1MaskX,cCircle1MaskY)=Min(5,7)=5`; probe `dst:=mindst+RandomExt*3+(i+j)*0.5`, `angle:=RandomExt*360`, `VectorRotateY`, `CheckStandPatternExt(...,True,...)` + `IncreaseFreq` + `break(MAIN)` on first success. Max reach [D]: pass1 `5+3+127.5=135.5`, passes2–3 `142.5`, passes4–5 `145.5` cells; typical accept near inner bound.
- [O] Order: (1) `stoneforests` x1 (`desert_stoneforests` if desert `v<77` else `desert_forests_big`) `mindst=5`; — stamp `cCircle2` 12x15 at `(x,z+2)` (`:769`); (2) `stones` x1 `mindst=12`; (3) forest x2 `mindst=12` (7-way `floor(RandomExt*7)` choice among pinefir_medium/spruce_medium/pine_medium/pinefir_big/spruce_big/pine_big/pine_big_2 when `foreststype=0`); (4) `stones` x1 `mindst=16`; (5) forest x1 `mindst=16`; — stamp `cCircle3` 22x18 at `(x,z+2)` (`:947`). Constants `cCircle1/2/3 = 5x7 / 12x15 / 22x18` (`:407-415`). `CreateStartPoint` pre-stamps `cCircle1` at `(x,z+2)` before `SetupMines(0,1)` + `SetupStartingResources` (`:980-988`).
- [O] `foreststype:=floor(RandomExt*3)` then hard `foreststype:=0` (`:5-6`, F08 E6) — shipped text runs **conifer only**; leaf/mixed branches dead.
- [O] No food rects: zero `field/food/SeedWheat/gc_basename_field` hits in `:720-980` scan (X22 X-E20/X-C6); only player-stock adds (`:261-289`). D07/F07/X22 agree.
- [O] Stone families are tree+weed+rock clumps, not bare rock: `stoneforests=str_new_1..8` (38–60 objs), `stones=d_stn_1..7` (13–41 objs) (F08 §3.2; `generator.cfg:802-908`).

## 4. SetupPatternsByType — freq / trycount / uniform draw [O/D/U]

- [O] Script rule (`misc.script:3681-3729`, F08 E3 + D07 §3.7): `needed:=floor(mapW*mapH*freq)` (`neededround` round-up to 1 if `freq>0`), `trycount:=floor(256*mapsizeoptimise)`, `mapsizeoptimise:=(320*320)/(W*H)` (x0.65 if <1). [D] At 320x320 with modifiers ≡1: big-conifer 11/family x4=44, mid 15x3=45, small 13x2=26, stones 16+12=28 (rates `frs_big/mid/small=0.0009/0.0009/0.00054`, `stn1/2=0.00016/0.00012`, `dcr=0.0005` at `dogenerate.inc:1688-1693`). Desert halves `frs_*` (`:1780-1785`).
- [O] Per-stamp: roulette member pick (§2 weighting) then up to `trycount` uniform `(x,y)` attempts until `CheckStandPatternExt` passes; on success damp member `Freq x0.2` (`:3706-3727`).
- [O/D] Native driver `sub_723748` (this pass P2–P4): 624 insn, 48 callees, 2 callers; pseudocode `FUN_00723748` shows (a) `+0x44/0x48` vs `+0x4c/0x50` needed/placed bounds loop with `%`/`/` shard scan, (b) double `FUN_00722b48` gate (called twice per candidate — test then re-test), (c) `FUN_0072344c` rect gate, `FUN_0071e200` height sample, `FUN_007231b8/7226c8/7227ec` mask/height gates, `FUN_007233b8` post-stamp, (d) `+0x41==0 → FUN_0075c228` (thin wrapper `sub_75c228`: `755f30(0x42b40000=90.0f,0,...)`) else `FUN_00755f30(*(+0x38),*(+0x34),...)` — the `StandPattern` vs `StandPatternWithAngle` fork (structure [D]; DScript names carried, not in CODE strings [U] — 0 hits §2).
- [U] Exact register mapping of `needed/trycount/FreqSum` and `728200/7281bc/730944` (uniform draw vs per-object RNG vs name-resolve) was not isolated in this 5-pass budget. Do not hard-code: `728200`/`7281bc` are candidates for the uniform draw / RNG stream (cf. D02 fnd_19–21: global LCG at `0x60f64c` + per-object instances like `0x7281bc`), `730944` for pattern-list resolve. Port must keep script `needed/trycount` arithmetic and treat native offsets as opaque.
- [O] Free-mask modifiers denominators 340/182/74/29 + size modifier `640/((W+H)/2)` (`misc.script:3931-3941`, `dogenerate.inc:1718-1725`); engine mask counts [U]. Two `SetRandomKey(randkey1)` resets bracket relief+mines (`:1772`) and forest/stone (`:1909`→`:1927` units) — separate seeded streams, not one continuous RNG (D07 §3.10; F08 §4 step 7).

## 5. CheckStand — mask-only + pre-mark [O]

- [O] Checker (`misc.script:3384-3521`, `ev_71484fdd…`/`ev_32fd9062…`): `doStand=true` places via `StandPatternWithAngle` (+ optional record-manager log); mask box `vMin..vMax`, centre `cx,cy`; `maskStand=GetPatternMaskStand`, `maskInvStand=GetPatternMaskInvStand`; fast path (`not doStand`, `angle=0`): step 4, reject if `(mask & stand) or (~mask & invstand)` and (out-of-map or `gPatternMask` set); full path same predicate over whole box (test) or test+stamp (`doStand=true`). `Ext` = test (`false`) then stamp (`true`); all D07 call sites pass `angle=0` so rotated branch is present but unused.
- [O] Native mask primitives re-observed (DEC_DEEP_placement §4 + this pass P3): `sub_755168` (stamp: `+0xa0=W,+0xa4=H,+0xa8=row-table` → `sub_764e04`: `0<=x<W,0<=y<H` → write), `sub_7550f8` (pure bounds: `-halfW<dx<+halfW` + `-halfH<dy<+halfH`), `sub_75505c` (test+stamp + `+0x65` auto/collide flag + `+0x1c` occupant slot + `sub_7d9694` link), `+0x80 & maskByte` required-stand gate before height/objects. Bounds [D]: out-of-range cells silently skipped, no wrap/clamp.
- [O] Water/shore enters **before** the checker: height `< -0.1` (not yet occupied) → occupied (`dogenerate.inc:1557-1564`); `generatemap.inc:811-850` pre-marks `gPatternMask` True where `gMapMask.b<>cBNone` or broad/bsmooth or `GetMapCollisionTag>0` (carried fnd_65: `ev_9cf7258c…`); shore collision discs radius `gc_WaterBorderSize=3`, tags water=87/waterborder=110/landborder=109/bridge=10/none=0, `_misc_SetShoresCollision*` 3x3 rule (carried fnd_66–68: `ev_0f1c667f…`, `ev_d6dd2aad…`, `ev_ec4090c9…`).
- [O] New pre-mark evidence (carried fnd_72): `CheckStandPattern` has no water/collision/topology test inside — fast step-4 + full box test `gPatternMask` + bounds only (`ev_926b544d…`). So [D] "rejects water/rock" is emergent from pre-mark + earlier stamps + three start ellipses, not a semantic branch. Global `SetupPatternsByType` uniform draws therefore land on whatever the mask already forbids.

## 6. Relief stamps + terrainmesh [O/D]

- [O] Same stamp frame (`sub_755f30`, `ev_ed57855c…` dossier + `ev_139fa697…`/`ev_db687a…` pseudocode): `rotangle=[ebp+0x10]`; normal centre `C=([ebp+0x18]+[+0x74],[ebp+0x14]+[+0x78])`; half-extents `(W-1)>>1,(H-1)>>1` (arithmetic-shift negative correction); rotate cell offset (`cos=sub_403404`, `sin=sub_40342c`) → `/2.0` (`0x75c1a4`, 252 xrefs) → `+0.5` (`0x75c1a8`) → add `C`. Editor `sub_8c5b78` is structural mirror (relocated tables only).
- [O] Record streams: `+0x2c` 24 B (`rep movsd ecx=6`), `+0x30` 16 B (4x`movsd`), `+0x34` 13 B (3x`movsd`+`movsb`) with separate pre-transforms `755bc8 / 755d1c / 755c6c` (`fcomp 0.0` + `fadd tbyte` + `fdiv 90.0`: `0x755c58/68`, `0x755da0/db0`, `0x755d08/5d18`; `ev_1b2e925c…`, `ev_dc6a24…`, `ev_09c56e…`). Per-record `+0x18/+0x82/+0x38` gates; 24 B path tests stand-mask byte then `755bc8` normalize (corner-byte permute) → `755664` 8-way `59b8a4` quadrant dispatch (+`+0x83`-gated `755578` corner fixups) → `7cca74→4cb27c` submit trampoline.
- [O] Height gate + smooth (carried fnd_51–54): `sub_75ca34` reads only `(W-1)x(H-1)` mask bytes, copies top-left, blocks final row/col; Smooth (`sub_755db4`) is boundary post-pass (clear-outer or clear-touching-blocked only, right tested twice / left omitted, radial Z x0.4, `Factor` in-place repeats, 4-neighbour `/4.0` at `0x755ee4`); `g_mnt_1..7` use `ReplaceForWater=true`, zero/small grids, `Smooth=true, Radius=3, Factor=4, Offset=2` — zero interior + boundary Smooth is the donor mesa integration, props are the silhouette.
- [O] Pinned CODE constants to port (only these): `0.0 / 90.0 / 2.0 / 0.5 / 4.0` (§5 table in DEC_DEEP_placement) + `75.0` (`0x723e34` generator outer-loop scale) + `2.0` (`0x723e44`); `tbyte` extended constants (`0x75c198/755c5c/…`, raw `21 68 C2 35…`) are [U] — never hard-code as PI.
- [O] No RNG in stamp: 662-callee list has no `RandomExt`/Delphi-`Random`/QPC seed import (this pass P3); object double-loops visit every record in order with no draw counter — per-instance variation is authored (record bytes via `755bc8` permute + `755578` fixups), not rolled [D]. WithAngle extra args (`+0x34/+0x38`) use as `minangle/maxangle` vs base yaw is [U].
- [O] Forest/stone/mineral object contents live in `pattern.lib` `Objects` arrays (not the `.pattern` 24-byte tail: `mng_1` 8x10 cells = 63 tail records vs 11 Objects; `d_frt_big_1` 2072 vs 124; `d_stn_1` 323 vs 34 — F08 E11), each with `RaceName/BaseName/Position/Direction/Up/Scaling` (e.g. `mng_1` `lib:713323-713633`, ore at centre scale `0.3152`; `d_frt_big_1` 124 trees; F08 §§3–4). Ore scale fixed `0.3152` no jitter; stones `0.25–0.4` ±15% (`envscales.cfg:15-109`).

## 7. Mill field sowing — building effect, not pattern [O/D]

- [O] Routine `_unit_DoSeedWheat(goHnd,bAuto)` at `unit.script:6470-6570` (X22 X-E01, verbatim §3.1): `ROW=7, COUNT=49, SIZE=1.6981` cells (commented `1.5`/`PixelsToTiles(80)` alternatives dead), `cScale/cRollAngle` dead (X-C3), `roll` declared never assigned then written to `fdirx` — **not RNG** (X-C1); `bCollision/bStaticObjects` never init-false — explicit `false` required (X-C2); `bAuto` inert (X-C4).
- [O] Lattice: `dirX=-((6.5*size)/2)+(i%7)*size`, same Z with `i/7`, `VectorRotateY(...,45)`; snap `size2=√(2·size²)=2.401476`, `px=floor((px+size)/size2)*size2`, `pz=floor((pz+size*0.5)/size2)*size2` (asymmetric +size / +size*0.5); extent pre-rotation `-5.518825…+4.669775`, rotated corners `(-7.804797,0),(6.604059,0),(-0.600369,±7.204428)` — half-diagonal ~7.8 cells ≈15.61 m, not a radius [D] (X22 §4).
- [O] Gates per node: 5x5 `gc_collision_size=0.5` rotated probe (25 samples, ±1 cell) rejects on `GetMapCollisionTag>0` or outside `maphalfW/H`; env scan `rad=size*0.9*3=4.58487`, food/wood/stone `allowdst=rad/3=1.52829`, gold/iron/coal `allowdst=rad` (`VectorDistance<allowdst` rejects); cost gate `CanApplyCostByID` + `GetCountOfPlayers>=gc_playerind_env`, writes `fposx/fposz/fdirx/fracename/fbasename/fplayer` via `WriteNewP` then `ApplyCostByID` (5 gold, `unit.script:1691-1693`).
- [O] Triggers (all `[*] = ;` text → activation [U]): mill-completion `OrderProduce(field,1)` (`ontagstates.inc:140-145`) → field-order completion `DoSeedWheat(myHnd,False)` (`doprogressorders.inc:130-135`) → map-start `cSeedWheat and not bRandomMap` every built alive mill (`generatemap.inc:1009-1025`) → AI `aidata.milllist` loop `True` (`progresseconomicai.inc:3688-3697`). Human chain is two-step (produce order → reseed); direct on-finished hook is PORT APPROXIMATION.
- [O] Downstream RNG only: `writenewp/readnewp` `if (random>0.5) PlaceFieldDecal(gohnd,60,45) else 45+180` (angle pick); `field.prop:33` `RandomMeshName=True` + `49-76` 7-entry summer/winter material lists, `UseSeasonMaterial=True`, `DefaultScale=0.03605085`, `DefaultRollAngle=45`; decal `envfieldd` 2x2, `w=h=60*goScale*1.3`, `texscale*=1.3`, `texOff=-0.15` (`misc.script:4286-4306`; X22 X-E16–19). `CLEAR_SOFT=1.52829 < SIZE=1.6981` so siblings survive — no field-vs-field exclusion [D].
- [O] No field/mill pattern family: 710 `.pattern` scan = field 0 / mil 0 / frt 248 / pump 15; `pattern.lib` `BaseName=field/mil` 0 (F07 E1/E15; X22 X-E20).

## 8. Building stands [O/D]

- [O] Donor (VIDEO_BUILDER_STANDS §1, 8 frames): peasants work from **outside** the unfinished footprint, never inside/under scaffold; arc / 2+ sides when crew>1 (V1-060 ~5 on blacksmith paving front+east), single side ~1 width out when 1 worker (V1-120/V2-300/V2-600/V2-900); counts 1 typical (tower/mine), ~4 mine rim, ~5 max observed; wall/gate stands unsampled (VB-U4).
- [O] Port defect (`game.gd:5195-5205/5480-5514`): `_work_slot` golden-angle hash (`id*2.399963 + center*0.13/0.07`, `(id%3)*0.35` stagger, `block_r+0.7`) tests only `is_blocked` (terrain grid), not `_blocked_for` building `block_rect`; fallback `return center` walks the peasant into the site when both ring points test blocked. Deterministic hash must be kept (seed stability); fix is game-only (see §9).
- [O] Donor mine-build snap (F08 §5 step 6; `dmscript.global:206`, `unit.script:6629-6672`, GUI callers commented [U]): nearest gold/iron/coal deposit within **1.5 map cells**, move building to deposit centre; else invalid.

## 9. Concrete gen/props recommendations (PORT APPROXIMATION unless noted)

1. **Rings, not ores.** Implement `for i in [minround,rounds-1]: for ore in {gold,iron,coal}: draw dst from ring band table (§2, version/size-gated verbatim incl. small-map missing-`i=2` quirk documented, not silently repaired) → `angle=R*360` → rotate → test/stamp; near `(0,1)`, global `(1,0)`; damping `Freq*=0.2` floor `0.0001`.
2. **Ellipses + probes.** One occupancy mask (`gPatternMask`, fixed 640); pre-mark water (`h<-0.1`), broad/bsmooth, collision>0; stamp `5x7` before near mines, `12x15` after stoneforests, `22x18` at end, all at `(x,z+2)`; `trycount=128`, `trycount2=3`, `dst=mindst+R*3+(i+j)*0.5`; first-accept wins else place nothing. No food rects.
3. **Global passes.** `needed=floor(W*H*freq)`, `trycount=floor(256*mapsizeoptimise)` (`optimise=(320²)/(W*H)`, x0.65 if <1); roulette pick → up to `trycount` uniform `(x,y)` attempts via `CheckStandPatternExt`; reset RNG at each `SetRandomKey(randkey1)` boundary (D02 LCG `s=(s*0xFC0D+0x3C6EF35F) mod 2³²`, output `f32(s/2³²)` — keep separate streams, never add draws inside stamp).
4. **Checker.** Two-phase (test `doStand=false` incl. step-4 fast path, then stamp `true`); predicate only `(mask&stand)|(~mask&invstand)` + bounds; `angle=0` path. Native bounds `-halfW<dx<+halfW`, `-halfH<dy<+halfH`, `0<=x<W` for mask writes.
5. **Stamp frame.** `C=origin+offset74/78` (normal branch), `(W-1)>>1,(H-1)>>1`, `rotate(cos/sin rotangle) → /2.0 → +0.5 → +C`; keep 24/16/13 B streams separate (`755bc8/755d1c/755c6c`); port only `0.0/90.0/2.0/0.5/4.0` (+`75.0/2.0` generator scale/divide); leave `tbyte` as `DONOR_TBYTE_UNVERIFIED`; `minangle<=0 & maxangle>=90 → accept`, else accept-all + warning until fields typed.
6. **Relief.** Expand `(W-1)x(H-1)` vertex-mask lattice (block last row/col), `ReplaceForWater` zero-interior allowed, then boundary-only Smooth (`Radius=3, Factor=4`, radial Z x0.4, `/4.0`); do not stamp full `WxH` rectangles; `terrainmeshN` props carry silhouette (one MultiMesh per prop mesh, not per-corner submits).
7. **Objects.** Export `pattern.lib` `Objects[]={base,race,x,y,z,dir,up,scale}` per pattern (numbers only) and instantiate with converted meshes (pines/spruce/oak/stones already present; `minegolds/desert` verify before wiring); season = material swap (all 680 sections `Summer=True`), not separate patterns; shipped text = conifer-only (`foreststype=0`) — gate leaf/mixed behind explicit option.
8. **Mill fields.** Separate runtime stage after mill instantiated (not pattern pass): 49 candidates, `step=1.6981` cells (=3.3962 m at 2 m/cell — fix port half-scale `1.6981 m`), 45° lattice + asymmetric snap, 25-cell probe + `3.0566 m` soft / `9.1697 m` ore clearance, 5 gold each, 45° prop + 45/225 decal (`texscalefix=1.3`, `texOff=-0.15`); init booleans `false`, no per-node RNG, two-step produce→reseed trigger labelled PORT APPROXIMATION; correct stale `spec/10:50,53` food-rect rows per X-C6.
9. **Builder stands (game-only).** Keep primary hash + `block_r+0.7`; test candidates with `_blocked_for` (rect-aware), not `is_blocked`; delete `return center` → bounded 16-angle x `rr,rr+1,rr+2…` outward scan from builder's hash angle, last resort stay-in-place; keep `MAX_BUILDERS_SENT` etc. unchanged.

## 10. Claim register

| # | Claim | Label |
|---|---|---|
| 1 | Order §0(1) (mask→tiles→pre-mark→starts→relief→global mines→global patterns→peasants→FillOwnerMap) | [O] D07 §3.10 |
| 2 | Rings §2 (round→ore→256, shared bands, current 14/32/70/22) | [O] `ev_a33507f9…` |
| 3 | Small-map missing-`i=2` anomaly | [O] quirk / [U] runtime effect |
| 4 | Ellipses/probes/counts §3, no food rects | [O] `ev_7733cb43…`/`ev_5200df4f…`, X-E20 |
| 5 | `needed/trycount`/roulette/damping §4 + native `723748` fork/gates | [O] script + VAs / [U] register mapping |
| 6 | Mask-only checker + pre-mark §5 | [O] `ev_71484fdd…`/`ev_32fd9062…`/`ev_926b544d…`/`ev_9cf7258c…` + VAs `755168/764e04/7550f8/75505c/+0x80` |
| 7 | Stamp frame/constants/no-RNG §6 | [O] `ev_ed57855c…`/`ev_139fa…`/`ev_db687a…` + `0.0/90.0/2.0/0.5/4.0` |
| 8 | Field sowing §7 (49/1.6981/45°/clearances/5g, no RNG in sow) | [O] X-E01–E20 |
| 9 | Builder stands §8 (outside, arc; port centre-fallback defect; 1.5-cell mine snap) | [O] video frames + `game.gd` lines |
| 10 | All §9 items are PORT APPROXIMATION; no parity | [U] |

## 11. UNVERIFIED / open

- [U] Retail activation of every `[*] = ;` DScript caller (SetupMines/Resources/Patterns/DoSeedWheat/decal).
- [U] `gRecordGeneratorVersion` in shipped games (70–82 vs 50–62 vs 88–106); `mapsize>2 // tiny` enum mapping; `dst` zero-vs-stale on small-map ring 2.
- [U] `gc_meters_to_tile=2` engine consumption (metres-per-cell [D] from `:170/:172` ratio, use [U]); decal `w/h` unit; `tbyte` PI-family values; 24 B field map / 13 B tag semantics beyond §6; `+0x34/+0x38` WithAngle use; LOD `0..150/2500`; Delphi-variant (`0x8f2008`) vs `RandomExt` (`0x60f64c`) draw assignment in `723748`.
- [U] Sibling-field registration timing, 49-survival on shipped maps, per-node `field1..4` choice, any binary-only growth machine (DEC-VIS-03 87.5 s machine vs F07/X22 no-stage text — unresolved here), DLC additions, visual parity (no donor A/B frame).

*End of DEC_LANDSCAPE_item_placement. One report written; donor READ-ONLY; no parity claim.*
