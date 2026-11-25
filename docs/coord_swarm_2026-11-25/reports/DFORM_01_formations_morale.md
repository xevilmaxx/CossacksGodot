---
id: DFORM-01
title: "Donor formations / squads / morale / AI-behaviour truth (gameplay parity tranche)"
area: donor / gameplay / formations / morale / squads / AI
owner: DFORM-01 (donor deep-dive micro-worker)
date: 2026-11-25
status: COMPLETE — read-only; no code edits, no runner jobs, no donor copies
method: Python 3.14 bytes/latin-1 reads of C:\Games\Cossacks 3 (READ-ONLY); fresh reads 2026-11-25 + two cross-check passes
compliance: donor never executed/copied; port files read only; this report is the sole artefact
label_key: "observed = literal bytes read this pass | derived = arithmetic/control-flow over observed | inferred = strong but indirect | UNVERIFIED = no plaintext evidence"
---

# DFORM-01 — Donor formations / squads / morale / AI-behaviour truth

## Goal

Close a documented research gap before a future gameplay-parity tranche. `DEC_02_scripts.md`
asserted "no numeric morale exists; disband is `count<0.25×basecount`; shooter retreat is a
move-order mode; port famine HP-drain and morale constants are invented", and `DEC_03_configs.md`
fully parsed `formations.cfg` (149 IDs, 46 non-zero bonuses). Neither document deeply proved the
*consumer* chain, the *full-tree absence* of morale, or the *squad/AI lifecycle rules*. This report
fresh-reads the donor config and its script consumers, proves/refutes the morale claim with a
whole-tree search, documents squad + AI rules with `path:line` pseudocode (marking ACTIVE
`[*] = ;` script bodies vs plain `;` intent), ranks port gaps read-only, and corrects prior docs.

Today's 3D work does not depend on this; it is a truth baseline for a later tranche.

## Sources

**Donor (fresh-read this pass, READ-ONLY, `C:\Games\Cossacks 3`):**
- `data\game\var\formations.cfg` — full 2,307-line file; 20 representative records re-read with line numbers.
- `data\scripts\lib\init.script:7-81` — `_init_InitializeFormations` (loader). Fresh read.
- `data\scripts\lib\player.script:792-850, 910-980, 996-1053` — formation snapshot, CreateSquad, FillSquad. Fresh read.
- `data\scripts\lib\miscext2.script:330-445` — `_misc_DoDamage` hold-bonus branches. Fresh read.
- `data\scripts\dmscript.global:113-212, 400-482, 655-660, 717-719, 781-786, 1955-1968, 2064` — constants + `TFormation`. Fresh read.
- `data\scripts\units\global.inc\progress.inc:1-40, 40-56, 140-180` — disband/hold + AI gate. Fresh read.
- `data\scripts\lib\squad.script:1-29, 96-107, 365-378` — officer/drummer slots, base count, symmetry. Fresh read.
- `data\scripts\lib\unit.script:7173-7240, 7360-7369` — runaway order mode. Fresh read.
- `data\scripts\lib\classes.script:4780-4845` — AI army min/max counts. Fresh read.
- `data\scripts\units\global.inc\progresswarai.inc:1116-1130, 2400-2415, 2795-2840, 4065-4095` — AI battle gate, retreat, fear, executor. Fresh read.
- Full-tree keyword scans: **2,559 files** (all roots) then **373 code files** (`.script/.inc/.global/.source/.aix/.cfg/.res/.txt` under `data\scripts`, `data\game\var`, `data\gui`, `data\resources`).

**Prior docs read (all eight):** `decomp/DEC_02_scripts.md`, `decomp/DEC_03_configs.md`,
`docs/research/RB_MECHANICS.md`,
`docs/coord_swarm_2026-11-24/reports/R03_formations_squads.md`, `.../R06_ai_behavior.md`,
`docs/audit/DONOR_RECRUIT_MODIFIERS.md`, `docs/audit/AI_SURVIVAL_DIAG.md`; plus
`docs/coord_swarm_2026-11-25/decomp/DEC_03_configs.md` §4.9.

**Port (read-only, current working tree 2026-11-25):** `app/scripts/data.gd:73,80-81,96-97,367-378,380-535,540-549`,
`app/scripts/game.gd:1997,3043,3054,3082-3110,3218,3263-3271,4121,4127,4800-4818,4933,5002-5044`,
`app/scripts/ai.gd:436,676,868`, `app/scripts/config.gd:503-510,528-539`, `app/config.json:98-99,104-105,114`.

