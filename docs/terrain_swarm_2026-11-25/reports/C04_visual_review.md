---
id: C04
title: "Final visual-review protocol — deciding 'result is good' (charter §5)"
role: QA / READ-ONLY / SECOND AGENT
owner: C04 (independent reviewer; never the builder of the frame under review)
date: 2026-11-25
status: PROTOCOL__READ_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB__NO_DONOR_PARITY_CERTIFICATION
scope: "Exactly one output file: docs/terrain_swarm_2026-11-25/reports/C04_visual_review.md. No .gd/.gdshader/config/asset/test/tool/fixture/result edit, no Godot submission or queue mutation, no donor-file copy into the repo. This document is the protocol and the blank sign-off template; it records no PASS verdict for the current build."
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED]
parity_guard: "PORT APPROX — internal consistency only. No donor GPU A/B frame exists (CAPTURE_RECHECK.md:35; PIXEL_01:22,83,106,110; METRIC_01:321-325). 'Reads like the reference samples' is a comparative visual judgement, never donor-parity certification. Donor parity stays UNVERIFIED."
governing_sources:
  - docs/terrain_swarm_2026-11-25/CHARTER.md — §1 (owner symptom), §1b (selection quad, ghost final stage), §3 (guardrails), §5 (definition of good)
  - docs/terrain_swarm_2026-11-25/SWARM_BOARD.md:75-91 — C01 tool ownership, COORD integration, fresh 64² + real-map capture
  - docs/coord_swarm_2026-11-25/CAPTURE_RECHECK.md — established second-agent method (§1 artifacts/commands, §2 checklists, §3 image rules, §4 recording, §5 attribution)
  - docs/coord_swarm_2026-11-25/reports/PIXEL_01_p0_capture_review.md — independent visual read; region descriptions; two failure modes kept separate
  - docs/coord_swarm_2026-11-25/reports/METRIC_01_dark_rows.md — metric-scope analysis; PIXEL-01 vs METRIC-01 reconciliation precedent
  - docs/coord_swarm_2026-11-25/TEST_MATRIX.md:29-36,58-75 — windowed 1280×720 capture, second-agent rule, no weakening, metrics never override visual
  - docs/coord_swarm_2026-11-25/VIDEO_QA_PROTOCOL.md:11-15,30-46 — frame sequences for marquee/ghost motion; frames.json; no parity from motion
  - variant3d/tools/smallmap_capture.py:21-39,42-58 — stats/scan-stderr definitions
  - variant3d/tools/terrain_ab_metric.py:1-31,60-61,370-380,490-497 — C01 SMOKE METRIC fields and explicit "not a fidelity gate or donor proof" label
  - docs/terrain_swarm_2026-11-25/reports/D03_selection_probe.md:70-94,97-105,150-222,309-329 — capture traps A/B/C/D, overlay-inclusive harness fix, before/during/after PNGs, pixel assertions and UNVERIFIED-on-missing-PNG rule
  - docs/terrain_swarm_2026-11-25/reports/A12_config_knobs.md:27-43,116-121,144-158,170-179 — no config bridge for uv_repeat/mask_to_alpha; shader defaults unbound; K1/K2 binding requirement; --config overlay limits
  - docs/coord_swarm_2026-11-25/reports/RELIEF_VISUAL_01.md:70-109,127-148 — proven real-map windowed capture form, raw sidecar, observed water/artifact regions
  - docs/coord_swarm_2026-11-25/reports/B_GHOST_DIAG.md:31-38,51-55 and B_GHOST_FIX.md:13-18 — ghost artifact history and stage-1 substitution to look for
  - docs/coord_swarm_2026-11-25/reports/V3D_01_selection_rectangle_audit.md:54-80 — selection overlay code path and failure history
---

# C04 — final visual-review protocol

## 0. What this protocol does and does not do

