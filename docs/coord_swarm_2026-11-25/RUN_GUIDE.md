---
title: RUN_GUIDE — launch and verify the 3D variant (owner-facing)
area: coord_swarm_2026-11-25
task_id: RUN-GUIDE-01
owner: documentation worker
date: 2026-11-25
status: living
audience: owner (cold-readable)
scope: documentation only — no code edits, no runner jobs launched by this worker
---

# RUN_GUIDE — launch and verify the 3D variant (`variant3d/`)

Run everything from the repo root `C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3` (`docs/variant3d/README.md:112`; `docs/COMMANDS.md:3`), with Windows `python`, not `python3` (`TEST_MATRIX.md:72`). Every command and rule below is cited; anything unverified is marked **UNVERIFIED**. Paths without a directory prefix are repo-root relative.

## 0. Two caveats before you start

1. **The launcher and `docs/variant3d/README.md` disagree about windowed launch.** The README (`:118-122`, a 2026-11-24 snapshot per `:16-17`) calls a runner job with `--stay` the "preferred path" for a windowed game. The actual `launch_variant3d.bat:4-12` says the opposite in detail: the runner redirects stdout/stderr, resolves Godot via bare `shutil.which("godot")` (here Godot is only a WinGet symlink, not on PATH), and calls `reap_spawned_godot()` which would kill the real game window. Also `--stay` is **not** a runner argument (no match in `variant3d/tools/godot_runner.py`; its commands are `run`/`status`/`doctor`/`reset`/`ack`/`unwedge` — `docs/COMMANDS.md:28-36`). **Follow the batch file for manual play; the README launch recommendation is stale.** Its test commands (`:129-158`) are fine.
2. **`app/` is the 2D shipping port; `variant3d/` is a separate project with its own runner spool** (`docs/variant3d/README.md:46-55`). Never mix their tools (§2).

## 1. Launch the game (windowed, manual play)

```bat
launch_variant3d.bat
```

Exact owner command (`docs/variant3d/README.md:110-116`). The batch `cd /d "%~dp0"` itself, so it works from the repo root or double-clicked (`launch_variant3d.bat:16`); it aborts if `variant3d\project.godot` is missing (`:18-22`), resolves Godot via `where godot`, then the WinGet link, then `%ProgramFiles%\Godot\godot.exe` (`:24-36`), then runs:

```bat
"%GODOT%" --path variant3d %*
```

(`launch_variant3d.bat:42-44`). Extra args are forwarded verbatim after `--path variant3d` (`:14,43-44`); which extras are valid is **UNVERIFIED** — do not add flags absent from `docs/COMMANDS.md`. If Godot is not found, install with `winget install GodotEngine.GodotEngine` (`:37`). `launch_3d.bat` is only a compatibility shim; its old `app/` terrain sandbox is **VISUAL FAIL — do not use for acceptance** (`docs/variant3d/README.md:123-125`; `launch_3d.bat:1-26`).

## 2. Gates (headless, variant runner only)

Agents/workers never call `godot` directly (`docs/COMMANDS.md:8-9,11-18`); use the variant runner with a fresh **unique `--id`** on every invocation (`docs/COMMANDS.md:32`). The owner launching manually uses §1; the owner *verifying* uses these. First-time checkout bootstrap (generates `variant3d/.godot/`):

```bat
python variant3d\tools\godot_runner.py run --id import --timeout 900 -- ^
  --headless --path variant3d --import
```

(`docs/variant3d/README.md:139-144`; `ASSET_IMPORT_01.md:40-42`; `STATUS_WAVE7_PHASE2.md:258-259`). The import job in `ASSET_IMPORT_01.md:54` added `--max-wait 1800`; that option exists (`godot_runner.py:574`). Queue health, then the three final gates (`FINAL_GATE_PLAN_01.md:154-159`):

```bat
python variant3d\tools\godot_runner.py status
python variant3d\tools\godot_runner.py run --id coord-final-selftest --timeout 300 -- --headless --path variant3d -- --self-test variant3d/selftest.json
python variant3d\tools\godot_runner.py run --id coord-final-uitest --timeout 240 -- --headless --path variant3d -- --ui-test variant3d/uitest.json
python variant3d\tools\assert_clean.py --json
```

