# T6 QA LANE — live state (parent T6-QA)

Parent session: `ses_df8393adbffeE3AT4n1abIh5W1`. Protocol: `SWARM_OPS.md` §7
(recursive swarm), §5d (liveness), §3 (gates), §7.6 (acceptance ladder),
`app/tools/AGENT_PROTOCOL.md` §1b (queue waits are NOT hangs). Quality rules:
`SWARM_OPS.md` §5b-QUALITY — every claim labelled `observed` / `derived` /
`inferred`; no measured evidence = `UNVERIFIED`, never `PASS`.

This lane owns **piece-verdict aggregation**, the **integration gate desk**, and
**swarm liveness watch**. It keeps the T6 wave honest: pieces pass on evidence,
integrations pass gates, nobody is silently stuck.

> **Spawn mechanism (`observed` 2026-11-23):** the `subagent` tool named in the
> brief is not exposed in this runtime. Children are background OpenCode
> sessions started with
> `opencode run --agent general --model <model> --session <id> --auto --title <T> <prompt>`.
> Notifications arrive on child idle; the parent reads report files, pings by
> sessionID (`opencode run --session <id> ...`), and re-spawns on
> `opencode-go/muse-spark-1.3-contributor#high` after 2 failures or >20 min
> silence with no pending job and no reply. This matches the sibling WATER lane.
>
> **Model (`observed` 2026-11-23; COORDINATOR-ACCEPTED):** the originally
> prescribed `opencode/hy4-flash-free` returned `Free usage limit reached` for
> all three first spawn attempts (exit 1, `t6-q0{1,2,3}.log`). A two-message
> probe confirmed `opencode-go/beam-free` and `opencode-go/hy4-flash-free`
> work; children were respawned on **`opencode-go/hy4-flash-free`** with the
> same sessionIDs and prompts. The coordinator accepted this milestone and a
> new owner directive is now in `SWARM_OPS.md` §7.2: **use
> `opencode-go/hy4-flash-free` for ALL further QA-lane spawns.**
>
> **Host facts for every child prompt (`observed`, coordinator 2026-11-23):**
> use **`python`**, NOT `python3`; Blender is at
> `C:\Program Files\Blender Foundation\Blender 5.2\blender.exe`. The QA lane
> submits no Blender jobs, but these facts are carried into any follow-up.

## Owned / boundary

- Parent owns **only** `docs/t6/QA_LANE.md` (this file). It also *holds* the
  dashboard path `docs/t6/DASHBOARD.md`, but the generated file is written by
  Q01's tool.
- Children own only the files named in the ticket table below.
- READ-ONLY for this lane: `SWARM_BOARD.md`, `SWARM_OPS.md`,
  `docs/T6_WAVE_PLAN.md`, `app/tools/AGENT_PROTOCOL.md`, all engine code
  (`app/scripts/**`, `app/shaders/**`, `app/tools/bake_sprites.py`,
  `app/tools/terrain_piece_render.py`, `app/tools/unit_bakers/**`), all other
  lanes' docs (`docs/t6/TERRAIN*`, `UNITS*`, `WATER*`, `RUST*`, `RESEARCH*`) and
  their owned outputs, `docs/STATUS_*.md`.
- Donor `C:\Games\Cossacks 3` = private use, read-only, NEVER copy into repo.
- **Godot budget: ZERO jobs unless an integration gate is actually running.**
  Health/status/clean-gate commands do not launch Godot and are allowed.
  Every Godot launch (only at a granted integration) goes through
  `python app\tools\godot_runner.py run --id t6qa-<purpose> --timeout 300 -- <args>`
  with a shell timeout ≥ 300000 ms. Queue waits are not hangs; never
  re-submit a red gate blindly — read the report first and attribute parse
  errors to their owner (`SWARM_OPS.md` §5d.5).

## Ticket table