- It defines how a **second agent or human** decides the single charter §5 question: *is the result good?* The decision is made from **three required captures** plus the gate record, with the visual read as the authoritative half. It is not a donor-parity test and it never becomes one (`CHARTER.md:55-57,122-130`; `CAPTURE_RECHECK.md:35`; **observed**).
- C04 writes only this protocol. The reviewer who executes it must be independent of the builders; the builder never self-certifies the visual read (`TEST_MATRIX.md:58-59,75`; `CAPTURE_RECHECK.md:34,249`; **observed**). COORD alone owns runner jobs, one Godot at a time, via `python variant3d\tools\godot_runner.py run --id <UNIQUE>`; **C04 submits none** (`CHARTER.md:63-65`).
- When executed, the reviewer fills the §7 sign-off block **in this file** (no new report file). A blank or partially filled sign-off is not a PASS (`CAPTURE_RECHECK.md:89`; **derived**).
- Two independent failure modes are kept as two separate fields: what the image shows, and what the metric/gate numbers say. `PIXEL-01` called a `GENUINE_VISUAL_DEFECT` where `METRIC-01` called the specific predicate `METRIC_ARTIFACT`; both observations were retained and reconciled by a stricter applicable gate, not by erasing either one (`PIXEL-01:73-83`; `METRIC_01:228-268`; `CAPTURE_RECHECK.md:36`; **observed**).
- **Two capture traps govern the UI half, and one config trap governs A/B attribution** (all OBSERVED/DERIVED from `D03_selection_probe.md:70-94` and `A12_config_knobs.md:116-121,144-158`):
  - **Trap A — wrong viewport:** main's `Screenshot3DViewport` reparents **only `world` and `camera`**, not `input_ctl`; a saver-style `capture_view3d.get_texture().get_image()` therefore shows terrain and units but **no selection quad**. That is a false negative, not evidence the quad is broken. Any quad verification MUST use a capture path that includes the live overlay (D03 harness fix: reparent `sel_rect_overlay` into `capture_view3d` and assert the new parent in the result JSON).
  - **Trap B — blank backbuffer:** the root-window texture reads blank under `gl_compatibility`; `root.get_texture().get_image()` is not a valid shortcut. A missing or blank PNG/frame is recorded **UNVERIFIED (NO PNG)** and fails the required item — never a fabricated PASS from green JSON or node state.
  - **Config trap — no `uv_repeat` / `mask_to_alpha` bridge:** those shader uniforms exist (`terrain_tileindex.gdshader:214,235`) but `_tileindex_material()` binds neither (`world3d_terrain.gd:682-721`); writing them into a `--config` overlay creates **unread keys with no effect** (`A12:120-121,152-156`). An A/B arm claiming to vary them is not a valid arm until an additive key **and** one binding line land (A12 K1/K2); cross-arm visual differences must not be attributed to them.

---

## 1. Claim labels and the recording rule

Every line in the review's claim ledger (§6) carries exactly one label (`FINAL_GATE_PLAN_01.md:30-35` as quoted in `CAPTURE_RECHECK.md:37`; `B_GHOST_DIAG.md:5`; **observed**):

| Label | Use it for | Example from this protocol's sources |
|---|---|---|
| **OBSERVED** | Literal pixel/region fact or document fact, with path + coordinates/frame number. A negatively worded observation is allowed **only if the named region was actually scanned**. | "CAP-1 x200–720/y200–480 shows thin brighter diagonal strokes a few luma counts above the field" (`PIXEL_01:31-35`). |
| **DERIVED** | Arithmetic or direct control-flow consequence of OBSERVED facts. Show the inputs. | "`full_width_dark_rows=720` on a 720-row image means 720/720 rows met the >90%-luma<20 predicate" (`METRIC_01:76,196-199`). |
| **INFERRED** | Plausible cause, or the comparative judgement "reads like the reference samples". Must carry a caveat; cannot promote to parity. | "The strokes are *consistent with* stretched texgen, but other causes are not excluded" (`PIXEL_01:66-71`). |
| **UNVERIFIED** | Cannot be established from the available material: donor parity, off-screen subjects, missing capture, headless/blank capture, unavailable camera pose. **Never converted to PASS.** | "Actual camera transform at capture time" (`METRIC_01:309-312`); donor parity (`METRIC_01:321-325`). |

Rules (binding):

1. Describe **regions before verdicts**: frame fill and corners, sky/horizon/ground boundary, tonal range and colour signature, then each named phenomenon in §3 (`CAPTURE_RECHECK.md:235`; **observed**).
2. Pixel descriptions are OBSERVED. *Why* a feature exists is INFERRED. A missing/invisible/out-of-frame target is UNVERIFIED, not a negative PASS (`W55_visual_ab.md:21-27,134-138` as cited in `CAPTURE_RECHECK.md:237`; **observed**).
3. "Reads like the reference samples" is an INFERRED comparative judgement tied to named features (multi-scale mottling, rock faces, natural shore). It is **not** a donor-parity claim and never becomes one (`CHARTER.md:23-25,126`; **observed**).
4. Every claim names its evidence id: capture path + approximate pixel box, or frame number from `frames.json`, or the exact command output. An uncited claim is UNVERIFIED (`CAPTURE_RECHECK.md:248`; **derived**).
5. No donor screenshot is copied into the repo or treated as a GPU A/B frame (`VIDEO_QA_PROTOCOL.md:48-52`; **observed**).

---

## 2. The three captures that must exist

Exactly **three capture sets** are gating evidence for §7. They are produced by COORD-owned runner jobs through the FIFO runner; C04 only opens their artifacts. A missing capture makes its §7 item **FAIL** for missing evidence (UNVERIFIED evidence cannot pass a required item) — it is never replaced by a green JSON or a neighbouring capture (`CAPTURE_RECHECK.md:54,266`; **derived**).

