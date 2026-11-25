---
id: CLEAN-ACK-PLAN-01
title: "Map the 16 unacked skipped variant jobs to superseding PASS jobs; prepare exact ack commands"
area: coordination / variant3d clean gate / read-only planning
owner: CLEAN-ACK-PLAN-01 (read-only planning worker; no runner-state mutation)
date: 2026-11-25
status: PLAN_ONLY__NO_RUNNER_STATE_MUTATION__NO_CODE_EDIT__NO_DONOR_ACCESS
scope: "Read-only inspection of variant3d/.godot_queue result JSONs, status.json, and existing coordination reports. Only this report file was authored. No ack/cancel/reset/unwedge/doctor command was run; no Godot process started or killed; no donor file or code/config/test/asset touched."
labels: [observed, derived, inferred, UNVERIFIED]
counts: "16 skipped tickets 448-473; 14 with verified ok/exit 0 PASS supersedes; 2 UNRESOLVED (452, 453)"
prerequisite: "Commands MUST NOT be run while any job is pending or any Godot process is alive. COORD/user owns execution."
---

# CLEAN-ACK-PLAN-01 — ack plan for the 16 unacked skipped variant jobs

**Mutation statement (explicit):** **No runner-state mutation was performed.** No
`ack`, `cancel`, `reset`, `unwedge` or `doctor` command was executed; no job was
submitted; no `now_serving`, `counter`, lock, job, result JSON or `status.json` field
was changed; no Godot process was started or killed; no code, config, test, fixture,
asset or donor file was read for editing or edited. **The only file written is this
report.** All commands in §4 are **prepared, not executed**.

**Labels used:** `observed` = literal file/command fact read here; `derived` =
arithmetic or cross-reference of observed facts; `inferred` = best-supported reading
with a caveat; `UNVERIFIED` = cannot be proven from the material read.

**No visual-parity, donor A/B, selftest-green or CLEAN claim is made in this report.**
This is an ack-preparation plan only.

---

## 1. Sources read (all read-only)

| # | Source | What it supplied |
|---:|---|---|
| S1 | `docs/coord_swarm_2026-11-25/reports/QA_CLEAN_02.md` | The task's 16 unacked `skipped` jobs (tickets 448–473), exact error strings, owner attribution table (§2.1), and the "CLEAN not signable / queue not quiet" verdict. |
| S2 | `docs/coord_swarm_2026-11-25/reports/CLEAN_01_variant_clean.md` | Precedent: 98 historical failures acked with concrete reasons via `python variant3d\tools\godot_runner.py ack <ticket> --reason "<text>"`; 2 unexplained `failed` jobs (296/300) deliberately left unacked; ack metadata semantics. |
| S3 | `variant3d/tools/CLEAN_GATE.md` (exit-code section `:40-46`, ack section `:105-117`, ruling `:99-103`) | Gate exit codes (0 CLEAN / 1 DIRTY / 2 bad invocation); `failed` deliberately excluded; `ack` is the coordinator's sanctioned remediation; meaningful verdict requires a quiet queue. |
| S4 | `variant3d/tools/godot_runner.py:538-564` (`cmd_ack`) and `:596-599` (argparse) | Exact ack argument contract: ticket is an int, `--reason` required; sets `acknowledged`/`ack_reason`/`ack_at` on `results/<ticket:08d>.json` and syncs the same three fields into the matching `status.json` history entry. Ticket with no result JSON → exit 2. |
| S5 | `variant3d/.godot_queue/results/000004*.json` and `000005*.json` | Per-job `id`, `argv`, `status`, `exit`, `error`, `acknowledged` for all 16 skips and every candidate supersede (read directly). |
| S6 | `variant3d/.godot_queue/status.json` (`history`) | Authoritative unacked-failure set; used for the two-pass count verification in §6. |
| S7 | `docs/coord_swarm_2026-11-25/reports/QA_RUNNER_ARTIFACTS_01.md` | Cross-cutting audit of tickets 445–490: skip causes, output-file emptiness, owner→ticket mapping (§5), ok-job list (§3), and the note that 476 is the only final green rotor smoke (§7 Q4). |
| S8 | Owner reports: `MOTION_ANIM_01.md:213-221,252-259`, `CONFIG_WIRE_RELIEF.md:140-148`, `WEATHER_DRIVER_01.md:11,121-136`, `AUDIO_SEL_02.md:15,141,213`, `TERRAIN_DARK_FIX.md:16-18,163-178`, `SP_06_renderer_hook.md:236-237,344-353`, `QA_PARITY_01.md:37-44,62-77,95-113` | Documented PASS supersedes and skip incidents for the named owners. |
| S9 | `RECHECK_P0.md:34,177`, `QA_LINKS_02.md:48-49`, `GATE_READY_01.md:105-126,165-166` | Caveats: P0 capture discrepancy for 456/483/496; `DARKROW_ALL_01.md` and `SEASON_TEST_PATH_01.md` reports absent on disk; original 16-skip list corroboration. |

