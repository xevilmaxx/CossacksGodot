# DEC DEEP — Donor Forest Generation (cossacks.exe t_87f0f3c130b0)

> Scope: recover donor forest placement so candidate `terrain_donor_gen.gd` stops emitting sparse/isolated stands and reproduces dense irregular belts with glades. Donor READ-ONLY. No code/Godot/git touched. No parity claim.

- Donor pin: `t_87f0f3c130b0` (`C:\Games\Cossacks 3\cossacks.exe`, active target).
- Donor text sources (addresses = file + line; nothing executed):
  - `data/scripts/common.inc/dogenerate.inc` (2103 lines)
  - `data/scripts/lib/misc.script` (7013 lines)
  - `data/scripts/common.inc/generatemap.inc` (GenerateMap constants + bitmap pipeline)
  - `data/scripts/common.inc/smoothforestborders.inc` (171 lines)
- Feed context: 23k forest records but ~16k instance; palms/desert scrub newly converted but unbound; weeds dominate skips.

Legend: **[O]** observed in donor text (evidence id) · **[D]** derived inference for port · **[U]** unknown / unverified.

---

## 1. [O] Family selection is a Freq roulette with decay, not uniform choice

**Evidence:**

- `ev_3cb6763b7958d8e5b7dc3ea5d9e0eea9c3674fcebe196d4d09152bd36299c927` — `misc.script:3382-3730`: `_misc_GetOrCreateGeneratorParser` fills missing `Freq=1` and computes per-group `FreqSum`; `_misc_PatternIncreaseFreq` (`cMinFreq=0.0001`, `newfreq=oldfreq*0.2`, clamp, `FreqSum=sum-old+new`, `UsedCount+1`, `TotalCount+1`); `_misc_GetPatternNameByParser`: `freqrnd=RandomExt*freqsum`, in-order subtract `freqrnd-=freq`, first `freqrnd<freq` wins.
- `ev_158e24f52149ed153820aa1c74a255df24c7d36da7297ea460eb803ca0a08080` — `misc.script:3655+`: `_misc_PlacePatternByType` (8 tries, `CheckStandPatternExt(...,False,0)` test-only, then `PatternIncreaseFreq`) and `_misc_SetupPatternsByType` header (see §4).
- `ev_0ffdfec5f4afd722c49f7d0afc62ceb4e5abd6e56a09405571ddd73390a6fe25` — `dogenerate.inc:700-970`: every accepted forest/stone start placement calls `_misc_PatternIncreaseFreq(pGenerator,str,name)`.

**Donor rule recovered:**

1. Group `PatternList` selected by `str` (e.g. `forests_pinefir_medium`).
2. Individual `Pattern` picked by roulette over current `Freq` / `FreqSum`.
3. On accept, that pattern's `Freq *= 0.2` (floor `0.0001`) and `FreqSum` is decremented accordingly. This is anti-repetition / clump-breaking: re-picking the same dense pattern gets progressively rarer within one stage.
4. Missing `Freq` defaults to `1`.

**Port fix for `terrain_donor_gen.gd`:**

- Do NOT pick forest variant by `randi() % n` or uniform weights. Implement mutable `Freq/FreqSum` per group, initialised `1` where absent, `freqrnd = RandomExt()*freqsum` with in-order walk, and `freq*=0.2` on every stamp (same group `str`).
- Keep separate `FreqSum` per `str`, not one global table. Palms/desert scrub (`desert_forests_big/medium/unique/small`) need their own groups; if port maps them into temperate groups the roulette is wrong and they appear "unbound".
- Log `UsedCount/TotalCount` per group for tuning; donor already maintains them.

## 2. [O] `foreststype` is drawn then forced to 0 — pine/fir/spruce only in this build

**Evidence:**

- `ev_c1f53d01a0c13b8455615dc909446f4843fbca558366f4618f2f2d280aac6808` — `dogenerate.inc:1-30`:
  - `var foreststype : Integer = floor(RandomExt*3);`
  - immediately `foreststype := 0;`

