---
id: COMP-04
role: "RUNTIME STABILITY / ERROR HISTORY of variant3d/ — windowed-game breakage sweep"
owner: COMP-04
date: 2026-11-24
scope: "READ-ONLY. No source/asset/config/test edits, no Godot launches, no git. Evidence: variant3d/.godot_queue/results/*/stderr.txt + stdout.txt and docs/coord_swarm_2026-11-24/reports/*.md + current source."
charter: docs/coord_swarm_2026-11-24/COMPLETENESS_CHARTER.md:1-23
status: "DELIVERED — 21 historical error classes triaged; 16 FIXED/BENIGN, 5 UNTIL WINDOWED RETEST; current-source hazard list + window test checklist"
visual_parity_claim: false
---

# COMP-04 — runtime stability / error history (`variant3d/`)

## 0. Method and evidence boundary

1. Parsed all 257 result directories under `variant3d/.godot_queue/results/`
   (`00000000` … `00000256`), every `stderr.txt`, with a local analysis script
   (outside the repo, `Temp/opencode/analyze_stderr.py`). Headlines were
   normalised (numbers/`res://` paths collapsed) and grouped by job. Bootstrap
   import noise (`Unable to open file` / `Failed loading resource` for `.ctex`
   and unimported block PNGs) and exit-time leaks were separated from script
   errors; both are reported explicitly below.
2. Cross-checked the CURRENT source with two local scripts
   (`Temp/opencode/crosscheck.py`, `hazard_scan.py`): extracted every
   `world.*`, `_wr.*` and `camera.*` member/string access in `main.gd`,
   `hud.gd`, `input_controller.gd`, `audio.gd`, `selftest.gd`, `uitest.gd`,
   `testbridge.gd` and compared against `var`/`func`/`const` declarations in
   `world3d.gd` and `camera3d.gd`; separately scanned for typed 2D params,
   `Vector2`↔`Vector3` assignments and `int()` on Dictionaries.
3. V7-92 integration was checked against `tile_atlas_loader.gd`, `water3d.gd`,
   `world3d_terrain.gd` and `shaders/{terrain_tileindex,water3d}.gdshader`.

**Boundary:** no windowed interactive play was performed by this agent. Where
verification exists only as a headless probe or a numeric measurement, the
verdict is explicitly **UNVERIFIED IN A WINDOW**, even when the error is
provably absent from the current source.

---

## 1. Evidence table — recorded runtime errors and their status

Jobs are ticket numbers; result directories are
`variant3d/.godot_queue/results/<6-digit-ticket>_<job-id>/`. "FIXED" means the
symptom is absent from CURRENT source and a later green job exists; it does
**not** claim donor parity.

