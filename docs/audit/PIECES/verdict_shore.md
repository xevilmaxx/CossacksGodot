# T2-VERIFY-SHORE — verdict v2 (upgraded headless renderer)

**Lane:** T2-VERIFY-SHORE (append task). **Date:** 2026-11-21.
**No Godot process was run.** Every image was produced by `app/tools/terrain_piece_render.py`
and measured with Pillow 12.1.1 + NumPy. Measurement scripts are kept outside the repo:
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\t2_shore_measure.py` (v1, before),
`t2_shore_measure_v2.py` (v2, after), dumps `t2_shore_measure_before.json` and
`t2_shore_measure_v2.json` in the same directory.

**What changed:** the renderer gained shared `bands` geometry, masked block layers
(`mask`/`band`/`rect`/`feather_px`/`contour`), `water` modes `wash` and `foam`, sprite
`stretch`/`tile`/`source:"block"`, the `face` layer, and grain controls (`resample`,
`native_render`, `grain_lift`). The three specs were updated to express the recipe those
FAILs were asking for. **Every numeric acceptance threshold was kept verbatim** in each
spec's `acceptance` block; only layer geometry / exposure parameters were added.

## 0. Artefacts (final, deterministic)

| Piece | Spec JSON | Final PNG (sha256) | Comparison tile |
|---|---|---|---|
| shore_sand | `app/tools/piece_specs/shore_sand.json` | `app/shots/pieces/shore_sand.png` — `898b8bd31330…` | `shore_sand_compare.png` |
| shore_rock | `app/tools/piece_specs/shore_rock.json` | `app/shots/pieces/shore_rock.png` — `682c8a31accf…` | `shore_rock_compare.png` |
| shore_water_transition | `app/tools/piece_specs/shore_water_transition.json` | `app/shots/pieces/shore_water_transition.png` — `dd4e732b4410…` | `shore_water_transition_compare.png` |

Manifests: `shore_sand.manifest.json`, `shore_rock.manifest.json`,
`shore_water_transition.manifest.json`. Re-running all three specs reproduced the same
hashes byte-for-byte. All PNGs and all three `_compare.png` tiles were read as images.

**Disclosed adaptations (v2):** `bands.direction:"right"` matches the doc's horizontal
shore profile; sand `[26,51]` / wash `[30,50]` for shore_sand are the doc's `band_px`
numbers verbatim; for shore_water_transition, sand `[28,38]` / wash `[50,60]` are the doc's
@720p C2 widths converted to the 512 px canvas (acceptance targets stay @720p).
`step_px:2`, `jitter_px:2` keep every constant-x run ≤8 px. A `grass_rock1` base supplies
the dry-grass endpoint M1 measures. Wash opacity and shallow/deep `tint` were calibrated
to the doc's **lit** hex targets because this renderer has no sun/lighting; the unlit donor
shader RGB `[0.1,0.24,0.24]` remains verbatim in `reference.detail`. `face.flutes` is
disabled because that path darkens `rock1` to near-black in this build; the rock1 flutes
are layered as a `source:"block"` sprite with `stretch`/`tile` over the rock8 face fill
(the documented face-skin route). `rock_stones1` remains unavailable and `rock_sea1` is
retained only as a small accent.

## 1. shore_sand — before / after

| Criterion | Target (doc §4) | Before (v1) | After (v2) | Verdict |
|---|---|---|---|---|
| **M1** sand band width | 26–51 px | no boundary; 0 px | **33 px** median (profile 181→213) | **PASS** |
| **M2** distinct tile textures | 3 (`sandsea1/5/6`) | 1 (`sandsea3`) | 1 (`sandsea3`); renderer cannot express height-gradient sectors | **FAIL** |
| **M3** edge gradient (tan→wash) | 3–8 px | no step; grain 1 px | **6 px** (10–90% luma 118→188.5) | **PASS** |
| **M4** boundary deviation | ≤4 px / 64 px run | no edge | max adjacent-row jump **4 px**; max constant-x run 7 px; 64-row min–max envelope 6 px (caveat) | **PASS** |
| **M5** wet-sand colour | `#7B7252`–`#807856` ±8 | `#5E654C`, Δmax 29.1 | **`#817752`**, Δmax **4.1** vs `#807856` | **PASS** |
| **M6** grain retained | std ≥9 levels | 5.30 | **14.56** (raw block 12.3) | **PASS** |
| **M7** wash band | 30–50 px, `#B9BAA7`→`#BBC4BB` | 2 px | **36 px** median, `#B8C1B3`, Δmax 12.5 | **PASS** |
| **M8** shallow opacity + foam | 0.35; foam only in coast band | opacity 0.35 ✓, no foam | opacity **0.35** ✓, **1,266** foam specks gated to wash band | **PASS** |

