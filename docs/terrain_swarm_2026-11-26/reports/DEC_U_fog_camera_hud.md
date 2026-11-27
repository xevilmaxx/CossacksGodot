# DEC-U-FOG-CAMERA-HUD — fog, FOV/sensor, camera, selection, HUD/minimap, save, tick interleave, delivery split (2026-11-26)

- id: DEC-U-FOG-CAMERA-HUD
- worker: DEC-U-FOG-CAMERA-HUD (subagent, full 1:1 donor port)
- date: 2026-11-26
- scope: READ-ONLY decomp. Donor binary never executed/copied. Donor text read as text only. No code/asset/config/Godot/git change. Exactly one repo file written (this report).
- pin: `t_87f0f3c130b0` = `C:\Games\Cossacks 3\cossacks.exe`, PE32, 5,768,048 B, sha256 `87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c`
- upstream: `DEC_U_skirmish.md` (§2.9–2.11, §3: M1/C1/T1/T2/D1/Q1/S1/R1/V1/V2/F1/E1/A1/O1/G1), `PORT1TO1_skirmish_logic.md` (§9–§13: U1/U15/U16/U17/U18, delivery, tick, save)
- labels: `[O]` verbatim donor bytes/text · `[D]` deterministic reading · `[I]` inference · `[U]` UNVERIFIED (settling experiment given, never substituted) · `PORT APPROXIMATION` = port-authored substitute
- parity: NO PARITY CLAIM. No donor GPU A/B frame. No donor binary executed by this worker. Closed items rest on donor text `[O]` with file:line; engine-side items stay `[U]`.
- network: OUT OF SCOPE.

## 0. Pass ledger (all native passes pinned `document:"t_87f0f3c130b0"`)

| # | Pass | Result |
|---|---|---|
| P1 | `core_session_show` | active `t_87f0f3c130b0` (Deep), 555 evidence records; `editor.exe t_68474ddde43f` present, untouched |
| P2 | `core_feature_find "GetFOWLOSData"` | negative `ev_be8575b24af2ca658b9f3c3907485b142a0f9864816c376a39144fee18b08b3e` — 0 strings/functions/imports (script-bound name, expected) |
| P3 | `core_feature_find "SetFOWEnable"` | negative `ev_f476d16079a0ec18a1cd6b1313ddf233b7e834b1bd9093e5caee2ce087d9866f` — 0/0/0 (script-bound, expected) |
| P4 | `core_feature_find "FocalLength"` | negative `ev_0eb1f63858f1df62b11abe33c764967b0f6e77a24c015a9bf0eab8e528981258` — 0/0/0 (config-side literal, expected) |
| P5 | `core_feature_find "GameManagerStartSelection"` | negative `ev_30db27aaf96b7ca23c3003b5023d9e22815b04b970330b17bd2a6245a02cf062` — 0/0/0 (script/engine-bound, expected) |
| P6 | `native_bytes_find text "fogreveal"` | **negative** `ev_d80780256b6c1c303f408eccf2422426b0d2bf85fe094a77e239b0d20d82870a` — 0 matches utf8+utf16le (script-side basename; engine stores it opaquely) |
| P7 | `native_bytes_find text "resourceDropRadius"` | **negative** `ev_43eace7f170c26b6df19a6b96622617caaaca35af5a086529c63e0455ad00495` — 0 matches (script-side constant, expected) |
| P8 | `native_bytes_find text "FOWEnable"` | **positive** `ev_ae7d083867057581f8221772ca24173249b3509085b3af3e7eed5728c5bac039` — 3 matches: file-off `0x1d9daa` (VA `0x5da9aa`, CODE), `0x2a74b5` (VA `0x6a80b5`), `0x2a74dd` (VA `0x6a80dd`) |
| P9 | `native_bytes_find text "MinFocalLength"` | **positive** `ev_d5c83e0d7669cc5e17ca9081d49bc0a372116fd92b4168a772062de63a077820` — 1 match: file-off `0x3ab368` (VA `0x7abf68`, CODE) |
| P10 | `native_bytes_find text "GetFOWLOSData"` | **positive** `ev_4f7e8d6440c11e327ccc728e5ffce9dc65313d95b50db44a85bb1b0090ef584d` — 1 match: file-off `0x2a7812` (VA `0x6a8412`, CODE) |
| P11 | `native_bytes_find text "spmRunTime"` | **positive** `ev_88e08a5de679d946ce8ce7dd58cc7f322c1a082041e7ae4dbdd7242361c9ad5c` — 2 matches: `0x11123d` (VA `0x511e3d`), `0x1119c8` (VA `0x5125c8`), CODE |
| P12 | `native_bytes_find text "RecordCustomBegin"` | **positive** `ev_a6f63aeb9b9771aad0822665fdc0784fb3827978f08b6bc27b147b8923e31b10` — 6 matches (first page): `0x281736/7a/de/42/8a`, `0x281d0a` (VAs `0x682336…0x68290a`, CODE) |
| P13–P40 | ~28 donor-text read/grep passes (outside Craft Anything, `C:\Games\Cossacks 3\data\…`) | all `[O]` below with file:line |

