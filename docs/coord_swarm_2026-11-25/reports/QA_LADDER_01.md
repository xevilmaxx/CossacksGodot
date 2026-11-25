---
id: QA-LADDER-01
title: "Re-evaluation of the 64² ladder row status after P0 confirmation, dark-row repairs and stale-result quarantine"
owner: QA-LADDER-01 (read-only QA subagent)
date: 2026-11-25
status: DONE__REPORT_ONLY__NO_RUNNER_JOB__NO_CODE_EDIT__NO_LADDER_ADVANCE
scope: "Exclusive output: docs/coord_swarm_2026-11-25/reports/QA_LADDER_01.md. No Godot submission, no code/test/shader/config/fixture/result-JSON edit, no donor access, no row declared PASS, no ladder advance."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
labels: [observed, derived, inferred, UNVERIFIED]
snapshot: "Live worktree read in this QA pass (2026-11-25, after the 12:02 local report writes). All mtimes are point-in-time observations; local time = UTC+1 on this host, so UTC times quoted in the cited reports appear one hour earlier here."
parity_guard: "PORT APPROX — internal consistency only. No donor GPU A/B frame exists; every verdict below is about the port's own artifacts and gates. No donor parity is claimed or assessed (TEST_MATRIX.md:32-34,73-74)."
other_files_edited: false
---

# QA-LADDER-01 — 64² ladder row status, re-evaluated

## 0. Mandate, label key and boundary

This is a **read-only re-evaluation** of the piece→combo ladder after three events: (a) the
post-final-LIGHT-02-formula P0 capture and its second-agent confirmation, (b) the dark-row
applicability edits to the seven atoms P1–C4, and (c) the quarantine of the stale P3
false-green result. It verifies which result JSONs exist on disk today, whether each is
fresh relative to its atom source, whether a `RECHECK_<ROW>.md` exists, and what the
current JSON actually says. It then names the next two runner commands COORD can use and
restates the stop policy.

- **observed** — read directly from a file, command output, or filesystem mtime/hash this pass.
- **derived** — arithmetic/structural consequence of observed values (e.g. source newer than JSON ⇒ stale).
- **inferred** — reasoned reading, explicitly caveated, not directly stated in a source.
- **UNVERIFIED** — cannot be established from available material (above all donor parity, and the visual half of S1).

No runner job was submitted and no row is advanced by this report. Per `CAPTURE_RECHECK.md:249` and
`TEST_MATRIX.md:57-59`, **COORD alone** authorises rows; `FINAL` stays COORD-only and last.
No donor GPU A/B frame exists, so nothing here is a parity claim.

## 1. Sources

### Required documents read (all read-only)

| Source | What it supplies |
|---|---|
| `docs/coord_swarm_2026-11-25/TEST_MATRIX.md` | Ladder rows P0→S1→F (:14-27), 64² reuse and criteria (:29-51), sequential/second-agent/stop/windowed protocol (:53-75). |
| `docs/coord_swarm_2026-11-25/CAPTURE_RECHECK.md` | Second-agent role, four-artifact set, exact inspection commands, per-row checklists, image rules, ownership and attribution (:0-6). |
| `docs/coord_swarm_2026-11-25/reports/P0_FRESH_CAPTURE_01.md` | Ticket 504 `p0fresh01-capture`, final-formula timing proof, P0 `PASS 22/22`, measured luma, `READY_FOR_LADDER`. |
| `docs/coord_swarm_2026-11-25/reports/RECHECK_P0_FINAL.md` | Independent `P0 CONFIRMED_PASS`; 11 PASS / 0 FAIL / 1 N/A; COORD cleared to decide P1; no advancement. |
| `docs/coord_swarm_2026-11-25/reports/RECHECK_S1.md` | S1 atom `PASS 23/23`, image `UNVERIFIED (NO PNG)`, and shared-JSON overwrite provenance caveat (§7). |
| `docs/coord_swarm_2026-11-25/reports/DARKROW_ALL_01.md` | Seven atoms edited; all validation was `--check-only` (`:101-151`); §5.3 says no runtime/PNG/luma proof and P1–C4 remain UNVERIFIED. |
| `docs/coord_swarm_2026-11-25/reports/QA_ATOM_STALE_02.md` | Atom-vs-result mtime table (`:35-57`), seven stale atoms, darkrowall jobs emitted no JSON (`:74-100`), P3 false-green (`:102-118`). |
| `docs/coord_swarm_2026-11-25/reports/P3_RESULT_CLEAN_01.md` | Move-only quarantine of `t_terrain_mines.json`; SHA-256 preserved; no fresh P3 result until a windowed row. |
| `docs/coord_swarm_2026-11-25/reports/QA_UX_DOC_01.md` | UX/loading documentation audit; included as required reading; it makes no ladder-status or parity claim and is not used to advance any row. |

