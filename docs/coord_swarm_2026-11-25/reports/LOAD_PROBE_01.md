---
id: LOAD-PROBE-01
title: "LOAD-PROBE-01 — load-responsiveness / post-load usability atom (authoring only)"
owner: LOAD-PROBE-01
date: 2026-11-25
status: AUTHORED__NO_GODOT_RUNS__NO_PASS_CLAIM__MEASUREMENT_ONLY
scope: "One new test atom + this report. main.gd (LOAD-ASYNC-01) and hud.gd (UI-TOPBAR-01) read-only; no source/config/manifest/gate/git edit; no runner job submitted."
owns:
  - "variant3d/tests/t_load_usability.gd"
  - "docs/coord_swarm_2026-11-25/reports/LOAD_PROBE_01.md"
labels: [LOAD, POST_LOAD_USABILITY, UNVERIFIED_REQUIRES_INSTRUMENTATION, MEASUREMENT_ONLY]
evidence_labels: [observed, derived, inferred, UNVERIFIED]
---

# LOAD-PROBE-01 — load-responsiveness / post-load usability atom

## Goal

Author (not run) a single `extends SceneTree` atom that boots the **real 64² 3D game**
and measures five owner-requested properties from the 2026-11-25 UX directive —
loading freezes the window and, after the overlay disappears, something is still
loading and blocks normal use (`PROGRESS.md:104-113`). The atom must record what
it can actually observe, mark everything that needs a main.gd edit as
**UNVERIFIED / requires-instrumentation**, write
`res://tests/results/t_load_usability.json`, guard to headless, defer its quit,
and make **no PASS claim**. No Godot job was launched and no gate is asserted.

## Sources

| Source | Used for |
|---|---|
| `PROGRESS.md:104-113` | Owner UX directive (window freeze; post-overlay blocking), disjoint owners (`main.gd` = LOAD-ASYNC-01, `hud.gd` = UI-TOPBAR-01) |
| `CHARTER.md:32-49,75-86` | Disjoint outputs, `observed`/`derived`/`inferred` labelling, gates reserved to the end |
| `variant3d/scripts/main.gd:168-182,206,230-246` | Headless detection, `render_mode`, test-mode branches; no-flag boot reaches `_setup_menu()` |
| `variant3d/scripts/main.gd:248-268` | `_setup_menu()` / `_on_menu_chosen()`: **staged async load only in the non-headless branch** (`:257-268`) |
| `variant3d/scripts/main.gd:270-367` | `_apply_menu_cfg()` — the first call `_on_menu_chosen` makes (`:256`) |
| `variant3d/scripts/main.gd:455-519` | `_show_loading()` / `_set_loading()` / `_hide_loading()` — overlay nodes, `loading_active`, stage text/bar |
| `variant3d/scripts/main.gd:521-528` | `_loading_tick()` — two `process_frame` awaits, generation guard |
| `variant3d/scripts/main.gd:530-645` | `_do_async_load()` — every generation stage and every world/camera/HUD/input bind, final tick then `_hide_loading()` |
| `variant3d/scripts/main.gd:1046-1149` | `_setup_full_game()` — the synchronous headless test-mode boot (no overlay) |
| `variant3d/scripts/main.gd:1556-1692` | `_process()` watchdog/tick/`world.sync()` loop that runs after load |
| `variant3d/scripts/config.gd:273,489,523-525` | Config overlay, `apply()` maps fixture tiles/seed to `Data.MAP_W/H/RANDOM_SEED` |
| `variant3d/scripts/menu.gd:93-102` | Menu `_ready()` builds the shell but emits no automatic `chosen` signal (safe to call handlers manually) |
| `variant3d/scripts/world3d.gd:599-602`; `camera3d.gd:171-174,444-452,511-519`; `hud.gd:167-169,201-213`; `input_controller.gd:129-134,172-185,297-315,305-315,387-400` | Real `bind()` side effects used as observable "bound" flags and responsiveness endpoints |
| `variant3d/scripts/game.gd:355,414,983,1145,1164,1362,1800` | Generation stage functions called by `_do_async_load` |
| `variant3d/tests/_template_test.gd:1-38` | Headless self-exiting atom shape, result JSON, deferred `quit` |
| `variant3d/tests/README.md:3-33,67-80` | Bare `quit()` hangs Godot 4.7; one-feature-per-file; result shape |
| `variant3d/tests/t_smallmap_terrain.gd:9-16,85,174-231,234-416` | Real-boot pattern via `main.tscn` + `--config` + `--screenshot`; inspect on first `_process()`; deferred quit; stderr-scan note |
| `docs/coord_swarm_2026-11-25/reports/TEST_01_smallmap_harness.md:60-98,269-305` | Runner monopoly, result split, no-GDScript-stderr fact, 64² as smallest proven map |
| `variant3d/tests/fixtures/small_map_64.json:10-15` | 64×64, seed 20261113, `render_mode=3d` test-only overlay |
| `docs/coord_swarm_2026-11-25/RUN_GUIDE.md:14,35-55,92` | Windows `python`, serialized variant runner, stderr scan requirement |
| `docs/coord_swarm_2026-11-25/PROGRESS.md:115-126` | Existing hard-error classes (`hud3d_adapter` parse cascade, missing `.ctex`) that the stderr scan must catch |
| `docs/coord_swarm_2026-11-25/UX_LOADING.md:38-40,61-73,75-97` | Owner requirement split: R3 windowed responsiveness, R4 readiness-before-hide, R5 no post-load blocking; windowed drag explicitly required for R3 |
| `docs/coord_swarm_2026-11-25/UX_LOADING.md:145-150` | Its proposed atom name `t_load_responsive.gd` did not exist; this task instead specifies `t_load_usability.gd` |

