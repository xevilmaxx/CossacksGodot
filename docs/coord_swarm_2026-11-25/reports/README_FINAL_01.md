---
id: README-FINAL-01
title: "README final reconciliation — sections changed, sources and snapshots"
date: 2026-11-25
owner: README-FINAL-01 (documentation micro-worker)
status: DELIVERED__DOC_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB
scope: "Exactly two files touched: docs/coord_swarm_2026-11-25/README.md (targeted edits) and this report. No code, config, test, asset, backup, git, queue or runner state was changed; no Godot job submitted; no donor file accessed."
labels: [observed, derived, UNVERIFIED, PORT_APPROXIMATION, snapshot]
source_convention: "Paths are relative to docs/coord_swarm_2026-11-25/; report citations use file:line read at this snapshot. Latest snapshot cited: reports/QA_BOARDLIVE_01.md:36 = 11:32:51 local (DB MAX time_updated 11:32:50)."
snapshot: "The swarm kept landing files during this edit (reports/*.md counted 133 then 134 in two polls); all counts and State-column readings are point-in-time, not live."
---

# README-FINAL-01 — final README reconciliation

## 1. Task and discipline

Refresh the swarm README with the reconciliations that landed after README-UPDATE-01, using
**targeted edits only**. Read set per task: `README.md`, `SWARM_BOARD.md` (live-session
section + Batches S/R), `PROGRESS.md`, `CORRECTIONS.md`, and
`reports/{QA_CONFIGJSON_01,MAPSIZE_01,MOTION_ANIM_01 §8,WEATHER_DRIVER_01,DESERT_REMAP_02,
GATE_READY_01,QA_DOCS_02,QA_ATOM_RESULTS_01}.md`. Supporting reads used only to resolve
conflicts already named by those sources: `QA_BOARDLIVE_01.md`, `MINIMAP_QUAD_01.md`,
`README_UPDATE_01.md`, `reports/` directory listing, and the on-disk `CORRECTIONS.md` row
count. No code was edited, no runner job was run, and no donor binary was read, copied or
executed. No visual-parity claim is made by this report.

## 2. Sections changed in `README.md`

| README section (final line numbers) | Change | Source(s) |
|---|---|---|
| Frontmatter `:6-9` | `refreshed_by: README-FINAL-01`; status now carries `FINAL NOT_READY`; snapshot line names the latest cited DB read instead of README-UPDATE-01's ~11:00 read. DOC-03 authorship kept. | `reports/QA_BOARDLIVE_01.md:36`; `reports/GATE_READY_01.md:10,192-219` |
| §0 decomp bullet `:49-52` | Corrections count **57 → 60**; citations updated from `:100-105,159-170` to rows `:47-109`, duplicate chain `:111-115`, UNVERIFIED `:117-139`, summary `:169-180`. | `CORRECTIONS.md:47-109,111-115,117-139,169-180`; `reports/QA_DOCS_02.md:44,75` |
| §0 config bullet `:101-116` | Replaced "no `features` section" with the **21-key `features` object present, 21/21 MATCH**; earlier claims marked stale; added the 40/70 Snow driver status. | `reports/QA_CONFIGJSON_01.md:29-59,73-85,89-98,102-126`; `reports/WEATHER_DRIVER_01.md:7,26-31,107-116,118-150` |
| §0 owner-error bullet `:72-80` | Superseded original report text now points at the corrected outcome bullet instead of repeating "still RUNNING / ctex absent". | `PROGRESS.md:104-115`; `reports/MOTION_ANIM_01.md:289-305`; `reports/QA_DOCS_02.md:55` |
| §0 motion/atlas bullets `:90-100,117-124` | VID "16/16 distinct" corrected to 16 frames / 10 distinct signatures; rotor parse-only claim replaced with the fixed path; SP-4/SP-6 state refreshed. | `reports/QA_ATOM_RESULTS_01.md:88-91`; `reports/MOTION_ANIM_01.md:224-305`; `SWARM_BOARD.md:196-199,289` |
| §0 seven new bullets `:130-194` | FINAL **NOT_READY** with integrated 28/29 `build`; session-DB method + terminated-worker counts; MAPSIZE-01 reverted; rotor fixed (PORT APPROX spin); desert remap 11→38; atom-result false-green/staleness guard. | See §3 below. |
| §1 resume order `:198-251` | 57→60 row count; live section flagged STALE; PROGRESS gate table marked reconciled (not merely contradicted); CONFIG_PIPELINE marked as a freeze superseded on `features`; post-UPDATE-01 landings refreshed. | `reports/QA_BOARDLIVE_01.md:109-131`; `reports/QA_DOCS_02.md:39,43,71-76`; `reports/QA_CONFIGJSON_01.md:89-98` |
| §2 folder map `:263,271` | Corrections row → 60; report count → measured snapshot (133→134 during two polls, plus this report) with drift caveat. | `CORRECTIONS.md:171`; `reports/QA_DOCS_02.md:10,83`; directory read |
| §3 green table `:285,289-290` | VID frame claim corrected; corrections 60; new `config.json` `features` 21/21 row (structural, no job). | `reports/QA_ATOM_RESULTS_01.md:88-91`; `reports/QA_CONFIGJSON_01.md:29-59,130-135` |
| §3 pending table `:299-310` | Integrated selftest = 28/29 `build`; FINAL = **NOT_READY — DO NOT RUN**; owner errors split (rotor fixed / minimap no gates); config row split (21/21 JSON present, wire state incomplete); ticket-state snapshot; MAPSIZE-01 reverted; desert data-only; atom JSON staleness. | `reports/GATE_READY_01.md:181-219,251-264`; `reports/MAPSIZE_01.md:11-17,58-106,134-145`; `reports/DESERT_REMAP_02.md:127-145,157-191`; `reports/QA_BOARDLIVE_01.md:19-50,94-114` |
| §3 honesty guard `:312-321` | Added: data-only JSON ≠ runtime proof; `passed:true` can be stale/false green; FINAL explicitly NOT_READY; donor-parity citation moved to the current row. | `reports/QA_ATOM_RESULTS_01.md:70-81`; `CORRECTIONS.md:132`; `reports/GATE_READY_01.md:192-219` |
| §5 `:344-363` | Failure register extended: no "all globally configurable"; no stale "no features section"; no donor 3-D rotor-spin parity; no runtime claim for the 38-pair remap; no re-spawning terminated workers. | `reports/QA_CONFIGJSON_01.md:120-126`; `reports/MOTION_ANIM_01.md:234-240,296-300`; `reports/DESERT_REMAP_02.md:157-173`; `SWARM_BOARD.md:35` |
| §6 pointer index `:384-386,409-411,438-442,453-456,468-472,481-486,506-519` | Updated Selection, Terrain, Config, Season, Motion, Map-size entries; added a "Final reconciliation" subsection listing all new reports. | Per-entry citations written into `README.md` |
| Bottom line `:528-539` | Board/live section labelled stale snapshot; use GATE_READY_01 (28/29 `build`, NOT_READY) for gate truth; parity and final-gate guard kept. | `reports/QA_BOARDLIVE_01.md:109-114`; `reports/GATE_READY_01.md:181-219` |

