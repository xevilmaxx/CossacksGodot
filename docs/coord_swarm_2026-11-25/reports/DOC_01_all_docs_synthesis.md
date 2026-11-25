---
id: DOC-01
title: "All-prior-docs synthesis — what exists / what is missing / how to fix (2026-11-25 3D work)"
owner: DOC-01 (documentation micro-worker)
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_GODOT_RUN__NO_CODE_EDITS
scope: "Systematic read of prior docs (governance, status, QA, AUDIT3D, COMPLETENESS, TERRAIN2, G3x, V7-8x/V7-9x, FIX*, PIECES/verdicts, audit/RENDER_ARCH/TERRAIN_*/WATER_*, plus today's landed sibling reports). One report file only."
output: "docs/coord_swarm_2026-11-25/reports/DOC_01_all_docs_synthesis.md"
labels: [SYNTHESIS, SELECTION_RECTANGLE, TERRAIN_QUALITY, STALE_DOC_AUDIT, DONOR_EVIDENCE_INDEX]
evidence_labels: [observed, derived, inferred, "fresh-code-read (DOC-01, 2026-11-25)"]
parity_guard: "No donor GPU A/B frame exists anywhere in this project. Every visual-parity claim in the docs is UNVERIFIED. This report does not change that."
charter: "docs/coord_swarm_2026-11-25/CHARTER.md (donor primary, 2D secondary, piece-before-whole, final test only at end)"
---

# DOC-01 — Consolidated prior-docs synthesis for today's 3D work

> **Cold-readable.** This synthesizes what the project's own documents say, not new
> measurement. Every statement carries a source label. Vocabulary:
> **OBS** = observed directly in a cited doc or (marked FRESH) in current source read
> by DOC-01 today; **DER** = derived/arithmetic consequence; **INF** = inference
> stated with a caveat; **STALE** = a snapshot superseded by a later doc/measurement;
> **UNVERIFIED** = no evidence exists and no value was invented.

## 1. Goal

Today's owner directive (`docs/coord_swarm_2026-11-25/CHARTER.md` §0, items 2/4/5/6/7)
asks for deep reading of *all* previous docs and a consolidated answer for the two
named 3D faults:

1. **3D selection rectangle** — drag-box selection "does not work".
2. **3D terrain quality** — "bad even without trees", requiring isolated tests on
   the smallest map in the order terrain → +trees → +shore → +mines → combos,
   with the final whole-system test only at the end.

For each topic this report answers, from prior docs (and today's already-landed
sibling reports): **what EXISTS**, **what is MISSING / UNVERIFIED**, **what fixes
were attempted and with what outcome**, and **what the donor truth is**. It then
gives the failure/anti-pattern register, a stale-prose arbitration table, a donor
evidence index, a gap ranking, and recommended micro-tasks consistent with the
charter's ownership and test-ladder rules.

**No code, config, test, shader, asset, runner job or git operation was performed
by DOC-01.** Five short read-only source inspections were made to arbitrate stale
doc claims; those are labelled `FRESH` with exact file:line.

---

## 2. Docs read list (systematic, grouped by evidence tier)

### Tier 0 — governance / current state (read in full unless marked)

| Doc | How used |
|---|---|
| `docs/RESUME.md` (411 lines, updated 2026-11-21) | master index; gates, D-xx traces, stale-prose warnings (§2 note, §7, §9, open questions) |
| `docs/SWARM_OPS.md` | §0 charter, §3 non-negotiable gates, §5b-QUALITY evidence-before-edits, §5c doc lane, §7 recursion/piece-before-whole (§7.6), §7.5 read-only shared code |
| `docs/coord_swarm_2026-11-25/CHARTER.md`, `SWARM_BOARD.md`, `PROGRESS.md` | today's goals, 14 micro-tickets, Batch A/B/C ownership, gates, S-25 decisions |
| `docs/coord_swarm_2026-11-24/WAVE7_3D_VARIANT_CHARTER.md` | variant3d architecture, seams, no-bake directive, phase-2 splits, donor-truth rule |
| `docs/variant3d/README.md` (amber snapshot), `docs/variant3d/STATUS_WAVE7_PHASE2.md` | project identity, own runner, final verdict + qualifications, historical snapshots |
| `docs/coord_swarm_2026-11-24/{CHARTER,AUDIT3D_CHARTR*,COMPLETENESS_CHARTER,FINAL_GATE,GAPS,AUDIT3D_TRIAGE}.md` | session charters, gap matrix, gate definition, triage of 10 P0s |
| `docs/DECISION_LOG.md` (D-01…D-44) | precedence, D-22 quality-first, D-23/26/27/28 gates, D-31…D-44 visual-PASS revocations, D-41/44 file grants |
| `docs/SWARM_BOARD.md`, `docs/STATUS_{AI,DECOMP,GRAPHICS,SKIRMISH,TESTS}.md` | sampled via targeted grep for board state, P0 tranche, "selftest 29/29 is not visual proof" |
| `docs/QA_REPORT.md`, `docs/REMEDIATION_PLAN.md`, `docs/DONOR_OPTIONS_GAPS.md` | final QA verdicts (O5/O7/O8), donor-licence plan, skirmish options parity |

### Tier 1 — 3D parity audits and completeness verdicts (2026-11-24)

`reports/AUDIT3D_01_models.md` … `AUDIT3D_09_runtime_proof.md` (all nine; 03, 05, 08, 09 read in depth); `AUDIT3D_TRIAGE.md`; `reports/COMPLETENESS_01_tests.md` … `COMPLETENESS_06_verdict.md` (all six; 02, 03, 04, 05, 06 read in depth); `CAMSEAM_double_subtract.md`, `D01_resow_failure.md`, `W55_visual_ab.md`, `W56_whole_map_feasibility.md` (headings), `W33_selection_aura.md` (headings/quotes).

### Tier 2 — terrain donor/fix chain (2026-11-24)

`reports/G31_donor_3d_truth.md`, `G32_heightmap_world.md`, `G33_heightmap_capture.md`, `G34_heightmap_splat.md` (full); `TERRAIN2_01_donor_pipeline.md`, `TERRAIN2_02_donor_textures.md` (sampled), `TERRAIN2_03_water_weather.md` (sampled), `TERRAIN2_04_gap_recipe.md`, `TERRAIN2_05_leftovers.md`, `TERRAIN2_06_tileindex_architecture.md` (full/sections); `V782_splat_detail.md`, `V783_donor_map_importer.md` (sampled), `V784_donor_water_shader.md`, `V785_tile_atlas.md`, `V786_tileindex_shader.md`, `V790_donor_camera_changes.md`, `V791_dual_mode_atlas.md`, `V792_terrain_integration.md` (full/sections); `V712_picking3d.md`, `V768_picking_fix.md`, `V775_pick_caller.md`, `V768/V731/V733` test atoms; `V760_light_rig.md`, `V761_donor_key_colors.md`, `V762_entity_feed.md`, `V763_missing_models.md`, `V764_donor_morph_anim.md`, `V765_donor_tints.md`, `V766_camera_jump.md`, `V767_hud_minimap_jump.md`, `V769_selftest_snapshot.md`, `V770_viewport_capture.md`, `V771_audio_vector3.md`, `V772_import_new_objs.md`, `V773_fx_world_offset.md`, `V774_consume_poses.md`, `V776_ghost_rally.md`, `V777_zoom_anchor_height.md`, `V778_ship_skins.md`, `V779_pose_memo.md`, `V780_res_dirty_gate.md`, `V781_minimap_black_fix.md` (indexed/quoted via the synthesis docs); `FIXSEL_visuals.md`, `FIXSEL_picking_orders.md`, `FIXTERRAIN_visual_quality.md`, `TERRAIN_SMALL_maps.md`, `PLAY2FIX_navbox.md`, `W51_ai_force_wave.md` (headings).

### Tier 3 — deep audit library (2026-11-21/24)

`docs/audit/RENDER_ARCH_{CAMERA,CRAFT_ANYTHING,CRAFT_ANYTHING_REPORT,PATTERNS,PORT_FEASIBILITY,REFLECTION,SHADERS,SYNTHESIS,TERRAIN,UNITS,WHY_WE_FAILED}.md` (headings/claim lines); `TERRAIN_{BEAUTY_TRIAGE,BLEND_DONOR_PLAN,CHECKERBOARD_TRIAGE,DONOR_ASSETS,DONOR_PATTERNS,DONOR_PIPELINE,DONOR_WATER,PORT_ASSETS,PORT_DECOR,PORT_HILLS,PORT_RENDER,REFERENCE_IMAGES,SANDBOX_PLAN}.md` (headings/claim lines); `WATER_{PERF,PORT_FIX,REPORT}.md`; `SELFTEST_FIVE_FAILURES.md`; `PIECES/verdict_{shore,water,grass_relief,decor}.md`, `PIECES/mines_display.md`, `PIECES/{forest_conifer,forest_broadleaf,bushes_understory,map_density,field_crops}.md` (claim/verdict sections).

