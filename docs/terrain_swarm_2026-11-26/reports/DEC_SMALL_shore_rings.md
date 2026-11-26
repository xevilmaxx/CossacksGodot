# DEC_SMALL — shore rings (`frame_0012.png` chevrons at 64²)

Date: 2026-11-26
Scope: small READ-ONLY decomp, 3 passes max. One report file only. No code/Godot/git. Donor READ-ONLY; no binary executed/copied.
Donor pinned: Craft Anything active target `t_87f0f3c130b0` = `C:\Games\Cossacks 3\cossacks.exe`, 5,768,048 B, sha256 `87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c`, Deep mode (verified this ticket via `core_session_show` + `core_targets_list`; no `core_target_open/select` issued, no target changed).
Context: `reports/PHOTO_LED_chevron_ab.md` — face-promotion gate (`face_hist={0:4096}`) and forced `donor_rows/cols=1` both leave the nested diagonal chevrons unchanged; at 64² the only non-zero tile ids are 87,88,89,90,93,97,98 around water (F05: 87–90 = `sandrock1–4`, 93 = `sandsea1`, 97 = `sandsea5`, 98 = `sandsea6`). No parity claim. `[U]` = unresolved, stated exactly.

## 1. The 8-sector → sandsea rule + height/mask gates (donor verbatim)

Source (re-read read-only this ticket): `C:\Games\Cossacks 3\data\scripts\common.inc\texturemap.inc:426-530`. Every line below is `;`-commented GSC text — authoritative intent, runtime execution `[U]`.

Gradient (`:433-447`):

```
lh=GetHeightData(realx-1,realy) (:433); rh=GetHeightData(realx+1,realy) (:434)
th=GetHeightData(realx,realy-1) (:435); bh=GetHeightData(realx,realy+1) (:436)
rbh=SE (:437, unused by shore table); dirX=lh-rh (:438); dirY=th-bh (:439)
len=VectorLength(dirX,dirN,dirY) (:441); if (len>0.01) then begin (:442-443)
normalize (:444); vecangle=VectorAngle(1,0,0,dirX,0,dirY) (:445); if (dirY<0) vecangle:=-vecangle (:446-447)
```

Gate (`:463-472`):

```
if gMapMask[ix,iy].b>0 (:464) then begin
  if (height<cWaterHeight) then bWater:=True (:466-467)       // h < -0.25 (:29-30)
  else if (height<cWaterShoreHeight) then bWaterShore:=True (:469-470) // h < -0.1 (:31)
if (bWater) or (bWaterShore) then begin (:472) -> SHORE PATH
```

`[D]` Strict `<` at both bounds: `h=-0.25` is `bWaterShore`, `h=-0.1` is dry (X28 vectors 11/13). Union is `h<-0.1 ∧ mask.b>0`. `cWaterHeight=-0.25`, `cWaterShoreHeight=-0.1` (`:29-31`) are classification literals only, never plane Y (D06 §3, spec 05 §1).

Sectors (`:474-501`, `cAngle=45` at `:474`, `vecangle+=180` at `:476`):

| `vec_post` window | donor lines | name |
|---|---|---|
| `[-22.5,22.5)` | `:479-480` | `bR` |
| `[22.5,67.5)` | `:482-483` | `bRB` |
| `[67.5,112.5)` | `:485-486` | `bB` |
| `[112.5,157.5)` | `:488-489` | `bLB` |
| `[157.5,202.5)` | `:491-492` | `bL` |
| `[202.5,247.5)` | `:494-495` | `bLT` |
| `[247.5,292.5)` | `:497-498` | `bT` |
| catch-all `else bRT` | `:500-501` (`:500` bound commented out) | `bRT` |

Tile map (`:503-511`, independent `if`s in file order, later-wins in port `match`):

```
bLB->sandsea5 (:504); bRB->sandsea6 (:505); bB->sandsea1 (:506); bL->sandsea6 (:507)
bR->sandsea6 (:508); bT->sandsea1 (:509); bRT->sandsea5 (:510); bLT->sandsea6 (:511)
```

