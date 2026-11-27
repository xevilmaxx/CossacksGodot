---
id: PORT1TO1-BUNDLE-INDEX-2026-11-27
title: "Minimal evidence bundle index for the owner 1:1 port decision (full 1:1 Cossacks 3 donor port)"
worker: BUNDLE-INDEX (read-only subagent)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-27
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION__NO_PARITY_CLAIM
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_bundle_index.md
files_created: [docs/terrain_swarm_2026-11-26/reports/PORT1TO1_bundle_index.md]
files_edited: []
scope_guard: "Repo file/line reads and read-only filesystem existence checks only. No source, shader, config, asset, test, fixture, manifest, result JSON, backup, queue file, git state, Godot process, runner subcommand, gate, capture, ROI metric, donor binary or donor GPU frame was created, modified, executed, copied or hashed. Exactly one repository file written: this report."
labels: [MINIMAL_BUNDLE, NAVIGATION_INDEX, OWNER_REVIEW, PRESERVE_ONLY, "PORT APPROXIMATION", PARITY_UNVERIFIED, RESULT_IS_NOT_GOOD, NO_APPROXIMATION, NO_PARITY_CLAIM]
parity_status: UNVERIFIED
parity_claim: NONE
visual_parity_claim: false
verdict: "RESULT IS NOT GOOD — blocking_unverified is non-empty; six-condition chain 0/6 CLOSED; no donor GPU A/B frame; no approximations; no parity claim."
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
bundle_file_count: 34
governing_sources:
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_handoff_checklist.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_owner_brief.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_p0_final_status.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_p0_session_plan.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_session_risks.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_artifact_layout.md (§5.1, §6)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_hash_manifest.md (§2)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_final_gates.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_evidence_index.md (§Contradictions C-1/C-2/C-3)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_deep_index2.md (§Flags X-1)
---

# PORT1TO1 — minimal evidence bundle index (2026-11-27)

> **Mandatory reviewer line (verbatim):** PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

> **Bottom line up front:** `parity.status = UNVERIFIED`; `parity.claim = NONE`; `visual_parity_claim = false`; six-condition chain **0/6 CLOSED** (condition 6 **PARTIAL**, port-internal repeatability only). `blocking_unverified` is non-empty, therefore **`RESULT IS NOT GOOD`** unconditionally. This index selects **34 files** (≤40) from the ~370-report corpus. Every selected file is evidence of its own scope only; **no item in this bundle closes donor parity, retires a `[U]`, acknowledges a ticket, wires a value, or supplies a gate pass.**

## 0. How to read this index

- This is a **read-only navigation index**, not a verdict, gate pass, parity proof or acceptance decision. It names the smallest file set an owner needs to *review* the 1:1 port decision; it does not make that decision.
- Paths are repo-relative with forward slashes. All 34 paths were confirmed present by read-only `Test-Path` at this pass. Presence is existence evidence only (`PORT1TO1_evidence_index.md:15`).
- Every row states: (a) **exact path**, (b) **why it is in the bundle**, (c) **what claim it does NOT support**. The "does NOT support" column is the guard: a PASS string, a green-looking JSON, a hash match or an index listing never promotes parity.
- **Grouping:** (1) plan/handoff/brief; (2) seven P0 packets + final P0 status + session plan/risks; (3) verification artifacts; (4) preserve-only hash witnesses; (5) three supersession/correction reports.
- **Exclusion discipline:** the bundle is *minimal*. The 300-row index, 23-row addendum, 28-row deep supplement and the individual `DEC_U_*` deep-pass reports are **not** bundle members — they are navigable background the owner already has. The three index-family documents in group 5 are included only because they carry the contradiction/supersession registers that govern interpretation of four specific topics.

---

## 1. Plan / handoff / brief (3 files)