Engine-string verdict `[D]`: FOW/selection/save names that ARE engine entry points (`FOWEnable`, `GetFOWLOSData`, `spmRunTime`, `RecordCustomBegin`, `MinFocalLength`) leave byte traces (P8–P12); gameplay/script identifiers (`fogreveal`, `resourceDropRadius`, `SetFOWEnable`, `GameManagerStartSelection`, `FocalLength`) do not (P2–P7) — consistent with script-side law + engine-side grid/projection/selection-box. Negatives are expected, not proof of absence.

## 1. Fog-of-war visibility rule + grid

### 1.1 RECOVERED — vision function (was F1-head / U18-part)

`data/scripts/lib/unit.script:11563-11614` (`_unit_GetVision(var res; const hnd)`), verbatim shape:

- `[O]` fogreveal objects: `if tag = gc_properties_stringtag_fogreveal (dmscript.global:1439, =109)` → read state-machine `TProj(pproj)` (`gc_argproj_proj=0`, `dmscript.global:836`), `res := floor(pproj.dx)`, else `res := 0` + `ErrorLog`. `dx` is set to the caller `radius` at creation (see §1.2).
- `[O]` normal objects: `if GetGameObjectVisibleByHandle(hnd)` and state-machine `TObj(pobj)` non-nil and `not bdead` and `bbuilt` → `res := floor(cBaseVal + cModVal * gObjProp[cid][id].vision)` with `const cBaseVal = 20; const cModVal = 4` (`:11567-11571`, active; `:11568-11569` commented `18/3.6/3.75` are dead alternates — do not port). Else `res := 0` (+ `ErrorLog` arms for nil/zero handles).
- `[O]` schema: `vision: Integer` field is `TObjProp` (`classes.script:3612`); written by `SetObjBaseSearchBuildVisionScore(..., vision, ...)` (`unit.script:571-581`, `-1` = keep); examples `misflagman vision := 8` (`:2069`), `3/3/2/2/0` rows (`:2167/:2236/:2550/:2560/:2569/:2581`); full per-sid audit is mechanical text work (no binary needed).

`[D]` examples (integer floor is load-bearing): vision 0 → 20; vision 1 → 24; vision 3 → 32; vision 8 → 52. Units of `res` (cells? world units?) are engine-defined — see §1.4 [U].

### 1.2 RECOVERED — fogreveal object plumbing (was F1)

- `[O]` `misc.script:5918-5944` (`_misc_GetOrCreateFogReveal(px,pz,radius)`): reuse `_misc_GetFogReveal(px,pz)` (`:5901-5916`, radius-`gc_epsilon` scan for existing tag-109 object); else `CreatePlayerGameObjectHandleByHandle(miscPlHnd, 'misc', 'fogreveal', px, RayCastHeight, pz)` (`gc_racename_misc='misc' :944`, `gc_basename_fogreveal='fogreveal' :965`, `gc_playerind_misc = MaxPlayerCount+1 :101`); `AddFOWObjects(Result)`; `SetGameObjectVisibleByHandle(Result, False)`; then set `TProj.px/pz/dx := px/pz/radius` or `ErrorLog('fogreveal …')`.
- `[O]` `_misc_RemoveFogReveal` (`:5883-5897`): same epsilon scan, `GameObjectDestroyByHandle` first tag-109 match, `break`.
- `[O]` scenario trigger `map_revealZone` (`scenario.script:1851-1864`): `bstate → GetOrCreate(x,z,radius)` else `Remove(x,z)`; `if GetFOWEnable then FOWBuildFull`; `log('… radius='+…)`.
- `[O]` exclusion: `unit.script:11572` branch + `unit.script:5519` (`bvisible=True; CheckVisibility function in C1` comment — C1 visibility consumer is engine-side).