**Verification discipline:** every key claim below was obtained twice — once by a fresh independent
Python latin-1 read this pass, and once by cross-check against a prior doc (or a second literal read
within the same pass). Temp analysis scripts live in
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\dform01_*.py`, outside the repo.

---

## Formation semantics table

### Config record schema (observed, `formations.cfg:3-12`, `:822-835`)

```
formations : section
  [*] : struct.begin
     id = LINE15                       :822   (string SID; loader stores this in gFormation[i].sid)
     symmetry = 1                      :823
     bonusdamage = 2                   :824
     bonusshield = 2                   :825
     bonusdamagehold = 7               :826
     bonusshieldhold = 7               :827
     mask : struct.begin               :828  (array of row strings; max 24 rows × 54 cols)
        [*] = ...............          :829  (15 cols)
        [*] = ...............          :830
        [*] = ***************          :831
        [*] = ...............          :832
        [*] = ...O.......O...          :833
     struct.end
  struct.end
```

**`mask` field meaning (derived from consumer, not a declared legend):** a *glyph grid*, not a
bitmask. The loader (`lib/init.script:50-75`) scans each row string:
- `*` → `countunits++` and `mask[j][pos-1] := True` (`:58-64`) — a rank-and-file slot.
- `O` → `countofficers++` and `maskofficers[j][pos-1] := True` (`:66-75`) — an officer/drummer slot.
- `.` → skipped (empty cell).
`width` = longest row; `height` = row count (`init.script:77-78`). `TFormation.mask` and
`maskofficers` are `Boolean[24][54]` (`dmscript.global:167-168, 1967-1968`). **Label: observed for
the loader operations; inferred that `O` means specifically "officer/drummer slot"** (no legend
text exists in any `.cfg`; corroborated by `player.script:845-849`, which places `offHnd` into
`maskOfficers` cells). This closes DEC-03 Open Q3 as *strongly derived*, still without a literal legend.

### Exact bonus-tuple semantics (fresh-confirmed consumer chain)

Tuple order is `[bonusdamage, bonusshield, bonusdamagehold, bonusshieldhold]` (`dmscript.global:1959-1962`).

| Field | Applied where | Exact condition | Citation | Label |
|---|---|---|---|---|
| `bonusdamage` | attacker damage **+** bonus | target in squad and squad `fHoldMode=False` (and weapon kind ≠ firearrow) | `lib/miscext2.script:421-431` (`:429-431`) | observed |
| `bonusdamagehold` | attacker damage **+** bonus | same, but `fHoldMode=True` | `miscext2.script:427-428` | observed |
| `bonusshield` | incoming damage **−** bonus | target in squad and `fHoldMode=False` | `miscext2.script:347-354` (`:353-354`) | observed |
| `bonusshieldhold` | incoming damage **−** bonus | target in squad and `fHoldMode=True` | `miscext2.script:350-351` | observed |

Snapshot onto squad on formation set (`lib/player.script:809-812`, fresh-read):
`fAddDamage := bonusdamage; fAddShield := bonusshield; fAddDamageHold := bonusdamagehold;
fAddShieldHold := bonusshieldhold;` — i.e. the tuple is **snapshotted at formation assignment**,
not looked up live at damage time. The four fields are serialised (`lib/serial.script:1044-1047`
write / `1115-1118` read / `1187-1190` size / `1255-1258` seek, per DEC-02 D-16).

### Formation families and their tuples (149 IDs; representative records fresh-read, full set parsed twice)

| Family / IDs | Tuple `(dmg, shield, hold-dmg, hold-shield)` | sym | Mask shape (fresh sample) | path:line | Label |
|---|---|---:|---|---|---|
| `none` | `0,0,0,0` | 0 | single `*` | `:3-11` | observed |
| `LINE3..LINE10` | `0,0,0,0` | 1 | sparse `*..*..*` lattice | `:14-91` | observed |
| `LINE3PUS..LINE100PUS` | `0,0,0,0` | 1 | `*.*.*` lattice, up to 7 rows | `:102-599` | observed |
| `LINEMORB2..20` | `0,0,0,0` | 1 | 3-row orb lattice | `:616-809` | observed |
| **`LINE15, LINE36, LINE72, LINE120, LINE196`** | **`2,2,7,7`** | 1 | solid bars + `O` slots in last row | `:822, :837, :851, :866, :882` | observed |
| **`SQUARE15, KARE15`** | **`2,2,7,7`** | 0 | 4-5 rows; `OO***` / `*O.**` | `:1505, :1519` | observed |
| **`SQUARE36/72/120/196`, `KARE36/72/120/196`** | **`2,2,7,7`** | 1 | filled / hollow with `O` markers | `:897-1048` | observed |
| **`LINE400, SQUARE400, KARE400`** | **`3,3,7,7`** | 1 | 50-wide / 20-wide / hollow 22-wide; `O` in last row | `:1862, :1881, :1913` | observed |
| `TRI, TRI2, TRI3`, `PRUS, PRUS2, PRUS3`, `SHER, SHER2, SHER3` + `0`-suffixed twins | `1,1,1,1` (uniform) | 1 | triangle/wedge/solid | `:1533-1794` | observed |
| `*_OLD` legacy: `SHER_OLD`, `SHER0_OLD` | `2,1,2,1` | 1 | solid rows | `:1296, :1422` | observed |
| `SHER3_OLD`, `SHER03_OLD` | `0,1,1,0` | 1 | 3 solid rows | `:1328, :1454` | observed |
| `SHER2_OLD`, `SHER02_OLD`, `PRUS0_OLD`, `TRI0_OLD` | `1,1,1,1` | 1 | hollow/solid/triangle | `:1313, :1439, :1341, :1364` | observed |
| **`TRI_OLD`** | **`-10,9,95,-19`** | 1 | 15-row triangle | `:1177-1182` | observed |
| **`PRUS_OLD`** | **`5,-5,-27,80`** | 1 | 13-row wedge lattice | `:1240-1245` | observed |
| `ALONE, ODIN, SHIPS*, PACK20`, all `*NB` | `0,0,0,0` | mixed | single/ship/pack; NB = same mask as base | `:1074-1163, :1945-2276` | observed (NB zero) / inferred (NB = "no bonus") |
| `LINE2, LINE2PUS, LINEMORB2/3/4` | `0,0,0,0` | 1 | 2-4 cols | `:1807-1851` | observed |

**Counts (derived, verified twice):** 149 records, 137 `symmetry=1` / 12 `symmetry=0`, **46** with
at least one non-zero bonus. Distribution: 15×`(2,2,7,7)`, 22×`(1,1,1,1)`, 3×`(3,3,7,7)`,
2×`(2,1,2,1)`, 2×`(0,1,1,0)`, plus 2 outliers (`TRI_OLD`, `PRUS_OLD`). Matches DEC-02/DEC-03/R03.

**`symmetry` meaning (derived):** read into `gFormation[i].symmetric` at `init.script:43` and
consumed at `lib/squad.script:373` (`var sym := gFormation[form].symmetry;`) in the grid
rebuild/fill path — it controls symmetric rearrangement of placed units, not a bonus.

**Hold-bonus activation nuance (derived, fresh):** the hold bonus only becomes active after a
37.5 s progressive ramp (`gc_squad_holdmode_time = 150*8*0.03125`, `dmscript.global:180`;
`progress.inc:160-170`) **and only if** the hold tuple differs from the normal tuple and at least
one hold field is >0 (`progress.inc:162`). Consequence: `(1,1,1,1)` formations (TRI/PRUS/SHER
family) can never enter hold mode — their hold equals normal — whereas `(2,2,7,7)` / `(3,3,7,7)`
and the `_OLD` outliers can. Prior docs did not spell out this consequence.

---

## Morale verdict + evidence

### Verdict

**CONFIRMED (observed, verified twice): there is no numeric morale, rout, panic, flee, veteran,
experience or unit-level "morale state" anywhere in the donor's executable plaintext.** Every
morale-like behaviour the game actually has is one of three *non-morale* mechanics:
(1) a deterministic squad auto-disband on count loss, (2) shooter kiting implemented as a
**move-order mode**, and (3) AI **army-level** tactical retreat/force comparison.

### Whole-tree search evidence (fresh, pass 2)

| Term | Code files (373 scanned) | All files (2,559 scanned) | Interpretation |
|---|---:|---:|---|
| `morale` | **0** | 93 | All 93 are mission narrative in `data\locale\*\missions\*.txt/.lng` (e.g. `framis3.txt:70`, `scemis3.txt:42`). Label: observed. |
| `rout` | **0** | 233 | All locale narrative ("the enemy is routing!", e.g. `ausmis4.txt:72`, `bonmis1.txt:24`). observed. |
| `panic` | **0** | 247 | All locale narrative / mission keys (`@q.help.panic` etc.). observed. |
| `flee` | **0** | 831 | All locale narrative / mission keys (`@q.dragoons.flee`, `@r.let.flee`). observed. |
| `fear` | **3** (all one local bool) | 157 | The 3 code hits are one AI local variable, not a unit stat — see below. observed. |
| `veteran` | **0** | — | No experience/veteran mechanic. observed. |
| `experience` | **0** | — | No experience mechanic. observed. |
| `replenish` | **0** | — | Donor calls it "fill" (`_player_FillSquad`), not "replenish". observed. |

The 3 `fear` code hits are `data\scripts\units\global.inc\progresswarai.inc:2799,2817,2832`:
a local `Boolean` inside the AI diversionary/army logic, set when an enemy army is both closer
than 30 units and stronger (`enForce > myForce`, `:2810-2817`) and used only to skip target
selection (`:2832`). **It is a target-selection guard, not a unit morale state.** Derived from
literal code; verified twice (full-tree scan + targeted read of `:2795-2840`).

### What actually exists instead

**(a) Shooter "retreat" = a move-order mode (observed, fresh):**
- `gc_obj_order_move_mode_runaway = 2` (`dmscript.global:657`); `runawaydelay=1.3`, `runawaydist=3.5` (`:198-199`).
- `_unit_IsRunAway` (`lib/unit.script:7175-7180`): `Result := (orders[0].itype=move) AND (orders[0].info.progress=move_mode_runaway)`.
- `_unit_DoRunAway` (`:7184-7238`): `deltadst := Clamp(minsearchdist-dst, 3*epsilon, 3.5)`; place point on the line away from threat; clamp 0.25 inside map edge; `_unit_OrderMove(..., move_mode_runaway, True)`.
- Trigger: melee threat within `minsearchdist`, not stand-ground, and standtime gate (`:7364-7368`); also `:7603` and `:8152-8153`.
- The mode is also referenced as an *exclusion* in targeting/gather logic (`miscext.script:1225,1258,1274`; `unit.inc/nothing.inc:262-264`; `onendpointreached.inc:19`).
**Conclusion:** the "shooters flee when enemy closes" behaviour is a deterministic movement order, with no HP/threshold/morale variable. Label: observed.

**(b) Squad disband = deterministic count threshold (observed, fresh):**
- `gc_player_SquadDismissPercent = 0.25` (`dmscript.global:156`).
- `CheckSquadsDisband` (`units/global.inc/progress.inc:5-35`): `basecount := fBaseCount`; `count := _squad_GetBaseUnitCount`; `if count < basecount*0.25 then ... _misc_DisbandSquad(plHnd,i,true)`.
- `_squad_GetBaseUnitCount` (`lib/squad.script:98-107`): `GetCount - 1 if officer - 1 if drummer`, floored at 0. So the threshold is on **rank-and-file only**, and `fBaseCount` is the formation's `countunits` (officers excluded by the loader's `*` vs `O` counting).
- **Human-only:** the call is gated `if (not gPlayer[plind].bai) then CheckSquadsDisband(plind);` (`progress.inc:174-175`). AI squads are *not* auto-disbanded this way.
- UI nicety: if the interface player has the squad selected, member handles are cached (`progress.inc:17-28`), the squad is disbanded (`:30`), then members are re-added to the selection (`:31-32`).
Label: observed. No morale, no "rear/flank attack", no ">30% losses", no officer/drummer-death condition — those are wiki (RB S13), **UNVERIFIED** against donor plaintext.

**(c) Army retreat/force comparison = AI tactics (observed, fresh):**
- `gc_ai_BitvaInterval = 8` (`dmscript.global:478`); battle gate `if GetGameTime - TArmy.fLastBattleTime > 8 then ...` (`progresswarai.inc:1122`).
- Force-based retreat: if `enForce > myForce` (with home bonus doubling `myForce` within 25 scan-grid cells) → retreat to a safe/top zone / city centre (`progresswarai.inc:2400-2475`, `:2909`).
- Diversion `fear` bool as above (`:2799-2832`).
Label: observed. This is army command logic, not unit morale.

### What the port invented (observed in port, UNVERIFIED as donor)

| Port construct | Port line | Donor status |
|---|---|---|
| `MORALE_BASE=70`, `MORALE_ROUT_THRESHOLD=25` | `data.gd:80-81`; `config.gd:503-504`; `config.json:98-99` | No donor constant. Non-donor invention. |
| Per-unit `morale` / `routing` fields | `game.gd:1997, 4800-4818` | No donor unit field. |
| Morale hit shock `−4` / `−6` | `game.gd:5014, 5044` | No donor code. |
| Officer/drummer morale aura (+20/+10) | per RB_MECHANICS:70-71 (older line numbers) | Donor has no morale stat for an aura to modify. |
| `SQUAD_XP_PER_KILL=1`, `_PER_BONUS=2`, `_CAP=3`, `_award_squad_xp` | `data.gd:540-542`; `game.gd:3063-3080` | `experience`/`veteran` = 0 donor code hits. No donor XP raises formation bonuses. |
| `FAMINE_GRACE_S=120`, `FAMINE_DRAIN_PER_S=0.3` | `data.gd:96-97`; `config.gd:509-510`; `config.json:104-105`; `game.gd:4121,4127` | Donor famine is a **probability roll**, not a grace timer + HP drain (`unit.inc/nothing.inc:450-496`; DEC-02 D-10). Wrong model. |

**Double-verification note:** the "no morale" claim was tested twice with different corpora and
methods — DEC-02's 4.37 MB script corpus (`morale|rout|panic|fear`) and this pass's 2,559-file /
373-code-file scan with a wider key set. Both return zero code hits outside the single AI `fear` bool.
Label: observed (absence is an observed property of the scanned corpus), with the standard caveat
that binary-only behaviour cannot be excluded → residual **UNVERIFIED** for the compiled PE.

---

## Squad / AI pseudocode (donor, with ACTIVE vs plain-`;` marking)

Container note: `data\scripts\lib\*.script` and `dmscript.global` are **plain code** (active text).
`data\scripts\units\global.inc\*.inc` lines are stored as `[*] = ;<line>` — the `[*]=;` prefix is the
code-wrapper format, and the text after `;` **is ACTIVE script code** (not a comment). Plain `;`
without `[*] =` in `.global`/`.script` is likewise active code; `//` and `{ }` are true comments.
Where a behaviour exists only as a `//` comment it is marked **INACTIVE/intent** below.

