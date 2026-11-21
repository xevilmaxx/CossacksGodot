# T2-BUILD-RENDER — non-water render fixes (world.gd)

Owner: T2-BUILD-RENDER. Date 2026-11-21. Sole owned file: `app/scripts/world.gd`.
Water-owned code (`_setup_water_overlay`, `app/shaders/water_overlay.gdshader`)
was **not** edited.

## Backup

`inbox/backup/world.gd.bak-T2RENDER` (115,743 bytes) — taken immediately before
any edit, with T2-BUILD-WATER's changes already present.

## Exact diff (final file:line)

| # | Change | final line(s) |
|---|---|---|
| 1 | Shore band substrate: `ter_wash` pale sandsea-grain image built in `_build_masks`; `_chunk_fields()` + `_shore_substrate()` bake a depth-tinted bed (pale `#C3D1CA` in the 0–0.57 m collar, deep teal offshore) with a sand-neighbour contour edge; `t==3` role pass uses it instead of flat `ter_blue` | 71, 963–977, 1140–1240, 1430 |
| 2 | Ravine visual face-collar: `FACE_VIS_THRESHOLD=0.25` (below 0.5 collision), `FACE_LIT`/`FACE_SHADOW` palette, `_face_collar()` paints rock8 fill + 2×-stretched rock1 flutes, hard grass rim, gradient-keyed lit/shadow ramp, per-segment crop offsets; called from `_build_chunk` | 1242–1346, 1444 |
| 3 | Terrain-driven grass gain: dead `_gain_at()` replaced with a mirror-folded signed ±gain field (128-tile period, 20–80 px patches); `_grass_gain()` composites olive light/dark patch overlays; `GRASS_PATCH_HARD_RIM` option; relief shade ceiling 0.20→0.14 | 598–657, 1470 |
| 4 | Mine marker: deposit draws `mine_<type>` sprite, no olive apron disc/ore-dot trio, contact shadow only; height 2.8 m, mine jitter forced to 1.0/1.0 | 156–163, 2017–2037 |
| 5 | Field decal: `envfieldd`/`envfielddw` loaded with donor alpha, drawn as a 2.3-tile 2:1 ground decal with linear gold tint; procedural stalks kept for depleted/fallback | 1838–1882, 2014–2016 |
| 6 | Decor thinning: forest detail 1–3 trees/cell → ~1/cell (10% zero, 8% two); broadleaf 14%→38%; height buckets 1.6/4.0/6.8→1.4/3.2/5.4 m; lower-left contact shadow; understory/edge thresholds 0.5→0.62 / 0.62→0.78; resource tree bases 7.5/12.5→4.4/6.2 m | 1666–1670, 1692, 1721–1739, 1794–1800, 1829, 1833, 1974 |

Diff size: 415 insertions / 66 deletions in `app/scripts/world.gd`.
`terrain[]`, `blocked[]`, `game.gd` and the sim RNG were not touched.

## Gates (all via `app/tools/godot_runner.py`, timeout >= 300000 ms, --max-wait 3600)

| Gate | Runner id(s) | Result |
|---|---|---|
| `--check-only` | `t2render-check-v2` (ticket 801) | ok |
| selftest | `t2render-selftest-v2` (802) | 29/29 PASS, `passed=true` |
| uitest | `t2render-uitest-v2` (803) | 17/17 PASS, `passed=true` |
| `bake_bench.py --frames 120` | `t2render-bench-v2` (805) | `max_ms=219.47`, `mean_ms=111.71` → **PASS** (<250) |

An earlier implementation called `height_at()` per sub-node and measured
`max_ms=603.28` (FAIL); precomputed 35×35 tile grids + coarse early-outs brought
it to 219.47 ms. First PASS measurement was 218.70 ms.

## Captures (1280×720, non-blank, Pillow-verified)

`app/shots/t2render_land.png` (terrain_land.json), `t2render_relief.png`
(terrain_relief_probe.json), `t2render_shore2.png` (new `app/shots/t2render.json`,
mediterranean + `screenshot_focus: relief`), plus an earlier start-framed
`t2render_shore.png`.

| Capture | mean RGB | L mean | L std |
|---|---|---|---|
| t2render_land | (66.3, 64.2, 30.7) | 62.2 | **31.1** |
| t2render_relief | (61.4, 60.0, 28.1) | 57.8 | 22.6 |
| t2render_shore2 | (79.3, 89.9, 81.7) | 87.8 | 45.9 |

## Before/after measured numbers

- **Shore collar** (same box, `water_t2.png` from T2-BUILD-WATER →
  `t2render_shore2.png`): mean RGB **(103.8, 94.0, 65.1)** → **(155.2, 165.7,
  150.9)**. The flat blue-teal ring (sampled (40,82,97) in the water report) is
  replaced by a pale wash contour; individual pale samples reach
  (175,187,181), with the coordinator's `#C3D1CA` gate as the target.
  Sampled transect values in the collar are 140–190 L, no constant-L run.
