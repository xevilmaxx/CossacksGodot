---
id: PORT1TO1-INTERNAL-VALIDATION-2026-11-26
title: "Exact port-internal validation summary — full 1:1 Cossacks 3 donor port"
worker: INTERNAL-VALIDATION (read-only subagent)
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_internal_validation.md
files_created: [docs/terrain_swarm_2026-11-26/reports/PORT1TO1_internal_validation.md]
files_edited: []
scope_guard: "Repo file/line reads only (read tool) plus one read-only Test-Path existence check of this report's own target path. No source, shader, config, asset, test, fixture, result JSON, queue, backup, git state, Godot process, runner job, gate, capture, MP4, ROI metric, MCP host or donor binary was created, modified or executed. Every command/procedure quoted below is transcribed from the cited landed reports; this worker executed none of them."
labels: [OBSERVED, DERIVED, UNVERIFIED, "PORT APPROXIMATION", PRESERVE-ONLY, NO_PARITY_CLAIM]
parity_status: UNVERIFIED
parity_claim: NONE
verdict: "RESULT IS NOT GOOD — blocking_unverified is non-empty; six-condition chain 0/6 CLOSED"
reviewer_line: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
---

# PORT1TO1 — exact port-internal validation summary (2026-11-26)

> **Mandatory reviewer line (verbatim):** PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

> **Read this before any row below.** This is a read-only compilation of *port-internal* validation evidence already landed in this workspace. Each procedure/command is quoted from the cited report; none was run by this worker. Every result is one of **PASS (port-internal)**, **REFUSAL/FAILED**, or **UNVERIFIED**. **No row asserts donor parity, a camera match, a gate PASS, or closure of any P0 item.** File presence is evidence of existence only.

---

## 0. The explicit distinction — internal consistency PASS vs donor fidelity UNVERIFIED

| Axis | Honest state |
|---|---|
| **Port-internal consistency** | **PASS across the artifacts in §2**: MCP protocol + 6 tools exercised live; edited GDScript statically parse-checked; full-port snapshots render clean apart from the deliberate water hard-fail; a mechanically admissible 3-frame sequence manifest; 14/14 ROI metrics executed with zero refusals; two deterministic runs produced byte-identical `sha256_pixels`; preserve-only witnesses byte-identical; final guard four-area PASS with COORD label fixes. |
| **Donor fidelity** | **UNVERIFIED, with no claim.** No same-size/seed/type/season/camera/ROI donor GPU A/B frame exists (`PORT1TO1_parity_chain.md:51`; `X39_ab_feasibility.md:32-37/74-81/104-110`). Only a worker-forbidden owner Route A could produce one; none was executed. |
| **Camera match** | **NOT asserted.** `PORT1TO1_roi_register.md:86` forces `--camera NOT_SHARED_donor-oblique_vs_port-17p27`; V1-SENSOR/V2-PROJ/V2-DRAG/V2-BOX/V2-MINI remain `[U]`; FOV `17.27°` is a labelled port derivation (`parity_chain:69-74`). |
| **P0 closure** | **None.** P0-1 Water U12, P0-1b U4*, P0-2 U1/U3/U5/U6, P0-3 FOW grid/occlusion/persistence/tint, P0-4 tick interleave, P0-5 animation blend, P0-6 save container, P0-7 RNG G1, P0-8 selection/projection are all open (`acceptance_plan.md:273-291`; `parity_chain.md:93-108`). |
| **Six-condition chain** | **0/6 CLOSED.** Condition 2 = PARTIAL (port-internal only); condition 6 = PARTIAL (repeatability only, corrected from BLOCKED); conditions 1, 3, 4, 5 = BLOCKED (`PORT1TO1_parity_recheck.md:40-63`). A PARTIAL is not a CLOSE. |
| **Verdict** | **`RESULT IS NOT GOOD` while `blocking_unverified` is non-empty** (`V109_owner_answer_final.md:74/91`; `owner_decisions.md:14/39/353`; `acceptance_plan.md:33/269`). |

**Internal consistency PASS does not imply donor fidelity.** A capture is evidence of a render; a byte-identical hash pair is evidence of repeatability; a guard PASS is evidence of label/test hygiene. None of these is a donor comparison, and none can lift parity above tier 2 (`owner_decisions.md:39-40`, `V109:91`, `acceptance_plan.md:368`).

