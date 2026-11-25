---
id: OWNER-FAULTS-UPDATE-01
title: "OWNER-FAULTS-UPDATE-01 — refresh OWNER_FAULTS.md with landed diagnoses and fixes"
area: coord_swarm_2026-11-25
date: 2026-11-25
owner: documentation worker (read-only on code; this report + OWNER_FAULTS.md only)
scope: "DOCUMENTATION ONLY. No code edit, no runner job, no queue mutation, no test weakening, no donor-parity or PASS claim."
labels: [observed, derived, inferred, UNVERIFIED]
snapshot: "On-disk reads 2026-11-25 from C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3; HEAD cd90a181 (three commits past the prior 83b77ea snapshot). The swarm is still landing reports concurrently; re-read before acting."
parity_guard: "PORT APPROXIMATION — NOT DONOR PARITY; visual = UNVERIFIED. No row promoted to PASS."
owns:
  - docs/coord_swarm_2026-11-25/OWNER_FAULTS.md
  - docs/coord_swarm_2026-11-25/reports/OWNER_FAULTS_UPDATE_01.md
---

# OWNER-FAULTS-UPDATE-01

## 0. Label key and boundary

- **observed** — file/report text and line numbers read directly this pass, plus current tree values (`config.json:29`, `world3d_entities.gd:1177-1199`, `convert_skins.py:80-81`, `hud.gd:112,444`, `main.gd:157,675`).
- **derived** — structural conclusion from observed rows (e.g. "report landed while board still says RUNNING").
- **inferred** — judgement without a direct measurement or donor A/B; never asserted as fact.
- **UNVERIFIED** — not checkable without a gate, a windowed observation or an absent artifact.

**Snapshot caveat.** `SWARM_BOARD.md` states are stale relative to landed reports: `UI-TOPBAR-01` is DONE at `:270` and `NATION-DONOR-01` DONE at `:295`, but `:271`/`:272`/`:294`/`:296`/`:297`/`:298`/`:299` still say RUNNING while their reports now exist. New reports continued to appear during this pass (`NATION_MODEL_01.md`, `HUD_LAYOUT_RUN_01.md`, `LOAD_PROBE_RUN_01.md` were absent from the initial listing). `RELIEF_LIVE_DIAG_01` is RUNNING (`SWARM_BOARD.md:334`) with **no report** — confirmed by glob and repo-wide grep `[observed]`.

No code, asset, config, test, atom, result JSON, queue state or report other than the two owned files was touched; no runner job was submitted. `PORT APPROXIMATION — NOT DONOR PARITY` and `visual = UNVERIFIED` are retained on every row; **no PASS claim** is made for F1–F6 `[observed]`.

## 1. Per-row before → after

### F1 — white marks / missing hills

| Aspect | Before | After | Evidence / label |
|---|---|---|---|
| Evidence | Report `TERRAIN_MARKS_01.md` **absent**; board only (`SWARM_BOARD.md:294`); no image | Report landed (255 lines, DELIVERED); supplied ticket-504 PNG opened and scanned; `RELIEF_ENABLE_01.md`, `QA_RELIEF_ON_01.md`, `QA_RELIEF_DUMP_01.md` also landed | `TERRAIN_MARKS_01.md:30-66,128-152` `[observed]` |
| Root cause | **UNVERIFIED** (candidate only, no causal link) | **Diagnosed for the captured/dumped config**: rank 1 relief opt-in off (`config.gd:59,448-449`; `main.gd:762-777` omit key); rank 2 `test*`/`rock*` tile-id colour on flat cells = best explanation for pale marks but refuted for this PNG; rank 3 `plt2` coarse-grid clamp = real geometry, flat-topped if enabled, refuted for this PNG. Still UNVERIFIED: owner frame/seed, donor tile→alpha rule, donor parity | `TERRAIN_MARKS_01.md:90-124,150-152,204-223` `[observed/derived/UNVERIFIED]` |
| Owning file / session | Session `TERRAIN-MARKS-01`, owning file UNVERIFIED | Suspect `config.gd:59,448-449`, secondary `game.gd:1771-1795`; config flip by `RELIEF-ENABLE-01` in `config.json:29`; live-relief diag ticket still RUNNING with no report | `TERRAIN_MARKS_01.md:193-200`; `RELIEF_ENABLE_01.md` frontmatter; `SWARM_BOARD.md:334` `[observed]` |
| Fix state | PENDING / UNVERIFIED | **CONFIG FIX LANDED / RUNTIME UNVERIFIED**: `config.json:29` = `"relief_stamps": true`; dump key present but array empty for seed 20261113; applied not observable; dump job 521 killed at 180 s; no gate, no visual A/B, no PASS | `RELIEF_ENABLE_01.md` verdict; `QA_RELIEF_ON_01.md` verdict; `QA_RELIEF_DUMP_01.md` verdict `[observed]` |
| Acceptance test | None authored | Unchanged A/B recipe now the acceptance gate (still PENDING): flag-on/off dump, `stats.relief_grid.applied > 0`, height shift, real-dump fixed-camera capture, `SCRIPT ERROR == 0`, second-agent re-check | `TERRAIN_MARKS_01.md:156-191`; `CAPTURE_RECHECK.md:249` `[observed/derived]` |