| ID | Micro-task | sessionID | State | Owned outputs | Evidence / gate |
|---|---|---|---|---|---|
| T6-Q01 | Piece-verdict registry / aggregator (plain Python) | `ses_t6q01_registry` | DONE / piece test PASS (2026-11-23) | `app/tools/t6_registry.py` (NEW), `docs/t6/DASHBOARD.md` (generated) | Report verified by parent (12.4 KB, claims labelled); `py_compile` + real run + `--out` all exit 0; conservative PASS demotion; ZERO Godot jobs |
| T6-Q02 | Integration gate desk — **IDLE-WATCH** (no integration granted) | `ses_t6q02_gate` | IDLE-WATCH / piece test PASS (2026-11-23) | `docs/t6/reports/T6-Q02.md` | Report verified by parent: 7 paths + negative control, 9-command dry-run, 0 Godot jobs (post-write `next_ticket` still 1056); resumes only on coordinator grant |
| T6-Q03 | Liveness watch — health / runner status / orphan check | `ses_t6q03_liveness` | SWEEP 4 DONE (2026-11-23); sweeps 1–4 verified, ~15 min cadence armed | `docs/t6/reports/T6-Q03.md` (append-only) | Sweeps 1–4 CLEAN after coordinator acks, no wedge, zero Godot jobs; board now lists QA DONE (reactivatable) |
| T6-Q04 | Independent C5 re-review of T6-T15 v4 (coordinator request) | parent-performed (no child) | DONE — evidence handed to coordinator (2026-11-23) | `docs/t6/QA_LANE.md` §T6-Q04 (this note) | Independent Python/Pillow re-measurement + visual compare read; ZERO Godot/Blender jobs; RED-clear ruling belongs to coordinator |

## Supervision log (parent keeps current)

- 2026-11-23: read `SWARM_OPS.md` §7/§3/§5d, `docs/T6_WAVE_PLAN.md`,
  `app/tools/AGENT_PROTOCOL.md`, `docs/STATUS_TESTS.md`, `worker_health.py`,
  `godot_runner.py`. Confirmed `docs/t6/` already holds sibling lane docs and
  21 piece manifests. `docs/t6/reports/` created (was absent).
- 2026-11-23: confirmed the `subagent` tool is unavailable; using background
  OpenCode sessions (same mechanism as sibling lanes) with explicit sessionIDs
  above. Q01 + Q03 spawned immediately; Q02 armed in IDLE-WATCH.
- 2026-11-23: tool-path reconnaissance for the Q02 dry-run (`observed`):
  `godot_runner.py`, `assert_clean.py`, `worker_health.py`, `scan_map.py`,
  `bake_bench.py`, `full_map_shot.py`, `extract_map.py` all exist. The geometry
  verifier is **`app/tools/terrain_geometry_verify.py`**; `geometry_verify.py`
  does NOT exist. `scan_map.py --dir DIR`; `terrain_geometry_verify.py --dump
  FILE.json [--baseline FILE.json] [--json]`.
- 2026-11-23: parent baseline health sweep run read-only (0 Godot jobs);
  findings recorded in §health.
- 2026-11-23: **Q02 idle piece test PASSED, went idle.** Parent read
  `docs/t6/reports/T6-Q02.md` (11796 B): all 7 tool paths + the missing
  `geometry_verify.py` negative control confirmed; 9-command `t6qa-*` dry-run
  with ≥300000 ms timeouts; bake-bench honesty contract captured; 0 jobs
  submitted (verified `next_ticket` unchanged at 1056). Filed OQ-1 (fresh dump
  source) and OQ-2 (DIRTY clean gate). **Parent resolved OQ-1** below.
- 2026-11-23: **Q03 sweep 1 DONE, went idle.** Parent read
  `docs/t6/reports/T6-Q03.md` (11449 B): three verbatim outputs with
  timestamps/exit codes, health table, wedge check, escalation section.
  Correctly treated `assert_clean.py` exit 1 / DIRTY as a valid verdict and
  marked the "all three exit 0" piece-test line **NOT MET** rather than faking
  a pass — accurate work. No live orphan, no wedge.
- 2026-11-23: **Q01 DONE, piece test PASS.** Parent read
  `docs/t6/reports/T6-Q01.md` (12377 B) and independently re-ran
  `python -m py_compile app/tools/t6_registry.py` (exit 0) and
  `python app\tools\t6_registry.py` (exit 0). Live scan: 43 tickets, 7 reports,
  23 manifests, 49 rows, `unmatched_reports=0`, 9 parse anomalies recorded.
  Reports with no matching ticket: none. No Godot jobs, no engine files.
  Parent rulings on Q01's open questions recorded in §Dashboard refresh.
- 2026-11-23: **Q02 OQ-1 addendum landed** — row 4a/4b corrected in its own
  report, OQ-1 marked RESOLVED, backup `T6-Q02.md.bak-T6-Q02` created, still
  IDLE-WATCH, `next_ticket` unchanged (1056) → 0 Godot jobs.
