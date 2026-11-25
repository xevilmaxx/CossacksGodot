---
id: A03
ticket: TERRAIN-SWARM-2026-11-25/A03
title: "Tile-art asset audit — tile_index_atlas cells, block PNGs, 4x4 tiling"
status: DONE (read-only; no Godot job, no code edit)
labels: [observed, derived, inferred, UNVERIFIED]
image_artifact: A03_atlas_cells_contact.png
---

# A03 — Atlas cell / tile-art audit

## 0. Scope and method

Charter read in full first. This ticket audits **actual pixels**, not shader theory.

Inputs (all read-only):

- `variant3d/assets/terrain/atlas/tile_index_atlas.png` — 16,384 × 8,192 **RGBA**, 1024 px cells, decoded **once** with Pillow and cropped cell-by-cell (machine has 25 GB RAM, so no memory-bound streaming was needed). Alpha in the audited cells is uniformly 255.
- `variant3d/assets/terrain/atlas/tile_index_atlas.manifest.json` — 16 × 8 grid, 128 slots, 124 named cells, 121 filled, 3 empty.
- `variant3d/assets/terrain/blocks/*.png` — source art.
- `variant3d/assets/terrain/structs/tileblocks.json`, `variant3d/scripts/game.gd:1957-2031`, `variant3d/shaders/terrain_tileindex.gdshader:214-218,390-392`, `tile_index_atlas.png.import:26`.

**OBSERVED (E01): the atlas is a verbatim pixel copy of the block art.** For every cell audited below, `crop(atlas cell) == np.asarray(block PNG)` exactly (19/19), and three sampled `source_sha256` values (`grass1`, `ground1`, `test7`) match the shipped block files. Metrics below are therefore reproducible from the cheap 1.5 MB block PNGs without opening the 180 MB atlas.

Measurement convention (all **DERIVED**, computed values, no GPU involved):

- `Y = 0.299R + 0.587G + 0.114B` on 8-bit sRGB values, no linearisation — a *measurement* convention, not physical luminance.
- **std** = std(Y) = contrast. **edge** = (mean |ΔxY| + mean |ΔyY|)/2, in luma units/pixel.
- **gx/gy** = (gx−gy)/(gx+gy); positive = more change across columns = **vertical-feature bias**.
- **Sx / Sy** = mean |Y[:,0]−Y[:,−1]| / gx and mean |Y[0,:]−Y[−1,:]| / gy: wrap jump relative to a normal adjacent-pixel jump. ≈1.0 means the wrap edge is no worse than an ordinary interior step; >1.5 means a cut boundary.
- **ΔYx / ΔYy** = signed mean wrap step. A large |ΔY| is a **DC brightness step**, i.e. a visible line every tile even when Sx/Sy is modest.
- **FFT-aniso** = max/min of summed 2D-FFT power in 30° angular bins (radius 3…N/3) of a **4×4 tiling**. 1.0 = isotropic, >2 = directional energy. Angle = dominant bin.
- **LF** = std(Y downsampled 8×8)/std(Y): coarse-structure fraction. One 8×8 bin = 128 px = 0.25 m at the current 2 m/cell.
- 4×4 tiling visual check is in **`A03_atlas_cells_contact.png`** (the only image written; each panel shows one cell tiled 4×4 with a single-cell inset). Visual verdicts are CPU previews (LANCZOS downscale), **not** GPU frames.

## 1. Evidence index

