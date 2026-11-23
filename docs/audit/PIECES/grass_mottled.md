# T2-PIECE-GRASS-MOTTLED — grass piece with terrain-driven tonal patches

RESEARCH only. One output file. No code, no Godot edits, no donor copies into the repo.
All pixel work used Pillow 12.1.1 on the original donor JPEGs / port PNGs; probe scripts lived only in
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\`. Tags: `observed` (seen in source), `derived`
(computed from pixels), `inferred` (interpretation). Prior baseline: `docs/audit/TERRAIN_REFERENCE_IMAGES.md`
§2 (palette), §3.3 (ground texture), §5 (acceptance criteria).

**Purpose:** define a 512×512 *mottled* grass piece whose light/mid/dark olive patches (20–80 px scale)
come from terrain-driven masks, and prove it is NOT the flat clean-grass piece (same art, no tonal drive).
Companion negative control is `grass_clean` (not authored here); its numbers are quoted from prior §3.3.

---

## 1. Donor evidence — crop boxes, hex, measured statistics

### 1.1 Positive reference (mottled / relief grass)

| Item | Value | Tag |
|------|-------|-----|
| Image | `C:\Users\Maxym.Oboyshev\Downloads\c3\articolo-787.jpg` (960×540), donor #6 overview | observed |
| Crop box (source px) | `(250,220,450,420)` → 200×200 = prior `c6_overview.png` box from §3.3 | observed |
| Mean colour of box | RGB (77.1, 74.6, 42.2) → **`#4D4B2A`** | derived (Pillow) |
| Luminance | mean **71.7**, std **37.55** (prior §3.3: 37.6 — confirmed) | derived |
| Hi-frequency | image − 5 px Gaussian blur, mean **11.17** (prior §3.3: 11.36 — confirmed within JPEG/blur tolerance) | derived |
| Luminance bins | 8 bins × 32 levels, % = `[5.0, 39.3, 44.7, 4.8, 1.9, 1.2, 1.2, 1.8]` → **4 bins ≥3%** (bins 0–3) | derived |
| Patch scale | §3.3 `observed`/`derived`: shading patches dominate at **20–80 px**; confirmed by a 5×5 grid of 40×40 px sub-boxes whose L means span 45.2 → 130.1 | derived |

40×40 px patch-grid means on that 200×200 crop (L / hex, row-major) give the tonal anchors:

| Patch role | Measured box mean | Canonical hex anchor (prior §2) |
|---|---|---|
| Light olive (sunlit sward) | L 88.6 `#625C32`, L 97.0 `#696341` | **`#6B6732`** (107,103,50) |
| Mid olive | L 73.1 `#4D4E25`, L 60.3 `#404020`, L 79.8 `#575230` | **`#616727`** (97,103,39) / `#64642F` (100,100,47) |
| Dark olive (shadowed/swale) | L 45.2 `#302F1B`, L 48.3 `#343319`, L 51.9 `#363622` | **`#3E411F`** (62,65,31) |
| Distant/open grass (secondary) | — | `#4F5325` (79,83,37), donor #2 crop `(300,600,600,760)` |

The single brightest patch (L 130.1 `#94805B`) is the gully rock rim, **not** grass; exclude it from the
grass-only histogram target but keep it as the reason the reference box has bins 4–7 populated.
Light→dark grass patch ratio ≈ 97/45 ≈ 2.2 (prior §5 rank 5 wants lit/shadow ratio ≥1.5, target 1.7–1.9).

### 1.2 Negative control (flat clean grass) — must NOT match

| Item | Value | Tag |
|------|-------|-----|
| Image / crop | `cossacks-3-v1-498085.jpg` (1280×720), donor #8; prior `c8_ravine_center.png` is a 2× zoom of src `(560,150,1000,560)`, so its box `(0,350,350,700)` maps to **src `(560,325,735,500)`** (175×175) | observed + derived |
| Mean colour | RGB (96,100,40) → **`#606428`** | derived |
| Luminance | mean **91.8**, std **8.70** (prior §3.3: 91.8 / 8.6 — confirmed) | derived |
| Hi-frequency | **3.42** (prior: 2.96) | derived |
| Bins | `[0.1, 1.5, 69.5, 28.6, 0.3, 0, 0, 0]` → **2 bins ≥3%**, both in bins 2–3 | derived |

