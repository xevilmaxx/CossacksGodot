---
id: H07
ticket: "HEIGHTMAP WAVE follow-up — H07: minimal data-only 3D reuse of G22's 2D findings to raise large-scale organic variation"
wave: WAVE G follow-up (H follow-up)
owner: H07 (read-only / proposal-only)
created: 2026-11-25
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_RUNNER_JOB__NO_GODOT__NO_CODE_OR_ASSET_EDIT
charter: docs/terrain_swarm_2026-11-25/CHARTER.md
board: docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
scope: "This report is the ONLY repo file written. No Godot process, no runner job, no status/queue mutation, no .gd/.gdshader/asset/config/test/JSON edit, no git write. All source facts are read from the current tree; all similarity claims are labelled INFERRED or UNVERIFIED."
labels: [observed, derived, inferred, UNVERIFIED, PORT APPROX]
parity_guard: "DONOR PARITY STAYS UNVERIFIED (CHARTER §3/§5). No donor GPU A/B frame exists. Every '2D looks like donor' or 'this could raise organic variation' statement below is INFERRED (visual reading) or UNVERIFIED (no A/B frame); no parity, equivalence or 'closer by N%' verdict is issued."
owner_file_note: "variant3d/scripts/game.gd is B03's file. COORD grants ownership only AFTER G04 finishes. H07 proposes hunks only; it does not edit, and it does not grant itself an owner."
sources_read:
  - docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
  - docs/terrain_swarm_2026-11-25/CHARTER.md
  - docs/terrain_swarm_2026-11-25/reports/G22_2d_vs_3d.md
  - docs/terrain_swarm_2026-11-25/reports/A10_regression_constraints.md
  - docs/terrain_swarm_2026-11-25/reports/H03_heightmap_hypothesis.md
  - docs/terrain_swarm_2026-11-25/reports/A11_reference_metrics.md
  - docs/terrain_swarm_2026-11-25/reports/G05_visual_review.md
  - docs/terrain_swarm_2026-11-25/reports/A04_tile_diversity.md
  - docs/terrain_swarm_2026-11-25/reports/G04_gate_log.md
  - variant3d/scripts/game.gd
  - app/scripts/game.gd
  - variant3d/scripts/world3d_terrain.gd
  - variant3d/shaders/terrain_tileindex.gdshader
  - app/scripts/world.gd, variant3d/scripts/world.gd
  - variant3d/tests/t_combo_all.gd, variant3d/tests/t_terrain_only.gd
---

# H07 — minimal data-only reuse of 2D terrain findings in 3D

## 0. Verdict, with labels

**RECOMMENDED MINIMAL CHANGE: option (a), the pass-order flip in `variant3d/scripts/game.gd`, as a pinned-seed A/B only.** It is the only one of the three options that is purely a change to which donor tile ids `game.gd` writes: no atlas repack, no mesh/topology/UV2 change, no shader or sampler change, no new node, and no synthetic field. [D: from the code reads in §2–§5.] Whether it actually raises large-scale organic variation is **UNVERIFIED** — no A/B frame exists.