### Tier 4 — today's parallel sibling reports (landed during DOC-01)

`reports/V3D_01_selection_rectangle_audit.md`, `V3D_02_terrain_render_audit.md`, `V2D_01_2d_selection_logic.md`, `V2D_02_2d_terrain_logic.md` (indexed), `DTRN_01_donor_terrain_pipeline.md`, `TEST_01_smallmap_harness.md` (all read today). These are the freshest evidence and are authoritative for current code state where they conflict with older snapshots.

---

## 3. Synthesis — Topic A: selection rectangle in 3D

### 3.1 What EXISTS (fact)

From `V3D_01_selection_rectangle_audit.md` (authoritative current code-path audit, OBS static) plus DOC-01 FRESH verification:

- **The 3D path is constructed.** `main.gd:181-182` maps `gameplay.render_mode` → `Data.RENDER_MODE` (default `"3d"`); `main.gd:578-591` builds `world3d.gd` + `camera3d.gd`; `main.gd:627-631,1010-1014` wires input via `bind_3d()` → `picking3d.gd` (`input_controller.gd:114-126`). [OBS, V3D-01 §0]
- **Drag events are captured.** `input_controller.gd:528` `_unhandled_input`; LMB press stores `drag_start` and resets `dragging` at `:608-609`; motion >6 px sets `dragging` at `:662-663`; release builds the box and applies selection at `:610-624`. [OBS, V3D-01 §1-3; FRESH confirmed `input_controller.gd:595-679`]
- **The functional algorithm is present end-to-end.** Box = `Rect2(minf(a.x,bp.x), minf(a.y,bp.y), absf(...), absf(...))` from `_screen_to_world()` at both corners (`:615-617`), loop over `game.entities` with filters `dead / player != 0 / kind != "unit"` and `rect.has_point(e.pos)` (`:619-623`), then `_set_selection(arr)` (`:624` → `:207-217` flags + `hud.refresh_selection()`). It is the 2D algorithm copied verbatim; the only adaptation is `_screen_to_world()`. [OBS, V3D-01 §3; V2D-01 §2/§3; FRESH]
- **Coordinate spaces match in the drag branch.** In 3D `_screen_to_world()` records the raw pixel in `_pick_screen` then returns `picking.ground_point()` (`input_controller.gd:455-462`), which ray-marches the heightfield and adds the deterministic half-map offset (`picking3d.gd:75-108,121-127,148-171,235-243`). Both rectangle corners and `e.pos` are SIM map-origin metres — there is **no** px/m mixing. [OBS, V3D-01 §3; FIXSEL_picking_orders.md §2.3/§4]
- **Click-pick and orders already work.** `FIXSEL_picking_orders.md` measured before 1/6 → after 10/10: unit/building pick, left-click select, selection mirror, right-click `cmd_move`, and exact destination `(155,155)`; parse, selftest 29/29 and `t_pick3d` 6/6 all green (jobs 258/259/266/272/274/276/279/280/282). [OBS, FIXSEL_picking_orders.md §5-7]
- **Selection *feedback* for already-selected units exists.** `FIXSEL_visuals.md` added `world3d_fx.sync_selection()` + `Selection3D` torus markers with 13 donor key-colour slots; probe measured 2 rings → 0 on clear, correct donor colours, selftest 29/29 (jobs 263/265/267/270/273/277). Labelled `PORT APPROXIMATION — NOT DONOR PARITY` (donor glow is engine-side/private-use). [OBS, FIXSEL_visuals.md §1-3]
- **`render_mode == "3d"` does NOT gate drag-select out**, and click/drag are mutually exclusive on release. [OBS negative finding, V3D-01 break-point rows 7-8]
- **`picking3d._project_world()` already exists** and uses `Camera3D.unproject_position()` (`picking3d.gd:198-207`); it is used by `pick()`/`pick_res()` but not by the drag path. This is reusable for a correct screen-space box test. [OBS, V3D-01 §3/§5; FIXSEL_picking_orders.md §4]

### 3.2 What is MISSING / UNVERIFIED

| Gap | Status | Source |
|---|---|---|
| **No 3D rectangle visual.** `world3d.gd:126-127` declares `sel_rect`/`sel_active`; `input_controller.gd:1169-1172` writes them; repo-wide grep finds no draw consumer. The 2D `world.gd:3641-3647` calls `fx_layer.draw_rect()` with a white 1.5 px outline + 0.18 alpha fill; `world.gd:2141` redraw gate `if sel_active: return true` has no 3D counterpart. | **HIGH-confidence OBS (static)**; the only definitively proven break. | V3D-01 break-point #1 + §4; AUDIT3D-05 E10/P2-2 (`world3d.gd:88-89` historical); COMPLETENESS_02:84,130; COMPLETENESS_03:78,81; DEEPDEC_08:234,263 |
| **Functional drag-box never tested end-to-end in 3D.** `uitest.gd:115-123` step `select_box` calls `_set_selection(_peas().slice(0,3))` directly; `selftest.gd` has 0 matches for `drag|sel_rect|MOUSE_BUTTON_LEFT`; `t_pick3d.gd` only checks `ground_point` finite and dictionaries returned with an identity stub camera; `testbridge.gd:82-89,121-142` has `click`, `move`, `key` but no drag command. | **OBS**; hence green 29/29 + 17/17 never covered this fault. | V3D-01 §6 + break-point #6; V2D-01 §2 row 12; COMPLETENESS_01 §2-4 |
| **Box geometry is approximate under a −32° perspective camera.** Two screen corners are ray-hit onto the terrain (with a flat Y=0 fallback for above-horizon pixels), forming a SIM-ground AABB; units are tested by ground `e.pos`, not their projected body point. Screen box ≠ ground box under perspective; mis-selection/over-selection near frame edges is plausible. | **DER/INF, magnitude UNMEASURED** (not a proven total failure). | V3D-01 break-point #3; V2D-01 §3 row "inside-box"; `picking3d.gd:148-171`; `camera3d.gd:232-252` |
| **Double-click select-all-of-type uses a stale `view_rect`.** `world3d._update_view_rect()` trusts a stale comment and omits the half-map shift for `Vector2` corners that `hud3d_adapter.gd:62` applies; the path at `input_controller.gd:632-635` can select the wrong set. | **MEDIUM-HIGH DER** (single prior measurement). Separate call site from drag. | V3D-01 break-point #5; PLAY2FIX_navbox.md:14-29,69-83; AUDIT3D-05 E9 (historically `view_rect` = full map via Vector2/Vector3 mismatch) |
| **Drags that start/end over the minimap are preempted** and the camera jumps instead (`input_controller.gd:543-554,656-661`; `hud.gd:1409-1443`). | **OBS (static)** | V3D-01 break-point #4 |
| **Latent `_pick_screen` mutation**: `_screen_to_world()` is called at `:555,:615,:616,:1167-1168,:1239`, overwriting the pixel that a later `_pick()` uses. Not used by the drag branch; hazard for mixed guard/cursor paths. | **DER** | V3D-01 §5 |
| **Donor drag-rectangle truth is engine-side/UNVERIFIED.** Donor `misc.script:7-27` exposes only `GetCountGameManagerPickedObjects`/`GetHandleGameManagerPickedObjects`; `GameManagerIsSelectionMode`/`GameManagerCancelSelection`/`gbool_gui_isselectionstarted` in `onmousedown.inc:364-390`, `onmousemove.inc:5-30`; no rectangle geometry/z-order, radius or depth rule is script-readable. DSEL-01/DSEL-02 were RUNNING when DOC-01 read the board. | **OBS donor (negative) / UNVERIFIED** | V712_picking3d.md §2; DEEPDEC_08:78,146,177,234; V3D-01 open Q3-4; 2026-11-25 SWARM_BOARD rows DSEL-01/02 |
| **Aura extras absent**: 2D building progress arc, four pulsing corner diamonds, garrison pips, unit facing tick, squad links, selected-building rally pennant; donor glow textures/geometry unmapped. | **OBS** | FIXSEL_visuals.md §4 Q4; COMPLETENESS_02 §4 rank 5; V2D-01 §3 |

### 3.3 Fixes attempted and outcomes (selection)

