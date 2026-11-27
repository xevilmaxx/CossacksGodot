---
id: DEC-U-TEAMS
worker: DEC-U-TEAMS (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c, entry RVA 0x4f1a08 (= VA 0x8f1a08)"
donor: "READ ONLY. Donor binary never executed/copied/opened as a target. Donor DScript text read as text only (byte-level probe of the binary for identifier strings is a read, not an execution). No repo code/asset/config/Godot/git edit: this report is the only file written."
network: "OUT OF SCOPE. Net branches (_net_IsServer/Client/Replay, Lan* parsers, lanid>0 fixups, rating/autosearch quick-play force) are cited only to exclude them from the 1:1 sim contract."
parity: "NO PARITY CLAIM. No donor GPU A/B frame; no donor binary executed by this worker."
context: "DEC_U_scenario_win.md proved donor team-win is `_misc_CheckEndGame` and `_player_SetupTeams` maps FFA team-0 to distinct sim teams vs shared map-team to shared sim win; port `game.gd` now uses `_sim_team`, two-phase check, but team setup details may be approximated. THIS ticket recovers the full setup law statically."
labels: "[O] verbatim donor literal (file:line) · [D] deterministic reading · [I] inference, flagged · [U] UNVERIFIED with exact experiment · PORT APPROXIMATION = port substitute to remove for 1:1"
---

# DEC-U-TEAMS — team id enumeration, FFA expansion, ally/enemy matrix, vision, win/defeat stamping, lobby mapping (2026-11-26)

## 0. Pin + pass ledger (every pass pinned `t_87f0f3c130b0`; donor read-only, never executed)

| # | Pass | Result / evidence |
|---|---|---|
| P1 | Pin re-assert | `C:\Games\Cossacks 3\cossacks.exe`, 5,768,048 B, sha256 `87f0f3c130b0…4e16c` (first-16 re-hashed this session, full hash matches DEC-U-SCENARIO-WIN), `MZ` + `e_lfanew=256`, `PE\0\0`, i386, 10 sections, entry RVA `0x4f1a08` (= VA `0x8f1a08`, matches scenario-win report). Binary never executed/copied/opened as a target. |
| P2 | Native identifier probe (read-only byte scan, NOT execution) | `EV-N`: ASCII **and** UTF-16LE counts for `CheckEndGame / SetupTeams / TEnemyInfo / enemyPlMask / bleave / victorystate / curTeam / gPlayer / peacemode` are all **0** — DScript identifiers are not embedded as plain tokens (compiled/packed script store). Consequence: **no native VA for any team routine is statically recoverable** → [U]-N1 (§9). PE header fields above are the only native [O]. |
| P3 | `_player_SetupTeams` verbatim | `EV-T1`: `lib/player.script:2139-2173` full procedure + nested `GetTeam` (§2). |
| P4 | SetupTeams caller census (whole script tree) | `EV-T2`: exactly 2 script callers — `common.inc/dogenerate.inc:2052` (`SetupTeams(true)`) and `common.inc/initmap.inc:66` (`SetupTeams(false)`); zero callers in `lib/*.script` (§3). |
| P5 | Team-id defaults + reset law | `EV-T3`: `player.script:110-117` (`victorystate:=none`, `enemyplmask:=255 xor (1 shl id)`, `myplmask:=(1 shl id)`, **`team := 0`**); `map.script:118-152` `_map_ResetMapPlayer`; `map.script:156-337` `_map_ResetMapSettings` quick-play/singleplayer/lobby-cap branches (§1/§7). |
| P6 | Ally/enemy mask layer | `EV-M1`: `initmapgen.inc:144,154-165` + `initmap.inc:48-64` + `serial.script:83-94,164-175` enemy/friend loops; `EV-M2`: `player.script:2175-2271` `_player_MakeAlly / _player_MakeEnemyForAll / _player_MakeEnemy` verbatim (§4). |
| P7 | Trigger-time team/diplomacy mutation | `EV-M3`: `scenario.script:2175-2249` actions 18/19/20 (`playerSetAsEnemy/Ally/Neutral` — mask-only except MakeAlly) + action 21 `unitsChangePlayer` squad path (`:2250-2309`) + actions 80/81 enable/disableAI bexists writes (`:2310-2325`) (§4). |
| P8 | Shared vision / FOW | `EV-V`: `player.script:451-478` `_player_UpdateFOW` verbatim (§5). |
| P9 | Win/defeat stamping | `EV-E` (re-pinned, not re-derived): `miscext2.script:3768-3845` `_misc_CheckEndGame` + `:3847-3896` `_misc_Surrender`; `EV-F`: `initmapgen.inc:256-264` spectator purge; `miscext2.script:3043-3060` debug-console `scenario win/lose`; `initmaphistoricalbattle.inc:124-129` forced `bexists:=True` + victorystate clear (§6). |
| P10 | Lobby map-team input mapping | `EV-L1`: `misc.script:5810-5837` `_misc_SetClLanTeamByIndex` (incl. `gc_MaxPlayerCount+plind+1` FFA encoding + rating/autosearch force); `EV-L2`: `miscext2.script:2503-2520` battle auto-balance `1/2`; `EV-L3`: `miscext2.script:2550-2642` `SetMapFromName` field index `j=2 → team`; `EV-L4`: `map.script:140-150,257-270` quick-play `1/2` + closed slots (`team:=0, bclosed:=True`); `EV-L5`: `map.script:235-245` singleplayer force slots 0/1 (§7). |
| P11 | Record + enum census | `EV-C`: `classes.script:95-113` `TMapPlayer` (team/bexists/bhuman/bclosed/bleave/lanid…), `:3674-3698` `TPlayer` (team/enemyplmask/myplmask/victorystate/stamp/bexists/bneutral…), `:4048-4092` `TEnemyInfo` (team/enemyMask/changed), `dmscript.global:97-102,776-779,1649-1651,1665` (`MaxPlayerCount=12`, `MaxNonSpectators=8`, `mercenaryind=11`, victorystate `0/1/2`, quick-play counts, `spectator_countryid=-2`) (§1). |
| P12 | Port approximation audit (read-only, no edit) | `EV-P`: `game.gd:478-494` (`new_player` `team:-1`), `:600-616` (setup_begin `Data.TEAMS`), `:4043-4055` (`_is_ally`), `:8271-8370` (`_sim_team/_misc_check_end_game/_surrender`), `:8376-8416` (`_player_bexists/_check_player_exists`), `:8426-8468` (`_check_victory`); `data.gd:572-592` (`PLAYER_COUNT/TEAMS/PLAYER_AI/MAX_PLAYERS=12`), `:270-296` (victory surface) (§8). |

DSL note `[D]`: donor `not X` on a numeric lvalue is the current-value read, not negation (inherited).

---

## 1. Team id enumeration — the two records and every literal default [O]

`EV-C` (`classes.script:95-113`, `3674-3698`, `dmscript.global:97-102,776-779,1649-1665`):

- Slots: `gc_MaxPlayerCount = 12` (`dmscript.global:97`); playable cap `gc_MaxNonSpectatorsCount = 8` (`:98`); slot 11 is `gc_player_mercenaryind` (`:776`); spectator nation is `gc_spectator_countryid = -2` (`:1665`); victorystate table `none = 0, win = 1, lose = 2` (`:777-779`); quick-play sizes `2/4/6` (`:1649-1651`).
- Lobby record `TMapPlayer` (`:95-113`): `id, cid, csid, name, team, color, lanid, startx, starty, aidifficulty, bexists, bai, bhuman, bclosed, bready, bloaded, bleave`. **Lobby team lives here** (`gMap.players[i].team`).
- Sim record `TPlayer` (`:3674-3698`): `…, victorystate, victorystategametime, …, myplmask, enemyplmask, team, difficulty, bexists, …, bneutral, …`. **Win-law team lives here** (`gPlayer[i].team`).
- Enemy aggregate `TEnemyInfo` (`:4048-4092`): `team, enemyMask, changed, enabled, …`; list `gEnemyInfoList` rebuilt by SetupTeams; lookup is **by team, not by player** (`misc.script:3003-3026` `EV-M4`: `_misc_GetTeamEnemyInfo` scans for `TEnemyInfo.team = team`; `_misc_GetPlayerEnemyInfo(plInd)` = team-info of `gPlayer[plInd].team`).
- Reset default `[O]` (`player.script:110-117`, inside `_player_Init`): `victorystate := none`, `victorystategametime := 0`, `enemyplmask := 255 xor (1 shl id)`, `myplmask := (1 shl id)`, **`team := 0`**, `bexists := False`, plus `bai/bneutral := False` (`:119-124` region). So **sim-team 0 is the pre-setup sentinel**, not a playable alliance.
- Menu-frame default `[O]` (`map.script:118-152`): `_map_ResetMapPlayer` zeroes the whole `TMapPlayer` record, then `id := ind; color := ind`. Non-quick-play path leaves `team = 0` (zero-init). Quick-play (`bQuickPlay`, `:138-151`): slots `>= gint_quickplay_countofplayers` get `team := 0, bclosed := True` (and `bclosed` for `ind < MaxPlayerCount-1`); slots below split `team := 1` (first half) / `team := 2` (second half). `map.script:257-270` repeats the same law in `_map_ResetMapSettings`.

**Enumeration law [D]**: legal lobby values are `0` (unset/FFA, also reused for closed slots) and positive ids (`1, 2, …`, LAN FFA uses `gc_MaxPlayerCount+plind+1`, §7). Legal sim values after setup are `>= 1` (SetupTeams only ever assigns `curTeam = 1, 2, …`); sim `0` survives only for slots SetupTeams never visits — and it visits **every** slot whose sim team is still `0` (§2), so post-setup sim `0` means "slot never initialised", never an alliance.

---

## 2. `_player_SetupTeams` — the exact FFA-expansion law [O]

`EV-T1` verbatim, `lib/player.script:2139-2173`:

```
procedure _player_SetupTeams(mapInfo : Boolean);
   function GetTeam(ind) : Integer;
      if mapInfo then Result := gMap.players[ind].team
      else Result := gPlayer[ind].team;
   gEnemyInfoList.Clear;
   var curTeam : Integer = 1;
   for i := 0 to gc_MaxPlayerCount-1 do
   if gPlayer[i].team = 0 then              // sentinel scan over SIM teams
   begin
      gPlayer[i].team := curTeam;           // (a) claim next sim team
      var pEnemyInfo : Pointer = gEnemyInfoList.Add;
      TEnemyInfo(pEnemyInfo).team := curTeam;
      TEnemyInfo(pEnemyInfo).enemyMask := gPlayer[i].enemyPlMask;
      var myTeam : Integer = GetTeam(i);    // (b) lobby (mapInfo) or sim (!mapInfo) key
      if myTeam > 0 then
         for j := i+1 to gc_MaxPlayerCount-1 do
         if GetTeam(j) = myTeam then
         gPlayer[j].team := curTeam;        // (c) absorb later mates, forward only
      curTeam := curTeam+1;                 // (d) ALWAYS increments, even for FFA singletons
   end;
```

Deterministic consequences [D] (no behaviour invented — direct reads of (a)–(d)):

1. **FFA (all lobby teams 0)** ⇒ the `(c)` branch never fires; every slot with sim-team 0 takes its own `curTeam`. 8-player FFA ⇒ sim teams `1..8`. This is the "FFA expansion": **lobby `0` never survives as a shared sim alliance**.
2. **Shared lobby team N>0** ⇒ the first slot (in index order) claiming `curTeam` absorbs every later slot with the same lobby key into that `curTeam`, **including slots whose sim team was already non-zero** (assignment (c) is unconditional — no `= 0` guard on `j`). Earlier-index slots with a *different* key keep their own earlier `curTeam`.
3. **Forward-only absorption**: a slot `j` is absorbed only by the earliest claimant `i < j` with the same key. A later slot can never pull an earlier slot into its team.
4. **`curTeam` increments per outer-loop hit**, so absorbed mates "consume" no extra number but the number still advances past them: e.g. lobby `[1,1,2,2]` (sim pre-state all 0) ⇒ `i=0` claims 1, absorbs 1; `i=1` skipped (now 1); `i=2` claims **2**, absorbs 3 ⇒ sim `[1,1,2,2]` — numbers coincide here, but lobby `[1,0,1]` ⇒ `i=0` claims 1 absorbs 2; `i=1` skipped; ⇒ sim `[1,1,…]` with `curTeam=2` for the next claimant. Lobby keys are **labels**, sim ids are **dense assignment order** — never equate them numerically.
5. **`gEnemyInfoList` gets exactly one entry per outer-loop hit** (i.e. per sim team), snapshotting the claimant's `enemyPlMask` at setup time. AI danger/attract bookkeeping is therefore **per sim team** (`_misc_GetPlayerEnemyInfo` resolves through the player's current team, `EV-M4`).
6. **Slots with pre-set non-zero sim team are skipped by the outer scan** (`if gPlayer[i].team = 0`), but can still be absorbed by (c). In the `mapInfo=false` path `GetTeam` reads those same sim values, so pre-seeded sim teams act as their own grouping keys.
7. Pre-setup sim `0` on a slot that is roster-absent (`gMap.players[i].bexists = False`) is still processed — SetupTeams does **not** consult `bexists`. Roster gating happens later, in CheckEndGame phase 1.

