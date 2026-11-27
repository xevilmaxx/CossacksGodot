# DEC-U-B11-AI — STATIC continuation reads: progresseconomicai / progresswarai split, resbalance mine levels, officer-wait / squad timing, ExecuteState sites, `[*] = ;` container D-rows

Scope: worker DEC-U-B11-AI in the full 1:1 Cossacks 3 donor port. READ-ONLY static donor-text sweep. No code/Godot/git edits, no donor execution/copying. Parity UNVERIFIED, no approximations, no parity claim.

Tooling: read-only shell (`Get-ChildItem` / `Get-Content` / `Select-String`) over donor text under `C:\Games\Cossacks 3\data\scripts\**` plus repo reports (`DEC_U_ai_thresholds.md`, `DEC_U_ai_activation.md`). No `native_*` craftanything calls were used in this ticket. No donor binaries executed. Exe pin `t_87f0f3c130b0` re-asserted by size read only: `C:\Games\Cossacks 3\cossacks.exe` = 5,768,048 B [O], matching the prior EV-BIN size.

Context: `PORT1TO1_u_classify.md` B11 = STATIC continuation reads of `progresseconomicai`/`progresswarai` split, `resbalance` mine levels, officer-wait/squad timing, the 37 `ExecuteState` sites, and the `[*] = ;` container D-rows (D-1…D-9); activate no D-row. Prior work established `[*] = ;` is a section container, AI ladders ship enabled, behaviours remain class-A `[U]`.

Method: every `path:line` below was re-read with `Get-Content` / `Select-String` in this ticket. Labels: `[O]` = byte-proven donor-text literal at the cited line; `[D]` = deterministic reading (arithmetic, container syntax) directly entailed by cited bytes; `[I]` = inference, flagged; `[U]` = UNVERIFIED, with exact zero-mismatch termination. No AI timing/value is invented; no static fact is promoted to live port behaviour.

## 1. Split definition — `ProgressEconomicAI` vs `ProgressWarAI` [O]

| Item | Donor site | Byte-proven text fact |
|---|---|---|
| Econ file identity | `data/scripts/units/global.inc/progresseconomicai.inc:1-3` | `section.begin` / `Name = ProgressEconomicAI` / `Code : struct.begin` [O]; file 231,799 B, 3924 lines [O] (`Get-Item`/`Get-Content` count) |
| War file identity | `data/scripts/units/global.inc/progresswarai.inc:1-3` | `section.begin` / `Name = ProgressWarAI` / `Code : struct.begin` [O]; file 228,378 B, 4261 lines [O] |
| Econ container close | `progresseconomicai.inc:3923` | `section.end` [O] (3924-line file; line 3924 is trailing) |
| War container close | `progresswarai.inc:4260` | `section.end` [O] (4261-line file) |
| Econ head | `progresseconomicai.inc:4` | `[*] = ;gPlayer[GetPlayerIndexByHandle(GetPlayerCurrentPlHandle)].aidata.ailist.Clear;` [O] — executable donor line inside container, not a comment |
| Econ nation consts | `progresseconomicai.inc:7-30` | `const cid_aus = 0 … cid_tat = 22, cid_lit = 23` block [O] |
| War head constants | `progresswarai.inc:5,8-11` | `const gc_ai_ZoneSizeFactor = 2;` [O]; live `var gc_ai_ApproachDist : Float = 1 * gc_ai_ZoneSizeFactor * TopologyGetZoneSize;` [O]; `var gc_ai_WaterApproachDist … 2 * …` [O]; `var gc_ai_ScanGridFactor : Float = gc_scangrid_countx / 64;` [O]; `const gc_ai_GrenadierTargetFactor = 5;` [O] |
| Manifest registration | `data/scripts/units/global.aix` (`Name = ProgressAI`, `Name = ProgressEconomicAI` + `LanClientExecute = True`, `Name = ProgressWarAI`, all `UsedFile = True` with matching `UsedFileName`, `CurrentState = Progress`) | Section manifest registers all three AI states and boots `CurrentState = Progress` [O] |
| Dispatch chain (text) | `units/global.inc/progress.inc:177-178` / `units/global.inc/progressai.inc:6-14` | `if (gPlayer[plind].bexists) and ((gPlayer[plind].bai) or …adviser…)` then `ExecuteState('ProgressAI');` [O]; `if (_player_CheckProgressLastTimeAndIncrease(gPlayer[plInd].lastprogressaitime, 2, gc_global_TimeProgressAI))` then `ExecuteState('ProgressEconomicAI'); ExecuteState('ProgressWarAI');` else adviser-only `ExecuteState('ProgressEconomicAI')` + `gbool_gui_recheckadviseradvice := False;`, always `SwitchTo('Progress');` [O] |
| Think cadence literal | `data/scripts/dmscript.global:1486` | `gc_global_TimeProgressAI = 0.03*16*5;` [O]; deterministic reading = 2.4 s [D] (arithmetic only, not a behaviour claim) |
| Think gate function | `data/scripts/lib/squad.script:756-785` | `function _player_CheckProgressLastTimeAndIncrease(var lasttime : Float; itype : Integer; addtime : Float)` [O]; slot 2 = `lastprogressaitime` (`:770`) [O]; cross-player anti-collision skip `if (checktime-addtime=gametime)` → `bskip` (`:773-778`) [O]; re-arm `lasttime := gametime+addtime` (`:782`) [O]; fires only when `gametime>lasttime` [O] |
| Think stagger init | `data/scripts/lib/player.script:140` + save twin `data/scripts/lib/serial.script:2213` | `player.lastprogressaitime := id*0.25+gc_global_TimeProgressAI;` [O]; `val.lastprogressaitime := plInd*0.25+gc_global_TimeProgressAI;` [O] |