**Point-in-time caveat (`observed`):** the spool is still live. This read found
`status.json history total 497` and result JSONs up to ticket **507** — later than the
QA_CLEAN_02 snapshot (`history 480`, results through ~496). The 16 skipped tickets and
their error strings are unchanged, but see §7 Q1 for a *new* unacked `timed-out` entry
(ticket 494) that appeared after QA_CLEAN_02.

---

## 2. Method and verification of the 16

1. Took the 16 tickets from `QA_CLEAN_02.md §1.2` (`assert_clean.py --json` failure
   list) and §2.1 owner table.
2. Read each `results/<ticket:08d>.json`; all 16 have `status: "skipped"`,
   `exit: null`, `run: 0.0`, no `acknowledged` field, and an `error` string matching
   QA_CLEAN_02 verbatim (`observed`).
3. For each skip, selected a superseding job by (a) matching `argv` script, (b) later
   ticket / retry chain (`-r2`/`-r3`/`-r4`/`-r1` ids), and (c) an owner report or the
   cross-cutting runner audit that names the retry (`derived`).
4. Verified every candidate supersede directly in its result JSON: `status == "ok"`
   **and** `exit == 0` (`observed`). Two passes of the count were run; both agree (§6).
5. Where no later `ok`/exit 0 job with the same gate `argv` exists **anywhere in the
   result set**, the row is marked **UNRESOLVED** and no ack command is proposed.

**Label mapping of table columns:** ticket / job id / skip reason = `observed`;
owner ticket = `derived` (QA_RUNNER_ARTIFACTS_01.md §5, explicitly `observed` for
452/453 via QA_PARITY_01.md); superseding PASS job = `observed` status/exit + `derived`
mapping; evidence report = `observed`; recommended ack_reason = `derived`/`inferred`
(proposal only, not executed).

---

## 3. Sixteen-row mapping table

`PASS` column notation: `<ticket> <id> — ok/exit 0` (verified in the result JSON).
`—` in the PASS column means no superseding PASS job exists.

