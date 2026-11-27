---
id: PORT1TO1-CHECKLIST-FINAL-2026-11-27
title: "FINAL owner checklist — full 1:1 Cossacks 3 donor port (post-final-wave, compact)"
worker: CHECKLIST-FINAL (read-only subagent)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-27
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION__NO_PARITY_CLAIM
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_checklist_final.md
files_created: [docs/terrain_swarm_2026-11-26/reports/PORT1TO1_checklist_final.md]
files_edited: []
scope_guard: "Repo file/line reads plus read-only Test-Path and read-only Get-FileHash -Algorithm SHA256 over existing repo files only. No source/shader/config/asset/test/fixture/result-JSON/backup/queue change; no git operation, no Godot process/runner job/gate/capture/ROI metric, no donor binary opened/hashed/executed/captured, no donor GPU A/B frame. Exactly one repository file written: this report."
labels: [SIGNOFF_CHECKLIST, OBSERVED, PRESERVE_ONLY, OWNER_ONLY_PACKETS, "PORT APPROXIMATION", PARITY_UNVERIFIED, RESULT_IS_NOT_GOOD, NO_PARITY_CLAIM]
parity_status: UNVERIFIED
parity_claim: NONE
visual_parity_claim: false
verdict: "RESULT IS NOT GOOD — blocking_unverified is non-empty (nine P0 rows OPEN plus domain tails, D4 included unless explicitly excluded); six-condition chain 0/6 CLOSED (conditions 2 and 6 PARTIAL, port-internal only; 1/3/4/5 BLOCKED); 71 open [U] (A42/B14/C5/D10); no donor GPU A/B frame; no COORD ruling; no approximations; no parity claim."
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
supersedes_for_navigation: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_handoff_checklist.md
governing_sources:
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_handoff_checklist.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_owner_brief2.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_u_register2.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_p0_final_status.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_p0_packet_index.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_counts_sync.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_hash_manifest.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_final_gates.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_chain_update2.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_claim_recheck6.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_claim_recheck7.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_handoff_sync.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_handoff_check2.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_index_final3.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_b_angle_final.md
---

# PORT1TO1 — FINAL owner checklist (2026-11-27)

> **Mandatory reviewer line (verbatim):** PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

> **How to read.** Compact sign-off index over already-landed reports, not a new verdict, gate pass or parity claim. **Every checkbox is deliberately unchecked**: no parity box is marked complete anywhere in this document. A `[ ]` means "COORD/owner must sign", not "failed" and not "closed". States are transcribed from cited artifacts plus read-only existence/hash checks made for this report. Paths are repo-relative with forward slashes; `reports/` means `docs/terrain_swarm_2026-11-26/reports/`.

## 0. Standing rules (apply to every section)

- [ ] Parity stays `parity.status = UNVERIFIED`, `parity.claim = NONE`, `visual_parity_claim = false`; six-condition chain **0/6 CLOSED** (conditions 2 and 6 PARTIAL port-internal only; 1/3/4/5 BLOCKED — `chain_update2.md:15/51/71`, `counts_sync.md:41`).
- [ ] Verdict stays **`RESULT IS NOT GOOD`** while `blocking_unverified` is non-empty (nine P0 rows + domain tails, D4 included unless explicitly excluded — `counts_sync.md:43`, `u_register2.md:37/178/190`). `RESULT IS GOOD` is admissible only when `blocking_unverified = []` and all six conditions hold — not today.
- [ ] Forbidden actions remain forbidden: no `--ignore-history`, no result-JSON deletion/hand-edited status, no `reset`/`doctor`/`cancel`/`unwedge`, no retry-until-green, no threshold/assertion change, no I11 re-application, no preserve-only flag flip, no donor binary execution (`handoff_checklist.md:44`, `acceptance_runbook.md:54/320`).
- [ ] Ack ≠ pass: tickets 575/582/585 remain owner-only and UNACKED; no worker ack and no gate pass inferred from an ack (`final_gates.md:123`, `handoff_check2.md:68`).
- [ ] No approximation endorsed: all `PORT APPROXIMATION` / `[U]` labels and P0 hard-fails intact; no `[D]` static fact promoted to a value/behaviour/gate/parity (`claim_recheck7.md:54`, `u_register2.md:45-48`).
- [ ] No item in §1–§4 closes donor parity. Every packet/session is owner/COORD-only and closes nothing by itself; workers are forbidden from donor execution (`p0_packet_index.md:26/52-55`).

