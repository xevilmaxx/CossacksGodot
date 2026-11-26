---
id: V42
swarm: TERRAIN-SWARM-2026-11-26
title: "V42 — exact copy-paste gate/capture command packet for COORD, after all implementation workers report"
agent: "V42 (verification subagent; one-report-only, read-only planning)"
owner_file: docs/terrain_swarm_2026-11-26/reports/V42_gate_commands.md
status: PLANNED_ONLY__NO_RUNNER_JOB__NO_GATE_RESULT__NO_PARITY_CLAIM
created: 2026-11-26
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_guard: "PORT APPROXIMATION / port-internal consistency only. No donor GPU A/B frame exists (CHARTER.md:41,134-135; V21 GR-C08). No command in this packet produces or certifies donor fidelity."
principle: "[O] literal file:line or read-only filesystem read · [D] deterministic consequence of cited source/flags · [I] recommendation with caveat · [U] unresolved. V42 executed ZERO runner subcommands and ZERO Godot processes; nothing below is a gate result."
governing_sources:
  - docs/terrain_swarm_2026-11-26/CHARTER.md
  - docs/terrain_swarm_2026-11-26/SWARM_BOARD.md
  - docs/terrain_swarm_2026-11-26/IMPLEMENTATION_PLAN.md
  - docs/terrain_swarm_2026-11-26/reports/V06_gate_remediation.md
  - docs/terrain_swarm_2026-11-26/reports/V21_gate_register.md
  - docs/terrain_swarm_2026-11-26/reports/P03_gates_capture.md
  - docs/terrain_swarm_2026-11-26/spec/12_QA_AND_INTEGRATION.md
  - variant3d/tools/AGENT_PROTOCOL.md
  - variant3d/tools/godot_runner.py
landing_check: "V36_integration_checklist.md was NOT landed at write time (read-only glob returned no V36*; only V37_minor_conflicts.md exists). Commands are built from landed sources only. No data from a donor GPU A/B frame is used — none exists."
---

# V42 — exact gate/capture command packet (COORD runs; V42 ran nothing)

> **Verified 2026-11-26 (V94 path-correction pass; read-only `Test-Path`, no gate run, no runner subcommand, no Godot, no parity claim).** Two non-resolving paths from V76 B1 were corrected to their on-disk canonical forms; the 28 unique `v42-` ids, the `ack 575/582/585 --reason` syntax, all flags and the rollback commands are unchanged.
> 1. **Shader (A′-3 §4.5 and 4 other mentions):** `variant3d\shaders\terrain_donor.gdshader` (`Test-Path` FALSE) → canonical **`variant3d\shaders\terrain_donor_shader.gdshader`** (`Test-Path` TRUE), including the §4.6 rollback `Remove-Item` list. The two intentionally-absent optional `res://scripts/terrain_donor_shader.gdshader` references (t_terrain_donor.gd:43) are deliberately left unchanged — no parse job added for them.
> 2. **Spec (A′-2 §4.4):** `variant3d\spec\terrain_qa_spec.json` (tool copy absent, `Test-Path` FALSE) → **`docs\terrain_swarm_2026-11-26\spec\terrain_qa_spec.json`** (`Test-Path` TRUE). Per V73 `spec/README.md:38` this file is **SCHEMA-ONLY / UNPOPULATED** — treat it as advisory evidence only, never as a passing gate; no threshold or class-B band is promoted.
> Every other packet path was re-checked with read-only `Test-Path` and resolves. This is a documentation correction only: no gate result asserted, no donor-parity claim.

## 0. Executive summary

1. **[O] Every flag below was re-read from the tool source, not copied from prose.** `godot_runner.py` exposes `run/status/doctor/reset/cancel/unwedge/ack` with `run --id` (required), `run --timeout` (default 120.0), `run --max-wait` (default 3600.0) and `argparse.REMAINDER` Godot args (`godot_runner.py:615-652`); `assert_clean.py` exposes only `--json`, `--max-lock-age`, `--ignore-history` (`assert_clean.py:262-272`). No invented flag appears.
2. **[O] The ACK syntax is `ack <ticket> --reason "<text>"`** — ticket is a positional `int`, `--reason` is required, and a result JSON must already exist (`godot_runner.py:644-647,586-612`). `ack` has **no** `--id` and **no** `--ignore-history`; the latter is an `assert_clean.py` flag that suppresses the failure set (`assert_clean.py:154-156,270-271`) and is forbidden here. `00000575.json`, `00000582.json`, `00000585.json` all exist and all three remain unacked in `status.json` as of this read (read-only file reads).
3. **[O] The runner/spool shape is unchanged:** spool `variant3d/.godot_queue` (`godot_runner.py:46-53`), `counter=607`, `now_serving=607`, `jobs/` count 0, `godot.lock` absent (read-only `Get-Content`-equivalent + `pathlib` pass). `status.json` history = 500 with exactly 575/582/585 unacked. Hence a bare `assert_clean.py --json` is `DIRTY` until the three evidence-backed acks land.
4. **[D] The packet follows V21 order exactly:** A′-0 → A′-1 → A′-2 → A′-3 → D-0 → D-1 → D-2 → D-3 → D-4 → D-5 → D-6 (`V21_gate_register.md:154-181`). Gates are placed at their V21 stations: `selftest`/`uitest` at D-5, `t_render_mode`/`t_terrain_donor`/`t_map_variety` at D-3, `scan_map.py` at D-2, `assert_clean` at A′-0/D-0/D-5.
5. **[O] The fresh tree is further along than the predecessor reports assumed:** the seam is already applied (`main.gd:125,189-190,593-594,1112-1113`; `world3d.gd:144,220-224,624`), new modules and `t_terrain_donor.gd` exist, `terrain_qa_harness.py`/`terrain_qa_spec.json`/`X13_blend_test_vectors.md`/`V17_spec_readiness.md` have landed, `bak-COORD-I11` backups exist, and the shader is at **`variant3d/shaders/terrain_donor_shader.gdshader`** (not the planned `scripts/terrain_donor_shader.gdshader`). The packet is keyed to these **actual** paths.
6. **[U] No gate result, no runner job, no parity claim.** V42 submitted no runner subcommand (not even `status`), launched no Godot, edited no file except this report. All 64²/240²/320² results, determinism, CLEAN and visual acceptability remain UNVERIFIED until COORD executes the packet.

