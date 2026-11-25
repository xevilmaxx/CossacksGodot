---
id: PIXEL-01
title: "Visual review of captured P0 terrain-only PNG (TEST-RUN-02 job 404)"
owner: PIXEL-01 (visual-review micro-worker)
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_GODOT_RUN__NO_DONOR_ACCESS
scope: "One new report file only. No code, shader, asset, config, test, runner job or donor edit/copy."
image_path: 'C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\test01_ladder2\smallmap64_terrain_only.png'
upstream: "TEST-RUN-02 job 404 stopped at P0; result passed=false, 20 passes / 1 fail (full_width_dark_rows expected 0, observed 720)"
labels: [observed, derived, inferred]
verdict: GENUINE_VISUAL_DEFECT
parity_claim: false
---

# PIXEL-01 — visual review of the captured P0 terrain-only PNG

## 0. Scope, inputs and reading rule

- **Image inspected:** `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\test01_ladder2\smallmap64_terrain_only.png` (988,242 B, 1280×720), read directly as an image and re-measured read-only with `python variant3d/tools/smallmap_capture.py stats <png>`; the re-measure reproduces the job's published numbers exactly (`non_black_fraction=0.992807`, `mean_luma=13.271`, `mean_rgb=[14.045,14.381,0.001]`, `full_width_dark_rows=720`).
- **Metric definition:** `variant3d/tools/smallmap_capture.py:21-39`.
- **Camera / capture setup:** `docs/coord_swarm_2026-11-25/reports/TEST_P0_report.md:51-68,142-159` (atom authors a private `SubViewport`, 1280×720, fresh `World3D`, `UPDATE_ONCE`, real `camera3d.gd` bound, `_process()` edge-scroll disabled after bind, 10 frames, `await RenderingServer.frame_post_draw`, `get_texture().get_image().save_png()`); `variant3d/scripts/camera3d.gd:88,122-123,171-204` (perspective, `FOV_DEG_ASSUMED=17.27` marked PORT APPROX / UNVERIFIED, default height `√(20·58)≈34.1 m`, `bind()` sets centred transform). No camera value was changed or re-run here.
- **Background context only:** `DTRN_01_donor_terrain_pipeline.md`, `V3D_02_terrain_render_audit.md` (P2/P3/P6/P7), `GAPS.md` §2. **No donor GPU frame exists in the project; no donor parity is claimed anywhere in this report.** Cause statements below are explicitly `inferred`.

## 1. Observations — what is in the image

All coordinates are approximate pixels in the 1280×720 frame. Contrast is extremely low throughout; descriptions of faint features are at the limit of visibility.

- **Frame fill:** the entire frame, including all four corners, is filled with a near-black dark-olive field. No bright region, no sky, no horizon line, and no distinguishable ground/sky boundary exists anywhere. The upper-right quadrant (≈x 640–1280, y 0–340) and the right half generally are the most uniform areas.
- **Colour:** channel maxima over the whole image are R=29, G=31, B=3; median RGB ≈ (14,14,0); blue is effectively absent (only ~0–0.1% of pixels in any 3×3 region have B>0). Sampling after quantisation to steps of 4 yields only **26 distinct colours**; the three dominant ones are `[16,16,0]` (~48.6% of pixels), `[12,12,0]` (~27.2%) and `[12,16,0]` (~11.5%). The image is a low-dynamic-range olive field, not a grey or black one.
- **Tiles / patches:** **no distinguishable 2 m tile grid, no checkerboard, no seam lines and no banding at tile scale.** No cell boundary can be picked out. The 3×3 region means are nearly identical (13.23–13.32 luma), each with std ≈2.35, and row means span only 12.636–14.038 while column means span 12.507–13.763 — there is no large-scale vertical or horizontal tonal structure.
- **Faint features (real pixels, not grid-aligned):**
  - upper-left / centre: a cluster of thin, slightly brighter **diagonal scratch-like strokes** around ≈x 200–720, y 200–480, densest near ≈x 300–620, y 300–450;
  - lower-left: a faint **curved arc / soft band** around ≈x 0–430, y 500–690;
  - lower-middle: a faint smeared patch around ≈x 350–950, y 480–620.
  These strokes stay only a few luma counts above the field (region maxima up to 28.4, never ≥30) and do **not** resolve into tile art, relief, shoreline or any recognisable structure.