## 3. Required reconciliations — claim and authority

| Required change | Where it landed in README | Authority |
|---|---|---|
| Corrections 57 → **60** | `:49-52,198-200,263,289` | `CORRECTIONS.md:47-109` (rows 1–60), `:171` ("60 indexed corrections"); `reports/QA_DOCS_02.md:44,75` |
| `config.json` **HAS** the 21-key `features` section; 21/21 MATCH; "no features" stale | `:101-116,214-215,232-233,263,290,305,354-356,438-442,506-507` | `reports/QA_CONFIGJSON_01.md:29-59` (21-row table), `:59` (21 MATCH / 0 mismatch), `:73-85` (sole addition, 240²/`land`), `:89-98` (stale-claim verdict), `:102-114` (recommended doc corrections), `:120-126` (runtime UNVERIFIED) |
| MAPSIZE-01 **reverted**; gate startup failures; donor sizes unmatched | `:154-163,308,481-486` | `reports/MAPSIZE_01.md:11-17` (outcome), `:44-56` (value-only edit), `:58-74` (jobs 455/482, banner only), `:76-92` (pre-existing 28/29 `build`; concurrent failures), `:94-106` (revert + transient HEAD commit), `:134-145` (summary); `SWARM_BOARD.md:281` |
| Rotor errors **fixed**: port copy + import + spin PORT APPROX | `:96-100,164-177,304,468-472,510-511` | `reports/MOTION_ANIM_01.md:191-211` (root cause), `:224-232` (port PNG copy, `Image.load()`, fallback, `BACK→FORWARD`), `:234-240` (speed/pivot PASS, spin PORT APPROX, donor 3-D UNVERIFIED), `:242-288` (jobs 476/478/489), `:289-305` (outcome) |
| Desert remap **11 → 38** | `:178-187,309,453-456,512` | `reports/DESERT_REMAP_02.md:17-23` (scope/status), `:41-94` (38 pairs; 11 OLD + 27 NEW), `:127-145` (validation), `:147-155` (`alpha0c` exception), `:157-191` (open questions, no parity claim) |
| Live-session **DB method**; most workers **terminated** | `:140-153,205-209,307,518-519` | `SWARM_BOARD.md:14-35` (DB path, `session_v2`/`parent_id`, columns, helper, 140 children / 135 terminated / 4 BUSY at 11:28); `reports/QA_BOARDLIVE_01.md:19-50` (direct read-only query, parent id, 156 children / 137 terminated / 19 BUSY at 11:32:51), `:80-114` (STALE verdict), `:131` (do not re-spawn) |
| FINAL **NOT_READY**; integrated selftest **28/29 `build`** | `:130-139,299,301,312-321,528-539` | `reports/GATE_READY_01.md:181-188` (selftest red, 28/29 `build`), `:192-219` (NOT_READY + seven blockers), `:251-264` (summary); independent pre-change 28/29 `build`: `reports/MAPSIZE_01.md:76-83`; final-gate plan `reports/FINAL_GATE_PLAN_01.md:53-105` |

