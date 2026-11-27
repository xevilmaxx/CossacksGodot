---
id: PORT1TO1-CLAIM-RECHECK4-2026-11-27
title: "CLAIM-RECHECK4 — read-only post-bundle/camera-wire parity-claim string re-sweep: all current reports + current variant3d/"
agent: CLAIM-RECHECK4 (read-only subagent; no code/Godot/git/donor execution)
created: 2026-11-27
role: "Follow-up to PORT1TO1_claim_recheck3.md. Since that sweep a minimal bundle index, eight static class-B probes, four owner/index/decision packets, two plan/handoff syncs and two implementation lanes (2D + 3D first-camera wire) landed. Re-scan EVERY current reports/*.md plus current variant3d/ for forbidden parity strings and misread-risk phrasing; verify each new report's UNVERIFIED/no-parity marker and verdict line; cite every gap with LABEL-ONLY remediation; confirm no implementation lane asserted donor parity."
parity: UNVERIFIED
parity_claim: NONE
parity_claim_code: NONE
visual_parity_claim: false
verdict: "RESULT IS NOT GOOD — blocking_unverified is non-empty; six-condition chain 0/6 CLOSED; no donor GPU A/B frame; no COORD ruling; no approximations; no parity claim."
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
output_files: "Exactly one repository file written: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_claim_recheck4.md"
methods: "Read-only glob/grep/read of the current working tree. No code edit, no Godot process, no runner subcommand, no gate, no capture, no donor execution, no git command, no result-JSON/test/backup/config mutation. All file:line numbers are current working-tree numbers. Every quoted forbidden literal below is quoted as a SCAN TARGET, a NEGATION, or a GUARDED OBSERVATION — never as a claim."
---

# CLAIM-RECHECK4 — post-bundle/camera-wire parity-claim string re-sweep (current tree, 2026-11-27)

> **PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.**

This is a read-only label/string audit. It does not execute the donor, Godot, a runner job, a gate or a capture; it does not run git; it does not close a `[U]`, wire a value, promote a metric or change any file other than this report. It supplements `PORT1TO1_claim_recheck3.md`, which PASSed source/report parity strings before the bundle/index/camera-wire wave landed. This sweep re-checks those strings against the current tree and audits every newly landed report and implementation lane.

## 1. Scope — what counts as "new" here

Baseline cut = mtime of `PORT1TO1_claim_recheck3.md` (2026-11-27 05:39:22). Fourteen report files are under audit as new:

- **Strictly newer than the baseline at first listing (12):** `DEC_U12_caller_walk.md` (05:39:58), `DEC_U3_reg_sweep.md` (05:40:56), `DEC_U_smooth_kernel_deep.md` (05:44:18), `DEC_U_tver_deep.md` (05:46:39), `DEC_U_econ_deep.md` (05:46:51), `DEC_U_coll_census_deep.md` (05:46:58), `DEC_U_place_seed_deep.md` (05:47:39), `PORT1TO1_c_decisions.md` (05:48:54), `PORT1TO1_d_cosmetic.md` (05:50:03), `PORT1TO1_handoff_sync.md` (05:51:14), `PORT1TO1_b_angle_index.md` (05:51:50), `PORT1TO1_plan_sync.md` (05:51:53).
- **Landed during this audit (1):** `PORT1TO1_d4_reclass.md` (05:52:31) — the task marks it pending, but the file is on disk and is audited here.
- **Just before the cut, not in recheck3's 19-file scope (1):** `PORT1TO1_bundle_index.md` (05:37:58) — task-directed into this sweep.

**Two implementation lanes:** `IMPL-START-CAMERA-WIRE` (2D, plan `:221`) and `IMPL-START-CAMERA-3D` (3D, plan `:227`), both recorded DONE/parses OK at `PORT1TO1_handoff_sync.md:39`; surfaces are `variant3d/scripts/camera.gd`, `camera3d.gd` and the `game.gd` flag/target seam. Three plan rows remain DOING (`PORT1TO1_PLAN.md:231,234,236` — B-ANGLE-INDEX, PLAN-SYNC, D4-RECLASS) although their report files exist; that is a plan-status label lag with no parity impact, and `PORT1TO1_plan_sync.md:27` warns the plan is being concurrently mutated. All citations below are current-tree at audit time.