Ships-enabled vs runtime split: the section-container syntax, manifest registration, and gate literals above ship enabled in donor text [D] (per `DEC_U_ai_activation` §§2–3, retired INERT theory). Whether the engine executes this chain at runtime stays `[U]` (U-B11-1, §6).

## 2. `resbalance` mine levels [O]

| Item | Donor site | Byte-proven text fact |
|---|---|---|
| Writer (note donor spelling) | `progresseconomicai.inc:591-595` | `procedure _ai_SetResouceBalance(plind, resid, a0, a1, a2 : Integer);` → `gPlayer[plind].aidata.resbalance[resid][0] := a0; [1] := a1; [2] := a2;` [O] |
| Food consumer | `progresseconomicai.inc:971,973` | `requiredFood : Integer = …resbalance[gc_resource_type_food][0]` then `requiredFood := requiredFood+(gPlayer[plInd].counter.farmused div 350)*5;` [O] |
| Wood/stone consumers | `progresseconomicai.inc:979-982` | `woodProportion := …resbalance[gc_resource_type_wood][0]`, `stoneProportion := …resbalance[gc_resource_type_stone][0]`; `newWood/newStone := (onWood+onStone+freepeasant.GetCount)*Proportion div 100` [O] |
| Mine-level selector | `progresseconomicai.inc:996-1032` | `_ai_ProgressMinesUpgradeByResId`: sorts `ailist` by tag-float distance to `(centerx,centerz)`; live branch `if dist>gc_ai_dist_mines_lvl2 then reqlevel := resbalance[resid][2] else if dist>gc_ai_dist_mines_lvl1 then [1] else [0]` (`:1018-1024`) [O]; superseded index-commented trio `//if (i<1)…[0] //if ((i>=2)…[1] //if (i>=3)…[2]` (`:1013-1015`) is `//`-disabled donor text [O] |
| Distance bands | `dmscript.global:503-506` | `gc_ai_dist_mines_lvl1 = 30;` / `gc_ai_dist_mines_lvl2 = 60;` / `gc_ai_dist_mines_expansion = 85;` (+ disabled `//… = 70` alt) [O] |
| Mine-id mapping | `progresseconomicai.inc:598-613` | `_ai_GetMineIdByResType`: gold→`gc_ai_unit_minegold`, iron→`gc_ai_unit_mineiron`, coal→`gc_ai_unit_minecoal` [O]; inverse `_ai_GetResByMineAiRole` [O] |
| Upgrade step | `progresseconomicai.inc:632-660` | `_ai_TryUpgradeMineEx(gohnd, cid, id, curlevel)`: `level := curlevel+1`, `sid := TUniqUpgrade(p).levelsid[level]`, `if sid<>''` then proceed [O] |

No mine timing/value is invented: which `a0/a1/a2` triple the strategy setup writes per resource is a separate strategy-block read, not closed here; live upgrade *effect* timing stays `[U]` (U-B11-2).

## 3. Officer-wait / squad timing — ships-enabled text vs runtime [U]

