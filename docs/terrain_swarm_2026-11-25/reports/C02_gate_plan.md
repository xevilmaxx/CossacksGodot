---
id: C02-GATE-PLAN-01
title: "Exact integration gate COORD must run after B01–B06 land"
area: terrain swarm / QA planning
owner: C02 (QA planning, READ-ONLY)
created: 2026-11-25
status: PLAN_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB__NO_DONOR_ACCESS
scope: "This report only. No .gd/.gdshader/config/test/fixture/tool edit; no Godot job submitted/cancelled/reset/unwedged/acked; no donor execution or copy. All commands below are proposed, not executed. C04 §10's four mandatory rows (G-Q0/G-Q1/G-A0/G-G0) were folded in by this follow-up; C04's file was not edited."
labels: [observed, derived, inferred, UNVERIFIED]
snapshot_caveat: "At write time no B01–B06 report and no A11/A09 report had landed (reports dir listing: observed). All job ids below are NEW and unique; ticket numbers in cited historical reports are point-in-time only. The CAP-3 probe atoms proposed in D03/E04 were absent from variant3d/tests/ at this read (observed) — CAP-3 is blocked until COORD lands them."
sources_read:
  - docs/terrain_swarm_2026-11-25/CHARTER.md
  - docs/terrain_swarm_2026-11-25/SWARM_BOARD.md
  - docs/terrain_swarm_2026-11-25/reports/C04_visual_review.md (incl. §10 hand-off addendum)
  - docs/terrain_swarm_2026-11-25/reports/D03_selection_probe.md
  - docs/terrain_swarm_2026-11-25/reports/E04_ghost_qa.md
  - docs/terrain_swarm_2026-11-25/reports/A12_config_knobs.md
  - docs/coord_swarm_2026-11-25/TEST_MATRIX.md
  - docs/coord_swarm_2026-11-25/FINAL_CHECKLIST.md
  - docs/coord_swarm_2026-11-25/reports/FINAL_GATE_PLAN_01.md
  - docs/coord_swarm_2026-11-25/reports/P0_FRESH_CAPTURE_01.md
  - docs/coord_swarm_2026-11-25/reports/P0_GATE_01.md
  - docs/coord_swarm_2026-11-25/reports/RELIEF_VISUAL_01.md
  - variant3d/tools/godot_runner.py
  - variant3d/tools/smallmap_capture.py
  - variant3d/tools/terrain_ab_metric.py
  - variant3d/tests/t_render_mode.gd
  - variant3d/README.md
  - README.md
---

# C02 — integration gate plan (COORD, after B01–B06 land)

## 0. Authority and labels

This is a **plan only**. Nothing here was run and nothing here may be weakened. Labels follow
the charter (`CHARTER.md:55-69`): **OBSERVED** = file/tool fact read for this plan;
**DERIVED** = control-flow or arithmetic consequence; **INFERRED** = plausible reading with a
caveat; **UNVERIFIED** = cannot be proven (no donor GPU A/B frame exists, no fresh runner poll
was issued by this worker).

Binding rules inherited from the charter and the coord-swarm gate docs:

| Rule | Source |
|---|---|
| One Godot at a time; **only** `python variant3d\tools\godot_runner.py run --id <UNIQUE> …`; never direct `godot`; Windows `python`, not `python3`; PowerShell `;` not `&&` | `CHARTER.md:63,69`; `TEST_MATRIX.md:70-72`; `FINAL_GATE_PLAN_01.md:47-49`; `variant3d/README.md:61-70` |
| Query `status` before submitting; queue must be quiet (`pending=0`, lock free, 0 live Godot) | `CHARTER.md:64-65`; `FINAL_GATE_PLAN_01.md:80-88`; `FINAL_CHECKLIST.md:238-250` |
| Never weaken an assertion, lower a threshold, delete `expected_pre_fix_failure`, or rerun a failure hoping for green | `CHARTER.md:59-62`; `TEST_MATRIX.md:60-68` |
| Windowed captures only — headless = `SKIP_CAPTURE` / `passed=false`, **not** PASS; `SCRIPT ERROR == 0` is mandatory | `TEST_MATRIX.md:62-64`; `FINAL_GATE_PLAN_01.md:123-125,199-201` |
| No synthetic dither/noise/luminance field (S-25-09); no invented donor constants; label `PORT APPROX` | `CHARTER.md:59-62`; `README.md:344-351` |
| Second agent re-checks each capture; owner never self-certifies; metrics never override visual A/B | `TEST_MATRIX.md:58-59,73-75`; `CHARTER.md:122-130` |
| CAP-3 integrity: quad verdicts need the `input_ctl`-inclusive capture path; blank/missing/root-texture readback is UNVERIFIED, never a fabricated PASS | `C04_visual_review.md:220-229` (§10 G-Q0/G-Q1), `:72,81-82`; `D03_selection_probe.md:70-88` |
| Config overlays cannot attribute `uv_repeat`/`mask_to_alpha`; ghost stage not config-reachable | `C04_visual_review.md:220-229` (§10 G-A0/G-G0), `:143`; `A12_config_knobs.md:120-121,134-139,152-156` |
| `app/**` untouched; 2D tooling is **not** a 3D gate | `TEST_MATRIX.md:48-51,66`; `FINAL_CHECKLIST.md:451-478` |

