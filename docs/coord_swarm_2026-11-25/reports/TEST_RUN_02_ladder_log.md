---
id: TEST-RUN-02
title: "Execution log — restarted 64² piece→combo ladder (P0→C4), after ATOM-REPAIR + HARNESS-01"
owner: TEST-RUN-02 (execution owner; read-only on all code/tests)
date: 2026-11-25
status: STOPPED_AT_FIRST_FAILING_ROW__P0
scope: "Sequential runner execution only. No .gd, config, manifest, shader, fixture or other report was edited by this agent. Only this log file is authored."
owns:
  - "docs/coord_swarm_2026-11-25/reports/TEST_RUN_02_ladder_log.md"
matrix: "docs/coord_swarm_2026-11-25/TEST_MATRIX.md:53-75"
prior_log: "docs/coord_swarm_2026-11-25/reports/TEST_RUN_01_ladder_log.md"
ladder: "P0 -> P1 -> P2 -> P3 -> C1 -> C2 -> C3 -> C4 (S1 and FINAL out of scope)"
stop_rule: "TEST_MATRIX.md:60-61 / task rule 3 — stop at first row whose result does not pass; no rerun, no assertion weakening, no atom edit"
evidence_labels: [observed]
png_dir: "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\test01_ladder2\\"
---

# TEST-RUN-02 — execution log: restarted 64² piece→combo ladder

Restart of TEST-RUN-01 (which stopped at P0 on four GDScript parse errors at
script load, job 321). Per task context, ATOM-REPAIR made all nine atoms load
(jobs 364–375) and HARNESS-01 fixed the shared helper's runtime cast
(job 384, `SCRIPT ERROR == 0`). This run re-executed the ladder from P0.

## Runner status at start

Captured with `python variant3d\tools\godot_runner.py status` before submission:

```
spool        = C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\variant3d\.godot_queue
now_serving = 395
next_ticket = 401
pending      = 6 [395, 396, 397, 398, 399, 400]
godot.lock   = HELD (age 110.2s)
completed    = 394
max wait     = 503.08s   mean wait = 46.53s
max run      = 605.56s
statuses     = {'failed': 126, 'ok': 246, 'timed-out': 22}
```

Six builder jobs were already queued; FIFO interleaving was expected and no
job was re-submitted. The P0 submission was assigned ticket **404** (tickets
401–403 were claimed by other builders between the status check and submission).
Tool timeout for the runner call was 900000 ms (≥ 300000 ms required).

## Environment / conventions obeyed

- Windows `python` (3.14) only; never `python3`. Godot was never invoked directly.
- Launch form: `python variant3d\tools\godot_runner.py run --id TESTRUN02-<row> --timeout <s> -- --path variant3d --script res://tests/<atom>.gd -- <user args>`.
- Row P0 launched **windowed** (no `--headless`), with the PNG path passed as a
  user arg after the second `--`.
- PNG output directory `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\test01_ladder2\`
  was created; no PNG or result JSON was authored into the repo by this agent
  (the result JSON was written by the atom under `variant3d/tests/results/`).
- Per the stop rule, no failing row was rerun, no assertion was weakened, and
  no atom was edited.

## Executed rows

| # | Atom | runner job (ticket / id) | result JSON | Verdict | PNG path | `smallmap_capture.py stats` | `scan-stderr` | Wall time |
|---|------|--------------------------|-------------|---------|----------|------------------------------|---------------|-----------|
| P0 | `t_terrain_only.gd` | 404 / `TESTRUN02-P0` | `variant3d/tests/results/t_terrain_only.json` — exists; **`passed=false`, `verdict=FAIL`**, `capture_status=PASS`, 20 passes / 1 fail / 0 skipped, `structural_ok=false` | runner `END failed`, exit 1; atom verdict **FAIL** | `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\test01_ladder2\smallmap64_terrain_only.png` — exists (988242 bytes) | see below — `full_width_dark_rows=720` (fraction 1.0), `non_black_fraction=0.992807`, `mean_luma=13.271` | `script_error_lines: 0` (requirement `SCRIPT ERROR == 0` **MET**) | wait 255.49 s, run 25.73 s |

Launch used for P0:

```
python variant3d\tools\godot_runner.py run --id TESTRUN02-P0 --timeout 180 -- --path variant3d --script res://tests/t_terrain_only.gd -- --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/test01_ladder2/smallmap64_terrain_only.png" --png "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/test01_ladder2/smallmap64_terrain_only.png"
```

Runner output:

```
[runner] ticket 404 'TESTRUN02-P0' START (waited 255.49s)
[runner] ticket 404 'TESTRUN02-P0' END failed (run 25.73s)

