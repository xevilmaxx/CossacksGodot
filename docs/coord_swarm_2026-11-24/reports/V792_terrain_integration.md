---
id: V7-92
task: "TERRAIN2-06 A3 integration — wire V7-85 atlas + V7-86 shader + V7-91 loader + V7-84 water into the one terrain module"
title: "Single terrain module now consumes live game.tileblock, tile-index shader, dual atlas transport and donor water"
owner: V7-92
date: 2026-11-24
status: DELIVERED__PARSE_CLEAN__PROBE_20of20__SELFTEST_29of29__WINDOWED_CAPTURE__NO_VISUAL_PARITY_CLAIM
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
scope: "ONE existing file (variant3d/scripts/world3d_terrain.gd) + ONE report. No shader, loader, water module, atlas asset, app/, config, test or git edit. One temp probe was created, run, and DELETED."
owns:
  - "variant3d/scripts/world3d_terrain.gd (sole ownership, integration only)"
  - "docs/coord_swarm_2026-11-24/reports/V792_terrain_integration.md (this file)"
labels: [DONOR_TILE_INDEX_FROM_LIVE_GAME, PORT_APPROXIMATION_TRANSPORT, UNVERIFIED_EYE_PLANES, UNVERIFIED_FACE_PROMOTION, NO_VISUAL_PARITY_CLAIM]
visual_parity_claim: false
runner: "variant3d/tools/godot_runner.py only; jobs 246,247,249,251,252,253 (final parse 247, final probe 251, selftest 252, capture 253)"
verification_counts:
  parse: "ticket 247 ok, exit 0, 5.56 s, stderr 0 B"
  probe: "ticket 251 ok, exit 0, 35.84 s, 20/20 PASS"
  selftest: "ticket 252 ok, exit 0, 62.24 s, variant3d/selftest.json passed=true, 29/29 steps passed"
  capture: "ticket 253 ok, exit 0, 43.69 s, Screenshot3DViewport 1280x720"
tile_index_source: "LIVE GAME — game.tileblock PackedByteArray (game.gd:53,1610-1689; main.gd:741 dump base64), uint8 per cell, 320x320 = 102,400 cells"
atlas_modes: "single (DEFAULT, coordinator update) / split / array; loader reports chosen mode in stats['atlas_mode']; split+array verified 28/28 by V7-91 job 245"
atlas_dimensions_measured: "16384x8192 RGBA, grid [16,8] from V7-85 manifest, 124 named / 121 filled cells"
water_uniforms_measured: "water_level=-0.25, shore_height=-0.1, max_height=2.96 (texturemap.inc:29-31); height_aware=true after bind_height_grid()"
capture_path: "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v792_tileindex_water.png (OUTSIDE repo)"
---

# V7-92 — terrain integration (single module, three landed pieces wired)

## 0. Verdict and honesty guard

The one terrain module now (1) loads the V7-91 atlas through a stable loader with
public `set_atlas_mode("single"|"split"|"array")` — **`single` is the default** per
the coordinator update, with the loader's auto-fallback single→split→array
reported in `stats["atlas_mode"]`; (2) assigns the V7-86 tile-index
`ShaderMaterial`, writing the **live donor tile id** from `game.tileblock` into
`UV2.x` and ground face mode `0` into `UV2.y`, with `atlas_grid` from the V7-85
manifest and donor intensity repacked into mask ALPHA; and (3) instantiates the
V7-84 water module, calls `bind_height_grid()` and removes the old constant quad
from the normal path.

**Tile indices came from the LIVE GAME, not a fallback.** The live field name was
verified as `game.tileblock: PackedByteArray` (`variant3d/scripts/game.gd:53`),
sized `MAP_W*MAP_H` at `game.gd:1621` and dumped base64 at `main.gd:741`; the 2D
3D sibling decodes the same uint8-per-cell buffer at
`app/scripts/world3d.gd:185-202`, and `app/scripts/world.gd:258-261` iterates it.
The port fallback label is present and tested for stubs with no tileblock.

