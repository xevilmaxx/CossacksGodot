---
id: VID-CAP-01
title: "Moving-unit frame sequence on the 64x64 3D map — capture only"
owner: VID-CAP-01 (capture tooling micro-worker)
date: 2026-11-25
status: CAPTURE_OK__16_FRAMES__CONTACT_SHEET_AND_MP4_BUILT__0_SCRIPT_ERROR__NO_ANALYSIS
scope: "ONE new atom + ONE new report. No game code, config, manifest, fixture, shader, gate file, donor copy or git edit. No full gates / ladder."
owns:
  - "variant3d/tests/t_motion_capture.gd"
  - "docs/coord_swarm_2026-11-25/reports/VID_CAP_01_capture.md"
labels: [FRAME_SEQUENCE, WINDOWED_GPU_CAPTURE, 64x64_FIXTURE, FIXED_CAMERA, DETERMINISTIC_SIM, CAPTURE_ONLY]
visual_parity_claim: false
analysis_status: "NOT PERFORMED — VID-AN-01 (muse-spark 1.3 contributor) is a separate ticket"
runner: "variant3d/tools/godot_runner.py ONLY. FINAL job id 'vidcap01-frames', ticket 408, status ok, exit 0. Failed/transient tickets 380, 383, 386, 388, 391, 394, 401 retained for transparency."
---

# VID-CAP-01 — unit-motion frame sequence (capture only)

## 0. Scope and honesty guard

This ticket **captures** a reproducible frame sequence and assembles a contact
sheet + MP4. It does **not** analyse motion: no pose-pop, foot-slide, direction
flip or donor-parity verdict is made here. The analysis is reserved for
`VID-AN-01` (muse-spark 1.3 contributor, default variant) per
`VIDEO_QA_PROTOCOL.md:11-15,40-46`. Donor footage is external-only
(`VIDEO_QA_PROTOCOL.md:48-52`); nothing donor-derived was downloaded or copied.

Only the two owned files were created. No existing file was edited.

## 1. Sources

| Source | Used for |
|---|---|
| `docs/coord_swarm_2026-11-25/VIDEO_QA_PROTOCOL.md:11-15,23-28,30-37,45-52,55-56` | owner directive, capture rules (fixed camera/seed/64²/interval, sidecar JSON, Pillow + ffmpeg assembly), analysis split, queue |
| `docs/coord_swarm_2026-11-25/reports/TEST_01_smallmap_harness.md:62-66,99-109,142-173,247-255` | one-atom-per-file rule, real-boot 64² pattern, 64² recommendation, windowed SubViewport precedent |
| `docs/coord_swarm_2026-11-24/reports/TERRAIN_SMALL_maps.md:31-41,57-66,94-97,130-148` | fixture overlay semantics, runner invocation form, stderr scan tool, measured 64² GPU capture |
| `docs/coord_swarm_2026-11-24/reports/V770_viewport_capture.md:29-35,180-199` | measured `Screenshot3DViewport` path; blank 3D capture must fail loudly |
| `variant3d/tests/t_smallmap_terrain.gd:9-16,174-224` and `variant3d/tests/t_select_rect.gd:261-283,286-337` | real `main.tscn` + `--config` + `--screenshot` menu-skip; boot-on-first-framewait; clear/spawn/freeze pattern |
| `variant3d/scripts/main.gd:1180-1193,1527-1567,1609-1612,1670-1672,1804-1870` | SubViewport setup, sim stepping, saver disarm, screenshot readback |
| `variant3d/scripts/game.gd:1988-2038,2839-2851,3283-3310,3887-3919,5464-5497` | spawn/officer arrays, `cmd_move`, squad propagation, `tick`, victory no-op trap |
| `variant3d/scripts/camera3d.gd:144-152,189-205,423-430,626-634` | SIM `_target` contract, zoom/height, `jump_to_world`, `set_zoom_target(immediate)` |
| `variant3d/scripts/world3d.gd:682-701`, `world3d_entities.gd:900-905,1206-1241,1454-1547`, `anim3d.gd:98-105,489-530` | `world.sync`, unit yaw from `face`, donor-timed pose, pose provenance labels |
| `variant3d/scripts/data.gd:23,32,648-656`, `variant3d/tests/fixtures/small_map_64.json:10-15` | `TILE_M`, `FPS=32`, officer stats, 64² fixture keys |
| `variant3d/tools/godot_runner.py:46-57,115-129,305-343,349-437` | FIFO ticket lock, hard timeout, result directories |
| `variant3d/tools/smallmap_capture.py:50-58` | external `SCRIPT ERROR` scan (no GDScript stderr API) |