### 1.3 RECOVERED — FOW enable/team gating (was F1 / U18)

`player.script:451-478` (`_player_UpdateFOW(plInd)`):

- `[O]` `bFOW := True`, then `False` if `gPlayer[pl].bballoon` or `settings.additional.balloon = with (gc_mapsettings_balloon_with, :1049)` or `gPlayer[pl].victorystate <> none (:777-778)`; then `False` if `not gbool_editor_fogofwar (:2120)`.
- `[O]` always `ClearFOWPlayers`; if `bFOW`: `AddFOWPlayers(own handle)`, plus same-`team` allies (`i<>plInd`, `plInd<>0 or not neutral`), `SetFOWDovFunc('_unit_GetVision')`; finally `SetFOWEnable(bFOW)`.
- `[O]` call site: `_control_SetPlayer` (`control.script:712-720`): `SetPlayerHandleInterfaceIO → _player_UpdateFOW → Deselect → DoUpdateSelection → InitMinimap`.
- `[O]` cheat/flag surface: `profile.script:47/298` (`bCheatNoFogOfWar`), `miscext2.script:3334` set + `:3424 'fog'` cheat key, `:3013` editor toggle; `player.script:458` gate above is the only sim consumer.

### 1.4 Still-[U] — FOW grid resolution, LOS combination, explored-vs-visible, minimap coupling

No readable text defines: FOW cell size (world→grid quant), multi-viewer combination (max/sum), LOS occlusion vs pure radius (height/forest/wall blocking?), persistence of explored area, or minimap tint thresholds. `DynFog*` in `camera.cfg:59-64` is a **visual** depth fog (`DynFogDepth=False` in gameplay cam), not the gameplay FOW — do not conflate.

- Experiment F1-GRID (runtime, owner-authorised): skirmish, FOW on, one peasant (known `vision`, e.g. default 1 → expect 24). `FOWBuildFull`/step, dump `GetFOWLOSData` on a transect line through the unit at 1.0-cell steps; fit radius (world units) vs `floor(20+4·vision)`; repeat with vision 0/3/8 sids and with a `fogreveal` radius R trigger zone to test `floor(dx)` path. Then two overlapping viewers (distance d apart) to test max-vs-sum; then interpose forest/hill/wall to test occlusion. Acceptance: cell size + combine rule + occlusion verdict, or keep `[U]`.
- Experiment F1-MINI (GPU): paired screenshots (FOW on/off, same frame) + `gui.script:3479-3496` blend arms; sample explored-but-unseen vs never-seen pixel values. Never video-derived constants — pixels only to label thresholds.

## 2. FOV / sensor-width derivation from pitch/height/focal 400

### 2.1 RECOVERED — all camera inputs (was U17/V1-head; corrects bible §9)

`data/cameras/camera.cfg:1-65` (gameplay camera), verbatim:

- `[O]` `RestrictInfo: HeightTarget=1, HeightTargetMin=5, SphereHeight=SphereLength=58 (:6-9), Min 20 (:7,10)`.
- `[O]` `FreeRotationInfo`: all four pitch angles **−32°** (`:32-35`), `AngleLerpPower=1`, `Min/MaxDistToTargetObject=1/10`, `MaxHeightLerpFactor=0.15`.
- `[O]` `MinFocalLength=MaxFocalLength=400 (:44-45)`, `FocalLengthPower=1.0` — zoom fixed.
- `[O]` `ElasticInfo` velocities/raycast steps (`:13-28`), `Bounded=True, DistToGroups=15`, DOF block (`:51-57`), `DynFogStart=0.25, End=0.025, Density=2.0, Power=0.85, Offset=0, Depth=False (:59-64)`.

Siblings (not gameplay, cited so port never mixes them): `default.cameras:1-96` (`Camera0/@Camera0`: Focal 400, DepthOfView 1200, Target 0/49/78.42…, Pos 0/0.053/0.0848, Dir −Z; `@CameraDebug`: Focal 100, DepthOfView 50); `cameradebug.cfg` (Sphere 19/5, pitch −30/−48, Focal 86–100); `camerascreenshot.cfg` (Sphere 13/0.75–0.6, pitch −90…+20, Focal 95, `DynFogDepth=True`).

