---
id: G18
ticket: TERRAIN-SWARM-WAVE-G / G18
title: "Authoritative register — donor bugs / anti-patterns we must NOT copy (evidence, our status, guard rule)"
owner: G18 (READ-ONLY register subagent)
created: 2026-11-25
status: DELIVERED__ONE_REPORT_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB
scope: "Read-only. Read WAVE_G_CHARTER.md, CHARTER.md, F04_quality_reviews.md §4, F03_selection_online.md, D05_selection_ui.md and, for newly discovered entries, F01_almanac_terrain.md, F02_almanac_building_ghost.md, B01/B03/B04/B05/B06 reports plus on-disk variant3d source. Exactly one file written: this report. No code/config/asset/test/scene/shader/git edit. No Godot process or runner job submitted."
labels: [observed, derived, inferred, UNVERIFIED, PORT_APPROX, DONOR_CITED]
parity_guard: "NO DONOR PARITY CLAIM. No donor GPU A/B frame exists (CHARTER §3); every status below is a statement about OUR current tree, not about matching donor pixels."
---

# G18 — donor bugs / anti-patterns we must NOT copy

## 0. How to read this register

Purpose: one cold-readable, authoritative list for every future worker. If an idea appears here,
**do not implement it**, even when a review calls it "authentic" — review prose is context, not a
specification (F04 §0, CHARTER §3).

Evidence labels (binding per CHARTER §3):

- **OBSERVED** — verbatim claim from a cited source, or a direct read of our current tree,
  fetched/read this session (2026-11-25).
- **DERIVED** — direct control-flow / geometry consequence of an observed fact.
- **INFERRED** — judgement about what to avoid; not proven by a donor GPU frame.
- **UNVERIFIED** — no evidence obtained; above all, **donor parity**, which stays UNVERIFIED.

Status vocabulary used in the tables:

| Status | Meaning |
|---|---|
| **NO-DEFECT BY INSPECTION; LIVE UNVERIFIED** | Our code has no path reproducing the donor bug (DERIVED from control flow). No live/port-vs-donor A/B frame confirms it visually. |
| **GUARD PRESENT IN CODE; LIVE UNVERIFIED** | An explicit guard/isolation exists in our tree; its runtime effect was not re-captured in this ticket. |
| **FIXED IN CODE (this wave); VISUAL UNVERIFIED** | A Wave-B fix landed; no fresh windowed capture reviewed here (G04/G05 own that). |
| **OPEN PORT GAP (analogous)** | Our port has a related defect of its own — copy the *donor bug*, not the fix, would make it worse. |
| **N/A — NOT IMPLEMENTED** | The donor feature (e.g. fauna) is absent; bug cannot occur yet. Guard for a future ticket. |
| **OUT OF SCOPE / P2 OPTIONAL** | Acknowledged, deliberately not a terrain-P0/P1 work item. |

Sources are abbreviated as in the cited reports: `F04-S<n>` = source inventory row in
`F04_quality_reviews.md` §1; `F03-S<n>` = source register row in `F03_selection_online.md`;
`F01-U/L<n>` = source rows in `F01_almanac_terrain.md`. Full URLs are repeated in each row so the
register is self-contained.

---

## 1. Core register — mandated by ticket + F04 §4 (13 entries)

### 1.1 Box selection stops working after selecting a wall

| | |
|---|---|
| **Donor citation** | Charter §1b.2; F04 §4 #1; F03 Finding 5 / F03-S6 WGB review: https://wolfsgamingblog.com/2016/09/28/cossacks-3-review-less-sequel-more-hd-remaster/ — "…from the developer's console still being accessible through a tap of P to **the box selection not working after you select a wall** and units sometimes failing to obey commands." |
| **Evidence class** | OBSERVED (donor report); DERIVED (our status). |
| **Our status** | **NO-DEFECT BY INSPECTION; LIVE UNVERIFIED.** D05 §3 row 1 (`D05_selection_ui.md:76`) and B05 (`B05_selection_impl.md:227,278`) both derive it from control flow. Current tree: `variant3d/scripts/input_controller.gd:671-702` `_apply_rect_selection()` rebuilds `arr` from scratch on every drag (`not e.dead and e.player == 0 and e.kind == "unit"`) and calls `_set_selection(arr)`; a wall click merely calls `_set_selection([wall])` and carries no state into the next drag. Port box-select excludes **all** buildings (walls/gates included), which is a deliberate simplification, not the donor bug. |
| **Guard rule** | **Never carry previous-selection state into the marquee drag path — keep rebuilding the boxed set from scratch so a prior wall/building pick cannot disable box-select; live wall-then-drag capture still needed.** |