Distinction gate (derived): mottled std ≈ 4.3× clean, hi-freq ≈ 3.3× clean, bin count 4 vs 2, and the
mottled histogram must populate **bin 0 and bin 1** (L 0–63), which the clean piece essentially never does.

### 1.3 Block donors actually named by the recipe

Lineage: donor `terrain/tiles/textures/grass1..grass10.dds` → port PNGs (`docs/guides/GUIDE4.md:180-189`,
"light meadow pool"). Measured on `app/assets/terrain/blocks/*.png` (all 1024×1024 RGB, `observed`):

| Block | Mean hex | L mean | L std | hi-freq | bins ≥3% | Role in recipe |
|---|---|---|---|---|---|---|
| `grass1` | `#4C521E` | 74.6 | 8.91 | 6.36 | 2 | continuous tile base |
| `grass6` | `#373019` | 47.4 | 11.72 | 8.47 | 3 | dark tonal overlay |
| `grass10` | `#4C4A18` | 69.1 | 13.28 | 9.59 | 2 | mid/warm tonal overlay |

`grass6` is ≈27 L darker than `grass1` — the only one of the three with a useful dark tone. `grass10` is
only ≈5 L darker than the base, so its 0.2 layer mostly adds **hue/grain**, not tonal separation.

---

## 2. Port state (current file:line — prior audit line numbers are stale)

### 2.1 What exists and can be reused

| Concern | Location | Current behaviour |
|---|---|---|
| Constants | `app/scripts/world.gd:25` `CHUNK_T=32`; `:35` `terrain_px=16`; `:54` `BLK_CACHE=32`; `:58` `BLOCKS_PER_CHUNK=3`; `:59` `BLOCKS_PER_ROLE=2`; `:877-880` `_bake_px()=min(terrain_px*4,64)=64` | one chunk = 32×32 cells baked at 64 px/cell (2048² at high preset) |
| Block loading | `world.gd:850-872` `_block_img()` | loads `res://assets/terrain/blocks/<name>.png`, `_mirror_tileable` to 1024 (`:713-732`), then `adjust_bcs(1.0,1.12,1.0)` — a flat +12% grain lift for every block; LRU 32 |
| Seamless crops | `world.gd:734-751` `_wrap_crop()`; `:909-916` `_alpha_mask()` | modular blits; coverage stored in **alpha**, bilinearly upscaled, consumed by `blend_rect_mask` |
| Atlas compositor | `world.gd:998-1046` `_composite_blocks()` | per-cell 2×2 coverage for *every* named block in one pass (`:1004-1040`), optional `max_alpha` + gamma `falloff` (`:1035-1039`), per-name crop offset `abs(hash(nm))%512` (`:1044-1046`). This is the exact hook a named-block piece needs. |
| Chunk bake | `world.gd:1048-1088` `_build_chunk()` | base = ONE continuous `_block_img("grass1")` crop (`:1064`); distinct names ranked from `game.tileblock`/`tbl_names` (`:1068-1080`); top **3** composited (`:1080`,`:1088`); `sandsea*` reserved for shore pass (`:1084-1087`) |
| Role overlays | `world.gd:1094-1135` | dirt→`ground1`, forest→`grass_ground2`, sand/rock→oriented names, water→blue substrate |
| Season/relief tint | `world.gd:1141-1165` | relief shade is RGB (0.05,0.04,0.03) at alpha ≤0.20 → **≤~13 L darkening**, far below the 37.6 std target (derived) |
| Dead gain code | `world.gd:589-597` `_gain_at()`, amplitude `±8.5%` | grep in `app/scripts/` finds only the definition — **never called**. It cannot be credited as the current mottling mechanism. |
| Pre-warm | `world.gd:171-191` | warms a fixed meadow set then every block name used by the map; `grass6`/`grass10` only loaded if a tileblock name happens to equal them |
| Tileblock source | `game.gd:1124-1193` `_assign_tileblocks()` | base cell = `grass1` (`:1141`); detail pass `:1095-1119` maps `tile_low/highground` red÷2 into `tbl_names`; 3-pass smooth `:1183`; forest border `grass5`/`rock9` `:1375`. **No `.gd` literal names `grass6` or `grass10`** (grep) — they exist only as PNGs, so a piece spec must address them explicitly, not via the live tileblock map. |
| Perf gate | `SWARM_BOARD.md:249-251` (QA-P1) | ≤3 composites/chunk, max bake 50.06 ms vs 250 ms. The 3-layer spec exactly fills the cap — do not add a 4th block layer. |

