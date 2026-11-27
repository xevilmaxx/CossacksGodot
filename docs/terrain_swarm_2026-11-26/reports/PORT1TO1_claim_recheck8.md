---
id: PORT1TO1-CLAIM-RECHECK8-2026-11-27
title: "CLAIM-RECHECK8 — read-only post-HANDOFF-fix parity-claim and stale-supersession re-sweep: all current reports + HANDOFF + plan + current variant3d/"
agent: CLAIM-RECHECK8 (read-only subagent; no code/Godot/git/donor execution)
created: 2026-11-27
role: "Follow-up to PORT1TO1_claim_recheck7.md. Since that sweep COORD qualified HANDOFF §9.20/§9.22 (camera-focus / task-count / baseline / label claims), LABEL-HARDEN applied two source qualifiers plus brief/register/plan heading fixes, and CLAIM-RECHECK7 landed. Re-scan EVERY current reports/*.md plus HANDOFF.md, PORT1TO1_PLAN.md (and .bak-NUMBERING) and the current variant3d/ source for unguarded parity strings and stale ABSENT/EXACT claims that contradict the later supersessions (start-camera wire, tool .oss, capture progress, team-win). Cite every remaining gap at exact file:line with LABEL-ONLY remediation; confirm the latest edits introduced no new claim."
parity: UNVERIFIED
parity_status: UNVERIFIED
parity_claim: NONE
parity_claim_code: NONE
visual_parity_claim: false
verdict: "RESULT IS NOT GOOD — blocking_unverified is non-empty; six-condition chain 0/6 CLOSED; nine P0 rows OPEN; 71 open [U] (A42/B14/C5/D10); no donor GPU A/B frame; no matched camera; no COORD ruling; static [D] facts narrow experiments only; no approximations; no parity claim."
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
output_files: "Exactly one repository file written: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_claim_recheck8.md"
methods: "Read-only glob/grep/read plus read-only filesystem mtime listings of the current working tree. No code edit, no Godot process, no runner subcommand, no gate, no capture, no ROI comparison, no donor execution, no git command, no result-JSON/test/backup/config mutation. All file:line numbers are current working-tree numbers. Every quoted forbidden literal below is quoted as a SCAN TARGET, a NEGATION, a FORBIDDEN-PHRASING LIST, a GUARDED OBSERVATION or a SUPERSESSION CITATION — never as a claim."
---

> **PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.**

# CLAIM-RECHECK8 — post-HANDOFF-fix parity-claim and stale-supersession re-sweep (current tree, 2026-11-27)

This is a read-only label/string audit. It does not execute the donor, Godot, a runner job, a gate, a capture or an ROI comparison; it does not run git; it does not close a `[U]`, wire a value, promote a metric, apply a label fix or change any file other than this report. It supplements `PORT1TO1_claim_recheck7.md`, which PASSed parity strings immediately after the LABEL-HARDEN fix wave. This sweep adds the four named supersession axes and the just-landed COORD HANDOFF point-in-time qualifications.

## 1. Scope and baseline cut

Scanned in full: `docs/terrain_swarm_2026-11-26/reports/**/*.md` (the whole set, including the newly landed `PORT1TO1_claim_recheck7.md`), `HANDOFF.md`, `PORT1TO1_PLAN.md` and `PORT1TO1_PLAN.md.bak-NUMBERING`, and the current `variant3d/` source (`.gd`, `.gdshader`, `.py`, `.json`, `.cfg`, `.tscn`, plus read of `spec/**` hits). Backup files (`*.bak-*`) are preservation-only and carry no live claim, as in recheck2–7.