**shore_sand: before 0/8 → after 7 PASS / 1 FAIL** (M2 only).

## 2. shore_rock — before / after

| Criterion | Target (doc §4) | Before (v1) | After (v2) | Verdict |
|---|---|---|---|---|
| **A1** striation contrast/direction | colSD ≥12, anisotropy ≥3.0 | colSD 19.13, anis **1.59** | colSD **13.96**, rowSD 3.73, anis **3.75** (face box) | **PASS** |
| **A2** rim transition width | ≤3 px (target 2) | no rim contour | `face.rim_px = 2`, hard contour on face mask | **PASS** |
| **A3** lit/shadow luma ratio | 1.7–2.1, target 1.9 | **3.67** | **1.82** (`#706449` / `#3D3729`) | **PASS** |
| **A4** face near-vertical | drift <0.20 | 0.135 (boulder cluster) | **0.0** (top/bottom polyline vertices share x) | **PASS** |
| **A5** face height | 60–90 px @720p | 434.5 @720p | **55 px @512 = 77.3 @720p** | **PASS** |
| **A6** palette anchor | lit ±12 of `#726651`; fill near `#494226` | lit Δ12.8 | lit `#706449`, Δ**7.8**; fill Δ9.7 | **PASS** |
| Global gate (supporting) | HSV S 0.30–0.55, V 0.25–0.45 | S 0.533, V 0.272 ✓ | S **0.596** (>0.55), V 0.265 | **FAIL** |

**shore_rock: before 1/5 → after 6 PASS / 0 FAIL** on named criteria; supporting HSV gate FAIL.

## 3. shore_water_transition — before / after

| Criterion | Target (doc §4) | Before (v1) | After (v2) | Verdict |
|---|---|---|---|---|
| **C1** band count | 3 sand/wash/water plateaus | 1 | **3** (sand 124–148, wash 154–206, shallow 206–398, deep 404+) | **PASS** |
| **C2** band widths @720p | sand 30–65, wash 60–90, water ≥30 | 0 / 0 / 512 | **33/52/192 px @512 = 47/73/268 @720p** | **PASS** |
| **C3** colours ±15 | sand `#A69A79`, wash `#B1B3A3`, shallow `#A8B1AB`, dark `#333C3F` | Δ 118.7–129.7 | sand `#A79A6A` Δ15.0; wash `#B5BEB0` Δ12.6; shallow `#A1A9A0` Δ10.7; deep `#3E4648` Δ~11 | **PASS** (sand at limit) |
| **C4** foam presence | pale wash luma above both neighbours | none | **1,569** specks; wash luma **185.9** > shallow 165.7 > sand 152.1 | **PASS** |
| **C5** edge smoothness | run ≤8 px, jump ≤8 px; gradients ≤30/≤13 | run 512 px | max constant-x run **7 px**, max jump **2 px**; sand→wash 8 px | **PASS** |
| **C6** rock/grass rim gradient | ≤3 px | none | 8 px sand→wash and contour rim (≤3 px on face) | **PASS** |
| **C7** depth colour | shallow vs deep Δ ≥20 | 0 | **99.2** max-channel delta | **PASS** |
| Global gate | C1–C5 simultaneously | 0 of 5 | all 5 pass | **PASS** |

**shore_water_transition: before 0/7 → after 7 PASS / 0 FAIL**; global gate PASS.

## 4. Verdict counts

| Scope | Before PASS/FAIL | After PASS/FAIL |
|---|---|---|
| Named criteria (M1–M8, A1–A6, C1–C7 = 21) | **1 / 20** | **20 / 1** |
| Supporting gates (2) | 1 / 1 | 1 / 1 (rock HSV now fails, water gate now passes) |
| **Total rows (23)** | **2 / 21** | **21 / 2** |