### 1.2 Corner-brightness blow-out (lighting coupled to cursor/view)

| | |
|---|---|
| **Donor citation** | Patch notes #22 (2017-02-24), F04-S20: https://cossackshq.net/c3-news-patch-notes-22/ — "Fixed lighting, now the map won't get too bright if you hover over to the lower left corner". Cf. F04 §2 F-8, §5 P1-8. |
| **Evidence class** | OBSERVED (patch text); DERIVED (our status). |
| **Our status** | **NO-DEFECT BY INSPECTION (view-independent lighting confirmed); LIVE UNVERIFIED.** `variant3d/shaders/terrain_tileindex.gdshader:43` is `render_mode … unshaded, cull_disabled`, so Godot scene lights cannot modulate ALBEDO a second time (A07-E5, `A07_color_lighting.md:333`). The donor sun is a constant `lsParallel` direction (`terrain_tileindex.gdshader:130-158,287-305`), rotated by `VIEW_MATRIX` together with the normal (`:296,298`), so `dot(l,n)` — and hence `v_packed` (`:305`) and final `rgb` (`:427`) — is invariant under camera rotation; `v_eye` is used only for face-mask UV (`:404-407`), never for brightness. No mouse/cursor uniform exists in the shader. B04 (`B04_relief_impl.md:51,278`) records the same requirement. No corner-hover A/B frame was produced here. |
| **Guard rule** | **Keep lighting a function of surface orientation and fixed donor light constants only — never feed cursor position, screen corner or camera position into brightness/tonemap.** |

### 1.3 Bland uniform green terrain across random maps

| | |
|---|---|
| **Donor citation** | F04-S1 HeyPoorPlayer: https://www.heypoorplayer.com/2016/09/28/cossacks-3-review/ — "same bland green environment a lot"; F04-S14 cossacksworld NTM: http://cossacksworld.ucoz.co.uk/index/newterrainmod/0-335 — "They all look the same"; F04-S5/S4 (French: "topographie… pauvre au possible", "réalisation… sommaire"). F04 §4 #3. |
| **Evidence class** | OBSERVED (donor reviews); DERIVED (our status). |
| **Our status** | **OPEN P0 GAP — not claimed fixed.** The baseline frame `p0_final_formula.png` is flat uniform olive (CHARTER §1:21, F04 §0); A07 (`A07_color_lighting.md:250-258,329-336`) measures `B/G=0.326`, `b*=35.44` and attributes the uniformity to fixture/data (`UV2.x ≡ 0`) plus an atlas albedo blue deficit, explicitly **not** a light-energy/gamma defect. B01 (sampling), B03 (tile data re-roll) and B04 (relief) landed this wave, but **no fresh windowed capture was reviewed by G18** (G04/G05 own that) — current visual state UNVERIFIED. |
| **Guard rule** | **Do not reproduce "one flat green field": keep multi-scale variation sourced from tile-id/pattern/relief data, and reject any change that collapses the histogram back to a single dominant id (no synthetic dither/noise field — S-25-09).** |

### 1.4 Flat, unmoving environmental models / static decor

| | |
|---|---|
| **Donor citation** | F04-S1 HeyPoorPlayer: "fauna and geological objects feel very underwhelming; most environmental models feel very flat and have no movement"; F04-S7 GamingOnPC: https://www.gamingonpc.com/reviews/cossacks-3-review/ — maps "mostly static". F04 §4 #4; animated trees are NTM mod-only (F04-S13item14, P2-10). |
| **Evidence class** | OBSERVED (reviews); INFERRED (our port guidance). |
| **Our status** | **STATIC BY INSPECTION / P2 OPTIONAL — UNVERIFIED visually.** No wind/fauna animation is part of the landed terrain work; F04 §3 classifies animated foliage and fauna as **mod-only** (NTM), explicitly "do not let a P2 item delay a P0 fix" (F04 §3 note). Water surface animation exists (`t_terrain_shore.gd:649-671` water-sample delta) but decor does not. Not a regression to fix at P0. |
| **Guard rule** | **Do not copy flat static decor as a target state; if adding P2 foliage motion, keep it non-flickering and budgeted, and never let it stand in for the P0 tile/relief work.** |

### 1.5 Ships on land / ships clip and cancel each other's fire

