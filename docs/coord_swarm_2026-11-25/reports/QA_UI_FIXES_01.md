---
id: QA-UI-FIXES-01
title: "QA-UI-FIXES-01 — did the responsive top-bar and async-loading fixes land?"
area: coord_swarm_2026-11-25
task_id: QA-UI-FIXES-01
date: 2026-11-25
owner: read-only QA subagent
status: DELIVERED__READ_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB__ONE_REPORT_ONLY
scope: "Read-only verification of on-disk artifacts, code-vs-backup diffs and requirement-to-evidence mapping. No code/config/test/manifest/queue edit; no Godot process or godot_runner.py job; no report promoted to PASS."
labels: [observed, derived, inferred, UNVERIFIED]
snapshot: "On-disk reads 2026-11-25 (post-11:46 UX_LOADING.md snapshot). HEAD 83b77ea; variant3d/scripts/hud.gd and main.gd are MODIFIED in the working tree (uncommitted). Board Batch T is DB-tracked 11:44:52."
parity: "NO donor-parity, visual-parity or runtime-PASS claim."
---

# QA-UI-FIXES-01 — landing verification for UI-TOPBAR-01 / LOAD-ASYNC-01

## 0. Label key

- **observed** — read directly this pass (file reads with line numbers, directory
  globs, `git status`, unified diffs of live files against the named backups).
