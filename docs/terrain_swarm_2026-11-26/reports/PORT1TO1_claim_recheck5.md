---
id: PORT1TO1-CLAIM-RECHECK5-2026-11-27
title: "CLAIM-RECHECK5 — read-only post-B-angle/randkey/copy-map parity-claim string re-sweep: all current reports + current variant3d/"
agent: CLAIM-RECHECK5 (read-only subagent; no code/Godot/git/donor execution)
created: 2026-11-27
role: "Follow-up to PORT1TO1_claim_recheck4.md. Since that sweep the class-B index was finalised, B6/B9/B10 and NB-1..NB-7 reports landed, two more static angles (U-REG-TEX ctor, B4/B5 residual) landed, two implementation lanes (randkey-derivation telemetry, exact quad copy-map telemetry) landed and the plan was renumbered. Re-scan EVERY current reports/*.md plus current variant3d/ for forbidden parity strings; verify each new report's UNVERIFIED/no-parity marker and verdict line; confirm no implementation lane asserted donor parity; cite every misread-risk phrasing with LABEL-ONLY remediation."
parity: UNVERIFIED
parity_claim: NONE
parity_claim_code: NONE
visual_parity_claim: false
verdict: "RESULT IS NOT GOOD — blocking_unverified is non-empty; six-condition chain 0/6 CLOSED; no donor GPU A/B frame; no COORD ruling; no approximations; no parity claim."
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
output_files: "Exactly one repository file written: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_claim_recheck5.md"
methods: "Read-only glob/grep/read of the current working tree. No code edit, no Godot process, no runner subcommand, no gate, no capture, no donor execution, no git command, no result-JSON/test/backup/config mutation. All file:line numbers are current working-tree numbers. Every quoted forbidden literal below is quoted as a SCAN TARGET, a NEGATION, or a GUARDED OBSERVATION — never as a claim."
---

# CLAIM-RECHECK5 — post-B-angle/randkey/copy-map parity-claim string re-sweep (current tree, 2026-11-27)

> **PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.**

This is a read-only label/string audit. It does not execute the donor, Godot, a runner job, a gate or a capture; it does not run git; it does not close a `[U]`, wire a value, promote a metric or change any file other than this report. It supplements `PORT1TO1_claim_recheck4.md`, which PASSed source/report parity strings before the B-angle-final / NB / randkey / copy-map wave landed.

## 1. Scope — what counts as "new" here

Baseline cut = mtime of `PORT1TO1_claim_recheck4.md` (2026-11-27 05:54:43). **Twelve** report files are under audit as new; one landed during this audit and is included:

| # | New report | mtime | Angle |
|---|---|---|---|
| 1 | `DEC_U_b6_g0.md` | 06:03:39 | B6 T-G0 forest density |
| 2 | `DEC_U_nb1.md` | 06:03:49 | NB-6 (index NB-6 / brief "NB-1") `TOSW*` whole-binary ctor sweep |
| 3 | `DEC_U_b9_wpn_shield.md` | 06:04:11 | B9 E-WPN/SHIELD |
| 4 | `DEC_U_b10_skirmish_tables.md` | 06:04:49 | B10 S-SKIRM tables |
| 5 | `DEC_U_nb3.md` | 06:06:40 | NB-3 LOS quadtree call edge |
| 6 | `DEC_U_nb4.md` | 06:07:45 | NB-4 `GenerateMapRandKey` derivation body |
| 7 | `DEC_U_nb2.md` | 06:07:51 | NB-2 HF/MDEN/OBJ relief residual |
| 8 | `DEC_U_nb7.md` | 06:08:48 | NB-7 S0 kernel body |
| 9 | `DEC_U_nb5.md` | 06:09:52 | NB-5 `U-copy-site` native side |
| 10 | `PORT1TO1_b_angle_final.md` | 06:11:01 | definitive class-B outcome table |
| 11 | `DEC_U_ureg_ctor.md` | 06:11:43 | U-REG-TEX ctor sweep |
| 12 | `DEC_U_b45_residual.md` | 06:13:41 | B4/B5 residual angles (landed during this audit) |

**Plan renumbering:** `PORT1TO1_PLAN.md` (06:14:20) now carries rows 238–254; recheck4 is row 237 (`:248`), B6/B9/B10 are rows 238–240 (`:249-251`), NB-2…NB-7 rows 242–246 (`:253-257`), `IMPL-RANDKEY-DERIV` row 247 (`:258`), B-angle final row 248 (`:259`), U-REG-TEX row 249 (`:260`), `IMPL-QUAD-COPY` row 250 (`:261`), B4/B5 residual row 251 (`:262`), this recheck row 252 DOING (`:263`). No parity state attaches to any row number.

