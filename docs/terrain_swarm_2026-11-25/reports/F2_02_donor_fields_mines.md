---
id: F2-02
ticket: "TERRAIN-SWARM-WAVE-G / WAVE F2 / F2-02"
title: "Donor truth — mill farm-field decals and mine-deposit placement snap"
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_RUNNER__NO_CODE_EDIT
scope: "One report written. No code/asset/config/test/git edit, no Godot or runner job. Donor inspected READ-ONLY by text reads; no donor file copied, modified or executed."
donor_root: "C:\\Games\\Cossacks 3\\data (READ-ONLY, private use)"
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, "commented-script caveat"]
visual_parity_claim: false
---

# F2-02 — Donor truth: farm fields around mills, and magnetic mine placement

## 0. Mandate and evidence discipline

Owner directives (WAVE_G_CHARTER.md:126-141):

> *"mill fields, make them bigger so they come in contact with each other"* and
> *"mines when placed on correct spot use magnetic snap for correct positioning when building the mine on it."*

This ticket establishes **donor truth only** for both. It does **not** audit our port
(F2-01/F2-02 peer scope), does **not** propose the fix (F2-03/F2-04) and makes **no
donor-parity claim** — no donor GPU A/B frame exists (CHARTER.md:55-69, 122-131).
No runner job was submitted; G04 remains the sole Godot owner.

Labels used literally:

- **OBSERVED** — a donor file line/byte or a repo file line was read here. Where the
  shipped line is `[*] = ;`-prefixed (OSW state-script comment syntax), the label is
  **OBSERVED (commented text); runtime activation UNVERIFIED**. This is the same caveat
  DTRN-06 §1.4 and A08 §8 item 7 record for the donor's `.inc` scripts.
- **DERIVED** — deterministic arithmetic over OBSERVED values.
- **INFERRED** — plausible reading, explicitly not proven.
- **UNVERIFIED** — cannot be proven from readable donor text; do not promote.

Path convention: `D:` = `C:\Games\Cossacks 3\data\`. Repo paths are relative to the
workspace root. All line numbers are 1-based as read this session.

---

## 1. Sources

### 1.1 Donor files read directly (READ-ONLY)

| Role | Donor path / lines |
|---|---|
| Field decal descriptors | `D:terrain\decals\decals.lib:1-44`; `D:terrain\decals\decals.mat:110-115` |
| Field decal pixels (prior lane, re-cited) | `D:terrain\decals\env\envfieldd.dds`, `envfielddw.dds` via `docs/audit/PIECES/field_crops.md:24-52`, `docs/coord_swarm_2026-11-25/reports/DTRN_06_donor_grass_decals.md` claim C20 |
| Field decal placement routine | `D:scripts\lib\misc.script:4284-4306` (`_misc_PlaceFieldDecal`) |
| Field prop / scale | `D:objects\env\field.prop:1-157`; `D:game\var\envscales.cfg:1-14`; `D:scripts\lib\miscext2.script:772` |
| Mill seeding / field cluster | `D:scripts\lib\unit.script:6468-6570` (`_unit_DoSeedWheat`); `D:scripts\units\building.inc\ontagstates.inc:140-145`; `D:scripts\units\building.inc\doprogressorders.inc:120-136`; `D:scripts\common.inc\generatemap.inc:1014-1024`; `D:scripts\units\global.inc\progresseconomicai.inc:3688-3697`; `D:scripts\units\global.inc\writenewp.inc:23-29`; `readnewp.inc:41-47` |
| Units / collision constants | `D:scripts\dmscript.global:43-45, 166-185, 203-211, 308-314, 952-957`; `D:scripts\lib\misc.script:460-466, 1427-1428` |
| Mine deposits (`SetupMines`) | `D:scripts\common.inc\dogenerate.inc:522-717`; `D:scripts\common.inc\generatemap.inc` call sites per DTRN-05 §4.6; `D:game\var\generator.cfg:67-205` (via DTRN-05 C1/C11) |
| Mine prop / footprint / decal | `D:objects\env\minegold.prop` et al. and `D:game\var\envscales.cfg:16-36` (via DTRN-05 C2/C5/C6); `D:objects\buildings\eurcoa.prop:45-70,115-119`; `D:terrain\decals\decals.lib:142-163` (via DTRN-05 C14) |
| Magnetic snap (ghost + commit + finder) | `D:scripts\lib\miscext2.script:977-1019,1023-1032,1098-1133,1192-1197`; `D:scripts\gui\menu.inc\onmousedown.inc:209-254`; `D:scripts\lib\unit.script:6629-6672`; `D:scripts\lib\misc.script:4638-4663,4990-5038` |

### 1.2 Repo reports re-read (secondary, all OBSERVED as repo text)

`docs/coord_swarm_2026-11-25/reports/DTRN_05_donor_mines.md` (mines, C1–C24),
`DTRN_06_donor_grass_decals.md` (decal alpha, C18–C21),
`docs/coord_swarm_2026-11-25/decomp/DEC_05_terrain_formats.md` (§5.4 units),
`docs/terrain_swarm_2026-11-25/reports/A08_donor_truth_local.md`,
`docs/audit/PIECES/field_crops.md`, `docs/audit/PIECES/donor_decals_and_masks.md`,
`docs/terrain_swarm_2026-11-25/reports/F02_almanac_building_ghost.md` (S3 indexed patch notes),
`docs/decomp/DB_SCRIPTS.md:67,129`.

### 1.3 Online (corroboration only, not primary donor truth)

- `https://raw.githubusercontent.com/anyalink99/cossacks-3-almanac/main/internals_en/scripts/building_mechanics_evidence.md`
  — read live this session. §1: "The collision mask in `<sid>.prop`; each mask cell spans
  0.5 map cells (`gc_collision_size = 0.5`)"; "Mask scale `ScaleFactor = 1` … the visual
  `DefaultScale = 0.662` does not affect collision". §5.1: `eurgol/euriro/eurcoa`
  `peasantabsorber = 5` (up to 95). This corroborates the local footprint semantics;
  it does **not** document mine-deposit snapping.