Equivalent ids `variant-final-selftest` / `variant-final-uitest` appear in `docs/variant3d/STATUS_WAVE7_PHASE2.md:245-249`; per-atom tests use `--script res://tests/<module>.gd` instead of a selftest flag (`docs/variant3d/README.md:146-153`).

**Variant spool note.** The variant runner's spool is `variant3d/.godot_queue` (`variant3d/tools/godot_runner.py:47-53`); `status` prints that path (`:442`), and results land under `variant3d/.godot_queue/results/<ticket>_<id>/` (`ASSET_IMPORT_01.md:61,83-84`). The `python app\tools\godot_runner.py ...` examples in `docs/COMMANDS.md:42-57` are **2D**; do not use them for 3D (`docs/variant3d/README.md:154-159`). `variant3d/tools/assert_clean.py:34` on disk now reads the **variant** spool, confirmed by `CLEAN_02_variant_gate.md:108-116` (`history.total 411`, variant lock held); the "mis-wired to app spool" finding in `CLEAN_01_variant_clean.md` is **stale** — CLEAN-02 fixed it. Two stale *text* references are not behaviour: `assert_clean.py:16` remediation hint still names `app/tools/` (`CLEAN_02_variant_gate.md:135-138`) and `CLEAN_GATE.md:87` names `app/.godot_queue/results/`. Never run the **2D** `doctor` during a variant import: it kills Godot by name regardless of spool (`docs/variant3d/README.md:155-156`).

Pass criteria, all required: `variant3d/selftest.json` `"passed": true`, **29/29**; `variant3d/uitest.json` `"passed": true`, **17/17**; `assert_clean.py --json` → `CLEAN`, exit 0 (no live Godot process, free/young lock, no unacked timed-out/error/skipped jobs) (`FINAL_GATE_PLAN_01.md:161-169`; `STATUS_WAVE7_PHASE2.md:251-255`; `CLEAN_GATE.md:90-103`). A per-job 29/29 is not enough; the artifact must be green (`QA_AUDIT_01_implementation_claims.md:47-57` as cited at `FINAL_GATE_PLAN_01.md:162-164`). **Current artifact state (read 2026-11-25):** selftest `"passed": false`, 29 steps, failed step `build`; uitest `"passed": true`, 17 steps (`DEFAULTS_VERIFY_01.md:38,92,102`). So selftest is a **genuine red gate** until a fresh run flips it; do not weaken it (`TEST_MATRIX.md:67-68`).

## 3. Capture a 64² piece or a motion video

Recommended order for a cold run (`TEST_MATRIX.md:53-66`; `FINAL_GATE_PLAN_01.md:100-169`):

1. Run `python variant3d\tools\godot_runner.py status` — confirm the spool line and that the queue is quiet.
2. On a fresh checkout where `variant3d/.godot/` is absent, run the bootstrap import above, then re-check `status`.
3. Capture pieces in ladder order `P0 → P1 → P2 → P3 → C1 → C2 → C3 → C4 → S1`; stop at the first failing row, record the exact assertion and route it to the owning fix ticket (`TEST_MATRIX.md:60-61`).
4. Only then run selftest, uitest and `assert_clean.py --json` (FINAL) on a quiet queue; the 2D `app/**` gates must stay untouched and green (`TEST_MATRIX.md:65-66`).

Reuse the existing harness — `variant3d/tests/fixtures/small_map_64.json`, `Screenshot3DViewport`, seed `20261113`, fixed camera, 1280×720, capture after ~10 frames (`TEST_MATRIX.md:29-36`); do not build a new one. Rows are **windowed** (no `--headless`): headless gives `SKIP_CAPTURE` / `passed=false`, not PASS (`TEST_MATRIX.md:62-64`; `VID_CAP_01_capture.md:114`). The 2D files `t_shore_smoke.gd`, `t_water.gd`, `visual_tuning_test.gd`, `terrain_piece_render.py`, `tools/pieces/t6_*` are **not** 3D gates (`TEST_MATRIX.md:48-51`).

Still, P0 terrain-only (`FINAL_GATE_PLAN_01.md:126-130`, citing `P0_GATE_01.md:130-132`):

```bat
python variant3d\tools\godot_runner.py run --id <unique-id> --timeout 180 -- --path variant3d --script res://tests/t_terrain_only.gd -- --screenshot "<TEMP>/smallmap64_terrain_only.png" --png "<TEMP>/smallmap64_terrain_only.png"
```