| # | Exact path | Why it is in the bundle | What claim it does NOT support |
|---|---|---|---|
| 1.1 | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_acceptance_plan.md` | Governing owner-facing decision frame: defines the six parity conditions, the verdict template (`RESULT IS NOT GOOD` while `blocking_unverified` non-empty), the P0 register, and the forbidden action list. It is the authority the other bundle documents cite. | Does **not** support "parity achieved" or "a gate passed". It declares all six conditions unclosed, forbids `--ignore-history` / result-JSON deletion / threshold changes, and explicitly states donor execution and any parity claim are out of scope. |
| 1.2 | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_handoff_checklist.md` | The final sign-off index: 68 deliberately **unchecked** boxes over preserve-only hashes, port-internal artifacts, owner-only packets and regeneration commands; carries the verbatim reviewer line and the dominance statement "no item on this checklist closes donor parity". | Does **not** support "any checkbox is cleared", "any parity item complete", "a `[U]` retired" or "a ticket acknowledged". An unchecked `[ ]` means "COORD/owner must sign", not "failed" and not "done". |
| 1.3 | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_owner_brief.md` | Concise owner summary of donor-exact vs still-approximation, the six P0 experiments, honest verification status, preserve-only table and the exact verdict template. It is the 1–2 page orientation document before the detailed packets. | Does **not** support "the port is donor-exact / visually matched". It labels water, FOW, tick, blend, save, RNG and selection as `PORT APPROXIMATION` / `[U]` and states `RESULT IS NOT GOOD` unconditionally. |

> Note: `PORT1TO1_PLAN.md` (root of the wave) and `HANDOFF.md` are governing sources cited by these three documents but are **not** separate bundle members; their decision-relevant content is transcribed into 1.1–1.3.

---

## 2. Seven P0 packets + final status + session plan/risks (10 files)

Mapping: water covers three rows (P0-1 / P0-1b / P0-2); FOW = P0-3; tick = P0-4; blend = P0-5; save = P0-6; selection = P0-8; RNG = P0-7. Nine P0 rows, seven dedicated packets.

| # | Exact path | Why it is in the bundle | What claim it does NOT support |
|---|---|---|---|
| 2.1 | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_water_owner_protocol.md` | Owner-only run-book for P0-1/1b/2 (U12 reflection provenance, U4* scalar tuple, U1/U3/U5/U6); the single ordered GPU/debugger session spec on pinned `t_87f0f3c130b0`. | Does **not** support "water renders donor-exactly" or "the tuple/classification was captured". No water draws while U12 FBO is unbound; the packet is a run-book, and no owner session was executed. |
| 2.2 | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_fow_owner_protocol.md` | Owner-only P0-3 packet: fixed-seed reveal transects, `GetFOWLOSData` dumps, combine/occlusion/persistence/tint phases and zero-mismatch criteria. | Does **not** support "FOW grid/cell size is donor" or "a residual closed". `1 res = 1 m` and `fog_counts > 0` remain labelled `PORT APPROXIMATION`; the packet closes nothing by itself. |
| 2.3 | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_tick_owner_protocol.md` | Owner/COORD P0-4 packet: headless fixed-dt hash harness (12 players × 3600 frames × 3 seeds × 6 sequences) and single-surviving-order criterion. | Does **not** support "the donor tick order was recovered". `TICK_ORDER v1` stays labelled `PORT APPROXIMATION`; a surviving order would be port-internal self-consistency, not donor proof. |
| 2.4 | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_blend_owner_protocol.md` | Owner-only P0-5 packet: R-B1…B4 / R-C1/C2 plus W/S/A/R batteries, 3/3 byte-identical trials, `(0,0)` hard-cut control. | Does **not** support "donor interpolation was recovered" or "a weight curve is known". Port has zero `lerp`/`mix`/`slerp`; `requested_blend` is intent-only. |
| 2.5 | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_save_owner_protocol.md` | Owner-only P0-6 packet: paired known-state `.map` saves, one-field-at-a-time divergence, hexdump offsets and 3 repeats. | Does **not** support "byte parity of the save container". Wire format stays v5 additive-only `PORT EXTENSION`; every byte pattern in the packet is a *predicted expectation*, not an observed donor byte. |
| 2.6 | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_selection_owner_protocol.md` | Owner-only P0-8 packet: fixed rig `58 m / −32° / focal 400`, ≥5 surveyed markers, T1–T10 zero-pixel / zero-mismatch gates for projection, AABB, pick, drag, marquee and minimap. | Does **not** support "projection/picking is donor-matched". `FOV 17.27°`, nearest-single pick, depth tie-break and screen-UV bias remain `PORT APPROXIMATION` scaffolding. |
| 2.7 | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_rng_owner_protocol.md` | Owner/COORD P0-7 packet: S/G stream split, per-site draw counts, X21 oracle series (R20/L20/C300/U50/F1M/K0/A600) and native state-dump breakpoints. Closes the stale "no P0-7 packet" gap. | Does **not** support "the donor RNG stream was attributed" or "P0-7 closed". `[U]-G1` stays open; a state dump is not a GPU frame and no partial green wires a stream. |
| 2.8 | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_p0_final_status.md` | Definitive **nine-row** current P0 table: each row's exact blocker, deep-pass `[O]`/`[D]`, remaining `[U]`, packet/session id and status; explicitly records that no value was promoted by any deep pass. | Does **not** support "any P0 is CLOSED". All nine rows are `OPEN` (structure closed/value open, static narrowing only, or algebra closed/attribution open); `CLOSED` appears for no row. |
| 2.9 | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_p0_session_plan.md` | Seven ordered owner session blocks (4 GPU, 1 paired-save, 1 native-state-dump/harness, 1 harness-only); supersedes the advice-only six-packet ordering. | Does **not** support "a session was performed" or "a terrain Route A capture settled a P0". Sessions are specified, not run; a Route A terrain capture settles zero P0 rows. |
| 2.10 | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_session_risks.md` | Seven S1–S7 failure-mode registers: for each failure the only allowed actions are `REPEAT UNDER CORRECTED SETUP` or `KEEP [U] OPEN`; no threshold may be relaxed. | Does **not** support "a failure was waived", "a threshold relaxed" or "a retry until green". Any failure keeps its `[U]` and its P0 row open. |

> Excluded deliberately: `PORT1TO1_p0_packet_index.md` describes **six** packets and "P0-7 has no packet" — a stale reading preserved as flag S-1 in `PORT1TO1_deep_index2.md:100`, supplied in group 5. The seven packets above are the current set.

---

## 3. Verification artifacts (13 files)

### 3.1 MCP host probe (1)

| # | Exact path | Why it is in the bundle | What claim it does NOT support |
|---|---|---|---|
| 3.1 | `variant3d/tests/t_mcp_host.gd` | In-repo protocol constants for the live `cossacksgodotmcp` host probe (protocol `2025-03-26`, exactly 6 tools: `game.status`, `game.tick`, `camera.pan_to`, `game.screenshot`, `game.place_building`, `video.record_frames`; `game.tick({})` clean refusal). | Does **not** support "donor parity", a gate PASS, or that the fixed-step design is implemented. It is a protocol-level, port-internal telemetry probe with no parity field. |

### 3.2 Deterministic manifests / repeat verification (8)

| # | Exact path | Why it is in the bundle | What claim it does NOT support |
|---|---|---|---|
| 3.2a | `inbox/qa/captures/detcheck_20261113/manifest.json` | Primary COORD deterministic-capture manifest (seed `20261113`, `--capture-ticks 64`, 1280×720). One half of the two-run byte-identical `sha256_pixels` pair. | Does **not** support "donor A/B frame" or chain condition 6 CLOSED. Validates opt-in port-internal replay only; `parity=UNVERIFIED`. |
| 3.2b | `inbox/qa/captures/detcheck2_20261113/manifest.json` | Repeat COORD run manifest matching 3.2a; per-frame `sha256_pixels` byte-identical (`def18ad9…`, `18e1e72…`). | Same as 3.2a: a port-vs-port replay pair, not a donor match; no `[U]` closed. |
| 3.2c | `inbox/qa/captures/repcheck_20261113/manifest.json` | Primary manifest for the repeatability gate; `status=ok`, `byte_identical=true`, `mismatches=[]`, `kind="port-internal repeatability gate (NOT donor parity)"`. | Does **not** support condition 6 CLOSED — it moves condition 6 to **PARTIAL** only, and explicitly carries `parity="UNVERIFIED (not assessed)"`. |
| 3.2d | `inbox/qa/captures/repcheck_20261113/repeat_verification.json` | The primary-vs-repeat diff/repeat verification artifact (`byte_identical=true`, `status=pass`). | Does **not** support "a gate pass" or "a matched camera". Port-internal repeatability only. |
| 3.2e | `inbox/qa/captures/repcheck_20261113_repeat/manifest.json` | Repeat-run manifest paired with 3.2c/3.2d. | Does **not** support a donor comparison; `parity=UNVERIFIED` on both runs. |
| 3.2f | `inbox/qa/captures/finalcheck_20261127/manifest.json` | Point-in-time final repeatability primary manifest (SHA-256 identity recorded in `PORT1TO1_hash_manifest.md:89`); present and preserved, not re-adjudicated. | Does **not** support a donor A/B frame or parity promotion; not a fresh COORD ruling. |
| 3.2g | `inbox/qa/captures/finalcheck_20261127/repeat_verification.json` | Final repeatability diff artifact (identity at `hash_manifest.md:90`). | Does **not** support a gate result; port-internal diff only. |
| 3.2h | `inbox/qa/captures/finalcheck_20261127_repeat/manifest.json` | Final repeat-run manifest (identity at `hash_manifest.md:91`). | Does **not** support a matched-input manifest; `parity=UNVERIFIED`. |

> Frame PNGs and runner stdout/stderr inside these directories are **not** bundle members; the hash manifest records only the JSON manifest/diff artifacts (`PORT1TO1_hash_manifest.md:93`).

### 3.3 ROI metrics summary (1)

| # | Exact path | Why it is in the bundle | What claim it does NOT support |
|---|---|---|---|
| 3.3 | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_roi_metrics.md` | Report of the 14 executed `compare_frames.py` comparisons (14/14 exit 0, 0 refusals), the 14 diff/JSON rows and the mandatory `NOT_SHARED` camera notation. | Does **not** support "similarity %", "donor threshold PASS" or parity. All 14 rows are `parity="UNVERIFIED"`, `claim=null`, `camera=NOT_SHARED_donor-oblique_vs_port-17p27`; numbers are support cues only. |

