---
title: COORD SWARM 2026-11-25 — 3D variant: selection rectangle + terrain fidelity
area: coordination / variant3d
owner: COORD (primary agent)
updated: 2026-11-25
status: living
charter: skirmish-first, donor-is-truth
parent: docs/coord_swarm_2026-11-24/
---

# 🐝 Coord swarm — 2026-11-25 (3D variant day)

## 0. Owner directive (verbatim intent, 2026-11-25)

1. New folder under `docs/` for today; track **mods in markdown**, progress, and so on.
2. **Read carefully all previous docs.** Analyse the **donor** deeply for *every single aspect*
   needed. Use swarm logic. Do **deeper analysis even 3 times if necessary**, especially on
   the donor.
3. **Keep features and tests small** so swarm size can be increased.
4. Look at what **logical features were ported from donor into the 2D variant** — even if not
   perfect, they help understand what is missing. **Secondary helper only; primary is always
   the donor.**
5. **Keep improving documentation until the result is really really good.**
6. Concrete known faults to fix today:
   - **3D selection rectangle does not work** (drag-box selecting units).
   - **3D terrain quality is bad even without trees.** Need isolated tests:
     terrain only → terrain+trees → terrain+shore → terrain+mines → all needed combos.
     **Only test the final result at the end.** Tests must run on the **smallest possible map**.
7. Deep analysis of what exists / what is missing / how to fix existing problems, and
   **resolve all of it with subagents**.

## 1. Governing rules (inherited, binding at every depth)

- **Donor is the source of truth**: `C:\Games\Cossacks 3\data` (read-only; Python `bytes` +
  latin-1, never run/copy binaries). Every 3D constant must cite donor `path:line` or an
  evidence id. If unreadable → `UNVERIFIED`, never invented.
- **2D port is a SECONDARY helper**: use it only to understand *logical* intent of a ported
  feature. If 2D and donor disagree, donor wins and 2D is logged as a divergence.
- **Piece before whole** (`SWARM_OPS.md` §7.6): each worker tests its own smallest piece on the
  smallest map BEFORE any combo/full test. Final whole result tested once, at the end.
- **One Godot at a time**, via `python variant3d\tools\godot_runner.py run --id ...`. Never
  direct `godot`. Host is Windows: `python` (3.14), not `python3`. Blender at
  `"C:\Program Files\Blender Foundation\Blender 5.2\blender.exe"`.
- **Disjoint outputs**: each micro-worker owns exactly its own report file (analysis phase).
  Shared code (`main.gd`, `input_controller.gd`, `world3d*.gd`, `hud.gd`, shaders, tests) is
  **read-only** until an integration ticket grants one builder exclusive ownership.
- **Backups before edits**: `inbox\backup\<name>.bak-<TICKET>`.
- **Evidence labels**: `observed` / `derived` / `inferred` in every report. Separate facts
  from guesses. Re-verify important donor findings with an independent agent (2nd/3rd pass).
- **2D shipping gates stay green** — `app/**` untouched this session.

## 2. Folder layout

```
docs/coord_swarm_2026-11-25/
├── CHARTER.md              ← this file (rules, goals, ownership)
├── PROGRESS.md             ← living coordinator log (batches, gates, decisions)
├── SWARM_BOARD.md          ← micro-ticket table: id, scope, owner, state, evidence
├── GAPS.md                 ← consolidated what-exists / what-is-missing / how-to-fix
├── TEST_MATRIX.md          ← piece → combo → small-map → final test ladder
├── PLAN_IMPLEMENTATION.md  ← atomic disjoint implementation tickets + gating
├── decomp/                 ← deep donor decompilation DOCUMENTATION lane
│   ├── README.md           ← lane charter
│   ├── EVIDENCE_INDEX.md   ← evidence id / path:offset index
│   └── DEC_0x_*.md         ← one decomp record per donor aspect
└── reports/<TICKET>.md     ← one cold-readable report per micro-worker
```

## 3. Micro-task rule

A ticket is one of: one donor aspect, one variant3d code path, one 2D logical analogue,
one test atom, one doc synthesis. If a worker finds its task compound, it splits and reports;
it does not grow the diff. Prefer many tiny workers over few big ones.

## 4. Gates for today

- **Analysis gate:** every report cites donor `path:line` / evidence id or is explicitly
  `UNVERIFIED`; important donor claims re-verified by a second (and where needed third) agent.
- **Piece gate:** smallest-map isolated render of just terrain (no trees/shore/mines), with
  screenshot + measured criteria + donor visual reference.
- **Combo gate:** piece + trees, piece + shore, piece + mines, then pair/triple combos, each
  on the same smallest map, each re-rendered and measured.
- **Fix gate:** selection rectangle drag-box selects the expected units on the smallest map;
  no regression to click-pick, orders or minimap.
- **Final gate (end of day only):** variant selftest 29/29 + uitest 17/17 + clean; 2D gates
  still green; owner visual review.

## 5. Scope guard

Singleplayer skirmish only (D-12). Missions / campaigns / DLC / network stay deferred.
