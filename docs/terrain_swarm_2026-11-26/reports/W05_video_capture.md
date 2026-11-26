---
id: W05-VIDEO-CAPTURE-2026-11-26
swarm: TERRAIN-SWARM-2026-11-26
wave: DONOR-TERRAIN VISUAL WAVE
title: "W05 — exact donor-backend motion-capture protocol, source audit and current blocker"
role: READ-ONLY PLANNING — one report only; no code, Godot, git, runner job or capture
owner_file: docs/terrain_swarm_2026-11-26/reports/W05_video_capture.md
status: PLANNED_ONLY__CURRENT_SEQ_FLAGS_INSUFFICIENT__CAPTURE_SEAM_REQUIRED__PARITY_UNVERIFIED
created: 2026-11-26
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_guard: "PORT APPROXIMATION / port-internal evidence only. No donor GPU A/B frame exists. No command below is a capture result, and nothing in this report certifies donor fidelity."
principle: "[O] literal source/read-only filesystem fact · [D] deterministic consequence · [I] protocol recommendation/heuristic · [U] unresolved. W05 executed ZERO runner subcommands and ZERO Godot processes."
governing_sources:
  - docs/terrain_swarm_2026-11-26/VISUAL_WAVE_CHARTER.md
  - docs/terrain_swarm_2026-11-26/reports/V42_gate_commands.md
  - docs/terrain_swarm_2026-11-26/reports/V06_gate_remediation.md
  - docs/terrain_swarm_2026-11-26/reports/A05_qa_harness.md
  - docs/terrain_swarm_2026-11-26/reports/X39_ab_feasibility.md
  - reference/videos.md
  - variant3d/scripts/main.gd
  - variant3d/scripts/testbridge.gd
  - variant3d/scripts/camera3d.gd
  - variant3d/scripts/world3d.gd
  - variant3d/tests/t_motion_capture.gd
  - variant3d/tools/video_build.py
  - variant3d/tools/seq_to_mp4.py
  - variant3d/tools/record_session.py
  - variant3d/tools/godot_runner.py
---

# W05 — donor-backend motion-capture protocol

## 0. Executive answer

1. **[O] The flags exist and reach the donor setup.** `--seq`, `--seq-step`, `--seq-seconds` and `--journey` are parsed in `variant3d/scripts/main.gd:1311-1345`. A non-empty `seq_dir` enables the watchdog and full-game setup (`main.gd:214-220,238-253`); in 3D that setup reads `features.terrain.backend`, accepts only `donor`, and calls `world.set_terrain_backend(...)` before `world.bind(game)` (`main.gd:185-191,1110-1115`).
2. **[O]/[D] They do not currently produce admissible donor 3D motion frames.** Windowed `--seq` reads the **root viewport** (`main.gd:2130-2143`), while the proven 3D readback path is the dedicated `Screenshot3DViewport` created only for `--screenshot` (`main.gd:1244-1262,1858-1939`). If the root read is empty or blank, `--seq` silently substitutes `_render_headless_image(800, 600)` (`main.gd:2141-2143`). Its index still says `mode="window"` (`main.gd:2147-2149`), so the index cannot distinguish GPU terrain from the CPU map.
3. **[O] `--journey` is not a recorder.** It enables AI for player 0 and moves the camera toward the mean position of player-0 non-peasant units, with zoom target `0.75` while fighting and `1.0` otherwise (`main.gd:733-746,1180-1182,1682-1717`). Combined with `--seq`, it still inherits the root-viewport/CPU-fallback defect.
4. **[O] `--screenshot` is the only current main-scene flag that reads the real 3D SubViewport, but it saves one frame and exits.** It is suitable for a preflight still, not a motion sequence (`main.gd:1739-1741,1858-1939`). Do not combine it with `--seq` as a workaround: sequence capture still reads the root, and the screenshot saver quits the process.
5. **[O] The Python video tools do not repair the aperture.** `record_session.py` and `video_build.py` both call test-bridge `shot`; `_do_shot()` reads the root viewport (`testbridge.gd:277-308`). `seq_to_mp4.py` only assembles `frame_%04d.png` files. None is a donor-aware camera-path recorder.
6. **[O] A proven sequence seam already exists as a template, not as this protocol.** `t_motion_capture.gd` captures `Screenshot3DViewport` with `UPDATE_ONCE` and no CPU fallback (`t_motion_capture.gd:390-432`), but it is hard-wired to 64², seed `20261113`, 16 frames, `frame_%03d.png`, a fixed camera, a different temp directory, entity clearing, and a result JSON inside the repo (`t_motion_capture.gd:34-46,202-224,258-271,300-381,434-436,487-505`). It cannot directly satisfy W05.
7. **[D] Current no-go:** an honest three-shot donor motion capture requires a small COORD-owned generalization of that proven SubViewport seam. Section 5 gives a fail-fast PowerShell packet that runs only after `variant3d/tests/t_terrain_motion_capture.gd` lands with the contract in §4. The guard intentionally stops on the current tree; claiming that today's `--seq` already yields donor 3D video would be invented capture.

**Bottom line:** configuration compatibility is **YES**; admissible donor visual motion with the existing `--seq` family is **NO**. Donor parity remains **UNVERIFIED**.

---

## 1. Source verification — three passes, no inherited flag prose

### 1.1 Pass record

