---
id: DEC-U-SELECTION
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: "WORKER DEC-U-SELECTION — static pick/marquee/screen-world decomp, single-click law + open predicates"
owner_file: docs/terrain_swarm_2026-11-26/reports/DEC_U_selection.md
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_ASSET_CONFIG_GODOT_GIT_EDIT
created: 2026-11-26
labels: [O, D, I, U, NO_PARITY_CLAIM, NO_APPROXIMATION]
parity_guard: "NO DONOR PARITY IS CLAIMED. No same-camera donor/port A/B frame was produced or examined. Every donor statement is read-only text/byte/VA observation; every port statement is a read-only source line. 'Required donor-faithful replacement' names the algorithm to implement, not a claim it is implemented."
scope_guard: "Exactly one repo file written (this report). No source, shader, config, asset, fixture, test, runner, Godot, git or user-mod edit. Donor binary and donor data read READ-ONLY; no donor executable run, no donor bytes copied. Network/multiplayer/lobby/Steam/replay-sync OUT OF SCOPE (singleplayer skirmish only)."
donor_pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE x86, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c, Deep mode. Every native call passed document=t_87f0f3c130b0 explicitly; global active target was never changed."
port_scope: "variant3d/scripts/picking3d.gd + variant3d/scripts/input_controller.gd + variant3d/scripts/game.gd:dec_u_pick_* (read-only line citations only; no edits). game.gd/data.gd pick-radius/AABB tables are cited as context, not changed."
upstream: "docs/terrain_swarm_2026-11-26/reports/DEC_U_entities_art_collision.md (§5.3/P14, E-U13) + DEC_U_fog_camera_hud.md (§4, IMPL-COLLISION-CALLERS/IMPL-FOG-PATCHES) + DEC_U_camera_projection.md (§§3-4, V2-BOX/V2-PROJ). This worker closes nothing by port fallback."
---

# DEC-U — selection decomp: single-click law, marquee, screen→world anchor (donor 1:1)

> READ-ONLY. Singleplayer skirmish only. Network excluded. No parity claim. No approximation endorsed.
> Each `[U]` ends in a fixed-camera selection capture with a zero-mismatch termination criterion. No weighting, ray formula, inside-test, or anchor is invented.

## 0. Method, labels, passes

