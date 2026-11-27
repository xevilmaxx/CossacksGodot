---
id: PORT1TO1-CLAIM-RECHECK2-2026-11-27
title: "CLAIM-RECHECK2 — read-only post-deep-pass parity-claim string re-sweep: all current reports + current variant3d/"
agent: CLAIM-RECHECK2 (read-only subagent; no code/Godot/git/donor execution)
created: 2026-11-27
role: "Follow-up to PORT1TO1_claim_final.md, which swept the tree before the ~15-17 deep-pass/owner reports landed. Re-scan EVERY current reports/*.md plus current variant3d/ for forbidden parity strings and misread-risk phrasing introduced by the new reports; verify each new report's verdict line; cite every gap with LABEL-ONLY remediation; confirm no deep pass promoted a static finding to behavioural parity."
parity: UNVERIFIED
parity_claim: NONE
parity_claim_code: NONE
visual_parity_claim: false
verdict: "RESULT IS NOT GOOD — blocking_unverified is non-empty; six-condition chain 0/6 CLOSED; no donor GPU A/B frame; no COORD ruling; no approximations; no parity claim."
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
output_files: "Exactly one repository file written: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_claim_recheck2.md"
methods: "Read-only glob/grep/read of the current working tree. No code edit, no Godot process, no runner subcommand, no gate, no capture, no donor execution, no git command, no result-JSON/test/backup/config mutation. All file:line numbers are current working-tree numbers. Every quoted forbidden literal below is quoted as a SCAN TARGET, a NEGATION, or a GUARDED OBSERVATION — never as a claim."
---

# CLAIM-RECHECK2 — post-deep-pass parity-claim string re-sweep (current tree, 2026-11-27)

> **PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.**

This is a read-only label/string audit. It does not execute the donor, Godot, a runner job, a gate or a capture; it does not run git; it does not close a `[U]`, wire a value, promote a metric or change any file other than this report. It supplements `PORT1TO1_claim_final.md`, which PASSed source/report parity strings **before** the deep-pass/owner wave landed. This sweep re-checks those strings against the current tree and audits the newly landed reports.

## 1. Scope — what counts as "new" here

Baseline cut = mtime of `PORT1TO1_claim_final.md` (2026-11-27 00:05:33). Every report with a later mtime is treated as new: 17 files.

- **Eight static deep passes:** `DEC_U12_deep.md`, `DEC_U_blend_deep.md`, `DEC_U_fow_numeric_deep.md`, `DEC_U_save_deep.md`, `DEC_U_tick_deep.md`, `DEC_U_select_deep.md`, `DEC_U_hmap_num_deep.md`, `DEC_U_water_shader_deep.md` (the repaired/complete rewrite, 04:15:13).
- **Four owner-facing/protocol packets:** `PORT1TO1_rng_owner_protocol.md`, `PORT1TO1_owner_decisions_update.md`, `PORT1TO1_owner_brief_addendum.md`, `PORT1TO1_p0_dryrun.md`.
- **Five in-between reports:** `PORT1TO1_decision_sim.md`, `PORT1TO1_handoff_checklist.md`, `PORT1TO1_p0_consistency.md`, `PORT1TO1_objects_anim_collisions_fx.md`, `PORT1TO1_water_owner_protocol.md` (the F3-repaired version, 00:10:12).

Scanned in full: `docs/terrain_swarm_2026-11-26/reports/**/*.md`, plus `spec/**`, root docs (`CHARTER.md`, `HANDOFF.md`, `SWARM_BOARD.md`, `REPORT_INDEX.md`, plans) and the current `variant3d/` tree (`.gd`, `.gdshader`, `.json`, `.md`, `.cfg`, `.tscn`).

Scan classes (inherited from the baseline, case-insensitive where wording varies), each run repo-wide over both trees:

- **C1** forbidden true flags: `parity=true`, `parity = true`, `"parity": true`, `visual_parity_claim=true`, `parity_claim=true`, `donor_parity_claim=true`, `parity=PASS`.
- **C2** `RESULT IS GOOD` (unqualified vs qualified / conditional / template / negation).
- **C3** `claim=owner-supplied` used as a pass.
- **C4** unqualified donor-parity assertions: "donor parity confirmed/achieved/PASS/verified", "parity achieved", "matches donor", "close to donor", "donor-exact" read as a runtime claim, "1:1/1TO1 parity", "perfect/full parity".
- **C5** gate/metric promoted to parity: "gate PASS ⇒ parity", "PASS proves donor", "no threshold + metric = parity".
- **C6** port-internal "parity" strings misreadable as donor parity when cut out of context (including new "donor-faithful" phrasing).

