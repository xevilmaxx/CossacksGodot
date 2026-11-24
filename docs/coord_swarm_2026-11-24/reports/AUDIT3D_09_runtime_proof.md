---
id: AUDIT3D-09
owner: AUDIT3D-09 (runtime proof subagent)
scope: "Actual headless/windowed runtime evidence that variant3d/ boots and builds a real 3D node tree; screenshot/render artifact hunt; result-dir error triage"
date: 2026-11-24
status: DELIVERED — runtime node tree MEASURED; 3D viewport visual parity UNVERIFIED (viewport capture blank, CPU-map fallback)
---

# AUDIT3D-09 — runtime proof (headless 3D boot / skirmish smoke / render evidence)

## 1. Scope and method

- Charter: `docs/coord_swarm_2026-11-24/AUDIT3D_CHARTER.md:1-35`. AUDIT ONLY: no source edits except one temporary probe (`variant3d/tests/t_audit3d_runtime_tmp.gd`), deleted before this report was written (`Test-Path` = `False` after `Remove-Item`). No git commands. Exactly one report file written.
- Every Godot launch went through variant3d's own runner: `python variant3d\tools\godot_runner.py run --id <id> --timeout <s> -- <godot args>` (`variant3d/tools/godot_runner.py:349-437,571-576`). No direct `godot` invocation. The runner allocates a FIFO ticket, serialises with `godot.lock`, hard-kills the process tree at `--timeout`, and writes `stdout.txt`/`stderr.txt` to `variant3d/.godot_queue/results/<ticket>_<id>/` (`godot_runner.py:46-54,357-374,395-433`).
- Configuration under test: `variant3d/config.json:38` `"render_mode": "3d"`; consumed at `variant3d/scripts/main.gd:176-177` and branched at `main.gd:573-590` (async load) and `main.gd:1003-1010` (synchronous selftest/screenshot/battle path). Engine `Godot Engine v4.7.2.stable.official.ed1daf0bf`; renderer `gl_compatibility` (`variant3d/project.godot:25-26`).
- All stdout/stderr quoted below was read from the runner's result directories, not from a local console. OBSERVATION and INFERENCE are separated; anything not measured is labelled UNVERIFIED.

## 2. Evidence table (all jobs measured)