| Item | Donor site | Byte-proven text fact | Status |
|---|---|---|---|
| Wait constant definition | `dmscript.global:475` | `gc_ai_OfficerWaitTime = 20; // in seconds on normal speed` [O] | Definition ships [O]; any wait arithmetic is `[U]` — full-text search for `OfficerWait` returns ONLY this definition line, zero consumption sites [O] |
| Officer slots reset | `progresseconomicai.inc:1655-1657` | `gPlayer[plInd].aiData.officer17[i] := 0; officer18[i] := 0;` (loop head) [O] | Text [O]; fill timing [U] |
| Officer/drummer census | `progresseconomicai.inc:1729-1748` | `gc_ai_unit_officer17/18` + `drummer17/18` case arms: `if bAdviseProduceOfficers then count+1; if slot=0 then slot := goHnd` [O] | Text [O]; cadence [U] |
| Officer build rule 17 | `progresseconomicai.inc:2105-2130` | `numOfficers := pikemanCount div 36; if (numOfficers=0) and (pikemanCount>28) then numOfficers := 1;` then `_ai_TryUnit(…officer17/drummer17…)` gated on `countofficers17=0` / adviser or `bai` + academy + gold>300 (`:2125`) [O] | Text [O]; production timing [U] |
| Officer build rule 18 | `progresseconomicai.inc:2261-2288` | `numOfficers18 := inf18Count div 36;` … `_ai_TryUnit(…officer18…)` [O] | Text [O]; timing [U] |
| Squad constructors | `progresswarai.inc:3595,3756` | `procedure _ai_CreateOfficerSquad(offHnd, drumHnd : Integer);` [O]; `procedure _ai_TryCreateOfficerSquad(plInd : Integer);` [O] | Text [O]; form latency [U] |
| Squad call sites | `progresswarai.inc:3766-3770,4231` | `if (officer17[i]<>0) and (drummer17[i]<>0) then _ai_CreateOfficerSquad(…)` (17-pair and 18-pair) [O]; tail call `_ai_TryCreateOfficerSquad(plInd);` (`:4231`) [O] | Text [O]; dispatch condition [U] |
| Squad-write path | `progresswarai.inc:3728` | `_player_WriteSquadNew(plHnd, needFormInd, offHnd, drumHnd, …aiList, false, true)` inside officer-squad body [O] | Text [O]; engine effect [U] |
| Bitva gate | `progresswarai.inc:1122` + re-arm `:1182` | `if GetGameTime - TArmy(pArmy).fLastBattleTime > gc_ai_BitvaInterval then` [O]; `TArmy(pArmy).fLastBattleTime := GetGameTime;` [O]; band `gc_ai_BitvaInterval = 8;` (`dmscript.global:478`) [O] | Literals [O]; battle cadence [U] |
| Artillery hold | `progresswarai.inc:3976-4057` | `nullDelay` counts guns with `IsInRange(TObj(pObj).attackDelay, 0, 1)` (`:3998-3999`) [O]; `if nullDelay < artCount then fLastArtTime := GetGameTime` else `if GetGameTime - fLastArtTime >= 3 then` reposition + re-arm (`:4037-4057`) [O] | Literals [O]; fire timing [U] |
| Sail destroy delay | `dmscript.global:196` + `progresswarai.inc:3926` | `gc_unit_SailToDestroyTime = 5;` [O]; `GameObjectDelayExecuteStateByHandle(goHnd, 'SailToDestroy', gc_unit_SailToDestroyTime);` [O] | Literals [O]; delay behaviour [U] |
| Hold-mode ramp | `dmscript.global:180` + `progress.inc:164` | `gc_squad_holdmode_time = 150*8*gc_frames_to_time;` [O]; `fHoldModeProgress := fHoldModeProgress+(deltatime/gc_squad_holdmode_time)` → `>=1` latches `fHoldMode := True` [O] | Literals [O]; ramp behaviour [U] |
| Seed-wheat gate | `dmscript.global:1487` + `progresseconomicai.inc:3896` | `gc_global_TimeSeedWheat = 0.03*2000;` [O]; `if (bprocess) and (_player_CheckProgressLastTimeAndIncrease(…lastseedwheattime, 3, gc_global_TimeSeedWheat+plInd*3))` [O] | Literals [O]; wheat cadence [U] |
| Squad-move-count gate | `dmscript.global:1485` + `progress.inc:152` | `gc_global_TimeCalcSquadsMoveCount = 0.03*10;` [O]; polled via slot 1 with `(0.001*plInd)+…` skew [O] | Literals [O]; cadence [U] |

