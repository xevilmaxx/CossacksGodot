# DEC DEEP — Prop Water Exclusion (donor read-only)

Target pin: `t_87f0f3c130b0` (`C:\Games\Cossacks 3\cossacks.exe`, Deep mode).
Symptom: 4K overview shows props stamped inside water blobs; donor would never place them there.
Scope: recover exact donor stand/water exclusion gates. One report only. No code/Godot/git changes. No parity claim.

Donor text sources (all READ-ONLY via Craft Anything `core_text_read` / `native_bytes_find`):

- `C:\Games\Cossacks 3\data\scripts\lib\misc.script` (7013 lines, sha256 `1b2613cd…`)
- `C:\Games\Cossacks 3\data\scripts\common.inc\generatemap.inc` (1059 lines, sha256 `866a9223…`)
- `C:\Games\Cossacks 3\data\scripts\dmscript.global` (2400 lines, sha256 `65ddd386…`)
- `C:\Games\Cossacks 3\data\scripts\common.inc\texturemap.inc` (963 lines, context only)

---

## [O] Observed — `_misc_CheckStandPattern` has NO water/collision/topology test inside

`misc.script:3384–3521` (`_misc_CheckStandPattern`):

- Signature: `_misc_CheckStandPattern(patName, plHnd, standX, standZ, angle, doStand, bWriteToParser, pHnd): Boolean`.
- If `doStand=true`: calls `StandPatternWithAngle(...)` then optionally `_misc_WritePatternToParser`.
- Computes mask box from `GetPatternMaskWidth/Height`, `GetPatternOffsetX/Z`, angle-snapped `cx/cy`, `vMinX/vMinY/vMaxX/vMaxY`, `GetMapWidth/Height`.
- Fast path only when `(not doStand) and (angle=0)`: `step=4` sparse scan over `GetPatternMaskValue` masked by `GetPatternMaskStand / GetPatternInvMaskStand`; rejects on out-of-map or `gPatternMask[indJ,indI]=true`.
- Full path: per-cell `GetPatternMaskValue(patName, i-vMinY, j-vMinX)` masked the same way; `doStand` stamps `gPatternMask:=true`, else rejects on out-of-map or occupied.
- No call to `GetMapCollisionTag`, `GetMapCollisionTagInRadius`, `Topology*`, height, or water-mask inside this function body.

Evidence: `ev_926b544d581b415d94b58fb223f139e8006c09e9cb4f2431b70872353f1beab6` (misc.script lines 3385–3404, fresh read); prior full-function read covered 3384–3521 fast-scan + full-box logic.

`misc.script:3516–3521` (`_misc_CheckStandPatternExt`): two-pass wrapper — test pass `doStand=False`, then stamping pass `doStand=True`. Water exclusion is therefore inherited from whatever pre-marked `gPatternMask`, not re-checked here.

## [O] Observed — water exclusion is pre-marked into `gPatternMask` in `generatemap.inc:818`

`generatemap.inc:811–850` (GenerateMap `cPlaceFreeForests` block):

```pascal
for y:=0 to mapheight-1 do
for x:=0 to mapwidth-1 do
begin
   var realx := floor(lx+x);
   var realy := floor(ty+y);
   if ((not bRandomMap) and (gMapMask[x,y].forest<>cGGenForest))
     or (gMapMask[x,y].bsmooth)
     or (gMapMask[x,y].water<>cBNone)
     or (gMapMask[x,y].broad)
     or (GetMapCollisionTag(realx, realy, True)>0) then
   begin
      gPatternMask[x, y] := True;
   end;
end;
```

- This is the `water<>cBNone` gate referenced as `:818`. `gPatternMask=True` = blocked for all later `_misc_SetupPatternsByType` → `_misc_CheckStandPatternExt` calls (`plain_huge/big/medium/small`).
- Constants: `cBNone=0`, `cBWater=1` (`generatemap.inc` header block); `cGForest=1, cGGenForest=2, cGStone=3`.
- Note on storage form: lines are stored as `[*] = ;...` entries in the `.inc` file. Reported here as observed DScript text, not as executed-trace proof.

Evidence:

- `ev_9cf7258c6a32d47cf9aad6082d465a5000821535c011629848faa2240dc9c5f1` (generatemap.inc lines 811–850, the gate + `gPatternMask[x,y]:=True`)
- `ev_6bc131bd7da3b8112c24483df6d9fe5d111de8bdea177817dacded772ebc1225` (generatemap.inc offset ~790, same gate in commented-storage form)
- `ev_2d298dd2ba7b3d3e7a6732a81c55546aa2892996e700e205e402cf8e636318d6` (generatemap.inc header `cBNone/cBWater/cGForest` definitions)
- `ev_5d51c78904d591bff889daa4e9c664354ffb419498dc0c776b5cfde3f3e6cf09` (`native_bytes_find` single match `gPatternMask[x, y] := True` at file offset `0x95ac`; `cBNone` matches at `0x24c/0x435b/0x5548/0x94da`)