| Ticket / job id | Exact command (run from repo root) | Wait / run / exit | Measured result |
|---|---|---|---|
| 72 `audit3d-smoke-quit10` | `python variant3d\tools\godot_runner.py run --id audit3d-smoke-quit10 --timeout 60 -- --headless --path variant3d --quit-after 10` | 90.74 s / 18.20 s / 0 (`ok`) | stdout = engine banner only; **stderr empty**. Engine boots and exits cleanly after 10 frames. No `world3d_entities` warning in stderr → this particular smoke stayed in menu and did **not** exercise 3D world construction (OBSERVATION). |
| 69 `v-launcher-config3d-selftest` (historical, not mine) | `... run --id v-launcher-config3d-selftest --timeout 300 -- --headless --path variant3d -- --self-test variant3d/selftest.json` | 0.00 s / 123.20 s / 1 (`failed`) | **Known failure confirmed.** `stderr.txt:8-12`: `SCRIPT ERROR: Invalid type in function 'bind' in base 'CanvasLayer (C3HUD)'... argument 2 (Node3D (world3d.gd)) is not a subclass of the expected argument class.` at `main.gd:1043`, then `watchdog: wall-clock limit reached, forced exit` (`stderr.txt:13`). Cause: `hud.bind(g: C3Game, w: C3World)` (former `hud.gd:162`) rejected the `world3d.gd` `Node3D`. |
| current `hud.gd` (fix landed during audit) | source read, no job | — | `variant3d/scripts/hud.gd:9-14` now documents the relaxation; `hud.gd:14` is `var world` (untyped), `hud.gd:167` is `func bind(g: C3Game, w) -> void:`. The P0 type error above is **resolved in the tree as measured now**. |
| 76 `audit3d-selftest-3d-current` | `python variant3d\tools\godot_runner.py run --id audit3d-selftest-3d-current --timeout 300 -- --headless --path variant3d -- --self-test variant3d/selftest.json --timeout 180` | 85.45 s / 95.71 s / 0 (`ok`) | `variant3d/selftest.json` rewritten with `"passed": true`. Backtrace in `stderr.txt` proves the **real 3D world is constructed in gameplay**: `bind (world3d_entities.gd:144)` → `bind (world3d.gd:240)` → `_setup_full_game (main.gd:1005)` → `_ready (main.gd:226)`. Also 5 captured `SCRIPT ERROR: Invalid call. Nonexistent 'int' constructor.` at `world3d.gd:207` (see gap G2). |
| 75 `audit3d-node-tree-probe` | `python variant3d\tools\godot_runner.py run --id audit3d-node-tree-probe --timeout 120 -- --headless --path variant3d --script res://tests/t_audit3d_runtime_tmp.gd` (temp probe, since deleted) | 140.17 s / 4.41 s / 0 (`ok`) | `AUDIT3D_RUNTIME` line: `world_is_Node3D=true`, `camera_is_Camera3D=true`, `view_scale=16.0`, `class_counts={"Camera3D":1,"DirectionalLight3D":1,"MeshInstance3D":4,"Node":1,"Node3D":8,"Window":1,"WorldEnvironment":1}`, `mesh_count=4`. Full node tree in §3. |
| 73 `audit3d-shot-windowed` (short watchdog) | `python variant3d\tools\godot_runner.py run --id audit3d-shot-windowed --timeout 150 -- --path variant3d -- --screenshot variant3d/shots/audit3d_09_windowed.png --screenshot-frames 10 --timeout 60` | 0.00 s / 75.35 s / 1 (`failed`) | stdout proves a **real GPU context**: `OpenGL API 3.3.0 NVIDIA 571.96 - Compatibility - Using Device: NVIDIA - NVIDIA GeForce MX130`. In-game 60 s watchdog fired before frame 10 (`stderr.txt`: `watchdog: wall-clock limit reached, forced exit`) → no image produced. |
| 74 `audit3d-shot-headless` | `python variant3d\tools\godot_runner.py run --id audit3d-shot-headless --timeout 180 -- --headless --path variant3d -- --screenshot variant3d/shots/audit3d_09_headless.png --screenshot-frames 10 --timeout 60` | 75.38 s / 64.77 s / 0 (`ok`) | `screenshot saved (headless map render): C:/Users/.../audit3d_09_headless.png` — CPU map image, not a 3D render (§4). |
| 77 `audit3d-shot-windowed-long` | `python variant3d\tools\godot_runner.py run --id audit3d-shot-windowed-long --timeout 360 -- --path variant3d -- --screenshot variant3d/shots/audit3d_09_windowed.png --screenshot-frames 10 --timeout 300` | 124.89 s / 39.68 s / 0 (`ok`) | stdout: `screenshot saved (fallback map render): C:/Users/.../audit3d_09_windowed.png`. **The real viewport texture was judged blank** (`main.gd:1749-1752`) and replaced by the CPU map image. Same 0× GPU 3D pixels in artifact. stderr also: `SCRIPT ERROR: Trying to assign value of type 'Vector3' to a variable of type 'Vector2'. at C3Audio._process (audio.gd:153)` (gap G3). |
| 78 `audit3d-shot-headless-long` | `python variant3d\tools\godot_runner.py run --id audit3d-shot-headless-long --timeout 240 -- --headless --path variant3d -- --screenshot variant3d/shots/audit3d_09_headless.png --screenshot-frames 10 --timeout 180` | 164.59 s / 48.82 s / 0 (`ok`) | Same `headless map render` result and same artifact path as 74 (file overwritten, 45,425 bytes). |

## 3. Node-tree proof (ticket 75, measured)

Probe instantiated the real `res://scripts/world3d.gd` and `res://scripts/camera3d.gd`, bound a stub game with a 16×16 `height[]`, added both to the `SceneTree` root, called `world.bind(game)`, `world.sync(0.016)`, `camera.bind(game, view_scale)`, then walked the tree.