**Landing state (checked by directory glob on 2026-11-25, twice):**
`reports/LOAD_ASYNC_01.md` was **absent** both times; `UX_LOADING.md` landed
*while this atom was being written* and was then read (its §3 R4/R5 rows and
§4.1–4.3 checklists are cited above). No numeric acceptance threshold was
assumed from either document: UX-LOAD-DOC-01 states R3 needs a real windowed
drag and leaves R4/R5 **UNVERIFIED / PENDING** (`UX_LOADING.md:69-71,82,90,97`),
and all thresholds in this atom are labelled probe parameters, not spec
constants. If LOAD-ASYNC-01 later changes `_loading_tick` stage layout or
overlay flags, the atom re-reads live state each frame and records the new
values rather than hard-coding the old ones. (Observed at authoring time:
`inbox/backup/main.gd.bak-LOADASYNC01` existed while `main.gd` itself was still
unmodified in git status — an in-flight edit, not a reviewed contract.)

## Atom design

`variant3d/tests/t_load_usability.gd` (`extends SceneTree`, tab-indented, no
`class_name`, no direct `quit()`):

1. **Headless guard (`:196-201`, `:442-444`).** `DisplayServer.get_name()` is
   recorded; a non-headless run writes a result with `headless_guard:
   UNVERIFIED` and defers `quit(0)` rather than driving a windowed click it
   cannot observe.
2. **Real 64² boot (`:202-212`, `:244-263`).** Instantiates
   `res://scenes/main.tscn` as a child of `root`, passes only
   `--config res://tests/fixtures/small_map_64.json`; with no test-mode flags
   main takes `_setup_menu()` (`main.gd:206,230-246`) instead of the
   synchronous `_setup_full_game()` (`main.gd:1046-1149`). On the first
   `_process()` tick it verifies `render_mode == "3d"`, `Data.MAP_W/H == 64`,
   `Data.RANDOM_SEED == 20261113` (`config.gd:523-525`).
3. **Forced real staged load (`:265-276`).** Calls the real handlers
   `_apply_menu_cfg(cfg)` and `_do_async_load(cfg)` via `Object.call()`, exactly
   the two calls `_on_menu_chosen` makes (`main.gd:256,268`). `_do_async_load`
   has no headless gate other than window sizing (`main.gd:544-549`), so the
   overlay nodes and all generation stages run verbatim in headless. **This is
   a proxy for a Start click, not a click** — that distinction is recorded as
   a limitation and the literal click path is UNVERIFIED.
4. **Per-frame sampling (`:279-323`).** While `loading_active` and a valid
   `loading_layer` are both true (flags from `main.gd:512-519,530-539`), each
   `_process()` records `Time.get_ticks_usec()`, the inter-frame gap, the
   `loading_stage` text and `loading_bar.value` transitions
   (`main.gd:503-510`), and a binding snapshot. On the first frame the overlay
   becomes hidden, the snapshot is frozen as the (b) evidence.