### 3.4 Guard / claim audits (2)

| # | Exact path | Why it is in the bundle | What claim it does NOT support |
|---|---|---|---|
| 3.4a | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_final_guard_audit.md` | Static parity-string / approximation-label / preserve-mod guard: PASS in all four guard areas with 3 MINOR label gaps (GF1–GF3). Confirms no test weakening and no unguarded parity claim. | Does **not** support "a gate PASS". A label/string guard PASS is not a gate run, capture, donor comparison or parity result. |
| 3.4b | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_claim_final.md` | Post-guard C1–C5 parity-claim sweep across `reports/` and `variant3d/`: no live unguarded parity claim; C6 label-only hardening suggestions, none applied. | Does **not** support "donor fidelity" or "a gate/metric promoted to parity". It *negates* parity strings; it does not assert them. |

### 3.5 Hash manifest (1)

| # | Exact path | Why it is in the bundle | What claim it does NOT support |
|---|---|---|---|
| 3.5 | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_hash_manifest.md` | Point-in-time SHA-256 identity manifest for this minimal bundle: 25 rows; the three recorded baselines (P-2/P-4a/P-4b) matched at that read; donor pin recorded **by report id only**. | Does **not** support "donor fidelity", a gate pass, matching inputs or a same-camera A/B frame. Hashes certify artifact byte identity only; the donor `cossacks.exe` was not opened, hashed or executed. |

---

## 4. Preserve-only hash witnesses (5 files)

These are the actual byte-frozen repo artifacts behind §5.1 of `PORT1TO1_artifact_layout.md` and §2.1–2.2 of `PORT1TO1_hash_manifest.md`. Rule: never flip, revert, overwrite, "repair", re-apply or delete; hash before **and** after every capture.

| # | Exact path | Why it is in the bundle | What claim it does NOT support |
|---|---|---|---|
| 4.1 | `variant3d/config_donor_capture.json` | **P-2**, recorded baseline `aa857480…202da` (17,912 B) matched at the hash-manifest read. Keeps `backend=donor`, `demo_mill=true`, water `alpha_confine=true`/`shore_prox=false`. | Does **not** support "donor parity" or "preservation beyond byte identity". A hash match is point-in-time byte preservation only, not a gate pass. |
| 4.2 | `inbox/backup/main.gd.bak-COORD-I11` | **P-4a**, recorded baseline `3859b605…e71f8` (86,133 B) = V11 E1 / V65 §8 baseline; single-applied I11 seam witness. | Does **not** support "the seam may be re-applied" or "a donor behaviour claim". It certifies one byte state only; re-application or default flip is forbidden. |
| 4.3 | `inbox/backup/world3d.gd.bak-COORD-I11` | **P-4b**, recorded baseline `44ee96c0…ab07a` (37,084 B) = V11 E2 baseline; single-applied I11 seam witness, late-switch refusal preserved. | Same as 4.2: byte-witness only; no re-application, no parity implication. |
| 4.4 | `variant3d/config.json` | **P-1**, current hash `223767e5…d44e2` (15,981 B) matches the point-in-time reading only. Keeps `backend=donor`, `color_unify=true`, `fov_deg=17.27` (labelled `PORT APPROX`). | Does **not** support "preservation against a recorded baseline" — **no baseline exists**; and does **not** support "17.27° is a donor value". Never flip backend to hide a defect. |
| 4.5 | `variant3d/assets/models/manifest.json` | **P-3**, current hash `36f6a378…27231` (339,158 B) matches the point-in-time reading only. Keeps `ukr/buildings` bucket, EUR aliases, `field` conversions; rollback by id only. | Does **not** support "preservation against a recorded baseline" — **no baseline exists**; and does **not** support whole-file restore as a remedy. |

> Donor pin witness `t_87f0f3c130b0` (`X59_donor_bytes_seal`, recorded hash `87f0f3c1…c16`) is **not** a bundle file: the donor binary is outside the repo, recorded by report id only, was never opened/hashed/executed by the read-only workers, and is never an admissible A/B frame.

---

## 5. Three supersession / correction reports (3 files)

These three index-family documents carry the contradiction/supersession registers covering the four named topics: **tool `.oss`** (C-1), **capture progress** (C-2 / F-2), **team-win** (C-3 / F-3), **start-camera** (X-1). A later report does **not** make an earlier claim true.

| # | Exact path | Why it is in the bundle | What claim it does NOT support |
|---|---|---|---|
| 5.1 | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_evidence_index.md` | Original contradiction register §"Contradictions and superseded claims": **C-1** tool `.oss` (56 `pea<nat>_<tool>.oss` refute "no tool `.oss`"), **C-2** capture progress (no progress accumulator/majority/cooldown; port `capture_t` is approximation), **C-3** team-win (donor-verbatim in `_misc_CheckEndGame`, not port policy). Underlying source reports: `DEC_U_tool_attach.md`, `DEC_U_capture_state.md`, `DEC_U_scenario_win.md`. | Does **not** support "the earlier claim is now true" or "a `[U]` closed by the flip". The file-scope ABSENT verdicts stand where stated; capture `capture_t` stays a labelled port residual; no parity follows. |
| 5.2 | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_evidence_index_addendum.md` | Carries the contradictions forward with point-in-time corrections: **F-2** capture progress / `capture_t` reaffirmed as a port residual that must not be donor-cited or deleted; **F-3** team-win reaffirmed (`PORT1TO1_endgame_protocol.md:114-123` T2, U-F2 row at `:222`); plus F-1/F-4/F-5/F-6 status supersessions. | Does **not** support "a new contradiction was resolved" or "a ticket acknowledged". Flags are preserved, not repaired; a later report does not make an earlier claim true; no gate promoted. |
| 5.3 | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_deep_index2.md` | **X-1** records the start-camera supersession: `DEC_U_start_deep.md` supersedes `DEC_U_start_positions.md` §6 EV-CAM-1 ("NO start→camera wiring"); camera is wired via `doprogress.inc:41`, path-scope verdict flips to WIRED-VIA-DOPROGRESS. **X-7** records the stale six-packet / P0-7-no-packet wording (S-1). | Does **not** support "camera numerics recovered" or "P0-7 closed". The file-scope ABSENT verdict stands; target/height/`time=0` smoothing stay `[U]`; the RNG packet listing does not close P0-7. |

