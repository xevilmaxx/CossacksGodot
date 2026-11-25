---
id: TEST-RUN-01
title: "Execution log — 64² piece→combo ladder (P0→C4)"
owner: TEST-RUN-01 (execution owner; read-only on all game code/tests)
date: 2026-11-25
status: STOPPED_AT_FIRST_FAILING_ROW__P0
scope: "Sequential runner execution only. No .gd, config, manifest, shader, fixture or other report was edited by this agent. Only this log file is authored."
owns:
  - "docs/coord_swarm_2026-11-25/reports/TEST_RUN_01_ladder_log.md"
matrix: "docs/coord_swarm_2026-11-25/TEST_MATRIX.md:53-75"
evidence_labels: [observed]
ladder: "P0 -> P1 -> P2 -> P3 -> C1 -> C2 -> C3 -> C4 -> S1 -> FINAL"
stop_rule: "TEST_MATRIX.md:60-61 / task rule 4 — stop at first row whose result does not pass; no rerun, no assertion weakening, no atom edit"
---

# TEST-RUN-01 — execution log: 64² piece→combo ladder

## Runner status at start

Captured with `python variant3d\tools\godot_runner.py status` before the first submission:

```
spool        = ...\variant3d\.godot_queue
now_serving  = 319
next_ticket  = 320
pending      = 1 [319]
godot.lock   = HELD (age 5.1s)
completed    = 318
max wait     = 503.08s   mean wait = 50.69s
max run      = 605.56s
statuses     = {'failed': 82, 'ok': 214, 'timed-out': 22}
```

A builder job (ticket 319, `cfg02-selftest-iso1`) was in flight and queue lock was held.
Per protocol the first atom was submitted through the FIFO runner (one Godot at a
time, no direct `godot` call). Note: ticket 320 (`sel01-tselect-win`) was claimed by
another builder between the status check and this agent's submission, so this
agent's first job received ticket **321**. This is normal FIFO interleaving, not a
re-submission.

## Environment / conventions obeyed