| ID | Capture set | Required content | Artifacts the reviewer opens |
|---|---|---|---|
| **CAP-1** | **Fresh windowed 64² capture** | Real generated 64² map via `variant3d/tests/fixtures/small_map_64.json` (seed 20261113, `render_mode=3d` inherited), **not** the flat synthetic P0 all-grass stub. Windowed, no `--headless`, `--screenshot` after the second `--`, `--screenshot-frames 10`, 1280×720, main's real camera bound (`RELIEF_VISUAL_01.md:70-85`; `TEST_MATRIX.md:29-36`; **observed**). Ground-only terrain quality: tiling, streaks, blotches, colour variation. | Requested PNG **or** the raw sidecar `<name>.png.raw.png` if main's blank detector refused the final write (`RELIEF_VISUAL_01.md:98-123` — record that refusal and the `screenshot capture diag` line); `stdout.txt`/`stderr.txt`; config/fixture path. A P0-style stub frame, if supplied, is an **auxiliary control**, not a substitute for CAP-1. |
| **CAP-2** | **Real-map windowed capture** | Same windowed command form with the **real map config** under review (no 64² dimension override unless that map is the subject); 1280×720, fixed camera, same seed. Shows relief/cliffs, shore, large-scale variation over the real extent (`CHARTER.md:124-127`; `SWARM_BOARD.md:89`; **observed**). | PNG (or raw sidecar with diag), `stdout.txt`/`stderr.txt`, config path and seed. Record camera diag (`camera_current=true`, viewport 1280×720) verbatim. |
| **CAP-3** | **Interaction frame sequence** (one capture set, ≥5 frames: 3 mandatory quad PNGs + 2 ghost PNGs) on a real windowed 64² boot | Frame **A** = `before.png`: pre-drag/selected-wall state; frame **B** = `during.png`: selection marquee actively dragging (quad visible, cursor displaced from drag start); frame **C** = `after.png`: post-release quad hidden; frames **D/E** = build ghost at a **valid** then **invalid** site showing the **last/completed** stage (or after cancel/placement, ghost gone). Frames may be one runner submission with a sequence capture; `frames.json` must record per frame: sim time, mouse screen position, drag start/current, overlay visible + rect, `build_ghost_sid`, requested stage, ghost visible/valid/position (`VIDEO_QA_PROTOCOL.md:30-37`; `CAPTURE_RECHECK.md:52`; **observed**). **The quad frames MUST come from an input_ctl-inclusive capture path**, not main's saver: reparent the live `sel_rect_overlay` into `main.capture_view3d` and record `ov.get_parent() == capture_view3d`, `run_mode=windowed_real_input`, `event_coord_scale=[1,1]`, `marquee_color` and `marquee_width_px` in the result JSON (`D03:70-83,97-105,123-126,309-318`). Do not reuse main's saver mid-drag (`main.gd:1730-1732,1930`; D03 Trap C) and do not read the root-window texture (D03 Trap B). | Raw frames (`d03_selquad_before|during|after.png` in a unique Temp folder), `frames.json`, contact sheet and MP4 where motion is reviewed, `stdout.txt`/`stderr.txt`, result JSON with overlay-parent and pixel-sample records. Keep raw frames until the sign-off is recorded (`VIDEO_QA_PROTOCOL.md:37`). If the quad or ghost is off-screen in a frame, that item is UNVERIFIED for that frame — never PASS. |

**Capture-integrity prerequisites (apply to all three; items 1–5 OBSERVED from `CAPTURE_RECHECK.md:56-60`, `TEST_MATRIX.md:62-64`, `RELIEF_VISUAL_01.md:80-85`, `smallmap_capture.py:31-38`; items 6–7 from `D03:70-88,263-278`):**

1. Windowed launch; no `--headless` (headless yields `SKIP_CAPTURE` / `passed=false`, not PASS).
2. PNG/raw sidecar exists, is 1280×720, non-blank. For a raw sidecar accepted because of the blank-detector false positive, require the printed `screenshot capture diag` with `camera_current=true`, `world_parent=Screenshot3DViewport` and a plausible camera/target (`RELIEF_VISUAL_01.md:104-123`).
3. `python variant3d\tools\smallmap_capture.py scan-stderr <stderr.txt>` → `script_error_lines: 0`. Non-`SCRIPT ERROR` runtime warnings are recorded as observations (`CAPTURE_RECHECK.md:59,123`).
4. Fixed harness/seed/camera/size reused; no new harness introduced for the review. A different harness makes cross-capture attribution UNVERIFIED.
5. For CAP-3, per-frame metadata exists and matches the claimed states; a single still cannot evidence "during drag" or "last stage" by itself (`VIDEO_QA_PROTOCOL.md:21,39-46`).
6. **Quad-capture path (D03 Trap A):** the result JSON must prove the overlay was parented into `capture_view3d` and that events were real windowed input. A frame captured by main's saver (which reparents only `world` + `camera`) contains no quad and is **not** a quad test — record the item **UNVERIFIED (WRONG CAPTURE PATH)**, never PASS and never "quad still broken" (`D03:72-83,123-126,318`).
7. **Blank/missing readback (D03 Trap B):** null/empty image, wrong size, transparent/null first pixel, missing PNG, or `SKIP_CAPTURE` under headless → **UNVERIFIED (NO/BLANK PNG)** and FAIL for that required item; root-texture substitutes are forbidden (`D03:84-88,169-185,263-278`; `main.gd:1906-1913` precedent).