Post-baseline state (read-only mtime sweep): the latest changes are the COORD qualifications of `HANDOFF.md:430` (§9.20) and `HANDOFF.md:454-460` (§9.22); `LABEL-HARDEN` comment qualifiers at `variant3d/scripts/terrain_donor_gen.gd:116` and `variant3d/scripts/terrain_donor_mesh.gd:1942`; the heading fixes at `PORT1TO1_owner_brief2.md:37`, `PORT1TO1_u_register2.md:21/23/103` and `PORT1TO1_PLAN.md:268`; the landing of `PORT1TO1_claim_recheck7.md`; and plan rows 262–266 (`PORT1TO1_PLAN.md:273-277`). `PORT1TO1_PLAN.md:276` (row 265) is this worker, `CLAIM-RECHECK8`, DOING — a status row, not a parity assertion.

Scan classes are inherited from `PORT1TO1_claim_final.md:28-33` / `PORT1TO1_claim_recheck6.md:41-48`: C1 forbidden true flags; C2 unqualified `RESULT IS GOOD`; C3 `claim=owner-supplied`-as-pass; C4 unqualified donor-parity assertion; C5 gate/metric promoted to parity; C6 port-internal or static-recovery phrasing misreadable as donor parity. A seventh axis, C7, is added here: **stale `ABSENT`/`EXACT` claim that a later report or implementation has superseded** (the four named topics).

## 2. Result by class — guarded vs unguarded

| Class | Live unguarded claim found by this sweep | Classification | Evidence (exact file:line) |
|---|---|---|---|
| **C1 true flags** | **NONE** | An independent live-`variant3d/scripts` scan for `parity\s*[=:]\s*true`, `"parity"\s*:\s*true`, `visual_parity_claim\s*[=:]\s*true`, `parity_claim\s*[=:]\s*true`, `donor_parity_claim\s*[=:]\s*true` returned **"No matches found"**. No report introduced a true flag. | Quoted-only inventories unchanged from recheck7 §2; post-HANDOFF edits add no flag. |
| **C2 `RESULT IS GOOD`** | **NONE unguarded** | Every hit is a conditional template, forbidden-phrasing list, quotation or negation; the rechecked final reports carry literal `RESULT IS NOT GOOD`. | `PORT1TO1_acceptance_plan.md:368`; `PORT1TO1_acceptance_runbook.md:345`; `PORT1TO1_final_gates.md:147`; `PORT1TO1_owner_brief2.md:15/99`; `X39_ab_feasibility.md:236`; `PORT1TO1_claim_recheck7.md:12`. |
| **C3 owner-supplied-as-pass** | **NONE** | All occurrences record a human assertion that never promotes `parity=UNVERIFIED`. | `PORT1TO1_decision_sim.md:56/142/173`; `PORT1TO1_gate_audit.md:164`; `PORT1TO1_claim_recheck7.md§2`. |
| **C4 donor-parity assertion** | **NONE unguarded** | Static `[O]/[D]` recovery paired with surviving `[U]`; runtime/visual parity denied. | Forbidden lists: `PORT1TO1_acceptance_plan.md:370`; `PORT1TO1_owner_brief2.md:99`; `V33_do_not_do_checklist.md:73`; `A03_asset_pipeline.md:266`. Guarded static recovery: `DEC_U_skirmish_impl_patch.md:538`; `F07_mill_fields.md:215`; `DEC_VIS_03_fields.md:413`. |
| **C5 gate/metric → parity** | **NONE** | Every gate/metric surface denies parity; the `--check-only` parse artifact is a syntax check, not a gate PASS. | `PORT1TO1_gate_audit.md:163/192/219`; `PORT1TO1_final_gates.md:98`; `PORT1TO1_parity_chain.md:130`; `PORT1TO1_roi_metrics.md:25/200`; `PORT1TO1_claim_recheck7.md§5`. |
| **C6 misread-risk strings** | **NONE is a parity claim**; no new phrasing introduced by the latest edits | Carried-forward guarded phrasings unchanged (`"donor-settled"`, `"donor-faithful"`, `"endorsed"`, `"2D parity"`, `"count parity with the pre-fix baseline"`), each adjacent to an inline negation. | `PORT1TO1_claim_recheck7.md§5`; `camera.gd:31-38/178`; `camera3d.gd:484`; `terrain_donor_gen.gd:109/126`; `terrain_donor_mesh.gd:1943-1948`. |
| **C7 stale `ABSENT`/`EXACT` claim** | **NONE is a parity claim**; 13 carried-forward historical claims still lack an **inline** supersession footnote at the source site | Centrally registered as flags (`PORT1TO1_evidence_index.md:367-375` C-1/C-2/C-3; `PORT1TO1_deep_index2.md:94` X-1; `PORT1TO1_bundle_index.md:143/147/149`; `PORT1TO1_handoff_check2.md:47-50`), but a reader of the source line alone can still take the stale reading as current. All remediations below are label-only. | Full register in §3. |

