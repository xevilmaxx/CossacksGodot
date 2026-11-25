---
id: S01-SPEED-AUDIT
ticket: S01 (WAVE S — SPEED OPTIONS)
title: "S01 — full game-speed pipeline audit (variant3d), read-only"
owner: S01 read-only subagent
date: 2026-11-25
status: READ_ONLY_AUDIT__NO_CODE_EDITS__NO_RUNNER_JOB__NO_GODOT
scope: "Exactly one repo file written: this report. All variant3d sources were READ ONLY; no backup created, no patch applied, no Godot process or runner ticket."
labels: [observed, derived, inferred, UNVERIFIED]
charter: docs/terrain_swarm_2026-11-25/CHARTER.md
wave_charter: docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
---

# S01 — game-speed pipeline audit

## 0. Authority / method

- `WAVE_G_CHARTER.md:31,154-155` — only G04 runs Godot / runner jobs; `hud.gd` is contested
  (P12 also proposes it) and COORD grants one owner after G04. This agent ran **no** Godot.
- `CHARTER.md:55-69` — OBSERVED / DERIVED / INFERRED / UNVERIFIED separation; no test
  weakening; disjoint ownership; backups before edits. None apply to a report-only ticket.
- Method: direct source reads of `variant3d/scripts/{hud,main,config,data,game,ai,input_controller,uitest}.gd`,
  `variant3d/tests/{t_hud_layout,t_menu_roster,t_motion_capture}.gd`, `inbox/backup/hud.gd.bak*`,
  plus literal greps for `Engine.time_scale`, `_physics_process`, `speed_menu`, `set_speed`.
  **No execution, no capture, no measured FPS.** Every dynamic claim is labelled.

## 1. Executive summary

| # | Finding | Label |
|---|---|---|
| E1 | The top-bar dropdown does **not** top out at x8 — it has exactly four items `II / 1x / 2x / 4x` (`hud.gd:444`). x8 exists only as a **clamp** (`main.gd:362,722`) and as `--fast` (`main.gd:1350-1351`). The charter/owner wording is stale. | **OBSERVED** |
| E2 | There is **no** `Engine.time_scale` and **no** `_physics_process` anywhere in `variant3d` (literal greps returned zero matches). Speed is a custom accumulator in `_process`. | **OBSERVED** |
| E3 | Selecting a speed: `OptionButton.item_selected` → `_on_speed_idx` → `_on_speed` → `speed_cb` lambda in `main.gd` → `set_speed()` → clamp → `hud.refresh_speed()`. | **OBSERVED** (chain at §4) |
| E4 | The fixed step stays `1/Data.FPS = 1/32 s`; high multipliers add **more ticks per frame**, never larger ticks. So x16/x32/x64 do not by themselves corrupt sim semantics. | **DERIVED** from `data.gd:32`, `main.gd:1617,1621-1631` |
| E5 | The binding limit is `steps < 64` per frame (`main.gd:1621`) = **2.0 sim-seconds/frame**. x8 at the worst dt is exactly at that limit; x16/x32/x64 need 128/256/512 ticks and will be truncated on slow frames, growing `acc` without bound. | **DERIVED** (math in §6.1); downstream lag **INFERRED** |
| E6 | `t_hud_layout.gd:61-62` hard-codes the option labels/metadata; adding options **will fail 6 checks** (3 viewport sizes × label + metadata) unless those constants are updated. Updating them to list the new real items is not test weakening. | **DERIVED** from `t_hud_layout.gd:61-62,424,432` |
| E7 | Safest addition: append items in `hud.gd:444`, raise only `main.gd:722`'s upper clamp (and optionally `:362`), and add an accumulator saturation so high speeds degrade instead of building a tick debt. Leave `selected=1`, donor ids, `Data.FPS`, and the 64-step cap untouched. | **INFERRED** proposal (S02 owns exact hunks) |

## 2. Pipeline map (exact file:line)