| # | Symptom / file:line (as recorded) | Result-dir evidence | Verdict | Current-source proof |
|---:|---|---|---|---|
| E1 | Baseline parse cascade: `Could not find type "C3Game/C3World/C3Camera/C3HUD/C3Input/C3AI/C3TestBridge/C3Audio"`, `Identifier … not declared`, `Cannot infer … Variable`, `Could not resolve external class member 'bind'` in `main.gd` and scripts | jobs 0 (`v70-baseline-selftest`), 8, 10, 14, 17, 21, 29, 40 | **FIXED (historical scaffold).** No current parse error. | Full selftest job 254 `stderr.txt` has no `SCRIPT ERROR`; jobs 247/210/201 parse-clean on terrain/camera/world3d. |
| E2 | `Invalid type in function 'bind' in base 'CanvasLayer (C3HUD)' … argument 2 (Node3D (world3d.gd)) is not a subclass of the expected argument class` at `main.gd:1043`; followed by watchdog | job 69 `stderr.txt:8-13`; AUDIT3D-09 §2, §5.1, V753 §3b | **FIXED.** Typed param was `w: C3World` (Node2D). | `hud.gd:14` `var world` untyped; `hud.gd:167 func bind(g: C3Game, w)`; fix diff at `docs/.../reports/V753_hud_integration.md:152-178`. |
| E3 | 5× per-frame `SCRIPT ERROR: Invalid call. Nonexistent 'int' constructor.` at `world3d.gd:207` ← `sync` ← `main.gd:1551` (`get_selected()` returns Dictionaries) | jobs 71, 76 (`audit3d-selftest-3d-current`), 86 `stderr.txt:29-40`, 91 | **FIXED.** | `world3d.gd:279-301` now extracts `_int_prop(item, "id", -1)`; V762 §4 (`docs/.../V762_entity_feed.md:34-39,75-90`) + job 130 green, no error. |
| E4 | 5,087× `Invalid access to property or key 'dbg_res' on a base object of type 'Node3D (world3d.gd)'` at `main.gd:1592` — the user-reported windowed perf-print crash | job 173 `stderr.txt:85-93, …` (5,087 lines); `PROGRESS.md:925-936` | **FIXED.** | `world3d.gd:128-131` declares all four int counters with real increments (`:329,:332,:387,:627`); `main.gd:1592` null-guards `_wr`. Jobs 182/183/185 green; job 254 stderr has no such line. |
| E5 | `Trying to assign value of type 'Vector3' to a variable of type 'Vector2'` at `C3Audio._process (audio.gd:153)` — windowed/audio-active only | job 77 (`audit3d-shot-windowed-long`), AUDIT3D-09 §5.3 / G3 | **FIXED in source; WINDOWED RETEST UNVERIFIED.** | `audio.gd:157-161` branches on `cam.global_position is Vector3` → `Vector2(p3.x, p3.z)/16.0`; V771 jobs 97/117/121 (6/6 probe, 29/29 selftest). V771 §5 Q4: no new windowed run. |
| E6 | Minimap centre click → black main view (RB-01): camera `(320,34,374)` off the ±320 m centred terrain | job 206 (`v781-probe-before`, 2/8 expected FAIL); V781 §1-3 | **FIXED BY MEASUREMENT; USER WINDOWED RETEST PENDING.** | `camera3d.gd:177-186,207-242,408-439` (SIM↔centred conversion + `_own_clamp_target` seam guard); jobs 207/208/211 (11/11), 212 (29/29), job 253 windowed shows on-terrain camera `(277.11,39.33,-217.95)`. `AUDIT3D_TRIAGE.md:56-58` still says retest pending. |
| E7 | `Condition "!is_inside_tree()" is true. Returning: Transform3D()` / `Node not inside tree. Use look_at_from_position()` (camera probes) | jobs 75, 84, 96, 99, 107, 112, 149, 151, 187, 189 | **PROBE ARTIFACT, not present in production.** | Probes called `bind()` during `SceneTree._initialize()` (AUDIT3D-09 §3, note at :55). Production binds after `add_child` (`main.gd:578-595`, `1053-1059`); the one live `look_at` is guarded (`world3d_fx.gd:691 if node.is_inside_tree()`). No such line in jobs 253/254/255. |
| E8 | `Cannot call method 'get_visible_rect' on a null value`, `Camera is not inside scene` | jobs 96, 99 (`t_camera3d`) | **PROBE ARTIFACT.** | Same pre-tree-notification cause; V766 fixed the probes with deferred `_run()`. `camera3d.gd:185` calls `make_current()` only inside `bind()` after the node is added in production. |
| E9 | `Invalid assignment of property or key 'render_priority' … MeshInstance3D`, `Leaked instance dependency`, `Pages in use exist at exit … RasterizerSceneDummy` | jobs 23, 28, 57, 60 (fog/composition probes) | **PROBE / engine-exit only.** | Current `world3d_fog.gd:231 func _update_fog()`; no current `render_priority` assignment in `variant3d/scripts/*.gd`. |
| E10 | `String formatting error: unsupported format character`, `mapgen: missing mask …` | jobs 11, 2 | **FIXED (import bootstrap).** | Jobs 1-5 generated `.import`/`.ctex`; jobs 252/254 stderr clean of mapgen/import errors. |
| E11 | `Invalid call. Nonexistent function 'new' in base 'GDScript'`, `… 'is_valid'`, `Cannot return value of type "Resource" because return type is "bool"`, `Cannot get return value of "resize()"`, `TypeError Dictionary→String` in `tile_atlas_loader.gd` / shader probes | jobs 17, 21, 29, 219, 223, 226, 230, 239, 244, 246, 248, 250 | **FIXED.** | Loader now `extends RefCounted`, `load() -> bool` with `self.load()` (`tile_atlas_loader.gd:51,161-192,389-440`); `img.resize()` void (`:422`); `str(null)` guarded (`:405-411`). V791 jobs 245 PASS 28/28, 250 PASS 24/24; V786 job 235 PASS 47/47, empty stderr; V792 job 247 clean. |
| E12 | `Parse Error: Function "_ensure_shipped_skins()/_nearest_local()/_action_range_for()" not found in base self` and `world3d: cannot instantiate res://scripts/anim3d.gd` | job 173 (`v770-journey3d-probe`) | **FIXED (probe referenced wrong base).** | `anim3d.gd:742,893,918` now define all three; anim3d loads in jobs 252/253/254. |
| E13 | `Invalid access to property or key 'size' on a base object of type 'null instance'`, `Invalid access … 'global_transform' on Nil`, `Invalid assignment of index … Transform3D`, `Invalid type in function '_apply_tint' … MultiMeshInstance3D` | jobs 103, 124, 105, 156 | **FIXED (probe type contracts).** | `world3d_entities.gd:330 func _apply_tint(instance: GeometryInstance3D, mesh: Mesh, …)`, `:798 func _xf(id: int) -> Transform3D`; probes now bind real nodes (jobs 127/161). |
| E14 | Shader compile failures in water/tile-index probes (`Shader compilation failed`, invalid sampler hint `filter_nearest_mipmap_linear`, non-const default `1.0/512.0`) | jobs 217, 223, 226 | **FIXED.** | V786 job 235 PASS 47/47, empty stderr; V792 windowed job 253 rendered a real `Screenshot3DViewport` with tile grain and water band (no shader error in stderr). |
| E15 | `watchdog: wall-clock limit reached, forced exit` | jobs 69, 73, 166, 168, 173, 175 | **Runner timeout, not a game crash.** | Runner hard-kills at `--timeout` (`godot_runner.py:395-433`). With `--timeout 300`, jobs 251/252/253/254/255 completed green. |
| E16 | `An input event object is being parsed more than once in the same frame` | job 231 `stderr.txt:1-7` (`_v790_camera_probe.gd:37`) | **PROBE ONLY.** | `Input.parse_input_event` occurs only in `testbridge.gd:127,140,159` (test harness), not in game scripts. |
| E17 | `world3d_terrain: bind(game) with a height dump first` | jobs 12, 249 (probe called `build()` before a dump was bound) | **PROBE ONLY.** | `world3d_terrain.gd:557-560 build()` calls `_dump_from_game()` then `_decode_tile_indices()`; `world3d.gd:544-547` only calls `terrain.build()` when `_has_height_source(game)` (`:208-215`) is true. |
| E18 | Recurring benign warning: `world3d_entities: DONOR-SAMPLED FLAT-ROOT MORPH … NOT DONOR PARITY` (`world3d_entities.gd:206` ← `world3d.gd:549` ← `main.gd:1054`) | 45+ jobs, incl. every final run 252/253/254/255/256 | **PRESENT BY DESIGN (not an error).** | Documented in `AUDIT3D_TRIAGE.md:36` (G8 "CLOSED (approx)"). No visual parity claim. |
| E19 | Exit-time `ObjectDB instances leaked`, `resources still in use`, GLES texture / RID leaks (e.g. `Texture with GL ID of 46: leaked 5460 bytes`, `RenderingServer::get_singleton() is null`) | every final job: 252/253/254/255/256 | **PRESENT (cosmetic).** | AUDIT3D-09 §5.4 / G7; not fixed in this scope. No frame-output impact observed, but stderr is never fully clean. |

