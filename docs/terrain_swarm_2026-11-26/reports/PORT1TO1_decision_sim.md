---
id: PORT1TO1-DECISION-SIM-2026-11-26
title: "Decision-simulation brief — authorize vs decline the owner-only Route A donor GPU A/B capture (full 1:1 Cossacks 3 donor port)"
worker: DECISION-SIM (read-only subagent)
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_decision_sim.md
files_created: [docs/terrain_swarm_2026-11-26/reports/PORT1TO1_decision_sim.md]
files_edited: []
scope_guard: "Repo/doc file reads only. No source, shader, asset, config, test, fixture, manifest, result JSON, backup, queue, app/ byte or git state was modified, created or executed; no Godot process, runner subcommand, gate, capture, ROI metric or donor binary was run; no donor GPU frame was produced or compared. Exactly one repository file written: this report."
labels: [DECISION_SIMULATION, OWNER_ONLY_ROUTE_A, "PORT APPROXIMATION", PARITY_UNVERIFIED, NO_APPROXIMATION, NO_PARITY_CLAIM]
parity_status: UNVERIFIED
parity_claim: NONE
visual_parity_claim: false
verdict: "RESULT IS NOT GOOD — blocking_unverified is non-empty; six-condition chain 0/6 CLOSED; no donor GPU A/B frame; no approximations; no parity claim."
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
governing_sources:
  - docs/terrain_swarm_2026-11-26/CHARTER.md (§2, §4 :26-30, :66-82)
  - docs/terrain_swarm_2026-11-26/reports/X39_ab_feasibility.md (§0, §2 Route A, §3 :113-160, §4 :163-192, §5-8)
  - docs/terrain_swarm_2026-11-26/reports/V109_owner_answer_final.md (:74, :76-79, :89-91)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_owner_decisions.md (§0 :36-42, §9 :315-323, §10, §11)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_parity_chain.md (§0 :36-41, §1 :45-58)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_parity_recheck.md (§0 :40-46, §1 :50-63, §2-3)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_p0_packet_index.md (§1-3)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_acceptance_plan.md (§2.3-2.4 :177-190, §4 :234-254, §5 :258-269, §6 :273-291, §9 :355-370)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_gate_audit.md (§0, §2-6)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_roi_register.md (§0, §6-8)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_owner_brief.md (§3, §5)
  - docs/terrain_swarm_2026-11-26/HANDOFF.md (§4-5 :128-139, §7 :159-161, §9.21)
---

# PORT1TO1 — decision simulation: authorize / decline the owner-only Route A donor capture

> **Mandatory reviewer line, verbatim (`PORT1TO1_owner_decisions.md:15/32`, `PORT1TO1_acceptance_plan.md:28-29`):**
> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

> **What this document is.** A read-only decision simulation for the owner. It reports the exact ordered steps of the two branches and their honest consequences. It **does not recommend either branch**, issues **no execution instruction to any worker or to the assistant**, and **does not relax the read-only rule**. Route A is an **owner-only** action (`X39:32-37`, `CHARTER §4`: "No donor executable is run, no donor binary is copied or committed. Donor material = private use only."). No approximation is adopted and no parity is claimed in either branch.

---

## 0. Fixed baseline — the state both branches start from (do not quote selectively)

- The parity chain is the six **conditions** at `V109:91` / `owner_decisions:319`; **all six** are required, and parity has no tier above 2 (`owner_decisions:40`, `acceptance_plan:368`). Current state: **0/6 CLOSED** — condition 2 PARTIAL (port-internal admissible sequence only), condition 6 PARTIAL (internal two-run repeatability only), conditions 1/3/4/5 BLOCKED (`PORT1TO1_parity_recheck.md:44/63`); no earlier "0/6 with no flags on disk" reading is used here, because the re-audit supersedes it on that one cell.
- `blocking_unverified` is non-empty — P0-1…P0-8 remain open with hard-fails/labels intact in current source (`parity_chain:93-108`, `acceptance_plan:273-291`, `owner_decisions:14/39/322/353`). Therefore **`RESULT IS NOT GOOD` unconditionally**, in both branches.
- **No donor GPU A/B frame exists on disk**, and no worker route can produce one (`X39:32-37/74-81`; `acceptance_plan:188-190`). The 12 H.264 stills are third-party frames of unknown build/camera/zoom/compression → direction of movement only (`roi_register:45-70`, `X39:96-100`).
- `parity.claim = NONE`, `parity.status = "UNVERIFIED"`, `visual_parity_claim = false`. No gate is green (`gate_audit:40-44`), no ROI metric promotes parity (`roi_register:27/211-214`), and a donor frame is **necessary but not sufficient** (`X39:34/178`).