So exactly three live textures: `sandsea1` (B/T), `sandsea5` (LB/RT), `sandsea6` (R/RB/L/LT). `sandsea2/3/4` survive only as commented alternatives on the same lines. Winter: `GetSeasonType=2 → +'_winter'` (`:525-526`); `MapGetTileIndexByTileBlock` + `SetTileIndex(x,y,newtex)` (`:527-528`). Numeric ids (F05 §3): `sandsea1=93` cell `(13,5)`, `sandsea5=97` cell `(1,6)`, `sandsea6=98` cell `(2,6)`. Height overrides on the shore path (`:514-519` `|h|>2.7→rock8`, `>2.4→rock4`) are `{…}`-commented — inert. Cliff is the `else` at `:556-557` (different 6-branch pre-angle table + live `|h|` overrides `:594-601`); it does not run `+180` (X28 M2). Do not merge the tables.

## 2. How shore tiles are smoothed/weighted

Source: `C:\Games\Cossacks 3\data\gen\tilesmooth_scripts.cfg:5-66` (Item 0, first `SmoothTiles` chain), mechanism `smoothtiles.inc:63-80,84-237`.

Item 0 lists (all `[O]`):

- Wet-sand family 1: `sandsea1=1`, `sandsea2=1`, `sandsea3=1`, `sandsea4=1` (`:5-24`).
- Wet-sand family 2: `sandsea5=0.7`, `sandsea6=0.3` (`:25-36`).
- `sandrock1/3` list commented out (`:37-50`).
- Rock exclusion: `rock9=0.0`, `rock8=0.0`, `rock5=0.0` (`:51-66`).

Engine (D06 §4.2, X08): `SmoothTileMap(0,0,W,H,3)` — 3 passes, each a horizontal sweep then a vertical sweep, in place (`smoothtiles.inc:191-237`); `GetNeighbourTiles` maps the pair to the minimal-distance compatibility list (`:84-187`); `|i1-i2|=1` (+ any Prob>0) → no change; `=2` → replace one side from the middle list; else replace the farther-from-water side from `min+1`; `FindRandomTileIndex`: `rnd=RandomExt*SumProb`, first `Prob>0` entry with `rnd<cumulative` wins (`:63-80`). `TileSmoothPasses=6` (`globalparams.cfg:9`) has no readable consumer — preserved contradiction, script value 3 followed (spec 05 §2, F03).

`[D]` Smoothing only swaps already-painted adjacent ids (`93/97/98` ↔ `sandsea2/3/4` intermediates at weights 1.0 vs 0.7/0.3); it creates no sector geometry. `[U]` It does not explain photo ids 87–90 (`sandrock1–4`): the only `sandrock` smoothing list is commented out, and the live shore paint is `sandsea*` only. Whether 87–90 come from a prior cover/transition stage or the same commented block at runtime is unresolved — do not promote either story.

## 3. Which UV/alpha refkey/material shore tiles use

- `tiles.mat:385-408`: `sandsea1..6` are all `{refurl=reftile.mat; refkey=normal}` binding their own `sandseaN.dds`. No `verticalfront/side`, no `alphavert`.
- `reftile.mat:1-108` (`normal`): `Texture2Name=alpha` (`:6`), `TextureScale=1` (`:12-16`), `BlendingMode=bmTransparency` (`:17`), `tmmUser` (`:34`), `maNearest/miNearestMipmapLinear` (`:32-33`). `verticalfront` (`:120-144`, `alphavert`, scale `0.125`, `tmmEyeLinear` S=X/T=Z) and `verticalside` (`:146-170`, S=Y/T=Z) bind only `rockNvf/vs` + `sandNf/s` faces (`tiles.mat:142-213`) — never shore (F05 §5, F06 §4.2).
- Shader: `hf.pvl.smx3.frag:13-14` `color.rgb=texUnit0.rgb`, `color.a=texUnit1.a`; `:17` lighting multiply; `:50` write. `hf.pvl.sm.vert:34` `TexCoord[1]=MultiTexCoord1` (mask UV passthrough); `:30-32` texGen drives only `TexCoord[0]`. No mask math, no neighbour fetch, no threshold in any donor shader (F06 §2.2).
- Masks: `alpha.bmp` 512×256 8-bpp = 8×4 patches of 64² (F06 §3); `alphanull.bmp` all-zero bound only to ids 86/110/123 (`tiles.mat:346-359`), not to shore; `alphavert.bmp` 1024×512 eye-linear, faces only. `bmTransparency` is enum index 1 (`cossacks.exe:949234`); exact GL factors and fixed-function pass count are `[U]` (F06 U-F06-2, RV-TRN-01 verdict D). Mask is a framebuffer coverage weight, never an albedo multiplier (X17 §3.2, D08 §3.5).

