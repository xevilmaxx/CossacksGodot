---
id: COMP-06
title: "Final COMPLETENESS VERDICT — variant3d 3D variant (synthesis)"
owner: COMP-06
date: 2026-11-24
scope: "Synthesis only. Read-only: no Godot launches, no git operations, no source edits."
sources:
  - "COMPLETENESS_CHARTER.md"
  - "AUDIT3D_TRIAGE.md (docs/coord_swarm_2026-11-24/)"
  - "STATUS_WAVE7_PHASE2.md (docs/variant3d/)"
  - "README.md"
  - "AUDIT3D_01..09 reports, V781/V784/V786/V790/V791/V792 reports, TERRAIN2 reports"
  - "current source + result JSONs (variant3d/scripts/, shaders/, tests/results/, selftest.json, uitest.json)"
peer_reports_at_read_time: "COMPLETENESS_01..05 did NOT exist (single targeted glob of reports/ at read time); synthesis relies on the audits/status/verified source listed above"
---

# COMPLETENESS_06 — final verdict

## 1. One-line answer

**FUNCTIONALLY COMPLETE WITH GAPS** — the three-part bar (2D-equivalent skirmish mechanics, donor-grounded presentation, green functional gates) is met at the artifact/probe level: all 10 former P0 gaps are closed and selftest 29/29 + uitest 17/17 + `t_render_mode` PASS are green with `render_mode="3d"`, but I withhold an unqualified COMPLETE because the **user's windowed minimap-click retest after V7-81/90 is still pending**, several presentation subsystems remain explicitly labelled approximations, donor visual parity has no A/B by definition, and a formal variant `CLEAN` verdict is not claimed (`docs/variant3d/STATUS_WAVE7_PHASE2.md:31-55`; `docs/coord_swarm_2026-11-24/AUDIT3D_TRIAGE.md:26-59`).

Why not INCOMPLETE: the gaps that used to block acceptance are closed by measurement, not by assertion — real GPU pixels via `Screenshot3DViewport` (V7-70, jobs 138/179), 0→5 entity meshes in probe (V7-62, job 130), 79/81 roster OBJs (V7-63+72), 13 donor tint slots 21/21 (V7-61+65), light node-tree 19/19 (V7-60, job 75), FX offset 452.548 m → 0.000 m (V7-73), ghost/rally wired (V7-76), minimap camera 11/11 probe (V7-81, job 211), donor camera math 8/8 (V7-90, job 238), donor tile-index terrain + donor water shader (V7-86/84/91/92) (`AUDIT3D_TRIAGE.md:29-38`; `STATUS_WAVE7_PHASE2.md:16-53`). Why not plain COMPLETE: the honesty qualifications in §6 below and gap list in §4 are real, not cosmetic.

## 2. Scorecard

Ratings are against the **defined** completeness bar in §3, not against donor visual identity. "Evidence" cites a report/result or a direct current-source read; where the only citation is an audit dated before later fixes, that is stated.

