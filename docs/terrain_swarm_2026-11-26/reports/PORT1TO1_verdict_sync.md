---
id: PORT1TO1-VERDICT-SYNC-2026-11-27
title: "VERDICT-SYNC — inventory of every current verdict-bearing artifact, exact verdict strings, additive-vs-substantive classification, and one canonical minimal verdict line"
worker: VERDICT-SYNC (read-only subagent; full 1:1 Cossacks 3 donor port)
date: 2026-11-27
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION__NO_PARITY_CLAIM__NO_APPROXIMATION
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_verdict_sync.md
files_created: [docs/terrain_swarm_2026-11-26/reports/PORT1TO1_verdict_sync.md]
files_edited: []
scope_guard: "Repo file/line reads plus read-only SHA-256 string hashing over text already on disk. No source, shader, config, asset, test, fixture, result JSON, backup, queue, git, Godot, runner, gate, capture, ROI metric or donor change; no donor binary executed or opened; no donor GPU A/B frame produced or compared. Every donor fact below is carried [O]/[D] from cited landed reports. No status, count, value, gate or preserve-only hash was changed; all remediation pointers are LABEL-ONLY text fixes, none applied."
parity_status: UNVERIFIED
parity_claim: NONE
visual_parity_claim: false
verdict: "RESULT IS NOT GOOD — blocking_unverified is non-empty; parity.status=UNVERIFIED; parity.claim=NONE; no donor GPU A/B frame exists and none may be produced under the read-only rule; static [D] facts only narrow experiments; deterministic repeats are port-internal; no gate or ROI metric promotes parity; no approximations; no parity claim."
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
---

> **Mandatory reviewer line, verbatim:** PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

# PORT1TO1 — VERDICT-SYNC (one canonical final verdict; current tree, 2026-11-27)

This is a READ-ONLY inventory and reconciliation of the verdict declarations, following `PORT1TO1_handoff_check2.md` §5, which found the mandatory reviewer line byte-identical everywhere but the fenced verdict blocks divergent. It changes no earlier section, closes no `[U]`, promotes no value and asserts no parity. Every pointer below is an exact `file:line` read; every remediation is **LABEL-ONLY** and **none was applied**.

## 0. Basis, snapshot and method

- **Governing inputs read:** `HANDOFF.md:9/12/411-460`; `PORT1TO1_PLAN.md:197/265/291`; `PORT1TO1_acceptance_plan.md:33/269/355-370`; `PORT1TO1_handoff_check2.md:14-16/71-89`; `PORT1TO1_claim_recheck6.md:12/52-58/129-133`; `PORT1TO1_claim_recheck7.md:12-13/47-71/111-117`; `PORT1TO1_chain_update2.md:15/71/116-120/140`; every artifact named in §2–§4 below.
- **Snapshot caveat:** the tree is being concurrently mutated. Newest reads observed during this work: `PORT1TO1_claim_recheck7.md` (frontmatter verdict at `:12`) and `PORT1TO1_plan_sync2.md` (verdict at `:15`, snapshot bound to plan SHA-256 `FB66247B…85347`, mtime `2026-11-27T06:27:08.4661472+01:00`) both landed **after** `handoff_check2` was written. `claim_recheck7.md:39` recorded `PLAN-SYNC2` as not landed at its scan; it is present at this read. All line numbers and hashes below are point-in-time reads; **no claim is made about any later state**.
- **Method:** `Get-Content`/`Select-String` reads and `SHA-256` over exact extracted strings only. Block identity in §2 is by hash of the exact line range including the closing fence. "Exact verdict string" means the literal text as written, not a paraphrase.

## 1. The two invariants

### 1.1 Mandatory reviewer line — byte-identical (unchanged)

Exact string (SHA-256 `30FEC6929276B30830D397D525EA1AC43D11AF773B0CA263F0F04A16EA3928E7`):

```
PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.
```

Declared mandatory/verbatim at `HANDOFF.md:12,192,257,272,295,321`; `handoff_sync.md:15,25`; `owner_brief2.md:33,86-87`; `claim_recheck2.md:12,19`, `recheck3.md:12,19`, `recheck4.md:12,19`, `recheck5.md:12,19`, `recheck6.md:13,20`, `recheck7.md:13,20`; `chain_update2.md:44`; `hash_manifest.md:22,28`; `final_gates.md:15,38`; and carried unchanged in the fenced blocks of §2. This worker re-verified literal presence of the exact string in 8 divergent artifacts (all `True`); the exhaustive declaration list is `handoff_check2.md:73`. `HANDOFF.md:9` `parity_guard` is a different frontmatter field and is not the reviewer line.

### 1.2 Verdict core — semantically identical (unchanged)