**C1–C6 result: no live unguarded parity claim exists in `reports/`, `HANDOFF.md`, the plan or live `variant3d/` source, and none was introduced by the latest edits.** C7 residues are not parity claims: they are historical donor-text findings whose *supersession* is registered but not footnoted inline.

## 3. C7 gap register — stale ABSENT/EXACT claims (all LABEL-ONLY, no code/value/status change)

No remediation below was applied by this audit. Each "superseding evidence" citation is a landed report or source line; none closes a `[U]`, changes a P0 row, wires a value or asserts parity.

### 3.1 Start-camera wire (supersession X-1)

| # | Exact file:line | Stale string (excerpt) | Superseding evidence | LABEL-ONLY remediation |
|---|---|---|---|---|
| 8S1 | `DEC_U_start_positions.md:90`, `:92`, `:98`, `:110`, `:111`, `:122` | "FIRST camera target / focus derivation — statically ABSENT `[O-absence / U]`"; EV-CAM-1 "NO `startx/y → camera` wiring exists in any readable script"; EV-CAM-7 "first-frame focus is therefore engine-default … any `homes[0]`-centred start view is a PORT CHOICE"; CAM row "NO literal `[U]`" | `DEC_U_start_deep.md:11/82-91/143` (wire at `doprogress.inc:41`, path-scope flip); `PORT1TO1_deep_index2.md:94` X-1; `PORT1TO1_handoff_sync.md:31/39`; plan task 217 `PORT1TO1_PLAN.md:228`; `PORT1TO1_handoff_check2.md:50` already proposes the fix | Add a one-line supersession footnote at the report top/§6: "ABSENT is **file-scope** (`data/scripts`) only; **path-scope SUPERSEDED** by `DEC_U_start_deep.md §3` — wire at `doprogress.inc:41`, 2D+3D implementation tasks 221/227; target/height/`time=0`/native clamp still `[U]`; NO PARITY CLAIM." Historical rows otherwise unchanged. |
| 8S2 | `DEC_U_victory_start.md:94`, `:167` | "Start placement — exact literals; camera focus: statically ABSENT `[O / U]`"; unresolved list "CAM-initial-focus" | Same X-1 chain; `DEC_U_start_deep.md:11/143` | Append "(superseded at path scope by `DEC_U_start_deep.md §3`; file-scope ABSENT stands; camera numerics `[U]`; no parity)". |
| 8S3 | `PORT1TO1_PLAN.md:130` (task 119) | "camera wire proven absent `[U]`" | Task 217 `:228`; `PORT1TO1_handoff_check2.md:48` | Append "(**superseded by task 217** — wire found at `doprogress.inc:41`; target/height/time `[U]`). Plan status label only. |
| 8S4 | `PORT1TO1_PLAN.md:134` (task 123) | "`camera.gd` comment-only negative proof + PORT CHOICE `[U]`-CAM **focus** tag" | Tasks 221/227 `:232/:238`; `PORT1TO1_claim_recheck4.md:91` GAP-4N4; `PORT1TO1_handoff_check2.md:49` | Append "(**focus tag retired** by tasks 221/227; zoom `0.75` remains PORT CHOICE `[U]-CAM`, NOT donor-derived)." |
| 8S5 | `PORT1TO1_evidence_index.md:244` | index row "camera wire proven absent `[U]`" | X-1 at `PORT1TO1_deep_index2.md:94`; `PORT1TO1_bundle_index.md:149` | Append "(path-scope superseded — see X-1; no `[U]` closed by the flip)". Index presence is existence only. |

