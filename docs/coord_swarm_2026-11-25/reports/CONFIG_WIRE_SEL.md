---
task_id: CONFIG-WIRE-SEL
title: "CONFIG-WIRE-SEL — 3D selection rectangle constants read from the global feature config"
owner: CONFIG-WIRE-SEL (small implementation builder / subagent)
date: 2026-11-25
status: DONE__NO_BEHAVIOUR_CHANGE__SMOKE_AND_REAL_DRAG_GREEN
scope: "Exactly two repo files touched: variant3d/scripts/input_controller.gd and this report. Plus the requested backup copy inbox/backup/input_controller.gd.bak-CONFIGWIRES."
owns:
  - "variant3d/scripts/input_controller.gd"
  - "docs/coord_swarm_2026-11-25/reports/CONFIG_WIRE_SEL.md"
backup: inbox/backup/input_controller.gd.bak-CONFIGWIRES
validation: "variant runner only, Windows python: ticket 430 configwires-smoke (headless --check-only, ok/exit 0) and ticket 438 configwires-drag (windowed real-input t_select_rect.gd, ok/exit 0, PASS 23/23). SCRIPT ERROR == 0 in both. No full gates, no ladder, no direct godot."
labels: [CONFIG_CONSUMER, NO_BEHAVIOUR_CHANGE, REAL_INPUT_DRAG, VARIANT_RUNNER_ONLY]
---

# CONFIG-WIRE-SEL — report

## 1. Goal

Wire the five selection constants implemented by SEL-01 to the typed getters added
by CONFIG-CORE-01, **without changing behaviour**. CONFIG-CORE-01 seeded 21
behaviour-preserving defaults and getters but left no consumer
(`reports/CONFIG_CORE_01.md:26-27,104-106`); this ticket is the first consumer and
covers only the selection group.

## 2. Sources read (read-only)

| Source | What it supplied |
|---|---|
| `reports/CONFIG_CORE_01.md:38-42,60-63` | Exact getter names, defaults and donor citations for the five selection keys; "no consumer wired" statement. |
| `variant3d/scripts/config.gd:46-53` | `FEATURES_DEFAULTS.selection` literals (`0.005`, `0.25`, `[1,1,0,1]`, `1`, `0.5`). |
| `variant3d/scripts/config.gd:414-434` | The five typed getter signatures/bodies (`feature_selection_*`). |
| `variant3d/scripts/config.gd:269,302` | `static var active` and `active = self` in `load_all()` — the access path to the live config. |
| `reports/SEL_01_implementation.md:35-41,58-63` | Donor citations and the exact hard-coded call sites this ticket replaces. |
| `reports/S1_INPUT_FIX.md:153-162,184-191` | The proven windowed real-drag atom invocation and its green baseline (23/23). |
| `variant3d/scripts/camera3d.gd:187-190`, `camera.gd:67` | Proven null-safe read pattern `var cfg = C3ConfigScript.active; if cfg != null: ...`. |
| Owned file, pre-edit | `input_controller.gd:92` (painter), `:203-204` (epsilon helper), `:735` (double-click literal), and the drag/overlay/`cmd_*` branches at `:630-638,692-757,772-788,1307-1315`. |

No new getter was added; the exact names in `config.gd` were used verbatim.

## 3. Getter → constant map (with citations)

| Hard-coded constant (before) | Getter used (exact name) | Getter citation | Consumer site (after) | Fallback when `ConfigScript.active == null` |
|---|---|---|---|---|
| `0.005` world epsilon | `feature_selection_world_epsilon_m() -> float` | `config.gd:420-421`; default table `CONFIG_CORE_01.md:38`; donor `onmousemove.inc:32` | `input_controller.gd:218` | `0.005` |
| `0.25` attack/guard epsilon | `feature_selection_attack_epsilon_m() -> float` | `config.gd:423-424`; `CONFIG_CORE_01.md:39`; donor `onmousemove.inc:33-34` | `input_controller.gd:216-217` | `0.25` |
| `Color(1,1,0,1)` marquee colour | `feature_selection_marquee_color() -> Array` | `config.gd:426-428`; `CONFIG_CORE_01.md:40`; donor `brushes\selection.cfg:3-14` | `input_controller.gd:94,98,100` | `[1,1,0,1]` |
| `1.0` marquee line width (px) | `feature_selection_marquee_width_px() -> int` | `config.gd:430-431`; `CONFIG_CORE_01.md:41`; donor `selection.cfg:3-14` `LineWidth=1` | `input_controller.gd:95,99-100` | `1.0` |
| `0.5` double-click window (s) | `feature_selection_double_click_s() -> float` | `config.gd:433-434`; `CONFIG_CORE_01.md:42`; donor `menu.cfg:33` `KeyDoubleDelay` | `input_controller.gd:222-224`, call at `:755` | `0.5` |