Every governing artifact terminates as **`RESULT IS NOT GOOD` while `blocking_unverified` is non-empty** (`HANDOFF.md:411/422/433/446/460`; `PORT1TO1_PLAN.md:159/163/197`; `owner_brief2.md:15/89/99`; `handoff_sync.md:14/58`; `claim_recheck6.md:12`). No unguarded `RESULT IS GOOD` exists: `claim_recheck7.md:48` records C2 NONE unguarded (62 report hits, all conditional templates, forbidden-phrasing inventories, quotations or negations; `variant3d/` returned "No matches found"), corroborating `claim_final.md:40` and `claim_recheck6.md:55`. The divergence is therefore **in presentation only**, not in verdict state.

## 2. Inventory A — fenced governing verdict blocks (10 artifacts)

These are the "fenced verdict blocks" of the owner's concern. Exact strings (fence included) and SHA-256 of each extracted range:

| ID | Artifact : lines | SHA-256 (extracted range) | Exact variant | Class |
|---|---|---|---|---|
| F1 | `PORT1TO1_acceptance_plan.md:357-366` | `948AE5AA…AD69E` | Authority/template; `<one blocking item, e.g. water U12/U4*, FOW grid a-e, tick interleave, animation blend, save container, RNG G1, or absent donor A/B>`; `blocking_unverified = <non-empty list from §6>` | parameterized |
| F2 | `PORT1TO1_owner_brief.md:80-92` | `285AA7AF…C364` | Concrete full form; blocker enumeration; **no** `; no COORD ruling` | canonical concrete family |
| F3 | `PORT1TO1_decision_sim.md:128-140` | `285AA7AF…C364` | **byte-identical to F2** | canonical concrete family |
| F4 | `PORT1TO1_owner_brief2.md:85-97` | `285AA7AF…C364` | **byte-identical to F2** | canonical concrete family |
| F5 | `PORT1TO1_internal_validation.md:139-152` | `9F4ED1BC…F07B` | F2 **plus** extra line `no COORD ruling).` at `:145` | additive qualifier |
| F6 | `PORT1TO1_handoff_checklist.md:278-291` | `9F4ED1BC…F07B` | **byte-identical to F5** (`no COORD ruling).` at `:284`) | additive qualifier |
| F7 | `PORT1TO1_final_gates.md:138-145` | `0ECA44D7…46AC` | Short form: reviewer line + `parity.status=UNVERIFIED` + `parity.claim=NONE` + `RESULT IS NOT GOOD while blocking_unverified non-empty`; no enumeration | compression (guards retained) |
| F8 | `PORT1TO1_acceptance_runbook.md:332-343` | `17164189…C5880` | Parameterized; `<one blocking item, e.g. no donor A/B frame (PT-V1 controlling), …, or absent COORD ruling>` + `<non-empty list: PT-V1…PT-V8, P0-1…P0-8, …>` | parameterized |
| F9 | `PORT1TO1_roi_metrics.md:168-183` | `E5F04A5A…614E5` | Scope restatement: `RESULT IS NOT GOOD — donor/port cameras are not A/B-matched (PT-V1 controlling) and the blocking [U] set is non-empty (…)` + named `blocking_unverified` list | additive scope restatement |
| F10 | `PORT1TO1_owner_brief_addendum.md:67-79` | `285AA7AF…C364` | **byte-identical to F2** ("repeated from owner brief §5, unchanged") | canonical concrete family |

Exact canonical concrete block (F2 = F3 = F4 = F10), verbatim:

```
PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B
frame exists; this review certifies neither donor fidelity nor a gate pass.

RESULT IS NOT GOOD — blocking_unverified is non-empty (no donor A/B frame; water U12/U4*;
FOW grid; tick interleave; animation blend; save container; RNG G1; selection/projection).
parity.claim = NONE
parity.status = UNVERIFIED
blocking_unverified = [PT-V1, PT-V2, PT-V3, PT-V4, PT-V5, PT-V6, PT-V7,
                       P0-1, P0-1b, P0-2, P0-3, P0-4, P0-5, P0-6, P0-7, P0-8,
                       W-R1, T-SEED, T-CALLBACK, atlas-layout, X17, U-INJ-1..11,
                       plus the domain residuals]
```

Exact F5/F6 delta (only difference from F2): the blocker line breaks after `selection/projection;` and adds a tenth line `no COORD ruling).` (`internal_validation.md:143-145`; `handoff_checklist.md:282-284`). Hash math: F5/F6 length 700 vs F2 683 (+17 chars). No other byte differs.

Exact F7 block, verbatim (`final_gates.md:138-145`):

