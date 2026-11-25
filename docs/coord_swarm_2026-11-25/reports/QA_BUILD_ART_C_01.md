---
id: QA-BUILD-ART-C-01
owner: QA-BUILD-ART-C-01 (read-only QA subagent)
role: "Verify BUILD-ART-C-01 stage-mesh runtime integration after landing; no code edits, no runner jobs"
swarm: coord_swarm_2026-11-25
date: 2026-11-25
snapshot: "2026-11-25 12:56-12:57 local"
status: NOT_VERIFIED__TICKET_IN_FLIGHT__NO_PROMOTION
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
output: "docs/coord_swarm_2026-11-25/reports/QA_BUILD_ART_C_01.md (exclusive output)"
scope: "Read-only: reports, git status/log, runner job/result spool, manifest.json, and world3d_entities.gd vs its named BUILDARTC01 backup. No source, asset, test, config, queue or board edit; no Godot job."
labels: [observed, derived, inferred, UNVERIFIED, NO_VISUAL_PARITY]
parity: "NO PARITY CLAIM — no runtime mesh proof, no capture, no donor A/B"
---

# QA-BUILD-ART-C-01 — stage mesh runtime integration (post-landing check)

> [!IMPORTANT]
> **BUILD-ART-C-01 has not landed.** At every snapshot (12:48, 12:51, 12:52,
> 12:54, 12:56) `reports/BUILD_ART_C_01.md` was **absent**, the SWARM_BOARD
> row still read **RUNNING**, and no `buildartc01-*` job or result existed in
> the variant runner spool. Code edits attributable to the ticket are present
> in the working tree/HEAD, but they are **in flight and partial** (C1, C5, C7
> observed; C4, C6 not observed). Therefore **no runtime PASS is issued** and
> nothing is promoted. This is a snapshot verdict, not a final QA of a landed
> ticket.

## 1. Sources (all read-only)

| # | Path | Use / label |
|---|---|---|
| S1 | `docs/coord_swarm_2026-11-25/reports/BUILD_ART_C_01.md` | **ABSENT** at 5 snapshots. **observed** (absence) |
| S2 | `docs/.../reports/BUILD_STAGE_INTEGRATION_01.md:1-284` | Authoritative plan C1–C8, byte-identical frozen-block list, gates R1–R12, atom spec. **observed** |
| S3 | `docs/.../reports/STAGE_IMPORT_01.md:181-260` | BUILD-ART-C/D explicitly outstanding; 108/108 sidecars; runtime `load()` still UNVERIFIED. **observed** |
| S4 | `inbox/backup/world3d_entities.gd.bak-BUILDARTC01` | Ticket-named pre-integration baseline: 103,539 B, SHA-256 `4C763ABF…C88951`, mtime 12:27:53. **observed** |
| S5 | `variant3d/scripts/world3d_entities.gd` | 104,622 B, SHA-256 `753B9B11…ADA530`, mtime 12:50:52; committed at `65a1f49a` 12:52:55 +0100. **observed** |
| S6 | `git diff --no-index S4 S5` | Complete diff = 4 hunks: `:272-289`, `:495-498`, `:1790-1820`, `:1858-1867`. **observed** |
| S7 | `inbox/backup/world3d_entities.gd.bak-NATIONMODEL01` (93,632 B, SHA `9C797DFB…E75199`) | Earlier baseline; confirms stage labels were still the old "no stage OBJ" text before this ticket. **observed** |
| S8 | `variant3d/assets/models/manifest.json` (`models`, 280 entries) | `cen` (bbox 6 numbers), `cen1` (1,702 verts), `cen1a` (4,293), `cena` (8) all carry per-sid 6-number bboxes. **observed** |
| S9 | `docs/.../SWARM_BOARD.md:417,433` | QA row and `BUILD-ART-C-01` row both **RUNNING**. **observed** |
| S10 | `variant3d/.godot_queue/jobs`, `/results` | Latest job `00000550 relieflive01-smoke` (12:48:56); latest result `00000548 hudlayoutrepair01-run` (12:49:18). No `buildartc01-*` id. **observed** |
| S11 | `git status --short` at 12:56:46 | No test/asset/config/manifest edit attributable to this ticket; `variant3d/tests/t_build_stages.gd` absent. **observed** |

Label convention: **observed** = bytes/files/repo text read this pass; **derived** = control-flow or diff consequence; **inferred** = indirect synthesis; **UNVERIFIED** = no readable evidence and no runtime/visual capture.

## 2. Verification table

