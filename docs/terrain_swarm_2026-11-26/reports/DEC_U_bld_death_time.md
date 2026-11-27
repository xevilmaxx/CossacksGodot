---
id: DEC-U-BLD-DEATH-TIME
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: "WORKER DEC-U-BLD-DEATH-TIME — donor 1:1 building-death time-base static probe"
owner_file: docs/terrain_swarm_2026-11-26/reports/DEC_U_bld_death_time.md
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_ASSET_CONFIG_GODOT_GIT_EDIT
created: 2026-11-26
labels: [O, D, I, U, NO_PARITY_CLAIM, NO_APPROXIMATION]
parity_guard: "NO DONOR PARITY IS CLAIMED. No same-camera donor/port A/B frame was produced or examined. Every donor statement is a read-only file/line/byte observation; every port statement is a read-only source line. No duration, loop count, or TTL is invented."
scope_guard: "Exactly one repo file written (this report). No source, shader, config, asset, fixture, test, runner, Godot, git or user-mod edit. Donor binary and donor data tree read READ-ONLY; no donor executable run, no donor bytes copied into the repo. Singleplayer skirmish only."
donor_pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe (PE x86, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c). Data tree C:\\Games\\Cossacks 3\\data read READ-ONLY. Pin re-verified this session via certutil (ev_pin_reverify). Binary never executed."
port_scope: "variant3d/scripts/data.gd:122-123 (DEC_U_BUILDING_DEATHTIME_FRAMES / DEC_U_BUILDING_DEATHTIME_S_SHOWN) + variant3d/scripts/world3d_entities.gd death-schedule call sites (read-only line citations)"
prior_reports_read:
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_smoke_burn_ttl.md ([U]-BURN/[U]-EX/[U]-TTL framing, §6-§7)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_death_families.md (shared selector, 30/30, mine x2)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_unit_death_art.md ([U]-T time-base, E-T capture)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_entities_art_collision.md (gc_frames_to_time/gc_time_to_frames, deathtime keys)
---

# DEC-U — building death time-base probe (new static angles)

> READ-ONLY. Singleplayer skirmish only. No parity claim. No approximation endorsed.
> Each `[U]` ends in either a static verdict with cited bytes/lines, or a named GPU/runtime capture.
> The 30-valued constants remain destroy-scheduling keys, never a visual/smoke TTL — endorsed nowhere in this report.

## 0. Method, labels, passes