**Net:** no historical *script* error survives in the current source. The
remaining stderr content in the latest jobs (252-256) is the deliberate
flat-root-morph warning plus exit leaks only. The unverified part is whether
the fixes that were proven by **headless numeric probes** behave identically in
an interactive window.

---

## 2. Current-source hazard scan (scripted cross-check)

### 2.1 Property/method cross-check

`crosscheck.py` extracted **108** `world.*` / `_wr.*` / `camera.*` accesses in
`main.gd` and **34** in `input_controller.gd`; `hud.gd`, `audio.gd`,
`selftest.gd`, `uitest.gd`, `testbridge.gd` produced no unmatched world
accesses. Of the 35 `main.gd` flags, all are either engine `Node` methods
(`get_parent`, `get`, `set`, `call`, `make_current`, `get_viewport`,
`global_position`, `position` on the appropriate 2D/3D camera) or string-form
accesses whose target is declared (`_anim_dir` → `world3d.gd:725`,
`jump_to_world` → `camera3d.gd:393`, `_apply_transform` → `camera3d.gd:223`).
The single genuinely 2D-only flag, `camera.mark_dirty()` at
`input_controller.gd:239-240`, is guarded by `has_method` and sits in the
`else` (2D) leg.

Hazards that remain, with judgement:

| ID | Hazard | Evidence | Residual risk |
|---|---|---|---|
| H1 | **V7-70/V7-81 seam still writes camera private fields.** `_center_camera3d_target()` sets `_target`, `_last_clamp_target`, `_last_clamp_zoom` then calls `_apply_transform()`; call sites at startup (`:605`, `:1068`) and journey (`:1651`). `camera3d.gd:233-237` neutralises it only by a *signature* test (`_target == _last_clamp_target and _target != _own_clamp_target and zoom == _last_clamp_zoom`). | `main.gd:1008-1016`; `camera3d.gd:207-242,437-439`; V781 §4 Q1 | **HIGH-ish / UNVERIFIED:** if a zoom change makes `zoom != _last_clamp_zoom` when the foreign memo is written, the guard will not fire and `_apply_transform()` can subtract the map half twice → off-terrain focus (black view). The 11/11 probe simulated the seam at *constant* zoom. Windowed minimap + journey + wheel-zoom next frame is untested. |
| H2 | **Unbranched game-load / options callback on `world`.** `game_load()` reads `world.fog_explored/fog_vis._update_fog()`; quality callback reads `terrain_chunks`, `terrain_order`, `terrain_px`, `invalidate_forest_bake()`, `_build_masks()`, `_bake_px()`, `anim_tex`, `anim_index`, `_anim_dir()`; fog toggle writes `world.fog_sprite.visible`. | `main.gd:1394-1401`, `1485-1512` | **LOW (no error):** `world3d.gd:104-105,140-146,654-732` supplies honest aliases/no-ops for all of them. **BUT semantic:** `fog_sprite` is an empty `Node3D` proxy (`world3d.gd:525-530`), so the Fog-of-war toggle has no visual effect in 3D; quality change does not rebuild the V7-92 tile-index material. Not measured. |
| H3 | **Patrol/guard route overlay is a `Node2D` child of a `Node3D` fx layer.** `route_node = Node2D.new(); world.fx_layer.add_child(route_node)` with `_draw_*` canvas commands and `world.world_to_px()`. | `input_controller.gd:52-97,313-333,364-379`; `world3d.gd:517-524,613` | **LOW (no error, invisible art):** legal Godot node graph but 2D draw commands cannot paint in a 3D viewport. No runtime exception measured; patrol/guard visual feedback is effectively missing in 3D. |
| H4 | `hud.gd:_minimap_jump_3d()` returns `true` for every 3D LMB press/drag even when `_cam3d_jump()` fails (adapter/camera missing), so the caller unconditionally calls `set_input_as_handled()` contrary to its own comment "swallow ONLY when jump actually ran". | `hud.gd:1409-1410,1433-1443,1445-1454`; `bind_3d()` fallbacks at `:201-212` | **LOW (usability):** minimap LMB becomes a no-op if `bind_3d()` could not create the adapter; RMB orders still fall through. No error. |
| H5 | Typed params rejecting Node3D: none remain in live shared paths. | `hud.gd:14,167`; `input_controller.gd:13-15,66`; `main.gd:54-60`; only 2D-only scripts keep `C3World` (`camera.gd:10,53`) | **PROVABLY GONE** (E2). |
| H6 | Vector2↔Vector3 mixing: every suspicious assignment is either in a 2D-only branch or type-guarded. | `audio.gd:157-161` (3D) / `:161,328` (2D else); `input_controller.gd:231-240,843-846`; `hud.gd:1409-1415` / `:1486` (Camera2D `elif`); `main.gd:1645-1654`; `world3d_fx.gd:691` | **PROVABLY GONE in source** (E5/E3); audio branch not re-run in a window. |
| H7 | `int()` on Dictionaries: none remain in the 3D path. `world3d.gd:296` extracts `.id`; other `int()` calls use `.get("id", …)` or String/int inputs. | `world3d.gd:279-301`; `world3d_entities.gd:821,850,906,927,971,1008-1037`; `picking3d.gd:289`; `ai.gd:815` | **PROVABLY GONE** (E3). |
| H8 | `dbg_*` counters: all four exist on `world3d.gd` and on 2D `world.gd`; read/reset is null-guarded. | `world3d.gd:128-131,329,332,387,627`; `main.gd:143-146,1592,1599-1602` | **PROVABLY GONE** (E4). |
| H9 | Production bind order: 3D world is bound **before** `add_child` (`main.gd:1053-1055`, `579-581`). Modules therefore build off-tree. | current tree-dependent calls are guarded (`world3d_fx.gd:691`, `camera3d.gd:185` called post-add) | **LOW today, fragile:** any future module using `look_at`/`get_global_transform` during `bind()` will reproduce E7. |
| H10 | Dynamic `.call("…")` strings on world/camera: all guarded or defined. | `main.gd:1016,1020,1022,1499,1650`; `hud.gd:208,1447,1453`; `input_controller.gd:232,234,239,446,451,843-844` | **LOW**; no missing-method error in current source. |
| H11 | Exit leaks persist in every run (E19). | jobs 252-256 stderr | **PRESENT, cosmetic**; can be mistaken for a new failure by log-scraping tools. |