Worked 2v2 / FFA traces [D] (labels only, from (a)–(d)):

| Lobby `gMap.players[].team` (slots 0..3) | Sim result `gPlayer[].team` | Winner set on full wipe of one side |
|---|---|---|
| FFA `[0,0,0,0]` | `[1,2,3,4]` | last live non-leaver alone |
| 2v2 `[1,1,2,2]` | `[1,1,2,2]` | both survivors of the live team |
| 2v1 menu `[0,0,1]` (map-frame shape; post-setup) | slot with lobby 1 absorbs forward; lobby-0 slots each take own ids | the two ex-0 singletons are mutual enemies |

Port note (anticipated §8): the port's `_sim_team` maps negative→unique and keeps `0` shared. Donor-faithful input mapping must therefore translate lobby `0` (unset/FFA) to "each slot its own team" **before** the win law runs, while preserving a real shared `0` only where the donor menu literally leaves closed-slot `0`s — which CheckEndGame ignores anyway via the roster gate.

---

## 3. Setup callers — which key (`mapInfo`) runs where [O]

`EV-T2`: only two script call sites in the whole `data/scripts` tree:

- `common.inc/dogenerate.inc:2052`: `_player_SetupTeams(true)` — the **skirmish/random-map path**. Runs after per-slot `bai/centerfound/basenation/progressTick` init (`:2030-2050`), before peacetime/border/fill (`:2054-2068`). Key = **lobby** `gMap.players[].team`.
- `common.inc/initmap.inc:66`: `_player_SetupTeams(false)` — the **mission/editor path** (`InitMap`: `ResetMapSettings(single, …)` → `ResetProgressPlayer` → `CreatePlayers` → `ResetGameData` → enemy-mask loops `:43-64` → `SetupTeams(false)` → `_control_SetPlayer`). Key = **sim** `gPlayer[].team` as pre-seeded by the mission/editor (init loops read `gMap.players[].team` for masks, but the grouping key is sim-side).

