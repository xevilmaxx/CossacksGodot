---
id: HEIGHT-GEN-DEEP-01
title: "Donor height-field generation — exhaustive re-read of generatemap.inc, exact class×R formula, .map float32 layout, runtime writer analysis, port mismatches"
agent: HEIGHT-GEN-DEEP-01 (donor deep-dive worker, coord swarm 2026-11-25)
date: 2026-11-25
status: DONE — 3 independent passes (full text re-read / independent .map byte decode / formula↔grid correspondence); read-only donor; no donor run or copy; no repo code edit; no runner job
output: docs/coord_swarm_2026-11-25/reports/HEIGHT_GEN_DEEP_01.md
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
donor: "C:\\Games\\Cossacks 3 (READ-ONLY; Python bytes + latin-1 + struct, never executed/copied)"
labels: [observed, derived, inferred, UNVERIFIED]
parity_guard: "No donor GPU frame exists; no donor parity claim is made. Port facts are comparisons only."
verdict: "DONOR HEIGHT FORMULA RECOVERED VERBATIM — NO NOISE/FREQUENCY IN THE HEIGHT WRITE; R-CODE AMPLITUDES IN PRIOR DOCS WERE OVERSTATED FOR HILL/RAVINE (commented-out multipliers); .map GRIDS INDEPENDENTLY RE-DECODED; FINAL CLAMP STILL UNVERIFIED"
scope: "One new file only. No source/asset/config/test/shader/git edit. No donor file run or copied. Temp Python scripts live under %LOCALAPPDATA%\\Temp\\opencode only."
---

# HEIGHT-GEN-DEEP-01 — donor height generation, full documentation

> **Evidence discipline.** **observed** = literal donor line, decoded byte/header, or direct
> read-only measurement with a stated `path:line` / offset. **derived** = arithmetic or
> control-flow consequence of observed facts. **inferred** = best reading with an explicit
> caveat. **UNVERIFIED** = not provable from the files read; do not promote. Donor is truth;
> the port is only compared, never treated as evidence of donor behaviour. **No parity claim.**

---

## 0. Sources

### 0.1 Donor — re-read fresh, read-only, in full (pass 1)

| # | Path | Size / lines | Role |
|---|---|---:|---|
| D1 | `C:\Games\Cossacks 3\data\scripts\common.inc\generatemap.inc` | 51,794 B / 1,059 lines | **Read in FULL this pass** (lines 1–1059). Height constants, R-code decode, bitmap→height formula, smoothing, water fields, editor-only tail. |
| D1b | `C:\Games\Cossacks 3\scripts\editor.inc\generatemap.inc` | 222 B / 9 lines | Thin stub: `BoolRegister0 := False; StringRegister0 := ''; MapExecuteState('DoGenerateMissionMap')` (`:4-6`). Not a height implementation. |
| D2 | `C:\Games\Cossacks 3\data\scripts\common.inc\postprocess.inc` | relevant `:63-73`, `:132-133`, `:349-441` | Bitmap noise/Gaussian; editor-only (guard at D1:507-517). |
| D3 | `C:\Games\Cossacks 3\data\scripts\common.inc\dogenerate.inc` | `:465-479` re-read; stage-9 relief from cited prior reports | Editor reset block (`:467-478` commented); relief family stamps (prior reports). |
| D4 | `C:\Games\Cossacks 3\data\scripts\lib\miscext.script` | `:1503-1520` | The only **other** plaintext `SetHeightData` writer found (editor "modify height" helper, gated `bModifyHeight`). |
| D5 | `C:\Games\Cossacks 3\cossacks.exe` | 5,768,048 B | Read-only byte-name census (pass 3) to classify native entry points. |
| D6 | `C:\Games\Cossacks 3\data\maps\missions\{bonmis1,engmis4,battle1}.map` | read-only | Independent height-grid decode (pass 2). |

### 0.2 Project documents read (context, not new donor evidence)

`docs/coord_swarm_2026-11-24/reports/DEEPDEC_02_terrain_render.md` (full),
`docs/coord_swarm_2026-11-24/reports/G31_donor_3d_truth.md` (full),
`docs/coord_swarm_2026-11-24/reports/DEEPDEC_05_map_serialization.md` (full),
`docs/coord_swarm_2026-11-24/reports/DEEPDEC_05_map_serialization.md` §2.1/§6,
`docs/decomp/DC_FORMATS.md` (full),
`docs/audit/TERRAIN_DONOR_PIPELINE.md` (full),
`docs/audit/TERRAIN_DONOR_PATTERNS.md` (full),
`docs/coord_swarm_2026-11-25/reports/DTRN_02_donor_terrain_geometry.md` (full),
`docs/coord_swarm_2026-11-25/reports/DPATTERN_01_relief_grids.md` (full),
`docs/coord_swarm_2026-11-25/reports/RELIEF_VISUAL_01.md` (full),
`docs/coord_swarm_2026-11-25/reports/RELIEF_LIVE_DIAG_01.md` (full).

### 0.3 Port — read-only comparison

`variant3d/scripts/mapgen.gd` (full, 211 lines), `variant3d/scripts/game.gd`
(`:40-84`, `:855-1144`), `variant3d/scripts/main.gd` (`:780-809`),
`variant3d/tools/import_donor_map.py` (full),
`app/scripts/mapgen.gd:63-73`, `app/scripts/game.gd:858-993,1095-1097` (older duplicates).

### 0.4 Verification passes