**NO VISUAL / DONOR PARITY CLAIM.** A real windowed GPU capture was taken (§5),
but no donor frame was captured or compared. Eye-plane values, face promotion,
mask sub-rect mapping, shadow projection and the donor blend pass count remain
UNVERIFIED (TERRAIN2-06 §6; V7-86 §6; V7-84 §8).

## 1. Evidence citations (all read-only)

| # | Evidence | Observation / use | Class |
|---:|---|---|---|
| E1 | `variant3d/scripts/game.gd:53` | `var tileblock: PackedByteArray` — VERIFIED live field name | OBS |
| E2 | `game.gd:1610-1689`, `:1621` | `_assign_tileblocks()` resizes to `MAP_W*MAP_H` and writes one uint8 per cell; `BLK_WATER=255` at `:52` | OBS |
| E3 | `variant3d/scripts/main.gd:741` | dump key `tileblock` = `Marshalls.raw_to_base64(game.tileblock)` | OBS |
| E4 | `app/scripts/world3d.gd:185-202` | 2D world's 3D sibling decodes `rawtb[src]` as one byte per cell — confirms layout, NOT four sub-tile indices | OBS |
| E5 | `app/scripts/world.gd:258-261` | live `game.tileblock` iterated cell-by-cell for block names | OBS |
| E6 | `app/shots/g32_dump.json:1`, re-measured this agent | 102,400 bytes, **31 distinct ids**, min 0 / max 85, top `14:28535`, `0:15993`, `16:15962`, `79:7667`, `78:6691`, `25:4135` | MEASURED |
| E7 | `TERRAIN2_06_tileindex_architecture.md:29-31,67-72` | donor `TMapTerrainDataTile.tex` (`dmscript.global:2026-2035`) ↔ port buffer; A3 must add tileblock to `_dump_from_game()` | OBS + DESIGN |
| E8 | `V785_tile_atlas.md:52-55,226-229` | atlas 16384×8192, grid 16×8, 124 named / 121 filled; masks alpha.png 512×256 and alphavert.png 1024×512 | SHIPPED + MEASURED |
| E9 | PNG IHDR re-read this agent | both masks are 8-bit grayscale (IHDR colour type 0): intensity is in R, not A — repacked to A in this module | MEASURED |
| E10 | `V786_tileindex_shader.md:123-179` (INTEGRATION CONTRACT) | UV2.x=index, UV2.y=face mode (0 ground), `atlas_grid` from manifest with NO donor default, three samplers read `.a`, `shadow_enabled=0`, shader already `blend_mix, unshaded, cull_disabled` | CONTRACT |
| E11 | `V791_dual_mode_atlas.md:79-96,140` | loader stable API; split+array both verified 28/28 (job 245); coordinator update adds `single` default + auto-fallback | SHIPPED + MEASURED |
| E12 | `V784_donor_water_shader.md:74-82,107-119` | integration hook `build(w,h)` + `bind_height_grid(height,w,h)`; donor literals −0.25/−0.1/2.96; `hmapTex` binding UNVERIFIED | OBS + DESIGN |
| E13 | `V782_splat_detail.md:49-65,159-160` | V7-82 LINEAR filter + 1280² splat path and donor rig must be preserved | OBS |

## 2. Exact diff — `variant3d/scripts/world3d_terrain.gd` (final file line numbers)

The file was rewritten in one pass (no other file touched). Functional changes by line:

