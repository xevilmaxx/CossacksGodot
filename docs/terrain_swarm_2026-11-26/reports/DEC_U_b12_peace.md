---
id: DEC-U-B12-PEACE-2026-11-27
worker: DEC-U-B12-PEACE (subagent, full 1:1 Cossacks 3 donor port)
date: 2026-11-27
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
scope: "READ-ONLY static donor-text sweep over C:\\Games\\Cossacks 3\\data\\scripts\\** and data/game/var/** plus repo reports. No donor binary executed/copied. No code/Godot/git edits: this report is the only file written."
pin: "t_87f0f3c130b0 (carried from DEC_U_d4_floats.md / DEC_U_menu_peace.md; not re-verified by this worker — no native execution, no target-open)"
tooling: "read-only shell only (Get-Content / Select-String / Get-FileHash) over donor text. CraftAnything native_* not used. Donor binary never executed/copied."
labels: [O, D, U, NO_APPROXIMATION, PARITY_UNVERIFIED, NO_PARITY_CLAIM]
parity_status: UNVERIFIED
parity_claim: NONE
visual_parity_claim: false
verdict: "RESULT IS NOT GOOD — blocking_unverified non-empty; B12 values stay [U]; chain 0/6"
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
governing_sources:
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_u_classify.md  (B12 next angle, S-MKT/Q2/VIC/PEACE class B)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_d4_floats.md     (market prices/U6-T/DLT already swept — NOT redone here)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_upgrade_q2.md    (upgrade law: divisor/charge/slot/bDone/Apply switch)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_upgrade_rows.md   (per-row time/cost inventory + generator law)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_menu_peace.md     (peace enum/labels/lobby/init/expiry chain)
---

# DEC-U-B12-PEACE — static donor-text sweep: upgrade time/cost/gate/preempt/dispatch/loss/cadence + peace indices/60x (2026-11-27)

## 0. Method and negative scope

Read-only `Select-String` / `Get-Content` / `Get-FileHash` passes only. Every `[O]` below is a
verbatim donor-text line with `path:line` as returned by the shell. `[D]` is a deterministic
reading of that text. `[U]` is everything requiring live execution. No value is invented;
no static literal is promoted to live port behaviour. Market-price computation
(`res.script:184-342`, `floor`, rational push, `Lerp`/`round`/`MaxFloat`) is **NOT redone**:
it is owned by `DEC_U_d4_floats.md` (U6-T/DLT/O1). This ticket cites it only as the
cost-push boundary (§6) and re-uses its `[O]` line numbers without re-arguing them.

Byte identity (read-only `Get-FileHash`, SHA256, 2026-11-27):

| File | SHA256 |
|---|---|
| `...\data\scripts\lib\country.script` | `96156485571558506037A3CB85E496A1D1D978600E81D8CA2DA94AB230F953CA` |
| `...\data\scripts\lib\res.script` | `3F96F486F4ED94798619F6A4944678798D25461DD6F4113AA720E2B7B22DED18` |
| `...\data\scripts\lib\misc.script` | `1B2613CD63320C39FD9997EEA608ED732A4442BF3FA664686878ED69D2F1A26B` |
| `...\data\scripts\lib\unit.script` | `57C81156EC3FEDDBAA313F94B5245B6BD1565D2D4F43592A717847410FD192DF` |
| `...\data\scripts\lib\miscext.script` | `68AC00A3573BCDA104CD0DD3B795DE4E017515BF2653E7D9A6EA6AD892B82D42` |

Donor roots read (all 2026-11-27): `data/scripts/lib/country.script`,
`data/scripts/lib/res.script`, `data/scripts/lib/misc.script`,
`data/scripts/lib/unit.script`, `data/scripts/lib/miscext.script`,
`data/scripts/lib/miscext2.script`, `data/scripts/lib/player.script`,
`data/scripts/dmscript.global`, `data/scripts/units/building.inc/doprogressorders.inc`,
`data/scripts/units/building.inc/nothing.inc`,
`data/scripts/units/building.inc/ondeath.inc`,
`data/scripts/common.inc/dogenerate.inc`,
`data/scripts/progress/progress.inc/nothing.inc`,
`data/gui/menu.inc/showcustomgame.inc`, `data/gui/menu.inc/eventcustomgame.inc`,
`data/gui/menu.inc/donewgame.inc` (171 lines), `data/game/var/startingsettings.cfg`,
`data/locale/en/gui.txt`.

