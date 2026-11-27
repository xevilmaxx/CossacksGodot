---
id: PORT1TO1-HASH-MANIFEST-2026-11-27
title: "SHA-256 identity manifest for the minimal owner parity-decision bundle (full 1:1 Cossacks 3 donor port)"
worker: HASH-MANIFEST (read-only subagent)
date: 2026-11-27
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_hash_manifest.md
files_created: [docs/terrain_swarm_2026-11-26/reports/PORT1TO1_hash_manifest.md]
files_edited: []
scope_guard: "Read-only repo file/line reads plus read-only Get-FileHash -Algorithm SHA256 over existing files only. No source, shader, config, asset, test, fixture, manifest, result JSON, backup, queue file, app/ byte, git state, Godot process, runner subcommand, gate, capture, ROI metric, donor binary or donor file was created, modified, executed, copied or hashed by this worker. Exactly one repository file written: this report. No donor GPU A/B frame produced or compared."
labels: [IDENTITY_MANIFEST, SHA256, OBSERVED, PRESERVE_ONLY, DONOR_PIN_REPORT_ID_ONLY, "PORT APPROXIMATION", PARITY_UNVERIFIED, NO_PARITY_CLAIM]
governing_sources:
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_artifact_layout.md (§5.1, §6, §7)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_p0_packet_index.md (§1)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_owner_brief.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_acceptance_plan.md
  - docs/terrain_swarm_2026-11-26/reports/X59_donor_bytes_seal.md (§2, §4)
parity_status: UNVERIFIED
parity_claim: NONE
visual_parity_claim: false
verdict: "RESULT IS NOT GOOD — blocking_unverified is non-empty; six-condition parity chain 0/6 closed; no donor GPU A/B frame; hashes certify artifact identity only; no parity claim."
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
---

# PORT1TO1 — SHA-256 identity manifest for the minimal owner parity-decision bundle (2026-11-27)

> **Mandatory reviewer line, verbatim (`PORT1TO1_owner_decisions.md:15/32`, `PORT1TO1_acceptance_plan.md:28-29`):**
> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

> **Scope of this manifest.** `PORT1TO1_artifact_layout.md` lists directories but records only three baseline hashes (§5.1). This report closes that documentation gap for the **minimal owner parity-decision bundle only** — it does **not** hash the 328-report corpus, captures, ROI metrics, configs, backups or tools at large. Every row below is a point-in-time SHA-256 of an **existing repo file**, computed with read-only `Get-FileHash -Algorithm SHA256`. Hashes certify **artifact identity**, **NOT donor fidelity**. No parity claim is made, and parity remains **UNVERIFIED**.

## 0. What a hash in this manifest does and does not certify

- **Does certify:** the exact byte identity of the named repo file at the read recorded here; detection of later byte drift in that file; agreement with a previously recorded baseline hash where one exists (§5.1).
- **Does NOT certify:** donor fidelity, donor parity, a gate pass, implementation correctness, matching inputs, a same-camera donor A/B frame, or any `[U]` → `[D]` promotion. A matched preserve-only hash is byte-preservation evidence only (`artifact_layout.md:242`).
- **No parity decision.** The owner decision requires all six conditions in `artifact_layout.md` §6; status is 0/6; no subset of these hashes closes any condition.
- **Donor binary: never hashed by this worker.** The donor pin witness is recorded by **report id only** (§2.2). The donor `cossacks.exe` was not opened, hashed, executed, copied or captured in this pass.

## 1. Method

- Working directory: `C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3`; paths below are repo-relative with forward slashes.
- Read-only PowerShell `Get-FileHash -LiteralPath <file> -Algorithm SHA256`, one pass per file at 2026-11-27; sizes from read-only `Get-Item.Length`; hashes rendered lowercase.
- No file was written except this report; no donor file was read or hashed; no Godot/Git/runner/gate/capture/ROI operation was performed.
- Bundle membership taken from: `artifact_layout.md` §5.1 (three preserve-only configs/manifest + two I11 backups + donor pin), §5 (tool files), §2/§3 (deterministic capture artifacts), `p0_packet_index.md` §1 (six owner packets), plus owner brief and acceptance plan as named in the task.

## 2. Manifest — path / size / SHA-256 / role

### 2.1 Three preserve-only configs/manifest (P)

| Path | Size (B) | SHA-256 | Role |
|---|---:|---|---|
| `variant3d/config.json` | 15981 | `223767e57b506577ead54633708380a425a0b8aa439c8e3c28478c15c8ed44e2` | preserve-only config; owner mod; **no recorded baseline** — point-in-time reading only (artifact_layout.md:252) |
| `variant3d/config_donor_capture.json` | 17912 | `aa857480474399dc4674104744ea292bf84094d8321cdd4d0889c24cf9a202da` | preserve-only capture config; **matches recorded baseline P-2** (owner_decisions.md:333, acceptance_plan.md:310, parity_chain.md:113) |
| `variant3d/assets/models/manifest.json` | 339158 | `36f6a378548f3116dc1585d7cdd34526a17b5c46d1ded02e3a93c7c736f22731` | preserve-only asset manifest; **no recorded baseline** — point-in-time reading only (artifact_layout.md:253) |