Scanned in full: `docs/terrain_swarm_2026-11-26/reports/**/*.md` (the whole report set), `spec/**`, root docs (`CHARTER.md`, `HANDOFF.md`, `SWARM_BOARD.md`, `REPORT_INDEX.md`, `PORT1TO1_PLAN.md`) and the current `variant3d/` tree (`.gd`, `.gdshader`, `.json`, `.md`, `.cfg`, `.tscn`, `.py`). Backup files (`*.bak-*`) are preservation-only and are treated as non-live, as in recheck2/recheck3.

Scan classes (inherited from the baseline, case-insensitive where wording varies), each run repo-wide over both trees:

- **C1** forbidden true flags: `parity=true`, `parity = true`, `"parity": true`, `visual_parity_claim=true`, `parity_claim=true`, `donor_parity_claim=true`, `parity=PASS`.
- **C2** `RESULT IS GOOD` (unqualified vs conditional / template / quotation / negation).
- **C3** `claim=owner-supplied` used as a pass.
- **C4** unqualified donor-parity assertions: "donor parity confirmed/achieved/PASS/verified", "parity achieved", "matches donor", "close to donor", "donor-exact" read as a runtime claim, "1:1/1TO1 parity", "perfect/full parity".
- **C5** gate/metric promoted to parity: "gate PASS ⇒ parity", "PASS proves donor", "no threshold + metric = parity".
- **C6** port-internal "parity" strings and "donor-faithful"/"donor 1:1"/"endorsed as donor-faithful"/"donor-settled" phrasing misreadable as donor parity when cut out of context.

## 2. Result by class — guarded vs unguarded

