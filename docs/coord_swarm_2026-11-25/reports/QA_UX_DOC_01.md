---
id: QA-UX-DOC-01
title: "QA-UX-DOC-01 — are the UX/loading requirements fully documented and assigned?"
date: 2026-11-25
owner: QA-UX-DOC-01 (read-only documentation QA worker)
status: DELIVERED__READ_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB__ONE_REPORT_ONLY
scope: "This report is the ONLY file written. No code, config, test, asset, git, queue or runner state touched; no Godot job submitted; no donor file accessed."
labels: [observed, derived, inferred, UNVERIFIED]
audit_mode: read-only; findings are gaps in documentation/assignment, not fixes
snapshot: "Read 2026-11-25; git status at read time shows PROGRESS.md and SWARM_BOARD.md modified in the working tree (uncommitted)."
---

# QA-UX-DOC-01 — UX/loading documentation and ownership audit

## 0. Method and label key

- **observed** — read directly this pass (file reads with line numbers, shell `Test-Path`, `git status`/`git diff`, repo-wide grep).
- **derived** — arithmetic/structural conclusions from observed rows (e.g. "6 requirements, 0 landed acceptance tables").
- **inferred** — judgement about cold-reader risk or likely intent, stated as such, never asserted as fact.
- **UNVERIFIED** — not checked or not checkable (no job was run, no donor read, no session DB queried; absent artifacts cannot be attributed to a cause).

Evidence discipline: every finding names a `file:line` or a documented command result. **No donor parity claim is made or assessed in this report** — this is a documentation/assignment audit only. No PASS result is claimed by this worker; where PASS appears below it is quoted from a cited existing artifact and explicitly marked as such.

## 1. Sources

### Read (observed)

| Source | What it supplies |
|---|---|
| `docs/coord_swarm_2026-11-25/PROGRESS.md:104-113` | The **owner UX/loading directive** — the only place the six requirements and four ticket names appear. `[observed]` It is a working-tree addition (`git diff` shows `+11` lines after `:103`), i.e. uncommitted at read time. |
| `docs/coord_swarm_2026-11-25/RUN_GUIDE.md` (143 lines; esp. `:37-57`, `:68`, `:94-109`, `:139`) | Owner-facing launch/verify guide. Contains **no** UX/loading acceptance criteria; `:68` fixes the harness viewport at 1280×720; `:133` calls a "freeze" a terrain-chunk-bake symptom, not a load-window freeze. |
| `docs/coord_swarm_2026-11-25/SWARM_BOARD.md` (302 lines, all read) | Ticket state registry. **No Batch row, session id or State cell exists for `UI-TOPBAR-01`, `LOAD-ASYNC-01`, `HUD-LAYOUT-01`, `UX-LOAD-DOC-01` or any load probe.** |
| `docs/coord_swarm_2026-11-25/reports/QA_DOCS_01.md:15-22,121-169` | House convention for labels, frontmatter and ranked gaps; documents that living-doc state is perishable. |
| `variant3d/MECHANICS.md:606,611-620,623-628,641-645` | **Prior** documentation claiming responsive/scalable UI and a "no-overlap HUD guarantee" with top bar clipped "by construction", "verified by layout math at 400-2560px widths". Context only — it is not the owner requirement table and does not cover load behaviour. |
| `variant3d/scripts/hud.gd:381-443` | Observed code state: `CenterContainer` + `top_panel.clip_contents = true` (`:384-392`); six resource icon+label pairs, buttons and **speed buttons** `["II", 0.0], ["1x", 1.0], ["2x", 2.0], ["4x", 4.0]` (`:397-433`) — not a dropdown. |
| `variant3d/scripts/main.gd:147-153,455-645` | Observed code state: `loading_layer`/`loading_active`/`loading_gen` fields; staged `_do_async_load()` with `await _loading_tick(...)` between stages (`:530-643`) and `_hide_loading()` immediately after the final "Ready!" tick (`:643-645`). |
| `variant3d/uitest.json:55`, `variant3d/scripts/uitest.gd:280`, `variant3d/uitest_patterns.json:55` | Existing "game speed set to 2x: yes" step — a **button** assertion, not a dropdown assertion. |
| Shell `Test-Path` + repo-wide grep | Confirmed absence of every artifact named in the task (below). |

### Confirmed absent (`Test-Path: False`, observed)