| Lines | Change |
|---:|---|
| 1-58 | Header: added V7-92 wiring description, E1-E5 live-tileblock verification, `single`-default coordinator note, NO PARITY guard. All V7-13/V7-60 donor citations kept verbatim. |
| 111-136 | Added module path constants (`TILE_ATLAS_LOADER_PATH`, `WATER3D_PATH`, `TILEINDEX_SHADER_PATH`, `V785_MANIFEST_PATH`), `ATLAS_MODE_SINGLE/SPLIT/ARRAY`, `var atlas_mode = "single"` and V7-92 state vars. |
| 158-178 | Added public `set_atlas_mode(mode: String)`; normalizes to `single`, delegates to the loader, rebuilds when already built. Loader's chosen mode is reported, not assumed. |
| 206-262 | Added `_load_atlas()`: instantiate `TileAtlasLoader` (dynamic load), call `load()`, read chosen mode via `current_mode` else `get_mode()`, take `atlas_grid()` from manifest, bind masks, and supply a dedicated split loader only when the chosen transport has no 2D atlas sampler. |
| 270-278 | Added `_repack_mask_alpha()` — grayscale R→A intensity repack (E9), so V7-86's `.a` reads donor intensity. |
| 290-305 | Added `_tileindex_material()` — assigns tile_atlas/alpha_atlas/alphavert_atlas, `atlas_grid`, `shadow_enabled=0.0`; deliberately NO cull/transparency (shader owns them). |
| 307-320 | **Preserved unchanged** V7-82 `_terrain_material()` incl. `TEXTURE_FILTER_LINEAR` at line 309. |
| 347-386 | `_dump_from_game()` extended to include base64 `tileblock` from the live game (line 371 fix: pass `PackedByteArray` directly to `Marshalls.raw_to_base64`, no `.to_byte_array()`). |
| 389-428 | Added `_decode_tile_indices()`: accepts dump `PackedByteArray` or base64, else live `game.tileblock`; builds histogram; fallback label `PORT APPROXIMATION — NOT DONOR PARITY` at line 420. |
| 431-462 | **Preserved** old `_make_water()` verbatim, now fallback-only. |
| 464-487 | Added `_make_water3d()`: V7-84 module `build(w,h)` before `add_child`, `bind_height_grid(height,w,h)` at line 479, internal plane renamed `WaterPlane` at line 484 (keeps `terrain3d_sandbox.gd:122` hook), no double water surface. |
| 494-528 | **Preserved unchanged** V7-60 `WorldEnvironment`/`DonorSun` rig (`DonorSun` at 519). |
| 531-554 | `invalidate()` clears all new references as well as the old mesh/rig. |
| 557-700 | `build()`: live-height decode unchanged; tile-index decode + atlas load at 583-586; `ARRAY_TEX_UV2` written at 631 and attached at 649; clamp guard at 613/629 for out-of-atlas ids (e.g. `BLK_WATER=255`); tile-index material chosen at 659 with splat fallback at 665-668; water module at 679-682; stats assembled. |
| 722-762 | Stats: A3 shape `tile_index_cells`, `tile_index_hist`, `atlas_path`, `uv_model`, `face_model` plus `atlas_mode`, `atlas`, `tile_index`, `material_model`, `water`; all original keys retained. |
| 800-817 | **Preserved unchanged** `height_at_world()` bilinear sampler. |

## 3. Measured verification (variant3d runner only)

| Job / ticket | id | Result | Measured |
|---:|---|---|---|
| 246 | `v792-parse-terrain` | failed (4.48 s) | Parse error: `PackedByteArray.to_byte_array()` does not exist (line 371); fixed by passing the array directly. |
| **247** | **`v792-parse-terrain-r2`** | **ok, exit 0, 5.56 s, stderr 0 B** | `--headless --path variant3d --script res://scripts/world3d_terrain.gd --check-only` clean. |
| 249 | `v792-integration-probe` | failed (5.35 s) | Probe stub issue: `C3Game.map_w` not assignable; fixed with a `StubGame extends C3Game` subclass (same pattern as `t_terrain3d.gd:41-46`). |
| **251** | **`v792-integration-probe-r2`** | **ok, exit 0, 35.84 s, 20/20 PASS** | Probe results below. Temp probe + result JSON DELETED after the pass. |
| **252** | **`v792-selftest`** | **ok, exit 0, 62.24 s** | `variant3d/selftest.json` `passed=true`, **29/29** steps `passed=true`, 0 failed. |
| **253** | **`v792-shot-windowed`** | **ok, exit 0, 43.69 s** | `viewport=Screenshot3DViewport image=1280x720`, `camera_current=true`, `world_parent=Screenshot3DViewport`, capture source `Screenshot3DViewport/1280x720`. |