| # | Ticket | Job id | Owner ticket | Skip reason (verbatim from result JSON) | Superseding PASS job id / ticket | Evidence report | Recommended `ack_reason` string |
|---:|---:|---|---|---|---|---|---|
| 1 | 448 | `motionanim01-rotor-smoke` | MOTION-ANIM-01 | `ticket 448 was skipped (serving=464)`; wait 1825.52 s (`derived`: also wrongly cancelled by QA-PARITY-01 cleanup) | **476** `motionanim01-rotor-smoke-r3` — ok/0, same `--check-only world3d_entities.gd` argv | `MOTION_ANIM_01.md:213-221,252-259`; `QA_RUNNER_ARTIFACTS_01.md:57,85,275-276`; `results/00000476.json` | `Queue-wait supersession: ticket 448 skipped (serving=464) after QA-PARITY-01 cleanup cancel; no Godot ran. Superseded by 476 motionanim01-rotor-smoke-r3, same --check-only world3d_entities.gd smoke, ok exit 0, script_error_lines 0 (MOTION_ANIM_01.md:252-258).` |
| 2 | 449 | `configwirer-smoke` | CONFIG-WIRE-RELIEF | `ticket 449 waited > 1800s for its turn` (max-wait expiry; `derived`: cleanup cancel) | **464** `configwirer-smoke-r2` — ok/0, same `--check-only main.gd` argv | `CONFIG_WIRE_RELIEF.md:140-148`; `QA_RUNNER_ARTIFACTS_01.md:58,73`; `results/00000464.json` | `Max-wait expiry: ticket 449 waited >1800s after QA-PARITY-01 cleanup cancel; no Godot ran. Superseded by 464 configwirer-smoke-r2, same --check-only main.gd parse smoke, ok exit 0 (CONFIG_WIRE_RELIEF.md:142-148).` |
| 3 | 450 | `weatherdriver01-smoke` | WEATHER-DRIVER-01 | `ticket 450 was skipped (serving=461)`; wait 1773 s | **479** `weatherdriver01-smoke` — ok/0, same `--check-only world3d_fx.gd` argv (also **488** `weatherdriver01-smoke` — ok/0, `t_fx3d` PASS 13/13) | `WEATHER_DRIVER_01.md:11,121-136`; `QA_RUNNER_ARTIFACTS_01.md:59,88,97`; `results/00000479.json`, `00000488.json` | `Queue overtake: ticket 450 skipped (serving=461); no Godot ran. Superseded by 479 weatherdriver01-smoke, same --check-only world3d_fx.gd parse smoke, ok exit 0, 0 B stderr, 0 SCRIPT ERROR (WEATHER_DRIVER_01.md:11,128-136).` |
| 4 | 451 | `audiosel02-smoke` | AUDIO-SEL-02 | `ticket 451 waited > 600s for its turn` (max-wait expiry) | **487** `audiosel02-smoke` — ok/0, same `--check-only input_controller.gd` argv | `AUDIO_SEL_02.md:15,141,213`; `QA_RUNNER_ARTIFACTS_01.md:60,96`; `results/00000487.json` | `Max-wait expiry: ticket 451 waited >600s; no Godot ran. Superseded by 487 audiosel02-smoke, same --check-only input_controller.gd parse smoke, ok exit 0, 0 B stderr (AUDIO_SEL_02.md:15,141).` |
| 5 | 452 | `qaparity01-uitest` | QA-PARITY-01 | `ticket 452 was skipped (serving=461)`; wait 1755.91 s | **NONE — UNRESOLVED** | `QA_PARITY_01.md:40,44,62-81,95,120`; `QA_RUNNER_ARTIFACTS_01.md:61,247,249`; `results/00000452.json` | *No ack proposed.* See §5. |
| 6 | 453 | `qaparity01-selftest` | QA-PARITY-01 | `ticket 453 was skipped (serving=461)`; wait 1755.87 s | **NONE — UNRESOLVED** | `QA_PARITY_01.md:39,44,69-77,95,103,120`; `QA_RUNNER_ARTIFACTS_01.md:62,248`; `results/00000453.json` | *No ack proposed.* See §5. |
| 7 | 456 | `terraindarkfix2-p0` | TERRAIN-DARK-FIX | `ticket 456 was skipped (serving=461)`; wait 1638.9 s, no Godot, no PNG | **496** `terraindarkfix2-p0-r3` — ok/0, same `t_terrain_only.gd` P0 capture argv (483 r2 failed; 491 `terraindarkfix2-smoke` also ok/0 on `t_terrain3d.gd`) | `TERRAIN_DARK_FIX.md:16-18,163-178`; `QA_RUNNER_ARTIFACTS_01.md:65,92`; `results/00000496.json`; caveat `RECHECK_P0.md:34,177` | `Queue overtake: ticket 456 skipped (serving=461); no Godot ran, no PNG. Retry 483 failed (transient import collision); superseded by 496 terraindarkfix2-p0-r3, same t_terrain_only.gd P0 capture, ok exit 0, both gates PASS (TERRAIN_DARK_FIX.md:16-18,165,175-178).` |
| 8 | 457 | `sp06-sun-smoke` | SP-6 | `ticket 457 was skipped (serving=458)`; wait 1632.09 s | **480** `sp06-sun-smoke-r2` — ok/0, same `--check-only world3d_terrain.gd` argv | `SP_06_renderer_hook.md:236-237,344-353`; `QA_RUNNER_ARTIFACTS_01.md:66,89`; `results/00000480.json` | `Queue overtake: ticket 457 skipped (serving=458) after 1632s wait; no Godot ran. Superseded by 480 sp06-sun-smoke-r2, same --check-only world3d_terrain.gd smoke, ok exit 0, 0 B stderr (SP_06_renderer_hook.md:236-237,344-353).` |
| 9 | 458 | `motionanim01-rotor-smoke-r2` | MOTION-ANIM-01 | `ticket 458 was skipped (serving=461)`; wait 1519.4 s | **476** `motionanim01-rotor-smoke-r3` — ok/0, same `--check-only world3d_entities.gd` argv | `MOTION_ANIM_01.md:214-221,252-259`; `QA_RUNNER_ARTIFACTS_01.md:67,85,275-276`; `results/00000476.json` | `Queue overtake: ticket 458 (r2) skipped (serving=461); no Godot ran. Superseded by 476 motionanim01-rotor-smoke-r3, same --check-only world3d_entities.gd smoke, ok exit 0, script_error_lines 0 (MOTION_ANIM_01.md:215-221,252-258).` |
| 10 | 465 | `audiosel02-smoke` | AUDIO-SEL-02 | `ticket 465 was skipped (serving=475)`; wait 1102 s | **487** `audiosel02-smoke` — ok/0, same `--check-only input_controller.gd` argv | `AUDIO_SEL_02.md:15,141`; `QA_RUNNER_ARTIFACTS_01.md:74,96`; `results/00000487.json` | `Queue overtake: second audiosel02-smoke submission skipped (serving=475); no Godot ran. Superseded by 487 audiosel02-smoke, same --check-only input_controller.gd parse smoke, ok exit 0 (AUDIO_SEL_02.md:15,141).` |
| 11 | 466 | `seasonpath01-smoke` | SEASON-TEST-PATH-01 | `ticket 466 was skipped (serving=467)`; wait 812.4 s | **499** `seasonpath01-smoke-r4` — ok/0, same `--check-only t_season_overlay.gd` argv (484 r2 / 492 r3 failed) | `results/00000499.json`; `QA_RUNNER_ARTIFACTS_01.md:75,93`; `QA_LINKS_02.md:49` (owner report absent) | `Queue overtake: ticket 466 skipped (serving=467); no Godot ran. Retry chain 484/492 failed; superseded by 499 seasonpath01-smoke-r4, same --check-only t_season_overlay.gd smoke, ok exit 0 (results/00000499.json).` |
| 12 | 469 | `darkrowall-t_combo_shore_mines` | DARKROW-ALL-01 | `ticket 469 was skipped (serving=475)`; wait 445.6 s | **506** `darkrowall-t_combo_shore_mines-r1` — ok/0, same `--check-only t_combo_shore_mines.gd` argv | `results/00000506.json`; `QA_RUNNER_ARTIFACTS_01.md:78`; `TEST_C3_report.md:9,68`; `QA_LINKS_02.md:48` (owner report absent) | `Queue overtake: ticket 469 skipped (serving=475); no Godot ran. Superseded by 506 darkrowall-t_combo_shore_mines-r1, same --check-only t_combo_shore_mines.gd, ok exit 0 (results/00000506.json).` |
| 13 | 470 | `darkrowall-t_combo_trees_mines` | DARKROW-ALL-01 | `ticket 470 was skipped (serving=475)`; wait 440.2 s | **505** `darkrowall-t_combo_trees_mines-r1` — ok/0, same `--check-only t_combo_trees_mines.gd` argv | `results/00000505.json`; `QA_RUNNER_ARTIFACTS_01.md:79`; `TEST_C2_report.md:26,59`; `QA_LINKS_02.md:48` | `Queue overtake: ticket 470 skipped (serving=475); no Godot ran. Superseded by 505 darkrowall-t_combo_trees_mines-r1, same --check-only t_combo_trees_mines.gd, ok exit 0 (results/00000505.json).` |
| 14 | 471 | `darkrowall-t_terrain_shore` | DARKROW-ALL-01 | `ticket 471 was skipped (serving=475)`; wait 445.4 s | **493** `darkrowall-t_terrain_shore-r1` — ok/0, same `--check-only t_terrain_shore.gd` argv | `results/00000493.json`; `QA_RUNNER_ARTIFACTS_01.md:80`; `TEST_P2_report.md:20,55`; `QA_LINKS_02.md:48` | `Queue overtake: ticket 471 skipped (serving=475); no Godot ran. Superseded by 493 darkrowall-t_terrain_shore-r1, same --check-only t_terrain_shore.gd, ok exit 0 (results/00000493.json).` |
| 15 | 472 | `darkrowall-t_combo_all` | DARKROW-ALL-01 | `ticket 472 was skipped (serving=475)`; wait 439.6 s | **507** `darkrowall-t_combo_all-r1` — ok/0, same `--check-only t_combo_all.gd` argv | `results/00000507.json`; `QA_RUNNER_ARTIFACTS_01.md:81`; `TEST_C4_report.md:3,62`; `QA_LINKS_02.md:48` | `Queue overtake: ticket 472 skipped (serving=475); no Godot ran. Superseded by 507 darkrowall-t_combo_all-r1, same --check-only t_combo_all.gd, ok exit 0 (results/00000507.json).` |
| 16 | 473 | `darkrowall-t_terrain_trees` | DARKROW-ALL-01 | `ticket 473 was skipped (serving=475)`; wait 444.9 s | **486** `darkrowall-t_terrain_trees-r1` — ok/0, same `--check-only t_terrain_trees.gd` argv | `results/00000486.json`; `QA_RUNNER_ARTIFACTS_01.md:82,95,118-119`; `TEST_P1_report.md:20,56`; `QA_LINKS_02.md:48` | `Queue overtake: ticket 473 skipped (serving=475); no Godot ran. Superseded by 486 darkrowall-t_terrain_trees-r1, same --check-only t_terrain_trees.gd, ok exit 0 (QA_RUNNER_ARTIFACTS_01.md:95; results/00000486.json).` |