**C04 §10 hand-off (OBSERVED, folded in by this follow-up):** C04 explicitly declined to edit
this file under disjoint ownership and asked COORD to relay four mandatory gate rows —
G-Q0 (capture path), G-Q1 (readback integrity), G-A0 (config-overlay validity), G-G0
(ghost-stage reachability) — at `C04_visual_review.md:220-229`. They are applied here in
§2 G3b and §3, with no change to C04's file.

**B01–B06 owned files (OBSERVED from `SWARM_BOARD.md:64-73` and the B dispatch prompts):**

| Ticket | Sole edited file | Gate proxy used below |
|---|---|---|
| B01 | `variant3d/shaders/terrain_tileindex.gdshader` | no `.gd` script exists → headless atom smoke + shader compile in the windowed P0 capture |
| B02 | `variant3d/scripts/tile_atlas_loader.gd` + atlas `.import` files | `--check-only` on the loader; static `.import` check; atlas-mode fallback exercised by selftest |
| B03 | `variant3d/scripts/game.gd` | `--check-only` on `game.gd`; determinism re-proved by selftest |
| B04 | `variant3d/scripts/world3d_terrain.gd` | `--check-only` on `world3d_terrain.gd`; mesh invariants re-proved by selftest/P0 atom |
| B05 | `variant3d/scripts/input_controller.gd` | `--check-only` on `input_controller.gd`; drag semantics re-proved by uitest/selftest |
| B06 | `variant3d/scripts/world3d_entities.gd` | `--check-only` on `world3d_entities.gd`; ghost stage visual proof belongs to C04 CAP-3 (G-G0: code path, not config) |

## 1. Pre-flight (G0) — do this BEFORE the first job

Windows PowerShell, from the repository root
`C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3`. Every command is one line;
do not chain with `&&`.

```
python variant3d\tools\godot_runner.py status
Get-CimInstance Win32_Process -Filter "Name like 'Godot%'" | Select-Object ProcessId,CommandLine
New-Item -ItemType Directory -Force -Path "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\c02g" | Out-Null
```

**PASS pre-flight (all required):** `pending=0 []`, `godot.lock=free`, `now_serving == next_ticket`,
and zero live Godot processes (an empty `Get-CimInstance` result). If a job is still queued or
running, **wait — do not submit** (`FINAL_GATE_PLAN_01.md:92-96`). A held lock with a live owner
is normal churn, not a defect; a `DIRTY` `assert_clean` during churn is likewise expected and
must not be signed (`FINAL_GATE_PLAN_01.md:166-169`).

Also confirm ownership is closed before starting (cross-ref C03): each B owner's report has
landed, each backup `inbox/backup/<file>.bak-B0X` exists, and no builder still has an
in-flight edit to a file under test (`SWARM_BOARD.md:84-91`; `FINAL_CHECKLIST.md:94-118`).

## 2. Ordered, copy-pasteable gate sequence

Submit **one job at a time, in this order**. Re-run `status` after every job's result JSON
appears. Every `--id` below is **new and unique** — never reuse an id already present in
`variant3d/.godot_queue/results/` or `status.json`; the FIFO runner serialises jobs but
telemetry keys on the id, and a reused id makes the evidence ambiguous
(`godot_runner.py:115-129,196-206`; `CHARTER.md:63`).

### G1 — headless parse/smoke, one per edited script (6 jobs)

`--check-only` proves **parsing only**, never runtime (`FINAL_CHECKLIST.md:164-169`;
`CONFIG_PIPELINE.md:310`). Any non-zero exit, `SCRIPT ERROR`, or parse line is a hard FAIL.

```
python variant3d\tools\godot_runner.py run --id c02g-parse-b01-shader --timeout 180 -- --headless --path variant3d --script res://tests/t_terrain_only.gd -- --config "C:/Users/Maxym.Oboyshev/Documents/Craft Anything/cossacks-3-3/variant3d/tests/fixtures/small_map_64.json"
python variant3d\tools\godot_runner.py run --id c02g-parse-b02-atlas --timeout 180 -- --headless --path variant3d --check-only --script res://scripts/tile_atlas_loader.gd
python variant3d\tools\godot_runner.py run --id c02g-parse-b03-game --timeout 180 -- --headless --path variant3d --check-only --script res://scripts/game.gd
python variant3d\tools\godot_runner.py run --id c02g-parse-b04-terrain --timeout 180 -- --headless --path variant3d --check-only --script res://scripts/world3d_terrain.gd
python variant3d\tools\godot_runner.py run --id c02g-parse-b05-input --timeout 180 -- --headless --path variant3d --check-only --script res://scripts/input_controller.gd
python variant3d\tools\godot_runner.py run --id c02g-parse-b06-entities --timeout 180 -- --headless --path variant3d --check-only --script res://scripts/world3d_entities.gd
```

