---
id: V7-82
owner: V7-82
title: "V7-82 — restore in-cell donor grain: 4 texels/cell splat re-bake (variant3d only)"
date: 2026-11-24
status: DELIVERED__PORT_APPROXIMATION__NOT_DONOR_PARITY
verdict: "4x splat re-bake restores measurable in-cell grain (0 -> 1.233/255 within-cell deviation; 320x320 -> 1280x1280). Parse clean (ticket 242), variant selftest passed:true 29/29 (ticket 243). Genuine Screenshot3DViewport before/after frames captured outside the repo; donor/visual parity NOT claimed."
jobs: [213, 214, 242, 243]
scope: "variant3d/tools/heightmap_splat.py (read/backup only, no code change), variant3d/assets/terrain/heightmap/splat_albedo.png + manifest (tool-regenerated), ONE line in variant3d/scripts/world3d_terrain.gd, this report. No app/ edit, no config/test edit, no git operation."
files_changed: ["variant3d/assets/terrain/heightmap/splat_albedo.png", "variant3d/assets/terrain/heightmap/splat_albedo.manifest.json", "variant3d/scripts/world3d_terrain.gd", "docs/coord_swarm_2026-11-24/reports/V782_splat_detail.md"]
backups: ["inbox/backup/heightmap_splat.py.bak-V782", "inbox/backup/splat_albedo.png.bak-V782", "inbox/backup/splat_albedo.manifest.json.bak-V782"]
classification: "PORT APPROXIMATION — NOT DONOR PARITY"
---

# V7-82 — 4× splat detail (interim polish, donor representation unchanged)

## 0. Status and honesty guard

**PORT APPROXIMATION — NOT DONOR PARITY.** This ticket restores *in-cell grain* in the
existing single-albedo 3D path by re-baking the already-shipped splat at
`--texels-per-cell 4`; it does **not** reproduce the donor representation.
TERRAIN2-01 (`docs/coord_swarm_2026-11-24/reports/TERRAIN2_01_donor_pipeline.md:152-157,199-205`)
establishes that the donor stores **one integer tile index per cell** (`tex`,
`GetTileIndex`/`SetTileIndex`; no splat weights), selects it from slope aspect and
`tilesmooth_scripts.cfg` neighbour rules, and derives terrain albedo UVs from
**eye planes** (`hf.pvl.sm.vert:26-33`, `shaders.lib:30`; cited at
`TERRAIN2_01_donor_pipeline.md:75,369-372`) instead of our 0..1 map UVs. No amount of
splat resolution reproduces that coordinate/behaviour model. Implementing tile
indices, `vf/vs/f/s` face variants or eye-plane projection is explicitly **out of
scope** here and belongs to the separate architecture agent.

No donor binary was read, executed or copied. No 2D bake spritesheet and no
8-azimuth output was produced or edited by this ticket.

## 1. Evidence (path:line)

| # | Evidence | Observation |
|---|---|---|
| E1 | `variant3d/tools/heightmap_splat.py:191-208` | `block_texels()` LANCZOS-resizes each 1024² donor-derived PNG to `n×n`; with `n=1` one RGB mean per 2 m cell. |
| E2 | `variant3d/tools/heightmap_splat.py:230-297,383-384` | `build_splat()` output is `map_w*n × map_h*n`; `--texels-per-cell` flag already exists (default 1). No tool code change was needed or made. |
| E3 | `TERRAIN2_02_donor_textures.md:59,141` | P10: default `n=1` ⇒ one mean RGB per block/cell (grass1 `[76,83,30]`); 99.9% of donor grain discarded — direct cause of the flat dark-olive frame. |
| E4 | `TERRAIN2_04_gap_recipe.md:105-118` | P0-1: re-run the existing tool with `--texels-per-cell 4`, keep donor-derived manifest provenance, set LINEAR filter; expected gain = in-cell mottling, no mesh/UV change. |
| E5 | `app/scripts/world.gd:1012-1034,1040-1042` | 2D port already renders the same donor blocks at 64 px per 2 m cell; only the 3D splat path flattens them. |
| E6 | `variant3d/assets/terrain/heightmap/splat_albedo.manifest.json:12-16,19-29,421-430` (before) | seed 20261113, dump sha `79f93c…`, 320×320, `texels_per_cell 1`, donor-block mapping retained. |
| E7 | `TERRAIN2_01_donor_pipeline.md:152-157,199-205,369-372` | Integer tile index + eye-plane UVs: this change is interim polish, not donor fidelity. |