| Class | Live unguarded claim introduced by the new wave | Classification | Evidence (exact file:line) |
|---|---|---|---|
| **C1 true flags** | **NONE** | Every hit is a quoted scan target, a negation, a zero-count assertion or a governance list. A repo-wide `variant3d/` scan for `parity\s*[=:]\s*true`, `parity=true`, `visual_parity_claim\s*[=:]\s*true`, `parity_claim\s*[=:]\s*true`, `parity\s*[=:]\s*PASS` and the unqualified `RESULT IS GOOD` literal returned **"No matches found"**. | Baseline targets remain quoted-only: `DEC_U_port_guard_audit.md:77,160`; `PORT1TO1_final_guard_audit.md:30,42,167`; `PORT1TO1_internal_validation.md:128`; `V111_asset_final.md:27` ("0 `visual_parity_claim:true`"); `V33_do_not_do_checklist.md:73`; `V76_gate_preflight.md:46`; `PORT1TO1_tree_recheck.md:50`. The 14 new reports add no C1 flag: `PORT1TO1_bundle_index.md:7,12-15`; `DEC_U12_caller_walk.md:7,14-16`; `DEC_U3_reg_sweep.md:8-12`; `DEC_U_coll_census_deep.md:8-9`; `DEC_U_smooth_kernel_deep.md:8-9`; `DEC_U_tver_deep.md:9-12`; `DEC_U_econ_deep.md:9,11`; `DEC_U_place_seed_deep.md:9-12`; `PORT1TO1_b_angle_index.md:8-11`; `PORT1TO1_c_decisions.md:8-11`; `PORT1TO1_d_cosmetic.md:8-11`; `PORT1TO1_handoff_sync.md:6,11-13`; `PORT1TO1_plan_sync.md:7,13-14`; `PORT1TO1_d4_reclass.md:8-11`. |
| **C2 `RESULT IS GOOD`** | **NONE unguarded** | The literal (quoted here as a scan target only) appears in the new wave twice, both guarded: a conditional template ("admissible **only** when `blocking_unverified = []` … not today") and a forbidden-to-settle row quoting the D14 repair. Ten of 14 new reports carry `RESULT IS NOT GOOD` in a verdict or closing line. | New guarded: `PORT1TO1_bundle_index.md:156`; `PORT1TO1_c_decisions.md:69-74`. New verdicts: `DEC_U12_caller_walk.md:17`; `DEC_U_tver_deep.md:13`; `DEC_U_econ_deep.md:181`; `PORT1TO1_b_angle_index.md:12`; `PORT1TO1_c_decisions.md:12`; `PORT1TO1_d_cosmetic.md:12`; `PORT1TO1_handoff_sync.md:14`; `PORT1TO1_plan_sync.md:16`; `PORT1TO1_d4_reclass.md:12`; `PORT1TO1_bundle_index.md:16`. Baseline guarded set unchanged: `W08_visual_acceptance_criteria.md:196`; `V15_acceptance_without_reference.md:331-332`; `X39_ab_feasibility.md:236`; `PORT1TO1_final_guard_audit.md:30,64,65,157,167`; `PORT1TO1_acceptance_plan.md:368`; `PORT1TO1_acceptance_runbook.md:345`; `PORT1TO1_owner_brief.md:94`; `PORT1TO1_owner_brief_addendum.md:81`; `PORT1TO1_final_gates.md:147`; `PORT1TO1_u_register_update.md:113,172`; `PORT1TO1_decision_sim.md:142`; `PORT1TO1_p0_session_plan.md:250`; `PORT1TO1_session_risks.md:170`; `PORT1TO1_handoff_checklist.md:293`; `PORT1TO1_internal_validation.md:128,129,154`; `PORT1TO1_tree_recheck.md:34,51-53`; `V67_owner_answer_check.md:128`; `DEC_U_port_guard_audit.md:80`. |
| **C3 `claim=owner-supplied`-as-pass** | **NONE** | Every occurrence records a human assertion, not a verdict, and explicitly never promotes `parity=UNVERIFIED`. The new wave adds only a restatement of that negation. | New: `PORT1TO1_c_decisions.md:61` ("records `claim=owner-supplied` yet **never promotes `parity=UNVERIFIED`**"). Baseline: `PORT1TO1_decision_sim.md:56,142,173`; `PORT1TO1_final_guard_audit.md:30,48-49,167`; `PORT1TO1_gate_audit.md:164`; `PORT1TO1_artifact_layout.md:196`; `PORT1TO1_acceptance_plan.md:252,263`; `PORT1TO1_roi_register.md:90,213`; `variant3d/tools/acceptance/compare_frames.py:16,139,255`; `variant3d/tools/acceptance/README.md:13,129`. |
| **C4 donor-parity assertion** | **NONE unguarded** | Hits split into (a) negations / forbidden-phrasing inventories and (b) static `[O]/[D]` donor text/byte recovery paired with still-`[U]` port values — not runtime parity. The two camera lanes add no runtime claim. | New negations/lists: `PORT1TO1_bundle_index.md:52,54,66,95,158,159`; `PORT1TO1_d_cosmetic.md:47,145`; `PORT1TO1_handoff_sync.md:27,31-35,39-40`; `DEC_U_tver_deep.md:13` ("does NOT byte-match shipped artifacts"); `DEC_U_coll_census_deep.md:9,191`; `DEC_U_smooth_kernel_deep.md:158`; `DEC_U_econ_deep.md:167,179,181`; `DEC_U_place_seed_deep.md:23,202,204`; `DEC_U3_reg_sweep.md:22,165,198-199`; `DEC_U12_caller_walk.md:22,26,28`; `PORT1TO1_d4_reclass.md:27,159`; `PORT1TO1_plan_sync.md:21,25`. New static recovery with guard: `DEC_U_coll_census_deep.md:190` ("donor-exact text" `[O]`) guarded by `:9` parity_guard. Live source guards: `variant3d/scripts/camera.gd:15,17,24,30,70-76,77-79,89,178`; `camera3d.gd:49,72,75,91,96-97,103,110,135-136,165,199,207,215,444-445,484,622-627,667`; `game.gd:5,11,685,687-709`; `data.gd:26,53,310,3033`; `world3d.gd:45,105,557`; `input_controller.gd:20,131,1424`; `main.gd:1051,1066`; `variant3d/shaders/terrain_tileindex.gdshader:22,58,362`; `variant3d/tools/acceptance/compare_frames.py:17,256`. |
| **C5 gate/metric → parity** | **NONE** | Every gate/metric surface is explicitly denied as parity. New reports restate the denial; none attaches a green gate to parity. | `PORT1TO1_bundle_index.md:52,95`; `PORT1TO1_c_decisions.md:61,74`; `PORT1TO1_d4_reclass.md:159`; `PORT1TO1_handoff_sync.md:39-40`; `PORT1TO1_plan_sync.md:15-16,27`; `DEC_U3_reg_sweep.md:198`; `DEC_U_tver_deep.md:13`. Baseline: `PORT1TO1_decision_sim.md:163-180`; `PORT1TO1_gate_audit.md:14,40,163-164,192,200-201,219,225`; `PORT1TO1_final_gates.md:14,44,69,98,162,167,173`; `PORT1TO1_parity_chain.md:41,121,129-130,147,152`; `PORT1TO1_parity_recheck.md:46,117-118,136,141`; `PORT1TO1_internal_validation.md:154`; `V112_gate_witness.md:14,37,93`. |
| **C6 misread-risk strings** | **NONE is a parity claim**; 5 NEW guarded phrasings + 2 carried-forward implementation-seam phrasings, all label-only | Guarded by inline or adjacent negations; listed only because a reader cutting a line out of context could misread them. Full register in §4. | See §4. |

