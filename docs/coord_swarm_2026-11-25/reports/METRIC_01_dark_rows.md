---
id: METRIC-01
title: "P0 full_width_dark_rows=720 — genuine defect or harness/camera artifact?"
owner: METRIC-01 (harness-analysis micro-worker)
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_RUNNER_JOB__NO_EDIT_EXCEPT_THIS_REPORT
scope: "Read-only analysis of TEST-RUN-02 job 404 (P0) capture, the dark-row metric definition, and the P0 camera/terrain code. No code, shader, test, atom, config, fixture, gate file or other report was edited; no Godot job was submitted."
owns:
  - "docs/coord_swarm_2026-11-25/reports/METRIC_01_dark_rows.md"
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
labels: [observed, derived, inferred, UNVERIFIED]
evidence_labels: [observed, derived, inferred, UNVERIFIED]
verdict: METRIC_ARTIFACT
related:
  - "TEST-RUN-02 (job 404): docs/coord_swarm_2026-11-25/reports/TEST_RUN_02_ladder_log.md:60-62,110-142,202-229"
  - "PIXEL-01 (sibling): independent visual review of the same PNG — not performed here"
parity_guard: "No donor GPU A/B exists; no donor-parity claim is made."
---

# METRIC-01 — is P0's `full_width_dark_rows=720` a defect?

## 0. Question and sources

Decide whether the single failing check in TEST-RUN-02's P0 row
(`full_width_dark_rows=720`, expected 0) is a genuine render defect or a
harness/camera artifact of applying a water-band metric to a water-free frame.

Sources read read-only this pass:

| Source | Used for |
|---|---|
| `variant3d/tools/smallmap_capture.py:21-39` | exact PNG metric definition (luma, non-black, dark rows) |
| `variant3d/tests/t_terrain_only.gd:61-62,340-391,483-490,635-669` | P0 fixture, water hiding, in-GPU metric mirror, camera pose, assertion |
| `variant3d/tests/results/t_terrain_only.json:1-188` | observed P0 checks and `measured` values |
| `docs/coord_swarm_2026-11-24/reports/TERRAIN_SMALL_maps.md:27-29,101-121,138-148,160-170` | origin and meaning of the dark-band observation |
| `docs/coord_swarm_2026-11-25/reports/V3D_02_terrain_render_audit.md:88-92,117-153` | P6/P7 problem entries, F6 acceptance, T0/T2 ladder criteria |
| `docs/coord_swarm_2026-11-25/reports/DTRN_03_donor_shore_water.md:131,393-401,476-488` | water-band defect W2/M5 scope (terrain+shore, not terrain-only) |
| `docs/coord_swarm_2026-11-25/reports/TEST_P0_report.md:97-98,176-188` | author's assertion basis and visual UNVERIFIED expectation |
| `docs/coord_swarm_2026-11-25/reports/TEST_RUN_02_ladder_log.md:60-62,110-142,202-229,272-286` | job 404 numbers, stderr, open questions |
| `docs/coord_swarm_2026-11-25/TEST_MATRIX.md:18,29-46,53-75` | ladder criteria; "never weaken an assertion to obtain green" (:67-68) |
| `variant3d/scripts/camera3d.gd:88,122-123,171-220,245-275` and `variant3d/scripts/data.gd:23,113-114,165-167` | camera height, pitch, FOV, map half-extent — framing derivation |
| `variant3d/scripts/world3d_terrain.gd:93-95,540-582,664-729,925-984` | mesh extent, material, sky/sun rig, water plane |
| `variant3d/shaders/terrain_tileindex.gdshader:43,151-159,269-319,415-464`, `variant3d/assets/terrain/blocks/grass1.png` | current olive tile shader inputs and tile art colour |

---

## 1. Exactly what `full_width_dark_rows` counts — and its threshold

**Observed (code read, verification pass 1).**

- `variant3d/tools/smallmap_capture.py:24` converts the PNG to float32 RGB
  in 0..255; `:25` computes `luma = 0.2126*R + 0.7152*G + 0.0722*B`;
  `:26` defines `non_black_fraction` as the mean of `any(channel > 8.0)`;
  `:27-28` defines the metric verbatim:

  ```
  # Full-width dark bands: rows where >90% of pixels have luma < 20.
  dark_rows = int(((luma < 20.0).mean(axis=1) > 0.90).sum())
  ```

- `variant3d/tools/smallmap_capture.py:37-38` reports the integer count and
  `dark_rows / image_height`.
