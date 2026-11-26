---
id: V06
swarm: TERRAIN-SWARM-2026-11-26
title: "V06 — exact, legitimate remediation plan for stale gates, mixed-aperture capture tools, runner history and the missing fresh baseline"
role: READ-ONLY REMEDIATION PLAN — no Godot process, no runner job, no code/config/asset/test/JSON edit, one report only
owner_file: docs/terrain_swarm_2026-11-26/reports/V06_gate_remediation.md
status: PLANNED_ONLY__NO_RUNNER_JOB__NO_EDIT__PARITY_UNVERIFIED
created: 2026-11-26
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, "PORT APPROXIMATION"]
charter: docs/terrain_swarm_2026-11-26/CHARTER.md
board: docs/terrain_swarm_2026-11-26/SWARM_BOARD.md
predecessors:
  - docs/terrain_swarm_2026-11-26/reports/P03_gates_capture.md
  - docs/terrain_swarm_2026-11-26/reports/A05_qa_harness.md
  - docs/terrain_swarm_2026-11-26/spec/12_QA_AND_INTEGRATION.md
parity_guard: "PORT APPROXIMATION / port-internal gates only. No donor GPU A/B frame exists. Nothing in this report certifies donor fidelity; donor parity remains UNVERIFIED (CHARTER.md:41,134-135)."
principle: "[O] observed file/line or filesystem read · [D] derived from observed code/arithmetic · [I] inferred with caveat · [U] UNVERIFIED. Every CLI below is PLANNED for COORD; V06 executed none of it."
---

# V06 — gate / capture remediation (exact plan, nothing executed)

## 0. Executive summary

- **[O] All green result JSONs are stale for today's tree.** On-disk mtimes are `selftest.json` 2026-11-25 15:28:20, `uitest.json` 15:36:51, `tests/results/t_render_mode.json` 15:37:37, `tests/results/t_map_variety.json` 10:40:11, `tests/results/t_terrain_only.json` 15:38:42; today is 2026-11-26. They read `passed=true` (`variant3d/selftest.json:2`, `variant3d/uitest.json:2`, `variant3d/tests/results/t_render_mode.json:65-69`, `variant3d/tests/results/t_map_variety.json:30-31`) but a green flag is not freshness (`L07_gate_log.md:84-86,137-138,152-154`). **Remediation: regenerate with five new unique-id runner jobs (§4.2); accept only mtime-after-START.**
- **[D] The mtimes are traceable, not fabricated.** `15:28:20 = ticket 591 START 15:23:59 + 260.97 s`, `15:36:51 ≈ ticket 592 START 15:29:46 + 426.41 s`, `15:37:37 ≈ ticket 593 START 15:37:27 + 10.78 s`, `15:38:42 ≈ ticket 594 START 15:38:17 + 26.04 s` (`L07_gate_log.md:131-166`; status.json `created`/`run` fields). They were fresh **on 2026-11-25**, stale today. `t_map_variety.json` provenance is **[U]** and must simply be regenerated.
- **[O] Eight `variant3d/tools` capture/scan scripts are byte-identical to their `app/tools` twins** (SHA-256 equality, two independent passes: `Get-FileHash` + `python hashlib`): `terrain3d_shot.py`, `heightmap3d_shot.py`, `full_map_shot.py`, `compare_shots.py`, `terrain_compare.py`, `terrain_sample_shot.py`, `terrain_land_shot.py`, `scan_map.py`. `assert_clean.py` and `godot_runner.py` differ and are variant-correct (`assert_clean.py:33-36`, `godot_runner.py:46-47`). **Remediation: explicit CLI overrides where the tool exposes them; variant3d-local copies for tools whose project/spool is hardcoded and cannot be overridden (§4.3).**
- **[O] Runner spool is settled: `counter=607`, `now_serving=607`, `pending_job_files=0`, `godot.lock` absent**, but `status.json` history has exactly **3 unacknowledged** leak-status entries: **575** `bbclamptidy01-parse` (`timed-out`), **582** `terrainswarm-g1-selftest` (`skipped`), **585** `g04-uitest` (`timed-out`). A bare `assert_clean.py --json` is therefore `DIRTY` (`assert_clean.py:40-42,154-188,199-218`). **Remediation: three COORD `ack --reason` calls with evidence-backed reasons, then a plain `assert_clean.py --json` — never `--ignore-history`, never deletion (§4.1).**
- **[O] No fresh 240²/320² baseline exists.** A09's proposed baselines are absent, `variant3d/shots` and `variant3d/scans` do not exist, no PNG newer than 2026-11-26 was found under `variant3d/` or the A09 temp folder. **Remediation: two windowed captures plus two same-seed dump pairs per size, frozen outside the repo (§4.4).**
- **[O] `terrain_ab_metric.py` is a SMOKE metric with no `--baseline` and no ARI.** CLI at `terrain_ab_metric.py:722-743`; label `:62,653`; A09's ARI is spec-only code at `A09_capture_plan.md:328-352` and no implementation file exists. **Remediation: candidate-vs-frozen-baseline at identical crop; donor-folder distribution as hints only; no "ARI pass" wording (§4.5).**
- **[I] No threshold is lowered, no assertion deleted, no result fabricated, no parity claimed.** This is a PORT APPROXIMATION remediation of evidence provenance only.