Guarded, no action: `camera.gd:31-38` already carries a `SUPERSESSION` block and `:178` `NO PARITY CLAIM`; `camera3d.gd:473-484` carries the donor wire with width/height `[U]` and `NO PARITY CLAIM`. These are the *new* wire claims, not stale ABSENT claims, and are covered by recheck7 §5.

### 3.2 Tool `.oss` (supersession C-1)

| # | Exact file:line | Stale string (excerpt) | Superseding evidence | LABEL-ONLY remediation |
|---|---|---|---|---|
| 8T1 | `DEC_U_aaf_art_audit.md:89`, `:96`, `:156`, `:188` | "Units — body tracks exist; tool attaches do not (as `.oss`)"; "**no `peaukr_*` tool file** … no separate bone-track `.oss` was found in this pass"; "[U]-T … no `peaukr_*.oss` bone-track file was found"; "tool `.oss` files not found in `D:actors/units/` this pass" | `DEC_U_tool_attach.md:43/56/63/326` (56 `pea<nat>_<tool>.oss` under `attach/`, premise refuted by recursive parent-glob); `PORT1TO1_evidence_index.md:373` C-1; `PORT1TO1_bundle_index.md:147`; plan tasks 98/102/106 `PORT1TO1_PLAN.md:109/113/117` | Append to §2.1, §4 and the §6 claim table: "(**SUPERSEDED** — `DEC_U_tool_attach.md §1/§2.3` found 56 attach `.oss`; 63 tool skins + 3D attach wired by `IMPL-TOOL-WIRING`; T-A/T-B stay `[U]`; no parity)". The "this pass" scope qualifier is not a supersession footnote. |
| 8T2 | `DEC_U_final_register.md:80`, `:121` | "peasant tool attach (no `peaukr_*.oss` this pass)"; "tool-`.oss` full-tree globs" as static-settleable | `DEC_U_tool_attach.md:56/326`; C-1 `PORT1TO1_evidence_index.md:373` | Append "(superseded: 56 attach `.oss` exist; full-tree glob landed)". |
| 8T3 | `DEC_U_aaf_triggers.md:94` | "**no** — port `[U]-T` carried (no tool-attach path; `CONSTRUCT_SKIN_STATUS` labels it)" | `IMPL-TOOL-WIRING` task 106 `PORT1TO1_PLAN.md:117`; `HANDOFF.md:430` ("63 derived skins + 3D attach wiring") | Append "(superseded by task 106 — attach path wired; T-A/T-B remain `[U]`; no parity)". Note `IMPL_U_aaf_triggers.md:218` is a conditional glob/capture probe, already guarded. |

### 3.3 Capture progress (supersession C-2)

| # | Exact file:line | Stale string (excerpt) | Superseding evidence | LABEL-ONLY remediation |
|---|---|---|---|---|
| 8C1 | `DEC_U_skirmish.md:69` | "Still `[U]`: protector-count majority rule (lines ~1050-1100 tail not read this ticket) and post-capture cooldown. Experiment in §9-C1." | `DEC_U_skirmish_tables.md:230/242/344` (C1 RESOLVED; cooldown confirmed ABSENT); `DEC_U_capture_state.md:37/54/62`; `DEC_U_capture_veto_deep.md:30/91-93`; C-2 `PORT1TO1_evidence_index.md:374` | Append "(**RESOLVED** — ANY-protector veto + AI-artillery majority table, **no** post-capture cooldown; port `capture_t` retired to a dormant v5 key; see `DEC_U_skirmish_tables.md §3` / `DEC_U_capture_state.md §§1-2`; no parity)". |
| 8C2 | `DEC_U_skirmish_impl_patch.md:393`, `:399`, `:428`, `:597` | "**Keep the port's `capture_t` accumulation for those, labelled; do not claim the tail**"; "Tail (majority/cooldown) stays `[U]-C1`"; "Protector majority + post-capture cooldown stay `[U]-C1`"; "U4-tail capture majority + cooldown … not read" | Same C-2 chain; source already superseded at `game.gd:8278-8287`, `:8568-8573`, `:8685-8690`, `:8822-8825` (donor cadence law, no cooldown, `capture_t` dormant) | Append the 8C1 supersession note at each of the four sites. Documentation instruction only — no source change is proposed; `game.gd` already implements the donor law. |