`reports/DANIM_01_action_ranges.md` was **not present** when this ticket ran;
no donor action-range claim is made.

## 2. Atom design (`variant3d/tests/t_motion_capture.gd`)

**Boot choice: real `main.tscn`, not a stub.** Reasons: (1) the windowed GPU
readback is already measured end-to-end through main's `Screenshot3DViewport`
(`main.gd:1180-1193`, `1804-1870`; V7-70 ticket 179; TERRAIN-SMALL ticket 308);
(2) a stub would have to duplicate that seam *and* re-derive the SIM→centred
camera convention that is a known capture trap (`camera3d.gd:245-256`,
`:423-430`; `V770_viewport_capture.md:26-28`); (3) the real boot supplies the
real sim, entity/anim sync and camera, so every sidecar field is measured rather
than reconstructed. Cost is acceptable (~25 s boot inside a 360 s runner job).

Atom behaviour (all `path:line` refer to the new file):

- `extends SceneTree`, deferred `call_deferred("quit", 0/1)` in `_finish()`
  (`:165-199`); no bare `quit()` from `_initialize()`.
- Reads `--config` / `--screenshot` from user args (`:84-90`), validates the
  64²/3d/seed-20261113 fixture (`:510-530`), then instantiates
  `res://scenes/main.tscn` and waits real `frame_post_draw` ticks until `game`
  and `capture_view3d` exist (`:532-554`) — because a custom SceneTree main loop
  delivers the child scene's `_ready()` only once the loop starts
  (`t_smallmap_terrain.gd:220-223`).
- **Sim freeze:** clears `ais`, sets `speed=0`, `acc=0`, disarms main's own
  screenshot saver (`:299-317`). `main.gd:1543` then returns before any tick,
  sync, camera retarget or main-side quit. The atom drives the sim itself: 12
  fixed `1/32 s` ticks per captured frame (`:384-393`; `data.gd:32`,
  `main.gd:1557`). `winner`/`paused` are cleared before each tick because the
  cleared AI player would otherwise let `_check_victory()` set `winner` and make
  `tick()` a no-op (`game.gd:3888`, `5464-5497`).
- **Four units, one order:** clears generator entities (`:202-223`), spawns 4
  player-0 `officer` units at SIM `(61,62) (67,62) (61,66) (67,66)`, forms one
  squad, and issues **one** `cmd_move(officer, (78,69))` which propagates to all
  members (`:319-370`; `game.gd:3197-3240,3283-3310,2839-2851`). A recorded
  fallback (4 direct calls) exists if `squad_form()` is empty; it was **not**
  used in the final run (`move_calls=1`, `squad_id=1`).
- **Fixed camera:** `jump_to_world(centre)` + `set_zoom_target(max_zoom, true)`
  then `camera.set_process(false)` so camera3d's own edge/clamp smoothing cannot
  drift the pose (`:372-381`; the first successful run, ticket 401, *did* drift
  and was superseded). Measured camera pose is byte-identical in all 16 frames.
- **Capture:** every `FRAME_INTERVAL=3` rendered frames, set
  `UPDATE_ONCE`, `await RenderingServer.frame_post_draw`, read
  `Screenshot3DViewport.get_texture().get_image()`, save
  `frame_%03d.png` (`:395-447`). A flat read is retried up to 4 times with a
  fresh `UPDATE_ONCE`; a genuinely blank frame still fails loudly — no CPU
  fallback (`:399-420`; `main.gd:1846-1853`). Final run had **0** retries.