**C1–C5 result: no live unguarded parity claim was introduced by any of the 14 new reports, and none was introduced in `variant3d/` by either camera-wire lane.** All C6 strings are guarded; they are listed only as hardening items.

## 3. Verdict-line verification for every new report

The owner's required verdict marker is `RESULT IS NOT GOOD` / `parity.claim=NONE` / `UNVERIFIED`. All 14 new reports carry an UNVERIFIED/no-parity marker. Ten carry a literal verdict line (frontmatter `verdict:` or closing `RESULT IS NOT GOOD`); four deep probes express the verdict as a closing non-claims register with a **Denied** "port equals donor" row and no literal verdict line — the same presentation gap recorded as GAP-1 in recheck2/recheck3 (LABEL-ONLY, not a suppressed verdict; see GAP-4N5).

| # | New report | UNVERIFIED / no-parity evidence | Verdict line (current tree) | Literal verdict present? |
|---|---|---|---|---|
| 1 | `PORT1TO1_bundle_index.md` | `:7` status `…NO_PARITY_CLAIM`; `:12-15` labels + `parity_status: UNVERIFIED` / `parity_claim: NONE` / `visual_parity_claim: false` | `:16` `verdict: "RESULT IS NOT GOOD … chain 0/6 CLOSED … no parity claim"`; `:17` reviewer line | **Yes** |
| 2 | `DEC_U12_caller_walk.md` | `:7` status `…NO_PARITY_CLAIM`; `:14-16` UNVERIFIED/NONE/false; `:22` "No parity claim. Port keeps hard-fail." | `:17` `verdict: "RESULT IS NOT GOOD — U12 reflection provenance stays [U]; …"` | **Yes** |
| 3 | `DEC_U3_reg_sweep.md` | `:8` status `…NO_PARITY_CLAIM`; `:9` labels `PARITY_UNVERIFIED`; `:10-12` NONE/UNVERIFIED/false; `:22` `parity.claim = NONE` | `:22` reviewer line + `:198-199` "No parity claim. No approximation substituted."; no `verdict:` key | No — UNVERIFIED/no-parity form only |
| 4 | `DEC_U_coll_census_deep.md` | `:8` labels `NO_PARITY_CLAIM, NO_APPROXIMATION`; `:9` parity_guard "NO DONOR PARITY IS CLAIMED …" | `:191` claim 8 **Denied** (port visual equals donor motion/occlusion/FX); no `verdict:` key | No — UNVERIFIED/no-parity form only |
| 5 | `DEC_U_smooth_kernel_deep.md` | `:8` labels `NO_PARITY_CLAIM, NO_APPROXIMATION`; `:9` parity_guard; `:26` "No parity claim. No approximation endorsed." | `:158` **Denied** (any kernel/parity/similarity claim); no `verdict:` key | No — UNVERIFIED/no-parity form only |
| 6 | `DEC_U_tver_deep.md` | `:9` labels `PARITY_UNVERIFIED`; `:10-12` NONE/UNVERIFIED/false; `:14` reviewer line | `:13` `verdict: "RESULT IS NOT GOOD for T-VER — port's pinned 92/240² does NOT byte-match shipped artifacts …"` | **Yes** |
| 7 | `DEC_U_econ_deep.md` | `:9` labels `[U] … PORT APPROXIMATION`; `:11` `parity: "NO PARITY CLAIM …"` | `:181` closing "`RESULT IS NOT GOOD` while `blocking_unverified` is non-empty"; `:179` `parity.claim = NONE` | **Yes** (closing line) |
| 8 | `DEC_U_place_seed_deep.md` | `:9` labels `PARITY_UNVERIFIED`; `:10-12` UNVERIFIED/NONE/false; `:23`,`:204` "No parity claim(ed)" | §7 non-claims `:202-204`; no `verdict:` key | No — UNVERIFIED/no-parity form only |
| 9 | `PORT1TO1_b_angle_index.md` | `:8-11` PARITY_UNVERIFIED/NONE/false; `:13` reviewer line | `:12` `verdict: "RESULT IS NOT GOOD … chain 0/6 CLOSED … class-B static results never close class-A value/behaviour items"` | **Yes** |
| 10 | `PORT1TO1_c_decisions.md` | `:8-11` PARITY_UNVERIFIED/NONE/false; `:13` reviewer line | `:12` `verdict: "RESULT IS NOT GOOD … chain 0/6 CLOSED … no parity claim"` | **Yes** |
| 11 | `PORT1TO1_d_cosmetic.md` | `:8-11` PARITY_UNVERIFIED/NONE/false; `:13` reviewer line | `:12` `verdict: "RESULT IS NOT GOOD … ten class-D items remain [U] and are NOT CLOSED …"` | **Yes** |
| 12 | `PORT1TO1_plan_sync.md` | `:7` labels `NO_PARITY_CLAIM, PARITY_UNVERIFIED, RESULT_IS_NOT_GOOD`; `:13-14` UNVERIFIED/false; `:21` reviewer line | `:16` `verdict: "RESULT IS NOT GOOD - blocking_unverified is non-empty"` | **Yes** |
| 13 | `PORT1TO1_handoff_sync.md` | `:6` status `…NO_PARITY_CLAIM…NO_APPROXIMATION`; `:11-13` UNVERIFIED/NONE/false; `:25` reviewer line; `:27` "asserts no parity" | `:14` `verdict: "RESULT IS NOT GOOD … chain 0/6 CLOSED; nine P0 rows OPEN"` | **Yes** |
| 14 | `PORT1TO1_d4_reclass.md` | `:8-11` PARITY_UNVERIFIED/NONE/false; `:13` reviewer line; `:27` `parity.claim = NONE` | `:12` `verdict: "RESULT IS NOT GOOD … D4 remains [U] and is NOT CLOSED …"`; `:159` restatement | **Yes** |