| Pass | Instrument | Scope | Result |
|---|---|---|---|
| 1 | Full source read | `main.gd` header, `_ready`, `_setup_full_game`, parser, `_process`, screenshot and sequence functions | Located declarations, control flow and all capture branches |
| 2 | Independent targeted grep | `--seq`, `--journey`, `--screenshot`, `--timeout`, `--config`, `--seed`, `terrain_backend`, `seq_*` | Cross-checked every spelling, default and call site |
| 3 | Focused line-range reread | `main.gd:1264-1380,1596-1752,1858-1939,2113-2195`; `camera3d.gd:262-282,589-719`; `testbridge.gd:277-308`; tool argument blocks | Resolved the root-vs-SubViewport contradiction and camera capability limits |

The governing reports were used only as corroboration. Every existing flag below was read from source, not copied from V42/V06 prose.

### 1.2 Existing flag matrix

| Flag | Exact source behavior | Donor-backend consequence |
|---|---|---|
| `--seq <dir>` | Sets `seq_dir`; missing value defaults to `seq` (`main.gd:1311-1314`). Relative paths are made project-local by `_seq_ensure_dir()` (`main.gd:2113-2123`). Enables watchdog/full-game setup (`main.gd:214-220,238-253`). | Donor backend is selected in full-game 3D setup, but frame pixels come from the root viewport with CPU fallback. Use an **absolute temp path**; a relative path would put output inside `variant3d/`. |
| `--seq-seconds <n>` | `clampf(..., 1.0, 600.0)`, default `60.0` (`main.gd:1315-1318`; declaration `:90`). Capture ends when `game.time_s >= seq_seconds`, at `seq_max`, or on a winner (`main.gd:2145-2151`). | Sim-seconds, not wall-clock capture time. Slow rendering can make a short sim sequence take far longer than its nominal duration. |
| `--seq-step <s>` | `clampf(..., 0.25, 30.0)`, default `1.0` (`main.gd:1319-1322`; declaration `:91`). Next capture is scheduled from `game.time_s` (`main.gd:1750-1752`). | Maximum requested cadence is 4 sim-frames/s; actual wall-clock rate is render-bound. No camera path or ROI is specified by this flag. |
| `--journey` | Boolean; no value (`main.gd:1341-1342`). Includes player 0 in AI brains (`main.gd:733-746,1180-1182`). Camera retargets once per second (`main.gd:1682-1717`). | Works as a 3D camera/AI mode, but actual path is gameplay-dependent and it does not fix sequence readback. Not an exact, reproducible terrain pan. |
| `--screenshot <file.png>` | Sets `screenshot_path` (`main.gd:1271-1274`). In windowed 3D, creates `Screenshot3DViewport`, reparents world+camera, reads it after `frame_post_draw`, writes raw+final PNG, then quits (`main.gd:1244-1262,1739-1741,1858-1939`). | **Valid single donor GPU still** when windowed and non-blank. Not a sequence. |
| `--screenshot-frames <n>` | `maxi(10, int(...))`, default `120` (`main.gd:1275-1278`; declaration `:69`). | Can delay the one-shot saver while a custom atom initializes; does not turn `--screenshot` into multi-frame capture. |
| `--timeout <seconds>` | `maxf(1.0, float(...))`; missing value yields `0.0` (`main.gd:1343-1346`). Modes with capture/seq/journey use `limit_s` or default `120.0` as a hard wall-clock deadline (`main.gd:214-220`). | Must be set explicitly for 240² work. The runner timeout must be larger than this in-game watchdog. |
| `--config <file.json>` | Sets `config_path` (`main.gd:1347-1350`); loaded and applied before mode setup (`main.gd:180-191`). | The overlay must explicitly contain `gameplay.render_mode="3d"` and `features.terrain.backend="donor"`; do not rely on ambient config. |
| `--seed <int\|random>` | Integer sets `seed_arg`; `random` sets `seed_random` (`main.gd:1365-1372`). Applied after config load (`main.gd:192-195`). | Pin `20261113` in both overlay and CLI; verify the actual dump/capture sidecar, not just the requested value. |
| `--headless` | Godot engine argument, skipped by the game parser (`main.gd:1264-1265,1377-1379`); detected through `DisplayServer` (`main.gd:178`). | Headless screenshot/sequence is a CPU map image, never donor 3D GPU evidence (`main.gd:1858-1869,2134-2143`). |

### 1.3 Compatibility verdicts

| Proposed use | Verdict | Why |
|---|---|---|
| Windowed `--seq` + donor overlay | **NO for visual motion** | Root viewport read + silent 800×600 CPU fallback; no SubViewport selection |
| Headless `--seq` / `--cli` + donor overlay | **NO for visual motion** | CPU map timelapse by design |
| `--journey` + donor overlay | **Camera mode only** | No frame output by itself; actual path is AI/gameplay-dependent |
| `--journey --seq` + donor overlay | **NO for visual motion** | Same defective `--seq` capture branch |
| Windowed `--screenshot` + donor overlay | **YES, one still** | Proven `Screenshot3DViewport` path; exits after one image |
| Headless `--screenshot` + donor overlay | **NO for 3D** | 800×600 CPU map |
| `--test-api` + `record_session.py` / `video_build.py` | **NO for donor motion** | Test bridge reads root viewport; no camera-path/ROI contract |
| `t_motion_capture.gd` + donor overlay | **Template only** | Real SubViewport sequence, but fixed 64²/seed/camera/output contract and entity clearing |
| COORD-generalized SubViewport atom | **Required** | Only route that can meet exact path, seed, ROI, frame-count and out-of-repo requirements without pretending current flags work |

---

## 2. Capture-tool audit

