---
id: TERRAIN-DARK-01
title: "Diagnosis — why the TEST-RUN-02 P0 terrain-only capture is uniformly near-black olive"
owner: TERRAIN-DARK-01 (read-only diagnosis micro-worker)
date: 2026-11-25
snapshot_at: "2026-11-25T10:37:57+01:00"
status: DELIVERED__READ_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB__NO_DONOR_COPY
scope: "Exactly one new report file. No .gd/.gdshader/asset/config/test/fixture/git edit; no Godot runner job; donor read only (no copy)."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
git_head: b1332b91
primary_evidence: "TEST-RUN-02 job 404 P0; C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\test01_ladder2\\smallmap64_terrain_only.png"
labels_used: [observed, derived, inferred, UNVERIFIED]
parity_claim: false
verdict: "AMBIENT-ONLY LIGHTING IS THE DOMINANT IDENTIFIED MECHANISM (a/e); ABSOLUTE 8-BIT LUMA RESIDUAL UNVERIFIED; CAUSE NOT PROVEN BY A GPU A/B"
---

# TERRAIN-DARK-01 — why P0 is a near-black olive field

## 0. Remit and discipline

This is a read-only diagnosis of the *cause* of the darkness, not a re-adjudication of the
`full_width_dark_rows` gate and not a visual review. The visual symptom is taken as given from
PIXEL-01 (`GENUINE_VISUAL_DEFECT`, `PIXEL_01_p0_capture_review.md:11,73-81`); the metric's
definition/scope is taken from METRIC-01 (`METRIC_01_dark_rows.md:47-104`) and the sibling
verification is noted without re-running it. No donor frame exists; **no donor parity is claimed**.
Every statement carries `observed` / `derived` / `inferred` / `UNVERIFIED`. Key claims were
checked twice (noted explicitly in §1 and §2).

## 1. Evidence snapshot (timestamped, read-only)

Snapshot time **2026-11-25T10:37:57+01:00**, `git HEAD = b1332b91`. Other builders have the tree
dirty (`config.gd`, `menu.gd`, `audio.gd`, `t_terrain_only.gd`, several docs); none of their edits
were touched by this worker. Live-file hashes/mtimes at snapshot:

| File (project-relative) | mtime | bytes | SHA-256 (first 16) |
|---|---|---:|---|
| `variant3d/shaders/terrain_tileindex.gdshader` | 2026-11-25 10:07:11 | 27,042 | `01C44B6EC3963D70F` |
| `variant3d/scripts/world3d_terrain.gd` | 2026-11-25 10:18:12 | 69,635 | `B4B965382F8E74550` |
| `variant3d/scripts/camera3d.gd` | 2026-11-25 10:24:17 | 40,155 | `893C2BA1BD6CC8AEC` |
| `variant3d/scripts/tile_atlas_loader.gd` | 2026-11-25 10:23:39 | 17,986 | `9B82A48DF4F8A7DD6` |
| `variant3d/assets/terrain/atlas/tile_index_atlas.manifest.json` | 2026-11-24 15:51:19 | 60,677 | `112E9FF5ED632DD3` |
| `variant3d/tools/smallmap_capture.py` | 2026-11-24 17:31:46 | 2,738 | `133B8CC5CA5162BC` |
| `variant3d/tests/t_terrain_only.gd` | 2026-11-25 09:41:41 | 25,913 | `912A6777E8759051` |
| `variant3d/tests/results/t_terrain_only.json` | 2026-11-25 10:24:21 | 5,243 | `80C93C18CF151DB1` |

- **observed** — job 404 artifacts (PNG, result JSON, stdout/stderr) were written 10:24:21–22;
  the shader hash equals the post-DALPHA-02 hash recorded at `DALPHA_02_patch_mapping.md:40`
  (`01C44B6E…E245D`) — **verification 1: report vs live hash; verification 2: DALPHA-02 §1 hash**.
  `world3d_terrain.gd`, `camera3d.gd` and the loader were written seconds before the capture;
  the snapshot is therefore effectively capture-time source, but a same-second concurrent edit
  cannot be excluded (UNVERIFIED).
