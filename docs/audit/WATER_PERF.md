---
title: Water-rendering strategy evaluation for Godot 4 Compatibility
owner: T2-WATER-3
lane: RESEARCH only (read-only)
decision_context: "P-21 (water DONE — partial), TB-B1c, N-07 bake/frame gate"
updated: 2026-11-21
status: complete
scope: "No code edits, no Godot runs, no donor copies. Donor files were opened read-only on the private-use install; no bytes were exported into the repo."
files_written: "docs/audit/WATER_PERF.md (exactly one)"
---

# 💧 WATER_PERF — water strategy comparison (Cossacks 3 → Godot port)

> [!IMPORTANT]
> All numbers below are tagged `observed` (direct file read / Pillow metadata / Godot
> docs), `derived` (arithmetic from observed constants) or `inferred` (order-of-magnitude
> estimate with stated assumptions, **not measured**). This agent did **not** run Godot,
> did not edit code, and did not copy any donor asset. GPU costs are estimates only.

---

## 1. Baseline — what actually ships today (`observed`)

| Item | Evidence |
|---|---|
| Renderer is **Compatibility** | `app/project.godot:25-26` — `renderer/rendering_method="gl_compatibility"` (desktop + mobile); `:9` features include `"GL Compatibility"`. |
| Water is already a **single full-map `canvas_item` overlay shader** | `app/scripts/world.gd:69-72,803-848`; `app/shaders/water_overlay.gdshader:1-2`. `Sprite2D` with `z_index=-9` (above baked terrain `-10`, below resources `1`). |
| One RGBA8 mask baked **once at bind**, not per chunk | `world.gd:829-838` — 160×160 mask; `R`=type-3 coverage, `G`=depth/1.07, `B`=depth/0.57, `A`=1; `height_at()` sampled once per tile. |
| Time advances **every frame** | `world.gd:1226` `anim_t += dt`, `:1229-1230` `water_mat.set_shader_parameter("time", anim_t)`. |
| Shader work per water pixel | `water_overlay.gdshader:45-90`: 1 mask fetch + `field()`×3 × 3 fetches (9) + 2 foam fetches = **~12 texture fetches**, ~6 `pow()` calls (170/120/5/24/5/7), plus ALU; `discard` at `:48` skips dry land (`coverage < 0.004`). |
| Textures bound | `world.gd:823-826`: `wave0`=`diffusewaves0.png`, `wave1`=`diffusewaves1.png`, `wave2` and `foam_tex`=`diffusewaves2.png` (512² mirror-tiled). All are local converted PNGs; no donor file is read at runtime. |
| Dead code removed | `world.gd:792-795` — the old `variants[3]` four-crop set was deleted; no per-chunk water re-bake. |
| No screen/depth/cubemap use anywhere in `app/` | Repo-wide grep for `BackBufferCopy|hint_screen_texture|hint_depth_texture|samplerCube|Cubemap` → **no matches**. |
| Wave PNG import has **no mipmaps** | `water_png/diffusewaves*.png.import` — `mipmaps/generate=false`; minified wave sampling can alias (inferred visual risk). |

**Conclusion (`observed`):** strategy **A is already implemented**. This audit therefore
compares "keep/harden A" against four alternatives rather than proposing a greenfield build.

### Perf gate — important discrepancy (`observed` vs task brief)

- `app/shots/perf.md:215-258` records the **measured** N-07 result: `BAKE_BENCH ... max_ms=645.24 mean_ms=526.63` (job `qa1-bench-4`, ticket 639) → **FAIL** vs the `< 250 ms` target. `:241-251` notes it is cold-cache dominated and that only ~12–20 bakes occurred, but the verdict is still FAIL. The cost is in `_build_chunk`, **not** in the water overlay setup.
- The task brief for this agent states "N-07 gate now **50 ms** max bake, target 250 ms". No `50 ms` figure exists anywhere in `docs/` or `app/shots/perf.md` (grep). I cannot corroborate it; I treat **≤ 250 ms** as the operative gate and explicitly flag the 50 ms figure as **unverified brief text**. Every strategy below states its bake impact relative to both.