- `https://niocreations.ru/cossacks-3-almanac/docs_en?p=recon/world/economy/building_mechanics.md`
  — fetched live; returned only the site navigation shell (no article body). Not used as evidence.
- Indexed patch notes quoted in `F02_almanac_building_ghost.md:170-180` (S3, indexed snapshot,
  **not** a live read): "Implemented algorithm to search for proper place to construct a
  building, if current position is unavailable. Now the game would propose to use proper
  place nearby" — patch 05.05.17 (1.5.4.72.5195); "Improved the building allocation
  mechanism, now players can place buildings closer to trees" — patch 14.01.17. Secondary
  context for the existence of donor placement snapping; the local scripts below are the
  authority for the mine-specific behaviour.

---

## 2. Claim table

D: paths are relative to `C:\Games\Cossacks 3\data\`.

| # | Claim | Evidence | Label | Caveat |
|---|---|---|---|---|
| F1 | `envfieldd`/`envfielddw` are 512² DXT5 decals; alpha bbox (a>8) `(17,19,494,494)` = 477×475, ~93% of tile; alpha shared byte-identically between seasons | `field_crops.md:24-52`; DTRN-06 C20/C21; `donor_decals_and_masks.md` §3 | OBSERVED (prior pixel reads) | Gold in screenshots is render-time, INFERRED |
| F2 | Decal descriptor footprint is **2×2 map cells**, season pair envfieldd↔envfielddw | `D:terrain\decals\decals.lib:37-43`; `:mat:110-115` | OBSERVED | Template `width/height`, not the runtime-scaled size |
| F3 | Runtime field decal is enlarged: `w=h=scale*goScale*1.3`, `scale=60`, angle 45° or 225° | `D:scripts\lib\misc.script:4284-4306`; `D:scripts\units\global.inc\writenewp.inc:23-29`; `readnewp.inc:41-47` | OBSERVED (misc.script active-looking; `.inc` commented text) | Units of `w` vs cell grid UNVERIFIED (§3.3) |
| F4 | A mill seeds a **7×7 = 49-node** wheat field: `cRow=7`, `cCount=49`, node spacing `size=1.6981` map cells, grid rotated 45°, base snapped to `size2=sqrt(2)*size≈2.4017` cells | `D:scripts\lib\unit.script:6475-6502` | OBSERVED (active-looking text) | Runtime activation of this function not executed here |
| F5 | Per node: 5×5 collision blocks of `gc_collision_size=0.5` rotated 45° must be clear; environment scan `rad=size*0.9*3≈4.585`, food/wood/stone clearance `rad/3≈1.528`, ore clearance `rad≈4.585` | `D:scripts\lib\unit.script:6504-6548`; `D:scripts\dmscript.global:178` | OBSERVED / DERIVED | Field nodes are food resources (`env.inc\initial.inc:48`), so food-clearance 1.528 < spacing 1.698 ⇒ sibling nodes are allowed (DERIVED) |
| F6 | Fields occur around mills because mills seed them: on build `OrderProduce(field,1)`; on map start every built mill calls `_unit_DoSeedWheat`; on completing a field order the mill seeds again; AI calls the same routine | `D:scripts\units\building.inc\ontagstates.inc:140-145`; `doprogressorders.inc:130-135`; `D:scripts\common.inc\generatemap.inc:1021-1022`; `D:scripts\units\global.inc\progresseconomicai.inc:3688-3697` | OBSERVED (commented `.inc` text); activation UNVERIFIED | Matches the reference screenshots' mill-centred rectangle (`field_crops.md:74-103`) |
| F7 | Donor reference fields are one contiguous hard-edged rotated rectangle with a square mill clearing and a second field nearby; edge 2–8 px at 720p | `field_crops.md:74-103`, §1.4 | OBSERVED (image crops, prior lane) | Not a renderer A/B; no donor GPU frame |
| F8 | `SetupMines`: 3/4/5 rings by density 0/1/2, 3 ores per ring (mng/mni/mnc), 256 angle tries, accept first candidate passing `_misc_CheckStandPatternExt` | `D:scripts\common.inc\dogenerate.inc:522-535,544-557,704-713` (re-read); DTRN-05 C10/C11/C12 | OBSERVED (commented `.inc` text); activation UNVERIFIED | Per-start call sites and exact version bands in DTRN-05 §4.6 |
| F9 | Deposit stamp is 8×10 cells / 32 of 80 occupied / 63 records; deposit visual ≈4.736×4.987 m ≈2.37×2.49 map cells; no scale jitter | DTRN-05 C5/C6/C9; `D:game\var\envscales.cfg:16-36` | OBSERVED/derived (prior lane) | Record-id→prop binding UNVERIFIED |
| F10 | Built-mine collision mask is 10×10 half-cell rows = **5×5 map cells** (diamond/octagon); its dirt decal is also 5×5 | `D:objects\buildings\eurcoa.prop:49-62`; DTRN-05 C14; almanac §1 (URL §1.3) | OBSERVED | `gc_collision_size=0.5` at `D:scripts\dmscript.global:178` |
| F11 | Donor **magnetically snaps** a mine placement to the nearest ore deposit within `1.5` map cells of the cursor, for both the ghost and the committed building; no deposit ⇒ invalid | `D:scripts\dmscript.global:206`; `D:scripts\lib\unit.script:6629-6672`; `D:scripts\lib\miscext2.script:1098-1132`; `D:scripts\gui\menu.inc\onmousedown.inc:209-254` | OBSERVED (finder active-looking; GUI callers commented `.inc` text); activation UNVERIFIED | This is donor truth about *mechanism*, not a port parity claim |
| F12 | On commit the donor also **chooses the mine type from the deposit** (gold→`eurgol`, iron→`euriro`, coal→`eurcoa`) and builds at the deposit's exact X/Z; Y comes from the deposit | `D:scripts\gui\menu.inc\onmousedown.inc:228-253`; `D:scripts\lib\miscext2.script:1122-1125` | OBSERVED (commented text) | — |
| F13 | Normal buildings use a different path: ghost normalised to `floor(m*2)/2+0.25`, then `_misc_GetAdjustedBuildingPos` tries offsets of 0.5 / 1 cells until `_misc_CanPlaceBuilding` passes | `D:scripts\lib\miscext2.script:1030-1031,1134-1141,977-1019` | OBSERVED | Mines bypass this path entirely (F11) |
| F14 | `_misc_CanPlaceBuilding` validates against the collision **mask**, a height delta `cHeightDelta=0.275`, and per-resource clearance (`wood:envRad`, `stone:envRad+0.45`, `food:envRad+0.5`, ore:`mineRad`), with a +1.5 diagonal relaxation | `D:scripts\lib\misc.script:4638-4663,4645-4647,4990-5038` | OBSERVED | The snapped-mine call passes `0,0.26,0,-1` — i.e. resource clearance deliberately disabled because the target *is* the deposit (DERIVED) |

**Not promoted:** exact decal `w` unit, runtime activity of any `[*] = ;`-prefixed
line, tile→field patch index, donor-side measured frame parity, and whether the
deposit `minegold`/`minegolds` variant is terrain-selected — all UNVERIFIED.

---

## 3. PART A — Farm fields (`envfieldd`) around mills

### 3.1 The decal asset and its donor size (OBSERVED)

- `D:terrain\decals\decals.lib:37-43`: descriptor `name = envfieldd`,
  `Decal.width = 2`, `Decal.height = 2`, `SummerLibMaterialName = envfieldd`,
  `WinterLibMaterialName = envfielddw`. Template material defaults at `:1-35`
  (`texscale = 1/1`, `epsilon = 0.01`, rotate/scale/offset capabilities `True`).
  The descriptor stores **capabilities**, not per-placement transforms
  (`donor_decals_and_masks.md` §2.3, claim 7).
- `D:terrain\decals\decals.mat:110-115` maps both names to
  `.\data\terrain\decals\env\envfieldd.dds` / `envfielddw.dds`.
- Decoded DXT5 images are 512×512; alpha min/max/mean 0/255/148.1; alpha bbox
  `(a>8) = (17,19,494,494)` = 477×475; side alpha ramp ≈12 px; opaque means
  summer `#4D442E`, winter `#756F61` (`field_crops.md:24-52`, DTRN-06 C20).
  `envfieldd`/`envfielddw` alpha is **byte-identical** — one footprint, two RGB fills
  (`donor_decals_and_masks.md` claim 13).
