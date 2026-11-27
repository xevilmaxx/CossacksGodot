---
id: DEC-U-ENDGAME-TEAM-DEEP
worker: DEC-U-ENDGAME-TEAM-DEEP (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. Donor binary never executed/copied/opened as a target. Donor DScript text read as text only. Byte search is a read of stored file bytes, never execution. No repo code/asset/config/Godot/git edit: this report is the only file written."
network: "OUT OF SCOPE. Net branches (_net_IsServer/Client/Replay/Online/Offline, Lan* parsers/sends/scores, lanid>0 fixups) are cited only to exclude them from the 1:1 sim contract."
parity: "NO PARITY CLAIM. No donor GPU A/B frame; no donor binary executed by this worker."
context: "Prior: _misc_CheckEndGame two-phase team win [O] (miscext2.script:3769-3844, first-transition stamps), SetupTeams forward-absorb [O], team-win precedence [O]; team hook/counter details partly [U]. THIS ticket attacks from NEW angles: packed CODE byte search with VAs, wrapper signatures/arity, native-only stamp-scope test, hidden-gate code-structure check."
labels: "[O] verbatim donor literal (file:line or VA) · [D] deterministic reading · [I] inference, flagged · [U] UNVERIFIED with exact experiment · PORT APPROXIMATION = port substitute to remove for 1:1"
---

# DEC-U-ENDGAME-TEAM-DEEP — packed CODE search, wrapper arity, native stamp-scope test, precedence-gate audit (2026-11-26)

## 0. Pin + pass ledger (every pass pinned `t_87f0f3c130b0`; donor read-only, never executed)

| # | Pass (read-only) | Result / evidence |
|---|---|---|
| P0 | Pin re-assert | `Get-FileHash` SHA256 `87F0F3C1…AF4E16C`, 5,768,048 B `[O]`. Binary never executed/copied/opened as a target. |
| P1 | `core_target_open` cossacks.exe | target `t_87f0f3c130b0`, kind `pe`, sha256 matches pin `[O]`. |
| P2 | `native_bytes_find` endgame identifiers (a): `_misc_CheckEndGame`, `_player_SetupTeams`, `SetupTeams`, `CheckEndGame`, `victorystate`, `victorystategametime`, `gfloat_peacetime`, `gbool_peacemode`, `ChangePlayer`, `SquadChangePlayer`, `winnerteam`, `GetPlayerIndexInterfaceIO`, `LanServerSendResults`, `LanCloseSessionSetScores`, `GetFirstLeaver` | 14× **0 hits**, 1× **1 hit** (`GetPlayerIndexInterfaceIO` @ `0x68da16`, CODE, ev_88341f11) §1. |
| P3 | Second sweep: `Surrender/MakeAlly/MakeEnemy/UpdateFOW/KillPlayerUnits/GetGameTime/victory/Victory/peacetime/Peacetime/peacemode/bleave/bexists/endgame_win/endgame_lose` | 1 hit only: `GetGameTime` @ `0x69faf6` CODE; all endgame field/routine names **0 hits** `[O-absence in stored bytes]` §1. |
| P4 | Third sweep (player-scope wrappers): `GetPlayerIndex/SetPlayer/GetPlayerHandle/GetPlayerTeam/SetPlayerTeam/GetPlayerVictory/SetPlayerVictory/PlayerSwitchTo/GetGameObject/ExecuteStateByHandle/SetProgressingPauseMode/WritePeaceTime/WriteFreeList/LanSendParser/ProgressPlayers` | `SetPlayer*` 61 hits from `0x68ccc2`; `GetGameObject*` 426 hits from `0x62caae`; `ExecuteStateByHandle` 9 hits from `0x63c4c4`; `PlayerSwitchToByHandle` 1 hit `0x69fbce`; `GetPlayerIndex*` 2 hits (`0x68da16`+`0x68f4e2`); `GetPlayerVictory/SetPlayerVictory/GetPlayerTeam/SetPlayerTeam/WritePeaceTime/WriteFreeList` **0 hits** §1/§2. |
| P5 | Fourth sweep: `Team/Winner/winner/Ally/Enemy/VictoryState/PlayerTeam/TeamEnemy/EnemyInfo/bleave/bexists/peacetime/PeaceTime/gbool/gfloat/gPlayer/gMap` + `SetPlayerIntValue/GetPlayerIntValue/SetPlayerFloatValue/ParserSetIntValue/PlayerExecuteState/SetPlayerControlMode/AddPlayerEnemy/AddPlayerFriend/DeletePlayerEnemy/MakeAlly/MakeEnemy/FOW/Minimap/MiniMap/Peace/Scenario/SwitchTo/Nothing/ProgressAI/CheckProgress` | `Enemy*` 49 hits (GO-logic family, `0x62daed…`); `Team` 3 hits (all LAN-client score/team strings, `0x68062e/0x680686/0x6814a8`); `FOW` 36 / `MiniMap` 61 / `Scenario` 20 / `SwitchTo` 38 / `Nothing` 1 (`0x4ab39d`); `Winner/winner/Ally/VictoryState/PlayerTeam/TeamEnemy/EnemyInfo/bleave/bexists/peacetime/PeaceTime/Peace/gbool/gPlayer/gMap/MakeAlly/MakeEnemy/ProgressAI/CheckProgress/WritePeaceTime/WriteFreeList` **0 hits**; `gfloat` 1 hit (`0x6e4876`, QueryMachine tag-float context, unrelated) §1. |
| P6 | Fifth sweep (re-own path): `SetGameObjectPlayer/GameObjectPlayer/ChangeOwner/SetOwner/Capture/SquadChange/PlayerCalcGroups/DelayExecuteState/CancelDelay/SetGameObjectValue` | `SetGameObjectPlayerHandleByHandle` 2 hits (`0x62ef7e`,`0x639d32`); `DelayExecuteState` 12 / `SetGameObjectValue` 2 / `Capture` 11; `ChangeOwner/SetOwner/SquadChange` **0 hits** §2. |
| P7 | `native_bytes_show` table windows: `0x68d800/0x68da00/0x68f400/0x68cc00/0x69fa00/0x693f00` + `0x691800/0x6a8000/0x69fd00/0x66ba00` + `0x680600/0x681400/0x62da80/0x6e4800` + `0x62ef00/0x639c00/0x63c500` | Full prototype runs transcribed §2 (ev_c4c401ef/ev_bfdbafbf/ev_69445d76/ev_ebe73f85/ev_e904a3b1/ev_613cedd6 + follow-ups) `[O]`. |
| P8 | Donor-text re-reads: `miscext2.script:3768-3845` CheckEndGame + `:3847-3896` Surrender; `player.script:2139-2173` SetupTeams; `miscext.script:892-959` `_misc_ChangePlayer`; `nothing.inc:83-107` head order + `:646-695` CheckEndGame/peacetime tail; `scenario.inc` full 99-line file | Verbatim law re-pinned §4; `_misc_ChangePlayer` calls `SetGameObjectPlayerHandleByHandle(goHnd, newPlHnd)` (`:915`) + counter re-link, no victorystate write `[O]` §2/§4. |
| P9 | Port `variant3d/scripts/game.gd` grep (read-only, no edit) | `_misc_check_end_game` `:8811`, defeat `:8886-8897`, surrender `:8936-8939`, `_check_victory` `:8955-8973`, save mirrors `:9078-9114` — cites only §5. |

Strange-read log `[D]`: `native_bytes_find` searches stored file bytes only — engine caveat "compressed, encrypted or packed regions and data built at run time are not seen, so no match is not proof of absence" applies to every 0-hit row. The 0-hits are therefore `[O-absence in stored bytes]`, never proof a routine/field does not exist. Same split as the blend worker (data-section index 0 hits vs CODE-embedded table hits) and tick worker (P2/P8): DScript-defined procedures (`_misc_*`, `_player_*`) and DScript field names (`victorystate`, `bexists`, `bleave`, `gPlayer`, `gMap`) live in the packed script store, while the CODE-embedded table holds engine `Get/Set*ByHandle` exports. No donor binary executed; no donor bytes copied.

---

## 1. (a) Packed CODE byte search — endgame names with VAs

### 1.1 Direct endgame identifiers: 14× absent in stored bytes, 1× present [O]

| # | Term | Hits (utf8+utf16le) | VA / location | Reading |
|---|---|---|---|---|
| A1 | `_misc_CheckEndGame` | 0 (ev_8056c6b9) | — | DScript-defined function; name in packed script store only `[O-absence]` |
| A2 | `_player_SetupTeams` | 0 (ev_c3248ef3) | — | same |
| A3 | `SetupTeams` | 0 (ev_dba34ac1) | — | same (substring of A2, still 0) |
| A4 | `CheckEndGame` | 0 (ev_43f0f86e) | — | same |
| A5 | `victorystate` | 0 (ev_8442a9b1) | — | `TPlayer` field name; script-store only |
| A6 | `victorystategametime` | 0 (ev_49246406) | — | same |
| A7 | `gfloat_peacetime` | 0 (ev_21707a3c) | — | global name; script-store only |
| A8 | `gbool_peacemode` | 0 (ev_4c191f2a) | — | same |
| A9 | `ChangePlayer` | 0 (ev_afeba522) | — | `_misc_ChangePlayer` is DScript (`miscext.script:894`); engine side is `SetGameObjectPlayerHandleByHandle` §2 |
| A10 | `SquadChangePlayer` | 0 (ev_f8ec66cc) | — | `_misc_SquadChangePlayer` DScript (`miscext.script:1189`); same engine path |
| A11 | `winnerteam` | 0 (ev_a0827f59) | — | **DScript local** (`miscext2.script:3809` `var winnerteam : Integer`), not a field/export |
| A12 | `GetPlayerIndexInterfaceIO` | **1** (ev_88341f11) | **`0x68da16`**, CODE, file-offset `0x28ce16` | engine export; table entry §2 |
| A13 | `LanServerSendResults` | 0 (ev_aa1a57c9) | — | `_misc_LanServerSendResults` DScript; engine side is `LanSendParser`-family §2 |
| A14 | `LanCloseSessionSetScores` | 0 (ev_1a6a8430) | — | `_misc_LanCloseSessionSetScores` DScript; engine side `LanSrvSetClientScore` §2 |
| A15 | `GetFirstLeaver` | 0 (ev_89e89772) | — | `_misc_GetFirstLeaver` DScript |

### 1.2 Control sweep: what IS in the CODE-embedded table [O]

| Term | Hits | First VAs | Note |
|---|---|---|---|
| `GetGameTime` | 1 | `0x69faf6` CODE | `function GetGameTime(): Float` — the stamp clock §2 |
| `GetPlayerIndex` | 2 | `0x68da16` (A12) + `0x68f4e2` (`GetPlayerIndexByHandle`) | A12 is the suffix-independent entry; `0x69069b` in tick-deep was the same-string suffix |
| `SetPlayer*` | 61 | `0x68ccc2…` cluster | generic key-value + control-mode wrappers §2 |
| `GetGameObject*` | 426 | `0x62caae…` | GO property/state wrappers, incl. re-own §2 |
| `ExecuteStateByHandle` | 9 | `0x63c4c4…` | GO-scoped delay states, NOT the player `ExecuteState('Scenario')` dispatcher |
| `PlayerSwitchToByHandle` | 1 | `0x69fbce` | `procedure PlayerSwitchToByHandle(plhandle: Integer; const state: String)` |
| `SetProgressingPauseMode` | 1 | `0x69fef6` | scenario query-break gate actuator |
| `LanSendParser` | 1 | `0x681afa` | net transport only — excluded |
| `ProgressPlayers*` | 9 | `0x693f89…/0x6a8894/0x71001f` | thread/priority/performance object (tick-deep §3 re-pinned) |
| `Enemy` | 49 | `0x62daed…` (GO `DoFindEnemyStateLogic`) | targeting logic, not the team matrix |
| `Team` | 3 | `0x68062e/0x680686/0x6814a8` | ALL are `LanPublicServerGetClientTeam*` / `LanClSetMyTeam` lobby strings — no sim-team accessor |
| `FOW` | 36 | `0x5da816…/0x6a80b5…` | `Get/SetFOWEnable`, `Add/ClearFOWPlayers`, `FOWBuildFull`, `SetFOWDovFunc` §2 |
| `MiniMap/MiniMap` | 61/4 | `0x5da83a/0x611f7f…/0x66ba6c…` | `SetGUIMinimapZoom`, `GUIMiniMapPrimitivesClear` neighbours — vision/minimap actuators |
| `Scenario` | 20 | `0x69fd44…` | `SetCurrentScenarioName/Index`, `Begin/EndPlayingCurrentScenario` §2 |
| `SwitchTo` | 38 | `0x62fd8e…` | state-switch family (`SwitchTo('Nothing'/'Scenario')` actuators) |
| `Nothing` | 1 | `0x4ab39d` | single stored-bytes hit; state name, not code |
| `gfloat` | 1 | `0x6e4876` | `QueryMachineResult*TagFloat` context — NOT the peacetime global |
| `SetGameObjectPlayer` / `GameObjectPlayer` | 2 / 4 | `0x62ef7e/0x639d32…` | re-own wrappers §2 |
| `SetPlayerIntValue/SetPlayerFloatValue/GetPlayerIntValue/ParserSetIntValue/PlayerExecuteState/SetPlayerControlMode/AddPlayerEnemy/AddPlayerFriend/DeletePlayerEnemy` | 1–3 each | `0x68ce66/0x68d1be/0x68cf26/0x6e8d0e/0x68d3a2/0x68d446/0x6918c6/0x69191a/0x69196e` | player/GO-scope native actuators §2 |

### 1.3 Zero-hit exclusion list (all `[O-absence in stored bytes]`, packed-region reserve) [O]

`Winner`, `winner`, `Ally`, `VictoryState`, `victoryState`, `PlayerTeam`, `SetPlayerTeam`, `GetPlayerTeam`, `GetPlayerVictory`, `SetPlayerVictory`, `TeamEnemy`, `EnemyInfo`, `bleave`, `bexists`, `peacetime`, `Peacetime`, `PeaceTime`, `Peace`, `victory`, `Victory`, `Surrender`, `MakeAlly`, `MakeEnemy`, `UpdateFOW`, `KillPlayerUnits`, `ProgressAI`, `CheckProgress`, `WritePeaceTime`, `WriteFreeList`, `ChangeOwner`, `SetOwner`, `SquadChange`, `gbool`, `gPlayer`, `gMap`.

Consequence `[D]`: no `SetPlayerVictory*/SetPlayerTeam*/GetPlayerTeam*` native export exists in stored bytes. Sim-team and victorystate are read/written as DScript record fields (`gPlayer[i].team`, `gPlayer[i].victorystate`) inside the packed script store — exactly why the script text (re-pinned §4) is the authoritative law and the native table contributes only generic handle/index/key-value/enemy-friend/GO actuators (§2).

---

## 2. (b) Wrapper signatures / arity for winnerteam / player-scope targets [O]

All prototypes below are byte-verbatim ASCII from the `native_bytes_show` windows cited; arity is counted from the parenthesised parameter list. `My`-prefixed forms act on the interface player; `ByHandle` forms take an explicit handle.

### 2.1 Interface-player / index wrappers (the `myplind`/`plInd` scope of W8–W11)

| VA (window) | Exact prototype [O] | Arity |
|---|---|---|
| `0x68d800` (ev_c4c401ef) | `function GetPlayerHandleByIndex(playerindex: Integer): Integer` | 1 |
| `0x68d800` | `function GetPlayerControlModeByIndex(playerindex: Integer): String` | 1 |
| `0x68d800` | `function GetCountOfPlayers(): Integer` | 0 |
| `0x68d800` | `function GetPlayerNameInterfaceIO(): String` | 0 |
| `0x68d800` | `function GetPlayerHandleInterfaceIO(): Integer` | 0 |
| `0x68da00` (ev_bfdbafbf) | `function GetPlayerIndexInterfaceIO(): Integer` | **0** (the W8/W9/W10/W11 `plInd` source; `_misc_Surrender :3851`, `scenario :1742`) |
| `0x68da00` | `procedure SetPlayerHandleInterfaceIO(const plhandle: Integer)` | **1** (`_control_SetPlayer` viewer switch, `control.script:712-720`) |
| `0x68f400` (ev_69445d76) | `function GetPlayerGameObjectsCountByHandle(playerhandle: Integer): Integer` | 1 (W1 kill-guard `:126` reader) |
| `0x68f400` | `function GetPlayerIndexByHandle(plhandle: Integer): Integer` | 1 (`_misc_ChangePlayer :896` re-own reader) |
| `0x68d892` region (P4) | `function GetPlayerHandleByIndex` / `GetPlayerNameByIndex/Set…` cluster | 1–2 |

### 2.2 Generic player key-value wrappers (the ONLY native player-field write path; 3-arg shape)

| VA (window) | Exact prototype [O] | Arity |
|---|---|---|
| `0x68cc00` (ev_ebe73f85) | `procedure SetPlayerValueByHandle(plhandle: Integer; const key: String; const value: String)` | 3 |
| `0x68cc00` | `function GetPlayerValueByHandle(plhandle: Integer; const key: String): String` | 2 |
| `0x68ce66/0x68d1be` | `procedure SetPlayerIntValueByHandle(plhandle: Integer; const key: String; value: Integer)` | **3** |
| `0x68cc00` | `function GetPlayerIntValueByHandle(plhandle: Integer; const key: String): Integer` | 2 |
| `0x68cf26/0x68d27e` | `procedure SetPlayerFloatValueByHandle(plhandle: Integer; const key: String; value: Float)` | **3** |
| `0x68cc00` | `function GetPlayerBoolValueByHandle(plhandle: Integer; const key: String): Boolean` / `procedure SetPlayerBoolValueByHandle(plhandle: Integer; const key: String; value: Boolean)` | 2 / 3 |
| `0x68cc00` | `procedure PlayerExecuteStateByHandle(plhandle: Integer; const state: String)` | **2** (`WriteFreeList`/`WritePeaceTime` peacetime actuators, `nothing.inc:681/685`) |

`[D]`: no `*Victory*` / `*Team*` specialisation of this family exists in stored bytes (§1.3). A port-side `SetPlayerIntValueByHandle(h, 'victorystate', v)`-style call would be a PORT MAPPING with no donor call-site — the donor writes `gPlayer[i].victorystate := …` directly in script. Do not invent one.

### 2.3 Enemy/friend + control-mode + GO re-own wrappers (Layer-B / ChangePlayer path)

| VA (window) | Exact prototype [O] | Arity |
|---|---|---|
| `0x691800` | `procedure AddPlayerEnemyPlayerByHandle(plhandle, enemyplhandle: Integer)` | 2 (trigger actions 18/20 engine-handle arm) |
| `0x691800` | `procedure AddPlayerFriendPlayerByHandle(plhandle, friendplhandle: Integer)` | 2 (action 20 neutral arm) |
| `0x691800` | `procedure DeletePlayerEnemyPlayerByHandle(plhandle, enemyplhandle: Integer)` | 2 |
| `0x691800` | `procedure DeletePlayerFriendPlayerByHandle(plhandle, friendplhandle: Integer)` | 2 |
| `0x691800` | `procedure ClearEnemyPlayersByHandle(plhandle: Integer)` / `procedure ClearFriendPlayersByHandle(plhandle: Integer)` | 1 |
| `0x68d446…` | `procedure SetPlayerControlModeByHandle(plhandle: Integer; const controlmode: String)` | 2 |
| `0x62ef00` | `procedure SetGameObjectPlayerHandleByHandle(const gohandle, newplayerhandle: Integer)` | **2** (the engine half of `_misc_ChangePlayer :915`; DScript mirrors `TObj(pl) := newPlInd` at `:917` + counter re-link `:914/:919`) |
| `0x639c00` | `procedure SetGameObjectPlayerNameByHandle(gohandle: Integer; const newplayername: String)` | 2 |
| `0x63c500` | `procedure GameObjectDelayExecuteStateByHandle(gohandle: Integer; const state: String; ftime: Float)` | 3 |
| `0x63c500` | `procedure SetGameObjectValueByHandle(gohandle: Integer; const key: String; const value: String)` | 3 |

`_misc_ChangePlayer` signature (DScript, `[O]` `miscext.script:894`): `procedure _misc_ChangePlayer(const goHnd, newPlHnd: Integer; const bCapture, bCustom, blan: Boolean)` — **5 params** (2 handles + 3 booleans); `_misc_SquadChangePlayer(pSquad: Pointer; newPlInd: Integer): Pointer` (`miscext.script:1189`) — **2 params**, returns Pointer. Neither name has a native CODE entry (§1.1 A9–A10): both are script-level, calling the 2-arg engine re-own above. The ChangePlayer path writes **no** `victorystate`/`team`/`bleave` field inline (`:892-959` — counters + `TObj.pl` + mine-insider recursion only).

### 2.4 Clock / scenario / FOW / LAN wrappers touching endgame order

| VA (window) | Exact prototype [O] | Arity |
|---|---|---|
| `0x69fa00` (ev_e904a3b1) | `function GetGameTime(): Float` | **0** (every `victorystategametime := GetGameTime` clock) |
| `0x69fa00` | `procedure SetGameTime(val: Float)` | 1 (no endgame writer calls it — listed to prevent confusion) |
| `0x69fbce` | `procedure PlayerSwitchToByHandle(plhandle: Integer; const state: String)` | 2 (`SwitchTo('Nothing'/'Scenario')` engine family) |
| `0x6a8000` | `function GetFOWEnable: Boolean` / `procedure SetFOWEnable(val: Boolean)` | 0 / 1 |
| `0x6a8000` | `procedure AddFOWPlayers(hnd: Integer)` / `procedure ClearFOWPlayers` | 1 / 0 |
| `0x6a8000` | `procedure SetFOWDovFunc(val: String)` | 1 (`_player_UpdateFOW :475`) |
| `0x6a8000` | `procedure FOWBuildFull` | 0 |
| `0x69fd00` | `procedure SetCurrentScenarioName/Index`, `Begin/EndPlayingCurrentScenario`, `SetProgressingPauseMode(value: Boolean)` | 1–2 |
| `0x681400` | `procedure LanSrvSetClientScore(aclientid: Integer; ascore: Integer)` | 2 (scores tail — excluded) |
| `0x681400` | `procedure LanClSetMyTeam(const ateam: Integer)` | 1 (lobby only — excluded) |

### 2.5 `winnerteam` scope verdict [O/D]

`winnerteam` is declared `var winnerteam : Integer` INSIDE `_misc_CheckEndGame` (`miscext2.script:3809`) — a procedure-local accumulator, assigned at `:3816` per stamped survivor and read once at the LAN-only guard `:3820` (`if (winnerteam>0)`). It has **no** field declaration in `classes.script` (`TPlayer` `:3674-3698`, `TMapPlayer` `:95-113`, `TEnemyInfo` `:4048-4092` — none contains it), **no** native CODE entry (§1.1 A11), and **no** wrapper prototype anywhere in the §2 windows. The 1:1 contract therefore keeps NO `winnerteam` field: the port `winner` scalar (`game.gd:8798-8811` region) stays labelled PORT-ONLY. The only donor-persistent per-survivor writes in the stamp loop are the two `TPlayer` fields `victorystate` (Integer) + `victorystategametime` (Float) — both script-store direct writes, both absent from the native table by construction.

---

## 3. (c) Per-player vs per-team win stamp — native-field-write test

**Verdict: NOT determinable from native field writes; determination rests on DScript text [O]. No native VA is claimed.**

- Native test performed: byte search for every spelling that could carry a native win/team write — `victorystate`, `victorystategametime`, `winnerteam`, `Winner/winner`, `VictoryState`, `PlayerTeam/SetPlayerTeam/GetPlayerTeam`, `TeamEnemy/EnemyInfo`, `bleave`, `bexists`, `gPlayer`, `SetPlayerVictory/GetPlayerVictory` — returns **0 hits in stored bytes** (§1.1/§1.3). There is no native field-write instruction sequence to attribute, hence no per-player/per-team scope triple (address, width, loop bound) can be byte-proven. Stating otherwise would invent a stamp.
- Script-law determination (unchanged, `[O]` `miscext2.script:3810-3818`): the win stamp loops `for i:=0 to gc_MaxPlayerCount-1` and writes **every** slot satisfying `gPlayer[i].bexists AND NOT gMap.players[i].bleave AND victorystate <> win` — i.e. **team scope**: all live non-leaver survivors of the single remaining sim team, never one picked winner. The LAN shadows (W6/W7 `:3820-3835`) are per-human fixups under `lanid > 0` — excluded from the 1:1 contract.
- What the native table DOES prove about scope `[D]`: all native player-scope actuators are addressed by **single-handle + key** (1-handle/2–3-arg, §2.1–§2.2) or **pair-handles** (2-arg enemy/friend, §2.3). No native export takes a team id and fans out to members — consistent with (but not proof of) the script-side loop being the only fan-out. The `Team`-named natives are lobby LAN strings only (§1.2), never the `gPlayer[].team` win-law key.
- Port consequence: `game.gd:8811-8861` stamps every live non-leaver non-win survivor — keep. Any single-`winner` pick would contradict the loop law; the `winner` scalar stays PORT-ONLY display state, never a gate on later stamps (§5-2).

---

## 4. (d) Hidden precedence gate audit — CheckEndGame vs peacetime expiry vs scenario triggers

Code-structure verdict: **no hidden gate exists.** The three paths are sequentially ordered in `nothing.inc` with disjoint read/write sets except the shared `GetGameTime` clock and the `bexists` liveness the win law legitimately consumes.

### 4.1 Global-tick order (verbatim, `nothing.inc`) [O]

| Step | Site | Gate | Reads | Writes |
|---|---|---|---|---|
| S1 Scenario triggers | `:103-107`: `if (gScenario.bactive) then begin if _net_IsOffline or (IsLanReady and gamemode=game and gamestage>waitingloading) then ExecuteState('Scenario')` | `bactive` + offline/ready | timers, trigger conditions (§4.2) | `myplind` win/lose stamps W10/W11 (future engine), `bupdateally`, one-shot deactivations |
| S2 Movie | `:108-109` | `gMovie.bstarted` | movie state | — (no endgame field) |
| S3 Projectile/pathing | `:111-…` | damage/queue state | — | — |
| S4 **CheckEndGame** | **`:647` `_misc_CheckEndGame;`** | **NONE — ungated** | roster `bexists` + sim `team` (phase 1); sim `bexists` + `bleave` + `team` (phase 2); `victorystate`/`gametime` | W5 team-win stamps (+LAN shadows + net tail) |
| S5 Topology flush | `:649-656` | `gInt_UpdateAreasCount > 0` | update rects | — |
| S6 **Peacetime expiry** | `:658-695`: `if (gbool_peacemode) and (gametime > gfloat_peacetime) and (not replay) and (not client)` | peacemode + clock + not-replay/client | `gbool_peacemode`, `gametime`, `gfloat_peacetime` | clears `gbool_peacemode`; destroys `ptborder` objects via `WriteFreeList`; broadcasts `WritePeaceTime`; `GameObjectRequestToDestroy`; minimap clear+refresh |
| S7 Perf/write tails | `:697-709+` | timers | `GetCurrentTime` | `WriteRes/WriteStats` — no endgame field |

### 4.2 Scenario-section internals (verbatim, `scenario.inc` 99 lines) [O]

Timers first (`:7-15`: `bfinished := True` when `(GetGameTime-starttime)*1000 >= time`), then triggers `0..511` in index order (`:18-90`): stamp `activetime` if `<= 0` (`:23-24`), battle-mode net-only pre-scan (`:33-64`) else first-real-condition break (`:66-67`), fire on `bConditionExists AND _scenario_CheckTriggerConditions` (`:71`) → one-shot deactivate (`bactive := False; activetime := 0`, `:73-74`) → `_scenario_EvaluateTriggerActions` (`:77`) → query-break (`:86-87`: `if (_net_IsOffline) and (GetProgressingPauseMode) then break`) → `UpdateAIRegionsActiveStateToTriggers` (`:91-92`) → `SwitchTo('Nothing')` (`:96`).

### 4.3 Pairwise gate checks — all negative [O/D]

1. **CheckEndGame → peacetime**: the `:647` call takes no return-value branch and sits 11 lines BEFORE the `:658` peacetime `if`. The peacetime condition reads NO `victorystate`/`winnerteam`/`bchanges` output — only `gbool_peacemode + gametime + gfloat_peacetime + replay/client`. No forward gate. `[D]`
2. **Peacetime → CheckEndGame**: peacetime expiry writes NO `bexists`/`bleave`/`team`/`victorystate` field (`:658-695` full read — zero stamp tokens). No backward gate. The port `_check_victory` peace-guard (`game.gd:8973` region, "peacetime expiry never wrote victorystate") is therefore harmless PORT policy, not donor law. `[D]`
3. **Scenario → CheckEndGame**: scenario actions CAN write `myplind` win/lose (W10/W11) and `bexists` (actions 80/81) and masks (18/20) / merges (19) — all consumed by LATER CheckEndGame passes in tick order S1→S4. That is intended data flow, not a hidden veto: NOTHING in `scenario.inc` or `:103-107` suppresses the `:647` call, and NOTHING in `miscext2.script:3775-3844` tests `gScenario.bactive`. The team-win law therefore fires in mission mode too (DEC-U-SCENARIO-WIN §4.5 re-pinned). `[D]`
4. **CheckEndGame → scenario**: the `:647` call precedes NO scenario code in the same tick (scenario ran at S1); it writes no timer/flag/trigger field the `:18-90` loop reads next tick except via the documented `net_IsOffline` condition-24 blackout (`scenario.script:1686-1688`: trigger gated on `myplind victorystate = none` stops firing once terminal — an [O] trigger-condition read, not a tick-scheduler gate). `[D]`
5. **Same-frame kill→lose→win**: per-player slice (staggered cadence, `progress.inc:56-141`) clears sim `bexists` + lose-stamps W1; global tail S4 reads the FRESH value the same frame. `win_tick >= lose_tick` is legal, same frame allowed — ordering invariant, no gate to add. `[D]`

Net-only neighbours excluded (cited as boundaries, never specified): `LanServerSendResults`/`LanCloseSessionSetScores` (`:3837-3842`), surrender net arms (`:3854-3887`), trigger actions 90-98, `WritePeaceTime/WriteFreeList` transport, `LanSendParser` (`0x681afa`), `LanSrvSetClientScore`/`LanClSetMyTeam` (`0x681400`).

---

## 5. Port change list — `game.gd` / `data.gd` (read-only inspection; COORD/owner applies; this worker wrote no code)

1. **`game.gd:8811` (`_misc_check_end_game`) — keep loop, harden comments.** The every-survivor loop (`:8856-8861`) already matches `:3810-3818` incl. the `<> win` skip (= the `lose→win` flip, annotate as such, not a bug). ADD: phase-1 roster gate must read roster-side `bexists` (not sim), phase-2 sim `bexists + bleave`; assert post-`_setup_teams` sim teams `>= 1` in debug. Keep `winner` scalar PORT-ONLY and NEVER early-return later stamps on it (W10/W11 overwrites must still land). Cite `miscext2.script:3768-3845`.
2. **`game.gd:8886-8897` (defeat) + `:8936-8939` (surrender) — match unconditional-overwrite shape.** Donor W8/W9/W10/W11 overwrite STATE unconditionally (time still `iff 0`); only W1/W5 are edge/inequality-guarded (DEC-U-ENDGAME-STAMP §3 re-pinned). If the port skips the state write when already terminal, change to always assign + keep the `== 0.0` time gate. Keep spectator `bleave` skip (purge W13 shape). Cite `miscext2.script:3847-3896 + scenario.script:2995-3064`.
3. **`game.gd:8955-8973` (`_check_victory`) — keep position (post-slice, `nothing.inc:646` analogue), keep peace comment.** No reorder vs peacetime expiry needed (§4.3-1/2 prove order-irrelevant: disjoint write sets). Do NOT add any `scenario_active ⇒ skip CheckEndGame` gate — donor runs it UNGATED in both modes (§4.3-3).
4. **No new native-mapped call.** §2 proves there is no `SetPlayerVictory/Team` export to wire: keep direct `players[i]` field writes. Do NOT add a `SetPlayerIntValueByHandle(h,'victorystate',…)` path — it would be an invented mapping with no donor call-site.
5. **Do NOT port**: debug-console `scenario win/lose` (`miscext2.script:3052-3058`), W6/W7 LAN-human fixups (`:3820-3835`), any §4-S7 net send/score/rating call, campaign/profile tails (`scenario.script:3002-3064`), `advanced_ifThenElse` stub, trigger net actions 90-98.

---

## 6. Still-[U] register — fixed-seed 2v2/FFA endgame captures, zero-mismatch termination

Seed convention (all rows): fixed seed S, map `land/med/plains`, peacetime index 0 (= 0 s), AI passive (no orders) unless the row says otherwise. `victorystate_int`: 0 none / 1 win / 2 lose (`dmscript.global:777-779`). `gametime` = donor `GetGameTime`, port `time_s`. Each run asserts tick-exact equality across 3 identical-seed runs AND the stated cross-condition. **Zero-mismatch termination: any single-tick or single-field divergence = FAIL — stop, file the diverging tick/field, no tolerance, no statistics. No parity claim is made by passing; passing only closes the row.** Owner-authorised donor runs only; never this worker. No invented stamp/order.

| # | Item | Static state after this ticket | Exact experiment | Zero-mismatch criterion |
|---|---|---|---|---|
| U-E1 | CheckEndGame same-frame ordering vs staggered exists scan | Order S1→S4 [O] §4; `win_tick >= lose_tick` legal [D] | 1v1 seed S: kill P1's last peasant/center at fixed tick T (port harness drives; donor owner replicates). Log `lose_tick` (W1) + `win_tick` (W5) + both `gametime` values. | 3 runs identical `lose_tick/win_tick/gametime` triple; `win_tick >= lose_tick` (same frame allowed). Any `win_tick < lose_tick` = ordering bug, terminate. |
| U-E2 | FFA last-man win (4-slot) | Law [O] §3 (every-survivor loop; distinct sim teams via SetupTeams) | 4-slot FFA lobby `[0,0,0,0]` seed S: eliminate slots in fixed order 3→2→1 (scripted kills, same tick offsets). | No `win` stamp while ≥2 live non-leavers; final survivor `int=1`, all others `2`; ticks identical across 3 runs. Early `win` = fail, terminate. |
| U-E3 | 2v2 shared-team win | Forward-absorb [O] (`player.script:2141-2173`) + loop [O] §3 | 2v2 lobby `[1,1,2,2]` seed S: wipe team B on fixed ticks. | BOTH team-A slots stamp `win` on the SAME tick; identical across 3 runs; no `win` before the last B-slot loss. Single-winner pick = fail, terminate. |
| U-E4 | Leaver exclusion + `lose→win` flip vs `win→lose` overwrite precedence | W5 `<> win` skip flips `lose→win`; W8/W9/W11 overwrite anything incl. `win→lose` [O] (ENDGAME-STAMP §3) | 2v2 seed S: (a) `_surrender` team-A slot 0 with units alive → surviving team-B stamps `win` same tick; leaver keeps `lose`, never flips. (b) Surrender one already-`win` slot → that slot `lose`, mate stays `win`, mate `gametime` UNCHANGED. | (a) leaver `2`, survivors `1` same tick; (b) first-write-wins time preserved. Any time overwrite or leaver flip to `win` = fail, terminate. |
| U-E5 | `winnerteam` has no observable | Local-only [O/D] §2.5 — no field, no export, no VA | 1v1 seed S, no kills for N ticks: assert NO stamp AND no LAN send. Then FFA wipe in fixed order. | No-write phase: zero `victorystate_int`/`gametime` deltas across 3 runs. Any port logic branching on `winner` scalar to suppress a later stamp = fail, terminate. |
| U-E6 | Peacetime/CheckEndGame independence | Disjoint write sets [O/D] §4.3-1/2 | Peacetime index 5 (60 s) + 1v1 kill at T < expiry and T > expiry, seed S. | Stamp ticks identical with/without pending peacetime; expiry tick identical with/without pending kills; border-destroy set identical. Any coupling = fail, terminate. |
| U-E7 | Scenario-trigger → CheckEndGame flow (mission harness future) | S1→S4 order [O] §4; trigger strikes `myplind` only [O] | Mission-harness future: fire W10 `win` on `myplind`, then wipe the opposing team. | Mates of `myplind` stamp `win` on the next S4 pass (team law), `myplind` time UNCHANGED (first-write-wins). Until the trigger engine lands, port asserts nothing here. |
| U-E8 | `net_IsOffline` trigger blackout after interface terminal | Condition 24 reads `myplind victorystate = none` (`scenario:1686-1688`) [O] | Mission-harness future: W10 `win` on `myplind`, then evaluate an `IsOffline`-gated trigger next tick. | Second trigger does NOT fire (blackout); 3 runs identical. Firing = gate bug, terminate. |
| U-N1 | Native team-routine VAs | [O-absence in stored bytes] §1 (packed-region reserve) | Owner-side debugger only: break on `victorystate` write in a 2v2 skirmish, back-trace to CheckEndGame/SetupTeams VAs. | VAs recorded with module+offset; no byte-patch, no binary copy. This worker asserts nothing native. |
| U-C1 | ChangePlayer re-own counters | 5-param DScript + 2-arg engine re-own [O] §2.3; no stamp inline | 1v1 seed S: capture (not kill) P1's last center via `unitsChangePlayer` path. | No `victorystate` delta from the capture alone; later wipe stamps normally. Any capture-stamp = fail, terminate. |

Forbidden: inventing any score/time-limit threshold, any per-mission trigger→victory mapping, any native VA, any LAN score/rating value, any camera constant, any `SetPlayerVictory/Team` wrapper call.

---

## 7. Explicit non-claims and file discipline

- NO PARITY CLAIM. Resolved items rest on donor TEXT `[O]` with `file:line` and on stored-byte table reads `[O]` with VA + evidence id; open items name exact next reads/captures in §6.
- No number invented: score has NO threshold, time limit has NO value, purge/console stamps carry NO tick, `winnerteam` has NO port field value (port scalar stays PORT-ONLY), no wrapper arity beyond the verbatim parenthesised lists in §2.
- Native-scope discipline: every 0-hit is labelled `[O-absence in stored bytes]` with the packed-region reserve — never "routine does not exist". The only positive native endgame-djacent VAs claimed are the engine-export table entries in §1.2/§2 (`0x68da16`, `0x68f4e2`, `0x69faf6`, `0x69fbce`, `0x68cc00`-family, `0x691800`-family, `0x62ef7e`, `0x63c500`-family, `0x6a8000`-family, `0x69fd00`-family, `0x681afa`, `0x681400`-family, `0x693f89`-family). No win/team/peacetime native VA is claimed because none was found.
- Read-only compliance: exactly one repo file written (this report). Donor binary never executed, never copied; no source/asset/config/test/runner/Godot/git state changed. Network excluded throughout.

*End of DEC-U-ENDGAME-TEAM-DEEP.*
