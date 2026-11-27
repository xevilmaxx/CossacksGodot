---
id: PORT1TO1-ACCEPTANCE-RUNBOOK-2026-11-26
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: WORKER ACCEPTANCE-RUNBOOK — exact owner-runnable evidence-regeneration runbook (read-only)
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_acceptance_runbook.md
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION
created: 2026-11-26
labels: [OBSERVED, DERIVED, UNVERIFIED, "PORT APPROXIMATION", PARITY_UNVERIFIED, NO_APPROXIMATION]
parity_status: UNVERIFIED
parity_claim: false
parity_claim_code: NONE
verdict: "RESULT IS NOT GOOD — blocking_unverified is non-empty; six-condition parity chain 0/6 closed"
scope_guard: "Exactly one repository file written (this report). No source, shader, asset, config, test, fixture, result JSON, backup, git state, Godot process, runner job, gate, capture, MP4, ROI metric, MCP host or donor binary was created, modified or executed by this worker. All commands below are a planned, owner-runnable packet assembled from direct read-only reads of the landed tools and reports."
governing_sources:
  - variant3d/scripts/main.gd (:38-39, :175-178, :231-258, :1408-1411, :1669-1680, :2195-2235)
  - variant3d/tools/acceptance/capture_sequence.py (:133-265, :268-420)
  - variant3d/tools/acceptance/contact_sheet.py (:222-292)
  - variant3d/tools/acceptance/compare_frames.py (:43-53, :118-257)
  - variant3d/tools/godot_runner.py (:384-509, :615-652)
  - variant3d/tools/seq_to_mp4.py (:37-79)
  - variant3d/tools/full_map_shot.py (:1-120)
  - variant3d/tests/t_mcp_host.gd (:1-17, :24-31, :304-312)
  - %TEMP%\opencode\v42\verify_mcp.py and verify_mcp_tools.py (read-only on-disk reads)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_acceptance_plan.md (:103-254, :295-370)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_artifact_layout.md (:118-219, :240-284)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_roi_register.md (:146-214)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_roi_metrics.md (:108-183)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_fixed_step_plan.md (:617-671)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_gate_audit.md (:57-70, :170-194)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_parity_chain.md (:36-58, :127-133)
---

# PORT1TO1 — owner acceptance runbook (evidence regeneration, 2026-11-26)

> **Mandatory reviewer line, verbatim (`PORT1TO1_owner_decisions.md:15/32`, `PORT1TO1_acceptance_plan.md:28-29`):**
> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

> **What this is.** A single, runnable ordering of the landed tools so the owner can regenerate admissible evidence: static preflight → single-door Godot captures (4K overview, wide/close deterministic sequences) → contact sheets + MP4 → ROI metric re-execution → MCP host start/verify/stop → byte-identical two-run frame-hash check. Every command is copied from the landed source/tools/cited reports; PowerShell from repo root unless stated. **This worker ran none of it.** The six-condition chain is **0/6 closed** (`PORT1TO1_parity_chain.md:39/58`); no step below closes a condition or produces a donor A/B frame.

> **No approximations, no parity claim.** Every producer prints `parity=UNVERIFIED`; no metric, contact sheet, MP4, MCP screenshot or unit-test PASS is a donor-parity verdict. `blocking_unverified` is non-empty, so the honest verdict stays `RESULT IS NOT GOOD` (§9).

---

## 0. Conventions and non-negotiable rules [D]

- Repo root: `C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3`. All commands run from there. PowerShell `;`, never `&&`.
- Temp root used by the landed reports: `$env:TEMP = C:\Users\Maxym.Oboyshev\AppData\Local\Temp`. Define once per session:
  ```powershell
  $Acc = Join-Path $env:TEMP 'opencode\v42\acceptance'
  New-Item -ItemType Directory -Force -Path $Acc | Out-Null
  ```