- **derived** — structural conclusion from observed rows (e.g. "diff adds a
  readiness flag but no guard in the hide function").
- **inferred** — judgement about likely effect or risk, never asserted as fact.
- **UNVERIFIED** — not checkable without a runner job, a windowed observation or
  an absent artifact. No absent artifact is assigned a cause.

This worker does not promote any owner report, atom or code diff to PASS. Where
"PASS" appears below it is either a quoted status from another artifact or an
explicitly labelled absence of one.

## 1. Sources

| Source | What it supplies | Label |
|---|---|---|
| `docs/coord_swarm_2026-11-25/UX_LOADING.md` (201 lines, frontmatter `:1-10`) | Owner directive R1–R5 (`:61-73`), checklists (`:75-113`), runner commands and unique-id convention (`:114-160`), evidence register (`:172-185`) | **observed** (full-file read) |
| `docs/coord_swarm_2026-11-25/SWARM_BOARD.md:259-288` (Batch T) | Session ids and states for UI-TOPBAR-01, LOAD-ASYNC-01, HUD-LAYOUT-01, UX-LOAD-DOC-01, LOAD-PROBE-01, QA-UX-DOC-01 | **observed** |
| `docs/coord_swarm_2026-11-25/PROGRESS.md:104-113` | Verbatim owner directive and disjoint ownership (as quoted in UX_LOADING.md §1) | **observed** (via cited doc; not re-read verbatim this pass) |
| `variant3d/scripts/hud.gd` (live, 86,604 B, mtime 11:52:24) vs `inbox/backup/hud.gd.bak-UITOPBAR01` (80,873 B, mtime 10:42:15) | Landing diff for the responsive bar and speed dropdown | **observed** (unified diff: 179 added / 34 deleted lines) |
| `variant3d/scripts/main.gd` (live, 85,219 B, mtime 11:51:51) vs `inbox/backup/main.gd.bak-LOADASYNC01` (83,697 B, mtime 10:50:40) | Landing diff for async loading, readiness flag and warm-up move | **observed** (unified diff: 31 added / 2 deleted lines) |
| `variant3d/scripts/hud.gd:108,112-114,172,273,326,390-456,490-502,513-588,590-602,629-638,2031-2041` | Current symbol lines used for citations below | **observed** |
| `variant3d/scripts/main.gd:157,462-464,517-524,526-533,535-674` | Current loader lines used for citations below | **observed** |
| `reports/HUD_LAYOUT_01.md` (231 lines) and `reports/LOAD_PROBE_01.md` (252 lines) | Atom authoring status, assertions and documented (unexecuted) commands | **observed** (contents quoted as authoring claims, **not** as PASS) |
| `reports/QA_UX_DOC_01.md` (112 lines) | Earlier documentation/assignment blockers B1–B3 and M1 | **observed** |
| `variant3d/scripts/uitest.gd:21,34,274-280` | Existing speed step calls `main.set_speed()` directly; it does not exercise a dropdown | **observed** |
| Directory globs for `UI_TOPBAR_01.md`, `LOAD_ASYNC_01.md`, `t_hud_layout.json`, `t_load_usability.json` | Absence of owner reports and run artifacts | **observed** (no matches) |
| `git status --short`, `git log -5 --oneline` | Both code files modified, not committed; HEAD 83b77ea | **observed** |

## 2. On-disk table

| Artifact (task-named unless noted) | On disk now? | Evidence / label |
|---|---|---|
| `docs/coord_swarm_2026-11-25/reports/UI_TOPBAR_01.md` | **NO** | Repo-wide glob returns no file (**observed**). UX_LOADING.md:182 already listed it PENDING. Owner `UI-TOPBAR-01` / `ses_dedb5cfdbffe9rh6Oh2C7HL1zS` still **RUNNING** (`SWARM_BOARD.md:270`). **NOT LANDED — report absent.** |
| `docs/coord_swarm_2026-11-25/reports/LOAD_ASYNC_01.md` | **NO** | Repo-wide glob returns no file (**observed**); LOAD_PROBE_01.md:56-57 independently confirms two earlier absences. Owner `LOAD-ASYNC-01` / `ses_dedb5890affedzB6Lq8J5wNje9` still **RUNNING** (`SWARM_BOARD.md:271`). **NOT LANDED — report absent.** |
| `variant3d/scripts/hud.gd` vs `inbox/backup/hud.gd.bak-UITOPBAR01` | **YES — both, diff landed** | 179 added / 34 deleted lines; live file mtime 11:52:24 > backup 10:42:15 (**observed**). Working-tree `M` in git status, uncommitted (**observed**). See §3 R1/R2. |
| `variant3d/scripts/main.gd` vs `inbox/backup/main.gd.bak-LOADASYNC01` | **YES — both, diff landed** | 31 added / 2 deleted lines; live file mtime 11:51:51 > backup 10:50:40 (**observed**). Working-tree `M`, uncommitted (**observed**). See §3 R3/R4/R5. |
| `docs/coord_swarm_2026-11-25/UX_LOADING.md` | **YES** | 201 lines, untracked (`??` in git status), status `living` (`:7`); its snapshot (`:9`) explicitly pre-dates the fixes and says main.gd/hud.gd were clean at `49aa81f7` then (**observed**). Its §3/§4 rows are therefore stale relative to the current code diff (**derived**). |
| `variant3d/tests/t_hud_layout.gd` (related, not task-named) | **YES** | Untracked; authored by `HUD-LAYOUT-01` / `ses_dedb52b4cffeblhZ66JpqnZBbj`, board state **RUNNING** (`SWARM_BOARD.md:272`); report status `AUTHORED__NO_GODOT_RUN__NO_PASS_CLAIM` (`HUD_LAYOUT_01.md:1-13`). No `t_hud_layout.json` result file (**observed**). |
| `variant3d/tests/t_load_usability.gd` (related, not task-named) | **YES** | Untracked; authored by `LOAD-PROBE-01` / `ses_dedb412e9ffe8KZdustXtfybVD`, state `DONE — TERMINATED` **authoring only** (`SWARM_BOARD.md:274`); report status `MEASUREMENT_ONLY__NO_PASS_CLAIM` (`LOAD_PROBE_01.md:1-13`). No `t_load_usability.json` result file (**observed**). |
| Owner reports promoted to PASS | **NO** | Neither owner report exists; the two atoms that do exist explicitly disclaim a PASS. Nothing in this QA promotes any of them (**observed**). |

**derived summary:** implementation edits for both owners are present on disk and
uncommitted; neither owner's report landed; the board still marks both owners
RUNNING; and neither acceptance atom has been executed.

## 3. Requirement status

Each row states the **code evidence** (what the diff actually changed) and the
**report / measurement status**. A code diff is evidence that an edit landed; it
is **not** evidence that the owner symptom is fixed at runtime.

### R1 — Top bar never overflows / adapts to viewport

- **File evidence (observed, landed):** `hud.gd:172` changes `top_center` from
  `CenterContainer` to `Control`; `:390-406` builds a viewport-anchored
  full-width `PanelContainer` holding `top_bar` with `SIZE_EXPAND_FILL`;
  `:326` calls new `_layout_top()` from `_apply_scale()`; `:513-588`
  `_layout_top()` selects normal/compact/tiny/ultra modes from `ui_vp.x`
  (thresholds 1000/700/560), resizes icons, fonts, buttons, separators and band
  height, and hides separators/status/settings at narrower widths.
- **Report / measurement:** `UI_TOPBAR_01.md` **NOT LANDED** —
  `ses_dedb5cfdbffe9rh6Oh2C7HL1zS` (board **RUNNING**, `SWARM_BOARD.md:270`).
  Atom authored (`HUD-LAYOUT-01`, `ses_dedb52b4cffeblhZ66JpqnZBbj`, **RUNNING**,
  `:272`) but no result JSON and no windowed capture (**observed**).
- **Qualification (derived/inferred):** the implementation bounds the panel with
  anchors and `clip_contents = true` and *shrinks* non-critical elements; it does
  not prove that no child is visually cut off. `HUD_LAYOUT_01.md:135-143` records
  `clipped_overflow_children` as a diagnostic, not a gate, and
  `UX_LOADING.md:102` requires "no child may be cut off" — a possible criterion
  mismatch (**inferred**).
- **Verdict:** edit **LANDED**; requirement **UNVERIFIED** at runtime.

### R2 — Game speed becomes a dropdown

- **File evidence (observed, landed):** the four-`Button` loop of the backup
  (`bak:428-433`) is replaced at `hud.gd:444-447` by one `OptionButton` from
  `_mkoption()` (`:490-502`) with the exact items
  `[["II",0.0],["1x",1.0],["2x",2.0],["4x",4.0]]` as item metadata;
  `item_selected` → `_on_speed_idx()` (`:599-602`) → `_on_speed()`;
  `refresh_speed()` (`:629-638`) mirrors external speed/pause changes into the
  dropdown without a feedback loop. `speed_buttons` is retained at `:108` but
  annotated "now empty" for API readers.
- **Report / measurement:** `UI_TOPBAR_01.md` **NOT LANDED** —
  `ses_dedb5cfdbffe9rh6Oh2C7HL1zS` (board **RUNNING**). Atom checks
  `single_speed_widget`/`speed_options`/`speed_option_metadata` exist on paper
  (`HUD_LAYOUT_01.md:128-129`) but was never run (**observed**).
- **Qualification (observed):** the existing gate step `uitest.gd:274-280` calls
  `main.set_speed()` directly and never touches the dropdown, so it cannot detect
  a regression back to buttons (same gap as `QA_UX_DOC_01.md:84`, M1).
- **Verdict:** edit **LANDED**; requirement **UNVERIFIED** at runtime.

### R3 — Windows window stays movable during load

- **File evidence (observed, landed):** `main.gd:555-558` adds an explanatory
  comment about the Windows message pump; three extra `_loading_tick` yields are
  inserted at `:594` ("Wiring camera..."), `:637` ("Wiring input...") and `:648`
  ("Starting audio..."), alongside the pre-existing inter-stage awaits
  (`:526-533`). Stage bodies themselves remain synchronous single-frame blocks
  (`:559-593`, `:620-656`).
- **Report / measurement:** `LOAD_ASYNC_01.md` **NOT LANDED** —
  `ses_dedb5890affedzB6Lq8J5wNje9` (board **RUNNING**, `SWARM_BOARD.md:271`).
  No windowed title-bar drag was performed; the load probe atom is authoring-only
  and headless (`LOAD_PROBE_01.md:149-166`, limitations 1–3).
- **Qualification (derived, from `UX_LOADING.md:55`):** inter-stage awaits
  repaint the progress bar but do not *guarantee* that the window is draggable
  during a long synchronous stage; no worker thread was added by this diff
  (**observed** absence in diff). Therefore the landed change is a partial
  mitigation, not proof of R3 (**inferred**).
- **Verdict:** edit **LANDED (partial mitigation)**; window movability
  **UNVERIFIED** — remains **NOT LANDED** as evidence.

### R4 — Overlay hides only when world/HUD/input/FX are ready

- **File evidence (observed, landed):** new `load_ready` flag at `main.gd:157`,
  reset in `_show_loading()` (`:464`); set to `true` only at `:673`, immediately
  before `_hide_loading()` (`:674`). `world.sync(0.0)` and
  `await RenderingServer.frame_post_draw` are moved behind the overlay
  (`:657-669`), with a generation recheck after the draw (`:668-669`). Extra
  ticks at `:594/:620/:637/:648` gate camera, HUD, input and audio creation.
- **Report / measurement:** `LOAD_ASYNC_01.md` **NOT LANDED** —
  `ses_dedb5890affedzB6Lq8J5wNje9` (board **RUNNING**). No slow-stage injection,
  no FX-readiness assertion, no run artifact.
- **Qualification (derived):** `_hide_loading()` itself (`:517-524`) still
  unconditionally frees the layer and does **not** check `load_ready`; the
  invariant is enforced by call-site ordering only, not by a guard. A future
  early `_hide_loading()` call would not be caught. The atom's binding check (b)
  covers world/camera/HUD/input but explicitly leaves FX readiness and
  slow-stage injection UNVERIFIED (`LOAD_PROBE_01.md:191-195`, limitation 10).
- **Verdict:** edit **LANDED**; invariant **NOT ENFORCED IN CODE** and
  **UNVERIFIED** at runtime.

### R5 — No post-load blocking; game fully usable on overlay hide

- **File evidence (observed, landed):** the two operations previously deferred
  past overlay removal — first `world.sync(0.0)` and first 3D draw — now run
  before `_hide_loading()` (`main.gd:657-674`); `load_ready` is set only after
  them and after "Ready!" tick (`:664`). No labelled stage call exists after
  `:674` in `_do_async_load()` (**observed**).
- **Report / measurement:** `LOAD_ASYNC_01.md` **NOT LANDED** —
  `ses_dedb5890affedzB6Lq8J5wNje9` (board **RUNNING**). Final gates not re-run
  for this change on this pass (no runner job permitted).
- **Qualification (observed/derived):** the atom marks `d_no_deferred_heavy_stage`
  **UNVERIFIED** because `main.gd` exposes no deferred-stage observable
  (`LOAD_PROBE_01.md:141,173-175`); `e_no_hard_engine_errors` likewise needs an
  external stderr scan (`:142`). Post-hide input/order/camera probes are direct
  calls, not real `InputEvent`s (`:167-171`). `UX_LOADING.md:71` additionally
  requires selftest 29/29, uitest 17/17 and `assert_clean.py --json` CLEAN —
  none is freshly evidenced here.
- **Verdict:** edit **LANDED**; requirement **UNVERIFIED** — remains **NOT LANDED**
  as evidence.

## 4. Remaining tests (exact jobs still needed)

### 4.1 Unique-id convention (verbatim from `UX_LOADING.md:118`)

> **Unique-id convention:** `<ticket-lowercase>-<purpose>[-<variant>]`, fresh for
> every invocation (e.g. `uxloaddoc01-hudlayout-1024`,
> `uxloaddoc01-loadresp-01`). Never reuse an id (`docs/COMMANDS.md:32`;
> `RUN_GUIDE.md:37-38`). This document's prefix is `uxloaddoc01-`.

Run from the repo root with Windows `python` (not `python3`); variant spool
`variant3d/.godot_queue`, not the 2D spool (`UX_LOADING.md:116`). Agents never
call `godot` directly. Queue health first:
`python variant3d\tools\godot_runner.py status` (`UX_LOADING.md:121-123`).

### 4.2 HUD layout atom — jobs defined by UX_LOADING.md §5 (ids follow the convention)

Windowed (no `--headless`), fresh ids, one job at a time
(`UX_LOADING.md:133-142`):

```bat
python variant3d\tools\godot_runner.py run --id uxloaddoc01-hudlayout-1024 --timeout 180 -- ^
  --path variant3d --script res://tests/t_hud_layout.gd -- --width 1024 --height 768 --png "%TEMP%\uxloaddoc01\hud_1024.png"
python variant3d\tools\godot_runner.py run --id uxloaddoc01-hudlayout-1280 --timeout 180 -- ^
  --path variant3d --script res://tests/t_hud_layout.gd -- --width 1280 --height 720 --png "%TEMP%\uxloaddoc01\hud_1280.png"
python variant3d\tools\godot_runner.py run --id uxloaddoc01-hudlayout-1920 --timeout 180 -- ^
  --path variant3d --script res://tests/t_hud_layout.gd -- --width 1920 --height 1080 --png "%TEMP%\uxloaddoc01\hud_1920.png"
```

**Caveat (observed):** `UX_LOADING.md:142` itself marks `--width/--height/--png`
as UNVERIFIED until the atom lands. The atom that actually landed documents a
*different* flag set — `--config <ABS>\small_map_64.json --screenshot
<TEMP>\hud_layout_unused.png --png-1024x576 / --png-1280x720 / --png-1920x1080`
— and uses ids `HUDLAYOUT01-headless` / `HUDLAYOUT01-windowed`
(`HUD_LAYOUT_01.md:96-109`). Those ids do **not** follow the
`<ticket-lowercase>-<purpose>` convention and are quoted, not endorsed, here. A
runner operator must reconcile the flag shape and mint fresh convention ids
before submitting; no job was submitted by this QA. Artifacts belong in
`%LOCALAPPDATA%\Temp\opencode\...`, never in the repo (`UX_LOADING.md:142`).

### 4.3 Load usability probe — jobs still needed

`UX_LOADING.md:145-150` provides only a template whose script path does not
exist:

```bat
python variant3d\tools\godot_runner.py run --id uxloaddoc01-loadresp-01 --timeout 180 -- ^
  --path variant3d --script res://tests/t_load_responsive.gd
```

(`res://tests/t_load_responsive.gd` absent — **observed**). The on-disk atom is
`res://tests/t_load_usability.gd` (578 lines, `LOAD_PROBE_01.md`), and its report
documents **no runner command at all** (authoring-only, `:224-231`). A real job
therefore still needs: the script path corrected to `t_load_usability.gd`, the
`--config res://tests/fixtures/small_map_64.json` argument, a fresh
`uxloaddoc01-loadresp-*` id, and an external
`python variant3d\tools\smallmap_capture.py scan-stderr <stderr>` step
(`LOAD_PROBE_01.md:215`, `:142`). Its own verdict convention must stay
`MEASUREMENT_ONLY__NO_PASS_CLAIM` / `gate_claim: NONE` (`LOAD_PROBE_01.md:115-123`).

R3 additionally requires a **windowed manual title-bar drag** at each progress
stage; neither atom can establish window movability headless
(`UX_LOADING.md:69,77-82,150`; `LOAD_PROBE_01.md:161-166`). A windowed probe that
performs a real Start click is still to be authored/assigned
(`LOAD_PROBE_01.md:206-208`). Do not substitute a headless run for it.

### 4.4 Post-change final gates (COORD only, once, strictly serial)

Per `UX_LOADING.md:152-160`: `uxloaddoc01-selftest`, `uxloaddoc01-uitest`, then
`python variant3d\tools\assert_clean.py --json`; pass criteria 29/29, 17/17 and
CLEAN exit 0. These are unchanged in shape but must be re-run after the current
uncommitted `hud.gd`/`main.gd` edits land; no fresh result was observed this pass.
Note gate attribution policy `UX_LOADING.md:162-170` (no weakening, stop at first
failing row, classify harness/queue races before blaming game code).

## 5. Open questions

1. **Cause of absent owner reports (UNVERIFIED).** `UI_TOPBAR_01.md` and
   `LOAD_ASYNC_01.md` are absent while their code edits landed and their board
   states are still RUNNING (`SWARM_BOARD.md:270-271`). Whether this is "still
   writing" or "never filed" is not checkable from disk.
2. **Commit state (observed → inferred).** Both fixes are working-tree `M` only.
   If the tree is reset, both landings disappear; no commit was made by this QA.
3. **R4 guard (derived).** `load_ready` is written but never read by
   `_hide_loading()` (`main.gd:517-524`). Should an owner add an explicit
   assertion/guard, or is call-site ordering the accepted contract? The atom
   checks bindings at hide time but not a flag.
4. **R3 sufficiency (inferred).** Do the three added inter-stage yields actually
   keep the window draggable? Only a windowed title-bar drag can settle this;
   `UX_LOADING.md:55` already notes stage bodies stay synchronous.
5. **Criterion mismatch on clipping (inferred).** `UX_LOADING.md:102` says no
   child may be cut off, while the landed fix relies on clipping and the atom
   records clipped children as a diagnostic, not a gate
   (`HUD_LAYOUT_01.md:135-143`). Which reading of "never overflows" is authoritative?
6. **Flag-shape drift (observed).** UX_LOADING.md's `--width/--height/--png`
   shape differs from the atom's `--config/--screenshot/--png-WxH` shape; its
   proposed atom name also differs (`t_load_responsive.gd` vs `t_load_usability.gd`,
   `LOAD_PROBE_01.md:187-190`). Who updates UX_LOADING.md §5 to match the landed
   atoms, and who mints convention-compliant ids?
7. **Existing speed gate (observed).** `uitest.gd:274-280` bypasses the new
   dropdown entirely; is a dropdown-specific gate to be added, and by which owner
   (M1 in `QA_UX_DOC_01.md:84`)?
8. **No integrated gate (UNVERIFIED).** No fresh selftest/uitest/CLEAN result tied
   to these two diffs was found; a per-job result would not be an integrated
   green tree (`UX_LOADING.md:58,71`).

## 6. Summary

- **Landing (observed):** both implementation diffs are present on disk and
  uncommitted — `hud.gd` +179/−34 lines vs `hud.gd.bak-UITOPBAR01`, `main.gd`
  +31/−2 lines vs `main.gd.bak-LOADASYNC01`. `UX_LOADING.md` is present (201
  lines) but its snapshot pre-dates the fixes, so its §2/§3/§4 "PENDING" rows are
  stale as code descriptions though still accurate as verification status.
- **NOT LANDED (observed):** `reports/UI_TOPBAR_01.md` and
  `reports/LOAD_ASYNC_01.md` do not exist anywhere in the repo; the corresponding
  owners are `ses_dedb5cfdbffe9rh6Oh2C7HL1zS` and `ses_dedb5890affedzB6Lq8J5wNje9`,
  both still **RUNNING** on `SWARM_BOARD.md:270-271`. No owner report was promoted
  to PASS by this QA.
- **Requirement verdicts:** R1 (no overflow) and R2 (dropdown) have clear landed
  code evidence but no acceptance measurement; R3 (movable window) has only a
  partial mitigation and no windowed observation; R4 (overlay hides when ready)
  has a landed `load_ready` flag with no guard in `_hide_loading()`; R5 (no
  post-load blocking) has the warm-up moved behind the overlay but no
  deferred-stage observable and no fresh gates. All five remain **UNVERIFIED**
  at runtime; none is claimed PASS.
- **Remaining work (derived):** run the three width rows and the load probe with
  fresh `uxloaddoc01-*` ids on a quiet variant spool, reconcile the documented
  flag/atom-name drift, add a real windowed Start-click drag check for R3, and
  re-run the final gates strictly serially under COORD.
- **No parity claim:** nothing here establishes donor visual or behavioural
  parity; runtime behaviour of the bar and loader is UNVERIFIED. This report is
  the only file written by this worker; no code, config, test, manifest, queue or
  runner state was touched.
