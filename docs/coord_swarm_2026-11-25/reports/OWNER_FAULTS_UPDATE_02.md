---
id: OWNER-FAULTS-UPDATE-02
title: "OWNER-FAULTS-UPDATE-02 — record the reproduced white-marks fault and the UX atom results in OWNER_FAULTS.md"
area: coord_swarm_2026-11-25
date: 2026-11-25
owner: documentation worker (read-only on code; only the two owned files written)
scope: "DOCUMENTATION ONLY. No code/asset/config/test/atom/result-JSON/queue edit, no runner job, no gate, no test weakening, no donor-parity claim and no PASS claim for any fault row."
labels: [observed, derived, inferred, UNVERIFIED]
snapshot: "On-disk reads made 2026-11-25 from C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3. New reports RELIEF_VISUAL_01.md, RELIEF_LIVE_DIAG_01.md and QA_ATOM_RUNS_01.md landed since UPDATE-01; SWARM_BOARD.md still marks RELIEF-VISUAL-01 (:326) and RELIEF-LIVE-DIAG-01 (:334) RUNNING, QA-ATOM-RUNS-01 DONE (:336), and both atom repairs (:347-348) RUNNING with no report. Reports are fixed artifacts; re-read before acting."
parity_guard: "PORT APPROXIMATION — NOT DONOR PARITY; visual = UNVERIFIED. No donor GPU A/B frame exists. No row is promoted to PASS."
owns:
  - docs/coord_swarm_2026-11-25/OWNER_FAULTS.md
  - docs/coord_swarm_2026-11-25/reports/OWNER_FAULTS_UPDATE_02.md
---

# OWNER-FAULTS-UPDATE-02

## 0. Label key, boundary and caveats

- **observed** — text, line numbers and literal values read directly this pass from
  the owned file and the eight cited reports, plus the current `SWARM_BOARD.md` rows.
- **derived** — structural/arithmetic consequence of observed rows.
- **inferred** — best-fitting explanation without a pixel-aligned donor A/B; never
  asserted as proven.
- **UNVERIFIED** — no landed report, image, gate or measurement backs the claim.

**Snapshot caveat.** Every citation is a read of on-disk state on 2026-11-25, not a
live measurement `[observed]`. Reports can be superseded, uncommitted working-tree
edits reverted, and this swarm is still landing reports concurrently; re-read the
cited files and re-run any gate before acting `[derived]`. In particular the board
lags the file system: `RELIEF_VISUAL_01.md` and `RELIEF_LIVE_DIAG_01.md` exist while
their rows (`:326`, `:334`) still say RUNNING `[observed]`.

**No-PASS rule and donor-parity caveat.** No fault row has a gate job; the only
gate report read, `P0_FRESH_CAPTURE_01.md:11,176-197` (ticket 504, `t_terrain_only`
P0 atom), certifies only the 64² P0 terrain-only atom and must not be transferred
to F1–F6 `[observed]`. `RELIEF_VISUAL_01.md` is a failed capture job, not a gate;
both atom runs are explicitly `NO_PASS_CLAIM` and `QA_ATOM_RUNS_01.md` promotes
nothing `[observed]`. All visual attribution stays `PORT APPROXIMATION — NOT DONOR
PARITY` with `visual = UNVERIFIED`, and no donor GPU A/B frame exists
(`RELIEF_VISUAL_01.md:16,244-246`; `RELIEF_LIVE_DIAG_01.md:11`) `[observed]`.

## 1. Per-row before → after

### F1 — white marks / missing hills (terrain row)