- The P0 atom mirrors this in GDScript at
  `variant3d/tests/t_terrain_only.gd:363-391` (same luma coefficients, same
  `l < 20.0`, same per-row `row_dark / width > 0.90`) and asserts
  `int(ms["full_width_dark_rows"]) == 0` at `:666-667`.
- The atom's own justification string is
  `"expected 0; smallmap_capture.py:27-28"` (`t_terrain_only.gd:667`), and the
  author recorded the same basis in `TEST_P0_report.md:98`.

**Interpretation (derived).** The metric is a **whole-row uniformity detector**:
it does not ask what the dark pixels *are*. A row qualifies when more than
90% of its 1280 pixels have luma below 20, regardless of whether those pixels
are water, shadow, night, dark ground, or a deliberately dark test fixture.
For a 720-row image, the maximum possible count is 720, so the observed value
means **every one of the 720 rows satisfied the row predicate**.

**Design intent (observed, from the governing docs).**

- `TERRAIN_SMALL_maps.md:27-29` attributes dark bands in the earlier full-game
  capture to **height-driven water fields**, explicitly *not* shadows, and
  `:160-165` repeats that attribution; `:166-170` reports that the *unbounded
  shadow streak* regression gate measured **0** dark rows there.
- `V3D_02:91` (P6) names the symptom "Dark horizontal/diagonal bands across
  the ground" and the cause "Height-aware water fields, not shadows";
  `V3D_02:129` (F6) sets the acceptance "Full-width dark rows = 0" for a
  **water** fix; `V3D_02:144` (T0) lists "no full-width dark rows" among many
  P0 criteria, while `V3D_02:146` (T2, terrain+shore) repeats the same gate
  where water is actually present.
- `DTRN_03:131` (C30) and `:396` (W2) tie the dark/green row artifact to
  **water cells clamped to `grass1`**; its metric M5 at `:484` is explicitly
  "**0 full-width dark/green rows; no water pixel showing `grass1` substrate
  — compare T0 (terrain only) with T2**". That is a T0-vs-T2 difference test,
  not a claim that a water-free T0 frame must be bright.
- `TEST_P0_report.md:184-187` itself says the author never ran the atom and
  that zero dark rows was only "*plausible*" for water hidden + all-grass
  tileblock — explicitly UNVERIFIED, not a promised property.

**Conclusion (derived).** The predicate was introduced to catch **water
bands / water-on-grass tint** (`V3D_02` P6/F6, `DTRN_03` W2/M5). It has no
clause that verifies the presence of water pixels before firing, so it is
**inapplicable by construction** to a frame in which the water plane is
deliberately hidden and there are no water cells.

---

## 2. Expected P0 camera framing — is every row geometrically ground?

**Observed (P0 code).**

- The atom creates a synthetic 64×64 grid: `height[i] = 1.5 + 0.03*sin + 0.02*cos`
  (≈1.45–1.55 m), `tileblock[i] = 0` (grass1), `res_nodes = []`
  (`t_terrain_only.gd:259-268`, `TEST_P0_report.md:55-59`).
- `no_water_cells` and `no_water_tileblock` are checked as 0
  (`t_terrain_only.gd:553-570`); the recorded values are 0/0
  (`t_terrain_only.json:142,176`).
- The one module-created `WaterPlane` and `Water3D` node are set invisible
  (`t_terrain_only.gd:340-358`, `:608`), recorded as `water_plane_count=1`,
  `all_hidden=true` (`t_terrain_only.json:101-104,173-175`).
- The capture viewport is 1280×720 (`t_terrain_only.gd:61,431-436`); the camera
  is a real `camera3d.gd` bound to the stub, its `_process()` disabled and
  `make_current()` called (`:483-490`).
- `world3d_terrain.gd` builds **one** full-grid indexed mesh: vertices
  `(x+0.5-w/2)*TILE_M, height[i], (z+0.5-h/2)*TILE_M` with `TILE_M=2.0`
  (`data.gd:23`), i.e. a 128 m × 128 m quad centred on the origin; verified
  here as 1 surface / 4,096 verts / 7,938 tris (`t_terrain_only.json:150-151`,
  `V3D_02:67`).

**Derived (camera arithmetic, verification pass 2).**

1. `camera3d.gd:171-220`: `bind()` sets `PROJECTION_PERSPECTIVE`, `fov =
   FOV_DEG_ASSUMED` = **17.27°** (`:88,176`), `near=0.1`, `far=4096`,
   `zoom_target = 1` (`:203-206`), `height_target = height =
   sqrt(20*58) ≈ 34.0588 m` (`:208-209,122-123,232-234`), and `_target =
   _map_half()` (`:215`). For the stub, `_map_half()` = `(64,64)*2*0.5 =
   (64,64) m` (`:245-252`), so `base = _target - half = (0,0,0)` — the **map
   centre**, not a corner.