Explicit separation: every literal above ships enabled as donor text; the engine's real-time interpretation (seconds-on-normal-speed scaling, `GetGameTime` tick, squad-form latency, officer-wait countdown) needs runtime timing and stays `[U]` (U-B11-3, U-B11-4). This worker invents no wait duration and promotes no static literal to live port behaviour.

## 4. `ExecuteState` sites — exact counts, no conflation [O] + [U]

Static sweep in this ticket (`Get-ChildItem -Recurse -File` over `data/scripts`, then `Select-String`):

- All `ExecuteState` substring variants (bare + `GameObject…` + `Player…` + `StateMachine…` + `GUI…` + `…Delay…` + `…Cancel…`): **216 hits** across donor script text [O].
- Bare `(?<!\w)ExecuteState\(` only: **53 hits** across donor script text [O].
- Bare hits inside the AI dispatch files: **4** — `progressai.inc:8` (`ExecuteState('ProgressEconomicAI')`), `progressai.inc:9` (`ExecuteState('ProgressWarAI')`), `progressai.inc:14` (adviser-path `ExecuteState('ProgressEconomicAI')`), `progress.inc:178` (`ExecuteState('ProgressAI')`) [O].
- AI-adjacent delayed dispatch: `progresswarai.inc:3926` `GameObjectDelayExecuteStateByHandle(goHnd, 'SailToDestroy', gc_unit_SailToDestroyTime)` [O] (not a bare site; listed so it is not miscounted).
- The "37 `ExecuteState` sites" in the B11 angle is the **native-exe static-hit count** from prior EV-BIN (`DEC_U_ai_activation` §2/P1: 37 static `ExecuteState` hits in the pinned 5,768,048 B exe, section-name strings 0 hits because names resolve via `.aix`) — re-asserted here by size read only, not re-scanned [O-size / D-reference]. It is NOT the donor-text count (216 / 53 / 4 above); the three numbers measure different corpora and must not be merged [D].

Dispatch conditions stay `[U]`: that a bare `ExecuteState('…')` row fires requires the gate chain (`bexists`, `bai`/adviser, 2.4 s slot-2 gate, `bprocess`, `centerfound`, `TAIData.bprogress*`, `landBattle/waterBattle`/`defenceStage`, wall-attack/artillery branches) plus engine binding of the `[*]` section interpreter — exact zero-mismatch capture still required (U-B11-1, U-B11-5).

## 5. `[*] = ;` container — boundaries and D-rows D-1…D-9 (activate NONE)

Container facts re-measured in this ticket [O]:

- `progresseconomicai.inc`: 3918/3924 lines match `[*]`; 237/3924 are the empty `[*] = ;` separator alone [O].
- `progresswarai.inc`: 4255/4261 lines match `[*]`; 337/4261 are the empty `[*] = ;` separator alone [O].
- `[*]` is the section-code line container, not a comment marker: it prefixes executable rows that must ship (`peco:4` ailist clear, nation consts, `progress.inc:146-147` income/consume per prior EV-SYN-01/02) while genuine disablement appears *inside* `[*]` lines as `//` or `{…}` [D, following `DEC_U_ai_activation` §2].

D-rows (all remain dead in this ticket — no activation authorised):