- **Single door:** every Godot launch goes through `python variant3d/tools/godot_runner.py run`. **Never invoke `godot` directly.** `capture_sequence.py` and `full_map_shot.py --gen-dump` already submit through `run` internally (`capture_sequence.py:166-168`; `full_map_shot.py` header `:44-45`).
- **One job at a time:** submit one job, wait for its terminal result, inspect status/artifacts, then submit the next. Never re-submit a queued/running ticket; never run a second harness, `record_session.py`, `video_build.py` or a manual Godot alongside a capture (`acceptance_plan.md:110-113`).
- **Runner hygiene (absolute):** never `godot_runner.py reset`, `doctor`, `cancel`, `unwedge`, never delete result JSONs, never hand-edit queue status, never `--ignore-history`, never re-run until green, never lower a threshold or delete an assertion to manufacture a clean run (`acceptance_plan.md:112/311`, `gate_audit.md:179`). Ack of 575/582/585 is owner-only with an evidence-backed reason (`gate_audit.md:170-185`).
- Fresh output subdirectory per run; the harness refuses to reuse `frame_*.png` or an existing `.capture.lock` (`capture_sequence.py:140-143, :335-342`). Do not delete real captures or a live lock to force a rerun.
- All output artifacts go under `inbox/qa/captures/`, `%TEMP%\opencode\v42\` or `%TEMP%\opencode\v42\acceptance\`. **Never write a capture artifact into `variant3d/`.**

---

## 1. Static preflight (no Godot) — run before every capture block [D]

Exact commands from `PORT1TO1_acceptance_plan.md:117-127` / `PORT1TO1_artifact_layout.md:124-136`:

```powershell
python -m py_compile variant3d/tools/acceptance/imgio.py `
  variant3d/tools/acceptance/capture_sequence.py `
  variant3d/tools/acceptance/contact_sheet.py `
  variant3d/tools/acceptance/compare_frames.py
python variant3d/tools/godot_runner.py status
python variant3d/tools/assert_clean.py --json
Get-Command ffmpeg,ffprobe -ErrorAction SilentlyContinue
python -c "import PIL; print(PIL.__version__)"
Test-Path "$env:TEMP\opencode\donor_videos\selected\cZW0AEupCaI\t_600.png"
```

Accept only: `py_compile` exit 0; runner `status` shows no pending job, `godot.lock` free, `now_serving == next_ticket`, no `timed-out|error|skipped` in history; `assert_clean.py --json` CLEAN without `--ignore-history`; ffmpeg + ffprobe + Pillow present; donor frame present. **Missing ffmpeg is a hard block for MP4** — `seq_to_mp4.py` returns 0 with only a contact sheet (`seq_to_mp4.py:64-68`, `acceptance_plan.md:129`). Pillow absent ⇒ `contact_sheet.py --fit` refused and 5×7 fallback font used (`contact_sheet.py:106-108, :170-172`).

### 1.1 Preserve-only hashes and backups — before AND after every capture [D]

Exact commands from `PORT1TO1_artifact_layout.md:214-219` and `acceptance_plan.md:295-311`:

```powershell
Get-FileHash variant3d\scripts\main.gd,variant3d\scripts\world3d.gd,inbox\backup\main.gd.bak-COORD-I11,inbox\backup\world3d.gd.bak-COORD-I11 -Algorithm SHA256
Get-FileHash variant3d\config_donor_capture.json,variant3d\config.json,variant3d\assets\models\manifest.json -Algorithm SHA256
```

Hard baseline witnesses (must match exactly; a changed hash invalidates the run):

| File | Required SHA-256 |
|---|---|
| `variant3d/config_donor_capture.json` | `aa857480474399dc4674104744ea292bf84094d8321cdd4d0889c24cf9a202da` |
| `inbox/backup/main.gd.bak-COORD-I11` | `3859B6056BFDFDD5A659931835FD0901DD03DB36B02A453389D9338BAC9E71F8` |
| `inbox/backup/world3d.gd.bak-COORD-I11` | `44EE96C0DCFB35558F6EA3E0493E8F8FAA1CADF6E155BEB38031A9B11E1AB07A` |

`variant3d/config.json` and `variant3d/assets/models/manifest.json` have **no recorded baseline** in the cited reports; record their before/after values in the run notes and require them to be identical across the run (point-in-time readings only, not preservation proof — `artifact_layout.md:250-253`). Also record the six P-9 tool hash prefixes `ABBF0571 / DDFB8688 / 00C0591A / 667B71FB / 3A92D053 / 5A3B9E77` (`artifact_layout.md:255`) if re-hashing tooling.

Preserve-only values that must not be flipped to "fix" a defect: `config.json` `features.terrain.backend="donor"`, `relief_stamps=true`, `color_unify=true`, water `alpha_confine=true`/`shore_prox=false`, camera pitch `-32`, `start_zoom=0.3448276`, `fov_deg=17.27` (labelled PORT APPROX), 1280×720; `config_donor_capture.json` `demo_mill=true`; single-applied I11 seam in `main.gd`/`world3d.gd`; additive-only v5 save keys; preserved donor contradictions (`TileSmoothPasses=6` carried alongside `SmoothTileMap(...,3)` use, `lake_big := plain*2*0`, swamp 17×20/18×23, `alphanull`, `specular_rgb` effective `vec3(0)`) — **never "repair"** (`acceptance_plan.md:299-311`, `artifact_layout.md:227-238`).

---

## 2. Single-door Godot captures

