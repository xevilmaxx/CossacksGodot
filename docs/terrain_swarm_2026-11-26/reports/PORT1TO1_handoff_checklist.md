---
id: PORT1TO1-HANDOFF-CHECKLIST-2026-11-27
title: "Final sign-off checklist — full 1:1 Cossacks 3 donor port (HANDOFF §9.16–9.21; plan task 181)"
worker: HANDOFF-CHECK (read-only subagent)
date: 2026-11-27
covers: "2026-11-26 owner handoff / final report set"
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_MUTATION_DONOR_EXECUTION
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_handoff_checklist.md
files_created: [docs/terrain_swarm_2026-11-26/reports/PORT1TO1_handoff_checklist.md]
files_edited: []
scope_guard: "Read-only repo file/line reads, read-only Test-Path, read-only Get-FileHash -Algorithm SHA256 over existing repo files, and two orientation-only read-only git status/branch queries. No code, Godot, runner subcommand, gate, capture, ROI metric, MCP probe, donor binary or donor GPU frame executed; no git mutation; no source/shader/config/asset/test/result-JSON/backup/queue change. Exactly one repository file written: this report."
labels: [SIGNOFF_CHECKLIST, OBSERVED, PRESERVE_ONLY, OWNER_ONLY_PACKETS, "PORT APPROXIMATION", PARITY_UNVERIFIED, NO_PARITY_CLAIM]
governing_sources:
  - docs/terrain_swarm_2026-11-26/HANDOFF.md (§9.16–§9.21)
  - docs/terrain_swarm_2026-11-26/PORT1TO1_PLAN.md (task 181)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_owner_brief.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_p0_packet_index.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_hash_manifest.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_final_gates.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_internal_validation.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_parity_chain.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_parity_recheck.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_claim_final.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_owner_decisions.md (§9–§10)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_acceptance_runbook.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_u_register_update.md
parity_status: UNVERIFIED
parity_claim: NONE
visual_parity_claim: false
verdict: "RESULT IS NOT GOOD — blocking_unverified is non-empty; six-condition chain 0/6 CLOSED; no donor GPU A/B frame; no approximations; no parity claim."
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
---

# PORT1TO1 — final handoff checklist (2026-11-27)

> **Mandatory reviewer line (verbatim):** PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

> **How to read this checklist.** It is a compact sign-off index over already-landed reports, not a new verdict, gate pass or parity claim. Every checkbox is deliberately **unchecked**: nothing here marks a parity item complete, retires a `[U]`, acknowledges a ticket or closes a chain condition. States are transcribed from cited artifacts, plus read-only existence/hash checks made for this report. A `[ ]` means "COORD/owner must sign", not "failed". Paths are repo-relative with forward slashes unless stated; `reports/` means `docs/terrain_swarm_2026-11-26/reports/`.

## 0. Standing rules (apply to every section)

- [ ] Confirm no item in §1–§4 closes donor parity. `parity.status = UNVERIFIED`, `parity.claim = NONE`, `visual_parity_claim = false`; six-condition chain **0/6 CLOSED** (condition 2 PARTIAL, condition 6 PARTIAL, conditions 1/3/4/5 BLOCKED — `parity_recheck.md:44-63`).
- [ ] Confirm the verdict stays `RESULT IS NOT GOOD` while `blocking_unverified` is non-empty (`owner_brief.md:14/94`, `final_gates.md:144/147`).
- [ ] Confirm forbidden actions remain forbidden: no `--ignore-history`, no result-JSON deletion, no `reset`/`doctor`/`cancel`/`unwedge`, no retry-until-green, no threshold/assertion change, no I11 re-application, no preserve-only flag flip, no donor binary execution (`acceptance_runbook.md:54/320`, `final_gates.md:130`).
- [ ] Confirm ack ≠ pass: tickets 575/582/585 remain UNACKED and owner-only; no worker ack, no claim of a gate pass from an ack (`final_gates.md:123`).
- [ ] Confirm no approximation is endorsed: all `PORT APPROXIMATION` / `[U]` labels and P0 hard-fails remain intact (`claim_final.md:80-83`, `u_register_update.md:206`).

## 1. Preserve-only items — current hash / witness / untouched verification

Hash method for this pass: read-only `Get-FileHash -LiteralPath <file> -Algorithm SHA256`, lowercase rendering, one read at 2026-11-27. Hashes certify **byte identity only**, never donor fidelity (`hash_manifest.md:32-37`). Rule: never flip, revert, overwrite, "repair" or re-apply any of these (`owner_decisions.md:328`; `acceptance_runbook.md:78-97`).

### 1.1 Recorded baseline present and CURRENTLY MATCHING

