# PARITY_verify — read-only verification of the six-condition donor-parity chain (current tree, 2026-11-27)

- id: PARITY-VERIFY-2026-11-27
- worker: PARITY-VERIFY (read-only subagent)
- date: 2026-11-27
- status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION__NO_PARITY_CLAIM
- owner_file: docs/terrain_swarm_2026-11-26/reports/PARITY_verify.md
- files_created: [docs/terrain_swarm_2026-11-26/reports/PARITY_verify.md]
- files_edited: []
- scope_guard: "Repo/doc file and read-only manifest/JSON reads only. No source, shader, asset, config, test, fixture, result JSON, backup, queue, Godot process, runner job, gate, capture, ROI metric, git command, or donor binary was created, modified, opened, hashed, executed or compared. No donor GPU A/B frame was produced or compared. Exactly one repository file written: this report."
- parity_status: UNVERIFIED
- parity_claim: NONE
- visual_parity_claim: false
- chain: 0/6 CLOSED
- verdict: "RESULT IS NOT GOOD — blocking_unverified is non-empty; six-condition chain 0/6 CLOSED; no donor GPU A/B frame; no matched camera; parity UNVERIFIED."

> **Mandatory reviewer line (verbatim):** PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

## 0. Question answered

**Can RESULT become GOOD from any worker action in this environment? No.**

No worker with no donor GUI control and no donor execution can close any of the six conditions. Every closure requires an owner-supplied artifact (donor GPU run, owner manifest, owner/COORD ruling, owner-gated harness) listed in §3. Chain is 0/6; `blocking_unverified` is non-empty; RESULT IS NOT GOOD while it is non-empty. No approximation is proposed; no parity is claimed.

## 1. Six-condition audit — status, exact evidence, worker-closability

