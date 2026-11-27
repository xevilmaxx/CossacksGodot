---
id: PORT1TO1-CLAIM-RECHECK3-2026-11-27
title: "CLAIM-RECHECK3 — read-only post-deep-parity-claim string re-sweep: all current reports + current variant3d/"
agent: CLAIM-RECHECK3 (read-only subagent; no code/Godot/git/donor execution)
created: 2026-11-27
role: "Follow-up to PORT1TO1_claim_recheck2.md. Since that sweep ~14 more deep/owner reports landed plus one implementation lane (IMPL-START-CAMERA-WIRE). Re-scan EVERY current reports/*.md plus current variant3d/ for forbidden parity strings and misread-risk phrasing; verify each new report's UNVERIFIED/no-parity marker and verdict line; cite every gap with LABEL-ONLY remediation; confirm no deep pass promoted a static finding to behavioural parity and no implementation lane introduced a parity assertion."
parity: UNVERIFIED
parity_claim: NONE
parity_claim_code: NONE
visual_parity_claim: false
verdict: "RESULT IS NOT GOOD — blocking_unverified is non-empty; six-condition chain 0/6 CLOSED; no donor GPU A/B frame; no COORD ruling; no approximations; no parity claim."
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
output_files: "Exactly one repository file written: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_claim_recheck3.md"
methods: "Read-only glob/grep/read of the current working tree. No code edit, no Godot process, no runner subcommand, no gate, no capture, no donor execution, no git command, no result-JSON/test/backup/config or git mutation. All file:line numbers are current working-tree numbers. Every quoted forbidden literal below is quoted as a SCAN TARGET, a NEGATION, or a GUARDED OBSERVATION — never as a claim."
---

# CLAIM-RECHECK3 — post-deep parity-claim string re-sweep (current tree, 2026-11-27)

> **PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.**

This is a read-only label/string audit. It does not execute the donor, Godot, a runner job, a gate or a capture; it does not run git; it does not close a `[U]`, wire a value, promote a metric or change any file other than this report. It supplements `PORT1TO1_claim_recheck2.md`, which PASSed source/report parity strings before the latest deep-wave landed. This sweep re-checks those strings against the current tree and audits every newly landed report.

## 1. Scope — what counts as "new" here

Baseline cut = mtime of `PORT1TO1_claim_recheck2.md` (2026-11-27 04:19:25). Every report with a later mtime is treated as new: **19 files** (the 14 named in the task, plus 5 supporting packets).

- **The 14 deep/static probes:** `DEC_U_water_time_deep.md`, `DEC_U_water_uv_deep.md`, `DEC_U_save_trg_deep.md`, `DEC_U_fow_persist_deep.md`, `DEC_U_bld_death_time.md`, `DEC_U_fow_occ_deep.md`, `DEC_U_anim_complete_deep.md`, `DEC_U_capture_veto_deep.md`, `DEC_U_genseed_deep.md`, `DEC_U_endgame_team_deep.md`, `DEC_U_peace_deep.md`, `DEC_U_speed_consumer_deep.md`, `DEC_U_state_deep.md`, `DEC_U_start_deep.md`.
- **Five owner/index packets:** `PORT1TO1_evidence_index_deep_supplement.md` (04:20:16), `PORT1TO1_tree_recheck.md` (04:40:24), `PORT1TO1_deep_index2.md`, `PORT1TO1_u_classify.md`, `PORT1TO1_p0_final_status.md`.
- **One implementation lane:** `IMPL-START-CAMERA-WIRE` (plan `PORT1TO1_PLAN.md:232,246`), active, implemented in `variant3d/scripts/camera.gd` and its `game.gd` seam — audited in §6. No other new implementation lane landed (plan `:239-255` lists the rest as read-only workers).

Scanned in full: `docs/terrain_swarm_2026-11-26/reports/**/*.md` (the whole report set, including the newly landed files above), `spec/**`, root docs (`CHARTER.md`, `HANDOFF.md`, `SWARM_BOARD.md`, `REPORT_INDEX.md`, `PORT1TO1_PLAN.md`) and the current `variant3d/` tree (`.gd`, `.gdshader`, `.json`, `.md`, `.cfg`, `.tscn`).

Scan classes (inherited from the baseline, case-insensitive where wording varies), each run repo-wide over both trees:

