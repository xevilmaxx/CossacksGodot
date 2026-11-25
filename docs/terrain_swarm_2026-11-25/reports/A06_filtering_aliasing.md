---
id: A06-FILTERING-ALIASING
title: "A06 — sampling/filtering diagnosis of the terrain diagonal streaks"
owner: A06 (DIAGNOSIS, read-only)
date: 2026-11-25
status: COMPLETE__READ_ONLY__NO_GODOT_JOBS
labels: [observed, derived, inferred, UNVERIFIED]
files_created:
  - docs/terrain_swarm_2026-11-25/reports/A06_filtering_aliasing.md
files_edited: []
godot_jobs_run: 0
parity_guard: "Donor filtering intent (reftile.mat:24-49, tfIsotropic, 11 mips) is OBSERVED from donor text; no donor GPU A/B exists in this session. Every proposed anisotropy/linear change is a PORT APPROXIMATION, never donor parity."
---

# A06 — filtering / aliasing diagnosis

## 0. Scope compliance and concurrency note

`CHARTER.md` was read in full first. This agent made **no code edits**, submitted **no Godot runner job**, and created exactly one file (this report). Pillow work wrote only temporary images under
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\p0fresh01\` (outside the repo) — the zoom crops are diagnostic scratch, not deliverables.

**Important concurrency observation (OBSERVED via `git status` / `git diff` while this analysis ran):** implementation agents landed fixes in the exact files under study — B01 changed `variant3d/shaders/terrain_tileindex.gdshader:60` from `filter_nearest_mipmap` to `filter_linear_mipmap`, and B02 added `_prepare_atlas_image()` to `variant3d/scripts/tile_atlas_loader.gd` plus `mipmaps/generate=true` in two `.import` files. The supplied capture `p0_final_formula.png` is the **pre-B01/B02 baseline**. This report therefore separates:

* **BASELINE** = state that produced the capture (and the state the Charter's suspect #3 describes);
* **CURRENT** = state of the working tree at the time of this report (line numbers below are CURRENT unless marked BASELINE).

## 1. OBSERVED — the sampling chain

### 1.1 Shader samplers (`variant3d/shaders/terrain_tileindex.gdshader`)

| Sampler | BASELINE | CURRENT | Sampled where |
|---|---|---|---|
| `tile_atlas` (`:60`) | `filter_nearest_mipmap, repeat_enable` | `filter_linear_mipmap, repeat_enable` (B01) | `tile_rgb()` `:332-338`, called from `fragment()` `:392` |
| `alpha_atlas` (`:66`) | `filter_nearest, repeat_enable` | unchanged | `fragment()` `:419` via `alpha_patch_uv()` `:365-378` |
| `alphavert_atlas` (`:72`) | `filter_nearest, repeat_enable` | unchanged | `fragment()` `:412` |
| `shadow_map` (`:83`) | `filter_nearest, repeat_enable` | unchanged | `shadow_tap()` `:382-386` (shadow OFF by default) |

Godot 4.7 defines the hint grammar as `filter[_nearest|_linear][_mipmap][_anisotropic]` plus `repeat[_enable|_disable]` ([Shading language, uniform hints](https://docs.godotengine.org/en/4.7/tutorials/shaders/shader_reference/shading_language.html)). For a **custom uniform sampler**, the hint — not the texture resource's flag — is authoritative; the project-level `canvas_textures/default_texture_filter` does not apply to it (Godot issue [#74332](https://github.com/godotengine/godot/issues/74332)).

Precise meaning of `filter_nearest_mipmap` in Godot 4.7 ([VisualShaderNodeTextureParameter, `FILTER_NEAREST_MIPMAP`](https://docs.godotengine.org/en/4.7/classes/class_visualshadernodetextureparameter.html)): *nearest texel in X/Y*, with mipmaps **enabled** — by default it **blends between the two nearest mip levels** (`rendering/textures/default_filters/use_nearest_mipmap_filter = false`, engine default); only when that project setting is `true` does it pick the single nearest mip level (the classic hard LOD banding case). So the Charter's shorthand "nearest magnification" is imprecise: the defect is **nearest texel selection during minification plus an absent mip chain**, not merely nearest magnification.

### 1.2 Atlas asset and its import settings

* `variant3d/assets/terrain/atlas/tile_index_atlas.png` — measured with Pillow: **16384×8192**, 179,912,941 bytes. Manifest `.../tile_index_atlas.manifest.json:13-29` declares grid `[16,8]`, `cell_size [1024,1024]` → one atlas cell is **1024² texels**.
* `variant3d/assets/terrain/atlas/tile_index_atlas.png.import:18-40` — `compress/mode=0`, **BASELINE `mipmaps/generate=false` at `:26`**, no `flags/*` keys (no filter/repeat/anisotropy entries). CURRENT: `:26` = `true` (B02). Same for `tile_index_atlas_winter.png.import`.
* Masks: `alpha.png` = **512×256** (8×4 patches of 64²), `alphavert.png` = **1024×512** (Pillow-measured). Their `.import:26` files still have `mipmaps/generate=false`; shader hints at `:66/:72` are `filter_nearest` (no mipmaps requested), so this is internally consistent with the donor mask path.

### 1.3 How the loader actually builds the texture (`variant3d/scripts/tile_atlas_loader.gd`)

* The PNG is decoded with `Image.load()` in `_load_image_at()` (`:320-332`), then wrapped with `ImageTexture.create_from_image(...)`. **The `.import` `[params]` never reach this runtime texture** (no `ResourceLoader.load()` of the PNG anywhere in the shader-facing path; `world3d_terrain.gd:721` binds the loader's texture verbatim). This is the single most important plumbing fact: editing `.import` alone cannot change the sampled atlas.
* BASELINE: `_load_single()` (old `:280-290`) and `_load_split()` (old `:388-397`) created the texture with only level 0; `ImageTexture.create_from_image()` does **not** generate mips ([ImageTexture docs](https://docs.godotengine.org/en/4.7/classes/class_imagetexture.html)). No `generate_mipmaps()` call existed anywhere in the tree.
* CURRENT: B02 added `_prepare_atlas_image()` at `:335-356` (`img.has_mipmaps()` guard + `img.generate_mipmaps(false)`) and calls it at `:285` (single) and `:413` (split). `MODE_ARRAY` still builds `Texture2DArray` from raw images at `:471-476` **without** mips; `_load_masks()` at `:482-494` still creates base-level-only mask textures (acceptable for `filter_nearest`, but relevant to Fix 1 below).
* Donor truth for contrast: `reports/A08_donor_truth_local.md` §6 item 9 records donor terrain art as **full 1024² with 11 mip levels, nearest-mag / nearest-mipmap-linear-min, `tfIsotropic`** (`reftile.mat:24-49`; DTRN-01 C3/C16). The baseline port had **0 mip levels** while asking for a mipmap sampler.

### 1.4 World-space repeat, mesh pitch, camera

* `terrain_tileindex.gdshader:214` `uv_repeat = vec2(0.5,0.5)` = 1 repeat / 2 m (donor `gc_meters_to_tile=2`).
* `:392` `vec3 rgb = tile_rgb(v_tile, fract(v_st * uv_repeat));` — `fract()` is in the **fragment** stage for RGB.
* `:316` `v_alpha_uv = fract(v_st * uv_repeat) * alpha_uv_scale;` — `fract()` is in the **vertex** stage for the alpha masks (see §3.3).
* `variant3d/scripts/world3d_terrain.gd:150` `TILE_M = 2.0`; mesh vertices are placed at cell centres `:1391-1393`, `Vector3((x+0.5-cx)*TILE_M, …, (z+0.5-cz)*TILE_M)`. **The 2 m texture period is exactly the 2 m mesh pitch.**
* `variant3d/scripts/config.gd:108` / `data.gd:196-198` / `camera3d.gd:278-282`: camera pitch **−32°**, height 20–58 m — a shallow oblique view of a ground plane, i.e. exactly the minification regime where mip/anisotropic filtering matters.

### 1.5 Project render settings (`variant3d/project.godot:21-28`)

```
renderer/rendering_method="gl_compatibility"      (:25)
renderer/rendering_method.mobile="gl_compatibility"(:26)
textures/canvas_textures/default_texture_filter=1 (:27)  // 2D canvas only
environment/defaults/default_clear_color=...      (:28)
```

There is **no** `rendering/textures/default_filters/anisotropic_filtering_level` override (engine default **2**), no `use_nearest_mipmap_filter` override (default **false**), no `texture_mipmap_bias` override (default 0), no `rendering/anti_aliasing/quality/msaa_3d` (default 0), no `screen_space_aa` (default 0), and no `rendering/scaling_3d/scale` (default 1.0). Compatibility renderer supports MSAA and SSAA but **not** FXAA, SMAA, TAA or FSR2 ([3D antialiasing, Godot 4.7](https://docs.godotengine.org/en/4.7/tutorials/3d/3d_antialiasing.html)). Anisotropic filtering works in Compatibility via `EXT_texture_filter_anisotropic` but requires a mip chain and an `_anisotropic` hint to have any effect.

## 2. PIXEL MEASUREMENT — Pillow quantification of the supplied capture

Source: `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\p0fresh01\p0_final_formula.png` (1280×720; the P0 baseline frame). All numbers below are **OBSERVED** measurements of that file; scratch crops: `a06_zoom_streaks.png` (320×240 centre crop, 4× NEAREST, autocontrast) and `a06_lowpass_streaks.png` (Gaussian σ=22, autocontrast), both in the temp folder only.

| Measurement | Result |
|---|---|
| Global luma (Pillow `L`) | mean 88.46, σ 10.20, range 10–149 — flat olive field |
| 4× zoom of `(384,240)-(704,480)` | fine grain plus faint diagonal dark streaks running up-right/down-left |
| Gaussian σ=22 + autocontrast | reveals a regular **chevron/grid** of diagonal bands converging toward the horizon — the projection of a fixed 2 m lattice, not organic mottling |
| FFT of centre band `y=180:600`, row-mean removed, Hann window | dominant peaks at **fx = ±16 cycles / 1280 px → 80.0 px period** and fx=±17 → 75.3 px, with **fy ≈ 0 (±1)**; peak power 4.0×10⁸ vs 2.3×10⁸ for the next bin — a narrowband, nearly vertical-frequency pattern |
| Detrended per-distance spectra (σ=22) | strongest fine band: near/bottom k=13 → **98.5 px**, mid k=16 → **80.0 px**, far/top k=18 → **71.1 px** per repeat. Period shrinks with distance as expected under perspective |
| Directional high-pass (σ=8) mean \|dI\| at lag 24 px | 2.06 at 0°, 2.02 at 165°, **1.24 at 90°** → ≈1.66× anisotropy: image changes ~1.7× more horizontally than vertically, i.e. features are elongated into vertical/diagonal streaks |
| Autocorrelation along the (1,1) diagonal (σ=8) | local peak at lag 68 px (0.284), consistent with the observed band spacing |

**Minification estimate (DERIVED from the two rows above):** one atlas cell = 1024 texels per 2 m → **512 texels/m**. A cell projects to ~98.5 px near, ~80 px mid, ~71 px far → 40–51 px/m → **10.4–14.4 atlas texels per screen pixel**. Correct antialiasing would need about `log2(12.8) ≈ 3.7` mip levels of downsampling at mid-screen. With only level 0 (BASELINE) the GPU must choose **one texel out of a ~13×13 footprint**; the 8×8-minified case is ~164 texels into one pixel. That is far beyond Nyquist and guarantees moiré; because the same 2 m cell is repeated with the same phase, the folded error is *coherent*, which is why it reads as bands rather than random noise.

## 3. MECHANISM — how `filter_nearest_mipmap` + `fract()` + shallow minification create the streaks

1. **No LOD filtering at minification (primary).** The hint asks for mips, but the runtime texture has one level. In GLES3 a mip-min filter on a one-level texture clamps to level 0 and applies nearest selection. Every screen pixel therefore samples a single atlas texel from a 10–14 texel footprint. High-frequency grass detail folds (aliases) into low frequencies; because the sampled patch is identical every 2 m, the folded pattern is identical every 2 m.
2. **The repeat is phase-locked to the mesh lattice.** `fract(v_st*0.5)` completes exactly one cycle per `TILE_M = 2.0` cell, and vertices sit at cell centres (§1.4). Each cell starts its atlas UV at the same phase; when neighbouring cells share a tile id (Charter §2 item 5: top-5 ids 72.68% → 58.52%), they are byte-identical copies. Perspective turns that lattice into converging chevrons — exactly the σ=22 image and the fx=±16 spectral peak. This is the *pattern*; the aliasing in step 1 is what makes it high-contrast enough to see.
3. **`fract()` in the vertex stage collapses the alpha mask to a constant.** Mesh vertices are at 2 m spacing and the mask phase period is 2 m, so `v_st*0.5` at every vertex is an integer or half-integer (depending on map width parity) → `fract(...)` is the **same value (0.5 or 0) at every vertex** (DERIVED from `:311-316`, `:214`, `world3d_terrain.gd:1391-1393`). Interpolation preserves that constant. `alpha_patch_uv()` `:376` then samples the **centre** of one 64² patch for the whole cell, and `:427` folds that scalar into RGB (`mask_to_alpha=1`). The alpha path therefore contributes no intra-cell variation: it paints a uniform brightness per tile id on a 2 m grid — the "soft blocky patches" and repeated dark blotches — and its cell edges align with the RGB bands, reinforcing the diagonal streaks. The donor's authored alpha seam feather (A08 §2.2) never survives.
4. **Implicit-derivative seam at the 2 m wrap (latent, becomes active once mips exist).** `fract()` jumps 1→0 at every cell boundary inside a triangle. The GPU computes implicit LOD from derivatives of the *post-fract* UV; across that one pixel, `dFdx(uv)` is O(1/atlas_grid) = 0.0625 in atlas space = O(1024) atlas texels → LOD ≈ 10. With mips (now supplied by B02) and `filter_linear_mipmap` (B01), those boundary pixels will fetch a very blurry level, producing a 1-pixel dark/blur line on every 2 m seam; in the BASELINE the mip filter clamped to level 0 and instead produced a hard texel jump. Either way the seam is visible. This is a standard `fract()`+mipmap pitfall; the robust fix is `textureGrad()` with derivatives of the **unwrapped** coordinate.
5. **`repeat_enable` is inert here.** After `fract()` (RGB and mask) and the atlas cell offset in `tile_rgb()` `:336` / `alpha_patch_uv()` `:377`, all sampled UVs lie in [0,1]; the wrap mode is never exercised. It cannot repair the `fract()` seam, and simply deleting `fract()` and relying on `repeat_enable` would be *wrong* for a multi-cell atlas: wrapping would pull in texels from an unrelated neighbouring preset cell. Half-texel inset per cell is required if linear filtering is enabled.
6. **Post-process AA cannot fix any of the above.** MSAA only adds coverage samples at geometry edges; it does not add colour samples inside a fragment and cannot undo texture minification aliasing. The ±16-cycle band is a shader-sampling defect (consistent with F04 §4 item 13: "AA has virtually no effect").

## 4. What Godot 4.7 actually exposes (alternatives and their trade-offs)

| Sampler hint | What it does | Effect here |
|---|---|---|
| `filter_nearest` | nearest texel, **no mips** (current masks `:66/:72`) | Sharp up close, grainy/aliased at distance; mask stays a per-cell scalar |
| `filter_linear` | 4-texel bilinear, **no mips** | Smooth up close, still grainy at distance — does not solve 13:1 minification |
| `filter_nearest_mipmap` | nearest texel + mips; default blends 2 mip levels; with `use_nearest_mipmap_filter=true` picks **nearest mip only** → visible LOD banding | BASELINE RGB hint; inert without a mip chain; nearest-mip variant would add LOD-step banding |
| `filter_linear_mipmap` | bilinear in level + trilinear mip blend | CURRENT RGB hint (B01). Good default for minified detail art; needs mips (B02 supplies them); risks cross-cell bleed without per-cell inset |
| `filter_nearest_anisotropic` / `filter_linear_anisotropic` | anisotropic footprint selection for oblique surfaces; level set by `rendering/textures/default_filters/anisotropic_filtering_level` (default 2, max depends on GPU) | Best physical match to a −32° camera, **but only with a mip chain**; donor is `tfIsotropic`, so label PORT APPROX |
| `repeat_enable` / `repeat_disable` | wrap mode for UVs outside [0,1] | Inert with `fract()`; dangerous as a substitute for atlas-cell handling |

Project-level knobs available in `variant3d/project.godot`: `rendering/textures/default_filters/use_nearest_mipmap_filter` (keep **false**), `.../anisotropic_filtering_level` (2 → 4/8), `.../texture_mipmap_bias`, `rendering/anti_aliasing/quality/msaa_3d` (0 → 2/4; works in Compatibility), `rendering/scaling_3d/scale` (>1 = SSAA, works in Compatibility but costly). FXAA/SMAA/TAA/FSR2 are **unavailable** in the configured `gl_compatibility` renderer.

## 5. Ranked cause list

| # | Cause | Evidence | Status | Fixed by others? |
|---|---|---|---|---|
| **1** | **Mip chain absent on the shader-facing atlas while the sampler requested mips** → nearest selection from a 10–14 texel footprint at mid-screen (moiré/banding) | BASELINE `.import:26` false; BASELINE loader `ImageTexture.create_from_image(img)` no `generate_mipmaps`; §2 measurement 12.8 texels/px; A08 §6 item 9 donor had 11 mips | **CONFIRMED** (code + import + pixels) | YES — B02 `generate_mipmaps` + B01 hint; **verify**, and extend to MODE_ARRAY (§6 Fix 1) |
| **2** | **Hard 2 m RGB repeat phase-locked to the 2 m mesh lattice** under a −32° camera → coherent chevron/diagonal bands | shader `:214`, `:392`; `world3d_terrain.gd:150,1391-1393`; σ=22 crop; FFT fx=±16 (80 px), k=13/16/18 by distance | **CONFIRMED** as the geometry of the pattern | NO — F04 P0-1 owns breaking the verbatim repeat |
| **3** | **Vertex-stage `fract()` makes the alpha mask a per-cell constant**, folded into RGB → repeated blotches aligned with the 2 m grid | shader `:316`, `:365-378`, `:419`, `:427`; vertex pitch derivation §3.3 | **DERIVED (high confidence)** from code; exact pixel share of this term INFERRED | NO — unique to this report |
| **4** | **`fract()` implicit-derivative seam** produces LOD spikes / blur lines on every 2 m boundary once mips exist | shader `:392` after `fract`; standard GLES derivative behaviour; LOD≈10 estimate §3.4 | **INFERRED** (standard GPU behaviour, no GPU A/B run) | NO — new residual risk from B01+B02 |
| **5** | **Linear filtering (B01) without per-cell half-texel inset** can bleed unrelated adjacent atlas cells at cell borders | `tile_rgb()` `:336` uses whole [0,1] local UV; atlas packing is V7-85 APPROX (`manifest:39`) | **INFERRED** | NO — needs shader-side inset |
| **6** | Project render settings offer no AA/anisotropy help, and Compatibility excludes FXAA/TAA/FSR2 | `project.godot:25-28`; Godot 4.7 AA table | **CONFIRMED** settings; contribution to texture moiré **INFERRED low** | NO — settings decision for COORD |

Donor parity stays **UNVERIFIED** throughout: no donor GPU A/B exists.

## 6. Three concrete fixes (exact file paths)

### Fix 1 — complete the mip supply for *every* transport, then verify (partially landed by B02)

* `variant3d/scripts/tile_atlas_loader.gd`: keep `_prepare_atlas_image()` (`:335-356`) and its calls at `:285`/`:413`. **Add** `img.generate_mipmaps(false)` for each 1024² image in `_load_array()` before `ta.create_from_images(images)` (`:471-476`) — otherwise the `array` fallback silently reverts to the baseline defect. Optionally apply it to the two mask images in `_load_masks()` `:482-494` **only if** their hints are later changed away from `filter_nearest`.
* `variant3d/assets/terrain/atlas/tile_index_atlas.png.import:26` and `tile_index_atlas_winter.png.import:26`: `mipmaps/generate=true` (already done by B02). `alpha.png.import:26` / `alphavert.png.import:26` can stay `false` while their hints remain `filter_nearest`.
* `variant3d/shaders/terrain_tileindex.gdshader:60`: keep `filter_linear_mipmap` (B01) until the derivative fix below is in; do **not** re-enable `filter_nearest_mipmap`.

Verification: a fresh capture with the same camera, then re-run the §2 Pillow spectral check; the fx=±16 narrowband peak should lose most of its isolated energy relative to neighbouring bins. `assert_clean`/gates unchanged.

### Fix 2 — derivative-safe atlas sampling + restore intra-cell mask variation (new; not landed)

File: `variant3d/shaders/terrain_tileindex.gdshader`

* `:264-267`: add `varying vec2 v_st_unwrapped;` and at `:314-316` set `v_st_unwrapped = v_st * uv_repeat;`; **remove** `fract()` from the vertex stage and pass the unwrapped value to `fragment()`.
* `:332-338` `tile_rgb()`: compute `local = fract(local_unwrapped)`, inset it by half a texel (`const float CELL_INSET = 0.5/1024.0;` → `local = mix(vec2(CELL_INSET), vec2(1.0-CELL_INSET), local)`) before `uv = (vec2(col,row)+local)/atlas_grid`, and sample with explicit gradients derived from the **unwrapped** coordinate to kill the seam LOD spike:
  `textureGrad(tile_atlas, uv, dFdx(v_st_unwrapped)/atlas_grid, dFdy(v_st_unwrapped)/atlas_grid).rgb`.
  (`textureGrad` is available in Godot 4.7 — [Built-in shader functions](https://docs.godotengine.org/en/4.7/tutorials/shaders/shader_reference/shader_functions.html).)
* `:392`: call `tile_rgb(v_tile, v_st_unwrapped)` instead of `fract(v_st * uv_repeat)`.
* `:419`: call `alpha_patch_uv(v_tile, fract(v_st_unwrapped))` — moving the wrap to the fragment stage restores real intra-cell mask variation instead of the constant described in §3.3; the existing half-texel clamp at `:376` already protects the 64² patch border.

Expected effect: removes cause #3, #4 and #5 together without changing tile ids, atlas layout or donor constants. This is a PORT APPROXIMATION of donor eye-plane texgen, not a parity claim.

### Fix 3 — project-level filtering/AA settings for a shallow camera (PORT APPROX)

File: `variant3d/project.godot`, `[rendering]` block at `:21-28`:

```
textures/default_filters/anisotropic_filtering_level=4   ; 2x more oblique detail than default 2
anti_aliasing/quality/msaa_3d=2                          ; geometry edges only; not a moiré fix
; scaling_3d/scale=1.25                                  ; optional SSAA (Compatibility-supported, costly)
```

Pair the anisotropy level with `filter_linear_mipmap_anisotropic` on `tile_atlas` at `variant3d/shaders/terrain_tileindex.gdshader:60` (or `filter_nearest_mipmap_anisotropic` if donor's nearest-mag look must be approximated). Keep `use_nearest_mipmap_filter=false`. Keep `textures/canvas_textures/default_texture_filter=1` as-is — it is 2D-canvas only and does not affect the spatial sampler. Do **not** enable FXAA/SMAA/TAA/FSR2 while `:25` selects `gl_compatibility`. Label anisotropy a PORT APPROXIMATION: donor `filteringquality=tfIsotropic` (`reftile.mat:24-49`; A08 §7 item 4).

## 7. Open questions / UNVERIFIED

* No donor GPU A/B frame exists, so the *visual* share of each ranked cause (RGB aliasing vs per-cell mask scalar vs tile-id repetition) is **INFERRED**, not quantified by A/B.
* Whether `generate_mipmaps(false)` on a 16k×8k ImageTexture exceeds the target GPU's VRAM budget in practice (~33% extra over the 512 MiB base level) is **UNVERIFIED**; no runner job was submitted.
* The exact LOD spike magnitude at the `fract()` seam depends on driver derivative implementation; the LOD≈10 figure in §3.4 is an analytical estimate.
* `use_nearest_mipmap_filter` is engine-default false here (no override in `project.godot`); if a platform preset overrides it, the `filter_linear_mipmap` banding behaviour changes.
