---
id: A01
ticket: "TERRAIN SWARM A01 — shader tiling / diagonal-streak diagnosis"
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_CODE_EDIT__NO_GODOT_JOB__NO_RUNNER_JOB
owner_file: docs/terrain_swarm_2026-11-25/reports/A01_shader_tiling.md
scope: "ONE new report. No code/shader/asset/config/test edit; no Godot launch; no runner job; no donor file executed or copied."
labels: [observed, derived, inferred, UNVERIFIED]
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
inputs_read:
  - docs/terrain_swarm_2026-11-25/CHARTER.md (complete, 132 lines)
  - variant3d/shaders/terrain_tileindex.gdshader (complete, 502 lines)
  - variant3d/scripts/world3d_terrain.gd (254-326, 670-739, 950-994, 1540-1569)
  - variant3d/scripts/camera3d.gd (55-184)
  - variant3d/scripts/config.gd (:73, :503)
  - variant3d/assets/terrain/atlas/tile_index_atlas.manifest.json
  - variant3d/assets/terrain/atlas/{tile_index_atlas,alpha,alphavert}.png.import
  - docs/coord_swarm_2026-11-25/reports/RECHECK_P0_FINAL.md (:122-125, :158-174)
  - docs/terrain_swarm_2026-11-25/reports/A04_tile_diversity.md (:48-105)
  - images: p0_final_formula.png, smallmap64_terrain_only.png, donorA/B JPEGs,
    a06_lowpass_streaks.png, a06_zoom_streaks.png
parity_guard: "No donor GPU A/B frame exists. No donor-parity claim is made anywhere in this report. Every new numeric constant in the fix options is a PORT APPROXIMATION."
---

# A01 — Repeating/diagonal-streak artifact in `terrain_tileindex.gdshader`

## 0. Honesty labels and method

- **OBSERVED** — literal line of code / import flag / manifest value, or a measurement I made with Pillow/NumPy on the named images.
- **DERIVED** — arithmetic or control-flow consequence of cited OBSERVED lines and measurements.
- **INFERRED** — visual attribution with no pixel-aligned donor frame.
- **UNVERIFIED** — cannot be proved from readable data; explicitly flagged where relevant.