- [ ] **P-2** `variant3d/config_donor_capture.json` — keep `backend=donor`, `demo_mill=true`, water `alpha_confine=true`/`shore_prox=false`. Current: `aa857480474399dc4674104744ea292bf84094d8321cdd4d0889c24cf9a202da` (17,912 B) = recorded baseline (`owner_decisions.md:333`; `hash_manifest.md:53`). **Untouched verification: BYTE-IDENTICAL to recorded witness** at this read.
- [ ] **P-4a** `inbox/backup/main.gd.bak-COORD-I11` — single-applied I11 seam witness. Current: `3859b6056bfdfdd5a659931835fd0901dd03db36b02a453389d9338bac9e71f8` (86,133 B) = V11 E1 / V65 §8 baseline (`owner_decisions.md:335`; `hash_manifest.md:60`). **Untouched verification: BYTE-IDENTICAL.**
- [ ] **P-4b** `inbox/backup/world3d.gd.bak-COORD-I11` — single-applied I11 seam witness. Current: `44ee96c0dcfb35558f6ea3e0493e8f8faa1cadf6e155beb38031a9b11e1ab07a` (37,084 B) = V11 E2 baseline (`owner_decisions.md:335`; `hash_manifest.md:61`). **Untouched verification: BYTE-IDENTICAL.**
- [ ] **P-9 (2 of 6)** `variant3d/tools/build_terrain_new_atlas.py` current `3a92d053a3e361001fc305f0dbd98681702ba756124566d4408bbcfda99904ff` = recorded prefix `3A92D053` (`V90_static_syntax_seal.md:181`). **Untouched verification: BYTE-IDENTICAL.**
- [ ] **P-9 (2 of 6)** `variant3d/tools/terrain_qa_harness.py` current `5a3b9e772f0be82330f4a0e6f42d4e1b36909815a3e79ecaba9f6e311c5d8492` = recorded prefix `5A3B9E77` (`V90_static_syntax_seal.md:182`). **Untouched verification: BYTE-IDENTICAL.**

### 1.2 Recorded baseline present but CURRENTLY NOT MATCHING — open hygiene finding

- [ ] **P-9 (4 of 6)** `variant3d/tools/decode_donor_cfg.py` — current `79bc8179fe7e5a5b00c303cc0b1e9ec9764a080a612c71ff57f0a40f59b84c47`; recorded P-9 final-pass prefix `ABBF0571` (`V38_code_review_r2.md:49`, V55 E10, V90 §7:177, V102 P9:39). **Untouched verification: NOT ESTABLISHED — current prefix differs from recorded baseline.**
- [ ] **P-9 (4 of 6)** `variant3d/tools/decode_pattern_lib.py` — current `faa3b2e9f0e97938902b0fcbec9326717f84ebe85490cff8c769bf84f86716ad`; recorded prefix `DDFB8688` (`V90_static_syntax_seal.md:178`). **Untouched verification: NOT ESTABLISHED — prefix differs.**
- [ ] **P-9 (4 of 6)** `variant3d/tools/decode_donor_pattern.py` — current `fb1f2f72615b9483a18a6f5eb53c8c78b03a8c8b2c2b6beb4c066f1f201e6679`; recorded prefix `00C0591A` (`V90_static_syntax_seal.md:179`). **Untouched verification: NOT ESTABLISHED — prefix differs.**
- [ ] **P-9 (4 of 6)** `variant3d/tools/decode_donor_masks.py` — current `4c64073281bb30b56691224616251f342f5f92a414e2708761ca891f39f9ea56`; recorded prefix `667B71FB` (`V90_static_syntax_seal.md:180`). **Untouched verification: NOT ESTABLISHED — prefix differs.**
- [ ] COORD action on the four mismatches: establish provenance (later owner/COORD edit vs relocation vs drift) and re-baseline or restore **on the frozen tree at A′-1**, then independently re-run `py_compile`. Requirement: "COORD must independently re-run `py_compile` at A′-1 on the frozen tree; a landed report is not COORD's re-run" (`owner_decisions.md:340`, `V102_final_blockers.md:68`). This is an identity/hygiene finding only — it is **not** a parity result, not a gate failure and not a claim that any tool is faulty.

### 1.3 No recorded baseline — point-in-time identity only (must not be read as preservation proof)

- [ ] **P-1** `variant3d/config.json` — keep `backend=donor` (`:29`), `color_unify=true` (`:31`), `fov_deg=17.27` (labelled PORT APPROX), numeric overrides, comments. Current: `223767e57b506577ead54633708380a425a0b8aa439c8e3c28478c15c8ed44e2` (15,981 B) — matches the point-in-time reading in `hash_manifest.md:52` / `internal_validation.md:120`. **Untouched verification: NO RECORDED BASELINE; identical to prior reading only. Do not flip backend to `legacy` to hide a defect.**
- [ ] **P-3** `variant3d/assets/models/manifest.json` — keep `ukr/buildings` bucket, EUR aliases, `field` conversions; rollback by id only, never whole-file restore. Current: `36f6a378548f3116dc1585d7cdd34526a17b5c46d1ded02e3a93c7c736f22731` (339,158 B) — matches `hash_manifest.md:54` / `internal_validation.md:121`. **Untouched verification: NO RECORDED BASELINE; identical to prior reading only.**

### 1.4 Rule-only preserve items (no per-file baseline hash in cited reports)

