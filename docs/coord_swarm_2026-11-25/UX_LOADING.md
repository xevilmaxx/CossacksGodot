---
title: UX-LOAD-DOC-01 — owner UI/loading requirements and verification plan
area: coord_swarm_2026-11-25
task_id: UX-LOAD-DOC-01
owner: documentation worker
date: 2026-11-25
status: living
scope: "DOCUMENTATION ONLY — no code edits, no runner jobs launched, no test weakening, no donor-parity claim."
snapshot: "On-disk read 2026-11-25 ~11:46 local; HEAD 83b77ea (11:40:26 +0100). variant3d/scripts/main.gd and hud.gd are clean at 49aa81f7 (10:55:05 +0100) — i.e. the code described below PRE-DATES the owner directive and has NOT yet been changed for it."
---

# UX-LOADING — owner UI/loading requirements, evidence and verification plan

> **Snapshot caveat.** Every line reference below is a read of the on-disk state at the time
> stated in frontmatter, not a live measurement. Reports are fixed artifacts and may be
> superseded; re-read them and re-run gates before acting. Three of the four owners named by
> the directive (`UI-TOPBAR-01`, `LOAD-ASYNC-01`, `HUD-LAYOUT-01`) have **no report on disk**
> at write time (directory listing, `docs/coord_swarm_2026-11-25/reports/`, 2026-11-25
> ~11:46; they appear only in `PROGRESS.md:109-113`), so their results are **PENDING /
> UNVERIFIED throughout**. `GATE_FAIL_01.md` **did** land (file mtime 11:41:44). No donor
> comparison, visual or numeric, is made here — this document covers owner-reported UX and
> functional readiness only. **No parity claim.**

## 1. Owner directive (recorded, observed)

`PROGRESS.md:104-113` records the directive verbatim in substance:

| Item | Owner words (as recorded) | Label / citation |
|---|---|---|
| S1 | "the top HUD bar with resources overflows the screen" | **observed** (owner report recorded) — `PROGRESS.md:105-106` |
| S2 | "the game-speed buttons should be a dropdown" | **observed** (owner request) — `PROGRESS.md:106` |
| S3 | "loading freezes the Windows window (cannot move it)" | **observed** (owner report) — `PROGRESS.md:106-107` |
| S4 | "after the loading screen disappears something is still loading and blocks normal use" | **observed** (owner report) — `PROGRESS.md:107` |
| Requirement | "the bar must never overflow and should adapt to viewport/resolution, and when the loading screen finishes the game must be fully usable" | **observed** — `PROGRESS.md:107-109` |
| Owner split | `UI-TOPBAR-01` → `hud.gd` (responsive bar + speed dropdown); `LOAD-ASYNC-01` → `main.gd` (time-sliced/worker-thread loading, overlay hidden only when ready); `HUD-LAYOUT-01` → new `tests/t_hud_layout.gd` atom for 1024/1280/1920 widths; `UX-LOAD-DOC-01` → this file | **observed** — `PROGRESS.md:109-113` |
| Governance | "No test weakening; gates owned by their agents" | **observed** — `PROGRESS.md:113` |

**Derived consequence:** S3 is an input/event-loop symptom (main thread busy), while S4 is a
readiness/ordering symptom (work continues after overlay removal). They need separate
acceptance tests even though one ticket owns both (`PROGRESS.md:110-111`).

## 2. Current on-disk baseline (read-only; all labels explicit)

