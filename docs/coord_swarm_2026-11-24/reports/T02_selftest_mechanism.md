---
owner: T2
directive: test-split
date: 2026-11-24
status: recon-complete
scope: read-only; no Godot runs; no edits outside this report
---

# T2 — Minimal-diff mechanism to run a named subset of selftest steps

## Finding (one line)

`--self-test <path>` is an **output-report path only**, never an input script; `C3SelfTest.run()` is one monolithic function with 29 hardcoded, unconditionally-executed `steps.append` blocks and no step-name switch — so a second JSON with a subset of steps would **not** "just work"; a code change (mirror the existing `--ui-only` precedent) is required.

## Evidence — how the mechanism actually works

### 1. Arg parsing: `--self-test` sets a flag + output path, nothing else
- `app/scripts/main.gd:811-814` — in `_parse_args()`: `"--self-test": selftest_path = args[i+1] if i+1 < args.size() else "selftest.json"; i += 2`. Default value is the bare filename `"selftest.json"`.
- `app/scripts/main.gd:59` — `var selftest_path := ""`.
- `app/scripts/main.gd:159` and `:175` — a non-empty `selftest_path` arms the wall-clock watchdog and makes `_ready()` skip the menu via `_setup_full_game()`.
- `app/scripts/main.gd:1230-1231` — in `_process()`: `elif selftest_path != "" and frame > 4: _run_selftest()`.
- `app/scripts/main.gd:1498-1511` — `_run_selftest()`: `var st := C3SelfTest.new(); st.bind(game, hud, self); var report: Dictionary = st.run(); var out := _write_text(selftest_path, JSON.stringify(report, "  ")); ... _quit(0 if report.get("passed", false) else 1)`.
  - **The path is consumed only by `_write_text` at line 1505 — as a WRITE target.** There is no `FileAccess.get_file_as_string(selftest_path)` / `JSON.parse_string` of it anywhere.
- `app/scripts/main.gd:6` — header comment confirms intent: `--self-test <file.json> ... save a report`.
- Repo-wide grep of all `get_file_as_string`/`json.load` in `app/**/*.{gd,py}` found **no reader of the selftest JSON**. The only consumer is external: `docs/COMMANDS.md:202` (`python -c "import json; d=json.load(open('app/selftest.json')); print(d['passed'], [s['step'] for s in d['steps'] if not s['passed']])"`) and gate docs (`STATUS_TESTS.md:64,148`, `docs/T6_WAVE_PLAN.md:23`, etc.).

### 2. `selftest.gd` decides everything in one hardcoded function; no JSON, no filter
- `app/scripts/selftest.gd:35` — `func run() -> Dictionary:` — **takes zero parameters**.
- Lines 35–503: a fixed linear sequence of 29 step blocks, each ending in `steps.append({"step": "<name>", "passed": ..., "detail": ...})`. They execute unconditionally in source order; there is no `if name`/`match`/`only`/`has_method` dispatch and no JSON load. The 29 names in order (verified against on-disk `app/selftest.json`):
  `move`(47), `act`(62), `fight`(70), `build`(81), `train`(98), `mine`(144), `hud`(150), `no_overlap`(169), `volley`(187), `heal`(197), `morale`(207), `upgrade`(224), `market`(226), `capture`(239), `squad`(249), `formation`(254), `wall`(266), `shell`(274), `formation_bonus`(295), `replenish`(304), `flee`(318), `garrison`(333), `peasant_capture`(358), `resow`(404), `attack_ground`(414), `save_load`(423), `grid_equiv`(444), `farm_cap`(464), `nav_detour`(503).
- `app/scripts/selftest.gd:505-511` — verdict construction: `all_passed` = AND over **all** steps; returns `{"version":1, "passed":all_passed, "sim_seconds":..., "shots_fired":..., "resources_gathered":..., "steps":steps}`. A subset that reports fewer than 29 steps will visibly differ from this shape.
- Baseline note: on-disk `app/selftest.json` currently `passed:false`, 29 steps, 2 failures (`peasant_capture`, `resow`) — matches `docs/coord_swarm_2026-11-24/CHARTER.md:87-90`.

**Conclusion:** passing `--self-test app/selftest_economy.json` today would simply write the full 29-step report to a different filename. The JSON's contents (a "subset of steps") are never read, so it has zero filtering effect.