- [ ] **P-5 Shader/mesh opt-ins** — keep `scene_color=vec3(0.2)`, `sampler2DArray tile_array`, `tile_map` binding, neutral `color_unify_gain=vec3(1.0)`, specular zero, loader/manifest atlas grid, and the documented CPU-baked `uv0/uv1` rewrite; do not silently remove or claim parity for it. Witness: `owner_decisions.md:336`, `DEC_U_port_guard_audit.md §3.1/§6`, backups `.bak-GLSTATE/.bak-RENDER1TO1/.bak-COLORSEAM/.bak-LIGHTMATCH/.bak-SUBCELLS`. **Untouched verification: guard PASS in `final_guard_audit.md` / `claim_final.md`; no per-file hash baseline — COORD must include in before/after hash table.**
- [ ] **P-6 v5 save keys** — `game.gd` `save_v5` `"version":5`, additive-only, restore `>=5`; no key removed/renamed/reordered/version-bumped. Witness: `owner_decisions.md:337`, `DEC_U_save_contract.md §9`, `parity_chain.md:103`. **Untouched verification: guard PASS; no byte-parity claim; P0-6 stays open.**
- [ ] **P-7 Stale ghost test/assets** — keep `variant3d/tests/t_ghost_final_stage.gd:30` and CAP-3 drag/ghost frames as-is; on-demand result/shot paths may be absent before a run — do not repair, delete or fabricate. Witness: `owner_decisions.md:338`, `V13_stale_qa_refs.md §2`, `V21 GR-C04`. **Untouched verification: guard PASS; absence ⇒ UNVERIFIED, never PASS.**
- [ ] **P-8 Preserved donor contradictions** — `TileSmoothPasses=6` vs `SmoothTileMap(...,3)` (use 3, carry 6); `tilesmooth.cfg` vs `tilesmooth_scripts.cfg`; swamp 17×20 vs 18×23; port `id mod 64` zeros vs donor `alphanull` 86/110/123; `specular_rgb` effective `vec3(0)`; `lake_big := plain*2*0`; demo-mill/fields/builder stands. Never "fix". Witness: `owner_decisions.md:339`, `V47 §6 R1`, `DEC_U_port_guard_audit.md §3.1`. **Untouched verification: guard PASS; no value change permitted.**
- [ ] **P-9 hygiene rule** — never `reset`/`doctor`/`cancel`/`unwedge`, never delete result JSONs or hand-edit status, never `--ignore-history`; re-run `py_compile` at A′-1 on the frozen tree (`owner_decisions.md:340`, `acceptance_runbook.md:54`).
- [ ] **Donor pin witness (report id only)** — `X59_donor_bytes_seal`, pin `t_87f0f3c130b0` (`C:\Games\Cossacks 3\cossacks.exe`), recorded donor-side hash `87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c`. This worker performed `Test-Path` only: path **PRESENT**; the binary was **not** opened, hashed, executed, copied or captured. **Untouched verification: NOT APPLICABLE to this worker; never an admissible A/B frame** (`hash_manifest.md:37/67/120`).
- [ ] **I11 seam integrity (live files)** — `variant3d/scripts/main.gd` and `world3d.gd` carry the single-applied seam (not re-applied); current read-only hashes this pass: `main.gd` `93faea93d911477303503a43a1457a3df1f485d256cec10ee8f70ac478acbb10`, `world3d.gd` `0a1f231930b2d39f5e486b47c37f327c9d343013162e00160ce4383894b36901`. No baseline for the live files is recorded in the cited reports; the two **backup** witnesses in §1.1 are the baselines. COORD must record before/after values for both live files at every capture (`acceptance_runbook.md:83-85`).
- [ ] **Capture-time rule** — hash every §1 item **before and after every capture**; a changed witness invalidates that run; never use `--ignore-history` (`acceptance_runbook.md:78-95`, `owner_decisions.md:328`).

## 2. Verification artifacts — exact path and state

All states below are transcribed from cited reports; read-only `Test-Path` this pass confirmed presence for every path listed. **File presence and a `PASS` string are evidence of that file's own scope only** (`final_gates.md:40`).

### 2.1 Unit / advisory selftests

- [ ] `variant3d/selftest.json` — **PASS (port-internal)**, 29/29, `passed=true`; `parity` field ABSENT. Blocking red GR-A03 only when COORD runs it with a fresh mtime-after-START envelope; on disk alone it is a file, not an accepted run (`final_gates.md:59`).
- [ ] `variant3d/uitest.json` — **PASS (port-internal)**, 17/17; `parity` ABSENT; blocking red GR-A03; UI flow only (`final_gates.md:60`).
- [ ] `variant3d/tests/results/t_render_mode.json` — **PASS (port-internal)**, 10 checks, `seam_missing=false`; `parity` ABSENT (`final_gates.md:61`).
- [ ] `variant3d/tests/results/t_map_variety.json` — **PASS (port-internal)**, 5/5 incl. `same_seed_byte_identical`; self-repeat, not a donor match; `parity` ABSENT (`final_gates.md:62`).
- [ ] `variant3d/tests/results/t_terrain_donor.json` — **class-A structural PASS (26/26) with all 18 class-B advisories UNVERIFIED**; self-denies parity: `parity.claim=NONE`, `parity.status=UNVERIFIED`, `visual_parity_claim=false` (`:518-522`). **Highest misread risk** — `status=PASS` is not a parity proof (`final_gates.md:63`, `parity_chain.md:41`).
- [ ] `variant3d/tests/results/summary.json` — **PASS (stale aggregate)** 19/19, mtime 2026-11-21; advisory, not fresh (`final_gates.md:64`).
- [ ] `variant3d/tests/t_final_gate.gd` — advisory source/doc probe; **no result JSON on disk**; any printed `FINAL_GATE n/m` must not be quoted as parity (`final_gates.md:65`).
- [ ] `variant3d/tests/manifest.json` — 41 registered test ids; **registration present, not a gate PASS** (`final_gates.md:66`).
- [ ] `docs/terrain_swarm_2026-11-26/spec/terrain_qa_spec.json` — **SCHEMA-ONLY / UNPOPULATED**; advisory, never a passing gate (`final_gates.md:67`).