Notes (OBSERVED/DERIVED):

- **B01** owns a `.gdshader`, not a `.gd` script, so no `--check-only --script` applies. The
  headless atom run parses the material-construction path and compiles the shader; expect
  `SKIP_CAPTURE` / `passed=false` because it is headless — that is **not** a gate PASS, only a
  parse/compile smoke. `SCRIPT ERROR == 0` and no shader compile error in stderr are required;
  runtime proof is G2.
- **B02** additionally requires a static `.import` check: atlas mode fallback
  `single → split → array` and manifest semantics must be unchanged (B02 dispatch prompt);
  record the `grep`/diff of the touched `.import` files. The headless smoke alone does not
  validate import flags.
- After each job run:
  ```
  python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\<ticket>_<job-id>\stderr.txt
  ```
  Replace `<ticket>` with the actual ticket from `status`/the result path. Require
  `script_error_lines: 0`. (`smallmap_capture.py:50-58`; `P0_FRESH_CAPTURE_01.md:114-120`.)

### G2 — 64² windowed P0 capture (CAP-1)

Proven launch shape from `P0_FRESH_CAPTURE_01.md:51-65` and `FINAL_GATE_PLAN_01.md:126-130`
(OBSERVED). No `--headless`; PNG passed as a user arg after the second `--`; fixed 64² harness,
seed 20261113, fixed camera, 1280×720, capture after ~10 frames (`TEST_MATRIX.md:29-36`).

```
python variant3d\tools\godot_runner.py run --id c02g-cap1-p0-64 --timeout 300 -- --path variant3d --script res://tests/t_terrain_only.gd -- --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/c02g/cap1_p0_64.png" --png "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/c02g/cap1_p0_64.png"
```

Read-only verification (run after the result JSON exists):

```
python variant3d\tools\smallmap_capture.py stats "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/c02g/cap1_p0_64.png"
python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\<ticket>_c02g-cap1-p0-64\stderr.txt
python variant3d\tools\terrain_ab_metric.py "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/c02g/cap1_p0_64.png" --json
```

`terrain_ab_metric.py` is a **smoke metric, not a gate** — its own header says
`SMOKE METRIC - heuristic only, NOT a fidelity gate or donor proof`
(`terrain_ab_metric.py:24-32,60`). Copy its numbers verbatim into the review record; never
let them erase a visible defect (`C04_visual_review.md:131-142`). If main's blank detector
refuses the final PNG, open the `.png.raw.png` sidecar and record the `screenshot capture diag`
line (`camera_current=true`, `world_parent=Screenshot3DViewport`, 1280×720)
(`RELIEF_VISUAL_01.md:98-123`; `C04_visual_review.md:74-82`).

C04's CAP-1 prefers a real generated 64² boot frame rather than the P0 stub
(`C04_visual_review.md:70`). If COORD needs the full C04 sign-off, take it as a **separate
job with its own unique id** `c02g-cap1-realboot` using the proven main-saver form
(`RELIEF_VISUAL_01.md:70-78`) with `--config <ABS>\small_map_64.json` and
`--screenshot-frames 10`. The P0 atom frame above remains the task-required 64² P0 capture
and is an auxiliary control for C04, not a substitute for a missing real-boot frame.

### G3 — real-map windowed capture (CAP-2)

Same windowed command form with the **real map config under review** (no 64² dimension
override unless that map is the subject); fixed seed, fixed camera, 1280×720, capture after
~10 frames (`CHARTER.md:124-127`; `SWARM_BOARD.md:89`; `C04_visual_review.md:71`;
`RELIEF_VISUAL_01.md:70-85`). The shipped `variant3d/config.json` is the real map; do not
edit it to make a capture.

```
python variant3d\tools\godot_runner.py run --id c02g-cap2-realmap --timeout 300 -- --path variant3d -- --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/c02g/cap2_realmap.png" --screenshot-frames 10 --timeout 120
```

Optional donor-scale arm — create a **Temp** `--config` overlay (never edit the shipped
config), then submit with a new unique id `c02g-cap2-320`. Safe keys from `A12_config_knobs.md:107`
are `gameplay.map_width_tiles` / `map_height_tiles` (min 16):

```
Set-Content -Path "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\c02g\real_320.json" -Value '{"gameplay":{"map_width_tiles":320,"map_height_tiles":320}}'
python variant3d\tools\godot_runner.py run --id c02g-cap2-320 --timeout 300 -- --path variant3d -- --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/c02g/cap2_320.png" --screenshot-frames 10 --config "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/c02g/real_320.json" --timeout 120
```