2. `camera3d.gd:255-275` with `data.gd:165` `CAMERA_PITCH = -32°`:
   `back = h*cos(32°)/sin(32°) = h/tan(32°) ≈ 54.505 m`;
   eye `= (0, 34.0588, 54.505)`, looking at `(0,0,0)`.
3. Vertical half-FOV = 8.635°; horizontal half-FOV =
   `atan(tan(8.635°)*(1280/720)) ≈ 15.108°`. Top-of-frame ray is 23.365°
   below horizontal: reaches the ground 78.837 m from the eye, at world
   `z ≈ -24.33 m`, half-width `≈ 21.28 m`. Bottom-of-frame ray is 40.635°
   below horizontal: reaches ground 39.688 m from the eye, at `z ≈ +14.82 m`,
   half-width `≈ 10.72 m`.
4. Both extents are comfortably inside the mesh footprint `x,z ∈ [-64,+64] m`
   (the measured 1.45–1.55 m ground height shifts the hits only a few metres).
   **Therefore, under the intended transform, every screen ray hits the
   terrain mesh: the whole 720-row frame is ground, with no horizon, sky,
   off-map edge, water or entity.** With tile id 0 everywhere and water hidden,
   "dark row" is just a row of dark ground.

**UNVERIFIED caveat (does not change the verdict).** The runner's `stderr.txt`
records two transform errors at bind time — `Condition "!is_inside_tree()"` at
`camera3d.gd:274` and `Node not inside tree. Use look_at_from_position()` at
`:275`, called from `bind()` `:220` and `t_terrain_only.gd:486`
(`TEST_RUN_02_ladder_log.md:172-183`, open question 3 at `:283-286`). The
camera is added to the SubViewport before `bind()` (`t_terrain_only.gd:483-486`),
but during `_initialize()` tree membership may not yet be effective. Whether
the intended transform was actually applied at capture time is **UNVERIFIED**;
it needs a runtime camera-pose probe, not an inference from this metric.
The recorded pixels, however, are *consistent* with a fully ground-covered
frame (§3) and *inconsistent* with a water band.

---

## 3. Are the recorded pixel numbers consistent with ground-only render?

**Observed (artifacts; verification pass 3 — independent read of the PNG).**

- Re-running the read-only inspector on the exact PNG
  (`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\test01_ladder2\smallmap64_terrain_only.png`)
  reproduced `bytes=988242`, `1280×720`, `non_black_fraction=0.992807`,
  `mean_rgb=[14.045,14.381,0.001]`, `mean_luma=13.271`,
  `full_width_dark_rows=720`, fraction 1.0 — identical to
  `TEST_RUN_02_ladder_log.md:118-137`. The atom's in-GPU value
  `non_black_fraction=0.9937467` (`t_terrain_only.json:119,158`) differs by
  ~0.00094, consistent with float-vs-8-bit PNG quantisation at the `>8`
  cutoff; both clear the >0.9 gate.
- Independent pixel distribution (Pillow/NumPy, read-only):
  luma min/median/mean/max = **0.0 / 12.99 / 13.27 / 28.41**;
  99.73% of pixels have luma <20, 100% have luma <30;
  row-mean luma at y=0/180/360/540/719 = 13.16/13.31/13.38/12.69/13.59;
  row fraction <20 at those rows = 99.69/99.77/99.53/99.92/99.61%.
  Blue channel max is 3. There is **no bright band, no horizon, no dark-vs-bright
  row transition** — the frame is uniformly dark olive from top to bottom.
  This directly explains 720/720 rows without invoking any water anomaly.

**Derived (arithmetic on recorded numbers).**

- Recomputing the metric's own luma from `mean_rgb`:
  `0.2126*14.045 + 0.7152*14.381 + 0.0722*0.001 = 13.2713`, matching the
  recorded `mean_luma=13.271` to three decimals. The recorded numbers are
  internally coherent, not a corrupted stats read.
- `720/720 = 1.000000`, matching `full_width_dark_row_fraction=1.0`; and with
  99.73% of pixels globally below 20 and each sampled row at 99.5–99.9% below
  20, the `>0.90` per-row predicate fires on every row. **Verified twice
  (code definition + arithmetic), plus a third independent PNG re-read.**

**Inferred (shader/colour consistency).**

