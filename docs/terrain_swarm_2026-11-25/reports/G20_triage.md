---
id: G20-TRIAGE-01
title: "G20 — gate failure triage: first selftest (ticket 583) parse/gate/cascade analysis"
ticket: G20
owner: G20 (read-only triage; no runner, no Godot, no source edit)
created: 2026-11-25
status: DELIVERED__READ_ONLY
scope: "This report only. No Godot launch, no runner job submitted/cancelled/unwedged/acked, no .gd/.gdshader/config/test/fixture/tool/result file created or edited. All findings are from files already on disk."
labels: [observed, derived, inferred, UNVERIFIED]
charter: docs/terrain_swarm_2026-11-25/CHARTER.md
wave_charter: docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
---

# G20 — first-selftest failure triage (ticket 583)

## 0. Authority, labels, evidence sources

- `WAVE_G_CHARTER.md:31` — only G04 may submit runner jobs; G20 is analysis-only.
- `WAVE_G_CHARTER.md:27,58` — the first selftest (ticket 583) failed on B05's two parse errors;
  COORD fixed them; G20's ticket is read-only triage from result JSONs.
- **OBSERVED** = read directly from the named file/line. **DERIVED** = control-flow/arithmetic
  consequence of observed facts. **INFERRED** = plausible engine-level reading with caveat.
  **UNVERIFIED** = not proven; above all donor parity (no donor GPU A/B frame exists).

Evidence files (all OBSERVED, read this turn):

| Role | Path |
|---|---|
| Failed result JSON | `variant3d/.godot_queue/results/00000583.json` |
| Failed job stderr | `variant3d/.godot_queue/results/00000583_terrainswarm-g1-selftest/stderr.txt` (56 lines) |
| Failed job stdout | `variant3d/.godot_queue/results/00000583_terrainswarm-g1-selftest/stdout.txt` (2 lines) |
| Bogus skipped twin | `variant3d/.godot_queue/results/00000582.json` |
| Green reference selftest | `variant3d/.godot_queue/results/00000580.json` + `.../stdout.txt` |
| Fixed sources | `variant3d/scripts/input_controller.gd`, `variant3d/scripts/main.gd`, `variant3d/scripts/tile_atlas_loader.gd`, `variant3d/scripts/world3d_entities.gd` |
| Test manifests | `variant3d/selftest.json` (29 steps), `variant3d/uitest.json` (17 steps) |
| Gate plan / gate log | `reports/C02_gate_plan.md`, `reports/G04_gate_log.md` |

## 1. What ticket 583 actually recorded (OBSERVED)

`00000583.json`: `id="terrainswarm-g1-selftest"`, argv
`--headless --path variant3d -- --self-test variant3d/selftest.json`,
`wait=0.00098s`, `run=125.36s`, `timeout=300.0`, **`exit=1`, `status="failed"`**.
Its `stdout.txt` holds only the Godot version banner and a blank line — **the selftest report
line never printed**, so zero test steps ran (OBSERVED). Ticket 582 is the known bogus twin:
`status="skipped"`, `error="ticket 582 was skipped (serving=2581)"`, `run=0.0` (`00000582.json`);
the real failure to triage is **583** (consistent with `G04_gate_log.md:73-75`).

Root failures in `stderr.txt` (OBSERVED, verbatim line numbers):

| stderr | Error | Site |
|---|---|---|
| 1-2 | `SCRIPT ERROR: Parse Error: Cannot infer the type of "dst" variable because the value doesn't have a set type.` | `res://scripts/input_controller.gd:621` |
| 3-4 | `SCRIPT ERROR: Parse Error: Identifier "KEY_CONTROL" not declared in the current scope. Did you mean to use "KEY_CTRL"?` | `res://scripts/input_controller.gd:876` |