## 1. Scope and authority

V06 read files only. It launched **no** Godot process and called **no** runner subcommand (`CHARTER.md:80-82`; `P03_gates_capture.md:22,121`). It edited exactly one file: this report. Every `python ...` line below is a **PLANNED** command for COORD / the implementation owner; unique ids are reserved here and were confirmed absent from `status.json` history (`v06_ids=[]`, read-only second pass). Paths are repo-root relative, Windows `python`, PowerShell `;` (never `&&`) (`CHARTER.md:94`; `P03_gates_capture.md:63,117`).

## 2. Evidence table

| # | Label | Source (file:line / read-only command) | Establishes |
|---:|---|---|---|
| E01 | [O] | `docs/terrain_swarm_2026-11-26/CHARTER.md:26-31,46-64,66-85,121-135` | Donor-only read; `app/` byte-untouched; mandatory labels; gates 29/29, 17/17, `t_render_mode`, CLEAN; 240²/320²; one Godot at a time; no parity without donor GPU A/B |
| E02 | [O] | `SWARM_BOARD.md:28,42-53`; `P03_gates_capture.md:1-14` | V06 owns one report; COORD integrates; P03's inventory is predecessor evidence, not a verdict |
| E03 | [O] | `variant3d/selftest.json:2,12`; `variant3d/uitest.json:2,3`; `variant3d/tests/results/t_render_mode.json:64-69`; `variant3d/tests/results/t_map_variety.json:30-31`; `variant3d/tests/results/t_terrain_only.json` (filesystem read); read-only filesystem mtimes (pass 1 `Get-ChildItem`, pass 2 `python pathlib.stat`) | `passed=true` on all five; mtimes all 2026-11-25, stale on 2026-11-26 |
| E04 | [O] | `docs/terrain_swarm_2026-11-25/reports/L07_gate_log.md:84-86,131-154,158-166,202-212` | Freshness rule (mtime after START), exact selftest/uitest command forms with `--timeout 600`, and the 591–595 jobs that actually wrote four of the five JSONs |
| E05 | [O] | `variant3d/.godot_queue/counter` = 607, `now_serving` = 607, `jobs/` file count 0, `godot.lock` absent (two passes); `status.json` history = 500 | Settled spool; no live pending job; history still carries leaks |
| E06 | [O] | `status.json` leak-status computation, two independent passes (PowerShell `Group-Object` and `python` set filter): 41 leak-status entries, 38 `acknowledged`, **3 unacked**: 575/582/585; histogram `failed=152, ok=307, skipped=18, timed-out=23` | Exact unacked set; `failed` is deliberately excluded by `assert_clean.py:40-42` |
| E07 | [O] | `variant3d/.godot_queue/results/00000575.json`, `00000582.json`, `00000585.json` (all exist, read twice) | 575 exit −9/run 302.44 s/`timed-out`; 582 run 0.0/`skipped`, error `ticket 582 was skipped (serving=2581)`; 585 exit −9/run 308.54 s/`timed-out` |
| E08 | [O] | `variant3d/tools/assert_clean.py:3-18,33-42,154-188,199-218,262-288` | Only `--json`, `--max-lock-age`, `--ignore-history`; no ack flag; `--ignore-history` returns `enabled:false, total:null, failures:[]` and therefore hides reasons; ack is done by the runner |
| E09 | [O] | `variant3d/tools/godot_runner.py:46-54,586-611,619-647` | `ack <ticket> --reason <text>` requires an existing result JSON; writes `acknowledged`, `ack_reason`, `ack_at` to result **and** status history; spool is `variant3d/.godot_queue` |
| E10 | [O] | `docs/coord_swarm_2026-11-25/reports/B_B_CLAMP_TIDY.md:148-149`; `docs/terrain_swarm_2026-11-25/reports/G04_gate_log.md:66-87,157-165,183,197-211`; `docs/terrain_swarm_2026-11-25/reports/G12_runner_monitor.md:128-138` | Historical, non-fresh, non-parity provenance for 575/582/585; 582 is a terminal bookkeeping remnant, 585 was killed at 300 s with `SCRIPT ERROR 0` |
| E11 | [O] | `docs/coord_swarm_2026-11-25/reports/MAP240_APPLY_01.md:100-109,159-165`; `status.json` 567/568/569 all `ok`/exit 0 | Later green 29/29 and 17/17 jobs exist; they supersede the retired probes but do **not** make those probes green |
| E12 | [O] | SHA-256 equality, two passes (`Get-FileHash`, then `python hashlib`): 8 pairs identical, `assert_clean.py`/`godot_runner.py` different | Byte-identical tool set listed in §0; variant spool tools are correct |
| E13 | [O] | `variant3d/tools/terrain_sample_shot.py:36-40,63-69,145,209-216,333-341,431-440` | `RUNNER` resolves to variant runner but Godot argv hardcodes `--path app`; result lookup uses `ROOT/"app"/".godot_queue"`; outputs go to `variant3d/shots`; no project override |
| E14 | [O] | `variant3d/tools/terrain_land_shot.py:7,24-37,40-47,117-120` | Thin profile imports and mutates `terrain_sample_shot.py`; inherits its `app` aperture; only scan/capture/seed/validate flags |
| E15 | [O] | `variant3d/tools/full_map_shot.py:87-94,117-127,133-147,173,470-486,504` | Compositor blocks resolve under `variant3d`; `--gen-dump` hardcodes `--path app`; result lookup hardcodes `app/.godot_queue`; no `--project` flag |
| E16 | [O] | `variant3d/tools/heightmap3d_shot.py:36-48,128-141,170-181`; `terrain3d_shot.py:24-30,94-121`; `terrain_compare.py:42-56,306-328`; `compare_shots.py:133-141`; `scan_map.py:2-5,448` | Per-tool hardcoded paths and the exact override surface available (§4.3) |
| E17 | [O] | `variant3d/tools/terrain_ab_metric.py:22-33,52,62-63,722-743`; no `ARI` or `--baseline` token anywhere in the file; `A09_capture_plan.md:103-108,328-352` | SMOKE-only tool; `--compare-ref` distribution and one-reference modes only; ARI is an unimplemented proposal |
| E18 | [O] | `variant3d/config.json:70,74-77`; `variant3d/scripts/main.gd:3-5,27-31,1262-1367`; `variant3d/tests/manifest.json:139-144,244-258` | Shipped size is 240²/seed 20261113; `--config`/`--seed`/`--dump-map`/`--screenshot` flags; headless screenshot is an 800×600 CPU fallback; test timeouts |
| E19 | [O] | Read-only listings: `variant3d/shots` absent, `variant3d/scans` absent, `%TEMP%\opencode\p03`/`a09` absent, A09 baseline PNGs absent, `terrain_repetition_metrics.py` absent, `terrain_qa_harness.py` absent, zero PNGs under `variant3d/` with today's mtime | No fresh 240²/320² baseline; planned harness/ARI tools not built |
| E20 | [O] | `git status --short`: no `app/` entry (all changes are docs/ reports/spec) at read time | `app/` drift not introduced by V06; COORD must re-hash at G0/G5 (`spec/12_QA_AND_INTEGRATION.md:42-46`) |