### F2 — Russia/Bavaria render Ukrainian art

| Aspect | Before | After | Evidence / label |
|---|---|---|---|
| Evidence | Three reports absent; code reads only | `NATION_DONOR_01.md` (twice verified), `NATION_FLOW_01.md`, `NATION_MODEL_01.md` all landed | `NATION_DONOR_01.md:23-30,77-166`; `NATION_FLOW_01.md:53-69`; `NATION_MODEL_01.md:49-78` `[observed]` |
| Root cause | **UNVERIFIED**; candidate "single sid, no nation remap" | **Diagnosed**: nation key reaches generation (owner hypothesis refuted, C4); first loss at starting-army generic sids (`game.gd:2702-2740`), decisive loss at sid-only 3D mesh key; Ukrainian look from manifest art selection, not a mis-set nation key (C6/G7/G10). Visual consequence still UNVERIFIED | `NATION_DONOR_01.md:194-211`; `NATION_FLOW_01.md:85-127,189-203` `[observed/derived/UNVERIFIED]` |
| Owning file / session | `world3d_entities.gd` / `NATION-MODEL-01` RUNNING, fix unassigned | Same primary owner, report landed with +197/−3 selector; load-bearing manifest/OBJ art fix has **no owner** (derived) | `NATION_MODEL_01.md:51-66,80-85` `[observed]` |
| Fix state | PENDING / UNVERIFIED | **SELECTOR LANDED / VISUAL FIX BLOCKED**: nation recovery, donor building-prefix probe, on-disk probe, telemetry; unit-family selection fixed for 7 nations; buildings/naval/Bavaria/Russia-specific art BLOCKED (0 prefixed OBJs among 172); Ukrainian look explicitly NOT fixed; parse smoke OK; no capture/gate/PASS | `NATION_MODEL_01.md:4-23,68-84,106-110` `[observed]` |
| Acceptance test | Tuple probe required, not run | Unchanged tuple probe + windowed re-check; new telemetry can supply part, but a visual assertion needs non-Ukrainian meshes and a gate | `NATION_FLOW_01.md:140-165` `[observed/derived]` |

### F3 — wrong peasant building animation

| Aspect | Before | After | Evidence / label |
|---|---|---|---|
| Evidence | Two reports absent; no frame sequence | `BUILD_ANIM_DIAG_01.md` and `BUILD_ANIM_01.md` landed, plus `NATION_MODEL_01.md`, `BUILD_SKIN_01.md`, `BUILD_SKIN_02.md`, `QA_SKIN_CONSTRUCT_01.md`, `QA_SKIN_REGEN_01.md` | `BUILD_ANIM_DIAG_01.md:190-245`; `BUILD_ANIM_01.md:16-41`; `QA_SKIN_REGEN_01.md:18` `[observed]` |
| Root cause | **UNVERIFIED**; candidate "requested action aliased to non-build donor action" | **Diagnosed**: presentation-layer gap — no `order.type` branch in `_unit_action()` (pre-fix `:1009-1016`), 0.15 m/s gate → idle; secondary skin-export gap → snap to 149/237. "Missing AAF clip" REFUTED (`anim3d.gd:86`). Donor `construct` 186..198 confirmed. Engine loop/blend still UNVERIFIED | `BUILD_ANIM_DIAG_01.md:20-34,104-143,190-203`; `BUILD_ANIM_01.md:59-63` `[observed/UNVERIFIED]` |
| Owning file / session | `anim3d.gd` / `BUILD-ANIM-01` assumed fixer | `anim3d.gd` explicitly **not** the owner: interim edit restored byte-for-byte (SHA `54FACBB…`, `git diff` clean); branch landed via `NATION-MODEL-01` in `world3d_entities.gd`; skin export via `BUILD-SKIN-01/02` | `BUILD_ANIM_01.md:25-41,103-109`; `NATION_MODEL_01.md:64` `[observed]` |
| Fix state | PENDING / UNVERIFIED | **BOTH FIXES LANDED / RUNTIME UNVERIFIED**: branch at `world3d_entities.gd:1177-1199`; `convert_skins.py:80-81` includes `construct`; `QA_SKIN_REGEN_01.md` JSON-export-level PASS with frames `[186,188,191,193,196,198]`; `buildanim01-smoke` NOT run; no capture/gate/PASS | `QA_SKIN_REGEN_01.md:18,96,108`; `BUILD_ANIM_01.md:133-143` `[observed]` |
| Acceptance test | Frame-sequence recipe required, not run | Unchanged: six-frame `pose_for` check never 149/237, sync capture `rendered_actions["construct"] >= 1`, zero builder idle, `|aconstruct|` batches, second agent | `BUILD_ANIM_DIAG_01.md:222-257` `[observed/derived]` |

