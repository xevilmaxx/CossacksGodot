---
id: P03
swarm: TERRAIN-SWARM-2026-11-26
title: "P03 — acceptance gates and capture tooling inventory for the fresh terrain port"
role: READ-ONLY AUDIT — no code edits, no Godot process, no runner job, one report only
owner_file: docs/terrain_swarm_2026-11-26/reports/P03_gates_capture.md
status: INVENTORY_ONLY__NO_RUNNER_JOB__NO_NEW_CAPTURE__PARITY_UNVERIFIED
created: 2026-11-26
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, "PORT APPROXIMATION"]
charter: docs/terrain_swarm_2026-11-26/CHARTER.md
board: docs/terrain_swarm_2026-11-26/SWARM_BOARD.md
parity_guard: "No donor GPU A/B frame exists. Every command below is a port-internal gate or a PORT APPROXIMATION smoke metric; no donor-parity claim is made or implied."
principle: "[O] observed file/line · [D] derived from observed code/arithmetic · [I] inferred with caveat · [U] UNVERIFIED — nothing here is a verdict or a fresh gate result."
---

# P03 — gates / capture infrastructure audit

## 0. Executive summary

- **[O] The gate commands are already fully specified and unchanged:** variant selftest `29/29`, uitest `17/17`, `t_render_mode` PASS with `seam_missing=false`, `assert_clean` verdict `CLEAN`, plus `t_map_variety` 5/5 and `scan_map.py` ALL GREEN as terrain-specific structural gates (`docs/terrain_swarm_2026-11-25/reports/C02_gate_plan.md:302-356`; `Z04_height_only_design.md:412`; `variant3d/tests/results/t_map_variety.json:2-31`). **P03 ran none of them.**
- **[O] The on-disk green JSONs are stale, not fresh evidence:** `selftest.json` mtime `2026-11-25 15:28:20`, `uitest.json` `15:36:51`, `t_render_mode.json` `15:37:37`, `t_map_variety.json` `unix_ms=1795599611871`. Freshness is `result mtime after job START`, not merely `passed=true` (`L07_gate_log.md:84-86,137-138,152-154`; `G04_gate_log.md:205-211`).
- **[O] The runner is the only legal Godot door, and it is serialised:** `variant3d/tools/godot_runner.py` spool = `variant3d/.godot_queue`, FIFO lock + hard timeout, one Godot at a time, unique `--id` per invocation (`godot_runner.py:47-53,615-652`; `AGENT_PROTOCOL.md:14-35`; `A09_capture_plan.md:459-471`; `CHARTER.md:80-82`). Analysis workers submit **no** jobs.
- **[D] Critical trap for the fresh port:** with the exception of four variant-aware scripts, the `variant3d/tools/*` capture tools are **byte-identical copies of `app/tools/*`** and still hardcode `--path app`, `app/.godot_queue`, `app/shots`, and legacy M0/M0.6 defaults. Running them from `variant3d/tools` does **not** capture the fresh `variant3d` terrain unambiguously. SHA-256 equality verified read-only for `terrain3d_shot.py`, `heightmap3d_shot.py`, `full_map_shot.py`, `compare_shots.py`, `terrain_compare.py`, `terrain_sample_shot.py`, `terrain_land_shot.py`, `scan_map.py`; `assert_clean.py`, `godot_runner.py`, `smallmap_capture.py`, `terrain_ab_metric.py` are variant/different copies. Details §3.
- **[O] `terrain_ab_metric.py` has no `--baseline` / ARI flag.** A09's ARI score is a *specification only* (`A09_capture_plan.md:103-109,328-352`); the implemented tool offers candidate-only, candidate-vs-one-reference, and `--compare-ref` distribution modes (`terrain_ab_metric.py:722-844`; `C01_metric_tool.md:204-205`). COORD must not claim an A/B "gate" from it.
- **[D] No 240²/320² fresh baseline exists yet.** The available baselines are 64² P0 / prior real-map captures and third-party donor stills (§5). A fresh baseline must be frozen first from the new pipeline at each size, then compared like-with-like.
- **[O] Current spool snapshot (read-only file read, no runner invoked):** `counter=607`, `now_serving=607`, `pending_job_files=0`, `godot.lock` absent; `status.json` history 500 entries with **3 unacknowledged** `timed-out`/`skipped` jobs (tickets 575, 582, 585). Therefore a bare `assert_clean.py --json` would print `DIRTY` today; `--ignore-history` suppresses those but must not be used to manufacture a false CLEAN (`C02_gate_plan.md:349-356`).

---

## 1. Evidence table

