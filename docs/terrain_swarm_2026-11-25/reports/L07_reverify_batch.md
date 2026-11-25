---
id: L07
ticket: "INTEGRATION wave / L07 — re-verification batch design after B01 + B04 (+ B03 if implicated)"
title: "Exact ordered re-verification batch for COORD/G04: chessboard-gone and contours-gone gate, with three-baseline C01 comparison"
owner: L07 (read-only integration-planning subagent)
created: 2026-11-25
status: DESIGN_ONLY__NO_RUNNER_JOB__NO_CODE_EDIT__NO_DONOR_ACCESS__PARITY_UNVERIFIED
scope: "Exactly one file written: this report. No .gd/.gdshader/config/test/fixture/tool/result/asset edit; no Godot process launched; no runner job submitted/cancelled/acked/reset/unwedged/doctored; no process killed; no donor file copied or executed. Every command below is a SPECIFICATION for the sole job owner (G04), not work performed here."
labels: [observed, derived, inferred, UNVERIFIED]
charter: docs/terrain_swarm_2026-11-25/CHARTER.md
wave_charter: docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
operator_rule: "Only G04 submits runner jobs (WAVE_G_CHARTER.md:31,67-70). L07 submits ZERO jobs."
parity_guard: "No donor GPU A/B frame exists. All captures, C01 numbers and R1-R6 readings are PORT APPROX internal consistency only; donor parity stays UNVERIFIED in every case (CHARTER.md:57-58,122-130; G21:11,285-289)."
sources_read:
  - docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
  - docs/terrain_swarm_2026-11-25/CHARTER.md
  - docs/terrain_swarm_2026-11-25/reports/G04_gate_log.md
  - docs/terrain_swarm_2026-11-25/reports/C02_gate_plan.md
  - docs/terrain_swarm_2026-11-25/reports/P09_measurement.md
  - docs/terrain_swarm_2026-11-25/reports/G21_acceptance_checklist.md
  - docs/terrain_swarm_2026-11-25/reports/B01_shader_impl.md
  - docs/terrain_swarm_2026-11-25/reports/B04_relief_impl.md
  - docs/terrain_swarm_2026-11-25/reports/C01_metric_tool.md
  - docs/terrain_swarm_2026-11-25/reports/G01_select_capture_atom.md
  - docs/terrain_swarm_2026-11-25/reports/G02_ghost_atom.md
  - variant3d/scripts/main.gd (--timeout CLI parsing, :31, :1334-1337)
---

# L07 — exact re-verification batch after the chessboard/contour fixes land

## 0. Authority, labels, and what this is not

- **OBSERVED** = direct file/line read; **DERIVED** = control-flow or arithmetic consequence;
  **INFERRED** = plausible reading with a caveat; **UNVERIFIED** = cannot be proven without a
  real run. **Donor parity is UNVERIFIED throughout** — nothing below is a parity certificate.
- Per `WAVE_G_CHARTER.md:31,42`, **G04 is the only agent permitted to submit runner jobs** and
  this report is L07's sole output. **No job has been submitted by L07.** The whole batch below
  is a design for G04/COORD to execute after the owning builders land their fixes.
- This is a **design, not a weakened gate**: no threshold is lowered, no assertion deleted, no
  `expected_pre_fix_failure` marker flipped, no `SKIP_CAPTURE`/headless run accepted as a PASS,
  and no capture is written over an existing baseline (`CHARTER.md:55-69`; `C02_gate_plan.md:48,450-452`).
- All commands run from repo root `C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3`
  with Windows `python` (not `python3`), PowerShell `;` not `&&` (`CHARTER.md:69`).

## 1. Trigger condition — what must have landed first (all OBSERVED from reports)