**Donor rule recovered:**

- `foreststype` 0 = pine/fir/spruce path, 1 = leaf, 2 = mixed. The second line pins it to 0 in the shipped script, so `SetupStartingResources` and the `frs_*` block only ever take the `case 0` arm in this donor snapshot (desert path excepted, see §3).
- This explains why leaf/mixed groups exist in the file list but never dominate generated maps here.

**Port fix:**

- Default `foreststype=0`. Expose 1/2 only as explicit override, not random. When overriding, switch the ENTIRE group set (`forests_leaf_*` / `forests_mixed_*` + `smoothforestborders` `forestType`), not just one call site.
- `smoothforestborders.inc` keys the same enum (`cForestTypePineFirSpruce=0, Mixed=1, Leaf=2`, `forestType=IntRegister0` per `ev_5786d47b544dcc7b2d1cfcdd06a07971953cbe37b1e328ed5801cf0b5f2f5e25`). Port must pass the same value to both stages.

## 3. [O] Desert vs temperate group switch; palms/scrub unbound if group name mismatches

**Evidence:**

- `ev_0ffdfec5f4afd722c49f7d0afc62ceb4e5abd6e56a09405571ddd73390a6fe25` — `dogenerate.inc:736-940`:
  - `bDesert = (season=3)`.
  - Start ring: desert `desert_stoneforests` (ver<77) else `desert_forests_big`; temperate `stoneforests`.
  - Two start forests: desert `rnd=floor(RandomExt*2)` → `desert_forests_medium/big`; temperate `case foreststype`: `0: rnd=floor(RandomExt*7)` → `forests_pinefir_medium/spruce_medium/pine_medium/pinefir_big/spruce_big/pine_big/pine_big_2` else `forests_pinefir_medium`, `1: forests_leaf_medium`, `2: forests_mixed_medium`.
  - Same switch repeats for the +4 ring forest.
  - Desert `desert_stones` vs temperate `stones` uses `mindst+RandomExt*2+((i+j)*0.5)`.

**Port fix:**

- Gate EVERY forest pick on `bDesert` first, `foreststype` second. A palm asset bound to `forests_pine_big` will never be selected by the desert arm; a desert scrub bound only to temperate groups will never fire on desert maps. That matches "newly converted but unbound".
- Verify group-name strings exactly (`desert_forests_big/medium/small/unique`, `desert_stones`, `desert_stoneforests`). A typo routes to `Log('SetupPatternsByType : wrong str')` and zero stamps (see §4) — silent sparse output.
- Preserve version gate `gRecordGeneratorVersion<77` for `desert_stoneforests` vs `desert_forests_big` if port supports old seeds.

## 4. [O] `_setup_patterns_by_type` is uniform-cell draw with occupancy reject; `SetupTiledPatterns` is the lattice path (decor/tiles only)

**Evidence:**

- `ev_158e24f52149ed153820aa1c74a255df24c7d36da7297ea460eb803ca0a08080` — `misc.script:_misc_SetupPatternsByType`:
  - `mapsizeoptimise=(320*320)/(W*H)`; if `<1` then `*=0.65`.
  - `needed=floor(W*H*freq)`, fallback `needed=round(W*H*freq)` when floor is 0 but `freq>0` (+ log).
  - `trycount=floor(256*mapsizeoptimise)` per `needed` item.
  - Per item: roulette name once, then up to `trycount` draws `x=floor(x0+RandomExt*W)`, `y=floor(y0+RandomExt*H)` with `_misc_CheckStandPatternExt(env,name,x,y,True,pRMHnd)`; on success `PatternIncreaseFreq`, `realcount+1`, `badtries` otherwise.