## 1. Preserve-only items — current hash / witness (baseline vs point-in-time)

Hash method this pass: read-only `Get-FileHash -LiteralPath <file> -Algorithm SHA256`, lowercase, one read at 2026-11-27. **Hashes certify byte identity only, never donor fidelity** (`hash_manifest.md:32-37`). "Baseline-matched" = equals a previously recorded baseline; "point-in-time" = no recorded baseline; "prefix mismatch" = current hash differs from a recorded prefix, an identity/hygiene finding only, not a parity result or a gate failure. Never flip, revert, overwrite, "repair", re-apply or re-hash-as-proof any of these (`owner_decisions.md:328/340`).

- [ ] **P-2** `variant3d/config_donor_capture.json` — keep `backend=donor`, `demo_mill=true`, water `alpha_confine=true`/`shore_prox=false`. Current `aa857480474399dc4674104744ea292bf84094d8321cdd4d0889c24cf9a202da` (17,912 B) = **baseline-matched P-2** (`owner_decisions.md:333`, `hash_manifest.md:53`). Byte-identical to recorded witness at this read.
- [ ] **P-4a** `inbox/backup/main.gd.bak-COORD-I11` — single-applied I11 seam witness. Current `3859b6056bfdfdd5a659931835fd0901dd03db36b02a453389d9338bac9e71f8` (86,133 B) = **baseline-matched P-4a / V11 E1**.
- [ ] **P-4b** `inbox/backup/world3d.gd.bak-COORD-I11` — single-applied I11 seam witness. Current `44ee96c0dcfb35558f6ea3e0493e8f8faa1cadf6e155beb38031a9b11e1ab07a` (37,084 B) = **baseline-matched P-4b / V11 E2**.
- [ ] **P-1** `variant3d/config.json` — keep `backend=donor`, `color_unify=true`, `fov_deg=17.27` (PORT APPROXIMATION), numeric overrides, comments. Current `223767e57b506577ead54633708380a425a0b8aa439c8e3c28478c15c8ed44e2` (15,981 B) — **point-in-time, no recorded baseline** (`hash_manifest.md:52/113`). Do not flip backend to `legacy` to hide a defect.
- [ ] **P-3** `variant3d/assets/models/manifest.json` — keep `ukr/buildings`, EUR aliases, `field` conversions; rollback by id only, never whole-file restore. Current `36f6a378548f3116dc1585d7cdd34526a17b5c46d1ded02e3a93c7c736f22731` (339,158 B) — **point-in-time, no recorded baseline** (`hash_manifest.md:54/113`).
- [ ] **P-9 baseline-matched tools (2 of 6):** `variant3d/tools/build_terrain_new_atlas.py` `3a92d053a3e361001fc305f0dbd98681702ba756124566d4408bbcfda99904ff` (= recorded `3A92D053`); `variant3d/tools/terrain_qa_harness.py` `5a3b9e772f0be82330f4a0e6f42d4e1b36909815a3e79ecaba9f6e311c5d8492` (= `5A3B9E77`) (`V90_static_syntax_seal.md:181-182`).
- [ ] **P-9 prefix-mismatch tools (4 of 6) — open hygiene finding:** `variant3d/tools/decode_donor_cfg.py` `79bc8179fe7e5a5b00c303cc0b1e9ec9764a080a612c71ff57f0a40f59b84c47` vs recorded `ABBF0571`; `decode_pattern_lib.py` `faa3b2e9f0e97938902b0fcbec9326717f84ebe85490cff8c769bf84f86716ad` vs `DDFB8688`; `decode_donor_pattern.py` `fb1f2f72615b9483a18a6f5eb53c8c78b03a8c8b2c2b6beb4c066f1f201e6679` vs `00C0591A`; `decode_donor_masks.py` `4c64073281bb30b56691224616251f342f5f92a414e2708761ca891f39f9ea56` vs `667B71FB`. `handoff_sync.md:53` records these as **stale recorded prefixes** (files byte-identical to HEAD); no re-baseline or revert is authorised by this checklist. COORD must establish provenance and independently re-run `py_compile` at A′-1 on the frozen tree (`owner_decisions.md:340`, `V102_final_blockers.md:68`).
- [ ] **I11 seam live files (no recorded baseline; point-in-time only):** `variant3d/scripts/world3d.gd` `0a1f231930b2d39f5e486b47c37f327c9d343013162e00160ce4383894b36901` — unchanged from the earlier checklist reading. `variant3d/scripts/main.gd` current `94c610479b1df594c648e1aa236cbfdcdcc695319dbbcc5f9c86fb1939619ef6` — **drifted** from `93faea93…` transcribed at `handoff_checklist.md:81`; provenance not established by this read-in, COORD to adjudicate in the before/after hash table (see §5). The two **backup** witnesses in P-4a/P-4b remain the baselines; both still baseline-matched.
- [ ] **Rule-only preserve items (no per-file hash baseline):** P-5 shader/mesh opt-ins (`scene_color=vec3(0.2)`, `sampler2DArray tile_array`, `tile_map` binding, neutral `color_unify_gain=vec3(1.0)`, specular zero, CPU-baked `uv0/uv1`), P-6 v5 save keys (additive-only, restore `>=5`), P-7 stale ghost test/assets, P-8 preserved donor contradictions (`TileSmoothPasses=6` vs `SmoothTileMap(...,3)`, swamp 17×20/18×23, `alphanull`, `specular_rgb` effective `vec3(0)`, `lake_big := plain*2*0`, demo-mill/fields/stands), P-9 gate hygiene. Witnesses `owner_decisions.md:336-340`, `c_decisions.md:106-110`. No value change permitted; guard PASS is not a hash baseline.
- [ ] **Donor pin witness (report id only):** `X59_donor_bytes_seal`, pin `t_87f0f3c130b0` (`C:\Games\Cossacks 3\cossacks.exe`); recorded donor-side hash `87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c` **quoted from the report, not re-hashed here**. This worker did not open, hash, execute, copy or capture the donor binary; never an admissible A/B frame (`hash_manifest.md:37/67/120`).
- [ ] **Capture-time rule:** hash every §1 item **before and after every capture**; a changed witness invalidates that run; never use `--ignore-history` (`acceptance_runbook.md:78-95`). No `[U]` may be wired as a value.

