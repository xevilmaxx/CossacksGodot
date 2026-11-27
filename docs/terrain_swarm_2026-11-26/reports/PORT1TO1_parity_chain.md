---
id: PORT1TO1-PARITY-CHAIN-2026-11-26
title: "Read-only audit of the six-condition donor-parity chain against the CURRENT working tree"
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: WORKER PARITY-CHAIN — read-only audit; exactly one report written
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_parity_chain.md
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION
created: 2026-11-26
labels: [OBSERVED, DERIVED, UNVERIFIED, "PORT APPROXIMATION", PRESERVE-ONLY, NO_PARITY_CLAIM]
parity_status: UNVERIFIED
parity_claim: false
parity_claim_code: NONE
verdict: "RESULT IS NOT GOOD — blocking_unverified is non-empty; no condition of the six-condition chain is closed"
scope_guard: "Repo file/line reads and read-only PowerShell Get-ChildItem/Get-FileHash of existing files only. No source, shader, asset, config, test, fixture, result JSON, backup, git state, Godot process, runner job, gate, capture, ROI metric or donor binary was modified, created or executed. No donor frame was produced or compared. Exactly one repository file written: this report."
governing_sources:
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_owner_decisions.md (§0, §9 :315-323, §10 :326-341, §11 :353)
  - docs/terrain_swarm_2026-11-26/reports/V109_owner_answer_final.md (:74, :91)
  - docs/terrain_swarm_2026-11-26/reports/V105_final_owner_sheet.md (§78 chain referenced at owner_decisions :319)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_determinism_audit.md (:36, :55-60, :214-219)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_roi_register.md (:27, :35, :86, :220, :226-256)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_fixed_step_plan.md (:29-34, :596-613, :691-702)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_acceptance_plan.md (:31, :33, :186-190, :258-270, :273-291, :355-370)
  - docs/terrain_swarm_2026-11-26/reports/X39_ab_feasibility.md (:9-10, :32-37, :74-81, :104-110, :165-178)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_full_project_audit.md (:101, :108-119)
  - variant3d/scripts/{main,game,camera3d,config,anim3d,water3d}.gd, variant3d/{config.json,config_donor_capture.json}
  - inbox/qa/captures/fullport6_seq2_20261113/manifest.json, variant3d/tests/results/t_terrain_donor.json
---

# PORT1TO1 — six-condition parity chain audit (current tree, 2026-11-26)

> **Mandatory reviewer line (verbatim, `PORT1TO1_owner_decisions.md:15/32`, `PORT1TO1_acceptance_plan.md:28-29`):**
> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

> **This is a read-only audit, not a new claim.** It reports the state of the files as read on 2026-11-26. It does not execute the donor, Godot, a runner job, a gate or a capture. It does not close any `[U]`, does not weaken any test, and does not promote any metric.

## 0. Bottom line (do not quote selectively)

- **The six-condition chain is defined at `PORT1TO1_owner_decisions.md:319` and restated verbatim at `V109_owner_answer_final.md:91`.** It is a chain of *conditions*, not achievements: parity requires **all six**. The reviewer line at `V109:91` and `owner_decisions:39` is explicit: until all six hold, `parity.claim = NONE`, `parity.status = "UNVERIFIED"` and **`RESULT IS NOT GOOD`**. No tier above 2 exists (`owner_decisions:40`, `acceptance_plan:368`).
- **Current state: zero of the six conditions is closed.** One condition has a *partial, port-internal* satisfaction (condition 2 — one admissible port-internal sequence exists); one has a *code-level partial* satisfaction (condition 3 — the P0 fisher sim hazard is neutralized in source, but replay is not demonstrated and the frame-step mode is unimplemented). The remaining four are blocked. None is ruled by COORD.
- **`blocking_unverified` is non-empty** — P0-1…P0-8 remain open (`acceptance_plan:273-291`; `owner_decisions:39,322`; `roi_register:220`). Therefore **`RESULT IS NOT GOOD`**, unconditionally (`V109:74`, `owner_decisions:14/39/353`, `acceptance_plan:33/269`).
- **No unit-test gate and no ROI metric promotes parity.** A `compare_frames.py` run always prints `parity=UNVERIFIED` (`roi_register:27/211-214`); the fresh `t_terrain_donor.json` `status=PASS` selftest itself carries `parity.claim="NONE"`, `parity.status="UNVERIFIED"`, `visual_parity_claim=false` (read this pass, §4.2 below). Unit tests are not the acceptance path (`acceptance_plan:31`, `determinism_audit:204`, `fixed_step_plan:670-671`).