---

## 1. Method

1. Read-only enumeration of `docs/terrain_swarm_2026-11-26/` frontmatter, `HANDOFF.md` §9.17–§9.21, `PORT1TO1_PLAN.md` task table, and the `reports/PORT1TO1_*.md` verification set (`owner_brief`, `parity_chain`, `parity_recheck`, `roi_metrics`, `roi_register`, `artifact_layout`, `acceptance_plan`, `acceptance_runbook`, `final_guard_audit`, `determinism_audit`, `evidence_index`, `ack_evidence`, `gate_audit`, `owner_decisions`).
2. For each artifact in §2, transcribed the exact command/procedure, result, evidence path/hash, and explicit non-proof from those reports. Hashes are copied verbatim with their source; none was recomputed by this worker.
3. No tool that runs code, Godot, git, the donor, a capture, a gate, an MP4 build, an ROI metric, or an MCP probe was used.

---

## 2. Artifact-by-artifact validation summary

### 2.1 MCP host — all 6 tools verified live

- **Procedure (exact, from `PORT1TO1_acceptance_runbook.md:222-265`):** launch through the single Godot door —
  ```powershell
  $ABS = (Resolve-Path variant3d\config_donor_capture.json).Path
  $BOOT = Join-Path $env:TEMP 'opencode\v42\boot_viewport.png'
  python variant3d\tools\godot_runner.py run --id mcp-host --timeout 3600 -- `
    --path variant3d --script res://tests/t_mcp_host.gd -- `
    --config "$ABS" --seed 20261113 --mcp-port 8931 `
    --screenshot "$BOOT"
  ```
  Wait for `GAMECRAFT-MCP READY port=8931 map=<w>x<h>`; then probe with `python "$env:TEMP\opencode\v42\verify_mcp.py"` and `python "$env:TEMP\opencode\v42\verify_mcp_tools.py"`. Acceptance: HTTP 200 `initialize`, integer JSON-RPC id echoed, requested protocol `2025-03-26`, `serverInfo=cossacksgodotmcp/1.0.0`, `tools/list` returns exactly 6 tools, `game.tick({})` is a clean `isError` refusal (missing `seconds`).
- **Result:** **PASS (port-internal, live protocol + tools).** All six tools exercised on a QA 64×64 donor-backend map: `game.status` (map 64×64, 19 entities, seed 20261113); `game.tick` (0.5 s advance); `camera.pan_to`; `game.screenshot` (1280×720 PNG, valid signature, 933 KB); `game.place_building` (invalid `cen` refused with exact reason; `mil` succeeded `site_id=246`); `video.record_frames` (4 PNG frames). Boot fixes recorded: early-listen, explicit `--screenshot`, `Data.set_render_mode()` static setter, `data.gd:1106` scope bug, FX ghost declarations + `Mesh.ARRAY_TEX_UV`/`deg_to_rad`. **No refusal was the final result of any of the six probes** (the `game.tick({})` refusal is the expected negative control).
- **Evidence path:** `HANDOFF.md:394,407-408,421` (§9.17/§9.18/§9.19); `PORT1TO1_PLAN.md:25` (task 14 DONE); `PORT1TO1_owner_brief.md:57`; `PORT1TO1_acceptance_runbook.md:222-265`; `variant3d/tests/t_mcp_host.gd:23-31`; backup `inbox/backup/t_mcp_host.gd.bak-MCPPROTO`; probe outputs `%TEMP%\opencode\v42\mcp_gamecraft\shot_0001.png`, `vid_0002.png … vid_0005.png` (933,438 B each); probe config `%TEMP%\opencode\v42\mcp_qa_small.json` (QA-ONLY).
- **Does NOT prove:** donor fidelity, camera match, a gate PASS, or any P0 closure. `verify_mcp.py:76` states "protocol level only; no parity claim"; the QA map config is a temporary file, **not** a parity artifact (`HANDOFF:408`); MCP `game.tick` is an optional fixed-tick driver, not donor A/B and not the deterministic-capture design (`acceptance_runbook:261`).

### 2.2 Parse checks across edited GDScript