`[I]` appears only where explicitly marked. `[U]` items are collected in §6.

## 3. Multiple-pass reconciliation of contradictory status claims

Owner directive (`CHARTER.md:85-93`): re-read contradictory states with a second instrument before declaring them. V06 did so for every contested claim.

| Claim | Pass 1 | Pass 2 (different instrument) | Accepted reading |
|---|---|---|---|
| "All green gate JSONs" | `Get-Content ... | Select-String '"passed": true'` → green on all five | `Get-ChildItem` mtimes, then independent `python pathlib.stat` mtimes → all 2026-11-25 | [O] Green **but stale**; no gate may be claimed on today's tree |
| "Stale = fabricated?" | mtime arithmetic vs L07 logs | Status history `created`/`run` for tickets 591–595 | [D] Four JSONs were written by **ok** L07 jobs on 2026-11-25; stale, not fake. `t_map_variety` source **[U]** |
| "Spool 607/607, pending 0, lock free" | `Get-Content counter/now_serving`, `Test-Path godot.lock`, `jobs/` count | `python` read of `status.json` + result-JSON existence check | [O] Both agree; settled spool, no re-submit needed |
| "3 unacked failures" | PowerShell `Group-Object status` + literal unacked filter | `python` set filter `{timed-out,error,skipped}` minus `acknowledged` | [O] Both return exactly 575/582/585; 41 leak-status entries, 38 already acked |
| "582 serving=2581 contradicts counter=607" | Result JSON error string `serving=2581` | `G12_runner_monitor.md:79,128-138` documents an old ticket band and calls it a bogus skip; `G04_gate_log.md:157-165` records COORD clearing the stale job | [O]/[D] Historical error string from an earlier spool generation; not a live desync. Cause of the `2581` value itself **[U]** |
| "Tools are byte-identical" | `Get-FileHash app/tools vs variant3d/tools` | `python hashlib.sha256` on the same 10 pairs | [O] 8 identical, 2 different — no contradiction |
| "No fresh baseline" | `Test-Path` on A09 baseline paths | Recursive `%TEMP%\opencode` + `variant3d/` file-date scan | [O] None exists |

**Resolution rule applied:** where the two passes disagreed or the source was older than today's tree, the claim was demoted to stale/**[U]** and scheduled for regeneration; it was never promoted to a PASS.

## 4. Remediation steps — exact CLI (PLANNED; COORD executes)

Let `<T>` = `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v06` (new, outside the repo). Godot-facing paths use forward slashes because the repo path contains a space (`G12_runner_monitor.md:79`; `P03_gates_capture.md:145`).

### 4.1 Step 0 — acknowledge the three historical failures WITH reasons, then assert CLEAN

