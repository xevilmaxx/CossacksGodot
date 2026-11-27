---
id: PORT1TO1-BUNDLE-VERIFY-2026-11-27
title: "Read-only path / size / SHA-256 verification of the final owner bundle, checklist and audit (full 1:1 Cossacks 3 donor port)"
worker: BUNDLE-VERIFY (read-only subagent)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-27
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION__NO_PARITY_CLAIM__NO_APPROXIMATION
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_bundle_verify.md
files_created: [docs/terrain_swarm_2026-11-26/reports/PORT1TO1_bundle_verify.md]
files_edited: []
scope_guard: "Read-only Test-Path / Get-Item.Length / Get-FileHash -Algorithm SHA256 over existing repo files only. No source, shader, config, asset, test, fixture, manifest, result JSON, backup, queue file, git state, Godot process, runner subcommand, gate, capture, ROI metric, donor binary or donor GPU frame was created, modified, executed, copied or hashed. Exactly one repository file written: this report."
labels: [BUNDLE_VERIFY, SHA256, OBSERVED, PRESERVE_ONLY, DONOR_PIN_REPORT_ID_ONLY, "PORT APPROXIMATION", PARITY_UNVERIFIED, RESULT_IS_NOT_GOOD, NO_APPROXIMATION, NO_PARITY_CLAIM]
parity_status: UNVERIFIED
parity_claim: NONE
visual_parity_claim: false
verdict: "RESULT IS NOT GOOD — blocking_unverified is non-empty; parity.status=UNVERIFIED; parity.claim=NONE; 34/34 bundle paths exist with non-zero size; one stale recorded hash assertion (label-only correction proposed, not applied by worker; CORRECTED by COORD 2026-11-27); no donor GPU A/B frame; no approximations; no parity claim."
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
governing_sources:
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_bundle_index.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_checklist_final.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_final_audit.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_hash_manifest.md
---

> **Mandatory reviewer line (verbatim):** PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

# PORT1TO1 — bundle path / size / SHA-256 verification (2026-11-27)

> **Bottom line up front:** All **34/34** paths of the authoritative minimal owner bundle in `PORT1TO1_bundle_index.md` were confirmed **present on disk with non-zero size**; SHA-256 was computed for every one. **0** bundle paths are missing, **0** are empty. Cross-check against every recorded hash/size assertion in `PORT1TO1_hash_manifest.md`, `PORT1TO1_checklist_final.md` and `PORT1TO1_bundle_index.md` found **one stale recorded assertion** — `PORT1TO1_hash_manifest.md:99` (`water_owner_protocol.md`), corrected by a **label-only** proposal in §4, **not applied** by this read-only worker; **CORRECTED by COORD 2026-11-27** in `hash_manifest.md:99`. Three `cap_fullport*.png` references are absent on disk but already disclosed as such at `PORT1TO1_checklist_final.md:92` (no new finding, no correction). **No bundle item asserts parity.** The donor pin is referenced **by report id only** and was never hashed or executed. `parity.status = UNVERIFIED`; `parity.claim = NONE`; `visual_parity_claim = false`; **`RESULT IS NOT GOOD` while `blocking_unverified` is non-empty**; no approximation adopted; no parity claim.

## 1. Method and verification universe

- Method: read-only `Test-Path -LiteralPath <file> -PathType Leaf`, `Get-Item.Length`, `Get-FileHash -LiteralPath <file> -Algorithm SHA256` (rendered lowercase), one pass at 2026-11-27. Working directory: `C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3`.
- **Verification universe** (all file paths named by the three "final" governance documents):
  - **Table A — the authoritative 34-file minimal owner bundle** from `PORT1TO1_bundle_index.md` §1–§5 (3 + 10 + 13 + 5 + 3 = 34). This is the primary target of this audit.
  - **Table B — 28 additional concrete paths asserted with hashes or "present" state** in `PORT1TO1_checklist_final.md` §1–§2 and `PORT1TO1_hash_manifest.md` §2.4.
  - **Table C — 23 governing-source report paths** named in the frontmatter of `PORT1TO1_bundle_index.md`, `PORT1TO1_checklist_final.md` and `PORT1TO1_final_audit.md` (three of these are already in Table A).