---

## 1. Branch A — owner authorizes a Route A donor session

### 1.1 What the authorization changes, and what it does not

- It grants the **owner** permission and capability to personally run `C:\Games\Cossacks 3\cossacks.exe`, generate a map, capture a PNG and hand the artefacts plus a written manifest to COORD. Workers still run no donor, no Godot job, no gate, no capture (`CHARTER §4`, `X39:115`, `p0_packet_index:52`). This brief does not tell any worker to do any of it.
- It can supply the artifact for **chain condition 1** and enable COORD to advance conditions 2 and 3. It **does not, by itself, close any condition**: the donor PNG is necessary, not sufficient — parity needs a proven matched scene/seed/camera/ROI and a demonstrated byte-identical geometry + pixel-identical frame, ruled by COORD (`X39:34/169-171/178`, `V109:91`).
- It **does not change `parity.claim`/`parity.status`**. `compare_frames.py` keeps printing `parity=UNVERIFIED`; `--assert-ab-verified` only writes `claim=owner-supplied` (`roi_register:211-214`, `acceptance_plan:252`). COORD — not this brief and not any worker — may update the reviewer line to "Donor frame supplied by owner; parity still UNVERIFIED pending demonstrated match" (`X39:176`). Parity remains UNVERIFIED pending a demonstrated match.

### 1.2 Exact ordered steps (Route A, `X39 §3`, verbatim values)

These steps are written **for the owner and COORD**. No step is an instruction to this worker or the assistant.

1. **Pin the target configuration before launching the donor** and write a plain-text manifest (`X39:117-132`):
   - Size `mapsize = 0` → **320×320** grid. Do **not** use 240²: there is no donor 240² enum (`X39:123`; contradiction P2/U5 at `X39:203/222`). Port 64² is a port-only determinism fixture.
   - Map type donor `TerrainTypes` **0 Land** (`nowater2`), closest to port `gameplay.map_type = "land"`; record the enum actually selected if different (enum↔port mapping is `[I]`).
   - Season integer **0 Summer** (or 2 Winter / 3 Desert if deliberately testing); record entitlement state. Season 1 is absent `[U]`; Spring/Autumn alias Summer.
   - Seed keys `randkey0` (u32 high word) and `randkey1` (u32 low word), both supplied explicitly; `randkey0`'s derivation is `[U]`, `randkey1` is embedded in the save filename `game_v<ver>k<randkey1>.map`. If unreadable, mark `UNKNOWN` and the comparison degrades to A/B-L2-or-direction-only.
   - Camera profile `data\cameras\camera.cfg` (note if `camerascreenshot.cfg` / `cameradebug.cfg` was used). Record tilt **−32°**, focal **400** (Min=Max), dolly/SphereHeight/Length **20…58**, DepthOfView **1200**, and the actual in-game zoom/dolly at capture. Donor absolute FOV/sensor stays `[U]`; port `fov_deg = 17.27` is an assumption.
   - Window **1280×720, windowed** (no fullscreen scaling), no HUD over the intended ROI.
   - Donor build/version string (`gDataVersion`) and install path.
   - Port-side keys mirrored by COORD, never owner: `pitch_degrees=-32`, `fov_deg=17.27`, `start_zoom=0.3448276`, `min/max_height=20/58`, `pixels_per_meter=16`, `window=[1280,720]`, via explicit absolute config overlay, never ambient config.