S1 selection, real 64² boot through main's `--screenshot` path (`FINAL_GATE_PLAN_01.md:131-134`, citing `S1_INPUT_FIX.md:146-151`):

```bat
python variant3d\tools\godot_runner.py run --id <unique-id> --timeout 300 -- --path variant3d --script res://tests/t_select_rect.gd -- --config <ABS>\variant3d\tests\fixtures\small_map_64.json --screenshot <TEMP>\s1inputfix_smallmap64.png
```

Motion sequence, proven final shape (job 408, `VID_CAP_01_capture.md:119-134`):

```bat
python variant3d\tools\godot_runner.py run --id vidcap01-frames --timeout 360 -- ^
  --path variant3d --script res://tests/t_motion_capture.gd -- ^
  --config res://tests/fixtures/small_map_64.json ^
  --screenshot C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/vidqa/unused_flag.png ^
  --timeout 280
```

Pass `--config res://tests/fixtures/small_map_64.json`, **not** an absolute path containing spaces — that failed tickets 380/386 (`VID_CAP_01_capture.md:113`). `--screenshot` here is only the menu-skip flag; the atom writes `frame_000.png…` to the temp dir (`:127,143-153`). Assemble with `ffmpeg -framerate 4 -i frame_%03d.png -c:v libx264 -pix_fmt yuv420p motion.mp4` (`VIDEO_QA_PROTOCOL.md:36`; measured at `VID_CAP_01_capture.md:152`). Keep artifacts under `%LOCALAPPDATA%\Temp\opencode\...`, **never in the repo** (`VIDEO_QA_PROTOCOL.md:28`; `VID_CAP_01_capture.md:157`); build a Pillow contact sheet plus per-frame sidecar, keep raw frames until the verdict, and hold camera/seed/interval fixed (`VIDEO_QA_PROTOCOL.md:32-37`). After each row check the atom JSON plus `python variant3d\tools\smallmap_capture.py stats <PNG>` and `scan-stderr <job stderr>`, require `SCRIPT ERROR == 0`, and have a **second agent** re-check the capture — the owner never self-certifies visual review (`FINAL_GATE_PLAN_01.md:138-142`; `TEST_MATRIX.md:58,75`).

## 4. Expected warnings — NOT bugs

| What you see | Why expected | Evidence |
|---|---|---|
| `pose_source=donor_flat_root_morph`, `visual=UNVERIFIED`, "deliberate morph warning" | Rig semantics unreadable → sampled flat-root poses labelled `PORT APPROXIMATION — NOT DONOR PARITY`; a label, not a crash, and never "ported donor animation". | `anim3d.gd:32,63`; `VID_CAP_01_capture.md:172-173`; `STATUS_WAVE7_PHASE2.md:40`; `SWARM_BOARD.md:140`; `AUDIT3D_TRIAGE.md:36`; `PROGRESS.md:581`; `docs/variant3d/README.md:76-79` |
| `PORT APPROX` on FOV `17.27°`, world-XZ texgen, minimap `ArcTan`, P0 luma gates, snow white quad | Honesty labels for donor-unverified values; do not "fix" them for green. | `SWARM_BOARD.md:58,108,122,135,137`; `P0_GATE_01.md:154`; `TEST_MATRIX.md:45,67-68` |
| `assert_clean.py` → `VERDICT: DIRTY`, exit 1 while a job runs / lock held | Correct during swarm churn; a signable verdict needs a quiet queue. | `CLEAN_GATE.md:100-103`; `CLEAN_01_variant_clean.md:209-240`; `CLEAN_02_variant_gate.md:117-131`; `FINAL_GATE_PLAN_01.md:166-169` |
| Long FIFO wait; `now_serving` behind `next_ticket` | Serialized tickets, telemetry not hangs; `--max-wait` defaults 3600 s; a 284.53 s wait ended `ok`. | `docs/COMMANDS.md:20-26,33`; `godot_runner.py:574`; `ASSET_IMPORT_01.md:61-66` |
| Exit-time RID-leak `ERROR` lines | Pre-existing cleanup noise, not `SCRIPT ERROR`s; judge via `scan-stderr`. | `VID_CAP_01_capture.md:136-141` |
| History shows acknowledged/timed-out jobs | `ack`-ed failures are counted but skipped; `failed` excluded by D-13. | `CLEAN_GATE.md:86-88,95-98,105-113`; `CLEAN_02_variant_gate.md:113-116` |