- 2026-11-23: **Q03 sweep 2 landed** — clean gate recheck CLEAN (exit 0,
  acknowledged=12, failures=[]), appended to its append-only log; no ack by
  this lane, 0 Godot jobs.
- 2026-11-23: **COORDINATOR directive received** — (a) milestone accepted;
  keep all spawns on `opencode-go/hy4-flash-free`; (b) clean gate RESOLVED by
  coordinator `ack` of the 12 timed-out jobs with per-ticket reasons —
  `assert_clean.py` now CLEAN (coordinator-verified); Q03 asked to re-run and
  append sweep 2, this lane must NOT re-ack; (c) Q02 idle-watch confirmed
  correct; (d) host facts `python` not `python3`, Blender at the path above.
- 2026-11-23: **Q03 sweep 4 completed via the 900 s timer** — full cycle exit
  0, CLEAN, no wedge; board now marks QA `DONE (reactivatable)`; worker_health
  correctly drops DONE owners (not a lost worker). Consolidated in §health.
- 2026-11-23: **COORDINATOR re-review request (T6-T15 C5)** — TERRAIN's v4
  claims v3's FAIL was a 512²-vs-200² sampling artefact. QA parent performed
  the independent re-measurement directly (no child re-measured its own work).
  Verdict in §T6-Q04 below; ZERO Godot jobs.
- 2026-11-23: **COORDINATOR close-out directive** — both escalations received
  and routed: T6-T15 genuine FAIL to TERRAIN parent (keep iterating, no
  self-pass on C5); R05 ticket-id mismatch to RUST parent; conservative
  UNVERIFIED handling of U03/U05 endorsed. **Standing orders:** resume Q03
  for periodic liveness sweeps at ~15 min cadence while the wave is active;
  refresh the dashboard when new reports land; keep the integration-request
  watch; when an `INTEGRATION REQUEST` lands, this desk runs the full
  acceptance suite per Q02's command table. Implemented: Q03 scheduled via a
  background 900 s timer that resumes `ses_t6q03_liveness` with the generic
  periodic sweep prompt (`t6-q03-periodic.txt`); each completion notifies the
  parent, who verifies and refreshes.

### Escalation state

- Q01: 0 failures, DONE. Q02: 0 failures (idle piece test PASS, addendum
  landed). Q03: 0 failures (sweeps 1–3 verified). No re-spawn needed. All three
  are well under the 2-failure / 20-min-silence trigger.
- Re-spawn trigger: 2 failures on the same micro-task, or >20 min silence with
  no pending job and no reply, on `opencode-go/muse-spark-1.3-contributor#high`
  with the failed attempt's report attached.

## §health — liveness log (from Q03, parent consolidates)

_Parent consolidates each observed STALLED flag and the clean-gate verdict
here with a timestamp; Q03's verbatim sweeps live in its report._

- **2026-11-23, parent baseline (`observed`, read-only, 0 Godot jobs):**
  - `worker_health.py --stall-min 10`: all six lane parents `ALIVE`
    (`files=0`, no owned-file mtimes resolved from the board, no pending jobs);
    only `unassigned (gated)` flagged `STALLED` (last owned-file edit ~2392 min
    ago). **Interpretation (`derived`):** `unassigned (gated)` is a board
    placeholder for gated work, NOT a live worker — do not escalate it.
  - `godot_runner.py status`: `now_serving=1056`, `next_ticket=1056`,
    `pending=0`, `godot.lock=free`; 500 completed, max wait 607.89 s, mean
    31.58 s, max run 386.34 s; statuses 438 ok / 50 failed / 12 timed-out.
    **Queue is idle, not wedged** (`now_serving == next_ticket`, lock free).
  - `assert_clean.py --json`: exit 1, verdict **DIRTY** — `processes.clean=true
    (count 0)`, `lock.state=free`, but `history` reports 12 unacknowledged
    `timed-out` jobs (tickets 752/754/756/758/815/865/969/975/978/979/983/1037).
    **This is pre-existing historical state, not QA-lane breakage.** Only the
    coordinator may `ack` it; this lane will not ack, reset or unwedge. At the
    next integration gate, record this as a gate blocker for the coordinator
    rather than re-running blindly.