| Tool | What it actually does | W05 decision |
|---|---|---|
| `variant3d/tools/video_build.py` | Real OS cursor drives menu → skirmish → house placement; `shot()` writes `frame_%04d.png` through test-bridge RPC; assembles at fixed 8 fps (`video_build.py:99-132,161-273`). Default output is `app/shots/build_house`; it deletes that directory first (`:104-110`). | **Do not use for terrain motion.** It is a UI/build recorder, not a donor camera-path recorder; root readback remains a trap. |
| `variant3d/tools/record_session.py` | Human plays; recorder polls `shot` + `state`, deletes output dir, defaults to 1200 frames / 0.7 s interval, assembles fixed 8 fps (`record_session.py:36-45,62-109`). Default output is inside `app/shots`. | **Do not use for this protocol.** No deterministic camera path, seed/ROI manifest or donor-backend validation; root readback. |
| `variant3d/tools/seq_to_mp4.py` | Sorts `frame_*.png`, writes `contact.png`, invokes ffmpeg with `frame_%04d.png`, libx264/yuv420p/CRF20 (`seq_to_mp4.py:37-79`). Flags: `--dir`, `--fps`, `--out`, `--contact-only` (`:38-43`). | **Use for assembly only**, after the capture atom emits contiguous `frame_0000.png…`. Check ffmpeg first and check the MP4 exists: missing ffmpeg returns 0 after keeping only the contact sheet (`:64-68`). |
| `variant3d/tests/t_motion_capture.gd` | Real main boot; `Screenshot3DViewport`; fixed-step sim; `UPDATE_ONCE`; blank retry; no CPU fallback; per-frame camera/pose metadata (`:274-487`). | **Reuse the seam, not the file as-is.** It hard-codes 64²/seed/16 frames/fixed camera, clears entities, writes `frame_%03d.png` to `vidqa`, and writes a result under `res://tests/results`. |

**[D] Naming trap:** `seq_to_mp4.py` consumes four-digit names, while `t_motion_capture.gd` writes three-digit names. Copying the old atom's frames into a folder and running `seq_to_mp4.py` will fail its ffmpeg input pattern. The new atom must standardize on `frame_%04d.png`.

---

## 3. Camera capability and coordinate contract

- **[O] SIM metres:** `Data.TILE_M = 2.0` (`variant3d/scripts/data.gd:23`). Camera `_target`, `jump_to_world()` and `apply_external_target()` use top-left-origin SIM metres; the SIM→centred-world subtraction occurs once in `_apply_transform()` (`camera3d.gd:46-47,248-282,504-524`).
- **[O] Fixed yaw, no orbit API:** yaw is fixed at 0 and pitch comes from `Data.CAMERA_PITCH`; the camera sits at height `h` and looks at the target (`camera3d.gd:262-282`). `_process()` supports middle-drag, edge scroll, arrow-key pan and zoom (`:589-686`), but no yaw/orbit control exists. Therefore W05 specifies an exact **pan**, not an invented orbit.
- **[O] Donor-legal height range:** `camera.min_height=20`, `max_height=58` (`variant3d/config.json:61-70`); `max_zoom = 58/20 = 2.9`, and `set_zoom_target(2.9, true)` gives height 20 m (`camera3d.gd:209-245,711-719`). Height 58 m corresponds to start zoom `0.3448276`.
- **[O] Capture keys:** pitch `-32°`, FOV `17.27°` (`config.json:35-36,61-64`), window `1280×720` (`config.json:50-53`). FOV remains a **PORT APPROXIMATION / UNVERIFIED** donor value (X39 P3/U4).
- **[D] Shot coordinates below are SIM metres, not tile indices.** A tile cell `(x,y)` has centre `((x+0.5)*2, (y+0.5)*2)` m. Resource `res[].x/y` and `starts[].x/y` in `--dump-map` are already metres (`main.gd:763-769`).
- **[I] Path interpolation is exact:** for frame `i` of `N`, `t=i/(N-1)` and `s=t*t*(3-2*t)`; interpolate each target component as `a+(b-a)*s`. Percentiles use the nearest-rank definition. These are protocol choices, not donor constants.

---

## 4. Required COORD-owned capture seam

### 4.1 Why a seam is required

No current main flag combines all of: repeated real SubViewport readback, an exact camera path, a selected terrain ROI, donor-backend validation, four-digit frame names and an outside-repo manifest. `--seq` has cadence but the wrong readback; `--screenshot` has the right readback but one frame; `t_motion_capture.gd` has repeated right readback but the wrong fixed contract.

**Recommended owner:** COORD, because it owns `main.gd`/integration. W05 changes no code.

### 4.2 Planned atom contract — `variant3d/tests/t_terrain_motion_capture.gd`

The file does **not exist** at this pass. The following is a required interface, not a claim that it is runnable today.

**Reuse:** the real-main boot, saver disarm, fixed-clock and SubViewport capture pattern from `t_motion_capture.gd:274-487`.

**Existing main-side args the packet may pass:**

- `--config <absolute temp overlay>`
- `--screenshot <absolute temp dummy.png>` — menu-skip/SubViewport setup only
- `--screenshot-frames 1000000`
- `--seed 20261113`
- `--timeout 840`

**Planned atom-only args:**