- **What a hash certifies here:** byte identity of the named repo file at this read only. A hash equality or mismatch is **never** donor fidelity, a gate pass, a matched camera/frame, or a `[U]` promotion (`PORT1TO1_hash_manifest.md:32-37`). No donor file was opened, hashed or executed.

## 2. Table A — authoritative 34-file owner bundle (all verified present, non-zero)

`MATCH` = current hash/size equals the value recorded in the cited line; `POINT-IN-TIME` = no recorded baseline exists; `STALE` = current hash/size differs from a recorded assertion (see §4).

| # | Exact path (repo-relative) | Exists | Bytes | SHA-256 (computed this pass) | Status |
|---|---|---:|---:|---|---|
| 1.1 | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_acceptance_plan.md` | yes | 40718 | `48d6d2d2bdc3786aa12e8e2fc3094d32e4f8d6e3b006826826241b60f5f3fe6b` | MATCH `hash_manifest.md:106` |
| 1.2 | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_handoff_checklist.md` | yes | 35368 | `85b11874175b815b79924955eb782f6652b20d607f44106129857d8bc413736b` | present, non-zero |
| 1.3 | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_owner_brief.md` | yes | 12407 | `4268fdf94ae708b6866389e815abcda93983f9cb1df0e599406bf875bf0bfb0d` | MATCH `hash_manifest.md:105` |
| 2.1 | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_water_owner_protocol.md` | yes | 33325 | `f794807da7b651146d1cb1a316a974a9a825b2d87502f59f6dfb156d88386750` | **STALE** `hash_manifest.md:99` — see §4 |
| 2.2 | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_fow_owner_protocol.md` | yes | 42856 | `c4b37b77ad451cf73d8d940fbdafef32f71efeb91e72ec408fbf1c2d5efd6c56` | MATCH `hash_manifest.md:100` |
| 2.3 | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_tick_owner_protocol.md` | yes | 33603 | `385f82a8a5cef8ed10c16227d8bddd3c71466a9af3b165cb59af841a33665b9e` | MATCH `hash_manifest.md:101` |
| 2.4 | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_blend_owner_protocol.md` | yes | 29334 | `6fafb550befff4325d22d64c26a0d55d7b5d02c3f8715119f646b52a1f5f08d5` | MATCH `hash_manifest.md:102` |
| 2.5 | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_save_owner_protocol.md` | yes | 28345 | `5b77f0d0731f916850323da7a1ac918b67f3bb270ccd6ee5363b99767b17a2d5` | MATCH `hash_manifest.md:103` |
| 2.6 | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_selection_owner_protocol.md` | yes | 28923 | `22dd3c34a4b69347557eab277f50daf361cc645933dd482d5e8ae244d072e5f0` | MATCH `hash_manifest.md:104` |
| 2.7 | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_rng_owner_protocol.md` | yes | 35891 | `af6b9fc2c32c247fef7ff430cea3e774219fa061356a42ec3495019d2857efb8` | present, non-zero (stale six-packet reading superseded — `bundle_index.md:77`) |
| 2.8 | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_p0_final_status.md` | yes | 30378 | `4a28c6d1136ce91cc463e7ba5a2489922c09ff0d443175177648be1b65a1eb43` | present, non-zero |
| 2.9 | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_p0_session_plan.md` | yes | 41734 | `d90102149eca045bc752866e95be371e5234051f66334382f89bbe918f6b7f49` | present, non-zero |
| 2.10 | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_session_risks.md` | yes | 37147 | `9e557d98adc738c28fc5f29b8da704f3a03980f7fa6b9d6eb9bb3388e2873662` | present, non-zero |
| 3.1 | `variant3d/tests/t_mcp_host.gd` | yes | 21859 | `96f7008c539b2540aeb7409d492df205459457baa744b7d484b28c16112507e7` | MATCH `hash_manifest.md:76` |
| 3.2a | `inbox/qa/captures/detcheck_20261113/manifest.json` | yes | 5868 | `4b3eda01ca4db8376fb87396b8f0c4acfcc59c6c645a0421b39901976ca16681` | MATCH `hash_manifest.md:84` |
| 3.2b | `inbox/qa/captures/detcheck2_20261113/manifest.json` | yes | 5882 | `bc2880f3fa0805b77e5acd6fae8a8d981c1e4e5c0d18de8f79e1e67823cae0d0` | MATCH `hash_manifest.md:85` |
| 3.2c | `inbox/qa/captures/repcheck_20261113/manifest.json` | yes | 6129 | `459c7d3e1e6283991de4f447c2e433b51c773210da97de506b11bd3d9706de23` | MATCH `hash_manifest.md:86` |
| 3.2d | `inbox/qa/captures/repcheck_20261113/repeat_verification.json` | yes | 3028 | `36b9ddf63ba6adb3edf157396732640c4f32259ea32bfb36660b690a28a8151a` | MATCH `hash_manifest.md:87` |
| 3.2e | `inbox/qa/captures/repcheck_20261113_repeat/manifest.json` | yes | 5198 | `d92b5fede78fbcbd2677f4bb0f1cc82a3a78cae7adac630f8d575682aa23bb6c` | MATCH `hash_manifest.md:88` |
| 3.2f | `inbox/qa/captures/finalcheck_20261127/manifest.json` | yes | 6159 | `fc49925214e33e72ca05bf8dc889d0bd38261f2aa96cc1cbe2026d441db532e5` | MATCH `hash_manifest.md:89` |
| 3.2g | `inbox/qa/captures/finalcheck_20261127/repeat_verification.json` | yes | 3046 | `e409885913278ba7bfb1f02dbaf82542a3d0916bf6d4cd7007cb7a59e52b32ba` | MATCH `hash_manifest.md:90` |
| 3.2h | `inbox/qa/captures/finalcheck_20261127_repeat/manifest.json` | yes | 5229 | `ce4bd3f1681b52fe507f760bc1a5ff8809fb85c97e79d7de1e317be38b144e77` | MATCH `hash_manifest.md:91` |
| 3.3 | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_roi_metrics.md` | yes | 27542 | `3097a58eb7f305b66511411ee81e9785d0b6fe8809b4ac552d15c1a7fcb8c625` | present, non-zero |
| 3.4a | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_final_guard_audit.md` | yes | 23820 | `d4c2f8a84ad2fb2d773ed34f0f7dc88df4557fd48814d56dc9aed62c532cee8c` | present, non-zero |
| 3.4b | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_claim_final.md` | yes | 15464 | `a96486ba21c51f2b7f2ac048e360cb88f4e63d584528ce25fb6c9e617c9f6515` | present, non-zero |
| 3.5 | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_hash_manifest.md` | yes | 14195 | `94e59d5b785f5d2b9f4cb31bd9603ca50bab2fe05969e574086d1341228054e9` | present, non-zero |
| 4.1 | `variant3d/config_donor_capture.json` | yes | 17912 | `aa857480474399dc4674104744ea292bf84094d8321cdd4d0889c24cf9a202da` | MATCH baseline P-2 (`bundle_index.md:131`, `hash_manifest.md:53`) |
| 4.2 | `inbox/backup/main.gd.bak-COORD-I11` | yes | 86133 | `3859b6056bfdfdd5a659931835fd0901dd03db36b02a453389d9338bac9e71f8` | MATCH baseline P-4a (`bundle_index.md:132`, `hash_manifest.md:60`) |
| 4.3 | `inbox/backup/world3d.gd.bak-COORD-I11` | yes | 37084 | `44ee96c0dcfb35558f6ea3e0493e8f8faa1cadf6e155beb38031a9b11e1ab07a` | MATCH baseline P-4b (`bundle_index.md:133`, `hash_manifest.md:61`) |
| 4.4 | `variant3d/config.json` | yes | 15981 | `223767e57b506577ead54633708380a425a0b8aa439c8e3c28478c15c8ed44e2` | POINT-IN-TIME; no recorded baseline (`bundle_index.md:134`, `hash_manifest.md:52`) |
| 4.5 | `variant3d/assets/models/manifest.json` | yes | 339158 | `36f6a378548f3116dc1585d7cdd34526a17b5c46d1ded02e3a93c7c736f22731` | POINT-IN-TIME; no recorded baseline (`bundle_index.md:135`, `hash_manifest.md:54`) |
| 5.1 | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_evidence_index.md` | yes | 162631 | `4190fdeae76b3994d54f1b1bc22677991e957feae0057e22e061c4d8e6172223` | present, non-zero |
| 5.2 | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_evidence_index_addendum.md` | yes | 26634 | `469a69407bcbf44ff4569180d67cf02c7a8e71fef7df0033430bdbbc64f76776` | present, non-zero |
| 5.3 | `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_deep_index2.md` | yes | 25864 | `1cd2b9e8745d3087e93c694ab5ccb4b353016bf0b813accb65a27115be45e326` | present, non-zero |

**Table A result:** 34/34 present, 34/34 non-zero, 0 missing, 0 empty. 1 stale recorded-hash assertion (row 2.1). All three recorded baselines P-2/P-4a/P-4b match at this read; P-1/P-3 remain point-in-time with no baseline.

## 3. Tables B and C — additional asserted paths (all hashed this pass)

### Table B — checklist / hash-manifest concrete paths outside the 34-file bundle

| Exact path | Exists | Bytes | SHA-256 (computed) | Note |
|---|---:|---:|---|---|
| `variant3d/tools/build_terrain_new_atlas.py` | yes | 44759 | `3a92d053a3e361001fc305f0dbd98681702ba756124566d4408bbcfda99904ff` | current hash equals value at `checklist_final.md:61`; baseline prefix `3A92D053` |
| `variant3d/tools/terrain_qa_harness.py` | yes | 61675 | `5a3b9e772f0be82330f4a0e6f42d4e1b36909815a3e79ecaba9f6e311c5d8492` | equals `checklist_final.md:61`; baseline prefix `5A3B9E77` |
| `variant3d/tools/decode_donor_cfg.py` | yes | 39058 | `79bc8179fe7e5a5b00c303cc0b1e9ec9764a080a612c71ff57f0a40f59b84c47` | equals current value at `checklist_final.md:62`; recorded prefix `ABBF0571` already flagged stale there |
| `variant3d/tools/decode_pattern_lib.py` | yes | 50213 | `faa3b2e9f0e97938902b0fcbec9326717f84ebe85490cff8c769bf84f86716ad` | equals `checklist_final.md:62`; recorded `DDFB8688` already flagged stale |
| `variant3d/tools/decode_donor_pattern.py` | yes | 46705 | `fb1f2f72615b9483a18a6f5eb53c8c78b03a8c8b2c2b6beb4c066f1f201e6679` | equals `checklist_final.md:62`; recorded `00C0591A` already flagged stale |
| `variant3d/tools/decode_donor_masks.py` | yes | 29341 | `4c64073281bb30b56691224616251f342f5f92a414e2708761ca891f39f9ea56` | equals `checklist_final.md:62`; recorded `667B71FB` already flagged stale |
| `variant3d/scripts/world3d.gd` | yes | 38260 | `0a1f231930b2d39f5e486b47c37f327c9d343013162e00160ce4383894b36901` | equals `checklist_final.md:63`; unchanged |
| `variant3d/scripts/main.gd` | yes | 90703 | `94c610479b1df594c648e1aa236cbfdcdcc695319dbbcc5f9c86fb1939619ef6` | equals current value at `checklist_final.md:63`; drift from `93faea93…` already disclosed there |
| `variant3d/tools/godot_runner.py` | yes | 26009 | `4ab77a980c029b2d7b7489cf9d14bf5293483a0cba618e59e2df03a71b884e52` | MATCH `hash_manifest.md:73` |
| `variant3d/tools/acceptance/capture_sequence.py` | yes | 31416 | `f208782bbe4495b3803b2e7fd85a92d73b4cf6ff3eb7f29460b4b86df5767158` | MATCH `hash_manifest.md:74` |
| `variant3d/tools/acceptance/compare_frames.py` | yes | 12081 | `ec7e91b31bbe00a4274c8fb59ea2706ead4e46921c67d0bccd65a090225cc719` | MATCH `hash_manifest.md:75` |
| `variant3d/tools/compare_shots.py` | yes | 6558 | `55e6c16253f4c7087c05d8b52814159058831f8abe409e78ca53b202bf2b391d` | present, non-zero (`checklist_final.md:87`) |
| `variant3d/tools/terrain_ab_metric.py` | yes | 36103 | `f445abfc244bce5221621731aea67c160d62cf7edda5335d7e31040ebfed76cd` | present, non-zero (`checklist_final.md:87`) |
| `variant3d/selftest.json` | yes | 4454 | `eaf38b97c194159dd1dafa97bb13f25d5866db4586103552dbada76f9e947935` | present, non-zero (`checklist_final.md:72`) |
| `variant3d/uitest.json` | yes | 2040 | `ebb9ac0e0e81b4f98b0ef269f04cb9be43b6786355f61bff5be1c23e9ba2e69b` | present, non-zero (`checklist_final.md:73`) |
| `variant3d/tests/results/t_render_mode.json` | yes | 1552 | `53a315105a005f6bb556ba4d84daf3d62b8e190d5a02779f668a97fa0144d92e` | present, non-zero (`checklist_final.md:74`) |
| `variant3d/tests/results/t_map_variety.json` | yes | 1022 | `08224d25e5b35759d979f07d50ef1fbf265ae2aa232a8d38f147167340f98e90` | present, non-zero (`checklist_final.md:75`) |
| `variant3d/tests/results/t_terrain_donor.json` | yes | 16494 | `c02f453ccb6b0c629a424b4ee1357caf3e278a351d1e98ef232ae4c26ddbce83` | present, non-zero (`checklist_final.md:76`) |
| `variant3d/tests/results/summary.json` | yes | 23874 | `1eaac209a330537cfd1783068f2db015c2fd6b614ebff2abf61e79ff7d004681` | present, non-zero (`checklist_final.md:77`) |
| `variant3d/tests/t_final_gate.gd` | yes | 1707 | `c4e4d6325d5555287a1785ab47932e2f271cb2be652481cec7c104000a9aaf6b` | present, non-zero (`checklist_final.md:78`) |
| `variant3d/tests/manifest.json` | yes | 9870 | `c09bd10e88b0cf84eb534bdab7c8675989c48eb02c8e44da37834c57b608e178` | present, non-zero (`checklist_final.md:79`) |
| `docs/terrain_swarm_2026-11-26/spec/terrain_qa_spec.json` | yes | 5913 | `4d1bfe226fb80b796e09eb520c95317d3dcb884419887f8690d3297a381b8617` | present, non-zero (`checklist_final.md:80`) |
| `inbox/qa/captures/fullport6_seq2_20261113/manifest.json` | yes | 5656 | `884ec6eeb302207d019964b001da3b35f2412d020764634ff7005c34a6e65ee9` | present, non-zero (`checklist_final.md:91`) |
| `inbox/qa/captures/fullport6_seq2_20261113/contact.json` | yes | 2238 | `759ce28214cce8fa3c78bb52457363f04630b0f403d1c4b37cf0970b0e2e83a3` | present, non-zero (`checklist_final.md:91`) |
| `variant3d/.godot_queue/results/00000133.json` | yes | 534 | `dd9c580b64a7d991455871837e0f551f0a436e054308f83796fc8f5d89da8765` | present, non-zero (`checklist_final.md:89`) |
| `cap_fullport6.png` | **MISSING** | 0 | n/a | already disclosed absent at `checklist_final.md:92` — see §4 |
| `cap_fullport7.png` | **MISSING** | 0 | n/a | already disclosed absent at `checklist_final.md:92` — see §4 |
| `cap_fullport8.png` | **MISSING** | 0 | n/a | already disclosed absent at `checklist_final.md:92` — see §4 |

`inbox/qa/captures/roi_metrics_20261113/` is a directory and holds **28** files (14 diff PNG + 14 metrics JSON), matching the count stated at `checklist_final.md:85`; no per-file hash assertion exists there.

### Table C — governing-source report paths (all present, non-zero; hashed for completeness)

| Exact path | Bytes | SHA-256 (computed) | Source |
|---:|---|---|---|
| `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_artifact_layout.md` | 36145 | `8303b85ddf371d9079b63effbb79bdde07e83cbf3333b43035b5039bd70a20f6` | bundle_index:25 |
| `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_final_gates.md` | 23335 | `3ecf84b81056d51ac502bd5092b27e0d282741114e1905d6a4c45cb6437b9f02` | bundle_index:27 / checklist:27 |
| `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_owner_brief2.md` | 15621 | `58d46dbbcf7706c4ba3051572f9e396593f45e4a00bd4d51979d66affceb4fe9` | checklist:21 / final_audit:19 |
| `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_u_register2.md` | 29554 | `93251c93480fc086c56e3771e7cf57f226b4005f7616ebe03d43ae90ba9ed9d2` | checklist:22 / final_audit:21 |
| `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_p0_packet_index.md` | 12858 | `068c561f6a19e9185bc6e9b33a84f3ae2073bcd18eac9ca087fe5643fbe9f960` | checklist:24 |
| `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_counts_sync.md` | 19403 | `571e9c512a953cd20ffcffc3ae5909498d079da9e9cdd21726844e78800f3c69` | checklist:25 / final_audit:22 |
| `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_chain_update2.md` | 26950 | `3011472da2f2ee2970b2fa97316a21f4b6e1ba05db7926de570b9534a885521d` | checklist:28 |
| `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_claim_recheck6.md` | 26709 | `4f4dec8e23aa6c680b277f3079986aa96d903051c907f6c00cecc9a26a8ff6e2` | checklist:29 |
| `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_claim_recheck7.md` | 25340 | `3f901c94cf927ae063b1b90800277460cf335454f9bbb1a7b9312bbbc85fcae6` | checklist:30 |
| `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_handoff_sync.md` | 10546 | `b605a1d8f96094dbdb4e022ca740e321af86eb2e5ac73883625fe775c5417ac9` | checklist:31 |
| `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_handoff_check2.md` | 16053 | `a68a2b4183719d8ffc2471773d64e04b7becf20527ee81c9c7c1188886a113a3` | checklist:32 |
| `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_index_final3.md` | 32041 | `c72042bd21cced57f4687e906501efacc59f78ca72c5ada6d5d285162404989d` | checklist:33 |
| `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_b_angle_final.md` | 24190 | `47caf70c35734b46fb7029fff496132e29f7ff4822e33b82146bcb7b8fe6b55b` | checklist:34 |
| `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_full_project_audit.md` | 45060 | `0158daa0c92f15bbf879e54b1f1d6cdf6bc488fbc73f9028a96462270f65d590` | final_audit:18 |
| `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_verdict_sync.md` | 33014 | `9cddcee509a4587e9a8f7865f5a392b3b01e40548a7c9fcf33c0ffeffc5b0d8d` | final_audit:23 |
| `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_handoff_vsync.md` | 15098 | `01415a351d4218795c061e5dd2c7938eeb7caf3f7c179c0810a97ce2784d7efe` | final_audit:24 |
| `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_parity_chain.md` | 28195 | `29b0fb8c12e90f3430154bc7de15579f8669504c5c6a9f1e01385624365cf24a` | final_audit:26 |
| `docs/terrain_swarm_2026-11-26/PORT1TO1_PLAN.md` | 49879 | `a839441b6e662de520a45905d8b8c6ff4593fcdec2194dd9b11e6f7029593dd0` | final_audit:28 |
| `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_checklist_final.md` | 27381 | `599421a12769ad37f88616a0a3ddf89c3889d18764d90eecca63948c5307e433` | final_audit:25 |
| `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_final_audit.md` | 17489 | `5d9f9a7d047a5d22701f676c5d400ebad29c9e2ab3e5043e66ec2722dc605d09` | this audit's target |
| `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_bundle_index.md` | 24338 | `f74bfcd08299f30e03ec3bb9ffa63bdae76a4251bd75b18096c84863d90b21f2` | this audit's target |
| `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_evidence_index_addendum.md` | 26634 | `469a69407bcbf44ff4569180d67cf02c7a8e71fef7df0033430bdbbc64f76776` | bundle member 5.2 |
| `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_deep_index2.md` | 25864 | `1cd2b9e8745d3087e93c694ab5ccb4b353016bf0b813accb65a27115be45e326` | bundle member 5.3 |

**Tables B/C result:** 51/51 concrete paths present and non-zero except the three already-disclosed `cap_fullport*.png` absences. No new missing or empty path found.

## 4. Flags — exact line pointer and label-only correction

### FLAG-STALE-1 (one stale recorded hash/size assertion)

- **Exact line pointer:** `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_hash_manifest.md:99` (row 2.6).
- **Recorded at that line:** size `33009`, SHA-256 `626c3bbcce1b2e4b3523f11162025cf5bf2c9a5edec4d63d711ed8768c490cde`, role `P0-1/1b/2 water owner packet`.
- **Verified on disk this pass:** size `33325`, SHA-256 `f794807da7b651146d1cb1a316a974a9a825b2d87502f59f6dfb156d88386750`.
- **Classification:** identity/hygiene staleness of a point-in-time hash assertion only. **No** parity result, defect conclusion, gate failure or `[U]` change attaches. The file itself is a present, non-zero owner run-book (`bundle_index.md:66`); `bundle_index.md` does not record a hash for it, so no second assertion is stale.
- **Label-only correction (PROPOSED — not applied by this read-only worker; CORRECTED by COORD 2026-11-27 — `hash_manifest.md:99` now records `33325` / `F794807D…6750` with "point-in-time, no parity/gate implication"; plan row 283 DONE):**

  Replace line 99 with:
  `| docs/terrain_swarm_2026-11-26/reports/PORT1TO1_water_owner_protocol.md | 33325 | f794807da7b651146d1cb1a316a974a9a825b2d87502f59f6dfb156d88386750 | P0-1/1b/2 water owner packet; **point-in-time identity only — no recorded baseline; byte identity, NOT donor fidelity, NOT a gate or parity result** |`

- **Guard on correction:** do not treat the old `626c3bbc…` value as a baseline, do not flip or revert any preserve-only flag, do not re-apply an I11 seam, do not promote any `[U]`, and do not read the correction as a gate pass.

### FLAG-MISSING-1/2/3 (already-disclosed absences — no correction required)

- **Exact line pointer:** `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_checklist_final.md:92`.
- `cap_fullport6.png`, `cap_fullport7.png`, `cap_fullport8.png` are absent on disk. This is already stated verbatim at that line ("read-only audits found them absent on disk … Discrepancy preserved verbatim, neither resolved nor repaired").
- **Label-only correction:** **none** — the existing label is accurate; preserve it unchanged. No asset creation, restoration or substitution is authorised.

### Confirmations of already-disclosed discrepancies (no new finding)

- `checklist_final.md:62` four decode-tool prefix mismatches (`ABBF0571`/`DDFB8688`/`00C0591A`/`667B71FB`): current hashes computed this pass equal the "current" values transcribed there; the recorded prefixes remain stale as disclosed. No re-baseline applied.
- `checklist_final.md:63` live `main.gd` = `94c61047…19ef6`, drift from `93faea93…` at `handoff_checklist.md:81`: confirmed; provenance remains for COORD; no change.
- `bundle_index.md:77` stale six-packet / "P0-7 has no packet" reading: superseded by the seven-packet set; the RNG packet file is present and non-zero (Table A row 2.7). No repair applied.

## 5. Guardian confirmations required by the task

1. **No bundle item asserts parity.** `PORT1TO1_bundle_index.md:36`, `:42` and `:155-168` state explicitly: "No item in this bundle closes donor parity";each row's "What claim it does NOT support" column negates parity, gate, `[U]`-retirement and ticket-ack readings; `parity_claim = NONE`, `parity.status = UNVERIFIED`, `visual_parity_claim = false`. `PORT1TO1_checklist_final.md:132` states "NO ITEM ON THIS CHECKLIST CLOSES DONOR PARITY"; `PORT1TO1_final_audit.md:92` states no worker action can close parity. Verified: nothing in the 34 bundle rows asserts donor parity or a gate pass; the hash/size rows certify byte identity only.
2. **Donor pin is referenced by report id only — never hashed or executed.** `PORT1TO1_bundle_index.md:137`, `PORT1TO1_checklist_final.md:65`, `PORT1TO1_hash_manifest.md:67` and §2.3 record `X59_donor_bytes_seal` / pin `t_87f0f3c130b0` (`C:\Games\Cossacks 3\cossacks.exe`) with donor-side hash `87f0f3c1…c16` **quoted from the report, not computed here**; the donor binary is outside the repo and is not a bundle file. This worker did not open, hash, execute, copy or capture it. No donor-side value was used in any Table A/B/C computation.
3. **Parity UNVERIFIED.** `parity_status: UNVERIFIED`, `parity_claim: NONE`, `visual_parity_claim: false`. Six-condition chain **0/6 CLOSED** (conditions 2 and 6 PARTIAL port-internal only; 1/3/4/5 BLOCKED). No donor GPU A/B frame exists; no matched camera/ROI manifest; no COORD zero-mismatch ruling.
4. **`RESULT IS NOT GOOD` while `blocking_unverified` is non-empty.** Nine P0 rows OPEN; 71 open `[U]` (A42/B14/C5/D10); D4 stays `[U]`; tickets 575/582/585 UNACKED. `RESULT IS GOOD` is admissible only when `blocking_unverified = []` and all six conditions hold — not today.
5. **No approximations adopted; no parity claim.** All `PORT APPROXIMATION` / `[U]` labels and P0 hard-fails remain intact. Forbidden phrasing remains forbidden: "matches donor", "close to donor", "donor parity", "similarity %", "donor threshold PASS", "gate PASS" derived from a capture. This report makes none of them and promotes no `[D]`, metric, replay pair or hash to parity.

## 6. Claim register and scope attestation

| # | Claim | Label / source |
|---|---|---|
| 1 | 34/34 bundle paths exist with non-zero size; SHA-256 computed for each | [O] read-only `Test-Path` / `Get-FileHash` this pass, Table A |
| 2 | One stale recorded hash/size assertion at `hash_manifest.md:99`, label-only correction proposed (CORRECTED by COORD 2026-11-27) | [O] Table A row 2.1 vs `hash_manifest.md:99`, §4 FLAG-STALE-1 |
| 3 | Three `cap_fullport*.png` paths absent, already disclosed at `checklist_final.md:92`; no correction | [O] §4 FLAG-MISSING-1/2/3 |
| 4 | Three recorded baselines P-2/P-4a/P-4b match; P-1/P-3 point-in-time, no baseline | [O]/[D] Table A rows 4.1–4.5, `hash_manifest.md:112-113` |
| 5 | No bundle item asserts parity; donor pin by report id only, never hashed/executed | [D] `bundle_index.md:36/42/137/155-168`, `checklist_final.md:65/132`, `hash_manifest.md:67`, `final_audit.md:92` |
| 6 | Read-only worker; exactly one repository file written; no code/Godot/git/donor execution; no approximation; no parity claim | [O] scope guard |

---

*End of PORT1TO1_bundle_verify. Read-only verification; exactly one repository file written: `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_bundle_verify.md`. Parity UNVERIFIED; `parity.claim = NONE`; `visual_parity_claim = false`; `RESULT IS NOT GOOD` while `blocking_unverified` is non-empty. No approximation, no parity claim; no item in the bundle closes donor parity.*
