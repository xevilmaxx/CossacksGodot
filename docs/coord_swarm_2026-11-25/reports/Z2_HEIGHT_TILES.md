---
id: Z2-HEIGHT-TILES
title: "Recon: height clamp, analytic-vs-donor-grid relief, test*/rock* tile placement in current game.gd"
agent: "Z2-MAPGEN-HEIGHT (read-only recon subagent, coord swarm 2026-11-25)"
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_EDIT__NO_RUNNER_JOB__NO_DONOR_EXEC
scope: "One new file only: this report. No code/config/asset/test/Godot/git/donor write. Donor bytes read in place only."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
labels: [observed, derived, inferred, UNVERIFIED]
parity_guard: "PORT APPROXIMATION throughout. No donor GPU A/B exists; no donor parity is claimed anywhere."
note: "All game.gd/main.gd line numbers are CURRENT file lines (2026-11-25 read), not the older line numbers quoted in prior reports."
---

# Z2 HEIGHT / TILES — three answers

## 0. Boundary and method

Read-only source/donor/text reads only. Facts labelled **observed** (literal source line / decoded file), **derived** (arithmetic or control-flow consequence), **inferred** (attribution without pixel-aligned donor A/B), **UNVERIFIED**. Port line cites are `variant3d/scripts/...` unless prefixed `donor:` (`C:\Games\Cossacks 3\...`). Donor > port throughout; nothing invented to fill gaps.

---

## 1. Q1 — HEIGHT CLAMP (±2.964)

### 1.1 The clamp sites (observed, current lines)

| Site | Code | Effect | Evidence |
|---|---|---|---|
| `game.gd:81` | `const RELIEF_PLATEAU := 2.964` | upper bound constant | observed |
| `game.gd:83` | `const RELIEF_RAVINE := -2.964` | lower bound constant | observed |
| `game.gd:1052` | `height[i] = clampf(height[i] + gv0 * gscale, gmin, gmax)` | **donor-grid stamp clamp**; `gmin/gmax` are verbatim pattern literals (`game.gd:1049-1051`, meta `game.gd:118-123`) | observed |
| `game.gd:1099` | `height[i] = clampf(height[i] + amp * f, RELIEF_RAVINE, RELIEF_PLATEAU)` | analytic-fallback stamp clamp ±2.964 | observed |
| `game.gd:1209` | `_shape_stamp_relief()` | called unconditionally before collision | observed |
| `game.gd:1216-1237` | global land composite clamp | `terrain==3` skipped (`:1217`); **donor cells** take single `clampf(h,-2.964,+2.964)` at `:1219-1229`; all other cells take dither cap `hcap = 2.964 or 2.934` at `:1233-1237` | observed |
| `main.gd:788-803` | relief marker gate | dump-path flag; default false ⇒ no `relief_stamps` key (`:802-803`) | observed |

### 1.2 Is the clamp donor-grounded? (mixed; final clamp UNVERIFIED)

| Claim | Verdict | Evidence |
|---|---|---|
| Donor authoring constants are ±2.964 | **observed** | `donor: generatemap.inc:4` `cPlateauHeight = 2.964`; `:6` `cRavineHeight = -2.964`; `:5` `cHillHeight = 2.964/2.25`; `:7` `cWaterHeight = -1.1`. `cMaxHeight=2.96` is a **tile-classification** constant, not a height ceiling (`donor: texturemap.inc:29`; DTRN_02 `:109,192`). |
| Baked donor `.map` heights never exceed ±2.96399999 | **observed** | DTRN_02 C10 `:106`; decoded bonmis1/engmis4 min `-2.9639999866`, max `+2.9639999866` (`:262-263`), with 4.18%/9.07% of cells at exactly +2.964. |
| Donor has a script height clamp that produces that bound | **UNVERIFIED** | Full `generatemap.inc` read found no height clamp: only `ClampInt` on **indices** (`donor: generatemap.inc:561-562,619-627`); final height writes at `:574` and `:242`. Confirmed by HEIGHT-GEN-DEEP-01 §5.4/§8 Q1 and RELIEF-LIVE-FIX-01 `:117-123,303-306`. Port clamp is explicitly **port-only**, not claimed donor. |
| Port ±2.964 is therefore donor-grounded | **derived, weak** | It reproduces the **observed baked envelope** (DTRN_02 `:106`), but the donor mechanism that enforces it is UNVERIFIED; the port value is a safety bound, not a transcribed donor clamp (RELIEF-LIVE-FIX-01 `:117-123`). |

