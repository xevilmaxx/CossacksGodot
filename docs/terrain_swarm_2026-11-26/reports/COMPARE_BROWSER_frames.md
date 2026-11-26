---
id: COMPARE-BROWSER
swarm: TERRAIN-SWARM-2026-11-26 / DONOR-TERRAIN VISUAL WAVE
wave: 2026-11-26 VISUAL WAVE — SECONDARY image analysis
role: "COMPARE-BROWSER worker subagent; reports to COORD"
owner_file: docs/terrain_swarm_2026-11-26/reports/COMPARE_BROWSER_frames.md
created: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_EDIT__NO_GODOT_JOB__NO_PARITY_CLAIM
labels: [O, D, I, U, "PORT APPROXIMATION", "NO_PARITY_CLAIM"]
scope_guard: "Exactly one repo file written (this report). No code, shader, config, asset, test, fixture, result JSON, git, Godot process, runner job or gate touched. Donor browser JPEGs, wide2 PNGs and capture.json were opened read-only. One labelled contact sheet written only to %TEMP%\\opencode\\donor_compare\\."
parity_guard: "The three browser frames are third-party YouTube captures of unknown build, camera, zoom, world area and JPEG compression. They are REFERENCE/DIRECTION material, NOT an A/B pair with the port. No donor GPU A/B frame exists. parity.claim = NONE, parity.status = UNVERIFIED. Every metric below is a support/screening cue computed independently on each image; no cross-image similarity score, threshold or 'matches donor' wording is used."
governing_sources:
  - docs/terrain_swarm_2026-11-26/VISUAL_WAVE_CHARTER.md — §1 goals, §2 hard rules
  - docs/terrain_swarm_2026-11-26/reports/W08_visual_acceptance_criteria.md — §1 metric rule, §2 class table, §5 tiers
  - docs/terrain_swarm_2026-11-26/reports/W07_props_visual_audit.md — §3.3, §4.1–4.4, §7.5
  - docs/terrain_swarm_2026-11-26/reports/W05_video_capture.md — §3 camera contract, §7.2 reference rule
  - docs/terrain_swarm_2026-11-26/HANDOFF.md — §9.10 lines 261–266 (fix facts supplied by COORD)
---

# COMPARE-BROWSER — donor browser video frames vs our `wide2` frames

## 0. Executive summary

1. **[O] Deliverables.** A labelled five-panel contact sheet was produced at
   `%TEMP%\opencode\donor_compare\contact_sheet.png` (1920×890). The YouTube chrome was removed
   from all three browser JPEGs by a rectangular video-viewport crop; the crop is identical for
   all three donor frames. Our two frames are shown uncropped at 1280×720. This is the only
   written artifact besides this report.
2. **[O] The two image sets are not the same camera, scene or seed.** Donor panels show close
   skirmish views (castle/windmill/field at 120 s, forest and boulders at 600 s, mine/field/army
   at 1800 s). Our panels are the pinned 240² wide pan at height 58 m, FOV 17.27°, pitch −32°
   (`capture.json`, frames 0 and 23). **No parity, similarity percentage or donor threshold is
   derived.** The donor frames are direction-of-appearance references only.
3. **[O] The strongest visible gaps are exactly the named blockers.** Our frame 23 shows a
   large pale, near-neutral rectangular plane under a grey relief mesh (clean-ROI pale-low-sat
   fraction **0.121** vs donor **0.014–0.037**), while none of the three donor frames shows such
   a base. Our frame 0 shows hard, rectilinear near-black stepped bands (clean-ROI luma<32
   fraction **0.0995** vs donor **0.0248–0.0560**), while donor ground is continuous, mottled
   and soft-shaded.
4. **[O] Fields, forest density and prop/material integration are absent or degenerate in our
   frames.** Gold-like pixel fraction in the clean ROI is **0.0000–0.0002** in ours vs
   **0.0635–0.1099** in donor frames; donor 600 s shows multiple conifer groves with long
   ground shadows, ours shows a handful of isolated dark stick trees; donor boulders and the
   mine dome sit directly on grass/field, ours show a mesh on a hard-edged plane.