**Three implementation surfaces / artifacts:** `IMPL-RANDKEY-DERIV` (`variant3d/scripts/terrain_donor_gen.gd`, 06:10:03 — plus a `--check-only` parse result `variant3d/.godot_queue/results/00000133.json`, exit 0, status ok, not a gate), `IMPL-QUAD-COPY` (`variant3d/scripts/terrain_donor_mesh.gd`, 06:11:50), and the two camera-wire lanes carried from recheck4 (`camera.gd`, `camera3d.gd`, `game.gd` — unchanged mtime this wave).

Scanned in full: `docs/terrain_swarm_2026-11-26/reports/**/*.md` (whole report set), `spec/**`, root docs (`CHARTER.md`, `HANDOFF.md`, `SWARM_BOARD.md`, `REPORT_INDEX.md`, `PORT1TO1_PLAN.md`, the `.bak-NUMBERING` plan) and the current `variant3d/` tree (`.gd`, `.gdshader`, `.json`, `.md`, `.cfg`, `.tscn`, `.py`). Backup files (`*.bak-*`) are preservation-only and are treated as non-live, as in recheck2/3/4.

Scan classes (inherited, case-insensitive where wording varies), each run repo-wide over both trees:

- **C1** forbidden true flags: `parity=true`, `parity = true`, `"parity": true`, `visual_parity_claim=true`, `parity_claim=true`, `donor_parity_claim=true`, `parity=PASS`.
- **C2** `RESULT IS GOOD` (unqualified vs conditional / template / quotation / negation).
- **C3** `claim=owner-supplied` used as a pass.
- **C4** unqualified donor-parity assertions: "donor parity confirmed/achieved/PASS/verified", "parity achieved", "matches donor", "close to donor", "donor-exact" read as a runtime claim, "1:1/1TO1 parity", "perfect/full parity".
- **C5** gate/metric promoted to parity: "gate PASS ⇒ parity", "PASS proves donor", "no threshold + metric = parity", a parse result read as verification.
- **C6** port-internal "parity" strings and "donor-faithful"/"donor-instruction-faithful"/"donor-settled"/"endorsed" phrasing misreadable as donor parity when cut out of context.

## 2. Result by class — guarded vs unguarded