### 2.2 I11 backups (P)

| Path | Size (B) | SHA-256 | Role |
|---|---:|---|---|
| `inbox/backup/main.gd.bak-COORD-I11` | 86133 | `3859b6056bfdfdd5a659931835fd0901dd03db36b02a453389d9338bac9e71f8` | hashed I11 seam witness E1; **matches recorded baseline P-4a** (artifact_layout.md:247) |
| `inbox/backup/world3d.gd.bak-COORD-I11` | 37084 | `44ee96c0dcfb35558f6ea3e0493e8f8faa1cadf6e155beb38031a9b11e1ab07a` | hashed I11 seam witness E2; **matches recorded baseline P-4b** (artifact_layout.md:248) |

### 2.3 Donor pin witness — report id only, donor binary NOT hashed

| Witness | Recorded pin id | SHA-256 | Role |
|---|---|---|---|
| `X59_donor_bytes_seal` (`reports/X59_donor_bytes_seal.md`), corroborated by `D01_rtti_function_anchors`, `D02_seed_rng`, `D06_water_shore` and other DEC-DEEP reports | `t_87f0f3c130b0` (`C:\Games\Cossacks 3\cossacks.exe`) | **NOT COMPUTED — report id only.** Donor binary was not opened, hashed, executed or copied by this worker. X59 §2/§4 records the donor-side witness hash `87f0f3c130b0…c16` for that pinned target; it is quoted from the report, **not re-hashed here**. | donor pin identity witness; read-only, outside the repo; never an admissible A/B frame |

### 2.4 Key tool files (E, tooling)

| Path | Size (B) | SHA-256 | Role |
|---|---:|---|---|
| `variant3d/tools/godot_runner.py` | 26009 | `4ab77a980c029b2d7b7489cf9d14bf5293483a0cba618e59e2df03a71b884e52` | owner-managed runner spool driver (`run/status/ack`); no recorded baseline in cited reports — point-in-time reading only |
| `variant3d/tools/acceptance/capture_sequence.py` | 31416 | `f208782bbe4495b3803b2e7fd85a92d73b4cf6ff3eb7f29460b4b86df5767158` | only legal serial viewport capture harness; `--deterministic-capture`/`--capture-ticks` remain design-only (artifact_layout.md:114) |
| `variant3d/tools/acceptance/compare_frames.py` | 12081 | `ec7e91b31bbe00a4274c8fb59ea2706ead4e46921c67d0bccd65a090225cc719` | ROI diff tool; always prints `parity=UNVERIFIED`; never promotes parity (acceptance_plan.md:247-252) |
| `variant3d/tests/t_mcp_host.gd` | 21859 | `96f7008c539b2540aeb7409d492df205459457baa744b7d484b28c16112507e7` | MCP host protocol constants (artifact_layout.md:113) |

> The six P-9 tool hash prefixes quoted at `artifact_layout.md:255` (`ABBF0571 / DDFB8688 / 00C0591A / 667B71FB / 3A92D053 / 5A3B9E77`) belong to the `decode_*.py` tools, not to the four files above. No baseline claim is made for §2.4.

### 2.5 Four deterministic capture manifests / diff artifacts (E — port-internal, not donor A/B)

| Path | Size (B) | SHA-256 | Role |
|---|---:|---|---|
| `inbox/qa/captures/detcheck_20261113/manifest.json` | 5868 | `4b3eda01ca4db8376fb87396b8f0c4acfcc59c6c645a0421b39901976ca16681` | detcheck primary capture manifest (`--capture-ticks 64`, seed 20261113) |
| `inbox/qa/captures/detcheck2_20261113/manifest.json` | 5882 | `bc2880f3fa0805b77e5acd6fae8a8d981c1e4e5c0d18de8f79e1e67823cae0d0` | detcheck2 primary capture manifest |
| `inbox/qa/captures/repcheck_20261113/manifest.json` | 6129 | `459c7d3e1e6283991de4f447c2e433b51c773210da97de506b11bd3d9706de23` | repcheck primary capture manifest |
| `inbox/qa/captures/repcheck_20261113/repeat_verification.json` | 3028 | `36b9ddf63ba6adb3edf157396732640c4f32259ea32bfb36660b690a28a8151a` | repcheck diff/repeat verification artifact (primary vs repeat) |
| `inbox/qa/captures/repcheck_20261113_repeat/manifest.json` | 5198 | `d92b5fede78fbcbd2677f4bb0f1cc82a3a78cae7adac630f8d575682aa23bb6c` | repcheck repeat-run manifest |
| `inbox/qa/captures/finalcheck_20261127/manifest.json` | 6159 | `fc49925214e33e72ca05bf8dc889d0bd38261f2aa96cc1cbe2026d441db532e5` | finalcheck primary capture manifest |
| `inbox/qa/captures/finalcheck_20261127/repeat_verification.json` | 3046 | `e409885913278ba7bfb1f02dbaf82542a3d0916bf6d4cd7007cb7a59e52b32ba` | finalcheck diff/repeat verification artifact (primary vs repeat) |
| `inbox/qa/captures/finalcheck_20261127_repeat/manifest.json` | 5229 | `ce4bd3f1681b52fe507f760bc1a5ff8809fb85c97e79d7de1e317be38b144e77` | finalcheck repeat-run manifest |