## 5. Genuine failures — escalate

- **Parse / `SCRIPT ERROR`:** indentation must be TABS; check a dict-literal comma; restore `inbox/backup/<name>.bak2` and redo; for a hang use `--timeout 60` and read the first `SCRIPT ERROR` above the watchdog (`docs/COMMANDS.md:226-232`). Require `script_error_lines: 0` (`VID_CAP_01_capture.md:136-141`).
- **Missing `.ctex`:** `ERROR: Unable to open file: res://.godot/imported/mill_rotor.png-8777cf191d7418e8d37d5605c8135028.ctex` then `Failed loading resource: res://assets/models/anim/common/buildings/mill_rotor.png` at `world3d_entities.gd:1430 → :1458 → :1387` is a real windowed-run error (`ASSET_IMPORT_01.md:19-25`). Plain `--import` did not produce it (`:33,98,109-112`); likely cause is the intentional `variant3d/assets/models/anim/.gdignore` (`:123-129`, inference, not an engine log line). A graceful-fallback ticket was expected to stop the crash (`:134`) — whether it landed is **UNVERIFIED**. Never fabricate a ctex or widen `.gdignore` yourself (`:131-135`).
- **Red gates:** selftest not 29/29 or `passed:false` (currently the case, §2); uitest not 17/17; `assert_clean.py --json` DIRTY on a **quiet** queue; headless `SKIP_CAPTURE` / `passed=false` (`TEST_MATRIX.md:63`; `VID_CAP_01_capture.md:114`). Record the failed assertion and route it to the owning fix ticket; do not rerun hoping for green (`TEST_MATRIX.md:60-61`).

## 6. Current defaults and where they come from

Effective values (verified 2026-11-25): **Russia vs Bavaria (`rus`/`bav`), 240×240 Tiny, `mediterranean`, `hills`, fog off, `summer`, FFA / 2 players** (`DEFAULTS_VERIFY_01.md:49-57,116`; spot-check `variant3d/config.json:41-43,71-72`).

| Setting | Source |
|---|---|
| Interactive skirmish: `menu.gd` defaults emitted by `_emit_start()` and applied by `main.gd:270-367` | `DEFAULTS_VERIFY_01.md:47,51-57`; `CFG_01_skirmish_defaults.md:76-90` |
| Menu-skipping / headless: `config.json` overlay via `main.gd:176-177` merged over `config.gd`'s built-in `DEFAULT` (`config.gd:274-301`) | `DEFAULTS_VERIFY_01.md:47,72-77` |
| 240×240 committed in `config.json:41-42` by MAP-SMALL-01 (commit `f9dd8d16`) | `DEFAULTS_VERIFY_01.md:52,83` |
| Shape/relief: `menu.gd:55,64,71`; DEFAULT `config.gd:125,129` read at `:545,548`; donor keys `data.gd:293-336` | `DEFAULTS_VERIFY_01.md:53-54,73-77`; `CFG_01_skirmish_defaults.md:51-59` |
| Fog off: `config.gd:51,382,96,498`; `config.json:22`; `data.gd:55` | `CFG_01_skirmish_defaults.md:61-70`; `DEFAULTS_VERIFY_01.md:55` |

Two traps, both **not current bugs**: raw `gameplay.map_type: land` at `config.json:73` is not what a menu-skipping run applies — `config.gd:545` reads `gameplay.terrain_type` and the DEFAULT `mediterranean` survives the merge at `:274-301` (`DEFAULTS_VERIFY_01.md:70-77,D1:91`). Port Tiny 240 vs donor literal 256 is a deliberate accepted choice (`CFG_01_skirmish_defaults.md:38-49`; `DEFAULTS_VERIFY_01.md:94`). The third overlay `user://options.json` was not inspected — **UNVERIFIED** on this machine (`DEFAULTS_VERIFY_01.md:106-108`).

## 7. Troubleshooting