- **C1** forbidden true flags: `parity=true`, `parity = true`, `"parity": true`, `visual_parity_claim=true`, `parity_claim=true`, `donor_parity_claim=true`, `parity=PASS`.
- **C2** `RESULT IS GOOD` (unqualified vs qualified / conditional / template / negation).
- **C3** `claim=owner-supplied` used as a pass.
- **C4** unqualified donor-parity assertions: "donor parity confirmed/achieved/PASS/verified", "parity achieved", "matches donor", "close to donor", "donor-exact" read as a runtime claim, "1:1/1TO1 parity", "perfect/full parity".
- **C5** gate/metric promoted to parity: "gate PASS ⇒ parity", "PASS proves donor", "no threshold + metric = parity".
- **C6** port-internal "parity" strings and "donor-faithful"/"donor 1:1"/"endorsed as donor-faithful" phrasing misreadable as donor parity when cut out of context.

## 2. Result by class — guarded vs unguarded

| Class | Live unguarded claim introduced by the new wave | Classification | Evidence (exact file:line) |
|---|---|---|---|
| **C1 true flags** | **NONE** | Every hit is a quoted scan target, a negation, a zero-count assertion or a governance list. A repo-wide scan for compact/quoted `true` forms (`"parity": true`, `visual_parity_claim:=true`, `parity=PASS`, `parity_claim: true`) returned **no live match in `variant3d/`**. | Baseline targets remain quoted-only: `DEC_U_port_guard_audit.md:77,160`; `PORT1TO1_final_guard_audit.md:30,42,167`; `PORT1TO1_internal_validation.md:128`; `V111_asset_final.md:27` ("0 `visual_parity_claim:true`"); `V33_do_not_do_checklist.md:73`; `V76_gate_preflight.md:46`; `PORT1TO1_tree_recheck.md:50`. The 14 new deep probes use `status: … NO_PARITY_CLAIM` (`DEC_U_water_time_deep.md:5`, `DEC_U_water_uv_deep.md:7`, `DEC_U_save_trg_deep.md:6`, `DEC_U_capture_veto_deep.md:6`, `DEC_U_genseed_deep.md:6/11`, `DEC_U_endgame_team_deep.md:6`, `DEC_U_peace_deep.md:6`, `DEC_U_start_deep.md:6`) or `labels: [… NO_PARITY_CLAIM …]` (`DEC_U_bld_death_time.md:8`, `DEC_U_anim_complete_deep.md:8`, `DEC_U_speed_consumer_deep.md:8`, `DEC_U_state_deep.md:8`), or `parity: "NO PARITY CLAIM …"` (`DEC_U_save_trg_deep.md:10`, `DEC_U_capture_veto_deep.md:10`, `DEC_U_endgame_team_deep.md:10`, `DEC_U_peace_deep.md:9`, `DEC_U_start_deep.md:10`, `DEC_U_fow_persist_deep.md:10`, `DEC_U_fow_occ_deep.md:10`). `DEC_U_water_uv_deep.md:13` carries `visual_parity_claim: false`. The 5 new packets carry `parity_claim: NONE|false` and `visual_parity_claim: false` (`PORT1TO1_tree_recheck.md:8-9`, `PORT1TO1_u_classify.md:10-11`, `PORT1TO1_p0_final_status.md:15-17`) or `status: … NO_PARITY_CLAIM` + `PARITY_UNVERIFIED` labels (`PORT1TO1_evidence_index_deep_supplement.md:9,11`, `PORT1TO1_deep_index2.md:10,12`). |
| **C2 `RESULT IS GOOD`** | **NONE unguarded** | All hits are conditional templates, forbidden-phrasing lists, quotations of prior audits, or explicit negations. The 14 new deep probes contain the unqualified string **zero** times. | New guarded reports: `PORT1TO1_u_classify.md:12` (`verdict: "RESULT IS NOT GOOD …"`), `PORT1TO1_p0_final_status.md:18` (same), `PORT1TO1_tree_recheck.md:10`, `PORT1TO1_evidence_index_deep_supplement.md:18`, `PORT1TO1_deep_index2.md:19`. Baseline guarded set unchanged: `W08_visual_acceptance_criteria.md:196`; `V15_acceptance_without_reference.md:331-332`; `X39_ab_feasibility.md:236` (now `RESULT IS NOT GOOD … no unqualified RESULT IS GOOD`); `PORT1TO1_final_guard_audit.md:30,64,65,157,167`; `PORT1TO1_acceptance_plan.md:368`; `PORT1TO1_acceptance_runbook.md:345`; `PORT1TO1_owner_brief.md:94`; `PORT1TO1_final_gates.md:147`; `PORT1TO1_u_register_update.md:113,172`; `PORT1TO1_decision_sim.md:142`; `PORT1TO1_p0_session_plan.md:250`; `V67_owner_answer_check.md:128` (remediation text). |
| **C3 `claim=owner-supplied`-as-pass** | **NONE** | Every occurrence is "records a human assertion, not a verdict; never promotes `parity=UNVERIFIED`". The new wave adds no occurrence. | `PORT1TO1_decision_sim.md:56,142,173`; `PORT1TO1_final_guard_audit.md:30,47-49,167`; `PORT1TO1_gate_audit.md:164`; `PORT1TO1_artifact_layout.md:196`; `PORT1TO1_acceptance_plan.md:252,263`; `PORT1TO1_roi_register.md:90,213`; `variant3d/tools/acceptance/compare_frames.py:16,139,255`; `variant3d/tools/acceptance/README.md:13,129`. |
| **C4 donor-parity assertion** | **NONE unguarded** | Hits split into (a) negations / forbidden-phrasing lists and (b) static `[O]/[D]` donor text/byte recovery paired with a still-`[U]` port side — not runtime parity. The new wave adds no runtime claim. | New negations/lists: `PORT1TO1_tree_recheck.md:54` (forbidden-phrasing inventory only); `PORT1TO1_evidence_index_deep_supplement.md:18`; `PORT1TO1_deep_index2.md:19,105`. New static recoveries with inline guard: `DEC_U_bld_death_time.md:186` ("Any port building-death visual/audio equals donor … **Denied** … parity UNVERIFIED"), `:190` ("No donor parity, similarity score, threshold or gate PASS is claimed"); `DEC_U_anim_complete_deep.md:226` ("Any port motion/timing/blend equal to donor … **Denied** … visual UNVERIFIED"), `:230`; `DEC_U_state_deep.md:202` ("Any port motion equalling donor … **Denied** … visual UNVERIFIED"), `:206`; `DEC_U_speed_consumer_deep.md:255` ("Any port visual equals donor … **Denied** … parity UNVERIFIED"), `:259`; `DEC_U_water_time_deep.md:152` ("No parity claim"), `:148` ("Keep `visual_parity_claim=false`"); `DEC_U_water_uv_deep.md:201,204`; `DEC_U_save_trg_deep.md:157`; `DEC_U_fow_persist_deep.md:130`; `DEC_U_fow_occ_deep.md:103`; `DEC_U_capture_veto_deep.md:155`; `DEC_U_genseed_deep.md:185`; `DEC_U_endgame_team_deep.md:237`; `DEC_U_peace_deep.md:131`; `DEC_U_start_deep.md:141`. Live source guarded: `variant3d/scripts/audio.gd:404` (`[I] … not donor-exact`); `variant3d/scripts/game.gd:8156-8158` (`NO PARITY CLAIM`), `:685,4525` (implementation-seam negations); `variant3d/scripts/camera.gd:15-17,24,30,178` (negations); `variant3d/scripts/hud.gd:683`; `variant3d/scripts/data.gd:429,693,2407,2414,2418` (LABEL ONLY). |
| **C5 gate/metric → parity** | **NONE** | Every gate/metric surface is explicitly denied as parity. The new reports restate the denial; none attaches "PASS" to parity. | `PORT1TO1_evidence_index_deep_supplement.md:18,115` ("Index presence implies no claim and no gate PASS … nothing closes a `[U]`, promotes a metric … or upgrades any report to a gate PASS"); `PORT1TO1_deep_index2.md:19,105` (same); `PORT1TO1_p0_final_status.md:18` ("no value promoted by any deep pass"); `PORT1TO1_tree_recheck.md:10,34`; `PORT1TO1_decision_sim.md:163-180`; `PORT1TO1_gate_audit.md:14,40,163,164,192,200-201,219,225`; `PORT1TO1_final_gates.md:14,44,69,98,162,167,173`; `PORT1TO1_parity_chain.md:41,121,129-130,147,152`; `PORT1TO1_parity_recheck.md:46,117-118,136,141`; `PORT1TO1_internal_validation.md:154`; `V112_gate_witness.md:14,37,93`. |
| **C6 misread-risk strings** | **NONE is a parity claim**; 2 NEW "donor 1:1 / endorsed as donor-faithful" phrasings + 2 NEW implementation-seam "donor-settled [O]" phrasings, all guarded; residual baseline strings still un-hardened | Guarded by explicit inline or adjacent negations; all are label-only hardening items. Full register in §4. | See §4. |