**Supersede verification (`observed`):** all 14 named PASS jobs were read directly as
`status: "ok"`, `exit: 0`, `error: null`, with an `argv` script identical to the skipped
job's (or, for 456, the identical `t_terrain_only.gd` capture argv). No supersede was
accepted on prose alone.

---

## 4. Exact ack commands — prepared, NOT executed

Prerequisite repeated: **do not run any of these while a job is pending or a Godot
process is alive.** COORD / the user owns execution. Each line is one command from the
project root, using Windows `python` (not `python3`), and matches the CLEAN-01 precedent.

```text
python variant3d\tools\godot_runner.py ack 448 --reason "Queue-wait supersession: ticket 448 skipped (serving=464) after QA-PARITY-01 cleanup cancel; no Godot ran. Superseded by 476 motionanim01-rotor-smoke-r3, same --check-only world3d_entities.gd smoke, ok exit 0, script_error_lines 0 (MOTION_ANIM_01.md:252-258)."
python variant3d\tools\godot_runner.py ack 449 --reason "Max-wait expiry: ticket 449 waited >1800s after QA-PARITY-01 cleanup cancel; no Godot ran. Superseded by 464 configwirer-smoke-r2, same --check-only main.gd parse smoke, ok exit 0 (CONFIG_WIRE_RELIEF.md:142-148)."
python variant3d\tools\godot_runner.py ack 450 --reason "Queue overtake: ticket 450 skipped (serving=461); no Godot ran. Superseded by 479 weatherdriver01-smoke, same --check-only world3d_fx.gd parse smoke, ok exit 0, 0 B stderr, 0 SCRIPT ERROR (WEATHER_DRIVER_01.md:11,128-136)."
python variant3d\tools\godot_runner.py ack 451 --reason "Max-wait expiry: ticket 451 waited >600s; no Godot ran. Superseded by 487 audiosel02-smoke, same --check-only input_controller.gd parse smoke, ok exit 0, 0 B stderr (AUDIO_SEL_02.md:15,141)."
python variant3d\tools\godot_runner.py ack 456 --reason "Queue overtake: ticket 456 skipped (serving=461); no Godot ran, no PNG. Retry 483 failed (transient import collision); superseded by 496 terraindarkfix2-p0-r3, same t_terrain_only.gd P0 capture, ok exit 0, both gates PASS (TERRAIN_DARK_FIX.md:16-18,165,175-178)."
python variant3d\tools\godot_runner.py ack 457 --reason "Queue overtake: ticket 457 skipped (serving=458) after 1632s wait; no Godot ran. Superseded by 480 sp06-sun-smoke-r2, same --check-only world3d_terrain.gd smoke, ok exit 0, 0 B stderr (SP_06_renderer_hook.md:236-237,344-353)."
python variant3d\tools\godot_runner.py ack 458 --reason "Queue overtake: ticket 458 (r2) skipped (serving=461); no Godot ran. Superseded by 476 motionanim01-rotor-smoke-r3, same --check-only world3d_entities.gd smoke, ok exit 0, script_error_lines 0 (MOTION_ANIM_01.md:215-221,252-258)."
python variant3d\tools\godot_runner.py ack 465 --reason "Queue overtake: second audiosel02-smoke submission skipped (serving=475); no Godot ran. Superseded by 487 audiosel02-smoke, same --check-only input_controller.gd parse smoke, ok exit 0 (AUDIO_SEL_02.md:15,141)."
python variant3d\tools\godot_runner.py ack 466 --reason "Queue overtake: ticket 466 skipped (serving=467); no Godot ran. Retry chain 484/492 failed; superseded by 499 seasonpath01-smoke-r4, same --check-only t_season_overlay.gd smoke, ok exit 0 (results/00000499.json)."
python variant3d\tools\godot_runner.py ack 469 --reason "Queue overtake: ticket 469 skipped (serving=475); no Godot ran. Superseded by 506 darkrowall-t_combo_shore_mines-r1, same --check-only t_combo_shore_mines.gd, ok exit 0 (results/00000506.json)."
python variant3d\tools\godot_runner.py ack 470 --reason "Queue overtake: ticket 470 skipped (serving=475); no Godot ran. Superseded by 505 darkrowall-t_combo_trees_mines-r1, same --check-only t_combo_trees_mines.gd, ok exit 0 (results/00000505.json)."
python variant3d\tools\godot_runner.py ack 471 --reason "Queue overtake: ticket 471 skipped (serving=475); no Godot ran. Superseded by 493 darkrowall-t_terrain_shore-r1, same --check-only t_terrain_shore.gd, ok exit 0 (results/00000493.json)."
python variant3d\tools\godot_runner.py ack 472 --reason "Queue overtake: ticket 472 skipped (serving=475); no Godot ran. Superseded by 507 darkrowall-t_combo_all-r1, same --check-only t_combo_all.gd, ok exit 0 (results/00000507.json)."
python variant3d\tools\godot_runner.py ack 473 --reason "Queue overtake: ticket 473 skipped (serving=475); no Godot ran. Superseded by 486 darkrowall-t_terrain_trees-r1, same --check-only t_terrain_trees.gd, ok exit 0 (QA_RUNNER_ARTIFACTS_01.md:95; results/00000486.json)."
```