---

## 2. Donor fidelity targets (condensed from `TERRAIN_DONOR_WATER.md`, all `observed` there)

Five features make the donor read as "water": (1) per-frame GPU wave scroll (`time` uniform,
two shift directions, 3+9 octave fBm off a 256² `waveMap`); (2) depth-driven shallow→deep
colour and alpha (`coastfade` 0.57, `deepwater_fadedepth` 1.07, `watercolor`/`watercolor2`);
(3) projected reflection distorted by wave normals (`texture2DProj(reflectionMap, refuv)`,
`hdrMultiplier`); (4) sun-linked specular glints (`pow(grad,170/120)`, `water_specularcolor`,
light direction from `light.cfg`); (5) procedural foam confined to the coast band (`nautic()`,
`particles()`). Foam is **procedural** — no foam texture exists in the donor `water/textures/`.

Donor cubemap facts (`observed` this audit, private-use read only):
`C:\Games\Cossacks 3\data\materials\cubemap\cubemap_c00..c05.bmp` — six **128×128 RGB** BMPs,
49,180 B each (~288 KiB raw). `data\materials\ref\refcubemap.mat:24-33` maps them
PX/NX/PY/NY/PZ/NZ with `mappingmode = tmmCubeMapReflection`, `magfilter=maNearest`,
`minfilter=miNearestMipmapNearest`, `Compression=tcHighSpeed`. **UNVERIFIED** (also in TDR-4 §6):
the plaintext never binds this cube map to the water shader's `reflectionMap`; the observed
water path is a *projected* reflection. A converted cube map would therefore be a plausible
environment map, not a proven donor-water input.

---

## 3. Approach comparison table

Cost assumptions (`derived`/`inferred`, **not measured**): 1920×1080 viewport = 2.07 Mpx;
water ≥ 25% ⇒ ~0.52 M water-pixel shades/frame; 60 fps ⇒ ~31 M water-shades/s. One
full-screen RGBA8 back-buffer copy = 8.3 MB/frame ≈ 0.5 GB/s at 60 fps → roughly 0.6–1.7 ms
on a weak integrated GPU (inferred, with driver sync possibly more; Godot issue #108935 flags
a "high performance impact" for `hint_screen_texture`). Fetch/ALU costs below are order-of-magnitude.