### 2.2 Deterministic repeat / replay

- [ ] `inbox/qa/captures/repcheck_20261113/repeat_verification.json` — **PASS (port-internal repeatability)**: `byte_identical=true`, `status=pass`, `mismatches=[]`, 1280×720, 64 ticks, seed `20261113`, `kind="port-internal repeatability gate (NOT donor parity)"`, `parity="UNVERIFIED (not assessed)"` (`final_gates.md:78`, `internal_validation.md:107`). Condition 6 → PARTIAL, not CLOSED.
- [ ] `inbox/qa/captures/repcheck_20261113/manifest.json` + `inbox/qa/captures/repcheck_20261113_repeat/manifest.json` — primary + repeat run manifests; `status=ok`, `parity=UNVERIFIED` (`final_gates.md:79-80`, `hash_manifest.md:86/88`).
- [ ] `inbox/qa/captures/detcheck_20261113/manifest.json` and `inbox/qa/captures/detcheck2_20261113/manifest.json` — two COORD runs, seed `20261113`, `--capture-ticks 64`, 2 frames/1280×720; frame PNGs, `seq_index.json` and per-frame `sha256_pixels` byte-identical (`def18ad9…`, `18e1e72…`); both `parity=UNVERIFIED`. **Validates the opt-in mode only; closes no donor A/B, camera match or `[U]`** (`final_gates.md:81-83`, `HANDOFF.md:441/444`).
- [ ] `inbox/qa/captures/finalcheck_20261127/manifest.json`, `.../repeat_verification.json`, `inbox/qa/captures/finalcheck_20261127_repeat/manifest.json` — **PRESENT** (read-only `Test-Path` this pass; SHA-256 identity recorded in `hash_manifest.md:89-91`); role: port-internal final repeatability artifacts; not re-adjudicated by this checklist. No donor A/B, no parity promotion.

### 2.3 ROI comparisons

- [ ] `variant3d/tools/acceptance/compare_frames.py` — **14 invocations executed, 14/14 exit 0, 0 refusals**; always prints `parity=UNVERIFIED` (`final_gates.md:91`, `internal_validation.md:100`).
- [ ] `inbox/qa/captures/roi_metrics_20261113/` — 14 diff PNGs + 14 metrics JSONs (R01–R14); each `parity="UNVERIFIED"`, `claim=null`, `camera=NOT_SHARED_donor-oblique_vs_port-17p27`; support cues only (`final_gates.md:92`).
- [ ] `reports/PORT1TO1_roi_metrics.md` — report of 14 rows; all UNVERIFIED (`:56-104`).
- [ ] `reports/PORT1TO1_roi_register.md` — 14 verified donor ROIs + NO-ROI table; mandatory `NOT_SHARED` marker records **no shared camera asserted** (`HANDOFF.md:442`, `final_gates.md:94`).
- [ ] `variant3d/tools/compare_shots.py` — candidate-vs-candidate at pinned camera only; threshold 0.80 smoke placeholder; advisory (`internal_validation.md:95`).
- [ ] `variant3d/tools/terrain_ab_metric.py` — SMOKE only, no ARI, labelled "NOT a fidelity gate or donor proof" (`internal_validation.md:96`, `HANDOFF.md:128`).

### 2.4 MCP host, parse checks, capture sequence, guard