### 2.1 4K whole-map overview (diagnostic — never donor-legal) [D]

`full_map_shot.py --gen-dump` submits one headless `godot_runner.py run` job (`t2full-*` ids) and then composes the PNG in headless Python. Exact command from `acceptance_plan.md:135-140` / `artifact_layout.md:141-145`:

```powershell
python variant3d/tools/full_map_shot.py --gen-dump --seed 20261113 `
  --config variant3d/config_donor_capture.json `
  --dump "$env:TEMP\opencode\v42\acceptance\map_overview_dump.json" `
  --out "$env:TEMP\opencode\v42\acceptance\map_overview_4k.png" --tile-px 64
```

Required sidecar assertions: `png_width == map_w*tile_px`, `png_height == map_h*tile_px`, actual seed `20261113`, and no undisclosed `--tile-px` fallback (`acceptance_plan.md:142-146`). Fidelity caveat: reproduces tile choice/placement/season tint/water/resources, **not** SmoothTiles cross-fade, water shader, lighting, fog or sprites (`full_map_shot.py:38-42`). This 4096×4096 top-down plan view is **not** a donor-legal 1280×720 RTS frame: never feed it to `compare_frames.py` against a donor frame (resolution refusal) and never claim water parity from its pale blobs.

**Never run concurrently with another Godot job.** After the run: `python variant3d/tools/godot_runner.py status`; require pending 0, lock free, counters aligned.

### 2.2 Wide + close deterministic sequences (port-internal evidence) [D]

Prepare two temp config copies; the repo config stays byte-unchanged (`acceptance_plan.md:152-162`):

```powershell
$Acc = Join-Path $env:TEMP 'opencode\v42\acceptance'
New-Item -ItemType Directory -Force -Path $Acc | Out-Null
Copy-Item variant3d\config_donor_capture.json (Join-Path $Acc 'wide_config.json') -Force
Copy-Item variant3d\config_donor_capture.json (Join-Path $Acc 'close_config.json') -Force
# In close_config.json set ONLY camera.start_zoom = 2.9; keep pitch -32, fov 17.27,
# 1280x720, random_seed 20261113, backend donor. Record BOTH SHA-256 values.
Get-FileHash (Join-Path $Acc 'wide_config.json'),(Join-Path $Acc 'close_config.json') -Algorithm SHA256
```

Landed deterministic harness flags (`capture_sequence.py:293-296, :310-317`; engine flags at `:153-154`): `--deterministic` and `--capture-ticks N` (positive; must equal `frames * max(1,round(step*32))`). For `--frames 24 --step 1`, `N = 24*32 = 768` (`fixed_step_plan.md:634`). `--headless`/`--mode shot` are refused with `--deterministic`.

Exact wide/close deterministic capture (one call, two runner jobs submitted strictly in order, ids `acapt-accept1-wide` then `acapt-accept1-close`):

```powershell
python variant3d/tools/acceptance/capture_sequence.py `
  --seed 20261113 --frames 24 --step 1 --label accept1 `
  --view wide=(Join-Path $Acc 'wide_config.json') `
  --view close=(Join-Path $Acc 'close_config.json') `
  --mode seq --deterministic --capture-ticks 768 `
  --timeout 240 --max-wait 3600 `
  --out inbox/qa/captures/accept1_det_20261126
```

Harness contract (`capture_sequence.py:299-328, :235-256`): `--frames` 1..600; `--step` 0.25..30; `frames*step` in [1,600]; `--label` slug; unique `--view` names; `--seed` integer or literal `random` (non-deterministic, recorded `deterministic=false`). Engine args are `--path variant3d -- --config <abs> --seed <int> --deterministic-capture --capture-ticks 768 --seq <view_dir> --seq-seconds 24 --seq-step 1 --timeout 210`, wrapped by `godot_runner.py run --id acapt-<label>-<view> --timeout 240 --max-wait 3600 --`.

Admissibility gate on `manifest.json` per view (`acceptance_plan.md:177-184`, `capture_sequence.py:224-256`):

- `status=ok`, `deterministic=true`, `capture_ticks=768`, `expected_sim_seconds=24.0`, `expected_resolution=[1280,720]`, `parity=UNVERIFIED`;
- every view `complete=true`, `runner_status=ok`, `runner_exit=0`, `frame_count=24`, `headless=false`, `capture_semantics="windowed seq = real viewport frames (frame_post_draw)"`;
- `resolution_observed == {"width":1280,"height":720}` and `resolution_matches_request=true` — the discriminator against the silent 800×600 `_render_headless_image` CPU fallback;
- `seq_index.json`: `deterministic=true`, `ticks_done=768`, `ticks_per_frame=32`, `sim_seconds == 24.0` (±1e-9), `winner=-1`, `frames=24`, `mode="window"`;
- config SHA-256 recorded and equal to the temp copy used; per-frame `sha256_file` + `sha256_pixels` present;
- engine stderr contains **none** of `deterministic-capture:`, `watchdog:`, `cli: wall-clock limit reached`, `fallback map render`, `headless map render`, `blank image, retrying`.

`main.gd` refuses blank/wrong-size viewport frames under deterministic mode and never substitutes the CPU fallback (`main.gd:2211-2215`). A winner early stop records `complete=false` and exits non-zero. All of this is **port-internal evidence only** — no donor A/B (`acceptance_plan.md:184, :188-190`).

---

## 3. Contact sheets and MP4 assembly [D]

### 3.1 Contact sheets (pixel-preserving by default)

```powershell
python variant3d/tools/acceptance/contact_sheet.py `
  --manifest inbox/qa/captures/accept1_det_20261126/manifest.json `
  --out inbox/qa/captures/accept1_det_20261126/contact.png --cols 4 --hash-labels