| Stage | file:line | Observed behaviour | Label |
|---|---|---|---|
| Top-bar option list | `variant3d/scripts/hud.gd:444` | `speed_menu = _mkoption([["II",0.0],["1x",1.0],["2x",2.0],["4x",4.0]], 1)` — pause + x1/x2/x4; **default selection index 1 = x1** | OBSERVED |
| Option helper | `hud.gd:490-501` (metadata cast at `:498`) | Each item's label is text, metadata is `float(it[1])`; `selected = 1` at `:499` | OBSERVED |
| Legacy API shim | `hud.gd:108` | `speed_buttons: Array = []` — kept empty for readers; no more speed Buttons | OBSERVED |
| Read-out label | `hud.gd:452`, `:637` | `"%.0fx" % sp`, or `"PAUSED"` | OBSERVED |
| Donor config map | `data.gd:385` | `DONOR_GAME_SPEED = {slow:0.5, normal:1.0, fast:2.0, very_fast:4.0}` — **x0.5 exists here (menu/config), not in the top-bar dropdown** | OBSERVED |
| Settings-file path | `config.gd:588` (`apply()`) | `Data.GAME_SPEED = _donor_id("game_speed", Data.DONOR_GAME_SPEED.keys(), "normal")` — key `game_speed`, donor ids only | OBSERVED |
| In-menu path | `menu.gd:757,951` → `main.gd:354` | Menu emits `"gamespeed": <donor id>`; `_donor_cfg(cfg, ["gamespeed"], ...)` maps it back through `DONOR_GAME_SPEED` | OBSERVED |
| Config → runtime speed | `main.gd:360-362` | Only when CLI did not force a speed (`speed == 1.0`): `speed = clampf(DONOR_GAME_SPEED[Data.GAME_SPEED], 0.1, 8.0)` — config ids can reach x4 max | OBSERVED |
| CLI overrides | `main.gd:1350-1354` | `--fast` sets `speed = 8.0` (bypasses `set_speed`); `--speed` uses `maxf(0.1, value)` with **no upper clamp** — x16/x32/x64 are already reachable from CLI | OBSERVED |
| Setter clamp | `main.gd:721-724` (`set_speed`) | `speed = clampf(s, 0.0, 8.0)` then mirrors HUD; this is the hard UI ceiling | OBSERVED |
| Time-scale application | `main.gd:1587,1614-1631` | `dt = minf(dt,0.25)` → `acc += dt*speed` → `step = 1/Data.FPS` → `while acc >= step and steps < 64` → `game.tick(step)` → `brain.tick(step)` | OBSERVED |
| Sim tick guard | `game.gd:4281-4284` | `if paused or winner != -1: return`; `dt = minf(dt, TICK_MAX)` with `TICK_MAX = 0.25` (`data.gd:54`, rebound `game.gd:407`) | OBSERVED |
| AI cadence | `ai.gd:67-76`; `data.gd:73` | Every fixed tick decrements `think_t`; think fires at `AI_THINK_INTERVAL = 1.0` **sim-second** | OBSERVED |
| Presentation clock | `main.gd:1671` → `world3d.gd:682-683` → `world3d_entities.gd:2019` | `world.sync(dt)` receives **raw** dt, not `dt*speed`; `_anim_t` is wall-clock, while sim positions come from scaled ticks | OBSERVED |
| Capture cadence | `main.gd:1730,1737-1743` | Screenshot after `screenshot_frames` **rendered frames** (default 120, `:69`); sequence frames keyed to `game.time_s` (`seq_step` clamp 0.25..30 at `:1311`, `seq_max = 600` at `:94`, CLI twin at `:2175-2182`) | OBSERVED |
| CLI-mode stepping | `main.gd:2148-2160` | `_run_cli_incremental()` ticks by `cli_ticks_cap` / `cli_frame_ms`; **never reads `speed`** — CLI matches ignore game speed | OBSERVED |

## 3. Reality check on "currently tops up at x8"

**OBSERVED:** the live dropdown at `hud.gd:444` is `II / 1x / 2x / 4x`. The same four items
appear in the pre-UI-TOPBAR-01 button loop in every inspected backup
(`inbox/backup/hud.gd.bak-agentSC:245`, `hud.gd.bak:115`, `hud.gd.bak-HUD01:394`,
`hud.gd.bak-CONFIGWIREH:401`, etc.). A `git log -S '8x' -- hud.gd` returned no commit.
`P12_hud_fix_proposal.md:170` independently records the same four-item list.

