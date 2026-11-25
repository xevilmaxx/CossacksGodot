---
id: FINAL-AUDIT-01
title: "FINAL-AUDIT-01 — whole-tree readiness check for COORD's final gate sign-off"
area: coordination / final QA (read-only)
owner: FINAL-AUDIT-01 (read-only final QA subagent)
date: 2026-11-25
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
status: COMPLETE__READ_ONLY__NO_MUTATION__NO_JOB_SUBMITTED
scope: "Read file contents and mtimes; read-only godot_runner.py status + assert_clean.py --json polls; scoped git status. No code/config/test/fixture/result-JSON/PNG/queue/git edit, no submit/cancel/ack/reset/unwedge, no direct godot, no donor access."
exclusive_output: "docs/coord_swarm_2026-11-25/reports/FINAL_AUDIT_01.md"
labels: [observed, derived, inferred, UNVERIFIED]
parity_guard: "No donor GPU A/B frame exists. Every visual/fidelity finding stays PORT APPROX — internal consistency only; no parity claim."
verdict: NOT_READY
mutation_performed: false
---

# FINAL-AUDIT-01 — final QA verdict on whole-tree sign-off readiness

**Verdict: `NOT_READY`.** The delivered 240² gates (29/29, 17/17) and the config state are
green on the current tree, but the gate protocol's piece→combo ladder, second-agent capture
re-checks, owner visual sign-off, donor A/B, clean-queue gate and current-tree 2D re-run are
not satisfied. Full detail below. **No parity claim is made anywhere in this report.**

**No mutation performed.** This audit only read files and ran the two explicitly read-only
tools (`godot_runner.py status`, `assert_clean.py --json`). `status` only calls
`ensure_spool()` with `exist_ok=True` on already-existing directories; `assert_clean.py`
writes nothing (`variant3d/tools/assert_clean.py:13-14,288`). `git status --short` was read
before and after the polls and is byte-identical. The only file written is this report.

**Label key:** `observed` = literal file/tool output read in this pass; `derived` =
arithmetic or control-flow consequence of observed facts; `inferred` = best-supported
reading with caveat; `UNVERIFIED` = cannot be established from available evidence.

---

## 1. Evidence table

Times are UTC, 2026-11-25. Citations are workspace-root relative. `R/` =
`docs/coord_swarm_2026-11-25/reports/`.