| Class | Live unguarded claim introduced by the new wave | Classification | Evidence (exact file:line) |
|---|---|---|---|
| **C1 true flags** | **NONE** | Every hit is a quoted scan target, a negation, a zero-count assertion or a governance list. A repo-wide scan of `docs/` for `parity\s*[=:]\s*true`, `"parity"\s*:\s*true`, `parity\s*[=:]\s*PASS`, `visual_parity_claim\s*[=:]\s*true`, `parity_claim\s*[=:]\s*true`, `donor_parity_claim\s*[=:]\s*true` returned only the prior audit inventories; a scan of live `variant3d/scripts/*.gd` for the same forms plus `RESULT IS GOOD` returned **"No matches found"**. | Baseline quoted-only targets unchanged: `DEC_U_port_guard_audit.md:77,160`; `PORT1TO1_final_guard_audit.md:30,42,167`; `PORT1TO1_internal_validation.md:128`; `V111_asset_final.md:27`; `V33_do_not_do_checklist.md:73`; `V76_gate_preflight.md:46`; `PORT1TO1_tree_recheck.md:50`; recheck2/3/4 scan inventories. All 12 new reports use `NO_PARITY_CLAIM` / `PARITY_UNVERIFIED` / `NONE` / `false`: `DEC_U_b6_g0.md:9-13`; `DEC_U_nb1.md:14-17`; `DEC_U_b9_wpn_shield.md:6,10,158`; `DEC_U_b10_skirmish_tables.md:6,10,202-204`; `DEC_U_nb3.md:10,82,101`; `DEC_U_nb4.md:9,163,167`; `DEC_U_nb2.md:14-17`; `DEC_U_nb7.md:8-12,106`; `DEC_U_nb5.md:5,9,21,248`; `PORT1TO1_b_angle_final.md:8-12`; `DEC_U_ureg_ctor.md:9-12,167`; `DEC_U_b45_residual.md:8-9,98`. |
| **C2 `RESULT IS GOOD`** | **NONE unguarded** | The literal (quoted here as a scan target only) appears in the new wave **zero** times. Six of 12 new reports carry a literal `RESULT IS NOT GOOD` verdict; six express the verdict as UNVERIFIED/no-parity + governing line (GAP-5N7, label-only). Baseline guarded set unchanged. | Literal verdicts: `DEC_U_b6_g0.md:13`; `DEC_U_nb1.md:17`; `DEC_U_nb2.md:17,232`; `PORT1TO1_b_angle_final.md:12,27,142,155,159,161`; `DEC_U_ureg_ctor.md:18`; `DEC_U_b45_residual.md:100`. Governing/no-literal form: `DEC_U_b9_wpn_shield.md:158`; `DEC_U_b10_skirmish_tables.md:204`; `DEC_U_nb3.md:10,101`; `DEC_U_nb4.md:165,167`; `DEC_U_nb5.md:21,251`; `DEC_U_nb7.md:23,110`. Baseline guarded set unchanged: `W08_visual_acceptance_criteria.md:196`; `V15_acceptance_without_reference.md:331-332`; `X39_ab_feasibility.md:236`; `PORT1TO1_final_guard_audit.md:30,64,65,157,167`; `PORT1TO1_acceptance_plan.md:368`; `PORT1TO1_acceptance_runbook.md:345`; `PORT1TO1_owner_brief.md:94`; `PORT1TO1_owner_brief_addendum.md:81`; `PORT1TO1_final_gates.md:147`; `PORT1TO1_u_register_update.md:113,172`; `PORT1TO1_decision_sim.md:142`; `PORT1TO1_p0_session_plan.md:250`; `PORT1TO1_session_risks.md:170`; `PORT1TO1_handoff_checklist.md:293`; `PORT1TO1_internal_validation.md:128,129,154`; `PORT1TO1_tree_recheck.md:34,51-53`; `V67_owner_answer_check.md:128`; `DEC_U_port_guard_audit.md:80`; `PORT1TO1_claim_recheck4.md:49`. |
| **C3 `claim=owner-supplied`-as-pass** | **NONE** | No occurrence in any of the 12 new reports. Baseline occurrences all record a human assertion, not a verdict, and explicitly never promote `parity=UNVERIFIED`; unchanged from recheck4. | Baseline: `PORT1TO1_decision_sim.md:56,142,173`; `PORT1TO1_final_guard_audit.md:30,48-49,167`; `PORT1TO1_gate_audit.md:164`; `PORT1TO1_artifact_layout.md:196`; `PORT1TO1_acceptance_plan.md:252,263`; `PORT1TO1_roi_register.md:90,213`; `variant3d/tools/acceptance/compare_frames.py:16,139,255`; `variant3d/tools/acceptance/README.md:13,129`. |
| **C4 donor-parity assertion** | **NONE unguarded** | Hits split into (a) negations / forbidden-phrasing inventories and (b) static `[O]/[D]` donor text/byte recovery paired with still-`[U]` port values. No new report and no implementation lane asserts a runtime/visual donor match. | New negations/lists: `DEC_U_b6_g0.md:30,46,186,190`; `DEC_U_nb1.md:22,28,85,103,123-125`; `DEC_U_b9_wpn_shield.md:10,114,155,158`; `DEC_U_b10_skirmish_tables.md:10,178,202,204`; `DEC_U_nb3.md:10,15,82,101`; `DEC_U_nb4.md:23,135,163,167`; `DEC_U_nb2.md:22,192,230-232`; `DEC_U_nb7.md:9,23,94,106,110`; `DEC_U_nb5.md:21,205,235,248,251`; `PORT1TO1_b_angle_final.md:27,111,139,141,156`; `DEC_U_ureg_ctor.md:23,165,167`; `DEC_U_b45_residual.md:9,22,98,100`. Guarded static recovery: `DEC_U_nb5.md:205` ("static angle CLOSED [D]" paired with "value-level byte-dump stays [U]"), `DEC_U_nb4.md:135` ("U-KEY derivation CLOSED [D]" with runtime fields `[U]`), `DEC_U_b9_wpn_shield.md:140` (future fixture, GAP-5N1). Live source guards: `terrain_donor_gen.gd:81-82,122-126,452-458,532,822,928`; `terrain_donor_mesh.gd:1937,1943-1948`; `camera.gd:15-17,30,70-79,89,161,178`; `camera3d.gd:483-484`; `game.gd:685,687-709`. |
| **C5 gate/metric → parity** | **NONE** | Every gate/metric surface is explicitly denied as parity. The new `--check-only` parse artifact (`00000133.json:3-17`) is a syntax check (exit 0 / status ok), **not** a gate PASS and not a parity surface; no report attaches it to parity. | `PORT1TO1_b_angle_final.md:27,73,111,139-143`; `DEC_U_nb5.md:205,226,235`; `DEC_U_nb4.md:135,163`; `DEC_U_b6_g0.md:30,190`; `DEC_U_b9_wpn_shield.md:114,120,155`; `DEC_U_b10_skirmish_tables.md:178,202`; `DEC_U_nb7.md:89,94,110`; `DEC_U_b45_residual.md:68,98,100`. Baseline: `PORT1TO1_decision_sim.md:163-180`; `PORT1TO1_gate_audit.md:14,40,163-164`; `PORT1TO1_final_gates.md:14,44,162,167`; `PORT1TO1_parity_chain.md:41,121,129-130,147`; `PORT1TO1_parity_recheck.md:46,117-118,136`; `PORT1TO1_internal_validation.md:154`; `V112_gate_witness.md:14,37,93`. |
| **C6 misread-risk strings** | **NONE is a parity claim**; 7 NEW guarded phrasings + carried-forward implementation-seam phrasings, all label-only | Guarded by inline or adjacent negations; listed only because a reader cutting a line out of context could misread them. Full register in §4. | See §4. |