- `D:scripts\lib\miscext2.script:772` preloads the decal material
  `ProjectLoadDecalMaterial('envfieldd')` (OBSERVED).

### 3.2 Runtime decal scaling — the donor's own "make it bigger" factor (OBSERVED / DERIVED)

`D:scripts\lib\misc.script:4284-4306`:

```
procedure _misc_PlaceFieldDecal(goHnd : Integer; scale, angle : Float);
  const decalname = 'envfieldd';
  const texscalefix = 1.3;
  w := scale*goScale*texscalefix;
  h := scale*goScale*texscalefix;
  texscale0 := texscale0*texscalefix;
  texscale1 := texscale1*texscalefix;
  texOff0 := -(texscalefix-1)/2;   texOff1 := -(texscalefix-1)/2;
```

Callers pass `scale = 60` and `angle = 45` **or** `45+180 = 225`
(`writenewp.inc:23-29`, `readnewp.inc:41-47` — `[*] = ;`-prefixed, activation UNVERIFIED).

`goScale = GetGameObjectScaleXByHandle(goHnd)` (`:4293`). The field object's
`D:objects\env\field.prop:139-145` has `DefaultScale = 0.03605085`, `RandomScale=False`;
`D:game\var\envscales.cfg:5-11` declares `group=field`, `name=field`, `scale=0.033`,
`min=max=1` (no jitter). Note `0.033 × 1.09245 = 0.03605085`, where `1.09245` is
`cScale` in `_unit_DoSeedWheat` (`unit.script:6478`) — **DERIVED** consistency,
the exact application site of `cScale` in the inspected block is UNVERIFIED.