**Read-only commands the reviewer may run** (Windows `python`, one Godot at a time, no runner submission from C04; `CAPTURE_RECHECK.md:62-83`; **observed**):

```
python variant3d\tools\smallmap_capture.py stats "<TEMP>\<capture>.png"
python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\<ticket>_<job>\stderr.txt
python variant3d\tools\terrain_ab_metric.py "<TEMP>\<capture>.png" --json
```

Open every image directly with the image reader. `stats` prints `NOTE: qualitative comparison only. No donor parity is claimed.` (`smallmap_capture.py:47`); C01's tool prints `SMOKE METRIC - heuristic only, NOT a fidelity gate or donor proof` (`terrain_ab_metric.py:60`). Neither number set replaces the image.

---

## 3. Region map — what to inspect, in which capture

All coordinates are approximate pixels in the 1280×720 frame (y down), inherited from the established reads (`PIXEL_01:24-38`; `RELIEF_VISUAL_01.md:127-148`). If the scene composition differs, **relocate by description** (ground band, water boundary, cursor) and record the new box; never silently shrink a region to avoid an artifact.

| # | Phenomenon | Capture(s) | Exact region / scan method | Signal that fails the item |
|---|---|---|---|---|
| R1 | **Tiling periodicity / grid / checker** | CAP-1, CAP-2 | Ground band excluding HUD/sky/water: CAP-1 ≈x120–1160/y60–640; CAP-2 use the full ground band in three strips: y40–220, y220–500, y500–690. Scan 3×3 sub-region means and row/column profiles; look for identical patches at fixed screen spacing, 2 m cell boundaries, stepped/nested outlines, seam lines. Note `tile_period_px`, `tile_axis`, `row/col_periodicity` from C01 beside — not instead of — the visual read. | Any visible cell boundary, checker mosaic, repeated identical patch or stepped/nested band that is regular rather than organic. The PIXEL-01 baseline had **no** distinguishable 2 m grid (`PIXEL_01:30`); that is the standard. |
| R2 | **Diagonal streaks / moiré** | CAP-1, CAP-2 | Upper-left/centre ≈x200–720/y200–480, densest ≈x300–620/y300–450; also check right half ≈x640–1280/y0–340 for uniform banding and the lower-left curved band ≈x0–430/y500–690. Describe orientation, spacing, luma above field, and whether strokes stay non-grid-aligned. If a second camera pose/frame exists, check whether strokes move with the camera or stay world-fixed. | Regular parallel strokes/bands that read as repetition or moiré; a **curved organic band or true cliff edge is not automatically a streak** — record the distinction as OBSERVED/INFERRED. |
| R3 | **Dark blotches / repeated dark patches** | CAP-1, CAP-2 | Lower-middle ≈x350–950/y480–620, plus whole ground band. Compare local luma to surrounding field; check whether dark patches recur at tile cadence or in identical shape. Cross-check `non_black_fraction`, `mean_luma` and `full_width_dark_rows` with the same PNG (§5). | Repeated, similarly shaped dark blotches; full-width dark/green rows; any new dark band where water is present. A single darker relief/shadow area that is non-repeating is OBSERVED, not automatically FAIL. |
| R4 | **Multi-scale organic colour variation** | CAP-1, CAP-2 | Whole ground band; record large-scale mottling (tens of px) and fine grain (few px), hue/luma spread, presence of grey rock faces. Compare **in words** to the local sample descriptions in `CHARTER.md:23-24` (soft green mottling, dark/light patches, ravines/cliffs; no grid/streaks/repetition). | Flat uniform olive field with only fine grain; no large-scale variation anywhere after full-band scan. Judgement is INFERRED comparative, not parity. |
| R5 | **Relief / cliffs / seams** | CAP-2 primarily; CAP-1 as baseline | y40–690 ground band, with extra attention where slopes/ravines are expected. Look for grey rock faces, non-flat silhouettes, large soft patches; scan for **white stepped grid-aligned bands with nested outlines** (historical artifact: top-left x0–440/y0–330; right x700–1280/y0–500; bottom-left x200–470/y540–720; bottom-right x850–1280/y530–720 in `RELIEF_VISUAL_01.md:141-147`), black rows, z-fighting shimmer, new seams. | New seams, z-fighting, black rows, white stepped/nested bands, or a near-flat ground where relief is expected. Absence of a specific historical patch must be stated with the scanned box. |
| R6 | **Shore / water boundary** | CAP-2 | Locate cyan water first (prior real-map examples: right ≈x1050–1280/y420–470; bottom-right ≈x850–1280/y610–720; bottom-left ≈x0–95/y560–600), then inspect a ≈20–60 px band on both sides of each boundary and the rows through it. Check transition naturalness, water-on-grass tint, full-width dark/green rows, repeated bands parallel to shore. | Full-width dark/green rows on this water-bearing frame; water pixels showing `grass1`; repeated/hard banded shore; new dark row attributable to water. The dark-row gate is applicable on CAP-2 (`METRIC_01:86-89,99-104`); on a water-free frame it is recorded diagnostic only (`P0_GATE_01.md:74-77`). |
| R7 | **Selection quad during drag** | CAP-3 frames A/B/C (`before|during|after.png`) | The rectangle bounded by drag start and current cursor **plus a ≈40 px margin** in `during.png`; use `frames.json` to locate it. Check overlay visible *during* drag, corners track the drag endpoints, correct thickness/colour, rectangle centre **unfilled** (matches `before.png` within 8/255), and hidden in `after.png` (D03 pixel checks: ≥3/4 edge midpoints and ≥2/4 corners marquee-coloured, samples inside `expected.grow(2)`, configured RGBA `[1,1,0,1]` default, no stray yellow — `D03:192-222,309-325`). In frame A, if a wall is selected, verify a subsequent drag still produces the quad (the donor "box select fails after selecting a wall" bug is **not** to be copied: `CHARTER.md:79-80`). **First confirm the input_ctl-inclusive capture path (§2 item 6):** a saver-style frame with no quad is a capture failure, not a visual defect. | Quad absent/lagging/detached from cursor during drag; filled interior; wrong colour/width; quad persists or stays visible after release; wall-selected drag produces no quad (only if that scenario was actually captured — otherwise UNVERIFIED for this sub-check, not PASS). **No quad in a saver-style frame = UNVERIFIED (WRONG CAPTURE PATH), never a FAIL of the game quad and never a PASS.** |
| R8 | **Ghost final stage** | CAP-3 frames D/E (`ghost_valid|ghost_invalid.png`) | A ≈80–160 px box around the cursor ground point plus the footprint outline. Check a translucent **building silhouette of the last/completed build stage**, not a stage-1 foundation or a bare footprint quad; green when valid, red when blocked; alpha ≈0.4 with no self-occlusion; footprint pixel-honest (ghost base matches the site/building extent); ghost clears on cancel/placement. Donor stage chain is `<sid>1..4` with final stage at full progress (`CHARTER.md:105-107`); the prior port substitution used stage `"1"` (`B_GHOST_DIAG.md:33-35`; `B_GHOST_FIX.md:13-18`) — look for and name that exact defect if it persists. | Foundation/first-stage silhouette, bare green/red box, opaque ghost, red/green inverted, ghost offset from cursor footprint, ghost lingering after cancel, or target not visible in the frame (the latter is UNVERIFIED → FAIL for this required item). |