```
PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B
frame exists; this review certifies neither donor fidelity nor a gate pass.

parity.status=UNVERIFIED
parity.claim=NONE
RESULT IS NOT GOOD while blocking_unverified non-empty
```

The same short form appears inline at `final_gates.md:48-49`. Note the `RESULT IS NOT GOOD` line there carries no `blocking_unverified` enumeration and no `no donor A/B` clause; that guard is carried by the immediately preceding reviewer line of the same fenced unit. It is a compression, **not** a dropped guard when the two-line unit is read together.

Exact F8/F1 parameterization slots, verbatim: F1 `acceptance_plan.md:361-365`; F8 `acceptance_runbook.md:336-342`. Both are templates ("choose exactly one"), never asserted as a live verdict. F8 is the only fenced block that names `absent COORD ruling` inside the `<one blocking item>` slot.

**False "verbatim" labels (label-only defect, carried from `handoff_check2.md:79`):** `handoff_checklist.md:276` claims F6 is "Verbatim from `owner_brief.md:80-92`, `internal_validation.md:139-152`, `final_gates.md:138-145`, `acceptance_runbook.md:332-343`" — it is verbatim only from `internal_validation.md`; F2, F7 and F8 differ. `internal_validation.md:137` claims F5 is "Verbatim from `owner_brief.md:80-92`, `acceptance_runbook.md:332-343`, `roi_metrics.md:168-183`" — it is verbatim from none of the three (each lacks or phrases the `no COORD ruling` clause differently). **[Historical defect record — both labels CORRECTED by COORD 2026-11-27; no block text changed; confirmed by `claim_recheck10.md`/`claim_recheck11.md`.]**

### 2.1 Single-line exact verdict declarations (2)

`PORT1TO1_chain_update2.md:120` and `:140` are the same single line verbatim (inline code at `:120`, plain at `:140`) and carry the **complete guard set** in one line:

```
parity.claim = NONE; parity.status = "UNVERIFIED"; visual_parity_claim = false; six-condition chain 0/6 CLOSED — condition 1 BLOCKED, 2 PARTIAL (port-internal only), 3 BLOCKED, 4 BLOCKED, 5 BLOCKED, 6 PARTIAL (internal repeatability only); RESULT IS NOT GOOD — blocking_unverified is non-empty; no donor GPU A/B frame, no matched camera, no COORD ruling; static [D] facts narrow experiments only; deterministic repeats are port-internal; no gate or ROI metric promotes parity; no approximation, no parity claim.
```

This is the maximal form from which the canonical minimal line of §6 is derived by deleting only point-in-time enumerations and scope detail. It is a landed artifact; the canonical line introduces no new fact.

## 3. Inventory B — frontmatter `verdict:` strings

Read of all `reports/*.md`: **78** frontmatter `verdict:` lines; **58** contain the literal `RESULT IS NOT GOOD`; **20** are scope-local verdict strings without it. All are guarded. Exact strings grouped by identity:

**B1 — bare / minimal:**
- `PORT1TO1_owner_brief.md:14` = `PORT1TO1_owner_decisions.md:14`: `RESULT IS NOT GOOD — blocking_unverified is non-empty`
- `V109_owner_answer_final.md:13`: `RESULT IS NOT GOOD`

**B2 — chain only:**
- `PORT1TO1_internal_validation.md:14`: `RESULT IS NOT GOOD — blocking_unverified is non-empty; six-condition chain 0/6 CLOSED`
- `PORT1TO1_acceptance_runbook.md:12` = `PORT1TO1_artifact_layout.md:13` = `PORT1TO1_final_guard_audit.md:11`: `RESULT IS NOT GOOD — blocking_unverified is non-empty; six-condition parity chain 0/6 closed`
- `PORT1TO1_parity_chain.md:13`: `...; no condition of the six-condition chain is closed`
- `PORT1TO1_parity_recheck.md:14`: `...; no condition of the six-condition chain is CLOSED`