- `ev_c2378ef378af5c2743cffd3888a52639cbc0941c869d10c21da48edf811219fd` — `dogenerate.inc:1330-1360` `SetupTiledPatterns(str)`: `cSize=25`, `wcount=floor(mapW/25)`, `hcount=floor(mapH/25)`, lattice `realx=round(x*25+12-(W div 2)-1)`, `realy=...`, unconditional `_misc_CheckStandPattern(...,True,False,0)` + `PatternIncreaseFreq`. Called only for `desert_tiles` / `tiles` (plus commented-out `tiles_decor 0.0006`).
- `ev_7fdf227d031da71f1216e0e7467b16081ed4eabf69ecf2ad601ab33be0d106ef` — `dogenerate.inc:1540-1600`: water-shore pre-block `if (not gPatternMask[x,y]) and (height<-0.1) then gPatternMask:=True` with `cWaterShoreHeight=-0.1`; relief freqs `plt/mnt/hil` per `relieftype 0-4`.

**Donor rule recovered:**

- Forests/stones/mountains/plains use UNIFORM random cell draws, NOT a 25-cell lattice. Lattice is tiles-only. Port must not tile forests on a grid — that yields the reported regular sparse look.
- Density is `needed ≈ W*H*freq` attempts with up to 256 (scaled down on >320 maps) occupancy tries each. Sparse vs dense is controlled by `freq`, not by lattice spacing.
- `badtries` is counted but only logged in commented `TimeLog`; no retry of `needed` beyond `trycount`.

**Port fix:**

- Implement `_misc_SetupPatternsByType` verbatim: `needed`, `trycount`, uniform `floor()` draws, test-and-stamp via `_check_stand` (§5), `Freq` decay on success.
- Keep `SetupTiledPatterns(cSize=25)` for `tiles`/`desert_tiles` ONLY. Do not reuse it for forests.
- Apply water pre-block BEFORE forests: `height < -0.1 → gPatternMask=True`. Forests drawn afterward auto-avoid water via occupancy test. Skipping this lets forests draw on shore then fail later, looking sparse.

## 5. [O] `_check_stand` occupancy: fast step-4 pre-scan + full box, maskStand/maskInvStand, OOB = occupied

**Evidence:**

- `ev_3cb6763b7958d8e5b7dc3ea5d9e0eea9c3674fcebe196d4d09152bd36299c927` — `misc.script:3384-3521`:
  - `angleRad=angle*pi/180`; `doStand` → `StandPatternWithAngle(pl,pat,standX,standZ,angleRad,0,90)` + optional `_misc_WritePatternToParser`.
  - Mask window from `GetPatternMaskWidth/Height`, `GetPatternOffsetX/Z`, `w=(mW-1) div 2`, `h=(mH-1) div 2`, `vMin=floor(x-w)`, `vMax=vMin+mW-1`, centre `cx=floor((vMin+vMax)/2)+0.5`.
  - Fast path only when `not doStand and angle=0`: `step=4`, `optW=mW div 4`, `optH=mH div 4`, sample `(fi,fj)` with edge clamp `Min(i*step,mH/mW)`; if `(mask & maskStand) or (!mask & maskInvStand)` then `indI=optYH+fi` (`vMinY+H div 2`), `indJ=optXW+fj`; OOB or `gPatternMask[indJ,indI]` → `false`.
  - Full box `i=vMinY..vMaxY-1`, `j=vMinX..vMaxX-1` (note `-1` upper bound in text), rotated `fi/fj` when `angle<>0` via `Round(cos)*(…)+Round(sin)*(…)`; `maskValue=GetPatternMaskValue(pat,i-vMinY,j-vMinX)`; same `maskStand/maskInvStand` gate; `doStand` stamps `gPatternMask:=true` where free, else test returns `false` on first OOB/occupied relevant cell.
  - `_misc_CheckStandPatternExt`: `Result=(env<>0) and Check(...,False,False,0)`; if true then `Check(...,True,bWriteToParser,pHnd)`.

**Port fix:**