**Option (b), per-cell blend attribute extension, is REJECTED for H07.** It needs a new mesh attribute (B04's file), a shader varying/sample change (B01's file) and a new data source (B03's file), i.e. three owners and a shader-path change; G22 itself calls it an *extension* of the tile-index architecture (`G22_2d_vs_3d.md:135`). It is **INFERRED** feasible, **UNVERIFIED** for seams/perf, and outside "minimal data-only".

**Option (c), face collar/decal overlays, is REJECTED for H07 but kept as a strongest-candidate future ticket.** It leaves the tile index, atlas and terrain sampler contract untouched, but it is not data-only (new nodes/materials/draw calls) and has unreviewed z-fighting/season risk. **INFERRED** to be the most direct transfer of G22's `w55_zoom_out.png` finding; **UNVERIFIED** visually and for gates.

**INFERRED (visual, not parity):** of G22's three reuse routes, the pass-order flip is the cheapest to test; the compositing/collar routes are the ones G22 associated with the 2D frames' donor-like structure. **UNVERIFIED:** that any of them moves the A11 BV32 target on the *current* tree — G04's fresh capture never ran (`G04_gate_log.md:25-58`), so the only 3D image available is the pre-fix 11:41 stub (`G05_visual_review.md:45-53`).

No test was weakened, no threshold lowered, no runner job submitted, no Godot launched, no code/asset edited.

---

## 1. What G22 established and what H07 may reuse

G22's reusable findings, quoted with their own labels:

1. **2D asset parity is already present.** `app/assets/terrain/blocks/*.png` (112 donor block PNGs, 1024²) are byte-identical to `variant3d/assets/terrain/blocks/` (example SHA256 prefixes in `G22_2d_vs_3d.md:113`); `decals_png/` (924 PNGs) and `dmask/` likewise exist in both trees (`:121`). **OBSERVED** file facts. **No new donor bytes are needed**; adding any is out of scope (`G22:137`; `CHARTER.md:60`, S-25-09).
2. **2D compositing recipe:** mirror-tile to seamless 1024², one-time `adjust_bcs(1.0, 1.12, 1.0)` per block (`app/scripts/world.gd:1012-1034`, assembly `:817-836`), exact per-cell coverage grids written into a mask **alpha** channel and upscaled **bilinearly**, then `blend_rect_mask()` (`world.gd:1084-1093`, `:1211-1253`, `:838-854`). **OBSERVED.** The bilinear cross-fade at name borders is the only anti-aliasing (`:116`).
3. **Opposite pass order:** 2D runs `_smooth_tilemap(brng,3)` **then** `_apply_detail_pass()` (`app/scripts/game.gd:1682` vs `:1689`); 3D runs `_apply_detail_pass(brng)` **then** `_smooth_tilemap(brng,3)` (`variant3d/scripts/game.gd:2039` vs `:2067`). **OBSERVED** in the current tree (re-verified this ticket). Which order is donor-correct is **UNVERIFIED** (`G22:125`).
4. **Detail bitmap is donor data, not noise:** `tile_lowground.png` / `tile_highground.png` R byte selects a tile id (`_apply_detail_pass`, `variant3d/scripts/game.gd:1913-1952`; H03-E10/H03-E8). Reusing it is permitted; inventing a noise field is not.
5. **Variation lives in transition blocks, not `grass1`:** measured BV32 `grass1.png` 8.1 vs `grass_ground1/3.png` 58.2, median of 112 blocks ≈22.2 (`G22:114`). **OBSERVED.** A field dominated by one id stays flat regardless of atlas richness.
6. **3D is already under-varied in data:** pre-TRN-DATA 320² histogram `grass_ground1` 28,535 cells / `grass_ground3` 15,962, top-5 73.09% (`A04_tile_diversity.md:80`); offline post-TRN-DATA top-5 58.52%, distinct 31→32 (`:104`). Live post-B tile histogram is **UNVERIFIED** (`:75-76`).

**Similarity claims:** "2D frames look structurally closer to the donor stills than the 3D stub" = **INFERRED** (`G22:31`); "2D composited grass has donor-like multi-scale mottling" = **INFERRED** (`G22:95`); "donor parity" = **UNVERIFIED** everywhere.

---

## 2. Frozen acceptance baselines (read-only, from A11 / G05)

All numbers in this section are **OBSERVED** measurements made by those tickets on `p0fresh01/p0_final_formula.png` (1280×720, timestamp 11:41:11, pre-fix P0 stub). They are the BEFORE arm **only if** the same stub protocol is re-run; the current tree's appearance is **UNVERIFIED** (`G22:37,145`; `G05:77-92`).

| Metric | Frozen baseline | Donor reference band | Source |
|---|---:|---:|---|
| **BV32 n640** (headline structure metric) | **8.7** | **247.6** median (n=10), ref A **205.0**; target band **≈150–270** | `A11:133,167-171` |
| BV32 native | 9.9 | 141.1 median / 144.1 ref A | `A11:129,141` |
| BV8 / BV16 / BV64 n640 | 12.6 / 10.1 / 6.5 | 319.7 / 292.0 / 159.0 | `A11:131-134` |
| `grad n640` (fine grain) | **5.00** | 1.30 median → target **1–2** | `A11:137,172-177` |
| luma std | **10.6** | 20.1 median → target **18–22** | `A11:135,178-181` |
| HSV saturation mean | 0.675 | 0.529 median (secondary only) | `A11:136,183-186` |
| BV128 `between_block_var`, full frame | **6.957941** | donor median **222.977013** | `G05:211,244,274-275` |
| BV128 `between_block_var`, crop `120,60,1040,580` | **4.417590** | — (same crop both arms) | `G05:257-264,317` |
| `std_luma` / `std_saturation` | 10.595727 / 0.029662 | 35.017412 / 0.189215 | `G05:238-239` |
| `row_periodicity` / `tile_period_px` | 0.688919 / 64 | 0.232149 / 7 median | `G05:219-220,253-255` |
| `non_black_fraction` / `full_width_dark_rows` | 1.0 / 0 | gates: >0.9 / ==0 | `G05:268-269`; `A10:96-98` |

A genuine improvement moves BV32/BV128, `std_luma`, `std_saturation` **up** and `grad`, `row_periodicity`, `tile_period_px` **down**, with the same crop on both arms. These are **movement indicators, not thresholds and not a fidelity gate** (`G05:325-328`; `A10 §3` T5 protocol).

**Hard gates that must stay green** (all are structural/PORT APPROX, never donor truth; `A10 §1-§4`): selftest **29/29**, uitest **17/17**, `t_render_mode` 2D default, `assert_clean` CLEAN, 1 surface / 4096 verts / 7938 tris / 4096 UV2, `uv2_x ∈ [0,123]`, `uv2_y ∈ {0,1,2}`, `flat_grid_promoted == 0`, `tileblock_index_preserved`, `uv2_x_summer_winter_identical`, `uv2_x_desert_remap_consistent`, `ground_mean_luma >= 40`, `ground_max_luma >= 100`, `nonblack > 0.9`, `full_width_dark_rows == 0` and `dark_cols == 0` in C4, `height_at_world` within 0.001 m and entity Y within 0.02 m. **No threshold may be lowered to make an A/B pass.**

---

## 3. Option (a) — RECOMMENDED: pass-order flip, data-only, pinned seed

### 3.1 Mechanism and honest ceiling

- Change only the order of two calls in `_assign_tileblocks()` so 3D matches the 2D call order in `app/scripts/game.gd:1682,1689`. The detail bitmap remains the same donor-derived source; no id outside `presets_summer.json`, no new RNG family, no new asset. [D: `variant3d/scripts/game.gd:1913-1952,1957-2085`.]
- **INFERRED:** applying donor bitmap ids as *final* cells (2D order) instead of letting 3-pass smoothing reconcile them (3D order) may produce larger coherent mottled regions from the bitmap's authored spatial structure; `A04 §2-§3` shows smoothing preserves `|Δ|=1` neighbours and cannot diversify interiors. **UNVERIFIED:** it may instead *reduce* detail coverage (cells changed to non-`grass1` by smoothing are skipped by `_apply_detail_pass` at `:1927`) and leave unsmoothed transition borders. The A/B, not this reasoning, decides.
- **Ceiling:** this cannot make 2D's bilinear per-cell cross-fade (`world.gd:1211-1253`) — the shader still samples one atlas cell per 2 m (`terrain_tileindex.gdshader:392`) and still folds mask into RGB (`:427`). So even a positive result stays **INFERRED** as "structurally closer", never parity.

### 3.2 Exact hunks — PROPOSAL ONLY, do not apply before COORD's grant

Owner file after grant: **`variant3d/scripts/game.gd`** (currently B03's; `WAVE_G_CHARTER.md:20,68`, H07 grant rule). Backup before edit: **`inbox/backup/game.gd.bak-H07`** (`CHARTER.md:66`; convention confirmed in `inbox/backup/`).

Hunk A1 — remove the pre-smooth detail call (current lines 2034–2039):

```diff
--- a/variant3d/scripts/game.gd
+++ b/variant3d/scripts/game.gd
@@ -2032,9 +2032,3 @@
 	# 2) oriented shores + cliffs (donor texturemap.inc 8-sector tables)
 	_apply_shore_cliffs()
-	# 3) donor detail variety (loadtextureterrainfrombitmap.inc): cells still
-	# on the default block get their TileBlock from the low/high-ground
-	# bitmaps (R div 2), picked by height.  Donor order is TextureMap ->
-	# bitmap base -> SmoothTiles (DTRN-01 §4 / RV-TRN-02 §4.4), so the
-	# detail tiles are reconciled too instead of being left as final cells.
-	_apply_detail_pass(brng)
 	# B03-P2 (PORT APPROXIMATION, A04 §6 P2): restore the donor's
```

Hunk A2 — insert after `_smooth_tilemap(brng, 3)` (current line 2067), before forest borders:

```diff
@@ -2064,6 +2058,12 @@
 	# 4) exact 3-pass SmoothTileMap (donor smoothtiles.inc:191-237): three
 	# passes, horizontal then vertical, over the FINAL tile field before UV2.
 	# TRN-DATA: the donor rule table now covers all 118 active lists.
 	_smooth_tilemap(brng, 3)
-	# 5) forest-border stamps (donor smoothforestborders.inc: grass5/rock9
+	# 5) H07-A (PORT APPROXIMATION, A/B only): donor detail-bitmap pass moved
+	# AFTER SmoothTiles, matching the 2D shipping order
+	# (app/scripts/game.gd:1682 smooth, :1689 detail). Which order is
+	# donor-correct is UNVERIFIED (G22 §5.4). Data-only: tile ids only — no
+	# shader, atlas, mesh, UV2 or sampler change. Pin seed/camera/zoom/biome.
+	_apply_detail_pass(brng)
+	# 6) forest-border stamps (donor smoothforestborders.inc: grass5/rock9
 	# tiles + bushes at edge cells with exactly one forest neighbour)
```

No other hunk. The B03-P2 `tls_*` ground1 stamps (`:2051-2063`) stay **before** smoothing, so their borders remain reconciled; the mine-apron final authority (`:2074-2076`) still runs last. Winter names are regenerated from the new `tileblock` at `:2081-2085`; desert remapping is derived at mesh build, so no season dictionary or remap hunk is needed. [D: read of `:2051-2085`.]

### 3.3 A/B protocol — G04 / COORD only

1. Pin `Data.RANDOM_SEED` (e.g. `20261113`, the A04 dump seed) and **hold constant** camera pose, zoom, window size, `BIOME`, `RELIEF`, map size and capture crop. `brng` is its own stream seeded `int(Data.RANDOM_SEED)+7` (`:1970`), so terrain/blocked/res_nodes/mapgen stay byte-identical; **only tileblock bytes change** [D]. Do not pin by editing source — set the seed in the harness/dump.
2. ARM A = current tree (backup kept). ARM B = H07-A hunks applied. **No third axis changed** — this is not a T5 multi-axis A/B (`A10 §3` T5).
3. Only G04 submits jobs (`WAVE_G_CHARTER.md:31`), one Godot at a time, unique ids. Same capture command/crop on both arms; record exact PNG paths and timestamps as separate provenance-labelled arms (`G05:353-362`).
4. Compare with `python variant3d\tools\terrain_ab_metric.py ... --crop 120,60,1040,580 --json` plus the A11 BV32 metric definition (`A11 §1, §8`). Compute a 64² stub, a real 320² map, and the live tile histogram (`world3d_terrain.gd:1650,1747-1751`).
5. **Ship rule:** B ships only if BV32 n640 / BV128 moves toward the §2 band *and* all §2 hard gates stay green. If BV32 does not move, revert from backup — do not lower a threshold or add a noise field to force it.

### 3.4 Acceptance metrics for (a)

Primary: **BV32 n640** 8.7 → up toward ≈150–270 (ref median 247.6 / ref A 205.0); **BV128 between_block_var** 6.957941 full / 4.417590 crop → toward 222.977013 band. Secondary: `std_luma` 10.595727 → 18–22; `std_saturation` 0.029662 → toward 0.189215; `grad n640` 5.00 → 1–2; `row_periodicity` 0.688919 → toward 0.232149. Guard: `non_black_fraction` 1.0 stays >0.9; `full_width_dark_rows` 0 and `dark_cols` 0; `ground_mean_luma >= 40`, `ground_max_luma >= 100`; histogram top-5 / distinct-id compared with A04's 58.52% / 32 offline baseline; identical histograms across two runs of the pinned seed. All deltas are **movement indicators, PORT APPROX, not donor parity**.

---

## 4. Option (b) — per-cell blend attribute extension: evaluate, REJECT for H07

### 4.1 What it would take (illustrative only — do not apply)

Data source must be donor-derived, not synthetic: e.g. pack a coarse per-cell blend id + weight from the already-available detail bitmap R or `relief_smooth[]` into a new vertex attribute. This touches three owner files after separate COORD grants: `game.gd` (B03), `world3d_terrain.gd` (B04), `terrain_tileindex.gdshader` (B01). Backups: `inbox/backup/game.gd.bak-H07B`, `world3d_terrain.gd.bak-H07B`, `terrain_tileindex.gdshader.bak-H07B`.

```diff
--- a/variant3d/scripts/world3d_terrain.gd   (illustrative; B04's file)
@@ -1371,6 +1371,7 @@
 	var verts := PackedVector3Array()
 	var norms := PackedVector3Array()
 	var uvs := PackedVector2Array()
 	var uvs2 := PackedVector2Array()
+	var blends := PackedFloat32Array()   # must be filled from a donor-derived source
@@ -1504,6 +1505,7 @@
 			uvs2[i] = Vector2(float(tid), float(face))
+			blends[i] = <donor-derived blend value>   # PORT APPROX, no synthetic noise
@@ -1520,7 +1522,8 @@
 	arrays[Mesh.ARRAY_TEX_UV] = uvs
 	arrays[Mesh.ARRAY_TEX_UV2] = uvs2
+	arrays[Mesh.ARRAY_COLOR] = <rgba carrying neighbour id + weight>
 	arrays[Mesh.ARRAY_INDEX] = inds
```
```gdshader
// illustrative, B01's file — new varying + second tile_rgb() sample in fragment()
varying float v_blend;                 // from COLOR.a; atlas samplers UNCHANGED
vec3 rgb = mix(tile_rgb(v_tile, local), tile_rgb(v_neighbour, local), v_blend);
```

Contract check: the three sampler uniforms (`:60,66,72`), `atlas_grid` (`:91`), `mask_to_alpha` (`:235`) and the fold (`:427`) can remain; UV2.x/y semantics are untouched (`world3d_terrain.gd:1507`, `t_combo_all.gd:688-690`). But this **adds a vertex attribute and a second per-fragment atlas sample**, so it is **not** "data-only" and it *extends* the tile-index architecture (G22:135). The exact Godot attribute enum / `COLOR` availability and shader varying path are **UNVERIFIED** here (no Godot run).

### 4.2 Evaluation

- **Potentially addresses the real ceiling:** G22 identifies the missing bilinear cross-fade as the structural difference (`G22:116,135`). **INFERRED** feasibility, **UNVERIFIED** that it avoids seams.
- **Risk:** second atlas sample per fragment (P05 shader-cost), seam/z-fighting at cell borders, `full_width_dark_rows`/`dark_cols` and luma-floor flips, season atlas swaps must keep the extra attribute consistent, three disjoint owners and a multi-file backup, no donor rule for blend id/weight (**PORT APPROX**, CONFIRMED_UNVERIFIED).
- **Verdict:** not minimal, not data-only, multi-owner. Defer to a dedicated ticket with COORD-granted owners and a G04 perf/seam A/B.

---

## 5. Option (c) — face collar / decal overlays: evaluate, REJECT for H07

### 5.1 What it would take (illustrative only — do not apply)

Source functions already exist in both trees (byte-identical donor art, G22:113,121): `world.gd:1400-1532` `_face_collar()` (height-gradient grid, `rock8.png` face fill, lit/shadow ramp, stretched `rock1.png` flutes, ≤3 px grass rim), `world.gd:731-739` `_bld_decal()`, `world.gd:2529-2540` `_field_decal()`, `_alpha_mask()` `:1086`, `_composite_blocks()` `:1218`. Proposed 3D form: a **separate** `MeshInstance3D` overlay built from `height[]` gradients with `rock8/rock1` and `decals_png`/`deco_png` textures, at a small world-Y offset, driven by a new disjoint script (e.g. `variant3d/scripts/world3d_terrain_overlay.gd`). No terrain shader sampler, atlas, UV2 or tile-index change.

```gdscript
# illustrative new file; owner TBD by COORD (do not touch world3d.gd without grant)
var overlay := MeshInstance3D.new()   # < CELLS vertices: see gate note below
overlay.mesh = _build_face_collar_mesh(game.height, MAP_W, MAP_H)
overlay.position.y += COLLAR_EPS      # PORT APPROX — z-fighting UNVERIFIED
world3d.add_child(overlay)            # season tint / decal paths must follow BIOME
```

Gate note: `t_combo_all.gd:441-456` counts only ArrayMesh nodes with exactly `CELLS` (4096) vertices for `single_terrain_mesh`/`no_new_seam_class` (`:634`, `:1018-1022`), so a sub-4096-vertex overlay does not by itself fail those checks. **UNVERIFIED** for the capture's dark-row/col predicates and for the season atoms.

### 5.2 Evaluation

- **INFERRED:** this is the most direct transfer of what G22 read as donor-like in `w55_zoom_out.png` (grey ravine walls, rock flutes, grass rim, decals) and would add structure the tile-index shader cannot produce (`G22:120-121,136`). **UNVERIFIED:** no matched-camera frame.
- **Risk:** new draw calls/nodes (P02/P07 audits), z-fighting and seams, season/decal path consistency, shadow flags must stay OFF (`A10:86,297-298`), water/shore interaction (`A10:88-90`), owner grant for `world3d.gd` if wiring is needed, and **not data-only**.
- **Verdict:** strongest *future* visual ticket, but rejected for the H07 minimal data-only mandate. Backups if it ever lands: `inbox/backup/world3d.gd.bak-H07C` (only if that file is granted); new overlay file needs none.

---

## 6. Consolidated risk register for (a) [recommended]

| # | Risk | Evidence / label | Mitigation |
|---|---|---|---|
| R1 | RNG stream shift: `_apply_detail_pass` consumes `brng` for B03-P1 re-rolls (`:1943-1950`); moving it changes every later smoothing/border draw. Deterministic per seed, but tileblock bytes change. | **D** from `:1970`, `:1943-1950`, `:2263-2270` | Pin seed; never change several axes at once; record tile histogram on both arms (`A10 §3` T5). |
| R2 | Reduced detail coverage: smoothing may convert `grass1` cells before detail runs; `_apply_detail_pass` skips non-`grass1` (`:1927`). Direction of BV32 change is unknown. | **D**, effect **UNVERIFIED** | A/B decides; revert if BV32 does not rise. |
| R3 | Unsmoothed transition borders from detail ids (no second smooth, matching 2D comment at `app/scripts/game.gd:1686-1688`). | **I** | Watch `dark_rows`/`dark_cols`, luma floors, `no_new_seam_class`; do NOT add smoothing back without new ticket. |
| R4 | Season invariants: winter UV2.x identity and desert 1:1 remap must still hold after tileblock changes. | **O** constraints `A10:124-126` | Re-run season atom; no dictionary/remap edit in this hunk. |
| R5 | Histogram baseline is stale: no live post-B histogram exists (`A04:75-76`); G22's 3D image is pre-fix (`G22:37`). | **O/U** | Capture fresh A arm; compare only A vs B, never against the 11:41 stub as if current. |
| R6 | No donor parity can be established; every similarity reading is INFERRED. | **U** (`CHARTER §3,§5`) | Label all claims; no "closer by N%" verdict. |
| R7 | Ownership: `game.gd` is B03's until G04 finishes and COORD grants. | **O** (`WAVE_G_CHARTER.md:20,68`) | Proposal only; no edit, no self-grant. |
| R8 | Runner hygiene: G04 was blocked at pre-flight with stale ticket 582 (`G04_gate_log.md:25-58`); re-running a failing row to force green creates DIRTY (`A10:158-162`). | **O** | G04 alone checks `status`, uses unique ids, no rerun-to-green. |
| R9 | Guard S-25-09: do not "help" the flip with a noise/dither field. | **O** (`CHARTER.md:60`, `A10:234`, `G22:137`) | No new texture, no hash field, no invented donor constant. |

---

## 7. Guardrails and hand-off

- No donor parity claim; donor GPU A/B frame does not exist (`CHARTER.md:57-58`; H03 §4).
- H03's hypothesis is **refuted as stated** (`H03_heightmap_hypothesis.md:210-214`): no layer is both a donor height source and drawn as albedo. H07 therefore does **not** propose routing anything to a height input; it reuses only the documented tile-id/compositing findings.
- Read-only/proposal-only while G04 runs gates; COORD grants one owner per file after G04. Backup before any edit. `app/` untouched.
- Only G04 submits runner jobs; no Godot was launched by H07.
- One repo file written: this report. No code, asset, config, test, JSON, queue or git change.

## 8. Similarity-claim ledger (explicit labels)

| Claim | Label | Basis |
|---|---|---|
| "2D shipping renderer looks structurally closer to donor stills than the 3D stub" | **INFERRED** | G22:31 (visual reading, different scenes/cameras) |
| "2D composited grass has donor-like multi-scale mottling" | **INFERRED** | G22:95; BV32n 669.2 vs donor 219.4 is a measured ratio, the *resemblance* is inferred |
| "Pass-order flip could raise large-scale organic variation" | **UNVERIFIED** | No A/B frame; §3.1 mechanism is inference only |
| "2D bilinear alpha cross-fade explains its mottling" | **INFERRED** from code; **UNVERIFIED** visually | G22:116,135; no donor GPU A/B |
| "Face collar/decals make cliffs read donor-like" | **INFERRED** | G22:120-121,136 |
| "Current-tree 3D appearance is flat/olive" | **UNVERIFIED** | Only pre-fix 11:41 frame exists (G05:45-53; G22:145) |
| "Donor parity of any proposed change" | **UNVERIFIED** | No donor GPU A/B frame anywhere in the session |
| "Byte-identical donor blocks/decals already in 3D tree" | **OBSERVED** | G22:113,121 file comparison; no similarity inference needed |

---

*End of H07 report. Read-only; one report file; no Godot, no runner job, no code or asset edit; donor parity UNVERIFIED.*