2. **Launch and generate** (`X39:134-138`): start the donor normally from its own install (no copy/move); start a skirmish/new game at the Step-1 settings; the donor has no numeric seed UI, so read `randkey1` from the saved `.map` filename and copy both u32 integers from game state/log; save the generated `.map` **outside the repo** (e.g. `C:\Users\Maxym.Oboyshev\Documents\cossacks3_ab\donor_320_land_summer_k<randkey1>.map`) to preserve the exact scene for a possible Route-B same-geometry comparison.
3. **Capture the donor PNG outside the repo** (`X39:140-146`): position the camera to Step-1 values; let the frame settle (no selection panel, no HUD tooltip over the intended ROI); save a full-resolution PNG to an owner-controlled directory outside the repo (recommended `C:\Users\Maxym.Oboyshev\Documents\cossacks3_ab\donor_320_land_summer_k<randkey1>.png` — **do not** reuse the X07 still folder as evidence); record verbatim capture timestamp, window size, camera profile, tilt/focal/dolly actually used, saved `.map` filename and PNG SHA-256.
4. **Provide manifest + both out-of-repo artefacts to COORD** (`X39:148-150`): COORD (a) pins the port key manifest and explicit overlay, (b) produces the port PNG via the **single legal Godot path** `python variant3d\tools\godot_runner.py run --id x39-ab-<unique> ...` with a unique id into a temp directory outside the repo (e.g. `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\x39_ab\port_320_land_summer.png`), and (c) verifies admissibility **before any read**. **This worker submits no Godot job.**
5. **Verify admissibility G0-a…e** (`X39:150`, `acceptance_plan:177-185`, `roi_register §2`): `status=ok`, every view `complete=true`, `runner_status=ok`, `runner_exit=0`; `headless=false`, `capture_semantics="windowed seq = real viewport frames (frame_post_draw)"`; `resolution_observed == 1280×720` and `resolution_matches_request==true` (any 800×600 or CPU-fallback frame is a failed capture); config SHA-256 recorded and equal to the temp copy actually used (baseline P-2 `aa857480…202da`); seed and backend as requested; per-frame `sha256_file` + `sha256_pixels` present; `script_error_lines = 0`; `parity=UNVERIFIED`.
6. **ROI and comparison** (`X39:152-158`): pick a ground-only fractional ROI `(x0,y0,x1,y1)` and apply the **same** box to both frames (safe starting point A11 ref `.35,.55,.48,.70`, re-verified on ground in both frames). If it lands on a different feature → **UNVERIFIED, not retried until green**. Confirm `compare_shots.py --crop-frac` uses the same ordering on both sides; use `terrain_ab_metric.py ... --crop-frac <roi>` for distribution/direction hints; use `compare_shots.py --threshold 0.9999` only under the proven-match conditions of `X39 §4`. Keep `metric_field` and `visual_field` separate in the report; write `parity.claim = NONE` and `parity.status = UNVERIFIED` until COORD explicitly rules a demonstrated match.
7. **Owner's one-line manifest fields** (`X39:159`): size enum; map type enum; season int; `randkey0`/`randkey1` (or `UNKNOWN`); camera profile + tilt/focal/dolly + actual zoom; donor build version; saved `.map` path (out of repo); donor PNG path (out of repo) + SHA-256; ROI `(x0,y0,x1,y1)` confirmed ground-only on both sides; written attestation "donor launched by owner; assistant never executed donor".
8. **Label the pair** (`X39:163-178`): **A/B-L1** (matched inputs: same keys, size, type, season, camera, ROI) or **A/B-L2** (scene-matched rendering after the D04 §7 importer upgrade). L1 can prove divergence if frames differ; it does **not** certify parity even if they look similar. L2 tests rendering, not generation. Admissibility is mandatory: G0-a…e, identical ground-only ROI verified on both sides, separate metric/visual fields, verbatim reviewer line.

### 1.3 Which P0 packets can be settled in one session

**Direct answer: a Route A donor session, as defined in `X39 §3`, settles ZERO P0 packets.** It is a terrain capture + manifest, not any packet's terminating experiment. Each P0 retires only on its own zero-mismatch capture (`p0_packet_index:26`, `owner_decisions:37`). The six indexed packets (`p0_packet_index §1`) and P0-7 (no packet; `owner_decisions §6`, `acceptance_plan:286`) require the following, none of which is produced by the Route A frame:

