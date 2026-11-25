---
id: FINAL-CHECKLIST-01
title: "Sign-off checklist — 2026-11-25 3D variant work"
area: coordination / sign-off
owner: FINAL-CHECKLIST-01 (documentation worker; session ses_dedbedaf9ffejr3WE6IIQbhDuF)
date: 2026-11-25
status: READ_ONLY__TWO_FILES_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB__FINAL_REFRESH_02_APPLIED
refreshed_by: "FINAL-CHECK-REFRESH-02 (documentation repair worker; this file + reports/FINAL_CHECK_REFRESH_02.md only)"
refresh_date: 2026-11-25
scope: "Only this file and reports/FINAL_CHECK_REFRESH_02.md were written by this refresh. No .gd/.gdshader/config/test/fixture/result-JSON/git/queue edit; no Godot job submitted, cancelled, reset, unwedged or acked; no donor access. Read-only file reads only in this pass — the nine task-listed reports, README.md, SWARM_BOARD.md, CORRECTIONS.md and the prior FINAL_CHECK_REFRESH_01.md; no runner/clean poll was issued by this worker, all runner numbers are cited from the named reports."
labels: [observed, derived, inferred, UNVERIFIED]
verdict: NOT_READY_FOR_FINAL_GATE
snapshot_caveat: "All runner numbers, session states and job ids are point-in-time snapshots from the cited reports/live reads; the queue is churning. Newest read-only polls are in R/QA_GATE_READY_02.md:11,46-120: godot_runner.py status moved now_serving 516→521, next_ticket 523→524, pending 7 [516…522]→3 [521…523], lock HELD (237.2 s→38.2 s); assert_clean.py --json stayed DIRTY/exit 1 with 17→18 unacked failure-status jobs (16 skipped + ticket 494 timed-out + ticket 516 timed-out) and one live Godot (PID 8984→11292). Earlier FINAL-CHECK-REFRESH-01 poll: now_serving=515, next_ticket=516, pending=1 [515], lock HELD 33.2 s, 17 unacked; QA_FINAL_02.md:95-96 saw a momentary drain at 11:51:50 (pending=0, lock free, 0 Godot). Report mtimes at that earlier read: QA_PARITY_01.md 11:23:46, QA_ATOM_RESULTS_01.md 11:22:30, GATE_READY_01.md 11:26:32, QA_DOCS_02.md 11:27:50, TERRAIN_DARK_FIX.md 11:38:09, MAP_SMALL_01_report.md 11:38:53, RECHECK_P0.md 11:36:47, RECHECK_S1.md 11:39:13, RECHECK_P0_FINAL.md 11:45:29, P0_FRESH_CAPTURE_01.md 11:42:31, README.md 11:52:23; DARKROW_ALL_01.md was ABSENT at that read. Conflicts are recorded explicitly, not resolved by assertion. No fresh poll by this refresh."
sources_read:
  - docs/coord_swarm_2026-11-25/reports/FINAL_GATE_PLAN_01.md
  - docs/coord_swarm_2026-11-25/reports/GATE_READY_01.md
  - docs/coord_swarm_2026-11-25/reports/QA_PARITY_01.md
  - docs/coord_swarm_2026-11-25/reports/QA_ATOM_RESULTS_01.md
  - docs/coord_swarm_2026-11-25/reports/QA_DOCS_02.md
  - docs/coord_swarm_2026-11-25/CORRECTIONS.md
  - docs/coord_swarm_2026-11-25/TEST_MATRIX.md
  - docs/coord_swarm_2026-11-25/CAPTURE_RECHECK.md
  - docs/coord_swarm_2026-11-25/SWARM_BOARD.md (live-session section §"LIVE SESSION STATUS" and all ticket rows)
  - docs/coord_swarm_2026-11-25/PROGRESS.md
  - docs/coord_swarm_2026-11-25/reports/ reports directory listing (read-only)
  - variant3d/selftest.json, variant3d/uitest.json (read-only)
  - docs/coord_swarm_2026-11-25/reports/QA_FINAL_02.md
  - docs/coord_swarm_2026-11-25/reports/P0_FRESH_CAPTURE_01.md
  - docs/coord_swarm_2026-11-25/reports/RECHECK_P0.md, RECHECK_P0_FINAL.md, RECHECK_S1.md
  - docs/coord_swarm_2026-11-25/reports/MAP_SMALL_01_report.md, TERRAIN_DARK_FIX.md
  - docs/coord_swarm_2026-11-25/README.md, SWARM_BOARD.md, PROGRESS.md (re-read for citation drift)
  - read-only `python variant3d\\tools\\godot_runner.py status` and `python variant3d\\tools\\assert_clean.py --json` polls (FINAL-CHECK-REFRESH-01)
  - docs/coord_swarm_2026-11-25/reports/FINAL_CHECK_REFRESH_01.md (prior refresh report, re-read)
  - docs/coord_swarm_2026-11-25/reports/QA_GATE_READY_02.md, QA_2D_GATES_01.md, QA_SPEED_01.md, QA_ATOM_RUNS_01.md, RELIEF_VISUAL_01.md, QA_PATCH_VERIFY_01.md (new evidence, read this pass)
  - docs/coord_swarm_2026-11-25/CORRECTIONS.md (re-read: 63 rows), README.md and SWARM_BOARD.md (corrections-count re-check)
---

# FINAL-CHECKLIST-01 — sign-off checklist for today's 3D variant work

## 0. How to read this checklist / rule base

**Citation shorthand (observed):** `R/` = `docs/coord_swarm_2026-11-25/reports/`;
`S/` = `docs/coord_swarm_2026-11-25/`; `V/` = `variant3d/`;
`Q/` = `variant3d/.godot_queue/results/`. Other paths are workspace-root relative.
Every citation is `path:line` (1-based). Job ids are written verbatim.

**Labels:** `observed` = literal text / tool output / file fact read for this checklist;
`derived` = arithmetic or control-flow consequence of observed facts;
`inferred` = plausible reading with an explicit caveat; `UNVERIFIED` = cannot be proven
from the read material (no donor GPU A/B, no fresh runner poll by this worker).
Every item carries a STATUS (`DONE` / `PARTIAL` / `OPEN`) and an evidence cite;
`[x]` marks DONE only, `[ ]` marks PARTIAL or OPEN.

**Governing rules cited for every section (observed unless labelled):**