- Reproduce the two-phase call: test pass (`doStand=False`) then stamp pass (`doStand=True`). Single-pass "stamp and rollback" changes `RandomExt` consumption and overlap behaviour.
- Respect BOTH `maskStand` and `maskInvStand`: only cells where `(mask & maskStand) or (!mask & invStand)` participate. Treating every pattern-bbox cell as blocking over-rejects and sparsifies.
- OOB counts as occupied in test mode. Do not allow edge wrap or edge-anchored forests.
- Keep fast step-4 pre-scan semantics (same `Min` edge clamp). It is a pure reject accelerator; removing it is fine for correctness but keeping it preserves skip counts/`badtries` distribution.
- `envplHnd=0` always fails. Ensure env player handle is valid before forest stage.

## 6. [O] Start `KeepClear` ellipses: two stamped rings around each start

**Evidence:**

- `ev_0ffdfec5f4afd722c49f7d0afc62ceb4e5abd6e56a09405571ddd73390a6fe25` — `dogenerate.inc:720-950`: `_misc_FillPatternMaskElipse(pointx,pointy+2,cCircle2MaskX,cCircle2MaskY)` after stoneforest ring; `_misc_FillPatternMaskElipse(pointx,pointy+2,cCircle3MaskX,cCircle3MaskY)` after second forest ring. Centre is `(pointx, pointy+2)`, not `(pointx,pointy)`.
- `ev_c1f53d01a0c13b8455615dc909446f4843fbca558366f4618f2f2d280aac6808` — `dogenerate.inc:13-30`: `_misc_FillPatternMaskElipse` body: `IsDotInElipse: sqr(x-x0)/sqr(rx)+sqr(y-y0)/sqr(ry)<=1`, loops `i=-round(ry)..floor(ry*2)-1`, `j=-round(rx)..floor(rx*2)-1`, `indx=floor(x+(W div 2)+j)`, stamps `gPatternMask:=True` in-bounds.
- Prior DEC `fnd_4` (D07) records radii `cCircle1 5x7, cCircle2 12x15, cCircle3 22x18` centred at `(start.x,start.y+2)` — cited here as cross-reference; radii constants live outside the two excerpts above.

**[U]:** exact `cCircle*MaskX/Y` numeric values were not re-read in this pass; confirm from donor `common.inc` constants before tuning (`fnd_4` values above are the current best reference, not re-verified here).

**Port fix:**

- After the stoneforest probe and again after the forest probes, stamp the two ellipses at `y+2`. Missing the `+2` offset shifts the clear zone and lets forests swallow starts (or leaves starts too bare if radius is inflated to compensate).
- Start probes themselves use `trycount=128`, inner `trycount2=3`, `dst=mindst+RandomExt*3+((i+j)*0.5)` (stones second ring `+RandomExt*2`), `angle=RandomExt*360`, `VectorRotateY`, `round(point+px/pz)`. `mindst=Min(maskX,maskY)` of the just-stamped (or next) circle. Implement this expanding-ring search; pure uniform scatter near starts will not match donor glade spacing.

## 7. [O] Density / clump dials: `frs_big/mid/small` + per-branch divisors + free-mask modifier

**Evidence:**

- `ev_7fdf227d031da71f1216e0e7467b16081ed4eabf69ecf2ad601ab33be0d106ef` — `dogenerate.inc:1690-1710`: `frs_big=0.0009`, `frs_mid=0.0009`, `frs_small=0.00054`, `dcr=0.0005`, `stn1=0.00016`, `stn2=0.00012`. Commented area-normalisation block is DISABLED (`{...}`), so no `areamod/0.85` correction in this build.
- Donor call sites (local grep, `dogenerate.inc:1805-1896`, to be promoted to evidence on next pass):
  - Desert: `desert_forests_big frs_big/4 + frs_big/8`, `desert_forests_medium frs_big/4 + frs_big/8`, plus `frs_mid/6` arms and `desert_forests_small frs_small/2`.
  - Temperate pine/fir/spruce (`foreststype=0`): `forests_{pinefir,spruce,pine,pine_big_2}_big frs_big/8` each (four concurrent big groups), `forests_{spruce,pinefir,pine}_medium frs_mid/6` each, `forests_{pinefir,pine}_small frs_small/4` each.
  - Leaf/mixed: `forests_leaf/mixed_big frs_big/4`, `..._medium frs_mid/4`, `..._small frs_small/4` (fewer concurrent groups, larger per-group share).
  - `stones stn1/stn2`, `plain_* pln_*`, `swamp_*/lake_*` interleave in the same occupancy space.