| Pass | What | Result |
|---|---|---|
| V1 | Full `generatemap.inc` re-read, line-by-line, including both bitmap-decode branches and the smoothing helper | Formula, all constants, both bitmap passes, all smoothing parameters recovered |
| V2 | Fresh Python decode of 3 donor `.map` height grids with an independently written header locator (no import tool used), plus a generated 253,208-value float32 model of the active formula | Grid offsets/bounds confirmed; exact-value correspondence 32.29% / 69.44% / 51.09%; `battle1` max = `2.964×204/255` |
| V3 | Deterministic recomputation of the R-code table and EXE name census | Prior-doc amplitude overstatement found; native entry-point names present in EXE |

---

## 1. Answer in one line

**Donor height is `h = -1.1·fb·(1 + 3.5·fr) + A_class·fr`, where `fr = R/255`, `fb = B/255`
from the authored terrain-mask bitmap and `A_class ∈ {+2.964, +2.964/2.25, -2.964, 0}`;
there are no noise layers, no frequency parameter and no per-cell random term anywhere in
the height write (`generatemap.inc:552-578`).** Relief *shape* enters later through
native pattern stamps that carry authored float32 grids, and the final clamp is still
**UNVERIFIED**.

---

## 2. The `[*] = ;` convention and what is live (activity prerequisites)

Every source line of `generatemap.inc:1-1058` is stored as `      [*] = ;<code>`. This is the
donor's **live source-storage wrapper**, not a comment: the real disable token is `//`.
This was independently established in `DPATTERN_01_relief_grids.md:304-309` (citing
`RV-SEL-01:65-83,397-402`) and is confirmed internally by this fresh read: lines that are
genuinely disabled use `//`, e.g. `:50` (`// const cDropWaterPatterns`), `:213`
(`//exit`), `:297-299` (`//ErrorLog...`), `:571-572` (the two commented amplitude
multipliers), `:607`, `:680-685`, `:784`, `:807-810`, `:840-888`, `:1055-1056`.

**Label: observed** (wrapper shape and `//` usage in the literal file), **inferred** (the
claim that the engine executes the unwrapped text; no donor run was made).

Therefore every `SetHeightData` / `SmoothTerrain` / `_misc_SmoothTerrainCustom` call
quoted below is **live donor intent**. Native execution itself remains **UNVERIFIED** by
this lane (see §7).

---

## 3. Full donor height algorithm — pseudocode with `path:line`