- **Sidecar:** `frames.json` records per frame: SIM time, anim clock, each
  unit's SIM position / `face` (rad + deg) / `moving` / order / real
  `anim3d.pose_for()` action+frame+donor+pose_source, camera target/position/
  zoom/height/viewport/current flag, PNG path, byte size, rendered-frame index,
  image signature and blank flag (`:226-270,424-447,467-485`).
- **Headless guard:** writes `SKIP_CAPTURE` marker + result JSON with
  `status=SKIP_CAPTURE`, `passed=false`, exits without claiming PASS
  (`:149-157`). Exercised by ticket 383 (below); the final run was windowed.
- Result JSON at `res://tests/results/t_motion_capture.json`, `CAPTURE_OK` /
  `CAPTURE_FAILED` / `SKIP_CAPTURE`, deferred quit (`:165-199`).

## 3. Runner execution (exact jobs)

All launches used `python variant3d\tools\godot_runner.py run ...` only. No
direct `godot`, no concurrency bypass, no full gate. Windows `python`.

| Ticket | Job id | Result | Note |
|---:|---|---|---|
| 377 | `vidcap01-parse` | ok | `--check-only` parse of the atom; stdout/stderr clean |
| 380, 386 | `vidcap01-frames` | failed | Windowed `--script` with an **absolute `--config` path containing spaces** (`.../Craft Anything/...`): exit 1 after ~7 s, stdout contained **only** the Godot banner (no OpenGL line), stderr empty. The atom never ran. Fixed by passing `--config res://tests/fixtures/small_map_64.json` (resolves to the same fixture; `_resolve_config` at `:93-101`). |
| 383 | `vidcap01-headlessguard` | failed (by design) | Headless guard fired: `VIDCAP01 FAIL headless_guard`, result `status=SKIP_CAPTURE`, `passed=false`; `SKIP_CAPTURE.txt` written in the temp dir. Exit 1 — no PASS claimed. |
| 388 | `vidcap01-win-diag` | failed | Control diagnostic: windowed **main-scene** `--screenshot` boot did initialise OpenGL 3.3 and read `Screenshot3DViewport`; exit 1 from pre-existing project state, not used as capture evidence. |
| 391 | `vidcap01-win-argdiag2` | failed | Atom ran; boot/viewport passed but `spawn("officer")` threw `Out of bounds get index '0'` (`game.gd:2034`) because `officers` had been flattened with `clear()`; fixed by restoring `[[],[]]` slots (`:219-223`). |
| 394 | `vidcap01-frames` | failed | 6 frames saved; `game.tick()` became a no-op after victory detection; one flat read at frame 6. Fixed by clearing `winner` per tick and adding readback retries. |
| 401 | `vidcap01-frames` | ok | 16 frames, `CAPTURE_OK 10/10`, but camera `_target` drifted `(63.31,63.31) → (51.83,51.83)`; superseded. |
| **408** | **`vidcap01-frames`** | **ok** | **FINAL.** Wait 149.01 s, run 62.39 s, exit 0. `render_mode=3d`, `64×64`, seed `20261113`, `Screenshot3DViewport` `1280×720`, `camera_current=true`, `CAPTURE_OK PASS 10/10`. |

Final command (ticket 408):

```
python variant3d\tools\godot_runner.py run --id vidcap01-frames --timeout 360 -- ^
  --path variant3d --script res://tests/t_motion_capture.gd -- ^
  --config res://tests/fixtures/small_map_64.json ^
  --screenshot C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/vidqa/unused_flag.png ^
  --timeout 280
```