5. **[D] All numeric values below are per-image support cues** (mean RGB, luma, saturation,
   gradient, edge fraction, block variance). They corroborate the eye's read; they are not
   gates, not donor matches, and no value was tuned to make a row look favourable.
6. **[U] Donor camera height, FOV, zoom, build and compression remain unknown.** Camera
   comparisons are stated only as apparent-scale direction cues, never as matched parameters.

> **PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B
> frame exists; this review certifies neither donor fidelity nor a gate pass.**
> (verbatim W05 §7.2 / W08 §0 / charter §2)

---

## 1. Sources, provenance and admissibility

### 1.1 Input files (opened read-only)

| Tag | Description | SHA-256 (observed) | Native size |
|---|---|---|---|
| D120 | Donor browser frame @120 s, `...\271d6d8d-...\0\screenshot.jpeg` | `d2b3ec7e85f42f9486185e8645b78439967ccbb757e322f79e39a1b7c893991b` | 1296×886 |
| D600 | Donor browser frame @600 s, `...\20bd2316-...\0\screenshot.jpeg` | `8d0a4d96cdec27a0c4656f2d3157371c4048be60a705a8a85f8ce9963758c403` | 1296×886 |
| D1800 | Donor browser frame @1800 s, `...\f2c89dff-...\0\screenshot.jpeg` | `a3c26372328235d943c61fadf415e6c350a656d05373e0d237dde2d3429410a1` | 1296×886 |
| W0 | Our `donor_240_wide2\frame_0000.png` | `f6bada74d133298538f9304fb9f489196e3d9dc8df36bcb35c6d29203cfd1a30` | 1280×720 |
| W23 | Our `donor_240_wide2\frame_0023.png` | `043f0ba23a91f53d36f27acb8a3a6401c329f589c1735acc6e6452bbb689aafc` | 1280×720 |