```text
# ============ PHASE 0 — seed, random source, bitmap load ============
bRandomMap := BoolRegister0                              # generatemap.inc:61
if bRandomMap:                                           # :139-141
    bTGA := True
    randkey0 := gMap.settings.gen.randkey0               # :142
    randkey1 := gMap.settings.gen.randkey1               # :143
    if record-manager 'Generator' exists:                # :144-156
        folderpath := ParserGetValueByKey('maskpath')    # :151
        inputbitmap := ParserGetValueByKey('maskname')   # :152
    else:
        plcount := count of existing non-spectator players  # :159-169
        folderpath := StringRegister0                    # :171  (relief-type mask dir)
        ParserGetFilesInRoot(folderpath+'\*.tga')        # :174
        for i := plcount .. gc_MaxPlayerCount-1:          # :179-187
            try folderpath+'\'+i+'pl*.tga'; first non-empty wins
        rndind := floor(RandomExt*count)                 # :190   <-- ONLY RNG in source pick
        inputbitmap := file[rndind]                      # :191
else:                                                    # editor / authored mission
    randkey0 := 0; randkey1 := 10                        # :87-88
    inputbitmap := editor form value                     # :95-111
srcbitmappath := folderpath+'\'+inputbitmap              # :202
SetRandomExtKey64(randkey0, randkey1)                    # :216   (seed reset #1)
srcbitmap := CreateBitmapTGA if bTGA else CreateBitmap   # :286-289
LoadBitmap(srcbitmap, srcbitmappath)                     # :290
GetBitmapSize(srcbitmap, srcwidth, srcheight)            # :292
lx, ty := _misc_GetMapLeftTopPos()                       # :253-254  (centred origin)

# ============ PHASE 1 — decode the SOURCE mask (class + starts) ============
gPatternMask[*] := False                                 # :311-313
if srcwidth > mapwidth:                                  # :315  (upscale path)
    for bitmapy, bitmapx over src bitmap:                # :318-320
        x := floor((bitmapx/srcwidth)*mapwidth)          # :322
        y := floor((bitmapy/srcheight)*mapheight)        # :323
        GetBitmapPixel(srcbitmap,bitmapx,bitmapy, fr,fg,fb,fa)   # :324  (floats 0..1)
        if (fr=1) and (fg=1) and (fb=1):                 # :325  PURE WHITE = START
            dedup by (bitmapx,bitmapy), store gMap.players[spInd] # :327-337
            fr := fg := fb := 0                          # :338-341  (wipe start pixel)
        ir := floor(fr*255); ig := floor(fg*255); ib := floor(fb*255)  # :342-344
        gMapMask[x,y].r,g,b := fr,fg,fb                   # :345-347
        gMapMask[x,y].broad := (fa>0)                     # :348-351
        case ir of                                       # :352-370
            255, 191 : terrain := cRPlateau; bsmooth := (ir=191)
             96, 112 : terrain := cRHill;    bsmooth := (ir=112)
             48,  88 : terrain := cRRavine;  bsmooth := (ir=88)
             else    : terrain := cRNone;    bsmooth := (ir=64)
        case ig of: 255→cGForest; 127→forest only if terrain≠none;
                    64→cGGenForest; 128→cGStone; 192→cGForestStone  # :371-383
        case ib of: 255→cBWater else cBNone               # :384-388
        gPatternMask[x,y] := NOT( (ir,ig,ib)=(0,0,0) or (255,255,255) ) # :389-393
else:                                                    # :396  (1:1 or downscale path)
    for y,x over map grid:                               # :397-398
        bitmapx := x if sizes equal else floor(x/mapwidth*srcwidth)   # :402-411
        GetBitmapPixel(...)                              # :412
        same white-start handling + dedup                # :413-443
        same ir/ig/ib decode, same cases                 # :444-495
for i := 0 .. spInd-1:                                   # :498-502
    startx := -(W div 2) + (startx/srcwidth)*W           # centred generator coords
    starty := -(H div 2) + (starty/srcheight)*H

# ============ PHASE 2 — TARGET resample (overwrites R and B only) ============
if not bRandomMap:                                       # :507  EDITOR ONLY
    if cPostProcessBitmapGaussian: SetRandomExtKey64(...); ExecuteState('PostProcess') # :509-516
    trgbitmap := LoadBitmap('.\data\gen\bitmap\ext\bitmaptrg.bmp')   # :519-521
else:
    trgbitmap := srcbitmap                               # :531  RANDOM MAP: SAME BITMAP
for y,x over map grid:                                   # :537-538
    bitmapx := floor((x/mapwidth)*trgwidth)              # :541
    bitmapy := floor((y/mapheight)*trgheight)            # :542
    GetBitmapPixel(trgbitmap, bitmapx,bitmapy, fr,fg,fb,fa)   # :543
    gMapMask[x,y].r := fr                                # :544   <-- used by height term
    # gMapMask[x,y].g := fg;   [DISABLED at :545]
    gMapMask[x,y].b := fb                                # :546   <-- used by water term
# NOTE: .terrain class is NOT recomputed here. For random maps trg==src so R and class
# agree; for editor maps class comes from SOURCE while fr/fb come from POST-PROCESSED TARGET.
#                                                              [derived from :537-547 + :352-370]

# ============ PHASE 3 — THE HEIGHT WRITE (the formula) ============
if cLoadHeightDataFromTexture:                           # :552  (True at :37)
  for y := 0 .. mapheight, x := 0 .. mapwidth:           # :556-557  NOTE inclusive (+1 row/col)
    realx := floor(lx+x); realy := floor(ty+y)           # :559-560  centred engine grid
    ix := ClampInt(x,0,mapwidth-1); iy := ClampInt(y,0,mapheight-1) # :561-562
    fr := gMapMask[ix,iy].r; fb := gMapMask[ix,iy].b     # :563-564
    if bRandomMap and (fr=1) and (fb=1): continue        # :565-566  skip start pixels
    hwater := cWaterHeight*(fb*(1+fr*3.5))               # :567  = -1.1*fb*(1+3.5*fr)
    case gMapMask[ix,iy].terrain of                      # :569-573
        cRPlateau : hterrain := cPlateauHeight*fr        # :570  (+2.964*fr)
        cRHill    : hterrain := cHillHeight*fr           # :571  (+1.31733*fr)
                    # ... //*(255/cRColorHill);  [DISABLED — see §5]
        cRRavine  : hterrain := cRavineHeight*fr         # :572  (-2.964*fr)
                    # ... //*(255/cRColorRavine); [DISABLED — see §5]
        # no else: cRNone leaves hterrain unassigned (effectively 0 — see §5)
    SetHeightData(realx, realy, hwater+hterrain)         # :574  THE ONLY BASE HEIGHT WRITE

# ============ PHASE 4 — SMOOTHING (three mechanisms) ============
helper _misc_SmoothTerrainCustom(x,y,times,power,lerp,minh,maxh):    # :218-245
    if power=0: exit                                     # :220-221
    for i := 0 .. times-1:                               # :227
      if x>minx and x<(W div 2) and y>miny and y<(W div 2):  # :228 (uses W for both axes)
        lt:=GetHeightData(x-1,y-1); rt:=GetHeightData(x+1,y-1)   # :230-231
        lb:=GetHeightData(x-1,y+1); rb:=GetHeightData(x+1,y+1)   # :232-233
        h :=GetHeightData(x,y)                           # :234  DIAGONAL 4-neighbour stencil
        if h<>lt or h<>rt or h<>lb or h<>rb:             # :235  skip if flat
          if minh<=h<=maxh:                              # :236
            z1 := (lt+rt)/2; z2 := (lb+rb)/2             # :238-239
            res := h + ((z1+z2)/2 - h)/power             # :240
            res := Lerp(h,res,lerp)                      # :241
            SetHeightData(x,y,res)                       # :242  SECOND height write site

if cSmoothTerrainUsingBitmap:                            # :580 (True at :38)
  for y,x if gMapMask[x,y].bsmooth:                      # :584-587
    SmoothTerrain(realx, -realy, False, 3)               # :591  NATIVE; note -realy sign flip

if cSmoothAllMapHeight:                                  # :598 (True at :39)
  for y,x: _misc_SmoothTerrainCustom(realx,realy,1, 4, 0.5, 0.01,100) # :601-608 (land only)
  for i := 0 .. 2:                                      # :612  THREE COASTAL PASSES
    for y,x:                                            # :614-615
      bWater := (gMapMask[ix,iy].water = cBWater)        # :621  MASK test, not height test
      for ny in y±rad, nx in x±rad (rad=2):              # :625-634
          if any gMapMask[nx,ny].water=cBWater: bWater := True
      if bWater: _misc_SmoothTerrainCustom(realx,realy,1, 0.35,0.5, -100,-0.01) # :637
  TerrainUpdate(True,False)                              # :641  native flush

# ============ PHASE 5 — WATER MESH FIELDS (not height) ============
if cPlaceWater:                                          # :646
    cWaterFieldSize := 2; cWaterMapArrSize := 640/2=320  # :649-651
    bWaterMap[wmx,wmy] := any mask B>0 and (R<1 or B<1) in 2x2 cell  # :656-676
    WaterFieldAdd(name, tx,tz,bx,bz, cOffsetY=-0.5)      # :688-704  native; NO height write

# ============ PHASE 6 — editor-only tail, no further height writes ============
SetRandomExtKey64(randkey0,randkey1)                     # :774 before TextureMap
ExecuteState('TextureMap'); ExecuteState('SmoothTiles')  # :776, :786
ExecuteState('LoadTextureTerrainFromBitmap')             # :795
# cPlaceFreeForests/cPostStandPatterns/cSeedWheat/cBuildTopology/cUpdateMinimap
# are ALL guarded `(not bRandomMap)` → :711, :801, :895, :1009, :1028, :1037
```