Result records: `variant3d/.godot_queue/results/00000408.json`,
`.../00000408_vidcap01-frames/stdout.txt`, `.../stderr.txt`.
Atom result: `variant3d/tests/results/t_motion_capture.json`
(`status=CAPTURE_OK`, `passes=10`, `total=10`, `frame_count=16`).

`SCRIPT ERROR` scan — `python variant3d/tools/smallmap_capture.py scan-stderr
variant3d\.godot_queue\results\00000408_vidcap01-frames\stderr.txt` →
**`script_error_lines: 0`**. (Earlier tickets showed concurrent-work errors in
`world3d_fx.gd` / `ParticleProcessMaterial`; none are in the final job, and none
were fixed by this ticket. Exit-time RID-leak ERROR lines are pre-existing and
are not `SCRIPT ERROR`s.)

## 4. Artifacts (all outside the repo)

Directory: `C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/vidqa/`

| Artifact | Bytes | Notes |
|---|---:|---|
| `frame_000.png` … `frame_015.png` | 1,514,790 … 1,517,976 (sum **24,275,759**) | 16 raw 1280×720 GPU PNGs, one per captured frame |
| `frames.json` | **48,780** | per-frame SIM / pose / camera / image sidecar |
| `contact_sheet.png` | **426,980** | Pillow 4×4 grid, 320×180 tiles, 1280×720 total, frame labels |
| `motion.mp4` | **431,953** | ffmpeg 9.0.1, `-framerate 4 -i frame_%03d.png -c:v libx264 -pix_fmt yuv420p`; 16 frames, 4 s, H.264 high 4:2:0 1280×720 |
| `unused_flag.png` | — | menu-skip flag only; the atom never writes it |
| `SKIP_CAPTURE.txt` | 82 | from ticket 383 headless-guard diagnostic; **not** a captured frame |
| `win_diag.png.raw.png` | 1,766,790 | from ticket 388 control diagnostic; **not** part of the final sequence |

No frames, JSON, sheet or video was written into the repo.

## 5. Per-frame metadata summary (final run, ticket 408)

- Fixture: `res://tests/fixtures/small_map_64.json`, seed `20261113`, `3d`, 64².
- SIM step `1/32 s`, 12 ticks per capture = **0.375 sim-seconds** per captured
  frame; captured SIM times: `0.500, 0.875, 1.250, …, 6.125 s` (16 frames).
- Rendered-frame indices: `3, 6, 9, …, 48` — exactly every 3 rendered frames;
  `blank_read_retries = 0`.
- Units: ids `10, 11, 12, 13`, all `officer`, player `0`; initial SIM
  `(61,62) (67,62) (61,66) (67,66)`; one `cmd_move` to SIM `(78,69)`, squad 1.
- Camera (identical in **all** 16 frames): `target_sim_m=(64,64)`,
  `position_world_m=(0,20,32.00669)`, `height_m=20`, `zoom=2.9`,
  `viewport=Screenshot3DViewport`, `camera_current=true`,
  `camera_process_enabled=false`.
- Pose provenance: every sampled pose has `pose_source=donor_flat_root_morph`
  and `visual=UNVERIFIED` (port label, not donor parity); `action` values seen:
  `walk` and `idle`. Unit-10 donor pose frames across the 16 captures:
  `15, 1, 15, 1, 15, 24, 10, 24, 10, 19, 10, 19, 6, 19, 6, 15`.
- Image check: 0 blank frames, **16 distinct** image signatures, mean luma
  `0.144–0.180`.

Selected unit-10 rows (full data in `frames.json`):

| Frame | SIM time (s) | Unit-10 SIM pos (m) | azimuth (deg) | pose frame |
|---:|---:|---|---:|---:|
| 0 | 0.500 | (61.176, 61.587) | −74.9 | 15 |
| 1 | 0.875 | (61.579, 61.431) | −16.9 | 1 |
| 3 | 1.625 | (62.363, 61.033) | −34.6 | 1 |
| 5 | 2.375 | (62.835, 61.620) | 56.0 | 24 |
| 7 | 3.125 | (63.645, 61.701) | −48.2 | 24 |
| 8 | 3.500 | (63.767, 61.577) | 117.7 | 10 |
| 12 | 5.000 | (63.765, 61.576) | 117.7 | 6 |
| 15 | 6.125 | (63.764, 61.575) | 117.7 | 15 |