- **observed (verified twice)** — `TEST_RUN_02_ladder_log.md:62,110-142,202-229` and the live
  `t_terrain_only.json:2,119-129,134-177` agree: `passed=false`, 20 pass / 1 fail
  (`full_width_dark_rows=720`), `capture_status=PASS`, `SCRIPT ERROR == 0`,
  `mean_luma=13.271`, `mean_rgb=[14.045,14.381,0.001]`, `non_black_fraction≈0.9937`
  (Python re-read 0.992807, `PIXEL_01:19`, `METRIC_01:170-188`). All structural checks pass:
  1 surface / 4,096 verts / 7,938 tris / 4,096 UV2 / atlas `(16,8)` / `shadow_enabled=0` /
  water hidden.
- **observed (verified twice)** — every cell is tile 0: `t_terrain_only.gd:61,266-275`
  (`GRASS_TILE := 0`, `_tileblock[i] = GRASS_TILE`) **and** `t_terrain_only.json:167-168`
  (`uv2_x_min = uv2_x_max = 0.0`). `t_terrain_only.json:170-172` gives `uv2_y_hist={"0":4096}`
  → all ground face mode.
- **observed (verified twice)** — atlas cell 0 is `grass1`:
  `tile_index_atlas.manifest.json:48-70` (`index 0`, `cell_xy [0,0]`, `source_png grass1.png`),
  and this worker's read-only Python check: `grass1.png` SHA-256
  `28e617b1…8019a` equals the manifest `source_sha256`; a crop of the 16384×8192 atlas cell
  `(0,0)` has mean RGB `[76.01, 82.46, 30.39]` (same as the block PNG). This also reproduces
  `METRIC_01:211-212`.
- **observed (verified twice)** — alpha patch `(0,0)` is constant 255: direct read of
  `assets/terrain/atlas/alpha.png` (512×256 L) gives `min=max=mean=255` over rows/cols 0..63,
  consistent with the inherited `DALPHA_01 §6.4` inference and with
  `DALPHA_02_patch_mapping.md:156-161` (sentinel patches are donor-authored roles).
- **observed** — donor `light.cfg:26-31` Position = `(-0.344731152057648, 0.938701450824738, 0, 1)`;
  `LightStyle=lsParallel` at `:17`. Donor shader `hf.pvl.sm.vert:13` uses
  `l = normalize(gl_LightSource[0].position.xyz - realpos.xyz)` (read-only latin-1 text this
  worker; nothing copied).

## 2. Mechanistic walk-through of the active path

All citations are to the snapshot files in §1.

1. `t_terrain_only.gd:266-275` builds a 64² flat tileblock of id 0; `world3d_terrain.gd` writes
   `UV2.x=0`, `UV2.y=0` (`t_terrain_only.json:167-172`). The shader reads `v_tile=UV2.x`,
   `v_face=UV2.y` (`terrain_tileindex.gdshader:317-318`).
2. `tile_rgb()` (`terrain_tileindex.gdshader:325-331`) maps id 0 → atlas cell `(0,0)` via
   `atlas_grid=(16,8)` and `fract(v_st*uv_repeat)` (`:304-309,385`). Cell 0 is `grass1`,
   mean `(76,82,30)` sRGB (§1). Because every cell has the same id, **there is nothing to draw a
   tile grid or seams with** — the frame's uniformity is a fixture property, not proof of atlas
   failure.
3. Alpha: `face==0` → `a = texture(alpha_atlas, alpha_patch_uv(v_tile, v_alpha_uv)).a`
   (`:389-413`). For `tile=0` the DALPHA-02 decomposition (`:358-371`;
   `DALPHA_02_patch_mapping.md:73-90`) yields `cell=(0,0)` — the constant-255 patch. The
   module repacks R→A without inversion (`world3d_terrain.gd:523-536`). Therefore
   **`a=1` and `ALPHA = mix(1,a,1) = 1`** (`:232-241,464`). No framebuffer darkening from the
   mask is possible in this specific frame.