### 3.1 Where relief *shape* actually comes from (outside this file)

The base grid above is then sculpted by native pattern stamps. From the freshly read
`generatemap.inc` there is **no height write after phase 4**; the relief stamp families
live in `dogenerate.inc:1621-1765` and the per-cell float32 grids in `data\pattern\*.pattern`,
with sculpt config in `pattern.lib` — documented with byte offsets and cross-checks in
`DTRN_02_donor_terrain_geometry.md:202-252` and `DPATTERN_01_relief_grids.md:2-9,101-132,302-382`.
Those two reports were **not** re-derived byte-for-byte in this pass; their quoted literals
are used as context only and are labelled **prior report**. Key point for this task: the
base formula has **no noise/frequency**, while the pattern grids are *authored* relief
windows (e.g. `k_ravine_1` `[-2.9636,+3.1398]`, `plt2` `[-0.0733,+3.6134]`), and the
engine blend (`Replace`/`Smooth`, clamp/scale order) is **UNVERIFIED**
(`DPATTERN_01:348-382`).

### 3.2 Noise and seed — explicit answer

* **No noise layer, no amplitude/frequency parameter and no per-cell RNG exists in the
  height write.** Grep of the full file shows `RandomExt` only at `:190` (mask-file pick)
  and RNG-key resets at `:216`, `:513`, `:774`. **observed.**
* Noise *does* exist in `postprocess.inc:63-73,132-133,349-441`
  (`bRandomNoise=True`, `cNoiseProb=0.5`, `cMinDropPower=1`, `cMaxDropPower=3`,
  Gaussian radii `0.00001` and `0.925` with `rs=Round(r*2.57+0.5)=3`) but it operates on
  the **bitmap**, is invoked **only** from the `not bRandomMap` branch
  (`generatemap.inc:507-517`), and is therefore **not** part of skirmish height generation.
  **observed + derived.** Random-map masks are shipped pre-blurred (the port's
  `*_gauss.png`), consistent with `TERRAIN_DONOR_PIPELINE.md` C6.
* Seed use: `randkey0/randkey1` (map settings, or 0/10 in editor) seed `SetRandomExtKey64`;
  the only use before the height write is selecting *which* terrain-mask TGA is sampled.
  **observed.**

---

## 4. Constants and R-code tables

### 4.1 Constants (all **observed**, `generatemap.inc:4-7` unless noted)

| Constant | Literal donor source | Value | Role |
|---|---|---:|---|
| `cPlateauHeight` | `:4` | `2.964` | Plateau amplitude; multiplies `fr` |
| `cHillHeight` | `:5` | `cPlateauHeight/2.25` = `1.317333333…` (float32 `1.31733334`) | Hill amplitude; multiplies `fr` |
| `cRavineHeight` | `:6` | `-2.964` | Ravine amplitude; multiplies `fr` |
| `cWaterHeight` | `:7` | `-1.1` | Water-bed term in `hwater` |
| R multiplier in `hwater` | `:567` | `3.5` | `-1.1*fb*(1+fr*3.5)` |
| `cWaterFieldSize` / `cOffsetY` | `:649`, `:688` | `2` / `-0.5` | Water **mesh** field, not height |
| Coastal `rad` / power / lerp / band | `:625`, `:637` | `2` / `0.35` / `0.5` / `[-100,-0.01]`, 3 passes (`:612`) | Underwater smoothing |
| Global smooth power / lerp / band | `:606` | `4` / `0.5` / `[0.01,100]`, 1 pass | Land smoothing |
| `bsmooth` native radius | `:591` | `3` | `SmoothTerrain(realx,-realy,False,3)` |

Distinct **classification** constants (`texturemap.inc:29-31`, cited from
`TERRAIN_DONOR_PIPELINE.md §3.1`; not re-read here): `cMaxHeight=2.96`,
`cWaterHeight=-0.25`, `cWaterShoreHeight=-0.1`. These are **not** the `-1.1` used in the
height write. **observed (prior report)**.

### 4.2 R-code assignment (**observed**, `generatemap.inc:9-27`)

| Symbolic class code | R colour code | Expression | Integer value |
|---|---:|---|---:|
| `cRNone` | 0 | `:9` | 0 |
| `cRPlateau` | **255** | `:10`, `:21` | 1 / 255 |
| `cRHill` | **96** | `:11`, `:22` | 2 / 96 |
| `cRRavine` | **48** | `:12`, `:23` | 3 / 48 |
| `cRColorSmooth` | **64** | `:24` `128 div 2` | 64 |
| `cRColorPlateauSmooth` | 191 | `:25` `(255 div 2)+64` | 127+64 |
| `cRColorHillSmooth` | 112 | `:26` `(96 div 2)+64` | 48+64 |
| `cRColorRavineSmooth` | 88 | `:27` `(48 div 2)+64` | 24+64 |

G/B codes (`generatemap.inc:13-19,28-32`): forest 255, gen-forest 64, stone 128,
forest+stone 192; forest-only when G=127 and class≠none (`:373-377`/`:475-479`); water B=255.

