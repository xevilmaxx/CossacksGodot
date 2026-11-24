---
id: TERRAIN2-05
scope: Sweep all 2026-11-24 session docs/reports for unresolved leftovers and open questions; one prioritised to-do list (audit only)
date: 2026-11-24
status: COMPLETE — AUDIT ONLY (no source/asset/git edits)
---

# TERRAIN2_05 — Leftovers / open-questions to-do list (2026-11-24)

## Method

Read-only sweep of `docs/coord_swarm_2026-11-24/`: `TERRAIN2_CHARTER.md`,
`AUDIT3D_TRIAGE.md`, `PROGRESS.md`, `IMPROVEMENTS.md`, `FINAL_GATE.md`,
`GAPS.md`, `WAVE7_3D_VARIANT_CHARTER.md`, `docs/variant3d/STATUS_WAVE7_PHASE2.md`,
the root `docs/STATUS_*.md`, and every `reports/*.md` open-question /
follow-up / NOT-DONE / UNVERIFIED section (109 such sections extracted).
A handful of current files were read-only cross-checked (`camera3d.gd`,
`world3d_fog.gd`, `world3d.gd`, `main.gd`, `t_hud_fidelity.gd`, file existence)
so that already-fixed items are not re-listed. No donor file was run or copied;
no Godot job was submitted; no source/asset/config/test/git edit was made.

**Exclusions honoured (already closed, not re-listed):** all 10 AUDIT3D P0s
(G1–G10), launcher, `dbg_*` crash, self-snapshot regression, E18/E19,
model coverage / OBJ import, donor tints implementation, pose-memoisation and
`res_dirty` reconcile perf, HUD bind / picking-flag / camera-jump API seams,
`t_hud_fidelity` `[N]`→`(N)` drift (now `(N)` at `app/tests/t_hud_fidelity.gd:142-148`),
fog `render_priority` error (now `sorting_offset` at
`variant3d/scripts/world3d_fog.gd:211-212`), FX `consume_events` double-spawn
(now `false` at `variant3d/scripts/world3d.gd:554` and sole path via
`main.gd:1694-1733`), and the `main.gd:1499` untyped-`idx_path` parse break
(explicit `String` now).

**Priority key:** P1 = blocks acceptance / user-visible correctness;
P2 = real fidelity or hygiene gap with evidence; P3 = cosmetic, speculative or
low-cost cleanup. No P0 remains: the ten AUDIT3D P0s are closed
(`AUDIT3D_TRIAGE.md:26-38`). Status: **OPEN** = actionable and unfixed;
**UNVERIFIED** = evidence exists but no measurement/repro/proof;
**BLOCKED** = needs external decision, donor data or environment.

**Terrain note:** donor terrain fidelity (relief, water/waves, fog/cloud/sky,
splat/albedo consistency) is being researched in parallel by TERRAIN2-01…04.
It is listed **once** as DF-02 and is **not** expanded here — no terrain
research is duplicated by this report.

## 1. Real runtime bugs / unverified runtime behaviour