**DERIVED:** the "x8" in the owner/charter wording corresponds to the numeric ceiling
`clampf(..., 0.0, 8.0)` in `set_speed` (`main.gd:722`) and the `--fast` shortcut
(`main.gd:1351`), not to any selectable UI item. Therefore the request effectively means:
**add x8 as a real UI item first, then x16/x32/x64**; there is no existing x8 item to preserve.

## 4. Selection → application call chain (exact)

1. `hud.gd:446` — `speed_menu.item_selected.connect(_on_speed_idx)`.
2. `hud.gd:605-608` — `_on_speed_idx(idx)` bounds-checks and reads
   `speed_menu.get_item_metadata(idx)` (the float from `:498`).
3. `hud.gd:646-649` — `_on_speed(sp)` plays click audio and calls `speed_cb.call(sp)`.
4. `main.gd:626-632` (async load) / `main.gd:1145-1151` (direct load) — the lambda:
   `s <= 0.0` → `game.paused = true` (does **not** change `speed`);
   otherwise `game.paused = false`, `set_speed(s)`, `hud.refresh_speed(speed, paused)`.
5. `main.gd:721-724` — `set_speed` clamps to `[0, 8]` and calls `refresh_speed`.
6. `hud.gd:635-644` — label update, then `_speed_index(sp)` (`:597-603`, exact float
   match with `<0.01`, fallback index 1) drives `speed_menu.selected`; programmatic
   assignment emits no `item_selected`, so there is no feedback loop.

**DERIVED consequence of the fallback:** with `--fast` (x8) or `--speed 16` today, the label
reads `8x`/`16x` but the dropdown falls back to `1x` because no matching item exists.
Adding x8/x16/x32/x64 items fixes that display inconsistency for free.

**OBSERVED (pause hotkey):** `input_controller.gd:1325-1327` toggles `game.paused` directly
via `_is(k, "pause")`; the binding is `"pause": "Space"` at `config.gd:198`. There are **no
speed-up/speed-down hotkeys** in `input_controller.gd` (literal grep). Space does not call
`hud.refresh_speed`, so the dropdown/label can show a stale speed state after a Space pause;
this pre-existing quirk is not caused by new options.

## 5. Time-scale mechanism — no engine time scale

**OBSERVED:** literal greps for `Engine.time_scale`, `_physics_process`, and
`physics_ticks_per_second` across `variant3d` returned **zero matches**. The sim is a
fixed-step accumulator entirely inside `_process`:

```
main.gd:1614-1621   dt = minf(dt, 0.25);  acc += dt * speed
                    step = 1.0 / Data.FPS       # 1/32 = 0.03125 s
                    while acc >= step and steps < 64:
main.gd:1625          game.tick(step)
main.gd:1629-1631     for brain in ais: brain.tick(step)
```

`Data.FPS = 32.0` (`data.gd:32`). Speed therefore changes **how many identical 0.03125 s
ticks run per rendered frame**, not the tick size, tick order, or `game.tick` internals.

## 6. Do x16/x32/x64 break anything?

### 6.1 Fixed-step sim and the 64-step ceiling — DERIVED

Per-frame nominal sim-time demand is `dt * speed`, with `dt ≤ 0.25` (`main.gd:1615`).
Per-frame supply is at most `64 * 0.03125 = 2.0 s` (`main.gd:1621`, `data.gd:32`).

| Speed | Worst-case (dt=0.25) ticks needed | Cap 64 | Min rendered fps to keep up |
|---:|---:|---|---:|
| x1 | 8 | fits | 4 |
| x2 | 16 | fits | 4 |
| x4 | 32 | fits | 4 |
| x8 | **64** | **exactly at cap** | 4 |
| x16 | 128 | truncated | ≥8 fps (dt ≤ 0.125 s) |
| x32 | 256 | truncated | ≥16 fps (dt ≤ 0.0625 s) |
| x64 | 512 | truncated | ≥32 fps (dt ≤ 0.03125 s) |

At 60 fps the per-frame demand is x16 ≈ 8.5 ticks, x32 ≈ 17, x64 ≈ 34 — all under 64,
so the cap is not hit **at that frame rate**. At 30 fps, x64 needs ≈68 ticks/frame > 64.

**INFERRED (no run):** because `acc` is never capped, a sustained low-fps x64 session
accumulates a tick debt (up to ~14 sim-seconds per frame at dt=0.25); when fps recovers,
every frame keeps spending 64 ticks catching up. The per-frame cap prevents a hang, but
the game can stay "behind" for a long time. This is the concrete reason not to simply
raise the UI ceiling.