## 1. Scope, authority and verification method

- Read-only. The only file written is this report. The runner was **not** invoked; spool state was obtained from direct file reads (`variant3d/.godot_queue/counter`, `now_serving`, `status.json`, `results/`, `jobs/`, `godot.lock`) — a read-only instrument, not a runner subcommand.
- Windows/PowerShell, `python`, `;` (never `&&`), repo-root relative, quoted paths with spaces (`CHARTER.md:94`; `P03_gates_capture.md:63`). Godot-facing paths use forward slashes (`V06_gate_remediation.md:81`).
- **Unique-id rule:** only the `run` subparser declares `--id` (`godot_runner.py:619-624`). `status` (`:626-627`), `ack` (`:644-647`) and every non-runner tool take **no** `--id`. Therefore every `run` command below carries a fresh `v42-` id; no id is invented for `status`, `ack`, `assert_clean.py`, `scan_map.py`, `smallmap_capture.py`, `py_compile`, `git` or `Get-FileHash`.
- **Multiple passes on anomalies** (`CHARTER.md:85-93`): flag surfaces were read twice (source `add_parser`/`add_argument` + the governing reports); the 240²-vs-320² "shipped size" contradiction was re-read in `config.json:74-77` (240²) and `variant3d/tests/fixtures/small_map_64.json:6` (claims 320²) — both literals exist, so **all three overlays are pinned explicitly** and every artifact is labelled by its actual size (`V21 MP7:149`).
- The missing V36 checklist was re-globbed twice (`V3*` returned only `V37_minor_conflicts.md`); no V36 content is assumed.

## 2. Evidence table

| # | Label | Source (file:line / read-only command) | Establishes |
|---:|---|---|---|
| E01 | [O] | `variant3d/tools/godot_runner.py:46-53,384-425,488-509,615-652` | Spool `variant3d/.godot_queue`; `run --id/--timeout/--max-wait`; `status`; `--` stripped at `:650-651`; runner timeout vs queue wait semantics |
| E02 | [O] | `godot_runner.py:586-612,644-647` | `ack <ticket> --reason <text>`; positional int ticket; result must exist (`:589-592`); writes `acknowledged`/`ack_reason`/`ack_at` to result **and** status history (`:598-608`); no `--id` on ack |
| E03 | [O] | `variant3d/tools/assert_clean.py:33-42,154-188,199-218,262-272` | Only `--json`/`--max-lock-age`/`--ignore-history`; leak set `{timed-out,error,skipped}`; `failed` excluded; `--ignore-history` returns `enabled:false,total:null,failures:[]` |
| E04 | [O] | Read-only reads of `variant3d/.godot_queue/counter`=`607`, `now_serving`=`607`, `jobs/*.json`=0, `godot.lock` absent, `status.json` history=500 | Settled spool; no re-submit/cleanup needed |
| E05 | [O] | Read-only `status.json` filter + `results/00000575.json`,`00000582.json`,`00000585.json` existence check | 575 `bbclamptidy01-parse` timed-out, 582 `terrainswarm-g1-selftest` skipped, 585 `g04-uitest` timed-out; all three unacked; result files present ⇒ `ack` will not return 2 |
| E06 | [O] | `V06_gate_remediation.md:83-98` (reasons at `:89-91`; E10 at `:49`, E11 at `:50`) | Evidence-backed ack wording and provenance for 575/582/585; never deletion/`--ignore-history` |
| E07 | [O] | `variant3d/scripts/main.gd:1271-1376` (`--screenshot` `:1271`, `--screenshot-frames` `:1275`, `--self-test` `:1283`, `--ui-test` `:1303`, `--timeout` `:1343`, `--config` `:1347`, `--dump-config` `:1351`, `--seed` `:1365`, `--dump-map` `:1373`) | Every game-side flag used below exists; unknown words skipped (`:1264-1265`) |
| E08 | [O]/[D] | `docs/terrain_swarm_2026-11-25/reports/C02_gate_plan.md:103-123`; `P12_hud_fix_proposal.md:362-363`; `L07_reverify_batch.md:102-105` | Prior-atom parse form: `run --id <u> --timeout 180 -- --headless --path variant3d --check-only --script res://…gd`; `.gdshader` has **no** `--check-only --script`, prior atom used headless test-script run (`:109,119-123`) |
| E09 | [O] | `V21_gate_register.md:154-181` (A′-0…A′-3, D-0…D-6, rollback at `:181`) | Exact gate order, stations and rollback action |
| E10 | [O] | `P03_gates_capture.md:68-75,166-178,182-199`; `V06_gate_remediation.md:100-130,152-182` | Exact selftest/uitest/`t_render_mode`/`t_map_variety` forms and fresh 240²/320² windowed capture forms |
| E11 | [O] | `variant3d/tools/scan_map.py:448` (`--dir` required); `smallmap_capture.py:64-69` (`stats` with `--reference`, `scan-stderr`); `terrain_ab_metric.py:725-741`; `compare_shots.py:135-141`; `full_map_shot.py:470-486` | All tool flags in this packet verified from source |
| E12 | [O] | `variant3d/tools/terrain_qa_harness.py:1123-1129` | N16's real CLI is `--dump-a/--dump-b/--seed-manifest/--policy/--out/--check`; **not** the `fingerprint`/`compare-runs` subcommands assumed by V21 — no invented subcommand is used here |
| E13 | [O] | `git status --short` (read-only), `variant3d/tests/t_terrain_donor.gd:33,36-45,49-61`, `manifest.json:1-5,139-144,244-258` | Seam applied; `t_terrain_donor` result path and optional module paths; manifest still 40 tests / atom not appended; relief atom still stale |
| E14 | [O] | `variant3d/config.json:74-77`; `variant3d/tests/fixtures/small_map_64.json:2-15`; `inbox/backup/{main.gd,world3d.gd}.bak-COORD-I11`, `manifest.json.bak-INTREG` | Shipped size is 240²; 64² fixture exists; rollback backups exist (no `bak-I12`, so manifest rollback is id-level) |
| E15 | [O] | `V06_gate_remediation.md:132-150`; `P03_gates_capture.md:93`; `terrain_sample_shot.py:145,431-440`; `full_map_shot.py:471`; `V21_gate_register.md:122` | Mixed-aperture tools and the exact override/bypass surface (§5) |
| E16 | [O] | `CHARTER.md:26-31,66-85,121-135`; `spec/12_QA_AND_INTEGRATION.md:86-94,127-139` | `app/**` byte-identical; gates 29/29, 17/17, `t_render_mode`, CLEAN; one Godot at a time; no parity without GPU A/B; file-scoped rollback |

