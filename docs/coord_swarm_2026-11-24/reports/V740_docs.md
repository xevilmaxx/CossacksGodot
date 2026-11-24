---
owner: V7-40
role: docs atom — cold-readable variant3d docs (Wave 7 phase 2)
date: 2026-11-24
status: DONE
owns: "docs/variant3d/README.md + docs/variant3d/STATUS_WAVE7_PHASE2.md + this report ONLY"
reads: "charter, V7-3 atomic contract, V70/V71/V72/V732/V738 reports, G31/G32 reports, variant3d/README.md (read-only), STATUS_TEMPLATE.md, PROGRESS.md, FINAL_GATE.md, launch scripts, filesystem snapshot"
godot_runs: none
code_edits: none
---

# V7-40 — Cold-readable docs for the 3D variant

## 1. Delivered (exactly three new files, no other edits)

| Path | Purpose |
|---|---|
| `docs/variant3d/README.md` | Cold-readable entry point: what `variant3d/` is (separate project, own runner, hardlinked assets, no 2D bake), donor-leverage + D-12 singleplayer-skirmish rule, launch via `launch_variant3d.bat`, runner/test commands, phase-2 atomic task map with file owners + statuses as of read, and links to every wave-7 report. |
| `docs/variant3d/STATUS_WAVE7_PHASE2.md` | `docs/STATUS_TEMPLATE.md`-style living doc: TL;DR + Mermaid, at-a-glance evidence table, DONE vs LEFT per atomic task, owners, gates (variant 29/29 baseline GREEN; final variant gate PENDING), evidence index, "how to resume", open questions. |
| `docs/coord_swarm_2026-11-24/reports/V740_docs.md` | This report. |

No Godot process was launched; no code, config, asset, manifest or existing
document was modified. `variant3d/README.md` (V7-0's scaffold README) was read
only, as instructed.

## 2. Sources read (all cited inside the two docs)

- `docs/coord_swarm_2026-11-24/WAVE7_3D_VARIANT_CHARTER.md` — architecture,
  GOVERNING RULE (`:29-38`), NO 2D BAKE (`:40-57`), phase owners (`:66-79`), gates.
- `docs/coord_swarm_2026-11-24/V73_ATOMIC_CONTRACT.md` — one-file-per-agent
  module APIs (`:8-17`), integration seams (`:19-24`), test atoms (`:26-30`),
  docs atoms (`:32-34`), runner (`:36-38`).
- `docs/coord_swarm_2026-11-24/reports/V70_scaffold.md` — copy/link ledger §1,
  runner proof §2, baseline 29/29 job `v70-baseline-selftest-r3` ticket 5 §3,
  `.gdignore` §5, handoff §6.
- `.../V71_mechanics_inventory.md` — SHARE/ADAPT/NEW/BLOCKED inventory,
  donor-source table §2.4, world contract §3, ownership §4, honest risks §5.
- `.../V72_mesh_conversion_feasibility.md` — 116 `.obj`, donor animation truth,
  BLOCKED skinned rig, PORT APPROXIMATION fallback, test ids T-V72-1…5.
- `.../G31_donor_3d_truth.md` — perspective not ortho (claim 1), heightfield,
  donor-live meshes, M0.6 failure analysis.
- `.../G32_heightmap_world.md` — full-grid mesh recipe (job `g32-shot` ticket
  1334) that feeds `world3d_terrain.gd`.
- `variant3d/README.md` (V7-0, read-only), `docs/STATUS_TEMPLATE.md`,
  `docs/coord_swarm_2026-11-24/PROGRESS.md`, `FINAL_GATE.md`,
  `launch_variant3d.bat`, `launch_3d.bat`.
- Phase-2 reports that had landed mid-read: `V732_test_camera3d.md` (job
  `v732-camera3d` ticket 7, intentional `MODULE_MISSING`) and
  `V738_manifest.md` (0 of 7 registered; 24 2D entries intact).
- Filesystem snapshot at ~12:05: module/test file existence and mtimes under
  `variant3d/scripts/**`, `variant3d/tests/**`, `reports/V7*.md`.

## 3. Key facts recorded (with evidence)

- Variant baseline is green: **29/29 PASS**, exit 0, 82.13 s, step names/details
  identical to 2D — `v70-baseline-selftest-r3` / `V70_scaffold.md` §3.
- 2D gates remain the reference: selftest 29/29 job 1289, uitest 17/17 job 1290,
  CLEAN (198 jobs, 7 acked) — `PROGRESS.md` "SESSION FINAL VERDICT".
- Final **variant** gate (29/29 + 17/17 + clean) has **not** been run — charter
  "Gates"; `PROGRESS.md` phase-2 atomic-split note.
- Governance: donor-as-source-of-truth, cite `path:line`/evidence id, no invented
  values, singleplayer skirmish only (D-12) — charter `:29-38`, V7-1/V7-2.
- No 2D bake in 3D: sprite dirs `.gdignore`d, geometry/tex/animation kept;
  skinned donor rigs BLOCKED, sampled poses labelled PORT APPROXIMATION —
  charter `:40-57`, `V70_...md` §5, `V72_...md` §4-§5.
- Phase-2 is in flight: 18 atomic agents (8 modules, 7 tests, manifest, 2 docs,
  supervision), integration seams deferred — `PROGRESS.md`. At the ~12:05
  snapshot most module/test files existed on disk, but only V7-32 and V7-38
  phase-2 reports were present; all such claims are marked UNCERTAIN/ON DISK in
  the status doc.

## 4. Notes / discrepancies for the coordinator

1. **Status filename.** `V73_ATOMIC_CONTRACT.md:34` names the final docs artifact
   `docs/variant3d/STATUS.md`, but my task explicitly assigned
   `docs/variant3d/STATUS_WAVE7_PHASE2.md`. I wrote the assigned path and recorded
   the discrepancy as an open question in the status doc; no `STATUS.md` was
   created (would exceed my two-file ownership).
2. **Stale reports are labelled, not silently rewritten.** `V732_test_camera3d.md`
   reports `MODULE_MISSING`, but `camera3d.gd` appeared at 12:04:49;
   `V738_manifest.md` registered 0 tests because the test files were absent at
   *its* verification time, but 7 test files existed by 12:05. Both are recorded
   with a "re-run needed / STALE" note rather than a false PASS claim.
3. **Moving target.** Files were landing during the read (world3d_fx.gd,
   world3d_fog.gd, t_render_mode.gd appeared between snapshots). Every status in
   the docs is explicitly time-stamped and marked UNCERTAIN where an agent is
   still running. A fresh sweep should be done before the final gate.
4. Two owning plans coexist (charter V7-3…V7-9 coarse slots vs V7-3 atomic
   one-file agents). The docs present **both** maps rather than choosing one,
   because the executed launch used the atomic split while integration seams
   follow the charter slots.

## 5. Scope compliance

Created/modified only the three files in §1. No file under `app/`,
`variant3d/`, `docs/coord_swarm_2026-11-24/` (other than this report) or any
existing doc was changed. No Godot/Blender/donor process was launched; all work
was read-only analysis + three Markdown writes.