| Aspect | Before (UPDATE-01 state) | After (this refresh) | Evidence / label |
|---|---|---|---|
| Evidence | `TERRAIN_MARKS_01.md` landed with a **flat P0 PNG that had no white marks** (max luma 149, zero px >160); no real generated map frame; `RELIEF_LIVE_DIAG_01.md` absent | A **real generated 64² GPU sidecar** now exists and reproduces the symptom: 1280×720, `mean_luma` 115.039, `non_black_fraction` 0.999145, 0 full-width dark rows; **44,381 near-white px** (`min(R,G,B)>180`) = **4.8156 %** of 921,600, 122,932 px luma>180, near-white bbox (0,0)–(1279,719), **no visible hills/ridges/shading**. `RELIEF_LIVE_DIAG_01.md` has also landed (board `:334` stale). | `RELIEF_VISUAL_01.md:127-174,180-220`; `TERRAIN_MARKS_01.md:45-66`; `SWARM_BOARD.md:326,334` `[observed]` |
| Root cause | Diagnosed **for the captured/dumped config** only: rank 1 relief opt-in off; rank 2 `test*`/`rock*` tile-id colour (best explanation for pale marks, refuted for P0 PNG); rank 3 `plt2` coarse-grid clamp (real geometry, flat-topped, refuted for P0 PNG). Owner frame/seed, tile→alpha rule and parity UNVERIFIED | Ranking retained, plus **live-path mechanism source-confirmed**: the flag gates only the `--dump-map` marker (`main.gd:788-803`); live boot builds terrain from `game.height[]` shaped by `game.gd:_shape_stamp_relief()` (`game.gd:870-914`, called at `:1092`) — no donor float32 relief grid reaches live height. The reproduced marks' **pixel-level root cause stays UNVERIFIED/inferred** (tile-id art rank 2/4 favored; no flag-off A/B, no donor A/B). `RELIEF_LIVE_DIAG_01.md` confirms the mechanism but still labels attribution to the owner's exact frame UNVERIFIED. | `RELIEF_VISUAL_01.md:59-64,224-246`; `RELIEF_LIVE_DIAG_01.md:12,278,373-389`; `TERRAIN_MARKS_01.md:90-124` `[observed/derived/UNVERIFIED]` |
| Owning file / session | Suspect `config.gd:59,448-449`, secondary `game.gd:1771-1795`; live-relief diag ticket RUNNING with no report | Same suspect files; live-relief diag `ses_ded925739ffexlkv9OmJ0wU5xr` (`:334`, board RUNNING, report landed); relief capture `RELIEF-VISUAL-01` / ticket 532 (`:326`, board RUNNING, report landed). | `TERRAIN_MARKS_01.md:193-200`; `RELIEF_VISUAL_01.md:10-17`; `SWARM_BOARD.md:326,334` `[observed]` |
| Fix state | **CONFIG FIX LANDED / RUNTIME UNVERIFIED**: `config.json:29 = true`; dump key present, array empty for seed 20261113; no gate, no visual A/B, no PASS | **CONFIG FIX LANDED / WHITE MARKS REPRODUCED / STILL FLAT / ROOT CAUSE UNVERIFIED**: job 532 (`reliefvisual01-boot`) waited 482.622 s, ran 56.269 s, `failed`/exit 1 — `_is_blank()` (`main.gd:1932-1942`) compares each sampled luminance only to the bright sky-blue top-left pixel (`p00≈0.88`), so the non-blank olive frame was misclassified; requested `relief_on.png` absent, 2,450,951 B raw GPU sidecar inspected; `SCRIPT ERROR == 0`; `stats.relief_grid.applied` not exposed by this path and remains unmeasured; flag-on dump `relief_stamps=[]` for seed 20261113. No gate, no flag-off A/B, no donor A/B, **no PASS**. | `RELIEF_VISUAL_01.md:87-123,159-174,216-246`; `RELIEF_ENABLE_01.md` verdict `[observed]` |
| Acceptance test | `TERRAIN_MARKS_01.md:156-191` A/B recipe still PENDING (flag-on/off dump, `stats.relief_grid.applied > 0`, height shift, real-dump fixed-camera capture, `SCRIPT ERROR == 0`, second-agent re-check) | Recipe unchanged; this refresh adds `[derived]`: correct/avoid the one-sided `_is_blank()` sky-corner rejection so the final PNG is written; run a same-seed, camera-matched **flag-off A/B**; histogram `test7/8/9` (ids 78/79/80) against `|dh|<0.5` on the marked cells; donor parity stays blocked. | `TERRAIN_MARKS_01.md:156-191`; `RELIEF_VISUAL_01.md:250-267`; `RELIEF_LIVE_DIAG_01.md:317-338` `[derived/UNVERIFIED]` |

### F4 — top-bar overflow / speed dropdown (UI row)

