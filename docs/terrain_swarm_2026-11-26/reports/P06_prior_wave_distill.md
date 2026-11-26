---
id: P06
ticket: "TERRAIN-SWARM-2026-11-26 / P06 — distill the 2026-11-25 terrain investigation for the donor-first fresh implementation"
owner: P06 (read-only distillation subagent)
created: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_RUNNER__NO_CODE_EDIT__NO_DONOR_ACCESS
scope: "READ-ONLY. Scanned ~166 reports in docs/terrain_swarm_2026-11-25/reports/**, ~271 in docs/coord_swarm_2026-11-25/reports/**, ~162 in docs/coord_swarm_2026-11-24/**, all of docs/t6/**, plus the 2026-11-26 CHARTER.md and SWARM_BOARD.md. Deep-read the decisive reports named in §0. git status/diff used read-only for §5. No donor file opened by this ticket; donor facts are cited from prior read-only reports."
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION"]
parity_guard: "NO DONOR GPU A/B FRAME EXISTS (2026-11-26 CHARTER §2/§5). Every donor statement here is a structural citation of a prior report; every visual attribution is INFERRED or UNVERIFIED. NO DONOR PARITY CLAIM, no PASS claim, no gate claim."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
---

# P06 — Prior-wave distillation: root causes, rejected approaches, confirmed mechanisms, open questions, landed state

## Executive summary

1. **[D] The concentric "rock maze" is not one bug but a four-stage relay, and each stage was fixed in turn.** The original producer was the height-gradient collision pass writing `terrain[i]=5` from the port's own analytic relief; the carrier is `terrain==5` (99.5% reproducible from the dumped height array, radial-profile correlation 0.9996–1.0000) and `tileblock` is only its art (Y01 §2–§5; Y02 §3–§5). After B03/L03 removed that paint, the surviving rings came from `_apply_detail_pass` height-gated detail ids (58.6% of the map, strictly complementary to rock ids; Y01b §8), then from stale Y04 smoothing guards neutralised by Y05's `grass9→test8` swap (Y07 §2–§4), then from L01 spot ids whose per-id alpha patch is dark (Y08 §1–§5). The current tree carries the resulting final-authority collapse (Y08/Y08b) and the rings were **observed absent** in the y08c capture (Y10 E01). Fine diagonal veins are a *separate* symptom: intrinsic atlas albedo (`grass_ground1/2/3`) plus the verbatim 2 m repeat, not a height layer (A03 E03/F03, A02, H03/H05).
2. **[D] Flat relief is amplitude-vs-footprint plus missing donor geometry, not a display misroute.** ±2.964 m over a ~126×164 m cap (~1°) under an `unshaded` donor Blinn-Phong at ≈70° sun gives near-zero shading contrast; verbatim `cDiff=0.5/0.55` face gates cannot fire, so grey `rockNvf/vs` art is never selected; only 2 of 26 donor grids reach height and the donor-active `ravine_big` family has no grid; the donor's actual mountain silhouette comes from `terrainmesh*.osm` props 6.9–9.55 units tall (A05 §3/§4; Z02 §2; Z03 §1–§2). B04's attempt to force the face gates produced the maze and was reverted (B04 §1–§5).
3. **[I] The owner's heightmap-as-albedo hypothesis was decisively refuted twice.** No candidate layer is both a donor height source and drawn as albedo in the port; the only partly-valid observation is that the alpha/alphavert mask is folded into albedo at shader `:427`, but the donor's mask is a `bmTransparency` crossfade weight, never a height input (H03 C1–C4; H05 §1–§4; H04 §1; H01 §2–§4). Routing it into `height[]` would break tile identity, the `mask_to_alpha` A/B and the mesh invariants (H05 §5).
4. **[D] Shore and mill/field/mine are known-but-unlanded donor-grounded gaps.** Water F1–F4 landed (G26 §3) but reflection/bed lighting are off, a non-donor `water_cell` alpha cut exists, coarse swell is zero under `WATER_LEVEL=-0.25`, and no water-bearing capture exists (G26 §4/§6). Donor fields are 49 nodes at 1.6981 **map cells** with `1.3×` decals and 1.528-cell food clearance < spacing (touching), while the port step is half a donor cell and clashes at 3.0 m (F2-02 §3; F2-01 via F2-03 §0/E2); donor mines magnetically snap within 1.5 cells to the nearest ore (F2-02 §4). The port's 2D billboard rotor hub is not the donor mesh-frame hub (M02 §3.3).
5. **[O] The working tree is NOT a clean pre-swarm baseline.** Three source files are modified vs HEAD (game.gd Y08b scoping fix, shader Y10 anisotropy hint, project.godot Y11 anisotropy level 4) plus the whole untracked `docs/terrain_swarm_2026-11-26/`; HEAD already contains B03/L03/Y05/Y07/Y08 relief/tile changes, the Z08 relief-prop module, C01's derived `terrainmesh1..4` assets (now under `obj/shared/terrain/`) and the donor atlas/water/tileindex modules (§5). A fresh donor-shaped module must compose with these, not overwrite them, and `app/` must stay byte-untouched.

> [!IMPORTANT]
> **Labels used below:** **[O]** observed (literal source/bytes/report line, or `git` output read this ticket); **[D]** derived (deterministic consequence of [O]); **[I]** inference without a donor GPU A/B; **[U]** UNVERIFIED. **PORT APPROXIMATION** marks every port-authored substitute. **Donor parity stays UNVERIFIED everywhere.**

## §0 Decisive reports deep-read for this distillation

| Cluster | Reports (all under `docs/terrain_swarm_2026-11-25/reports/` unless noted) | Role in this briefing |
|---|---|---|
| Maze root cause | `Y01_maze_data_proof.md` (+Y01b §8), `Y02_maze_root_cause.md`, `L03_realmap_regression.md`, `Y07_ring_survivors.md`, `Y08_checkerboard.md` (+Y08b §12), `Y10_anisotropic.md`, `Y11_aniso_level.md`, `B03_diversity_impl.md` §9–§11, `B04_relief_impl.md` | §1A, §2, §5 |
| Heightmap hypothesis | `H01_donor_layers.md`, `H02_port_layers.md`, `H03_heightmap_hypothesis.md` (E1–E14), `H04_heightmap_fix.md`, `H05_refutation.md`, `H06_pass_order.md` | §1B, §2, §3 |
| Relief / flatness | `A05_relief_visibility.md`, `Z01_height_data.md`, `Z02_hills_invisible.md`, `Z03_donor_relief_props.md`, `Z04_height_only_design.md`, `Z06_prop_placement.md`, `Z08_impl.md`, `C01_asset_impl.md` | §1C, §2, §3 |
| Tile art / alpha | `A02_alpha_pattern.md` (E1–E11), `A03_atlas_cells.md` (E01–E10), `A04_tile_diversity.md` (cited), `G15_tile_measure.md` (cited), `G25_unverified_register.md`, `G26_water_shore.md` | §1B, §2, §3, §4 |
| Mill / field / mine | `F2_02_donor_fields_mines.md` (F1–F14), `F2_03_fields_fix.md`, `M02_donor_mill.md` | §1E, §3, §4 |
| Donor mechanisms | `docs/coord_swarm_2026-11-25/reports/DTRN_01..06*.md` (cited), `DPATTERN_01_relief_grids.md` (cited), `RV_TRN_02_smoothing_rules.md` (cited); `docs/coord_swarm_2026-11-24/reports/V784_donor_water_shader.md`, `V785_tile_atlas.md`, `V786_tileindex_shader.md` | §3 |
| 2D donor ground truth | `docs/t6/TERRAIN_LANE.md` + `docs/t6/reports/T6-T01..T15.md` (lane status) | §3 (piece-level donor facts) |

