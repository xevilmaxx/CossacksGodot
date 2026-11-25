---
id: P05
ticket: TERRAIN-SWARM-2026-11-25 / Wave P / P05 (read-only per-fragment shader-cost audit)
date: 2026-11-25
status: COMPLETE__READ_ONLY__NO_GODOT_JOBS
labels: [observed, derived, inferred, UNVERIFIED]
files_created:
  - docs/terrain_swarm_2026-11-25/reports/P05_shader_cost.md
files_edited: []
godot_jobs_run: 0
runner_jobs_submitted: 0
parity_guard: "No donor GPU A/B frame exists (CHARTER §3). No capture, frame-time, bandwidth or disassembly evidence was produced. Every fetch/ALU/SFU figure below is a static count (OBSERVED code) plus an analytical cost reading labelled INFERRED; every throughput, cache-hit, translator-folding and visual outcome is UNVERIFIED. Nothing here is a benchmark and nothing claims donor parity."
---

# P05 — per-fragment cost of terrain / water / FX-fog shaders after B01+B02

## 0. Scope compliance

Read-only. Exactly one file created (this report). No shader, script, config, test or asset was
edited; no Godot process was started and no runner job was submitted
(`WAVE_G_CHARTER.md:31`, `:67-70`). Sources read in full or in targeted slices:
`WAVE_G_CHARTER.md` (Wave P at :60-89), `CHARTER.md`, `reports/B01_shader_impl.md`,
`reports/G17_perf_audit.md`, `reports/A06_filtering_aliasing.md`,
`reports/A10_regression_constraints.md`, `reports/G16_season_check.md`; shader source verified
directly at `variant3d/shaders/terrain_tileindex.gdshader` (502 lines),
`variant3d/shaders/water3d.gdshader` (261 lines), `variant3d/shaders/water_overlay.gdshader`,
and the inline shaders/materials in `variant3d/scripts/world3d_fog.gd` and
`variant3d/scripts/world3d_fx.gd`; binding/geometry context from
`variant3d/scripts/water3d.gd`, `variant3d/scripts/world3d_terrain.gd`, `variant3d/scripts/world3d.gd`
and `variant3d/tests/{t_terrain_shore,t_fog3d}.gd`.

**Label convention used throughout:** `[O]` = literal code fact with file:line; `[D]` = arithmetic
or structural deduction from `[O]`; `[I]` = analytical cost estimate with no measurement;
`[U]` = requires a run, disassembly or capture — UNVERIFIED. `app/**` was not audited (P05 scope
is `variant3d`); `variant3d/shaders/water_overlay.gdshader` is read only as an in-repo precedent.

---

## 1. Executive answer (before the ledgers)

1. **The terrain shader is not the dominant per-fragment cost after B01.** Its new work is
   ~60–80 ALU, 2 SFU (`sin`/`cos`), 2 derivative ops and ~9 texel reads per fragment **INFERRED**
   (§2). The only material change is trilinear sampling now that B02 supplies mips — already
   concluded by G17 §8. Cutting the mirror table or `textureSize` buys almost nothing.
2. **`water3d.gdshader` is the real fragment hotspot, and G17 did not audit it.** A surviving
   water fragment executes **5 calls to `water_map()`, each 12 `noise()` texture fetches and
   10 `sin`** → **68 texture fetches, ~50 `sin`, 5 `pow` per fragment INFERRED** (§3.2). Worse,
   a **dry** fragment of the full-map water plane executes `height_map()` + one `water_map()` =
   **13 fetches before `discard`** `[O]`; whether depth/early-Z avoids that is **UNVERIFIED** (§3.3).
3. **Three PORT APPROX-safe, output-identical simplifications exist** with no A/B-contract
   damage: (a) gate the unconditional foam `nautic()`/`particles()` at `water3d.gdshader:238-239`
   behind its zero-multiplying band, following the project's own `T-WATER-FAST` precedent
   (`water_overlay.gdshader:261-269`); (b) drop the redundant `fract()` in `noise()`
   (`:73-75`); (c) an early dry-land discard before `:170`, gated on `waveheight <= 0.0` (§6.2).
4. **Terrain-side hoists are legal but low value.** Hoisting `textureSize()`/inset to a bind-time
   uniform (`:335`) is the safest terrain micro-win, but it is line-neutrality-sensitive and only
   saves a query the driver probably already folds — **UNVERIFIED** (§6.1).