**B3 — chain + no A/B (+ no COORD):**
- `PORT1TO1_decision_sim.md:15`: `RESULT IS NOT GOOD — blocking_unverified is non-empty; six-condition chain 0/6 CLOSED; no donor GPU A/B frame; no approximations; no parity claim.`
- `PORT1TO1_claim_final.md:10`: `...; six-condition chain 0/6 CLOSED; no donor GPU A/B frame; no COORD ruling`
- `PORT1TO1_tree_recheck.md:10`: `...; six-condition parity chain 0/6 CLOSED; no donor GPU A/B frame; no COORD ruling`
- `PORT1TO1_claim_recheck2.md:11` = `recheck3.md:11` = `recheck4.md:11` = `recheck5.md:11` = `PORT1TO1_handoff_checklist.md:30`: `RESULT IS NOT GOOD — blocking_unverified is non-empty; six-condition chain 0/6 CLOSED; no donor GPU A/B frame; no COORD ruling; no approximations; no parity claim.`
- `PORT1TO1_index_final3.md:22`: `...; six-condition chain 0/6 CLOSED (condition 6 PARTIAL, port-internal only); no donor GPU A/B frame; no COORD ruling; no approximations; no parity claim.`
- `PORT1TO1_handoff_check2.md:14`: `...; six-condition chain 0/6 CLOSED; nine P0 rows OPEN; no donor GPU A/B frame; no COORD ruling; no approximations; no parity claim.`
- `PORT1TO1_plan_sync2.md:15`: `...; six-condition chain 0/6 CLOSED; nine P0 rows OPEN; no donor GPU A/B frame; no COORD ruling; internal plan consistency only; no approximations; no parity claim.`

**B4 — chain + no A/B + static-[D] guard:**
- `PORT1TO1_claim_recheck6.md:12`: `RESULT IS NOT GOOD — blocking_unverified is non-empty; six-condition chain 0/6 CLOSED; no donor GPU A/B frame; no COORD ruling; static [D] facts narrow experiments only; no approximations; no parity claim.`
- `PORT1TO1_chain_update2.md:15`: `RESULT IS NOT GOOD — blocking_unverified is non-empty; six-condition chain 0/6 CLOSED; no donor GPU A/B frame; no matched camera; no COORD ruling; static [D] facts narrow experiments only; no approximation, no parity claim`
- `PORT1TO1_claim_recheck7.md:12`: `RESULT IS NOT GOOD — blocking_unverified is non-empty; six-condition chain 0/6 CLOSED; nine P0 rows OPEN; 71 open [U] (A42/B14/C5/D10); no donor GPU A/B frame; no matched camera; no COORD ruling; static [D] facts narrow experiments only; no approximations; no parity claim.`
- `PORT1TO1_counts_sync.md:16`: `RESULT IS NOT GOOD — blocking_unverified is non-empty; governing final counts are 71 open [U] (A42/B14/C5/D10), 9 P0 rows OPEN, six-condition chain 0/6 CLOSED; parity UNVERIFIED; no donor GPU A/B frame; no approximation, no parity claim`