## 2. Result by class — guarded vs unguarded

| Class | Live unguarded claim introduced by the new wave | Classification | Evidence (exact file:line) |
|---|---|---|---|
| **C1 true flags** | **NONE** | Every hit is a quoted scan target, a negation, a zero-count assertion or a governance list. `variant3d/` scan for compact/quoted `true` forms (`"parity": true`, `visual_parity_claim:=true`, `parity=PASS`, etc.) returned **no matches**. | Baseline targets remain quoted-only: `DEC_U_port_guard_audit.md:77,160`; `PORT1TO1_final_guard_audit.md:30,42,167`; `PORT1TO1_internal_validation.md:128`; `V111_asset_final.md:27` ("0 `visual_parity_claim:true`"); `V33_do_not_do_checklist.md:73`; `V76_gate_preflight.md:46`. New reports add no C1 flag: deep passes use `visual_parity_claim: false` (`DEC_U12_deep.md:13`, `DEC_U_hmap_num_deep.md:13`, `PORT1TO1_water_owner_protocol.md:13`); owner packets use `parity_claim: false|NONE` (`PORT1TO1_rng_owner_protocol.md:14-17`, `PORT1TO1_owner_decisions_update.md:14-17`, `PORT1TO1_p0_dryrun.md:18-20`, `PORT1TO1_decision_sim.md:12-14`, `PORT1TO1_handoff_checklist.md:27-29`, `PORT1TO1_p0_consistency.md:12-14`). |
| **C2 `RESULT IS GOOD`** | **NONE unguarded** | All hits are conditional templates, forbidden-phrasing lists, quotations of prior audits, or explicit negations ("admissible only when `blocking_unverified=[]` … not today"). The new reports' occurrences are all of the guarded form; the eight deep passes contain the string **zero** times. | New guarded: `PORT1TO1_owner_decisions_update.md:113` (forbidden-to-settle row), `:130` (verdict `RESULT IS NOT GOOD`); `PORT1TO1_owner_brief_addendum.md:81`; `PORT1TO1_p0_dryrun.md:181`; `PORT1TO1_decision_sim.md:56,142`; `PORT1TO1_rng_owner_protocol.md:256-258`; `PORT1TO1_handoff_checklist.md:293`. Baseline guarded set unchanged: `W08_visual_acceptance_criteria.md:196`; `V15_acceptance_without_reference.md:331-332`; `X39_ab_feasibility.md:236` (now `RESULT IS NOT GOOD … no unqualified RESULT IS GOOD`); `PORT1TO1_final_guard_audit.md:30,64,65,157,167`; `PORT1TO1_acceptance_plan.md:368`; `PORT1TO1_acceptance_runbook.md:345`; `PORT1TO1_owner_brief.md:94`; `PORT1TO1_final_gates.md:147`; `V67_owner_answer_check.md:128`. |
| **C3 `claim=owner-supplied`-as-pass** | **NONE** | Every occurrence is "records a human assertion, not a verdict; never promotes `parity=UNVERIFIED`". New reports repeat only the negation. | `PORT1TO1_decision_sim.md:56,142,173`; `PORT1TO1_final_guard_audit.md:30,48-49,167`; `PORT1TO1_gate_audit.md:164`; `PORT1TO1_artifact_layout.md:196`; `PORT1TO1_acceptance_plan.md:252,263`; `PORT1TO1_roi_register.md:90,213`; `variant3d/tools/acceptance/compare_frames.py:16,139,255`; `variant3d/tools/acceptance/README.md:13,129`. |
| **C4 donor-parity assertion** | **NONE unguarded** | Hits split into (a) negations / forbidden-phrasing lists and (b) static `[O]/[D]` donor text/byte recovery with the port side labelled PORT APPROXIMATION or `[U]` — not runtime parity. The new wave adds no runtime claim. | New negations/lists: `PORT1TO1_owner_brief_addendum.md:81`; `PORT1TO1_p0_dryrun.md:138,181`; `PORT1TO1_decision_sim.md:142,172`; `PORT1TO1_owner_decisions_update.md:19,33,113`; `PORT1TO1_rng_owner_protocol.md:36,262`. New static recoveries with inline guard: `PORT1TO1_objects_anim_collisions_fx.md:9,243,283,412,615,623` ("donor text/byte exact [O]; NOT visual parity"); `DEC_U_collision_full.md:282,285,289,290`; `DEC_U_inertia_rtti.md:202,205`; `DEC_U_move_speed.md:250,253,256`; `DEC_U_res_point.md:27,232`; `DEC_SMALL_shore_rings.md:84`; `DEC_U_skirmish_impl_patch.md:538`; `DEC_VIS_03_fields.md:413` (negation); `F07_mill_fields.md:215` ("a **PORT APPROXIMATION**, not donor parity"). Live source guarded: `variant3d/scripts/audio.gd:404` (`[I] … not donor-exact`); `variant3d/scripts/game.gd:8156-8158` (`NO PARITY CLAIM` then static literal note), `:123,895,2508,2777,2877,3312,5491,7192,8207,8216,8228,8245,8368,8396,8637,8665,8753,9076,9837` (all negations / `visual_parity_claim=false`); `variant3d/scripts/hud.gd:683` (negation); `variant3d/scripts/data.gd:429,693,2407,2414,2418` (LABEL ONLY). |
| **C5 gate/metric → parity** | **NONE** | Every gate/metric surface is explicitly denied as parity. The new reports restate the denial; none attaches "PASS" to parity. | `PORT1TO1_decision_sim.md:163-180` (§4 "Risk of misreading internal PASS / gates / ROI metrics as parity"; `:169` names `t_terrain_donor.json` `status=PASS` the highest-risk cue and quotes its own `parity.claim=NONE`); `PORT1TO1_p0_dryrun.md:31,40-43,158-160`; `PORT1TO1_rng_owner_protocol.md:204-211` ("Close", metric, average, threshold retune, retry-until-green and port-internal replay pair never count); `PORT1TO1_owner_decisions_update.md:61,105-114`; `PORT1TO1_final_gates.md:14,44,69,98,162,167,173`; `PORT1TO1_gate_audit.md:14,40,163,164,192,200-201,219,225`; `PORT1TO1_parity_chain.md:41,121,129-130,147,152`; `PORT1TO1_parity_recheck.md:46,117-118,136,141`; `PORT1TO1_roi_metrics.md:25`; `PORT1TO1_roi_register.md:27,222`; `PORT1TO1_internal_validation.md:154`; `V112_gate_witness.md:14,37,93`; `V102_final_blockers.md:96`; `V111_asset_final.md:16,49` (asset GO "not a gate PASS, not donor parity"). |
| **C6 misread-risk strings** | **NONE is a parity claim**; 4 residual un-hardened strings from the baseline register + 2 NEW "donor 1:1 / donor-faithful" phrasings in deep-pass reports | Guarded by explicit inline or adjacent negations; all are label-only hardening items. Full register in §4. | See §4. |