- [ ] `variant3d/tests/t_mcp_host.gd` — **PASS (port-internal, live)**: `cossacksgodotmcp`, protocol `2025-03-26`, exactly 6 tools (`game.status`, `game.tick`, `camera.pan_to`, `game.screenshot`, `game.place_building`, `video.record_frames`); `game.tick({})` clean refusal; no parity field, protocol level only (`final_gates.md:104-107`, `HANDOFF.md:407-408/421`).
- [ ] Parse checks — "All 18 edited GDScript files pass `--check-only`" (`HANDOFF.md:406`); `reports/V90_static_syntax_seal.md` **PASS (static only)** 13/13 (6 Python, 6 GDScript structure, 1 shader); Godot parse/smoke explicitly NOT run by that worker (`final_gates.md:113-114`).
- [ ] Ticket 575 `bbclamptidy01-parse` — timed out, exit −9, 302.44/300 s, `SCRIPT ERROR 0`; **NOT a passing gate and NOT a parse proof; UNACKED** (`final_gates.md:115`).
- [ ] `inbox/qa/captures/fullport6_seq2_20261113/manifest.json` + `contact.json` — 3-frame windowed sequence, `status=ok`, `deterministic=true`, `headless=false`, `parity=UNVERIFIED`, runner ticket 49; `contact.png` 2572×1528 `exact_pixels_preserved=true`; **port-internal evidence only** (`internal_validation.md:88-91`). Earlier `fullport6_seq_20261113/` attempt failed with `KeyError('seq_seconds')` and is preserved as a failure witness.
- [ ] `cap_fullport6.png` / `cap_fullport7.png` / `cap_fullport8.png` — reported rendered clean apart from the deliberate water U12/U4* hard-fail (`HANDOFF.md:409-410/441`); **read-only audits found them absent on disk** (`parity_chain.md:52`, `parity_recheck.md:57`, `internal_validation.md:82`). Discrepancy preserved verbatim, neither resolved nor repaired by this checklist.
- [ ] `reports/PORT1TO1_final_guard_audit.md` + `reports/PORT1TO1_claim_final.md` — **PASS in all four guard areas with 3 MINOR label gaps (GF1–GF3)**; C1–C5 parity-claim sweep: no live unguarded parity claim in `reports/` or `variant3d/`; C6 nine label-only hardening suggestions, none a parity claim, none applied by those audits (`internal_validation.md:128-131`, `claim_final.md:80-83`).
- [ ] `reports/PORT1TO1_hash_manifest.md` — point-in-time SHA-256 identity for the minimal owner bundle; three recorded baselines (P-2/P-4a/P-4b) matched at that read; donor pin recorded **by report id only**; no parity decision (`hash_manifest.md:112-124`).
- [ ] `reports/PORT1TO1_evidence_index.md` + `..._addendum.md`, `..._gate_audit.md`, `..._ack_evidence.md`, `..._determinism_audit.md`, `..._final_gates.md`, `..._u_register_update.md` — final claim-audit set; each carries `parity=UNVERIFIED` / `RESULT IS NOT GOOD`; no gate or metric promoted to parity (`claim_final.md:66-76`).

## 3. Open P0 blockers — packet paths (all still open)

All eight P0 rows remain `[U]`, hard-fails/labels intact; six owner packets exist, plus one P0 with **no dedicated packet**. Every packet closes nothing by itself; each retires only on its own zero-mismatch capture (`p0_packet_index.md:26-37/50-55`, `u_register_update.md:51-69`).

- [ ] **P0-1 / P0-1b / P0-2 — Water U12 reflection provenance, U4* scalar tuple, U1/U3/U5/U6.** Packet: `reports/PORT1TO1_water_owner_protocol.md`. Owner-only GPU/debugger session on pinned `t_87f0f3c130b0`; ≥2 water-visible frames + camera move, 0 differing bits/elements. Current port state: **no water drawn** — U12 reflection hard-fail (`water3d.gd:501-503/601-607`), U4* UNSET gate with no default (`water3d.gd:277/375-393/674-678`), BUILTIN `[D]` default, `±2.96` labelled U3 substitutes.
- [ ] **P0-3 — FOW grid a–e / combine / occlusion / persistence / tint.** Packet: `reports/PORT1TO1_fow_owner_protocol.md`. Seed `20261113` reveal transects, `GetFOWLOSData` dumps, 0 mismatching cells ×3. Current state: labelled provisional `1 res = 1 m` driver, not donor; per-tick `world3d_fog.gd` rebuild is `[U]` shape.
- [ ] **P0-4 — Native tick interleave / firing rate / cadence.** Packet: `reports/PORT1TO1_tick_owner_protocol.md`. Headless fixed-dt harness: 12 players × 3600 frames × 3 seeds × 6 sequences, single surviving byte-identical order. Current state: `TICK_ORDER v1` labelled **PORT APPROXIMATION** in `game.gd:5697/6058`.
- [ ] **P0-5 — Animation blend operator / completion / AAF triggers.** Packet: `reports/PORT1TO1_blend_owner_protocol.md`. R-B1…B4 / R-C1/C2 + W/S/A/R batteries, 3/3 byte-identical trials, `(0,0)` hard-cut control. Current state: no interpolation — one nearest frame, clamp-at-last empty hook; `requested_blend` is intent-only.
- [ ] **P0-6 — Save container / transform / checksum.** Packet: `reports/PORT1TO1_save_owner_protocol.md`. Paired known-state `.map` saves, one field varied at a time, re-save byte-identical, 3 repeats. Current state: **PORT EXTENSION**, v5 additive-only, key-order + round-trip determinism only, never byte parity.
- [ ] **P0-7 — RNG stream split (S/G G1) and per-site draw counts.** **No dedicated packet file exists.** Experiment owner/COORD harness: `reports/PORT1TO1_owner_decisions.md §7`, `reports/PORT1TO1_u_register_update.md §1` row P0-7, `reports/DEC_U_rng_ledger.md`, `reports/X21_rng_vectors.md` (oracle `(0x44A108F9,0x00000001)`, series R20/L20/C300/U50/F1M/K0/A600), 0 mismatches. Current state: `[U]-G1` labelled, attribution/draw counts unclosed; no donor stream claim. (This omission from the six-packet index is recorded, not repaired.)
- [ ] **P0-8 — Selection / projection / camera.** Packet: `reports/PORT1TO1_selection_owner_protocol.md`. Fixed rig `58 m / −32° / focal 400`, ≥5 surveyed markers → 0 px, pick winner/membership 0 mismatches incl. exact ties + FOW veto. Current state: `FOV 17.27°`, `cull_disabled`, nearest-single, depth tie-break and screen-UV bias retained as scaffolding / PORT APPROXIMATION.
- [ ] **Non-P0 parity-invalidating tails remain open** (`u_register_update.md:73-121/206`): PT-V1…PT-V7, W-R1, T-SEED/T-CALLBACK, T-SMOOTH/MINMAX/MOD, T-VER/MDEN/HF/OBJ, T-G0, U-speed-consumer/T-SPEED, E-COLL/LOS, E-ART, E-DMG/FF/flight, E-WPN/SHIELD, E-VIS/SEL, E-STATE, S-SKIRM, S-AI-A1…A8, S-MKT/Q2/VIC/PEACE, CS-*/Q-* capture tails, SAVE R1e/R1g, F-V1/V2, F tail, `U-INJ-1…11`, N-1…N-16. None is promoted; none closes a P0.
- [ ] **The single actor that could start changing the verdict** is an owner-authorised Route A donor GPU frame with a matched camera/ROI manifest (`reports/PORT1TO1_final_gates.md §8`, `reports/X39_ab_feasibility.md §3`). Necessary but not sufficient; workers are forbidden from executing the donor. No such frame exists.