[D]: in skirmish the lobby team row the player edits in the menu IS the grouping key; in missions the grouping key is whatever the mission setup left in sim teams (normally all `0` → each slot its own team unless the mission pre-sets shared sim teams — no such pre-setter is readable in `initmaphistoricalbattle.inc`, which forces `bexists:=True` for all slots but never writes `team`, `EV-F`).

---

## 4. Ally/enemy matrix — two layers, exact mutation law [O]

There are **two distinct layers**. Never conflate them (ports that equate "ally" with "same team id" get trigger diplomacy wrong):

**Layer A — team id** (`gPlayer[].team` + `TEnemyInfo.team`). Read by: CheckEndGame both phases (`miscext2.script:3776-3811`), FOW sharing (`player.script:464-473`), `CountOfPlayersTeamUnitsInZone` condition 31 (`scenario.script:1517-1555` reads `gPlayer[TObj.pl].team = gPlayer[player].team`), `net_CurrentPlayerTeam` condition 27 (`:1702-1706` reads `gMap.players[myplind].team` — lobby side), `GetTeamPlayersCount` (`player.script:2130-2137`). Mutated by: SetupTeams (§2), `_player_MakeAlly` (merge), `_player_MakeEnemyForAll` (extract), spectator purge (no team write — slot leaves the matrix via `bexists:=False + bleave:=True + lose`, `initmapgen.inc:256-264`).