**C1–C5 result: no live unguarded parity claim was introduced by any of the 19 new reports, and none was introduced in `variant3d/` by the `IMPL-START-CAMERA-WIRE` lane.** All C6 strings are guarded; they are listed only because a reader cutting a line out of context could misread them.

## 3. Verdict-line verification for every new report

The owner's required verdict marker is `RESULT IS NOT GOOD` / `parity.claim=NONE` / `UNVERIFIED`. All 19 new reports carry at least one form; **5 carry the full governing triple**. The 14 static deep probes express the verdict as `[U]` + "NO PARITY CLAIM" plus a closing claim register with a **Denied** row for any "port equals donor" reading, and do **not** carry the literal `RESULT IS NOT GOOD` or `parity.claim=NONE` — the same presentation gap recorded as GAP-1 in `PORT1TO1_claim_recheck2.md` (LABEL-ONLY, not a suppressed verdict).

| # | New report | UNVERIFIED / no-parity evidence | Verdict line (current tree) | Full governing triple? |
|---|---|---|---|---|
| 1 | `DEC_U_water_time_deep.md` | `:5` status `NO_PARITY_CLAIM`; `:8` "No parity claim"; `:152` "**No parity claim.** No donor binary executed …"; `:153` "No approximation substituted" | Closing non-claims §9 (`:150-154`); `:148` keep `visual_parity_claim=false` / `unresolved=[U1,U3,U4*,U5,U6,U12]` | No — UNVERIFIED / no-parity form only |
| 2 | `DEC_U_water_uv_deep.md` | `:7` status `NO_PARITY_CLAIM`; `:13` `visual_parity_claim: false`; `:201` "**No parity claim.** …" | Closing non-claims §8 (`:199-205`); `:204` zero-mismatch termination load-bearing | No — UNVERIFIED / no-parity form only |
| 3 | `DEC_U_save_trg_deep.md` | `:6` status `NO_PARITY_CLAIM`; `:10` `parity: "NO PARITY CLAIM …"`; `:157` "NO PARITY CLAIM … never byte parity" | `:96` substantive static finding ("in-memory `orders[i].info.trg` is a runtime session handle [D]") + §7 non-claims (`:155-160`) | No — UNVERIFIED / no-parity form only |
| 4 | `DEC_U_fow_persist_deep.md` | `:10` "parity: NO PARITY CLAIM …"; `:130` "No parity claimed …"; `:131` "No approximation substituted" | §6 explicit non-claims (`:128-133`); §4 `[U]` transects with player-switch (W) / save-reload (S) arms | No — UNVERIFIED / no-parity form only |
| 5 | `DEC_U_bld_death_time.md` | `:8` labels `NO_PARITY_CLAIM`; `:9` parity_guard "NO DONOR PARITY IS CLAIMED …"; `:190` "No donor parity … is claimed" | §8 claim register `:186` **Denied** (port equals donor); §9 scope statement (`:188-190`) | No — UNVERIFIED / no-parity form only |
| 6 | `DEC_U_fow_occ_deep.md` | `:10` "parity: NO PARITY CLAIM …"; `:103` "No parity claimed …"; `:104` "No approximation substituted" | §6 explicit non-claims (`:101-105`); occlusion stays `[U]` with E-OCC transect | No — UNVERIFIED / no-parity form only |
| 7 | `DEC_U_anim_complete_deep.md` | `:8` labels `NO_PARITY_CLAIM`; `:9` parity_guard "NO DONOR PARITY IS CLAIMED …"; `:230` "No donor parity … is claimed" | §7 claim register `:226` **Denied** (port motion/timing/blend equal to donor); §8 scope statement | No — UNVERIFIED / no-parity form only |
| 8 | `DEC_U_capture_veto_deep.md` | `:6` status `NO_PARITY_CLAIM`; `:10` `parity: "NO PARITY CLAIM …"`; `:155` "NO PARITY CLAIM …" | §7 explicit non-claims (`:153-158`); engine-internal + behavioural confirmations stay `[U]` | No — UNVERIFIED / no-parity form only |
| 9 | `DEC_U_genseed_deep.md` | `:6` status `NO_PARITY_CLAIM`; `:11` `parity_claim: false`; `:185` "No parity claim. No invented seed." | §8 Bottom line (`:179-185`); every `[U]` has a breakpoint dump terminating on zero mismatches | No — UNVERIFIED / no-parity form only |
| 10 | `DEC_U_endgame_team_deep.md` | `:6` status `NO_PARITY_CLAIM`; `:10` "parity: NO PARITY CLAIM …"; `:237` "NO PARITY CLAIM …" | §7 explicit non-claims (`:235-240`); `:238` "No number invented" | No — UNVERIFIED / no-parity form only |
| 11 | `DEC_U_peace_deep.md` | `:6` status `NO_PARITY_CLAIM`; `:9` "parity: NO PARITY CLAIM …"; `:131` "NO PARITY CLAIM …" | §7 explicit non-claims (`:129-134`); `:132` `visual_parity_claim=false` | No — UNVERIFIED / no-parity form only |
| 12 | `DEC_U_speed_consumer_deep.md` | `:8` labels `NO_PARITY_CLAIM`; `:9` parity_guard "NO DONOR PARITY IS CLAIMED …"; `:259` "No donor parity … is claimed" | §7 claim register `:255` **Denied** (port visual equals donor march/turn/formation); §8 scope statement | No — UNVERIFIED / no-parity form only |
| 13 | `DEC_U_state_deep.md` | `:8` labels `NO_PARITY_CLAIM`; `:9` parity_guard "NO DONOR PARITY IS CLAIMED …"; `:175` "No row implemented. No parity claimed." | §8 claim register `:202` **Denied** (port motion equalling donor timing/pose/blend); §9 scope statement | No — UNVERIFIED / no-parity form only |
| 14 | `DEC_U_start_deep.md` | `:6` status `NO_PARITY_CLAIM`; `:10` "parity: NO PARITY CLAIM …"; `:141` "NO PARITY CLAIM …" | §7 explicit non-claims (`:139-145`); `:142` "No number invented"; supersession disclosed at `:143` | No — UNVERIFIED / no-parity form only |
| 15 | `PORT1TO1_evidence_index_deep_supplement.md` | `:9` status `…NO_PARITY_CLAIM…`; `:11` labels `PARITY_UNVERIFIED`; `:18` "PARITY IS UNVERIFIED … `parity.claim = NONE` …" | `:18` "`RESULT IS NOT GOOD` while `blocking_unverified` is non-empty"; `:115` final reviewer note | **Yes** |
| 16 | `PORT1TO1_tree_recheck.md` | `:8` `parity: UNVERIFIED`; `:9` `parity_claim: NONE`; `:10` `visual_parity_claim: false` | `:10` `verdict: "RESULT IS NOT GOOD … chain 0/6 CLOSED …"`; `:11` reviewer line | **Yes** |
| 17 | `PORT1TO1_deep_index2.md` | `:10` status `…NO_PARITY_CLAIM…`; `:12` labels `PARITY_UNVERIFIED`; `:19` "PARITY IS UNVERIFIED … `parity.claim = NONE` …" | `:19` "`RESULT IS NOT GOOD` while `blocking_unverified` is non-empty"; `:105` final reviewer note | **Yes** |
| 18 | `PORT1TO1_u_classify.md` | `:9-11` `parity_status: UNVERIFIED` / `parity_claim: NONE` / `visual_parity_claim: false` | `:12` `verdict: "RESULT IS NOT GOOD … 0/6 CLOSED …"`; `:13` reviewer line | **Yes** |
| 19 | `PORT1TO1_p0_final_status.md` | `:14-17` `parity_status: UNVERIFIED` / `parity_claim: false` / `parity_claim_code: NONE` / `visual_parity_claim: false` | `:18` `verdict: "RESULT IS NOT GOOD … 0/6 CLOSED … no value promoted by any deep pass …"`; `:19` reviewer line | **Yes** |