| ID | One-line leftover | Evidence (path:line) | Pri | Suggested owner / file | Status |
|---|---|---|---|---|---|
| RB-01 | User-reported "minimap LMB → black main view": V7-81 source fix is in `camera3d.gd` but no V7-81 report or verification job ever landed | `PROGRESS.md:262-273`; `variant3d/scripts/camera3d.gd:147,151,186-198`; no `reports/V781*.md` | P1 | V7-81 session / coordinator, `camera3d.gd` | UNVERIFIED |
| RB-02 | Fog overlay samples `game.height` while terrain mesh is built from the base64 dump height; quads can sink/float (`FOG_Y_OFFSET=0.03` has no donor source) | `reports/V716_world3d_fog.md:138-139`; `reports/V751_world3d_integration.md:128-131` | P1 | integrator, `world3d_fog.gd` + `world3d_terrain.gd` | UNVERIFIED |
| RB-03 | Entity fog-visibility culling not implemented: `sync()` honours only `dead`/`hidden`/depletion, not `fog_explored`/`fog_vis` | `reports/V751_world3d_integration.md:132-135`; `reports/V716_world3d_fog.md:140` | P1 | entities owner, `world3d_entities.gd` | OPEN |
| RB-04 | No end-to-end 3D-mode runtime job; `t_render_mode` is source inspection only and does not execute the 3D branch | `reports/V750_main_integration.md:200-211`; `reports/V737_test_render_mode.md:78` | P1 | coordinator, variant runner | UNVERIFIED |
| RB-05 | Capture-mode inversion: port lets peasants/artillery capture buildings; donor `bcancapture=False`; artillery-rate claim conflicts with R12-05 | `GAPS.md:27`; `reports/W21_game_rules.md:164-166`; `PROGRESS.md:104-105` | P2 | `game.gd` owner | OPEN |
| RB-06 | Gold-shortage desertion has no rebel-player destination; policy (kill / flip to enemy / new player) undecided and touches victory logic | `reports/W21_game_rules.md:167`; `GAPS.md:22` | P2 | `game.gd` owner + coordinator | OPEN |
| RB-07 | AI force ≥260 / wave ≥1 is a measured fail: gold mine never built, gold bottoms at 2, `train_unit` rejects gold units → waves never fire | `GAPS.md:33-34`; `reports/W51_ai_force_wave.md:340-345`; `reports/I06_ai_metal_mines.md:111-113` | P1 | AI owner, `ai.gd` / `game.gd` | OPEN |
| RB-08 | `terrain_px` quality change updates only a scalar; 3D terrain mesh is never rebuilt on quality change | `reports/V762_entity_feed.md:156-158` | P2 | terrain owner, `world3d.gd` / `world3d_terrain.gd` | OPEN |
| RB-09 | Ghost ground point uses flat `Camera3D.screen_to_world()` (Y=0) while picking ray-marches the height field; steep terrain diverges from click | `reports/V776_ghost_rally.md:130-134` | P2 | input owner, `world3d.gd` / `input_controller.gd` | UNVERIFIED |
| RB-10 | Rally TTL 2 s expires unseen markers; 3D redraws every `sync()` vs 2D dirty-gated redraw; visibility equivalence not latency-measured | `reports/V776_ghost_rally.md:139-142`; `reports/V715_world3d_fx.md:94` | P2 | FX owner, `world3d_fx.gd` | UNVERIFIED |
| RB-11 | Picking parallax: `BODY_LIFT_M=0.8` guess, screen-px reach vs 2D metre reach, ~2 m any-entity fallback for `players_only=false` | `reports/V768_picking_fix.md:196-200`; `reports/V752_input_integration.md:136-141`; `reports/V775_pick_caller.md:167-171` | P2 | picking owner, `picking3d.gd` | UNVERIFIED |
| RB-12 | Behind-camera entities clamp `_ppm()` to 0.01 m and inflate pick reach; no guard | `reports/V768_picking_fix.md:201-203`; `reports/V775_pick_caller.md:169-171` | P3 | picking owner, `picking3d.gd` | OPEN |
| RB-13 | No `unbind_3d`: returning to a 2D skirmish on a reused HUD keeps the 3D source (benign full-map fallback, but no reset) | `reports/V753_hud_integration.md:246-250`; `reports/AUDIT3D_05_camera_hud_pick.md:185-186` | P2 | HUD owner, `hud.gd` / `hud3d_adapter.gd` | OPEN |
| RB-14 | `render_mode="3d"` without `bind_3d()` silently gives a full-map HUD box (currently wired at `main.gd:1020-1023`, but no regression guard) | `reports/V753_hud_integration.md:238-242` | P2 | `main.gd` owner | UNVERIFIED |
| RB-15 | `world_to_px` / `view_rect` canvas-px vs viewport-px ambiguity still affects patrol overlay and double-click in 3D | `reports/V751_world3d_integration.md:136-140`; `reports/V752_input_integration.md:148-151`; `reports/V71_mechanics_inventory.md:262` | P2 | `world3d.gd` owner + coordinator ruling | OPEN |
| RB-16 | Camera focus stays map-origin metres while world meshes are centred; `_center_camera3d_target()` freezes `clamp_pos()` memo, so a future camera edit can push focus off-map again | `reports/V770_viewport_capture.md:222`; `reports/V773_fx_world_offset.md:168-171`; `reports/V771_audio_vector3.md:136-146` | P2 | camera owner, `camera3d.gd` / `main.gd` | UNVERIFIED |
| RB-17 | F9 / Options / rally runtime paths never individually exercised in 3D (only selftest + probe calls) | `reports/V762_entity_feed.md:153-155`; `reports/V776_ghost_rally.md:146-148` | P2 | coordinator smoke pass | UNVERIFIED |
| RB-18 | `--seq` windowed capture still targets the root viewport and can fall back to the CPU 2D map | `reports/V770_viewport_capture.md:222-223` | P2 | `main.gd` owner | OPEN |
| RB-19 | `dock` has a paid placement path but `can_place()` rejects water (`game.gd:3620`), so the naval dock is unusable; bar18/dip hotkeys share letters with other commands | `reports/W32_building_ux.md:444-450` | P2 | `game.gd` / `config.json` owner | OPEN |
| RB-20 | Builder death mid-build can orphan a site; shift-queue with one peasant can stall earlier sites (`cmd_build` overwrites one order) | `reports/W31_build_rules.md:319-324` | P2 | `game.gd` owner | OPEN |
| RB-21 | `artillery_explosion_fx` smoke-test failure is pre-existing (reproduced on untouched backup); visual gate still open | `reports/W33_selection_aura.md:147-153`; `PROGRESS.md:851-855` | P2 | test owner / `world.gd` | OPEN |
| RB-22 | 3D path may still execute the 2D sprite fallback at `world.gd:399-413`; whether it is only test-reachable is unchecked | `reports/AUDIT3D_07_resources.md:75-76` | P2 | coordinator runtime probe | UNVERIFIED |
| RB-23 | Fresh-clone headless boot with no editor import pass: missing `.ctex` for static textures could fail `load()` | `reports/AUDIT3D_07_resources.md:74-76` | P2 | tooling owner | UNVERIFIED |