| # | Evidence | Value (observed unless labelled) | Source |
|---:|---|---|---|
| E1 | `variant3d/selftest.json` | `passed: true`, **29 steps / 29 pass / 0 fail**; mtime **12:27:55** | live read; `python` JSON parse |
| E2 | `variant3d/uitest.json` | `passed: true`, **17 steps / 17 pass / 0 fail**; mtime **12:30:42** | live read; `python` JSON parse |
| E3 | Ticket **568** `map240apply01-selftest` | `--self-test variant3d/selftest.json`; `status=ok`, `exit=0`, wait 0.0007 s, run **86.78 s**; result `00000568.json` | `variant3d/.godot_queue/results/00000568.json` |
| E4 | Ticket **569** `map240apply01-uitest` | `--ui-test variant3d/uitest.json`; `status=ok`, `exit=0`, wait 0.0011 s, run **146.17 s**; result `00000569.json` | `variant3d/.godot_queue/results/00000569.json` |
| E5 | `config.json` | `gameplay.map_width_tiles=240`, `map_height_tiles=240`; `features` = 8 groups / **21 leaf keys**; `features.terrain.relief_stamps=true`; mtime **12:26:15** | `variant3d/config.json:16-54,80-81`; live parse |
| E6 | `app/**` git status | **empty** (no uncommitted 2D change) | `git status --short -- app/`, exit 0 |
| E7 | P0 final capture | ticket **504** `p0fresh01-capture`, windowed; PNG 10:41:11.360, JSON 10:41:12.264; `PASS 22/22 evaluated, 1 skipped`, luma 91.432/155.163, `SCRIPT ERROR 0`; **P0 CONFIRMED_PASS** (11 PASS/0 FAIL/1 N/A) | `R/RECHECK_P0_FINAL.md:12-14,47,221-241` |
| E8 | P0 staleness (`derived`) | current `terrain_tileindex.gdshader` mtime **11:57:42**; `game.gd` 11:56:59, `mapgen.gd` 12:02:30, `hud.gd` 12:01:53, `selftest.gd` 12:21:01 — all **after** the 10:41 P0 PNG | live `Get-Item` mtimes vs E7 |
| E9 | P1–C4 results | stale parse-only/headless JSONs or **absent**; source mtimes 10:05–10:48 vs result mtimes 09:00–09:03; `t_terrain_mines.json` **ABSENT** now | `R/QA_ATOM_RESULTS_01.md:45-52`; live mtimes + glob |
| E10 | S1 | JSON `passed:true` 23/23 but canonical JSON overwritten by jobs 414→438→495; **no PNG**; image verdict `UNVERIFIED (NO PNG)` | `R/RECHECK_S1.md:34,121-136,142-145,149-158` |
| E11 | Second-agent re-checks | exactly **3** files: `RECHECK_P0.md` (10:36:47), `RECHECK_S1.md` (10:39:13), `RECHECK_P0_FINAL.md` (10:45:29); **none** for P1/P2/P3/C1/C2/C3/C4 | live glob + mtimes |
| E12 | Owner visual sign-off | **absent** — no signed owner review artifact; standing `OPEN` (`H-1`) | `FINAL_CHECKLIST.md:416-422`; `R/QA_GATE_READY_03.md:221,298` |
| E13 | Donor GPU A/B | **absent** — no matched donor frame anywhere; parity `UNVERIFIED` by standing rule | `R/RECHECK_P0_FINAL.md:232-235`; `TEST_MATRIX.md:32-34,73-74` |
| E14 | Runner `status` (this audit) | spool `variant3d\.godot_queue`; `now_serving=570`, `next_ticket=570`, `pending=0 []`, lock **free**, `completed=500`, max wait 1825.52 s, max run 1207.38 s, statuses `failed 153 / ok 307 / skipped 17 / timed-out 23`; exit 0 | live read-only command |
| E15 | `assert_clean.py --json` (this audit) | **DIRTY**, exit **1**; `processes.count=0`, `lock.state=free`; `history.total=500`, `acknowledged=35`, **5 unacked failure-status jobs**: 516 timed-out, 521 timed-out, 526 skipped (serving=527), 538 timed-out, 555 timed-out | live read-only command |
| E16 | 2D gates | `qa2d-selftest` ticket **1348** ok/0 **29/29**, `qa2d-uitest` ticket **1349** ok/0 **17/17**, `CLEAN`/exit 0 at the time; verdict CONFIRMED_GREEN — **not re-run on the current tree by this audit** | `R/QA_2D_GATES_01.md:24-28,82-109,164-179` |
| E17 | Mask alpha fix | near-white 44,381 → 6,989 (**−84.252 %**), exact sky-cyan below sky strip 32,744 → 0; **frame-wide statistics only**, camera x differs 1.352 m (not pixel-registered A/B) | `R/MASK_ALPHA_FIX_01.md:159-186,262-266` |
| E18 | Relief fix | cell-level **CONFIRMED** at runtime: seed 20261150 `plt2`, `candidates=1`, `applied_cells=443`, height/tileblock SHA changed (ticket 565 ok/0); **no visual A/B**, silhouette/blend/row-flip UNVERIFIED | `R/RELIEF_SEED_PROBE_01.md:147-158,185-203,207-216` |
| E19 | HUD layout | `t_hud_layout.json` **62 passes / 0 fails / 3 skipped**, `capture_status=PASS`, windowed, 3 PNGs with blank-frame guard only; label `PORT APPROX` — **structural**, no donor/owner visual | live JSON read (`passes:618`, `verdict:628`, `parity_label:616`) |
| E20 | Load usability | `t_load_usability.json` `MEASUREMENT_ONLY__NO_PASS_CLAIM`, `gate_claim:NONE`, `pass_claim:false`, headless, (a)/(d)/(e) UNVERIFIED, real Start click not exercised | live JSON read (`:69-79,81,129,275,278`) |
| E21 | Sign-off doc conflict (`derived`) | `FINAL_CHECKLIST.md` still declares selftest **RED 28/29 `build`** and verdict NOT_READY, contradicted by E1/E3 (current 29/29) — docs lag the delivered tree | `FINAL_CHECKLIST.md:12,192-202,497-504` vs E1/E3 |

