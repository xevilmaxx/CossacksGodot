# T2-VERIFY-WATER — verdict (water_glints + water_shallow), post-renderer-upgrade

**Agent:** T2-VERIFY-WATER (swarm child). **Date:** 2026-11-21. **Lane:** VERIFY only — no Godot run, no shader/world code edited, no donor asset copied into the repo.
**Tool:** `app/tools/terrain_piece_render.py` (deterministic Pillow renderer, now upgraded with `bands`, `wash`/`foam` modes, `mask`/`band`, `contour`, `opacity_mask`, `brightness`, `native_render`/`resample`/`final_resample`/`grain_lift`).
**Measurement:** Pillow 12.x + NumPy in `%LOCALAPPDATA%\Temp\opencode\water_verify_measure.py` and `water_verify_measure_v2.py` (temp only, outside the repo). Nothing from that work is part of this repo.

## Scope caveat (still binding after the upgrade)

The renderer is a **depiction/reference tool, not the port engine**. It implements the water body colour (`col = tint*(0.80+0.40*h)`, shader **:64**) plus tool-side diffuse approximations of wash, foam and shore geometry. It has **no sun vector** and **no per-pixel specular model**, so:

- glints remain **untestable in-engine** — a measured 0 is a tool limit, never a pass;
- the renderer can now *paint* the donor palette and 3-band shore, but that does **not** mean `water_overlay.gdshader` / `world.gd` were fixed. §3 lists the real shader defects that still require an in-engine fix and a render/capture to close.

No spec was tuned to manufacture a pass. All numeric thresholds and the palette-gate conflict are retained verbatim.

### Artifact hashes

| Piece | Before (previous verdict) | After (upgraded renderer) |
|---|---|---|
| `water_glints.png` | `34a6c87cf1b4d16277…` | **`5b492f4dccb1eb854f8…`** |
| `water_shallow.png` | `0f3e65cc611422e57c…` | **`ad03566ce445e0f48d…`** |

Both new hashes reproduced exactly on a second render (byte-deterministic). Comparison tiles regenerated alongside each PNG.

---

## Part 1 — `water_glints` (kept deep-only on purpose)

`app/tools/piece_specs/water_glints.json` now uses `native_render: true`, `resample: "nearest"`, `final_resample: "lanczos"`, `grain_lift: 0.1` (rendered at 1024², downsampled once). **No `bands` and no `foam` layer were added**: A1–A3 gate the whole crop with the water mask forced to deep (`water_glints.md` §5); a pale wash or foam band would inject bright-neutral pixels and manufacture a false A1 pass. The renderer still has no sun vector.

Reference crop sanity unchanged: `articolo-787.jpg (890,12,960,30)` → 0 glints, luminance variance **153.27** (study 153.3 ✓).

### 1.1 Before / after

| # | Criterion | Target | Before | After | PASS/FAIL |
|---|---|---|---|---|---|
| A1 | Isolated bright-neutral glint fraction | ≤0.30 % (stretch 0.10 %) **and >0** | 0 px / 0.0000 % | 0 px / 0.0000 % | **FAIL** (glints absent; no sun vector) |
| A2 | Largest component ≤12 px; ≥50 % of glint px coherent | ≤12 px, ≥50 % | 0 components, undefined | 0 components, undefined | **FAIL** |
| A3 | Whole-crop luminance variance | ≤400 (stretch ≤250) | 0.38 (trivial) | **0.14** (trivial) | PASS *trivially* — no glints. In-engine 795 / 805–832 → FAIL |
| A4 | Sun linkage (rotate `sun_dir` ≥30°) | cluster moves; non-uniform | not testable; constant `L` at :69 | not testable; no sun vector | **FAIL** |

**Glints tally unchanged: 1 trivial PASS / 3 FAIL.** The upgrade did not (and must not) convert glints to passes.

### 1.2 Exact in-engine shader fix still required — `app/shaders/water_overlay.gdshader:69–75`

`world.gd:820` `Vector2(-0.3447/4.0, 0.9387)` is the correct mapped sun vector — **keep it**.

| Line | Current | Required change | Donor anchor |
|---|---|---|---|
| **:69** | constant `L = normalize(vec3(sun_dir.x,0,sun_dir.y))` | per-pixel ray: `vec3 sun = normalize(vec3(sun_dir.x,0,sun_dir.y)); vec3 r0 = vec3(p*UV_SCALE, WATER_LEVEL); vec3 rd = normalize(sun - r0);` (`p` at **:54**) | `water.dev.frag:215–216` |
| **:70** | `max(dot(n,L),0.0)` | `dot(n, rd)` | `:217` |
| **:71** | `pow(grad,170.0)*8.0` | `pow(grad,170.0)` — **remove ×8** | `:218` |
| **:72** | `pow(grad,120.0)*4.0` | `pow(grad,120.0)` — **remove ×4** | `:219` |
| **:73** | corona from `pow(grad,5)` | `gradpos = dot(vec3(0,0,1),rd); corona = smoothstep(0,1,pow(gradpos,5));` | `:220–221` |
| **:74** | `col += SPEC*(spec+spec2)*(0.20+0.80*corona)` | donor composite: soft `×0.25` with `(grad−1)*0.5` damping, corona **divides** `/(1+corona*1.25)`, glossy add bare `×0.4` | `:224–226` |
| **:75** | broad `vec3(0.10,0.12,0.14)*pow(grad,24)*0.35` | **delete** — no donor analogue | composite ends `:226` |