---

## 4. OBSERVED / INFERRED / UNVERIFIED in practice

For each phenomenon R1–R8, the reviewer writes one ledger row (template in §6) following this shape:

> **R2 / CAP-1 / OBSERVED** — x200–720/y200–480: ~7 thin brighter near-parallel strokes, spacing ≈18–25 px, luma ≈3–6 above field, non-grid-aligned; no strokes in x900–1200/y100–300. Evidence: `<capture>.png`, `stats` output block 1.
>
> **R2 / CAP-1 / INFERRED (caveated)** — pattern is consistent with camera-dependent texgen aliasing; no cause is proven by this frame alone (`PIXEL_01:66-71`).
>
> **R8 / CAP-3 frame D / UNVERIFIED** — ghost silhouette stage cannot be identified because the building is partly behind the HUD panel; required evidence missing → sign-off item FAIL, not PASS.
>
> **R7 / CAP-3 `during.png` / UNVERIFIED (WRONG CAPTURE PATH)** — frame was read from main's saver; `input_ctl` is not parented into `capture_view3d`, so a missing yellow quad is a capture-path artifact, not a game defect (`D03:72-83`). No quad claim is made; sign-off item 7 fails for missing evidence.
>
> **R7 / CAP-3 `during.png` / OBSERVED** — with the overlay reparented and `ov.get_parent()==capture_view3d` in JSON, ≥3/4 edge midpoints and ≥2/4 corners are yellow inside `expected.grow(2)`; centre matches `before.png` within 8/255; `during.png` x395–917/y274–458 (`D03:192-222`).

Do not write: "no artifacts anywhere" after inspecting one crop; "donor-like" as an OBSERVED label; a cause as OBSERVED; or a PASS derived from a JSON assertion alone (`CAPTURE_RECHECK.md:234-240`; **observed**).

---

## 5. Using C01 metric numbers without overriding the visual read