| # | Claim / gate | Result | Basis & label |
|---|---|---|---|
| 1 | `BUILD_ART_C_01.md` landed | **FAIL — ABSENT** | S1; five checks 12:48–12:56. **observed** |
| 2 | Builder state | **IN FLIGHT** | S9: session `ses_ded7a7ed3ffeVKh7QK500EOKfH` still RUNNING. **observed** |
| 3 | Named backup exists | **PASS** | S4 present, 103,539 B; pre-edit baseline usable. **observed** |
| 4 | Selector unchanged | **PASS (code level)** | S6: no hunk touches `_build_progress01():1767-1776` or `_build_stage_suffix():1782-1788`; `floor(p*4)`, `clampf`, `wal` fold and stage-4 clamp intact. **derived from observed diff** |
| 5 | Per-stage bbox lookup (C1) | **CODE PRESENT — runtime UNVERIFIED** | S5 `:1802,1807-1808,1818-1819`: `art_sid = sid+suffix+("a" if scaffold else "")`, `_bbox.get(art_sid, _bbox.get(sid, []))`, `bbox_sid`, honest `bbox_note`; S8 confirms manifest bboxes exist. No runtime assertion/run. **observed + UNVERIFIED** |
| 6 | Tint re-application (C5) | **CODE PRESENT — visual UNVERIFIED** | S5 `:1859-1867`: on every real mesh change, `_player_tint(_player_index(e))` guarded by `tint is Color`, then `_apply_tint(mi, chosen, tint, sid, "building")` (base sid keeps mask); `_player_tint():634` exists. **observed + UNVERIFIED** |
| 7 | Honest stats labels (C7) | **PARTIAL PASS** | S5 `:284-285`, `:498` replace unconditional "no stage OBJ" with measured/converted wording and keep `visual UNVERIFIED`; **but** `build_stage_art_status` still keys off the un-extended probe (row 9), so art-less/all-scaffold detection can mislabel. No "parity" string added. **observed + derived** |
| 8 | Completion scaffold `<sid>a` visible (C4) | **NOT OBSERVED** | S5 `:1877-1880` still `free()` + `erase()` on `finished=true`; no `<sid>a` keep/bind branch. **observed** |
| 9 | Availability probe extended (C6) | **NOT OBSERVED** | S5 `:417-422` still probes only `<sid>1.obj` and `<sid>a.obj`; no `1..4`/`1a..4a` loop; `build_stage_obj_hits`/`build_scaffold_obj_hits` will under-count. **observed** |
| 10 | Rotor block byte-identical | **PASS** | S6: no hunk in `_rotor_mesh():1674-1701`, `_rotor_material():1702-1741`, `_attach_rotor():1742-1766`, or the MILLFIX spin/billboard block in `sync():1991+`. **derived from observed diff** |
| 11 | Nation block byte-identical | **PASS** | S6: no hunk in `:656-795` (`_nation_of`, `_donor_building_prefix`, `_entity_mesh_sid`, `_record_nation_mesh`) or the `Data` preload. **derived** |
| 12 | Build-action block byte-identical | **PASS** | S6: no hunk in `_unit_action():1174-1202` / `_measure_speed():1203-1220` construct branch. **derived** |
| 13 | Tree/decor pool byte-identical | **PASS** | S6: no hunk in `_resource_sid():1916-1933`, `_pick_sid():1934-1940`, `add_resource():1941-1964`. **derived** |
| 14 | Motion block byte-identical | **PASS** | S6: no hunk in `_smooth_face():1221-1234`, `_load_obj_topology():1235-1284`, `_morph_mesh():1285-1377`, or motion telemetry in `sync()`. **derived** |
| 15 | Public API signatures unchanged | **PASS** | S6: `bind/sync/add_unit/add_building/add_resource/remove` untouched; `remove()` scaffold mirror intact. **derived** |
| 16 | No test edits by this ticket | **PASS (ticket scope)** | S6 has no test hunk; S11 shows `t_build_stages.gd` absent and other tickets' test changes, not this ticket's. **observed** |
| 17 | No fabricated art | **PASS (ticket scope)** | S6 touches only `world3d_entities.gd`; no OBJ/MTL/PNG/manifest edit or creation in this ticket (108 art files pre-exist from BUILD-ART-BATCH-01). **observed + inferred** |
| 18 | Runner artifacts `buildartc01-smoke` / probe | **UNVERIFIED — ABSENT** | S10: no such id in jobs/results spool; no stdout/stderr/JSON to read. **observed (absence)** |
| 19 | Parse/smoke exit 0, stderr 0, `SCRIPT ERROR == 0` | **UNVERIFIED** | No artifact (row 18). Static check only: `_player_tint` resolves, so the new call is not an obvious undefined-symbol parse error — **inferred**, not a runner result. |
| 20 | 64² runtime atom (suffixes 1/2/3/4, bbox, visible scaffold, hit counters) | **UNVERIFIED** | `t_build_stages.gd` absent (S11); BUILD-ART-D outstanding (S3). **observed** |
| 21 | Visual / donor parity | **NO CLAIM** | No capture, no A/B; ticket labels themselves keep `visual UNVERIFIED`. **observed + charter rule** |