| Expected artifact | Named by |
|---|---|
| `docs/coord_swarm_2026-11-25/UX_LOADING.md` | `PROGRESS.md:112-113` (`UX-LOAD-DOC-01`) |
| `docs/coord_swarm_2026-11-25/reports/UI_TOPBAR_01.md` | task / `PROGRESS.md:110` (`UI-TOPBAR-01`) |
| `docs/coord_swarm_2026-11-25/reports/LOAD_ASYNC_01.md` | task / `PROGRESS.md:110-111` (`LOAD-ASYNC-01`) |
| `docs/coord_swarm_2026-11-25/reports/HUD_LAYOUT_01.md` | task / `PROGRESS.md:111` (`HUD-LAYOUT-01`) |
| `docs/coord_swarm_2026-11-25/reports/LOAD_PROBE_01.md` | task ("if landed") |
| `variant3d/tests/t_hud_layout.gd` | `PROGRESS.md:111-112` (new atom for 1024/1280/1920) |
| `variant3d/tests/t_load_ready.gd` | proposed probe name in §4 — **not** an existing file |

Repo-wide grep for `UX_LOADING|UI_TOPBAR|LOAD_ASYNC|HUD_LAYOUT|LOAD_PROBE|UX-LOAD-DOC|t_hud_layout|speed dropdown|responsive bar` returned **only `PROGRESS.md:110-112`**; for `topbar|top bar|loading overlay|movable|fully usable` the swarm-folder hits are unrelated (selection overlay, terrain, viewportrect). **derived:** apart from the one directive paragraph, the UX/loading work is not represented in any other living doc.

## 2. Owner requirement → documentation/assignment table

Status vocabulary is limited to **PENDING / IMPLEMENTED / UNVERIFIED**, as requested. Here "status" means the *documented-and-assigned* state at read time, not a code verdict.

| # | Owner requirement (authority: `PROGRESS.md:104-113`) | Documented? | Owning file / session | Acceptance test | Current status |
|---:|---|---|---|---|---|
| 1 | **Top bar never overflows; adapts to viewport/resolution.** Owner reported the resource bar overflows the screen (`:105,108-109`). | **Partial — directive only.** `[observed]` No `UX_LOADING.md`; no written assertion or pass criterion. A *prior* claim exists in `variant3d/MECHANICS.md:641-645` ("clips instead of spilling", 400–2560 px), contradicted by the owner report — not a substitute for the new requirement. | `UI-TOPBAR-01` → `variant3d/scripts/hud.gd` (`:110`). `HUD-LAYOUT-01` → new `variant3d/tests/t_hud_layout.gd` (`:111-112`). **No session id / no board row** `[observed]`. | Named only as "atom for 1024/1280/1920 widths" (`:111-112`); atom absent, no assertion text, no job id. `[observed]` | **PENDING** — dispatched; no report or atom landed. Implementation `UNVERIFIED` (code state observed at `hud.gd:384-392`, not acceptance-tested). |
| 2 | **Game-speed buttons become a dropdown** (`:106`). | **Partial — directive only.** `[observed]` No control type, values, keyboard behaviour or expected label set specified in an acceptance table; no dropdown mention elsewhere in swarm docs. | `UI-TOPBAR-01` → `hud.gd` (`:110`). Same missing session/board tracking as row 1. | **None named.** `[observed]` Existing `uitest` step only asserts "game speed set to 2x: yes" (`uitest.gd:280`) against the current four buttons (`hud.gd:428-433`). | **PENDING** — dispatched; no report. Current code is still buttons `[observed]`; dropdown behaviour `UNVERIFIED`. |
| 3 | **Window stays movable during loading** (owner: "loading freezes the Windows window (cannot move it)", `:106-107`). | **No.** `[observed]` Only the narrative sentence; no requirement statement, no OS-window criterion, no owner file beyond a ticket name. | `LOAD-ASYNC-01` → `variant3d/scripts/main.gd` (`:110-111`). No session id / board row / report. | **None named.** `[observed]` No atom or probe cited in the directive; `LOAD_PROBE_01.md` absent. | **PENDING** — dispatched; no report. Existing staged loader `main.gd:530-645` observed but window movability `UNVERIFIED`; owner report says the fault persists. |
| 4 | **Overlay hides only when ready** (`:110-111`). | **No.** `[observed]` "Ready" is not defined anywhere (sim ready? art ready? HUD built? first frame?) — no written condition. | `LOAD-ASYNC-01` → `main.gd` (`:110-111`). No session id / board row / report. | **None named.** `[observed]` Code observation: `_hide_loading()` follows the last `_loading_tick(1.0, "Ready!", gen)` at `main.gd:643-645` — a *sequence*, not a tested invariant. | **PENDING** — dispatched; no report; readiness predicate `UNVERIFIED`. |
| 5 | **No post-load blocking** (owner: after the loading screen disappears something is still loading and blocks normal use, `:106-108`). | **No.** `[observed]` No definition of "blocking", no timeout/responsiveness criterion, no reporting of which stage continues after overlay removal. | `LOAD-ASYNC-01` → `main.gd` (`:110-111`). No session id / board row / report. | **None named.** `[observed]` No probe exists; the only "freeze" documentation in `RUN_GUIDE.md:133` is the unrelated 2026-11-19 terrain-chunk-bake note (`MECHANICS.md:606`). | **PENDING** — dispatched; no report; post-overlay work `UNVERIFIED`. |
| 6 | **Game fully usable when the loading screen finishes** (`:108-109`). | **No.** `[observed]` No usability checklist (input, orders, selection, HUD, audio) and no "fully usable" gate. | `LOAD-ASYNC-01` → `main.gd` (`:110-111`), but success depends on `hud.gd` + input + world; no integration owner named for the cross-file hand-off. | **None named.** `[observed]` No atom; final gate ownership is unset for this scope (general gate policy `PROGRESS.md:190` / `SWARM_BOARD.md:120` reserves FINAL to COORD, not restated for UX). | **PENDING** — dispatched; no report; end-to-end usability `UNVERIFIED`. |
| 7 | *(meta)* **`UX_LOADING.md` requirements/acceptance table** (`:112-113`) | **No — file absent** `[observed]`. This is the deliverable that would document rows 1–6. | `UX-LOAD-DOC-01` → `UX_LOADING.md` (`:112-113`); no session id / board row / report. | N/A — the table itself is the missing artifact. | **PENDING** — not landed. |