**C1–C5 result: no live unguarded parity claim was introduced by any of the 17 new reports, and none was introduced in `variant3d/` by the label-fix edits that landed just after the baseline audit.** All C6 strings are guarded; they are listed only because a reader cutting a line out of context could misread them.

## 3. Verdict-line verification for every new report

The owner's required verdict marker is `RESULT IS NOT GOOD` / `parity.claim=NONE` / `UNVERIFIED`. All 17 new reports carry at least one form; 9 carry the full governing triple. The eight static deep passes express the verdict as `[U]` + "No parity claim" / `visual_parity_claim:false` and do **not** carry the literal `RESULT IS NOT GOOD` or `parity.claim=NONE` — a presentation gap (GAP-1, label-only), not a suppressed verdict.

| # | New report | Verdict evidence (current tree) | Full governing triple? |
|---|---|---|---|
| 1 | `DEC_U12_deep.md` | `:7` `status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM`; `:13` `visual_parity_claim: false`; `:21` "no parity is claimed"; `:131` "**No parity claim**"; `:132` "No approximation substituted"; §6 `[U]` register. | No — UNVERIFIED / no-parity form only |
| 2 | `DEC_U_blend_deep.md` | `:8` labels `NO_PARITY_CLAIM, NO_APPROXIMATION`; `:9` `parity_guard: "NO DONOR PARITY IS CLAIMED"`; `:19` "No parity claim"; `:234` claim 12 **Denied**; `:238` "No donor parity … claimed". | No — UNVERIFIED / no-parity form only |
| 3 | `DEC_U_fow_numeric_deep.md` | `:10` `parity: NO PARITY CLAIM`; `:15` "no parity is claimed"; `:132` "unproven by static means"; `:162` "No parity claimed"; §6 `[U]` register. | No — UNVERIFIED / no-parity form only |
| 4 | `DEC_U_save_deep.md` | `:6` `NO_PARITY_CLAIM`; `:10` `parity: "NO PARITY CLAIM …"`; `:115` "NO PARITY CLAIM"; `:116` "No number invented"; §5 `[U]` register. | No — UNVERIFIED / no-parity form only |
| 5 | `DEC_U_tick_deep.md` | `:6` `NO_PARITY_CLAIM`; `:10` `parity: "NO PARITY CLAIM …"`; `:131` "NO PARITY CLAIM"; `:132` "Any frame-level round-robin … is `[U]`"; §5 `[U]` register. | No — UNVERIFIED / no-parity form only |
| 6 | `DEC_U_select_deep.md` | `:8` `NO_PARITY_CLAIM`; `:9` `parity_guard: "NO DONOR PARITY IS CLAIMED"`; `:20` "No parity claim"; `:178` claim 8 `[U]`, claim 9 **Denied**; `:182` "No parity … claimed". | No — UNVERIFIED / no-parity form only |
| 7 | `DEC_U_hmap_num_deep.md` | `:7` `NO_PARITY_CLAIM`; `:13` `visual_parity_claim: false`; `:23` "no live numbers promoted"; `:185` "**No parity claim**"; `:186` "No approximation substituted"; §6 `[U]` register. | No — UNVERIFIED / no-parity form only |
| 8 | `DEC_U_water_shader_deep.md` | `:5` `NO_PARITY_CLAIM`; `:8` "no parity claim"; `:65` "No parity claim. No approximation substituted"; `:69` "no byte in this pass promotes any path, scalar, time source, UV, or reflection target to settled". | No — UNVERIFIED / no-parity form only |
| 9 | `PORT1TO1_rng_owner_protocol.md` | `:14-17` `parity_status: UNVERIFIED`, `parity_claim: false`, `parity_claim_code: NONE`, `visual_parity_claim: false`; `:18` "… chain 0/6 … no donor GPU A/B frame … no parity claim"; `:256` "verdict remains **`RESULT IS NOT GOOD`**"; `:258` `parity.claim=NONE`. | **Yes** |
| 10 | `PORT1TO1_owner_decisions_update.md` | `:14-17` full flags; `:18` `verdict: "RESULT IS NOT GOOD — … chain 0/6 CLOSED … no parity claim"`; `:33` reviewer line; `:130` verdict template. | **Yes** |
| 11 | `PORT1TO1_owner_brief_addendum.md` | `:12` `parity_status: UNVERIFIED`; `:13` `parity_claim: NONE`; `:14` `verdict: "RESULT IS NOT GOOD …"`; `:31` reviewer line; `:81` unconditional verdict. | **Yes** |
| 12 | `PORT1TO1_p0_dryrun.md` | `:18-20` full flags; `:21` `verdict: "RESULT IS NOT GOOD … chain 0/6 CLOSED …"`; `:27` reviewer line; `:170-179` verdict template. | **Yes** |
| 13 | `PORT1TO1_decision_sim.md` | `:12-14` full flags; `:15` `verdict: "RESULT IS NOT GOOD … chain 0/6 CLOSED …"`; `:35` reviewer line; `:122` "RESULT IS NOT GOOD unconditionally". | **Yes** |
| 14 | `PORT1TO1_handoff_checklist.md` | `:27-29` full flags; `:30` `verdict: "RESULT IS NOT GOOD …"`; `:31` reviewer line; `:282-286` template; `:296` sign-off state. | **Yes** |
| 15 | `PORT1TO1_p0_consistency.md` | `:12-14` full flags; `:15` `verdict: "RESULT IS NOT GOOD … chain 0/6 CLOSED …"`; `:25` reviewer line; `:111` final template. | **Yes** |
| 16 | `PORT1TO1_objects_anim_collisions_fx.md` | `:9` parity_guard "NO DONOR PARITY IS CLAIMED"; `:29` "No parity claim"; `:615` "**Denied** … parity UNVERIFIED"; `:623` "No donor parity, similarity score, threshold or gate PASS is claimed". | No — UNVERIFIED / no-parity form only |
| 17 | `PORT1TO1_water_owner_protocol.md` | `:13-15` full flags; `:16` `verdict: "RESULT IS NOT GOOD while blocking_unverified is non-empty (COORD P0 consistency F3 fix)"`; `:17` reviewer line; `:214` "`parity.status='UNVERIFIED'`, `parity.claim=NONE` throughout". | **Yes** (repaired after F3) |