| Rule | Citation |
|---|---|
| Test the smallest piece first; only test the final result at the end | `S/TEST_MATRIX.md:11`; S-25-04 `S/PROGRESS.md:171`; S-25-12 `S/PROGRESS.md:179` |
| Strict row order `P0→P1→P2→P3→C1→C2→C3→C4→S1→FINAL`, one ticket per row, no reorder/parallelise | `S/TEST_MATRIX.md:57`; `S/CAPTURE_RECHECK.md:12,249`; `R/FINAL_GATE_PLAN_01.md:100-103` |
| Second agent re-checks PNG/stderr before any row is PASS; owner never self-certifies | `S/TEST_MATRIX.md:58-59,75`; `S/CAPTURE_RECHECK.md:34,54,247-249`; `R/FINAL_GATE_PLAN_01.md:102-103,202-205` |
| Stop at first failing row; never rerun hoping for green; never weaken a test/marker | `S/TEST_MATRIX.md:60-61,67-68`; `R/FINAL_GATE_PLAN_01.md:182-201`; `S/CAPTURE_RECHECK.md:256-266` |
| Windowed captures only; headless = `SKIP_CAPTURE`/`passed=false`, not PASS; `SCRIPT ERROR == 0` mandatory | `S/TEST_MATRIX.md:62-64`; `R/FINAL_GATE_PLAN_01.md:123-125,199-201`; `S/CAPTURE_RECHECK.md:57-60` |
| One Godot at a time, FIFO variant runner only, Windows `python` (3.14) not `python3`, repo-root-relative paths | `S/TEST_MATRIX.md:70-72`; `R/FINAL_GATE_PLAN_01.md:47-49,84,117-121` |
| Queue gate: `pending=0`, free lock, 0 live Godot, `assert_clean.py --json` CLEAN/exit 0, no unacked failure-status jobs | `R/FINAL_GATE_PLAN_01.md:80-88,161-170`; `R/GATE_READY_01.md:192-219` |
| FINAL is COORD-only and last; State column is COORD-only; no early FINAL | `S/SWARM_BOARD.md:11,122`; `S/TEST_MATRIX.md:27,65-66`; `R/FINAL_GATE_PLAN_01.md:206-207`; S-25-04/S-25-12 `S/PROGRESS.md:171,179` |
| `app/**` untouched and green; 2D `app/` tooling is not a 3D gate | `S/TEST_MATRIX.md:48-51,66`; S-25-08 `S/PROGRESS.md:175`; `S/PROGRESS.md:197`; `R/FINAL_GATE_PLAN_01.md:78,144-146,175-178` |
| Metrics never override donor visual A/B; no donor GPU frame exists → parity UNVERIFIED; `PORT APPROX` | `S/TEST_MATRIX.md:32-34,73-74`; `S/CAPTURE_RECHECK.md:10,35,237`; `S/CORRECTIONS.md:132`; `S/PROGRESS.md:198`; `R/FINAL_GATE_PLAN_01.md:172-173,208-214` |

> **FINAL-GATE AUTHORISATION (explicit, required by the task):** COORD may run the one
> final whole-system gate **only after every `OPEN` item in sections A–I below is closed**
> and every `PARTIAL` item has been re-verified against fresh evidence. Both ladder
> attempts stopped at P0 (`R/FINAL_GATE_PLAN_01.md:220-221`; `S/SWARM_BOARD.md:118,178`),
> the integrated selftest is red (§C), the queue is DIRTY/churning (§D), and the second-agent
> re-check reports are absent (§F). **Current verdict: NOT_READY** — derived from
> `R/GATE_READY_01.md:192-219`, `R/QA_PARITY_01.md:99-105` and `R/FINAL_GATE_PLAN_01.md:53-88`.

---

## A. Code ownership / backups complete

- [x] **A-1 — STATUS DONE.** Ownership policy: one output file per worker; shared code
  READ-ONLY until an exclusive integration grant; COORD only edits the board State column.
  **Evidence:** `S/SWARM_BOARD.md:11-12,232-234`; S-25-01 `S/PROGRESS.md:168`;
  S-25-11 `S/PROGRESS.md:178`. **Label: observed.**
- [x] **A-2 — STATUS DONE.** Backups verified for the audited implementation set:
  QA-AUDIT-01 confirmed "all 25 backups verified", 10 tickets CONFIRMED / 3 PARTIAL,
  **0 prohibited patterns, no weakened tests, no deleted `expected_pre_fix_failure` markers**.
  **Evidence:** `S/PROGRESS.md:97-103`; `S/SWARM_BOARD.md:165`;
  rule `inbox\backup\<name>.bak-<TICKET>` at `S/SWARM_BOARD.md:234`. **Label: observed (doc).**
- [ ] **A-3 — STATUS PARTIAL.** Backups for the *post-audit* builders (Batch S/O waves:
  DARKROW-ALL-01, SEASON-TEST-PATH-01, DESERT-REMAP-02, PROP-W-PLAN-01, AUDIO-SEL-02,
  CONFIG-WIRE-RELIEF, WEATHER-DRIVER-01, MAPSIZE-01, PERF-3D-01, QA-PARITY-01) were not
  re-audited by QA-AUDIT-01; no backup verification report for these was read.
  **Evidence:** `S/SWARM_BOARD.md:240-255,270-278`; `R/QA_DOCS_02.md:10,83` (swarm still
  landing files; residual counts are lower bounds). **Label: inferred / UNVERIFIED.**
  *Gate condition:* COORD verifies backups before ladder start (rule `S/SWARM_BOARD.md:234`).
- [x] **A-4 — STATUS DONE.** Batch H disjoint file grants, one targeted headless smoke per
  builder, full gates once by COORD (decision S-25-12).
  **Evidence:** `S/SWARM_BOARD.md:126-127`; `S/PROGRESS.md:179`. **Label: observed.**
- [ ] **A-5 — STATUS PARTIAL.** Builder release: many P-1/D builders have closed
  (`CONFIG-UI-01`, `SP-1`, `SP-4`, `ASSET-IMPORT-01`, `DEFAULTS-VERIFY-01`,
  `CONFIG-COUNT-01`, `CONFIG-WIRE-SEL`, `MOTION-ANIM-01`, `SP-6`, `TERRAIN-DARK-FIX`).
  The snapshot's "4 BUSY" is stale: board `S/SWARM_BOARD.md:23-27` (11:32:51) shows
  **19 BUSY**, `R/SESSION_STATUS_FINAL_01.md:42-44` (11:37) **23 BUSY**, and board
  `:267` (11:44:52) **20 BUSY** (`R/QA_FINAL_02.md:85`). MAP-SMALL-01 has now closed —
  `R/MAP_SMALL_01_report.md:6` `REVERTED__GATES_NOT_GREEN` (both owned files restored,
  report landed 11:38:53) — so "MAP-SMALL-01 still open" is also stale. Other builders
  remain in flight (a fresh Godot `--ui-test` process was live at this refresh), so
  PARTIAL holds.
  **Evidence:** `S/SWARM_BOARD.md:23-27,267`; `R/SESSION_STATUS_FINAL_01.md:42-44`;
  `R/MAP_SMALL_01_report.md:6,18-25`; `R/GATE_READY_01.md:150-175` (plan P-1/D snapshot
  partly stale); `R/QA_DOCS_02.md:49-69`; `R/QA_FINAL_02.md:85,99`.
  **Label: observed + derived.** *Gate condition:* no in-flight edit may touch a file
  under test after the ladder starts (`R/FINAL_GATE_PLAN_01.md:62,94-96`).
- [x] **A-6 — STATUS DONE.** No code/config/test/fixture/git/queue mutation by this
  documentation worker; only this file and `reports/FINAL_CHECK_REFRESH_02.md` written by
  this refresh (FINAL-CHECK-REFRESH-01 wrote its own report in the prior pass). No runner
  poll or job of any kind was issued in this pass — all gate numbers are cited from the
  named reports.
  **Evidence:** this file's frontmatter `scope`/`refreshed_by`; `R/FINAL_CHECK_REFRESH_01.md:8`;
  `R/QA_GATE_READY_02.md:30-35`; `R/QA_PATCH_VERIFY_01.md:24-29`.
  **Label: observed (self) / derived (cross-worker pattern).**

## B. Targeted smokes green (job ids)

All rows in this section are **per-job artifacts only**: they do **not** imply the
integrated tree is green (`R/QA_PARITY_01.md:46-60,99-104`; `R/FINAL_GATE_PLAN_01.md:74`;
`S/PROGRESS.md:186-190`). **Label for the whole section: observed (doc), derived
interpretation.**

- [x] **B-1 — STATUS DONE.** Selection/input family: `337` (SEL-01 selftest 29/29),
  `318` (uitest 17/17), `329` (12/12 real-drag probe), `414` (`s1inputfix-run`, S1 atom
  23/23), CONFIG-WIRE-SEL windowed drag 23/23.
  **Evidence:** `R/FINAL_GATE_PLAN_01.md:74`; `R/QA_PARITY_01.md:50-57`;
  `S/SWARM_BOARD.md:110,148,171,211`. **Label: observed.**