Cited evidence ids are preserved verbatim so a later worker can grep them. Line numbers quoted from source are **as observed in the named report at its write time**; re-check before editing (Z04 §0 already warns of ~+15 line drift from in-flight edits).

---

## §1 Definitive root-cause chain of the visual failures

### §1A The concentric rock maze / contour bands (PRIMARY chain, now 4 successive producers)

**Stage 0 — the data proof [O]+[D] (Y01, Y02).**
- 320² seed-20261113 dumps (`app/shots/g32_dump.json`, `app/shots/t6t90_dumps/dump_20261113_a/b.json`, `variant3d/tests/results/w52_self_base.json`) decode to a `terrain==5` mask of **6,967 cells** (6,965 in A/B); `height` is identical across them (SHA prefix `9beb972d7145893f`), `tileblock` differs by 25,333 cells (24.7%) (Y01 §1/§3.1/§4.2). This is the array-level proof of the owner's "same positions, only colour changed".
- `terrain` **carries** the rings (3 dominant 4-connected components of 2,424 / 512 / 479 cells; 40 components ≥8 cells), `height` **drives** them, `tileblock` **paints** them (96.5% of rock tile ids are `terrain==5`; 91.3% of rock cells carry a rock id) (Y01 §2.1/§2.2/§5).
- Re-implementing `game.gd:1240-1264` on the dumped height reproduces **6,932/6,967 = 99.5%** of rock cells; radial ring-profile correlation is **0.9996–1.0000**; the hill/stone `dc` discs at `:846-852` account for only 35 cells (0.5%) (Y01 §3.1–§3.3). Rock mask IoU across dump families is 0.996–1.0000 (Y01 §4.1).
- Y02's independent ranked verdict: **(b) height-gradient rock painting is PRIMARY**, the `near_start` hard step (`game.gd:951-966`, skip at `:1037`) being the dominant ring generator around buildings; **(c) relief height stamps are CONTRIBUTING UPSTREAM only** — `_shape_stamp_relief()` writes `height[]` and **no** tile id or `terrain` write; **(d) atlas art is SECONDARY (colour only)**; **(a) hill/stone dc discs are REAL BUT MINOR**; **(e) alpha mask is RULED OUT as geometry producer** (Y02 §2–§4, evidence rows in Y02 §3).

**Stage 1 — the original producer [O]+[D] (B04, L03, B03 §11).**
- B04 added `_relief_face_at()` scaling the donor `cDiff` by span (`span*0.03`, floor 0.05) plus absolute-height gates `|h|>2.4/>2.7`; the owner's capture showed dense concentric rings around every building and it was **fully reverted** to `inbox/backup/world3d_terrain.gd.bak-B04` (B04 §1–§4). B04 was **not** in the tree/capture that L03 analysed (L03 §2).
- L03 identified the then-live producer: the cliff-role gradient gate at `game.gd:1275-1308` promoting **quantised 8-bit base-mask terraces** (`mapgen.gd:63-85`) and clamp `0.03` dither bands (`game.gd:1267-1274`) to `terrain=5`, then `_apply_shore_cliffs()` / `_cliff_tile_for()` painting nested grey bands with `|h|>2.7→rock8`, `>2.4→rock4`; a pre-B03 240² dump has 1,494/57,600 role-5 cells plotting as thin arcs/rings — **the maze predates B03** (L03 §3 rank 1–2, §4).
- B03's final edit (against `game.gd.bak-B03-relief`) made the gradient pass **collision-only**: `terrain[i]=5` removed, `set_blocked_tile(x,y,true)` kept unconditional; `_relief_stamp_mask` retained as harmless/reusable data (B03 §11). `grep` today finds exactly one executable `terrain=5` write (the stone quarry disc) — Y08 §11.3, current-tree check this ticket.

**Stage 2 — the surviving TILEBLOCK maze [O]+[D] (Y01b).**
- With gradient rock writes gone, the same rings survived in the owner's `l07c` capture; Y01b proves the carrier is now `_apply_detail_pass()`'s id set `{grass_ground1=14, grass_ground3=16, test7=78, test8=79}` = **59,999 cells / 58.6% of the map**, **strictly complementary** to `terrain==5` (0 overlap), painted in 1–6-cell runs that follow height contours (radial corr up to |0.92|); the `h<0.1` bitmap selection is the height gate (Y01 §8.1–§8.3).
- **Important correction:** the bitmap R channel is a **categorical tile id** (`R=tex*2`, only 12/10 distinct values, `corr(R,height)≈0`), not a continuous height field (Y01 §8.3; H03-E10). B03-P3's redirect to `grass9/test8/test7` does **not** remove the pattern — all three differ from base `grass1=0` (Y01 §8.4).

**Stage 3 — the stale-guard ring halo [O]+[D] (Y07).**
- The surviving rings after Y03/Y04/Y05 were the **3-pass donor smoothing** chain (`_smooth_tilemap` → `_tb_smooth_pair` → `_tb_pick`, donor lists at `game.gd:1604-1760`): Y05 changed the neutralised meadow id from `grass9`(8) to `test8`(79) at `:2008` while Y04's four midpoint guards still tested `!= grass9`; on a `test8` meadow `79 != 8` is always true, so transition ids were written back and 3 passes nested them 3–6 deep around every start/deposit (Y07 §2/§3, frontmatter verdict). Y07-IMPL widened the four guards to exclude **both** `test8` and `grass9` (four one-line edits, backup `game.gd.bak-Y07`) (Y07 §8).

**Stage 4 — the checkerboard and the final authority [O]+[I] (Y08, Y08b/c).**
- The olive light/dark checkerboard is **one coupled mechanism**: L01's spot pass is the spatial trigger (1–6-cell runs of `grass9/grass5/test9/test8`), the dominant brightness mechanism is the **per-id alpha patch** (`grass9`→(2,0) and `grass5`→(1,0) have effective `a≈0.72` vs base `test8`(0,0) `a=1.0`), measured ΔY=25.9 with a hue-preserving ratio (1.43,1.43,1.50) — a scalar-mask signature, not an atlas-id switch; smoothing is a hard-edge co-cause; the 2 m repeat only supplies grid cadence (Y08 §1 E04/E06, §2, §3, §4 rank table).
- Widening the Y07 guards changed **coverage, not contrast** (light/dark ratio invariant ±0.01 between y04b and y07 while dark fraction rose 0.145→0.356) — this **falsified further spot/guard micro-tweaks** (Y08 §8 E15).
- Y08 Branch A (APPLIED under COORD grant) adds a final-authority loop in `_assign_tileblocks()` collapsing ordinary land (`terrain` not 1/3/4/5, not water, not mine apron) to `test8` after smoothing, and sets the start-disc `g0` to `test8`; `brng` draws unchanged (Y08 §11.2/§11.4). Y08b (APPLIED; current `git diff`) additionally sets worked-ground `g1` to `test8` and paints the **whole** start keep-clear disc (water-guarded) rather than only `terrain==2` cells (Y08 §12; §5 this report).
- **Observed outcome:** y08c capture = 0 script errors, concentric rings **gone**, but horizontal striping persists (Y10 §0/E01). Y10 applied `tile_atlas : filter_linear_mipmap_anisotropic` (the only valid Godot token; `filter_linear_anisotropic` does not exist) and Y11 added `textures/default_filters/anisotropic_filtering_level=4` (enum index for 16x, **not** the literal `16`); both are **APPLIED_NOT_CAPTURED** and PORT APPROX vs donor `tfIsotropic` (Y10 §2/§3, Y11 §2/§3).