So donor shore = ground-UV RGB (`sandsea1/5/6.dds`) + `alpha.bmp` 64² patch crossfade via `bmTransparency`. No eye-linear projection, no per-cell scale `0.125`, no RGB fold on this path.

## 4. Why port cell-centre triangulation + packed atlas turns the ring into nested chevrons

Port facts cited (not modified):

- Mesh: vertices at cell centres `(x+0.5)/w`, world XZ (`world3d_terrain.gd:1310-1314`); one fixed diagonal per quad `i00,i01,i10 / i10,i01,i11` (`:1415-1418`). Gradient for the sector table is centre-sampled `atan2(th-bh, lh-rh)` (`_donor_aspect_deg`, `:792-802`); flat guard is `eps 0.0001` (donor `len>0.01` at `:442` approximated).
- Shore gate in port is `water_sentinel OR height<DONOR_SHORE_H(-0.1)` (`:1326`) + art filter (`sandsea*` or low `sand*`, `:1364-1366`); donor `mask.b>0` (`:464`) is not readable here — labelled PORT APPROX in-code (`:1361-1363`). Sector function itself (`_donor_shore_name`, `:839-870`) is donor-exact including the `else→RT` catch-all (`:845`) and later-wins chain (`:861-869`). Flat deep water falls back to `sandsea1` (`:1371-1379`, PORT APPROX: donor leaves its water tile unchanged but the port has no water block).
- Atlas: 16×8 grid of 1024² cells, `cell=(id%16,id//16)` (`build_tile_index_atlas.py:84-88,151-176`; `tile_index_atlas.manifest.json`); shader `tile_rgb` (`terrain_tileindex.gdshader:329-338`) looks up `(cell+uv)/grid` with world-ground `fract(v_st*0.5)` (2 m repeat from `gc_meters_to_tile=2`) plus an invented warp `0.125*sin/cos(dot(v_st,…))` (`:334`) and half-texel inset (`:335-336`).
- Alpha: per-cell id hash `dir=id%4, variant=(id/4)%4, half=(id/16)%2, opposite=(id/64)%2` + 180° mirror (`alpha_patch_uv`, `:365-378`), sampled at `fract(v_alpha_uv)` (`:417`), then PORT-APPROX guard `mix(mix(1.0,clamp(a,0.35,1.0),0.5),1.0,step…)` (`:419`) confining flat-ground factors to `[0.675,1.0]`, folded into RGB `rgb*mix(1.0,a,mask_to_alpha)` (`:427`), `ALPHA=1.0` (`:475`). Every element after the sampler (hash patch, 0.35 floor, 0.5 strength, sentinel bypass, RGB fold) has no donor counterpart (F06 §5.2/§6).

Mechanism `[D]`: around each water body the donor rule paints a closed 8-sector ring alternating three different photographs (93/97/98). The port reproduces that alternation exactly (correct per X28), then (a) repeats each 1024² photo every 2 m of ground via `fract`, so a one-cell ring becomes several concentric art bands; (b) modulates each cell by a different id-derived 64² alpha sub-rect (`sandsea1=93` vs `5=97` vs `6=98` hash to different `row/variant/half` cells) clamped to `[0.675,1.0]` and multiplied into RGB, so adjacent ring cells get different brightness steps with no donor patch rule; (c) samples heights only at cell centres and splits every quad on the same diagonal, quantising the smooth `atan2` circle into axis-aligned stairsteps. (a)+(b)+(c) together read at close camera as large nested diagonal chevrons. This is consistent with PHOTO A/B: gating face promotion to zero and forcing the 8×8 selector to 1×1 changes only blockiness, because neither the face path (`reftile.mat` vertical*, `alphavert`) nor subcell selection is on the shore path — the ring, the packed cells, and the stub alpha rule remain.