C01 (`variant3d/tools/terrain_ab_metric.py`) reports smoke statistics: `color` (mean/std RGB, luma, saturation), `block_variance` (`between_share` at 2–128 px), `autocorrelation` (`axis_mean`, `diag_mean`, `diag_minus_axis`), `directional_gradient` (`diag_excess`, `streak_angle_deg`, `coherence`), `seam_repetition` (`row_seam`, `col_seam`, `row/col_periodicity`, `tile_repeat`, `tile_period_px`, `seam_repetition_driver`), and donor-folder comparison fields (`z`, `outside_donor_range`) (`terrain_ab_metric.py:170-198,211-256,332-351,370-380,490-497`; **observed**). The tool labels its own output `SMOKE METRIC - heuristic only, NOT a fidelity gate or donor proof` (`:60`) and the charter labels donor parity UNVERIFIED.

Rules:

1. **Copy numbers verbatim and cite the command and PNG path** into the "C01 metric reading" field. Treat them as corroboration for R1–R4 (e.g. a high `diag_excess` alongside visible streaks; a low `between_share` alongside a flat field), never as the decision itself (`CAPTURE_RECHECK.md:238`; `TEST_MATRIX.md:73-74`; **observed**).
2. **A green metric or green JSON never erases a visible defect.** If CAP-1 shows a grid, streaks or repeated blotches, R1/R2/R3 fail even when `seam_repetition_score` is low or the atom's `verdict=PASS` (`PIXEL_01:73-83`; `CAPTURE_RECHECK.md:91`; **observed**).
3. **A red metric on an inapplicable predicate is reported, not used to invent a failure or a pass.** `full_width_dark_rows` counts rows with >90% of pixels at luma<20 (`smallmap_capture.py:27-28`) and was authored as a **water-band** detector (`METRIC_01:99-104,228-268`). On a water-free CAP-1 it is a recorded diagnostic (`RECORDED_NOT_APPLICABLE`, `P0_GATE_01.md:74-77`); on CAP-2 with water it is applicable. If a predicate is genuinely inapplicable, record both its value and the visual reading, leave the instrument unchanged, and route the scoping change to a separate evidence-backed ticket — no threshold lowering, assertion deletion or rerun-for-green (`CAPTURE_RECHECK.md:239,265`; `TEST_MATRIX.md:67-68`; **observed**).
4. **Keep the two verdicts separate.** Fill "C01 metric reading" and "second-agent visual reading" as distinct fields; do not merge into an average. This is the PIXEL-01/METRIC-01 reconciliation: defect observation retained, instrument scope corrected, neither erased (`CAPTURE_RECHECK.md:36`; **observed**).
5. **Donor-folder z-scores and `outside_donor_range` are calibration hints only.** They are computed against a folder of donor stills, not a donor GPU A/B frame at matched camera; they cannot establish parity, and a "good" z-score does not make R1–R8 pass (`terrain_ab_metric.py:24-31,490-497`; **observed**).
6. Gate items (§7 item 9) are read from their own reports, not inferred from images or C01 numbers. A green metric is not a gate certificate (`CAPTURE_RECHECK.md:250`; **observed**).
7. **Config-overlay arms are not arms for unbound uniforms.** A12 established that `uv_repeat` and `mask_to_alpha` are declared shader uniforms with **no config bridge**: `_tileindex_material()` binds neither, and writing those keys into a `--config` JSON creates unread keys with no effect (`A12:120-121,152-156`; `terrain_tileindex.gdshader:214,235`; **observed/derived**). Therefore: (a) never describe a `--config`-only difference as a `uv_repeat`/`mask_to_alpha` A/B result; (b) if an arm's `--dump-config` shows no such key or the binding line is absent, record the arm's causal attribution **UNVERIFIED**; (c) accept such an A/B only when the additive key **and** one `set_shader_parameter(...)` binding line are confirmed present (A12 K1/K2), with identical seed, camera and `start_zoom` across arms. The same discipline applies to ghost final stage (no config key; `world3d_fx.gd:645` hard-calls stage `"1"`, A12:134-139, K8).

---

## 6. Claim ledger template (fill once per R-item per capture)

| Field | Fill-in |
|---|---|
| Item / capture / frame | R__ / CAP-__ / frame __ (or PNG path) |
| Scanned region (px box) | x___–___, y___–___ (full band / sub-crop stated) |
| OBSERVED | Literal description + luma/colour/spacing where relevant |
| DERIVED | Arithmetic only, with inputs |
| INFERRED (caveated) | Possible cause or "reads like samples" judgement; state what would disprove it |
| UNVERIFIED | Missing frame, off-screen target, camera pose, donor parity, etc. |
| Evidence id | PNG path + `stats`/C01 command output, or frame number + `frames.json` field |
| Item result | PASS / FAIL (from §7) |

---

## 7. Sign-off template — "result is good" (charter §5)

Mark **exactly one** of PASS / FAIL per row. Justify every row with a ledger reference; blank = UNVERIFIED = FAIL for a required item. Result is good **only if every row is PASS** and no required evidence is UNVERIFIED.