**Conclusion on verdicts:** no new report asserts parity, closes a P0, or weakens a test. Nine carry the full owner triple; eight carry an equivalent UNVERIFIED/no-parity verdict. Chain is **0/6 CLOSED** in every packet that states a number.

## 4. Gap register — all LABEL-ONLY, no code/value/behaviour change

These strings are **not** parity claims. Each is guarded by an adjacent negation or a named port-internal qualifier. They are listed because an out-of-context quote could be misread as donor parity. **No remediation was applied by this audit**; replacements below are label text only.

### 4.1 Residual baseline C6 strings (still un-hardened in current tree)

| # | Exact file:line | Current string (excerpt) | Guard that prevents a claim | Label-only remediation |
|---|---|---|---|---|
| GAP-2 | `docs/.../reports/DEC_U_audio_rng.md:98` | "setting it to `1.0` is the donor-exact audition path for U-AUD-3 comparisons" | Same bullet says `PORT APPROXIMATION — no donor pitch RNG (sound.script:476,523 DefRandomOffset=0 [O])`; this is a text-pitch constant, not a runtime claim | Append `(text-pitch constant only; runtime/audio parity UNVERIFIED)`. (baseline MR-2) |
| GAP-3 | `variant3d/scripts/pattern_gen.gd:373` | "count parity with the pre-fix baseline" | "pre-fix baseline" is port-internal | Append `(port-internal count parity, NOT donor parity)`. (baseline MR-7) |
| GAP-4 | `variant3d/scripts/game.gd:81`, `:2438` | "simulation/world.gd parity"; "2D parity preserved" | Named port modules (`simulation/world.gd`, 2D) | Append `(port-internal, NOT donor parity)` at both sites. (baseline MR-8) |
| GAP-5 | `variant3d/scripts/input_controller.gd:938` | "keep 2D parity" | "2D" qualifier | Append `(NOT donor parity)`. (residual of baseline MR-9; `camera.gd:122` was cleared) |

