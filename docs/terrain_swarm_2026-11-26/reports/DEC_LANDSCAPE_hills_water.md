# DEC_LANDSCAPE — donor hills + water formation (mask → relief → smooth → shore → fields)

- target: `t_87f0f3c130b0` = `C:\Games\Cossacks 3\cossacks.exe` (5,768,048 B, sha256 `87f0f3c130b0…`), Deep mode, donor READ-ONLY
- context: 4K overview shows 4 grey water blobs + relief; this report recovers the full donor hill/water chain so the port can reproduce shape, depth, shores and borders without inventing values
- prior starting points (not repeated blindly): `reports/F04_masks.md`, `reports/D03_mask_pipeline.md`, `reports/D06_water_shore.md`, `spec/03_MASK_TO_HEIGHT.md`, `spec/04_PATTERN_STAMPING.md`, `spec/05_WATER_SHORE.md` — all re-verified below with fresh reads + new native anchors
- discipline: donor text/bytes only; every DScript line is `[*] = ;`-prefixed intent text; **runtime execution UNVERIFIED [U]**; no donor binary executed, no donor file copied, no code/Godot/git touched; **no parity claim**; max 5 passes per function (owner rule), logged in §1

Labels: [O] = observed donor bytes/text/instructions re-read this ticket; [D] = deterministic arithmetic/control-flow from [O]; [U] = UNVERIFIED, do not implement as fact.

## 1. Pass ledger (why this goes deeper than F04/D03/spec03-05)

| # | Question / contradiction | Passes (≤5) | Outcome |
|---|---|---|---|
| P1 | Mask constants + class codes real? | (1) `generatemap.inc:0-50` fresh read; (2) `generatemap.inc:340-450` class decode; (3) `generator.cfg:0-35` shape paths; (4) native `terrainmask` byte search → 0 hits; (5) native `CreateBitmapTGA` search → 1 hit `0x60cbc2` CODE | [O] text confirmed; native TGA loader is a DScript-API registration string, not a recovered decoder — decoder function still [U] |
| P2 | Relief formula `hwater/hterrain` exact? | (1) `generatemap.inc:540-720` height loop; (2) second read `:400-450` sampling/starts; (3) prior D03 formula cross-check; (4) native f32 census from D03 (distinctive constants absent) — reused, not re-scanned | [O] verbatim formula; [D] not compiled as float constants in binary |
| P3 | Height smoothing = how many passes, what kernel? | (1) `generatemap.inc:210-290` `_misc_SmoothTerrainCustom` body; (2) `generatemap.inc:580-645` S0/S1/S2 chain; (3) native `SmoothTerrain` → 2 hits `0x6a395a/0x6a3b12`; (4) native `MapGeneratorSmoothTerrain` → 1 hit `0x6a394e` with full signature | [O] exact chain + new native proof that both smooth entry points are engine-registered DScript procedures |
| P4 | Shore sectors + tile smoothing real? | (1) `texturemap.inc:25-100` gates; (2) `texturemap.inc:460-540` 8×45° table; (3) `smoothtiles.inc:185-245` `SmoothTileMap(…,3)`; (4) `tilesmooth_scripts.cfg:0-70` probs; (5) `globalparams.cfg:0-30` `TileSmoothPasses=6` vs script `3` | [O] contradiction preserved, not resolved |
| P5 | Water fields/borders Y and tags? | (1) `generatemap.inc:640-760` field loop + `cOffsetY=-0.5`; (2) native `WaterFieldAdd` → 1 hit `0x6029b2` inside `sub_601d3c` + API signature bytes; (3) `misc.script` bridge/border rules via D06 (not re-read, cited); (4) native `sandsea1` → 0 hits (tile names not in binary) | [O] field Y and gate; [U] runtime plane Y |