---

## 1. The six-condition parity chain — condition-by-condition status

Source of the chain: `PORT1TO1_owner_decisions.md:319` ("the six-condition chain of `V109 §6` / `V105 §78`") and `V109_owner_answer_final.md:91` (verbatim). Column "Closes only with" names the **exact artifact/act** that would close that condition; none of these artifacts exists in the current tree.

| # | Condition (verbatim/condensed from `V109:91`) | Status now | Evidence from current tree | Exact artifact that would close it |
|---|---|---|---|---|
| 1 | Owner supplies a genuine same-size/seed/type/season/camera/ROI **donor GPU frame** | **BLOCKED** | `X39_ab_feasibility.md:32` — no route inside project rules can produce a donor GPU frame by any worker; `:33` only owner-launched `cossacks.exe` Route A is viable; `:36` no donor frame captured; `acceptance_plan:188-190` donor A/B forbidden to workers; `roi_register:45-70` the 12 frames are third-party H.264 stills of unknown build/camera/zoom/compression. No owner-supplied donor frame is on disk or named in any report. | Owner-run donor PNG **outside the repo** + written key/camera/size/season/ROI manifest per `X39 §3` (:113-157); donor binary never executed by a worker. Even then necessary, not sufficient (`X39:34/178`). |
| 2 | An admissible non-blank 1280×720 candidate capture, `script_error_lines=0`, pinned seed/camera/size, identical ROI | **PARTIAL (port-internal only)** | `inbox/qa/captures/fullport6_seq2_20261113/manifest.json:7` `headless=false`, `:22` `status=ok`, `:95` `resolution_matches_request=true`, `:65` config SHA `aa857480…202da`, `:20` seed `20261113`, `:14` `parity="UNVERIFIED"`; `roi_register:69-71` confirms F0/F1/F2 1280×720. **But** `acceptance_plan:184` admits it only "as port-internal evidence only — still no donor A/B"; `cap_fullport6.png`/`cap_fullport7.png` named at `acceptance_plan:41` are **absent** (read-only listing this pass, corroborating `roi_register:73`); no pinned donor-matched camera exists (§3.2 below). | A fresh windowed capture with `status=ok`, `complete=true`, `resolution_observed=1280×720`, `script_error_lines=0`, pinned seed/camera/size, paired with a real donor frame at the same ROI (`acceptance_plan:177-186`, §2.3 admissibility gate). |
| 3 | Inputs **matched and labelled** (A/B-L1 same keys, or A/B-L2 importer-rendered same geometry) | **BLOCKED** | `X39:137` donor has no numeric seed UI; `randkey0/1` derivation `[U]`; `X39:169-171` L1 requires same keys/size/type/season/camera/ROI and still does **not** certify parity; L2 requires the D04 §7 importer upgrade. `roi_register:86` forces `--camera NOT_SHARED_donor-oblique_vs_port-17p27`, i.e. no shared camera is asserted. `determinism_audit:216` port-vs-port replay **INCOMPLETE**; `:217` port-vs-donor **UNVERIFIED**. | Owner manifest with both donors' `randkey0/1`, size enum, map type, season, camera constants and fractional ROI, recorded per `X39 §3`; plus the D04 importer upgrade for L2. No such manifest exists. |
| 4 | Fresh gates green, not stale, 575/582/585 acknowledged, `app/**` byte-identical | **BLOCKED** | `owner_decisions:322` — result JSONs stale, `assert_clean` last read DIRTY with 575/582/585 unacked, `inbox/qa/**` PENDING; `full_project_audit:101` Q-1 "No gate green", advisory policy, `terrain_qa_spec.json` SCHEMA_ONLY. Fresh `t_terrain_donor.json` (11/26) is an **advisory self-test**: `status=PASS`, `total=26`, but `parity.status="UNVERIFIED"`, every advisory `status=UNVERIFIED`, `S2_water_fraction=0`, `S3_shore_fraction=0`, `S5_relief_stamp_count=0` (read this pass, §4.2). No D1/D3 dump integrity, no 320², no COORD gate ruling. | Fresh runner result JSONs with mtime after job START; D1 dumps (5 streams × 3 sizes, zero byte difference); D3 run integrity `status∉{timed-out,error,skipped}`, `script_error_lines=0`, CLEAN; selftest 29/29, uitest 17/17, `t_render_mode` PASS, `t_map_variety` 5/5, `assert_clean` CLEAN with 575/582/585 acknowledged **with evidence-backed reasons**, `app/**` byte-identical (`owner_decisions:319-320`). |
| 5 | Spec/toolchain evidence completed — §§01–14 READY, X15 root manifest, I05 atlas/I03 feed, N17 populated and signed, **`blocking_unverified = []`** | **BLOCKED** | `full_project_audit:13-16` (~45 approximations; 3 structural blockers), `:49` T-1 atlas tier ABSENT, `:61-63` P-1/P-3 Objects feed unwired / `bind`→`build`, `:101` N17 SCHEMA_ONLY, `:117` root `manifest.json` absent. `owner_decisions:322` `blocking_unverified` non-empty; `acceptance_plan:289` additional RUNTIME-only blockers; every P0 row in `acceptance_plan:277-287` ends in a labelled port state, not a closed experiment. | All §§01–14 READY, X15 root `manifest.json` emitted, I05 atlas built and bound, I03 feed consumed with `props_total>0 && fallback_used=false`, N17 populated and signed, and `blocking_unverified = []` ruled by COORD (`owner_decisions:319-320`). |
| 6 | **Demonstrated byte-identical geometry + pixel-identical frame** under the proven-matched manifest, ruled by **COORD explicitly** | **BLOCKED** | No COORD ruling exists in any report; `V109:91` requires explicit COORD ruling; `roi_register:27/220` parity stays UNVERIFIED; `acceptance_plan:252` `--assert-ab-verified` never promotes `parity=UNVERIFIED`; `fixed_step_plan:665-671` a passing replay pair still leaves `parity=UNVERIFIED`. | A COORD-signed owner report with a demonstrated geometry-byte equality and pixel-identical matched frame (zero mismatch), explicitly ruling condition 6. No such report exists. |