Baseline C6 items already hardened in the current tree (**no action**): `PORT1TO1_objects_anim_collisions_fx.md:243,283,412` now `donor text/byte exact [O]; NOT visual parity` (MR-1); `variant3d/scripts/input_controller.gd:1424` now `P-33: donor hotkeys.cfg KEY MAP [O] static text only; NOT donor parity` (MR-3); `variant3d/scripts/camera3d.gd:135,136,165` now `port-internal parity; NOT donor parity [U]` and `:207,473,600` carry port-internal/negating tags (MR-4); `variant3d/scripts/main.gd:1051,1066` now `port-internal parity (NOT donor)` (MR-5); `variant3d/tests/t_anim_metrics.gd:23` now `(NOT donor-frame parity)` (MR-6). The C1–C5 register from `PORT1TO1_claim_final.md §2` is unchanged and still PASS.

### 4.2 NEW misread-risk phrasings introduced by deep-pass reports

| # | Exact file:line | Current string (excerpt) | Guard that prevents a claim | Label-only remediation |
|---|---|---|---|---|
| GAP-6 | `docs/.../reports/DEC_U_select_deep.md:18` | `# DEC-U-SELECT-DEEP — FOV law, projection args, drag-anchor, marquee inside-test (donor 1:1)` | `:9` parity_guard "NO DONOR PARITY IS CLAIMED"; `:20` "No parity claim"; claim 8 `[U]`, claim 9 Denied | Retitle suffix to `(static donor-source localization; NOT donor runtime parity)`. The literal "donor 1:1" in a heading is the single highest-cut-out-of-context risk in the new wave. |
| GAP-7 | `docs/.../reports/DEC_U_hmap_num_deep.md:186` | "… `±2.96` span, both explicitly labelled `[U3]`, is **endorsed as the donor-faithful behaviour** until the corresponding zero-mismatch capture lands" | `[U3]` tag, "until … capture lands", `:185` "No parity claim", `:153` "must not re-label `±2.96` as recovered" | Change "endorsed as the donor-faithful behaviour" to "retained as the labelled port substitute (NOT donor behaviour)". |
| GAP-8 | `docs/.../reports/DEC_U12_deep.md:132` | "The port's hard-fail (no water until a real reflection target) is **endorsed as donor-faithful**." | `:131` "No parity claim"; `:133` "No guess promoted"; §6 all `[U]` | Change to "retained as the labelled hard-fail posture (not a claim of donor behaviour)". |