Do **not** put `uv_repeat` or `mask_to_alpha` in any overlay and claim an A/B from it: those
uniforms have **no config bridge** in `_tileindex_material()` (`A12_config_knobs.md:120-121,152-156`;
`C04_visual_review.md:143`; **G-A0** at `C04:226`). Verify G3 with `stats`, `scan-stderr` and
`terrain_ab_metric.py` exactly as in G2, substituting the CAP-2 PNG/ticket.

### G3b — CAP-3 interaction frames with the four C04 §10 hard gates (G-Q0/G-Q1/G-A0/G-G0)

C04 requires a **frame sequence, five frames**: `before.png`, `during.png`, `after.png`
(selection quad) and `ghost_valid.png`, `ghost_invalid.png` (last-stage ghost at a valid then
blocked site), with a `frames.json` recording per-frame sim time, mouse screen position, drag
start/current, overlay visible + rect, `build_ghost_sid`, requested stage, ghost
visible/valid/position (`C04_visual_review.md:72`; CAP-3). **CAP-3 is not runnable from existing
atoms:** neither `variant3d/tests/t_select_rect_capture.gd` (D03) nor
`variant3d/tests/t_ghost_final_stage.gd` (E04) existed in `variant3d/tests/` at this read
(OBSERVED). COORD must land/provide those atoms before submitting these jobs; do **not**
substitute main's saver, `t_select_rect.gd`'s no-PNG run, or a single still.

Proposed windowed submissions (unique ids; Windows `python`; one at a time; the two atoms are
proposals in D03/E04, so confirm the on-disk script path first):

```
python variant3d\tools\godot_runner.py run --id c02g-cap3-quad --timeout 300 -- --path variant3d --script res://tests/t_select_rect_capture.gd -- --config "C:/Users/Maxym.Oboyshev/Documents/Craft Anything/cossacks-3-3/variant3d/tests/fixtures/small_map_64.json" --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/c02g/cap3_selquad_menu_skip.png"
python variant3d\tools\godot_runner.py run --id c02g-cap3-ghost --timeout 300 -- --path variant3d --script res://tests/t_ghost_final_stage.gd -- --config "C:/Users/Maxym.Oboyshev/Documents/Craft Anything/cossacks-3-3/variant3d/tests/fixtures/small_map_64.json" --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/c02g/cap3_ghost_valid.png" --no-ghost-png "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/c02g/cap3_ghost_cancelled.png"
```

Launch forms taken verbatim from `D03_selection_probe.md:249-259` and
`E04_ghost_qa.md:107-112,808` (OBSERVED). In the D03 atom, reparent the live
`sel_rect_overlay` into `main.capture_view3d` during configure and record the parent in the
result JSON (`D03:70-83,124`); `--screenshot` is the menu-skip flag, not the quad frame name.

**Frame-name caveat (OBSERVED/UNVERIFIED):** the E04 proposal saves one PNG during placement
(`--screenshot`) and `--no-ghost-png` is the **cancelled** frame; its `ghost_tint_blocked`
check is structural only (`E04_ghost_qa.md:83,112,619`). It does **not** emit `ghost_invalid.png`
by itself. COORD must extend the atom (or use a separate blocked-site capture with a new unique
id) to produce a real `ghost_valid.png` **and** `ghost_invalid.png` at valid vs blocked sites.
Never relabel the cancel frame as "invalid": a missing `ghost_invalid.png` is UNVERIFIED → FAIL
for C04 §7 item 8, not a PASS inferred from `ghost_tint_blocked`.

**The four mandatory rows, applied here:**

- **G-Q0 — capture-path gate (D03 Trap A).** No quad PASS may come from main's saver path:
  `Screenshot3DViewport` reparents only `world` + `camera`, **not** `input_ctl`. Require the
  result JSON to prove `ov.get_parent() == capture_view3d`, `run_mode=windowed_real_input`,
  `headless=false`, both viewports `[1280,720]`, `event_coord_scale=[1,1]`
  (`D03:315`; `C04:72,81`), plus D03 pixel assertions (≥3/4 edge midpoints and ≥2/4 corners
  marquee-coloured inside `expected.grow(2)`, centre matches `before.png` within 8/255,
  configured RGBA `[1,1,0,1]`, quad hidden in `after.png`; `C04:108`, `D03:192-222,309-325`).
  A **quad-less saver frame is `UNVERIFIED (WRONG CAPTURE PATH)`** — neither "quad broken"
  nor PASS (`C04:224` → §10 item 1; `C04:123`).