**UNVERIFIED:** actual fps on the MX130 machine and whether any real x16/x32/x64 session
hits the cap — no capture/run was performed (G04/P09 territory).

### 6.2 Physics ticks — OBSERVED / DERIVED

No Godot physics ticks are used for simulation (§5). The 64-step accumulator **is** the
effective per-frame tick budget. Raising speed does not change `step`, so physics-style
fixed-step determinism is preserved for every tick that actually runs. The failure mode is
*dropped/queued* ticks, not *larger* ticks.

### 6.3 AI stepping — OBSERVED / DERIVED

`brain.tick(step)` is called in the same `while` loop as `game.tick(step)`
(`main.gd:1625,1629-1631`), so AI and sim stay tick-for-tick aligned. `ai.gd:73-76` turns
`think_t` by the same `step`, with a 1.0 **sim**-second interval (`data.gd:73`): at x16 the
AI thinks 16× per wall-second, etc. **DERIVED:** no correctness break, but sim+AI CPU per
wall-second scales linearly with the multiplier, which feeds back into §6.1's fps.
**OBSERVED:** CLI mode (`main.gd:2148-2160`) ignores `speed` entirely.

### 6.4 Capture timing — OBSERVED / DERIVED

- Sequence frames are triggered on `game.time_s >= seq_next` (`main.gd:1741-1742`), so
  **sim-time cadence is preserved** (`seq_step`); only wall-clock cadence scales with speed.
  **DERIVED:** at x64 / 60 fps / `seq_step=0.25` that is ≈16 sim-s and ≈64 frames per wall
  second; `seq_max = 600` (`main.gd:94`) exhausts the sequence in ~10 wall seconds.
- Screenshots fire after `screenshot_frames` **rendered frames** (`main.gd:1730`, default
  120 at `:69`), not sim-seconds. **DERIVED:** at high speed the captured game state is much
  further advanced than at x1; capture-comparison tests that assume wall-frame timing shift.
- CLI sequence capture uses `cli_t`, not `game.time_s` (`main.gd:2175-2182`) and is unaffected
  by `speed`.
- **OBSERVED:** existing atoms freeze the sim by writing the field directly —
  `_main.set("speed", 0.0)` and `_main.set("acc", 0.0)` (`t_motion_capture.gd:306-307`;
  same pattern in `t_select_rect.gd:368`, `t_select_rect_capture.gd:440`,
  `t_ghost_final_stage.gd:264`, `t_view_rect_rv.gd:220`). Because they bypass `set_speed`,
  raising its clamp does **not** break them.

### 6.5 Visual/animation coupling — OBSERVED + INFERRED

`world.sync(dt)` receives raw dt (`main.gd:1671`), so `_anim_t` (`world3d_entities.gd:2019`,
`world3d.gd:683`) ages at wall-clock rate while unit positions advance at `speed ×` rate.
`_measure_speed()` divides sim displacement by that wall-clock clock
(`world3d_entities.gd:1224-1236`) and feeds the walk/idle gate `WALK_SPEED_GATE_M_S = 0.15`
(`:226`, `:1211-1216`). **INFERRED:** at x16+ measured displacement rates inflate ~16–64×,
so slow-moving units may be classified as walking and pose/teleport smoothness degrades.
**Already true in kind at x4; magnified, not introduced, by the new options.** No parity
claim is made; donor animation timing UNVERIFIED here.

## 7. Test surface

| Test | file:line | Effect of adding x8/x16/x32/x64 |
|---|---|---|
| `t_hud_layout` | `t_hud_layout.gd:61-62` (`SPEED_LABELS=["II","1x","2x","4x"]`, `SPEED_META=[0,1,2,4]`), asserted at `:424` and `:432` for each of three viewports | **Will fail 6 checks** unless both constants are extended in the same order as `hud.gd:444`. Update = reflecting the new UI, not weakening. |
| `t_hud_layout` legacy guard | `:435-441` | Uses `SPEED_LABELS.has(c.text)`; still zero legacy speed Buttons — no change needed beyond the constants. |
| `uitest` | `uitest.gd:21,275-280` | Calls `set_speed(2.0)` then `set_speed(1.0)`; unaffected by a raised upper clamp. |
| `t_menu_roster` | `t_menu_roster.gd:165-184` | `gamespeed:"fast"` → `Data.GAME_SPEED=="fast"`, `main.speed≈2.0`; donor ids unchanged → unaffected. |
| Freeze-style atoms | `t_motion_capture.gd:303-316` and the four siblings in §6.4 | Write `speed`/`acc` directly; unaffected. |
| `t_perf_scale` | `t_perf_scale.gd:1-38` | Numbers-only sim probe; no speed assertion. |