| # | Charter §5 item / check | Required evidence | PASS | FAIL | Ledger ref / note |
|---|---|---|:--:|:--:|---|
| 1 | **All three capture sets exist and are integrity-clean** | CAP-1, CAP-2, CAP-3 paths; 1280×720; windowed; non-blank; `script_error_lines: 0`; `frames.json` for CAP-3; **CAP-3 quad path proven input_ctl-inclusive**; no root-texture/blank readback | ☐ | ☐ | Missing/headless/blank capture or wrong quad path → FAIL (UNVERIFIED evidence), never a fabricated PASS |
| 2 | **No repeating diagonal streaks** | R2 on CAP-1 and CAP-2 | ☐ | ☐ | Any regular streak/moiré band in either capture → FAIL |
| 3 | **No grid / checker mosaic / tiling periodicity** | R1 on CAP-1 and CAP-2 | ☐ | ☐ | Cell boundary, repeated patch, stepped/nested outline → FAIL |
| 4 | **No repeated dark blotches** | R3 on CAP-1 and CAP-2; C01 `color`/`block_variance` as corroboration only | ☐ | ☐ | Repeated dark patches or new dark rows → FAIL |
| 5 | **Multi-scale organic colour variation** (INFERRED comparative judgement) | R4 on CAP-1 and CAP-2 vs `CHARTER.md:23-24` feature list | ☐ | ☐ | Uniform flat/olive field with only fine grain → FAIL; never worded as donor parity |
| 6 | **Relief/cliffs and shore read like the samples; no new seams, z-fighting or black rows** | R5 + R6 on CAP-2 (CAP-1 baseline) | ☐ | ☐ | Water-band gate applies on CAP-2; white stepped bands/seams/z-fighting/black rows → FAIL |
| 7 | **Selection quad correct during drag** (draw, geometry, lifetime, hit semantics) | R7 on CAP-3 `before|during|after.png` **from an input_ctl-inclusive path** (overlay parent asserted); D03 pixel samples; wall-selected drag sub-check if captured, else UNVERIFIED sub-check | ☐ | ☐ | Wrong capture path or blank PNG → UNVERIFIED → FAIL of this item; visible absent/lagging/persisted/filled quad or reproduced wall-selection defect → FAIL. A quad-less saver frame is explicitly **not** a game defect finding |
| 8 | **Ghost shows the LAST/completed build stage**, translucent, green valid / red blocked, pixel-honest footprint | R8 on CAP-3 frames D/E (`ghost_valid|ghost_invalid.png`); donor stage chain `<sid>1..4` as cited context, not parity | ☐ | ☐ | Stage-1/foundation, bare footprint quad, opaque/offset/lingering ghost → FAIL |
| 9 | **Existing gates stay green** | Read gate reports: variant selftest **29/29**, uitest **17/17**, `t_render_mode`, `assert_clean` **CLEAN**, 2D `app/` untouched (`CHARTER.md:128-129`; `SWARM_BOARD.md:91`) | ☐ | ☐ | C04 does not run gates; a missing/stale gate report is FAIL for this item |
| 10 | **Provenance: every change has a donor citation or explicit PORT APPROX label**; no A/B attribution to unbound shader uniforms | `CHARTER.md:130`; implementation reports; `A12:120-121,144-158`; `--dump-config` + binding-line check per arm | ☐ | ☐ | Unlabelled substitute constant, missing citation, or a `--config`-only `uv_repeat`/`mask_to_alpha` arm claimed as a visual cause → FAIL / attribution UNVERIFIED |
| 11 | **No donor-parity certification anywhere in the review** | Every field uses PORT APPROX / UNVERIFIED for parity; no donor A/B claim | ☐ | ☐ | Any parity claim or "donor-confirmed" wording → FAIL |

**Overall verdict (tick one):** `RESULT IS GOOD — all PASS` ☐  /  `RESULT IS NOT GOOD — one or more FAIL or required UNVERIFIED` ☐

**Second-agent sign-off**

- Reviewer / agent id: ____________________  Date: ____________
- CAP-1 path: ____________________________________________________________
- CAP-2 path: ____________________________________________________________
- CAP-3 frame directory + `frames.json`: _________________________________
- C01 report / `--json` output path: _____________________________________
- Gate evidence paths: __________________________________________________
- C01 metric reading (verbatim numbers + path, §5): _____________________
- Second-agent visual reading (separate from metrics): ___________________
- Explicit statement (required): **"PORT APPROX — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."**
- Items failed / required UNVERIFIED (list with ledger ids): ______________
- Routing note (owning file per failure; no fix applied here): ____________

COORD acts on this sign-off; the reviewer does not advance any ladder, submit a rerun, edit an asset, or declare a row PASS (`CAPTURE_RECHECK.md:249-250,256-265`; **observed**).

---

## 8. Anti-patterns (all forbidden)