**DERIVED (unit caveat):** with `goScale=0.03605085`, `w = h = 60 × 0.03605085 × 1.3 ≈ 2.812`
in the same numeric space as the descriptor's `width=2`, i.e. the *live* field decal is
about **1.41× the 2×2 template**. If `w` is instead in pixels/other engine units, this
ratio does not hold — the unit of the `w` returned by `GetDecalDataByHandle` is not
documented in readable donor text (**UNVERIFIED**). The multiplier `texscalefix=1.3`
and its UV-offset compensation are OBSERVED regardless of units. The prop's own
`decalproperty` block with `DefaultDecalName = envfieldd` is **commented out**
(`field.prop:152-157`), so the script routine is the authoritative path.

### 3.3 How fields cluster around a mill (OBSERVED / DERIVED)

`D:scripts\lib\unit.script:6468-6570` `_unit_DoSeedWheat` is the cluster producer:

| Constant / rule | Donor literal | Line |
|---|---|---|
| nodes per sowing | `cRow = 7`, `cCount = cRow*cRow = 49` | `:6475-6476` |
| node spacing | `size = 1.6981` map cells (comment records `1.5`, `_misc_PixelsToTiles(80)`, `90/64`) | `:6477` |
| companion constants | `cScale = 1.09245`, `cRollAngle = 0` | `:6478-6479` |
| grid layout | `dirX = -((cRow-0.5)*size/2)+(i mod cRow)*size`; same for Z; both rotated 45° by `VectorRotateY` | `:6491-6494` |
| positional snap | `size2 = sqrt(2*size*size) ≈ 2.4017`; `px := floor((px+size)/size2)*size2`, `pz` similarly | `:6497-6499` |
| collision clearance | 5×5 grid of `gc_collision_size = 0.5` rotated 45°; reject node if `GetMapCollisionTag > 0` or outside map | `:6504-6521`; `dmscript.global:178` |
| resource clearance | `rad = size*0.9*3 ≈ 4.585`; food/wood/stone `allowdst = rad/3 ≈ 1.528`; gold/iron/coal `allowdst = rad ≈ 4.585`; reject node if a resource lies inside | `:6527-6548` |
| creation | `WriteNewP` with `fracename=gc_racename_env`, `fbasename='field'`, `fplayer=gc_playerind_env`, then cost applied | `:6550-6566` |