- **G-Q1 — readback-integrity gate (D03 Trap B).** Under `gl_compatibility`, a root-window
  texture read (`root.get_texture().get_image()`) comes back blank; it is **forbidden as
  evidence**. Null/empty image, wrong size (≠1280×720), transparent/null first pixel, missing
  PNG, or headless `SKIP_CAPTURE` → `UNVERIFIED (NO/BLANK PNG)` and gate **FAIL** for that
  required item; no fabricated PASS from a green JSON or node state (`C04:225` → §10 item 2;
  `C04:82`, `D03:84-88,169-185,263-278`). Prefer the real GPU frame from `capture_view3d`;
  if main's blank detector refuses the final write, use the `.png.raw.png` sidecar **only**
  with the printed `screenshot capture diag` (`camera_current=true`,
  `world_parent=Screenshot3DViewport`, 1280×720) recorded (`C04:77`, `RELIEF_VISUAL_01:98-123`).
- **G-A0 — config-overlay validity gate (A12 K1/K2).** `uv_repeat` and `mask_to_alpha` are
  shader uniforms with no config bridge (`world3d_terrain.gd:682-721` binds neither); overlay
  keys are unread. Any arm claiming a visual effect from those `--config` keys records
  attribution `UNVERIFIED` **unless** an additive key **and** one `set_shader_parameter(...)`
  binding line are confirmed, with seed/camera/`start_zoom` pinned and `--dump-config` logged
  per arm (`C04:226` → §10 item 3; `C04:143`; `A12:120-121,152-156`). G3's `real_320.json`
  arm uses only `gameplay.map_width_tiles`/`map_height_tiles`, which are bound
  (`A12:107`) — it is a map-size arm, **not** a shader-uniform arm.
- **G-G0 — ghost-stage gate (A12 K8).** The final/completed stage is **not reachable by any
  existing config key**: `world3d_fx.gd:645` hard-calls stage `"1"` (A12 K8 is a *proposal*
  only). Gate evidence must come from the **code/atom that resolves the final-stage mesh**
  (B06's `world3d_entities.gd` path + the E04 atom's structural resource-identity assertions),
  never from an overlay key (`C04:227` → §10 item 4; `C04:143`; `A12:134-139`). PASS requires
  `ghost_valid.png` / `ghost_invalid.png` to show a translucent silhouette of the
  **last/completed** stage — green valid / red blocked, alpha ≈0.4, pixel-honest footprint,
  cleared on cancel/placement — and **FAIL** for a stage-1 foundation, bare footprint quad,
  opaque/offset/lingering ghost, or an off-screen target (`UNVERIFIED` → FAIL; `C04:108,175`).

Read-only checks after the frames exist:

```
Get-ChildItem "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\c02g\cap3_*" | Select-Object Name,Length
python variant3d\tools\smallmap_capture.py stats "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/c02g/cap3_ghost_valid.png"
python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\<ticket>_c02g-cap3-quad\stderr.txt
```

### G4 — fold in A11's visual metric targets (conditional, no Godot job)

**Check once, at gate time:**

```
Test-Path "docs\terrain_swarm_2026-11-25\reports\A11_reference_metrics.md"
```

At plan-writing time this was `False` (OBSERVED — the A11 session was still live). Apply this
rule verbatim:

- **If A11 has landed:** read
  `docs/terrain_swarm_2026-11-25/reports/A11_reference_metrics.md` completely. Copy into the
  gate record, **verbatim**, the 2–3 numbers A11 names as most diagnostic and the direction
  it says a fix should move them (A11's scope: ground-region mean/median RGB, HSV saturation,
  luma histogram spread, and multi-scale block variance at 8/16/32/64 px, with ratios against
  `p0_final_formula.png`). Measure the same statistics on CAP-1 and CAP-2 using **A11's own
  ground-ROI rule and Pillow method** (do not compare whole frames against cropped donor
  stills). PASS requires each named number to move in A11's stated direction relative to the
  pre-fix baseline and, where A11 gives an explicit target range, to land inside it; FAIL if
  any named number moves the wrong way or stays flat while C04 R1–R4 still show a defect.
  If A11 marks a number `UNVERIFIED`, do **not** gate on it. Record the camera/zoom confound
  explicitly: a donor still is not a matched GPU A/B frame, so these are calibration targets
  only — `donor parity` stays **UNVERIFIED** (`A11` dispatch scope; `CHARTER.md:57-58`;
  `TEST_MATRIX.md:73-74`).
- **If A11 has not landed:** record `A11 numeric targets: UNVERIFIED (report absent)`, use the
  hard thresholds in §3, and **do not invent substitute numbers**. A green metric never
  compensates for a visible artifact (`C04_visual_review.md:137-141`).

### G5 — variant selftest 29/29

```
python variant3d\tools\godot_runner.py status
python variant3d\tools\godot_runner.py run --id c02g-selftest --timeout 300 -- --headless --path variant3d -- --self-test variant3d/selftest.json
```

