---
id: PORT1TO1-CHAIN-UPDATE2-2026-11-27
title: "Read-only re-audit of the six-condition donor-parity chain against the CURRENT tree, after the new static [D] facts, implementations and audits"
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: "WORKER CHAIN-UPDATE2 — read-only re-audit; exactly one report written"
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_chain_update2.md
updates: "docs/terrain_swarm_2026-11-26/reports/PORT1TO1_parity_chain.md and PORT1TO1_parity_recheck.md (statuses reaffirmed; no status cell changed)"
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION
created: 2026-11-27
labels: [OBSERVED, DERIVED, UNVERIFIED, "PORT APPROXIMATION", PRESERVE-ONLY, NO_PARITY_CLAIM]
parity_status: UNVERIFIED
parity_claim: false
parity_claim_code: NONE
visual_parity_claim: false
verdict: "RESULT IS NOT GOOD — blocking_unverified is non-empty; six-condition chain 0/6 CLOSED; no donor GPU A/B frame; no matched camera; no COORD ruling; static [D] facts narrow experiments only; no approximation, no parity claim"
scope_guard: "Repo file/line reads and read-only directory/hash listings of existing files only. No source, shader, asset, config, test, fixture, result JSON, backup, queue file, git state, Godot process, runner job, gate, capture, ROI metric or donor binary was modified, created or executed. No donor frame was produced or compared; no donor execution. Exactly one repository file written: this report."
governing_sources:
  - docs/terrain_swarm_2026-11-26/reports/V109_owner_answer_final.md (:74, :91)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_owner_decisions.md (:12-15, :32, :39-40, :319-322, :333, :353)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_parity_chain.md (:38-58, :86, :89, :129-130, :152)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_parity_recheck.md (:44, :61, :63, :101-107, :117-118, :141)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_claim_recheck4.md (:11-12, :78, :128, :144, :147)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_roi_register.md (:27, :86, :211-214, :220)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_acceptance_plan.md (:31, :177-190, :252, :269, :273-291, :368)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_fixed_step_plan.md (:29-34, :665-671, :696-699)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_b_angle_final.md (:12, :27, :60, :62, :73, :88-93)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_nb4.md (:132-135)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_nb5.md (:19-23)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_nb2.md (:17, :28-34)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_tver_deep.md (:13, :40-41, :238)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_ureg_ctor.md (:18, :29, :130-134, :167-171)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_b45_residual.md (:100)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_handoff_sync.md (:31, :39-40)
  - docs/terrain_swarm_2026-11-26/PORT1TO1_PLAN.md (:258, :261, :265)
  - variant3d/scripts/terrain_donor_gen.gd (:451-455)
  - variant3d/scripts/terrain_donor_mesh.gd (:1908-1915, :1942-1948, :2018-2029)
  - variant3d/scripts/game.gd (:683-685, :686-694, :709)
  - variant3d/scripts/camera.gd (:170-178), variant3d/scripts/camera3d.gd (:474-492)
---

# PORT1TO1 — six-condition parity chain, update 2 (current tree, 2026-11-27)

> **Mandatory reviewer line (verbatim, `PORT1TO1_owner_decisions.md:15/32`, `PORT1TO1_acceptance_plan.md:28-29`):**
> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

> **This is a read-only re-audit, not a new claim.** It re-reads the six-condition chain against the files as they exist in the current tree (2026-11-27). It does not execute the donor, Godot, a runner job, a gate, a capture or an ROI comparison; it does not close any `[U]`, wire a value, weaken a test or promote a metric. It does not change any status cell of `PORT1TO1_parity_chain.md` or `PORT1TO1_parity_recheck.md`: **no condition has changed status** since those two documents were written. Exactly one repository file is written: this report.

## 0. Bottom line (do not quote selectively)