Verbatim `AUDIT3D_RUNTIME` (stdout of result dir `00000075_audit3d-node-tree-probe`):

```
{"camera3d_count":1,"camera_is_Camera3D":true,"camera_script_loads":true,
 "class_counts":{"Camera3D":1,"DirectionalLight3D":1,"MeshInstance3D":4,"Node":1,
                 "Node3D":8,"Window":1,"WorldEnvironment":1},
 "engine":"4.7.2-stable (official)","mesh_count":4,"multimesh_count":0,
 "node3d_count":8,"probe":"AUDIT3D-09","view_scale":16.0,
 "world_is_Node3D":true,"world_script_loads":true,
 "world_tree":["@Node3D@2 [Node3D]","  @Node3D@3 [Node3D]",
   "    HeightmapTerrain [MeshInstance3D]","    WaterPlane [MeshInstance3D]",
   "    WorldEnvironment [WorldEnvironment]","    DonorSun [DirectionalLight3D]",
   "  @Node3D@4 [Node3D]","  @Node3D@5 [Node3D]","    FX3D [Node3D]",
   "    BuildGhost3D [Node3D]","      Footprint [MeshInstance3D]",
   "    Rally3D [Node3D]","  @Node3D@6 [Node3D]","    FogOverlay [MeshInstance3D]",
   "  @Node@7 [Node]"]}
```

- OBSERVATION: a genuine `Node3D` world, 4 `MeshInstance3D` nodes (`HeightmapTerrain`, `WaterPlane`, `Footprint`, `FogOverlay`), 1 `DirectionalLight3D` (`DonorSun`), 1 `WorldEnvironment`, and 1 real `Camera3D` exist at runtime. `multimesh_count=0` here only because the stub supplied no entities; prior measured probe ticket 41 (`v714-runtime-final`) recorded `V714_CHILDREN {"MeshInstance3D":1,"MultiMeshInstance3D":5}` and `units=2, buildings=1, resources=3` with populated data.
- OBSERVATION (probe artifact, not a product bug): `camera3d.gd:152-153` emitted `get_global_transform`/`look_at` "Node not inside tree" errors because the probe called `bind()` during `SceneTree._initialize()` before tree notifications; production binds after `add_child` (`main.gd:1006-1010`), and the 76/77 runs showed no such errors.
- INFERENCE: the 3D scene graph is real and composable; whether it is *visible on screen* is a separate question — §4 shows the captured viewport was blank.

## 4. Screenshot / render artifact hunt — explicit UNVERIFIED result

- Supported hook exists: `--screenshot <file>` / `--screenshot-frames N` are parsed at `main.gd:1142-1148`; capture fires at `main.gd:1596-1598`; `_save_screenshot()` at `main.gd:1715-1755`.
- **Headless branch is not a 3D render**: `main.gd:1716-1725` always calls `_render_headless_image(800,600)`, described at `main.gd:1769-1771` as "No GPU, no window, no textures: pure Image fills". The saved PNG is a flat top-down 2D map with coloured dots/rects for terrain/units (`main.gd:1782-1838`). Inspected image confirms this (800×600 flat map, no perspective).
- **Windowed branch also produced no 3D pixels**: with a real OpenGL 3.3 context (ticket 73 stdout), ticket 77's viewport texture failed `_is_blank()` (`main.gd:1749`, implementation `main.gd:1757-1767`) and the harness overwrote it with `_render_headless_image()` (`main.gd:1750-1752`), printing `fallback map render`. Inspecting `audit3d_09_windowed.png` shows the identical flat map.
- Exact artifact paths (both outside the workspace because `variant3d/shots/` did not exist at capture time; `main.gd:1668-1695` `_candidate_paths`/`_pick_target` falls through to `user://`):
  - `C:/Users/Maxym.Oboyshev/AppData/Roaming/Godot/app_userdata/CossacksGodot - 3D Skirmish Variant/audit3d_09_headless.png` (tickets 74, 78; 45,425 bytes)
  - `C:/Users/Maxym.Oboyshev/AppData/Roaming/Godot/app_userdata/CossacksGodot - 3D Skirmish Variant/audit3d_09_windowed.png` (ticket 77)
  - Requested workspace path `variant3d/shots/audit3d_09_*.png` does **not** exist (`Test-Path` = False).