## 2. Verification artifacts — exact path and state

States transcribed from cited reports; read-only `Test-Path` this pass confirmed presence for each named path. **File presence and a `PASS` string are evidence of that file's own scope only** (`final_gates.md:40`); none promotes parity.

- [ ] `variant3d/selftest.json` — **PASS (port-internal)** 29/29, `passed=true`, `parity` ABSENT; blocking red GR-A03 only when COORD runs it with a fresh mtime-after-START envelope (`final_gates.md:59`).
- [ ] `variant3d/uitest.json` — **PASS (port-internal)** 17/17, `parity` ABSENT; UI flow only (`final_gates.md:60`).
- [ ] `variant3d/tests/results/t_render_mode.json` — PASS (port-internal) 10 checks, `seam_missing=false`, `parity` ABSENT (`final_gates.md:61`).
- [ ] `variant3d/tests/results/t_map_variety.json` — PASS (port-internal) 5/5 incl. `same_seed_byte_identical`; self-repeat, not a donor match (`final_gates.md:62`).
- [ ] `variant3d/tests/results/t_terrain_donor.json` — **class-A structural PASS 26/26 with all 18 class-B advisories UNVERIFIED**; self-denies parity (`parity.claim=NONE`, `parity.status=UNVERIFIED`, `visual_parity_claim=false`, `:518-522`). Highest misread risk: `status=PASS` is not a parity proof (`final_gates.md:63`).
- [ ] `variant3d/tests/results/summary.json` — PASS (stale aggregate) 19/19, mtime 2026-11-21; advisory (`final_gates.md:64`).
- [ ] `variant3d/tests/t_final_gate.gd` — advisory probe, **no result JSON on disk**; any printed `FINAL_GATE n/m` is not parity (`final_gates.md:65`).
- [ ] `variant3d/tests/manifest.json` — 41 registered test ids; registration present, not a gate PASS (`final_gates.md:66`).
- [ ] `docs/terrain_swarm_2026-11-26/spec/terrain_qa_spec.json` — **SCHEMA-ONLY / UNPOPULATED**, advisory (`final_gates.md:67`).
- [ ] `inbox/qa/captures/repcheck_20261113/repeat_verification.json` — **PASS (port-internal repeatability)**: `byte_identical=true`, 1280×720, 64 ticks, seed `20261113`, `kind="port-internal repeatability gate (NOT donor parity)"`, `parity="UNVERIFIED (not assessed)"`. Chain condition 6 → PARTIAL, not CLOSED (`final_gates.md:78`).
- [ ] `inbox/qa/captures/detcheck_20261113/manifest.json` and `inbox/qa/captures/detcheck2_20261113/manifest.json` — two COORD runs, byte-identical per-frame `sha256_pixels` (`def18ad9…`, `18e1e72…`); both `parity=UNVERIFIED`; opt-in deterministic mode only, no donor A/B or `[U]` closure (`final_gates.md:81-83`).
- [ ] `inbox/qa/captures/finalcheck_20261127/manifest.json`, `.../repeat_verification.json`, `inbox/qa/captures/finalcheck_20261127_repeat/manifest.json` — **PRESENT**, port-internal final repeatability; identity recorded at `hash_manifest.md:89-91`; not re-adjudicated here (`handoff_checklist.md:105`).
- [ ] `variant3d/tools/acceptance/compare_frames.py` — **14 invocations, 14/14 exit 0, 0 refusals**; always prints `parity=UNVERIFIED` (`final_gates.md:91`).
- [ ] `inbox/qa/captures/roi_metrics_20261113/` — 14 diff PNGs + 14 metrics JSONs (R01–R14); each `parity="UNVERIFIED"`, `claim=null`, `camera=NOT_SHARED_donor-oblique_vs_port-17p27`; support cues only (`final_gates.md:92`).
- [ ] `reports/PORT1TO1_roi_metrics.md` / `reports/PORT1TO1_roi_register.md` — 14 UNVERIFIED rows; mandatory `NOT_SHARED` marker asserts no shared camera (`final_gates.md:92-94`).
- [ ] `variant3d/tools/compare_shots.py` — candidate-vs-candidate at pinned camera; threshold 0.80 smoke placeholder, advisory (`internal_validation.md:95`). `variant3d/tools/terrain_ab_metric.py` — SMOKE only, "NOT a fidelity gate or donor proof" (`internal_validation.md:96`).
- [ ] `variant3d/tests/t_mcp_host.gd` — **PASS (port-internal, live)**: `cossacksgodotmcp`, protocol `2025-03-26`, exactly 6 tools (`game.status`, `game.tick`, `camera.pan_to`, `game.screenshot`, `game.place_building`, `video.record_frames`); `game.tick({})` clean refusal; no parity field (`final_gates.md:104-107`).
- [ ] Parse checks — "All 18 edited GDScript files pass `--check-only`"; `reports/V90_static_syntax_seal.md` **PASS (static only)** 13/13; Godot parse/smoke explicitly NOT run by that worker (`final_gates.md:113-114`). `variant3d/.godot_queue/results/00000133.json` is `--check-only`, not verification (`claim_recheck7.md:51`).
- [ ] Ticket 575 `bbclamptidy01-parse` — timed out, exit −9, 302.44/300 s, `SCRIPT ERROR 0`; **NOT a passing gate and NOT a parse proof; UNACKED** (`final_gates.md:115`).
- [ ] `inbox/qa/captures/fullport6_seq2_20261113/manifest.json` + `contact.json` — `status=ok`, `deterministic=true`, `headless=false`, `parity=UNVERIFIED`; `contact.png` `exact_pixels_preserved=true`; port-internal only (`internal_validation.md:88-91`).
- [ ] `cap_fullport6.png` / `cap_fullport7.png` / `cap_fullport8.png` — reported rendered clean apart from the deliberate water U12/U4* hard-fail; **read-only audits found them absent on disk** (`parity_chain.md:52`, `parity_recheck.md:57`). Discrepancy preserved verbatim, neither resolved nor repaired.
- [ ] `reports/PORT1TO1_final_guard_audit.md` + `reports/PORT1TO1_claim_final.md` — PASS in all four guard areas with MINOR label gaps (GF1–GF3); C1–C5 sweep: **no live unguarded parity claim** in `reports/` or `variant3d/` (`internal_validation.md:128-131`, `claim_final.md:80-83`). `claim_recheck6.md:52-61` and `claim_recheck7.md:47-54` re-confirm C1–C5 NONE after the final wave and label fixes.
- [ ] `reports/PORT1TO1_hash_manifest.md` — point-in-time SHA-256 identity for the minimal owner bundle; three recorded baselines matched at that read; donor pin by report id only; no parity decision (`hash_manifest.md:112-124`).
- [ ] Final claim/audit set — `reports/PORT1TO1_owner_brief2.md`, `..._u_register2.md`, `..._p0_final_status.md`, `..._chain_update2.md`, `..._index_final3.md`, `..._counts_sync.md`, `..._handoff_sync.md`, `..._handoff_check2.md`, `..._claim_recheck6.md`, `..._claim_recheck7.md`, `..._b_angle_final.md`, `..._evidence_index.md` (+ addendum/deep supplement) — each carries `parity=UNVERIFIED` / `parity.claim=NONE` / `visual_parity_claim=false` and `RESULT IS NOT GOOD`; none promotes a `[D]`, a gate or a metric (`claim_recheck7.md:60-69`, `counts_sync.md:97-101`).

