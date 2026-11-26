---
id: V97-FINAL-COUNTS-2026-11-26
title: "FINAL counts seal — launches, reports, implementation files, derived assets, temp corpora, active workers; reconciled against V87"
agent: "V97 (read-only final-counts subagent, 30-agent DONOR-FIRST terrain swarm 2026-11-26; reporting to COORD)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_EDIT__NO_GODOT_JOB__NO_GATE_RUN__NO_CAPTURE__NO_PARITY_CLAIM
owner_file: docs/terrain_swarm_2026-11-26/reports/V97_final_counts.md
files_created: [docs/terrain_swarm_2026-11-26/reports/V97_final_counts.md]
files_edited: []
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_claim: false
parity_status: UNVERIFIED
frozen_at: "2026-11-26 10:26:07 local (final dual-pass snapshot; all counts point-in-time)"
snapshot_note: "Filesystem-authoritative, two independent count commands per headline figure. Both the report set and SWARM_BOARD.md grew during this read: reports 117 (V87) -> 119 -> 120 -> 122 -> 127; board rows 151 (V87) -> 155 -> 162. The frozen 10:26:07 read is the authority for this seal. No source, shader, asset, config, test, result JSON, git, Godot, runner, capture or donor state was touched. No gate run, no donor GPU A/B frame, no donor-parity claim."
---

# V97 — FINAL COUNTS SEAL (2026-11-26)

> **Honest frame.** Every number here is **file presence / filesystem evidence only**. A landed report, a present implementation file or a generated asset is **not** correctness, not a gate PASS, not spec READY and not donor parity. Reconciled against V87 (`reports/V87_swarm_statistics.md`, frozen 10:19:46), which is **landed** at this read. No parity claim is made anywhere in this report.

## 0. Verification method — two independent commands per headline count

| Count | Command A | Command B | Frozen result (10:26:07) |
|---|---|---|---|
| Report files | `Get-ChildItem -Recurse -File -Filter *.md` → `.Count` | `[IO.Directory]::GetFiles($p,'*.md',AllDirectories)` → `.Count` | **127 = 127** |
| Report IDs | `($_.BaseName -split '_')[0]` → `Sort-Object -Unique` | same extracted array → `.Count` distinct | **127 distinct = 127 files** (one report per worker) |
| Board worker IDs | regex `^\|\s*([A-Z]{1,2}\d{2})\s*\|\s*(Binary\|Data\|Port\|Design\|Verify\|Impl)\s*\|` over `Get-Content` lines | same regex over `Get-Content -Raw` via `[regex]::Matches` | **162 = 162 distinct IDs** |
| RUNNING board slots | board-ID set minus report-ID set (`HashSet`) | re-enumeration of `RUNNING` rows at second pass | **38 = 38** |
| Derived assets | `Measure-Object -Sum Length` over recursive listing | `foreach { $n++; $bytes += $f.Length }` accumulator | **5,255 files / 302,411,732 B** (identical) |
| Temp corpora | recursive `Get-ChildItem` + `Measure-Object` on the three temp folders | `[IO.Directory]::GetFiles` + `foreach` byte accumulator | **41,310 files / 614,758,996 B** (identical, both per-folder and total) |

The report set and the board were edited concurrently by other workers during every pass; the frozen 10:26:07 dual pass is the authority. Earlier passes in this read: reports 117 → 119 → 120 → 122 → 127; board 151 → 155 → 162. No separate session-completion ledger exists, so "active" cannot be observed (see §3).

## 1. Final counts — headline numbers (frozen 2026-11-26 10:26:07)

