---
id: PORT1TO1-HASH-VERIFY2-2026-11-27
title: "Independent read-only hash verification (verify2) — preserve-only items and P-9 tool witnesses"
worker: HASH-VERIFY2 (read-only subagent)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-27
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION__NO_PARITY_CLAIM
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_hash_verify2.md
files_created: [docs/terrain_swarm_2026-11-26/reports/PORT1TO1_hash_verify2.md]
files_edited: []
scope_guard: "Read-only Get-FileHash -Algorithm SHA256 over existing repo files only, plus repo file/line reads of recorded values. No source/shader/config/asset/test/fixture/result-JSON/backup/queue change; no git operation; no Godot process/runner job/gate/capture; no donor binary opened/hashed/executed/captured/copied; donor pin referenced by report id only. Preserve-only user mods never flipped/reverted/overwritten/repaired. Exactly one repository file written: this report."
labels: [HASH_VERIFY, OBSERVED, PRESERVE_ONLY, PORT_APPROXIMATION, PARITY_UNVERIFIED, RESULT_IS_NOT_GOOD, NO_PARITY_CLAIM]
parity_status: UNVERIFIED
parity_claim: NONE
visual_parity_claim: false
verdict: "RESULT IS NOT GOOD — blocking_unverified is non-empty (nine P0 rows OPEN plus domain tails; see PORT1TO1_checklist_final.md section 4). This hash pass certifies byte identity only, never donor fidelity."
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
governing_sources:
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_checklist_final.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_hash_manifest.md
---

# PORT1TO1 — hash_verify2 (2026-11-27, read-only)

> **Mandatory reviewer line (verbatim):** PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

> **How to read.** Independent recomputation of SHA-256 for every preserve-only item and witness that has a recorded hash/prefix on disk, via read-only `Get-FileHash -LiteralPath <file> -Algorithm SHA256`, one read per file at 2026-11-27. **Hashes certify byte identity only, never donor fidelity.** Classifications: `MATCH` = current hash equals the recorded value; `POINT-IN-TIME` = current hash recorded with no prior baseline to match against (identity snapshot, not a pass); `MISMATCH` = current hash differs from a recorded hash/prefix (identity/hygiene finding only, not a parity result or gate failure). Baseline-vs-point-in-time distinction is stated per row. Nothing was repaired, reverted, re-applied, overwritten, or re-hashed-as-proof. Parity UNVERIFIED; no parity claim.

## Method and donor-binary statement

- Method: read-only `Get-FileHash -LiteralPath <repo-relative path> -Algorithm SHA256` (uppercase hex as returned), no writes, no donor paths touched.
- **No donor binary was hashed, opened, executed, copied, or captured by this worker.** The donor pin (`X59_donor_bytes_seal`, pin `t_87f0f3c130b0`, `C:\Games\Cossacks 3\cossacks.exe`) is referenced by report id only; its recorded donor-side hash `87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c` is quoted from `PORT1TO1_checklist_final.md:65`, not re-hashed here.
- Expected values transcribed from `PORT1TO1_checklist_final.md section 1` (lines 56-65); actual values recomputed this pass.

## 1. Preserve-only files with recorded hashes