**Chain result: `parity.claim = NONE`, `parity.status = UNVERIFIED`, `RESULT IS NOT GOOD`.** Even if conditions 2 and 4 were later made green, the ceiling remains "gates green / internal consistency PASS / donor parity UNVERIFIED" (`owner_decisions:39`, `V109:91`, `acceptance_plan:368`).

---

## 2. Required audit item (1) — donor A/B frame legality under the read-only rule

- **Read-only rule is binding on this worker and all workers.** `X39:32` quotes CHARTER §4: "No donor executable is run, no donor binary is copied or committed. Donor material = private use only." `owner_decisions:36` classifies RUNTIME experiments as owner-authorised only; `:38` says no port change has been applied by a worker.
- **No legal donor A/B exists today.** `X39:36` — filesystem check: no donor GPU frame captured; `:37` — if the owner will not/cannot run the donor and supply the manifest, parity is permanently `UNVERIFIED`. `acceptance_plan:188-190` — "No donor binary was executed, no donor GPU frame captured, no port frame compared by this worker… This is the controlling reason the verdict is UNVERIFIED (§6)." `roi_register:11/45` — donor frames were only listed and their PNG headers read; no donor execution, no new extraction.
- **The 12 H.264 stills are not A/B legal.** `roi_register:45-70` — direction-of-appearance only; `:86` `--camera NOT_SHARED_donor-oblique_vs_port-17p27`; `acceptance_plan:97-99` water/shore blocked and PT-V1 UNVERIFIED. `X39:96-100` Route D is "insufficient by definition"; `:104-110` only Route A produces a real donor GPU frame, and even it needs a matched-input manifest (`:169-171`).
- **Status: LEGALLY BLOCKED for any worker.** Only an owner-run Route A can create the artifact; until then condition 1 cannot be satisfied. This audit produced none.