Native anchor `[O]`: `MinFocalLength` string resident at VA `0x7abf68` (`ev_d5c83e0d…`, P9) — config key reaches the engine; value 400 itself lives in config text, not EXE bytes.

### 2.2 Still-[U] — sensor width → FOV (the only missing derivation)

Thin-lens relation (pinhole, square pixels, no distortion) `[D]`:

> `FOV_v = 2·atan(sensor_h / (2·f))`, `FOV_h = 2·atan(sensor_w / (2·f))`, `f = 400` (focal length units = sensor units).

`[U]`: neither sensor width/height nor viewport mapping nor pitch→FOV coupling is in any readable file. Port `FOV 17.27°` stays `PORT APPROXIMATION`: as a check, 17.27° vertical implies `sensor ≈ 2·400·tan(8.635°) ≈ 121.4` focal units — that number is **derived from the port claim, not donor**, and must not be written back as donor fact.

- Experiment V1-SENSOR (matched-pair solve, owner-authorised): fixed map seed, fixed camera target, FOW off, place two surveyed markers at known world separation perpendicular to view axis at target depth; capture frame; measure pixel separation + full frame size; solve `sensor_w = f·(px_sep/frame_w)·(world_sep/depth)`-family per actual projection (bracket both pinhole and any engine fit-mode by repeating at two depths); cross-check vertical with horizontal. Then `cameradebug.cfg` focal-100 camera as second equation. Until then: pin 58/−32/400, tag every FOV/selection-frustum number `PORT APPROXIMATION`.

## 3. Exact camera constants + projection

Recovered constants: §2.1 table (58 / 20 / −32 / 400 / elastic + DOF + DynFog numbers). `[O]` hot path hooks are script-side: `GameObjectRayCastMouseRay`, `GameObjectSortRayCastList`, `GetCurrentMouseWorldCoord`, `GetCameraAbsolutePosition`, `GetGameObjectRayCastAABBByHandle(cPos…, mPos…)` (`control.script:164-184, 285-300`).

Still-[U] (engine-side): world→screen projection matrix, `world_ground_anchor` semantics (press-point vs first-move — `input_controller.gd:35-42` dual-model stays), raycast AABB expansion, frustum culling vs picking. Native `MinFocalLength` hit (P9) proves the key is consumed in CODE, not its value.

- Experiment V2-PROJ (GL trace + runtime): instrumented frame with known camera target/58/−32/400; log `GetCameraAbsolutePosition` + `GetCurrentMouseWorldCoord` for surveyed ground points; fit projection (focal, principal point, pitch application order, HeightTarget handling); drag-anchor test (press vs first-move ground point during scroll) to settle `input_controller` dual-model. Ghidra follow-up per audit Q-4 only if trace under-constrains.

## 4. Selection predicate

### 4.1 RECOVERED — script-side pick law (was U16/V2-head)

Single-click pick `control.script:156-274` (`_control_GetUnitUnderCursor(bMyPlayerOnly)`):