- **[O]** = observed donor file line / binary VA / port line. **[D]** = deterministic reading over cited [O]. **[I]** = reading without runtime proof. **[U]** = unresolved after passes here.
- Path shorthands: `D:` = `C:\Games\Cossacks 3\data\` (read-only donor tree). `P:` = workspace `variant3d/`. `c3` = `t_87f0f3c130b0`.
- `ev_*` = Craft Anything evidence id of a pass in **this** session (all pinned `document=t_87f0f3c130b0` unless the subject is a donor text path).

### 0.1 Pass ledger (multiple passes on the pin; strange-decomp log inline)

| Pass | Operation (all `document=t_87f0f3c130b0` unless noted) | Evidence | Result |
|---|---|---|---|
| P1 | donor text `control.script:140-289` (read-only) | local read | `_control_GetUnitUnderCursor:156-274` + `_control_PrepareUnitUnderCursorList:278-304` full chain [O] (§1) |
| P2 | donor text `onmousemove.inc:1-206` (read-only) | local read | drag state machine `:32-34,69,141-167` [O] (§3); release in `onmousedown.inc LButtonUp` (carried, re-cited) |
| P3 | donor text `misc.script:661-669` `_misc_GetDistancePos` + `:6407-6471` selection write protocol | local read | XZ `VectorDistance` law [O]; `Begin→Start(spmRunTime)→Picked→Cancel-once` [O] (§1.4) |
| P4 | donor text `dmscript.global:227-233` priority table | local read | `my=1/wood=2/food=3/stone=4/goinside=5/build=6/enemy=7` [O] (§1.2) |
| P5 | donor text `onmousedown.inc:270-355` click/double/shift/ctrl apply | local read | `_control_GetUnitUnderCursor(True)` + squad/type/union/remove arms [O] (§1.5) |
| P6 | `native_bytes_find` text `GetGameObjectRayCastAABBByHandle` | `ev_b0325b2d4e1e665d94b2a05d0c104b7a47e9ffcf23f7479abfbf94ac76755f60` | 1 hit `0x63153e` CODE [O] |
| P7 | `native_bytes_find` text `GameObjectSortRayCastList` | `ev_2bf9d42c1fd8ff9b8ee01bb4ba9a7aac285b4676876843fbb6a861a5e814cd01` | 1 hit `0x69e4be` CODE [O] |
| P8 | `native_bytes_find` text `spmRunTime` | `ev_0edab27d629633cee734f6fcfacf3e2f475fd9ccc61548e17aa7f69e65727579` | 2 hits `0x511e3d/0x5125c8` CODE [O] |
| P9 | `native_bytes_find` text `GameManagerBeginSelection` | `ev_f5bcd4138ebcf125c10b353e9dbde1709ba1e5dd52c7ae8f071712e788477785` | 1 hit `0x6a03fa` CODE [O] |
| P10 | `native_bytes_find` text `GameObjectRayCastMouseRay` | `ev_6025cda91611bdd4ae1150ca30eefbf3b24c1abf38ccb46915990ba59b986985` | 1 hit `0x69e422` CODE [O] |
| P11 | `native_bytes_find` text `GetCountGameManagerPickedObjects` | `ev_37d3a190cc385e7bfe61eaeb733763e43ebac166160e912a9651e2919100d782` | 1 hit `0x6a7cda` CODE [O] |
| P12 | `native_bytes_find` text `OctreeRayCast` | `ev_4685a40a22787c4a1566233cbb03af3a6ce2a7f18750363ecea551cdafddcde3` | 2 hits `0x62e84a/0x62e8fa` CODE [O] — first static `OctreeRayCast` anchor in this lane (not the `OctreeRayCastIntersect` 12-arg script signature, which is text-only) |
| P13 | `native_bytes_find` text `spmAdd` | `ev_29a985f971de4001f9b988d58c3549928d99f2baccb79b3645f3bf82b39e9f99` | 2 hits `0x511e48/0x5125dc` CODE [O] (Shift-union mode string) |
| P14 | `native_function_find` `0x63153e` (AABB) | `ev_7c93ac0086d711d6e0429cc095dffb9fa3fffe095e3c42d26128983777da1308` | `not inside any discovered function` [O] — binding-table placement, not a decodable caller |
| P15 | `native_function_find` `0x62e84a` (Octree) | `ev_aac6412ca949cd13c0cf72157cb5e9c68124707d4596144fbfbc70654d9a4dc2` | `not inside any discovered function` [O] — same verdict |
| P16 | `native_function_find` `0x511e3d` (spmRunTime) | `ev_3230277ac50d7c9feac417763bd8e635f9b2f105c932ceb7d743ba4f4adb1a01` | `not inside any discovered function` [O] — same verdict |
| P17 | port read `picking3d.gd:1-463`, `input_controller.gd:1-120 + :271-903`, `game.gd:914-941` | local read | IMPL wiring + [U] seams cited [O] (§5) |

**Strange-decomp log (required):** P14–P16 binding names all report "not inside any discovered function". That is the same CODE-string-table placement already logged in DEC_U_camera_projection P22 (`0x5fcbaa` inside `sub_5fc2d0`, neighbours outside any function). It is **not** parsed as a call graph: no caller, polarity, or register law is guessed from it. The only trusted caller semantics in this job are the donor-text script lines (P1–P5), which are complete and unambiguous. No byte pattern is promoted to a ray/AABB formula.

---

## 1. Single-click pick — statically recovered [O]

### 1.1 Chain `control.script:156-274` (verbatim order, nothing skipped)

1. `Result := 0` (`:159`); early-out `if (GetGUIMinimapUnderMouse) then exit` (`:161`). Same guard opens the list-builder (`:282`).
2. `GameObjectRayCastMouseRay;` (`:164`) then `GameObjectSortRayCastList;` (`:165`). Native anchors [O]: `MouseRay 0x69e422` (P10), `SortList 0x69e4be` (P7).
3. Per-frame handles: `myPlHnd := GetPlayerHandleInterfaceIO`, `plIO := GetPlayerIndexByHandle(myPlHnd)` (`:167-168`); `mpos` from `GetCurrentMouseWorldCoord` (`:169-170`); `cPos` from `GetCameraAbsolutePosition` (`:171-172`).
4. Loop `for i:=0 to GetGameObjectRayCastCount-1` (`:176`); candidate `goHnd := GetGameObjectRayCastByIndex(i)` (`:179`); **seed `prio : Float = 0.5`** (`:180`) — overwritten per category below, never the winner for `bres`-empty/resource-unknown arms.
5. Triple gate (`:181`): `GetGameObjectPlayableObjectByHandle ∧ GetGameObjectVisibleByHandle ∧ GetGameObjectCollisionDetectionByHandle`. Then ownership filter + engine AABB (`:183-184`): `((not bMyPlayerOnly) or (plHnd match)) and GetGameObjectRayCastAABBByHandle(goHnd, cPos.x,cPos.y,cPos.z, mPos.x,mPos.y,mPos.z)`. Native AABB anchor [O]: `0x63153e` (P6, binding-table only per P14).
6. Entity position `pos` via `_unit_GetGameObjectPos(goHnd, pos)` (`:186-187`); `dist := _misc_GetDistancePos(mpos, pos, false)` (`:188`) = **XZ** distance per §1.3.
7. Category arms (§1.2). Winner (`:258-266`): `if (prio>0)` then `relativeDst := (1+dist)/prio; if (nearestHnd=0) or (relativeDst<nearestDst) then { nearestHnd:=goHnd; nearestDst:=relativeDst; }`.
8. Post-loop FOW veto (`:270-273`): `bVisible := (not GetFOWEnable) or (GetFOWLOSData(X,Z)>0)` on the **winner only**; `not bVisible → nearestHnd := 0`. `Result := nearestHnd` (`:273`).

### 1.2 Priority table `dmscript.global:227-233` + per-arm overwrite [O]

Base seed `prio=0.5` (`control.script:180`). Overwrites:

- `bres` arm (`:199-218`): `pres := _res_GetTRes(goHnd)`; `nil → prio` keeps `0.5` (candidate can still win — see [U] §2.1); collision-tag gate `GetMapCollisionTag(X,Z,True)=0` required; then `food: brised ? gc_gui_cursorprio_food(3) : 0`; `wood → 2`; `stone → 4`; else `0`.
- `bunit/bbuilding` arm (`:220-256`): `pobj := _unit_GetTObj(goHnd)`; `nil → prio` keeps `0.5`; `benemy := enemyplmask…<>0`; `bcanbetarget := benemy ∧ _unit_SelectedUnitsCanAttack(…)`; `enemy∧bcanbetarget → 7`; `bmy → 1`; building overlay: `not bbuilt ∧ _unit_UnitsCanBuild → 6`; else `bbuilt ∧ _unit_IsUnitCanAbsorbInside → (usage=mine ? (peasantselected ? 5 : keep prior) : 5)`.
- Donor constants [O] (`dmscript.global:227-233`): `my=1, wood=2, food=3, stone=4, goinside=5, build=6, enemy=7` (P4).
- Consequence [D]: the integer set is **not** the whole story — the live seed `0.5` survives exactly when `pres=nil` (res with no `TRes`) or `pobj=nil` (unit/building with no `TObj`), and when a mine-absorbable building is tested without peasant-selected. Those arms are reachable in-engine and their donor intent is **[U]** (§2.1). The port must not delete the seed; it must route it per §5.

### 1.3 Distance metric `_misc_GetDistancePos(mpos, pos, False)` [O] + units [U]

`misc.script:663-669` verbatim [O]:

> `b3D=true → VectorDistance(p1.x,p1.y,p1.z, p2.x,p2.y,p2.z)` else `VectorDistance(p1.x, 0, p1.y, p2.x, 0, p2.y)`.

The pick call passes `False` (`control.script:188`), so the metric is the **XZ-plane `VectorDistance`** [D]. What is **[U]** is the unit/frame: `mpos` is the engine `GetCurrentMouseWorldCoord` ground point (metres in world space, but near/far/aspect binding unrecovered — DEC_U_camera_projection V2-PROJ), `pos` is `_unit_GetGameObjectPos` entity origin (foot vs centre vs AABB centre unrecovered in this lane). Whether `dist` is compared in metres, and whether the `+1` carries a metre bias or a pixel/depth-normalised bias, cannot be read statically. The `(1+dist)/prio` **shape** (add-one then divide, min-wins, strict `<`) is [O]; the **units** are [U] E-U13-pick (§2.2). Never substitute screen-pixel `sd` as donor metres.

### 1.4 FOW veto + write protocol [O]

- Veto is post-loop on the winner only, not per-candidate (`:270-272`) [O]. `PrepareUnitUnderCursorList` (`:278-304`) has **no** priority, **no** `playable/visible` pair (only `CollisionDetection`), and **no** FOW veto — it is the engine-AABB membership list only [O]. Do not conflate the two functions.
- Write protocol [O] (`misc.script:6409-6471`, P3): `ClearGameManagerPickedObjects → _misc_SetSquadsSelection(plInd,false) → GameManagerBeginSelection → GameManagerStartSelection('spmRunTime') → per-handle (squad<0 ? gSelectedObjects.Add : TSquad.fSelected:=true) + SetGameObjectPickedByHandle(goHnd,True) + Cancel-once when i=count-1 → _misc_UpdateSelection`. `Add` (`:6452-6471`) and `Remove` (`:6473+`) reuse the same `Begin→Start(spmRunTime)→…→Cancel-once` envelope. Native mode strings [O]: `spmRunTime 0x511e3d/0x5125c8` (P8), `spmAdd 0x511e48/0x5125dc` (P13), `Begin 0x6a03fa` (P9). `GameManagerIsSelectionMode`/`PickedObjects` anchors carried from DEC_U_camera_projection P17/P18/P25 (`0x6a03c2/0x6a7cda`); `IsSelectionMode` teardown verified in `onmousedown.inc LButtonUp` (upstream §3.1, re-cited not re-derived).

### 1.5 Click/double/shift/ctrl apply `onmousedown.inc:280-355` [O]

`goHnd := _control_GetUnitUnderCursor(True)` (`:280`); double-click or Ctrl → `_misc_SelectAllUnitsOfType(cid,id,True,False,Shift,squadSel)` (`:286-291`); single → `gIntegerList={goHnd}` + `not Shift∧not Ctrl → _misc_SetUnitsToSelection` else membership/squad test → `_misc_Add/RemoveUnitsFromSelection` (`:296-344`); empty hit + `not Shift∧not Ctrl → DeselectAll`-family (`:345+`, tail cut but branch head [O]). Port `input_controller.gd:1038-1107` mirrors this shape read-only (§5).

---

## 2. Still-[U] — E-U13-pick (distance units/weighting + tie-breaks)

### [U] E-U13-pick-open

(a) **Units of `dist`**: `mpos` frame/scale (engine world coord at surveyed ground height, with `+0.25` snap only in the editor path `onmousemove.inc:111-112`, not the pick path) vs `pos` frame (foot point vs AABB centre vs `TObj` origin). The `+1` in `(1+dist)` therefore cannot be dimensionally closed statically: if `dist` is metres the `1` is 1 m; if `dist` is tiles/pixels the `1` is 1 tile/px. The winning **shape** is fixed; the **weighting** (how many metres one priority point buys) is open.
(b) **Seed-`0.5` arms**: `pres=nil`, `pobj=nil`, mine-without-peasant-selected. Static text leaves `prio=0.5` live on those paths; whether the engine ever feeds such a handle into the loop (i.e. whether the AABB gate already excludes them) is engine-side.
(c) **Tie-break**: strict `<` with `nearestHnd=0` initialiser (`:261`) [O] means exact-equal `relativeDst` keeps the **earlier raycast order** (ray-sorted, `SortRayCastList` order, not id order) [D]. The initial `nearestDst` is uninitialised at function entry (no assignment before `:261`), so the first `prio>0` candidate always installs (`nearestHnd=0` short-circuit) [O/D]. What `SortRayCastList` sorts by (ray-`t`, depth, AABB entry) is engine-side → [U]. Port depth tie-break is therefore **labelled port depth tie-break, not donor**.
(d) **`bMyPlayerOnly` interaction**: `True` restricts the AABB test to own-handle objects (`:183`), but the FOW veto still applies to the winner (`:270`). Whether enemies ever enter the sorted list under `True` (for `enemyMask` evaluation) vs are filtered pre-sort is not in text → [U].
(e) **Engine AABB**: `GetGameObjectRayCastAABBByHandle(goHnd, cPos→mPos)` takes two world points [O] (call shape), but inside-test (slab vs OBB vs screen-rect, expansion by `SelectionSize`/scale, water/bridge height handling) and return convention are engine-side → [U]. `OctreeRayCast 0x62e84a/0x62e8fa` (P12) proves the octree-ray name family is resident in CODE, but both hits sit outside any discovered function (P15) and neither is the 12-arg `OctreeRayCastIntersect(sx,sy,sz,dx,dy,dz,px,py,pz,nx,ny,nz)` script signature (text-only, DEC_U_entities §5.2). No ray formula is invented.

### E-U13-pick — fixed-camera selection capture (zero-mismatch criterion)

Fixed rig 58 m / −32° / focal 400 (gameplay `camera.cfg`), FOW off, singleplayer skirmish, no camera move between probes. Survey a flat area; place one own peasant (prio 1), one wood node (prio 2), one own building-unbuilt (prio 6) and one attackable enemy (prio 7) at known world separations along one view ray so their screen projections overlap within 1–2 px at the test pixel. For each probe: log `GetCurrentMouseWorldCoord` (mpos), `_unit_GetGameObjectPos` per handle (pos), `GetGameObjectRayCastCount` + order after `SortRayCastList`, per-handle `prio` branch taken, computed `(1+dist)/prio` with `dist=_misc_GetDistancePos(mpos,pos,False)`, and the returned `nearestHnd`; repeat with FOW on + one winner inside zero-LOS (expect 0). **Termination:** predicted winner by the `(1+dist)/prio` min-rule with first-in-ray-order tie-break matches the returned handle on **every** probe including a constructed exact-tie (two handles at equal `(1+dist)/prio` to 1e-6) and a seed-`0.5` probe (`pres=nil`/`pobj=nil` if constructible, else documented unconstructible), with **zero mismatches** and the FOW-veto probe returning 0, before any unit/weighting/tie-break literal is written as donor fact. Port keeps screen-pixel `sd` + depth tie-break labelled PORT APPROXIMATION until then.

---

## 3. Screen→world drag anchor — script side [O], geometric anchor [U]

### 3.1 Recovered [O] (`onmousemove.inc:32-34,69,141-167`)

- Epsilon: `0.005` default; `0.25` in attack-point/guard mode (`:32-34`).
- World read per move: `GetCurrentMouseWorldCoord(x,y,z)` (`:69`).
- Two-phase start [O]: `if not isselectionstarted { isselectionstarted:=true; prevselmousex:=x; prevselmousez:=z; }` (`:141-147`, exact lines `145-146`).
- Axis-wise compare (`:152`): `if (Abs(x−prevselmousex)>eps) or (Abs(z−prevselmousez)>eps)` then `GameManagerBeginSelection` (`:154`) + Shift ? `spmAdd` (`:156-157`) else `spmRunTime` (`:162`, `spmRemove :160-161` commented dead).
- Release: `onmousedown.inc LButtonUp` `isselectionstarted:=false + if GameManagerIsSelectionMode then GameManagerCancelSelection` (upstream, re-cited).

[D]: donor freezes a **WORLD-ground** anchor on the first LMB-held move and compares axis-wise X/Z deltas — exactly what the port mirrors with `_sel_ground_start` (first-move) vs `_rect_ground_anchor` (press-frozen) (`input_controller.gd:57-71`). Which of the two the engine uses **geometrically** as the rect corner is still engine-side → [U] below. The port dual-model is therefore a faithful reading of `:141-152`, not a donor claim about geometry.

### [U] V2-PROJ-drag-anchor-open + capture

Which point the engine freezes as the rect corner (press-point vs first-move point) and whether the frozen corner is re-projected through the live camera on pan/zoom mid-drag. **Capture V2-PROJ-DRAG** (fixed rig, owner-authorised): LMB press at surveyed pixel, hold, step 1–3 px across the epsilon boundary in each axis; log `GetCurrentMouseWorldCoord` at press vs first-move vs each step + `GameManagerIsSelectionMode` onset frame. **Termination:** onset frame + frozen rect corner match ONE of (press-point, first-move-point) with **0 px / 0.0 m mismatch** on all four drag directions before the port collapses the dual model (`input_controller.gd:57-71,693-705`).

---

## 4. Marquee inside-test — script side [O] (negative result), predicate [U]

### 4.1 Recovered [O]: the inside predicate is engine-side (negative is the finding)

- No readable predicate: `GameManagerBegin/Start(spmAdd|spmRunTime)/Cancel/IsSelectionMode/PickedObjects` are engine calls; `spmFrame`/`InitMinimap`-style polling names are 0-hit (DEC_U_camera_projection P26, re-cited). Native anchors [O] this job: `Begin 0x6a03fa` (P9), `PickedObjects-count 0x6a7cda` (P11), `spmAdd 0x511e48/0x5125dc` (P13), `spmRunTime 0x511e3d/0x5125c8` (P8) — all CODE-resident but function-orphaned (P14–P16), i.e. binding-table placement, never a predicate.
- Neighbour contrast [O]: single-click law §1 (priority + AABB + XZ + FOW veto) vs `PrepareUnitUnderCursorList` (`:300-301`, collision+AABB membership only) — the drag path has **no** script-side per-candidate loop at all. Drag-rect world mapping + inside rule (centroid-in vs AABB-overlap vs containment fraction, edge inclusion, squad-grouping side effects) cannot be read statically [D].
- Port `Rect2.has_point` centroid-in + four-corner ground AABB stays `PORT APPROXIMATION` [O] (`input_controller.gd:693-742`, `picking3d.gd:287-305` AABB-screen-rect helper is port-side only).

### [U] V2-BOX-open + capture

Inside rule (centroid vs AABB vs fraction, edge inclusion, building vs unit vs res-node membership, squad side effects) + projection→box world mapping. **Capture V2-BOX** (FOW off, fixed rig): grid of idle peasants at known spacing; scripted drag rects inset/outset by 1–3 px around known units, both drag directions; log `GetCountGameManagerPickedObjects` membership per rect. **Termination:** fitted rule predicts membership of **all** probed rects including 1-px edge cases and both drag directions with **zero membership mismatches** before any rule is written as donor fact. `SelectionRectPainter` keeps its `PORT APPROXIMATION` tag until then.

---

## 5. Exact port change list (file/line; no code written here)

Each row: port site **[O]** (read-only), donor fact **[O]/[D]**, required replacement + why current code is not yet donor-faithful. `game.gd` rows are the eligibility/AABB single-source owned by IMPL-COLLISION-CALLERS; `picking3d`/`input_controller` rows are owned by IMPL-FOG-PATCHES. No row claims implementation.

| # | Port file:line (current [O]) | Donor fact (this job [O]/[D]) | Required donor-faithful replacement (no edit made here) |
|---|---|---|---|
| R-SEL-1 | `P:scripts/picking3d.gd:88-91 _donor_prio`, `:103-107 _donor_score`, `:449-463 _closer` | Prio table 1..7 [O] P4; winner `(1+dist)/prio` min-wins strict `<`, `prio<=0` excluded [O] §1.1(7) | KEEP `_donor_score=(1+dist)/prio` + `_closer` min-wins shape. CHANGE: thread the `0.5` seed through `_donor_prio` per §1.2 (`pres=nil`/`pobj=nil`/mine-without-peasant keep `0.5`, not `0`) once the game dict exposes `TRes/TObj`-nil-ness; today `0` excludes those arms which donor keeps eligible. Tag the seed arms [U] E-U13-pick until the §2 capture. |
| R-SEL-2 | `P:scripts/picking3d.gd:370 sd:=sp.distance_to(screen)`, `:377-384` + `:800-808 donor_pick_score` in controller | `dist=_misc_GetDistancePos(mpos,pos,False)` XZ `VectorDistance` [O] §1.3; screen-px `sd` is port measure | KEEP screen-px `sd` ONLY as labelled PORT APPROXIMATION (header `:50-58` already does). After E-U13-pick terminates: compute donor `dist` in world metres (mpos ground hit vs entity `pos` foot/centre per capture verdict) and feed THAT into `_donor_score`; do not invent the metre/px conversion before then. Tie-break stays port depth rule (`:461-462`) until the exact-tie probe passes. |
| R-SEL-3 | `P:scripts/picking3d.gd:358-364 eligible gate`, `P:scripts/game.gd:917-925 dec_u_pick_eligible` | Triple gate playable∧visible∧collision [O] §1.1(5); `PrepareList` needs collision-only [O] §1.4 | KEEP `dec_u_pick_eligible` as the single-click gate. ADD a separate `dec_u_list_eligible` (collision-only, no playable/visible/FOW filter) for the `PrepareUnitUnderCursorList` path if/when that path is ported; never reuse the single-click gate for it. Engine `SetGameObjectRayCastIntersectEnabled` stays [U] (E-U13 in DEC_U_entities). |
| R-SEL-4 | `P:scripts/picking3d.gd:287-305 _dec_u_aabb_screen_rect`, `P:scripts/game.gd:929-941 dec_u_pick_aabb` | AABB call shape `(goHnd,cPos→mPos)` [O] §1.1(5); only `eurmil` extents + unit AABB are [O] (DEC_U_entities P12) | KEEP the 8-corner project + `has_point` as PORT APPROXIMATION of the engine slab test. After E-U13-pick: replace with the fitted inside-test (slab vs OBB vs expansion verdict from the capture); expand the `dec_u_pick_aabb` table beyond `eurmil`/fallback only from per-`.prop` AABB reads, never from `block_r`. |
| R-SEL-5 | `P:scripts/picking3d.gd:372-376 _donor_los_ok` per-candidate + `P:scripts/input_controller.gd:810-816,866,892,895,900-903` | Veto is post-loop on winner only [O] §1.4 | KEEP per-candidate veto as additive hardening ONLY if the winner veto stays exactly once per apply (controller `:866/:900-903` already re-checks the winner). After E-U13-pick: conform to winner-only if the capture shows per-candidate veto changes membership (e.g. occluded nearest suppressing a visible second). Never weaken to no-veto. |
| R-SEL-6 | `P:scripts/input_controller.gd:771-798 donor_pick_priority` | Table + food-`brised`/building/enemy arms [O] §1.2 | CHANGE: return `0.5`-equivalent (e.g. `0.5` float prio, not `0`) for the nil/unknown arms per R-SEL-1; ADD mine `peasantselected` gating (currently always `goinside` at `:795-796` — donor requires peasant-selected for `usage=mine`, `:246-250`); ADD `_unit_UnitsCanBuild` gating for the unbuilt→6 arm (currently any unfinished building, `:793-794`). All three need sim predicates the port may not yet expose — leave labelled [U] until E-U13-pick. |
| R-SEL-7 | `P:scripts/input_controller.gd:800-808 donor_pick_score` | XZ `VectorDistance`, `b3D=False` [O] §1.3 | KEEP `(1+d)/prio` shape. CHANGE the `d` source from `mpos.distance_to(e.pos)` screen/world mix to donor XZ metres after E-U13-pick; keep `INF` on `prio<=0`/missing `pos` (already donor-faithful). |
| R-SEL-8 | `P:scripts/input_controller.gd:57-71` dual anchor, `:693-705 _drag_world_rect`, `:711-742 _apply_rect_selection`, `:850-903 _pick` | Two-phase anchor + axis epsilon + `spmAdd`/`spmRunTime` [O] §3.1; inside-test engine-side [O] §4.1 | KEEP dual model + 4-corner AABB + `has_point` + Shift-union as PORT APPROXIMATION (`:684-692` banner stays). After V2-BOX/V2-PROJ-DRAG terminate at zero mismatch: collapse to the winning anchor in `_drag_world_rect` only, and swap the inside rule in `_apply_rect_selection` only; keep epsilon/mode/teardown (`:1019-1021,1139-1154,717-732,1107`) unchanged. |
| R-SEL-9 | `P:scripts/input_controller.gd:819-847` Begin→Start→Cancel + squad split `:835-847` | Protocol [O] §1.4 (`misc.script:6418-6444`) | KEEP null-safe shims. No change except: Cancel exactly once per apply after the last Picked (already so at `:384`/`_set_selection`); squad `fSelected` mirror stays additive-only. |
| R-SEL-10 | `P:scripts/picking3d.gd:45-51` `BODY_LIFT_M/TIE_PX/FALLBACK` + `:227-271` analytic `_ppm` | No donor lift/tie/fallback literal exists in this lane [O] (absence after P1–P16 + upstream) | KEEP all three labelled PORT APPROXIMATION. `FALLBACK_REACH_M=2.0` mirrors the 2D `d<2.0` fallback (`input_controller.gd:895`) which is port-observed, not donor; never cite it as donor. Remove only by E-U13-pick verdict. |

Explicit non-changes: `camera3d.gd`/`config.gd` FOV/near/far, `world3d`/`hud` minimap-box, `game.gd` save/tick/`ai.gd` take NO edit from this ticket (V2-PROJ/V2-MINI/O1/R1 live in their own lanes).

---

## 6. Claim register

| # | Claim | Label |
|---|---|---|
| 1 | Single-click chain is `Minimap-exit → MouseRay → SortList → playable∧visible∧collision ∧ ownership ∧ engine-AABB → per-arm prio → min (1+dist)/prio → winner-only FOW veto` | [O] P1/P3/P4/P5, `control.script:161-273` |
| 2 | Priority integers are `1/2/3/4/5/6/7`; seed is `Float 0.5`; food needs `brised`, buildings need can-build/absorb (+peasant for mines), enemies need `enemyMask∧SelectedUnitsCanAttack` | [O] P1/P4, `control.script:180-255`, `dmscript.global:227-233` |
| 3 | `dist` is XZ `VectorDistance(mpos,pos)` (`b3D=False`); `(1+dist)/prio` min-wins with strict `<`, first-in-ray-order keeps ties, first eligible always installs | [O] P1/P3, `control.script:188,258-266`, `misc.script:663-669` |
| 4 | `dist` units/frame, seed-arm reachability, `SortList` order key, `bMyPlayerOnly` pre/post-sort point, engine AABB inside-test | [U] E-U13-pick, §2 capture |
| 5 | Drag anchor two-phase + axis epsilon + `Begin→spmAdd/spmRunTime→DoUpdateSelection`; press-vs-first-move geometry open | [O] script / [U] geometry, §3 |
| 6 | Marquee inside-test + screen→world rect mapping are engine-side; port centroid-in/4-corner AABB is approximation | [O] negative P9/P11/P13-P16 + [U] V2-BOX, §4 |
| 7 | Native `MouseRay 0x69e422 / SortList 0x69e4be / AABB 0x63153e / Begin 0x6a03fa / PickedCount 0x6a7cda / spmRunTime 0x511e3d+0x5125c8 / spmAdd 0x511e48+0x5125dc / OctreeRayCast 0x62e84a+0x62e8fa` resident in CODE; AABB/Octree/spm hits orphaned from discovered functions | [O] P6–P16 |
| 8 | No ray formula, weighting, inside rule, or anchor invented; port `picking3d` screen-px + depth tie-break and `input_controller` dual-model/`has_point` stay labelled PORT APPROXIMATION | [D] §§2-5 |
| 9 | Any port visual/selection equals donor behaviour | **Denied** — no same-camera donor/port A/B exists; parity UNVERIFIED |

## 7. Scope statement

Exactly one repository file was written by this worker: this report. All donor reads were read-only against pin `t_87f0f3c130b0` (every binary call with `document=` pinned; global target untouched) and the read-only `C:\Games\Cossacks 3\data` tree. No source, shader, config, asset, fixture, test, runner, Godot, git or user-mod state was changed. No donor binary executed, no GPU frame captured, no port capture compared. No parity, similarity score, threshold or gate PASS is claimed. Network is out of scope.

*End of DEC-U-SELECTION.*