Accept only a **fresh** result: `variant3d/selftest.json` `"passed": true`, **29/29**, runner
`status=ok` / exit 0, `SCRIPT ERROR == 0`. Per-job 29/29 from older tickets is not enough
(`TEST_MATRIX.md:27`; `FINAL_GATE_PLAN_01.md:161-164`; `FINAL_CHECKLIST.md:196-206`). Confirm no
assertion, threshold, seed or `expected_pre_fix_failure` marker was changed to obtain it;
in particular B03's determinism and B04's mesh invariants must hold
(`surface_count=1`, `vertex_count=4096`, `triangle_count=7938`, `uv2_count=4096`,
`flat_grid_promoted==0` — `TEST_MATRIX.md:33-40`; B04 dispatch prompt).

### G6 — variant uitest 17/17

```
python variant3d\tools\godot_runner.py status
python variant3d\tools\godot_runner.py run --id c02g-uitest --timeout 300 -- --headless --path variant3d -- --ui-test variant3d/uitest.json
```

Accept `variant3d/uitest.json` `"passed": true`, **17/17**, `status=ok` / exit 0,
`SCRIPT ERROR == 0` (`TEST_MATRIX.md:27`; `FINAL_GATE_PLAN_01.md:165`;
`FINAL_CHECKLIST.md:207-213`). This re-proves the B05 input path did not regress UI/drag
semantics.

### G7 — `t_render_mode`

```
python variant3d\tools\godot_runner.py status
python variant3d\tools\godot_runner.py run --id c02g-render-mode --timeout 120 -- --headless --path variant3d --script res://tests/t_render_mode.gd
```

Accept runner `status=ok` / exit 0 and `variant3d/tests/results/t_render_mode.json`
`"passed": true`, `"result": "PASS"`, `"seam_missing": false`, all checks PASS
(`README.md:126`; `FINAL_CHECKLIST.md:128-129`; `variant3d/tests/t_render_mode.gd:44-60,63-90`).
`render_mode_default_2d` is a **hard** gate: the 2D default must not be broken by the 3D work
(`t_render_mode.gd:5,79-80`). Do not weaken this test.

### G8 — queue CLEAN and final status (read-only; no Godot job id)

```
python variant3d\tools\assert_clean.py --json
python variant3d\tools\godot_runner.py status
```

Accept **all** of: `assert_clean.py --json` exit 0 with `"verdict": "CLEAN"`, `reasons=[]`,
`processes.count=0`, free lock, `failures=[]` (no unacked `timed-out`/`error`/`skipped` jobs);
and `godot_runner.py status` `pending=0`, `now_serving == next_ticket`, bounded max wait
(`FINAL_GATE_PLAN_01.md:80-88,166-170`; `FINAL_CHECKLIST.md:236-283`). **Never** use
`ack` to manufacture CLEAN: an ack is only for a genuinely retired diagnostic with an
explicit reason, and it must not hide a gate failure (`FINAL_CHECKLIST.md:261-269`). If any
result status is `timed-out`, `error`, `lock-timeout` or `skipped`, treat the gate as not
ready and route it to the owning ticket.

### G9 — 2D `app/**` gates untouched (verify; do not modify)

```
git status --porcelain -- app/
git diff --stat -- app/
```

Expect both empty. `app/**` is never edited by this swarm (`TEST_MATRIX.md:66`;
`FINAL_CHECKLIST.md:451-478`; `CHARTER.md:129`). Prior CONFIRMED_GREEN 2D artifacts are
tickets 1348 (`qa2d-selftest`, 29/29) and 1349 (`qa2d-uitest`, 17/17) per
`FINAL_CHECKLIST.md:457-469`. If COORD elects to re-prove them, use the **app** runner with
brand-new unique ids `c02g-app-selftest` / `c02g-app-uitest`
(`README.md:117-121`) and **never concurrently** with any variant runner job:

```
python app\tools\godot_runner.py run --id c02g-app-selftest --timeout 300 -- --headless --path app -- --self-test app/selftest.json
python app\tools\godot_runner.py run --id c02g-app-uitest --timeout 240 -- --headless --path app -- --ui-test app/uitest.json
python app\tools\assert_clean.py --json
```

## 3. Pass/fail thresholds (all required; none optional)

