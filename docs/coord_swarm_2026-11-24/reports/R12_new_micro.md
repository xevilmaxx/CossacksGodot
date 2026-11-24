---
owner: R12
decision: D-22
date: 2026-11-24
title: "New donor skirmish micro-features + re-check of MICRO's 3 open questions"
scope: "read-only donor text (latin-1) + port *.gd reads; one output file; no Godot run"
---

# R12 — new micro-features & MICRO re-checks

> Baseline = `docs/audit/MICRO.md` (68 rows). Donor read from `C:\Games\Cossacks 3`
> with `open(...,'rb')` + latin-1 only; no donor file run or copied. Port facts
> from `app/scripts/*.gd` and `app/assets/models/anim/**`. Everything below is
> **NEW relative to the 68**; overlaps already-ticketed rows were excluded after
> verification (capture modes, difficulty tiers, mine exhaustion, repair-by-many,
> population-limit warning and veteran XP are now IMPLEMENTED and are *not*
> re-listed here).

## 1. NEW features (donor → port)

| Name | Donor evidence (`path:line` + literal) | Port state (`app/scripts/...`) | Impact | Size | Proposed ticket |
|---|---|---|:---:|:---:|---|
| **23-slot log-message ticker** (`log.*`) | `lib/classes.script:4600-4622` `logmessage[gc_logmessagesid_terrainpreventsshot] := cloglocale+'terrainpreventsshot'` … 23 ids; literal strings `data/locale/en/gui.txt:45-77` — `The terrain profile prevents you from firing.`, `You have neither coal nor iron. %s1% is unable to fire.`, `WARNING! YOU HAVE NO GOLD! MUTINY IS INEVITABLE!`, `Improvement complete: %s1%`, `You are very low on food!`, `You are very low on iron and coal! ...ammunition soon.` | **PARTIAL** — only famine `game.gd:4046`, unit-limit `game.gd:3750`, generic capture `game.gd:5321`, building-lost `game.gd:4103`; no terrain/obstacle-shot, no-gold/no-ammo, low-food/gold/shoot, upgrade-done or built messages anywhere in `say()` calls | 🟠 MED | M | **R12-01** |
| **Off-screen under-attack / capture ALARM** (type + world coords + throttle) | `lib/misc.script:6152-6178` `if (not gSoundManager.IsObjInFrustum(trgHnd)) then gbool_gui_doalarm := True; gfloat_gui_alarmx := ...` + event remap `attack→attacked`, `capture→captured`; `dmscript.global:858-861,1122-1126,1227` `gc_gui_alarmevent_*`, `gc_gui_underattackalarminterval = 135`; fired at `lib/miscext.script:1140,366`; labels `lib/classes.script:4619-4622` | **PARTIAL→MISSING** — `main.gd:1263-1265,1270-1271,1288-1289` plays only the `alarm` *sound* on `rout`/`upgraded`/`capture`; no event type, off-screen gating, coords or HUD/minimap ping; grep `alarm` in all `*.gd` = those 3 lines only | 🟠 MED | M | **R12-02** |
| **Capture blocked by nearby gunfire** (`bblockshot`) | `dmscript.global:207,217` `gc_gameplay_captureblockshotradius = 160/gc_pixels_to_tile`; `lib/miscext.script:1023-1024` `if distSqr<gc_gameplay_captureblockshotradiusSqr then bblockshot := True;` then `:1036-1039` `if (usage<>peasant) and bblockshot then attackmaxdelay := MaxFloat(...,100*gc_frames_to_time)` | **MISSING** — `game.gd:5266-5287` gates capture only on `peas/sols` count and a live `guard` order; no shot-radius check | 🟠 MED | S | **R12-03** |
| **Capture cancels the victim's queued production + in-progress upgrade** | `lib/miscext.script:1115-1132` `if orders[i].iType=gc_obj_order_type_produce ... _unit_ProduceUnit(...); orders[i].info.amount := 0` … `gc_obj_order_type_performupgrade : _unit_CancelUpgradePerform(goHnd, ...)` then `_unit_ClearOrders(goHnd)` | **MISSING** — `game.gd:5298-5321` flips `e.player`, score, farm_cap, captured_nations; no queue/upgrade clear (no `queue.clear/erase` or upgrade-cancel in the capture block) | 🟠 MED | S | **R12-04** |
| **Artillery captures ~4× faster than infantry** | `dmscript.global:1479-1480` `gc_unit_TimeCheckCapture = 0.1*19-gc_unit_TimeEpsilon` / `gc_unit_TimeCheckCaptureArt = 0.1*5-gc_unit_TimeEpsilon`; `units/unit.inc/nothing.inc:512-515` artillery uses the shorter gate | **MISSING** — `game.gd:5289` single `speed_c := peas*1.0 + sols*0.25` for every unit kind; `def.artillery` not consulted | 🟡 LOW | S | **R12-05** |
| **Randomised, staged corpse decay** (not one fixed timer) | `units/unit.inc/deathstage1.inc:64-76` `const maxalpha=1; const minalpha=0.4; ... time := 2+time-random*(time/1); DoSemiTransparent(...); GameObjectMyDelayExecuteState('DeathStage2', time)`; stages 2/3/4 in `deathstage2.inc`/`deathstage4.inc:4-8`; `dmscript.global:186-194` `gc_unit_deathtime_1=20`, `_1ship=10`, `_2art=30`, `_3=4` | **PARTIAL** — `data.gd:56` `CORPSE_LIFE := 90.0` (config `config.gd:65,388`); `game.gd:3856-3857` one expiry, `:4082` spawn, cap 600 `:4083`. Fade exists in `world.gd:3286+` but no randomness, no stages, no ship/artillery split (row 64 covers *existence*, not timing) | 🟡 LOW | S | **R12-06** |