| D-row | Donor site | Byte-proven row | Disposition |
|---|---|---|---|
| D-1 | `progresswarai.inc:4` | `[*] = ;//exit;` at `ProgressWarAI` head [O] | Shipped-disabled kill-switch stub; do not remove comment [O-text] |
| D-2 | `progresswarai.inc:6-10` | `//const gc_ai_ApproachDist = 16;` + `//const … = 2;` beside live `var gc_ai_ApproachDist…` / `var gc_ai_WaterApproachDist…` (`:8-9`) [O] | Superseded constants; live rows are the `var`s |
| D-3 | `progresswarai.inc:2810` | `var enForce : Integer = TArmyInfo(pAInfo).cavalry {+ TArmyInfo(pAInfo).mortars} + …infantry + …shooters;` — mortar term brace-commented [O] | Fear sum excludes mortars in shipped text |
| D-4 | `progresswarai.inc:4239-4253` | `{var armyCount…_ai_ProgressMineBuilders(pArmy);…end;}` non-AI army build-mine loop in braces [O] | Disabled; non-AI war tail is defenders-only `:4254-4255` |
| D-5 | `progresseconomicai.inc:3807-3814` + `{log…}` blocks (`:3818+`) | `{gPlayer…bFlags[…] := True/…not True;}` forced-strategy test block + `{log('plind…')…}` log blocks [O] | Debug/test-only |
| D-6 | `progresseconomicai.inc:3893,3900` (adviser-variant gates around live `:3883,3896`) | `{or ((not bai) and …bupgrades)}` in `ai_upgrade_towers` guard (`:3892-3893`); seed-wheat adviser double-gate (`:3896-3900`) [O] | Disabled variants of the live gates |
| D-7 | `progresseconomicai.inc:~2310` region per Thresholds §4 | `{36}` dragun-dip alternative beside live `32` [O per Thresholds; line approximate, value pair exact] | Disabled alternative |
| D-8 | `lib/miscext2.script:2890-2990` region (lobby/console setters `:2608/2619`, `bai` toggles `:2901,2979-2994`, `bprogress*`/`bhumanai` flags `:2918-2958`) | Console `ai …` setters that write `gPlayer[plInd].bai`, `bhumanai`, `bprogressEconomy/Construction/Produce/War/Upgrades` [O] | Owner/debug-only setters; prove flags exist, never ship-state |
| D-9 | `progresseconomicai.inc` passim | `//TimeLog(…)` tracers inside `[*]` lines [O] | Instrumentation, no sim effect |

## 6. What ships enabled vs what needs runtime [U]

SHIPS ENABLED (static text, no behaviour claim): §1 split/manifest/gate literals, §2 resbalance writer/consumers/bands, §3 constructor/gate literals, §5 container rows except D-1…D-9 `//`/`{…}` disables. AI ladders ship enabled; behaviours remain class-A `[U]` per prior classification.

NEEDS RUNTIME — blocking_unverified (all `[U]`, zero-mismatch termination stated):

- U-B11-1 — Runtime binding of the `Progress → ProgressAI → EconomicAI + WarAI` fire (text chain §1 closed, engine execution not). Termination: fixed-seed AI skirmish in unmodded donor-attached game, instrument `lastprogressaitime` + `aidata` list growth; pass = growth events on 2.4 s + `id*0.25` cadence with anti-collision, 3 seeds, 0 mismatches.
- U-B11-2 — Live mine-upgrade effect (reqlevel → `upglevel` step → mine output). Termination: fixed-seed map, log `reqlevel` vs `individual.upglevel` per mine band (</> 30/60) per 2.4 s fire for 600 s; pass = byte-identical sequences across 3 seeds, 0 mismatches.
- U-B11-3 — Officer-wait / squad-form timing (`OfficerWaitTime = 20 s` definition has zero consumers in text; `div 36` + 36-pikemen sandbox + `_ai_CreateOfficerSquad` latency unproven). Termination: officer + 36 pikemen sandbox, fixed seed, log squad-form game-time over 5 runs; pass = ±1 tick, 0 mismatches.
- U-B11-4 — Squad/army battle timing (`BitvaInterval` 8, `fLastArtTime >= 3`, `SailToDestroy` 5, hold-mode ramp, seed-wheat gate). Termination: fixed-seed battle sandbox, log `fLastBattleTime`/`fLastArtTime` fires per game-time; pass = exact literal cadences observed, 3 seeds, 0 mismatches.
- U-B11-5 — Dispatch conditions of the 37 exe `ExecuteState` sites (which site fires under which `bai`/adviser/`bprocess`/`centerfound`/`defenceStage`/wall/art branch). Termination: per-branch coverage run in donor-attached game; pass = every claimed fire observed at its gate, 0 extra fires, 0 mismatches.

## 7. Parity statement

Parity UNVERIFIED. Chain 0/6. RESULT IS NOT GOOD while blocking_unverified (U-B11-1…U-B11-5) is non-empty. No parity claim is made; no D-row is activated; no static literal above is asserted as live port behaviour. Port `ai.gd`/`data.gd`/`config.gd` values remain PORT APPROXIMATION until the terminations in §6 pass (per `DEC_U_ai_activation` §5 delta: shared 1.0 s gate vs donor 2.4 s + stagger + anti-collision).