- **Structures:** none visible — no trees, mines, units, buildings, water plane or shoreline; consistent with the atom's empty `res_nodes` and hidden water, but this is an image observation only, not a verification of those flags.
- **Brightness census:** 99.734% of all pixels have luma < 20; 24.1% have luma < 12; **0 pixels have luma ≥ 30**; the brightest single pixel is 28.4. A full-width dark-row test therefore fires on every one of the 720 rows.

## 2. Metric reading — what `full_width_dark_rows` actually measures

`variant3d/tools/smallmap_capture.py:25-28`: luma `= 0.2126R + 0.7152G + 0.0722B`; a row is "dark" when `>90%` of its pixels have `luma < 20`; the metric counts such rows. It is a **row-count of near-black occupancy**, not a tile-seam, variance, or donor-comparison metric. `non_black_fraction` separately measures the share of pixels with any channel `>8`.

Reading it against this image:

- The failure is **global, not a one-row or few-row band**. Every row has mean luma 12.636–14.038; even the row with the most pixels at or above the threshold has only **1.41%** of pixels with luma ≥20. No row contains a bright strip that the threshold might be mistakenly clipping.
- The frame is **not blank**: `non_black_fraction=0.992807` and there are faint real pixel strokes; a blank/black readback would have driven this near 0.
- It is also **not the configured sky**. `world3d_terrain.gd:934-948` sets `Environment.BG_SKY` with `background_color=(0.62,0.70,0.66)` and donor sky colours; a sky-filled or un-textured viewport would be bright and blue-bearing, whereas this frame is olive with B≈0. Something dark-olive is being drawn — most plausibly the terrain material's output — but that is an inference, not a proven binding diagnosis.
- Therefore the metric is reporting the correct symptom of the pixels: the whole frame sits well below its intended luminance floor. Conversely, the metric says nothing about *why*, and a zero value would not have proved donor fidelity.

## 3. Separated claims

### observed (from the PNG and cited source lines)

- Uniform near-black olive field over all 1280×720; no sky, horizon, tiles, checkerboard, seams or structures distinguishable.
- Faint diagonal strokes (upper-left/centre) and a faint curved band (lower-left); no grid alignment.
- `mean_rgb=[14.045,14.381,0.001]`, `mean_luma=13.271`, 720/720 dark rows, 99.734% of pixels luma<20, max pixel luma 28.4.
- The atom's capture path and frozen real camera as described in §0; water hidden and `res_nodes` empty per the atom's authored setup.

### derived (arithmetic / direct consequence)

- The threshold failure is a property of the **entire frame**, not of a localised dark band: no row has more than 1.41% pixels ≥ luma 20, and no pixel anywhere reaches luma 30.
- The frame has essentially no usable tonal range for terrain interpretation (26 quantised colours; per-region std ≈2.35).
- The frame is non-blank and olive, so it is neither an empty black capture nor the bright port sky.
- Structural PASS results in the job JSON (1 surface, 4096 verts, 7938 tris, 4096 UV2, atlas (16,8), shadow OFF) are consistent with a mesh and material being present; they do **not** imply correct visible colour, and are not themselves visual evidence.

### inferred (possible causes — not established, no fixes proposed)

- The known port approximations identified in `V3D_02` could plausibly contribute: shader is `unshaded` with `light_position_eye=0` headlight (P3); neutral eye-plane UVs with `uv_repeat=(1,1)` producing camera-dependent, wrongly scaled texgen (P2); `mask_to_alpha` compositing over a dark framebuffer (P7). The faint smeared strokes are *consistent with* P2-style stretched grain, but could equally be atlas fall-back or another artefact.
- Water banding (P6) is **not** a candidate for this atom because its water plane is hidden — an explicit exclusion, not a finding.
- An exposure / tone-mapping / viewport-state difference between this atom's private `SubViewport` and main's proven `Screenshot3DViewport` path is another untested possibility.
- None of these can be selected from this single frame; **no donor parity or causal claim follows.**

## 4. Verdict

**GENUINE_VISUAL_DEFECT** — with high confidence in the defect, low confidence in any cause.

Strongest evidence, in order:

1. **The pixels themselves are globally dark**: 99.734% below luma 20, brightest pixel 28.4, every row mean 12.6–14.0. The 720 dark rows are not a threshold edge case or a thin-band false positive.
2. **The image is visually unusable as a terrain frame**: no distinguishable tiles, relief, horizon or structure resolves anywhere; only faint, non-grid-aligned smears exist. This matches the human-visible symptom the check was authored to guard (`V3D_02:144`, T0 "no full-width dark rows").
3. **It is not a blank or mis-coloured capture artifact of the metric**: non-black fraction is 0.993, and the olive B≈0 signature is incompatible with the module's configured bright sky. So `METRIC_ARTIFACT` is rejected. `UNDETERMINED` is rejected for the *symptom* (the visual review independently confirms it), though the *cause* remains undetermined.

Guard on the verdict: this says the **P0 frame fails its own visual acceptance criterion**. It does **not** say the port is or is not donor-like — no donor GPU frame exists, and parity stays UNVERIFIED.

## 5. One discriminating next test (proposed, not executed)

**Paired fixed-camera capture on the same P0 stub, one extra control frame.** Keep the fixture, atlas, shader, SubViewport size, frame count and readback path byte-identical; capture two PNGs:

- **(A) Readback control:** replace only the terrain mesh with a full-frame flat mid-grey/olive unlit quad routed through the *same* `SubViewport` → `frame_post_draw` → `save_png()` path.
- **(B) Pitch variant:** restore the terrain and re-capture with only the camera pitch/height changed (e.g. height ≈20 m and a steeper downward tilt instead of ≈34.1 m), same target and fixture.

How this discriminates:

- **A bright, near-threshold control + dark B at every pitch** → darkness originates in the terrain material/lighting path, not the capture pipeline; strengthens the `V3D_02` P3/P7 attribution.
- **A also dark olive (~14,14,0)** → the darkness is introduced by the readback/exposure/viewport path; the visual defect is real but its cause is outside the terrain shader.
- **B changes the screen position/direction of the faint streaks while luma stays ~13** → supports camera-dependent neutral texgen (`V3D_02` P2); **world-fixed streaks** point away from it.

Keep the assertions unchanged (`full_width_dark_rows == 0`, `non_black_fraction > 0.9`); do not lower a threshold to obtain a green result. All conclusions stay PORT APPROX until a donor frame exists. This is a proposal only — no runner job or code edit was made by this worker.

## 6. Open questions

1. Is the dark olive output from the tile-index atlas path, the splat fallback, or the mask-alpha composite over a dark framebuffer? The PNG alone cannot distinguish these; no `material_model` visual evidence was captured here.
2. Does `mask_to_alpha=1.0` (`V3D_02` P7) materially lower luma in this isolated atom, as its earlier A/B suggested on the full scene?
3. Are the faint diagonal strokes stretched atlas grain from neutral eye-plane UVs (`V3D_02` P2), or a separate decal/transport artefact? Unresolvable at 1280×720 without the pitch variant.
4. Are this atom's fresh `World3D` environment, tone mapping and viewport clear state identical to main's proven screenshot path? Not A/B-tested.
5. What luma/variance a donor 64² terrain-only frame *would* show at a matched camera is UNKNOWN; no donor GPU frame exists, so the luma floor of 20 has no donor-derived calibration in this report.

## 7. Summary

The captured P0 frame is a globally dark, low-contrast olive field that fills all 1280×720 pixels. It has no sky, horizon, distinguishable tiles, checkerboard, seams or structures — only faint diagonal smears in the upper-left/centre and a faint curved band in the lower-left. The `full_width_dark_rows=720` failure is a faithful description of those pixels (99.734% below luma 20; brightest pixel 28.4), not a metric artifact or a thin dark band. The frame is non-blank and is not the configured sky, so something olive is rendered but is far too dark and too featureless to serve as a terrain visual baseline. Verdict: **GENUINE_VISUAL_DEFECT**, cause UNDETERMINED, donor parity UNVERIFIED. The proposed paired control + pitch capture is the smallest next test that separates capture-pipeline, lighting/composite and texgen explanations without weakening the gate.

---

*End of PIXEL-01. One report written; image and cited sources read only; no Godot run, no runner job, no donor access, no code or asset change, no donor-parity claim.*