**derived:** 6 owner requirements + 1 documentation deliverable = 7 rows; 0 have a landed requirements/acceptance table, 0 have a named acceptance test with assertions, 0 have a session id or State cell on `SWARM_BOARD.md`, 0 have a landed report. **inferred:** a cold reader can find the owner complaint once in `PROGRESS.md`, but cannot tell what "done" means, who is actually working it, or how to verify it.

## 3. Gaps ranked, with recommended tickets

### BLOCKER

| ID | Gap | Evidence / label | Recommended ticket (owner) |
|---|---|---|---|
| B1 | **No `UX_LOADING.md`**: none of the six requirements has a written acceptance test, pass criterion or "ready" definition. The deliverable explicitly dispatched at `PROGRESS.md:112-13` does not exist. | `Test-Path False`; grep only hits `PROGRESS.md:110-112`. `[observed]` | `UX-LOAD-DOC-01` (COORD to confirm/spawn) — land `UX_LOADING.md` with one row per requirement: exact assertion, viewport/ widths, trigger, pass/fail, owning file, gate runner and job-id placeholder. No test weakening. |
| B2 | **Four UX tickets are not tracked on `SWARM_BOARD.md`** — no Batch row, session id or State cell, although `PROGRESS.md:109-113` says they were dispatched. Ownership exists only as a prose sentence. | 302-line board read; no matches. `[observed]` **derived:** state cannot be queried from the board. | COORD (sole owner of State column, `SWARM_BOARD.md:11`) — add a "Batch UX" table with unique ticket ids, session ids, exclusive file grants and states; reconcile `PROGRESS.md:109-113`. |
| B3 | **Loading requirements 3–6 have no test of any kind**, and no `LOAD_PROBE_01.md` landed. `HUD-LAYOUT-01` covers only top-bar widths (`:111-112`), so window movability, overlay timing, post-load blocking and usability are untestable from the current test set. | Directive `:110-112`; absence confirmed. `[observed]` | `LOAD-PROBE-01` (new) — define and author a windowed probe (e.g. `variant3d/tests/t_load_ready.gd`) asserting: window can be moved during load; overlay visibility ⟺ not-ready; no blocking work after overlay hides; input/orders/HUD usable immediately after. Gate owned by its agent, final gate by COORD. |

### MEDIUM