- **The chain is defined at `V109_owner_answer_final.md:91` / `PORT1TO1_owner_decisions.md:319`: all six conditions are required.** Until **all six** hold, `parity.claim = NONE`, `parity.status = "UNVERIFIED"`, `visual_parity_claim = false` and **`RESULT IS NOT GOOD`** (`V109:74/91`, `owner_decisions:12-14/39/320/322`). No tier above 2 exists (`owner_decisions:40`, `acceptance_plan:368`).
- **Still 0/6 conditions CLOSED.** Statuses are identical to the two predecessor audits: condition 1 BLOCKED, condition 2 PARTIAL (port-internal only), condition 3 BLOCKED, condition 4 BLOCKED, condition 5 BLOCKED, condition 6 PARTIAL (internal repeatability only — the corrected cell of `parity_recheck.md:61`). **No new static fact or implementation promoted any condition to CLOSED, and none demoted or upgraded any status cell** (`parity_recheck.md:44/63`, `claim_recheck4.md:78/144`).
- **What landed since the predecessors changes the *experiments*, not the *statuses*.** randkey derivation `[D]` + implementation, exact quad-copy site `[D]` + implementation, relief-field defaults `[D]`, T-VER shipped-envelope 53 vs port 92/240² `[D]`, first-camera wire implementation (2D + 3D), UREG-CTOR partial ownership `[D]`, and the B6/B9/B10/B45 residuals are all recorded in the current tree. Every one is a static recovery or a label/telemetry-only implementation; every one leaves a named `[U]` residual and an owner-only zero-mismatch experiment. None is a donor frame, a matched camera, a COORD ruling or a green gate.
- **`blocking_unverified` is non-empty** — all nine P0 rows (P0-1, P0-1b, P0-2…P0-8) plus the register tails remain OPEN (`owner_decisions:39/322/353`, `acceptance_plan:273-291`, `roi_register:220`, `claim_recheck4.md:144`, `handoff_sync:14`). Therefore **`RESULT IS NOT GOOD`**, unconditionally (`V109:74`, `owner_decisions:14/39`, `acceptance_plan:33/269`).
- **No unit-test gate and no ROI metric promotes parity.** `compare_frames.py` always prints `parity=UNVERIFIED` (`roi_register:27/211-214`); the deterministic-capture manifests themselves record `parity=UNVERIFIED` (`parity_recheck.md:88/119`); owner acceptance is snapshot/video-driven, not unit-test gates (`acceptance_plan:31`), and `--assert-ab-verified` never promotes parity (`acceptance_plan:252`).

---

## 1. The six conditions — current status and the effect of the new facts

Source of the chain: `V109:91` (verbatim) / `owner_decisions:319`. The "Closes only with" column names the exact artifact/act; **none of these artifacts exists in the current tree**. The last column is the only place the new facts are relevant, and in every row they narrow an experiment rather than close a condition.