## 2. Exact diff

### 2.1 `variant3d/scripts/world3d_terrain.gd` — ONE line added (line 104)

```diff
 func _terrain_material(splat: Texture2D) -> Material:
  	var mat := StandardMaterial3D.new()
  	if splat != null:
  		mat.albedo_texture = splat
+	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR  # V7-82: 4x splat texels stay smooth, no mip chain in tool PNG
  	# Splat A is normalised height DATA (G3-4), not opacity: never blend it.
```

No other line in this file changed; the V7-60 donor light/sky rig
(`_make_environment()`, `world3d_terrain.gd:210-243`) is untouched. Mipmaps were
**not** added: the tool writes a plain PNG, `splat_albedo.png.import:26` records
`mipmaps/generate=false`, and the runtime loads the file via `Image.load`
(`world3d_terrain.gd:90-97`), so there is no mip chain to select. LINEAR (filter
value 1) is explicit rather than relying on the material default.

### 2.2 `variant3d/tools/heightmap_splat.py` — no change

SHA-256 unchanged: `297aa8cee2d24b58867e0cc1469323b4831998cb8f5af68ab75e55d8c0e5b3e7`.
The backup is byte-identical to the shipped file.

### 2.3 Splat regeneration (tool invocation, from its own argparse)

```
python -X utf8 variant3d\tools\heightmap_splat.py \
  --dump app/shots/g32_dump.json \
  --presets app/assets/terrain/structs/presets_summer.json \
  --blocks-dir app/assets/terrain/blocks \
  --alpha height --blend-radius 1 --blend-height-eps 0.25 \
  --texels-per-cell 4 --water-block sandsea6 \
  --out variant3d/assets/terrain/heightmap/splat_albedo.png
```

`--out` was required because the tool's default output (`heightmap_splat.py:71`) is
the `app/` path. All other inputs stay at the values that produced the old
manifest, so provenance is preserved. `--blocks-dir` is the default `app/assets/terrain/blocks`;
all **224** files there are byte-identical to `variant3d/assets/terrain/blocks`
(measured SHA-256 over every filename), so the already-present variant3d donor
blocks are the same art. Manifest diff is exactly three fields:

```diff
-  "output_file": "app\\assets\\terrain\\heightmap\\splat_albedo.png",
+  "output_file": "variant3d\\assets\\terrain\\heightmap\\splat_albedo.png",
   "output_size": [
-    320,
-    320
+    1280,
+    1280
   ],
-  "texels_per_cell": 1,
+  "texels_per_cell": 4,
```

Verified preserved: `input_dump`, `input_dump_sha256` (`79f93c…`), `input_seed`
(20261113), `map_w/map_h` (320/320), `channels`, `alpha_mode`, blend parameters,
`water_block` (`sandsea6`), height min/max, and all **31** cell→block mapping rows
(including `grass1` 15,993 cells and `rock8` 2,283 cells). No new colour, block
name or mapping was invented.

## 3. Measured before/after

| Quantity | BEFORE | AFTER |
|---|---|---|
| `splat_albedo.png` dimensions | **320 × 320** RGBA | **1280 × 1280** RGBA |
| PNG byte size | **81,711 B** | **1,150,428 B** |
| SHA-256 (first 16) | `b4da4ebdedbddc6a` | `39aeeb28d4037ace` |
| manifest `texels_per_cell` | 1 | 4 |
| in-cell mean |RGB| deviation | 0.000 (one mean texel/cell) | **1.233 / 255** |
| mean `|dx|` between adjacent texels | 0.614 | **1.305** |

"Grain improved" is true at the **texture-data** level: within-cell variation is
no longer identically zero and high-frequency energy roughly doubles. It is a
small absolute change (4×4 LANCZOS samples are themselves near-uniform), so do
**not** expect donor-like mottling. Global mean RGB is essentially unchanged
(before `[48.75, 48.53, 21.89]`, after `[49.17, 48.36, 21.98]`), i.e. no colour
invention.