Exit code: 1
```

`harness_source` in the result JSON is
`shared:res://tests/fixtures/_smallmap_harness.gd` — the shared-harness path
was taken; the embedded fallback stub was not used. This confirms the
ATOM-REPAIR/HARNESS-01 fixes unblocked script load (unlike TEST-RUN-01, where
no JSON or PNG was produced).

## P0 artifacts

### Result JSON (`variant3d/tests/results/t_terrain_only.json`)

Key fields, verbatim values:

- `id`: `t_terrain_only`
- `passed`: `false`
- `verdict`: `FAIL`
- `capture_status`: `PASS`
- `structural_ok`: `false`
- `passes`: `20`, `fails`: `1`, `skipped_or_skip_capture`: `0`
- `harness_source`: `shared:res://tests/fixtures/_smallmap_harness.gd`
- `png_path`: `C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/test01_ladder2/smallmap64_terrain_only.png`
- `parity_label`: `PORT APPROX — internal consistency only; no donor GPU A/B (V3D_02 parity_guard)`
- 21 named checks were evaluated; exactly one has `"passed": false`:
  `full_width_dark_rows`.

Structural measurements in `measured` (all consistent with the 64² baseline):
`mesh_surfaces=1`, `mesh_vertices=4096`, `mesh_triangles=7938`,
`uv2_count=4096`, `uv2_x_min=0.0`, `uv2_x_max=0.0`, `uv2_y_hist={"0":4096}`,
`flat_grid_promoted_cells=0`, `water_plane_count=1`, `water_3d_node_count=1`,
`height_min_m=1.45000541210175`, `height_max_m=1.54998576641083`,
`shader_shadow_enabled="0.0"`, `atlas_grid=[16.0, 8.0]`.

### PNG stats

Command and output:

```
python variant3d\tools\smallmap_capture.py stats "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\test01_ladder2\smallmap64_terrain_only.png"
```

```json
[
  {
    "path": "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\test01_ladder2\\smallmap64_terrain_only.png",
    "bytes": 988242,
    "width": 1280,
    "height": 720,
    "non_black_fraction": 0.992807,
    "mean_rgb": [
      14.045,
      14.381,
      0.001
    ],
    "mean_luma": 13.271,
    "full_width_dark_rows": 720,
    "full_width_dark_row_fraction": 1.0
  }
]
NOTE: qualitative comparison only. No donor parity is claimed.
```

The independent Python reader agrees with the atom's in-GPU metric:
all 720 of 720 rows are classified "full-width dark" (>90 % of pixels with
luma < 20), while 99.28 % of pixels are non-black. Mean colour is a very dark
olive (`mean_rgb ≈ [14.0, 14.4, 0.0]`, `mean_luma ≈ 13.27`).

### stderr scan

Command and output:

```
python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\00000404_TESTRUN02-P0\stderr.txt
```

```json
[
  {
    "path": "variant3d\\.godot_queue\\results\\00000404_TESTRUN02-P0\\stderr.txt",
    "exists": true,
    "script_error_lines": 0,
    "lines": []
  }
]
```

Requirement `SCRIPT ERROR == 0` is **MET**. The job `stderr.txt` (1033 bytes)
does contain other, non-`SCRIPT ERROR` runtime messages, recorded here as
observations (none is the failing check):