- `[O]` early-out `if GetGUIMinimapUnderMouse then exit` (`:161`, also `:282`); raycast `MouseRay → SortList`; per candidate require `Playable ∧ Visible ∧ CollisionDetection` + `RayCastAABB(cPos→mPos)` (`:181-184`).
- `[O]` priority table `dmscript.global:227-233`: `my=1, wood=2, food=3, stone=4, goinside=5, build=6, enemy=7`; food only if `brised` else 0 (`:206-217`); building branches (unbuilt+can-build → 6; absorbable/mine+peasant-selected → 5) (`:236-254`); enemy requires `enemyMask ∧ SelectedUnitsCanAttack` (`:225-231`).
- `[O]` winner: `relativeDst := (1+dist)/prio`, min wins (`:260-266`), with 3D→2D distance `_misc_GetDistancePos(mpos,pos,False)` = XZ `VectorDistance` (`misc.script:663-669`).
- `[O]` FOW veto: `bVisible := (not GetFOWEnable) or (GetFOWLOSData(x,z)>0)`; `not bVisible → nearestHnd := 0` (`:270-273`).
- `[O]` selection write protocol: `GameManagerBeginSelection → GameManagerStartSelection('spmRunTime') → SetGameObjectPicked* → GameManagerCancelSelection` (once-late optimisation comment `:30-31`), mirrored in `misc.script:6418-6444/6458-6470` (`_misc_SetUnitsToSelection` splits squad members to `TSquad.fSelected` vs `gSelectedObjects`, `GameManagerCancelSelection` when `i=count-1`), `_misc_Add/RemoveUnitsTo/FromSelection`, `_control_SelectAll*` (`control.script:24-152/420-531`), `_control_SelectOnlySquad` (`:728-…`, drummer/bagpiper carve-outs). `spmRunTime` resident at `0x511e3d/0x5125c8` (`ev_88e08…`, P11).
- `[O]` static visuals: `brushes/selection.cfg:1` — RGBA(1,1,0,1), 1 px, solid, `LineStep=1` (keep, drop [U] tag); hotkey→action table `hotkeys.cfg:1-243` (select: `Ctrl+Alt+A/Ctrl+A/Ctrl+Q/Ctrl+B/Ctrl+P/Ctrl+`/Ctrl+M/Z-family*; `interface|minimap Alt+M`; `Q viewcollision`).

### 4.2 Still-[U] — marquee inside-box predicate + projection→box mapping

The drag-rectangle `GameManager*` inside test and screen→world rect mapping are engine-side (no readable predicate; P5 negative expected). `SelectionRectPainter` stays `PORT APPROXIMATION`.

- Experiment V2-BOX (runtime): FOW off, grid of idle peasants at known spacing; scripted drag rects (inset/outset by 1–3 px around known units, both drag directions); log `GetCountGameManagerPickedObjects` membership per rect; fit inside rule (centroid-in vs AABB-overlap vs containment fraction, edge inclusion, squad-grouping side effects). Combine with §3 projection solve for world mapping.

## 5. HUD / minimap mapping

### 5.1 RECOVERED — what is statically known

- `[O]` panel: `minimap.cfg:1-27` — `ImageWidth/Height=240, Width/Height=240, VAlign=valBottom, HAlign=halLeft, Position=(0,0,0,1), Visible=True`; `FrustumLineStyle` 1 px white pattern 65535, `Visible=False`; `FrustumVisible=True`; primitive `lens.0` 40×40 UV (0.5,0.5)-(1,1). Remainder of file is the `pl2x2.*`/`pl3x3.*` sprite atlas (3 px / 4 px cells + `.sel` variants), **not** mapping law.
- `[O]` mapping law (`misc.script:1137-1172`): visible → building ? `pl3x3.<color>` : `pl2x2.<color>` (or `.sel` when selected), via `prim` behaviour `GetOrCreatePrimitive/MMPrimitiveItemName`; invisible → remove primitive. Color index = `gMap.players[pl].color`.
- `[O]` refresh: `gui.script:3472` (`_misc_UnitUpdateMiniMapPrimitive(goHnd,bPicked)` per HUD pass); `player.script:769` same on ownership/progress path.
- `[O]` FOW tint (`gui.script:3478-3496`): `bNotInFOW := (not GetFOWEnable) or (GetFOWLOSData>0)`; `bVisible := bgeology or bNotInFOW`; geology-visible-but-LOS-zero → `userBlend := 0.5` else `1.0` (resource row path; unit rows share the `bPicked` refresh, exact unit tint arm still needs the surrounding `gui.script` block read — listed as S2 below).
- `[O]` viewport box: `FrustumVisible/lens.0` + `FrustumLineStyle` keys exist; world→minimap scale/offset math is engine-side → [U].

### 5.2 Still-[U] — minimap scale, frustum box projection, explored tint for units

- Experiment V2-MINI (GPU + runtime): FOW off, full-map screenshot + minimap capture at known camera; fit world→minimap affine (scale/offset, aspect with 240² panel vs non-square maps); move camera, fit frustum `lens` quad vs projection (§3); FOW on: sample never-seen / seen-now / explored-not-visible cells for units vs resources to close the unit-tint arm. Static head-start: finish reading `gui.script` minimap/HUD block around `:3472` + `InitMinimap` state (reached via `control.script:719`).

## 6. Save contract fields