- [x] **B-2 — STATUS DONE.** Camera/view family: `339` (CAM-01), `356` (CAM-02),
  `381` (`camrv01-smoke3`, **20/20**, contract anchor), `413`/`416`/`417` (MMJUMP-02,
  nav 6/6), `429` (CONFIG-WIRE-CAM).
  **Evidence:** `S/SWARM_BOARD.md:145-147,158,214`; `R/QA_PARITY_01.md:56`;
  `R/FINAL_GATE_PLAN_01.md:74,231`. **Label: observed.**
- [x] **B-3 — STATUS DONE.** Terrain/water/relief family: `342` (TRN-SHADER),
  `343` (TRN-WATER), `361` (TRN-GEOM), `402` (RELIEF-01), `415` (RELIEF-02),
  `433` (CONFIG-WIRE-WATER) — all recorded `SCRIPT ERROR 0` / ok.
  **Evidence:** `S/SWARM_BOARD.md:131-134,168-169,212`;
  `R/FINAL_GATE_PLAN_01.md:74`. **Label: observed.**
- [x] **B-4 — STATUS DONE.** Entities/FX/weather/audio family: `358` (DECOR-01,
  pool 19/19), `428` + `434` (FX-IMPACT-01, `t_fx3d` 13/13), `405` (FX-WEATHER-01,
  `t_fx3d` 13/13), `424` (AUDIO-SEL-01); `AUDIO-SEL-02` is still RUNNING (not counted).
  **Evidence:** `S/SWARM_BOARD.md:135,141,144,160,270`; `R/FINAL_GATE_PLAN_01.md:74`;
  `R/QA_PARITY_01.md:58`. **Label: observed.**
- [x] **B-5 — STATUS DONE.** HUD/UI family: `340`/`349`/`357` (HUD-01),
  `366` (`uitestanchor-uitest`, 17/17, `minimap bottom-right: yes`),
  `440` (CONFIG-WIRE-HUD, uitest 17/17), `426` (CONFIG-UI-01).
  **Evidence:** `S/SWARM_BOARD.md:136-137,207,213`; `R/QA_PARITY_01.md:55`;
  `R/FINAL_GATE_PLAN_01.md:74`. **Label: observed.**
- [x] **B-6 — STATUS DONE.** Config/atlas/season-adjacent family: `419` (CONFIG-CORE-01),
  `382` (DALPHA-02, 6/6), `409` (SP-5 loader), `410` (SP-1 enum).
  **Evidence:** `S/SWARM_BOARD.md:157,192,195,206`; `R/FINAL_GATE_PLAN_01.md:74`.
  **Label: observed.**