4. Lighting: `sun_world = normalize(vec3(donor_sun_position.x/4, donor_sun_position.z/2,
   donor_sun_position.y))` (`:287-288`); the module binds the **raw** donor Position
   (`world3d_terrain.gd:137,562-565`). With donor Z=0 this gives
   `sun_world ≈ (-0.0915, 0.0, 0.9958)` — **Godot-Y component is exactly zero**. `l` is a
   constant view-space direction (`:289`); `n` is the flat ground normal in view space (`:291`).
   A rotation preserves dot products, so `dot(l,n) = dot(sun_world, world_up) = 0` for every
   camera pose and every pixel of this flat fixture. Hence
   `diffuse = 0` and `v_packed = ambient_rgb = (0.196,0.184,0.129)` (`:294-298`).
5. Specular is negligible: `specular_rgb` is bound to donor `(0.278,0.267,0.212)`
   (`world3d_terrain.gd:141,561`; correction to the shader's `vec3(0)` default at
   `terrain_tileindex.gdshader:157`), but `pow(dot(h,n),16)` with `dot(h,n)≈0.53` for a flat
   ground and a horizontal sun is ≈1.5e-5 (derived, camera-dependent; small for all
   reasonable poses).
6. Final combine `rgb = rgb*v_packed + v_specular` (`:417`) then `ALBEDO=rgb` (`:462`).

### Quantitative cross-check (derived; gamma path UNVERIFIED)

Using the measured atlas cell mean, sRGB-decoding the art, applying `v_packed`, then
sRGB-encoding for display:

| Lighting term | `v_packed` | predicted mean RGB | predicted mean luma |
|---|---|---:|---:|
| current donor-sun mapping (`dot(l,n)=0`) | `(0.196,0.184,0.129)` | `(31.6, 33.7, 5.7)` | 31.2 |
| sun mapped to Godot +Y (`dot(l,n)=1`) | `(1.008,0.965,0.824)` | `(76.3, 81.0, 26.9)` | 76.1 |
| old headlight (`dot≈0.53`) | `(0.626,0.598,0.497)` | `(60.1, 63.9, 19.2)` | 59.8 |
| **observed PNG** | — | **`(14.0, 14.4, 0.0)`** | **13.27** |

**Label: derived / UNVERIFIED.** The ~5× collapse of the lighting term from the intended
`ambient+diffuse` (~1.0) to `ambient` (~0.19) is solid arithmetic. The *absolute* 8-bit match is
not: the simple sRGB model predicts ~31 luma, not 13.27. The remaining ~2.3× factor depends on
Godot's SubViewport colour space / linear tonemap+exposure (`world3d_terrain.gd:149,951-952`)
and `get_texture().get_image().save_png()` readback (`t_terrain_only.gd:654-667`), which this
worker did not probe. **Do not claim the arithmetic explains every luma count.**

## 3. Ranked causal hypotheses