That is **14** commands (the 2 UNRESOLVED rows are intentionally absent). `cmd_ack`
returns 0 and prints `ticket N acknowledged: <reason>` on success; exit 2 means no
result JSON for that ticket (S4). After any ack, `cmd_ack` also syncs the three ack
fields into `status.json` history — so execution **does** mutate runner state and must
be owned by COORD/user, never by this planning worker.

---

## 5. UNRESOLVED rows — no ack proposed

### 5.1 Ticket 452 — `qaparity01-uitest` (QA-PARITY-01)

- `observed`: result JSON `00000452.json` is `skipped`, `exit null`, `run 0.0`, error
  `ticket 452 was skipped (serving=461)`; no stdout/stderr files (QA_RUNNER_ARTIFACTS_01.md:61).
- `observed`: QA_PARITY_01.md:40,44 states the job never launched Godot; §5/§7 say the
  integrated `uitest.json` artifact was read green at **17/17** (§3.3, §5), and earlier
  ok/exit 0 jobs `313 cfg01-uitest`, `318 sel01-uitest`, `366 uitestanchor-uitest`,
  `440 configwireh-uitest` exist (QA_PARITY_01.md:51-55; QA_RUNNER_ARTIFACTS_01.md:242).
- `observed`: **no job after ticket 452 has `ok`/exit 0 with the argv
  `--ui-test variant3d/uitest.json`.** The later jobs with that argv are 482
  `mapsize01-uitest` (`failed`) and 494 `mapsmall01-json-uitest` (`timed-out`);
  446/447 have no result record at all.