## 4. Discrepancies found and how they were handled

1. **Line-number drift in living docs.** README's old citations (`CORRECTIONS.md:100-105,159-170`)
   and old board line numbers no longer match the files. Every changed claim now cites the
   line numbers read in this snapshot; `QA_DOCS_02.md:44,75` was used to confirm the 60-row
   count and chain notice. No living doc other than the README was edited (COORD/other owners).
2. **Nested stale claims.** README-UPDATE-01's §0 OWNER bullet still described the original
   owner report as if it were the current state ("still RUNNING", "target ctex still absent",
   parse-only fallback). Rather than delete the history, it is relabelled "original report"
   and points to the corrected bullet (`:72-80` ↔ `:164-177`), sourced from
   `QA_DOCS_02.md:55` and `MOTION_ANIM_01.md:289-305`.
3. **"No features section" is a historical snapshot.** `QA_CONFIGJSON_01.md:89-98` explicitly
   resolves it as stale while keeping the old audits intact; the README follows that
   recommendation (annotate, do not silently rewrite old reports). The runtime consequence
   described in the older docs still holds numerically but by a different mechanism
   (`:98`); non-default runtime behaviour remains UNVERIFIED (`:120-126`).
4. **Two different "live worker" counts.** `SWARM_BOARD.md:19-29` (140 children, 135 terminated,
   4 BUSY at 11:28) and `QA_BOARDLIVE_01.md:36-50` (156 / 137 / 19 at 11:32:51, verdict STALE)
   are different snapshots, not a contradiction; both are recorded with their times and both
   show a large majority terminated. The helper-script caveat (`:29-31,135-138`) is preserved.
5. **VID frame-count claim.** `QA_ATOM_RESULTS_01.md:88-91` re-counted `frames.json` twice:
   16 frames, **10 distinct signatures**, contradicting the "16/16 distinct" wording in the
   capture report and board. The README now carries the artifact-backed number; no report
   was rewritten by this worker.
6. **Report count is a moving target.** Two `reports/*.md` polls returned 133 then 134 while
   this edit was in progress; `QA_DOCS_02.md:10,83` records the same drift (139→142 Markdown
   files in 74 s during its pass). The folder map therefore states a measured range, not a
   permanent total.
7. **Board State column still lags.** QA-DOCS-02 found 11 report-landed tickets plain RUNNING
   at 11:26:46 (`:43,49-73`) and QA-BOARDLIVE-01 found 14 phase-level rows already terminated
   (`:94-101`). These are COORD-only edits; the README flags them rather than changing them.

## 5. Honesty guard preserved

- Reports authored ≠ tests passed. "Green" in the README still requires a recorded runner
  result/job id; the 21/21 `features` parity and the 38-pair desert remap are explicitly
  labelled structural/data-only, not runtime proof (`QA_CONFIGJSON_01.md:120-126`;
  `DESERT_REMAP_02.md:157-173`).
- Atom-level PASS values (S1 23/23, CAM-RV-01 20/20, VID-CAP 10/10, FX 13/13) remain
  scenario-scoped; P3's `passed:true` is a documented false green and seven result JSONs are
  stale (`QA_ATOM_RESULTS_01.md:57,70-81`).
- Donor visual parity remains **UNVERIFIED**: no donor GPU A/B exists
  (`CORRECTIONS.md:132`; `GATE_READY_01.md:216-219`). The rotor spin fix is PORT APPROX from
  the 2D donor-bake proxy; donor 3-D spin direction is UNVERIFIED
  (`MOTION_ANIM_01.md:234-240,296-300`).
- The final whole-system gate has **not** been run; the current read-only verdict is
  **NOT_READY** (`GATE_READY_01.md:192-219`), and this worker ran no gate, submitted no job
  and mutated no runner state.
- All new facts are marked as snapshots: source report snapshots, DB read times, and the
  moving `reports/` count. PORT APPROXIMATION labels are preserved for FOV, world-XZ texgen,
  light compression, replacement luma gates, rotor spin and season data.

## 6. Verification and file statement

- Post-edit scan of `README.md`: no remaining "57-row / 57 indexed" corrections claim and no
  unqualified current-state "no `features` section" claim; the only occurrences of those
  phrases are explicitly marked as stale/superseded snapshots.
- Only `docs/coord_swarm_2026-11-25/README.md` and this report were written. No source,
  config, test, asset, backup, git, queue or runner state was touched. No donor file was
  accessed. `README.md` remains the main output.

---

*End of README-FINAL-01. Documentation only; no code edit, no runner job, no visual-parity claim.*