| Arg | Contract |
|---|---|
| `--dump <absolute dump.json>` | Same seed/size/config as the capture; supplies measured feature/relief coordinates |
| `--shot close64\|wide240\|feature240` | Selects the exact path/ROI algorithm in §4.3 |
| `--out-dir <absolute temp dir>` | Must be under `%TEMP%\opencode\v42\video\`; atom refuses a repo path |
| `--frames <n>` | Required exact frame count: 32 / 24 / 48 |
| `--fps <n>` | Presentation/cadence target: 8 / 6 / 8; also written to sidecar |

**Mandatory atom behavior:**

1. Windowed only. Headless is `SKIP_CAPTURE`, `passed=false`, never a visual PASS.
2. Validate requested **and actual** `game.MAP_W/MAP_H`, `Data.RANDOM_SEED`, `render_mode="3d"`, config `features.terrain.backend="donor"`, and live world stats `terrain_backend="donor"` / `terrain_script="res://scripts/terrain_donor_world.gd"` (`world3d.gd:705-707`). Record donor mesh/props stats; do not infer backend from the overlay alone.
3. Wait for `capture_view3d`; require 1280×720, `camera_current=true`, and non-null texture. The viewport must be `Screenshot3DViewport`.
4. Freeze main's sim exactly as the proven atom does: clear `ais`, set `speed=0`, `acc=0`, disarm `screenshot_done`. **Do not clear `game.entities`, `res_nodes`, `pattern_stamps` or clusters**; forests/mines/fields are required evidence.
5. Disable camera `_process` after applying each pose. Use `jump_to_world()` / `set_zoom_target(..., true)` so the path is explicit and does not inherit edge-scroll drift.
6. For every frame: apply path pose → `world.sync(0.0)` → set `UPDATE_ONCE` → `await RenderingServer.frame_post_draw` → read `capture_view3d.get_texture().get_image()` → save `frame_%04d.png`. Retry a flat read at most four times; then fail loudly. **No CPU fallback.**
7. Write only outside the repo: contiguous frames, `capture.json`, and no `res://tests/results` file. `capture.json` records config/dump SHA-256, requested/actual seed+size, backend/script, per-frame SIM time, target, camera position, height, zoom, FOV/pitch, ROI, capture milliseconds, blank retries, feature evidence coordinates, frame count and `parity.status="UNVERIFIED"`.
8. If the optional feature shot has no shore, forest or mine candidate at all, write `capture.json` with `status="NOT_APPLICABLE"`, list the empty classes and exit 0 without frames/MP4. If classes exist but no combined candidate meets the envelope, record `coverage="single_class"` and capture the highest-priority present class (shore → forest → mine). Do not shop another seed silently or imply uncovered classes were shown.

### 4.3 Exact shot, seed, path and ROI specification

All shots use **seed `20261113`**, `map_type="land"`, summer, 3D, donor backend, pitch `-32°`, FOV `17.27°`, fixed yaw 0, and a frozen sim. The seed is pinned by `variant3d/config.json:77`; no seed is chosen because it looks better. **[O] Read-only checks of the existing temp overlays confirm `backend="donor"` at line 31 and 3D/size/seed at lines 80-83 in both `map_donor_64.json` and `map_donor_240.json`; the packet copies and re-validates them rather than trusting that observation.**

ROI-selection rules below are **[I] framing heuristics**, not donor constants or acceptance thresholds. Every chosen screen ROI must be rechecked as ground-only in the captured frames; sky/HUD/void makes the dependent read UNVERIFIED.

#### Shot A — `close64`: 64² close-up relief pan

- **Config:** copy of the existing donor overlay `%TEMP%\opencode\v42\map_donor_64.json`; actual game grid must be 64×64.
- **Target selection:** from the fresh 64² dump, scan 9×9-tile land windows with a 12-tile map margin. Exclude water (`terrain==3`) and any window centre within 24 m of a start. Select the window with the greatest `p95(height)-p05(height)`; deterministic tie-break is lowest `y`, then lowest `x`. Let `C` be its centre in SIM metres.
- **Why this ROI:** it maximizes readable local relief rather than merely choosing the lowest/water-filled window. It is a diagnostic framing choice, not a donor distribution claim.
- **Path:** 32 frames at 8 fps (4 s). Target X is `C.x-6 → C.x → C.x+6`; target Y is `C.y`; use smoothstep interpolation. Height is fixed at 20 m (`zoom=2.9`). No yaw change.
- **Screen ROI:** `[0.20,0.30,0.80,0.90]`.
- **Meant to prove:** height/relief remains readable under parallax; slopes do not dissolve into flat olive; no checkerboard, tile terrace lattice, diagonal vein lattice or concentric rings; nearby props remain grounded on the surface. It does **not** prove donor parity.

#### Shot B — `wide240`: 240² wide landscape-composition pan

- **Config:** copy of `%TEMP%\opencode\v42\map_donor_240.json`; actual game grid must be 240×240.
- **Target:** map centre `C=(240*2/2, 240*2/2)=(240,240)` m. This is deterministic and independent of town-hall placement.
- **Path:** 24 frames at 6 fps (4 s). Target X `C.x-12 → C.x → C.x+12`; Y `C.y`; smoothstep. Height fixed at 58 m (`zoom=0.3448276`), the donor-legal widest view.
- **Screen ROI:** `[0.12,0.22,0.88,0.88]`.
- **Meant to prove:** landscape scale/composition at the shipped 240² size, terrain variation and prop distribution across a wider field of view, and absence of map-wide repetition/terrace bands. This is **not** a whole-map image; at donor-legal camera height it remains a local landscape view.

#### Shot C — `feature240`: conditional shore/forest/mine sample

- **Config/seed:** same 240² donor overlay and seed as Shot B.
- **Measured candidates from the dump:**
  - Shore: `tileblock` id 93, 97 or 98 (`terrain_donor_props.gd:116`; `terrain_donor_gen.gd:168-170`) with a 4-neighbour water cell (`terrain==3`).
  - Forest: a `res[]` node with `t="wood"`.
  - Mine: a `res[]` node with `t` in `{gold,iron,coal}`.