## 4. Exact commands to re-run port-internal validation

These are the landed owner/COORD commands, transcribed verbatim from `reports/PORT1TO1_acceptance_runbook.md` and `reports/PORT1TO1_internal_validation.md`. **This checklist worker ran none of them.** They are port-internal evidence regeneration only: no step produces a donor A/B frame, closes a P0, acknowledges a ticket or changes `parity.status`. Run from the repo root; PowerShell uses `;` never `&&`; single Godot door (`godot_runner.py run`); one job at a time; fresh output directory per run.

### 4.1 Define the temp root

```powershell
$Acc = Join-Path $env:TEMP 'opencode\v42\acceptance'
New-Item -ItemType Directory -Force -Path $Acc | Out-Null
```

### 4.2 Static preflight (no Godot)

```powershell
python -m py_compile variant3d/tools/acceptance/imgio.py `
  variant3d/tools/acceptance/capture_sequence.py `
  variant3d/tools/acceptance/contact_sheet.py `
  variant3d/tools/acceptance/compare_frames.py
python variant3d/tools/godot_runner.py status
python variant3d/tools/assert_clean.py --json
Get-Command ffmpeg,ffprobe -ErrorAction SilentlyContinue
python -c "import PIL; print(PIL.__version__)"
Test-Path "$env:TEMP\opencode\donor_videos\selected\cZW0AEupCaI\t_600.png"
```

Accept only: `py_compile` exit 0; runner quiet with lock free and counters aligned; `assert_clean.py --json` CLEAN **without** `--ignore-history`; ffmpeg/ffprobe/Pillow present; donor still present.

### 4.3 Preserve-only hashes — before AND after every capture

```powershell
Get-FileHash variant3d\scripts\main.gd,variant3d\scripts\world3d.gd,inbox\backup\main.gd.bak-COORD-I11,inbox\backup\world3d.gd.bak-COORD-I11 -Algorithm SHA256
Get-FileHash variant3d\config_donor_capture.json,variant3d\config.json,variant3d\assets\models\manifest.json -Algorithm SHA256
```

Hard witnesses: `aa857480…202da` (config_donor_capture), `3859B605…E71F8` (main.gd I11 backup), `44EE96C0…AB07A` (world3d.gd I11 backup). `config.json` and `manifest.json` have no recorded baseline — record before/after and require equality. Include the six P-9 tool prefixes; resolve §1.2 mismatches first.

### 4.4 Parse checks on edited GDScript (per file, single door)

```powershell
python variant3d\tools\godot_runner.py run --id v42-parse-data --timeout 180 -- --headless --path variant3d --check-only --script res://scripts/terrain_donor_data.gd
```

Likewise `v42-parse-gen`, `v42-parse-mesh`, `v42-parse-props`, `v42-parse-world`, `v42-parse-main`, `v42-parse-seam-world`, `v42-parse-tdonor`. A `.gdshader` has no `--check-only --script`; smoke-test via headless `t_terrain_donor.gd`.

### 4.5 Wide + close deterministic sequences (24 frames / 768 ticks)

```powershell
Copy-Item variant3d\config_donor_capture.json (Join-Path $Acc 'wide_config.json') -Force
Copy-Item variant3d\config_donor_capture.json (Join-Path $Acc 'close_config.json') -Force
# In close_config.json set ONLY camera.start_zoom = 2.9; keep pitch -32, fov 17.27,
# 1280x720, random_seed 20261113, backend donor. Record BOTH SHA-256 values.
Get-FileHash (Join-Path $Acc 'wide_config.json'),(Join-Path $Acc 'close_config.json') -Algorithm SHA256

