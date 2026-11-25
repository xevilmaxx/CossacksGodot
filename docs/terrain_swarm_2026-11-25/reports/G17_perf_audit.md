---
id: G17-PERF-AUDIT
ticket: TERRAIN-SWARM-2026-11-25 / G17 (read-only performance budget audit)
date: 2026-11-25
status: COMPLETE__READ_ONLY__NO_GODOT_JOBS
labels: [observed, derived, inferred, UNVERIFIED]
files_created:
  - docs/terrain_swarm_2026-11-25/reports/G17_perf_audit.md
files_edited: []
godot_jobs_run: 0
runner_jobs_submitted: 0
parity_guard: "No donor GPU A/B frame exists (CHARTER §3). Every cost figure below is a static/analytical estimate labelled INFERRED or UNVERIFIED. Nothing here is a benchmark, a frame-time measurement, or a donor-parity claim."
---

# G17 — performance budget audit of the B01+B02 shader/atlas path

## 0. Scope compliance

Read-only. Exactly one file created (this report); no code, shader, config, test or loader
file edited; no Godot process started and no runner job submitted (WAVE_G_CHARTER § "Only G04
submits runner jobs"). Inputs read in full: `WAVE_G_CHARTER.md`, `docs/terrain_swarm_2026-11-25/CHARTER.md`,
`reports/B01_shader_impl.md`, `reports/B02_atlas_impl.md`, `reports/A06_filtering_aliasing.md`,
and `docs/coord_swarm_2026-11-25/UX_LOADING.md`. Source verified directly:
`variant3d/shaders/terrain_tileindex.gdshader`, `variant3d/scripts/tile_atlas_loader.gd`,
`variant3d/scripts/world3d_terrain.gd`, `variant3d/scripts/world3d.gd`, `variant3d/scripts/main.gd`,
`variant3d/project.godot`, plus the on-disk atlas PNG size and the weak-GPU context record in
`docs/coord_swarm_2026-11-24/reports/AUDIT3D_09_runtime_proof.md:27`.

**No GPU A/B was run and no frame time was measured.** All throughput figures are order-of-magnitude
reasoning from instruction/fetch counts and published hardware classes, labelled **INFERRED**;
anything requiring a run is **UNVERIFIED**.

## 1. OBSERVED — what the integrated path actually executes

### 1.1 Shader, as landed (`terrain_tileindex.gdshader`)

| Site | Code (verified by direct read) | Change origin |
|---|---|---|
| `:60` | `uniform sampler2D tile_atlas : filter_linear_mipmap, repeat_enable;` | B01 (was `filter_nearest_mipmap`) |
| `:314-316` | `v_st = (texture_matrix * vec4(st,0,1)).xy;` then `v_alpha_uv = v_st * uv_repeat * alpha_uv_scale;` — `fract()` removed from vertex stage | B01 A06-F2 patch |
| `:329-338` | `tile_rgb(float idx, vec2 local_uv)`: `cell`/`key`, `v = mod(key.x+3*key.y, 4)`, `f` from four `step`s, `warp = 0.125*vec2(sin(dot(v_st,...)), cos(dot(v_st,...)))`, `inset = 0.5 / max(vec2(textureSize(tile_atlas,0))/max(atlas_grid,vec2(1)),vec2(1))`, `uv = mix(inset, 1-inset, fract(mix(local_uv,1-local_uv,f)+warp))`, `textureGrad(tile_atlas, (cell+uv)/atlas_grid, dFdx(v_st*uv_repeat)/atlas_grid, dFdy(v_st*uv_repeat)/atlas_grid)` | B01 + A06-F2 patch |
| `:417` | `a = texture(alpha_atlas, alpha_patch_uv(v_tile, fract(v_alpha_uv))).a;` | B01 A06-F2 patch (wrap moved to fragment) |
| `:419` | `a = mix(mix(1.0, clamp(a,0.35,1.0),0.5), 1.0, step(2.5,scol)*step(2.5,srow));` | B01 A02-P1/P4 |
| `:392` | `vec3 rgb = tile_rgb(v_tile, fract(v_st*uv_repeat));` — byte-identical A/B anchor | unchanged |

`tile_rgb()` is called **once per fragment** from `fragment()`; the mask path (`:412-419`) is
a second, separate `filter_nearest`, mip-less texture fetch (512×256 `alpha.png` / 1024×512
`alphavert.png`). The mask UV changed but the **mask fetch count did not** — still one nearest
texel per fragment (OBSERVED code; INFERRED cost).

### 1.2 Atlas supply, as landed (`tile_atlas_loader.gd`)

- `:350-356` `_prepare_atlas_image()` → `img.generate_mipmaps(false)` on the CPU, guarded by
  `img.has_mipmaps()`; called from `:285` (`_load_single`) and `:416` (`_load_split`).
- `MODE_ARRAY` still builds its `Texture2DArray` without mips (A06 §6 Fix 1, not landed).
- On-disk PNG: **179,912,941 bytes** (measured with `Get-Item` this audit), 16384×8192 RGBA →
  decoded base level **536,870,912 bytes = 512.0 MiB** (A06 §1.2, B02 §6 #3).

### 1.3 Call chain that places mip generation on the main thread (OBSERVED)

`main.gd:584-588`: after `_loading_tick(0.90, "Loading art...", gen)` the body calls
`world = make_world3d(); world.bind(game)` synchronously → `world3d.gd:599 bind()`,
`:639 terrain.build()` (comment: "ONE full-grid mesh; no chunk scheduling") →
`world3d_terrain.gd:1301 build()`, `:1341 _load_atlas()` → `:651 loader.call("load")` →
`:285`/`:416` → `_prepare_atlas_image()` → `img.generate_mipmaps(false)`.

`_loading_tick()` awaits only **between** stages (`main.gd:521-528`, per `UX_LOADING.md:54-55`),
so the whole "Loading art..." stage body — including the mip build and the subsequent 683 MiB
texture upload — runs inside one frame on the main thread. This is the same structural cause
`UX_LOADING.md` records as owner symptom S3 ("loading freezes the Windows window (cannot move
it)") and S4 (work continuing after overlay removal) — see §6.

### 1.4 Documented target hardware

`AUDIT3D_09_runtime_proof.md:27` records a real windowed context:
`OpenGL API 3.3.0 NVIDIA 571.96 - Compatibility - Using Device: NVIDIA - NVIDIA GeForce MX130`.
`project.godot:9` features `("4.4","GL Compatibility")`, `:25-26` `gl_compatibility`,
1280×720 viewport at `:15-16`. `GUIDE4.md:244-246` separately records a "weak GPU ... multi-second
hitch" on *terrain bake* — context that multi-second main-thread hitches are an existing project
concern, **not** a measurement of this shader/mip path.

## 2. Cost ledger — per-fragment work added by B01/B02

Counts below are static readings of the shader source. "Class" is a relative cost class, not a
measured time. All labels **INFERRED** unless marked OBSERVED (the code itself).

| # | New operation | Site | Per fragment | Mechanism / relative class | Label |
|---|---|---|---|---|---|
| 1 | Mirror variant `v=mod(kx+3ky,4)` + 4×`step` → `f` | `:331-333` | ~2 `mod`/`floor`, 4 `step`, 2 `mix` | Pure ALU, **branch-free**, cell-constant (all fragments in a 2 m cell agree → no divergence). Replaces *no* fetch; it changes UV inside the same fetch. | OBSERVED code; cost INFERRED negligible |
| 2 | `sin`/`cos` warp (2 dots + 2 transcendentals + 2 mul) | `:334` | 2 SFU ops, ~6 ALU | SFU throughput is a fraction of ALU on Maxwell-class parts. At 1280×720 with ~0.4–0.9 of pixels terrain → ~0.4–0.83 M fragments → ~0.8–1.7 M SFU/frame; ×60 fps = ~50–100 M SFU/s. Against an order-of-magnitude ~10² G SFU/s class budget that is **≪1 %**. Polynomial sin/cos cost ~8–16 ALU-eq each still leaves a few percent at most. | INFERRED from architecture; **no measurement** |
| 3 | `textureSize(tile_atlas,0)` for inset | `:335` | 1 "fetch" of a texture *parameter* | Texture dimensions are an immediate/uniform-like value; a compiler should fold it to a constant. Even if not folded, it is not a texel read. Risk only if the Compatibility GLSL translator emits a real query — UNVERIFIED without disassembly. | INFERRED negligible / UNVERIFIED translator behaviour |
| 4 | Half-texel inset `mix(inset,1-inset,fract(...))` | `:335-336` | ~6 ALU | Constant-derived clamp; no fetch. | INFERRED negligible |
| 5 | `textureGrad` with explicit `dFdx/dFdy` of the **unwrapped** varying | `:337` | 2 derivative ops (per quad) + 1 texture fetch | Replaces implicit-derivative `texture()`. It removes the LOD≈10 seam spike (A06 §3.4) at roughly **neutral** cost: two explicit derivatives replace the two implicit ones the driver would have computed. The gradient is taken before mirror/warp; mirror is a fold (|d|=1) and warp derivative is ~0.125×0.13 ≈ 0.016 rad/m vs base phase 0.5/m (~3 %), so LOD selection remains valid — INFERRED/DERIVED, not an A/B result. | INFERRED ~neutral vs baseline `texture()` |
| 6 | `filter_linear_mipmap` on `tile_atlas` **with real mips now present** | `:60` + loader `:350` | 1 trilinear fetch = **2 bilinear levels × 4 taps = 8 texel reads** | **This is the dominant per-fragment increase.** BASELINE was `filter_nearest_mipmap` on a one-level texture → clamp to L0 → 1 nearest texel/fragment. Now ~8 texels/fragment at L3/L4 (A06 §2 derived ≈10–14 atlas texels/px → log₂≈3.4–3.9). ~8× texel *fetch count*, but from 8 MiB/2 MiB levels instead of 512 MiB L0, so cache locality improves. | INFERRED; no A/B |
| 7 | Mask wrap moved vertex→fragment | `:316`, `:417` | same 1 nearest mask fetch | UV values changed (intra-cell variation restored); **no extra fetch, no mip** on mask samplers. | OBSERVED code; cost INFERRED neutral |
| 8 | Sentinel guard + P4 contrast compression | `:419` | ~5 ALU | No fetch, no branch. | INFERRED negligible |

**Net per-fragment picture (INFERRED):** ALU roughly ×2–3 vs the pre-B01 shader, SFU +2 ops,
texel fetches on `tile_atlas` ×8. In absolute terms 921,600 px × 8 taps × 4 B ≈ **29 MB/frame**,
≈**1.8 GB/s at 60 fps** if terrain fills the screen. An MX130-class part has tens of GB/s of
DRAM bandwidth (class value, UNVERIFIED for the exact board), so this is **a low-single-digit
percentage of peak bandwidth**, and much of it is served from cache at L3/L4. The real budget
risk is **capacity**, not throughput (§3).

## 3. Atlas VRAM and the mip-generation stall

### 3.1 VRAM capacity (DERIVED arithmetic from OBSERVED dimensions)

| Level | Size | Bytes |
|---|---|---|
| L0 | 16384×8192 | 536,870,912 (512.0 MiB) |
| L1 | 8192×4096 | 134,217,728 (128 MiB) |
| L2 | 4096×2048 | 33,554,432 (32 MiB) |
| L3 | 2048×1024 | 8,388,608 (8 MiB) |
| L4 | 1024×512 | 2,097,152 (2 MiB) |
| L5…L13 | … → 1×1 | ~1.0 MiB total |
| **Full chain** | ×4/3 geometric sum | **≈715,827,882 B ≈ 682.7 MiB** |
| **Added by B02** | chain − L0 | **≈178,956,970 B ≈ 170.7 MiB (+33 %)** |

Matches B02 §6 #3 and A06 §7. On a 2 GB MX130 this atlas alone is ~33 % of VRAM; on a 1 GB
board it is a serious allocation risk; on 4 GB it is comfortable. The exact board's VRAM and the
rest of the resident set are **UNVERIFIED** — no `nvidia-smi`/runner evidence in this audit.
Lowering `mipmaps/limit` cannot help: each level is ≤1/4 of the previous, so capping levels saves
at most a few MiB.

### 3.2 CPU build → startup hitch (main question of this ticket)

`generate_mipmaps(false)` must read 512 MiB of base pixels and write ~171 MiB of smaller levels:
**≥683 MiB of memory traffic**, plus the already-existing 180 MiB PNG → 512 MiB decode. A
theoretical floor at 10–20 GB/s weak-CPU bandwidth is ~35–70 ms; Godot's CPU box-filter build is
single-threaded to the author's knowledge (**INFERRED — implementation not inspected here**), so
a realistic range is **hundreds of milliseconds to a few seconds**. **UNVERIFIED** — never profiled.

Placement is the problem: per §1.3 this runs synchronously inside the "Loading art..." stage on
the main thread, with no worker thread (UX_LOADING §2: "No worker thread is present"). Therefore:

- **S3 (window freezes, cannot move it):** B02's mip build is *new main-thread work added to a
  stage the owner already complained about*. Expect it to **worsen** S3. Label **INFERRED** (direct
  call-chain evidence + known synchronous stage bodies; no measurement).
- **S4 (work continues after overlay disappears):** the mip build itself completes **before**
  `_hide_loading()` (`main.gd:643-645`), so it is not a post-hide CPU task. A possible post-hide
  GPU upload/first-draw hitch is **UNVERIFIED**.
- The `.import mipmaps/generate=true` edits (B02) do **not** add a second runtime build: the
  loader path uses `Image.load()` and bypasses the import resource (B02 §1, A06 §1.3). They only
  affect editor reimport, timing UNVERIFIED.
- `MODE_ARRAY` has no mips (A06 §6 Fix 1) — if the atlas falls back to array mode the shader
  silently returns to the aliased baseline; that is a correctness gap, not a perf saving.

## 4. Project settings — anisotropy / MSAA (OBSERVED)

`variant3d/project.godot:21-28` contains only `gl_compatibility` (×2),
`textures/canvas_textures/default_texture_filter=1` and `environment/defaults/default_clear_color`.
There is **no** `rendering/textures/default_filters/anisotropic_filtering_level`, no
`use_nearest_mipmap_filter`, no `texture_mipmap_bias`, no `anti_aliasing/quality/msaa_3d`, no
`screen_space_aa`, no `scaling_3d/scale`. Therefore:

- **Anisotropy is not set.** Engine default level is 2, but it is **inert for this sampler**:
  the custom `sampler2D` hint is authoritative (A06 §1.1, Godot issue #74332) and `:60` says
  `filter_linear_mipmap`, **not** `_anisotropic`. B02 deliberately did not enable it (donor is
  `tfIsotropic`, A08 §7 #4). Enabling it would be a PORT APPROX and would raise per-fragment
  fetch count further — not recommended on this GPU without a measurement.
- **MSAA is not set** (default 0). Compatibility supports MSAA/SSAA but not FXAA/SMAA/TAA/FSR2
  (A06 §1.5). MSAA adds coverage samples at *geometry edges* only; it cannot undo texture
  minification aliasing (A06 §3.6, F04 §4 item 13). Turning it on to "fix" terrain would cost
  fill-rate/memory without addressing the artifact. `canvas_textures/default_texture_filter=1`
  is 2D-canvas only and irrelevant here.

## 5. Cheap simplifications that preserve the artifact fix

Ranked by (benefit ÷ risk). All are **INFERRED / UNVERIFIED**; none was implemented by this agent.

1. **Move mip generation off the main thread — highest value, addresses S3 directly.**
   Wrap `_prepare_atlas_image()` in a `WorkerThreadPool` task (or add an await/yield between
   per-cell mip builds in split mode), then construct the `ImageTexture` on the main thread.
   Preserves level-0 bytes, the seam fix and the trilinear path exactly. Risk: Godot `Image`
   thread-safety and upload ordering need verification; would need its own ticket and a windowed
   drag test per `UX_LOADING.md` §4.1. **Do not** implement here.
2. **Hoist `textureSize()`/inset to a uniform** computed once at bind time (e.g. pass
   `0.5/atlas_cell_size` from GDScript where `_atlas_grid` is already known, `world3d_terrain.gd:661`).
   Removes a per-fragment query with *zero* visual change (same numeric value). A06 §6 Fix 2 used
   `textureSize` because "atlas pixel size is not a uniform" (B01 §5 #2), but the cell size is in
   fact available at bind time. Lowest-risk shader micro-optimisation; benefit likely tiny if the
   driver already folds the constant (**UNVERIFIED**).
3. **Precomputed mirror variant table — cheap but low payoff.** Replace the four `step`s at
   `:333` with `uniform vec2 mirror[4]; vec2 f = mirror[int(v)];` (4-entry constant array,
   dynamic index, no texture fetch), or compute `key`/`f` in the vertex stage and pass a varying
   (cell-constant, so 4 vertices per 2 m cell instead of every fragment). Saves ~3–6 ALU/fragment.
   **Answer to the ticket's example:** the variant is *already* a 5-line branch-free ALU formula —
   there is no hash texture or per-pixel random — so a table is a marginal constant-load swap,
   not a meaningful budget win. It preserves the artifact fix because the four mirror states and
   the `fract()` phase continuity are unchanged.
4. **Move the `sin`/`cos` warp to the vertex stage** (pass the warp as a varying). Cuts 2 SFU ops
   per fragment to 2 per vertex (~hundreds× fewer evaluations). Caveat: at 0.13/0.09 rad/m the
   phase changes ~0.26/0.18 rad across a 2 m cell, so interpolated sine differs slightly from
   the exact per-fragment value — visually likely invisible but **INFERRED**, and it would no
   longer be the literal low-frequency phase field B01 validated on paper. **Only after a fresh
   capture**, never as a silent edit.
5. **Do not** reduce the atlas to `filter_nearest`, remove mips, or remove `textureGrad` to save
   cost: each reintroduces one of A06's ranked causes #1/#4/#5 and defeats the artifact fix
   (A06 §5, §6). Do not enable anisotropy/MSAA as a substitute (§4).

**Bottom line on simplification:** the shader's new ALU/SFU work is not where the money is; the
loader's synchronous ~683 MiB mip build is. Optimising the mirror table buys almost nothing.

## 6. Relationship to the owner's loading complaint (UX_LOADING.md)

| Owner symptom | Does B01/B02 affect it? | Label |
|---|---|---|
| S3 "loading freezes the Windows window (cannot move it)" | **Worsened in probability**: B02 adds a synchronous main-thread CPU mip build plus a 683 MiB upload inside the already-synchronous "Loading art..." stage (§1.3, §3.2). No worker thread, no chunk amortisation. | INFERRED (call chain + byte counts); windowed drag UNVERIFIED |
| S4 "after overlay disappears something is still loading" | B02's mip build completes before `_hide_loading()`; not a post-hide CPU task. Possible first-draw texture upload hitch UNVERIFIED. No change to `_hide_loading()` readiness gap (`main.gd:643-645`). | INFERRED / UNVERIFIED |
| R3 acceptance ("drag title bar at every progress stage") | Must be re-run specifically at the **0.90 "Loading art..."** stage after B02 lands; this is the stage most likely to regress. | Recommendation; UNVERIFIED |

## 7. Open questions / UNVERIFIED register

1. No GPU A/B, no frame-time or bandwidth measurement exists — **all** cost ratios in §2/§3 are
   analytical. Do not restate them as measured results.
2. Exact MX130 board VRAM, clock and memory type, and the rest of the resident VRAM set — unknown.
3. Whether Godot 4.7.2's `generate_mipmaps(false)` is single-threaded and its exact cost on this
   CPU — unknown; range in §3.2 is a bound, not a benchmark.
4. Whether the Compatibility GLSL translator folds `textureSize()` to a constant — unknown (would
   need shader disassembly or a driver profiler).
5. Effective cache-hit rate at trilinear L3/L4 on this GPU — unknown; §2's ~1.8 GB/s assumes all
   fetches reach DRAM, so it is a conservative upper bound.
6. `MODE_ARRAY` still lacks mips (A06 §6 Fix 1) and the atlas-bleed seam risk remains (B02 §6 #2);
   both are correctness/visual items, not cost savings.
7. Donor parity remains UNVERIFIED throughout — donor `tfIsotropic`/11-mip art is OBSERVED text,
   but no donor GPU A/B frame exists (CHARTER §3).

## 8. Summary for COORD

- **Per-fragment:** the mirror variant, `textureSize`, inset and sentinel/P4 ALU are branch-free
  and negligible (INFERRED). The warp adds 2 SFU ops/fragment — still a small fraction of an
  MX130-class budget (INFERRED). `textureGrad` is roughly neutral versus implicit derivatives.
  The **only material per-fragment change is trilinear sampling now that mips actually exist**:
  ~8 texel fetches instead of 1, ≈29 MB/frame at 1280×720 — low-single-digit percent of a
  tens-of-GB/s memory budget (INFERRED, conservative bound).
- **Capacity:** 512 MiB → ~683 MiB atlas VRAM (+171 MiB, +33 %). This is the real hardware risk
  (INFERRED arithmetic from OBSERVED dimensions).
- **Startup:** the ~683 MiB CPU mip build runs synchronously on the main thread inside the
  "Loading art..." stage (`main.gd:584-588` → `world3d.gd:639` → `tile_atlas_loader.gd:350-356`),
  so it plausibly **adds to the owner's S3 loading freeze** (INFERRED; windowed drag UNVERIFIED).
  Recommend a follow-up ticket to move mip generation to a worker thread before final gate.
- **Settings:** anisotropy and MSAA are **not** set in `project.godot`; engine-default anisotropy
  is inert for this sampler, and MSAA cannot fix minification aliasing. No setting change is
  needed for the artifact fix (OBSERVED settings + A06 §1.5).
- **Cheap simplification:** a precomputed mirror-variant table saves only a few ALU; hoisting
  `textureSize`/inset to a bind-time uniform is the safer micro-win. Neither is worth delaying
  the gate. Prioritise the loader-thread change, not shader ALU.

*End of G17 report.*