### Squad creation — `lib/player.script:910-975` (ACTIVE, plain code)

```
CreateSquad(plHnd, formInd, officerHnd, drummerHnd, list, bSetPosition, bInSquad):
  if (formInd < 0) or (officerHnd valid officer) and (drummerHnd valid drummer):   // :914
     id := id of officer (or list[0])                                             // :921-928
     count := gFormation[formInd].countUnits                                     // :929
     pSquad := gPlayer[plInd].squads.AddSetup(count, id, false, true)             // :937 -> fBaseCount
     if officerHnd<>0: _squad_AddUnit(squad, officerHnd)                          // :942-943
     if drummerHnd<>0: _squad_AddUnit(squad, drummerHnd)                          // :944-945
     for each unit in list: _squad_AddUnit(squad, unit)                            // :948-953
     setup group + collision + central position/dir                               // :955-966
  else ErrorLog('Squad not created')                                              // :970-974
```
Officer/drummer are **slots 0 and 1**: `_squad_GetOfficer` reads `Get(0)` (`squad.script:7-13`);
`_squad_GetDrummer` reads `Get(1)` and **falls back to `Get(0)`** if slot 1 is not a drummer
(`squad.script:17-28`) — a nuance missed by R03 claim 9.

### Squad formation set — `lib/player.script:792-850` (ACTIVE)