| Topic | What is on disk now | Label / citation |
|---|---|---|
| Top bar construction | Full-width `CenterContainer` strip (`:384-389`) holding a `PanelContainer` with `clip_contents = true` (`:390-395`), six resource icon+label pairs (`:397-407`), idle/slots buttons, separators, status label (`:408-424`). | **observed** — `variant3d/scripts/hud.gd:381-424` |
| Speed controls | Four separate `Button`s from the loop `[["II",0.0],["1x",1.0],["2x",2.0],["4x",4.0]]`, each wired to `_on_speed()`; then Menu button, `speed_label`, `settings_label`. **No `OptionButton`/dropdown exists in `hud.gd`.** | **observed** — `hud.gd:428-443`, `:495-498`; absence by read of whole file (2026-11-25) |
| Intended overflow guard | Comment says the strip "clips instead of spilling"; `_apply_scale()` walks `uifs`/`uimw`/`uimh` metadata and recomputes `top_center.offset_top/bottom` on resize. | **observed** — `hud.gd:312-317`, `:224-232`, `:266-268`, `:294-311` |
| Scale law | `ui_scale_for(vp) = clampf(min(vp.x/1280, vp.y/720), 0.75, 2.5)` — scaling follows the viewport, so clipping/minimum-size behaviour does not automatically improve with resolution. | **observed** (code) / **derived** (consequence) — `variant3d/scripts/config.gd:751-754` |
| Why overflow is plausible | `CenterContainer` sizes its child to the child's combined minimum width; the bar's summed minimum widths and `separation=10` may exceed a 1024-wide viewport, in which case clipping hides controls rather than reflowing them. | **inferred** — `hud.gd:384-395`, `:397-443`; owner symptom `PROGRESS.md:105-106`. **UNVERIFIED** — no width measurement has been run. |
| Test hook exists | `hud_report()` already exposes `"top_bar": top_panel != null and top_panel.visible`. It checks presence/visibility only — **not** fit or bounds. | **observed** — `hud.gd:1886-1897` |
| Loading path (interactive) | Start click → `_on_menu_chosen()` → `_do_async_load(cfg)` fire-and-forget coroutine; headless/test modes stay synchronous via `_setup_full_game()`. | **observed** — `main.gd:253-268`, `:229-244` |
| Loading overlay | `CanvasLayer` layer 30, dim + card + title + stage label + `ProgressBar` + percent label; `_set_loading()` updates all; `_hide_loading()` only clears flags and `queue_free()`s the layer. | **observed** — `main.gd:455-519` |
| Time slicing that DOES exist | `_loading_tick()` awaits two `process_frame`s between stages; `_do_async_load()` awaits at 0.02/0.06/0.14/0.34/0.52/0.66/0.76/0.86/0.90/0.94/1.0. | **observed** — `main.gd:521-528`, `:539-573`, `:576-586`, `:643-645` |
| Remaining freeze cause | Each stage body (`game._gen_base()`, `_gen_forests()`, `_gen_resources()`, `_gen_finish()`, `_assign_tileblocks()`, `setup_spawns()`, world/camera/HUD/input construction) still runs synchronously to completion inside one frame. Inter-stage awaits repaint the bar but do **not** keep the Windows window draggable during a long stage. No worker thread is present. | **derived** from `main.gd:550-641` + `config.gd`-independent read; owner symptom `PROGRESS.md:106-107`. **UNVERIFIED** by measurement. |
| Readiness at hide time | Ordering only: world (`:578-585`), camera (`:588-611`), HUD (`:612-626`), input (`:627-629`), 3D hooks/FX path (`:630-631`), AI (`:635`), audio (`:636-641`), then final tick and `_hide_loading()` (`:643-645`). No explicit readiness flag or assertion gates the hide; `_hide_loading()` does not check world/HUD/input/FX. | **observed** (ordering, code) / **inferred** (readiness risk) — `main.gd:578-645`, `:512-519` |
| Prior gate diagnosis | Recent banner-only selftest/uitest failures were a **queue/harness race**, not game code: 75-byte banner, 0-byte stderr, no report write, each overlapping another Godot job; `reap_spawned_godot()` cross-kill is the best-fitting mechanism. | **observed/diagnosed** — `reports/GATE_FAIL_01.md:7,42-45,62-99,116-129` |
| Gate status | Per-job results do not imply an integrated green tree; only COORD's final gate can claim that. At writing time the README itself is a **2026-11-24 snapshot** and its "preferred" runner launch with `--stay` is stale; follow `launch_variant3d.bat` for manual play. | **observed** — `PROGRESS.md:195-201`; `docs/variant3d/README.md:16-17,118-122`; `RUN_GUIDE.md:18,33` |
| README loading sections | **None exist.** `docs/variant3d/README.md:110-158` covers launch and runner/tests only; no loading/overlay/responsiveness section was found at writing time. Treat any expected loading guidance there as **UNVERIFIED / PENDING** (probably to be added by an owner). | **observed** (full-file read, 243 lines) — `docs/variant3d/README.md:1-243` |

## 3. Requirement → evidence → owning file → acceptance test

Labels are per row; "UNVERIFIED" means no landed report/measurement backs the PASS claim.