New native evidence this ticket (all `document=t_87f0f3c130b0`): `ev_a61de37d18a8bf1608fe679ce73815788f691b5ea94884f339f6621b6e281271` (CreateBitmapTGA search), `ev_183a3a5a4c1094a1b8b693a3b77858e59f304c548b8bc73bb2023e3e72f80b8b` (`function CreateBitmapTGA: Integer` + `function CreateBitmap` registration bytes at `0x60cb80`), `ev_7f7b87d0a9100e795cc9891f1491460d7b548ef3955217dc192aa6eae5981762` (SmoothTerrain search, 2 hits), `ev_a5d0a56e30b35e3ed31983f1622c748296b44c8efa998a9fc0a0e8737d055120` (`procedure MapGeneratorSmoothTerrain(x,y,passes;radius:Float)` at `0x6a3930`), `ev_6a7e6a6a00ff055709c7fe5638788cae8dacc03b3e79fdc47d56f4880001c9ca` (MapGeneratorSmoothTerrain search, 1 hit `0x6a394e`), `ev_fc08cacc482de20bc57a409c7f4829780fb2d22d5f1641e75a86490b4ba8a658` (WaterFieldAdd search, 1 hit), `ev_7c0ced218c55877699c3ba4503d3502ba3e638734402490c9ad12ac7e5a33f70` (`function WaterFieldAdd(name;tx,tz,bx,bz,offsety:Float)` at `0x602980`), `ev_a74985c8c6f0e04fc2b8c95611890bcb768e6e654b6b5565055cd1e2da206a4d` (`0x6029b2` inside `sub_601d3c+0xc76`), `ev_644366dfa2624c0d9828ac5f718b3ced33be9ebd0839392987fa3f8a5963f19d` (`sub_601d3c`: 891 blocks / 1641 insns, study summary), `ev_83cacfab4d3a1439268451cee1ca5f387084295b165ec7479714ffb12455eadb` (`terrainmask` 0 hits), `ev_de8be27f5ce8cfd26119f543ac056b4c827346080cb287f6028953318c69acc1` (`_gauss` 0 hits), `ev_3b0a2563cd2f9d8689b9260f62e67d2f7fe2a1cd7822bfdbd34f7fa9e2ec7355` (`sandsea1` 0 hits), `ev_970aa93501f3e502f25639a96f5fd16246589a9be6ea5e53dad0d13a962ca870` + `ev_1ec212956a4952daf3e1769fe3b2241f4393877b19513348444d6f986d4aed6a` (function-find misses at `0x60cbc2`/`0x6a395a` = undiscovered-function limitation, not absence).

## 2. Mask decode — R/G/B, gauss, starts [O]+[D]

**[O] Shape-folder chain.** `generator.cfg` live Land path is `...\terrainmasks\nowater2` (`land` commented out); mediterranean/peninsulas/islands/continents/continent follow (`ev_6d3d13768d2064916d0bc519f6cfd39bff5446d706be2f8bbcf072f1f47e0af8`). `generatemap.inc:171-191` lists `folderpath\*.tga`, then first non-empty `i+'pl*.tga'` family for `i=plcount..7`, picks `floor(RandomExt*count)` (`ev_606306a220fbe3feb329705c5311eb977d4f3b74fc1694fe9e7d290c7dbb489f`). One RNG draw per map choice (D02 contract).

**[O] Channel schema (authored intent).** Constants (`ev_2d298dd2ba7b3d3e7a6732a81c55546aa2892996e700e205e402cf8e636318d6` re-confirmed + `ev_1b09ac2c2c2016bee0e68a0ce84aec46c504d73300c24c154ffd4d2072ec0065`):

- R: 255/191 plateau (+smooth), 96/112 hill (+smooth), 48/88 ravine (+smooth), 64 smooth-only; else `cRNone`. `bsmooth=(ir==smooth variant)`; smooth codes are `(code div 2)+64`.
- G: 255 forest, 127 forest-if-terrain-known, 64 gen-forest, 128 stone, 192 forest+stone; else `cGNone`.
- B: 255 water (`cBWater`), else `cBNone`. `broad:=(fa>0)` — no alpha byte exists in shipped 24-bit TGAs so this is inert on shipped data.
- `gPatternMask=False` when all-zero or all-white.

**[O] Shipped-data reality (F04/D03 full corpus, not re-decoded here).** All 1,331 vanilla `_gauss` + 1,279 `.src` masks have `R=G=0` off starts; 5,125 pure-white single pixels are the only 255s; B carries water + gauss ramp (all 256 values in `_gauss`, binary {0,255} in `.src`). Therefore `hterrain=0`, `forest=none` from masks alone on every shipped map — hills/forest must come from later stages (§3/§7), never from mask R/G.