## 2. Donor fidelity gaps

| ID | One-line leftover | Evidence (path:line) | Pri | Suggested owner / file | Status |
|---|---|---|---|---|---|
| DF-01 | No donor GPU visual A/B has ever been performed; real 3D pixels exist but parity is unclaimed across all modules | `docs/variant3d/STATUS_WAVE7_PHASE2.md:31-33`; `reports/V770_viewport_capture.md:214-219`; `reports/V778_ship_skins.md:214-217` | P1 | coordinator (GPU A/B harness) | UNVERIFIED |
| DF-02 | Donor terrain fidelity remains unresolved (height relief/LOD, water & waves, fog/cloud/sky, splat seed+size consistency, cliff striations) — **TERRAIN2-01…04 are researching this in parallel; do not duplicate** | `AUDIT3D_TRIAGE.md:41-42`; `TERRAIN2_CHARTER.md:23-28`; `reports/AUDIT3D_03_terrain.md:153-171` | P1 | TERRAIN2-01 / 02 / 03 / 04 peers | OPEN |
| DF-03 | Donor absolute FOV / sensor width for focal 400 and absolute yaw are UNVERIFIED; 2.90° vs 17.27° are both assumptions | `reports/G31_donor_3d_truth.md:262-263`; `reports/AUDIT3D_05_camera_hud_pick.md:168-174`; `reports/V711_camera3d.md:84-85` | P1 | donor RE / `camera3d.gd` | BLOCKED |
| DF-04 | Donor bone-parent table is unreadable → donor-faithful skinned GLB stays BLOCKED; all shipped poses remain flat-root PORT APPROXIMATION | `reports/V72_mesh_conversion_feasibility.md:423-426`; `reports/V764_donor_morph_anim.md:204-206`; `reports/AUDIT3D_08_donor_coverage.md:173-175` | P1 | donor RE / `anim3d.gd` | BLOCKED |
| DF-05 | True 3D positional audio (`AudioStreamPlayer3D`, donor emitter radius 8000 vs 80 semantics) not built; only distance culling works | `AUDIT3D_TRIAGE.md:57`; `reports/V771_audio_vector3.md:147-149`; `docs/variant3d/STATUS_WAVE7_PHASE2.md:38-39` | P1 | audio owner, `audio.gd` | OPEN |
| DF-06 | Donor alpha, >1.0 colour clamping and uniform-0 tint operation remain UNVERIFIED; exact vs clamped JSON variants both shipped | `reports/V761_donor_key_colors.md:119-123`; `reports/V765_donor_tints.md:156-159`; `AUDIT3D_TRIAGE.md:68` | P2 | donor shader RE / `world3d_entities.gd` | UNVERIFIED |
| DF-07 | Donor PFX semantics (`PixelRatio`/`Interval`/`FrameRate`/`AlphaTime/Power`) unmapped; three literal trail constants unproven | `reports/AUDIT3D_06_fx_anim_audio.md:147-152`; `reports/V715_world3d_fx.md:92`; `reports/AUDIT3D_08_donor_coverage.md:181-182` | P2 | FX owner / donor PFX RE | UNVERIFIED |
| DF-08 | Donor fog-of-war → terrain shader binding and depth-fog behaviour UNVERIFIED (depth fog disabled in gameplay camera) | `reports/AUDIT3D_03_terrain.md:166-168`; `reports/AUDIT3D_05_camera_hud_pick.md:182-184`; `reports/V716_world3d_fog.md:141` | P2 | TERRAIN2-03 peer (fold into DF-02) | UNVERIFIED |
| DF-09 | Donor minimap bottom-right 240 px vs port bottom-left 200 px: needs right-edge panel re-partition plus uitest assertion update | `reports/W23_hud_fidelity.md:35-49,353-355`; `reports/W54_test_expectations.md:175-177`; `GAPS.md:44` | P2 | HUD owner `hud.gd` + test owner `uitest.gd` | OPEN |
| DF-10 | Field regrowth is binary 60 s full restore vs donor 31.25 s gated +10% HP increments | `GAPS.md:15`; `reports/D01_resow_failure.md:183`; `reports/R01_farming_production.md:86-88` | P2 | `game.gd` owner | OPEN |
| DF-11 | Economy gaps: two-sided market absent, 0.35 price floor is a port invention, gold-shortage desertion/ship-stop incomplete | `GAPS.md:22`; `reports/R07_economy_market.md:60-67` | P2 | `game.gd` owner | UNVERIFIED |
| DF-12 | Formation order after moving is confirmed missing (array-index fan-out, no persistent slot map); morale/veteran/rout features are UNVERIFIED inventions | `GAPS.md:36-37`; `reports/R12_new_micro.md:578`; `reports/R03_formations_squads.md:82-83` | P2 | `game.gd` owner | OPEN / UNVERIFIED |
| DF-13 | Hotkey gaps: control-group append + double-tap-jump, speed keys, PGUP/PGDN/Home, donor P=Shipyard vs port P=patrol, F9/Space semantics | `GAPS.md:28`; `reports/R05_hotkeys_controls.md:81-86` | P2 | `input_controller.gd` / `config.gd` owner | OPEN |
| DF-14 | Scotland depth: 1/8 unique units, 3/13 skinned buildings, `bake_scottish.py` handles only the unit key; generic `highlander` miscounted | `GAPS.md:41`; `reports/R08_roster_upgrades.md:137-142`; `PROGRESS.md:104-105` | P2 | data/assets owner | OPEN / BLOCKED |
| DF-15 | Naval: 5 baked families staged-unwired, chaika/ferry unbaked, battleship/xebec hull-only, 2 orphan PNGs, 4 stale world-anchor index fields | `GAPS.md:19`; `reports/W210_naval_assets.md:291-298`; `reports/R09_naval.md:60-66` | P2 | data/assets owner | OPEN |
| DF-16 | New micro gaps unfiled: log ticker, off-screen alarm, capture-blocked-by-gunfire, capture cancels queue/upgrade, artillery capture rate, staged corpse decay | `GAPS.md:24`; `reports/R12_new_micro.md:61-64`; `reports/W21_game_rules.md:166` | P2 | `game.gd` owner | OPEN |
| DF-17 | Donor pick radius / overlap depth engine-side and UNVERIFIED; no donor literal invented for either port boundary | `reports/AUDIT3D_05_camera_hud_pick.md:175-177`; `reports/V768_picking_fix.md:204-205` | P2 | donor RE / `picking3d.gd` | UNVERIFIED |
| DF-18 | Donor minimap box rotation vs axis-aligned AABB and frustum fidelity UNVERIFIED (no donor path:line re-read) | `reports/V717_hud3d_adapter.md:125-128`; `reports/V753_hud_integration.md:251-254` | P2 | HUD adapter owner / donor RE | UNVERIFIED |
| DF-19 | Donor `wheelspeed` default, exact start zoom and metres/notch are UNVERIFIED; 0.75 start and 2.0 notch gain are port choices | `reports/W41_zoom_fluidity.md:238`; `reports/W42_zoom_input.md:167-174`; `reports/W55_visual_ab.md:173-174` | P3 | camera owner | UNVERIFIED |
| DF-20 | Donor victory condition `bexists` (town hall/farm) vs port any-building-or-unit elimination not aligned | `reports/R02_capture_siege.md:54`; `reports/W21_game_rules.md:167` | P2 | `game.gd` owner | UNVERIFIED |
| DF-21 | Donor GUI "team color container" skins not read; whether per-team choices differ from `gKeyColor` is unknown | `reports/AUDIT3D_02_colors.md:185-188` | P3 | donor GUI RE | UNVERIFIED |
| DF-22 | Donor `source.pfx` section→FX kind mapping absent; donor greys vs bright port colours unreconciled | `reports/AUDIT3D_02_colors.md:169-173` | P2 | FX owner / donor PFX RE | UNVERIFIED |
| DF-23 | Selection aura and rally flag visual A/B still open (idle-camera pulse gate, always-on toggle, aura scale overlap, garrison pip look) | `reports/W33_selection_aura.md:147-153`; `reports/W55_visual_ab.md:168-172` | P2 | coordinator screenshot / `world.gd` owner | UNVERIFIED |
| DF-24 | Zoom/edge-scroll FEEL and wheel-to-cursor tracking unverified by A/B; 4×/6× ramp may be aggressive at 1920×1080 | `reports/W41_zoom_fluidity.md:236-238`; `reports/W42_zoom_input.md:162-164`; `reports/W57_edge_scroll.md:252-256` | P2 | owner visual review | UNVERIFIED |
| DF-25 | Spell/branch: donor day/night is disabled in skirmish (parity), so any cycle would be new design — needs an explicit go/no-go, not a gap | `GAPS.md:42`; `reports/R10_environment.md:50-51` | P3 | coordinator decision | UNVERIFIED |