5. **Bound-state flags (`:130-190`).** `world.game/hud`, `camera.game/
   view_scale`, `hud.game/world/_hud3d_adapter`, and `input_ctl.game/world/
   hud/camera/render_mode/picking` are read each frame against the five real
   `bind()` contracts (`main.gd:578-634`; `world3d.gd:599-602`;
   `camera3d.gd:171-174`; `hud.gd:167-169,201-213`;
   `input_controller.gd:129-134,172-185`).
6. **Post-hide probes (`:325-393`).** Within `RESPONSE_FRAMES = 30` frames:
   `_set_selection()` → `selected_ids` (`:305-315` of the input controller),
   `minimap_order()` → selected unit `order.type ∈ {move, attack_move}`
   (`:387-400`), and `apply_external_target()` → camera `_target` /
   `global_position` change (`camera3d.gd:444-452,511-519`; `main.gd:605`).
   These are direct calls into live bound objects; synthetic mouse events in
   headless are UNVERIFIED.
7. **Stability poll (`:396-427`).** For `STABILITY_FRAMES = 30` frames the atom
   re-checks that the overlay stays hidden, `main.get_child_count()` and
   `game.entities.size()` do not change, and no inter-frame gap exceeds the
   documented heuristic `STALL_LIMIT_US = 250000`.
8. **Result (`:430-578`).** Writes `res://tests/results/t_load_usability.json`
   with `verdict: "MEASUREMENT_ONLY__NO_PASS_CLAIM"`, `gate_claim: "NONE"`,
   `pass_claim: false`, per-assertion `status`/`met_criterion`/`citation`,
   measured proxies, notes, limitations and the stderr-scan note; prints the
   verdict line; exits via `call_deferred("quit", 0)`. Exit 0 means "atom
   finished and wrote measurements", **not** "test passed". Failsafes
   (`MAX_FRAMES = 3600`, `WALL_CAP_US = 120000000`) prevent any hang without a
   busy loop; the runner hard timeout remains the outer guard
   (`RUN_GUIDE.md:35-55`).

## Assertion table

`status` describes observability; `met_criterion` is `true`/`false` only for
`OBSERVED` rows and `null` for `UNVERIFIED`. Every row carries its citation
inside the atom's JSON.

| # | Assertion / id | status (authoring design) | Criterion and source |
|---|---|---|---|
| 0 | `headless_guard` | OBSERVED if headless; else UNVERIFIED | `DisplayServer.get_name() == "headless"`; `tests/README.md:77-78`, `TEST_01_smallmap_harness.md:79` |
| 0b | `real_64_game_boot` | OBSERVED | `render_mode=3d`, `64×64`, seed `20261113`; `main.gd:173-182,206,230-246`, `config.gd:523-525`, `small_map_64.json:10-15` |
| 0c | `staged_overlay_observed` | OBSERVED if ≥1 overlay frame and ≥2 stage transitions; else UNVERIFIED | Overlay nodes/stage text really existed; `main.gd:458-501,530-645` |
| **(a)** | `a_longest_main_thread_stall` | **UNVERIFIED** | Exact per-stage stall cannot be bracketed from a sibling `SceneTree`: no timing field or per-stage signal exists in `main.gd:521-528,550-576`. Proxies reported: `max_inter_frame_gap_loading_us` (`Time.get_ticks_usec()` deltas) and `max_stage_to_stage_us` (stage-text timestamps). Instrumentation in `main.gd` (owned by LOAD-ASYNC-01, `PROGRESS.md:104-113`) is required for the literal metric. |
| **(b)** | `b_bindings_before_overlay_hide` | OBSERVED when a hide transition is seen; else UNVERIFIED | At the hide frame: all five objects valid, each `bind()` back-reference matches main's object, adapter and picking exist, and every bound flag's first observed frame ≤ hide frame. `main.gd:512-519,576-645`, `world3d.gd:599-602`, `camera3d.gd:171-174`, `hud.gd:167-169,201-213`, `input_controller.gd:129-134,172-185`. Real Start-click ordering remains UNVERIFIED (forced-call proxy). |
| **(c)** | `c_input_response` | OBSERVED if a live player-0 unit exists; else UNVERIFIED | `selected_ids` contains the probe unit within 30 frames of `_set_selection()`; `main.gd:627-634`, `input_controller.gd:305-315`. Real injected mouse events UNVERIFIED. |
| **(c)** | `c_order_response` | OBSERVED if a live player-0 unit exists; else UNVERIFIED | Unit `order.type ∈ {move, attack_move}` within 30 frames of `minimap_order()`; `input_controller.gd:387-400`, `main.gd:627-629` |
| **(c)** | `c_camera_response` | OBSERVED | `_target` and `global_position` both change (finite) within 30 frames of `apply_external_target()`; `main.gd:605,643-645`, `camera3d.gd:444-452,511-519` |
| **(d)** | `d_no_deferred_heavy_stage` | **UNVERIFIED** | `main.gd` exposes no deferred-stage flag, so the literal claim has no observable. Proxies only (30-frame poll): overlay stays hidden, child count and entity count stable, no inter-frame gap > 250 ms heuristic; `main.gd:512-519,643-645` |
| **(e)** | `e_no_hard_engine_errors` | **UNVERIFIED** | GDScript has no stderr API; a runner-side `smallmap_capture.py scan-stderr` must require `script_error_lines == 0`. `TEST_01_smallmap_harness.md:89-92,298`; `t_smallmap_terrain.gd:19-20,72`. Known error classes to look for: `PROGRESS.md:115-126`. |
| — | `no_pass_claim` | OBSERVED | `verdict=MEASUREMENT_ONLY__NO_PASS_CLAIM`; `CHARTER.md:75-86` |