Counts (OBSERVED): `SCRIPT ERROR` lines = **4** (stderr 1, 3, 5, 51); plain `ERROR:` = **1**
(stderr 7); `WARNING:` = **4** (stderr 9, 20, 32, 44); one `printerr` watchdog line (stderr 56).
This is consistent with `smallmap_capture.py:50-57` (`scan-stderr` counts lines containing
`SCRIPT ERROR` into `script_error_lines`) — ticket 583 would report `script_error_lines: 4`.

## 2. Both parse errors are corrected in the current file (OBSERVED)

`WAVE_G_CHARTER.md:22,27` says COORD applied two one-line fixes after B05. Confirmed against
the live tree:

| Defect (ticket 583) | Current source | Verdict |
|---|---|---|
| `:621` cannot infer `dst` | `input_controller.gd:621` = `var dst: Viewport = camera.get_viewport()` (explicit `Viewport` type; context `:617-628` `_event_px_to_cam_px`) | **Corrected** — the `:=`-style inference that failed on an untyped `get_viewport()` return is gone |
| `:876` `KEY_CONTROL` undeclared | `input_controller.gd:876` = `var ctrl_held := Input.is_key_pressed(KEY_CTRL)` | **Corrected** — Godot's `KEY_CTRL` constant is now used |

DERIVED: both reported parse-error triggers are absent from the current file, so a fresh parse of
`input_controller.gd` has no observed cause to emit stderr lines 1-4 again. This is a *static*
confirmation only — **no Godot run was performed** (G20 is not the runner owner), so a clean
runtime parse remains UNVERIFIED until G04 re-runs the gate (§6).

## 3. Why `main.gd` was a cascade, not a separate bug (OBSERVED + DERIVED)

The chain, in order:

1. `main.gd:46` (OBSERVED): `const C3InputScript = preload("res://scripts/input_controller.gd")`.
2. `input_controller.gd` failed to parse at `:621`/`:876` (OBSERVED, stderr 1-4) → the preloaded
   GDScript has no valid compiled class.
3. stderr 5-6 (OBSERVED): `SCRIPT ERROR: Compile Error: Failed to compile depended scripts. at:
   GDScript::reload (res://scripts/main.gd:0)` — `main.gd:0` (not a real source line) is Godot's
   way of reporting that **`main.gd` itself could not compile because a dependency failed**.
4. stderr 7-8 (OBSERVED): `ERROR: Failed to load script "res://scripts/main.gd" with error
   "Compilation failed".` — same single cause seen from the resource loader.
5. stderr 51-52 (OBSERVED): `SCRIPT ERROR: Invalid call. Nonexistent function 'new' in base
   'GDScript'. at: _setup_full_game (res://scripts/main.gd:1159)`.
   `main.gd:1159` (OBSERVED) is `input_ctl = C3InputScript.new()` inside `_setup_full_game`
   (`main.gd:1077+`). The **identical statement also exists at `main.gd:639`** inside
   `_do_async_load` (`main.gd:535-678`) — that is the sibling call site the dispatch's
   "main.gd:639" refers to; the captured stderr actually points at `:1159`, the synchronous path
   the selftest took (the warning backtraces at stderr 17-19/29-31/41-43 likewise show
   `_setup_full_game (main.gd:1105)` and `_ready (main.gd:235)`).

DERIVED / INFERRED: because `C3InputScript` is a preload of the broken script, the constant
resolved to a GDScript object with no compiled constructor, so calling `.new()` on it failed.
There is **no independent defect in `main.gd`**: both `:639` and `:1159` are the same one-line
instantiation, and both become valid as soon as `input_controller.gd` parses. The engine-internal
detail (preload yields a broken `GDScript` whose `new` is missing) is INFERRED from the error
text; the source-level chain (steps 1-5) is DERIVED from the file lines and stderr. No edit to
`main.gd` is warranted — changing it would be test/product weakening of a correct cascade site.

## 4. Complete stderr classification (every error/warning in ticket 583)