The mill→field link is explicit and repeated:

- On mill completion: `usage=gc_obj_usage_mill` ⇒ `_unit_OrderProduce(myHnd, cid, fieldid, 1)`
  (`D:scripts\units\building.inc\ontagstates.inc:140-145`, commented text).
- On map start: every built, alive mill gets `_unit_DoSeedWheat(goHnd, False)`
  (`D:scripts\common.inc\generatemap.inc:1014-1024`, commented text).
- On completing a `usage=gc_obj_usage_field` production order: the mill seeds again
  (`D:scripts\units\building.inc\doprogressorders.inc:123-136`, commented text).
- AI does the same via `_ai_DoSeedWheat` (`progresseconomicai.inc:3688-3697,3898-3901`).
- Field game objects are registered as `gc_resource_type_food` in
  `D:scripts\env\env.inc\initial.inc:48`, which is why the food-clearance rule applies
  between field nodes (OBSERVED via DTRN-05 C18).

**Do donor fields touch? (DERIVED / OBSERVED-image)**

1. The 49 field nodes are laid out at 1.6981-cell spacing; the *food* clearance is
   1.528 cells (`unit.script:6537` with `:6527`), i.e. **smaller than the spacing**, so
   sibling nodes are not rejected by the resource rule — the donor deliberately packs
   them closer than the clearance it applies to unrelated food/wood/stone.
2. Each node draws an `envfieldd` decal with `texscalefix=1.3` (§3.2); if the derived
   `w≈2.812` shares the node-spacing units, the decal footprint (~2.8) is larger than
   both the 1.6981 row spacing and the 2.4017 snapped diagonal spacing. That is a
   **touching/overlapping** coverage pattern, not isolated plates. The 12-px decal
   alpha ramp (`field_crops.md:37`) is an atlas feather on top of that footprint.
3. Independent visual evidence: the reference crops show **one contiguous hard-edged
   rotated rectangle** with a square dirt clearing for the mill and a second smaller
   field nearby; measured edge width 2–8 px at 720p (`field_crops.md:90-103`, §1.4).
   OBSERVED (image crop); **not** a donor GPU frame from this ticket.

Conclusion (donor truth): the donor's mill field is a **dense 7×7 cluster of field
nodes with enlarged, feathered decals whose footprints touch**, produced by the mill
itself. The exact on-screen overlap ratio is **UNVERIFIED** because the decal `w`
unit and the runtime activity of the `.inc` callers are not provable from readable text.
The donor-grounded knobs for F2-03 are therefore: node count 49, spacing 1.6981,
45° rotation + 2.4017 snap, 1.3× decal scale, 1.528 food clearance — not an invented
constant.