`assert_clean.py` has **no** ack flag (`assert_clean.py:262-272`); the only legitimate acknowledgement is the runner's own `ack` command, which writes `acknowledged`, `ack_reason`, `ack_at` to both the result JSON and status history (`godot_runner.py:586-611,644-647`). All three result JSONs exist, so `ack` will not return 2. **Do not** use `reset`, `cancel`, `doctor`, result-file deletion, status.json hand-editing, or `--ignore-history`: the latter sets `enabled:false, total:null, failures:[]` (`assert_clean.py:154-156`), i.e. suppresses the reasons instead of recording them.

```powershell
# --- COORD ONLY. PLANNED. Reasons are evidence-backed, not "passed" claims. ---
python variant3d\tools\godot_runner.py ack 575 --reason "COORD policy ack 2026-11-26: diagnostic-only --check-only game.gd parse probe timed out at 300s (exit -9, run 302.44s, SCRIPT ERROR 0; B_B_CLAMP_TIDY.md:148-149). Owner retired the probe without re-submit. This records retirement, NOT a passing gate and NOT a parse proof; fresh gates are re-run in 4.2."
python variant3d\tools\godot_runner.py ack 582 --reason "COORD policy ack 2026-11-26: terminal skipped bookkeeping remnant, run=0.0, bogus error serving=2581 (G12_runner_monitor.md:128-138; G04_gate_log.md:157-165); no Godot ran and COORD cleared the stale job file. Superseded by ok jobs 568/569 (MAP240_APPLY_01.md:100-109). Records retirement only, NOT a green selftest run."
python variant3d\tools\godot_runner.py ack 585 --reason "COORD policy ack 2026-11-26: g04-uitest hung in setup and was killed at 300s (exit -9, SCRIPT ERROR 0; G04_gate_log.md:183,197-211); follow-up 587 hit the 120s watchdog and the on-disk 17/17 predated both runs, so no fresh PASS was claimed. Superseded by ok job 569 at 240x240 (MAP240_APPLY_01.md:101,108-109). Records retirement, NOT a green uitest."

# --- verify with the plain gate: no --ignore-history ---
python variant3d\tools\godot_runner.py status
python variant3d\tools\assert_clean.py --json
```

Accept only: `verdict=CLEAN`, exit 0, `reasons=[]`, `checks.processes.count=0`, `checks.lock.state=free` (or `held_recent` with a live job), `checks.history.enabled=true`, `checks.history.total=500`, `checks.history.acknowledged>=3`, `checks.history.failures=[]` (`assert_clean.py:182-218`). **STOP** if any item is unmet. If a fourth leak appears later, ack it with its own reason or leave CLEAN explicitly unclaimed — never widen the failure set or delete an entry.

### 4.2 Step 1 — regenerate every stale green JSON with a new unique id

One job at a time; `godot_runner.py status` after each result; never re-submit a pending job (`P03_gates_capture.md:117-121`). Runner `--timeout` must exceed the in-game watchdog; `--timeout 600` after the second `--` is an operational flag, not a test change (`L07_gate_log.md:84-86,119-123`).

```powershell
# --- selftest 29/29 -> variant3d/selftest.json ---
python variant3d\tools\godot_runner.py run --id v06-selftest-20261126 --timeout 700 -- --headless --path variant3d -- --self-test variant3d/selftest.json --timeout 600
python variant3d\tools\godot_runner.py status

# --- uitest 17/17 -> variant3d/uitest.json ---
python variant3d\tools\godot_runner.py run --id v06-uitest-20261126 --timeout 700 -- --headless --path variant3d -- --ui-test variant3d/uitest.json --timeout 600
python variant3d\tools\godot_runner.py status

# --- t_render_mode PASS / seam_missing=false -> tests/results/t_render_mode.json ---
python variant3d\tools\godot_runner.py run --id v06-rendermode-20261126 --timeout 180 -- --headless --path variant3d --script res://tests/t_render_mode.gd
python variant3d\tools\godot_runner.py status

# --- t_map_variety 5/5 -> tests/results/t_map_variety.json ---
python variant3d\tools\godot_runner.py run --id v06-mapvariety-20261126 --timeout 180 -- --headless --path variant3d --script res://tests/t_map_variety.gd
python variant3d\tools\godot_runner.py status

# --- OPTIONAL / NON-GATE diagnostic (manifest status=pending, windowed): t_terrain_only.json ---
python variant3d\tools\godot_runner.py run --id v06-terrainonly-20261126 --timeout 300 -- --path variant3d --script res://tests/t_terrain_only.gd -- --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v06/v06_terrain_only.png" --png "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v06/v06_terrain_only.png" --timeout 600
python variant3d\tools\godot_runner.py status

# --- integrity of every job's stderr (substitute the real 8-digit tickets from status) ---
python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\<ticket>_v06-selftest-20261126\stderr.txt variant3d\.godot_queue\results\<ticket>_v06-uitest-20261126\stderr.txt
python variant3d\tools\assert_clean.py --json
```

Acceptance per JSON: result `status=ok`, `exit=0`, `passed=true`, step counts 29/29, 17/17, 10/10, 5/5, `result=PASS`, `seam_missing=false` where applicable, `script_error_lines=0`, and **mtime strictly after that job's START** (`E04`; `P03_gates_capture.md:68-72`). The optional `t_terrain_only` row is a diagnostic only (`manifest.json:252-258`); it must not be reported as an acceptance gate. No threshold is changed.

