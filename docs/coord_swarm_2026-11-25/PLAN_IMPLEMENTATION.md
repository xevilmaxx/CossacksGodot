---
title: IMPLEMENTATION PLAN — atomic, disjoint, gated (2026-11-25, 3D variant)
area: coordination
owner: COORD
updated: 2026-11-25
status: draft — gated on donor re-verification + piece tests
---

# 🛠️ Implementation plan — atom first, whole last

**No code is edited in this plan.** Every ticket below is one file (or one new test file),
one builder, with a backup and a targeted runner job. Shared code is READ-ONLY until this
plan grants exclusive ownership. Godot stays serialized through `variant3d/tools/godot_runner.py`.

## 0. Non-negotiable order (owner directive)

```
donor truth (2–3 passes)  →  piece tests P0..C4 + S1 on 64²  →  ONE final whole-system gate
```

Each row of `TEST_MATRIX.md` is run **alone first**, on the same 64² fixture, with a second
agent re-checking the capture. The final gate is never run early.

## 1. Ticket catalog

| Ticket | Owned file(s) — EXCLUSIVE | Change | Gated on | Acceptance |
|---|---|---|---|---|
| **SEL-01** | `variant3d/scripts/input_controller.gd` | (a) draw the drag rectangle as a `CanvasLayer` overlay in viewport pixels, **yellow (1,1,0,1), 1 px solid** (`selection.cfg:2-14`), `MOUSE_FILTER_IGNORE`; (b) replace 6-px screen threshold with donor **0.005 world m** on ground X/Z (`onmousemove.inc:32-34,152`, 0.25 in attack/guard mode); (c) Shift = add (`spmAdd`), no Shift = replace; (d) double-click 0.35 s → 0.5 s (`menu.cfg:33`); (e) keep click-pick branch byte-identical | DSEL-01 + DSEL-02 + **RV-SEL-01** (resolves `.inc` live-code convention) + S1 test written | S1 drives real mouse events on 3 units; exact selected-ID set; overlay Rect2 equals drag pixels during drag and clears on release; `cmd_*` counter 0; 29/29 + 17/17 green |
| **SEL-02** | `variant3d/tests/t_select_rect.gd` (new) | 3-unit stub (or real 64² boot for HUD), real press/motion/release events, assert selection list + overlay state + no click regression | TEST-01 harness helper | fails before SEL-01, passes after; result JSON written; `call_deferred(quit)` |
| **TRN-SHADER** | `variant3d/shaders/terrain_tileindex.gdshader` | (a) replace neutral eye-plane UVs with stable **world-ground XZ texgen** (APPROX label); (b) consume donor sun direction instead of `light_position_eye=0` headlight, decide `unshaded` honestly; (c) keep mask/donor equations intact | RV-TRN-01 + F0 donor baseline + T0 capture | T0/T5 A/B: pan/zoom texel displacement ≈0 in world space; luma/contrast changes measurable; no dark streak; donor parity NOT claimed |
| **TRN-WATER** | `variant3d/shaders/water3d.gdshader`, `variant3d/scripts/water3d.gd` | confine water alpha to actual water cells; revisit hmapMin/Max ±2.96, coastfade; keep donor literals/equations; no foam image | RV-TRN-03 + T2 capture | T2: full-width dark rows = 0; one water plane; land above water untinted; shore animation visible |
| **TRN-DATA** | `variant3d/scripts/game.gd` (or mapgen owner file) | parse donor `tilesmooth_scripts.cfg` transition rules into `tileblock` before UV2; increase family diversity; NO synthetic noise/dither | RV-TRN-02 (full rule parse) + T0 histogram baseline | top-5 share <73%, `test7/8/9` <14%; unchanged seed byte-identical where required; 29/29 green |
| **TRN-FACE** | `variant3d/scripts/world3d_terrain.gd` | 25° cliff tilt matrix + h overrides `rock8/rock4`; keep existing face promotion; use **recovered face eye planes** (front S=(1,0,0,0) T=(0,0,1,0), side S=(0,1,0,0) T=(0,0,1,0), scale 0.125) | RV-TRN-01 **DONE** (face literals/planes recovered; selection rule UNVERIFIED) + T0/T1 capture | face_hist matches known steep cells; flat fixture → 0 promoted; labelled APPROX |
| **DECOR-01** | `variant3d/scripts/world3d_entities.gd` | tree/mine placement fidelity + scale/jitter from donor `envscales.cfg`; no invented assets | DTRN-04/05 + DEC-03 + T1/T3 captures | exact category purity/counts; Y matches terrain; no overlap with water |
| **TEST-HARNESS** | `variant3d/tests/fixtures/_smallmap_harness.gd` (new, single owner) | `make_stub_game(...)`, `count_categories()`, `write_result()` — ~40 lines, dynamic `load()` | TEST-01 | all piece atoms can consume it; no atom edits it; no `class_name` |
| **TEST-P0..C4** | one new `variant3d/tests/t_*.gd` per row | nine atoms per `TEST_MATRIX.md` / TEST-01 §"Recommended new atom names" | TEST-HARNESS | each PASS alone on 64²; windowed capture + `<ticket>-<row>` runner job; stderr scanned |
| **INT-REGISTRY** | `variant3d/tests/manifest.json`, `variant3d/tools/test_all.py` | additive atom registration; variant-aware roots; `result_dir` → `variant3d/tests/results` | all piece atoms green | registry points at variant, not `app/`; no weakening of existing entries |
| **FINAL** | COORD only | variant selftest 29/29 + uitest 17/17 + clean; 2D gates untouched | every ticket above green + second-agent capture re-check | all gates green, owner visual review |