## [O] Observed — collision-tag water gate + waterborder disc radius `gc_WaterBorderSize=3`

`dmscript.global`:

- `gc_collisiontag_none=0`, `gc_collisiontag_bridge=10`, `gc_collisiontag_building=80`, `gc_collisiontag_terrain=101`, `gc_collisiontag_water=87`, `gc_collisiontag_waterborder=110`, `gc_collisiontag_landborder=109`, `gc_collisiontag_stretchland=85`, `gc_collisiontag_wall=95`.
- `gc_WaterBorderSize = 3`.

Evidence: `ev_d6dd2aad9f970033fce92a9c59b7c6d1f7118c61d299091d436134cec99ed3e2` (tag block head), `ev_0f1c667f9e834e371e2e4f4ca7356736138b25718104aa31a3ce54a80674f332` (`gc_WaterBorderSize=3` line), `ev_29bcdfd6dfafd0c2957579c6292c25ea9047a5ea9c45d7fef0fe9eac6adda2b4` (`native_bytes_find` `WaterBorderSize` at file offset `0x8e2d`).

`misc.script:5160+` (`_misc_SetShoresCollisionInArea`, referenced as `:5175/:5194/:5204`):

- Iterates `2*w × 2*h` half-tiles; where `GetMapCollisionTag(x,y,false)=gc_collisiontag_water` and a 3×3 neighbourhood contains tag `0` or `gc_collisiontag_bridge`, marks `border=true`.
- Then draws a disc `rad := gc_WaterBorderSize` (`i1=-rad..rad`, `minJ=Ceil(Sqrt(rad²-i1²))`, condition `i1²+j1²<rad²`): tag `0` → `MapDrawCollision(..., gc_collisiontag_landborder, ...)`, tag `water` → `MapDrawCollision(..., gc_collisiontag_waterborder, ...)`.

Evidence: `ev_ec4090c947f0a927c9a88959dcedb529eccea689877e7801bffdd72199d25203`.

`misc.script:4530+` port search (referenced as `:4544/:4553/:4590/:4599`):

- `GetMapCollisionTagInRadius(portX+dir, portZ+dir, cCollisionRad=1, True)` compared against `gc_collisiontag_water`; inner sweep `j=floor(minDist)..floor(maxDist)-1` re-probes with same radius-1 call. This is ship/port water-seeking logic, cited here only to fix the address of the `coltag_water` idiom — not a prop gate.

Evidence: `ev_d524cd2dbad1e5ec68f2c99f2f2bdbbaa47970750c5b2d6035b8e6ae08733a87`.

No `gc_collisiontag_*` string occurs in `cossacks.exe` CODE (`native_strings_find` zero matches, `ev_37a99974693a4122a99153bb615d556a30803350acf1ac07740984de362ae1cf`); tags live in donor DScript text.

## [O] Observed — `:3669/:3717` are pattern-frequency plumbing, not a water gate

Read at `misc.script:3650–3730` shows `_misc_PlacePatternByType` (trycount=8, `_misc_CheckStandPatternExt` + `_misc_PatternIncreaseFreq`) and `_misc_SetupPatternsByType` header (`mapsizeoptimise=(320*320)/(mapwidth*mapheight)`, `needed=floor(mapwidth*mapheight*freq)`, `trycount=floor(256*mapsizeoptimise)`, `x=floor(x0+RandomExt*mapwidth)`). No water/collision/topology test at those lines; exclusion is delegated to `gPatternMask` via `CheckStandPatternExt`.

## [D] Derived — which gate the port `_check_stand` / `_stamp_patterns` misses

Donor prop placement is a two-layer system:

1. **Pre-mark layer** (generatemap + shores): `gMapMask.water<>cBNone`, `broad`, `bsmooth`, and `GetMapCollisionTag>0` (which after `_misc_SetShoresCollision` includes the `waterborder` ring radius 3) all set `gPatternMask=True` before any `SetupPatternsByType` call.
2. **Stand layer** (`CheckStandPattern`): only tests `gPatternMask` occupancy + bounds.

Therefore a port `_check_stand` that tests only the pattern footprint / an initially-clear mask, without replicating layer 1, will accept cells inside water blobs and on the waterborder ring. That matches the reported 4K-overview symptom. The missing gate is not inside `CheckStandPattern` — it is the missing **pre-mark**: `water<>cBNone OR collision>0` (including `waterborder=110` ring) → blocked before stamping.