```

Sources from repeatable `--frame`, `--dir` (`--pattern`, default `frame_*.png`) and/or `--manifest` (optional `--view NAME`); de-duplicated and sorted (`contact_sheet.py:65-96`). Default **no rescale**: 1:1 paste, label band above pixels, sidecar `<out>.json` with `rescaled=false`, `exact_pixels_preserved=true`, source SHA-256 and box (`contact_sheet.py:160-166, :278-290`). `--fit 320x180` explicitly rescales (label `RESCALED … <- …`, sidecar `rescaled=true`) — use only for overview slides, never fine-pattern judging. Sidecar note: "Presentation only … parity=UNVERIFIED."

### 3.2 MP4 assembly (post-capture only)

```powershell
python variant3d/tools/seq_to_mp4.py `
  --dir "$env:TEMP\opencode\v42\acceptance\wide240" --fps 6 `
  --out "$env:TEMP\opencode\v42\acceptance\wide240.mp4"
python variant3d/tools/seq_to_mp4.py `
  --dir "$env:TEMP\opencode\v42\acceptance\close64" --fps 8 `
  --out "$env:TEMP\opencode\v42\acceptance\close64.mp4"
```

Flags are exactly `--dir`, `--fps` (int, default 10), `--out` (default `<dir>/journey.mp4`), `--contact-only` (`seq_to_mp4.py:38-43`). Encoder: `-framerate <fps> -i frame_%04d.png -c:v libx264 -pix_fmt yuv420p -crf 20` (`:70-72`). **It never reads fps from a manifest** — pass fps explicitly and declare/record it in the run notes. It reads four-digit `frame_%04d.png` only (three-digit `frame_%03d.png` fails). For a fresh run point `--dir`/`--out` at that run's frame directory (e.g. `inbox/qa/captures/accept1_det_20261126/01_wide`).

Mandatory guards — do **not** trust the exit code (`acceptance_plan.md:222-230`):

1. `Get-Command ffmpeg` preflight; missing ffmpeg ⇒ exit 0 with contact sheet only (`seq_to_mp4.py:64-68`).
2. `Assert-FrameSet`: count equals manifest frame count; names contiguous `frame_0000.png … frame_{N-1}.png`.
3. `Assert-Video`: MP4 exists and non-empty; `ffprobe -count_frames nb_read_frames` equals frame count; duration equals `frame_count/fps` within `max(0.25s, 1/fps)`.
4. `contact.png` exists after assembly; regenerate with `--contact-only` if absent.
5. Extract six diagnostics at 0/20/40/60/80/100% by exact index `round(p/100*(N-1))`:
   `ffmpeg -y -loglevel error -i <mp4> -vf "select=eq(n\,IDX)" -fps_mode passthrough -frames:v 1 <diag>\frame_IDX_pPPP.png`
6. Write `VIDEO_SHA256SUMS.json` enumerating artifacts **before** writing the manifest, outside the repo.
7. Human review: open `contact.png`, then the six full-resolution diagnostics; confirm declared fps/duration. A clean MP4 built from bad frames is still a failed capture — **re-encoding is never a remedy**.

---

## 4. ROI metric re-execution [D]

Use the 14 exact `compare_frames.py` commands in `PORT1TO1_roi_metrics.md:112-154` (or their register form at `PORT1TO1_roi_register.md:150-192`). Each is mechanically runnable; every one prints `parity=UNVERIFIED`. Command contract (identical for all 14):

- `--donor "$env:TEMP\opencode\donor_videos\selected\cZW0AEupCaI\t_<time>.png"` — one of the 12 verified 1280×720 third-party H.264 stills; no new extraction.
- `--port inbox/qa/captures/fullport6_seq2_20261113/01_donor/frame_0000.png` — F0, port pixels (view label `01_donor`), 1280×720, `sha256_file=6fc7dfab26ea04429db165c4327604908b892cfa4707605d5eda32e8a6f4ba80`. Substitutions only with a recorded reason; never `map_overview_4k.png` or a headless frame.
- `--roi x,y,w,h` — the donor-side box verbatim, `x,y>=0`, `w,h>=1`, inside 1280×720; the same box is cropped from both frames with no rescaling/clamping/inferred alignment.
- `--roi-source "<exact register provenance string>"` (≥10 chars, ends `locator only, no same-camera claim`).
- `--camera NOT_SHARED_donor-oblique_vs_port-17p27` — mandatory marker recording that **no shared camera is asserted**; do not replace with a friendly label.
- `--config-donor`/`--config-port`: not supplied. `--hist-bins` default 16; `--amplify` default 1.0. `--assert-ab-verified` **not supplied**.

Representative row (R06, verbatim from `roi_metrics.md:129`):

```powershell
python variant3d/tools/acceptance/compare_frames.py --donor "$env:TEMP\opencode\donor_videos\selected\cZW0AEupCaI\t_600.png" --port inbox/qa/captures/fullport6_seq2_20261113/01_donor/frame_0000.png --roi 0,60,640,300 --roi-source "PORT1TO1_video_targets.md section 3 D4, donor cZW0AEupCaI t_600 conifer belt and glades [0,60,640,360) => 0,60,640,300; identical box on port frame; locator only, no same-camera claim" --camera NOT_SHARED_donor-oblique_vs_port-17p27 --out-diff inbox/qa/captures/roi_metrics_20261113/diff_roi_R06_t600_d4.png --report inbox/qa/captures/roi_metrics_20261113/diff_roi_R06_t600_d4.json
```

The 14 ROI ids are R01 `400,350,500,300`; R02 `920,140,360,250`; R03 `640,360,640,360`; R04 `640,500,460,200`; R05 `180,300,240,170`; R06 `0,60,640,300`; R07 `200,280,280,170`; R08 `400,350,500,250`; R09 `900,140,180,150`; R10 `400,230,100,100`; R11 `620,40,110,90`; R12 `1060,220,110,110`; R13 `380,280,530,280`; R14 `0,0,1280,360` (`roi_register.md:98-113`). Use a fresh output directory for a fresh run (e.g. `inbox/qa/captures/roi_metrics_20261126/`). Where a landed report has no numeric box (`roi_register.md:123-142`: `t_0` D4, `t_60`, `t_600` D1/D8, `t_900`, `t_1200` D4, `t_1500`, `t_1800` D1/D8, `t_2100` D7/D8, the `t_2260`/`t_2370` water negatives, D9, 4K/headless) **emit no command**. Never invent, move, rescale or re-infer a ROI to make a metric look better.

Refusals (`compare_frames.py:143-174, :234-237`, exit 2, prints `parity=UNVERIFIED`): missing mandatory arg; bad `--roi` shape; `--roi-source` <10 chars; `--assert-ab-verified` reason <10 chars; `--amplify` outside [1,64]; donor/port load failure; **different resolutions**; ROI outside frame; differing SHA-256 if both configs supplied. Water/shore from `t_2260`/`t_2370` is **BLOCKED REFERENCE** (`PT-V2`/`PT-V3`; `acceptance_plan.md:95-99`).

---

## 5. MCP host — start / verify / stop [D]

The host is a Streamable-HTTP MCP endpoint inside the live Godot game, `POST http://127.0.0.1:8931/mcp` (JSON-RPC `initialize`, `tools/list`, `tools/call`). In-repo protocol constants: `variant3d/tests/t_mcp_host.gd:23-31`; backup `inbox/backup/t_mcp_host.gd.bak-MCPPROTO`. It occupies the single Godot door: **no capture may run while the host job is live**.