## 1. Upgrade TIME — per-row seconds law `[O]`

### 1.1 Setter law + frame constants `[O]`

- `data/scripts/lib/country.script:619-636` (`_country_SetUpgrade`): the `time` parameter is
  **Integer frames**; `:632` `country.upgrade[upgind].time := _misc_FramesToTime(time);`;
  `:636` `bindividual := False` default; `:626-631` six-price field copy
  `(food,wood,stone,gold,iron,coal)`.
- `data/scripts/dmscript.global:174` `gc_frames_to_time = 0.03125;` (`:175`
  `gc_time_to_frames = 32`). `[D]`: `seconds = frames × 0.03125`
  (`500→15.625`, `300→9.375`, `1000→31.25`, `320→10.0`, `1→0.03125`, `0→0.0`).
- Struct `[O]`: `dmscript.global:1837` `TCountryUpgrade.price = Integer[gc_ResCount]`
  (`gc_ResCount = 7`, `:3`); `:1838` `time = Float`.

### 1.2 Generator default `time=500` `[O]`

- `data/scripts/lib/country.script:872-925` (`AddUpgradePack`): per nonzero `value[j]`
  (`j=0..5`, skip-if-zero `:877`) emits one row with **hardcoded `time=500` frames**
  (`:920` `_country_AddUpgradeWithAccessControl(..., 500, x, y, ind, food[j], ...)`),
  `level=j+2`, `enabled=(j=0) and bEnabled`, chain link to next nonzero row (`:921-922`).
  `[D]`: every pack row is `15.625 s` unless hit by a §1.3 overwrite.
- `~113` per-nation `SetUpgStruct*` call sites (`:936-2210`) expand through this rule;
  full per-nation matrix therefore inherits `500` except the rows below.

### 1.3 The ONLY direct-seconds overwrites `[O]` (exhaustive; grep `upgrade[ind(-i)?].time :=` = 6 hits)

| Line | Statement | Hits row(s) | Effective s |
|---|---|---|---|
| `:1173` | `country.upgrade[ind-1].time := 46.875;` | last row of 17c-officer damage pack (`:1172`) | 46.875 |
| `:1198` | `country.upgrade[ind-1].time := 46.875;` | last row of 17c-officer protection pack (`:1197`) | 46.875 |
| `:1471` | `country.upgrade[ind-1].time := 46.875;` | last row of 18c-officer damage pack (`:1470`) | 46.875 |
| `:1495` | `country.upgrade[ind-1].time := 46.875;` | last row of 18c-officer protection pack (`:1494`) | 46.875 |
| `:1539` | `for i:=1 to 6 do country.upgrade[ind-i].time := 23.4375;` | ≤6 most recent = 17c-stable damage pack (`:1536`) | 23.4375 |
| `:1564` | `for i:=1 to 6 do country.upgrade[ind-i].time := 7.8125;` | ≤6 most recent = 17c-stable protection pack (`:1562`) | 7.8125 |

`[D]`: `ind` is the append cursor (`:668` `ind := ind+1`), so `ind-1` = last emitted row.
Short-pack bleed (loop always runs 6) is reproduced verbatim from Q2/ROWS; not re-derived here.

### 1.4 Sample call-site frames `[O]` (representative, not exhaustive — full census in ROWS §§1-2)

- `300` frames → `9.375 s`: `country.script:3438` (`century18` enable), `:3871-3881`
  mine `.1–.6` (`bindividual`, food+gold only, e.g. `:3871` `1000f/1250g`).
- `500` frames → `15.625 s`: `:3454` (`.1` effectfood 140, `750f/250g`); `:3518`
  (`.9` shield 85); `:3714` (`bla.1` fieldlifeperc 100); `:3936` (ferry `single_inside` 200,
  `1000f/1250g`, `bindividual` `:3937`).