**[O] Gauss is offline.** `moddersread.txt` (`ev_645ac14b55be9f99098a5aeed5cf5c11cf02435482e01fae835dfa82c5be3db9`): `_gauss` = postprocess of `.src` via `PostProcessSaver` in `scripts\editor.aix`; 256²→320², "smooth with noised water borders". Kernel (`ev_8c7c3d7b013806aa24c272a684ad6c9064c5b958d8b6f814c44feaa3814c9dc2`): `rs=Round(r*2.57+0.5)`, `w=Exp(-dsq/(2r²))/(PI*2r²)`, clamp-to-edge, `Round(255*val/wsum)/255`, `Clamp(0,1)`; two passes `r=0.00001 (rs=1)` then `r=0.925 (rs=3)`. Native `_gauss` = 0 hits (`ev_de8be27f…`) — blur lives in DScript/editor text, not compiled; shipped `_gauss` files already contain it.

**[O] Starts.** Pure white `fr=fg=fb=1` single pixels (`ev_4e304237c0d54df01f98fbc22b6b2fffa6ee618bfb6660c20f54f3267667b507`): dedup by exact coordinate (full scan in equal-size branch, prev-only in scaled branch), then zeroed (`fr=fg=fb=0`) before mask assignment. Filename `Xpl_` = marker count (6 near-duplicate + 2 DLC5 exceptions in F04). Sampling is nearest-pixel `floor(x/mapW*srcW)` (`ev_4e304237…`); second height pass leaves `g` unassigned (`//gMapMask[x,y].g:=fg`).

**[D] What this means for the 4 grey blobs.** Grey flat water = mask B bed (`h∈[-1.1,0]`) rendered without the donor water plane/shader split: with `fr=0`, `hwater=-1.1*(B/255)` is a smooth basin, deepest −1.1 at B=255, shoreline ramp over 1–2 px of gauss. A binary `B==255` gate loses 4–20 pts of water area vs donor `h<-0.25` (B≥58); a block-average resample further narrows the ramp.

## 3. Relief formula — `hwater` + `hterrain`, plateau/hill/ravine [O]+[D]

**[O] Verbatim** (`ev_3bc3d1b201378ba788b32229fa0f5e7e7f5ff4fd811a90687e74324c07b6e004`):

```
fr=gMapMask[ix,iy].r; fb=gMapMask[ix,iy].b
if bRandomMap and (fr=1) and (fb=1): continue   # keep start cell
hwater := -1.1*(fb*(1+fr*3.5))
case terrain of
  cRPlateau: hterrain := 2.964*fr
  cRHill:    hterrain := (2.964/2.25)*fr   # =1.31733…
  cRRavine:  hterrain := -2.964*fr
  # (no else → hterrain stays undefined/0; donor text has commented 255/cRColor multipliers)
SetHeightData(realx,realy,hwater+hterrain)
```

`cPlateauHeight=2.964`, `cHillHeight=2.964/2.25`, `cRavineHeight=-2.964`, `cWaterHeight=-1.1` (`ev_2d298dd2…`). `ix,iy` are clamped; loop is `0..mapW/H` inclusive; `realx=floor(lx+x)`.

**[D] Consequences.**

- Shipped masks (`fr=0` off starts): `h=-1.1*B/255`, range `[0,-1.1]`; water tag at `h<-0.25 ⇔ B≥58.1` (integer B≥58); shore at `h<-0.1 ⇔ B≥24`. No ±2.964 from masks — plateau/hill/ravine amplitudes are inert schema on shipped data.
- Authored (modded) masks: water deepens with R (`1+3.5*fr` up to 4.5× at white, but white is skipped); plateau +2.964·fr, hill +1.317·fr, ravine −2.964·fr (so ravine + water stack to −4.06 at fr=fb=1 if not skipped). The `terrain` enum, not the raw R byte, selects the branch — `191 vs 255` give identical height, differing only in `bsmooth`.
- Port must keep the enum branch + `fr` weighting (not `code/255` re-weighting) and keep the `fr=1&fb=1` skip; `mapgen.gd:212-215` already matches the `fr=0` case.

**[U]** Runtime execution of the `;`-prefixed block; `Round/Lerp/Exp/PI` precision; `SetHeightData` quantisation; whether `bRandomMap` swaps `trgbitmap:=srcbitmap` (no gauss) per `:529-533`.

## 4. Height smoothing passes — S0/S1/S2 exact [O]

**[O] Kernel** (`ev_6cd0ce44c67e975482a3d192333a1a57b8aa51d4395742b84ed5f42749874049`):