## 3. Required audit item (2) — camera / projection equality (V1/V2 still `[U]`)

- **No shared camera is asserted anywhere.** `roi_register:86` sets `--camera NOT_SHARED_donor-oblique_vs_port-17p27` as a mandatory marker "recording that no shared camera is asserted"; passing a friendly label would be an unsupported assertion. `roi_register:35` — the harness cannot verify donor identity, camera equality or ROI correctness.
- **Port FOV is still a labelled approximation in current source.** `variant3d/scripts/camera3d.gd:99-100` derives 17.27° from a 216 mm sensor at focal 400 (a port derivation, not a donor claim); `:109` `const FOV_DEG_ASSUMED: float = 17.27`; `:112-113` `NEAR_M=0.1`, `FAR_M=4096.0`; `:198-202` these are the null-config fallbacks. `variant3d/scripts/config.gd:81-82` and `:479-482` keep `fov_deg = 17.27` with the comment that "216 mm sensor -> 17.27 deg is a port derivation"; `variant3d/config.json:42` and `config_donor_capture.json:43` carry the same value.
- **V1/V2 termination not met.** `owner_decisions:283-289` — V1-SENSOR/V2-PROJ/V2-DRAG/V2-BOX/V2-MINI require ≥5 surveyed points reprojecting to 0 px, exact clip boundary, 0 rect-membership mismatches and 0 px minimap affine/frustum error; outcome → port change only after termination. `roi_register:246` lists F-V1/V2 as open. `acceptance_plan:287` says `17.27°` stays APPROX and all scaffolding (`cull_disabled`, `nearest-single`, depth tie-break, screen-UV bias) is retained.
- **Status: STILL `[U]` / BLOCKED.** Exact artifact to close: the V1-SENSOR + V2-PROJ + V2-DRAG + V2-BOX + V2-MINI captured pixel solve with the termination above (`owner_decisions:283-289`).

## 4. Required audit item (3) — deterministic replay

### 4.1 What IS fixed in current source (P0 fisher RNG)

- The determinism audit recorded an unseeded global `randf()` fisher-target draw at its `game.gd:8127-8128` (N3, "This alone invalidates a fixed-seed port-vs-port replay", `determinism_audit:55-60`, verdict `:216`).
- **Current tree differs:** the fisher target draw now lives at `variant3d/scripts/game.gd:8195-8196` and reads `var rr: float = (0.5 + sim_rng.random_f32()) * FISHER_RADIUS_MOVE_CHANGE` / `var ang: float = sim_rng.random_f32() * TAU`, feeding `e["fish_target"]` and `e.order` at `:8197-8198`. The change is documented in-source at `:8182-8194`: "P0 REPLAY FIX — COORD determinism audit… Replaced with the ALREADY-PRESENT seeded donor-controlled sim stream `sim_rng.random_f32()`… NO new stream is invented." `sim_rng` is the single donor `RandomExt` sim S stream (`game.gd:239`, seeded `:376/:601`).
- **This neutralizes the Class-N *sim-state* hazard only.** The same comment keeps `[U]` exact donor `random` stream attribution (`:8191-8193`) and retains "CS-D3 [U] 3-run zero-mismatch". A deterministic port choice is **not** a donor-stream claim; no zero-mismatch replay demonstrating it was run by this or any worker.