| ID | Gap | Evidence / label | Recommended ticket (owner) |
|---|---|---|---|
| M1 | **Speed-dropdown requirement has no assertion**; the only speed test asserts a button-driven 2× change. | `hud.gd:428-433`; `uitest.gd:280`. `[observed]` **derived:** the existing step cannot detect a regression back to buttons. | `UI-TOPBAR-01` + `HUD-LAYOUT-01` — add a dropdown-specific assertion (control type, selectable speeds, resulting `speed`) to the layout atom; keep the existing uitest step byte-identical. |
| M2 | **Prior "no-overflow / no-overlap by construction" documentation conflicts with the owner's report.** `variant3d/MECHANICS.md:641-645` (and `app/MECHANICS.md:644`) claim clipping and 400–2560 px layout math; owner still sees overflow. A cold reader may treat the old claim as the requirement being already met. | `[observed]` contradiction; `[inferred]` cold-read risk. | COORD / `README-UPDATE-02` — annotate the prior claim as superseded for the current 3D resource bar; point to `UX_LOADING.md` once B1 lands. |
| M3 | **Existing async loader has no evidence tied to the owner's two load faults.** `main.gd:530-645` already time-slices with `await`; the owner still reports a frozen window and post-overlay blocking. No cited job, measurement or diff proves the current code satisfies the new criterion. | `[observed]` code + `PROGRESS.md:106-108`; runtime truth `[UNVERIFIED]`. | `LOAD-ASYNC-01` — measure the long stages, document what (if anything) remains synchronous, and cite a windowed probe artifact per B3; do not claim PASS from code inspection. |
| M4 | **Directive is an uncommitted working-tree edit.** If lost, the only record of the six requirements disappears. | `git diff -- PROGRESS.md` shows the `+11` line block. `[observed]` | COORD — commit the directive paragraph (or land `UX_LOADING.md` first, then commit both). |

### NICHE

| ID | Gap | Evidence / label | Recommended ticket (owner) |
|---|---|---|---|
| N1 | **Width set is ambiguous**: dispatch says 1024/1280/1920 (`PROGRESS.md:111-112`); prior doc says 400–2560 (`MECHANICS.md:644`); `RUN_GUIDE.md:68` fixes 1280×720 for captures. No single authority for acceptance widths. | `[observed]` | `UX-LOAD-DOC-01` — declare the acceptance width set once in `UX_LOADING.md` and mark the other values as context, not gates. |
| N2 | **No named integration owner for "game usable after load"** although the success path spans `main.gd`, `hud.gd`, input and world. | `[observed]` `PROGRESS.md:110-113`; `[inferred]` hand-off gap. | COORD — name a cross-file integration owner in the UX table and state who runs the final gate; do not let each builder self-certify the whole flow. |

## 4. Open questions

1. Did `UX-LOAD-DOC-01`, `UI-TOPBAR-01`, `LOAD-ASYNC-01` and `HUD-LAYOUT-01` actually start? No session ids exist on the board, so this cannot be checked from docs. **UNVERIFIED** — query the session DB or re-dispatch with recorded ids.
2. Is the missing `UX_LOADING.md` "not yet landed" or "never started"? Absence is **observed**; cause is **UNVERIFIED**.
3. Does the owner's report target `variant3d/` (the focus of this swarm) or the 2D `app/` port? Both have a top bar and a staged loader; the directive does not say. **UNVERIFIED** — must be settled before acceptance widths are written.
4. What exactly is "ready" for row 4/6 — last sim stage, art loaded, HUD built, first rendered frame, or first accepted input? No definition found. **UNVERIFIED**.
5. What is the "something still loading" after overlay removal — a named stage, an async texture/asset load, or engine idle work? No artifact records it. **UNVERIFIED**.
6. Does "never overflow" mean no clipped glyphs, no off-screen nodes, or no panel overlap? `MECHANICS.md:644` uses "clips instead of spilling" as the guarantee; the owner reported overflow despite that. Criterion wording is **UNVERIFIED**.

## 5. Summary

- **Not fully documented.** `[observed]` The six owner requirements exist only as one 11-line paragraph in `PROGRESS.md:104-113`; the mandated `UX_LOADING.md` acceptance table is absent, and no acceptance test, pass criterion or "ready" definition is written for any requirement. **derived:** 0/7 rows in §2 have a landed test or acceptance table.
- **Assigned in name only.** `[observed]` Four ticket names and three exclusive file grants are stated in `PROGRESS.md:109-113`, but none appears on `SWARM_BOARD.md`, none has a recorded session id, and none has a landed report or authored atom. **derived:** assignment is prose-level, not state-level.
- **Coverage asymmetry.** `[derived]` The top-bar side has at least a *named* test plan (1024/1280/1920 atom); the four loading requirements have no test plan at all, despite being the more severe owner complaint (frozen window + blocked use).
- **Cold-read risk.** `[inferred]` `variant3d/MECHANICS.md:641-645` claims the overflow class of bug was already fixed "by construction", while `RUN_GUIDE.md:133` labels a different freeze as expected — a reader could conclude both complaints are already handled and skip the new tickets.
- **No parity claim.** This audit makes no donor-parity, visual-parity or runtime-PASS assertion. Runtime behaviour of the existing loader and bar is **UNVERIFIED**; code state quoted above is **observed only**.
- **No other file was edited, created or deleted by this worker.** No Godot job was submitted; no code, config, test, asset, git or queue state was touched.