**B5 — chain + no A/B + no approximation/no parity (no COORD clause):**
- `PORT1TO1_bundle_index.md:16`: `RESULT IS NOT GOOD — blocking_unverified is non-empty; six-condition chain 0/6 CLOSED; no donor GPU A/B frame; no approximations; no parity claim.`
- `PORT1TO1_u_classify.md:12`: `...; P0-1..P0-8 remain open; six-condition chain 0/6 CLOSED; no donor GPU A/B frame; no approximations; no parity claim`
- `PORT1TO1_b_angle_index.md:12`: same as `u_classify.md:12` with `class-B static results never close class-A value/behaviour items` appended.
- `PORT1TO1_u_register_update.md:14`: `...; P0-1/P0-1b/P0-2/P0-3/P0-4/P0-5/P0-6/P0-7/P0-8 remain open; six-condition chain 0/6 CLOSED; no donor GPU A/B frame; no approximations; no parity claim`
- `PORT1TO1_u_register2.md:13`: `...; all nine P0 rows OPEN; six-condition chain 0/6 CLOSED; class-B static closures and [D] derivations never close class-A value/behaviour items; no donor GPU A/B frame; no approximations; no parity claim`
- `PORT1TO1_p0_packet_index.md:18`: `... (P0-1…P0-8); six-condition chain 0/6 CLOSED; no donor GPU A/B frame; no approximations; no parity claim.`
- `PORT1TO1_p0_consistency.md:15`: `RESULT IS NOT GOOD — blocking_unverified non-empty (P0-1…P0-8 plus register tails); six-condition chain 0/6 CLOSED; no donor GPU A/B frame; no approximations; no parity claim.`
- `PORT1TO1_owner_decisions_update.md:18`: `... (all 9 P0 rows plus the §2 tails of PORT1TO1_u_register_update.md); six-condition chain 0/6 CLOSED; no donor GPU A/B frame; no approximations; no parity claim.`
- `PORT1TO1_handoff_sync.md:14`: `RESULT IS NOT GOOD — blocking_unverified non-empty; six-condition chain 0/6 CLOSED; nine P0 rows OPEN; no donor GPU A/B frame.`
- `PORT1TO1_hash_manifest.md:21`: `...; six-condition parity chain 0/6 closed; no donor GPU A/B frame; hashes certify artifact identity only; no parity claim.`
- `PORT1TO1_b_angle_final.md:12`: `...; P0-1..P0-8 remain open; six-condition chain 0/6 CLOSED; class-B static results never close class-A value/behaviour items; NB-4 is the only new numeric derivation [D] and NB-2's field-default table is a parser binding [D], neither is a parity or behaviour closure; no donor GPU A/B frame; no approximations; no parity claim`
- `PORT1TO1_d_cosmetic.md:12`: `...; P0-1…P0-8 remain open; six-condition chain 0/6 CLOSED; no donor GPU A/B frame; ten class-D items remain [U] and are NOT CLOSED; no approximations; no parity claim`
- `PORT1TO1_c_decisions.md:12`: `... (P0-1…P0-8 plus the §2 tails); six-condition chain 0/6 CLOSED; no donor GPU A/B frame; no approximations; no parity claim`
- `PORT1TO1_d4_reclass.md:12`: `...; D4 remains [U] and is NOT CLOSED; no approximations; no parity claim; no donor execution or A/B frame`
- `PORT1TO1_p0_dryrun.md:21`: `RESULT IS NOT GOOD — nine P0 rows remain open; six-condition chain 0/6 CLOSED; no donor GPU A/B frame; no port-internal check closes any P0; no approximations; no parity claim.`
- `PORT1TO1_p0_final_status.md:18`: `... (all nine P0 rows plus the domain tails); six-condition chain 0/6 CLOSED; no donor GPU A/B frame; no value promoted by any deep pass; no approximation; no parity claim.`
- `PORT1TO1_p0_sync2.md:18`: `RESULT IS NOT GOOD - all nine P0 rows stay OPEN, zero CLOSED; the five new [D] facts narrow experiments only and promote no value; blocking_unverified non-empty; no donor GPU A/B frame`
- `PORT1TO1_plan_sync.md:16`: `RESULT IS NOT GOOD - blocking_unverified is non-empty`
- `PORT1TO1_final_gates.md:14`: `RESULT IS NOT GOOD — blocking_unverified is non-empty; no gate, metric or internal PASS constitutes donor parity`
- `PORT1TO1_gate_audit.md:14`: `RESULT IS NOT GOOD — blocking_unverified is non-empty; no gate or ROI metric promotes parity`
- `PORT1TO1_owner_brief_addendum.md:14`: `RESULT IS NOT GOOD — blocking_unverified is non-empty; no P0 closed`
- `PORT1TO1_fow_owner_protocol.md:17`: `RESULT IS NOT GOOD — blocking_unverified non-empty; P0-3 (F-GRID a-e + persistence + tint) stays open; six-condition parity chain 0/6 CLOSED; no donor GPU A/B frame; no cell size, occlusion slope or colour invented; no parity claim.`
- `PORT1TO1_save_owner_protocol.md:17`: `RESULT IS NOT GOOD — P0-6 remains open; paired-save parity UNVERIFIED; no donor save produced or compared by this worker; no byte/default invented; v5 wire unchanged.`
- `PORT1TO1_selection_owner_protocol.md:13`: `RESULT IS NOT GOOD — P0-8 remains open; this packet authorises owner-only runs, closes nothing by itself`
- `PORT1TO1_p0_session_plan.md:17`: `RESULT IS NOT GOOD — zero P0 settled by the existing terrain Route A capture; all nine P0 rows open; four GPU donor sessions + one paired-save donor session + one native-state-dump/harness session + one harness-only session are SPECIFIED, not performed; six-condition chain 0/6 CLOSED; no accepted approximation, no parity claim.`
- `PORT1TO1_session_risks.md:17`: `RESULT IS NOT GOOD — zero P0 settled; all nine P0 rows open; seven owner sessions SPECIFIED, not performed; six-condition chain 0/6 CLOSED; any failure mode below keeps its item [U] and its P0 row open; no threshold relaxed, no value invented, no port result substituted for donor evidence; no approximation; no parity claim.`

**B6 — scope-local `RESULT IS NOT GOOD` (phrase used for a narrow static question, not the overall port verdict):**
`DEC_U12_caller_walk.md:17`; `DEC_U_b6_g0.md:13`; `DEC_U_nb1.md:17`; `DEC_U_nb2.md:17`; `DEC_U_tver_deep.md:13`; `DEC_U_ureg_ctor.md:18`. Exact strings at those lines, e.g. `DEC_U_nb1.md:17`: `RESULT IS NOT GOOD for NB-6 static angle alone — no byte-proven TOSW* ctor->C+0x4c / texture-+8 / C+0xe0 store recovered across the FULL binary; U12 provenance stays [U]; hard-fail (no water) endorsed; no approximation.` These narrow a static question and keep every value `[U]`; they do not change or replace the governing verdict.