### 1.3 Does the port decapitate real donor relief? (yes at the grid, consistent with baked maps)

| Pattern | Donor grid min/max | `HeightFieldScale` | Effective stamped cap | Clamped by `:1228`? | Evidence |
|---|---:|---:|---:|---|---|
| `k_ravine_1` | −2.9636276 / **+3.1398201** | 1.0 | +3.1398 | **yes** (positive side) | `game.gd:94-103,119-120`; `donor: pattern.lib:549585-549586`; DPATTERN `:142` |
| `plt2` | −0.0732549 / **+3.6134117** | 1.0 | +3.6134 | **yes** | `game.gd:104-113,121-122`; `donor: pattern.lib:6805-6806`; DPATTERN `:154` |
| `plt1` | −0.0949412 / +3.4966981 | 1.0 | +3.4967 | yes (if exported) | DPATTERN `:153` |
| `plt3` | −0.0298824 / **+4.7412834** | **0.8** | +3.7930 | yes (if exported) | DPATTERN `:155` (derived cap = 4.7413×0.8) |
| `plt4_fixed` | −0.1015686 / +3.2846272 | 1.0 | +3.2846 | yes (if exported) | DPATTERN `:156`; file on disk `plt4_fixed.pattern` |
| `plt5` | −0.1215688 / +2.0720758 | **1.5** | +3.1081 | yes (if exported) | DPATTERN `:157` (derived cap = 2.0721×1.5) |
| `hil1` | 0.0 / +3.8613024 | **0.65** | +2.5098 | **no** | DPATTERN `:160`; derived cap = 3.8613×0.65 |
| `g_mnt_1/3` | 0.0 / 0.0 (all-zero) | 1.0 | 0 | n/a | DPATTERN `:168-169` — relief is 3D props, not a grid |

**derived:** the donor-grid branch at `game.gd:1052` deliberately preserves the pattern's own `HeightFieldMax` (+3.6134 for `plt2`), but the *same cells* are re-clamped to +2.964 at `game.gd:1228`. Every plateau cap above +2.964 is flattened. The coarse `plt2` table's peak is `3.437` (`game.gd:108`, DPATTERN Appendix A2 `:615-626`), so the cap is already lost in the coarse data before the global clamp. **inferred:** this is the "flat pale mark not a hill" shape, but no donor A/B exists and no parity is claimed (TERRAIN MARKS 01 `:101,148`; RELIEF-LIVE-FIX-01 `:287-289`).

### 1.4 Minimal donor-faithful change (or UNVERIFIED)

- **No donor-faithful *removal* of the clamp can be justified.** The only observed donor target is the baked envelope ±2.96399999 (DTRN_02 `:106,262-263`); relaxing `game.gd:1228` to permit +3.6134 would exceed every decoded donor `.map` (UNVERIFIED whether donor engine does that). Keep `:81,83,1228` as-is. Existing reconciliation is already labelled port-only at `:1220-1227`.
- **No-op simplification (optional, byte-equivalent):** fold the pattern min/max into the stamp clamp at `game.gd:1052` as `clampf(h + gv0*gscale, maxf(gmin, RELIEF_RAVINE), minf(gmax, RELIEF_PLATEAU))` and delete the donor-cell `continue` at `:1229`. Numerically identical (all decoded `gmin ≥ -2.964`; the bound side is `gmax`), but it removes the double clamp. **derived**, not donor-parity-affecting.
- **To actually preserve the donor cap shape** one must change the target envelope itself (per-pattern Max, or drop the global clamp for donor cells) — **UNVERIFIED** against donor; do not do it without a donor A/B.

---

## 2. Q2 — ANALYTIC vs DONOR-GRID relief

### 2.1 Which path runs on a normal random map (observed + derived)