---

## 3. V7-92 terrain integration — new hazard surface

| ID | Area | Current-source observation | Verdict |
|---|---|---|---|
| V1 | **Atlas loader fallback.** `single` is default; `_load_atlas()` calls `loader.load()` and reads `current_mode` defensively (`world3d_terrain.gd:208-267`; `tile_atlas_loader.gd:161-187`). Single→split→array fallback verified headless in V791 jobs 245 (28/28) and 250 (24/24, including a simulated missing single PNG, `mode=split`, SHA `a1f123…dcfbd`). | Missing single PNG in a fresh clone switches to split; **if single AND split are both unavailable**, mode becomes `array`, `get_atlas_texture()` is null, and the dedicated split loader at `world3d_terrain.gd:259-262` also fails | **NO CRASH:** `_load_atlas()` returns false and `build()` keeps the V7-82 splat path with the explicit `PORT APPROXIMATION` label (`:654-668`). **UNVERIFIED in a windowed fresh-clone run** (V792 §6 Q4). |
| V2 | **Mask repack.** `_repack_mask_alpha()` loops every pixel of `alpha.png` (512×256) and `alphavert.png` (1024×512) via `get_pixel`/`set_pixel` on every `build()` (`world3d_terrain.gd:270-283`) ≈ 655k iterations. | Measured probes pass; no error. Possible startup hitch when combining this with the 180 MB single atlas upload (16384×8192 RGBA). | **NOT AN ERROR, UNMEASURED COST.** V792 only claims structural counts, no frame-time budget. |
| V3 | **Water module hook.** `build(w,h)` is called before `add_child` so `_ready()` does not auto-build a default grid; `bind_height_grid(height,w,h)` return value is **discarded** (`world3d_terrain.gd:469-486`; `water3d.gd:90-92,248-261`). | If `bind_height_grid()` fails, water3d keeps the 1×1 neutral texture (`water3d.gd:118-121,179`), i.e. full coverage at the wrong waterline — silently. Probe 251 measured `height_aware=true` with the real path. | **LOW, SILENT DEGRADATION.** No error path; verify `stats.water` in a windowed run. |
| V4 | **Shader uniform binding.** `_tileindex_material()` binds only `tile_atlas`, `alpha_atlas`, `alphavert_atlas`, `atlas_grid`, `shadow_enabled` (`world3d_terrain.gd:290-304`). The shader declares `shadow_map`, `eye_plane_s/t`, `texture_matrix` and 30 uniforms with APPROX defaults (`shaders/terrain_tileindex.gdshader:54-105`); V786 job 235 PASS 47/47 with empty stderr; V792 windowed job 253 rendered tile grain + water band. | `shadow_map` unbound → neutral sample; eye planes/texture matrix are engine-bound and unreadable (V786 §6, V792 §6 Q2). Array transport supplies no `sampler2D` (V792 §6 Q5). | **NO PARSE/LINK ERROR. Visual correctness UNVERIFIED** (no donor A/B). |
| V5 | **`invalidate()` frees ALL terrain children** (`world3d_terrain.gd:531-534`), including the V7-84 water node; only one water plane is ever created (`:677-681`). | Probe 251 `single_water_plane` PASS. No double-surface error. | **LOW.** External children attached to the terrain module would be destroyed on rebuild. |
| V6 | **Tile-index decode / clamp.** `_decode_tile_indices()` resizes to exactly `w*h` from dump or live `game.tileblock` and clamps out-of-atlas ids (`BLK_WATER=255` → 0) before writing `UV2.x` (`world3d_terrain.gd:392-429,623-631`). | No OOB in current source; measured 102,400 cells / 0 UV2 mismatches (V792 job 251). | **PROVABLY SAFE in source**, not re-run windowed. |