**B7 — 20 scope-local verdict strings without the phrase** (out of the governing-verdict set; each is guarded): `A04_landscape_props.md:35`, `DEC_U_save_trg_deep.md:96`, `F01_pattern_format.md:21`, `F02_pattern_lib.md:10`, `PORT1TO1_ack_evidence.md:14`, `PORT1TO1_rng_owner_protocol.md:18`, `V108_final_go.md:15`, `V111_asset_final.md:16`, `V89_final_asset_seal.md:16`, `VERIFY_HEIGHT_fix.md:15`, `X05_pattern_lib_validation.md:10`, `X13_blend_test_vectors.md:9`, `X23_corrected_relief_grids.md:27`, `X26_blend_formula_verification.md:10`, `X34_size_law_verification.md:11`, `X37_golden_blend_vectors.md:10`, `X49_i02_grid_audit.md:23`, `X55_postpatterns_decode.md:14`, `X67_envscales_decode.md:12`, `X70_envscales_i09.md:10`. Representative exact strings: `V111_asset_final.md:16` `GO for asset-pack readiness (conditional) — see §7. NOT a gate PASS, NOT donor parity. Overall port/gate/parity readiness remains NO-GO / UNVERIFIED.`; `F02_pattern_lib.md:10` `TEXT_DATABASE_NOT_BINARY_CONTAINER__680_SECTIONS__KNOWN_OFFSETS_ARE_1_BASED_LINE_NUMBERS__12_GRID_CROSS_CHECKS_BIT_EXACT__NO_PARITY_CLAIM`. None asserts donor parity or closes a P0.

## 4. Inventory C — blockquote "Verdict (verbatim governing form)" declarations (20 lines)

Exact common template (e.g. `PORT1TO1_u_register_update.md:206`):

```
port=UNVERIFIED; parity.claim = NONE; parity.status = "UNVERIFIED"; visual_parity_claim = false; blocking_unverified non-empty (P0-1, P0-1b, P0-2, P0-3, P0-4, P0-5, P0-6, P0-7, P0-8 plus the §2 tails); six-condition chain 0/6 CLOSED. RESULT IS NOT GOOD. No same-camera donor/port A/B frame exists; no approximation is authorised; no parity claim is made.
```

Sites (exact `file:line`): `b_angle_final.md:159`, `b_angle_index.md:118`, `c_decisions.md:132`, `counts_sync.md:118`, `d4_reclass.md:174`, `d_cosmetic.md:162`, `owner_decisions_update.md:130`, `p0_consistency.md:111`, `p0_final_status.md:94`, `p0_sync2.md:93`, `selection_owner_protocol.md:198`, `u_classify.md:230`, `u_register2.md:190`, `u_register_update.md:206`, plus the static-probe `DEC_U_b45_residual.md:100`, `DEC_U_b6_g0.md:190`, `DEC_U_b10_skirmish_tables.md:204`, `DEC_U_tver_deep.md:254`, and the short `artifact_layout.md:35`. All are blockquotes with inline code, **not** the fenced blocks of §2; they are separately labelled "verbatim governing form" and differ among themselves only by the additive tails listed in §5.

## 5. Classification — additive qualifier vs substantive claim

**Definition used.** *Additive qualifier* = a clause, enumeration or count that narrows or restates an already-guarded condition and cannot make the verdict more favourable. *Substantive claim* = a clause that changes the truth conditions of the verdict or asserts a new capability/state (unqualified `RESULT IS GOOD`, parity achieved, gate PASS, P0 closed, COORD ruling exists, A/B frame exists, value promoted, approximation adopted, test weakened).

**Result: every difference found is additive. No substantive claim exists in any current verdict-bearing artifact.**