## 5. Concrete port fix (existing files only; no invented constants, no synthetic noise)

1. `variant3d/scripts/world3d_terrain.gd` — keep the sector table byte-identical (`:839-870` already matches `:479-511`); do not retune `DONOR_CDIFF1/2`, `DONOR_SHORE_H=-0.1`, `WATER_LEVEL`, or add a foam/tint/noise term. Narrow the PORT-APPROX fallback at `:1371-1379` so flat deep-water interiors (aspect guard returns `""`, i.e. donor `len≤0.01` at `:442`) keep a single `sandsea1` fill and are never re-sectorised by neighbour gradients — one `if shore_name.is_empty(): keep sandsea1` guard, no new literal.
2. `variant3d/shaders/terrain_tileindex.gdshader` — stop inventing per-cell mask variation on the shore path: in `fragment()` (`:408-420`) bypass `alpha_patch_uv` + `:419` clamp/guard for ground cells whose `v_tile` is 93/97/98 (compare `floor(abs(v_tile))` against the three manifest ids already resolved in GDScript, no new id invented) and set `a=1.0` (opaque donor base RGB; `ALPHA=1.0` at `:475` unchanged). Rationale: the donor tile→patch rule is CONFIRMED_UNVERIFIED (F06 U-F06-1/U-F06-7); the current hash is the chevron amplifier. Neutral-1 adds no art, no noise, no threshold — it just removes the ungrounded modulation. Revisit only with neighbour-aware `MultiTexCoord1` data, never with another id hash.
3. Same shader `tile_rgb` (`:334`): delete the `0.125*sin/cos` warp (no donor counterpart; donor filtering is `maNearest/miNearestMipmapLinear`, `reftile.mat:29-37`). Keep the donor-grounded `fract(v_st*0.5)` 2 m repeat and half-texel inset. Expected effect: ring keeps correct donor ids/art per sector but renders as three flat sand photographs at uniform brightness instead of nested shaded chevrons; true water/foam work stays out of scope.

Verify by re-capturing the same close camera at 64² and comparing the PHOTO A/B ROIs (luma std, gradient, 24/48 autocorrelation, anisotropy) — ids 87–90/93/97/98 histogram must be unchanged, banding metrics must fall.

## 6. `[U]` precisely

1. Runtime execution of the whole `texturemap.inc:426-530` block (all `;`-commented; text intent `[O]`, activity `[U]`).
2. Origin of photo ids 87–90 (`sandrock1–4`) in the 64² ring: live shore paint is `sandsea*` only; the only `sandrock` smoothing list is commented (`tilesmooth_scripts.cfg:37-50`). No invented bridge story.
3. Donor tile→`alpha.bmp` patch rule, `tsDouble/ttExtended/TileXOffset=0.1/TileYOffset=0.2` arithmetic, and `tiaAlphaFromIntensity` formula (F06 U-F06-1/3).
4. `bmTransparency` GL factors/equation/pass count (F06 U-F06-2); port single `blend_mix` + RGB fold stays PORT APPROX.
5. Donor metres-per-cell for any screen-space band width; depth-space shore band is `0.15` height units (`-0.1 minus -0.25`) only.
6. Native `VectorAngle` return convention beyond X28's `atan2` derivation (cardinal vectors insensitive; diagonals assume standard `atan2`).
7. Any visual parity: no donor GPU A/B frame exists; this report makes none.

*End of DEC_SMALL shore-rings report. Exactly one file written; donor read-only; Craft Anything target `t_87f0f3c130b0` verified but never opened, executed, or copied.*