### Supporting sources (read/observed this pass)

| Source | Use |
|---|---|
| `reports/DARKROW_REPAIR_01.md` | Redundant/closed verification; explains C2's 11:48:28 mtime drift (edit reverted, bytes unchanged, hash `502e2f01…`). |
| `reports/RUNNER_FIX_01.md`, live `godot_runner.py --help` / `status` | Runner CLI (`--id`, `--timeout`, `--max-wait`), patched mutex present on disk, queue not drained at QA read. |
| `reports/TEST_P1_report.md:117-126`, `reports/TEST_P2_report.md:104-127` | Documented windowed launch forms and `--p0-png` / `--png-t1` user args. |
| `variant3d/tests/t_terrain_trees.gd:342-361,719-734,925-999` and `t_terrain_shore.gd:675-688,605-622` | Confirmed arg handling, P0-baseline requirement, two-frame/motion capture. |
| Live filesystem probes (`python` 3.14) | `variant3d/tests/*.gd` and `variant3d/tests/results/*.json` mtimes/sizes, JSON fields `passed`/`verdict`/`status`/`passes`/`fails`, `RECHECK_*.md` existence, quarantine file, `git status`, C2 hash. |

## 2. Row table — current on-disk status

Times are **local** (`datetime.fromtimestamp`); a UTC value quoted in a cited report is one hour lower.
"STALE" means the atom source is newer than the result JSON, so the JSON cannot certify current source.
JSON verdicts are the **literal fields in the file that exists today**, not a claim that the result is valid.