### 4.3 Step 2 — capture-tool apertures: explicit overrides vs variant3d-local copy

"Byte-identical" means invoking the `variant3d/tools` copy does **not** change its `app/` defaults. `TOOLS = Path(__file__).resolve().parent` makes `RUNNER` point at the *variant* runner in some tools while the Godot argv still says `--path app` — a mixed aperture (`E13`, `E15`; `P03_gates_capture.md:93`).

| Tool (byte-identical?) | Hardcoded path evidence (file:line) | Override surface that exists | Legitimate remediation |
|---|---|---|---|
| `terrain3d_shot.py` (identical) | `DEFAULT_SHOT/DEFAULT_STATS` `ROOT/"app"/"shots"` `:25-26`; `M05_SHOT`, `M0_SHOT`, `TWO_D` `:27-30`; seammask `:120` | only `--shot` `:96` | **Variant3d-local copy** if used at all; `--shot` alone cannot retarget the comparison set. Legacy M0/M0.6 art instrument, not a fresh 240²/320² gate |
| `heightmap3d_shot.py` (identical) | `RUNNER=ROOT/"app"/"tools"/godot_runner.py` `:37`; `SHOTS=ROOT/"app"/"shots"` `:38`; `SANDBOX_GD/SCENE` `:42,45`; `cmd += ["--path","app",...]` `:132,141` | `--shot`, `--json`, `--submit`, `--id`, `--timeout`, `--no-headless`, `--donor` `:172-181` — **no** project/runner/sandbox flag | **Variant3d-local copy** with `--project`/`--runner`/`--sandbox` overrides before any `--submit`. Verify-only mode is headless Pillow and reads legacy `app/shots` only |
| `full_map_shot.py` (identical) | `SHOTS=APP/"shots"`, `BLOCKS=APP/"assets/terrain/blocks"` `:91-92`; `--gen-dump` argv `--path app` `:140`; result lookup `ROOT/"app"/".godot_queue"` `:173`; doc `:36,44,124` | `--dump`, `--config`, `--out`, `--tile-px`, `--crosscheck-png`, `--game-timeout`, `--runner-timeout`, `--gen-dump` `:470-486` | Compositor: **explicit `--dump <abs>` and `--out <abs>` only**; do **not** use `--gen-dump` (boots `app`). If `--gen-dump` is required, **variant3d-local copy** changing `:140` to `--path variant3d` and `:173` to `variant3d/.godot_queue`. Diagnostic compositor, not the in-game renderer (`:117-127`) |
| `terrain_sample_shot.py` (identical) | `RUNNER=TOOLS/godot_runner.py` `:39` (variant), `SHOTS=APP/"shots"` `:40`, `CONFIG_PATH` `:63-69`, result `ROOT/"app"/".godot_queue"` `:145`, Godot argv `--path app` `:211,335` | only `--scan-seeds`, `--capture`, `--seed`, `--validate-only` `:431-440` | **Variant3d-local copy** adding `--project`, `--config`, `--spool`, `--out-dir`; `--capture` must not be run until repaired. Until then bypass with direct runner jobs from §4.4 |
| `terrain_land_shot.py` (identical) | imports base module by path `:24-27`, rewrites artefact names `:30-37`; inherits every `app` path and Godot argv from base | only `--scan`, `--capture`, `--seed`, `--validate-only` `:117-120` | **Variant3d-local copy** that also overrides `base.APP/SHOTS/CONFIG_PATH` and the Godot argv builders; fixing artefacts alone is insufficient |
| `terrain3d_shot.py` / `heightmap3d_shot.py` comparisons | donor JPG defaults `:29`, `:181` | `--donor` only on heightmap tool | Pass explicit donor paths or mark comparisons `UNVERIFIED`; never call them parity |
| `compare_shots.py` (identical) | no project aperture; doc example `app/tools` `:10` | `--shot`, `--ref`, `--crop`, `--threshold`, `--json` `:135-141` | **CLI overrides suffice**: pass both absolute PNGs and `--threshold 0.9999`. Default 0.80 is a smoke placeholder (`compare_shots.py:15-18`), same-scene determinism only |
| `terrain_compare.py` (identical) | `SHOTS=APP/"shots"`, `DEFAULT_SHOT/DEFAULT_OUT` `:42-52`, doc `:25-29` | `--shot`, `--ref`, `--water-ref`, `--out`, `--no-water`, `--seed` `:309-317` | **CLI overrides suffice**: pass all PNG paths explicitly; SMOKE label `:54-56` must stay attached |
| `scan_map.py` (identical) | docstring only: `app/tools/scan_map.py --dir scans` `:4` | `--dir` `:448` | **CLI override suffices**: dedicated `--dir` with only fresh dumps; no Godot, no project aperture |
| `smallmap_capture.py`, `terrain_ab_metric.py` (variant-only) | none | stats/scan-stderr; candidate/reference/crop flags | Use as-is with explicit absolute inputs |
| `assert_clean.py`, `godot_runner.py` (different) | variant spool `assert_clean.py:33-36`, `godot_runner.py:46-47` | as documented | Use as-is; no copy needed |