| Rank | Hypothesis | Label | Supporting evidence (`path:line`) | Refuting / limiting evidence |
|---:|---|---|---|---|
| **1** | **(a) `ALBEDO = tile_rgb*(ambient+diffuse)+specular` collapses to `tile_rgb*ambient` under the new donor-sun math.** | **derived mechanism; inferred visual attribution** | Shader `:287-299,417,462-464`; module binds raw donor Position `world3d_terrain.gd:137,562-565`; donor Position Z=0 (`light.cfg:26-31`); donor shader `hf.pvl.sm.vert:13` computes `l` from a light *position* (`TRN_SHADER:47-49` explicitly replaced this with a constant direction); olive art `(76,82,30)` §1; `V3D_02:88` (P3 "flat, dark olive ground") | The ~5× term collapse is proven, but absolute luma 13.27 vs ~31 predicted is **not** explained by this term alone (§2 table); a second, unprobed viewport/readback factor remains UNVERIFIED |
| **2** | **(e) Sun uniform binding is missing / wrong.** | **partly refuted, partly supported** | Binding is present and donor-cited: `world3d_terrain.gd:559-565`, `TRN_GEOM_implementation.md:76-78`. The *space/axis mapping* is wrong for a flat ground: donor Y=0.9387 lands in Godot Z, donor Z=0 lands in Godot Y (`terrain_tileindex.gdshader:287-288`; `world3d_terrain.gd:138`; `water.dev.vert:22` cited at `TRN_SHADER:48`). The `/4`,`/2` weights and engine light-space are already flagged UNVERIFIED at `TRN_SHADER:104-108` | "Missing binding" is refuted by the live `set_shader_parameter` call and by `TRN_GEOM:77`. This is a *scale/space mismatch*, not an absent uniform; do **not** describe it as an unbound light |
| **3** | **(b) `mask_to_alpha=1` blends a dark mask over a dark clear colour.** | **refuted for this frame; latent risk elsewhere** | Mechanism real: shader `:232-241,464`; `V3D_02:92` measured luma 42.735→38.425 when removed; module comment `world3d_terrain.gd:573-580` | For P0, tile id 0 → patch `(0,0)` = constant 255 (§1, verified twice) → `a=1` → `ALPHA=1`, so no blend occurs. Patch `(3,3)/(7,3)`=0 would zero alpha and black out a frame (`DALPHA_02:156-161`) but those cells are not sampled here |
| **4** | **(f) Camera framing entirely inside unlit terrain.** | **partially supported for "no sky"; refuted as cause of darkness; runtime pose UNVERIFIED** | PIXEL-01 `:28-29,36`; METRIC-01 §2 derivation (camera at `(0,34.06,54.5)` looking at origin, all rays hit the 128 m quad); `camera3d.gd:88,122-123,171-220,257-275`; bind-time tree errors `TEST_RUN_02:172-183` | A rotation cannot change `dot(l,n)` on a flat ground (§2 step 4), so framing cannot create the darkness. The `!is_inside_tree()` errors make the *actual* pose UNVERIFIED (METRIC-01 `:154-164,309-312`); pixel evidence is consistent with the intended pose but does not prove it |
| **5** | **(d) World-XZ texgen `fract()` samples a dark corner of the tile.** | **refuted as a global cause** | Mechanism exists: shader `:211,304-309,385`; `V3D_02:87` (P2) and `GAPS.md:34` | The whole frame integrates many 2 m periods of cell 0; grass1 mean is `(76,82,30)` with only ~1% pixels below 50 (p10≈66/69, §1). A dark corner cannot reduce the *whole* frame to 14. Could contribute to the faint smears (PIXEL-01 `:31-35`) — **inferred / UNVERIFIED** |
| **6** | **(c) Atlas sampling returns a near-black/empty cell.** | **refuted** | Empty cells exist: `ATLAS_01:75` (`86,110,123`); `ATLAS_01:216` | P0's UV2.x is identically 0 (§1, verified twice), and cell 0 is `grass1` with measured mean `(76,82,30)` (§1). No empty cell is reachable from this fixture |

**Ranking rationale:** (a)/(e) are the only hypotheses that change the *lighting term* by the
observed order of magnitude and also predict the R≈G≫B olive signature. (b)–(f) either cannot
fire in this fixture or explain only the absence of sky, not the luma floor.

## 4. Smallest discriminating experiments (to be run later; none run here)

**Experiment 0 — Python-only replay (no file edit, no Godot; already executed in §1/§2 and
repeatable).** Steps: (1) read `tile_index_atlas.manifest.json:48-70` → cell 0 = `grass1`;
(2) read `grass1.png` and the 0,0 crop of the atlas PNG → mean `(76.01,82.46,30.39)`;
(3) read `alpha.png[0:64,0:64]` → constant 255; (4) evaluate the shader's `v_packed` with
`sun_world=normalize((x/4,z/2,y))` and `n=world up`. **Expected output:** `dot(l,n)=0`,
`v_packed=ambient`, predicted luma ~31 under the simple sRGB model, vs observed 13.27.
Discriminates: supports (a)/(e); eliminates (c); shows (b) cannot fire. **Limitation:** cannot
resolve the residual ~2.3× (viewport path) — labelled UNVERIFIED.

**Experiment 1 — runtime uniform A/B via the shader's existing knobs (no game-code edit; needs
a new *test-only* probe atom and an authorised runner job — NOT submitted by this worker).**
Load the identical P0 fixture, capture after the identical 10 frames/readback, and call
`set_shader_parameter()` on the terrain `ShaderMaterial` before capture. Existing knobs
(`terrain_tileindex.gdshader:147-232,226-241`) suffice; no shader change is needed.