| Row / atom | Result JSON exists? | Freshness: source vs JSON | RECHECK report exists? | Current JSON verdict (literal) | QA verdict / next action |
|---|---|---|---|---|---|
| **P0** `t_terrain_only` | **Yes** — `t_terrain_only.json`, 5,658 B, mtime **11:41:12** (= 10:41:12 UTC, ticket 504) | Source 10:33:57 < JSON 11:41:12 ⇒ **CURRENT**; PNG 11:41:11 local postdates shader edit 09:53:34 UTC by ~47 min 37 s (**observed** in `P0_FRESH_CAPTURE_01.md:12,67-73`; `RECHECK_P0_FINAL.md:131-147`) | **Yes, two**: `RECHECK_P0.md` (11:36:47, historical gap finding) and `RECHECK_P0_FINAL.md` (11:45:29, confirmation) | `passed=true`, `verdict=PASS`, `passes=22`, `fails=0`, `skipped=1`, `structural_ok=true`, `capture_status=PASS` | **P0 CONFIRMED_PASS** on PORT APPROX gates (`RECHECK_P0_FINAL.md:219-241`). No new P0 capture needed. COORD may authorise P1; this QA does not advance. |
| **P1** `t_terrain_trees` | **Yes** — 7,663 B, mtime **10:08:38** | Source 11:05:08 > JSON 10:08:38 ⇒ **STALE** by 3,390 s; DARKROW-ALL added two luma gates and record-only dark-row (:72) | **No** | `passed=false`, `verdict=FAIL`, `passes=21`, `fails=1` — pre-edit artifact | Not runnable "as is": **needs a fresh windowed P1 capture**, then second-agent `RECHECK_P1.md`. Next row in strict order. |
| **P2** `t_terrain_shore` | **Yes** — 9,309 B, mtime **10:00:45** | Source 11:06:28 > JSON 10:00:45 ⇒ **STALE** by 3,943 s; DARKROW-ALL added luma gates, kept strict dark-row (:73) | **No** | `passed=false`, `verdict=UNVERIFIED`, `passes=16`, `fails=10` — pre-edit artifact | **Needs a fresh windowed P2 capture** with two frames 1 s apart (`--png` + `--png-t1`) and a second-agent `RECHECK_P2.md`. Submit only after P1 re-clear. |
| **P3** `t_terrain_mines` | **No** — absent from `results/` (quarantined; see §4) | Source 11:36:50; no JSON to compare ⇒ **NO VALID RESULT** | **No** | No current result. The removed artifact read `passed=true`, `13/13`, `headless=true`, `HEADLESS_STRUCTURAL_ONLY__PNG_UNVERIFIED` (`P3_RESULT_CLEAN_01.md:21-48`) | **Needs a fresh windowed P3 capture**; must genuinely evaluate the three former headless-skip rows. Do **not** carry 13/13 forward. |
| **C1** `t_combo_trees_shore` | **Yes** — 7,659 B, mtime **10:01:16** | Source 11:08:06 > JSON ⇒ **STALE** by 4,010 s | **No** | `passed=false`, `verdict=FAIL`, `passes=22`, `fails=2`, `skipped=4` | **Needs fresh windowed C1 capture** + `RECHECK_C1.md`, only after P3 clears. |
| **C2** `t_combo_trees_mines` | **Yes** — 5,793 B, mtime **10:01:35** | Effective source is post-DARKROW-ALL (11:13:01) > JSON ⇒ **STALE** by 4,286 s. File mtime now reads **11:48:28**, but SHA-256 equals `.bak-DARKROWREPAIR` (`502e2f01…`) — a reverted edit's timestamp drift, **not** a semantic change (`DARKROW_REPAIR_01.md:78-88,114-116`; hash re-verified this pass) | **No** | `passed=false`, `verdict=FAIL`, `passes=25`, `fails=3` — counts computed by `check()` code that no longer exists | **Needs fresh windowed C2 capture** + `RECHECK_C2.md`. Treat staleness as content-based, not just mtime-based. |
| **C3** `t_combo_shore_mines` | **Yes** — 5,134 B, mtime **10:02:43** | Source 11:10:03 > JSON ⇒ **STALE** by 4,040 s | **No** | `passed=false`, `verdict=SKIP_CAPTURE`, `passes=12`, `fails=0` — no capture | **Needs fresh windowed C3 capture** + `RECHECK_C3.md`. |
| **C4** `t_combo_all` | **Yes** — 923 B, mtime **10:03:15** | Source 11:11:11 > JSON ⇒ **STALE** by 4,077 s | **No** | `passed=false`, `status=SKIPPED_HEADLESS`, `passes=0`, no `verdict` | **Needs fresh windowed C4 capture** + `RECHECK_C4.md`. |
| **S1** `t_select_rect` | **Yes** — 6,563 B, mtime **11:33:36** (= 10:33:36 UTC) | Source 10:27:33 < JSON 11:33:36 ⇒ **CURRENT by mtime**, **but** provenance is ambiguous: JSON was overwritten by later agents (first read carried job 438 markers, second read job 495 `audiosel02-drag` markers) — `RECHECK_S1.md:149-158` | **Yes** — `RECHECK_S1.md`, 11:39:13 | `passed=true`, `passes=23`, `total=23`, `run_mode=windowed_real_input`; no `verdict`/`capture_status` field. Second-agent image verdict: `UNVERIFIED (NO PNG)` | **Artifact PASS 23/23, visual UNVERIFIED, provenance UNVERIFIED.** S1 is **not** the next row (strict order puts it after C4). A fresh S1-exclusive windowed run is advised if COORD wants unambiguous provenance (`RECHECK_S1.md:168,175-177`). |

**Derived counts (live):** 1 CURRENT with confirmation (P0), 1 CURRENT-but-provenance-ambiguous (S1),
6 STALE pre-edit JSONs (P1, P2, C1, C2, C3, C4), 1 absent (P3). **0** RECHECK reports exist for P1–C4;
only P0 (two) and S1 (one) do. These counts are point-in-time observations of a live worktree.

### Which rows can be run next

- **Only P1 is eligible to be submitted next**, and only as a **new, fresh, windowed** job — nothing in
  `results/` for P1 may be reused. Its prerequisite is met: P0 is confirmed and COORD is cleared to
  decide P1 (`RECHECK_P0_FINAL.md:236-241`).
- **P2 becomes eligible only after** a fresh P1 result JSON exists **and** its PNG/stderr have been
  re-checked by a second agent (`TEST_MATRIX.md:58-59`; `CAPTURE_RECHECK.md:1.1,4`).
- **P3–C4** are not eligible yet: each needs its own fresh windowed row in order, one ticket each;
  P3 additionally has **no** valid result JSON at all.