### 4.3 Stale cross-references created by later repairs (label-only)

| # | Gap | Current-tree fact | Label-only remediation |
|---|---|---|---|
| GAP-9 | `PORT1TO1_owner_decisions_update.md:91` and `PORT1TO1_owner_brief_addendum.md:59` still describe `DEC_U_water_shader_deep.md` as "partially written / ends mid-table … `[truncated 9113 chars]` … only §§0–2 usable". | The file was repaired **after** both reports (mtime 04:15:13). Current file is a complete 71-line rewrite with full §2 table, §5 capture register, §6 claim register and §7 Verdict (`:69`). | Repoint both descriptions to the repaired complete file; delete the truncation warning. A reader following the stale note would skip a delivered static record. |
| GAP-10 | `PORT1TO1_p0_consistency.md:104` (F3) still records that `PORT1TO1_water_owner_protocol.md` has no `verdict`/reviewer line and "contains neither the verbatim reviewer line nor the string `RESULT IS NOT GOOD`". | The water packet was repaired **after** F3 (mtime 00:10:12): `:16` now carries `verdict: "RESULT IS NOT GOOD … (COORD P0 consistency F3 fix)"` and `:17` a reviewer line. | Mark F3 **REMEDIED in current tree**; keep its label-only text as the record of what was fixed. |
| GAP-11 | `PORT1TO1_owner_decisions_update.md:25` cites `PORT1TO1_handoff_checklist.md:136` as still recording that P0-7 has no dedicated packet; the RNG packet now exists. | The same report acknowledges this at `:95-99` as stale and deliberately not edited (read-only scope). `PORT1TO1_rng_owner_protocol.md` is on disk. | Mark the checklist pointer stale in a future owner pass; no worker edit. (Known and disclosed — low risk.) |
| GAP-12 | `PORT1TO1_claim_final.md §3` MR-1/3/4/5/6 register still reads as "recommended, not applied". | Those five hardening edits **have landed** in the current tree (§4.1 above). | Mark MR-1/3/4/5/6 applied; leave MR-2/7/8/9 open as GAP-2…GAP-5. |

**Every gap above is label-only. None changes a value, gate, assertion, threshold, `[U]` status, P0 status or preserve-only mod.** No gap is a parity claim.

## 5. Explicit confirmation — no deep pass promoted a static finding to behavioural parity

Checked each of the eight deep passes plus the three owner-summary reports that consume them. In every case a recovered `[O]/[D]` static fact is paired with a still-`[U]` live value and an owner-only zero-mismatch experiment; none is written into the port as donor behaviour.