```
SetSquadFormation(plHnd, squadInd, formInd, ...):
   fFormation := formInd                                        // :801
   cols := width; rows := height                                // :804-805
   fAddDamage := bonusdamage; fAddShield := bonusshield          // :809-810
   fAddDamageHold := bonusdamagehold; fAddShieldHold := bonusshieldhold // :811-812
   offHnd := GetOfficer; drumHnd := GetDrummer                    // :814-815
   zero arGrid; walk rows-1..0 × cols-1..0:                      // :819-826
      mask cell '*'  -> place next non-officer/drummer unit      // :830-841
      mask 'O' cell  -> place offHnd then drumHnd                // :845-849
```

### Squad hold-mode ramp — `units/global.inc/progress.inc:156-172` (ACTIVE `[*]=;`)

```
for each squad descending:                                        // :157-159
  if fStandGround and not fHoldMode and not fAgressive and fMoveCount=0:  // :160
     if (fAddDamageHold>0 or fAddShieldHold>0)
        and (fAddDamageHold<>fAddDamage or fAddShieldHold<>fAddShield):   // :162
        fHoldModeProgress += deltatime / gc_squad_holdmode_time            // :164  (37.5 s)
        if fHoldModeProgress >= 1: fHoldModeProgress:=0; fHoldMode:=True // :165-168
```
Resets on movement/order: `readmove.inc:59-60`, `writemove.inc:42-43`,
`readsquadlistaction.inc:136-137,219-220`, `unit.script:10668-10669`; cleared when stand-ground
turned off (`misc.script:2224-2225`, `player.script:1454-1455`). `fMoveCount` is computed only for
**human** players (`progress.inc:150-154`, `_player_CalcSquadsMoveCount`); the hold loop itself is
not AI-gated — a fresh asymmetry worth noting (see Open Questions).

