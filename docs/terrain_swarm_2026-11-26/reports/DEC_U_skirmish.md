---
id: DEC-U-SKIRMISH
worker: DEC-U-SKIRMISH (subagent in full 1:1 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
ticket: "Resolve as many PORT1TO1_skirmish_logic.md §13 [U] as statically possible; concrete port change list"
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
labels: [O, D, I, U]
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. Donor binary never executed/copied. Donor text scripts read as text only. No repo code/asset/config/Godot/git change: this report is the only file written."
network: "OUT OF SCOPE. No multiplayer/netcode specified, audited, or changed."
parity: "NO PARITY CLAIM. No donor GPU A/B frame; no donor binary executed by this worker."
upstream: "PORT1TO1_skirmish_logic.md §1-14 (18 approximations, 20 [U]); IMPL-SKIRMISH-1TO1 v5 save state (labels, no values); D02 (RNG), DFORM-01 (morale absence), T6-M01 (gold-fire-stop), X09 (starts), X21 (RNG vectors), V01 (versions/derived keys)"
---

# DEC-U-SKIRMISH — static resolution of skirmish-logic [U]s (2026-11-26)

## 0. Authority and discipline (read first)

Every statement is `[O]` (verbatim donor bytes/text lines read this ticket), `[D]` (deterministic reading of `[O]`), `[I]` (interpretation, flagged), or `[U]` (UNVERIFIED — a concrete settling experiment is given in §9; the port must **hard-fail or label PORT APPROXIMATION**, never silently substitute). The single most important structural finding: **the skirmish sim is script-driven** — all numeric law below lives in shipped donor text (`data/scripts/...`, `data/game/var/...`, `data/cameras/...`), not in static EXE code. Three native passes pinned to `t_87f0f3c130b0` returned zero matches for `SetRandomKey` / `RandomExt` / `bfamine` / `famine` / `victorystate` / `0.03125` as designed: these identifiers are script-side (expected negative, §1). Prior binary-side results (D02 LCG, X21 vectors, V01 version bands) are cited, not re-derived.

**DSL note `[D]` (load-bearing for every literal below):** in donor script, `not X` prefixed to a numeric lvalue is the current-value read operator, NOT boolean/bitwise negation. Proof: `res.script:326` (`if (sellamount>not gPlayer[plInd].res[sellres])`), `res.script:302/327/337` (arithmetic on `not gPlayer[plInd].res[...]`), `player.script:301-302` (`stat.resonlife[i]+not gPlayer[plInd].res[i]`). So `not res[gold]<4` parses as `(value res[gold])<4`. All predicates below are read with this rule.

## 1. Pass ledger (owner rule; every native call pinned `document:"t_87f0f3c130b0"`)

| # | Pass | Result |
|---|---|---|
| P1 | `core_session_show` | active `t_87f0f3c130b0`, Deep mode, 547 evidence records, 1 unknown; `editor.exe t_68474ddde43f` present, untouched |
| P2 | `core_feature_find "SetRandomKey"` | **negative** `ev_c3804981595ae8e32f7250a675c54ac38863fa5625a8409059224652a93981f4` — 0 strings/functions/imports (script-side identifier, as expected) |
| P3 | `core_feature_find "RandomExt" / "bfamine" / "famine"` | **negative** (all three: 0 matching strings/functions/imports) — famine/morale law is script-side |
| P4 | `native_bytes_find text "victorystate" + "bfamine"` | **negative** — 0 matches utf8+utf16le (script-side state) |
| P5 | `native_bytes_find pattern "0D FC"` | `ev_4dd1780e0bbdb16190c7009abf5f33f0a0d90092007f04019e45dd25ee1025bf` — 33 short-pattern hits (e.g. `0x41259d,0x443afb,0x443b69…`); **rejected as RNG evidence** (2-byte pattern is non-specific; D02's LCG finding stands on its own) |
| P6–P30 | 25 donor-text read/grep passes (outside Craft Anything, `C:\Games\Cossacks 3\data\...`) | all `[O]` in §2–§8, each with file:line |

## 2. RESOLVED or structurally closed this ticket (donor literals)

### 2.1 Famine + rebellion numeric law — RESOLVED (was U11; corrects bible §6)

`data/scripts/units/unit.inc/nothing.inc:450-506` — per-tick unit block (inside `Nothing` state handler):

- Gate `[O]`: `gProfile.bFamine and (gPlayer[plInd].bfamine) and (bplayable)`, then mode `game/spectator`, then `not building and not bnohungry`.
- Inside-of-mine branch (`:456-479`) is **commented out** (`{...}`) — dead, do not port.
- Death roll `[O]` (`:482`): `(((difficulty>1) or lan_cached) and (RandomInt<50)) or ((difficulty=0) and (RandomInt<5)) or ((difficulty=1) and (RandomInt<12))` → `_unit_SetTagStates(go, essential_death)`.
- `_misc_RandomInt` `[O]` (`lib/misc.script:493-498`): `floor(random*gc_c1rand_to_random)`, `gc_c1rand_to_random=32768` (`dmscript.global:176`). So thresholds are **per-tick P(death)=50/32768 (hard/veryhard+LAN), 5/32768 (easy), 12/32768 (normal)** — no grace timer, no HP drain. Port `FAMINE_GRACE_S=120`/`FAMINE_DRAIN_PER_S=0.3` is wrong-shape and must be deleted.
- Rebellion `[O]` (`:487-497`): gate `brebellion and bmercenary and (plInd<>mercenaryind) and bplayable`; flip roll `(diff>1 and RandomInt<6000) or (diff=0 and RandomInt<100) or (diff=1 and RandomInt<200)` → `_misc_ChangePlayer(go, mercHnd, False, False, True)`.
- Upkeep engine `[O]` (`lib/player.script:270-322`): per-res `mult=100, speed=20000`; `resconsume*=gc_time_to_frames(32)`; `bank=remains/100+resconsume*dt; realbank=bank/20000; value=floor(realbank)`; deduct-or-flag: shortfall → `bfamine:=True` (food) / conditional `brebellion` (gold, only if `consume>income`); surplus path adds `not res` (value-read) to `stat.resonlife`. Clearing `[O]` (`:318-321`): `brebellion:=False` iff `not (res[gold]>=2)` or consume<=0; `bfamine:=False` iff `not (res[food]>0)` or consume<=0.
- Mine gold rate `[O]` (`player.script:233-238`): `rawconsume=(resconsume[gold]*32/100)/250` — port `MINE_INCOME=13*32/250` shape needs re-check against this exact line (note `*32/100`, i.e. frames→per-100).
- Income engine `[O]` (`player.script:240-266`): same accumulator shape with `speed=256/1.024` (=250.0 exactly).

### 2.2 Market dynamics — RESOLVED as wrong-shape in port (was U6; corrects bible §6)

`lib/res.script:180-309`:

- Per-res buy/sell tables `[O]`: food buy(20/25/40) sell(def 18.24095*0.8333≈15.20, min ×0.7, max ×1.3); wood buy(40/50/60) sell(20/30/40); stone buy(40/50/60) sell(def 19.29725*1.08306≈20.90, min ×0.75, max ×1.25); gold buy(140/190/240) sell(80/110/140); iron/coal buy(100/140/180 → +40 shift: min 80+20? verbatim `buycostmin:=80+20; buycostdef:=100+40; buycostmax:=120+60`) sell(40/60/80); else buy(40/50/60) sell(20/30/40). `buyexp=sellexp=gc_economy_exp=0.00002` (`dmscript.global:810`), `buytime/selltime=gc_economy_time=0.0001*32=0.0032` (`:811`); costs init to def (`:247-248`).
- Trade `[O]` (`:313-344`): `buyamount=floor(sellamount*sellcost[sell]/buycost[buy])`; sell clamped to `not res[sell]`; buy side pushes both costs toward max via `weight=buyamount*buyexp`, sell side pulls both costs toward min via `weight=sellamount*sellexp`.
- Recovery `[O]` (`:291-308`): the old linear `buytime*deltatime` block (`:279-286`) is **commented out**; live law is exponential `bc-(bc-bcd)*dt` with `dt=deltatime*0.025*MaxFloat(1, garr_res_dlt[i]*0.01)`, clamped to [min,max]. `garr_res_dlt/trg` from `_res_CalcDeltaResources` (`:252-268`, project-mode-gated).
- Market-dip modes `[O]` (`dmscript.global:1077-1081`: 0 default / 1 nodip / 2 nomarket / 3 noboth / 4 expensivemercs; effects `player.script:2741-2763`: nodip zeroes dip-center usage, nomarket deletes `bmarket` buildings, noboth both, expensivemercs rewrites merc costs).
- Port verdict `[D]`: single `MARKET_RATE/DRIFT/RECOVERY` scalar model cannot express per-res 6-column tables + weight pushes + exponential recovery. Replace, do not retune.

### 2.3 Capture predicate — SUBSTANTIALLY RESOLVED (was U4; bible §7)

`lib/miscext.script:963-~1100` (`_misc_CheckCapture`):

- Cadence `[O]`: `lasttimecheckcapture+gametimewithrnd`, interval `gc_unit_TimeCheckCapture=0.1*19-eps` / art `0.1*5-eps` (`dmscript.global:1479-1480`); jitter init `random*TimeCheckCapture` (`miscext2.script:2757`).
- Scan `[O]`: scangrid cells over `floor(captureradius/scangrid_size)+1`, `rx1`; `gc_gameplay_captureradius=214/gc_pixels_to_tile` (`dmscript.global:208`; px→m /26.666… → ≈4.01 m), blockshot `160/px` (≈3.0 m), protection `426/px` (≈7.99 m); squared variants precomputed (`:217-220`).
- Capturer filter `[O]` (`:1011`): skip iff capturer `bcapture or media=water` (walls use `_unit_SearchCapturersForWall`); require `distSqr<captureradiusSqr`; `bblockshot` iff also `<captureblockshotradiusSqr`.
- Non-peasant + blockshot ⇒ **100-frame** attack lock `attackmaxdelay/attackdelay=Max(...,100*gc_frames_to_time)` (`:1036-1040`).
- Map gating `[O]` (`nothing.inc:516-518` + `unit.script:11340`): default always checks; `capture=onlyartillery` restricts to `bart`; non-capturable / mine / center / market usages excluded as targets.
- Still `[U]`: protector-count majority rule (lines ~1050-1100 tail not read this ticket) and post-capture cooldown. Experiment in §9-C1. [SUPERSESSION-FIX: point-in-time/historical claim, not current — RESOLVED by `DEC_U_skirmish_tables.md` §3 / `DEC_U_capture_state.md` §§1-2 (C1 RESOLVED: ANY-protector veto + AI-artillery majority table; NO post-capture cooldown; port `capture_t` retired to dormant v5 key); parity UNVERIFIED — NO PARITY CLAIM.]

### 2.4 Gold-fire-stop — RESOLVED verbatim (was U9)

`lib/unit.script:8181-8209`: `bAttackPauseOk = melee or attackdelay=0`; `if bturnoff and (res[gold]<4)` → `attackmaxdelay/attackdelay=Max(...,100*gc_frames_to_time)` (=3.125 s), `bEnoughRes=False`, interface-player log `cantshootnogold`; else `_unit_EnoughResForShot(go,weapon)` with 64-frame lock on failure. Port `_GOLD_FIRE_STOP_RES=4.0` / `_GOLD_FIRE_STOP_S=100/32` (`game.gd:4832-4833,5741-5742`) are **exact** — keep, rewire comment to cite `unit.script:8185-8209`, and confirm the 100 is consumed as frames→seconds (it is: `/32`).

### 2.5 Defeat/liveness + peacetime — SUBSTANTIALLY RESOLVED (was U12; bible §8)

`data/scripts/units/global.inc/progress.inc:60-148`:

- `gMap.bbattle` ⇒ `bexists=True` always (battle missions exempt).
- Else `bexists=(farmused>0)`, with 0<farmused<100 fallback: scan peasant section for any unit with `visual_none+essential_none` tags (or human-owned inside-transport), else scan building section for built `usage=center`.
- `not bexists and (AI or human)` ⇒ `_misc_KillPlayerUnits`, first transition stamps `victorystate=lose + GetGameTime`, `_misc_LanServerSendResults`.
- Tick fragment order `[O]` (`:144-178`): exists-check → `_player_ProcessResourceIncome` → `_player_ProcessResourceConsume` → squad hold-mode progress (`fHoldModeProgress+=dt/gc_squad_holdmode_time`, `gc_squad_holdmode_time=150*8*0.03125=37.5 s` per `dmscript.global:180`) → `CheckSquadsDisband` (non-AI) → `ProgressAI` (AI or adviser-enabled). Partial answer to U1 (per-player slice; global interleave still [U]).
- Peacetime `[O]`: `progress.inc/nothing.inc:658`: `gbool_peacemode and gametime>gfloat_peacetime` gate; `readpeacetime.inc/writepeacetime.inc` serialize the flag; `gfloat_peacetime:=0` default (`serial.script:272`); room setup `peacetime` field (`miscext2.script:2375/2635`).
- Score `[O-absent]`: no score-limit victory in any readable script — port `VICTORY=score/SCORE_LIMIT=5000` is PORT EXTENSION with no donor counterpart. Keep only behind explicit non-1:1 flag.

### 2.6 Morale absence — RE-CONFIRMED (was U10; bible §7)

This-ticket greps over `data/scripts/lib` (+units/miscext): `morale|rout|panic|flee|veteran|experience` → **0 matches**; `bfamine|bFamine|starv|hunger` → only `bfamine/bFamine` boolean + profile flag (`classes.script:3695,5122`; `player.script:122,295,304,320-321`; `profile.script:39`). DFORM-01's absence claim holds. Runaway behavior is a move-mode (`gc_obj_move_mode_runaway`, `miscext.script:628,1225,1258,1274`); shooter fallback delays `runawaydelay=1.3/runawaydist=3.5` (`dmscript.global:198-199`). Disband-fraction literal (`basecount*0.25`) cited by bible from `dmscript.global:156/progress.inc:5-35/squad.script:98-107` was **not re-read this ticket** → replacement wiring stays [U] (experiment §9-M1). Port `data.gd:139-143` already self-labels MORALE_* as invention — delete, do not wire.

### 2.7 Damage/protection matrix shape — STRUCTURE RESOLVED, rows [U] (was U7; bible §7)

- Weapon rows `[O]` (`lib/weapon.script:39-62,314-329`): `_weapon_AddWeapon(ind, sid, fx, projbasename, damage, radius, gravity, propagation, physvalue, time)`; e.g. `NUCL2P 340dmg r=35px angle g2 t=Inf`, `NUCL3M 800 r=60px`, `NUCL3MONONEW 0dmg`. Radius units are pixels pre-`_misc_PixelsToTiles` (several rows) — port must apply `/26.666…` (and tiles `/2` where tile-space).
- Protection `[O]` (`lib/unit.script:510-517` + `classes.script:3582`): `objbase.protection[6]` = (pike, sword, bullet, cannister, arrow, cannonball); rows set per-sid, e.g. `:762` → (5,3,8,225,17,80); `:739` → (3,3,7,225,16,80). Full per-sid audit is mechanical text work (no binary needed) — experiment §9-T1.
- Application function (damage−protection combination, tower/wall kind-gate U3) **not located** this ticket → still [U] (experiment §9-T2).

### 2.8 Starts — TABLES LOCATED, values PARTIAL (was U13; bible §2)

`data/game/var/startingsettings.cfg:87-~720+`: `startid` blocks (−1 example all-zero `:89-97`; 0/1/2/3/4 at `:183/:187/:314/:503/:720` with `addresources{food,wood,stone,gold,iron,coal}` + `countries[]{allowedcountries[], addresources{}, legends[]{key,role,countrysid,basename}}`). Observed foods: startid 1 → 1000, 2 → 20000, 3 → 20000 (`:191/:318/:507`); −1/0 → 0. Remaining five resources per block + peasant legend rows not transcribed → experiment §9-S1 (pure text read, no GPU). Donor dispatch (`common.inc/dogenerate.inc:230-~300`): `startingunits>default` → per-player `startid` match → `addresources` ×6 → `allowedcountries` first-match → `CreateUnit` — matches X09; `bOnlyModifyPatternMask` two-insertion split confirmed at call site.

### 2.9 Camera — NUMBERS RESOLVED (was U17; corrects bible §9)

`data/cameras/camera.cfg:1-65`: `FreeRotationInfo` pitch **−32° at all heights** (`:32-35`), `SphereHeight=SphereLength=58`, min 20 (`:6-10`), `MinFocalLength=MaxFocalLength=400` (`:44-45`, zoom fixed), velocities/raycast steps (`:13-28`), DynFog (Start 0.25, End 0.025, Density 2.0, Power 0.85, `:59-64`). Port height 58 / pitch −32 are DONOR-GROUNDED (remove their [U] tags); FOV 17.27° stays [U] (focal px→angle needs sensor width — experiment §9-V1). `minimap.cfg` (22,749 B, `data/gui/minimap.cfg`) exists — minimap-box rule recoverable statically (§9-V2).

### 2.10 Derived-key derivation — ANSWERED (bible §12-b): donor does NOT derive

D02/X21/V01 (cited, not re-derived): `RandomExt` LCG, state words `0x9048d4/d8`, key0 discarded; 11×`SetRandomKey` + 3×`SetRandomExtKey64` all **identity** (same-key skip-ahead); Delphi `Random()` second instance (`sub_7281bc`, `0x8088405+1`) only where consumed. Port `_reseed_stage` (`game.gd:290-292`: `seed+si*1000003+ver*10007`) is PORT APPROXIMATION with no donor counterpart — replace with verbatim identity reseeds at the D02/D1 sites. `GetRandom(n)=floor(RandomExt*n)` (`dogenerate.inc:990-997`); Godot `randi_range/randf_range` rounding differs — wrap all sim draws. `brng`/`gen_rng`/local-`RandomNumber.new` extra streams (`game.gd:2028-2029,1446`) have no donor counterpart — delete from sim.

### 2.11 Small grounded literals (scattered [U] closures)

- Gather hits `[O]`: food 22 / wood 14 / stone 20 (`dmscript.global:799-801`, via `_res_GetHitsNeeded`, `res.script:348-358`).
- Repair `[O]`: `+gc_gameplay_repairhp=20` hp per construct hit (`units/unit.inc/onaclanimationreachedconstruct.inc:41`; `dmscript.global:211`).
- Delivery radius `[O-shape caveat]`: global `resourceDropRadius=3` (`dmscript.global:210`, port `DELIVERY_RADIUS_M=3 tiles` grounded) BUT `unit.script:9704-9705` shadows `resourceDropRadiusSqr=0.5` in carry-drop check and `:12032-12033` uses `4*4` for fisher — port must branch per call site (§9-E1).
- Conversions `[O]`: `px/m /26.6666666, m/tile 2, frames→s ×0.03125, s→frames ×32, c1rand→random /32768` (`dmscript.global:170-176` + `_misc_RandToRandom :486-490`, `_misc_PixelsToTiles` implied by `weapon.script:317` usage).
- Build pacing `[O-shape]`: `buildtime_modifier=10, c1toc3_framedifference=1.15, progressperhit=10*0.03125*1.15` (`:179-182`); `BuilderDist=1.0/Shift=0.5` (`:160-161`); AI `maxpeasants` 5/2 literals (`unit.script:9098-9104`).
- AI sampler thresholds `[O]` (`unit.script:3638-3665`): `guards<gc_ai_max_guards` gates with `RandomExt<_misc_RandToRandom(3000/6000/10000/20000)`; `freewarriors>15` priest branch (`:3649`); `lightinfantry` 20000-branch (`:3665`).
- Save framing `[O-shape]`: per-record `write*.inc/read*.inc` pairs (`units/global.inc/writeplayer.inc`, `writesync.inc` 5272 B, `writewall.inc` 11393 B…) + `serial.script:1035-1036/1106` (`fBaseCount/fStandGround` round-trip) — field lists are statically enumerable; byte framing (`[*] =` engine-bound lines) still [U] (§9-R1).

## 3. Still-[U] register (each with exact settling experiment; no approximation)

| # | Item (bible U#) | Static state after this pass | Exact experiment (owner-authorised) |
|---|---|---|---|
| M1 | Disband-fraction + runaway wiring (U10-replacement, U2-part) | Absence proven; literal `*0.25` NOT re-read | Read `squad.script:98-107` + `dmscript.global:156` + `progress.inc:5-35` + `misc.script CheckSquadsDisband` body; then runtime: 4:1-butchered squad, 60 s capture, assert disband event + `runaway` move-mode on survivors. No rout meter. |
| C1 | Capture majority/cooldown tail (U4) | Head 80% recovered §2.3 | Read `miscext.script:1050-1130` (protector loop, `capturerCount` use, `_misc_ChangePlayer` call args); runtime: N-vs-M peasant ring, log `lasttimecheckcapture` cadence + ownership flips. |
| T1 | Per-sid stat rows (U14) | Shape+examples §2.7 | Mechanical audit script over `unit.script` `SetObjBase*` + `weapon.script` `_weapon_AddWeapon` rows vs `data.gd` UNITS/BUILDINGS/WEAPONS; every row cite-or-tag. No binary needed. |
| T2 | Damage application + tower/wall kind-gate (U3, U7) | Not located | Grep `protection\[` consumers in `unit.script` attack path (~lines 8100-8360) + `tow/wal/gat` usage checks; runtime: per-kind shot log vs walls/towers. |
| D1 | Dispersion/height bonus (U8) | Not in readable text | Grep `dispers|scatter|height|hill|bonus` in `unit.script` shot fns; runtime: fixed-range volley spread σ + height-differential damage pairs. Until then delete port ×1.25/ARROW175-except-archer. |
| Q1 | Train/research timing + queue caps (U5) | Only maxpeasants 5/2 | Read `player.script` producer fns (`CreateConstructionDummy`, train/research cost-time, `artlimit/artcount :375`); runtime: queue-length sweep, batch-5/100 provenance (likely PORT EXTENSION — delete if absent). |
| S1 | Start stock/peasants per preset (U13) | Foods only §2.8 | Transcribe `startingsettings.cfg:183-720+` six-resource blocks + `legends` peasant rows; wire `addresources` ×6 verbatim (incl. double-add policy decision per X09-7). Text-only. |
| R1 | Save format contract (U15) | Field lists enumerable §2.11 | Enumerate `write*.inc/read*.inc` field order for player/unit/squad/wall/trade records; declare save PORT EXTENSION with explicit non-parity contract + full-state round-trip test (RNG states, queues, cooldowns, projectiles, stamps). |
| V1 | FOV/zoom (U17-tail) | 58/−32/400 fixed §2.9 | Read `default.cameras` + `cameradebug.cfg`; runtime: matched-pair screenshot solve for sensor width → FOV. Never video-derived. |
| V2 | Selection predicate + projection + minimap box (U16, U18-part) | Engine-side | Ghidra + GL trace per audit Q-4; static head-start: `minimap.cfg` (22 KB) + `initminimap.inc:5-7,17,33` + `onmousemove.inc:141-152`. |
| F1 | Fog-of-war rule (U18) | DynFog numbers §2.9; gameplay flag `gbool_editor_fogofwar` (`dmscript.global:2120`) + `fogreveal` basename (`:965`) | Grep `fogreveal|fogofwar|visibility` consumers in `player.script`/`miscext2.script`; runtime: explored-vs-visible minimap pairs. Default stays explicit cut. |
| E1 | Delivery-radius call-site split (new) | §2.11 caveat | Confirm which gather/drop/fisher call sites use global 3 vs local 0.5/4.0 (`unit.script:9704,12032`); port branches per site. |
| A1 | AI thresholds full table (U19) | Sampler + maxpeasants only §2.11 | Read `progresswarai.inc:2799-2832` fear selector + `progresseconomicai.inc` build order; label everything else PORT-AI. |
| O1 | Global tick interleave (U1-tail) | Per-player slice §2.5 | Recover `progress.inc:1-60` head (addtime/stagger `0.125*plInd`, `TimeCheckExists`) + `nothing.inc` progresstick cadence; freeze `TICK_ORDER v1 PORT APPROXIMATION` + fixed-seed hash test meanwhile. |
| G1 | RNG draw ledger (U20) | Streams/law cited §2.10 | X21 20-vector fixture + per-site draw-count test; assert `floor(n)` mapping at every sim draw. |

## 4. Concrete port change list (owner/COORD applies; this worker wrote no code)

1. **`variant3d/scripts/data.gd:74`** `START_PEASANTS=8` → X09/§9-S1 preset table (peasants from `legends` rows per `startid`; keep `8` only as explicitly-tagged fallback).
2. **`data.gd:81-132` (MORALE/FAMINE block)** → delete numeric morale stack (`MORALE_BASE/ROUT_THRESHOLD/OFFICER/DRUMMER/BONUS/LOW_HP/FAMINE_PENALTY`, `OFFICER_DAMAGE_BONUS/DRUMMER_SPEED_BONUS`, `PRIEST_HEAL_RADIUS/PER_S` at `:99-110`); replace famine with §2.1 roll (`RandomInt<50/12/5`, gates `gProfile.bFamine ∧ bfamine ∧ playable ∧ game/spectator ∧ ¬building ∧ ¬bnohungry`); add rebellion flip (`6000/100/200`, mercenary-only, `plInd≠mercenaryind`); wire `bfamine/brebellion` set/clear exactly per `player.script:294-321`.
3. **`data.gd:133-138` (MARKET)** → replace scalar model with §2.2 per-res tables (food sell ≈15.20/min ×0.7/max ×1.3; stone sell ≈20.90/min ×0.75/max ×1.25; full table in report), `floor(sell·sellcost/buycost)` trade, weight pushes to max/min, exponential recovery `dt=deltatime·0.025·Max(1,δ·0.01)`, dip modes 0-4.
4. **`game.gd:290-292` `_reseed_stage`** → delete `seed+si*1000003+ver*10007` derivation; implement verbatim identity reseeds at D02/D1 sites; split streams (mapgen/sim/art/test); route every sim draw through `floor(RandomExt·n)` wrapper (`game.gd:265-267,145,260,417,2028-2029,1446,5711,5726,5736,5628` + scatter sites `:654,683-684,703,705,834,864,870,873,1199-1201` + `:2252-2505` brng).
5. **`game.gd:5745-5810` `_apply_hit` + `game.gd:5659-5814` `_fire`** → rewire onto §2.7 shapes (weapon-row damage/radius-px→m, 6-kind protection array); remove height ×1.25 (`:5407-5410`), wall-between test, non-archer dispersions, `dist/30` flights, 0.45 s arrow, cap-512, 2.0 s deploy (`:5376-5399,5556` → donor deploy still [U]-D1/Q1, tag APPROXIMATION); keep gold-fire-stop `:5741-5742` + cite `unit.script:8185-8209`.
6. **`game.gd:6234-6267` victory** → replace OR-liveness/score/peace defaults with §2.5 `bexists` rule (`farmused>0` + peasant/center fallback; battle-mode exempt; lose-stamp + kill-units); delete `SCORE_LIMIT=5000` or gate behind non-1:1 flag; peacetime from `gbool_peacetime/gfloat_peacetime` surface.
7. **`game.gd:3030-3151` starts + `data.gd:278-306` nations** → consume `startingsettings.cfg` (startid match, 6-res `addresources`, `allowedcountries` first-match, two-insertion quirk per X09-7); `MAX_PLAYERS=12` (`data.gd:219`) stays PORT EXTENSION vs donor `gc_MaxNonSpectatorsCount=8` unless scoped out.
8. **`game.gd:5455-5566` queue + `hud.gd:806-981`** → cap/batch/multiplier set from §9-Q1; `BUILD_QUEUE_LIMIT=10/MAX_BUILDERS_SENT=8/batch 5/100/endless` tagged PORT EXTENSION until `player.script` producer audit lands.
9. **`game.gd:212-213` fields + gather** → hits-needed 22/14/20, repair +20/hit, delivery-radius per-site split (§2.11-E1); `FIELD_REGROW_TIME=60`, `SOW_COST=5` stay APPROXIMATION until X22/`unit.script` literals (§9, `game.gd:607,2940,2980,5920-5928`).
10. **`game.gd:6304-6401` serialize v4** → add missing state (tileblock/mine_mask/pattern_stamps/nav_version/rng+gen_rng states/projectiles/corpses/cooldowns/acq) + round-trip determinism test; declare PORT EXTENSION contract (§9-R1); `deserialize` v3 path needs proof test or removal.
11. **Camera/HUD (`camera.gd/camera3d.gd`, `config.gd:48-51,76-78`, `input_controller.gd:1-120`, minimap `hud.gd:345-368`)** → pin pitch −32 / height-length 58 / focal 400 (§2.9); FOV/selection-painter/picking/minimap-box stay APPROXIMATION-tagged (§9-V1/V2).
12. **`ai.gd` thresholds/cheat/famine-recall** → replace with §2.11 sampler literals + §9-A1 table; fear selector `progresswarai.inc:2799-2832` only grounded bit; rest labelled PORT-AI.
13. **Telemetry/format** → keep `PORT APPROXIMATION` tags per-field (bible §14 items 1-18 map 1:1 onto changes 1-12 above + DEC_ATTACK_WORK_ACTIONS pose gap, item 18); `visual_parity_claim=false`; unresolved list = [M1,C1-tail,T1,T2,D1,Q1,S1,R1,V1,V2,F1,E1,A1,O1,G1].

## 5. Explicit non-claims and file discipline

- No parity claimed. No donor binary executed, no GPU frame captured, no port capture compared. Closed items rest on donor text `[O]` with file:line; open items list exact next reads/captures in §3.
- No approximation substituted: every recovered literal replaces a port estimate 1:1; everything else remains a labelled `[U]` with a settling experiment.
- Read-only compliance: exactly one repo file written (this report). Native passes were pinned to `t_87f0f3c130b0` (P1-P5); shared Craft Anything investigation memory was read, never written; no target opened/selected/closed by this worker.

*End of DEC-U-SKIRMISH.*