**Definitive chain (compact):**
`height[] (R-code + analytic relief stamps) → near_start hard step + 0.03 dither terraces → collision pass |dh|>0.5/0.55 → (historically terrain=5 → rock tile ids; now collision-only) → detail-pass bitmap id selection at h<0.1 → 3-pass donor smoothing midpoints → L01 spot ids × per-id alpha patch → tileblock → UV2.x → atlas albedo`. **Geometry and albedo were never separated cleanly until the final-authority override; a fresh donor-shaped module must keep them separate by construction.**

### §1B Diagonal veins / streaks / repeated blotches (a different symptom)

- **[O] The vein lattice is intrinsic albedo.** All audited atlas cells are byte-identical copies of `blocks/*.png`; `grass_ground1`(14)/`grass_ground2`(15)/`grass_ground3`(16) carry a bright diagonal vein lattice/crosshatch (idx16 is an exact mirror of idx14; idx15 LF=0.39); `grass2` has FFT-aniso 5.16 and Sy=1.81; `ground1` is off-palette grey-brown (A03 E01/E03, §2 rows, F03/F04/F06). No cell contains the donor's large-scale mottling (LF 0.09–0.25; between-cell RGB std only (5.6,8.8,3.5)) (A03 F02).
- **[O]+[I] The faint streaks/repeating bands** are attributed to the verbatim 2 m world-XZ RGB repeat (`uv_repeat=(0.5,0.5)`, `fract(v_st*uv_repeat)` at shader `:214/:392`) under minification with no generated mip chain in the original atlas import (≈76 px measured period vs 73.7 px predicted), plus the `id mod 32` alpha-patch reuse and the full-cell mask fold (A01 Rank 1 / A06 Rank 2 via H03 §3 point 4; A02 Q1/Q2; H05 §4 item 3).
- **[O] The alpha mask:** 8×4×64² patch grid, `cell = f(id mod 32)` for 124 ids → only 32 patch roles; 8 ids map to constant-0 sentinels → black cells/cliff faces; only 7 ids get `a=1.0`; sampled on **every** flat fragment with no boundary test (A02-E1/E2/E4/E5, §1 Q1/Q2, §2 census). Lands B01/A02-P1/P4 and A06-F2 mitigations exist; the decisive `mask_to_alpha=0` A/B was **never produced** (A02-E11, H03 §4(a)).
- **[D] Refuted as causes:** the heightmap hypothesis (H03/H05/H04), the alpha mask as ring geometry (Y02 rank 5, L03 rank 5), and "normals are smoothed away" (A05 §3.3, Z02 §2 refuted).

### §1C Flat relief / absent hills, mountains and ravines

Ranked causes (A05 §4; Z02 §2):
1. **[O]+[I] Amplitude vs footprint — PRIMARY.** `HEIGHT_SCALE=1.0`, `TILE_M=2.0`; a `plt2` cap (42×55 donor cells × `W/160`) spans ~126×164 m at 240² for a ≈3 m rise (~1°); RCODE-FIX-01 reduced base amplitudes to **+0.496/−0.558**, ~2.7×/5.3× flatter than earlier captures (A05 §3.2; Z02 §2 rank 1; Z01 §3.1 for dump stats).
2. **[O] No silhouette geometry.** Donor mountains are `terrainmesh1..4.osm` props 6.93–9.55 units tall (~26–28 units wide) whose pattern height grids are **all-zero**; the port had zero such OBJs/manifest entries/consumer (Z03 §1.2/§2/§3; Z02 §2 rank 2). Z08/C01 later landed derived assets + a static instancing consumer (§3, §5) — visual correctness **UNVERIFIED**.
3. **[O]+[I] Shading cannot carry the read.** Shader is `unshaded`, donor Blinn-Phong only, high ≈70° sun, near-up normals; no shadow map, SSAO, AO or voxel pass; `shadow_enabled=0`, `mi.cast_shadow=OFF` (A05 §3.2/§4; Z02 §2 rank 3; P02/A12 cited).
4. **[O] Face gates cannot fire.** Verbatim `cDiff1=0.5`/`cDiff2=0.55` need a step 5–15× larger than the port supplies; `face` stays 0 so grey `rockNvf/rockNvs` art is never selected (A05 §3.7/§4 rank 4; Z02 §2 rank 4).
5. **[O] Coverage.** Only 2/26 decoded donor grids reach live height (`plt2`/`k_ravine_1` id gate); donor-active `ravine_big` is placed but has no port grid; `k_ravine_1` is BLOCKED and donor-disabled (A05 §3.5/§3.6/§4 rank 2–3; Z02 §2 rank 6; DPATTERN-01 cited).
6. **[O]+[I] Camera/sun** amplify ranks 1 and 3 but are already donor-legal and not actionable (A05 §3.4/§4 rank 5; Z02 §2 rank 7).

**[O] Height is really in the mesh** — `verts[i].y = height[i]*HEIGHT_SCALE` and normals from the same array; the dump is non-flat (std 1.191 m, 63.20% zeros, 1.689% edges >0.5 m) — so "heightmap was never implemented" is REFUTED for those dumps; older same-seed dumps are nearly flat (std 0.027–0.044 m, 98.1–98.6% zeros) (Z01 §3–§6; Z02 §0). The shipped 240² default has **no** on-disk dump (0/130 height-bearing JSON files are 240²) (Z01 §4.1/§7). The 8×10 tables are explicitly labelled "debug/preview aids only" (DPATTERN-01:595-600 via B03 §6/Z04 Part B).

### §1D Weak shore / water

- **[O] Landed donor fixes** (DTRN_03 F1–F4): surface Y decoupled from −0.25, water cells remapped off `grass1` via the 8×45° shore table, `shore_prox` removed, exact `coastfade2` alpha with no 0.35 floor; shore ids are donor `sandsea1/5/6` (93/97/98) (G26 §3; V784 §3).
- **[I] Remaining gaps, all UNVERIFIED visually:** (G26-1) reflection off + no `CalcTerrain` bed lighting/PCF → water likely flatter/darker than reference pale grey-green; (G26-2) foam brightness/width unproven (donor foam is procedural, no provable pixel band); (G26-3) non-donor hard `water_cell = 1-step(water_level,height)` alpha cut at classification height; (G26-4) `waveheight=clamp(WATER_LEVEL*3−1.5,0,1)=0` under shipped −0.25 → donor large swell absent; noise scale uses `map_size.x/128` vs UNVERIFIED donor `hmapW`; 8-bit height quantisation (≈0.023 m/step); (G26-5) ~1-cell wet sand collar vs broad reference beach, substrate gate is PORT APPROX (donor `mask.b>0` unreadable), flat water falls back to `sandsea1` instead of donor bed colour; `rock9/sand1/sand2` must stay out of active shore (G26 §4; DTRN_03 cited).
- **[O] Critical for today:** the only captured frames are all-olive with **zero cyan water pixels** (Y09 §2 R6; G26 §6 item 6), so *no* shore comparison is possible until a water-bearing capture exists. Do not re-import 2D `×8`/`×4`/`FOAM_GAIN` glints or invent `hmapTex` values (G26 §4 G26-2; V784 §8).

### §1E Mill fields, mines, rotor

