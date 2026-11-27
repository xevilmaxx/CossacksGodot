---
id: DEC-U-ENDGAME-STAMP
worker: DEC-U-ENDGAME-STAMP (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b0…4e16c, entry 0x8f1a08"
donor: "READ ONLY. Donor binary never executed/copied/opened as a target. Donor DScript text read as text only. No repo code/asset/config/Godot/git edit: this report is the only file written."
network: "OUT OF SCOPE. Net branches (_net_IsServer/Client/Replay/Online/Offline, Lan* parsers/sends/scores, lanid>0 fixups, WritePeaceTime/WriteFreeList net effects) are cited only to exclude them from the 1:1 sim contract."
parity: "NO PARITY CLAIM. No donor GPU A/B frame; no donor binary executed by this worker."
context: "DEC_U_scenario_win.md closed team-win _misc_CheckEndGame and precedence (nothing.inc:646 UNGATED vs progress.inc:54 gated slice); DEC_U_victory_start.md closed defeat first-transition victorystate+gametime stamp; DEC_U_teams.md called for a transition hook on every victorystate stamp (UpdateFOW re-resolve + viewer-set rebuild). Exact stamp fields/ordering/LAN exclusions remained partially [U]. THIS ticket closes the static census."
labels: "[O] verbatim donor literal (file:line) · [D] deterministic reading · [I] inference, flagged · [U] UNVERIFIED with exact experiment · PORT APPROXIMATION = port substitute to remove for 1:1"
---

# DEC-U-ENDGAME-STAMP — every `victorystate` / `victorystategametime` write: conditions, first-transition guards, scope, FOW/vision/UI tails, LAN exclusions (2026-11-26)

## 0. Pin + pass ledger (every pass pinned `t_87f0f3c130b0`; donor read-only, never executed)

| # | Pass | Result / evidence |
|---|---|---|
| P1 | Pin re-assert | `t_87f0f3c130b0` = `C:\Games\Cossacks 3\cossacks.exe`, 5,768,048 B, sha256 `87f0f3c130b0…4e16c`, entry `0x8f1a08`. Matches DEC-U-SCENARIO-WIN §0-P1 / DEC-U-TEAMS §0-P1. Binary never executed, copied, or opened as a target. |
| P2 | `victorystate` repo-wide grep (text only) | EV-GREP: literal `victorystate` over `C:\Games\Cossacks 3\data\scripts` → 54 hits in 8 files (§1 table). Only files `scenario.script`, `player.script`, `miscext2.script`, `dmscript.global`, `classes.script`, `units/global.inc/progress.inc`, `common.inc/initmapgen.inc`, `common.inc/initmaphistoricalbattle.inc` contain the token. `progress/progress.inc/nothing.inc` (global tick) and `lib/serial.script` contain **zero** `victorystate` writes `[O-absence]` (§1). |
| P3 | `units/global.inc/progress.inc:1-187` full read | EV-D: defeat stamp `:124-135` + surrender guards `:63-64` + battle short-circuit `:65-68` + scan `:69-123` verbatim §2.1. |
| P4 | `progress/progress.inc/nothing.inc:630-709` tail read | EV-N: `_misc_CheckEndGame` at `:647` UNGATED + peacetime expiry `:658-695` (no stamp) verbatim §2.2. Confirms NOTHING writes `victorystate` inline — it only CALLS the team law. |
| P5 | `lib/miscext2.script:3035-3114` debug-console + scenario-start read | EV-X1: console `scenario win/lose` `:3052-3058` (unguarded, `exit`) + clear `:3109-3110` verbatim §2.3. |
| P6 | `lib/miscext2.script:3660-3760` LAN-results + scores read | EV-L1: `_misc_LanServerSendResults :3660-3686` + `_misc_GetFirstLeaver :3690-3702` + `_misc_LanCloseSessionSetScores :3706-3760` verbatim §6. All LAN-only tails to exclude. |
| P7 | `lib/miscext2.script:3768-3896` CheckEndGame + Surrender read | EV-E: team-win stamp `:3810-3818` + LAN fixups `:3820-3835` + `bchanges` net tail `:3837-3842` + surrender `:3849-3896` verbatim §2.4/§2.5. |
| P8 | `lib/player.script:100-145` init + `:451-478` UpdateFOW + `:1900-1925` balloon caller read | EV-F: reset `:111-112` + FOW kill-switch `:456` + viewer set `:460-477` + balloon re-resolve verbatim §5. |
| P9 | `lib/scenario.script:2990-3075` endgame actions + `:1680-1689` offline gate + `:3290-3308` bupdateally tail read | EV-S: trigger win `:2995-3008` / lose `:3049-3065` (myplind-only, first-transition guard, campaign/profile tails) + `net_IsOffline` victorystate-gated condition `:1686-1688` + diplomacy FOW refresh `:3302-3306` verbatim §2.6/§5. |
| P10 | `lib/serial.script:60-200` compat re-link read | EV-R: `:83-94` + `:164-175` enemy/friend rebuild (FFA-safe `0 vs anything = enemy`), zero `victorystate` writes `[O-absence]` §1. |
| P11 | `common.inc/initmapgen.inc:240-289` + `initmaphistoricalbattle.inc:115-144` init reads | EV-I: spectator purge `:256-264` (unguarded lose) + historical clear `:124-129` verbatim §2.7. |
| P12 | `lib/control.script:710-720` SetPlayer read | EV-C: `GUIMiniMapPrimitivesClear → SetPlayerHandleInterfaceIO → _player_UpdateFOW → DeselectAll → DoUpdateSelection → InitMinimap` order verbatim §5. |
| P13 | Port `variant3d/scripts/game.gd` + `world3d_fog.gd` read-only inspection (no edit) | EV-P: `game.gd:489-494` defaults, `:8292-8376` CheckEndGame/surrender, `:8382-8422` bexists/defeat, `:8432-8480` _check_victory, `:8555-8591` serialize; `world3d_fog.gd:579-614` rebuild_fow_enable, `:604-614` terminal gate, `:645-673` viewer set, `:699-706` entity filter §7. |

DSL note `[D]` (inherited): donor `not X` on a numeric lvalue is the current-value read, not boolean negation.

---

## 1. Writer census — every `victorystate` / `victorystategametime` write site (closed)

Grep EV-GREP (54 hits) collapses to **12 write statements in 7 files**. Reads (`=`, `<>`, `ParserSetIntValue`) are NOT writes and are listed only to prevent miscounts. `nothing.inc` and `serial.script` write **nothing** — their absence is load-bearing.

| # | Site | File:line | Writes | Kind |
|---|---|---|---|---|
| W1 | defeat first-transition | `units/global.inc/progress.inc:130-132` | `gPlayer[plind].victorystate := lose; if (=0) then gametime := GetGameTime` | per-player LOSE, guarded |
| W2 | console `scenario win` | `miscext2.script:3053-3054` | `gPlayer[0].victorystate := win` (NO gametime, `exit`) | tooling, unguarded |
| W3 | console `scenario lose` | `miscext2.script:3057-3058` | `gPlayer[0].victorystate := lose` (NO gametime, `exit`) | tooling, unguarded |
| W4 | scenario-start clear | `miscext2.script:3109-3110` | `gPlayer[0].victorystate := none; gametime := 0` | tooling/init, unconditional |
| W5 | team-win stamp | `miscext2.script:3813-3815` | `victorystate := win; if (=0) then gametime := GetGameTime` (+ `winnerteam := team`, `bchanges := True`) | per-TEAM win, guarded |
| W6 | LAN-human win flip | `miscext2.script:3824-3826` | `victorystate := win; if (=0) then gametime := GetGameTime` | LAN-only, guarded — EXCLUDE |
| W7 | LAN-human lose fill | `miscext2.script:3832-3834` | `victorystate := lose; if (=0) then gametime := GetGameTime` | LAN-only, guarded — EXCLUDE |
| W8 | surrender server path | `miscext2.script:3859-3861` | `gPlayer[plind].victorystate := lose; if (=0) then gametime := GetGameTime` | per-player LOSE, guarded |
| W9 | surrender offline path | `miscext2.script:3891-3893` | `gPlayer[plind].victorystate := lose; if (=0) then gametime := GetGameTime` | per-player LOSE, guarded |
| W10 | trigger `endgame_win` | `scenario.script:2996-2998` | `gPlayer[myplind].victorystate := win; if (=0) then gametime := GetGameTime` | interface-player WIN, guarded |
| W11 | trigger `endgame_lose` | `scenario.script:3050-3052` | `gPlayer[myplind].victorystate := lose; if (=0) then gametime := GetGameTime` | interface-player LOSE, guarded |
| W12 | player init reset | `player.script:111-112` | `player.victorystate := none; victorystategametime := 0` | per-slot init, unconditional |
| W13 | spectator purge | `initmapgen.inc:263` | `gPlayer[i].victorystate := lose` (NO gametime write) | init, unguarded |
| W14 | historical-battle clear | `initmaphistoricalbattle.inc:127-128` | `victorystate := none; gametime := 0` | init, unconditional |
| — | ABSENT (no write) | `progress/progress.inc/nothing.inc` (whole file) | zero `victorystate` tokens; only CALLS `_misc_CheckEndGame` at `:647` | `[O-absence]` |
| — | ABSENT (no write) | `lib/serial.script` (whole file) | zero `victorystate` tokens; only `enemyplmask` + `AddPlayerEnemy/Friend` compat | `[O-absence]` |

Read-only neighbours (NOT writes — do not port as stamps): `miscext2.script:3674-3680` (LAN result serialise `win→win / lose→lose / else none`), `:3696-3699` (`GetFirstLeaver` reads `0 < gametime < 15*60` minimum), `:3728-3756` (score branches read `victorystate`), `dmscript.global:777-779` (enum `none=0/win=1/lose=2`), `classes.script:3684-3685` (field decls `Integer` + `Float`).

---

## 2. Exact conditions per write (verbatim, in call order)

### 2.1 W1 — skirmish auto-defeat (`units/global.inc/progress.inc:54-141`) [O]

Gate stack (all must hold or NO stamp):

1. `:43` `lastprogresstime > 0 AND deltatime > 0` (progress slice alive).
2. `:46` NOT (`_net_IsClient OR _net_IsReplay`) — client/replay never progresses.
3. `:54` `not gScenario.bactive AND gamestage > waitingloading AND gamemode IN (game, spectator)` — **scenario/mission mode never auto-defeats** (DEC-U-SCENARIO-WIN §4.4 re-pinned).
4. `:61` stagger gate `_player_CheckProgressLastTimeAndIncrease(lastcheckexists, 0, addtime)` with `addtime = 0.125*plInd + (bexists ? 8.0 s : 24.0 s)` (`gc_global_TimeCheckExists = 2.0 s`, `dmscript.global:1484`).
5. `:63-64` skip if `bnetsurrender = _net_IsServer AND bleave` OR `bsurrender = _net_IsOffline AND victorystate == lose` (already-surrendered slots do not re-enter).
6. `:65` `not gMap.bbattle` — battle mode forces `bexists := True` (`:67`), no scan, no stamp.
7. `:89-123` scan: `0 < farmused < 100` → deep scan (peasant `visual_none+essential_none`, human-inside-transport, built `usage=center`) else `bexists := (farmused > 0)`.
8. `:124` `not bexists AND (bai OR map-player bhuman)` → enter kill/stamp branch.
9. `:126-127` `if (GetPlayerGameObjectsCountByHandle > 0) then _misc_KillPlayerUnits` — units die BEFORE the stamp read below.
10. `:128` **`if (bPrevExists)`** — the first-transition guard: stamp fires only on the `True→False` edge (`bPrevExists` captured at `:73` before the scan).

Stamp (W1): `:130-132` `lose` + `gametime := GetGameTime` **iff 0**, then `:133` `_misc_LanServerSendResults` (net tail, §6). Leaver branch `:137-139` kills units with NO stamp on this path (the `lose` comes from `_misc_Surrender` W8/W9 instead).

### 2.2 Global tick — no inline stamp (`progress/progress.inc/nothing.inc:646-695`) [O]

- `:647` `_misc_CheckEndGame;` runs **UNGATED** (no `bactive`/gamemode/gamestage gate) every global tick — the ONLY endgame writer on this path is the callee (W5-W7).
- `:658` peacetime expiry `gbool_peacemode AND gametime > gfloat_peacetime AND not replay AND not client` → clears flag, destroys `ptborder` objects via `WriteFreeList`, broadcasts `WritePeaceTime`, `GameObjectRequestToDestroy`, `GUIMiniMapPrimitivesClear + _misc_UpdateMiniMapPrimitives(True)`. **No `victorystate` write on this path** — expiry never stamps.
- Ordering `[D]`: per-player slice (W1) runs on its staggered cadence; global-tail CheckEndGame (W5) reads the FRESH `bexists` later in the same frame (DEC-U-SCENARIO-WIN §4/§6 re-pinned). A kill at tick T can therefore `lose`-stamp (W1) and `win`-stamp survivors (W5) in the same frame: `win_tick >= lose_tick` is legal.

### 2.3 W2/W3/W4 — debug-console + scenario-start (`miscext2.script:3043-3110`) [O]

- Console dispatcher `:3043` case `'scenario'`, sub-key `s2`: `'win'` → W2 `gPlayer[0].victorystate := win; exit` (`:3052-3054`); `'lose'` → W3 `gPlayer[0] := lose; exit` (`:3056-3058`). **No `myplind`, no guard, no `gametime`, immediate `exit`** — slot 0 only, tooling path. The `scenario run/start/active` arms (`:3046-3050`) and `stop` disarm are the adjacent state writes, not stamps.
- Scenario-start re-init (only when `(gScenario.bactive)` after the dispatch, `:3064+`): `:3077` battle → `bexists := roster bexists` else `:3081` `bexists := (farmused > 0)`; offline slot-0 force `:3084-3087`; then W4 `:3109-3110` `gPlayer[0].victorystate := none; gametime := 0` (unconditional clear of the interface slot only).

### 2.4 W5/W6/W7 — `_misc_CheckEndGame` (`miscext2.script:3768-3845`) [O]

- Phase 1 — roster gate `:3775-3789`: over `gMap.players[i].bexists` (**roster-side**); collect `gPlayer[i].team` (**sim-side**); two distinct sim teams → `bSecondTeamExist` else `return False`, **no writes**.
- Phase 2 — live gate `:3791-3804`: pairwise `gPlayer[i].bexists AND NOT bleave`; any cross-team live pair → `bOneTeamLeft := False, break(MAIN)`. Single live team (or zero live — `True` vacuous, but the stamp loop then finds nobody) → enter stamp.
- W5 `:3810-3818`: every `gPlayer[i].bexists AND NOT bleave AND victorystate <> win` → `win` (+ `gametime iff 0`), record `winnerteam := team`, `bchanges := True`. **Team scope**: every survivor, never one pick. Unused-var edge `[D]`: `winnerteam` is `var`-zero-initialised, so the `winnerteam > 0` guard at `:3820` is deterministically false on the no-stamp path (DEC-U-SCENARIO-WIN §5 re-pinned).
- W6 `:3820-3827` LAN-human win flip + W7 `:3829-3835` LAN-human lose fill: both require `gMap.players[i].bhuman AND lanid > 0` — **LAN-only, excluded from the 1:1 contract** (§6).
- Net tail `:3837-3842`: `if (bchanges)` → `log + _misc_LanServerSendResults + _misc_LanCloseSessionSetScores` — **excluded** (§6). No FOW/minimap/vision call anywhere in this function.

### 2.5 W8/W9 — `_misc_Surrender` (`miscext2.script:3847-3896`) [O]

- `:3851-3853` `plInd := GetPlayerIndexInterfaceIO; if (not bspectator) then bleave := True` (spectators never become leavers).
- W8 server path `:3856-3861`: `if (_net_IsServer)` → `if (not bspectator) then victorystate := lose` (unconditional overwrite, not `<>`-guarded) + `gametime iff 0`, then `:3862` `_misc_CheckEndGame` (W5 may crown survivors in the SAME call).
- Client path `:3868-3870`: `LanSendParser(SURRENDER)` only — **no local stamp** (excluded).
- W9 offline path `:3889-3894`: `if (_net_IsOffline)` → `victorystate := lose` (unconditional) + `gametime iff 0`, then `_misc_CheckEndGame`.
- Non-surrender readers in the same function (`GetFirstLeaver`, rating/country re-link `:3872-3886`, `LanTerminateGame`) are LAN/rating tails — excluded.

### 2.6 W10/W11 — trigger `endgame_win/lose` (`scenario.script:2995-3065`) [O]

- Dispatcher `_scenario_EvaluateTriggerActions` captures `myplind := GetPlayerIndexInterfaceIO` once (`:1742`); win/lose branches read **no `.player` action field** — always the interface slot (neighbours take `.player` at `:1818-1829`; cf. DEC-U-SCENARIO-WIN §3).
- W10 `:2996-2998`: `gPlayer[myplind] := win` + `gametime iff 0` (first-transition guard on the TIME only — the state overwrites unconditionally, same shape as W8/W9). Then campaign tails `:3002-3047`: `started/finished/maxfinishdifficulty`, per-campaign achievement bits (`auscam/engcam/fracam/ukrcam/ruscam`, `tutcam`), `_profile_SaveStructToUserProfileParser`. Commented spectator-switch lines (`:2999-3000`) are dead.
- W11 `:3050-3052`: mirror `lose` + `gametime iff 0`, then loss-counter tail `:3056-3064` (`lose := Min(lose+1, started)`, no achievement bits). Commented spectator lines (`:3054-3055`) dead. Stub `advanced_ifThenElse` (`:3066-3068`) logs `todo` — never a stamp.
- Net-IsOffline condition `:1686-1688` reads the stamp (`victorystate = none` required) but never writes it: once `myplind` is terminal, offline-gated triggers stop firing.

### 2.7 W12/W13/W14 — init paths [O]

- W12 `player.script:110-117` (`_player_Init`, per slot `id`): `victorystate := none; gametime := 0; enemyplmask := 255 xor (1 shl id); myplmask := 1 shl id; team := 0; bexists := False` (+ `bai/bneutral := False` at `:119-124`). Sim-team `0` is the pre-setup sentinel, never an alliance.
- W13 `initmapgen.inc:256-264`: `if (roster bexists AND cid = spectator_countryid)` → `roster bexists := False; sim bexists := False; bleave := True; victorystate := lose` — **no `gametime` write, no `<>`/edge guard** (unconditional; differs from every guarded stamp).
- W14 `initmaphistoricalbattle.inc:124-129` (only `if gScenario.bactive`): all slots `bexists := True; victorystate := none; gametime := 0` — unconditional clear; the team law then decides purely on later kills/surrenders.

---

## 3. First-transition guards — exact shape per stamp [O]

| Stamp | Guard on STATE | Guard on TIME | Unconditional overwrite? |
|---|---|---|---|
| W1 defeat | `if (bPrevExists)` — True→False edge only | `if (=0)` | no |
| W5 team-win | `<> win` per survivor (re-stamp of a `lose` slot is allowed → flips to `win`) | `if (=0)` | no (skips wins) |
| W6 LAN win flip | `= lose AND team = winnerteam` (+ human/lanid) | `if (=0)` | yes within its filter — EXCLUDE |
| W7 LAN lose fill | `<> lose AND <> win` (+ human/lanid) | `if (=0)` | yes within its filter — EXCLUDE |
| W8/W9 surrender | NONE on state (overwrites even a `win`) | `if (=0)` | **yes** |
| W10/W11 trigger | NONE on state (overwrites even the opposite terminal) | `if (=0)` | **yes** |
| W2/W3 console | NONE + no time write at all | — | **yes** (slot 0) |
| W4/W12/W14 clear | NONE (init) | assigns `0` | yes |
| W13 purge | NONE + no time write at all | — | **yes** |

Consequences `[D]`:

1. `victorystategametime` is a **first-write-wins** field everywhere it is written: the `= 0` check precedes every `GetGameTime` store except the clears (which zero it) and the three no-time writes (W2/W3/W13 — time keeps whatever it held, including `0`).
2. The STATE field is first-transition-guarded ONLY at W1 (`bPrevExists`) and W5 (`<> win`). Surrender (W8/W9) and trigger (W10/W11) stamps overwrite unconditionally — a second trigger firing, or a surrender after a trigger win, REPLACES the state but (by rule 1) keeps the original tick.
3. The port must therefore keep TWO independent pieces of logic: an edge/inequality gate for the state (per-site, NOT one global `eliminated` flag) and a `== 0.0` gate for the time. A single boolean cannot reproduce W5's `lose→win` flip or W10's `win→lose` overwrite.

---

## 4. Team-vs-player scope [O]

- **Player scope**: W1 (that slot), W8/W9 (caller `plind`), W10/W11 (`myplind` = interface slot only), W2/W3/W4 (slot 0), W12 (that slot), W13 (that spectator slot), W14 (each slot in a loop, but still per-slot values).
- **Team scope**: ONLY W5 (every live non-leaver non-win) + its LAN shadows W6/W7. No other writer loops over mates. The trigger path NEVER stamps a team — the team-wide win after a mission trigger comes solely from a later CheckEndGame pass reading the fresh `bexists` (DEC-U-SCENARIO-WIN §4 re-pinned).
- **Roster vs sim split** `[O]`: phase 1 reads `gMap.players[].bexists` + `gPlayer[].team`; phase 2 reads `gPlayer[].bexists + bleave + team`. The defeat scan (W1) writes SIM `bexists` only; the spectator purge (W13) writes BOTH; historical battle (W14) writes SIM `bexists := True` for all slots (roster untouched).
- **Field order** `[D]`: every guarded stamp writes `victorystate` FIRST, then conditionally `victorystategametime`. The clears write the same order (`none`, then `0`). No site writes time before state; no site writes any third field atomically with the stamp (the `winnerteam`/`bchanges` locals in W5 and the campaign/profile tails in W10/W11 follow, they do not interleave).

---

## 5. FOW / vision / UI side effects (what the stamp does and does NOT do) [O]

### 5.1 The stamp itself writes no FOW/UI field — vision flips at the NEXT `_player_UpdateFOW`

- `player.script:453-478` verbatim law: `bFOW := True; if (bballoon OR balloon-option-with OR victorystate <> none) then bFOW := False` (`:456`); `if (not editor_fogofwar) then False` (`:459`); `ClearFOWPlayers; AddFOWPlayers(self) + same-sim-team mates minus slot-0/bneutral exception` (`:460-474`); `SetFOWDovFunc('_unit_GetVision')` (`:475`); `SetFOWEnable(bFOW)` (`:477`).
- Consequence `[D]`: ANY terminal stamp (W1/W5/W8/W9/W10/W11 lose OR win, even W2/W3/W13) disables FOW for that viewer the next time ITS `UpdateFOW(plInd)` runs — full map vision. The stamp functions themselves (W1/W5/W8/W9/W10/W11) contain **zero** `UpdateFOW / ClearFOWPlayers / AddFOWPlayers / SetFOWEnable / SetFOWDovFunc` calls — verified by read (P8/P12 grep: `UpdateFOW` hits are ONLY `player.script:1913/1921`, `serial` compat `276/286`, `initmapgen` compat `276/285`, `control.script:716`, `scenario.script:3305`). No stamp re-resolves vision inline. This is the hook DEC-U-TEAMS §5 called for: the port must call its FOW rebuild AFTER every stamp (§7), because the donor relies on the next explicit `UpdateFOW` call to propagate it.

### 5.2 Explicit re-resolve callers (the only vision refresh paths) [O]

- `control.script:712-720` `_control_SetPlayer`: `GUIMiniMapPrimitivesClear → SetPlayerHandleInterfaceIO → _player_UpdateFOW(plInd) → DeselectAll → DoUpdateSelection → InitMinimap`. Viewer switches re-resolve vision + minimap together.
- `scenario.script:3302-3306`: `if (bupdateally)` (set by diplomacy actions 18/19/20 at `:2196/:2223/:2248`) → `_player_UpdateFOW(plIO) + _misc_UpdateMiniMapPrimitives(False)`. Trigger diplomacy refreshes vision/minimap; trigger WIN/LOSE (W10/W11) do NOT set `bupdateally` — no refresh inline.
- `player.script:1907-1921` balloon upgrade: interface balloon → `_player_UpdateFOW(plInd)`; allied balloon → mirror `bballoon := True` on `myPlInd` + `UpdateFOW(myPlInd)`; then `_misc_CreateBalloon` (replay/client-gated). Balloon and victory share the SAME `:456` kill-switch.
- `initmapgen.inc:276/285` + `serial.script:276/286`: save-compat path only (`gRecordGeneratorVersion < 53/89` → `DeletePlayer + UpdateFOW(interface)`). No sim-rule content.
- `_misc_CheckEndGame` and the W1 defeat branch issue **no** `UpdateMiniMapPrimitives / GUIMiniMap* / UpdateFOW` call. Minimap death-dots therefore update on the generic per-tick primitive path, not on the stamp.

### 5.3 UI tails attached to stamps (port / do-not-port split)

- W1: `_misc_LanServerSendResults` (`:133`) — LAN-only, exclude (§6). Plus `_misc_KillPlayerUnits` BEFORE the stamp (`:126-127`) — SIM side effect, port must keep (already in `game.gd:8420-8422`).
- W5: `log('…bchanges') + LanServerSendResults + LanCloseSessionSetScores` (`:3837-3842`) — LAN-only, exclude (§6).
- W10: campaign `started/finished/maxfinishdifficulty` + achievement bits + `_profile_SaveStructToUserProfileParser` (`:3002-3047`); W11: loss counter + profile save (`:3056-3064`) — mission/profile persistence, NOT the 1:1 skirmish sim; port must not wire them to skirmish wins.
- W10/W11 commented spectator-mode switches (`:2999-3001/:3053-3055`) are dead code — never port.
- W13 purge writes `bleave := True` alongside the stamp — the ONLY init stamp that also flips leaver state (surrender W8/W9 does the same at runtime; W1/W5/W10/W11 never touch `bleave`).
- Peacetime expiry (`nothing.inc:658-695`) and `_control_SetPlayer` minimap clears are the only `GUIMiniMapPrimitivesClear + UpdateMiniMapPrimitives` calls near endgame — neither is conditioned on a stamp.

---

## 6. LAN-only tails to EXCLUDE (never part of the 1:1 sim contract) [O]

All live under `_net_*` gates or `lanid > 0` filters. Quote with `file:line`; port NOTHING below:

1. **W6** `miscext2.script:3820-3827`: `winnerteam > 0` + `bhuman + lanid > 0 + victorystate = lose + team = winnerteam` → flip to `win` (+ time iff 0). Post-stamp reconciliation of humans who lost before their team won.
2. **W7** `miscext2.script:3829-3835`: `bhuman + lanid > 0 + state neither lose nor win` → `lose` (+ time iff 0). Forces every undecided LAN human to a terminal state.
3. **`_misc_LanServerSendResults`** `:3660-3686`: gated `if (_net_IsServer) AND gamemode IN (game, spectator)`; serialises every slot (`id = lanid, ind, res = win/lose/none` at `:3674-3680`) and `LanSendParser(SESSION_RESULTS)`. Called from W1 (`progress.inc:133`), W5 (`miscext2:3840`), and surrender paths.
4. **`_misc_GetFirstLeaver`** `:3690-3702`: reads `0 < gametime < 15*60` minimum over all slots — earliest stamp inside a 15-minute window. Consumed ONLY by the scores function below; never a sim rule.
5. **`_misc_LanCloseSessionSetScores`** `:3706-3760+`: gated `_net_IsServer AND gamemode IN (game, spectator) AND (brating OR (not brating AND gt > 600 s))`; `LanSrvSetClientScore(lanid, ±w)` with `w = 1` (rating) / `2` (non-rating), first-leaver penalty, and the 1v1 team-mirror cases (`:3740-3757` slots 0..3). Rating/scoreboard only.
6. **Surrender net arms** `:3854-3887`: `_net_IsOnline → server` (W8 + CheckEndGame + `LanSendParser(LEAVE)` if `blanterminate`) vs `client` (`LanSendParser(SURRENDER)`, no local stamp) vs rating/country re-link (`:3872-3884`) vs `LanTerminateGame`. The OFFLINE arm (W9, `:3889-3894`) is the only surrender stamp in the 1:1 contract.
7. **Trigger net conditions/actions** `scenario.script:1676-1688` (IsServer/Client/Online/Offline — note `IsOffline` ALSO reads `victorystate = none`, §2.6) and actions 90-98 (`net_SetTriggerActive … net_TeamExecuteTriggerActions`, `:3196-3280`, DEC-U-SCENARIO-WIN §1) — excluded in full.
8. **Peacetime net guards** `nothing.inc:658` (`not replay AND not client`) and `WritePeaceTime/WriteFreeList` broadcasts — transport, not sim.

---

## 7. Port change list — `game.gd` / `world3d_fog.gd` (no edits made; COORD/owner applies)

All items add donor-verbatim behaviour or explicitly labelled placeholders. None invents a number. None touches save version, existing keys, or network.

1. **`game.gd:8410-8422` (`_check_player_exists`) — split the single `eliminated` flag into per-site edge gates (§3).** Keep the kill-before-stamp order (`_kill` loop BEFORE the state write — donor `:126-132`). Replace the `eliminated` boolean with the donor edge: stamp `lose` only when the freshly computed `_player_bexists(i)` is `False` AND the previous tick's value was `True` (store `prev_bexists:Dictionary` alongside `players`). Keep the `gametime == 0.0` time gate (already landed). Add the `:63-64` skip (server-`bleave` / offline-already-`lose`) and the `:65-68` `battle_mode ⇒ return` (already landed via `_player_bexists`) with cites `progress.inc:63-68`.
2. **`game.gd:8296-8357` (`_misc_check_end_game`) — make the W5 gate exact + stop the `winner` scalar from shadowing re-stamps.** (a) Phase-1 must ALSO require at least one rostered slot (current `have_team` handles it) and must compare `_sim_team` values post-SetupTeams only — after DEC-U-TEAMS §8 change 1 lands, assert `>= 1` in debug. (b) The stamp loop is correct (every live non-leaver non-win, `gametime iff 0`, cites `:3810-3818`); ADD the missing donor consequence: slots that already hold `lose` ARE flipped to `win` here (current `!= win` skip already does this — annotate it as the `lose→win` flip, not a bug). (c) Keep `winner/game_over.emit` labelled PORT-ONLY, but do NOT early-return later stamps because `winner != -1` — a W10 `lose` overwrite or a second W5 pass must still update per-player fields even after the first emit. Cite `miscext2.script:3768-3845`.
3. **`game.gd:8362-8376` (`_surrender`) — match W8/W9 unconditional overwrite + spectator guard.** Current code skips the stamp when already `lose` (`:8367`) — donor overwrites unconditionally (time gate still `iff 0`). Change to always assign `lose`, keep the `== 0.0` time gate, ADD `if (spectator) skip bleave` (donor `:3852-3853`; spectators land with the purge W13 instead), then run `_misc_check_end_game()` in the same call (already landed). Wire the offline/server split later; NEVER the client `LanSendParser` arm. Cite `:3847-3896`.
4. **`game.gd:489-494` (`new_player` defaults) — add the W12/W13/W4 init neighbours.** Beside the landed `roster_bexists/bleave/victorystate_int/gametime`, add `bneutral: false` (TPlayer flag read by `UpdateFOW`, `player.script:470-472`) and document `team: -1 → 0` normalisation boundary for `_setup_teams` (DEC-U-TEAMS §8-1). Spectator creation must set `roster_bexists=false + bleave=true + victorystate[_int]=lose` with NO time write (W13 exact). Historical-battle/mission loads clear `none/0` (W14). Cite `player.script:110-124 + initmapgen.inc:256-264 + initmaphistoricalbattle.inc:124-129`.
5. **`game.gd` (new, ~4 lines) — add the transition hook DEC-U-TEAMS §5 called for.** After EVERY per-player stamp site (W1 loop, W5 loop, `_surrender`, future trigger engine W10/W11, spectator purge) call `world3d_fog.rebuild_fow_full()` (or the 2D `world.gd` `_update_fog` force path) so the `:456` terminal-state kill-switch propagates the same frame. Donor calls it lazily via the next `UpdateFOW`; the port's single global fog grid has no per-viewer lazy path, so an eager rebuild is the faithful mapping — label PORT MAPPING, behaviour identical (fog off for terminal viewers). Cites `player.script:451-478 + scenario.script:3302-3306 + control.script:712-720`.
6. **`world3d_fog.gd:579-614` (`rebuild_fow_enable`) — keep, add surrender/purge coverage note.** The V3 terminal gate (`_is_terminal_victory`, `:604-614`) already implements `:456` (`<> none` ⇒ off). No change to the gate. ADD a comment: W8/W9 unconditional `win→lose` overwrites and W13's no-time `lose` BOTH trip this gate on the next rebuild — the hook in item 5 is what makes that timely. Cite `player.script:456 + dmscript.global:777-779`.
7. **`world3d_fog.gd:645-673` (`_fow_viewer_players`) + `:699-706` (entity filter) — keep, file the two stamp-adjacent gaps as labels.** (a) Terminal MATES are currently skipped from the viewer set (`:661`) — donor adds them unconditionally (`player.script:463-473` has no terminal check inside the loop); harmless while their units are dead (W1 kill precedes stamp), but annotate PORT APPROXIMATION. (b) `_is_fow_viewer_entity` (`dead/finished/hidden`) is the port of `_unit_GetVision`'s `bdead/bbuilt/visible` gates (`unit.script:11563-11614`) — keep, cite added. Neither change alters the stamp law.
8. **Do NOT port**: W2/W3 console stamps, W4 slot-0 clear (until a scenario console exists), W6/W7 LAN flips, any §6 net send/score/rating call, campaign/profile tails (W10/W11 `:3002-3064`), commented spectator-switch lines, `advanced_ifThenElse` stub, trigger net actions 90-98.

---

## 8. Still-[U] register — fixed-seed endgame captures, zero-mismatch criteria (no stamp invented)

Seed convention (all rows): fixed seed S, map `land/med/plains`, peacetime 0, AI passive (no orders) unless the row says otherwise. `victorystate_int`: 0 none / 1 win / 2 lose (`dmscript.global:777-779`). `gametime` = donor `GetGameTime`, port `time_s`. Each run asserts tick-exact equality across 3 identical-seed runs AND the stated cross-condition. Owner-authorised donor runs only; never this worker.

| # | Item | Static state after this ticket | Exact experiment | Zero-mismatch criterion |
|---|---|---|---|---|
| U-S1 | Stamp-tick granularity (`GetGameTime` vs tick) | Field order closed (§4: state first, time iff 0); tick quantisation open | 1v1 skirmish, seed S: kill P1's last peasant/center at fixed tick T (port harness). Log `lose_tick` (W1) + `win_tick` (W5) + both `gametime` values. | 3 runs identical `lose_tick/win_tick/gametime` triple; `win_tick >= lose_tick` (same frame allowed per §2.2); any `win_tick < lose_tick` = ordering bug. No invented timestamp. |
| U-S2 | `winnerteam` init on the empty path | Donor `var` zero-init ⇒ `> 0` guard false `[D]` §2.4; port `-1` equivalent unproven at runtime | 1v1, seed S, no kills for N ticks: assert NO stamp and NO LAN send. Then FFA 4-slot wipe in fixed order. | No-write phase: zero `victorystate_int`/`gametime` deltas across 3 runs. Wipe phase: final survivor `1`, rest `2`, identical ticks. Any `win` with ≥2 live teams = fail. |
| U-S3 | `lose→win` flip vs `win→lose` overwrite precedence | W5 flips `lose`→`win` (`<> win`); W8/W9/W11 overwrite anything (incl. `win`→`lose`) [O] §3 | 2v2 seed S: (a) wipe team B → both A `win`; then surrender one A slot → that slot `lose`, mate stays `win`. (b) Trigger-harness future: W10 `win` then W9 surrender same slot. | (a) Post-surrender: leaver `2`, mate `1`, `gametime` of mate UNCHANGED (first-write-wins); (b) surrender keeps original `win` tick in `gametime`. Any time overwrite = fail. |
| U-S4 | FOW re-resolve timing after each stamp (the DEC-U-TEAMS hook) | Donor lazy (`UpdateFOW` at next SetPlayer/diplomacy/balloon) [O] §5; port eager hook proposed §7-5 | 1v1 seed S with FOW on: stamp `lose` (W1) on P1; dump viewer's `fow_enabled + viewer set + los_at` the same tick and next tick. | Post-hook: viewer-0 grid off (`los_at = 1` everywhere) EXACTLY from the stamp tick; 3 runs identical bitmaps. Stale fog one extra tick = hook missing. |
| U-S5 | Surrender spectator guard + client no-stamp arm | Donor `:3852-3853` skips `bleave` for spectators; client sends parser, no local write [O] §2.5 | Spectator-slot fixture (W13 shape): call `_surrender` on the spectator slot. | `bleave` stays `False`, state stays `lose` from purge (no double write), `gametime` unchanged. Any flip to `win` by later W5 = fail (leaver exclusion). |
| U-S6 | W13 no-time purge vs guarded stamps | W13 writes NO `gametime` [O] §2.7; all other runtime stamps gate `iff 0` | Init fixture with 1 spectator + 2 humans, seed S: read purge slot `victorystate/gametime` at gen end, then run 1 kill. | Purge slot: `2` with `gametime == 0.0` until/unless a LATER guarded stamp (W6-excluded in 1:1 → stays `0.0`); identical across 3 runs. Any invented purge tick = fail. |
| U-S7 | `bneutral`/diplomacy vs win team (mask-only actions) | Actions 18/20 mask-only, 19 merges (DEC-U-TEAMS §4, `scenario:3302-3306` refresh) — win law reads team only | 2v2 seed S + future trigger engine: fire action 18 between team-A mates, wipe team B. | Both A slots still `win` same tick (team ids unchanged) while mutually hostile at targeting layer; vision set UNCHANGED by the mask edit (only `bupdateally` refresh). Collapse = fail. |
| U-S8 | `net_IsOffline` trigger blackout after interface terminal | Condition 24 requires `myplind victorystate = none` (`scenario:1686-1688`) [O] | Mission-harness future: fire W10 `win` on `myplind`, then evaluate an `IsOffline`-gated trigger next tick. | Second trigger does NOT fire (blackout); 3 runs identical. Firing = gate bug. Until the trigger engine lands, port asserts nothing here. |

Forbidden: inventing any score/time-limit threshold, any per-mission trigger→victory mapping (U-F1 in DEC-U-SCENARIO-WIN §8 retained), any native VA, any LAN score/rating value, any camera constant.

---

## 9. Explicit non-claims and file discipline

- NO PARITY CLAIM. Resolved items rest on donor TEXT `[O]` with `file:line`; open items name exact next reads/captures in §8.
- No number invented: score has NO threshold, time limit has NO value, per-mission triggers are NOT listed (U-F1 forbids inventing any), `winnerteam` has no port value (port `winner` scalar stays PORT-ONLY), purge/console stamps carry NO tick.
- LAN/rating/profile/campaign tails (§6) are cited ONLY as exclusion boundaries — none is specified, audited, or changed.
- Read-only compliance: exactly one repo file written (this report). All donor evidence is text reads + the §0-P2 negative-write grep; donor binary never executed, never copied; no source/asset/config/test/runner/Godot/git state changed. Network excluded throughout.

*End of DEC-U-ENDGAME-STAMP.*
