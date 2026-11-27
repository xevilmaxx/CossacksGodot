---
id: DEC-U-UPGRADE-Q2
worker: DEC-U-UPGRADE-Q2 (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. Donor binary never executed/copied/opened as target. Donor text scripts/data read as text only (CP1251 Russian comments not translated, quoted structurally). No repo code/asset/config/Godot/git edit: this report is the only file written."
network: "OUT OF SCOPE. All _net_IsClient/_net_IsReplay/_net_IsServer/_net_IsRecord/_net_IsOffline/bProcess branches are cited only as exclusion boundaries. No net behavior specified."
parity: "NO PARITY CLAIM. No donor GPU A/B frame; no donor binary executed by this worker. All [O] items are donor TEXT with file:line; every number the port needs but the donor text does not give stays [U] with an exact capture."
context: "Closes DEC_U_victory_start.md Q2 (performupgrade timing was PORT APPROXIMATION) and DEC_U_skirmish_tables.md Q1 (upgrade/research timing + cost). Reads _misc_UnitProgressOrderPerformUpgrade + order/cost/apply/cancel/save/AI/queue paths statically."
labels: "[O] verbatim donor literal (file:line) · [D] deterministic reading · [I] inference, flagged · [U] UNVERIFIED with exact experiment · PORT APPROXIMATION = port substitute to remove for 1:1"
---

# DEC-U-UPGRADE-Q2 — upgrade/research order law: duration, accumulation, cost, completion, queue (2026-11-26)

## 0. Pin + pass ledger (every pass pinned `t_87f0f3c130b0`; donor read-only, never executed)

| # | Pass | Result / evidence |
|---|---|---|
| P1 | Pin re-assert | `t_87f0f3c130b0`: `(Get-Item cossacks.exe).Length` = **5,768,048 B** this ticket (matches DEC-U-VICTORY-START/DEC-U-SKIRMISH-TABLES pin + sha `87f0f3c130b0…4e16c`). No binary executed, copied, or opened as a target. Native static analysis is closed per prior evidence (`entry 0x8f1a08`, packed Delphi `.bind` entropy 7.96, 0 string hits for game terms, engine strings only `XDMScript @0x958d1a`, `XCamera @0x958b6b/@0x959066`, `Cossacks 3 @0x96b304`): **no upgrade duration/cost literal exists in native code to recover** — scripts are authoritative `[O-absence, inherited D]`. |
| P2 | `lib/miscext.script:63-106` full read | EV-U-CORE: `_misc_UnitProgressOrderPerformUpgrade` verbatim §1 (all `[O]`). Duration divisor, progress increment, completion call, `bProcess` gate, `bindividual` log guard. |
| P3 | `lib/miscext.script:340-360,1100-1135` dispatch + capture-flush read | EV-U-DISP: `DoProgressOrders` case routes slot 0 to EV-U-CORE `[O]`; capture path flushes produce orders but **cancels** performupgrade via `_unit_CancelUpgradePerform` `[O]` §5. |
| P4 | `lib/unit.script:6055-6074` order-entry + `5764-5833` cost gates + `5836-5890` cancel-refund + `5993-6053` produce-merge (contrast) read | EV-U-ORDER: `_unit_OrderUpgrade` guard + `bDoFirst=True` insert `[O]`; `_unit_CanApplyUpgradeCostBySID` affordable-test + AI surcharge `[O]`; `_unit_ApplyUpgradeCostBySID` deduct-six + stats `[O]`; `_unit_CancelUpgradePerform` slot scan + refund + `inprogress:=False/timestart:=0` `[O]` §2/§3. |
| P5 | `lib/unit.script:4302-4388` AddOrder mechanics + `10225-10328` MakeUpgrade/WriteUpgrade selector read | EV-U-QUEUE: `bDoFirst` offset-to-0 vs first-free-slot `[O]` §6; one-upgrade-per-building selector + `level=upglevel+2` bindividual rule + cost→order→charge→`inprogress/timestart` sequence `[O]` §6. |
| P6 | `lib/player.script:1647-2022` Apply read | EV-U-APPLY: order-removal loop (with verbatim `orders[j]` index hazard, flagged not smoothed) + `upgstate` stamps + 20-way `itype` completion switch + link-enable + `WriteApply` net tail `[O]` §4. |
| P7 | `lib/country.script:617-660,755-775` + `dmscript.global:1828-1853,1790-1799,737-763` struct/enum read; samples `:1160-1211,1520-1570,3860-3975` | EV-U-TIME: `time := _misc_FramesToTime(time)` setter law + direct-seconds overwrites + `TCountryUpgrade.time: Float` + `TPlayerUpgradeState` fields + `gc_upg_type_*` 0-27 enum `[O]` §1. |
| P8 | `units/building.inc/doprogressorders.inc:1-383` + `building.inc/ondeath.inc:1-25` + `lib/miscext2.script:4520-4544` RepairSession read | EV-U-TICK: produce-gate block vs upgrade bare-delegate (`:380-383` ONLY `_misc_UnitProgressOrderPerformUpgrade(myHnd)`) `[O]`; death-cancel-refund `[O]`; RepairSession keeps performupgrade slots `[O]` §5/§7. |
| P9 | `units/building.inc/nothing.inc:1-137` cadence driver + `units/global.inc/writeupgrade.inc:1-90` + `readupgrade.inc:1-62` net mirror + `progresseconomicai.inc:640-660,1035-1050,3590-3660` AI guards read | EV-U-CAD: `Nothing` → `DoProgressOrders` every server tick + `lastprogresstime/progresstick` stamp `[O]`; write/read mirror order→charge→stamp `[O]`; AI `orders[0]<>performupgrade` entry guard + `orders[0]=performupgrade` early-exit `[O]` §7. |
| P10 | `dmscript.global:630-660,113` + `lib/misc.script:1226-1272` order vocabulary read | EV-U-VOCAB: `performupgrade=8`, `produce=4`, `MaxOrderCount=12`, `produce_infinite=-1` `[O]`; log serializer proves `upgradeid/produceid/restype/amount/progress` slot shape `[O]` §6. |
| P11 | Port `variant3d/scripts/game.gd:4579-4616,4618-4721,6834-6898` + `data.gd:2403-2520,266-268,300-319` read-only inspection (no edit) | EV-PORT: live `research/t/apply_upgrade/UPGRADES_BASE` countdown + cost + multiplier surface with line cites §8 (all port-side). |
| P12 | Negative searches (read-only) | `progress*.inc` + `doprogressorders.inc` contain **no** per-tick upgrade cost, **no** farm/food/art gate on the upgrade path, **no** difficulty multiplier on `delta`, **no** `progress:=0.995` pin on the upgrade path `[O-absence]` §1/§7. `country.script` direct `time:=` overwrites are seconds literals at those lines only — no global upgrade-time table is asserted beyond the per-row literal. |

DSL note `[D]` (inherited): donor `not X` on a numeric lvalue is the current-value read, not boolean negation. Applied once in §2 (CanApply affordable-test).

---

## 1. Duration source — per-upgrade seconds `gCountry[cid].upgrade[upgind].time` [O] (never invent)

1.1. Type `[O]` (`dmscript.global:1828-1838`): `TCountryUpgrade` carries `price = Integer[gc_ResCount]`, **`time = Float`**, `bindividual = Boolean`, `iarrparam1/sarrparam2`, `level/branch/itype/value`. Player side `[O]` (`:1790-1799`): `TPlayerUpgradeState { sid; done, enabled, inprogress, grey: Boolean; timestart, timedone: Float; bscenariodisabled }`.

1.2. Setter law `[O]` (`country.script:619-636` `_country_SetUpgrade`): `country.upgrade[upgind].time := _misc_FramesToTime(time)` where the `time` parameter is an **Integer frames** literal at the call site; `_misc_FramesToTime(v) = v*gc_frames_to_time`, `gc_frames_to_time = 0.03125` (`dmscript.global:174`, `misc.script:470-482` per DEC-U-VICTORY-START §4.1). So a call-site `time=1500` frames ⇒ `46.875 s` in the struct.

1.3. Direct-seconds overwrites are verbatim seconds `[O]`: `country.script:1173` `upgrade[ind-1].time := 46.875`; `:1198` `:= 46.875`; `:1471` `:= 46.875`; `:1495` `:= 46.875`; `:1539` `:= 23.4375`; `:1564` `:= 7.8125`. Arithmetic check `[D]`: `46.875 = 1500×0.03125`, `23.4375 = 750×0.03125`, `7.8125 = 250×0.03125` — consistent with the frames→seconds law, but the LAW cited is the assignment at that line, never a recomputed value. **Port must transcribe the per-upgrade literal at its row** (frames param or seconds overwrite), never a global research time, never an invented `UPGRADES_BASE[*].time` (current port `8.0/10.0/12.0/14.0/18.0/20.0/22.0/26.0` values in `data.gd:2403-2520` have **no donor counterpart on the rows inspected** — PORT APPROXIMATION until each row is cited to its `country.script` call site + overwrite).

1.4. Accumulation law `[O]` (`miscext.script:65-106`, full fn):
- `bProcess := not (_net_IsClient or _net_IsReplay)` (`:69`).
- `pobj/cid/upgind := orders[0].info.upgradeid` (`:71-73`); `if (upgind>0)` guard (`:74`).
- `bStart := (progress=0)` is **computed and then unused** (`:80`) — verbatim dead local `[O]`; do not port as behavior.
- `lastprogresstime/deltatime := GetGameTime-lastprogresstime`, gated `lastprogresstime>0 and deltatime>0` (`:83-85`).
- `progress := GetGameObjectStateMachineIntervalByHandle(goHnd)/1000` is read into a local and **never used** (`:87`) — verbatim dead read `[O]`; the divisor below does NOT use it.
- **`delta := deltatime / gCountry[cid].upgrade[upgind].time`** (`:88`) — the ONLY duration input. No difficulty scale, no farm check, no food check, no art check on this path (contrast produce `:170-231`, absent here — P12 `[O-absence]`).
- `if (bProcess) and (not upgstate.inprogress) and (not bindividual)` → `ErrorLog(...goUID...)` (`:91-92`): diagnostic only, no branch change.
- `progress += delta` (`:95`); `if (progress>=1) then bDone := True` (`:96-97`). **No clamp to 1** (contrast produce `:232-234` clamp) — verbatim `[O]`; overshoot persists until `_player_ApplyUpgrade` removes the order.
- `if (bDone) then if (bProcess) then _player_ApplyUpgrade(plHnd, goHnd, cid, upgind, True)` (`:98-102`).

Net law `[D]`: `ticks_to_complete = ceil(upgrade.time / dt_tick)` at the building's `Nothing→DoProgressOrders` cadence (§7); research `t` countdown with per-tick `dt` subtraction is PORT APPROXIMATION (port `game.gd:6888`), not the donor division law.

1.5. `bDone` is an uninitialized `Boolean` local defaulting `False` (`:82`); only set inside the `deltatime` guard. If the guard fails the call is a no-op (progress untouched, no completion) `[D]`.

---

## 2. Resource/gold cost gates — order-time charge, AI surcharge, refund [O]

2.1. Cost source `[O]` (`country.script:757-775` `_country_GetUpgradeCostBySID`): `price[6]` copied field-for-field from `gCountry[cid].upgrade[upgid].price[i]` for `i` in `0..gc_ResCount-1` (`food/wood/stone/gold/iron/coal` per `dmscript.global:791-797`). Cost lookup key is the **SID string**, resolved via `_country_GetUpgradeIndexByUpgradeID(cid, upgsid, False)` (`:759`).

2.2. Affordable-test `[O]` (`unit.script:5766-5788` `_unit_CanApplyUpgradeCostBySID`):
- `bProcess` same net gate; client/replay preview returns `True` unconditionally (`:5786-5787`).
- AI surcharge verbatim (`:5774-5778`): `if (gPlayer[plInd].bai) then { food := food+500; gold := gold+25; }` — a **gold gate exists** (`+25`) plus food (`+500`); wood/stone/iron/coal unchanged.
- Verbatim predicate (`:5779-5784`): `Result := ((not res[food]>=food) and (not res[wood]>=wood) and … (not res[coal]>=coal))`. Under the DSL `not`-rule `[D]` this reads as **each stock `>=` price** (AND of six sufficiency checks). Caller use (`unit.script:6068,10296`; `writeupgrade.inc:77`) treats `True` = may order/charge. Do NOT reinterpret as negation logic.

2.3. Charge-at-order `[O]` (`unit.script:5792-5833` `_unit_ApplyUpgradeCostBySID` + call sites):
- Deducts all six via `_res_AddResToPlayerByIndex(plInd, k, -price[k])` (`:5800-5805`) + `_misc_LanForceSyncRes` (`:5806`).
- Stats fork verbatim: `single_inside_mine` ⇒ `stat.resonmines[k] += price[k]` (`:5811-5819`); else ⇒ `stat.resonupgrade[k] += price[k]` (`:5822-5829`).
- Call order is **order-then-charge** in BOTH paths: `_unit_OrderUpgrade` (`:6069`) is sequenced BEFORE `_unit_ApplyUpgradeCostBySID` (`:10301`) in `MakeUpgrade` (`:10300-10301`) and `WriteUpgrade` (`:81-82`); both sites check `CanApply` first (`:6068`, `:10296`/`writeupgrade.inc:77`), then `inprogress` guard, then order+charge+stamp. Cost is charged **once at queue time**, never per tick (no charge inside `PerformUpgrade` — P12 `[O-absence]`).

2.4. `inprogress/timestart` stamps `[O]`: set at order time (`unit.script:10302-10303`; `writeupgrade.inc:83-84`; `readupgrade.inc:55-56` mirror): `upgstate[cid][upgid].inprogress := True; timestart := GetGameTime`. Cleared at completion (`player.script:1704-1705`: `inprogress := False; timestart := 0` + `done/timedone` for non-individual §4) and at cancel (`unit.script:5855-5856`: same pair). These are the save-visible research clocks, not the order `progress` float.

2.5. Cancel refund `[O]` (`unit.script:5837-5889` `_unit_CancelUpgradePerform`): scans `gc_obj_MaxOrderCount-1 downto 0`, matches `itype=performupgrade` AND `upgradeid=upgind` (`:5849-5852`), `_unit_RemoveOrder`, clears `inprogress/timestart`, and **refunds the full six-price** via `+food/+wood/…` (`:5859-5864`) + matching `stat.resonmines/resonupgrade -= price` fork (`:5867-5884`) + `_misc_LanForceSyncRes`. Trigger sites: building death (`building.inc/ondeath.inc:21-23`), capture (`miscext.script:1129-1130`), explicit cancel (`unit.script:10322`, `writeupgrade.inc` cancel arm), read-path cancel (`readupgrade.inc:60-62`).

---

## 3. Ordering — where the upgrade sits in the 12-slot queue [O]

3.1. Slot vocabulary `[O]` (`dmscript.global:113` `gc_obj_MaxOrderCount = 12`; `:630-650` order enum with `performupgrade = 8` at `:638`; `:660` `produce_infinite = -1`; `misc.script:1267-1271` log shape proves slot fields `upgradeid/produceid/restype/amount/progress`).

3.2. `_unit_OrderUpgrade` `[O]` (`unit.script:6057-6074`):
```
upgind := GetUpgradeIndexByUpgradeID(cid, upgsid, False)        (:6062)
if (upgind>-1) and (upgstate.sid=upgsid)
   and ((not upgstate.inprogress) or (bindividual)) then       (:6065)
   if (CanApplyCost(plHnd, cid, upgsid)) then                  (:6068)
      _unit_AddOrder(goHnd, performupgrade, …, upgind, …, bDoFirst=True)  (:6069)
else ErrorLog('Unknown upgrade')                               (:6073)
```
Guards: unknown sid rejected; same upgrade already `inprogress` rejected **unless `bindividual`** (per-building mine/tower rows `country.script:3872-3970` set `bindividual=True`); insufficient stock rejected (with AI surcharge inside `CanApply`). No farm/food/art-limit gate at order time (contrast produce) `[O-absence]`.

3.3. `bDoFirst=True` mechanics `[O]` (`unit.script:4304-4328`): `ind := 0; orders[0].bexecute := False; if (orders[0].itype<>none) then _unit_OrdersOffset(goHnd, 0, 1)` — the upgrade **preempts to slot 0**, shifting the prior head down. Non-`bDoFirst` produce instead takes the first `none` slot (`:4335-4342`). Upgrade therefore always researches at the head; `DoProgressOrders` and `PerformUpgrade` both read **`orders[0]` only** (`doprogressorders.inc:120,380-382`; `miscext.script:73`). Queued-behind semantics: any order behind slot 0 waits (no parallel second upgrade on the same building — enforced by the §3.4 selector, and the engine only advances `orders[0]`).

3.4. One-upgrade-per-building selector `[O]` (`unit.script:10255-10289` + identical `writeupgrade.inc:33-68`): scan all 12 slots for ANY `performupgrade` → `bPerformUpgrade`. Start arm requires `not bPerformUpgrade and bbuilt and not bdead` (+ `bindividual ? level=upglevel+2` check `:10269`). Cancel arm requires `bPerformUpgrade` and matches `orders[j].info.upgradeid=upgid`. AI mine-guard `[O]` (`progresseconomicai.inc:1043-1047`): if ANY building in `buildingslist` has `orders[0].itype=performupgrade` → `exit` (one mine upgrade at a time AI-wide); entry guard (`:648`): only consider buildings whose `orders[0].itype<>performupgrade`.

---

## 4. Completion effects — `_player_ApplyUpgrade` [O] (gold-relevant rows included)

4.1. Head `[O]` (`player.script:1649-1706`):
- `upgrade := gCountry[cid].upgrade[upgind]`; `itype=none` ⇒ `ErrorLog` tail (`:2021`), no effect.
- If `goHnd<>0`: scan `gc_obj_MaxOrderCount-1 downto 0`, remove matching `performupgrade` slot(s) (`:1656-1664`). **Verbatim index hazard — do NOT smooth over:** the loop variable is `i` but the second conjunct reads `TObj(pobj).orders[j].info.upgradeid` with the OUTER `j` (`:1662`), not `orders[i]`. Cite exactly; port must implement "remove the completed upgrade's order(s)" as INTENT `[I]` and tag the donor line as the authority, never claim the donor loop is `i`-clean.
- InterfaceIO fanfare (`:1667-1687`): `upgradedone` log + `upgmine`/`upg<sid-tail>` sound + `gbool_gui_update_unitcontrol := True`. Sound/log only.
- `done := True; timedone := GetGameTime()` for non-`bindividual` (`:1701-1702`); always `inprogress := False; timestart := 0` (`:1704-1705`).

4.2. Effect switch `[O]` (`:1707-1982`). `iarr2` is the SID→ID resolution of `sarrparam2` (`:1689-1730`). Full `itype` table (`dmscript.global:737-763` enum `[O]`):

| itype | Value law `[O]` (`player.script` line) | Gold/cost relevance |
|---|---|---|
| `lifeperc=1` | `maxhp := Round(maxhp*(1+value/100))` retro + prospective; live HP rescaled proportionally `:1735-1750` | — |
| `damage=2` | `damagestatic += round(value)`; `damage := floor((damageinit+damagestatic)*(1+damagepercent/100))` per matching weapon-kind `:1752-1770` | — |
| `damageperc=3` | `damagepercent += round(value)`; same recompute `:1771-1789` | — |
| `protection=4` | `protection[kind] += round(value)` `:1790-1801` (DEC-U-SKIRMISH-TABLES §1.4 re-pinned) | — |
| `shield=5` | `shield += round(value)` `:1802-1806` | — |
| `enableunit=6` | `_country_AddEnabled` `:1807-1811` | unlocks recruitment, no direct gold delta |
| `effectfood/wood/stone=7/9/11` | `resefficiency[cid][k] += round(value)` `:1812-1827` | gather efficiency, not a price |
| `effectfoodperc/woodperc/stoneperc=8/10/12` | `resefficiency := Round(resefficiency+value)` `:1815-1828` | — |
| `priceperc=13` | `price[j] := Round(price[j]*(1+StrToInt(sarr2-tail)/100))` for `j=1..ResCount-1` (wood..coal; food index 0 excluded) on listed unit IDs `:1833-1843` | **future unit gold prices change here** (gold `price[4]` scaled when listed) |
| `buildtimeperc=14` | `buildtime := buildtime*(1+value/(100*100000))` `:1845-1849` | divisor `10,000,000` verbatim — near-no-op, do NOT "fix" |
| `attpauseperc=15` | `pause := pause*(1+value/100)` for matching weapon kind `:1850-1858` | value `-30` ⇒ `×0.70` (port `rof_mult` rows grounded here) |
| `attrangeperc=16` | `radiusmax := radiusmax*(1+value/100)` `:1860-1868` | — |
| `attdispertionperc=17` | `dispertion := dispertion*(1+value/100)` `:1869-1877` | value `-35` rows |
| `healing=18` | heal matching live units `hp := min(maxhp, Round(hp+maxhp*value/100))` `:1878-1896` | — |
| `fishingperc=19` | `fishingmax/speed := Round(·*(1+value/100))` `:1897-1904` | — |
| `geology=20` | `bgeology := True` + minimap refresh `:1905-1909` | — |
| `balloon=21` | `bballoon := True` (+ally share) + `_misc_CreateBalloon` `:1910-1926` | — |
| `speedperc=22` | `speed := 1/(speed*(1+value/100))` + water-unit step-interval `Floor` rescale `:1927-1946` | — |
| `fieldlifeperc=23` | `fieldlife := Round(fieldlife+value)` `:1831-1832` | — |
| `single_inside=24` | this building `benabled:=True; upglevel+1; addtransport += round(value)` `:1947-1955` | **mine-slot chain** |
| `single_inside_mine=25` | this building `benabled:=True; upglevel+1; addpeasantabsorber += round(value)` `:1956-1964` | **mine-slot chain** |
| `single_attpauseperc=26` | this building `benabled:=True; upglevel+1; attackrate += value/100` `:1965-1973` | tower RoF rows |
| `single_buildgate=27` | wall building `benabled:=True; upglevel+1; _player_ConstructGates` `:1974-1982` | — |

4.3. Link-enable `[O]` (`:1986-2000`): upgrades listed in `gCountry[cid].upgradelinks[i][1]` whose `[i][0]` equals the completed ID get `enabled := True; done := False; timedone := 0`. Achievement + net tail (`:2002-2018`): `gAchLastUpgrades.Add(cid*maxupgradecount+upgind)` for InterfaceIO; `blan and (online or record)` ⇒ `WriteApply`.

---

## 5. Queue/cadence interaction + loss paths [O]

5.1. Only slot 0 advances. `doprogressorders.inc:120` dispatches on `arg_obj.orders[0].itype`; `performupgrade` arm (`:380-383`) is a bare delegate with **no produce-style gate block** (`:123-205` farm/limit/art/infinite-cost/port checks do NOT run for upgrades) `[O]`. Progress therefore accumulates for research even when the building could not currently train (e.g. farm-capped) — verbatim structural difference, not a bug to "fix".

5.2. Driver cadence `[O]` (`building.inc/nothing.inc:128-136`): server path — `if (orders[0].itype<>none) then ExecuteState('DoProgressOrders')` (`:128-129`); then unconditionally `lastprogresstime := GetGameTime; progresstick += 1` (`:135-136`). Client/replay path (`:17-138`) advances smoke/capture visuals only; `DoProgressOrders` runs on the `else` (server) arm. So `deltatime` in §1.4 is the **building's own Nothing-tick interval** (`GetGameTime - lastprogresstime`), not a fixed 0.03125 step and not the global Progress-slice stagger (`gc_global_TimeCheckExists` gates only the victory/exists block per DEC-U-VICTORY-START §1.4 — no upgrade gate).

5.3. No per-tick cost, no difficulty scale, no capturer pin on the upgrade path `[O-absence]` (P12): `deltabuildtime ×0.3/0.50/0.75/1/1.25` (`doprogressorders.inc:222-231`), infinite-cost recheck (`:184-200`), `progress := 0.995` pin (`:235-239`) all live inside the `produce` arm ONLY. Port multipliers `train_speed_mult/art_build_mult/build_mult` and endless-re-arm/infinite-cost logic must never touch research until a donor literal is cited.

5.4. Loss/refund paths `[O]`: death ⇒ `_unit_CancelUpgradePerform` + full refund (§2.5, `ondeath.inc:21-23`); capture ⇒ same cancel (`miscext.script:1129-1130`) then `_unit_ClearOrders` + ownership move (`:1132-1133`) — **no refund to the old owner on the capture path beyond what `CancelUpgradePerform` itself refunds** (it does refund to `plInd` of the building at call time; tag the ordering, never re-time it). RepairSession (`miscext2.script:4528-4529`) is an explicit no-op arm for `performupgrade` (produce with `amount=0` is cleared `:4521-4527`; upgrade slots are kept) `[O]`. Port `game.gd:7083-7087` clearing `e["research"]=null` on capture with "no refund" comment is therefore PORT APPROXIMATION on the refund half — donor cancels AND refunds via `CancelUpgradePerform`; keep-or-fix per §8 item 5.

---

## 6. What is NOT an upgrade/research literal (do not port as donor law)

- No per-category research-time constant exists on this path: building vs academy vs blacksmith differences are the per-row `time` literals (§1), never a second multiplier `[O-absence]`.
- `bindividual` rows (`country.script:3872-3970` mine/tower chains) are the ONLY multi-concurrent exception: the `inprogress` block is per-building for them (`unit.script:6065`, `:10298`); every other upgrade is globally one-at-a-time per `(cid, upgind)` via `upgstate.inprogress` `[O]`.
- `level = upglevel+2` (`unit.script:10269`, `writeupgrade.inc:47`) is the bindividual chain-advance rule: a building already researching/owning level N takes the row whose `level` equals `individual.upglevel+2` `[O]`. Do not invent a level number.
- AI surcharge is order-gate only (`+500 food / +25 gold` inside `CanApply`, §2.2); there is NO donor per-tick upkeep or research-speed AI bonus on the upgrade path `[O-absence]`.

---

## 7. Still-[U] register — each with a fixed-seed research capture + zero-mismatch criterion (no duration/cost invented)

| # | Item | Static state after this ticket | Exact experiment (owner-authorised; binary run by owner, never this worker) |
|---|---|---|---|
| Q2-TIME | Per-upgrade `time` literal for each port `UPGRADES_BASE` row | LAW grounded (§1: divisor is `gCountry[cid].upgrade[upgind].time` seconds; setter = frames×0.03125; overwrites verbatim). VALUES still [U]: no port row is yet cited to its `country.script` call-site frames param + overwrite line. | Fixed seed S, 1 blacksmith, full stock, queue ONE upgrade U: log `orders[0].info.progress` each building-Nothing tick to completion. **Zero-mismatch:** 3 identical-seed runs ⇒ identical tick count AND identical `progress` trace; `ticks×dt_tick ≈ time_literal` within one tick; value adopted only after citing `country.script:<line>` frames/seconds literal. Repeat per U. Never assert `8.0/10.0/12.0…` until cited. |
| Q2-COST | Per-upgrade six-price + gold gate for each port row | LAW grounded (§2: `price[6]` via `_country_GetUpgradeCostBySID`; charge-once at order; AI `+500 food/+25 gold`; refund-full on cancel). VALUES still [U]: port `cost` dicts are estimates. | Same setup: snapshot `res{food,wood,stone,gold,iron,coal}` + `stat.resonupgrade/resonmines` before order, after order, after cancel, after completion. **Zero-mismatch:** 3 runs identical deltas; `after_order = before − price_row` exactly; cancel restores exactly; `resonupgrade` (or `resonmines` for mine rows) increments by `price_row`. Adopt only with `country.script:<line>` price literal. Gold rows must show the `gold` delta explicitly. |
| Q2-GATE | `inprogress` block vs `bindividual` concurrency | LAW grounded (§3.4). BEHAVIOUR still [U] in port. | Seed S: order upgrade U on building A; attempt U on building B (same cid): expect reject for shared rows, accept for `bindividual` mine/tower rows; attempt second U' on A while A researches: expect reject (slot-0 busy). **Zero-mismatch:** 3 runs identical accept/reject matrix. |
| Q2-ORDER | `bDoFirst` preempt + slot-0-only progress | LAW grounded (§3.3/§5.1). PORT still [U] (port has separate `queue` + `research` fields, not 12 slots). | Seed S: fill building with a train job, then order U: assert U lands in `orders[0]`, prior head shifts to slot 1, and only slot 0 `progress` advances. **Zero-mismatch:** identical slot dumps across 3 runs. |
| Q2-DONE | Completion dispatch (`ApplyUpgrade` itype) per effect family | Switch transcribed verbatim (§4, all 20 itypes `[O]`). PORT `effect` mults still estimates. | Per family (damage/protection/priceperc/buildtimeperc/attpause/mine-slots): complete U on seed S, dump `objbase` before/after + one live-unit `hp/weapon/price` probe. **Zero-mismatch:** 3 runs identical before/after pairs; formula check uses donor `round()`/`floor()` exactly (bankers note per DEC-U-SKIRMISH-TABLES §8 stays open). The `orders[j]` hazard (§4.1) must be quoted if the trace shows multi-slot removal oddity — never silently "fix" in the capture. |
| Q2-LOSS | Death/capture cancel + refund routing | LAW grounded (§5.4). PORT `research=null, no refund` still APPROXIMATION. | Seed S: (a) destroy researching building ⇒ assert `CancelUpgradePerform` refund deltas + `inprogress=False/timestart=0`; (b) capture researching building ⇒ assert cancel + refund-to-whom + `upgstate` flags. **Zero-mismatch:** 3 runs identical resource/flag deltas. |
| Q2-CAD | Nothing-tick `deltatime` source under lag/pause/speed | Driver grounded (§5.2: `GetGameTime-lastprogresstime`). RATE under game-speed/pause still [U]. | Seed S at each game-speed (`DONOR_GAME_SPEED`): identical research ⇒ tick counts scale exactly with game-time (not wall-time). **Zero-mismatch:** per-speed 3-run identical; pause ⇒ `deltatime=0` no-op runs identical. |

---

## 8. Port change list (`game.gd` / `data.gd` — owner/COORD applies; this worker wrote no code)

All items add DONOR-VERBATIM law or explicitly labelled placeholders. None invents a number. None touches save version, existing keys, or network.

1. **`data.gd:UPGRADES_BASE` rows — re-source to §1, keep tagged until cited.** Each row keeps its key but gains `donor_sid / donor_time_expr / donor_price` comments citing `country.script:<call-site>+<overwrite line>`; numeric `time/cost` stay `PORT APPROXIMATION` until that cite lands. Duration consumer must become `progress += dt / donor_time_seconds` (NOT `r.t -= dt`). Never assert the current `8.0/10.0/…` set as donor.
2. **`game.gd:6885-6898` `_tick_building` research arm — rewire to §1.4.** Replace `r.t -= dt; if r.t<=0` countdown with donor accumulation on the researching slot: `progress += deltatime / donor_time_seconds` where `deltatime = GetGameTime - lastprogresstime` at the building's Nothing cadence; completion at `progress>=1` (no clamp); then the §4 dispatch. Keep per-building single-`research` field only as a VIEW over slot 0 until 12-slot orders land; tag `PORT APPROXIMATION (donor: orders[0] of 12 slots, bDoFirst preempt)`.
3. **`game.gd:4581-4616` `research()` gate — rewire to §§2-3.** Order of checks becomes donor order: (a) unknown-sid reject (`ErrorLog` path); (b) `inprogress` reject unless `bindividual` (mine_/tow_rof rows only); (c) slot-0 busy reject (building already researching); (d) `CanApply` with AI `food+500/gold+25` surcharge; (e) insert-at-head (`bDoFirst`) + charge-once + `inprogress:=True/timestart:=GetGameTime`. Current `pay_cost` stays as the charge primitive but must deduct all six donor prices (not the estimated dict subset) once cited. Current `mine_/tow_rof` per-building vs global split is CORRECT in shape (matches `bindividual`) — keep, cite `country.script:3872-3970`.
4. **`game.gd:4618-4721` `apply_upgrade/apply_upgrade_to_building` — rewire to §4 row-for-row.** Each `effect` branch gains the donor `itype` cite (`player.script:<line>`); `round()`/`floor()` call sites use donor semantics with the `[U]`-G1 bankers tag; `buildtimeperc` keeps the verbatim `/(100*100000)` divisor; `priceperc` applies to wood..coal only (food excluded); `single_inside(_mine)` writes go to the RESEARCHING BUILDING (`individual.*`), not the player; link-enables (`upgradelinks`) and `done/timedone/inprogress/timestart` stamps are added as state (save-visible). No effect number is changed without its `country.script` value literal.
5. **`game.gd:7083-7087` capture path — fix refund half.** Keep `research=null` (matches slot flush) but ADD donor `CancelUpgradePerform` refund (six-price + stats decrement + `inprogress/timestart` clear) citing `miscext.script:1129-1130 + unit.script:5837-5889`. Tag until wired: `PORT APPROXIMATION (donor refunds; port drops)`.
6. **`data.gd:266-268` queue caps — already correct, extend cite.** `DONOR_MAX_ORDER_COUNT=12` (`dmscript.global:113`) is landed; ADD comment that an upgrade occupies ONE slot via `bDoFirst→slot 0` (`unit.script:4304-4328,6069`) and that `BUILD_QUEUE_LIMIT` counts slots while produce batches live in `amount` (DEC-U-VICTORY-START §4.2). `MAX_BUILDERS_SENT=8` stays `PORT APPROXIMATION` (untouched by this ticket).
7. **Telemetry/format.** Every added line carries `file:line` + `[O]/[U]` tag; `visual_parity_claim=false`; unresolved list after this ticket = [Q2-TIME-values, Q2-COST-values, Q2-GATE-behaviour, Q2-ORDER-slots, Q2-DONE-effects, Q2-LOSS-routing, Q2-CAD-rate, CAM-initial-focus, Q3-build-hit-path, T1-tail, D1, G1-tail, A1-tail, R1, O1-tail per SKIRMISH-TABLES §9 + VICTORY-START §6].

---

## 9. Explicit non-claims and file discipline

- NO PARITY CLAIM. Resolved items (accumulation divisor, charge/refund law, slot-0/bDoFirst law, completion switch shape, cadence driver, AI surcharge) rest on donor TEXT `[O]` with `file:line`; per-upgrade VALUES (every `time` seconds and every six-price, including all gold costs) are explicitly NOT recovered by this ticket and must never be quoted as donor-grounded until §7 captures cite their rows.
- No number invented: no `time` seconds, no price, no gate threshold, no multiplier is asserted for any named upgrade. The only numbers in this report are donor literals quoted with their lines, or port line numbers quoted as port-side.
- The `orders[j]` hazard in `player.script:1662` and the dead locals in `miscext.script:80,87` are reported verbatim, not normalised.
- Read-only compliance: exactly one repo file written (this report). Donor binary never executed/copied/opened-as-target; native addresses above are inherited prior evidence, not new analysis. No source/asset/config/test/runner/Godot/git state changed. Net branches cited only as exclusion boundaries.

*End of DEC-U-UPGRADE-Q2.*