- **S1** is not eligible next (order), and even when reached its existing JSON needs a COORD decision
  on the overwrite caveat; an S1-exclusive fresh run would remove that ambiguity.
- **No row may be declared PASS on the evidence currently in `results/` except P0.** Headless,
  `SKIP_CAPTURE`, `SKIPPED_HEADLESS` or stale JSONs are not PASS (`TEST_MATRIX.md:62-64`;
  `CAPTURE_RECHECK.md:56-60,266`).

## 3. Dark-row repairs: parse-only evidence, no windowed P1–C4 capture

- **Observed:** `DARKROW_ALL_01.md:20,101-128` describes **seven headless `--check-only` jobs**, one per
  atom (tickets 475, 486, 493, 501, 505, 506, 507), all `END ok` with `SCRIPT ERROR == 0` and 0-byte
  stderr. `DARKROW_REPAIR_01.md:53-70` reuses those same artifacts and submits no new job.
- **Observed:** `DARKROW_ALL_01.md:144-151` states explicitly that `--check-only` proves parse/compile
  validity only — **not** runtime assertion outcomes, not PNG appearance, not `mean_luma`/`max_luma`
  values — and that ladder rows P1–C4 remain UNVERIFIED; no windowed frame was captured by that ticket.
- **Derived:** the new strict gates `ground_mean_luma >= 40` and `ground_max_luma >= 100` added to all
  seven atoms have been exercised on **P0 only** (ticket 504/496-style windowed capture), and P0 was
  **not** among the seven edited atoms (`QA_ATOM_STALE_02.md:98,139-140`). Therefore the post-edit
  behaviour of P1–C4 is untested at runtime.
- **Observed:** no result JSON path in `variant3d/tests/results/` has an mtime newer than 11:41:12
  (P0), and none of the newer files belongs to P1–C4 — see the newest-20 listing captured this pass.
  No windowed P1–C4 PNG/result pair exists.
- **S1 provenance caveat (observed, from `RECHECK_S1.md:149-158`):** the canonical
  `t_select_rect.json` is a shared file overwritten by repeated agents reusing the atom; its internal
  `screenshot_arg` / `unix_ms` markers identify job 438 on one read and job 495 on the next, not the
  task-nominated job 414. The 23/23 result is reproduced by three independent windowed jobs
  (414, 438, 495), which is **internal consistency, not donor parity**; job 414's stdout is intact.
  No PNG of the real drag exists, so the visual half stays UNVERIFIED.

## 4. Stale P3 result — quarantine confirmed

- **Observed (live):** `Test-Path` equivalent for `variant3d/tests/results/t_terrain_mines.json` is
  **False**; the results directory holds **63** JSON files (64 before the quarantine).
- **Observed (live):** the quarantined copy exists at
  `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\quarantine\t_terrain_mines.stale.json`
  — 4,618 B, mtime 2026-11-25 10:00:59 local, matching `P3_RESULT_CLEAN_01.md:69,77-84`.
- **Observed:** `git status --short` shows `D variant3d/tests/results/t_terrain_mines.json`.
- **Derived:** the stale false-green (`passed:true`, `13/13`, `headless:true`, three visual rows counted
  as passes with non-PASS statuses) is no longer visible to any consumer of `results/`.
- **UNVERIFIED:** whether a future windowed P3 run will keep the headless guard rows in the pass count —
  a re-run may mask rather than correct that counting pattern (`QA_ATOM_STALE_02.md:153`;
  `P3_RESULT_CLEAN_01.md:95`).

## 5. Exact next two runner commands (for COORD)

**Preconditions (observed at QA read):** `python variant3d\tools\godot_runner.py status` reported
`now_serving=521`, `next_ticket=524`, `pending=3 [521,522,523]`, `godot.lock=HELD (age 15.1s)`,
max observed wait 1,825.52 s. The patched runner's mutual-exclusion code is present on disk
(`claim_godot_lock(ticket)`, `spawned_pids`), so COORD should wait for a clean gate window
(`pending=0`, `godot.lock=free`, no live Godot) **or** submit strictly one job at a time with a
generous wait. Windows `python` (3.14), never `python3`; **runner only**, never direct `godot`;
unique ids; tool timeout ≥ 300000 ms (background submission if the queue may exceed it); **never
re-submit a pending job** (`AGENT_PROTOCOL.md:39-52`; `TEST_MATRIX.md:70-72`).