**Conclusion on verdicts:** no new report asserts donor parity, closes a P0, or weakens a test. Five carry the full owner triple; fourteen carry an equivalent UNVERIFIED/no-parity verdict with a closing claim register whose "port equals donor" row is **Denied**. Chain is **0/6 CLOSED** in every packet that states a number (`PORT1TO1_tree_recheck.md:10`, `PORT1TO1_u_classify.md:12`, `PORT1TO1_p0_final_status.md:18`, `PORT1TO1_evidence_index_deep_supplement.md:115`, `PORT1TO1_deep_index2.md:105`).

## 4. Gap register — all LABEL-ONLY, no code/value/behaviour change

These strings are **not** parity claims. Each is guarded by an adjacent negation or a named port-internal qualifier. **No remediation was applied by this audit**; replacements below are label text only.

### 4.1 NEW misread-risk phrasings in the 19 new reports

| # | Exact file:line | Current string (excerpt) | Guard that prevents a claim | Label-only remediation |
|---|---|---|---|---|
| GAP-N1 | `docs/.../reports/DEC_U_water_uv_deep.md:202` | "The port's current behaviour (BUILTIN default + hard-fail without reflection + labelled `[U6]` substitutes) is **endorsed as donor-faithful** until the corresponding zero-mismatch capture lands." | `:201` "No parity claim"; `:13` `visual_parity_claim: false`; `[U6]` tag; "until … capture lands"; `:204` zero-mismatch termination load-bearing | Change "endorsed as donor-faithful" to "retained as the labelled port substitute (NOT donor behaviour)". Same class as recheck2 GAP-7/GAP-8. |
| GAP-N2 | `docs/.../reports/DEC_U_bld_death_time.md:4` | `role: "WORKER DEC-U-BLD-DEATH-TIME — donor 1:1 building-death time-base static probe"` | `:9` parity_guard "NO DONOR PARITY IS CLAIMED …"; `:8` labels include `NO_PARITY_CLAIM`; `:186` claim 10 **Denied**; `:190` "No donor parity … is claimed" | Retitle suffix to `(static donor-source localization; NOT donor runtime parity)`. Same class as recheck2 GAP-6 (the highest cut-out-of-context risk in the previous wave). |
| GAP-N3 | `variant3d/scripts/camera.gd:63`, `:91`, `:161` | "the start-derived TARGET is donor-settled `[O]`"; "First TARGET is now the donor-settled one-shot wire above"; "the first TARGET is donor-settled via the game.gd flag …" | `:17`, `:30`, `:178` "NO PARITY CLAIM"; `:15-16` FOV "PORT APPROXIMATION / UNVERIFIED … NEVER a donor-claimed value"; `:77-79`, `:89` "PORT CHOICE `[U]-CAM` … NOT donor-derived"; `:70-76` CAM-derive/CAM-0 still `[U]` with fixed-seed captures | Append `(donor TEXT wire target only; runtime/visual parity UNVERIFIED)` at each site. Implementation-lane label hardening only. |
| GAP-N4 | `variant3d/scripts/game.gd:4537-4538` | "This branch implements the donor-settled peasant->mine case; the tow/cen case below stays as PORT_GARRISON." | `:4525` "NO PARITY CLAIM; CS-GARRISON `[U]` 3-run zero-mismatch retained"; `:4586` "NO PARITY CLAIM"; `:4535-4536` cites donor text `[O]` only | Append `(static donor-text gate only; runtime/visual parity UNVERIFIED)`. Implementation-seam label hardening only. |

