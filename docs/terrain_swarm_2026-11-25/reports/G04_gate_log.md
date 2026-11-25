---
id: G04-GATE-LOG-01
title: "G04 — sole Wave G runner owner: gate re-run log (pre-flight block cleared; 6 runner tickets executed)"
ticket: G04
owner: G04 (sole runner-owning Wave G agent)
created: 2026-11-25
status: DONE__NO_SOURCE_EDIT__UITEST_NOT_A_PASS__PARITY_UNVERIFIED
scope: "This report only. No .gd/.gdshader/config/test/fixture/tool/result file was created or edited. After COORD cleared the stale job, six unique g04- runner tickets were submitted sequentially via godot_runner.py run (one at a time, status between each); no unwedge/ack/reset/doctor and no process kill by name. Raw runner stdout/stderr/result JSONs are tool artifacts outside source ownership."
labels: [observed, derived, inferred, UNVERIFIED]
charter: docs/terrain_swarm_2026-11-25/CHARTER.md
wave_charter: docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
---

# G04 — gate log (pre-flight result)

## 0. Authority and labels

Per `WAVE_G_CHARTER.md:31`, G04 is the **only** Wave G agent permitted to submit runner jobs;
per `WAVE_G_CHARTER.md:42` its sole output is this file. Per the dispatch, the job顺序 is
selftest → uitest → t_render_mode → windowed P0 capture → windowed real-map capture, each with a
unique `g04-` id. **Observed** = file/command output read directly; **Derived** = control-flow /
arithmetic consequence; **Inferred** = plausible reading with caveat; **UNVERIFIED** = not
proven (above all, donor parity — no donor GPU A/B frame exists).

## 1. Pre-flight (G0) — FAILED, so no job was submitted

Command (repo root, Windows `python`):

```
python variant3d\tools\godot_runner.py status
```

Observed output (run twice, identical; first at ~14:43, re-confirmed 14:44 CEST):

```
spool        = C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\variant3d\.godot_queue
now_serving = 584
next_ticket = 584
pending      = 1 [582]
godot.lock   = free
completed    = 500
max wait     = 1825.52s   mean wait = 148.06s
max run      = 1207.38s
statuses     = {'failed': 153, 'ok': 306, 'skipped': 18, 'timed-out': 23}
```

Pre-flight criteria from `C02_gate_plan.md:85-89` and the dispatch:

| Criterion | Required | Observed | Verdict |
|---|---|---|---|
| `pending` | 0 | **1 `[582]`** | **FAIL** |
| `godot.lock` | free | free | PASS |
| counter alignment | `now_serving == next_ticket` | 584 == 584 | PASS |
| live Godot processes | 0 | 0 (`Get-CimInstance Win32_Process -Filter "Name like 'Godot%'"` returned no rows) | PASS |

**One criterion fails.** The dispatch says "require lock free and pending=0"; `C02_gate_plan.md:382`
says a non-zero pending is a **submit-nothing / wait** condition. Therefore **no runner job was
submitted**. No process was killed by name; no `cancel`/`unwedge`/`ack`/`reset`/`doctor` was run.

### 1.1 Counter-desync check — NONE observed

`now_serving` (584) equals `next_ticket` (584) — counter is aligned. The `unwedge` desync that
`WAVE_G_CHARTER.md:27` attributed to the earlier Wave G launch is **not present now** (COORD's
reset to 583, plus later jobs, left it consistent). There is no desync to report to COORD.

### 1.2 Diagnosis of the stale ticket 582 (read-only)

- `variant3d\.godot_queue\jobs\00000582.json` exists (id `terrainswarm-g1-selftest`, argv
  `--headless --path variant3d -- --self-test variant3d/selftest.json`, ticket created at epoch
  1795613838.3). Its job file still sits in the spool, which is what makes `pending` non-zero.
- `variant3d\.godot_queue\results\00000582.json` already records it as terminal:
  `"status": "skipped"`, `"error": "ticket 582 was skipped (serving=2581)"`, `run=0.0`.