### 6.1 RECOVERED — record inventory (was U15/R1-head)

- `[O]` save/record transport is the `RecordCustom*` net/replay package API, resident in CODE (`RecordCustomBegin` 6 hits `ev_a6f63…`, VAs `0x682336…0x68290a`). Skirmish offline save has **no donor byte format recovered** — port `serialize()` v4 stays `PORT EXTENSION`.
- `[O]` per-record field lists are statically enumerable from `units/global.inc/read*.inc + write*.inc` pairs (all read-only, no binary needed): `read/write-player` (package = `uid:int + cap:bool`, `writeplayer.inc:16-17 / readplayer.inc:8-9`, then `_misc_ChangePlayer` — network capture path, NOT persistent save); `read/write-peacetime` (`bool bstate`, `writepeacetime.inc:27`); plus `read/write-{apply,construct,death,free,freelist,gate,leave,leaveorder,move,new,newp,order,package,proj,projfree,rally,search,squadlistaction,squadnew,stand,stop,sync,syncunitsparams,trade,traderesources,upgrade,wall}` + `read/write-peace…/progress…/serial.script:1035-1036/1106 (fBaseCount/fStandGround)` + `progress.inc/writestats/writeres/writescenario` families. `onbeforesave/onafterload.inc` are trivial (`SwitchTo('Progress')`).
- `[D]` byte framing (`[*] =` engine-bound lines, field order vs wire order, integers/floats/bools encoding) is engine-side → [U]; no claim about donor save compatibility is possible statically.

### 6.2 Still-[U] — contract declaration

- Experiment R1 (text-only, no GPU): enumerate every `write*.inc` field in record order into a table (type per `RecordCustomWrite*` call), pair with `read*.inc` order; mark asymmetries; declare port save `PORT EXTENSION` with explicit non-parity contract; add round-trip determinism test (RNG states, queues, cooldowns, projectiles, corpses, stamps — cf. `PORT1TO1 §10` gap list). `deserialize` v3 path needs proof test or removal.

## 7. Global tick order / interleave

### 7.1 RECOVERED — per-player slice + per-unit body (was U1/O1-head)

Per-player `Progress` slice (`units/global.inc/progress.inc:37-180`), all `[O]`:

1. stagger gate: `addtime := 0.125*plInd + TimeCheckExists*4` (alive) or `*12` (dead/absent) with `TimeCheckExists = 0.01*200 = 2.0 s` (`dmscript.global:1484`) → effective 0.5–2.0 s+ cadence (`:56-61`);
2. `bexists` rule + lose-stamp + kill-units (`:65-141`, = DEC_U_skirmish §2.5, includes `farmused`, peasant visual+essential-none / inside-transport fallback, built-`center` fallback, battle-mode exemption);
3. `if plInd < MaxPlayerCount-1: _player_ProcessResourceIncome → _player_ProcessResourceConsume` (`:144-148`);
4. non-AI `CalcSquadsMoveCount` on `(0.001*plInd + TimeCalcSquadsMoveCount=0.3 s)` cadence (`:150-154; :1485`);
5. squad hold-mode progress `+= dt/37.5 s` (`gc_squad_holdmode_time = 150*8*0.03125`, `:156-172; :180`);
6. non-AI `CheckSquadsDisband` (`:174-175`, disband fraction `basecount*0.25 :15`, `gc_player_SquadDismissPercent=0.25 :156`);
7. `if bexists and (AI or adviser-enabled): ExecuteState('ProgressAI')` (`:177-178`).

Per-unit `Nothing` body (`units/unit.inc/nothing.inc:1-594`), all `[O]`: movie-block → `bbuilt` gate → `gametime/uniqrnd/deltatime/progresstick` snapshot → walk-sound + `attackdelay-=dt` → client/replay fast path (scangrid + stamp, `:96-112`) vs server path: topology (`lasttimetopology`, `TimeTopology=0.1*top_UnitTick−0.025 :1481`), scangrid (`TimeScanGrid=1.675 s :1478`), idlegrid (`TimeIdleGrid=3.075 s :1477`), birth-hang fix, enemy-search scheduler (`lastsearchenemy + uniqrnd*0.15+0.3`, order-gated allow-search matrix, water/art/smart-art branches, `cProgressSmartSearch=3 :441-443`), famine roll / rebellion flip / capture check (`:450-535`), reach test (`cProgressTestReach=3 :537-565`), ship best-position (`TimeFindBestPosition=3.075 s :1482, :567-584`), `_misc_DoProgressOrders` (`:585`), stamp `lastprogresstime/progresstick++` (`:587-588`). Jitter init `random*Time…` (`miscext2.script:2757-2761`, `serial.script:870-874`).