- `derived`/`inferred`: the PASS evidence is an artifact read and *earlier* jobs, not a
  later retry that supersedes 452. COORD forbade QA-PARITY-01 from further submissions
  after the incident (QA_PARITY_01.md:97,111).
- **Verdict: UNRESOLVED under the task's rule ("no PASS supersede → do not propose an
  ack").** If COORD later accepts artifact-level 17/17 as sufficient, a reasonable
  reason would cite 440/366 and QA_PARITY_01.md:81 — but that is a policy decision,
  not a verified supersede, so no command is issued here.

### 5.2 Ticket 453 — `qaparity01-selftest` (QA-PARITY-01)

- `observed`: result JSON `00000453.json` is `skipped`, `exit null`, `run 0.0`, error
  `ticket 453 was skipped (serving=461)`; no stdout/stderr files.
- `observed`: QA_PARITY_01.md:71-77,103,121 read the **integrated** `selftest.json` twice
  as **28/29, failing `build`** → exit 1, explicitly **NOT** a green selftest gate.
- `observed`: **no job after ticket 453 has `ok`/exit 0 with the argv
  `--self-test variant3d/selftest.json`.** Later jobs with that argv are 455, 461, 481,
  485, 490 (all `failed`) and 494's sibling 485. `446/447` have no record.