### 5.1 Start (through the single door, with rendering — no `--headless`)

Exact launch form from `t_mcp_host.gd:9-15`:

```powershell
$ABS = (Resolve-Path variant3d\config_donor_capture.json).Path
$BOOT = Join-Path $env:TEMP 'opencode\v42\boot_viewport.png'
python variant3d\tools\godot_runner.py run --id mcp-host --timeout 3600 -- `
  --path variant3d --script res://tests/t_mcp_host.gd -- `
  --config "$ABS" --seed 20261113 --mcp-port 8931 `
  --screenshot "$BOOT"
```

`_parse_args` refuses unless `--config` is absolute, `--seed 20261113`, and an explicit `--screenshot <absolute dummy png>` is present in user args (`t_mcp_host.gd:62-82`, root-cause note `:69-74`). The host prints `GAMECRAFT-MCP LISTENING port=8931 (donor map booting)` before the map build and `GAMECRAFT-MCP READY port=8931 map=<w>x<h>` only when the real game is live (`:143-162`). Wait for READY before probing. Do not use a QA config from inside the repo for production evidence; the landed probe config is `%TEMP%\opencode\v42\mcp_qa_small.json` (QA-ONLY, "NOT a parity artifact").

### 5.2 Verify (all 6 tools)

Probe scripts are on disk at `%TEMP%\opencode\v42\verify_mcp.py` and `verify_mcp_tools.py` (read-only reads this pass):