Stale references to correct when quoting prior docs: `TERRAIN_PORT_RENDER.md:65-96` and
`TERRAIN_SANDBOX_PLAN.md:124` cite `world.gd:695-717/806-837/841`; in the current file those offsets are
water/wave code. Current atlas lines are `850-872`, `998-1046`, `1064`, `1080-1088`.

### 2.2 Gap to close (derived, not yet implemented)

The named-block layers alone do **not** produce mottling. Pillow simulation of the exact spec
(`grass1` base + `grass6` ≤0.35 + `grass10` ≤0.2 over smooth 43–64 px coverage ramps, seed 7, 512²):

| Variant | L std | hi-freq | bins ≥3% |
|---|---|---|---|
| smooth masks, 0.35 / 0.20 (the spec) | 7.5 | 5.32 | 2 |
| hard masks, 0.35 / 0.20 | 7.8 | 5.42 | 2 |
| hard masks, 1.0 / 1.0 (upper bound) | 10.5 | 6.69 | 2 |
| spec layers **plus** ±30 L olive gain patches (20–80 px) | 28.9 | 3.33 | **4** |

Cause: all three block means sit in L 47–75, so block swaps move luminance by only a few levels; block
std (8.9–13.3) is close to clean-grass std (8.7). To reach the donor target the piece must pair the
three named layers with a **terrain-driven low-frequency olive gain of roughly ±25–35 L** (dark
`#3E411F`-side / light `#6B6732`-side), keep the fine block grain on top, and avoid the wrong bright
tail (rock `#94805B`) in grass-only regions. This is a recipe requirement, not a code claim.

---

## 3. JSON spec (required deliverable) + target histogram

```json
{
  "name": "grass_mottled",
  "size_px": [512, 512],
  "seed": 7,
  "layers": [
    {"type": "block", "name": "grass1", "tile": true},
    {"type": "block", "name": "grass6", "opacity": 0.35},
    {"type": "block", "name": "grass10", "opacity": 0.2}
  ],
  "reference": {
    "primary": {"image": "articolo-787.jpg", "crop": [250,220,450,420], "hex": "#4D4B2A"},
    "negative_control": {"image": "cossacks-3-v1-498085.jpg", "crop": [560,325,735,500], "hex": "#606428"},
    "patch_hexes": {"light": "#6B6732", "mid": "#616727", "dark": "#3E411F"},
    "patch_scale_px": [20, 80],
    "source_doc": "docs/audit/TERRAIN_REFERENCE_IMAGES.md §3.3/§5"
  }
}
```

Interpretation of layers: `grass1` is the seamless base (mirror-tiled, `tile:true`); `grass6` and
`grass10` are **patch** layers whose `opacity` is the ceiling of a terrain-driven coverage mask
(smooth 2×2-neighbourhood grid, same mechanism as `world.gd:998-1046`), not flat global blends. The
mandatory gain driver from §2.2 is part of the piece recipe but deliberately not a fourth `block`
layer (QA-P1 cap).

**Target luminance histogram** (8 bins × 32 levels, % of pixels, measured on the donor 200×200 box;
ranges are the acceptance band):