| Req | Requirement | Evidence (label) | Owning file / ticket | Acceptance test | Status |
|---|---|---|---|---|---|
| R1 | Top bar never overflows; adapts to viewport/resolution | Owner symptom `PROGRESS.md:105-106` (**observed**); bar/clip/scale code `hud.gd:381-395`, `:294-317`, `config.gd:751-754` (**observed**); mechanism of overflow **inferred**, unmeasured | `variant3d/scripts/hud.gd` — `UI-TOPBAR-01` (`PROGRESS.md:109-110`) | `t_hud_layout.gd` at 1024×768, 1280×720, 1920×1080: bar rect fully inside viewport (left ≥ 0, right ≤ width), no control clipped, all speed controls reachable by click; resize event re-runs the same check | **UNVERIFIED / PENDING** — atom not on disk |
| R2 | Game speed is a dropdown | Owner request `PROGRESS.md:106` (**observed**); four Buttons now `hud.gd:428-433` (**observed**) | `variant3d/scripts/hud.gd` — `UI-TOPBAR-01` (`PROGRESS.md:109-110`) | One dropdown control with the four speed values (II/pause, 1x, 2x, 4x); selecting each changes `set_speed`/`game.paused` through `hud.speed_cb` (`main.gd:616-622`) and `refresh_speed()` (`hud.gd:491-493`) shows the right text; no leftover separate speed buttons | **UNVERIFIED / PENDING** |
| R3 | Windows window stays responsive during load (movable) | Owner symptom `PROGRESS.md:106-107` (**observed**); synchronous stage bodies `main.gd:550-641` (**observed**), freeze mechanism **derived** | `variant3d/scripts/main.gd` — `LOAD-ASYNC-01` (`PROGRESS.md:110-111`) | During a real windowed Start click, drag the window title bar at every progress stage; it moves continuously; progress bar advances (no stuck frame); engine/Windows reports "responsive". Headless atom alone is insufficient — windowed observation required | **UNVERIFIED / PENDING** — no loader atom or report landed |
| R4 | Overlay hides only when world/HUD/input/FX are ready | Owner symptom `PROGRESS.md:107` (**observed**); `_hide_loading()` unconditional at `main.gd:643-645`, created nodes at `:578-641` (**observed**), readiness gap **inferred** | `variant3d/scripts/main.gd` — `LOAD-ASYNC-01` (`PROGRESS.md:110-111`) | Atom asserts all readiness flags true **before** `loading_layer` is freed; a deliberate slow-stage injection shows overlay still visible while any subsystem is not ready; no order where overlay disappears first | **UNVERIFIED / PENDING** |
| R5 | No post-load blocking; game fully usable when overlay disappears | Owner requirement `PROGRESS.md:107-109` (**observed**) | `variant3d/scripts/main.gd` — `LOAD-ASYNC-01`; integration check by COORD | Immediately after overlay hide: no further asset/mapgen stage runs; input responds, HUD buttons/speed dropdown respond, camera/FX active; selftest 29/29 + uitest 17/17 + `assert_clean.py --json` CLEAN on a quiet queue | **UNVERIFIED / PENDING** — gates are snapshots; `RUN_GUIDE.md:35-57` |
| R6 | Existing gates and 2D port stay green | `RUN_GUIDE.md:35-57`, `TEST_MATRIX.md:65-66` (**observed**); per-job ≠ integrated `PROGRESS.md:195-201` (**observed**) | COORD (final gate); owners keep their own targeted smokes | Final gate once, strictly serial, after all owners land; 2D `app/**` untouched | **UNVERIFIED / PENDING** |
| R7 | Gate failures attributed to the right owner file | `GATE_FAIL_01.md:42-45,116-129` (**observed**) | Runner/queue → COORD only (`GATE_FAIL_01.md:131-139`); game code → `hud.gd`/`main.gd` owners | Banner-only + empty stderr + no report write ⇒ harness/queue race, route to COORD, **not** to `hud.gd`/`main.gd`; genuine parse errors (`SCRIPT ERROR`) route to the owning `tests/*.gd` | **observed** diagnosis; **UNVERIFIED** for any future occurrence |

## 4. Verification checklists (tick only with cited evidence)