| # | Condition (`V109:91`) | Status now (unchanged from predecessors) | Evidence from current tree | Effect of the new `[D]` facts / implementations | Closes only with |
|---|---|---|---|---|---|
| 1 | Owner supplies a genuine same-size/seed/type/season/camera/ROI **donor GPU frame** | **BLOCKED** (same as `parity_chain:51`, `parity_recheck:56`) | `X39_ab_feasibility.md:32-37/74-81/104-110`; `acceptance_plan:188-190`; `roi_register:45-70` (12 third-party H.264 stills of unknown build/camera/zoom/compression); `claim_recheck4:144`. No worker route may produce a donor GPU frame; only owner-launched Route A is viable and it is not executed. | **None.** No static decoding or implementation can create a donor GPU frame. The new T-VER envelope recovery (`DEC_U_tver_deep:39-41`) describes shipped artifacts, not a captured A/B frame. | Owner-run donor PNG outside the repo + written key/camera/size/season/ROI manifest per `X39 §3`; donor binary never executed by a worker. Necessary, not sufficient (`X39:34/178`). |
| 2 | An admissible non-blank 1280×720 candidate capture, `script_error_lines=0`, pinned seed/camera/size, identical ROI | **PARTIAL (port-internal only)** (same as `parity_chain:52`, `parity_recheck:57`) | The `detcheck`/`detcheck2` manifests are mechanically admissible (`status=ok`, `headless=false`, `resolution_observed=1280×720`, seed 20261113, config SHA `aa857480…202da`) but are port-vs-port runs carrying `parity=UNVERIFIED`; `acceptance_plan:184` admits them "as port-internal evidence only — still no donor A/B"; `roi_register:86` forces `--camera NOT_SHARED_donor-oblique_vs_port-17p27`. `cap_fullport6/7/8.png` remain absent. | **Narrows the camera-matching experiment, does not close it.** The 2D+3D first-camera wire (`handoff_sync:31/39`, `game.gd:686-694/709`, `camera.gd:170-187`, `camera3d.gd:474-492`) implements a donor-text-derived one-shot target (`doprogress.inc:41`) but explicitly writes "NO PARITY CLAIM", invents no FOV/zoom/height constant, and leaves donor height/time args + native clamp `[U]` CAM-derive/CAM-0. No pinned donor-matched camera exists; `roi_register:86` still asserts no shared camera. | Fresh windowed capture with `status=ok`, `complete=true`, 1280×720, `script_error_lines=0`, pinned seed/camera/size, paired with a real donor frame at the same ROI (`acceptance_plan:177-186`). |
| 3 | Inputs **matched and labelled** (A/B-L1 same keys, or A/B-L2 importer-rendered same geometry) | **BLOCKED** (same as `parity_chain:53`, `parity_recheck:58`) | `X39:137` donor has no numeric seed UI; `X39:169-171` L1 requires matched keys/size/type/season/camera/ROI and still does not certify parity; L2 needs the D04 §7 importer upgrade. No owner manifest with both donors' `randkey0/1` exists. | **Narrows the key-input experiment only.** `DEC_U_nb4:132-135` closes the `GenerateMapRandKey` *formula* `[D]`: `randkey0=0` constant, `randkey1=Random($7FFFFFFF)` one draw, no name/settings input; `IMPL-RANDKEY-DERIV` records this as "LABEL / DATA / TELEMETRY ONLY… NEVER read by generation… every RNG reseed path untouched" (`terrain_donor_gen.gd:451-455`). Runtime invocation timing, U-KEY2 (key0-discard), U-MAP (shipped-map override) and the Delphi stream state/source stay `[U]` (`DEC_U_nb4:135`, `b_angle_final:88`). A static law is not a matched-input manifest. | Owner manifest with both donors' `randkey0/1`, size enum, map type, season, camera constants and fractional ROI per `X39 §3`; plus D04 importer upgrade for L2. |
| 4 | Fresh gates green, not stale, 575/582/585 acknowledged, `app/**` byte-identical | **BLOCKED** (same as `parity_chain:54`, `parity_recheck:59`) | `owner_decisions:322` — result JSONs stale, `assert_clean` last read DIRTY with 575/582/585 unacked, `inbox/qa/**` PENDING; `full_project_audit:101` Q-1 "No gate green", `terrain_qa_spec.json` SCHEMA_ONLY; `ack_evidence:36` 575/582/585 UNACKED. No D1 dumps (5 streams × 3 sizes, zero byte difference), no D3 run integrity, no COORD gate ruling. | **None.** The new reports are static reads and label-only implementations; none produces a fresh result JSON, a D1 dump, a D3 integrity record or an `assert_clean` CLEAN. Preserve-only witnesses remain as recorded (`parity_chain:110-116`). | Fresh runner result JSONs with mtime after job START; D1 zero byte difference; D3 CLEAN, `script_error_lines=0`; selftest 29/29, uitest 17/17, `t_render_mode` PASS, `t_map_variety` 5/5; `assert_clean` CLEAN with 575/582/585 acknowledged with evidence-backed reasons; `app/**` byte-identical (`owner_decisions:319-320`). |
| 5 | Spec/toolchain evidence completed — §§01–14 READY, X15 root manifest, I05 atlas/I03 feed, N17 populated and signed, **`blocking_unverified = []`** | **BLOCKED** (same as `parity_chain:55`, `parity_recheck:60`) | `full_project_audit:13-16/49/61-63/101/117` — ~45 approximations, atlas tier ABSENT, Objects feed unwired, N17 SCHEMA_ONLY, root `manifest.json` absent; `N17_gaps` 17 runtime gaps `[U]`; `owner_decisions:322` `blocking_unverified` non-empty; `acceptance_plan:289` RUNTIME-only blockers. | **None.** The B-angle and NB audits add static `[D]` facts while keeping every class-A value/behaviour item `[U]` (`b_angle_final:27/73`, `DEC_U_b45_residual:100`). They do not emit the root manifest, build/bind the atlas, wire the I03 feed, sign N17 or empty `blocking_unverified`. | All §§01–14 READY, X15 root `manifest.json` emitted, I05 atlas built and bound, I03 feed consumed with `props_total>0 && fallback_used=false`, N17 populated and signed, `blocking_unverified = []` ruled by COORD (`owner_decisions:319-320`). |
| 6 | **Demonstrated byte-identical geometry + pixel-identical frame** under the proven-matched manifest, ruled by **COORD explicitly** | **PARTIAL — unchanged from `parity_recheck:61`** | Two deterministic capture runs produced byte-identical per-frame `sha256_pixels`, PNG files and `seq_index.json` — *internal repeatability only*; both manifests record `parity=UNVERIFIED` (`:22`); no donor A/B, no shared camera, no geometry-byte equality, only 2 frames/64 ticks (not 24/768), no COORD ruling (`parity_recheck:99/101-107`, `claim_recheck4:144`). | **Narrows and even statically contradicts the geometry claim; still not CLOSED.** `DEC_U_tver_deep:40-41/238` proves the port's pinned `generator_version=92` / `240²` **does NOT byte-match** shipped `53`-envelope / `320²`-`384²` artifacts (zero-mismatch FAILS at word 0). `DEC_U_nb5:19-23` closes the copy *instruction map* `[D]` while the value-level byte dump stays `[U]`; `IMPL-QUAD-COPY` is "TELEMETRY ONLY: no geometry, mesh attribute, shader or sim change" (`terrain_donor_mesh.gd:1942-1948`, residual `[U]` U-10b at `:2018-2029`); `DEC_U_ureg_ctor:18/130-134` proves only **partial** single-instance ownership while height-texture identity/values stay `[U]` and the hard-fail is kept. None demonstrates donor geometry-byte equality or a matched frame. | A COORD-signed owner report with demonstrated geometry-byte equality and a pixel-identical **matched** frame (zero mismatch), explicitly ruling condition 6 under the proven-matched manifest. No such report exists. |