The PNG directory below is created recursively by the atoms; the P0 baseline path is the *existing*
fresh final-formula PNG verified this pass (2,129,263 B, mtime 11:41:11 local).

**1 — P1 `t_terrain_trees.gd` (windowed, fresh, unique id):**

```
python variant3d\tools\godot_runner.py run --id qaladder01-p1-fresh --timeout 300 --max-wait 2400 -- --path variant3d --script res://tests/t_terrain_trees.gd -- --screenshot C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/qaladder01/smallmap64_terrain_trees.png --png C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/qaladder01/smallmap64_terrain_trees.png --p0-png C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/p0fresh01/p0_final_formula.png
```

- No `--headless` (headless ⇒ `SKIP_CAPTURE`, not PASS). Both `--screenshot` and `--png` are accepted
  (`t_terrain_trees.gd:725-727`); `--p0-png` is **required** because the default derivation from the
  new screenshot name would not find the baseline (`t_terrain_trees.gd:351-361,990-996`), which would
  emit `SKIPPED_NO_BASELINE` for the four diff checks.

**2 — P2 `t_terrain_shore.gd` (windowed, fresh, unique id) — submit only after P1 clears:**

```
python variant3d\tools\godot_runner.py run --id qaladder01-p2-fresh --timeout 300 --max-wait 2400 -- --path variant3d --script res://tests/t_terrain_shore.gd -- --png C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/qaladder01/smallmap64_terrain_shore.png --png-t1 C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/qaladder01/smallmap64_terrain_shore_t1.png
```

- Two frames 1 s apart are required for `water_animation_delta` (`t_terrain_shore.gd:605-668`;
  `CAPTURE_RECHECK.md:52,141`); both frames and, where available, `frames.json` must be opened by the
  second agent. P2 is a **water-bearing** row, so the strict `png_full_width_dark_rows == 0` gate
  applies and must not be relaxed (`DARKROW_ALL_01.md:59-62,73`).

After each job: read `variant3d/tests/results/<atom>.json`, apply the read-only
`smallmap_capture.py stats <png>` and `scan-stderr <stderr.txt>` commands from
`CAPTURE_RECHECK.md:62-83`, open the PNG, and have a **second agent** record
`reports/RECHECK_<ROW>.md` before COORD authorises the next row.

### Stop policy (restated, unchanged)

1. **Strict order, one ticket per row:** `P0 → P1 → P2 → P3 → C1 → C2 → C3 → C4 → S1 → FINAL`
   (`TEST_MATRIX.md:57`; `CAPTURE_RECHECK.md:249`).
2. **Stop at the first failing row.** Record the exact failed assertion and route it to the owning fix
   ticket; do **not** submit the next row and do **not** rerun hoping for green (`TEST_MATRIX.md:60-61`;
   `CAPTURE_RECHECK.md:254-256`). A rerun is permitted only after an actual fix lands and COORD re-opens the row.
3. **No weakening:** no threshold lowered, no assertion deleted, no `expected_pre_fix_failure` marker
   flipped, no stale/headless/SKIP result converted into PASS (`TEST_MATRIX.md:62-68`;
   `CAPTURE_RECHECK.md:265-267`). An inapplicable predicate needs a separate evidence-backed ticket with
   an equally strict replacement, as in P0-GATE-01.
4. **Attribution by owning file, not symptom** (`CAPTURE_RECHECK.md:256-264`): load/parse failure → atom
   load owner; `SCRIPT ERROR != 0` → script/stderr owner; structural mismatch → terrain module owner;
   category purity → entity/resource owner; luma/visual defect → terrain render/lighting owner; water-band
   or motion failure on a water-bearing row → shore/water owner; S1 overlay/selection → input/selection owner.
   A skipped/timeout/banner-only runner job is an **infrastructure** finding for the runner owner, not a
   row PASS and not a reason to re-queue blindly (`DARKROW_ALL_01.md:130-142`; `RUNNER_FIX_01.md:354-393`).
5. **Metrics never override the image**, and visual PASS is never inferred from `stats` alone; donor
   parity remains UNVERIFIED throughout (`TEST_MATRIX.md:73-74`; `CAPTURE_RECHECK.md:234-240,267`).
6. **FINAL is COORD-only and last**; a green ladder row is not a final-gate certificate
   (`TEST_MATRIX.md:27,65-66`; `CAPTURE_RECHECK.md:250`).