The recurring `Required donor-faithful replacement` table headers in the new deep probes (`DEC_U_bld_death_time.md:165`, `DEC_U_anim_complete_deep.md:201`, `DEC_U_speed_consumer_deep.md:9` parity_guard, `DEC_U_state_deep.md:175-177`, `DEC_U_peace_deep.md:110`) are **guarded by the same-file parity_guard negations** ("names the algorithm to implement, not a claim it is implemented" / "No row implemented. No parity claimed"). They are the standard static-recovery idiom, not a new misread class; no action required beyond keeping those guards.

### 4.2 Residual baseline C6 strings still un-hardened in the current tree

Carried forward from `PORT1TO1_claim_recheck2.md §4.1/§4.2` — none was applied by this audit:

- `DEC_U_audio_rng.md:98` — "donor-exact audition path" (same bullet says `PORT APPROXIMATION — no donor pitch RNG …`). Append `(text-pitch constant only; runtime/audio parity UNVERIFIED)`.
- `variant3d/scripts/pattern_gen.gd:373` — "count parity with the pre-fix baseline" (port-internal). Append `(port-internal count parity, NOT donor parity)`.
- `variant3d/scripts/game.gd:81`, `:2438` — "simulation/world.gd parity"; "2D parity preserved" (named port modules). Append `(port-internal, NOT donor parity)`.
- `variant3d/scripts/input_controller.gd:938` — "keep 2D parity" ("2D" qualifier). Append `(NOT donor parity)`.
- `DEC_U_select_deep.md:18` — heading suffix "(donor 1:1)". Retitle `(static donor-source localization; NOT donor runtime parity)`.
- `DEC_U_hmap_num_deep.md:186` — "endorsed as the donor-faithful behaviour". Change to "retained as the labelled port substitute (NOT donor behaviour)".
- `DEC_U12_deep.md:132` — "endorsed as donor-faithful". Change to "retained as the labelled hard-fail posture (not a claim of donor behaviour)".