| Aspect | Before | After | Evidence / label |
|---|---|---|---|
| Evidence | `UI_TOPBAR_01.md`, `QA_UI_FIXES_01.md`, `QA_SPEED_01.md`, one HUD atom FAIL (42/11/12, `SKIP_CAPTURE`) | Same sources plus `QA_ATOM_RUNS_01.md` (independent read-only re-verification of `t_hud_layout.json` and both runner records) | `QA_ATOM_RUNS_01.md:50-69,90-114`; `HUD_LAYOUT_RUN_01.md:43-74` `[observed]` |
| Root cause | Inferred `CenterContainer` min-width overflow; headless `hud.ui_vp` stuck at 1280×720 so the three-size sweep never exercised three layouts (harness limitation, not a proven `hud.gd` regression); speed values PORT APPROX | Unchanged inference and PORT APPROX classification. The audit corroborates that raw FAIL/PASS rows do **not** certify top-bar fit: at 1920 the bar reads "inside" only because the HUD stayed at 1280 layout. | `UX_LOADING.md:50`; `HUD_LAYOUT_RUN_01.md:98-108`; `QA_ATOM_RUNS_01.md:78-80`; `QA_SPEED_01.md:71-96` `[inferred/derived/observed]` |
| Fix state | **CODE LANDED / PARTIAL RUNTIME EVIDENCE / NO ROW PASS**: `hud.gd` +179/−34; R2 dropdown verified at runtime at 1024/1280/1920; R1 UNVERIFIED (8 headless artifacts + 3 tooltip-literal drifts); visual `SKIP_CAPTURE` | Retained. `QA_ATOM_RUNS_01.md` confirms **the speed dropdown is the only owner requirement with positive runtime evidence**, and that it is **structural only** — four rows × three viewports, one `OptionButton`, items `["II","1x","2x","4x"]`, metadata `[0.0,1.0,2.0,4.0]` s, zero legacy buttons; click reachability UNVERIFIED. **Top-bar fit stays UNVERIFIED.** Atom defects **being repaired**: `HUD-LAYOUT-REPAIR-01` (`SWARM_BOARD.md:347`, tooltip drift + headless resize) RUNNING, no report. **No PASS.** | `HUD_LAYOUT_RUN_01.md:66-74,98-120`; `QA_ATOM_RUNS_01.md:81,101-107`; `SWARM_BOARD.md:347` `[observed/UNVERIFIED]` |
| Acceptance test | Windowed PNGs at three widths; reconcile "produced by/at … mines" literals; fresh COORD gates (29/29, 17/17, CLEAN) | Unchanged; `HUD-LAYOUT-REPAIR-01` owns the atom fixes, no report yet. No gate job for this row. | `HUD_LAYOUT_01.md:120-137`; `HUD_LAYOUT_RUN_01.md:122-128`; `QA_ATOM_RUNS_01.md:118-125` `[observed/UNVERIFIED]` |

### F5 — loading window freeze (load row)

| Aspect | Before | After | Evidence / label |
|---|---|---|---|
| Evidence | `LOAD_ASYNC_01.md`, `QA_UI_FIXES_01.md`, one load probe run (ticket 531, wall-cap) | Same sources plus `QA_ATOM_RUNS_01.md` audit of `t_load_usability.json` | `QA_ATOM_RUNS_01.md:55,82,92-109`; `LOAD_PROBE_RUN_01.md:51-75` `[observed]` |
| Root cause | Code-confirmed synchronous stage bodies; four frame-yielding slices are a **partial mitigation**; window movability UNVERIFIED | Unchanged; the audit restates that headless cannot establish window movability (no windowed drag, no Start click) and that all five owner properties (a)–(e) remain UNVERIFIED. | `LOAD_ASYNC_01.md:27-47,121-128`; `QA_UI_FIXES_01.md:111-129`; `QA_ATOM_RUNS_01.md:82` `[derived/UNVERIFIED]` |
| Fix state | **CODE LANDED / RUNTIME UNVERIFIED**: `main.gd` +31/−2; smoke 514 exit 0 with foreign `selftest.gd:153` parse error; windowed boot 517 failed; probe `ok`/exit 0 but `MEASUREMENT_ONLY__NO_PASS_CLAIM`, wall-cap at frame 1742, 23.26 s stage-gap proxy, probe-side format ERROR at `t_load_usability.gd:518` | Retained. `QA_ATOM_RUNS_01.md` confirms **window-movable and no-post-load-blocking stay UNVERIFIED**; the single measured camera non-response at frame −1 is a negative observation from a probe that was never issued, **not** a passed response. Atom defects **being repaired**: `LOAD-PROBE-REPAIR-01` (`SWARM_BOARD.md:348`, format/overlay/camera capture) RUNNING, no report. **No PASS, no gate.** | `LOAD_PROBE_RUN_01.md:77-134,144-167,215-223`; `QA_ATOM_RUNS_01.md:55,84,107-109`; `SWARM_BOARD.md:348` `[observed/UNVERIFIED]` |
| Acceptance test | Windowed title-bar drag at each stage label; real Start-click path; probe wall-cap/atom fix | Unchanged; repair ticket RUNNING with no report. Gates 29/29, 17/17, CLEAN are snapshot values, not a fresh run. | `UX_LOADING.md:77-82`; `LOAD_PROBE_RUN_01.md:225-245`; `QA_ATOM_RUNS_01.md:126-130` `[UNVERIFIED]` |