- `WAVE_G_CHARTER.md:27` notes 2000 bogus `skipped` result JSONs were deleted earlier; ticket 582
  is another skipped selftest from that churn (a duplicate of ticket 583, which ran and failed on
  B05's two parse errors — since fixed by COORD).
- **Derived:** the FIFO runner advances `now_serving` only when a serving job finishes or its
  holder is reclaimed (`godot_runner.py:324-378,466-470`); a skipped job that was *never* served
  can leave an orphan `jobs/*.json` behind while a later ticket (583) already ran, producing
  `now_serving=584` with a stale lower-numbered pending job. No live PID holds it (`holder_pid`
  lookups and the empty Godot process list confirm this).
- **Inferred:** the stale 582 job file is a bookkeeping remnant, not a live job; but cleaning it
  up (`cancel --ticket 582` or manual removal) is a queue mutation that the dispatch does not
  authorise for G04 and that `WAVE_G_CHARTER.md:27` reserves for COORD ("COORD handles it").
  G04 did not touch it.

**Action taken:** none beyond status reads and read-only file inspection. Reported to COORD so
the owner can decide whether to cancel/clear ticket 582 and re-run pre-flight.

## 2. Required job plan — prepared but NOT submitted

All ids below are reserved/unique (`g04-` prefix, none reused). None has been taken as a ticket.

| # | id | Command (from dispatch) | Timeout | Status |
|---|---|---|---|---|
| 1 | `g04-selftest` | `--headless --path variant3d -- --self-test variant3d/selftest.json` | 300 | NOT SUBMITTED (pre-flight fail) |
| 2 | `g04-uitest` | `--headless --path variant3d -- --ui-test variant3d/uitest.json` | 300 | NOT SUBMITTED |
| 3 | `g04-rendermode` | `--headless --path variant3d --script res://tests/t_render_mode.gd` | (dispatch default) | NOT SUBMITTED |
| 4 | `g04-p0cap` | **WINDOWED**, P0 capture per `A09_capture_plan.md` §2.1 + `stats`/`scan-stderr` | 300 | NOT SUBMITTED |
| 5 | `g04-realmap` | **WINDOWED**, real-map capture with seed `20261113` pinned, per `A09_capture_plan.md` §1/§2.2 | 300 | NOT SUBMITTED |

No ticket id, status, exit code, result JSON path, PNG path, `stats` numbers or
`SCRIPT ERROR` count can be recorded because no job ran — all are **UNVERIFIED / N/A**.

### 2.1 Prepared launch forms (exact, for use once pre-flight is clear)

From `A09_capture_plan.md:62-99` (§2.1/§2.3) and C02 `G2/G3` (`C02_gate_plan.md:135-192`).
Create the artefact dir first:
`New-Item -ItemType Directory -Force -Path "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\g04" | Out-Null`.

```
python variant3d\tools\godot_runner.py run --id g04-selftest --timeout 300 -- --headless --path variant3d -- --self-test variant3d/selftest.json
python variant3d\tools\godot_runner.py run --id g04-uitest --timeout 300 -- --headless --path variant3d -- --ui-test variant3d/uitest.json
python variant3d\tools\godot_runner.py run --id g04-rendermode --timeout 120 -- --headless --path variant3d --script res://tests/t_render_mode.gd
python variant3d\tools\godot_runner.py run --id g04-p0cap --timeout 300 -- --path variant3d --script res://tests/t_terrain_only.gd -- --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/g04/p0_64.png" --png "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/g04/p0_64.png"
```

For `g04-realmap` (no `--script`, windowed, seed pinned via `--seed` after config merge per
`A09_capture_plan.md:33,85,89`):

```
python variant3d\tools\godot_runner.py run --id g04-realmap --timeout 300 -- --path variant3d -- --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/g04/realmap.png" --screenshot-frames 10 --seed 20261113 --timeout 120
```

Observed config check just before this report: `variant3d/config.json` has
`random_seed: 20261113` (matches the pinned seed) and `map_width_tiles/map_height_tiles: 240`
(not 320²), and `camera.start_zoom: 0.3448276` — consistent with `A09_capture_plan.md:33-42`.
A09 notes the shipped map may be 240²; no 320² override was prepared because the dispatch asks
for a **real-map** capture with pinned seed, not specifically 320². Any later `real_320.json`
overlay would be a PORT APPROX map-size arm, never a shader-uniform A/B (`C02_gate_plan.md:189`).

Read-only verification planned after each result JSON exists (verbatim outputs to be pasted in a
follow-up to this report):

```
python variant3d\tools\smallmap_capture.py stats "<PNG>"
python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\<ticket>_<g04-id>\stderr.txt
```

`stats` is qualitative only ("No donor parity is claimed"); `scan-stderr` must return
`script_error_lines: 0`. Expected gates (not yet evaluated): selftest fresh 29/29 `passed=true`,
uitest 17/17, `t_render_mode` `result=PASS`/`seam_missing=false`, P0 PNG 1280×720 non-blank with
`non_black_fraction >= 0.9`, `mean_luma >= 40`, `max_luma >= 100`, real-map no new
seams/black rows, `SCRIPT ERROR == 0` everywhere (`C02_gate_plan.md:378-396`).

## 3. Honesty / parity statement

- No donor GPU A/B frame exists; **donor parity stays UNVERIFIED** regardless of any future gate
  result (`CHARTER.md:57-58,124-130`).
- `stats`/metrics are PORT APPROX internal consistency only; no donor-parity claim is made.
- No test was weakened, no threshold lowered, no `expected_pre_fix_failure` flipped.
- No process was killed by name; if a future job hangs, G04 will use only the runner's own
  `status`/timeout/`cancel --ticket` path and report, never `taskkill /IM`/`Stop-Process -Name`
  (`C02_gate_plan.md:408-452`).

## 4. Hand-off / open question for COORD

**UNBLOCK REQUESTED.** Pending ticket 582 is terminal (`skipped`) but its job file remains in
`variant3d\.godot_queue\jobs\`, so `pending=1` and G0 fails. Counter is aligned and lock/process
state are clean, so there is no desync for G04 to escalate — only the stale job file. COORD should
either run `python variant3d\tools\godot_runner.py cancel --ticket 582` (with an explicit
reason, since it is a pending job) or clear it by its own authority, then re-run `status` to
confirm `pending=0`. Once that is done, send a follow-up to this session and G04 will submit the
five `g04-` jobs sequentially, one at a time, re-checking `status` between each, and append the
full evidence (ticket, status, exit, JSON/PNG paths, verbatim `stats`, `SCRIPT ERROR` counts) to
this same report.

## 5. UNBLOCK + execution evidence (added after COORD cleared stale ticket 582)

**Unblock verified by G04 itself** before submitting anything: `now_serving=584`,
`next_ticket=584`, `pending=0 []`, `godot.lock=free`, 0 live Godot processes. No desync.
Counters advanced cleanly to `590/590` by the end (final status below); every job waited 0.00 s.

All jobs were submitted **one at a time** with `status` re-checked between them, using unique
`g04-` ids and the runner's own timeout/kill path only. **No process was killed by name**, no
threshold was lowered, no test weakened, no `reset`/`ack`/`doctor` used. All job results JSONs
and stdout/stderr live under `variant3d\.godot_queue\results\<ticket>_<id>\`.

### 5.1 Job-by-job evidence

| # | id | ticket | runner status / exit | run | result JSON | SCRIPT ERROR |
|---|---|---|---|---|---|---|
| 1 | `g04-selftest` | 584 | **ok / 0** | 228.67 s | `variant3d\.godot_queue\results\00000584.json` | **0** |
| 2 | `g04-uitest` | 585 | **timed-out / -9** | 308.54 s (limit 300) | `variant3d\.godot_queue\results\00000585.json` | **0** |
| 2b | `g04-uitest2` | 587 | **failed / 1** | 138.30 s (limit 600) | `variant3d\.godot_queue\results\00000587.json` | **0** (engine `ERROR:` only) |
| 3 | `g04-rendermode` | 586 | **ok / 0** | 16.87 s | `variant3d\.godot_queue\results\00000586.json` | **0** |
| 4 | `g04-p0cap` | 588 | **ok / 0** | 28.74 s | `variant3d\.godot_queue\results\00000588.json` | **0** |
| 5 | `g04-realmap` | 589 | **ok / 0** | 161.29 s | `variant3d\.godot_queue\results\00000589.json` | **0** |

Every `scan-stderr` returned `{"exists": true, "script_error_lines": 0, "lines": []}`
(paths: `...\00000584_g04-selftest\stderr.txt`, `...\00000585_g04-uitest\stderr.txt`,
`...\00000587_g04-uitest2\stderr.txt`, `...\00000586_g04-rendermode\stderr.txt`,
`...\00000588_g04-p0cap\stderr.txt`, `...\00000589_g04-realmap\stderr.txt`).

**(1) `g04-selftest` — PASS.** `variant3d/selftest.json`: `passed=true`, 29 steps, 29 passed,
0 failed. Exit 0. No PNG (headless).

**(2)+(2b) uitest — NOT A PASS; performance/harness finding.** First attempt `g04-uitest` hung
in game setup (`_setup_full_game` → `bind` → `build` → `_load_masks` warnings repeating) and was
hard-killed by the runner at 300 s (`[runner] KILLED after 300.0s`), `exit=-9`, `script_error_lines=0`.
Re-run `g04-uitest2` at 600 s exited 1 at 138.30 s; stderr contains
`watchdog: wall-clock limit reached, forced exit`, `WARNING: 3 ObjectDB instances were leaked at
exit`, `ERROR: 1 resources still in use at exit` — **engine** errors, not `SCRIPT ERROR`
(`scan-stderr` = 0). **Derived:** `main.gd:209,210-212,1588-1591` sets a default 120 s hard
watchdog for `--ui-test`, so the process was force-exited rather than completing normally; the
runner timeout was not the binding limit. **OBSERVED discrepancy to flag for COORD:** COORD's
follow-up states `uitest.json` was written 17/17 before the watchdog fired, but the on-disk
`variant3d/uitest.json` still reads `passed=true`/17-of-17 with `LastWriteTime = 2026-11-25
13:30:42`, which **predates both jobs** (job 585's stdout mtime is 14:52:40; job 587's stdout mtime
is later still). Both job stdouts contain only the Godot version banner — no test-progress lines.
So the 17/17 value is UNVERIFIED as *fresh* evidence from either run; it is recorded as stale,
not as a PASS for G6. No assertion was observed failing and no threshold/marker was touched.

**(3) `g04-rendermode` — PASS.** `variant3d/tests/results/t_render_mode.json`:
`passed=true`, `result=PASS`, `seam_missing=false`, 10/10 checks PASS including the hard
`render_mode_default_2d` / `runtime_default_2d` gates. (Submitted before COORD's "skip rendermode"
follow-up; already green, so not duplicated.)

**(4) `g04-p0cap` — PASS (windowed, no `--headless`).** Result: exit 0. PNG:
`C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/g04/p0_64.png` (923,061 bytes).
Verbatim `smallmap_capture.py stats`:
```
non_black_fraction = 1.0
mean_rgb = [94.562, 97.418, 32.367]
mean_luma = 92.134
full_width_dark_rows = 0
full_width_dark_row_fraction = 0.0
width=1280 height=720
```
Atom stdout gates: `T_TERRAIN_ONLY PASS capture_saved`, `ground_mean_luma - mean_luma=92.134
(strict >=40)`, `ground_max_luma - max_luma=119.160 (strict >=100)`,
`full_width_dark_rows - ... RECORDED_NOT_APPLICABLE (no water layer in P0; diagnostic only)`.
`script_error_lines=0`.

**(5) `g04-realmap` — PASS (windowed, no `--headless`).** Runner `--timeout 600`, main
`--timeout 600` (prevents the 120 s default watchdog), `--seed 20261113`, `--screenshot-frames 10`,
shipped real map (config observed at 240², seed 20261113). Result: exit 0. PNG:
`C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/g04/realmap.png` (1,799,634 bytes);
sidecar `realmap.png.raw.png` (1,799,634 bytes) also present. Verbatim `stats`:
```
non_black_fraction = 1.0
mean_rgb = [90.471, 86.357, 39.123]
mean_luma = 83.828
full_width_dark_rows = 0
full_width_dark_row_fraction = 0.0
width=1280 height=720
```
Verbatim capture diag from stdout:
`screenshot capture diag: viewport=Screenshot3DViewport image=1280x720
p00=(0.3412, 0.349, 0.098, 1.0) pcenter=(0.1059, 0.098, 0.0941, 1.0) camera_current=true
world_parent=Screenshot3DViewport camera_pos=(144.1104, 58.0, -88.57262) target=(384.1104, 58.60797)`
and `screenshot capture source: Screenshot3DViewport/1280x720`, `screenshot saved: .../realmap.png`.
`script_error_lines=0`.

### 5.2 Final queue state (read-only, no job submitted)
```
now_serving = 590
next_ticket = 590
pending      = 0 []
godot.lock   = free
```
0 live Godot processes. Six unique `g04-` ids consumed (584,585,586,587,588,589).

## 6. Gate summary and honesty statement

- **OBSERVED PASS:** selftest 29/29 fresh; `t_render_mode` 10/10 PASS with 2D default intact;
  windowed P0 and real-map captures exist, 1280×720, non-blank, `full_width_dark_rows=0`,
  `SCRIPT ERROR == 0` on every job.
- **OBSERVED FAIL / UNVERIFIED:** uitest did not produce a fresh 17/17 result in two attempts
  (runner timeout at 300 s; then main watchdog forced exit with engine resource-leak errors at
  138 s). G6 is **not satisfied** by G04's evidence; this is a performance/teardown finding, not a
  weakened or failed assertion. No rerun beyond the COORD-authorised second attempt.
- **INFERRED:** the two captures are suitable inputs for G05's C04-protocol visual read; G04 did
  **not** perform the visual verdict (second-agent rule), and did not run A09's TRACK A/B scoring.
- **UNVERIFIED:** donor parity — no donor GPU A/B frame exists. `stats`/luma numbers are strict
  PORT APPROX integrity gates and qualitative inspectors only ("No donor parity is claimed");
  they never substitute for the visual read or override a visible artifact.
- **No source edits:** only this report was written by G04. No test, threshold, fixture or tool was
  changed; no process killed by name; no runner command beyond `status` and `run` was used.

*End of G04 gate log — five jobs submitted post-unblock (6 runner tickets incl. the authorised
uitest re-run), full evidence above. DONE; available for COORD follow-up.*