- `320` frames → `10.0 s`: artillery cost/build `.1.1–.2.3` rows (`:3758-3766`, `:3809-3817`,
  cannon+howitzer).
- `1000` frames → `31.25 s`: `:3627` (academy `.26` healing 50); `:3903-3911`
  tower `.1–.5` (`single_attpauseperc` −20/−20/−10/−10/−10; commented `.6` `:3913` never added).
- `1500` frames → `46.875 s`: `:3993` (2nd-mill `.1` healing 50 — the ONLY `1500` param).
- `1` frame → `0.03125 s`: `:3943,3951,3960,3969` wall `single_buildgate` 5 (four nation-group
  variants, `bindividual` `:3944,3952,3961,3970`).
- `0`: `:3431` `'null'` placeholder (never researchable).

### 1.5 Accumulation divisor `[O]` (law re-pinned, values NOT re-argued)

- `data/scripts/lib/miscext.script:65-106` (`_misc_UnitProgressOrderPerformUpgrade`):
  `:69` `bProcess := not (_net_IsClient or _net_IsReplay)`; `:71-73`
  `cid/upgind := orders[0].info.upgradeid`; `:74` `if (upgind>0)` guard; `:80` dead
  `bStart` local (computed, unused); `:83-85`
  `lastprogresstime/deltatime := GetGameTime-lastprogresstime`, gated
  `lastprogresstime>0 and deltatime>0`; `:87` dead `progress` read from
  `GetGameObjectStateMachineIntervalByHandle/1000` (never used); `:88`
  **`delta := deltatime/gCountry[cid].upgrade[upgind].time`** — the ONLY duration input;
  `:95` `progress += delta`; `:96-97` `if (progress>=1) then bDone := True` (**no clamp**);
  `:98-102` `if (bDone) then if (bProcess) then _player_ApplyUpgrade(...)`.
  P12 absence re-affirmed: no per-tick cost, no farm/food/art/difficulty term on this path.

## 2. Upgrade COST — six-price charge-once law `[O]`

- Source `[O]` (`country.script:757-770` `_country_GetUpgradeCostBySID`): `price[6]` copied
  field-for-field `food/wood/stone/gold/iron/coal` (`dmscript.global:791-797`) from
  `gCountry[cid].upgrade[upgid].price[i]`; key is the SID string.
- Gate `[O]` (`unit.script:5764-5788` `_unit_CanApplyUpgradeCostBySID`): `:5774-5778`
  AI surcharge verbatim `if (gPlayer[plInd].bai) then { food := food+500; gold := gold+25; }`;
  `:5779-5784` six-way sufficiency predicate (DSL `not X` = value-read); client/replay
  preview returns `True` (`:5786-5787`).
- Charge `[O]` (`unit.script:5792-5806` `_unit_ApplyUpgradeCostBySID`): deducts all six via
  `_res_AddResToPlayerByIndex(plInd, k, -price[k])` + `_misc_LanForceSyncRes` (`:5806`);
  stats fork `single_inside_mine ⇒ resonmines` (`:5811-5819`) else `resonupgrade` (`:5822-5829`).
  Charged **once at queue time** (call order §4), never per tick.
- Refund `[O]` (`unit.script:5837-5890` `_unit_CancelUpgradePerform`): scans
  `gc_obj_MaxOrderCount-1 downto 0` (`dmscript.global:113` `= 12`), matches
  `itype=performupgrade` + `upgradeid=upgind` (`:5849-5852`), `_unit_RemoveOrder`,
  clears `inprogress:=False/timestart:=0` (`:5855-5856`), refunds full six-price
  (`:5859-5864`) + stats decrement fork (`:5867-5884`) + resync. Triggered by death
  (`building.inc/ondeath.inc:22`), capture (`miscext.script:1130`), explicit cancel
  (`unit.script:10322`, read-path cancel `readupgrade.inc:60-62` per Q2).

## 3. GATE — `inprogress` vs `bindividual` `[O]`