Conversions `[O]`: `gc_frames_to_time=0.03125 (:174)`, `gc_pixels_to_tile=53.3333333 (:172)` — i.e. px→tile /53.333; px→m /26.666… iff tile=2 m (`[D]`, consistent with DEC_U_skirmish usage `214/px→≈4.01`, `160→≈3.0`, `426→≈7.99` when read as metres); `gc_c1rand_to_random=32768 (:176)`; `_misc_PixelsToTiles/FramesToTime/RandToRandom/RandomInt` (`misc.script:462-498`).

### 7.2 Still-[U] — global interleave

Player-vs-player order, unit iteration order, and `Progress` vs unit-`Nothing` vs engine systems (pathing/separation/render) phasing are engine-driven; client/replay branch (`:46-48`, `:96-112`) further splits behaviour.

- Experiment O1 (determinism harness, no GPU): freeze `TICK_ORDER v1 PORT APPROXIMATION`; fixed seed + fixed order-list → fixed-hash test; then vary entity-array order and player count to exhibit order sensitivity; recover remaining stagger constants (`gc_top_UnitTick`, battle-music interval `400 :1228`) only as cited. Global order stays `[U]` until a `ProgressAI`/`DoProgressOrders` phasing read or engine trace lands.

## 8. Delivery-radius call-site split (was E1 — CLOSED as split)

Three distinct radii, all `[O]` — port must branch per call site, never unify:

| Call site | Literal | Meaning |
|---|---|---|
| global default `dmscript.global:210,220` | `gc_gameplay_resourceDropRadius = 3`, `…Sqr = 9` | metres-ish gameplay default; port `DELIVERY_RADIUS_M=3` grounded **only** where this global is consumed |
| peasant storehouse drop `unit.script:9702-9705` | `const gc_gameplay_resourceDropRadiusSqr = 0.5` (local shadow) | squared-distance < 0.5 vs storehouse `resourcePoint`-corrected position (`:9702`); commented-out plain-distance line above (`:9703`) is dead |
| fisher port drop `unit.script:12029-12033` | `const gc_gameplay_resourceDropRadiusSqr = 4*4` (local shadow) | squared-distance < 16 vs `GetPortResourcePoint` (`:12028`); golden path then `FisherAddRes + resamount:=0 + random-water re-target` (`:12035-12050`) |

`[D]`: the two `const … = …Sqr` lines lexically shadow the global inside their functions; port code reading the global at these two sites is wrong-shape. Fisher radius-change draw `(0.5+random)*gc_fisher_radius_move_change (:12039)` needs its literal recovered alongside (text-only follow-up S3).

## 9. Port change list (owner/COORD applies; this worker wrote no code)

Paths are `variant3d/scripts/…` (verified present):