### 3. The precedent already exists in the sibling UI test
- `app/scripts/uitest.gd:32-35` — `const SCENES := [...]` (17 names, authoritative list for validation).
- `app/scripts/uitest.gd:64-65` — `func run(): return run_only("")` — keeps the full gate path unchanged.
- `app/scripts/uitest.gd:67-102` — `func run_only(name: String)`: `name == "" or name == "all"` runs all 17 `_s_*` scenes; else `has_method("_s_"+name)` → `call(fn, steps)` with a `_s_menu_shell` preamble; unknown names append a failing step listing valid names.
- `app/scripts/main.gd:819-822` — `_parse_args` handles `"--ui-only": uitest_only = args[i+1] ...`.
- `app/scripts/main.gd:1513-1524` — `_run_uitest()` line 1517: `var report = ut.run_only(uitest_only) if uitest_only != "" else ut.run()`.
- `app/scripts/uitest.gd:6` documents the command form: `--ui-test app/uit.json --ui-only squad_keys`.

## Minimal-diff implementation plan (no edits made — plan only)

**Recommended: clone the `--ui-only`/`run_only` pattern into the sim selftest. This is additive, keeps `run()` as the 29/29 gate, and renames no called symbol (CHARTER.md:27).**

1. `app/scripts/main.gd` — `_parse_args()` (~5 new lines, parallel to `:819-822`):
   - Add `var selftest_only := ""` near line 59.
   - Add match arm: `"--self-only": selftest_only = args[i+1] if i+1 < args.size() else ""; i += 2; continue`.
   - Add one header-doc line near `:6`.
2. `app/scripts/main.gd` — `_run_selftest()` (line 1504, **one-line change**):
   - `var report: Dictionary = st.run_only(selftest_only) if selftest_only != "" else st.run()` — exactly mirrors line 1517.
   - Leave `_write_text(selftest_path, ...)` (line 1505) unchanged; subset callers pass a *different* output path (see gate hazards).
3. `app/scripts/selftest.gd` (the substantive refactor — one file, one owner):
   - Add `const STEPS := [ ...29 names... ]` (mirrors `uitest.gd:32`), used for validation + unknown-name error detail.
   - Add `func run() -> Dictionary: return run_only("")` (mirrors `uitest.gd:64-65`) so the existing gate command is byte-stable.
   - Change `func run() -> Dictionary:` at line 35 to `func run_only(only: String = "") -> Dictionary:` and dispatch. Two sub-options:
     - **3a (clean, recommended):** extract each of the 29 blocks into `_s_<name>(steps: Array)` functions and call them by name via `has_method`/`call` exactly like `uitest.gd:87-97`. Larger textual diff but self-contained, each subset builds its own conditions, unknown names handled uniformly.
     - **3b (smallest textual diff):** keep the 29 blocks inline, add `if _want("<name>"):` guards around each block (helper `_want(n)` returns `only == "" or only == "all" or n in only.split(",")`), and filter the final `steps` array. Fewer new symbols but ~29 indent edits in one file — mechanical, and it preserves the current shared-state execution order when `only == ""`.
   - Keep verdict shape (`version`, `passed`, `sim_seconds`, `shots_fired`, `resources_gathered`, `steps`) identical; `passed` remains AND over the steps actually run.

**Alternative with ZERO game-code change:** don't touch selftest.gd at all — use the existing small-test framework (`test_all.py --only ...`) for the subset steps that already have dedicated `t_*.gd` tests (see mapping below), and continue to run full `selftest.gd` only as the gate. Coverage is incomplete (many steps have no dedicated test), so this is a supplement, not a full substitute.

**Recommendation:** hybrid — (a) add `--self-only`/`run_only` for the steps with no dedicated small test, (b) let existing `t_*.gd` cover the ones they already assert, avoiding a third duplicate assertion layer.

### Runner command forms
- Full canonical gate (must remain 29/29, writes `app/selftest.json`):
  `python app\tools\godot_runner.py run --id <area>-selftest --timeout 180 -- --headless --path app -- --self-test app/selftest.json` (docs/COMMANDS.md:46, :77; `STATUS_TESTS.md:274-275`).
- Proposed subset (additive diagnostic):
  `python app\tools\godot_runner.py run --id <area>-selftest-economy --timeout 90 -- --headless --path app -- --self-test app/tests/results/selftest_economy.json --self-only mine,train,resow`
  (comma-separated names proposed; `--self-only` absent or `all` ⇒ full run, matching `uitest.gd:69`).