- [x] **B-7 — STATUS DONE (limited scope).** Atom repair / harness parse checks only:
  `364`–`375` (ATOM-REPAIR, all 9 atoms load, 0 parse errors) and `384` (HARNESS-01,
  `SCRIPT ERROR 0`, `Invalid cast 0`; exit 1 = atom's unchanged headless verdict).
  **These are parse-only, not gate PASS.** Evidence: `S/SWARM_BOARD.md:119-120`;
  `R/FINAL_GATE_PLAN_01.md:74`; `R/QA_ATOM_RESULTS_01.md:45-51,78-79`.
  **Label: observed + derived.**
- [x] **B-8 — STATUS DONE (limited scope).** TRN-DATA determinism `423` 5/5.
  Its **selftest** job `411` was 28/29 (`build`, missing `.ctex`) and is **not** green —
  see C-4. **Evidence:** `S/SWARM_BOARD.md:134`; `R/FINAL_GATE_PLAN_01.md:75`;
  `R/QA_PARITY_01.md:50-57`. **Label: observed.**
- [ ] **B-9 — STATUS PARTIAL.** Interpretation gate: per-job green artifacts remain valid
  for their own jobs, but QA-AUDIT F-01 / QA-PARITY show the integrated state is not
  green; `PROGRESS.md:205` (was `:194` at snapshot — line drift; `R/QA_FINAL_02.md:94,207`)
  still bolds "29/29 repeatedly" (scoped as per-job only at `:186-190`).
  **Evidence:** `R/QA_PARITY_01.md:99-104`; `R/FINAL_GATE_PLAN_01.md:74,76`;
  `R/QA_DOCS_02.md:39,76`; `S/PROGRESS.md:186-190,205`; `R/QA_FINAL_02.md:94,207`.
  **Label: derived (citation drift: observed).**
- [ ] **B-10 — STATUS PARTIAL.** HUD-layout and load-usability atoms *ran* once each but
  neither produced a gate PASS: job `530` (`hudlayoutrun01-atom`) → `t_hud_layout.json`
  **FAIL**, 42 passes / 11 fails / 12 skipped, `capture_status=SKIP_CAPTURE`, headless (no
  PNG), scan-stderr `SCRIPT ERROR == 0`; job `531` (`loadprobe01-atom`) →
  `t_load_usability.json` **`MEASUREMENT_ONLY__NO_PASS_CLAIM`**, `gate_claim:NONE`,
  `pass_claim:false`, no capture, wall-cap at frame 1742, plus one probe-side formatting
  `ERROR`. The speed dropdown is structurally PASS (4 rows × 3 viewports); top-bar fit and
  load responsiveness remain UNVERIFIED. **No PASS promoted**; this is a per-job artifact
  row, not a smoke green. The speed widget is static-only in `R/QA_SPEED_01.md:53-63,132-147`
  (no windowed run, no owner report `UI_TOPBAR_01.md`).
  **Evidence:** `R/QA_ATOM_RUNS_01.md:50-56,90-113,139-159`; `R/QA_SPEED_01.md:49-69,130-149`;
  `S/SWARM_BOARD.md:324-325,336`. **Label: observed (doc) + derived.**

## C. Integrated selftest / uitest — current red/green and exact failures

- [ ] **C-1 — STATUS OPEN (RED).** Integrated `variant3d/selftest.json`:
  `"passed": false`, **29 steps / 28 pass / 1 fail**. Exact failure:
  `selftest.json:31-36` → step `build`, detail `"house built in 3.1 s of build time
  (cost 120 wood)"`, `"passed": false`. Read live for this checklist (29 `step` keys,
  only `build` false); `wall`, `shell`, `farm_cap`, `nav_detour` now pass, so the older
  HEAD 26/29 failure set has shifted. Gate requires fresh **29/29**, so this is NOT a gate.
  **Evidence:** `V/selftest.json:2,31-36` (live read); `R/QA_PARITY_01.md:71-77,103`;
  `R/GATE_READY_01.md:183`; `R/FINAL_GATE_PLAN_01.md:76,162-164,226`;
  `S/PROGRESS.md:100-103`; newest confirmation `R/QA_GATE_READY_02.md:135,188,223-226`
  (mtime 10:28:11 UTC, `build` still failing, no fresh 29/29).
  **Label: observed (live) + derived.**
- [ ] **C-2 — STATUS PARTIAL (GREEN ARTIFACT, NOT GATE).** Integrated
  `variant3d/uitest.json`: `"passed": true`, **17/17** steps (live read confirms 17
  `step` keys; `minimap_frustum` = `"minimap bottom-right: yes"` per QA-PARITY at
  `:69-72`). It predates the final job and must be re-proved by a fresh COORD job.
  **Evidence:** `V/uitest.json:2-88` (live read); `R/QA_PARITY_01.md:81`;
  `R/GATE_READY_01.md:184,186-188`; `R/FINAL_GATE_PLAN_01.md:77,157,165`;
  newest confirmation `R/QA_GATE_READY_02.md:136,189,227-229` (17/17, mtime 09:51:54 UTC,
  stale, not re-proved by a fresh COORD job).
  **Label: observed + derived.**
- [ ] **C-3 — STATUS OPEN.** QA-PARITY-01 verdict **PARTIAL**, not a green re-verification:
  its final jobs `453` (`qaparity01-selftest`) and `452` (`qaparity01-uitest`) were
  **skipped** (`serving=461`, wait ≈1756 s, run 0.0, exit null); earlier `446`/`447`
  were killed by the worker's own 60 s shell timeout. The report file **is** present now
  (mtime 11:23:46), which supersedes `GATE_READY_01.md:145`'s "ABSENT" note, but its
  content is red on selftest. **Evidence:** `R/QA_PARITY_01.md:35-44,99-105,120-121`;
  `R/GATE_READY_01.md:145,241-242`; reports-dir listing (observed).
  **Label: observed + derived.** *Conflict recorded, not resolved by assertion.*
- [ ] **C-4 — STATUS OPEN.** TRN-DATA selftest job `411` = 28/29, `build` failed on the
  missing `mill_rotor.png` `.ctex`; ASSET-IMPORT-01 (job `444`, +12 ctex) landed but the
  target `.ctex` is still absent because `.gdignore` excludes the source PNG.
  **Evidence:** `R/FINAL_GATE_PLAN_01.md:75`; `S/SWARM_BOARD.md:134,215`;
  `S/PROGRESS.md:104-115`. **Label: observed (doc).**
- [ ] **C-5 — STATUS OPEN.** Measurement conflict is undecided by documents:
  `PROGRESS.md:197-201/205` "29/29 repeatedly" (was `:188/194` at snapshot — line drift;
  `R/QA_FINAL_02.md:94,207`) vs QA-AUDIT F-01 (26/29 HEAD / 28/29 worktree) vs today's
  28/29 (`build`); the **final job, not either table, decides**
  (`R/FINAL_GATE_PLAN_01.md:249-251`). Governance note is CLOSED
  (`R/QA_DOCS_02.md:39`), the underlying gate is not.
  **Evidence:** `R/FINAL_GATE_PLAN_01.md:76,226,249-251`; `R/QA_DOCS_02.md:39,76`;
  `S/PROGRESS.md:197-201,205`; `R/QA_FINAL_02.md:94,207`. **Label: derived (citation
  drift: observed).**

## D. Queue CLEAN prerequisites

- [ ] **D-1 — STATUS OPEN (target NOT met at refresh).** `godot_runner.py status` target:
  `pending = 0`, no held lock, bounded max wait. QA-FINAL-02.md:95 observed a momentary
  drain at 11:51:50 (`pending=0`, lock free, max wait 1825.52 s), but the newest read-only
  polls in `R/QA_GATE_READY_02.md:46-58,114-120` show the queue churning: Poll A
  `now_serving=516`, `next_ticket=523`, `pending=7 [516…522]`, lock HELD 237.2 s; Poll B
  `now_serving=521`, `next_ticket=524`, `pending=3 [521…523]`, lock HELD 38.2 s (max wait
  1825.52 s, bounded). Earlier FINAL-CHECK-REFRESH-01 poll: `pending=1 [515]`, lock HELD
  33.2 s. Marking DONE would inflate PASS, so the status stays OPEN.
  **Evidence:** `R/QA_GATE_READY_02.md:11,46-58,114-120,185`; `R/QA_FINAL_02.md:95,150`;
  `R/GATE_READY_01.md:49-59,78-90,122-133,196-199`; `R/FINAL_GATE_PLAN_01.md:84,170`.
  **Label: observed.**
- [ ] **D-2 — STATUS OPEN (target NOT met at refresh).** Zero live Godot processes is the
  target. QA-FINAL-02.md:96 saw `count=0` at 11:51:50, but the newest
  `assert_clean.py --json` polls in `R/QA_GATE_READY_02.md:60-66,105-112` show **1 Godot
  alive** in both (PID 8984, `--self-test … --self-only move,act,fight,build`; then PID
  11292, `--dump-map …reliefenabl01_dump.json`) alongside a held lock. Earlier snapshots
  had one alive too (PIDs 22252, 21684, 19436); lock HELD→free is not evidence of a quiet
  queue. Marking DONE would inflate PASS, so the status stays OPEN.
  **Evidence:** `R/QA_GATE_READY_02.md:60-66,105-112,185`; `R/QA_FINAL_02.md:96,151`;
  `R/GATE_READY_01.md:61-73,92-103,128-133,196-199`; `R/FINAL_GATE_PLAN_01.md:85,166`.
  **Label: observed + derived.**
- [ ] **D-3 — STATUS OPEN.** `assert_clean.py --json` → `CLEAN`, exit 0 on the **variant**
  spool. Observed twice DIRTY/exit **1** in GATE-READY with "1 Godot process alive" +
  "16 failed job(s)". Newest polls (`R/QA_GATE_READY_02.md:60-66,105-112,186`): **DIRTY,
  exit 1**, reasons "1 Godot process(es) alive" + "**17 failed job(s)**" at Poll A, rising
  to "**18 failed job(s)**" at Poll B; the earlier FINAL-CHECK-REFRESH-01 poll showed 17.
  Not CLEAN, so OPEN holds.
  **Evidence:** `R/QA_GATE_READY_02.md:60-66,105-112,186`; `R/QA_FINAL_02.md:97`;
  `R/GATE_READY_01.md:61-74,92-113,192-199`; `R/FINAL_GATE_PLAN_01.md:85,166-169`.
  **Label: observed.**
- [ ] **D-4 — STATUS OPEN.** No unacked `timed-out`/`error`/`skipped` jobs. Newest polls:
  `acknowledged=22` (failure-status scope); **17** unacked at Poll A = **16 `skipped` +
  1 `timed-out` (ticket 494 `mapsmall01-json-uitest`, exit -9)**, rising to **18** at Poll B
  with ticket **516** (`buildstep01-diag-240-r2`, `timed-out`, exit -9, run 304.999 s)
  (`R/QA_GATE_READY_02.md:100-112,122-129,187`). Direct `status.json` parse there counts 18
  unacked with 94 truthy `acknowledged` entries overall; `assert_clean.py:166-188` counts
  only within failure statuses, hence its 22 — both readings are DIRTY. Tickets `296`/`300`
  remain unacked `failed` and are excluded by D-13. Ack plans in `CLEAN_ACK_PLAN_01.md` /
  `QUEUE_DRAIN_01.md` were prepared, **not executed**.
  **Evidence:** `R/QA_GATE_READY_02.md:100-112,122-129,187`; `R/QA_FINAL_02.md:98,205`;
  `R/GATE_READY_01.md:105-113,200-201`; `R/FINAL_GATE_PLAN_01.md:86`.
  **Label: observed + derived.**
- [ ] **D-5 — STATUS OPEN.** All in-flight builders released or explicitly deferred before
  the ladder starts (cross-ref A-5). Ticket `485` `mapsmall01-json-selftest` was still
  pending at GATE-READY read time. **Evidence:** `R/GATE_READY_01.md:122-126,212-215`;
  `R/FINAL_GATE_PLAN_01.md:62,92-96`; `S/SWARM_BOARD.md:19-30`. **Label: derived.**
- [x] **D-6 — STATUS DONE.** Environment rule honoured *by this worker*: Windows `python`
  (3.14), no `python3`, no direct `godot`, no runner job of any kind. Read-only status /
  clean polls by other workers are permitted (`R/GATE_READY_01.md:32-39`).
  **Evidence:** `S/TEST_MATRIX.md:71-72`; `R/FINAL_GATE_PLAN_01.md:47-49,117-121`;
  this file's `scope`. **Label: observed (self).**
- [x] **D-7 — STATUS DONE.** `assert_clean.py:34` corrected to the **variant** spool;
  tool correctly reports DIRTY during churn. Formal signing is deferred to COORD → D-3.
  **Evidence:** `S/SWARM_BOARD.md:179-180`; `R/CLEAN_02_variant_gate.md:43-62,125-131`
  as cited at `R/FINAL_GATE_PLAN_01.md:85`; `R/CLEAN_01_variant_clean.md:260-283`.
  **Label: observed.**
- [x] **D-8 — STATUS DONE (fidelity only; post-patch gate OPEN).** Runner patch verified
  **APPLIED_AS_APPROVED**: the applied `godot_runner.py` is the approved post-image of
  `RUNNER_FIX_01.md` §3 (7 hunks, index `69d599ff..9730aa49`), hunk-for-hunk and body-for-body
  identical to the approved diff; backup/current blob hashes match the pre-/post-image;
  re-application to a byte-copy reproduces the live content after LF normalization;
  all five required mechanisms are present with no extra hunk; `py_compile` exits 0.
  The only byte-level difference is a whole-file CRLF conversion. **This is a patch-fidelity
  finding, not a runtime validation** — no solo post-patch gate was run, and the queue was
  neither drained nor quiet at verification (`pending=4`, lock HELD). Runtime correctness
  remains with COORD's §5 validation plan.
  **Evidence:** `R/QA_PATCH_VERIFY_01.md:13,65-90,92-114,118-135,172-187,221-230`;
  `R/QA_GATE_READY_02.md:159-167,195,259-261`; `S/PROGRESS.md:104-112`.
  **Label: observed + derived (runtime: UNVERIFIED).**

## E. Piece→combo ladder status, row by row

Order rule and per-row capture criteria: `S/TEST_MATRIX.md:18-27,57-68`;
`S/CAPTURE_RECHECK.md:93-226`; `R/FINAL_GATE_PLAN_01.md:105-146`.
**Both attempts stopped at P0; P1–C4/S1/FINAL were never executed as ladder rows**
(`S/SWARM_BOARD.md:118,178`; `R/FINAL_GATE_PLAN_01.md:220-225`). Labels per row below.

| Row | STATUS | Exact state / failure | Evidence (path / job id) | Label |
|---|:--:|---|---|---|
| [ ] **E-P0** `t_terrain_only` | **PARTIAL** | Attempt 1 job `321`: END failed, exit 1, 4 `SCRIPT ERROR` parse lines, no JSON/PNG. Attempt 2 job `404` windowed: `verdict=FAIL`, `full_width_dark_rows=720`, `SCRIPT ERROR == 0`, PNG+stats exist. P0-GATE job `421` exit 1 as expected (13.271 / 27.413) with strict luma gates; stage-1 fix job `441` windowed PASS (22/0/1, `mean_luma=98.680`, `max_luma=172.139`). The "final re-capture PENDING / no `RECHECK_P0.md`" claim is now false: final-formula job `504` (`p0fresh01-capture`) = windowed `PASS 22/22 evaluated, 1 skipped`, `mean_luma=91.432`, `max_luma=155.163`, PNG 47 min after the shader edit; `RECHECK_P0_FINAL.md` = **P0 CONFIRMED_PASS** (11 PASS / 0 FAIL / 1 N/A), and `RECHECK_P0.md` also landed; `R/QA_GATE_READY_02.md:150-151,190` independently re-records the same CONFIRMED_PASS as PR-5 DONE (evidence). PARTIAL retained only because COORD has not advanced the ladder row (row advancement is COORD-only) — no new PASS claim. | `S/PROGRESS.md:126-137`; `S/SWARM_BOARD.md:118,177-178,209`; `R/TEST_RUN_02_ladder_log.md:202-229`; `R/P0_GATE_01.md:81-105,134-174`; `R/TERRAIN_DARK_FIX.md:15-16,165,178-188`; `R/P0_FRESH_CAPTURE_01.md:59-64,67-73`; `R/RECHECK_P0.md:12-13,173`; `R/RECHECK_P0_FINAL.md:14,221-241`; `R/QA_FINAL_02.md:100,154,200`; `R/QA_GATE_READY_02.md:150-151,190` | observed + derived |
| [ ] **E-P1** `t_terrain_trees` | **OPEN** | Never executed as a row. Headless JSON `FAIL`/`SKIP_CAPTURE` 21/1/10; source 11:05:08 > JSON 10:08:38 → **stale**. Water-free dark-row assert applicability flagged. | `R/TEST_RUN_02_ladder_log.md:137-143,291-293`; `R/QA_ATOM_RESULTS_01.md:45,77-81`; `R/FINAL_GATE_PLAN_01.md:242-248`; `S/SWARM_BOARD.md:283` (DARKROW-ALL-01 RUNNING, report absent) | observed + inferred |
| [ ] **E-P2** `t_terrain_shore` | **OPEN** | Never executed. Headless JSON `UNVERIFIED`, no `capture_status`, 16/10 (3 `EXPECTED_PRE_FIX_FAILURE` + 7 headless `UNVERIFIED`), stale. Water-band gate applies here when run. | `R/QA_ATOM_RESULTS_01.md:46`; `R/TEST_RUN_02_ladder_log.md:137-143`; `S/CAPTURE_RECHECK.md:129-143` | observed |
| [ ] **E-P3** `t_terrain_mines` | **OPEN** | Never executed. **False green:** JSON `passed:true` (13/13) comes from headless skip rows (`png.written=false`, size `[0,0]`, `status=HEADLESS_STRUCTURAL_ONLY__PNG_UNVERIFIED`); `t_terrain_mines.gd:885-892` calls `check(...,true,...,non-PASS status)`. Source 11:06:57 > JSON 10:00:59 → stale. Must not be read as structural+visual PASS. | `R/QA_ATOM_RESULTS_01.md:47,70-75`; `S/CAPTURE_RECHECK.md:145-158` | observed + derived |
| [ ] **E-C1** `t_combo_trees_shore` | **OPEN** | Never executed. Headless JSON `FAIL`/`SKIP_CAPTURE` 22/2/4, stale (11:08:06 > 10:01:16). | `R/QA_ATOM_RESULTS_01.md:48`; `R/TEST_RUN_02_ladder_log.md:137-143` | observed |
| [ ] **E-C2** `t_combo_trees_mines` | **OPEN** | Never executed. Headless JSON `FAIL`/`SKIP_CAPTURE` 25/3/0, stale (11:13:01 > 10:01:35). Water-free row hard-asserts `full_width_dark_rows==0`; if inapplicable, open a separate evidence-backed ticket — do not relax. | `R/QA_ATOM_RESULTS_01.md:49`; `S/CAPTURE_RECHECK.md:173-185`; `R/FINAL_GATE_PLAN_01.md:242-248` | observed + inferred |
| [ ] **E-C3** `t_combo_shore_mines` | **OPEN** | Never executed. Headless JSON `SKIP_CAPTURE` (12/12 checks pass, gate is the capture), stale (11:10:03 > 10:02:43). | `R/QA_ATOM_RESULTS_01.md:50`; `S/CAPTURE_RECHECK.md:187-196` | observed |
| [ ] **E-C4** `t_combo_all` | **OPEN** | Never executed. Headless JSON `status=SKIPPED_HEADLESS`, 0/1, `total=1`, stale (11:11:11 > 10:03:15). Per-layer toggles owned by the atom, do not invent flags. | `R/QA_ATOM_RESULTS_01.md:51`; `R/FINAL_GATE_PLAN_01.md:114,135-137`; `S/SWARM_BOARD.md:104` | observed |
| [ ] **E-S1** `t_select_rect` | **PARTIAL** | Atom-level windowed job `414` PASS **23/23**, `SCRIPT ERROR 0`, `run_mode=windowed_real_input`; JSON fresh (10:27:33 < 10:46:01). The "no landed `RECHECK_S1.md`" claim is false: `RECHECK_S1.md` landed 11:39:13 — atom JSON/artifact PASS 23/23, but second-agent image verdict **UNVERIFIED (NO PNG)** plus shared-JSON provenance ambiguity (jobs 414/438/495); no row PASS. Ladder row not re-run; PARTIAL retained. | `R/QA_ATOM_RESULTS_01.md:52`; `S/SWARM_BOARD.md:171,241`; `R/FINAL_GATE_PLAN_01.md:115,131-134,256-258`; `S/CAPTURE_RECHECK.md:54,211-226`; `R/RECHECK_S1.md:34,142-145,149-158,164-168`; `R/QA_FINAL_02.md:102,153` | observed + derived |
| [ ] **E-FINAL** | **OPEN (RESERVED)** | Never run; COORD-only, last; requires fresh 29/29 + 17/17 + CLEAN/exit 0 + `pending=0`. | `S/SWARM_BOARD.md:122`; `S/TEST_MATRIX.md:27,65-66`; `R/FINAL_GATE_PLAN_01.md:148-178` | observed |
| [ ] **E-REG** manifest/registry lag | **PARTIAL** | All 9 manifest entries are `status:"pending"` even though P0 (job `441`) and S1 (job `414`) have green JSONs; `t_view_rect_rv` PASS 20/20 (job `381`) has **no** canonical result JSON; `t_motion_capture` (job `408`, `CAPTURE_OK`) has a green JSON but no manifest row. `--list` = 40 rows (30 ready / 10 pending), no 2D access. | `R/QA_ATOM_RESULTS_01.md:57-65,83-86,98-101`; `S/SWARM_BOARD.md:193`; `R/FINAL_GATE_PLAN_01.md:74` | observed + derived |

## F. Second-agent capture re-checks

- [x] **F-1 — STATUS DONE.** Protocol exists and is authoritative: `CAPTURE-RECHECK.md`
  (`RECHECK-<ROW>.md` naming, mandatory artifact set, `stats` + `scan-stderr` commands,
  PASS/FAIL/N/A criteria P0–S1, image-inspection rules, COORD-only ladder advance).
  **Evidence:** `S/CAPTURE_RECHECK.md:41-73,87-226,244-267`;
  `S/SWARM_BOARD.md:328` (CAPTURE-RECHECK-01 DONE; was `:284` — line drift,
  `R/QA_FINAL_02.md:104`). **Label: observed.**
- [ ] **F-2 — STATUS OPEN (partly closed).** The "0 `reports/RECHECK_*.md` files" claim is
  WRONG: **3** reports are on disk — `RECHECK_P0.md` (11:36:47, stage-1 frame, ladder not
  cleared), `RECHECK_S1.md` (11:39:13, image verdict UNVERIFIED / NO PNG) and
  `RECHECK_P0_FINAL.md` (11:45:29, **P0 CONFIRMED_PASS** on port gates). The snapshot's
  "4 BUSY" inference is stale (see A-5). P1, P2, P3, C1–C4 still have no second-agent
  re-check, so the gate condition is not met and the item stays OPEN. `R/QA_GATE_READY_02.md:192`
  (PR-7) independently confirms "P0/S1 only", with S1's image verdict UNVERIFIED (NO PNG).
  **Evidence:** `R/RECHECK_P0.md:12-13,173`; `R/RECHECK_S1.md:143-145`;
  `R/RECHECK_P0_FINAL.md:14,221-241`; `R/QA_FINAL_02.md:105,153`; `R/QA_GATE_READY_02.md:192`;
  reports-dir listing (observed); `S/SWARM_BOARD.md:23-27`;
  *Gate condition:* `S/TEST_MATRIX.md:75`. **Label: observed + derived.**
- [ ] **F-3 — STATUS OPEN (deliverable).** For every row: PNG + result JSON + runner
  stderr (+ `frames.json` on motion rows P2/C1/C3/C4); `stats` and `scan-stderr` outputs
  verbatim; windowed; `SCRIPT ERROR == 0`; separate "atom JSON verdict" and "second-agent
  image verdict". **Evidence:** `S/CAPTURE_RECHECK.md:43-60,62-83,246-250`;
  `R/FINAL_GATE_PLAN_01.md:138-146`. **Label: observed (rule), OPEN (execution).**
- [ ] **F-4 — STATUS PARTIAL.** Discipline is DONE: no worker self-certified a visual
  PASS — both ladder logs explicitly refused one because the second agent had not
  performed the role. The outcome is not achieved (F-2 remains OPEN).
  **Evidence:** `R/TEST_RUN_02_ladder_log.md:231-233`;
  `R/TEST_RUN_01_ladder_log.md:165-167`; `S/CAPTURE_RECHECK.md:34`.
  **Label: observed.**

## G. Donor decomp / corrections documentation

- [x] **G-1 — STATUS DONE.** Donor decompilation lane CLOSED (owner-confirmed): all 8
  `DEC_0x_*.md` reports on disk, `decomp/README.md` marks DONE, `decomp/SUMMARY.md` +
  `EVIDENCE_INDEX.md` hold findings and offsets. **Evidence:** `S/PROGRESS.md:75-79`;
  `S/SWARM_BOARD.md:56-71`. **Label: observed (doc).**
- [x] **G-2 — STATUS DONE.** Canonical `CORRECTIONS.md` index: **63** indexed rows (1–63).
  Rows 1–60 were independently grep/manual counted by QA-DOCS-02 (`COUNT=60 MIN=1 MAX=60`,
  no gaps or duplicate ids); rows 61–63 (Winter LFS pointer, donor Y-up light space, naval
  stale-doc refutations) landed later and the summary is synced: **63 indexed corrections;
  46 RESOLVED / 15 PARTIAL / 1 CONFIRMED_UNVERIFIED / 1 CONFIRMED_INFEASIBLE**. README now
  also reports 63 (G-7). Board `:165` still says "50 rows" — stale, superseded by the later
  verified count (board `:313` does say 63).
  **Evidence:** `S/CORRECTIONS.md:45-112,174-176`; `R/QA_DOCS_02.md:44,90` (count 60 at its
  snapshot); `README.md:49,199,263,289,518`; `S/SWARM_BOARD.md:165,313`.
  **Label: observed + derived (conflict recorded).**
- [x] **G-3 — STATUS DONE.** Duplicate-chain notice for rows **14/51** and **28/52**;
  row 51 and row 52 are authoritative. **Evidence:** `S/CORRECTIONS.md:111-115`;
  `R/QA_DOCS_02.md:44`. **Label: observed.**
- [x] **G-4 — STATUS DONE.** Inventory mismatch rows **58–60** present (root files 24,
  map field 55/32, `.inc` 455 whole-donor vs 313 under `data/`) and cross-referenced;
  they remain rows 58–60 of the now 63-row index (G-2).
  **Evidence:** `S/CORRECTIONS.md:107-109,174`; `R/QA_DOCS_02.md:45`;
  `S/SWARM_BOARD.md:242,394`. **Label: observed.**
- [ ] **G-5 — STATUS PARTIAL.** QA-DOCS-02 BLOCKER roll-up: B1 CLOSED, B3 CLOSED,
  **B2 PARTIAL** (C2/C3/C4 duplicate rows CLOSED; C6 report-landed-but-RUNNING not closed:
  11 rows plus README-UPDATE-01 at `:236`). **Evidence:** `R/QA_DOCS_02.md:43,47,49-69,86-93`.
  **Label: observed + derived.** *Owner action:* COORD-only State column (`S/SWARM_BOARD.md:11`).
- [ ] **G-6 — STATUS OPEN.** Duplicate ticket ids remain; only the cited line numbers
  drifted after the 11:51 board edit (`R/QA_FINAL_02.md:110,207`): `README-UPDATE-01`
  (`S/SWARM_BOARD.md:369` DONE / `:388` DONE — TERMINATED; were `:305/:324`, earlier
  `:217/:236/:280`), `INVENTORY-01` (`:371` DONE — TERMINATED / `:394` DONE; were
  `:307/:330`, earlier `:219/:242/:263`),
  `TEST-RUN-02` (`:119` RESERVED / `:176` DONE — STOPPED AT P0; were `:121/:155`).
  **Evidence:** `R/QA_DOCS_02.md:74`; `R/QA_ATOM_RESULTS_01.md:103-105`;
  `S/SWARM_BOARD.md:119,176,369,371,388,394`; `R/QA_FINAL_02.md:110,207`.
  **Label: observed (duplicates) + observed (citation drift).**
- [x] **G-7 — STATUS DONE (closed by README rewrite; count re-synced to 63).** The
  "README still says **57**" claim is false: `README.md` reports **63** corrections in four
  places — `:49` "**63 rows** (DOC-03 snapshot 50; rows 51–63 landed since)", `:199`
  "**63-row**", `:263` "Canonical **63-row**", `:289` "**63** indexed corrections" —
  matching the authoritative **63** (`S/CORRECTIONS.md:174-176`; rows 61–63 added since
  QA-DOCS-02 counted 60 at `R/QA_DOCS_02.md:44,90`); the "explicitly contradicted" caution is
  gone. Board `:369` still carries the stale "57-row corrections index" text, but that is a
  *board* lag (tracked in G-6/A-5), not a README defect.
  **Evidence:** `README.md:49,199,263,289,518`; `S/CORRECTIONS.md:174-176`;
  `R/QA_DOCS_02.md:75`; `R/QA_FINAL_02.md:111,202`; `S/SWARM_BOARD.md:369`.
  **Label: observed.**
- [x] **G-8 — STATUS DONE.** "Claims that stay UNVERIFIED" register is present: 8
  engine-side values, 3 `CONFIRMED_INFEASIBLE` (eye planes, FOV, native selection
  predicate); no invented values, no donor binary executed/copied. The caveat persists
  by design (H-2).
  **Evidence:** `S/CORRECTIONS.md:117-139,178-180`; `S/CORRECTIONS.md:141-167` (usage rules).
  **Label: observed.**

## H. Owner visual review and donor A/B caveat

- [ ] **H-1 — STATUS OPEN.** Owner visual review has not been signed: required by the
  matrix (`S/TEST_MATRIX.md:27,73-75`) and by the final acceptance list
  (`R/FINAL_GATE_PLAN_01.md:171-173`); only P0/S1 re-checks exist (F-2), none for P1–C4,
  and S1's image verdict is UNVERIFIED (NO PNG).
  **Evidence:** `S/CAPTURE_RECHECK.md:34-37,91`; `R/QA_ATOM_RESULTS_01.md:93-96`;
  `R/QA_GATE_READY_02.md:192-193`.
  **Label: derived.** A green gate does **not** constitute owner visual review.
- [ ] **H-2 — STATUS OPEN (evidence class UNVERIFIED).** Donor GPU A/B / rendered
  terrain, skin and water parity: **no matched donor frame exists**; donor execution was
  forbidden and a live GL/native trace is out of scope. Every visual claim stays
  UNVERIFIED. **Evidence:** `S/CORRECTIONS.md:132`; `S/TEST_MATRIX.md:32-34,73-74`;
  `S/PROGRESS.md:198`; `R/GATE_READY_01.md:216-219`;
  `R/FINAL_GATE_PLAN_01.md:208-214,230`. **Label: UNVERIFIED.**
- [ ] **H-3 — STATUS PARTIAL.** `PORT APPROX — internal consistency only` is the standing
  label for every capture (`R/TEST_RUN_02_ladder_log.md:99` as cited by
  `S/CAPTURE_RECHECK.md:35`; `S/CORRECTIONS.md:148-150`). Applied as a rule, but per-row
  frame-level labelling cannot be confirmed because RECHECK reports are absent.
  **Evidence:** `S/CAPTURE_RECHECK.md:10,237,267`; `R/FINAL_GATE_PLAN_01.md:193-198`.
  **Label: observed (rule) / UNVERIFIED (per-row).**
- [x] **H-4 — STATUS DONE (caveat stated).** The final gate is a truthful *system* gate,
  **not** a donor-parity certificate; metrics never override visual A/B.
  **Evidence:** `R/FINAL_GATE_PLAN_01.md:172-173,208-214`; `S/TEST_MATRIX.md:73-74`;
  `S/CAPTURE_RECHECK.md:237`. **Label: observed.**
- [ ] **H-5 — STATUS OPEN.** Owner's real-windowed runtime report is not signed off:
  `hud3d_adapter.gd:172-173` inferred-type parse errors cascading to `hud.gd:207`, and
  `mill_rotor.png` `.ctex` load errors. `MINIMAP-QUAD-01` is still RUNNING and
  `ASSET-IMPORT-01` landed with the target `.ctex` still absent.
  **Evidence:** `S/PROGRESS.md:104-115`; `S/SWARM_BOARD.md:143,215`;
  `R/FINAL_GATE_PLAN_01.md:62,75`. **Label: observed (report) + derived (unclosed).**
- [ ] **H-6 — STATUS PARTIAL (finding landed, no gate).** White-marks symptom **reproduced**
  in a real generated 64×64 windowed GPU frame with `features.terrain.relief_stamps = true`
  (job `532` `reliefvisual01-boot`): raw sidecar 1280×720, mean luma 115.039, non-black
  0.999145, 0 dark rows, 44,381 near-white pixels (4.8156 %) in stepped, grid-aligned
  concentric bands across top-left/right/bottom; **no visible hills, ridges or elevation
  shading**. `SCRIPT ERROR == 0`; the runner marked the job `failed`/exit 1 because
  `main.gd`'s one-sided blank detector rejected the non-blank frame against a bright sky
  corner, so the final PNG was not written (raw sidecar inspected instead). The flag gates
  only `--dump-map` output and the flag-on dump for this seed carries `relief_stamps = []`;
  donor-grid relief (`relief_grid.applied`) and a flag-on/flag-off pixel A/B remain
  **UNVERIFIED**. No donor parity claimed — `PORT APPROX`.
  **Evidence:** `R/RELIEF_VISUAL_01.md:10-18,45-64,87-99,127-175,216-246,271-287`;
  `R/QA_GATE_READY_02.md:109-112`. **Label: observed + derived (attribution: inferred;
  donor A/B: UNVERIFIED).**

## I. 2D gates

- [x] **I-1 — STATUS DONE.** `app/**` untouched today: defaults change was scoped to
  `variant3d/` only (S-25-08) and 2D gates are required to remain green.
  **Evidence:** `S/PROGRESS.md:175,197`; `S/TEST_MATRIX.md:66`;
  `R/FINAL_GATE_PLAN_01.md:78,229`. **Label: observed.**
- [ ] **I-2 — STATUS PARTIAL (artifact CONFIRMED_GREEN; current tree UNVERIFIED).**
  QA-2D-GATES-01's verdict is **CONFIRMED_GREEN**, scoped strictly to the 2D shipping
  project (`app/`): fresh 2D runner jobs `qa2d-selftest` (ticket **1348**, `ok`, exit 0,
  selftest **29/29**) and `qa2d-uitest` (ticket **1349**, `ok`, exit 0, uitest **17/17**),
  plus `assert_clean.py --json` `CLEAN`/exit 0 with `processes.count=0`, free lock,
  `history.total=256`, `failures=[]`, and `pending=0` with bounded max wait. No 2D gate was
  weakened or hand-edited; `variant3d/` was not touched. These gates were **not re-run** by
  GATE-READY-02 or by this checklist, so current-tree status is UNVERIFIED here; the final
  acceptance requires them green.
  **Evidence:** `R/QA_2D_GATES_01.md:24-28,82-94,104-109,164-173,216-225`;
  `S/SWARM_BOARD.md:285`; `R/GATE_READY_01.md:221-225`;
  `R/FINAL_GATE_PLAN_01.md:78,171,229`; `S/PROGRESS.md:190,197`.
  **Label: observed (artifact) / UNVERIFIED (current tree).**
- [x] **I-3 — STATUS DONE.** 2D `app/` tooling (`t_shore_smoke.gd`, `t_water.gd`,
  `visual_tuning_test.gd`, `terrain_piece_render.py`, `tools/pieces/t6_*`) is explicitly
  **not** a 3D gate; reuse its acceptance ideas, never its harness.
  **Evidence:** `S/TEST_MATRIX.md:48-51`; `R/FINAL_GATE_PLAN_01.md:144-146`.
  **Label: observed.**
- [x] **I-4 — STATUS DONE.** The 2D `app\tools\godot_runner.py` gate pattern
  (`docs/coord_swarm_2026-11-24/FINAL_GATE.md:1-17`) is an acceptance template only;
  its commands are out of scope for the 3D final gate and must not overwrite 3D reports.
  **Evidence:** `R/FINAL_GATE_PLAN_01.md:175-178`. **Label: observed.**

---

## Summary

| Section | DONE | PARTIAL | OPEN | Header outcome |
|---|:--:|:--:|:--:|---|
| A — ownership/backups | 4 | 2 | 0 | partially complete |
| B — targeted smokes | 8 | 2 | 0 | job-level artifacts green per docs; B-10 HUD/load atoms ran FAIL / MEASUREMENT_ONLY, not PASS |
| C — integrated selftest/uitest | 0 | 1 | 4 | **selftest RED 28/29 (`build`)**; uitest 17/17 stale (QA-GATE-READY-02) |
| D — queue CLEAN | 3 | 0 | 5 | **DIRTY / exit 1**; 17→18 unacked (16 skipped + 494 + 516 timed-out); pending 7→3, lock HELD, 1 Godot; runner patch D-8 APPLIED_AS_APPROVED |
| E — ladder P0–C4/S1/FINAL | 0 | 3 | 8 | stopped at P0; P0 CONFIRMED_PASS re-affirmed; P1–C4/S1 never run as rows |
| F — capture re-checks | 1 | 1 | 2 | protocol exists, 3 `RECHECK_*.md` landed (P0/S1 only); P1–C4 uncovered |
| G — decomp/corrections docs | 6 | 1 | 1 | 63 corrections indexed in both README and CORRECTIONS.md; board lag only (G-7 re-synced) |
| H — visual review / A/B | 1 | 2 | 3 | **owner review + donor A/B UNVERIFIED**; white marks reproduced (H-6), relief not visible |
| I — 2D gates | 3 | 1 | 0 | **CONFIRMED_GREEN** at jobs 1348/1349; current tree UNVERIFIED here |
| **TOTAL** | **26** | **13** | **23** | **NOT_READY_FOR_FINAL_GATE** |

**Derived roll-up:** there are **23 OPEN** items and **13 PARTIAL** items. Per the
explicit authorisation rule above, **COORD must not run the FINAL gate until every OPEN
item in A–I is closed** — specifically: integrated selftest fresh 29/29 (C-1/C-3/C-5;
`R/QA_GATE_READY_02.md:135,188` still `passed:false`, 28/29, `build`; MAP-SMALL-01 reverted
both owned files, so no 29/29 fix landed — `R/MAP_SMALL_01_report.md:6`), COORD ladder
advancement of the now-confirmed P0 row (E-P0: job `504` `PASS 22/22` +
`RECHECK_P0_FINAL.md` CONFIRMED_PASS, re-affirmed by `R/QA_GATE_READY_02.md:150-151,190`,
but no row advanced), a quiet CLEAN queue with zero unacked failure-status jobs
(D-1…D-4: newest polls `pending` 7→3, lock HELD 237.2→38.2 s, 1 Godot alive, DIRTY/exit
1, unacked 17→18 = 16 skipped + tickets 494 and 516 timed-out), all in-flight builders
released (A-5/D-5), every ladder row P1→C4/S1 windowed and green with a landed
second-agent `RECHECK_<ROW>.md` (E/F — only P0 and S1 have re-checks), owner visual review
(H-1/H-3) and the 2D current-tree re-check (I-2). Newly landed evidence is recorded
without promotion: the runner patch is `APPLIED_AS_APPROVED` (D-8) but no solo post-patch
gate ran; the HUD/load atoms ran but returned FAIL / `MEASUREMENT_ONLY__NO_PASS_CLAIM`
(B-10); the white-marks symptom is reproduced with no visible relief (H-6); the
corrections index is 63 in both README and CORRECTIONS.md (G-2/G-7). Donor visual parity
(H-2) remains **UNVERIFIED** by standing rule and is never converted to PASS by a green
gate.

**Labels on the roll-up:** counts are `derived` from the item statuses above; the rule
that FINAL is COORD-only and last is `observed` (`S/SWARM_BOARD.md:122`;
`S/TEST_MATRIX.md:27,65-66`; `R/FINAL_GATE_PLAN_01.md:206-207`); the queue, session and
artifact numbers remain point-in-time `observed` snapshots (`R/QA_GATE_READY_02.md:11,
46-120`; earlier `R/GATE_READY_01.md:10,128-133`); donor parity is `UNVERIFIED`
(`S/CORRECTIONS.md:132`).

**Refresh note (FINAL-CHECK-REFRESH-02):** targeted edits only — frontmatter
`status`/`scope`/`snapshot_caveat`/`sources_read` (+ `refreshed_by`/`refresh_date`), A-6,
B-10 (new), C-1/C-2 citations, D-1…D-4, D-8 (new), E-P0, F-2, G-2, G-4, G-6, G-7, H-1,
H-6 (new), I-2, the B/D/E/G/H/I summary header cells, the TOTAL row and the derived
roll-up. §0 (citation shorthand, labels, governing-rules table and the FINAL-GATE
AUTHORISATION blockquote) was preserved byte-identical as instructed; its stale "(§F)"
clause is still corrected by the §F item it cross-references. No status was weakened and
no PASS invented: C-1/C-2, D-1…D-4, E-P0/E-S1, F-2, I-2 and H-6 were **not** promoted;
B-10/D-8/H-6 record new evidence at honest scopes. Counters 25/11/23 → **26/13/23**
(three new items: D-8 DONE, B-10 + H-6 PARTIAL). The earlier FINAL-CHECK-REFRESH-01 pass
(24/11/24 → 25/11/23, G-7 closure only) is documented in `R/FINAL_CHECK_REFRESH_01.md`.
Per-item before→after with evidence is in `R/FINAL_CHECK_REFRESH_02.md`.

---

*End of FINAL-CHECKLIST-01 (stale items refreshed by FINAL-CHECK-REFRESH-02). This file
and `reports/FINAL_CHECK_REFRESH_02.md` only; no code, test, config, fixture, result-JSON,
git or runner-state mutation; no donor access; no Godot job submitted.*