### F4 — top-bar overflow / speed dropdown

| Aspect | Before | After | Evidence / label |
|---|---|---|---|
| Evidence | `UI_TOPBAR_01.md` absent; pre-fix baseline + authored atom only | Report landed (IMPLEMENTED, parse verified); `QA_UI_FIXES_01.md`, `QA_SPEED_01.md`, `HUD_LAYOUT_RUN_01.md` landed with one atom execution | `UI_TOPBAR_01.md:3,107-161`; `QA_SPEED_01.md:49-69`; `HUD_LAYOUT_RUN_01.md:43-74` `[observed]` |
| Root cause | **Inferred, unmeasured** (`CenterContainer` min width) | Same inference retained; headless atom showed `hud.ui_vp=(1280,720)` at all three sizes, so no three real layouts were exercised — harness limitation, not proven `hud.gd` regression. Speed values classified PORT APPROX, donor divergence stated | `UX_LOADING.md:50`; `HUD_LAYOUT_RUN_01.md:104-108`; `QA_SPEED_01.md:71-96` `[inferred/derived/observed]` |
| Owning file / session | `hud.gd` / `UI-TOPBAR-01` RUNNING; atom RUNNING | Same files; board now DONE for `UI-TOPBAR-01` (`:270`); atom run owner `HUD-LAYOUT-RUN-01` ticket 530 | `SWARM_BOARD.md:270-272`; `HUD_LAYOUT_RUN_01.md:1-17` `[observed]` |
| Fix state | UNVERIFIED / PENDING; code only uncommitted | **CODE LANDED / PARTIAL RUNTIME / NO ROW PASS**: +179/−34, minimap byte-identical (SHA `982B14BE…`), parse ticket 513 ok; atom FAIL 42/11/12 SKIP_CAPTURE; **R2 verified at runtime at 1024/1280/1920**; R1 UNVERIFIED (8 headless resize artifacts + 3 tooltip-literal drifts); 17/17 stale, no weakening | `UI_TOPBAR_01.md:25-48,121-135`; `HUD_LAYOUT_RUN_01.md:66-120` `[observed]` |
| Acceptance test | Three windowed widths + minimap assertions | Unchanged, plus: reconcile "produced by/at … mines" literals (`t_hud_layout.gd:66-68` vs `hud.gd:128-130`), run windowed resize, then fresh COORD gates | `HUD_LAYOUT_01.md:120-137`; `HUD_LAYOUT_RUN_01.md:122-128`; `QA_UI_FIXES_01.md:236-243` `[observed/derived]` |

### F5/F6 — load freeze and post-load blocking (one shared `main.gd` change)

