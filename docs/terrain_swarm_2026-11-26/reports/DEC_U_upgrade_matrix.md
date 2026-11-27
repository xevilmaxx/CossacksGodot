---
id: DEC-U-UPGRADE-MATRIX
worker: DEC-U-UPGRADE-MATRIX (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B (Length re-asserted this ticket via donor dir listing; binary never executed/copied/opened-as-target)"
donor: "READ ONLY. Donor binary never executed/copied/opened as target. Donor text script read as text only. No repo code/asset/config/Godot/git edit: this report is the only file written."
network: "Net branches cited only as exclusion boundaries. No net behavior specified."
parity: "NO PARITY CLAIM. All [O] items are donor TEXT with file:line. Every per-row seconds/cost value the port needs but that is not a verbatim donor literal below stays [U] with an exact capture. Nothing extrapolated from a neighbour row."
context: "Closes the [U]-matrix left by DEC_U_upgrade_rows.md: that ticket recovered all frame/seconds literals and the ~70 explicit add-access rows (country.script:3431-3996) but left the full per-nation pack matrix ([U]-R-matrix) with a capture recipe instead of a hand table. This ticket mechanically decodes the generator law and transcribes the complete _aus (Austria) column plus tur/alg gold deltas and the cannon/howitzer split."
labels: "[O] verbatim donor literal (file:line) · [D] deterministic reading · [I] inference, flagged · [U] UNVERIFIED with exact experiment · PORT APPROXIMATION = port substitute to remove for 1:1"
---

# DEC-U-UPGRADE-MATRIX — per-nation pack matrix: generator law + _aus column + tur/alg deltas + cannon/howitzer split (2026-11-26)

## 0. Pin + pass ledger (every pass pinned `t_87f0f3c130b0`; donor read-only, never executed)

| # | Pass | Result / evidence |
|---|---|---|
| P0 | Pin re-assert | Donor `cossacks.exe` Length = **5,768,048 B** this ticket (matches Q2/ROWS pin + sha `87f0f3c130b0…4e16c`). `country.script` Length = **355,207 B**. Binary never executed/copied/opened-as-target. |
| P1 | Generator law | `TUpgStruct` + `ResetUpgStruct` (`country.script:821-848`), `SetUpgStruct{FoodGold,FoodGoldIron,FoodGoldIronCoal}` (`:849-871`), `AddUpgradePack` (`:872-925`) read verbatim §1. |
| P2 | Setter / delta law | `_country_ModifyUpgrade` sentinel law (`:599-615`), `_country_SetUpgrade` frames→seconds + price copy (`:619-650`), `_country_AddUpgrade` append cursor (`:654-670`) re-read §1. |
| P3 | _aus block map | All 39 `_aus :` hits enumerated by grep; 34 pack `SetUpgStruct` lines + 6 explicit sword rows (`:2126-2133`) + upgplace sequence (`:935,1204,1500,1884,1930,2039`) verified §§2-3. |
| P4 | Pack-call pairing | All 54 `AddUpgradePack(country` call sites enumerated; each _aus struct line paired with its following pack call (type/x/y/bEnabled) §§2-3. |
| P5 | tur/alg deltas | Artillery `ModifyUpgrade` gold deltas (`:3784-3794`, `:3835-3845`) + tur/alg pikeman pack deltas (`:963-964`, `:987-988`) transcribed §4. |
| P6 | Cannon/howitzer split | Cost rows identical, build-time rows split 500f vs 1000f (`:3789-3793` vs `:3840-3844`), member switch (`:3796`), link severing (`:3799-3807`) §4. |
| P7 | Port surface (read-only) | `variant3d/scripts/data.gd:2527-2576` `UPGRADES_BASE` head read; cites in §6. No edit. |
| P8 | Multi-pass re-verify | Every _aus struct line re-read in a second pass (member/upgplace/bEnabled context); `sta2` absence proven by repo-wide `upgplace :=` grep (only `bar/ba2/sta`, no `sta2`) §2. |

Time conversion law `[D]`: `seconds = frames × 0.03125` (`_misc_FramesToTime`, `dmscript.global:174` per ROWS EV-R-TIME). Attested: `500→15.625`, `46.875=1500f`, `23.4375=750f`, `7.8125=250f`.

---

## 1. Generator law (mechanical, no invention) [O]

**EV-M-STRUCT** (`country.script:821-848`): `TUpgStruct{place, member, req[0..5], value/food/wood/stone/gold/iron/coal[0..5]}`. `ResetUpgStruct` zeroes all six arrays + place/member (`:833-847`).

**EV-M-SET** (`:849-871`): three setters differ ONLY in trailing resource tuples —
`SetUpgStructFoodGold`: per-slot `(value, food, gold)` (`:849-858`);
`SetUpgStructFoodGoldIron`: per-slot `(value, food, gold, iron)` (`:859-864`);
`SetUpgStructFoodGoldIronCoal`: per-slot `(value, food, gold, iron, coal)` (`:865-871`).
Unmentioned resources stay 0 (post-Reset). The per-slot `b0..b5` Boolean params are accepted and **dropped** — `TUpgStruct` has no Boolean field and `AddUpgradePack` never reads them `[D]`; all are `True` in every line below (transcribed verbatim, no semantics assigned).

**EV-M-PACK** (`:872-925`): for `j=0..5`, skip slot if `value[j]=0` (`:877`); else emit ONE row:
- `iupgtype := damage/protection` + `iparam1..3` weapon kinds per `upgradetype` (`:883-916`); `iupgtype2 := 1` for damage types, `2` for protection types (`:880,884-916`).
- SID `place.member.{iupgtype2}.(j+1)`, `level := j+2`, `enabled := (j=0) and bEnabled`, **`time := 500` frames** (`:920`), cost `(food[j],wood[j],stone[j],gold[j],iron[j],coal[j])`, access req `req[0..1]` (`:920`).
- Chain: link emitted row to next NONZERO slot (`:921-922`).
- `else ErrorLog('AddUpgradePack : Unknown type')` (`:917-918`).

**EV-M-DELTA** (`:599-615`): `_country_ModifyUpgrade` writes value/price fields **only if arg `<> -1`** (`default` = sentinel keep `[O]`; never 0).

**EV-M-APPEND** (`:654-670`): `_country_AddUpgrade` resolves index, calls `_country_SetUpgrade` (price copy `:626-631`, `time := FramesToTime(time)` `:632`, `bindividual := False` `:636`), registers SID into `upgradeplace`, `ind := ind+1` (`:668`).

**EV-M-PLACE**: `upgplace` sequence this ticket (grep, no `sta2` anywhere): `bar` (`:935`) → `ba2` (`:1204`) → `sta` (`:1500`) → `ba2` (`:1884`) → `sta` (`:1930`) → `bar` (`:2013,2023`) → `ba2` (`:2032`) → `bar` (`:2039`) → `sta` (`:2185`).

Reading rule `[D]`: a pack call's `(upgradetype, x, y, bEnabled)` + the ACTIVE `upgplace`/`member` at that line + the PRECEDING per-nation `SetUpgStruct` line fully determine every emitted row. The tables below apply this rule to `_aus` only.

---

## 2. _aus barracks packs (upgplace `ausbar`, `:935`; member per block; bEnabled `(cid<>_spa)` = True for aus, `:951`)

Pack A1 — struct `:953` → pack `:975` (`ctypeDamagePike`, x0 y1, bEnabled True). Member `pikeman` (`:947`).

| SID | lvl | itype→value | en | time | cost (f,w,s,g,i,c) |
|---|---|---|---|---|---|
| `ausbar.pikeman.1.1` | 2 | damage +1 | T | 500 → 15.625 | 200,0,0,50,0,0 |
| `.1.2` | 3 | damage +2 | F | 500 | 1300,0,0,300,0,0 |
| `.1.3` | 4 | damage +2 | F | 500 | 3600,0,0,450,0,0 |
| `.1.4` | 5 | damage +1 | F | 500 | 7200,0,0,1850,0,0 |
| `.1.5` | 6 | damage +2 | F | 500 | 16030,0,0,2000,0,0 |

Pack A2 — struct `:977` → pack `:1004` (`tmptype=ctypeProtection` `:1000`, x0 y2, bEnabled True). 5 rows:

| SID | lvl | value | en | time | cost (f,w,s,g,i,c) |
|---|---|---|---|---|---|
| `ausbar.pikeman.2.1` | 2 | +1 | T | 500 | 150,0,0,50,0,0 |
| `.2.2` | 3 | +1 | F | 500 | 900,0,0,175,0,0 |
| `.2.3` | 4 | +2 | F | 500 | 4500,0,0,300,0,0 |
| `.2.4` | 5 | +1 | F | 500 | 9005,0,0,507,0,0 |
| `.2.5` | 6 | +1 | F | 500 | 18010,0,0,3050,0,0 |

Pack A3 — struct `:1017` → pack `:1021` (`ctypeDamageSword`, 1,1,True). Member `roundshier` (`:1008`).

| SID | lvl | value | en | time | cost |
|---|---|---|---|---|---|
| `ausbar.roundshier.1.1` | 2 | +1 | T | 500 | 150,0,0,50,0,0 |
| `.1.2` | 3 | +1 | F | 500 | 1500,0,0,200,0,0 |
| `.1.3` | 4 | +2 | F | 500 | 1300,0,0,325,0,0 |

Pack A4 — struct `:1023` → pack `:1027` (`ctypeProtection`, 1,2,True). FoodGoldIron:

| SID | lvl | value | en | time | cost (f,w,s,g,i,c) |
|---|---|---|---|---|---|
| `ausbar.roundshier.2.1` | 2 | +1 | T | 500 | 200,0,0,70,120,0 |
| `.2.2` | 3 | +2 | F | 500 | 4360,0,0,150,320,0 |
| `.2.3` | 4 | +2 | F | 500 | 506,0,0,250,420,0 |

Pack A5 — struct `:1050` → pack `:1073` (`ctypeDamageBullet`, posx=2 `:1046`, y1, True). Member `musketeeraus` (`:1031`).

| SID | lvl | value | en | time | cost |
|---|---|---|---|---|---|
| `ausbar.musketeeraus.1.1` | 2 | +1 | T | 500 | 2000,0,0,100,0,0 |
| `.1.2` | 3 | +1 | F | 500 | 1000,0,0,300,0,0 |
| `.1.3` | 4 | +2 | F | 500 | 500,0,0,700,0,0 |

Pack A6 — struct `:1075` → pack `:1098` (`ctypeProtection`, posx=2, y2, True). FoodGoldIron, all 6 slots nonzero → 6 rows:

| SID | lvl | value | en | time | cost (f,w,s,g,i,c) |
|---|---|---|---|---|---|
| `ausbar.musketeeraus.2.1` | 2 | +1 | T | 500 | 170,0,0,50,100,0 |
| `.2.2` | 3 | +1 | F | 500 | 405,0,0,150,200,0 |
| `.2.3` | 4 | +1 | F | 500 | 1570,0,0,100,350,0 |
| `.2.4` | 5 | +1 | F | 500 | 1556,0,0,550,100,0 |
| `.2.5` | 6 | +1 | F | 500 | 1060,0,0,850,400,0 |
| `.2.6` | 7 | +1 | F | 500 | 3700,0,0,750,700,0 |

Pack A7 — struct `:1113` → pack `:1135` (`ctypeProtection` drummerdef, 4,2,True). Member `drummer` (`:1108` else). 1 row: `ausbar.drummer.2.1` L2 value +12, en T, 500, (706,0,0,50,0,0).

Pack A8 — struct `:1150` → pack `:1172` (`ctypeDamagePike`, 5,1,True). Member `officer` (`:1145` else). 1 row: `ausbar.officer.1.1` L2 value +20, en T, cost (100,0,0,50,0,0), time overwrite `:1173` → **46.875**.

Pack A9 — struct `:1175` → pack `:1197` (`ctypeProtection`, 5,2,True). 1 row: `ausbar.officer.2.1` L2 value +6, en T, cost (1850,0,0,450,0,0), overwrite `:1198` → **46.875**.

Explicit _aus sword rows (non-pack, `AddUpgradeWithAccessControl` directly; upgplace `bar` from `:2039`, member `roundshier` `:2115`):

| Line | SID | lvl / en | itype→value | time | cost (f,w,s,g,i,c) |
|---|---|---|---|---|---|
| `2126` | `ausbar.roundshier.1.4` | 5, False | damage-sword +1 | 500 | 7500,0,0,900,0,0 |
| `2127` | `.1.5` | 6, False | +1 | 500 | 9000,0,0,1080,0,0 |
| `2128` | `.1.6` | 7, False | +2 | 500 | 18750,0,0,2250,0,0 |
| `2131` | `.2.4` | 5, False | protection +1 | 500 | 3750,0,0,450,0,0 |
| `2132` | `.2.5` | 6, False | +1 | 500 | 6750,0,0,810,0,0 |
| `2133` | `.2.6` | 7, False | +2 | 500 | 9375,0,0,1125,0,0 |

Links `:2129-2130` (dmg .1.3→.1.6 chain) and `:2134-2135` (prot chain) `[O]`.

---

## 3. _aus 18c barracks + stables packs (upgplace per header)

### 3.1 Barracks-18c (upgplace `ausba2`, `:1204`; `bhave18century` True for aus, `:929`)

Pack B1 — `:1217`→`:1238` (dmg-pike, 0,1,True). Member `pikeman18` (`:1212`):

| SID | lvl | value | en | time | cost (f,g) |
|---|---|---|---|---|---|
| `ausba2.pikeman18.1.1` | 2 | +2 | T | 500 | 2000,800 |
| `.1.2` | 3 | +2 | F | 500 | 8000,1200 |
| `.1.3` | 4 | +2 | F | 500 | 20000,2500 |
| `.1.4` | 5 | +2 | F | 500 | 32000,2800 |
| `.1.5` | 6 | +2 | F | 500 | 32000,3800 |
| `.1.6` | 7 | +2 | F | 500 | 40500,4800 |

Pack B2 — `:1240`→`:1261` (protection, 0,2,True):

| SID | lvl | value | en | time | cost (f,g) |
|---|---|---|---|---|---|
| `ausba2.pikeman18.2.1` | 2 | +2 | T | 500 | 1500,500 |
| `.2.2` | 3 | +3 | F | 500 | 7000,1500 |
| `.2.3` | 4 | +2 | F | 500 | 37000,2000 |
| `.2.4` | 5 | +3 | F | 500 | 37000,5500 |
| `.2.5` | 6 | +2 | F | 500 | 37000,5500 |
| `.2.6` | 7 | +3 | F | 500 | 64600,5500 |

Pack B3 — `:1288`→`:1310` (dmg-pike, 2,1,True). Member `musketeer18` (`:1283` else):

| SID | lvl | value | en | time | cost (f,g) |
|---|---|---|---|---|---|
| `ausba2.musketeer18.1.1` | 2 | +1 | T | 500 | 1000,800 |
| `.1.2` | 3 | +1 | F | 500 | 1500,800 |
| `.1.3` | 4 | +2 | F | 500 | 2000,800 |
| `.1.4` | 5 | +2 | F | 500 | 2500,800 |
| `.1.5` | 6 | +3 | F | 500 | 3000,800 |
| `.1.6` | 7 | +3 | F | 500 | 3500,800 |

Pack B4 — `:1312`→`:1333` (protection, 2,2,True):

| SID | lvl | value | en | time | cost (f,g) |
|---|---|---|---|---|---|
| `ausba2.musketeer18.2.1` | 2 | +1 | T | 500 | 3706,350 |
| `.2.2` | 3 | +2 | F | 500 | 11030,1350 |
| `.2.3` | 4 | +2 | F | 500 | 35706,4000 |
| `.2.4` | 5 | +1 | F | 500 | 36556,4350 |
| `.2.5` | 6 | +2 | F | 500 | 30060,1350 |
| `.2.6` | 7 | +2 | F | 500 | 37600,1350 |

Pack B5 — `:1352`→`:1373` (dmg-pike, 3,1,True). Member `grenadier` (`:1347` else). Post-pack edit `:1374-1376` retargets LAST row (`.1.6`) `tooltiptype := grenadedmg`, `iarrparam1[0] := mortarball` `[O]`:

| SID | lvl | value | en | time | cost (f,g) |
|---|---|---|---|---|---|
| `ausba2.grenadier.1.1` | 2 | +2 | T | 500 | 2000,800 |
| `.1.2` | 3 | +3 | F | 500 | 12000,1800 |
| `.1.3` | 4 | +4 | F | 500 | 32000,2800 |
| `.1.4` | 5 | +5 | F | 500 | 42000,3800 |
| `.1.5` | 6 | +6 | F | 500 | 52000,4800 |
| `.1.6` | 7 | +1500 | F | 500 | 62000,15800 |

Pack B6 — `:1378`→`:1399` (protection, 3,2,True):

| SID | lvl | value | en | time | cost (f,g) |
|---|---|---|---|---|---|
| `ausba2.grenadier.2.1` | 2 | +1 | T | 500 | 3706,350 |
| `.2.2` | 3 | +2 | F | 500 | 11030,1350 |
| `.2.3` | 4 | +3 | F | 500 | 35706,3000 |
| `.2.4` | 5 | +1 | F | 500 | 36556,3350 |
| `.2.5` | 6 | +2 | F | 500 | 30060,1350 |
| `.2.6` | 7 | +3 | F | 500 | 64000,1350 |

Pack B7 — `:1414`→`:1435` (protection drummerdef, 4,2,True). Member `drummer18` (`:1408-1409` else). 1 row: `ausba2.drummer18.2.1` L2 value +15, en T, 500, (706,0,0,50,0,0).

Pack B8 — `:1449`→`:1470` (dmg-pike, 5,1,True). Member `officer18` (`:1443-1444` else). 1 row: `ausba2.officer18.1.1` L2 value +30, en T, cost (1000,0,0,800,0,0), overwrite `:1471` → **46.875**.

Pack B9 — `:1473`→`:1494` (protection, 5,2,True). 1 row: `ausba2.officer18.2.1` L2 value +12, en T, cost (1706,0,0,350,0,0), overwrite `:1495` → **46.875**.

### 3.2 Stables 17c (upgplace `aussta`, `:1500`)

Pack S1 — `:1515`→`:1536` (dmg-pike, 0,1,True). Member `reiter` (`:1510` else). Overwrite `:1538-1539` retimes last ≤6 rows → **all 6 rows 23.4375** `[O]`:

| SID | lvl | value | en | time | cost (f,g) |
|---|---|---|---|---|---|
| `aussta.reiter.1.1` | 2 | +1 | T | 23.4375 | 500,100 |
| `.1.2` | 3 | +2 | F | 23.4375 | 900,220 |
| `.1.3` | 4 | +1 | F | 23.4375 | 4400,280 |
| `.1.4` | 5 | +1 | F | 23.4375 | 2250,320 |
| `.1.5` | 6 | +1 | F | 23.4375 | 3030,600 |
| `.1.6` | 7 | +1 | F | 23.4375 | 7500,1800 |

Pack S2 — `:1541`→`:1562` (protection horsedef, 0,2,True). FoodGoldIron. Overwrite `:1563-1564` → **all 6 rows 7.8125** `[O]`:

| SID | lvl | value | en | time | cost (f,w,s,g,i,c) |
|---|---|---|---|---|---|
| `aussta.reiter.2.1` | 2 | +2 | T | 7.8125 | 200,0,0,135,300,0 |
| `.2.2` | 3 | +3 | F | 7.8125 | 600,0,0,100,400,0 |
| `.2.3` | 4 | +3 | F | 7.8125 | 800,0,0,200,560,0 |
| `.2.4` | 5 | +2 | F | 7.8125 | 1600,0,0,300,640,0 |
| `.2.5` | 6 | +1 | F | 7.8125 | 3200,0,0,350,300,0 |
| `.2.6` | 7 | +1 | F | 7.8125 | 16000,0,0,1000,5000,0 |

Pack D1 — `:1634`→`:1657` (dmg-bullet, 2,1, bEnabled=True `:1656`). Member `dragoon` (`:1629` else):

| SID | lvl | value | en | time | cost (f,g) |
|---|---|---|---|---|---|
| `aussta.dragoon.1.1` | 2 | +1 | T | 500 | 500,150 |
| `.1.2` | 3 | +1 | F | 500 | 700,200 |
| `.1.3` | 4 | +2 | F | 500 | 900,340 |
| `.1.4` | 5 | +1 | F | 500 | 0,0 |
| `.1.5` | 6 | +1 | F | 500 | 0,0 |
| `.1.6` | 7 | +3 | F | 500 | 0,0 |

Chain law `[O]`: `:1658-1667` severs every link whose head contains `sta.dragoon.1.3` (and `sta.dragoonpol.1.3`) — `.1.3→.1.4` broken, so `.1.4-.1.6` (enabled False) are unreachable via links.

Pack D2 — `:1670`→`:1692` (protection horsedef, 2,2, bEnabled True):

| SID | lvl | value | en | time | cost (f,g) |
|---|---|---|---|---|---|
| `aussta.dragoon.2.1` | 2 | +1 | T | 500 | 900,150 |
| `.2.2` | 3 | +2 | F | 500 | 6600,750 |
| `.2.3` | 4 | +2 | F | 500 | 5000,1250 |
| `.2.4` | 5 | +1 | F | 500 | 3000,700 |
| `.2.5` | 6 | +2 | F | 500 | 1000,2350 |
| `.2.6` | 7 | +2 | F | 500 | 6001,5000 |

### 3.3 Stables 18c (upgplace still `aussta` — no `sta2` exists, §1 EV-M-PLACE)

Pack C1 — `:1710`→`:1731` (dmg-pike, 3,1,True). Member `cuirassier` (`:1705` else):

| SID | lvl | value | en | time | cost (f,g) |
|---|---|---|---|---|---|
| `aussta.cuirassier.1.1` | 2 | +1 | T | 500 | 12000,600 |
| `.1.2` | 3 | +1 | F | 500 | 32000,1300 |
| `.1.3` | 4 | +1 | F | 500 | 62000,2200 |
| `.1.4` | 5 | +2 | F | 500 | 61000,3150 |
| `.1.5` | 6 | +2 | F | 500 | 57055,4100 |
| `.1.6` | 7 | +3 | F | 500 | 49050,8020 |

Pack C2 — `:1733`→`:1754` (protection horsedef, 3,2,True). FoodGoldIron:

| SID | lvl | value | en | time | cost (f,w,s,g,i,c) |
|---|---|---|---|---|---|
| `aussta.cuirassier.2.1` | 2 | +2 | T | 500 | 1760,0,0,350,1000,0 |
| `.2.2` | 3 | +3 | F | 500 | 3000,0,0,750,2000,0 |
| `.2.3` | 4 | +3 | F | 500 | 7600,0,0,300,3030,0 |
| `.2.4` | 5 | +2 | F | 500 | 8700,0,0,6200,100,0 |
| `.2.5` | 6 | +1 | F | 500 | 8700,0,0,2350,5000,0 |
| `.2.6` | 7 | +1 | F | 500 | 9700,0,0,4444,7060,0 |

Pack H1 — `:1771`→`:1792` (`ctypeDamageSword`, 4,1,True). Member `hussar` (`:1766` else). FoodGoldIron with **food 0 on early tiers** (verbatim):

| SID | lvl | value | en | time | cost (f,w,s,g,i,c) |
|---|---|---|---|---|---|
| `aussta.hussar.1.1` | 2 | +1 | T | 500 | 0,0,0,1800,1000,0 |
| `.1.2` | 3 | +2 | F | 500 | 0,0,0,3800,2000,0 |
| `.1.3` | 4 | +3 | F | 500 | 20200,0,0,0,2000,0 |
| `.1.4` | 5 | +4 | F | 500 | 32000,0,0,0,3000,0 |
| `.1.5` | 6 | +1 | F | 500 | 49200,0,0,0,3500,0 |
| `.1.6` | 7 | +1 | F | 500 | 20000,0,0,0,6000,0 |

Pack H2 — `:1794`→`:1815` (protection, 4,2,True):

| SID | lvl | value | en | time | cost (f,g) |
|---|---|---|---|---|---|
| `aussta.hussar.2.1` | 2 | +1 | T | 500 | 1760,1350 |
| `.2.2` | 3 | +1 | F | 500 | 1900,2350 |
| `.2.3` | 4 | +1 | F | 500 | 1600,5350 |
| `.2.4` | 5 | +2 | F | 500 | 8000,8350 |
| `.2.5` | 6 | +2 | F | 500 | 2000,15350 |
| `.2.6` | 7 | +3 | F | 500 | 56000,20150 |

Pack E1 — `:1833`→`:1854` (dmg-bullet, 5,1,True). Member `dragoon18` (`:1828` else). Req `century18` (2nd req slot):

| SID | lvl | value | en | time | cost (f,g) |
|---|---|---|---|---|---|
| `aussta.dragoon18.1.1` | 2 | +2 | T | 500 | 2000,100 |
| `.1.2` | 3 | +2 | F | 500 | 9000,350 |
| `.1.3` | 4 | +4 | F | 500 | 12000,400 |
| `.1.4` | 5 | +2 | F | 500 | 23000,580 |
| `.1.5` | 6 | +2 | F | 500 | 32000,680 |
| `.1.6` | 7 | +4 | F | 500 | 42000,780 |

Pack E2 — `:1856`→`:1877` (protection horsedef, 5,2,True):

| SID | lvl | value | en | time | cost (f,g) |
|---|---|---|---|---|---|
| `aussta.dragoon18.2.1` | 2 | +1 | T | 500 | 760,935 |
| `.2.2` | 3 | +1 | F | 500 | 1260,1150 |
| `.2.3` | 4 | +2 | F | 500 | 15600,2350 |
| `.2.4` | 5 | +1 | F | 500 | 17600,3350 |
| `.2.5` | 6 | +2 | F | 500 | 19600,5350 |
| `.2.6` | 7 | +3 | F | 500 | 21760,9350 |

Pack P1 — `:1898`→`:1905` (dmg-bullet, 1,1,True). Member `pandur` (`:1886`); upgplace back to `ausba2` (`:1884`):

| SID | lvl | value | en | time | cost (f,g) |
|---|---|---|---|---|---|
| `ausba2.pandur.1.1` | 2 | +1 | T | 500 | 3000,750 |
| `.1.2` | 3 | +1 | F | 500 | 4000,1100 |
| `.1.3` | 4 | +2 | F | 500 | 7000,1800 |
| `.1.4` | 5 | +1 | F | 500 | 12000,350 |
| `.1.5` | 6 | +1 | F | 500 | 32020,850 |
| `.1.6` | 7 | +2 | F | 500 | 45200,1330 |

Pack P2 — `:1918`→`:1925` (protection infdef, 1,2,True):

| SID | lvl | value | en | time | cost (f,g) |
|---|---|---|---|---|---|
| `ausba2.pandur.2.1` | 2 | +1 | T | 500 | 3706,350 |
| `.2.2` | 3 | +2 | F | 500 | 12060,1350 |
| `.2.3` | 4 | +2 | F | 500 | 36706,2250 |
| `.2.4` | 5 | +1 | F | 500 | 36706,3350 |
| `.2.5` | 6 | +2 | F | 500 | 37060,1350 |
| `.2.6` | 7 | +2 | F | 500 | 16706,1350 |

Pack U1 — `:1947`→`:1957` (`cUpgType=ctypeDamageSword` for aus — only pol/swe remap to pike, `:1955-1956`). Member `croat` (`:1932`); upgplace `aussta` (`:1930`); posx=1 (`:1944-1945`):

| SID | lvl | value | en | time | cost (f,g) |
|---|---|---|---|---|---|
| `aussta.croat.1.1` | 2 | +1 | T | 500 | 2000,500 |
| `.1.2` | 3 | +2 | F | 500 | 5000,800 |
| `.1.3` | 4 | +2 | F | 500 | 10000,1200 |
| `.1.4` | 5 | +1 | F | 500 | 20000,1300 |
| `.1.5` | 6 | +2 | F | 500 | 30000,3000 |
| `.1.6` | 7 | +2 | F | 500 | 20000,5000 |

Pack U2 — struct `:1959`→pack `:1966` (protection horsedef, posx=1, y2, True):

| SID | lvl | value | en | time | cost (f,g) |
|---|---|---|---|---|---|
| `aussta.croat.2.1` | 2 | +1 | T | 500 | 2000,1350 |
| `.2.2` | 3 | +1 | F | 500 | 1500,2100 |
| `.2.3` | 4 | +2 | F | 500 | 5000,2300 |
| `.2.4` | 5 | +2 | F | 500 | 10500,3400 |
| `.2.5` | 6 | +3 | F | 500 | 12600,4500 |
| `.2.6` | 7 | +3 | F | 500 | 40000,5000 |

_aus column total: 28 (A) + 39 (B) + 12 (S) + 12 (D) + 12 (C) + 12 (H) + 12 (E) + 12 (P) + 12 (U) + 6 (explicit) = **157 rows** `[D-count]`. Times: all 500f → 15.625 s except A8/A9/B8/B9 single rows 46.875 (`:1173,:1198,:1471,:1495`) and S1 23.4375 ×6 + S2 7.8125 ×6 (`:1538-1539,:1563-1564`).

---

## 4. tur/alg gold deltas + cannon/howitzer split [O]

Base rows are nation-shared; tur/alg pay the `ModifyUpgrade` gold override (sentinel law §1 EV-M-DELTA; `ind-1` = just-emitted row `[D]`).

Cannon (`member='cannon'`, `:3743`; cost rows `:3758-3781`, build rows `:3783-3794`):

| Row | Base cost (f,w,s,g,i,c) / time | tur/alg gold → | Cite |
|---|---|---|---|
| `art.cannon.2.1` build −2500000, en T | (0,0,0,500,1000,0), 320 | **950** | `:3783-3784` |
| `.2.2` | (0,0,0,1000,2000,0), 320 | **150** | `:3785-3786` |
| `.2.3` | (0,0,0,2000,3000,0), 320 | **250** | `:3787-3788` |
| `.2.4` | (2560,0,0,0,0,0), **500** | **1350** | `:3789-3790` |
| `.2.5` | (3560,0,0,0,0,0), **500** | **2500** | `:3791-3792` |
| `.2.6` | (5560,0,0,0,0,0), **500** | **3350** | `:3793-3794` |

Howitzer (`member='howitzer'`, switch `:3796`; cost rows `:3809-3832` identical to cannon; build rows `:3834-3845`):

| Row | Base cost / time | tur/alg gold → | Cite |
|---|---|---|---|
| `art.howitzer.2.1` build −2500000, en T | (0,0,0,500,1000,0), 320 | **350** | `:3834-3835` |
| `.2.2` | (0,0,0,1000,2000,0), 320 | **450** | `:3836-3837` |
| `.2.3` | (0,0,0,2000,3000,0), 320 | **550** | `:3838-3839` |
| `.2.4` | (2560,0,0,0,0,0), **1000** | **1150** | `:3840-3841` |
| `.2.5` | (3560,0,0,0,0,0), **1000** | **3200** | `:3842-3843` |
| `.2.6` | (5560,0,0,0,0,0), **1000** | **4500** | `:3844-3845` |

Split summary `[D]`: `.1.1-.1.6` cost rows identical (320/320/320/500/500/500 both members); `.2.1-.2.3` identical 320f; **`.2.4-.2.6` differ: cannon 500f vs howitzer 1000f**; gold overrides differ per member (cannon tail 1350/2500/3350 vs howitzer tail 1150/3200/4500). Link severing: `:3799-3803` (cannon last-3 tails) + `:3804-3807` (howitzer last-3 tails) `[O]`.

Pack-level tur/alg deltas (examples; same `SetUpgStruct` positions, different tuples):
- Pikeman dmg `:953` (aus: values 1,2,2,1,2; food 200/1300/3600/7200/16030; gold 50/300/450/1850/2000) vs `:963` tur / `:964` alg (values 2,2,2,2,2; food 200/600/1200/2200/16030; gold 50/300/450/1850/2000) `[O]`.
- Pikeman prot `:977` (aus values 1,1,2,1,1) vs `:987` tur / `:988` alg (values 1,2,3,1,2; same food/gold) `[O]`.
- Roundshier dmg `:1017` (aus 1,1,2) vs `:1018-1019` tur/alg (1,1,1 — third value 1300-gold tier dropped to value 1) `[O]`.
- Roundshier prot `:1023` (aus 1,2,2) vs `:1024-1025` tur/alg (1,1,2 — second tier value 2→1, food 4360→6360) `[O]`.

---

## 5. Still-[U] register — per-nation matrix cells + captures (nothing extrapolated)

Seed convention S (owner-executed; worker never runs the binary): fixed map + fixed nation pair + fixed `DONOR_GAME_SPEED` + full stock; instrumented owner build logs `orders[0].info.{upgradeid,progress}`, `gCountry[cid].upgrade[upgind].{time,price[0..6]}` at queue time, `res[0..6]` + `stat.resonupgrade/resonmines` before/after/cancel/complete. Wall-clock IRRELEVANT.

| # | Item | Static state after this ticket | Exact experiment |
|---|---|---|---|
| R-MATRIX-aus | 157 _aus rows §§2-3 as PORT values | LAW + all tuples + pack pairings grounded `[O]`; PORT adoption still [U] | Per _aus SID: queue tier (prereq chain first), run R-TIME + R-COST. **Zero-mismatch:** 3 identical-seed runs ⇒ identical tick count + progress trace + `after_order = before − price` exactly; cancel restores; link-enable per `:921-922` (severed: dragoon `:1658-1667`, artillery `:3799-3807`, 17c-officer tails — last-3 sever per ROWS §2.2). |
| R-MATRIX-other | All non-aus nation columns (23 nations × same pack skeleton, own tuples at the sibling `_xxx :` lines, e.g. `:954-973`, `:978-997`) | Generator LAW `[O]`; every tuple line cited by the block map below; hundreds of cells [U] — NEVER copy an _aus neighbour value | Same per (nation × member × tier). **Zero-mismatch** as above. Priority: tur/alg (gold deltas §4), ukr/sco (missing 18c blocks, `bhave18century=False` `:929`, empty members `:938,:1005-1007,:1036-1037`), pru/swe value-order swaps (`:961` food rotation). |
| R-TIME | Seconds for every row | LAW + all frames params + 6 overwrites grounded `[O]` (ROWS §1 + §2 above) | `orders[0].info.progress` per building-Nothing tick to completion. **Zero-mismatch:** 3 runs identical trace; `ticks×dt_tick ≈ <row seconds>` within one tick. |
| R-COST | Six-price per row incl. gold | Base + delta tuples transcribed `[O]`; PORT dicts estimates | Res/stat snapshot before/after/cancel/complete. **Zero-mismatch:** exact delta, exact restore, `resonupgrade` (or `resonmines` for mine rows). |
| R-1972 | Pack call `:1972` (protection horsedef 1,2) struct source | Call `[O]`; feeding struct block UNREAD this ticket [U] | Cite struct lines + run R-MATRIX on its SIDs before adoption. |
| R-ADDON | Nation-specific add-on rows `:2039-2210` (aus: none observed — aus absent from those member blocks; VERIFY, do not assume) | Block cites `[O]`; aus-participation [U] | Grep-equivalent owner check per nation + R-MATRIX capture for any emitted aus SID. |

Non-aus block map (file:line cites for the capture runner; tuples NOT transcribed here — read the cited line at capture time):
barracks-17c dmg `:953-974` → `:975`; prot `:977-998` (+`tmptype` `:1000-1003`) → `:1004`; roundshier dmg `:1017-1020` → `:1021`; prot `:1023-1026` → `:1027`; musketeer dmg `:1050-1072` (posx `:1046-1048`) → `:1073`; prot `:1075-1097` → `:1098`; drummer `:1113-1134` → `:1135`; officer dmg `:1150-1171` → `:1172` (+`:1173`); prot `:1175-1196` → `:1197` (+`:1198`).
barracks-18c pikeman18 dmg `:1217-1237` → `:1238`; prot `:1240-1260` → `:1261`; sword `:1268-1270` (sco-only `:1264-1271`); musketeer18 dmg `:1288-1309` → `:1310`; prot `:1312-1332` → `:1333`; grenadier dmg `:1352-1372` → `:1373` (+`:1374-1376` mortarball retarget); prot `:1378-1398` → `:1399`; drummer18 `:1414-1434` → `:1435`; officer18 dmg `:1449-1471` → `:1470` (+`:1471`); prot `:1473-1495` → `:1494` (+`:1495`).
stables reiter dmg `:1515-1535` → `:1536` (+`:1538-1539`); prot `:1541-1561` → `:1562` (+`:1563-1564`); light-cav/dragoon blocks `:1567-1693` (dragoon bEnabled `:1656`, sever `:1658-1667`); 18c cuirassier `:1710-1731` → `:1731`, `:1733-1754` → `:1754`; hussar `:1771-1792` → `:1792`, `:1794-1815` → `:1815`; dragoon18 `:1833-1854` → `:1854`, `:1856-1876` → `:1877`; pandur `:1898-1905` → `:1905`, `:1918-1925` → `:1925`; croat `:1947-1957` → `:1957` (cUpgType `:1954-1956`, posx `:1943-1945`), prot `:1959-1965` → `:1966`; `:1972` pack source [U R-1972]; arrow/bow blocks `:1994-2036`; sword tiers `:2125-2160` (aus `:2125-2135`, tur `:2137-2148`, alg `:2149-2160`); shooter add-ons `:2164-2210` (tur jannisary `:2164-2173`, ukr serdiuk `:2174-2179`).

---

## 6. Port change list (`data.gd` — owner/COORD applies; this worker wrote no code)

All items add donor-verbatim law or explicitly tagged placeholders. None invents a number. None touches save version, existing keys, or network.

1. **`data.gd:2527-2576` `UPGRADES_BASE` — extend with pack-matrix rows, keep tagged until captured.** Concrete donor anchors NOW citable (cite first, adopt after §5): `cen_18c` (`:2538-2539`, port `800f/600g`) ← `:3438` (300f, 30000f/5000g/2000i/2000c — PORT APPROXIMATION); `mil_food1` (`:2544`, `750f/250g`, time 10.0) ← `:3454` (750f/250g MATCH on cost, time APPROXIMATION: donor 15.625); `mil_food2` (`:2548-2549`) ← `:3466` (25600f/3350g/2000i row + `req0` access — port lacks req); `aca_build1` (`:2568-2569`) ← `:3530` (−7500000 buildtimeperc, 6950g — port `build_mult 0.25` shape APPROXIMATION). NEW keys from §§2-4 (e.g. `bla_sword_*` tiers from A3/U1/`:2126-2128`, `art_*` cannon/howitzer split with tur/alg gold variants, `sta_reiter_*` with 23.4375/7.8125 overwrite times) gain `donor_sid / donor_time_frames / donor_price_fws gic / donor_lines` comments. Numeric `time`/`cost` stay PORT APPROXIMATION until §5 passes. Never assert the `8.0/10.0/…` set as donor.
2. **`game.gd` tick research arm — rewire to the divisor law** (Q2 §1.4, re-pinned this ticket via `:88`): `progress += deltatime / donor_time_seconds`, completion at `progress>=1` no clamp. Per-row seconds come from §§2-4 above (500f default; 46.875/23.4375/7.8125 overwrites; 1000f howitzer tails; 320f artillery heads).
3. **`game.gd` `research()` gate — add pack-law cites.** Enabled-flags: only `.x.1` tiers start enabled (`(j=0) and bEnabled`, `:920`; bEnabled False for aus = never — spa pikeman `:951`, dragoon pre-`:1656` states). Link-enable chain (incl. severed tails `:1658-1667`, `:3799-3807`) replaces port policy until wired — tag PORT APPROXIMATION.
4. **tur/alg gold variants are separate PORT rows or a nation-modifier table**, citing `:3784-3794`/`:3835-3845` per row. Do NOT fold them into base costs.
5. **Telemetry/format.** Every added line carries `file:line` + `[O]/[U]` tag; `visual_parity_claim=false`; unresolved after this ticket = [R-MATRIX-aus values, R-MATRIX-other cells, R-TIME-values, R-COST-values, R-1972-source, R-ADDON-aus, Q2-DONE-effects, Q2-LOSS-routing, Q2-CAD-rate + prior tails per ROWS §7].

---

## 7. Explicit non-claims and file discipline

- NO PARITY CLAIM. The 157-row _aus transcription is donor TEXT `[O]` with `file:line`; PORT adoption of every value stays [U] until §5 captures pass.
- No number invented: every value/cost/seconds figure above is a verbatim donor literal at its cited line or an arithmetic `[D]` conversion (`×0.03125`). The B5 `.1.6` value `1500` is a damage value literal (`:1352`), NOT a time.
- Per-slot `b0..b5` params transcribed but assigned no semantics (dropped by the generator `[D]`).
- `ukr`/`tur`/`alg`/`sco` empty-member blocks (`_ukr : ;` etc.) emit NOTHING for those nations — absence of rows, not zero-cost rows `[O]` (`:958,:982,:1005-1007,:1036-1037` and member-empties `:1103,:1140,:1207-1210,:1274-1281,:1337-1339,:1442`).
- Read-only compliance: exactly one repo file written (this report). Donor binary never executed/copied/opened-as-target; pin re-asserted by size. No source/asset/config/test/runner/Godot/git state changed. Net branches excluded.

*End of DEC-U-UPGRADE-MATRIX.*