### Squad disband — `units/global.inc/progress.inc:5-35,174-175` (ACTIVE `[*]=;`)

```
if not bAI then CheckSquadsDisband(plind):                        // :174-175
  for each squad descending:                                      // :8-10
     basecount := fBaseCount; count := _squad_GetBaseUnitCount     // :12-13
     if count < basecount * 0.25:                                 // :15
        if interface player and squad selected: cache members     // :17-28
        _misc_DisbandSquad(plHnd, i, true)                         // :30
        re-add cached members to selection                        // :31-32
```
Other disband call sites (all ACTIVE): `ai.script:1285`, `player.script:1339`,
`scenario.script:2170,2906`, `unit.script:3922`, `progresswarai.inc:235,809,3135,3587`,
`readsquadlistaction.inc:118,201` (network `squad|disband` action),
`gui/menu.inc/onshortcut.inc:493`. The GUI button is `showunitcontrol.inc:1500`
(`'squad|disband'`, icon `dismissformation`), bound in `hotkeys.cfg:101-102` with an **empty Key**
(i.e. shipped unbound — confirmed DEC-03 §4.7 row 25).

### Squad fill/replenish — `lib/player.script:996-1050` (ACTIVE)

```
FillSquad(plHnd, squadInd, bSetPosition, blan):
   needCount := fBaseCount - GetCount                             // :1011
   if officer present: needCount++                                // :1012-1013
   if drummer present: needCount++                                // :1014-1015
   if needCount>0:
      _squad_GetCentralPosAndDir(...)                             // :1020
      addCount := _unit_FindUnitsAndFillList(pos, gc_gameplay_officersearchradius,
                                             cid, id, plHnd, needCount, ...) // :1022
      for each added unit: _squad_AddUnit                         // :1026-1029
      _player_SetSquadFormation(...)  // re-snapshot tuple + rebuild grid   // :1033
      optionally _player_SetSquadPosition(...)                    // :1035-1037
```
`gc_gameplay_officersearchradius = 1280 / gc_pixels_to_tile` (`dmscript.global:205`); with
`gc_pixels_to_tile=53.3333` (DEC-02 §4) that is **24 tiles** (derived; R03 Open Q1). An achievement
counter `gc_ach_learn_fillsquadhalfdead10` increments when a fill adds more than half of base count
(`:1039-1040`). Donor name is "fill", not "replenish"; GUI `squad|fill` button at
`showunitcontrol.inc:1499` / `onshortcut.inc:467-477`; hotkey `F` (`hotkeys.cfg:97-98`).