### 4.1 Window responsive during load (R3)
- [ ] Launch **windowed** via `launch_variant3d.bat` — never a runner job for a windowed game (`RUN_GUIDE.md:23-33`; `docs/variant3d/README.md:118-122` is stale, `RUN_GUIDE.md:18`).
- [ ] Click Start and, at each progress stage, drag the window title bar; record the stage label shown (`main.gd:483-484`, stage strings `:539-643`).
- [ ] Progress bar visibly advances without a frozen frame (`main.gd:503-510`, `:521-528`).
- [ ] If any stage blocks dragging: record the stage string and route to `LOAD-ASYNC-01` (`PROGRESS.md:110-111`). **Do not** accept "two awaited frames between stages" as proof — stage bodies remain synchronous (`main.gd:550-641`, **derived**).
- [ ] Result: **UNVERIFIED / PENDING** — no report or measurement landed.

### 4.2 Overlay hides only when world/HUD/input/FX ready (R4)
- [ ] Read `main.gd:578-645` and list creation order: world → camera → HUD → input → 3D hooks → AI → audio → hide.
- [ ] Confirm a readiness assertion exists in code before `_hide_loading()` (`main.gd:512-519` currently has none — **observed**).
- [ ] Confirm the overlay cannot be freed by a superseded generation except via the guard at `main.gd:521-528,542-543` (generation check exists — **observed**).
- [ ] Inject/observe a slow subsystem: overlay must stay up until that subsystem reports ready.
- [ ] Second agent confirms the ordering evidence (pattern: `TEST_MATRIX.md:59,75`).
- [ ] Result: **UNVERIFIED / PENDING**.

### 4.3 No post-load blocking (R5)
- [ ] After overlay disappears, no further `_loading_tick`/stage call executes (`main.gd:643-645` is last — **observed**).
- [ ] Input, speed control, camera and FX respond immediately in a windowed session.
- [ ] Headless atoms: selftest 29/29, uitest 17/17, `assert_clean.py --json` CLEAN on a quiet queue (`RUN_GUIDE.md:47-57`).
- [ ] Integrated artifacts (not just per-job JSON) read green (`PROGRESS.md:195-201`; `RUN_GUIDE.md:57`).
- [ ] Result: **UNVERIFIED / PENDING**; the cited gate numbers are snapshot values, not a fresh run.

### 4.4 Top bar fits at 1024 / 1280 / 1920 (R1)
- [ ] Atom `tests/t_hud_layout.gd` exists (HUD-LAYOUT-01) — **not on disk** at write time; all rows below **PENDING**.
- [ ] For each width/height pair, capture a **windowed** PNG (headless gives `SKIP_CAPTURE` — `TEST_MATRIX.md:62-64`; `RUN_GUIDE.md:68`).
- [ ] Assert `top_panel` rect inside viewport bounds; `top_panel.clip_contents` (`hud.gd:392`) must not be doing the fitting — no child may be cut off.
- [ ] Assert resize from 1280 → 1024 → 1920 and back preserves fit (`hud.gd:266-268`, `:294-317`; `config.gd:751-754`).
- [ ] Second agent re-checks every capture (`TEST_MATRIX.md:59,75`; `RUN_GUIDE.md:92`).
- [ ] Result: **UNVERIFIED / PENDING**.

### 4.5 Speed dropdown works (R2)
- [ ] Exactly one dropdown replaces the four Button loop at `hud.gd:428-433` — **not yet on disk** (**observed** current state, **PENDING** change).
- [ ] Each of the four values reachable; emission goes through `_on_speed()` → `speed_cb` (`hud.gd:495-498`; `main.gd:616-622`).
- [ ] `refresh_speed()` text agrees with selected value / paused state (`hud.gd:491-493`).
- [ ] Pause ("II", value `0.0`) sets `game.paused = true` (`main.gd:616-621`).
- [ ] Result: **UNVERIFIED / PENDING**.

## 5. Exact runner commands and unique-id convention

Run from the repo root `C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3`, with Windows `python` (not `python3`) (`RUN_GUIDE.md:14`; `TEST_MATRIX.md:72`). Agents/workers never call `godot` directly (`docs/COMMANDS.md:8-9,11-18`; `RUN_GUIDE.md:37`). The variant spool is `variant3d/.godot_queue`, **not** the 2D spool (`RUN_GUIDE.md:55`; `docs/variant3d/README.md:154-159`).

**Unique-id convention:** `<ticket-lowercase>-<purpose>[-<variant>]`, fresh for every invocation (e.g. `uxloaddoc01-hudlayout-1024`, `uxloaddoc01-loadresp-01`). Never reuse an id (`docs/COMMANDS.md:32`; `RUN_GUIDE.md:37-38`). This document's prefix is `uxloaddoc01-`.