| Bin (L) | 0–31 | 32–63 | 64–95 | 96–127 | 128–159 | 160–191 | 192–223 | 224–255 |
|---|---|---|---|---|---|---|---|---|
| Donor target % | 5.0 | 39.3 | 44.7 | 4.8 | 1.9 | 1.2 | 1.2 | 1.8 |
| Acceptance band % | 3–10 | 30–45 | 35–50 | 3–15 | 0–6 | 0–4 | 0–4 | 0–5 |

Hard gate: **≥4 bins at ≥3%**, of which **≥3 must be bins 0–3**; bins 1+2 together 65–90%. Bins 4–7 are
permitted mainly where rock/rim is present; for a pure-grass piece they may be near zero, in which case
the 4th populated bin must be bin 3 (L 96–127, the light-olive patch).

---

## 4. Measurable acceptance criteria (render 512×512 → downsample 200×200 for stats)

| # | Criterion | Target (derived from donor) | Measurement | Clean-piece contrast |
|---|---|---|---|---|
| C1 | Luminance std | **30–40** (donor 37.55) | Pillow `convert("L")` stddev on 200×200 | clean 8.70 → ratio ≥3× (donor 4.3×) |
| C2 | Tonal bin count | **≥4** of 8 bins ≥3% area; ≥3 of them in bins 0–3 | 8×32 histogram | clean 2 (bins 2–3 only) |
| C3 | Hi-frequency energy | **8–12** (donor 11.17; prior §5 rank 7 band 3–12) | mean abs(L − GaussianBlur(5)) | clean 3.42 |
| C4 | Patch scale | dominant patch diameter **20–80 px** at 512² (≈6–25 patches across the tile); 40×40 sub-box means must differ by ≥15 L | 5 px-blurred L grid + 40 px sub-box means | clean sub-box spread ≈0–5 L |
| C5 | Olive palette / saturation | patch means inside `#3E411F`–`#6B6732`, R≈G>B; HSV sat 0.30–0.55, value 0.25–0.45 (prior §5 global gate) | mean RGB per patch + `colorsys` | clean `#606428` is single-toned |
| C6 | Light/dark patch ratio | **1.7–2.4** (donor ≈2.2; prior §5 rank 5 ≥1.5) | L of 90th-pct patch mean ÷ 10th-pct patch mean | clean ≈1.0–1.2 |
| C7 | Layer budget / perf | exactly 3 named block layers; ≤3 composites per chunk; bake ≤250 ms (QA-P1) | spec count + `BLOCKS_PER_CHUNK=3` (`world.gd:58`) | — |
| C8 | Histogram fit | table in §3, L1 distance to donor 8-bin vector ≤ ~25 percentage points | compare bin vectors | clean misses bins 0–1 by ~45 pp |

Failure signature: a render with std <12, 2 bins, hi-freq ~5 means the gain driver was dropped and the
piece collapsed into `grass_clean` — reject.

---

## 5. Claim table