**Layer B — enemy masks + engine friend/enemy handles** (`gPlayer[].enemyplmask/myplmask` + `Add/DeletePlayerEnemy/FriendPlayerByHandle`). Read by targeting/AI (`control.script:225`, `ai.script:786-1411`, `miscext*.script` scan loops). Built at gen/mission init by pairwise loops with the **FFA-safe rule** `[O]` (`initmapgen.inc:154-165`, identical in `initmap.inc:52-64`, `serial.script:83-94,164-175`):

```
if (myteam <> histeam) or (histeam = 0) or (myteam = 0) then ENEMY(+mask bit, AddEnemy)
else FRIEND(+AddFriend)
```

[D]: lobby `0` vs anything ⇒ enemy, **even `0` vs `0`**. This pre-setup mask pass already encodes FFA hostility; SetupTeams afterwards only renumbers team ids (masks are NOT rewritten by SetupTeams except via the fresh `TEnemyInfo.enemyMask` snapshot).

Runtime mutations [O]:

- `_player_MakeAlly(plInd1, plInd2)` (`player.script:2177-2211`): **merges team ids** — every slot on either team takes `team1`; their `enemyPlMask` := complement mask; the absorbed team's `TEnemyInfo` is `Reset`, winner's updated + `changed := true`. Guard: no-op if already same team. ⇒ This is the ONLY runtime op that changes the win-law grouping.
- `_player_MakeEnemyForAll(plInd)` (`:2215-2259`): **extracts one slot** to the first empty team id `1..MaxPlayerCount` (error-log if none free), rebuilds its `TEnemyInfo`, rewrites old-mates' masks. Guard: no-op for singleton teams. `_player_MakeEnemy(a,b)` (`:2261-2271`): only if same team, extracts BOTH (two calls — they may land on different fresh teams).
- Trigger `playerSetAsEnemy` (action 18, `:2175-2197`): **mask + engine handles ONLY** — sets both mask bits, deletes friend links, adds enemy links. The two `_player_MakeEnemy` call forms are **commented out** (`:2176-2179`) — team ids UNCHANGED. `bneutral := False` on slots involving player 0. Sets `bupdateally` if the interface player is involved.
- Trigger `playerSetAsAlly` (action 19, `:2198-2224`): calls **`_player_MakeAlly`** (`:2202` — team merge, real) AND clears mask bits AND rewrites engine links. `bneutral := False` on slots involving player 0.
- Trigger `playerSetAsNeutral` (action 20, `:2225-2249`): **mask + engine handles ONLY** (clears bits, adds FRIEND links — neutral behaves as friend at the engine layer), sets `bneutral := True` for non-zero slots when 0 is involved. Team ids UNCHANGED. FOW interaction: slot 0 does not share vision with `bneutral` mates (§5).
- Trigger `unitsChangePlayer` (action 21, `:2250-2309`): re-owns squads/units, no team/mask write inline. Enable/disableAI (actions 80/81, `:2310-2325`): `bexists := True` on enable (no team write).
- Scenario conditions 26/28/29 read **lobby-side** `gMap.players` (`:1693-1723`); condition 31 reads **sim-side** team (§2 of scenario-win report).