- The active tile shader is `render_mode blend_mix, unshaded, cull_disabled`
  (`terrain_tileindex.gdshader:43`), computes `rgb = rgb * (ambient + diffuse)
  + specular` (`:294-299,415-417`) with `ambient_rgb ≈ (0.196,0.184,0.129)`,
  `diffuse_rgb ≈ (0.812,0.780,0.694)`, `specular_rgb = 0` (`:151-159`), and
  writes `ALBEDO=rgb`, `ALPHA=mix(1,a,mask_to_alpha)` with shipped
  `mask_to_alpha=1.0` (`:232-241,462-464`). The P0 material binds all three
  samplers, atlas `(16,8)`, `shadow_enabled=0`, fog off
  (`world3d_terrain.gd:540-582`; `t_terrain_only.json:83-98`).
- The all-grass tile art is itself olive/dark: `grass1.png` measured mean RGB
  `[76.01, 82.46, 30.39]` (1024², read-only). Olive R≈G, blue≈0 in the capture
  is exactly the signature of that art multiplied by the shader's warm
  ambient/diffuse product and the mask alpha blend. `V3D_02:88` (P3) already
  records "flat, dark olive ground" as a **known active port gap**, and
  `:92` (P7) records that the shipped mask-alpha blend *darkens* the frame
  when no bright sky is behind it (measured luma 42.735 → 38.425).
- The earlier full-game 64² capture had `mean_luma=44.181`, `mean_rgb≈
  [42.9,46.5,25.7]` and **0** dark rows (`TERRAIN_SMALL_maps.md:138-142`);
  that frame included water, entities, and the full main/sky composition.
  P0 is a stub, water-hidden, all-grass frame with a private SubViewport
  (`t_terrain_only.gd:429-437,469-490`) — **not** a controlled A/B against it.
  The absolute brightness difference is a separate visual-quality question,
  not evidence that this frame contains a water band.

---

## 4. Verdict

> **METRIC_ARTIFACT** — with an UNVERIFIED camera-pose caveat and no donor-parity claim.

Grounds, each labelled:

1. **Observed** — the metric only tests row-wise luma<20 prevalence
   (`smallmap_capture.py:25-28`; GDScript mirror `t_terrain_only.gd:363-391`).
   It does not detect water, alpha, tile id or depth; a water-free dark ground
   frame trips it identically.
2. **Derived** — P0 deliberately removes the phenomenon the metric was built
   for (`no_water_cells=0`, `no_water_tileblock=0`, `water_plane_hidden=true`;
   `t_terrain_only.json:101-104,142,173-176`). The metric's documented purpose
   is water bands (`TERRAIN_SMALL_maps.md:27-29,160-165`; `V3D_02:91,129`;
   `DTRN_03:131,396,484`).
3. **Derived** — from the code-specified camera (centre focus, height
   √1160 m, pitch −32°, V-FOV 17.27°, 1280×720, 128 m square mesh), the entire
   frame is ground (§2), so "every row dark" is the *expected* topology of a
   ground-only frame when the ground is darker than luma 20.
4. **Observed** — the PNG is ~99.28% non-black, uniformly olive, with **no
   row-level contrast** (§3), i.e. a rendered dark ground field, not a blank
   capture and not a water band. All 20 other checks pass
   (`t_terrain_only.json:131,179-180`); `SCRIPT ERROR == 0`
   (`TEST_RUN_02_ladder_log.md:144-163`).
5. **Inferred** — the most likely reason P0 is darker than the earlier full
   capture is the combination of all-grass tile art, the unshaded warm-lit
   tile shader with mask-alpha over a stub viewport, and the absence of the
   full main/sky/water composition — not a terrain geometry or atlas failure.

**Not a genuine defect in this ticket's scope:** no owner file among the P0
structural checks is implicated. There is **no evidence** that
`world3d_terrain.gd`, the shader, the atlas or `camera3d.gd` regressed *in the
sense this check asserts*. The camera bind-time errors
(`TEST_RUN_02_ladder_log.md:172-183`) are a **separate, UNVERIFIED harness/camera
concern** and are not the failing check.

**Explicitly not claimed:** that P0 is visually PASS. `TEST_MATRIX.md:59,75`
still requires a second-agent visual re-check (PIXEL-01, sibling), and
`V3D_02 parity_guard` forbids a donor claim. This verdict only says the
`full_width_dark_rows==0` gate is the wrong instrument for a water-free frame.

---

## 5. Routing recommendation — separate ticket, no atom edit here