---

## 4. PART B — Mine deposits and placement snap

### 4.1 Deposit generation (`SetupMines`) — rings (OBSERVED, re-read)

`D:scripts\common.inc\dogenerate.inc:522-717` (all lines `[*] = ;`-prefixed in the
shipped file ⇒ OBSERVED text / activation UNVERIFIED):

- `trycount = 256` (`:525`); density `0/1/2 → rounds = 3/4/5` (`:528-532`);
  `for i := minround to rounds-1` (`:535`).
- Three ores per ring: `mng`, `mni`, `mnc`, prefixed `desert_` on desert maps
  (`:544-553`); family list from `_misc_SelectPatternListParser` (`:554`).
- Version-gated distance bands; e.g. `v≥80`, big map: `14+8R, 32+10R, 70+12R,
  22+16R`, ring 4 skipped (`:595-601`); older bands at `:561-567,575-592`; corner
  handling at `:658-697`. `dst` is in map cells (DTRN-05 C12 derived 2 m/cell from
  `gc_meters_to_tile=2`, confirmed in `dmscript.global:171`).
- 256 random angles; first candidate accepted by `_misc_CheckStandPatternExt` at
  `round(newpointx+px), round(newpointy+pz)` (`:704-713`), then frequency damped.
- Per-start near ring 0 and global rings 1.. call sites are documented in DTRN-05 §4.6.

### 4.2 Deposit and built-mine footprints (OBSERVED / DERIVED)

| Object | Footprint | Evidence |
|---|---|---|
| Ore deposit (env prop) | mesh 4.736 × 4.987 m ≈ 2.37 × 2.49 map cells, scale 0.3152, no jitter | DTRN-05 C5/C6; `D:game\var\envscales.cfg:16-36` |
| Deposit stamp | 8×10 cells, 32/80 occupied, 63 object records | DTRN-05 C9 |
| Built mine collision mask | 10×10 mask rows × `gc_collision_size=0.5` ⇒ **5×5 map cells**, octagon fill | `D:objects\buildings\eurcoa.prop:49-62`; `dmscript.global:178`; almanac §1 (URL §1.3) |
| Built-mine ground plate | `eurcoad`/`eurgold`/`eurirod`, width=height=5, summer+winter | DTRN-05 C14; `D:terrain\decals\decals.lib:142-163` |

DERIVED: the built mine (5 cells) is about **2× the deposit's visual width** (~2.4 cells),
so centring the building on the deposit places the 5×5 mask symmetrically around the
ore pile; the 5×5 dirt plate is the donor's footprint-alignment art.
The mask-cell unit (0.5 map cell) and the fact that visual `DefaultScale` does not
change collision are independently confirmed by the almanac evidence doc (§1.3).

### 4.3 The magnetic snap — exact donor chain (OBSERVED)

Constants:

- `gc_gameplay_findminepositionradius = 1.5` map cells — `D:scripts\dmscript.global:206`.
- `gc_path_minemincoldist = 3.24`, `gc_path_mincoldist = 1` — `:44-45`
  (used by the *normal* placement validator, §4.4).

**Finder (active-looking text):** `D:scripts\lib\unit.script:6629-6672`
`_unit_FindMinePositionAndType(aproxpx, aproxpy, rad, var restype, reshnd, posx, posy)`:

- `_misc_MakeListEnvironmentInRadius(aproxpx, aproxpy, rad, true, false, false, false, true, …)` (`:6643`);
- keeps only `gc_resource_type_gold/iron/coal` (`:6655`);
- selects the **nearest** by 2D distance (`:6648-6660`);
- returns `posx = GetGameObjectPositionXByHandle(reshnd)`,
  `posy = GetGameObjectPositionZByHandle(reshnd)` — the **exact deposit centre** (`:6664-6670`).

**Ghost preview:** `D:scripts\lib\miscext2.script:1098-1132` inside
`_misc_GUIProgressPickedBldUID` (commented `.inc`-style text; activation UNVERIFIED):