- **Selection:** first seek a combined candidate. Discard candidates within 30 m of a map bound so the ±10 m pan does not frame void. For each remaining mine, find its nearest wood node and nearest qualifying shore cell. Choose the mine minimizing `distance(mine,wood)+distance(mine,shore)`; tie-break by dump order. Convert the shore cell centre to metres. A combined candidate requires all three classes and `max(pairwise distance) <= 48 m`. If no combined candidate exists but at least one class exists, choose the highest-priority present class (shore → forest → mine); shore uses lowest `y` then lowest `x`, while forest/mine use dump order. Record `coverage="single_class"` plus every present/covered/missing class. If no class exists, record `NOT_APPLICABLE`.
- **Target/path:** for `coverage="combined"`, `C` is the arithmetic mean of the three SIM-metre positions. For `coverage="single_class"`, `C` is the selected feature position. In both cases capture 48 frames at 8 fps (6 s), target X `C.x-10 → C.x → C.x+10`, Y `C.y`, smoothstep, height 58 m. The 48 m envelope is an **[I] operational framing limit**, not a donor threshold.
- **Screen ROI:** `[0.18,0.28,0.82,0.88]`.
- **Meant to prove:** for covered classes only—a continuous warm beach → near-shore foam → water transition without a hard tile cut; organic forest spacing/contact rather than a tree grid; a mine deposit on its ground disc with material differentiation; no radial mine rings or checker/terrace pattern. If a class is absent or outside a combined envelope, record it as missing/not covered—never imply the clip showed it.

**[U] Seed feature presence and co-location are not asserted here.** They become known only after the fresh 240² dump is decoded. No existing still is used as a substitute for that measurement.

---

## 5. Copy-paste PowerShell packet — gated, serialized, outside-repo output

**Current-tree behavior:** the first guard throws because `t_terrain_motion_capture.gd` is absent. That is intentional. After COORD lands the §4.2 seam, the same packet is executable without inventing a `--seq` capability.

All Godot launches use `variant3d\tools\godot_runner.py`. No direct `godot`, no git, no concurrent runner jobs. Runner bookkeeping remains in `variant3d\.godot_queue`; **all configs, dumps, frames, sidecars, contact sheets, MP4s and hashes are outside the repo** under `%TEMP%\opencode\v42\video\<unique-tag>\`. The unique batch directory prevents stale frames from contaminating a later MP4.

```powershell
$ErrorActionPreference = 'Stop'
Set-Location 'C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3'

$Tag = Get-Date -Format 'yyyyMMdd-HHmmss-fff'
$Root = Join-Path $env:TEMP 'opencode\v42\video'
$V = Join-Path $Root $Tag
$VF = $V.Replace('\','/')
$Atom = 'variant3d/tests/t_terrain_motion_capture.gd'
$Runner = 'variant3d/tools/godot_runner.py'

# FAIL FAST on the current tree. This atom is the required COORD-owned seam,
# not an existing flag and not a capture result.
if (-not (Test-Path $Atom)) {
    throw "BLOCKED: $Atom is absent. Current --seq reads the root viewport and can emit an 800x600 CPU map; no donor motion capture is claimed."
}
if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
    throw 'BLOCKED: ffmpeg is not on PATH; seq_to_mp4.py otherwise returns 0 without an MP4.'
}

New-Item -ItemType Directory -Force -Path $V | Out-Null
$cfg64 = Join-Path $V 'map_donor_64.json'
$cfg240 = Join-Path $V 'map_donor_240.json'
Copy-Item (Join-Path $env:TEMP 'opencode\v42\map_donor_64.json') $cfg64 -Force
Copy-Item (Join-Path $env:TEMP 'opencode\v42\map_donor_240.json') $cfg240 -Force

# Explicit donor/3d/size/seed guards; never trust ambient config.
$c64 = Get-Content $cfg64 -Raw | ConvertFrom-Json
$c240 = Get-Content $cfg240 -Raw | ConvertFrom-Json
if ($c64.features.terrain.backend -ne 'donor' -or $c64.gameplay.render_mode -ne '3d' -or
    $c64.gameplay.map_width_tiles -ne 64 -or $c64.gameplay.map_height_tiles -ne 64 -or
    $c64.gameplay.random_seed -ne 20261113) { throw '64 overlay guard failed' }
if ($c240.features.terrain.backend -ne 'donor' -or $c240.gameplay.render_mode -ne '3d' -or
    $c240.gameplay.map_width_tiles -ne 240 -or $c240.gameplay.map_height_tiles -ne 240 -or
    $c240.gameplay.random_seed -ne 20261113) { throw '240 overlay guard failed' }

function Assert-QuietRunner {
    python $Runner status
    if ($LASTEXITCODE -ne 0) { throw 'runner status failed' }
    python variant3d/tools/assert_clean.py --json
    if ($LASTEXITCODE -ne 0) { throw 'runner not CLEAN; follow V06 evidence-backed remediation, never --ignore-history' }
}

Assert-QuietRunner

# Same-seed measured dumps. Headless is legitimate here: dumps are data, not visual evidence.
$dump64 = Join-Path $VF 'dump_64.json'
$dump240 = Join-Path $VF 'dump_240.json'
$idDump64 = "w05-$Tag-dump64"
$idDump240 = "w05-$Tag-dump240"