### 4.2 What is NOT implemented / NOT demonstrated

- **Frame-step design unimplemented.** A full-tree read-only search for `deterministic-capture`, `capture-ticks`, `deterministic_capture` in `variant3d/` returned **no matches** — neither `main.gd` nor `capture_sequence.py` carries the design's flags. Current tick driver is still `main.gd:1635-1642` `dt = minf(dt, 0.25); acc += dt * speed; … while acc >= step and steps < 64`, with watchdog truncation still active at `:1629-1634` and `:1654-1655`. `PORT1TO1_fixed_step_plan.md:29-34` states "This is a design, not an implementation… no line of `main.gd` or `capture_sequence.py` was changed"; `:696` "Not implemented, not executed: all hunks are unapplied sketches"; `:697-699` port-vs-port self-determinism only CONDITIONAL and port-vs-donor UNVERIFIED.
- **Other Class-N hazards remain conditional and must be excluded by protocol.** `determinism_audit:62-67` (N4 audio RNG + wall-clock dedup), `:69-74` (N5 watchdog), `:76-81` (N6 frame pacing / frame-count screenshots), `:90-95` (N8 GPU fallback silent 800×600 substitution), `:97-102` (N9 save/load seed rewrite). `fixed_step_plan:596-613` confirms the design does not neutralize N3 (now code-fixed), N4, N9 or U5 water time.
- **Port-internal self-determinism exists but is bounded.** `variant3d/tests/results/t_terrain_donor.json` (read this pass) has `determinism.64.pairwise_equal=true` and `determinism.240.pairwise_equal=true` (hashes_a == hashes_b at 0 tolerance) — port-vs-port dump equality at 64²/240² only, **not** 320², **not** a frame replay, **not** donor parity. Its own `parity` object reads `claim=NONE`, `status=UNVERIFIED`, `visual_parity_claim=false`; all advisories are `status=UNVERIFIED`.
- **Status: PARTIAL.** P0 sim hazard N3 neutralized in code; deterministic replay **INCOMPLETE** (`determinism_audit:216`) because no two-run byte-identical frame-hash demonstration exists and the frame-step mode is unimplemented. Exact artifact to close: the `fixed_step_plan §8` two-run test (Run A/B, seed 20261113, pinned config SHA, `--capture-ticks 768`, 24 frames, byte-identical `sha256_pixels`, clean stderr, 1280×720) — and note that even a passing pair is port-internal self-consistency only (`fixed_step_plan:665-671`), not donor parity.

## 5. Required audit item (4) — are all P0 `[U]` blockers closed?

**No. All remain open, with hard-fails/labels intact in current source:**