---

## 2. Per-check verdict

### CHECK 1 — Current gates and 568/569 artifacts — **PASS (observed)**

E1–E4. `selftest.json` is `passed:true` with **29/29** steps (mtime 12:27:55); `uitest.json`
is `passed:true` with **17/17** (mtime 12:30:42). Both are the runner-generated outputs of
the two delivered jobs: ticket **568** (`--self-test`) `ok`/exit 0 in 86.78 s and ticket
**569** (`--ui-test`) `ok`/exit 0 in 146.17 s, with result envelopes at
`variant3d/.godot_queue/results/00000568.json` / `00000569.json`. The reported counts are
reproduced from the JSON step arrays, not merely from exit 0. `derived`: the JSON mtimes
match the job completion order (568 then 569 at 240²). This closes the delivered-gate half
of the final acceptance list; it does **not** by itself certify the ladder or visual state.

### CHECK 2 — Config 240² / 21-key features / relief true / `app/**` untouched — **PASS (observed)**

E5–E6. Live parse: map **240×240**, `features` has 8 groups and **21 leaf keys**
(`world_epsilon_m, attack_epsilon_m, marquee_color, marquee_width_px, double_click_s,
texgen_mode, m_per_tile, lighting, alpha_patch_mode, relief_stamps, tile_diversity,
surface_y, alpha_confine, shore_prox, snow, fov_deg, minimap_size, minimap_inset,
minimap_corner, fog, fog_of_war`), `relief_stamps=true`. Note the literal flag key is
`relief_stamps` (not a bare `relief`). `git status --short -- app/` is empty. This matches
`R/MAP240_APPLY_01.md:58-88` (two-value 320→240 diff, features byte-identical).

### CHECK 3 — Ladder rows — **FAIL (observed + derived)**

E7–E10. Row-by-row state and the exact fresh windowed capture still required. Every row
must be submitted **by COORD in strict order, one ticket each**, windowed (no `--headless`),
with the fixed 64² harness / seed 20261113 / fixed camera / 1280×720, a non-blank
`<TEMP>\smallmap64_<row>.png`, a fresh `variant3d\tests\results\t_<row>.json` whose source
mtime **precedes** the capture, stdout `RESULT: PASS`, and runner stderr
`SCRIPT ERROR == 0` (`CAPTURE_RECHECK.md:43-60,56-60`; `TEST_MATRIX.md:57-64`). Water rows
P2/C1/C3/C4 additionally need `frames.json` + two frames 1 s apart.