| Packet / blocker | What one session would actually have to deliver | Can the Route A terrain frame settle it? |
|---|---|---|
| **Water P0-1 / 1b / 2** (`water_owner_protocol`) | The **only** packet explicitly scoped as "one owner-authorised donor GPU/debugger session" — but it needs a **water-visible map**, unmodified `water.lib`, pinned `t_87f0f3c130b0`, Phases 0–6 GL/FBO/copy/upload/breakpoint tracing, U1 PATH verdict, U4* tuple, U12 class a/b/c, U3 numbers/texture, U5 writer, U6 UV/winding, **≥2 water-visible frames + level→pitched camera move**, 0 differing bits/elements, and the captured values bound and asserted in `t_water.gd`. | **No.** Route A is a 320² Land frame with water hard-fail intact (`water3d.gd:520-527`); it supplies none of the dumps and no water pixels. Settle-able only in a **different, dedicated** water session, never by the Route A capture. |
| **FOW P0-3** (`fow_owner_protocol`) | One fixed-seed donor session at seed `20261113` with script `GetFOWLOSData` dumps (1.0 and 0.25 transects), knob-default log, 240² panel captures at P6, repeat seeds where required, 0 mismatching cells. | **No.** A terrain PNG has no LOS dumps; the packet's criterion is cell-based, not pixel-based. |
| **Tick P0-4** (`tick_owner_protocol`) | Owner/COORD **headless fixed-dt harness** — no donor binary — 6 sequences × 12 players × 3600 frames × 3 literal seeds × load profiles, canonical per-frame hashes, byte-identical with a single surviving order. | **No.** Explicitly independent of donor execution; cannot be settled by a donor session at all. |
| **Blend P0-5** (`blend_owner_protocol`) | Fixed-seed donor sessions at 30 Hz with pinned camera; per-tick frame index + pose/joint hashes across `(6,8)` vs forced `(0,0)` seams and W/S/A/R batteries; **3/3 trials** per setting/sid, byte-identical frame-for-frame. | **No.** One static frame is not a per-tick trace and cannot meet 3/3. |
| **Save P0-6** (`save_owner_protocol`) | Paired known-state donor `.map` saves differing in exactly one field at a time + identical-state re-save control, byte-diff/hexdump with offsets, 3 identical-seed repeats. | **No.** Route A produces one `.map` for scene preservation, not paired single-field divergences. |
| **Selection P0-8** (`selection_owner_protocol`) | One **fixed-rig** (58 m / −32° / focal 400) donor GPU session with ≥5 surveyed markers, projection/frustum/ray-order/AABB/marquee/minimap dumps at 4 camera poses and both DPI arms, ≥5 points reprojecting to 0 px. | **No.** Route A's camera/zoom is recorded as used, not the fixed survey rig; no surveyed markers, no dumps. |
| **P0-7 RNG G1** (no indexed packet) | Fixed-fixture RNG harness vs X21/L20/C300/U50 oracle; 0 mismatches across the full series (`owner_decisions §6`, `acceptance_plan:286`). | **No.** No donor-packet route; harness-only. |

**Bound on the branch:** one owner-authorised session can execute **at most one packet protocol at a time**, and only if that session supplies *that packet's* exact scene/camera/dumps/repeats. No single session settles all six packets, and no packet "close" value, still, metric, replay pair or port fallback settles a P0 (`p0_packet_index:55`). After Route A, the honest chain state is: condition 1 can be supplied; conditions 2/3 can be advanced by COORD's port capture and the matched manifest; **conditions 4, 5 and 6 remain BLOCKED/PARTIAL** until fresh gates, completed spec/toolchain and an explicit COORD ruling. **Parity stays UNVERIFIED.**

---

## 2. Branch B — owner declines (or cannot run the donor)

This is the honest final state if the owner will not/cannot run the donor and supply the manifest. `X39:37/236`: if no route is viable, parity is reported as **permanently UNVERIFIED (declared, accepted)** — not as a gate failure, never as a donor match.

### 2.1 What is delivered