| P0 | Source evidence (current tree / reports) | Still `[U]`? |
|---|---|---|
| P0-1 Water U12 | `water3d.gd:501-503` `bind_reflection_map(null)` refused: "[U12] requires a real reflectionMap"; `_finalize_water_node` at `:601-607/:674-685`; `:807-808` reflection bound only by owner; `:307-308` FBO provenance UNVERIFIED. `acceptance_plan:279` port hard-fails water draw. | **YES** |
| P0-1b Water U4* | `water3d.gd:277` `null means "no captured value" — selecting ENGINE hard-fails, no invention`; `:290-291/:313` engine waveDirs unenumerated, no default; `acceptance_plan:280` explicit gate, no water. | **YES** |
| P0-2 Water U1/U3/U5/U6 | `water3d.gd:143-145` U3 uniforms are `map_size` substitutes recorded `[U]`; `:307` hmap identity UNVERIFIED; `acceptance_plan:281` BUILTIN `[D]` default, U12 hard-fail retained. | **YES** |
| P0-3 FOW a–e + persistence | `owner_decisions:142-188` each F-GRID row terminates only on a zero-mismatch capture; `roi_register:242` open; `acceptance_plan:282` "labelled provisional driver; no donor grid claim". | **YES** |
| P0-4 Tick interleave | `game.gd:5697` "freeze as `TICK_ORDER v1 PORT APPROXIMATION`" and `:6058` same; `owner_decisions:198` "TICK_ORDER v1 stays PORT APPROXIMATION"; `acceptance_plan:283`. | **YES** |
| P0-5 Animation blend/completion | `anim3d.gd:423-428` `requested_blend` is "LOGGED INTENT ONLY"; `:129` `AAF_LOOP_STATUS` `[U] U2`, `:200` `AAF_COMPLETION_STATUS` `[U]-C1/C2` clamp-at-last stand-in; `:759` clamp/nearest frame; no lerp/slerp on pose path. `acceptance_plan:284` no interpolation. | **YES** |
| P0-6 Save container | `game.gd:9063` "PORT EXTENSION contract, NOT a byte-parity claim", `:9364-9396` `save_v5` additive-only, `"version":5`, `:9479` restore `>=5`. `acceptance_plan:285` round-trip determinism only, never byte parity. | **YES** |
| P0-7 RNG G1 | `game.gd:202-204` S/G split and per-site counts stay `[U]-G1`; `:5914-5923` G-attributed draws `[U]-G1-b/G1-g`, promotion proof open; `:7845-7849` `GLOBAL_DROP_RADIUS[_SQR]` inert `[U]-E1`. `acceptance_plan:286` no parity. | **YES** |
| P0-8 Selection/projection | §3.2 above — `camera3d.gd:109` FOV APPROX; `roi_register:246` E-U13/V1-SENSOR/V2-PROJ open; `acceptance_plan:287` scaffolding retained. | **YES** |

- Additionally non-P0 but parity-invalidating `[U]` remain (`acceptance_plan:289`: T-SEED/T-CALLBACK, E-COLL, E-DMG/FF incl. known `PredictShot` mismatch, E-WPN/SHIELD, E-VIS/SEL, S-SKIRM, S-AI-A1–A8, S-MKT/Q2/VIC/PEACE) and `U-INJ-1…11` (`determinism_audit:162-176`).
- `acceptance_plan:269`: `RESULT IS NOT GOOD` while any P0 item is open. **Status: BLOCKED.** Each P0's exact closing artifact is its named zero-mismatch experiment in `owner_decisions §1–§8` / `acceptance_plan:277-287`; all are owner/RUNTIME and forbidden to workers (`owner_decisions:36-37`, `:349`).

## 6. Required audit item (5) — preserve-only mods documented (hashes)