**Chain result: `parity.claim = NONE`, `parity.status = "UNVERIFIED"`, `visual_parity_claim = false`, `RESULT IS NOT GOOD`.** Zero of six conditions is CLOSED (conditions 2 and 6 PARTIAL — both port-internal only; conditions 1/3/4/5 BLOCKED). Even if conditions 2, 4 and 6 were later made green, the ceiling remains "gates green / internal consistency PASS / donor parity UNVERIFIED" (`owner_decisions:39/320`, `V109:91`, `acceptance_plan:368`).

---

## 2. Inventory of the new facts — exactly what each one is and what it does not do

This section is the reason the six statuses did not move. Each item is `[O]/[D]` static recovery or a label/telemetry-only implementation with a surviving `[U]` residual.

| New fact (current tree) | Exact status | What it narrows | What it does **not** do |
|---|---|---|---|
| **randkey derivation** — `DEC_U_nb4:132-135`; impl `terrain_donor_gen.gd:451-455` (`IMPL-RANDKEY-DERIV`, plan `:258` DONE) | Formula CLOSED `[D]`; U-KEY2 / U-MAP / U-SS / U-ONLY / U-TIME still `[U]` | The matched-input experiment (condition 3): the derivation law is fixed as `randkey0=0`, `randkey1=Random($7FFFFFFF)`, one draw, no name/settings input. | Not read by generation; no seed derived or invented; every RNG reseed path untouched; no owner manifest; no donor A/B; no parity claim. |
| **exact quad-copy site** — `DEC_U_nb5:19-23`; impl `terrain_donor_mesh.gd:1908-1915/1942-1948/2018-2029` (`IMPL-QUAD-COPY`, plan `:261` DONE) | Static instruction/offset map CLOSED `[D]`; value-level dump `[U]` U-10b | The geometry transport question inside condition 6 (invocation chain, two 32 B `rep movsd` row lifts, 4-way scatter, `+0x0b` anchor). | No geometry, mesh-attribute, shader or sim change; donor VALUES still UNVERIFIED; owner write-breakpoint probe still required; no donor frame. |
| **relief field defaults** — `DEC_U_nb2:17/28-34` (`b_angle_final:86`) | CODE property/API tables + parser binding + wrapper arities + 5 shipped `pattern.lib` concretes `[O]/[D]`; per-pattern floats, angle-use, `Objects[]→mesh` binding, 675 undumped sections `[U]` | The relief-value experiment inside condition 5/6 (field names, offsets, defaults, section concretes). | No per-pattern float promoted into the generator; no angle/use rule proven; no mesh binding recovered; no value wired. |
| **T-VER shipped envelope 53 vs port 92/240²** — `DEC_U_tver_deep:13/40-41/238` | Literals `[O]/[D]`; live selectors (`gRecordGeneratorVersion`, `mapsize`, live terraintype index) `[U]` | The generator-version/mapsize experiment inside conditions 3 and 6: the port's current pin fails a zero-mismatch check at word 0 and on extent, so owner live-settings dump + paired-save battery is required. | No version promoted (92-as-current-script-word and 53-as-shipped-envelope-word are both only observed literals); no parity; no donor runtime session. |
| **first-camera wire, 2D + 3D** — `handoff_sync:31/39`; `game.gd:683-685/686-694/709`; `camera.gd:170-187`; `camera3d.gd:474-492` (plan tasks 221/227 DONE, parses OK) | Static wire target `[O]`; camera height/time args and native clamp `[U]` | The matched-camera experiment inside conditions 2 and 3 (one-shot `startx/starty` target via the existing `jump_to_world()` API). | No new FOV/zoom/height constant, no `HEIGHT_SCALE`; FOV 17.27° stays a labelled PORT APPROXIMATION (`parity_chain:72-74`); `--camera NOT_SHARED…` unchanged; "NO PARITY CLAIM" in source. |
| **UREG-CTOR partial ownership** — `DEC_U_ureg_ctor:18/29/130-134/167-171` | Partial single-instance ownership `[D]`; U3 identity/values `[U]` | The water height-texture identity question (one `C` owns uniform slots + descriptor pointer + height slot; height pointee class unproven). | No texture name/id/unit/size invented; `C+0x54…+0x64` ctor defaults are not hmap supply; hard-fail kept; no parity claim. |
| **B4/B5 residual + final class-B table** — `DEC_U_b45_residual:100`; `b_angle_final:12/27/73/93` | Property tables only; kernel/radius/`mb` semantics/live version `[U]`; 14/14 original B executed (B4/B5 partial), 6/7 NB | The class-B static backlog; confirms the only new numeric derivation is NB-4 and NB-2's `[D]` are parser field-defaults. | "Class-B static results never close class-A value/behaviour items"; no P0 closed; no gate PASS; no parity claim. |