| # | Label | Source (file:line) | Establishes |
|---:|---|---|---|
| E01 | [O] | `docs/terrain_swarm_2026-11-26/CHARTER.md:26-31,46-64,66-85,113-126` | Donor read-only; `app/` byte-untouched; mandatory labels; gates 29/29, 17/17, `t_render_mode`, CLEAN; 240² and 320² support; one Godot at a time; no parity without donor GPU A/B |
| E02 | [O] | `docs/terrain_swarm_2026-11-26/SWARM_BOARD.md:28,39-45` | P03 owns exactly `reports/P03_gates_capture.md`; COORD integrates |
| E03 | [O] | `docs/terrain_swarm_2026-11-25/reports/C02_gate_plan.md:79-101,302-356,392-396` | Preflight criteria, exact selftest/uitest/`t_render_mode`/CLEAN commands and acceptance fields |
| E04 | [O] | `docs/terrain_swarm_2026-11-25/reports/G04_gate_log.md:182-252` | Historical fresh 29/29, 10/10, windowed P0 + real-map captures; stale 17/17 finding |
| E05 | [O] | `docs/terrain_swarm_2026-11-25/reports/L07_gate_log.md:84-86,131,150,156-160,180-212` | Freshness/mtime rule; `--timeout 600` operational flag; watchdog failure mode; `--dump-config` capture conflict |
| E06 | [O] | `docs/terrain_swarm_2026-11-25/reports/A09_capture_plan.md:26-44,62-99,459-471` | Fixed capture conditions, 240² drift, exact 64²/320² windowed commands, one-Godot rule |
| E07 | [O] | `docs/terrain_swarm_2026-11-25/reports/C01_metric_tool.md:64-105,204-217` | Implemented `terrain_ab_metric` CLI forms and SMOKE / no-ARI limitations |
| E08 | [O] | `docs/terrain_swarm_2026-11-25/reports/G21_acceptance_checklist.md:52-58,80-105,131-191,241-250` | G0-a…e capture admissibility, same-ROI rule, R1–R8 visual cards, metric never overrides visual |
| E09 | [O] | `variant3d/tools/godot_runner.py:47-53,488-509,615-652`; `variant3d/tools/assert_clean.py:33-42,262-288` | Variant spool path, status fields, run/status/cancel/ack CLI; CLEAN/DIRTY algorithm |
| E10 | [O] | `variant3d/scripts/main.gd:3-5,31-35,1255-1371,1588-1611` | All user flags (`--screenshot`, `--screenshot-frames`, `--self-test`, `--ui-test`, `--config`, `--seed`, `--dump-map`, `--dump-config`, `--timeout`); headless screenshot = 800×600 CPU fallback; 120 s default watchdog |
| E11 | [O] | `variant3d/tests/t_render_mode.gd:5,44-60,63-126`; `variant3d/tests/t_map_variety.gd:15-17,184-259`; `variant3d/tests/manifest.json:139-144`; `variant3d/tools/test_all.py:28-50` | Test contracts, result paths, manifest registration and generic runner launch shape |
| E12 | [O] | `variant3d/tools/smallmap_capture.py:1-9,17-18,21-39,50-58,61-70` | `stats` / `scan-stderr` CLI, dependencies, "No donor parity is claimed" |
| E13 | [O] | `variant3d/tools/scan_map.py:2-22,86-97,446-510` | `--dir` input contract, dump source, derived 320² gates, exit codes |
| E14 | [O] | `variant3d/tools/terrain3d_shot.py:2-33,94-144`; `variant3d/tools/heightmap3d_shot.py:2-24,36-48,122-150,169-247` | Legacy M0.5/M0.6 and G3-2 sandbox verifiers; app-only paths; no direct Godot launch |
| E15 | [O] | `variant3d/tools/full_map_shot.py:2-63,87-94,133-181,467-488,494-620` | Whole-map diagnostic compositor, `--path app` dump generation, tiling rule and sidecar |
| E16 | [O] | `variant3d/tools/compare_shots.py:2-19,105-129,132-177`; `variant3d/tools/terrain_ab_metric.py:2-33,52,62,722-844`; `variant3d/tools/terrain_compare.py:2-30,42-52,306-328` | Headless image comparators; SSIM/MAD and texture statistics are SMOKE only |
| E17 | [O] | `variant3d/tools/terrain_sample_shot.py:2-23,36-40,63-69,92-118,209-216,333-341,344-393,428-457`; `variant3d/tools/terrain_land_shot.py:2-14,24-47,114-139` | 128² seed scan / windowed real-renderer gate, tbb0-* ids, app-path hardcoding, 800×600 rejection |
| E18 | [O] | Read-only `Get-FileHash` comparison of `app/tools/<name>.py` vs `variant3d/tools/<name>.py`, 2026-11-26 | 8 capture/scan tools byte-identical; 4 differ; see §3.1 |
| E19 | [O] | Read-only filesystem listing: `variant3d/config.json` (`random_seed=20261113`, `render_mode=3d`, `240×240`, `start_zoom=0.3448276`); `variant3d/.godot_queue/{counter,now_serving,godot.lock,status.json}` | Current size drift and live spool/history state |
| E20 | [O] | Read-only listings of `%TEMP%\opencode\p0fresh01`, `\g04`, `\l07b`, `C:\Users\Maxym.Oboyshev\Downloads\c3` (12 images); `app/shots` (mostly `.png.import` stubs) | Available baseline artefacts and their limitations (§5) |
| E21 | [O] | `docs/terrain_swarm_2026-11-26/reports/A05_qa_harness.md:297-339,379-389` | Peer design already planned the same gate/capture CLI family; P03 is the requested inventory reconciliation |
| E22 | [D] | Deduction from E18 + `full_map_shot.py:87-94,133-181`, `terrain_sample_shot.py:36-40,145,209-216` | Calling the variant copy of a byte-identical tool submits through the *variant* runner (its local `godot_runner.py`) but asks Godot to boot `app/` and reads/writes `app/` or `variant3d/shots` inconsistently |

`[I]` appears only where explicitly marked in §6/§9. `[U]` items are collected in §10.

---

## 2. Gate inventory — exact invocation, output, prerequisites, execution mode

All commands are **repo-root relative**, Windows `python`, PowerShell `;` (never `&&`), and every runner `run` needs a **new unique `--id`** (`E03`, `E06`).