**Explicitly checked and rejected as already covered** (no new ticket): map
capture modes (`dmscript.global:1072-1075` → `config.gd:450`, `game.gd:2722-2729,5260`);
5-tier difficulty (`dmscript.global:781-786` → `config.gd:434-439,504-508`,
`main.gd:291-356`, `menu.gd:696`); mine depletion (`game.gd:5225-5238` kills the
mine + "exhausted" say); repair by many peasants (`miscext2.script:4593-4602`
list → `game.gd:4129-4135,4606-4623` per-peasant `_work_slot`, 1 stone/hit);
population warning (`gui.txt:55-56` → `game.gd:3750`); veteran XP
(`game.gd:3037-3055`, `data.gd` SQUAD_XP_* — **stale MICRO row 55**).

## 2. Re-check claim table (the 3 MICRO open questions)

| # | Claim | Evidence | Method | Verdict | Action |
|---|---|---|---|---|---|
| a | `world.gd` loads `<sid>_s1..s4` **and** the PNGs exist | `world.gd:719-730` `_bld_tex`: `var si := clampi(int(progress/build_time*4.0),0,3)+1; var st := _bld_anim("%s_s%d" % [bk, si])`; `_bld_key :593-603` resolves `ven_tow`; `_bld_anim :633-649` + `_anim_dir :488-495` resolve `res://assets/models/anim/<nat>/buildings/<key>.png`; files present e.g. `app/assets/models/anim/ven/buildings/ven_tow_s1.png` … `ven_tow_s4.png` (also `ven_sto`, `ven_hou`, `ven_mil`, `ven_cen`, `ven_bla`, `ven_mar`, `ven_dip`, `ven_sta`; **1016** `*s?.png` under `models/anim/**/buildings`) | Direct code read + recursive file glob of asset dir | **CONFIRMED (both halves)** | Close MICRO open Q4 and the sprite half of row 43; construction *stage art* is IMPLEMENTED (the `hud.gd:452,766` bar plus 4 baked frames). Do not open a "bake stage sprites" ticket. |
| b | Formation keeps its order after moving — any port code? | Donor `lib/squad.script:111-145,199-263` keeps a persistent slot map `TSquad.arGrid[row,j]`, `fNeedRebuild`, and reassigns slots with `_misc_SortListByDirection(...,-dirX,-dirZ)` / per-row sort `:247-258`; `lib/group.script:115,162` uses `GroupGameObjectsGridSetGameObjectHandlePosition`. Port `game.gd:3258-3285` `_squad_order_members` rebuilds `all` from `s.members` each order and assigns `targets[fi]` **by array index**; `formation_targets :3288-3329` recomputes offsets every call; `input_controller.gd:495-506,599-609` uses selection order. No `slot`/`arGrid`/persistent position in any `*.gd` | Whole-file grep (`slot|arGrid|formation|order`) + read of both assignment paths | **CONTRADICTED** (donor confirmed; port side = CONFIRMED MISSING) | MICRO row 54 UNVERIFIED → **port gap confirmed**. Formation offsets exist but *order preservation* does not: slots are derived from mutable array order, never sorted by current position/facing. Open one S-sized ticket to persist a slot map on the squad dict (or record ACCEPTED DIVERGENCE); close Q5's formation half. |
| c | Squad disband — any code/selftest? | `game.gd:3238-3249` `squad_disband(sid)` erases `squad` id from officer/drummer/members and `squads.erase(sid)`; hotkey `config.gd:125` `squad_disband: Shift+F`, dispatch `input_controller.gd:778,793-797`; UI button `hud.gd:644-646` `Disband` → `_on_squad_disband :816-818`; **two automated checks**: `selftest.gd:251-255` (`passed: game.squads.is_empty()`) and `uitest.gd:195-220` (`squad_keys`, includes `disbanded … "yes" if dis_ok`) | Static read of all 5 call sites and both test assertions | **CONFIRMED** | Close MICRO row 56 and Q5's disband half: disband is fully wired and double-tested. Only re-run the two named tests if the coordinator wants a live green; no code work. |