- Windows `python` (3.14) only; never `python3`.
- All launches: `python variant3d\tools\godot_runner.py run --id TESTRUN01-<row> --timeout <s> -- --path variant3d --script res://tests/<atom>.gd -- <user args>`.
- All rows were launched **windowed** (no `--headless`), because 3D PNGs cannot be captured headless.
- PNG output directory `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\test01_ladder\` was created; no PNG was written into the repo.
- Tool timeouts for runner calls were 900000 ms (≥ 300000 ms required).

## Executed rows

| # | Atom | runner job (ticket / id) | result JSON | Verdict | PNG path | `stats` | `scan-stderr` | Wall time |
|---|------|--------------------------|-------------|---------|----------|---------|---------------|-----------|
| P0 | `t_terrain_only.gd` | 321 / `TESTRUN01-P0` | `variant3d/tests/results/t_terrain_only.json` — **ABSENT** (script never loaded, so no JSON was written) | runner `END failed`, exit 1; no verdict emitted by atom (`SCRIPT ERROR: Parse Error` at load) | `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\test01_ladder\smallmap64_terrain_only.png` — **ABSENT** | `stats` could not run: `FileNotFoundError` (PNG absent) | `script_error_lines: 4` (see below) | wait 0.00 s, run 6.50 s |

Launch used for P0:

```
python variant3d\tools\godot_runner.py run --id TESTRUN01-P0 --timeout 120 -- --path variant3d --script res://tests/t_terrain_only.gd -- --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/test01_ladder/smallmap64_terrain_only.png"
```

Runner output:

```
[runner] ticket 321 'TESTRUN01-P0' START (waited 0.00s)
[runner] ticket 321 'TESTRUN01-P0' END failed (run 6.50s)
Exit code: 1
```

`SCRIPT ERROR == 0` requirement: **NOT MET** — 4 `SCRIPT ERROR` lines.

## Stopping point

**Stopped at P0 (first row).** P0 is the first failing row and the ladder did not
advance. Per task rule 4 the failing row was not rerun, no assertion was weakened,
and the atom was not edited.

## Exact failure details (P0)

Failure is a **GDScript parse error at script load**, before any atom check ran and
before any result JSON or PNG could be produced. The runner job's
`stderr.txt` (`variant3d/.godot_queue/results/00000321_TESTRUN01-P0/stderr.txt`,
807 bytes) contains:

```
SCRIPT ERROR: Parse Error: The member "res_dirty" already exists in parent class C3Game.
   at: GDScript::reload (res://tests/t_terrain_only.gd:97)
SCRIPT ERROR: Parse Error: The member "entities" already exists in parent class C3Game.
   at: GDScript::reload (res://tests/t_terrain_only.gd:98)
SCRIPT ERROR: Parse Error: The member "res_nodes" already exists in parent class C3Game.
   at: GDScript::reload (res://tests/t_terrain_only.gd:101)
SCRIPT ERROR: Parse Error: The function signature doesn't match the parent. Parent signature is "resolve_mine_sid(String, Vector2) -> String".
   at: GDScript::reload (res://tests/t_terrain_only.gd:115)
ERROR: Failed to load script "res://tests/t_terrain_only.gd" with error "Parse error".
   at: load (modules/gdscript/gdscript_resource_format.cpp:46)
```

`stdout.txt` (169 bytes) contains only the Godot version / OpenGL device banner
(`Godot Engine v4.7.2.stable...`, `OpenGL API 3.3.0 NVIDIA 571.96 - Compatibility -
Using Device: NVIDIA - NVIDIA GeForce MX130`) — no atom `RESULT:` line and no
`T_TERRAIN_ONLY RESULT:` line.

`python variant3d\tools\smallmap_capture.py scan-stderr <P0 stderr.txt>` output:

```json
[
  {
    "path": "variant3d\\.godot_queue\\results\\00000321_TESTRUN01-P0\\stderr.txt",
    "exists": true,
    "script_error_lines": 4,
    "lines": [
      "SCRIPT ERROR: Parse Error: The member \"res_dirty\" already exists in parent class C3Game.",
      "SCRIPT ERROR: Parse Error: The member \"entities\" already exists in parent class C3Game.",
      "SCRIPT ERROR: Parse Error: The member \"res_nodes\" already exists in parent class C3Game.",
      "SCRIPT ERROR: Parse Error: The function signature doesn't match the parent. Parent signature is \"resolve_mine_sid(String, Vector2) -> String\"."
    ]
  }
]
```

`python variant3d\tools\smallmap_capture.py stats <P0 png>` failed with
`FileNotFoundError` because the PNG was never produced (script did not load).

**Exact failed check:** none of the atom's named checks executed. The failing item
is the script load itself (`GDScript::reload`) — four parse errors in the embedded
`LocalStubGame extends C3Game` fallback region (`t_terrain_only.gd:97,98,101,115`):
three members re-declared from the `C3Game` parent (`res_dirty`, `entities`,
`res_nodes`) and one parent-signature mismatch on `resolve_mine_sid`.

**Job / result paths:** runner job
`variant3d/.godot_queue/results/00000321_TESTRUN01-P0/` (`stderr.txt`, `stdout.txt`);
atom result path `variant3d/tests/results/t_terrain_only.json` (does not exist).

## Rows NOT run and why

| Row | Atom | Reason not run |
|-----|------|----------------|
| P1 | `t_terrain_trees.gd` | Ladder stopped at first failing row (P0). Not submitted. |
| P2 | `t_terrain_shore.gd` | Same — not submitted. |
| P3 | `t_terrain_mines.gd` | Same — not submitted. |
| C1 | `t_combo_trees_shore.gd` | Same — not submitted. |
| C2 | `t_combo_trees_mines.gd` | Same — not submitted. |
| C3 | `t_combo_shore_mines.gd` | Same — not submitted. |
| C4 | `t_combo_all.gd` | Same — not submitted. |
| S1 | `t_select_rect.gd` | Explicitly out of scope for TEST-RUN-01 (depends on SEL-01's in-flight fix; later ticket). Not submitted. |
| FINAL | selftest 29/29 + uitest 17/17 + clean | Explicitly owned by COORD, not by this agent. Not submitted. |

No row was rerun and no result was harvested as a pass.

## Open questions

1. The parse errors are in the **embedded `LocalStubGame extends C3Game` fallback**
   inside `t_terrain_only.gd`. GDScript parses the whole file at load time, so the
   fallback class blocks the shared-harness path before it can run. Multiple sibling
   atoms embed a same-shape fallback (`t_terrain_trees.gd`, `t_terrain_shore.gd`,
   `t_terrain_mines.gd`, `t_combo_trees_shore.gd`, `t_combo_trees_mines.gd`,
   `t_combo_shore_mines.gd`, `t_combo_all.gd`) — whether they carry the identical
   parent-redeclaration defect is **UNVERIFIED** (they were not executed, per the
   stop rule). This may be systemic; routing to the owning authoring ticket(s) is a
   COORD decision.
2. `resolve_mine_sid` in `C3Game` now has signature `resolve_mine_sid(String,
   Vector2) -> String`; the fallback overrides with a non-matching signature. This
   indicates the base class `C3Game` already supplies these members, so the
   fallback stubs should likely not re-declare them — but no fix was applied here
   (atom is read-only for this agent).
3. Donor visual parity remains UNVERIFIED for every row (no 64² donor A/B frame;
   `TEST_MATRIX.md:32-34`). The mandatory second-agent capture re-check
   (`TEST_MATRIX.md:58,75`) never became applicable — no PNG was produced.
4. Queue state after P0 was not re-polled for this log; the start-of-run status is
   recorded above as required.

## Final summary

- **Executed:** 1 row (P0, ticket 321 / `TESTRUN01-P0`).
- **Result:** failed — runner exit 1, `END failed`, 6.50 s run, 0.00 s wait.
- **Verdict from result JSON:** no result JSON was produced, so no atom verdict
  exists. No PASS is claimed.
- **Capture:** no PNG; `SCRIPT ERROR == 0` check failed (4 parse errors).
- **Stopping point:** P0 (first failing row).
- **Not run:** P1–C4 (ladder stopped), S1 and FINAL (out of scope for this ticket).
- **No test was weakened, no atom was edited, and no failing row was rerun.**
- **Action required:** route the P0 script-load parse errors to the owning atom
  authoring ticket (TEST-P0). The ladder cannot proceed until the atom loads.

---

*End of TEST-RUN-01. Facts only; no PASS claim beyond what runner output and stderr establish.*