Recommendation [I]: prefer **direct runner commands (§4.4)** for the first fresh baseline; repair tools only where a named worker owns the file, with COORD approval. V06 changes no tool.

### 4.4 Step 3 — establish the FIRST fresh 240² / 320² baseline

```powershell
New-Item -ItemType Directory -Force -Path "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v06\dumps" | Out-Null
'{"gameplay":{"render_mode":"3d","random_seed":20261113,"map_width_tiles":240,"map_height_tiles":240}}' | Out-File -FilePath "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v06\map_240.json" -Encoding ascii -NoNewline
'{"gameplay":{"render_mode":"3d","random_seed":20261113,"map_width_tiles":320,"map_height_tiles":320}}' | Out-File -FilePath "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v06\map_320.json" -Encoding ascii -NoNewline
```

`--config` is parsed/merged at `main.gd:1338-1341` and `--seed` applied after merge (`main.gd:1356-1363`); never call the shipped 240² config a 320² capture (`config.json:74-77`; `P03_gates_capture.md:164`).

```bat
python variant3d\tools\godot_runner.py run --id v06-baseline-240 --timeout 700 --max-wait 3600 -- --path variant3d -- --config "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v06/map_240.json" --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v06/fresh_240.png" --screenshot-frames 10 --seed 20261113 --timeout 600
python variant3d\tools\godot_runner.py status
python variant3d\tools\smallmap_capture.py stats "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v06/fresh_240.png"
python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\<ticket240>_v06-baseline-240\stderr.txt

python variant3d\tools\godot_runner.py run --id v06-baseline-320 --timeout 700 --max-wait 3600 -- --path variant3d -- --config "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v06/map_320.json" --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v06/fresh_320.png" --screenshot-frames 10 --seed 20261113 --timeout 600
python variant3d\tools\godot_runner.py status
python variant3d\tools\smallmap_capture.py stats "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v06/fresh_320.png"
python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\<ticket320>_v06-baseline-320\stderr.txt
```

Rules: **no `--headless`** (it writes the 800×600 CPU fallback, `main.gd:3-5`; `terrain_sample_shot.py:21-23,78-81`); `--screenshot-frames 10` selects the real viewport path; `--timeout 600` after the second `--` overrides the 120 s watchdog (`main.gd:31,1334-1336`); never combine with `--dump-config` (`L07_gate_log.md:180-198`). Require 1280×720, non-blank, `full_width_dark_rows=0`, `script_error_lines=0`, and record the stdout capture diag (`camera_current=true`, `world_parent=Screenshot3DViewport`, plausible camera position/target) before accepting a frame (`G21:52-58`; `G04:247-251`). If the blank detector rejects a valid frame, inspect `<name>.png.raw.png` and record an instrument defect — do not edit the detector (`P03_gates_capture.md:177`).

Freeze **outside** the repo (immutable names; record SHA-256 of PNGs, overlays and config; record seed/size/camera keys and ticket ids):

```powershell
Copy-Item "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v06\fresh_240.png" "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v06\fresh_240_baseline.png"
Copy-Item "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v06\fresh_320.png" "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v06\fresh_320_baseline.png"
Get-FileHash "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v06\fresh_240_baseline.png","C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v06\fresh_320_baseline.png","C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v06\map_240.json","C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v06\map_320.json" -Algorithm SHA256
```

Determinism / structure lane (two runs per size, one job at a time; dedicated dump directory because `scan_map.py` scans every JSON with `map_w`/`terrain` in `--dir`, `scan_map.py:451-463`):

```bat
python variant3d\tools\godot_runner.py run --id v06-dump-240-a --timeout 700 --max-wait 3600 -- --headless --path variant3d -- --seed 20261113 --config "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v06/map_240.json" --dump-map "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v06/dumps/v06_240_a.json" --timeout 600
python variant3d\tools\godot_runner.py status
python variant3d\tools\godot_runner.py run --id v06-dump-240-b --timeout 700 --max-wait 3600 -- --headless --path variant3d -- --seed 20261113 --config "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v06/map_240.json" --dump-map "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v06/dumps/v06_240_b.json" --timeout 600
python variant3d\tools\godot_runner.py status
python variant3d\tools\godot_runner.py run --id v06-dump-320-a --timeout 700 --max-wait 3600 -- --headless --path variant3d -- --seed 20261113 --config "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v06/map_320.json" --dump-map "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v06/dumps/v06_320_a.json" --timeout 600
python variant3d\tools\godot_runner.py status
python variant3d\tools\godot_runner.py run --id v06-dump-320-b --timeout 700 --max-wait 3600 -- --headless --path variant3d -- --seed 20261113 --config "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v06/map_320.json" --dump-map "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v06/dumps/v06_320_b.json" --timeout 600
python variant3d\tools\godot_runner.py status
python variant3d\tools\scan_map.py --dir "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v06/dumps"
python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\<ticket>_v06-dump-320-b\stderr.txt
python variant3d\tools\assert_clean.py --json
```