**Route to COORD / the P0 atom + harness owner as a NEW, separate ticket.**
Suggested title: *"Scope the `full_width_dark_rows` gate to water-bearing rows
(or record-only for terrain-only P0)"*. This worker did **not** edit
`t_terrain_only.gd`, `smallmap_capture.py`, any result JSON, or any gate file.

Exact minimal correction to propose (choose one, with COORD approval — do not
silently weaken an assertion; `TEST_MATRIX.md:67-68`):

1. **Preferred — scope, don't delete.** In `t_terrain_only.gd:666-667`, make the
   hard assertion conditional on a water layer actually being present in the
   frame, e.g. assert only when the `WaterPlane`/`Water3D` node is visible or
   the tileblock contains water ids; otherwise record the value into
   `measured.png_metrics` with status `RECORDED_NOT_APPLICABLE` and keep the
   P0 result dependent on the other 20 checks and on PIXEL-01's visual review.
   Keep `smallmap_capture.py:27-28` **unchanged** (it is a generic inspector).
2. **Alternative — move the gate to the water row.** Drop the strict `==0`
   assertion from T0/P0 and enforce it in the T2/P2 (terrain+shore) atom, where
   `V3D_02:146`, `DTRN_03:484` and `TEST_MATRIX.md:42` already require it.
   Pair it with a T0-vs-T2 region subtraction so a *new* dark row caused by
   water tint is still caught.
3. **Add (do not substitute) a framing/visibility probe** for P0: log the
   bound camera's `global_position`, forward vector and `get_view_rect()`
   after `bind()` to resolve the `!is_inside_tree()` errors at bind time
   (`TEST_RUN_02_ladder_log.md:172-183,283-286`). This is a separate
   camera/harness ticket; it must not be conflated with relaxing the metric.

`TEST_RUN_02`'s stop rule was followed correctly (no rerun, no weakening): the
ladder cannot advance until COORD resolves this ticket. If PIXEL-01's visual
review independently finds a blank, sky-only, or genuinely water-banded PNG,
reopen this verdict as `UNDETERMINED` and route to the implicated owner with
that new evidence.

---

## 6. Open questions / UNVERIFIED

1. **Actual camera transform at capture time** — bind-time `!is_inside_tree()`
   errors (`TEST_RUN_02_ladder_log.md:172-183`); intended pose derived in §2 but
   runtime pose **UNVERIFIED**. Needs a read-only runtime probe, not a rerun of
   the failing row.
2. **Why luma ≈13 vs 44 in the earlier full capture** — plausible causes listed
   in §3; no controlled A/B exists (no donor frame, and the two pipelines
   differ). Absolute brightness quality is a separate open visual question.
3. **Visual re-check** — PIXEL-01 (sibling) is reviewing the same PNG; this
   report does not substitute for `TEST_MATRIX.md:59,75`.
4. **Row-level dark-band contrast in water rows** — whether the corrected gate
   should use `>90%` luma<20 (current) or a depth/alpha-based predicate from
   `DTRN_03` §6 is a design decision for the new ticket.
5. **Donor parity** — remains UNVERIFIED everywhere (`V3D_02 parity_guard`);
   `mean_rgb=[14,14,0]` is not compared to any donor frame here.
6. **Synthetic fixture vs real 64² boot** — P0 uses in-memory all-grass data,
   not `small_map_64.json` (`TEST_P0_report.md:55-59`); no donor ground colour
   claim can be derived from it.

---

## Summary

- `full_width_dark_rows` counts rows where >90% of pixels have luma <20
  (`smallmap_capture.py:25-28`); it is a Water-band / shadow-band detector, not
  a ground-validity test (`V3D_02:91,129`; `DTRN_03:484`).
- P0 by design hides the only water plane and contains zero water cells
  (`t_terrain_only.json:101-104,142,176`), while the code-specified camera sees
  nothing but the 128 m ground quad (§2).
- The recorded image is uniformly dark olive (`mean_rgb=[14.045,14.381,0.001]`,
  `mean_luma=13.271`, 99.73% of pixels <20) with ~99.28% non-black and no row
  contrast; the arithmetic reproduces both the mean luma and 720/720 (§3).
- **Verdict: METRIC_ARTIFACT** (camera-pose side issue UNVERIFIED). Route a
  minimal harness scoping fix as a **new ticket** to COORD / P0 harness owner;
  do not weaken an assertion inside the failing atom and do not edit the atom
  from this worker.

---

*End of METRIC-01. Read-only analysis: no code, shader, asset, config, test,
fixture, gate file, git state or runner job was touched; only this report was
written. No donor frame was accessed and no visual PASS is claimed.*