1. `camera.gd` + `camera3d.gd` + `config.gd:48-51,76-78`: pin `SphereHeight/SphereLength=58`, `Min=20`, pitch `−32` (all heights), `Focal 400 fixed`; cite `camera.cfg:6-10,32-35,44-45`. Keep `FOV 17.27°` (or any derived angle), smoothstep framing, `HeightTarget` handling tagged `PORT APPROXIMATION` (§2.2-V1, §3-V2).
2. `world.gd` + `world3d.gd` + `world3d_fog.gd` (FOW): implement `_unit_GetVision` verbatim (`floor(20+4·vision)`, dead/unbuilt/invisible→0; fogreveal→`floor(dx)`; `unit.script:11565-11614`); gate via `_player_UpdateFOW` (`player.script:453-478`: balloon/victorystate/editor-flag, team share, `SetFOWDovFunc/SetFOWEnable`); scenario `revealZone` create/remove + `FOWBuildFull` (`scenario.script:1851-1864`); picking veto + resource-tint veto via `GetFOWLOSData>0` (`control.script:270-273`, `gui.script:3479-3496`); `DynFog*` stays visual-only (`camera.cfg:59-64`), never gameplay. Grid/combine/occlusion stay `[U]` (F1-GRID/F1-MINI).
3. `input_controller.gd:1-120` + `picking3d.gd` + `hud.gd` (selection): single-click = §4.1 prio table (`dmscript.global:227-233`) + `(1+dist)/prio` + AABB + triple `Playable∧Visible∧Collision` + minimap-under-mouse exit + FOW veto; write protocol `Begin→Start('spmRunTime')→Picked→Cancel-once`; squad split (`misc.script:6409-6448`); hotkeys `hotkeys.cfg`; brush `selection.cfg` (yellow 1 px solid). Marquee inside-box stays `PORT APPROXIMATION` (V2-BOX).
4. `hud.gd:345-368,806-981` + `config.gd` (HUD/minimap): panel `240² bottom-left (0,0,0,1)`, frustum style keys (`minimap.cfg:1-27`); per-unit `pl2x2/pl3x3.<color>/.sel` mapping (`misc.script:1137-1172`); `SetPlayer→UpdateFOW→DoUpdateSelection→InitMinimap` (`control.script:712-720`); resource LOS-blend `0.5/1.0` (`gui.script:3488-3491`); world→minimap scale + frustum quad stay `[U]` (V2-MINI).
5. `game.gd:6304-6401` (save): declare `PORT EXTENSION` non-parity contract; enumerate `read*/write*` pairs (§6.1) for field order; add missing state (tileblock/mine_mask/stamps/nav_version/RNG states/queues/cooldowns/projectiles/corpses/acq); `RecordCustom*` (P12 VAs) is net/replay transport, not offline-save proof. `writeplayer` uid+cap and `writepeacetime` bool are message payloads, not save fields — do not cite as save evidence.
6. `game.gd:4625-4685,5281-5306` (tick): implement per-player slice order §7.1 (stagger `0.125·plInd + 2.0·{4,12}`, exists→income→consume→squad-count→hold→disband→ProgressAI) and per-unit `Nothing` stage list with `cProgressSmartSearch/TestReach=3`, `Time{Scan,Idle,Topology,FindBest}=1.675/3.075/…/3.075 s`, search scheduler `uniqrnd·0.15+0.3`; freeze remainder as `TICK_ORDER v1 PORT APPROXIMATION` + fixed-seed hash test (O1).
7. `game.gd` gather/drop sites (delivery): branch three radii §8 (global 3 vs storehouse 0.5-sqr vs fisher 16-sqr, with resourcePoint/port-point corrections); transcribe `gc_fisher_radius_move_change` literal (text-only).
8. `data.gd` conversions: `px→tile /53.3333333` (`dmscript.global:172`), `frames→s ×0.03125` (`:174`), `c1rand→random /32768` (`:176`), `s→frames ×32`, tower/capture/protection radii via `_misc_PixelsToTiles` (`:205-209`: 1280/160/214/426 px); vision examples §1.1; `SquadDismiss 0.25` (`:156`), hold `37.5 s` (`:180`), `TimeCheckExists 2.0 / CalcSquads 0.3 s` (`:1484-1485`).
9. `ai.gd` (untouched by findings except cadence reuse): `ProgressAI` gating (`:177-178`) is the only grounded hook; thresholds stay `PORT-AI` (A1 lane, not this ticket).
10. Telemetry/format: keep `PORT APPROXIMATION` tags per-field; unresolved = `[F1-grid/combine/occlusion, V1-sensor/FOV, V2-projection/box, V2-MINI scale/tint-tail, R1-framing, O1-global-interleave, S2-unit-tint-arm, S3-fisher-radius-literal]`. `visual_parity_claim=false`.

## 10. Explicit non-claims + file discipline

- No parity claimed. No donor binary executed, no GPU frame captured, no port capture compared. Closed items rest on donor text `[O]` with file:line; open items list exact next reads/captures in §§1–8.
- No approximation substituted: every recovered literal replaces a port estimate 1:1; everything else remains labelled `[U]` with a settling experiment.
- Read-only compliance: exactly one repo file written (this report). Native passes pinned to `t_87f0f3c130b0` (P1–P12 with evidence ids + VAs/file-offs above); shared Craft Anything investigation memory was read, never written; no target opened/selected/closed by this worker.

*End of DEC-U-FOG-CAMERA-HUD.*