## 3. Performance

| ID | One-line leftover | Evidence (path:line) | Pri | Suggested owner / file | Status |
|---|---|---|---|---|---|
| PF-01 | Windowed absolute `sync_ms` after V7-79/V7-80 was never re-measured; only CPU ratios (8–12×) are quantified | `reports/V779_pose_memo.md:163-165`; `PROGRESS.md:341-348`; `docs/variant3d/STATUS_WAVE7_PHASE2.md:44-45` | P1 | coordinator windowed run | UNVERIFIED |
| PF-02 | 3D placement ghost calls `can_place()` every frame (2D throttles >2 px / sid change / 120 ms); a sim collision scan per frame | `reports/V776_ghost_rally.md:135-138` | P2 | `world3d.gd` owner | OPEN |
| PF-03 | Rank-1 sim hotspot not implemented: `_grid_rebuild()` allocates Vector2i + bucket array per cell every tick; `grid_query()` allocations at 11 sites | `GAPS.md:63`; `reports/P01_sim_hotpaths.md:111-116` | P2 | `game.gd` owner | OPEN (ESTIMATE) |
| PF-04 | `_kind_class` / TARGET_TABLE hoist and per-call building/unit array rebuilds not implemented (`enemies_preferred`, `_check_victory`) | `GAPS.md:64,66`; `reports/P01_sim_hotpaths.md:114-124` | P2 | `ai.gd` / `game.gd` owner | OPEN (ESTIMATE) |
| PF-05 | `res_nodes` scanned 3×/tick (stump age, removal, field regrow) at ~1700 nodes; maintained arrays not added | `GAPS.md:65`; `reports/P01_sim_hotpaths.md:117-118` | P2 | `game.gd` owner | OPEN (ESTIMATE) |
| PF-06 | `<30 s` standalone subset target not met: 41.83 s, ~36 s residual world/hud forest bake; guarded no-visual mode not attempted | `reports/W52_tiers_fast_subsets.md:278-282`; `reports/W26_test_speed.md:229-231`; `PROGRESS.md:230-232` | P2 | `main.gd` / `world.gd` owner | OPEN |
| PF-07 | `run_groups()` one-process speedup unmeasured; snapshot restore cost (`save_load` 28 s outlier) unverified | `reports/W26_test_speed.md:232-244`; `reports/W52_tiers_fast_subsets.md:288-290` | P2 | test owner | UNVERIFIED |
| PF-08 | Whole-map render remains BLOCKED-BY-BAKE-TIME; single-pass final-res bake and high-preset numbers unmeasured | `reports/W56_whole_map_feasibility.md:171-175`; `reports/W53_world_perf_light.md:265-272`; `IMPROVEMENTS.md:24,25` | P2 | `app/world.gd` owner | BLOCKED |
| PF-09 | W2-5 post-bake chunk early-out closed with no change shipped; archived patch not re-applied, `BAKE_BENCH`/minimap-hole checks not exercised | `IMPROVEMENTS.md:45`; `reports/W25_world_perf_weather.md:247-256` | P2 | `app/world.gd` owner | BLOCKED |
| PF-10 | Fog overlay full-map rebuild re-adds 25,600 quads on a visibility flip; no partial `surface_update_attribute_region`, not measured | `reports/V716_world3d_fog.md:142` | P3 | fog owner | UNVERIFIED |
| PF-11 | FX batches reserve 4096 slots; per-unit `pose_for` still skins ~577 verts every sync (memo reduced calls, not work per unique pose) | `reports/V774_consume_poses.md:195`; `reports/V778_ship_skins.md:230-233` | P3 | entities owner | OPEN |
| PF-12 | Anim-descriptor memo invalidation, minimap-box overlay duplication and chunk-sprite batching remain unmeasured; water `fract()` removal is a NO_WIN unless A/B'd | `reports/P02_render_hotpaths.md:69-74`; `GAPS.md:72` | P3 | render owner | UNVERIFIED |
| PF-13 | First-play audio hitch / small hot-set preload deferred; peak RSS and startup delta from I5 not measured | `reports/I05_lazy_audio.md:118-126` | P3 | audio owner | UNVERIFIED |
| PF-14 | `C3Game.setup` / `C3World.bind` stall cause unknown (baseline A/B proves it is unrelated to G-P7); stacks probe needed | `reports/W25_world_perf_weather.md:247-249` | P2 | tooling owner | BLOCKED |