## 6. What the sequence shows — factual observations only

1. Sixteen non-blank, distinct, GPU-rendered 3D PNGs were produced from the
   dedicated `Screenshot3DViewport` at 1280×720; stdout confirms
   `camera_current=true` and `world_parent=Screenshot3DViewport` (the latter
   from the control diagnostic, same code path).
2. The camera pose is byte-identical across all 16 frames, so frame-to-frame
   pixel changes are not attributable to camera motion.
3. SIM time increases by exactly 0.375 s per captured frame, confirming the
   atom-side fixed-step clock actually advanced (the ticket-401 no-op trap was
   removed).
4. Unit 10's SIM position changes on frames 0–8 (net ≈ +2.59 m X, −0.01 m Y),
   with measurable per-frame deltas (e.g. ≈ +0.40 m between frames 0 and 1).
   From frame 8 to frame 15 its SIM position is effectively static
   (|Δ| < 0.005 m total) while `order` is still `move` and the destination
   `(78,69)` has not been reached.
5. Unit 10's `face`/azimuth changes on frames 0–8 (range −74.9° … 117.7°) and
   is constant at 117.7° on frames 8–15. Its donor pose frame keeps changing
   throughout, including while SIM position is static.
6. Only **one** of the four units reports `moving=true` in any sampled frame;
   the other three retain the `move` order but are not flagged as moving.
7. All pose payloads carry the port's `donor_flat_root_morph` /
   `visual=UNVERIFIED` provenance.

No claim is made about animation smoothness, pose popping, foot sliding,
direction-flip correctness, donor AABB/ACL parity, or "look and feel". Those
are `VID-AN-01` questions.

## 7. Open questions (handed to analysis, not answered here)

1. Why does unit 10 stop changing SIM position after frame 8 while its order is
   still `move` and the destination is ~14 m away? Pathing/blocker/formation
   target? (`game.gd:_tick_unit`, nav grid).
2. Why is only one of the four squad members flagged `moving`, despite one
   `cmd_move` propagating `move` orders to all four (`game.gd:3283-3310`)?
3. Are the changing donor pose frames while SIM position is static an `idle`
   swap, a walk-cycle continuation, or a pose-pop? Requires visual review.
4. Visual parity to the donor remains **UNVERIFIED**; `DANIM_01` had not landed
   and no approved donor frame/video was supplied (`VIDEO_QA_PROTOCOL.md:48-52`).
5. Windowed `--script` with an absolute `--config` path containing spaces
   aborted before display init with no diagnostic; using the `res://` form is a
   workaround, not an explained root cause.
6. Pre-existing concurrent-work `SCRIPT ERROR`s appeared in earlier tickets but
   the final job scanned 0; no source was changed here to cause that.
7. The 4 fps MP4 playback rate is a presentation choice (sim interval is
   0.375 s ≈ 2.67 captured fps); it does not imply donor timing parity.

## 8. Summary

- **Delivered:** one new `extends SceneTree` atom and one report; real 64² boot,
  four friendly officers, one move order, frozen/deterministic sim, fixed
  camera, 16 frames every 3 rendered frames, sidecar `frames.json`, result JSON,
  Pillow contact sheet and ffmpeg MP4 — all outside the repo.
- **Measured:** runner job `vidcap01-frames`, final ticket **408**, `ok`, exit 0,
  62.39 s run; atom `CAPTURE_OK 10/10`; 16/16 non-blank distinct frames; 0
  `SCRIPT ERROR` lines; camera pose identical in every frame.
- **Not delivered:** any motion or donor-parity verdict. This is capture only;
  analysis is a separate muse-spark ticket (`VID-AN-01`).