### AI force / wave behaviour (ACTIVE `[*]=;` except where noted)

Constants (ACTIVE, `dmscript.global`): 16 army types (`:400-418`), 9 specialisations (`:420-428`),
9 army orders (`:430-438`, incl. `attackwall=8`), 12 construction sites (`:464`),
`UpdateEnemyInfoTick=200` (`:465`), `MergeArmyDist=3` (`:466`), `AgressorsCount=5` (`:474`),
`OfficerWaitTime=20` s (`:475`), `ArmyBattleDist=4` scan cells (`:477`), `BitvaInterval=8` s
(`:478`), `CityDangerDist=20` (`:479`); 5 difficulty tiers `-1..4` (`:781-786`).

Army composition thresholds (`lib/classes.script:4782-4843`, ACTIVE plain code):
```
armyMinCount: lightinf 36, shootinf/fasthorse/hardhorse/horseshooter/grenadier/peasant/
              archerinf 16, cannon/mortar 1, weakunit 25, supermortar 4, naval 1   // :4784-4799
defArmyMinCount: lightinf 4, others mostly same                                  // :4801-4816
armyMaxCount: infantry/grenadier/weak/supermortar/archer 256, cannon/mortar 36,
              peasant 16, naval 1                                                // :4818-4833
maxDivers[0..2] = 5, 8, 12; others 15 (gated by gc_ai_MaxDiverArmies=2)           // :4835-4843
```

Battle cadence and execution (`progresswarai.inc`, ACTIVE `[*]=;`):
```
if GetGameTime - TArmy.fLastBattleTime > gc_ai_BitvaInterval(8):   // :1122
    cancel := not _ai_CheckArmyBitva(...)                          // :1127-1130
_ai_ExecuteArmies(plInd):                                          // :4069-4095
    for each active army descending:                               // :4074-4077
        moveCount, attackCount, unitCount := ...                   // :4079-4081
        switch fOrder.iType: makebattle (check enemies, peacemode) // :4088-4095
```
Note: `gc_ai_BitvaInterval=8` is a **re-engagement cooldown after battle**, not a "wave every 8 s"
spawner — the port's `ai.gd:694` increments `wave` every think tick, which R06 flagged as the wrong
cadence. Correct reading of donor: 8 s gates army battle re-entry (`:1122`), and force comparison
(`:2810-2817`) drives retreat/target choice.

**INACTIVE/intent-only examples** (do not port as behaviour): commented
`//Log('Retreat! EnForce ...')` (`progresswarai.inc:2406`), commented rally Ctrl+LMB variant
(`gui/menu.inc/onmousedown.inc:271-278`, DONOR_RECRUIT_MODIFIERS D17), commented "make shooters less
annoying when chasing" notes (`unit.script:7367`, `:8152`), and the commented-out 4th game-speed
mode (`control.script:553`). All are `//` or `{ }` comments, not `[*]=;` code.

---

## Port-gap ranking (read-only; suggested tickets are proposals, no code changed)