Whole-file SHA-256 equality of each `(a,b)` dump pair is a legitimate **port-internal** determinism check **[D]**; the five-stream canonical fingerprint from A05 (`A05_qa_harness.md:111-128`) is **not yet runnable** because `terrain_qa_harness.py` does not exist (E19) — record it as **[U]**, do not claim D1 conformance until the tool lands. `scan_map.py` ALL GREEN / exit 0 is required (`scan_map.py:467-510`); never relax a gate at `:478-493`. Order: determinism → structure → visual → final regression (`A05_qa_harness.md:207-223`).

### 4.5 Step 4 — what the metric may and may not say

```powershell
# Like-with-like, identical crop on BOTH sides (PORT APPROXIMATION, SMOKE)
python variant3d\tools\terrain_ab_metric.py "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v06/candidate_320.png" "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v06/fresh_320_baseline.png" --crop 120,60,1040,580 --json

# Third-party donor-still distribution — direction hints only, parity UNVERIFIED
python variant3d\tools\terrain_ab_metric.py "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v06/candidate_320.png" --compare-ref "C:\Users\Maxym.Oboyshev\Downloads\c3" --crop-frac .35,.55,.48,.70 --json --per-file

# Same-scene / same-camera reproducibility ONLY; never donor parity
python variant3d\tools\compare_shots.py --shot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v06/candidate_320.png" --ref "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v06/candidate_320_repeat.png" --threshold 0.9999 --json
```

`--crop 120,60,1040,580` is the previously used ground box (`L05_feature_integration.md:98`); `--crop-frac .35,.55,.48,.70` is A11 ref-A's ground ROI (`C01:89-92`). The tool's own label is `SMOKE METRIC - heuristic only, NOT a fidelity gate or donor proof` (`terrain_ab_metric.py:62,653`); its CLI has `candidate`, optional `reference`, `--compare-ref`, `--json`, `--crop`, `--crop-frac`, `--blocks`, `--lags`, `--per-file` and nothing else (`:722-743`). A09's ARI formula (`:328-352`) is unimplemented. **Do not report an "ARI pass", an "A/B gate pass", or donor parity**; the honest verdict wording remains "gates green / internal consistency PASS / donor parity UNVERIFIED" (`A05_qa_harness.md:357-358`; `spec/12_QA_AND_INTEGRATION.md:29,42-46`).

## 5. Risks

1. **[O] Mixed aperture** — variant-local copies of byte-identical tools submit through the variant runner but boot `app/` and/or read `app/.godot_queue` (`E13-E15`). A default-argument "fresh capture" may be a 2D `app` frame. Mitigation: §4.3 + verify config/camera diag; never infer aperture from the script's location.
2. **[O] Stale-green JSON** — `passed=true` is not evidence of today's tree (`E03/E04`). Mitigation: mtime-after-START plus result-envelope and `scan-stderr`.
3. **[O] Watchdog vs runner timeout** — without `--timeout 600` after the second `--`, selftest/uitest force-exit near 120 s (`L07_gate_log.md:84-86,119-123`). Runner timeout must be strictly larger.
4. **[O] CLEAN cannot be obtained by suppression** — `--ignore-history` disables the history check and erases the reasons from the report (`assert_clean.py:154-156`). Ack with reasons (§4.1) or leave CLEAN unclaimed. `failed` is outside the leak set (`assert_clean.py:40-42`), so a wall of historical `failed` rows is not itself a CLEAN blocker — and must not be silently reclassified.
5. **[U] 582's `serving=2581` string** — historical spool-generation artifact, not a live desync (§3). If a future status shows `now_serving != counter`, stop; do not `unwedge` speculatively.
6. **[O] Size confusion** — shipped config is 240² (`config.json:75-76`) while A09/legacy prose says 320². Pin both overlays; label every artifact by its actual size.
7. **[O] Capture-integrity traps** — `--dump-config` exits before `--screenshot`; runner exit 0 is not a PNG; headless fallback is 800×600; blank-detector false rejection has a `.raw.png` sidecar (`P03_gates_capture.md:243`).
8. **[O] Queue contention** — 100–400 s FIFO waits are normal; re-submission creates duplicate tickets (`AGENT_PROTOCOL.md:39-49`). Spool is settled now (607/607), so no cleanup should be needed.
9. **[D] Huge compositor PNGs** — 320² at `tile_px=64` is 20 480²; `full_map_shot.py` halves tile size on memory error and renames output (`:540-567`). Verify the sidecar before any image comparison.
10. **[O]/[U] Harness gap** — `terrain_qa_harness.py` and `terrain_repetition_metrics.py` are absent (E19); A05's five-stream fingerprint and A09's ARI cannot be claimed. Use whole-file dump hashes as a provisional **[D]** check only.
11. **[O] `app/` drift** — must remain byte-identical (`CHARTER.md:26-31`; `spec/12_QA_AND_INTEGRATION.md:42-46`). V06 saw no `app/` diff (E20); COORD must re-verify at G0/G5.

## 6. UNVERIFIED register