| Attempt | Outcome | Evidence |
|---|---|---|
| **V7-12 `picking3d.gd` created** (screen→ground ray, `pick`, `pick_res`) | Parse PASS (job 26); runtime behaviour explicitly UNVERIFIED then; `BODY_LIFT_M=0.8` admitted guess, world offset calibration assumed flat Y=0 (later wrong). | V712_picking3d.md §4-6 |
| **V7-52 integration seam** (`input_controller.gd` routes `_screen_to_world/_pick/_pick_res` through `picking3d`) | Broke click-pick/order mapping: V7-81 changed `camera3d.screen_to_world()` to centred metres, `_recalc_offset()` self-calibration returned `(0,0)`, so entities projected at sim coords while camera/ray were centred → nothing selectable, orders 160 m short. Before probe 1/6. | FIXSEL_picking_orders.md §2.3/§3; AUDIT3D-05 E8/E13 |
| **FIX-SEL (2026-11-24)** rewrote `_recalc_offset()` deterministic half-map offset + `jump_to_world()` guard; `unproject_position()` for projection; per-depth `_pixel_reach()`; 3D patrol route as `MeshInstance3D`/`ImmediateMesh` | 10/10 probe PASS (job 279), selftest 29/29 (280), `t_pick3d` 6/6 (282); no visual-parity claim. Residual: `BODY_LIFT_M` unverified, yaw-0-only reach, behind-camera depth clamp. | FIXSEL_picking_orders.md §4-7; AUDIT3D_TRIAGE RB-11/RB-12 in TERRAIN2_05 |
| **V7-68 / V7-75 `players_only` fix** (callee + caller) | V7-68 measured true→friendly / false→enemy (job 127); V7-75 forwarded the flag from `input_controller.gd:396` (job 141 5/5) and fixed E18 shift+group via `jump_to_world()` (job 151 2/2); selftest 29/29 (144). | V768_picking_fix.md §5; V775_pick_caller.md §4-5 |
| **FIX-SELECTVIS (2026-11-24)** selection rings/owner colour | 13/13 probe (job 273), selftest 29/29 (277), but explicitly `PORT APPROXIMATION — NOT DONOR PARITY`; no donor A/B. First probe 267 failed because `queue_free()` deferred removal → switched to immediate `free()`. | FIXSEL_visuals.md §3 |
| **AUDIT3D-05 P2-2 proposal** "draw the drag rectangle in 3D by projecting `world3d.sel_rect` corners with `camera3d.world_to_px()`" | **Not implemented; and V3D-01 warns this is a trap**: `world_to_px()` expects centred metres while `sel_rect` holds SIM metres → second half-map subtract. Prefer a viewport-pixel `CanvasLayer` overlay in `input_controller.gd`. | AUDIT3D-05 P2-2; V3D-01 Fix B; CAMSEAM_double_subtract.md §9 |
| **W5-5 visual A/B attempt (2D)** | Zoom/startup visually PASS (real windowed frames, 245,740 changed px), but **aura UNVERIFIED** — selected building was off-screen; only 1,832 changed px of yellow HUD hint text in the world region. Lesson: a capture without the feature in frame is not an A/B. | W55_visual_ab.md §3-5; D-31/D-33 (PASS claims revoked for contaminated/off-feature crops) |

### 3.4 Donor truth for selection (what docs actually establish)

- Donor selection is **engine-side**: `misc.script:7-27` counters/handles; `onmousedown.inc:364-390`, `onmousemove.inc:5-30`, `GameManagerIsSelectionMode`/`gbool_gui_isselectionstarted` state flags. No script-readable rectangle geometry, z-order, pick radius or overlap-depth rule. **Do not invent a donor literal for the 6 px threshold, 4 px draw gate, +1.4 m grab margin, 0.8 m body lift or 2 m fallback** — all are port approximations. [OBS/UNVERIFIED, V712 §2; DEEPDEC_08:78; V2D-01 §5]
- Donor `gKeyColor` has **13** colour slots (`classes.script:7986-8015`, `gc_MaxColorCount=13`, applied at `unit.script:3860`, `player.script:2971`, `misc.script:5070-5073`); port shipped JSON has 13 slots, alpha UNVERIFIED. [OBS, FIXSEL_visuals.md §1; AUDIT3D-02]
- Donor control-group semantics differ from the port: donor Shift+N **adds to group** and group 0 exists; port Shift+digit recentres camera and only groups 1–9. Donor hotkeys include Ctrl+Alt+A / Ctrl+Shift+A, Ctrl+Q, Ctrl+Z / Ctrl+Shift+Z. [OBS, V2D-01 §2 row 11/§5; PROGRESS:999-1000; MICRO row 28]
- **Conclusion for today:** donor truth does not yet decide screen-space vs ground-space box test; DSEL-01/02 are the authority. Until they report, keep 2D semantics (ground/SIM AABB) as the baseline but prefer the already-proven `unproject_position()` projection for 3D correctness, labelled as a port implementation, not a donor parity claim. [INF]

---

## 4. Synthesis — Topic B: 3D terrain quality (with trees/shore/mines combos)

### 4.1 What EXISTS (fact)

The current path is **plumbed correctly** — this is the central conclusion of `V3D_02_terrain_render_audit.md` (freshest full audit) and `COMPLETENESS_03_donor_fidelity.md`:

| Stage | Exists | Evidence |
|---|---|---|
| Height grid | Live `game.height` Float32 (metres, ±2.964 ↔ donor `cMaxHeight=2.96`); one indexed `ArrayMesh`, 320² = 102,400 verts / 203,522 tris / 1 surface; central-difference normals; cell-centre UV | V3D_02 §Data-flow; G32 §1/§6; V731 test 6/6; `t_smallmap_terrain.gd` 21/21 at 64² |
| Tile index | **Live** `game.tileblock` uint8/cell → `_decode_tile_indices()` → `ARRAY_TEX_UV2.x`; 102,400 UV2 entries, 0 mismatches; `BLK_WATER=255` clamped to [0,123] by a port guard | V792 §2/§3; FIXTERRAIN §7 ticket 293; COMP-03 S1/E1 (Green) |
| Face mode | `UV2.y ∈ {0,1,2}` from donor-readable `cDiff1=0.5`, `cDiff2=0.55` (`texturemap.inc:63-64`) + aspect axis; FIX-TERRAIN promoted ~7% at 320² (`{0:95252,1:3416,2:3732}`); flat-grid regression → 0 | FIXTERRAIN §4/§7; V3D_02 row P5; TERRAIN_SMALL 21/21 |
| Atlas + masks | V7-85 16×8 atlas of 124 named 1024² cells (121 filled / 3 empty `alpha0a/b/c`), 179,912,941 B; donor masks `alpha.bmp` 512×256 and `alphavert.bmp` 1024×512 converted, intensity repacked R→A; loader modes `single` (default) → `split` → `array` | V785 §2-§6; V791 §9; V792 §3; COMP-03 E2 |
| Shader | `terrain_tileindex.gdshader` transcribes donor equations (Blinn-Phong, PCF 3/9 tap, fog modes) with donor literals (`face_scale=0.125`, `shadow_offset=1/512`, `fog_mode=0`); compiles clean (probe 47/47) | V786 §1/§4; COMP-03 E1 |
| Light rig | `WorldEnvironment` + `DonorSun` wired in `_make_environment()` (V7-60); **shadows intentionally OFF** by explicit user decision (sun + terrain cast) | V760; V3D_02 row P3/"already correct" #6; FIXTERRAIN §6 |
| Water | `water3d.gd` + `water3d.gdshader`: `diffusewaves0.png`, donor literals −0.25/−0.1/2.96, height-aware `bind_height_grid()`, one `WaterPlane`; old constant quad fallback-only | V784 §5-§7; V792 §3 (20/20); COMP-03 S2/E4 (Green data) |
| Props (trees/mines/stumps/food) | Present as static donor OBJ resource meshes via `world3d_entities.add_resource()` with donor `ENV_SCALE` (mine 0.3152, tree 0.5, stones 0.329 ±15%); `POOL_TREE`; sid resolution `mine_<ty>` | V3D_02 row P13; `world3d_entities.gd:113-118,1269-1315`; mines_display §1.1; forest_conifer §1 |
| Smallest-map harness | `tests/fixtures/small_map_64.json` / `small_map_128.json`, `t_smallmap_terrain.gd` (21 structural checks: 4,096 verts / 7,938 tris / face_hist / atlas grid / shadow state / one water plane), `smallmap_capture.py` `stats`/`scan-stderr`, real `Screenshot3DViewport` capture | TERRAIN_SMALL §3-§5 (64 probe 21/21, capture OK, 128 READY_NOT_RUN); TEST_01 §"current harness facts" |
| Functional gates | variant selftest 29/29 (job 254), uitest 17/17 (255), `t_render_mode` 10/10 `seam_missing=false` (256); 2D 29/29 (1342)/17/17 (1341)/CLEAN | STATUS_WAVE7_PHASE2 FINAL VERDICT; COMP-01 §1; COMP-05 §5 |

### 4.2 What is MISSING / UNVERIFIED (ranked causes of bad quality)

`V3D_02` problem table (P1–P15) is the authoritative current list. Condensed:

| ID | Cause | Class / status | Source |
|---|---|---|---|
| **P1** | **Tile data dominance, not a render bug.** Live tileblock: 31 ids 0..85; top five = 73.0% of cells; `test7/8/9` transition tiles = 14,358 cells (14.0%); only 82 unique block PNGs serve 124 cells (`grass_ground1`/`grass_ground3` byte-identical). Repeated light "maze" pattern is art/data. | OBS measurement, INF visual. ACTIVE. Cannot be fixed in terrain module/shader. | FIXTERRAIN RC1; V785 §6; TERRAIN_SMALL §6; V3D_02 P1 |
| **P2** | **Neutral eye-plane UVs** `eye_plane_s/t=(1,0,0,0)/(0,1,0,0)`, identity `texture_matrix`, `uv_repeat=(1,1)` → `t` = eye-space Y (height+depth mix), 1 m repeat; tile art slides/stretches with camera. Donor `gl_EyePlaneS/T[0]`/`TextureMatrix[0]` engine-bound, unreadable. | OBS defaults, DER camera-dependence, INF visual. **Largest shader-side gap.** | V3D_02 P2/F1; FIXTERRAIN RC5; V786 §2 ledger D06; COMP-03 gap 2 |
| **P3** | **Shader is an unshaded headlight**, not donor sun: `light_position_eye=vec3(0)` ⇒ `l=e`, `h=e`; `render_mode unshaded` means the real `DonorSun` never lights terrain; donor ambient/diffuse recorded but unused (raw swap measured only +0.9 luma, rejected). Shadows off by user decision. | OBS math, DER, INF. ACTIVE. | V3D_02 P3/F2; FIXTERRAIN RC4/§5; COMP-03 E7/E8 |
| **P4** | **Atlas packing + alpha sub-rect mapping approximate.** One whole preset per 1024² cell; donor `TileSize=64, Rows=16, Cols=16, AlphaRows=8, AlphaCols=4, AlphaTileSize=64` commented (`reftile.lib:3-12`); no cell→sub-rect mapping. | OBS commented donor + DER. UNVERIFIED. | V785 §7 #2; V3D_02 P4/F4; DTRN_01 C7 |
| **P5** | **Face promotion partial.** FIX-TERRAIN's `_face_mode_at` promotes slope cells but never changes `UV2.x`; donor `rockNvf/vs` 25° tilt metadata (`tiles.lib:119-136`) not applied; RGB stays base block. Exact promotion ENGINE/UNVERIFIED. | OBS/DER, AMBER. | V3D_02 P5/F5; COMP-03 RAG row 2b (Red); V792 §6.1 |
| **P6** | **Dark horizontal/diagonal water bands** from height-aware `water3d.gdshader` discard/coastfade on a full-map quad; `hmapMin/Max=±2.96` port approximation; **controlled shadow A/B changed 0 pixels** (terrain shader unshaded), so these are not shadows. | OBS A/B attribution; INF exact appearance. ACTIVE. Worse on small maps (features scale up). | V3D_02 P6/F6; TERRAIN_SMALL §6; FIXTERRAIN §5 ticket 291 |
| **P7** | **`mask_to_alpha=1.0` structurally wrong but deliberately kept**: donor `bmTransparency` has a second base-tile pass; port one `blend_mix` pass. Removing mask darkened luma 42.735→38.425 (bright sky behind) → rejected experiment. | OBS measurement + DER. ACTIVE, diagnostic knob. | V3D_02 P7; FIXTERRAIN §5 |
| **P8** | **Smooth normals erase stepped relief**: one vertex per 2 m cell, central differences over `2*TILE_M`, no wall mesh/LOD; `TILE_M=2.0` port-only; donor height-grid→triangle/LOD connector UNVERIFIED. Donor has 4 placed relief props (`terrainmesh1..4.osm`), not LODs of one mesh. | DER/INF. ACTIVE. | V3D_02 P8; COMP-03 row "terrain relief"; G31 claim 7; DTRN_01 C25 |
| **P9** | **No donor view-depth fog / clouds / real sky.** `fog_mode=0`, `fog_enabled=0`; active fog is port FOW overlay (off by default); port-tuned `ProceduralSkyMaterial`, no cloud nodes; donor `colors.lib` FogStart 390/End 490 readable but dormant. | OBS/DER. ACTIVE. | V3D_02 P9/F7; COMP-03 E8/E9/S5; DTRN_01 C20 |
| **P10** | **Fallback splat grain** 1 (now ~4) texels/cell vs 2D's 64 px/cell; in-cell deviation 1.233/255. Conditional — not the active path. | OBS; low impact. | V782; V3D_02 P10/F8 |
| **P13** | **Trees/shore/mines are NOT missing at data level** (atlas has shore ids `sandsea1..6`/`sandrock1..6`; resource meshes exist); gaps are static bind pose, no sway, no donor forest/stone environment-texture painting (`texturemap.inc:34-38`), `res_dirty` feed. | OBS presence, INF perceived absence. | V3D_02 P13; V785 §3; mines_display §1; forest_conifer §1 |
| **P15** | **Tests pass while ground looks bad:** `t_terrain3d.gd` asserts API/geometry only; the 64² probe adds structural checks but no donor A/B or pixel metric. | OBS. ACTIVE verification gap. | V3D_02 P15/F9; COMP-01 §2 (`t_terrain3d` stale relative to V7-92) |
| **Universal** | **No donor GPU A/B anywhere.** Real `Screenshot3DViewport` frames exist (outside repo) but no donor frame at matched seed/camera/zoom; all "visual PASS" candidates in history were revoked (D-31…D-38). | OBS by charter. BLOCKS every parity claim. | COMP-03 E20/gap 1; STATUS FINAL VERDICT; D-31…D-38; W55 |

### 4.3 Fixes attempted and outcomes (terrain)

| Attempt | Outcome | Evidence |
|---|---|---|
| **M0.6 per-tile flat quads + wall quads** (legacy `app/` sandbox) | **VISUAL FAIL**: terraced mosaic, grid-aligned stripes, 32×32 window (1% of map), lighting compensation, FOV trade-off; metrics improved (cliff 2921→0, seams 0, L 80.65, 78 calls/16 ms) while visual FAIL stood. Do not revive. | G31 §3/claim 10; SWARM_BOARD:407-428; RENDER_ARCH_WHY_WE_FAILED |
| **G3-2 full-grid ArrayMesh + G3-4 splat** | Structural fix verified (102,400 verts/203,522 tris, 129 ms, non-blank capture, SHA `fc7b21e0.`); honest verdict `GEOMETRY_FIX_VERIFIED__DONOR_FIDELITY_NOT_CLAIMED`, still flat/near-uniform at donor-valid framing (span 0.0059 at 40 m). | G32 §1/§7; G34; G33 (A/B half missing; M0.6 PNG gone) |
| **V7-84 donor water shader** | Probe 10/10 after real compile fixes (`fog_enabled` float→int; one-time shader errors), all donor literals read back; reflection/shadow/hmapTex deliberately unported. | V784 §6-§8; COMP-04 E11/E14 (fixed) |
| **V7-85 atlas + V7-86 shader + V7-91 loader + V7-92 integration** | Measured 124 cells, 121 filled, 31/31 ids resolvable, 3-mode loader 24/24 then 28/28, shader 47/47, integration 20/20, selftest 29/29, windowed capture; **no visual parity claim**. `single` default restored at user request; 180 MB PNG must stay uncommitted or LFS. | V785 §6; V786 §4; V791 §9; V792 §3/§7; COMP-05 F-01 |
| **FIX-TERRAIN (face promotion + shadow disable)** | Parse clean, probe 20/20, selftest 29/29; **controlled** face A/B 52,887 px changed (5.74%), luma 42.735→42.961 — the only quantitative claim; shadow A/B 0 px changed (honest limitation). Rejected and reverted: mask-blend removal (luma −4.31), donor light-colour swap (+0.67, not donor-faithful). | FIXTERRAIN §5-§8 |
| **TERRAIN-SMALL 64²/128² harness** | 64² probe 21/21, 64² capture OK (0 full-width dark rows), 128² READY_NOT_RUN; confirmed tile-art repetition and water bands reproduce at 64², shadow streaks absent. | TERRAIN_SMALL §4-§9 |
| **2D piece renderers (PIECES/verdicts)** | Shore 21/23 rows PASS after tool upgrade (M2 still FAIL: 3 sandsea sectors); water glints 1 trivial PASS/3 FAIL (no sun vector), shallow 3 PASS/7 FAIL; grass/relief 22 PASS/15 FAIL/9 UNVERIFIABLE. **All are Pillow depictions, not Godot frames** — do not close engine tickets from them. | verdict_shore §4-§7; verdict_water Overall; verdict_grass_relief §0/§8 |
| **D-31…D-38 visual PASS revocations** | T02/T05/T12 PASS claims revoked after coordinator review (defects unchanged / contaminated crops / feature-less surfaces); specific criteria adjudicated N/A when the *metric* demanded what donor truth refutes. Restore PASS only with clean, feature-containing donor panels + second-agent verification. | DECISION_LOG D-31…D-38; COMPLETENESS_CHARTER |

### 4.4 Donor truth for terrain (most load-bearing facts)