- **[O] Port field bug:** `_sow_field_ring()` sows a 7×7 rotated lattice with `step = 1.6981*TILE*0.5 = 1.6981 m` — **half a donor cell** — and rejects cells within `1.5*TILE = 3.0 m` of any food node including siblings; minimum accepted spacing 3.3962 m vs a 3D footprint of 2.4015 m → fields cannot touch; per-stage `rel` further shrinks XZ (F2-03 §0/E1–E4, §9 item 3).
- **[O] Donor truth:** a mill seeds **49 nodes** (`cRow=7`) at `size=1.6981` **map cells**, grid rotated 45°, position snap `sqrt(2)*size≈2.4017`, decal `texscalefix=1.3`, food clearance `rad/3≈1.528` cells **smaller** than spacing → siblings deliberately packed; reference is one contiguous hard-edged rotated rectangle with a square mill clearing; the mill re-seeds on build, on map start, and after each field order (F2-02 F1–F7, §3.2/§3.3). Decal `w` unit is UNVERIFIED.
- **[O] Donor mine placement:** `SetupMines` uses 3/4/5 rings × 3 ores with 256 angle tries; deposits are ~2.4-cell props in 8×10 stamps; the built mine is a 5×5-cell collision mask with a 5×5 dirt plate; **magnetic snap** within `gc_gameplay_findminepositionradius=1.5` cells finds the nearest gold/iron/coal object and places both ghost and foundation at its exact X/Z/Y, re-validating with `colRad=0, envRad=0, mineRad=-1`; no deposit ⇒ invalid; normal buildings instead use 0.5-cell normalisation plus ±0.5/±1 adjustment search (F2-02 F8–F14, §4.2–§4.4).
- **[O] Mill rotor:** donor rotor is `<sid>anim.oss` (not `.osm`), a single-bone 249-frame morph with local-Y axis, 251 keys @30 fps ⇒ **0.751 rad/s** (port's 0.75 matches), mesh-frame hub eur ≈ `(0,−1.47,5.628)`, rus ≈ `(0,−0.68,3.562)`; building authored yaw 45°/135°; not camera-facing, not wind-driven; no in-game rotation (M02 §3–§5). The port's 2D billboard hub `(0.17296,5.23533,0)` m, axis `Vector3.FORWARD` and `BACK→FORWARD` spin flip are **PORT APPROX** (M02 §8 item 4). No field/rotor/mine-snap fix landed (F2-03 and F2-04 are proposals; §5).

---

## §2 Approaches that were tried and REJECTED (with the reason and evidence)

| # | Rejected approach | Verdict / why | Evidence |
|---|---|---|---|
| 1 | **B04 face promotion** (span-scaled `cDiff1/2`, `|h|>2.4/>2.7` absolute-height promoters, `_relief_face_at()`) | Owner capture showed dense concentric rings around every building; fully reverted, **keep the revert**. Any variant fires on the `near_start` one-cell step (up to ≈2.964 m) and on plateau terraces; raising the gate to ~1.0 m would still leave the disc steps. | B04 §1–§5; Z02 §3; Z04 §7 |
| 2 | **`HEIGHT_SCALE` / amplitude exaggeration fudge** | Invented multiplier with no donor citation; breaks `height_at_world()`/entity Y/water gate; re-triggers baseline face gates on `near_start` steps → recreates B04. Rejected as primary; if ever ordered, must be config-gated default OFF and labelled PORT APPROX. | Z02 §2 "Rejected"; A05 §3.2; Z04 §7; CHARTER §3 |
| 3 | **Synthetic dither/noise/"beauty" field** | Decision **S-25-09** forbids it (recreates the 2D checkerboard regression); no new bitmap, hash, noise, gain or luminance field. The existing `0.03` dither cap must **not** be extended; donor-grid cells continue to skip it. | 2026-11-25 CHARTER.md:60-61; H03 §4; B03 §3; Y10 §4; Y11 §5 |
| 4 | **Tile-art relief** (relief writing `terrain=5`/rock ids; using rock/cliff tile colours as the relief cue) | Relief passes must write **height only**; the only route from relief to visible art was the collision→`terrain=5` conversion and the cliff/shore pass — that is the maze. Suppressing rock art on port-analytic relief cells is **PORT APPROX** (donor `texturemap.inc:557-591` paints rock from collision tags). | Y02 §4–§5; Z04 Part A/§7; B03 §11; L03 §2 |
| 5 | **"Force cliff art" by lowering a global height/threshold** | Same as (1) without the name: any global promotion gate fires on quantised 8-bit terraces and the start-disc step. Z04 does the **opposite** — a guard returning face 0 on producer-stamped cells. | B04 §3; Z02 §3; L03 §3; Z04 Part C |
| 6 | **Heightmap-as-albedo hypothesis (H03/H05/H04)** | REFUTED: no candidate is both a donor height source and drawn as albedo. Routing the alpha/detail layer to height would lose donor tile identity, void the published `mask_to_alpha` A/B (uniform becomes a no-op), break `height[]` length/±2.964/`height_at_world()` invariants, and leave the streaks in place. | H03 C1–C4/§3; H05 §1/§5; H04 §1; H01 §6; H02 §0/§4 |
| 7 | **Enable shadows / add SSAO/AO/voxel fakery** | No shadow map shipped, `shadow_enabled=0`, sun shadow off, terrain `cast_shadow=OFF`; enabling is inert and non-donor; donor AO usage UNVERIFIED. | Z02 §2 rank 9/"Rejected"; A10:86; A12:122/174 (cited) |
| 8 | **Border-only / compressed alpha mask as a fix** | A02-P2 border band would draw a **2 m grid of dark lines** (worse); P4 contrast compression and P1 sentinel guard are landed PORT APPROX mitigations, not donor parity, and the partition A/B was never run. | A02 Q4/P1–P5; H03 C1; H04 §3 Step 0 |
| 9 | **`mask_to_alpha=0` used as a fix rather than a diagnostic** | It removes legitimate transition shading; it is the sanctioned **partition experiment** only, and requires a real `set_shader_parameter` binding plus config key — a config-only arm is UNVERIFIED/FAIL (G-A0). | A02 Q3/P3; H04 §3; G25 U-41 |
| 10 | **Spot/guard/smoothing micro-tweaks to kill the checkerboard** | y07 vs y04b proved the light/dark ratio is invariant (±0.01/channel) while dark fraction changed → the contrast is baked into the id→patch map while >1 id is permitted on ordinary land. | Y08 §8 E15/§9 |
| 11 | **Reverting `:2008` to `grass9`** | Restores Y05's horizontal corrugation (patch (2,0), `a≈0.724`). | Y08 §5 "Do NOT"; Y07 §4.2 item 1 |
| 12 | **Reinstating the height-gradient `terrain=5` paint** | That is the original maze producer; B03 §11/L03 made the pass collision-only on purpose. | Y08 §5/§9; Y07 §4.2 item 2; B03 §11 |
| 13 | **MSAA/FXAA as a "fix"; anisotropy claimed as donor parity** | Donor is `tfIsotropic`; anisotropy is PORT APPROX. Y11 explicitly added no AA key. (Anisotropy itself is a *pending* A/B, not rejected.) | Y10 E09/§5; Y11 C03/§5; G25 U-52 |
| 14 | **A04 P3 / full 25-unit donor grid embedded in `game.gd`, and 1 m UV repeat** | Different owner + touches stamp RNG; 1 m doubles minification and cannot help since cells have no macro structure. `k_ravine_big_stone_1` table must first be derived and bit-gated (R-DATA). | B03 §6; A03 §5; Z04 Part B; G25 U-23 |
| 15 | **Global stochastic rotation / rotating streak cells** | PORT APPROX only; rotating a streak spreads it over more orientations; donor uses 25° only on sand/rock slope faces, never grass. 4-fold rotation restricted to isotropic cells is a conditional A/B at most. | A03 §5/§8/F08 |
| 16 | **Re-importing 2D water glints / inventing `hmapTex` values** | Donor `hmapTex` binding is only a string assignment; `heightmapwaves0.tga` has constant alpha 255 and is not the binding; 2D `×8`/`×4`/`pow(grad,24)`/`FOAM_GAIN` are explicitly "do not copy". | V784 §4/§8; G26 §4 G26-2; H01 §5 |
| 17 | **Generic entity spawn for relief props (bbox normalisation/grounding)** | Would override the authored donor `Scaling`/`Position`/yaw; needs a dedicated placement path bypassing bbox normalisation. | C01 §6.3; Z06 §5; Z08 §1/§4 |
| 18 | **Treating a green gate/smoke metric/offline replay as donor parity** | G25's anti-upgrade checklist: green JSON proves node state only; C01 is "heuristic only"; donor citation proves intent, not appearance; offline top-5 58.52% is not a live histogram. | G25 §9 items 1–12; C04/G21 cited in Y09 §0 |

---

## §3 Donor-grounded mechanisms CONFIRMED (safe to build on)

| Mechanism | Confirmed facts (labels) | Evidence |
|---|---|---|
| **Atlas cells / tile id** | 124 named presets from `presets_summer.json`; atlas 16×8 grid of 1024² cells, 121 filled / 3 empty (`alpha0a/b/c`); cells **byte-identical** to donor block PNGs; face presets reuse base art per `tiles.mat` (`rockNvf/vs`→`rockN.dds`, `sandNf/s`→`sandN.dds`); sand1/sand2 256²→1024² NEAREST upscale flagged APPROX; `UV2.x = float(GetTileIndex)` (donor `dmscript.global:2026-2035` / `savemapterraindata.inc:16-17`). | V785 E1–E11/§3/§6; V786 D01/D02; A03 E01 |
| **Alpha / alphavert masks** | `alpha.bmp` 512×256 8bpp data @1070, 8×4 grid of 64² organic feather masks, 254 grey intensities; `alphavert.bmp` 1024×512×24; bound via `reftilealpha.mat:30-37/139-146` (`tiaAlphaFromIntensity`, `tfAlpha`, `maNearest/miNearest`); `reftile.mat:6 Texture2Name=alpha`, `:17 bmTransparency`; `hf.pvl.smx3.frag:13-14` reads `texUnit0.rgb` + `texUnit1.a` **only** — a crossfade weight, **not** colour/height/noise; `(0,0)/(4,0)` = no transition, `(3,3)/(7,3)` = full cut. | H01 §4; V785 E6/E7/§4; A02-E4/E6; H03-E5 |
| **Donor grids / height sources** | Terrainmask R → relief class (255/191 plateau +2.964, 96/112 hill +1.31733, 48/88 ravine −2.964), B → water bed `−1.1*(fb*(1+fr*3.5))`, G → forest/stone placement **not height**, A → road `broad`; `hwater+hterrain` fed to `SetHeightData` at `generatemap.inc:562-574`; `.pattern` = `int32 w,h` + u8 occupancy + row-major float32 window near `8+w*h`, min/max bit-exact against `pattern.lib` `HeightFieldMin/Max` (26/26); `.map` bakes `float32[W*H]`; mask never bound as albedo. | H01 §2.1–§2.3/§5; DPATTERN-01 §2–§4; V784 §1 |
| **Smoothing / detail pass** | Donor call-site order `TextureMap` (`generatemap.inc:776`) → `SmoothTiles`/3-pass `SmoothTileMap` (`:786`, `smoothtiles.inc:237`) → `LoadTextureTerrainFromBitmap` (`:795`); 118 active groups / 282 pairs / 86 names; detail bitmap `h<0.1`, `r=floor(fr*255)`, `tex=r div 2`, **only where `GetTileIndex=0`**; patch runs 1–6 cells. **2D `app/` follows this order; 3D `variant3d/` is flipped** (detail before smooth) — flipping is donor-faithful in *call order only*, changes `tileblock` bytes and shared `brng` draws, and is not sufficient for fidelity. | H06 §0/§1/§2/§4; RV_TRN_02 cited; H01 §3.1–§3.3 |
| **Water shader** | Full donor `water.dev.frag` step order transcribed: `noise=p/256`, `hmapMin+tex.w*(hmapMax−hmapMin)`, `WATER_LEVEL=gl_TexCoord[1].z`, `deepwater_fadedepth=0.5+0.57=1.07`, `waveheight=clamp(level*3−1.5,0,1)`, `level=WATER_LEVEL+0.2*water_map`, land discard `height>level`, 4-tap normal/jitter, `terrain_map=vec3(.175,.1375,.1)+waveMap(p*8)*.25`, coastfade/coastfade2, reflection, specular `pow(grad,170/120)`, procedural foam `nautic()×18`/`particles()×200`, `resalpha=coastfade2`, EXP/EXP2 fog `1.442695`; constants −0.25/−0.1/2.96 from `texturemap.inc:29-31`, `TexScaleS/T=0.1/0.01`, `HDRMultiplier=1`; `heightmapwaves0.tga` is a decoy. | V784 §1/§3/§4/§6; DTRN_03 cited; G26 §3 |
| **Tileindex shader / geometry path** | One vertex per 2 m cell centre; `uvs2[i]=(tile_id,face)`; donor equation chain `realpos/e/l/h/n`, `v_packed=ambient+diffuse`, `v_specular`, fragment `rgb*v_packed+v_specular`; eye-plane projected UVs and 0.125 eye-linear face scale with donor front S=(1,0,0,0)/T=(0,0,1,0), side S=(0,1,0,0)/T=(0,0,1,0); 3-tap (SM20) and 9-tap (SM30) shadow divisors `1/512`; fog modes 1/2/3. `face` vocab exactly 0/1/2; 25° `AngleX/Z` is metadata only; `tangentSpace=false` → no normal map; 0 `glColorPointer` refs. | V786 D01–D20/§2/§3; H02 §3.4–§3.5; Z02 §1 |
| **Field / mine / prop data** | 112 `terrainmesh*` `Objects` records in 30 `pattern.lib` sections (mountain families only; 1–9 per stamp), each with Position/Direction/Up/Scaling captured at e.g. `pattern.lib:338480-338507`; scale uniform 0.353864–0.656215 (**not** 1 — `dogenerate.inc:1984-1985` only skips random rescale); `Up` encodes pure yaw in 10° steps; `terrainplateau1..4` have no `.prop`, no `pattern.lib` refs (skipped); props carry their own `terrainmeshN.dds` albedo; fields/mines constants as in §1E. | Z06 §1–§3/§6; Z03 §1.2/§4.2; F2-02 §3–§4; M02 §3 |
| **2D piece ground truth** | 12/15 t6 pieces reached unconditional PASS (grass_mottled, shore_sand, shore_rock, shore_water_transition, ravine_face, plateau, forest_conifer, forest_broadleaf, bushes, stones, field_crops, desert); T06 hill_ridge honestly FAIL (smooth loaf vs donor striated escarpment) — "needs heightfield-assisted approach"; T12 mines_display REVOKED. Metrics never override visual review. | `docs/t6/TERRAIN_LANE.md` §"Integration readiness" + supervision log |

---

## §4 Exact UNVERIFIED register — what today's donor decoding must resolve

Consolidated from G25 (authoritative anti-upgrade register), Z02/Z03/Z06/Z08, Y01/Y02, A02/H03/H05, G26 and Y10/Y11. **HARD RULE (G25 §0): an item closes only by producing the named evidence, reviewed by a second agent where stated. No green JSON, smoke metric, donor citation, offline replay, static read or matched-selection ratio closes anything.**

### §4.1 Highest priority (P0/P1 — blocks a GO or an owner complaint)

| ID | Item | Evidence that closes it | Source |
|---|---|---|---|
| V-01 | **Donor GPU parity** — hue, silhouette, grain, luma, shore, animation | Real donor GPU frame on the same GPU, matched seed/camera/scene, pixel-aligned, on disk, second-agent sign-off. Nothing else substitutes. | G25 U-01 |
| V-02 | **All integrated gates on the landed tree** (selftest 29/29, uitest 17/17, `t_render_mode`, `assert_clean`, `script_error_lines==0`, 2D `app/` byte-untouched) | Runner result JSONs with `ok`/`exit=0`, every step `passed=true`, no threshold lowered / `expected_pre_fix_failure` flipped. | G25 U-02 |
| V-03 | **Matched-camera reviewed post-fix captures** incl. a water-bearing real-map frame and a 64² P0 | Two non-blank 1280×720 PNGs, pinned seed 20261113, completed C04 §7 11-row table + G05 second-agent verdict. | G25 U-03; Y09 §2 R6; G26 §6 #6 |
| V-04 | **The shipped 240² default's actual height grid** | `--dump-map` of `config.json` defaults (240², seed 20261113, mediterranean/low_mountains) + §2 metrics on `dump["height"]` and mesh `stats`: grid 240×240, `height_min/max/range/scale`, `tile_index.face_hist`, `relief_grid.applied/stamps`, dump-vs-stats SHA. Acceptance: std<0.1 & >95% zeros & 0 steep edges ⇒ genuinely flat; else height exists and the gap is visual. | Z01 §8; Z02 §5 |
| V-05 | **Relief shape classes actually reaching height** (`k_ravine_big_stone_*`, `hil1`, `g_hil4`, `plt*`) | R-DATA derives `k_ravine_big_stone_1` 8×10 table bit-exact against `pattern.lib:730045-730046`; R-CODE adds ids without inventing one; dump shows `meta.relief_grid.candidates>0`, `applied_cells>0`, changed height hash and ≥1 cell below −2.0; gates green; capture reviewed for steeper silhouettes and **no rings** (visual parity still UNVERIFIED). | G25 U-23; A05 §5/§6; Z04 Part B |
| V-06 | **Face-promotion rule / 25° `AngleX/AngleZ` entry** | Donor engine decode + capture with face_hist on real slopes; whether the tilt-normal lighting effect is real. Port `rockNvf/vs` selection rule is PORT APPROX. | G25 U-33; V786 §2 #3; Z02 §4.2 |
| V-07 | **The `mask_to_alpha=0` A/B at identical camera** with a real `set_shader_parameter` binding + additive config key (G-A0) | Two captured frames, same compiled program, same camera; C01 deltas + second-agent read. Without it the mask-vs-atlas share is unknown. | A02-E11; H03 §4(a); H04 §3 Step 0; G25 U-41 |
| V-08 | **Live tile histogram on the CURRENT frame** (post-Y08/Y10/Y11, not pre-B03 dumps) | `--dump-map` decode showing which ids dominate ordinary land and that `ground1`/sand/rock exceptions are the only survivors; A11/C01 BV32 movement on the named ROI with camera confound stated. | H03 §4(b); A03 §7; G15; G25 U-25 |
| V-09 | **Donor relief-prop silhouette / placement** | G04 runs Z07 atom after reconciling MultiMesh collector, N-per-stamp count, manifest path and authored scale (strengthen, never weaken); props-ON/OFF A/B PNGs; human "does it read as a hill" review — port-visible only, **not** donor parity. | Z08 §6/§7 G8–G10; Z03 B4/B7; Z06 §7 Q1–Q7 |
| V-10 | **Water surface Y, `hmapTex` binding, reflection FBO, foam band width** | Donor runtime uniform trace / GPU frame; until then `waveheight=0` and reflection off stay as declared PORT APPROX omissions. | G25 U-38; V784 §8 #1–#4; G26 §6 #1–#4 |

### §4.2 Donor engine internals (CONFIRMED_UNVERIFIED — must stay labelled)

- **V-11** Tile-id → alpha-patch selection rule (`reftile.lib:10-12`, `tsDouble/ttExtended`, `TileXOffset/YOffset`, `tsDouble` complement pairs) and `bmTransparency` pass count/blend equation (G25 U-31/U-34; V785 §7 #2; H01 §7 #2).
- **V-12** Eye planes `gl_EyePlaneS/T[0]` and `gl_TextureMatrix[0]` numeric values (G25 U-32; V786 §6 #1).
- **V-13** Full `w×h` float32 Windows for donor-active relief patterns, engine sculpt blend (`Replace`/`ReplaceForWater`/`Smooth`, clamp/scale order, `−0.925` sign), and file-row→map-row `row_flip` sign (G25 U-23; A05 §7 #2–#3; H01 §7 #3).
- **V-14** Runtime activity of every `[*] = ;`-prefixed `.inc` script (generator, texturemap, smoothing, detail, alpha, GUI/mine snap) — authoritative *intent*, not proven execution (H01 §0/§7 #1; H06 §1.2; F2-02 §5 #1).
- **V-15** Which `.map` 37-byte record field is authoritative `tex`; what byte +33 encodes; relation of record block to float grid (H01 §2.2/§7 #4; G25 U-35 area).
- **V-16** Donor metres-per-cell (local `gc_meters_to_tile=2` CONFIRMED at `dmscript.global:171`; literal not published online), mesh LOD/tessellation, exact engine normal formula (G25 U-35/U-36; Z02 §5 #4–#5; DTRN_02 C19/C20 cited).
- **V-17** Native `StandPatternWithAngle` transform math, whether all N prop records instantiate, `ObjectsScale`/`ObjectsHeightOffset`/`ObjAutoOffset` multiplication, yaw sign to Godot Y-up, winter prop materials, desert prop textures (Z06 §3/§7; Z03 B4/B6; Z08 §5).
- **V-18** Mill field 3D decal `w` unit, whether all 49 nodes survive the environment scan, donor-side on-screen field/mine appearance, record-id→prop binding in the 63-record mine stamp, `minegold/minegolds` selection, `envscales.cfg` vs `cScale` application order (F2-02 §5 #2–#7).
- **V-19** Rotor world-space spin sense (cw/ccw), per-map rotation overrides, donor editor "R" hotkey (M02 §6/§8; G25 U-40 area).
- **V-20** Season/biome donor runtime activity; water scene-fog ACTIVE vs "off by default" conflict; SM20 vs SM30 profile; shadowampler/projection values (G25 U-37/U-39; V786 §6 #2/#5; G26 §6 #5).

### §4.3 Measurement/capture gaps left by the prior wave (do not silently promote)

- **V-21** Exact post-B03/post-Y08 tileblock dump for the captured frame; cell-to-pixel transform of `realmap.png`/`y08c` never inverted (Y01 §6/#probe, §8.5; Y07 §5 #1).
- **V-22** Which edit changed the rings' colour (no post-B03 histogram A/B); quantitative share of maze pixels by rock id vs transition id vs alpha fold (Y02 §6; Y01 §6 #2).
- **V-23** Post-fix share of mask-driven vs atlas-repeat-driven streaks; residual sentinel black cells; `MODE_ARRAY` atlas fallback mip seam LOD spikes; mirror seam / P4 tonal shift; `textureGrad` translator behaviour (G25 U-26–U-30).
- **V-24** Color B/G and b* bands, low-frequency BV32 deficit (~28.6×) on a reviewed frame; offline replay is not a live histogram (G25 U-24/U-25; A11/A07 cited).
- **V-25** Runner hygiene / backup byte-identity / static parse of edited files / season atlas consistency / hotkey live gaps — several Wave G assignments never landed (G25 U-55–U-58, §8).
- **V-26** Loading stall S3/S4 (B02's synchronous ~683 MiB mip build on the main thread) and all G17 cost ratios — analysis only, never profiled (G25 U-43/U-44/U-45).
- **V-27** Anisotropy A/B: Y10/Y11 are **APPLIED_NOT_CAPTURED**. If `coherence`/`row_periodicity`/`tile_repeat` do not fall while BV32 holds, record the null result (striping likely tile-id/patch data) and do not stack further shader changes (Y10 §5/§6; Y11 §7). The `array` atlas transport has no mips, so the hint is inert there (Y10 E08).
- **V-28** Mine magnetic snap and four-patch field quad are **proposals only** (F2-03/F2-04); port visual result of either is UNVERIFIED; owner must confirm whether donor node-count parity (49 nodes) or the four-patch shape is wanted (F2-03 §9 item 3).

---

## §5 Landed code changes in the working tree that a fresh module must coexist with

### §5.1 Uncommitted (vs HEAD), read this ticket with `git status --short` / `git diff`

| File | Change | Provenance / backup |
|---|---|---|
| `variant3d/scripts/game.gd` | **Y08b** scoping fix in `_finalize_mine_tiles()`: `var ci := _t(xx,yy)` moved inside `if ...length() <= 16.05:`, and the whole-disc start keep-clear `tileblock[ci] = g0` write (water-guarded) moved inside that same condition. `g0 := _blk("test8")`, `g1 := _blk("test8")` are present. | Y08 §12.3 / §11.2; backup `inbox/backup/game.gd.bak-Y08` (pre-Branch-A) |
| `variant3d/shaders/terrain_tileindex.gdshader` | **Y10**: one line, `uniform sampler2D tile_atlas : filter_linear_mipmap_anisotropic, repeat_enable;` (was `filter_linear_mipmap`). Comment block at `:52-59` is deliberately stale about the hint. All protected anchors (`:235`, `:365-378`, `:392`, `:410-419`, `:427`, `:475`, A/B block `:478-502`) byte-identical. | Y10 §3; backup `inbox/backup/terrain_tileindex.gdshader.bak-Y10`, SHA `E02E787A…` |
| `variant3d/project.godot` | **Y11**: one line inside `[rendering]`, `textures/default_filters/anisotropic_filtering_level=4` (enum index = 16x; literal `16` is out of range). No MSAA/FXAA/TAA key. | Y11 §2/§3; backup `inbox/backup/project.godot.bak-Y11`, SHA `6FFB4CDC…` |
| `docs/terrain_swarm_2026-11-25/reports/Y08_checkerboard.md` | modified (appended Y08b §12) | untracked siblings `Y08b_capture_log.md`, `Y08c_capture_log.md`, `Y10_anisotropic.md`, `Y10_capture_log.md`, `Y11_aniso_level.md` |
| `docs/terrain_swarm_2026-11-26/` | **untracked** — this wave's charter/board/reports | do not overwrite another worker's file |

No staged changes; no other source/asset/config files modified vs HEAD. The three backups above are untracked. Recent HEAD history is a series of `step` commits (`e234ac9b`, `0e9783f2`, …).

### §5.2 Already committed in HEAD (must be treated as present)

- `game.gd`: B03 diversity hunks (P1 detail re-roll, P2 tile stamps→`ground1`, P3 art redirect), B03 §11/L03 **collision-only gradient pass** (no `terrain=5` there), `_relief_stamp_mask` declared/populated/dilated but no longer read by the gradient pass, hill stamp `pass`, only the stone quarry disc still writes `terrain=5`; Y03/Y05 detail neutralisation `tex=_blk("test8")`, Y07's four widened smoothing guards, Y08's final-authority meadow collapse, L01 spot pass (`_stamp_grass_spots`), donor `DONOR_SMOOTH_RULES` and 3-pass smoother (game.gd grep this ticket: `meadow_id` at ~`:2151`, `g0/g1` at ~`:382/:388`, guards at ~`:2333–2345`).
- `world3d_terrain.gd`: one vertex per cell centre, `HEIGHT_SCALE=1.0`, `TILE_M=2.0`, `WATER_LEVEL=-0.25`, `_face_mode_at()` verbatim `cDiff` (no `_relief_face_at()`, B04 absent), `bind_height_grid()` water hook, tile-atlas ShaderMaterial, `cast_shadow=OFF`. **No Z04 art-guard/height-histogram landed** (grep found no `_relief_mask`/`relief_visibility`).
- `world3d_relief.gd` + `assets/terrain/mountain_props.json` + `tests/t_relief_props_qa.gd`: Z08 landed static per-sid `MultiMeshInstance3D` relief props, composed from `world3d.gd:bind()` (`RELIEF_SCRIPT`, `relief.bind(game, terrain)`, `stats.relief_props`). The file has since been adapted to the folder migration: it uses `AssetPaths.existing(sid,"obj")` and `LEGACY_OBJ_DIR` (grep this ticket), so do **not** assume the Z08 flat `OBJ_DIR` path.
- Derived relief assets: `terrainmesh1..4` OBJ/MTL/PNG exist under `assets/models/{obj,tex}/shared/terrain/` (C01 added them flat; FOLD migration moved them). The QA atom `t_relief_props_qa.gd` is still the **verbatim pre-MultiMesh Z07 atom** and will fail closed on node discovery until reconciled (Z08 §6) — an honest FAIL, not a regression.
- Tile atlas + masks (`tile_index_atlas.png` 16384×8192, manifest, `alpha.png` 512×256, `alphavert.png` 1024×512), tileindex shader, water module (`water3d.gd`/`water3d.gdshader`), donor mask PNGs, detail bitmaps, `presets_summer.json`, `tileblocks.json` — all present (V785/V784/H02).
- `app/` stays byte-untouched by every prior wave; keep it that way (CHARTER §1/§3).

### §5.3 Invariants a fresh module must preserve unless COORD explicitly grants otherwise

- `height[]` is a `PackedFloat32Array` of length `w*h` decoded LE from `dump["height"]`; `height_at_world()` samples the same grid the mesh was built from; don't feed a fragment texture into it (H05 §5.3, H02 §3.1).
- `blocked[]` is set on **every** steep cell unconditionally (`set_blocked_tile`); walkability/start protection/`scan_map` cliff metric depend on it (B03 §11, Y07 §4.1).
- `tileblock` is `PackedByteArray` size `MAP_W*MAP_H`, uint8 id in the 124-name table; `BLK_WATER=255` never overwritten; mine apron/road/shore/sand/rock roles are gate-protected exceptions (Y08 §9.5).
- `UV2.x` = integral tile id, `UV2.y` ∈ {0,1,2}; one surface, `(W−1)(H−1)×2` triangles; one-cell forward-difference normals; atlas `(16,8)`, three samplers, `shadow_enabled=0`, `cast_shadow=OFF` (A10/Z04 §5).
- `mask_to_alpha` A/B endpoints must both remain one compiled program with `a` present at `:427` (H05 §5.2; A02-E10).
- Determinism: same seed ⇒ same bytes; a **frozen tileblock hash is not a valid gate** — use `t_map_variety 5/5 same_seed_byte_identical` (B03 R1; Y07 §8.4; TRN-DATA precedent).
- One Godot at a time via `python variant3d\tools\godot_runner.py run --id <UNIQUE>`; analysis workers submit **no** runner jobs (2026-11-26 CHARTER §4).

---

## §6 "DO NOT REPEAT" — ranked

1. **Do not re-enable B04 face promotion or lower any global height/threshold to force cliff art.** It produced the maze on `near_start` steps and plateau terraces; fully reverted; keep the revert. (B04 §1–§5; Z02 §3; L03 §2)
2. **Do not route a mask/detail/alpha/atlas layer into `height[]`, and do not revive the H03/H05 heightmap-as-albedo hypothesis.** REFUTED twice; would void tile identity, the `mask_to_alpha` A/B and mesh invariants without removing streaks. (H03/H05/H04; H01 §6)
3. **Do not add a synthetic dither/noise/"beauty" field** (decision S-25-09) or extend the existing `0.03` dither cap; no invented donor constants. (CHARTER §3; B03 §3; Z04 §7)
4. **Do not raise `HEIGHT_SCALE` or amplitude literals as the primary visual fix.** Invented multiplier, entity/water desync, re-triggers (1). (A05 §3.2; Z02 §2; CHARTER §3)
5. **Do not let relief write `terrain=5`/rock ids or select cliff art.** Height-only in producer; the gradient pass is collision-only; a guard (face 0) is the safe direction, not a promoter. (Y02 §4; Z04 Part A/C; B03 §11)
6. **Do not treat tile-art albedo, the alpha patch or the 2 m repeat as a height source or a relief cue.** They are visible art/crossfade; fix large-scale variation with tile-id/relief/decal data, never a luminance field. (A03 F02/R09; A02; H05 §6)
7. **Do not micro-tune spots/guards/smoothing weights to kill the checkerboard, and do not revert `:2008` to `grass9` or restore the gradient `terrain=5` paint.** Coverage changed, contrast did not; those reverts restore known regressions. (Y08 §8/§5/§9; Y07 §4.2)
8. **Do not enable shadows/AO/voxel fakery or MSAA/FXAA as a fix; do not claim anisotropy as donor parity.** (Z02; A10:86; Y10 E09; Y11 C03)
9. **Do not treat a green gate, smoke metric, offline replay, donor text citation or matched numeric band as donor parity or as closing a required UNVERIFIED.** (G25 §9; C04/G21 via Y09)
10. **Do not instantiate relief props through the generic entity path (bbox normalisation/grounding); do not claim the landed Z08 props are visually verified.** (C01 §6.3; Z08 §6; Z06 §5)
11. **Do not import 2D water glints or invent `hmapTex`/eye-plane/`bmTransparency` pass-count values.** (V784 §8; G26 §4; G25 U-31/U-32/U-34)
12. **Do not stack further shader changes on the Y10/Y11 A/B before its matched-camera capture; if null, record it as tile-id/patch data.** (Y10 §5/§6; Y11 §7 Y11 note)

## §7 "BUILD ON THIS" — ranked

1. **Y01/Y02 + B03 §11 + L03: the maze is solved as a *separation* problem.** Start from a fresh pipeline where relief writes `height[]` only, collision is separate from art, and no analytic height gradient can select a rock tile id. Reuse Y02's "art-only guard" shape (mask in `_assign_tileblocks` + `_apply_shore_cliffs`) if any legacy path survives. (Y02 §4; Z04 Part A)
2. **A05/Z02/Z03/Z08/C01: give height real donor shape and real donor silhouette.** Stage A = derive full/bit-gated donor grids for the donor-active families (`ravine_big`, `hil1`, `g_hil4`), PORT APPROX blend and `row_flip: UNVERIFIED`; Stage B = use the already-landed `terrainmesh1..4` derived meshes + `world3d_relief.gd` static instancing (respect `AssetPaths`), and reconcile the Z07 QA atom by **strengthening** it. (A05 §5/§6; Z04 Part B; Z08 §1/§6; C01 §6.3)
3. **H01/V785/V786/A03/A02: keep the donor representation intact.** 124-cell donor-indexed atlas, byte-identical block art, `.a`-only mask semantics, `UV2.x=tex id` / `UV2.y` face 0/1/2, donor Blinn-Phong/shadow/fog equations and the `mask_to_alpha` A/B contract. Implement the donor's transition-only mask role with a neighbour-id attribute (A02-P5) **only** after V-07 partitions the cause. (V785 §3; V786 D01–D20; A02 P5; H04 §3)
4. **H06: use the real donor pass order** `TextureMap → SmoothTiles(3) → LoadTextureTerrainFromBitmap` as the spec target; the 3D flip is a known deviation and a byte/RNG-changing edit, not a cosmetic toggle. (H06 §0/§4)
5. **V784/DTRN_03/G26: start from the already-transcribed water equations.** F1–F4 landed; the residual work is binding-level (surface Y, hmapTex, reflection FBO, soft alpha cut, collar width) and must be gated on a water-bearing capture, with PORT APPROX labels. (G26 §3/§4/§5; V784 §3/§8)
6. **F2-02/DTRN_05/M02: use donor field/mine/rotor constants as the spec.** 49 nodes @1.6981 cells, 45°+2.4017 snap, 1.3× decals, 1.528 food clearance; mine snap 1.5 cells to nearest ore with zero/negative clearance; rotor local-Y 0.751 rad/s and mesh-frame hub. Decide explicitly whether the owner's four-patch quad (PORT APPROX) or donor node count is authoritative. (F2-02 §3–§4; F2-03 §9 item 3; M02 §3)
7. **G25 as the anti-upgrade register and the owner's "definition of good".** Every landscape class accounted for with a cited rule; fresh donor-shaped pipeline not a patch on radial-dome/rock-art; same seed byte-identical; 240² and 320² both work; no rings/vein lattice/grid; gates green; `app/` untouched; no parity claim without a donor A/B. (G25 §0/§9/§10; 2026-11-26 CHARTER §6)
8. **A11/C01/Y09 metrics as movement indicators only** (BV32, coherence, row_periodicity, tile_repeat, band anisotropy) — compare at an identical camera/crop, never as thresholds or parity. (Y09 §3/§5; Y10 §6; G25 U-25)
9. **t6 piece PASSes as donor-feature ground truth**, not GPU parity: grass_mottled, shore_sand/rock/water_transition, ravine_face, plateau, forest_conifer/broadleaf, bushes, stones, field_crops, desert; T06 hill_ridge FAIL tells you a 2D proxy cannot fix a heightfield problem. (`docs/t6/TERRAIN_LANE.md`)

## §8 Open questions (carry into today's spec/decoder work, do not guess)

1. Which of the donor's two relief channels owns each visible feature in the reference stills — height-grid shape, `rockNvf/vs` tile art, or `terrainmeshN` prop texture? **[U]** without a donor GPU A/B (Z03 §2/§7 Q1).
2. Do the exact full float32 relief windows, engine blend order/sign and `row_flip` exist in a readable form, or must the 8×10 block means remain the only derived table? (DPATTERN-01 via A05 §7; Z04 Part B)
3. Is the donor's alpha patch truly transition-only over a second base pass, and what is the exact id+boundary→patch rule/pass count? (G25 U-31/U-34)
4. What are the engine eye-plane values, metres-per-cell literal in the binary, SM20/SM30 profile, and 25° tilt path? (G25 U-32/U-36; V786 §6)
5. For the fresh module: does COORD want byte-for-byte reuse of the landed `game.gd`/`world3d_terrain.gd` paths behind a switch, or a clean sibling module composed by `world3d.gd` with the legacy path retained behind a flag until A/B passes? (2026-11-26 CHARTER §3 item 3; Z08 §5 as precedent for a sibling module)
6. What is the exact ownership grant for `game.gd` (B03/Y08), `world3d_terrain.gd` (B04), the shader (B01/Y10) and `project.godot` (Y11) before any implementation step? (CHARTER §4; all prior implementation reports are grant-gated)
7. Does the shipped `mountain_props.json` + derived `terrainmeshN` assets actually render on a mountains map (`.import`, `AssetPaths`, `prop_count>0`, QA atom reconciled)? (Z08 G2/G6/G8; FOLD-02 C1/M7)
8. Is the current horizontal striping a sampler/LOD effect or tile-id/patch data? The Y10/Y11 captures are the decisive test. (Y10 §5; Y11 §7)
9. Which relief/mine/field classes are explicitly out of scope today, and with what cited reason (plateau props, winter/desert props, full 25-unit grid, mine snap, rotor 3D)? (Z03 B5/B6; A05 §7 #5; F2-03 §9; M02 §8)

---

*End of P06. One report written. READ-ONLY: no source, shader, config, asset, test, donor, queue or git change; no Godot process; no runner job. Donor parity UNVERIFIED; no gate or PASS claim.*