| # | Dimension | Rating | Evidence | One-sentence reason |
|---|-----------|--------|----------|---------------------|
| 1 | Simulation parity | **GREEN** | `AUDIT3D_04_sim_parity.md:19,25,27,37` (14/21 common scripts byte-identical incl. `game.gd`/`ai.gd`/`world.gd`, all 29 selftest details match); verified `variant3d/selftest.json:2` `passed:true` + 29 `"step"` entries (grep); config differs only by `render_mode` (`AUDIT3D_04:27`). | Economy, capture, combat, morale, formations and AI are the same code as the shipping 2D port, so skirmish mechanics are genuinely 2D-equivalent. |
| 2 | Entity meshes | **GREEN** | `AUDIT3D_TRIAGE.md:11,31` (116 donor-derived OBJ, 0 GLB, 79/81 IDs, bar18/dock absent *in the donor*); `V762_entity_feed.md` probe 0→5 real mesh nodes; current files `variant3d/scripts/world3d_entities.gd`, `assets/models/obj/` present. | Real donor-derived geometry is the primary entity path, and the two uncovered IDs are donor-absent rather than port omissions. |
| 3 | Terrain | **GREEN** | `AUDIT3D_TRIAGE.md:12-13` (102,400-vertex grid, splat SHA-256 matches app); `V792_terrain_integration.md`; `variant3d/shaders/terrain_tileindex.gdshader:4-21` cites donor `TMapTerrainDataTile.tex` and eye-plane equations; atlas file measured on disk at 179,912,941 B. | Donor tile-index representation, donor splat and live height are wired into the 3D mesh, with any substitutes explicitly labelled. |
| 4 | Water | **AMBER** | `variant3d/shaders/water3d.gdshader:2-16,40-45` — donor `water.dev.frag` literals carry `path:line`, but `height_tex` is a PORT SUBSTITUTE and Fresnel/deep/shallow uniforms are deliberately unwired; `AUDIT3D_TRIAGE.md:42` (P1.2 flat quad pre-fix), `V784_donor_water_shader.md`. | The shader is donor-grounded numerically but runs on a flat 4-vertex plane with unproven binding semantics, so it is an approximation rather than a finished donor water system. |
| 5 | Lighting / fog | **AMBER** | `AUDIT3D_TRIAGE.md:34,44,66` (light rig node-tree CLOSED 19/19; donor light constants dropped in `heightmap_world3d.gd`; fog height/centre + `fog_revision` follow-up); `AUDIT3D_08_donor_coverage.md:66-68` (`light.cfg`, `colors.lib`, clouds unused); `AUDIT3D_09_runtime_proof.md:39-51` measured `DirectionalLight3D`+`WorldEnvironment`. | A real donor-sun/WorldEnvironment rig exists at runtime, but donor light/fog constants are partially dropped or reduced and visual results were never A/B checked. |
| 6 | Animation | **AMBER** | `STATUS_WAVE7_PHASE2.md:34-35` (55 skins auto-register, 733/733 verts morph, but flat-root `PORT APPROXIMATION`, N=6 frames/action, no interpolation); `AUDIT3D_06_fx_anim_audio.md:26,58-62` (no `.oss` bone parents, clock grounded for one sid only); `V764_donor_morph_anim.md`. | The clock and morph are donor-sampled and honestly labelled, but full donor skeletal deformation is blocked and no donor-parity frames are claimed. |
| 7 | FX / audio | **AMBER** | `AUDIT3D_TRIAGE.md:37-38,59` (FX offset fixed, ghost/rally 0→1/1→5); `AUDIT3D_06_fx_anim_audio.md:25,29,38-44,94-96`; verified grep of `variant3d/scripts/audio.gd` shows only `AudioStreamPlayer` (no `AudioStreamPlayer3D`). | The identical 325-clip donor audio bed and all event dispatches run in 3D, but FX are mostly hardcoded primitives and there is no true spatial audio. |
| 8 | Camera / input / HUD | **AMBER** | `V781_minimap_black_fix.md:151-174` (probe 11/11, camera (320,34,374)→(0,34,54), **no windowed visual reproduction**); `V790_donor_camera_changes.md:285-332` (probe 8/8, selftest 29/29; FOV 17.27° assumption, minimap ArcTan offset unimplemented, stale uitest under queue contention); `AUDIT3D_TRIAGE.md:54-58` (E6 flat-Y anchor open question). | Input/camera semantics are donor-grounded and measured numerically, but absolute FOV, donor minimap offset, and the actual windowed click behaviour remain unverified. |
| 9 | AI / economy | **GREEN** | `AUDIT3D_04_sim_parity.md:25,27,37` (`ai.gd`, `game.gd`, `data.gd` unchanged; identical resources 45 food/712 wood/120 stone/245.024 gold/65 trade, 73 shots); verified selftest steps `mine`, `market`, `capture`, `squad`, `formation`, `farm_cap`, `nav_detour` in `variant3d/selftest.json:46-185`. | AI waves, economy, capture and formations are inherited byte-for-byte from the 2D shipping sim and pass the same step-by-step assertions. |
| 10 | Tests / gates | **GREEN** | Verified `variant3d/selftest.json:2` `passed:true` 29/29; `variant3d/uitest.json:2` `passed:true` 17/17; `variant3d/tests/results/t_render_mode.json:64-68` `passed:true`, `seam_missing:false` (10 checks); `STATUS_WAVE7_PHASE2.md:16-22` (jobs 130/157/163/186/185, 191, 193, 1342/1341). | All three functional gates are green in current artifacts with the 3D renderer enabled; the caveat is that no *visual* gate and no formal variant CLEAN verdict exist (see #11/#12). |
| 11 | Runtime stability | **AMBER** | `AUDIT3D_TRIAGE.md:48-57` (`int(id)` error, `dbg_*` unbranched calls, E19 camera lerp, E18 shift+group, RB-01 all CLOSED); verified `variant3d/scripts/main.gd:143-146,1592` declares/uses the `dbg_*` counters; `AUDIT3D_09_runtime_proof.md:25,73-77` historical 3D selftest errors and exit-time ObjectDB/GLES3 leaks. | Known startup/per-frame errors are closed and 3D boots cleanly through the gates, but no fresh post-V7-92 windowed error sweep exists and benign exit leaks remain. |
| 12 | Shipping hygiene | **AMBER** | README:106-108 (180 MB single atlas exceeds GitHub ~100 MB limit; split/array fallbacks); atlas measured 179,912,941 B on disk; `AUDIT3D_07_resources.md:52-61` (no P0; 4236 gitignored bake files tracking UNVERIFIED, `shots/` absent, 2099 uncached `.ctex`, 17 missing `.uid`); verified `variant3d/tools/assert_clean.py:34` still hardwires `SPOOL` to `app/.godot_queue`, `STATUS_WAVE7_PHASE2.md:40-42` (60 historical unacked probe failures, no formal variant CLEAN). | No confirmed resource-breaking P0 exists and fallbacks cover the big atlas, but fresh-clone/LFS status, output dirs, sidecars and a variant-aware clean gate are unresolved. |

Legend: GREEN = meets the §3 bar with current evidence; AMBER = meets the functional bar but with a labelled approximation, an unverified donor claim, or an unresolved hygiene item; RED = blocking gap. **No dimension is RED** — the ten former P0 blockers are closed (`AUDIT3D_TRIAGE.md:26-38`).

## 3. Precise definition of "complete" used here

The 3D variant is COMPLETE for this audit iff **all three** hold:

1. **2D-equivalent skirmish mechanics** — the same sim/rules/input/HUD/AI/economy behaviours as the shipping `app/` port, evidenced by shared byte-identical sim scripts and the same 29 sim + 17 UI steps passing in `variant3d/` with `render_mode="3d"` (`AUDIT3D_04:19,25,37`; `variant3d/selftest.json:2`; `variant3d/uitest.json:2`).
2. **Donor-grounded presentation** — every visual/audio constant in the 3D path traceable to read-only donor text/geometry with a `path:line` citation, and every substitution explicitly labelled `PORT APPROXIMATION` / `PORT SUBSTITUTE` / `UNVERIFIED` rather than invented or silently claimed (`variant3d/shaders/terrain_tileindex.gdshader:4-21`; `water3d.gdshader:2-16`; `AUDIT3D_TRIAGE.md:69-75`). A labelled approximation is admissible; an unlabelled invention is not.
3. **Green gates** — variant selftest 29/29, uitest 17/17, `t_render_mode` PASS with `seam_missing=false`, and the 2D shipping gate untouched/green (`STATUS_WAVE7_PHASE2.md:16-22`; `variant3d/tests/results/t_render_mode.json:64-68`).

**Explicitly EXCLUDED: visual parity with the donor.** No GPU A/B between donor and port was ever performed; real 3D pixels exist but "looks like the donor" is not a criterion and is not claimed (`README.md:83,230`; `STATUS_WAVE7_PHASE2.md:31-33,54-55`). Scope is private-use singleplayer skirmish only; campaigns/missions/network are out of scope (`STATUS_WAVE7_PHASE2.md:188-195`).

Applying this definition strictly, the gate and mechanics legs are satisfied; the presentation leg is satisfied *only in the labelled-approximation sense*. The residual gaps below are therefore quality/verification gaps rather than failures of the mechanics definition — which is why the verdict is FUNCTIONALLY COMPLETE WITH GAPS, not INCOMPLETE and not an unqualified COMPLETE.

## 4. Top 10 remaining gaps, ranked by player-visible impact

| Rank | Gap (player-visible effect) | Evidence | Smallest next action |
|------|-----------------------------|----------|----------------------|
| 1 | **Windowed minimap click after V7-81/90 not retested by the user** — the original symptom was a black main view; fix is measured headless/numeric only, so the visible result is still unconfirmed. | `V781_minimap_black_fix.md:8,156-174,181` (camera (320,34,374)→(0,34,54), probe 11/11, "no windowed/visual reproduction"); `V790_donor_camera_changes.md:320`; `AUDIT3D_TRIAGE.md:56-58` ("USER WINDOWED RETEST STILL PENDING"); `STATUS_WAVE7_PHASE2.md:54`. | Launch `launch_variant3d.bat`, click the minimap centre then all four corners, and confirm the main 3D view stays populated and clamped inside the map; record pass/fail in `STATUS_WAVE7_PHASE2.md`. |
| 2 | **No donor visual A/B** — nobody has established that the 3D picture matches the donor at the same camera height/tilt; this is the largest perceptual unknown even though parity is excluded from the formal bar. | `README.md:83,230`; `STATUS_WAVE7_PHASE2.md:32-33,54-55`; `AUDIT3D_TRIAGE.md:15`; `W55_visual_ab.md` (proposal only). | Capture one donor frame and one variant frame at identical zoom/tilt via `Screenshot3DViewport` (V7-70) and label the result A/B or still-UNVERIFIED; do not call it parity without the pair. |
| 3 | **Animation is a flat-root approximation** — units morph sampled poses (6 frames/action, no interpolation, one sid's AAF) instead of donor skinning; visible motion is not donor motion. | `STATUS_WAVE7_PHASE2.md:34-35`; `AUDIT3D_06:26,58-62,104`; `AUDIT3D_TRIAGE.md:36`. | Accept and label as a shipping approximation; true fix needs donor bone parents, which are absent from the `.oss` payload (`AUDIT3D_06:26`) — do not fabricate a hierarchy. |
| 4 | **No true positional audio** — shots/explosions play at flat volume regardless of distance/pan, unlike the donor's emitter model. | `AUDIT3D_06:29,94-96,105`; verified grep: only `AudioStreamPlayer` in `variant3d/scripts/audio.gd` and no `AudioStreamPlayer3D` anywhere; `STATUS_WAVE7_PHASE2.md:38-39`. | Make `audio.play` render-mode-aware using the `Camera3D` map-origin target (AUDIT3D-06 fix #4, `audio.gd:317-323`), keeping the existing 20–60 m curve; `AudioStreamPlayer3D` is a later wave. |
| 5 | **Camera FOV and donor minimap ArcTan offset unverified/unimplemented** — zoom feel and minimap jump framing can differ from the donor even though the coordinate bug is fixed. | `V790_donor_camera_changes.md:30,43-44,328-332` (FOV 17.27° is an assumption; ArcTan offset left OPEN); `STATUS_WAVE7_PHASE2.md:37`; `AUDIT3D_TRIAGE.md:54` (E6 flat-Y zoom anchor, no measured bug). | Recover the donor projection/sensor or run an A/B measurement; until then keep the value labelled assumption and add no new number. |
| 6 | **Donor light/fog constants dropped or reduced in the 3D renderer** — colour and atmosphere can drift from the donor even with a real `WorldEnvironment`+`DonorSun` node tree. | `AUDIT3D_TRIAGE.md:44,66`; `AUDIT3D_04:39` (EXPOSURE 2.4→1.45, AMBIENT 2.5→1.10, SUN 2.2→1.7, donor diffuse dropped); `AUDIT3D_08:66-68` (`light.cfg`, `colors.lib` unused); `AUDIT3D_09:39-51` (rig measured). | Restore the donor constants verbatim from `app/scripts/heightmap_world3d.gd` into `variant3d/scripts/heightmap_world3d.gd`, then re-capture a windowed frame. |
| 7 | **180 MB single atlas exceeds GitHub's per-file limit** — a fresh clone can lose the default terrain texture path (fallbacks exist but change appearance). | `README.md:99-108`; `STATUS_WAVE7_PHASE2.md:50-51`; measured `variant3d/assets/terrain/atlas/tile_index_atlas.png` = 179,912,941 B on disk. | Keep the file uncommitted or put it in Git LFS; otherwise ship `split`/`array` mode and verify `world.stats["atlas_mode"]` on a clone. |
| 8 | **No formal variant `CLEAN` verdict / 60 unacked historical probe failures** — gate history cannot be asserted clean, so "green" rests on individual passing jobs. | `STATUS_WAVE7_PHASE2.md:40-42`; verified `variant3d/tools/assert_clean.py:33-36` points `SPOOL` at `app/.godot_queue`, not the variant spool. | Make a variant-aware clean check (`SPOOL = ROOT/variant3d/.godot_queue`), acknowledge the superseded probe failures with their passing successors, and run it once. |
| 9 | **FX are hardcoded primitives; donor PFX semantics unused** — smoke/explosions/flash do not use donor frame counts, sizes or colours; hit and dust have no visual feedback. | `AUDIT3D_06:25,38-44,102-108`; `AUDIT3D_08:69` (only 3 literal keys used); `AUDIT3D_TRIAGE.md:37-38` (offset/ghost/rally now closed). | Generate a read-only numbers-only table from `source.pfx` for FX life/alpha and reuse it in `world3d_fx.gd`; keep procedural meshes and do not claim parity. |
| 10 | **Fresh-clone / hygiene leftovers** — `shots/` output dir absent (captures silently lost), 4236 bake PNG+`.import` possibly ignored, 17 new `.gd` without `.uid` sidecars, 2099 uncached `.ctex` (regenerated), 2 orphan `.import` files. | `AUDIT3D_07:52-61` (E9/E14/E15/E20/E21, no P0); `AUDIT3D_09:63-66` (screenshots landed in `user://` because `shots/` missing). | Create `variant3d/shots/` before capture, verify git-tracked status of the bake files (no git was used in this audit), and do one editor import pass to regenerate `.uid`/`.ctex`. |

Not ranked as gaps because they are outside the definition: campaigns/missions/network, donor skinned-rig parity, donor `.map` relief, and `.pfx` art (§6).

## 5. What to test in the window (user checklist)

Run `launch_variant3d.bat` (windowed, `render_mode="3d"`); these checks target things the headless gates cannot prove.

- [ ] **Minimap centre click (retest required after V7-81/90):** the main 3D view stays on the map — no black screen, no jump to the terrain corner; expect camera near world centre `(0, ~34, ~55)` for a centre click (`V781_minimap_black_fix.md:162-165`).
- [ ] **Minimap corners:** clicking each corner clamps the camera inside the terrain instead of flying off it (`V781_minimap_black_fix.md:164`; corner lands near `(-297, -300)` centred).
- [ ] **Real 3D pixels, not the CPU map fallback:** stdout/stderr does not print `fallback map render`; the scene shows perspective terrain, water and meshes (`AUDIT3D_09:27-29,62`; V7-70 jobs 138/179).
- [ ] **Selection and orders:** left-click/box-select a unit and an enemy, right-click move/attack, confirm the HUD panel updates and a selection marker appears; F/J/K/L formation keys work (`AUDIT3D_TRIAGE.md:35` RB-01; `AUDIT3D_09:74` historical `int(id)` error now closed).
- [ ] **Build ghost and rally:** entering a build site shows a green/red footprint; a selected building's rally point shows its pennant (`AUDIT3D_TRIAGE.md:38`).
- [ ] **Camera feel:** one wheel notch ≈ 2 m height change at all zoom levels; key pan ≈ 2 m/s independent of zoom; middle-drag works; tilt stays −32° (`V790_donor_camera_changes.md:296-317`).
- [ ] **Audio:** event sounds fire and ambient beds are audible; **flat volume/no panning is expected** and is not a new bug (§4 rank 4).
- [ ] **stderr sweep:** no `Nonexistent 'int' constructor`, no `Vector3 → Vector2` audio error, no `bind()` type error; welcome-time `ObjectDB/resources leaked` warnings are cosmetic (`AUDIT3D_TRIAGE.md:48-58`; `AUDIT3D_09:73-76`).
- [ ] **If capturing evidence:** save a `Screenshot3DViewport` frame and label it `3D_GPU_CAPTURE`, never `DONOR_PARITY`; a donor A/B does not yet exist (§3).

## 6. Honesty — what is NOT claimed

- **No donor visual parity.** Real 3D pixels exist, but no GPU A/B against the donor was run; "looks like Cossacks 3" is not asserted (`README.md:83,230`; `STATUS_WAVE7_PHASE2.md:32-33,54-55`).
- **No true positional audio.** No `AudioStreamPlayer3D`, `AudioListener3D`, buses or donor emitter semantics; only the inherited flat 325-clip bed and (in 2D frame) distance culling (`AUDIT3D_06:29,94-96`; source grep). Donor radius semantics 8000 vs 80 remain UNVERIFIED (`AUDIT3D_06:96`).
- **No full donor animation frames or skinning.** Sampled flat-root pose morph with donor-timed AAF for **one** sid, 6 frames/action, no interpolation; labelled `PORT APPROXIMATION — NOT DONOR PARITY` (`STATUS_WAVE7_PHASE2.md:34-35`; `AUDIT3D_06:26,58-62`). No `.ani` files exist in the donor (`AUDIT3D_08:57`).
- **No campaigns, missions, DLC maps, cutscenes or network.** Out of scope D-12; only a singleplayer skirmish is claimed (`STATUS_WAVE7_PHASE2.md:188-195`).
- **No bit-exact donor terrain/water/FX parity.** Substitutes (`height_tex`, blend/unshaded/cull choices, procedural FX, single-pass blend) are labelled PORT APPROXIMATION/SUBSTITUTE (`terrain_tileindex.gdshader:19-37`; `water3d.gdshader:40-45`; `AUDIT3D_06:38-44`).
- **No donor FOV/projection, bone parents, `.map` relief, ACL/PFX or alpha-colour semantics** — these are UNREADABLE or UNVERIFIED and no value was invented (`AUDIT3D_TRIAGE.md:69-75`; `V790_donor_camera_changes.md:326-332`).
- **No formal variant CLEAN verdict** and no verified git-tracked/fresh-clone state — no git operations or Godot launches were performed in this synthesis, and the existing `variant3d/tools/assert_clean.py` still targets the `app/` spool (`STATUS_WAVE7_PHASE2.md:40-42`; `assert_clean.py:33-36`).
- **No claim that the 2D port was modified.** The charter requires `app/` byte-identical and its gate green; this audit read it but did not verify git state (`AUDIT3D_TRIAGE.md:77-82`; `STATUS_WAVE7_PHASE2.md:21-22`).

## 7. Peer-report availability / independent confirmation limits

Per the charter's single-look rule, I listed `docs/coord_swarm_2026-11-24/reports/` once and a targeted `COMPLETENESS_*` glob found **no** COMP-01..05 reports at read time. Dimensions that would have been independently re-confirmed by peers are therefore sourced as follows:

- **Tests/gates (COMP-01)** — partially confirmed directly: `selftest.json`, `uitest.json` and `t_render_mode.json` were read in current source; the 29/17-step parity and gate job ids come from `AUDIT3D_04:37` / `STATUS_WAVE7_PHASE2.md:16-22`, not from a peer report.
- **2D-vs-3D feature coverage (COMP-02)** — inferred from `AUDIT3D_04` E01-E17, `AUDIT3D_08` and the README feature table, not from a peer sweep; no independent per-feature 2D/3D/stub matrix was available.
- **Donor fidelity (COMP-03)** — taken from `AUDIT3D_01/02/03/08` and the V78x/TERRAIN2 reports; the "donor-grounded presentation" rating is only as strong as those dated audits plus the shaders I read directly.
- **Runtime stability (COMP-04)** — based on `AUDIT3D_09` (pre-fix snapshot) and `AUDIT3D_TRIAGE.md:48-58` closures; **no fresh post-V7-92 windowed error sweep** was available, so this dimension is AMBER, not GREEN.
- **Shipping hygiene (COMP-05)** — based on `AUDIT3D_07`, README:99-113, and direct filesystem reads (atlas size, `assert_clean.py` spool); git-tracked status could not be confirmed without git (forbidden by charter).

Every rating above is deliberately conservative where only audit-era evidence exists: a CLOSED row in `AUDIT3D_TRIAGE.md` is acceptance of the documented probe/gate evidence, not a new measurement by this agent.