| Distinct difference (exact phrase) | Exact sites | Classification |
|---|---|---|
| `no COORD ruling` / `; no COORD ruling).` / `absent COORD ruling` | F5 `:145`, F6 `:284`; frontmatter `claim_final.md:10`, `recheck2-5:11`, `recheck6:12`, `recheck7:12`, `chain_update2:15`, `index_final3:22`, `handoff_check2:14`, `plan_sync2:15`, `tree_recheck:10`; F8 `:338`; F11 `:120/:140` | **Additive** — names an already-open blocker (condition 6); cannot close it |
| `no matched camera` | `chain_update2.md:15/120/140`, `claim_recheck7.md:12` | **Additive** |
| `static [D] facts narrow experiments only` / `the five new [D] facts narrow experiments only and promote no value` | `claim_recheck6.md:12`, `claim_recheck7.md:12`, `chain_update2.md:15/120/140`, `p0_sync2.md:18` | **Additive guard** — required in canonical |
| `deterministic repeats are port-internal` | `chain_update2.md:120/140` | **Additive guard** — required in canonical |
| `no gate or ROI metric promotes parity` / `no gate, metric or internal PASS constitutes donor parity` | `gate_audit.md:14`, `final_gates.md:14`, `chain_update2.md:120/140` | **Additive guard** — required in canonical |
| `class-B static results never close class-A value/behaviour items` | `b_angle_final.md:12/159`, `b_angle_index.md:12/118`, `u_register2.md:13/190` | **Additive** |
| `no value promoted by any deep pass` / `no value was promoted by these [D] facts` | `p0_final_status.md:18/94`, `p0_sync2.md:93` | **Additive** |
| `hashes certify artifact identity only` | `hash_manifest.md:21` | **Additive** |
| `internal plan consistency only` | `plan_sync2.md:15` | **Additive** |
| `71 open [U] (A42/B14/C5/D10)` / `nine P0 rows OPEN` / `9 P0 rows OPEN` | `counts_sync.md:16/118`, `claim_recheck7.md:12`, `handoff_check2.md:14`, `plan_sync2.md:15` | **Additive** — point-in-time counts, no state change |
| `ten class-D items remain [U] and are NOT CLOSED` / `D4 remains [U] and is NOT CLOSED` | `d_cosmetic.md:12`, `d4_reclass.md:12` | **Additive** |
| `no cell size, occlusion slope or colour invented` / `no byte/default invented; v5 wire unchanged` | `fow_owner_protocol.md:17`, `save_owner_protocol.md:17` | **Additive** |
| `no port-internal check closes any P0` / `sessions SPECIFIED, not performed` | `p0_dryrun.md:21`, `p0_session_plan.md:17`, `session_risks.md:17` | **Additive** |
| blocker enumeration `(no donor A/B frame; water U12/U4*; FOW grid; tick interleave; animation blend; save container; RNG G1; selection/projection)` | F2/F3/F4/F5/F6/F10 verdict lines | **Additive** — names blockers, preserves non-emptiness |
| `<one blocking item>` / `<non-empty list …>` template slots | F1 `:361/:365`, F8 `:336/:341-342` | **Additive abstraction** — presentation risk only; admissible slot is always non-empty |
| short form with enumeration omitted | F7 `:142-144`, `final_gates.md:49` | **Compression** — all 7 guards remain in the reviewer-line + verdict-line unit |
| ROI-scope restatement `donor/port cameras are not A/B-matched (PT-V1 controlling)` | F9 `:172-174` | **Additive scope restatement** |

Substantive-claim search result: **NONE**. Evidence: `claim_recheck7.md:47-52` C1–C5 all NONE unguarded; `claim_recheck7.md:54`, `:71`; `claim_final.md:66-82`; `claim_recheck6.md:52-58`; `final_guard_audit.md:167`; `DEC_U_port_guard_audit.md:77/80/160`. No `[D]` was promoted to behaviour (`claim_recheck7.md:94-103`), no gate/metric promoted to parity (`claim_recheck7.md:51`), no donor A/B frame exists or was produced (`claim_recheck7.md:114`).

## 6. The canonical minimal verdict line

Derived by deleting only point-in-time enumerations and scope detail from the already-landed maximal line `chain_update2.md:120` = `:140`; the phrase "under the read-only rule" is carried unchanged from `artifact_layout.md:35` and `handoff_check2.md:10`. **No new fact, no promotion, no parity claim.**

**Canonical reviewer line (unchanged, mandatory, byte-identical — §1.1):**

```
PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.
```

**Canonical minimal verdict line (single line; the one unambiguous final verdict):**

```
RESULT IS NOT GOOD — blocking_unverified is non-empty; parity.status=UNVERIFIED; parity.claim=NONE; no donor GPU A/B frame exists and none may be produced under the read-only rule; static [D] facts only narrow experiments; deterministic repeats are port-internal; no gate or ROI metric promotes parity; no approximations; no parity claim.
```

Guard coverage (exact mapping; no approximation):

| Required guard | Token in canonical line |
|---|---|
| `parity.status=UNVERIFIED` | `parity.status=UNVERIFIED` |
| `parity.claim=NONE` | `parity.claim=NONE` |
| `RESULT IS NOT GOOD while blocking_unverified non-empty` | `RESULT IS NOT GOOD — blocking_unverified is non-empty` |
| no donor A/B under read-only rule | `no donor GPU A/B frame exists and none may be produced under the read-only rule` |
| static `[D]` only narrows experiments | `static [D] facts only narrow experiments` |
| deterministic repeats port-internal | `deterministic repeats are port-internal` |
| no gate/metric promotes parity | `no gate or ROI metric promotes parity` |
| (carried prohibition) no approximations / no parity claim | `no approximations; no parity claim` |