| | |
|---|---|
| **Donor citation** | F04-S2 NoobFeed (pre-release): https://www.noobfeed.com/reviews/cossacks-3-pc-review — naval clipping; patch #22, F04-S20: https://cossackshq.net/c3-news-patch-notes-22/ — "Ships now won't sail on land". F04 §4 #5. |
| **Evidence class** | OBSERVED (donor report/patch); DERIVED (our status). |
| **Our status** | **GUARD PRESENT IN CODE; LIVE UNVERIFIED.** `variant3d/scripts/game.gd:527-535` `_is_water()` admits only deep-water terrain id 3 and the comment states "Ships may enter only these tiles; the shore sand collar (terrain 4) and all land stay impassable"; `:4158-4167` `_naval_spawn_pos()` ring-scans for a water tile next to the dock; `:4710-4720` `_nav_repath()` keeps naval entities on clear water lines (water is `BLK_WATER` in the nav grid). This addresses *ships on land* by inspection; ship-vs-ship clipping/fire-cancel is a separate cosmetic bug not reproduced by any code path found. |
| **Guard rule** | **Keep water/land masks geometrically honest: every ship spawn, path and shore transition must be validated against the water mask — never let a decorative shoreline or relief stamp make land passable to ships.** |

### 1.6 Bridge pathfinding strands units