## 4. Tooling / hygiene

| ID | One-line leftover | Evidence (path:line) | Pri | Suggested owner / file | Status |
|---|---|---|---|---|---|
| TH-01 | No formal variant CLEAN verdict is claimed; 60 historical unacked probe-iteration failures remain (doc also says "no variant `assert_clean.py`", though `variant3d/tools/assert_clean.py` now exists — recheck) | `docs/variant3d/STATUS_WAVE7_PHASE2.md:40-42`; `PROGRESS.md:316-318`; file existence `variant3d/tools/assert_clean.py` | P1 | coordinator / variant tooling | UNVERIFIED |
| TH-02 | 4236 ignored legacy sprite files: whether they are already force-tracked in git is UNVERIFIED (no git operations permitted this session) | `AUDIT3D_TRIAGE.md:58`; `reports/AUDIT3D_07_resources.md:73` | P1 (conditional) | coordinator (owner-owned git) | BLOCKED |
| TH-03 | Concurrent `doctor` kills Godot by name regardless of spool; it killed two variant import attempts | `reports/V70_scaffold.md:187-190` | P2 | tooling owner, `godot_runner.py` / ops | OPEN |
| TH-04 | Job 1262 exited 1 silently at ~190 s with no stdout/stderr or CLI JSON; cause UNVERIFIED | `reports/W24_ai_waves.md:272-274` | P2 | tooling owner | UNVERIFIED |
| TH-05 | Import jobs (tickets 1324/1326) failed exit 1 with no diagnostic; runtime `Image.load` workaround verified but cause unexplained | `reports/G32_heightmap_world.md:253-255` | P2 | tools owner | UNVERIFIED |
| TH-06 | `shots/` dir never created; 17 `.gd` lack `.uid` sidecars; 2099 `.ctex` absent | `AUDIT3D_TRIAGE.md:61-62`; `reports/AUDIT3D_07_resources.md:71-79` | P2 | tooling owner | OPEN |
| TH-07 | 259.36 MiB sha256-duplicate PNGs and 144.62 MiB stale `.ctex` are measured but not purged; dedup must preserve all paths via hardlink/copy | `reports/W29_dead_assets.md:132-196`; `GAPS.md:29`; `PROGRESS.md:104-105` | P2 | coordinator maintenance window | OPEN |
| TH-08 | 2 orphan root `.import` files are identical leftovers in both `app/` and `variant3d/`; single-lane deletion may reappear on re-copy | `reports/AUDIT3D_07_resources.md:77-79` | P3 | tooling owner | OPEN |
| TH-09 | 3D export needs an explicit include list for the `.gdignore` JSON-metric dependency | `reports/V70_scaffold.md:200-201` | P2 | export owner | OPEN |
| TH-10 | `t_naval` still tests only `yacht`; parameterise over all 7 index keys and assert 0 orphans/0 fallback | `reports/W210_naval_assets.md:297-298`; `reports/W22_data_truth.md:127-128` | P2 | test owner, `t_naval.gd` | OPEN |
| TH-11 | No dedicated runtime test for the four new build rules (`t_build_rules`) — the landed job was a collision-regression script | `reports/W31_build_rules.md:308-316`; `IMPROVEMENTS.md:18` | P2 | test owner | OPEN |
| TH-12 | `grid_equiv` assertion is inert (always true; mismatch branch is `pass`) | `GAPS.md:54` | P2 | `selftest.gd` owner | OPEN |
| TH-13 | Gate enforcement still needs an external `len(steps)==29` assertion so a subset run can never be mistaken for the full gate | `reports/T02_selftest_mechanism.md:128`; `GAPS.md:53` | P2 | tooling owner | OPEN |
| TH-14 | 3D capture harness reduced; donor light constants dropped in `heightmap_world3d.gd`; +0.1875 s selftest sim-time unexplained | `AUDIT3D_TRIAGE.md:63` | P2 | tooling owner | UNVERIFIED |
| TH-15 | `t_camera3d.gd` pre-existing `_initialize()` tree-timing failure needs separate triage before it can be called green | `reports/V766_camera_jump.md:183-185`; `reports/V732_test_camera3d.md:118-126` | P2 | test owner | UNVERIFIED |
| TH-16 | `launch_variant3d.bat --stay` forwarding is not confirmed honoured in the 3D main scene (job just lives until `--timeout 900`) | `reports/H01_hygiene.md:157-159` | P3 | launcher/main owner | UNVERIFIED |
| TH-17 | QA box numpy decision open; stdlib fallback guarantees ~32.7 s vs ~8 s with numpy | `reports/W28_scan_perf.md:533-534` | P3 | coordinator | UNVERIFIED |