python variant3d/tools/acceptance/capture_sequence.py `
  --seed 20261113 --frames 24 --step 1 --label accept1 `
  --view wide=(Join-Path $Acc 'wide_config.json') `
  --view close=(Join-Path $Acc 'close_config.json') `
  --mode seq --deterministic --capture-ticks 768 `
  --timeout 240 --max-wait 3600 `
  --out inbox/qa/captures/accept1_det_20261126
```

Admissibility: `status=ok`, `parity=UNVERIFIED`, `capture_ticks=768`, `frame_count=24`, `resolution_observed={"width":1280,"height":720}`, `resolution_matches_request=true`, `headless=false`, no `watchdog:`/`deterministic-capture:`/`fallback map render` line in stderr. A winner early stop or any 800×600 frame is a failed capture.

### 4.6 Contact sheet and MP4 (presentation only)

```powershell
python variant3d/tools/acceptance/contact_sheet.py `
  --manifest inbox/qa/captures/accept1_det_20261126/manifest.json `
  --out inbox/qa/captures/accept1_det_20261126/contact.png --cols 4 --hash-labels

python variant3d/tools/seq_to_mp4.py `
  --dir "$env:TEMP\opencode\v42\acceptance\wide240" --fps 6 `
  --out "$env:TEMP\opencode\v42\acceptance\wide240.mp4"
```

Never trust the MP4 exit code alone: assert frame count/contiguity, `ffprobe` frame count and duration, `contact.png`, six diagnostics at 0/20/40/60/80/100%, `VIDEO_SHA256SUMS.json` outside the repo, then human review. Re-encoding is never a remedy.

### 4.7 ROI metric re-execution (representative row R06; 14 rows total in `roi_metrics.md:112-154`)

```powershell
python variant3d/tools/acceptance/compare_frames.py --donor "$env:TEMP\opencode\donor_videos\selected\cZW0AEupCaI\t_600.png" --port inbox/qa/captures/fullport6_seq2_20261113/01_donor/frame_0000.png --roi 0,60,640,300 --roi-source "PORT1TO1_video_targets.md section 3 D4, donor cZW0AEupCaI t_600 conifer belt and glades [0,60,640,360) => 0,60,640,300; identical box on port frame; locator only, no same-camera claim" --camera NOT_SHARED_donor-oblique_vs_port-17p27 --out-diff inbox/qa/captures/roi_metrics_20261113/diff_roi_R06_t600_d4.png --report inbox/qa/captures/roi_metrics_20261113/diff_roi_R06_t600_d4.json
```

Use a fresh output directory for a fresh run. Never supply `--assert-ab-verified`; never change `--roi`, `--roi-source`, `--camera`, resolution, `--hist-bins` or `--amplify` to obtain a run. Water/shore `t_2260`/`t_2370` are BLOCKED REFERENCE.

### 4.8 MCP host — start / verify / stop

```powershell
$ABS = (Resolve-Path variant3d\config_donor_capture.json).Path
$BOOT = Join-Path $env:TEMP 'opencode\v42\boot_viewport.png'
python variant3d\tools\godot_runner.py run --id mcp-host --timeout 3600 -- `
  --path variant3d --script res://tests/t_mcp_host.gd -- `
  --config "$ABS" --seed 20261113 --mcp-port 8931 `
  --screenshot "$BOOT"

# after GAMECRAFT-MCP READY port=8931:
python "$env:TEMP\opencode\v42\verify_mcp.py"
python "$env:TEMP\opencode\v42\verify_mcp_tools.py"

python variant3d/tools/godot_runner.py status
```

Accept only: exactly 6 tools in `tools/list`, all six calls without `isError`, `game.tick({})` a clean refusal. Stop by letting the job hit `--timeout`; never `reset`/`doctor`/`cancel`/`unwedge`.

### 4.9 Byte-identical two-run check

```powershell
# Run A
python variant3d/tools/acceptance/capture_sequence.py `
  --seed 20261113 --frames 24 --step 1 --label fixedA `
  --view wide=(Join-Path $Acc 'wide_config.json') `
  --mode seq --deterministic --capture-ticks 768 `
  --timeout 240 --max-wait 3600 `
  --out inbox/qa/captures/fixedA_20261126

# Run B — identical except label and out
python variant3d/tools/acceptance/capture_sequence.py `
  --seed 20261113 --frames 24 --step 1 --label fixedB `
  --view wide=(Join-Path $Acc 'wide_config.json') `
  --mode seq --deterministic --capture-ticks 768 `
  --timeout 240 --max-wait 3600 `
  --out inbox/qa/captures/fixedB_20261126
```

