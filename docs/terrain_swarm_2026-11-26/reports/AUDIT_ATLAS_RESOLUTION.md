---
id: AUDIT-ATLAS-RES
ticket: "TERRAIN-SWARM-2026-11-26 / AUDIT-ATLAS-RES"
title: "Atlas resolution / mip audit — why exact 8x8 selection removed the grid but darkened and flattened the ground"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_GODOT_NO_GIT_NO_DONOR_EXEC
owner_file: docs/terrain_swarm_2026-11-26/reports/AUDIT_ATLAS_RESOLUTION.md
role: "SECONDARY read-only analysis, worker AUDIT-ATLAS-RES, reporting to COORD"
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, "PORT APPROXIMATION"]
parity_claim: false
scope_guard: "Donor READ ONLY: DDS headers read as bytes only; no donor binary executed, copied, committed or modified. No repo code/shader/config/asset/test/git/Godot change. Exactly one repo file written: this report. Temp analysis scripts only under C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\."
inputs_read:
  - "docs/terrain_swarm_2026-11-26/reports/DEC_VIS_01_uv_mapping.md"
  - "docs/terrain_swarm_2026-11-26/reports/D08_tile_select_bin.md"
  - "docs/terrain_swarm_2026-11-26/reports/X06_atlas_visual_audit.md"
  - "docs/terrain_swarm_2026-11-26/reports/COORD_terrain_root_cause.md"
  - "variant3d/assets/terrain_new/atlas/tile_index_atlas.manifest.json + tile_index_atlas.png (IHDR)"
  - "variant3d/scripts/tile_atlas_loader.gd; variant3d/scripts/terrain_donor_mesh.gd; variant3d/shaders/terrain_donor_shader.gdshader"
  - "C:\\Games\\Cossacks 3\\data\\terrain\\tiles\\textures\\*.dds headers (grass/test/rock/sand, read-only)"
  - "inbox/qa/captures/cap_donor_240l.png; %TEMP%\\opencode\\v42\\cap_donor_240k.png; %TEMP%\\opencode\\v42\\dumps\\v42_{64,240,320}_{a,b}.json"
---

# AUDIT-ATLAS-RES — packed-atlas resolution and mip loss

## 0. Executive summary

1. **[D] The 8×8 selector is now correct in *topology* but is applied inside a cell that is 8× too small.** Donor `grass1.dds` is **1024×1024 DXT1, 11 mips** (header bytes read), and the recovered `tsDouble` producer selects one **128×128** art subcell per 2 m cell (DEC-VIS-01 §4.2/§6.2). The current committed `terrain_new` atlas is **2048×1024**, 16×8 grid, **128×128 per cell** (manifest + IHDR). One selected subrect is therefore **16×16 px**, not 128×128: **8× fewer texels per axis, 64× fewer per subcell**. No code change is needed to see this; it follows from `textureSize(tile_atlas,0)/atlas_grid` in `terrain_donor_shader.gdshader:337`.

2. **[D] The mip/guard math compounds the loss.** The shader sets `packed_lod_offset = log2(1024/128) = 3` (`:350-351`) and `max_lod = floor(log2(128)) = 7` (`:362`). At guard LOD 4 the 16 px subcell is already ≤14 px; at 6 it is 8 px; at **7 the inset is 0.5 of the cell, `guarded_local` collapses to the cell centre and the gradient scale reaches zero (`:367-378`)** — i.e. **one constant texel per tile cell**. With a 1024² cell, LOD 7 still leaves a 112 px subcell. Full numbers in §3.

3. **[O] The capture pair proves the two symptoms are different mechanisms.** In clean ground ROIs, `240k` has mean luma **68.71** (bottom) / **68.74** (top), luma σ **3.39 / 2.66**, mean absolute gradient **2.99 / 1.98** and shows the 2 m olive lattice. `240l` has mean luma **55.07 / 55.07**, σ **0.0 / 0.0**, gradient **0.0 / 0.0** — a **single constant RGB (59,56,40)** over hundreds of thousands of pixels. The grid is gone because sampling no longer varies; the ground is not merely "less detailed", it carries **no texture information at all** in that ROI. ΔRGB (k−l) = **(+14.22, +19.74, −19.37)**.