- **2026-11-23 sweep 1, from Q03's report (`observed` / `derived`):** window
  10:45:21–10:46:08 +01:00. Same three verbatim outputs as the parent baseline
  (cmds 1 & 2 exit 0; cmd 3 exit 1 by design). `now_serving == next_ticket ==
  1056`, jobs dir empty, no lock, 0 Godot processes → **normal idle queue, NOT
  the wedge signature**. `unassigned (gated)` STALLED (2392.2 min quiet) maps
  to `SWARM_BOARD.md:650,653,655` tickets T6-T90/U90/W04 (BLOCKED) — a
  placeholder, not a live worker; **informational, no ping/reassignment**.
  All six lane parents show `ALIVE` only because `quiet_min` is `None`;
  (`inferred`) that is a tool default, so their liveness is `UNVERIFIED` by
  this signal, not proven activity. Escalation to parent: none for wedge or
  parse errors. Orphan/clean verdict: **DIRTY**, 0 processes, lock free.

- **2026-11-23 sweep 2, Q03 recheck after coordinator acks (`observed`):**
  `python app\tools\assert_clean.py --json` exit **0**, verdict **CLEAN** —
  0 orphan processes, `godot.lock` free, history `acknowledged=12`,
  `failures=[]`. Timestamp 10:53:37–10:53:49 +01:00, verbatim JSON appended
  to `docs/t6/reports/T6-Q03.md` under "Sweep 2". Only that read-only command
  was run; this lane acked nothing, zero Godot jobs. **Sweep 1 DIRTY is
  resolved** — integration gates are no longer blocked by clean-gate state.

- **2026-11-23 sweep 3, Q03 periodic full cycle (`observed`):** all three
  commands exit 0. `T6-QA parent` now shows a positive activity signal
  (last owned-file edit 8.9 min, 1 file -> ALIVE); the other five lane parents
  remain `ALIVE` by default with no activity signal (liveness `UNVERIFIED` by
  this tool). `unassigned (gated)` STALLED 2410.1 min - the same gated
  placeholder, informational. `now_serving = next_ticket = 1056`, 0 pending,
  free lock, 0 procs -> idle queue, no wedge. Clean gate still **CLEAN**
  (`acknowledged=12`, `failures=[]`). No parse-failure attribution. ZERO
  Godot jobs; no ack/reset/unwedge/cancel/doctor/run calls.

- **2026-11-23 sweep 4, Q03 periodic cycle via 900 s timer (`observed`):**
  all three commands exit 0; CLEAN (0 orphans, lock free, `acknowledged=12`,
  `failures=[]`), `now_serving = next_ticket = 1056`, 0 pending, no wedge.
  `T6-QA parent` and `T6-RESEARCH` no longer appear in `worker_health.py`
  because the board marks both **DONE** (QA = "DONE (reactivatable)") and the
  tool scans only IN_PROGRESS/BLOCKED/ASSIGNED — an expected state change,
  not a lost worker. RUST/TERRAIN/UNITS/WATER parents remain ALIVE by default
  with no activity signal (liveness `UNVERIFIED` by this tool).
  `unassigned (gated)` STALLED 2434.2 min — same placeholder. ZERO Godot jobs.

## §gate-readiness notes (for Q02 when triggered)

- ~~(`observed` 2026-11-23) Clean gate DIRTY for 12 historical timeouts.~~
  **RESOLVED by coordinator (2026-11-23):** all 12 `timed-out` jobs were
  acked with per-ticket reasons (6× environment-wide `--check-only` hangs;
  `t2gen2-selftest8` superseded by T2 GEN green gates; `t5gen-v2-d7/d8/d9`
  superseded by T5-GEN green gates 1016/1022–1025; `m0-3d-terrain` and
  `terrain3d_m05_a` from the CLOSED 3D branch). `assert_clean.py` now returns
  CLEAN (coordinator-verified). Q03 appended sweep 2 as the durable evidence
  (§health); **this lane did not ack anything**. Q02 must still report a red
  gate rather than re-run the suite to "make it green".
- (`observed` 2026-11-23) Runner is idle (0 pending, lock free), so gate jobs
  would not contend — but **do not submit any** until an integration request is
  actually granted.
