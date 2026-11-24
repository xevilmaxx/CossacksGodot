# Coordinator session charter — 2026-11-24

**Role:** primary agent = coordinator (`SWARM_OPS.md` §7.1).
**Owner directive this session:** keep extracting skirmish single-player features from
the donor, compare with what is missing; use swarm directives; split work into many
mini/micro subagents (more agents is better); improve performance everywhere possible;
improve the project overall; document progress in a dedicated docs subfolder.

**Owner directive (follow-up, same session):** split big tests into smaller, logically
meaningful test sets that are relatively fast to execute. Opened as lane T (T1–T3)
below: the 29-step monolithic `app/selftest.json` must become several fast, coherent
subsets without weakening any assertion or breaking the 29/29 gate semantics.

## Scope (inherited, `SWARM_OPS.md` §0 / D-12)

- **In scope:** random skirmish, AI opponents/teams, skirmish options, full donor
  gameplay roster/mechanics, maximum graphics fidelity, mass-army performance.
- **Deferred:** missions, campaigns, `.aix`, DLC mission maps, cutscenes, network.

## Non-negotiable gates (binding on every depth, `SWARM_OPS.md` §3 + §5b-QUALITY)

1. No direct `godot` — only `python app\tools\godot_runner.py run --id <id>-<purpose> --timeout <s> -- …`.
2. Disjoint file ownership; one file belongs to exactly one active ticket.
3. Backup before edit: `inbox\backup\<name>.bak-<ticket-id>`.
4. Green before review: `app/selftest.json` 29/29 + `app/uitest.json` 17/17.
5. No redistribution of donor assets (`C:\Games\Cossacks 3`, private use only).
6. Minimal diffs, no renames of called symbols.
7. Quality-first: evidence before edits; `observed`/`derived`/`inferred` labels;
   `UNVERIFIED` when not proven; visual A/B before metrics; metrics never override visual review.

## This session's docs subfolder

`docs/coord_swarm_2026-11-24/` — all coordinator + swarm reports for this session:

| Path | Contents |
|---|---|
| `CHARTER.md` | This file — charter, gates, swarm tree, progress |
| `reports/R##_*.md` | Recon: one donor feature family extracted vs port |
| `reports/P##_*.md` | Recon: performance opportunity in one file/area |
| `GAPS.md` | Aggregated donor-vs-port gap matrix (recon outputs consolidated) |
| `IMPROVEMENTS.md` | Landed improvements with evidence + gate results |
| `PROGRESS.md` | Session log (what ran, what concluded, what shipped) |

## Swarm tree (wave 1 — recon, all read-only, no runner cost)

```
Coordinator (this session)
├── R1..R12  Donor feature extraction (one family each)  → reports/R##_*.md
└── P1..P4   Performance recon (one file/area each)      → reports/P##_*.md
```

Recon workers own exactly ONE output report file. They do NOT edit game code,
do NOT run Godot, do NOT touch `SWARM_BOARD.md` / `SWARM_OPS.md` / other lanes' files.
They read donor at `C:\Games\Cossacks 3` read-only (Python `open(...,'rb')` +
`latin-1`, never run/copy donor binaries) and port code under `app/scripts/`.

Wave 2 (implementation) opens after recon lands: micro-builders with disjoint
file ownership, backups, runner gates, one report each under `reports/I##_*.md`.

### Lane T — split big tests into small, logically meaningful, fast sets (owner directive)

```
Coordinator
└── T1..T3  test-split recon (read-only)  → reports/T0*_*.md
```

- T1: taxonomy of the 29 selftest steps → proposed coherent fast subsets.
- T2: mechanism — how `--self-test` is loaded/filtered; minimal-diff subset support;
  overlap with existing `app/tests/t_*.gd` small-test framework.
- T3: per-step cost/dependency analysis → target subset sizes for fast execution.

## Progress

- 2026-11-24: docs read (SWARM_OPS, BOARD, BACKLOG, RESUME, STATUS_*, PERFORMANCE_SWARM,
  MICRO, DONOR_OPTIONS_GAPS); donor data tree confirmed; this charter created.
- Wave 1 recon swarm: 16 agents launched (R1–R12 donor features, P1–P4 performance).
  Session ids: R1 ses_df3754085ffeAYzfuNWgWrR7JO, R2 ses_df3754082ffeToaY1p8P1MJ3G3,
  R3 ses_df375407effev8I6okTXauVEP8, R4 ses_df3754070ffe1xj6IULPk183zt,
  R5 ses_df375406cffeP4AU2Lm157jjPP, R6 ses_df374fac4ffeQxixoV35m8hLnL,
  R7 ses_df374fac3ffewAfeIKThB7br4O, R8 ses_df374fac0ffe2AgcIJbENbvf55,
  R9 ses_df374fab0ffeN9QTbv969vau8W, R10 ses_df374faacffetdk3t45n1kD546,
  R11 ses_df374a50affep3kRdY3F4L7z3x, R12 ses_df374a509ffeDLRnw12zdOOchi,
  P1 ses_df374a4faffeBp8qHWDb8Rvbyv, P2 ses_df374a4b4ffeHf2P2l8dUiESkj,
  P3 ses_df374a4aeffeCjWh16PoiKOPXR, P4 ses_df374a496ffevsI4VeX2xZAnEc,
  T1 ses_df372b218ffe3Ifg0JE4cDJpD6, T2 ses_df372b216ffetkLKCu3ny1X3aJ,
  T3 ses_df372b215ffegOV3XJk0aDcQhJ.
- Baseline truth check (read-only + fresh runner): on-disk `app/selftest.json` shows
  `passed:false` with 2 failures (`peasant_capture`, `resow`); `app/uitest.json`
  `passed:true`; clean gate DIRTY from 4 unacknowledged historical timeouts
  (#1132/#1135/#1184/#1205). Fresh selftest job `coord-baseline-selftest` submitted.
- Lane T (test splitting): launching T1–T3 recon now.
- Wave 2 implementation: pending recon + lane T.

## Periodic supervision (owner request 2026-11-24)

Owner asked to check subagents periodically. Automation
`aut_20c9e4cc0001a6MHYIQ9OSk0sQ` ("swarm-supervision-2026-11-24") ran every
5 minutes: checked report files vs expected ids, pinged silent/running agents,
read runner status + clean gate, appended one-line checks to `PROGRESS.md`.
**Paused 2026-11-24 after all 26 agents closed and the final gate went green.**
Manual supervision also happens on every child notification (`SWARM_OPS.md` §7.3).
R8/R11 were pinged 2026-11-24 because their reports landed but their sessions
stayed open on trailing background donor scans.