```
if (usage=gc_obj_usage_mine) then
begin
   _unit_FindMinePositionAndType(mx, mz, gc_gameplay_findminepositionradius, restype, reshnd, px, pz);
   if (reshnd<>0) then
   begin
      bavailable := _misc_CanPlaceBuilding(goHnd, plInd, usage, px, pz, 0, 0.26, 0, -1, True);
      py := GetGameObjectPositionYByHandle(reshnd);
      SetGameObjectPositionByHandle(goHnd, px, py, pz);       // ← ghost snapped
   end
   else
   begin
      bavailable := False;
      SetGameObjectPositionByHandle(goHnd, mx, my, mz);      // ← left at raw cursor, invalid
   end;
end
```

**Commit (click):** `D:scripts\gui\menu.inc\onmousedown.inc:209-254` (commented text):

- `:211-215` mine branch re-runs the finder with the **same 1.5-cell radius**, overwriting
  mouse coords `px,pz` with the deposit position;
- `:216-217` `reshnd=0 ⇒ bBadPosition := True` (reject);
- `:228-234` the building SID is derived from the deposit ore:
  `gold → gc_basename_minegold ('eurgol')`, `iron → 'euriro'`, `coal → 'eurcoa'`;
- `:237-240` validity re-checked at the snapped position with
  `_misc_CanPlaceBuilding(goHnd, myPlInd, usage, px, pz, 0, 0.26, 0, -1, True)`;
- `:250-253` `_player_ConstructBuildingList(..., sid, px, pz, ...)` — the building is
  created **at the deposit centre**, not at the cursor;
- `:1192-1196` (`miscext2.script`) the resulting `bavailable` drives the green/red
  construction blink (`_unit_DoConstructionBlinkGameObject`).

**Contrast — normal buildings:** `miscext2.script:1030-1031` normalises the cursor to
`floor(m*2)/2+0.25` (0.5-cell grid with 0.25 offset) and `:1134-1141` calls
`_misc_GetAdjustedBuildingPos` (`:977-1019`), which retries offsets of ±0.5 and ±1
cells until `_misc_CanPlaceBuilding` passes. Mines **bypass** this adjustment; their
position is dictated by the deposit. That is the donor's magnetic snap, not a generic
grid snap.

**Important caveat:** the GUI/`.inc` lines are `[*] = ;`-prefixed in the shipped data,
so the *activation* of these exact callers in the retail binary is **UNVERIFIED**
(same caveat as DTRN-06/A08 for donor `.inc` scripts). The finder and validator functions
themselves are present as active-looking text. The 2017 patch note quoted in
`F02_almanac_building_ghost.md:170-180` (indexed secondary source) independently
corroborates that donor placement uses a "search for proper place … propose to use
proper place nearby" algorithm, but it is not mine-specific.

### 4.4 Footprint / clearance validation (OBSERVED)

`D:scripts\lib\misc.script:4638-4663,4990-5038` `_misc_CanPlaceBuilding`:

- footprint width/height from `GetGameObjectCollisionMaskWidth/HeightByHandle`
  (`:4646-4647`) — collision **mask**, not mesh silhouette (almanac §1.3);
- `cHeightDelta = 0.275` (`:4645`); cells whose height spread exceeds it are rejected
  (`:4990-4995`);
- environment scan at `renvminerad = max(envRad, mineRad)` (`:4662`, `:5002-5004`);
  per-resource clearance at `:5012-5020`: `wood → envRad`, `stone → envRad+0.45`,
  `food → envRad+0.5`, `gold/iron/coal → mineRad`; diagonal contacts get `+1.5`
  relaxation (`:5024-5028`); rejection if `distx < dist` and `disty < dist` (`:5029-5032`);
- standard callers pass `colRad=gc_path_mincoldist=1`, `unitRad=0.26`,
  `envRad=0.5`, `mineRad=gc_path_minemincoldist=3.24` (e.g. `miscext2.script:981,1075,1086`;
  `dmscript.global:44-45`). AI uses the same values (`progresseconomicai.inc:3434`).

**DERIVED:** the snapped-mine call deliberately passes `colRad=0, envRad=0, mineRad=-1`
(§4.3). A negative `mineRad` disables the ore-clearance rejection (there is no
"too close to a deposit" check) because the deposit is the intended target; a normal
building would be rejected within 3.24 cells of ore. This is why a mine can be placed
*on* a deposit while every other building cannot.