| Path | Code | Runs? | Evidence |
|---|---|---|---|
| Live donor-grid branch | `game.gd:970-984` name gate → `:1039-1055` stamp | **Bound but normally inert.** Gate accepts exactly `plt2`/`k_ravine_1` (`:977-982`). `k_ravine_1` is unreachable (RELIEF-02 `:68-84`; RELIEF-LIVE-FIX-01 `:269-273`). Available fixture seed 20261113 emits `relief_grid = {candidates:0, applied_cells:0}` — neither of its two plateau stamps is named `plt2` | observed (ledger, RELIEF-LIVE-FIX-01 `:237-254`); **UNVERIFIED** that any seed places `plt2` (RELIEF-LIVE-FIX-01 `:317-318`) |
| Live analytic fallback | `game.gd:1056-1099` radial/taper profiles | **Yes — this is what shapes a normal random map.** Every non-donor stamp reaches `:1091` (`f`) and `:1099` (`+= amp*f`) | **derived** from `:1055 continue` + `:977-984` |
| Dump/render donor-grid stamp (`world3d_terrain.gd` opt-in) | `main.gd:777-803` producer; config default false (TERRAIN MARKS 01 `:99`) | **No.** Key omitted at `:802-803`; reader returns 0; P0 harness dump has no marker (TERRAIN MARKS 01 `:99,118-124`) | observed |

### 2.2 Visibility arithmetic (derived; camera visibility UNVERIFIED)

| Quantity | Value | Evidence |
|---|---:|---|
| Max analytic amplitude | 2.964 m | `game.gd:1099`, `:81` |
| Mission's 480 m map span | 2.964 / 480 = **0.62%** | derived from mission figure; donor 480-cell grid option at DTRN_02 `:187`, donor metre scale UNVERIFIED (`C20 :116`) |
| Port default 320² × `TILE_M=2.0` = 640 m | 2.964 / 640 = **0.46%** | DTRN_02 `:265,285`; `C20 :116` |
| Ravine wall local slope | ~2.964 m over `rim_tiles=3` cells ≈ 6 m ⇒ up to ~49% | `game.gd:1001,1079-1081`; derived |
| Rock/face promotion from those slopes | `|dh|>0.5` at `:1248-1262` ⇒ terrain=5 + blocked | observed; so relief is visible in tiles even if not visually obvious |
| Whole-map silhouette at shipped camera | **UNVERIFIED** — no matched camera A/B (TERRAIN MARKS 01 `:219-221`; V3D_02 `:88` headlight/unshaded) | inferred only |

**derived:** at whole-map framing relief is <1% of span (subtle); locally the ravine 3-tile walls and plateau rim are steep enough to generate rock tiles. Visibility is a camera/lighting question, not a height-arithmetic one.

### 2.3 What FULL donor-grid stamping would take (minimum change list)

| # | Required change | Current blocker | Evidence |
|---:|---|---|---|
| 1 | Export full `w*h` float32 windows to **derived numeric JSON** (numbers only; no donor binary copied), with `w,h,offset,scale,min,max` and verbatim min/max validation | Only two 8×10 coarse tables exist (`game.gd:94-113`) | DPATTERN §7 `:450-501`, §8 `:504-537`; DTRN_02 §8 Step 1 `:372-377`; coarse tables labelled "debug/preview aids only" DPATTERN `:599-600`, `game.gd:86-90` |
| 2 | Replace the 80-float constants and `_sample_relief_grid()` (`game.gd:918-934`) with native-resolution lookup over the full `w×h` window, keeping the same `u,v` footprint input (`:1046-1047`) | Bilinear over 10×8 only | observed |
| 3 | Widen the name gate at `game.gd:977-982` to all decoded names; verify each name is present in `assets/terrain/patterns/donor_patterns.json` (only `plt2` was observed present; others **UNVERIFIED**) | Exactly two ids accepted | RELIEF-02 `:45`; RELIEF-LIVE-FIX-01 `:68-84` |
| 4 | Read per-pattern `HeightFieldScale` from `pattern.lib`, not hardcoded 1.0 (`game.gd:1049`, `RELIEF_GRID_META :118-123`) | `plt3=0.8`, `plt5=1.5`, `hil1=0.65` ignored | DPATTERN `:155,157,160`; DTRN_02 C7 `:103` |
| 5 | Resolve row-flip sign and engine blend `Replace`/`Smooth` before claiming shape fidelity | Both UNVERIFIED | DPATTERN `:120-124,348-382`; `game.gd:116-117,1109` |
| 6 | Reconcile the global clamp `:1228` (see §1.4) for the newly decapitated caps | plateau caps up to +3.793 effective | derived from DPATTERN `:153-157` |
| 7 | Mountains: add 3D props (`terrainmesh1..4.osm` → derived glTF), **not** a height grid | Mountain grids all-zero | DPATTERN `:168-169`; DTRN_02 C8/C9 `:104-105`, §8 Step 4 `:394-399` |
| 8 | Map native pattern extent instead of the scaled `st.cells` bbox (`game.gd:1024-1027,1046-1047`) | Donor stamp extent engine-side | RELIEF-LIVE-FIX-01 §4 `:212-221`; DPATTERN `:302-346` |

