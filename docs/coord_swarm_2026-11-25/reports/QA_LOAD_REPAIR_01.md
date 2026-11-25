---
id: QA-LOAD-REPAIR-01
title: "QA-LOAD-REPAIR-01 — read-only verification of LOAD-PROBE-REPAIR-01's atom fix after landing"
owner: read-only QA subagent
date: 2026-11-25
status: REPAIR_VERIFIED__MEASUREMENT_ONLY_UPHELD__NO_PASS_PROMOTION
scope: "Read-only QA. No code edits, no runner jobs, no queue mutation, no result-JSON edits, no gate claims. Sole authored output is this report."
owns:
  - "docs/coord_swarm_2026-11-25/reports/QA_LOAD_REPAIR_01.md"
labels: [QA, LOAD, POST_LOAD_USABILITY, HARNESS_REPAIR, VERIFICATION_ONLY, NO_PASS_PROMOTION]
evidence_labels: [observed, derived, inferred, UNVERIFIED]
inputs_read:
  - "docs/coord_swarm_2026-11-25/reports/LOAD_PROBE_REPAIR_01.md"
  - "docs/coord_swarm_2026-11-25/reports/LOAD_PROBE_RUN_01.md"
  - "docs/coord_swarm_2026-11-25/reports/LOAD_PROBE_01.md"
  - "variant3d/tests/t_load_usability.gd (current, post-repair)"
  - "inbox/backup/t_load_usability.gd.bak-LOADPROBEREPAIR (pre-repair)"
  - "variant3d/tests/results/t_load_usability.json (atom result)"
  - "variant3d/.godot_queue/results/00000547.json (runner result, job loadproberepair01-run)"
  - "variant3d/.godot_queue/results/00000547_loadproberepair01-run/stdout.txt"
  - "variant3d/.godot_queue/results/00000547_loadproberepair01-run/stderr.txt"
  - "docs/coord_swarm_2026-11-25/SWARM_BOARD.md; docs/coord_swarm_2026-11-25/OWNER_FAULTS.md"
---

# QA-LOAD-REPAIR-01 — read-only verification of the LOAD-PROBE-REPAIR-01 atom fix

## 1. Sources and landing state

