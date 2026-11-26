---
id: Y08B-CAPTURE-LOG-01
title: "Y08b — capture GATE FAIL: 5 SCRIPT ERRORs (game.gd:397-398 undeclared 'ci'), no PNG, watchdog forced exit"
ticket: Y08b (visual re-capture after Y08b + reverted UV probe)
owner: G04 (sole runner-owning agent)
created: 2026-11-25
status: GATE_FAIL__SCRIPT_ERROR_5__NO_PNG__NO_SOURCE_EDIT__NO_RERUN__PARITY_UNVERIFIED
scope: "Exactly one new report written. One runner job submitted (y08b-realmap). No other gate re-run, no code/config/test/tool edit, no weakening, no process kill, no unwedge/ack/reset/doctor."
labels: [observed, derived, inferred, UNVERIFIED]
charter: docs/terrain_swarm_2026-11-25/CHARTER.md
wave_charter: docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
previous_log: docs/terrain_swarm_2026-11-25/reports/UVPROBE_capture_log.md
---

# Y08b — fresh real-map capture attempt (after Y08b + reverted UV probe)

## 0. Authority and reason for this job

COORD authorised exactly one fresh visual re-capture after Y08b (`game.gd` edited, backup
`.bak-Y08b`) and the reverted UV probe (COORD reported these — G04 did not inspect or edit them).
G04 is the sole runner-job owner (`WAVE_G_CHARTER.md:31`). **This attempt FAILED**; no PNG exists.

Labels: **OBSERVED** = direct command/file output; **DERIVED** = control-flow/arithmetic;
**INFERRED** = plausible reading with caveat; **UNVERIFIED** = not proven (above all, donor parity).

## 1. Pre-flight and submission

`python variant3d\tools\godot_runner.py status` before submission: `now_serving=604`,
`next_ticket=604`, `pending=0 []`, `godot.lock=free`. Fresh artifact dir created:
`New-Item -ItemType Directory -Force -Path "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\y08b"`.

Exact command submitted (windowed — no `--headless`, no `--dump-config`):
```
python variant3d\tools\godot_runner.py run --id y08b-realmap --timeout 700 -- --path variant3d -- --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/y08b/realmap.png" --screenshot-frames 10 --seed 20261113 --timeout 600
```

## 2. Result — FAILED

Result JSON `variant3d\.godot_queue\results\00000604.json` (verbatim fields):
- `ticket`: **604**, `id`: `y08b-realmap`
- `argv`: `--path variant3d -- --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/y08b/realmap.png" --screenshot-frames 10 --seed 20261113 --timeout 600`
- `wait`: 0.003367900848388672 s, `run`: **609.9024157524109 s**, `exit`: **1**,
  `timeout`: 700.0, `status`: **failed**
- stdout: `variant3d\.godot_queue\results\00000604_y08b-realmap\stdout.txt`
- stderr: `variant3d\.godot_queue\results\00000604_y08b-realmap\stderr.txt`

**No PNG.** `Get-ChildItem "C:\Users\...\opencode\y08b\"` returned **empty**. The `stats` tool
failed with `FileNotFoundError` (same shape recorded in `L07_gate_log.md §8.4`); no `stats`
numbers exist, and no capture diag line appears in stdout. Therefore the user-requested checks
"exit 0" and "PNG 1280×720 non-blank" both FAIL.

Verbatim `python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\00000604_y08b-realmap\stderr.txt`:
```
[
  {
    "path": "variant3d\\.godot_queue\\results\\00000604_y08b-realmap\\stderr.txt",
    "exists": true,
    "script_error_lines": 5,
    "lines": [
      "SCRIPT ERROR: Parse Error: Identifier \"ci\" not declared in the current scope.",
      "SCRIPT ERROR: Parse Error: Identifier \"ci\" not declared in the current scope.",
      "SCRIPT ERROR: Compile Error: Failed to compile depended scripts.",
      "SCRIPT ERROR: Compile Error: Failed to compile depended scripts.",
      "SCRIPT ERROR: Invalid call. Nonexistent function 'new' in base 'GDScript'."
    ]
  }
]
```
→ **SCRIPT ERROR = 5** (gate requires 0).

Verbatim stderr tail (failure chain, read by G04 read-only):
```
SCRIPT ERROR: Parse Error: Identifier "ci" not declared in the current scope.
   at: GDScript::reload (res://scripts/game.gd:397)
SCRIPT ERROR: Parse Error: Identifier "ci" not declared in the current scope.
   at: GDScript::reload (res://scripts/game.gd:398)
SCRIPT ERROR: Compile Error: Failed to compile depended scripts.
   at: GDScript::reload (res://scripts/world.gd:0)
SCRIPT ERROR: Compile Error: Failed to compile depended scripts.
   at: GDScript::reload (res://scripts/main.gd:0)
ERROR: Failed to load script "res://scripts/main.gd" with error "Compilation failed".
   at: load (modules/gdscript/gdscript_resource_format.cpp:46)
SCRIPT ERROR: Invalid call. Nonexistent function 'new' in base 'GDScript'.
   at: _setup_full_game (res://scripts/main.gd:1085)
   GDScript backtrace (most recent call first):
       [0] _setup_full_game (res://scripts/main.gd:1085)
       [1] _ready (res://scripts/main.gd:235)
watchdog: wall-clock limit reached, forced exit
```

**DERIVED:** the Y08b `game.gd` edit introduced undeclared `ci` at `:397`/`:398`; `game.gd`
failed to parse, which cascaded to `world.gd`/`main.gd` compile failures and a failed
`main.gd` instantiation at `:1085`; the game then idled until the documented 600 s main watchdog
forced exit (~610 s wall). The runner's own 700 s limit was not the binding limit.

**Verdict:** **GATE FAIL** on three independent grounds — runner exit 1, `SCRIPT ERROR = 5`, and
no PNG. Per `C02_gate_plan.md:378-396` and `L07_reverify_batch.md §6`, a missing frame is
`UNVERIFIED → FAIL`, never a PASS. No cross-capture A/B and no donor claim arise from it.

## 3. Final state and honesty statement

Final `status`: `now_serving=605`, `next_ticket=605`, `pending=0 []`, `godot.lock=free`. One new
unique ticket consumed (604). No other gate was re-run.

- No code/config/test/tool edit; no threshold lowered, no test weakened, no assertion deleted.
  G04 did **not** fix `game.gd:397-398`; that is the owning agent's task.
- **No rerun** was performed — standing "no reruns without go-ahead" rule; COORD did not
  authorise a second attempt here.
- **PORT APPROX — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this log certifies neither donor fidelity nor a gate pass.**
- G04 performed no visual R1–R6 verdict and no C01/T11 metric scoring.

## 4. Hand-off

**DONE (job submitted and recorded; result = FAIL).** Flagged to COORD: the owning agent must
resolve the undeclared `ci` at `res://scripts/game.gd:397-398` (and the resulting `main.gd`
compile/instantiation failure), after which a fresh capture under a new unique id is required.
G04 will not rerun without explicit authorisation. Stays available.

*End of Y08b capture log — one job, FAILED (SCRIPT ERROR 5, no PNG), donor parity UNVERIFIED.*