| Metric | Count | Notes |
|---|---:|---|
| **Distinct worker IDs launched (SWARM_BOARD rows)** | **162** | D01–D09 = 9; F01–F10 = 10; P01–P06 = 6; A01–A06 = 6; I = 16; V = 70; X = 45. Charter originally 125 rows; V87 froze 151; V45 (concurrent board owner) grew it to 162 during this read. Board rows are **documentation**, not proof a session ran. |
| **Union of board IDs + report IDs** | **165 distinct IDs** | 3 report ids have no board row at the frozen read (very late landings); they are real launched workers, not invented owners. N-ticket artefacts (N14/N16/N17/N18/N19) and board/index workers (V45/V50/V74/V87) are **not** counted as separate board launches. |
| **Reports landed (files)** | **127** | `reports/**`, 127 distinct worker ids ⇒ one report per worker, as the charter requires. V87 froze 117 (10:19:46); grew during this read. Newest at freeze include V52, X67, V90, V95, X59, X44. **File presence only.** |
| **Spec files** | **17** | §00–§14 section files (15) + `README.md` + `terrain_qa_spec.json`; all present, none marked READY (board/REPORT_INDEX). |
| **Implementation files on disk (core, created)** | **13** | 6 tools (`decode_donor_cfg.py`, `decode_donor_pattern.py`, `decode_pattern_lib.py`, `decode_donor_masks.py`, `build_terrain_new_atlas.py`, `terrain_qa_harness.py`); 5 GDScript (`terrain_donor_data/gen/mesh/props/world.gd`); 1 shader (`terrain_donor_shader.gdshader`); 1 test (`t_terrain_donor.gd`). Verified with `Test-Path`. |
| **Additional implementation artefacts** | **4** | `main.gd` + `world3d.gd` modified in place (I11 two-file seam, **not** new files) + 2 `*.bak-COORD-I11` backups; `spec/terrain_qa_spec.json` (N17) lives in `spec/`, counted in the 17 spec files. |
| **Absent implementation files** | **4** | `terrain_donor_tiles.gd` (I07 second file), `validate_terrain_new.py` (N7), `inbox/qa/terrain_qa_report.json` (N18), `inbox/qa/captures/` (N19). `inbox/qa/**` holds PENDING markers only. |
| **Derived assets generated** | **5,255 files / 302,411,732 B (~288.6 MiB)** | `variant3d/assets/terrain_new/**`, all derived, untracked, **unvalidated**. Identical to V87's frozen figure — this tree was stable across both reads. At V77 it held only 780 `.json` files / ~242,316,351 B; it grew mainly in the `masks/` tier. |
| **Temp corpora outside repo** | **41,310 files / 614,758,996 B (~586 MiB)** | From reports (V87 §1.2 / X01 §4.1 / X02 §4) **and independently re-verified on disk at this read** with two commands. All under `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\`. No donor binary or derived corpus is in the repo or committed. |

### 1.1 Derived-asset tiers (frozen 10:26:07 — exact agreement with V87 §1.1)

| Tier | Files | Bytes |
|---|---:|---:|
| `patterns/` | 777 | 238,526,989 |
| `masks/` | 4,467 | 52,757,581 |
| `atlas/` | 8 | 7,551,760 |
| `cfg/` | 3 | 3,575,402 |
| **Total** | **5,255** | **302,411,732** |

Extension census: **785 `.json` + 4,470 `.png`**. `atlas/` is **present** at this read (8 files), although `SWARM_BOARD.md` and the V77 index still record it as absent — those documents are stale on this point. No asset byte check, decoder replay or gate run was performed here.

### 1.2 Temp corpora outside repo (report-sourced + independent on-disk re-verification)

| Folder | Files | Bytes | Source |
|---|---:|---:|---|
| `cossacks3_decomp/` | 18,919 (18,918 `.c` + 1 state file) | 298,135,470 | X01 §4.1 — 18,918/18,918 discovered functions, 4,265 (22.54%) structured:false |
| `editor_decomp/` | 22,385 (22,384 `.c` + 1 state file) | 315,391,988 | X02 §4 — 22,384/22,384 discovered functions, 12,254 (54.7%) garble markers |
| `editor_decomp_idx/` | 6 | 1,231,538 | X02 §2 — matches/garble/api-callers/api-roles tables + sweep scripts |
| **Total** | **41,310** | **614,758,996** | Private-use donor derivative, outside repo, never executed or committed |

Each row matched **exactly** under both disk methods (`Get-ChildItem`+`Measure-Object` and `[IO.Directory]::GetFiles`+accumulator), and the totals match V87's report-sourced figures exactly. X01's own caveat stands: only **11 of 34** D01 terrain anchors are in the discovered set, so corpus "completeness" is relative to discovered functions only.

## 2. Reconciliation against V87

V87 is **present** at this read (`Test-Path` = True). It froze at 10:19:46; this seal froze at 10:26:07 (~6 minutes later), during which concurrent workers kept landing reports and editing the board.

| Metric | V87 (10:19:46) | V97 (10:26:07) | Delta | Reconciled? |
|---|---:|---:|---:|---|
| Board worker IDs | 151 | 162 | +11 | Yes — board grew (V=63→70, X=41→45) by concurrent V45 board edits; no contradiction, both authoritative at their own instant. |
| Report files / distinct IDs | 117 / 117 | 127 / 127 | +10 | Yes — 10 late landings (incl. V52, X67, V90, V95, X59, X44); one report per worker invariant holds in both. |
| Union board+reports | 158 | 165 | +7 | Yes — follows the two growths above. |
| RUNNING board slots | 38 | 38 | 0 | Yes — identical set (I01–I15, 19 V slots, X04/X10/X14/X32). |
| Spec files | 17 | 17 | 0 | Yes — stable. |
| Core implementation files | 13 present | 13 present | 0 | Yes — `Test-Path` re-check; `terrain_donor_tiles.gd` still absent. |
| Derived assets | 5,255 / 302,411,732 B | 5,255 / 302,411,732 B | 0 | Yes — exact, including all four tiers. |
| Temp corpora | 41,310 / 614,758,996 B | 41,310 / 614,758,996 B | 0 | Yes — exact, independently re-verified on disk here. |

**No contradiction with V87 was found.** All deltas are explained by documented concurrent growth of the report set and the board (`V87 §0` snapshot_note; `SWARM_BOARD.md` V45/V74 refresh notes). V87's own discarded-pass caveat (a `$Matches` reuse bug it corrected) does not affect any figure reconciled above. V87 remains the canonical final-statistics report; this V97 report is the later counts seal, not a replacement.

## 3. Workers still active at this read — honest answer

**38 board slots are `RUNNING` (no report file on disk) at the frozen read**, exactly matching V87's 38:

- **I01–I15 (15):** implementation tickets — owner files present for I01–I13 but unvalidated; I14/I15 have **no ticket definition on disk** (no owner invented). `RUNNING` here follows the report-file rule, not observed execution.
- **V02, V10, V14, V18, V19, V22–V25, V29–V32, V35, V39–V41, V43, V45 (19):** mostly "Reserved (no evidence)" / "no report" slots; V43 has re-verify notes in `spec/12`–`spec/14`, V45 has the board-refresh note. No report content inferred for the others.
- **X04, X10, X14, X32 (4):** extra donor text, extra donor schema, evidence index, reserved slot. X14 has `spec/00_EVIDENCE_INDEX.md` but no `reports/X14*.md`.

**Separately, ≥28 distinct workers demonstrably *delivered* reports in the final 15-minute window** (V87 §2's burst list, e.g. V83/V90/V95/X56/X59/X67/V52). That is report-evidenced activity, **not** an observation of live Godot/Craft Anything sessions.

**Caveat:** `RUNNING` is a **documentation state** ("no report file on disk"), not proof a session is alive; "reserved / no evidence" slots are not genuinely assigned work. The filesystem cannot distinguish a live worker from a recycled-but-unlanded slot, and no session-completion ledger was available. So the honest answer is: **38 slots are marked RUNNING; "still active" cannot be confirmed as a live-session count beyond the ≥28 report-evidenced producers in the final window.** No gate run, no capture and no parity claim by this worker.

## 4. One-line honest statement (presence vs correctness vs parity)

**Presence is high and donor decode integrity is strong, but correctness is unproven and donor parity is UNVERIFIED — no gate was run, no fresh 240²/320² capture exists, no donor GPU A/B frame exists, and the port remains a legacy-default scaffold of `PORT APPROXIMATION`, so `RESULT IS NOT GOOD`.**

*End of V97 report. Exactly one repo file written (`docs/terrain_swarm_2026-11-26/reports/V97_final_counts.md`). No source, shader, config, asset, test, result JSON, git, Godot, runner, capture or donor change; no gate result and no donor-parity claim.*