| | |
|---|---|
| **Donor citation** | F04-S2 NoobFeed: "pathfinding difficulties, especially when coming up to bridges which made portions of larger groups to remain behind"; F04-S5 (JeuxVideo via https://www.commentchoisir.fr/test-Cossacks_3.htm) — blobs stuck at mountain feet. F04 §4 #6. |
| **Evidence class** | OBSERVED (reviews); DERIVED (our status). |
| **Our status** | **N/A — NO BRIDGE ENTITY IN PORT; RELIEF/SHORE TRAVERSABILITY UNVERIFIED.** grep of `variant3d/scripts/*.gd` finds no gameplay bridge (only `scripts/testbridge.gd`, the test-only TCP harness, and `world3d_fx.gd:362`, a skirmish-menu value bridge). Navigation uses the `blocked` grid (`game.gd:522-525,4710-4720`). No unit-stranding reproduction found; no live real-map traversability capture in this ticket. |
| **Guard rule** | **Before any relief/shore/bridge work, verify every stamped cell stays traversable on the nav grid — never add a visual height/water feature that silently makes a group of units unable to cross.** |

### 1.7 Cannons move and fire with no crew

| | |
|---|---|
| **Donor citation** | F04-S2 NoobFeed; F04-S5 JeuxVideo; F04-S6 Gamepressure: https://www.gamepressure.com/editorials/reviews/cossacks-3-review-a-sad-return-to-the-past/zee9. F04 §4 #7. |
| **Evidence class** | OBSERVED (reviews); DERIVED (our status). |
| **Our status** | **GUARD PRESENT IN SIM; ANIMATION FIDELITY OUT OF SCOPE / UNVERIFIED.** `variant3d/scripts/game.gd:5302` requires artillery deployment ("the crew unlimbers before the first shot") and `:4916` treats standing still as readying the gun; `t_smoke_fx.gd:179-194` exercises `deploy_t`/`cmd_attack` with cannon shots. Crew sheets are baked in the naval/anim index (`data.gd:1207-1208`, `world.gd:169,3169-3172`). This is cosmetic-animation debt with no gameplay value for the terrain port; no donor A/B. |
| **Guard rule** | **Do not spend P0/P1 effort reproducing "crewless cannon" fidelity — keep deployment gating intact and label any crew-sheet approximation PORT APPROX rather than claiming donor animation parity.** |

### 1.8 High-brightness fog-of-war transparency

| | |
|---|---|
| **Donor citation** | Patch notes #14, F04-S21: https://cossackshq.net/c3-news-patch-notes-14/ — "Fog of War is no longer transparent on monitors with high brightness". F04 §4 #8. |
| **Evidence class** | OBSERVED (patch text); DERIVED (our status). |
| **Our status** | **NO-DEFECT BY INSPECTION; LIVE UNVERIFIED.** `variant3d/scripts/world3d_fog.gd:38-44` uses a fixed port alpha ladder `0.78 / 0.30 / 0.0` (unexplored/explored/visible), ported from 2D `world.gd:2251-2255`; no monitor-brightness, gamma or exposure input exists in that module. The terrain shader explicitly keeps `fog_mode = 0.0` (donor FogMode=0, `world3d_terrain.gd:742-743,1742`). Donor view-distance depth fog is disabled in gameplay (`world3d_fog.gd:19-31`) and is a different mechanic. |
| **Guard rule** | **Keep fog-of-war alpha a fixed state encoding with no display-brightness or exposure coupling; do not "fix" legibility by making fog fade with gamma/hardware.** |

### 1.9 NTM animals block buildings / wall lines

| | |
|---|---|
| **Donor citation** | Steam Workshop NTM (id 1255766623), F04-S19: https://steamcommunity.com/sharedfiles/filedetails/?id=1255766623 — user comment: wild animals "prevent you from putting up a building, or properly drawing a defensive line of walls, it's annoying that you can't kill them or move them to the side". F04 §4 #9. |
| **Evidence class** | OBSERVED (user comment); INFERRED (guard). |
| **Our status** | **N/A — NO FAUNA/BIRDS IN PORT.** No animal/bird spawn exists in `variant3d/scripts/game.gd` (grep: only `audio.gd:38-42,468-469` ship select cue and `world3d_fog.gd` unit counts). F04 §2 F-4/P2-11 marks fauna as mod-only optional polish. |
| **Guard rule** | **If fauna/birds are ever added (P2), they must be non-blocking: exclude them from placement collision and wall-line checks, and make them killable/movable.** |

### 1.10 NTM border grass / black spots / bad-decoration textures

| | |
|---|---|
| **Donor citation** | F04-S15 EMOM/NTM Known Issues: http://cossacksworld.ucoz.co.uk/index/new_random_map_mask_samples/0-333 — "Weird grass texture on east/south border on normal maps on desert and arctic maps"; "Black spots around mines on artic [arctic] maps"; NTM item 24 "Fixed misdecor7 & 8 having a bad texture (tent texture pointing to wrong file)". F04 §4 #10. |
| **Evidence class** | OBSERVED (mod Known Issues); DERIVED (our status). |
| **Our status** | **GUARDS PRESENT, NO KNOWN BORDER/BLACK-SPOT REPRODUCTION; LIVE UNVERIFIED.** No desert/arctic NTM biome in the port. Season/tile-index preservation is guarded (`A10_regression_constraints.md:86-92,96-100`; B04 report `:277`), and the 8 constant-zero alpha sentinels that produced pure-black cells are bypassed by the B01 guard (`B01_shader_impl.md:120,209-211`; shader `:410-419`). C04 R5 (`C04_visual_review.md:106`) requires scanning for new seams/black rows on real-map captures; none is recorded by G18. |
| **Guard rule** | **Treat every border/seam/black-spot artifact as a hard FAIL (CHARTER §5) — do not inherit mod biome textures or mask-wrap rules, and never silence a seam by shrinking the review ROI.** |

### 1.11 Generation-time blow-up from dense decor

| | |
|---|---|
| **Donor citation** | F04-S17 NTM animals update: http://cossacksworld.ucoz.co.uk/news/updated_cossacks_3_new_terrain_mod/2018-01-20-54 — v1.3.3.7 "Improved the generation time for the 'black forest' option. Reduced the amount of trees/patterns that were being generated. Still one of the 'longest' generation times". F04 §4 #11. |
| **Evidence class** | OBSERVED (mod changelog); INFERRED (budget rule). |
| **Our status** | **N/A FOR SHIPPED PORT; BUDGET UNMEASURED HERE.** The port does not ship NTM's 200+ patterns/736 masks; selftest includes a timed build step ("house built in 3.1 s", cited in `E03_ghost_fix_proposal.md:314`). No real-map generation-time number was produced or compared in G18 (read-only, no runner). |
| **Guard rule** | **Budget decor/pattern density before adding it — measure generation time on the real map and keep it bounded; do not trade a P0 visual win for an NTM-style long generate.** |

### 1.12 Odd / contradictory option combinations

| | |
|---|---|
| **Donor citation** | F04-S14: http://cossacksworld.ucoz.co.uk/index/newterrainmod/0-335 — "Some combinations of options may appear a bit weird eg; countryside + mountains"; "desert + foresttype: it will always be palm trees". F04 §4 #12. |
| **Evidence class** | OBSERVED (mod author); DERIVED (our status). |
| **Our status** | **GUARD PRESENT (validation), COMBINATION MATRIX UNVERIFIED.** `variant3d/scripts/config.gd:696-701` `_donor_id()` validates terrain/map/relief ids and falls back to donor defaults with a `problems` entry (A12 §2, `A12_config_knobs.md:105`). No known contradictory-combination regression was found; no exhaustive combo matrix was run in this ticket. |
| **Guard rule** | **Keep biome/terrain/season rules mutually consistent and validate lobby ids — if a combination is nonsensical, report `problems` rather than silently producing "desert + palm forest" output.** |

### 1.13 AA as the fix for streaks

| | |
|---|---|
| **Donor citation** | F04-S10 gameGPU: https://en.gamegpu.com/test-gpu/rts-strategii/cossacks-3-test-gpu — "Activating anti-aliasing has virtually no effect on anything". F04 §4 #13; A06 §2 item 6. |
| **Evidence class** | OBSERVED (technical review); DERIVED (our status). |
| **Our status** | **NOT COPIED — FIX IS AT SAMPLING LEVEL; VISUAL UNVERIFIED.** A06 (`A06_filtering_aliasing.md:97`) derives that MSAA only covers geometry edges and cannot undo texture minification aliasing. Landed fixes are B01 (mirror/warp + unwrapped-derivative `textureGrad` + half-texel inset + sentinel guard + mask contrast compression), B02 (real runtime mip chain + `.import mipmaps=true`) and the `filter_linear_mipmap` change (`terrain_tileindex.gdshader:60`). No AA toggle is used as the remedy. |
| **Guard rule** | **Fix tiling/streaks in tile-index data and texture sampling — never claim a post-process AA toggle solves an aliasing defect; re-open the sampling fix instead.** |

---

## 2. Newly added from the other reports (11 entries)

These are donor bugs/anti-patterns or donor game-feature quirks found in reports beyond F04 §4.
All are recorded as **OBSERVED** third-party/donor-source claims and **none were reproduced here**.

### 2.1 First-stage ("lying") ghost preview

| | |
|---|---|
| **Donor citation** | Charter §1b.3; F01 C11 (`F01_almanac_terrain.md:413`); F02 §2.5–§3 (`F02_almanac_building_ghost.md:151-168,198-201`): https://gamemechanicshoard.com/mechanic/ghost-preview/ — "Pitfall: a lying ghost — any gap between what the preview showed and what placement actually produced … destroys the trust the entire pattern exists to provide; the ghost must be pixel-honest." Donor stage chain `<sid>1..4.osm`; progress 0 shows `<sid>1.osm` (§2.1–2.3). |
| **Evidence class** | OBSERVED (generic convention via indexed snapshot; source 403, definition recovered via websearch — F02 §1 S4); DERIVED (our status). |
| **Our status** | **FIXED IN CODE (B06); VISUAL UNVERIFIED.** Pre-fix defect at `world3d_fx.gd:645` (`_stage_mesh_info(sid, "1", false)`) and node `GhostBuildingStage0` (E01 §4, E04 `:47`). B06 resolves the finished base mesh first, adds a stage-4 fallback and renames the node `GhostBuildingFinished` (`B06_ghost_impl.md`; E04 QA). F02 §3.1 explicitly says "Cossacks 3 itself displays a finished-structure hologram" is **UNVERIFIED** — our "last stage" requirement is an owner product decision, not a donor-proven behaviour. |
| **Guard rule** | **Resolve the ghost to the finished/last stage mesh and its real footprint — never preview the stage-1 foundation, and never describe the finished-ghost convention as verified donor parity.** |

### 2.2 Buildings with no stage art vanish in the editor

| | |
|---|---|
| **Donor citation** | F02 §2.3 (`F02_almanac_building_ghost.md:125-139`), sibling forum `/forum/28-52-1` indexed via cossacksworld: "this only works for buildings that actually have the graphics for building stages, for example the SelFraDoms or GorFra dont have these graphics and make the buildings dissapear." |
| **Evidence class** | OBSERVED (forum quote); DERIVED (our status). |
| **Our status** | **NO-DEFECT BY INSPECTION — DELIBERATE IMPROVEMENT.** F02 §2.3 records our explicit `base_mesh_port_approximation` fallback (§4.2), so a building without stage art does not vanish. Not a parity defect. |
| **Guard rule** | **Always keep a finished-base-mesh fallback when stage art is missing — never let a building disappear because its stage chain is incomplete.** |

### 2.3 One-sided cliff difference erasing the sand collar

| | |
|---|---|
| **Donor citation** | F01 §6 item 4 (`F01_almanac_terrain.md:353`) and C11 (`:413`): `docs/guides/GUIDE4.md:2106-2107` — "The cliff pass divided height differences by TILE and only looked at +x/+y, turning half of every shore into blocked rock and erasing the sand collar." The donor uses aspect sectors and absolute height thresholds. |
| **Evidence class** | OBSERVED (donor-script truth via local recon); DERIVED (our status). |
| **Our status** | **NO-DEFECT BY INSPECTION; LIVE UNVERIFIED.** Our relief-aware face promotion preserves the donor cDiff gates and uses both axes (`world3d_terrain.gd` B04 addition `_relief_face_at()`, `B04_relief_impl.md:67-84,268-276`); the sand/shore collar is guarded by water bounds (`A10:88-96`). No half-shore blocked-rock repro found. |
| **Guard rule** | **Use aspect sectors and both height-gradient axes for cliff/shore selection — never a one-sided +x/+y per-tile difference that paints half a coast as blocked rock.** |

### 2.4 `tls_3` hack in tiled background placement

| | |
|---|---|
| **Donor citation** | F01 C11 (`F01_almanac_terrain.md:413`) citing donor `data/scripts/common.inc/dogenerate.inc:514` (F01 L7): the `tls_3` hack. |
| **Evidence class** | OBSERVED (donor script line cited in recon); INFERRED (guard). |
| **Our status** | **NOT COPIED.** F01 §7 row 6 and C2 describe the intended mechanism — a 25-cell weighted lattice of `d_tls_1..4` clumps snapped to cell centres, **not** per-tile procedural noise and not the special-case hack. No `tls_3` special case exists in our generator. |
| **Guard rule** | **Reproduce the weighted lattice mechanism, never a one-off `tls_3` special case; no per-tile procedural noise in place of authored clumps.** |

### 2.5 Early drag-box / camera interaction broken (box shifts instead of resizing)

| | |
|---|---|
| **Donor citation** | F03 Finding 5 (`F03_selection_online.md:253`), F03-S7 Steam bug thread https://steamcommunity.com/app/333420/discussions/1/350543389014614918/ (OP 20 Sep 2016): "drag-box selecting units in half-broken: it frezzes window scrolling with mouse, but if I scroll with keys, the box shifts along with the view instead of getting resized from the point I started it"; "Cannot scroll and select at the same time"; F03-S11 r/Cossacks3 Bugs Megathread https://www.reddit.com/r/Cossacks3/comments/53pq86/bugs_megathread/ — "Selecting units is only possible on the currently visible area, the camera doesn't move with the selection." GSC fixed it in Nov 2016 (F03-S1/S2, official). |
| **Evidence class** | OBSERVED (community reports + official fix text); DERIVED (our status). |
| **Our status** | **NOT REPRODUCED — our port has no camera-follow drag yet (F03 gap G1), so the broken combined state cannot occur.** Our drag is a two-ground-point world rect (`input_controller.gd:665-702`); G08 is assigned to propose camera-follows-drag. If G1 lands, target the **fixed** donor behaviour (frame + map moves with you), not the Sep-2016 state. |
| **Guard rule** | **When adding camera-follows-drag, anchor the quad to screen drag pixels while the world scrolls; regression-test that keyboard+mouse scroll resizes from the original anchor instead of shifting the box.** |

### 2.6 Box select intermittently dies / carries into the next game

| | |
|---|---|
| **Donor citation** | F03 Finding 5 (`F03_selection_online.md:254`), F03-S7 comment #1: "My box to select units has stopped working and I can't select the troops I just recruited…"; comment #10: "just got this one and it carried into my next game". |
| **Evidence class** | OBSERVED (community reports); DERIVED (our status). |
| **Our status** | **NO-DEFECT BY INSPECTION; LIVE UNVERIFIED.** Our drag state is rebuilt per drag and finalized on LMB-up (`input_controller.gd:671-702`); B05 added the single `_cancel_drag()` helper (`B05_selection_impl.md:78`) clearing `drag_start`/`dragging`. No persistent selection/quad state survives a restart path found by G18. |
| **Guard rule** | **Reset drag/selection state on LMB-up, mode change and game restart — never let a stale marquee or selection set leak across games.** |

### 2.7 No visual delta on Shift-add

| | |
|---|---|
| **Donor citation** | F03 Finding 5 (`F03_selection_online.md:255`), F03-S7: "when SHIFT selecting some types of units in your current selection, there is no highlight (visual indication) which units you selected". |
| **Evidence class** | OBSERVED (community report); DERIVED (our status). |
| **Our status** | **DRAG UNION CORRECT; CLICK/GROUND VARIANT OPEN.** F03/F04: shift-drag `spmAdd` union is implemented and windowed real-drag VERIFIED (`D05_selection_ui.md:79`, `input_controller.gd:678-691`). But D05 defect #3 (`D05_selection_ui.md:56`) — Shift+click on empty ground clears the selection — is an **OPEN port gap analogous to the donor defect**. |
| **Guard rule** | **Give Shift-add the same feedback as a normal selection and preserve the previous set on Shift+empty-ground — do not silently deselect when Shift is held.** |

### 2.8 Selected markers hidden by terrain/buildings

| | |
|---|---|
| **Donor citation** | F03 Finding 4 Tier B + Finding 5 (`F03_selection_online.md:213-217,256`), F03-S7: "there is no visual indication of selected units, if they are standing next to a building (their blue/yellow circle is 'under' the building)"; F03-S8: "when units are above farms, you cannot see the highlight circles anymore." |
| **Evidence class** | OBSERVED (community reports); INFERRED (guard). |
| **Our status** | **PORT APPROX / OCCLUSION UNVERIFIED.** Our port draws procedural rings/aura (`D05_selection_ui.md:83`, labelled "NOT DONOR PARITY"); no donor `selection.friend`-style material mapping (F03 gap G6). No live occlusion capture in this ticket. |
| **Guard rule** | **Keep selection rings/quad above ground and decor in draw order and never remove donor-style feedback to "fix" clunkiness; white outline is a fan suggestion, not donor behaviour.** |

### 2.9 Missing selection audio on some units

| | |
|---|---|
| **Donor citation** | F03 Finding 5 (`F03_selection_online.md:257`), F03-S7: "some units do not have sound effects while walking or when you select them"; donor `selectpeasant1..6`/`selectship` cues (F03 L1 claim 22). |
| **Evidence class** | OBSERVED (community report); DERIVED (our status). |
| **Our status** | **WIRING FIXED; EDGE CASES/AUDIBLE UNVERIFIED.** `audio.gd:38-42,443-477` exposes `play_selection()` with ship-cue mapping; `input_controller.gd:323-337` calls it once per `_set_selection()`. D05 §2 #7/#8 (`D05_selection_ui.md:60-61`) flags the empty-selection and deterministic count-based variant choice as a PORT APPROX with open edge cases. |
| **Guard rule** | **Wire a cue for every selected kind (including ships/buildings) and suppress it for empty selections — do not copy the donor's silent-unit gap.** |

### 2.10 Developer console exposed via the P key

| | |
|---|---|
| **Donor citation** | F03-S6 WGB review, same sentence as §1.1: "from the developer's console still being accessible through a tap of P" (F03 Finding 5, `F03_selection_online.md:252`). |
| **Evidence class** | OBSERVED (review); DERIVED (our status). |
| **Our status** | **NO-DEFECT BY INSPECTION.** No developer-console-on-P binding was found in `variant3d/scripts/config.gd`/`input_controller.gd`; the shipped hotkey table (`config.gd:178-224`, `config.json controls.hotkeys`) contains only player-facing actions. |
| **Guard rule** | **Never expose debug/developer consoles through a single unmodified gameplay key; any debug hook must be gated behind an explicit opt-in flag.** |

### 2.11 Units sometimes failing to obey commands

| | |
|---|---|
| **Donor citation** | F03-S6 WGB review, same sentence: "and units sometimes failing to obey commands" (F03 Finding 5, `F03_selection_online.md:252`). |
| **Evidence class** | OBSERVED (review); DERIVED (our status). |
| **Our status** | **NO-REPRODUCTION FOUND; LIVE UNVERIFIED.** No code path in `variant3d/scripts/game.gd` drops an issued order for a selected own unit (`cmd_*` paths and `_nav_repath` at `:4710-4720`); no live command-obedience A/B was run here. |
| **Guard rule** | **Preserve command delivery after any selection/nav change — a unit that was boxed or grouped must execute the order, and any new edge-scroll/quad work must not swallow commands.** |

---

## 3. Context-only anti-patterns (recorded, deliberately NOT tasks)

F03 Finding 5 last row and F04 §2 F-5 mark these as **context**, not specifications. They are kept
here so nobody mistakes them for quality targets:

| Anti-pattern | Source | Why not a task |
|---|---|---|
| Clunky UI / messy rank setup; "tons of redundant micromanagement", "low legibility and chaotic combat" | F03-S9/S10 (`F03_selection_online.md:258`); F04-S6 | Reviewer context for why quad/feedback matters; not a feature request to copy. |
| "Blinded by the current snow textures" (vanilla) | F04-S13 item 21; F04 §2 F-5 | Winter/snow lighting is vanilla with a mod "darker winter" tweak; P2 seasonal work only, never a reason to blow out brightness (see §1.2). |
| "The graphics are the game's biggest asset" vs "graphics… quite pretty" disagreement between reviews | F04-S3/S6 | Shows review authority is limited; several reviews are of pre-release/review-copy builds (F04 §0). Do not treat any single review as a donor spec. |

---

## 4. Explicit non-members (do not add these as "donor bugs")

These are **our own** port defects/traps, not donor behaviour to avoid copying. They belong to
their owning tickets, not this register:

- D05 defects #1–#4 (`D05_selection_ui.md:54-57`): Ctrl+click same-type, Ctrl+click removal,
  Shift+click on empty ground, Shift+double-click. **Port gaps**, except §2.7 above records the
  donor analogue.
- D05 #5/#6 hover-cursor over HUD and top-strip click-through (`:58-59`): port routing decisions.
- A12 config trap: `uv_repeat` / `mask_to_alpha` are declared shader uniforms with **no config
  bridge** (`C04_visual_review.md:39,143`); `--config` arms claiming to vary them are invalid.
- A10 "known-gap markers" (`A10_regression_constraints.md:220-232`): `expected_pre_fix_failure`,
  false-green skips, blank-detector trap — verification debt, not donor bugs.
- C04 historical white stepped bands / z-fighting (`:106`): our own earlier rendering artifacts.
- F05 guard "do not reintroduce ±2.964 amplitudes or noise layers" (`F05_online_vs_local.md:54,74`):
  donor-derived constants wrongly used earlier in our port, not a donor bug.

---

## 5. Consolidated guard rules (paste into PR descriptions)

1. Keep box-select state-free across prior wall/selection (`_apply_rect_selection` rebuilds `arr`).
2. Lighting = fixed sun direction × surface normal; no cursor/camera/screen-corner brightness term.
3. Multi-scale colour comes from tile/pattern/relief data — never synthetic noise/dither.
4. Decor motion is P2 only; never let static decor stand in for the P0 visual fix.
5. Ship spawn/path/shore must validate against the water mask; land stays impassable to ships.
6. Relief/shore must not break nav traversability (no bridge-stranding analogue).
7. Artillery keeps deployment gating; no crewless-fire fidelity spending at P0/P1.
8. Fog alpha is a fixed state ladder — no display-brightness or exposure coupling.
9. Fauna/birds, if added, must be non-blocking and removable.
10. Border/seam/black-spot artifacts are hard FAILs; no NTM biome/border mask inheritance.
11. Budget decor density; measure generation time before expanding patterns.
12. Validate option combos; no silent contradictory biome fallback.
13. Fix streaks in tile sampling/data, not with post-process AA.
14. Ghost = finished stage + honest footprint; never a stage-1 foundation or a lying preview.
15. Missing stage art falls back to base mesh — never make a building vanish.
16. Cliff/shore selection uses aspect sectors + both gradient axes — no one-sided +x/+y pass.
17. Background clumps use the weighted lattice — no `tls_3` special case, no per-tile noise.
18. Camera-follow drag (if landed) keeps the quad screen-anchored and resize-from-anchor.
19. Reset drag/selection state on release/restart — no stale marquee across games.
20. Shift-add keeps prior selection and gives feedback; Shift+empty-ground never deselects.
21. Selection rings stay above ground/decor; do not remove donor-style feedback.
22. Selection cues cover every kind; empty selection is silent.
23. No developer console on a bare gameplay key.
24. Issued orders are never swallowed by selection/nav changes.

---

## 6. Honesty statement

- **Read-only:** exactly one new file written (this report). No code, config, asset, test, scene,
  shader, queue, gate or git edit; no Godot process or runner job (WAVE_G_CHARTER standing rule —
  only G04 submits runner jobs).
- Every donor claim above is quoted from a source listed in the cited reports, fetched in earlier
  waves and re-read here; URLs are reproduced verbatim. No donor binary was run and no donor GPU
  A/B frame exists.
- Our status entries are **OBSERVED** direct reads of the current tree plus **DERIVED** control-flow
  consequences, or explicitly marked UNVERIFIED. Nothing here asserts donor pixel parity; all
  visual/audible/live-key equivalence remains UNVERIFIED.
- The "NO-DEFECT BY INSPECTION" conclusions (§1.1, §1.2, §1.8, §2.1–2.3, §2.6, §2.10–2.11) are
  derivation from control flow, **not** live tests (cf. D05 §5). COORD/G04/G05 may upgrade them
  only with fresh evidence.

*End of G18 report.*
