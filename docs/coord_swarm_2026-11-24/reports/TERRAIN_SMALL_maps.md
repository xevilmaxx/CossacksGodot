---
id: TERRAIN-SMALL
title: "Terrain regression at 64x64 / 128x128 tiles — fixtures, headless probe, one windowed capture"
owner: TERRAIN-SMALL
date: 2026-11-24
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
status: FAST_LANE__64_PROBE_21of21__64_CAPTURE_OK__128_READY_NOT_RUN__NO_DONOR_AB
scope: "ONLY two new test fixtures, one new probe script, one new read-only tool, this report. No source/shader/canonical config/app/manifest/gate-file/git edit."
owns:
  - "variant3d/tests/fixtures/small_map_64.json"
  - "variant3d/tests/fixtures/small_map_128.json"
  - "variant3d/tests/t_smallmap_terrain.gd"
  - "variant3d/tools/smallmap_capture.py"
  - "docs/coord_swarm_2026-11-24/reports/TERRAIN_SMALL_maps.md"
labels: [SMALL_MAP_REGRESSION, FACE_MODE, SHADOW_DISABLE_GATE, TILE_ART_LIMITATION, NO_VISUAL_PARITY_CLAIM]
visual_parity_claim: false
runner: "variant3d/tools/godot_runner.py only. Tickets 301/302/306 failed (my path/script bugs, kept for transparency); 307 = 64 probe PASS 21/21; 308 = 64 windowed capture OK. No 128 job, no full selftest (fast-lane instruction)."
---

# TERRAIN-SMALL — terrain tests on much smaller maps

## 0. Scope and honesty guard

Fast lane: deliver both fixtures + probe + this report; run **one** final 64×64
probe and **one** 64×64 windowed capture. The 128×128 harness is authored and
ready but **READY_NOT_RUN**. No donor frame exists; no visual parity is claimed.
Dark bands in the capture are **height-driven water fields** (`water3d.gd`),
not shadows — a controlled shadow A/B measured 0 changed pixels because the
tile shader is `unshaded` (FIX-TERRAIN report §5, ticket 291).

## 1. How main.gd accepts a test config

`main.gd:27,1278-1281` parses `--config <file.json>` from
`OS.get_cmdline_args()` / `OS.get_cmdline_user_args()` (`main.gd:171-172`) into
`config_path`; `_ready()` calls `cfg.load_all(config_path)` then `cfg.apply()`
(`main.gd:175-177`). `config.gd:226-246` reads `res://config.json` first and
**merges** the extra file over it (`_merge`, `config.gd:329-337`), so an overlay
that only sets two keys leaves every other value at its canonical value.
`config.gd:405-407` maps those keys to `Data.MAP_W/MAP_H`; `main.gd:181-182`
maps `gameplay.render_mode` to `Data.RENDER_MODE`. Therefore the fixtures are
minimal overlays, not copies of the canonical config.

## 2. Config diffs (canonical `variant3d/config.json` untouched)

| File | `gameplay.map_width_tiles` | `gameplay.map_height_tiles` | `gameplay.render_mode` | `gameplay.random_seed` | Everything else |
|---|---:|---:|---|---:|---|
| `variant3d/config.json` (canonical, hash `0B7E2538…A69041`, mtime 17:02:55) | 320 | 320 | `3d` | 20261113 | baseline |
| `variant3d/tests/fixtures/small_map_64.json` | **64** | **64** | `3d` (verbatim guard) | 20261113 (verbatim guard) | inherited, unchanged |
| `variant3d/tests/fixtures/small_map_128.json` | **128** | **128** | `3d` (verbatim guard) | 20261113 (verbatim guard) | inherited, unchanged |

Only the two map-size keys differ from the canonical config; the repeated
render_mode/seed are the same values, present so the fixture states its
invariants explicitly. Donor seed, `map_type=land`, relief/season/richness and
all height rules are inherited from the canonical config and `config.gd`
defaults — no map-generation constant was changed.

Runner invocations (fast lane, 64 only):

```
python variant3d/tools/godot_runner.py run --id smallmap-probe-64-r4 --timeout 300 -- \
  --headless --path variant3d --script res://tests/t_smallmap_terrain.gd -- \
  --config <abs>/small_map_64.json --screenshot <temp>/terrain_smallmaps/unused_64.png
python variant3d/tools/godot_runner.py run --id smallmap-shot-64 --timeout 420 -- \
  --path variant3d -- --screenshot <temp>/terrain_smallmaps/smallmap_64.png \
  --screenshot-frames 10 --config <abs>/small_map_64.json --timeout 300
```

`--screenshot` is a **test-only** runner flag that makes `main.gd:230` skip the
menu and build the full game (`main.gd:231,1034,1043-1058`); the probe never
writes that dummy PNG. `--timeout 300` is `main.gd`'s watchdog (`main.gd:1274`).

## 3. Probe design (`variant3d/tests/t_smallmap_terrain.gd`)

