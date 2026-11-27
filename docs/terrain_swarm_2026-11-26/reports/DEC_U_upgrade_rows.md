---
id: DEC-U-UPGRADE-ROWS
worker: DEC-U-UPGRADE-ROWS (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b0…4e16c"
donor: "READ ONLY. Donor binary never executed/copied/opened as target. Donor text scripts/data read as text only. No repo code/asset/config/Godot/git edit: this report is the only file written."
network: "Net branches cited only as exclusion boundaries. No net behavior specified."
parity: "NO PARITY CLAIM. All [O] items are donor TEXT with file:line. Every per-row seconds/cost value the port needs but that is not a verbatim donor literal below stays [U] with an exact capture. No number invented."
context: "Closes the [U] register left by DEC_U_upgrade_q2.md (per-upgrade time frames/seconds + six-price rows). Q2 grounded the laws (divisor, FramesToTime setters, six-price charge, 12-slot queue, 20-itype completion); this ticket inventories the ROWS those laws act on."
labels: "[O] verbatim donor literal (file:line) · [D] deterministic reading · [I] inference, flagged · [U] UNVERIFIED with exact experiment · PORT APPROXIMATION = port substitute to remove for 1:1"
---

# DEC-U-UPGRADE-ROWS — per-upgrade time + six-resource cost row inventory (2026-11-26)

## 0. Pin + pass ledger (every pass pinned `t_87f0f3c130b0`; donor read-only, never executed)

| # | Pass | Result / evidence |
|---|---|---|
| P0 | Pin re-assert | `cossacks.exe` Length = **5,768,048 B** this ticket (matches Q2 pin + sha `87f0f3c130b0…4e16c`). Binary never executed/copied/opened-as-target. All evidence below is donor script TEXT with `file:line`. |
| P1 | Setter + struct law | EV-R-SET: `_country_SetUpgrade` (`country.script:619-650`) — `price[food..coal]` field copy `:626-631`, `time := _misc_FramesToTime(time)` `:632`, `bindividual := False` default `:636`. Struct `TCountryUpgrade` (`dmscript.global:1828-1853`): `price = Integer[gc_ResCount]` `:1837` (`gc_ResCount = 7` `:3`), `time = Float` `:1838`. `_misc_FramesToTime(v) = v*gc_frames_to_time` (`misc.script:470-474`), `gc_frames_to_time = 0.03125` (`dmscript.global:174`). |
| P2 | Time-literal census | EV-R-TIME: every `time` call-site literal + all 6 direct `time :=` overwrites enumerated §1 (grep `upgrade[ind(-i)?].time` + `cTrue, N,` census; only writers repo-wide). |
| P3 | Explicit-row transcription | EV-R-ROWS: all ~70 non-generated `AddUpgrade`/`AddUpgradeWithAccessControl` rows transcribed verbatim §2 (academy/mill/naval/artillery/mine/tower/wall/ferry/mill-heal blocks, `country.script:3431-3996`). |
| P4 | Generator law | EV-R-GEN: `TUpgStruct` + `SetUpgStruct{FoodGold,FoodGoldIron,FoodGoldIronCoal}` + `AddUpgradePack` (`country.script:821-925`) — rule by which ~113 per-nation call sites (`:936-2210`) expand to rows, all at `time=500` (`:920`) except the §1 overwrites. |
| P5 | Per-nation init path | EV-R-INIT: `_country_Init` per-cid (`:2571-2606`) → members → `_country_InitUnitsUpgrades(country, ind, linkind)` at `:3975` → `_country_InitAll` loops all cids (`:4064-4077`); `_player_Init` copies `sid`+`enabled` into `upgstate` (`player.script:80-86`). |
| P6 | Duration modifiers | EV-R-MOD: game-speed path (`control.script:551-570`, `dmscript.global:1025-1030`) + difficulty enum (`:781-786`) + negative searches (no difficulty term on upgrade path; only AI gate surcharge `unit.script:5774-5778`; `res.script` 0 hits; `_misc_CleanRecordManagerExt` timedone shift `miscext2.script:2719-2740` classified as record-rewind fixup, not a duration law). |
| P7 | Cross-file writer census | EV-R-ONLY: repo-wide grep `upgrade[…].(time\|price\|value\|enabled\|level\|itype\|bindividual) :=` hits ONLY `country.script` (setter `:602-636`, 6 time overwrites `:1173-1564`, ~20 `bindividual := True` `:3872-3970`) — no other script file writes row data. `ModifyUpgrade` (`:599-615`) overwrites value/price fields only when arg `<> -1` (`default` = keep). |
| P8 | Port surface (read-only) | EV-R-PORT: `variant3d/scripts/data.gd:2517-2698` `UPGRADES_BASE` (~70 rows, all `time`/`cost` estimated), `game.gd:4676-4711` `research()`, `:4713-4808` `apply_upgrade`, `:4810-4816` `apply_upgrade_to_building`, `:7589-7601` tick countdown, `:7793-7798` capture flush. |

Time conversion law `[D]`: `seconds = frames × 0.03125`. Attested mappings: `500→15.625`, `300→9.375`, `1000→31.25`, `320→10.0`, `1→0.03125`, overwrites `46.875=1500f`, `23.4375=750f`, `7.8125=250f`.

---

## 1. Complete `time` inventory — every literal that reaches `upgrade[].time` [O]

### 1.1 Call-site `time` params (Integer frames → `FramesToTime` at `country.script:632`)

| Frames | Seconds [D] | Where used (call sites) |
|---|---|---|
| `500` | 15.625 | DEFAULT. All `AddUpgradePack` rows (`:920` hardcodes `500`); all academy/mill/naval/art-fire/art-hp/art-acc/art-ship rows in §2 table unless noted; ferry `.1` (`:3936`); 18c-shooter `.2.4–.2.6` cannon rows (`:3789-3793`) |
| `300` | 9.375 | `century18` enable row (`:3438`); mine chains `.1–.6` (`:3871-3881`) |
| `1000` | 31.25 | academy `.26` heal (`:3627`); tower `tow` `.1–.5` (`:3903-3911`); howitzer build `.2.4–.2.6` (`:3840-3844`); 18c `sta` shooter rows are `500` (contrast) |
| `320` | 10.0 | artillery cost `.1.1–.1.3` + build `.2.1–.2.3` rows, cannon AND howitzer (`:3758-3766`, `:3783-3787`, `:3809-3817`, `:3834-3838`) |
| `1500` | 46.875 | mill `.1` heal (`:3993`) — the ONLY `1500`-frame param |
| `1` | 0.03125 | wall `single_buildgate` rows (`:3943`, `:3951`, `:3960`, `:3969`) — research completes on the next Nothing tick |
| `0` | 0.0 | `'null'` placeholder row (`:3431`) — never researchable (`upgplace` never lists it; `ind` consumed only) |

### 1.2 Direct-seconds overwrites (verbatim seconds, applied AFTER the pack/call) [O]

| Line | Statement | Hits which row(s) | Effective seconds |
|---|---|---|---|
| `:1173` | `country.upgrade[ind-1].time := 46.875;` | LAST row of the 17c-officer damage pack (`:1172`) | 46.875 (was 15.625) |
| `:1198` | `country.upgrade[ind-1].time := 46.875;` | LAST row of the 17c-officer protection pack (`:1197`) | 46.875 |
| `:1471` | `country.upgrade[ind-1].time := 46.875;` | LAST row of the 18c-officer damage pack (`:1470`) | 46.875 |
| `:1495` | `country.upgrade[ind-1].time := 46.875;` | LAST row of the 18c-officer protection pack (`:1494`) | 46.875 |
| `:1538-1539` | `for i:=1 to 6 do country.upgrade[ind-i].time := 23.4375;` | up to 6 most recent rows = whole 17c-stable damage pack (`:1536`) | 23.4375 |
| `:1562-1564` | `for i:=1 to 6 do country.upgrade[ind-i].time := 7.8125;` | up to 6 most recent rows = whole 17c-stable protection pack (`:1562`) | 7.8125 |

Mechanics note `[D]`: `ind` is the append cursor (`:668` `ind := ind+1` per row), so `ind-1` = the single most recently added row and `ind-1..ind-6` = the just-emitted pack. Pack rows emitted with `value[j]=0` are SKIPPED (`:877`), so a short pack retimes fewer than 6 rows — the `for i:=1 to 6` loop then bleeds onto the PREVIOUS pack's tail rows. Port must reproduce order-of-emission, not just per-row values.

---

## 2. Explicit (non-generated) rows — verbatim transcription [O]

Arg order (from `:619`, `:654`, `:694`): `(upgid, level, tooltiptype, itype, value, enabled, time, x, y, ind, food, wood, stone, gold, iron, coal, …)`. `cTrue=True` (`:782`), `bAddIfNotExist=True` (`:781`). Costs are `(food, wood, stone, gold, iron, coal)`.

### 2.1 Mill / academy / naval economy block (`upgplace := csid+'mil'` `:3427` … `:3996`)

| Line | SID suffix | itype → value | time | cost (f,w,s,g,i,c) | Access req |
|---|---|---|---|---|---|
| `3431` | `'null'` | none, 0, disabled | 0 | all 0 | — |
| `3438` | `century18` (`csid+'cen'+'.1'`) | enableunit 0 | 300 → **9.375 s** | 30000,0,0,5000,2000,2000 | aca+tem+art bldgs |
| `3454` | `.1` | effectfood 140 | 500 | 750,0,0,250,0,0 | — |
| `3466` | `.2` (lvl 2, disabled) | effectfood 180 | 500 | 25600,0,0,3350,2000,0 | req0 |
| `3474` | `.1` | effectfood 40 | 500 | 0,200,0,325,0,0 | — |
| `3478` | `.2` | effectfood 50 | 500 | 0,2400,0,625,0,0 | — |
| `3484` | `.3` | effectfood 50 | 500 | 0,3600,0,850,0,0 | — |
| `3490` | `.4` | fieldlifeperc 200 | 500 | 0,1000,0,475,0,0 | — |
| `3495` | `.5` | fishingperc 100 | 500 | 0,12400,0,2520,0,0 | port bldg |
| `3503` | `.6` | enableunit 0 (frigate) | 500 | 0,12400,0,7040,0,0 | port bldg |
| `3512` | `.7` | priceperc 0 (fishboat, `sarr2[0]='fishboat'` `:3513`) | 500 | 0,7300,0,1220,0,0 | port bldg |
| `3517` | `.8` | effectwoodperc 100 | 500 | 5500,0,0,550,0,0 | blacksmith |
| `3518` | `.9` | shield 85 | 500 | 0,9400,7850,1150,0,0 | — |
| `3530` | `.10` | buildtimeperc −7500000 | 500 | 0,0,0,6950,0,0 | — |
| `3538` | `.11` | shield 80 | 500 | 0,0,16200,1500,0,0 | — |
| `3555` | `.12` | damageperc 10 (bullet) | 500 | 0,0,0,0,5000,0 | blacksmith |
| `3557` | `.13` | damageperc 10 (bullet) | 500 | 0,0,0,4000,0,0 | blacksmith |
| `3559` | `.14` | damageperc 15 (bullet) | 500 | 0,0,0,7000,0,0 | blacksmith |
| `3561` | `.15` | damageperc 25 (bullet) | 500 | 0,0,0,0,0,11000 | blacksmith |
| `3564` | `.16` | attrangeperc 5 | 500 | 0,0,0,2000,12150,0 | artillery bldg |
| `3575` | `.17` | attrangeperc 10 | 500 | 0,0,3000,4550,19200,0 | artillery bldg |
| `3586` | `.18` | lifeperc 50 (cannon hp 25000→5000 comment) | 500 | 0,0,0,500,3830,1500 | artillery bldg |
| `3594` | `.19` | enableunit 0 (multicannon) | 500 | 0,0,0,1500,0,2500 | artillery bldg |
| `3597` | `.20` | attdispertionperc −35 | 500 | 0,3540,0,2000,0,7250 | artillery bldg |
| `3607` | `.21` | healing 25 | 500 | 0,350,0,100,0,250 | artillery bldg |
| `3613` | `.22` | geology 0 | 500 | 0,0,0,250,0,0 | — |
| `3614` | `.23` | effectstoneperc 100 | 500 | 0,0,0,1550,3000,0 | — |
| `3615` | `.24` | effectstoneperc 200 | 500 | 4200,0,0,1550,0,12520 | — |
| `3621` | `.25` | balloon 0 | 500 | 0,0,0,5750,0,0 | req0 |
| `3627` | `.26` | healing 50 | **1000 → 31.25 s** | 0,0,0,200,0,200 | — |
| `3629` | `.27` | attdispertionperc −35 | 500 | 0,9540,0,12000,0,65200 | artillery bldg |
| `3639` | `.28` | speedperc 40 | 500 | 0,65400,0,24050,0,0 | port bldg |
| `3650` | `.29` | enableunit 0 (battleship) | 500 | 0,32300,0,6800,9000,12800 | port bldg |
| `3655` | `.30` | buildtimeperc −5000000 | 500 | 0,2300,42700,1150,0,0 | port bldg |
| `3664` | `.31` | attpauseperc −30 (bullet) | 500 | 0,0,6000,5500,4200,0 | — |
| `3669` | `.32` | priceperc 0 (value `cValueForTooltip`=35 tooltip-only) | 500 | 0,0,0,6050,0,7750 | century18 |
| `3697` | `.33` | attpauseperc −30 (bullet) | 500 | 0,5000,0,5500,0,15200 | — |
| `3702` | `.34` | shield 2 | 500 | 0,0,0,9750,0,0 | blacksmith |
| `3707` | `.35` | damage 5 (pike) | 500 | 0,0,0,11500,0,0 | century18+blacksmith |
| `3709` | `.36` | damageperc 25 (pike) | 500 | 0,0,0,19500,0,0 | century18+blacksmith |
| `3714` | `bla.1` | fieldlifeperc 100 | 500 | 0,400,0,90,0,0 | — |
| `3715` | `bla.2` | shield 50 | 500 | 0,0,12320,350,900,0 | — |
| `3717` | `bla.3` | buildtimeperc −3333333 | 500 | 0,0,0,3650,5300,8200 | — |
| `3729` | `bla.5` | damage 5 (pike+sword) | 500 | 0,0,0,4000,7900,0 | — |
| `3738` | `bla.6` (+armored-member sarr2 `:3739`) | shield 2 | 500 | 0,0,0,4950,10500,0 | — |
| `3982` | `bla`-upgplace `.34` (2nd blacksmith block) | shield 2 | 500 | 0,0,0,6950,0,0 | blacksmith |
| `3986` | (+`ModifyUpgrade` `_eng` `:3996` → stone 12000, gold 500) | shield 2 | 500 | 0,0,0,4950,10200,0 | — |
| `3993` | `.1` (2nd mill block) | healing 50 | **1500 → 46.875 s** | 0,20000,0,1500,0,0 | artillery bldg |

Per-nation `ModifyUpgrade` deltas on the SAME rows (value/price only, `default` = keep `[O]` `:601-614`): `:3440-3450` (null-row price per nation — dead row, no effect); `:3456-3457,3468` (.1/.2 mill); `:3476,3480-3482,3486-3488,3492-3493`; `:3497-3498,3507-3509,3515` (port chain); `:3526-3528,3533-3534,3547-3550`; `:3572-3573,3583-3584`; `:3604-3605,3623-3624,3636-3645,3652,3659-3660`; `:3720-3722,3733-3734` (bla.3/bla.5); `:3784-3794,3835-3845` (tur/alg artillery gold tweaks); `:3884` (mine `.6` food 7080/gold 25410 for one nation — see §3). Full per-nation price matrix = cross of base row × these deltas; transcending any single table — see [U]-R-matrix capture.

Link chains `[O]`: mill `.1→.2` (`:3453`); self-links `.21→.21`, `.26→.26` (`:3472-3473` — single-row loops, enable-then-done with no successor); artillery cost/build link-ranges with last-3 tails severed (`:3747-3755`, `:3799-3807` — levels 4,5,6 have NO auto-enable successor: `upgradelinks[…][1] := ''`).

### 2.2 Artillery depot rows (cannon + howitzer, `upgplace := csid+'art'` `:3742`) [O]

Cost/build chains, `member='cannon'` (`:3743`) then `member='howitzer'` (`:3796`). `cValueForTooltip = 35` (`:3757`) is the priceperc `value` (tooltip percent); the REAL −25% wood/gold/iron effect is written into `sarrparam2` tail slots per row (`:3759-3761` × 12 rows cannon, `:3810-3832` × 6 shown + identical howitzer block).

| Lines | SID | lvl | itype → value | time | cost (f,w,s,g,i,c) |
|---|---|---|---|---|---|
| `3758` / `3809` | `art.<m>.1.1` | 2 | priceperc 35 | 320 → **10.0 s** | 0,1000,500,300,0,0 |
| `3762` / `3813` | `.1.2` | 3 | priceperc 35 (disabled) | 320 | 0,3000,1000,500,0,0 |
| `3766` / `3817` | `.1.3` | 4 | priceperc 35 (disabled) | 320 | 0,6000,2000,1000,0,0 |
| `3770` / `3821` | `.1.4` | 5 | priceperc 35 (disabled) | 500 → 15.625 | 1760,0,0,350,0,0 |
| `3774` / `3825` | `.1.5` | 6 | priceperc 35 (disabled) | 500 | 1760,0,0,350,0,0 |
| `3778` / `3829` | `.1.6` | 7 | priceperc 35 (disabled) | 500 | 1760,0,0,350,0,0 |
| `3783` / `3834` | `art.<m>.2.1` | 2 | buildtimeperc −2500000 | 320 | 0,0,0,500,1000,0 (+tur/alg gold→950 `:3784` / →350 `:3835`) |
| `3785` / `3836` | `.2.2` | 3 | buildtimeperc −2500000 (disabled) | 320 | 0,0,0,1000,2000,0 (+tur/alg →150 `:3786` / →450 `:3837`) |
| `3787` / `3838` | `.2.3` | 4 | buildtimeperc −2500000 (disabled) | 320 | 0,0,0,2000,3000,0 (+tur/alg →250 `:3788` / →550 `:3839`) |
| `3789` | cannon `.2.4` | 5 | buildtimeperc −2000000 (disabled) | **500** | 2560,0,0,0,0,0 (+tur/alg →1350 `:3790`) |
| `3791` | cannon `.2.5` | 6 | buildtimeperc −2000000 (disabled) | **500** | 3560,0,0,0,0,0 (+tur/alg →2500 `:3792`) |
| `3793` | cannon `.2.6` | 7 | buildtimeperc −2000000 (disabled) | **500** | 5560,0,0,0,0,0 (+tur/alg →3350 `:3794`) |
| `3840` | howitzer `.2.4` | 5 | buildtimeperc −2000000 (disabled) | **1000 → 31.25 s** | 2560,0,0,0,0,0 (+tur/alg →1150 `:3841`) |
| `3842` | howitzer `.2.5` | 6 | buildtimeperc −2000000 (disabled) | **1000** | 3560,0,0,0,0,0 (+tur/alg →3200 `:3843`) |
| `3844` | howitzer `.2.6` | 7 | buildtimeperc −2000000 (disabled) | **1000** | 5560,0,0,0,0,0 (+tur/alg →4500 `:3845`) |

### 2.3 Mine / tower / ferry / wall rows (`bindividual=True`, per-building concurrency) [O]

Mine loop `for i:=1 to 3` (`gol/iro/coa`, `upgplace := 'eur'+member` `:3849-3857` — SAME SIDs all nations): `.1→.2→.3` links (`:3858-3859`), full `.1–.6` chain only if `bhave18century` (`:3860-3865`, i.e. NOT ukr/tur/alg/sco per `:929`), else `.3` dead-ends at `century18` (`:3861`).

| Lines | SID | lvl / en | itype → value | time | cost (f,w,s,g,i,c) | bindividual |
|---|---|---|---|---|---|---|
| `3871` | `eur<gol/iro/coa>.1` | 2, cTrue | single_inside_mine +5 | 300 → **9.375 s** | 1000,0,0,1250,0,0 | `:3872` |
| `3873` | `.2` | 3, False | +8 | 300 | 5250,0,0,4950,0,0 | `:3874` |
| `3875` | `.3` | 4, False | +10 | 300 | 12500,0,0,9250,0,0 | `:3876` |
| `3877` | `.4` | 5, False | +12 | 300 | 15800,0,0,18500,0,0 | `:3878` + req0 `:3863-64 arm` |
| `3879` | `.5` | 6, False | +15 | 300 | 19800,0,0,21050,0,0 | `:3880` |
| `3881` | `.6` | 7, False | +40 | 300 | 50200,0,0,25950,0,0 | `:3882` (+`:3884` nation food/gold delta) |

Tower (`upgplace` = tower place, `member` loop implied; `commonName+'tow'` sarr2 `:3903-3911`): `.1` −20 (gold 250, **t=1000**); `.2` −20 (iron 350); `.3` −10 (coal 400); `.4` −10 (iron 450); `.5` −10 (coal 500); (commented `.6` `:3913` never added; private `.6` registration also commented `:3927` — chain ends at `.5` `[O]`). Ferry `single_inside` +200 (`:3936`, t=500, 1000f/1250g, req century18, `:3937` private). Wall gates `single_buildgate` 5 (`:3943` wood 400 / `:3951` stone 500 / `:3960` stone 500 / `:3969` stone 500 — four nation-group variants, each **t=1 → 0.03125 s**, `:3944`+ private).

---

## 3. Generated (pack) rows — the rule, block map, and worked expansion [O-law / U-matrix]

EV-R-GEN law (`country.script:872-925`): for each `SetUpgStruct*` call site, `AddUpgradePack` emits one row per nonzero `value[j]` (`j=0..5`, `:877`), with SID `place.member.{1|2}.(j+1)`, `level=j+2`, `enabled=(j=0) and bEnabled`, **`time=500` frames verbatim (`:920`)**, cost `(food[j],wood[j],stone[j],gold[j],iron[j],coal[j])` (ResetUpgStruct zeroes all `:832-848`; FoodGold leaves wood/stone/iron/coal = 0; FoodGoldIron leaves stone/coal = 0), `iarrparam1` = weapon-kind triple per `upgradetype` (`:882-916`), `sarrparam2[0]=member`, access req `blacksmith`/`academy` + `req[0..1]` (`:920`), chain link to next nonzero row (`:921-922`).

Block map (all inside `_country_InitUnitsUpgrades`, `cid` case-split per nation `[O]`):

| Lines | Block | Pack calls | Time law |
|---|---|---|---|
| `934-1200` | barracks 17c (pikeman/roundshier/officer/barabanshik) | `AddUpgradePack` `:1172` (dmg), `:1197` (prot) + officer `:1150-1170→1172`, `:1175-1195→1197` | 500 except LAST row of each pack **46.875** (`:1173`, `:1198`) |
| `1201-1497` | barracks 18c (pikeman18/officer18; skipped if ukr/tur/alg/sco) | `:1470` (dmg), `:1494` (prot) | 500 except LAST row each **46.875** (`:1471`, `:1495`) |
| `1499-1565` | stables 17c heavy cav (reiter/vityaz/reiterswe) | `:1536` (dmg), `:1562` (prot) | last ≤6 rows **23.4375** (`:1539`) / **7.8125** (`:1564`) |
| `1567-2050` | stables light cav + dragoon/shooter academy packs (`member` per nation; `SetUpgStruct*` has per-nation food/gold/iron/coal tuples) | pack-per-member, e.g. `:2057-2210` nation-specific 18c shooter add-ons (see below) | 500, NO overwrite |
| `2057-2210` | nation-specific 18c shooter/musketeer add-ons (`*.1.6`/`*.2.6` level-7 rows, all `enabled=False`, req blacksmith) | e.g. `:2057` dmg +2 (15000f/1875g, pike); `:2059` prot +2 (11250f/1500g); … `:2168-2170` bullet dmg +1/+2/+3 (5000f/1600g, 7500f/3200g, 10000f/4800g) | 500, NO overwrite |
| `2126-2160` | 17c sword-damage + protection tier-4/5/6 rows (per-nation) | `:2126-2128` dmg (7500f/900g … 18750f/2250g); `:2131-2133` prot (3750f/450g … 9375f/1125g); + `:2138-2157` nation-variant tiers | 500, NO overwrite |

Worked expansion `[D]` (mechanical, no invention) — `_aus` pikeman damage, `:953`:
`SetUpgStructFoodGold(…, value0..5 = 1,2,2,1,2,0; food = 200,1300,3600,7200,16030,0; gold = 50,300,450,1850,2000,0; …)` → `AddUpgradePack(…, ctypeDamagePike, …)` emits 5 rows (j=0..4; j=5 skipped, value 0): `…bar.<member>.1.1 … .1.5`, levels 2..6, `enabled` = True only for `.1.1`, each `time=500` (15.625 s), costs `(200,0,0,50,0,0)`, `(1300,0,0,300,0,0)`, `(3600,0,0,450,0,0)`, `(7200,0,0,1850,0,0)`, `(16030,0,0,2000,0,0)`, itype damage, iparam1=pike, sarr2[0]=member, req blacksmith. Same reading applies to every site in §3-block map; the FULL per-nation × per-member matrix (hundreds of rows) is therefore [U]-R-matrix — recoverable row-by-row by the capture in §5, never by hand-transcription here.

`_country_ModifyUpgrade` (`:599-615`) post-deltas on pack rows: value/price field written only if arg `<> -1` (`default` = sentinel keep `[O]`; `default` is the language default-value marker — do NOT treat as 0). Applies to `.1`-row nation tweaks (`:3440-3450` etc.) — each cited inline in §2.

---

## 4. How `upgrade[]` is initialized per nation [O]

1. `_country_InitAll()` (`country.script:4064-4077`): `for i:=0 to gc_MaxCountryCount-1` — clears `gCountry[i]` if occupied (`:4071-4072`), resolves `sid` (`:4073`), calls `_country_Init(gCountry[i], sid)` (`:4074-4075`). Runs once at startup/load for EVERY cid.
2. `_country_Init` (`:2571-…`): `cid := _country_GetIDBySID(csid)` (`:2577`); nation flags via `_country_IDToBoolean` (`:2581-2606`, 24 nations aus…lit); member table per nation (`:2608-2570` region, e.g. peasants `:2655-2662`); economy/upgrade blocks per `upgplace` (`mil` `:3427`, `bla`…, `art` `:3742`, mines/towers `:3847-3972`); then `_country_InitUnitsUpgrades(country, ind, linkind)` at **`:3975`** (barracks/stable pack generation `:779-2210`); `ind`/`linkind` are append cursors shared across the whole init — row ORDER in `upgrade[]` = emission order.
3. `_country_InitUnitsUpgrades` (`:779-925` setup): `bAddIfNotExist=True` (`:781`); per-nation booleans (`:793-819`); `TUpgStruct` + 3 setters + `ResetUpgStruct` + `AddUpgradePack` defined LOCALLY (`:821-925`) — the generator exists only during init; `bhave18century := (not ukr) and (not tur) and (not alg)` (`:929`); `blacksmith/academy/century18/commonName/commonNamePort` strings (`:930-935`, `:2641-2652`).
4. Row identity: `_country_GetUpgradeIndexByUpgradeID(cid, upgid, bAddIfExist)` (`:376-395`) — empty `id=''` slots reused; `AddUpgrade` (`:654-670`) registers each SID into its `upgradeplace` (`:666-667`) and `ind+1`. Same SID string may exist in MANY cids (per-cid arrays `gCountry[cid].upgrade[j]`) with per-cid value/price deltas — nation differences are DATA, not code branches at research time.
5. Player side: `_player_Init` (`player.script:58-86`) — for all `(i,j)`: `ClearUpgradeState` (`:83`) then `upgstate[i][j].sid := gCountry[i].upgrade[j].id` + `enabled := …enabled` (`:84-85`). `inprogress/done/timestart/timedone` start cleared. Access-control/enable gating at research time via `_player_CheckAccess`-family (`player.script:355,411-429`) + `upgradelinks` (`player.script:1986-2000`, Q2 §4.3).
6. Save/load boundary: `serial.script:449` re-clears upgrade state on the load path; scenario triggers can flip `bscenariodisabled` (`scenario.script:2534-2541`); `_player_FixPlayersUpgStateBadIndexes` (`player.script:2790-2849`) re-maps `upgstate` by SID after nation table changes.

---

## 5. How duration is modified by game speed / difficulty [O + O-absence]

### 5.1 Game speed — NO script multiplier on the upgrade path; game-time law is invariant

- Speed control: `_control_SetGameSpeedByMode` (`control.script:551-570`): `mode → speedfactor ∈ {7, 10, 14}` (`dmscript.global:1027-1029`, count `:1025`, default `:1026`); **`//SetTimeSpeedFactor(speedfactor);` is COMMENTED OUT (`:563`)** — the factor is only forwarded as `FloatRegister0` to `GUIExecuteState('WriteTimeSpeed')` (`:566-568`). No script scales `GetGameTime`, `deltatime`, or `upgrade[].time`.
- Duration input is game-time (`miscext.script:83-88`, re-pinned this ticket via grep EV-R): `deltatime := GetGameTime-lastprogresstime` (`:83-85` per Q2 §1.4) and `delta := deltatime/gCountry[cid].upgrade[upgind].time` (`:88`). Ticks-to-complete = `ceil(time / per-Nothing-tick game-time delta)` at the building's own cadence (`building.inc/nothing.inc:128-136`, Q2 §5.2). Game speed changes WALL-clock rate via the engine clock only — research duration in game-time seconds is identical at every speed setting `[D]`.
- The ONLY time-adjacent adjustment found: `_misc_CleanRecordManagerExt` (`miscext2.script:2719-2740`) shifts `upgstate[j][k].timedone` (plus `aidata.inittime`, `lastprogresstime`) by `oldgametime-newgametime` on record-manager cleanup — a replay/rewind fixup, NOT a duration modifier `[D]`.

### 5.2 Difficulty — NO effect on duration or price; only an AI order-gate surcharge

- Enum `[O]` (`dmscript.global:781-786`): `none=-1, easy=0, normal=1, hard=2, veryhard=3, impossible=4` (AI use `>1`/`>0` gates e.g. `unit.script:7367`; map-gen assignment `common.inc/initmapgen.inc:100-140`).
- Negative searches `[O-absence]` (this ticket): `difficulty` × `upgrade`/`price`/`cost`/`res` = 0 hits in `lib/` outside AI combat gating; `difficulty` = 0 hits in `res.script`; `ai.script` upgrade refs touch only `upgstate.done` (`ai.script:2089,2099`) and `aidata.upgradeid` fill (`:339-343`) — no time/price term.
- SOLE difficulty-adjacent cost term `[O]`: AI surcharge inside `_unit_CanApplyUpgradeCostBySID` (`unit.script:5774-5778`, Q2 §2.2): `if (gPlayer[plInd].bai) then { food+500; gold+25 }` — order-gate only, never per-tick, never a duration scale. (Unit-train twin at `unit.script:5704-5710`: food+300/gold+25 — different numbers, do not conflate.)

---

## 6. Still-[U] register — one fixed-seed capture per item, zero-mismatch criterion, nothing invented

Seed convention S (owner-executed; worker never runs the binary): fixed map + fixed nation pair + fixed `DONOR_GAME_SPEED` mode + full stock; instrumented owner build logs `orders[0].info.{upgradeid,progress}`, `gCountry[cid].upgrade[upgind].{time,price[0..6]}` at queue time, and `res[0..6]` + `stat.resonupgrade/resonmines` before-order / after-order / after-cancel / after-complete. Wall-clock is IRRELEVANT — all criteria compare game-time/tick counts.

| # | Item | Static state after this ticket | Exact experiment (owner-authorised) |
|---|---|---|---|
| R-TIME | Seconds for EVERY row in §§2–3 as the port must store it | LAW + all frames params + all 6 overwrites grounded `[O]` (§1). Per-row seconds [U] until the row's own capture passes (transcription above is donor text, but the PORT value is adopted only after capture). | Per upgrade U on seed S, ONE blacksmith/academy/mine/tower, full stock: log `orders[0].info.progress` each building-Nothing tick to completion. **Zero-mismatch:** 3 identical-seed runs ⇒ identical tick count AND identical `progress` trace; `ticks×dt_tick ≈ <row seconds from §§1–3>` within one tick. Adopt `time` only then. Priority: `.1`-pack rows (15.625), overwritten tails (46.875/23.4375/7.8125), `t=1` wall gates (1-tick), `t=320` artillery (10.0), `t=300` mines (9.375), `t=1000` tower/heal (31.25), `t=1500` mill (46.875). |
| R-COST | Six-price `(f,w,s,g,i,c)` per row incl. ALL gold costs | All base rows + nation `ModifyUpgrade` deltas transcribed `[O]` (§§2–3). PORT `cost` dicts stay estimates until captured. | Same setup: snapshot `res[food,wood,stone,gold,iron,coal]` + `stat.resonupgrade/resonmines` before order, after order, after cancel, after completion. **Zero-mismatch:** 3 runs identical deltas; `after_order = before − price[row]` exactly; cancel restores exactly; `resonupgrade` (mine rows: `resonmines`) increments by `price[row]`. Gold rows must show the `gold` delta explicitly (e.g. century18 5000g, `.15` 11000 coal-only vs gold-only rows). Repeat per nation for every `ModifyUpgrade` delta row. |
| R-MATRIX | Full per-nation pack matrix (§3 block map) | Generator LAW `[O]` (`:872-925`); one worked expansion `[D]`; hundreds of cells [U]. | For each (nation × member × tier): queue the tier (with prereq chain researched), run R-TIME + R-COST. **Zero-mismatch:** same as R-TIME/R-COST; PLUS chain check — next tier stays `enabled=False` until link predecessor completes (`upgradelinks`, `player.script:1986-2000`); severed tails (artillery `:3748-3755`, `:3800-3807`) never auto-enable. Any deviation ⇒ cite `country.script` line, never smooth over. |
| R-GATE | `inprogress` vs `bindividual` concurrency | LAW `[O]` (`unit.script:6065`, `:10298`; Q2 §3.4). | Seed S: order U on building A; attempt U on B (same cid): reject for shared rows, accept for mine/tower `bindividual` rows; attempt 2nd U′ on researching A: reject. **Zero-mismatch:** 3 runs identical accept/reject matrix. |
| R-ORDER | `bDoFirst` preempt + slot-0-only progress | LAW `[O]` (Q2 §3.3/§5.1). | Seed S: fill building with a train job, order U: assert U lands in `orders[0]`, head shifts down, only slot-0 `progress` advances. **Zero-mismatch:** identical slot dumps × 3 runs. |
| R-SPEED | Speed-invariance of game-time duration | LAW `[D]` (§5.1: game-time divisor, engine-side clock). | Same research at each `DONOR_GAME_SPEED` mode (7/10/14): game-time ticks-to-complete identical; wall-clock scales. **Zero-mismatch:** per-mode 3-run identical tick counts. |

---

## 7. Port change list (`data.gd` / `game.gd` — owner/COORD applies; this worker wrote no code)

All items add donor-verbatim law or explicitly tagged placeholders. None invents a number. None touches save version, existing keys, or network.

1. **`data.gd:2517-2698` `UPGRADES_BASE` — re-source row by row to §§1–3, keep tagged until captured.** Each row gains `donor_sid / donor_time_frames / donor_price_fws gic / donor_lines` comments citing its `country.script` call-site line (+ overwrite line). Concrete donor anchors available NOW (no capture needed for the CITE, capture needed for the ADOPTION): `cen_18c` ← `:3438` (300f, 30000f/5000g/2000i/2000c — port `800f/600g` is APPROXIMATION); `mil_food1`-class ← `:3454` (140-efffood, 750f/250g); `aca_fire1..4` ← `:3555-3561` (iron 5000 / gold 4000/7000 / coal 11000 — port iron/gold splits are APPROXIMATION); `aca_rof1/rof2` ← `:3664` (6000s/5500g/4200i), `:3697` (5000w/5500g/15200c — port `900g/500i`, `1400g/800i` are APPROXIMATION); `aca_shipbuild1` keeps the x10-flag comment (`:2690-2693` already cites `:3655`); mine/tower rows ← §2.3 (all `300f`/`1000f`, food+gold only — port wood/stone costs + `mine_mult`/`tower_rof` effect shapes are APPROXIMATION, donor is `single_inside_mine` slot counts +5/+8/+10/+12/+15/+40 and `single_attpauseperc` −20/−20/−10/−10/−10); wall-gate rows (NEW keys, `t=1`) have no port counterpart — add as `time: 0.03125` after R-TIME. Numeric `time`/`cost` stay `PORT APPROXIMATION` until §6 captures pass. Never assert the `8.0/10.0/…/26.0` set as donor.
2. **`game.gd:7589-7601` tick research arm — rewire to the divisor law.** Replace `r.t -= dt; if r.t<=0` countdown with donor accumulation on the researching slot: `progress += deltatime / donor_time_seconds` where `deltatime` = building-Nothing-tick game-time delta, completion at `progress>=1` with NO clamp (`miscext.script:88,95-97`), then the §4/Q2 dispatch. Keep per-building single-`research` field only as a VIEW over slot 0; tag `PORT APPROXIMATION (donor: orders[0] of 12, bDoFirst preempt, unit.script:4304-4328,6069)`.
3. **`game.gd:4676-4711` `research()` gate — rewire to donor order.** Donor order: unknown-sid reject → `inprogress` reject unless `bindividual` (mine_/tow_rof keys only — current `per_bld` prefix split at `:4701` is CORRECT in shape, cite `country.script:3872-3970`) → slot-0 busy reject → `CanApply` with AI `food+500/gold+25` surcharge (`unit.script:5774-5778`; currently missing — ADD) → insert-at-head + charge-once + `inprogress:=True/timestart:=GetGameTime` (`unit.script:10302-10303`). Current `pay_cost` stays as the charge primitive but must deduct all six donor prices once cited. The `cen_18c` building-set gate (`:4689-4700`) is port policy — tag `PORT APPROXIMATION (donor: upgradelinks + access-control, country.script:715-728, player.script:355-429)` until wired.
4. **`game.gd:4713-4808` + `:4810-4816` completion — rewire to itype rows.** Each `effect` branch gains its donor `itype` cite (`player.script:1707-1982`, Q2 §4 table); `round()`/`floor()` keep donor semantics; `buildtimeperc` keeps the verbatim `/(100*100000)` divisor (`player.script:1845-1849`); `priceperc` applies wood..coal only (food excluded, `:1833-1843`); `single_inside(_mine)` writes go to the RESEARCHING BUILDING; link-enables + `done/timedone/inprogress/timestart` stamps become state (save-visible per `player.script:1701-1705,1996-1998`). No effect number changes without its `country.script` value literal + R-MATRIX capture.
5. **`game.gd:7793-7798` capture path — fix refund half.** Keep `research=null` (matches slot flush) but ADD donor `CancelUpgradePerform` full six-price refund + `inprogress/timestart` clear (`miscext.script:1129-1130`, `unit.script:5837-5889`, Q2 §2.5). Current `:7793-7795` comment ("no refund to old owner") is PORT APPROXIMATION — donor refunds via `CancelUpgradePerform` to `plInd` at call time; tag until wired. Same for `_kill`/death path (`game.gd:5743` + `ondeath.inc:21-23`): cancel + refund + clear.
6. **`data.gd:276-277` queue caps — already correct, extend cite.** `DONOR_MAX_ORDER_COUNT=12` landed; ADD comment that an upgrade occupies ONE slot via `bDoFirst→slot 0` and that produce batches live in `amount` (Q2 §3.3). `BUILD_QUEUE_LIMIT` stays.
7. **Telemetry/format.** Every added line carries `file:line` + `[O]/[U]` tag; `visual_parity_claim=false`; unresolved after this ticket = [R-TIME-values, R-COST-values, R-MATRIX-cells, R-GATE-behaviour, R-ORDER-slots, R-SPEED-modes, Q2-DONE-effects, Q2-LOSS-routing, Q2-CAD-rate, CAM-initial-focus, Q3-build-hit-path, T1, D1, G1-tail, A1-tail, R1, O1-tail per SKIRMISH-TABLES §9 + VICTORY-START §6].

---

## 8. Explicit non-claims and file discipline

- NO PARITY CLAIM. Grounded items rest on donor TEXT `[O]` with `file:line`; per-row port VALUES stay `[U]` until §6 captures pass. Nothing in §§2–3 is quoted as port-adopted.
- No number invented: every seconds/cost figure above is a verbatim donor literal at its cited line, or an arithmetic `[D]` conversion (`×0.03125`) of one. The §3 worked expansion derives from the `:920` rule, flagged `[D]`.
- `bindividual` commented-out `:3914` (`//country.upgrade[ind-1].bindividual := True;`) and commented `SetUpgStruct` lines (`:3480,3486,3492,1055,1080`, tower `.6` `:3913`, private `.6` `:3927`) are reported as NOT emitted — the chain lengths above exclude them.
- Read-only compliance: exactly one repo file written (this report). Donor binary never executed/copied/opened-as-target; pin re-asserted by size only. No source/asset/config/test/runner/Godot/git state changed. Net branches cited as exclusion boundaries only.

*End of DEC-U-UPGRADE-ROWS.*