[D] matrix summary for the port: maintain BOTH `team:int` (win/FOW/AI key) and `enemy_mask:int + friend/engine set` (targeting key). Trigger set-enemy/neutral must NOT rewrite `team`; set-ally MUST (merge). FFA init must mark every pair mutual enemies even though post-setup sim teams are all distinct (both layers agree, but they are computed independently).

---

## 5. Shared-vision / FOW implications [O]

`EV-V` verbatim, `player.script:453-478`:

```
procedure _player_UpdateFOW(plInd);
   bFOW := True;
   if (gPlayer[plInd].bballoon) or (gMap.settings.additional.balloon = with)
      or (gPlayer[plInd].victorystate <> none) then bFOW := False;
   if (not gbool_editor_fogofwar) then bFOW := False;
   ClearFOWPlayers;
   if (bFOW) then
      AddFOWPlayers(self);
      for i: if (i<>plInd) and (gPlayer[i].team = team) then
         //if ((not gScenario.bactive) or (plInd<>0)) or ((plInd=0) and (not gPlayer[i].bneutral)) then
         if (plInd<>0) or (not gPlayer[i].bneutral) then AddFOWPlayers(i);
      SetFOWDovFunc('_unit_GetVision');
   SetFOWEnable(bFOW);
```

Law [D]:

1. Vision is shared with **same sim-team mates** (the post-SetupTeams ids), not lobby ids.
2. Slot 0 (the mission/interface slot) does NOT receive vision from `bneutral` mates; any other slot shares with all same-team mates regardless of `bneutral`.
3. FOW is disabled entirely (full map vision) when: the slot owns a balloon, **or** the map balloon option is "with", **or** the slot has ANY terminal victorystate (`<> none` — a winner or loser sees everything), **or** editor fog is off. Defeat/win therefore also flips vision — a second, silent consequence of the §6 stamps.
4. Called from init paths and team-change paths (`player.script:1913,1921` region; `serial.script:276,286` post-compat `UpdateFOW`). Port FOW (if any) must re-resolve sharing on every team-id merge/split (§4) and on every victorystate transition, not only on setup.

---

## 6. Team-based win/defeat stamping [O]