### 2.4 Grids that exist on donor disk (observed: filesystem + DPATTERN table)

`C:\Games\Cossacks 3\data\pattern\`:

| Family | Files present | Deep-decoded (26, DPATTERN `:59,142-170`) |
|---|---|---|
| plateau | `plt1`, `plt2`, `plt3`, `plt4_fixed`, `plt5` | all 5 (`:153-157`) |
| plateau_big / plateau_small | `f_plt_big_1/2/3`, `f_plt_mid_1/2`, `d_plt1/2/3/4/5/6` | `f_plt_big_1`, `d_plt1` only (`:158-159`) |
| hills_dark / hills_light | `hil1/2/3/4`, `g_hil1/2/3/4/5/6/7/8/9` | `hil1-4`, `g_hil1,2,4,9` (`:160-167`) |
| ravine_medium / ravine_big | `k_ravine_1/2/3/4/5/6/7/8/9`, `k_ravine_big_1`, `k_ravine_big_stone_1..8` | `k_ravine_1..9`, `k_ravine_big_1`, `k_ravine_big_stone_1` (`:142-152`) |
| mountains | `g_mnt_1/2/3/4/5/6/7` | `g_mnt_1`, `g_mnt_3` — all-zero (`:168-169`) |
| plain_huge | `big_hill_1` | not in the 26 (grid **UNVERIFIED**) |

**observed:** 710 `.pattern` files inventoried, 26 deeply decoded (DPATTERN `:59`). Files present but not decoded have **UNVERIFIED** float windows; do not assume they decode.

---

## 3. Q3 — test*/rock* tiles on flat cells

### 3.1 Donor rule or port bug? — DONOR RULE (observed donor lines)

| Mechanism | Port | Donor | Verdict |
|---|---|---|---|
| Bitmap detail pass | `_apply_detail_pass` `game.gd:1911-1935`: h only **selects** bitmap (`:1927-1930`, `h < 0.1`), `tex = R div 2` (`:1933`), written only on cells still `grass1` (`:1925`, `:1934-1935`) | `loadtextureterrainfrombitmap.inc:4` `cLowHeight=0.1`; `:25-29` h selects low/high bitmap; `:32-36` `GetBitmapPixel` then `tex := r div 2`; `:37-42` only if `GetTileIndex=0` | **observed**: byte-equivalent rule. No height gate on the resulting tile id → `test*` can and does land on flat `h<0.1` cells by donor design. |
| Smoothing chains | `_tb_pick` `game.gd:2125-2142`; `_tb_smooth_pair` `:2144-2205`; `_smooth_tilemap` `:2207-2214` (3 passes). **No height read anywhere.** | `smoothtiles.inc:191-234` works purely on `atilemap[i,j]` via `GetNeighbourTiles` (`:203-213`, `:221-231`), called with 3 passes at `:237`, written at `:240-242`. **No height read.** | **observed**: port reproduces the height-blind donor rule. |
| `test7/8/9`, `rock4/8` as chain members | `game.gd:1560` (`rock9/8/5` SumProb 0), `:1568,1576,1584` (`test8` J=4), `:1577,1607` (`test7` J=5), `:1592,1603` (`rock8` J=1), `:1633` (`test8:0.4/test7:0.6`) | `tilesmooth_scripts.cfg:58` rock8, `:90` rock4, `:166,262,354` test8, `:270,604` test7, `:370,491` test9 | **observed**: ids are donor-authored chain entries, not port-invented speckles. Port comment at `game.gd:1959-1961` explicitly removed old random `test7/8/9` speckle behaviour. |

**verdict:** `test7/8/9` on flat cells are **donor-rule** (bitmap `tex = R div 2` + donor height-blind smoothing), **not a port bug**. **inferred:** their bright speckle art (TERRAIN MARKS 01 `:100`) is the plausible source of "pale marks"; refuted for the flat P0 fixture (`:99-103`).

### 3.2 Are rock8/rock4 height-gated correctly? (locally yes; not final authority — donor too)

| Check | Result | Evidence |
|---|---|---|
| Threshold literals | `game.gd:2104` `absf(h0)>2.7 → rock8`; `:2106` `>2.4 → rock4`; `:2108` `<0.1 → ""` | Matches `donor: texturemap.inc:594-601` verbatim — **observed** |
| Gradient/orientation gate | `game.gd:2079-2087` 4-neighbour `dir_x/dir_y`, early return if both <0.01 (`:2085-2086`) | Matches `donor: texturemap.inc:433-447` (`len>0.01`) — **observed** |
| Cell set | `game.gd:2112-2123` applies only where `terrain==5`; `terrain=5` is set exactly where donor `cDiff1/cDiff2` steep tests fire (`game.gd:1248-1262`) | **derived**: port `terrain==5` is the collision-tag proxy (DTRN_02 C12 `:108`); faithful |
| Final authority | `_apply_shore_cliffs()` runs at `game.gd:2016` **before** `_smooth_tilemap()` at `:2026`; smoothing is height-blind (`:2144-2205`) | **derived**: rock ids can be inserted/overwritten on flat cells by smoothing. RELIEF-LIVE-FIX-01 `:77-80` grades the earlier "rock ids impossible on flat land" claim **overstated**. Same is true in the donor (`smoothtiles.inc:191-234`) ⇒ **donor-faithful**, not a port defect. |

### 3.3 The "maze" look — cause chain (observed measurement + inferred attribution)

| Cause | Quantification | Evidence |
|---|---|---|
| Tile-id concentration from donor bitmaps | Pre-change live histogram top-5 = **73.0%** (`grass_ground1` 28,535; `grass1` 15,993; `grass_ground3` 15,962; `test8` 7,667; `test7` 6,691); `test7+8` 14.0%; `test9` 2,229 | V3D_02 P1 `:86`; TRN_DATA `:47-51` |
| After TRN-DATA smoothing/forest fix | Offline replay top-5 = **58.52%**; `test7+8` **14.89%**; `test9` **0.84%**; combined 15.72% | TRN_DATA `:54-64`; exact live histogram **UNVERIFIED** (`:85`) |
| Why `test7+8` stays ≈15% | Donor `tile_lowground.bmp` R=156/158 ⇒ `tex` 78/79 ≈30% of low-ground pixels; reducing further requires replacing donor bitmap bytes (forbidden) | TRN_DATA `:64`; ids 78/79 confirmed `presets_summer.json:80-81` (V3D_02 `:86`); `test9`=80 (`presets_summer.json:82`) |
| Art duplication | `grass_ground1`/`grass_ground3` block PNGs byte-identical | V3D_02 `:86` |
| Amplifier (shader, different owner) | Eye-plane UVs make texgen camera-dependent; 1 m `fract` repeat | V3D_02 P2 `:87`, F1 `:124` — **inferred** contributor, not measured here |

**derived:** "maze" = a few dominant near-identical art families + high transition-id share + camera-dependent UV. No single height/tile bug; the dominant tile-data share is donor-authored.

### 3.4 Minimal fix levers (labelled; with measurable effect + cheap verification)

| Lever | Exact lines | Effect | Fidelity |
|---|---|---|---|
| **F0 — no tile-data fix (recommended).** Treat the residual share as donor-authored; address V3D_02 F1/F4 in shader/atlas owners | none in `game.gd` | preserves donor tile bytes | **donor-faithful**; visual result UNVERIFIED without A/B |
| **F1 — port-approx test suppression.** In `_apply_detail_pass`, after `game.gd:1933`, skip the write at `:1934-1935` when `tbl_names[tex]` is `test7`/`test8`/`test9` (fall back to `grass1`) | `game.gd:1933-1935` | Offline-derived: `test7+8` 14.89% → ~0, `test9` 0.84% → ~0; top-5 falls below 58.52% but `grass1` rises (may worsen uniformity) | **NOT donor-faithful** — overrides donor `tex = R div 2`; do not present as parity |
| **F2 — port-approx rock height gate in smoothing.** In `_tb_smooth_pair` before each write at `game.gd:2191-2205`, reject a picked `rock8` if `absf(height[cell])<=2.7` and `rock4` if `<=2.4` | `game.gd:2191,2193,2195,2197,2199-2205` | rock4/rock8 on `|h|<=2.4` cells → 0; changes tile histogram only | **NOT donor-faithful** — donor smoothing is height-blind (`smoothtiles.inc:191-234`); F2 is a deliberate deviation, UNVERIFIED |
| **F3 — faithful clamp-order tidy.** Ensure cliff tiles are assigned from the *final* height field: `_shape_stamp_relief()` already runs at `:1209` before `_apply_shore_cliffs()` at `:2016` | `game.gd:1209,2016,2022,2026` | no histogram change; guards against future reordering | **donor-faithful** (donor order TextureMap → bitmap → SmoothTiles, TRN_DATA `:25`) |

**Cheap dump-map verification (no Godot run needed beyond the dump):**
1. Use `main.gd:791-803` `--dump-map`: base64-decode `tileblock` (`main.gd:796`) and `height` (`main.gd:795`), both row-major `y*MAP_W+x` (`game.gd:1931-1932`).
2. Histogram ids `78/79/80` (`test7/8/9`; `presets_summer.json:80-82`) and `rock4`/`rock8` ids via `tbl_idx`; cross-tab against `absf(height)`. Assert F1 ⇒ counts of 78/79/80 ≈ 0; F2 ⇒ `rock4/8` cells with `|h|<=2.4` = 0.
3. Assert unchanged `terrain`/`blocked`/`meta.stamp_counts` bytes (TRN_DATA `:69`: tile-only edits preserve all other streams).
4. Read `meta.relief_grid.applied_cells` (`game.gd:1101-1110`) to confirm the relief path state; do **not** conflate with `stats.relief_grid.applied` (RELIEF-LIVE-FIX-01 `:256-259`).

---

## 4. Verdict and open questions

| # | Question | Answer |
|---:|---|---|
| 1 | Is ±2.964 donor-grounded? | **derived/UNVERIFIED**: matches the observed baked `.map` envelope (DTRN_02 `:106`) and authoring constants (`generatemap.inc:4,6`), but no donor height clamp exists in plaintext; port bound is port-only (RELIEF-LIVE-FIX-01 `:117-123`). Decapitation of `plt2` +3.6134 is real at `game.gd:1228` but consistent with baked maps. No donor-faithful removal. |
| 2 | Which relief runs normally? | **observed/derived**: live analytic fallback (`game.gd:1056-1099`); donor-grid branch (`game.gd:1039-1055`) is wired but never exercised by the available fixture (`applied_cells=0`); render-side donor grid flag off by default (`main.gd:802-803`). |
| 3 | Are test*/rock* on flat cells bugs? | **observed**: donor rule for both bitmap ids (`loadtextureterrainfrombitmap.inc:26-42`) and smoothing (`smoothtiles.inc:191-234`); rock thresholds match donor (`texturemap.inc:594-601`), but smoothing is height-blind in donor too — not a port bug. |

**UNVERIFIED (do not guess):** whether any seed places `plt2`; donor engine blend `Replace`/`Smooth` and row-flip sign; donor final clamp mechanism; live post-TRN-DATA histogram; whether the visual "maze" changes with F1/F2; any donor GPU A/B / parity.

*End of Z2-HEIGHT-TILES. Read-only; one file written; no code/asset/config/test/Godot/git/donor modification; no parity claim.*