`extends SceneTree` (required by `--script`). Reads `--config` from user args,
validates the fixture is JSON and square 64/128, then instantiates the real
`res://scenes/main.tscn` and adds it to root. Because a custom `SceneTree` main
loop delivers the scene's `_ready()` only once the loop starts, all inspection
runs on the first `_process()` tick (this was the cause of the first false
failure: the initial version read unmodified `Data` defaults 160/2d).
Verifies and measures 21 checks:

1. `fixture_map_size`, `real_game_boot` — fixture 64/128, runtime `render_mode=3d`, `Data.MAP_W/H`, seed.
2. `terrain_mesh_present`, `terrain_stats_present` — `HeightmapTerrain` MeshInstance3D, its module parent, non-empty `stats`.
3. `single_surface`, `vertex_count`, `triangle_count`, `uv2_count` — exactly `w*h` vertices / `(w-1)²·2` triangles / `w*h` UV2 entries.
4. `uv2_x_donor_range` — UV2.x inside `[0,123]` (manifest `named_cells=124`), counts out-of-range.
5. `uv2_y_face_modes` — UV2.y strictly in `{0,1,2}`, measured histogram.
6. `face_hist_sum` / `face_hist_matches_uv2` — `stats.tile_index.face_hist` sums to `w*h` and equals the measured UV2.y histogram.
7. `flat_face_zero` — calls the shipped `_face_mode_at` on an all-constant `w*h` grid; promoted cells must be 0 (FIX-TERRAIN §8 regression guard, no atlas rebuild).
8. `tile_index_cells` — `w*h` cells, live `dump.tileblock base64` source, out-of-atlas clamp count.
9. `atlas_grid_manifest`, `atlas_material_bound`, `shader_shadow_disabled` — `stats.atlas.grid=[16,8]`, shader `atlas_grid=(16,8)`, three sampler textures bound, `shadow_enabled=0`.
10. `donor_sun_present`, `donor_sun_shadow_off`, `terrain_cast_shadow_off` — FIX-TERRAIN explicit shadow-disable gate at every size.
11. `water_module_present` — `Water3D` node, one `WaterPlane`, `water3d.gd`, `height_aware=true`.

`no SCRIPT ERROR` is verified externally by
`python variant3d/tools/smallmap_capture.py scan-stderr <stderr.txt>` (GDScript
has no stderr API). Results are printed to stdout and written to
`user://smallmap_terrain_<size>.json` (outside the repo).

## 4. Measured counts

### 64×64 — ticket 307, exit 0, 15.35 s, **21/21 PASS** (`smallmap_terrain_64.json`)

| Quantity | Measured | Expected |
|---|---:|---:|
| Runtime map / render mode / seed | `64×64`, `3d`, `20261113` | same |
| Mesh surfaces | 1 | 1 |
| Mesh vertices | **4,096** | 64² |
| Mesh triangles | **7,938** | 63²·2 |
| UV2 entries | **4,096** | 64² |
| UV2.x range / out-of-atlas | `0..85`, 0 | inside `0..123` |
| UV2.y histogram | `{0: 3455, 1: 311, 2: 330}` | sum 4,096 |
| `face_hist` (stats) | `{0: 3455, 1: 311, 2: 330}`, sum 4,096 | matches UV2 |
| Flat-grid promoted cells | 0 | 0 |
| Tile-index cells / source | 4,096 / `dump.tileblock base64 (main.gd:741)` | live |
| Tile ids observed | 28 distinct, range 0..85; top: `0:1110, 10:507, 14:359, 25:277, 20:230, 16:221, 79:192` | ≤124 |
| Atlas grid / mode | `(16,8)` / `single` | `(16,8)` |
| Shader `shadow_enabled` | `0.0` | 0 |
| `DonorSun.shadow_enabled` | `false` | false |
| Terrain `cast_shadow` | `0` (OFF) | OFF |
| Water | `Water3D`, 1 plane, `height_aware=true` | present |
| SCRIPT ERRORs (stderr scan) | **0** | 0 |

### 128×128 — **READY_NOT_RUN**

`small_map_128.json` and the same probe are ready; the fast-lane instruction
forbids the job. No counts, no capture. All 128² expectations are `w*h=16,384`
vertices/UV2, `127²·2=32,258` triangles, `face_hist` sum 16,384, atlas `(16,8)`,
sun/terrain shadow OFF, one water plane.

## 5. Capture (64×64 only) — ticket 308, exit 0, 21.29 s

Real GPU frame via `Screenshot3DViewport` (`main.gd:1180-1193,1789-1825`);
stdout confirms `viewport=Screenshot3DViewport image=1280x720`,
`camera_current=true`, `world_parent=Screenshot3DViewport`. Files are outside
the repo in `C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/terrain_smallmaps/`.
Read-only stats from `variant3d/tools/smallmap_capture.py stats`:

| Image | Bytes | Dimensions | non-black | mean RGB | mean luma | full-width dark rows |
|---|---:|---|---:|---|---:|---:|
| `smallmap_64.png` | 1,705,282 | 1280×720 | 0.99916 | `[42.883, 46.497, 25.718]` | 44.181 | **0** |
| `smallmap_64.png.raw.png` | 1,705,282 | 1280×720 | 0.99916 | same | same | 0 |
| reference `C:/Users/.../Temp/opencode/v792_tileindex_water.png` (320², older V7-92 frame) | 1,636,628 | 1280×720 | 0.998254 | `[59.575, 48.877, 25.964]` | 49.463 | 0 |

Qualitative comparison only: the 64² frame is darker in red channel and lower
luma than the older 320² reference, but the reference has different entity
colours (red debug buildings) and a different camera focus, so it is **not** a
controlled A/B and no donor parity is inferred. Non-black > 0.9 as required by
FIX-TERRAIN §8.

## 6. Artifact observations and scaling

Visible in `smallmap_64.png` (visual inspection, not a donor comparison):

- **Repeated light "maze"/stepped tile pattern** across most of the ground —
  the known data-level limitation (FIXTERRAIN RC1: live tileblock has few ids,
  transition tiles `test7/8/9` occupy a large share; only 82 unique block arts
  for 124 atlas cells). At 64² the pattern is visibly coarser: each donor tile
  covers a larger fraction of the frame than at 320². This is **art/data**, not
  a shader bug, and it reproduces at 64².
- **Dark horizontal/diagonal bands** (e.g. across the middle and lower half,
  plus the dark blocky patch near centre-bottom) match the height-driven water
  fields. Per the coordinator/FIXTERRAIN shadow A/B they are **not shadows**;
  the tile shader is `unshaded` and toggling the shadow map changed 0 pixels.
  They reproduce at 64², with band footprint relative to the frame larger than
  at 320².
- **No full-width dark streak**: automated metric reports 0 rows where >90 % of
  pixels have luma < 20. The unbounded directional streak attributed to the old
  400 m shadow frustum over a 640² mesh does **not** reproduce at 64² with
  shadows disabled — expected, since both the map extent and the shadow map are
  gone.
- **Seams / wrong colours**: no new seam class was observed; the apparent seams
  are the tile-art repetition above. Exact donor vf/vs promotion, eye-plane UV
  and alpha sub-rect remain PORT APPROXIMATION, so any residual wrong-colour
  claim is UNVERIFIED.

Scaling summary: **tile-art repetition and water bands are present at 64² and
scale with map size in apparent feature size** (smaller map → larger features);
**shadow streaks are absent at 64²**, which is a regression gate, not proof of
a donor-faithful fix. 128² NOT RUN.

## 7. Gate files untouched (hash/mtime check, no writes)

| File | Before and after SHA-256 | mtime | Artifact |
|---|---|---|---|
| `variant3d/selftest.json` | `EF7596ADE091E8965A0045383E6BB0F3AA7D9604B46AA01F110287E787C80A5F` | 11/24/2026 5:17:31 PM | `passed=true`, **29 steps** |
| `variant3d/uitest.json` | `F05EB6D8D119E4DE9F37DD314EA450267999C4B5C53C7F2776238613AC5B5C33` | 11/24/2026 4:09:56 PM | `passed=true`, **17 steps** |

Hashes and mtimes are identical before and after this wave. Full selftest was
**not** re-run (fast-lane instruction); the 29/29 and 17/17 artifacts are the
pre-existing ones, only checked, never overwritten.

## 8. Job history (transparency)

| Ticket | id | Result | Note |
|---:|---|---|---|
| 301 | `smallmap-probe-64` | failed 5.03 s | my `%20` literal in the config path; no script fault |
| 302 | `smallmap-probe-64-r2` | failed 20.54 s | inspected inside `_initialize()` before `_ready()` delivered; saw defaults 160/2d |
| 306 | `smallmap-probe-64-r3` | failed 2.42 s | parse error: locals `gp`/`want_h` used from split `_run_checks()`; fixed by member vars |
| 307 | `smallmap-probe-64-r4` | **ok, 21/21** | final 64² probe |
| 308 | `smallmap-shot-64` | **ok** | final 64² windowed capture |

No 128² job, no full selftest, no git command.

## 9. UNVERIFIED / open

- 128² probe and capture: **READY_NOT_RUN** by instruction; all 128² counts are predictions from `w*h`, not measurements.
- No donor GPU A/B at any size: visual parity UNVERIFIED (as everywhere in this project).
- Water bands are attributed to `water3d.gd` per FIX-TERRAIN's controlled A/B, but no new per-size A/B was run here.
- Eye-plane UV values, exact donor vf/vs promotion and alpha sub-rect mapping remain ENGINE/UNVERIFIED; 64² `face_hist={0:3455,1:311,2:330}` is a port approximation, not a donor measurement.
- Unrelated capture-time stderr had `mill_rotor.png` resource-load errors and an RID leak; `SCRIPT ERROR` count is 0 for both final jobs, but those errors were not fixed here (outside ownership).
- `small_map_*.json` overlays inherit canonical values; if the canonical config changes, the fixtures' explicit render_mode/seed guards could become stale (they are intentionally equal today).