| # | Exact repo path | Expected (recorded) | Actual (this read) | Class | Baseline vs point-in-time |
|---|---|---|---|---|---|
| P-1 | `variant3d/config.json` | `223767E57B506577EAD54633708380A425A0B8AA439C8E3C28478C15C8ED44E2` | `223767E57B506577EAD54633708380A425A0B8AA439C8E3C28478C15C8ED44E2` | POINT-IN-TIME (unchanged from recorded point-in-time value) | Point-in-time; no recorded baseline (`hash_manifest.md:52/113`). Not a baseline match. |
| P-2 | `variant3d/config_donor_capture.json` | `AA857480474399DC4674104744EA292BF84094D8321CDD4D0889C24CF9A202DA` | `AA857480474399DC4674104744EA292BF84094D8321CDD4D0889C24CF9A202DA` | MATCH | Baseline-matched (`owner_decisions.md:333`, `hash_manifest.md:53`); `demo_mill=true` kept. |
| P-3 | `variant3d/assets/models/manifest.json` | `36F6A378548F3116DC1585D7CDD34526A17B5C46D1DED02E3A93C7C736F22731` | `36F6A378548F3116DC1585D7CDD34526A17B5C46D1DED02E3A93C7C736F22731` | POINT-IN-TIME (unchanged from recorded point-in-time value) | Point-in-time; no recorded baseline (`hash_manifest.md:54/113`). Not a baseline match. |
| P-4a | `inbox/backup/main.gd.bak-COORD-I11` | `3859B6056BFDFDD5A659931835FD0901DD03DB36B02A453389D9338BAC9E71F8` | `3859B6056BFDFDD5A659931835FD0901DD03DB36B02A453389D9338BAC9E71F8` | MATCH | Baseline-matched single-applied I11 seam witness (V11 E1). |
| P-4b | `inbox/backup/world3d.gd.bak-COORD-I11` | `44EE96C0DCFB35558F6EA3E0493E8F8FAA1CADF6E155BEB38031A9B11E1AB07A` | `44EE96C0DCFB35558F6EA3E0493E8F8FAA1CADF6E155BEB38031A9B11E1AB07A` | MATCH | Baseline-matched single-applied I11 seam witness (V11 E2). |
| I11-live | `variant3d/scripts/main.gd` | `94C610479B1DF594C648E1AA236CBFDCDCC695319DBBCC5F9C86FB1939619EF6` (current recorded; drifted from `93faea93…` transcribed at `handoff_checklist.md:81`) | `94C610479B1DF594C648E1AA236CBFDCDCC695319DBBCC5F9C86FB1939619EF6` | POINT-IN-TIME (equals the current recorded value; MISMATCH only against the older `93faea93…` transcription) | No recorded baseline; point-in-time live file. Drift vs the older transcription is preserved as an open provenance question, not resolved here (see Drift section). |
| I11-live | `variant3d/scripts/world3d.gd` | `0A1F231930B2D39F5E486B47C37F327C9D343013162E00160CE4383894B36901` | `0A1F231930B2D39F5E486B47C37F327C9D343013162E00160CE4383894B36901` | POINT-IN-TIME (unchanged from recorded point-in-time value) | No recorded baseline; point-in-time live file. |

## 2. P-9 decode tools (baselines / recorded prefixes)

| # | Exact repo path | Recorded baseline/prefix | Actual (this read) | Class |
|---|---|---|---|---|
| P-9a | `variant3d/tools/build_terrain_new_atlas.py` | full `3A92D053A3E361001FC305F0DBD98681702BA756124566D4408BBCFDA99904FF` (= prefix `3A92D053`) | `3A92D053A3E361001FC305F0DBD98681702BA756124566D4408BBCFDA99904FF` | MATCH (baseline-matched) |
| P-9b | `variant3d/tools/terrain_qa_harness.py` | full `5A3B9E772F0BE82330F4A0E6F42D4E1B36909815A3E79ECABA9F6E311C5D8492` (= prefix `5A3B9E77`) | `5A3B9E772F0BE82330F4A0E6F42D4E1B36909815A3E79ECABA9F6E311C5D8492` | MATCH (baseline-matched) |
| P-9c | `variant3d/tools/decode_donor_cfg.py` | recorded prefix `ABBF0571` | `79BC8179FE7E5A5B00C303CC0B1E9EC9764A080A612C71FF57F0A40F59B84C47` | POINT-IN-TIME current value; PREFIX-MISMATCH vs stale recorded prefix (identity/hygiene only) |
| P-9d | `variant3d/tools/decode_pattern_lib.py` | recorded prefix `DDFB8688` | `FAA3B2E9F0E97938902B0FCBEC9326717F84EBE85490CFF8C769BF84F86716AD` | POINT-IN-TIME current value; PREFIX-MISMATCH vs stale recorded prefix (identity/hygiene only) |
| P-9e | `variant3d/tools/decode_donor_pattern.py` | recorded prefix `00C0591A` | `FB1F2F72615B9483A18A6F5EB53C8C78B03A8C8B2C2B6BEB4C066F1F201E6679` | POINT-IN-TIME current value; PREFIX-MISMATCH vs stale recorded prefix (identity/hygiene only) |
| P-9f | `variant3d/tools/decode_donor_masks.py` | recorded prefix `667B71FB` | `4C64073281BB30B56691224616251F342F5F92A414E2708761CA891F39F9EA56` | POINT-IN-TIME current value; PREFIX-MISMATCH vs stale recorded prefix (identity/hygiene only) |