### 4.3 Exact class×R height table — **CRITICAL CORRECTION TO PRIOR DOCS**

The **active** lines are `hterrain := A_class * fr` (`:570-572`) with `fr = R/255`.
The two multipliers `*(255/cRColorHill)` and `*(255/cRColorRavine)` appended after `//`
on `:571-572` are **disabled** — they would be required only if the source colour range
were `0-32 / 0-96` (the donor's own comment). **observed.**

| R code | donor class | `bsmooth` | `fr` | **active donor `hterrain` (f32)** | port `relief(v)` | Δ port−donor |
|---:|---|---|---:|---:|---:|---:|
| 255 | plateau | false | 1.00000000 | **+2.963999987** | +2.964000000 | +0.000000013 |
| 191 | plateau smooth | true | 0.74901961 | **+2.220094204** | +1.110047059 | −1.110047145 |
| 96 | hill | false | 0.37647059 | **+0.495937258** | +1.317333333 | +0.821396075 |
| 112 | hill smooth | true | 0.43921569 | **+0.578593493** | +0.650917647 | +0.072324155 |
| 48 | ravine | false | 0.18823529 | **−0.557929397** | −2.964000000 | −2.406070603 |
| 88 | ravine smooth | true | 0.34509804 | **−1.022870660** | +1.317333333 | +2.340203993 |
| 64 | none (smooth) | true | 0.25098039 | **0.0** * | +0.371952941 | +0.371952941 |

\* `case` at `:569-573` has **no `else`**: `hterrain` is never assigned for `cRNone`. At
Delphi language level an uninitialised `Float` local is **UNVERIFIED**; the observed
`.map` grids have `0.0` as the single most common value (29.38% / 61.94% / 37.17% exact),
so **derived** effective value is `0.0`.

**Corrections to prior documents (derived from the fresh read):**

1. `docs/audit/TERRAIN_DONOR_PIPELINE.md:102,241,278-282` and
   `docs/coord_swarm_2026-11-25/reports/DTRN_02_donor_terrain_geometry.md:135,176,391`
   describe `cHillHeight=1.31733` as "hill relief amplitude at R=96" and give unit-test
   expectations `R=96 → +1.317`, `R=48 → −2.964`. Those values require the **`//`-disabled**
   `*(255/code)` multipliers at `generatemap.inc:571-572`. Under the live text the
   amplitudes are **+0.496** and **−0.558**. **derived (strong), observed literals.**
2. `TERRAIN_DONOR_PIPELINE.md:281` lists `R=48 → −2.964`, which contradicts its own
   `−2.964*R/255` formula (`−0.558`). Fresh read resolves it in favour of `−0.558`.
3. `TERRAIN_DONOR_PIPELINE.md:241` claims port at R=88 is `+0.511`. The actual code
   (`variant3d/scripts/mapgen.gd:67-68`) has `absf(88−96)<=12`, so R=88 is captured by the
   **hill** branch and returns `+1.317`, not the fallback `+0.511`. **observed** (port line).

---

## 5. `.map` height layout — independent verification

### 5.1 Layout (from `DEEPDEC_05_map_serialization.md:82-98,258-288`, `DC_FORMATS.md:21`,
`variant3d/tools/import_donor_map.py:113-174`; re-verified independently here)

```
TerrainMapBegin (int32 len 15 + ASCII)                    OBS
  u32 W, u32 H, u32 subTiles(=4), u32 tilePx(=64)          OBS / INFER labels
  ~1.64 MB sparse pre-grid region                         UNVERIFIED
  u32 W, u32 W          <-- SECOND repeated dimension pair (anchor)
  f32[W*H] height grid, row-major idx = y*W + x, LE       OBS
  f32[639] post-grid run (320 maps)                       UNVERIFIED
  102400 x 37-byte tile records                           OBS
  ... MergeCamera / MergeModules / named coords ...
TerrainMapEnd
```

Dimensions are **not** hard-coded: `bonmis1`/`engmis4` = 320², `battle1` = 384²
(`DEEPDEC_05:95-97`). Height is IEEE-754 float32, little-endian, no compression and
no per-cell offset bias; the grid begins **8 bytes after the second `u32 W,u32 W` header**.

### 5.2 Fresh independent decode (pass 2 — fresh Python, own anchor search, no import tool)

| Map | File bytes | W×H | grid header | grid offset | min | max | mean |
|---|---:|---:|---|---|---|---:|---:|
| `bonmis1.map` | 23,447,543 | 320² | `0xA68AC5` | `0xA68ACD` | −2.9639999866 | +2.9639999866 | −0.0727413214 |
| `engmis4.map` | 29,429,271 | 320² | `0xA33534` | `0xA3353C` | −2.9639999866 | +2.9639999866 | +0.2523451036 |
| `battle1.map` | 56,117,715 | 384² | `0x1F21D16` | `0x1F21D1E` | −1.1000000238 | +2.3712000847 | −0.0707587129 |

**observed.** Min/max/mean for the two previously read maps reproduce `DTRN_02:260-263`
exactly; `battle1` is new to this pass.

Exact-float histogram (**observed**; `f32(2.964)=2.9639999866`, `f32(-2.964)=-2.9639999866`,
`f32(-1.1)=-1.1000000238`):

| Map | distinct values | `h==0` | `h==+2.964` | `h==−2.964` | exactly `−1.1` | outside `[−2.964,+2.964]` |
|---|---:|---:|---:|---:|---:|---:|
| bonmis1 | 49,804 | 30,084 (29.3789%) | 1,721 (1.6807%) | 361 (0.3525%) | 69 (0.0674%) | **0** |
| engmis4 | 29,425 | 63,429 (61.9424%) | 7,346 (7.1738%) | 2 (0.0020%) | 87 (0.0850%) | **0** |
| battle1 | 66,671 | 54,803 (37.1657%) | 0 | 0 | 20,039 (13.5898%) | **0** |