| Fix | Landed state to confirm on disk before submitting anything | Why this batch exists |
|---|---|---|
| **B01 — chessboard removal** | `variant3d/shaders/terrain_tileindex.gdshader` must be in its **final, mirror-removed** state: no `key`/`v`/`f` per-cell flip lattice in `tile_rgb()`; only the continuous low-frequency `warp` remains; `:392`, `:427`, `:235`, `:365-378`, `:475-502` anchors byte-identical (`B01_shader_impl.md:69-79,110,160-186,245-261`). Backup `inbox/backup/terrain_tileindex.gdshader.bak-B01` exists. | The per-cell mirror produced "an axis-aligned 2 m flip lattice read as a chessboard" on `g04/p0_64.png` and was rejected by the owner (`B01:69-71`; §9 owner verdict). That PNG is the **chessboard defect baseline**. |
| **B04 — contour fix** | `variant3d/scripts/world3d_terrain.gd` must carry a **contour-safe** fix (not the reverted `_relief_face_at()` absolute-height/`span×0.03` promotion). A new backup `inbox/backup/world3d_terrain.gd.bak-B04-<L07>` or equivalent must exist; no `B04_` constant, no `_relief_promoted_cells`, no `stats["b04_relief_promotion"]` unless deliberately reintroduced with owner sign-off (`B04_relief_impl.md:80-98`). | The previous attempt produced "dense concentric topographic contour / maze patterns — nested stepped rings across nearly the whole frame" and rings around every building/start, and was fully reverted (`B04:25-40,80-83`). `g04/realmap.png` is the **contour defect baseline**. `B04:100-114` requires a fresh windowed capture + second-agent read before any contour work can be called clean. |
| **B03 — only if implicated** | `variant3d/scripts/game.gd` (backup `inbox/backup/game.gd.bak-B03` already present). Land it **only** if the new P0/real-map frames show the verbatim 2 m repeat returning (R1 FAIL) after the mirror removal — `B01:132-135` states the correct remedy is B03 tile-ID diversity, **not another lattice variant**. | B01 deliberately leaves a clean hook in `tile_rgb()` for B03's tile identity (`B01:155-158`). If R1 fails this way, the batch is void and must be re-run with fresh ids after B03 lands (§7 branch). |

**Pre-submit ownership check (read-only, `C02_gate_plan.md:91-93`):** each owning report landed, each
backup exists, no builder has an in-flight edit to a file under test, and `git status --short`
shows the expected `M` set only. If ownership is open, **submit nothing**.

## 2. G0 pre-flight — mandatory before the first job, and before every subsequent job

```powershell
python variant3d\tools\godot_runner.py status
Get-CimInstance Win32_Process -Filter "Name like 'Godot%'" | Select-Object ProcessId,CommandLine
New-Item -ItemType Directory -Force -Path "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\l07" | Out-Null
```

**PASS** requires all of: `pending=0 []`, `godot.lock=free`, `now_serving == next_ticket`, zero
live Godot processes (`C02:85-89`; `G04_gate_log.md:47-58,169-171`). A non-zero pending is a
submit-nothing/wait condition (`C02:382`). Re-run `status` after **every** job's result JSON
appears; one job at a time, no id reuse, no `unwedge`/`ack`/`reset`/`doctor`, no name-based
process kill (`C02 §4:408-452`; `G04_gate_log.md:150-153`).