```powershell
python "$env:TEMP\opencode\v42\verify_mcp.py"
python "$env:TEMP\opencode\v42\verify_mcp_tools.py"
```

`verify_mcp.py` retries `initialize` up to 120×2 s, sends `notifications/initialized`, runs `tools/list`, calls `game.status` and `game.tick({})` (expected `isError` refusal), probes `GET /mcp`, and ends `VERIFY DONE (protocol level only; no parity claim)`. Acceptance: HTTP 200 `initialize` with `protocolVersion` in `["2024-11-05","2025-03-26","2025-06-18"]`, `serverInfo=cossacksgodotmcp/1.0.0`, integer JSON-RPC id preserved, and **`tools/list` returns exactly 6 tools**:

| # | Tool | Verification call (`verify_mcp_tools.py:31-36`) |
|---|---|---|
| 1 | `game.status` | `{}` |
| 2 | `game.tick` | `{"seconds":0.5}` |
| 3 | `camera.pan_to` | `{"x":100.0,"y":40.0}` |
| 4 | `game.screenshot` | `{}` — returns text JSON + base64 PNG |
| 5 | `game.place_building` | `{"sid":"cen","x":110.0,"y":45.0}` |
| 6 | `video.record_frames` | `{"frames":4,"sim_step":0.03125}` |

All six must appear in `tools/list` and return without `isError` in the tool probe's argument shape; `game.tick({})` must be a clean `isError` refusal (missing `seconds`), not a silent success. Screenshot/video outputs land in `%TEMP%\opencode\v42\mcp_gamecraft\` (`shot_0001.png`, `vid_0002.png … vid_0005.png`) — presentation/telemetry only, **no parity claim** (`verify_mcp.py:76`, `verify_mcp_tools.py:37`, `artifact_layout.md:111-113`). MCP `game.tick` is an optional fixed-tick driver, not donor A/B and not the deterministic-capture design.

### 5.3 Stop

Let the runner job reach its `--timeout` and hard-kill its process tree (`godot_runner.py:449-459`), then confirm `python variant3d/tools/godot_runner.py status` shows pending 0, lock free, counters aligned. Never use `reset`/`doctor`/`cancel`/`unwedge`, never delete the job's result files, and never start another Godot job until the queue is quiet. A `failed`/timed-out host job is expected for a long-running server (`%TEMP%\opencode\mcp_host_runner.log`: ticket 0 `mcp-host-8931` END failed after 308.13 s); it is not evidence of a gate pass or a parity claim.

---

## 6. Byte-identical two-run frame-hash check [D]

This is the landed deterministic-mode empirical test (`main.gd:38-39/1408-1411/2227-2233`, `capture_sequence.py:153-154/235-256`); its pass conditions are `PORT1TO1_fixed_step_plan.md:640-661`. Run A and Run B are byte-identical except `--label` and `--out`. Same pinned temp config bytes → same `config_sha256_file`. Preflight is exactly §1; one job at a time; no `reset`/`doctor`/`cancel`/result deletion.

```powershell
# Run A
python variant3d/tools/acceptance/capture_sequence.py `
  --seed 20261113 --frames 24 --step 1 --label fixedA `
  --view wide=(Join-Path $Acc 'wide_config.json') `
  --mode seq --deterministic --capture-ticks 768 `
  --timeout 240 --max-wait 3600 `
  --out inbox/qa/captures/fixedA_20261126

# Run B — identical except label and out
python variant3d/tools/acceptance/capture_sequence.py `
  --seed 20261113 --frames 24 --step 1 --label fixedB `
  --view wide=(Join-Path $Acc 'wide_config.json') `
  --mode seq --deterministic --capture-ticks 768 `
  --timeout 240 --max-wait 3600 `
  --out inbox/qa/captures/fixedB_20261126
```

`768 = frames(24) * max(1, round(step(1)*FPS(32)))`; `engine_fps_anchor="variant3d/scripts/data.gd:246"`.