- **Defeat is per-player; win is per-team.** Exists collapse (`units/global.inc/progress.inc:71-135`, re-pinned P9 of scenario-win) clears sim `bexists`, kills units, and on first transition stamps that slot `lose` (+ `gametime` iff 0). The whole slice is gated by `not gScenario.bactive` (`:54`) — missions never auto-defeat. `CheckEndGame` (`miscext2.script:3776-3844`) then crowns **every live non-leaver non-win slot** `win` (+ stamp iff 0) when exactly one sim team remains live; roster gate reads `gMap.players[].bexists` + sim teams, live gate reads sim `bexists` + `not bleave` + pairwise team inequality. No `winnerteam` write on the empty path (var zero-init; `winnerteam > 0` guard deterministically false — port `-1` init is equivalent, tagged in §8).
- **Surrender** (`:3849-3895`): sets caller `bleave := True` (unless spectator), stamps caller `lose` (+ iff 0; server/offline paths), then runs `CheckEndGame` — so a surrender can immediately crown the surviving team in the same call.
- **Spectator purge** (`initmapgen.inc:256-264`): roster spectator slots get `bexists := False` (both records) + `bleave := True` + `victorystate := lose` with **no timestamp guard** (unconditional write — differs from the guarded first-transition stamps).
- **Historical battle** (`initmaphistoricalbattle.inc:124-129`): all slots `bexists := True`, victorystate cleared — team law then decides purely on later kills/surrenders.
- **Debug console** (`miscext2.script:3052-3058`): `scenario win/lose` writes `gPlayer[0]` directly, no guard, immediate `exit` — tooling path, never a sim rule; port must not wire it.
- **Scenario trigger win/lose** (`scenario.script:2995-3064`): always strikes `myplind` only (interface slot), never a team — the team-wide stamp comes solely from CheckEndGame.

---

## 7. Lobby map-team input mapping [O + U]

Resolved [O]:

| Input | Donor law | Address |
|---|---|---|
| Menu frame default | zero-init record; non-quick-play leaves `team = 0` | `map.script:118-133` |
| Quick-play split | first half `team := 1`, second half `team := 2`; overflow slots `team := 0, bclosed := True` | `map.script:138-151, 257-271` |
| Singleplayer force | slot 0 `bexists+bhuman`, slot 1 `bexists+bai+easy` (teams untouched → whatever frame held) | `map.script:235-245` |
| Non-single/non-quick/non-rating tail | slots `8..11` reset via `_map_ResetMapPlayer(...,true)` | `map.script:315-334` |
| LAN client team pick | `_misc_SetClLanTeamByIndex`: rating/autosearch ⇒ forced `1/2` by slot half; else `0` ⇒ `gc_MaxPlayerCount+plind+1` (unique FFA keys `13..24`), else literal `team` | `misc.script:5812-5837` |
| LAN room string | field `j=2` parses to `map.players[i].team` (human `lanid,cid,team,color,ready`; AI `-aidifficulty,cid,team,color`) | `miscext2.script:2579-2610` |
| Battle-mode join | auto-balance to the smaller of team 1 / team 2 counts | `miscext2.script:2503-2520` |
| Serial-compat re-link | engine friend/enemy handles rebuilt with the §4 FFA-safe rule (`0` vs anything = enemy) | `serial.script:83-94,164-175` |

Still engine/GUI-side [U]-L1: the actual lobby click → `gMap.players[i].team := N` write (and the `settings.additional.teams` count row, `:2639`) lives in GUI/engine code with no readable DScript writer — `Select-String '\.team :='` over `lib/*.script` returns only the rows tabled above. Experiment in §9 (U-L1) pins it without inventing.

[D] FFA encoding census: lobby `0` (menu unset / quick-play-closed / default) and lobby `13..24` (LAN FFA unique keys) BOTH mean "no alliance", but travel different SetupTeams paths: `0` takes the §2(a)+(d) singleton expansion; `13..24` are positive distinct keys that never match each other, so each slot still takes its own `curTeam` via the same loop — identical sim outcome, distinct wire form. A port that collapses `13..24 → 0` before SetupTeams is behaviour-identical; a port that collapses `0 → unique` AFTER SetupTeams but compares `0 == 0` as allied anywhere (targeting, FOW, win gate) is wrong.

---

## 8. Port change list — `game.gd` / `data.gd` (no edits made; COORD/owner applies)