- `DEC_U_blend_deep.md:143` "`afpLinear` names a linear mode — it does NOT name the blend-window weight `w(t)`"; `:184` "a second exported frame fetch is NOT demonstrated … fetch_policy:'nearest_single_no_blend [U]-B2'"; `:196` "Success bounds the SUPPORT only — it never names `w(t)`"; `:234` any port motion equal to donor **Denied**.
- `DEC_U12_deep.md:23` "no reflection texture, size, unit, or matrix value is supplied"; `:132-133` "No approximation substituted … No guess promoted"; `:125` FORBIDDEN list (neutral texture, assumed unit, invented bias matrix, pool rule).
- `DEC_U_fow_numeric_deep.md:132` "relation … to metres, map tiles, or any 2.5/5 m grid is **unproven by static means**"; `:146` "Explicit non-inventions: no cell size … no combine operator, no occlusion slope … no RTTI field layout, no knob default".
- `DEC_U_save_deep.md:115` "The port contract stays **key-order parity + round-trip determinism**, never byte parity"; `:116` "No number invented … every unrecovered byte is a named `[U]` with an experiment, never a filler constant".
- `DEC_U_tick_deep.md:132` "Any frame-level round-robin, rate, dispatch loop, thread effect, or stage interleave is `[U]` — never default plInd-ascending all-players-per-frame to donor law"; `:117` U-S1 stays PERMANENTLY NATIVE.
- `DEC_U_select_deep.md:109` "Until then every angle stays `PORT APPROXIMATION`"; `:178` claim 8 `[U]` (sensor width, FOV, near/far, anchor, marquee rule); `:162` "`SelectionRectPainter` keeps its `PORT APPROXIMATION` tag until then".
- `DEC_U_hmap_num_deep.md:62-64` byte-proven grid clamp is explicitly "do **not** wire as uniforms"; `:153` "The port must keep the `[U3]` labels and must not re-label `±2.96` as recovered"; `:185-186`.
- `DEC_U_water_shader_deep.md:69` "no byte in this pass promotes any path, scalar, time source, UV, or reflection target to settled".
- Consumer summaries: `PORT1TO1_owner_decisions_update.md:38-41` "Each **narrows an experiment**; **none closes a P0** … `CLOSED` appears for no P0 row"; `:67` "Each **bounds the capture**; none supplies the live value, and none is a parity claim"; `:105-114` forbidden-to-settle table. `PORT1TO1_owner_brief_addendum.md:33,63` "no gate pass, no parity verdict … NO P0 closed … no required zero-mismatch experiment was weakened, substituted or satisfied". `PORT1TO1_p0_dryrun.md:31,40-43,158-160` "A port-internal check may confirm **internal consistency only** … Never promote". `PORT1TO1_rng_owner_protocol.md:36,204-211` "a zero-mismatch result yields a `[D]+harness-id` *internal* result … it is **not** a donor runtime observation … `parity.status` remains UNVERIFIED".

**No promotion found.** Every static finding remains a bounded search hint; every live value remains `[U]` pending its named owner-only experiment; even a green harness yields internal consistency only.

## 6. Dominance confirmation and verdict

- `parity=UNVERIFIED`, `parity.claim=NONE`, `parity.claim_code=NONE`, `visual_parity_claim=false` dominate across all 17 new reports and the baseline set. Representative exact citations: `PORT1TO1_rng_owner_protocol.md:14-18,256-258`; `PORT1TO1_owner_decisions_update.md:14-19,130`; `PORT1TO1_owner_brief_addendum.md:12-14,31,81`; `PORT1TO1_p0_dryrun.md:18-22,27,170-179`; `PORT1TO1_decision_sim.md:12-16,35,122,142`; `PORT1TO1_handoff_checklist.md:27-31,296`; `PORT1TO1_p0_consistency.md:12-16,25,111`; `PORT1TO1_water_owner_protocol.md:13-17,214`; `PORT1TO1_objects_anim_collisions_fx.md:9,615,623`; the eight deep passes at the lines in §3.
- **`RESULT IS NOT GOOD`** while `blocking_unverified` is non-empty — all nine P0 rows plus the register tails remain OPEN (`PORT1TO1_owner_decisions_update.md:49-61,130`; `PORT1TO1_p0_dryrun.md:170-179`). **Six-condition chain 0/6 CLOSED**; conditions 2 and 6 are PARTIAL (port-internal only), conditions 1/3/4/5 BLOCKED (`PORT1TO1_decision_sim.md:43-46`; `PORT1TO1_owner_decisions_update.md:113`). No donor GPU A/B frame exists; no COORD ruling exists.
- **No approximation adopted, no parity claim, no test weakened, no gate/capture/donor execution.** The 12 gaps in §4 are label-only and none was applied by this audit. Exactly one repository file was written: this report.

*End of CLAIM-RECHECK2. PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass. `RESULT IS NOT GOOD`; chain 0/6.*