Peak add drops from `4.8` to `≈0.65` linear; per-pixel `rd` restores sun linkage.

---

## Part 2 — `water_shallow` (bands + coast foam now expressed)

`app/tools/piece_specs/water_shallow.json` now declares a shared `bands` descriptor (`direction: "down"`, `origin: 0.45`, `jitter_px: 10`, `step_px: 6`, `sand: [26,51]`, `wash: [30,50]`) and four masked layers: sand block (`mask: "band"`, `band: "sand"`, `contour: true`), pale wash water (`mode: "wash"`, `band: "wash"`, `opacity_mask: gradient down`), weak coast foam (`mode: "foam"`, `band: "wash"`, `intensity: 0.15`, `speck_scale: 1.0`, `opacity: 0.35`) and the port's shallow water body (`mode: "shallow"`, `band: "water"`, `opacity: 0.35`). Manifest geometry: **shore y=230, sand_w=36 px, wash_w=34 px** — both inside the measured target ranges.

### 2.1 Palette-gate conflict — STILL NOT RESOLVED (both gates kept)

Reference box means on `maxresdefault_1.jpg` (reproduce `water_shallow.md` §1.1 exactly):

| Gate | Box | Mean RGB | Hex | Lstd | Status |
|---|---|---|---|---|---|
| Clean shallow water | `(398,182,420,212)` | (195.3,209.0,202.3) | **`#C3D1CA`** | 11.6 | observed — palette anchor |
| Clean rippled | `(390,176,422,214)` | (194.4,204.7,194.5) | `#C2CDC3` | 13.6 | observed |
| Wash | `(372,196,396,224)` | (188.7,189.0,168.7) | `#BDBDA9` | 12.7 | observed |
| Sand | `(340,210,380,250)` | (167.7,157.8,126.7) | `#A89E7F` | 10.5 | observed |
| Inherited ticket anchor | `(410,190,457,237)` | (104.5,106.4,100.6) | **`#696B65`** | **70.8** | **contaminated** (water + minimap border; 4–6× clean Lstd) |

The spec's `palette_gate_conflict` object records both; M1 below scores both rather than silently choosing.

### 2.2 Before / after (M1–M10)

| # | Criterion | Target | Before | After | PASS/FAIL |
|---|---|---|---|---|---|
| **M1** | Water-body mean RGB | anchor (105,107,101)±18 **or** clean (195,203,196)±18 | 0 mask px; broad mean (117.9,122.5,102.3) | water body (y≥274) mean **(117.4,122.0,101.9)**; strict mask only **9 / 121,856 px** | **FAIL** (clean gate 77–87 ch off; mask effectively empty; near anchor numerically only) |
| **M2** | Whole-tile mean RGB | ≈(120–185, 125–195, 110–190) | (125.0,128.1,**107.5**) — B below floor | **(140.3,137.8,112.3)** — all three channels inside | **PASS** (was FAIL) |
| **M3** | Distinct bands on shore-normal profile | exactly **3** (sand→wash→water) | 1 stable `w` run (0–511) on all profiles | 2 stable runs (`w` 0–~204 land, `w` ~230–511 wash+water); only 3–6 px `S` speckles in sand band | **FAIL** (geometry now drawn; §1.2 colour classifier still cannot separate wash from water) |
| **M4** | Sand band width | **26–51 px** | 41 px strip drawn, 0 px recognised | **36 px geometric** (in range), 0 px recognised as stable `S` run | **FAIL** on defined S-run metric; width itself now expressible |
| **M5** | Wash band width | **30–50 px** | 46 px strip drawn, 0 px recognised | **34 px geometric** (in range), no distinct `w` run (merged with water run) | **FAIL** on defined w-run metric; width itself now expressible |
| **M6** | Ripple crest spacing | median **6 px**, accept **3–12 px** | 0 crests; undefined | **0 crests in water body (y≥274)**; undefined | **FAIL** (no radial arcs — genuine defect) |
| **M7** | Crest↔trough luminance contrast | **≈33 levels** | 3.57 levels | **2.57 levels** (p20 118.71, p90 121.28) | **FAIL** (worse) |
| **M8** | Foam absence | **0** near-white px in coast band; no white run >3 px | 0 near-white — **by omission** (no foam implemented) | 0 near-white in wash band and tile; **128 foam specks with L>178** rendered inside the band (median wash L 162.76) | **PASS** — now with an actual band-gated mechanism |
| **M9** | Shallow alpha at shoreline | **0.35** at `coastfade2≈0` | 0.35 (derived) | 0.35 (manifest/spec; PNG RGB) | **PASS** (derived) |
| **M10** | Shallow water saturation | mean HSV **S ≤ 0.12** | 0.1646 | **0.1647** | **FAIL** (unchanged) |