---

## 6. Explicit statements and claim register

1. **Parity is UNVERIFIED.** `parity.claim = NONE`, `parity.status = "UNVERIFIED"`, `visual_parity_claim = false`; six-condition chain **0/6 CLOSED** (condition 6 **PARTIAL**, port-internal repeatability only). No donor GPU A/B frame exists; no matched camera/ROI manifest; no COORD zero-mismatch ruling.
2. **`RESULT IS NOT GOOD` while `blocking_unverified` is non-empty** — all nine P0 rows plus the `PORT1TO1_u_register_update.md` tails. `RESULT IS GOOD` is admissible only when `blocking_unverified = []` and all six conditions hold — not today.
3. **No item in this bundle closes donor parity.** Groups 1–5 are respectively: decision frame/sign-off index, owner-only run-books, port-internal verification artifacts, byte-witnesses, and contradiction registers. None supplies a donor frame, a matched-input manifest, a fresh COORD ruling, an acked ticket set (575/582/585 remain UNACKED), a completed spec/toolchain with `blocking_unverified = []`, or a zero-mismatch geometry+frame ruling.
4. **No approximations are endorsed.** All `PORT APPROXIMATION` / `[U]` labels and P0 hard-fails remain intact. A "close" value, metric, still, replay pair, port fallback or labelled substitute settles nothing.
5. **No parity claim is made.** Forbidden phrasing remains forbidden: "matches donor", "close to donor", "donor parity", "similarity %", "donor threshold PASS", "gate PASS" derived from a capture, or `--assert-ab-verified` treated as verification.
6. **Read-only scope.** This worker wrote exactly one repository file (this report). No code, Godot, runner subcommand, gate, capture, ROI metric, donor binary or donor GPU frame was executed; no git mutation; no source/shader/config/asset/test/result-JSON/backup change. Every listed path was checked only for existence.
7. **Bundle size = 34 files** (3 + 10 + 13 + 5 + 3), within the ≤40 limit; minimal selection with the excluded corpus documented in §0 and §2.

| # | Claim | Basis |
|---|---|---|
| 1 | The 34 paths are the minimal owner-review bundle, grouped into five named groups. | [O] read-only `Test-Path` of every path; groupings from cited governing reports |
| 2 | Each row's "does NOT support" guard prevents a PASS string, hash match, index listing or supersession from being read as parity. | [D] `final_gates.md`, `hash_manifest.md:32-37`, `evidence_index.md:15`, `deep_index2.md:94` |
| 3 | Seven packets cover nine P0 rows; all rows OPEN; the stale six-packet index is superseded, not repaired. | [D] `p0_final_status.md §1`, `p0_session_plan.md:47`, `deep_index2.md:100` |
| 4 | Parity UNVERIFIED; `RESULT IS NOT GOOD`; no approximation; no parity claim; no bundle item closes parity. | [D] `owner_brief.md:78-94`, `handoff_checklist.md:295-296`, `artifact_layout.md:259-284` |

---

*End of PORT1TO1_bundle_index. Read-only minimal-bundle index; exactly one repository file written. Parity UNVERIFIED; `RESULT IS NOT GOOD` while `blocking_unverified` is non-empty. No approximation, no parity claim; no item in this bundle closes donor parity.*
