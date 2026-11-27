---
id: PORT1TO1-ENDGAME-PROTOCOL
worker: ENDGAME-PROTOCOL (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c, entry 0x8f1a08"
donor: "READ ONLY. Donor binary never executed/copied/patched/opened as a target by this worker. Donor DScript/data/locale text read as text only. No source/asset/config/test/runner/Godot/git mutation: this report is the only file written."
network: "OUT OF SCOPE. Net branches (_net_IsServer/Client/Replay/Record/Online/Offline, Lan* parsers/sends/scores, lanid>0 fixups, net trigger actions 90-98) are cited only as exclusion boundaries, never as sim law."
parity: "PARITY UNVERIFIED. No donor GPU A/B frame exists under the owner rule; no donor binary was executed. This protocol is an experiment PLAN, not a result, not an approximation, and not a parity claim."
labels: "[O] verbatim donor literal (file:line) · [D] deterministic reading · [U] UNVERIFIED with exact zero-mismatch experiment · PORT APPROXIMATION / PORT POLICY / PORT EXTENSION = labelled port substitute, never donor law"
scope_guard: "Exactly one repository file written (this report). No code, shader, asset, config, test, fixture, result JSON, backup, git state, Godot process, capture, gate, or donor execution occurred. No threshold, mission trigger, VA, hook, cadence, camera constant, score value or LAN value invented."
sources:
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_scenario_win.md
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_victory_start.md
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_endgame_stamp.md
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_endgame_fow.md
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_teams.md
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_menu_peace.md
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_famine_profile.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_acceptance_plan.md (§2 runner rules, §7 preserve-only)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_fixed_step_plan.md (§0-§8)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_determinism_audit.md (N1-N9, admissibility §0)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_parity_chain.md (§86/§89 fixed-step status)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_owner_decisions.md (§0 owner rule, settle classes)
  - docs/terrain_swarm_2026-11-26/PORT1TO1_PLAN.md (task 149)
---

# PORT1TO1 — fixed-seed ENDGAME experiment protocol (owner-runnable, 2026-11-26)

> **Required reviewer line, verbatim (acceptance plan §0 / owner decisions §0):**
> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B
> frame exists; this review certifies neither donor fidelity nor a gate pass.

> **This is a protocol, not a result.** It consolidates the seven landed endgame law reports into one owner-runnable, fixed-seed experiment sequence. It introduces no approximation, no invented constant, no weakened gate, and no parity claim. Every open item stays `[U]` until its own zero-mismatch criterion terminates; no "close", no metric, no green-looking test and no port fallback promotes anything.

---

## 0. Authority boundaries — who may run what

| Lane | Allowed under the 2026-11-26 owner rule | Forbidden to workers |
|---|---|---|
| **A — donor-runtime only** | DONOR binary launched **by the owner only**; debugger breakpoints, native VA discovery, GL/GPU dumps, live lobby clicks, per-mission trigger export from the donor editor, native user-profile store bytes, native menu renders | Any worker execution/copy/patch of `C:\Games\Cossacks 3\cossacks.exe`; any worker-produced donor GPU frame. Workers cite text `[O]` only. |
| **B — port-internal, deterministic capture** | Owner or owner-authorized harness runs of `variant3d/tools/acceptance/capture_sequence.py` through `godot_runner.py run` at a literal seed with pinned config bytes, plus fixed-tick state dumps and two-run byte-identical frame-hash comparison (§2) | Any claim that a port-internal pass proves donor parity; any lowering of a repeat count or threshold; any CPU-fallback substitution. |
| **C — static/port read-only** | Text re-reads, negative greps, manifest/hash inspection, file:line verification | Any source/asset/config/test/git/Godot mutation by an analysis worker. |

**Verdict vocabulary:** every row of §5 terminates as `0 mismatches in N identical-seed runs` (N as stated per row) **or** stays `[U]`. A donor-runtime row can never be closed by lane B; a port-internal row can never be promoted to donor parity. `parity=UNVERIFIED`, `parity.claim=NONE`, `blocking_unverified` non-empty ⇒ `RESULT IS NOT GOOD` while any P0/endgame `[U]` remains open (owner decisions §0; acceptance plan §9).

---

## 1. Exact scenario setup (pin every value before any run)

### 1.1 Pin / seed / config / harness

1. **Donor pin (text authority only):** `t_87f0f3c130b0`, sha256 `87f0f3c130b0…4e16c`, 5,768,048 B. Re-hash read-only; never execute. All seven law reports were pinned to this binary.
2. **Seed:** literal `S = 20261113` (acceptance pin, `gameplay.random_seed`, CLI `--seed 20261113`). **Never `--seed random`** (Class-N1, determinism audit §1: process-start `randi()`) and never the menu Random button (N2). Assert `manifest.deterministic == true` and `seed == "20261113"`. The endgame U registers write "fixed seed S" generically; this protocol instantiates S as 20261113.
3. **Config:** temp copy of `variant3d/config_donor_capture.json` (outside repo, under `%TEMP%\opencode\v42\…`), bytes pinned and SHA-256 recorded before and after every run (`capture_sequence.py` records `config_sha256_file`; preserve-only witness `aa857480…202da` in acceptance plan §7). Preserve verbatim: `features.terrain.backend="donor"` (`config_donor_capture.json:31`), `features.terrain.relief_stamps=true` (`:29`), `features.terrain.demo_mill=true` (`:32` — QA fixture, **not** donor skirmish law), water alpha keys, `camera.pitch_degrees=-32.0`, `min_height=20.0`, `max_height=58.0`, `start_zoom=0.3448276`, `fov_deg=17.27` (PORT APPROX/UNVERIFIED), `1280×720`, `pixels_per_meter=16.0`. For pixel captures set `audio.enabled=false` in the temp copy (Class-N4: `audio.gd:360,368` unseeded clip pick/pitch + wall-clock dedup `:334-337`). **No `load_save`** (Class-N9: seed rewrite `game.gd:9334-9335`).
4. **Harness rule:** every launch via `python variant3d/tools/godot_runner.py run`; one job at a time, wait for terminal result; status must be quiet (no held lock, no `timed-out|error|skipped`); never `reset`/`doctor`/`cancel`/`unwedge`, never delete result JSONs, never `--ignore-history`. Preflight: `py_compile` of the four acceptance tools, `godot_runner.py status`, `assert_clean.py --json`, ffmpeg/ffprobe/Pillow present (acceptance plan §2.0-§2.1). Fresh output directory per run; no capture artifact written under `variant3d/`.
5. **Deterministic-mode preflight (D0 — MANDATORY):** plan task 149 marks `IMPL-FIXED-STEP` DONE (`--deterministic-capture` / `--capture-ticks N`; authoritative 1280×720 viewport; no fallback; audio_seed manifest), **but** `PORT1TO1_parity_chain.md` (read this pass) reports a full-tree search found **no** `deterministic-capture`/`capture-ticks` symbol in `variant3d/` and `main.gd:1635-1642` still frame-paced. Therefore, before relying on lane B, assert the mode is actually live: manifest `deterministic=true`, `deterministic_capture=true`, `capture_ticks=N`, `seq_index.json.ticks_done=N`, `ticks_per_frame=32`, `sim_seconds=N/32` (within `1e-9`), `winner=-1`, `resolution_observed=1280×720`, no `watchdog:`/`cli: wall-clock limit reached`/`deterministic-capture:` line in stderr. **If the flags are absent, lane B is unavailable: every port-internal experiment below stays donor-runtime/owner-only and `[U]`.** Do not claim the design is implemented.
6. **Tick budget:** `--step 1` ⇒ `Data.FPS=32.0` (`data.gd:246`), `ticks_per_frame = max(1, round(step*32)) = 32`; `--frames 24` ⇒ `--capture-ticks 768` (fixed_step plan §0.3/§8). Byte-identical `sha256_pixels` for all 24 frames across two runs is the lane-B self-consistency gate only. Residual hazards NOT neutralized by fixed-step: N3 fisher `randf()` (`game.gd:8127-8130` — any capture with a fishing delivery is inadmissible), N4 audio (disable), N9 save (excluded), U5 water time (`water3d.gd:374-384`, no water drawn under U12 hard-fail — never freeze `_time`), GPU/driver state (same machine/build/driver only).

### 1.2 Map / roster / teams / peace / victory / famine settings

| Surface | Exact setting (all cited) |
|---|---|
| **Map** | Endgame law registers use fixture `land/med/plains` with peacetime 0 and AI passive unless the row says otherwise (scenario-win §8; stamp §8; FOW §6; teams §9; victory-start §6; famine §5). The harness snapshot fixture is the 240×240 donor-backend random map from the pinned config above. **Record which fixture is used; never compare across the two within one zero-match claim.** For the camera experiment only (victory-start E-CAM), a fixed bitmap with 2 white pixels at logged coords is required; no camera constant may be invented. |
| **Roster** | `gc_MaxPlayerCount=12` (`dmscript.global:97`), playable cap `gc_MaxNonSpectatorsCount=8` (`:98`), slot 11 = `gc_player_mercenaryind` (`:776`), spectator country id `-2` (`:1665`). Fixtures: 1v1 (slots 0/1), 2v2 (0..3), FFA 4-slot, 2v1 `[0,0,1]`, plus one spectator slot for purge rows. Per-slot fields: `roster_bexists` (`gMap.players[].bexists`), sim `bexists` (`gPlayer[].bexists`), `bleave`, `bhuman/bai/bclosed`, `bneutral`, `team` (lobby + sim), `victorystate`, `victorystategametime`, `enemyplmask/myplmask`. |
| **Teams** | `_player_SetupTeams` (`player.script:2139-2173`): every sim-team-0 slot claims `curTeam=1,2,…` in index order and forward-absorbs later slots with the same *lobby* key `>0`; `curTeam` always increments; `gEnemyInfoList` gets one entry per sim team. FFA `[0,0,0,0]` ⇒ sim `[1,2,3,4]`; 2v2 `[1,1,2,2]` ⇒ `[1,1,2,2]`; 2v1 `[0,0,1]` ⇒ two ex-0 singletons mutual enemies. Skirmish key = lobby (`dogenerate.inc:2052`, `mapInfo=true`); mission key = sim (`initmap.inc:66`, `false`). **Two layers must be logged separately:** layer A team id (win/FOW/AI key), layer B `enemyplmask/myplmask` + engine friend/enemy handles (targeting key), FFA-safe rule `if (myteam<>histeam) or (histeam=0) or (myteam=0) then ENEMY` (`initmapgen.inc:154-165`) — `0` vs anything is enemy, even `0` vs `0`. LAN FFA unique keys `13..24` collapse to distinct singles identically to `0` (teams §7). |
| **Peace** | Lobby stores a **DONOR INDEX tag**, never minutes: selectable tags `{0,1,11,2,3,4,5,6,7,8,9}` in that display order; index 10 `_reserved` never added (not selectable) and `_misc_GetPeaceTime` `else → 0` (`misc.script:4278-4279`). Seconds = index minutes × 60 at `misc.script:4281`: `{0,600,900,1200,1800,2700,3600,5400,7200,10800,14400}` for `{0,1,11,2,3,4,5,6,7,8,9}` respectively (`dmscript.global:1055-1066`; `misc.script:4262-4281`; locale `gui.txt:553-575`). Init: `gfloat_peacetime := _misc_GetPeaceTime(index)` and `gbool_peacemode := (index <> 0)` (`dogenerate.inc:2054-2064`). Expiry: strict `gametime > gfloat_peacetime` (`nothing.inc:658`) — at equality peace still holds. **No `40/50` rows, no `%d min` for 90+, no `startingsettings.cfg` peace key** (menu-peace §3/§5). Port `PEACE_TIME` gate (`game.gd`) is PORT POLICY; keep, relabel, never gate 1:1 on it. |
| **Victory** | `victorystate` enum `none=0/win=1/lose=2` (`dmscript.global:777-779`); fields `TPlayer.victorystate:Integer`, `victorystategametime:Float`. **Score victory and time-limit victory are ABSENT** `[O-absence]` (victory-start §1.3; scenario-win §7/P10): no cfg key, no threshold, no timer; the sole `timelimit` hit is pause-menu `gc_pause_timelimit=120`. Port `VICTORY/SCORE_LIMIT=5000` stays `PORT_EXTENSION_SCORE_VICTORY=false` — never a 1:1 law, never invent a threshold. Team win is donor-verbatim `_misc_CheckEndGame` (`miscext2.script:3769-3844`), not port policy (scenario-win §5 corrects victory-start §1.4). Trigger system caps: 512 triggers, 8 conditions, 16 actions, 32 condition kinds, 99 action kinds (`classes.script:6205-6384`); endgame_wins are actions 47/48 only (`scenario.script:2995-3064`). Per-mission trigger→victory mapping stays `[U]-F1`: **no mapping may be invented**. |
| **Famine / merc** | `gProfile.bFamine` shipped default **TRUE** (`profile.script:39`, field `classes.script:5122`); stored profile may overwrite on boot via engine natives (`profile.script:642,729-736`, byte format `[U]-P-store`); no menu/clamp/cfg writer found (famine §3). Upkeep: `bfamine` set on food shortfall, `brebellion` set on gold shortfall iff `consume>income`, cleared when stock `<2` (`player.script:270-322`). Unit death roll `<50/<5/<12` and rebellion roll `<6000/<100/<200` vs `_misc_RandomInt=floor(random*32768)` (`nothing.inc:482,492`, `misc.script:494-498`, `dmscript.global:176`). Rebellion flip target = **slot 11** via `GetPlayerHandleByIndex(gc_player_mercenaryind) → _misc_ChangePlayer(...,False,False,True)` (`nothing.inc:494-495`, `miscext.script:894-958`); `bmercenary` sids are the eight `dip` rows (`unit.script:612-614`). Port has no slot-11 mercenary player; keep `[U]-U11-M-port`, invent no faction/player. |

---

## 2. Deterministic capture invocation (lane B, conditional on D0)

From repo root, temp config pinned per §1.1. Two runs identical except `--label`/`--out`:

```powershell
python variant3d/tools/acceptance/capture_sequence.py `
  --seed 20261113 --frames 24 --step 1 --label egA `
  --view state=(Join-Path $env:TEMP 'opencode\v42\endgame\state_config.json') `
  --mode seq --deterministic --capture-ticks 768 `
  --timeout 240 --max-wait 3600 `
  --out inbox/qa/captures/egA_20261126
```

`768 = 24 * max(1, round(1*32))`. Run B: `--label egB`, `--out inbox/qa/captures/egB_20261126`. Config copy must have `audio.enabled=false`, `load_save` absent, literal seed, backend `donor`, `demo_mill=true` preserved; record SHA-256. Pass conditions (fixed-step plan §8.2, none weakened): both manifests `status=ok`, `parity=UNVERIFIED`, `deterministic=true`, `seed="20261113"`, `capture_ticks=768`, `expected_sim_seconds=24.0`, `expected_resolution=[1280,720]`, config SHA equal to pinned copy, `headless=false`; per view `runner_status=ok`, `runner_exit=0`, `complete=true`, `frame_count=24`, `resolution_observed=1280×720`, `resolution_matches_request=true`; `seq_index.json` `ticks_done=768`, `ticks_per_frame=32`, `sim_seconds=24.0`, `winner=-1`; stderr free of watchdog/refusal lines; **for every view and index 0..23 Run A `sha256_pixels` == Run B `sha256_pixels`** (`sha256_file` likewise; `sha256_pixels` authoritative if PNG metadata differs); no 800×600 or blank frame. A failure is a failed capture, never a retry-until-green. A pass proves **port-internal self-consistency only**.

State dumps (for the fields in §4) are taken at the same fixed ticks through the owner harness (MCP `game.tick` is an optional fixed-tick driver, determinism audit §1 N6; it is **not** a donor A/B). Every dump must carry the tick index and `game.time_s`; emission cadence must not depend on wall clock.

---

## 3. Step-by-step trigger sequence

Each step lists donor law `[O]` with cite, port surface label, and the authority lane that can settle it. All tick ordering is `[D]` from the cited passes; no cadence is invented.

**T0 — Init / setup (before tick 0).**
- `_player_Init` per slot: `victorystate:=none`, `victorystategametime:=0`, `enemyplmask := 255 xor (1 shl id)`, `myplmask := 1 shl id`, `team:=0`, `bexists:=False` (`player.script:110-124`; W12 in stamp §2.7). Sim-team 0 is a pre-setup sentinel, never an alliance.
- `_player_SetupTeams(true)` skirmish / `(false)` mission per §1.2; build `gEnemyInfoList` with one entry per sim team.
- Spectator purge W13 (`initmapgen.inc:256-264`): roster+sim `bexists:=False`, `bleave:=True`, `victorystate:=lose` **with no `gametime` write**, unconditional.
- Historical-battle clear W14 (`initmaphistoricalbattle.inc:124-129`, only `gScenario.bactive`): all slots `bexists:=True`, `victorystate:=none`, `gametime:=0`.
- Peacetime init per §1.2; FOW viewer set built by the init `SetPlayer` R1 path (`control.script:712-720`, callers `initmapgen.inc:204/214/225` etc.).
- Note port-only `winner` scalar / `game.gd:5501` early-return freezes post-victory stamping; donor `CheckEndGame` keeps running globally. Rows needing post-terminal stamps (U-S3, U-F3) require the owner to assert or disable that early return before the run; until then these remain `[U]` and no donor-equivalent behaviour is claimed (FOW §4, port change list item 3).

**T1 — `bexists` auto-defeat (W1).** `units/global.inc/progress.inc:54-141`.
1. Gate: `lastprogresstime>0 AND deltatime>0` (`:43`); not `_net_IsClient/_net_IsReplay` (`:46`); `not gScenario.bactive AND gamestage>waitingloading AND gamemode IN (game,spectator)` (`:54`); stagger `_player_CheckProgressLastTimeAndIncrease(lastcheckexists,0,addtime)` with `addtime = 0.125*plInd + (bexists ? 8.0 s : 24.0 s)` (`:56-61`, `gc_global_TimeCheckExists=0.01*200=2.0 s`).
2. Skip if `bnetsurrender`/`bsurrender` (`:63-64`); battle mode forces `bexists:=True`, no scan/stamp (`:65-68`).
3. Scan (`:69-123`): `0<farmused<100` → deep scan peasant `statetag visual_none+essential_none` or human `insideofuid<>0`, then built `usage=center`; else `bexists := (farmused>0)`.
4. On `not bexists AND (bai OR bhuman)`: `_misc_KillPlayerUnits` **before** the stamp (`:126-127`), then **first-transition guard `if (bPrevExists)`** (`:128`) → W1 `victorystate:=lose`, `gametime:=GetGameTime` **iff 0** (`:130-132`). Leaver branch (`:137-139`) kills with no stamp.
- Scenario/mission mode (`bactive=True`) never runs this slice: no auto-defeat, no income, no AI.
- Lane B for port-internal; donor arm lane A for engine-slice scheduler.

**T2 — `_misc_CheckEndGame` team win (W5).** `miscext2.script:3769-3844`; called every global tick at `nothing.inc:647` **UNGATED** (no `bactive`/gamemode/gamestage gate).
1. Phase 1 roster gate (`:3775-3788`): over `gMap.players[i].bexists` (roster-side), collect `gPlayer[i].team` (sim-side); ≥2 distinct sim teams ⇒ `bSecondTeamExist`, else return `False` **with no writes**.
2. Phase 2 live gate (`:3791-3803`): pairwise over `gPlayer[i].bexists AND NOT bleave`; any cross-team live pair ⇒ `bOneTeamLeft:=False`, break.
3. Stamp (`:3804-3841`): every live non-leaver with `victorystate <> win` → `win`, `gametime := GetGameTime` iff 0, `winnerteam:=team`, `bchanges:=True`. **Team scope: every survivor, never one pick**; a slot already `lose` is flipped to `win` here. LAN-human fixups (`:3819-3834`) and `bchanges` net tail (`:3837-3842`) are **excluded**. `winnerteam` is `var`-zero-initialised so the `>0` guard is deterministically false on the no-stamp path `[D]`.
- Same-frame ordering `[D]`: W1 (per-player slice) then W5 (global tail) in one frame ⇒ `win_tick >= lose_tick` legal; `win_tick < lose_tick` is an ordering bug.

**T3 — Surrender (W8/W9).** `_misc_Surrender`, `miscext2.script:3847-3896`.
1. `plInd := GetPlayerIndexInterfaceIO`; `bleave := True` **unless spectator** (`:3851-3853`).
2. Offline arm (W9, `:3889-3894`): `victorystate:=lose` **unconditional overwrite** (no state guard, even over `win`), `gametime := GetGameTime` iff 0. Server arm W8 (`:3856-3861`) identical under `_net_IsServer`; client arm (`:3868-3870`) sends `LanSendParser(SURRENDER)` with **no local stamp** — excluded.
3. `:3862`/`:3894` call `_misc_CheckEndGame` **in the same call**: survivors can be crowned with zero intermediate refresh. Port-only early-return caveat from T0 applies.

**T4 — Scenario trigger win/lose (W10/W11).** `scenario.script:1375-1734` (conditions), `:1738-1774` (dispatcher), `:2994-3064` (actions), `scenario.inc` full file.
1. Scenario section per global tick head: timers first (`bfinished := (GetGameTime-starttime)*1000 >= time`); triggers `i=0..511` in index order; skip `!bactive`; stamp `activetime:=GetGameTime` if `<=0`; battle pre-scan (only net-kind conditions may veto); evaluate `j=0..7` conditions AND-combined with `logical_OR` (id 20) as separator; sign law `equal/≠/>/≥/</≤` with `sign_none → False`; counter indirection when `busecounterasamount/astime`.
2. On fire: one-shot deactivate (`bactive:=False`, `activetime:=0`) + `_scenario_EvaluateTriggerActions` with `myplind := GetPlayerIndexInterfaceIO` captured once (`:1742`).
3. Action 47 `endgame_win` (`:2995-3047`): `gPlayer[myplind].victorystate:=win`, `gametime` iff 0, campaign/profile tails (excluded). Action 48 `endgame_lose` (`:3049-3064`): mirror `lose`. **Both strike the interface slot only** — they read no `.player` field; AI/co-op slots unaffected. Overwrite unconditionally on state (same shape as W8/W9), time first-write-wins.
4. `bupdateally` is NOT set by win/lose actions ⇒ **no inline FOW refresh**; `advanced_ifThenElse` (49) is a `todo` stub; `net_IsOffline` condition 24 requires `victorystate=none`, so offline-gated triggers black out once `myplind` is terminal. Query-dialog request (`_net_IsOffline AND GetProgressingPauseMode`) `break`s later triggers that tick.
- Per-mission trigger→victory mapping is `[U]-F1`: owner exports trigger rows from each `data/maps/missions/*.map` in the donor editor; port replays ONLY exported rows (each cites `mission + trigger index`). Any invented kind/param fails.

**T5 — Peace expiry.** `nothing.inc:658-695` (global tick tail, after T2).
- Condition `gbool_peacemode AND gametime > gfloat_peacetime AND not replay AND not client`. On expiry: clear flag; collect `ptborder` objects via misc-player handle → `WriteFreeList` + `WritePeaceTime(fbstate:=false)`; `GameObjectRequestToDestroyByHandle` per border; `GUIMiniMapPrimitivesClear + _misc_UpdateMiniMapPrimitives(True)`. **No `victorystate` write on this path** — peace never stamps. Strict `>` boundary: at `gametime == gfloat_peacetime` peace still holds.

**T6 — Famine / mercenary flip.** `units/unit.inc/nothing.inc:450-505`; `player.script:270-322`.
1. Master death gate `:450`: `gProfile.bFamine AND gPlayer[plInd].bfamine AND bplayable`; death roll `:482` `<50/<5/<12` (difficulty>1 / =0 / =1); `bplayable` game/spectator gate.
2. Rebellion gate `:487`: `brebellion AND bmercenary AND (plInd<>mercenaryind) AND bplayable`; roll `:492` `<6000/<100/<200`; target `:494-495` slot 11 via `_misc_ChangePlayer(goHnd, plMercHnd, False, False, True)` (counter move `player.script`/`miscext.script:913/:918`, `TObj(pl):=11` at `:916`).
3. Draws from `_misc_RandomInt = floor(random*32768)`; stream attribution is `[U]-G1` (Delphi second `Random()` vs `RandomExt` LCG). Port ledger site `data.gd:1742` `famine_rebellion` must reproduce the exact sequence; every extra/missing draw is a hard failure, not a tolerance.

**T7 — Team ally/enemy mutation (two layers).** `player.script:2177-2271`; `scenario.script:2175-2249`.
1. `_player_MakeAlly(a,b)` (`:2177-2211`): merges team ids (every slot on either team takes `team1`), masks to complement, absorbed `TEnemyInfo` Reset; no-op if already same team. Only runtime op that changes the win-law grouping.
2. `_player_MakeEnemyForAll(pl)` (`:2215-2259`): extracts one slot to first empty team `1..12`; `_player_MakeEnemy(a,b)` (`:2261-2271`) extracts both if same team.
3. Trigger action 18 `playerSetAsEnemy` (`:2175-2197`): mask + engine handles **only**, both `_player_MakeEnemy` call forms commented out ⇒ team ids unchanged; `bneutral:=False` on slots involving 0; sets `bupdateally` if IO involved.
4. Action 19 `playerSetAsAlly` (`:2198-2224`): calls `_player_MakeAlly` (`:2202`, **real team merge**) + mask/link rewrite; action 20 `playerSetAsNeutral` (`:2225-2249`): mask + FRIEND links **only**, `bneutral:=True` for non-zero slots when 0 involved, team unchanged.
5. No mutation path issues inline `UpdateFOW`. R2 tail `scenario.script:3302-3306` re-resolves only when `bupdateally` was set by 18/19/20 with IO involvement; a direct `MakeEnemy*` call would leave vision stale until the next R-call (no live caller — both trigger forms commented). FOW sharing is layer A (`team`) only; slot 0 does not receive vision from `bneutral` mates.

**T8 — FOW re-resolve after stamps (the lazy-vs-eager contrast).** `player.script:451-478`: `bFOW:=True`; `False` iff `bballoon` OR balloon-option-with OR `victorystate<>none` (`:456`) OR editor fog off; `ClearFOWPlayers` unconditionally; if `bFOW`, `AddFOWPlayers(self)` + same-sim-team mates minus slot-0/`bneutral` exception (`:460-474`), `SetFOWDovFunc('_unit_GetVision')` (`:475`), `SetFOWEnable(bFOW)` (`:477`). Only six live re-resolve callers exist (FOW §1): R1 `control.script:716` (viewer switch/init), R2 `scenario.script:3305` (diplomacy tail), R3a/b `player.script:1913/1921` (balloon), R4a/b `initmapgen.inc:276/285` (save-compat `<53/<89`). **Every stamp path (W1/W5/W8/W9/W10/W11), spectator purge, team mutation and global tick writes NO FOW/minimap field.** Donor engine keeps the last viewer set between R-calls; port `world3d_fog.gd` re-resolves eagerly per fog tick — a cadence substitution, not a donor hook. Dual-arm criterion in §5 U-F1/U-F2.

---

## 4. Per-tick log schema (emit one JSON row per fixed tick; all fields named)

| Group | Fields to dump (port name / donor name) |
|---|---|
| Clock | `tick_index`, `game.time_s` / `GetGameTime`, `dt_step` (must be `1/32` in lane B), `seed`, `config_sha256_file` |
| Victorystate | per slot `i∈0..11`: `victorystate_int` (`0 none/1 win/2 lose`) + `victorystate` string, `victorystategametime` / `gametime` (record writer W# and whether the `iff 0` gate fired — first-write-wins), `prev_bexists` / `bPrevExists` (for W1 edge), `bleave`, `bneutral`, `bballoon` |
| Liveness | per slot: `roster_bexists` (`gMap`), `sim_bexists` (`gPlayer`), `bai`, `bhuman`, `bclosed`, `bplayable`; `bSecondTeamExist` / `bOneTeamLeft` result each CheckEndGame pass; `winnerteam`/`bchanges` locals (donor arm only) |
| Team ids | per slot: lobby `gMap.players[].team`, sim `gPlayer[].team`, port `_sim_team`; the `gEnemyInfoList` rows (`team`, `enemyMask`, `changed`); `GetPlayerEnemyInfo`/`GetTeamEnemyInfo` resolution |
| Enemy masks | per slot `enemyplmask`, `myplmask`; per pair friend/enemy engine-handle links; the FFA-safe rule outcome at setup; which action (18/19/20/MakeAlly/MakeEnemy*) mutated them this tick |
| FOW viewer set | per viewer: `fow_enabled`, `ClearFOWPlayers` event, `AddFOWPlayers` set (ordered slot ids), slot-0/`bneutral` exception applied, `SetFOWDovFunc`, `SetFOWEnable`; `los_at` bitmap + `fog_vis`/`fog_explored` bits; **transect** across victim's last-known blip cell at 1.0-unit steps ±(vision+8) with `los_at`/`fog_vis`/`fog_explored` per sample; which R1–R4 caller fired (or `none`) |
| Capture / hide | entity `TObj`/`TObjProp` statetags (`visual_none`, `essential_none`, `essential_death`, `bbuilt`, `usage=center`, `insideofuid`, `dead/finished/hidden`), garrison/enter-hide state, unit owner `pl` before/after `_misc_ChangePlayer`, `ptborder` entity count, `capture/hide` overlay primitives |
| Score / counters | scenario `flags[]`, `timers[]` (`bfinished`), `counters[].value`, `results[].executecount`, `triggers[].bactive/bexists/activetime`, `bupdateally`; `counter.total` / `counter.farmused` (victory-start §2 CountOfPlayerUnits), `resconsume/resincome/res[food]/res[gold]`, `bfamine/brebellion`. **No donor score threshold exists** — any port `SCORE_LIMIT` field is labelled `PORT EXTENSION` telemetry, never a donor law |
| Stamp events | `writer_id` (`W1/W5/W8/W9/W10/W11/W13/W14`), state written, time written or `unchanged`, tick, first-transition gate result, units-killed-before-stamp count |
| RNG ledger | per draw site: site id, value, draw count; sites `famine_rebellion` (`floor(random*32768)`), fisher (N3 — capture inadmissible if present), any scenario counter draw; stream attribution `[U]-G1` |
| Determinism | `deterministic`, `capture_ticks`, `ticks_done`, `ticks_per_frame`, `seq_index.sim_seconds`, `winner`, `resolution_observed`, per-frame `sha256_pixels`/`sha256_file`, stderr refusal/watchdog lines |

Empty/unset fields must be emitted as explicit nulls with a reason, never omitted; omission is not a zero-mismatch. FOW transects and minimap primitive dumps are taken at T−1, T, T+1, T+5 around every stamped tick (FOW §6).

---

## 5. Zero-mismatch termination criteria (consolidated from the seven reports)

Every row: **identical seed S / pinned config, N identical runs, 0 mismatches on all stated fields**; any miss keeps the item `[U]`. `A` = donor-runtime only (owner, lane A); `B` = port-internal with deterministic capture (lane B, conditional on D0); `B→A` = port leg settleable in B, donor leg requires A. "Deferred" rows cannot be asserted by the port until the named engine exists. No row may be closed by a threshold, fallback, retry-until-green, or invented value.

### 5.1 `DEC_U_victory_start` (§6)

| ID | Criterion | Lane |
|---|---|---|
| V-score | Grep `victory\|score_limit\|timelimit` over `data/game/var/*.cfg` + `donewgame.inc` → 0 skirmish-auto hits; any hit quoted verbatim with file:line or ABSENT stands | A (text re-read) |
| V-prec | 2v2, eliminate one team-A member while mate `bexists`: 3 runs → identical `victorystate`/`gametime` stamps; team-continuation tagged PORT POLICY | B→A |
| P-peace | Each peace index 1-9,11 on seed S: `gfloat_peacetime` seconds = §1.2 table AND expiry at `gametime > peacetime` clears `gbool_peacemode` + destroys ptborders; identical (seed,index) → identical expiry tick | B→A |
| S-place | Seed S, N=4 FFA: dump `arrStartPosBusy` + `startx/y` across 3 runs → all identical; vary one draw site → only downstream words diverge | A (engine draw order) / B for port |
| CAM | Seed S fixed map, 2 white pixels at logged coords: `startx/y` must equal rescale formula exactly; camera target repeats across 3 runs or declared PORT CHOICE | B→A |
| Q1/Q2/Q3 | Train `completion_tick - start_tick = ceil(buildtime_seconds/dt)` exactly (AI ×0.3/0.5/0.75/1/1.25); upgrade 3 runs identical tick count; build-hit stage flips at `floor(progress*4)` boundaries | B→A |

### 5.2 `DEC_U_scenario_win` (§8)

| ID | Criterion | Lane |
|---|---|---|
| U-F1 | Owner exports each mission's trigger rows (kind ids + §1 params); port replays only exported rows; 3 identical-seed runs → identical `victorystate_int` + identical stamp tick; any invented kind/param fails the run | A (export) + B (replay) |
| U-E1 | 1v1 kill P1's last peasant/center at tick T: `lose_tick` and `win_tick` identical across 3 runs AND `win_tick >= lose_tick`; any `win_tick < lose_tick` = ordering bug | B→A |
| U-E2 | 2v2, one team-A slot `bleave` with units alive: 3 runs → surviving team-B ALL stamped `win` same tick; leaver keeps `lose`, never flipped | B |
| U-E3 | FFA 4-slot eliminated 3→2→1: no `win` until exactly one live non-leaver; survivor `int=1`, others `2`, identical ticks; then 2v2 wipe → BOTH survivors `win` same tick | B |
| U-T1 | `triggerIsActiveTime`: fire tick = `ceil(time_ms/dt)` exactly, identical across 3 runs; action-52 re-arm refires with fresh `activetime` | B→A (trigger engine) |
| U-T2 | Zone `CountOfUnitsInZone` + `moreequal N`: fires iff N present; add N+1 → same fire tick (early-break path), never earlier | B→A |
| U-T3 | Battle-mode pre-scan: non-net condition neither fires nor vetoes; net veto respected — **deferred until trigger engine lands** | Deferred |
| U-S1 | Two fireable triggers, first raises query: trigger[1] fires same tick iff no query requested, else next tick (sim asserts only the break) | B (GUI-owned) |
| U-P1 | Peacetime expiry fixture: all `ptborder` entities destroyed on the exact expiry tick across 3 runs; minimap primitives cleared | B→A |

### 5.3 `DEC_U_endgame_stamp` (§8)

Seed convention: `land/med/plains`, peacetime 0, AI passive; 3 identical-seed runs each.

| ID | Criterion | Lane |
|---|---|---|
| U-S1 | 1v1 kill at tick T: identical `lose_tick/win_tick/gametime` triple; `win_tick >= lose_tick`; no invented timestamp | B→A |
| U-S2 | 1v1 no kills for N ticks: zero `victorystate_int`/`gametime` deltas; then FFA wipe: survivor `1`, rest `2`, identical ticks; any `win` with ≥2 live teams = fail | B |
| U-S3 | 2v2: wipe B → both A `win`; surrender one A → leaver `2`, mate `1`, mate's `gametime` UNCHANGED (first-write-wins); future W10-then-W9 keeps original `win` tick; any time overwrite = fail | B (needs T0 early-return asserted) |
| U-S4 | 1v1 FOW on, stamp `lose` on P1: viewer-0 grid off (`los_at=1` everywhere) EXACTLY from stamp tick; 3 runs identical bitmaps; stale one extra tick = hook missing; donor arm stays stale to next R-call | B→A (dual arm) |
| U-S5 | Spectator slot `_surrender`: `bleave` stays `False`, state stays `lose` from purge, `gametime` unchanged; any later W5 flip to `win` = fail | B |
| U-S6 | 1 spectator + 2 humans: purge slot `2` with `gametime==0.0` (no-time write) until any later guarded stamp (none in 1:1); identical across 3 runs; any invented purge tick = fail | B |
| U-S7 | 2v2, action 18 between team-A mates, wipe B: both A still `win` same tick (team ids unchanged), vision set UNCHANGED by mask edit; collapse = fail | B→A (trigger engine) |
| U-S8 | Mission harness: fire W10 `win` on `myplind`, then evaluate `IsOffline`-gated trigger next tick → does NOT fire; 3 runs identical; until trigger engine lands port asserts nothing | Deferred |

### 5.4 `DEC_U_endgame_fow` (§6)

Seed convention as §5.3; **minimap transect on every row** (fixed camera, 1-px-step viewport transect across victim blip cell, `fow_enabled + viewer set + los_at` at 1.0-unit steps ±(vision+8), `fog_vis/fog_explored`, minimap primitive name/pos/visibility). Each run: 3 identical-seed dumps at T−1, T, T+1, T+5.

| ID | Criterion | Lane |
|---|---|---|
| U-F1 | W1 defeat: DONOR arm fog STALE (`los_at=0` in dead zone, blip present) through next R1 — any same-tick full vision = invented hook. PORT arm: grid off (`los_at=1` everywhere, overlay hidden) EXACTLY from stamp tick; stale one extra tick = missing hook. Control leg: same seed, no kill | B→A (dual arm) |
| U-F2 | W5 team-win 2v2: both A slots `win` same tick; vision flips for BOTH in the SAME R-call — split-frame flip = fail | B→A (dual arm) |
| U-F3 | Surrender double-stamp: leaver `2`, survivors `1`, survivor `gametime` unchanged; single vision transition (no lose-frame then win-frame); any intermediate full-vision-only-leaver frame = invented refresh | B |
| U-F4 | Trigger win with no diplomacy: `bupdateally` stays False, NO `UpdateFOW(plIO)` in fire evaluation, vision flips only at later R-call; any inline refresh = fail — **deferred until trigger engine** | Deferred |
| U-F5 | Trigger action 19 merge + win same evaluation: merge precedes `:3302` tail (flag True, `UpdateFOW(plIO)` + `UpdateMiniMap(False)` AFTER team write); slots 0+1 `win` same tick; tail-before-merge = ordering bug | B→A (trigger engine) |
| U-F6 | Mask-only diplomacy (18/20): viewer set IDENTICAL across the fire (only enable/primitive timestamps move); both A slots still `win` post-wipe; FFA/neutral leak = fail | B→A |
| U-F7 | Spectator purge → init R1: purge slot `2` with `gametime==0.0`; viewer set excludes purged slot from tick 0; identical across 3 runs; any invented purge tick = fail | B |
| U-F8 | Balloon × victory: (a) `fow_enabled` False from balloon tick and STAYS False across later terminal stamp (no double transition); (b) geology upgrade changes minimap only, `fow_enabled` UNCHANGED; any FOW flip on geology = fail | B→A |

Retained without re-proof (cite, do not re-close): stamp U-S1/U-S2/U-S3/U-S5/U-S6/U-S7/U-S8; teams U-T7/U-T8; U-N1; U-L1; FOW-knobs E-KNOB-defaults/E-GRID-a..e; fog-territory E-FOGT-a..d.

### 5.5 `DEC_U_teams` (§9)

| ID | Criterion | Lane |
|---|---|---|
| U-T1 | 4-slot FFA `[0,0,0,0]`, eliminate 3→2→1: no `win` while ≥2 live non-leavers; final survivor `int=1`, others `2`; `lose_tick`/`win_tick` identical across 3 runs; `win_tick >= last lose_tick` | B |
| U-T2 | 2v2 `[1,1,2,2]` wipe B: BOTH A slots `win` SAME tick, ticks identical across 3 runs, no `win` before last B loss | B |
| U-T3 | 3-slot `[0,0,1]`: kill slot 2 → NO win (two live teams); kill slot 1 → slot 0 alone `win`; any win with 2 live teams = fail | B |
| U-T4 | 2v2 surrender team-A slot 0 with units alive: leaver keeps `lose`, never `win`; surviving B slots `win` same tick; identical across 3 runs | B |
| U-T5 | Action 18 between team-A mates, wipe B: both still `win` same tick, mutually hostile at targeting layer; collapse = fail | B→A (trigger engine) |
| U-T6 | FFA 3-slot action 19 between 0,1 then wipe 2: slots 0+1 `win` same tick (merged `team1`); without trigger only slot survivor wins (U-T1 control) | B→A |
| U-T7 | 2v2 FOW on: ally scout reveals for mate, FFA foe does not, `bneutral` mate hidden from slot 0 only; reveal bitmaps equal across 3 runs; leak = fail (port FOW stays stubbed until pass) | B→A |
| U-T8 | Mission-shape slot 0 + neutral mate: slot 0 gains no vision from neutral mate, non-zero mate does | B→A |
| U-N1 | Owner debugger break on `victorystate` write in 2v2, back-trace CheckEndGame/SetupTeams VAs; VAs recorded with module+offset, no byte patch/copy; worker asserts nothing native | **A only** |
| U-L1 | Owner drives lobby (teams 1/2/FFA), dumps `gMap` via `SetMapFromName` round-trip: wire values match §1.2 table (`0/1/2`, LAN FFA `13..24`, closed `x`); GUI values enter sim only through `_setup_teams` | **A only** |

### 5.6 `DEC_U_menu_peace` (§8)

| ID | Criterion | Lane |
|---|---|---|
| U-M1 | Expanded lobby dropdown transcribed row-for-row vs §1.2 table and `gui.txt:553-575`; 3 opens identical; any extra/missing row ⇒ table revised, never screenshot | **A only** |
| U-M2 | Click each of 11 rows, dump `gMap.settings.additional.peacetime`/room field: sequence exactly `0,1,11,2,3,4,5,6,7,8,9`; 3 passes byte-identical | **A only** |
| U-M3 | Indices `{1,11,4,9}`: `gfloat_peacetime` exactly `600.0, 900.0, 2700.0, 14400.0`; identical across 3 runs per index | A + B (port conversion U-P2) |
| U-M4 | Index 0 → `gbool_peacemode=false`, all others true; 3 runs identical; reserved 10 not drivable (U-M5) | A + B |
| U-M5 | Lobby listbox TAGS exactly `{0,1,2,3,4,5,6,7,8,9,11}` every run; tag 10 never present; forcing 10 by memory edit EXCLUDED | **A only** |
| U-M6 | Index 1 (600 s): last `true` tick has `gametime<=600.0`, first `false` tick `gametime>600.0`; border count → 0 exactly on false tick; 3 runs identical tick indices | B→A |
| U-P1 | Headless port `_peace_items()`: exactly 11 §1.2 rows (ids `0,1,11,2,3,4,5,6,7,8,9`, names §2 verbatim), no `null`; 3 runs identical | B |
| U-P2 | Feed all 11 tags + reserved 10 + garbage through apply path: `PEACE_TIME` exactly `{0,600,900,1200,1800,2700,3600,5400,7200,10800,14400}`; `10`/garbage → `0.0`; 3 runs identical | B |
| U-P3 | `PEACE_TIME=600.0`, step 599→601: guard returns at 599 and 600, passes at 601; 3 runs identical | B |
| U-S1 | Save/load round-trip: saved value equals lobby TAG, reloaded `PEACE_TIME` equals U-P2 seconds; until then saved peace UNVERIFIED | B |
| U-G1 | `gbool` flag + border/minimap port surface: deferred to border ticket; do NOT gate any 1:1 claim on it | Deferred |

### 5.7 `DEC_U_famine_profile` (§5)

| ID | Criterion | Lane |
|---|---|---|
| FP-1 | Fresh profile (owner backs aside existing store), headless boot, no Start: script-visible `gProfile.bFamine=true` on all 3 fresh boots; no-change Accept leaves store bytes identical across 3 repeats; any byte difference quoted field-by-field | **A only** (native store bytes) |
| FP-2 | Fixed seed, `bFamine=true`, 1 peasant/side, difficulty normal (rebellion 200 / famine 12), fixed-dt: (A) 600-tick soak no menu interaction; (B) identical soak opening/closing every options submenu without Apply. A and B traces identical across 3 repeats each (death ticks, victim ids, flag edges); divergence names the surface and stays `[U]` | A (donor arm) + B (port arm) |
| FP-3 | Seed S, difficulty normal (P=200/32768), `bFamine=true`, one `dip` merc owned by slot 0 with `brebellion` forced via upkeep shortfall: run to first flip or 20 000 ticks; port flip tick/owner/draws match donor-law model (single `floor(random*32768)<200` per tick per unit, target slot 11) on 3 repeats; stream attribution stays `[U]-G1`; any ledger mismatch quoted, never retuned | B→A |
| FP-4 | X21 20-vector fixture + per-site draw-count, famine-only soak: port `data.gd:1742` ledger reproduces exact draw sequence and exact death-tick set across 3 repeats; any extra/missing draw = hard failure | B |

**Forbidden across all rows:** inventing a score/time-limit threshold, a per-mission trigger→victory mapping, a native VA (outside U-N1 procedure), a LAN score/rating value, a camera constant, a FOW hook/cadence/cell size, a famine faction/player, or a peace `40/50` row. Retained `[U]` from earlier law reports are not re-closed by this protocol.

---

## 6. One-line authority summary

- **Donor-runtime only (forbidden to workers; lane A):** native VA discovery (U-N1), per-mission trigger export (U-F1), donor lobby click/room-string dumps (U-L1, U-M1/M2/M5), native profile-store bytes (FP-1), donor FOW/engine cadence and GL/RTTI dumps, donor menu renders, the DONOR arm of every dual-arm FOW/stamp experiment, and any donor GPU A/B frame. These require an owner-launched donor process; under the read-only rule no worker may run or capture them.
- **Port-internal with deterministic capture (lane B, conditional on D0):** stamp ticks and first-write-wins `gametime`, `victorystate_int` sequences, team ids/enemy masks after SetupTeams and mutations, surrender/leaver exclusion, spectator purge no-time write, peace index→seconds and strict-`>` expiry, famine/rebellion draw ledger and flip ordering, port FOW viewer-set/los_at `los_at=1`-from-stamp-tick arm, and two-run byte-identical `sha256_pixels` under fixed seed/config. A B-pass establishes **self-consistency only**; the donor half of every dual-arm row stays `[U]` until lane A terminates it.
- **No lane closes parity.** Even all rows terminating with zero mismatches leaves `parity=UNVERIFIED`; no donor GPU A/B frame exists under the owner rule.

---

## 7. Non-claims and file discipline

- **PARITY UNVERIFIED.** No donor GPU A/B frame; no donor binary executed by this worker. This protocol introduces no approximation and makes no parity claim; existing port substitutes stay labelled `PORT APPROXIMATION`, `PORT POLICY`, `PORT EXTENSION` and are never cited as donor law.
- No number invented: no score threshold (score is ABSENT), no time-limit value, no per-mission trigger mapping, no native VA, no LAN score, no camera constant, no FOW Hz/cell size/hook, no famine faction/player, no peace `40/50` row, no `advanced_ifThenElse` semantics.
- The `winner != -1` early-return (`game.gd:5501`) is a documented port-only ordering inversion vs `nothing.inc:647` (UNGATED CheckEndGame); it is flagged as a precondition for the post-terminal-stamp rows, not silently worked around.
- The deterministic capture mode is treated as **conditional**: plan task 149 records `IMPL-FIXED-STEP` DONE, while `PORT1TO1_parity_chain.md` reports no such symbols in `variant3d/`. This protocol asserts the mode live at D0 before using lane B and otherwise leaves every experiment in lane A/`[U]`. It does not claim the mode is implemented, and it does not claim it neutralizes N3/N4/N9/U5.
- Network/multiplayer is out of scope throughout; all `_net_*`/LAN/campaign/profile tails are exclusion boundaries only.
- Read-only compliance: exactly one repository file written (this report). No source/asset/config/test/runner/result/backup/git/Godot/donor state changed.

*End of PORT1TO1_endgame_protocol. Read-only; exactly one file written; no approximations introduced; no test weakened; no donor binary executed; PARITY UNVERIFIED.*