| Aspect | Before | After | Evidence / label |
|---|---|---|---|
| Evidence | `LOAD_ASYNC_01.md` absent; probe atom authored only | Report landed (161 lines); `QA_UI_FIXES_01.md`, `LOAD_PROBE_RUN_01.md` landed with one atom run | `LOAD_ASYNC_01.md:7-55,138-147`; `LOAD_PROBE_RUN_01.md:51-134` `[observed]` |
| Root cause (F5) | **Derived, unmeasured** (synchronous stage bodies) | Code-confirmed R3: stage bodies still monolithic; four frame-yielding slices are a partial mitigation; window movability still UNVERIFIED | `LOAD_ASYNC_01.md:27-47,121-128`; `QA_UI_FIXES_01.md:111-129` `[derived/UNVERIFIED]` |
| Root cause (F6) | **Inferred, unmeasured** (`_hide_loading()` unconditional) | Code-qualified R4/R5: only hide call site gated by `load_ready`, but `_hide_loading()` itself has no guard and there is no deferred-stage observable; runtime UNVERIFIED | `LOAD_ASYNC_01.md:138-147`; `QA_UI_FIXES_01.md:131-169` `[observed/UNVERIFIED]` |
| Owning file / session | `main.gd` / `LOAD-ASYNC-01` RUNNING; probe authoring DONE | Same owner (board `:271` stale — report landed); probe run ticket 531 | `SWARM_BOARD.md:271,274`; `LOAD_PROBE_RUN_01.md:51-64` `[observed]` |
| Fix state | PENDING / UNVERIFIED | **CODE LANDED / RUNTIME UNVERIFIED**: +31/−2; smoke ticket 514 exit 0 but foreign `selftest.gd:153` parse error; windowed boot 517 failed with no screenshot and used `_setup_full_game`, not the edited loader; probe `ok`/exit 0 but `MEASUREMENT_ONLY__NO_PASS_CLAIM`, wall-cap at frame 1742, no hide snapshot, no input/order probes, camera non-response at −1, 23.26 s stage-gap proxy, probe-side format ERROR at `t_load_usability.gd:518`; no gate/PASS | `LOAD_ASYNC_01.md:62-117`; `LOAD_PROBE_RUN_01.md:77-134,215-223` `[observed]` |
| Acceptance test | Windowed title-bar drag + readiness/slow-stage/post-hide assertions | Unchanged; probe run incomplete, needs wall-cap/atom fix and a real Start-click windowed run; gates 29/29, 17/17, CLEAN still snapshot values only | `UX_LOADING.md:69,70,77-82,92-97`; `LOAD_PROBE_RUN_01.md:225-245` `[observed/UNVERIFIED]` |

## 2. Open questions (carried forward, not resolved by this refresh)

1. **F1** — which frame/seed produced the owner's white marks; does `stats.relief_grid.applied > 0` after the config flip; will `RELIEF_LIVE_DIAG_01` land (`SWARM_BOARD.md:334`)? `[UNVERIFIED]`
2. **F2** — who owns the manifest/OBJ art fix for `rus*`/`bav*`/`eur*` buildings and Russian/Bavarian units, and can a visual assertion ever pass without it? `[UNVERIFIED]`
3. **F3** — will a runtime `pose_for`/sync capture confirm the six construct frames and `|aconstruct|` batches; is the loop/hammer/smoke presentation in scope? `[UNVERIFIED]`
4. **F4** — which "produced by/at … mines" literal is canonical; can a windowed resize clear the 8 headless FAILs; which reading of "never overflows" is authoritative vs `clipped_overflow_children` being recorded-only? `[UNVERIFIED]`
5. **F5** — does the 23.26 s stage-to-stage proxy represent a genuine main-thread stall; can a windowed Start-click drag prove movability? `[UNVERIFIED]`
6. **F6** — should `_hide_loading()` gain a real `load_ready` guard (naive guard mis-fires at `:463`), and who supplies a deferred-work observable and FX-readiness assertion? `[UNVERIFIED]`
7. **Cross-cutting** — no gate job certifies any of F1–F6; all donor parity remains blocked. Neither atom run is a gate and neither produced a PASS `[observed]`.

## 3. Summary

All six faults moved from "no landed report" to "diagnosis landed", and five received code/data changes (F1 config flip; F2 selector; F3 action branch + skin export; F4 HUD rewrite; F5/F6 shared loader split) `[observed]`. Root causes for F2 and F3 are now observed/code-confirmed; F1 is confirmed for the captured/dumped config but its owner frame is still absent; F4's overflow cause remains inferred and headless-unproven; F5/F6 causes are code-confirmed but runtime-unmeasured `[observed/derived]`. No row was promoted to PASS: there is no gate job, no donor A/B, and the two atom runs are explicitly `NO_PASS_CLAIM` (one FAIL, one incomplete measurement) `[observed]`. The "resolved vs still open" section added to `OWNER_FAULTS.md §4` records the split with citations. `PORT APPROXIMATION — NOT DONOR PARITY` and `visual = UNVERIFIED` are preserved throughout; no other file was edited and no runner job was submitted `[observed]`.

*End of OWNER-FAULTS-UPDATE-01.*
