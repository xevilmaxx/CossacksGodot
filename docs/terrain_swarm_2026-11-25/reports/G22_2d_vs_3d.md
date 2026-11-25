---
id: G22
ticket: "WAVE G follow-up — G22: does the 2D shipping renderer look closer to the donor samples than the 3D variant?"
wave: WAVE G follow-up
owner: G22 (read-only)
created: 2026-11-25
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_RUNNER_JOB__NO_CODE_OR_ASSET_EDIT
charter: docs/terrain_swarm_2026-11-25/CHARTER.md
board: docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
scope: "This report is the ONLY repo file written. No Godot process, no runner job, no source/asset/config/test/shader/JSON edit, no git write. Images were read with Pillow; two diagnostic zoom crops were written only to C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/g22/."
labels: [observed, derived, inferred, UNVERIFIED, PORT APPROX]
parity_guard: "DONOR PARITY STAYS UNVERIFIED (CHARTER §3, §5). No donor GPU A/B frame exists. Every similarity below is labelled INFERRED (visual reading) or UNVERIFIED; no parity, equivalence or 'closer by N%' claim is made."
sources_read:
  - docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
  - docs/terrain_swarm_2026-11-25/CHARTER.md
  - docs/terrain_swarm_2026-11-25/reports/G11_2d_monitor.md
  - docs/terrain_swarm_2026-11-25/reports/G04_gate_log.md
  - docs/terrain_swarm_2026-11-25/reports/C01_metric_tool.md
  - docs/terrain_swarm_2026-11-25/reports/A11_reference_metrics.md
  - docs/terrain_swarm_2026-11-25/reports/G07_relief_plan.md
  - docs/terrain_swarm_2026-11-25/reports/G18_donor_bugs.md
  - app/scripts/game.gd, app/scripts/world.gd
  - variant3d/scripts/game.gd, variant3d/scripts/world3d_terrain.gd, variant3d/shaders/terrain_tileindex.gdshader
  - app/assets/terrain/structs/*.json, variant3d/assets/terrain/atlas/tile_index_atlas.manifest.json
---

# G22 — 2D shipping renderer vs 3D variant: terrain look

## 0. Verdict, with labels

**INFERRED (visual, not a parity claim):** on the images that exist, the **2D shipping renderer in `app/` looks structurally closer to the donor stills than the 3D variant's available terrain capture.** The reason is *structure*, not a better palette: the 2D frames contain relief walls with grey rock faces, tree cover, patch boundaries and multi-block ground mosaics, whereas the 3D P0 frame is a flat, uniform olive field with fine grain. This is a visual reading of different scenes at different cameras — **UNVERIFIED** as donor parity and **UNVERIFIED** as a general statement about every zoom level.

**DERIVED (from Pillow numbers, §4):** the gap is **mixed**, not a clean "2D wins".
- At the composited grass-layer scale, 2D has *more* large-scale mottling than the donor ROI (BV32-normalised 669.2 vs 219.4 — about 3x), while the 3D P0 frame has ~25x *less* (8.6).
- At far game zoom, some 2D grass ROIs are essentially **as flat as the 3D frame** (BV32-normalised 4.7 vs 8.6 vs donor 219.4). So "the 2D ground is always organic" is **NOT supported**.

**UNVERIFIED:** no donor GPU A/B exists; all 12 donor files are third-party JPEG/WEBP screenshots; the only representative 3D terrain-only capture (`p0_final_formula.png`, 11:41) predates the Wave B shader/atlas fixes, and G04's fresh capture never ran (`G04_gate_log.md:25-58`). Any statement about the *current* 3D tree's appearance is therefore **UNVERIFIED**. No test was weakened, no runner job was submitted, no code or asset was edited.

---

## 1. Method and scope

- Read `WAVE_G_CHARTER.md` and `CHARTER.md` first; honoured "only G04 submits runner jobs", disjoint ownership, labels, no synthetic noise/dither, no donor-parity claim.
- Opened existing PNG/JPG files with **Pillow 12.1.1 / numpy 2.4.3** via inline `python -` (no script file in the repo). Metric definitions follow `A11_reference_metrics.md` §1 and `C01_metric_tool.md` §2: Rec.709 luma `Y`, HSV-style `S=(max-min)/max`, block variance `BV_B` of `B×B` block-mean luma, a 640-px LANCZOS normalisation (`*n640`) and mean absolute first derivative (`grad n640`). All numbers in §4 are **OBSERVED**; ratios are **DERIVED**.
- No Godot process, no `godot_runner.py` invocation, no status mutation. Two diagnostic enlargements were written to the pre-approved temp folder only (`...\Temp\opencode\g22\g22_w55_grass_zoom.png`, `g22_highland_grass_zoom.png`, `g22_combo_grass_layer.png`).
- **UNVERIFIED:** nothing here proves what the donor engine actually renders; image similarity is a human reading plus descriptive statistics.

---

## 2. Files opened (OBSERVED)

| Role | Path | Size / mode | Note |
|---|---|---|---|
| 2D combo A | `app/shots/t6t90/t6t90_combo_grass_trees.png` | 2086x1120 RGB | Caption: "PORT RENDER (deterministic) ... layers ... Pillow, noGodot" left; "DONOR REFERENCE CROP" right |
| 2D combo B | `app/shots/t6t90/t6t90_combo_ravine_grass.png` | 2086x1120 RGB | port winding gully / grass plateau / rock vs donor ravine crops |
| 2D combo C | `app/shots/t6t90/t6t90_combo_shore_water.png` | 2086x1120 RGB | shore band and water |
| 2D full map | `app/shots/map_variants/variant_B_highland.png` | 864x864 RGB | top-down shipping map view |
| 2D game view | `app/shots/w55_zoom_out.png`, `w55_startup.png` | 1280x720 RGBA | in-game UI + terrain + cliffs |
| 2D source art | `app/shots/orig/tile_grass1.png`, `app/shots/tiles/grass1.png`, `app/assets/terrain/blocks/*.png` | 256–1024 px | donor block PNGs |
| Reference A | `C:\Users\Maxym.Oboyshev\Downloads\c3\cossacks-3-v1-498085.jpg` | 1280x720 RGB | charter's "reference sample A" |
| Reference B | `...\c3\articolo-787.jpg` | 960x540 RGB | charter's "reference sample B" |
| 3D primary | `...\Temp\opencode\p0fresh01\p0_final_formula.png` | 1280x720 RGBA | the capture used in CHARTER §1 and A11 §2; **pre-B-fix** |
| 3D diagnostics | `...\Temp\opencode\maskalpha01\maskalpha_after.png`, `...\reliefvisual\relief_on_fixed.png` | 1280x720 RGBA | later debug captures with heavy black/striped relief artifacts; **not** shipping representatives |

---

## 3. Visual comparison (OBSERVED image content; similarity readings labelled)

1. **2D combo A** places its port layers directly beside donor crops. The port "T01 grass" cell shows large, soft pale/dark mottling with no grid; the donor right-hand cells show the same class of organic patchiness. **INFERRED:** the 2D ground layer has the *same kind* of multi-scale patch structure the donor stills show. **UNVERIFIED:** source identity or parity — the port cell is a composited deterministic render, not a donor frame.
2. **2D combo B** has an explicit winding gully and a grass/rock transition; the donor reference cells show grey ravine walls with rock striation. **INFERRED:** the 2D renderer has a *structural analogue* of donor cliffs that the 3D P0 frame entirely lacks. **UNVERIFIED:** the shapes are not the same place, seed or camera.
3. **`w55_zoom_out.png`** shows a grey ravine with layered rock flutes, fine grass rim, scattered trees and mottled green ground, plus HUD/minimap. **INFERRED:** at scene level this is much closer to reference A's *composition* (rolling ground + cliff + trees) than the 3D P0 frame. **UNVERIFIED:** the reference has unit formations and different art assets.
4. **Far grass in `w55_zoom_out`** (enlarged ROI, temp crop) is a fairly uniform dark-green field with faint blocky rectangular patches. **OBSERVED:** some of those rectangles read as per-cell block boundaries — a mild checker/quilt effect, not donor parity. **INFERRED:** do **not** copy this part of the 2D look; the charter's S-25-09 guard rejects synthetic noise/dither precisely because it recreates a checkerboard regression (`G18_donor_bugs.md:74`, `:310`).
5. **3D P0** is a flat olive field with fine grain, faint banding and no visible relief, cliffs, trees or large patches. **OBSERVED.** **INFERRED:** this is the opposite of the donor's multi-scale structure and is the frame the owner complained about.
6. **3D diagnostic frames** (`maskalpha_after`, `relief_on_fixed`) show repeated black/striped rings around relief and buildings while the flat field stays olive. **OBSERVED.** **UNVERIFIED:** these are debug captures; they are cited only as additional evidence of artificial repetition, not as the current shipping 3D frame.

---

## 4. Quantitative comparison (Pillow; OBSERVED numbers, DERIVED ratios)

All rows use the A11 metric definitions on **ground-only ROIs chosen by visual judgement**. ROI coordinates are fractional `(x0,y0,x1,y1)` of each image, or absolute pixels. BV values are variances of 32×32 block-mean luma; `BV32n` is the same after resampling the ROI to 640 px width; `grad` is mean |dY| at 640 px.

| Image | ROI | px | Y mean | Y sd | S mean | BV8/16/32/64 | BV32n | grad | lag-1 autocorr |
|---|---|---:|---:|---:|---:|---|---:|---:|---:|
| **Ref A** `cossacks-3-v1-498085.jpg` | .35,.55,.48,.70 (A11) | 166x108 | 87.19 | 19.65 | 0.540 | 219.5/164.3/144.1/93.3 | 219.4 | 2.11 | 0.982 |
| **Ref B** `articolo-787.jpg` | .30,.27,.42,.39 (A11) | 115x65 | 85.57 | 21.55 | 0.517 | 225.8/96.2/9.1/n/a | 263.6 | 1.39 | 0.993 |
| **3D P0** `p0_final_formula.png` | .02,.02,.98,.98 (A11) | 1228x692 | 91.42 | 10.56 | 0.675 | 15.3/12.5/9.9/7.2 | 8.6 | 5.01 | 0.490 |
| **2D** combo grass layer (`combo_grass_trees` top-left cell) | abs (12,54)-(528,564) | 516x510 | 74.35 | 31.50 | 0.522 | 888.6/785.9/621.6/292.0 | 669.2 | 2.46 | 0.993 |
| **2D** `w55_zoom_out` far grass | abs (850,150)-(1250,550) | 400x400 | 68.00 | 4.78 | 0.779 | 8.0/5.4/3.3/1.3 | 4.7 | 2.04 | 0.836 |
| **2D** `w55_startup` same ROI | abs (850,150)-(1250,550) | 400x400 | 67.72 | 4.74 | 0.783 | 10.9/7.9/5.3/2.9 | 7.2 | 1.37 | 0.926 |
| **2D** `variant_B_highland` grass+trees ROI | abs (430,300)-(520,390) | 90x90 | 66.00 | 14.11 | 0.765 | 106.7/97.3/137.0/n/a | 144.5 | 0.81 | 0.997 |
| 2D `app/shots/orig/tile_grass1.png` | whole file | 320x320 | 77.33 | 4.60 | 0.632 | 8.6/6.9/5.5/4.2 | 6.9 | 1.62 | 0.890 |
| 2D `app/shots/tiles/grass1.png` | whole file | 256x256 | 77.33 | 4.27 | 0.631 | 8.1/6.3/5.0/3.3 | 6.9 | 1.16 | 0.933 |

**DERIVED readings (directional only, no threshold, no parity):**
- Large-scale mottling (`BV32n`) vs Ref A: 3D P0 **8.6 = 0.04x** donor; 2D combo grass **669.2 = 3.05x** donor; 2D highland ROI **144.5 = 0.66x** donor; 2D far grass **4.7 = 0.02x** donor. **INFERRED:** the 2D *composited* layers and mixed-scene ROIs sit in the donor's structural band; the 3D frame and the 2D far-grass patch do not. The 2D combo layer overshoots, so "more variance is better" is false — the target is *coherent* patches, not raw variance.
- Fine-grain balance (`grad`): Ref A 2.11, 3D P0 **5.01 (2.4x donor)**, 2D combo grass 2.46, 2D far grass 2.04. **INFERRED:** the 3D frame concentrates energy in fine grain, matching A11 §5 item 2's "grain without structure" signature; the 2D samples are closer to the donor's balance.
- Colour: Ref A `S=0.540`, 3D P0 `0.675` (hard yellow-olive), 2D combo grass `0.522`. **INFERRED:** the 2D composited ground has a donor-like saturation range; the 2D far grass (`S=0.779`) does not, so this is scene-dependent.
- **UNVERIFIED:** every comparison above is confounded by scene, camera, zoom, season and JPEG compression. A11 §6 already shows one uniform donor grass ROI scoring only 1.1x the 3D P0 frame's block variance, so the gap is not universal.

---

## 5. What the 2D renderer actually does — exact reusable assets and techniques

All paths below are **OBSERVED** source/data. Attribution to donor behaviour is as stated in the code comments; whether those comments are donor-correct is **UNVERIFIED** (no donor access this ticket).

### 5.1 Tileblock smoothing and detail assignment (data, not art)
- `app/scripts/game.gd:1610-1698` `_assign_tileblocks()`: default every land cell to `grass1` (donor `SetTileIndex(x,y,0)`); road `ground1`/`test2`/`test3`; sand/rock choices; then (a) `_apply_shore_cliffs()` using the 8-sector height-gradient tables (`:1708-1785`), (b) `_smooth_tilemap(brng,3)` (`:1682`, implementation `:1869-1876`), (c) `_apply_detail_pass()` (`:1689`), (d) `_stamp_forest_borders()` (`:1692`).
- `_tb_smooth_pair()` `game.gd:1806-1867` is a 3-pass compatible-chain smoother driven by `app/assets/terrain/structs/smooth_summer.json` — **OBSERVED:** 10 chains, e.g. chain 0 `sandsea1..4`, chain 3 `rock9/rock8/rock5` (prob 0) and `rock1/2/3/6/7/4`; `_tb_pick()` samples `prob` weights (`:1787-1804`).
- `_apply_detail_pass()` `game.gd:1581-1605`: for cells still on `grass1`, read `tile_lowground.png` if `height < 0.1` else `tile_highground.png`, take `tex = R*255/2` from the map-sampled bitmap, and reassign the cell. **OBSERVED:** this is the source of "real meadow mottling" per the code comment, i.e. a *donor-data* variation pass, not synthetic noise.
- `app/assets/terrain/structs/tileblocks.json` (245 named block records) and `presets_summer.json` (124 names) are the index dictionary.

### 5.2 Donor block PNGs and per-cell compositing
- `app/assets/terrain/blocks/`: **112** donor block PNGs, 1024² each. **OBSERVED:** `variant3d/assets/terrain/blocks/` contains the same files byte-identically (e.g. `grass1.png` SHA256 prefix `28e617b1f722`, `grass_ground1.png` `93a5ad238d5c` in both trees). **No new donor asset is needed by 3D.**
- Measured block variance (OBSERVED): `grass1.png` Y sd 9.2 / BV32 8.1; `grass_ground1.png` and `grass_ground3.png` Y sd 20.9 / BV32 58.2; median of all 112 blocks BV32 ≈ 22.2. **DERIVED:** the artistic variation lives in the *transition* blocks; a tile field dominated by `grass1` will look flat even though the atlas is rich.
- `app/scripts/world.gd:1012-1034` `_block_img()`: load `blocks/<name>.png`, mirror-assemble to 1024² seamless (`:817-836` — right half flip-X, bottom flip-Y, corner both), then `adjust_bcs(1.0, 1.12, 1.0)` **once per block** (comment: doing it per cell would reintroduce tile borders).
- `world.gd:1211-1253` `_composite_blocks()`: rank the distinct donor block names in a chunk, build one coverage grid per name with **exact per-cell** coverage, then `_alpha_mask()` (`:1084-1093`) writes coverage into the mask **alpha** channel and upscales **bilinearly** — the cross-fade across name borders is the only anti-aliasing — and `blend_rect_mask()` composites one cache-cropped donor block per name (`:838-854` `_wrap_crop`).
- `world.gd:1543-1632` `_build_chunk()`: base = chunk's dominant donor block; per-role passes use one continuous donor crop feathered by a 2×2-sampled smooth region mask; shore uses gamma falloff 1.7 / ceiling 0.55 so `sandsea*` stays a textured narrow band, not a flat tan ring; then `_face_collar()`, season tint and relief shading.

### 5.3 Relief face collar and decals
- `world.gd:1400-1532` `_face_collar()`: computes a height-gradient magnitude grid (bilinear-sampled at sub-tile resolution), early-outs on flat chunks, fills steep faces with a per-segment-offset crop of `rock8.png`, overlays a lit/shadow ramp derived from a fixed sun direction, blends vertically stretched `rock1.png` flutes masked to the face interior, and adds a ≤3 px fine grass rim from `grass1.png`. **INFERRED:** this is the main reason `w55_zoom_out.png` cliffs read like the donor's grey rock walls. **UNVERIFIED:** not a donor GPU comparison.
- `world.gd:731-739` `_bld_decal()` loads `app/assets/terrain/decals_png/<nation><sid>d.png` (924 PNGs in both trees) as building ground plates; `world.gd:2527-2540` `_field_decal()` uses `deco_png/envfieldd.png`/`envfielddw.png` for ripe fields; `deco_png/` also holds `christmastreed.png`, `groundexp0..3.png`. `app/assets/terrain/dmask/d_00..47.png` supplies mask shapes. **INFERRED:** decals add the small-scale scene detail visible in donor stills; the 3D P0 terrain-only frame has none of it.

### 5.4 The 3D side already has the same data
- `variant3d/shaders/terrain_tileindex.gdshader:14-24`: **one** per-cell integer tile index selects a cell of a donor-block atlas; world X/Z texgen at 2 m/cell; alpha/alphavert masks. The 3D mesh path is `variant3d/scripts/world3d_terrain.gd` — one indexed ArrayMesh, `UV2.x = tile index`, `UV2.y = face mode`, atlas 16×8 / 1024² cells (`tile_index_atlas.manifest.json`). Mesh invariants are explicitly protected (`world3d_terrain.gd:94-95`).
- `variant3d/scripts/game.gd:2033-2070` already contains the same smoothing/detail/border functions. **OBSERVED difference:** 3D applies `_apply_detail_pass(brng)` **before** `_smooth_tilemap(brng,3)` (`:2039`, `:2067`) and adds B03's `tiles`-pattern `ground1` stamps (`:2051-2063`); 2D applies smoothing **before** the detail pass (`app/scripts/game.gd:1682` vs `:1689`). Both cite donor evidence; which order is donor-correct is **UNVERIFIED**.
- `variant3d/scripts/world.gd` contains the same `_composite_blocks`, `_face_collar`, `_bld_decal` functions as `app/scripts/world.gd` (grep hits at `:1218`, `:1400`, `:731`), but the 3D terrain render path described above is the tile-index shader. **UNVERIFIED:** whether these 2D-style functions execute for the 3D terrain frame — no capture or runtime trace was produced by this ticket.

---

## 6. Reuse options for 3D — proposals only, no edits made

Every option keeps the primary one-index-per-cell contract (`UV2.x` + the 16×8 atlas) and the protected mesh invariants. All are **INFERRED** feasibility readings and **UNVERIFIED** visually and for performance; none was implemented or run.

1. **Data-only pass-order / detail-bitmap A/B (lowest architectural risk).** Change only which tile ids `variant3d/scripts/game.gd` writes, so that high-variance donor transition blocks (`grass_ground1/3`, `grass5`, etc.) are assigned rather than a `grass1`-dominated field. This needs **no shader, atlas, mesh or sampler change** — tile-index architecture is untouched. **OBSERVED** support: the shipped tile histogram includes `grass_ground1` at 28,535 cells and `grass_ground3` at 15,962, yet the P0 frame measures BV32n 8.6. **UNVERIFIED:** that the current tree still shows this after B01/B02. A/B must be run by G04/COORD only.
2. **Per-cell cross-fade of adjacent atlas cells (medium risk).** Reuse the 2D `_alpha_mask` idea: carry a small second per-cell datum (a blend index + weight) alongside the primary index, or a separate low-res mask texture, and let the shader cross-fade the selected cell with its neighbour over one cell border. This **extends** the tile-index architecture rather than replacing it; one atlas cell per 2 m and `UV2.x` stay authoritative. **INFERRED** from `world.gd:1211-1253`; **UNVERIFIED** whether the extra attribute/texture fits the mesh/perf contract or avoids visible seams.
3. **Overlay relief-face collar and decals (lowest visual risk, zero tile-index change).** Draw `rock8`/`rock1` face fills, lit/shadow ramp and fine grass rim as a separate textured overlay driven by the same `height[]` gradient, and reuse the existing `decals_png`/`deco_png` art as separate sprites/meshes. The primary index, atlas and UV2 pair are untouched. **INFERRED** as the most direct transfer of what makes `w55_zoom_out.png` look donor-like; **UNVERIFIED** for z-fighting, seams and gate impact.
4. **Do NOT plan an asset copy.** The donor blocks, decals, masks and atlas cells are already byte-identical in both trees (§5.2/5.4). The deficit is selection/composition/relief, not missing art. Adding donor bytes or a synthetic noise field is out of scope and contradicts `CHARTER.md:60` and `G18_donor_bugs.md:74,310`.

**Guardrails for any follow-up owner:** no threshold/assertion weakening; no synthetic dither/noise (S-25-09); label every substitute PORT APPROX; back up before edits (`inbox/backup/<file>.bak-<TICKET>`); respect disjoint ownership; only G04 submits runner jobs; `app/` remains untouched; donor parity stays UNVERIFIED.

---

## 7. Limitations (UNVERIFIED / explicit)

- The 3D representative is the **pre-fix** 11:41 `p0_final_formula.png`. No fresh 3D frame exists because G04 was blocked on stale ticket 582 (`G04_gate_log.md:25-58`). Current-tree 3D appearance is **UNVERIFIED**.
- Reference stills are third-party JPEG/WEBP with unknown build, camera, season and downsampling; no donor GPU A/B frame exists. All similarity labels are INFERRED/UNVERIFIED; **no donor-parity claim is made anywhere in this report**.
- ROI choices are visual judgements; a different crop can reverse the 2D-vs-3D ordering at the far-grass scale (§4). Reference B's native BV32 is only 9.1 because that ROI is a near-uniform grass patch — consistent with A11 §6's warning.
- The 2D combo sheets are diagnostic layer comparisons authored by another agent ("Pillow, noGodot"), not a pure game frame; `w55_*` and `variant_*` are the shipping-renderer evidence.
- I did not open donor files, run Godot, submit a runner job, edit code/assets, or touch `app/`. The only repo file written is this report.

---

## 8. Reproduction (read-only)

Tool form used for the headline 3D-vs-reference check (`C01_metric_tool.md` §3):

```powershell
python variant3d\tools\terrain_ab_metric.py "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\p0fresh01\p0_final_formula.png" "C:\Users\Maxym.Oboyshev\Downloads\c3\cossacks-3-v1-498085.jpg" --crop-frac .02,.02,.98,.98 --json
```

The §4 table was produced with an inline Python snippet (Pillow + numpy) that crops each ROI, computes `Y`, `S`, `BV_B`, resamples to width 640 (LANCZOS) for `BV*n` and `grad`, exactly per `A11_reference_metrics.md` §1; it wrote nothing into the repo. The metric tool's own `flags` are heuristics, not a fidelity gate (`C01_metric_tool.md:38-47,183-185`).

---

*End of G22 report. Read-only; one report file; no Godot, no runner job, no code or asset edit; donor parity UNVERIFIED.*
