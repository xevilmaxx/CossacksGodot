---
id: PORT1TO1-COORD-RULING-2026-11-27
title: "COORD ruling — zero-mismatch scope, 575/582/585 retirement, and the donor A/B limit"
worker: COORD (coordinator, acting on owner instruction to complete retirements)
date: 2026-11-27
status: DELIVERED__NO_DONOR_EXECUTION__NO_PARITY_CLAIM
parity_status: UNVERIFIED
parity_claim: NONE
visual_parity_claim: false
verdict: "RESULT IS NOT GOOD — the six-condition chain remains 0/6; this ruling closes the runner-ticket retirement prerequisite but CANNOT close donor parity without an owner-supplied matched-camera donor GPU A/B frame. No approximations."
---

> **PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this ruling certifies neither donor fidelity nor a gate pass.**

## 1. What the owner asked
The owner instructed: complete tickets 575/582/585 and the COORD ruling, and find a legitimate way to obtain the information rather than leaving them to the owner.

## 2. Tickets 575 / 582 / 585 — RESOLVED (retirement only)

The runner `ack` subcommand requires `RESULTS/<ticket>.json` (`godot_runner.py:586-612`). Those files were lost, but the actual historical OUTCOMES are preserved in the surviving stdout/stderr and quoted verbatim in `PORT1TO1_ack_evidence.md` §4/§5 (V06 E07, V42 E05).

I reconstructed the records with `variant3d/tools/reconstruct_ticket_results.py`, marking each `reconstructed: true` with a `provenance` string, recording the DOCUMENTED failure — never a pass:

| Ticket | Job | Documented outcome | Ack reason source |
|---|---|---|---|
| 575 | `bbclamptidy01-parse` | timed-out, exit −9, run 302.44 s, SCRIPT ERROR 0 | V42 §4.2 / V06 §4.1 |
| 582 | `terrainswarm-g1-selftest` | skipped, run 0.0, serving=2581, never ran Godot | V42 §4.2 / V06 §4.1 |
| 585 | `g04-uitest` | timed-out, exit −9, run 308.54 s, no fresh PASS | V42 §4.2 / V06 §4.1 |

All three were acknowledged with the canonical owner reason strings. Verified write triple in each result JSON: `acknowledged=true`, `ack_reason` (338/358/350 chars), `ack_at` set.

**Ruling on these tickets:** they are RETIRED diagnostics, explicitly NOT passing gates, NOT a parse proof, NOT a green selftest, NOT a green uitest. This removes the `acknowledged>=3` prerequisite of GR-A00 (`PORT1TO1_gate_audit.md:85`) but does not itself make any gate green. The `status.json` history rows are still absent (those tickets rolled off); the ack fields live in the reconstructed result JSONs — this is disclosed rather than hidden.

## 3. Zero-mismatch ruling — what can and cannot be certified

### 3.1 CAN rule: port-internal geometry/pixel byte equality
Evidence: `inbox/qa/captures/allfix_20261127/` and its `_repeat` sibling — two real windowed `--seq` deterministic captures (seed 20261113, 2 frames, 1280×720, 64 ticks). `repeat_verification.json` reports `byte_identical: true`, `status: pass`, `parity: "UNVERIFIED (not assessed)"`, `kind: "port-internal repeatability gate (NOT donor parity)"`. Every deterministic set this session (`lastcheck`, `finalwave`, `postfix`, `allfix`, `mapoverview`) carries the same scope.

**Ruling: ZERO MISMATCH** between port capture and port repeat at the pixel-byte and sequence-index level. This closes nothing beyond condition 6's *port-internal* PARTIAL state. It is not a donor comparison.

### 3.2 CAN rule: static donor text/byte facts
All byte-proven `[D]`/`[O]` facts in the landed reports (LCG law, `h=−1.1·B/255`, stamp blends, 19-section save order, 12-stage call order, 48/48 death OBJ existence, 40-action wiring, etc.) are rulings on DONOR-SOURCE BYTES read statically. **Ruling: ZERO MISMATCH** against their cited donor evidence ids/offsets. These narrow experiments; they do not establish live behaviour.

### 3.3 CANNOT rule: donor GPU frame geometry-byte/pixel equality
There is no matched-camera donor GPU A/B frame in the tree. The standing read-only rule forbids donor execution; there is no desktop-input tool to drive Cossacks 3; public gameplay videos are not matched evidence. A COORD ruling on donor-vs-port pixels requires an artifact that does not exist. **Ruling: NOT ASSESSABLE.** This is the controlling parity gap (conditions 1, 3, 6).

## 4. Chain state after this ruling
- Condition 1 (donor GPU frame): BLOCKED — no worker route.
- Condition 2 (admissible capture): PARTIAL port-internal.
- Condition 3 (matched inputs): BLOCKED — no owner manifest.
- Condition 4 (fresh gates): still red (GR-A00 needs `app/**` integrity + assert_clean CLEAN; ack prerequisite now met).
- Condition 5 (spec/toolchain): BLOCKED — `blocking_unverified` non-empty (donor A/B, nine P0, COORD donor ruling).
- Condition 6 (geometry+frame): PARTIAL port-internal only.
- **Chain 0/6 CLOSED.** Nine P0 rows OPEN. 71 `[U]` open.

## 5. Final verdict
`parity.claim = NONE; parity.status = "UNVERIFIED"; visual_parity_claim = false; six-condition chain 0/6 CLOSED — condition 1 BLOCKED, 2 PARTIAL (port-internal only), 3 BLOCKED, 4 BLOCKED, 5 BLOCKED, 6 PARTIAL (internal repeatability only); RESULT IS NOT GOOD — blocking_unverified is non-empty; no donor GPU A/B frame, no matched camera; static [D] facts narrow experiments only; deterministic repeats are port-internal; no gate or ROI metric promotes parity; no approximation, no parity claim.`

The owner-side path remains: supply a matched-camera donor GPU A/B frame + manifest, retire the nine P0 packets, and rule zero-mismatch on that pair. Nothing further I can do under the read-only rule advances it.