- `unit.script:6055-6074` (`_unit_OrderUpgrade`): `:6062` resolve index; `:6065`
  `(upgstate.sid=upgsid) and ((not inprogress) or (bindividual))`; `:6068`
  `CanApply` check; `:6069`
  `_unit_AddOrder(..., performupgrade, ..., upgind, ..., False, True)` (`bDoFirst=True`);
  `:6073` `ErrorLog('Unknown upgrade')` on `upgind=-1`.
- `bindividual=True` rows `[O]`: `country.script:3872-3982` (mine `.1–.6`), `:3904-3912`
  (tower `.1–.5`), `:3937` (ferry), `:3944-3970` (walls); commented `:3914` NOT emitted.
  Every other upgrade is globally one-at-a-time per `(cid,upgind)`.
- Selector `[O]` (`unit.script:10255-10303` MakeUpgrade + `writeupgrade.inc:33-68` mirror):
  scan all 12 slots for ANY `performupgrade` (`:10255-10261`); start arm requires
  `not bPerformUpgrade and bbuilt and not bdead` (`:10267`) plus
  `bindividual ? level=upglevel+2` (`:10269`); order→charge→stamp sequence
  `:10300-10303` (`OrderUpgrade`, `ApplyUpgradeCost`, `inprogress:=True`,
  `timestart:=GetGameTime`); cancel arm `:10281/10322`.
- AI mine-guard `[O]` (`progresseconomicai.inc:640-660,1035-1050,3590-3660` per Q2):
  entry requires `orders[0].itype<>performupgrade`; one mine upgrade AI-wide.

## 4. PREEMPT + DISPATCH `[O]`

- Preempt `[O]` (`unit.script:4304-4328` `_unit_AddOrder`): `bDoFirst` ⇒ `ind:=0`,
  `orders[0].bexecute:=False`, shift prior head down via `_unit_OrdersOffset(goHnd,0,1)`
  (`:4320-4326`). Non-`bDoFirst` produce takes first `none` slot (`:4335-4342`).
  Research therefore always lands in **slot 0**; queued-behind orders wait.
- Dispatch `[O]` (`building.inc/doprogressorders.inc:120,380-383`): `:120`
  `case arg_obj.orders[0].itype of`; `:380-383` `performupgrade:` arm is a bare
  delegate `_misc_UnitProgressOrderPerformUpgrade(myHnd)` with **no produce-style
  gate block** (farm/limit/art/infinite-cost checks `:123-205` do not run for upgrades).
  Only slot 0 advances.
- Completion head `[O]` (`player.script:1649-1706`): order-removal loop `:1656-1664`
  (verbatim `orders[j]` hazard at `:1662` — cited, never smoothed); `done/timedone`
  for non-`bindividual` (`:1701-1702`); always `inprogress:=False/timestart:=0`
  (`:1704-1705`); 20-way `itype` switch `:1707-1982` (Q2 §4 table, not recopied);
  link-enable `:1986-2000`; `WriteApply` net tail (`:2002-2018`).

## 5. LOSS + CADENCE `[O]`

- Loss paths `[O]`: death ⇒ `CancelUpgradePerform` + full refund
  (`ondeath.inc:21-23` → `unit.script:5837-5890`); capture ⇒ same cancel (`miscext.script:1130`)
  then `_unit_ClearOrders` + ownership move (`:1132-1133`); RepairSession keeps
  performupgrade slots (`miscext2.script:4528-4529` explicit no-op arm; produce `amount=0`
  cleared `:4521-4527`).
- Cadence `[O]` (`building.inc/nothing.inc:128-136,438-492`): server path —
  `if (orders[0].itype<>none) then ExecuteState('DoProgressOrders')` (`:128-129`);
  then unconditionally `lastprogresstime := GetGameTime; progresstick += 1`
  (`:135-136`; mirror `:491-492`). So `deltatime` in §1.5 is the **building's own
  Nothing-tick interval** (`GetGameTime − lastprogresstime`), not a fixed step and not the
  global progress slice. Smoke/rally/sync arms (`:58,441,484`) never touch research.