No criterion was relaxed to make a row green: the three rows the task itself
declares unobservable without instrumentation are recorded as UNVERIFIED with
their proxies, not as PASS or FAIL.

## Limitations

1. **Observed — headless cannot take the real overlay branch.**
   `main.gd:257-268` sends headless straight to the synchronous
   `_setup_full_game()` (`main.gd:1046-1149`); the atom therefore calls the
   private handlers itself. The real Start-button click / `chosen` signal is
   **UNVERIFIED** (`main.gd:248-268`; `menu.gd:93-102`).
2. **Observed — (a) needs instrumentation.** `_loading_tick` only updates a
   label and awaits two frames (`main.gd:521-528`); no stage timer exists.
   Inter-frame gaps and stage-text timestamps are wall-clock proxies that
   include the awaited frame pumps, not isolated main-thread busy time.
3. **Observed — window freeze is not reproducible headless.** The owner's
   "cannot move the Windows window" symptom (`PROGRESS.md:104-107`; R3 at
   `UX_LOADING.md:69,77-82`) depends on GUI painting and `DisplayServer` calls
   (`main.gd:544-549`) that headless never executes. UX-LOAD-DOC-01 explicitly
   requires a real windowed title-bar drag and says a headless atom alone is
   insufficient (`UX_LOADING.md:69,82,150`); this atom does not test it and
   claims nothing about it.
4. **Observed — synthetic input is not real input.** Direct `_set_selection()`
   / `minimap_order()` calls into the bound controller prove the bindings are
   live; they do not prove `InputEvent` delivery through the viewport. Real
   mouse/key events in headless are **UNVERIFIED**
   (`input_controller.gd:305-315,387-400`).
5. **Observed — (d) has no literal observable.** "Deferred heavy stage still
   running" is not a flag, signal or node in `main.gd`; only bounded stability
   proxies are measurable. The 250 ms gap ceiling is a probe heuristic, not a
   donor or owner threshold.
6. **Observed — (e) is external-only.** No GDScript stderr API
   (`TEST_01_smallmap_harness.md:89-92`); keep the runner `stderr.txt` until
   the scan is done (`RUN_GUIDE.md:92`).
7. **Derived — the atom has no manifest entry.** Registration and
   `test_all.py` still point at `app/` (`TEST_01_smallmap_harness.md:134-140,
   261-264`); launch must be manual through the variant runner. This atom
   does not edit the manifest (exclusive outputs only).
8. **Derived — results land inside the repo.** The task requires
   `res://tests/results/t_load_usability.json`, unlike
   `t_smallmap_terrain.gd:74` which uses `user://`; a run will create that
   JSON file, which is a runtime artifact, not an authored source edit.