- Judging from `stats`/C01 numbers or a green JSON without opening the PNG/frames (`CAPTURE_RECHECK.md:234,238`; `PIXEL_01:59-64`).
- Treating `full_width_dark_rows`, `diag_excess` or a donor z-score as a fidelity gate or parity proof (`smallmap_capture.py:47`; `terrain_ab_metric.py:60`; `METRIC_01:321-325`).
- Dropping an artifact from the region list, lowering a threshold, deleting an assertion, or rerunning until green (`TEST_MATRIX.md:60-68`; `P0_GATE_01.md:176-186`).
- Converting a missing PNG, blank/root-texture frame, off-screen ghost/quad, headless frame or unproven cause into PASS (`CAPTURE_RECHECK.md:266`; `W55_visual_ab.md:21-27,134-138`; `D03:84-88,169-185,263-278`).
- Reading a saver-style screenshot (reparents only `world` + `camera`) as quad evidence, or calling a quad-less frame "quad still broken" (`D03:72-83`). Any quad verdict without an asserted `input_ctl`-inclusive capture path is invalid.
- Treating a `--config` overlay with `uv_repeat`/`mask_to_alpha` keys as a real A/B arm when no shader-parameter binding exists (`A12:120-121,152-156`).
- Calling a smooth frame sequence a donor match (`VIDEO_QA_PROTOCOL.md:39-46`).
- Certifying donor parity, copying donor images into the repo, or letting the implementing builder self-certify the visual read (`CAPTURE_RECHECK.md:35,249`).
- Editing anything except this report, or submitting any Godot job, while executing C04 (`CHARTER.md:55-69`; ticket scope).

---

## 9. Summary

Three captures — fresh windowed 64² (CAP-1), real map (CAP-2), and a frame-sequenced interaction set (CAP-3) — are opened and described region by region (§3). Each claim is labelled OBSERVED / DERIVED / INFERRED / UNVERIFIED with a path, pixel box or frame id (§1, §6). C01's numbers and `stats` are corroborating smoke measurements only; they never override the visual read, and the inapplicable-predicate case follows the PIXEL-01/METRIC-01/P0-GATE-01 precedent of keeping both readings (§5). Two capture traps are hard gates: quad verification requires an `input_ctl`-inclusive capture path (D03 Trap A), and any blank/missing/root-texture readback is UNVERIFIED, never a fabricated PASS (D03 Trap B). No `--config`-only `uv_repeat`/`mask_to_alpha` arm can support an attribution claim without a real binding line (A12). The §7 table turns charter §5 into eleven PASS/FAIL rows plus an overall "result is good" decision; donor parity is explicitly **UNVERIFIED** and no donor-parity certification is issued.

---

## 10. Hand-off to C02 / COORD — gate-plan addendum (not applied here)

At the time of this update no C02 report exists in `docs/terrain_swarm_2026-11-25/reports/`. Per charter §3 disjoint ownership and C04's one-report scope, **C04 did not edit C02's file**; COORD must relay the following mandatory gate rows to C02 (or apply them when integrating):

1. **G-Q0 — capture-path gate (D03 Trap A).** No gate may accept a selection-quad PASS from main's saver path: `Screenshot3DViewport` reparents only `world` + `camera`, not `input_ctl`. Require result-JSON proof `ov.get_parent() == capture_view3d`, `run_mode=windowed_real_input`, `event_coord_scale=[1,1]`, and the D03 before/during/after PNGs with pixel assertions. A quad-less saver frame is `UNVERIFIED (WRONG CAPTURE PATH)`, not "quad broken" and not PASS.
2. **G-Q1 — readback-integrity gate (D03 Trap B).** Root-window texture reads blank under `gl_compatibility`; forbid `root.get_texture().get_image()` as evidence. Null/empty image, wrong size, transparent/null first pixel, missing PNG or headless `SKIP_CAPTURE` → `UNVERIFIED (NO/BLANK PNG)` and gate FAIL; no fabricated PASS from green JSON/node state.
3. **G-A0 — config-overlay validity gate (A12).** `uv_repeat` and `mask_to_alpha` are shader uniforms with **no config bridge** (`world3d_terrain.gd:682-721` binds neither; overlay keys are unread). Any gate plan arm claiming a visual effect from `--config` keys for these must instead record attribution `UNVERIFIED` unless an additive key **and** one `set_shader_parameter(...)` binding line are confirmed (A12 K1/K2), with seed/camera/`start_zoom` pinned and `--dump-config` logged per arm.
4. **G-G0 — ghost-stage gate (A12 K8).** The final/completed stage is not reachable by any existing config key (`world3d_fx.gd:645` hard-calls stage `"1"`). Gate evidence must come from the code/atom that resolves the final stage mesh, never from an overlay key.

These rows mirror C04 §2 items 6–7, §5 rule 7 and §7 items 1/7/10; they carry no donor-parity claim.

---

*End of C04. Protocol and blank template only. No code, config, asset, test, tool, result, gate or donor file edited; no Godot job submitted; no visual PASS or overall GOOD verdict recorded by this worker.*