`[I]` appears only where explicitly marked (§5 recommendation). `[U]` items are collected in the packet's acceptance notes and §8.

## 3. Source-verified flag matrix (multiple passes, no invention)

| Tool / subcommand | Verified flags (source:line) | Not available / forbidden |
|---|---|---|
| `godot_runner.py run` | `--id` required, `--timeout` float (default 120.0), `--max-wait` float (default 3600.0), `godot_args` remainder, leading `--` stripped (`:619-624,650-651`) | no `--project`, no `--path` on the runner itself (Godot args follow `--`) |
| `godot_runner.py status` | no arguments (`:626-627`) | no `--id`, no `--json` |
| `godot_runner.py ack` | positional `ticket:int`, `--reason` **required** (`:644-647`) | no `--id`, no `--ignore-history`, no deletion |
| `assert_clean.py` | `--json`, `--max-lock-age SEC`, `--ignore-history` (`:264-271`) | `--ignore-history` forbidden by V06/V21 (suppresses reasons) |
| `main.gd` (after second `--`) | `--screenshot`, `--screenshot-frames`, `--self-test`, `--ui-test`, `--timeout`, `--config`, `--dump-config`, `--seed`, `--dump-map` (`:1271-1376`) | never combine `--dump-config` with `--screenshot` (`P03:176-177`) |
| `smallmap_capture.py` | `stats IMAGES... [--reference PNG]`, `scan-stderr LOGS...` (`:64-69`) | — |
| `scan_map.py` | `--dir` required (`:448`) | — |
| `terrain_ab_metric.py` | `candidate [reference]`, `--compare-ref FOLDER`, `--json`, `--crop x,y,w,h`, `--crop-frac x0,y0,x1,y1`, `--blocks`, `--lags`, `--per-file` (`:725-741`) | **no** `--baseline`, no ARI (`P03:24,203`) |
| `compare_shots.py` | `--shot`, `--ref`, `--crop`, `--threshold` (default 0.80), `--json` (`:135-141`) | 0.80 default is a smoke placeholder (`P03:204`) |
| `full_map_shot.py` | `--dump`, `--gen-dump`, `--seed`, `--config`, `--tile-px`, `--out`, `--crosscheck-png`, `--game-timeout`, `--runner-timeout` (`:470-486`) | no `--project`; `--gen-dump` boots `app` (`V06 E15`) |
| `terrain_sample_shot.py` | `--scan-seeds`, `--capture`, `--seed`, `--validate-only` (`:431-440`) | no `--project`/`--spool`; result lookup hardcoded `app/.godot_queue` (`:145`) |
| `terrain_qa_harness.py` | `--dump-a`, `--dump-b`, `--seed-manifest`, `--policy`, `--out`, `--check` (`:1123-1129`) | no `fingerprint`/`compare-runs` subcommands |

## 4. Command packet — COORD executes, in V21 order

**Conventions.** `<T>` = `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v42` (outside the repo). Run from repo root. One Godot at a time; call `python variant3d\tools\godot_runner.py status` after **every** `run` and re-check `pending=0`, lock free, counters aligned before submitting the next (`AGENT_PROTOCOL.md:39-49`; `P03:120`). Substitute the real 8-digit ticket from `status`/the result path wherever `<ticketN>` appears. **Accept nothing on exit 0 alone**: require result envelope `status=ok`, `exit=0`, `SCRIPT ERROR=0`, fresh result mtime after that job's START and `scan-stderr` `script_error_lines: 0` (`V06:130`).

### 4.0 One-time temp workspace + pinned size overlays (no Godot)

```powershell
New-Item -ItemType Directory -Force -Path "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v42\dumps" | Out-Null
'{"gameplay":{"render_mode":"3d","random_seed":20261113,"map_width_tiles":64,"map_height_tiles":64}}' | Out-File -FilePath "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v42\map_64.json" -Encoding ascii -NoNewline
'{"gameplay":{"render_mode":"3d","random_seed":20261113,"map_width_tiles":240,"map_height_tiles":240}}' | Out-File -FilePath "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v42\map_240.json" -Encoding ascii -NoNewline
'{"gameplay":{"render_mode":"3d","random_seed":20261113,"map_width_tiles":320,"map_height_tiles":320}}' | Out-File -FilePath "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v42\map_320.json" -Encoding ascii -NoNewline
```

**[D]** The 64² values mirror the landed fixture `variant3d/tests/fixtures/small_map_64.json:10-15`; config.gd reads `res://config.json` first and merges the overlay (`small_map_64.json:5`; `main.gd:1347-1349`), and `--seed` is applied separately (`main.gd:1365-1371`). Do not call a shipped-config frame "320²" (`config.json:75-76` is 240²).

### 4.1 A′-0 — preflight, ACK three leaks WITH reasons, then plain CLEAN

```powershell
python variant3d\tools\godot_runner.py status
python variant3d\tools\assert_clean.py --json
git status --short -- app/
git diff --exit-code -- app/
```

**[O]** The second command is expected `DIRTY` until the three acks land (E05). Note the exact ACK syntax (§4.2), then re-verify.

### 4.2 ACK syntax (from source) and the three evidence-backed calls

**Syntax** (`godot_runner.py:644-647`, `:586-612`):

```
python variant3d\tools\godot_runner.py ack <TICKET_INT> --reason "<evidence-backed text>"
```

- `ticket` is a **positional int**; `--reason` is **required**; a missing result JSON returns 2 (`:589-592`). All three result files exist (E05).
- The call writes `acknowledged=true`, `ack_reason`, `ack_at` into both `results\<ticket>.json` and the matching `status.json` history row (`:598-608`).
- **Never** `--ignore-history`, result deletion, status hand-editing, `reset --yes`, `doctor`, `cancel` or `unwedge` to obtain CLEAN (`V06:83-85`; `E03`). These acks record **retirement of retired diagnostics**, not passing gates.