## 5. Documentation

| ID | One-line leftover | Evidence (path:line) | Pri | Suggested owner / file | Status |
|---|---|---|---|---|---|
| DOC-01 | `STATUS_WAVE7_PHASE2.md` historical "LEFT" table and 7 open questions (snapshot ~12:05) were never reconciled with the authoritative FINAL VERDICT at the top | `docs/variant3d/STATUS_WAVE7_PHASE2.md:11,142-160,279-296` | P2 | V7-40 / coordinator | OPEN |
| DOC-02 | Same doc asserts "no variant `assert_clean.py`" and "formal variant CLEAN not claimed"; the tool now exists — re-verify and update, do not silently drop the caveat | `docs/variant3d/STATUS_WAVE7_PHASE2.md:40-42`; `variant3d/tools/assert_clean.py` | P2 | V7-40 / coordinator | UNVERIFIED |
| DOC-03 | `V751_world3d_integration.md` still lists the fog `render_priority` blocker although `world3d_fog.gd:211-212` now uses `sorting_offset` | `reports/V751_world3d_integration.md:113-123` vs `variant3d/scripts/world3d_fog.gd:211-212` | P3 | doc owner | OPEN |
| DOC-04 | `V774_consume_poses.md` records a stale `world3d.gd:490` comment still saying "static bind pose" after donor poses were consumed | `reports/V774_consume_poses.md:198-200` | P3 | doc owner / `world3d.gd` | OPEN |
| DOC-05 | Root `docs/STATUS_*.md` (updated 2026-11-21) still carry unresolved tickets/open questions (P-42 teams, P-04 board state, Z-01 triple-gate repetition, 0.80 fidelity threshold, malformed `status.json`) not reconciled with this session | `docs/STATUS_AI.md:82,118-120`; `docs/STATUS_SKIRMISH.md:297-300`; `docs/STATUS_TESTS.md:187,362-367` | P2 | doc owners | UNVERIFIED |
| DOC-06 | Stale doc paths: `STATUS_GRAPHICS.md:68,130`, `NAVAL_PORT_PLAN.md:34`, `SWARM_BOARD.md:663` say `anim/naval/index.json` / "54/1 keys" vs live `naval_units/index.json` with 7 keys | `reports/W210_naval_assets.md:296-297` | P3 | doc owners | OPEN |
| DOC-07 | `README.md` / `COMMANDS.md` still say "28-step" selftest; actual is 29 | `GAPS.md:83` | P3 | doc owner | OPEN |
| DOC-08 | `docs/audit/MICRO.md` rows 1–4,6–8,10,13,65 and other claims are stale — do not re-ticket without re-verifying against source | `GAPS.md:82`; `reports/R01_farming_production.md:81-99` | P2 | doc owner / coordinator | OPEN |
| DOC-09 | Brief-level path/format errors: `buildings.txt` does not exist in `data/locale/en` (names live in `units.txt:895-1015`); installed donor has 0 `.ani` files | `reports/R08_roster_upgrades.md:143-145`; `reports/AUDIT3D_08_donor_coverage.md:185-186` | P3 | doc owner | UNVERIFIED |
| DOC-10 | Final 3D status location undecided: this file vs `docs/variant3d/STATUS.md` per the atomic contract | `docs/variant3d/STATUS_WAVE7_PHASE2.md:294-296` | P3 | coordinator | OPEN |
| DOC-11 | No direct `self-snapshot: first difference at …block_rect` log was captured; E11's consequence is a strong static inference only | `reports/V769_selftest_snapshot.md:296-299`; `PROGRESS.md:510-511` | P3 | test owner | UNVERIFIED |
| DOC-12 | `sim_seconds` varies run-to-run (366.47–366.91); cause UNVERIFIED, no assertion depends on it | `reports/V769_selftest_snapshot.md:300-302` | P3 | tooling owner | UNVERIFIED |
| DOC-13 | T1 subset table lists a different step order for `formations_morale` than source order; both hard deps preserved, display order needs correcting | `reports/I04_test_split.md:143-147` | P3 | doc owner | OPEN |
| DOC-14 | Check name `worker_counts_brackets` / `all_bracketed` is cosmetic stale wording after `(N)` assertions were adopted | `reports/W54_test_expectations.md:169-173`; `app/tests/t_hud_fidelity.gd:140-148` | P3 | test owner | OPEN |