Guarded "endorsed as donor-faithful … until … capture lands" phrasings in pre-existing water/FOW reports (`DEC_U_water_mesh_uv.md:197`, `DEC_U_water_capture.md:200`, `DEC_U_hmap_identity.md:185`, `PORT1TO1_fow_owner_protocol.md:300`, `PORT1TO1_water_owner_protocol.md:219`) are unchanged and remain label-only; each is adjacent to a "No approximation substituted" / "No parity claim" and an `[U]` tag. Recheck2 GAP-9…GAP-12 (stale cross-references) are unchanged; no new stale pointer was found in the 19 new reports.

**Every gap above is label-only. None changes a value, gate, assertion, threshold, `[U]` status, P0 status or preserve-only mod. No gap is a parity claim.**

## 5. Explicit confirmation — no deep pass promoted a static finding to behavioural parity

Checked each of the 14 new deep probes plus the 5 owner/index consumers. In every case a recovered `[O]/[D]` static fact is paired with a still-`[U]` live value and an owner-only zero-mismatch experiment; none is written into the port as donor behaviour. None of these reports has an IMPL lane recorded (`PORT1TO1_deep_index2.md` rows, `PORT1TO1_PLAN.md:220-231`).

- `DEC_U_water_time_deep.md:148` "Keep `visual_parity_claim=false` and `unresolved=[U1,U3,U4*,U5,U6,U12]` until … captures supply 0-mismatch tuples"; `:153` "No time source, clock, delta literal, or writer is asserted beyond the byte-proven reader + construction zero."
- `DEC_U_water_uv_deep.md:204` "Zero-mismatch termination is load-bearing: any future claim that U6 is settled must cite the … capture tuple with 0 mismatches … else it is not donor truth."
- `DEC_U_save_trg_deep.md:157` "The port contract stays **key-order parity + round-trip determinism**, never byte parity"; `:158` "No number invented … every unrecovered byte names its experiment."
- `DEC_U_fow_persist_deep.md:131` "the provisional `1 res = 1 metre` driver stays labelled … until E-PERSIST-a terminates"; `:132` "RTTI field layouts explicitly unrecovered … no field map is cited or used."
- `DEC_U_bld_death_time.md:183-186` TIME BASE / burn / smoke stay `[U]`; "Any port building-death visual/audio equals donor motion/timing/sound — **Denied** … parity UNVERIFIED."
- `DEC_U_fow_occ_deep.md:103-104` "No parity claimed … no blocker, slope, step count, `FOWElevation` constant, or TLOS layout is added to the port by this report."
- `DEC_U_anim_complete_deep.md:223-226` "[U]-C1 / [U]-C2a…d stay open"; "Any port motion/timing/blend equal to donor … **Denied**."
- `DEC_U_capture_veto_deep.md:157` "No new veto, threshold, majority, cooldown, immunity, or lockout is asserted anywhere in this report."
- `DEC_U_genseed_deep.md:185` "Every still-[U] field carries a breakpoint dump that terminates only on zero mismatches plus a restart-changes-seed check. No invented seed. No parity claim."
- `DEC_U_endgame_team_deep.md:238` "No number invented: score has NO threshold, time limit has NO value … no wrapper arity beyond the verbatim parenthesised lists."
- `DEC_U_peace_deep.md:132` "No number invented: no opcode, no peace VA … no threshold beyond cited literals … `visual_parity_claim=false`."
- `DEC_U_speed_consumer_deep.md:252-255` "No global base speed / tick default byte-proven"; "Any port visual equals donor march/turn/formation motion — **Denied** … parity UNVERIFIED."
- `DEC_U_state_deep.md:201-202` "Every remaining `[U]` … has a named … capture with zero-mismatch termination"; "Any port motion equalling donor timing/pose/blend … **Denied**."
- `DEC_U_start_deep.md:142` "No number invented: no camera target/zoom/pitch/facing constant … no start-separation distance"; `:143` the prior ABSENT verdict is superseded only at path scope and "no `[U]` is closed by the flip … camera numerics … remain `[U]`" (`PORT1TO1_deep_index2.md:94`).
- Consumer summaries: `PORT1TO1_p0_final_status.md:18` "no value promoted by any deep pass"; `PORT1TO1_deep_index2.md:105` "Nothing in this index closes a `[U]`, promotes a metric, accepts an approximation or upgrades any report to a gate PASS"; `PORT1TO1_evidence_index_deep_supplement.md:115` same; `PORT1TO1_u_classify.md:12` "P0-1..P0-8 remain open"; `PORT1TO1_tree_recheck.md:10` "chain 0/6 CLOSED".

