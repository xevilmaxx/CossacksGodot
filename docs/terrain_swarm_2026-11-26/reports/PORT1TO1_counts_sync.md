---
id: PORT1TO1-COUNTS-SYNC-2026-11-27
title: "Final counts cross-check — CURRENT plan and final reports (71 [U] / 9 P0 / 0-of-6)"
worker: COUNTS-SYNC (read-only subagent; full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-27
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_counts_sync.md
files_created: [docs/terrain_swarm_2026-11-26/reports/PORT1TO1_counts_sync.md]
files_edited: []
scope_guard: "Repo/doc file reads and read-only filesystem listing/parse only. No source, shader, asset, config, test, fixture, manifest, queue, result JSON, backup or git state written; no donor binary opened/executed/captured; no Godot process, runner job, gate, harness, replay, paired save or port capture run. Exactly one repository file written: this report. Every donor/port fact below is carried [O]/[D] from the cited landed reports; no count is recomputed into a new authoritative total."
labels: [OBSERVED, DERIVED, UNVERIFIED, "PORT APPROXIMATION", PARITY_UNVERIFIED, NO_APPROXIMATION, NO_PARITY_CLAIM, RESULT_IS_NOT_GOOD]
parity_status: UNVERIFIED
parity_claim: NONE
visual_parity_claim: false
verdict: "RESULT IS NOT GOOD — blocking_unverified is non-empty; governing final counts are 71 open [U] (A42/B14/C5/D10), 9 P0 rows OPEN, six-condition chain 0/6 CLOSED; parity UNVERIFIED; no donor GPU A/B frame; no approximation, no parity claim"
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
governing_sources:
  - docs/terrain_swarm_2026-11-26/PORT1TO1_PLAN.md (current master task list, 260 sequential tasks)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_u_register2.md (final definitive U register: 71, A42/B14/C5/D10; 9 P0; 0/6)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_p0_final_status.md (definitive nine-row P0 table, all OPEN)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_chain_update2.md (chain 0/6, no status cell changed)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_owner_brief2.md (final owner brief: 8 recovery rows, 9 P0, 0/6)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_u_classify.md, PORT1TO1_b_angle_final.md, PORT1TO1_p0_sync2.md, PORT1TO1_handoff_sync.md, PORT1TO1_plan_sync.md, PORT1TO1_index_final3.md, PORT1TO1_claim_recheck6.md, PORT1TO1_handoff_checklist.md, PORT1TO1_owner_brief.md
---

# PORT1TO1 — final counts sync audit (current tree, 2026-11-27)

> **Mandatory reviewer line, verbatim:** PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

> This is a read-only cross-check of four governing counts — open `[U]` rows, P0 rows, parity-chain conditions and plan task numbering — across the CURRENT plan and the final-report set. It flags inconsistencies with exact `file:line` and a **label-only correction**; it applies no fix, promotes no `[U]`, closes no P0, changes no status cell and makes no parity claim. A `PARTIAL` is not a `CLOSE`, an index presence is not a gate PASS, and a static `[D]` is not a value or behaviour closure.

---

## 0. Governing final state — CONFIRMED

| Quantity | Governing value | Exact citations (current tree) |
|---|---|---|
| Open `[U]` rows at authoritative register granularity | **71** (`A42 / B14 / C5 / D10`; domains W15/T5/E18/S16/F12/GOV5) | `PORT1TO1_u_register2.md:60,61,67-75,77-89,182`; `PORT1TO1_u_classify.md:53,162-184,224`; `PORT1TO1_d_cosmetic.md:34`; `PORT1TO1_handoff_sync.md:35,46`; `PORT1TO1_owner_brief2.md:35,48`; `PORT1TO1_PLAN.md:231,266,271` |
| P0 rows | **9**, all `OPEN`; `CLOSED` appears for no row; `PARTIAL` is a chain-cell label only | `PORT1TO1_p0_final_status.md:40,47-61,86,94`; `PORT1TO1_u_register2.md:62,134-150,185`; `PORT1TO1_owner_brief2.md:15,50-64`; `PORT1TO1_chain_update2.md:53,99`; `PORT1TO1_PLAN.md:230,266` |
| Six-condition parity chain | **0/6 CLOSED** — conditions 2 and 6 PARTIAL (port-internal only), conditions 1/3/4/5 BLOCKED | `PORT1TO1_chain_update2.md:15,51,71,120,140`; `PORT1TO1_u_register2.md:63,177`; `PORT1TO1_owner_brief2.md:71`; `PORT1TO1_p0_final_status.md:18,34,90`; `PORT1TO1_PLAN.md:163,179,265` |
| Parity | **UNVERIFIED**; `parity.claim = NONE`, `visual_parity_claim = false`; no donor GPU A/B frame, no matched camera, no COORD ruling | `PORT1TO1_u_register2.md:9-13,176,190`; `PORT1TO1_p0_final_status.md:14-18,34`; `PORT1TO1_chain_update2.md:11-15,71,120`; `PORT1TO1_owner_brief2.md:12-15,91-92`; `PORT1TO1_claim_recheck6.md:7-12,129-131` |
| Verdict | **`RESULT IS NOT GOOD`** while `blocking_unverified` is non-empty — nine P0 rows plus domain tails (D4 included unless explicitly excluded); unconditional | `PORT1TO1_u_register2.md:13,37,178,190`; `PORT1TO1_p0_final_status.md:18,34,94`; `PORT1TO1_chain_update2.md:15,53,120`; `PORT1TO1_owner_brief2.md:15,89,99`; `PORT1TO1_PLAN.md:197` |
| Current master task list | **260 tasks**, numbered 1–260, no gaps, no duplicates, sequential (read-only parse of `PORT1TO1_PLAN.md:12-271`; last row `:271`) | `PORT1TO1_PLAN.md:271` |

No final report produces a revised authoritative `[U]` total, a `CLOSED` P0 row, or a chain fraction other than `0/6`. No final report asserts donor parity. The governing counts above are therefore stable; the findings in §2 are **stale snapshots and label risks**, not changes to those counts.

---

## 1. Reconciliation detail

### 1.1 The 71 is a row count, not a sum of all named ids

- `PORT1TO1_u_classify.md:53,162-184` lists 71 rows; class sums 42+14+5+10 = 71 and domain sums 15+5+18+16+12+5 = 71. `PORT1TO1_u_register2.md:60,61,89` carries those counts unchanged and explicitly records **0** rows removed by the post-register sweep.
- `U-base-speed` is an id split, not an added row: `PORT1TO1_p0_final_status.md:67-69` calls it "genuinely new", but `PORT1TO1_u_register2.md:65,116,120` identifies it as a split of the already-counted `U-speed-consumer / T-SPEED` row (`PORT1TO1_u_classify.md:85`). Likewise `U-KEY2`/`U-MAP`/`U-SS`, `CAM-*`, `U6-T`/`DLT`/`O1` refine counted rows (`u_register2.md:65`). **No final report counts 72.** See CS-8.
- `PORT1TO1_d_cosmetic.md:34` (10 of 71 class-D) and `PORT1TO1_c_decisions.md:122` (5 class-C) are consistent with `u_classify.md §3.1/§3.2`.

### 1.2 Nine P0 rows

`PORT1TO1_p0_final_status.md:53-61` is the definitive 9-row table (rows 1–9: P0-1, P0-1b, P0-2, P0-3, P0-4, P0-5, P0-6, P0-7, P0-8), restated unchanged by `PORT1TO1_u_register2.md:138-150`, `PORT1TO1_owner_brief2.md:54-64`, `PORT1TO1_p0_sync2.md:54-64` and `PORT1TO1_chain_update2.md:53`. Zero rows are `CLOSED` or `PARTIAL` as rows. D4 is **not** one of the nine; it is a blocking non-P0 tail unless all four out-of-scope conditions are recorded (`u_register2.md:154-168`).

### 1.3 Chain 0/6

`PORT1TO1_chain_update2.md:51,71` is the current re-audit: no status cell changed from `PORT1TO1_parity_chain.md`/`PORT1TO1_parity_recheck.md`. Condition 6 PARTIAL rests on port-internal `detcheck`/`detcheck2` byte-identical `sha256_pixels` (2 frames / 64 ticks, not 24/768), and even that cell is statically contradicted by the T-VER 53-vs-92/240² byte mismatch (`chain_update2.md:69,84`). A PARTIAL never accumulates into parity (`chain_update2.md:112`).

### 1.4 "8 exact recoveries" is a row count, not eight implemented donor matches

`PORT1TO1_PLAN.md:268` says "8 exact recoveries" for task 257. `PORT1TO1_owner_brief2.md:41-48` has exactly eight §1 rows, but **four** are `IMPLEMENTED` (rows 1–4) and **four** are `REPORTED-ONLY` (rows 5–8); row 8 is governance/outcome, not a donor-exact recovery. `PORT1TO1_claim_recheck6.md:86` (GAP-6N4) already proposes the label-only fix. See CS-13.

---

## 2. Inconsistency register — exact `file:line` + label-only correction

All corrections below are **text/label recommendations only**. None was applied by this worker; none changes a count, status, gate, value, preserve-only hash or verdict.

| ID | Severity | Exact `file:line` | Observed string / state | Governing or contradicting evidence | Label-only correction |
|---|---|---|---|---|---|
| **CS-1** | Count-context stale | `PORT1TO1_PLAN.md:271` (and master table `:12-271`) | Task list reaches **260**; the brief context says "plan at 259 tasks" | Read-only parse: 260 rows, min 1 / max 260, 0 duplicates, 0 out-of-sequence; task 260 (`COUNTS-SYNC`) was added after the 259-task snapshot | Label the 259 figure "pre-task-260 snapshot"; state current master count as **260 tasks, 1–260 sequential**. Do not compress or renumber rows |
| **CS-2** | Plan-internal count stale | `PORT1TO1_PLAN.md:273` header `:275-283` bullets | "Current active workers **(4)**" with **9** bullets; only 3 rows are `DOING` (`:267` #256, `:270` #259, `:271` #260) | Six bullets are DONE lanes: `:275` #252, `:276` #253, `:277` #254, `:278` #255, `:280` #257, `:281` #258 (all DONE at `:263,264,265,266,268,269`) | Change header to "**(3)**" and either drop the six DONE bullets or retitle the block "historical roster (DONE)". Status cells unchanged |
| **CS-3** | Superseded snapshot | `PORT1TO1_plan_sync.md:27,61-65,70,72,77,88-103` | Snapshot has **236** task rows; reports gaps #53/#122, duplicates #131/#132, out-of-order #123/#130, "active workers (3)", 8 stale DONE bullets, "all worker-executable lanes DONE" contradiction | `PORT1TO1_PLAN.md:245` (task 234) records `+ COORD renumbering` → "237 rows sequential, no gaps/dups"; current plan is 260 sequential rows with 3 DOING | Prefix every finding "snapshot `sha256=9759F047…`, 236 rows" and mark it superseded by the renumbered 260-row plan. Do not re-apply those renumber fixes |
| **CS-4** | Stale absence claim | `PORT1TO1_u_classify.md:34`, `:223` | "`PORT1TO1_p0_final_status.md` is pending/nonexistent (0 hits)" classification claim | File exists: `PORT1TO1_p0_final_status.md:1-96`; plan `PORT1TO1_PLAN.md:230` task 219 DONE; cited by `PORT1TO1_u_register2.md:19` | Relabel "at the time of this classification; superseded by the landed definitive 9-row table". The 71/42/14/5/10 counts stay as carried |
| **CS-5** | Stale brief counts | `PORT1TO1_owner_brief.md:44-53` (P0 table), `:61` | Six-row P0 table (+ P0-6 in a footnote) and "No `PORT1TO1_parity_recheck.md` landed (only `X36_mountain_visual_recheck.md`)" | 9 P0 rows are governing (`p0_final_status.md:47-61`); `PORT1TO1_parity_recheck.md` exists; `owner_brief2.md:50-64,71` is the current brief | Label `owner_brief.md` "pre-final snapshot, superseded by `owner_brief2.md` for P0 count and chain status". Do not use its 6-row table for current counts |
| **CS-6** | Stale status label | `PORT1TO1_b_angle_final.md:49,89,93`, `:17` | "NB-5 PENDING — no `DEC_U_nb5*.md` observed"; 6/7 NB count; plan cited with NB-5 DOING | `DEC_U_nb5.md` exists and is CLOSED-`[D]` static; `PORT1TO1_PLAN.md:256` task 245 DONE; flagged by `PORT1TO1_u_register2.md:101`, `PORT1TO1_index_final3.md:124`, `claim_recheck5.md` GAP-5N6, `PORT1TO1_owner_brief2.md:48` ("pending then executed") | Relabel NB-5 "EXECUTED — static chain/scatter CLOSED `[D]`; value dump `U-10b` stays `[U]`"; keep "6/7" explicitly as index-time count, not a current count. No class-A item closes |
| **CS-7** | Known numbering collision | `PORT1TO1_b_angle_final.md:81-90,93`; `DEC_U_nb1.md` worker id; `PORT1TO1_PLAN.md:252` (task 241) | index-**NB-1** (U-REG-TEX residual) vs `DEC-U-NB1` worker executing the **NB-6** TOSW-ctor angle; NB-1 termination not claimed met | `b_angle_final.md:81` records the collision and "no candidate silently renumbered"; `PORT1TO1_u_register2.md:105` carries both readings | Always write "index-NB-1 (U-REG-TEX)" vs "NB-6 / worker `DEC-U-NB1` (TOSW ctor sweep)"; do not count them as two executed candidates or silently renumber |
| **CS-8** | Double-count guard | `PORT1TO1_p0_final_status.md:67-69`; `PORT1TO1_PLAN.md:230`; `DEC_U_speed_consumer_deep.md:224` | "One genuinely new `[U]`" / "new U-base-speed noted" / "plus the new U-base-speed" | `PORT1TO1_u_register2.md:65,116,120`: U-base-speed is a **split** of counted `U-speed-consumer / T-SPEED` (`u_classify.md:85`); no final report totals 72 | Append "(new **id**, not a new top-level register row; authoritative total remains 71)" at each site. Never add T-BASE/U-base-speed to the 71 |
| **CS-9** | Bad section citation | `PORT1TO1_p0_sync2.md:27,48,77,89` | Cites `PORT1TO1_b_angle_final.md §3.5` for "class-B static never closes class-A" four times | `PORT1TO1_b_angle_final.md` has §3.1 at `:79`, §3.2 at `:97`, §3.3 at `:113`, §4 at `:137`; the discipline statement is `:139`. No §3.5 exists | Repoint all four citations to `PORT1TO1_b_angle_final.md:139` (§4) or `:79` (§3.1). No count or status changes |
| **CS-10** | Stale aggregate P0 count | `PORT1TO1_handoff_checklist.md:129`, `:136` | "All **eight** P0 rows ... **six** owner packets, plus one P0 with **no dedicated packet**"; P0-7 "No dedicated packet file exists" | Nine P0 rows are governing; `PORT1TO1_rng_owner_protocol.md` is the dedicated P0-7 packet (plan `PORT1TO1_PLAN.md:202` task 191 DONE); `PORT1TO1_owner_decisions_update.md:97` already flags the six-packet index as stale | Relabel "nine P0 rows; seven owner packets; no P0 without a packet"; mark the P0-7 line "superseded". No packet closes a row |
| **CS-11** | Final-wave snapshot stale | `PORT1TO1_claim_recheck6.md:33-35,84` | Describes a 258-row plan, task 255 "still labelled DOING", task 258 DOING, and "a further PLAN renumbering landed" | Current plan has 260 rows; `:266` task 255 DONE, `:269` task 258 DONE (report at `claim_recheck6.md:1-16`), tasks 259/260 added | Label all plan-row statements "scan snapshot 06:19:45 / 258 rows"; do not quote them as current statuses. Its UNVERIFIED/0/6 verdict remains valid |
| **CS-12** | Final-wave snapshot stale | `PORT1TO1_index_final3.md:36,38,111,132` | 404-file glob; plan tasks 219–259; task 255 DOING vs report `DELIVERED`; task 256 self-DOING; task 258/259 "no report observed" | Current plan 260 rows; `:266` #255 DONE, `:269` #258 DONE; `PORT1TO1_index_final3.md:1-24` and `PORT1TO1_claim_recheck6.md:1-16` are delivered; task 259/260 have no report at this read (task 260 is this audit) | Label "point-in-time index snapshot"; reconcile statuses as "report delivered; plan status at read preserved". Keep 71/9/0-6 claims (`:110,111,138`) unchanged |
| **CS-13** | Misread-risk label | `PORT1TO1_PLAN.md:268` (task 257 note) | "**8 exact recoveries**, 9 P0 rows ..." | `PORT1TO1_owner_brief2.md:41-48`: 4 IMPLEMENTED + 4 REPORTED-ONLY; row 8 is governance; `PORT1TO1_claim_recheck6.md:86` GAP-6N4 already specifies the fix | Adopt GAP-6N4 wording: "8 static donor-text/byte recoveries (NOT donor runtime parity); 9 P0 rows open; chain 0/6". Plan status label only |
| **CS-14** | Non-defect, kept for audit clarity | `PORT1TO1_u_classify.md:85`, `PORT1TO1_u_register_update.md:91` vs `DEC_U_move_speed.md:54-74,94`, `PORT1TO1_p0_final_status.md:69` | "18 defined-but-dead speed constants" vs "17 `//`-dead per-sid writes" | `DEC_U_move_speed.md:58-74` shows an 18-row table = 1 `gc_obj_speed_default` + 17 per-sid rows; `:199` lists exactly 17 commented writes; no live consumer (`:94`) | No change required; if restating, write "18-row table (1 default + 17 per-sid), all defined-but-unconsumed". This is **not** a 72nd `[U]` row (see CS-8) |

---

## 3. What was explicitly checked and found consistent

1. **No competing `[U]` total.** No final report states 70 or 72 open rows; all occurrences of the authoritative total are 71 with A42/B14/C5/D10 (`u_classify.md:162-184`; `u_register2.md:60-89`; `owner_brief2.md:48`; `handoff_sync.md:46`; `index_final3.md:110`; `PLAN.md:231,266,271`).
2. **No competing P0 total.** `owner_brief.md:44-53` and `handoff_checklist.md:129` are the only sub-nine readings and are both older snapshots (CS-5, CS-10). The current set is nine rows, all OPEN.
3. **No competing chain fraction.** Every final report that states a number says 0/6; conditions 2 and 6 are PARTIAL, never CLOSED (`chain_update2.md:51,71`; `u_register2.md:63,177`; `owner_brief2.md:71`; `p0_final_status.md:18,34`; `index_final3.md:22,138`; `claim_recheck6.md:12,130`).
4. **No parity claim.** Frontmatter of every final report is `parity_status: UNVERIFIED` / `parity_claim: NONE|false` / `visual_parity_claim: false` (`u_register2.md:9-12`; `p0_final_status.md:14-17`; `chain_update2.md:11-14`; `owner_brief2.md:12-14`; `index_final3.md:19-22`; `claim_recheck6.md:7-11`). `claim_recheck6.md:52-61` found no live unguarded C1–C5 claim; its four new C6 items are guarded and label-only (`:83-86`).
5. **No status promotion by static facts.** `u_register2.md:61,95,110`, `p0_sync2.md:74-80`, `chain_update2.md:89,95`, `b_angle_final.md:139-143` all reaffirm that NB `[D]` derivations, T-VER literals and camera wires leave named `[U]` residuals and close zero P0 rows.
6. **Plan numbering itself is sound.** The current master table parses as 260 rows, 1–260, no gaps, duplicates or out-of-order entries; CS-1/CS-2/CS-3 concern snapshot labels and the active-worker roster, not the row sequence.

---

## 4. Verdict and claim register

| # | Claim | Label |
|---|---|---|
| 1 | Governing final state is 71 open `[U]` (A42/B14/C5/D10), 9 P0 rows all OPEN, chain 0/6, parity UNVERIFIED, `RESULT IS NOT GOOD` while `blocking_unverified` non-empty | `[D]` §0 with exact citations |
| 2 | Current plan has 260 sequential tasks; the "259 tasks" context and the 234/236/237/258-row snapshots are historical, not current counts | `[O]` read-only parse; CS-1/CS-3/CS-11/CS-12 |
| 3 | Fourteen label-level inconsistencies/stale snapshots were located; each has an exact `file:line` and a label-only correction; none changes a count, status, value or gate | `[O]`/`[D]` §2 |
| 4 | `U-base-speed` is a split id, not an extra top-level row; no authoritative total of 72 exists; 18-row speed table = 1 default + 17 per-sid | `[D]` CS-8/CS-14 with cited reports |
| 5 | NB numbering collision is disclosed, not silently renumbered; NB-5 is landed but stale-labelled PENDING in `b_angle_final` | `[O]`/`[D]` CS-6/CS-7 |
| 6 | No donor binary executed, no GPU frame captured/produced/compared, no Godot/gate/harness/replay/paired-save run, no git edit; exactly one repository file written | `[O]` scope guard |
| 7 | No approximation adopted, no `[U]` wired, no test weakened, no parity claim; `parity.status = UNVERIFIED`, chain 0/6 | `[O]`/`[D]` scope guard + governing verdicts |

> **Verdict (verbatim governing form):** `port=UNVERIFIED`; `parity.claim = NONE`; `parity.status = "UNVERIFIED"`; `visual_parity_claim = false`; `blocking_unverified` non-empty (P0-1, P0-1b, P0-2, P0-3, P0-4, P0-5, P0-6, P0-7, P0-8 plus the domain tails, D4 included unless explicitly excluded); six-condition chain 0/6 CLOSED; final counts **71 open `[U]` / 9 P0 OPEN / 0-of-6**. **`RESULT IS NOT GOOD`.** No same-camera donor/port A/B frame exists; no approximation is authorised; no parity claim is made.

---

*End of PORT1TO1_counts_sync. Read-only; exactly one repository file written; no source/shader/asset/config/test/runner/Godot/git/donor-execution; parity UNVERIFIED; `RESULT IS NOT GOOD` while `blocking_unverified` is non-empty.*