**New captures must go to the fresh `...\opencode\l07\` directory** so the three baselines in §5
stay byte-intact. Never point a candidate `--screenshot`/`--png` at `g04/p0_64.png`,
`g04/realmap.png`, or `p0_final_formula.png`.

## 3. Ordered batch — unique job ids and exact launch forms

All ids are **new, `l07-` prefixed, and unique** (none appears in any report or
`variant3d/.godot_queue/results/`). The order follows the proven Wave G sequence
selftest → uitest → t_render_mode → P0 → real-map → interaction atoms (`G04_gate_log.md:19-23`;
`C02:95-102`). Runner `--timeout` is before the first `--`; game/user flags are after the second `--`.

| # | id | Purpose | Hard gate |
|---|---|---|---|
| 0a | `l07-parse-b03-game` *(only if B03 landed)* | `--check-only` parse smoke on changed `game.gd` | exit 0, `script_error_lines: 0` (`C02 G1:111`) |
| 0b | `l07-parse-b04-terrain` | `--check-only` parse smoke on the new contour-safe `world3d_terrain.gd` | exit 0, `script_error_lines: 0` (`C02 G1:112`) |
| 0c | `l07-parse-b01-shader` | headless `t_terrain_only.gd` smoke → shader compile (expect `SKIP_CAPTURE`, **not** a PASS) | no shader compile error; `SCRIPT ERROR == 0` (`C02:119-123`) |
| 1 | `l07-selftest` | fresh variant selftest | `passed=true`, **29/29**, exit 0 |
| 2 | `l07-uitest` | fresh uitest with documented `--timeout 600` user flag | `passed=true`, **17/17**, exit 0 |
| 3 | `l07-rendermode` | `t_render_mode` + 2D default | `result=PASS`, `seam_missing=false`, 10/10, 2D default intact |
| 4 | `l07-p0cap` | **windowed** 64² P0 capture, pinned seed/camera | PNG 1280×720 non-blank, luma floors, `SCRIPT ERROR == 0` |
| 5 | `l07-realmap` | **windowed** real-map capture, pinned seed/camera, game `--timeout 600` | PNG 1280×720, dark-row gate applies, `SCRIPT ERROR == 0` |
| 6 | `l07-cap3-quad` *(conditional, §3.1)* | G01 CAP-3 selection quad, 3 frames | G-Q0 + G-Q1 + 36 checks |
| 7 | `l07-cap3-ghost` *(conditional, §3.1)* | G02 CAP-3 ghost final stage, valid + cancelled frames | G-G0 + checks, check 7 not weakened |
| 7b | `l07-cap3-ghost-invalid` *(conditional, §3.1)* | real **blocked-site** frame (atom does not emit one) | `ghost_invalid.png` exists or item 8 = UNVERIFIED → FAIL |

### 3.1 Copy-pasteable forms (proven launch shapes from `G04_gate_log.md:104-122`, `C02:108-115,141-151,177-186,210-212`, `P09:85-99`)

One-time artifact dir from §2. Submit sequentially; `status` between each.

```powershell
# 0a — only if B03 landed
python variant3d\tools\godot_runner.py run --id l07-parse-b03-game --timeout 180 -- --headless --path variant3d --check-only --script res://scripts/game.gd

# 0b — contour-safe B04 source
python variant3d\tools\godot_runner.py run --id l07-parse-b04-terrain --timeout 180 -- --headless --path variant3d --check-only --script res://scripts/world3d_terrain.gd

# 0c — shader compile smoke (headless; SKIP_CAPTURE expected, NOT a gate PASS)
python variant3d\tools\godot_runner.py run --id l07-parse-b01-shader --timeout 180 -- --headless --path variant3d --script res://tests/t_terrain_only.gd -- --config "C:/Users/Maxym.Oboyshev/Documents/Craft Anything/cossacks-3-3/variant3d/tests/fixtures/small_map_64.json"

# 1 — selftest, fresh 29/29 (G04 took 228.67 s; 300 is proven)
python variant3d\tools\godot_runner.py run --id l07-selftest --timeout 300 -- --headless --path variant3d -- --self-test variant3d/selftest.json

# 2 — uitest: user flag --timeout 600 overrides main.gd's 120 s default watchdog
#     (G04_gate_log.md:197-211: runner 300 s timed out; runner 600 s with game default forced exit at 138 s)
#     NO assertion/threshold/marker changed: --ui-test variant3d/uitest.json stays intact.
python variant3d\tools\godot_runner.py run --id l07-uitest --timeout 600 -- --headless --path variant3d -- --ui-test variant3d/uitest.json --timeout 600

# 3 — t_render_mode (2D default is a hard gate; C02:329-340)
python variant3d\tools\godot_runner.py run --id l07-rendermode --timeout 120 -- --headless --path variant3d --script res://tests/t_render_mode.gd

# 4 — windowed P0 64² capture (t_terrain_only.gd fixes the 64² harness, seed 20261113, fixed camera)
python variant3d\tools\godot_runner.py run --id l07-p0cap --timeout 300 -- --path variant3d --script res://tests/t_terrain_only.gd -- --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/l07/p0_64.png" --png "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/l07/p0_64.png"

# 5 — windowed real-map capture, seed re-applied after config merge, game --timeout 600
python variant3d\tools\godot_runner.py run --id l07-realmap --timeout 600 -- --path variant3d -- --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/l07/realmap.png" --screenshot-frames 10 --seed 20261113 --timeout 600 --dump-config