| ID | Label | Evidence |
|---|---|---|
| E01 | OBSERVED | All 19 audited atlas cells are byte-identical to their `blocks/*.png` sources; manifest labels them `DIRECT`, `status=OK`, 1024×1024. |
| E02 | OBSERVED | Manifest: 124 named cells, 121 filled, 3 empty (`alpha0a/b/c`, transparent, no art fabricated); 6 sand cells upscaled 256→1024. |
| E03 | OBSERVED | `grass1` / `test10` / `test11` are the **same pixel array**; `grass8` = `test0`; `grass_ground3` = exact horizontal mirror of `grass_ground1`. |
| E04 | OBSERVED | `tileblocks.json`: `test10` = 16×16 sub-tiles, `test11` = 32×32 sub-tiles; all grass-family entries have `rows=cols=1`, `anglex=anglez=0`. No `.gd` file reads `anglex`/`anglez`/tileblock `rows`/`cols` (grep over `variant3d/**/*.gd`). |
| E05 | OBSERVED | `game.gd:1982` — every land cell starts as `grass1` (preset index 0); `:1991` roads use `ground1` 50%; `:2030` mine aprons force `ground1`. |
| E06 | OBSERVED | `terrain_tileindex.gdshader:214-218,390-392` — `uv_repeat=(0.5,0.5)`, `rgb = tile_rgb(v_tile, fract(v_st*uv_repeat))`: **one cell per 2 m**, grounded on donor `gc_meters_to_tile=2` (`dmscript.global:171`). |
| E07 | OBSERVED | `tile_index_atlas.png.import:26` — `mipmaps/generate=false`; `:18` `compress/mode=0` (lossless). No generated mip chain for the repeated texture. |
| E08 | OBSERVED | Per-cell numbers in §2 (measured this ticket). |
| E09 | OBSERVED | 4×4 tiling appearance in `A03_atlas_cells_contact.png`. |
| E10 | OBSERVED | `tileblocks.json`: 36 `sand*s` / `rock*vs` entries use `anglex=25, anglez=25`; the atlas's 36 `FACE_BASE_REUSE` face cells are exact identity copies of their bases (no rotation baked in). |

## 2. Per-cell measurements (in-scope grass family, 19 cells)

| Cell | idx | mean (R,G,B) | std | edge | gx/gy | Sx | Sy | ΔYy | FFT-aniso (angle) | LF | 4×4 verdict |
|---|---:|---|---:|---:|---:|---:|---:|---:|---|---:|---|
| grass1 | 0 | 76.0, 82.5, 30.4 | 8.87 | 7.63 | 0.00 | 1.18 | 1.11 | −0.05 | 1.46 (0°) | 0.23 | clean but bland; baseline fill |
| grass2 | 1 | 77.1, 80.4, 31.8 | 13.14 | 11.21 | **+0.29** | 1.03 | **1.81** | +0.51 | **5.16 (0°)** | 0.13 | **vertical streaks / wrap cut** |
| grass3 | 2 | 72.5, 71.1, 21.9 | 15.36 | 15.28 | −0.01 | 0.98 | 1.18 | **+8.47** | 1.27 (90°) | 0.12 | **horizontal seam line** |
| grass4 | 3 | 75.2, 68.0, 19.6 | 10.21 | 10.06 | 0.00 | 0.97 | 1.25 | **+7.58** | 1.25 (90°) | 0.11 | **horizontal seam line** |
| grass5 | 4 | 64.7, 62.0, 31.4 | 16.26 | 16.24 | 0.00 | 0.95 | 1.01 | −3.16 | 1.51 (90°) | 0.12 | usable; darker/cooler, slight bottom edge |
| grass6 | 5 | 54.8, 48.0, 25.2 | 11.70 | 10.65 | +0.14 | 1.08 | 1.18 | −0.09 | 2.20 (90°) | 0.25 | dark olive-brown, mottled, mild directionality |
| grass7 | 6 | 74.8, 77.0, 29.1 | 11.97 | 10.80 | −0.01 | **1.30** | 1.15 | −0.47 | 1.89 (90°) | 0.23 | usable; soft patch texture, mild wrap mismatch |
| grass8 | 7 | 73.7, 79.4, 23.8 | 15.91 | 11.89 | +0.02 | 1.15 | 1.26 | −3.90 | 1.78 (90°) | 0.11 | usable with bottom-edge caution; = `test0` art |
| grass9 | 8 | 77.0, 79.4, 29.4 | 15.62 | 15.94 | 0.00 | **0.93** | **1.02** | +0.78 | **1.20 (0°)** | 0.12 | **best: isotropic, seamless, good contrast** |
| grass10 | 9 | 76.0, 74.3, 24.0 | 13.29 | 12.16 | −0.02 | 1.02 | 0.99 | −1.65 | 2.29 (90°) | 0.13 | good seams; some vertical energy |
| ground1 | 10 | **99.8, 90.7, 66.3** | 19.64 | 16.61 | −0.07 | **1.40** | 0.60 | −0.14 | 1.33 (60°) | 0.10 | **grey-brown, diagonal scratches; not grass** |
| grass_ground1 | 14 | 82.5, 79.3, 36.6 | 20.73 | 15.87 | +0.01 | 1.21 | 1.20 | −0.40 | 2.24 (40°) | 0.21 | **bright diagonal vein lattice — strong repeat** |
| grass_ground2 | 15 | 83.5, 83.9, 40.0 | 20.59 | 14.98 | −0.01 | 0.93 | 0.80 | −1.00 | 1.67 (90°) | **0.39** | **denser crosshatch veins; worst visual repeat** |
| grass_ground3 | 16 | 82.5, 79.3, 36.6 | 20.73 | 15.87 | +0.01 | 1.21 | 1.20 | −0.40 | 2.13 (130°) | 0.21 | **mirror of idx14; same lattice, reversed angle** |
| test7 | 78 | 74.2, 78.8, 28.2 | 13.20 | 10.89 | +0.02 | 1.10 | 0.91 | +0.05 | 1.50 (90°) | 0.11 | good; soft, slightly flat |
| test8 | 79 | 73.0, 77.9, 27.9 | 15.03 | 14.93 | +0.04 | 0.95 | 0.96 | +0.82 | **1.27 (90°)** | 0.09 | **good; isotropic, seamless** |
| test9 | 80 | 74.5, 76.4, 24.6 | 16.02 | 15.99 | −0.01 | 1.07 | 0.94 | +1.01 | **1.26 (90°)** | 0.10 | **good; isotropic, seamless** |
| test12 | 83 | 73.4, 79.7, 29.1 | 9.78 | 8.58 | −0.01 | 1.05 | 1.11 | +1.36 | 1.53 (130°) | 0.15 | acceptable but very flat |
| test14 | 85 | 74.2, 80.6, 29.4 | 9.46 | 8.37 | +0.01 | 1.00 | 1.24 | +1.00 | 1.24 (0°) | 0.16 | acceptable but very flat |