**Conclusion on verdicts:** no new report asserts donor parity, closes a P0, or weakens a test. Ten carry a literal verdict; four carry an equivalent UNVERIFIED/no-parity verdict with a **Denied** claim register (GAP-4N5, label-only). Chain is **0/6 CLOSED** in every packet that states a number (`PORT1TO1_bundle_index.md:16`; `PORT1TO1_b_angle_index.md:12`; `PORT1TO1_c_decisions.md:12`; `PORT1TO1_d_cosmetic.md:12`; `PORT1TO1_handoff_sync.md:14`; `PORT1TO1_plan_sync.md:15-16`; `PORT1TO1_d4_reclass.md:159`; `DEC_U3_reg_sweep.md:198`).

## 4. Gap register — all LABEL-ONLY, no code/value/behaviour change

These strings are **not** parity claims. Each is guarded by an adjacent negation or a named port-internal qualifier. **No remediation was applied by this audit**; replacements below are label text only.

### 4.1 NEW misread-risk phrasings in the 14 new reports / camera lanes

| # | Exact file:line | Current string (excerpt) | Guard that prevents a claim | Label-only remediation |
|---|---|---|---|---|
| GAP-4N1 | `docs/.../reports/DEC_U12_caller_walk.md:151` (echoed at `:17` and `PORT1TO1_b_angle_index.md:42`) | "The port's current behaviour (hard-fail, no water, no grey fallback …) is **endorsed as donor-faithful**."; verdict "hard-fail (no water) **endorsed**" | `:7` NO_PARITY_CLAIM; `:14-16` UNVERIFIED/NONE/false; `:22,26` "No parity claim"; `:28` "[U] kept on every provenance value"; `:151` "No texture, size, unit, matrix, class identity, or pool rule is supplied" | Change "endorsed as donor-faithful" to "retained as the labelled hard-fail posture (NOT donor behaviour)"; change verdict "endorsed" to "retained as labelled". Same class as recheck2 GAP-8 / recheck3 GAP-N1 (still un-hardened at `DEC_U12_deep.md:132`). |
| GAP-4N2 | `docs/.../reports/DEC_U3_reg_sweep.md:199` | "The port's decoded-grid `height_tex`/`hmapTex` + `±2.96` span, both explicitly labelled `[U3]`, is **endorsed as the donor-faithful behaviour** until the corresponding zero-mismatch captures land." | `:9` PARITY_UNVERIFIED; `:11-12` NONE/UNVERIFIED/false; `:22` `parity.claim = NONE`; `:165` "No invented texture id. No parity claim."; `:198` "No parity claim"; `[U3]` tag + "until … captures land" | Change to "retained as the labelled `[U3]` port substitute (NOT donor behaviour)". Same class as recheck2 GAP-7 / `DEC_U_hmap_num_deep.md:186`. |
| GAP-4N3 | `docs/.../reports/PORT1TO1_handoff_sync.md:3` (title), `:29` (heading) | "Final handoff sync addendum — **donor-exact corrections** since HANDOFF §9.22"; "## 1. New **donor-exact corrections** landed since §9.22" | `:6` NO_PARITY_CLAIM; `:11-13` UNVERIFIED/NONE/false; `:25` reviewer line; `:27` "asserts no parity"; `:31-35` each correction carries explicit `[U]` residuals and a zero-mismatch experiment | Retitle/heading to "static donor-text/localization corrections (NOT donor runtime parity)". "donor-exact" in a heading is the highest cut-out-of-context risk in this wave. |
| GAP-4N4 | `variant3d/scripts/camera.gd:63-64`, `:91`, `:161` (carried from recheck3 GAP-N3; 3D mirror at `camera3d.gd:473-484`) | "the start-derived TARGET is **donor-settled `[O]`**, so the former EV-CAM-7 'engine-default / PORT CHOICE focus' tag is **RETIRED**, not merely reworded"; "First TARGET is now the **donor-settled** one-shot wire above" | `camera.gd:17,30,178` "NO PARITY CLAIM"; `:15-16` FOV "PORT APPROXIMATION / UNVERIFIED … NEVER a donor-claimed value"; `:70-76` CAM-derive/CAM-0/S-place/S-ver/N-native still `[U]` with fixed-seed captures, "never donor law"; `:77-79,89,161` zoom is "PORT CHOICE `[U]-CAM`, NOT donor-derived". `camera3d.gd:483` height/time args + clamp stay `[U]` CAM-derive/CAM-0; `:484` "NO PARITY CLAIM." | Append "(static donor-text wire target only; runtime/visual parity UNVERIFIED)" at each 2D site; add the same qualifier to the 3D mirror comment. Implementation-lane label hardening only. |
| GAP-4N5 | `DEC_U3_reg_sweep.md`, `DEC_U_coll_census_deep.md`, `DEC_U_smooth_kernel_deep.md`, `DEC_U_place_seed_deep.md` (no `verdict:` key) | Four static probes carry no literal `RESULT IS NOT GOOD` / `parity.claim=NONE` verdict line; verdict is expressed as UNVERIFIED/no-parity frontmatter + closing **Denied** register | `:22/:198` (`U3`), `:9/:191` (coll), `:9/:158` (smooth), `:10/:204` (place seed) all deny a port-equals-donor reading and keep every value `[U]` | Append a `verdict: "RESULT IS NOT GOOD — … no parity claim"` line (or the literal closing statement used at `DEC_U_econ_deep.md:181`) to each. Presentation label only — not a suppressed verdict. |

