---
id: X22
ticket: "TERRAIN-SWARM-2026-11-26 / Wave X / X22 — implementation-ready verbatim translation spec for DONOR field sowing"
agent: "X22 (worker subagent, 30-agent DONOR-FIRST terrain swarm)"
owner_file: docs/terrain_swarm_2026-11-26/reports/X22_field_sowing_translation.md
created: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_ASSET_EDIT__NO_GODOT_JOB
labels: [O, D, I, U, "PORT APPROXIMATION"]
scope: "Exactly one repo file written (this report). Donor opened READ-ONLY via latin-1 (iso-8859-1) text decode; no donor binary executed, copied, or committed. No app/** or variant3d/** edit; no .gd/.gdshader/.json/.cfg/.import/asset/test/git mutation; no Godot process and no godot_runner.py job."
donor_root: "C:\\Games\\Cossacks 3\\data (READ-ONLY, private use)"
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
parity_claim: false
parity_guard: "NO DONOR PARITY CLAIM. No donor GPU A/B frame exists and no Godot capture was made by X22. 'Donor-faithful' below means literal agreement with a cited authored donor path:line or a deterministic derivation from such lines. Every runtime activation of a donor [; ]-commented .inc caller is [U]. Everything implemented from this report remains PORT APPROXIMATION until a real A/B frame lands (CHARTER.md:41,44,125)."
verification_passes: 4
encoding: "donor .script/.inc/.prop/.lib read with [System.Text.Encoding]::GetEncoding('iso-8859-1') (latin-1); 1-based line numbers as read this session"
sources_read:
  - docs/terrain_swarm_2026-11-26/CHARTER.md; docs/terrain_swarm_2026-11-26/SWARM_BOARD.md
  - docs/terrain_swarm_2026-11-26/reports/F07_mill_fields.md
  - docs/terrain_swarm_2026-11-26/spec/08_FIELDS_AND_PROPS.md; docs/terrain_swarm_2026-11-26/spec/10_STAGE_ORDER.md
  - docs/terrain_swarm_2026-11-26/reports/V09_2d_order_transplant.md
  - docs/terrain_swarm_2026-11-26/reports/D07_resources_bin.md; V12_resource_spec.md; V01_unverified_resolution.md (grep-level cross-check)
  - C:\Games\Cossacks 3\data\scripts\lib\unit.script:6468-6570, :1685-1700 (latin-1, full verbatim)
  - C:\Games\Cossacks 3\data\scripts\units\building.inc\ontagstates.inc:132-152; common.inc\generatemap.inc:1002-1030; units\building.inc\doprogressorders.inc:124-140; units\global.inc\progresseconomicai.inc:3682-3702; units\global.inc\writenewp.inc:18-34; units\global.inc\readnewp.inc:38-50 (latin-1)
  - C:\Games\Cossacks 3\data\scripts\dmscript.global:168-182; scripts\lib\misc.script:4282-4310; objects\env\field.prop:25-160; terrain\decals\decals.lib:36-45; scripts\common.inc\dogenerate.inc:720-980 targeted scan (latin-1)
  - variant3d/scripts/game.gd:2715-2774; variant3d/scripts/world3d_entities.gd:300-321 (read-only)
  - variant3d/assets/** file-existence + byte-size census (read-only)
---

# X22 — verbatim translation spec: donor field sowing (`_unit_DoSeedWheat`)

## 0. Method, labels, and the four-pass contradiction reconciliation

**[O]** observed (literal on-disk line, latin-1 decode). **[D]** derived (deterministic arithmetic over [O]). **[I]** inference without a donor A/B. **[U]** UNVERIFIED. **PORT APPROXIMATION** = explicit port substitute for an unrecovered donor rule.

Four passes were run before any number or verdict in this report was declared:

| Pass | Instrument | What it established |
|---|---|---|
| P1 | `read` tool on the five governing reports (CHARTER, BOARD, F07, spec §08, V09) | Scope, label discipline, prior-art claims to re-verify |
| P2 | PowerShell `[System.IO.File]::ReadAllLines(..., iso-8859-1)` on `lib\unit.script` (12,381 lines) and every caller/constant file | Full verbatim routine `:6468-6570` and all trigger text |
| P3 | Targeted regex scans (no human paraphrase): `roll|cScale|cRollAngle|bAuto|random|bCollision|bStaticObjects` inside `:6468-6570`; `field|food|SeedWheat|gc_basename_field` inside `dogenerate.inc:720-980` | Confirmed four contradictions below and the no-food-rect finding |
| P4 | Independent `[math]` recomputation of `size2`, `rad`, `rad/3`, rotated corners, and `gc_pixels_to_tile / gc_pixels_to_meter` | All derived constants in §4 reproduced to 6 decimals |

**Multi-pass contradiction register (owner directive, CHARTER.md:86-93).** Every anomaly below was re-run with a second instrument; nothing was skipped after one sighting.

| # | Contradiction / anomaly | Pass 1 | Pass 2 | Pass 3 / final verdict |
|---|---|---|---|---|
| X-C1 | **`roll` is declared but never assigned** (`unit.script:06554`), then written into `TPlayerArgs(parg).fdirx` (`:06559`). It is *not* an RNG draw. | Full routine read: `var roll : Float;` with no assignment. | Regex scan of `:6468-6570`: exactly 2 hits — declaration `:06554` and use `:06559`. No `Random`/`RandomExt` anywhere in the routine. | **[U] UNVERIFIED.** Do **not** invent a random yaw for the field. The donor value of `fdirx` is unspecified in readable text; treat as "no donor-defined roll" and let the receiving engine's zero/default apply, explicitly labelled. This corrects any reading that implies the sow routine itself consumes RNG. |
| X-C2 | **`bCollision` / `bStaticObjects` are never initialised to `False`** (`unit.script:06504`, `:06525`). Each is only ever set `True` on rejection (`:06518`, `:06544`). | Full read: no `:= False`. | Regex scan confirms only `True` assignments plus the two `not ...` reads (`:06523`, `:06550`). | **[U]** language-level zero-initialisation of DScript locals is not recoverable from text. Implementation must **explicitly initialise both to `false`** — this is a formalisation of the only sane reading, not a new donor constant. |
| X-C3 | **`cScale = 1.09245` and `cRollAngle = 0` are dead constants** (`unit.script:06478-06479`). F07 E1 lists them among the routine's constants. | Full read shows declaration only. | Regex scan: zero further occurrences in `:6468-6570`. | **[O] dead text.** They are **not** used by sowing; **do not** carry them into the pseudocode as active scale/yaw. Field yaw comes from `field.prop:149` (`DefaultRollAngle = 45`), not `cRollAngle`. |
| X-C4 | **`bAuto` parameter is inert** (`unit.script:06470`); its only branch is commented (`:06472-06473`). Callers pass `False, False, False, True` (AI). | Signature + comment in full read. | Regex scan: `bAuto` occurs only at signature and the commented line. All four caller sites re-read verbatim (§3.2). | **[O] text / [U] runtime.** The comment claims "seed less wheat" for auto, but no code implements it. Treat all four callers as the same behaviour; never invent an auto-thinning rule. |
| X-C5 | **Metres-per-cell semantics.** F07 §7 R1 marks `gc_meters_to_tile = 2` as [U] ("2 tiles per metre" would invert everything). | F07 Risk 1 + `dmscript.global:0171` single hit. | Second instrument: `dmscript.global:0170` `gc_pixels_to_meter = 26.6666666` and `:0172` `gc_pixels_to_tile = 53.3333333`. Ratio `53.3333333 / 26.6666666 = 2.00000000375`. Ratio `1 / gc_tiles_to_pixels(0.01875) = 53.3333`. | **[D] semantic resolved in donor text:** one map tile = **2 metres**, i.e. `gc_meters_to_tile` is *metres per tile*, so F07's 3.3962 m spacing and 3.0566 m clearance stand. **[U]** remains only for engine-side consumption of that constant. F07's inversion risk is therefore downgraded, not erased. |
| X-C6 | **"Guaranteed food rects in `SetupStartingResources`"** — `spec/10_STAGE_ORDER.md:50,53` and A02/GUIDE4 assert them; D07/V12 deny them. | spec §10 read verbatim. | V12 `C-V4` (`:82`) rules "**D07 wins**: zero food rects"; D07 `:375,398` agrees; spec §08:80-81 agrees. | Third direct instrument: latin-1 scan of donor `dogenerate.inc:720-980` (the full `SetupStartingResources` body) for `field\|food\|SeedWheat\|gc_basename_field` → **zero hits**. **[O] D07/F07/X22 all agree: no food rects.** A02/spec §10 row 50/53 is stale and must be corrected by COORD. |
| X-C7 | F07 E19 gives the baked rotor JSON path as `models/anim/common/buildings/mill_rotor.json`. | F07 E19 / :116 citation. | Filesystem census. | **[O] path correction:** actual file is `variant3d/assets/models/anim/buildings/mill_rotor.json`; the PNGs are at `models/anim/common/buildings/mill_rotor.png` and `models/tex/shared/buildings/mill_rotor.png`. The `.../common/...json` path does not exist. |

---

## 1. Executive summary

1. **[O] The donor sowing routine is `_unit_DoSeedWheat(const goHnd: Integer; const bAuto: Boolean)` at `C:\Games\Cossacks 3\data\scripts\lib\unit.script:6470-6570`.** It is a **unit/building runtime effect**, not a pattern stamp: 7×7 = 49 candidate nodes, step `size = 1.6981` map cells, rotated **45°** twice (lattice and collision probe), base snapped by `size2 = √(2·size²) = 2.401476` cells with asymmetric `+size` X / `+size·0.5` Z offsets, and **5 gold per accepted field** (`unit.script:1691-1693`). Verbatim text is in §3.1.
2. **[O] Exact extent [D]:** pre-rotation coordinate range `−5.518825 … +4.669775` cells; after 45° rotation the four corners are `(−7.804797, 0)`, `(6.604059, 0)`, `(−0.600369, ±7.204428)`. The farthest node centre is **7.804797 cells ≈ 15.61 m** from the origin — a **rotated square of half-diagonal ~7.8 cells**, not a circular radius. The 25-sample collision probe extends a further ±1 cell (±√2 ≈ 1.4142 cells after rotation) around each node.
3. **[O] Trigger chain (all four callers are `; `-commented `.inc` text → activation [U]):** mill construction completion orders one field (`ontagstates.inc:140-145`); a completed field order calls `_unit_DoSeedWheat(myHnd, False)` (`doprogressorders.inc:130-135`); map start with `cSeedWheat` seeds every built, alive mill (`generatemap.inc:1009-1025`); the AI loops `aidata.milllist` with `True` (`progresseconomicai.inc:3688-3697`). The called unit is the **mill** (`usage = gc_obj_usage_mill`), the produced object is the **field** (`sid = gc_basename_field`, `usage = gc_obj_usage_field`).
4. **[O]/[D] RNG:** the sow routine itself draws **no random number**. The only randomness in the creation chain is downstream: `writenewp.inc:25` `if (random>0.5)` picks decal angle `45` vs `225`, echoed at `readnewp.inc:43`; `field.prop:33` `RandomMeshName = True` plus `RandomMaterialName` lists (`:49-76`) pick crop art. `roll` at `unit.script:06554` is an **uninitialised local**, not RNG (X-C1).
5. **[D] Scale contract:** `gc_pixels_to_tile / gc_pixels_to_meter = 53.3333333 / 26.6666666 = 2.0000000` (`dmscript.global:170,172`) ⇒ 1 tile = 2 m (X-C5). Donor node spacing = `1.6981 × 2 = 3.3962 m`; donor food/wood/stone clearance = `1.52829 × 2 = 3.05658 m`; ore clearance = `4.58487 × 2 = 9.16974 m`. The port's `3.0 m` clash (`game.gd:2755`) is **close to donor-correct**, while the port's `step = 1.6981·TILE·0.5 = 1.6981 m` (`game.gd:2740`) is **half donor spacing** — both labelled **PORT APPROXIMATION** (§4.3).
6. **[O] Assets:** 10 converted European mill OBJs, 1 converted field OBJ (`field1.osm`), 1 crop texture (`field1.dds`), 2 field decals (summer/winter), and a baked rotor PNG are usable; missing are death stages, rus/tur mill families, winter crop textures, `field2/3.osm`, `.oss`/`.aaf` geometry, and the pump family — exact paths in §5.
7. **[O]/[D] Stage order:** field sowing is a **building effect after mill completion**, not a generation pattern stage. It belongs after prop/mine placement and mill instantiation in the fresh module, as a separate runtime-triggered stage; `SetupStartingResources` has zero food rects (X-C6; D07/V12/spec §08:80-81). `frt_*` (248) is forest and `k_pump_*` (15) is decorative pumps (F07 E14/E15) — neither stamps fields.
8. **[I] No parity claim.** No donor GPU A/B frame and no Godot capture were produced by X22.

---

## 2. Evidence table

| ID | Source (donor path:line, latin-1) | Observation | Label |
|---|---|---|---|
| X-E01 | `scripts\lib\unit.script:6468-6570` | Full `_unit_DoSeedWheat` body — quoted verbatim in §3.1. | [O] |
| X-E02 | `unit.script:6475-6479` | `cRow=7`, `cCount=cRow*cRow=49`, `size=1.6981` (commented alternatives `1.5`, `PixelsToTiles(80)`), `cScale=1.09245`, `cRollAngle=0`. | [O] (last two dead — X-C3) |
| X-E03 | `unit.script:6481-6486` | `sid = gc_basename_field`; `id = _unit_ConvertObjSIDToID(TObj(pobj).cid, sid)`; `maphalfwidth/height = GetMapWidth/Height div 2`. | [O] |
| X-E04 | `unit.script:6489-6494` | `for i:=0 to cCount-1`; `dirX = -((cRow-0.5)*size/2)+(i mod cRow)*size`; same `dirZ` with `i div cRow`; `VectorRotateY(dirX,dirY,dirZ,45)`. | [O] |
| X-E05 | `unit.script:6495-499` | `px/pz` from `GetGameObject*Position*ByHandle`; `size2 = sqrt(2*size*size)`; `px := floor((px+size)/size2)*size2`; `pz := floor((pz+size*0.5)/size2)*size2`. | [O] |
| X-E06 | `unit.script:6506-6521` | `for j:=0 to 25-1` (5×5); `dirx=(-2+j div 5)*gc_collision_size`, `dirz=(-2+j mod 5)*gc_collision_size`; `VectorRotateY(...,45)`; `GetMapCollisionTag(cx,cy,True)>0` or `Abs(cx)>=maphalfwidth` or `Abs(cy)>=maphalfheight` → reject. | [O] |
| X-E07 | `scripts\dmscript.global:0178` | `gc_collision_size = 0.5`. | [O] |
| X-E08 | `unit.script:6527-6548` | `rad := size*0.9*3 = 4.58487`; `_misc_MakeListEnvironmentInRadius(xOff,yOff,rad,true,true,true,true,true,gIntegerList)`; by `TRes(pRes).itype`, food/wood/stone → `allowdst := rad/3 = 1.52829`, gold/iron/coal → `allowdst := rad`; `VectorDistance(...) < allowdst` → reject. | [O] |
| X-E09 | `unit.script:6552-6566` | Cost gate `_unit_CanApplyCostByID`, `GetCountOfPlayers>=gc_playerind_env`, client/replay allowance; writes `fposx/fposz/fdirx/fracename/fbasename/fplayer` into `TPlayerArgs`, calls `PlayerExecuteStateByHandle(plHnd,'WriteNewP')`, then `_unit_ApplyCostByID`. | [O] |
| X-E10 | `unit.script:1691-1693` | `'field'` object: `objbase.price[gc_resource_type_gold] := 5`, `objprop.usage := gc_obj_usage_field`. | [O] |
| X-E11 | `scripts\dmscript.global:0170,0171,0172,0173` | `gc_pixels_to_meter=26.6666666`; `gc_meters_to_tile=2`; `gc_pixels_to_tile=53.3333333`; `gc_tiles_to_pixels=0.01875`. | [O]; ratio [D] |
| X-E12 | `scripts\units\building.inc\ontagstates.inc:140-145` | On mill completion (`usage=gc_obj_usage_mill`): convert `gc_basename_field` to `fieldid`, `_unit_OrderProduce(myHnd,arg_obj.cid,fieldid,1)`. | [O] text / [U] runtime |
| X-E13 | `scripts\common.inc\generatemap.inc:1009-1025` | `if (cSeedWheat) and (not bRandomMap)` and full player count: for every built, non-dead mill → `_unit_DoSeedWheat(goHnd, False)`. | [O] text / [U] runtime |
| X-E14 | `scripts\units\building.inc\doprogressorders.inc:130-135` | On order completion with `usage=gc_obj_usage_field`: `_unit_DoSeedWheat(myHnd, False)`, then amount 0 and `_unit_RemoveOrder(myHnd,0)`. | [O] text / [U] runtime |
| X-E15 | `scripts\units\global.inc\progresseconomicai.inc:3688-3697` | `_ai_DoSeedWheat(plind)` loops `aidata.milllist` → `_unit_DoSeedWheat(goHnd, True)`. | [O] text / [U] runtime |
| X-E16 | `scripts\units\global.inc\writenewp.inc:23-29`; `readnewp.inc:41-47` | `if (base=gc_basename_field) then if (random>0.5) then _misc_PlaceFieldDecal(gohnd,60,45) else _misc_PlaceFieldDecal(gohnd,60,45+180)` — **the RNG use in the field chain**. | [O] text / [U] runtime |
| X-E17 | `scripts\lib\misc.script:4286-4306` | `_misc_PlaceFieldDecal(goHnd,scale,angle)`: `decalname='envfieldd'`, `rollangle=angle`, `goScale=GetGameObjectScaleXByHandle`, `w=h=scale*goScale*texscalefix(1.3)`, `texscale0/1 *= 1.3`, `texOff0/1 = -(1.3-1)/2 = -0.15`. | [O] |
| X-E18 | `objects\env\field.prop:30-38,47-76,139-150` | `DefaultMeshName=field1.mesh`, `RandomMeshName=True`, 3 usable meshes; 7-entry summer/winter material lists, `UseSeasonMaterial=True`; `DefaultScale = 0.03605085` on X/Y/Z; `DefaultRollAngle=45`; decal binding commented out (`:152-157`). | [O] |
| X-E19 | `terrain\decals\decals.lib:38-43` | `envfieldd`: summer `envfieldd`, winter `envfielddw`, `Decal.width=2`, `height=2`. | [O] |
| X-E20 | `scripts\common.inc\dogenerate.inc:720-980` targeted scan | Zero occurrences of `field`, `food`, `SeedWheat`, `gc_basename_field` in `SetupStartingResources` (X-C6). | [O] scan |
| X-E21 | `scripts\lib\unit.script:6472-6473,06554,06559` | Auto branch commented; `roll` uninitialised → `fdirx`; dead `cScale`/`cRollAngle`. | [O]; semantics [U] |
| X-E22 | repo `variant3d/scripts/game.gd:2722-2767` | Port `_sow_field_ring`: `SOW_ROW=7`, `SOW_GOLD=5`, cap 49, `step=1.6981*TILE*0.5`, `Vector2(cc-rr,cc+rr)*step`, clash `1.5*TILE`, no collision grid, no ore check, no decal call. | [O] port; **PORT APPROXIMATION** |
| X-E23 | repo `variant3d/scripts/world3d_entities.gd:311-319` | `FIELD_STEP_M=1.6981`, `FIELD_SPAN_M=√2·1.6981=2.40148`, decal paths, `FIELD_EMISSION_WARM` donor tint with port energy 0.22 flagged PORT APPROX. | [O] port |
| X-E24 | repo file census `variant3d/assets/**` | 10 mill OBJs, `field.obj`, `field.png`, 2 decals, 2 rotor PNGs + JSON (actual JSON path corrected in X-C7) all present with byte sizes listed in §5. | [O] |
| X-E25 | `docs/.../reports/D07_resources_bin.md:375,398`; `V12_resource_spec.md:82`; `V01_unverified_resolution.md:154` | Cross-report agreement: no food rects in `SetupStartingResources`; fields are runtime object/decal rule, no standalone generation stage. | [O] secondary, re-verified by X-E20 |

---

## 3. Verbatim donor excerpt (latin-1 decode)

### 3.1 `_unit_DoSeedWheat` — `C:\Games\Cossacks 3\data\scripts\lib\unit.script:6468-6570`, complete and unabridged

Line numbers are 1-based. Text is reproduced byte-for-byte as decoded with `iso-8859-1`; the two non-ASCII/cyrillic comments elsewhere in the file do not occur in this range.

```
06468: // _unit_DoSeedWheat
06469: //
06470: procedure _unit_DoSeedWheat(const goHnd : Integer; const bAuto : Boolean);
06471: begin
06472:    //if (bAuto) then
06473:    //seed less wheat then when we press doseed manually. Done same way as in original Cossacks.
06474: 
06475:    const cRow = 7;
06476:    const cCount = cRow*cRow;
06477:    const size = 1.6981;//1.5;//_misc_PixelsToTiles(80); //90, 64
06478:    const cScale = 1.09245;//0.965;
06479:    const cRollAngle = 0;//30;
06480: 
06481:    var sid : String = gc_basename_field;
06482:    var pobj : Pointer = _unit_GetTObj(goHnd);
06483:    var id : Integer = _unit_ConvertObjSIDToID(TObj(pobj).cid, sid);
06484: 
06485:    var maphalfwidth : Integer = GetMapWidth div 2;
06486:    var maphalfheight : Integer = GetMapHeight div 2;
06487: 
06488:    var i : Integer;
06489:    for i:=0 to cCount-1 do
06490:    begin
06491:       var dirX : Float = -((cRow-0.5)*size/2)+(i mod cRow)*size;
06492:       var dirY : Float;
06493:       var dirZ : Float = -((cRow-0.5)*size/2)+(i div cRow)*size;
06494:       VectorRotateY(dirX, dirY, dirZ, 45);
06495:       var px : Float = GetGameObjectPositionXByHandle(goHnd);
06496:       var pz : Float = GetGameObjectPositionZByHandle(goHnd);
06497:       var size2 : Float = sqrt(2*size*size);// _misc_PixelsToTiles(114);// 90
06498:       px := floor((px+size)/size2)*size2; // making discreat and adjustment for better view
06499:       pz := floor((pz+size*0.5)/size2)*size2; // making discreat and adjustment for better view
06500: 
06501:       var xOff : Float = px+dirX;
06502:       var yOff : Float = pz+dirZ;
06503: 
06504:       var bCollision : Boolean;
06505:       var j : Integer;
06506:       for j:=0 to 25-1 do // size of wheat field to scan is 5x5 collision blocks rotated at 45 degree
06507:       begin
06508:          var dirx : Float = (-2+j div 5)*gc_collision_size;
06509:          var diry : Float;
06510:          var dirz : Float = (-2+j mod 5)*gc_collision_size;
06511:          VectorRotateY(dirx, diry, dirz, 45);
06512: 
06513:          var cx : Float = xOff+dirx;
06514:          var cy : Float = yOff+dirz;
06515: 
06516:          if (GetMapCollisionTag(cx, cy, True)>0) or (Abs(cx)>=maphalfwidth) or (Abs(cy)>=maphalfheight) then
06517:          begin
06518:             bCollision := True;
06519:             break;
06520:          end;
06521:       end;
06522: 
06523:       if (not bCollision) then
06524:       begin
06525:          var bStaticObjects : Boolean;
06526: 
06527:          var rad : Float = size*0.9*3;
06528:          _misc_MakeListEnvironmentInRadius(xOff, yOff, rad, true, true, true, true, true, gIntegerList);
06529:          for j:=gIntegerList.GetCount-1 downto 0 do
06530:          begin
06531:             var envHnd : Integer = gIntegerList.Get(j);
06532:             var allowdst : Float;
06533:             var pRes : Pointer = _res_GetTRes(envHnd);
06534:             if (pRes<>nil) then
06535:             begin
06536:                case TRes(pRes).itype of
06537:                   gc_resource_type_food, gc_resource_type_wood, gc_resource_type_stone : allowdst := rad/3;
06538:                   gc_resource_type_gold, gc_resource_type_iron, gc_resource_type_coal : allowdst := rad;
06539:                end;
06540: 
06541:                var tmpDist : Float = VectorDistance(xOff, 0, yOff, GetGameObjectPositionXByHandle(envHnd), 0, GetGameObjectPositionZByHandle(envHnd));
06542:                if (tmpDist<allowdst) then
06543:                begin
06544:                   bStaticObjects := True;
06545:                   break;
06546:                end;
06547:             end;
06548:          end;
06549: 
06550:          if (not bStaticObjects) then
06551:          begin
06552:             if (GetCountOfPlayers>=gc_playerind_env) and ((_unit_CanApplyCostByID(TObj(pobj).cid, id, TObj(pobj).pl) or (_net_IsClient or _net_IsReplay))) then
06553:             begin
06554:                var roll : Float;
06555:                var plHnd : Integer = GetGameObjectPlayerHandleByHandle(goHnd);
06556:                var parg: Pointer = StateMachineGetArgDataByInd(GetPlayerStateMachineHandle(plHnd), gc_argplayer_plr);
06557:                TPlayerArgs(parg).fposx:=xOff;
06558:                TPlayerArgs(parg).fposz:=yOff;
06559:                TPlayerArgs(parg).fdirx:=roll;
06560:                TPlayerArgs(parg).fracename:=gc_racename_env;
06561:                TPlayerArgs(parg).fbasename:=sid;
06562:                TPlayerArgs(parg).fplayer:=gc_playerind_env;
06563:                PlayerExecuteStateByHandle(plHnd, 'WriteNewP');
06564:                var fieldHnd: Integer = TPlayerArgs(parg).fresult;
06565:                _unit_ApplyCostByID(TObj(pobj).cid, id, TObj(pobj).pl);
06566:             end;
06567:          end;
06568:       end;
06569:    end;
06570: end;
```

**Reading notes.** [O] The 5 gold charge is not in this routine; it is the object price at `unit.script:1691-1693` applied here by `_unit_ApplyCostByID` (`:06565`). [D] `fieldHnd` at `:06564` is assigned and never used — the routine does not track or list the created fields. [D] The two `break` statements (`:06519`, `:06545`) exit only the inner `j` loops. [O] No random call appears anywhere in `:6468-6570` (X-C1/X-E16).

### 3.2 Exact trigger callers (verbatim, latin-1) — which unit calls it and when

`ontagstates.inc:140-145` — mill **finishes construction**, orders one field produce:

```
00140:       [*] = ;      if (gObjProp[arg_obj.cid][arg_obj.id].usage=gc_obj_usage_mill) then
00141:       [*] = ;      begin
00142:       [*] = ;         var sid : String = gc_basename_field;
00143:       [*] = ;         var fieldid : Integer = _unit_ConvertObjSIDToID(arg_obj.cid, sid);
00144:       [*] = ;         _unit_OrderProduce(myHnd, arg_obj.cid, fieldid, 1);
00145:       [*] = ;      end;
```

`doprogressorders.inc:130-135` — that field **order completes**, reseed:

```
00130:       [*] = ;         if (gObjProp[cid][id].usage=gc_obj_usage_field) then
00131:       [*] = ;         begin
00132:       [*] = ;            if (bProcess) then
00133:       [*] = ;            _unit_DoSeedWheat(myHnd, False);
00134:       [*] = ;            TOrderInfo(porderinfo).amount := 0;
00135:       [*] = ;            _unit_RemoveOrder(myHnd, 0);
```

`generatemap.inc:1009-1025` — map start with `cSeedWheat` and not a random map, **every built alive mill**:

```
01009:       [*] = ;if (cSeedWheat) and (not bRandomMap) then
01010:       [*] = ;begin
01011:       [*] = ;   if (GetCountOfPlayers>=gc_MaxPlayerCount) then
01012:       [*] = ;   begin
01013:       [*] = ;      var i, j : Integer;
01014:       [*] = ;      for i:=0 to gc_MaxPlayerCount-1 do
01015:       [*] = ;      begin
01016:       [*] = ;         var plHnd : Integer = GetPlayerHandleByIndex(i);
01017:       [*] = ;         for j:=GetPlayerGameObjectsCountByHandle(plHnd)-1 downto 0 do
01018:       [*] = ;         begin
01019:       [*] = ;            var goHnd : Integer = GetGameObjectHandleByIndex(j, plHnd);
01020:       [*] = ;            var pobj : Pointer = _unit_GetTObj(goHnd);
01021:       [*] = ;            if (pobj<>nil) and (gObjProp[TObj(pobj).cid][TObj(pobj).id].usage=gc_obj_usage_mill) and (TObj(pobj).bbuilt) and (not TObj(pobj).bdead) then
01022:       [*] = ;            _unit_DoSeedWheat(goHnd, False);
01023:       [*] = ;         end;
01024:       [*] = ;      end;
01025:       [*] = ;   end;
01026:       [*] = ;end;
```

`progresseconomicai.inc:3688-3697` — **AI economic tick**, one call per mill in `aidata.milllist`:

```
03688:       [*] = ;procedure _ai_DoSeedWheat(plind :Integer);
03689:       [*] = ;begin
03690:       [*] = ;   _misc_ProfilerBegin('_ai_DoSeedWheat');
03691:       [*] = ;   var i : integer;
03692:       [*] = ;   for i:=0 to gPlayer[plind].aidata.milllist.GetCount-1 do
03693:       [*] = ;   begin
03694:       [*] = ;      var goHnd : Integer = gPlayer[plind].aidata.milllist.Get(i);
03695:       [*] = ;      _unit_DoSeedWheat(goHnd, True);
03696:       [*] = ;   end;
03697:       [*] = ;   _misc_ProfilerEnd('_ai_DoSeedWheat');
03698:       [*] = ;end;
```

**[O]/[U] Verdict:** the invoking object is always the **mill** (building with `gc_obj_usage_mill`); invocation moments are (1) completion of construction via an indirect produce order, (2) completion of that produce order, (3) map initialization for pre-built mills, (4) AI economic tick. **All four lines are `; `-commented**; retail activation is [U]. Note the human chain is two-step (`OrderProduce` → `DoSeedWheat`), so a direct "on build complete → 49 fields" port hook is a **PORT APPROXIMATION** of the trigger timing.

### 3.3 Downstream RNG and decal (verbatim, latin-1)

`writenewp.inc:23-29` (identical at `readnewp.inc:41-47`) and `misc.script:4286-4306` establish how the created field is dressed:

```
00023:       [*] = ;   if (base=gc_basename_field) then
00024:       [*] = ;   begin
00025:       [*] = ;      if (random>0.5) then
00026:       [*] = ;      _misc_PlaceFieldDecal(gohnd, 60, 45)
00027:       [*] = ;      else
00028:       [*] = ;      _misc_PlaceFieldDecal(gohnd, 60, 45+180);
00029:       [*] = ;   end;
```

```
04288:    const decalname = 'envfieldd';
04289:    var rollangle : Float = {GetGameObjectRollAngleByHandle(goHnd)+}angle;
04293:    var goScale : Float = GetGameObjectScaleXByHandle(goHnd);
04296:    GetDecalDataByHandle(decHnd, w, h, x, z, texOff0, texOff1, scale0, scale1, texScale0, texScale1, texAng, eps, texRot, texScale, texOff, texOffRot, libMat, decName);
04298:    const texscalefix = 1.3;
04299:    w := scale*goScale*texscalefix;
04300:    h := scale*goScale*texscalefix;
04301:    texscale0 := texscale0*texscalefix;
04302:    texscale1 := texscale1*texscalefix;
04303:    texOff0 := -(texscalefix-1)/2;
04304:    texOff1 := -(texscalefix-1)/2;
04305:    SetDecalDataByHandle(decHnd, w, h, x, z, texOff0, texOff1, scale0, scale1, texScale0, texScale1, texAng, eps, texRot, texScale, texOff, texOffRot, libMat, decName);
```

[D] `texOff0 = texOff1 = -0.15`. [U] the unit of `GetDecalDataByHandle().w/h` is not documented in readable data; `60 × 0.03605085 × 1.3 = 2.812` is a derived reading only (F07 §4.5).

---

## 4. GDScript pseudocode implementation (donor constants only)

### 4.1 Constants and their sole donor authority

Every literal below is cited; **no port-invented constant appears in the donor-derived core**.

| Constant | Value | Units | Authority |
|---|---|---|---|
| `ROW` | `7` | count | `unit.script:6475` |
| `COUNT` | `7*7 = 49` | count | `unit.script:6476` |
| `SIZE` | `1.6981` | map cells | `unit.script:6477` |
| `ROT_DEG` | `45` | degrees | `unit.script:6494`, `:6511` |
| `COLLISION_SIZE` | `0.5` | map cells | `dmscript.global:0178` |
| `PROBE_N` | `25` (5×5) | count | `unit.script:6506` |
| `RAD` | `SIZE*0.9*3 = 4.58487` | cells | `unit.script:6527` |
| `CLEAR_SOFT` | `RAD/3 = 1.52829` | cells | `unit.script:6537` |
| `CLEAR_ORE` | `RAD = 4.58487` | cells | `unit.script:6538` |
| `PRICE_GOLD` | `5` | gold / field | `unit.script:1692` |
| `METERS_PER_CELL` | `2` | m / cell | `dmscript.global:0171`; confirmed via `:0170,:0172` (X-C5) |
| `DECAL_SCALE_ARG` | `60` | argument | `writenewp.inc:26-28` |
| `TEXSCALEFIX` | `1.3` | multiplier | `misc.script:4298` |
| `TEXOFF` | `-(1.3-1)/2 = -0.15` | UV | `misc.script:4303-4304` |
| `FIELD_DEFAULT_SCALE` | `0.03605085` | prop scale | `field.prop:141-143` |
| `FIELD_ROLL_DEG` | `45` | degrees | `field.prop:149` |
| `DECAL_ANGLE` | `45` or `225` | degrees | `writenewp.inc:26,28`; chosen by `random>0.5` at `:25` |

Explicitly **excluded** (X-C3/X-C1): `cScale=1.09245`, `cRollAngle=0`, and `roll` are dead/undefined donor text and must not become implementation constants.

### 4.2 Pseudocode — literal transplant of `unit.script:6470-6570`

```gdscript
# X22 pseudocode. Cell units are DONOR map cells (1 cell = 2 m, dmscript.global:171).
# PORT APPROXIMATION as a whole: no donor A/B frame exists.
const ROW := 7                       # unit.script:6475
const COUNT := ROW * ROW             # :6476 -> 49
const SIZE := 1.6981                 # :6477
const ROT_DEG := 45.0                # :6494, :6511
const COLLISION_SIZE := 0.5          # dmscript.global:178
const PROBE_N := 25                  # :6506
const RAD := SIZE * 0.9 * 3.0        # :6527 -> 4.58487
const CLEAR_SOFT := RAD / 3.0        # :6537 -> 1.52829
const CLEAR_ORE := RAD               # :6538 -> 4.58487
const GOLD_PER_FIELD := 5            # :1692
const METERS_PER_CELL := 2.0         # dmscript.global:171 (+ :170/:172, X-C5)

func rotate_y_45(x: float, z: float) -> Vector2:
    # VectorRotateY(x, y, z, 45) at unit.script:6494 and :6511.
    # Standard Y-rotation: x' = x*cos + z*sin ; z' = -x*sin + z*cos.
    var c: float = cos(deg_to_rad(ROT_DEG))
    var s: float = sin(deg_to_rad(ROT_DEG))
    return Vector2(x * c + z * s, -x * s + z * c)

func do_seed_wheat(mill_hnd: int, _b_auto: bool) -> int:
    # bAuto is inert in readable donor text (X-C4); never invent auto-thinning.
    var sid: String = GC_BASENAME_FIELD                     # :6481
    var id: int = convert_obj_sid_to_id(mill_cid, sid)      # :6483
    var map_half_w: int = int(get_map_width()) / 2          # :6485
    var map_half_h: int = int(get_map_height()) / 2         # :6486
    var size2: float = sqrt(2.0 * SIZE * SIZE)              # :6497 -> 2.4014760503
    var px0: float = get_object_x(mill_hnd)                 # :6495
    var pz0: float = get_object_z(mill_hnd)                 # :6496
    # Snap is recomputed INSIDE the i loop in the donor (:6497-6499). It is
    # loop-invariant, so hoisting is deterministic; keep it here for clarity.
    var px: float = floor((px0 + SIZE) / size2) * size2     # :6498
    var pz: float = floor((pz0 + SIZE * 0.5) / size2) * size2  # :6499 (+SIZE*0.5 Z asymmetry)
    var made: int = 0

    for i in COUNT:                                          # :6489
        var dir_x: float = -((ROW - 0.5) * SIZE / 2.0) + float(i % ROW) * SIZE   # :6491
        var dir_z: float = -((ROW - 0.5) * SIZE / 2.0) + float(i / ROW) * SIZE   # :6493 (integer div)
        var r: Vector2 = rotate_y_45(dir_x, dir_z)           # :6494
        var x_off: float = px + r.x                          # :6501
        var y_off: float = pz + r.y                          # :6502

        # --- 5x5 rotated collision probe (:6504-6521) ---
        var b_collision: bool = false                        # X-C2: explicit init
        for j in PROBE_N:                                    # :6506
            var dx: float = (-2 + j / 5) * COLLISION_SIZE    # :6508 (integer div)
            var dz: float = (-2 + j % 5) * COLLISION_SIZE    # :6510
            var pr: Vector2 = rotate_y_45(dx, dz)            # :6511
            var cx: float = x_off + pr.x                     # :6513
            var cy: float = y_off + pr.y                     # :6514
            if get_map_collision_tag(cx, cy, true) > 0 or absf(cx) >= float(map_half_w) or absf(cy) >= float(map_half_h):  # :6516
                b_collision = true                           # :6518
                break                                        # :6519
        if b_collision:
            continue                                         # :6523 negation

        # --- environment/resource clearance (:6525-6548) ---
        var b_static: bool = false                           # X-C2: explicit init
        var env_list: Array[int] = make_list_environment_in_radius(x_off, y_off, RAD)  # :6528
        for j in range(env_list.size() - 1, -1, -1):         # :6529 (downto 0)
            var env_hnd: int = env_list[j]                   # :6531
            var res = get_tres(env_hnd)                      # :6533
            if res == null:
                continue                                     # :6534
            var allow_dst: float = -1.0
            match res.itype:                                 # :6536
                FOOD, WOOD, STONE:
                    allow_dst = CLEAR_SOFT                   # :6537
                GOLD, IRON, COAL:
                    allow_dst = CLEAR_ORE                    # :6538
            if allow_dst < 0.0:
                continue  # donor `case` leaves allowdst undefined for other itypes [U]
            var ex: float = get_object_x(env_hnd)            # :6541
            var ez: float = get_object_z(env_hnd)            # :6541
            var d: float = vector_distance(x_off, 0.0, y_off, ex, 0.0, ez)  # :6541
            if d < allow_dst:                                # :6542
                b_static = true                              # :6544
                break                                        # :6545
        if b_static:
            continue                                         # :6550 negation

        # --- cost gate + creation (:6552-6566) ---
        if get_count_of_players() >= GC_PLAYERIND_ENV and (can_apply_cost(mill_cid, id, mill_player) or net_is_client_or_replay()):  # :6552
            # fdirx := `roll` at :06559 is UNDEFINED donor text (X-C1).
            # Do NOT substitute a random yaw here; use the engine default and label PORT APPROX.
            player_execute_state(
                get_player_state_handle(mill_hnd), "WriteNewP",
                {"fposx": x_off, "fposz": y_off,
                 "fracename": GC_RACENAME_ENV, "fbasename": sid,
                 "fplayer": GC_PLAYERIND_ENV})               # :6556-6563
            apply_cost(mill_cid, id, mill_player)            # :6565 (5 gold, :1692)
            made += 1

    return made
```

### 4.3 Scale relationship to `gc_meters_to_tile = 2` — and the port clashes

| Quantity | Donor value | Metres (×2) | Port value | Verdict |
|---|---|---|---|---|
| node spacing | `1.6981` cells (`unit.script:6477`) | **3.3962 m** [D] | `1.6981·TILE·0.5 = 1.6981 m` (`game.gd:2740`) | **PORT APPROXIMATION — half-scale** |
| soft clearance | `rad/3 = 1.52829` cells (`:6537`) | **3.05658 m** [D] | `1.5·TILE = 3.0 m` (`game.gd:2755`) | **PORT APPROXIMATION — numerically near donor** but omits ore tier |
| ore clearance | `rad = 4.58487` cells (`:6538`) | **9.16974 m** [D] | absent | **PORT APPROXIMATION — missing rule** |
| snap pitch | `size2 = √2·size = 2.401476` cells (`:6497`) | 4.802952 m | absent (`game.gd:2743-2745` uses `r-7/2`, `c-7/2`) | **PORT APPROXIMATION** |
| lattice centre | `−0.600369` cells after rotation [D] | −1.200738 m | centred at 0 (`cc-rr`, `cc+rr`) | **PORT APPROXIMATION** |
| field count | up to 49 (`:6476`) | — | ≤49 cap but ≤24 observed (F2-01) | **PORT APPROXIMATION** |
| collision probe | 25 half-cell samples rotated 45° (`:6506-6511`) | ±1.4142 m reach | `is_blocked()` single point (`game.gd:2746`) | **PORT APPROXIMATION** |
| footprint | `58.518572 × 0.03605085 ≈ 2.1096 m` [D] (`field.prop:141-143`, F07 E12) | decal `60 × 0.03605085 × 1.3 = 2.812` in undefined units [U] | `FIELD_SPAN_M = √2·1.6981 = 2.40148 m` (`world3d_entities.gd:311-312`) | **PORT APPROXIMATION** |

**[D] Sibling survival:** `CLEAR_SOFT = 1.52829 < SIZE = 1.6981`, so a previously sown field (registered as a food resource at `env.inc/initial.inc:48`, via F07 §4.1) is *inside* its neighbour's clearance threshold and does not reject it. Do **not** add a field-vs-field exclusion in the fresh module.

**[I] Determinism/stream note:** the donor sow routine has no RNG draw; the only draws are in the downstream `WriteNewP` field-decal choice (`writenewp.inc:25`) and prop mesh/material randomisation (`field.prop:33,48`). A fresh module that adds an RNG draw per node changes the shared stream and can shift later pattern placement — keep the sow RNG account separate and pin the seed (V09 §5 step 1 / H06 §4.2). **[U]** unrun.

---

## 5. Asset inventory — use these / missing ones (exact paths)

`D:` below = `C:\Games\Cossacks 3\data` (READ-ONLY). Repo paths are relative to the workspace root. Sizes are byte counts from the read-only census (X-E24).

### 5.1 Converted assets to use

| Runtime asset (exact repo path) | Bytes | Donor source (exact path) | Role / authority |
|---|---:|---|---|
| `variant3d/assets/models/obj/shared/buildings/mil.obj` | 244,468 | `D:\actors\buildings\commoneur\eurmil.osm` | finished mill tower; `eurmil.actor:2-3` |
| `.../mil1.obj` | 52,206 | `...\eurmil1.osm` | build stage 1 |
| `.../mil2.obj` | 85,977 | `...\eurmil2.osm` | build stage 2 |
| `.../mil3.obj` | 152,079 | `...\eurmil3.osm` | build stage 3 |
| `.../mil4.obj` | 268,816 | `...\eurmil4.osm` | build stage 4 |
| `.../mila.obj` | 168,608 | `...\attach\eurmila.osm` | scaffold, finished |
| `.../mil1a.obj` | 252,451 | `...\attach\eurmil1a.osm` | scaffold build 1 |
| `.../mil2a.obj` | 374,479 | `...\attach\eurmil2a.osm` | scaffold build 2 |
| `.../mil3a.obj` | 347,098 | `...\attach\eurmil3a.osm` | scaffold build 3 |
| `.../mil4a.obj` | 365,834 | `...\attach\eurmil4a.osm` | scaffold build 4 |
| `variant3d/assets/models/tex/shared/buildings/mil.png` | 3,998,174 | `D:\materials\buildings\commoneur\eurmil.dds` | summer body albedo, 2048² RGBA |
| `variant3d/assets/models/obj/shared/terrain/field.obj` | 44,551 | `D:\actors\env\field1.osm` | crop mesh (546 verts / 544 faces, identical bbox) |
| `variant3d/assets/models/tex/shared/terrain/field.png` | 48,365 | `D:\materials\env\field1.dds` | summer crop albedo, 512×256 |
| `variant3d/assets/terrain/deco_png/envfieldd.png` | 615,507 | `D:\terrain\decals\env\envfieldd.dds` | summer ground decal (`decals.lib:38-43`) |
| `variant3d/assets/terrain/deco_png/envfielddw.png` | 659,209 | `D:\terrain\decals\env\envfielddw.dds` | winter twin; alpha byte-identical to summer (F07 E9) |
| `variant3d/assets/models/anim/common/buildings/mill_rotor.png` | 36,081 | derived bake of `D:\actors\buildings\commoneur\attach\eurmilanim.oss` | 320² sail sheet — **PORT APPROX stand-in** |
| `variant3d/assets/models/tex/shared/buildings/mill_rotor.png` | 36,081 | same bake, importable copy | **PORT APPROX stand-in** |
| `variant3d/assets/models/anim/buildings/mill_rotor.json` | 107 | derived rotor metadata | path corrected from F07 E19 (X-C7) |
| `variant3d/assets/terrain/decals_dds/eurmild.dds` / `eurmildw.dds` | 1,398,256 each | `D:\terrain\decals\buildings\eurmild{,w}.dds` | byte-identical donor DDS copies — **charter/licensing flag for COORD** (F07 §7 R5) |
| `variant3d/assets/sounds/amb_windmill.ogg` | 981,042 | `D:\sounds\ambient\amb_windmill.ogg` | windmill ambient bed |

**[O] Port code hooks already present:** `variant3d/scripts/game.gd:2715` (`_sow_field_ring` on finished mill), `:2722-2727` (ROW/GOLD/cap), `variant3d/scripts/world3d_entities.gd:313-314` (both decal paths), `:302-306` (donor-decoded rotor hub/axis). All are labelled PORT APPROX where they deviate (§4.3).

### 5.2 Missing assets — exact donor paths, no port counterpart found

| Donor path (exact) | Role | Port status |
|---|---|---|
| `D:\actors\buildings\commoneur\eurmil_death1.osm` (174,580 B) | destroyed stage 1 (`eurmil.actor:20-22`) | **missing** [O] |
| `D:\actors\buildings\commoneur\eurmil_death2.osm` (136,748 B) | destroyed stage 2 (`eurmil.actor:23-26`) | **missing** [O] |
| `D:\actors\buildings\commoneur\attach\eurmil_death1a.osm` / `eurmil_death2a.osm` (20,620 / 29,380 B) | destroyed scaffold | **missing** [O] |
| `D:\actors\buildings\commonrus\rusmil.osm` (49,508 B) + `rusmil1..4.osm` + `rusmil_death{1,2}.osm` + `attach\rusmila.osm` | Russian mill family | **missing** [O] |
| `D:\actors\buildings\commontur\turmil.osm` (256,228 B) + `turmil1..4.osm` | Turkish mill family | **missing** [O] |
| `D:\objects\buildings\{rusmil,turmil}.prop` | rus roll 45 / tur roll 135, distinct masks | **missing** [O] |
| `D:\materials\buildings\commoneur\eurmilw.dds` (5,592,560 B); `D:\materials\buildings\common{rus,tur}\rusmil{,w}.dds`, `turmil{,w}.dds` | winter / rus / tur body art | **missing** [O] |
| `D:\actors\env\field2.osm` (23,932 B), `field3.osm` (26,308 B) | crop mesh variants 2/3 | **missing** [O] |
| `D:\materials\env\field.dds`, `field2.dds`, `field3.dds`, `field4.dds` (174,928 B each) | referenced summer crop albedos | **missing** [O] |
| `D:\materials\env\fieldw.dds`, `field1w.dds`, `field2w.dds`, `field3w.dds`, `field4w.dds` (174,928 B each) | winter crop albedos (`field.prop:68-76`) | **missing** [O] — metadata `prop_winter_materials.json:114-133` says `port_art_exists:false` |
| `D:\materials\env\field5\6\7{,w}.dds` | authored but **unreferenced** by any prop | deliberately out of scope [O] |
| `D:\actors\buildings\commoneur\attach\eurmilanim.oss` (55,388 B); `...\commonrus\attach\rusmilanim.oss` (45,708 B) | skinned sail geometry, 251 keys @30 fps | **missing as geometry** [O]; replaced by baked PNG |
| `D:\animations\aaf\eurmilanim.aaf`, `rusmilanim.aaf` (30 B each) | `"idle",1,249,morph` | **missing** [O] |
| `D:\actors\buildings\commoneur\attach\eurmilanim.actor` (373 B); `D:\objects\buildings\attach\eurmilanim.prop` (1,577 B) | sail bindings | **missing** [O] |
| `D:\objects\env\pump.prop`, `pump1.prop`, `pump2.prop`, `pump3.prop`; `D:\actors\env\pump.actor`; `D:\materials\env\pump.dds` (349,672 B) | decorative pump family (`k_pump_*`, 15 patterns) | **missing** [O] — ornamental, **not** a crop mechanism (F07 §4.3) |
| `D:\objects\env\field.prop` | donor prop (scale 0.03605085, roll 45, season lists) | not converted; port sim uses 0.6 m radius (`game.gd:2763`) — **PORT APPROXIMATION** |
| `D:\objects\buildings\eurmil.prop` | 5×5 diamond collision mask, roll 45 | not converted; port uses radius 2.0 — **PORT APPROXIMATION** |

**[O] Pattern families are not field sources:** 710 `.pattern` files / `pattern.lib` contain **0** field/mill names; `frt_*` (248) = forest, `k_pump_*` (15) = pumps (F07 E15). `donor_patterns.json` holds 146 `frt` relief-cell records and **0** pump records; no field/mill family exists (F07 E20). Pattern conversion alone cannot place fields.

---

## 6. Implications for `spec/08_FIELDS_AND_PROPS.md`

1. **[O] §8 is correct and should be promoted from "from F07" to an implementation-ready rule block.** Its 7×7/1.6981/45°/√2-snap/~7.8-cell/5-gold summary (`:69-71`) matches the verbatim routine in §3.1 exactly. Add the two new resolutions: (a) metres-per-cell is now **[D]** (`dmscript.global:170-172`, X-C5), and (b) the sow routine has **no RNG**; RNG is downstream at `writenewp.inc:25` and `field.prop:33` (X-E16/X-E18).
2. **[O]/[D] §4 ("Mill fields are decals, not terrain tile ids") is confirmed but incomplete.** The full chain is: mill building → produce order → `_unit_DoSeedWheat` → `WriteNewP` object → `_misc_PlaceFieldDecal` ground decal + field prop mesh. Both the object and the decal must exist; a decal-only or a pattern-only implementation is a **PORT APPROXIMATION**.
3. **[D] §5 staged order needs one new stage, placed by trigger, not by pass index.** A04 P0–P6 order (prop silhouette → shore rocks → forests/stones → mines → **mill fields** → swamps/lakes → decor) is a *render-stage* order. Sowing is a **runtime effect fired by mill state**, so in the fresh `terrain_donor_*` pipeline it must be invoked after mills are instantiated and on each of the four donor trigger moments (§3.2), not baked into the static generation pattern passes. Stage 5 ("mill fields") should call a seeding function, not a pattern stamp. **[U]** runtime activation of all four donor callers is still commented text.
4. **[O] §8:80-81 is confirmed by a third independent instrument (X-E20).** `SetupStartingResources` has zero food/field placements. **COORD action required:** `spec/10_STAGE_ORDER.md:50` ("Starting resources ... port food rects") and `:53` ("Fields ... `envfieldd`, food rects ... D1:720-980"), plus `A02_algorithm.md:637,643` and the older research files, are stale. V12 `C-V4` already ruled "D07 wins" (`V12:82`). No new food-rect stage should be added to the fresh module.
5. **[D] §4.5/§8 unit line should state the derived clearance explicitly:** 3.3962 m spacing, 3.0566 m soft clearance, 9.1697 m ore clearance, all under the 2 m/cell reading that is now donor-text-derived (`dmscript.global:170-172`). The port's 3.0 m clash and 1.6981 m half-step must stay visibly labelled **PORT APPROXIMATION** until A/B.
6. **[O] Asset line (`:77-79`) is verified file-by-file in §5.** Add the X-C7 path correction for `mill_rotor.json` and the note that the byte-identical donor DDS decals under `decals_dds/` are existing port state needing COORD adjudication (charter §4 "never commit donor binaries").
7. **[I] Season/stage guidance:** keep any port `ripe/growing/regrowing/depleted` machine as an explicitly labelled gameplay layer; the donor has no readable time-based crop stage (F07 §4.1, V01 U11). Use `field.prop:68-76` season material swap and `decals.lib:40-41` winter decal when winter art is converted; until then label the reuse of summer art **PORT APPROXIMATION**.

---

## 7. Risks

| # | Risk | Evidence / label | Mitigation |
|---|---|---|---|
| R1 | **Runtime activation.** Every mill→seed caller is `; `-commented `.inc` text; the routine itself is active-looking script text but retail execution is unproven. | X-E12..X-E15, X-C4 [U] | Binary anchor (D01/D07) before treating 49 nodes as observed behaviour; keep "donor-faithful" narrow = authored text only. |
| R2 | **Uninitialised `roll` / boolean locals.** A literal port that copies `roll` or omits `:= false` can produce undefined yaw or reversed gating. | X-C1, X-C2 [U] | Explicitly init booleans false; do not invent a random yaw; label the engine default **PORT APPROXIMATION**. |
| R3 | **Scale inversion.** If 1 cell were 0.5 m (the F07 Risk 1 inversion), all metre figures halve/double. | X-C5 [D] text / [U] engine | Ratio derived from two independent donor constants; confirm in binary (D02/D05) before changing `game.gd:2740`. |
| R4 | **Trigger timing.** Port hooks `_sow_field_ring` directly on `finished`; donor does mill-complete → `OrderProduce` → order-complete → `DoSeedWheat`. | `game.gd:2715` vs `ontagstates.inc:140-145`, `doprogressorders.inc:130-135` [O]/[I] | Implement the two-step order chain or label the direct hook **PORT APPROXIMATION**; do not claim identical timing. |
| R5 | **RNG stream shift.** Adding a per-node random draw where donor has none shifts all later pattern draws. | X-C1, X-E16, V09 §5 [I]/[U] | Separate RNG account; pin seed; A/B one axis; never add a draw inside the 49-node loop. |
| R6 | **Count vs spacing conflict.** 49 nodes at 3.3962 m need ~15.61 m half-diagonal free space; a mill + roads + 2 m building clearance may block most candidates on real maps. | X-E02/X-E20 [D]/[U] | No synthetic "guarantee"; let donor rejection rules decide; measure on a seeded map only. |
| R7 | **Decal unit undefined.** `GetDecalDataByHandle().w/h` has no documented unit; `2.812` and `2.1096 m` are readings. | X-E17 [U] | Keep `FIELD_SPAN_M`/decal scaling as **PORT APPROXIMATION**; do not tune to a guessed overlap ratio. |
| R8 | **Licensing/charter.** Byte-identical donor DDS files already in `variant3d/assets/terrain/decals_dds/`. | X-E24, F07 §7 R5 [O] | COORD adjudicates keep/replace/remove; X22 changed nothing. |
| R9 | **Stale spec contradiction.** `spec/10:50,53` still asserts food rects; implementing from it would create a non-donor stage. | X-C6 [O] | COORD to correct §10; fresh module follows `spec/08 §8` + D07/V12/X22. |
| R10 | **No A/B frame.** Any "closer to donor" wording can be over-read as parity. | CHARTER.md:41,44,125 [U] | Every output labelled **PORT APPROXIMATION**; no % verdict; no donor frame claim. |

---

## 8. UNVERIFIED register (do not promote)

1. **[U]** Retail-binary reachability of `_unit_DoSeedWheat` and all four `[*] = ;` callers (X-E12..X-E15).
2. **[U]** Donor value/meaning of the uninitialised local `roll` written to `fdirx` (`unit.script:06554,06559`) — X-C1.
3. **[U]** DScript local-variable initialisation for `bCollision` / `bStaticObjects` (`unit.script:06504,06525`) — X-C2.
4. **[U]** Engine-side consumption of `gc_meters_to_tile = 2` (`dmscript.global:0171`); the *semantic* is [D] from `:0170,:0172`, but no consumer was found.
5. **[U]** Unit of `GetDecalDataByHandle().w/h` (`misc.script:4296-4300`) and therefore exact crop/decal overlap.
6. **[U]** Whether all 49 candidates survive the donor environment scan on a shipped map (blocked tiles, water, cliffs, roads, treasury); creation/list timing inside the loop.
7. **[U]** Real per-map field count and whether sibling fields are actually registered as food resources in time to be skipped by later nodes.
8. **[U]** Which random `field1..4` material a node receives (`field.prop:49-76`, `random>0.5` at `writenewp.inc:25`); warm `field`/`fieldw` emission may never be drawn.
9. **[U]** Any time-based crop-growth state machine compiled into the binary (none in readable text).
10. **[U]** DLC/expansion additions of mill/field patterns (F10 scope) — current 710-file scan says none.
11. **[U]** Visual effect of port emission energy 0.22 (`world3d_entities.gd:320-321`) and the 3D decal UV binding (A04 E13).
12. **[U]** Same-seed determinism of the transplanted rule — true by construction, never run.
13. **[U] No donor GPU A/B frame and no Godot capture** were produced by X22 — **no parity claim**.

---

## 9. Open questions

- **Q1 (D01/D07):** can the binary anchor `_unit_DoSeedWheat` and confirm which mill states actually reach it? This decides whether R1 stays [U].
- **Q2 (D02/D05):** can the engine confirm `gc_meters_to_tile` as metres-per-cell, closing the last part of X-C5?
- **Q3 (COORD):** should the fresh module implement the two-step `OrderProduce → DoSeedWheat` trigger (donor text) or keep the direct `finished` hook labelled **PORT APPROXIMATION**?
- **Q4 (COORD):** `spec/10_STAGE_ORDER.md:50,53` and A02:637/643 still assert food rects — approve the correction to D07/V12/X22 wording?
- **Q5 (A03/V07):** convert `field2/3.osm` and all `field*w.dds`, or keep one mesh and label the rest **PORT APPROXIMATION**?
- **Q6 (A03):** convert `eurmilanim.oss` to a real skinned mesh with its 251-key morph, or retain the baked PNG stand-in with an explicit label?
- **Q7 (COORD):** adjudicate the byte-identical donor DDS decals under `variant3d/assets/terrain/decals_dds/` (R8).
- **Q8 (QA):** with 49 donor-spaced nodes, will a ~2.11 m crop plus a 2.812-unit decal visually touch at 3.3962 m? Needs a donor frame or, failing that, a clearly labelled render probe.
- **Q9 (A04):** decal angle `45` vs `225` is RNG-chosen downstream (`writenewp.inc:25`); should the fresh module consume one draw per node for this, and if so from which RNG account?

---

## 10. Summary (five lines)

1. **[O] X22 transcribed `unit.script:6468-6570` verbatim (latin-1): 7×7=49 nodes, 1.6981-cell step, 45° lattice + 45° 5×5 collision probe, `size2=√2·size` snap, 7.8048-cell half-diagonal, 5 gold each; four commented callers identify the mill as the invoking building.**
2. **[O]/[D] The routine draws no RNG — `roll` is uninitialised and `cScale`/`cRollAngle`/`bAuto` are dead text; RNG lives downstream at `writenewp.inc:25` and `field.prop:33`. `gc_pixels_to_tile/gc_pixels_to_meter = 2` resolves metres-per-cell in donor text, giving 3.3962 m spacing and 3.05658 m soft / 9.16974 m ore clearance.**
3. **[O] Verified assets to use: 10 eur-mill OBJs, `field.obj`/`field.png`, `envfieldd{,w}.png`, baked rotor PNGs + `models/anim/buildings/mill_rotor.json` (path corrected); missing death stages, rus/tur mills, winter crops, `field2/3`, `.oss`/`.aaf` and pumps — exact donor paths in §5.**
4. **[D] Field sowing is a mill-state effect, not a pattern stamp; it belongs after mill instantiation in the fresh module's stage order, and `SetupStartingResources` has zero food rects (direct donor scan + D07/V12), so spec §10 rows 50/53 are stale.**
5. **[I] Pseudocode in §4 uses only donor-cited constants; the port's 3.0 m clash and 1.6981 m half-step stay labelled PORT APPROXIMATION, activation stays [U], and no donor parity is claimed without an A/B frame.**

*End of X22 report. Exactly one repo file written. Donor read-only (latin-1); no donor binary executed or copied; no `app/**` or `variant3d/**` edit; no Godot job; no parity claim.*