**No promotion found.** Every static finding remains a bounded search hint; every live value remains `[U]` pending its named owner-only experiment; even a green harness yields internal consistency only.

## 6. Explicit confirmation — no implementation lane introduced a parity assertion

Only one new implementation lane landed: `IMPL-START-CAMERA-WIRE` (plan `PORT1TO1_PLAN.md:232,246`), status DOING. Its surfaces are `variant3d/scripts/camera.gd` and the `game.gd` flag/target seam.

- `variant3d/scripts/camera.gd:17` "Global interleave / framing stay `[U]` O1/R1. **NO PARITY CLAIM.**"; `:24` "[U] PORT APPROXIMATION pending V2-MINI-QUAD (0 px capture). No parity claim."; `:30` "Donor text read-only; pin … binary NEVER executed. **NO PARITY CLAIM.**"; `:15-16` FOV 17.27 deg "stays PORT APPROXIMATION / UNVERIFIED … NEVER a donor-claimed value".
- `variant3d/scripts/camera.gd:70-76` "STILL `[U]` (fixed-seed captures; **NOT claimed**): CAM-derive … CAM-0 … S-place, S-ver, N-native"; zero-mismatch is declared "ENGINE-DEFAULT-STABLE, **never donor law**".
- `variant3d/scripts/camera.gd:77-79,89` START zoom 0.75 is "**PORT CHOICE `[U]-CAM`, NOT donor-derived**"; `:178` the one-shot wire function ends with "**NO PARITY CLAIM.**" No new FOV, zoom or camera constant is asserted to match the donor.
- `variant3d/scripts/game.gd:685` "this exposes ONLY the start-derived target to the port camera API. **NO PARITY CLAIM.**"; `:4525,4586` implementation comments carry "NO PARITY CLAIM" with CS-GARRISON `[U]` retained.
- Repo-wide scan of `variant3d/` for C1 true flags and for runtime donor-parity assertion forms (`parity=true`, `visual_parity_claim:=true`, "donor parity confirmed/achieved/PASS/verified", "parity achieved", "matches donor", "close to donor", "perfect/full parity", "1:1 parity") returned **no matches**. The only "donor-settled" strings are the guarded static-text phrasings in §4.1 (GAP-N3/GAP-N4).