### 4.2 Standard static-recovery idiom in the new wave (guarded, no action)

`DEC_U_coll_census_deep.md:9` and `:190` use "Required donor-faithful replacement" / "donor-exact text `[O]`"; the same-file `parity_guard` at `:9` states "names the algorithm to implement, not a claim it is implemented". This is the established static-recovery idiom (recheck2 §4.2, recheck3 §4.1), not a new class; keep the guard. The "donor-exact / visually matched" strings at `PORT1TO1_bundle_index.md:52,54,66` are quoted as things the cited packet **does NOT support**, and `:158-159` restate the forbidden-phrasing rule; no action.

### 4.3 Residual baseline C6 strings still un-hardened in the current tree

Carried forward from recheck2 §4/recheck3 §4.2 — **none was applied by this audit**:

- `DEC_U_audio_rng.md:98` — "donor-exact audition path" (same bullet says `PORT APPROXIMATION — no donor pitch RNG …`). Append `(text-pitch constant only; runtime/audio parity UNVERIFIED)`.
- `variant3d/scripts/pattern_gen.gd:373` — "count parity with the pre-fix baseline" (port-internal). Append `(port-internal count parity, NOT donor parity)`.
- `variant3d/scripts/game.gd:81`, `:2475` — "simulation/world.gd parity", "2D parity preserved" (named port modules). Append `(port-internal, NOT donor parity)`.
- `variant3d/scripts/input_controller.gd:938` — "keep 2D parity". Append `(NOT donor parity)`.
- `DEC_U_select_deep.md:18` — heading suffix "(donor 1:1)". Retitle `(static donor-source localization; NOT donor runtime parity)`.
- `DEC_U_hmap_num_deep.md:186`, `DEC_U_water_uv_deep.md:202` — "endorsed as the donor-faithful behaviour" / "endorsed as donor-faithful". Change to "retained as the labelled port substitute (NOT donor behaviour)".
- `DEC_U12_deep.md:132` — "endorsed as donor-faithful". Change to "retained as the labelled hard-fail posture (not a claim of donor behaviour)".
- `DEC_U_bld_death_time.md:4` — role suffix "donor 1:1 building-death time-base static probe". Retitle `(static donor-source localization; NOT donor runtime parity)`.