| Step | HARD PASS threshold | FAIL / stop condition |
|---|---|---|
| G0 pre-flight | `pending=0`, lock free, 0 Godot, ownership closed | Submit nothing; wait or resolve ownership first |
| G1 parse smokes ×6 | runner `ok`, exit 0; `script_error_lines: 0`; no parse shader error for B01; B02 `.import` flags/fallback unchanged | Any exit ≠ 0, `SCRIPT ERROR`, parse line or changed atlas fallback → stop, route to owning B ticket |
| G2 CAP-1 64² P0 | windowed PNG (or raw sidecar + diag) 1280×720, non-blank; `SCRIPT ERROR == 0`; `non_black_fraction ≥ 0.9`; `mean_luma ≥ 40`; `max_luma ≥ 100` (strict PORT APPROX gates, `P0_GATE_01.md:84-98`); `full_width_dark_rows` **recorded diagnostic only** on this water-free frame (`P0_GATE_01.md:74-77`); C04 R1–R3 clean, R4 organic variation | Any regular diagonal streak/moiré, grid/checker/repeated patch, repeated dark blotch, uniform olive field, blank/headless PNG, `SCRIPT ERROR > 0`, luma below floor → FAIL. Do not lower 40/100 |
| G3 CAP-2 real map | windowed 1280×720 PNG/sidecar, `SCRIPT ERROR == 0`; `full_width_dark_rows == 0` **where water is present** (`METRIC_01:86-89,99-104`; `C04:107`); no new seams/z-fighting/black rows or white stepped bands (R5); shore natural (R6); no grid/streaks/blotches (R1–R3); relief/cliffs readable; large-scale variation (R4) | Any of those defects, or a missing/blank/wrong-path capture. If the chosen real map has **no water**, record dark rows as `RECORDED_NOT_APPLICABLE` and keep both readings — do not flip or delete the predicate (`C04:139`) |
| G3b CAP-3 five frames | all five PNGs `before` / `during` / `after` / `ghost_valid` / `ghost_invalid` exist with `frames.json` per-frame metadata; windowed, 1280×720, `SCRIPT ERROR == 0`; atoms `t_select_rect_capture.gd` + `t_ghost_final_stage.gd` landed first | Missing atom, missing frame, single still, or no `frames.json` → CAP-3 UNVERIFIED → FAIL of C04 §7 items 1/7/8. Do not substitute main's saver or a headless run |
| **G-Q0** (capture path) | result JSON proves `ov.get_parent() == capture_view3d`, `run_mode=windowed_real_input`, `headless=false`, viewports `[1280,720]`, `event_coord_scale=[1,1]`; D03 pixel assertions pass on `during.png`; quad hidden in `after.png` | Quad-less saver frame → `UNVERIFIED (WRONG CAPTURE PATH)`, never "quad broken" and never PASS (`C04 §10:224`; `D03:315`) |
| **G-Q1** (readback integrity) | real GPU frame from `capture_view3d`; non-null/non-empty 1280×720 image, non-transparent first pixel; raw sidecar only with `camera_current=true` diag | `root.get_texture().get_image()` evidence, blank/null/wrong-size/missing PNG, or headless `SKIP_CAPTURE` → `UNVERIFIED (NO/BLANK PNG)` and FAIL; no PASS from green JSON/node state (`C04 §10:225`) |
| **G-A0** (overlay validity) | only bound keys used (`gameplay.map_width_tiles`/`map_height_tiles`); seed/camera/`start_zoom` pinned; `--dump-config` logged per arm | `uv_repeat`/`mask_to_alpha` overlay claim with no additive key **and** `set_shader_parameter(...)` binding → attribution `UNVERIFIED` and FAIL for that arm (`C04 §10:226`; A12 K1/K2) |
| **G-G0** (ghost stage) | code/atom resolves the **final** mesh; `ghost_valid`/`ghost_invalid` show translucent last-stage silhouette, green/red, pixel-honest footprint, cleared on cancel/place | Stage-1 foundation, bare quad, opaque/offset/lingering ghost, off-screen target (UNVERIFIED), or an overlay-only "stage" key → FAIL (`C04 §10:227`; A12 K8) |
| G4 A11 numbers | If A11 landed: its 2–3 named numbers move in its stated direction on both captures, inside any explicit target range, measured on A11's ROI; camera/zoom confound stated; parity stays UNVERIFIED. If absent: `UNVERIFIED`, hard thresholds only | Wrong-direction/flat number with residual visual defect → FAIL. Never invent numbers; never call a matched-scene ratio donor parity |
| G5 selftest | fresh `passed=true`, **29/29**, exit 0, no weakened assertion/marker | Anything less, stale JSON, or a weakened check → FAIL |
| G6 uitest | fresh `passed=true`, **17/17**, exit 0 | Anything less → FAIL |
| G7 t_render_mode | fresh `passed=true`, `result=PASS`, `seam_missing=false`, all checks PASS, 2D default intact | Any FAIL check or `SEAM_MISSING` → FAIL |
| G8 CLEAN | `verdict=CLEAN`, exit 0, `reasons=[]`, `failures=[]`, 0 processes, free lock, `pending=0` | `DIRTY`, unacked failure job, live process, held lock → not ready |
| G9 2D gates | `app/` byte-untouched; optional re-runs 29/29 + 17/17 CLEAN | Any `app/` diff or red 2D gate → FAIL |