---

## 4. Provably gone vs UNVERIFIED until a windowed play session

**Provably gone (source + later green job):**
- all E1 parse cascades; E2 HUD typed-param rejection; E3 `int(Dictionary)`;
  E4 `dbg_res`/`dbg_bld`/`dbg_unit`/`dbg_fx`; E9 `render_priority`;
  E10 mapgen/import failures; E11 loader/shader parse+type failures;
  E12 missing anim3d methods; E13 entity-module type contracts;
  E14 shader compile failures; E15/E16 probe-only watchdogs and duplicate input
  parsing. Latest full variant selftest (job 254) and uitest (job 255) have no
  `SCRIPT ERROR` line; only E18 warning + E19 exit leaks.

**UNVERIFIED until a real windowed session (even though source looks correct):**
1. **Minimap black-screen fix in live play** (E6): 11/11 headless probe +
   numeric before/after only; the user's retest is explicitly still pending
   (`AUDIT3D_TRIAGE.md:56-58`, V781 §4 Q4).
2. **Windowed audio branch** (E5): fix proven by stub-Camera3D probe;
   headless selftest skips audio via `main.gd:1127-1129`, so a normal windowed
   run is the only proof.
3. **V7-70 seam under zoom changes** (H1): probe froze zoom; journey/startup
   writes `_target` externally and a wheel zoom on the next frame may break the
   signature guard.