| Row | Current state (observed/derived) | Exact fresh windowed capture still needed |
|---|---|---|
| **P0** `t_terrain_only` | **CONFIRMED_PASS** as of ticket 504 (E7), but its PNG **predates** the shader edit at 11:57:42 and other source edits (E8) — `derived`: no longer certifies current code | Re-capture P0 windowed on the current tree; JSON `verdict=PASS` with strict luma gates `mean>=40`/`max>=100`, `non_black_fraction>0.9`, `full_width_dark_rows` recorded-only; PNG + stdout/stderr; then a fresh `RECHECK_P0*.md` |
| **P1** `t_terrain_trees` | Stale headless `FAIL`/`SKIP_CAPTURE` (21/1/10); source 10:05:08 > JSON 09:08:38; never a ladder row | Fresh windowed `smallmap64_terrain_trees.png` + JSON; assert tree count/category purity/tree-height snap/no-tree-below-water/`png_differs_from_p0` and dark-row predicate; image review of silhouette/density |
| **P2** `t_terrain_shore` | Stale headless `UNVERIFIED`, no `capture_status` (16/10: 3 `EXPECTED_PRE_FIX_FAILURE` + 7 headless UNVERIFIED); source 10:06:28 > JSON 09:00:45 | Fresh windowed capture; exactly one height-aware water plane, water-band gate `full_width_dark_rows==0`, shore UV2 ids, alpha confined to cells, **two frames 1 s apart + `frames.json`** for water animation |
| **P3** `t_terrain_mines` | Former headless false-green JSON (`HEADLESS_STRUCTURAL_ONLY__PNG_UNVERIFIED`); source 10:36:50 > old JSON 10:00:59; **`t_terrain_mines.json` is now ABSENT** (live glob) | Fresh windowed capture; `png_capture_windowed` non-blank, `mine_sid_resolution`, `mine_y_matches_terrain`, ground unchanged outside mine bbox, no z-fighting visual; do not accept headless passes |
| **C1** `t_combo_trees_shore` | Stale headless `FAIL`/`SKIP_CAPTURE` (22/2/4); source 10:08:06 > JSON 09:01:16 | Fresh windowed capture; tree/shore interaction, single water plane, `full_width_dark_rows==0`, **frames.json** if motion claimed |
| **C2** `t_combo_trees_mines` | Stale headless `FAIL`/`SKIP_CAPTURE` (25/3/0); source 10:48:28 > JSON 09:01:35 | Fresh windowed capture; tree/ore purity and separation, no water, `non_black_fraction`, dark-row hard-assert (separate ticket if inapplicable — never relax) |
| **C3** `t_combo_shore_mines` | Stale headless `SKIP_CAPTURE` (12/12 checks pass; the capture *is* the gate); source 10:10:03 > JSON 09:02:43 | Fresh windowed capture; mines above water, shore masking, `full_width_dark_rows==0`, **frames.json** if motion claimed |
| **C4** `t_combo_all` | Stale headless `SKIPPED_HEADLESS`, 0/1, `total=1`; source 10:11:11 > JSON 09:03:15 | Fresh windowed capture with all layers toggled; mesh/atlas/shadow/water/tree/ore structural counts and capture checks, **frames.json** if motion claimed |
| **S1** `t_select_rect` | Windowed 23/23 atom PASS but **shared JSON overwritten** by jobs 414/438/495 and **no PNG** (E10); not a ladder row | S1-exclusive windowed run with unambiguous provenance; if a PNG is required, produce and second-agent-review `s1inputfix_smallmap64*.png`; otherwise record image verdict `UNVERIFIED` explicitly and obtain COORD disposition |
| **FINAL** | Reserved, never run | Only after all above rows are green and re-checked: fresh 29/29 + 17/17 + CLEAN/exit 0 + `pending=0` |

### CHECK 4 — Second-agent re-checks — **FAIL (observed)**

E11. Only `RECHECK_P0.md`, `RECHECK_S1.md`, `RECHECK_P0_FINAL.md` exist. There is **no**
`RECHECK_P1.md`…`RECHECK_C4.md`; S1's image half is `UNVERIFIED (NO PNG)`. Per
`TEST_MATRIX.md:58-59,75` no row may be called PASS without the second agent, so the gate
condition is unmet even where a result JSON is green.

### CHECK 5 — Owner visual sign-off / donor GPU A/B — **FAIL / UNVERIFIED (derived + UNVERIFIED)**

E12–E13. No signed owner visual review artifact exists. No matched donor GPU A/B frame
exists; donor execution was out of charter. Both stay `UNVERIFIED`. A green ladder row or
green gate does **not** constitute owner visual review or donor parity.

### CHECK 6 — Runner `status` + `assert_clean.py --json` — **PARTIAL (observed), clean gate FAIL**

E14–E15. The queue has **drained** since the stale checklist: `pending=0`, lock **free**,
**0** live Godot processes, `now_serving=next_ticket=570`. However `assert_clean.py --json`
returns **DIRTY / exit 1** because `status.json` still holds **5 unacked failure-status
jobs** (516 & 521 & 538 & 555 `timed-out`, 526 `skipped`, serving=527). With `acknowledged=35`
of 500 history entries, the N-20 clean gate is **not** met. Note `failed` exit codes are
excluded from `FAILURE_STATUSES` by tool policy (`assert_clean.py:42`), so the 153 historical
`failed` jobs are not the cause. No mutation was performed to clear these.

### CHECK 7 — 2D gates — **EVIDENCE-ONLY (observed + UNVERIFIED)**

E16. `R/QA_2D_GATES_01.md` records a genuine `CONFIRMED_GREEN`: tickets **1348** (selftest
29/29) and **1349** (uitest 17/17), both `ok`/exit 0 on the 2D runner, with `CLEAN`/exit 0 at
that time. This audit did **not** re-run the 2D gates on the current tree, and the 2D runner
is a different spool from the variant queue. Mark **evidence-only**, not a current-tree PASS.