- **Spec layer**: §§01–14 under `docs/terrain_swarm_2026-11-26/spec/`; `terrain_qa_spec.json` (N17) is **SCHEMA_ONLY / unpopulated** — advisory evidence, never a passing gate (`gate_audit:68`, `full_project_audit:101`).
- **Decoder/compiler + implementation layer**: the six Python tools, terrain GDScript modules, V37 shader and `t_terrain_donor`; 13/13 implementation files present; opt-in deterministic capture mode (`--deterministic-capture --capture-ticks N`) live in `main.gd`/`capture_sequence.py`; the single-applied I11 seam and both SHA-exact `.bak-COORD-I11` backups (`V109:50-52`, `parity_recheck §2`). **Presence is not a gate pass and not correctness.**
- **Derived assets**: `variant3d/assets/terrain_new/**` present by point-in-time glob (counts are presence-only and unverified), with **no X15 root `manifest.json`**, no `schemas/` tier, no I05 atlas tier and no bound I05/I03 feed (`V109:51`, `full_project_audit:49/61-63/117`).
- **Port-internal verification records**: landed windowed captures (`fullport6_seq2_20261113`; `detcheck_20261113`, `detcheck2_20261113`), two-run byte-identical per-frame `sha256_pixels` (internal repeatability only, 2 frames / 64 ticks — not 24/768), 14 executed ROIs, result JSONs and manifests that themselves record `parity=UNVERIFIED` (`parity_recheck §3`, `roi_register §3/§5`).
- **Decision/audit records**: `PORT1TO1_owner_decisions.md`, `PORT1TO1_p0_packet_index.md`, `PORT1TO1_parity_chain.md` + `PORT1TO1_parity_recheck.md`, `PORT1TO1_gate_audit.md`, `PORT1TO1_roi_register.md`, `X39_ab_feasibility.md`, `V109_owner_answer_final.md`, the P0 owner protocols, and this decision-simulation brief.
- **Preserve-only witnesses**: P-2 config hash `aa857480…202da` and the two I11 backup hashes byte-identical at last read; P-1/P-3 have no recorded baseline; P-9 tool hashes and donor pin `87f0f3c130b0…` recorded but not re-verified by workers (`owner_decisions:330-340`, `parity_chain:110-116`).

### 2.2 What stays UNVERIFIED

- **Donor parity**: `parity.claim = NONE`, `parity.status = "UNVERIFIED"`, `visual_parity_claim = false`; no tier above 2; ceiling remains **"gates green / internal consistency PASS / donor parity UNVERIFIED"** even under the most favourable gate outcome (`owner_decisions:39-40`, `V109:91`, `acceptance_plan:368`).
- **Six-condition chain: 0/6 CLOSED.** Condition 2 PARTIAL (port-internal only), condition 6 PARTIAL (internal repeatability only — no donor A/B, no shared camera, no geometry-byte equality, no COORD ruling, 2 frames/64 ticks not 24/768), conditions 1/3/4/5 BLOCKED (`parity_recheck §1/§3.2`).
- **All P0-1…P0-8** open with hard-fails/labels intact; plus non-P0 parity-invalidating `[U]` (T-SEED/T-CALLBACK, E-COLL, E-DMG/FF incl. `PredictShot` mismatch, E-WPN/SHIELD, E-VIS/SEL, S-SKIRM, S-AI-A1–A8, S-MKT/Q2/VIC/PEACE) and `U-INJ-1…11` (`parity_chain:93-108`, `acceptance_plan:289`).
- **Camera/projection**: V1-SENSOR/V2-PROJ/V2-DRAG/V2-BOX/V2-MINI still `[U]`; `FOV_DEG_ASSUMED = 17.27` stays PORT APPROXIMATION; `--camera NOT_SHARED_donor-oblique_vs_port-17p27` marker unchanged (`parity_chain:69-74`, `roi_register:86`).
- **Gates**: no gate green; 575/582/585 unacked with no on-disk ack evidence; no D1 dump ruling (five streams × 64²/240²/320²) and no D3 run-integrity ruling; `app/**` byte-identity not ruled; `assert_clean` CLEAN not claimed; fresh mtimes are not accepted runs without an mtime-after-START envelope (`gate_audit:40-44/57-70/170-179`, `owner_decisions:322`).
- **Spec/toolchain**: §§01–14 not all READY, N17 unsigned, X15 root manifest absent, I05 atlas/I03 feed unbound, `blocking_unverified = []` not ruled by COORD (`parity_recheck:60`).
- **Donor references**: no donor GPU A/B frame; the 12 H.264 stills remain direction-of-appearance only; no reliable still for mountains, sea, iron/coal mines, rivers or swamps (`X39:96-100`, `HANDOFF:137`).