```bat
:: 0) Queue health — ALWAYS first, read-only
python variant3d\tools\godot_runner.py status
```

```bat
:: 1) Bootstrap ONLY on a fresh checkout where variant3d/.godot/ is absent
python variant3d\tools\godot_runner.py run --id uxloaddoc01-import --timeout 900 -- ^
  --headless --path variant3d --import
```
(`RUN_GUIDE.md:39-44`; `docs/variant3d/README.md:139-144`.)

```bat
:: 2) Width rows — HUD-LAYOUT-01 atom, WINDOWED (no --headless).
::    FLAG SHAPE ONLY: the atom has not landed, so its exact CLI flags are UNVERIFIED.
python variant3d\tools\godot_runner.py run --id uxloaddoc01-hudlayout-1024 --timeout 180 -- ^
  --path variant3d --script res://tests/t_hud_layout.gd -- --width 1024 --height 768 --png "%TEMP%\uxloaddoc01\hud_1024.png"
python variant3d\tools\godot_runner.py run --id uxloaddoc01-hudlayout-1280 --timeout 180 -- ^
  --path variant3d --script res://tests/t_hud_layout.gd -- --width 1280 --height 720 --png "%TEMP%\uxloaddoc01\hud_1280.png"
python variant3d\tools\godot_runner.py run --id uxloaddoc01-hudlayout-1920 --timeout 180 -- ^
  --path variant3d --script res://tests/t_hud_layout.gd -- --width 1920 --height 1080 --png "%TEMP%\uxloaddoc01\hud_1920.png"
```
Command shape derived from `RUN_GUIDE.md:70-80` and `TEST_MATRIX.md:62-64`; `--width/--height/--png` names are **UNVERIFIED** until HUD-LAYOUT-01 lands (`PROGRESS.md:111-112`). Keep artifacts under `%LOCALAPPDATA%\Temp\opencode\...`, never in the repo (`RUN_GUIDE.md:92`).

```bat
:: 3) Loading responsiveness / readiness atom — NO TICKET OWNS SUCH AN ATOM YET.
::    Template only; do NOT submit until an atom is authored and its flags are known.
python variant3d\tools\godot_runner.py run --id uxloaddoc01-loadresp-01 --timeout 180 -- ^
  --path variant3d --script res://tests/t_load_responsive.gd
```
`res://tests/t_load_responsive.gd` does **not** exist on disk at write time — **UNVERIFIED / PENDING**. Windowed manual drag (§4.1) is the only currently available responsiveness evidence; a headless run cannot prove the window is movable (`TEST_MATRIX.md:62-64`).

```bat
:: 4) Final gates — strictly serial, once, after all owners land and the queue is quiet
python variant3d\tools\godot_runner.py run --id uxloaddoc01-selftest --timeout 300 -- ^
  --headless --path variant3d -- --self-test variant3d/selftest.json
python variant3d\tools\godot_runner.py run --id uxloaddoc01-uitest --timeout 240 -- ^
  --headless --path variant3d -- --ui-test variant3d/uitest.json
python variant3d\tools\assert_clean.py --json
```
(`RUN_GUIDE.md:46-51`; `docs/variant3d/README.md:131-137`; equivalent ids in `STATUS_WAVE7_PHASE2.md:245-249`.) Pass criteria: `selftest.json` `passed:true` 29/29, `uitest.json` `passed:true` 17/17, `assert_clean.py --json` CLEAN exit 0 (`RUN_GUIDE.md:57`). Results land in `variant3d/.godot_queue/results/<ticket>_<id>/` (`RUN_GUIDE.md:55`).

## 6. Failure policy