4. **Atlas fallback in a real GPU window** (V1): split fallback proved headless;
   array→splat degradation never driven through a windowed terrain build.
5. **Menu-triggered paths** (H2/H3): F9 load, quality change, fog toggle and
   patrol/guard overlay are not covered by selftest/uitest assertions; they are
   stubbed, not visually validated in 3D.
6. **Exit leaks** (E19) remain present; not a crash but stderr is not clean.

---

## 5. What to test in the window next (checklist)

1. **Baseline stderr:** start a normal 320×320 windowed game, play 3-5 minutes,
   keep stderr. Expected only: flat-root morph warning once + exit leaks. Any
   `dbg_res`, `Nonexistent 'int'`, `Vector3→Vector2`, `hud.bind`, or
   `Cannot call method … on null` is a regression.
2. **Minimap LMB:** click centre, then all four corners, then drag. Camera must
   stay over the centred terrain; compare with V781's measured centre
   `(0.0, 34.06, 54.51)` view-centre ≈ `(0, -4.76)` and corner `≈(-297,-300)`.
   Any black frame = E6 regression.
3. **Seam + zoom:** immediately after startup and after a journey-mode focus,
   wheel-zoom once, then click minimap. Watch for a camera snap off-terrain —
   this is the H1 signature-guard failure mode the probe did not exercise.