**Reading rule:** a `[D]` structural/arithmetic fact closes only the named *static* question. It is not a promoted generator value, not a wired behaviour, not a green gate and not donor parity (`b_angle_final:27`, `parity_chain:58`).

---

## 3. Reaffirmations (unchanged by this update)

1. **Static `[D]` facts only narrow experiments.** Every new `[D]` is paired with a surviving `[U]` and an owner-only zero-mismatch termination (`DEC_U_nb4:135`, `DEC_U_nb5:20`, `DEC_U_nb2:17`, `DEC_U_tver_deep:40-41`, `DEC_U_ureg_ctor:18`, `DEC_U_b45_residual:100`, `b_angle_final:27/73`). The formula for a derivation, the instruction map for a copy, a field-default table, a shipped-envelope literal, a static wire target and a partial ownership edge are search bounds for a later experiment — never a substitute for the experiment and never a parity claim. `claim_recheck4:115-128` confirms no deep pass promoted a static finding to behavioural parity.
2. **Deterministic repeats are port-internal.** The `detcheck`/`detcheck2` byte-identical `sha256_pixels`, PNG files and `seq_index.json` establish only two-run repeatability of the port under a fixed seed/config (`parity_recheck:99/101-107`). Both manifests record `parity=UNVERIFIED` (`:22`); there is no donor comparison, no geometry-byte equality, no 24-frame/768-tick §8 test, no shared camera and no COORD ruling. Even a passing `fixed_step_plan §8` two-run pair remains port-internal self-consistency only (`fixed_step_plan:665-671`).
3. **Gates and ROI metrics never promote parity.** Every `compare_frames.py` run and every refusal prints `parity=UNVERIFIED`; MAE/RMSE/max error/differing-pixel fraction/Pearson/histogram correlation/intersection/chi-square/the absolute-difference PNG/`--assert-ab-verified` are support cues with no promotion threshold (`roi_register:27/196-222`, `X39:169-171`). A `PASS` selftest, `t_render_mode`/`t_map_variety`, D1 hash equality and the deterministic manifests are likewise port-internal support cues only (`acceptance_plan:31/252`, `determinism_audit:204`, `fixed_step_plan:670-671`, `parity_chain:129-130`, `parity_recheck:117-118`, `claim_recheck4:52`). No gate is green (`full_project_audit:101`, `acceptance_runbook:326`).
4. **Parity stays UNVERIFIED.** `parity.claim = NONE`, `parity.status = "UNVERIFIED"`, `visual_parity_claim = false`; no tier above 2 exists (`owner_decisions:12-14/39-40/320`, `V109:91`, `acceptance_plan:368`).
5. **`RESULT IS NOT GOOD`** because `blocking_unverified` is non-empty — nine P0 rows open, no donor GPU A/B frame, no admissible matched capture, no COORD ruling (`owner_decisions:14/39/322/353`, `V109:74/91`, `acceptance_plan:33/269`, `roi_register:220`, `claim_recheck4:144`).
6. **No approximation, no parity claim, no execution.** This audit adopted no approximation, made no parity claim, weakened no test/gate, and performed no code/Godot/git/donor execution. Exactly one repository file was written: this report.