1. **Never weaken.** Do not edit assertions, remove `expected_pre_fix_failure` markers, change seeds or substitute headless `SKIP_CAPTURE` for a windowed PASS (`TEST_MATRIX.md:62-64,67-68`; `RUN_GUIDE.md:109`). A per-job 29/29 is not an integrated green tree (`PROGRESS.md:195-201`; `RUN_GUIDE.md:57`).
2. **Stop at first failing row.** Record the exact failed assertion and route it to the owning fix file; do not rerun hoping for green (`TEST_MATRIX.md:60-61`; `RUN_GUIDE.md:109`).
3. **Classify before blaming game code.** 75-byte engine banner + empty stderr + no report write + overlapping jobs = harness/queue race (`GATE_FAIL_01.md:42-45,62-74,116-129`); owner is COORD/runner, not `hud.gd` or `main.gd`. Drain the queue, confirm `pending=0` and a free lock, pause `tests/*.gd` edits, then run the gates one at a time (`GATE_FAIL_01.md:131-139`; `SWARM_BOARD.md:254` still labels the ticket RUNNING although its report is `status: diagnosed` — **observed** drift).
4. **Parse errors are a different class.** `SCRIPT ERROR: Parse Error` with stderr belongs to the owning `tests/*.gd` (`GATE_FAIL_01.md:112-114`; `RUN_GUIDE.md:105-107`). Keep indentation TABS and restore a backup rather than loosening a check (`RUN_GUIDE.md:107`).
5. **Second-agent re-check.** No owner self-certifies visual/layout captures (`TEST_MATRIX.md:59,75`; `RUN_GUIDE.md:92`).
6. **Report to the owning file, not across the boundary.** `hud.gd` → `UI-TOPBAR-01` (`PROGRESS.md:109-110`); `main.gd` → `LOAD-ASYNC-01` (`PROGRESS.md:110-111`); new `tests/t_hud_layout.gd` → `HUD-LAYOUT-01` (`PROGRESS.md:111-112`); runner/queue maintenance → COORD only (`GATE_FAIL_01.md:25,131-139`). This worker edits only `docs/coord_swarm_2026-11-25/UX_LOADING.md`.
7. **No parity claim.** Nothing here establishes donor visual or behavioural parity; donor-unverified values elsewhere stay labelled `PORT APPROX` (`PROGRESS.md:162-164`; `RUN_GUIDE.md:98-99`).

## 7. Evidence-availability register

| Artifact | On disk 2026-11-25 ~11:46? | Use here | Label |
|---|---|---|---|
| `PROGRESS.md:104-113` owner directive | yes | Requirements text and owner split | **observed** |
| `reports/GATE_FAIL_01.md` | yes (mtime 11:41:44) | Failure classification, gate policy | **observed** |
| `RUN_GUIDE.md` | yes | Commands, launch path, gate criteria, reporting path | **observed** |
| `docs/variant3d/README.md` loading sections | **no such sections**; file is a 2026-11-24 snapshot (`:16-17`), launch advice stale (`:118-122`; `RUN_GUIDE.md:18`) | Launch/test commands only (`:110-158`) | **observed** / **UNVERIFIED** for loading guidance |
| `main.gd` loading lines | yes, clean at 49aa81f7 | Baseline time-slicing, overlay, ordering | **observed**; freeze/readiness risk **derived/inferred** |
| `hud.gd` top-bar lines | yes, clean at 49aa81f7 | Baseline bar construction, speed Buttons, scale hooks | **observed**; overflow mechanism **inferred** |
| `reports/UI_TOPBAR_01.md` | **no** | — | **PENDING / UNVERIFIED** |
| `reports/LOAD_ASYNC_01.md` | **no** | — | **PENDING / UNVERIFIED** |
| `reports/HUD_LAYOUT_01.md` | **no** | — | **PENDING / UNVERIFIED** |
| `variant3d/tests/t_hud_layout.gd` | **no** | — | **PENDING / UNVERIFIED** |

## 8. Summary

Owner reported four UX faults — overflowing top bar, speed buttons that should become a
dropdown, a Windows window that freezes during load, and work continuing after the loading
overlay disappears (`PROGRESS.md:104-109`). On disk, a time-sliced loading coroutine with a
progress overlay already exists (`main.gd:521-645`) and the top bar already has scale hooks
and clipping (`hud.gd:294-317`, `:381-395`), but the stage bodies remain synchronous and the
speed control is still four Buttons (`main.gd:550-641`; `hud.gd:428-433`) — so the reported
symptoms are consistent with the code, yet no owner fix or acceptance measurement has landed.
`GATE_FAIL_01.md` supplies the failure-classification rule (queue/harness race vs genuine
parse error) that this plan reuses (`GATE_FAIL_01.md:116-139`). All five checklists in §4 and
all six acceptance rows in §3 are **UNVERIFIED / PENDING**; `UI_TOPBAR-01`, `LOAD-ASYNC-01`
and `HUD-LAYOUT-01` have no reports on disk. Commands in §5 use fresh `uxloaddoc01-*` ids
and the variant spool only. No test was weakened, no runner job was submitted, no game file
was changed, and no donor-parity claim is made.