Notes on P-9c…P-9f: current full hashes equal the values recorded at `checklist_final.md:62`; per `handoff_sync.md:53` the recorded prefixes are stale (files byte-identical to HEAD). This pass confirms the current full-hash values only. No re-baseline, revert, or "repair" is authorised by this report; COORD must establish provenance and independently re-run `py_compile` at A′-1 on the frozen tree (`owner_decisions.md:340`, `V102_final_blockers.md:68`).

## 3. Drift / required owner action

- **No new drift detected this pass.** Every recomputed hash equals its currently recorded value in `PORT1TO1_checklist_final.md section 1`.
- **Preserved open findings (not repaired, not reverted, owner action required):**
  1. `variant3d/scripts/main.gd` — current `94C61047…9EF6` differs from the older `93faea93…` transcription at `handoff_checklist.md:81`. Provenance not established by any read-in to date. **Owner action:** COORD to adjudicate and record the before/after hash table at capture (cf. `checklist_final.md:63/143`). Do NOT revert or overwrite either the live file or the I11 backup witnesses.
  2. Four P-9 tool prefix mismatches (P-9c…P-9f above) — stale recorded prefixes vs stable current full hashes. **Owner action:** COORD to establish provenance and independently re-run `py_compile` at A′-1 on the frozen tree; no worker re-baseline or revert.
- **Standing rule:** preserve-only user mods must never be flipped, reverted, overwritten, re-applied, or re-hashed-as-proof. If any future read shows a `MISMATCH` against the values recorded here, flag the exact path and stop; do not repair.

## 4. Parity and verdict

- `parity.status = UNVERIFIED`; `parity.claim = NONE`; `visual_parity_claim = false`.
- **Hashes certify byte identity only, never donor fidelity.** No hash in this report is a parity result, a gate pass, or a donor-fidelity claim.
- **RESULT IS NOT GOOD** while `blocking_unverified` is non-empty (nine P0 rows OPEN plus domain tails; canonical block at `PORT1TO1_checklist_final.md section 4` / `owner_brief2.md:85-97`). This RESULT IS NOT GOOD stands regardless of the MATCH rows above.
- No parity claim is made by this report.

## 5. Claim register (this report)

| # | Claim | Label / source |
|---|---|---|
| 1 | 13 SHA-256 values independently recomputed read-only; exact paths with expected vs actual recorded above | [O] `Get-FileHash` this pass; expected values from `checklist_final.md:56-65` |
| 2 | P-2/P-4a/P-4b/P-9a/P-9b MATCH their recorded baselines; P-1/P-3/live I11 files POINT-IN-TIME; P-9c…P-9f current full hashes confirmed, prefix-mismatch vs stale recorded prefixes preserved | [O] this pass vs `checklist_final.md:56-65`, `handoff_sync.md:53` |
| 3 | No new drift; two preserved open provenance findings with owner actions, no repair/revert performed | [O] this pass; scope guard |
| 4 | No donor binary hashed/opened/executed/copied/captured; donor pin by report id only | [O] scope guard; `hash_manifest.md:37/67/120` |
| 5 | Parity UNVERIFIED; hashes certify identity not fidelity; RESULT IS NOT GOOD while blocking_unverified non-empty; no parity claim | [D] `checklist_final.md:44-46/131-133` |
| 6 | Read-only worker; exactly one repository file written; no code/Godot/git/donor execution | [O] scope guard |

---

*End of PORT1TO1_hash_verify2. Read-only independent hash verification; exactly one repository file written. Parity UNVERIFIED; `parity.claim = NONE`; visual parity claim false; `RESULT IS NOT GOOD` while `blocking_unverified` is non-empty. No approximation, no parity claim, no repair/revert/re-baseline.*