**C1–C5 result: no live unguarded parity claim was introduced by any of the 12 new reports, and none was introduced in `variant3d/` by the randkey or quad-copy lanes.** All C6 strings are guarded; they are listed only as hardening items.

## 3. Verdict-line verification for every new report

The owner's required verdict marker is `RESULT IS NOT GOOD` / `parity.claim=NONE` / `UNVERIFIED`. **All 12 new reports carry an UNVERIFIED/no-parity marker.** Six carry a literal `RESULT IS NOT GOOD` verdict; six carry the equivalent governing form (no literal verdict line — GAP-5N7, label-only, not a suppressed verdict), exactly as recorded for four reports in recheck4 GAP-4N5.

| # | New report | UNVERIFIED / no-parity evidence | Verdict line (current tree) | Literal verdict present? |
|---|---|---|---|---|
| 1 | `DEC_U_b6_g0.md` | `:9` PARITY_UNVERIFIED; `:10-12` UNVERIFIED/NONE/false; `:30` `parity.claim = NONE`; `:190` verdict restatement | `:13` `verdict: "RESULT IS NOT GOOD for B6 promotion … T-G0 stays [U]; no density invented; no parity claim"` | **Yes** |
| 2 | `DEC_U_nb1.md` | `:14-16` UNVERIFIED/NONE/false; `:22` "No parity claim"; `:28` `[U]` on every provenance value | `:17` `verdict: "RESULT IS NOT GOOD for NB-6 static angle alone … hard-fail (no water) endorsed; no approximation."` (see GAP-5N2) | **Yes** |
| 3 | `DEC_U_b9_wpn_shield.md` | `:6` NO_PARITY_CLAIM; `:10` "NO PARITY CLAIM"; `:155-158` zero promotions + governing line | `:158` "`port=UNVERIFIED`; `parity.claim = NONE`; … no parity is claimed" | No — UNVERIFIED/no-parity form only |
| 4 | `DEC_U_b10_skirmish_tables.md` | `:6` NO_PARITY_CLAIM; `:10` "NO PARITY CLAIM"; `:202` NONE/UNVERIFIED/false | `:204` "`port=UNVERIFIED`; `parity.claim = NONE` … no parity claim is made" | No — UNVERIFIED/no-parity form only |
| 5 | `DEC_U_nb3.md` | `:10` "NO PARITY CLAIM"; `:82` "No parity claim"; `:101` "No parity claimed" | `:15` classifying paragraph + `:101` non-claims; no `verdict:` key | No — UNVERIFIED/no-parity form only |
| 6 | `DEC_U_nb4.md` | `:9` PARITY_UNVERIFIED; `:163` NONE/UNVERIFIED/false; `:167` "No parity claimed" | `:165` required reviewer line verbatim; no `verdict:` key | No — UNVERIFIED/no-parity form only |
| 7 | `DEC_U_nb2.md` | `:14-16` UNVERIFIED/NONE/false; `:22` "No parity claim"; `:232` restatement | `:17` `verdict: "RESULT IS NOT GOOD for NB-2 static angle alone … every value/behaviour item stays [U] … no approximation."` | **Yes** |
| 8 | `DEC_U_nb7.md` | `:8` NO_PARITY_CLAIM; `:9` parity_guard; `:10-12` UNVERIFIED/NONE/false; `:106` claim 7 | `:23` "No parity claim"; `:110` "No donor parity, similarity score, threshold or gate PASS is claimed"; no `verdict:` key | No — UNVERIFIED/no-parity form only |
| 9 | `DEC_U_nb5.md` | `:5` NO_PARITY_CLAIM; `:9` `parity_claim: false`; `:21` "No parity claim"; `:248` value dump + parity `[U]`/NONE | `:21` §0 verdict table "**No parity claim.** No donor GPU frame; no donor execution"; `:251` "no parity claimed" | No — UNVERIFIED/no-parity form only |
| 10 | `PORT1TO1_b_angle_final.md` | `:8-11` PARITY_UNVERIFIED/NONE/false; `:141` chain 0/6; `:27` reviewer line | `:12` `verdict: "RESULT IS NOT GOOD … chain 0/6 CLOSED … class-B static results never close class-A value/behaviour items"`; `:142,:159` restatements | **Yes** |
| 11 | `DEC_U_ureg_ctor.md` | `:9-12` NO_APPROXIMATION/PARITY_UNVERIFIED/NONE/false; `:23` reviewer line; `:167` NONE/UNVERIFIED/false | `:18` `verdict: "RESULT IS NOT GOOD for the U-REG-TEX static angle alone … U3 identity/values stay [U]; hard-fail endorsed; no approximation."` (see GAP-5N3) | **Yes** |
| 12 | `DEC_U_b45_residual.md` | `:8-9` NO_PARITY_CLAIM + parity_guard; `:98` NONE/UNVERIFIED/false | `:100` "**RESULT IS NOT GOOD** while `blocking_unverified` is non-empty … no parity claim is made" | **Yes** |