4. **PERF line:** run past 120 frames so `main.gd:1592` prints
   `r/b/u/f=…`; confirm four non-negative integers and no property error.
5. **Audio-active paths:** let mill/town ambience play and fire positional
   events; confirm no Vector3→Vector2 error and that distance culling applies
   (volume falls off beyond 60 m — V771).
6. **Menu interactions:** F5 save → F9 load; Options → quality high/medium/low;
   Fog-of-war toggle; Quit-to-menu → restart. Expect no `Invalid access` on
   `world`; note that fog toggle is a visual no-op in 3D (H2).
7. **Input extras in 3D:** M/G patrol/guard routes, build ghost, minimap RMB
   orders, middle-drag, edge scroll, arrow keys. Expect no exception; expect
   the route line itself to be invisible (H3) but orders to work.
8. **Atlas fallback simulation:** hide/rename the 180 MB single atlas (or set
   `terrain/tile_atlas_mode`), launch windowed, verify split reassembly renders
   without shader errors; then force array mode and confirm graceful splat
   fallback rather than a black terrain.
9. **V7-92 stats:** dump terrain stats and check `atlas_mode`, `atlas_grid`,
   `uv_model`, `tile_index_hist`, `material_model`, `water.height_aware=true`,
   and exactly one `WaterPlane` in the node tree.

---

## 6. Top 5 remaining runtime risks (ranked)

1. **V7-70/V7-81 seam is signature-based** (`main.gd:1008-1016` ↔
   `camera3d.gd:233-237`): a zoom change between the foreign `_target` write and
   the next `_apply_transform()` can double-subtract the half-map offset →
   off-terrain camera / black view. Not covered by the 11/11 constant-zoom probe.
2. **Minimap black-screen fix has no user windowed retest** (V781 Q4,
   `AUDIT3D_TRIAGE.md:56-58`) — headless numbers are good, live play is not.
3. **Windowed audio branch** (`audio.gd:157-161`, V771 Q4) is proven only by a
   stub-Camera3D probe; headless selftest skips audio entirely.
4. **V7-92 atlas fallback / single-PNG dependency**: 180 MB PNG is required for
   the default path; split fallback is headless-only, and array→splat
   degradation (no `sampler2D`) is unmeasured in a GPU window; 655k-pixel mask
   repack + 512 MB texture upload is a startup hitch candidate.
5. **Unbranched shared-menu paths are stubs, not parity**: `game_load`, quality
   change and Fog toggle (`main.gd:1394-1401,1485-1512`) rely on honest
   no-ops/`Node3D` visibility proxy in `world3d.gd:525-530,654-732`; patrol/guard
   route overlay is a `Node2D` in a `Node3D` tree (`input_controller.gd:52-97`)
   and will not render in 3D.

---

*End of report. COMP-04 wrote only this file; all analysis scripts lived under
`C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/`. No Godot job was launched,
no source/asset/config/test was edited, no git command was run. No donor visual
parity is claimed.*