| Gate | Path | Exact CLI (template; `<UNIQUE>` = fresh id) | Produces / acceptance | Prerequisites | Headless or GPU/windowed |
|---|---|---|---|---|---|
| Preflight | `variant3d/tools/godot_runner.py` | `python variant3d\tools\godot_runner.py status` | Text with `spool`, `now_serving`, `next_ticket`, `pending`, `godot.lock`, status histogram (`godot_runner.py:488-509`) | None (read-only) | Headless / no Godot |
| Variant selftest **29/29** | `variant3d/selftest.json` | `python variant3d\tools\godot_runner.py run --id <UNIQUE> --timeout 700 -- --headless --path variant3d -- --self-test variant3d/selftest.json --timeout 600` | Fresh `selftest.json`: `passed=true`, `steps` 29/29; runner `status=ok`/exit 0; `SCRIPT ERROR=0`; mtime after job START (`E03:302-315`, `E05:131,137-138`) | Clean preflight; settled tree; `--timeout 600` is a documented operational guard, not a test change (`E05:119-123`) | **Headless** (no capture) |
| Variant uitest **17/17** | `variant3d/uitest.json` | `python variant3d\tools\godot_runner.py run --id <UNIQUE> --timeout 700 -- --headless --path variant3d -- --ui-test variant3d/uitest.json --timeout 600` | Fresh `uitest.json`: `passed=true`, 17/17; exit 0; `SCRIPT ERROR=0`; mtime after START (`E03:317-327`, `E05:150-154`) | Same as selftest; without user `--timeout 600` the main 120 s watchdog forced-exits (`E05:85,119-123`) | **Headless** |
| `t_render_mode` | `variant3d/tests/t_render_mode.gd:63-126` | `python variant3d\tools\godot_runner.py run --id <UNIQUE> --timeout 120 -- --headless --path variant3d --script res://tests/t_render_mode.gd` | `variant3d/tests/results/t_render_mode.json`: `passed=true`, `result=PASS`, `seam_missing=false`, 10/10; hard 2D default gates `render_mode_default_2d` / `runtime_default_2d` (`E03:329-340`, `E11`) | `main.gd` readable/loadable; no game bootstrap | **Headless**; no GPU needed |
| `assert_clean` **CLEAN** | `variant3d/tools/assert_clean.py:262-288` | `python variant3d\tools\assert_clean.py --json` (add `--max-lock-age SEC`, `--ignore-history` only with a recorded reason) | Exit 0 + `verdict=CLEAN`, `reasons=[]`, `processes.count=0`, lock free/`held_recent`, `failures=[]`; failure set `{timed-out,error,skipped}` (`assert_clean.py:42,110-188,213-218`; `E03:342-356`) | All runner jobs finished; no live Godot; no unacked failure statuses | Headless; **never kills anything** |
| `t_map_variety` **5/5** | `variant3d/tests/t_map_variety.gd:184-259`, result `variant3d/tests/results/t_map_variety.json` | `python variant3d\tools\godot_runner.py run --id <UNIQUE> --timeout 120 -- --headless --path variant3d --script res://tests/t_map_variety.gd` (shape from `test_all.py:38-50`, manifest `timeout=90` at `manifest.json:139-144`) | 5 checks: seed differences, `same_seed_byte_identical`, map type water, 110×90 size, start reachability; fresh JSON mtime after START (`E11`, `Z04:412`) | `game.gd`/`data.gd` preloads; in-process `Data.MAP_W/H` override; **don't use a frozen tileblock hash** (`Y07_ring_survivors.md:202`) | **Headless** |
| `scan_map.py` | `variant3d/tools/scan_map.py:446-510` | `python variant3d\tools\scan_map.py --dir <DIR_OF_DUMP_JSON>` | Per-seed rows + means, `reachability n/n`, `ALL GREEN` exit 0; exit 1 on any red; gates at `:478-493` (water ±5 pp vs mask, donor-scaled patches/mean, purity/clear 100 %, coast ≥90 %, cliff ≥80 %, tileflow ≥99 %, reach) | A directory of JSON dumps containing `map_w`, `map_h`, `terrain`, `blocked`, `res`, `starts` (`scan_map.py:86-97,451-463`); dumps from `godot --headless --path variant3d -- --dump-map FILE --seed N` (`main.gd:1364-1367`; docstring `:6` still says `app`) | **Pure Python headless**; no Godot, no GPU. numpy optional (`:27-34`) |
| `scan-stderr` integrity | `variant3d/tools/smallmap_capture.py:50-58` | `python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\<ticket>_<id>\stderr.txt` | JSON with `script_error_lines: 0` required (`E03:128-133`) | Runner result dir exists | Headless |

**Known gate hazards [O]:** (a) a green JSON can be stale (`E04:205-211`, `E05:84-86`); (b) `--dump-config` exits before `--screenshot`, so never combine them (`E05:180-198`); (c) a runner `ok`/exit-0 is not a PNG (`E05:180-198`); (d) `assert_clean` counts only leaked statuses, and `failed` is deliberately excluded (`assert_clean.py:40-42`).

---

## 3. Capture / image-tool inventory

### 3.1 Path-aperture audit [O]/[D]

Read-only SHA-256 comparison (E18) gives:

| Tool | `variant3d/tools` copy | Where it points when invoked from `variant3d/tools` |
|---|---|---|
| `terrain3d_shot.py`, `heightmap3d_shot.py`, `full_map_shot.py`, `compare_shots.py`, `terrain_compare.py`, `terrain_sample_shot.py`, `terrain_land_shot.py`, `scan_map.py` | **byte-identical** to `app/tools` copy | Legacy `app/` defaults and/or `--path app`; see per-tool rows below |
| `assert_clean.py` | **different** | Correct variant spool `variant3d/.godot_queue` (`assert_clean.py:34`) |
| `godot_runner.py` | **different** | Correct variant spool `variant3d/.godot_queue` (`godot_runner.py:47`) |
| `smallmap_capture.py`, `terrain_ab_metric.py` | **different** (variant-only files; no app counterpart) | Pure image/log inspectors; no project aperture |