## Ranked recommendations — the three I would pick next

1. **RB-01 — close the user-reported minimap → black-view bug properly.**
   `camera3d.gd` already contains the V7-81 frame conversion (`:147,151,186-198`),
   but `PROGRESS.md:262-273` is the only record: there is no `V781*.md` report
   and no verification job. This is the only user-visible runtime bug that was
   dispatched and never closed with evidence. One targeted probe (minimap centre
   lands near world centre) + the variant selftest would convert it from
   UNVERIFIED to CLOSED and stop the frame-convention question (RB-16) from
   resurfacing.

2. **DF-01 — make donor visual A/B executable, then let the terrain peers use it.**
   Every remaining fidelity item (DF-02 terrain, DF-03 FOV/yaw, DF-06 tint
   semantics, DF-23 aura) ends at "UNVERIFIED — no donor comparison". The
   TERRAIN2-01…04 agents are producing donor-grounded recipes in parallel;
   without a repeatable GPU A/B harness their findings cannot be accepted or
   rejected. Building that harness is the highest-leverage next item and does
   not duplicate terrain research.

3. **RB-07 — resolve the measured AI force/wave failure.**
   `GAPS.md:33-34` and `W51_ai_force_wave.md:340-345` show a functional
   acceptance target that is still a measured fail: gold mine never built,
   gold bottoms at 2, `train_unit` rejects every gold-cost unit, so `wave`
   stays 0 after a clean 300 s soak. Unlike the fidelity items this is not a
   judgement call — it is a reproducible wrong behaviour with a bounded fix
   (stone priority for `mine_gold` / affordability-aware sid fallback) and a
   defined re-soak gate.

   Honourable mention: **PF-01** (one windowed `sync_ms` run after V7-79/V7-80)
   is cheap and would close the last open performance honesty caveat, but it is
   measurement, not a fix.