**No implementation-lane parity assertion found.** The camera-wire lane wires a donor-text-located target while keeping every numeric derivation `[U]`, exactly as the deep report prescribes; it closes no P0.

## 7. Dominance confirmation and verdict

- `parity=UNVERIFIED`, `parity.claim=NONE`, `parity.claim_code=NONE`, `visual_parity_claim=false` dominate across all 19 new reports and the baseline set. Representative exact citations: `PORT1TO1_tree_recheck.md:8-11`; `PORT1TO1_u_classify.md:9-13`; `PORT1TO1_p0_final_status.md:14-19`; `PORT1TO1_evidence_index_deep_supplement.md:9,11,18,115`; `PORT1TO1_deep_index2.md:10,12,19,105`; the 14 deep probes at the lines in §3.
- **`RESULT IS NOT GOOD`** while `blocking_unverified` is non-empty — all nine P0 rows plus the register tails remain OPEN (`PORT1TO1_p0_final_status.md:18`; `PORT1TO1_u_classify.md:12`; `PORT1TO1_owner_decisions_update.md:49-61,130`). **Six-condition chain 0/6 CLOSED**; conditions 2 and 6 are PARTIAL (port-internal only), conditions 1/3/4/5 BLOCKED (`PORT1TO1_decision_sim.md:43-46`; `PORT1TO1_parity_chain.md:38-58`; `PORT1TO1_p0_final_status.md:18`). No donor GPU A/B frame exists; no COORD ruling exists.
- **No approximation adopted, no parity claim, no test weakened, no gate/capture/donor execution.** The 4 new gaps in §4.1 plus the carried-forward baseline gaps are label-only and none was applied by this audit. Exactly one repository file was written: this report.

*End of CLAIM-RECHECK3. PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass. `RESULT IS NOT GOOD`; chain 0/6.*