Guarded, no action: `PORT1TO1_skirmish_logic.md:47` describes the port `capture_t` field as `Port [O]` (port-side structure, not a donor claim); `HANDOFF.md:430` already carries the corrected "capture has NO progress/majority/cooldown (first passing tick flips ownership)".

### 3.4 Team-win (supersession C-3)

| # | Exact file:line | Stale string (excerpt) | Superseding evidence | LABEL-ONLY remediation |
|---|---|---|---|---|
| 8W1 | `DEC_U_victory_start.md:73`, `:162`, `:176` | "no donor `_winner_of_loser` / team-continuation rule … is PORT policy"; "team-win aggregation — label PORT POLICY"; "V-prec … port team-continuation is policy" | `DEC_U_scenario_win.md:11/26/104/162` (correction logged: donor-verbatim `_misc_CheckEndGame`, `miscext2.script:3769-3844`, global `nothing.inc:646`); plan `:64/:81`; source `game.gd:8828` | Append "(**SUPERSEDED** — team-win is donor-verbatim `CheckEndGame`; see `DEC_U_scenario_win.md §5/§7`; source label at `game.gd:8828` reads 'DONOR team-win law (NOT port policy)'; no parity)". |
| 8W2 | `PORT1TO1_acceptance_plan.md:275`, `DEC_U_final_register.md:30` | non-blocking tail lists include "team-win policy" | C-3 `PORT1TO1_evidence_index.md:375`; `DEC_U_scenario_win.md:162`; `DEC_U_policy_audit.md:310/340` | Append "(superseded — donor-verbatim team law landed; only mission mapping/stamp residuals stay `[U]`)". Tail status itself is unchanged. |
| 8W3 | `PORT1TO1_evidence_index.md:224` | index row "score/team-win stay port policy" | C-3 register at `PORT1TO1_evidence_index.md:375`; plan `:64/:81` | Append "(superseded — see C-3; score absence remains correct, team-win is donor-verbatim)". Index presence is existence only. |

Guarded, no action: `DEC_U_policy_audit.md:310/340` explicitly says "team-win (law landed; comment stale)"; `game.gd:8828/9034` already carries the donor-law label and the old single-winner pick as retired.

**Every C7 gap above is label-only.** None changes a value, gate, assertion, threshold, `[U]` status, P0 status, preserve-only file or source byte. None is a donor-parity claim, and none was remediated by this audit.

## 4. Confirmation — the latest edits introduced no new claim