- **Verdict: UNRESOLVED, and positively contradicted** — the closest integrated evidence
  is a FAIL, so there is no PASS supersede to cite. Ack only after a documented green
  integrated selftest lands and is verified ok/exit 0.

---

## 6. Count verification (twice, as requested)

**Pass 1 — `status.json history` (S6), read directly:**
- Unacked failure-status (`timed-out`/`error`/`skipped`) entries: **17** tickets
  `[448,449,450,451,452,453,456,457,458,465,466,469,470,471,472,473,494]`.
- Of those, `skipped`: **16** tickets `[448,449,450,451,452,453,456,457,458,465,466,469,470,471,472,473]`.
- This set is **exactly** the 16 tickets in QA_CLEAN_02.md §1.2/§2.1 → **match (true)**.
  The extra entry is ticket 494 `mapsmall01-json-uitest`, `timed-out`, exit −9, unacked —
  a *later* arrival, outside this task's 16 (see §7 Q1).

**Pass 2 — result JSONs (S5) cross-referenced to history:**
- Result JSONs with `status: skipped`, no `acknowledged` field, **and** a matching
  `status.json` history entry: **16** tickets, same set as above → **match (true)**.
  (Three more skipped result JSONs — 454 `minimapquad01-boot`, 462 `rotorasset01-import`,
  468 `audiosel02-drag` — have **no history entry**, per QA_RUNNER_ARTIFACTS_01.md:125-128,
  so they do not drive `assert_clean` and are not in scope.)
- Supersede verification: **14** of 16 have a directly verified `ok`/exit 0 PASS job
  (§3); **2** are UNRESOLVED (452, 453). **14 + 2 = 16** → **match**.

Both passes agree: **16 in scope, 14 resolved, 2 unresolved.**

---

## 7. Prerequisites and execution ownership

1. **Queue quiet is mandatory.** Per `variant3d/tools/CLEAN_GATE.md:99-103` and
   CLEAN-01 §4/§6, a meaningful gate verdict needs no pending jobs and no live Godot
   process. QA_CLEAN_02 found `pending = 6 [490…495]` and a live PID; later reads here
   show the spool has advanced to ticket 507. **Do not ack while any job is pending or
   any Godot process is alive.**
2. **COORD / user owns execution.** This worker prepared commands only. Running them
   mutates `results/*.json` and `status.json` (S4) and is explicitly out of this
   worker's exclusive output.
3. **Ack is hygiene, not a green claim.** An ack only makes `assert_clean.py` skip a
   failure-status entry while still counting it (S3/S4). It does not prove visual parity,
   a green selftest, or CLEAN.