- **Procedure (exact, from `PORT1TO1_acceptance_runbook.md` §1 / `V42_gate_commands.md:143-164`):** per-file headless parse jobs through the single door, e.g.
  ```powershell
  python variant3d\tools\godot_runner.py run --id v42-parse-data --timeout 180 -- --headless --path variant3d --check-only --script res://scripts/terrain_donor_data.gd
  ```
  and likewise `v42-parse-gen`, `v42-parse-mesh`, `v42-parse-props`, `v42-parse-world`, `v42-parse-main`, `v42-parse-seam-world`, `v42-parse-tdonor`; plus `python -m py_compile` on the six acceptance tools. A `.gdshader` has **no** `--check-only --script`; it is smoke-tested via a headless `t_terrain_donor.gd` run (`V42:161-164`). `HANDOFF.md:406` records the batch outcome as "All 18 edited GDScript files pass `--check-only`; `game.gd:314` parse error from the skirmish worker fixed by COORD; acceptance tools (`variant3d/tools/acceptance/`) pass `py_compile`, a 4-frame contact sheet and a zero-MAE self-comparison that still prints `parity=UNVERIFIED`."
- **Result:** **PASS (static parse/compile/smoke only).** `PORT1TO1_PLAN.md` records `parses OK` / `gen+inputs parse checked` on the implementation rows; `V90_static_syntax_seal.md` records 13/13 implementation files STATIC PASS (6/6 Python parse, 6/6 GDScript structure, 1/1 shader syntax) with Godot parse/smoke explicitly **NOT** run by that worker. **Refusal/non-pass preserved:** ticket 575 (`bbclamptidy01-parse`, diagnostic `--headless --path variant3d -- --check-only res://scripts/game.gd`) `timed-out`, exit `-9`, 302.44 s / 300 s, `SCRIPT ERROR 0` — it is "NOT a passing gate and NOT a parse proof" and remains unacked (`PORT1TO1_ack_evidence.md:74/109`, `V104_ack_reasons.md:94`).
- **Evidence path:** `HANDOFF.md:406`; `PORT1TO1_PLAN.md:12,15,60,66-79,87-155,175`; `V42_gate_commands.md:143-164`; `V90_static_syntax_seal.md`; `PORT1TO1_ack_evidence.md:74,109,121`; `V104_ack_reasons.md:94,110,131`; `V108_final_go.md:86` (third argument removed from `raw.encode_float(0, v, true)` at `terrain_donor_gen.gd:377/:1844`).
- **Does NOT prove:** runtime behaviour, donor fidelity, camera match, a gate PASS, or P0 closure. Static parse is not the acceptance path; `ack` records retirement only; a fresh `PASS` selftest is advisory with `parity=NONE/UNVERIFIED` (`parity_chain.md:41/119-123`).

### 2.3 Full-port snapshots — `cap_fullport6/7/8.png` clean except the deliberate water hard-fail

