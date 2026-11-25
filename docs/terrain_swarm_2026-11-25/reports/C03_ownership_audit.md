---
id: C03
ticket: "Ownership / backup discipline audit (QA, READ-ONLY)"
wave: C — verification tooling / QA
owner: C03 (this session — ses_ded2296eaffdR0CALIDWqFurDK)
charter: docs/terrain_swarm_2026-11-25/CHARTER.md
board: docs/terrain_swarm_2026-11-25/SWARM_BOARD.md
created: 2026-11-25
audit_cutoff: 2026-11-25T14:23:29+01:00
status: MOMENT-IN-TIME — swarm still dispatching; re-check required at integration
labels: [observed, derived, inferred, UNVERIFIED]
---

# C03 — Ownership & backup audit (moment-in-time)

## 0. Scope and method (OBSERVED)

Read-only audit only. No source file, backup, report other than this one, or runner job was
created or modified by this agent. Evidence gathered from:

- `git status --porcelain=v1 -uall`
- `git diff --stat` / `git diff --cached --stat`
- `git diff --stat -- <the six B-owner files>`
- filesystem listing of `inbox/backup/`, `docs/terrain_swarm_2026-11-25/`, and its `reports/`
- `SWARM_BOARD.md` (COORD's authoritative ownership map, read at 14:22:41+01:00)

**Important:** the working tree changed repeatedly *during* this audit. Observed status counts
went 2 → 5 → 9 entries between 14:22 and 14:23. All findings below are pinned to the single
cut-off timestamp in the front matter; later landings are explicitly out of scope of this
snapshot and are covered by the re-check command in §7.

## 1. Ownership map under audit (OBSERVED — from SWARM_BOARD.md)

| Ticket | Exclusive file | Session id |
|---|---|---|
| B01 | `variant3d/shaders/terrain_tileindex.gdshader` | ses_ded229759ffelRBI3RY5eFdGiV |
| B02 | `variant3d/scripts/tile_atlas_loader.gd` **+ atlas `.import`** | ses_ded229759ffdicFrqcKHP5Y8Os |
| B03 | `variant3d/scripts/game.gd` | ses_ded229743ffeBCaHnUqsqjQ7ac |
| B04 | `variant3d/scripts/world3d_terrain.gd` | ses_ded229726ffdXTlhqimEoovMth |
| B05 | `variant3d/scripts/input_controller.gd` | ses_ded2296edffd3Uv4Tqd5PlynJj |
| B06 | `variant3d/scripts/world3d_entities.gd` | ses_ded2296ecffed36vvKKPj76aD1 |

Board declares 38 subagents dispatched (A01–A12, B01–B06, C01–C04, D01–D06, E01–E05, F01–F05).

## 2. Six B-owner files — working-tree state at cut-off (OBSERVED)

`git diff --stat` restricted to the six files returned **empty**. `git diff --cached --stat`
was also empty. Therefore:

| Ticket | File | Modified? | `git diff` | Verdict |
|---|---|---|---|---|
| B01 | `terrain_tileindex.gdshader` | no | empty | untouched — no edit landed yet |
| B02 | `tile_atlas_loader.gd` | no | empty | untouched — no edit landed yet |
| B03 | `game.gd` | no | empty | untouched — no edit landed yet |
| B04 | `world3d_terrain.gd` | no | empty | untouched — no edit landed yet |
| B05 | `input_controller.gd` | no | empty | untouched — no edit landed yet |
| B06 | `world3d_entities.gd` | no | empty | untouched — no edit landed yet |

**Derived:** at this moment there is no landed implementation from any B owner, so there is
no source-level conflict and no opportunity for one agent to have edited another's file.
This is expected wave sequencing, not a defect (INFERRED).

Last commit touching any of the six files is `8e9de1bf` ("step", 2026-11-25T14:11:55+01:00),
which predates charter creation (14:18:58+01:00) — i.e. no swarm-era commit has landed to these
files (OBSERVED/INFERRED).

## 3. Backup verification — `inbox/backup/*.bak-B0X` (OBSERVED)

Charter rule: "Backups before any edit: `inbox/backup/<file>.bak-<TICKET>`." Expected mapping
and cut-off state:

| Ticket | Expected backup | Present at cut-off? | Note |
|---|---|---|---|
| B01 | `terrain_tileindex.gdshader.bak-B01` | **YES** (`??` untracked) | backup taken, but the shader itself is still untouched — correct backup-first order |
| B02 | `tile_atlas_loader.gd.bak-B02` | NO | no B02 edit landed either, so no violation yet |
| B02 | (atlas `.import`.bak-B02, if edited) | NO | B02 also owns an atlas `.import`; none present |
| B03 | `game.gd.bak-B03` | NO | no B03 edit landed either |
| B04 | `world3d_terrain.gd.bak-B04` | NO | no B04 edit landed either |
| B05 | `input_controller.gd.bak-B05` | NO | no B05 edit landed either |
| B06 | `world3d_entities.gd.bak-B06` | NO | no B06 edit landed either |

A filesystem-wide scan for `*.bak-B0?` returned exactly one file:
`terrain_tileindex.gdshader.bak-B01`. Broader `*B0?*` matched only unrelated historical
backups (`data.gd.bak-V750`, `main.gd.bak-W52`).

**UNVERIFIED:** that the single B01 backup is byte-identical to the pre-edit shader — no
edit has landed to compare against. Re-check after B01 edits.

Historical backups for these six files from *prior, non-swarm* tickets exist (e.g.
`terrain_tileindex.gdshader.bak-TRNSHADER`, `.bak-DALPHA02`, `.bak-MASKALPHAFIX`; `tile_atlas_loader.gd.bak-SP05`;
`game.gd.bak-TRNDATA`; `world3d_terrain.gd.bak-TRNGEOM`; `input_controller.gd.bak-SEL01`;
`world3d_entities.gd.bak-BUILDSTAGES01`). These are out of scope for C03 and are **not**
swarm-ticket backups.

**Derived / flagged:** B02–B06 missing `.bak-B0X` is *not* a violation at cut-off (charter
requires the backup before an edit, and no edits exist). It becomes a hard violation the
moment any of those files changes without its matching backup. See §6 and §7.

## 4. Cross-touch check — did any agent touch another's file? (OBSERVED)

Complete `git status --porcelain=v1 -uall` at cut-off:

```
 M variant3d/selftest.json
?? docs/terrain_swarm_2026-11-25/CHARTER.md
?? docs/terrain_swarm_2026-11-25/SWARM_BOARD.md
?? docs/terrain_swarm_2026-11-25/reports/A08_donor_truth_local.md
?? docs/terrain_swarm_2026-11-25/reports/A10_regression_constraints.md
?? docs/terrain_swarm_2026-11-25/reports/A12_config_knobs.md
?? docs/terrain_swarm_2026-11-25/reports/F04_quality_reviews.md
?? inbox/backup/terrain_tileindex.gdshader.bak-B01
?? variant3d/tools/terrain_ab_metric.py
```

Attribution against the board:

| Working-tree change | Owner per board | In scope? |
|---|---|---|
| `CHARTER.md`, `SWARM_BOARD.md` | COORD | YES |
| `reports/A08_*`, `A10_*`, `A12_*` | A08, A10, A12 (own report) | YES |
| `reports/F04_*` | F04 (own report) | YES |
| `inbox/backup/terrain_tileindex.gdshader.bak-B01` | B01 (own file's backup) | YES |
| `variant3d/tools/terrain_ab_metric.py` | C01 (exclusive tool) | YES |
| `variant3d/selftest.json` (M) | **no swarm owner** | see below |

**Derived:** every swarm-era change observed maps to its own ticket's exclusive output. No
agent wrote another agent's report, tool, source file, or backup. **No cross-touch detected.**

`selftest.json` detail (OBSERVED): modified content is regenerated test output only —
`gold`, `wood`, `shots_fired`, `sim_seconds`, per-step `wall_ms`, deposit distances, entity
counts; `passed: true` throughout. Its last write time is **14:12:53+01:00**, i.e. *before*
`CHARTER.md` creation at **14:18:58+01:00**. Therefore this is a **pre-swarm, likely generated
test artifact, not an out-of-scope swarm edit** (INFERRED, high confidence). It is flagged here
only so COORD does not mistake it for a swarm regression; no action required by this audit.

## 5. Reports directory — duplicate / missing tickets (OBSERVED)

Directory `docs/terrain_swarm_2026-11-25/reports/` exists at cut-off and contains exactly four
files:

- `A08_donor_truth_local.md`
- `A10_regression_constraints.md`
- `A12_config_knobs.md`
- `F04_quality_reviews.md`

**Duplicates: none.** No ticket id appears more than once; no filename collisions or
near-duplicate aliases observed.

Missing at cut-off (30 reports + C03 in progress):

| Wave | Expected | Present | Missing |
|---|---|---|---|
| A01–A12 | 12 | A08, A10, A12 | A01, A02, A03, A04, A05, A06, A07, A09, A11 |
| B01–B06 | 6 | — | B01–B06 (see caveat below) |
| C01–C04 | 4 | — | C01, C02, C03 (this report, not yet written at cut-off), C04 |
| D01–D06 | 6 | — | D01, D02, D03, D04, D05, D06 |
| E01–E05 | 5 | — | E01, E02, E03, E04, E05 |
| F01–F05 | 5 | F04 | F01, F02, F03, F05 |

Caveat (OBSERVED/INFERRED): per `SWARM_BOARD.md`, B owners deliver exclusive source edits,
**not** reports, so "missing B01–B06 report" is not a defect. What matters is that their six
source files are also still untouched (§2). C01 has landed its tool but no report yet; C01's
report is not C03's property to create.

**UNVERIFIED:** content correctness of the four landed reports — C03 audits ownership only,
not findings. No report was opened for judgment.

## 6. Flags at cut-off

| # | Severity | Finding |
|---|---|---|
| F1 | INFO | No B implementation has landed; all six owned source files are clean. Nothing to conflict yet. |
| F2 | WATCH | Only B01's backup exists; B02–B06 have no `.bak-B0X`. Becomes a violation at first edit without backup. |
| F3 | WATCH | 34 of 38 expected ticket outputs absent (4 reports landed). Swarm clearly still mid-flight. |
| F4 | INFO | `variant3d/selftest.json` modified but predates charter (14:12:53 vs 14:18:58) and is generated test output — pre-existing, not a swarm out-of-scope edit. |
| F5 | NONE | No out-of-scope swarm edit, no duplicate report, no conflicting change observed at cut-off. |

## 7. Re-check command for COORD at integration (OBSERVED — ready to paste in PowerShell)

Run this from the repo root when all agents have reported or timed out; it reproduces every
check in this report in one shot:

```
git status --porcelain=v1 -uall; git diff --stat -- variant3d/shaders/terrain_tileindex.gdshader variant3d/scripts/tile_atlas_loader.gd variant3d/scripts/game.gd variant3d/scripts/world3d_terrain.gd variant3d/scripts/input_controller.gd variant3d/scripts/world3d_entities.gd; Get-ChildItem inbox/backup -Filter '*.bak-B0?' | Select-Object -ExpandProperty Name | Sort-Object; Get-ChildItem docs/terrain_swarm_2026-11-25/reports -File | Select-Object -ExpandProperty Name | Sort-Object
```

Integration pass criteria derived from this audit:

1. Each of the six files that is modified must have its matching `*.bak-B0X` present; a
   modified file with no matching backup is a hard violation.
2. No ticket's output may appear under another ticket's filename; any duplicate report name
   or any agent editing a file outside its exclusive list is a violation.
3. All 38 ticket outputs should be accounted for (38 reports, or explicit timeouts; B owners
   accounted for by source edits + backups instead of reports).
4. Confirm each landed B edit stays within its single exclusive file (B02 additionally owns
   one atlas `.import`).
5. Re-run static parse/load on the six files before any Godot gate, per COORD checklist.

## 8. Limitations (UNVERIFIED)

- Snapshot is moment-in-time; agents were still dispatching and writing throughout. Later
  landings are not covered.
- No runner jobs were queried or submitted (C03 is read-only); runner state is out of scope.
- Backup contents were listed, not diffed; backup fidelity is unverified.
- Report contents were not evaluated for correctness, citations, or PORT APPROX labelling.

*End of C03 report.*