- Speed/difficulty `[O-absence + O]`: `control.script:551-570` speed modes
  (`dmscript.global:1027-1029` factors `7/10/14`); `//SetTimeSpeedFactor` commented out
  (`:563`) — no script scale on `GetGameTime`/`deltatime`/`upgrade[].time`.
  Difficulty enum `dmscript.global:781-786`; zero `difficulty × upgrade/price/cost/res`
  hits outside AI combat gating (Q2/ROWS P12, re-affirmed by this sweep's greps).

## 6. Rational cost-push / delivery / resonlife — boundary only (market NOT redone) `[O]`

- Market law (pointer, no re-argument): `res.script:252-268` DLT transfer
  (`round(Lerp(ClampInt(...)))`, `trg=r`), `:272-309` recovery
  (`dt=deltatime*0.025*MaxFloat(1,dlt*0.01)`, pull-to-def with `Clamp`),
  `:311-343` market transfer (`floor` at `:315`, rational push `:337-342` with `:340`
  `buyres.sellexp` quirk). All floats/widths/round-half rules stay `[U]` per D4.
- Delivery `[O]` (the charge path this ticket owns): `_unit_ApplyUpgradeCostBySID`
  `:5800-5805` six `_res_AddResToPlayerByIndex(plInd, k, -price[k])` calls — the single
  point where upgrade cost leaves the player stock.
- Resonlife `[O]` (`player.script:21-27,280-302`): stat stores zeroed `:21-27`
  (`resonupgrade/resonmines/resonlife/resbuy/ressell`); `:292`
  `stat.resonlife[i] += value` on consume; `:301` `stat.resonlife[i] += not res[i]` on
  full-take; `:294-295,303-304` `bfamine/brebellion := False` side-effects for
  food/gold. These are stats writes, never price inputs.
- Adjacent-file negatives `[O]`: `donewgame.inc` (171 lines) peace/market/economy/upgrade/
  cost/price grep → **0 hits**; `startingsettings.cfg` same-pattern grep → only `:27`
  `//gc_ai_unit_market = 12;` comment; `country.script` market grep → only upgrade
  `price[...]` assignments + building names (`spamar/mar`, `:2837-3829`), zero
  `gEconomy`/dlt hits; `player.script` market grep → only `resonlife` + `marketdip`
  building gating (`:2741-2763`), zero `gEconomy` hits.

## 7. Peace indices + 60x fix `[O]`

### 7.1 Enum `[O]` (`dmscript.global:1055-1066`)

`default=0, _10=1, _20=2, _30=3, _45=4, _60=5, _90=6, _120=7, _180=8, _240=9,
_reserved=10, _15=11`. Twelve constants, verbatim.

### 7.2 Seconds function `[O]` (`misc.script:4262-4281` `_misc_GetPeaceTime(ind): Float`)

Arms map each named constant to its MINUTE number (`default→0, 10→10, …, 240→240,
15→15` at `:4267-4277`); `_reserved` (10) has **no arm**; `:4278-4279`
`else Result := 0`; `:4281` **`Result := Result * 60`** — seconds. `[D]`:
`gfloat_peacetime` unit is seconds; arm literals are minutes.

### 7.3 Lobby display/fill `[O]` (`showcustomgame.inc`)

- Value-case map `:890-901` covers the 11 tags (`default,10,20,30,45,60,90,120,180,240,15`).
- Count slot `:1032-1033`: `count := gc_mapsettings_peacetime_15` (= 11).
- Fill loop `:1126-1150`: `for i:=0 to gc_mapsettings_peacetime_240` (0..9, `:1126`);
  `case i` → s2 suffix (`:1128-1139`); item tag = enum index (`:1140`
  `GUIListBoxAddItem(elmHnd, text, i)`); `:1143-1146` inserts `15` (tag 11) right after
  `10`; `:1150` tag-restore `GetGUIListBoxItemIndexOfTag(..., peacetime)` — stored value
  IS the enum index. Selectable set: **{0,1,11,2,3,4,5,6,7,8,9}**; index 10 never added.
- Labels `[O]` (`locale/en/gui.txt:553-575`): `Peace Time` header; `No Peace Time`;
  `10/15/20/30/45/60 min`; `1.5 hours / 2 hours / 3 hours / 4 hours` for 90+.

### 7.4 Selection write + wire + init + expiry `[O]`

- Write (`eventcustomgame.inc:60-79`): `additional_options` / `activeoption=3` ⇒
  `gMap.settings.additional.peacetime := tag` (`:79`).
- Wire (`miscext2.script:2375 + :2635`): serialize `roomdata+IntToStr(peacetime)+…`;
  deserialize at `gc_MaxPlayerCount+9`. Raw index crosses the wire, no conversion.
- Init (`dogenerate.inc:2054-2064`): `:2054` `gbool_editor_peacemode := False`;
  `:2059` `gfloat_peacetime := _misc_GetPeaceTime(peacetime)` (seconds);
  `:2060` `gbool_peacemode := (peacetime <> gc_mapsettings_peacetime_default)` — flag from
  the INDEX, not the seconds; `:2064-2065` `if (gbool_peacemode) then SetupBorderObjects`.
- Expiry (`progress/progress.inc/nothing.inc:658-695`): `:658`
  `if (gbool_peacemode) and (gametime > gfloat_peacetime) and (not _net_IsReplay) and
  (not _net_IsClient)` ⇒ `:660` `gbool_peacemode := false`; ptborder collect via
  misc-player handle → `WriteFreeList` + `WritePeaceTime` with `fbstate` (`:684-685`);
  `GameObjectRequestToDestroyByHandle` per border (`:689`);
  `GUIMiniMapPrimitivesClear + _misc_UpdateMiniMapPrimitives(True)` (`:692-693`).
  Strict-`>` boundary: at `gametime == gfloat_peacetime` peace still holds.
- Absences `[O-absence]`: `startingsettings.cfg` `peacetime` grep → 0 hits (peace is NOT
  sourced from that cfg); `donewgame.inc` peace grep → 0 hits; `gui.script` peace grep →
  0 hits (menu peace lives in `menu.inc/*.inc`, not `lib/gui.script`).

## 8. What stays `[U]` and why (no weakening)

| Id | Open piece | Why static text cannot settle it | Zero-mismatch capture termination (exact, owner-executed) |
|---|---|---|---|
| B12-TIME | Per-upgrade `time` seconds for each port row | Setter/generator/overwrite LAW is `[O]` (§1), but port adoption needs the row's own trace; `Float` tick accumulation width is engine-defined | Fixed seed S, 1 building, full stock, queue U: log `orders[0].info.progress` per Nothing tick to completion. **Zero-mismatch:** 3 identical-seed runs ⇒ identical tick count AND identical `progress` trace; `ticks×dt_tick ≈ <row seconds>` within one tick; cite `country.script:<line>` per row |
| B12-COST | Per-row six-price incl. all gold costs + nation `ModifyUpgrade` deltas | Base rows + deltas transcribed `[O]` (§2, ROWS §§2-3), but port `cost` dicts stay estimates until captured | Same setup: snapshot `res[6]` + `stat.resonupgrade/resonmines` before order / after order / after cancel / after complete. **Zero-mismatch:** 3 runs identical deltas; `after_order = before − price[row]` exactly; cancel restores exactly |
| B12-GATE | `inprogress` block vs `bindividual` concurrency behaviour | LAW `[O]` (§3); live accept/reject matrix needs execution | Seed S: order U on A, attempt U on B (shared rows: expect reject; mine/tower rows: accept); attempt 2nd U′ on researching A: reject. **Zero-mismatch:** 3 runs identical matrix |
| B12-PREEMPT | `bDoFirst` preempt + slot-0-only progress | LAW `[O]` (§4); port has no 12-slot surface | Seed S: fill building with a train job, order U: assert U lands in `orders[0]`, head shifts down, only slot-0 `progress` advances. **Zero-mismatch:** identical slot dumps × 3 runs |
| B12-DISP | `PerformUpgrade` divisor path under lag/pause/speed | LAW `[O]` (§§1.5/5); rate under game-speed/pause is engine-clock | Seed S at each `DONOR_GAME_SPEED` mode: identical research ⇒ game-time ticks identical, wall-clock scales; pause ⇒ `deltatime=0` no-op. **Zero-mismatch:** per-mode 3-run identical |
| B12-LOSS | Death/capture cancel + refund routing | LAW `[O]` (§5); refund-to-whom on capture needs execution | Seed S: (a) destroy researching building ⇒ `CancelUpgradePerform` deltas + flags; (b) capture ⇒ cancel + refund-to-whom + `upgstate` flags. **Zero-mismatch:** 3 runs identical deltas |
| B12-PEACE | Lobby→sim peace chain live values | Indices/labels/init/expiry LAW `[O]` (§7); no live tag/seconds/flag/tick log exists | Fixed seed S: (a) lobby tag dump ⇒ exactly `0,1,11,2,3,4,5,6,7,8,9`; (b) `gfloat_peacetime` for {1,11,4,9} ⇒ exactly `600,900,2700,14400`; (c) `gbool_peacemode` false iff index 0; (d) expiry: last `true` tick `gametime<=600`, first `false` tick `gametime>600` + border count → 0. **Zero-mismatch:** 3 runs identical per probe |
| D4-U6T/DLT | Market float semantics (NOT owned here) | Engine `floor`/`round`/`Lerp`/`Float` width — see D4 §4 | Carried, unchanged: U6-T 36-float + DLT 600-tick zero-mismatch batteries |

Prior skirmish-law reports ported the divisor/charge/slot/Apply-switch shapes
`[O-PORT]`; **all class-A behavioural values above stay `[U]`**.

## 9. Claim register and verdict

| # | Claim | Label |
|---|---|---|
| 1 | Upgrade time/cost/gate/preempt/dispatch/loss/cadence literals mapped: setter `:619-636`; frames consts `:174-175`; pack `500` `:872-925`; 6 overwrites `:1173-1564`; sample rows `:3431-3996`; AI surcharge `:5774-5778`; charge `:5792-5806`; cancel `:5837-5890`; order `:6057-6074`; `bDoFirst` `:4304-4328`; divisor `:65-106`; dispatch `:380-383`; cadence `:128-136`; death `:ondeath 22`; capture `miscext:1130-1133`; RepairSession `miscext2:4528-4529` | `[O]` this sweep (hashes §0) |
| 2 | Peace chain mapped: enum `:1055-1066`; seconds fn `:4262-4281` (×60 at `:4281`, `else→0`); lobby `:890-1150`; write `:eventcustom 79`; wire `:2375/:2635`; init `:dogenerate 2059-2065`; expiry `:nothing 658-695`; labels `gui.txt:553-575`; absences (`startingsettings`/`donewgame`/`gui.script` peace → 0 hits) | `[O]` this sweep |
| 3 | Market prices NOT redone; D4 owns `res.script:184-342` float semantics (U6-T/DLT stay `[U]`/blocking) | `[D]` per `DEC_U_d4_floats.md` |
| 4 | NOT recoverable statically: `Float` 32/64 width, `round`/`floor` half-way/negative rules, `Lerp` formula, engine tick/pause/speed clock, live tag/seconds/flag/tick reads | `[U]` §8 |
| 5 | No donor executed/copied, no value wired, no approximation adopted, no parity claimed; exactly one repo file written | `[O]` scope guard |
| 6 | B12 stays `[U]`/blocking: per-row values + live behaviours need §8 zero-mismatch batteries; termination is zero-mismatch, nothing less | `[D]` per `PORT1TO1_u_classify.md` B12 |

> Verdict: `port=UNVERIFIED`; `parity.claim = NONE`; `parity.status = "UNVERIFIED"`;
> `visual_parity_claim = false`; `blocking_unverified` non-empty (P0-1…P0-8 plus domain
> tails incl. B12-TIME/COST/GATE/PREEMPT/DISP/LOSS/PEACE and D4 U6-T/DLT/O1);
> six-condition chain 0/6 CLOSED. **RESULT IS NOT GOOD.** No same-camera donor/port A/B
> frame exists; no approximation is authorised; no parity claim is made.

*End of DEC_U_b12_peace. Read-only; exactly one repository file written;
no source/asset/config/test/runner/Godot/git/donor-execution; B12 remains `[U]`
and is NOT CLOSED; parity UNVERIFIED; `RESULT IS NOT GOOD` while
`blocking_unverified` is non-empty.*