python $Runner run --id $idDump64 --timeout 700 --max-wait 3600 -- --headless --path variant3d -- --seed 20261113 --config ($cfg64.Replace('\','/')) --dump-map $dump64 --timeout 600
if ($LASTEXITCODE -ne 0) { throw "dump64 runner failed: $idDump64" }
python $Runner status

python $Runner run --id $idDump240 --timeout 700 --max-wait 3600 -- --headless --path variant3d -- --seed 20261113 --config ($cfg240.Replace('\','/')) --dump-map $dump240 --timeout 600
if ($LASTEXITCODE -ne 0) { throw "dump240 runner failed: $idDump240" }
python $Runner status

$d64 = Get-Content $dump64 -Raw | ConvertFrom-Json
$d240 = Get-Content $dump240 -Raw | ConvertFrom-Json
if ($d64.seed -ne 20261113 -or $d64.map_w -ne 64 -or $d64.map_h -ne 64) { throw 'actual 64 dump guard failed' }
if ($d240.seed -ne 20261113 -or $d240.map_w -ne 240 -or $d240.map_h -ne 240) { throw 'actual 240 dump guard failed' }

function Invoke-CaptureShot {
    param([string]$Shot, [string]$Config, [string]$Dump, [int]$Frames, [int]$Fps)
    $id = "w05-$Tag-$Shot"
    $out = Join-Path $VF $Shot
    $dummy = Join-Path $VF "$Shot-menu-skip.png"
    New-Item -ItemType Directory -Force -Path $out | Out-Null

    python $Runner run --id $id --timeout 900 --max-wait 3600 -- --path variant3d --script res://tests/t_terrain_motion_capture.gd -- --config ($Config.Replace('\','/')) --screenshot $dummy --screenshot-frames 1000000 --seed 20261113 --dump $Dump --shot $Shot --out-dir $out --frames $Frames --fps $Fps --timeout 840
    if ($LASTEXITCODE -ne 0) { throw "capture runner failed: $id" }
    python $Runner status
    return $id
}

$idClose = Invoke-CaptureShot -Shot close64 -Config $cfg64 -Dump $dump64 -Frames 32 -Fps 8
$idWide = Invoke-CaptureShot -Shot wide240 -Config $cfg240 -Dump $dump240 -Frames 24 -Fps 6
$idFeature = Invoke-CaptureShot -Shot feature240 -Config $cfg240 -Dump $dump240 -Frames 48 -Fps 8

function Assert-FrameSet {
    param([string]$Dir, [int]$Want)
    $frames = @(Get-ChildItem $Dir -File -Filter 'frame_*.png' | Sort-Object Name)
    if ($frames.Count -ne $Want) { throw "frame count $($frames.Count) != $Want in $Dir" }
    for ($i=0; $i -lt $Want; $i++) {
        $name = 'frame_{0:D4}.png' -f $i
        if (-not (Test-Path (Join-Path $Dir $name))) { throw "missing contiguous frame $name in $Dir" }
    }
    $frameArgs = @($frames.FullName)
    python variant3d/tools/smallmap_capture.py stats @frameArgs
    return $frames
}

$closeFrames = Assert-FrameSet -Dir (Join-Path $V 'close64') -Want 32
$wideFrames = Assert-FrameSet -Dir (Join-Path $V 'wide240') -Want 24
python variant3d/tools/seq_to_mp4.py --dir (Join-Path $V 'close64') --fps 8 --out (Join-Path $V 'close64.mp4')
if ($LASTEXITCODE -ne 0 -or -not (Test-Path (Join-Path $V 'close64.mp4'))) { throw 'close64 MP4 missing' }
python variant3d/tools/seq_to_mp4.py --dir (Join-Path $V 'wide240') --fps 6 --out (Join-Path $V 'wide240.mp4')
if ($LASTEXITCODE -ne 0 -or -not (Test-Path (Join-Path $V 'wide240.mp4'))) { throw 'wide240 MP4 missing' }

# Optional feature clip: combined or explicitly labelled single-class coverage is allowed.
# Empty CAPTURE_OK, silent partial coverage and NOT_APPLICABLE without a reason are not.
$featureDir = Join-Path $V 'feature240'
$featureManifest = Join-Path $featureDir 'capture.json'
if (-not (Test-Path $featureManifest)) { throw 'feature240 capture.json missing' }
$fm = Get-Content $featureManifest -Raw | ConvertFrom-Json
if ($fm.status -eq 'CAPTURE_OK') {
    if ($fm.coverage -notin @('combined','single_class') -or @($fm.classes_covered).Count -eq 0 -or [string]::IsNullOrWhiteSpace($fm.reason)) {
        throw 'feature240 CAPTURE_OK lacks explicit coverage/reason'
    }
    $featureFrames = Assert-FrameSet -Dir $featureDir -Want 48
    python variant3d/tools/seq_to_mp4.py --dir $featureDir --fps 8 --out (Join-Path $V 'feature240.mp4')
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path (Join-Path $V 'feature240.mp4'))) { throw 'feature240 MP4 missing' }
} elseif ($fm.status -eq 'NOT_APPLICABLE') {
    if ([string]::IsNullOrWhiteSpace($fm.reason)) { throw 'feature240 NOT_APPLICABLE lacks reason' }
    Write-Host "feature240 NOT_APPLICABLE: $($fm.reason)"
} else {
    throw "feature240 invalid capture status: $($fm.status)"
}

# Scan every capture job's stderr. Substitute nothing: ids are unique to this batch.
$logs = @()
foreach ($id in @($idDump64,$idDump240,$idClose,$idWide,$idFeature)) {
    $rdir = Get-ChildItem 'variant3d/.godot_queue/results' -Directory |
        Where-Object { $_.Name -like "*_$id" } | Select-Object -Last 1
    if ($null -eq $rdir) { throw "no result directory for $id" }
    $logs += (Join-Path $rdir.FullName 'stderr.txt')
}
python variant3d/tools/smallmap_capture.py scan-stderr @logs

# Freeze hashes outside the repo. Enumerate before writing the manifest itself.
$artifacts = @($cfg64,$cfg240,$dump64,$dump240) +
    @(Get-ChildItem $V -Recurse -File | Where-Object { $_.Extension -in '.png','.mp4','.json' })
$artifacts | Sort-Object FullName | ForEach-Object { Get-FileHash $_.FullName -Algorithm SHA256 } |
    ConvertTo-Json | Set-Content (Join-Path $V 'SHA256SUMS.json') -Encoding utf8

Assert-QuietRunner
Write-Host "W05 capture packet complete: $V"
Write-Host 'PORT APPROXIMATION only; donor parity UNVERIFIED.'
```

**Human acceptance after the packet:** inspect every `smallmap_capture.py stats` row and all `capture.json` fields. Require 1280×720, non-blank terrain, `full_width_dark_rows=0`, exact frame count, `camera_current=true`, `world_parent=Screenshot3DViewport`, live donor backend/script, actual requested seed+size, and `script_error_lines=0`. Any 800×600 frame, CPU fallback marker, blank frame, wrong backend, wrong actual grid, non-contiguous sequence or script error is a failed capture—not a reason to rerun until green.

---

## 6. Performance budget and watchdogs

All numbers here are **[I] operational budgets**, not donor performance claims.

| Stage | Budget |
|---|---|
| Runner queue wait | `--max-wait 3600`; wait is not runtime and never justifies duplicate submission |
| Dump job | runner `700 s`; in-game watchdog `600 s` |
| Capture job | runner `900 s`; in-game watchdog `840 s` (runner exceeds game by 60 s) |
| Boot/readiness | atom aborts after 300 s without game + `Screenshot3DViewport` |
| Capture phase after ready | hard deadline 180 s per shot |
| Target cadence | close64 **8 fps** (125 ms/frame); wide240 **6 fps** (167 ms/frame); feature240 **8 fps** |
| Target duration | 32/8 = 4 s; 24/6 = 4 s; 48/8 = 6 s |
| Per-frame stall watchdog | 10 s without a saved non-blank frame → abort, preserve partial artifacts |
| Rolling performance floor | median capture interval over the last 16 frames must be ≤250 ms (≥4 fps); otherwise `PERF_FAIL`, not a visual PASS |
| Blank read | at most 4 fresh `UPDATE_ONCE` retries, then fail; no CPU fallback |
| MP4 fps | presentation rate only; record measured intervals in `capture.json` and never call the clip real-time if the floor failed |

**One-Godot-at-a-time rule:**

1. Use only the serialized runner; never call `godot` directly.
2. Submit one `run`, wait for its terminal result, inspect `status` and artifacts, then submit the next.
3. Never re-submit a queued/running ticket. FIFO waits of minutes are normal (V42 §4 conventions; V06 risk 8).
4. Do not run `record_session.py`, `video_build.py`, another runner, or a manual Godot instance alongside a capture job.
5. If `status` shows pending work, a held lock, `now_serving != next_ticket`, or any `timed-out|error|skipped`, stop. Do not use `reset`, `doctor`, `cancel`, `unwedge`, result deletion or `--ignore-history` to manufacture a clean run.

---

## 7. Comparison to `reference/videos.md` — direction only, never parity

### 7.1 What the reference actually supplies

`reference/videos.md:3-7` states that YouTube watch pages returned only an HTML shell and no stream transcription was possible. The file is an index of 17 links/playlists with titles/descriptions and mechanics notes (`:9-27`), **not** a local video corpus, frame manifest, camera log or same-scene donor capture.

Useful qualitative entries are #2 (gameplay shell), #7 (early economy/wood/food), #8 (iron-mine opener), #10 and #11 (full skirmish). The index does **not** certify a shore, mountain, iron/coal or matched-camera reference. X39 Route D and A05 §4 therefore remain binding: third-party footage is direction-of-movement only.

### 7.2 Legitimate comparison procedure

1. **Candidate self-A/B first.** Repeat the exact same shot with the same seed/config/path/ROI. Compare frame `N` to frame `N` with `terrain_ab_metric.py <candidate> <repeat> --crop x,y,w,h --json`; the identical pixel crop is mandatory. `compare_shots.py --threshold 0.9999` is allowed only for this same-scene/same-camera reproducibility check, never donor-vs-port parity (`A05 §4.2`; `compare_shots.py:15-18,135-141`).
2. **Temporal port-internal read.** Play each MP4 at its declared fps and inspect full resolution plus `contact.png`. Record camera-target/height from `capture.json`; confirm motion follows the specified path and no sim/AI/camera drift occurred.
3. **Qualitative donor-video direction read.** If the owner supplies legally viewable reference clips/frames outside the repo, log URL/title, timestamp, unknown build/camera/compression and the exact sampled frame. Compare only directional questions: does terrain read as relief under parallax; do shore/forest/mine scales and contacts feel plausible; are grids/rings/terraces absent? Do not claim the same scene, seed, camera or timing.
4. **Optional still-distribution hint.** If reference frames are exported outside the repo, `terrain_ab_metric.py <candidate-frame> --compare-ref <outside-folder> --crop-frac <same-roi> --json --per-file` may report distribution direction. Its own label is `SMOKE METRIC - heuristic only, NOT a fidelity gate or donor proof` (`terrain_ab_metric.py:62,725-742`). Never compare a whole candidate frame to a cropped donor frame.
5. **Separate fields.** Keep numeric candidate self-A/B, temporal visual observations and donor-reference qualitative notes in separate report fields. A green number cannot erase a visible grid/streak/blotch/seam; a red number cannot invent one (`A05 §4.2`).

### 7.3 Shot-specific review card

| Shot | Port-internal questions | Donor-reference directional questions | Forbidden claim |
|---|---|---|---|
| close64 | Does relief remain readable through the pan? Any checker/terrace/vein/ring? Do props stay grounded? | Do reference clips suggest soft organic relief and stable parallax rather than stepped bands? | “matches donor hills”, “donor parity”, numeric donor threshold |
| wide240 | Is the 240² landscape composition coherent? Are repetitions/lattices visible at wide framing? | Does the reference suggest terrain variation and prop distribution at a comparable gameplay scale? | Whole-map equivalence; same camera/FOV; parity from unlike clips |
| feature240 | Is shore continuous? Are forests organic? Is the mine on its disc and differentiated? Any radial placement pattern? | Do reference clips give a plausible direction for beach/foam/water, grove density and mine scale? | Certified shore/iron/coal reference; same-seed or same-scene claim |

**Required reviewer line, verbatim:**

> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

Even a real owner-supplied donor PNG is necessary but not sufficient: matched scene/seed/camera/ROI and a demonstrated match are still required (X39 §4). Nothing in this protocol makes that transition.

---

## 8. Acceptance, failure and UNVERIFIED register

### 8.1 Accept a shot only if all are true

- Runner terminal `status=ok`, `exit=0`; fresh result and artifacts after that job's START.
- `scan-stderr` reports `script_error_lines=0`.
- Windowed `Screenshot3DViewport`, 1280×720, non-blank, `full_width_dark_rows=0`, no CPU fallback.
- Actual seed/map size match the shot; live world stats prove donor backend and donor terrain script.
- Exact contiguous frame count; per-frame camera path and height match §4.3; ROI is ground-only.
- Performance budget recorded; any floor/stall/deadline failure is labelled, not hidden by re-encoding.
- MP4 exists, is non-empty, has the declared frame count/duration, and was built from the saved frames.
- SHA-256 manifest exists outside the repo.
- Independent second-agent visual read completed; parity wording remains UNVERIFIED.

### 8.2 Stop conditions

Any wrong-size/800×600/blank/CPU frame; root-texture capture; donor backend not proven; camera drift; missing/non-contiguous frames; script error; watchdog/timeout; concurrent Godot; repo-written capture artifact; or attempted parity wording. Preserve the failed artifacts and runner logs; do not rerun until green.

### 8.3 UNVERIFIED register

| Item | Status | What settles it |
|---|---|---|
| Generalized `t_terrain_motion_capture.gd` exists and implements §4.2 | **[U] absent at W05 pass** | COORD-owned implementation + parse/windowed smoke |
| Existing `--seq` yields donor 3D motion | **[O] refuted for current source** | A future root→SubViewport capture fix plus fresh measured frames |
| Seed `20261113` feature presence / combined coverage | **[U]** | Fresh 240² dump + §4.3 selector; single-class coverage is allowed when explicitly recorded |
| Requested 64² produces actual 64² live grid | **[U]** | Dump and capture sidecar actual `MAP_W/MAP_H`; donor input can prefer a native-size mask (`terrain_donor_inputs.gd:210-222`) |
| Camera orbit | **[U]/unsupported** | New camera capability; current protocol is pan-only |
| Target 8/6 fps and watchdog margins on this machine | **[U]** | Measured per-frame intervals from a real capture |
| Local donor video frames/timestamps | **[U] absent** | Owner-supplied out-of-repo corpus and provenance log |
| Donor GPU A/B frame / demonstrated match | **[U] absent** | X39 owner route plus matched manifest and demonstrated match; still not automatic parity |

---

## 9. Honesty / scope statement

Exactly one repo file was written: this report. W05 executed **zero** runner subcommands, launched **zero** Godot processes, ran no capture, edited no code/config/asset/test/result, and used no git command. No donor executable or donor file was executed or copied. The existing temp configs and source files were read only. No frame, metric, feature coordinate, performance result or video is invented. Every command in §5 is a **PLANNED** packet for COORD and intentionally fails before any Godot job on the current tree because the required atom is absent. All existing flags were verified from source in three passes; all new atom-only arguments are explicitly labelled as a proposed interface, not as existing flags. **PORT APPROXIMATION / port-internal consistency only; donor parity remains UNVERIFIED.**

## 10. Five-line summary for COORD

1. `--seq/--seq-step/--seq-seconds/--journey` exist and boot donor 3D, but windowed `--seq` reads the root viewport and can silently emit an 800×600 CPU map; it is not admissible donor motion capture.
2. `--screenshot` has the proven SubViewport path but one frame; `record_session.py`, `video_build.py` and test-bridge `shot` also read the root; `seq_to_mp4.py` is assembly only.
3. Generalize the proven `t_motion_capture.gd` SubViewport seam into a COORD-owned atom with exact path/ROI, donor validation, four-digit frames and outside-repo manifests; W05 changes no code.
4. Pin seed `20261113`: 64² relief pan at 20 m, 240² map-centre wide pan at 58 m, and a conditional dump-selected shore/forest/mine sample; no orbit claim, no seed shopping, no silent partial-feature claim.
5. Run one serialized Godot job at a time with 900/840 s capture watchdogs, 8/6/8 fps targets and a 4 fps rolling floor; compare donor videos only for direction of movement and keep parity UNVERIFIED.

*End of W05. Planned only; no runner job, no Godot, no capture, no code/git edit, no parity claim.*