Secondary context (not ranked): `grass_sand1/2`, `grass_rock1` mean (68.8,74.6,28.9)/(76.2,80.8,32.7)/(71.7,69.3,33.9), FFT-aniso 1.51/1.67/1.00, all atlas==block.

## 3. Findings

### F01 — The art is near-seamless; the pattern is *repetition*, not broken edges. OBSERVED / DERIVED
Across the 19 cells, 16 have both Sx and Sy ≤ 1.30 and |ΔY| ≤ 1.7 luma. The source textures were authored to wrap. Only `grass3` (+8.47) and `grass4` (+7.58) carry a large *signed* vertical wrap step, and `grass2` has Sy = 1.81. So "seams" in the render (charter §1 line 21) are, for most cells, **the periodic reappearance of the same fine detail every 2 m**, not a per-cell cut line. This is a crucial distinction: edge-healing 17 cells would buy little.

### F02 — No cell contains the donor's large-scale mottling. OBSERVED / DERIVED / INFERRED
LF (coarse 0.25 m structure fraction) is **0.09–0.25** for the 15 core grass-like cells; FFT low-power fraction is 0.065–0.39. Across those 15 cells the mean RGB is (72.7, 74.3, 27.0) with between-cell std only **(5.6, 8.8, 3.5)** — switching tile ids barely changes the colour. **INFERRED:** repeating or re-scaling these cells cannot produce the donor's soft multi-metre green mottling (charter §1 lines 23–24); that variation must come from tile-id/relief/decal data, not from this art. Classic nearest-minified olive grain with no macro structure is exactly what the P0 screenshot shows.

### F03 — `grass_ground*` is the loudest intrinsic pattern. OBSERVED (E03, E08, E09)
`grass_ground1/2/3` show bright diagonal veins forming a crosshatch/diamond lattice that is unmistakable in the 4×4 panels; `grass_ground2` has the highest LF of the whole set (0.39). `grass_ground3` is an exact horizontal flip of `grass_ground1`, so the three ids provide **one base pattern plus a mirror**, not three variants. At 2 m/cell these veins tile every 2 m and align with the owner's "diagonal streaks" complaint — **INFERRED** as a contributor wherever those ids are painted (detail pass), not proven to dominate the P0 frame.

### F04 — `grass2` is a directional outlier. OBSERVED / DERIVED
FFT-aniso **5.16** (dominant 0° → vertical-energy concentration) and spatial gx/gy = **+0.29**, plus Sy = 1.81 (worst wrap mismatch of the grass set). The 4×4 panel shows a repeated vertical banding. This is a textbook source of shallow-camera moiré/banding under nearest sampling with no mipmaps (E06, E07).