Guarded "endorsed as donor-faithful … until … capture lands" phrasings in pre-existing water/FOW reports (`DEC_U_water_mesh_uv.md:197`, `DEC_U_water_capture.md:200`, `DEC_U_water_fbo.md:153`, `DEC_U_hmap_identity.md:185`, `PORT1TO1_fow_owner_protocol.md:300`, `PORT1TO1_water_owner_protocol.md:219`) are unchanged and remain label-only; each is adjacent to a "No approximation substituted" / "No parity claim" and an `[U]` tag. No new stale cross-reference was found in the 14 new reports; recheck2 GAP-9…GAP-12 remain as recorded.

**Every gap above is label-only. None changes a value, gate, assertion, threshold, `[U]` status, P0 status or preserve-only mod. No gap is a parity claim.**

## 5. Explicit confirmation — no deep pass promoted a static finding to behavioural parity

Checked each of the eight new static class-B probes plus the six owner/index/consumer packets. In every case a recovered `[O]/[D]` static fact is paired with a still-`[U]` live value and an owner-only zero-mismatch experiment; none is written into the port as donor behaviour.

- `DEC_U12_caller_walk.md:28` "Net result: `[U]` kept on every provenance value"; `:151` no texture/size/unit/matrix/class/pool rule supplied.
- `DEC_U3_reg_sweep.md:165` "No invented texture id. No parity claim. No `HeightMapTexUnit` number."; `:198-199` no tuple/name/size/unit/conversion factor supplied, `[U3]` span retained.
- `DEC_U_coll_census_deep.md:22` "Each `[U]` ends in a named capture/probe, never in a port fallback."; `:191` any port visual equals donor motion/occlusion/FX — **Denied**.
- `DEC_U_smooth_kernel_deep.md:158` any box/gaussian/lerp blur, window claim or parity/similarity claim — **Denied**; port keeps `bsmooth_kernel` NULL/`SKIPPED`.
- `DEC_U_tver_deep.md:13` port's pinned 92/240² "does NOT byte-match shipped artifacts"; live selectors stay `[U]`; `PORT1TO1_handoff_sync.md:34` records the zero-mismatch **FAIL** on word 0 and extent.
- `DEC_U_econ_deep.md:167` "No rate, radius, weight, or stagger was invented … No `[U]`→`[D]` promotion is claimed"; `:179` all tails keep `[U]` with fixed-seed batteries.
- `DEC_U_place_seed_deep.md:202-204` Delphi per-run seed stays `[U]`; no invented seed/derivation; no parity claimed.
- Consumer packets: `PORT1TO1_b_angle_index.md:12` "class-B static results never close class-A value/behaviour items"; `PORT1TO1_d_cosmetic.md:12` "ten class-D items remain `[U]` and are NOT CLOSED"; `PORT1TO1_d4_reclass.md:12` "D4 remains `[U]` and is NOT CLOSED"; `PORT1TO1_c_decisions.md:74` label-only repair "changes no parity state"; `PORT1TO1_handoff_sync.md:39-40` "REPORTED ONLY — no IMPL lane recorded … no value was wired into port code, no gate PASS follows"; `PORT1TO1_plan_sync.md:27` no finding survives later plan edits; `PORT1TO1_bundle_index.md:158` "No approximations are endorsed".

**No promotion found.** Every static finding remains a bounded search hint; every live value remains `[U]` pending its named owner-only experiment; even a green harness yields internal consistency only.

## 6. Explicit confirmation — no implementation lane asserted donor parity