### CHECK 8 — Landed fixes with no visual proof — **PARTIAL / UNVERIFIED (observed + derived)**

E17–E20. None of these is promoted to PASS:

- **Mask alpha fix** — near-white reduction **−84.252 %** is a **frame-wide statistic** of a
  non-pixel-registered before/after (camera x differs by 1.352 m); mechanism attribution is
  `INFERRED`, engine blend / donor patch semantics `UNVERIFIED`. **PORT APPROX**.
- **Relief fix** — cell-level runtime **CONFIRMED** (candidates=1, applied_cells=443,
  height/tileblock SHA changed) but that is dump-byte evidence only; whether it reads as a
  hill at the shipped camera, donor blend/row-flip and silhouette are `UNVERIFIED`. **PORT APPROX**.
- **HUD layout** — 62/62 structural + 3 non-blank guard PNGs; no donor or owner visual reading. **PORT APPROX**.
- **Load usability** — `MEASUREMENT_ONLY__NO_PASS_CLAIM`, `gate_claim:NONE`, `pass_claim:false`,
  headless, with (a)/(d)/(e) `UNVERIFIED` and no real Start click. **UNVERIFIED**.

---

## 3. Blockers, ranked

1. **B1 — Ladder never completed on the current tree (CHECK 3, E7–E10).** P0's evidence
   postdates only its own old shader snapshot, not the current shader (11:57:42); P1–C4 have
   only stale/parse-only/headless results (P3's JSON is now absent); S1 has overwritten
   provenance and no PNG. **Minimal action:** COORD re-runs P0→P1→P2→P3→C1→C2→C3→C4→S1
   strictly in order, one windowed ticket per row, on the final tree, with fresh
   PNG + JSON + `SCRIPT ERROR 0` (+ `frames.json` on water rows), then a second-agent
   `RECHECK_<ROW>.md` for every row.
2. **B2 — Second-agent re-checks missing for P1–C4; S1 visual half missing (CHECK 4, E11).**
   **Minimal action:** after B1 captures, commission independent `RECHECK_P1`…`RECHECK_C4`
   and resolve S1's PNG/provenance question; no row advances before its re-check lands.
3. **B3 — Owner visual sign-off and donor GPU A/B absent (CHECK 5, E12–E13).** Standing
   `UNVERIFIED`; the charter forbids donor execution. **Minimal action:** COORD must record an
   explicit disposition — accept the permanent `PORT APPROX / UNVERIFIED` label with named
   risk owner, or block sign-off until a donor frame is provided. Do not convert any metric
   into parity.
4. **B4 — Clean-queue gate still DIRTY (CHECK 6, E15).** 5 unacked failure-status jobs.
   **Minimal action:** owner/COORD acknowledges (or cleanly re-runs) tickets 516, 521, 526,
   538, 555, then a fresh `assert_clean.py --json` must return CLEAN/exit 0 with `pending=0`,
   free lock, 0 Godot. (This audit did not ack anything.)
5. **B5 — Landed fixes have no visual proof (CHECK 8, E17–E20).** **Minimal action:** keep
   them labelled `PORT APPROX` / `UNVERIFIED`; if visual acceptance is required, add a
   windowed A/B with a second-agent reading for the mask-alpha frame, relief silhouette,
   HUD and load responsiveness.
6. **B6 — 2D gates are evidence-only (CHECK 7, E16).** **Minimal action:** if the final
   acceptance requires a current-tree 2D re-run, submit tickets on the **2D** runner and
   keep reports out of variant3d reports.
7. **B7 — Sign-off documentation drift (E21).** `FINAL_CHECKLIST.md` still reports
   selftest RED 28/29 `build`, contradicted by the delivered 29/29. **Minimal action:**
   refresh the checklist/board before COORD signs so the record matches the tree.

---

## 4. Sign-off conditions (all must hold before COORD runs FINAL)

1. Fresh integrated `variant3d/selftest.json` **29/29** and `uitest.json` **17/17** on the
   final tree (current files satisfy this as of 12:27:55 / 12:30:42, but FINAL must re-run
   after B1–B5 settle).
2. Every ladder row P0…S1 re-run windowed with a fresh non-blank PNG, fresh result JSON,
   `SCRIPT ERROR == 0`, correct source-vs-capture ordering, and a landed second-agent
   `RECHECK_<ROW>.md` that records atom verdict and image verdict separately.
3. S1 provenance ambiguity resolved and its no-PNG status explicitly accepted or a PNG
   produced and reviewed.
4. `godot_runner.py status`: `pending=0`, free lock, 0 live Godot; `assert_clean.py --json`:
   **CLEAN / exit 0**, no unacked failure-status jobs.
5. `config.json` remains 240×240 with the 21-key features block and `relief_stamps=true`,
   and `app/**` remains untouched.
6. 2D gates green on a current-tree run (or explicitly accepted as evidence-only at
   tickets 1348/1349).
7. Owner visual sign-off either signed or explicitly waived with a named risk owner;
   donor A/B stays `UNVERIFIED` with **no parity claim** in the release notes.
8. Landing fixes carry honest labels: mask-alpha frame-wide only, relief cell-level only,
   HUD structural only, load probe measurement-only.

---

## 5. Open questions

1. `[UNVERIFIED]` Will COORD accept the permanent absence of a donor GPU A/B as a documented
   risk, or treat it as an absolute sign-off blocker?
2. `[UNVERIFIED]` Who owns the five unacked failure-status jobs (516/521/526/538/555), and
   will they be acknowledged or re-run? (No ack performed here.)
3. `[UNVERIFIED]` Is a PNG mandatory for S1 row PASS, given the atom's deliberate no-PNG
   design and the protocol's S1 exception (`CAPTURE_RECHECK.md:54`)?
4. `[UNVERIFIED]` Does the post-capture shader edit (11:57:42) change any P0-asserted
   behaviour, or only the mask-alpha path? Timestamp proves staleness, not behavioural drift.
5. `[UNVERIFIED]` Should the 2D gates be re-run on the current tree, or is the
   `CONFIRMED_GREEN` artifact at 1348/1349 sufficient given `app/**` is untouched?
6. `[UNVERIFIED]` Do the HUD/load/mask/relief fixes need their own windowed visual A/B before
   FINAL, or are the structural/frame-wide/cell-level labels sufficient for COORD?
7. `[derived]` Can the stale `FINAL_CHECKLIST.md` verdict be refreshed by COORD before
   sign-off so the authoritative record matches the 29/29 tree?

---

## 6. Summary

- **PASS (green, current tree):** delivered 240² gates — selftest **29/29**, uitest **17/17**,
  tickets **568/569** `ok`/exit 0 (E1–E4); config **240×240** with 21 feature keys and
  `relief_stamps=true`; `app/**` untouched (E5–E6).
- **FAIL / not met:** the piece→combo ladder (P0 stale vs current shader, P1–C4
  stale/parse-only/absent, S1 overwritten and PNG-less), missing `RECHECK_P1`…`RECHECK_C4`,
  absent owner visual sign-off, absent donor GPU A/B, dirty clean gate (5 unacked
  failure-status jobs), and 2D gates as evidence-only.
- **PARTIAL / UNVERIFIED:** mask-alpha improvement is frame-wide `PORT APPROX`; relief is
  cell-level confirmed but visually `UNVERIFIED`; HUD is structural 62/62; load probe is
  `MEASUREMENT_ONLY`. None is a PASS.
- **Queue snapshot (`observed`, point-in-time):** `pending=0`, lock free, 0 Godot,
  `now_serving=next_ticket=570`, `completed=500`; `assert_clean=DIRTY`, exit 1, 5 unacked.
- **Verdict: `NOT_READY`** for COORD's final gate sign-off. The minimal path to readiness is
  B1→B2 (fresh ladder + second-agent re-checks), then B4 (clean queue), then explicit COORD
  disposition of B3/B5/B6/B7. **No donor parity is claimed; all visual/fidelity findings remain
  `PORT APPROX — internal consistency only` or `UNVERIFIED`.**
- **Mutation statement: none.** No code, config, test, fixture, result-JSON, PNG, queue,
  lock, counter, job or git state was changed. No runner job was submitted, cancelled,
  acknowledged, reset or unwedged; no direct `godot` and no donor access. Git status was
  identical before and after the two read-only polls. Only this report was written.

---

*End of FINAL-AUDIT-01. Read-only final QA; no mutation, no job submission, no parity claim.*