**Conclusion on verdicts:** no new report asserts donor parity, closes a P0, or weakens a test. Six carry a literal verdict; six carry an equivalent UNVERIFIED/no-parity governing line (GAP-5N7, label-only). Chain is **0/6 CLOSED** in every packet that states a number (`PORT1TO1_b_angle_final.md:12,141,159`; `DEC_U_b45_residual.md:100`; `PORT1TO1_claim_recheck4.md:144` carried).

## 4. Gap register — all LABEL-ONLY, no code/value/behaviour change

These strings are **not** parity claims. Each is guarded by an adjacent negation or a named port-internal qualifier. **No remediation was applied by this audit**; replacements below are label text only.

### 4.1 NEW misread-risk phrasings in the 12 reports

| # | Exact file:line | Current string (excerpt) | Guard that prevents a claim | Label-only remediation |
|---|---|---|---|---|
| GAP-5N1 | `DEC_U_b9_wpn_shield.md:140` | "keep `round()` half-to-even with `[U]`-G1 tag until the X21 20-vector fixture **proves Delphi parity**" | `:114` no CODE value overrides/confirms any script row; `:120` zero promotions; `:155` applications stay `[U]`; `:158` `parity.claim = NONE`. "Delphi parity" here names a future port-internal rounding-vector fixture, not a donor GPU A/B comparison. | Change to "until the X21 20-vector fixture proves the port `round()` matches Delphi half-to-even (port-internal numerical check, **NOT donor parity**)". Same class as recheck4 GAP-4N2 conditional-closure wording. |
| GAP-5N2 | `DEC_U_nb1.md:17` (verdict) and `:28` | "hard-fail (no water) **endorsed**" / "The port's hard-fail (no water until a real reflection target) **is endorsed**" | `:14-16` UNVERIFIED/NONE/false; `:22` "No parity claim"; `:28` `[U]` on every provenance value; `:103-104` no byte-proven link; `:123-125` no guess promoted | Change "endorsed" to "retained as the labelled hard-fail posture (NOT donor behaviour)". Same class as recheck2 GAP-8 / recheck3 GAP-N1 / recheck4 GAP-4N1. |
| GAP-5N3 | `DEC_U_ureg_ctor.md:18` (verdict) and `:168` | "hard-fail **endorsed**"; "the port's decoded-grid `height_tex`/`hmapTex` + `±2.96` span … **is endorsed as the donor-faithful behaviour** until the corresponding zero-mismatch captures land" | `:9-12` NO_APPROXIMATION/PARITY_UNVERIFIED/NONE/false; `:23` reviewer line; `:134` identity/class/values `[U]`; `:167` "No parity claim"; `[U3]` tag + "until … captures land" | Change verdict "endorsed" to "retained as labelled"; change `:168` to "retained as the labelled `[U3]` port substitute (NOT donor behaviour)". Same class as recheck3 GAP-N2 / recheck4 GAP-4N2. |
| GAP-5N4 | `DEC_U_nb5.md:235` | "No parity claim: this map is **donor-instruction-faithful**, not a same-camera A/B proof." | `:21` "No parity claim"; `:205` static angle CLOSED [D] as an instruction/offset map only; `:220` value-level dump `[U]`; `:226` owner-only termination; `:248` value dump + parity `[U]`/NONE | Change to "static donor-instruction-derived field map (NOT donor runtime/visual parity)". Highest cut-out-of-context risk in this wave because "faithful" sits in an imperative-looking port instruction. |
| GAP-5N5 | `variant3d/scripts/terrain_donor_gen.gd:116` and `variant3d/scripts/terrain_donor_mesh.gd:1942` (implementation lanes) | "SCOPE: **donor-settled facts ONLY** …"; "NB-5 … **donor-settled STATIC facts**, labelled data only" | gen `:117-126` BYTE-PROVEN [D] but "labelled data/telemetry ONLY", "no generation RNG behaviour change", state/source `[U]`, "no parity claim"; gen `:452-458` "NEVER read by generation" + `parity UNVERIFIED`; gen `:822,:928` `"parity": "UNVERIFIED"`; mesh `:1943-1948` "NOT a memcpy … no constant invented … value-level byte dump stays [U] U-10b … TELEMETRY ONLY: no geometry/mesh/shader/sim change"; mesh `:1937` "no parity claim" | Append "(static donor-text/byte facts only; runtime/visual parity UNVERIFIED)" at each lane site. Implementation-lane label hardening only; no telemetry key, generation path or mesh attribute changes. Carry-forward: `terrain_donor_gen.gd:2728` "donor-exact" (pre-existing at `.bak-RANDKEYDERIV:2557`) stays as recorded in recheck4 §4.3. |
| GAP-5N6 | `PORT1TO1_b_angle_final.md:49` | "**NB-5** — `U-copy-site` native side … **PENDING** — no `DEC_U_nb5*.md` observed; `PORT1TO1_PLAN.md:256` row 245 DOING, `DEC-U-NB5` active" | `:73,93` "No original B execution closed a class-A value …"; `:139-143` no P0 closed. But `DEC_U_nb5.md` landed at 06:09:52 (before this table at 06:11:01) and the renumbered plan marks row 245 **DONE** (`PORT1TO1_PLAN.md:256`). | Change status to "EXECUTED — `DEC_U_nb5.md` (static chain/scatter CLOSED [D]); value-level dump `[U]` U-10b unchanged" and update the plan cite to `:256` DONE. Status-label correction only; no closure, no parity. |
| GAP-5N7 | `DEC_U_b9_wpn_shield.md:158`; `DEC_U_b10_skirmish_tables.md:204`; `DEC_U_nb3.md:10,101`; `DEC_U_nb4.md:165,167`; `DEC_U_nb5.md:21,251`; `DEC_U_nb7.md:23,110` | Six new reports carry no literal `RESULT IS NOT GOOD` / `verdict:` line; verdict is expressed as UNVERIFIED/no-parity frontmatter + governing line | Each denies a parity claim and keeps every live value `[U]`; no parity state is suppressed | Append a `verdict: "RESULT IS NOT GOOD — … no parity claim"` line (or the literal closing form used at `DEC_U_b45_residual.md:100`) to each. Presentation label only — continuation of recheck4 GAP-4N5. |