Donor JPEGs live under
`C:\Users\Maxym.Oboyshev\.cache\opencode\browser-exports\7b3985b074cee559c2525440bfbd7698c595e810065d7dbbc4ca7f55c2fe2fd1\`;
our frames and `capture.json` under
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v42\video\donor_240_wide2\`.

### 1.2 Camera facts (candidate side only, from `capture.json`)

- **[O] Frames 0 and 23:** `height_m = 58.0`, `fov_deg = 17.27000045776`, `pitch_deg = −32.0`,
  `zoom = 0.3448275862`, `viewport = Screenshot3DViewport`, `camera_current = true`,
  `process_enabled = false`, yaw contract `0.0°`; targets `(60,240)` m and `(420,240)` m SIM.
  Total 24 contiguous frames, `status = CAPTURE_OK`, `parity.status = UNVERIFIED`.
- **[U] Donor-side camera:** unknown (browser capture, no camera log). The 17.27° FOV itself
  remains `PORT APPROXIMATION` per W05 §3 / HANDOFF §9.10.

### 1.3 Admissibility

- **[O] G0-a…e style guard (W08 §1):** every panel is non-blank; the identical fractional ROI
  `.12,.08,.81,.68` is applied to all five images. That ROI excludes the in-game top resource
  strip, bottom unit panel, bottom-right minimap and the burned-in YouTube subtitles. Metrics
  on the full crop are reported separately and flagged as HUD-contaminated.
- **[O] The video crop for all three donor frames is the same rectangle: `(17, 68, 901, 566)`**
  → 884×498 (aspect 1.775 ≈ 16:9), detected by the first contiguous non-white run from the
  page's top-left, not by a hand-guessed number. The YouTube chrome, sidebar thumbnails, title,
  likes and comments are excluded.
- **[U] No claim that the crop matches the donor game's original render rectangle** — the
  browser may letterbox or rescale; no stream metadata was available.
- **[D] Different scenes/cameras make any A/B interpretation inadmissible.** W08 §1 forbids
  cross-image similarity as a gate; W05 §7.2 permits only directional read of owner-supplied
  reference frames. This report follows that rule.

---

## 2. Method and metric definitions

Instrument: a bounded Python 3.14 / Pillow 12.1.1 + NumPy probe written temporarily under
`%TEMP%\opencode\donor_compare\` and run once after two crop-detection passes. It reads images
only and writes only `contact_sheet.png`. No repo code, no Godot, no git.

For each image, computed on 8-bit RGB:

| Metric | Definition used here | W08 §1 class |
|---|---|---|
| `mean_rgb` | arithmetic mean of R,G,B channels | (a) screening cue |
| `mean_luma`, `std_luma` | Rec.709 luma `0.2126R+0.7152G+0.0722B`, mean / population std | (a) |
| `mean_sat` | mean of `(max−min)/max` per pixel (W08 §1 definition) | (a) |
| `grad` | mean `hypot(Δx, Δy)` of luma central differences | (a) |
| `e20/e40/e80` | fraction of pixels with `grad ≥ 20/40/80` | (a) |
| `bv32` | population std of 32×32 block *means* of luma (spatial heterogeneity) | (a) |
| `max_row_diff` | max absolute difference between adjacent row-mean luma values | (a) |
| `dark_le12` | fraction of pixels with all channels ≤12 (W07 §5 probe) | (a) |
| `dark_luma32` | fraction of pixels with luma <32 | (a) |
| `bright_luma200` | fraction of pixels with luma >200 | (a) |
| `green_dom` | fraction where G>R and G>B | (a) |
| `gold_like` | fraction with `R>B+30`, `G>B+15`, `R>90` (golden field/stubble direction cue) | (a), locally defined here |
| `pale_low_sat` | fraction with luma>105 and sat<0.42 (pale quad / stone direction cue) | (a), locally defined here |
| 64px two-scale split | std of 64×64 block means vs mean within-block luma std | (a), locally defined here |

**Rule applied:** these numbers support the visual read; they never replace it and never become
a pass/fail threshold. Donor JPEG compression inflates donor `grad`/`e40` somewhat; that
direction is noted wherever it could matter.

---

## 3. Quantitative results

### 3.1 Full video viewport (HUD/subtitles included — contaminated, lower confidence)

| Image | mean RGB | luma (mean±std) | mean sat | grad | e40 | bv32 | dark<32 | gold_like |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| D120 | 74.19, 71.96, 32.43 | 69.58 ± 28.22 | 0.5714 | 14.943 | 0.0896 | 16.109 | 0.0943 | 0.1145 |
| D600 | 67.70, 65.89, 29.98 | 63.68 ± 24.90 | 0.5786 | 10.439 | 0.0620 | 16.619 | 0.1079 | 0.0544 |
| D1800 | 75.54, 70.05, 34.14 | 68.62 ± 28.06 | 0.5672 | 15.348 | 0.1132 | 16.137 | 0.0781 | 0.1094 |
| **W0** | 63.47, 66.61, 20.64 | 62.62 ± 17.94 | 0.6466 | 6.107 | 0.0286 | 14.483 | 0.1714 | 0.0019 |
| **W23** | 80.30, 82.17, 30.45 | 78.04 ± 22.00 | 0.6752 | 4.071 | 0.0042 | 20.626 | 0.0002 | 0.0001 |

`max_row_diff` is omitted here because the donor HUD/subtitle bands dominate it (27.8–17.4);
it is reported on the clean ROI instead.

### 3.2 Clean ROI `.12,.08,.81,.68` — identical fractional rectangle on all five images

| Image | mean RGB | luma (mean±std) | mean sat | grad | e20 | e40 | bv32 | max_row_diff | dark<32 | bright>200 | green_dom | gold_like | pale_low_sat |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| D120 | 74.21, 71.61, 34.25 | 69.46 ± 24.22 | 0.5448 | 16.480 | 0.2707 | 0.1036 | 13.136 | 3.119 | 0.0526 | 0.0017 | 0.2894 | 0.1099 | 0.0374 |
| D600 | 71.36, 69.70, 31.00 | 67.26 ± 19.75 | 0.5775 | 9.392 | 0.1409 | 0.0493 | 13.084 | 2.244 | 0.0560 | 0.0001 | 0.4229 | 0.0635 | 0.0145 |
| D1800 | 77.31, 74.71, 32.42 | 72.21 ± 18.52 | 0.5882 | 9.154 | 0.1224 | 0.0523 | 10.627 | 2.620 | 0.0248 | 0.0015 | 0.3050 | 0.0669 | 0.0138 |
| **W0** | 68.20, 71.25, 21.12 | 66.99 ± 15.05 | 0.6784 | 5.510 | 0.0499 | 0.0274 | 10.328 | 3.373 | 0.0995 | 0.0000 | 0.9906 | 0.0000 | 0.0029 |
| **W23** | 82.71, 84.33, 33.86 | 80.34 ± 24.67 | 0.6563 | 3.822 | 0.0067 | 0.0060 | 22.945 | 30.239 | 0.0000 | 0.0000 | 0.8756 | 0.0002 | 0.1212 |

**Reads [O]/[D] (support only):**

- Donor `grad` 9.15–16.48 and `e20` 0.122–0.271 vs ours 3.82–5.51 and 0.007–0.050: our
  images contain far fewer mid-scale edges. Part of the donor advantage is JPEG detail; even
  with that caveat the gap is large and matches the visible absence of fields, groves and
  built detail.
- Donor `mean_sat` 0.545–0.588 vs ours 0.656–0.678: our olive is systematically more
  saturated; mean B is 21.1 in W0 vs 31.0–34.3 in donor (direction cue only, different scenes).
- W23 `bv32` 22.9 and `max_row_diff` 30.2 are driven by **one discontinuity** — the pale prop
  base — not by organic relief; W0's `dark<32 = 0.0995` is driven by the stepped dark bands.

### 3.3 Targeted probes (each in that image's own pixel coordinates)

| Probe | Result | Read |
|---|---|---|
| D120 golden field, crop `(474,122,844,332)` | mean RGB 82.94, 78.14, 30.61; grad 20.043; `gold_like` 0.2565; `green_dom` 0.1652 | [O] legible golden parcel with dense fine texture |
| D600 forest/rock, crop `(300,30,800,320)` | mean RGB 73.00, 71.29, 31.39; grad 8.088; `green_dom` 0.4674 | [O] conifer groves + grey boulder cluster share the frame |
| D1800 mine/field, crop `(250,220,800,470)` | mean RGB 85.98, 76.58, 34.79; grad 17.235; `gold_like` 0.2249 | [O] mine dome embedded in gold stubble, no pale plinth |
| W0 banded relief, `(520,430,1240,680)` | mean RGB 48.94, 52.73, 20.02; luma<32 **0.4211** | [O] hard dark terraces dominate ~42% of this ROI |
| W0 dark trees, `(80,370,520,560)` | mean RGB 72.26, 74.97, 20.87; `bv32` 3.375 | [O] thin near-black stick trees, almost no body shade |
| W23 pale base + mesh, `(790,280,1175,470)` | mean RGB **139.66, 134.86, 113.07**; luma 134.31; sat 0.2251 | [O] neutral pale base, unlike any ground in donor panels |
| W23 pure base strip, `(800,440,1160,468)` | mean RGB **160.93, 154.90, 136.20**; luma 154.83; sat 0.1569; grad 0.74 | [O] flat, featureless, near-white plane (BV32 not computed: strip <32 px tall) |
| W23 plain ground, `(200,250,700,600)` | mean RGB 73.08, 75.85, 20.62; luma std **3.04**; `e40` 0 | [O] near-uniform olive carpet with 1–2 px stipple only |
| Most uniform 64×64 donor patch (full crop sweep) | D120 std 2.881, D600 std 1.539, D1800 std 1.775 | [D] local uniformity itself is *not* the defect; the defect is the absence of larger-scale mottling/props/shadows and the hard base edge |
| 64px two-scale split on clean ROI (block-mean std / within-block std) | D120 10.15/19.34; D600 11.77/15.41; D1800 7.79/12.50; W0 8.25/8.17; W23 20.63/6.51 | [D] donor local detail 12.5–19.3 vs ours 6.5–8.2; W23's large-scale number is the pale plane, not relief |

---

## 4. Ten concrete visual differences

Every row is a direct visual read `[O]` of the contact sheet or a deterministic pixel statement
`[D]`; "direction" means it is a reference observation, not a matched-camera comparison.

| # | Difference (priority order) | Donor reference observation | Our wide2 observation | Label / caveat |
|---:|---|---|---|---|
| 1 | **White square prop bases** | None of D120/D600/D1800 shows a pale rectangular plinth under a rock, mine or building; props meet grass/field directly. Clean-ROI `pale_low_sat` 0.0138–0.0374 (stonework, HUD-adjacent bright pixels). | W23: a large flat beige plane (pure strip RGB 160.9/154.9/136.2, luma 154.8, sat 0.157, grad 0.74) under a grey relief mesh, plus a second partial plane at the top edge. Clean-ROI `pale_low_sat` **0.1212** (≈3–8× donor). | `[O]/[D]`. Highest-priority blocker; consistent with HANDOFF §9.10 line 264. Cause is `[I]` (likely unbound MTL/albedo or default material on `terrainmesh*`), not proven here. |
| 2 | **Dark prop albedo / silhouette bodies** | Trees in D600 have lit green crowns, shaded sides and long dark ground shadows; castle stone in D120/D1800 reads grey with structure. Donor clean `dark<32` 0.0248–0.0560. | W0 trees are thin near-black sticks with no crown mass; stepped bands reach `dark<32` 0.4211 in the banded ROI; clean ROI `dark<32` 0.0995. No readable stone/decor in either panel. | `[O]/[D]`. Consistent with W07 §4 (missing/shaded material path) and HANDOFF line 264. No runtime material dump was taken here. |
| 3 | **Ground texture scale / uniformity** | Continuous mottled carpet: grass tufts, small stones, soft shadow patches at ~5–100 px; visible multi-scale variation even where no prop is present. Within-block luma std 12.5–19.3. | 1–2 px olive stipple with almost no mid-scale structure; plain-ground patch luma std **3.04**, `e40 = 0`, within-block std 6.5–8.2. | `[O]/[D]`. Donor JPEG adds grain, but the missing mid-scale content is a visible, independent read. `uv_repeat=1.0 + LOD inset` is reported landed (HANDOFF line 265) but has not produced donor-like scale at 58 m. |
| 4 | **Field presence** | D120 and D1800 contain a large, sharp-edged golden diamond field wrapped around a stone windmill/mine; field ROI `gold_like` 0.2565 / 0.2249, and `green_dom` drops to 0.1652. | No golden parcel in W0 or W23: clean-ROI `gold_like` 0.0000 / 0.0002; `green_dom` 0.99 / 0.88. | `[O]/[D]`. Different world areas by design, so this is "field class not visible in this pan", not "field missing from the build". W07 §3.3: mill-field hook has no caller — a separate script-sown path. |
| 5 | **Forest density and grounding** | D600 shows several dense conifer groves plus scattered individuals; trees have crowns, contact shadows and irregular spacing. | W0 has only a handful of isolated dark vertical sticks; W23 has essentially none in the central view. No visible long shadows. | `[O]`, directional. Scene-dependent count is not a gate; the *form* difference (silhouette stick vs shaded crown + shadow) is the actionable part. |
| 6 | **Rock / mine integration** | D600 boulders are a clustered grey mass sitting on grass with contact shading; D1800 mine dome sits inside the golden field with no plinth. | W23 relief mesh sits on a hard-edged quad with a straight horizon line; its `max_row_diff` 30.239 is that rectangle edge, not terrain shape. | `[O]/[D]`. No claim that the donor mesh or mine model is the same asset. |
| 7 | **Camera height / FOV / apparent scale** | Donor frames are close skirmish views: castles and conifers occupy a large share of the viewport; individual trees are tens of pixels tall in a 498 px crop. Camera values unknown `[U]`. | Candidate is the widest donor-legal pan: 58 m, FOV 17.27°, pitch −32°, zoom 0.3448. Trees and props are only a few percent of 720 px; large areas read as empty carpet. | `[O]` candidate, `[U]` donor. **Direction only**: different scenes and zoom make any ratio a non-comparable cue. FOV itself is `PORT APPROXIMATION` per W05 §3. |
| 8 | **Relief shape: terraces vs rolling ground** | Donor ground is continuous and softly rolling; no straight stair-step edges, diagonal bands or concentric rings in these three frames. | W0 has large rectilinear dark bands with sharp 90° steps (lower-centre, upper-left, right edges); W08 §2 names exactly these as forbidden artifacts. | `[O]`. The 240c baseline defect is still visible in `wide2` frame 0. NO fix or cause asserted from image alone. |
| 9 | **Built decor / stone detail** | D120/D1800 show multi-tower stone castles and a windmill with readable masonry, windows and roofs; grey stone also appears in the D1800 lower-left. | Neither candidate panel shows a readable building; the wide framing contains mostly bare carpet, sticks and the one grey mesh on a plane. | `[O]`, directional. COORD must decide whether decor is simply outside this pan; image cannot distinguish absence-in-scene from absence-in-build. |
| 10 | **Lighting/contact shadows and hue balance** | Donor has long soft tree/prop shadows and a warmer, less saturated ground (sat 0.545–0.588, B 31.0–34.3); stone reads neutral grey. | No contact shadows under W23 mesh; HANDOFF line 265 reports shadows OFF. Our ground is greener/more saturated (sat 0.656–0.678; B 21.1 in W0); pale quad is near-neutral bright. | `[O]/[D]`. Lighting constants (1.4/2.0) reported landed; visual result in these frames still lacks contact shadow. |

---

## 5. Ranked fix list for FIX-PROP-MAT and FIX-SHADER2

These are **recommendations to the owning workers/COORD**, not changes made here and not gate
verdicts. Order is by visible impact in the two inspected candidate frames. "Verify" steps are
port-internal self-checks; none is a donor-parity check.

### FIX-PROP-MAT (prop material / base integration)

| Rank | Action | Evidence motivating it | Verify (port-internal) |
|---:|---|---|---|
| 1 | **Remove the pale rectangular prop plinth.** For every `terrainmesh1..4` / relief / mine batch, confirm the OBJ/MTL→albedo binding or an explicit `material_override`; reject any default white/untextured fallback. Check UVs on the converted relief meshes for an unwrapped/degenerate quad. | Difference 1; W23 pure base strip luma 154.8 vs ground ~71; clean pale fraction 0.1212. W07 §4.4 already flags "no material_override / no albedo verification" as a separate task. | After fix, re-shoot frame 23 at the pinned camera; `pale_low_sat` in the clean ROI must fall sharply and no straight base edge may be visible. No numeric donor threshold. |
| 2 | **Make prop albedo readable, not black or flat white.** Restore/verify the donor light-and-environment rig for the donor backend (W07 §4.1) and confirm imported PNG sidecars + `source_color` on prop materials; prefer donor albedo over invented tint. | Difference 2; W0 dark sticks and dark bands; HANDOFF line 264 "dark prop materials". | Props show crown/body shading and non-zero mid-tones in a fresh capture; `script_error_lines=0`; no black silhouette-only class. |
| 3 | **Integrate rocks/mine/relief with the ground surface.** Conform placement to the terrain surface, remove hard quad borders, and keep the mesh within its footprint; no floating plinth. | Difference 6; W23 `max_row_diff` 30.2 is the quad edge. | On the same pinned camera, the prop silhouette rises from continuous ground, not from a rectangle. |
| 4 | **Raise forest density and tree form toward groves with crowns and irregular spacing**, using the donor conifer albedo; keep long ground shadows where a shadow decision allows. | Difference 5; D600 groves vs W0 sticks. | Fresh wide pan contains clustered, shaded trees rather than isolated black verticals; count is a visual read, not a threshold. |
| 5 | **Wire the script-sown mill-field hook separately** (W07 §3.3: `mill_field_hook()` returns `hook_only:true`, no caller) so a golden L/rectangle parcel plus windmill becomes visible on a field-bearing map. | Difference 4; donor field ROI `gold_like` ≈0.23–0.26 vs ours ≈0. | Non-zero, legible golden footprint with a boundary; no golden noise sprayed over relief steps. |
| 6 | **Re-decide shadows/lighting energy with COORD** (reported 1.4/2.0, shadows OFF). Donor frames show contact shadows; these are part of what makes props look grounded. | Difference 10. | A fresh capture shows contact shadows under trees/props without crushed blacks; no new invented light constants. |

### FIX-SHADER2 (ground shader / tile art)

| Rank | Action | Evidence motivating it | Verify (port-internal) |
|---:|---|---|---|
| 1 | **Eliminate the hard dark stepped bands in frame 0 at their source** — height/normal or tile-id discontinuity — without synthetic noise/dither, face promotion, HEIGHT_SCALE fudge or lowered gates (charter §2, W08 §2). | Difference 8; W0 banded ROI `dark<32` 0.4211, rectilinear 90° steps. | Re-shoot the same wide path; no terraces/bands/rings at the pinned camera. A green metric cannot erase a visible band. |
| 2 | **Correct the ground hue/saturation toward the donor direction** (less oversaturated olive, slightly more blue in the ground channel) using donor-derived tile colours only. | §3.2: sat 0.656–0.678 ours vs 0.545–0.588 donor; B 21.1 vs 31–34. | Same fractional clean ROI before/after; report mean RGB and sat as support cues, never a donor-match claim. |
| 3 | **Fix texture scale at the shipped 58 m camera.** The reported `uv_repeat = 1.0` + LOD inset has not produced donor-like mid-scale mottling: plain-ground luma std 3.04, `e40 = 0`. Tune tile art / mip LOD from donor tile vectors, not random noise. | Difference 3; two-scale split 6.5–8.2 vs 12.5–19.3. | Mid-scale variation becomes visible without stipple aliasing or a repeating grid; no synthetic texture injected. |
| 4 | **Keep relief soft under parallax.** After rank 1, re-run the 24-frame wide pan and check frames 0 and 23 plus intermediates for shimmer/reappearing steps. | W05 §7.3 wide240 read requirement. | Candidate self-consistency across the sequence only (candidate-vs-candidate determinism); never donor-vs-candidate. |
| 5 | **Recapture a before/after self-A/B at the pinned camera** and let the reviewer record visual and metric fields separately (W08 §1/§5). No donor still is promoted into an A/B. | W08 §4 I11; charter §1 goal 4. | 1280×720 non-blank, `script_error_lines=0`, identical fractional ROI, `parity.claim=NONE`. |

**Explicitly out of scope for these two tickets:** no donor binary execution, no donor constant
invention, no gate change, no `app/**` edit, no Godot launch by this worker.

---

## 6. What this report does **not** establish

| Item | Status | Why / what would settle it |
|---|---|---|
| Donor camera height / FOV / zoom / crop identity | `[U]` | Browser frames have no camera log; apparent scale is direction only. |
| Same scene / seed / world area between browser frames and wide2 | `[U]` | Three different skirmish moments vs one pinned 240² pan; no matched manifest. |
| Donor parity, similarity score, threshold or gate PASS | `[U]` — **NO CLAIM** | W08 §1 / W05 §7.2 forbid it; no donor GPU A/B frame exists. |
| Cause of the pale quad (unbound MTL, UV, default material, or other) | `[I]` only | Image shows the symptom; no node/material dump or runtime log was captured. |
| Whether fields/decor are absent from the build or simply outside this pan | `[U]` | Need a dump-selected `feature240` capture and a node census. |
| Runtime `props_total`, `matched_stamps`, lighting rig values | `[U]` | No Godot job was run; HANDOFF §9.10 fix facts are COORD-supplied, not re-derived here. |

---

## 7. Multiple-pass register (charter §2)

| Pass | Instrument | Result |
|---:|---|---|
| P1 | Direct full-frame view of all three browser JPEGs | Identified YouTube chrome, video rectangle, and the three distinct skirmish compositions. |
| P2 | Row/column luma scan of D120 | First crop detector overreached into the sidebar (933×563); **rejected as wrong**. |
| P3 | Revised contiguous-run detector on all three JPEGs | Identical crop `(17,68,901,566)` = 884×498; re-checked by direct view of the contact sheet. |
| P4 | Direct view of both wide2 PNGs | Frame 0 dark rectilinear bands + sparse dark sticks; frame 23 grey mesh on pale quad. |
| P5 | Full-viewport metrics, all five images | HUD/subtitle contamination visible in `max_row_diff`; retained only as flagged lower-confidence row. |
| P6 | Identical clean fractional ROI `.12,.08,.81,.68`, all five images | Used as the primary metric ROI; no ROI was moved to improve a number. |
| P7 | Targeted ROIs on field, forest/rock, mine, dark bands, pale base, plain ground | Confirmed each visual read with a separate local probe. |
| P8 | Sweep for the most uniform 64×64 donor patches | Prevented an overclaim that donor ground is uniformly higher-variance; defect reframed as missing mid-scale structure + hard base edge. |
| P9 | 64px two-scale decomposition on clean ROI | Separated "large-scale discontinuity" (W23 quad) from "local detail" (donor 12.5–19.3 vs ours 6.5–8.2). |
| P10 | `capture.json` read for frames 0/23 | Camera height/FOV/pitch/zoom/source confirmed as candidate facts only. |
| P11 | Second visual pass of the finished contact sheet | Labels legible; no panel mislabelled; pale quad and dark bands visible at sheet scale. |

No anomaly was accepted from a single reading. No ambient process was started, no donor file
executed, no repo artifact other than this report written.

---

## 8. Claim register

| # | Claim | Source | Label |
|---:|---|---|---|
| 1 | Video viewport crop is `(17,68,901,566)` for all three donor frames | P2/P3 pixel scans + direct view | `[O]` |
| 2 | Candidate camera is 58 m / 17.27° / −32° / zoom 0.3448 | `capture.json` frames 0 and 23 | `[O]` |
| 3 | W23 contains a flat pale quad under a grey mesh; donor frames show none | P4/P7 + §3.3 probes | `[O]` |
| 4 | W0 contains hard dark stepped bands | P4/P7; banded ROI `dark<32` 0.4211 | `[O]/[D]` |
| 5 | Fields, shaded groves and integrated boulders/mine are visible in donor frames, not in these two candidate pans | direct view + `gold_like`/`green_dom`/`grad` cues | `[O]` directional |
| 6 | All metrics are support cues; donor JPEG compression inflates edges | W08 §1, X36 §1 as cited there | `[D]` |
| 7 | Quad cause (material/UV/default fallback) is a hypothesis | visual symptom + W07 §4.4 context | `[I]` |
| 8 | Donor camera and build identity unknown | no donor camera log | `[U]` |
| 9 | **No donor parity claim; parity UNVERIFIED** | §0 guard, §6, W08 §5 | `[U]` |

---

## 9. Handoff to COORD

1. **FIX-PROP-MAT P0:** kill the pale plinth and verify albedo/material binding for every
   relief/mine/stone/forest batch (§5 ranks 1–2). This is the single largest visible defect in
   frame 23.
2. **FIX-SHADER2 P0:** remove the rectilinear dark terraces in frame 0 at the height/tile/normal
   source; do not mask them with noise or a scale fudge (§5 rank 1).
3. **Capture owner:** re-run the same 24-frame wide path after each fix; compare candidate to
   candidate at the pinned camera and keep `parity.status = UNVERIFIED`.
4. **COORD decision:** shadows are reported OFF; donor references show contact shadows. Decide
   deliberately rather than leaving it implicit.
5. **feature240:** because fields/forest/mine are absent from these two pans, a dump-selected
   feature shot is required before any class-level visual verdict.

*End of COMPARE-BROWSER. Exactly one repo file written; browser JPEGs, wide2 PNGs and capture
metadata read only; no code/shader/config/asset/test/result/git/Godot/donor change; no donor
A/B frame, no cross-image score, no donor parity claim.*