**Shallow tally: before 8 FAIL / 2 PASS → after 7 FAIL / 3 PASS** (M2 flipped; M8 PASS became substantive). M3/M4/M5 remain FAIL only because the *colours* still miss the strict §1.2 classifier — the geometry is now correct; fixing the colours is an in-engine shader task, so these were **not** converted to passes.

### 2.3 Former tool limitation — now resolved (renderer capability, not a port fix)

1. **3-band sand→wash→water geometry** — `bands` + `mask:"band"` + `band` now draw sequential jagged bands; manifest gives sand_w **36 px** (target 26–51) and wash_w **34 px** (target 30–50) at shore y=230. Before: one flat water overlay covering y≥87, no bands at all.
2. **Coast foam, band-confined** — `mode:"foam"` with `intensity:0.15`, `speck_scale:1.0`, `band:"wash"` produces 128 specks with L>178 inside the wash band while keeping **0 near-white pixels**. M8 is now a substantive PASS instead of "no foam code exists".
3. **Pale wash palette** — `mode:"wash"` paints the donor `#BDBDA9 → #C3D1CA` ramp; wash band mean (151.1,147.9,123.0), and the corrected composite moved M2 into its expected range.
4. **Hard contour on the sand rim** — `contour:true` gives a ≤3 px rim and suppresses stair-step; geometric colour-change rows cluster at 197–234 and 268, confirming defined band boundaries.
5. **Grain-preserving path** — `native_render`/`resample`/`final_resample`/`grain_lift` on the glints tile (1024²→512²) changed its variance 0.38→0.14; glint count stays 0 (no sun vector), correctly still FAIL.

### 2.4 Genuine port defect requiring the in-engine shader fix (NOT resolved by the upgrade)

| # | Defect | File:line | Failed criteria |
|---|---|---|---|
| 1 | `×8`/`×4` glint boosts, constant `L`, inverted corona, broad sheen; no per-pixel `rd` | `app/shaders/water_overlay.gdshader:69–75` | A1, A2, A4 (A3 in-engine) |
| 2 | Dark teal shallow tint `(0.10,0.24,0.24)` and missing `2.2+watershade` gain | `app/shaders/water_overlay.gdshader:27`, `:63–64` | M1, M10, and the colour half of M3–M5 |
| 3 | No radial-sine arc term; donor arcs are not in `diffusewaves0` (cellular) | `app/shaders/water_overlay.gdshader:35–43` | M6, M7 |
| 4 | Foam too strong / wrong source (`pow(1-f,5)` on bright veins; `particle_amount` should be 0, `nautic_gain` 0.15) | `app/shaders/water_overlay.gdshader:81–85` | Renderer's weak foam is only a tool depiction; engine still needs the fix |
| 5 | Depth/coverage baked one pixel per tile → stair-step wash; renderer contour only hides it | `app/scripts/world.gd:829–838`, `:845` | M3–M5 edge quality in-engine |
| 6 | Strict §1.2 band classifier fails because sand/water RGB are still off — painting the right palette in the tool does not change the shader | `water_overlay.gdshader:27`, shader composite | M3–M5 |

### 2.5 Exact remaining shader/world changes (unchanged from the pre-upgrade verdict)

- `water_overlay.gdshader:27` — replace `WATERCOLOR=(0.10,0.24,0.24)` with a pale gray-cyan working value targeting `#C3D1CA`/`#C2CDC3`; keep `WATERCOLOR2` at **:28**.
- `water_overlay.gdshader:63–64` — apply `2.2+watershade` shallow gain before the deep mix.
- `water_overlay.gdshader:35–43` — add radial-sine arcs: centre `(430,470)`, falloff `320 px`, wavelength `6 px` (accept 3–12 px), crest `#D8E6DE` / trough `#AFBBB4`, contrast 33 levels; keep the three donor sheets as substrate.
- `water_overlay.gdshader:81–85` — `particle_amount = 0`, `nautic` scaled to `0.15`, foam strictly gated by `band = coastfade*(1−coastfade2)`.
- `world.gd:829–838` — bake coverage/depth at sub-tile pixel resolution (or reduce `TEXTURE_FILTER` smoothing) so the wash spans 30–50 px rather than one tile step.
- `water_overlay.gdshader:69–75` — the glint rewrite in §1.2.

Owner decision still open: adopt **clean `#C3D1CA`** as the hard gate and keep `#696B65` as an inherited design anchor with the contamination caveat — **not resolved here**.

---

## Overall

| Piece | Before | After | Change |
|---|---|---|---|
| `water_glints` | 1 trivial PASS / 3 FAIL | 1 trivial PASS / 3 FAIL | none — no sun vector, deliberately not faked |
| `water_shallow` | 2 PASS / 8 FAIL | **3 PASS / 7 FAIL** | M2 flipped; M8 PASS became substantive; geometry/foam/wash expressible |

Both pieces still **FAIL** overall. The renderer upgrade resolved only *depiction* limitations (shore bands, band-gated foam, pale wash, contour, grain); every remaining failure traces to real shader/world defects that need an in-engine fix and capture. Neither glint criterion was converted to a pass.