- Existing small tests:
  `python app\tools\test_all.py --only t_upgrades t_squads` → `test_all.py:37-65` delegates each to `godot_runner.py` with FIFO lock + timeout, writes `app/tests/results/<id>.json`; `:95-100` writes `summary.json`; `:109` returns non-zero on any failure. Single test: `python app\tools\godot_runner.py run --id t-squads --timeout 90 -- --headless --path app --script res://tests/t_squads.gd`.

## Gate hazards

1. **Overwrite of the canonical report.** `_run_selftest()` always writes to `selftest_path` (main.gd:1505). The canonical command passes `app/selftest.json` (COMMANDS.md:46, :77); a subset run that reuses that path would replace the 29-step gate artifact with a shorter one. Because the report still carries `"passed": true` when its (subset) steps pass, a naive gate reader (`COMMANDS.md:202`, `STATUS_TESTS.md:148`) could be fooled or could break on a missing 29-step count. **Rule: subset runs must never write `app/selftest.json`.**
2. **Safe per-subset result path convention.** Write subsets to `app/tests/results/selftest_<subset>.json` (reuses the existing `test_all.py` result dir + ignore patterns; `manifest.json:4` `"result_dir": "app/tests/results"`). Alternative `app/selftest_<subset>.json` also works but clutters the canonical `app/` root. `_candidate_paths`/`_pick_target` (main.gd:1299-1326) resolve relative paths workspace-root-first, so pass an explicit `app/tests/results/...` or `res://tests/results/...` path to avoid the `user://` fallback. `_write_text` (main.gd:1328-1344) auto-creates directories, so no setup needed.
3. **Gate semantics must stay full.** Charter §4 (`CHARTER.md:25`): "app/selftest.json 29/29 + app/uitest.json 17/17". Keep `run()`/`--self-test` as the 29/29 path; subsets are diagnostics only, never a gate substitute, and must not change the verdict shape. Enforce in docs/review that a subset PASS cannot be cited as a green gate.
4. **Shared mutable state ⇒ arbitrary subsets may not be independent.** In `selftest.gd` the steps share one `peasant` captured once at `:38-43`, global resource grants (`:74`, `:91`, `:113-114`, `:176-177`, `:211-214`, `:258-259`, etc.), spawned entities, and a `Data.AI_ENABLED` toggle (`:349` false → `:357` true). A naive per-step filter could yield false failures when a prerequisite setup block is skipped. **Needs T3's dependency analysis**; this is the main correctness risk of `run_only`. The `uitest.gd` scenes avoid it by building their own conditions (`uitest.gd:7-8`, `:90-94` preamble).
5. **Doc drift (non-blocking):** `README.md:42,57,87` and `COMMANDS.md:45,75,211,246` still say "28-step"; actual count is 29. Don't let a subset count be compared against the stale "28" figure.

## Existing-test mapping (29 selftest steps ⇄ `app/tests/t_*.gd` / manifest)

Manifest `ready` tests: `t_build_flow`(building_block_test.gd), `t_mill_logic`(mill_logic_test.gd), `t_mine_unified`(unified_mine_test.gd), `t_visual_tuning`, `t_mill_rotor`, `t_upgrades`, `t_roster_scotland`, `t_squads`, `t_multi_ai`, `t_teams`, `t_smoke_fx`, `t_water`, `t_weather`(pending), `t_hud_fidelity`, `t_anim_metrics`, `t_naval`, `t_mass_army`, `t_map_variety`, `t_capture`, `t_audio_events`, `t_pick_res`, `t_forest_dense`, `t_forest_bake`, `t_forest_bake_render` (manifest.json:5-195).