- **OQ-1 RESOLVED by parent (`observed` 2026-11-23):** the fresh dump for
  `scan_map.py` is **NOT** produced by `extract_map.py` (that tool extracts
  donor `.map` ASCII placements). `scan_map.py:4-6` states every dump comes from
  `godot --headless --path app -- --dump-map FILE --seed N`; `GUIDE4.md:72,534`
  and `TERRAIN_SANDBOX_PLAN.md:146` confirm. Since this is a Godot launch, at
  trigger Q02 must use the runner:
  `python app\tools\godot_runner.py run --id t6qa-dump --timeout 300 -- --headless --path app -- --dump-map app\shots\t6qa_dumps\dump_<seed>.json --seed <seed>`
  then `python app\tools\scan_map.py --dir app\shots\t6qa_dumps` (dedicated dir
  so only the fresh dump is scanned). This is a gate job, legal only after a
  granted integration; **zero jobs now**. Q02 was asked to append this as an
  addendum to its own report.

## §integration-requests — seen by this desk

_An INTEGRATION REQUEST is a section titled exactly `INTEGRATION REQUEST` in a
lane doc, naming the shared file + exact changes + piece PASS evidence. Until
one appears, Q02 stays IDLE-WATCH and no Godot job is submitted._

- 2026-11-23 initial scan (`observed`): **none**. Gated rows exist but no
  request has been filed:
  - `WATER_LANE.md:35` — T6-W04 "INTEGRATION — GATED. DO NOT START", blocked on
    W01 verification + W02 PASS.
  - `T6_WAVE_PLAN.md:117` — T6-T90, granted only after ≥12/15 terrain pieces
    PASS + owner visual review.
  - `T6_WAVE_PLAN.md:139` — T6-U90, gated on verified staging sheets.
  - No TERRAIN/UNITS lane doc had been filed at scan time.
- 2026-11-23 Q02's independent re-scan (`observed`, `T6-Q02.md` §1): still
  **none**. Adds: `TERRAIN_LANE.md:36,40` T6-T90 "NOT OPEN", 0/15 pieces PASS;
  `UNITS_LANE.md:48` T6-U90 "not started". Two independent scans agree — no
  request has landed, so Q02 correctly remains IDLE-WATCH.
- 2026-11-23 parent periodic re-scan (`observed`): grep for the exact heading
  across `docs/t6/**` returns only the WATER gated row, TERRAIN's
  "section will be written here when ≥12/15 PASS" note (currently **0/15
  PASS**), and QA/Q02's own definitions. **Three independent scans agree —
  still none.** Q02 stays IDLE-WATCH; no Godot job.
- 2026-11-23 latest watch (after coordinator close-out): heading scan across
  `docs/t6/**` returns **no** `## INTEGRATION REQUEST` section. The gate desk
  stays armed; Q02's session `ses_t6q02_gate` is resumed only on a filed
  request naming the shared file + exact changes + piece PASS evidence.

## Escalation requests to coordinator (parent writes; coordinator acts)

- **CLOSED 2026-11-23 — clean gate DIRTY (12 unacknowledged timeouts).**
  Coordinator investigated and `ack`-ed tickets 752/754/756/758/815/865/969/
  975/978/979/983/1037 with per-ticket reasons; `assert_clean.py` now CLEAN
  (coordinator-verified). No further action required from this lane; Q03
  appended sweep 2 as the durable evidence. Gate blocker removed.
- **2026-11-23 | QA | liveness tool | `unassigned (gated)` STALLED** —
  `worker_health.py` flags a board placeholder for BLOCKED T90/U90/W04, not a
  live worker. Evidence: `docs/t6/reports/T6-Q03.md` sweep 1. **Request:**
  informational only; parent ruling = note as informational, do NOT ping or
  reassign, and do NOT edit `worker_health.py` (not ours to change).

- **2026-11-23 | QA aggregation | T6-T15 | piece verdict FAIL** —
  `docs/t6/reports/T6-T15.md` (desert_variant, 8P/1F/1U) shows dashboard State
  FAIL. Evidence: `docs/t6/DASHBOARD.md` (10:05:40Z refresh). **Request:**
  coordinator to route to TERRAIN parent; QA does not re-run/revert and will
  not sign any integration while a piece is red.
- **2026-11-23 | QA aggregation | T6-R05 | reports have no lane row** —
  `T6-R05-AAF.md` (PASS), `T6-R05-OSM.md` (PASS) and `T6-R05-OSS.md` (FAIL)
  all parse ticket `T6-R05`, absent from the RUST lane table. Evidence:
  dashboard 10:12:16Z "Reports with no matching lane ticket". **Request:**
  coordinator/RUST parent to reconcile the ticket id; QA leaves them visible
  and unassigned rather than inventing a ticket.