| stderr line(s) | Message (abridged) | Classification | Rationale / action |
|---|---|---|---|
| 1-2 | Parse Error, cannot infer `dst`, `input_controller.gd:621` | **Real defect — OBSERVED, FIXED** | COORD's one-line type annotation present in current file (§2). No action. |
| 3-4 | Parse Error, `KEY_CONTROL` undeclared → `KEY_CTRL`, `input_controller.gd:876` | **Real defect — OBSERVED, FIXED** | `KEY_CTRL` present in current file (§2). No action. |
| 5-6 | Compile Error "Failed to compile depended scripts", `main.gd:0` | **Cascade of the two parse errors** | Not an independent `main.gd` bug (§3). Clears when dependency parses. |
| 7-8 | `ERROR: Failed to load script "res://scripts/main.gd" ... Compilation failed` | **Cascade of the two parse errors** | Same root cause as 5-6, seen from `load()`. Note: plain `ERROR:` is *not* counted by `scan-stderr`, but a clean gate should have none. |
| 9-10 | "Loaded resource as image file, this will not work on export: `tile_index_atlas.png`" | **Asset import warning — benign** | `tile_atlas_loader.gd:320-330` `_load_image_at()` deliberately uses `Image.load()` to build the runtime mip chain (B02). Headless/editor path works; export-only caveat. Expected to persist. |
| 11-19 | Backtrace `_load_image_at` → `_load_atlas` → `build` → `bind` → `_setup_full_game` → `_ready` | **Backtrace attached to warning 9-10** | Context, not a new issue. |
| 20-31 | Same image-load warning for `alpha.png` + backtrace | **Asset import warning — benign** | Same `_load_image_at`/`_load_masks` path (`tile_atlas_loader.gd:489`). Expected to persist. |
| 32-43 | Same image-load warning for `alphavert.png` + backtrace | **Asset import warning — benign** | Same path. Expected to persist. |
| 44-45 | "world3d_entities: DONOR-SAMPLED FLAT-ROOT MORPH — **PORT APPROXIMATION — NOT DONOR PARITY** ... visual UNVERIFIED" | **Benign PORT APPROX warning** | `world3d_entities.gd:191` `ANIM_STATUS`, emitted by `push_warning` at `:528`. This is the charter-mandated honesty label (`CHARTER.md:57-58,130`), not a defect. Expected to persist. |
| 46-50 | Backtrace `bind (world3d_entities.gd:528)` → `bind (world3d.gd:641)` → `_setup_full_game` → `_ready` | **Backtrace attached to warning 44-45** | Context, not a new issue. |
| 51-55 | `SCRIPT ERROR: Invalid call. Nonexistent function 'new' in base 'GDScript'`, `main.gd:1159` (same call at `:639`) | **Cascade of the two parse errors** | §3. Not a separate bug; no `main.gd` edit. |
| 56 | `watchdog: wall-clock limit reached, forced exit` | **Harness self-protection — benign mechanism / symptom** | `main.gd:1587-1592` `_process()`: `deadline_ms` is armed for selftest runs at `main.gd:209-212` with default `hard_limit=120.0` s. Setup never completed, so the selftest never finished and the watchdog forced `_quit(1)` at ~125 s wall clock. Not a game defect; it explains the `exit=1` and the missing selftest report line. |

**Net triage:** 2 real defects, both already corrected; 3 cascade errors from those defects;
3 benign asset-import warnings; 1 benign PORT APPROX warning; 1 benign watchdog symptom.
No remaining real defect is visible in ticket 583's stderr on the current tree.

## 5. Exact re-run criteria for G04 (what clears the gate)

G04 is the sole runner owner (`WAVE_G_CHARTER.md:31`); its prepared job plan and ids are in
`G04_gate_log.md:89-143`. Every job must be submitted with a **unique `g04-` id** through
`python variant3d\tools\godot_runner.py run --id <unique> ...`, one Godot at a time. Gate criteria:

1. **`SCRIPT ERROR == 0`** on **every** G04 job's `stderr.txt`, measured as
   `script_error_lines` from `python variant3d\tools\smallmap_capture.py scan-stderr <stderr.txt>`
   (`smallmap_capture.py:50-57` counts lines containing `SCRIPT ERROR`). Concretely, none of
   ticket 583's four `SCRIPT ERROR` lines may recur: no `:621` parse error, no `:876` parse
   error, no `main.gd:0` "Failed to compile depended scripts", no `GDScript.new()` at
   `main.gd:1159`/`:639`. The benign `WARNING:` lines (§4) do **not** count as script errors and
   are expected to persist; the plain `ERROR: Failed to load script` and the watchdog line must
   also be absent for a clean selftest/uitest run.
2. **selftest 29/29**: `g04-selftest` result JSON has `status="ok"`, `exit=0`; `stdout.txt`
   contains the `self-test report:` line; written `variant3d/selftest.json` has
   `"passed": true` and **all 29 `steps[]` entries `"passed": true`** (29 step names confirmed in
   `selftest.json`; 29 is also the step count declared at `selftest.gd:16`). No step weakened,
   no threshold lowered, no `expected_pre_fix_failure` flipped.
3. **uitest 17/17**: `g04-uitest` result JSON has `status="ok"`, `exit=0`; written
   `variant3d/uitest.json` has `"passed": true` and **all 17 `steps[]` entries `"passed": true`**
   (17 step names confirmed in `uitest.json`).

Supporting gates from `G04_gate_log.md:140-143` (not substitutes for the three above):
`t_render_mode` `result=PASS`/`seam_missing=false`; windowed P0 and real-map PNGs 1280×720,
non-blank (`non_black_fraction >= 0.9`, `mean_luma >= 40`, `max_luma >= 100`), no new seams or
black rows, `SCRIPT ERROR == 0` on each capture job. Pre-flight must also be clear: `pending=0`,
`godot.lock` free, `now_serving == next_ticket`, zero live Godot processes (the stale ticket 582
job file was the pre-flight blocker in `G04_gate_log.md:25-87`). Donor parity stays **UNVERIFIED**
regardless of any gate result (`CHARTER.md:57-58,124-130`).

## 6. CAP-3 atoms — hand-off note (OBSERVED)

`C02_gate_plan.md:10,200,386,459-470` recorded CAP-3 as **blocked** because D03's/E04's probe
atoms did not exist on disk at that read. Per `WAVE_G_CHARTER.md:39-40`, **D03's CAP-3 atoms are
now being authored by G01/G02**: `variant3d/tests/t_select_rect_capture.gd` (G01, quad
before/during/after) and `variant3d/tests/t_ghost_final_stage.gd` (G02, ghost valid/invalid)
(OBSERVED: both paths exist at this read; their reports are `G01_select_capture_atom.md` and
`G02_ghost_atom.md`, the latter already landed). Consequence for the gate: once both atoms have
landed as final deliverables, CAP-3 can move from UNVERIFIED to capturable; G04's windowed
frame-sequence capture must then satisfy C04's hard gates — `input_ctl`-inclusive capture path
(overlay reparented into `capture_view3d`, `ov.get_parent()==capture_view3d` in JSON), five PNGs
plus `frames.json`, `script_error_lines: 0`, no root-texture/blank readback (`C04_visual_review.md:72,168,174-175`; `D03_selection_probe.md:70-88`). G20 authored no atom and ran no capture; this
is a status note only.

## 7. Honesty / scope statement

- READ-ONLY: no runner job, no Godot process, no source/config/test/fixture/tool/result edit —
  this report file is the only artifact written.
- The two fixes are confirmed **statically** (current file lines); a clean runtime parse is
  UNVERIFIED until G04 re-runs (§6). No donor-parity claim is made or implied.
- No test weakened; no threshold changed; cascade errors were traced to their single root, not
  patched at the symptom site.

*End of G20 triage.*