- VERDICT on task item 2: the project has a `--screenshot` hook, but **there is no supported way in the current harness to obtain a genuine 3D viewport image** — both headless and windowed paths end in the CPU map fallback. **UNVERIFIED visual parity.** This is not the same as "3D does not render": the node tree exists and a GPU context exists; the capture path fails. Root cause is an open question (§6).

## 5. Real error lines from result dirs (path:line evidence)

All from `variant3d/.godot_queue/results/.../stderr.txt` unless noted.

1. `00000069.../stderr.txt:8-12` — `Invalid type in function 'bind' ... argument 2 (Node3D (world3d.gd)) is not a subclass of the expected argument class` at `main.gd:1043`; followed by `watchdog: wall-clock limit reached` (`:13`). Historical; fixed in current tree (`hud.gd:14`, `hud.gd:167`).
2. `00000076.../stderr.txt` — 5× `SCRIPT ERROR: Invalid call. Nonexistent 'int' constructor. at: _sync_selection (res://scripts/world3d.gd:207)`, called from `sync (world3d.gd:282)` ← `_process (main.gd:1551)`. Measured during the passing 3D selftest. Source: `world3d.gd:207` `var k := int(id)` where `id` comes from `game.get_selected()` (`main.gd` contract), which returns **entity Dictionaries** (`game.gd:2585-2590`). 3D selection mirroring (`world3d.gd:203-209`) therefore stays empty. INFERENCE: HUD/minimap selection state in 3D is broken; the selftest does not catch it.
3. `00000077.../stderr.txt` — `SCRIPT ERROR: Trying to assign value of type 'Vector3' to a variable of type 'Vector2'. at: C3Audio._process (res://scripts/audio.gd:153)`. Source `audio.gd:150-153`: `var center := Vector2.ZERO` then `center = cam.global_position / 16.0`; with `camera3d.gd:38 extends Camera3D`, `global_position` is `Vector3`. Only observable in windowed mode (`can_play` guard at `main.gd:1077-1079`).
4. Repeated benign/port warnings: `world3d_entities: STATIC BIND POSE - PORT APPROXIMATION - NOT DONOR PARITY` at `world3d_entities.gd:144` (tickets 69, 74, 76, 77, 78, 75); exit-time `ObjectDB instances leaked` / `resources still in use` (74, 76, 77, 78); GLES3 texture leak + `RenderingServer::get_singleton() is null` on windowed exit (73, 77); `RendererDummy RID allocations leaked` in earlier parse probes (ticket 57 stdout:15-19).
5. Ticket 73 `stderr.txt`: watchdog before frame 10 when the in-game `--timeout` was 60 s; 320×320 synchronous setup needs ~75 s in this environment. Not a code defect, but a default that prevents a screenshot with the documented short timeout.

## 6. Ranked gaps