4. **Re-run the gate after acks**, on a quiet queue, with a variant-spool-aware
   assertion: `variant3d/tools/assert_clean.py:34` was reported mis-wired to the
   **app** spool (CLEAN_01 §1, CLEAN-02 fix); a correct variant verdict needs that
   addressed or an equivalent direct variant-spool check.
5. **Acking these 16 will not by itself make history clean** if ticket 494 remains
   unacked `timed-out` (§6 Pass 1) or new failures arrive. COORD must re-evaluate the
   full unacked failure set at execution time.

---

## 8. Open questions

1. **(`observed`/`UNVERIFIED`)** Ticket **494** `mapsmall01-json-uitest` is now
   `timed-out`, exit −9, unacked in `status.json` — it appeared after QA_CLEAN_02's
   snapshot. Is it a separate transient to be acked/resubmitted by its owner
   (MAP-SMALL-01), and will more arrive? Acking only the 16 will leave history DIRTY.
2. **(`UNVERIFIED`)** Will QA-PARITY-01's 452/453 be resolved by a green integrated
   gate (uitest already 17/17 as an artifact; selftest 28/29 FAIL as of QA_PARITY_01.md),
   or will COORD accept artifact-level evidence and ack them with a policy reason?
   No ack is proposed here.
3. **(`UNVERIFIED`)** `DARKROW_ALL_01.md` and `SEASON_TEST_PATH_01.md` are **absent**
   (QA_LINKS_02.md:48-49). The 466/469–473 supersedes rest on result JSONs + the
   cross-cutting QA_RUNNER_ARTIFACTS_01.md + atom-authoring reports, not owner reports.
   Should owners land their reports before COORD acks those six rows?
4. **(`UNVERIFIED`)** Conflict on the 456 chain: TERRAIN_DARK_FIX.md:16-18,165,175-178
   says ticket 496 wrote a PNG and both gates PASS; RECHECK_P0.md:34,177 says no PNG
   was found for 456/483/496 and the final re-capture is pending. The ok/exit 0
   envelope of 496 is `observed` either way, but the capture claim should be settled
   before the ack reason is finalised if COORD wants artifact-level certainty.
5. **(`derived`)** Some superseded skips share one PASS job (448+458 → 476; 451+465 →
   487). Acking both duplicates is legitimate (each skipped entry is independently
   unacked), but COORD may prefer one consolidated reason string per owner.
6. **(`UNVERIFIED`)** The 3 skipped result JSONs without history entries (454, 462,
   468) remain a history/artifact inconsistency (QA_RUNNER_ARTIFACTS_01.md:265-267).
   They are not in the 16 and not gated; no action proposed.

---

## 9. Summary

- **No runner-state mutation was performed. No code edit. No donor access. Only this
  report was written.** All §4 commands are prepared text, not executed.
- Read QA_CLEAN_02.md, CLEAN_01_variant_clean.md, `variant3d/tools/CLEAN_GATE.md`
  (exit codes + ack section), and `godot_runner.py:cmd_ack` as required.
- Built a **16-row** table (tickets 448–473) mapping each unacked `skipped` job to its
  owner, exact skip reason, superseding PASS job, evidence report, and a concrete
  proposed `ack_reason` string.
- **14** rows have a directly verified `ok`/exit 0 PASS supersede with matching `argv`
  (476, 464, 479/488, 487, 496, 480, 499, 506, 505, 493, 507, 486); **2** rows
  (**452**, **453**, QA-PARITY-01) are **UNRESOLVED** — no later PASS supersede exists,
  and the integrated selftest near 453 is 28/29 FAIL.
- Provided **14 exact `python variant3d\tools\godot_runner.py ack <ticket> --reason
  "<text>"`** command lines, with the explicit warning that they **must not be run
  while jobs are pending / a Godot process is alive**, and that **COORD/user owns
  execution**.
- Counts verified twice (history pass and result-JSON pass): **16 in scope = 14
  resolved + 2 unresolved**. Noted the newer unacked `timed-out` ticket 494, which
  means acking these 16 alone will not sign CLEAN.