Method: full read of the shader and charter; read of all charter-named images; throwaway analysis scripts written **only** to `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\` (outside the repo) for grayscale FFT, 1-D/2-D autocorrelation (ACF), directional row-band period, and structure-tensor orientation; Pillow reads of atlas/alpha image headers. No repo file but this report was touched.

**Concurrent-change note (OBSERVED after analysis):** the shader and atlas `.import` were read in their pre-B01 state (`:60` = `filter_nearest_mipmap`; `mipmaps/generate=false`). A later read shows a concurrent implementation agent has already changed `:60` to `filter_linear_mipmap` and `tile_index_atlas.png.import:26` to `mipmaps/generate=true` — i.e. the Option 1 fix recommended in §6 is already landed. All "BEFORE" snippets and pixel measurements below describe the state actually analysed; the diagnosis of Rank 1/3/4 is unaffected. Verification of the landed change belongs to the QA wave, not to this read-only ticket.

---

## 1. OBSERVED — the exact texgen chain

| Step | Line | Literal |
|---|---|---|
| Sampling hint | `:60` | `uniform sampler2D tile_atlas : filter_nearest_mipmap, repeat_enable;` |
| Import reality | `tile_index_atlas.png.import:26` | `mipmaps/generate=false` (also false for `alpha.png.import:26`, `alphavert.png.import:26`) |
| World-space position | `:281` | `vec4 worldpos = MODEL_MATRIX * vec4(VERTEX, 1.0);` |
| Ground planes | `:120-121` | `eye_plane_s = vec4(1,0,0,0)`, `eye_plane_t = vec4(0,0,1,0)` → world **X** and **Z** |
| Texgen dots | `:311` | `vec2 st = vec2(dot(worldpos, eye_plane_s), dot(worldpos, eye_plane_t));` |
| Texture matrix | `:122`, `:314` | `uniform mat4 texture_matrix = mat4(1.0);` → `v_st = (texture_matrix * vec4(st,0,1)).xy;` — **identity, never bound anywhere** (grep over all of `variant3d`: only shader `:122/:314` and the stats string `world3d_terrain.gd:1555`) |
| Repeat | `:214-218` | `uniform vec2 uv_repeat = vec2(0.5, 0.5);` with comment "one atlas cell repeats every 2 m of ground" |
| Mask phase | `:316` | `v_alpha_uv = fract(v_st * uv_repeat) * alpha_uv_scale;` — **identical 2 m phase** |
| RGB fetch | `:392` | `vec3 rgb = tile_rgb(v_tile, fract(v_st * uv_repeat));` |
| Cell lookup | `:332-337` | `col = mod(idx, cols); row = floor(idx/cols); uv = (vec2(col,row)+local_uv)/atlas_grid; texture(tile_atlas, uv).rgb` |
| Mask patch | `:365-378` | tile id decomposed into `dir/variant/half/opposite`; `(cell+t)/vec2(8,4)` picks one of **32** 64² patches from the 512×256 alpha atlas |
| Mask folded to RGB | `:427` | `rgb = rgb * mix(1.0, a, mask_to_alpha) * v_packed + v_specular;` with `mask_to_alpha = 1.0` at `:235` |
| Grid/atlas geometry | manifest `atlas` | `size=[16384,8192]`, `grid=[16,8]`, `cell_size=[1024,1024]`, 121 filled cells |
| Camera for the frame | `config.gd:503`, `camera3d.gd:122,175` | pitch `-32°`; height `sqrt(20*58)=34.06 m`; `PROJECTION_PERSPECTIVE` |

**DERIVED**: the whole ground is a plane tiled by `fract(world_x/2, world_z/2)` into 1024² atlas texels per 2 m. Nothing in the chain varies the phase per cell, per tile id, or per scale. This is a single, globally coherent, axis-aligned world grating.

---

## 2. OBSERVED — image measurements

Grayscale `L`, whole 1280×720 frames:

| Image | mean | std | min/max | gradient RMS x / y / diag |
|---|---:|---:|---:|---|
| `p0_final_formula.png` (current P0) | 88.455 | **10.196** | 10 / 149 | 13.05 / 13.19 / 13.23 |
| `smallmap64_terrain_only.png` (earlier) | 88.448 | **10.196** | 6 / 149 | 13.04 / 13.20 / 13.25 |
| donor A `cossacks-3-v1-498085.jpg` | 75.348 | **29.091** | 0 / 254 | 23.36 / 21.82 / 24.83 |
| donor B `articolo-787.jpg` (960×540) | 71.367 | **33.320** | 0 / 255 | 23.41 / 22.00 / 26.56 |

- **OBSERVED**: the two port frames are statistically near-identical, so the artifact is a **static world-space** pattern, not camera-swimming (the old eye-plane bug is indeed gone).
- **OBSERVED**: port contrast is ~1/3 of either donor sample (std 10.2 vs 29–33); this quantifies the charter's "flat uniform olive" complaint but is **context**, not the streak cause.
- **OBSERVED**: 2-D ACF of an 8×8 box-lowpass field of the current frame has a dominant peak at **dx = ±76 px, acf = 0.714**. FFT of the same field has a peak at fx = ±0.0110 cycles/px (≈91 px) and the raw frame at fy = ±0.0375 (≈27 px, the grain scale).
- **OBSERVED**: the dominant horizontal ACF lag **grows monotonically with screen row**: 60 px at rows 0–60 → 63 → 66 → 69 → 72 → 76 → 79 → 82 → 85 → 88 → **91 px** at rows 600–660 (12 bands, peak acf 0.61→0.71). Along screen-y the ACF decays monotonically with **no local maximum** in 25–150 px.
- **DERIVED** (camera math): with pitch 32°, h = 34.06 m → focus distance d = h/sin32° ≈ 64.3 m; FOV 17.27° → px/m at focus = 720/(2·64.3·tan8.635°) ≈ **36.9 px/m**. One 2 m cell therefore spans **≈73.7 px horizontally**, within **3 %** of the measured 76 px. The ground-Z period is foreshortened to 2·36.9·sin32° ≈ **39 px**, which lies in the range where the measured vertical ACF shows no peak — consistent with aliasing destroying that periodicity.
- **OBSERVED (other agent's image, used as data)**: `a06_lowpass_streaks.png` in the same capture folder shows a staircase/teeth band pattern; `a06_zoom_streaks.png` shows blocky repeated patches. These corroborate the measurements above but are **INFERRED** as to cause.
- **INFERRED**: because the repeat period increases toward the bottom of the frame, iso-phase lines of the world-X grating are not vertical — they lean with row (slope dx/dy ≈ k·0.047 for the k-th tile boundary), which is exactly the "faint diagonal streaks / repeating bands" the owner describes. The streaks are **perspective-sheared copies of the 2 m world-X repeat**, not a separate diagonal texture.

**Contrast with prior visual call**: `RECHECK_P0_FINAL.md:162-166` recorded "No ... tile grid ... visible; ... faint low-contrast darker mottling / streaking ... diffuse, not grid-aligned". That was a visual judgement; my lowpass ACF measures a narrow 76 px periodic component with a systematic row gradient. I report the measurement as OBSERVED and the prior reading as an INFERRED visual call; they disagree, and the measurement wins for the streak question. (The un-lowpassed frame genuinely does not show a *hard* grid — see §4.2.)

---

## 3. Ranked root causes

### Rank 1 — 2 m world-XZ `fract` grating (OBSERVED code + DERIVED pixels)

`:311` + `:214-218` + `:392` produce one verbatim atlas cell per 2 m with a single global phase. No per-cell rotation, offset, or scale breaks it. The measured 76 px horizontal period matches the predicted 73.7 px for a 2 m cell at the P0 camera within 3 %, and its monotonic 60→91 px row gradient is the perspective signature of a fixed world grid. **This is the primary cause of the repeating bands/streaks.**

### Rank 2 — minification of 1024² cells with no mip chain (OBSERVED code + OBSERVED import + DERIVED consequence)

`:60` asks for `filter_nearest_mipmap`, but `tile_index_atlas.png.import:26` says `mipmaps/generate=false`; the shader hint cannot create levels that were never imported. Effective sampling is therefore **nearest, level-0 only**. A 1024² cell is squeezed into ≈74×39 px at the frame centre — **≈14× horizontal and ≈26× vertical minification**. Nearest level-0 minification of a repeating texture is the textbook moiré/aliasing generator: it converts the 2 m grating into harsh beat patterns and destroys the vertical period (matching the missing vertical ACF peak). The shader's own comment at `:52-58` already admits the hint is only an approximation of the donor's mixed nearest-mag / nearest-mipmap-linear-min filter, so even with mips this is not donor parity.

### Rank 3 — mask phase locked to the same 2 m grid and folded into RGB (OBSERVED code + DERIVED patch map)

`:316` gives the alpha patch **the same** `fract(v_st*uv_repeat)` phase as RGB. The patch is one of 32 64² sub-rects (`:365-378`), clamped half a texel inside its border (`:376`), and `:427` multiplies it into albedo with `mask_to_alpha = 1.0` (`:235`). So every 2 m cell boundary is also a mask-pattern boundary — a second, perfectly co-registered grating. A quick dec enumeration of `alpha_patch_uv` for ids 0..85 yields exactly **32** distinct patches, with constant patches `(0,0)=255`, `(4,0)=255`, `(3,3)=0`, `(7,3)=0` used by several ids; id 0 (`grass1`) maps to `(0,0)`, i.e. a no-op mask. **Frame-specific note**: `RECHECK_P0_FINAL.md:123` records `uv2_y_hist={"0":4096}` for the 64² P0 fixture and `A04_tile_diversity.md:84` records that fixture as ~97 % tile id 0. If the current frame is that fixture (**INFERRED** — the PNG carries no tile histogram), then mask modulation is effectively 1.0 there and the dark blotches come from the atlas cell's own content, not from the mask. The co-registration still amplifies the 2 m grid in any frame with mixed ids.

### Rank 4 — no multiscale content in the sampled signal (OBSERVED pixels, contributing context)

std 10.2 vs donor 29–33; gradient RMS ~13 vs donor ~22–27. One flat tile family + one flat mask + no relief means nothing breaks the grating. This is a contributing condition, not an independent cause of streaks. Fixing it belongs to relief/data tickets (charter §2 items 5–6), not to this shader option list.

### Explicitly NOT a cause for this artifact

| Candidate | Verdict | Evidence |
|---|---|---|
| `texture_matrix` non-identity | **RULED OUT (OBSERVED)** | Declared `mat4(1.0)` at `:122`, applied at `:314`, never bound in any script; an identity matrix cannot introduce a new period. The repetition is set solely by `uv_repeat` at `:214/:316/:392`. |
| 25° face tilt | **RULED OUT for this frame (OBSERVED)** | The shader deliberately does *not* apply a 25° rotation (`:468-471`). The only 25° application is `_tilt_face_normal()` at `world3d_terrain.gd:965-973`, which rotates **normals**, only for `face==1/2`, and so affects lighting `v_packed` (`:305`) — not texgen, not UV phase. P0 fixture has `uv2_y_hist={"0":4096}` (`RECHECK_P0_FINAL.md:123`): all face 0. On a real slope map its lighting effect is **UNVERIFIED** and cannot create a world-XZ grating. |
| Face modes 1/2 | **RULED OUT for this frame (OBSERVED)** | Same histogram: 4096/4096 face 0. Face paths at `:397-412` switch only to `alphavert_atlas`; RGB stays `tile_rgb` at `:392`. |
| Eye-space/camera swim | **RULED OUT (OBSERVED)** | `:281/:311` use `MODEL_MATRIX * VERTEX`; the two captures have identical statistics, confirming a static pattern. |
| Hard atlas-cell seams | **INFERRED minor** | Measured wrap-seam gradient on `grass1` is 1.18× (x) / 1.11× (y) the interior gradient; `grass2` 1.03×/1.81×. Cells are approximately tileable, so seams are not the driver. |

---

## 4. The four scoped questions, answered

1. **World-ground XZ texgen + `fract(v_st*uv_repeat)` (`:311-316`, `:392`)** — confirmed as the source of the periodic structure. Stable world projection correctly removed the old camera-swimming artifact but replaced it with a static world grating. The `fract` is applied **after** the world projection and before both atlas and mask lookup, so there is exactly one phase for all 2 m cells.
2. **One atlas cell per 2 m at a shallow camera** — the 1024² cell is minified ~14× horizontally and ~26× vertically at the P0 camera. The horizontal period measures 76 px (predicted 73.7 px), the vertical period is aliased away, and the horizontally-periodic bands are sheared by perspective into the observed diagonal streaks. This is the core mechanism (**DERIVED**, well-supported).
3. **Nearest-mipmap filtering at `:60`** — the hint is effectively inert because `mipmaps/generate=false` on the atlas import. Level-0 nearest minification is the amplifier that turns the 2 m grating into moiré. **This is the second-ranked cause and the highest-leverage single fix.**
4. **25° tilt / face modes / identity `texture_matrix`** — none contributes to this frame (see table above). The 25° literal is real donor metadata (`tiles.lib:119-136`) but its port use is a normals-only PORT APPROX (`world3d_terrain.gd:964`) and the shader explicitly omits it (`:468-471`).

---

## 5. Shader-level fix options (exact snippets, tradeoffs)

All options preserve the existing UV contract, the `mask_to_alpha` A/B contract at `:478-501`, the 2D app, and the tests. None injects a synthetic dither/noise/hash field (charter S-25-09 guardrail). No donor constant is invented; every new number is labelled PORT APPROX.

### Option 1 — Make mipmaps actually exist, and ask for linear mip filtering

```gdshader
// :60 — BEFORE
uniform sampler2D tile_atlas : filter_nearest_mipmap, repeat_enable;
// :60 — AFTER
uniform sampler2D tile_atlas : filter_linear_mipmap, repeat_enable;
```
plus the mandatory import-side companion (outside shader ownership, one flag in `variant3d/assets/terrain/atlas/tile_index_atlas.png.import:26`):
```
mipmaps/generate=true
```
Tradeoffs: directly removes the level-0 nearest minification that creates the moiré; one-line shader change; no new constants; reversible. Requires a reimport of the 16384×8192 atlas (~1/3 more VRAM for mips) and an import-file edit by an implementation owner — **the hint alone changes nothing while the import flag is false**. It softens fine grain (donor samples have sharp detail), so an A/B with `filter_nearest_mipmap` (now with real mips) is worthwhile. It does **not** remove the underlying 2 m repetition, only the streaks it aliases into.

### Option 2 — Break the RGB/mask phase lock

```gdshader
// :316 — BEFORE
v_alpha_uv = fract(v_st * uv_repeat) * alpha_uv_scale;
// :316 — AFTER (incommensurate scale + phase; PORT APPROXIMATION, no donor literal)
v_alpha_uv = fract(v_st * uv_repeat * 1.37 + vec2(0.19, 0.41)) * alpha_uv_scale;
```
Tradeoffs: the 2 m mask boundaries no longer coincide with RGB cell boundaries, removing the double grating and most "repeated dark blotches" on mixed-id maps; no extra texture fetch. The `1.37` / offsets are new PORT APPROX constants, not donor values, and mask semantics move further from the already-UNVERIFIED donor rule (`DALPHA-01/02`). Do **not** change the `mask_to_alpha` default at `:235`: it is a published A/B contract (`:478-501`); any amplitude experiment must use runtime `set_shader_parameter("mask_to_alpha", …)` instead.

### Option 3 — Deterministic two-scale blend of the same atlas cell (no noise/dither)

```gdshader
// :392 — BEFORE
vec3 rgb = tile_rgb(v_tile, fract(v_st * uv_repeat));
// :392 — AFTER (PORT APPROXIMATION; no hash, no dither, no random field)
vec2 uvA = fract(v_st * uv_repeat);
vec2 uvB = fract(v_st * uv_repeat * 0.73 + vec2(0.31, 0.17));
vec3 rgb = mix(tile_rgb(v_tile, uvA), tile_rgb(v_tile, uvB), 0.25);
```
Tradeoffs: reduces the coherence of the 2 m repeat without adding any synthetic noise field (guardrail-safe), at the cost of a second `texture()` fetch per pixel and a constant blend weight that only softens, never removes, the repeat. Both scales are PORT APPROX. A spatially varying weight would hide it better but risks recreating the S-25-09 checkerboard regression, so it is deliberately **not** proposed.

### Option 4 — Reuse the donor alpha atlas as a large-scale modulation source

```gdshader
// near :392/:427 — additive, PORT APPROXIMATION, no new sampler/binding needed
float macro = texture(alpha_atlas, alpha_patch_uv(v_tile, fract(v_st / 24.0))).a;
rgb = rgb * mix(1.0, a, mask_to_alpha) * mix(0.88, 1.12, macro) * v_packed + v_specular;
```
Tradeoffs: the only option that adds the multi-scale organic variation the donor samples show, using **donor art** rather than an invented noise field. Still one extra fetch; the 24 m period and 0.88–1.12 range are PORT APPROX and would introduce their own (weaker) repeat; the donor alpha patches are edge-transition masks, so their suitability as a macro multiplier must be A/B'd. The mask patch rule stays UNVERIFIED.

### Option 5 — Diagnostic A/B knob only: change the repeat scale

```gdshader
// :214 — AFTER (diagnostic, PORT APPROXIMATION — breaks the 2 m donor-grounded scale)
uniform vec2 uv_repeat = vec2(0.37, 0.43);
```
Tradeoffs: zero new machinery; if the measured 76 px period shifts to ≈123 px and the streaks change with it, that *proves* the texgen diagnosis. But it abandons the donor `gc_meters_to_tile=2` grounding and keeps an equally rigid repeat, so it is a **verification experiment, not a shipping fix**.

---

## 6. Single recommended option

**Recommend Option 1** (mipmaps generated + `filter_linear_mipmap` at `:60`) as the one change to land first.

Rationale: Rank 2 is the amplifier that converts the Rank 1 grating into the *specific* artifact named in this ticket — faint diagonal streaks/moiré at a shallow camera. It is the only option that removes the aliasing mechanism itself rather than merely re-phasing or disguising the repeat; it needs one shader-line edit plus one import flag; it introduces no invented donor constant, no synthetic noise/dither, no new sampler, and no test weakening. It is fully reversible and A/B-able at identical camera.

Timing: a concurrent implementation agent has landed this exact change (see the concurrent-change note in §0); this report recommends it on the evidence of the pre-change frames, and does not itself verify the post-change image.

Stated limitation: Option 1 removes the **streaks**, not the underlying 2 m cell repetition. If a coherent grid remains afterwards, the follow-up should be Option 2 (phase decoupling) and/or Option 4 (donor-art macro variation), each as its own ticket with its own A/B. That is outside this single recommendation.

---

## 7. Guardrail compliance

- No donor-parity claim: visual parity stays **UNVERIFIED**; no donor GPU A/B frame exists; every proposed new constant is explicitly a PORT APPROXIMATION.
- No test weakened; no threshold changed; no `expected_pre_fix_failure` flipped.
- No synthetic dither/noise/hash field proposed (S-25-09).
- No Godot launch and no `godot_runner.py` job submitted; no code, shader, asset, config or test file edited.
- Only this report file was created.