| Rank | Donor rule (citation) | Current port file/line (read-only) | Missing / wrong | Suggested small ticket |
|---:|---|---|---|---|
| 1 | No donor morale stat; disband is deterministic `count<0.25*base`, **human-only** (`dmscript.global:156`; `progress.inc:15,174-175`; `squad.script:98-107`) | `data.gd:80-81,540-542`; `game.gd:1997,4800-4818,5014,5044,3063-3080`; `config.json:98-99` | Wrong model: numeric morale/rout, XP, hit-shock invented; no donor-style auto-disband call found | Remove/relabel morale as explicit deviation OR add `base_count` + 25% auto-disband gated to human slots; one selftest step |
| 2 | Hold bonus ramps 37.5 s with reset and `hold≠normal` gate (`dmscript.global:180`; `progress.inc:160-170`; `readmove.inc:59-60`) | `game.gd:3082,3100` key on per-unit `e.hold`; no `hold_progress` in port (`grep hold_progress` = 0) | Bonus applied instantly; no timer, no reset, no "hold≠normal" gate | Add `hold_progress` to squad dict; selftest t=0 vs t=37.5; fixed-seed A/B before merge |
| 3 | Famine = probability death roll, no grace/HP drain (`unit.inc/nothing.inc:450-496`; `misc.script:494-498`) | `data.gd:96-97`; `config.gd:509-510`; `config.json:104-105`; `game.gd:4121,4127` | Wrong model (grace + 0.3 hp/s) | Replace with difficulty-scaled roll; keep constants in config |
| 4 | Formation masks 54×24 with `*` units / `O` officers; 149 IDs reachable (`init.script:38-78`; `player.script:830-849`) | `data.gd:368-378` 5 generic shapes; `game.gd:3054` prefix→tuple lookup | Only 3-4 families reachable; `wedge` inherits LINE tuple; masks not imported | Add family ids + prefix mapping; unmapped → `[0,0,0,0]`; one selftest per family |
| 5 | Donor tuple snapped onto squad at set-time (`player.script:809-812`); hero/drummer slots 0/1 with slot-0 fallback (`squad.script:17-28`) | `game.gd:3082-3110`; `game.gd:3189` (drummer18 not special) | Live lookup instead of snapshot; 18c drummer not assigned; slot-0 fallback absent | Snapshot tuple on set; accept `drummer18`; mirror slot-0 fallback |
| 6 | Fill tops to `fBaseCount` within 24-tile officer radius and re-snapshots (`player.script:1011-1033`; `dmscript.global:205`) | `game.gd` replenish path (R03:3099-3130, now shifted); F key in `input_controller.gd`; fixed 6 m radius | Radius/target differ; no visible fill button | Make radius config-driven; add HUD fill button |
| 7 | AI battle cadence 8 s cooldown + force-based retreat (`dmscript.global:478`; `progresswarai.inc:1122,2400-2475`) | `ai.gd:676,868` (`wave` increments each think tick, R06 C8) | No cooldown; force ratio instead of min/max counts | Add `wave_cooldown` from donor 8 s; adopt armyMinCount thresholds after gap #8 |
| 8 | AI army min/max counts + divers (lightinf 36; maxDivers 5/8/12; `classes.script:4784-4843`) | `ai.gd:529-548,621` (ratio-based; raids need `cav<6`) | Composition heuristic differs | Adopt donor min-counts; low determinism risk |
| 9 | 5 AI difficulty tiers with behavioural effects (`dmscript.global:781-786`; R06 C1/C19) | `config.gd:528-539`; `data.gd:73`; `config.json:114` (3 tiers + resource cheat) | 2 tiers missing; cheat instead of upgrades/divers | Add veryhard/impossible; keep cheat as separate flag to preserve traces |
| 10 | Donor machine-gun round-robin of N infinite orders (`unit.script:10362-10365,10440-10443`; `doprogressorders.inc:295-310`) | `game.gd:5268-5316` (infinite flag + re-arm; cap 10 vs donor 12) | Cap 10 vs 12; batch carried differently | Raise cap to 12; align batch semantics (DONOR_RECRUIT_MODIFIERS §5) |
| 11 | Donor exact formation bonus import 149/149, 46 nonzero, 0 diffs (DEC-03 E07; R03 claim 2) | `data.gd:380-535`; `game.gd:3054` | **IMPLEMENTED** — table matches; only family reachability remains (#4) | No ticket (doc-only note) |
| 12 | Donor selection priority `(1+dist)/prio`, camera config load (`control.script:156-274,581-589`) | no equivalent found (`input_controller.gd`); camera partially imported | Out of this tranche's scope but recorded by DEC-02 | Separate camera/selection ticket |

Line numbers in the middle rows have drifted since R03 (2026-11-24): `_formation_atk/_formation_def`
moved `game.gd:3057/3086 → 3082/3100`; `SQUAD_MAX` `data.gd:544 → 549`; morale constants
`data.gd:70-71 → 80-81`. Re-verify before editing.

---

## Corrections to prior docs

1. **NEW nuance vs DEC-02 D-07 / R03 claim 10:** donor auto-disband is gated to **non-AI** players
   (`progress.inc:174-175`) and the threshold count **excludes officer and drummer**
   (`squad.script:98-107`). Prior docs stated the 25% rule without either qualifier.
2. **NEW nuance vs R03 claim 9:** `_squad_GetDrummer` is not simply `Get(1)`; it falls back to
   `Get(0)` when slot 1 is not a drummer (`squad.script:17-28`).
3. **NEW nuance vs DEC-02 D-07:** hold-mode ramp additionally requires `hold bonus > 0` **and**
   `hold bonus ≠ normal bonus` (`progress.inc:162`); `(1,1,1,1)` families can never enter hold mode.
4. **RB_MECHANICS G-13 / S13 ("morale disband on >30% losses, rear/flank attack, officer/drummer
   death; experience raises bonuses")** — **UNVERIFIED / not supported** by donor plaintext. The only
   donor disband is count-based 25% for human players; no XP/veteran code exists. Keep as a design
   addition, never as donor parity.
5. **DEC-02's "no numeric morale in 4.37 MB corpus"** — independently re-confirmed on a wider tree
   (2,559 files incl. locale; 373 code files) with zero code hits for morale/rout/panic/flee/
   veteran/experience; the only `fear` is an AI bool. Residual UNVERIFIED applies only to compiled PE.
6. **Port line drift since R03** (see §Port-gap ranking) — downstream agents must re-read lines.
7. **Port `AI_ATTACK_FORCE`** — `data.gd:73` static default is **260.0**, overridden by
   `config.json:114 = 120.0` via `config.gd:528`; R06 quoted the older 120 value. Both are port
   numbers, not donor constants.
8. **DEC-03 Open Q3 (`O` glyph)** — partially closed: loader proves `O` sets `maskofficers` and
   increments `countofficers` (`init.script:66-75`), and `player.script:845-849` places the officer
   there. Still no literal `.cfg` legend; label remains strongly derived + inferred.

---

## Open questions

1. **UNVERIFIED — `O` glyph legend.** Loader + placement prove "officer/drummer slot", but no
   `formations.cfg` legend text exists. Derived, not literal.
2. **UNVERIFIED — why auto-disband excludes AI.** AI uses `_ai_ArmyDisband` / `_ai_DisbandMineSettlers`
   (`progresswarai.inc:3573-3587,3098-3135`) instead. Do not add auto-disband to AI port without an
   owner decision.
3. **INFERRED — hold-mode asymmetry.** The hold ramp loop is not AI-gated (`progress.inc:156-172`)
   but `fMoveCount` is only computed for humans (`:150-154`), so AI squads may satisfy `fMoveCount=0`
   trivially. Confirm with a recorded game before porting AI hold behaviour.
4. **UNVERIFIED — negative `_OLD` bonuses** (`TRI_OLD -10,9,95,-19`; `PRUS_OLD 5,-5,-27,80`) are
   imported verbatim by the port; are they reachable in old saved maps or dead legacy data? Needs a
   version-gate check (DEC-03 Q5).
5. **UNVERIFIED — donor "no drummer ⇒ no bonus"** gate in port (`game.gd:3088-3089,3103-3104`):
   R03 Q2 noted no donor line states this; carried forward, still unproven.
6. **UNVERIFIED — cavalry ladder 40/90/160** has no donor `formations.cfg` id; port comments already
   label its bonuses UNVERIFIED. Keep; do not tune.
7. **UNVERIFIED — compiled PE.** Absence claims are about plaintext data/scripts only; no donor
   binary was executed or disassembled for this tranche.
8. **DOC-ONLY — stale docs to refresh:** `docs/audit/MICRO.md:233-240` (rows 52-59, old lines and
   `SQUAD_MAX=195`) and R03/R06 line numbers remain stale relative to the current tree.

---

## Summary

- **Formation truth:** `formations.cfg` stores 149 records; each is a glyph `mask` grid (max 24×54)
  where `*` = rank-and-file slot and `O` = officer/drummer slot, plus a 4-integer bonus tuple
  `[damage, shield, hold-damage, hold-shield]` and a `symmetry` flag. The tuple is loaded by
  `_init_InitializeFormations` (`init.script:38-78`), snapshotted onto each squad at formation set
  (`player.script:809-812`), and applied as ± damage/shield by `miscext2.script:347-354,425-431`,
  with the `hold*` half gated behind a 37.5 s progressive hold mode. 46 records are non-zero;
  distributions and outliers freshly re-read and consistent with DEC-02/DEC-03.
- **Morale verdict: CONFIRMED — no numeric morale in donor.** Whole-tree scans (2,559 files;
  373 code files) return zero code hits for morale/rout/panic/flee/veteran/experience. All 93/233/
  247/831 morale-family hits are mission narrative locale text; the 3 `fear` hits are one AI target-
  selection bool. Donor has only (a) deterministic squad auto-disband at `<25%` of base count,
  rank-and-file only and human-only, (b) shooter kiting as move-order mode `=2` (1.3 s / 3.5 tiles),
  and (c) AI army retreat/force comparison with an 8 s battle cooldown. The port's morale/rout/XP
  and famine grace+HP-drain are inventions (RB wiki S13 not supported by donor plaintext).
- **Squad/AI lifecycle** documented with ACTIVE `[*]=;` pseudocode for create/formation-set/hold/
  disband/fill and AI army thresholds, cadence, retreat and execution; intent-only comments marked.
- **Port gaps ranked 12 rows**; highest-value small tickets are the 25% human auto-disband, the
  37.5 s hold ramp, and replacing the famine HP-drain with the donor probability roll.
- **Two new corrections** to prior docs (human-only + rank-and-file disband; drummer slot-0 fallback)
  plus the hold-gate consequence and stale port line numbers.

**Files changed:** exactly one — `docs/coord_swarm_2026-11-25/reports/DFORM_01_formations_morale.md`.
No code edits, no runner jobs, no donor writes/copies; donor was never executed.