## 3. Nine P0 rows — packet paths, all OPEN (no row CLOSED, no row PARTIAL)

Paths relative to `reports/`. **Seven distinct packets cover nine rows** (water packet covers rows 1–3); each is an owner-only run-book that closes nothing by itself; a row retires only on its own zero-mismatch capture/harness (`p0_packet_index.md:26`, `p0_final_status.md:40/63`). All rows `[U]`, hard-fails/labels intact. **P0-7 now has a dedicated packet** (the earlier checklist's "no dedicated packet" is superseded — `counts_sync.md:87`).

- [ ] **1 — P0-1 / W-U12** (static narrowing only; no water drawn; U12 reflection hard-fail) — packet `PORT1TO1_water_owner_protocol.md` / S1 Ph3. Owner GPU session: classify (a) FBO / (b) `glCopyTexImage2D` dst / (c) static upload; dump `(provenance,name,w,h,unit,matrix)`, 0 mismatches across ≥2 water-visible frames + 1 camera move.
- [ ] **2 — P0-1b / W-U4\*** (structure closed, value open; UNSET gate, no default) — packet `PORT1TO1_water_owner_protocol.md` / S1 Ph2. Break `FUN_00851bdc`, hook S1–S11/W0/W1/S10/S11 uniform tuple, 0 ULP across 2 frames + move.
- [ ] **3 — P0-2 / W-U1,U3,U5,U6** (structure closed, value open; `±2.96` labelled U3 substitutes) — packet `PORT1TO1_water_owner_protocol.md` / S1 Ph1/4/5/6. `glShaderSource` + 30-key uniform log, live `(W,H,Min,Max)`, UV/cull state, 0 differing bits across ≥2 frames + move.
- [ ] **4 — P0-3 / F-GRID a–e + persistence + occlusion + tint** (static narrowing only; provisional `1 res = 1 m`) — packet `PORT1TO1_fow_owner_protocol.md` / S2. Seed `20261113` reveal transects, `GetFOWLOSData` dumps, 0 mismatching cells ×3.
- [ ] **5 — P0-4 / S-TICK-O1 + D1–D3** (static narrowing only; `TICK_ORDER v1` labelled PORT APPROXIMATION) — packet `PORT1TO1_tick_owner_protocol.md` / S6. Headless fixed-dt harness, 12 players × 3600 frames × 3 seeds × 6 sequences, one byte-identical order surviving.
- [ ] **6 — P0-5 / E-B1…B4, C1, C2 + W/S/A/R** (structure closed, value open; no interpolation) — packet `PORT1TO1_blend_owner_protocol.md` / S3. 30 Hz stepped 3/3 byte-identical trials, `(0,0)` hard-cut control.
- [ ] **7 — P0-6 / S-SAVE-R1a…g** (structure closed, value open; PORT EXTENSION, v5 additive-only) — packet `PORT1TO1_save_owner_protocol.md` / S5. Paired known-state `.map` saves, one field varied, re-save byte-identical, 3 repeats.
- [ ] **8 — P0-7 / S-RNG-G1** (algebra closed, attribution/counts open; `[U]-G1`) — packet `PORT1TO1_rng_owner_protocol.md` / S7. Full R20/L20/C300/U50/F1M/K0/A600 vs X21 oracle `(0x44A108F9,0x00000001)`, 0 mismatches; L2 state-dump breakpoints (not a GPU frame).
- [ ] **9 — P0-8 / E-U13 + F-V1/V2** (static narrowing only; `FOV 17.27°` PORT APPROXIMATION) — packet `PORT1TO1_selection_owner_protocol.md` / S4. Fixed `58 m / −32° / focal 400`, ≥5 surveyed markers → 0 px, pick/membership 0 mismatches incl. exact ties + FOW veto.
- [ ] **Non-P0 parity-invalidating tails remain open** (`u_register2.md`: 71 open `[U]` = A42/B14/C5/D10; D4 stays `[U]`, NOT CLOSED unless all four out-of-scope conditions recorded; `U-base-speed` is a split id, not a 72nd row — `counts_sync.md:85`). None is promoted; none closes a P0.
- [ ] **The only actor that could start changing the verdict** is an owner-authorised Route A donor GPU frame with a matched camera/ROI manifest (`final_gates.md §8`, `X39_ab_feasibility.md §3`). Necessary but not sufficient; workers are forbidden from executing the donor. **No such frame exists.**

## 4. Canonical verdict string

Verbatim governing block from `reports/PORT1TO1_owner_brief2.md:85-97`, declared canonical by `reports/PORT1TO1_handoff_check2.md:80` (identical to `owner_brief.md:84-92` and `decision_sim.md:132-140`; other reports use shorter/parameterized forms, none semantically different):

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

- [ ] Use exactly one verdict; given the current tree this is the only admissible one. Forbidden phrasing at all times: "matches donor", "close to donor", "donor parity", "similarity %", "donor threshold PASS", "gate PASS" derived from a capture, or `--assert-ab-verified`/a parse check treated as verification (`owner_brief2.md:99`).
- [ ] **EXPLICIT STATEMENT — NO ITEM ON THIS CHECKLIST CLOSES DONOR PARITY.** §1 preserves bytes; §2 inventories port-internal artifacts; §3 lists owner-only experiments. None supplies a donor GPU A/B frame, matched camera/ROI manifest, fresh COORD-ruled gates with 575/582/585 acknowledged, `blocking_unverified = []`, or a COORD-signed zero-mismatch geometry+frame ruling. Chain remains 0/6 (two PARTIAL, four BLOCKED).
- [ ] Final sign-off state: `parity.status = UNVERIFIED`; `parity.claim = NONE`; `visual_parity_claim = false`; chain **0/6**; **9 P0 rows OPEN**; **71 open `[U]`**; **`RESULT IS NOT GOOD` while `blocking_unverified` is non-empty**; no approximation adopted; no parity claim; no test weakened; no donor binary executed.

## 5. What changed since `PORT1TO1_handoff_checklist.md` (short)

- [ ] **P0 count and packets:** 8 → **9 rows**; P0-7 (S-RNG-G1) gained its dedicated packet `PORT1TO1_rng_owner_protocol.md`; "six packets + one P0 with no dedicated packet" → **seven packets, no P0 without a packet** (`counts_sync.md:87`, `owner_brief2.md:63`).
- [ ] **Final-wave reports landed:** `owner_brief2`, `u_register2`, `index_final3`, `chain_update2`, `p0_sync2`, `p0_final_status`, `counts_sync`, `handoff_check2`, `claim_recheck6`, `claim_recheck7`, `b_angle_final` — final brief / definitive register / final index / verdict set. Governing counts confirmed unchanged: **71 open `[U]` (A42/B14/C5/D10), 9 P0 OPEN, chain 0/6, plan 260 sequential tasks** (`counts_sync.md:37-46`).
- [ ] **Randkey / copy-map implementations:** `IMPL-RANDKEY-DERIV` (NB-4 `GenerateMapRandKey`: `randkey0=0`, `randkey1=Random($7FFFFFFF)`, slot `+0x18/+0x1c`) and `IMPL-QUAD-COPY` (NB-5 two 32-B `rep movsd` row lifts + 4-iteration scatter) are **telemetry/label-only, "NEVER read by generation", no geometry/sim/generation change**; every live value stays `[U]` (`owner_brief2.md:41-42`, `u_register2.md:99/101`).
- [ ] **B-angle final + NB1…NB7:** original class-B **14/14 executed** (B4/B5 partial), new NB **6/7**; NB-4 is the only new numeric `[D]`, NB-2 supplies parser field defaults. NB-1 index-vs-worker numbering collision (index-NB-1 U-REG-TEX vs NB-6/`DEC-U-NB1` TOSW ctor sweep) is **preserved, no silent renumber**; NB-5's "PENDING" label in `b_angle_final` is stale (report landed, static chain CLOSED `[D]`, `U-10b` value still `[U]`) — label-only, no class-A item closed (`b_angle_final.md:79-93`, `counts_sync.md:83-84`).
- [ ] **HANDOFF point-in-time fixes:** `handoff_sync.md` syncs the post-§9.22 band (187→235 then 187→260) and records the start-camera supersession (wire found at `doprogress.inc:41`, 2D+3D wire IMPLEMENTED with no new FOV/zoom/height constant); `handoff_check2.md:35-58` logs stale count/status/point-in-time claims (S1–S3, camera focus, plan snapshots) with **label-only** proposed fixes, none applied by that worker.
- [ ] **Label hardening:** `claim_recheck6.md` logged 4 new guarded label risks (GAP-6N1…6N4); per `claim_recheck7.md:28-39`, COORD then retitled the `owner_brief2` heading, hardened two `u_register2` `CLOSED [D]` pointer labels and the `CLOSED-NEGATIVE-refuted` label, fixed the plan row note, and `LABEL-HARDEN` added static/no-parity qualifiers at `variant3d/scripts/terrain_donor_gen.gd:116` and `terrain_donor_mesh.gd:1942` — **no value/behaviour/gate change**. C1–C5 remain NONE unguarded (`claim_recheck7.md:47-54`).
- [ ] **Observed hash drift (identity only):** live `variant3d/scripts/main.gd` now reads `94c610479b1df594c648e1aa236cbfdcdcc695319dbbcc5f9c86fb1939619ef6`, differing from `93faea93…` transcribed at `handoff_checklist.md:81`; `world3d.gd` and all five P-1/P-2/P-3/P-4a/P-4b witnesses are unchanged and still match their recorded values. Provenance of the `main.gd` difference is **not established by this read-in** — COORD to adjudicate and record before/after values at capture. **No parity, defect or gate conclusion attaches to this observation.**
- [ ] **Unchanged:** no donor GPU A/B frame, no matched camera, no COORD ruling; all nine P0 rows OPEN; no approximation, no parity claim.

## 6. Claim register (this report)

| # | Claim | Label / source |
|---|---|---|
| 1 | Preserve-only set P-1…P-9, six P-9 tool hashes, I11 seam live files and donor pin inventoried with current read-only SHA-256; baseline-matched vs point-in-time distinguished | [O] `Get-FileHash` this pass; `hash_manifest.md:48-67`, `c_decisions.md:100-114` |
| 2 | Five witnesses unchanged; four P-9 tool prefixes differ from recorded values (hygiene only); live `main.gd` drifted from earlier transcription, provenance unresolved | [O] this pass vs `handoff_checklist.md:54-58/70-71/81`, `handoff_sync.md:53` |
| 3 | Verification artifacts in §2 are port-internal with explicit parity denials; none promotes parity | [O]/[D] `final_gates.md:42-134`, `claim_recheck7.md:47-54` |
| 4 | Nine P0 rows OPEN; seven owner packets; all packet files present on disk | [D] `p0_final_status.md:47-63`, `counts_sync.md:60/87`, read-only `Test-Path` this pass |
| 5 | Canonical verdict block is `owner_brief2.md:85-97`, `RESULT IS NOT GOOD` while `blocking_unverified` non-empty | [D] `handoff_check2.md:75-80`, `counts_sync.md:43` |
| 6 | What changed since the earlier checklist: randkey/copy-map telemetry lanes, B-angle/NB final, final brief/register/index/verdict reports, HANDOFF point-in-time fixes, label hardening, P0-7 packet, observed `main.gd` drift | [D] §5 with cited reports |
| 7 | Read-only worker; exactly one repository file written; no code/Godot/git/donor execution; no parity box marked complete | [O] scope guard |

---

*End of PORT1TO1_checklist_final. Read-only final owner checklist; exactly one repository file written. Parity UNVERIFIED; `parity.claim = NONE`; visual parity claim false; six-condition chain 0/6; nine P0 rows OPEN; `RESULT IS NOT GOOD` while `blocking_unverified` is non-empty. No approximation, no parity claim, no box marked complete.*