The active instance is read as `ConfigScript.active` (`config.gd:269,302`), the
same static seam already used by `camera3d.gd:187` and `camera.gd:67`. Every read
is null-guarded with the identical original literal, so an isolated test that
instantiates `C3Input` without booting `main.gd` (no `load_all()`, hence no
`active`) sees exactly the pre-ticket values.

## 4. Before → after (file-local diff)

`variant3d/scripts/input_controller.gd` — **26 insertions, 3 deletions** in the
owned file (git diff). Three logical hunks:

| # | Location (after) | Before | After |
|---|---|---|---|
| 1 | `SelectionRectPainter._draw()`, `:88-100` | `draw_rect(rect_px, Color(1,1,0,1), false, 1.0, false)` | Resolves `ConfigScript.active`; when non-null reads `feature_selection_marquee_color()` and `feature_selection_marquee_width_px()`; the same `draw_rect()` call now uses `Color(float(col[0]), …)` and `float(width)`. With defaults, colour/line-width/solid/no-fill are byte-equivalent in effect. |
| 2 | `_selection_epsilon_m()`, `:214-218` | `return 0.25 if (attack_ground_mode or guard_mode) else 0.005` | Same signature `-> float`; reads `feature_selection_attack_epsilon_m()` / `feature_selection_world_epsilon_m()` when a config is active, identical literals otherwise. |
| 3 | new `_double_click_s()`, `:222-224`; call site `:755` | inline literal `now - last_click_t < 0.5` | new `-> float` helper reads `feature_selection_double_click_s()` with `0.5` fallback; the click branch changes only that one expression. |

**Unchanged (byte-identical):** the drag/click split and LMB press/release
branches, Shift union (`spmAdd`) block, Ctrl-remove omission, world ground rect
construction and `rect.has_point(e.pos)` entity filter, the click-pick branch
and its `_pick` calls, `SelectionRectOverlay` creation in `bind_3d()` and its
`get_selection_rect()` / `set_selection_rect()` API, the `_process()` overlay
refresh at `:1325-1329` (now shifted by +14 lines), every `game.cmd_*` call
site, `world.sel_rect` mirror, minimap-release early-out, all symbols and
signatures, and every other file.

## 5. Backup

| Item | Value |
|---|---|
| File | `inbox/backup/input_controller.gd.bak-CONFIGWIRES` |
| Taken | before the first edit (plain copy of `variant3d/scripts/input_controller.gd`) |
| SHA-256 (backup and pre-edit source) | `63A2E3DB11C6CDEB2D545B032374B807898EB6382851AF3FEB83DA1B38158019` |
| Size | 57,319 bytes (both) |

Restore is a plain copy back over `variant3d/scripts/input_controller.gd`.

## 6. Validation — variant runner only, unique ids

Windows `python`, no direct `godot`, no full gates, no ladder.

| Ticket / id | Command | Mode | Status / exit | wait / run | Result | `SCRIPT ERROR` |
|---:|---|---|---|---|---|---:|
| 430 | `configwires-smoke` | headless `--check-only --script res://scripts/input_controller.gd` | **`ok` / 0** | 116.27 s / 8.61 s | parse/validation clean; stdout 75 B (Godot banner), stderr 0 B | **0** |
| 438 | `configwires-drag` | windowed `--script res://tests/t_select_rect.gd` + `small_map_64.json` fixture + screenshot flag | **`ok` / 0** | 13.10 s / 48.52 s | `PASS 23/23`, `t_select_rect.json` `"passed": true`, `run_mode: windowed_real_input` | **0** |