### F05 — `grass3` / `grass4` have authored horizontal seams. OBSERVED / DERIVED
ΔYy = +8.47 / +7.58 luma between bottom and top rows. Because Sx/Sy are only 1.18/1.25 (interior contrast is high), a per-cell "seam ratio" flag alone would miss this; the **signed step** exposes it. Tiling produces a faint horizontal line at each 2 m boundary.

### F06 — `ground1` is off-palette. OBSERVED
Mean (99.8, 90.7, 66.3) — roughly +24/+16/+37 over the grass-family mean — a grey-brown dirt texture with diagonal scratches and Sx = 1.40. It is appropriate for roads/mine aprons (`game.gd:1991,2030`) but wrong as generic meadow.

### F07 — "Variety" is partly illusory. OBSERVED (E03, E04)
`test10`/`test11` repeat `grass1` exactly; `test0` repeats `grass8` exactly. Donor `tileblocks.json` declares `test10` = 16×16 and `test11` = 32×32 sub-tiles, i.e. the donor uses those names for *sub-tiling*, whereas the manifest packs them as single 1024 px copies of `grass1` art. No `.gd` code consumes those `rows`/`cols`/angle fields (grep evidence E04). **INFERRED:** the port therefore gains three ids but zero new pixels — consistent with charter §2 suspect 5 (one id repeated = one cell repeated). Whether another non-GDScript path uses the fields is **UNVERIFIED** here.

### F08 — Rotation is not already in the ground pack. OBSERVED (E10)
All audited grass-family tileblocks have `anglex=anglez=0`; the 36 angled entries are `sand*s`/`rock*vs` faces at 25°. The 124-cell atlas `FACE_BASE_REUSE` entries are identity copies, not rotated. The single mirrored pair (`grass_ground1`→`grass_ground3`) shows mirroring exists in the source family, but systematic stochastic rotation of grass would be a **PORT APPROX**, not donor-grounded.

### F09 — Filtering amplifies whatever pattern remains. OBSERVED (E06, E07) / INFERRED
`uv_repeat=0.5` gives 512 px/m; at shallow camera distance this is minification, and the atlas has `mipmaps/generate=false`. Nearest/minified sampling of a 2 m verbatim repeat is the classic aliasing path for the charter's "faint diagonal streaks / repeating bands". This ticket did **not** run Godot, so the causal share between aliasing and cell repetition is **UNVERIFIED**.

## 4. Best / worst as a repeating ground texture

**Best (use as default flat-grass):**

1. **grass9 (idx 8)** — FFT-aniso 1.20, Sx 0.93, Sy 1.02, |ΔY| ≤ 0.8, std 15.6, olive (77,79,29). Cleanest all-round.
2. **test9 (idx 80)** — 1.26, Sx 1.07, Sy 0.94, ΔYy +1.01, std 16.0.
3. **test8 (idx 79)** — 1.27, Sx 0.95, Sy 0.96, ΔYy +0.82, std 15.0.
4. Second tier: **grass1** (seamless but std only 8.9 — flat), **grass10** (good seams, aniso 2.29), **grass5/grass7** (usable, darker/warmer).

**Worst (do not tile as ground):**

1. **grass_ground2 (15)**, **grass_ground1 (14)**, **grass_ground3 (16)** — bright diagonal lattice, 4×4 repeat unmistakable; idx16 is a mirror of idx14.
2. **grass2 (1)** — FFT-aniso 5.16, Sy 1.81, vertical banding.
3. **ground1 (10)** — off-palette grey-brown with diagonal scratches and Sx 1.40.
4. **grass3 (2) / grass4 (3)** — signed seam +8.5/+7.6 luma every 2 m.
5. **test12/test14** — not broken, but std 9.5–9.8 makes them the flattest fillers; low priority.

## 5. Repeat scale and stochastic rotation

**1 m per cell (`uv_repeat=1.0`) — reject.** DERIVED/INFERRED: doubles repeat frequency per screen area and doubles minification (1024 px/m sampled at distance), making both the 2 m pattern and the no-mip aliasing (E07) worse. Since cells have almost no coarse structure (F02), there is no large blob to "shrink away".