| Source | Role | State (label) |
|---|---|---|
| `reports/LOAD_PROBE_REPAIR_01.md` | Repair log / validation run under audit | **Observed:** absent on this QA's first directory glob and first report-name listing; present on a later `Test-Path` check during this same QA turn (`REPAIR_REPORT_EXISTS=True`, frontmatter `status: MEASUREMENT_ONLY__NO_PASS_CLAIM__REPAIR_VALIDATED`, 263 lines). Landing condition met **while QA was running**. |
| `reports/LOAD_PROBE_RUN_01.md` | Pre-repair baseline (ticket 531) | **Observed:** 262 lines; wall-cap at frame 1742, `overlay_frames=0`, camera frame `-1`, probe-side format ERROR at old `:518`. |
| `reports/LOAD_PROBE_01.md` | Original atom design / criterion contract | **Observed:** 252 lines; assertion table `:131-143`, "no criterion relaxed" statement `:145-147`. |
| `variant3d/tests/t_load_usability.gd` | Post-repair atom (661 lines) | **Observed:** repaired; `git status` = ` M` (modified, uncommitted on disk). |
| `inbox/backup/t_load_usability.gd.bak-LOADPROBEREPAIR` | Pre-repair atom (578 lines) | **Observed:** present; `git status` = `??`. Used as diff base. |
| `variant3d/tests/results/t_load_usability.json` | Atom-written result | **Observed:** 279 lines; `git status` = ` M`; `unix_ms: 1795607262024.0` (later than ticket-531's `1795605663650.0`). |
| `variant3d/.godot_queue/results/00000547.json` | Runner result for `loadproberepair01-run` | **Observed:** ticket `547`, `id: loadproberepair01-run`, `status: ok`, `exit: 0`, `wait: 237.04 s`, `run: 91.88 s`, `timeout: 300.0`, `created: 1795606935.1738272`. Contains **no `measured` block** — measured fields live in the atom JSON above. |
| `.../00000547_loadproberepair01-run/stdout.txt` | Atom stdout | **Observed:** 4 lines; `:3` result-JSON write, `:4` `T_LOAD_USABILITY VERDICT: MEASUREMENT_ONLY__NO_PASS_CLAIM`. |
| `.../00000547_loadproberepair01-run/stderr.txt` | Hard-error evidence | **Observed:** 62 lines; zero `SCRIPT ERROR`, zero `String formatting error`, zero `t_load_usability.gd:` backtrace; one exit-time `ERROR: 1 resources still in use at exit` at `:61`. |
| `SWARM_BOARD.md:348`, `OWNER_FAULTS.md:13,59,75-76,100,118-119` | Pre-landing board state | **Observed (stale snapshot):** both atom-repair rows still `RUNNING`, "no report". Not treated as current after the report landed. |

**Method (observed):** a Python `difflib.unified_diff` of backup → current atom; direct reads of all three JSON/stdout/stderr artifacts; PowerShell `Select-String` counts on the repair-run stderr; `git status --short` limited to the four relevant paths. No `godot`, runner command, or `scan-stderr` job was launched by QA; the stderr classification is a direct read, not a claimed re-run of the repair owner's scan.

## 2. Verification table

Labels are per row: **Observed** = read directly from a file; **Derived** = conclusion from comparing observed artifacts; **Inferred** = interpretive judgement; **UNVERIFIED** = not established by this QA.

| # | Check from task | Result | Label | Evidence |
|---|---|---|---|---|
| V0 | Repair landed | **Yes** — report present by end of QA; atom modified; backup present | Observed | `Test-Path` result; `git status`: ` M` atom, `??` report + backup. First glob of this turn showed no repair report; it appeared mid-turn (honest state transition, not a back-dated claim). |
| V1 | `%d` format fix | **Confirmed in code and at runtime** | Observed + Derived | Backup `:518-521` and `:502-503` concatenated `"..." + "..." % [args]`; current `:601-605` and `:580-582` wrap the concatenation in parentheses before `%`. Two sites, matching repair report §3 rows 10/12 and §3's "two format expressions" note. Runtime: job-547 stderr has **0** `SCRIPT ERROR`, **0** `String formatting error`, **0** atom backtrace; the atom JSON `(d)` detail now reads `... Proxies over 30 frames: violations=11, max_inter_frame_gap_post_us=33515827 (heuristic ceiling 250000)` — numeric, no literal `%d` (contrast ticket 531's unsubstituted placeholders). |
| V2 | Overlay sampled from first frame | **Confirmed** | Observed + Derived | Current `_process()` `:247-261` moves `_phase_loading(now, gap)` out of the `match`; on frame 1 `_phase_boot()` sets `_phase = 2` (`:296`) and the `if _phase == 2 and not _probe_started` at `:259` fires in the same frame. Result JSON: `stage_log[0] = {stage:"Preparing...", frame:1, us:5443043}`, `overlay_first_us: 5443043`, `overlay_visible_frames: 28`, `overlay_stage_valid_frames: 28`, `staged_overlay_observed` OBSERVED/`true` (was UNVERIFIED/`false`). Detection now uses overlay **nodes** (`visible := layer_ok or stage_ok`, `:315`) instead of the always-false `loading_active`; raw `overlay_flag_active_frames: 0` retained. |
| V3 | Camera probe actually fires | **Confirmed** | Observed | `_begin_probes()` `:418-420` sets `_camera_request_issued` and calls `apply_external_target` unconditionally (guarded only by camera/method presence); distinct-target fallback at `:402-405`. Result JSON: `camera_request_issued: true`, `camera_target_before: [103.74, 41.44]`, `camera_target_requested: [72.0, 64.0]`, `response_frames.camera: 1` (window 30), `c_camera_response` OBSERVED/`true` (was OBSERVED/`false` at frame `-1`). The request and the observed target/eye movement are both recorded, so this is a real probe observation, not a fabricated response. |
| V4 | Wall-cap / phasing reaches stability, or honest `WINDOWED_REQUIRED` | **Reached stability phase** | Observed + Derived | Result JSON `frames: 60` (not 1742), `notes` contains only the unchanged Start-click-proxy limitation — **no wall-cap note**; `hide_frame: 29`, all three `response_frames` = 1, `stability_violations: 11`, `max_gap_post_us: 33515827`. Derived: completion came from `_phase_stability` → `_finish()` (`:497-498`), not the 120 s failsafe (`:239-242`). Repair report §8 `:209-218` states in prose that no windowed run was required **for this repair**, while keeping R3 title-bar drag / real Start click UNVERIFIED. **Caveat (Observed):** the literal token `WINDOWED_REQUIRED` does not exist anywhere in the repo; the honesty clause is satisfied by prose and by reaching stability, not by a machine-readable marker. |
| V5 | No criterion relaxed / deleted | **Upheld with one documented detection change** | Derived + Inferred | Diff shows all 11 `_record` ids retained (`real_64_game_boot` moved to boot phase; its detail string shortened but same render_mode/64×64/seed test). All six constants unchanged (`RESPONSE_FRAMES=30`, `STABILITY_FRAMES=30`, `MAX_FRAMES=3600`, `WALL_CAP_US=120000000`, `STALL_LIMIT_US=250000`, `POS_TOL_M=1.0`). (a), (d), (e) still `UNVERIFIED`/`null`; `staged_overlay_observed` still needs ≥1 overlay frame **and** ≥2 stage transitions (`:525`); (b) still needs all flags true at hide and first-seen ≤ hide (`:555-569`); (c) windows still 30 frames. `c_camera_response` became **stricter** (`:588-597`: `UNVERIFIED` if no request). **Inferred:** changing the overlay-presence gate from `active and layer_ok` to `layer_ok or stage_ok` is a detection repair for a game-side flag bug, not an acceptance-threshold relaxation; raw flag counts are preserved. A strict contract reviewer may still want this explicitly signed off by the atom owner — see Open question 1. |
| V6 | `MEASUREMENT_ONLY__NO_PASS_CLAIM` retained | **Confirmed** | Observed | Atom JSON: `verdict: MEASUREMENT_ONLY__NO_PASS_CLAIM`, `gate_claim: NONE`, `pass_claim: false`, `checks[].id: no_pass_claim` OBSERVED/`true`. `stdout.txt:4` prints the same verdict. Repair report `:35-36, :156, :256-257` makes no gate claim. |
| V7 | `SCRIPT ERROR` / probe-side error | **No `SCRIPT ERROR`; formatting ERROR eliminated** | Observed | Repair-run stderr `Select-String` counts: `SCRIPT ERROR` = 0, `String formatting error` = 0, `t_load_usability.gd:` = 0. Only `ERROR:` line is `1 resources still in use at exit` (`:61`), an exit-time resource message, not a GDScript parse/format failure. (e) remains `UNVERIFIED`/`null` — no "clean stderr" claim is made here either. |
| V8 | Result JSON for `loadproberepair01-run` present | **Present** | Observed | `00000547.json` (runner metadata only) + atom `t_load_usability.json` (measured fields) + stdout/stderr. All measured fields cited in V1–V4 were read directly, not taken on trust from the repair report. |
| V9 | (d) proxy outcome | **Numeric but breaching** | Observed + Derived | `stability_violations: 11` over 30 frames; `max_gap_post_us: 33515827` vs heuristic ceiling `250000`; (d) still `UNVERIFIED`/`null`. Derived: reaching the stability phase produced numbers; it did **not** make (d) pass. No promotion. |