## 3. Top-5 ranked actionable NEW gaps

| Rank / ticket | Target file | Minimal change | Acceptance criterion | Determinism risk |
|---|---|---|---|---|
| 1 · **R12-01** log ticker | `game.gd` (near `say` `:2800`), `hud.gd` log area, `data.gd` (message ids) | Add `post_event("log", id, args)` + a `LOG_MSGS` string table copied from `gui.txt:45-77`; emit at the existing failure sites (shot blocked, no gold/iron, upgrade done, low food/gold/shoot) with a per-id sim-time cooldown | 23 donor ids have a string; firing the matching condition produces exactly that text once per cooldown; famine/unit-limit messages keep their current wording | **LOW** — text + event only; use `dt`-based cooldown, never `Time.get_ticks_msec()` |
| 2 · **R12-02** off-screen alarm | `game.gd` (`post_event` sites), `main.gd:1250-1292`, `hud.gd` | Extend `post_event` with `alarm{type,pos}` on attacker/capture events; `main.gd` maps to the 4 donor event types, replaces sound-only branch with a timed HUD/minimap marker and throttling | Attacking/capturing an off-screen owned building raises the correct one of the 4 alarm types at the target coords, throttled to donor cadence; an on-screen attack does not alarm | **MED** — donor uses `IsObjInFrustum` (view-dependent). In headless/replay use a deterministic proxy (distance from camera focus) and keep alarm state in `game`, not `main` |
| 3 · **R12-03** capture gunfire block | `game.gd:5266-5287` (capture loop) | Record most-recent friendly shot position/time per player from `_fire`; if any shot within `160/gc_pixels_to_tile` in the last N sim-seconds, disqualify non-peasant capturers | A lone soldier cannot advance capture while friendly/foe shots land within the donor radius; a peasant still can; same input replay gives identical capture % | **MED** — depends on shot-event ordering; store in a fixed-order dict keyed by shooter id and advance with `dt` |
| 4 · **R12-04** capture clears queue | `game.gd:5298-5321` (success block) | On owner flip, clear the building's training `queue` and any in-progress upgrade, mirroring donor `_unit_ClearOrders`/`_unit_CancelUpgradePerform` | Capturing a barracks/academy mid-production leaves it with an empty queue and no pending research; the old player is not refunded; new player can immediately queue | **LOW** — pure dict mutation in an existing deterministic branch |
| 5 · **R12-05** artillery capture rate | `game.gd:5289`, `data.gd` | `if (u.def.artillery) speed_c += 19/5 - 1` (donor check-cadence ratio) or add a `capture_rate` per unit kind | An artillery piece contributes ~3.8× a soldier's capture progress; infantry/peasant speeds unchanged; formation/capture-mode gating unaffected | **LOW** — numeric, no new RNG |

*(R12-06 corpse staging is table-only this pass: the fixed 90 s life is player-visible but low frequency, and donor's `random*(time/1)` must be routed through the seeded sim RNG to avoid desync — do not bundle casually.)*

## 4. Open questions

1. **Alarm frustum parity.** Donor's off-screen test is camera-dependent; the port has no camera in headless. Need an owner decision on a deterministic replacement before R12-02 is scoped beyond sound.
2. **Log-message cooldowns.** Donor throttles some messages via `lastattacktime`/adviser intervals; exact per-id cadence beyond `gc_gui_underattackalarminterval = 135` is not pinned down. Use a conservative shared cooldown and tune after a replay.
3. **`bblockshot` owner.** Donor applies the 100-frame attack delay to the *captured* object's `attackmaxdelay`, not the capturer; intent (suppress defender fire vs suppress capturer) is `inferred`. Confirm with one live capture under fire before wiring R12-03.
4. **Donor locale `misc|log.alarm*` strings are absent from `data/locale/en/*`.** I found the 4 ids in `classes.script:4619-4622` but no English literals; R12-02 needs owner-supplied wording or reuse of the existing "under attack" text.
5. **Stage-sprite cross-nation coverage.** Only the `ven` folder was spot-checked by name; 1016 `*s?.png` exist overall. If full parity is required, enumerate `<nat>_<sid>_s1..s4` for every `Data.PLAYER_NATIONS` before declaring row 43 fully closed.

---

**Files changed by this worker:** `docs/coord_swarm_2026-11-24/reports/R12_new_micro.md` only.
**No donor file copied or executed; no Godot run; no other file edited.**
