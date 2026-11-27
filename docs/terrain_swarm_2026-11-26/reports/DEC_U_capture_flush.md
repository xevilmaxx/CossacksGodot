---
id: DEC-U-CAPTURE-FLUSH
worker: DEC-U-CAPTURE-FLUSH (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. Donor binary never executed/copied/opened as target. Donor text scripts/data read as text only. No repo code/asset/config/Godot/git edit: this report is the only file written."
network: "OUT OF SCOPE. All _net_IsClient/_net_IsReplay/_net_IsServer/_net_IsRecord/_net_IsOffline/bProcess branches are cited only as exclusion boundaries. No net behavior specified."
parity: "NO PARITY CLAIM. No donor GPU A/B frame; no donor binary executed by this worker. All [O] are donor TEXT with file:line; every number the port needs but the donor text does not give stays [U] with an exact capture. No flush rule is invented."
context: "DEC_U_order_slots.md Q-CAPTURE [U]: donor capture flush writes production orders (miscext.script:1116-1132); port game.gd keeps a labelled queue=[] / research=null gap. DEC_U_skirmish_tables.md closed the capture head predicate but not the production/order effect on capture."
labels: "[O] verbatim donor literal (file:line) · [D] deterministic reading · [I] inference, flagged · [U] UNVERIFIED with exact experiment · PORT APPROXIMATION = port substitute to remove for 1:1"
---

# DEC-U-CAPTURE-FLUSH — the exact capture-flush law: which orders clear/advance, refunds, slot effects, capturer interaction (2026-11-26)

## 0. Pin + pass ledger (every pass pinned `t_87f0f3c130b0`; donor read-only, never executed)

| # | Pass | Result / evidence |
|---|---|---|
| P1 | Pin re-assert | `(Get-Item cossacks.exe).Length` = **5,768,048 B**, `(Get-FileHash SHA256).Hash` = `87F0F3C130B027E7C4E72DC217EAE9D592982370D112E0D224897BC92AF4E16C` (case-insensitive match to `t_87f0f3c130b0`). No binary executed, copied, or opened as a target. |
| P2 | `data/scripts/lib/miscext.script:892-1185` full read | EV-CF-FLUSH: `_misc_ChangePlayer` strip law (`:894-959`) + `_misc_CheckCapture` flush block (`:1111-1134`) + ChangePlayer call (`:1178`) + AI die rolls (`:1143-1173`), all `[O]` (§1). |
| P3 | `data/scripts/lib/unit.script:2756-2890` read | EV-CF-SLOTS: `_unit_ClearOrder` field resets (`:2756-2808`), `_unit_SortOrders` compaction (`:2812-2833`), `_unit_RemoveOrder` (`:2837-2842`), `_unit_OrdersOffset` (`:2846-2866`), `_unit_ClearOrders` static-skipping (`:2870-2880`) — all `[O]` (§2). |
| P4 | `data/scripts/lib/unit.script:5837-6053` read | EV-CF-CANCEL: `_unit_CancelUpgradePerform` refund law (`:5837-5889`) + `_unit_CancelUnitProduction` per-unit refund law (`:5893-5991`) + `_unit_OrderProduce` merge-or-new-slot law (`:5995-6053`), all `[O]` (§§3-4). |
| P5 | `data/scripts/lib/unit.script:10351-10520` read | EV-CF-PRODUCE: `_unit_ProduceUnit` bState=True order arm (`:10433-10458`) vs bState=False cancel arm (`:10459-10465`) + fallback loop (`:10478-10520`), all `[O]` (§4). Capture flush calls it with `(False, False, True)` (`:1124`) — verbatim params kept, semantic effect stays `[U]` (§4.4). |
| P6 | `data/scripts/lib/player.script` grep + `dmscript.global:113` read | EV-CF-NOELSEWHERE: `gc_obj_MaxOrderCount=12` (`dmscript.global:113`) `[O]`; player.script producer/cancel grep (CreateConstructionDummy `:200-228`, WriteOrderObjects `:1076-1099`, OrderUnits* `:1099-1468`, ConstructBuildingList `:1478+`, upgstate lifecycle `:43-52,83-85,1701-1705`) shows NO second flush site `[O-absence]` (§6). progress.inc text probe refused by OS ACL (method-caveated, §6). |
| P7 | Native read-only probe | `Select-String -Path cossacks.exe -Pattern MaxOrderCount` → **0 hits** `[O-absence, method-caveated]`; consistent with inherited DEC-U-ORDER-SLOTS P11 (script-declared storage, engine only moves handles). Native entry `0x8f1a08` re-pinned by reference (no new native claim). |
| P8 | Port `variant3d/scripts/game.gd:5240-5264,5266-5399,5412-5445,7948-8041,8097-8270,8778-8813` + `data.gd:276-277` read-only inspection (no edit) | EV-CF-PORT: telemetry const + merge-first train + per-unit cancel + head-only tick + capture block `queue=[]/research=null` (`:8258-8260`) + `orders12` save telemetry (§7, all port-side). |

DSL note `[D]` (inherited): donor `not X` on a numeric lvalue is the current-value read, not boolean negation. Applies to `not bSorting`, `not bExit`, `not bMerged`, `not bState` below.

---

## 1. The flush block — verbatim law [O] (`miscext.script:1111-1134`)

Scope gate `[O]` (`:1100-1103`): flush runs only when `(visual_hide)=0` AND (`bbuilding` OR `essential_none`). Non-buildings take the `_unit_Stop(goHnd)` arm (`:1111-1112`) and NEVER enter the flush. Walls / `bAutoKill(uninit False)` take `bDie := True` (`:1106-1109`, uninitialised-local caveat kept verbatim — read §5.7) and die without `ChangePlayer`.

Building arm `[O]` (`:1113-1134`), executed BEFORE `newPlHnd` is computed (`:1136`) and BEFORE `_misc_ChangePlayer` (`:1178`):

```
for i := 0 to gc_obj_MaxOrderCount-1 do                          // :1116 ASCENDING 0..11
  if orders[i].iType = produce then                              // :1118
    if orders[i].info.amount <> 0 then                           // :1120 (BOTH finite>0 AND infinite=-1 pass)
      gIntegerList.Clear; gIntegerList.Add(goHnd);               // :1122-1123
      _unit_ProduceUnit(GetGameObjectPlayerHandleByHandle(goHnd), // :1124 OLD-owner handle (swap not yet done)
        gIntegerList, cid, orders[i].info.produceid,
        orders[i].info.amount, False, False, True);               // :1124 bState=False, bcheckres=False, blan=True
      orders[i].info.amount := 0;                                 // :1125 unconditional zero AFTER the call
  else if orders[i].iType = performupgrade then                  // :1129
    _unit_CancelUpgradePerform(goHnd,                             // :1130
      gCountry[cid].upgrade[orders[i].info.upgradeid].id);
_unit_ClearOrders(goHnd);                                        // :1132 static-PRESERVING ( §2)
_unit_SetSTO(goHnd, 0);                                          // :1133
```

Fixed points (no inference):

1. Loop covers ALL 12 slots ascending, including the head. There is no head-only shortcut and no `break`.
2. `amount <> 0` filter: `amount=0` produce slots (e.g. a mill-field one-shot already zeroed per `doprogressorders.inc:130-136`, or an empty-produce guard remnant `:128,:377-378`) are SKIPPED — the call is not made, the slot is left for `ClearOrders`. Finite `>0` and infinite `-1` (`gc_obj_order_produce_infinite`, `dmscript.global:660`) both pass the filter.
3. The `ProduceUnit` player handle is the VICTIM's (`GetGameObjectPlayerHandleByHandle(goHnd)` while `TObj.pl` is still the loser). Any cost check, refund payee, or stat write inside that call attributes to the LOSER, never the capturer. The capturer's handle is not read until `:1136`.
4. `amount := 0` is unconditional after the call — even if the call exits early, breaks, or cancels only one unit, the slot's remainder is truncated to zero in place (removal itself happens later via `ClearOrders`, §2).
5. `performupgrade` slots call `CancelUpgradePerform` with the upgrade's STRING id resolved through `gCountry[cid].upgrade[upgradeid].id` (`:1130`). No amount/progress guard exists on this arm: ANY `performupgrade` slot cancels, including a head slot mid-progress.
6. `ClearOrders` (`:1132`) is the static-SKIPPING variant (`unit.script:2870-2880`); `static` orders survive it here. `SetSTO(goHnd,0)` (`:1133`) drops the rally/resource target AFTER the order flush (STO ≠ order slot; cited so the port never conflates `rally=null` with slot clearance).
7. Order types other than `produce` / `performupgrade` (`move, attackobj, gainres, exitunits, build, repair, …`) are NOT touched by this block. They are handled — if at all — by the LATER `_misc_ChangePlayer` strip (§5).

---

## 2. Queue-slot effects of the flush [O]

- `EV-CF-SLOTS-A` — `_unit_ClearOrder` (`unit.script:2756-2808`) `[O]`: `itype := none; bexecute/bremove := False; static := false` (`:2788-2791`); target zeroed via `_unit_SetOrderTrg(goHnd, ind, 0, …)` (`:2794`); `x/y/dx/dy/dir/z/upgradeid/produceid/restype/amount/progress := 0` (`:2795-2805`). With `not bSorting`, `gotomine/gototransport` additionally release `insidereserved` on the target (`:2767-2784`). **Clearing is never a refund** — zero resource writes on this path.
- `EV-CF-SLOTS-B` — `_unit_ClearOrders` (`:2870-2880`) `[O]`: skips `static` orders (`:2876`), then `_unit_SortOrders`. `_unit_SortOrders` (`:2812-2833`) `[O]`: single left-compaction pass; live prefix becomes dense `0..k-1`. `_unit_RemoveOrder` (`:2837-2842`) `[O]`: `ClearOrder(ind, True, False)` + `SortOrders`.
- Applied to the flush: after `:1125` zeroes every produce `amount` in place, `:1132` clears every NON-static slot (produce remnants with `amount=0`, upgrade remnants already `RemoveOrder`'d by `CancelUpgradePerform`, and any other queued non-static orders such as `exitunits`) and compacts. A `static` produce/upgrade slot with `amount=0` SURVIVES `:1132` with its zeroed amount — then meets the `ChangePlayer` strip (§5), which does NOT test `static` (it keeps only `none`/`move`, `:909`). Net effect of the two-stage pipeline on a static slot is therefore `[D]` composition (survives stage 1, removed at stage 2) — behaviourally `[U]` until Q-STATIC (§8) passes.
- `OrdersOffset` (`:2846-2866`) is NOT called on the flush path (no `bDoFirst` insert here). No tail-destruction beyond the clear+compact above. Do not port a tail-eviction on capture.

---

## 3. Upgrade arm — cancel + refund payee [O] (`unit.script:5837-5889`)

`_unit_CancelUpgradePerform(goHnd, upgsid)` (`:5837`):

1. Resolves cost via `_country_GetUpgradeCostBySID(cid, upgsid, …)` (`:5845`) — the FULL upgrade price, not a pro-rata remainder. No progress scaling exists anywhere in this proc.
2. Top-down scan `MaxOrderCount-1 downto 0` (`:5847`); matches `performupgrade` slots whose `info.upgradeid = upgind` (`:5849-5852`, `upgind>0` guard).
3. Per match: `_unit_RemoveOrder(goHnd, i)` (`:5854`, immediate compact); `gPlayer[plInd].upgstate[cid][upgind].inprogress := False; timestart := 0` (`:5855-5856`), where `plInd` is derived from the building's CURRENT handle (`:5842`) — at flush time, the LOSER.
4. Refund `[O]` (`:5857-5885`), gated `bProcess = not (_net_IsClient or _net_IsReplay)` (`:5840`): full cost re-added per resource (`:5859-5864`) to the LOSER + `_misc_LanForceSyncRes` (`:5865`); stat counters decremented (`resonmines` for `single_inside_mine`, else `resonupgrade`, `:5867-5884`).
5. Capture consequence `[D]`: the loser's `inprogress` is cleared and the loser is refunded the FULL price EVEN IF the upgrade was 99% complete. The capturer receives NO upgrade state (upgstate is per-player, `gPlayer[pl]`, not per-building) and NO head-start: a fresh `OrderUpgrade` must re-pay and re-time from zero. The port's `research=null` drop without refund-to-loser is therefore WRONG in the refund direction and MISSING nothing in the capturer direction — see change list (§7, item 3). The exact refund stream (which of `res[]` vs `lanres` the test observes) is `[U]`-Q-REFUND-UPG until the fixed-seed trace passes.

---

## 4. Produce arm — what `_unit_ProduceUnit(…, False, False, True)` does [O] + the one honest ambiguity [U]

4.1. Signature `[O]` (`unit.script:10351`): `_unit_ProduceUnit(plHnd, list, cid, id, tryamount, bState, bcheckres, blan)`.

4.2. Amount normalisation `[O]` (`:10362-10366`): `amount<=produce_infinite(-1)` → `bsetinfinite := True; amount := round(Abs(amount))`. Flush passes the slot's raw `amount`: finite N → N iterations; infinite `-1` → 1 iteration with `bsetinfinite=True`; a hypothetical `-5` → 5 iterations (`[U]`-Q-NEG inherited from ORDER-SLOTS §4.2 — flush never synthesises `-5`, it only forwards what the slot holds).

4.3. Per-iteration building pick `[O]` (`:10368-10426`): single-entry list (`list.Get(0)=goHnd`, `bldcount=1`); per-slot scan sums `curproduceamount` (same-sid finite), `curproduceamountmisc`, `curproduceinfinite/infinitemisc` (`:10386-10407`); `bState=False` pick rule (`:10419`): `(curproduceamount>0) and (max)` — with one candidate the building is picked iff it still holds a SAME-or-other finite produce amount > 0. `bcurinfinite` buildings are never picked on this arm (`:10416` gate).

4.4. THE AMBIGUITY — stated, not smoothed over. With `bState=False` the picked-building arm is the CANCEL arm `[O]` (`:10459-10465`):
`_unit_CancelUnitProduction(bldHnd, cid, id, 1, False)` + `amountproceed += 1`, versus the `bState=True` ORDER arm (`:10433-10458`: `OrderProduce(bldHnd, cid, id, 1-or-infinite)` + resource check). The flush passes `bState=False`. A face-value composition therefore reads as: **per produce slot, the flush cancels ONE unit (refunding the loser per §3-style per-unit law) and then truncates the slot remainder via `:1125` without further refund** — NOT a re-queue under the capturer. The inherited ORDER-SLOTS §4.5 gloss ("re-ordered under the new owner (or die with it)") is the opposite reading and is WITHDRAWN by this worker as an `[I]` that this pass cannot sustain from the two `[O]` texts alone. The fallback loop (`:10478-10520`, per-building `CancelUnitProduction` scan for infinite slots `:10497+`) is consistent with the cancel reading but was cut at the read limit and is NOT cited beyond its existence — full-line recovery is `[U]`-Q-FLUSH-SEM. **No flush rule is invented: the port change list (§7) implements the VERBATIM call + zero + clear + strip pipeline and tags the semantic (re-order vs cancel-one-and-truncate) `[U]` with experiment Q-FLUSH-SEM (§8).**

4.5. Cost-gate consequence that IS firm `[O]`: `bcheckres=False` (`:10435` short-circuits the `CanApplyCost` check on the True arm; the False arm has no cost check at all). Whatever the arm does, a broke loser does not stop the flush. `blan=True` only arms the `WriteUpgrade`-style network tail (`:10338-10346` analogue) — out of scope.

4.6. Relation to `_unit_OrderProduce` (`:5995-6053`) `[O]`: merge-first (`:6004-6042`), infinite↔finite collision cancel+exit (`:6011-6015`), infinite-on-infinite exit (`:6035-6038`), charge-before-add (`:6045-6050`). This proc is reachable from the flush ONLY via the True arm; on the False arm it is not called. Do not cite merge law as flush law.

---

## 5. `_misc_ChangePlayer` second strip + everything the flush does NOT do [O] (`miscext.script:894-959`)

After the AI die rolls (`:1143-1173`, SKIRMISH-TABLES §3 — loser-AI building `random>0.25 → bDie`, else slow-death `hp := 1999 − floor(RandomExt×300)` when `bbuilt+bslowdeath`), `bDie ? essential_death : _misc_ChangePlayer(go,newPlHnd,True,False,True)` (`:1175-1178`):

1. Non-`none`/non-`move` strip `[O]` (`:908-910`): `for i := MaxOrderCount-1 downto 0: if not (none or move) → _unit_RemoveOrder(goHnd, i)`. Runs AFTER the ownership swap (`SetGameObjectPlayerHandleByHandle + TObj.pl := newPlInd`, `:915-917`). Keeps `move` orders (rally-path remnants) — the flush's `ClearOrders` does not keep them, so any `move` slot alive at capture survives ONLY this stage's keep-rule. Net: post-capture queue = whatever `move` slots existed (normally none on a production building) — behaviourally `[U]`-Q-MOVE.
2. Per-order refund on this strip: NONE — `RemoveOrder → ClearOrder + SortOrders` has no resource write (§2). Any refund the loser gets comes SOLELY from the §3/§4 cancel arms, never from the strip.
3. STO/path/arglists `[O]` (`:903-905`): `SetSTO(go,0)` (again), `_unit_PathListRemove`, `_misc_FixArgLists` — rally/path state, not order slots.
4. Mine-insider capture `[O]` (`:922-947`): `inside` list members are THEMSELVES `ChangePlayer`'d recursively (`:933`) with `ScanGridRemoveUnit + SetSTO(trg,go)` (`:934-935`), and `resincome` produce counters move from loser to winner (`:941-944`). Peasants inside a captured mine therefore change owner WITH their (empty — peasants hold no produce/upgrade slots) queues intact; their `gainres` infinite-detach bookkeeping is untouched by either strip arm that names only `produce/performupgrade` (flush) or keeps `move` (ChangePlayer). Claiming more (e.g. peasant load preservation) is `[U]`-Q-MINE.
5. Wall / `bAutoKill` / birth-hide / non-building paths NEVER reach `ChangePlayer`: `bDie` essential-death (`:1106-1109, :1175-1176`), non-building essential-birth gate (`:1093-1099`), mine-STO error branch (`:1180-1181`). No flush, no refund, no strip on those paths.

---

## 6. `player.script` / `progress.inc` negative result

- `player.script` grep (P6): upgrade lifecycle (`_player_ClearUpgradeState :43-52`, init `:83-85`, completion `:1701-1705`), construction dummies (`:200-228`), order writers (`_player_WriteOrderObjects :1076-1099`, `_player_OrderUnitsToBuild :1099-1241`, `OrderUnitsToGoInside :1248-1353`, `OrderUnitsListToGainRes :1360-1390`, `OrderUnitsToAttack :1398-1468`, `_player_ConstructBuildingList :1478+`) — NO capture-flush counterpart: no `ProduceUnit`-replay, no `CancelUpgradePerform`-on-capture, no `ClearOrders`-on-capture call site exists in this file `[O-absence]`. The flush lives SOLELY in `miscext.script:1116-1132`.
- `progress.inc`: `Select-String` probe REFUSED by OS ACL (`Access to the path … is denied`) — method-caveated, NOT a content claim. The global-tick `CheckCapture` driver is inherited from SKIRMISH-TABLES P7 (`building.inc/nothing.inc:293-326`, `unit.inc/nothing.inc:507-535`, cadence `0.1×19−eps=1.875 s` / art `0.475 s`) and is not re-audited here. No new progress.inc literal is claimed.
- `unit.script:5835` comment lines (`:5839`, `:5895`) note `WriteUpgrade`/cancel write/read state events — network tails, out of scope.

---

## 7. Port change list (`game.gd` / `data.gd` — owner/COORD applies; this worker wrote no code)

All items add DONOR-VERBATIM law or explicitly labelled placeholders. None invents a number. None touches save version, existing keys, or network. `config.json:93` (`build_queue_limit: 10`) is a user-file override path and is NOT renamed by any item below.

1. **`game.gd:8258-8260` capture block — keep + cite, add loser-refund TODO.** PRESERVE `e["queue"] = []` / `e["research"] = null` / `e.erase("rally")` + rally re-arm verbatim. ADD comment citing the verbatim pipeline `miscext.script:1116-1132 → 1132 → 1133 → 1178 → miscext.script:908-910` and tag the TWO divergences: (a) port drops the loser refund (upgrade FULL refund `unit.script:5859-5864` + produce-arm per-unit refund `unit.script:5960-5977`, both payable to the LOSER `players[old]`); (b) port skips the verbatim `ProduceUnit(…,False,False,True)` call + `amount:=0` + `ClearOrders(static-preserving)` + `SetSTO(0)` + `ChangePlayer` move-keeping strip. Do NOT invent the re-order: implement the CALL with old-owner handle and tag semantics `[U]`-Q-FLUSH-SEM. Telemetry: `visual_parity_claim=false`.
2. **`game.gd:5266-5399` `train_unit` — no capture change.** ADD one-line cite: post-capture re-training by the capturer goes through this same merge-first path (`unit.script:5995-6053`); the flush itself never writes to the capturer's queue (§5). No code change.
3. **`game.gd:5412-5438` `cancel_train` — add loser-payee cite.** Current per-unit decrement + `Data.refund(players[building.player].res, …)` IS the `CancelUnitProduction` payee shape (`unit.script:5929-5977`: refund to the building's CURRENT owner). On capture the current owner is the loser — route the capture-time refund (item 1) to `players[old]`, never `players[capturer]`. No formula change; mercenary `costpercent/100^count` curve (`:5934-5956`) stays `[U]`-Q-MERGE.
4. **`game.gd:7948-8041` `_tick_building` head-only — no capture change.** ADD cite: post-capture the queue restarts at head `orders[0]` (`doprogressorders.inc:120`); `pop_front` + dense queue is the matching operation (`unit.script:2812-2842`). A captured building with an (unexpected) surviving `move` job must NOT train from it — guard `job.sid` against `Data.UNITS` (move jobs have no `build_time`); log-and-drop, tagged `[U]`-Q-MOVE.
5. **`game.gd:8778-8813` `serialize` `orders12` — extend cite, no shape change.** ADD comment: slot field order `trg:I,x,y,dx,dy,dir,z:F,upgradeid,produceid,restype,amount:I,progress:F` (`dmscript.global:1678-1702`); on capture the donor-recoverable post-flush dump is twelve `none` slots except possibly kept `move`/surviving-`static` entries (§§2,5) — port `orders12` default-zero dump stays, tagged `[U]`-Q-STATIC until Q-STATIC passes. Never truncate/pad differently; never bump version.
6. **`data.gd:276-277` — extend cite (no value change).** `DONOR_MAX_ORDER_COUNT=12` is the loop bound at `miscext.script:1116` AND `unit.script:2874,5847,6004,10386`; `BUILD_QUEUE_LIMIT` counts port `queue` jobs, NOT donor slots — slot↔job equivalence stays `[U]` (ORDER-SLOTS Q-SLOT-JOB).
7. **Telemetry/format.** Every added line carries `file:line` + `[O]/[D]/[U]` tag; `visual_parity_claim=false`; unresolved list after this ticket = [Q-FLUSH-SEM, Q-REFUND-UPG, Q-REFUND-PROD, Q-STATIC, Q-MOVE, Q-MINE, Q-WALL, Q-CAPTURER] (§8).

---

## 8. Still-[U] register — each with a fixed-seed capture/queue trace + zero-mismatch criterion (no flush rule invented)

Conventions for all captures (owner-authorised; binary run by owner, never this worker): fixed seed S, fixed map, fixed nation pair (e.g. ukr vs pol barracks + blacksmith), full stock unless the capture varies cost; instrumented owner build dumps donor `orders[0..11].{itype,produceid,upgradeid,amount,restype,progress}` per building-Nothing tick + `gPlayer[loser/winner].res[0..5]` + `upgstate[cid][upgind].{inprogress,timestart}` + port `queue`/`research` snapshot per tick. Wall-clock is IRRELEVANT — all criteria compare slot dumps, res ledgers, and tick counts. Three identical-seed runs; ANY inter-run divergence FAILS the item (quote the divergent dump, do not average).

| # | Item | Static state after this ticket | Exact experiment |
|---|---|---|---|
| Q-FLUSH-SEM | Produce-arm semantics: re-order under loser vs cancel-one-and-truncate | VERBATIM call+params `[O]` (`:1124`); effect `[U]` (§4.4) | Seed S: queue ONE finite batch N=5 (affordable, farm/art-capped-safe). Capture mid-queue (progress<1). Dump slots + loser `res[]` + winner `res[]` per tick across the capture tick. **Zero-mismatch:** 3 runs identical; EITHER (a) loser `res[]` increases by exactly ONE `floor(price×costmodifier)` unit AND slot remainder truncated (cancel reading), OR (b) a new same-sid `produce` slot/amount appears under loser handle with a fresh cost charge (re-order reading) — quote which. No third outcome accepted without a verbatim cite. Port implements the call, never the reading. |
| Q-REFUND-PROD | Produce refund payee/amount on capture | Per-unit refund law `[O]` (`:5960-5977`); capture-triggered count/payee `[U]` | Seed S: queue N=3 finite + capture. Log loser `res[]` delta tick-before→tick-after, winner delta (=0 expected), slot dump. **Zero-mismatch:** 3 runs identical; assert delta equals 0, 1, or N unit-prices — quote exact count; assert payee is loser. |
| Q-REFUND-UPG | Upgrade FULL-refund-on-capture | Refund law `[O]` (`:5859-5864` to loser + stat decrement); capture trigger `[O]` (`:1129-1130` unconditional) | Seed S: start an upgrade (blacksmith, known cost C), capture at 50% progress. Log loser `res[]` delta, `upgstate.inprogress/timestart`, slot dump. **Zero-mismatch:** 3 runs identical; assert delta = +C to loser, `inprogress=False, timestart=0`, winner gains no state. |
| Q-STATIC | Static-order survival across the two-stage pipeline | Stage-1 skip `[O]` (`:2876`) + stage-2 no-static-test `[O]` (`:909`); net `[D]`, behaviour `[U]` | Seed S: hand-craft (owner debug) one `static=True` produce slot amount=2, capture. Dump post-`:1132` (pre-ChangePlayer if observable) + post-capture slots. **Zero-mismatch:** 3 runs identical; report survive-stage-1?/removed-stage-2? as observed. Port keeps `orders12` zero-dump until then. |
| Q-MOVE | `move`-order survival via ChangePlayer keep-rule | Flush ignores `move` `[O]` (`:1118/:1129`); ChangePlayer keeps `move` `[O]` (`:909`); building-with-move observable `[U]` | Seed S: queue a `move` order on a capturable building if reachable (else record UNREACHABLE with the failed call's `file:line`), capture. Dump slots. **Zero-mismatch:** 3 runs identical; assert kept `move` at head or twelve `none`. Port log-and-drop guard (§7 item 4) stays until then. |
| Q-CAPTURER | Capturer's own queue interaction | Untouched `[D]` from callee-target analysis (`goHnd`-only writes, §§1,5); behaviour `[U]` | Seed S: capturer owns a producing barracks (2 batches queued) while its peasants capture a second building. Dump capturer-building slots before/after. **Zero-mismatch:** 3 runs identical; assert byte-identical slots + `progress` continuity (no reset). |
| Q-MINE | Mine-insider recursive ChangePlayer | Recursion + `resincome` move `[O]` (`:922-947`); peasant queue/load effect `[U]` | Seed S: 3 peasants inside a mine, capture the mine. Dump insider `orders[]`, `STO`, `inside` list, both players' `counter.resincome[]`. **Zero-mismatch:** 3 runs identical; assert owner flip + STO re-point + resincome delta = `produce[i]×3`. |
| Q-WALL | Wall/bAutoKill/birth-hide exclusion | Exclusion branches `[O]` (`:1093-1099, :1106-1109, :1180-1181`); `bAutoKill` uninitialised-local caveat `[I]` flagged | Seed S: attempt capture of a wall segment + (if reachable) an `essential_birth` unit. **Zero-mismatch:** 3 runs identical; assert `essential_death` with NO flush writes (no res delta, no slot churn) — quote the taken branch. Do not initialise `bAutoKill` in the port. |

---

## 9. Explicit non-claims and file discipline

- NO PARITY CLAIM. The flush pipeline (§§1-5) rests on donor TEXT `[O]` with `file:line`; the produce-arm semantic (Q-FLUSH-SEM), every refund delta (Q-REFUND-*), and every survival/interaction item (Q-STATIC/Q-MOVE/Q-CAPTURER/Q-MINE/Q-WALL) are explicitly NOT recovered behaviourally and must never be quoted as donor-grounded until their captures pass with zero mismatch.
- No number invented: 12 is the donor literal (`dmscript.global:113`); `amount`/`restype`/`progress` semantics are transcribed, not assigned; no slot↔job conversion factor is asserted (§7 item 6 keeps the adoption separate from the equivalence).
- The ORDER-SLOTS §4.5 gloss ("replays produce … under the new owner") is SUPERSEDED by §4.4 of this report (verbatim params kept, effect marked `[U]`). Future readers: cite this report's Q-FLUSH-SEM, not the older gloss.
- Read-only compliance: exactly one repo file written (this report). All donor evidence is text reads + one zero-hit binary probe; donor binary never executed, never copied; no source/asset/config/test/runner/Godot/git state changed.
- Network out of scope: `bProcess`, `WriteUpgrade/ReadUpgrade` mirror, `LanForceSyncRes` tails, and replay/client preview branches are cited only as exclusion boundaries.

*End of DEC-U-CAPTURE-FLUSH.*