- **Representation:** one integer tile index per cell (`TMapTerrainDataTile{height,tex,collision[4]}`, 640² grid; `dmscript.global:2026-2035`, `:78-81`), generated at runtime by `SetTileIndex`; **no stored donor tile-index/splat array exists**. Two samplers: RGB from unit 0, alpha from unit 1 (`hf.pvl.smx3.frag:13-14`). Donor blending is **discrete tile selection + 3-pass compatibility smoothing + alpha-atlas modulation**, not splat weights/vertex colours. [OBS V1+V2, DTRN_01 C1/C2/C8/C9]
- **Tile atlas metadata (commented but readable):** `TileSize=64, Rows/Cols=16, AlphaRows=8, AlphaCols=4, AlphaTileSize=64` (`reftile.lib:3-12`); `sand1-4` 64/2/2; 124-name Summer index table (`terrain.presets:2-6`); 112 tile DDS (110×1024², sand1/2×256²) + `alpha.bmp` 512×256×8 + `alphavert.bmp` 1024×512×24. [OBS, DTRN_01 C3-C7; V785 §1]
- **Metres per cell is UNVERIFIED** (`TILE_M=2.0` is port-only). Filtering is nearest-mag + nearest-mipmap-linear, **no anisotropy** (`reftile.mat:24-49`). No terrain normal map exists. [OBS, DTRN_01 C6/C16/C18]
- **Slope/shore/cliff selection:** 8-sector aspect classification (`texturemap.inc:433-448,474-529`), cliff overrides `abs(h)>2.7→rock8`, `>2.4→rock4`, `<0.1→none` (`:557-611`), roads use `ground1`/`test2`/`test3` from mask alpha (`:617-646`), `test*.dds` are **real soil textures** used in the wrong semantic role by the port (not "placeholders"). Weight table `sandsea1..4=1`, `5=0.7`, `6=0.3` (`tilesmooth_scripts.cfg`). Shore band classification `[-0.25,-0.1)`; no foam texture family exists (foam procedural in `water.dev.frag`). [OBS, DTRN_01 C10-C15; mines_display §1.4; TERRAIN_DONOR_WATER]
- **Shading:** per-vertex Blinn-Phong (`hf.pvl.sm.vert:9-23`), fragment `rgb*TexCoord[4]+TexCoord[5]`, 3-tap (`of=1/512`, `/3`) or 9-tap (`/9`) PCF `sampler2DShadow`, fog modes 1/2/3 with `1.442695`; which SM profile is active is UNVERIFIED. `gl_EyePlaneS/T[0]` and `gl_TextureMatrix[0]` are engine-bound/UNVERIFIED. [OBS/DER, DTRN_01 C19; V786 §1 D06/D14-D16]
- **Fog is OFF by default in the donor** (`FogMode=0`, FogStart 390/End 490, `camera.cfg:59 DynFogDepth=False`); do not enable unconditionally. [OBS, DTRN_01 C20; COMP-03 S5]
- **Water:** height-aware 2×2-cell fields, discard where `height>level`, coast fade 0.57 / deep fade 1.07, alpha `coastfade2`; bound textures `DiffuseWaves0` (luminance) and `DiffuseWaves2` (normal material), `HeightMapWaves0` commented; `hmapTex` binding UNVERIFIED; reflections projected (`texture2DProj`), cubemap vs live FBO UNVERIFIED; Fresnel block commented in shipped fragment. [OBS/UNVERIFIED, DTRN_01 C21-C23; WATER_REPORT §2.3; V784 §8]
- **Relief props** `terrainmesh1..4.osm` + `terrainplateau1..4` are placed assets with summer/winter DDS, not LODs of one mesh; height-grid surface topology/LOD connector UNVERIFIED. Donor terrain albedo art includes 25° oriented `rockNvf/vs` / `sandNf/s` face blocks reusing base `.dds`. [OBS, DTRN_01 C25; G31 claim 7; V785 §1 E4/E5]
- **Trees/mines:** donor tree families `spruce/pinesmall/firsmall/pinedry` with 4 authored meshes each and ±15% `envscales` jitter; mines share one `.osm` silhouette (byte-identical), scale 0.3152 with **no jitter** (contrary to the port's blanket 0.85–1.15 claim); mine prop ≈4.7×5.0×0.6 m ≈2.4×2.5 tiles; placement pattern `mng_1` = 8×10 cells, generator rings 14–22/32–42/70–82/22–38 m, 256 angle tries; **no donor reference image contains a clear mine** (visual reference UNVERIFIED). [OBS/DER, mines_display §1; forest_conifer §1; DEEPDEC-01/dogenerate.inc]
- **Forest density targets:** 20–60 / 150–250 / 650–1000 trees per megapixel; donor per-cell detail density ≈1953 trees/MP (2–3× dense) in the port reconstruction; only 2/15 forest families reachable in the 2D port; broadleaf lit family hue 53–70°, sat 0.43–0.59, lit B ≥48. [OBS/DER, TERRAIN_REFERENCE_IMAGES §3.2/§5; forest_conifer §1; forest_broadleaf §1; TERRAIN_PORT_DECOR]

### 4.5 Combos: what docs say about trees/shore/mines *in combination*

- **No prior 3D combo test exists.** `t_terrain3d.gd` tests geometry only; `t_smallmap_terrain.gd` tests structural terrain+water presence but not trees/mines in isolation, and its 64² capture is a full-game frame (all layers mixed, no toggles). [OBS, V3D_02 P15/"what is already correct" #12; TEST_01 §"current harness facts"]
- **Data is present but feed-gated**: shore tile ids in atlas + live tileblock, tree/mine/stump meshes via `world3d_entities.add_resource()`, `res_dirty` gate; perceived absence is an inference, not missing data. [OBS/INF, V3D_02 P13]
- **TEST_01's proposed ladder** (design only, no code) is the authoritative plan for today: 64² stub, one atom per row, P0 terrain-only → P1 trees → P2 shore → P3 mines → C1 trees+shore, C2 trees+mines, C3 shore+mines, C4 all → S1 selection rect (real boot) → FINAL whole gate. Each row asserts structural invariants + a real `Screenshot3DViewport` PNG, `scan-stderr` SCRIPT ERROR = 0, and no donor parity claim. Recommendation: 64² as the ladder map (32² config floor 16² but generator clear rings would suppress features); 128² as a second rung after 64² green. [OBS, TEST_01 §test ladder/§smallest-map/§summary]
- **V3D_02's ladder** is equivalent (T0 terrain only / T1 +trees / T2 +shore / T3 +mines / T4 combos / T5 controlled shader A/B) and explicitly warns that copied 2D tools (`t_shore_smoke.gd`, `visual_tuning_test.gd`, `t_water.gd`, `terrain_piece_render.py`, `tools/pieces/t6_*`) target `app/`, not the 3D path — reuse their acceptance *ideas*, not their harnesses. [OBS, V3D_02 §"Piece-test ladder"/§warning]

---

## 5. Prior failures not to repeat (with citations)

| # | Anti-pattern | What happened / why it matters | Citations |
|---:|---|---|---|
| 1 | **Visual PASS without a donor A/B** | Real 3D pixels exist, but no donor frame was ever captured at matched camera; COMP charter forbids parity claims; multiple PASS claims were revoked when the coordinator actually opened the sheets. Never write "looks donor-like" from metrics or node counts. | COMP-03 E20/gap 1; STATUS FINAL VERDICT; D-31…D-38; W55 §5; verdict_water §0 |
| 2 | **Contaminated / off-feature donor crop** | T02/T05/T12 PASS claims revoked: defects unchanged, donor crop contained UI/minimap/wooden siding, or selected building off-screen (only yellow HUD text changed). Binding intake rule: parent must open every compare PNG and validate the donor crop contains the feature. | D-31, D-33, D-37, D-38; W55 §3-5 |
| 3 | **Metrics override visual review** | M0.6: cliff metric 2921→0, seams 0, 78 calls/16 ms — still "flat top-down mosaic, visual FAIL". `RENDER_ARCH_WHY_WE_FAILED` H2: "we understood and then substituted approximations, and our gates rewarded the approximation." | G31 claim 10; RENDER_ARCH_WHY_WE_FAILED H1/H2; CHARTER "metrics never override visual review" |
| 4 | **Seams / flat-Y / double-subtract coordinate bugs** | M0.5 dead-band left literal cracks; M0.6 traded cracks for grid-aligned stripes; V7-81 centred camera + old self-calibration gave `(0,0)` offset → all picks/orders broken; CAM-SEAM v1 clamped before transform and froze a stale memo → unclamped corner focus / black view. Never project SIM metres through `camera3d.world_to_px()` (expects centred metres); never re-calibrate a frame offset by comparing a function to itself. | FIXSEL §2.3/§3; CAMSEAM §9; PLAY2FIX_navbox; V3D_01 Fix B warning; COMP-04 H1 |
| 5 | **Tile-index pitfalls** | Live field is one uint8 per cell (`game.tileblock`), **not** 4 sub-tiles; donor `tsDouble/ttExtended` sub-atlas values are commented; `BLK_WATER=255` must be clamped; `game.tileblock` byte-identity to donor `GetTileIndex` is UNVERIFIED; 82 unique PNGs serve 124 cells; 3 `alpha0*` cells empty. Do not invent sub-tile indices or a metres-per-cell constant. | FIXTERRAIN Q2; V785 §3/§7; V792 §6.8; DTRN_01 C6/C7; TERRAIN2_06 §5 |
| 6 | **Queue orphans / direct `godot`** | Six 100%-CPU orphans (D-01) → single FIFO runner (D-03); 100–400 s waits are normal, never re-submit; probes that forget `quit()` in `_initialize()` get hard-killed (FIXSEL ticket 260, V768 103, V791 230). Headless stub work must run in the first frame, not `_initialize()`; defer `quit()`. | D-01/D-03/D-16; RESUME §4/§8; FIXSEL §5; V768 §5; V791 §5 |
| 7 | **Stale docs / stale artifacts** | RESUME/STATUS/GAPS snapshots (2026-11-21) still say 28/28, P-04 BLOCKED, "no 3D pixels", "no light rig", 14/21 identical scripts, "60 unacked" (now 84). `t_pick3d.json` still records stale `MODULE_MISSING`; `t_terrain3d.json` predates V7-92. Re-verify current source/artifacts before acting. | RESUME §2 note; TERRAIN2_05 DOC-01…DOC-08; COMP-01 §2-3; COMP-05 §4; V3D_02 open Q9 |
| 8 | **Weakening a test to obtain green** | `grid_equiv` assertion is inert (mismatch branch `pass`); D-25 showed radius 5→6 regressed clearance 94→83% while inclusive `>=` fixed it — the plausible prescription was wrong. Never retune a correct generator/test to please a stale judge; latch the truth (e.g. resow should latch first tick `hits>0`, not sample terminal state). | GAPS G-T5; D-24/D-25; D01_resow_failure §root cause; T01_selftest_taxonomy |
| 9 | **"Fix" what is already correct** | Live tile index→shader, manifest atlas grid, mask alpha repack, full-grid mesh, donor rig, shadow-OFF decision, shader compilation and CAM-SEAM are all done/verified. V3D_02 §"What is already correct — do not redo" is the guard list. | V3D_02 §"already correct"; COMP-03 RAG Green rows; FIXTERRAIN §6 |
| 10 | **Coupling selection to visuals or orders accidentally** | `_pick_screen` is overwritten by unrelated `_screen_to_world()` calls; drag and click must stay mutually exclusive; never change `cmd_*` call sites, `_set_selection`, 2D branches or donor tint batches when fixing the rectangle. Preserve byte-identical 2D path. | V3D_01 §5; FIXSEL §4/§6; V775 §4; SWARM_OPS §3.6 minimal diffs |
| 11 | **Assuming the donor is 2D** | "Optimized 2D perspective" hypothesis refuted: donor is a perspective OpenGL renderer (tilt −32°, focal 400, live meshes/skinning, lit heightfield). The ortho branch serves HUD/editor. Treat 2D port as SECONDARY only. | G31 claims 1/8 + §6; RENDER_ARCH_CRAFT_ANYTHING; RENDER_ARCH_SYNTHESIS |
| 12 | **Unowned parallel edits / missing backups** | Cross-file edits = REVIEW BLOCK; each builder owns exactly one file; backups `inbox/backup/<name>.bak-<TICKET>`; today's analysis phase is strictly read-only, one report per worker. | SWARM_OPS §3.2/§7.5; 2026-11-25 CHARTER §1/§3; S-25-01 |

---

## 6. Doc truth vs stale prose — arbitration table

| Topic | Stale / conflicting prose | Authoritative source (and why) |
|---|---|---|
| Gate counts | `AGENT_PROTOCOL.md §2`, `SWARM_OPS.md §3.4`, RESUME/STATUS say **28/28** or board P-04 BLOCKED; some say "24/29"; QA O7 section briefly said 18/19 FAIL. | **29/29 + 17/17 + CLEAN**, D-21/D-23/D-26/D-27/D-28; `QA_REPORT.md` ABSOLUTE FINAL (jobs #570-573, suite 19/19 at 11:41:06); app JSONs are live truth. Later verdict supersedes earlier section. |
| 2D release state | QA_REPORT mid-document `FAIL` (t_mass_army) vs later `PASS` | Later **SIGNED-OFF FINAL / ABSOLUTE FINAL PASS** sections supersede it; the failing check was a harness defect fixed in ticket 427. |
| Map size | `data.gd:33-34` static 160; 160-tile radius notes in QA | **320 tiles** is working size (D-24; `config.gd:405-406`, `game.gd:213-214`; deep-GEN 28–44 tile mine distances donor-faithful). 160 is pre-config default / stale judge radius. |
| 3D pixels | AUDIT3D-09 "no real 3D pixels; CPU map fallback" (jobs 73/77) | **Closed** (G1): `Screenshot3DViewport` jobs 138/179 produced real GPU frames. AUDIT3D-09 is a historical snapshot; STATUS FINAL VERDICT and V770 are authoritative. |
| Light rig | AUDIT3D-03 P0 "no donor light rig / unwired `heightmap_world3d.gd`" | **Closed** (V7-60): `world3d_terrain.gd:553-593` wires `WorldEnvironment`+`DonorSun`. AUDIT3D-03 predates V7-60/84/92; COMP-03 E6 and V3D_02 "already correct" #6 re-verified in current source. |
| Water | AUDIT3D-03 P1-2 "flat constant quad, no donor shader" | **Closed at data level** (V7-84/V7-92): `water3d.gd` binds `diffusewaves0.png` + donor literals; old quad fallback-only. COMP-03 S2 Green (data) but mechanism still APPROX. |
| Terrain albedo | AUDIT3D-03 "one static 320² splat is the active path" | **Superseded**: live `game.tileblock` → UV2 → 124-cell donor atlas + V7-86 shader is active; splat is fallback-only. COMP-03 S1/E1, V792, V3D_02 data-flow. |
| Face flags | COMP-03/V792 "UV2.y = 0 for all cells" (RAG Red) | **Superseded by FIX-TERRAIN** (face promotion landed; ~7% promoted at 320², 0 on flat grid; RAG now AMBER, not Green — exact rule still UNVERIFIED). DTRN_01 C27 explicitly flags the stale claim. V3D_02 row P5 is current. |
| Selection visuals | COMPLETENESS_02/03 "no 3D ring/aura; critical" | **Partially superseded** by FIX-SELECTVIS (procedural rings + donor colours, 13/13 probe). Still true that rectangle has no 3D draw consumer and aura is PORT APPROXIMATION. |
| Selection rectangle | AUDIT3D-05 E10 "selection works, no visual box"; V3D-01 refines: functional path present but untested, geometry approximate, box visual missing | **V3D-01 (2026-11-25) authoritative** — it re-read all current code and adds the untested/geometry findings that the older audits did not have. |
| Picking flag | V7-68 "enemy call sites degraded until caller forwards" | **Closed** by V7-75 (`input_controller.gd:396` forwards flag; probe 5/5, selftest 29/29). V768's handoff note is a snapshot. |
| Camera minimap bug | TERRAIN2_05 RB-01 / COMP-06 gap 1 "V7-81 fix unverified, user retest pending"; COMP-04 E6 "fixed by measurement, user retest pending" | Progression: V781 probe 11/11 → V790 8/8 → CAMSEAM 5/5 → COMP-04 "fixed by measurement"; **PROGRESS §"SESSION FINAL VERDICT"** records user-pasted clean windowed output, so the "windowed retest pending" half is itself stale; keep donor-visual-parity caveat. |
| Variant CLEAN | STATUS/COMP-01 "no `assert_clean.py`; 60 unacked" | `variant3d/tools/assert_clean.py` exists but hardwires the 2D spool; 84 unacked historical probe failures with 19 failure-status jobs → a formal variant CLEAN is **not claimed**. COMP-05 §3/§4 is the careful reading; do not silently drop the caveat. |
| Script similarity | AUDIT3D_TRIAGE "14/21 scripts byte-identical, identical audio.gd" | **13/21** in COMP-02 current-source hash check; `audio.gd` and `data.gd` diverged (3D adapters). Current source wins over the triage snapshot. |
| Test health | "t_terrain3d 6/6 PASS, t_pick3d 6/6" (V731/V733) | COMP-01: `t_terrain3d.json` stale vs V7-92's 15:54 edit; `t_pick3d.json` stale FAIL 0/6 `MODULE_MISSING`; camera test has no green artifact. Ad-hoc probes (V768 127, FIXSEL 279, V792 251) are not registered artifacts. |
| Donor terrain parity | "face promotion implemented → donor-faithful cliffs" | No — FIXTERRAIN labels `PORT APPROXIMATION`; donor promotion rule/eye planes/sub-rect mapping are UNVERIFIED; COMP-03 RAG row 2b remains Red/AMBER. Never promote an approximation to fact. |
| Piece PASS claims | `verdict_*` rows "PASS" for pillow-rendered pieces | They are **renderer depictions, not Godot frames**; T02/T05/T12 PASS claims were revoked elsewhere; build-lane must verify in-engine before closing tickets. |

---

## 7. Most valuable donor evidence ids / paths index

| Id / path | What it proves | Source doc |
|---|---|---|
| `ev_030dff8c.`, `ev_10f78080.`, `ev_cc0ee18b.`, `ev_0f634d4b.` | Donor main view is perspective, not ortho | G31 claim 1; V71 §0; V72 §1.1 |
| `ev_e000f15b…` (D-07) | Craft Anything donor investigation opened read-only | DECISION_LOG D-07 |
| `ev_392885a6.`, `ev_0bbb20c1.`, `ev_6a6b0380.`, `ev_e5ad6408.` | `.oss` layout, `.osm` IDP2, AAF ranges, ACL (bone parents unreadable) | V72 §1.1; V764 |
| `ev_6fcb0711.`, `ev_9918481e.`, `ev_1dfd1d67.`, `ev_03eb161c.`, `ev_d94dda94.`, `ev_4b104764.`, `ev_d77442d0.` | Proven `water.lib` defaults; binary block is string-key assignments + a bitmask, not shader floats | V784 §6 (DEEPDEC-03) |
| `fc7b21e0.` | G3-2 non-blank 320² capture SHA (`app/shots/hm3d_full.png`) | G32 §6; job 1334 |
| `79f93c2c…` / `b4da4ebd…` | G3-2 dump SHA / splat PNG SHA (manifest provenance) | G32 §4; G34; AUDIT3D-03 E7/E10 |
| `a1f123a1…dcfbd` / parts `019f0f9d…`, `295a527c…` | V7-85 atlas SHA / lossless split parts | V785 §2; V791 §2 |
| `C:\Games\Cossacks 3\data\scripts\dmscript.global:2026-2035`, `:78-81` | `TMapTerrainDataTile{height,tex,collision[4]}`, 640² grid | DTRN_01 C1; G31 |
| `data\terrain\tiles\terrain.presets:2-6`, `:134-138` | 124-name Summer/Winter tile index dictionaries | V785 E1/E2; DTRN_01 C5 |
| `data\terrain\tiles\terrain.lib:5-10`; `reftile.lib:3-12` | `TextureScale=1`; commented `TileSize=64/Rows=16/Cols=16/AlphaRows=8/AlphaCols=4/AlphaTileSize=64`, `tsDouble`/`ttExtended` | DTRN_01 C6/C7; TERRAIN2_06 E14 |
| `data\terrain\ref\reftile.mat:120-169`; `reftilealpha.mat:30-37,139-146` | `alphavert` eye-linear planes S=X/T=Z and S=Y/T=Z, scale 0.125; `alpha.bmp`/`alphavert.bmp` sources | V786 D17/D20; V785 E6-E8 |
| `data\shaders\obj\hf.pvl.sm.vert:9-46`; `hf.pvl.smx3.frag:13-46`, `smx9.frag:25-34` | Exact donor lighting/eye-plane texgen/PCF/fog equations | V786 §1 ledger D03-D16; DTRN_01 C19; TERRAIN2_06 E12 |
| `data\shaders\shaders.lib:15-52,914-951` | HeightField profile (SM20 smx3 / SM30 smx9), texGen/vertexColor flags | DTRN_01 C19; TERRAIN2_06 E12 |
| `data\scripts\common.inc\texturemap.inc:30-31,63-64,433-448,474-529,557-611,617-646` | Water −0.25/−0.1/2.96; cDiff 0.5/0.55; 8-sector aspect, shore/cliff/road selection | FIXTERRAIN §4; DTRN_01 C12-C14; V785 E11 |
| `data\scripts\common.inc\smoothtiles.inc:126-180,197-234,237`; `gen\tilesmooth_scripts.cfg:1-35` | 3-pass compatibility smoothing; authored transition weights 1/1/1/1/0.7/0.3 | DTRN_01 C9/C10; TERRAIN2_06 E10 |
| `data\water\water.dev.frag:37-47,106-127,167-232,237-253`; `water.lib:25,32-33,43-45`; `water.mat:1-20,32-39` | Water constants, procedural foam, height-aware discard, wave bindings, commented heightmap | DTRN_01 C21-C23; V784 §6; WATER_REPORT §2 |
| `data\env\lights\light.cfg:3-16,26-29`; `shaders\water\water.dev.vert:22` | Donor sun position/direction, ambient/diffuse/specular; Z-up→Y-up transform | G32 §3; TERRAIN_DONOR_WATER; COMP-04 |
| `data\env\colors\colors.lib:23,34-43`; `data\cameras\camera.cfg:59` | Fog table (Start 390/End 490/Mode 0), `DynFogDepth=False` → fog off by default | DTRN_01 C20; COMP-03 S5 |
| `data\game\var\envscales.cfg:16-36` (mines 0.3152 min=max=1), `:40-46` (stones 0.329 ±15%) | Mine scale has no jitter; tree/stone families have ±15% | mines_display §1.1; forest_conifer §1; P-32 |
| `data\objects\env\mine{gold,iron,coal}.prop`; `data\actors\env\mine*.osm` (byte-identical SHA `A2A6380C7521B941`) | One silhouette, material-only differentiation; ≈4.7×5.0×0.6 m | mines_display §1.1-1.2 |
| `data\game\var\generator.cfg` (`mng/mni/mnc`, 5 patterns each); `dogenerate.inc:522-717` | Mine rings 14-22/32-42/70-82/22-38 m, 256 angle tries; `mng_1` 8×10 cells | mines_display §1.3; RENDER_ARCH_CRAFT_ANYTHING_REPORT |
| `data\gui\menu.inc\onmousedown.inc:364-390`, `onmousemove.inc:5-30`, `misc.script:7-27` | Donor selection is engine-side; no readable rectangle geometry/radius/depth rule | DEEPDEC_08:78,146; V712 §2 |
| `data\scripts\lib\classes.script:7986-8015` (`gc_MaxColorCount=13`) | 13 donor key-colour slots | FIXSEL_visuals.md §1; AUDIT3D-02 |
| `app\shots\g32_dump.json:1` | 320² dump, 102,400-byte live tileblock, 31 ids 0..85, top 14:28535/0:15993/16:15962 | V792 E6; V785 §6; TERRAIN_SMALL |
| `variant3d\tests\fixtures\small_map_64.json`, `t_smallmap_terrain.gd`, `tools\smallmap_capture.py` | Reusable smallest-map ladder harness (64², 21/21, real GPU capture) | TERRAIN_SMALL; TEST_01 |

Evidence ids/artifacts **outside the repo** (do not rely on them being committed): `C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/fixterrain_*.png`, `terrain_smallmaps/smallmap_64.png`, `v792_tileindex_water.png`, `app/shots/w55_*.png`, `app/shots/pieces/*.png`. [OBS]

---

## 8. Gap ranking (consolidated, today's work in scope)

| Rank | Gap | Impact | Authority |
|---:|---|---|---|
| 1 | **No donor GPU A/B harness** — blocks every fidelity/visual-PASS claim, including terrain and selection aura | Blocking for "quality" acceptance | COMP-03 gap 1; DF-01; D-31…D-38 |
| 2 | **3D drag-box has no visual rectangle** and no end-to-end functional test (plus untested perspective geometry) | The owner's named fault | V3D-01; AUDIT3D-05 E10; COMPLETENESS_02:84 |
| 3 | **Eye-plane UVs are neutral substitutes** (camera-dependent tiling, wrong scale) | Largest shader-side terrain defect | V3D_02 F1/P2; V786 §6 |
| 4 | **Unshaded headlight** instead of donor sun; donor ambient/diffuse unused; shadows off by decision | Flat/dark ground | V3D_02 F2/P3; FIXTERRAIN RC4 |
| 5 | **Tile-data dominance** (73% top-5, 14% `test*` transitions) — cannot be fixed in the module | Repeated "maze" pattern at every map size | V3D_02 F3/P1; TERRAIN_SMALL §6 |
| 6 | **No isolated/combo 3D tests** for terrain+trees/shore/mines; copied 2D tools don't exercise the 3D path | Owner explicitly requested the ladder | TEST_01; V3D_02 §ladder |
| 7 | **Atlas sub-rect / alpha mapping + face promotion + 25° tilt approximate** | Square look, wrong cliff art | V3D_02 F4/F5; COMP-03 row 2b |
| 8 | **Water bands tint low land; `hmapTex`/reflection/shadow UNVERIFIED** | Dark bands dominate small-map captures | V3D_02 F6/P6; V784 §8 |
| 9 | **`mask_to_alpha` structurally wrong (kept by measurement)**, donor fog/cloud/sky dormant | Residual blend/lighting mismatch | V3D_02 P7/P9; FIXTERRAIN §5 |
| 10 | **Test/registry hygiene**: stale `t_pick3d`/`t_terrain3d`/`t_camera3d` artifacts, no variant CLEAN, 180 MB atlas LFS risk | Green gates are not proof of these features | COMP-01; COMP-05; TERRAIN2_05 TH-01 |
| 11 | **Double-click `view_rect` half-map offset**; minimap-overlapping drags | Related selection correctness, separate atom | V3D-01 break-point #4/#5 |
| 12 | **Aura extras / donor aura parity** | Feedback completeness (secondary to the rectangle itself) | FIXSEL_visuals Q4; COMP-02 §4 |

---

## 9. Recommended micro-tasks for today (charter-compliant)

All are **read-only analysis / test-design or disjoint single-file grants**, one output per worker, no whole-system runs until the end (`2026-11-25 CHARTER` §1/§3/§4; `SWARM_OPS` §7.5). Batch A/B tickets are already running; these are the natural Batch C atoms, gated on the reports.

1. **Close the donor-selection question first** — let DSEL-01 (`DSEL_01_donor_selection_rectangle.md`) and DSEL-02 (projection math) land, then independently re-verify the claim "donor box test is engine-side, no readable radius/threshold" with a different method (Batch B). Do not implement a 6 px/4 px/0.8 m/2 m constant as "donor". [CHARTER §0.2, §4 analysis gate]
2. **FIX-SEL-RECT — functional box test (one builder, two files at most).** Add `picking3d.select_in_rect(start_px, end_px, players_only)` using the proven `_screen_of()`/`unproject_position()` projection and a `depth>0` guard; branch `input_controller.gd` `:613-624` on `render_mode == "3d"` while leaving the 2D branch byte-identical. Ownership: `picking3d.gd` + `input_controller.gd` **one builder only** (board FIX-SEL slot). Reuse `BODY_LIFT_M` but label it an estimate. [V3D-01 Fix A; FIXSEL precedent]
3. **FIX-SEL-RECT-VIS — screen-pixel `CanvasLayer` overlay** inside `input_controller.gd` (same builder as #2 or a separate grant that does not touch #2's files — do not split one file across workers): `mouse_filter = MOUSE_FILTER_IGNORE`, draw `Rect2(drag_start, current_mouse).abs()` outline + 18% fill from `_process()`. **Do not** project `world.sel_rect` through `camera3d.world_to_px()` (SIM vs centred trap). [V3D-01 Fix B; AUDIT3D-05 P2-2 corrected]
4. **TEST-02a…d — isolated 64² terrain atoms** (`t_terrain_only.gd`, `t_terrain_trees.gd`, `t_terrain_shore.gd`, `t_terrain_mines.gd`), one file + one PNG each, using TEST_01's exact assertions and `scan-stderr`; stub game, one layer at a time; no donor parity claim. [TEST_01 §test ladder P0-P3; V3D_02 T0-T3]
5. **TEST-03a…d — combos** (trees+shore, trees+mines, shore+mines, all) on the same 64² stub; independently toggleable layers; assert "no new seam class", single water plane, no mine in water. **Only then** TEST-04 selection-rect atom (real 64² boot, N=8 units, synthetic press/motion/release, exact `selected_ids`, `cmd_*` counter 0) and finally the single FINAL gate. [TEST_01 C1-C4/S1/FINAL; CHARTER §0.6]
6. **F-TERRAIN-UV — world-ground texgen atom** (shader + terrain module, one builder): replace neutral `eye_plane_s/t`/identity matrix with a documented world-XZ projection and a meaningful `uv_repeat`; accept only if 64² controlled A/B shows stable ground texel under a known pan delta; keep PORT APPROX label until donor values are recovered. [V3D_02 F1; V786 §6]
7. **F-TERRAIN-LIGHT — donor-sun-in-shader atom**: feed the already-wired `DonorSun` direction into the shader lighting (or document why `unshaded` must stay), with a controlled 64² A/B; don't re-add a second light rig and don't re-enable shadows without a bounded donor-grounded frustum. [V3D_02 F2; FIXTERRAIN §6]
8. **Small hygiene atoms (cheap, independent)**: refresh the stale `world3d.gd:126-127` line-reference comment (V3D-01 Q7); re-run the registered `t_pick3d`/`t_camera3d` atoms after modules land so artifacts are no longer stale (COMP-01 §5); run the 128² small-map probe (READY_NOT_RUN). [TERRAIN_SMALL §9; COMP-01]
9. **Arbitration atom for DOC truth**: reconcile `docs/variant3d/STATUS_WAVE7_PHASE2.md` historical "LEFT" table + `assert_clean.py` claim with its own FINAL VERDICT (TERRAIN2_05 DOC-01/DOC-02 still open), and update `RESUME.md`/STATUS snapshots to point at the 2026-11-25 charter. [TERRAIN2_05 §5; RESUME open questions]

**Ownership guard:** all shared code is READ-ONLY until a grant; one builder per file; backups `inbox/backup/<name>.bak-<TICKET>`; only the variant runner (`python variant3d\tools\godot_runner.py`), never `godot` directly; `python` 3.14 not `python3`; app/ 2D gates must stay green. [CHARTER §1; SWARM_OPS §3; DECISION_LOG D-03]

---

## 10. Open questions

1. DSEL-01/02: donor drag-rectangle events/threshold/filter set and screen-vs-ground box test — unresolved; decides whether V3D-01 Fix A's screen-space projection is a port choice or donor-faithful.
2. Which part of "does not work" did the user actually see (no box vs wrong selection set)? One windowed repro would settle it (V3D-01 Q1).
3. Can a permitted donor GPU A/B frame be produced at 64² and matched camera? If not, every "quality improved" claim stays PORT APPROX (F0).
4. Do readable donor values exist for `gl_EyePlaneS/T[0]`, `TextureMatrix[0]`, `tsDouble` sub-atlas math, `AlphaRows/Cols/TileSize`, face-promotion rule, SM20/SM30 profile, `hmapTex` binding, absolute FOV/sensor, metres-per-cell? (V3D_02 Q1-Q9; V786 §6; V784 §8)
5. Is 64² the coordinator's "smallest possible", or should a 32² exploratory fixture be attempted (config floor 16², but generator clear rings suppress trees/mines/starts)? (TEST_01 Q2)
6. For the stub ladder: real donor `tileblock`/atlas with generator artefacts, or hand-authored clean tileblock? Either way no donor parity claim. (TEST_01 Q1)
7. Should trees/mines/shore tests build a shared single-owner helper, or duplicate ~40 lines per atom? (TEST_01 §scaffolding)
8. Should drag selection honour Shift (add)? 2D ignores it for drags; donor unknown until DSEL-01. (V3D-01 Q4; V2D-01 Q5)
9. Does the drag need to work when starting/ending over the minimap, or is preemption acceptable? (V3D-01 Q5)
10. Is `world3d.view_rect`'s half-map fix in the same ticket as selection or a separate atom? It affects double-click, not drag. (V3D-01 Q6)
11. Formal variant CLEAN: acknowledge 84 historical probe failures with passing successors and make `assert_clean.py` variant-aware, or keep the caveat? (COMP-05 §3; COMP-06 gap 8)

---

## 11. Summary

- **Selection rectangle:** the 3D code path is *present* (input capture, drag state, SIM-metre box test, selection flags, rings) and click-pick/orders were fixed and measured in `FIXSEL`. The **definitive missing piece is the rectangle visual** (`sel_rect`/`sel_active` are data-only in `world3d.gd`, no 3D draw consumer); the functional box has **never been tested end-to-end** and is geometrically approximate under a −32° perspective camera. Donor internals are engine-side/UNVERIFIED, so no donor threshold/radius may be invented. Smallest fix: screen-space `select_in_rect()` via `unproject_position()` + a viewport-pixel overlay, with a 3-unit stub probe that drives real mouse events. [V3D-01; FIXSEL_*; V2D-01]
- **Terrain quality:** the pipeline is *correctly wired* (live `game.tileblock` → UV2 → donor atlas/masks/shader; donor water literals; donor sun rig; 64² harness). Bad visuals are caused by data dominance (`test*` transitions 14%, top-5 73%), neutral eye-plane UVs, an unshaded headlight, approximate atlas/mask sub-rect mapping and partial face promotion, height-driven water bands, and a structurally wrong-but-measured mask blend — while **no donor A/B exists**. Do not redo the already-fixed geometry/lighting-rig/shader-compile/camera-seam items. [V3D_02; FIXTERRAIN; COMP-03; V792; TERRAIN_SMALL]
- **Method:** the recurring failure was not missing donor truth but substituting approximations and calling metrics "visual PASS". Today's work must keep donor primary, 2D secondary, isolate one piece on 64² before combos, run the final whole-system test once at the end, and label every visual claim UNVERIFIED until a donor A/B exists. [RENDER_ARCH_WHY_WE_FAILED; D-22/D-31…D-38; 2026-11-25 CHARTER]

---

*DOC-01 wrote exactly one file. No game code, config, test, asset, shader, runner job or git operation was performed. All donor paths are private-use read-only references; no donor binary was run or copied.*