### 4.2 Standard static-recovery idiom in the new wave (guarded, no action)

`DEC_U_b6_g0.md:42-45,149`, `DEC_U_b9_wpn_shield.md:105-114`, `DEC_U_b10_skirmish_tables.md:130-146`, `DEC_U_nb2.md:28-34,152-156,188-192`, `DEC_U_nb3.md:15,49-53`, `DEC_U_nb4.md:100-115`, `DEC_U_nb5.md:19-23,205`, `DEC_U_nb7.md:57,83`, `DEC_U_ureg_ctor.md:29,107`, `DEC_U_b45_residual.md:49,57,86` use the established "static `[O]/[D]` donor text/byte recovery, port value stays `[U]`" idiom. Each is adjacent to an explicit negative ("No parity claim", "no value promoted", "terminate only on zero mismatches"). This is the recheck2 §4.2 / recheck3 §4.1 / recheck4 §4.2 idiom, not a new class; keep the guards. The "CLOSED [D]" labels at `DEC_U_nb4.md:135`, `DEC_U_nb5.md:20,205` and `DEC_U_nb2.md:230` are explicitly qualified as static/formula-level and are reconciled by `PORT1TO1_b_angle_final.md:34,73,111` ("a structural closure is not a value closure"); no action.

### 4.3 Residual baseline C6 strings still un-hardened in the current tree

Carried forward from recheck2 §4 / recheck3 §4.2 / recheck4 §4.3 — **none was applied by this audit**:

- `DEC_U_audio_rng.md:98` — "donor-exact audition path" (same bullet says `PORT APPROXIMATION — no donor pitch RNG …`). Append `(text-pitch constant only; runtime/audio parity UNVERIFIED)`.
- `variant3d/scripts/pattern_gen.gd:373` — "count parity with the pre-fix baseline" (port-internal). Append `(port-internal count parity, NOT donor parity)`.
- `variant3d/scripts/game.gd:81`, `:2475` — "simulation/world.gd parity", "2D parity preserved" (named port modules). Append `(port-internal, NOT donor parity)`.
- `variant3d/scripts/input_controller.gd:938` — "keep 2D parity". Append `(NOT donor parity)`.
- `DEC_U_select_deep.md:18` — heading suffix "(donor 1:1)". Retitle `(static donor-source localization; NOT donor runtime parity)`.
- `DEC_U_hmap_num_deep.md:186`, `DEC_U_water_uv_deep.md:202` — "endorsed as the donor-faithful behaviour" / "endorsed as donor-faithful". Change to "retained as the labelled port substitute (NOT donor behaviour)".
- `DEC_U12_deep.md:132` — "endorsed as donor-faithful". Change to "retained as the labelled hard-fail posture (not a claim of donor behaviour)".
- `DEC_U_bld_death_time.md:4` — role suffix "donor 1:1 building-death time-base static probe". Retitle `(static donor-source localization; NOT donor runtime parity)`.
- `camera.gd:63-64,91,161` and `camera3d.gd:473-484` — "donor-settled … RETIRED" static-text phrasings, guarded by `:15-16,70-79,89,178` / `:479-484`. Append the recheck4 GAP-4N4 qualifier at each site.

Guarded "endorsed … until … capture lands" phrasings in pre-existing water/FOW reports (`DEC_U_water_mesh_uv.md:197`, `DEC_U_water_capture.md:200`, `DEC_U_water_fbo.md:153`, `DEC_U_hmap_identity.md:185`, `PORT1TO1_fow_owner_protocol.md:300`, `PORT1TO1_water_owner_protocol.md:219`) are unchanged and remain label-only. No new stale cross-reference was found except GAP-5N6; recheck2 GAP-9…GAP-12 remain as recorded.

**Every gap above is label-only. None changes a value, gate, assertion, threshold, `[U]` status, P0 status or preserve-only mod. No gap is a parity claim.**

## 5. Explicit confirmation — no static result was promoted to behaviour or parity

Checked all 12 new reports: every recovered `[O]/[D]` static fact is paired with a still-`[U]` live value and an owner/COORD-only zero-mismatch experiment; none is written into the port as donor behaviour by these reports.

- `DEC_U_b6_g0.md:46` "No value promoted. T-G0 stays `[U]`"; `:171-175` C-G0a/b/c zero-mismatch battery; no `G→count` formula invented.
- `DEC_U_b9_wpn_shield.md:114-120` zero promotions; `:131` B9 closes only when W1/W3/W4 batteries are green; no neighbour-sid copy.
- `DEC_U_b10_skirmish_tables.md:178,202` six §5 batteries with zero-mismatch termination; no rate/weight/threshold invented.
- `DEC_U_nb1.md:28,103-104` `[U]` kept on every provenance value; no `TOSW*`→`C+0x4c/e0/+8` edge; `TOSWRefTextureImage` stays `[I]`.
- `DEC_U_nb2.md:192,230-232` no `pattern.lib` float promoted into the generator; U-HF/U-ANG/U-OBJ/U-MAX/U-S0/U-MDEN/U-ATLAS all `[U]`.
- `DEC_U_nb3.md:71-82,101-102` no blocker/slope/step/`FOWElevation`/TLOS value invented; FOW linkage `[U]`.
- `DEC_U_nb4.md:135,163` U-KEY **derivation formula** CLOSED `[D]` only; invocation timing, U-KEY2/U-MAP/U-SS/U-ONLY/U-TIME remain `[U]` with probes.
- `DEC_U_nb5.md:205,220-226` static chain/scatter map CLOSED `[D]`; value-level byte dump stays `[U]` U-10b with owner-only break/trace probe.
- `DEC_U_nb7.md:83,89-94` no kernel/topology/weights/radius/VM-dispatch recovered; all such values `[U]`; blurred kernel denied.
- `DEC_U_b45_residual.md:57,63-68,81-86` property-table structure only; no radius/version/mapsize value decoded; selectors `[U]`.
- `DEC_U_ureg_ctor.md:134,140-150` U3 identity/values `[U]` with GL captures; `C+0x54` ctor defaults proven *not* to be draw-time hmap supply.
- Consumer tables: `PORT1TO1_b_angle_final.md:34,73,93,111,139-143` — 14/14 original and 6/7 NB executed statically; only NB-4's derivation is a new numeric `[D]`; no class-A item closed, no P0 closed, no parity claimed. `PORT1TO1_claim_recheck4.md:128-139` carried forward unchanged.

**No promotion found.** Every static finding remains a bounded search hint; every live value remains `[U]` pending its named owner-only experiment; even a green harness yields internal consistency only.

## 6. Explicit confirmation — no implementation lane asserted donor parity