**Cross-check of repair report claims (all Observed unless noted):** ticket 547 / `ok` / `exit 0` / 237.04 s wait / 91.88 s run match `00000547.json`; the before→after field table in repair report §5 matches the atom JSON field-for-field; the §7 `script_error_lines == 0` claim is consistent with this QA's direct stderr scan. No discrepancy found between the repair report and the artifacts read.

## 3. Verdict

**REPAIR VERIFIED — harness repairs are present, coherent and corroborated by the ticket-547 artifacts; `MEASUREMENT_ONLY__NO_PASS_CLAIM` upheld; NO PASS PROMOTION, NO GATE CLAIM.**

- **Verified at source level (Observed/Derived):** both `%d` sites parenthesised; overlay sampling moved to the first `_process()` frame and switched to real overlay nodes with raw counters retained; camera request issued unconditionally from `_begin_probes()` with a distinct target and recorded before/after; probe unit sourced from existing sim units (and the spawn fallback was **not** used in this run — `probe_unit_created_by_atom: false`); all criterion constants and all 11 check ids retained; camera row made stricter.
- **Verified at runtime level (Observed):** job `loadproberepair01-run` (ticket 547) ran the repaired atom and wrote `t_load_usability.json` with `frames: 60`, 28 overlay frames, `hide_frame: 29`, all three post-hide responses at frame 1, numeric (d) proxies, no formatting ERROR, and the unchanged no-pass verdict. The run reached the stability phase rather than the wall-cap.
- **Not promoted (UNVERIFIED):** (a) exact per-stage main-thread stall, (d) literal "no deferred heavy stage", (e) hard engine errors beyond the literal `SCRIPT ERROR` scan, the real Start-button click path, real windowed title-bar drag / paint during load (R3), real synthetic `InputEvent` delivery, and FX readiness. The breached (d) proxy is a negative observation, not a proven game fault and not a PASS.
- **Inferred (not proven by QA):** the `loading_active` flag behaviour is consistent with the root-cause narrative in `LOAD_PROBE_RUN_01.md` / repair report §3, supported by `overlay_flag_active_frames: 0` and 15 stage transitions; QA did not instrument `main.gd` and does not assign ownership of that game-side behaviour.