- **Grass tonal std**: full-frame 24.0 (`terrain_land.png`) → **31.1**
  (`t2render_land.png`), inside the 30–40 target. Two clean-grass boxes: 19.0 /
  14.5 → **24.4 / 23.3** (still below 30; see gaps). No checkerboard: patch
  field is bilinear and mirror-folded with 128-tile period.
- **Field decal**: footprint strip median RGB **(137,117,36)** vs spec gold
  `#94762E` (148,118,46) → Δ(−11,−1,−10), within ±15. Alpha footprint from
  donor DXT5 now visible (rectangular gold patch, not a full-tile olive square);
  procedural stalks remain the fallback.
- **Forest detail density**: code-level mean 2 trees/cell (1,953/MP) →
  **0.972 trees/cell (≈949/MP)**, inside the 650–1000/MP band; 3 height
  buckets retained; broadleaf share 14%→38%.
- **Mine marker**: `mine_<type>` sprite at 2.8 m with 1.0/1.0 jitter; the
  43.8%-bbox olive disc and three ore-dot circles are gone (code-level; no
  mine was inside the captured viewport).

## Honest remaining gaps

1. Ravine **≤3 px rim** is approximated at ~8 px @720p (1/4-tile sub-grid).
   A true 3 px contour needs per-pixel height sampling, which re-broke N-07
   (603 ms) when attempted at height_at() granularity. Flute anisotropy and
   the exact lit/shadow hexes remain 2D-proxy limitations (see
   `verdict_grass_relief.md` §8 rows 2–3).
2. Grass std in *clean* grass boxes is 23–24, below the 30–40 band; the
   full-frame 31.1 is boosted by dirt/rock edges. Patch colour endpoints were
   pushed beyond the donor `#3E411F`–`#6B6732` hex range to reach the std
   target, so the bright patches are more yellow than the donor piece.
3. Mine/field were not inside the captured camera view (mine marker code path
   verified, field measured in the start-framed capture); a mine-focused
   capture is still needed for A1/A5/A6 pixel confirmation.
4. Shore pale band is ~35–45 L darker than `#C3D1CA` at the sampled box because
   the GPU overlay's shallow body still contributes; the water shader was
   deliberately left untouched.
5. N-07 headroom is 30 ms (219 of 250); further per-chunk work needs a
   re-benchmark.

---

## APPEND — shore halo correction (second pass)

The first-bed version keyed the pale zone off DEPTH, so on a gently sloping
lake bed the pale zone spanned 80–120 px and, mixed with the overlay's bright
shallow body, read as a near-white halo. Corrected in the world.gd sections I
own; the water shader and all water-owned code remain untouched.

### Exact diff (final file:line)

| Change | Line(s) |
|---|---|
| Bed keyed off **shore distance** (1 tile = 32 px @720p) instead of depth; constants `SHORE_WASH_TILES=1.0`, `SHORE_WASH_DEPTH=0.35`, `SHORE_PALE=#BDBDA9`, `SHORE_SHALLOW=#C3D1CA`, `SHORE_DEEP`, `SHORE_GROUND` | 1186–1191 |
| 3-pass distance relaxation on the cached 35×35 tile grid; pale art only on shallow water cells within 1 tile of a non-water cell; land cells get muted ground colour (no inland bleed); hard contour at band outer edge; `sub=2` to hold N-07 | 1193–1268 |
| Face-collar rim crop converted to RGBA8 (format-mismatch fix surfaced after T2-BUILD-GEN changed the selftest map) | 1362 |

### Before/after shoreline profiles (`t2render_shore2.png` → `t2render_shore3.png`)

Widest contiguous pale run per transect, mean RGB of that run:

| y | shore2 width / RGB | shore3 width / RGB |
|---|---|---|
| 250 | 73 px / (160,174,167) | **39 px / (156,160,146)** |
| 360 | 39 px / (134,143,135) | **21 px / (148,152,138)** |
| 480 | 74 px / (160,176,171) | 69 px / (138,144,133) |
| 600 | 26 px / (131,151,150) | **26 px / (159,164,150)** |

The 80–120 px near-white halo is gone; three of four transects are now inside
the 30–50 px wash band, with grey-green RGB ~138–164 instead of 200+. The y=480
transect is a shallow-angle shoreline and remains ~69 px (residual gap).

### Gates / capture after the append
- `--check-only`: `t2render-shore-check-done` (848/857) ok.
- `bake_bench.py --id t2render-shore-bench`: final ticket 858,
  `max_ms=220.60`, `mean_ms=114.44` → **PASS**. (Two intermediate runs with
  the same id measured 267/388 ms during a concurrent `t2gen-check-final`
  timeout; all later runs pass 200–232 ms.)
- selftest: `t2render-shore-selftest` — **28/29**, the single failing step is
  `build` (house did not finish). `game.gd` / `pattern_gen.gd` were modified by
  T2-BUILD-GEN at 3:50/3:43 PM, after my earlier 29/29 green run; the failure
  is sim-side and outside my owned file. My own render script errors were fixed
  (`blend_rect_mask` format mismatch).
- uitest: `t2render-shore-uitest` (860) **17/17 PASS**.
- Capture: `app/shots/t2render_shore3.png` — 1280×720, non-blank (ticket 855).

