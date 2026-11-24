---
agent: V7-37
role: atomic test writer (Wave 7 phase 2)
date: 2026-11-24
status: BLOCKED-PENDING-INTEGRATION
gate: expected FAIL — main.gd has no 3D seam yet; SEAM_MISSING emitted
owns: "variant3d/tests/t_render_mode.gd + this report only; app/ and main.gd untouched"
---

# V7-37 — `t_render_mode.gd`: deterministic render-mode seam gate

## 1. What was delivered

One new file, `variant3d/tests/t_render_mode.gd` (tabs, `extends SceneTree`,
per-check PASS/FAIL, `call_deferred("quit", ...)` — no direct `quit()` in
`_initialize()`). It does **source inspection** of `res://scripts/main.gd` plus
a **light load** (`load(MAIN)` and a bare `script.new()` to read the declared
default without running `_ready()`). It never boots the game, never runs the
selftest, never touches any other module.

Ten checks, each recorded as `result: PASS|FAIL` in stdout and JSON:

| # | Check | Enforces |
|---:|---|---|
| 1 | `main_source_readable` | `main.gd` opens and is non-empty |
| 2 | `main_script_loads` | script parses under Godot (light load) |
| 3 | `render_mode_exposed` | `var render_mode` / `render_mode =` present |
| 4 | `render_mode_default_2d` | default/fallback is `"2d"` (`var render_mode := "2d"`, `cfg.text("gameplay.render_mode", "2d")`, …) and **not** `"3d"` |
| 5 | `make_world3d_exposed` | `func make_world3d(` declared |
| 6 | `make_camera3d_exposed` | `func make_camera3d(` declared |
| 7 | `three_d_branch_present` | world/camera construction gated on `render_mode` (`if`/`elif`/`match`/`== "3d"`) |
| 8 | `three_d_helpers_wired` | both `make_*` names appear ≥2× (declared **and** called) |
| 9 | `two_d_path_preserved` | `C3WorldScript.new()`, `C3CameraScript.new()`, `world.bind(game)`, `camera.bind(world)` still present |
| 10 | `runtime_default_2d` | bare instance exposes `render_mode == "2d"` (or uninitialised-before-`_ready`, in which case the source fallback governs) |

`seam_missing = !(3 ∧ 4 ∧ 5 ∧ 6 ∧ 7 ∧ 8)`. When true the script prints
`SEAM_MISSING`, writes `status: "BLOCKED-PENDING-INTEGRATION"` and exits 1.
Checks 1, 2 and 9 remain independent so a missing seam cannot be masked by a
broken script or by removal of the legacy 2D path.

## 2. Run evidence (variant runner, as required)

Command (repo root):

```
python variant3d\tools\godot_runner.py run --id v737-render-mode-seam-r1 --timeout 120 -- --headless --path variant3d --script res://tests/t_render_mode.gd
```

- **Job id:** `v737-render-mode-seam-r1` — **ticket 18**
- **Result:** `status: failed`, `exit: 1` — **expected** (seam not landed)
- **Wait:** 144.46 s (shared FIFO behind other wave jobs) · **Run:** 5.96 s · no timeout
- Runner result: `variant3d/.godot_queue/results/00000018.json`
- stdout: `variant3d/.godot_queue/results/00000018_v737-render-mode-seam-r1/stdout.txt`
- Test JSON: `variant3d/tests/results/t_render_mode.json` → `passed: false`,
  `result: FAIL`, `seam_missing: true`,
  `status: BLOCKED-PENDING-INTEGRATION`

stdout (verbatim check lines):

```
CHECK main_source_readable           PASS  res://scripts/main.gd (71512 chars)
CHECK main_script_loads              PASS  light load of res://scripts/main.gd (no _ready)
CHECK render_mode_exposed            FAIL  main.gd declares/assigns render_mode
CHECK render_mode_default_2d         FAIL  gameplay.render_mode fallback is "2d"
CHECK make_world3d_exposed           FAIL  func make_world3d(...) present
CHECK make_camera3d_exposed          FAIL  func make_camera3d(...) present
CHECK three_d_branch_present         FAIL  world/camera construction gated on render_mode
CHECK three_d_helpers_wired          FAIL  both make_* helpers declared AND called
CHECK two_d_path_preserved           PASS  legacy 2D world/camera constructors still present
CHECK runtime_default_2d             FAIL  SEAM_MISSING: no render_mode property on main.gd instance
SEAM_MISSING  SEAM_MISSING: main.gd has no 3D render-mode seam (integration not landed)
T_RENDER_MODE FAIL 10 checks; SEAM_MISSING: main.gd has no 3D render-mode seam (integration not landed)
```

Score: **3 PASS / 7 FAIL** — the three passes are the preconditions and the
unchanged 2D path; every 3D seam check fails as designed.

## 3. Why BLOCKED, not a test defect

`grep` over `variant3d/scripts/main.gd` found **zero** occurrences of
`render_mode`, `make_world3d` or `make_camera3d`. The only construction path is
the legacy 2D one, twice: `C3WorldScript.new()` / `C3CameraScript.new()` at
`main.gd:558` and `:563` (normal start), and `:926` / `:930` (selftest/screenshot
start). Per the contract (`V73_ATOMIC_CONTRACT.md:21`) these seams belong to the
`main.gd` integration owner, who had not landed them at run time. The test was
deliberately **not weakened**: it reports `SEAM_MISSING` and fails the gate.

## 4. Positive-path validation (no repo edits)

The match patterns were cross-checked against a synthetic post-integration
snippet (`var render_mode := "2d"` + `cfg.text("gameplay.render_mode", "2d")`
+ `if render_mode == "3d": world = make_world3d(); camera = make_camera3d()` +
legacy `else` path + both `func make_*` declarations). All required patterns
matched and both helper counts were 2 — so the gate will flip to PASS when the
integration lands, without any edit to this test.

**Re-run gate for the integration owner** (same runner, new id):

```
python variant3d\tools\godot_runner.py run --id v737-render-mode-seam-r2 --timeout 120 -- --headless --path variant3d --script res://tests/t_render_mode.gd
```

Expect `exit 0`, 10/10 PASS, `status: PASS`, `seam_missing: false`.

## 5. Scope compliance

Only `variant3d/tests/t_render_mode.gd` and this report were created.
`variant3d/scripts/main.gd` was **read only**; `manifest.json` was **not**
touched (its owner registers new tests LAST, per contract line 30). The
generated `variant3d/tests/results/t_render_mode.json` is the test's own
runtime output, not a source edit. No Godot process was launched outside
`variant3d/tools/godot_runner.py`. `app/` is untouched.