**Reconciliation note (observed):** `DTRN_02:260-263` reports bonmis1 "31.97% at 0.0,
21.69% at −1.1" and engmis4 "64.31% at 0.0". My counts use **exact float32 equality**;
the map contains many near-values (bonmis1: `−1.0999984741` ×10,236; `−1.0999999046` ×2,378),
so the earlier percentages evidently used an unstated tolerance/rounding. Both readings
agree on the dominant values and on the bounds; the precise percentages should be quoted
with the method stated.

### 5.3 Formula ↔ grid correspondence (pass 2, new evidence)

A model of the **active** formula was generated for all 256×256 integer `(R,B)` pairs and
all four classes (253,208 distinct float32 outputs), then compared to each decoded grid:

| Map | values exactly equal to a model output |
|---|---:|
| bonmis1 | 33,069 / 102,400 = **32.2939%** |
| engmis4 | 71,111 / 102,400 = **69.4443%** |
| battle1 | 75,341 / 147,456 = **51.0939%** |

Top exact matches are `(class,R,B)` = `(plateau,0,0)→0.0`, `(plateau,255,0)→+2.964`,
`(plateau,0,255)→−1.1`; smaller peaks include `(ravine,1,0)`, `(plateau,204,0)`.
Notably:

* `battle1` max `+2.3712000847` = `f32(2.964 × 204/255)` exactly — an 8-bit R code of 204,
  direct evidence that the height term is `cPlateauHeight * R/255`. **derived (strong).**
* The recurring step `−0.004313726` = `f32(−1.1/255)` is exactly `hwater` at `B=1, R=0`,
  confirming 8-bit quantisation of the water term. **derived (strong).**
* A non-zero fraction of cells does **not** match the model — consistent with the
  smoothing passes (`generatemap.inc:580-644`) and/or pattern stamping modifying a subset
  of cells. **inferred.**

### 5.4 How height is later clamped

* **In `generatemap.inc`: no height clamp exists.** `ClampInt` at `:561-562,619-620,
  626-627` clamps *indices*, not heights. The only height writes are `:242` and `:574`.
  **observed (full-file read).**
* Baked grids in all 3 maps lie inside `[−2.964,+2.964]`, and two reach the exact
  endpoints. This is **consistent with** a clamp but does not prove one: the base formula
  can produce `−3.45` for `R=88` (ravine) + `B=255` water, and relief grid `k_ravine_4`
  has min `−3.06597` (`DPATTERN_01:147`) below the baked ceiling. `battle1` never reaches
  either endpoint (max `+2.3712`, min `−1.1`), so saturation is not universal.
  **derived + UNVERIFIED (clamp implementation).**
* Port clamps twice: `variant3d/scripts/game.gd:993`
  `height[i] = clampf(height[i] + amp*f, RELIEF_RAVINE, RELIEF_PLATEAU)` and
  `game.gd:1099-1109` with a **port-only** `_noise2`-dithered cap
  (`hcap = 2.964 if hq<0.58 else 2.934`). The dither is a quantisation device, **not** a
  donor formula. **observed (port), no donor analogue.**

---

## 6. Port comparison — exact mismatches with owners

All port paths below are the **live `variant3d/` tree** (per `RELIEF_LIVE_DIAG_01.md:54-57`).
`app/scripts/*` carries the same `relief()` (`app/scripts/mapgen.gd:63-73`) and the same
stamp/clamp code (`app/scripts/game.gd:858-993,1095-1097`) and is an older duplicate.