```
_SmoothTerrainCustom(x,y,times,power,lerp,minh,maxh):
  if power=0: exit
  repeat times:
    if in-bounds (x>minx, x<mapW/2, …):
      lt,rt,lb,rb = 4 diagonal neighbours; h = centre
      if any differ and minh≤h≤maxh:
        res = h+(((lt+rt)/2+(lb+rb)/2)/2-h)/power
        SetHeightData(x,y,Lerp(h,res,lerp))
```

Effective step = `lerp/power`: land `0.5/4=0.125`, coastal `0.5/0.35≈1.4286` (overshoots the diagonal mean — intentional).

**[O] Stage order** (`ev_3bc3d1b…` + `ev_21e884bff74f3f4acd8c3563eabe752439963b53be5f654e0104c0cdebac0553`):

| Stage | Trigger | Call | Source |
|---|---|---|---|
| S0 | each `bsmooth` cell | `SmoothTerrain(realx,-realy,False,3)` — radius/param 3, note negated Y | `:580-595` |
| S1 | whole map, once | `custom(1,4,0.5,0.01,100)` | `:598-608` (negative-range variant commented, do not implement) |
| S2 | cells with mask-water in clamped 5×5 (`rad=2`, Chebyshev square, `break(MAIN)`) | `custom(1,0.35,0.5,-100,-0.01)` × **3 passes** | `:611-640` then `TerrainUpdate(True,False)` |

**[O] Native registration (new this ticket).** `SmoothTerrain` and `MapGeneratorSmoothTerrain(x,y,passes;radius:Float)` exist as DScript-API strings in CODE (`ev_7f7b87…`, `ev_a5d0a56…`, `ev_6a7e6a6a…`); `terrainmask` has 0 native hits (`ev_83cacf…`) while `CreateBitmapTGA` has exactly 1 (`ev_a61de37…` + `ev_183a3a5…`). So the smooth entry points are engine-provided; their kernels remain [U] (built-in function discovery misses them: `ev_970aa935…`, `ev_1ec21295…`).

## 5. Shore sectors + tile smoothing [O]

**[O] Height→tile gate** (`ev_f75e8319953652afc3f5795a4abdeacdbb9bd664d4e4b129412cfc2144c9a253` + `ev_b39998acb0abca0a1b1b0bac7dfe269c0bc40892e44b2692cd1e70754efce79f`): only when `gMapMask.b>0`: `h<-0.25 → bWater`, else `h<-0.1 → bWaterShore`; collision `MapDrawCollision(water tag,1)`; cliff probes `|dh|>0.5/0.55` (`cDiff1/cDiff2`).

**[O] 8×45° wet-sand rim** (`ev_b39998…`): gradient `dirX=lh-rh, dirY=th-bh`, `vecangle+180`, `cAngle=45`, windows `[(k*45-22.5),(k*45+22.5))` with final else → bRT; tiles `bB/bT→sandsea1`, `bLB/bRT→sandsea5`, `bR/bRB/bL/bLT→sandsea6`; winter suffix; `MapGetTileIndexByTileBlock`. Commented alternatives (`sandsea2/3/4`, rock overrides) are not live. Tile names have 0 native hits (`ev_3b0a25…`) — script-level only.

**[O] Tile smoothing.** `SmoothTileMap` = per pass: horizontal sweep then vertical sweep of `GetNeighbourTiles` + `FindRandomTileIndex (RandomExt*sumProb, first cumulative win)`; distance-1 nonzero-prob = no-op; distance-2 = midpoint-list pick; larger gap = step toward water (`ev_062a2880ea566cc0dd2715cce1ee2b6514466cbd7ad9d69e2b3d82f5f2f410d3`). Live call `SmoothTileMap(0,0,W,H,3)` — **3 passes**. Probabilities (`ev_8e86fb5e04e0a63d703bffa1a78960b77ac444eadaf4bf2a70a4f6cee8a245ce`): `sandsea1-4=1`, `sandsea5=0.7/sandsea6=0.3`, `rock9/rock8/rock5=0`. Contradiction: `globalparams.cfg: TileSmoothPasses=6` (`ev_1d627b25201150d0e84930e1ccbf429cc28a7c795073bdc14dbdc82e1bf608a5`) has no readable consumer — follow the script `3`, record `6` as [U].

## 6. Water fields + borders [O]+[U]