## 6. Verdict

- **P0 (observed/derived):** CONFIRMED_PASS on the port's own gates; fresh final-formula windowed
  capture exists; second-agent confirmation exists. **Cleared, not advanced.**
- **P1–C4 (observed/derived):** every result JSON is pre-edit and stale (P3 absent entirely); no
  `RECHECK_<ROW>.md` exists for any of them; the dark-row repairs were `--check-only` only; **all five
  need fresh windowed captures** and second-agent re-checks before any row-level PASS.
- **S1 (observed/UNVERIFIED):** current JSON is fresh by mtime and its 23/23 artifact result is
  reproduced by three windowed jobs, but there is no drag PNG (image verdict UNVERIFIED) and the shared
  JSON's provenance is ambiguous. Not next in ladder order; a fresh S1-exclusive run is advised.
- **Next runner rows:** P1, then P2, using exactly the two commands in §5, with the §5 stop policy.
- **No parity claim:** all results are `PORT APPROX — internal consistency only`; donor GPU A/B remains
  blocked and UNVERIFIED. No row was submitted, re-run, or declared PASS by this QA worker.

## 7. Open questions

1. **Runner gate window (observed → COORD decision):** queue was not drained at QA read (`pending=3`,
   `godot.lock=HELD`). Will COORD wait for `pending=0` before the §5 submissions, or accept FIFO waits with
   `--max-wait 2400`? (`RUNNER_FIX_01.md:354-366`.)
2. **Runtime luma gates (UNVERIFIED):** whether post-edit P1–C4 frames clear `>=40` / `>=100` is untested;
   `--check-only` cannot answer it (`DARKROW_ALL_01.md:182-184`).
3. **P2 authored markers (observed from reports, runtime UNVERIFIED):** `TEST_P2_report.md:100-102`
   lists `EXPECTED_PRE_FIX_FAILURE` rows; if they still fail on a healthy frame, the stop rule applies and
   a separate owner ticket — not a weakened atom — is required.
4. **C2 mtime (resolved, recorded):** 11:48:28 reflects an edit/revert with byte-identical hash
   (`DARKROW_REPAIR_01.md:114-116`; re-verified this pass). Future staleness checks should use hashes as
   well as mtimes.
5. **S1 evidence acceptance (UNVERIFIED — COORD decision):** whether to accept `RECHECK_S1.md`'s
   JSON/stdout-only verdict, and whether to fund a fresh S1-exclusive windowed run for unambiguous
   provenance and a drag PNG (`RECHECK_S1.md:168,175-177`).
6. **P3 guard counting (UNVERIFIED):** a windowed P3 re-run must genuinely evaluate the three visual
   rows; whether the headless-skip pass-count pattern is corrected or merely masked remains open
   (`QA_ATOM_STALE_02.md:153`).
7. **Live worktree (UNVERIFIED):** other agents are still editing docs/tests (several reports and atoms
   changed during the cited audits). These mtimes are a snapshot, not a final state.
8. **Donor A/B (UNVERIFIED):** no matched donor GPU frame exists; hue/grain/luma fidelity and all
   visual-parity claims remain blocked (`TEST_MATRIX.md:46,73-74`).

## 8. Summary

- Read all nine required documents plus supporting repair/runner/launch sources; probed the live
  filesystem for result JSONs, atom mtimes, RECHECK reports, the quarantine file, git status and the
  C2 hash.
- **P0:** one CURRENT result with two recheck reports — CONFIRMED_PASS (PORT APPROX).
- **P1, P2, C1, C2, C3, C4:** six STALE pre-edit result JSONs, zero recheck reports; **P3:** result
  quarantined and absent from `results/` — confirmed. All seven require fresh windowed ladder rows.
- **S1:** CURRENT by mtime with a recheck report, but JSON/stdout-only evidence, no PNG, and a
  documented overwrite/provenance caveat; not eligible next.
- Dark-row repairs are parse-only (`--check-only`); no windowed P1–C4 capture exists; S1's shared JSON
  is overwritten by repeated agents.
- Gave COORD the exact next two windowed runner commands (`qaladder01-p1-fresh`, `qaladder01-p2-fresh`)
  with unique ids and the unchanged stop policy.
- **No donor parity claim, no runner job, no code/result edit, no ladder advance by this worker.**

---

*End of QA-LADDER-01. Read-only QA record only.*