| # | Donor fact (`path:line`) | Port code (`file:line`) | Exact mismatch | Owner | Label |
|---:|---|---|---|---|---|
| 1 | `hterrain = A_class*fr`, `fr=R/255`, all 7 R codes (`generatemap.inc:563-574`, table §4.3) | `variant3d/scripts/mapgen.gd:63-73` `relief()` | Threshold bands, not code→class→amplitude. R=191 → 1.110 vs 2.220; R=96 → 1.317 vs 0.496; R=48 → −2.964 vs −0.558; R=88 → +1.317 vs −1.023; R=64 → +0.372 vs 0 | `variant3d/scripts/mapgen.gd` | observed + derived |
| 2 | `hwater = −1.1*fb*(1+3.5*fr)` at `:567` | `mapgen.gd:186` | **Matches** (water term correct) — recorded so it is not "fixed" by accident | — | observed |
| 3 | One `GetBitmapPixel` per map cell, exact 8-bit codes (`:541-543`, `:409-412`) | `mapgen.gd:160-184` | Averages all source pixels mapped into a cell (`cr/cb /= n`), so 8-bit codes are blended; donor never averages | `variant3d/scripts/mapgen.gd` | observed |
| 4 | White start pixels skipped `:565-566` (test on R and B only) | `mapgen.gd:173-175` | Tests `r>0.99 and g>0.99 and b>0.99` (all three) — different gate | `variant3d/scripts/mapgen.gd` | observed |
| 5 | `bsmooth` cells get native `SmoothTerrain(realx,−realy,False,3)` (`:587-592`) | `mapgen.gd` — no equivalent | Missing entirely | `variant3d/scripts/mapgen.gd` | observed |
| 6 | Global land smooth: power 4, lerp 0.5, band `[0.01,100]`, 1 pass (`:606`) | `mapgen.gd` — no equivalent | Missing entirely | `variant3d/scripts/mapgen.gd` | observed |
| 7 | Coastal smoothing keyed on **mask B** with neighbour radius 2 and height band `[−100,−0.01]`, **3 passes at every quality** (`:611-640`) | `mapgen.gd:98-122,191-208` | Keyed on `height<0.8`/`<−0.1`, smooths all near-water cells; passes drop to 2 (medium) / 1 (low) at `:194-197` | `variant3d/scripts/mapgen.gd` | observed |
| 8 | `hterrain` has **no** setting for `cRNone` (`:569-573`); donor land baseline 0.0 | `game.gd:1042-1055` | Adds analytic paraboloids `(1−dd)²×(2.964/2.25)×relief_scale` — no donor analogue in this file; max 1.317 and tiny at map scale | `variant3d/scripts/game.gd` | observed (port) |
| 9 | Relief shape = authored `w×h` float32 grids in `.pattern` with `HeightFieldScale/Min/Max` (prior: `DPATTERN_01:101-132,348-382`) | `game.gd:870-993` | Analytic radial/taper `f=clampf((edge−d)/rim,0,1)` over donor *footprints*; comment at `:874-875` still says height fields "undecoded" | `variant3d/scripts/game.gd` (+ `pattern_gen.gd` data contract) | observed |
| 10 | No height clamp in `generatemap.inc`; authored pattern grids can reach −3.066 (`DPATTERN_01:147`) | `game.gd:993` and `:1099-1109` | Two clamps; the second uses a `_noise2` dither on the cap (`:1105-1108`) producing 2.964/2.934 bands — a port-only height artefact | `variant3d/scripts/game.gd` | observed |
| 11 | Donor stamp families are native `_misc_SetupPatternsByType` + `StandPattern` (prior: `DPATTERN_01:302-346`) | `game.gd:893-985` | Per-kind amplitude table is port-authored (`plateau 0.97/6`, `plain 0.45/8`, `mountain 0.78/8`, `hill 0.80/8`, `ravine rim 3`) — no donor literals | `variant3d/scripts/game.gd` | inferred (port) |
| 12 | Donor flag/relief is not a dump gate; height is written during generation | `main.gd:788-803`, `config.gd:448-449` | `features.terrain.relief_stamps` gates **only** the `relief_stamps` key in `--dump-map`; live boot discards it (`world3d_terrain.gd:916-953,522-524,1193`) — confirms `RELIEF_LIVE_DIAG_01` rank 1 | `variant3d/scripts/main.gd`, `config.gd` | observed |
| 13 | Donor water `cOffsetY=-0.5` on a 2-cell field grid (`:649,688,704`) | `mapgen.gd` / `game.gd` | Port derives water from height `<−0.25`; donor's water **mesh** flag comes from mask B (`:666`) | `variant3d/scripts/mapgen.gd` | observed |

**On the observed symptom** (`RELIEF_VISUAL_01.md:134-157`, `:226-246`): pale, stepped,
grid-aligned bands with no hills. From the source comparison: (a) no donor relief grid
reaches live `height[]` (rows 9/12), (b) the port's own dithered cap (row 10) is a
height-side source of banding, and (c) `RELIEF_LIVE_DIAG_01.md:213-255,278` independently
attributes the *bright* marks to `test7/8/9` tile-id art on flat cells. All three are
**port-side** explanations; **no donor frame exists and no parity claim is made**.

---

## 7. Which donor code actually writes heights at runtime?

### 7.1 Plaintext (script-level, live intent — `observed`)

| Writer | Location | Gate / note |
|---|---|---|
| `SetHeightData(realx, realy, hwater+hterrain)` | `generatemap.inc:574` | Base mask write; skipped for white start pixels on random maps |
| `SetHeightData(x, y, res)` | `generatemap.inc:242` (inside `_misc_SmoothTerrainCustom` `:218-245`) | Reached from `:606` (global), `:637` (coastal ×3); not from the `bsmooth` path |
| `SmoothTerrain(realx,-realy,False,3)` | `generatemap.inc:591` | Native; only on `bsmooth` cells |
| `PlateauTerrain(0,0,False,r,True)` | `generatemap.inc:265` | **Editor-only** branch (`not bRandomMap`, `:264-280`) |
| `PlateauTerrain(...)` | `dogenerate.inc:470` | Inside a `{...}`-commented block `:467-478` — **disabled** |
| `SetHeightData(realx,realy,h*koef)` | `miscext.script:1519-1520`, `koef=0.8` at `:1513` | Gated `bModifyHeight and not bwater` — an editor "modify terrain" helper, not the skirmish path |

A full text search of `C:\Games\Cossacks 3\data\scripts\**` for
`SetHeightData|GetHeightData|SmoothTerrain|PlateauTerrain|TerrainUpdate|SetHeight|HeightField`
returned 47 matches; the complete set of **write** sites is the table above (all other
hits are reads/constants/features). **observed.**

### 7.2 Native / UNVERIFIED boundary

These names are embedded in `cossacks.exe` (read-only byte census, **observed**;
file offsets): `SetHeightData @0x2a30ea`, `GetHeightData @0x2a30ae`,
`SmoothTerrain @0x2a2d5a, @0x2a2f12`, `PlateauTerrain @0x2a2e96, @0x442030, @0x44204c,
@0x4421f0, @0x44220c`, `TerrainUpdate @0x2a326e`, `WaterFieldAdd @0x201db2`,
`THeightFieldGetHeightEvent @0x140d8a`, `HeightField` ×48 (`DEEPDEC_02` evidence
`ev_4e4eeb88…`). This proves **native entry points exist**, not that a given script line
calls a given machine-code function.