### Probe measurements (ticket 251, 20/20)

- `default_mode_single`: `atlas_mode="single"` (coordinator default).
- `chosen_mode_reported`: `stats.atlas_mode="single"` == `stats.atlas.grid=[16.0, 8.0]` source; loader's chosen mode surfaced.
- `array_mode_initialises`: `set_atlas_mode("array")` → chosen mode `array`, **121 array layers**.
- `split_mode_initialises`: `set_atlas_mode("split")` → chosen mode `split`, atlas size **[16384, 8192]**.
- `tile_index_uv2_values`: stub dump with real 102,400-byte tileblock pattern
  `[14,0,16,25,7,255]` → **102,400 UV2 entries, 0 mismatches**; first six
  `14,0,16,25,7,0` (255 = `BLK_WATER` clamped by the PORT GUARD).
- `tile_index_hist`: **102,400 cells**, `hist14=17067`, `hist255=17066`,
  source `dump.tileblock base64 (main.gd:741)` — i.e. indices came from a real
  tileblock, not fabricated.
- `atlas_grid_from_manifest`: `(16,8)`; `atlas_samplers_bound`: atlas
  `[16384,8192]`, both masks bound; `mask_intensity_in_alpha`:
  `alpha(0,0).r == .a`, format 5 (RGBA8 after repack).
- `shadow_disabled_and_no_extra_cull`: `shadow_enabled=0.0`.
- `water_module_attached` + `water_donor_literals`: `water_level=-0.25`,
  `shore_height=-0.1`, `max_height=2.96`; `water_height_grid_bound`:
  `height_grid={w:320,h:320}`, `height_aware=true`; `single_water_plane`:
  renamed `WaterPlane` carries a `ShaderMaterial` (no stacked quad).
- `donor_sun_rig`: `WorldEnvironment` (WorldEnvironment) and `DonorSun`
  (DirectionalLight3D) both present.
- `stats_shape_preserved`: all expected keys present, `missing=[]`.

### Real shipped-dump measurement (read-only Python, this agent)

`app/shots/g32_dump.json:1` key `tileblock`: **102,400 bytes**, **31 distinct
ids**, range **0..85**, top ids `14:28535`, `0:15993`, `16:15962`, `79:7667`,
`78:6691`, `25:4135` — matches V7-85 §6 and E6. Manifest `atlas.size=[16384,8192]`,
`grid=[16,8]`, `named_cells=124`, `filled_cells=121`.

Probe stderr contained only expected Godot import warnings while array mode
loads the block PNGs (`Image.load` of un-imported PNGs, the documented V7-85/V7-91
runtime path) — no terrain error.

## 4. Preserved-work checklist

| Work | Preserved | Evidence |
|---|:---:|---|
| V7-60 donor `WorldEnvironment` + `DonorSun` rig, `SUN_POS`, `DONOR_AMBIENT/DIFFUSE`, energies, Z-up→Y-up transform | ✅ | file lines 57-64, 494-528; `DonorSun` at 519 |
| V7-82 `TEXTURE_FILTER_LINEAR` and 1280² splat path/fallback | ✅ | lines 113, 307-320, 664-668; G3-4 splat PNG untouched |
| Live-height mesh (one full-grid ArrayMesh, central-difference normals, cell-centre UV, one draw call) | ✅ | lines 597-656; `height_at_world()` 800-817 unchanged |
| `bind/build/invalidate/has_chunk_or_fallback/height_at_world` V73 API | ✅ | lines 183, 557, 531, 792, 800 |
| Old constant water quad | ✅ fallback-only | `_make_water()` 431-462 called only if V7-84 module fails (679-681) |
| Stats original keys (grid, albedo, water_level_m, sun, donor_references, timing) | ✅ | 705-796, all original keys retained |
| Donor citations | ✅ extended | lines 24-58, 751-766 |

