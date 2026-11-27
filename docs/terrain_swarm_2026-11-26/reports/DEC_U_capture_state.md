---
id: DEC-U-CAPTURE-STATE
worker: DEC-U-CAPTURE-STATE (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. Donor binary never executed/copied/opened as target. Donor text scripts/data read as text only. No repo code/asset/config/Godot/git edit: this report is the only file written."
network: "OUT OF SCOPE. All _net_IsClient/_net_IsReplay/_net_IsServer/_net_IsRecord/bProcess branches are cited only as exclusion boundaries. blan/WritePlayer tails out of scope."
parity: "NO PARITY CLAIM. No donor GPU A/B frame; no donor binary executed by this worker. All [O] are donor TEXT with file:line; every number the port needs but the donor text does not give stays [U] with an exact capture."
context: "DEC_U_skirmish_tables.md closed the capture HEAD predicate (80% shapes: cadences, radii, AI die rolls) and DEC_U_capture_flush.md is active on the order-flush arm. This ticket covers what both leave open: capture PROGRESS accumulation, majority/cooldown tail, garrison/hide states, ownership-transfer counter/FOW effects."
labels: "[O] verbatim donor literal (file:line) · [D] deterministic reading · [I] inference, flagged · [U] UNVERIFIED with exact experiment · PORT APPROXIMATION = port substitute to remove for 1:1"
---

# DEC-U-CAPTURE-STATE — building-capture state machine: progress, majority/cooldown tail, garrison/hide, ownership transfer, FOW/team effects (2026-11-26)

## 0. Pin + pass ledger (every pass pinned `t_87f0f3c130b0`; donor read-only, never executed)

| # | Pass | Result / evidence |
|---|---|---|
| P1 | Pin re-assert | `(Get-Item cossacks.exe).Length` = **5,768,048 B**; `(Get-FileHash SHA256).Hash` = `87F0F3C130B027E7C4E72DC217EAE9D592982370D112E0D224897BC92AF4E16C` (case-insensitive match to `t_87f0f3c130b0`). No binary executed, copied, or opened as a target. EV-CS-PIN |
| P2 | `miscext.script:892-959,963-1185,1187-1214` full re-read | EV-CS-XFER: `_misc_ChangePlayer` strip+swap law; EV-CS-CHECK: `_misc_CheckCapture` boolean-instant law; EV-CS-SQUAD: `_misc_SquadChangePlayer` adjacent path (bCapture=False) |
| P3 | `building.inc/nothing.inc:293-326` + `unit.inc/nothing.inc:507-535` cadence re-read | EV-CS-CAD: `lasttimecheckcapture` gate is the ONLY capture timer; no progress accumulator |
| P4 | Zero-hit probes (method: text grep over script tree, not binary) | EV-CS-NOCAP: `capture_t\|capturet\|CaptureProgress\|captureprogress\|capture_cool\|capturecool\|capturelock\|capture_tick` → **0 hits**; i.e. no donor capture-progress/cooldown field exists in script text |
| P5 | `unit.script:4617-4691,4693-4763` search procs | EV-CS-SEARCH: `_unit_SearchProtectors/_unit_SearchCapturers/_unit_SearchCapturersForWall` + `_unit_CheckCapturersStopProduce/_unit_TestCapture` filter law |
| P6 | `unit.script:3787-4001` counter procs | EV-CS-COUNT: `_unit_AddObjToPlayerCounters/_unit_RemoveObjFromPlayerCounters` exact transfer arithmetic |
| P7 | `unit.script:11563-11627` vision + `3135-3167,3169-3300,3601-3700` grid/topology/AI procs | EV-CS-VIS: `_unit_GetVision` formula; EV-CS-GRID: ScanGrid/Topology/AIData add/remove law |
| P8 | `unit.script:3016-3099,5540-5590,10025-10123` + `2311-2316,2043-2048` absorber/transport rows | EV-CS-GAR: mine `peasantabsorber=5`, ferry `transport=120`, GoInside/DoHideInside/AddInside/RemoveFromInside law; tower-garrison ABSENCE |
| P9 | `building.inc/ontagstates.inc:80-191,240-336` + `unit.inc/ontagstates.inc:537-551,890-923,11009-11159` tag transitions | EV-CS-HIDE: `visual_hide` transition effects (building + unit); birth/death stage law |
| P10 | Port `game.gd:1996,2724-2745,2960-2999,3782-3786,4150-4185,4988-4989,5356-5439` + `data.gd:57,329,346,1245-1286` read-only inspection (no edit) | EV-CS-PORT: port `capture_t` accumulation, `garrison/hidden/inside_of`, `captured_nations`, score/farm handling as PORT APPROXIMATION baselines (§7) |
| P11 | `dmscript.global` constant re-pin | EV-CS-GLB: statetags (`:5-7,30,35,41`), scangrid (`:55-60`), `MaxOrderCount=12` (`:113`), slow-death (`:129-131`), radii (`:207-209,217-219`), usages (`:310,314`), `gc_argunit_inside=4` (`:830`), map modes (`:1072-1075`), cadences (`:1476-1482`), orders array (`:1763`) |

DSL note `[D]` (inherited): donor `not X` on a numeric lvalue is the current-value read, not boolean negation.

---

## 1. Progress accumulation: donor has NONE — capture is boolean-instant per cadence tick [O]

1.1. The only capture timer in the donor is `lasttimecheckcapture`, armed in the `Nothing` tick, never inside the capture path:
- Buildings-unbuilt, always: `if gametime>lasttimecheckcapture { lasttimecheckcapture := gametimewithrnd+TimeCheckCapture; _misc_CheckCapture }` (`building.inc/nothing.inc:300-304`) `[O]`.
- Buildings-built + `bcapture`: same gate, then map-mode switch (`:311-326`): `default/nopeasants → CheckCapture`; `nocenterspeasants → skip center`; `onlyartillery → (empty: NO check)` `[O]`.
- Units + `bcapture` + playable (`unit.inc/nothing.inc:507-535`): non-art `lasttimecheckcapture := gametimewithrnd{…}+TimeCheckCapture`, art `+TimeCheckCaptureArt` (`:512-515`); `default or bart → CheckCapture`; `onlyartillery and bart → CheckCapture`; the `nopeasants/nocenterspeasants` commented block (`:520-534`) is dead `[O]`.
- Constants `[O]` (`dmscript.global:1476-1480`): `TimeEpsilon=0.025`; `TimeCheckCapture=0.1*19-eps=1.875 s`; `TimeCheckCaptureArt=0.1*5-eps=0.475 s`; init jitter `random*TimeCheckCapture` (`unit.inc/initial.inc:320`, `serial.script:870`, `miscext2.script:2757`) `[O]`.
- `gametimewithrnd := gametime+uniqrnd` (`building.inc/nothing.inc:297`) `[O]` — the jitter is per-object phase, not progress.

1.2. `_misc_CheckCapture` (`miscext.script:963-1185`) performs at most ONE ownership flip per call and writes NO accumulator: on success it falls through to the flush block (`:1111-1134`), AI die rolls (`:1143-1173`), then `bDie ? essential_death : _misc_ChangePlayer(go,newPlHnd,True,False,True)` (`:1175-1178`) `[O]`. There is no `capture_t`, no `progress +=`, no partial-credit field anywhere on the path (EV-CS-NOCAP zero-hit probe) `[O-absence, method-caveated to script text; native engine fields not probed by this worker]`.

1.3. Consequence `[D]`: "capture progress" as a decaying accumulator does not exist in the donor. The observable behaviour is: every 1.875 s (0.475 s art) the boolean predicate (enemy capturer in 8.025 m AND no protector veto AND map-mode/birth/hide/AI gates) is tested once; the first passing tick transfers ownership instantly. A lone peasant and a swarm differ only in how many cells satisfy the predicate, never in a fill rate.

1.4. Port divergence (EV-CS-PORT, no edit): `game.gd:1996` `"capture_t": 0.0` per building; `:5395-5404` `e.capture_t += dt * (peas*1.0 + sols*0.25) [*0.5 if garrison>0]` to `need = 5.0 + max_hp/2500`, with `:5439` decay `capture_t - dt` when no capturer; `:5396-5397` garrison-halving; `:5403` white-flag event text. ALL of this — rate, need formula, soldier weight 0.25, garrison ×0.5, decay — is PORT APPROXIMATION with no donor literal behind it. Change list §7 item 1 replaces it with the cadence-gate law. Static state of the rate question: CLOSED against the donor (no rate exists); behaviour stays `[U]`-CS-PROGRESS until the fixed-seed trace passes (§6).

---

## 2. Majority / cooldown tail: NO majority count, NO post-capture cooldown [O]

2.1. General case — single-protector veto, not a majority vote `[O]` (`miscext.script:1041-1072`): own-mask cells in `floor(protectionradius/scangrid)+1` are scanned with `_unit_SearchProtectors`; any hit with `not bcapture` and `distSqr < protectionSqr` sets **`bcapture := False`** immediately and `protectorsCount += 1`. One uncounted protector outvotes any number of capturers. `protectorsCount` is accumulated but NEVER compared in the general path — it is only read by the AI-artillery exception below `[D]`.

2.2. Sole exception — AI-owned artillery suicide table `[O]` (`:1073-1088`): only if owner `bAI` and target `bartillery`, and only after the non-wall hp gate: `(prot=1 and cap>=prot) or (prot=2 and cap>3) or (prot=3 and cap>7) or (prot=4 and cap>10)` → `if (not bEasy) or (random>0.5) → essential_death, exit`. `bEasy := aidifficulty < veryhard` (`:1031`) `[O]`. prot≥5 has NO row: 5+ protectors on an AI gun can never trigger this death (falls through to the normal veto, which already killed `bcapture`) `[D]`.

2.3. Non-peasant blockshot freeze is NOT a capture cooldown `[O]` (`:1036-1040`): non-peasant target + `distSqr < blockshotSqr` sets `attackmaxdelay/attackdelay := MaxFloat(…, 100*frames_to_time = 3.125 s)`. It delays the victim's shooting, never the next capture test.

2.4. No post-capture cooldown exists `[O-absence composed to law]`: neither `_misc_CheckCapture` nor `_misc_ChangePlayer` writes `lasttimecheckcapture`; the next test is gated solely by the pre-existing `lasttimecheckcapture` armed in `Nothing`. After a flip at time T with next-check at Tnext > T, the new owner is re-testable at Tnext with zero additional lockout `[D]`. Do NOT port any `capture_cooldown / capture_lock / immunity_t` field.

2.5. Ancillary search laws that constrain the tail `[O]`:
- `_unit_SearchCapturers` (`unit.script:4641-4664`): non-building + `bcancapture` + mask hit + `pl <> mercenary` → return. No hide-tag test, no count, no distance test inside (distance is tested by the caller `:1017-1018`).
- `_unit_SearchCapturersForWall` (`:4668-4691`): drops the `bcancapture` requirement (any non-building enemy unit counts vs walls).
- `_unit_SearchProtectors` (`:4617-4637`): `bprotector` + non-building + `(myplmask & plmask)=0` → return. Hidden units carry no tag test here either — they are unreachable because `visual_hide` transitions call `_unit_ScanGridRemoveUnit` (EV-CS-HIDE); the scan only sees grid members `[D]`.
- `_unit_CheckCapturersStopProduce` (`:4693-4727`) and `_unit_TestCapture` (`:4729-4763`) are read-only probes (no state write): any `bprotector` hit in radius ⇒ True/False. They do not arm, reset, or consume any capture state `[O]`.

---

## 3. Ownership transfer: `_misc_ChangePlayer` verbatim pipeline + exact counter/FOW effects [O]

3.1. Call context `[O]`: capture reaches `ChangePlayer(go,newPlHnd,True,False,True)` only after: neutral gate (`:970-971`), capturer filter (`:1003-1028`), peacetime rules (inherited), wall-hp gate (`:1034`), blockshot freeze (`:1036-1040`), protector veto (`:1041-1072`), AI-artillery death exit (`:1073-1088`), birth/hide gate (`:1093-1099`, §4), hide gate (`:1100`), flush block (`:1111-1134`, FLUSH report), AI die rolls (`:1143-1173`, TABLES §3). `newPlHnd` is the capturer unit's owner handle (`:1136`); IO-party alarm fires pre-flip (`:1139-1140`).

3.2. Transfer pipeline, verbatim order `[O]` (`miscext.script:894-959`):
1. `prevPlInd := TObj.pl` (`:900`).
2. If `GetTagStateByType(hide)=0` (target NOT hidden): `SetSTO(go,0)`; `PathListRemove(go)`; `FixArgLists(go)`; `for i := MaxOrderCount-1 downto 0: if not (none or move) → RemoveOrder(i)` (`:901-911`). Hidden targets SKIP this strip but CONTINUE to the swap (the `if` covers only `:903-910`, not `:913+`) `[D — load-bearing for CS-HIDE]`.
3. `bbuilt := TObj.bbuilt` snapshot; `RemoveObjFromPlayerCounters(go, bbuilt, bCapture)` under the LOSER (`:913-914`); `SetGameObjectPlayerHandleByHandle(go,newPlHnd)`; `TObj.pl := newPlInd` (`:915-917`).
4. `AddObjToPlayerCounters(go, bbuilt, bCapture, bCustom)` under the WINNER (`:919`); `gGuiUpdateHighlights.Add(go)` (`:920`).
5. Mine-insider recursion (`:922-947`): every handle in `gc_argunit_inside` list is itself `ChangePlayer(trg,newPlHnd,bCapture,bCustom,blan)` (`:933`), then `ScanGridRemoveUnit(trg) + SetSTO(trg,go)` (`:934-935`); if usage=mine, `resincome[i] ±= produce[i]*insideCount` moves loser→winner (`:937-945`).
6. LAN tail (`:950-957`): `WritePlayer` with `fcapture=bCapture` when online/record — out of scope, cited as boundary.

3.3. Counter arithmetic — exact, asymmetric `[O]` (`unit.script:3787-4001`):
- Gate: first block runs `if (not bbuilding) or (bbuilt) or (bcaptured and TObj.bbuilt)` (`:3798`, remove `:3884`). An unbuilt building transferred with `bCapture=False` (e.g. mercenary-rebellion path `:495`, cheat path `miscext2:3227`) does NOT move `built/farm/resconsume/scores`; with `bCapture=True` it DOES (capture forces the block even when `bbuilt=False`) `[D — load-bearing: capture of a construction site still transfers its counters]`.
- `counter.built[cid][id] ±1` (`:3801/:3887`); `counter.all[cid][id] ±1` + `counter.total ±1` (`:3847-3850/:3969-3972`); farm `±prop.farm` (`:3805/:3891`); `resconsume[i] ±= consume[i]` all 6 (`:3809-3810/:3895-3896`); units only: `farmused ±1`, plus `resconsume[food] ±= 30` unless `bnohungry` (`:3819-3821/:3905-3907`, `gc_obj_foodperunit=30` per TABLES §1.0).
- Artillery/depot: `artlimit += prop.artdepo` / `artcount += 1` for `artind > none` (`:3826-3833`), mirrored on remove (`:3930-3937`) `[O]`.
- Scores are deliberately asymmetric `[O]`: ADD `scores += score*5` when captured else `*1` (`:3836-3841`); REMOVE `scores -= score*5` when captured, `*3` when rebellion+mercenary, else `*2`, clamped at 0 (`:3940-3950`). Net of a capture flip: loser `−5×score`, winner `+5×score` — a 10×score swing, not a move `[D]`.
- Stats: `produced +1` only when NOT captured and NOT custom (`:3813-3814`); `killed +1` only when NOT captured (`:3899-3900`). Captures never inflate either stat `[O]`.
- Roster/lists: buildings `Add/RemoveObjToPlayerLists` (`:3824/:3928`); walls additionally `gWallSystem.RemoveHandle` (`:3953-3954`); AI buildprojects reset (`:3956-3962`); ctrlgroups wiped 10× (`:3991-3998`); `LanSyncUnitsParamsUIDList` entry removed (`:3977-3978`); IO-selection deselected (`:3980-3988`).

3.4. FOW/team/grid effects — exact `[O]`:
- ScanGrid re-key: remove runs `_unit_ScanGridRemoveUnit` (`:3974` → `gScanGridUnits[pl].Remove + gScanGrid.Remove(mat, pl)`, `:3157-3167`); add runs `_unit_ScanGridAddUnit` (`:3856` → `gScanGrid.Add(mat, NEWpl) + gScanGridUnits[NEWpl].Add`, `:3135-3153`). Post-flip the object senses AND is sensed as the winner's: future capturer/protector scans, `fPlMask` aggregation, and minimap aggregation follow the new key `[D]`.
- AIData: `RemoveFromAIData` pre-flip when processing AI (`:3965-3966`); `AddToAIData` post-flip when `(processingAI and winner-AI) or (winner-human and adviser enabled)` (`:3853-3854`) `[O]`.
- Topology: `TopologyRemove` (`:3975` → danger/attract deltas by OLD pl, `:3248-3300`); `TopologyAdd` when `(bcaptured) or (not building) or (bbuilt) or (bcustom)` (`:3862-3863` → `changeDanger/changeAttract[NEWpl]`, `:3169-3205`) `[O]`.
- Recolour + highlight: `ApplyKeyColorRecursiveChild(go, winnerColor)` (`:3860`); `gGuiUpdateHighlights.Add(go)` (`:920`, GUI consumes at `gui.script:3383-3569`) `[O]`.
- Vision follows WITHOUT any tag change `[D]`: `_unit_GetVision` (`:11563-11614`) returns `floor(20 + 4*prop.vision)` iff visible AND `not bdead` AND `bbuilt`, else 0 (fogreveal-projectile branch `:11572-11587` excepted). `ChangePlayer` touches no visual/essential tag, so vision RADIUS is unchanged but its PL ATTRIBUTION flips with the scangrid key. No fog-reveal call, no minimap-primitive create/destroy, no territory-owner write occurs in this proc — fog/territory updates are engine-side downstream of the grid key `[I — flagged; engine FOW not decompiled by this worker]`.
- Team: no team field is read or written anywhere on the path; allies/enemies follow from `enemyplmask/myplmask` of the new `pl` on subsequent scans. No team-transfer bonus, penalty, or veto exists `[O-absence over the cited procs]`.
- Adjacent non-capture path (do not conflate): `_misc_SquadChangePlayer` (`:1189-1214`) moves squad members with `ChangePlayer(go,newPlHnd,False,True,True)` + `squad := newInd` + `SetupGroup/SetGroupCollisionOptions`, `fPlIndex := newPlInd`. `bCapture=False` ⇒ different counter gate (`:3798/:3884`) and stat effects (`produced` IS incremented). Never cite it as capture law.

---

## 4. Garrison / hide states: what the donor HAS vs the port's tower garrison [O]

4.1. Donor garrison equivalents — mines and transports ONLY:
- Mine absorber: `objprop.peasantabsorber := 5` for `gol/iro/coa` mines (`unit.script:2311-2316`) `[O]`; `produce[gold/iron/coal] := 13` (`:2318-2322`); `bslowdeath := False`, `exitMaxDelay := 0.5` (`:2316-2317`) `[O]`.
- Transport: ferry `transport := 80+40` (`:2043`), `usage=transport`, `bnohungry` (`:2043-2045`) `[O]`.
- `_unit_CanGoInside` (`:10048-10056`) `[O]`: building target ⇒ allowed ONLY `trg.usage=mine AND unit.usage=peasant`; non-building target ⇒ `trg.transport>0 AND unit non-building AND media=land`. Towers/centres/barracks can NEVER absorb in the donor — the port's `tow/cen` garrison has no donor counterpart (see 4.4).
- `_unit_OrderGoInside` (`:5556-5590`) `[O]`: capacity `(inCount+insidereserved) < (absorber+transport)`; reserves `insidereserved += 1`; peasants→`gotomine`, else→`gototransport` order appended.
- `_unit_DoHideInside` (`:3087-3099`) `[O]`: `AddInside + FullClearOrders + SetTagStates(visual_hide [+ essential_birth if not already birth])`. `FullClearOrders` (≠ `ClearOrders`) clears STATIC slots too (`:2884-2890`) `[O]`.
- `_unit_AddInside` (`:3018-3032`) `[O]`: `insideofuid := trgUID`; `winner.resincome[i] += produce[i]` per resource (attributed to the TARGET's owner at hide time).
- `_unit_RemoveFromInside` (`:3034-3083`) `[O]`: resolves STO vs `insideofuid` (replay/client vs sim branches `:3042-3056`); `inside.Remove(go)`; `resincome[i] -= produce[i]`; clears `insideofuid/bLeaveRequested`. Logs `trgHnd=0` if orphaned (`:3081`).
- Capacity probes: `_unit_IsUnitCanAbsorbInside` (`:10027-10044`), `_unit_UnitsCanGoInside` (`:10058-10123`) — `bbuilt` + free-slot + per-candidate `CanGoInside` scan `[O]`.

4.2. `visual_hide` transition effects — complete `[O]`:
- Buildings (`building.inc/ontagstates.inc:171-190`): `Visible(False)` + `CollisionDetection(False)` + `Playable(False)` + `Picked(False)` + `Selected.Remove` + `GuiUpdateHighlights.Add` + **`ScanGridRemoveUnit`** (`:172-179`); un-hide restores playable/collision/highlight + `ScanGridProgress` (`:183-188`).
- Units (`unit.inc/ontagstates.inc:11009-11138` / `ForceState` mirror): same visible/playable/collision-off + STO-keyed `inside.Add(hnd)` + `UnitRemoveMiniMapPrimitive + Picked(False) + Selected.Remove + GuiUpdateHighlights.Add` (`:11109-11129`); un-hide (`visual_none` while invisible) re-creates the minimap primitive + restores playable/collision + highlight (`:11131-11138`). The commented hide-add block (`:537-547`) is dead code — the live add is `:11122-11128` `[O]`.
- Essential interplay (`unit.inc/settagstates.inc:143-146`) `[O]`: `visual_hide + essential_none` is declared impossible by the engine (`ErrorLog … that should be impossible`) and force-remapped to `essential_birth`. Hide therefore ALWAYS pairs with birth or death, never with none `[D — load-bearing for 4.3]`.
- Hidden units die hidden: `essential_death + visual_hide` (inside mine/transport) runs `DoDeath + animNone + DeathStage4` (`:11076-11081`, `:551-563`) `[O]`.

4.3. Hide × capture interaction — exact `[O]`:
- Target gate: the flush/transfer block runs only `if (statetag and visual_hide)=0` (`miscext.script:1100`). A hidden BUILDING (inside nothing — buildings are never absorbed, so in practice only editor/cheat states) cannot be captured and cannot be died-by-capture `[D]`.
- Birth gate (`:1093-1099`): non-building + `essential_birth` + hide-UNSET ⇒ `essential_death`, exit ("should be change player … death only if this is ai?" comment kept verbatim). A hidden (`hide≠0`) birth unit SKIPS this death and falls to `:1100`, where a non-building takes `_unit_Stop` (`:1111-1112`) — never the transfer. Net: hidden units are NEVER `ChangePlayer`'d by capture; they are stopped or error-logged (`:1180-1181` mine-STO branch) `[D]`.
- Hidden TARGET with `ChangePlayer` (cheat/editor path, not capture): the `:901` hide gate skips STO/path/arg/order-strip but the ownership swap (`:914-919`), counters, grid re-key, insider recursion, and LAN tail still execute `[O]`. Port must preserve this asymmetry (see §7 item 4).
- Mine-insider flip on capture (`:922-947`): insiders are `ChangePlayer`'d recursively WITH the mine (`bCapture` inherited), `ScanGridRemoveUnit(trg)` + `SetSTO(trg, goMine)` re-pointed at the mine under its new owner, `resincome` moved loser→winner by `produce×insideCount` (`:937-945`) `[O]`. Insider queues: peasants hold no produce/upgrade slots, so neither the flush (produce/performupgrade only) nor the `ChangePlayer` move-keeping strip touches them; their `gainres` infinite-detach bookkeeping is untouched by name — claiming more (peasant load preservation) is `[U]`-CS-GAR (§6).

4.4. Port tower/centre garrison is PORT APPROXIMATION with NO donor counterpart `[O-absence]`:
- `cmd_enter` (`game.gd:2972-2985`): same-player, `tow/cen` only, no artillery/cavalry, cap 10, sets `inside_of/hidden=true/garrison+=1`. Donor allows garrison ONLY in mines (peasants) and transports — `tow/cen` have `peasantabsorber=0, transport=0`, and `_unit_CanGoInside` returns False for them. No donor line permits it.
- `game.gd:5356` tower fire `2×garrison`, `:5358-5361` garrison heal `2.0/s`, `:5396-5397` capture-rate halving when `garrison>0`, `:2999` unload-zero, `:4166-4172` garrison-dies-with-building: all five are port inventions (siege feel), none has a donor literal. Keep labelled until CS-GARRISON passes; do NOT delete (they are the port's playtested loop, `t_capture.gd:103-106`).

---

## 5. FOW / team / alarm / rally summary (all [O] unless flagged)

- Alarm: `if TObj.pl = IO-party → _misc_DoAlarm(capturerHnd, go, capture)` (`:1139-1140`) — pre-flip, victim-side keyed `[O]`.
- Rally/STO: capture zeroes STO twice (`ChangePlayer :903`, flush `SetSTO(go,0) :1133`) and `PathListRemove/FixArgLists` non-hidden targets (`:904-905`); rally restore (`game.gd:5431-5434` `_default_rally`) is port-side — donor rally after capture is whatever `SetSTO(go,0)` leaves (zero), plus `bRally` flag untouched on the TObj (rally POINT retention across capture is `[U]`-CS-RALLY, §6).
- Selection/ctrlgroups/minimap/highlight: covered in §3.3-3.4, all `[O]`.
- Score/farm/counters: §3.3, all `[O]`.
- FOW engine gap `[I — flagged]`: scangrid re-key + `GetVision` attribution flip are script-side `[O]`; actual fog-texture invalidation, territory (`gScanGrid.owner`) repaint, and enemy-minimap unveil are engine calls below the script line and are NOT specified here. The fixed-seed trace CS-FOW (§6) observes them behaviourally without asserting a mechanism.

---

## 6. Still-[U] register — each with a fixed-seed capture trace + zero-mismatch criterion

Conventions (owner-authorised; binary run by owner, never this worker): fixed seed S, fixed map, fixed nation pair (e.g. ukr vs pol barracks + mine + blacksmith), full stock unless the capture varies cost. Instrumented owner build dumps donor `orders[0..11].{iType,produceid,upgradeid,amount,restype,progress}` + `TObj.{pl,bbuilt,bdead,statetag,insideofuid,STO,scangridx/y,lasttimecheckcapture}` + `gPlayer[loser/winner].{counter.built/all/total/farmused/scores/resconsume,res[],counter.resincome,artlimit,artcount,stat.produced/killed}` + `gScanGrid` membership + `_unit_GetVision` + minimap-primitive presence per Nothing tick across the capture tick. Wall-clock IRRELEVANT. Three identical-seed runs; ANY inter-run divergence FAILS the item (quote the divergent dump, do not average).

| # | Item | Static state after this ticket | Exact experiment |
|---|---|---|---|
| CS-PROGRESS | No accumulation / instant flip | CLOSED against donor text (EV-CS-CAD + EV-CS-NOCAP): boolean test per 1.875/0.475 s tick, first pass flips | Seed S: 1 peasant in radius of empty built barracks, no protectors, `default` mode. Dump `lasttimecheckcapture/TObj.pl` per Nothing tick ±10 ticks. **Zero-mismatch:** 3 runs identical; assert `pl` flips on a tick where `gametime>lasttimecheckcapture` with NO intermediate partial state; quote `lasttimecheckcapture` before/after (expect unchanged by the flip itself). Port deletes `capture_t` rate law meanwhile (§7.1). |
| CS-COOLDOWN | No post-capture lockout; AI-artillery majority rows | CLOSED textually (§2); behaviourally `[U]` | Seed S ×2: (a) recapture race — flip A→B, hold a second enemy unit in radius, dump ticks to re-flip B→A; (b) AI-artillery table — AI gun, protectors 1..4 with capturers at/below/above each threshold, `bEasy` both ways. **Zero-mismatch:** 3 runs identical each; (a) assert re-test at next `lasttimecheckcapture` with no extra delay; (b) assert death iff table+`random>0.5` gate, else veto-hold — quote `protectorsCount/capturerCount/random` draws. |
| CS-TRANSFER | Counter/score/grid exact deltas | Laws `[O]` §3.3-3.4; ledger values `[U]` until traced | Seed S: capture a built mine (3 peasants inside) + a barracks (queued produce×2 + upgrade mid-progress — flush report owns the queue arm, this item owns the COUNTER arm). Dump full §6 ledger tick-before→tick-after + 3 ticks later. **Zero-mismatch:** 3 runs identical; assert loser `−5×score`, winner `+5×score`, `built/all/total/farm/resconsume/art` ±1 mirrors, `produced/killed` UNCHANGED, `resincome` moved by `produce×insideCount`, scangrid key = winner, `GuiUpdateHighlights` contains go. |
| CS-GARRISON | Mine-insider flip; tower-garrison absence | Mine law `[O]` §4.1/4.3; tower garrison `[O-absence]` | Seed S: 3 peasants `DoHideInside` a mine, capture the mine; separately attempt `OrderGoInside` peasant→tower (expect False/empty per `:10052-10053`). **Zero-mismatch:** 3 runs identical; mine case: assert insider `pl` = winner, `STO` = mine, `resincome` delta = `13×3` gold (or per-sid produce), queues untouched; tower case: assert refusal with the failing call's `file:line` quoted. Port keeps `garrison` meanwhile, tagged (§7.5). |
| CS-HIDE | Birth/hide gates; hidden-target strip-skip | Laws `[O]` §4.3; composition `[D]` | Seed S: (a) `essential_birth` non-building in radius (hide-unset) → expect `essential_death`, no `ChangePlayer`; (b) hidden peasant (inside mine) whose mine is NOT captured but is in radius → expect `_unit_Stop`, ownership unchanged; (c, editor/cheat only) hidden building `ChangePlayer` → expect swap WITHOUT order-strip. **Zero-mismatch:** 3 runs identical; quote taken branch + `orders[]` dump for (c). |
| CS-FOW | Vision attribution + minimap/selection follows | Formula `[O]` §3.4; engine repaint `[I]` | Seed S: unit with `vision=V` (e.g. peasant V=1/3/4 per nation, TABLES §1.3) captured via mine-insider path + building captured directly. Dump `_unit_GetVision` (expect `20+4V` iff visible/built/alive, `0` while hidden/dead/unbuilt), scangrid cell membership, minimap-primitive presence, `gSelectedObjects`/ctrlgroup membership, key-colour index. **Zero-mismatch:** 3 runs identical; assert radius same, attribution = winner; fog-texture observations quoted, never asserted as law. |
| CS-RALLY | Rally-point retention across capture | `SetSTO(go,0)` ×2 `[O]`; `bRally/rallyX/Y` untouched `[O-absence]` | Seed S: building with rally set, capture, dump `STO/bRally/rallyX/rallyY` before/after + first produced unit's exit path. **Zero-mismatch:** 3 runs identical; report observed values. Port `_default_rally` re-arm stays tagged until then. |

---

## 7. Concrete port change list (`game.gd` / `data.gd` — owner/COORD applies; this worker wrote no code)

All items add DONOR-VERBATIM law or explicitly labelled placeholders. None invents a number. None touches save version, existing keys, demo-mill/builder-stands hooks, or I11 seam paths.

1. **`game.gd:1996,5362-5439` capture accumulator → cadence gate.** DELETE the `capture_t` rate law (`peas*1.0+sols*0.25`, `need=5+maxhp/2500`, garrison ×0.5, decay) or rewire `capture_t` to store `lasttimecheckcapture` (next-allowed-test time = `time_s + uni + (1.875 | 0.475 if art)` with per-object `uni` jitter at spawn). Implement §1-§2 verbatim: unbuilt-always test; built tests `bcapture` + map-mode gate (`default/nopeasants→test`; `nocenterspeasants→skip center`; `onlyartillery→NO building tests`); unit tests `bcapture+playable` with art/non-art cadences (dead commented block stays dead); instant flip on first passing tick. Cite `building.inc/nothing.inc:300-326`, `unit.inc/nothing.inc:510-535`, `dmscript.global:1476-1480`, `miscext.script:963-1185`. Telemetry: `visual_parity_claim=false`.
2. **`game.gd:5384-5393` guard-block → protector veto.** REPLACE the port's guard-order scan (G-09) with the donor veto: ANY protector (`bprotector`, non-building — `unit.script:4617-4637`) of the VICTIM's side within `426px = 7.9875 tiles = 15.975 m` of the target kills the attempt for that tick (`miscext.script:1041-1072`). Keep the guard-order check only as an ADDITIONAL labelled PORT RULE if playtests need it — never as the donor veto. Add the AI-artillery suicide table verbatim (`:1073-1088`) with `bEasy` + `random>0.5` gate. NO majority comparison in the general path; NO cooldown field.
3. **`game.gd:5405-5434` transfer pipeline → `ChangePlayer` order.** Implement §3.2 verbatim: (a) hidden-target strip-skip (`:901`); (b) non-`none`/`move` order strip OWNER-SWAP-ADJACENT (downto loop, `:908-910`); (c) swap (`:915-917`); (d) winner-side `AddObj` + highlight (`:919-920`); (e) mine-insider recursion + `resincome` move (`:922-947`); (f) scores −5×/+5× with clamp, `produced/killed` untouched on capture, farm/farmused/art/counters mirrored (§3.3). Wire the FLUSH-report queue arms (produce/upgrade + `ClearOrders(static-preserving)` + `SetSTO(0)`) BEFORE the swap, owned by that ticket — do not duplicate here, cross-cite it. `players[old].entities ↔ players[capturer].entities`, `farm_cap`, `score`, `captured_nations` (G-07) stay as the port's roster projection of the donor counter law — add cites, keep behaviour.
4. **`game.gd:2972-2999,5356-5361,4166-4172` garrison → donor absorber law + labelled port rule.** Gate `cmd_enter` on `_unit_CanGoInside` verbatim (`unit.script:10048-10056`): buildings accept ONLY peasants-into-mines; everything else needs `transport>0` land-nonbuilding targets. Mines keep `peasantabsorber=5, produce=13` (`data.gd:1282-1286` already exact — add `unit.script:2311-2322` cite). Tower/centre garrison (cap 10, `hidden`, fire bonus, heal, capture-halving, dies-with-building) stays as explicitly labelled PORT RULE `PORT_GARRISON (no donor counterpart; CS-GARRISON open)` — never cite a donor line for it. Implement `DoHideInside` effects for mine entry: `FullClearOrders` (static-cleared), `insideofuid/STO`, `visual_hide[+birth]`, scangrid-remove, minimap-remove (`:3087-3099, :11109-11129`).
5. **FOW/selection/highlight (`game.gd` capture block + select paths).** On flip: scangrid key = winner (remove+add with material+pl), AIData remove/add per adviser/AI flags, topology remove/add, ctrlgroups wiped, IO-selection dropped, key-colour re-applied, highlight queued — cites `unit.script:3135-3167,3169-3205,3248-3300,3601-3700,3980-3998,3853-3860` + `miscext.script:920`. Vision: `20+4×prop.vision` iff visible/built/alive else 0 (`unit.script:11563-11614`) — attribution follows new `pl`; do NOT animate fog or territory here (engine-side, CS-FOW open).
6. **`data.gd:329,346` mode strings → donor enum cites.** `DONOR_CAPTURE` order already matches `dmscript.global:1072-1075` (`default/nopeasants/nocenterspeasants/onlyartillery` = 0..3); `CAPTURE_MODE`/`CAPTURE_ENABLED` (`data.gd:57,346`) keep as user overrides, cited as PORT CONFIG, never as donor law. `peasant_capture` interplay with `bcancapture/bcapture` stays per TABLES §3 + SEARCH §2.5.
7. **Telemetry/format.** Every added line carries `file:line` + `[O]/[D]/[U]/[I]` tag; `visual_parity_claim=false`; unresolved list after this ticket = [CS-PROGRESS(behaviour), CS-COOLDOWN(behaviour), CS-TRANSFER(ledger), CS-GARRISON, CS-HIDE(c), CS-FOW(engine), CS-RALLY]. Closed textually: progress-absence, majority-absence, cooldown-absence, transfer pipeline, counter arithmetic, hide transitions, absorber law.

---

## 8. Explicit non-claims and file discipline

- NO PARITY CLAIM. Closed items rest on donor TEXT `[O]` with `file:line`; every open item names its exact fixed-seed trace + zero-mismatch criterion in §6 and must never be quoted as donor-grounded until its three runs match.
- No number invented: 214/160/426 px radii, 1.875/0.475 s cadences, 3.125 s blockshot freeze, `1999/300` slow-death, `5/3/2/1` score modifiers, `20+4V` vision, absorber 5 / transport 120, `inside=4`, statetag bits — all donor literals with lines. `capture_t` rate/need/weights, tower garrison, `captured_nations`, `_default_rally` re-arm are PORT rules, labelled, never donor-cited.
- Read-only compliance: exactly one repo file written (this report). All donor evidence is text reads plus one zero-hit script-text probe; donor binary never executed, copied, or opened as a target; no source/asset/config/test/runner/Godot/git state changed. `progress.inc` was NOT re-read (ACL-refused in the FLUSH ticket; inherited cadence law not re-audited here — no new progress.inc literal claimed).
- Supersessions: port `capture_t` accumulation, G-09 guard-veto-as-capture-law, and any tower-garrison donor claim are WITHDRAWN by §§1/2/4 of this report. Future readers: cite CS-* items, not the older glosses.

*End of DEC-U-CAPTURE-STATE.*