| Item | Status | Why / owner |
|---|---|---|
| Fresh 29/29, 17/17, `t_render_mode` 10/10, `t_map_variety` 5/5, CLEAN for the 2026-11-26 tree | **UNVERIFIED — stale JSONs only** | V06 ran no job; §4.1–4.2 are plans for COORD |
| Provenance of `t_map_variety.json` (unix_ms 1795599611871 = 2026-11-25 10:40:11) | **[U]** | No matching *ok* ticket identified in two passes; regenerate, do not repair history |
| Fresh 240² / 320² windowed baseline and frozen copies | **UNVERIFIED — do not exist** | §4.4; COORD |
| Five-stream byte-identical dump fingerprints (A05 D1) | **UNVERIFIED — tool absent** | `terrain_qa_harness.py` missing (E19); provisional whole-file SHA only |
| A09 ARI implementation / "ARI gate" | **UNVERIFIED — not implemented** | `terrain_ab_metric.py:722-743`; spec-only `A09_capture_plan.md:328-352` |
| Whether repaired `terrain_sample_shot.py --capture` / `terrain_land_shot.py --capture` work against variant3d | **UNVERIFIED** | Both hardcode `--path app`; V06 ran nothing |
| Usefulness of `terrain3d_shot.py` / `heightmap3d_shot.py` for the fresh module | **UNVERIFIED / probably not** | Legacy M0/M0.6 and G3-2 app sandbox targets (`E16`) |
| Exact origin of the `serving=2581` value in ticket 582's error | **[U]** | Documented as bogus skip/bookkeeping (`G12:79,128-138`); old spool generation inferred, not proven |
| Donor still build/camera/crop and all donor range bands | **UNVERIFIED** | Third-party JPEGs, unknown build (`A05:162-166`, `A09:437-441`) |
| Any donor-parity statement | **UNVERIFIED — no claim made** | No donor GPU A/B frame (`CHARTER.md:41,134-135`) |
| `variant3d/shots`, `variant3d/scans` contents | **UNVERIFIED — directories absent at read time** | E19; tools create parents on demand |
| Full dump `meta` generation-key contract of the fresh module | **UNVERIFIED** | `A05:390`; D/A tickets own it |

## 7. Open questions

1. **Q1 (COORD):** Accept the three evidence-backed `ack --reason` strings verbatim (§4.1), or amend the wording while keeping the evidence citations? V06 proposes no deletion and no `--ignore-history`.
2. **Q2 (COORD / implementation owner):** Repair the five mixed-aperture tools with `--project`/`--spool` flags, or bypass them permanently with the direct runner commands in §4.4? One owner per file (`spec/12_QA_AND_INTEGRATION.md:16-22`).
3. **Q3 (COORD):** Which size is canonical — shipped 240² (`config.json:75-76`) or spec-level 320²? V06 pins both explicitly and assigns no priority.
4. **Q4 (A05/COORD):** Who builds `terrain_qa_harness.py` and freezes the immutable baseline PNGs / SHA manifest? A05's tool is a design only (`A05_qa_harness.md:297-339`).
5. **Q5 (D02/A02):** Are 240² and 320² expected to share an RNG stream shape, or is cross-size comparison advisory only? A05's D2 is deliberately advisory (`A05:135`).
6. **Q6 (A06/QA desk):** Who performs the independent second-agent visual read R1–R6 and records the required reviewer sentence (`A05:203-205`)?
7. **Q7 (COORD):** At what evidence threshold may any structural `--policy` flip to `red` — signed donor spec alone, or spec plus one real donor GPU frame (`A05:352-354`)?

## 8. Honesty / scope statement

Exactly one file was written: this report. No `.gd`, shader, config, fixture, tool, result JSON, PNG, `app/` file or git state was edited; no donor binary was copied or executed; **no Godot process was launched and no runner subcommand (including `run`, `status`, `ack`, `cancel`, `reset`, `doctor`, `unwedge`) was executed**. Every value came from read-only file reads, hashes, listings and arithmetic, with a second pass on each contested claim (§3). Every CLI is a **PLANNED** instruction for COORD. No threshold was lowered, no assertion deleted, no green result fabricated, and no donor-parity claim made. **PORT APPROXIMATION / port-internal consistency only; donor parity remains UNVERIFIED.**

## 9. Five-line summary

1. [O] Five green result JSONs are stale on 2026-11-26; four are traceable to ok L07 jobs on 2026-11-25, `t_map_variety` provenance is [U] — regenerate all with unique `v06-*` runner ids.
2. [O] Eight `variant3d/tools` scripts are byte-identical `app/tools` copies with hardcoded `app/` paths; use explicit overrides where exposed, variant3d-local copies for `terrain_sample_shot.py`, `terrain_land_shot.py`, `heightmap3d_shot.py`, `terrain3d_shot.py` and `full_map_shot.py --gen-dump`.
3. [O] Spool is settled at 607/607, pending 0, lock free, but 575/582/585 are unacked leaks: ack each with an evidence-backed `--reason`, then run plain `assert_clean.py --json` — never `--ignore-history`.
4. [O] No fresh 240²/320² baseline exists; freeze two windowed captures plus two same-seed dump pairs per size via one-at-a-time runner jobs with absolute overlays.
5. [O] `terrain_ab_metric.py` is SMOKE-only with no `--baseline`/ARI; like-with-like crops and donor-folder distribution are hints only — donor parity stays UNVERIFIED.

*End of V06 gate remediation plan. Planned only; no runner job, no edit, no parity claim.*