**[O] Field raster** (`ev_21e884bff74f3f4acd8c3563eabe752439963b53be5f654e0104c0cdebac0553`): `cWaterFieldSize=2`, `cWaterMapArrSize=640/2=320`; per 2×2 block, if any cell has `b>0 and (r<1 or b<1)` → `bWaterMap[wmx,wmy]=True` (edge-label `CELL` + `break(CELL)`); commented neighbour-fill stays off; `WaterFieldsClear`, `cOffsetY=-0.5`, `mapsizemod=(320/((640/mapH)*2))*2`, `WaterFieldAdd(name,tx,tz,bx,bz,-0.5)` per true field.

**[O] Native registration (new).** `function WaterFieldAdd(name;tx,tz,bx,bz,offsety:Float)` at `0x602980` (`ev_7c0ced21…`); sole reference `0x6029b2` inside `sub_601d3c+0xc76` (`ev_fc08cacc…`, `ev_a74985c8…`, `ev_644366df…`). Class binding (XWater/fXWaterField) remains [U] — RTTI-only per D06.

**[O] Borders (D06, cited).** Water/waterborder/landborder/bridge tags + `gc_WaterBorderSize=3`, bridge `cScale=1.15/cBaseHeightOffset=0.4876/block 2.81·scale/ends 1.78·scale/offsets 1.07·scale/collision r=3 step 2 tag 10`, `fordtyp` = squad formation not terrain ford. Runtime plane-Y value (−0.5 vs classification −0.25/−0.1 vs basin −1.1) execution is [U]; keep the three levels distinct per spec05.

## 7. Concrete generation recommendations (port inputs, not edits)

1. **Mask import.** Nearest-pixel sample; exact-white detect → record start, zero pixel, skip height; keep `R` enum decode as schema but expect `hterrain=0/forest=none` on shipped masks; exclude starts from water fraction; use `B≥58` (not `>58`) + `B>0∧h<-0.25` gate; honour TGA orientation (final bottom-left, `.src` top-left); Land shape = `nowater2`.
2. **Relief.** Implement `hwater=-1.1*fb*(1+3.5*fr)` + enum branch `{2.964, 1.31733, -2.964, 0}*fr` exactly; do not re-weight by `code/255`; real hills on shipped maps come from pattern relief stamps (`spec04`: `sub_755f30` three blend paths + `Smooth` post-pass), not mask R — wire stamps before tuning amplitudes.
3. **Smoothing.** Order S0 (bsmooth, `SmoothTerrain(…,…,False,3)`, note `-y`) → S1 whole-map `(1,4,0.5,0.01,100)` → S2 3× `(1,0.35,0.5,-100,-0.01)` on 5×5 mask-water neighbourhood + `TerrainUpdate(True,False)`; coastal coefficient is `1.4286`, not `0.5`; land pass is not optional.
4. **Shore tiles.** Gate `b>0∧(h<-0.25∨h<-0.1)` → 8-sector `sandsea1/5/6` only (+`_winter`); smooth with `0.7/0.3` weights, `rock9/8/5=0`; tile passes = 3 horizontal+vertical sweeps, not 6; keep 6-branch cliff table separate.
5. **Water/borders.** Raster 2×2 fields with the exact `b>0∧(r<1∨b<1)` gate, `Y=-0.5` as candidate surface (label runtime [U]); collision borders radius 3, bridge as objects+collision tag 10; never use classification thresholds as plane Y; never bind `heightmapwaves0.tga` as `hmapTex` (alpha-255, commented out).
6. **QA gates.** Byte-identity on converted masks; `R/G` start-only check; `B≥58` water fraction; single-pixel starts with duplicate guard; gauss `2.57/2r²/clamp/Round(255·v/wsum)/255` baked offline if re-exported.

## 8. Risks + UNVERIFIED register [U]

- Donor DScript executes behind `;` comment prefixes in readable dumps — stage order/constants are [O] text, runtime behaviour [U].
- Native `SmoothTerrain/MapGeneratorSmoothTerrain/CreateBitmapTGA/WaterFieldAdd` are proven registrations but their kernels/callers are undiscovered (built-in `function_find` misses: `ev_970aa935…`, `ev_1ec21295…`); xrefs absent for string-immediate sites.
- `Round` ties, `Lerp/Exp/PI` precision, `SetHeightData` quantisation, px→world-metre scale, `fa/broad`, DLC5-only shapes, stamp-vs-smooth order for ±2.964, and any GPU A/B frame — all [U]; no visual parity claimed.

*End of DEC_LANDSCAPE report. One file written; donor READ-ONLY; no code/Godot/git touched.*