- `_misc_GetFreePatternMaskModifier(probsmall,probmid,problarge,probhuge)` + `modifier=640/((W+H)/2)` rescale `pln_*/swamp_*/lake_*` on non-640 maps (tail of `ev_7fdf227d...`; exact forest application is in the unread continuation).

**[D] why candidate looks sparse/isolated:**

- Four pine big groups at `frs_big/8` each ≈ `4×(W·H·0.0009/8)` attempts ≈ half the attempts of one leaf big group at `frs_big/4`. If port collapses the four groups into one draw with the same divisor, big-stand attempts drop ~4×.
- `frs_mid/6` ×3 groups and `frs_small/4` ×2 groups have the same fan-out. Port must issue ALL group calls; a single-group port is sparse by construction.
- Freq decay (§1) + occupancy reject (§5) turn uniform draws into clumps with holes (glades): first stamps succeed, depress their own pattern, neighbours fail on overlap, leaving gaps. A port without decay produces either uniform scatter (no clumps) or, if it adds its own min-distance, isolated dots (no belts).

**Port fix:**

- Keep the exact fan-out: pine path issues 4 big + 3 medium + 2 small forest calls with the divisors above; leaf/mixed issue 1+1+1 per size with `/4`. Do not "simplify" to one call per size.
- Apply `mapsizeoptimise` inside `trycount`, and the `640/((W+H)/2)` + free-mask modifier to `pln/swamp/lake` (and verify whether `frs_*` are also scaled in the continuation lines past `ev_7fdf227d...` before changing forest counts on 320/384 maps).
- Weeds (`tiles_decor 0.0006`, commented out in this snapshot) must stay OFF unless donor explicitly enables them; enabling weeds in the same mask space with forests explains "weeds dominate skips" — weeds consume `gPatternMask` cells that forests would otherwise take.

## 8. [O] Mask G/B gates: water (B) blocks; forest-type (G) selects border dress, not placement

**Evidence:**

- `ev_68ead745c2e6d359fc5a718cbb1781869623bdc6e91e10c5b5dc82d9a9ef6d466` — `generatemap.inc:0-60`: `cGNone=0, cGForest=1, cGGenForest=2, cGStone=3, cGForestStone=4`; `cBNone=0, cBWater=1`; colours `cGColorForest=255, cGColorGenForest=64, cGColorStone=128, cGColorForestStone=192`, `cBColorWater=255`; flags `cPlaceForest=True, cPlaceFreeForests=True, cPlaceWater=True`.
- `ev_d9f4ed1ef380aef32979ac0e7e6904433162aad483ffcb27a1f7064ae8971a96` — `smoothforestborders.inc:30-171`: gate `if ((g=2) or (g=3)) and (r=0)` on the GenerateMap bitmap (`r=floor(fr*255)`, `g=floor(fg*255)`), 4-neighbour `fr>0` count, only `count=1` cells enter `grid`; dress loop `if grid=3 → fr=1` else `grid=2 → fg=1`; `if grid=2 or (grid=3 and RandomExt>0.975)` then `count=floor(1+RandomExt*16)` border objects `fb_1..53` (pine path only in text) at `place=Clamp(real-rad+RandomExt*rad*2)`, `rad=1.5`, plus `tilecount=floor(1+RandomExt*3)` tiles `grass5/rock9/rock9` (`_winter` suffix when `GetSeasonType=2`).
- `ev_7fdf227d...` water pre-block (`height<-0.1 → mask`) is the B-gate enforcement into `gPatternMask`.

**Donor rule recovered:**