- **Documented:** `owner_decisions:326-341` P-1…P-9 with must-not-change statements; `acceptance_plan:295-311` §7 preserve-only config checks; `determinism_audit:180-191` §4 explicit preserve-only list; `full_project_audit:108-119` §9 owner modifications. Rule: re-verify SHA-256 before and after every capture, never flip/revert/repair/re-apply (`owner_decisions:328`, `acceptance_plan:297/311`).
- **Verified byte-identical this pass (read-only `Get-FileHash`, [O]):** `variant3d/config_donor_capture.json` = `aa857480474399dc4674104744ea292bf84094d8321cdd4d0889c24cf9a202da` — matches the witness at `owner_decisions:333`, `acceptance_plan:310` and `fullport6_seq2_20261113/manifest.json:65`; `inbox/backup/main.gd.bak-COORD-I11` = `3859B6056BFDFDD5A659931835FD0901DD03DB36B02A453389D9338BAC9E71F8` and `inbox/backup/world3d.gd.bak-COORD-I11` = `44EE96C0DCFB35558F6EA3E0493E8F8FAA1CADF6E155BEB38031A9B11E1AB07A` — both match `owner_decisions:335` / `acceptance_plan:306` (V102 §Seam, V65 §8, V95 item 5). The I11 seam is single-applied in `main.gd` (`owner_decisions:335`) and no re-application was performed here.
- **Present by direct reads but with NO recorded baseline hash in the cited reports:** `variant3d/config.json` (`backend="donor"` `:29`, `color_unify=true` `:31`, `fov_deg=17.27` `:42`, `start_zoom=0.3448276` `:76`) — current hash this pass `223767e57b506577…`; `variant3d/assets/models/manifest.json` (nation move / EUR aliases / `field` fields, `owner_decisions:334`) — current hash `36f6a378548f3116…`. `owner_decisions:332/334` explicitly say "No per-file SHA recorded in the cited reports — re-hash before/after capture (plan §7)". These current values are **not** evidence of preservation against a baseline; they are only point-in-time readings.
- **Tool hashes P-9** (`owner_decisions:340`: `ABBF0571 / DDFB8688 / 00C0591A / 667B71FB / 3A92D053 / 5A3B9E77`) and donor pin `cossacks.exe` `87f0f3c130b0…` are recorded in reports but were **not** re-verified by this audit; the report itself requires COORD to independently re-run `py_compile` at A′-1 on the frozen tree.
- **Status: DOCUMENTED, PARTIALLY RE-VERIFIED.** Documentation exists; only three witnesses (P-2 config hash, P-4 two backups) were confirmed byte-identical this pass. Exact artifact to fully close: COORD's before/after SHA-256 table for **every** preserve-only item (P-1…P-9), with no `--ignore-history`, no deleted result JSON and no forced re-apply (`owner_decisions:328/340-352`, `acceptance_plan:295-311`).

## 7. Required audit item (6) — no weakened tests / gates

- **No test or gate was modified, run, retried-until-green, threshold-lowered or bypassed by this worker** (scope guard). The fixed-step design explicitly forbids it: `fixed_step_plan:667-669` "Do not lower a threshold, do not substitute a CPU map, do not retry until green, and do not add a port fallback to force a match"; `:611-613` a mismatch is never papered over. `determinism_audit:204` "no test is weakened and no port fallback may close it". `owner_decisions:37` "No item is settled by… a green-looking test"; `:38` "no port change in this register has been applied by this worker".
- **Fresh `status=PASS` JSONs do not equal a gate pass.** `t_terrain_donor.json` `status=PASS`, `total=26` read this pass, but its own `parity` object is `NONE/UNVERIFIED/visual_parity_claim=false`, all advisories are `UNVERIFIED`, and the determinism equality is only port-internal 64²/240². `full_project_audit:101` records the acceptance posture as advisory with no gate green, `terrain_qa_spec.json` SCHEMA_ONLY, N17 unsigned. `acceptance_plan:31` "Owner acceptance is snapshot/video-driven, not unit-test gates"; `:252` `--assert-ab-verified` never promotes parity.
- **No weakening detected in source labels:** P0 labels, hard-fails and `[U]` tags are intact in `game.gd`, `water3d.gd`, `camera3d.gd`, `anim3d.gd`, `config*.json` as cited in §5. No threshold was changed to make a defect disappear; the `demo_mill`/`color_unify`/`backend` preserve-only flags remain as documented (§6).
- **Status: NO WEAKENING; gates still not green.** Exact artifact to close condition 4: the fresh, non-advisory, COORD-ruled gate battery with 575/582/585 acknowledged and `app/**` byte-identical (§1 row 4) — not a `PASS` selftest.

---

## 8. Explicit, unambiguous statements