| Claim | Evidence | Method | Verdict | Caveat / correction |
|---|---|---|---|---|
| Relief grass std ≈37.6, hi-freq ≈11.36, ≥4 bins | `articolo-787.jpg` `(250,220,450,420)` | Pillow L-std, 5px-blur diff, 8×32 histogram | **derived / confirmed** | measured 37.55 / 11.17 / 4 bins; blur/JPEG tolerance |
| Clean grass std ≈8.6, hi-freq ≈2.96 | `cossacks-3-v1-498085.jpg` src `(560,325,735,500)` (2×-crop mapping) | same | **derived / confirmed** | measured 8.70 / 3.42; prior box only interpretable via the 2× crop |
| Light/mid/dark olive patch anchors `#6B6732`/`#616727`/`#3E411F` | prior §2 + 40×40 grid means `#625C32`…`#302F1B` | box means + palette table | **observed + derived** | brightest `#94805B` patch is rock rim, exclude from grass-only target |
| Patches live at 20–80 px | prior §3.3 + 40 px grid heterogeneity | visual + grid | **derived** | crop-dependent; use C4 tolerance |
| `grass1/6/10` PNGs exist, 1024², means L 74.6/47.4/69.1 | `app/assets/terrain/blocks/`; GUIDE4.md:180-189 | file listing + Pillow | **observed + derived** | block grain lifted +12% by `world.gd:866` |
| `grass6`/`grass10` are not named anywhere in `.gd` | grep `app/scripts/` | source search | **observed** | spec must name them explicitly; live tileblock map won't supply them |
| Current compositor can blend named blocks with smooth masks and alpha ceilings | `world.gd:998-1046` | source read | **observed** | max_alpha/falloff already exist; no new engine path needed |
| Relief shade overlay already delivers the target mottling | `world.gd:1141-1165` | source read + arithmetic | **CONTRADICTED** | ≤0.20 alpha of near-black → ≤~13 L; cannot reach std 37.6 |
| `_gain_at()` provides meadow mottling | `world.gd:589-597` | grep call sites | **CONTRADICTED** | defined but never called |
| Old line refs `world.gd:806-837` still describe grass mixing | TERRAIN_PORT_RENDER.md:65-96 | current file read | **CORRECTION** | those offsets are now water/wave code; use `:850-872`, `:998-1046`, `:1064`, `:1080-1088` |
| 3 specified block layers are sufficient for mottling | Pillow simulation of spec | L-std / bins on 512² sim | **CONTRADICTED** | std 7.5, 2 bins even at full alpha; needs ±25–35 L terrain-driven olive gain (§2.2) |
| Hi-freq criterion is met by donor block art alone | sim hi-freq 5.3–6.7; prior §5 band 3–12 | 5px-blur diff | **derived / PASS (conditional)** | pass only if gain patches retain the block grain; smooth gain alone drops hi-freq to 3.3 |
| Piece is distinct from clean grass | C1/C2/C3 contrast table | derived metrics | **inferred — pending render** | must be checked on an actual 512² render; no render produced in this research lane |

Open questions: (1) exact donor bitmap that drove the 20–80 px gain (tile_low/highground R÷2 is per-cell,
so a per-piece continuous gain field is port-authored — confirm with owner); (2) whether 3 composites is a
hard runtime cap for piece renders too (QA-P1 measured chunks, not single-piece bakes); (3) whether bins
4–7 may be dropped entirely for grass-only pieces or must retain a thin light-rim tail.

---

## T6 verdict (T6-T01) — mini-baker render, 2026-11-23

Back up before edit: `inbox\backup\grass_mottled.md.bak-T6-T01` (source sha256
`A1F857B70FF1DB51092925E7CA2517F9C45A799DD83B3EED8A1DCB43DD866CE8`).
Full claim table, hashes and open questions: `docs/t6/reports/T6-T01.md`.
Renderer: NEW `app/tools/pieces/t6_grass_mottled.py` (imports
`terrain_piece_render.py` READ-ONLY; no Godot, no donor binary copied).

**Donor anchors re-measured first (tags: observed / derived).** Primary #8 clean
grass `(560,325,735,500)`: `#606428`, L 91.75, std 8.70, hi-freq 3.42, **2**
bins ≥3%. Palette boxes: lit `#686935` (doc canonical `#6B6732`), mid `#616727`
exact, mid-alt `#64642F` exact, dark sample `#464827` (doc canonical `#3E411F`).
Mottled #6 `(250,220,450,420)`: `#4D4B2A`, L 71.66, std 37.55, hi-freq 11.18,
bins `[5.0,39.3,44.7,4.8,1.9,1.2,1.2,1.8]` → 4 bins ≥3%. **Observed caveat:**
that crop contains explosions/rock, so bins 4–7 are not grass; a grass-only
subregion `(0,0,150,200)` measures L 71.77, std 33.98, hi-freq 9.31, bins
`[4.2,36.4,49.4,4.7,2.0,1.1,1.1,1.2]`. Donor `grass{1,6,10}.dds` are 1024²
DXT1 and decode **byte-identically** to the port block PNGs (diff 0.0).