- **LABEL-HARDEN source qualifiers:** `terrain_donor_gen.gd:116` now reads `SCOPE: donor-settled facts ONLY [STATIC [D] ONLY — NO DONOR PARITY; live values [U]] …`; `terrain_donor_mesh.gd:1942` reads `donor-settled STATIC facts, labelled data only [STATIC [D] ONLY — NO DONOR PARITY; live values [U]]`. Both are comment-only bracketed negations plus a `[U]` reminder; all surrounding guards (`:109/:117-126` and `:1943-1948`, "no constant invented", "value-level byte dump stays `[U]` U-10b", "TELEMETRY ONLY") are intact. No code, value, behaviour or assertion changed. Verified independently of recheck7 §4.
- **Heading fixes:** `PORT1TO1_owner_brief2.md:37` "donor STATIC recoveries ([O]/[D]) … (no behavioural parity)"; `PORT1TO1_u_register2.md:21/23` "STATIC-CLOSED `[D]`" with surviving `[U]`; `:103` "STATIC CLAIM REFUTED `[O]` … no donor visual parity"; `PORT1TO1_PLAN.md:268` "8 static donor recoveries ([O]/[D])". Each substitutes a narrower qualifier or adds a negation; no `[U]` closed, no P0 changed.
- **COORD HANDOFF qualifications:** `HANDOFF.md:430` adds only the parenthetical "camera focus later superseded — donor start-derived wire found at `doprogress.inc:41`, implemented 2D+3D; height/zoom derivation still `[U]`". `HANDOFF.md:454-460` replaces the 186-task snapshot with a point-in-time qualifier, narrows the preserve-baseline statement to one recorded baseline, changes "all misread-risk labels tightened" to "most … with residual gaps logged in `claim_recheck6.md`/`claim_recheck7.md` (later fixed where source-side)", and records the `cap_fullport8`/`cap_fullport9` raw-pixel SHA difference as EXPECTED with only opt-in `--deterministic-capture --capture-ticks N` as the byte-identical path. All are narrowing/qualifying text; no parity claim, gate PASS or approximation was added.
- **Recheck7 landing:** `PORT1TO1_claim_recheck7.md:7-13` carries UNVERIFIED/NONE/false and literal `RESULT IS NOT GOOD`; `PORT1TO1_PLAN.md:273` records it DONE. It introduced no new claim (its own §4 verifies each fix).
- **Plan rows 262–266** (`PORT1TO1_PLAN.md:273-277`) are status rows; no parity state attaches to a row number.
- **Live source:** the independent C1 scan returned "No matches found". `game.gd:8278-8287/8568-8573/8685-8690/8822-8825` encodes the donor capture cadence/no-cooldown law; `game.gd:8828` encodes the donor team-win law. No stale ABSENT/EXACT assertion was added to source by the latest edits.

No new parity string, no new unguarded `RESULT IS GOOD`, no new promoted gate/metric and no new stale ABSENT/EXACT claim was introduced by the latest edits.

## 5. Dominance confirmation and verdict

- `parity.status = UNVERIFIED`, `parity.claim = NONE`, `parity.claim_code = NONE`, `visual_parity_claim = false` dominate across the rechecked set, including `HANDOFF.md:7-12`, `PORT1TO1_PLAN.md:310`, `PORT1TO1_claim_recheck7.md:7-13` and the final reports checked there.
- **Six-condition chain 0/6 CLOSED** — conditions 2 and 6 PARTIAL (port-internal only), conditions 1/3/4/5 BLOCKED (`PORT1TO1_chain_update2.md:15/51/71/120/140`; `PORT1TO1_owner_brief2.md:15/71`; `PORT1TO1_counts_sync.md:16/41/99`). No donor GPU A/B frame exists; no matched camera; no COORD ruling. The C7 gaps above narrow no condition and close no P0 row.
- **9 P0 rows OPEN**, **71 open `[U]`** (A42/B14/C5/D10), tickets **575/582/585** owner-only unacked (`PORT1TO1_u_register2.md:62/134-150`; `PORT1TO1_counts_sync.md:39-40/54/60`; `PORT1TO1_owner_brief2.md:50-64`). Because `blocking_unverified` is non-empty, **`RESULT IS NOT GOOD`** — unconditionally.
- **No approximation adopted, no parity claim, no test/gate weakened, no code/Godot/git/donor execution.** All 13 C7 gaps are label-only and none was applied by this audit. Exactly one repository file was written: this report.

*End of CLAIM-RECHECK8. PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass. `RESULT IS NOT GOOD`; chain 0/6; no approximations; no parity claim.*