5. **Do not remove mirror/warp, `textureGrad`, the inset, the vertex→fragment mask wrap, the
   sentinel guard or P4** to save ALU: each reintroduces one of A06's ranked streak/blotch causes
   and/or breaks the published A/B anchor set (§7).

---

## 2. Terrain — `terrain_tileindex.gdshader` AFTER B01 (+ A06-F2 patch)

### 2.1 Active per-fragment path (shipped uniform defaults)

All defaults verified `[O]`: `shadow_enabled=0.0` (`:180`), `fog_mode=0.0` (`:198`),
`mask_to_alpha=1.0` (`:235`). Therefore the shadow block `:430-453` and fog block `:456-466`
are runtime-not-taken; `face_mode_override` (`:229`) selects the per-vertex path. The active
path is `:392` → `tile_rgb()` `:329-338` → face/flat mask `:396-420` → `:427` → `:472/:475`.

| Site | Code `[O]` | Static work `[D]` | Cost reading |
|---|---|---|---|
| `:392` | `vec3 rgb = tile_rgb(v_tile, fract(v_st * uv_repeat));` | 1 `fract` on vec2; **A/B anchor, byte-identical** | negligible `[I]` |
| `:330-331` | `cols = max(atlas_grid.x,1)`, `cell`, `key = floor(v_st*uv_repeat)` | ~2 `max/floor/mod`, cell-constant | negligible `[I]` |
| `:332-333` | `v = mod(key.x+3*key.y,4)`, `f` via 4 `step` + 2 `mix` | ~2 `mod`, 4 `step`, 2 `mix`, **branch-free**, no texture, no hash | negligible, cell-constant `[I]` (G17 §2 #1) |
| `:334` | `warp = 0.125*vec2(sin(dot(v_st,vec2(.13,.07))), cos(dot(v_st,vec2(.09,.11))))` | 2 dot + **2 SFU transcendentals** + 2 mul | ~50–100 M SFU/s at 720p/60 if terrain fills screen → ≪1% of an MX130-class budget `[I]`; G17 §2 #2 |
| `:335` | `inset = 0.5 / max(vec2(textureSize(tile_atlas,0))/max(atlas_grid,vec2(1.0)), vec2(1.0))` | 1 texture-*parameter* query, 2 `max`, 1 divide, vec2 | should fold to a constant; **translator folding UNVERIFIED** `[U]` (G17 §2 #3, §7 #4) |
| `:336` | `uv = mix(inset, 1.0-inset, fract(mix(local_uv,1.0-local_uv,f)+warp))` | ~6 ALU | negligible `[I]` |
| `:337` | `textureGrad(tile_atlas, (cell+uv)/atlas_grid, dFdx(v_st*uv_repeat)/atlas_grid, dFdy(...)/atlas_grid).rgb` | 2 derivative ops (per quad) + **1 texture fetch**; with `filter_linear_mipmap` (`:60`) that fetch is trilinear ≈ **8 texel taps `[I]`** | **dominant terrain fetch**; ~29 MB/frame at 1280×720 ≈ 1.8 GB/s @60 fps as a conservative all-DRAM bound `[I]`, G17 §2 #6/§8 |
| `:396-407` | `int face`; `if (face==1||face==2)` → `texture(alphavert_atlas, mask_uv).a` | 1 branch (cell-coherent) + **1 nearest mask fetch** | negligible `[I]` |
| `:412-419` | id decomposition → `texture(alpha_atlas, alpha_patch_uv(v_tile, fract(v_alpha_uv))).a` (`:417`), then sentinel + P4 `mix(mix(1.0,clamp(a,.35,1.),.5),1.0,step...)` (`:419`) | ~10 + ~15 (incl. `:376` clamp) + ~5 ALU; **1 nearest mask fetch**; no mip on masks (G16 §4) | ~30 ALU `[I]`, negligible; mask fetch count unchanged from baseline (G17 §2 #7/#8) |
| `:427` | `rgb = rgb * mix(1.0, a, mask_to_alpha) * v_packed + v_specular` | ~6 ALU; **A/B anchor** | negligible `[I]` |
| `:472/:475` | `ALBEDO = rgb; ALPHA = 1.0;` | opaque; `blend_mix` still blends but src alpha 1 | fill cost only `[I]` |

**Net terrain picture `[I]`:** ~60–80 ALU, 2 SFU, 2 derivatives, ~9 texel reads per fragment;
ALU roughly ×2–3 vs pre-B01, fetches ×8 on the colour atlas. This matches G17 §2/§8; no new
measurement is added here. **All absolute numbers are INFERRED; none was timed.**

### 2.2 Why these costs exist (streak-fix inventory that must be preserved)

| Mechanism | Line(s) | A06-ranked cause it kills | Change that would reintroduce it |
|---|---|---|---|
| B01 mirror variant `v`/`f` | `:331-333` | Charter §2 #1 — verbatim 2 m `fract()` repeat → diagonal streaks | removing mirror/warp |
| Low-freq UV warp | `:334` | F04 §5 P0-1 — no cell copied verbatim on a fixed lattice | removing or flattening warp |
| `filter_linear_mipmap` | `:60` | A06 #1/#2 — nearest minification + absent mips | back to nearest / mip removal |
| Half-texel inset | `:335-336` | A06 #5 — linear filtering bleeding adjacent atlas cells | removing inset |
| `textureGrad` from unwrapped varying | `:337`, vertex `:316` | A06 #4 — `fract()` implicit-derivative LOD≈10 seam spike | back to implicit `texture()` |
| Fragment-stage mask wrap | `:315-316`, `:417` | A06 #3 — vertex `fract()` collapses mask to one scalar per cell | moving wrap back to vertex |
| A02-P1 sentinel bypass | `:412-419` | pure-black cells / cliff faces (`a=0` → `rgb=v_specular`) | removing guard |
| A02-P4 contrast compression | `:419` | repeated dark blotches / flat olive (A02 §2/§4) | removing compression |

A06's exact ranking is at `reports/A06_filtering_aliasing.md:117-120`; B01's implementation ledger
at `reports/B01_shader_impl.md:116-123` and the A06-F2 patch at `:226-263`.

---

## 3. Water — `variant3d/shaders/water3d.gdshader`

### 3.1 Geometry / state `[O]`

- One 4-vertex, 2-triangle **full-map** plane (`water3d.gd:212-237`; `stats.plane_vertices=4`,
  `plane_triangles=2` at `:243-244`); integrated as the single `WaterPlane` under `Water3D`
  (`world3d_terrain.gd:1158`, `:1169-1185`).
- `render_mode blend_mix, cull_disabled, unshaded` (`:21`) — unshaded, so no Godot lighting, but
  still a **transparent** pass with explicit `ALPHA` (`:260`).
- `reflection_enabled=0` (`water3d.gd:199`), `fog_enabled=0` (`:196`) → reflection (`:206-211`)
  and fog (`:251-257`) branches are runtime-not-taken. `wave_noise` is a 256² `filter_linear,
  repeat_enable` texture (`:49-51`); `height_tex` neutral 1×1 by default (`:52-56`, bound at
  `water3d.gd:210`).
- Surface Y default −0.25 (`water3d.gd:179`) ⇒ `waveheight = clamp(-0.25*3-1.5,0,1) = 0`
  (`:169`), so the donor coarse-swell term is zero by derivation (`:95`, DTRN-03 C16).

### 3.2 Fetch / SFU ledger per surviving water fragment `[D]`

| Site | Calls | Texture fetches | Transcendentals |
|---|---|---|---|
| `:163` `height_map(v_height_uv)` | `height_map` (`:81-84`) | **1** (`height_tex`) | — |
| `:170` `water_map(v_height_uv*15+..., waveheight)` | `water_map` (`:87-109`): 3 `noise` for `f` (`:92-94`) + **9 `noise` in the fixed 9-iteration loop** (`:102-107`) | **12** (`wave_noise`) | **10 `sin`** (`:95` + 9× `:104`) |
| `:171-173` `if (height > level) discard;` | — | — | — |
| `:189` `h1` | `water_map` | **12** | **10 `sin`** |
| `:190` `h2` | `water_map` | **12** | **10 `sin`** |
| `:191` `h3` | `water_map` | **12** | **10 `sin`** |
| `:192` `h4` | `water_map` | **12** | **10 `sin`** |
| `:197` `terrain_map(uv)` | (`:145-147`) | **1** (`wave_noise`) | — |
| `:219` `pow(gc, spec_soft=170)` | — | — | 1 `pow` (large exponent) |
| `:220` `pow(gc, spec_glossy=120)` | — | — | 1 `pow` (large exponent) |
| `:222` `pow(max(gradpos,0),5)` | — | — | 1 `pow` |
| `:239` `nautic(uv)` (`:112-124`) | 3 `noise` in 3-iteration loop (`:117-122`) | **3** | 1 `pow(1-f,5)`, 3 `smoothstep` |
| `:239` `particles(uv)` (`:127-139`) | 3 `noise` in 3-iteration loop (`:132-137`) | **3** | 1 `pow(f*0.35,7)` |
| **Total (shipped defaults)** | 5 × `water_map` + `nautic` + `particles` | **68 fetches `[D]`** | **~50 `sin` + 5 `pow` + 3 `smoothstep` `[D]`** |

Every one of those numbers is a **static count of OBSERVED source**, not a measured frame cost;
the *cost reading* of the counts is **INFERRED**. The fetches all hit a 256² texture likely resident
in cache, so DRAM traffic may be far below a naive 68×4 B×pixels estimate — **UNVERIFIED**
(no disassembly, no profiler, no capture). Still, 68 fetches + ~50 SFU per fragment is an
order-of-magnitude heavier shader than the terrain shader's ~9 + 2 — **INFERRED, high confidence
in the relative ordering from instruction counts alone**.

Foam note `[O]`: at `:238-239` the entire `nautic`/`particles` result is multiplied by
`watershade * coastfade * (1.0 - coastfade2)`. With `coast_fade_depth=0.57` and
`deep_fade_depth=1.07` (`water3d.gd:182-183`), that band is zero in deep water (`coastfade2→1`)
and zero at the waterline (`coastfade→0`), peaking near 0.535 m (DTRN-03 §3.3). The 6 noise
fetches and 2 `pow` are nevertheless **evaluated unconditionally** today `[O]`.

### 3.3 Overdraw and the `discard` caveat `[D/I/U]`

- Dry fragments (height > level) still pay `height_map` + one full `water_map` = **13 fetches +
  10 `sin`** before `:171-173` discards `[D]`. On a 320² map (config.json:39-40) the water plane
  spans the whole visible ground, so this can be a large fraction of the frame `[I]`.
- The plane is drawn in the **transparent** pass and the terrain is opaque; if depth-test/early-Z
  rejects dry plane fragments before shading, the 13-fetch cost disappears. But the shader
  contains `discard` (`:172`), which on some drivers disables early-Z. **Whether early-Z survives
  here is UNVERIFIED** — it needs a GPU profiler/disassembly, which this ticket forbids. Treat the
  13-fetch figure as a **worst-case bound**, not a measured cost.
- No second water layer exists (`t_terrain_shore.gd:770-795` asserts exactly one plane and one
  module; WATER_LEVEL −0.25 is a hard invariant, A10 §4). Any fast-path must not add a plane.

---

## 4. FX / fog shader layers

### 4.1 Fog overlay — inline shader, `world3d_fog.gd:147-165`

`[O]` shader text at `:152-162`:
`render_mode blend_mix, unshaded, cull_disabled, depth_draw_never;` and a trivial
`ALBEDO = COLOR.rgb; ALPHA = COLOR.a;`. **Zero texture fetches, ~2 ALU per fragment `[D]`.**
The shader is not a cost problem. The geometry is:

- **One quad per map tile** (`world3d_fog.gd:184-200`): at MAP_W=MAP_H=320 that is 102,400 quads
  / 204,800 triangles / 409,600 vertices `[D]`, lifted `FOG_Y_OFFSET=0.03` above terrain (`:44`,
  `:187`).
- Per-tile alpha ladder 0.78 unexplored / 0.30 explored / **0.00 visible** (`:39-41`, `:128-133`).
- `depth_draw_never` + visible tiles still submitted ⇒ the layer rasterises a full-screen
  transparent pass even where alpha is exactly 0 `[O/D]`. Fragment work is tiny, but **blend
  bandwidth and draw overhead are the cost `[I]`**; the 0-alpha quads can be removed with no pixel
  change (§6.4).
- Refresh cadence: `_refresh_mesh()` is already called whenever any `fog_vis` value changes
  (`:303-318`), so a compacted mesh can stay current `[O]`.
- `t_fog3d.gd` asserts array sizes, no `Sprite2D` fallback and per-tile API (`:170-184`); it does
  **not** assert quad/vertex counts (grep over the whole file) — no test weakening needed `[O]`.

### 4.2 FX layer — `world3d_fx.gd` standard materials (no custom shader)

`[O]` `_material()` (`:1008-1019`) and `_impact_material()` (`:1026-1040`) build
`StandardMaterial3D` with `TRANSPARENCY_ALPHA`, `SHADING_MODE_UNSHADED`, emission on, `cull_mode
= CULL_DISABLED`, optional additive blend and `DEPTH_DRAW_DISABLED`. No texture fetch in the
FX materials themselves `[D]`, but transparent overdraw sources are:

| Layer | Lines | Overdraw source `[O]` |
|---|---|---|
| Smoke / fire cross-quads | `:1115-1119`, `:1133-1137` | 2 large transparent quads per item, `cull_disabled` → both faces shaded |
| Volley smoke | `:1158-1173` | 2 billboard quads (1.4 m + 2.0 m) per item |
| Muzzle flash / arrow trail | `:1174-1196` | 1 additive billboard quad each; trail `DEPTH_DRAW_DISABLED` (`:1192`, `:1036-1037`) |
| Selection rings | `:1266-1276` | 3 meshes per selected entity (ring + under-ring + pip), translucent (`:1262-1264`) |
| Rally markers | `:1205-1229` | 4 meshes per marker, 3 translucent (`:1206`, `:1213`, `:1219`, `:1226`) |
| Ghost | `:909-925` | footprint box + finished-building mesh, both transparent, `DEPTH_DRAW_DISABLED` (`:908`) |
| Snow (gated OFF by default) | `:973-1005` | 4 GPUParticles3D emitters, 100/100/100/200 billboard quads, alpha 0.5, no z-write; `_apply_snow_gate()` keeps invisible at Weather=40 (`:954-965`) |
| Dynamic OmniLight3D | `:1113`, `:1125`, `:1138` | one light per active shot/explode/fire FX; unshaded FX ignore it, but other lit materials may not — **UNVERIFIED** without a frame |

`FX_CAP` bounds transient items (`:112`, `:1506-1514`), so this is bounded overdraw, not unbounded
leak `[O]`. P02 owns the draw-call/instance side; P05 only records that none of these custom paths
adds a per-fragment texture fetch.

---

## 5. Overdraw summary (unshaded / transparent layers) `[D/I]`

| Pass | Blend / depth | Full-map? | Per-fragment fetch | Overdraw note |
|---|---|---|---|---|
| Terrain | `blend_mix, unshaded, cull_disabled`, `ALPHA=1.0` (`:43`, `:475`) | yes (one mesh) | ~9 `[I]` | opaque-equivalent; no alpha blending benefit |
| Water plane | `blend_mix, unshaded, cull_disabled` (`:21`), explicit ALPHA | yes (4 verts) | 68 `[D]`, 13 pre-discard `[D]` | early-Z interaction with `discard` **UNVERIFIED** (§3.3) |
| Fog overlay | `blend_mix, unshaded, depth_draw_never` (`world3d_fog.gd:154`) | yes (per-tile quads) | 0 `[D]` | full-screen transparent pass incl. alpha=0 tiles |
| FX quads/rings/ghost | `TRANSPARENCY_ALPHA`, mostly `DEPTH_DRAW_DISABLED` | no (bounded by cap) | 0 `[D]` | small but additive; see §4.2 |

No second terrain or water pass exists in the current tree (`A10 §1.2`, `t_terrain_shore.gd:770-795`).

---

## 6. Exact PORT APPROX-safe simplifications (with line numbers)

All are **proposals only**; P05 changed no file. "Bit-identical" below means the arithmetic output
at both A/B endpoints is unchanged `[D]`; it does **not** mean a driver could not reassociate
floating point — **UNVERIFIED** without a capture, and no capture is permitted here.

### 6.1 Terrain: hoist `textureSize`/inset — SAFE, negligible benefit

- **Edit:** `terrain_tileindex.gdshader:335` → `vec2 inset = 0.5 / max(atlas_cell_size, vec2(1.0));`
  with `atlas_cell_size` supplied at bind time from the loaded atlas pixel size ÷ `atlas_grid`
  (`world3d_terrain.gd:661` already reads `_atlas_grid`; the loader knows the image size). Numeric
  value stays 0.5/1024 = 0.00048828125 for the shipped 16384×8192 / 16×8 atlas (G16 §3/:171).
- **Why safe:** same inset value → same samples → streak fix unchanged; `:392`, `:365-378`,
  `:419`, `:427`, `:475`, `:476` and the A/B block `:478-502` stay byte-identical. This is G17
  §5 #2 verbatim.
- **Flags:** (a) line-count neutrality — adding a declaration line shifts every cited anchor and
  breaks B01 §3/:45-47, A06 §8, G17 §1.1 file:line citations. Preserve 502 lines by replacing a
  comment-only line inside the uniform block with `uniform vec2 atlas_cell_size = ...; // <original
  citation>`, or bind from GDScript on an existing unused parameter slot — **never** insert a line.
  (b) Hardcoding `0.000488` instead of binding breaks B01 §5 #2's "derived from the real atlas
  size, not a hardcoded donor constant" claim; label any constant `PORT APPROX — asset-derived`.
  (c) Benefit is tiny if the driver folds `textureSize` already — **UNVERIFIED** (G17 §7 #4).
- **Verdict:** safe, low priority.

### 6.2 Water: gate the foam `nautic()`/`particles()` — SAFE, highest value

- **Edit:** `water3d.gdshader:238-239` → compute `float foam_band = coastfade * (1.0 - coastfade2);`
  and wrap the add in `if (foam_band > 0.0) { watercolor += watershade * foam_band * (...); }`.
- **Why safe:** the result is multiplied by exactly `foam_band`; when it is 0 the current code adds
  0, so the guarded version is bit-identical for all reachable inputs `[D]`. Saves **6 texture
  fetches + 2 `pow` + 3 `smoothstep` for deep-water fragments `[D]`**.
- **Citation:** use the project's own sanctioned precedent — `variant3d/shaders/water_overlay.gdshader:261-269`
  `T-WATER-FAST`: *"nautic()/particles() are 6 more noise taps that feed only the band-multiplied
  foam add; deep water skips them, output unchanged."* Keep the donor cite `water.dev.frag:227`
  on the surviving line. Label `PORT APPROX — fast path, output-identical`, not donor parity.
- **Flags:** no published A/B contract exists for this shader; `t_terrain_shore.gd:899-905` checks
  only that `particle_amount == 30.0` and reads no foam shader text — no weakening. Branch
  divergence at the band boundary is **UNVERIFIED**; deep water is spatially coherent `[I]`.
  Pixel equality still needs a fresh capture per CHARTER §5 before any visual claim.
- **Verdict:** safe, **do first**.

### 6.3 Water: remove redundant `fract()` in `noise()` — SAFE, low risk

- **Edit:** `water3d.gdshader:74` → `return texture(wave_noise, p * (1.0 / 256.0)).r;`.
- **Why safe:** `wave_noise` carries `repeat_enable` (`:49`), so GL_REPEAT wraps negative/>1
  coordinates identically to `fract()`; saves 1 `fract` per `noise()` call → **up to 66 `fract`
  saved per fragment `[D]`** (5 × 12 `water_map` noise calls + 3 `nautic` + 3 `particles`;
  `terrain_map`'s inline `fract` at `:146` is not affected). It also moves *closer* to the cited donor equation
  `noise(p) = texture2D(waveMap, p*(1./256.)).x` (`water.dev.frag:65-68`, quoted at `:72`).
- **Flags:** exact wrapping at the seam with `filter_linear` is mathematically equivalent but was
  not GPU-tested — **UNVERIFIED**; needs capture. No test reads `fract` in this shader
  (`t_terrain_shore.gd` only checks `shore_prox` absence at `:926-936`). Do **not** remove `fract()`
  from `terrain_tileindex.gdshader:392` — there it is the 2 m repeat contract (A06 §3.4 #5).
- **Verdict:** safe, small.

### 6.4 Water: early dry-land discard before the level `water_map()` — SAFE only when gated

- **Edit:** between `:169` and `:170`, add
  `if (waveheight <= 0.0 && height > water_level) { discard; }`, keeping `:171-173` unchanged.
- **Why:** with shipped constants `waveheight=0`, the `sin` swell term at `:95-96` is 0 and the
  9-loop `f` is `<= 0` (`:104`, `f -= amp*abs(sin(...))`, `amp>0`) ⇒ `level <= water_level`, so
  `height > water_level` implies `height > level` ⇒ the existing discard would fire anyway `[D]`.
  Saves **12 fetches + 10 `sin` per dry fragment `[D]`** (the worst-case bound of §3.3).
- **Flags:** **must** keep the `waveheight <= 0.0` gate. A future A/B surface Y > 0.8333 makes
  `waveheight>0` and `level` may exceed `water_level`; an ungated early-out would then delete
  legitimate shallow-water fragments and break the sanctioned A/B value described at `:165-168`.
  This changes the literal donor equation shape at `:170-176`, so label `PORT APPROX — uniform-gated
  fast path`, and re-run the shore atom's pixel checks. No early-Z claim is made (§3.3).
- **Verdict:** conditional; needs a capture before merging.

### 6.5 Fog overlay: omit alpha=0 quads — SAFE structurally, moderate value

- **Edit:** `world3d_fog.gd:184-203` and `:218-228`: when building/refreshing, append vertices,
  uvs, indices and colours only for tiles whose `_alpha_for(i) > 0.0`; remap `base` indices and
  `_set_tile_color`'s `i*4` slot (`:136-144`) through the same compacting map. The change gate at
  `:303-318` already calls `_refresh_mesh()` on transitions, so visibility stays correct `[O]`.
- **Why safe:** alpha-0 quads contribute nothing under `blend_mix` `[D]`; removes up to 100% of the
  fog pass after full reveal (INFERRED fraction — no capture). Keeps the inline shader
  `:152-162`, alpha ladder `:39-41` and the two public fog arrays untouched.
- **Flags:** implementation is a GDScript edit owned by a different ticket (P05 is read-only);
  `t_fog3d.gd` has no quad-count assertion `[O]`, but the HUD/minimap reads the same `fog_vis`
  aliases (`world3d.gd:652-655`) — do not change array semantics. The compacting map must be
  deterministic or `_set_tile_color` will tint the wrong tile — **UNVERIFIED** until tested.
- **Verdict:** safe proposal; hand to an implementation ticket, not P05.

### 6.6 Terrain: things that are legal but not worth it

| Idea | Sites | Benefit `[I]` | Flag |
|---|---|---|---|
| Mirror table `uniform vec2 mirror[4]` or compute `f` in vertex | `:332-333` | ~3–6 ALU/fragment; G17 §5 #3 calls it marginal | New uniform/varying adds a line → anchor shift; mirror states and `fract()` phase must stay identical |
| Replace 4 `step` with `floor`/`mod` algebra | `:333` | ~1–2 ALU | Same output needed; no capture → UNVERIFIED; low value |
| Polynomial sin/cos approximation | `:334` | 2 SFU → ~16–32 ALU; on Maxwell-class SFU this is **likely a regression `[I]`** | Changes the exact low-frequency phase field B01 §5 #1 validated on paper; new pattern UNVERIFIED |
| Move `sin`/`cos` warp to vertex stage | `:334` + `:274-326` | 2 SFU per fragment → 2 per vertex | G17 §5 #4: phase differs ~0.26/0.18 rad across a 2 m cell; **only after a fresh capture**, never silent; touches A06-F2 comment `:265` |

### 6.7 Explicitly NOT safe (reintroduce the streak/blotch fix or break the contract)

1. Back to `filter_nearest_mipmap` or mip removal (`:60`, loader `:350-356`) — A06 #1/#2, G17 §5 #5.
2. Remove `textureGrad` / revert to implicit `texture()` (`:337`) — A06 #4 seam LOD spike.
3. Remove the half-texel inset (`:335-336`) — A06 #5 cross-cell bleed with linear filtering.
4. Move `fract()` back to the vertex stage (`:315-316`) — A06 #3 collapses mask to per-cell scalar.
5. Remove mirror/warp (`:331-334`) — Charter §2 #1, F04 P0-1 diagonal streaks return.
6. Remove sentinel guard or P4 (`:412-419`) — A02-P1 black cells / A02-P4 dark blotches return.
7. Fold `mask_to_alpha` into a branch or delete `mix(1.0,a,mask_to_alpha)` at `:427` — **breaks
   the published A/B contract** (`:478-502`, endpoints `:492-496`) and the byte-identical anchor.
   The ~5 ALU saved at `:419` is not worth it.

---

## 7. A/B contract and citation-break flags (summary table)

| Candidate | Breaks A/B contract? | Breaks cited anchor / report claim? | Action |
|---|---|---|---|
| Hoist `textureSize` (`:335`) to uniform | No — `:427`, `:475`, endpoints unchanged | **Yes if a line is inserted**: B01 §3/:45-47 (502 lines), `:392`, `:419`, `:478-502`; B01 §5 #2 "not a hardcoded constant" | In-place / line-neutral only; bind from loader; label asset-derived |
| Mirror table (`:332-333`) | No | New uniform/varying shifts anchors; mirror-state claim B01 §4 #1 | Marginal; defer |
| sin/cos removal (`:334`) | No | B01 §5 #1 phase-field claim; visual UNVERIFIED | Do not |
| sin/cos to vertex (`:274-326`, `:334`) | No | A06-F2 comment `:265`; needs fresh capture | Defer to capture ticket |
| Sentinel/P4 removal (`:412-419`) | Not the endpoints, but destroys the shipped `"1.0"` visual meaning at `:492-494` | B01 §4 #3/#4, A02-P1/P4, A10 §4 | Do not |
| Short-circuit `mask_to_alpha` branch | **YES** — `:492-496` says both endpoints are one compiled program; `:427` must stay byte-identical | B-Shader-AB block `:478-502`; A10 §3 T5 | Do not |
| Water foam guard (`:238-239`) | N/A (no water A/B block) | No test reads the text; keep `water.dev.frag:227` cite; add `T-WATER-FAST` cite | **Do first** |
| Water `noise()` fract removal (`:74`) | N/A | Moves closer to donor cite `:72`; no test reads it | Do, with capture |
| Water early discard (between `:169`/`:170`) | Would break future A/B surface-Y value if ungated | Donor equation shape `:170-176`; DTRN-03 C16 | Gate on `waveheight<=0`, capture first |
| Fog quad compaction (`world3d_fog.gd:184-203`, `:218-228`) | N/A | Inline shader `:152-162`, alpha ladder `:39-41`, t_fog3d `:170-184` intact | Safe proposal |

**Line-number invariant:** `terrain_tileindex.gdshader` is 502 lines with anchors `:235`,
`:365-378`, `:392`, `:419`, `:427`, `:475`, `:476` and the `:478-502` block (B01 §3/:45-47,
B01 §6/:167-175, A06 §8/:261-263). Every terrain-side simplification must be **line-count-neutral**
or it invalidates citations in B01, A06, G17, A10 and this report simultaneously.

---

## 8. UNVERIFIED register / open questions

1. No GPU A/B, frame-time, bandwidth or disassembly evidence exists. **All** fetch/ALU ratios and
   absolute figures in §2–§5 are static `INFERRED` counts, not measurements (G17 §7 #1).
2. Whether the driver folds `textureSize(tile_atlas,0)` to a constant — unknown (G17 §7 #4).
3. Whether `discard` at `water3d.gdshader:172` disables early-Z for the full-map water plane —
   unknown; the 13-fetch pre-discard bound (§3.3) may never be paid.
4. Effective cache-hit rate for the 256² `wave_noise` across 68 fetches/fragment — unknown.
5. Whether any simplifications above preserve pixels — unknown until a fresh windowed capture;
   no donor GPU A/B exists (CHARTER §3/§5), so parity stays UNVERIFIED regardless.
6. Whether `filter_linear` + `repeat_enable` wrapping equals `fract()` at negative coordinates on
   this GLES3 translator — unknown (§6.3).
7. Exact MX130 VRAM/clock/bandwidth and the rest of the resident set — unknown (G17 §7 #2).
8. Whether the unshaded FX materials' OmniLights affect other lit materials — unknown (§4.2).
9. `MODE_ARRAY` atlas still lacks mips (G17 §7 #6) — if that path is chosen, the terrain shader
   silently returns to the aliased baseline; a correctness gap, not a saving.

---

## 9. Bottom line for COORD

- **Per-fragment ranking `[I]`:** `water3d.gdshader` (~68 fetches + ~50 `sin` per surviving water
  fragment; 13 fetches + 10 `sin` pre-discard on dry plane fragments) **≫** terrain (~9 fetches,
  2 SFU) **≫** fog (0 fetches, 2 ALU) ≈ FX materials (0 fetches). G17 audited only the terrain
  side; the water shader is the unexamined hotspot.
- **First cheap win:** `water3d.gdshader:238-239` foam guard (§6.2), then `:74` `fract` removal
  (§6.3), then the gated early discard (§6.4). All preserve the shipped equations where they
  matter and none touches a published A/B anchor.
- **Terrain:** accept G17's conclusion — hoisting `textureSize`/inset (§6.1) is the only safe
  micro-win and is tiny; the mirror/SFU math is not where the time is. **Never** trade away the
  B01/A06 streak fixes for a few ALU (§6.7).
- **Overdraw:** the alpha-0 fog quads (§6.5) and the water plane's early-Z/discard interaction
  (§3.3) are the two fill-rate questions; both need an implementation ticket and a real capture.
- **Still the largest structural suspects** remain G17's: synchronous ~683 MiB CPU mip build
  (loader, not shader) and 512→683 MiB atlas VRAM (G17 §3, §8; P06/P08 own those).
- **No runner job was submitted and no Godot was run by P05** (`WAVE_G_CHARTER.md:31`, `:67-70`).

*End of P05 report. Read-only; one report; no code edit, no Godot job, no donor-parity claim.*