**Acceptance criteria — all required, none weakened:**

1. Both manifests: `status=ok`, `parity=UNVERIFIED`, `deterministic=true`, `seed="20261113"`, `deterministic_capture=true`, `capture_ticks=768`, `expected_sim_seconds=24.0`, `expected_resolution=[1280,720]`, `config_sha256_file` equal to the pinned temp config, `headless=false`, `capture_semantics="windowed seq = real viewport frames (frame_post_draw)"`.
2. Every view: `runner_status=ok`, `runner_exit=0`, `complete=true`, `frame_count=24`, `resolution_observed=={"width":1280,"height":720}`, `resolution_matches_request=true`.
3. `seq_index.json`: `deterministic=true`, `ticks_done=768`, `ticks_per_frame=32`, `sim_seconds == 768/32 == 24.0` (±1e-9), `frames=24`, `mode="window"`, `winner=-1`.
4. `runner_stderr.txt` / `engine_stderr` contain **no** `watchdog:`, no `cli: wall-clock limit reached`, no `deterministic-capture:` refusal line.
5. **Byte-identical frame hashes:** for the view and each index `0..23`, Run A `sha256_pixels` equals Run B `sha256_pixels` in order, and `sha256_file` likewise (`sha256_pixels` is authoritative if PNG metadata ever differs). All other per-frame/manifest fields identical apart from `generated_utc`/`runner_ticket`/timestamps/paths.
6. No 800×600 or blank frame; no early termination. One such frame is a **failed capture**, not an admissible replay.

**Verdict rule (`fixed_step_plan.md:663-671`):** all conditions hold ⇒ evidence supports **port-internal fixed-seed self-consistency only**, never donor parity; the reviewer line stays verbatim. Any condition fails ⇒ deterministic capture mode is **not demonstrated**; keep the affected Class-N/`[U]` item open (N4 audio RNG, N9 save/load, U5 water time, GPU/driver state remain open hazards; N3 fisher sim draw is code-fixed via `sim_rng` but donor attribution is `[U]`). Do not lower a threshold, substitute a CPU map, retry until green or add a port fallback to force a match. A passing pair never changes `parity=UNVERIFIED` or `blocking_unverified`; unit-test gates are not the acceptance path.

---

## 7. Refusal / failure handling — never force a pass [D]

| Failure | Exact evidence | Required action |
|---|---|---|
| Runner preflight not quiet, lock held, `now_serving != next_ticket`, or `timed-out|error|skipped` in history | `godot_runner.py status`, `assert_clean.py --json` | **STOP.** Do not `reset`/`doctor`/`cancel`/`unwedge`, do not delete result JSONs, do not `--ignore-history`, do not ack without evidence-backed owner reason. Report the state; parity stays UNVERIFIED. |
| `.capture.lock` held / `frame_*.png` already present | `capture_sequence.py:140-143, :335-342` refusal | Use a **fresh** `--out`; inspect the lock owner first; remove a lock only after confirming no capture process is alive. Never delete real captures to rerun. |
| Runner failure / no ticket / `status != ok` / `runner_exit != 0` | manifest `entry["error"]`, `runner_stderr.txt` | Preserve the partial manifest as failure witness; STOP. Do not re-submit until green. |
| 800×600 / CPU fallback / wrong resolution | `resolution_observed`, `resolution_matches_request`, `capture_semantics` | Failed capture. Never substitute headless output, never `--headless` for donor-legal frames, never re-encode to hide it. |
| Tick contract/witness mismatch, winner early stop, watchdog/refusal line in stderr | `seq_index.json`, stderr scan (`capture_sequence.py:235-256`) | Failed/incomplete capture; keep the affected `[U]` open; do not relax `--capture-ticks` or step to force a match. |
| `compare_frames.py` `REFUSED:` (exit 2) | §4 refusal list | Preserve stderr + `parity=UNVERIFIED`. **Do not change `--roi`, `--roi-source`, `--camera`, resolution configs, donor/port files, `--hist-bins` or `--amplify` to obtain a run.** If no landed numeric box exists, emit no command (`roi_register.md:123-142`). |
| MP4 missing/empty/wrong decoded frames/duration, ffmpeg absent | §3.2 seven guards | Hard block; do not substitute the contact sheet for a video, do not lower fps/duration tolerances, do not re-encode bad frames. |
| MCP probe fails / `tools/list` ≠ 6 / tool `isError` | `verify_mcp.py`, `verify_mcp_tools.py` output | Record UNVERIFIED; check READY line, absolute `--config`, explicit `--screenshot`, port 8931. Do not wipe the queue or kill unrelated jobs to restart until green. |
| Any metric looks "close" or a gate JSON says `PASS` | stdout/JSON | Support cue only. **No similarity %, donor-threshold PASS, "matches donor", "gate PASS" or `--assert-ab-verified` as verification.** All such reports print `parity=UNVERIFIED`. |