- **[O]** = observed donor file line / directory entry / binary byte string / port line. **[D]** = arithmetic over cited [O] (offsets, counts, products). **[I]** = reading without runtime proof. **[U]** = unresolved after the passes here.
- Path shorthands: `D:` = `C:\Games\Cossacks 3\data\` (read-only). `P:` = workspace `variant3d\`. `c3` = pin `t_87f0f3c130b0`.
- `ev_` ids below are this session's pass-evidence ids (all against the pin; binary never executed).

### 0.1 Pass ledger (multiple passes on the pin; strange-read log inline)

| Pass | Operation (read-only) | Evidence | Result |
|---|---|---|---|
| P1 | Pin re-verify: `certutil -hashfile cossacks.exe SHA256` + length | `ev_pin_reverify` | `87f0f3c130b0…`, `5,768,048 B` [O] — pin confirmed, binary not executed |
| P2 | Full re-read `D:scripts/dmscript.global:170-199` TTL/clock block | `ev_global_ttl` | `gc_frames_to_time=0.03125`, `gc_time_to_frames=32`, `gc_building_deathtime_0/1=30`, full `gc_unit_deathtime_*` row [O] (§2) |
| P3 | Full re-read `D:scripts/units/building.inc/settagstates.inc` (61 lines) + `deathstage1.inc` + `deathstage2.inc` + `delaydestroy.inc` | `ev_stage_full` | 3 building death-scheduling call sites, raw constants, mine `*2` only, no frame-time multiply [O] (§3) |
| P4 | Full re-read `D:scripts/lib/misc.script:460-482` + repo-wide grep `_misc_FramesToTime` consumers | `ev_timebase_check` | Helper defined once; used for weapon pause / buildtime / upgrade time; **zero** death-scheduling uses [O absence] (§3) |
| P5 | Repo-wide grep `DelayExecuteState` (30 hits) + `GetTimeSpeedFactor/GetCurrentTime/GetGameTime/DeltaTime` + building.inc `EffectClear/PFXClear/buildingsmoke` | `ev_delay_sites`, `ev_smoke_stop` | Full caller inventory; smoke stop is transition-clear + destroy, gated `not bdead` [O] (§3-§5) |
| P6 | Packed CODE byte search over `cossacks.exe` (5,768,048 B, Python `read_bytes`+`find`, no execution): counts + file offsets for `DelayExecuteState/CancelDelayExecuteState/GetTimeSpeedFactor/GetCurrentTime/GetTotalTime/GetGameTime/SetGameTime/GetRealTime` vs `deathtime/DeathStage1/DeathStage2/buildingsmoke/FramesToTime/gc_building/gc_unit_deathtime`; PE section parse (`e_lfanew`, `ImageBase=0x400000`) → FO/RVA/VA table; 90-byte ASCII context per hit | `ev_code_bytes` | API-table entries byte-proven in CODE with `Float ftime/time` signatures [D]; script identifiers 0 hits [D] (§2) |
| P7 | `D:scripts/units/building.inc/ontagstates.inc` death-case grep + `nothing.inc:1-120,293-424` smoke-block re-read (client+server) | `ev_ontag_full`, `ev_nothing_full` | Death order: sound + `MyGameObjectPFXClear` → mesh swap + misc-child clear + gated `DoExplosion`; smoke attach only under `not bdead`, throttle `mod 7`, detach on heal [O] (§5) |
| P8 | Shipped `.map`/profile search: `D:maps/missions/` listing (67 files) + `battle1.map` (56,117,715 B) byte-count for `death/deathtime/buildingsmoke/DeathStage1/2`; `D:game/var/` listing + text grep `death/smoke/deathtime` | `ev_map_profile` | 0 hits in binary map; 0 hits in all 11 `game/var/*.cfg` [O absence] (§4) |
| P9 | Port anchor re-read `P:scripts/data.gd:122-123` + `P:scripts/world3d_entities.gd` death-schedule comments | `ev_port_reread` | `DEC_U_BUILDING_DEATHTIME_FRAMES=30`, `DEC_U_BUILDING_DEATHTIME_S_SHOWN=30*FRAMES_TO_TIME=0.9375 s; shown, not endorsed` [O] (§6) |
| P10 | Cross-check vs DEC_U_smoke_burn_ttl §6-§8 + DEC_U_death_families §2 + DEC_U_entities_art_collision P11 | `ev_xcheck` | Agreement on facts/keys/gates; this report adds only the CODE VA table + zero-hit negatives + wrapper verdict; no prior [D] overturned |

**Strange-read log:** none blocking. (a) PowerShell `Select-String` quoting fault on worker side (backtick/brace) bypassed by using the repo `grep` tool + Python `pathlib` reads — donor bytes untouched. (b) Binary `grep` via ripgrep returned 0 hits for `deathtime` while Python `bytes.find` confirmed the same 0 — both methods agree, recorded as one negative. (c) No donor `.map` text was assumed parseable; the 56 MB `battle1.map` was treated as opaque bytes and only counted, never decoded.

---

## 1. New static angle (a): packed CODE byte search — API table + clock helpers [O/D]

Image: `ImageBase=0x400000` [O] (`OptionalHeader.Magic=0x10b`, `e_lfanew=0x100`) via `ev_code_bytes`. Section: `CODE VA 0x1000, file 0x400, size 0x4F0E00` [O]. Formula used: `RVA = 0x1000 + (FO - 0x400)` for `FO` inside CODE; `VA = 0x400000 + RVA` [D].

### 1.1 Hit counts over the full 5,768,048 B (byte-proven) [D]

| Key | Count [D] | Verdict |
|---|---|---|
| `DelayExecuteState` | 12 | [O] native API family present (table §1.2) |
| `CancelDelayExecuteState` | 3 (subset of the 12 lines) | [O] cancel pair present |
| `GetTimeSpeedFactor` | 1 | [O] single clock helper entry |
| `GetCurrentTime` / `GetTotalTime` / `GetGameTime` / `SetGameTime` / `GetRealTime` | 1 each, contiguous cluster | [O] time-source cluster |
| `deathtime` / `Deathtime` / `DEATHTIME` | 0 | [D] absence: TTL constant name not embedded in binary |
| `DeathStage1` / `DeathStage2` | 0 | [D] absence: state names are script-side only |
| `buildingsmoke` | 0 | [D] absence: effect key is script/pfx-side only |
| `FramesToTime` | 0 | [D] absence: `_misc_FramesToTime` is a script function, no native of that name |
| `gc_building` / `gc_unit_deathtime` | 0 | [D] absence: `gc_*` constants live in `dmscript.global` text, not in CODE |

Only byte-proven upgrades to [D] are the counts/addresses themselves and the absence statements above (dual-method: Python `find` + ripgrep agree on `deathtime`).

### 1.2 API-table VA register (all in CODE, read-only strings, never executed) [O/D]

Context is the 90-byte printable window per hit (`ev_code_bytes`); signatures are the donor's own API-table declarations, not worker inference.

| # | File offset (FO) [O] | RVA [D] | VA [D] | Printable declaration [O] |
|---|---|---|---|---|
| 1 | `0x23B923` | `0x23C523` | `0x63C523` | `function GetGameObjectDelayExecuteStateNameByHandle(gohandle: Integer): String` |
| 2 | `0x23B9C0` | `0x23C5C0` | `0x63C5C0` | `procedure GameObjectDelayExecuteStateByHandle(gohandle: Integer; const state: String; ftime: Float)` |
| 3 | `0x23BA2E` | `0x23C62E` | `0x63C62E` | `procedure GameObjectMyDelayExecuteState(const state: String; ftime: Float)` |
| 4 | `0x23BA86` | `0x23C686` | `0x63C686` | `procedure GameObjectCancelDelayExecuteStateByHandle(gohandle: Integer)` |
| 5 | `0x23BAD8` | `0x23C6D8` | `0x63C6D8` | `procedure GameObjectMyCancelDelayExecuteState` |
| 6 | `0x25C369` | `0x25CF69` | `0x65CF69` | `procedure SetGroupGameObjectsDelayExecuteStateByHandle(grhandle: Integer; const statename: String; aoffset, anoise, ainc: Float)` |
| 7 | `0x25FC42` | `0x260842` | `0x660842` | `function GetGroupDelayExecuteStateNameByHandle(grhandle: Integer): String` |
| 8 | `0x25FC93` | `0x260893` | `0x660893` | `procedure GroupDelayExecuteStateByHandle(grhandle: Integer; const state: String; ftime: Float)` |
| 9 | `0x25FD01` | `0x260901` | `0x660901` | `procedure GroupCancelDelayExecuteStateByHandle(grhandle: Integer)` |
| 10 | `0x27131D` | `0x271F1D` | `0x671F1D` | `procedure GUIDelayExecuteState(const state: String; const time: Float)` |
| 11 | `0x271370` | `0x271F70` | `0x671F70` | `function GetGUIDelayExecuteState: String` + `function GetGUIDelayExecuteTime: Float` |
| 12 | `0x3AF64D` | `0x3B024D` | `0x7B024D` | `DirectDelayExecuteTime / DirectDelayExecuteState` (scheduler-adjacent names, same CODE) |
| C1 | `0x29EDD6` | `0x29F9D6` | `0x69F9D6` | `function GetTimeSpeedFactor(): Float` (preceded by `SetTimeSpeedFactor(factor: Float)`) |
| C2 | `0x29EEA2` | `0x29FAA2` | `0x69FAA2` | `function GetCurrentTime(): Float` |
| C3 | `0x29EECE` | `0x29FACE` | `0x69FACE` | `function GetTotalTime(): Float` |
| C4 | `0x29EEF6` | `0x29FAF6` | `0x69FAF6` | `function GetGameTime(): Float` + `procedure SetGameTime(val: Float)` |
| C5 | `0x29EF4A` | `0x29FB4A` | `0x69FB4A` | `function GetRealTime(): Float` |

**[D] verdict (angle a):** the delay scheduler is a native `Float`-taking API (`ftime`/`time: Float`), not a frame counter at the declaration site. The clock helpers exist natively (`GetTimeSpeedFactor/GetCurrentTime/GetTotalTime/GetGameTime/SetGameTime/GetRealTime`), each exactly once and clustered. The building-death constants, state names, smoke key, and `FramesToTime` have **zero** CODE bytes — they are script/pfx-side text, so no native wrapper constant-folding them is visible in the string table. The native scheduler *body* (seconds vs ticks) is NOT in the string table and stays unproven — §3 keeps [U].

---

## 2. New static angle (b): death-state transition code — is either 30 multiplied? [O]

### 2.1 The only building death-scheduling lines in readable script [O]

`settagstates.inc:39,46-50` (`ev_stage_full`, full 61-line read, re-verified):

- `:39` birth-path: `GameObjectMyDelayExecuteState('DeathStage2', gc_building_deathtime_1)` — raw constant, no arithmetic.
- `:46-50` completed-building path: `var deathtime : Float = gc_building_deathtime_0;` → `if mine then deathtime := deathtime*2;` → `GameObjectMyDelayExecuteState('DeathStage1', deathtime)` — the ONLY multiply is the documented mine `×2`.

`deathstage1.inc:7-11` (`ev_stage_full`): `var deathtime : Float = gc_building_deathtime_1;` → `if mine then deathtime := deathtime*2;` → `GameObjectMyDelayExecuteState('DeathStage2', deathtime)` — again mine `×2` only.

`ontagstates.inc:333-334` wall tail (`ev_ontag_full`): `GameObjectMyCancelDelayExecuteState; GameObjectMyDelayExecuteState('DelayDestroy', gc_unit_deathtime_3)` — raw, with the LAN-unsync comment carried from prior reports.

### 2.2 `_misc_FramesToTime` exists but touches none of the above [O absence]

Definition `misc.script:470-474`: `Result := (val*gc_frames_to_time)` [O]. Consumers repo-wide (`ev_timebase_check`): `weapon.script:333,337,349-362` (projectile `pause`/`life` construction), `unit.script:539` (weapon pause), `:576` (`objbase.buildtime`), `:2625` (pause decrement), `country.script:632` (upgrade time). **Zero** `DelayExecuteState` + `FramesToTime` co-occurrences at any death call site (`ev_delay_sites` 30-hit inventory checked line-by-line). The attack-delay path instead decrements with `GetGameTime` deltas (`nothing.inc:27-29,329-334`), and `progresstick` is the `mod-7` throttle counter, not a clock conversion.

**[D] verdict (angle b):** at every readable building death transition the `30` values are passed **unscaled** (mine `×2` is the sole arithmetic). No `×0.03125` / `×32` / `_misc_FramesToTime` wrapper exists on the path. Whether the native `ftime: Float` parameter (§1.2) *means* seconds or ticks is therefore entirely a property of the packed scheduler body, which static text cannot see — the TIME BASE stays **[U]** (§6). The port's `DEC_U_BUILDING_DEATHTIME_S_SHOWN = 30 * FRAMES_TO_TIME` remains a shown-not-endorsed arithmetic display, not a proven conversion.

---

## 3. Time-source context the script DOES show (bounds, not proof) [O/I]

- `GetGameTime` deltas drive per-tick logic: `deltatime := GetGameTime-lastprogresstime; attackdelay := MaxFloat(attackdelay-deltatime, 0)` (`nothing.inc:27-29`, server mirror `:329-334`) [O]; slow-death HP drain `hp -= floor(deltatime*gc_BuildingSlowDeathSpeed)+1` (`:123`, `:458`) [O]. So `GetGameTime` behaves like a seconds-scale float in script arithmetic [I — behaviour inferred from use, not a native spec].
- GUI/store call sites pass second-scale literals to the same scheduler family: `GameObjectDelayExecuteStateByHandle(Result, 'FreeToPool', 10)` (`gui.script:3038`, `soundcontrol.inc:109`) [O]; `GUIDelayExecuteState('DoAutoSave', 3)` (`scenario.script:3099`) [O]; `GameObjectDelayExecuteStateByHandle(goHnd, 'SetRallyPoint', gc_unit_opentraptime=1.3)` (`unit.script:11810`) [O]; `SailToDestroy` at `gc_unit_SailToDestroyTime=5` (`progresswarai.inc:3926`) [O]. Consistent with seconds, but the GUI/group schedulers need not share the game-object scheduler's unit — recorded as a bound, **not** a proof. TIME BASE stays [U].

---

## 4. New static angle (c): shipped `.map` / profile death-timer defaults [O absence]

- `D:maps/missions/` lists 67 files (`34 .map` + `33 .aix` + `battle*.map`) [O] (`ev_map_profile`).
- `battle1.map` (56,117,715 B) byte-count: `death` 0, `deathtime` 0, `buildingsmoke` 0, `DeathStage` 0 [D — counted, opaque bytes never decoded].
- `D:game/var/` lists 11 cfgs (`battles/campaigns/envscales/formations/generator/hotkeys/objcustom/random/startingsettings/units/wallcustom`) [O]; text grep `death|smoke|deathtime` over the directory: **0 hits** [O absence].

**[D] verdict (angle c):** no shipped map or `game/var` profile carries a death-timer default that could override or rescale the `30/30` script constants. (Player-profile `bFamine`-style overrides are a separate family and out of scope; no cfg writer for death timing exists in readable text.)

---

## 5. New static angle (d): are `buildingfire/buildingsmoke` loopers stopped by a timer or by state-clear only? [O/D]

Re-reads: `nothing.inc:17-137` (client) + `:293-493` (server) are line-identical in the smoke logic (`ev_nothing_full`); `ontagstates.inc:82-91,264-316` (`ev_ontag_full`).

1. Attach gate [O]: both smoke branches sit under `if (not arg_obj.bdead)` (`:19`, `:293`). After `OnDeath→_unit_DestroyObj` sets the dead flag, **zero new `GetOrCreate('buildingsmoke')` executes**; `progresstick` increments (`:136`, `:492-493`) sit inside the same `not bdead` blocks, so the `mod 7` throttle stops advancing for the dead object.
2. Throttle [O]: attach proceeds only on `(progresstick mod 7)=0` AND a `random>freq` roll, max ONE attach per qualifying tick (`break` at `:79`/`:384`), target `maxind` from the HP fraction (`:43`/`:348`).
3. Death-transition clear [O]: non-wall `MyGameObjectPFXClear` (`ontagstates.inc:88`) on the `switchEssential=death` case; misc-racetag children `BehaviourClear + EffectClear + RequestToDestroy` (`:294-296`) on the death branch (`:289-298`); wall-only tail `EffectHighlightRemove + EffectClear(myHnd)` (`:315-316`). No `DelayExecuteState`/timer argument appears on any clear line.
4. Holder destroy [O]: `DeathStage2` → `_misc_UnitTopologyUpdate` + `GameObjectRequestToDestroyByHandle(myHnd)` for non-walls (`deathstage2.inc:8-15`) — the holder destroy ends the `samLoop/Free=False` children whose PFX lifetime is unbounded in data (`source.pfx:2050-2062`, carried from DEC_U_smoke_burn_ttl §1.2).
5. Negative [O absence]: no `EffectClear`/`BehaviourClear`/`MyGameObjectPFXClear` call site in `building.inc/` references `gc_building_deathtime_*`, `progresstick`, or any second count; the constants reference ONLY the two `DelayExecuteState('DeathStageN', …)` schedulers (§2.1).

**[D] verdict (angle d):** looper stop is **event-driven only** (transition clear + holder destroy), with pre-death attach count bounded by the HP→`maxind` walk and the `mod-7` throttle — there is no timer-based smoke TTL in readable script. Burn duration / smoke stop therefore cannot be `30` or `0.9375 s` under any time base; both stay [U]-BURN only insofar as the *wall-clock* length of the `_death1→_death2→destroy` windows (E-U14-ttl) and the rendered looper tail are uncaptured (§6).

---

## 6. What stays [U] and the fixed-camera captures that terminate each item

TIME BASE, burn wall-clock, and smoke render-tail stay **[U]**. Nothing below is closed by a port fallback; no `FRAMES_TO_TIME` conversion is applied to any scheduling constant until E-U14-ttl terminates.

- **E-U14-ttl (delay-unit probe — terminates [U]-TIME only):** singleplayer skirmish, fixed camera (record `camera.position/projection`, target world pos, `GetTimeSpeedFactor` on screen), non-mine mill victim. Log wall seconds death-tag → `_death2` swap → destroy (game-time + frame counter) across 3 runs. **Terminates iff** offsets equal ONE of `30.0 s` / `0.9375 s` / other within **±1 frame** consistently; the outcome is recorded as the scheduler's unit and STILL never copied onto any effect TTL (per §5, stop is event-driven).
- **E-U14-burn (attach/stop frame log — terminates [U]-BURN):** damage the mill in ~10% HP steps at fixed camera; log per frame `hp/maxhp`, `smokecount`, `progresstick mod 7`, each `GetOrCreate('buildingsmoke')` attach frame + smoke-point index, each detach frame; then kill it and log `_death1` swap, `debris` child, `deathbld` audible frame, explosion spawn frame(s), every smoke-holder `EffectClear`/destroy, `_death2` swap, destroy frame. **Terminates iff** across 3 runs: (i) attaches satisfy `mod 7 = 0` with **0 off-tick attaches**; (ii) post-death attach count is **exactly 0**; (iii) all pre-death holders cleared by `DeathStage1` at latest (**0 surviving loopers** past the `_death2` swap); (iv) ruin persists with **0 smoke** until destroy.
- **E-U14-ex / E-U14-snd:** carried unchanged from DEC_U_smoke_burn_ttl §7 (explosion keys `grenadeexp`+`expflash`, sound `deathbuilding1/2` onset ±1 frame, `burn1..7` logged as observed-never-wired).

Until all applicable captures terminate: keep `DEC_U_BUILDING_DEATHTIME_FRAMES` (scheduling only, never a `life`/TTL argument), keep `DEC_U_BUILDING_DEATHTIME_S_SHOWN` labelled shown-not-endorsed, keep the two-stage ruin swap on the delay chain, and keep `RALLY_TTL`-style placeholders untouched.

---

## 7. Exact port anchors (file/line; no code written here)

| # | Port site (current [O]) | Donor fact (this job [O]/[D]) | Required donor-faithful handling (no invented TTL) |
|---|---|---|---|
| T1 | `data.gd:122-123` `DEC_U_BUILDING_DEATHTIME_FRAMES := 30` / `DEC_U_BUILDING_DEATHTIME_S_SHOWN := 30 * FRAMES_TO_TIME # 0.9375 s; shown, not endorsed` | `gc_building_deathtime_0/1=30` (`dmscript.global:183-184`) [O]; CODE VA table §1.2 proves `Float ftime` scheduler [D]; no wrapper multiply (§2.2) [O absence] | Keep both lines verbatim; keep the `shown, not endorsed` guard. `FRAMES` feeds ONLY the `DeathStage1/DeathStage2` delay arguments; `S_SHOWN` feeds NO scheduler, NO `life`/TTL, NO FX span. Cite this report §2 at the use site |
| T2 | `world3d_entities.gd` death-schedule comments (`Data.DEC_U_BUILDING_DEATHTIME_S_SHOWN (shown, not endorsed)`) | Schedulers take raw `30` (mine `×2`), unit [U] (§2-§3) | Do not resolve the comment to either `30.0 s` or `0.9375 s` until E-U14-ttl terminates; scheduling stays on the `FRAMES` constant (opaque unit) |
| T3 | Death-edge smoke/FX/sound path (`BLD_DEATH_SMOKE_KEY`, `add_impact_fx`, `explode` stand-in — see DEC_U_smoke_burn_ttl §8 B1/B2/B5) | Smoke stop is event-driven (§5) [D]; explosion `grenadeexp`+`expflash`, sound `deathbld` (prior [O]) | No change from this report beyond the guard in T1; B1–B5/F1–F3 remain owned by DEC_U_smoke_burn_ttl and need E-U14-ttl/burn/ex/snd first |

---

## 8. Claim register

| # | Claim | Label |
|---|---|---|
| 1 | `gc_building_deathtime_0/1=30`, `gc_frames_to_time=0.03125`, `gc_time_to_frames=32` | [O] `dmscript.global:174-175,183-184` |
| 2 | Building death schedulers pass raw `30` (mine `×2` only); no `FramesToTime` multiply on the path | [O] `settagstates.inc:39,46-50`, `deathstage1.inc:7-11`; absence `ev_timebase_check` |
| 3 | Native scheduler declarations take `Float ftime/time`; clock helpers `GetTimeSpeedFactor/GetCurrentTime/GetTotalTime/GetGameTime/SetGameTime/GetRealTime` exist in CODE | [O] strings at §1.2 FO/RVA/VA; [D] counts/addresses |
| 4 | Script identifiers `deathtime/DeathStage1/DeathStage2/buildingsmoke/FramesToTime/gc_building/gc_unit_deathtime` have 0 CODE bytes | [D] full-binary counts (`ev_code_bytes`) |
| 5 | No shipped `.map`/profile death-timer default (`battle1.map` 0/0/0/0; `game/var/*.cfg` 0 hits) | [O absence/D counts] `ev_map_profile` |
| 6 | `buildingsmoke` stop is transition-clear + holder-destroy; 0 post-death attaches; no timer TTL | [O] `nothing.inc:19,293`, `ontagstates.inc:88,294-296,315-316`, `deathstage2.inc:8-15`; [D] lifecycle |
| 7 | TIME BASE (seconds vs ticks/frames) for the `30` scheduling values | **[U]** — E-U14-ttl terminates (§6) |
| 8 | Burn wall-clock / smoke render-tail length | **[U]**-BURN — E-U14-burn terminates (§6) |
| 9 | `DEC_U_BUILDING_DEATHTIME_S_SHOWN` (0.9375 s) is shown, not endorsed; never flows into a TTL | [O] `data.gd:122-123` + this §7 T1 |
| 10 | Any port building-death visual/audio equals donor motion/timing/sound | **Denied** — no same-camera donor/port A/B exists; parity UNVERIFIED |

## 9. Scope statement

Exactly one repository file was written by this worker: this report. All donor reads were read-only against pin `t_87f0f3c130b0` (binary never executed) and the read-only `C:\Games\Cossacks 3\data` tree. No source, shader, config, asset, fixture, test, runner, Godot, git or user-mod state was changed. No donor parity, similarity score, threshold or gate PASS is claimed. Network is out of scope.

*End of DEC-U-BLD-DEATH-TIME.*