## 3. Findings

- **F1 (blocking): no landed report, no runner evidence.** The ticket is still
  RUNNING on the board; a QA PASS cannot be issued for an unlanded ticket.
  **observed**
- **F2 (partial implementation): C1/C5/C7 are present in code, C4/C6 are not.**
  The finished-building scaffold is still freed; the bind-time probe still
  measures only `1`/`a` names. Label honesty in `build_stage_art_status`
  therefore rests on a partial measurement. **observed + derived**
- **F3 (latent, not a proven defect):** the new tint call uses base `sid` for
  `_apply_tint`, so band masking follows the base manifest entry rather than
  the stage art's `tex_name`. This matches the plan's stated option but its
  rendered effect is unmeasured. **derived; visual UNVERIFIED**
- **F4 (provenance):** the partial edits entered HEAD in commit `65a1f49a`
  (12:52:55) while the worker remained RUNNING; whether that commit was made
  by the worker or by COORD is **UNVERIFIED**. **observed commit / inferred attribution**
- **F5 (no prohibited pattern observed):** no assertion weakening, no lowered
  threshold, no invented mesh name, no donor file copied by this ticket.
  **observed from diff**

## 4. Verdict

**NOT_VERIFIED__TICKET_IN_FLIGHT__NO_PROMOTION.**

- Code-level: selector and all frozen blocks are byte-identical; C1 (per-stage
  bbox), C5 (tint re-application) and most of C7 (honest labels) are present
  relative to the ticket's own named backup. That is a **code-level partial
  PASS only**. **observed + derived**
- Runtime: no `buildartc01-smoke`/probe job, no result JSON, no stderr, no
  64² atom, no capture. All runtime and visual claims stay **UNVERIFIED**.
- Completion: `BUILD_ART_C_01.md` absent and worker RUNNING → the ticket has
  **not landed**; a final QA verdict must be re-run after it does.

**No parity claim of any kind is made.**

## 5. Open questions

1. Will `BUILD_ART_C_01.md` land, and will its own gates (exit 0 / stderr 0 /
   `SCRIPT ERROR == 0`) be readable?
2. Are C4 (`<sid>a` completion scaffold) and C6 (probe extension) intentionally
   deferred to a follow-up, or still pending in the same ticket?
3. Once the probe is extended, will `build_stage_obj_hits` and
   `build_scaffold_obj_hits` be positive on a real run?
4. Does the re-applied tint actually survive a stage mesh swap on screen?
5. When does BUILD-ART-D's `t_build_stages.gd` atom land, and do the five
   progress points prove suffix 1/2/3/4 + the stage-4 clamp?
6. Who committed `65a1f49a` — worker or COORD — and does that close the
   ownership window on `world3d_entities.gd`?
7. Are the 8-vertex `cena`/`tow1a`/`mara` meshes intentional minimal LOD?
   Only a render test can answer (carried from STAGE_IMPORT_01 Q3).

## 6. Summary

At 12:56–12:57 the BUILD-ART-C-01 ticket had **not landed**: report absent,
worker RUNNING, zero runner artifacts. A 104,622-byte `world3d_entities.gd`
differs from the ticket's 103,539-byte named backup in exactly four hunks,
adding per-stage bbox lookup, tint re-application after mesh swaps, and
revised honest stage labels, while leaving the selector, rotor, nation,
build-action, tree, motion and public API byte-identical. Completion-scaffold
retention (C4) and probe extension (C6) are not present. No test, asset,
manifest or config edit is attributable to this ticket. **Runtime evidence is
absent, so every runtime/visual item is UNVERIFIED and no promotion or parity
claim is issued.** Re-run this QA after the report and smoke/probe artifacts
land.

*End of QA-BUILD-ART-C-01 report. Read-only; no code, queue or runner mutation.*