### 2.3 Verdict

**`RESULT IS NOT GOOD` unconditionally** — `blocking_unverified` is non-empty (`V109:74`, `owner_decisions:14/39/353`, `acceptance_plan:33/269`, `roi_register:220`). This is the honest floor, not a gate failure and not a donor-match claim.

### 2.4 Stable handoff wording (carry verbatim, unchanged)

Carried forward exactly as at `PORT1TO1_owner_brief.md:80-92` / `acceptance_plan:357-370`; the first two lines are the mandatory reviewer line:

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

`RESULT IS GOOD` is admissible **only** when `blocking_unverified = []` and all tier-2 conditions hold — not under Branch B, and not under Branch A until COORD explicitly rules a demonstrated match. Forbidden phrasing in any handoff: "matches donor", "close to donor", "donor parity", "similarity %", "donor threshold PASS", "gate PASS" derived from a capture, or treating `--assert-ab-verified` as verification (`acceptance_plan:370`, `owner_brief:94`).

---

## 3. Minimum evidence to upgrade any single parity-chain condition — and why no worker can supply it

Upgrading **one** condition never promotes parity: all six must hold simultaneously, and a donor frame is necessary but not sufficient (`V109:91`, `X39:34/178`). Every closing artifact below is owner/COORD-owned or requires a forbidden RUNTIME action; none is available to a read-only worker.

| # | Current status | Exact minimum artifact that would close this condition | Why no worker can supply it |
|---|---|---|---|
| 1 | BLOCKED | Owner-run donor PNG **outside the repo** + written key/camera/size/season/ROI manifest per `X39 §3`; donor binary never executed or copied by a worker. | `CHARTER §4` forbids executing/copying the donor; `X39:32-37` says only the owner-launched Route A is viable, and it is not executed by workers; no donor frame exists. Necessary, not sufficient (`X39:34/178`). |
| 2 | PARTIAL (port-internal) | Fresh windowed capture: `status=ok`, `complete=true`, `resolution_observed=1280×720`, `resolution_matches_request=true`, `script_error_lines=0`, pinned seed/camera/size, identical fractional ROI, **paired with a real donor frame at the same ROI** (`acceptance_plan:177-186`). | Requires a Godot runner job (analysis workers submit no jobs, `CHARTER §4`) **and** the owner's donor frame (condition 1). Existing captures are port-vs-port with `parity=UNVERIFIED` and `--camera NOT_SHARED…`; `cap_fullport6/7/8.png` are absent. |
| 3 | BLOCKED | Owner manifest with both sides' `randkey0/1`, size enum, map type, season, camera constants and fractional ROI recorded per `X39 §3`; **plus** the D04 §7 importer upgrade for A/B-L2. | Donor has no numeric seed UI; `randkey0` derivation and saved-map byte mapping are `[U]` (`X39:137`, E9); port FOV is an assumption; no shared camera is asserted. The importer upgrade is COORD-owned, and no worker may run the donor to observe inputs. |
| 4 | BLOCKED | Fresh, non-advisory, COORD-ruled gate battery: result JSONs with mtime after job START; D1 dumps (5 streams × 64²/240²/320², zero byte difference); D3 run integrity `status∉{timed-out,error,skipped}`, `script_error_lines=0`, CLEAN; selftest 29/29, uitest 17/17, `t_render_mode` PASS, `t_map_variety` 5/5; `assert_clean` CLEAN with **575/582/585 acknowledged with evidence-backed reasons** (never deleted, never `--ignore-history`); `app/**` byte-identical (`owner_decisions:319-320`). | Ack is owner-only (`gate_audit:81/174-176`); no result JSON resolves for 575/582/585; workers may not run Godot, gates, `ack`, `reset`, `doctor`, `cancel`, `unwedge`, lower a threshold or fabricate a green JSON (`gate_audit:179`). No D1/D3 ruling exists. |
| 5 | BLOCKED | §§01–14 marked READY (V17), X15 root `manifest.json` emitted, I05 atlas built and bound, I03 feed consumed with `props_total>0 && fallback_used=false`, N17 populated and signed, and `blocking_unverified = []` ruled by COORD (`owner_decisions:319-320`). | Workers cannot mark sections READY or sign N17; N17 is SCHEMA_ONLY, atlas tier ABSENT, Objects feed unwired, root manifest absent (`full_project_audit:13-16/49/61-63/101/117`); closing P0 RUNTIME items is owner-only. |
| 6 | PARTIAL (repeatability only) | COORD-signed owner report with demonstrated **geometry-byte equality + pixel-identical matched frame** (zero mismatch) under the proven-matched manifest, explicitly ruling condition 6. The §8 design target is 24 frames / 768 ticks at `--step 1`. | No COORD ruling exists; the two deterministic runs are 2 frames / 64 ticks, pixels only (no geometry-byte equality), `parity=UNVERIFIED`, no donor A/B, no shared camera (`parity_recheck §3.2`); `fixed_step_plan:665-671` says even a passing replay pair stays UNVERIFIED. Worker cannot sign a ruling or produce the donor comparison. |

