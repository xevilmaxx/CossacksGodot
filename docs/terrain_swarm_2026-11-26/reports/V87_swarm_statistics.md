---
id: V87-SWARM-STATISTICS-2026-11-26
title: "FINAL swarm statistics — launches, reports, implementation files, derived assets, temp corpora, concurrency, wave coverage"
agent: "V87 (read-only final-statistics subagent, 30-agent DONOR-FIRST terrain swarm 2026-11-26; reporting to COORD)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_EDIT__NO_GODOT_JOB__NO_GATE_RUN__NO_CAPTURE__NO_PARITY_CLAIM
owner_file: docs/terrain_swarm_2026-11-26/reports/V87_swarm_statistics.md
files_created: [docs/terrain_swarm_2026-11-26/reports/V87_swarm_statistics.md]
files_edited: []
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_claim: false
parity_status: UNVERIFIED
frozen_at: "2026-11-26 10:19:46 local (final dual-pass snapshot; all counts are point-in-time)"
snapshot_note: "Filesystem-authoritative. The report set and the derived-asset tree both grew during this read (reports 105 → 117; assets 780 → 5,255 files) and SWARM_BOARD.md itself was edited from 125 → 151 rows by a concurrent board owner. Every number below is from the frozen final read or explicitly labelled as an earlier pass. Two independent count methods were used throughout. No source, shader, asset, config, test, result JSON, git, Godot, runner or donor state was touched; no gate run, no capture, no donor GPU A/B frame."
---

# V87 — FINAL SWARM STATISTICS (2026-11-26)

> **Honest frame:** every figure here is **file presence / filesystem evidence only**. A landed report, a present implementation file or a generated asset is **not** correctness, not a gate PASS, not spec READY and not donor parity. No parity claim is made anywhere in this report.

## 0. Verification method (two independent commands per headline count)

| Count | Method A | Method B | Result |
|---|---|---|---|
| Report files | `Get-ChildItem -File -Recurse \| Measure-Object).Count` | `foreach ($f in $files) { $n++ }` accumulator | **117 = 117** at 10:19:46 |
| Report IDs | regex `^([A-Z]+\d+)_` → `Sort-Object -Unique` | `Select-Object -Unique` on the same extracted array | **117 distinct IDs = 117 files** (one report per worker, as the charter requires) |
| Board worker IDs | regex `^\|\s*([DFPAXVI]\d{2})\s*\|\s*(Binary\|Data\|Port\|Design\|Verify\|Impl)\s*\|` | `Select-Object -Unique` + per-prefix recount | **151 rows = 151 distinct IDs** |
| Implementation files | explicit `Test-Path` on 13 canonical owner paths | `Get-ChildItem variant3d/tools/*.py` filter + board `PRESENT` inventory | **13 core files**, all present |
| Derived assets | `Measure-Object -Sum Length` over recursive listing | manual `foreach { $n++; $bytes += $f.Length }` | **5,255 files / 302,411,732 B** at 10:19:46 (identical in both passes at that instant) |
| Temp corpora | recursive `Get-ChildItem` + `Measure-Object` on the three temp folders | X01 §4.1 and X02 §4 byte totals summed by hand | **41,310 files / 614,758,996 B** (exact agreement) |

**Discarded pass (multi-pass honesty):** a first board-status parse reused `$Matches[1]` after a second regex had overwritten it, producing 38 empty RUNNING ids and a false "0 RUNNING without a report". The parse was redone capturing the id before the status match; the corrected result is §4. A `glob` listing and two `Get-ChildItem` listings were also cross-read; the set grew between them, so the final frozen read is the authority.

## 1. Day's output — headline numbers