| Variant | Exact setting | Expected output and interpretation |
|---|---|---|
| **1A — constant-albedo control** | `ambient_rgb=(0.5,0.5,0.5)`, `diffuse_rgb=(0,0,0)`, `specular_rgb=(0,0,0)` | Predicted mean RGB ≈ `(53,58,19)`, luma ≈54 (§2 model). **Bright control →** capture pipeline and atlas sampling work; darkness originates in the lighting/composite term. **Still ~14 →** darkness is in the SubViewport/readback path, not the shader lighting |
| **1B — vertical-sun test** | `donor_sun_position=(0,0,1)` (maps to Godot +Y via `:287-288`) | Predicted mean RGB ≈ `(76,81,27)`, luma ≈76. **Brightens ≈2.4× →** confirms (a)/(e): the zero Godot-Y component of the shipped sun is the cause of the lost diffuse. **No change →** look elsewhere (normals/uniform actually applied) |
| **1C — mask-alpha diagnostic** | `mask_to_alpha=0.0` | With `a=1`, `mix(1,1,0)=1`: **expected no pixel change**, confirming (b) is inert here. Any change means the mask path is not the constant-255 patch (would require a tile/patch mismatch) |
| **1D — texgen scale diagnostic** | `uv_repeat=(0.05,0.05)` vs shipped `(0.5,0.5)` | Mean RGB/luma should stay within the grass1 range if (d) is not a dark-corner artefact; large luma swings would support (d) |
| **1E — specular isolation** | `specular_rgb=(0,0,0)` with shipped sun | Expected negligible change (§2 step 5). A large change would implicate the TRN-GEOM donor-specular binding (`world3d_terrain.gd:561`) |

All variants must keep `full_width_dark_rows`/`non_black_fraction` as **recorded** metrics; none
may weaken an assertion (`TEST_MATRIX.md:67-68`; `PIXEL_01:98`).

**Experiment 2 — paired control quad + pitch variant** (already specified by PIXEL-01
`:85-98`): a flat mid-grey unlit quad through the same SubViewport path, and a terrain capture
with only camera pitch/height changed. A bright control + unchanged terrain luma isolates the
shader; a dark control implicates the capture path; streak movement with pitch supports (d).

**Experiment 3 — camera-pose probe** (METRIC-01 `:293-297,309-312`): log `global_position`,
forward vector and `get_view_rect()` after `bind()` to resolve the `!is_inside_tree()` errors;
this settles (f). Expected under the intended pose: `(0,34.06,54.5)`, forward toward origin.

## 5. Owner-file recommendation and candidate fix direction

**Single most likely owner file: `variant3d/shaders/terrain_tileindex.gdshader`**, specifically
the donor-sun → eye-space conversion at `:287-299` and its constant-direction (`lsParallel`)
assumption at `:136-149`, introduced by TRN-SHADER (`TRN_SHADER_implementation.md:47-49`).
The module-side binding (`world3d_terrain.gd:562-565`) is present and donor-cited, so the
*shader's axis/space reinterpretation* is where the lost diffuse originates.

**Candidate direction (NOT a fix, NOT implemented):** re-derive, with donor citation and an
explicit `PORT APPROXIMATION`/`UNVERIFIED` label, how `light.cfg` Position (Z=0, W=1) becomes the
shader's eye-space `l` — including whether the donor's `l = normalize(position - realpos)`
(`hf.pvl.sm.vert:13`) must be retained, and which Godot axis receives donor Y/Z — instead of
blindly restoring the old `light_position_eye=0` headlight or scaling a constant ad hoc. Any
change must preserve the cited donor constants and be A/B'd with Experiment 1B before a visual
claim. The residual 8-bit luma factor (§2) may belong to a *different* owner (SubViewport /
environment / capture tooling) and is UNVERIFIED; do not bundle it into this shader ticket.

## 6. Corrections / stale statements in prior docs (no edits made)

1. **`TRN_SHADER_implementation.md:123-128` is stale:** it says "No new uniform binding is
   required" and that adding `set_shader_parameter()` calls would be future work. TRN-GEOM has
   since bound `ambient_rgb`, `diffuse_rgb`, `specular_rgb` and `donor_sun_position`
   (`world3d_terrain.gd:559-565`; `TRN_GEOM:76-78`). Correct current statement: the bindings
   exist; the *space mapping* is the open issue.