| Symptom | Meaning / action | Evidence |
|---|---|---|
| `godot.lock = HELD`, job never starts | Dead holder reclaimed after `STALE_SEC = 300`; don't kill a young lock. Use `python variant3d\tools\godot_runner.py doctor` for orphans; `reset --yes` is maintenance only; never the 2D `doctor` during a variant import. | `godot_runner.py:54,318-337`; `docs/COMMANDS.md:34-35,55-56`; `CLEAN_GATE.md:84-85`; `docs/variant3d/README.md:155-156` |
| Job sits in FIFO; waits grow | Normal serialization, not starvation. Read `status` (`now_serving`, max/mean wait); raise `--max-wait` only with evidence (ASSET-IMPORT-01 used 1800). | `docs/COMMANDS.md:20-26,33`; `godot_runner.py:574`; `ASSET_IMPORT_01.md:54,64` |
| `Unable to open file ... .ctex` / `Failed loading resource` | Genuine missing cache under a `.gdignore` tree; `--import` will not recreate it. Record the exact error and report it; do not fabricate files. | `ASSET_IMPORT_01.md:19-25,98,109-125,141` |
| `Parse Error` / `SCRIPT ERROR` | TABS not spaces; dict comma; restore backup; re-run with `--timeout 60`; scan stderr. | `docs/COMMANDS.md:226-232`; `VID_CAP_01_capture.md:136-141` |
| Near-black olive terrain (`mean_luma 13.271`, `full_width_dark_rows=720` in P0) | Known diagnosed P0 symptom: lighting term collapses under donor-sun math; residual luma factor partly UNVERIFIED. Record metrics, keep assertions, A/B with a constant-albedo control; do not call it PASS. | `TERRAIN_DARK_01.md:17,54-57,134-139,164-170,242-250`; `P0_GATE_01.md:154`; `METRIC_01_dark_rows.md:47-104` as cited at `TERRAIN_DARK_01.md:22-24` |
| No game window after the batch | Godot not found: install via WinGet or check `where godot` / WinGet link / ProgramFiles lookups. Do not substitute a runner job for a windowed game. | `launch_variant3d.bat:24-39,4-12` |
| `assert_clean.py` DIRTY with no live Godot and no pending jobs | Then it is genuine: check history for unacked `timed-out`/`error`/`skipped`; `failed` alone is excluded by D-13. | `CLEAN_GATE.md:86-88,95-98`; `FINAL_GATE_PLAN_01.md:166-169` |

## 8. Where to report new findings

Write a new report into `docs/coord_swarm_2026-11-25/` (reports in `docs/coord_swarm_2026-11-25/reports/`). Cite job ids, ticket numbers and result JSON/stdout/stderr paths; separate `observed` / `derived` / `inferred` / `UNVERIFIED` (`DEFAULTS_VERIFY_01.md:16-18`; `VIDEO_QA_PROTOCOL.md:39-46`). Keep captures outside the repo and have a second agent re-check visual evidence (`VIDEO_QA_PROTOCOL.md:28,46`; `TEST_MATRIX.md:75`). There is **no** `GDIGNORE_01.md` in this folder or `reports/` at writing time (directory listing, 2026-11-25) — any `.gdignore` verdict is **UNVERIFIED**; the only landed import evidence is `ASSET_IMPORT_01.md:123-141`. Inputs read for this guide, all cited inline above: `docs/variant3d/README.md` (launch/test), `launch_variant3d.bat`, `docs/COMMANDS.md`, `VIDEO_QA_PROTOCOL.md`, `TEST_MATRIX.md`, `reports/CFG_01_skirmish_defaults.md`, `reports/DEFAULTS_VERIFY_01.md`, `reports/ASSET_IMPORT_01.md`, `reports/CLEAN_01_variant_clean.md` (+ `CLEAN_02_variant_gate.md`), plus on-disk `godot_runner.py`, `assert_clean.py`, `anim3d.gd`, `config.json`, selftest/uitest artifacts.

## 9. Summary

Launch with `launch_variant3d.bat` (never a runner job for a windowed game); verify with the `variant3d/tools/godot_runner.py` gate commands and `variant3d/tools/assert_clean.py --json`, all via the **variant** spool with fresh unique ids. Capture 64² pieces/motion windowed with the reused fixture and keep artifacts in `%LOCALAPPDATA%\Temp\opencode`. Flat-root `PORT APPROX` labels, `PORT APPROX` annotations, FIFO waits and a DIRTY gate during active jobs are expected; parse errors, missing `.ctex`, `SKIP_CAPTURE` and red gates are not. Defaults: Russia vs Bavaria / 240² / Mediterranean+hills / no fog. Selftest is currently red (28/29, `build`) — report new findings and re-run results into `docs/coord_swarm_2026-11-25/`.