# 6 — G01 CAP-3 quad (--screenshot is the menu-skip flag; 3 PNGs land beside it)
python variant3d\tools\godot_runner.py run --id l07-cap3-quad --timeout 300 -- --path variant3d --script res://tests/t_select_rect_capture.gd -- --config "C:/Users/Maxym.Oboyshev/Documents/Craft Anything/cossacks-3-3/variant3d/tests/fixtures/small_map_64.json" --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/l07/cap3_selquad_menu_skip.png"

# 7 — G02 CAP-3 ghost (during + cancelled frames)
python variant3d\tools\godot_runner.py run --id l07-cap3-ghost --timeout 300 -- --path variant3d --script res://tests/t_ghost_final_stage.gd -- --config "C:/Users/Maxym.Oboyshev/Documents/Craft Anything/cossacks-3-3/variant3d/tests/fixtures/small_map_64.json" --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/l07/cap3_ghost_valid.png" --no-ghost-png "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/l07/cap3_ghost_cancelled.png"

# 7b — separate blocked-site frame (C02 G3b caveat: E04/G02 atom does NOT emit ghost_invalid.png)
#      The atom must be extended by ITS OWNER first; never relabel the cancelled frame as "invalid".
#      id reserved; exact argv is owner-supplied once the atom emits it. Until then: UNVERIFIED → FAIL.
```

**`--timeout 600` honesty note (binding).** This is the **documented user flag**
(`main.gd:31,1334-1337`; `G04_gate_log.md:234-236`), not a test change. It only raises the game's
hard wall-clock limit so a slow MX130 setup can finish; it does **not** alter `uitest.json`,
any assertion, any threshold, or the 17 checks. Accept only a **fresh** `variant3d/uitest.json`
`passed=true`/17-of-17 whose `LastWriteTime` is **after** job `l07-uitest` started — G04 §5.2
found the on-disk 17/17 predated both earlier jobs and was therefore **stale, not a PASS**.
A watchdog-forced exit or engine resource-leak error stays a finding; do not rerun
hopefully, and never lower a limit to manufacture green (`C02:450-452`).

**Pinned seed/camera proof (G21 G0-d).** For `l07-realmap`, record `settings file:` from stdout,
`--dump-config` effective values, and the verbatim `screenshot capture diag` line
(`camera_current=true`, `world_parent=Screenshot3DViewport`, 1280×720). G04 §5.1 recorded
`camera_pos=(144.1104, 58.0, -88.57262) target=(384.1104, 58.60797)` and `config.json`
`random_seed: 20261113`, `camera.start_zoom: 0.3448276`. If camera/zoom/seed differ from the
`g04/realmap` baseline, **cross-capture attribution is UNVERIFIED** — the new frame is still
assessable in-frame, but "contours gone vs baseline" cannot be claimed from it. Do not edit
the shipped config to force a match.

**Conditional G01/G02 rule.** Run jobs 6/7/7b **only if** the atoms are in a runnable, honest state:
G01 `t_select_rect_capture.gd` executes all 36 checks with no weakened predicate
(`G01_select_capture_atom.md:46-50,187-195`), and G02 `t_ghost_final_stage.gd` has its check 7
resolved by a **real footprint-visibility fix**, not by relaxing it
(`G02_ghost_atom.md:59-68,142-160`). Both atoms exist on disk but are **AUTHORED__NOT_RUN**
(UNVERIFIED). If either is unrepaired, **do not run it in this batch**; record CAP-3 items 7/8
as `UNVERIFIED (NO VALID CAP-3 FRAMES)` → FAIL per `G21:178-190,208-209`. Do not substitute
main's saver, a single still, or a headless run (`C02:194-225`).

## 4. Per-job integrity — stats / scan-stderr / result reads

After each result JSON exists (ticket number from `status` / result path):

```powershell
python variant3d\tools\smallmap_capture.py stats "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/l07/p0_64.png"
python variant3d\tools\smallmap_capture.py stats "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/l07/realmap.png"
python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\<ticket>_l07-p0cap\stderr.txt
python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\<ticket>_l07-realmap\stderr.txt
```

Run `scan-stderr` on **every** job's stderr (including selftest/uitest/rendermode and the atoms).
Require `{"exists": true, "script_error_lines": 0, "lines": []}` (`G04:189-192`). `stats` is
qualitative only ("No donor parity is claimed"). If `_is_blank()` refuses a valid frame, analyse
the `.png.raw.png` sidecar with its `screenshot capture diag` — **do not edit the detector**
(`P09:151`; `G21:55`). Record per job: id + ticket, runner `status`/exit, wait/run seconds,
result JSON path, stdout/stderr paths, PNG path/size, verbatim `stats`, and `SCRIPT ERROR` count
(`C02 §5:454-464`).

Fresh result reads: `variant3d/selftest.json` (`passed=true`, 29 steps), `variant3d/uitest.json`
(`passed=true`, 17 checks, fresh mtime), `variant3d/tests/results/t_render_mode.json`
(`passed=true`, `result=PASS`, `seam_missing=false`, all checks, hard 2D default gates).

Final read-only checks (no job id): `python variant3d\tools\assert_clean.py --json`
(expect `verdict=CLEAN`, `reasons=[]`, `failures=[]`, 0 processes, free lock, `pending=0`) and
`git status --porcelain -- app/` + `git diff --stat -- app/` (both **empty** — 2D untouched;
`C02 G8/G9:342-376`). Never `ack` to manufacture CLEAN (`C02:352-356`).

## 5. C01 metric comparisons — three baselines, direction only (SMOKE METRIC, not a gate)

The three named baselines map to two defects and one original state:

| Baseline path | What it is |
|---|---|
| `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\p0fresh01\p0_final_formula.png` | **Old/original** pre-B01 P0: 1280×720; mean RGB `93.73,96.76,31.62`, luma mean `91.4`, std `10.6`, p5–p95 `75–109`, sat `0.675`, BV32 n640 `8.7`, grad n640 `5.00`; ground ROI fractional `.02,.02,.98,.98` → 1229×691 (`G21:71-75`). |
| `...\opencode\g04\p0_64.png` | **Chessboard defect** frame — the per-cell mirror lattice the owner rejected (`B01:69-71`; `G04:218-232`). |
| `...\opencode\g04\realmap.png` | **Contour defect** frame — dense concentric rings/maze (`B04:25-40`). Sidecar `realmap.png.raw.png` exists; use only with its diag (`G04:237-252`). |

Run these on the **new** `l07` PNGs. Copy numbers **verbatim** with command + paths into the
metric field; keep them separate from the visual field (`G21:77-104,239-251`).

```powershell
# A. Strongest chessboard A/B: same harness form, new P0 vs the chessboard baseline
python variant3d\tools\terrain_ab_metric.py "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/l07/p0_64.png" "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/g04/p0_64.png" --crop 120,60,1040,580 --json