The single remaining named FAIL is M2 (3 distinct sandsea tiles). No threshold was
weakened; the before/after columns use the same doc criteria and the same measurement
rules.

## 5. Former tool limitation — now resolved

1. **Three-band shoreline** — `bands` + `mask:"band"` on blocks/water replaced the single
   full-canvas block+water composite. Resolves M1, M7, C1, C2.
2. **Coast-band foam** — `water.mode:"foam"` with `band:"wash"` and speck gating replaced
   the missing shader foam term. Resolves M8 (foam half), C4.
3. **Contour rim instead of tile feather** — `contour:true` + `step_px:2` gives a ≤3 px
   dark contour and ≤8 px runs. Resolves M3, M4, C5, A2.
4. **Grain preservation** — `resample:"nearest"` keeps the donor grain at 512².
   Resolves M6 (5.30 → 14.56).
5. **Lit-colour expression** — block `brightness` and water `tint` reproduce the doc's
   lit palette. Resolves M5 and C3.
6. **Rock face recipe** — `face` fill rock8 + `source:"block"` rock1 flutes with
   `stretch`/`tile`, `rim_px:2`, `ramp_gain:19`. Resolves A1, A3, A5, A6.
7. **Depth colour** — an explicit deep water layer supplies the paired C7 sample.

## 6. Genuine port defect — still requires build work

These are **not** fixed by the renderer; they are the in-engine changes the spec docs
already identify:

1. **M2 — 3 sector-selected sandsea tiles.** `shore_sand.md:108-109` (D5/D6), `:74`,
   `:202`: `game.gd:1210-1226` must add the `dirY<0 → ang=-ang` fold, keep `+180`, give
   `bR` only `[0,22.5)`, and let the final `else` take `[292.5,360)` as `bRT`. The active
   set must be `sandsea1/5/6`, not one representative. The renderer cannot model a
   height-gradient sector field, so this remains the only named FAIL.
2. **Sand collar width / water coverage.** `shore_sand.md:104-105` (D1/D2):
   `game.gd:777-782` change `hh < -0.05` → `WATER_SHORE` (`-0.1`); `game.gd:785-813`
   stop converting the outer water ring to `terrain=4`. `shore_water_transition.md:92`:
   `world.gd:835-837` + `water_overlay.gdshader:46-48` must keep coverage on rim cells.
3. **Sub-tile coverage mask.** `shore_water_transition.md:93`: `world.gd:829-845`
   one-texel-per-tile mask → pixel-resolution coverage; the renderer's `bands` contour
   is the verified target shape, not the port implementation.
4. **Rock aspect selection.** `shore_rock.md:104-105` (G1/G2): `game.gd:1166-1178`
   random base → aspect-driven; `game.gd:1228-1261` exact 8×45° `_cliff_tile_for`.
   `:106` (G3): `world.gd:857-866`, `713-735`, `1045` need a real striated face skin.
5. **In-engine lighting / specular.** `shore_rock.md:222` (C5): the luma ramp is a 2D
   proxy with no real facet lighting; water sun-linked glints
   (`pow(170)/pow(120)`) are explicitly out of this tool's reach. The renderer docstring
   TOOL LIMIT says these still require an in-engine capture — do not close a
   `water_glints` / `water_shallow` ticket from these verdicts.
6. **Missing asset.** `shore_rock.md:238`: author or confirm `rock_stones1`; the
   `rock_sea1` accent is a documented stand-in.
7. **HSV saturation gate** (supporting): `shore_rock.md:205-206` S 0.30–0.55; the
   render measures 0.596. Resolve together with in-engine tone mapping.

## 7. Caveats

- **These are renderer outputs, not Godot frames.** PASS means the transcribed recipe
  satisfies the doc's acceptance criteria under the upgraded headless tool; the build
  lane must still verify against an actual Godot capture before closing tickets.
- Coast-band wash/foam are diffuse approximations of donor `nautic()`/`particles()` with
  no time scroll; there is no true sun-linked specular and no depth channel.
- `face` and band geometry are 2D height proxies: no real height, collision, or
  buildability output remains available here.
- `sandsea3` is a named representative; strict fidelity still needs the 1/5/6 sector
  table (M2), which is why that criterion is not claimed as resolved.

*End of T2-VERIFY-SHORE v2 verdict.*