- B=255 (water) excludes via height/mask before forests ever draw. G=64 (`GenForest`) vs G=255 (`Forest`) vs 128/192 (stone mixes) select the bitmap-driven border dress in `SmoothForestBorders`; the excerpt only dresses `grid 2/3` (G-channels 2/3 in the `floor(fg*255)` domain — i.e. near-black green, NOT 64/255; the 64/255 mapping lives in the unread bitmap-encode section).
- Border dress is sparse by design: `grid=3` cells dress only with `p=0.025` (`RandomExt>0.975`), each dressing 1–16 `fb_*` props + 1–3 tiles.

**[U]:** full bitmap encode (`fr/fg/fb` ↔ R/G/B semantics for free vs mask forests) past `generatemap.inc:120` was not re-read this pass; shipped `_gauss.tga` census (prior D03-F9) shows R=G=0 in shipped masks, so live-mask G semantics must come from the in-memory bitmap, not shipped files. Do not port shipped-TGA green as forest density.

**Port fix:**

- Enforce B-gate FIRST (water/height), then occupancy. Do not treat G as a placement mask for free forests; G selects border dress.
- Implement `SmoothForestBorders` as a post-pass: single-neighbour (`count=1`) edge cells only, `fb_*` 1–53 + `grass5/rock9` tiles, `rad=1.5` jitter, winter suffix. Missing this pass leaves belts with hard edges (candidate "isolated" look).
- `forestType` mismatch (pine vs leaf/mixed) selects the wrong `fb_*` pool; the excerpt hard-codes `pind=floor(1+RandomExt*53)` only under `cForestTypePineFirSpruce`. Leaf/mixed arms are absent in the visible text — verify before enabling leaf/mixed dress, else leaf forests get zero borders.

## 9. Concrete port checklist (`terrain_donor_gen.gd` + props, no edits made)

1. **Roulette:** per-group `Freq/FreqSum`, `Freq default 1`, `freq*=0.2` + `FreqSum` fixup on stamp, `cMinFreq 0.0001`. Separate groups for `desert_*` vs temperate.
2. **Type gates:** `bDesert=(season==3)` outer, `foreststype=0` default (pin, do not randomise until design decision). Same value to start resources AND `frs_*` block AND border `forestType`.
3. **Draw kind:** forests = uniform `floor(x0+RandomExt*W)` with `trycount=floor(256*mapsizeoptimise)`; tiles ONLY on `cSize=25` lattice. `needed=floor(W*H*freq)` with `round()` fallback when 0.
4. **Occupancy:** test-then-stamp `CheckStandPatternExt`; honour `maskStand/maskInvStand`; OOB=blocked; `env<>0`.
5. **Starts:** `trycount=128×trycount2=3` expanding rings `dst=mindst+RandomExt*{3,2}+((i+j)*0.5)`, `angle=RandomExt*360` + `VectorRotateY`, `round()` coords; stamp ellipses at `(x,y+2)` after stoneforest ring and after forest ring. Confirm `cCircle*` radii from constants (prior `5×7 / 12×15 / 22×18` — re-verify).
6. **Density fan-out:** keep ALL per-group calls with exact divisors (`/4 /6 /8`, small `/4` or `/2` desert). Four pine big groups ≠ one group. Keep `stn1=0.00016, stn2=0.00012`, `frs_big/mid=0.0009, frs_small=0.00054`.
7. **Glades/belts:** expect them FROM decay + rejection, not from explicit clearing. If adding explicit glade carving, keep it outside the roulette or clumps double-thin.
8. **Borders:** post-pass `count==1` edge, `fb_1..53`, `rad=1.5`, `count=1+floor(RandomExt*16)`, tiles `grass5/rock9/rock9` + winter suffix, `grid=3` at 2.5%.
9. **Weeds/palms:** keep `tiles_decor` disabled as in snapshot; bind palm/scrub assets to `desert_forests_*` groups with their own `Freq`, not into temperate `forests_*`.
10. **Water:** `height<-0.1 → gPatternMask=True` before any forest; `B=255` never hosts forest. `G` is dress selector, not density.