Artifacts: `variant3d/.godot_queue/results/00000430.json` +
`00000430_configwires-smoke/{stdout,stderr}.txt`, and
`00000438.json` + `00000438_configwires-drag/{stdout,stderr}.txt`.
Result JSON: `variant3d/tests/results/t_select_rect.json`.

Job 438 measured values unchanged from the S1-INPUT-FIX baseline
(`S1_INPUT_FIX.md:184-191`): viewport 1280×720, `event_coord_scale=[1,1]`,
world delta 24.3009 m > 0.005 m, overlay `Rect2(p0,p1).abs()` visible during
drag and hidden/empty after release, selected `[10,11]`, short click `[10]`,
`cmd_calls={}` both times. All 23 checks PASS, including both retained
`expected_pre_fix_failure` markers. stderr contains only pre-existing,
unrelated resource/RID-leak noise (`mill_rotor.png` load failures and
ObjectDB/texture leaks at exit from concurrent world3d work) — no test failure
and no `SCRIPT ERROR`. `--check-only` does not execute `load_all()`, but it did
parse the inner-class `ConfigScript.active` access and all five getter calls.

## 7. Explicit no-behaviour-change statement

- Every getter default equals the literal it replaced
  (`config.gd:46-53`, `CONFIG_CORE_01.md:38-42`); the null-config fallbacks are
  those same literals. `apply()` and `config.json` were not touched, so no
  externally supplied value can differ from the pre-ticket run.
- The only runtime path difference is *where the number comes from*: with the
  default config active, all five resolve to the identical values. No logic,
  ordering, threshold comparison, selection set, event handling or call site
  changed.
- No symbol was renamed, no signature changed, no getter added, no other
  getter group consumed. No test, harness, fixture, manifest, config, asset,
  scene or git state was edited by this builder.
- `git diff --stat` shows other modified files (`camera3d.gd`, `hud.gd`,
  `world3d_*.gd`, `SWARM_BOARD.md`, `tile_index_atlas_winter.png`,
  `t_map_variety.json`) — these are concurrent swarm-agent changes, **not**
  made by this ticket. This builder's only game-file diff is the three hunks in
  §4.

## 8. Open questions

1. **JSON schema not exercised.** No `features` object was added to any config;
   this ticket only consumes whatever a future JSON owner supplies. Behaviour
   with a non-default `features.selection.*` override is untested by design.
2. **Number coercion** (`CONFIG_CORE_01.md:119-121`): whole-float JSON values
   are stored as ints by `_copy()`; the typed getters coerce via `num()`/`int()`,
   so consumers stay correct, but a raw `data.features` reader would see ints.
3. **Marquee colour shape.** `feature_selection_marquee_color()` returns an
   `Array`; the painter indexes `[0..3]` as floats. A malformed array (fewer
   than four entries) would error at draw time — input validation is left to the
   JSON owner, consistent with `CONFIG_CORE_01.md:122-124` (string modes are
   unvalidated too).
4. **`ConfigScript.active` lifetime.** Static singleton set in `load_all()`
   (`config.gd:302`). If a future test resets it mid-run, the null fallbacks keep
   behaviour stable, but no dynamic reconfiguration path was introduced here.
5. **Other getter groups remain unconsumed** (terrain, water, weather, camera,
   hud, render, gameplay). Wiring them is outside this ticket's exclusive
   ownership.

## 9. Summary

Wired all five 3D selection rectangle constants to the existing
`feature_selection_*` getters in `variant3d/scripts/input_controller.gd`:
world epsilon `0.005`, attack/guard epsilon `0.25`, marquee colour
`RGBA(1,1,0,1)`, line width `1` px and double-click window `0.5 s`. The drag and
click logic, Shift-add, world ground rect, marquee overlay and every `cmd_*`
call site remain byte-identical; no symbols were renamed, no signatures changed
and no getter was added. Backup `input_controller.gd.bak-CONFIGWIRES` verified
by SHA-256. Variant-runner jobs `configwires-smoke` (430, headless check-only,
`ok`/0) and `configwires-drag` (438, windowed real-input `t_select_rect.gd`,
`ok`/0, PASS 23/23) both recorded `SCRIPT ERROR == 0`. **No behaviour change** —
only the source of identical default values moved into the global feature
config. **No other file was edited by this builder** — only the owned file and
this report (plus the requested backup copy outside the repo's game tree).
