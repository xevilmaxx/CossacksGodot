---
id: G21
ticket: G21
title: "Decisive visual-acceptance checklist for G04's upcoming P0 / real-map PNGs"
role: READ-ONLY / CHECKLIST AUTHOR / SECOND-AGENT REVIEW INSTRUMENT
owner: G21 (WAVE G follow-up)
created: 2026-11-25
status: CHECKLIST_ONLY__NO_RUNNER_JOB__NO_CODE_OR_ASSET_EDIT__NO_DONOR_PARITY_CLAIM
scope: "Exactly one output file: docs/terrain_swarm_2026-11-25/reports/G21_acceptance_checklist.md. No .gd/.gdshader/config/asset/test/tool/fixture/result edit; no Godot launch, runner submission/queue mutation; no donor-file copy into the repo. This is a blank instrument: it records no PASS verdict for any frame, because G04's PNGs did not exist when it was written."
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED]
parity_guard: "PORT APPROX — internal consistency only. Every 'reads like the reference samples' judgement is an INFERRED comparative read tied to named features, never donor-parity certification. No donor GPU A/B frame exists (CHARTER.md:55-58,122-130; C04:10,58; A11:22-24,237-238). Donor parity stays UNVERIFIED regardless of this checklist's outcome."
governing_sources:
  - docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md — §Standing rules (G04 sole runner owner; one report per agent; no donor-parity claim)
  - docs/terrain_swarm_2026-11-25/CHARTER.md — §1 owner symptom + reference samples A/B, §3 guardrails, §5 definition of good
  - docs/terrain_swarm_2026-11-25/reports/C04_visual_review.md — §2 capture integrity, §3 region map R1–R8, §5 metric hierarchy, §7 sign-off
  - docs/terrain_swarm_2026-11-25/reports/A11_reference_metrics.md — §2–§5 baseline numbers, reference medians and target bands
  - docs/terrain_swarm_2026-11-25/reports/C01_metric_tool.md — §2 field names, §5 interpretation, §7 A11 mapping caveats
  - docs/terrain_swarm_2026-11-25/reports/G04_gate_log.md — §2 prepared PNG paths and capture launch forms
---

# G21 — visual acceptance checklist (blank instrument for G04's PNGs)

## 0. How to use this document