> **Reading:** `detcheck`/`detcheck2` carry a primary `manifest.json` only; `repcheck`/`finalcheck` additionally carry a `repeat_verification.json` diff artifact and a `_repeat/manifest.json`. All eight rows are **port-internal** evidence: they document deterministic-capture replay within the port, contain no donor GPU A/B frame, and do not close parity condition 4 or 6 (`artifact_layout.md` §6). The frame PNGs and runner stdout/stderr inside those directories are **not** part of this minimal manifest.

### 2.6 Six owner P0 packets + owner brief/plan (E — owner-only run-books)

| Path | Size (B) | SHA-256 | Role |
|---|---:|---|---|
| `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_water_owner_protocol.md` | 33325 | `F794807DA7B651146D1CB1A316A974A9A825B2D87502F59F6DFB156D88386750` | P0-1/1b/2 water owner packet; point-in-time (no baseline), no parity/gate implication |
| `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_fow_owner_protocol.md` | 42856 | `c4b37b77ad451cf73d8d940fbdafef32f71efeb91e72ec408fbf1c2d5efd6c56` | P0-3 FOW owner packet |
| `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_tick_owner_protocol.md` | 33603 | `385f82a8a5cef8ed10c16227d8bddd3c71466a9af3b165cb59af841a33665b9e` | P0-4 tick owner packet |
| `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_blend_owner_protocol.md` | 29334 | `6fafb550befff4325d22d64c26a0d55d7b5d02c3f8715119f646b52a1f5f08d5` | P0-5 blend/completion owner packet |
| `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_save_owner_protocol.md` | 28345 | `5b77f0d0731f916850323da7a1ac918b67f3bb270ccd6ee5363b99767b17a2d5` | P0-6 save container/transform owner packet |
| `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_selection_owner_protocol.md` | 28923 | `22dd3c34a4b69347557eab277f50daf361cc645933dd482d5e8ae244d072e5f0` | P0-8 selection/projection/camera owner packet |
| `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_owner_brief.md` | 12407 | `4268fdf94ae708b6866389e815abcda93983f9cb1df0e599406bf875bf0bfb0d` | owner brief |
| `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_acceptance_plan.md` | 40718 | `48d6d2d2bdc3786aa12e8e2fc3094d32e4f8d6e3b006826826241b60f5f3fe6b` | owner acceptance plan |

> Every P0 packet is an owner-only run-book that closes nothing by itself (`p0_packet_index.md:26`); hashing them certifies the documents' identity, not that any packet's zero-mismatch gate was run or passed.

## 3. Baseline cross-check and limits

- The three recorded baselines in `artifact_layout.md` §5.1 (P-2 `aa857480…`, P-4a `3859b605…`, P-4b `44ee96c0…`) **match** the values computed here at this read. This is point-in-time byte-preservation evidence only — **not** donor parity and **not** a gate pass.
- `variant3d/config.json` and `variant3d/assets/models/manifest.json` have **no recorded baseline** in the cited reports; their values here are point-in-time readings, not preservation-against-baseline claims (`artifact_layout.md:250-253`).
- No recorded baseline exists in the cited reports for the four §2.4 tools or the eight §2.5 manifests/diffs; their values are point-in-time identity readings only.
- Concurrency caveat: reports in `reports/` are still being landed by other workers; §2.6 values are as read at this pass and may be re-read by COORD immediately before any freeze.

## 4. Explicit statements and claim register

1. **Hashes certify artifact identity, NOT donor fidelity.** No hash in this report is a similarity measure, a threshold, a gate result, or a parity proof.
2. **The donor pin witness is recorded by report id only** (`X59_donor_bytes_seal`, pin `t_87f0f3c130b0`). This worker did **not** hash, open, execute, copy or capture the donor binary `cossacks.exe`; the donor-side hash quoted from X59 is not a hash computed here.
3. **No parity claim.** `parity.claim = NONE`, `parity.status = "UNVERIFIED"`, `visual_parity_claim = false`; no tier above 2 exists; no donor GPU A/B frame exists.
4. **Six-condition chain 0/6 closed.** This manifest supplies none of the six conditions in `artifact_layout.md` §6 and makes no approximation.
5. **`RESULT IS NOT GOOD`** while `blocking_unverified` is non-empty (P0-1…P0-8 remain open).
6. **Scope attestation.** Read-only worker. Exactly one repository file written: this report. No code, Godot job, git operation, capture, ROI metric, donor execution, or other artifact change. The four deterministic-capture directories were read only for their JSON manifest/diff files; their PNG frames and runner logs were neither hashed nor modified.

*End of PORT1TO1_hash_manifest. Read-only identity manifest; exactly one repository file written. Hashes certify artifact identity, not donor fidelity. Parity UNVERIFIED; no parity claim.*