| # | Sev | Gap (OBSERVATION unless stated) | Evidence | Smallest donor-grounded fix (proposal only — not applied) |
|---|---|---|---|---|
| G1 | **P0** | No real 3D viewport pixels: windowed GPU screenshot is blank and silently replaced by CPU map; headless screenshot is CPU map by design. Visual parity cannot be accepted. | `main.gd:1739-1752`, `main.gd:1716-1725`, `main.gd:1769-1771`; tickets 74/77/78 stdout; inspected PNGs | Make the capture target explicit: assign the composed world's `World3D` to the capture viewport and keep `camera3d.gd:131 make_current()` authoritative; if the fallback is retained, label the artifact `CPU_MAP_NOT_3D` so it can never be mistaken for proof. Use donor camera literals already cited at `camera3d.gd:12-20` — no new art/values. |
| G2 | P1 | Per-frame runtime error breaks 3D selection mirroring; gate still green. | `world3d.gd:203-209`, `game.gd:2585-2590`; ticket 76 stderr | At `world3d.gd:207`, read the id from the entity Dictionary (`id.get("id")`, same key used by `by_id` at `game.gd:2023`) instead of `int(id)`. Donor/pre-existing data only. |
| G3 | P1 | Windowed (audio-active) mode throws a Vector3→Vector2 type error every ambient tick. | `audio.gd:150-153`, `camera3d.gd:38`; ticket 77 stderr | Use ground-plane components already in the camera: `Vector2(cam.global_position.x, cam.global_position.z) / 16.0` (16 px/m is the port value at `data.gd:113`, already cited). |
| G4 | P1 | Headless screenshot harness cannot serve as 3D visual evidence (CPU map render). | `main.gd:1716-1725`, `main.gd:1769-1838` | Document this in screenshot tooling; if a render proof is needed, run windowed with a working capture (G1). No donor data involved. |
| G5 | P2 | Default 60 s in-game watchdog kills the screenshot job before frame 10 at 320×320. | ticket 73 (`watchdog...` after 75.35 s); `main.gd:200-203`, `main.gd:1214-1217` | Pass `--timeout 300` for screenshot/selftest modes (as tickets 76/77 did) or raise the default for capture modes only. |
| G6 | P2 | Entities remain static bind pose ("NOT DONOR PARITY") in every 3D run. | `world3d_entities.gd:144`; `world3d.gd:41-43` | Complete the already-planned handoff to `anim3d.gd` (owner V7-18); no new art — donor `.oss` bone parents remain UNVERIFIED. |
| G7 | P2 | Cleanup leaks (ObjectDB/resources; GLES3 texture; RendererDummy RIDs) at exit. | tickets 73/74/76/77/78 stderr; ticket 57 stdout:15-19 | Lowest-risk: free the screenshot `Image`/`CompressedTexture2D` and audio players in `_quit()` (`main.gd:1259-1261`). Cosmetic, does not affect frame output. |
| G8 | P2 | Screenshot artifacts silently land in `user://` instead of the requested workspace path. | `_candidate_paths`/`_pick_target` at `main.gd:1668-1695`; `variant3d/shots/` absent | Create `variant3d/shots/` before capture, or capture to `res://shots/` explicitly; keep existing fallback as last resort. |

## 7. Open questions

1. Why was the windowed viewport texture blank despite `OpenGL API 3.3.0 ... NVIDIA`, `world3d.gd` node tree, and `camera3d.gd:131 make_current()`? UNVERIFIED: capture timing vs. World3D assignment vs. an opaque overlay. No source was edited to investigate.
2. Once capture is fixed, does the rendered perspective match the donor main view (camera FOV/yaw are already marked PORT ASSUMPTION at `camera3d.gd:32-37` and G31)? UNVERIFIED.
3. Is the `int(id)` error (G2) also breaking the in-game 3D HUD/minimap selection, or only the mirror dict? INFERENCE only; needs a targeted runtime assertion (the selftest has no render-mode/3D assertions — grep of `scripts/selftest.gd` found no `render_mode`/`world3d`/`Camera3D`/`MeshInstance` matches).
4. Is `audio.gd:153` (G3) firing in ordinary interactive play, or only in screenshot mode? Observed in ticket 77 only; headless runs skip audio (`main.gd:1077-1079`).
5. The `hud.gd` relaxation landed while this audit was running; was any other file changed by the fixing agent between tickets 69 and 76? Not checked (no git, per charter). All measurements above are from the tree as read at their timestamps.

## 8. Verdict

- Measured: headless engine boots cleanly (72); the full 3D skirmish selftest now passes with `render_mode=3d` (76); a real `Node3D`/`MeshInstance3D`/`Camera3D`/`DirectionalLight3D`/`WorldEnvironment` tree is created at runtime (75); a real OpenGL 3.3 GPU context exists in windowed mode (73).
- Not measured: **actual 3D pixels on screen**. Both screenshot paths end in the CPU map fallback, so visual parity remains UNVERIFIED.
- Top 3 gaps: **G1 (P0 blank/fallback viewport)**, **G2 (P1 `int(id)` selection error)**, **G3 (P1 windowed audio Vector3→Vector2 error)**.