## 2. Conflict arbitration already applied

- **S-25-06 / world vs screen rect:** donor (`DSEL_02`, 3 passes) uses WORLD ground coordinates
  and a world-epsilon threshold. V3D-01's screen-space `select_in_rect()` suggestion came from
  the 2D analogue and is **REJECTED**. Keep the world rect; change the threshold and Shift
  semantics; draw the visual box as a viewport-pixel overlay (visual is a labelled port
  approximation until a donor A/B exists).
- **S-25-09 / no synthetic tile noise:** DTRN-01 M10 + DOC-01 failure register forbid adding a
  luminance/dither/noise field — it re-creates the documented 2D checkerboard regression.
- **Do-not-redo list:** tile-index wiring, atlas manifest, mask R→A repack, one-mesh geometry,
  donor water equations, donor sun rig, shadow-OFF decision, shader compile fixes, camera
  double-subtract fix (V3D_02 §"What is already correct" 1–12; DTRN-01 §6.1).

## 3. Per-ticket working agreement

1. Back up each owned file to `inbox\backup\<name>.bak-<TICKET>` before editing.
2. Minimal diff; no renames of symbols other scripts call; no "improvements" beyond the ticket.
3. Every 3D constant cites donor `path:line`/evidence id, else `UNVERIFIED` + `PORT APPROXIMATION`.
4. Targeted runner job with unique id `<ticket>-<purpose>`; record job id and result in the report.
5. One report `reports/<TICKET>.md` with claim table (`observed`/`derived`/`inferred`), before→after, gates, open questions.
6. COORD alone updates `SWARM_BOARD.md` state and merges.

## 4. Test ladder ownership map (parallelisable, one file each)

```
TEST-HARNESS (helper) ──┬── TEST-P0  (terrain only)
                        ├── TEST-P1  (+trees)
                        ├── TEST-P2  (+shore)
                        ├── TEST-P3  (+mines)
                        ├── TEST-03a/b/c/d (combos)
                        └── TEST-04  (selection) ──── SEL-01 (input_controller.gd)
```

Runner is FIFO: authoring can be parallel, **execution is strictly sequential** P0→P1→P2→P3→
C1→C2→C3→C4→S1→FINAL, stopping at the first failing row.