---

## 4. Why none of the six conditions can be CLOSED here

Closure of any condition requires artifacts this read-only worker cannot produce and the current tree does not contain:

- **Conditions 1, 2, 3** require an owner-supplied donor GPU frame (`X39:32-37/104-110`), an admissible capture paired to it at an identical ROI, and a matched/labelled input manifest with both donors' keys and camera constants (`X39 §3`, `V109:91`). Workers are forbidden from executing the donor (`owner_decisions:36-38`, `acceptance_plan:188-190`); the new static key/camera facts narrow those experiments but cannot supply their artifacts. `--camera NOT_SHARED_donor-oblique_vs_port-17p27` remains mandatory (`roi_register:86`).
- **Conditions 4, 5** require fresh, non-advisory, COORD-ruled gates (575/582/585 acknowledged, `app/**` byte-identical) and completed spec/toolchain evidence with `blocking_unverified = []` (`owner_decisions:319-322`). Static audits and label-only implementations produce neither; `blocking_unverified` is non-empty and all nine P0 rows remain open.
- **Condition 6 (PARTIAL)** requires a COORD-signed owner report demonstrating geometry-byte equality and a pixel-identical **matched** frame with zero mismatch (`V109:91`, `acceptance_runbook:326`, `artifact_layout:270`, `final_guard_audit:34`, `HANDOFF:445`). Internal two-run repeatability is not that report. The new T-VER `[D]` fact makes the current port pin fail the byte-match at word 0, and the quad-copy and UREG-CTOR `[D]` facts close only static maps/partial ownership while their value/identity residuals stay `[U]` — so the owner live-settings dump, paired-save battery and GL capture experiments, not more static decoding, are what could inform a future ruling. A passing replay pair still leaves `parity=UNVERIFIED` (`fixed_step_plan:665-671`).

**A PARTIAL is not a CLOSE.** Conditions 2 and 6 are port-internal partial satisfactions only; they do not accumulate into parity. All six conditions must hold simultaneously, and the ceiling even then is "gates green / internal consistency PASS / donor parity UNVERIFIED" (`owner_decisions:39`, `V109:91`, `acceptance_plan:368`).

---

## 5. Exact final verdict line