# B. New P0 vs the ORIGINAL baseline, A11 ground ROI (same-crop on both PNGs)
python variant3d\tools\terrain_ab_metric.py "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/l07/p0_64.png" "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/p0fresh01/p0_final_formula.png" --crop-frac .02,.02,.98,.98 --json

# C. Strongest contour A/B: same harness form, new real-map vs the contour baseline
python variant3d\tools\terrain_ab_metric.py "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/l07/realmap.png" "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/g04/realmap.png" --crop-frac .02,.02,.98,.98 --json

# D. New real-map vs ORIGINAL baseline (cross-harness: attribution UNVERIFIED unless seed/camera match)
python variant3d\tools\terrain_ab_metric.py "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/l07/realmap.png" "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/p0fresh01/p0_final_formula.png" --crop-frac .02,.02,.98,.98 --json

# E. Per-box corroboration for R5 (substitute each G21 box as --crop x,y,w,h on pair C)
#    top-left 0,0,440,330 | right 700,0,580,500 | bottom-left 200,540,270,180 | bottom-right 850,530,430,190
```

Fields to read (`C01_metric_tool.md:39-47`), always as **direction of movement across same-crop
A/B frames**, never absolute gates:
- Chessboard check (pair A): `seam_repetition.row_periodicity`, `col_periodicity`, `tile_repeat`,
  `row_seam`, `col_seam`, `seam_repetition_score`, `driver` should **not rise** vs the chessboard
  baseline; a drop corroborates R1. `directional_gradient.band_peak_deg` / `band_*` descriptive only.
- Contour check (pair C): periodic/seam components in the R5 boxes should not rise vs the contour
  baseline; a drop corroborates R5. **Visual R5 is decisive** — C01 has no concentric-ring field.
- Original-state tracking (pairs B/D): `block_variance[8/16/32/64].between_block_var` UP in step at
  all scales, `color.std_luma` UP toward ≈18–22, `color.p05_luma`/`p95_luma` spread wider,
  `color.mean_saturation` DOWN toward ≈0.53, `directional_gradient.axis_gradient_energy` DOWN
  (`G21 §3:108-128`; `C01 §5.1,§7:212-217`). C01's block/gradient fields are **raw-crop proxies**,
  **not** A11's 640-normalised absolute bands (`G21:88-92`; `C01:205-217`).
- `flags` are triage hints, not thresholds; `outside_donor_range`/z-scores are calibration hints
  only (`C01:183-191`; `G21:249-250`).

**Binding:** a green/better number never closes a visible grid, streak, blotch, contour ring,
seam or dark row; a red number on an inapplicable predicate never invents one (`G21 §6:239-251`).
A `full_width_dark_rows` reading on the water-free P0 frame is `RECORDED_NOT_APPLICABLE` and
kept in both fields; on the water-bearing real map the gate applies (`G21:173-176`). Pairs B/D
are **not donor parity**; they are PNG-vs-PNG direction checks on a matched crop.

## 6. Explicit PASS/FAIL — "chessboard gone" and "contours gone" (G21 R1–R6 boxes)

Apply the admissibility gate `G21 §1` (G0-a…e) to each PNG **first**. Missing/blank/headless/
wrong-size/root-texture frame, or unmatched camera for a cross-capture claim → that item is
**UNVERIFIED → FAIL**; never converted to PASS (`G21:47-58,183,190`). Describe the region before
the verdict (`G21:39-43`); every "absent" statement must name the box actually scanned.

### 6.1 CHESSBOARD GONE — primary frame `l07/p0_64.png`, corroborated on `l07/realmap.png`

| Box (G21) | Scan | **PASS** | **FAIL** |
|---|---|---|---|
| **R1** P0 ground `x120–1160 / y60–640`; real-map strips `y40–220`, `y220–500`, `y500–690` | 3×3 sub-region means + row/column mean profiles; look for axis-aligned 2 m flip lattice, cell boundaries, checker mosaic, repeated identical patch, stepped/nested outline. Read C01 pair A `seam_repetition`/`tile_repeat` **beside, not instead of** the image. | No cell boundary, no checker mosaic, no repeated patch, no regular stepped band; sub-region means vary irregularly; periodic/repeat fields do not rise vs `g04/p0_64`. | Any visible axis-aligned flip lattice, checker mosaic, repeated patch or regular stepped outline — **even if** `seam_repetition_score` is low or a JSON verdict is PASS (`G21:137-142`). If it is specifically the verbatim 2 m repeat returning, route to **B03** (§7 branch), not another lattice variant. |
| **R2** both PNGs: `x200–720 / y200–480`, densest `x300–620 / y300–450`; right `x640–1280 / y0–340`; lower-left `x0–430 / y500–690` | Orientation, spacing, luma above field, non-grid alignment; compare to `g04/p0_64` for the mirror-lattice strokes. | No regular parallel strokes/bands in any named box; grain reads non-periodic. | Regular parallel strokes/bands reading as repetition/moiré. A curved organic band or true cliff edge is recorded as OBSERVED/INFERRED, **not** auto-FAIL (`G21:144-149`). |
| **R3** both PNGs: `x350–950 / y480–620` + whole ground band | Local luma vs field; recurrence at tile cadence or identical shape; `color`/`block_variance`/dark rows as corroboration only. | No recurring same-shape dark patches, no new dark band; darker areas are single non-repeating relief/shadow regions. | Repeated similarly shaped dark blotches, full-width dark/green rows, new dark band where water is present (`G21:151-156`). |
| **R4** both PNGs, whole ground band | Large-scale mottling (tens of px), fine grain subordinate, hue/luma spread, grey rock faces; §3 numeric anchors as INFERRED corroboration. | Coherent light/dark patches ≥32 px present; fine grain subordinate; spread broad; verdict worded as INFERRED comparison to named features. | Flat uniform olive field with only fine grain after a full-band scan, or palette-only change with BV32 still ≈8.7 and grad ≈5.00 (`G21:158-162`). |

**Chessboard-gone sign-off:** PASS **only if R1+R2+R3 all PASS** on the new P0 frame with R4 not
regressed and pair A periodic/repeat fields not worse than `g04/p0_64`. The owner's chessboard
verdict was made on the P0 frame (`B01 §9`), so that frame is decisive; `l07/realmap.png` must
independently show no R1 lattice for the batch to be called clean.

### 6.2 CONTOURS GONE — primary frame `l07/realmap.png`, P0 as baseline

| Box (G21) | Scan | **PASS** | **FAIL** |
|---|---|---|---|
| **R5** real-map ground `y40–690`; historical boxes top-left `x0–440 / y0–330`, right `x700–1280 / y0–500`, bottom-left `x200–470 / y540–720`, bottom-right `x850–1280 / y530–720`; + around every building/start position | Grey rock faces vs nested concentric rings; explicitly compare to `g04/realmap` (the contour baseline). Look for **dense concentric topographic rings / maze**, nested stepped outlines, rings around town hall/huts/resource clusters, plus seams, z-fighting, black rows, white stepped/nested bands. Read C01 pair C/box crops beside the image. | Relief/shore breaks up the surface; **no concentric contour rings/maze and no rings around buildings/start positions** in any named box; no new seam, z-fighting, black row or white stepped/nested band (`G21:164-169`). | Any dense concentric contour/nested-ring pattern (the `B04:33-39` regression), rings around buildings/starts, new seams/z-fighting/black rows, white stepped grid-aligned bands, or near-flat ground where relief is expected — regardless of C01 numbers. |
| **R6** real map: right `x1050–1280 / y420–470`; bottom-right `x850–1280 / y610–720`; bottom-left `x0–95 / y560–600`; 20–60 px band both sides | Transition naturalness, water-on-grass tint, full-width dark/green rows, repeated bands parallel to shore. Dark-row gate **applies** on this water-bearing frame. | Natural transition; no full-width dark/green row; no `grass1` pixels in water; no repeated hard bands parallel to shore. | Full-width dark/green rows on this water-bearing frame, water pixels showing `grass1`, repeated/hard banded shore, or a new dark row attributable to water (`G21:171-176`). |
| **R1/R2/R3** on real-map strips (§6.1) | Same scans; contour fix must not reintroduce a grid/streak/blotch. | Same as §6.1 on real-map strips. | Same as §6.1. |

**Contours-gone sign-off:** PASS **only if R5 and R6 both PASS** on `l07/realmap.png` with the
R1–R3 strips not regressed vs `g04/realmap`. A flat-but-clean frame is acceptable per the owner's
`B04:80-83` instruction ("a flat-but-clean terrain is better than this"); a contour-free frame
is **not** thereby donor parity.

### 6.3 Gate ledger (all required; none optional)

| Item | Source | PASS | FAIL / stop |
|---|---|---|---|
| Selftest | `C02:302-315`; fresh JSON | `passed=true`, 29/29, exit 0, B03 determinism + B04 mesh invariants (`surface_count=1`, `vertex_count=4096`, `triangle_count=7938`, `uv2_count=4096`, `flat_grid_promoted==0`) | Anything less; stale JSON; weakened marker |
| Uitest | `C02:317-327`; `G04:197-211` | fresh 17/17, exit 0, mtime after job start, `SCRIPT ERROR == 0`, `--timeout 600` user flag present | Watchdog-forced exit, stale 17/17, any weakened check |
| `t_render_mode` | `C02:329-340` | `result=PASS`, `seam_missing=false`, all checks, `render_mode_default_2d` intact | Any FAIL check or `SEAM_MISSING` |
| P0 capture | `C02:384`; `G04:220-232` | windowed 1280×720 non-blank; `non_black_fraction ≥ 0.9`, `mean_luma ≥ 40`, `max_luma ≥ 100`; `full_width_dark_rows` recorded-not-applicable (water-free); `SCRIPT ERROR == 0`; §6.1 PASS | Any R1–R3 defect, blank/headless PNG, luma below floor (do **not** lower 40/100) |
| Real-map capture | `C02:385`; `G04:234-252` | windowed 1280×720; seed/camera pinned & diag recorded; `SCRIPT ERROR == 0`; `full_width_dark_rows == 0` where water present; §6.2 PASS | Any R5/R6 defect, missing/blank/wrong-path capture, unmatched camera claimed as baseline A/B |
| CAP-3 quad (if run) | `C02:386-387`; `G21:178-183`; `G01:187-195` | 3 PNGs + `frames.json`; `ov.get_parent()==capture_view3d`, `run_mode=windowed_real_input`, `headless=false`, viewports `[1280,720]`, `event_coord_scale=[1,1]`; ≥3/4 edge midpoints & ≥2/4 corners marquee-coloured; centre ≤8/255 vs baseline; hidden in `after.png`; all 36 checks | Quad-less saver frame → `UNVERIFIED (WRONG CAPTURE PATH)` (not "quad broken", not PASS); blank readback → FAIL |
| CAP-3 ghost (if run) | `C02:388-390`; `G21:185-190`; `G02:59-68,142-160` | code/atom resolves **final** mesh; `ghost_valid` + real `ghost_invalid` show translucent last-stage silhouette, green/red, alpha ≈0.4, pixel-honest footprint, cleared on cancel/place; check 7 unweakened | Stage-1/foundation, bare quad, opaque/offset/lingering ghost, off-screen target, missing `ghost_invalid.png` → UNVERIFIED → FAIL |
| Queue / 2D | `C02:395-396` | `assert_clean` CLEAN; `pending=0`; `app/` byte-untouched | DIRTY, unacked failure, live process, any `app/` diff |
| Donor parity | `CHARTER:57-58,124-130`; `G21:11,288-289` | Always **UNVERIFIED** — verdict text must say so | Any "donor-confirmed"/"donor match" wording → FAIL |

**Overall:** the batch is PASS only if every applicable row above is PASS **and** a second agent
(independent of the frame builder) signs the G21 R1–R6 read against all new PNGs
(`C02:398-406`; `G21:28,221-235`). R7/R8 remain UNVERIFIED unless CAP-3 frames land; that is an
evidence-completeness statement, **not** a finding that the quad or ghost is broken.

## 7. Branch if B03 is implicated

If `l07-p0cap` shows R1 FAIL of the specific "verbatim 2 m repeat returning after mirror removal"
kind (`B01:132-135`), **do not reintroduce a lattice variant and do not lower R1**. Stop the batch,
hand the tile-ID-diversity fix to B03 (`game.gd`, backup `inbox/backup/game.gd.bak-B03`), wait for
it to land, then **re-run the entire batch with a new fresh id set** (`l07b-*`) and new artifact
dir — no id reuse, no overwrite of prior result JSONs (`C02:98-101,439`; `P09:130`).

## 8. Donor parity — mandatory closing statement

Copy verbatim into the reviewer block of the sign-off (`G21:230`):

> **"PORT APPROX — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."**

No number in §5 and no R-card in §6 establishes donor fidelity. `stats`/C01/green JSON never
override a visible artifact; a missing or blank frame is never promoted to PASS; donor parity
stays **UNVERIFIED** whatever the batch reports.

## 9. L07 boundary / honesty ledger

- **OBSERVED:** the six governing documents plus B01/B04/C01/G01/G02 and `main.gd:1334-1337`
  were read directly; the baseline paths, boxes, thresholds and historical job outcomes quoted
  above are file facts with line anchors.
- **DERIVED:** the ordered batch and unique `l07-` id registry follow the proven G04/C02 sequence;
  the three-baseline mapping follows B01 §9 (chessboard on `g04/p0_64`), B04 §1 (contours on
  `g04/realmap`) and G21 §2 (`p0_final_formula` as original baseline).
- **INFERRED (caveated):** that the contour-safe B04 fix and the mirror-removed B01 shader will
  actually produce clean frames — a prediction only; only G04's windowed run + second-agent read
  can settle it. Whether the G01/G02 atoms are repaired in time is UNVERIFIED.
- **UNVERIFIED:** every job id in §3 is reserved, **not submitted**; every expected PNG/metric is
  unmeasured; donor parity; CAP-3 from terrain stills.
- **No runner job, no code/config/test/tool edit, no donor access, no process kill.** Only this
  report was written; G04 remains the sole job owner and COORD alone advances any gate.

*End of L07 — design only. No job submitted; all expected results UNVERIFIED.*