**[D] Consequence:** a tool like `terrain_sample_shot.py` called from `variant3d/tools` uses `RUNNER = TOOLS/godot_runner.py` = *variant* runner (`terrain_sample_shot.py:36-40`) but its Godot argv hardcode `--path app` (`:209-216,333-341`), and result-JSON lookup hardcodes `ROOT/"app"/".godot_queue"` (`:145`). Its PNG/config outputs go to `SHOTS = variant3d/shots` (`:40,63-69`) — a directory that does **not** currently exist (E20). The same mixed aperture applies to `full_map_shot.py`: compositor blocks resolve under `variant3d/assets/terrain/blocks` (`:87-94`) while `--gen-dump` asks Godot to boot `app` (`:138-145`) and reads ticket status from `app/.godot_queue` (`:173`). **Do not treat these as fresh-port captures without explicit COORD-owned paths and verification.**

### 3.2 Per-tool detail

| Tool (path) | CLI | Produces | Prerequisites | Headless / GPU-windowed |
|---|---|---|---|---|
| `variant3d/tools/terrain3d_shot.py` | `python variant3d\tools\terrain3d_shot.py --shot <png>` (doc `:11-14`) | Luma/ROI stats, seam heuristic, M0/M0.6/donor comparison, `VERDICT nonblank_1280x720` (`:94-144`); reads `app/shots/terrain3d_m06.png` by default (`:25-30`) | Existing legacy PNG + `app/shots/terrain3d_m06.json` (`:99,127-141`); numpy+Pillow; fixed ROI `(160:560,250:1030)` (`:33`) | **Headless, no Godot launched** (`:9`). Legacy art-pass instrument; not for 240²/320² fresh capture [I] |
| `variant3d/tools/heightmap3d_shot.py` | `python variant3d\tools\heightmap3d_shot.py` (verify); `--submit --id g33-* --timeout 180`; `--no-headless`; `--shot/--json` (`:18-24,169-182`) | New `hm3d_*.json` stats; image verdict `PASS/FAIL`; optional one runner capture (`:227-247`) | `app/scripts/heightmap3d_sandbox.gd` must exist (`:36-48,124-126` — it does); id must start `g33-` (`:184-186`); default RUNNER is `app/tools/godot_runner.py` (`:37`) | **Verify = headless Pillow only.** `--submit` default headless GPU/software; `--no-headless` windowed. Heuristic donor comparison explicitly NOT proof (`:153-166,233-238`) |
| `variant3d/tools/full_map_shot.py` | `python variant3d\tools\full_map_shot.py --gen-dump --seed 20261113 --dump <json>`; then `--dump <json> --out <png> --tile-px 64` (or `--tile-px 1`); optional `--crosscheck-png` (`:47-63,467-488`) | Whole-map PNG of size `map_w*tile_px × map_h*tile_px` (320²→20480², 240²→15360² at 64) + JSON sidecar with histograms/assertions (`:523-620`) | `--dump-map` JSON, Pillow, real port block PNGs in `variant3d/assets/terrain/blocks` (`:87-94`; E20: exists); `Image.MAX_IMAGE_PIXELS=None` (`:85`); halving fallback on memory error (`:540-560`) | **Compositor is headless, deterministic, no GPU.** Only `--gen-dump` submits Godot, and it hardcodes `--path app` (`:138-145`) → use a variant dump produced separately for a fresh port. **Diagnostic compositor, not the in-game renderer** (`:38-42,117-127`) |
| `variant3d/tools/compare_shots.py` | `python variant3d\tools\compare_shots.py --shot <png> --ref <png> [--crop x,y,w,h] [--threshold 0.80] [--json]` (`:9-13,132-142`) | Score 0..1 via SSIM if scikit-image present, else normalised MAD; `verdict PASS/FAIL` (`:105-129,150-173`); JSON if `--json` | Pillow; optional scikit-image | **Headless, no GPU/network/donor access** (`:2-7`). Default 0.80 is a **smoke placeholder**, not a fidelity gate (`:15-18`); legitimate only candidate-vs-candidate at fixed camera (`A05:189-193`) |
| `variant3d/tools/terrain_ab_metric.py` | `python variant3d\tools\terrain_ab_metric.py <candidate> [<reference>] [--compare-ref FOLDER] [--crop x,y,w,h \| --crop-frac x0,y0,x1,y1] [--json] [--per-file]` (`:22-33,722-744`) | `terrain_ab_metric/1` JSON: color, block variance, autocorrelation, directional gradient, seam/repetition, flags (`:10-21,482-508,767-844`) | numpy + Pillow (`:44-72`); images ≥8×8 after crop (`:169-172`); default donor folder `C:\Users\Maxym.Oboyshev\Downloads\c3` (`:52`, E20: 12 files) | **Headless**; no Godot, no GPU. `SMOKE METRIC … NOT a fidelity gate or donor proof` (`:62,653`); **no `--baseline`/ARI implemented** (`C01:204-205`) |
| `variant3d/tools/terrain_compare.py` | `python variant3d\tools\terrain_compare.py --shot <png> --ref <jpg> [--water-ref <jpg>] [--out <png>] [--seed S] [--no-water]` (`:23-30,306-328`) | `terrain_sample_contact.png` feature-aligned contact sheet + JSON pairs with SMOKE scores (`:194-303`) | Shot + reference JPG must exist (`:319-324`); default shot `variant3d/shots/terrain_sample.png` currently **absent** (E20) → pass explicit `--shot`; donor refs in `Downloads/c3` exist | **Headless Pillow**; imports `compare_shots.py` by path (`:108-114`); every number labelled `SMOKE ONLY — feature-aligned, not a fidelity gate` (`:56`) |
| `variant3d/tools/terrain_sample_shot.py` | `python variant3d\tools\terrain_sample_shot.py` (print commands); `--scan-seeds [N]`; `--capture --seed 9`; `--validate-only` (`:7-17,428-442`) | Seed-scan JSON dumps + `app`-style `terrain_sample_128_seedscan{,_best}.json`; `terrain_sample_128.png` + validation report with `real_renderer_gate` (`:299-327,344-393`) | `app/shots/terrain_sample.json` (`:63-64`; E20: exists); runner `tbb0-*` ids; windowed 1280×720; 800×600 CPU fallback is rejected (`:21-23,78-81,374-388`) | Scan = **headless runner `godot --headless --path app`** (`:209-216`); capture = **windowed runner, no `--headless`** (`:333-341`); PNG validation itself headless Pillow. Mixed aperture per §3.1 |
| `variant3d/tools/terrain_land_shot.py` | `python variant3d\tools\terrain_land_shot.py --scan \| --capture --seed 20261113 \| --validate-only` (`:9-13,114-122`) | `terrain_land*.png`/JSON under `variant3d/shots`, job ids rewritten to `tbb0-land-*` (`:24-47`) | Same as `terrain_sample_shot.py`; land/nowater2 config `app/shots/terrain_land.json` exists (E20) | Same mixed mode: scan headless, capture windowed |
| `variant3d/tools/smallmap_capture.py` | `python variant3d\tools\smallmap_capture.py stats <png> [<png>...] [--reference <png>]`; `... scan-stderr <log>...` (`:7-9,61-70`) | JSON image stats (`non_black_fraction`, `mean_luma`, `full_width_dark_rows`, size) or `script_error_lines` (`:21-58`); prints "No donor parity is claimed" (`:47`) | numpy+Pillow (`:17-18`); PNG path | **Headless**; no Godot, no writes |
| `variant3d/tools/scan_map.py` | `python variant3d\tools\scan_map.py --dir <dump-dir>` (`:2-5,446-449`) | Gate rows + `ALL GREEN`/exit 1 (`:467-510`) | Dump JSONs; no Godot | **Headless pure Python** |
| `variant3d/tools/assert_clean.py` | `python variant3d\tools\assert_clean.py [--json] [--max-lock-age SEC] [--ignore-history]` (`:262-271`) | `VERDICT: CLEAN/DIRTY` (`:221-259`) | Finished runner batch | Headless; read-only |