**Overall:** the integration gate is PASS only if G0–G9 **and the four mandatory rows
G-Q0 / G-Q1 / G-A0 / G-G0** all PASS **and** a second agent has signed the C04 visual review
against all three capture sets (`C04_visual_review.md:162-189,220-229`). A green JSON never
substitutes for the second-agent visual read; missing evidence is FAIL, never a fabricated
PASS (`C04:66,164`). Every UNVERIFIED required item — including a wrong-capture-path frame,
a blank readback, an unbound-uniform overlay arm and a config-only ghost claim — is FAIL for
that item (`C04 §10:224-227`). Donor parity remains **UNVERIFIED** in every case — this is a
truthful *system* gate, not a parity certificate (`CHARTER.md:57,124-130`;
`FINAL_GATE_PLAN_01.md:208-214`).

## 4. If a job is stuck — what COORD may and may not do

The runner already owns timeout and recovery (`godot_runner.py:1-33,294-321,324-378,453-459`).
**Never kill a Godot process by name** — no `taskkill /IM godot.exe`, no
`Stop-Process -Name Godot`, no `pkill -9 -f godot`. That destroys another job's child and
breaks the mutual-exclusion guarantee; the runner kills **only PIDs its own job spawned**
(`godot_runner.py:261-273`, `reap_spawned_godot`).

1. **Diagnose first** — `python variant3d\tools\godot_runner.py status` and the job's
   `variant3d\.godot_queue\results\<ticket>.json`. Statuses are `queued`, `running`, `ok`,
   `failed`, `timed-out`, `skipped`, `lock-timeout`, `error`
   (`godot_runner.py:397-409,451-461,483-485`). A job older than its `--timeout` with no
   progress is a candidate, not proof.
2. **Let the built-in hard timeout act** — `kill_tree()` uses `taskkill /PID <pid> /T /F` on
   Windows and reaps only that job's PIDs (`godot_runner.py:212-222,261-273,453-459`). Do not
   resubmit while the ticket is still `queued` or `running`.
3. **Dead holder / wedge** — the FIFO skips a holder whose PID is gone and reclaims a lock
   only when its recorded owner is dead (`STALE_SEC = 300`, `godot_runner.py:54,337-378`).
   If `now_serving` is pinned to a dead holder while **no Godot process is alive and the lock
   is free**, run:
   ```
   python variant3d\tools\godot_runner.py unwedge
   ```
   `unwedge` refuses to act while the lock is held or any Godot process is alive
   (`godot_runner.py:294-321`).
4. **Cancel a still-pending job only** — by ticket or by prefix; the serving job holding the
   lock is deliberately skipped:
   ```
   python variant3d\tools\godot_runner.py cancel --ticket <ticket>
   python variant3d\tools\godot_runner.py cancel --prefix c02g-
   ```
   (`godot_runner.py:555-583`). A cancelled/retried job must get a **new unique id**.
5. **Orphans that bypassed the runner** (e.g. a directly launched `godot`) — with COORD's
   explicit approval only:
   ```
   python variant3d\tools\godot_runner.py doctor
   ```
   It enumerates processes by PID via CIM and kills them by PID, then releases the lock
   (`godot_runner.py:512-538`) — it is not a name-based kill.
6. **Last resort, maintenance only** — `python variant3d\tools\godot_runner.py reset --yes`
   clears counter, serving, status, jobs and results (`godot_runner.py:541-552`). It destroys
   evidence; use only with owner authorisation and after saving the relevant result JSONs.
7. **Never** "fix" a stuck gate by lowering a threshold, flipping a marker, or rerunning a
   failure hoping for green (`TEST_MATRIX.md:60-68`; `FINAL_GATE_PLAN_01.md:182-201`). Record
   the exact failed assertion/stuck status and route it to the owning ticket.

## 5. Evidence record to leave behind

For every step save: job id + ticket, runner `status`/exit, wall/run times, result JSON path,
`stdout.txt`/`stderr.txt` paths, PNG path and 1280×720/non-blank confirmation, verbatim
`stats`, `scan-stderr` and `terrain_ab_metric.py --json` output, A11 target paragraph (if
landed), the **five CAP-3 frame paths + `frames.json` + overlay-parent/`event_coord_scale`
JSON fields (G-Q0)** + `screenshot capture diag` for any sidecar (G-Q1), the per-arm
`--dump-config` and binding-line check (G-A0), the final-stage mesh resolution proof (G-G0),
the second-agent reviewer id and verdict, and the final `assert_clean`/`status` snapshot.
Record every claim as OBSERVED / DERIVED / INFERRED / UNVERIFIED; donor parity stays
UNVERIFIED (`CHARTER.md:55-58`; `C04_visual_review.md:43-60,147-189,220-229`).

---

*End of C02-GATE-PLAN-01. Plan only — no code edit, no Godot job, no donor access, no queue
mutation. Execute only after B01–B06 reports have landed, C03 has confirmed backups and
disjoint ownership, and the D03/E04 CAP-3 atoms exist on disk. C04's §10 four rows were
folded in by COORD follow-up; C04's file was not modified by this worker.*