```
ERROR: String formatting error: a number is required.
   at: validated_evaluate (core/variant/variant_op.h:770)
   GDScript backtrace (most recent call first):
       [0] _initialize (res://tests/t_terrain_only.gd:416)
ERROR: Condition "!is_inside_tree()" is true. Returning: Transform3D()
   at: get_global_transform (scene/3d/node_3d.cpp:649)
   GDScript backtrace (most recent call first):
       [0] _apply_transform (res://scripts/camera3d.gd:274)
       [1] bind (res://scripts/camera3d.gd:220)
       [2] _initialize (res://tests/t_terrain_only.gd:486)
ERROR: Node not inside tree. Use look_at_from_position() instead.
   at: look_at (scene/3d/node_3d.cpp:1253)
   GDScript backtrace (most recent call first):
       [0] _apply_transform (res://scripts/camera3d.gd:275)
       [1] bind (res://scripts/camera3d.gd:220)
       [2] _initialize (res://tests/t_terrain_only.gd:486)
WARNING: 3 ObjectDB instances were leaked at exit (run with `--verbose` for details).
   at: cleanup (core/object/object.cpp:2536)
```

The `stdout.txt` shows 20 `PASS` lines and one `FAIL` line, ending with:

```
T_TERRAIN_ONLY RESULT_JSON: C:/Users/Maxym.Oboyshev/Documents/Craft Anything/cossacks-3-3/variant3d/tests/results/t_terrain_only.json
T_TERRAIN_ONLY RESULT: FAIL 20/21 evaluated, 0 skipped
```

## Stopping point

**Stopped at P0 (first row of the ladder).** P0's result JSON reports
`passed=false` / `verdict=FAIL`, so the ladder did not advance. Per task rule 3
the failing row was not rerun, no assertion was weakened, and no atom was
edited. No PASS is claimed for P0 or any later row.

## Exact failure details (P0)

- Failed check name: **`full_width_dark_rows`** (last entry of `CHECK_NAMES`,
  index 20).
- Atom detail string (verbatim from result JSON / stdout):
  `full_width_dark_rows=720 (expected 0; smallmap_capture.py:27-28)`.
- Asserted condition: `int(ms["full_width_dark_rows"]) == 0`
  (`variant3d/tests/t_terrain_only.gd:666-667`), mirroring
  `smallmap_capture.py:27-28`: a row is dark when >90 % of its pixels have
  luma < 20.
- Observed value: **720 dark rows out of 720** (fraction 1.0), from both the
  atom's in-GPU metric and the independent `smallmap_capture.py stats` run.
- Contributing image statistics: `non_black_fraction=0.992807` (passes its own
  >0.9 check), but `mean_luma=13.271` and `mean_rgb=[14.045,14.381,0.001]` —
  the rendered ground is uniformly below the luma-20 threshold, so every row
  is classified dark.
- All other 20 named checks passed, including the structural baseline
  (4096 verts / 7938 tris / 4096 UV2 / flat-grid promotions 0 / atlas (16,8) /
  `shadow_enabled=0` / water plane hidden / capture saved). This is a **visual
  image-metric failure**, not a load failure and not a script-error failure.
- Job / result paths:
  - runner job directory `variant3d/.godot_queue/results/00000404_TESTRUN02-P0/`
    (`stdout.txt` 2299 bytes, `stderr.txt` 1033 bytes);
  - atom result `variant3d/tests/results/t_terrain_only.json` (written by the
    atom; `verdict=FAIL`);
  - capture `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\test01_ladder2\smallmap64_terrain_only.png`.
- `SCRIPT ERROR == 0` is satisfied, so this is not a repeat of the
  TEST-RUN-01 parse failure.

No visual PASS claim is made: the mandatory second-agent capture re-check
(`TEST_MATRIX.md:58,75`) is a separate role and was not performed by this
execution owner.

## Rows NOT run and why