```powershell
python variant3d\tools\godot_runner.py ack 575 --reason "COORD policy ack 2026-11-26: diagnostic-only --check-only game.gd parse probe timed out at 300s (exit -9, run 302.44s, SCRIPT ERROR 0; docs/coord_swarm_2026-11-25/reports/B_B_CLAMP_TIDY.md:148-149). Owner retired the probe without re-submit. This records retirement, NOT a passing gate and NOT a parse proof; fresh gates are re-run below."
python variant3d\tools\godot_runner.py ack 582 --reason "COORD policy ack 2026-11-26: terminal skipped bookkeeping remnant, run=0.0, bogus error serving=2581 (docs/terrain_swarm_2026-11-25/reports/G12_runner_monitor.md:128-138; G04_gate_log.md:157-165); no Godot ran and COORD cleared the stale job file. Superseded by ok jobs 568/569 (MAP240_APPLY_01.md:100-109). Records retirement only, NOT a green selftest run."
python variant3d\tools\godot_runner.py ack 585 --reason "COORD policy ack 2026-11-26: g04-uitest hung in setup and was killed at 300s (exit -9, SCRIPT ERROR 0; G04_gate_log.md:183,197-211); follow-up 587 hit the 120s watchdog and the on-disk 17/17 predated both runs, so no fresh PASS was claimed. Superseded by ok job 569 at 240x240 (MAP240_APPLY_01.md:101,108-109). Records retirement, NOT a green uitest."

python variant3d\tools\godot_runner.py status
python variant3d\tools\assert_clean.py --json
```

**Accept only** (`assert_clean.py:182-218`; `V06:98`): exit 0, `verdict=CLEAN`, `reasons=[]`, `checks.processes.count=0`, `checks.lock.state=free` (or `held_recent` with a live job), `checks.history.enabled=true`, `checks.history.total=500`, `checks.history.acknowledged>=3`, `checks.history.failures=[]`. **STOP** if any item is unmet; if a fourth leak appears, ack it with its own reason — never widen the failure set or delete an entry.

### 4.3 A′-1 — static / parse smoke (one runner job per file)

```powershell
python -m py_compile variant3d\tools\decode_donor_cfg.py variant3d\tools\decode_donor_pattern.py variant3d\tools\decode_pattern_lib.py variant3d\tools\decode_donor_masks.py variant3d\tools\build_terrain_new_atlas.py variant3d\tools\terrain_qa_harness.py

python variant3d\tools\godot_runner.py run --id v42-parse-data --timeout 180 -- --headless --path variant3d --check-only --script res://scripts/terrain_donor_data.gd
python variant3d\tools\godot_runner.py status
python variant3d\tools\godot_runner.py run --id v42-parse-gen --timeout 180 -- --headless --path variant3d --check-only --script res://scripts/terrain_donor_gen.gd
python variant3d\tools\godot_runner.py status
python variant3d\tools\godot_runner.py run --id v42-parse-mesh --timeout 180 -- --headless --path variant3d --check-only --script res://scripts/terrain_donor_mesh.gd
python variant3d\tools\godot_runner.py status
python variant3d\tools\godot_runner.py run --id v42-parse-props --timeout 180 -- --headless --path variant3d --check-only --script res://scripts/terrain_donor_props.gd
python variant3d\tools\godot_runner.py status
python variant3d\tools\godot_runner.py run --id v42-parse-world --timeout 180 -- --headless --path variant3d --check-only --script res://scripts/terrain_donor_world.gd
python variant3d\tools\godot_runner.py status
python variant3d\tools\godot_runner.py run --id v42-parse-main --timeout 180 -- --headless --path variant3d --check-only --script res://scripts/main.gd
python variant3d\tools\godot_runner.py status
python variant3d\tools\godot_runner.py run --id v42-parse-seam-world --timeout 180 -- --headless --path variant3d --check-only --script res://scripts/world3d.gd
python variant3d\tools\godot_runner.py status
python variant3d\tools\godot_runner.py run --id v42-parse-tdonor --timeout 180 -- --headless --path variant3d --check-only --script res://tests/t_terrain_donor.gd
python variant3d\tools\godot_runner.py status
```

**Shader (`.gdshader`) — exact prior-atom form, not `--check-only --script`.** Prior atoms state explicitly that a `.gdshader` has no `--check-only --script` and instead use a headless test-script run that constructs the material and compiles the shader (`C02_gate_plan.md:109,119-123`). Adapted to the landed atom:

```powershell
python variant3d\tools\godot_runner.py run --id v42-shader-smoke --timeout 300 -- --headless --path variant3d --script res://tests/t_terrain_donor.gd -- --config "C:/Users/Maxym.Oboyshev/Documents/Craft Anything/cossacks-3-3/variant3d/tests/fixtures/small_map_64.json"
python variant3d\tools\godot_runner.py status
python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\<ticket>_v42-shader-smoke\stderr.txt
```

**[O]/[D]** Require `SCRIPT ERROR=0` and no shader compile line in stderr; headless `SKIP_CAPTURE` / `passed=false` is **expected** and is only a parse/compile smoke, never a gate PASS (`C02:119-123`). Do **not** add a parse job for the absent `res://scripts/terrain_donor_tiles.gd` or `res://scripts/terrain_donor_shader.gdshader` — `t_terrain_donor.gd:42-43` declares them optional, and the landed shader is `variant3d/shaders/terrain_donor_shader.gdshader` (E13; open question Q3).

### 4.4 A′-2 — evidence checkpoint (read-only; no runner job)

```powershell
Test-Path docs\terrain_swarm_2026-11-26\reports\V17_spec_readiness.md
Test-Path docs\terrain_swarm_2026-11-26\reports\X13_blend_test_vectors.md
Test-Path variant3d\tools\terrain_qa_harness.py
Test-Path docs\terrain_swarm_2026-11-26\spec\terrain_qa_spec.json
```

**[D]** Record which class-B bands remain `[U]` and set `--policy advisory` for every structural gate (`V21:129-131,164`; `spec/12:105-109`). **STOP** if any `[U]` band is promoted or any threshold changed (`V21 A′-2`).

### 4.5 A′-3 — ledger (no gate result claimed)