| Metric | Count | Notes |
|---|---:|---|
| **Board-authoritative workers launched** | **151 distinct IDs** | D01–D09 = 9; F01–F10 = 10; P01–P06 = 6; A01–A06 = 6; X = 41; V = 63; I01–I16 = 16. The charter/board originally chartered 125 rows (D9+F10+P6+A6+X33+V45+I16); the board grew to 151 as late workers were reconciled. |
| **Union of board IDs + report IDs** | **158 distinct IDs** | 7 report ids landed with no board row at the frozen read (e.g. V55/X44/X57 and other very late ids); these are real launched workers, not invented owners. Additional N-ticket workers (N14/N16/N17/N18/N19) and board/index workers (V45/V50/V74) appear in on-disk documentation but are **not** counted as separate board launches. |
| **Reports landed (files)** | **117** | `reports/**`; 117 distinct worker ids ⇒ one report per worker. Earlier snapshots: 103 (V74 board), 102 (V77 index), 105/107/108/114/115/116 during this read. |
| **Spec files** | **17** | §00–§14 section files (15) + `README.md` + `terrain_qa_spec.json`. All sections present; none marked READY by the board. |
| **Implementation files created (core)** | **13** | 6 tools (4 `decode_*.py`, `build_terrain_new_atlas.py`, `terrain_qa_harness.py`), 5 GDScript (`terrain_donor_data/gen/mesh/props/world.gd`), 1 shader (`terrain_donor_shader.gdshader`), 1 test (`t_terrain_donor.gd`). |
| **Additional implementation artefacts** | **4 + 1 spec artifact** | `main.gd` + `world3d.gd` modified in place by the I11 two-file seam (not new files); 2 backups `*.bak-COORD-I11` created; `spec/terrain_qa_spec.json` (N17). |
| **Absent implementation files** | **4** | `terrain_donor_tiles.gd` (I07 second file), `validate_terrain_new.py` (N7), `inbox/qa/terrain_qa_report.json` (N18), `inbox/qa/captures/` (N19). `inbox/qa/**` holds PENDING markers only. |
| **Derived assets generated** | **5,255 files / 302,411,732 B (~288.6 MiB)** | `variant3d/assets/terrain_new/**`, all derived, untracked, **unvalidated**. At V77 this tree held only 780 `.json` files / ~242,316,351 B; it grew during this read (mostly the `masks/` tier) — every asset count is point-in-time. |
| **Temp corpora outside repo** | **41,310 files / 614,758,996 B (~586 MiB)** | X01 + X02 corpus trees plus X02's index folder; all under `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\`. Read-only verified present at this read. No donor binary or derived corpus is in the repo or committed. |

### 1.1 Derived-asset tiers (frozen 10:19:46)

| Tier | Files | Bytes |
|---|---:|---:|
| `patterns/` | 777 | 238,526,989 |
| `masks/` | 4,467 | 52,757,581 |
| `atlas/` | 8 | 7,551,760 |
| `cfg/` | 3 | 3,575,402 |
| **Total** | **5,255** | **302,411,732** |

`atlas/` is **present** at this read (8 files), although the board and V77 index still record it as absent — those documents are stale on this point. No asset byte check, decoder replay or gate run was performed here.

### 1.2 Temp corpora outside the repo (from X01/X02 reports, verified on disk)

| Folder | Files | Bytes | Source |
|---|---:|---:|---|
| `cossacks3_decomp/` | 18,919 (18,918 `.c` + 1 state file) | 298,135,470 | X01 §4.1 — 18,918/18,918 discovered functions, 20 write calls; 4,265 (22.54%) structured:false |
| `editor_decomp/` | 22,385 (22,384 `.c` + 1 state file) | 315,391,988 | X02 §4 — 22,384/22,384 discovered functions, 3 write calls; 12,254 (54.7%) carry garble markers |
| `editor_decomp_idx/` | 6 | 1,231,538 | X02 §2 — `matches_all.txt`, `garble_counts.txt`, `api_callers2.txt`, `api_roles.txt` and sweep scripts |
| **Total** | **41,310** | **614,758,996** | Private-use donor derivative, outside repo, never executed or committed |

X01's own cross-check limits the meaning of "100%": only **11 of 34** D01 terrain anchors occur in the discovered set (23 absent), so corpus completeness is relative to discovered functions only.

## 2. Peak concurrent active count — estimate

Three independent indicators, none of which is a live session ledger:

1. **Board design floor:** `SWARM_BOARD.md:4-5` — "At least 30 workers are kept active; finished slots are immediately recycled into verification tasks." ⇒ designed concurrency **≥ 30**.
2. **Board RUNNING markers:** **38 rows** at the frozen read (4 X, 19 V, 15 I). These are "no report file on disk" slots, not proof of running sessions.
3. **Observed delivery burst:** at 10:16:40, **28 distinct worker ids** had landed a report within the preceding 15 minutes (V83, X56, V53, V76, V63, V60, V66, V64, X51, V81, V65, V59, X31, V62, V61, X54, V58, V49, X36, V47, V56, X49, X29, V57, X33, X24, V38, X25). One report per worker ⇒ at least 28 workers were actively delivering in that window.

**Honest estimate: peak concurrency ≈ 30–38, most plausibly ~30–35.** The board's ≥30 policy is corroborated by ≥28 distinct producers in a 15-minute window; 38 is the upper bound from RUNNING markers. No session-completion ledger was available, so this is an inference `[D]/[I]`, not an observation of simultaneous Godot/Craft Anything sessions.