| Row | Atom | Reason not run |
|-----|------|----------------|
| P1 | `t_terrain_trees.gd` | Ladder stopped at first failing row (P0). Not submitted. Its `--p0-png` baseline would have been the P0 PNG, which exists but belongs to a FAIL row. |
| P2 | `t_terrain_shore.gd` | Same — not submitted. |
| P3 | `t_terrain_mines.gd` | Same — not submitted. |
| C1 | `t_combo_trees_shore.gd` | Same — not submitted. |
| C2 | `t_combo_trees_mines.gd` | Same — not submitted. |
| C3 | `t_combo_shore_mines.gd` | Same — not submitted. |
| C4 | `t_combo_all.gd` | Same — not submitted. |
| S1 | `t_select_rect.gd` | Explicitly out of scope — S1-INPUT-FIX still working on it. Not submitted. |
| FINAL | selftest 29/29 + uitest 17/17 + clean | Explicitly excluded ("Do NOT run final gates"). Not submitted. |

No row was rerun and no result was harvested as a pass.

## Runner status at end

Final `python variant3d\tools\godot_runner.py status` (after P0, for context only):

```
spool        = C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\variant3d\.godot_queue
now_serving = 408
next_ticket = 411
pending      = 4 [407, 408, 409, 410]
godot.lock   = free
completed    = 406
max wait     = 503.08s   mean wait = 49.06s
max run      = 605.56s
statuses     = {'failed': 129, 'ok': 255, 'timed-out': 22}
```

Other builders' jobs continued through the FIFO runner; none was cancelled or
reordered by this agent.

## Open questions

1. All 720 rows are dark because mean luma is ~13.27 even though ~99.28 % of
   pixels are non-black. Is the root cause shader/terrain output brightness,
   camera framing (e.g. looking away from the lit ground), or the capture
   path's colour/exposure handling? Routing the `full_width_dark_rows` failure
   to the owning fix ticket is a COORD decision; no investigation edit was
   made here.
2. `stderr.txt` reports `String formatting error: a number is required` at
   `t_terrain_only.gd:416`, which matches the literal
   `"source=%s MAP=%dx%d height/tileblock/res_nodes present=%s"` detail printed
   in `stdout.txt`. Appears cosmetic (the check still passed), but it is a
   real runtime `ERROR` line and may be worth fixing in the atom's owner ticket.
3. `camera3d.bind()` is called at `t_terrain_only.gd:486` while the camera is
   not yet inside the tree, producing two transform `ERROR` lines in stderr.
   Whether this affects framing/brightness is UNVERIFIED; it did not produce a
   `SCRIPT ERROR` and was not the failing check.
4. `WARNING: 3 ObjectDB instances were leaked at exit` — source UNVERIFIED.
5. Donor visual parity remains UNVERIFIED for every row: no 64² donor A/B
   frame exists (`TEST_MATRIX.md:32-34`, `V3D_02 parity_guard`). The atom's own
   label is `PORT APPROX — internal consistency only`.
6. The seven sibling atoms (P1–C4) were not executed, so their run-time state
   after ATOM-REPAIR/HARNESS-01 is UNVERIFIED. They are not claimed runnable
   beyond the task context statement.

## Final summary

- **Executed:** 1 row (P0, ticket 404 / `TESTRUN02-P0`), windowed, one Godot
  at a time via the runner.
- **Result:** runner `END failed`, exit 1; wait 255.49 s, run 25.73 s.
- **Verdict from result JSON:** `passed=false`, `verdict=FAIL` (20 pass, 1 fail,
  0 skipped). No PASS claimed.
- **Capture:** PNG produced; `smallmap_capture.py stats` reports
  `full_width_dark_rows=720` (fraction 1.0), `non_black_fraction=0.992807`,
  `mean_luma=13.271`.
- **`SCRIPT ERROR == 0` requirement:** MET (`script_error_lines: 0`), unlike
  TEST-RUN-01 — the parse-error blocker is resolved.
- **Exact failing check:** `full_width_dark_rows` — expected 0, observed 720.
- **Stopping point:** P0 (first failing row). P1–C4 not run by the stop rule;
  S1 and FINAL out of scope.
- **No test was weakened, no atom was edited, and no failing row was rerun.**
- **Action required:** route the P0 `full_width_dark_rows` failure to the
  owning fix ticket; the ladder cannot proceed past P0 until that row passes.

---

*End of TEST-RUN-02. Facts only; no PASS claim beyond what the result JSON,
runner output, PNG stats and stderr scan establish.*