### 4.5 Donor-grounded targets for F2-04 (not a fix proposal)

Stated as donor facts for the follow-up owner; no implementation here:

1. Snap radius from cursor: **1.5 map cells** (`dmscript.global:206`).
2. Snap target: nearest gold/iron/coal resource **object centre** in that radius
   (`unit.script:6629-6672`), for both ghost and commit.
3. No deposit in radius ⇒ placement invalid and ghost stays at cursor, red
   (`miscext2.script:1128-1132`).
4. 5×5 built-mine mask / 5×5 dirt plate centred on the deposit
   (`eurcoa.prop:49-62`, DTRN-05 C14) — footprint alignment is centre-to-centre,
   not corner-to-corner.
5. Mine type can follow the deposit ore (`onmousedown.inc:228-234`) — a donor behaviour
   the port should decide to match or explicitly diverge from.

---

## 5. UNVERIFIED register (do not promote)

1. Runtime activity of every `[*] = ;`-prefixed `.inc` script line
   (`dogenerate.inc`, `generatemap.inc`, `writenewp.inc`, `readnewp.inc`,
   `onmousedown.inc`, `ontagstates.inc`, `doprogressorders.inc`, `miscext2.script`
   GUI branch). Authoritative *intent* text, not proven execution.
2. The unit of the decal `w/h` returned by `GetDecalDataByHandle` vs the 2-cell
   descriptor `width/height`; therefore the exact decal overlap ratio
   (`≈2.812` derived under one reading) is UNVERIFIED.
3. Whether every one of the 49 field nodes from a single sowing survives the
   environment scan (depends on creation/list timing inside the loop) — not measured.
4. Exact on-screen mine/field appearance: no donor gameplay A/B frame is available
   (`mines_display.md §1.5`, DTRN-05 §8/Q8). Field gold is render-time INFERRED.
5. Record-id → prop binding inside the 63-record mine stamp (DTRN-05 Q1).
6. Which terrain/season selects `minegold`/`minegolds` (DTRN-05 Q2).
7. Whether `envscales.cfg field scale=0.033` is applied before or after `cScale=1.09245`
   (only the product matches `field.prop` scale).
8. Online almanac page fetch returned navigation only; no article text was available
   from `niocreations.ru` this session. The GitHub evidence doc was read live.

---

## 6. Summary

**Fields.** Donor `envfieldd` is a 512² DXT5 decal with a 2×2-cell descriptor footprint
and a byte-identical winter alpha pair. The runtime deliberately enlarges it by
`texscalefix = 1.3` (`misc.script:4284-4306`) and places it at 45°/225°. A mill produces
a **7×7 = 49-node** wheat field: spacing 1.6981 map cells, 45° rotation, 2.4017-cell
position snap, 5×5 half-cell collision clearance, and — decisively — a **1.528-cell
food-resource clearance that is smaller than the 1.6981 node spacing**, so sibling field
nodes are allowed to sit almost two cells apart. Reference crops show the result as one
contiguous hard-edged rotated rectangle with a mill clearing. That is the donor-grounded
basis for "bigger, touching" fields; the exact overlap ratio stays UNVERIFIED (§5.2).

**Mines.** Donor `SetupMines` stamps 3/4/5 rings × 3 ores with 256 angle tries
(`dogenerate.inc:522-717`); deposits are ~2.4-cell visual props inside 8×10-cell stamps,
while the built mine is a 5×5-cell collision mask with a 5×5 dirt plate. Placement is
**magnetically snapped**: within 1.5 cells of the cursor the game finds the nearest
gold/iron/coal deposit, moves the ghost (and later the built foundation) to that exact
X/Z and the deposit's Y, re-validates with zero/negative clearance radii, and rejects a
click with no deposit in range (`dmscript.global:206`; `unit.script:6629-6672`;
`miscext2.script:1098-1132`; `onmousedown.inc:209-254`). Normal buildings instead use a
0.5-cell grid normalisation plus a ±0.5/±1 adjustment search. No donor-parity claim is
made; no port file was touched and no runner job was submitted.

*End of F2-02. One report written. DONOR_TRUTH only; activation of commented scripts,
unit of decal `w`, and all visual parity remain UNVERIFIED. No code, asset, config,
test, git or Godot-runner state changed.*