**4 m per cell (`uv_repeat=0.25`) — conditional yes, PORT APPROX.** Halving repeat frequency and halving minification attacks both pattern density and aliasing; 1024 px over 4 m is still 256 px/m. It **does** make an individual cell's intrinsic features twice as large, so it helps only on the isotropic cells (grass9/test9/test8/grass1) and **hurts** grass2, grass_ground*, ground1 (their streaks become bigger and more legible). It breaks the 2 m rhythm but cannot create donor-scale mottling (F02). It departs from donor `gc_meters_to_tile=2` (E06) and must be labelled as such. **UNVERIFIED** until a GPU A/B frame exists.

**Stochastic rotation — conditional yes, PORT APPROX.** A world-cell-hashed 0/90/180/270° + mirror rotation breaks axis-aligned grid lines and reorients streaks, and the pack already contains a mirrored variant (E03). Constraints: use only 4-fold rotations/mirrors (arbitrary angles destroy tileability at the wrap boundary); apply only to cells with FFT-aniso < ~1.5 (grass9, test8, test9, grass1, test7, test12, test14); **do not apply to grass2/grass_ground*/ground1** — rotating a streak just changes its angle and spreads the defect over more orientations. Donor uses 25° only on sand/rock slope faces, not grass (F08), so this is not donor parity.

**Combined recommendation:** keep the donor-grounded 2 m baseline for parity; if the owner still sees repetition, run an A/B of *4 m + stochastic 90° rotation limited to grass9/test9/test8*, rather than changing scale or rotating globally. Neither lever alone fixes the flatness gap of F02.

## 6. Concrete asset-level recommendations

| # | Recommendation | Owner | Label |
|---|---|---|---|
| R01 | Restrict default meadow fills to **grass9, test9, test8**; retire `grass1` as the universal base (`game.gd:1982`) except where a deliberately flat look is wanted. | B-wave data | DERIVED from E08/E05 |
| R02 | **Blacklist `grass_ground1/2/3` as repeating ground.** Keep them only as masked cliff/road transitions covering ≤1 cell; treat idx16 as a mirror of idx14, not extra variety. | B-wave data / asset | OBSERVED E03/E09 |
| R03 | **Blacklist `grass2`** from large flat fills (FFT-aniso 5.16, Sy 1.81). If retained, limit to small transition patches. | B-wave data | DERIVED E08 |
| R04 | Heal the top/bottom edges of **`grass3`/`grass4`** (content-aware blend until ΔYy < 2 luma) before any tiled use; otherwise exclude. | asset fix | OBSERVED E08 |
| R05 | Keep **`ground1`** confined to road/mine-apron masks (`game.gd:1991,2030`), never generic grass. | B-wave data | OBSERVED E06/E05 |
| R06 | Stop counting **`test0`/`test10`/`test11`** as art variety; they are exact copies. If a distinct look is needed, author new 1024 px art or use the rotation lever of §5. | asset / data | OBSERVED E03 |
| R07 | Do **not** change to 1 m. If an A/B is run, test **4 m only on isotropic cells** and label it PORT APPROX (departure from `gc_meters_to_tile=2`). | B/C-wave | DERIVED + INFERRED |
| R08 | If stochastic rotation is implemented: 0/90/180/270°+mirror, world-cell hashed, isotropic cells only, atlased UVs adjusted for the rotation; **not** on grass2/grass_ground*/ground1. PORT APPROX. | B-wave shader | OBSERVED E10 + INFERRED |
| R09 | Treat multi-metre colour variation as a **tile-id/relief/decal problem** (F02): no asset in this family supplies it. Flag to data/relief tickets, not to texture edits. | COORD | INFERRED |

## 7. Unknowns / UNVERIFIED

- Which of these cells actually dominates the P0 frame: no tile-id histogram from a rendered capture was produced in this ticket (A01/A05 territory). `game.gd:1982` makes `grass1` the default, but the painted detail-pass mix is unmeasured here.
- Donor parity: no donor GPU A/B frame exists; every visual judgement above is CPU-side. Charter rule §3.1 applies — parity stays **UNVERIFIED**.
- Any non-GDScript consumer of `tileblocks.json` `rows`/`cols`/`anglex` fields (F07).
- Whether the `.ctex` import (`compress/mode=0`, lossless) introduces any filtering not visible in the source PNGs; the shader sampler path was not executed.

*End of A03. Only files written: this report and `A03_atlas_cells_contact.png`.*