Topology: no `Topology*` call occurs in `CheckStandPattern` / `SetupPatternsByType` / pre-mark loop (`native_bytes_find` `Topology` has 53 hits in `misc.script` elsewhere — bridge/zones/updates — none in the prop stand path). Do not add a topology gate to props; the donor prop gate is mask + water + collision only.

## [D] Derived — concrete port fix recommendation for `terrain_donor_gen.gd` (NO EDIT made)

In the donor-gen pre-pass that builds the stand/occupancy mask (the function that feeds `_check_stand` / `_stamp_patterns`), add before any pattern attempts, per map cell `(x,y)`:

```gdscript
# donor: generatemap.inc:818 + shores waterborder ring
var blocked: bool = (water_id != CB_NONE) or broad or bsmooth or (collision_tag > 0)
# collision_tag must already include the shores pass:
#   water (87) ring radius gc_WaterBorderSize (3) -> waterborder (110)
#   land-side ring -> landborder (109)
# with half-tile sampling (x+i/2, y+j/2) and disc test i1*i1+j1*j1 < 9
if blocked:
    pattern_mask[x][y] = true  # = gPatternMask True = reject in _check_stand
```

Constants to hard-code (from `dmscript.global`): `CB_NONE=0`, `WATER=87`, `WATERBORDER=110`, `LANDBORDER=109`, `BRIDGE=10`, `WATER_BORDER_SIZE=3`.

Order matters: build collision (including `SetShoresCollision` waterborder discs) → pre-mark `pattern_mask` with `water<>cBNone or broad or collision>0` → then run pattern setup / `_check_stand` (mask-only test) → stamp. Do not insert a height/topology test into `_check_stand`; donor does not have one there. Verify by re-rendering the 4K overview: water blobs + 3-cell ring must contain zero new prop stamps.

## [U] Unknowns / limits

- Whether the active runtime `GenerateMap` path executes the `[*] = ;`-stored `cPlaceFreeForests` block verbatim at map-gen time, or a compiled variant with identical constants — text observed, execution not traced (no run, per constraints).
- Exact half-tile ↔ world mapping of `GetMapCollisionTag(realx, realy, True)` vs port heightfield sampling — needs owner-side same-seed diff, not claimed here.
- `CheckStandPattern` angle≠0 rotation rounding (`Round(cos)*...`) port fidelity — out of scope for water exclusion.
- No parity claim: this report recovers gate addresses/text only; visual parity after the fix remains to be measured by the owner.

---

### Evidence ledger (session `t_87f0f3c130b0`, Deep)

| id | what |
|----|------|
| `ev_926b544d581b415d94b58fb223f139e8006c09e9cb4f2431b70872353f1beab6` | misc.script 3385–3404 `_misc_CheckStandPattern` head |
| `ev_9cf7258c6a32d47cf9aad6082d465a5000821535c011629848faa2240dc9c5f1` | generatemap.inc 811–850 pre-mark gate |
| `ev_6bc131bd7da3b8112c24483df6d9fe5d111de8bdea177817dacded772ebc1225` | generatemap.inc ~790 same gate (storage form) |
| `ev_2d298dd2ba7b3d3e7a6732a81c55546aa2892996e700e205e402cf8e636318d6` | generatemap.inc header `cBNone/cBWater/cG*` |
| `ev_5d51c78904d591bff889daa4e9c664354ffb419498dc0c776b5cfde3f3e6cf09` | `gPatternMask[x,y]:=True` file offset `0x95ac`; `cBNone` offsets |
| `ev_d6dd2aad9f970033fce92a9c59b7c6d1f7118c61d299091d436134cec99ed3e2` | dmscript.global collision-tag block |
| `ev_0f1c667f9e834e371e2e4f4ca7356736138b25718104aa31a3ce54a80674f332` | `gc_WaterBorderSize=3` |
| `ev_29bcdfd6dfafd0c2957579c6292c25ea9047a5ea9c45d7fef0fe9eac6adda2b4` | `WaterBorderSize` file offset `0x8e2d` |
| `ev_ec4090c947f0a927c9a88959dcedb529eccea689877e7801bffdd72199d25203` | `_misc_SetShoresCollisionInArea` waterborder disc |
| `ev_d524cd2dbad1e5ec68f2c99f2f2bdbbaa47970750c5b2d6035b8e6ae08733a87` | port `GetMapCollisionTagInRadius` vs `gc_collisiontag_water` |
| `ev_37a99974693a4122a99153bb615d556a30803350acf1ac07740984de362ae1cf` | zero `gc_collisiontag` strings in exe CODE |
| Findings `fnd_65`–`fnd_72` | settled answers above |

*READ-ONLY donor; no Godot file edited. Port recommendation only.*