### F6 — post-load blocking (load row)

| Aspect | Before | After | Evidence / label |
|---|---|---|---|
| Evidence | `LOAD_ASYNC_01.md` R4/R5 code-confirmed; `LOAD_PROBE_RUN_01.md` hide transition never sampled, post-hide probes never reached | Same plus `QA_ATOM_RUNS_01.md`: overlay-ready (`b_bindings_before_overlay_hide`, `staged_overlay_observed`) and no-post-load-blocking (`d_no_deferred_heavy_stage`, input/order/camera) all UNVERIFIED | `QA_ATOM_RUNS_01.md:83-84,104-109`; `LOAD_PROBE_RUN_01.md:120-134` `[observed]` |
| Root cause | Inferred/code-qualified: only hide call site gated by `load_ready`; `_hide_loading()` itself still unconditionally frees the layer with no flag check; R5 has no deferred-stage observable | Unchanged; the audit adds no runtime measurement that would promote it. | `QA_UI_FIXES_01.md:131-169`; `LOAD_ASYNC_01.md:138-147` `[observed/UNVERIFIED]` |
| Fix state | **CODE LANDED / RUNTIME UNVERIFIED**: `load_ready` set immediately before hide; guard deliberately not added; no readiness assertion, slow-stage injection or post-hide observation | Retained; `QA_ATOM_RUNS_01.md` upholds `MEASUREMENT_ONLY__NO_PASS_CLAIM` (`gate_claim:NONE`, `pass_claim:false`). **Overlay-ready and no-post-load-blocking remain UNVERIFIED**; atom repair `LOAD-PROBE-REPAIR-01` (`SWARM_BOARD.md:348`) RUNNING with no report. **No PASS, no gate.** | `LOAD_PROBE_RUN_01.md:215-223`; `QA_ATOM_RUNS_01.md:90-109`; `SWARM_BOARD.md:348` `[observed/UNVERIFIED]` |
| Acceptance test | Assert readiness before overlay free; inject slow stage; post-hide responsiveness; gates 29/29, 17/17, CLEAN | Unchanged; repair ticket RUNNING, no report; no donor comparison. | `UX_LOADING.md:70,92-97`; `QA_ATOM_RUNS_01.md:126-135` `[UNVERIFIED]` |

### Cross-cutting rows and sections

| Section | Before | After | Evidence / label |
|---|---|---|---|
| Frontmatter / snapshot caveat | `refresh_task_id: OWNER-FAULTS-UPDATE-01`; snapshot did not list the new reports or the repair tickets | `refresh_task_id/refresh_report` point to UPDATE-02; snapshot and caveat now record the three newly landed reports, the stale board rows (`:326`, `:334`) and both repair tickets (`:347-348`) | `OWNER_FAULTS.md:9-13,18-32` `[observed]` |
| Source register (§0) | `RELIEF_LIVE_DIAG_01.md` listed as **absent**; no rows for `RELIEF_VISUAL_01.md`, `QA_ATOM_RUNS_01.md` or the repairs; owner image row said only the flat P0 PNG existed | Three new source rows + the two repair tickets; `RELIEF_LIVE_DIAG_01.md` marked **Landed** (board stale); owner-image row now **Partial** — a real 64² frame exists with white marks, but no owner frame/seed, donor A/B or nation/animation capture | `OWNER_FAULTS.md:53,57-59,65` `[observed]` |
| Donor parity (§2.3) | Guard citation list ended at the two atom runs | Guard list extended with `RELIEF_VISUAL_01.md:16,244-246` and `RELIEF_LIVE_DIAG_01.md:11`; no donor A/B frame exists even for the reproduced marks | `OWNER_FAULTS.md:96` `[observed]` |
| Summary (§3) / resolved-vs-open (§4) | No reproduced-mark result; no atom audit; no repair tickets | Both sections record the reproduced symptom, the dump-only flag/live `_shape_stamp_relief()` split, the UNVERIFIED root-cause attribution, the single positively evidenced UX requirement (speed dropdown), the four UNVERIFIED UX properties, and the two atom repairs; no PASS | `OWNER_FAULTS.md:100,102,107,110,114,117-120` `[observed/derived/UNVERIFIED]` |

