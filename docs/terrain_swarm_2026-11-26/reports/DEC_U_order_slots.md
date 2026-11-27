---
id: DEC-U-ORDER-SLOTS
worker: DEC-U-ORDER-SLOTS (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. Donor binary never executed/copied/opened as target. Donor text scripts/data read as text only (CP1251 Russian comments not translated, quoted structurally). No repo code/asset/config/Godot/git edit: this report is the only file written. IMPL-QUEUE-LIMIT (config/data) files were read, never edited."
network: "OUT OF SCOPE. All _net_IsClient/_net_IsReplay/_net_IsServer/_net_IsRecord/_net_IsOffline/bProcess branches are cited only as exclusion boundaries. No net behavior specified."
parity: "NO PARITY CLAIM. No donor GPU A/B frame; no donor binary executed by this worker. All [O] items are donor TEXT with file:line; every number the port needs but the donor text does not give stays [U] with an exact capture. No slot<->job equivalence is asserted anywhere in this report."
context: "DEC_U_victory_start.md + IMPL-QUEUE-LIMIT set donor MaxOrderCount=12 in config/data but flagged [U]: donor counts ORDER SLOTS per object (a batch lives in one order's `amount`), the port counts JOBS in `queue`; slot<->job equivalence is unproven. This ticket recovers the exact static order-slot law and leaves the equivalence [U] with captures."
labels: "[O] verbatim donor literal (file:line) · [D] deterministic reading · [I] inference, flagged · [U] UNVERIFIED with exact experiment · PORT APPROXIMATION = port substitute to remove for 1:1"
---

# DEC-U-ORDER-SLOTS — the 12-slot order law: append/remove, amount/batch, bDoFirst, full queue, train iteration (2026-11-26)

## 0. Pin + pass ledger (every pass pinned `t_87f0f3c130b0`; donor read-only, never executed)

| # | Pass | Result / evidence |
|---|---|---|
| P1 | Pin re-assert | `t_87f0f3c130b0`: `(Get-Item cossacks.exe).Length` = **5,768,048 B**, `Get-FileHash SHA256` = `87F0F3C1…4E16C` (case-insensitive match to `87f0f3c130b0…4e16c`). No binary executed, copied, or opened as a target. |
| P2 | `dmscript.global:113,630-660,1678-1702,1763` read | EV-OS-VOCAB: `gc_obj_MaxOrderCount=12`, order-type enum, `produce_infinite=-1`, `TOrderInfo`/`TOrder`/`orders[]` shape (§1, all `[O]`). |
| P3 | `units/building.inc/doprogressorders.inc:1-416` full read | EV-OS-TICK: dispatch-on-`orders[0]`, produce arm (`:123-379`), empty-guard remove (`:377-378`), performupgrade delegate (`:380-383`), infinite-rotation scan (`:298-313`) (§7, all `[O]`). |
| P4 | `lib/unit.script:2733-2734,2756-2890` read | EV-OS-REMOVE: init loop, `_unit_ClearOrder` field resets, `_unit_SortOrders` compaction, `_unit_RemoveOrder`, `_unit_OrdersOffset`, `_unit_ClearOrders`/`_unit_FullClearOrders` (§3, all `[O]`). |
| P5 | `lib/unit.script:4304-4389` read | EV-OS-ADD: `_unit_AddOrder` full mechanics — `bClearOrders`, `bDoFirst`, first-free-slot, `gainres infiniteorderind` special, `ind=-1` silent nil, `bdead` guard (§2, all `[O]`). |
| P6 | `lib/unit.script:5995-6074` read | EV-OS-PRODUCE: `_unit_OrderProduce` merge-or-new-slot law + charge-before-add; `_unit_OrderUpgrade` `bDoFirst=True` insert (§4/§5, all `[O]`). |
| P7 | `lib/unit.script:5893-5991` read | EV-OS-CANCEL: `_unit_CancelUnitProduction` decrement/convert/refund/remove law (§4, all `[O]`). |
| P8 | `lib/unit.script:10351-10466` read | EV-OS-DISPATCH: `_unit_ProduceUnit` negative-`amount` → infinite fan-out, per-building load scan, per-click single-unit `OrderProduce` (§4, all `[O]`). |
| P9 | `lib/unit.script:4518-4536,10734-10748` + `lib/miscext.script:1116-1132` read | EV-OS-AUX: `exitunits` in-place merge-or-new; `_unit_GetLastOrderIndex`; capture-flush replays produce / cancels upgrade / `ClearOrders` (§3/§4, all `[O]`). |
| P10 | `gc_obj_MaxOrderCount` census (46 hits, 15 files) | EV-OS-CENSUS: every slot-loop site enumerated (§6); no UI free-slot precheck exists anywhere on the `OrderProduce` path `[O-absence]`. |
| P11 | Binary read-only negative probe | `findstr /m` for `MaxOrderCount`, `bDoFirst`, `TOrderInfo`, `OrdersOffset` over `cossacks.exe` → **0 hits each** `[O-absence, method-caveated]` (§8). Native order-storage characterization inherited from DEC-U-UPGRADE-Q2 P1 (no new native claim). |
| P12 | Port `variant3d/scripts/game.gd:5210-5315,7605-7668` + `data.gd:270-277` + `config.gd:140-144,528-539` + `config.json:93` read-only inspection (no edit) | EV-OS-PORT: live `train_unit/cancel_train/queue_count/_tick_building`, `DONOR_MAX_ORDER_COUNT/BUILD_QUEUE_LIMIT`, config default 12 vs `config.json` override 10 (§9, all port-side). |

DSL note `[D]` (inherited): donor `not X` on a numeric lvalue is the current-value read, not boolean negation. Not exercised on the paths below except where quoted.

---

## 1. Slot vocabulary — what a "slot" is [O]

- `[O]` `dmscript.global:113`: `gc_obj_MaxOrderCount = 12;`
- `[O]` `dmscript.global:1763` inside `TObj`: `orders = TOrder[gc_obj_MaxOrderCount]` — every object owns exactly 12 order slots, always (no dynamic growth).
- `[O]` `dmscript.global:1678-1691` `TOrderInfo` field order (verbatim): `trg:I, x,y,dx,dy,dir,z:F, upgradeid,produceid,restype,amount:I, progress:F`.
- `[O]` `dmscript.global:1693-1702` `TOrder`: `itype:I, info:TOrderInfo, bexecute,bremove,static:Boolean` (`uid/next/priority` commented out — absent fields, do not port).
- `[O]` `dmscript.global:630-650` order-type enum: `none=0, move=1, attackobj=2, gainres=3, produce=4, patrol=5, attackpoint=6, continueattackpoint=7, performupgrade=8, fishing=9, creategates=10, buildwallcontinue=11, buildwall=12, gotomine=13, gototransport=14, leavetransport=15, leavebuilding=16, build=17, guard=18, repair=19, exitunits=20`.
- `[O]` `dmscript.global:660`: `gc_obj_order_produce_infinite = -1;`
- `[I]` (flagged, load-bearing for §6): a slot is "free" iff `itype = gc_obj_order_type_none`. Every scan in §§2-4 uses exactly this predicate; no occupancy bitmap exists.

---

## 2. Append law — `_unit_AddOrder` [O] (`lib/unit.script:4304-4389`, full fn)

Signature `[O]` (`:4304`): `_unit_AddOrder(goHnd, itype, itrghnd, ix,iy,idx,idy,idir,iz, iupgradeid, iproduceid, irestype, iamount, iprogress, bClearOrders, bDoFirst) : Pointer`.

2.1. Dead guard `[O]` (`:4311-4312,4386-4388`): `if (not bdead)` else `ErrorLog('…bdead unit try to add order…')`, `Result = nil`. Dead objects never gain slots.

2.2. `bClearOrders` arm `[O]` (`:4315-4318`): `ind := 0; _unit_ClearOrders(goHnd)`. Slot 0 is then written unconditionally.

2.3. `bDoFirst` arm `[O]` (`:4320-4328`):
- `ind := 0`;
- `gainres`-on-`gainres` detach (`:4323-4324`): if head is `gainres` and the new order is `gainres`, `_unit_SetOrderTrg(goHnd, 0, 0, True)` first;
- `orders[0].bexecute := False` (`:4325`);
- `if orders[0].itype <> none then _unit_OrdersOffset(goHnd, 0, 1)` (`:4326-4327`) — the head is pushed down one; the tail slot is destroyed by `OrdersOffset` itself (§3.3). **Preemption never checks for a free slot.**

2.4. Normal append `[O]` (`:4330-4347`): only when `not bClearOrders` and `not bDoFirst`: linear scan `0..MaxOrderCount-1`; first `itype=none` slot wins (`ind := i`, `bfound`). No best-fit, no type affinity. **If no free slot exists `ind` stays `-1`.**

2.5. `gainres` infinite-detach `[O]` (`:4349-4356`): after either arm, if any slot holds `gainres` (`infiniteorderind`), detach its target, `bexecute := False`, `_unit_OrdersOffset(goHnd, infiniteorderind, 1)`, `ind := infiniteorderind`. (Peasant gather bookkeeping; not a produce path — cited so the port never mistakes it for a 13th slot.)

2.6. Write `[O]` (`:4358-4384`): only `if (ind>=0)`: `itype`, `bexecute/bremove := False`, `static := false` (`:4364-4367`), target via `_unit_SetOrderTrg` (`:4370`), all six floats + `upgradeid/produceid/restype/amount` + `progress := iprogress` (`:4371-4381`). Returns the slot pointer; on `ind=-1` returns `nil` **silently** (no log, no error). Callers on the produce path ignore the return (§6.3).

2.7. `bDoFirst` callers observed `[O]`: upgrade insert (`:6069`, §5), `_unit_OrderMove` `bDoFirst` param (`:4409-4422`), fishing (`:4395-4403`), `_unit_OrderExitUnit` (`:4499`, `:4535`). Produce append always passes `False, False` (`:6051`).

---

## 3. Remove law [O]

3.1. `_unit_ClearOrder(goHnd, ind, bUpdateOrdList, bSorting)` `[O]` (`:2756-2808`): `itype := none; bexecute/bremove := False; static := false` (`:2788-2791`); target zeroed via `_unit_SetOrderTrg(goHnd, ind, 0, …)` (`:2794`); `x/y/dx/dy/dir/z/upgradeid/produceid/restype/amount/progress := 0` (`:2795-2805`). With `not bSorting`, `gotomine/gototransport` additionally releases `insidereserved` on the target (`:2767-2784`). **Clearing is not a refund** — no resource write on this path.

3.2. `_unit_SortOrders` `[O]` (`:2812-2833`): single left-compaction pass: first `none` hole remembered in `ind`; each later live order is struct-copied down (`orders[ind] := orders[i]`, `:2828`), the source cleared with `bSorting=True` (`:2829`). Holes therefore never persist between operations: the live prefix is always dense `0..k-1`.

3.3. `_unit_OrdersOffset(goHnd, fromind, offset)` `[O]` (`:2846-2866`): `offset=0` is an `ErrorLog` (`:2865`); else destroys the top `offset` slots (`:2852-2853` `ClearOrder` on `MaxOrderCount-1 downto MaxOrderCount-offset`), shifts `[MaxOrderCount-(1+offset)..fromind]` down (`:2856-2860`), clears the vacated `[fromind..fromind+offset-1]` (`:2861-2862`). With `(0,1)` this is: **slot 11 destroyed, slots 10..0 move to 11..1, slot 0 freed**. The destroyed tail is cleared with `bUpdateOrdList=true` (res-grid counts updated) but never refunded.

3.4. `_unit_RemoveOrder(goHnd, ind)` `[O]` (`:2837-2842`): `ClearOrder(ind, True, False)` + `SortOrders`. Remove-anywhere compacts.

3.5. `_unit_ClearOrders` vs `_unit_FullClearOrders` `[O]` (`:2870-2890`): `ClearOrders` skips `static` orders (`:2876`) then sorts; `FullClearOrders` clears all 12 without sorting. `static` orders survive `ClearOrders` (capture path §4.5 uses the static-skipping one).

3.6. `_unit_GetLastOrderIndex` `[O]` (`:10734-10748`): top-down scan for last non-`none`; `-1` when empty. Read-only; the only donor "how full is the queue" primitive.

3.7. Fresh-object init `[O]` (`:2733-2734`): all 12 slots `_unit_ResetOrder`'d at creation (`:2649` + loop).

---

## 4. `amount`/batch representation — one slot carries the batch [O]

4.1. `_unit_OrderProduce(goHnd, ordercid, orderid, amount)` `[O]` (`:5995-6053`):
- Merge scan `[O]` (`:6004-6042`): `MaxOrderCount-1 downto 0`; live `produce` slots with `produceid=orderid` (`:6007-6009`) merge unless the infinite↔finite collision rules fire:
  - finite order onto an infinite slot, or infinite request onto a positive slot → `_unit_CancelUnitProduction(…, amount, True)` + `bExit` (`:6011-6015`) — the existing batch is cancelled/converted, the new request dies;
  - `costpercent in (100, 0)` or `unitcount = orders[i].info.restype` (`:6017`; `restype` stores the live-unit count snapshot at order time — comment verbatim at `:6017`) → merge: infinite stays infinite (`:6021-6022`), else `amount += amount` (`:6024`); per-unit `ApplyCostByID` charged `amount` times (`:6026-6031`) — **never for the infinite sentinel** (`:6026` guard);
  - infinite request onto an infinite slot → `bExit + break` (`:6035-6038`) — duplicate endless silently dropped.
- New slot `[O]` (`:6043-6052`): only `if (not bExit) and (not bMerged)`: charge `amount`× per-unit cost up front (`:6045-6050`, skipped for `usage=field`), then `_unit_AddOrder(…, produce, …, upgradeid=ordercid, produceid=orderid, restype=unitcount, amount, 0, False, False)` (`:6051`). **A 100-unit batch is ONE slot with `amount=100`** (DONOR_RECRUIT_MODIFIERS D19 re-pinned). No per-unit slots are ever created on this path.
- `[D]` (load-bearing, §6.3): the charge loop runs BEFORE `AddOrder`; `AddOrder`'s nil-on-full is unchecked here.

4.2. Negative-`amount` dispatch `[O]` (`:10362-10366,10440-10443` inside `_unit_ProduceUnit :10351…`): `if (amount<=produce_infinite) then begin bsetinfinite := True; amount := round(Abs(amount)); end` — `-1` → one infinite order, `-5` → **five** infinite `OrderProduce` calls (loop `:10368`, call `:10441`). Each call independently hits the merge/exit rules (§4.1): the 2nd–5th endless onto an already-infinite slot take the `:6035-6038` exit. Observable slot count for `-5` is therefore 1 live infinite slot (plus whatever the exit/cancel churn does), NOT 5 queued slots — capture Q-NEG (§10) must confirm, never assume.
- Per-click granularity `[O]` (`:10440-10443`): the non-infinite path calls `_unit_OrderProduce(bldHnd, cid, id, 1)` once per loop iteration (each iteration re-picks the least-loaded building via the `:10386-10424` load scan, which sums `amount` across slots per sid: finite `curproduceamount += amount` `:10393-10394`, infinite counted separately `:10400-10403`, `bState` folds misc+infinite `:10410-10415`).

4.3. `_unit_CancelUnitProduction` `[O]` (`:5893-5991`): outer `for i := 0 to Abs(amount)-1` (`:5900`); inner top-down slot scan for `produce`+`produceid=unitID` (`:5903-5910`); `amount>0 → amount -= 1` (`:5920-5921`); `amount=0` → convert-to-infinite (`:5924-5925`) or `progress := 0` (`:5927`); slot removed only when `amount=0` (or already infinite) and not converted (`:5979-5981`, `_unit_RemoveOrder(goHnd, j)`); port-building slot-0 removal also drops the ship dummy (`:5982-5983`). Refund is per-unit `floor(price×costmodifier)` over all six resources (`:5960-5977`) with mercenary `costpercent/100^count` curve (`:5934-5956`, caps 2 / 20000); `bProcess → _misc_LanForceSyncRes` (`:5989-5990`). `bPayed` is set when `amount>0 or progress>0` (`:5912-5913`) but forced `False` when a converting slot already had `progress>0` (`:5916-5917`) — **converting an in-progress batch to endless forfeits that unit's refund** `[D]`.

4.4. Completion decrement `[O]` (`doprogressorders.inc:247-313`): at `progress>=1` (and `bProcess`): finite `amount -= 1` (`:273-274`), `progress := 0` (`:275`); access-control recheck replays the REMAINDER through `_unit_ProduceUnit` (`:280-290`, donor's own refill path); `amount=0 → _unit_RemoveOrder(myHnd, 0)` (`:292-293`); infinite slots rotate: scan `0..MaxOrderCount-1` for first `none` (`:300-307`), `orders[lastInd] := orders[0]` (`:310`), `_unit_RemoveOrder(myHnd, 0)` (`:311`) — the finished endless moves to the tail so the next slot trains. `if (lastInd>0)` (`:308`): **with no free slot the rotation is skipped** (order stays at head, still `progress=0`, trains again next tick) — infinite output never stalls on a full queue `[D]`.
- Spawn `[O]` (`:315-371`): `WriteNew` at exit point (`:253-259`) or self pos (`:262-266`), port override (`:269-270`), then `OrderLeave` + rally/resource chaining for land (`:361-370`), `GetBuildingExitData` + `OrderLeave` for ships (`:351-359`).
- Mill-field one-shot `[O]` (`:130-136`): `usage=field` → `_unit_DoSeedWheat(myHnd, False)`, `amount := 0`, `_unit_RemoveOrder(myHnd, 0)`. Field sow consumes no train tick.
- Empty-produce guard `[O]` (`:128`, `:377-378`): `id=0` or `amount` neither `>0` nor infinite → `_unit_RemoveOrder(myHnd, 0)`.

4.5. Capture flush `[O]` (`miscext.script:1116-1132`): per slot — `produce` with `amount<>0` is replayed through `_unit_ProduceUnit(…, amount, …)` then `amount := 0` (`:1118-1126`); `performupgrade` → `_unit_CancelUpgradePerform` (`:1129-1130`); then `_unit_ClearOrders` (`:1132`, static-preserving) + STO reset. Queued batches do not transfer to the capturer; they are re-ordered under the new owner (or die with it).

---

## 5. `bDoFirst` preemption [O]

5.1. Mechanics `[O]` (`unit.script:4320-4328` + §3.3): `ind := 0`, head `bexecute := False`, live head shifted down via `OrdersOffset(0,1)`. The upgrade path passes `bDoFirst=True` (`:6069` inside `_unit_OrderUpgrade :6057-6074`, itself guarded by unknown-sid reject, `inprogress`-unless-`bindividual`, and `CanApply` cost gate `:6062-6068`).

5.2. Full-queue preemption `[D]` (direct composition of two `[O]` laws): with all 12 slots live, `OrdersOffset(0,1)` clears slot 11 first (`:2852-2853`). **The tail order is destroyed without refund** (ClearOrder has no resource write, §3.1). Preemption therefore always succeeds and always evicts the tail when full.

5.3. Non-preemptive full queue `[D]` (same composition): `OrderProduce`'s `AddOrder(False, False)` returns nil; the slot write is skipped. See §6.3 for the cost consequence.

5.4. Other in-place merge (contrast) `[O]` (`unit.script:4520-4536` `_unit_OrderExitUnit`): existing `exitunits` slot found top-down → `amount += 1`, no new slot (`:4525-4528`); else `AddOrder(exitunits, …, 1, …, bDoFirst)` (`:4535`). Same batch-in-`amount` shape as produce.

---

## 6. What happens when all 12 slots are full — the full-queue table

No free-slot precheck exists on any caller of `_unit_OrderProduce` (P10 census: the only 4 call sites are the definition, two `ProduceUnit` fan-out calls, and the mill-field sow; the UI/AI `ProduceUnit` load scan `:10386-10424` balances load, never reserves a slot) `[O-absence]`.

| Case | Static law | Status |
|---|---|---|
| New order MERGES (same `produceid`, §4.1 rules) | No slot needed; `amount += amount`, cost charged | `[O]` (`:6004-6042`) |
| New distinct order, free slot exists | Charged (`:6045-6050`), `AddOrder` writes first `none` | `[O]` (`:6043-6052` + §2.4) |
| New distinct order, 0 free slots, `bDoFirst=False` | `AddOrder` returns nil, order lost; **cost was already charged** (`:6045-6050` run before `:6051`) | `[D]` — charge-then-drop quirk; capture Q-FULL (§10) must confirm before any port change |
| New order with `bDoFirst=True` (upgrade / move / exitunit), 0 free slots | Succeeds at slot 0; tail (slot 11) destroyed, no refund | `[D]` from `[O]+[O]` (`:4320-4328` + `:2852-2853`); capture Q-TAIL (§10) |
| Infinite completion, 0 free slots | Rotation skipped (`lastInd>0` fails, `:308`); head re-trains | `[O]` (`:295-313`) |
| Upgrade while another upgrade queued anywhere | Rejected before any slot write (`:10255-10289` selector per UPGRADE-Q2 §3.4; AI-wide mine guard `progresseconomicai.inc:1043-1047`) | `[O]` (inherited, re-pinned) |

---

## 7. Training progress iterates slots — the exact law [O]

7.1. Head-only dispatch `[O]` (`doprogressorders.inc:120`): `case arg_obj.orders[0].itype of`. **Only slot 0 ever advances.** Slots 1..11 are inert storage; no round-robin, no parallel second batch, no per-slot time-slicing exists in this file (416 lines, single dispatch).

7.2. Driver cadence `[O]` (inherited re-pinned from DEC-U-UPGRADE-Q2 §5.2): `units/building.inc/nothing.inc:128-136` — server path `if (orders[0].itype<>none) then ExecuteState('DoProgressOrders')` (`:128-129`); then `lastprogresstime := GetGameTime; progresstick += 1` (`:135-136`). So `deltatime` in the tick formula is the building's own Nothing-tick interval, and an empty head skips the state entirely.

7.3. Tick formula `[O]` (`:217-234`): `deltatime := GetGameTime-lastprogresstime` (guarded `lastprogresstime>0, deltatime>0`, `:219`); **`deltabuildtime := deltatime / objbase.buildtime`** (`:221`); AI-nonhuman difficulty scale `0.3/0.50/0.75/1/1.25` (`:222-231`); `progress += deltabuildtime` (`:232`), clamp 1 (`:233-234`); AI capturer-near pin `progress := 0.995` (`:235-239`).

7.4. Start-gates `[O]` (`:139-205`): evaluated at `bStart` AND every tick: `farmused<farm` clamped by map-limit table (`:142-152`, limits `dmscript.global:1089-1098`), `total<32000` (`:164`), `artcount<artlimit` (`:167`), port-place free `cMinDist=3` (`:19`, `:202-203`), infinite-cost recheck + not-enough-res log (`:184-200`) incl. verbatim food rule (`:199-200`). The upgrade arm (`:380-383` bare delegate to `_misc_UnitProgressOrderPerformUpgrade`) runs NONE of these (UPGRADE-Q2 §5.1).

7.5. Slot flow over time `[D]` (composition): a batch trains at head → each completion decrements `amount` (§4.4) → at 0 the slot is removed and `SortOrders` pulls the next live slot to head (§3.4) → it starts at `progress=0` (`bStart=True`) and pays that tick's start-gates. Queue order is strictly FIFO by slot index. **Port `queue.pop_front()` on the LAST unit of a job is the matching operation; port decrementing `count` per completion is the matching law; port `t` countdown is NOT (donor accumulates `progress += dt/buildtime`, §9 item 3).**

---

## 8. Native order engine — what lives below the script [O-absence + inherited D]

- P11 probe: `findstr /m` over `t_87f0f3c130b0` for `MaxOrderCount` / `bDoFirst` / `TOrderInfo` / `OrdersOffset` → **0 hits each**. Method caveat `[D]`: `findstr` is line-oriented, so this is a coarse probe, not a byte-exhaustive proof. It is consistent with — and only with — the inherited characterization below; no positive native order literal is claimed from it.
- Inherited `[D]` (DEC-U-UPGRADE-Q2 §0-P1, re-pinned `t_87f0f3c130b0`): native entry `0x8f1a08`, packed Delphi `.bind` entropy 7.96, 0 string hits for game terms; engine strings are only `XDMScript`/`XCamera`/`Cossacks 3`. The serial layer is donor *script* (`lib/serial.script`), the engine exposes only `Write*/Read*/Seek*/SizeOf` + `Save/Load/MergeStreamTypeBase` primitives. Order storage (`TObj.orders[12]`) is script-declared reflection data (`dmscript.global:1763`); the engine moves objects/handles (`GetGameObject*ByHandle`, `PlayerExecuteStateByHandle('WriteNew')`) but the slot laws §§2-7 are script text.
- Consequence for this ticket: **no native order-slot literal was recovered or needed**; §§1-7 are authoritative as script `[O]`. Any future native claim requires pinned VA reads, not this report.

---

## 9. Port change list (`game.gd` / `data.gd` — owner/COORD applies; this worker wrote no code)

All items add DONOR-VERBATIM law or explicitly labelled placeholders. None invents a number. None touches save version, existing keys, or network. `config.json:93` (`build_queue_limit: 10`) is a user-file override path and is NOT renamed by any item below.

1. **`data.gd:270-277` — extend cite (no value change).** `DONOR_MAX_ORDER_COUNT=12` already landed via IMPL-QUEUE-LIMIT. ADD comment: one order carries the batch in `info.amount` (`unit.script:5995-6053`); `BUILD_QUEUE_LIMIT` counts port `queue` jobs, NOT donor slots — slot↔job equivalence stays `[U]` (§10 Q-SLOT-JOB). Cite `dmscript.global:113,1678-1702`.
2. **`game.gd:5250` `free_slots` — rewire to merge-first law.** Donor never uses free-slot count to accept an order: `OrderProduce` merges same-`produceid` first (`unit.script:6004-6042`) and only then needs a slot (`:6043-6052`). Port must: on `train_unit`, first fold into an existing same-`sid` finite job (`count += affordable`, charge per unit — matches `:6019-6032`); only genuinely new sids consume `free_slots`. Infinite↔finite collision (`:6011-6015,6035-6038`) must cancel/exit, not append. Tag until wired: `PORT APPROXIMATION (donor: merge-or-new-slot, no free-slot precheck)`.
3. **`game.gd:7614` `job.t -= dt*tsm` — rewire to donor accumulation.** Replace countdown with `progress += (dt / buildtime_seconds) × difficulty_mult` (AI-nonhuman only: `0.3/0.50/0.75/1/1.25`), clamp 1, `0.995` AI-capturer pin, per `doprogressorders.inc:221-239`. Source `build_time` per sid from the per-sid frame literals (units plain `FramesToTime`, buildings ×10 — DEC-U-VICTORY-START §4.1). Move `train_speed_mult/art_build_mult` (game.gd:7609-7613) off the sim path (test/cheat multiplier, never default-on). Finite `count` stays HUD-side as the view of donor `amount`.
4. **`game.gd:5279-5280` batch append — already donor-shaped, cite it.** `{"count": affordable}` in ONE job dict IS the `amount`-in-one-slot law (`unit.script:6051`); add the cite + `[O]` tag. Do NOT fan a batch into N jobs.
5. **`game.gd:5292-5308` `cancel_train` — rewire to per-unit decrement.** Donor `CancelUnitProduction` (`unit.script:5893-5991`) decrements `amount` per unit with per-unit refund and removes the slot only at 0/convert; port refunds `n×price` and drops the whole job at once. Single-unit cancel must do `count -= 1` + single-price refund, drop job only at 0 (cite `:5920-5927,5979-5981`). Full-job cancel keeps the current shape (matches the `Abs(amount)` loop intent `[I]`).
6. **`game.gd:7608` head-only + FIFO note.** Add comment: donor advances `orders[0]` only (`doprogressorders.inc:120`); `pop_front` on last unit + `SortOrders`-equivalent density is already the matching law — cite `unit.script:2812-2842`. No code change.
7. **`game.gd:7642-7647` endless re-arm — add no-free-slot branch.** Donor infinite completion rotates to tail only if a free slot exists, else re-trains at head (`doprogressorders.inc:295-313`). Port: infinite job with `queue.size() == BUILD_QUEUE_LIMIT` keeps position and resets `t` (current code already resets in place — cite the donor lines as the authority, do not invent rotation).
8. **Capture-flush gap (no port counterpart found).** Donor replays produce batches + cancels upgrades on capture (`miscext.script:1116-1132`); port capture path was not re-audited this ticket — file as `[U]`-Q-CAPTURE with experiment §10. Do not invent behavior.
9. **Telemetry/format.** Every added line carries `file:line` + `[O]/[D]/[U]` tag; `visual_parity_claim=false`; unresolved list after this ticket = [Q-SLOT-JOB, Q-FULL, Q-TAIL, Q-MERGE, Q-NEG, Q-ROT, Q-CAPTURE] (§10).

---

## 10. Still-[U] register — each with a fixed-seed queue capture + zero-mismatch criterion (no slot↔job mapping invented)

Conventions for all captures (owner-authorised; binary run by owner, never this worker): fixed seed S, fixed map, fixed nation pair, full stock unless the capture varies cost; instrumented owner build dumps donor `orders[0..11].{itype,produceid,amount,restype,progress}` per building-Nothing tick + port `queue` snapshot per tick. Wall-clock is IRRELEVANT — all criteria compare slot dumps and tick counts.

| # | Item | Static state after this ticket | Exact experiment |
|---|---|---|---|
| Q-SLOT-JOB | Slot↔job equivalence (the headline [U] from IMPL-QUEUE-LIMIT) | NOT proven: donor slots vs port jobs count different things; `BUILD_QUEUE_LIMIT=12` is the donor slot COUNT adopted as a limit, not an equivalence | Seed S, one barracks: issue N=1,5,12,13 distinct-sid train orders (all affordable, farm/art-capped-safe). Snapshot donor `orders[0..11]` occupancy + port `queue.size()` each tick. **Zero-mismatch:** 3 identical-seed runs ⇒ identical slot dumps AND identical port snapshots; the MAPPING (which job index ⇔ which slot) is reported as observed, never asserted as law. Any divergence (e.g. port drops N=13 while donor merges) stays `[U]` with the divergent dump quoted. |
| Q-FULL | Charge-then-drop on full queue (§6.3) | `[D]` from `[O]+[O]`; behaviourally unconfirmed | Seed S: fill 12 slots with 12 distinct unmergeable produce orders, then order a 13th distinct affordable sid. Log `res[]` before/after + slot dump. **Zero-mismatch:** 3 runs identical; EITHER `res` unchanged + no new slot (guard exists elsewhere — quote its `file:line`, downgrade §6.3 to closed) OR `res` charged + no new slot (quirk confirmed — port must mirror or explicitly tag). No third outcome accepted without a verbatim cite. |
| Q-TAIL | `bDoFirst` tail eviction (§5.2) | `[D]` from `[O]+[O]`; behaviourally unconfirmed | Seed S: fill 12 slots with distinct produce orders (log `res[]`), then order an upgrade (or `bDoFirst` move). Dump all 12 slots + `res[]`. **Zero-mismatch:** 3 runs identical; assert upgrade at `orders[0]`, prior `orders[10]` now at `orders[11]`, prior `orders[11]` GONE, no refund delta. |
| Q-MERGE | Mercenary `costpercent`/`restype` merge fork (`:6017`) | Law `[O]`; WHICH branch real mercenary rows take still `[U]` | Seed S: order N mercenary units where live count changed since ordering (so `unitcount <> restype`) with `costpercent ∉ {100, 0}`. Dump slots. **Zero-mismatch:** 3 runs identical; merge ⇒ one slot `amount` grows, new-slot ⇒ occupancy grows. Quote the row's `costpercent` line with the outcome. |
| Q-NEG | `-5` endless fan-out (§4.2) | Dispatch `[O]`; observable slot count `[U]` | Seed S: issue `amount=-5` on one building with full stock. Dump slots per tick. **Zero-mismatch:** 3 runs identical; report exact live-slot count and which iterations took the `:6035-6038` exit. Never assert "5 endless queues" in the port until this passes. |
| Q-ROT | Infinite rotation target (§4.4) | Law `[O]` (`orders[lastInd] := orders[0]`); tail-position observable `[U]` in port terms | Seed S: infinite order at head + one finite order behind; complete one infinite cycle. Dump slots. **Zero-mismatch:** 3 runs identical; assert finite order now at head with `progress` advancing, infinite at first `none` index. |
| Q-CAPTURE | Capture flush of queued batches (§4.5) | Law `[O]`; port has no counterpart (not audited) | Seed S: queue 2 batches + start an upgrade, then capture the building. Dump victor `orders[]`, loser `upgstate`, `res[]` deltas both sides. **Zero-mismatch:** 3 runs identical; assert produce replayed (`ProduceUnit` re-order), upgrade cancelled + refunded, `ClearOrders` density. |

---

## 11. Explicit non-claims and file discipline

- NO PARITY CLAIM. The slot laws §§1-7 rest on donor TEXT `[O]` with `file:line`; full-queue cost behavior, tail eviction, merge forks, and every capture in §10 are explicitly NOT recovered behaviourally and must never be quoted as donor-grounded until their captures pass with zero mismatch.
- No number invented: 12 is the donor literal (`dmscript.global:113`); `amount`/`restype`/`progress` semantics are transcribed, not assigned; no slot↔job conversion factor (no "1 job = 1 slot") is asserted — §9 item 1 and Q-SLOT-JOB keep the adoption (limit value) separate from the equivalence (unproven).
- The `gainres infiniteorderind` arm (§2.5) is cited so it is never mistaken for produce capacity; peasant-gather queue semantics are out of scope and carry no port recommendation.
- Read-only compliance: exactly one repo file written (this report). All donor evidence is text reads + `findstr` negative probe + inherited pinned VAs; donor binary never executed, never copied; no source/asset/config/test/runner/Godot/git state changed.
- Network out of scope: `bProcess` gates, `WriteUpgrade/ReadUpgrade` mirror, `LanForceSyncRes` tails, and replay/client preview branches are cited only as exclusion boundaries.

*End of DEC-U-ORDER-SLOTS.*