**Renderer defect found (observed):** the shared `patches` layer clamps signed
grid values to 0 in an `L` image (seed 7 field mean 62.57 vs 128), biasing the
baseline gain by **−38.6 L**. The old `grass_mottled.png` reached its std via a
mostly-negative gain, not a symmetric ±L driver. The mini-baker keeps the gain
in float NumPy arrays and uses a continuous rank→CDF ramp with fire-censored
grass histogram `[6,36,41,12,3,1,1,0]`, a 56 px terrain driver and 6 px fine
grain; three named block layers preserved (C7 = 3).

**Measured acceptance (200² downsample) — 11 PASS / 0 FAIL:**

| Criterion | Target | Measured | Verdict |
|---|---|---|---|
| T6-A patch amplitude | ±25–35 L | 5px-blur field 45/72/102 → **−27/+30 L** (40² proxy −22.4/+18.5) | PASS |
| T6-B tonal patches | ≥4 bins ≥3% | **4 / 4** in bins 0–3 | PASS |
| T6-C grid_peak | <0.20 | **0.083** (donor 0.048; old baseline 0.203; checker 0.93) | PASS |
| C1 L std | 30–40 | **30.93** | PASS |
| C2 bins ≥3% / low | ≥4 / ≥3 | **4 / 4** | PASS |
| C3 hi-freq | 8–12 | **10.58** (donor 11.18) | PASS |
| C4 patch px / 40² spread | 20–80 / ≥15 | **56 px / 50.84 L** | PASS |
| C5 palette, sat, val | olive; 0.30–0.55; 0.25–0.45 | `#4B4E28`; **0.522 / 0.306** | PASS |
| C6 light/dark ratio | 1.7–2.4 | **1.800** (donor crop range 1.50–1.99) | PASS |
| C7 block layers | 3 | **3** | PASS |
| C8 hist L1 | ≤25 pp | **23.54 pp** grass-only / **21.59 pp** full donor | PASS |

**Parent visual feedback (2026-11-23) and response.** T6-TERRAIN read the first
compare sheet and flagged "large blurry CAMOUFLAGE BLOBS (~40–80 px)". I accept
the texture-scale part of that criticism: the single BICUBIC-upsampled driver
had rounded, over-smooth patch edges and too little grain. The final render
adds octaves at cell/2 (w 0.20) and cell/4 (w 0.08) to roughen edges and raises
additive fine grain 4 → 6 L, lifting hi-freq 8.06 → **10.58** (donor 11.18),
with `cdf_tighten` 0.85 → 0.82 to keep histogram L1 ≤25. All 11 gates still
pass. **Scope note:** the parent's reference point was the #8 *clean-grass*
crop (std 8.6 / hf 2.96), which is this piece's negative control — §1.1/§1.2,
C1 and the failure signature above require std 30–40 and explicitly reject a
collapse to clean grass. Matching that crop would be a regression, not a fix;
only the valid "soft blobs" part was acted on.

**Visual judgement (decisive):** PASS with caveats. Grain is visibly finer and
patch edges are less blobby than the first submission; a few bright sunlit-tip
specks (~1.8% pixels) remain slightly more yellow than donor grass, and broad
tonal regions remain because C1 *requires* them. A 2-D noise proxy cannot
reproduce actual grass-blade geometry. Rejected candidates are documented in
the report (camo-posterised CDF, grid-peaked noise, fire-yellow blobs).

**Outputs:** `app/shots/pieces/t6_grass_mottled.png` (sha256
`d6e09cc2792cc8cad58ca4acd0102d544b89897d84e91838b70a005a1566867e`),
`..._compare.png` (`d3fbe978e8a2721640f9b2688cd8232861086d155939f0fa768050b4f2141b47`),
`..._nogain.png` (`5101196dc516c0a1128de947620db055f1d39a6bda0ee420f0c259bb44417e2a`).
Determinism verified byte-identical across two runs.

**Open questions:** (a) `grid_peak` detrend definition is my derived high-pass
ACF — parent ratification needed; (b) clean-grass bin count is 2 measured, not
the stated ≥3; (c) bright-tail censoring confirmed as pure-grass intent?;
(d) shared `patches` clamp defect needs an integration ticket (not edited here);
(e) exact donor gain bitmap still unknown — proxy is INFERRED.