## 3. Coverage by wave

| Wave | Board ids | Landed report ids at frozen read | Coverage / state |
|---|---:|---:|---|
| **Donor binary** (D + binary X: X01/X02/X08/X12/X17/X21/X26/X31, X54-adjacent) | D = 9; X wave total 41 | D = 9/9; X data at 10:18 = 37 distinct landed ids | Full D coverage; X01/X02 bulk corpora complete over *discovered* functions only; D01 anchors and garbled bands remain `[U]`. |
| **Donor data formats** (F + data X) | F = 10 | F = 10/10 | Full F coverage: `.pattern` 710/710 size law, `pattern.lib` 680 sections, 4,466 masks, 7 cfg files, 124 tile ids, DScript corpus. X23/X34/X49 independently re-verified key tables. |
| **Port baseline audit** (P) | 6 | 6/6 | Full: pipeline, asset inventory, gates/capture, decoder reuse, 2D reuse, prior-wave distillation. |
| **Design / spec** (A + spec/§00–§14) | A = 6 | A = 6/6; 17 spec files | Full A coverage; §00–§14 all exist but spec/README still PENDING; V17/V26/V34/V36 stale-text items and V47's OPEN list remain. |
| **Verification** (V) | 63 | 47 distinct report ids at 10:18; 38 board rows still RUNNING | Broad but unfinished: V47 canonical register (33 RESOLVED / 4 PRESERVED / 2 DECISION / 4 UNVERIFIED + 19 OPEN), V15/V21/V57 parity+gate framing, V58/V59/V61/V62/V64/V65/V81 final audits/packets. No gate PASS produced. |
| **Implementation** (I + N artefacts) | 16 | 13 core files + I16 report; I01–I15 have **no** reports | Files present, unvalidated; I11 seam default `"legacy"`; `terrain_donor_tiles.gd` absent; I14/I15 have no ticket definition on disk. |

**Totals check:** 9 + 10 + 6 + 6 + 41 + 63 + 16 = **151** board ids, matching the board-parse result.

## 4. Workers still active at this read

**38 board slots are marked `RUNNING` and every one still has no report file at the frozen read** (corrected parse, §0):

- **I01–I15 (15):** implementation tickets. I01–I13 owner files are on disk but unvalidated; I14/I15 have **no ticket definition** found on disk (no owner invented). Their board status is `RUNNING` by the report-file rule, not by observed execution.
- **V02/V10/V14/V18/V19/V22–V25/V29–V32/V35/V39–V41/V43/V45 (19):** mostly "Reserved (no evidence)" or "no report" slots at the V74/V87 board snapshot; V43 has live re-verify notes in `spec/12`–`spec/14`, V45 has the board-refresh note. No report content was inferred for the others.
- **X04/X10/X14/X32 (4):** extra donor text, extra donor schema, evidence index, reserved slot. X14's `spec/00_EVIDENCE_INDEX.md` is present but there is no `reports/X14*.md`.

**Separately, ≥28 distinct workers demonstrably delivered reports in the final 15-minute window** (list in §2). Their in-flight work at this read: final forbidden-pattern scan (V83), plateau-generator DScript decode (X56), CLI/runner reconciliation (V53), gate pre-flight (V76), go/no-go packet (V63), I04 audit (V60), asset-gap final (V66), ownership/collision audit (V64), closing `[U]` items with donor text + Deep Ghidra (X51), owner decision packet (V81), patch verification (V65), and implementation audits (V58/V59/V61/V62). These are report-evidenced activities, not observed live sessions.

**Caveat:** `RUNNING` is a **documentation state** ("no report file"), not proof that a session is alive, and "reserved / no evidence" slots are not genuinely assigned work. The filesystem cannot distinguish a live worker from a recycled-but-unlanded slot; no completion-message ledger was available.

## 5. One-line honest statement

**Presence is high and donor decode integrity is strong, but correctness is unproven and donor parity is UNVERIFIED — no gate was run, no fresh 240²/320² capture exists, no donor GPU A/B frame exists, and the port remains a legacy-default scaffold of `PORT APPROXIMATION`, so `RESULT IS NOT GOOD`.**

*End of V87 report. Exactly one repo file written (`docs/terrain_swarm_2026-11-26/reports/V87_swarm_statistics.md`). No source, shader, config, asset, test, result JSON, git, Godot, runner, capture or donor change; no gate result and no donor-parity claim.*