9. **Observed — atom name differs from UX-LOAD-DOC-01's proposal.**
   `UX_LOADING.md:145-150` proposes `t_load_responsive.gd` and marks it absent;
   this task explicitly requires `t_load_usability.gd`. No existing file was
   overwritten and neither name is registered in the manifest (limitation 7).
10. **Derived — (b) does not cover every R4 sub-item.** UX-LOAD-DOC-01 asks for
    FX readiness and a deliberate slow-stage injection proving the overlay
    stays up (`UX_LOADING.md:70,84-90`). This atom checks the four bindings
    named by its own task (world/camera/HUD/input) only; FX readiness and
    slow-stage injection remain UNVERIFIED / owned by LOAD-ASYNC-01.
11. **Inferred — LOAD-ASYNC-01 may change the contract.** If the staged path,
   overlay flag names or bind order change, the atom may report UNVERIFIED or
   a false binding violation; re-read the report before interpreting a run.
   The atom samples live state rather than assuming today's stage strings.

## Open questions

1. Will LOAD-ASYNC-01 expose a per-stage timer or a `loading_stage_started_us`
   field in `main.gd`? If so, assertion (a) can be upgraded from UNVERIFIED to
   OBSERVED without weakening; if not, it stays UNVERIFIED.
2. Is a windowed runner job acceptable for a follow-up atom that performs a
   real Start click and checks window movability/paint during load? That is the
   only way to test the owner's literal freeze report (`PROGRESS.md:104-107`).
3. UX_LOADING.md landed mid-authoring (`:61-73`): R5 requires "no further stage
   runs; input/HUD/speed/camera/FX respond; gates green" but gives **no numeric
   frame or wall-clock bound** (`UX_LOADING.md:71,92-97`). The atom uses 30
   frames and reports raw timings; no threshold is claimed as spec. Should
   COORD/UX-LOAD-DOC-01 set a number, and should this atom's window be changed
   to match?
4. Is the 250 ms inter-frame gap ceiling acceptable, or should it be derived
   from a measured donor/owner budget? Currently labelled a heuristic.
5. Should the atom be registered in `variant3d/tests/manifest.json` and
   `test_all.py` by a later integration ticket? Not done here (exclusive
   outputs).
6. If `hud.bind_3d()` fails (the known `hud3d_adapter` parse cascade,
   `PROGRESS.md:115-121`), assertion (b) will correctly report a missing
   binding flag — but only a stderr scan will say whether it was a hard error.

## No-runner declaration

No Godot process, runner ticket, import, or `python variant3d\tools\godot_runner.py`
invocation was launched by this worker. No test result JSON was generated or
read from a run. No source file other than the two exclusive outputs was
created or modified; `main.gd` and `hud.gd` were read only. There is no PASS
claim: the atom's declared verdict is `MEASUREMENT_ONLY__NO_PASS_CLAIM`,
`gate_claim: NONE`, and this report asserts no gate result.

## Summary

- **Observed:** the real staged loading path with the overlay exists only in
  `main.gd`'s non-headless branch (`main.gd:253-268`); a headless real-game boot
  skips it (`main.gd:230-244,1046-1149`). The overlay's visible state, stage
  text and per-binding flags are nonetheless observable from a sibling
  `SceneTree` if the atom invokes the real menu handlers itself.
- **Derived:** the new atom forces that path in headless, samples `Time.get_ticks_usec()`
  gaps and stage transitions, snapshots all bindings at the hide frame, then
  probes input/order/camera and polls post-hide stability within bounded frame
  windows. It writes `res://tests/results/t_load_usability.json` with cited,
  per-assertion `status`/`met_criterion` and no PASS verdict.
- **UNVERIFIED:** exact per-stage main-thread stall (a), the literal
  "no deferred heavy stage" claim (d), and hard engine errors (e) cannot be
  established without, respectively, `main.gd` instrumentation, a
  deferred-stage observable, and an external stderr scan. Real Start-click
  and real synthetic input are also proxies only.
- **Not run:** no Godot job was submitted; every measurement value is a design
  of what the atom will record, not a result. This is a measurement atom, not
  a gate, and no test was weakened.