- **Procedure (as recorded, not re-executed):** windowed 1280×720 donor-backend port captures at seed `20261113`, submitted through the single Godot door / acceptance harness; COORD rendered and inspected the result. `HANDOFF.md:409-410` (§9.18) and `:441` (§9.21); `PORT1TO1_PLAN.md:26` (task 15). No full command line / runner ticket is recorded for these three single snapshots; the only recorded tickets in this set are ticket 49 for the 3-frame sequence (§2.4) and tickets 118/119 for the two deterministic runs (§2.6). **No command line is invented here.**
- **Result:** **PASS (port-internal render observation), with one expected hard-fail.** `cap_fullport6.png` renders buildings/units cleanly; only error is the expected **U12 water hard-fail** (no reflection texture provenance, no grey fallback). `cap_fullport7.png` renders cleanly; the only error is the now-explicit **[U4*] water gate** (no scalar source captured → no water, no grey fallback). `cap_fullport8.png` renders clean apart from the deliberate **water U4* hard-fail**; deterministic mode landed with I11 seam and both config hashes unchanged. All outputs print `parity=UNVERIFIED`.
- **Disk-presence discrepancy — recorded, not reconciled:** read-only audits found `cap_fullport6/7.png` **absent on disk** (`PORT1TO1_artifact_layout.md:70`; `PORT1TO1_roi_register.md:73`) and `cap_fullport6/7/8.png` **absent on disk** at later passes (`PORT1TO1_parity_chain.md:52`; `PORT1TO1_parity_recheck.md:57`), while `HANDOFF.md:409-410/441` and `PORT1TO1_owner_brief.md:58` report them rendered/clean. Both statements are preserved verbatim as source-derived; this report neither resolves nor repairs the discrepancy. A `%TEMP%\opencode\v42\` root containing `cap_fullport*.png` is listed as prior point-in-time temp captures (`artifact_layout.md:107`).
- **Evidence path:** `HANDOFF.md:409-410,441`; `PORT1TO1_PLAN.md:15,26,160`; `PORT1TO1_owner_brief.md:58`; `PORT1TO1_acceptance_plan.md:41`; `PORT1TO1_artifact_layout.md:70,107`; `PORT1TO1_parity_chain.md:52`; `PORT1TO1_parity_recheck.md:57`.
- **Does NOT prove:** donor fidelity, camera match, a gate PASS, or P0 closure. Water is deliberately not drawn (U12/U4*), so no water parity is scored; unit-test gates are explicitly not the acceptance path (`HANDOFF:410`); snapshots are candidate-internal images only.

### 2.4 Three-frame sequence manifest — `inbox/qa/captures/fullport6_seq2_20261113/`

- **Procedure (exact, from `PORT1TO1_acceptance_plan.md:150,184` and `artifact_layout.md:74-95`):** `capture_sequence.py` in windowed `--seq` mode (`frame_post_draw`, no `--headless`), one view at a time through `godot_runner.py`; seed `20261113`, config `config_donor_capture.json`, config SHA `aa857480474399dc4674104744ea292bf84094d8321cdd4d0889c24cf9a202da`. Runner ticket **49** (`variant3d/.godot_queue/results/00000049_acapt-fullport6-donor/`). The earlier `fullport6_seq_20261113/` attempt **failed** with `error=KeyError('seq_seconds')` and is preserved as a failure witness; the harness `seq_seconds` bug was then fixed.
- **Result:** **PASS (mechanically admissible, port-internal only).** `manifest.json`: `status=ok`, `deterministic=true`, `headless=false`, `seed="20261113"`, `parity="UNVERIFIED"`, `runner_ticket=49`, `capture_semantics="windowed seq = real viewport frames (frame_post_draw)"`, `resolution_matches_request=true`; 3 frames `frame_0000..0002.png`, all 1280×720. `contact.png`/`contact.json`: 2572×1528 sheet, `rescaled=false`, `exact_pixels_preserved=true`. `seq_index.json`: `frames=3`, `mode="window"`, `seconds=2.0`, `sim_seconds=2.1875`, `step=1.0`. Runner stdout 129 B, stderr 0 B.
- **Evidence path / hashes:** `PORT1TO1_artifact_layout.md:78-95`; `PORT1TO1_acceptance_plan.md:42,184`; `PORT1TO1_roi_register.md:69`. Frame `sha256_file`: `frame_0000.png` = `6fc7dfab26ea04429db165c4327604908b892cfa4707605d5eda32e8a6f4ba80`; `frame_0001.png` = `bbdec7c59c7ff4799480361810a27169c41e935a550b4b08a119756429ffe2e4`; `frame_0002.png` = `aa657352e5f659984a337fa211272daf926ad68784dc0c29708eacb61cd47676`. `frame_0000.png` `sha256_pixels` = `36400d9cb2a25cb17be07db6cb1fc21837859ff172fe55043bd851812986632e` (`roi_register.md:74`).
- **Does NOT prove:** donor fidelity, camera match, a gate PASS, or P0 closure. `acceptance_plan.md:184` admits it "as port-internal evidence only — still no donor A/B"; no pinned donor-matched camera exists; it is not paired with a donor frame at the same ROI.

### 2.5 14/14 ROI comparisons — all `parity=UNVERIFIED`

- **Procedure (exact, from `PORT1TO1_roi_metrics.md:112-154`):** 14 invocations from the repo root with Python 3.14.3 of
  ```powershell
  python variant3d/tools/acceptance/compare_frames.py --donor "$env:TEMP\opencode\donor_videos\selected\cZW0AEupCaI\t_<s>.png" --port inbox/qa/captures/fullport6_seq2_20261113/01_donor/frame_0000.png --roi <x,y,w,h> --roi-source "<register §5 provenance>" --camera NOT_SHARED_donor-oblique_vs_port-17p27 --out-diff inbox/qa/captures/roi_metrics_20261113/diff_roi_R<nn>_....png --report inbox/qa/captures/roi_metrics_20261113/diff_roi_R<nn>_....json
  ```
  for ROI ids R01–R14. Only `--out-diff`/`--report` were redirected from the register §5 commands; every `--donor`, `--port`, `--roi`, `--roi-source`, `--camera` is the register value verbatim. `--assert-ab-verified` was **not** supplied; no config pair was supplied; `--hist-bins` default 16 and `--amplify` default 1.0 were not overridden. Port side F0 = `fullport6_seq2_20261113/01_donor/frame_0000.png`.
- **Result:** **14/14 EXECUTED, 0 refusals, all UNVERIFIED.** All runs exited 0, emitted no `REFUSED:` line, printed per-channel metrics and `parity=UNVERIFIED (metrics never constitute donor parity)`. 14 diff PNGs + 14 metrics JSONs written **only** to `inbox/qa/captures/roi_metrics_20261113/`. Each JSON records `parity="UNVERIFIED"`, `claim=null`, `owner_assertion=null`, `camera=NOT_SHARED_donor-oblique_vs_port-17p27`, `config_donor=null`, `config_port=null`, `hist_bins=16`, `amplify=1.0`, `frame_size=[1280,720]`.
- **Evidence path / hashes:** `PORT1TO1_roi_metrics.md:56-104` (per-ROI MAE/RMSE/max/differing-pixel/Pearson/histogram rows and all 14 diff-PNG SHA-256 values); `PORT1TO1_artifact_layout.md:97-99`; `PORT1TO1_roi_register.md:66-71,152-191`. Donor still SHA-256: `t_0=b037afde74b9e6dbb3b807b31468da81222a24af58da768c725c7ce0d40b5c45`; `t_120=59039e2dbf2cef6ba1c15d4065c8f8ed9604296b271ffa105b5f74d6d81e6677`; `t_300=cc3baa4b557a3e246e0cead52a57c79e2c39d2be569ae00bc4c520c0c309523f`; `t_600=326a33d3120ca9379aa1a552c65cf3816654da57f37823e03a3ad1e95963dbed`; `t_1200=a98ef75b02fe66ba920cf8bbd7eb2d66b3af25c757b3eb15a6105f0c575ae187`; `t_1800=7def3a3d88f64dd3d5825ffab6121748bddb2a637dbc0bc2207c14000a96b937`; `t_2100=5e14ed4f3471d06351d833979a3bd19e7e107d8e450d23fb00b9d7a7ddf69aeb`. Every port-side hash is F0's `6fc7dfab…ba80`.
- **Does NOT prove:** donor identity, camera equality, ROI correctness, or visual parity. The donors are third-party H.264 extracts of unknown build/map/camera/zoom/compression and the port frame is a port-internal viewport capture; the `--camera` marker explicitly records **no shared camera**. MAE/RMSE/max error/differing-pixel fraction/Pearson/histogram correlation/intersection/chi-square and the diff PNGs are support cues only — no threshold, similarity %, donor-threshold PASS, or gate PASS (`roi_metrics.md:25-27,172-185`).

### 2.6 Two deterministic runs — byte-identical `sha256_pixels`

- **Procedure (as landed and re-read):** opt-in `--deterministic-capture --capture-ticks N` in `main.gd` (`:38-39,231-239,1408-1413`; watchdog/deadline disabled, headless/CLI/`--seed random`/`<=0` ticks refused, `capture_ticks_per_frame=maxi(1,int(round(seq_step*Data.FPS)))`) and `capture_sequence.py` (`:152-154,293-296,310-317,359`); fixed `1/32` ticks, authoritative `capture_view3d`, 1280×720 asserts, no CPU fallback, audio seed in manifest. Two COORD runs: `detcheck_20261113` and `detcheck2_20261113`, seed `20261113`, `--seq-seconds 2`, `--seq-step 1`, 2 frames, **64 ticks**. Re-verified by read-only `Get-FileHash` in `PORT1TO1_parity_recheck.md:80-99`.
- **Result:** **PASS (port-internal repeatability only).** Both manifests: `deterministic=true`, `deterministic_capture=true`, `capture_ticks=64`, `seed=20261113`, `status=ok`, `parity=UNVERIFIED`; engine argv `--deterministic-capture --capture-ticks 64`; config SHA `aa857480…202da`. Frame PNGs, `seq_index.json` and per-frame `sha256_pixels` byte-identical across the two runs. `seq_index`: `ticks_done=64`, `ticks_per_frame=32`, `sim_seconds=2.0`, `winner=-1`. This corrected exactly one cell of the earlier chain audit — condition 6 **BLOCKED → PARTIAL**, not CLOSED; chain remains **0/6**.
- **Evidence path / hashes:** `inbox/qa/captures/detcheck_20261113/manifest.json` and `detcheck2_20261113/manifest.json`. Manifest SHA-256: detcheck = `4B3EDA01CA4DB8376FB87396B8F0C4ACFCC59C6C645A0421B39901976CA16681`; detcheck2 = `BC2880F3FA0805B77E5ACD6FAE8A8D981C1E4E5C0D18DE8F79E1E67823CAE0D0`. Frame `sha256_pixels`: `frame_0000.png` = `def18ad94e6abb22d698679be77cba96e3b21dda739eee8779315efffcc9842f`; `frame_0001.png` = `18e1e7217aac9c6680f91f1504922dcd92d00545bd67c427a993209a467f7265` (both identical across runs). Frame file SHA-256 `[O]`: `A776159F6233DE53EA51EEB1E8FA9FE91655091F60ED2821AA941E5996B7C876` and `167764BFFE19EC7A8421E3B4D36528E08A20AAF85245D28477B2A2EF4C64EA3B` (identical). `seq_index.json` SHA-256 `07E0B2AF960B23FB1A1AC7E1406C399203350E7FEE179D5AACBECDF2C83ED187`; runner `stderr.txt` SHA-256 `E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855` (empty). Source: `PORT1TO1_parity_recheck.md:84-99`; `HANDOFF.md:441,444`; `PORT1TO1_PLAN.md:160` (task 149 DONE); `PORT1TO1_owner_brief.md:60`.
- **Scope limits (why PARTIAL, not CLOSED):** 2 frames / 64 ticks, **not** the `fixed_step_plan §8` / `acceptance_runbook:141/154/299` target of 24 frames / 768 ticks; pixels only, no geometry-byte equality; no matched manifest (port config only, `parity=UNVERIFIED`); no COORD ruling. Engine stderr (`00000118_acapt-detcheck-donor`, `00000119_acapt-detcheck2-donor`) contains the deliberate water U4* hard-fail and benign Godot teardown lines, with no `watchdog:`, `cli: wall-clock limit reached` or `deterministic-capture:` refusal; the manifests do **not** record a `script_error_lines` field, so `script_error_lines=0` is **not** asserted from them (`parity_recheck:103-107`).
- **Does NOT prove:** donor parity, camera match, a gate PASS, P0 closure, or the full §8 two-run test. `HANDOFF.md:444` states it validates "the opt-in mode only; it does NOT close donor A/B, camera match, or any `[U]`."

### 2.7 Preserve-only config hashes — unchanged

- **Procedure (exact):** read-only `Get-FileHash -Algorithm SHA256` re-hash of existing files, compared against recorded witnesses (`PORT1TO1_parity_chain.md:110-116`; `PORT1TO1_final_guard_audit.md:125-146`; `PORT1TO1_parity_recheck.md:109-111`). No file was written, flipped, reverted, repaired or re-applied.
- **Result:** **PASS for the three recorded witnesses (byte-identical); PARTIAL for the two un-witnessed readings.** Re-hash held across the deterministic-mode landing and the captures.
- **Evidence path / hashes:**
  - `variant3d/config_donor_capture.json` = `aa857480474399dc4674104744ea292bf84094d8321cdd4d0889c24cf9a202da` — **byte-identical** to `owner_decisions.md:333`, `acceptance_plan.md:310`, `parity_chain.md:113`, `fullport6_seq2_20261113/manifest.json:65`.
  - `inbox/backup/main.gd.bak-COORD-I11` = `3859b6056bfdfdd5a659931835fd0901dd03db36b02a453389d9338bac9e71f8` — **byte-identical** to `owner_decisions.md:335` / `acceptance_plan.md:306`.
  - `inbox/backup/world3d.gd.bak-COORD-I11` = `44ee96c0dcfb35558f6ea3e0493e8f8faa1cadf6e155beb38031a9b11e1ab07a` — **byte-identical** to the same witnesses.
  - `variant3d/config.json` = `223767e57b506577ead54633708380a425a0b8aa439c8e3c28478c15c8ed44e2` — point-in-time reading matching the prior read, **no recorded baseline** (`owner_decisions.md:332`).
  - `variant3d/assets/models/manifest.json` = `36f6a378548f3116dc1585d7cdd34526a17b5c46d1ded02e3a93c7c736f22731` — point-in-time reading matching the prior read, **no recorded baseline** (`owner_decisions.md:334`).
  - P-9 tool-hash prefixes `ABBF0571 / DDFB8688 / 00C0591A / 667B71FB / 3A92D053 / 5A3B9E77` and donor pin `cossacks.exe` = `87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c` — recorded but **not re-verified** by the chain audit; COORD must re-run `py_compile` at A′-1 on the frozen tree (`owner_decisions.md:340`; `parity_chain.md:115`).
- **Does NOT prove:** donor fidelity, camera match, a gate PASS, or P0 closure. The I11 seam markers are present and single-applied (`main.gd:127/199-201/625-627/1144-1146`; `world3d.gd:111/121/147/148/223-227/627/648/709-710`), but presence is not a gate result; `config.json`/`manifest.json` cannot be certified against any baseline; 575/582/585 remain unacked and `ack` never becomes a PASS (`ack_evidence.md:38/137`).

### 2.8 Final guard audit — four-area PASS with COORD label fixes

- **Procedure (exact):** read-only literal/regex scans for parity-claim strings; label/experiment scan at emit sites; `Compare-Object` of `variant3d/tests/*.gd` against every existing `.bak-*` plus `check(`-count comparison; `Get-FileHash -Algorithm SHA256` on preserve-only files; direct reads of the I11 seam markers. No code, Godot, git or donor execution; no test run (`PORT1TO1_final_guard_audit.md:6,26`).
- **Result:** **PASS in all four areas, with 3 MINOR label gaps.** Area (1) parity strings PASS — no live `parity=true`, `"parity": true`, `visual_parity_claim=true`, unqualified `RESULT IS GOOD` or unqualified donor-parity assertion; every live occurrence is negated/guarded. Area (2) approximations PASS — prior G1–G3 verified fixed; remaining GF1–GF3 are label-only (inferred food→`workconstruct` stand-in; water plane-Y `-0.25` placeholder; legacy tile-index shader `PORT APPROX` labels), no invented donor constant. Area (3) weakened tests PASS — `check()` counts unchanged vs backups; all changed assertions are adjudicated (P0-GATE-01 / DARKROW_ALL_01 / D-22 P-45) and compensated by stricter applicable gates. Area (4) preserve-only PASS — §2.7 hashes. No rollback triggered.
- **COORD label fixes (recorded in the plan, not applied by this worker):** `PORT1TO1_PLAN.md:35` task 24 "Port guard / preserve-mod audit … DONE … PASS: no new approximation/parity claim, user mods + backups intact; 3 minor `[U]` label gaps fixed in shader/inputs"; `:174` task 163 "Final parity-string guard … DONE … `PORT1TO1_final_guard_audit.md` + COORD label fixes … PASS; GF1/GF2/GF3 label gaps fixed, GF4 conditional verdict corrected". Note the guard report's own register lists GF1–GF4 remediation as **"label-only, NOT applied"** by that guard (`final_guard_audit.md:150-159`); the applied COORD fixes are those recorded in the plan. GF4 is the conditional `RESULT IS GOOD` line at `X39_ab_feasibility.md:236`, replaced with the D14 text from `V67_owner_answer_check.md:128` ("Conditional only, not today's verdict … today `blocking_unverified` is non-empty, so `RESULT IS NOT GOOD`").
- **Evidence path:** `PORT1TO1_final_guard_audit.md:28-34,40-67,71-103,107-146,150-174`; `DEC_U_port_guard_audit.md`; `PORT1TO1_PLAN.md:35,174`; `PORT1TO1_owner_brief.md:40,62`.
- **Does NOT prove:** donor fidelity, camera match, a gate PASS, or P0 closure. Guard PASS is label/test hygiene only; GF1–GF4 assert no donor fidelity, change no simulation/rendering value, lower no test and remove no owner mod; the guard's own verdict remains `parity_UNVERIFIED`, `blocking_unverified` non-empty (`final_guard_audit.md:172-173`).

---

## 3. Verdict template (exact)

Adapted from `PORT1TO1_owner_brief.md:80-92`, `PORT1TO1_acceptance_runbook.md:332-343`, `PORT1TO1_roi_metrics.md:168-183` (additive variants, NOT verbatim — see `PORT1TO1_verdict_sync.md` §5):

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

`RESULT IS GOOD` is admissible **only** when `blocking_unverified = []` and all tier-2 conditions hold — not today. Forbidden phrasing: "matches donor", "close to donor", "donor parity", "similarity %", "donor threshold PASS", "gate PASS" derived from a capture, or treating `--assert-ab-verified` as verification (`owner_brief.md:94`; `acceptance_runbook.md:345`). **Given the current tree, `blocking_unverified` is non-empty, so `RESULT IS NOT GOOD` unconditionally** — internal-consistency PASS notwithstanding.

---

## 4. Honest ceiling

The best honest outcome supported by §2 is exactly: **gates green / internal consistency PASS / donor parity UNVERIFIED** — and even "gates green" is not claimed here: no fresh COORD-ruled gate battery exists, 575/582/585 are unacked, D1/D3 are unruled, `terrain_qa_spec.json` is SCHEMA_ONLY (`parity_chain.md:54-56`; `gate_audit.md:64/81/185`; `ack_evidence.md:38`). The eight artifacts in §2 validate the port's own protocol, syntax, renders, repeatability, preservation and labelling. **None of them closes condition 1/3/4/5, none supplies a donor GPU A/B frame, none asserts a camera match, none closes a P0 item, and none changes `parity.status` from `UNVERIFIED`.**

---

## 5. Claim register

| # | Claim | Label |
|---|---|---|
| 1 | MCP host exposes exactly 6 tools; protocol + all six calls verified live on a QA map | [O] `HANDOFF:407-408`, `acceptance_runbook:250-261`, `PLAN:25` |
| 2 | Edited GDScript statically parse-checked; ticket 575 timed-out parse is NOT a parse proof | [O]/[D] `HANDOFF:406`, `V42:143-164`, `ack_evidence:74` |
| 3 | `cap_fullport6/7/8` reported clean apart from deliberate water U12/U4* hard-fail; read-only audits found them absent on disk | [O] `HANDOFF:409-410/441`, `owner_brief:58` vs `parity_chain:52`, `parity_recheck:57` |
| 4 | `fullport6_seq2_20261113` mechanically admissible 3-frame manifest, port-internal only | [O] `artifact_layout:78-95`, `acceptance_plan:184` |
| 5 | 14/14 ROI comparisons executed, 0 refusals, all `parity=UNVERIFIED` | [O] `roi_metrics:56-104/160-162` |
| 6 | Two deterministic runs byte-identical `sha256_pixels`; condition 6 PARTIAL, chain 0/6 | [O]/[D] `parity_recheck:84-99`, `HANDOFF:444` |
| 7 | Three preserve-only witnesses byte-identical; two readings have no baseline | [O] `final_guard_audit:129-137`, `parity_chain:113-115` |
| 8 | Final guard four-area PASS; prior G1–G3 fixed; GF1–GF4 label-only with COORD fixes in plan | [O]/[D] `final_guard_audit:28-34/150-174`, `PLAN:35/174` |
| 9 | Internal-consistency PASS ≠ donor fidelity; no donor A/B frame, no camera match, no P0 closure | [D] `parity_recheck:40-63`, `owner_decisions:39-40`, `V109:91` |
| 10 | Verdict `RESULT IS NOT GOOD` while `blocking_unverified` non-empty | [D] `owner_brief:14/94`, `acceptance_runbook:345`, `parity_chain:40` |
| 11 | This worker wrote exactly one repository file; no code, Godot, git, donor, capture, gate, MP4, ROI metric or MCP probe executed | [O] scope |

---

*End of PORT1TO1_internal_validation. Read-only compilation; exactly one repository file written (this report). No source, shader, config, asset, test, result JSON, queue, backup, git state, Godot process, runner job, gate, capture, MP4, ROI metric, MCP host or donor binary was created, modified or executed by this worker. All commands/procedures above are quoted from the cited landed reports. No approximation adopted, no donor parity claimed, no camera match asserted, no P0 item closed. `RESULT IS NOT GOOD` while `blocking_unverified` is non-empty.*