## 5. Windowed GPU capture

Real `Screenshot3DViewport` path (no headless CPU fallback), via the runner:

```
python -X utf8 variant3d\tools\godot_runner.py run --id v792-shot-windowed --timeout 420 -- \
  --path variant3d -- --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v792_tileindex_water.png" \
  --screenshot-frames 10 --timeout 300
```

Path: `C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v792_tileindex_water.png`
(**outside the repo**, 1,636,628 bytes, 1280×720).

Qualitative read only: donor-block tile grain is visible on the ground (repeating
grass/road/rock block patterns) and the water band is present; red-highlighted
entities are the known debug/selection overlay from the existing port. Camera
position `(277.11, 39.33, -217.95)`. **No donor frame was captured; no A/B was
performed; no visual parity is claimed.**

## 6. Open questions / UNVERIFIED (do not guess)

1. Face-tile promotion (A5) has not landed: `UV2.y=0` for every cell; the
   `rockNvf/vs` 25° metadata is not applied (TERRAIN2-06 UNVERIFIED #2; V7-86 #2).
2. Runtime `gl_EyePlaneS/T[0]`, `TextureMatrix[0]`, fog light/shadow energies are
   engine-bound and UNVERIFIED — shader defaults remain neutral APPROX.
3. `alpha.bmp`/`alphavert.bmp` sub-rect↔tile mapping is UNVERIFIED
   (`reftile.lib:3-12` commented); this module repacks the whole-mask PNG into
   alpha, inventing no cell mapping.
4. The `single` default needs the 180 MB PNG in the working tree. The loader's
   auto-fallback single→split→array was NOT exercised here (the PNG was present);
   a fresh-clone fallback run remains to be measured by its owner.
5. V7-86's shader is `sampler2D`-only; in array mode the 121-layer array is
   loaded/verified but a dedicated split loader supplies the 2D sampler. A future
   shader atom could add `sampler2DArray` support; not in this file's ownership.
6. Donor `hmapTex` binding remains UNVERIFIED (DECOMP-04 §8); `bind_height_grid()`
   is an explicitly labelled PORT SUBSTITUTE.
7. Live `game.tileblock` byte-identity with the donor engine's `GetTileIndex`
   buffer is UNVERIFIED (donor `.map` body not decoded); the port buffer is the
   authoritative live source for this module.
8. `BLK_WATER=255` cells are clamped to tile 0 by a PORT GUARD (line 629) so the
   shader never samples outside the 124 named cells; under water these are
   covered by the V7-84 plane. Clamp count is in `stats["tile_index"]["out_of_atlas_cells_clamped"]`.

## 7. No-parity statement

**Visual parity against the donor is UNVERIFIED and NOT CLAIMED.** This report
documents structural integration and measured counts only. No donor binary was
executed, no donor frame was compared, and every donor behaviour that is not
readable in text carries an explicit APPROXIMATION / UNVERIFIED / PORT SUBSTITUTE
label. Where live tile indices are unavailable the module falls back to the
V7-82 splat path with the literal label
`PORT APPROXIMATION — NOT DONOR PARITY` (line 420); in the measured runs live
indices were present, so that fallback was not the source of rendered tiles.

---

*End of report. V7-92 wrote only the owned terrain module and this file; the
temporary probe and its JSON were deleted; no shader, loader, water module,
atlas asset, app/, config, test or git state was touched by this agent. The
selftest runner rewrote `variant3d/selftest.json` as its mandated output (same
as V7-82 ticket 243); this was runner-generated, not an intentional edit.*