`visual_parity_claim = false` is a widely carried **additive** guard (`chain_update2.md:120`, §4 template); it is omitted from the *minimal* line but may be appended without changing the verdict. The canonical line is a strict subset of `chain_update2.md:120` and is therefore already evidenced in the landed corpus.

## 7. LABEL-ONLY remediation pointers (proposed; none applied)

| # | Target (exact label site) | LABEL-ONLY pointer |
|---|---|---|
| R1 | `handoff_checklist.md:276` | Replace "Verbatim from `owner_brief.md:80-92`, `internal_validation.md:139-152`, `final_gates.md:138-145`, `acceptance_runbook.md:332-343`" with "Adapted from `owner_brief.md:80-92` (= `decision_sim.md:128-140` = `owner_brief2.md:85-97` = `owner_brief_addendum.md:67-79`); `internal_validation.md:139-152` = this block plus `; no COORD ruling`; `final_gates.md:138-145` short form; `acceptance_runbook.md:332-343` parameterized." No block text change. **[CORRECTED by COORD 2026-11-27 — label narrowed to "Verbatim only from `internal_validation.md:139-152`"; no block text change.]** |
| R2 | `internal_validation.md:137` | Same "Verbatim from" label is false for `acceptance_runbook.md` and `roi_metrics.md`; reword to "Adapted from …" per R1. No block text change. **[CORRECTED by COORD 2026-11-27 — label reworded to "Adapted from … NOT verbatim (see `PORT1TO1_verdict_sync.md` §5)"; no block text change.]** |
| R3 | F5 `internal_validation.md:139-152`, F6 `handoff_checklist.md:278-291` | `no COORD ruling).` is an **additive qualifier**, not a defect in content: optionally annotate "(additive qualifier; canonical line = §6)" rather than delete. If aligned, replace the blocker enumeration with the §6 line; no state change. |
| R4 | F7 `final_gates.md:138-145` and inline `:48-49` | Annotate "short form; full guard line = `chain_update2.md:120`" so the omitted enumeration is not read as a dropped guard. No text change required to keep verdict. |
| R5 | F1 `acceptance_plan.md:357-366`, F8 `acceptance_runbook.md:332-343` | Annotate "template — slot must be filled by a named blocking item; `blocking_unverified` never empty in the admissible form". No template change. |
| R6 | F9 `roi_metrics.md:168-183` | Annotate "ROI-scope restatement of the governing verdict, not a separate verdict". No text change. |
| R7 | F2/F3/F4/F10 (hash `285AA7AF…C364`) | Already the canonical concrete family; optionally annotate "canonical governing block; minimal line = §6". |
| R8 | F11 `chain_update2.md:120/140` | Declare as canonical maximal guard line from which §6 is derived; no text change. |
| R9 | Frontmatter `verdict:` families B1–B6 (58 lines) and §4 blockquote declarations (20 lines) | Annotate "functionally equivalent to canonical §6 line; differences are additive qualifiers only". No status, count, gate or value change. |
| R10 | Scope-local strings B6/B7 | Annotate "scope-local verdict, not the overall port verdict"; do **not** promote any to a governing verdict. |

Every R-item is a text-label proposal. **No file other than this report was written; none of these was applied.**

## 8. Final state (unchanged)

`parity.status = UNVERIFIED`; `parity.claim = NONE`; `visual_parity_claim = false`; six-condition chain **0/6 CLOSED** (conditions 2 and 6 PARTIAL, port-internal only; 1/3/4/5 BLOCKED); all nine P0 rows OPEN; 71 open `[U]` (A42/B14/C5/D10) per `counts_sync.md:16/118`; tickets 575/582/585 owner-only unacked; no donor GPU A/B frame exists or was invented under the read-only rule; no matched camera; no COORD ruling; HANDOFF §4 gate cells remain `TODO(COORD)`; unit-test gates are explicitly not acceptance. Because `blocking_unverified` is non-empty, **`RESULT IS NOT GOOD`** — unconditionally, in every form inventoried above. No approximation adopted, no parity claim, no gate-PASS claim.

---

*End of PORT1TO1-VERDICT-SYNC. Exactly one repository file written by this worker (`docs/terrain_swarm_2026-11-26/reports/PORT1TO1_verdict_sync.md`). No code, shader, config, asset, test, result JSON, backup, queue, git, Godot, runner, gate, capture, ROI metric or donor change; no donor binary executed; no donor A/B frame produced or compared. All remediations are proposed LABEL-ONLY text fixes; none was applied. Parity UNVERIFIED; `RESULT IS NOT GOOD` while `blocking_unverified` is non-empty.*