**Consequence:** there is no single artifact a read-only worker can add to move any cell from BLOCKED/PARTIAL to CLOSED. The only legal producer of the missing evidence is the owner (donor execution, ack, manifest) and COORD (gate ruling, importer upgrade, spec signing, final parity ruling). This brief supplies neither.

---

## 4. Risk of misreading internal PASS / gates / ROI metrics as parity

The controlling rule: **no unit-test gate and no ROI metric promotes parity** (`gate_audit:198-204`, `roi_register:27`, `parity_recheck:117-118`). Every cue below is port-internal or advisory; treating any of them as parity is the named misread risk.

| Cue | What it actually is | Required guard |
|---|---|---|
| `t_terrain_donor.json` `status=PASS`, `total=26`, `determinism.*.pairwise_equal=true` | **Highest-risk cue.** Advisory selftest; its own `parity` object is `claim=NONE`, `status=UNVERIFIED`, `visual_parity_claim=false`; all advisories `UNVERIFIED`; S2 water = 0, S3 shore = 0, S5 stamps = 0; determinism is port-vs-port 64²/240² — not 320², not a frame replay, not donor (`gate_audit:98`, `parity_chain:88`). | Quote the `parity` object alongside any `PASS`. Never call it a gate pass or parity proof. |
| `selftest.json` 29/29, `uitest.json` 17/17, `t_render_mode` PASS, `t_map_variety` 5/5, `summary.json` 19/19 | Port-internal smoke/regression; `parity.claim = ABSENT`; `t_map_variety` same-seed byte-identical is self-determinism (`gate_audit:91-96/109`). | "YES if read alone" — always label as internal consistency only. |
| D1 hash equality, `assert_clean` CLEAN, GR-A red gates | Port-internal integrity preconditions; "blocking" means *must fail if violated*, never *passes*, never *confers parity* (`gate_audit:52/107/109`). | D1/D3 must be ruled, not inferred; CLEAN not claimed; 575/582/585 unacked. |
| 14 `compare_frames.py` ROIs (MAE, RMSE, max error, differing-pixel fraction, Pearson, histogram correlation/intersection/chi-square, absolute-diff PNG) | Measurements of two images; the tool **always prints `parity=UNVERIFIED`** on success and refusal; no threshold is defined; cannot verify donor identity, camera equality or ROI correctness (`roi_register:27/196-222`, `gate_audit:163`). | Support cues only. No "matches donor", "similarity %", "donor threshold PASS", no moving/rescaling the ROI to hide an artifact. |
| `--assert-ab-verified` | Writes `claim=owner-supplied`; tool still prints `parity=UNVERIFIED` (`acceptance_plan:252`, `roi_register:213`). | Explicitly forbidden as verification. |
| `compare_shots.py --threshold 0.9999` / 0.80 default; `terrain_ab_metric.py` | Same-candidate self-determinism; 0.80 is a smoke placeholder; `terrain_ab_metric.py` is SMOKE-only, no ARI, labelled "NOT a fidelity gate or donor proof" (`gate_audit:152/165-166`). | Legal only for self-vs-self at proven-matched camera; SMOKE label kept. |
| Contact sheets, MP4, "looks right" visual cards | Presentation/human-review cues; a clean MP4 built from bad frames is still a failed capture; no metric may override the visual read (`acceptance_plan:194-230`, `HANDOFF:128`). | Keep metric and visual fields separate; no parity wording. |
| Two deterministic runs with byte-identical `sha256_pixels` | Internal repeatability of the port under a fixed seed/config only; 2 frames / 64 ticks, pixels only, `parity=UNVERIFIED`, no donor A/B, no COORD ruling (`parity_recheck:99/101-107`). | Call it "opt-in mode validated", not "donor match" or "any `[U]` closed" (`HANDOFF:444`). |
| Static PASS (13/13 parse, V61/V65 six pairs, V95 5/5), fresh file mtimes | Line-level/filesystem verdicts with Godot parse/smoke not run; freshness is necessary, not sufficient, without an mtime-after-START envelope (`V109:54`, `gate_audit:42`). | Never promoted to a gate pass or parity. |
| Ack of 575/582/585 | Retires a diagnostic; **not** a PASS, parse proof or selftest/uitest result (`gate_audit:81/185`). | Ack only with owner approval and evidence-backed reason; no deletion, no `--ignore-history`. |