## Open questions / UNVERIFIED register (not turned into new work here)

- **Donor-vs-port decisions needed before any edit:** donor fidelity vs 2D
  palette parity (`AUDIT3D_02_colors.md:174-177`); uniform-0 operation
  (`V765_donor_tints.md:158`); formation slot-map parity vs accepted divergence
  (`R12_new_micro.md:578`); capture peasant/artillery inversion
  (`W21_game_rules.md:164-166`); desertion destination (`W21:167`);
  `world_to_px`/`view_rect` units (`V71_mechanics_inventory.md:262`).
- **Donor data unreadable (do not invent values):** bone parents, `.map` relief,
  ACL/PFX semantics, absolute FOV/yaw, water `hmapTex` binding, donor yaw,
  alpha and >1.0 clamping (`AUDIT3D_TRIAGE.md:66-72`; `G31:262-275`;
  `V761_donor_key_colors.md:119-127`).
- **Historical/no-proof items kept honest:** 0 `.ani` files in installed donor
  (`AUDIT3D_08:185-186`); `sim_seconds` variance (`V769:300-302`); suppressed
  import-job diagnostics (`G32:253-255`); job 1262 silent exit (`W24:272-274`).
- **No git ops were performed** — the 4236-file tracking question (TH-02) and
  all purge/untrack proposals (TH-07, DOC-05) remain owner-gated
  (`AUDIT3D_TRIAGE.md:74-79`; `W29_dead_assets.md:207-210`).

*Audit-only report. No donor binary was run or copied; no source, config,
asset, test or git change was made; exactly this one file was written.*