Current approximation `EV-P` (read-only): `new_player` defaults `team:-1` (`game.gd:484`) with FFA = negative-is-unique; `setup_begin` overwrites from `Data.TEAMS` (`:614-616`); `_is_ally` requires both `>= 0` and equal (`:4046-4055`); `_sim_team` maps `< 0 → -(pi+2)` unique, `>= 0` compared by equality (`:8286-8288`); two-phase `_misc_check_end_game` + `_surrender` + `scenario_active` split + serialize of `roster_bexists/bleave/stamp` all landed (`:8290-8585`); `Data.TEAMS` default `[]`, `MAX_PLAYERS = 12` PORT EXTENSION vs donor non-spectator cap 8 (`data.gd:575-585`); victory surface `VICTORY/SCORE_LIMIT/PORT_EXTENSION_SCORE_VICTORY` (`data.gd:287-296`).

Required changes (file:line = port edit site; donor cite = behaviour source):

1. **`game.gd:614-616` (setup_begin) — run the §2 law instead of copying lobby ids.** Add `_setup_teams(map_info: bool)` mirroring `player.script:2141-2173`: iterate slots in index order over the *sim* `team` field initialised from `Data.TEAMS` with **unset/FFA normalised to `0` first** (port `-1` → `0` at this boundary, then forget `-1`); `cur := 1`; per outer hit assign + snapshot enemy entry; absorb forward on equal lobby key `> 0`; always `cur += 1`. `map_info=true` = skirmish path (`dogenerate.inc:2052`); keep a `false` variant for mission/editor loads (`initmap.inc:66`). Donor cite `player.script:2139-2173`.
2. **`game.gd:8286-8288` (`_sim_team`) — delete the negative-unique branch after (1).** Post-setup sim teams are `>= 1`; `_sim_team` becomes a plain field read. Keep the function as the single accessor (win gate, FOW, AI) so the §4 layer-A key has one source. Donor cite `player.script:2158,2168`.
3. **`game.gd:4046-4055` (`_is_ally`) — add the two-layer model.** Keep team-equality for the win/FOW key, but add a per-pair `enemy_mask: int` (+ friend set where engine handles exist) initialised with the §4 FFA-safe rule (`0` vs anything = enemy) at setup (`initmapgen.inc:154-165`), mutated ONLY by: MakeAlly-merge (§4, team ids + masks), MakeEnemy-extract (§4), trigger 18/20 mask-only edits and trigger 19 MakeAlly call (`scenario.script:2175-2249`). Until the trigger engine lands, expose `set_ally(a,b)/set_enemy(a,b)/set_neutral(a,b)` stubs that implement exactly those mask/team writes and NOTHING else. Donor cite `player.script:2175-2271 + scenario.script:2175-2249`.
4. **`game.gd:8376-8398` (`_player_bexists`) — keep, annotate gap.** Tag-test `visual_none+essential_none` → port `not dead and not hidden` stays PORT APPROXIMATION; human-inside-transport branch already keys on `not is_ai` (matches `(gMap.players[plInd].bhuman)`, `progress.inc:100`). Donor cite `units/global.inc/progress.inc:89-123`.
5. **`game.gd:8290-8351` (CheckEndGame) — two corrections.** (a) Phase-1 gate must ALSO require the sim-team comparison over rostered slots only — landed; but `first_team` init `0` collides with a real sim team only if a pre-setup `0` leaks — after (1) impossible; assert `>= 1` in debug. (b) `winner` scalar/`game_over.emit` stays port-only (no donor field); keep, labelled. Donor cite `miscext2.script:3775-3844`.
6. **`game.gd:8356-8370` (`_surrender`) — keep, add spectator guard.** Donor skips `bleave` for spectators (`miscext2.script:3852-3853`); port should too once spectators exist. Donor cite `:3847-3895`.
7. **`data.gd:583-585` (`TEAMS`) — document the wire encoding.** Comment: `[]/absent = all lobby 0 (FFA)`; LAN `13..24` unique keys collapse to distinct singles identically to `0` (§7-[D]); closed slots are `roster_bexists=false`, never `team=0`-allied. No value change.
8. **Do NOT port**: debug-console win/lose (`miscext2.script:3052-3058`), commented spectator-switch lines, `advanced_ifThenElse` stub, net actions 90-98, LAN-human fixups (`:3819-3834`), rating/autosearch force (`misc.script:5816-5826`, net-excluded).

---

## 9. Still-[U] register — fixed-seed 2v2/FFA captures, zero-mismatch criteria (no matrix invented)

Seed convention: fixed seed S (port `Data` seed path), map `land/med/plains`, peacetime 0, AI passive (no orders) unless the row says otherwise. `victorystate_int`: 0 none / 1 win / 2 lose (`dmscript.global:777-779`). Each run asserts tick-exact equality across 3 identical-seed runs AND the stated cross-condition.