```powershell
Get-FileHash variant3d\tools\decode_donor_cfg.py,variant3d\tools\decode_donor_pattern.py,variant3d\tools\decode_pattern_lib.py,variant3d\tools\decode_donor_masks.py,variant3d\tools\build_terrain_new_atlas.py,variant3d\tools\terrain_qa_harness.py,variant3d\scripts\terrain_donor_data.gd,variant3d\scripts\terrain_donor_gen.gd,variant3d\scripts\terrain_donor_mesh.gd,variant3d\scripts\terrain_donor_props.gd,variant3d\scripts\terrain_donor_world.gd,variant3d\tests\t_terrain_donor.gd,variant3d\shaders\terrain_donor_shader.gdshader,variant3d\config.json,docs\terrain_swarm_2026-11-26\spec\terrain_qa_spec.json -Algorithm SHA256
```

### 4.6 D-0 — repeat preflight on the integrated tree

```powershell
python variant3d\tools\godot_runner.py status
python variant3d\tools\assert_clean.py --json
git status --short -- app/
git diff --exit-code -- app/
python -c "import json,pathlib; d=json.loads(pathlib.Path('variant3d/tests/manifest.json').read_text()); t=d['tests']; print('test_count',len(t),'last',t[-1]['id'],'t_terrain_donor_present',any(x.get('id')=='t_terrain_donor' for x in t))"
```

**[O]** V11 §8 acceptance requires 40→41 with `t_terrain_donor` appended **last**; current read shows 40 and no entry (E13). One `var`/setter/ternary (`main.gd:125,189-190,593-594,1112-1113`; `world3d.gd:144,220-224,624`) and default `"legacy"` (`main.gd:125`; `world3d.gd:144`) are the expected seam shape (`spec/12:12-20`).

### 4.7 D-1 — static/parse on final tree

```powershell
python variant3d\tools\godot_runner.py run --id v42-reparse-seam-main --timeout 180 -- --headless --path variant3d --check-only --script res://scripts/main.gd
python variant3d\tools\godot_runner.py status
python variant3d\tools\godot_runner.py run --id v42-reparse-seam-world --timeout 180 -- --headless --path variant3d --check-only --script res://scripts/world3d.gd
python variant3d\tools\godot_runner.py status
python variant3d\tools\godot_runner.py run --id v42-relief-props-atom --timeout 180 -- --headless --path variant3d --check-only --script res://tests/t_relief_props_qa.gd
python variant3d\tools\godot_runner.py status
```

**[O]** GR-A24 is a **known hard blind spot**: `t_relief_props_qa.gd:30` still points at `res://assets/terrain/terrainmesh_props.json` (absent) while the live manifest is `mountain_props.json` (`V21 GR-A24/E15/U15`). COORD must have its owner repoint the literal **without lowering** `SCALE_WANT`/`BBOX_TOL`/count; do not report this atom green until then.

### 4.8 D-2 — determinism/structure lane (headless dumps; one job at a time)

```bat
python variant3d\tools\godot_runner.py run --id v42-dump-64-a --timeout 700 --max-wait 3600 -- --headless --path variant3d -- --seed 20261113 --config "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v42/map_64.json" --dump-map "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v42/dumps/v42_64_a.json" --timeout 600
python variant3d\tools\godot_runner.py status
python variant3d\tools\godot_runner.py run --id v42-dump-64-b --timeout 700 --max-wait 3600 -- --headless --path variant3d -- --seed 20261113 --config "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v42/map_64.json" --dump-map "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v42/dumps/v42_64_b.json" --timeout 600
python variant3d\tools\godot_runner.py status
python variant3d\tools\godot_runner.py run --id v42-dump-240-a --timeout 700 --max-wait 3600 -- --headless --path variant3d -- --seed 20261113 --config "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v42/map_240.json" --dump-map "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v42/dumps/v42_240_a.json" --timeout 600
python variant3d\tools\godot_runner.py status
python variant3d\tools\godot_runner.py run --id v42-dump-240-b --timeout 700 --max-wait 3600 -- --headless --path variant3d -- --seed 20261113 --config "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v42/map_240.json" --dump-map "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v42/dumps/v42_240_b.json" --timeout 600
python variant3d\tools\godot_runner.py status
python variant3d\tools\godot_runner.py run --id v42-dump-320-a --timeout 700 --max-wait 3600 -- --headless --path variant3d -- --seed 20261113 --config "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v42/map_320.json" --dump-map "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v42/dumps/v42_320_a.json" --timeout 600
python variant3d\tools\godot_runner.py status
python variant3d\tools\godot_runner.py run --id v42-dump-320-b --timeout 700 --max-wait 3600 -- --headless --path variant3d -- --seed 20261113 --config "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v42/map_320.json" --dump-map "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v42/dumps/v42_320_b.json" --timeout 600
python variant3d\tools\godot_runner.py status
python variant3d\tools\scan_map.py --dir "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v42/dumps"
python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\<ticket>_v42-dump-320-b\stderr.txt
Get-FileHash "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v42\dumps\v42_64_a.json","C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v42\dumps\v42_64_b.json","C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v42\dumps\v42_240_a.json","C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v42\dumps\v42_240_b.json","C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v42\dumps\v42_320_a.json","C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v42\dumps\v42_320_b.json" -Algorithm SHA256
python variant3d\tools\assert_clean.py --json
```

**Optional N16 lane (now landed; flags verified at E12)** — use only with the real pinned key manifest and two same-key dumps; no `compare-runs` subcommand exists:

```powershell
python variant3d\tools\terrain_qa_harness.py --dump-a "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v42/dumps/v42_240_a.json" --dump-b "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v42/dumps/v42_240_b.json" --seed-manifest "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v42/map_240.json" --policy advisory --out "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v42/qa_harness_report.json" --check
```

**[D]** Whole-file SHA equality per `(a,b)` pair is a legitimate **port-internal** determinism check `[D]`; D1's five-stream zero-difference fingerprint must come from the harness, not the whole-file hash (`V06:200`; `V21 U6`). Never relax `scan_map.py` gates (`scan_map.py:478-493`); require `ALL GREEN`/exit 0.

### 4.9 D-3 — headless structural gates (`t_render_mode`, `t_terrain_donor`, `t_map_variety`)