4. **[D] Downsampling cannot explain the darkening.** NEAREST 1024→128 preserves the block mean to within **≤0.4/255 per channel** on every measured used block (test8: donor `(72.77,77.82,27.83)` vs cell `(73.01,77.89,27.92)`). All used tile means are green-dominant (`G>R>>B`); the `240l` flat fill is `R>G>B` with elevated blue. The darker/browner result is therefore a **separate colour/alpha/lighting or sampler-state effect**, not an arithmetic consequence of packing. The exact GPU cause of the constant fill (collapsed LOD, debug LOD left set, unbound sampler or background layer) is **[U]** — no runner job, uniform dump or GPU frame was produced by this worker.

5. **[O] The 240² generator is effectively a one-tile generator.** The canonical 240² dump uses **13 distinct byte values: 12 legal ids + water sentinel 255**. Id **79 `test8`** occupies **51,033 / 57,600 = 88.60 %** of cells; id 255 occupies 5,776 (10.03 %); the other ten legal ids together occupy 1,791 cells (3.11 %). Grass1 (id 0) is **not used at all** in these dumps. This is consistent with P01 §10's reported flattening to `test8`; it is a **generator/id-distribution issue**, separate from atlas resolution. Full histogram in §5.

6. **[D] Memory: the donor-faithful packed atlas already exists on disk.** `variant3d/assets/terrain/atlas/tile_index_atlas.png` is **16384×8192, 179,912,941 B (171.6 MiB)** — a 16×8 grid of 1024² cells. RGBA8 VRAM: **512 MiB base / 682.7 MiB with mips**. The current `terrain_new` atlas is **8 MiB / 10.7 MiB**. A partial Texture2DArray over the 14 legal ids seen in all canonical dumps is **56 MiB base / 74.7 MiB with mips** (≈9.3 MiB if DXT1 layers are supported). These are the realistic MX130 choices; §6 tabulates all options.

7. **[I]/[D] Smallest donor-faithful change:** bind (or regenerate at the same geometry) the **existing 16384×8192 atlas** and keep every uniform as-is. `textureSize()` makes `cell_px = 1024`, `donor_to_packed = 1`, `packed_lod_offset = 0`; the shader needs **no edit**. Exact asset/uniform list in §7. No synthetic detail, no upscaling beyond the already-labelled `sand1/2` NEAREST case, **no donor parity claim**.

---

## 1. Method and scope