| # | Strategy | Required assets | Godot 4 Compatibility feasibility | Est. per-frame cost (`inferred`) | Fidelity ceiling | Exact file(s) that would change |
|---|---|---|---|---|---|---|
| **A** | Current full-viewport `canvas_item` shader, `uniform sampler2D` wave sheets (already shipped) | 3 local PNGs (`diffusewaves0/1/2.png`) + 160×160 bake-time RGBA mask — **all present** | **Yes, native.** `canvas_item` + `sampler2D` + `fract()` repeat; no compute, no SDFGI, no 3D effects. `water_overlay.gdshader:15-19` compiles on GL Compatibility | ~12 fetches + ~6 `pow` + ~40 ALU per water pixel ⇒ ~6.2 M fetches/frame, ~375 M/s; ~1–3 ms on weak GPU. **Zero added CPU/bake cost.** | High for depth tint, glints, foam; **no true reflection/refraction**. Fine wave detail limited by authored PNGs and no mipmaps (aliasing at minify) | **None** (already in `app/shaders/water_overlay.gdshader`, `app/scripts/world.gd`). Hardening touches only these two |
| **B** | `hint_screen_texture` refraction in `world.gd` overlay | None new | **Technically supported** (docs feature table: screen texture ✔ in Compatibility) but **architecturally wrong here**: overlay z=-9 draws before units z=3/buildings z=2, so the copy contains terrain only; needs `BackBufferCopy` if any other screen-reader appears | Adds **1 full-screen copy** (~8.3 MB/frame, ~0.6–1.7 ms+) + 1 screen fetch/pixel; total ~13 fetches ⇒ ~7 M/frame. Also breaks the "one quad, no screen work" property (`water_overlay.gdshader:9`) | Refraction distortion only; **reflection of scene objects is impossible** with current z-order; shoreline land-bleed and stale-buffer artefacts | `app/shaders/water_overlay.gdshader` (uniform + `SCREEN_UV` sample), `app/scripts/world.gd` (add `BackBufferCopy`/z-order). No new asset |
| **C** | Donor cube-map reflection from `cubemap_c*.bmp` (private-use conversion) | **6 donor BMPs must be converted** into a Godot `Cubemap` resource (~288 KiB). Not in repo; requires a one-time conversion tool and licence review | **Feasible but non-trivial.** `samplerCube` is supported in Compatibility (`samplerCubeArray` is **not**); editor creation of Cubemap is regressed (Godot issue #65665), so build must assemble it via `Cubemap.create()`/`set_side()` + `ResourceSaver` (or a Python→PNG intermediate) | +1 cubemap fetch/pixel (~0.52 M/frame) — cheaper than B; one-time ~0.3 MB asset load. No per-frame copy | **Static sky/environment reflection**, mirrored by wave normals; no live objects, no shoreline-aware projection. Donor binding UNVERIFIED ⇒ may not match donor water at all | New `app/tools/convert_donor_cubemap.*`, new `app/assets/terrain/water_png/cubemap_donor.res`, `app/scripts/world.gd` (bind uniform), `app/shaders/water_overlay.gdshader` (`samplerCube` + `reflect()`) |
| **D** | Purely procedural fBm in-shader (no textures) | None; **deletes** the 3 wave PNG bindings | Possible in GLSL ES 3.0, but ~18–30 hash-noise octaves × ~30 ALU to emulate the donor's 9-octave `water_map`; donor's own non-`.dev` shader uses 11-octave procedural height (TDR-4 §3c) — a real precedent for the cost | ~600–900 ALU/pixel × 0.52 M = ~300–470 M ALU/frame (~20–28 GALU/s at 60 fps) — **likely over budget on the weak GPU**; removes all texture fetches | **Lower**: authored 256² donor wave art is replaced by generic value noise; glints/foam still possible but the specific donor look is lost | `app/shaders/water_overlay.gdshader` only; `app/scripts/world.gd` can drop 3 texture binds (optional) |
| **E** | Hybrid: bake more depth/shore/normal proxy data once, keep a cheap shader | No new assets; widen the existing bind-time mask from 3 channels to e.g. R=coverage, G=depth/1.07, B=depth/0.57, A=shore-band width; optional low-res baked normal atlas from existing PNGs | **Yes**, same as A; the extra work is in `_setup_water_overlay()` at **bind** (25,600 tiles), never in `_build_chunk`, so N-07 bake is untouched | Shader drops from ~12 to ~3–5 fetches ⇒ ~0.3–1 ms (inferred). Bind-time bake grows by ~25.6 k `height_at()` calls once (already paid once today) | Same ceiling as A, minus fine detail if proxies are too coarse; adding a baked normal atlas recovers most of it | `app/scripts/world.gd` (mask channels, bind), `app/shaders/water_overlay.gdshader` (consume fewer fetches) |

---

## 4. Per-approach notes and artefact analysis

### A — current wave-sheet overlay (baseline)
`field()` (`:35-43`) samples three independently scrolled sheets and weights 0.42/0.32/0.26;
finite differences `hx/hy` (`:56-60`) reconstruct a normal; `:63-75` do depth tint + glints;
`:80-85` do coast-band foam. This covers donor features 1, 2, 4, 5; only projected reflection
(3) is absent. `discard` at `:48` limits work to water cells. Two known weak points: (a) `foam_tex`
is bound to the *same* texture as `wave2` (`:826`), so foam and swell noise are correlated rather
than independent donor octaves; (b) no mipmaps on imports → shimmer when zoomed out (inferred).
Both are cheap fixes with no new assets and no perf impact.

### B — screen-texture refraction
Godot docs: "when `hint_screen_texture` is first found in a node that is about to be drawn,
Godot does a full-screen copy to a back-buffer"; overlapping readers need `BackBufferCopy`.
Consequences for this port (`derived` from z-order at `world.gd:847,842` and `:192-206`):
- The overlay at z=-9 is drawn before resources/buildings/units (z=1/2/3), so a screen sample
  contains only baked terrain. Calling this "reflection" overstates it — it is **refraction of
  the substrate** at best.
- Jittered UVs near the shoreline pull land pixels into water pixels (edge bleed); without a
  depth buffer for this 2D scene there is no way to reject them. (`hint_depth_texture` *is*
  supported in Compatibility per docs, but a pure Sprite2D scene has no meaningful depth
  variation — so depth-aware rejection is unavailable for a reason unrelated to renderer support.)
- Adds a full-screen copy every frame and a screen fetch per pixel; Godot issue #108935 reports
  high impact. **Reject as default.**

### C — donor cube map
Face order and mapping are explicitly in `refcubemap.mat:24-29`, so conversion is deterministic.
Cost per frame is one cubemap fetch — cheaper than B. Two blockers: (1) it is a **static**
environment capture (128² faces, nearest/mipmap-nearest), so no units, ships or shoreline appear
in it; (2) the donor binding is **UNVERIFIED** — TDR-4 §6 already flagged that the plaintext
uses a *projected* `reflectionMap`, not the cube map. Additionally, Godot 4 cannot create
Cubemap resources in the editor (issue #65665 open), so a build-time tool is required. Viable as
an **optional, licence-reviewed** later ticket; not justified as the default path.

### D — procedural fBm
Replaces 11 texture fetches with ~18–30 value-noise octaves. On a weak GPU this is the highest
per-pixel ALU of the five options and the most likely to miss a 16.7 ms frame budget, while
*lowering* fidelity relative to the authored donor wave art. Donor's own 11-octave `.frag` is a
precedent for the cost, not for the value. **Reject.**

### E — baked-proxy hybrid
This is the natural evolution of A: the mask is already baked once at bind (`:829-838`), so
adding a fourth channel (shore-band width, precomputed glint mask, or a low-res normal atlas
derived from the existing sheet) moves work from per-frame to one-time. Critical guard: the
extra loop must stay in `_setup_water_overlay()` — **never in `_build_chunk`** — otherwise it
would add to the already-failing `BAKE_BENCH` 645.24 ms (`perf.md:223`).

---

## 5. Recommendation

**Recommend strategy A, hardened with E-style baked proxies; do not adopt B, C or D now.**

Reasoning:
1. **A is already shipped and paid for** (`water_overlay.gdshader`, `world.gd:803-848`). It
   already delivers four of the five donor water features with no donor asset conversion, no
   screen copy and no extra bake.
2. **N-07 is already red** (645.24 ms measured, `perf.md:223`). B/C/D all add GPU work and C
   adds an asset pipeline; none reduce the failing bake metric. E reduces per-frame fetch count
   without touching `_build_chunk`.
3. **Compatibility fit**: A/E use only `canvas_item` + `sampler2D`, the cheapest supported path.
   B's framebuffer copy and C's Cubemap resource creation are supported but carry complexity
   that the current gate cannot absorb.
4. **Fidelity/effort**: the remaining donor gap (projected reflection) is the one feature whose
   donor source binding is UNVERIFIED (TDR-4 §6). Converting the cube map on that evidence risks
   shipping a static sky reflection that is not even what the donor water used.
5. **Optional later**: after a windowed GPU measurement exists, revisit C as a separate,
   licence-reviewed ticket (static sky reflection only), and only if A/E show >2 ms headroom.

---

## 6. Implementation sketch (recommended A+E; no code written by this agent)

Files: `app/shaders/water_overlay.gdshader` (tuning/uniforms, fetch reduction) and
`app/scripts/world.gd` (`_setup_water_overlay()` mask channels + uniform binding, `sync()`
time advance). No new asset, no donor conversion, no BackBufferCopy.

Uniform list (kept from today, plus proposed additions; `TEXTURE` is the baked mask):

| Uniform | Type | Source / intent | Status |
|---|---|---|---|
| `TEXTURE` (built-in) | `sampler2D` | 160×160 RGBA mask: `R`=coverage, `G`=depth/1.07, `B`=depth/0.57, `A`=shore-band width (new) | keep; `A` proposed |
| `time` | `float` | `world.gd:1226,1230` — `anim_t += dt` every frame | keep |
| `sun_dir` | `vec2` | `world.gd:820` — `(-0.3447/4, 0.9387)` from `light.cfg` | keep |
| `map_size` | `vec2` | `world.gd:821` — `(160, 160)` | keep |
| `tile_m` | `float` | `world.gd:822` — `Data.TILE_M = 2.0` | keep |
| `wave0`, `wave1`, `wave2` | `sampler2D` | `world.gd:823-825` — three distinct donor sheets | keep |
| `foam_tex` | `sampler2D` | currently same as `wave2` (`:826`); bind a 4th sheet (`diffusewaves3.png`) to decorrelate foam | **change binding only** |
| `shallow_color`, `deep_color`, `spec_color` | `vec3` | replace the three `const` at `:27-29` so palette can be tuned without recompiling | proposed |
| `coast_fade`, `deep_fade` | `float` | replace `const` at `:30-31` (0.57 / 1.07) | proposed |
| `wave_gain`, `spec_gain`, `foam_gain` | `float` | expose the hand-tuned 1.2 / 8.0·4.0 / 0.9·0.5 multipliers (`:60,71-72,85`) | proposed |
| `low_detail` | `bool`/`float` | low preset: skip `hx/hy` finite differences (use `h` only) and one foam sample → ~7 fetches | proposed, perf-gated |
| ~~`hint_screen_texture`~~ | — | deliberately **not** added | reject (B) |
| ~~`samplerCube`~~ | — | deliberately **not** added | defer (C) |

Sketch of the bind-time mask extension (description, not code): at `world.gd:831-838`, keep
`wet`, `dep`, and additionally compute a normalized distance-to-shore term from the type-3 grid
(one 4-neighbour check per tile, 25.6 k checks once at bind) into `A`; the shader then reads the
foam band from `A` instead of deriving it from two depth proxies. This removes one `smoothstep`
and makes foam width independent of terrain slope. Do **not** move any of this into
`_build_chunk` (`:1063-1088` in the current file numbering; see `perf.md:218-219`).

---

## 7. Measurable acceptance criteria

Frame-time / bake (`derived` from `perf.md` gate definition; all require a **windowed** run —
this container has no display, `perf.md:93-105`):

| Metric | Method | Threshold |
|---|---|---|
| Max single-frame chunk bake (N-07) | existing `BAKE_BENCH ... max_ms=` emitter (`perf.md:218-239`), low preset, 120 frames, 2-chunks/frame + LRU 24 unchanged | **≤ 250 ms** (current 645.24 ms = FAIL); if the brief's 50 ms gate is authoritative, ≤ 50 ms instead — resolve with owner first |
| Bake regression from water changes | run identical `qa1-bench-4` overlay before/after; compare `max_ms`/`mean_ms` | after ≤ before (no new ms in `_build_chunk`) |
| Mean frame-time delta, water ≥25% of 1920×1080 | windowed capture, 10 s, 60 fps target | +< 2 ms mean vs baseline A |
| Worst per-frame time | same capture | no frame > 250 ms; 0 new resource loads per frame |
| Shader fetch count | static source count at `water_overlay.gdshader` | A ≤ 12; A+E ≤ 5 on low preset |

Visual metrics (`derived` from TDR-4 W-1..W-4 acceptance):

| Metric | Method | Threshold |
|---|---|---|
| Per-frame motion | two frames 100 ms apart, standing camera, water-only crop pixel diff | > 0; phase advances ≥ 1 px at `view_scale=1` |
| Depth colour | sample a shallow cell (depth < 0.15 m) and a deep cell (> 1 m) | ≥ 20/255 difference in ≥ 1 RGB channel |
| Moving glints | same deep pixel at t and t+0.5 s | luminance difference ≥ 0.1 |
| Foam confinement | coastline screenshot | foam pixels inside the 0.57 m band; **0** foam pixels at depth > 1.07 m |
| No new screen artefacts | shoreline zoom | no land-bleed fringe inside water, no stale-backbuffer ghosting (this is why B is rejected) |

---

## 8. Claim table

| # | Claim | Evidence | Method | Verdict |
|---|---|---|---|---|
| 1 | Renderer is Compatibility | `project.godot:25-26` | observed | **Confirmed** |
| 2 | Water already uses a per-frame `canvas_item` overlay with 3 wave textures | `world.gd:69-72,803-848,1226-1230`; `water_overlay.gdshader:15-19` | observed | **Confirmed** — A is shipped, not hypothetical |
| 3 | Water overlay does not re-bake chunks per frame | `world.gd:792-795,829-838`; `perf.md:218-219` | observed | **Confirmed** |
| 4 | N-07 currently fails at 645.24 ms vs 250 ms | `perf.md:215-239` | observed | **Confirmed (measured, engine-emitted)**; cold-cache caveat at `:241-251` |
| 5 | Task brief's "50 ms max bake" | task prompt only | observed (absence) | **UNVERIFIED** — no such figure in repo; 250 ms used as operative gate |
| 6 | Donor cubemaps are six 128×128 RGB BMPs mapped PX..NZ | Pillow metadata + `refcubemap.mat:24-33` | observed | **Confirmed** |
| 7 | The cube map is the donor water reflection source | TDR-4 §6; `water.dev.frag` uses projected `reflectionMap` | observed (absence of binding) | **UNVERIFIED** — do not treat as fact |
| 8 | `hint_screen_texture` causes a full-screen copy; overlapping readers need `BackBufferCopy` | Godot screen-reading shaders doc; issue #108935 | observed | **Confirmed** |
| 9 | `samplerCube` works in Compatibility; `samplerCubeArray` does not | Godot shading-language reference (data types table) | observed | **Confirmed** |
| 10 | `hint_depth_texture` is unavailable in Compatibility | — | observed (contradicted) | **False** — docs feature table marks it supported; it is useless *here* because the scene is 2D, not because the renderer forbids it |
| 11 | A costs ~12 fetches / water pixel | `water_overlay.gdshader:39-42,46,55-57,81-82` | derived | **Confirmed by static count**; runtime GPU time unmeasured |
| 12 | B/C/D per-frame numbers in §3 | cost model in §3 | inferred | **Estimates only** — no Godot run was permitted |
| 13 | E's extra baking is free with respect to N-07 | `world.gd:829-838` is bind-time; `perf.md:218-219` bake is `_build_chunk` | derived | **Confirmed conditionally** — only if extra work stays in `_setup_water_overlay()` |
| 14 | Foam and swell noise are currently correlated | `world.gd:825-826` binds both `wave2` and `foam_tex` to `ter_water` | observed | **Confirmed** |
| 15 | Donor has no foam texture; foam is procedural | TDR-4 §2/§4 | observed (prior doc + donor listing) | **Confirmed** |

---

## 9. Out of scope / open questions

1. No windowed GPU timing exists (`perf.md:93-105`); all per-frame numbers are estimates. QA must measure A vs A+E before claiming a frame-time win.
2. Resolve the brief's "50 ms" vs repo's "250 ms / 645.24 ms FAIL" with the gate owner.
3. Whether the retail donor binds `refcubemap` to water remains open (TDR-4 §8 Q2, Q4) — a binary/runtime check is needed before any C ticket.
4. If C is ever pursued: licence review of donor BMP conversion is mandatory; this agent copied nothing.
5. `variants[3]` deletion (`world.gd:792-795`) is already in the repo — no further action in this lane.

**Bottom line:** keep the shipped A overlay, apply the two zero-cost fidelity fixes (decorrelate
`foam_tex`, add mipmaps or a low-detail preset path), and move extra shore data into the existing
bind-time mask (E). That improves fidelity and can only reduce per-frame fetch count, while
leaving the failing chunk-bake gate untouched. B, C and D should stay rejected until measured
headroom and a verified donor binding exist.