```bat
python variant3d\tools\godot_runner.py run --id v42-rendermode --timeout 180 -- --headless --path variant3d --script res://tests/t_render_mode.gd
python variant3d\tools\godot_runner.py status
python variant3d\tools\godot_runner.py run --id v42-terraindonor --timeout 300 -- --headless --path variant3d --script res://tests/t_terrain_donor.gd
python variant3d\tools\godot_runner.py status
python variant3d\tools\godot_runner.py run --id v42-mapvariety --timeout 180 -- --headless --path variant3d --script res://tests/t_map_variety.gd
python variant3d\tools\godot_runner.py status
python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\<ticket>_v42-rendermode\stderr.txt variant3d\.godot_queue\results\<ticket>_v42-terraindonor\stderr.txt variant3d\.godot_queue\results\<ticket>_v42-mapvariety\stderr.txt
```

**Acceptance (not a result — these are criteria to check after COORD runs):** `variant3d/tests/results/t_render_mode.json` `passed=true`, `result=PASS`, `seam_missing=false`, 10/10 (`P03:70`); `variant3d/tests/results/t_terrain_donor.json` `passed=true`, no class-A FAIL, every `[U]`/HOOK_MISSING row recorded as advisory and never promoted (`t_terrain_donor.gd:22-30,142-149,618-621`); `variant3d/tests/results/t_map_variety.json` 5/5 (`P03:72`). All result mtimes must be after their job START (`V06:130`).

### 4.10 D-4 — FRESH WINDOWED captures: 64², 240², 320² (one job at a time, output outside repo)

```bat
python variant3d\tools\godot_runner.py run --id v42-cap-64 --timeout 700 --max-wait 3600 -- --path variant3d -- --config "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v42/map_64.json" --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v42/cap_64.png" --screenshot-frames 10 --seed 20261113 --timeout 600
python variant3d\tools\godot_runner.py status
python variant3d\tools\godot_runner.py run --id v42-cap-240 --timeout 700 --max-wait 3600 -- --path variant3d -- --config "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v42/map_240.json" --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v42/cap_240.png" --screenshot-frames 10 --seed 20261113 --timeout 600
python variant3d\tools\godot_runner.py status
python variant3d\tools\godot_runner.py run --id v42-cap-320 --timeout 700 --max-wait 3600 -- --path variant3d -- --config "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v42/map_320.json" --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v42/cap_320.png" --screenshot-frames 10 --seed 20261113 --timeout 600
python variant3d\tools\godot_runner.py status
python variant3d\tools\smallmap_capture.py stats "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v42/cap_64.png" "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v42/cap_240.png" "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v42/cap_320.png"
python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\<ticket>_v42-cap-64\stderr.txt variant3d\.godot_queue\results\<ticket>_v42-cap-240\stderr.txt variant3d\.godot_queue\results\<ticket>_v42-cap-320\stderr.txt
```

**Rules:** no `--headless` (it writes the 800×600 CPU fallback, `main.gd:3-5`; `P03:175`); `--screenshot-frames 10` selects the real viewport path (`main.gd:1275-1276`); `--timeout 600` after the second `--` overrides the 120 s watchdog (`main.gd:1343-1345`; `P03:176`); runner `--timeout 700` must exceed it; never combine with `--dump-config` (`P03:176-177`). Require 1280×720, non-blank, `full_width_dark_rows=0`, `script_error_lines=0` and record the stdout capture diag (`camera_current=true`, `world_parent=Screenshot3DViewport`, plausible camera pos/target) before accepting a frame (`V21 GR-C01:113`; `P03:187`). A blank-detector false rejection has a `<name>.png.raw.png` sidecar — record an instrument defect, do not edit the detector (`P03:177`).

**Freeze outside the repo + SHA-256 manifest:**

```powershell
Copy-Item "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v42\cap_64.png" "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v42\cap_64_baseline.png"
Copy-Item "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v42\cap_240.png" "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v42\cap_240_baseline.png"
Copy-Item "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v42\cap_320.png" "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v42\cap_320_baseline.png"
Get-FileHash "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v42\cap_64_baseline.png","C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v42\cap_240_baseline.png","C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v42\cap_320_baseline.png","C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v42\map_64.json","C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v42\map_240.json","C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v42\map_320.json" -Algorithm SHA256
```

**[U]** No donor GPU A/B frame exists. Optional SMOKE-only comparisons (flags verified at E11; identical crop on both sides; no "ARI pass"/parity language):

```powershell
python variant3d\tools\compare_shots.py --shot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v42/cap_320.png" --ref "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v42/cap_320_repeat.png" --threshold 0.9999 --json
python variant3d\tools\terrain_ab_metric.py "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v42/cap_320.png" "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v42/cap_320_baseline.png" --crop 120,60,1040,580 --json
python variant3d\tools\terrain_ab_metric.py "C:/Users/Maxym.Oboyshev/AppData\Local\Temp\opencode\v42\cap_320.png" --compare-ref "C:\Users\Maxym.Oboyshev\Downloads\c3" --crop-frac .35,.55,.48,.70 --json --per-file
```

### 4.11 D-5 — final regression on the integrated tree

```bat
python variant3d\tools\godot_runner.py run --id v42-selftest --timeout 700 -- --headless --path variant3d -- --self-test variant3d/selftest.json --timeout 600
python variant3d\tools\godot_runner.py status
python variant3d\tools\godot_runner.py run --id v42-uitest --timeout 700 -- --headless --path variant3d -- --ui-test variant3d/uitest.json --timeout 600
python variant3d\tools\godot_runner.py status
python variant3d\tools\godot_runner.py run --id v42-rendermode-final --timeout 180 -- --headless --path variant3d --script res://tests/t_render_mode.gd
python variant3d\tools\godot_runner.py status
python variant3d\tools\godot_runner.py run --id v42-mapvariety-final --timeout 180 -- --headless --path variant3d --script res://tests/t_map_variety.gd
python variant3d\tools\godot_runner.py status
python variant3d\tools\assert_clean.py --json
git status --short -- app/
git diff --exit-code -- app/
```

**Acceptance:** `selftest.json` `passed=true` **29/29**, `uitest.json` **17/17**, `t_render_mode` `PASS`/`seam_missing=false`, `t_map_variety` **5/5**, `assert_clean` CLEAN, `app/**` byte-identical, every JSON fresh (mtime after START) (`spec/12:90-94`; `V21 GR-A03:75`). Without `--timeout 600` after the second `--`, selftest/uitest force-exit near 120 s (`V06:221`).

### 4.12 D-6 — COORD sign-off (no runner job; COORD writes the report)