- Secondary read-only worker; no donor target was opened and no Craft Anything tool was used on a donor binary. DDS files were opened as byte streams (128-byte headers) under `C:\Games\Cossacks 3\data\terrain\tiles\textures\`; nothing was executed, copied or written there.
- PNG dimensions were read from the 8-byte IHDR at offset 16 (independent of Pillow); image statistics used system Pillow **12.1.1** + NumPy **2.4.3** (the vendored `variant3d/tools/blender_py/PIL` is a source-only stub, as recorded in X06 §3).
- Temp scripts: `%TEMP%\opencode\audit_atlas_res.py`, `audit_used_ids.py`, `audit_hist_all.py` and their JSON outputs — all outside the repo.
- No Godot job, no `git` command, no repo source/shader/config/asset/test change. Only this file was written into the repo.
- Labels: **[O]** bytes/text observed; **[D]** computed from observed bytes; **[I]** interpretation; **[U]** not verifiable from read-only evidence. Every port-side substitute is a **PORT APPROXIMATION**.

### Evidence register

| ID | Label | Source | Observation |
|---|---|---|---|
| E1 | [O] | `variant3d/assets/terrain_new/atlas/tile_index_atlas.png` IHDR; manifest `atlas` | 2048×1024 RGBA8, 4,211,707 B; `cell_size=[128,128]`, `grid=[16,8]`, 124 named / 121 filled / 3 empty |
| E2 | [O] | legacy `variant3d/assets/terrain/atlas/tile_index_atlas.png` IHDR | 16384×8192, 179,912,941 B (171.6 MiB) |
| E3 | [O] | donor DDS headers, 63 named files inspected | All grass/test/rock/sandsea/sandrock are 1024×1024, DXT1, pitch 524288, **11 mips**, file 699,192 B; `sand1/sand2` are 256×256, 9 mips, 43,832 B |
| E4 | [D] | E1+E3+DEC-VIS-01 §4.2 | donor subcell 128 px vs packed subcell 16 px |
| E5 | [O] | `%TEMP%\opencode\v42\cap_donor_240k.png` and `cap_donor_240l.png` (both 1280×720 RGBA) | k = 577,168 B, l = 240,113 B; mean/σ/gradient in §4 |
| E6 | [O] | `%TEMP%\opencode\v42\dumps\v42_240_{a,b}.json` | 240×240, 57,600 cells; histogram in §5; `a` and `b` byte-identical histogram |
| E7 | [O] | `%TEMP%\opencode\v42\dumps\v42_{64,320}_{a,b}.json` | union of legal ids across all three sizes = 14 (adds 18 `rock2`, 24 `rock8`) |
| E8 | [O]/[D] | `variant3d/assets/terrain/blocks/*.png` vs new atlas cell crops | block means vs cell means agree ≤0.4/255; gradient energy drops 3.9×–4.4× at 128² |
| E9 | [O] | `terrain_donor_shader.gdshader:337-385` | `cell_px`, `donor_to_packed`, `packed_lod_offset`, `max_lod`, inset and `textureGrad` formulas |
| E10 | [O] | `tile_atlas_loader.gd:335-356`, `terrain_donor_mesh.gd:422-438` | CPU `generate_mipmaps(false)` attaches mips to base-level `ImageTexture`; level 0 unchanged |

---

## 2. Donor block vs packed cell — the resolution gap

| Quantity | Donor (`grass1.dds` et al.) | Current `terrain_new` atlas | Ratio |
|---|---:|---:|---:|
| Art block / cell | 1024×1024 | 128×128 | 8× linear |
| DDS / atlas mip levels | 11 | atlas has mips (CPU-generated); per-cell useful depth ≤8 | −3 levels |
| `tsDouble` subcells per block | 8×8 (Rows=Cols=8) | 8×8 applied inside the cell | same count |
| **Effective px per selected subcell** | **128×128** | **16×16** | **8× linear / 64× area** |
| DXT1 file bytes per block | 699,192 | — | — |
| Mean colour change from packing | — | ≤0.4/255 per channel | negligible |

Measured mean/colour-retention examples ([O]/[D], E8):

| id / name | donor block mean RGB | packed cell mean RGB | donor gradient¹ | cell gradient upscaled¹ | mean abs diff donor vs NEAREST-upscaled cell |
|---:|---|---|---:|---:|---:|
| 10 `ground1` | (99.53, 90.59, 66.13) | (99.90, 90.75, 66.42) | 20.11 | 5.08 | 18.50 |
| 17 `rock1` | (76.74, 67.38, 53.34) | (76.96, 67.54, 53.54) | 15.19 | 4.96 | 16.00 |
| 73 `test2` | (92.63, 86.71, 61.44) | (92.90, 86.85, 61.52) | 31.61 | 8.13 | 29.14 |
| 79 `test8` | (72.77, 77.82, 27.83) | (73.01, 77.89, 27.92) | 15.45 | 3.95 | 13.82 |
| 93 `sandsea1` | (128.24, 119.50, 85.46) | (128.49, 119.46, 85.73) | 13.51 | 3.57 | 13.24 |

¹ mean |∂luma/∂x|+|∂luma/∂y| on 1024² grids (cell upscaled NEAREST to 1024² for a like-for-like metric). **~4× of the authored gradient energy is lost** before any mip filtering. This is aliasing from throwing away 63 of every 64 source texels with NEAREST, not a new colour.

---

## 3. Mip and guard-inset quantification

Shader arithmetic (E9, `terrain_donor_shader.gdshader:337-383`):

```text
cell_px          = textureSize(tile_atlas,0) / atlas_grid   // (128,128) now
selector_step    = 1/8                                      // 8x8 subcells
donor_to_packed  = 1024 / cell_px.x = 8
packed_lod_offset= log2(8) = 3
max_lod          = floor(log2(min(cell_px))) = 7
raw_lod          = log2(donor_footprint_px) - 3
guard_lod        = clamp(ceil(raw_lod + DEBUG_MIP_BIAS), 0, 7)
inset            = 0.5 * 2^guard_lod / cell_px
guarded_local    = mix(inset, 1-inset, cell_local)
lod_scale        = (1 - 2*inset) * exp2(DEBUG_MIP_BIAS)
```

`inset` is in cell fractions; the usable span of the cell is `cell_px − 2·(0.5·2^g)` and the selected subcell span is that divided by 8:

| guard LOD | current cell 128: inset px | subcell px left | 1024 cell: inset px | subcell px left |
|---:|---:|---:|---:|---:|
| 0 | 0.5 | 15.9 | 0.5 | 127.9 |
| 3 | 4 | 15.0 | 4 | 127.0 |
| 4 | 8 | **14.0** | 8 | 126.0 |
| 5 | 16 | 12.0 | 16 | 124.0 |
| 6 | 32 | 8.0 | 32 | 120.0 |
| 7 | 64 | **0.0 — collapsed to one texel** | 64 | **112.0** |
| 8 | n/a (clamped) | — | 128 | 96.0 |
| 10 | n/a | — | 512 | 0 |

**[D] Consequence:** at the current cell size the guard erases the selected subcell entirely at its maximum legal LOD, and `lod_scale → 0` there makes `textureGrad` use the level-0 texel at the cell centre — a constant colour. With a 1024² cell the guard only starts to bite near LOD 9–10, by which point even the donor's own 128 px subcell has been filtered down. This is why a 16 m world selection period can be *correct* and the image still flat.

**[U] Capture-state caveat:** a perfectly constant ground (§4) is stronger than the guard alone predicts at plausible wide-view footprints (~0.1–0.5 cell/px ⇒ LOD ~0–4). Either a debug LOD was left set, or the sampler/material state differed in the `240l` run. No uniform dump for that capture exists on disk; this worker did not run Godot to resolve it.

---

## 4. Capture A/B — grid removed, colour and detail lost

Both images are 1280×720 RGBA8. ROIs avoid props: `ground_bottom` = x[40,620), y[545,705); `ground_top` = x[10,600), y[40,230). `k` = `cap_donor_240k.png`; `l` = `cap_donor_240l.png`.

| ROI | metric | 240k | 240l | Δ |
|---|---|---:|---:|---:|
| ground_bottom | mean RGB | (73.22, 75.74, 20.63) | **(59.00, 56.00, 40.00)** | (+14.22, +19.74, −19.37) |
| ground_bottom | mean luma | 68.71 | 55.07 | −13.63 |
| ground_bottom | luma σ | 3.39 | **0.00** | −3.39 |
| ground_bottom | mean abs gradient | 2.99 | **0.00** | −2.99 |
| ground_top | mean RGB | (73.23, 75.78, 20.72) | **(59.00, 56.00, 40.00)** | (+14.23, +19.78, −19.28) |
| ground_top | luma σ / gradient | 2.66 / 1.98 | **0.00 / 0.00** | — |
| full frame | mean luma | 68.42 | 55.84 | −12.58 |
| full frame | mean abs gradient | 4.20 | 1.87 | −2.33 |

**[O]** The constant fill is exactly `(59,56,40)` with zero variance in both ROIs — tens of thousands of identical pixels. **[D]** Its hue order (`R>G>B`, blue 40) does not match any used tile mean (all `G>R>>B`, blue 20–86) nor a NEAREST-downsampled mean (§2), so it is not "the atlas at a coarse mip". **[U]** Which of {LOD collapse, debug override, unbound `tile_atlas`, background/base layer} produced that constant is not recoverable from the PNGs alone.

**Interpretation [I]:** the lattice disappeared because per-fragment UV variation disappeared, not because the donor's 8×8 art matrix was reproduced. Restoring subcell detail and restoring correct mean colour are two separate checks.

---

## 5. Tile-id inventory of the current 240² generator

Source: `v42_240_a.json` / `v42_240_b.json` (`tileblock` array, 240×240 = 57,600 cells). Names from the `terrain_new` manifest / `presets_summer.json`.

| id | name | cells | share | donor DDS |
|---:|---|---:|---:|---|
| 79 | `test8` | 51,033 | **88.60 %** | 1024² DXT1, 11 mips |
| 255 | water sentinel (PORT, `game.gd:52`) | 5,776 | 10.03 % | n/a |
| 10 | `ground1` | 192 | 0.33 % | 1024² DXT1, 11 mips |
| 98 | `sandsea6` | 229 | 0.40 % | 1024² |
| 97 | `sandsea5` | 132 | 0.23 % | 1024² |
| 93 | `sandsea1` | 91 | 0.16 % | 1024² |
| 74 | `test3` | 16 | 0.03 % | 1024² |
| 73 | `test2` | 120 | 0.21 % | 1024² |
| 23 | `rock7` | 4 | 0.007 % | 1024² |
| 20 | `rock4` | 3 | 0.005 % | 1024² |
| 17 | `rock1` | 2 | 0.003 % | 1024² |
| 19 | `rock3` | 1 | 0.002 % | 1024² |
| 22 | `rock6` | 1 | 0.002 % | 1024² |

- **12 legal ids + sentinel**; `a` and `b` histograms are identical. No grass ids 0–9, no face ids 35–70, no sandrock 87–92, no desert 111–122.
- Across the three canonical sizes (64²/240²/320², six dumps, E7) the union is **14 legal ids** — the above 12 plus `18 rock2` and `24 rock8`.
- **[I] Visual consequence:** since 88.6 % of cells resolve to one packed cell (`test8`), the new 8×8 selector walks 64 subrects of *that one* 16 px-grid cell. Whatever its mean and hue become after shading/alpha is what the whole ground looks like. This is why an atlas-resolution fix must be paired with a histogram/generator fix before judging donor likeness — but the two owners are different, and this worker changed neither.
- **[U]** These dumps are timestamped 11:39–11:44, earlier than the 13:19 `240l` capture; COORD-supplied fix state may have changed the generator since. No new dump was requested or produced here.

---

## 6. Options compared

VRAM arithmetic assumes RGBA8 unless noted, full mip chain = ×4/3, 1 MiB = 1,048,576 B. MX130 is a 2 GB-class DDR3 mobile dGPU (vendor class **[I]**, not benchmarked here); bandwidth, not shader ALU, is the binding constraint for a large sampled atlas.

| Option | VRAM base / with mips | Disk asset | Donor fidelity | Code / uniform change | MX130 assessment |
|---|---:|---:|---|---|---|
| **A. Current 2048×1024 packed atlas** | 8 / 10.7 MiB | 4.0 MiB PNG | 16 px subcell; guard collapses at LOD 7 — **not donor-faithful** | none | Cheapest, but cannot carry 128 px subcell art; flattened output |
| **B. Full packed atlas 16384×8192 (16×8 × 1024²)** | **512 / 682.7 MiB** | **171.6 MiB PNG** (already on disk) | cell=1024 ⇒ 128 px subcell, `donor_to_packed=1`, LOD offset 0; art byte-identical for 1024² sources | asset/path only; **no shader/uniform edit** (`textureSize` adapts) | Legal in 16384-per-dimension class; 682 MiB fits 2 GB but 171.6 MiB PNG exceeds GitHub's 100 MB file limit → LFS/split parts; one-time CPU mip build (~1 s-class, [I]) |
| **C. Texture2DArray, all 121 filled cells @1024²** | 484 / 645.3 MiB (RGBA8); **~80.7 MiB if DXT1 layers work** | 112 donor-derived PNGs (166.1 MiB on disk, measured) | Each layer is a whole 1024² block ⇒ 128 px subcell, **no cross-cell bleed, no guard inset** | shader change: `sampler2DArray` + `tile_layer(index)` uniform map; mesh must bind `Texture2DArray` | Uncompressed nearly as costly as B; compressed is attractive, but Godot-side DXT1 `Texture2DArray` support is **[U]** — must be verified on target |
| **D. Partial array over used ids only (14 legal; 12 at 240²)** | 56 / 74.7 MiB (14 layers); ~9.3 MiB DXT1 | same 14 PNGs | Full 128 px subcell for every *currently emitted* id; **not** a general donor map (face/desert ids absent) | same shader change as C plus an id→layer map and an explicit guard/fallback for unmapped ids (labelled PORT APPROX) | **Best VRAM/bandwidth tradeoff** on MX130; safe only with a hard "unmapped id" assertion, not silent art fabrication |
| **E. Per-tile separate sampler bindings** | 448 / 597.3 MiB for 112 layers (48 / 64 MiB for 12) | 112 PNGs | Full art | needs material variants or bindless indexing; Godot dynamic sampler indexing is not portable | Rejected: draw-call/material explosion and uniform pressure on low-end hardware |

**Not recommended:** regenerating a 4096×2048 "middle" atlas (cell 256², subcell 32 px) — it only halves the deficit while keeping the 100 MB limit and the guard problem. No synthetic detail, noise or upscaling was considered (charter guardrail).

---

## 7. Recommendation — smallest donor-faithful change

**Adopt option B with the already-on-disk legacy atlas; no shader edit.**

1. **Asset:** `variant3d/assets/terrain/atlas/tile_index_atlas.png` (16384×8192, 179,912,941 B, E2). Either point the new terrain module at it via the existing `single_atlas_path` override in `TileAtlasLoader` (`tile_atlas_loader.gd:76,114-115`; `terrain_donor_mesh.gd:_atlas_paths()` at `:403-419`), or regenerate `variant3d/assets/terrain_new/atlas/tile_index_atlas.png` with the same 16×8 × 1024² geometry from the existing 112 block PNGs. If regenerating, update the manifest: `atlas.size=[16384,8192]`, `atlas.cell_size=[1024,1024]`, drop `APPROX_ATLAS_DOWNSAMPLE` from 1024² sources, keep `APPROX_SAND_UPSCALE` for `sand1/sand2` (256² donor, NEAREST — no invented colour), keep `APPROX_ATLAS_PACKING` and `NO_VISUAL_PARITY_CLAIM`.
2. **Uniforms (exact, unchanged values):** `tile_atlas` = that texture **with CPU mips** (`tile_atlas_loader.gd:350-356` already calls `generate_mipmaps(false)`; level 0 stays byte-identical); `atlas_grid=vec2(16,8)`; `donor_rows=8.0`; `donor_cols=8.0`; `donor_tile_size=64.0`; `donor_rgb_block_size=1024.0`; `map_cells=vec2(w,h)` (240,240 for the canonical run); `tile_map` = existing nearest L8 tile map; masks unchanged. `uv_repeat`, `mask_uv_source`, `DEBUG_*` remain at their current defaults — **do not leave `DEBUG_FORCE_LOD`/`DEBUG_MIP_BIAS` enabled for the verification capture**.
3. **Why no shader change:** `cell_px = textureSize/grid` becomes 1024, `donor_to_packed = 1024/1024 = 1`, `packed_lod_offset = 0`, `max_lod = 10`. The 8×8 subrect is now 128 px wide and the guard only reaches the collapse point at LOD 10.
4. **Verification owned by COORD (not this worker):** one pinned 240² capture with the exact file; assert `ground_bottom` luma σ > 0 and gradient > 0 (compare with the zero-valued `240l` numbers in §4), and re-check the mean against the used-tile means in §2 before calling the darkening resolved. A second check must confirm the 2 m checkerboard did not return *as a 16 m macro period*: donor selection is 8 cells × 2 m = 16 m, so some regularity is expected and must not be mistaken for the old 2 m lattice.
5. **Do not conflate owners:** the 88.6 % `test8` concentration (§5) is a generator/id-distribution finding (P01 §10 Y08 collapse), not an atlas defect. Full-resolution art will make that one tile sharper; it will not by itself create donor tile variety.
6. **Follow-up if VRAM/disk is binding:** implement option D (14-layer partial `Texture2DArray`) behind an explicit id→layer map and a hard unmapped-id assertion; verify DXT1 array support on the MX130 target before counting the compressed saving. Do **not** fabricate art for unmapped ids.

**No donor parity is claimed.** All magnitudes above are byte/image measurements or arithmetic over recovered donor constants and port files; no donor GPU A/B frame was produced or read.

---

## 8. UNVERIFIED register

| ID | Item | Status |
|---|---|---|
| AR-U1 | Which runtime state made `240l`'s ground exactly constant (LOD collapse, debug uniform, sampler binding, or background layer) | **[U]** no uniform dump / runner job for that capture |
| AR-U2 | Whether `variant3d/assets/terrain/atlas/tile_index_atlas.png` is git-tracked or LFS | **[U]** no git inspection by this worker (charter scope) |
| AR-U3 | Godot support for DXT1 layers in `Texture2DArray` on the target build | **[U]** compressed estimates are conditional |
| AR-U4 | Whether the 11:39–11:44 dumps still describe the 13:19 generator configuration | **[U]** no fresh dump taken |
| AR-U5 | Effective per-frame eye planes / texture matrix and alpha composite pass count | **[U]** unchanged from D08 §7 and DEC-VIS-01 §12; not re-derived here |
| AR-U6 | Visual parity with any donor frame | **[U]** no donor A/B exists; no parity claim |

---

## 9. Bottom line

The recovered 8×8 selector fixed the **wrong-period** grid, but it was applied to a **128² packed cell**, yielding **16 px** per authored subcell instead of the donor's **128 px**, with a guard inset that collapses to a single cell-centre texel at LOD 7. That is a sufficient, quantified explanation for the loss of detail. The simultaneous **darkening** is *not* explained by downsampling — NEAREST packing preserves each block's mean to <0.4/255 — and the measured flat fill `(59,56,40)` has a different hue order from every used tile, so a separate colour/alpha/sampler cause remains **[U]**. The smallest donor-faithful correction is to bind the existing 16384×8192 (1024²-cell) atlas with CPU mips and unchanged uniforms; the shader auto-adapts. A 14-layer partial `Texture2DArray` is the memory-optimal fallback. **No synthetic detail, no upscaling beyond the labelled sand case, no parity claim.**

*End of AUDIT-ATLAS-RES. Exactly one repo file written. Donor read-only; no binary executed/copied; no code, shader, config, asset, test, result-JSON, git or Godot state changed.*