Two new implementation lanes landed, both DONE/parses OK (`PORT1TO1_handoff_sync.md:39`; plan `:221`, `:227`):

- **2D — `IMPL-START-CAMERA-WIRE`:** `variant3d/scripts/camera.gd:55-80` recovers the donor one-shot wire as static text `[O]`; `:63-64` "donor-settled `[O]` … tag is RETIRED" is immediately bounded by `:70-76` "STILL `[U]` (fixed-seed captures; **NOT claimed**)" and "never donor law", `:77-79,89,161` "PORT CHOICE `[U]-CAM`, NOT donor-derived", `:17,30,178` "NO PARITY CLAIM". The consumer at `:179-187` is called from `:246` and applies the target through the **existing** `jump_to_world()` API — "No constant, no FOV and no zoom write is invented" (`:68-69`).
- **3D — `IMPL-START-CAMERA-3D`:** `variant3d/scripts/camera3d.gd:473-484` is the mirror through the 3D `jump_to_world()`; `:479-480` "no view_scale factor, and NO new FOV/zoom/pitch/height constant"; `:483` donor time/height args + native clamp stay `[U]` CAM-derive/CAM-0; `:484` "NO PARITY CLAIM". FOV/sensor/projection remain "PORT APPROXIMATION / UNVERIFIED" at `:49,72,91,96-97,103,110,199,444-445,622-627`.
- **Seam:** `variant3d/scripts/game.gd:685` "this exposes ONLY the start-derived target to the port camera API. **NO PARITY CLAIM.**"; `:687-709` one-shot flag arm/consume; `PORT1TO1_handoff_sync.md:39` "No new FOV/zoom/height constant, no `HEIGHT_SCALE`; donor height/time args and native clamp stay `[U]`".
- **Repo-wide source scan:** `variant3d/` returned no match for C1 true flags or for runtime donor-parity assertion forms (`parity=true`, `visual_parity_claim:=true`, "donor parity confirmed/achieved/PASS/verified", "parity achieved", "matches donor", "close to donor", "perfect/full parity", "1:1 parity"). The only "donor-settled"/"RETIRED" strings are the guarded static-text phrasings in GAP-4N4.

**No implementation-lane parity assertion found.** Both lanes wire a donor-text-located target while keeping every numeric derivation `[U]`, exactly as the deep reports prescribe; neither closes a P0.

## 7. Dominance confirmation and verdict

- `parity=UNVERIFIED`, `parity.claim=NONE`, `parity.claim_code=NONE`, `visual_parity_claim=false` dominate across all 14 new reports and the baseline set. Representative exact citations: `PORT1TO1_bundle_index.md:13-17`; `DEC_U12_caller_walk.md:14-17`; `DEC_U3_reg_sweep.md:10-12,22`; `DEC_U_coll_census_deep.md:8-9`; `DEC_U_smooth_kernel_deep.md:8-9`; `DEC_U_tver_deep.md:9-14`; `DEC_U_econ_deep.md:9,11,179-181`; `DEC_U_place_seed_deep.md:9-12`; `PORT1TO1_b_angle_index.md:8-13`; `PORT1TO1_c_decisions.md:8-13`; `PORT1TO1_d_cosmetic.md:8-13`; `PORT1TO1_handoff_sync.md:11-15`; `PORT1TO1_plan_sync.md:7,13-16`; `PORT1TO1_d4_reclass.md:8-13`.
- **`RESULT IS NOT GOOD`** while `blocking_unverified` is non-empty — all nine P0 rows plus the register tails remain OPEN (`PORT1TO1_b_angle_index.md:12`; `PORT1TO1_d4_reclass.md:12`; `PORT1TO1_handoff_sync.md:14`). **Six-condition chain 0/6 CLOSED**; conditions 2 and 6 are PARTIAL (port-internal only), conditions 1/3/4/5 BLOCKED (`PORT1TO1_decision_sim.md:43-46`; `PORT1TO1_parity_chain.md:38-58`; `PORT1TO1_bundle_index.md:95`). No donor GPU A/B frame exists; no COORD ruling exists.
- **No approximation adopted, no parity claim, no test weakened, no gate/capture/donor execution.** The five new gaps in §4.1 plus the carried-forward baseline gaps are label-only and none was applied by this audit. Exactly one repository file was written: this report.

*End of CLAIM-RECHECK4. PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass. `RESULT IS NOT GOOD`; chain 0/6.*