2. **`METRIC_01_dark_rows.md:13,228-267` and `PIXEL_01:11,73-81` answer different questions.**
   METRIC-01's `METRIC_ARTIFACT` verdict concerns the *gate's applicability* to a water-free
   frame; PIXEL-01's `GENUINE_VISUAL_DEFECT` concerns the *pixels*. Both can stand, but
   METRIC-01's causal sentence at `:252-255` ("warm-lit tile shader with mask-alpha over a stub
   viewport") is misleading: the shipped sun math gives **zero** diffuse on flat ground (§2),
   and mask-alpha is inert for tile 0 (§3 rank 3).
3. **`METRIC_01:43` cites shader lines `:151-159` for `specular_rgb = 0`;** in the snapshot the
   default is at `terrain_tileindex.gdshader:157` and the live value is overridden by
   `world3d_terrain.gd:561` to the donor specular `(0.278,0.267,0.212)`. The "specular = 0"
   premise no longer holds at runtime (its contribution is still negligible, §2 step 5).
4. **`V3D_02:88` (P3) describes the headlight `light_position_eye=0` as ACTIVE.** That was true
   at audit time but was changed by TRN-SHADER (`TRN_SHADER:47-49`); the current defect is the
   *replacement* sun mapping, not the old headlight. `GAPS.md:35` is likewise stale on "sun
   never lights terrain" — the shader now consumes the sun internally, just with zero diffuse
   on flat ground.
5. `ATLAS_01_transport.md:175` already corrects the older LFS wording; no further correction
   from this lane. `DALPHA_02:156-161` correctly anticipates that tile 0 selects the constant-255
   sentinel; this diagnosis confirms it numerically.

## 7. Open questions / UNVERIFIED

1. What exact linear→sRGB / tonemap / exposure conversion does this private `SubViewport`
   apply before `save_png()` (`world3d_terrain.gd:149,951-952`; `t_terrain_only.gd:654-667`)?
   Needed to explain the residual luma 13.27 vs ~31 predicted (Experiment 1A).
2. Did `bind()`'s `!is_inside_tree()` errors (`TEST_RUN_02:172-183`) leave the camera at its
   default pose? Pixel topology says no, but no runtime pose log exists (Experiment 3).
3. Does the donor engine treat `light.cfg` Position (W=1) as a direction or as a distant point,
   and does it subtract `realpos` as `hf.pvl.sm.vert:13` does? Already flagged UNVERIFIED at
   `TRN_SHADER:104-108`; central to the owner-file recommendation.
4. Are the faint diagonal smears (PIXEL-01 `:31-35`) texgen/mip artefacts, specular variation,
   or readback noise? Cannot be resolved at 1280×720 without Experiment 1D/2.
5. Would a matched donor 64² terrain-only frame have luma ≈13 or ≈76? No donor GPU A/B exists;
   every visual statement here stays `PORT APPROX` / UNVERIFIED.

## 8. Summary

The P0 frame is dark because the active shader's lighting term has collapsed. The fixture draws
one tile (`grass1`, mean RGB `(76,82,30)`) everywhere, with a fully opaque alpha patch, so the
atlas, mask and empty cells cannot explain the darkness. The shipped donor-sun mapping
(`terrain_tileindex.gdshader:287-289`) puts donor `Y=0.9387` into Godot **Z** and donor `Z=0` into
Godot **Y**; on the flat test ground `dot(l,n)=0` for every camera pose, so `diffuse` is exactly
zero and `ALBEDO ≈ grass1_rgb × ambient_rgb ≈ (0.014,0.016,0.002)` linear. That is a ~5× loss of
the intended lighting term and reproduces the R≈G≫B olive signature. Ranking: **(a)/(e) dominant
and supported; (b) refuted for tile 0; (f) explains only the absence of sky; (d) and (c) refuted
as global causes.** The absolute 8-bit luma (13.27 vs ~31 from the simple sRGB model) still has
an UNVERIFIED viewport/readback factor. Most likely owner: the terrain shader's donor-sun
conversion; candidate direction: re-derive the donor light-space mapping with citation and A/B
it (Experiment 1B) — **no fix is claimed or applied**. No code, config, test, asset, runner job
or donor copy was created or changed by this worker; this report is the only file written.

---

*End of TERRAIN-DARK-01. Read-only diagnosis; no Godot run, no code edit, no donor copy, no
donor-parity claim.*