**Explicit statements.** (1) No unit-test gate promotes parity. (2) No ROI metric promotes parity. (3) Parity stays `UNVERIFIED` with `parity.claim = NONE` and `visual_parity_claim = false`; no tier above 2 exists. (4) `RESULT IS NOT GOOD` while `blocking_unverified` is non-empty in **both** branches. (5) Neither branch adopts an approximation, makes a parity claim, weakens a test, or violates the read-only rule; exactly one repository file was written — this brief.

---

## 5. Claim register

| # | Claim | Label |
|---|---|---|
| 1 | Both branches simulated without recommendation; no execution instruction to any worker; read-only rule binding and unrelaxed | [D] `CHARTER §4`, `X39:115`, scope |
| 2 | Route A exact ordered steps are `X39 §3` Steps 1–5 + G0-a…e + A/B-L1/L2 labelling; donor frame necessary but not sufficient | [D] `X39:113-178`, `acceptance_plan:177-185` |
| 3 | A Route A terrain capture settles ZERO P0 packets; only water is scoped as one GPU/debugger session and needs a different, water-visible setup; tick needs no donor; P0-7 has no packet | [D] `p0_packet_index §1`, `owner_decisions §1-§6`, `acceptance_plan:277-287` |
| 4 | Branch B delivered layer is presence-only; N17 SCHEMA_ONLY, no X15 root manifest, no I05/I03 binding; no gate green | [O]/[D] `V109:50-54`, `full_project_audit`, `gate_audit:40-44` |
| 5 | Branch B stable handoff wording quoted verbatim; `RESULT IS NOT GOOD` unconditional; forbidden phrasing listed | [D] `owner_brief:80-94`, `acceptance_plan:355-370`, `V109:74` |
| 6 | Each chain condition's closing artifact is owner/COORD-owned or forbidden RUNTIME; no read-only worker can supply any of them | [D] `parity_recheck §1`, `X39:32-37/137`, `gate_audit:179/185` |
| 7 | Internal PASS/gates/ROI metrics are support cues only; highest misread risk is `t_terrain_donor.json` PASS/26; no metric promotes parity | [O]/[D] `gate_audit:98/198-204`, `roi_register:27/211-214` |
| 8 | Parity UNVERIFIED; `parity.claim = NONE`; six-condition chain 0/6 CLOSED; no approximation and no parity claim | [D] `V109:91`, `parity_recheck:44/63`, `owner_decisions:39` |
| 9 | Exactly one repository file written (this report); no code, Godot, git, donor execution, capture, gate or ROI metric produced | [O] scope |

---

*End of PORT1TO1_decision_sim. Read-only decision simulation; exactly one repository file written. Branch A = owner-only Route A steps; settles zero P0 packets. Branch B = delivered presence-only, all gaps UNVERIFIED, `RESULT IS NOT GOOD`, stable handoff wording verbatim. Six-condition chain 0/6 CLOSED; no unit-test gate or ROI metric promotes parity; parity UNVERIFIED; no approximation, no parity claim, no violation of the read-only rule.*