This is the **decisive read instrument** for the two PNGs G04 is about to produce under
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\g04\`: the P0 capture (`p0_64.png`)
and the real-map capture (`realmap.png`) prepared in `G04_gate_log.md:98-99,104-122`.
It is applied by a reviewer **independent of the frame's builder** (`C04:33`); G21 submits
no runner job and edits no source (`WAVE_G_CHARTER.md:31`).

Record each R-item exactly once per PNG with the four C04 labels (`C04 §1`):

- **OBSERVED** — literal pixel/region fact, with path + pixel box.
- **DERIVED** — arithmetic from OBSERVED inputs (e.g. a ratio to the baseline).
- **INFERRED (caveated)** — "reads like the reference samples" or a plausible cause; never parity.
- **UNVERIFIED** — missing/blank frame, off-screen target, unmatched camera, donor parity.
  **Never converted to PASS** (`C04:52,57,66`).

Describe the region before the verdict (`C04:56`): frame fill/corners, sky–ground boundary,
tonal range, then each named phenomenon. A negatively worded observation is permitted **only
if the named box was actually scanned** (`C04:49`). Boxes are approximate 1280×720 pixels,
y down (`C04:98`). If the scene composition differs, **relocate by description and record the
new box; never silently shrink a region to avoid an artifact** (`C04:98`).

---

## 1. Admissibility gate — is the PNG evidence at all?

Apply before any R-item. A failed sub-item makes that PNG **UNVERIFIED → FAIL** for every
item that depends on it; do not substitute a green JSON or a neighbouring capture (`C04:66`).

| # | Required (all OBSERVED from `C04:74-82`; paths from `G04_gate_log.md:108,114,121`) | PASS signal | FAIL signal |
|---|---|---|---|
| G0-a | Windowed launch, **no `--headless`** | Windowed result JSON; `--screenshot` after the second `--` | Headless / `SKIP_CAPTURE` → UNVERIFIED |
| G0-b | PNG exists, **1280×720**, non-blank | Image opens with real content; accept a `.png.raw.png` sidecar only with the printed `screenshot capture diag` (`camera_current=true`, `world_parent=Screenshot3DViewport`, plausible camera/target) recorded verbatim | Missing, wrong size, transparent/null first pixel, root-texture readback (`C04` Trap B) |
| G0-c | `python variant3d\tools\smallmap_capture.py scan-stderr <stderr.txt>` | `script_error_lines: 0` | Any `SCRIPT ERROR`; non-script warnings recorded as observations |
| G0-d | Harness/seed/camera/size fixed and recorded | `config.json` seed `20261113`, 1280×720, camera diag pasted (`G04:124-126`) | Different/new harness → cross-capture attribution UNVERIFIED |
| G0-e | Ground-only ROI chosen and stated | Same crop applied to candidate **and** baseline (§3) | Whole-frame vs cropped-donor comparison (`C01:210-211`) |

**Scope note (decisive).** `g04-p0cap` uses `t_terrain_only.gd` — a P0-style stub frame. Per
`C04:70` that is an **auxiliary control, not CAP-1** (CAP-1 requires the real generated 64²
via `small_map_64.json`, seed 20261113). The real-map PNG is the CAP-2 analogue. Therefore
this checklist can declare the **terrain half** assessable from G04's two PNGs; the
**interaction half (R7/R8)** is not evidenced by stills and stays UNVERIFIED (§5, item 7).
Record that distinction rather than claiming a full charter §5 "result is good" from two PNGs.

---

## 2. Before-vs-after method against `p0_final_formula.png`

Baseline (OBSERVED): `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\p0fresh01\p0_final_formula.png`,
1280×720 lossless PNG, A11 index 12, ground ROI fractional `.02,.02,.98,.98` → 1229×691
(`A11:78,96`). Its measured state: mean RGB `93.73, 96.76, 31.62`, luma mean `91.4`,
luma std `10.6`, p5–p95 `75–109` (34 levels; 84.0% of pixels in histogram bins 5–6,
`Y≈80–112`), HSV sat mean `0.675`, BV32 n640 `8.7`, grad n640 `5.00` (`A11:96,122,126-138,158`).

Do all four steps; keep the two readings in **separate fields** (`C04:137,140`):

1. **Integrity first** — pass §1 for both PNGs. Never compare a blank/headless frame.
2. **Same-crop numeric A/B (PNG vs PNG)** — copy numbers **verbatim**, cite the command and
   both paths. Two accepted forms:
   - C01 smoke: `python variant3d\tools\terrain_ab_metric.py <candidate.png> "<baseline>" --crop <x,y,w,h> --json`.
     PNG-vs-PNG is the like-with-like case (`C01:181`); C01 declares `SMOKE METRIC — heuristic
     only, NOT a fidelity gate or donor proof` (`C04:92`, `C01:29`).
   - A11-band form: apply A11's exact method to the **same ROI on both PNGs** — Rec.709 luma on
     sRGB values, resample ROI to width 640 (LANCZOS), 32×32 non-overlapping block means,
     `var(ddof=1)`; `grad n640` and hist as in `A11 §1`. Read-only, from temp; no repo tool edit.
   - **Caveat (binding):** C01 does **not** apply A11's 640-px normalisation, and has no direct
     `grad n640` field — its `block_variance[32].between_block_var` and
     `directional_gradient.axis_gradient_energy` are *raw-crop* proxies (`C01:205-217`). Use
     them for **direction of movement across A/B frames**, never as the A11 absolute bands
     (`C01:145,214-217`).
3. **Same-box visual A/B** — apply the R1–R6 boxes from §4 to **both** images and describe, in
   words, what changed: did strokes/bands/blotches disappear, did coherent light/dark patches
   appear, did the histogram "narrow spike" widen? Keep this prose out of the metric field.
4. **Attribution** — strongest A/B is P0-stub vs P0-stub (same harness form). For the real-map
   PNG, if seed/camera/harness differ from the baseline, label cross-capture attribution
   **UNVERIFIED** and report direction of movement only (`C04:79`; `C01:145`).

**Abuse check:** a better number never closes a visible grid, streak, blotch, seam or black row
(`C04:138`). A worse number never invents a defect the box does not show; if a predicate is
inapplicable (e.g. `full_width_dark_rows` on a water-free P0 frame), record its value **and**
the visual reading as `RECORDED_NOT_APPLICABLE` and leave the instrument untouched
(`C04:139`; no threshold lowering, no rerun-for-green, `C04:204`).

---

## 3. Numeric target bands — corroboration only (DERIVED from A11 §5)

These are **direction targets, not gates and not donor parity** (`A11:165-166,237-238`).
The three structural items must move together; a rise at only one scale indicates a new
periodic artifact, not organic mottling (`A11:168-172`).

| Metric (A11 method, same ROI on both PNGs) | p0 baseline (OBSERVED) | Target band (DERIVED) | Required direction | C01 proxy / caveat |
|---|---|---|---|---|
| **BV32 n640** | 8.7 | **≈150–270** (ref median 247.6; p25 200.9; p75 272.0; ref A 205.0) | **UP ~20–30×** | `block_variance[32].between_block_var` on same crop; directional only, no 640 normalisation (`C01:205-210`) |
| **BV8 / BV16 / BV64** | 15.3 / 12.5 / 7.2 (native) | rise **in step** across all scales | UP together | `block_variance[8/16/64].between_block_var`; one-scale-only rise = suspect periodicity (`A11:171-172`) |
| **grad n640** | 5.00 | **≈1–2 px⁻¹** (ref median 1.30; p25 0.78; p75 3.58; ref A 2.10) | **DOWN ~3–4×** | no direct C01 field; `axis_gradient_energy` raw — same-crop A/B only (`C01:215-217`). More fine dither would worsen it (`A11:178`) |
| **luma std** | 10.6 | **≈18–22** (ref median 20.1, range 18.3–21.9; ref A 19.6) | **UP ~1.9×** | `color.std_luma` on same crop |
| **p5–p95 / histogram** | 75–109 (34 levels), 84% in bins 5–6 | widen toward **~60–80 levels**; real occupancy in bins 2–4 and 7–9 | UP | `color.p05_luma` / `p95_luma`; histogram from A11 method |
| **HSV sat mean (secondary)** | 0.675 (highest of 13 ROIs) | **≈0.53** (~20% down); B up from 31.6 toward ~43 | DOWN | `color.mean_saturation`; palette only — **must not substitute** for the three structural items (`A11:184-187`) |

Reference-sample anchors for the prose read: ref A `cossacks-3-v1-498085.jpg` has mean RGB
`90.25, 90.84, 43.33`, luma std `19.6`, p5–p95 `51–118`, BV32 n640 `205.0`, grad `2.10`,
sat `0.541` (`A11:91,117,134-138`); ref B `articolo-787.jpg` is rolling relief with patchy
grass, luma std `21.7`, BV32 n640 `264.4`, grad `1.40` (`A11:89,115,119`); the green-ground
median luma mean is `74.0` (p0 `91.4`, so a luma *drop* is acceptable) (`A11:98-101`).

---

## 4. Region-by-region acceptance cards (exact boxes from C04 §3 R1–R8)

For each card fill: `Item / PNG / box`, `OBSERVED`, `DERIVED`, `INFERRED (caveated)`,
`UNVERIFIED`, `Evidence id`, `PASS`, `FAIL` (`C04 §6`). A card is **PASS only if its PASS
signal is positively observed in the named box**; absence of evidence is UNVERIFIED, not PASS.

### R1 — Tiling periodicity / grid / checker
- **Applies to:** P0 PNG (ground band ≈**x120–1160 / y60–640**, excluding HUD/sky/water) and real-map PNG (full ground band in three strips **y40–220, y220–500, y500–690**).
- **Scan:** 3×3 sub-region means plus row/column mean profiles; look for identical patches at fixed screen spacing, 2 m cell boundaries, stepped/nested outlines, seam lines. Note C01 `seam_repetition.{row/col_periodicity, tile_repeat, tile_period_px, driver}` beside — not instead of — the image (`C04:102`).
- **Reference look:** both donor samples have **no** grid, checker mosaic or repeated patch (`CHARTER.md:23-24`); PIXEL-01's baseline had **no distinguishable 2 m grid** (`C04:102`).
- **PASS:** no cell boundary, no checker mosaic, no repeated identical patch, no regular stepped band; sub-region means vary irregularly.
- **FAIL:** any visible cell boundary, checker mosaic, repeated patch or stepped/nested outline that is regular rather than organic — **even if** `seam_repetition_score` is low or a JSON verdict is PASS.

### R2 — Diagonal streaks / moiré
- **Applies to:** both PNGs. Upper-left/centre ≈**x200–720 / y200–480**, densest ≈**x300–620 / y300–450**; also right half ≈**x640–1280 / y0–340** for uniform banding, and lower-left curved band ≈**x0–430 / y500–690**.
- **Scan:** describe orientation, spacing, luma above field, non-grid alignment; if a second pose/frame exists, note whether strokes move with the camera or stay world-fixed.
- **Reference look:** no diagonal streaks or repetition in the samples (`CHARTER.md:23-24`). Numerical streak evidence is **inconclusive**: C01 `diag_excess≈0.0005`, `coherence≈0.013` on p0, and A11's lag-32 diagonal-vs-axis ratio `0.69` sits inside the reference range `0.50–0.99` (`C01:149-152`; `A11:209-212`). A detected FFT band (`band_peak_deg=90`, horizontal) is descriptive only (`C01:153-159`). **Do not let those numbers suppress or substitute for the visual read.**
- **PASS:** no regular parallel strokes/bands in any named box; grain reads non-periodic.
- **FAIL:** regular parallel strokes/bands that read as repetition or moiré. A curved organic band or true cliff edge is **not automatically a streak** — record the distinction as OBSERVED/INFERRED, do not fail on it without evidence (`C04:103`).

### R3 — Dark blotches / repeated dark patches
- **Applies to:** both PNGs. Lower-middle ≈**x350–950 / y480–620**, plus the whole ground band.
- **Scan:** local luma vs surrounding field; recurrence at tile cadence or identical shape. Cross-check `color`, `block_variance`, `full_width_dark_rows` **as corroboration only** (`C04:104`).
- **Reference look:** samples have dark/light patches that are **organic and non-repeating** (`CHARTER.md:23`); p0's narrow spike (`A11:156-161`) is the failure state.
- **PASS:** no recurring same-shape dark patches, no new dark band; any darker area is a single non-repeating relief/shadow region.
- **FAIL:** repeated similarly shaped dark blotches, full-width dark/green rows, or any new dark band where water is present. A single non-repeating darker relief area is OBSERVED, **not** auto-FAIL (`C04:104`).

### R4 — Multi-scale organic colour variation
- **Applies to:** both PNGs, whole ground band. Record large-scale mottling (tens of px), fine grain (few px), hue/luma spread, grey rock faces.
- **Reference look (INFERRED comparative, never parity):** ref A = organic grass with **large soft green mottling**, dark/light patches, ravines/cliffs with grey rock faces, trees; ref B = rolling relief, patchy grass, natural transitions; **no grid, streaks or repetition** (`CHARTER.md:23-24`). Numeric anchors: BV32 n640 ≈150–270, grad ≈1–2, luma std ≈18–22, sat ≈0.53 (§3). "Reads like the reference samples" must name which of these features is present (`C04:58`).
- **PASS:** coherent light/dark patches at ≥32 px scale are present **and** fine grain is subordinate; spread is broad; verdict worded as INFERRED comparison to named features.
- **FAIL:** flat uniform olive field with only fine grain after a full-band scan (`C04:105`), or a palette-only change where BV32 stays near `8.7` and grad near `5.00` (`A11:170`).

### R5 — Relief / cliffs / seams
- **Applies to:** real-map PNG primarily; P0 PNG as baseline. Ground band **y40–690**, with extra attention where slopes/ravines are expected.
- **Scan:** grey rock faces, non-flat silhouettes, large soft patches; scan explicitly for **white stepped grid-aligned bands with nested outlines** at the historical boxes: top-left **x0–440 / y0–330**; right **x700–1280 / y0–500**; bottom-left **x200–470 / y540–720**; bottom-right **x850–1280 / y530–720** (`C04:106`). Also black rows, z-fighting shimmer, new seams.
- **Reference look:** ravines/cliffs with grey rock faces and natural transitions (`CHARTER.md:23-24`).
- **PASS:** relief/shore breaks up the surface; no new seam, z-fighting, black row or white stepped/nested band. Any "absent artifact" statement names the scanned box (`C04:106`).
- **FAIL:** new seams, z-fighting, black rows, white stepped/nested bands, or near-flat ground where relief is expected.

### R6 — Shore / water boundary
- **Applies to:** real-map PNG. Locate cyan water first at prior real-map boxes: right ≈**x1050–1280 / y420–470**; bottom-right ≈**x850–1280 / y610–720**; bottom-left ≈**x0–95 / y560–600**; then inspect a **20–60 px band on both sides** and the rows through it (`C04:107`).
- **Scan:** transition naturalness, water-on-grass tint, full-width dark/green rows, repeated bands parallel to shore. The dark-row gate **applies on the real-map frame** (`METRIC_01:86-89,99-104`); on a water-free P0 frame record it `RECORDED_NOT_APPLICABLE` (`C04:107,139`).
- **Reference look:** natural rolling/shore transitions, no banding (`CHARTER.md:24`).
- **PASS:** natural transition; no full-width dark/green row; no `grass1` pixels in water; no repeated hard bands parallel to shore.
- **FAIL:** full-width dark/green rows on this water-bearing frame, water pixels showing `grass1`, repeated/hard banded shore, or a new dark row attributable to water.

### R7 — Selection quad during drag — **NOT EVIDENCED BY P0/REAL-MAP STILLS**
- **Applies to:** **CAP-3 only** (`d03_selquad_before|during|after.png` + `frames.json`). The rectangle bounded by drag start and current cursor **+ ≈40 px margin** in `during.png` (`C04:108`).
- **Required capture path (hard gate):** result JSON must prove overlay reparented into `capture_view3d` (`ov.get_parent()==capture_view3d`, `run_mode=windowed_real_input`, `event_coord_scale=[1,1]`). A saver-style frame (reparents only `world` + `camera`) contains no quad — that is a **capture failure, not a game defect** (D03 Trap A, `C04:37,81,206`).
- **PASS:** overlay visible during drag; corners track endpoints; correct thickness/colour (default RGBA `[1,1,0,1]`); ≥3/4 edge midpoints and ≥2/4 corners marquee-coloured inside `expected.grow(2)`; centre matches `before.png` within 8/255; hidden in `after.png`; a wall-selected drag still produces the quad (`C04:108`, `CHARTER.md:79-80`).
- **FAIL:** visible absent/lagging/detached quad, filled interior, wrong colour/width, quad persisting after release, or reproduced wall-selection defect — **only where that state was actually captured**.
- **From G04's two PNGs:** **UNVERIFIED (NO CAP-3 FRAMES)** → §5 item 7 cannot PASS. Do not mark "quad broken" and do not fabricate PASS from green JSON.

### R8 — Ghost final stage — **NOT EVIDENCED BY P0/REAL-MAP STILLS**
- **Applies to:** **CAP-3 only**, frames `ghost_valid|ghost_invalid.png`. A ≈**80–160 px box around the cursor ground point plus the footprint outline** (`C04:109`).
- **Reference/convention look:** translucent hologram of the **last/completed** build stage, green valid / red blocked, alpha ≈0.4, no self-occlusion, footprint pixel-honest, clears on cancel/placement. Donor stage chain `<sid>1..4` is cited **context, not parity** (`CHARTER.md:105-107`); the prior port defect hard-called stage `"1"` (`C04:109`, `C04:227`).
- **PASS:** final-stage silhouette, correct green/red, alpha ≈0.4, base matches site extent, ghost gone after cancel/placement.
- **FAIL:** foundation/stage-1 silhouette, bare footprint quad, opaque/offscreen/offset ghost, inverted colours, lingering ghost, or target not visible (the latter UNVERIFIED → FAIL for this required item).
- **From G04's two PNGs:** **UNVERIFIED (NO CAP-3 FRAMES)** → §5 item 8 cannot PASS.

---

## 5. Sign-off — "result is good" (charter §5) applied to this evidence

Tick **exactly one** of PASS / FAIL per row; justify each with an R-card ledger reference.
Blank = UNVERIFIED = FAIL for a required item. Result is good **only if every row is PASS and
no required evidence is UNVERIFIED** (`C04:164`).

| # | Charter §5 item | Evidence this checklist can see | PASS | FAIL | Ledger ref / note |
|---|---|---|:--:|:--:|---|
| 1 | Captures exist and are integrity-clean | §1 G0-a…e for both PNGs + gate report | ☐ | ☐ | Missing/headless/blank → UNVERIFIED → FAIL |
| 2 | No repeating diagonal streaks | R2 on P0 + real-map | ☐ | ☐ | Regular parallel strokes/moiré → FAIL; metric silence is not PASS |
| 3 | No grid / checker / tiling periodicity | R1 on both | ☐ | ☐ | Cell boundary/repeated patch/stepped outline → FAIL |
| 4 | No repeated dark blotches | R3 on both; C01 corroboration only | ☐ | ☐ | Repeated dark patches / new dark rows → FAIL |
| 5 | Multi-scale organic colour variation | R4 on both + §3 bands (INFERRED comparative) | ☐ | ☐ | Flat olive field with only fine grain → FAIL; never worded as donor parity |
| 6 | Relief/shore read like samples; no new seams/z-fighting/black rows | R5 + R6 on real-map (P0 baseline) | ☐ | ☐ | White stepped bands/seams/black rows → FAIL; dark-row gate applies on real-map only |
| 7 | Selection quad correct during drag | R7 on CAP-3 frames — **not in G04's two PNGs** | ☐ | ☐ | **UNVERIFIED (NO CAP-3 FRAMES) → FAIL of this item**; never "quad broken" from a still |
| 8 | Ghost shows last/completed stage | R8 on CAP-3 frames — **not in G04's two PNGs** | ☐ | ☐ | **UNVERIFIED (NO CAP-3 FRAMES) → FAIL of this item** |
| 9 | Existing gates stay green | Read gate reports: selftest 29/29, uitest 17/17, `t_render_mode`, `assert_clean` CLEAN, 2D `app/` untouched (`CHARTER.md:128-129`) | ☐ | ☐ | Read from reports, never inferred from PNG/C01 numbers (`C04:142,176`) |
| 10 | Provenance: donor citation or PORT APPROX label; no unbound-uniform A/B | Implementation reports; `A12` binding check | ☐ | ☐ | `--config`-only `uv_repeat`/`mask_to_alpha` arm claimed as cause → attribution UNVERIFIED |
| 11 | No donor-parity certification anywhere | Every field uses PORT APPROX / UNVERIFIED | ☐ | ☐ | Any "donor-confirmed"/"donor match" wording → FAIL |

**Overall verdict (tick one):** `RESULT IS GOOD — all PASS` ☐ / `RESULT IS NOT GOOD — one or more FAIL or required UNVERIFIED` ☐

Given the prepared deliverable is two terrain stills, **rows 7 and 8 are UNVERIFIED by
construction**; the honest outcome for that evidence set is `RESULT IS NOT GOOD` until CAP-3
frames land — this is an evidence-completeness statement, **not** a finding that the quad or
ghost is broken (`C04:66,168,174-175`).

**Reviewer block**

- Reviewer / agent id: ____________________  Date: ____________
- P0 PNG path + `script_error_lines`: __________________________
- Real-map PNG path + `script_error_lines`: ____________________
- Baseline path: `...\opencode\p0fresh01\p0_final_formula.png` (ROI `.02,.02,.98,.98`)
- C01 command + verbatim `--json` numbers, same crop on both PNGs: __________________
- A11-band values (BV32 n640, grad n640, luma std) for each PNG: ____________________
- Second-agent visual reading (separate field, per R-card): _________________________
- Required statement (copy verbatim): **"PORT APPROX — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."**
- Items failed / required UNVERIFIED (ledger ids): ______________
- Routing note (owning file per failure; no fix applied here): ____________________

COORD acts on this sign-off; the reviewer advances no ladder, submits no rerun, edits no asset
and declares no row PASS on JSON alone (`C04:196`).

---

## 6. The metric-never-overrides rule (binding, restated)

1. Copy numbers **verbatim** with command + path into the metric field; use them as
   corroboration for R1–R4 only (`C04:137`).
2. **A green metric or green JSON never erases a visible defect.** A visible grid/streak/blotch
   fails R1/R2/R3 even with low `seam_repetition_score` or `verdict=PASS` (`C04:138`).
3. **A red metric on an inapplicable predicate never invents a defect.** Record both values,
   leave the instrument unchanged, route any scoping change to a separate evidence-backed
   ticket — no threshold lowering, assertion deletion or rerun-for-green (`C04:139`).
4. Keep metric reading and visual reading as **two distinct fields**; never average them
   (`C04:140`). Donor-folder z-scores / `outside_donor_range` are calibration hints only and
   cannot make R1–R8 pass (`C04:141`).
5. Gate items are read from their own reports, not from images or metrics (`C04:142`).
6. No `--config`-only `uv_repeat`/`mask_to_alpha` arm can support an attribution claim without
   an additive key **and** a `set_shader_parameter(...)` binding line, with seed/camera/
   `start_zoom` pinned (`C04:143`, A12 K1/K2). Same discipline for ghost stage (A12 K8).

---

## 7. Forbidden here and in its execution

- Judging from `stats`/C01/green JSON without opening the PNG (`C04:202`).
- Treating `full_width_dark_rows`, `diag_excess`, a donor z-score or BV32 as a fidelity gate or
  parity proof (`C04:203`; `C01:29,60`; `A11:22-24`).
- Dropping an artifact from the region list, lowering a threshold, deleting an assertion or
  rerunning until green (`C04:204`).
- Converting a missing/blank/root-texture frame, off-screen ghost/quad, headless frame or
  unproven cause into PASS (`C04:205`).
- Reading a saver-style screenshot as quad evidence, or calling a quad-less frame "quad still
  broken" (`C04:206`).
- Calling a `--config` overlay a real A/B for unbound uniforms, or a smooth sequence a donor
  match (`C04:207-208`).
- Certifying donor parity, copying donor images into the repo, or letting the builder
  self-certify the visual read (`C04:209`).
- Editing anything except the assigned report, or submitting a Godot job (`WAVE_G_CHARTER.md:31,32`).

---

## 8. Honesty / parity statement

- **OBSERVED:** the four source documents' region boxes, sample descriptions and measured
  baseline/reference numbers quoted above, with paths and line anchors.
- **DERIVED:** the §3 target bands and the before/after direction checks from A11's reference
  medians and p0 baseline.
- **INFERRED (caveated):** every "reads like the reference samples" judgement, tied to named
  features; a cause is never proven by one frame (`C04:58,119`).
- **UNVERIFIED:** donor parity (no donor GPU A/B frame exists — `A11:22-24,237-238`;
  `C04:10`), R7/R8 from terrain stills, any missing/blank capture, and any unmatched-camera
  cross-capture attribution.
- **No donor-parity claim is made.** A checklist result — whatever it says — is PORT APPROX
  internal consistency only, never donor-fidelity certification and never a gate pass.

---

*End of G21. Blank checklist instrument only. No runner job submitted, no code/config/asset/test/tool/result edited, no donor file copied, no visual PASS or overall GOOD verdict recorded by this worker.*