No other test references the speed option list (literal grep across `variant3d/**/*.gd`).

## 8. Single safest way to add x16/x32/x64 (INFERRED proposal for S02)

Do **not** change `Data.FPS`, the tick order, the `steps < 64` cap, the default selection,
or any donor config id. Concretely:

1. **`hud.gd:444`** — append items after `4x`, keeping `selected` at index 1:
   `[["II",0.0],["1x",1.0],["2x",2.0],["4x",4.0],["8x",8.0],["16x",16.0],["32x",32.0],["64x",64.0]], 1`.
   Metadata floats flow through the existing `_mkoption` (`hud.gd:498`), `_on_speed_idx`
   (`:605-608`) and `_speed_index` (`:597-603`) with no other HUD change.
2. **`main.gd:722`** — raise the setter clamp ceiling from `8.0` to `64.0`
   (`clampf(s, 0.0, 64.0)`). **This is mandatory**: without it every new option silently
   collapses to x8. Optionally raise `main.gd:362` (config path) for consistency; donor ids
   still max at x4, so defaults are untouched.
3. **`main.gd:1616`** — saturate the accumulator right after `acc += dt * speed`:
   `acc = minf(acc, 64.0 * step)` (equivalently `2.0`). This keeps **exactly** today's
   behaviour for x1/x2/x4 and x8 (worst case dt=0.25 × 8 = 2.0, at most one tick clipped),
   while x16/x32/x64 degrade to "run 64 ticks this frame, no debt" instead of accumulating
   unbounded catch-up. **Alternative rejected:** raising `steps < 64` to 512 would change
   hitch behaviour at *all* speeds and risks multi-hundred-tick frame stalls (death spiral).
4. **`t_hud_layout.gd:61-62`** — extend `SPEED_LABELS` and `SPEED_META` in the same order.
   No threshold or assertion is removed.
5. Leave `--fast` (`main.gd:1351`) and `--speed` (`main.gd:1352-1354`) as they are; `--speed`
   already accepts high values, and its interaction with the new accumulator saturation is
   then well-defined.

**Default behaviour proof (DERIVED):** at startup `speed` is `1.0` (`main.gd:66`), the
dropdown default index is 1 → x1 (`hud.gd:444,499`), donor ids still resolve to ≤4
(`data.gd:385`, `main.gd:354,362`), `--fast` still means x8 (`main.gd:1351`), and the
accumulator saturation only binds when `dt*speed > 2.0`, impossible for x1..x8 given
`dt ≤ 0.25`. Therefore an unchanged config plays at exactly the same rate as before.

**Ownership warning:** `hud.gd` is also P12's proposed file (`WAVE_G_CHARTER.md:154-155`,
`P12_hud_fix_proposal.md:19-22`). P12's hunks do not touch `hud.gd:444`, but COORD must
grant one owner and require `inbox/backup/hud.gd.bak-S02` before any edit.

## 9. Unknowns / UNVERIFIED

- **UNVERIFIED:** no Godot run, capture, FPS number, or timing measurement was made by S01;
  all §6 dynamics are code-derived arithmetic, not observed behaviour. G04/P09 must verify.
- **UNVERIFIED:** whether the MX130 machine actually stays above 8/16/32 fps at x16/x32/x64
  with a real army (the very condition that decides if the 64-step cap binds).
- **UNVERIFIED:** donor's own maximum game speed — no donor citation was consulted for this
  ticket; these multipliers are port additions, not donor-parity claims.
- **UNVERIFIED:** whether Space-pause's stale dropdown state (§4) is intentional donor
  behaviour or a port bug; recorded as an observation only.
- **INFERRED, UNVERIFIED:** animation/motion-gate inflation at high multipliers (§6.5).

*End of S01 report — no code changed, no runner job submitted.*