- **Randkey lane — `IMPL-RANDKEY-DERIV` (`terrain_donor_gen.gd`, plan `:258` DONE):** `:113-126` new landing block records the byte-proven `GenerateMapRandKey` derivation as "labelled data/telemetry ONLY", "no generation RNG behaviour change", "caller-supplied randkey0/1 stay verbatim", Delphi state/source `[U]` with probes, "no parity claim"; `:451-458` `RANDKEY_DERIVATION_AUTHORITY` is "LABEL / DATA / TELEMETRY ONLY", "NEVER read by generation", `parity UNVERIFIED`; `:513-527` every open field carries a terminating probe; `:532` "PARITY / CONFIG HOOKS — all UNVERIFIED values live here"; `:822,928` telemetry `"parity": "UNVERIFIED"`. The parse artifact `variant3d/.godot_queue/results/00000133.json:3-17` is `--check-only` / exit 0 / status ok — a syntax check, **not** a gate PASS or a parity surface (C5).
- **Quad copy-map lane — `IMPL-QUAD-COPY` (`terrain_donor_mesh.gd`, plan `:261` DONE):** `:1942-1948` "donor-settled STATIC facts, labelled data only", "Every constant … quoted from decoded donor instruction bytes; no stride, offset or donor value is invented", "value-level byte dump stays `[U]` U-10b", "TELEMETRY ONLY: no geometry, mesh attribute, shader or sim change"; `:1937` triangles remain a "PORT representation, no parity claim"; `:1949-2017` every NB-5 key is `[O]/[D]` with a `DEC_U_nb5.md` section/evidence-id cite; no GL name, mesh binding or UV value is fabricated.
- **Camera wires (carried, unchanged this wave):** `camera.gd:15-17,30,63-79,89,161,178` and `camera3d.gd:49,72,75,91,96-97,103,110,473-484,622-627` keep FOV/zoom/height/time derivations `[U]` and "NO PARITY CLAIM"; `game.gd:685,687-709` exposes only the start-derived target through the existing API. No new assertion appeared.
- **Repo-wide source scan:** live `variant3d/scripts/*.gd` returned **no match** for C1 true flags, `RESULT IS GOOD`, or runtime donor-parity assertion forms (`parity=true`, `visual_parity_claim:=true`, "donor parity confirmed/achieved/PASS/verified", "parity achieved", "matches donor", "close to donor", "perfect/full parity", "1:1 parity"). The only "donor-settled"/"donor-exact"/"donor-faithful" strings are the guarded static-text phrasings in GAP-5N5 and §4.3. Backup files are preservation-only and carry no live claim.

**No implementation-lane parity assertion found.** Both new lanes wire donor-text-located facts as labelled telemetry while keeping every live value `[U]`, exactly as the static reports prescribe; neither closes a P0 or produces a gate PASS.

## 7. Dominance confirmation and verdict

- `parity=UNVERIFIED`, `parity.claim=NONE`, `parity.claim_code=NONE`, `visual_parity_claim=false` dominate across all 12 new reports and the baseline set. Representative exact citations: `DEC_U_b6_g0.md:9-13,190`; `DEC_U_nb1.md:14-17`; `DEC_U_b9_wpn_shield.md:6,10,158`; `DEC_U_b10_skirmish_tables.md:6,10,202-204`; `DEC_U_nb3.md:10,101`; `DEC_U_nb4.md:9,163,167`; `DEC_U_nb2.md:14-17,232`; `DEC_U_nb7.md:8-12,106,110`; `DEC_U_nb5.md:5,9,21,248`; `PORT1TO1_b_angle_final.md:8-12,141`; `DEC_U_ureg_ctor.md:9-12,167`; `DEC_U_b45_residual.md:8-9,98-100`.
- **`RESULT IS NOT GOOD`** while `blocking_unverified` is non-empty — P0-1…P0-8 and the §2/§3 tails remain OPEN (`PORT1TO1_b_angle_final.md:12,140-142`; `DEC_U_b45_residual.md:100`; `PORT1TO1_claim_recheck4.md:144`). **Six-condition chain 0/6 CLOSED**; conditions 2 and 6 PARTIAL (port-internal only), conditions 1/3/4/5 BLOCKED (`PORT1TO1_b_angle_final.md:141`; `PORT1TO1_decision_sim.md:43-46`; `PORT1TO1_parity_chain.md:38-58`). No donor GPU A/B frame exists; no COORD ruling exists.
- **No approximation adopted, no parity claim, no test weakened, no gate/capture/donor execution.** The seven new gaps in §4.1 plus the carried-forward baseline gaps are label-only and none was applied by this audit. Exactly one repository file was written: this report.

*End of CLAIM-RECHECK5. PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass. `RESULT IS NOT GOOD`; chain 0/6.*