The exact, unambiguous verdict of this re-audit is the following single line (repeated verbatim as the closing line of this report):

`parity.claim = NONE; parity.status = "UNVERIFIED"; visual_parity_claim = false; six-condition chain 0/6 CLOSED — condition 1 BLOCKED, 2 PARTIAL (port-internal only), 3 BLOCKED, 4 BLOCKED, 5 BLOCKED, 6 PARTIAL (internal repeatability only); RESULT IS NOT GOOD — blocking_unverified is non-empty; no donor GPU A/B frame, no matched camera, no COORD ruling; static [D] facts narrow experiments only; deterministic repeats are port-internal; no gate or ROI metric promotes parity; no approximation, no parity claim.`

---

## 6. Claim register

| # | Claim | Label |
|---|---|---|
| 1 | Chain is `V109:91` / `owner_decisions:319`; all six required; **0/6 CLOSED**; no status cell changed from `parity_chain.md`/`parity_recheck.md` | [D] report reads |
| 2 | New facts landed: randkey derivation `[D]`+impl, quad-copy site `[D]`+impl, relief-field defaults `[D]`, T-VER 53-vs-92/240² `[D]`, 2D+3D camera-wire impl, UREG-CTOR partial ownership `[D]`, B6/B9/B10/B45 residuals | [O]/[D] current-tree reads (`b_angle_final:43-50`, plan `:249-265`) |
| 3 | Each new `[D]` closes only a static question and leaves a named `[U]` residual with an owner-only zero-mismatch experiment | [D] `DEC_U_nb4:135`, `DEC_U_nb5:20`, `DEC_U_nb2:17`, `DEC_U_tver_deep:40-41`, `DEC_U_ureg_ctor:18`, `DEC_U_b45_residual:100`, `b_angle_final:27/73` |
| 4 | `IMPL-RANDKEY-DERIV` and `IMPL-QUAD-COPY` are label/data/telemetry-only: no generation, geometry, shader or sim change; residuals `[U]` | [O] `terrain_donor_gen.gd:451-455`, `terrain_donor_mesh.gd:1942-1948/2018-2029`, plan `:258/:261` |
| 5 | 2D+3D camera wire invents no FOV/zoom/height constant; height/time args + native clamp `[U]`; "NO PARITY CLAIM"; `--camera NOT_SHARED…` unchanged | [O] `handoff_sync:31/39`, `game.gd:683-685/686-694/709`, `camera.gd:170-178`, `camera3d.gd:474-492`, `roi_register:86` |
| 6 | T-VER port pin 92/240² does NOT byte-match shipped 53-envelope/320²-384²; selectors stay `[U]` | [O]/[D] `DEC_U_tver_deep:13/40-41/238`, `handoff_sync:34` |
| 7 | Deterministic `detcheck`/`detcheck2` repeatability is port-internal; manifests carry `parity=UNVERIFIED`; no donor A/B, no COORD ruling, 2 frames/64 ticks not 24/768 | [O]/[D] `parity_recheck:61/99/101-107/119`, `claim_recheck4:144`, `fixed_step_plan:665-671` |
| 8 | No gate is green; no gate or ROI metric promotes parity; `blocking_unverified` non-empty (nine P0 rows) | [D] `owner_decisions:322/353`, `acceptance_plan:31/252/269`, `roi_register:27/220`, `full_project_audit:101`, `claim_recheck4:144` |
| 9 | No approximation adopted, no parity claim, no test/gate weakened, no code/Godot/git/donor execution; exactly one repository file written | [O] scope guard |

---

parity.claim = NONE; parity.status = "UNVERIFIED"; visual_parity_claim = false; six-condition chain 0/6 CLOSED — condition 1 BLOCKED, 2 PARTIAL (port-internal only), 3 BLOCKED, 4 BLOCKED, 5 BLOCKED, 6 PARTIAL (internal repeatability only); RESULT IS NOT GOOD — blocking_unverified is non-empty; no donor GPU A/B frame, no matched camera, no COORD ruling; static [D] facts narrow experiments only; deterministic repeats are port-internal; no gate or ROI metric promotes parity; no approximation, no parity claim.