```powershell
python -c "import json,pathlib; p=pathlib.Path('variant3d/.godot_queue/status.json'); h=json.loads(p.read_text())['history']; print('history',len(h),'unacked',[(x.get('ticket'),x.get('status')) for x in h if x.get('status') in ('timed-out','error','skipped') and not x.get('acknowledged')])"
git status --short -- app/
```

**[O]** Verdict vocabulary stays "gates green / internal consistency PASS / donor parity UNVERIFIED"; `parity.status=UNVERIFIED`, split `declared_unverified` vs `blocking_unverified`, verbatim reviewer line (`V21 D-6:177`; `spec/12:121-122`). Any required UNVERIFIED ⇒ `RESULT IS NOT GOOD` + hold/rollback.

## 5. Exact override paths that avoid V06's hardcoded `app/` aperture

**[O]** Eight `variant3d/tools` capture tools are byte-identical `app/tools` copies (`P03:23,84-93`; `V06:26`). A variant-local copy still boots `app/` unless overridden (E15). The safe first-baseline route is the **direct runner commands in §4.8/§4.10** with explicit `--path variant3d` and absolute paths — **[I]** recommended; V06 changes no tool (`V06:150`).

| Tool | Hardcoded `app/` aperture (file:line) | Override that **exists** | COORD rule |
|---|---|---|---|
| `godot_runner.py`, `assert_clean.py` | variant spool `variant3d/.godot_queue` (`godot_runner.py:47`; `assert_clean.py:34`) | as documented | Use as-is; no copy needed (`V06:148`) |
| `scan_map.py` | docstring `app/tools/scan_map.py --dir scans` (`:4`) | **`--dir`** (`:448`; `V06:146`) | `scan_map.py --dir <fresh-dumps-dir>` only |
| `smallmap_capture.py`, `terrain_ab_metric.py` | none (variant-only image/log readers) | `stats`/`scan-stderr`; candidate/reference/crop flags (`V06:147`) | Pass explicit absolute paths as-is |
| `compare_shots.py`, `terrain_compare.py` | doc examples/comparator defaults `app/shots` (`P03:102-104`) | `--shot`, `--ref`, `--crop`, `--threshold`, `--json` (`compare_shots.py:135-141`; `V06:144-145`) | CLI overrides suffice; SMOKE labels stay |
| `full_map_shot.py` | `--gen-dump` Godot argv `--path app`; result lookup `app/.godot_queue` (`V06 E15:140`, `:471`) | `--dump`, `--out`, `--tile-px`, `--config` (`:470-486`) | Compositor only with explicit absolute `--dump`+`--out`; **never `--gen-dump`**. If unavoidable, variant-local copy changing the argv to `--path variant3d` and the lookup to `variant3d/.godot_queue` |
| `terrain_sample_shot.py` | result `ROOT/"app"/".godot_queue"` (`:145`), Godot argv `--path app`, outputs `variant3d/shots` (`V06 E13:141-145`) | only `--scan-seeds/--capture/--seed/--validate-only` (`:431-440`) — **no** `--project`/`--spool` | Do **not** run `--capture`; bypass with §4.10 direct runner |
| `terrain_land_shot.py` | inherits base module paths/argv (`V06:142`) | only `--scan/--capture/--seed/--validate-only` | Do **not** run `--capture`; variant-local copy would need to override `base.APP/SHOTS/CONFIG_PATH` too |
| `heightmap3d_shot.py`, `terrain3d_shot.py` | `RUNNER=app/tools/godot_runner.py`, `SHOTS=app/shots` (`V06:138-139`) | heightmap: `--shot/--json/--submit/--id/--timeout/--no-headless/--donor`; terrain3d: only `--shot` | Legacy M0/M0.6/G3-2 instruments; variant-local copy if used at all; never a fresh 240²/320² gate |

**[I]** Verify aperture from the **stdout config/camera diag**, never from the tool's folder (`V06:219`; `V21 GR-C10:122`).

## 6. Rollback — file-scoped, no `git reset --hard`

**Triggers (any one, COORD only):** D1 byte mismatch; D3 dirty runner or `timed-out|error|skipped`; any red structural FAIL; illegal tile id / unknown stamp/family; smoothing vector FAIL; `app/` hash drift or freeze-set diff; deleted assertion, lowered threshold, invented band or new donor constant without `path:line`; mixed-aperture/headless/blank/wrong-size capture; visible R1–R6 failure with or without green metrics; any donor-parity wording; any non-empty `blocking_unverified` (`V21:179`).

```powershell
# 1) Backup the CURRENT integrated state before touching anything (id-level backup).
Copy-Item variant3d\scripts\main.gd inbox\backup\main.gd.bak-V42-ROLLBACK
Copy-Item variant3d\scripts\world3d.gd inbox\backup\world3d.gd.bak-V42-ROLLBACK
Copy-Item variant3d\tests\manifest.json inbox\backup\manifest.json.bak-V42-ROLLBACK

# 2) Restore the two EDIT files from their named COORD-I11 backups (verified present, E14).
Copy-Item inbox\backup\main.gd.bak-COORD-I11 variant3d\scripts\main.gd -Force
Copy-Item inbox\backup\world3d.gd.bak-COORD-I11 variant3d\scripts\world3d.gd -Force
Get-FileHash variant3d\scripts\main.gd,variant3d\scripts\world3d.gd,inbox\backup\main.gd.bak-COORD-I11,inbox\backup\world3d.gd.bak-COORD-I11 -Algorithm SHA256

# 3) Manifest: id-level removal ONLY (no bak-I12 exists), never whole-file blind restore.
python -c "import json,pathlib; p=pathlib.Path('variant3d/tests/manifest.json'); d=json.loads(p.read_text(encoding='utf-8')); d['tests']=[t for t in d['tests'] if t.get('id')!='t_terrain_donor']; p.write_text(json.dumps(d, indent=2)+chr(10), encoding='utf-8')"

# 4) Delete ONLY the new module/composer/test/shader files (explicit list, no wildcard).
Remove-Item variant3d\scripts\terrain_donor_world.gd,variant3d\scripts\terrain_donor_data.gd,variant3d\scripts\terrain_donor_gen.gd,variant3d\scripts\terrain_donor_mesh.gd,variant3d\scripts\terrain_donor_props.gd,variant3d\tests\t_terrain_donor.gd,variant3d\shaders\terrain_donor_shader.gdshader

# 5) Composition returns to legacy via the existing switch (already default "legacy").
#    main.gd:125 / world3d.gd:144 => "legacy"; do not edit the switch to force donor.
```