| Layer | What is provable | Label |
|---|---|---|
| `generatemap.inc` text | Live source issues `SetHeightData`/`SmoothTerrain` calls; `[*] = ;` is storage, `//` is disable | observed (text) / inferred (execution) |
| Native engine | Owns the height array, `SetHeightData`/`GetHeightData`/`SmoothTerrain`/`PlateauTerrain`/`TerrainUpdate`/`WaterFieldAdd`; RTTI `THeightFieldGetHeightEvent(x,y,z,out color,out texPoint)` supplies per-vertex height/colour/UV to the HeightField shader | observed (names/RTTI) |
| Native implementation math | Exact `SmoothTerrain` stencil, `PlateauTerrain` shape, float rounding, clamp timing, and height-grid→mesh tessellation | **UNVERIFIED** — no donor run, no decompiled implementation |
| Relief pattern blend | `HeightFieldStand/Scale/Min/Max/Smooth/Replace/ReplaceForWater/Offset` occur **only** in `pattern.lib` (9,520 hits, zero script consumers: `DPATTERN_01:366-370`) | observed (absence) / **UNVERIFIED** (blend) |
| Runtime dispatch of terrain draw paths | `sub_4ff680`/`sub_501420` have 0 static callers and 0 address-taken (`DEEPDEC_02 §2A`) | **UNVERIFIED** |

**Bottom line:** the only demonstrable height writers are the native engines behind
`SetHeightData` and `SmoothTerrain`; the plaintext `.inc` supplies the *formula and the
call sites*. Which machine-code routine executes them, and whether a final clamp occurs,
is **UNVERIFIED** in this lane. Do not assert runtime execution or parity.

---

## 8. Open questions (UNVERIFIED — do not guess)

1. Is there a native height clamp at `±2.964`? Observed grids never exceed it, but
   `generatemap.inc` contains no clamp, `battle1` saturates neither endpoint, and relief
   grids can reach `−3.066`. `DPATTERN_01` Q8.
2. Exact per-cell blend of `HeightFieldReplace` / `ReplaceForWater` / `Smooth` and the
   sign convention of `HeightFieldScale=−0.925` (engine-side, config-only).
3. Exact byte offset of each relief `.pattern` float grid (±24–160 B ambiguity;
   `DPATTERN_01:110-118,540-543`).
4. Height-grid→surface-mesh tessellation / distance LOD (`DTRN_02` C19, `G31` Q2).
5. Donor metres per cell / height unit — blocks any absolute "donor is flatter" claim
   (`DTRN_02` C20).
6. For editor maps, does the class-from-source / `fr,fb`-from-target split (§3 phase 2)
   ever intentionally produce e.g. ravine class with target R=255 (a candidate source of
   the exact `−2.964` cells)? **inferred**, no plaintext consumer proves the intent.
7. Meaning of `gMapMask[x,y].terrain` when `cRNone` leaves `hterrain` unassigned —
   Delphi language-level initialisation (§4.3 note).
8. Why the earlier reports' `-1.1`/`0.0` percentages differ from exact-float counts
   (§5.2) — likely tolerance, not a different formula.
9. Native `SmoothTerrain(...,3)` stencil and the `-realy` sign flip at `:591` — no code
   recovered; the helper `_misc_SmoothTerrainCustom` is the only smoothing math observable.
10. No donor GPU frame exists; all visual statements about our map are port-internal.

---

## 9. Summary

* **Donor formula (observed, full fresh read):** `h = −1.1·fb·(1+3.5·fr) + A_class·fr`,
  `fr=R/255`, `fb=B/255`, `A_class ∈ {2.964, 2.964/2.25, −2.964, 0}`; white start pixels
  skipped; `SetHeightData` at `generatemap.inc:574`. **No noise layer, no frequency, no
  per-cell RNG.** Seed only selects the source bitmap (`generatemap.inc:190,216`).
* **R codes (observed):** plateau 255, hill 96, ravine 48, smooth-none 64, plus smooth
  variants 191/112/88. The **live** amplitudes at 96 and 48 are ≈`+0.496` and `−0.558`,
  not `+1.317`/`−2.964`: the multipliers that would produce the larger values are
  `//`-disabled at `generatemap.inc:571-572`. This corrects `TERRAIN_DONOR_PIPELINE.md`
  and `DTRN_02` (§4.3).
* **Smoothing (observed):** diagonal 4-neighbour helper `:218-245` (`power/lerp` formula
  `:238-242`), `bsmooth` native radius 3 at `:591`, global `power=4,lerp=0.5` at `:606`,
  coastal 3 passes `rad=2,power=0.35,lerp=0.5` gated on mask-B at `:611-640`.
* **`.map` (independent re-decode):** LE float32 `[W*H]` immediately after the second
  repeated `u32 W,u32 W`; bonmis1/engmis4 320² at `0xA68ACD`/`0xA3353C`, battle1 384² at
  `0x1F21D1E`. Bounds and 8-bit quantisation steps (`2.964×204/255`, `−1.1/255`)
  independently confirm the formula. Final clamp **UNVERIFIED**.
* **Activity:** plaintext supplies formula and call sites; native engine owns the height
  array; pattern grids are consumed engine-side with no plaintext blend. Runtime
  execution and draw-path identity stay **UNVERIFIED**.
* **Port:** 13 concrete divergences (§7), chiefly `mapgen.gd:63-73` band decoding and
  `game.gd:870-993,1099-1109` analytic stamps + dithered clamp; the relief flag is
  dump-only (`main.gd:788-803`). These explain the flat/no-hill symptom and a possible
  height-side banding source, but the bright marks are best explained by tile art
  (`RELIEF_LIVE_DIAG_01`). **Port approximation only; no donor parity claim.**

---

*End of HEIGHT-GEN-DEEP-01. One report written. Donor accessed read-only (Python bytes +
latin-1 + struct); no donor file run, copied or modified; no repo source, asset, config,
test, shader, JSON or git change; no runner job submitted.*