- **2026-11-23 | QA aggregation | RUST `assets_dds` | external test FAIL** —
  `docs/t6/reports/T6-R05-OSS.md` A10: sibling `tests/assets_dds.rs::
  synthetic_partial_edge_block` fails repo-wide (1 failed / 6 passed); the
  report's own gate A7 is PASS. **Request:** route to the DDS test's owner,
  NOT the OSS worker (SWARM_OPS §5d.5 attribution rule). QA will not revert
  or re-run either worker's code.

Format for future entries: `timestamp | lane | ticket | symptom | evidence
path | requested unblock (grant file / resolve parse error / reassign)`.
Never take over another worker's in-progress edit to "help".

## Dashboard refresh

`docs/t6/DASHBOARD.md` is regenerated by
`python app\tools\t6_registry.py` (Q01's owned tool) as reports land. The
parent runs it at supervision milestones and records the run + row counts here.

- **2026-11-23 first generation (Q01 piece test):** `py_compile` exit 0,
  `python app\tools\t6_registry.py` exit 0; dashboard created with timestamp,
  21→23 manifests represented, all 5→6 reports covered.
- **2026-11-23 parent refresh at Q01 DONE milestone (`observed`):** reran
  `python -m py_compile app/tools/t6_registry.py` → exit 0;
  `python app\tools\t6_registry.py` → exit 0,
  `tickets=43 reports=7 manifests=23 rows=49 unmatched_reports=0 anomalies=9`,
  dashboard header `Generated: 2026-11-23T10:00:58Z`; backup refreshed at
  `inbox\backup\DASHBOARD.md.bak-T6-Q01`. Input churn (1 more report since
  Q01's final run) is other lanes writing live — the tool rescans on each run.

- **2026-11-23 periodic refresh after Q03 sweep 3 (`observed`):** registry
  exit 0, `tickets=43 reports=12 manifests=23 rows=49 unmatched_reports=1
  anomalies=18`; dashboard `Generated: 2026-11-23T10:05:40Z`; backup refreshed.
  Report count grew 7 -> 12 as sibling lanes landed work.
- **2026-11-23 refresh after coordinator routing (`observed`):** registry exit
  0, `tickets=43 reports=22 manifests=23 rows=49 unmatched_reports=3
  anomalies=34`; dashboard `Generated: 2026-11-23T10:12:16Z`; backup refreshed.
  T6-T15 lane row now reads "**RED / QA FAIL - iterating**" — the coordinator's
  routing reached TERRAIN. Report count 12 -> 22 as sibling lanes landed work.
- **2026-11-23 refresh after T6-Q04 re-review (`observed`):** registry exit 0,
  `tickets=44 reports=31 manifests=26 rows=50 unmatched_reports=4
  anomalies=42`; dashboard `Generated: 2026-11-23T10:33:27Z`; backup refreshed.
  State changes noted in "Piece-verdict watch" above.

### Piece-verdict watch (parent reads dashboard at each refresh)

- **`T6-T15` TERRAIN `desert_variant` = FAIL** (`docs/t6/reports/T6-T15.md`,
  8 PASS / 1 FAIL / 1 UNVER; dashboard "State = FAIL"). Parent read the report
  (`observed`): the FAIL is **genuine and measured**, criterion C5 grain in
  the cracked sub-band (not a parse error; report summary itself says
  "9 PASS + 1 marginal PASS + 1 FAIL + 1 UNVERIFIED"). This is a **piece
  verdict, not a QA gate** — it belongs to the TERRAIN lane owner. Per
  `SWARM_OPS.md` §5d.5 QA does **not** re-run it, revert it, or promote it.
  Flagged to the coordinator for the TERRAIN parent. T6-T90 integration stays
  blocked (TERRAIN still well below the >=12/15 PASS grant condition).
- **`T6-R05-*` reports unmatched (now 3)** — `T6-R05-AAF.md` (PASS),
  `T6-R05-OSM.md` (PASS), `T6-R05-OSS.md` (FAIL); all parse ticket `T6-R05`,
  but no matching `T6-R05` row exists in the RUST lane doc (it was dropped
  earlier). The dashboard lists all three under "Reports with no matching
  lane ticket" rather than dropping them. RUST lane to reconcile; QA edits no
  RUST file.
  - **Do NOT mis-attribute the OSS FAIL (`observed`, parent read the report):**
    its own gate A7 is **PASS** (`cargo test --test assets_oss`: 5 passed, 0
    failed). The FAIL is criterion A10, explicitly **informational/external**:
    sibling `tests/assets_dds.rs::synthetic_partial_edge_block` fails in a
    repo-wide `cargo test` (6 passed / 1 failed). Per `SWARM_OPS.md` §5d.5 the
    failure belongs to the **DDS test's owner**, not the OSS worker; QA does
    not treat it as a T6-R05 gate failure. Routed below.
- **`T6-U03.md` / `T6-U05.md`** have no structured acceptance verdict rows, so
  they stay `UNVERIFIED` (not promoted) — same conservative rule as Q01's
  ruling 1 and 2.
- **2026-11-23 refresh at 10:33:27Z (`observed`):** registry exit 0,
  `tickets=44 reports=31 manifests=26 rows=50 unmatched_reports=4
  anomalies=42`. New state changes from other lanes:
  - `T6-T15` lane row now reads "**RED - two conditions pending**", report
    verdict UNVERIFIED (9 PASS / 0 FAIL / 1 UNVER). My §T6-Q04 evidence
    addresses the C5 condition; the second condition is not QA's to close.
  - `T6-T02` and `T6-T12` show FAIL report verdicts with lane state
    "**REVOKED by coordinator**" — already handled by the coordinator, so QA
    takes no action; the registry correctly keeps the FAIL visible rather
    than erasing the evidence.
  - Unmatched reports are now four `T6-R05-*` (AAF/PASS, DDS/PASS, OSM/PASS,
    OSS/FAIL) — the RUST ticket-id reconciliation escalation still stands.

### Parent rulings on Q01's open questions

1. **Lane-declared PASS with an incomplete report → keep `UNVERIFIED`.**
   Correct under `SWARM_OPS.md` §5b-QUALITY (unmeasurable = UNVERIFIED, not
   done). Dashboard's anomaly list records the divergence; do not promote.
2. **Do not parse prose-only gate statements (T6-W01).** Agreed — parsing
   narrative would risk inventing a verdict. Leave UNVERIFIED until that
   report carries a structured verdict table.
3. **Two `ravine_face` manifests → TERRAIN lane decides canonical.** QA does
   not arbitrate another lane's piece identity; both are shown verbatim.
4. **FAIL path untested** — accepted limitation until a FAIL report exists;
   the rule (any FAIL → FAIL) is documented in the dashboard honesty contract.

## T6-Q04 — independent C5 re-review (coordinator request, 2026-11-23)

TERRAIN's `docs/t6/reports/T6-T15.md` v4 claims the v3 C5 FAIL (cracked
sub-band hi-freq ~7.1 vs band 8–9) was a **512²-vs-200² sampling artefact**,
and reports v4 donor 8.42 / render 8.66 at A8 opacity 0.80, dark coverage
10.97%. TERRAIN verified but did not self-clear the RED flag. The coordinator
asked QA to **independently** re-measure and check the visual sheet. Performed
by the QA lane parent (second agent, not the T15 worker). ZERO Godot jobs,
ZERO Blender jobs, pure Python 3.14.3 / Pillow 12.1.1 / NumPy 2.4.3. No donor
asset was copied into the repo (DDS files were read in place).

### Method — re-derived independently from the documented procedure

Own implementation of the metric (`temp/t6_qa_c5_recheck.py`), **not** the T15
probe's `hf()` helper: resize to 200² with bilinear; `L = PIL.convert("L")`;
`B = L.filter(GaussianBlur(5))`; `hi-freq = mean(|L − B|)`.
- Donor tiles `C:\Games\Cossacks 3\data\terrain\tiles\textures\desert{2,3,4,5,6}.dds`,
  full tile `[0,0,1024,1024]` → 200², plus a `[0,0,512,512]` crop control.
- Patch interior: documented mask `dv._organic_patch_mask(512,512,19)` from
  the shipped module, resized to 200² bilinear, `mask > 220`. The module was
  used **only** for the documented mask, never for the metric.
- Artifact integrity (`observed`): shipped render SHA-256 `676ea593…`, compare
  sheet `645acfd2…`, module `ceeaab63…` — all exactly match T6-T15.md v4's
  owned-output table.

### Independent measurements (`observed`, my own script; report value in brackets)

| Sample | My 200² hi-freq | My 512² native | Report |
|---|---:|---:|---|
| donor `desert2.dds` full tile | **8.42** | — | 8.42 ✓ |
| donor `desert3.dds` full tile | **8.42** | — | 8.42 ✓ |
| donor `desert4` / `desert5` | 7.35 / 7.35 | — | 7.35 / 7.35 ✓ |
| donor `desert6` (base) | 2.27 | — | 2.27 ✓ |
| donor `desert2` crop `[0,0,512,512]` → 200² | 8.19 | — | (port-side control 8.19) ✓ |
| v3-equivalent render (op 0.85) patch interior | **9.21** (whole 5.00) | **7.03** (whole 4.97) | corrected 9.21; v3 prose ~7.1 ✓ |
| v4 shipped render (op 0.80) patch interior | **8.66** (whole **4.82**) | 6.66 (whole 4.86) | 8.66 / 4.82 ✓ |
| v4 dark coverage `L<90` | **10.97%** | — | 10.97% ✓ |

Mask interior coverage: 12.94% at 200², 13.28% at 512² (source core 14.22%).
Scale ratio (512²/200² interior hi-freq): **0.763 (v3)** / **0.769 (v4)**.

### Verdict on the three questions

1. **Method-artefact explanation — CONFIRMED (`derived` from `observed`).**
   The identical v3-equivalent image measures 7.03 at native 512² but 9.21 at
   200² — a **24% scale-induced drop** with no recipe change. The v3 FAIL was
   therefore a measurement-scale mismatch against a 200² donor anchor, not a
   demonstrated grain deficit. Minor reconciliation: the report's prose "~7.1"
   used a differently eroded sub-band; my non-eroded 512² interior is 7.03 and
   a 3 px-eroded variant is 6.31. The exact v3 digit depends on sub-band
   definition; the scale effect is decisive and directionally identical.
2. **v4 numbers — CONFIRMED (`observed`).** Donor desert2/3 reproduced at
   8.42 exactly, desert4/5 at 7.35, base desert6 at 2.27; v4 interior 8.66 sits
   **inside the unchanged 8–9 band**, whole-frame 4.82 inside 3–9, dark
   coverage 10.97% ≤ 25%. The C5 target text in the report still reads
   `cracked 8–9` — **no threshold weakening** (`observed`).
3. **Visual compare sheet — checked with the `read` tool (`observed`).**
   Left panel: olive-khaki ground with irregular clustered cracked/scree
   patches and hairline cracks, **no repeated identical rectangular stamps or
   lattice**; one dry gray boulder near centre with a soft contact shadow,
   visually grounded rather than floating. Right panel: vertical **orange-tan
   wooden siding** with a dark seam and a metallic object at the bottom —
   visually **not ground terrain**. Keeping the donor palette authoritative
   and not tuning to that crop is justified (`inferred` from the observed
   panels). The port remains cooler/darker than the wooden reference — a known
   stylistic gap, not a C5 criterion failure.

### Recommendation to coordinator (NOT a final ruling)

Evidence supports **clearing T6-T15's RED flag on C5**: the donor anchor was
reproduced independently, the corrective method was validated, v4's 8.66 is
inside an unweakened 8–9 band, and the visual defects originally reported are
gone. QA does **not** self-clear; the coordinator makes the RED-clear ruling
and decides whether T15 counts toward the ≥12/15 integration grant.
One sub-item stays **UNVERIFIED**: the QA-P1 250 ms **engine** bake — this
review was pure Python and cannot measure it; that belongs to T6-T90.

Evidence: `temp/t6_qa_c5_recheck.py`, `temp/t6_qa_c5_erode.py` (independent
scripts, temp only), `docs/t6/reports/T6-T15.md` v4, shipped render/compare
hashes above.

---

**Related:** `docs/T6_WAVE_PLAN.md` §2/§7.6 · `SWARM_OPS.md` §3/§5d/§7 ·
`app/tools/AGENT_PROTOCOL.md` §1b · `docs/STATUS_TESTS.md` ·
`docs/t6/DASHBOARD.md` · `docs/t6/reports/T6-Q0{1,2,3}.md`