Accept only all six criteria in `acceptance_runbook.md:293-302`: manifests `status=ok`/`parity=UNVERIFIED`/`deterministic=true`/`capture_ticks=768`; views `complete=true`, 1280×720; `seq_index` `ticks_done=768`/`sim_seconds=24.0`; clean stderr; per-frame `sha256_pixels` and `sha256_file` byte-identical A vs B; no blank/800×600 frame. A pass supports **port-internal fixed-seed self-consistency only** — N4/N9/U5 and the rest remain open.

### 4.10 Command-runner checkboxes

- [ ] COORD/owner-only: run §4.2–§4.9 on a frozen tree, one job at a time, with §4.3 hashes recorded before and after.
- [ ] Do not run any of §4.2–§4.9 until the §1.2 P-9 hash discrepancies are adjudicated and A′-1 `py_compile` is re-run.
- [ ] Record every refusal/failure as a witness; never retry until green (`acceptance_runbook.md:306-320`).

## 5. Verdict template and dominance statement

Use exactly one verdict; given the current tree, the second block is the only admissible one. Verbatim only from `internal_validation.md:139-152`; `owner_brief.md:80-92`, `final_gates.md:138-145` and `acceptance_runbook.md:332-343` are additive variants (see `PORT1TO1_verdict_sync.md` §5), not verbatim sources:

```
PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B
frame exists; this review certifies neither donor fidelity nor a gate pass.

RESULT IS NOT GOOD — blocking_unverified is non-empty (no donor A/B frame; water U12/U4*;
FOW grid; tick interleave; animation blend; save container; RNG G1; selection/projection;
no COORD ruling).
parity.claim = NONE
parity.status = UNVERIFIED
blocking_unverified = [PT-V1, PT-V2, PT-V3, PT-V4, PT-V5, PT-V6, PT-V7,
                       P0-1, P0-1b, P0-2, P0-3, P0-4, P0-5, P0-6, P0-7, P0-8,
                       W-R1, T-SEED, T-CALLBACK, atlas-layout, X17, U-INJ-1..11,
                       plus the domain residuals]
```

- [ ] **`RESULT IS GOOD` is admissible only when `blocking_unverified = []` and all six conditions hold** — not today (`V109_owner_answer_final.md:74/91`, `internal_validation.md:154`).
- [ ] Forbidden phrasing at all times: "matches donor", "close to donor", "donor parity", "similarity %", "donor threshold PASS", "gate PASS" derived from a capture, or `--assert-ab-verified` treated as verification (`owner_brief.md:94`).
- [ ] **EXPLICIT STATEMENT — NO ITEM ON THIS CHECKLIST CLOSES DONOR PARITY.** §1 preserves bytes; §2 inventories port-internal artifacts; §3 lists owner-only experiments; §4 regenerates port-internal evidence. None supplies a donor GPU A/B frame, a matched camera/ROI manifest, fresh COORD-ruled gates with 575/582/585 acknowledged, a completed spec/toolchain with `blocking_unverified = []`, or a COORD-signed zero-mismatch geometry+frame ruling. All six conditions remain unclosed (0/6; two PARTIAL, four BLOCKED).
- [ ] Final sign-off state: `parity.status = UNVERIFIED`; `parity.claim = NONE`; `visual_parity_claim = false`; six-condition chain **0/6**; **`RESULT IS NOT GOOD` while `blocking_unverified` is non-empty**; no approximation adopted; no parity claim; no test weakened; no donor binary executed.

## 6. Claim register (this report)

| # | Claim | Label / source |
|---|---|---|
| 1 | Preserve-only set P-1…P-9 plus I11 seam live files and donor pin inventoried with current read-only SHA-256 values | [O] `Get-FileHash` this pass; `owner_decisions.md:326-341`, `hash_manifest.md:48-67` |
| 2 | Three recorded baselines + two P-9 tool prefixes match current bytes; four P-9 tool prefixes do **not** match recorded baselines | [O] this pass vs `V90_static_syntax_seal.md:177-182`, `V102_final_blockers.md:39/68` — identity finding only |
| 3 | All verification artifacts in §2 carry port-internal states; none promotes parity | [O]/[D] `final_gates.md:42-134`, `internal_validation.md:26-37/160` |
| 4 | Eight P0 rows open; six owner packets + one P0 with no dedicated packet | [D] `p0_packet_index.md:28-37`, `u_register_update.md:51-69` |
| 5 | Re-run commands transcribed from landed runbook; none executed by this worker | [O] `acceptance_runbook.md:60-302`, `internal_validation.md:53-108` |
| 6 | Verdict `RESULT IS NOT GOOD` while `blocking_unverified` non-empty; parity UNVERIFIED; no item closes parity | [D] `owner_brief.md:78-94`, `parity_recheck.md:40-63` |
| 7 | Read-only worker; exactly one repository file written; no code/Godot/donor execution, no git mutation | [O] scope; two read-only git orientation queries disclosed in frontmatter |

---

*End of PORT1TO1_handoff_checklist. Read-only sign-off checklist; exactly one repository file written. No approximation, no parity claim. Parity UNVERIFIED; `RESULT IS NOT GOOD` while `blocking_unverified` is non-empty. No item on this checklist closes donor parity.*