**Adjacent, non-capture tools (inventory only, not gates):** `terrain_geometry_verify.py:2-16,626-630` (headless `--dump FILE.json [--baseline]` + `--json`, dump-based geometry); `terrain_piece_render.py:2-12` (headless Pillow piece renderer, legacy `app/tools/piece_specs`); `terrain_blend_test.py:434-446` (`--mode --spec --out-dir --grid --cell-px --seed`, headless blend A/B); `gen_variant_maps.py:2-12` (macro-layout preview PNGs, donor-textured); `extract_map.py:2-14`, `parse_terrain.py:2-6`, `import_donor_map.py:2-16`, `import_donor_masks.py:2-14`, `export_donor_patterns.py:2-9`, `donor_gen.py:2-16` (decoder/preview lane, P04 ownership). None of these is an acceptance gate for the fresh port; all are read-only candidates for reuse.

---

## 4. One Godot at a time / runner spool (binding)

- **[O]** Only launch form: `python variant3d\tools\godot_runner.py run --id <UNIQUE> --timeout <sec> -- <godot args>`; direct `godot` is forbidden because it created orphaned 100 %-CPU zombies (`AGENT_PROTOCOL.md:14-34`; `CHARTER.md:80-82`). PowerShell `;`, never `&&` (`E03:76-77`).
- **[O]** Spool = `variant3d\.godot_queue` with `jobs/`, `results/`, `counter`, `now_serving`, `godot.lock`, `status.json` (`godot_runner.py:47-53`); the **2D `app/.godot_queue` is a different FIFO** (`app/tools/godot_runner.py:47`). Never run the 2D `doctor` during a variant job — it kills Godot by name (`A09:471`; `app/tools/godot_runner.py` doctor implementation).
- **[O]** Results land in `variant3d\.godot_queue\results\<8-digit-ticket>_<job-id>\` with `stdout.txt`, `stderr.txt`, and a sibling `<ticket>.json`; `status` prints pending/lock/statistics (`E04:176,180-192`; `godot_runner.py:488-509`). A pending job has no result directory yet; queue waits of 100–400 s are normal, **do not re-submit** (`AGENT_PROTOCOL.md:39-49`).
- **[O]** Required preflight each session: `pending=0`, `godot.lock=free`, `now_serving == next_ticket`, zero live Godot processes (`E03:85-89`; `E06:50-60`). Submit one job at a time, re-check `status` after each result (`E03:95-101`).
- **[O]** Remediation is only the runner's own `status`/timeout/`cancel --ticket`/`unwedge`/`doctor`/`ack --reason` under COORD authority (`godot_runner.py:512-647`; `C02:408-448`). Analysis workers (P03 included) call `status` only; **P03 called no runner subcommand at all**.
- **[O]** Current snapshot (E19): `counter=607`, `now_serving=607`, `pending=0`, lock absent, history 500 with unacked tickets **575** (`bbclamptidy01-parse`, timed-out), **582** (`terrainswarm-g1-selftest`, skipped), **585** (`g04-uitest`, timed-out). A bare CLEAN assertion is therefore DIRTY today. Do not `ack` these to fake green; if they are genuinely retired diagnostics, COORD must record explicit reasons or use `--ignore-history` with the reasons in the gate log (`C02:349-356`).

---

## 5. Current baseline file paths (for comparison)

| Role | Path | Status / caveat |
|---|---|---|
| P0 64² visual baseline | `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\p0fresh01\p0_final_formula.png` | **Exists** (E20); A11 current capture / A09 "keep untouched" (`A11_reference_metrics.md:18,77,95,121`; `A09:72`) |
| P0 atom baseline (prior wave) | `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\g04\p0_64.png`; `...\l07b\p0_64.png` | Both exist (E20); windowed 1280×720; `stats` numbers in `G04:220-232`, `L07:167-178` |
| Prior real-map baseline | `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\g04\realmap.png` (+ `realmap.png.raw.png` sidecar) | Exists (E20); seed 20261113, shipped **240²** config (`G04:234-251`). `l07b/realmap.png` deliberately **absent** (`L07:180-198`) |
| A09 proposed baselines | `%TEMP%\opencode\a09\smallmap64_p0_fresh.png`, `...\realmap320_fresh.png`, `...\real_map_320.json` | **Do not exist yet** (`A09:62-99`; E20: `a09` dir missing); must be created by COORD |
| Fresh 240² / 320² baseline | **NONE** | `[U]` No fresh capture of the new terrain pipeline exists; freeze one per size before any A/B |
| Third-party donor stills | `C:\Users\Maxym.Oboyshev\Downloads\c3\` (12 images, e.g. `cossacks-3-v1-498085.jpg`, `articolo-787.jpg`) | **Exist** (E20); unknown build/camera/compression; distribution hints **only**, `UNVERIFIED` parity (`A09:437-441`; `A05:162-166`) |
| Legacy heightmap shot | `app\shots\hm3d_full.png`, `app\shots\hm3d_full.json` | Exist (E20); G3-2 app sandbox, not the fresh variant |
| Geometry dump | `app\shots\g32_dump.json`; scan dumps `app\scans\{scan_7.json,atomic_7.json,atomic_7b.json,atomic_7c.json}` | Exist (E20); legacy 2D dumps, input for `scan_map.py` / `terrain_geometry_verify.py` |
| Test-result baselines | `variant3d\selftest.json`, `variant3d\uitest.json`, `variant3d\tests\results\t_render_mode.json`, `...\t_map_variety.json`, `...\t_terrain_only.json` | All exist but **stale** (§0); accept only freshly written results |
| `app/shots/*.png` generally | Mostly `.png.import` stubs, only a few real PNGs (`hm3d_full.png`, `w55_*.png`) | **[D]** Explicit `--shot`/`--ref` paths are mandatory; do not assume default shots exist (E20) |

---

## 6. Exact commands COORD should use — fresh 240² / 320² capture + A/B metric

**These are PLANNED commands. P03 ran none of them.** Replace `<T>` with `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\p03` (create outside the repo, `E06:38`). All ids below are new/unique; do not reuse.

### 6.1 Preflight (no Godot)

```powershell
python variant3d\tools\godot_runner.py status
python variant3d\tools\assert_clean.py --json
New-Item -ItemType Directory -Force -Path "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\p03" | Out-Null
```

Accept `pending=0`, lock free, counters aligned, zero live Godot; resolve the three unacked history entries first (§4).

### 6.2 Pin size overlays (outside repo; never edit shipped config)

```powershell
'{"gameplay":{"render_mode":"3d","random_seed":20261113,"map_width_tiles":240,"map_height_tiles":240}}' | Out-File -FilePath "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\p03\map_240.json" -Encoding ascii -NoNewline
'{"gameplay":{"render_mode":"3d","random_seed":20261113,"map_width_tiles":320,"map_height_tiles":320}}' | Out-File -FilePath "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\p03\map_320.json" -Encoding ascii -NoNewline
```

`--config` is parsed at `main.gd:1338-1341` and merged over `res://config.json` (`A09:76`); `--seed` is applied after merge (`main.gd:1356-1363`, `A09:89`). The shipped file currently says **240²** (E19) — do not call a 240² frame "320²" (`A09:42`).

### 6.3 Fresh WINDOWED captures — one runner job at a time

```bat
python variant3d\tools\godot_runner.py run --id p03-fresh-240 --timeout 600 -- --path variant3d -- --config "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/p03/map_240.json" --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/p03/fresh_240.png" --screenshot-frames 10 --seed 20261113 --timeout 600
python variant3d\tools\godot_runner.py status
python variant3d\tools\godot_runner.py run --id p03-fresh-320 --timeout 600 -- --path variant3d -- --config "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/p03/map_320.json" --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/p03/fresh_320.png" --screenshot-frames 10 --seed 20261113 --timeout 600
python variant3d\tools\godot_runner.py status
```

- **No `--headless`**: headless `--screenshot` writes the 800×600 CPU fallback (`main.gd:3-5`; `terrain_sample_shot.py:374-388`). `--screenshot-frames 10` uses the `Screenshot3DViewport` path (`A09:32`; `G04:248-251`).
- `--timeout 600` after the second `--` overrides the 120 s main watchdog (`main.gd:31,1334-1336,1588-1611`; `E05:119-123`); runner `--timeout 600` must exceed it. Never combine with `--dump-config` (`E05:180-198`).
- If main's blank detector rejects a valid olive frame, inspect `<name>.png.raw.png` and record an instrument defect; **do not edit the detector** (`A09:90`).
- Freeze these two PNGs as the **fresh baselines** (copy to immutable `fresh_240_baseline.png` / `fresh_320_baseline.png` under `<T>`); later candidates must use identical config, seed, camera and crop.

### 6.4 Capture integrity (headless, after each result JSON exists)

```bat
python variant3d\tools\smallmap_capture.py stats "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/p03/fresh_240.png" "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/p03/fresh_320.png"
python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\<ticket240>_p03-fresh-240\stderr.txt variant3d\.godot_queue\results\<ticket320>_p03-fresh-320\stderr.txt
```

Require 1280×720, non-blank, `full_width_dark_rows=0`, `script_error_lines=0`, and the stdout `screenshot capture diag` with `camera_current=true`, `world_parent=Screenshot3DViewport`, plausible `camera_pos/target` (`G21:54-58`; `G04:247-251`). Record, do not infer, these strings.

### 6.5 A/B metric — what the current tool can actually do

```powershell
# Like-with-like candidate vs frozen baseline, SAME pixel crop on both (PORT APPROX)
python variant3d\tools\terrain_ab_metric.py "<T>\candidate_320.png" "<T>\fresh_320_baseline.png" --crop 120,60,1040,580 --json

# Third-party donor-still distribution — hints only, parity UNVERIFIED
python variant3d\tools\terrain_ab_metric.py "<T>\candidate_320.png" --compare-ref "C:\Users\Maxym.Oboyshev\Downloads\c3" --crop-frac .35,.55,.48,.70 --json --per-file

# Same-scene determinism only (NOT donor parity)
python variant3d\tools\compare_shots.py --shot "<T>\candidate_320.png" --ref "<T>\candidate_320_repeat.png" --threshold 0.9999 --json
```

- `--crop 120,60,1040,580` is the previously used ground box (`L05_feature_integration.md:98`); `--crop-frac .35,.55,.48,.70` is A11 ref-A's ground ROI (`C01:89-92`, `A05:341-344`). Use the **same** box/fraction on both sides; never compare a whole port frame against a cropped donor still (`C01:210-211`).
- The tool emits `flags`, not verdicts, and its label is `SMOKE METRIC - heuristic only, NOT a fidelity gate or donor proof` (`terrain_ab_metric.py:62,555-591`). **There is no `--baseline` or ARI** (`C01:204-205`); A09's ARI formula is a proposal, not runnable code (`A09:328-352`). Do not report an "ARI pass".
- `compare_shots.py`'s 0.80 default is a placeholder; it is only meaningful for same-scene/camera determinism at a high threshold (`compare_shots.py:15-18`; `A05:189-193`).

### 6.6 Structural / dump lane (headless, no capture)

```bat
python variant3d\tools\godot_runner.py run --id p03-dump-240 --timeout 600 --max-wait 3600 -- --headless --path variant3d -- --seed 20261113 --config "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/p03/map_240.json" --dump-map "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/p03/dump_240.json" --timeout 600
python variant3d\tools\godot_runner.py run --id p03-dump-320 --timeout 600 --max-wait 3600 -- --headless --path variant3d -- --seed 20261113 --config "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/p03/map_320.json" --dump-map "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/p03/dump_320.json" --timeout 600
python variant3d\tools\scan_map.py --dir "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/p03"
```

Use a dedicated dump directory (not the mixed `app/scans`), because `scan_map.py` scans **every** `*.json` with `map_w`/`terrain` keys in `--dir` (`scan_map.py:451-463`).

---

## 7. Recommended gate / capture sequence (COORD-owned)

| Step | Action | PASS condition | On FAIL |
|---:|---|---|---|
| 0 | `godot_runner.py status` + `assert_clean.py --json`; `git status` shows no `app/` diff; freeze config SHA | `pending=0`, lock free, counters aligned, CLEAN with recorded reasons, `app/` untouched | STOP; resolve queue/history first, never `ack` to fake green |
| 1 | Static / parse: `py_compile` on new tools, `--check-only --script` on new `terrain_donor_*.gd` | `SCRIPT ERROR=0`, no parse errors (`C02:103-133`) | STOP; fix cited cause |
| 2 | `t_map_variety` 5/5 + `t_render_mode` PASS 10/10 `seam_missing=false` | Fresh JSONs, mtime after START | STOP; rollback behind legacy switch (`CHARTER.md:61`) |
| 3 | Fresh `--dump-map` at 240² and 320² (§6.6), two runs each for determinism; `scan_map.py` ALL GREEN | Byte-identical same-seed dumps; all scan gates (`scan_map.py:478-493`) | STOP; determinism before any visual claim (`A05:207-223`) |
| 4 | Freeze fresh WINDOWED 240² / 320² baselines (§6.3–6.4); second-agent visual read R1–R6 | Admissibility G0-a…e; non-blank 1280×720; `script_error_lines=0`; diag recorded (`G21:52-58`) | Capture UNVERIFIED → FAIL; no metric may rescue it |
| 5 | Candidate capture at identical config/seed/camera/crop; metric per §6.5; donor folder as hints only | Like-with-like deltas + honest prose; `parity=UNVERIFIED` | Visible artifact overrides green numbers (`G21:241-250`) |
| 6 | Regression on final tree: selftest 29/29, uitest 17/17, `t_render_mode`, `assert_clean` CLEAN | Fresh results + `app/` byte-unchanged | Rollback; re-run to green (no threshold change) |
| 7 | COORD sign-off only: cross-check 30 reports, write `spec/`, record verdict vocabulary | `gates green / internal consistency PASS / donor parity UNVERIFIED` | No worker self-certifies (`SWARM_BOARD.md:39-45`) |

**Ordering rationale [D]:** determinism before structure before visual before regression, mirroring `A05:207-223`; regression last so it certifies the final integrated tree.

---

## 8. Risks

1. **Mixed tool aperture [O/D]** — byte-identical `variant3d/tools` copies still boot `app/` and reference `app/.godot_queue` (`§3.1`). A "fresh capture" made with default args may be a 2D app frame. Mitigation: explicit `--path variant3d`, explicit absolute `--config`/output paths, verify stdout config/camera diag before scoring.
2. **Stale-green JSON [O]** — 29/29 and 17/17 can predate the job (`E04:205-211`, `E05:84-86`). Require mtime-after-START plus result-envelope evidence.
3. **Watchdog vs runner timeout [O]** — without user `--timeout 600`, selftest/uitest force-exit at ~120 s (`E05:85,119-123`). Both limits must be set consistently.
4. **CLEAN not currently satisfiable [O]** — 3 unacked failure statuses (E19). `--ignore-history` hides but does not resolve them; C02 forbids manufacturing CLEAN.
5. **Fake metric gate [O]** — `terrain_ab_metric.py` is smoke-only and has no ARI; `compare_shots.py` 0.80 is a placeholder; donor JPEGs are different scenes (`E07`, `E16`, `A09:437-441`).
6. **Size confusion [O]** — shipped config is 240² while legacy specs say 320² (`A09:42`, E19). Pin both with overlays; label captures by actual size.
7. **Capture-integrity traps [O]** — `--dump-config` + `--screenshot` exits before capture (`E05:180-198`); runner exit 0 without PNG (`E05:180-198`); 800×600 headless fallback (`main.gd:3-5`); blank-detector false rejection with `.raw.png` sidecar (`A09:90`).
8. **Queue contention [O]** — FIFO waits 100–400 s are normal; re-submission creates duplicate tickets and starves the queue (`AGENT_PROTOCOL.md:39-49`).
9. **Huge compositor PNGs [D]** — 320² at `tile_px=64` is 20 480² (~419 Mpx); fallback halves `tile_px` on memory errors and renames the output (`full_map_shot.py:540-567`), so verify the sidecar's `tile_px` before comparing images.

---

## 9. UNVERIFIED register

| Item | Status | Why / owner |
|---|---|---|
| Fresh 240² / 320² capture of the donor-faithful terrain | **UNVERIFIED — does not exist** | COORD must produce (§6.3) |
| Fresh baseline for A/B | **UNVERIFIED** | Freeze before candidate comparison (§5) |
| Any donor-parity statement | **UNVERIFIED** | No donor GPU A/B frame; CHARTER:41,125-126 |
| Whether `variant3d/tools/terrain_sample_shot.py --capture` still works after aperture repair | **UNVERIFIED** | It currently boots `app/` (`terrain_sample_shot.py:209-216,333-341`); P03 ran nothing |
| Whether `terrain3d_shot.py` / `heightmap3d_shot.py` are useful for the fresh module | **UNVERIFIED / probably not** | Legacy M0/M0.6 and G3-2 sandbox targets (`E14`) |
| Fresh 29/29, 17/17, 10/10, 5/5, CLEAN, ALL GREEN for today's tree | **UNVERIFIED** | P03 read stale JSONs only; no runner job |
| Whether `assert_clean` can be made CLEAN without `--ignore-history` | **UNVERIFIED** | 3 unacked history entries; COORD decision (E19) |
| Donor still camera/crop/build and reference bands | **UNVERIFIED** | Third-party JPEGs (`A09:437-441`; `A05:162-166`) |
| A09 ARI implementation | **UNVERIFIED — not implemented** | `C01:204-205`; spec only at `A09:328-352` |
| `variant3d/shots` / `variant3d/scans` outputs | **UNVERIFIED** | Directories absent at read time (E20); tools create parents on demand |
| Full dump contract (`meta` generation keys, props arrays) of the fresh module | **UNVERIFIED** | A05:390; D/A tickets own it |

---

## 10. Open questions

1. **Q1 (COORD):** Which size is canonical — shipped `config.json` 240² (E19) or spec-level 320² (`A09:37-42`)? P03 recommends both explicit overlays and no silent substitution.
2. **Q2 (COORD / implementation owner):** Will the mixed-aperture tools be repaired to accept `--project variant3d`, or will COORD bypass them with direct runner commands (§6)? This report changes no tool.
3. **Q3 (COORD):** How to clear tickets 575/582/585 — legitimate `ack --reason`, `--ignore-history` with recorded rationale, or leave CLEAN explicitly unclaimed?
4. **Q4 (A05/COORD):** Does §6's command set satisfy A05's planned harness (`A05:297-339`), or should `terrain_qa_harness.py` be built first? P03 only inventories existing tools.
5. **Q5 (A05 QA desk):** With no donor GPU A/B frame, is the final verdict wording fixed as "gates green / internal consistency PASS / donor parity UNVERIFIED" (`A05:357-358`)?
6. **Q6 (D02/A02):** Are 240² and 320² expected to have the same RNG stream shape, or is cross-size comparison advisory only (`A05:134-136,367-368`)?
7. **Q7 (COORD):** Who owns the second-agent visual read R1–R6 and the immutable baseline freeze? P03 performs neither.

---

## 11. Honesty / scope statement

Exactly one file was written: this report. No `.gd`, shader, config, fixture, tool, result JSON, PNG, `app/` file or git state was edited; **no Godot process was launched and no runner subcommand (including `run` or `status`) was executed**. All "current" values came from read-only file reads, hashes and listings. No test was re-run; no assertion, threshold or marker was changed; no donor binary was copied or executed. Every tool command is a **plan** for COORD. **PORT APPROXIMATION / internal consistency only; no donor parity claim is made, and donor parity remains UNVERIFIED.**

## 12. Five-line summary

1. [O] Gates are fully specified: selftest 29/29, uitest 17/17, `t_render_mode`, `assert_clean` CLEAN, `t_map_variety` 5/5, `scan_map.py` ALL GREEN — but on-disk green JSONs are stale.
2. [D] Most `variant3d/tools` capture scripts are byte-identical `app/tools` copies with hardcoded `app/` paths; they must not be treated as fresh-port capture without explicit `--path variant3d` and absolute paths.
3. [O] Fresh 240²/320² captures require one-at-a-time windowed runner jobs with size overlays and `--screenshot-frames 10`; no fresh baseline exists yet.
4. [O] `terrain_ab_metric.py` is SMOKE-only with no ARI/--baseline; use identical crops for candidate-vs-baseline and donor-folder distribution as hints only.
5. [O] Spool is `variant3d/.godot_queue`; current state 607/607, pending 0, lock free, but 3 unacked failures make bare CLEAN DIRTY; donor parity stays UNVERIFIED.

*End of P03 gates/capture inventory.*