## 4. Open questions

1. **Detection gate sign-off [Inferred]:** should the atom owner explicitly confirm that replacing `visible = active and layer_ok` with `layer_ok or stage_ok` is an observation-only repair rather than a contract change? QA finds the acceptance thresholds untouched and raw flag counts preserved, but the gate change is what enables (b)/(c) to be observed at all.
2. **`WINDOWED_REQUIRED` marker [Observed]:** no such literal token exists anywhere in the repo. If future runs can hit the wall-cap again, should the atom emit a machine-readable `WINDOWED_REQUIRED` / explicit cap-reason field instead of relying on the prose scope statement in repair report §8?
3. **Runner JSON split [Observed]:** `00000547.json` carries only runner metadata; measured evidence lives in the atom's `t_load_usability.json`. Should downstream QA reports name both explicitly to avoid a "no measured fields" false negative?
4. **Stall interpretation [UNVERIFIED]:** ~21.48 s loading gap and ~33.52 s post-hide gap with 11 stability violations — genuine heavy work / post-overlay blocking, or headless frame-pump artefacts? Literal (a) still needs `main.gd` instrumentation; (d) remains a proxy.
5. **Windowed follow-up [UNVERIFIED]:** R3 window movability/paint and the real Start click still require a windowed run; this repair and this QA claim nothing about them.
6. **Board drift [Observed]:** `SWARM_BOARD.md:348` and `OWNER_FAULTS.md` snapshots still read `LOAD-PROBE-REPAIR-01 RUNNING / no report`. An owner refresh is needed so the landed report is not missed.

## 5. Summary

- **Observed:** `LOAD_PROBE_REPAIR_01.md` landed during this QA turn; the repaired atom, its backup, the `loadproberepair01-run` runner JSON, stdout/stderr and the atom result JSON were all read directly. Ticket 547: `ok`, `exit 0`, 237.04 s wait, 91.88 s run.
- **Observed:** the atom now completes in 60 frames: 28 overlay-visible frames, 15 stage transitions, hide at frame 29, all bindings true at hide, input/order/camera responses at frame 1 of 30, numeric (d) proxies, no `SCRIPT ERROR`, no format ERROR, and `MEASUREMENT_ONLY__NO_PASS_CLAIM` / `gate_claim: NONE` / `pass_claim: false` retained.
- **Derived:** both `%d` defects are fixed; overlay sampling starts on the first frame and uses real nodes; the camera request genuinely fires; the run reached the stability phase, not the wall-cap; no check was deleted and no threshold was relaxed (the camera row became stricter).
- **Inferred:** the overlay-gate change is a detection repair for a broken game-side flag, with raw counters preserved — not an acceptance relaxation.
- **UNVERIFIED / not claimed:** (a), (d), (e), real click/windowed R3, real input events, FX readiness; no PASS, no gate, no "clean run" claim. This report is the sole file authored by this QA; no code, runner job, or result artifact was modified.