## 4. Windowed GPU A/B captures (V7-70 path, artefacts outside the repo)

Both captures used the genuine `Screenshot3DViewport` path (no headless CPU-map
fallback), via the variant3d runner only:

```
python -X utf8 variant3d\tools\godot_runner.py run --id <id> --timeout 420 -- \
  --path variant3d -- --screenshot <abs temp png> --screenshot-frames 10 --timeout 300
```

| Ticket | Job id | Path | stdout evidence |
|---|---|---|---|
| 213 | `v782-shot-windowed-before` | `C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v782_splat_before.png` (+ `.raw.png`) | `viewport=Screenshot3DViewport image=1280x720`, `camera_current=true`, `world_parent=Screenshot3DViewport`, `screenshot capture source: Screenshot3DViewport/1280x720`, `screenshot saved:`; exit 0, 42.25 s |
| 214 | `v782-shot-windowed-after` | `C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/v782_splat_after.png` (+ `.raw.png`) | same four diagnostics; exit 0, 40.53 s |

BEFORE was captured **before** the splat was regenerated and before the gd edit.

**Visual read (qualitative, parity NOT claimed):** both frames still read as
dark olive with long diagonal cell-banding; the AFTER frame does not show a
dramatic texture change. Two fixed terrain patches give mixed high-frequency
readings (top-left 1.204 → 1.269; top-right 1.298 → 1.025), and the camera
drifted slightly between runs (`camera_pos` `(272.18, 39.33, -222.88)` →
`(270.86, 39.33, -224.20)`), so the two frames are **not** a pixel-aligned A/B.
The only solid grain evidence is the splat-level measurement in §3 and the
MANIFEST/output-size change. No donor screenshot was compared; donor visual
parity remains UNVERIFIED.

## 5. Verification (variant3d runner only) — PASSED

| Ticket | Job id | Check | Result |
|---|---|---|---|
| **242** | **`v782-parse-terrain-nosep`** | `--headless --path variant3d --script res://scripts/world3d_terrain.gd --check-only` | **ok, exit 0, 3.12 s, stderr 0 B** (waited 330 s for the shared queue) |
| **243** | **`v782-selftest-r2`** | `--headless --path variant3d -- --self-test variant3d/selftest.json` | **ok, exit 0, 94.45 s, `variant3d/selftest.json` `passed=true`, 29/29 steps `passed=true`, 0 failed** |

Selftest stderr contains only the pre-existing `world3d_entities` donor-morph
warning and exit-time ObjectDB/resource leak warnings; no terrain error. The
selftest job rewrote `variant3d/selftest.json` (its mandated output), which is not
part of this ticket's owned edits.

Earlier attempts (`215/218/221/225/227/233/234/237`) hung or failed; root cause was
an extra `--` separator that put `--check-only`/`--script` into Godot's *user-arg*
tail (screenshot/selftest flags are read from user args by `main.gd`, so those jobs
worked), plus heavy shared-queue contention. Ticket 242 uses the same argv shape as
the historic passing parse (ticket 6) and is clean.

## 6. Open questions

1. The shared Godot queue was heavily contended by concurrent agents (several jobs
   waited 100–500 s; one WinGet-shim child survived a kill). The early parse
   failures were caused by passing an extra `--` that hid `--check-only` from Godot;
   the corrected invocation (ticket 242) parses clean with empty stderr. No parse
   diagnostic implicating the edited line was ever produced.
2. The camera position differs slightly between the two screenshot jobs, so the
   windowed pair is a qualitative, not pixel-aligned, A/B.
3. Four texels/cell keeps only ~1/256 of the 64 px/cell detail the 2D port uses
   (`world.gd:1040-1042`). A higher `N` or the P0 tile-index architecture would be
   needed for donor-like grain; both are out of this ticket's scope/ownership.
4. The runtime bypasses the stale `.import`/`.ctex` sidecar (`world3d_terrain.gd:87-97`);
   the sidecar still describes the old 320² image. No sidecar was edited (not in
   exclusive ownership). Regeneration via the Godot editor import would be a
   separate task.
5. Tile-index / eye-plane implementation (TERRAIN2-01 P0/P1) is explicitly
   delegated to the separate architecture agent; no attempt was made here.