## 2. Open questions (carried forward, not resolved by this refresh)

1. **F1** — which frame/seed produced the now-reproduced marks, and is their cause
   tile-id art (rank 2/4) or height cliff art? `RELIEF_LIVE_DIAG_01.md` confirms the
   mechanism and favors tile art but explicitly leaves attribution to the owner's
   exact frame UNVERIFIED; no flag-off A/B and no donor A/B exist `[UNVERIFIED]`.
   *Directive note:* the task wording said "root cause still UNVERIFIED pending
   `RELIEF_LIVE_DIAG`"; that report has since landed, so the index records the
   source-confirmed mechanism **and** retains the UNVERIFIED label for the visual
   root cause rather than claiming a PASS `[observed/derived]`.
2. **F1** — will `_is_blank()` be corrected so a bright-sky corner cannot reject a
   valid frame and suppress the final PNG (`main.gd:1932-1942`)? No fix attempted
   (read-only mandate) `[UNVERIFIED]`.
3. **F1** — does any seed/preset place a non-empty `plt2` marker so
   `stats.relief_grid.applied > 0` can be measured? Seed 20261113 yields
   `relief_stamps=[]`; this path does not expose the stat at all `[UNVERIFIED]`.
4. **F4** — which "produced by/at … mines" literal is canonical, can a windowed
   resize clear the 8 headless FAILs, and will `HUD-LAYOUT-REPAIR-01` (`:347`)
   deliver a report? `[UNVERIFIED]`.
5. **F5** — is the 23.26 s stage-to-stage proxy a genuine main-thread stall or a
   frame-pump artefact? Can a windowed Start-click drag prove movability, once
   `LOAD-PROBE-REPAIR-01` (`:348`) lands? `[UNVERIFIED]`.
6. **F6** — should `_hide_loading()` gain a real `load_ready` guard (a naive guard
   mis-fires at `:463`), and who supplies a deferred-work observable and FX
   readiness assertion? `[UNVERIFIED]`.
7. **Cross-cutting** — no gate job certifies any of F1–F6; the P0 ticket-504 PASS is
   P0-only; both atom verdicts are `NO_PASS_CLAIM`; donor parity remains blocked for
   all six, including the reproduced white marks `[observed]`.

## 3. Summary

`OWNER_FAULTS.md` was refreshed in place with two substantive changes. The terrain
row now records that the owner's white-marks symptom is **reproduced** on a real
generated 64² map: 44,381 near-white pixels (4.8156 % of 921,600), 122,932 px
above luma 180, mean luma 115.039, frame-wide, and **no visible hills**
(`RELIEF_VISUAL_01.md:127-174`). The flag gates only the `--dump-map` marker while
live terrain is shaped by `game.gd:_shape_stamp_relief()` (`:59-64`;
`RELIEF_LIVE_DIAG_01.md:12`); the marks' root-cause attribution stays
**UNVERIFIED/inferred** and the failed job 532 (blank-detector false positive) is
**not** a gate or donor parity `[observed/derived]`.

The UI and load rows now carry the `QA_ATOM_RUNS_01.md` audit: code for all four
UX requirements has landed, the **speed dropdown is runtime-confirmed** (structural
only, at 1024/1280/1920), while **top-bar fit, window-movable, overlay-ready and
no-post-load-blocking remain UNVERIFIED**. Both atom defects are **being repaired**
by `HUD-LAYOUT-REPAIR-01` and `LOAD-PROBE-REPAIR-01` (`:347-348`, RUNNING, no
reports) `[observed/UNVERIFIED]`. The no-PASS rule, the
`PORT APPROXIMATION — NOT DONOR PARITY` / `visual = UNVERIFIED` caveat, the
observed/derived/inferred/UNVERIFIED label key and the snapshot caveat are all
preserved; no row was promoted to PASS `[observed]`.

**No other file was edited by this worker.** The only files written are the two
owned documents: `docs/coord_swarm_2026-11-25/OWNER_FAULTS.md` and this report.
No code, asset, config, test, atom, result JSON, queue state or report was
modified; no runner job was submitted; no donor-parity claim was made `[observed]`.

*End of OWNER-FAULTS-UPDATE-02.*