| # | selftest step (file:line) | Dedicated small test? | Coverage / note |
|---|---|---|---|
| 1 | move (47) | none | — |
| 2 | act / gather (62) | partial | `t_pick_res.gd` (harvest lookup), not the end-to-end gather |
| 3 | fight (70) | none | — |
| 4 | build (81) | partial | `building_block_test.gd` (manifest `t_build_flow`), `t_mine_build.gd`, `t_mines_place.gd`, `t_mines_fix.gd` |
| 5 | train (98) | none (UI only) | `uitest.gd` `train_flow` covers UI, not this sim step |
| 6 | mine (144) | **yes** | `unified_mine_test.gd` (`t_mine_unified`), `t_mines_fix.gd`, `t_mines_place.gd`, `t_mine_build.gd` — strong duplication |
| 7 | hud (150) | **yes** | `t_hud_fidelity.gd` (`t_hud_fidelity`) |
| 8 | no_overlap (169) | none | `t_mass_army.gd` touches formations, not overlap assertion |
| 9 | volley (187) | **yes** | `t_smoke_fx.gd` (`t_smoke_fx`) — smoke/volley/FX |
| 10 | heal (197) | none | — |
| 11 | morale (207) | none | — |
| 12 | upgrade (224) | **yes** | `t_upgrades.gd` (`t_upgrades`) — deeper upgrade-tree assertions |
| 13 | market (226) | none (UI only) | `uitest.gd` `market_panel` |
| 14 | capture / building (239) | **yes** | `t_capture.gd` (`t_capture`) |
| 15 | squad (249) | **yes** | `t_squads.gd` (`t_squads`) |
| 16 | formation (254) | **yes** | `t_squads.gd` (disband/layout part) |
| 17 | wall (266) | none | — |
| 18 | shell / rally+obj (274) | none (UI only) | `uitest.gd` `rally_panel` |
| 19 | formation_bonus (295) | **yes** | `t_squads.gd` (bonus ladder) |
| 20 | replenish (304) | **yes** | `t_squads.gd` |
| 21 | flee (318) | none | — |
| 22 | garrison (333) | none (UI only) | `uitest.gd` `garrison_keys` |
| 23 | peasant_capture (358) | partial | `t_capture.gd`, `t_food1_repro.gd` (explicitly probes this step) |
| 24 | resow (404) | partial | `t_food1_reach.gd`, `t_food1_repro.gd`, `mill_logic_test.gd` |
| 25 | attack_ground (414) | none (UI only) | `uitest.gd` `hotkeys_live` |
| 26 | save_load (423) | none (UI only) | `uitest.gd` `save_load_ui` |
| 27 | grid_equiv (444) | partial | `t_sim_hotspots.gd` (sim hot paths), `t_pick_res.gd` |
| 28 | farm_cap (464) | none | — |
| 29 | nav_detour (503) | partial | `t_nav_smoke.gd` is camera/minimap math, **not** path detour; `t_sim_hotspots.gd` partial |

**Duplication verdict:** 9 steps have a strong dedicated `t_*.gd` duplicate (mine, hud, volley, upgrade, capture, squad, formation, formation_bonus, replenish) plus 4 partial (act, build, resow, grid_equiv). The two frameworks already assert overlapping behavior. Do **not** add a third assertion layer: (a) for duplicated steps, wrap the existing tests (`test_all.py --only <ids>`); (b) for the ~16 steps with no dedicated test, add the `run_only` subset support to `selftest.gd` and run them through `--self-only`. Longer term, migrating each step to its own `t_*.gd` (per `app/tests/README.md:67-80`) would retire the monolith, but that is beyond a minimal diff.

## Open questions (for coordinator / T1 / T3)

1. **Subset granularity token:** one name (`--self-only mine`) vs comma list (`mine,train,resow`) vs group alias (`economy`)? The `uitest.gd` precedent is a single name; recommend comma list + group aliases defined alongside `const STEPS`.
2. **State dependencies:** which of the 29 steps can run standalone given the shared `peasant`/resource/AI-flag state (hazard 4)? T3's dependency/cost analysis is required before `run_only` per-step can be trusted. A safe interim subset = only steps with dedicated `t_*.gd` tests (no selftest code path at all).
3. **`--self-only` naming/sign-off:** additive flag aligns with CHARTER.md:27/§6 "minimal diffs, no renames of called symbols", but confirm it's acceptable and doesn't collide with any planned CLI option.
4. **Result-path convention:** confirm `app/tests/results/selftest_<subset>.json` vs `app/selftest_<subset>.json`; also confirm whether subset runs should be added to `manifest.json` (would make `test_all.py` write `results/<id>.json` automatically) — but that's a larger diff.
5. **Gate enforcement:** should a CI/gate check assert `len(steps)==29` on `app/selftest.json` so a stray subset run can never be mistaken for the full gate? Recommend yes (one-line external check, e.g. `docs/COMMANDS.md:202` style).
6. **Baseline:** current canonical report is red (2 failures, CHARTER.md:87-90); subset work should not be judged green until the full 29/29 gate is restored.