| # | Item | Static state | Exact experiment (owner-authorised donor runs only; never this worker) | Zero-mismatch criterion |
|---|---|---|---|---|
| U-T1 | FFA expansion 4-slot | Law [D] §2 (singleton `curTeam` per hit) | 4-slot FFA, lobby `[0,0,0,0]`, seed S. Eliminate slots in fixed order 3→2→1 (scripted kills, same tick offsets). | No `win` stamp while ≥2 live non-leavers; final survivor `int=1`, all others `2`; `lose_tick`/`win_tick` identical across 3 runs; `win_tick >= last lose_tick` (same frame allowed). |
| U-T2 | 2v2 shared-team win | Law [D] §2 (forward absorb) + EV-E stamp | 2v2 lobby `[1,1,2,2]`, seed S. Wipe team B on fixed ticks. | BOTH team-A slots stamp `win` on the SAME tick; ticks identical across 3 runs; no `win` before the last B-slot loss. |
| U-T3 | 2v1 menu shape `[0,0,1]` | [D] §2 ( lobby-0 singletons mutual enemies) | 3-slot lobby `[0,0,1]`, seed S. Kill slot 2 first, then slot 1. | After slot-2 death: NO win (two distinct live teams remain); after slot-1 death: slot 0 alone `win`. Any `win` while 2 live teams stand = fail. |
| U-T4 | Leaver exclusion | Law [O] `miscext2:3796-3811` | 2v2 seed S: `_surrender` team-A slot 0 with its units alive. | Leaver keeps `lose`, never flips to `win`; surviving team-B slots stamp `win` same tick; identical across 3 runs. |
| U-T5 | Trigger set-enemy does NOT split win team | Law [O] `scenario:2175-2197` (mask-only, MakeEnemy commented out) | 2v2 seed S + future trigger engine: fire action 18 between the two team-A slots, wipe team B. | Both A slots still `win` same tick (team ids unchanged) while mutually hostile at the targeting layer. Collapse = fail. |
| U-T6 | Trigger set-ally merges win team | Law [O] `scenario:2202` (`_player_MakeAlly` call) | FFA 3-slot seed S: fire action 19 between slots 0,1, then wipe slot 2. | Slots 0+1 `win` same tick (merged `team1`); without the trigger only slot-survivor wins (U-T1 control). |
| U-T7 | Shared vision follows sim team | Law [O] `player:453-478` | 2v2 seed S with FOW on: ally scout reveals for mate; FFA foe scout does not; `bneutral` mate hidden from slot 0 only. | Reveal-bitmaps equal across 3 runs; FFA leak or neutral-leak = fail. Port FOW stays stubbed until this passes. |
| U-T8 | `bneutral` + slot-0 exception | Law [O] `:470-472` (commented broad form NOT taken) | Mission-shape fixture, slot 0 + neutral mate. | Slot 0 gains no vision from neutral mate; non-zero mate does. |
| U-N1 | Native team-routine addresses | [O]-absence: zero ASCII/UTF-16LE hits (P2); PE header only | Owner-side debugger only: break on `victorystate` write in a 2v2 skirmish, back-trace to CheckEndGame/SetupTeams VAs. | VAs recorded with module+offset; no byte-patch, no binary copy. This worker asserts nothing native. |
| U-L1 | Lobby click → `gMap.players[i].team` write | [O]-absence: no DScript writer readable (§7) | Owner drives donor lobby: set teams 1/2/FFA per slot, dump `gMap` (save/room string `SetMapFromName` round-trip, `miscext2:2550-2642`). | Wire values match §7 table (`0/1/2`, LAN FFA `13..24`, closed `x`); GUI-only values never enter the sim except through `_setup_teams` (change 1). |

Forbidden: inventing any team matrix, any per-mission trigger→team mapping, any score/time-limit threshold, any native VA without the U-N1 procedure.

---

## 10. Explicit non-claims and file discipline

- NO PARITY CLAIM. Resolved items rest on donor TEXT `[O]` with `file:line`; open items name exact next reads/captures in §9.
- No number invented: FFA expansion produces dense `1..N` in slot order (not lobby labels); LAN FFA keys are `13..24`; quick-play split is halves `1/2`; caps are `12/8`; victorystate is `0/1/2`. Every port default filling gaps stays tagged `PORT EXTENSION / PORT APPROXIMATION / PORT POLICY`.
- Read-only compliance: exactly one repo file written (this report). Donor binary never executed, never copied; no source/asset/config/test/runner/Godot/git state changed. Network excluded throughout.

*End of DEC-U-TEAMS.*