**[D]** Keep inert tools/assets and every `.bak` (`V21:181`). Re-run **D-5** to green after restore and record the reason in the report `rollback` block. **Forbidden:** `git reset --hard`, `git checkout .`, `git clean`, blanket `Copy-Item`, deleting `.bak` files, re-running until green, weakening any gate (`spec/12:86-88`; `V21:181`), result-JSON deletion, `--ignore-history`, runner `reset --yes`, or `doctor` while any job is pending.

## 7. Risks

1. **[O] Stale-green JSON** — on-disk `passed=true` predates today's tree (`V06 E03/E04`); only mtime-after-START plus envelope + `scan-stderr` counts.
2. **[O] CLEAN by suppression** — `--ignore-history` erases the reasons (`assert_clean.py:154-156`); ack with reasons (§4.2) or leave CLEAN unclaimed.
3. **[O] Mixed aperture** — variant-local copies boot `app/` and read `app/.godot_queue` (§5); use direct runner jobs and verify stdout diag.
4. **[O] Watchdog vs runner timeout** — `--timeout 600` after the second `--` is mandatory; runner `--timeout 700` must exceed it (`V06:221`).
5. **[O] Size contradiction** — `config.json:75-76` = 240² vs `small_map_64.json:6` prose = 320²; pin all three overlays, label by actual size (`V21 MP7:149`).
6. **[O] Fresh tree ≠ reports' assumptions** — seam already applied, shader path differs from plan, N16/N17/X13/V17 landed, relief atom still stale (E13/E14); COORD must re-read before each station.
7. **[U] D1/N16 contract** — harness CLI is `--dump-a/--dump-b/…`, not V21's assumed subcommands (E12); whole-file SHA is `[D]` only, D1 stays UNVERIFIED until a real harness run.
8. **[O] Capture traps** — `--dump-config` exits before screenshot; runner exit 0 is not a PNG; headless fallback 800×600; blank detector has `.raw.png` sidecar (`P03:243`).
9. **[O] Queue contention** — FIFO waits of 100–400 s are normal; never re-submit (`AGENT_PROTOCOL.md:39-49`). Spool is settled (E04), so no cleanup.
10. **[O] `app/` drift** — re-hash at A′-0 and D-5 (E16).
11. **[U] 582 `serving=2581`** — historical spool artifact, not a live desync (`V06:223`); if `status` ever shows `now_serving != next_ticket`, STOP, do not `unwedge` speculatively.
12. **[O] SMOKE-only metric** — `terrain_ab_metric.py` has no `--baseline`/ARI (`E11`, `P03:24`); no "ARI pass", no donor-parity wording (`V21 GR-C07:119`).

## 8. Open questions

1. **COORD:** accept the three V06 ack strings verbatim (V06:89-91, reproduced in §4.2), or amend wording while keeping evidence citations? No deletion, no `--ignore-history`.
2. **COORD/I10:** `t_terrain_donor.gd:43` expects `res://scripts/terrain_donor_shader.gdshader`, but the landed shader is `res://shaders/terrain_donor_shader.gdshader`; the atom treats it as optional, so no shader gate fires — who reconciles the path without lowering an assertion?
3. **COORD/I12:** when is `t_terrain_donor` appended LAST to `manifest.json` (40→41) — before D-0 or at stage C′? Current manifest has no entry (E13).
4. **COORD/QA owner:** who repoints `t_relief_props_qa.gd:30` (`terrainmesh_props.json` → `mountain_props.json`) keeping `SCALE_WANT`/`BBOX_TOL`/count unchanged (GR-A24)?
5. **COORD:** canonical size — shipped 240² (`config.json:75-76`) or spec-level 320²? This packet pins both plus 64² and assigns no priority.
6. **COORD/V17:** which spec sections are READY and what evidence permits any `--policy red` flip (V21 Q1)? Packet uses `advisory` throughout.
7. **Owner:** is a genuine donor GPU A/B frame obtainable at all? Until yes, `parity.status=UNVERIFIED` and no R1–R6 card may be called donor parity.

## 9. Honesty / scope statement

Exactly one file was written: this report. No `.gd`, shader, config, fixture, tool, result JSON, PNG, `app/` file or git state was edited. **No Godot process was launched and no runner subcommand — including `run`, `status`, `ack`, `cancel`, `reset`, `doctor`, `unwedge` — was executed.** All "current" values came from direct read-only file reads, listings and the cited reports, with a second pass on every contested claim (flag surfaces, ack state, size contradiction, shader/module paths). Every command is a **PLAN** for COORD. No threshold was lowered, no assertion deleted, no green result fabricated, **no gate result claimed, no runner job submitted, and no donor-parity claim made**. **PORT APPROXIMATION / port-internal consistency only; donor parity remains UNVERIFIED.**

## 10. Five-line summary

1. [O] Flag surfaces re-verified from source: `godot_runner.py` `run/--id/--timeout/--max-wait`, `status`, `ack <ticket> --reason`; `assert_clean.py` `--json/--max-lock-age/--ignore-history`; all game/tool flags cited to file:line — no invented flag.
2. [O] 575/582/585 are still unacked (result JSONs exist, spool 607/607, lock free); ack each with the V06 evidence-backed `--reason`, then plain `assert_clean.py --json` — never `--ignore-history` or deletion.
3. [D] Packet follows V21 A′-0…A′-3 → D-0…D-6: parse/static per new `.gd`, headless test-script smoke for `.gdshader`, then `t_render_mode`/`t_terrain_donor`/`t_map_variety`, `scan_map.py`, and `selftest` 29/29 + `uitest` 17/17 at D-5, all with unique `v42-` ids.
4. [O] Fresh 64²/240²/320² windowed captures use pinned overlays, one at a time, `--path variant3d`, absolute config/screenshot paths under `%TEMP%\opencode\v42`, SHA-256 manifests; V06's hardcoded `app/` tools are bypassed or given explicit `--dump`/`--out`/`--dir` overrides.
5. [U] Rollback is file-scoped (`bak-COORD-I11` restore + id-level manifest edit + explicit new-file deletion), never `git reset --hard`; V42 ran no job, claims no gate result, and makes no donor-parity claim.

*End of V42 gate command packet. Planned only; no runner job, no gate result, no edit outside this report, no parity claim.*