Forbidden at all times: editing a threshold/assertion, deleting a result, fabricating a green JSON, promoting a class-B advisory band, re-applying the I11 seam, flipping preserve-only config flags, or executing the donor binary. Water/shore from this video stays `BLOCKED REFERENCE` (`t_2260`/`t_2370` negatives); never infer a target from `map_overview_4k.png`/`map_overview_waterfix.png`.

---

## 8. Conditions still UNVERIFIED (no step above closes them) [U]

All six chain conditions remain unclosed (`PORT1TO1_parity_chain.md:49-58`): (1) no owner-supplied matched donor GPU frame — the 12 H.264 stills are third-party, unknown build/map/camera/zoom/compression; (2) only port-internal candidate captures; (3) inputs not matched/labelled — `--camera NOT_SHARED_donor-oblique_vs_port-17p27` asserts no shared camera, `randkey0/1` derivation `[U]`; (4) gates not fresh/COORD-ruled, 575/582/585 unacked, D1/D3 unruled; (5) spec/toolchain incomplete, `blocking_unverified` non-empty; (6) no COORD-signed zero-mismatch geometry/frame ruling. P0-1…P0-8 remain open with hard-fails/labels intact (`acceptance_plan.md:273-291`, `parity_chain.md:93-108`). No tier above 2 exists.

---

## 9. Final verdict template (choose exactly one) [D]

```
PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B
frame exists; this review certifies neither donor fidelity nor a gate pass.

RESULT IS NOT GOOD — <one blocking item, e.g. no donor A/B frame (PT-V1 controlling),
water U12/U4*, FOW grid a-e, tick interleave, animation blend, save container, RNG G1,
or absent COORD ruling>.
parity.claim = NONE
parity.status = UNVERIFIED
blocking_unverified = <non-empty list: PT-V1…PT-V8, P0-1, P0-1b, P0-2…P0-8, W-R1,
                       T-SEED, T-CALLBACK, atlas-layout, X17, and the domain residuals>
```

The alternative `RESULT IS GOOD — DONOR-GROUNDED STRUCTURE VERIFIED + SELF-CONSISTENT VISUAL; donor parity UNVERIFIED (declared, accepted)` is admissible **only** when tier-2 G0-a…e checks pass, the required property is visible, forbidden artifacts absent, metric/visual fields separated, reviewer line verbatim, and no §8 blocker is in the blocking set (`acceptance_plan.md:355-368`). Even then no class reaches "donor parity." Given the current tree, **`blocking_unverified` is non-empty, so `RESULT IS NOT GOOD` unconditionally.** Forbidden phrasing: "matches donor", "close to donor", "donor parity", "similarity %", "donor threshold PASS", "gate PASS" derived from a capture, or treating `--assert-ab-verified` as verification (`acceptance_plan.md:370`).

---

## 10. Claim register

| # | Claim | Label |
|---|---|---|
| 1 | All commands/flags copied from landed source and cited reports; deterministic flags are present in `main.gd`/`capture_sequence.py` | [O]/[D] direct source reads |
| 2 | Single door is `godot_runner.py run`; `capture_sequence.py` and `full_map_shot.py --gen-dump` submit through it internally | [O] source |
| 3 | Four acceptance scripts compile; preflight/preserve-only hash commands are the landed ones; three hashes have exact baselines, two have none | [O]/[D] reports §1 |
| 4 | Deterministic wide/close and two-run commands satisfy `capture_ticks == frames*max(1,round(step*32))` and the §6 criteria | [D] source + `fixed_step_plan §8` |
| 5 | MCP host exposes exactly 6 tools; probe scripts verify protocol + all six calls | [O] on-disk probe reads, `t_mcp_host.gd:304-312` |
| 6 | No step produces a donor GPU A/B frame; every producer prints `parity=UNVERIFIED` | [U] guard, `parity_chain.md:36-58` |
| 7 | `blocking_unverified` non-empty ⇒ verdict `RESULT IS NOT GOOD`, parity UNVERIFIED | [D] `acceptance_plan.md:358-368` |
| 8 | This worker wrote exactly one repository file (this report); no code/Godot/git/donor execution, capture, MP4, ROI metric or MCP host action | [O] scope |

---

*End of PORT1TO1_acceptance_runbook. Read-only runbook; exactly one repository file written. No donor GPU A/B frame, no admissible matched capture, no COORD ruling; parity UNVERIFIED; no approximation and no parity claim.*