| # | Condition | Status | Exact evidence (current tree) | Can a worker with no donor GUI control and no donor execution close it? |
|---|---|---|---|---|
| 1 | Owner supplies a genuine same-size/seed/type/season/camera/ROI donor GPU frame | **BLOCKED** | `PORT1TO1_coord_ruling.md:44-45`: "There is no matched-camera donor GPU A/B frame in the tree." `PORT1TO1_parity_chain.md:51` + `PORT1TO1_owner_packet2.md:12-13`: no owner-supplied donor frame on disk or named in any report. `WATER_static_scalars.md:17-22`, `PORT1TO1_p0_final_status.md:52-61` rows 1-3: water live tuple needs a donor GPU/debugger session. `PORT1TO1_claim_recheck17.md:99`: "no donor GPU A/B frame; no matched camera." | **No.** Donor binaries are read-only and never executed; there is no desktop-input tool to drive Cossacks 3; public videos are not matched evidence. Only an owner-run donor session can create the artifact. |
| 2 | An admissible non-blank 1280×720 candidate capture, script_error_lines=0, pinned seed/camera/size, identical ROI | **PARTIAL (port-internal only)** | `inbox/qa/captures/gateext_repeat_20261127/manifest.json:22,31,36,44-80`: windowed seq, 2 frames 1280×720, seed 20261113, status ok, parity UNVERIFIED. `inbox/qa/captures/gateext_repeat_20261127/repeat_verification.json:2,69,71,77`: byte_identical true, kind "port-internal repeatability gate (NOT donor parity)", parity "UNVERIFIED (not assessed)", status pass port-internal scope only. `PORT1TO1_coord_ruling.md:37-39`: ZERO MISMATCH only between port capture and port repeat; "closes nothing beyond condition 6's port-internal PARTIAL state. It is not a donor comparison." `PORT1TO1_final_sync.md:48-49`: both repeats labelled port-internal; no capture promotes parity. | **No (as a parity closure).** A worker can re-run port-internal repeats, but a repeat only re-proves port-vs-port byte equality. Admissibility for parity requires pairing with a real donor frame at the same ROI, which does not exist. |
| 3 | Inputs matched and labelled (same keys/size/type/season/camera/ROI manifest, or importer-rendered same geometry) | **BLOCKED** | `PORT1TO1_owner_packet2.md:16-31`: all nine P0 packets specify owner/COORD-only experiments; "Every experiment is owner/COORD-only; workers forbidden." `PORT1TO1_p0_final_status.md:49`: "every experiment is forbidden to workers (read-only charter)." P0-8 (`PORT1TO1_selection_owner_protocol.md` / S4): fixed 58 m/−32°/focal 400 rig with ≥5 owner-surveyed markers, 0-px reprojection — no such owner manifest exists in tree. Camera stays PORT CHOICE/APPROX (`PORT1TO1_owner_packet2.md:39`: zoom 0.75 PORT CHOICE, 17.27° PORT APPROXIMATION). | **No.** No worker can survey owner markers, pin the donor camera, or emit the matched-input manifest. Requires the owner manifest. |
| 4 | Fresh gates green, not stale, 575/582/585 acknowledged with evidence-backed reasons, app/** byte-identical, assert_clean CLEAN | **BLOCKED** | `PORT1TO1_coord_ruling.md:28-32`: 575 (`bbclamptidy01-parse`, timed-out exit −9, 302.44 s), 582 (`terrainswarm-g1-selftest`, skipped, run 0.0), 585 (`g04-uitest`, timed-out exit −9, 308.44 s) were RETIRED via reconstructed `reconstructed:true` JSONs with canonical owner reason strings — "explicitly NOT passing gates, NOT a parse proof, NOT a green selftest, NOT a green uitest." "This removes the `acknowledged>=3` prerequisite of GR-A00 but does not itself make any gate green." `PORT1TO1_coord_ruling.md:48`: condition 4 still red (needs app/** integrity + assert_clean CLEAN; ack prerequisite only now met). `PORT1TO1_final_sync.md:53-54`: exactly one BLOCKED owner row (186); no gate/metric promotes parity. | **No.** Retirement was a ticket-queue prerequisite only. A green gate needs a fresh owner/COORD gate battery (A′-0…A′-3 then D-0…D-6, unique job ids, D1 5 streams×3 sizes zero-byte dumps, D3 script_error_lines=0, 29/29+17/17+render-mode+5/5 variety+scan_map ALL GREEN) plus app/** integrity — owner/COORD-only. |
| 5 | Spec/toolchain evidence completed and `blocking_unverified = []` | **BLOCKED** | `PORT1TO1_owner_packet2.md:62-76` canonical verdict: blocking_unverified = [PT-V1..V7, P0-1, P0-1b, P0-2, P0-3, P0-4, P0-5, P0-6, P0-7, P0-8, W-R1, T-SEED, T-CALLBACK, atlas-layout, X17, U-INJ-1..11, plus domain residuals] — non-empty. `PORT1TO1_p0_final_status.md:51-61`: all nine P0 rows OPEN (structure-closed/value-open, static-narrowing-only, or algebra-closed/attribution-open); `CLOSED` appears for no row. `WATER_static_scalars.md:17-22,182-211`: no live water scalar bindable statically; UNSET [U4*] hard-fail correct and must be kept. `PORT1TO1_u_classify.md` (via `PORT1TO1_p0_sync2.md`/`PORT1TO1_u_register2.md`): 71 open [U] (A42/B14/C5/D10). | **No.** Static [D] facts only narrow experiments; the register rules state a structural/absence closure is never a value closure. Emptying blocking_unverified requires the nine owner zero-mismatch captures/harnesses. |
| 6 | Demonstrated byte-identical geometry + pixel-identical frame under the proven-matched manifest, ruled by COORD explicitly | **PARTIAL (port-internal repeatability only); COORD ruling = NOT ASSESSABLE on donor pixels** | `PORT1TO1_coord_ruling.md:44-45`: "A COORD ruling on donor-vs-port pixels requires an artifact that does not exist. Ruling: NOT ASSESSABLE." `PORT1TO1_coord_ruling.md:37-39,53-54`: zero-mismatch ruled ONLY port-capture-vs-port-repeat at pixel-byte and sequence-index level; closes nothing beyond condition 6 PARTIAL. `PORT1TO1_parity_chain.md:56`: no COORD donor ruling exists; V109:91 requires explicit COORD ruling. `PORT1TO1_claim_recheck17.md:99-100`: chain 0/6; "no COORD ruling." | **No.** A worker cannot rule donor-vs-port equality without the matched pair. The only worker-reachable act (another port-internal repeat) adds no parity. |

**Chain result: 0/6 CLOSED. Parity UNVERIFIED. RESULT IS NOT GOOD.**

## 2. Six required confirmations

1. **No matched-camera donor GPU A/B frame exists.** `PORT1TO1_coord_ruling.md:44-45`; `PORT1TO1_owner_packet2.md:62-76`; `PORT1TO1_final_sync.md:41-42`; `PORT1TO1_claim_recheck17.md:99`. No owner-supplied donor frame is on disk or named in any report.
2. **Deterministic repeats are port-internal only.** `gateext_repeat_20261127/repeat_verification.json:2,69,71` (byte_identical true; kind port-internal repeatability gate NOT donor parity; parity UNVERIFIED not assessed); `manifest.json:24-30` (repeat note "port-internal repeatability only; never donor parity"); `PORT1TO1_coord_ruling.md:37-39`; `PORT1TO1_final_sync.md:48-49`.
3. **Water scalars are runtime-only (no static binding).** `WATER_static_scalars.md:17-22` verdict "No" — every live scalar irreducibly requires runtime [U]; UNSET [U4*] hard-fail correct and must be kept. `§3.1-§3.5`: branch condition is a runtime pointer (return of `sub_853530`), zero float literals in `FUN_00851bdc`, callees undiscovered, feature-find 0 hits. `§5` per-scalar table: every Live cell [U]. `PORT1TO1_p0_final_status.md:53-55` rows P0-1/P0-1b/P0-2 all OPEN.
4. **Nine P0 rows are owner-gated.** `PORT1TO1_p0_final_status.md:51-61` all nine OPEN; `PORT1TO1_owner_packet2.md:16-31` exact packet paths S1–S7 with required owner actions; `PORT1TO1_coord_ruling.md:54` nine P0 rows OPEN; every experiment forbidden to workers.
5. **575/582/585 retirement does not make a gate green.** `PORT1TO1_coord_ruling.md:28-32,48`: reconstructed `reconstructed:true` JSONs record the documented failure (never a pass); retirement removes only the `acknowledged>=3` prerequisite of GR-A00; `status.json` history rows still absent; condition 4 still red.
6. **The COORD ruling ruled donor pixels NOT ASSESSABLE.** `PORT1TO1_coord_ruling.md:44-45` verbatim ruling "NOT ASSESSABLE" as the controlling parity gap (conditions 1, 3, 6); chain 0/6; §57 verdict `parity.claim=NONE; parity.status=UNVERIFIED; RESULT IS NOT GOOD — blocking_unverified non-empty`.

No synthetic shortcut is proposed. No approximation is adopted. No parity is claimed.

## 3. Exact canonical verdict line

```
RESULT IS NOT GOOD — blocking_unverified is non-empty; six-condition chain 0/6 CLOSED; nine P0 rows OPEN; 71 open [U] (A42/B14/C5/D10); no donor GPU A/B frame; no matched camera; no COORD donor ruling; parity.claim = NONE; parity.status = UNVERIFIED; visual_parity_claim = false; no approximation; no parity claim.
```

Reviewer line (verbatim, always attached): `PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.`

## 4. Precise list of owner-supplied artifacts required to flip RESULT to GOOD

RESULT becomes GOOD only when `blocking_unverified = []` and all six conditions close. Each item below is owner/COORD-only; no worker action substitutes. Packet paths relative to `docs/terrain_swarm_2026-11-26/reports/`.

1. **Matched-camera donor GPU A/B frame + camera manifest (conditions 1+2+3).** Owner-run donor PNG(s) outside the repo at the pinned rig (seed 20261113, 1280×720 windowed, fixed 58 m/−32°/focal 400, ≥5 surveyed markers) with a written key/camera/size/season/ROI manifest per `X39_ab_feasibility.md §3`; paired port capture with `status=ok`, `complete=true`, `resolution_observed=1280×720`, `script_error_lines=0`, pinned seed/camera/size, identical ROI.
2. **P0-1 / W-U12 zero-mismatch capture (`PORT1TO1_water_owner_protocol.md` S1 Ph3).** Classify U12 as (a) FBO / (b) `glCopyTexImage2D` dst / (c) static upload; dump `(target,name,w,h,unit,matrix)`; 0 mismatches across ≥2 water-visible frames + 1 camera move.
3. **P0-1b / W-U4* scalar-winner capture (S1 Ph2).** Break `FUN_00851bdc`, read the layer pointer, hook S1–S11/W0/W1/S10/S11 uniforms on the U1 program; prove bit-exact ENGINE-or-FILE tuple, 0 ULP over 2 frames + move.
4. **P0-2 / W-U1,U3,U5,U6 captures (S1 Ph1/4/5/6).** Program hash + 30-key uniform log, live `(W,H,Min,Max)` + GL texture history, `C+0xc8` write-watch, UV/index/cull dumps; 0 differing bits over ≥2 frames + move.
5. **P0-3 / FOW grid + persistence + tint transects (S2, `PORT1TO1_fow_owner_protocol.md`).** Seed-20261113 reveal transects (visions 0/3/8), overlap/removal/team-split, blocker and walk-away/reload arms + raw `GetFOWLOSData` dumps; one fitted linear scale with 0 mismatching cells/edges.
6. **P0-4 / tick-interleave hash harness (S6, `PORT1TO1_tick_owner_protocol.md`).** 12 players × 3600 frames × 3 seeds × restarts (idle/battle/forced-veto), permuting only block boundaries until one byte-identical order survives with 0 tick mismatches.
7. **P0-5 / blend + completion batteries (S3, `PORT1TO1_blend_owner_protocol.md`).** R-B1…B4/C1/C2 + R-W/S/A/R at 30 Hz stepped frames, 3/3 trials per sid, `(6,8)` vs forced `(0,0)`; byte-identical frame/hash tables, 0 mismatches.
8. **P0-6 / paired save containers (S5, `PORT1TO1_save_owner_protocol.md`).** Paired donor `.map` saves differing in exactly one field + identical-state re-save control at seed 20261113, 3 repeats; exactly the predicted word diverges at the predicted offset, all else byte-identical.
9. **P0-7 / RNG full-series oracle (S7, `PORT1TO1_rng_owner_protocol.md`).** R20/L20/C300/U50/F1M/K0/A600 series vs X21 oracle `(0x44A108F9, 0x00000001)` plus L2 state-dump breakpoints; exact S sequence, 0 mismatches all series.
10. **P0-8 / selection + projection solve (S4, `PORT1TO1_selection_owner_protocol.md`).** ≥5 surveyed markers reproject to 0 px; pick/AABB/drag/marquee/minimap probes to 0 mismatches incl. exact ties, 1-px edges, FOW veto; near/far/aspect/drag anchor/minimap quad closed.
11. **Fresh gate battery green (condition 4).** Owner/COORD A′-0…A′-3 then D-0…D-6 with unique job ids (D1 5 streams × 3 sizes zero-byte dumps; D3 `script_error_lines=0`); 29/29 + 17/17 + render-mode + 5/5 variety + `scan_map ALL GREEN`; 575/582/585 already retired with evidence-backed reasons; `app/**` byte-identical; `assert_clean` CLEAN.
12. **COORD donor-parity ruling on the matched pair (condition 6).** A COORD-signed owner report demonstrating geometry-byte equality and pixel-identical matched frame (zero mismatch) under the proven-matched manifest, explicitly ruling condition 6 — the ruling that `PORT1TO1_coord_ruling.md:44-45` declares NOT ASSESSABLE today.
13. **Owner policy decisions + preserve-only integrity.** D4 market scope ruled in/out; deferred-alias normalisation-vs-quarantine ruled; zoom 0.75 / FOV 17.27° adoption only on a 0-mismatch row by owner; every preserve-only witness hashed before/after every capture (P-1…P-9); no `[U]` wired as a value; no test/gate weakened.

Until every item above lands, `blocking_unverified` stays non-empty and RESULT stays NOT GOOD. Nothing in this environment lets a worker supply any of them.

*End of PARITY_verify. Read-only verification; exactly one repository file written; no code/Godot/git/donor execution; no approximation; parity UNVERIFIED; chain 0/6; RESULT IS NOT GOOD while blocking_unverified is non-empty.*