## 10. Open unknowns [U] (do not guess in port)

- Exact `cCircle1/2/3MaskX/Y` + `cCircle*` constants file location.
- Continuation of `dogenerate.inc:1710-1940` (`modifier`, `GetFreePatternMaskModifier` application to `frs_*` vs only `pln/swamp/lake`).
- `generatemap.inc` bitmap encode for `cGColorGenForest=64` vs smoothborder `g=2/3` gate (two different green domains: authored colour vs `floor(fg*255)` sample — reconcile in next pass).
- Leaf/mixed `fb_*` pools (text shows pine `1..53` only).
- `gRecordGeneratorVersion` thresholds (77 for desert groups, 91 for `TerrainTypesDLC5`) vs port seed version.
- Shipped-mask vs live-bitmap G semantics (shipped census says R=G=0; live path is authoritative).

---

## Appendix — evidence ledger (this pass)

| id | source |
|---|---|
| `ev_c1f53d01a0c13b8455615dc909446f4843fbca558366f4618f2f2d280aac6808` | `dogenerate.inc:1-30` — `foreststype`, `IsDotInElipse`, `_misc_FillPatternMaskElipse` |
| `ev_3cb6763b7958d8e5b7dc3ea5d9e0eea9c3674fcebe196d4d09152bd36299c927` | `misc.script:3380-3740` — `CheckStandPattern`, `CheckStandPatternExt`, `GetOrCreateGeneratorParser/FreqSum`, `PatternIncreaseFreq`, `GetPatternNameByParser` roulette, `PlacePatternByType` |
| `ev_0ffdfec5f4afd722c49f7d0afc62ceb4e5abd6e56a09405571ddd73390a6fe25` | `dogenerate.inc:700-970` — `SetupStartingResources` desert/temperate switches, expanding-ring probes, ellipse stamps |
| `ev_c2378ef378af5c2743cffd3888a52639cbc0941c869d10c21da48edf811219fd` | `dogenerate.inc:1280-1710 (part)` — `SetupTiledPatterns cSize=25`, tiles-only call sites |
| `ev_7fdf227d031da71f1216e0e7467b16081ed4eabf69ecf2ad601ab33be0d106ef` | `dogenerate.inc:1540-1720` — water pre-block `-0.1`, `relieftype` table, `frs_big/mid/small dcr stn1/stn2`, disabled `areamod` block |
| `ev_158e24f52149ed153820aa1c74a255df24c7d36da7297ea460eb803ca0a08080` | `misc.script:3655-3755` — `SetupPatternsByType` uniform draw, `needed/trycount/badtries` |
| `ev_68ead745c2e6d359fc5a718cbb1781869623bdc6e91e10c5b5dc82d9a9ef6d466` | `generatemap.inc:0-120` — `cG/cB/cR` enums + colours + `cPlace*` flags + `forestType` |
| `ev_5786d47b544dcc7b2d1cfcdd06a07971953cbe37b1e328ed5801cf0b5f2f5e25` | `smoothforestborders.inc:1-30` header |
| `ev_d9f4ed1ef380aef32979ac0e7e6904433162aad483ffcb27a1f7064ae8971a96` | `smoothforestborders.inc:30-171` — `(g=2/3,r=0)+count==1` gate, `fb_1..53`, `rad=1.5`, `grass5/rock9` tiles |

Prior cross-refs (not re-emitted): D07 `fnd_3` (`CheckStandPattern` fast+full scan), `fnd_4` (`SetupStartingResources` ellipses `5×7/12×15/22×18 @ y+2`), D03-F9 (shipped TGA `R=G=0`, B-only water — live bitmap is authoritative for G).

*No parity claim. Next pass (if authorised): read `dogenerate.inc:1710-1940` (modifier application), `generatemap.inc:120-400` (bitmap G/B encode + `cPlaceFreeForests`), `misc.script:_misc_FillPatternMaskMapBorder` + `GetFreePatternMaskModifier`, and `pattern/*.lib` group lists for palm binding.*