1. **No unit-test gate promotes parity.** A `PASS` selftest, `t_render_mode`/`t_map_variety` results, D1 hash equality and all `compare_frames.py` metrics are port-internal support cues only. `acceptance_plan:31/252/264`, `roi_register:27/211-214`, `determinism_audit:204`, `fixed_step_plan:670-671`.
2. **No ROI metric promotes parity.** Every successful `compare_frames.py` run and every refusal prints `parity=UNVERIFIED`; MAE/RMSE/max error/differing-pixel fraction/Pearson/histogram correlation/intersection/chi-square/the absolute-difference PNG/`--assert-ab-verified` are support cues only; no threshold is defined (`roi_register:27/196-222`; `X39:169-171` "L1… does not certify parity even if they look similar").
3. **Parity stays UNVERIFIED** with `parity.claim = NONE`, `parity.status = "UNVERIFIED"`, `visual_parity_claim=false`; no tier above 2 exists (`owner_decisions:12-14/39-40`, `V109:91`, `acceptance_plan:355-370`).
4. **`RESULT IS NOT GOOD`** because `blocking_unverified` is non-empty — P0-1…P0-8 are open, no donor GPU A/B frame exists, no admissible matched capture exists, no COORD ruling exists (`owner_decisions:14/39/322/353`, `V109:74/91`, `acceptance_plan:33/269`, `roi_register:220`).
5. **No approximation, no parity claim, no test weakening, no code/Godot/git/donor execution was performed by this audit.** Exactly one repository file was written: this report.

## 9. Claim register

| # | Claim | Label |
|---|---|---|
| 1 | The six-condition chain is `owner_decisions:319` / `V109:91`; all six are required and none is closed | [D] report read |
| 2 | No donor GPU A/B frame may be produced by a worker; none exists; only owner Route A is viable and is not executed | [O]/[D] `X39:32-37/74-81`, `acceptance_plan:188-190` |
| 3 | V1/V2 camera/projection equality is still `[U]`; FOV 17.27° is PORT APPROX in current source | [O] `camera3d.gd:99-113`, `config.gd:81-82/479-482`, `roi_register:86` |
| 4 | P0 fisher `randf()` sim hazard is neutralized in current source via `sim_rng.random_f32()` at `game.gd:8195-8196`; donor stream attribution still `[U]`, CS-D3 retained | [O]/[D] `game.gd:8182-8198`, `determinism_audit:55-60` |
| 5 | Frame-step deterministic capture mode is unimplemented: no `deterministic-capture`/`capture-ticks` symbol in `variant3d/`; `main.gd:1635-1642` still frame-paced | [O] full-tree read-only search + direct read, `fixed_step_plan:29-34/696` |
| 6 | All P0-1…P0-8 blockers remain `[U]` with hard-fails/labels intact in current source | [O] §5 source reads + `acceptance_plan:277-287` |
| 7 | Preserve-only P-1…P-9 documented; P-2 config hash and P-4 two I11 backup hashes confirmed byte-identical this pass; P-1/P-3 have no baseline hash in reports | [O] `Get-FileHash` read-only + `owner_decisions:326-341` |
| 8 | No test/gate weakened; fresh `t_terrain_donor.json` PASS is an advisory selftest carrying `parity=NONE/UNVERIFIED` | [O] read of result JSON + `acceptance_plan:31/252` |
| 9 | No gate or ROI metric promotes parity; parity UNVERIFIED; `RESULT IS NOT GOOD` | [D] `roi_register:27/220`, `V109:74/91`, `owner_decisions:39/353` |
| 10 | This worker wrote exactly one repository file (this report); no code, Godot, git, donor execution, capture, gate or ROI metric produced | [O] scope |

---

*End of PORT1TO1_parity_chain. Read-only audit; exactly one repository file written. Six-condition chain: 0/6 closed. No donor GPU A/B frame, no admissible matched capture, no demonstrated byte-identical replay, no COORD ruling. No unit-test gate or ROI metric promotes parity; parity UNVERIFIED; `RESULT IS NOT GOOD`. No approximation, no parity claim.*
