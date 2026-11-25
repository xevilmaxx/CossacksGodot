---
id: QA-AUDIT-01
title: "QA-AUDIT-01 — independent verification of implementation claims vs diffs and runner artifacts"
date: 2026-11-25
owner: QA-AUDIT-01 (read-only auditor)
status: COMPLETE__FINDINGS_5_PLUS_1_INFO__NO_CODE_EDITED
scope: "Audit only the listed reports, their owned files' diffs and existing variant3d/.godot_queue/results/** artifacts. No Godot job was run; no code, test, config, backup or other report was edited; no donor file was opened or copied."
method: "Per report: read claim table -> diff pre-edit backup against live file -> check cited ticket JSON/stdout/stderr -> attribute by SWARM_BOARD.md ownership. NOTE: a concurrent builder committed the tree mid-audit (HEAD f9dd8d16 'step'); hence backup-vs-live diffs include later foreign edits, which are attributed separately (see F-02/F-04)."
verdict_scale: [CONFIRMED, PARTIAL, REFUTED]
---

# QA-AUDIT-01 — implementation-claim audit

## 1. Scope and attribution rules

Audited: SEL-01; CAM-01 + CAM-02; TRN-SHADER, TRN-WATER, TRN-GEOM, DECOR-01, HUD-01,
UITEST-ANCHOR, INT-REGISTRY, CFG-01; ATOM-REPAIR; HARNESS-01 (landed during the audit).
`MAP_SMALL_01_report.md`, `TRN_DATA_implementation.md` were **not present** in
`reports/` at audit time → out of scope ("if landed"), noted in §5.
Ownership taken from `SWARM_BOARD.md` §Batch D/F/G/H/I, not from report self-claims.
Artifacts read only from `variant3d/.godot_queue/results/NNNNNNNN.json` plus their
`stdout.txt`/`stderr.txt`. Selftest/uitest exit-code semantics confirmed at
`variant3d/scripts/main.gd:2003` (`_quit(0 if report.passed else 1)`), so `status=ok,
exit=0` is proof of a green 29-step/17-step report even where the generated JSON was
later overwritten by another job.

## 2. Per-ticket audit table

| Ticket | Claim (abridged) | Diff evidence (backup → live) | Job artifact | Verdict |
|---|---|---|---|---|
| SEL-01 | Overlay `SelectionRectPainter`/`SelectionRectOverlay` yellow 1px no-fill; 6px screen threshold → 0.005 m (0.25 attack/guard) world epsilon; Shift=union; double-click 0.35→0.5; click branch/`cmd_*` untouched; **only** `input_controller.gd` edited | `input_controller.gd.bak-SEL01` → live: 144+/5-, 8 hunks, all six claimed hunks present with inline `onmousemove.inc`/`selection.cfg`/`menu.cfg` citations; no foreign file attributable | 337 `sel01-selftest-final` ok/0 ⇒ 29/29; 318 `sel01-uitest` ok/0 ⇒ 17/17; 329 `sel01-probe-shift` ok/0, stdout `PASS 12/12` incl. `shift_drag_is_additive` | **CONFIRMED** |
| CAM-01 | Two comment-only hunks in `camera3d.gd`; FOV value 17.27 unchanged; no behaviour change | Final check: backup→live is exactly 2 hunks / 24+/4-, all `+`/`-` comment lines; `const FOV_DEG_ASSUMED: float = 17.27` byte-identical. (A transient MMJUMP-01 code hunk existed mid-audit and is gone — F-03.) | 339 `cam01-smoke` ok/0, stderr 0 B, `CAM01_SMOKE_OK` | **CONFIRMED** |
| CAM-02 | One hunk, 4+/4-, `xy = (c as Vector2) + Vector2(ox, oz)` in Vector2 branch only; no other file; runtime parity left UNVERIFIED | `world3d.gd.bak-CAM02` → live: exactly 4+/4- in one hunk at `_update_view_rect`; `ox/oz` already at `:252-253`, Vector3 branch/AABB untouched | 356 `cam02-smoke` ok/0, stderr 0 B, stdout `CAM02_SMOKE_OK view_rect=[P:(0,0),S:(5120,5120)]` (full-map fallback) | **CONFIRMED**; parity since resolved by CAM-RV-01 job 381 `ok`/0, `PASS 20/20` |
| TRN-SHADER | A1 world-XZ texgen; A2 `uv_repeat=0.5` from `gc_meters_to_tile=2`; B1 donor sun vector/`lsParallel`; B2 `(x/4,z/2,y)`; B3 ambient/diffuse; B4 `unshaded` kept; C1 64² sub-rect; **C2 `5+mod(abs(tile),22)`**; C3 face planes; C4 `mask_to_alpha` unchanged; D no forbidden effects | All claimed hunks present and cited. **C2 is no longer in the live file**: shader:343 says "old arbitrary `5 + mod(tile,22)`" and `alpha_patch_uv()` now uses DALPHA-02's dir/row/half/variant/opposite decomposition. Superseding edit is owned by DALPHA-02 (`bak-DALPHA02`, own report §3, job 382), not a TRN-SHADER cross-file edit | 342 `trnshader-smoke` ok/0, stderr 0 B, `T_TERRAIN3D RESULT: PASS 6/6` | **PARTIAL** — implementation CONFIRMED at delivery; C2 claim stale vs current tree (F-02) |
| TRN-WATER | `water_surface_y` decoupled from −0.25 classification; `water_cell = 1-step(water_level,height)` alpha gate; exact 0.57/1.07 ramp preserved; `shore_prox` removed; stats fields; exactly two owned source files; grass1 clamp handed off | `water3d.gdshader` + `water3d.gd` vs backups: all five changes present; donor literals (−0.25/−0.1/2.96/170/120/30, 0.1/0.01, HDR 1) unchanged; cross-owner note present; no edit to `world3d_terrain.gd` | 343 `trnwater-smoke` ok/0, stderr 0 B, `TRNWATER_SMOKE RESULT: PASS`, `shader_loaded=true problems=0` | **CONFIRMED** |
| TRN-GEOM | 25° `vf`/`vs` normal tilt, sector tables, height gates, light/sky colours + uniform binds, 1-cell normals, BLK_WATER→sandsea1/5/6, stats; topology unchanged; diff 384+/35- | All claimed hunks present with `texturemap.inc`/`tiles.lib`/`light.cfg`/`skydome.cfg` citations; `TILE_M=2.0` value unchanged (comment only); vertex/triangle/surface invariants unchanged. 384+/35- matches HEAD commit stat; current backup→live is 603+/35- because of RELIEF-01's later foreign hunks (F-04) | 361 `trngeom-smoke` ok/0, stderr 0 B, `SCRIPT ERROR 0` (also 350 ok/0) | **CONFIRMED** (own hunks); diff-size claim **PARTIAL** vs current tree |
| DECOR-01 | `POOL_TREE` 6→19, 18-sid scale ladder 0.475–0.76, three jitter bands, mine bypass, yaw=0/stand OPEN/mine disc BLOCKED labels; only `world3d_entities.gd` | `world3d_entities.gd.bak-DECOR01` → live: `POOL_TREE` 19 sids, `ENV_TREE_SCALE` 18 entries all cited to `envscales.cfg`, `ENV_JITTER_BANDS`, `_jitter_factor` only called for `type=="wood"`, statuses present; `ENV_SCALE` unchanged (comment only) | 358 `decor01-smoke` ok/0, `DECOR01_SMOKE_STATS pool=19/19 ladder=18 band=wide mine=0.3152 resources=3`; SE=0 (479 B stderr = pre-existing warnings) | **CONFIRMED** |
| HUD-01 | 200→240 bottom-right minimap −8/−8, panels clipped, adapter `get_minimap_corners()` with centred-world formula + preserved half-map offset; only 2 owned files; other files read-only | `hud.gd`: 240×240, anchors 1/1, offsets −278/−270/−8/−8, `strip_right` partition; click/texture path unchanged. `hud3d_adapter.gd`: centred `u=p.x/extent.x`, `p=pc+half`; numeric equivalence to old `p.x/TILE_M` holds | 340, 349, 357 all ok/0, stderr 0 B, `SCRIPT ERROR 0` (parse-only) | **CONFIRMED** |
| UITEST-ANCHOR | `uitest.gd:306-309` only: `anchor_left 0.0→1.0`, detail string, 2 citation comments; no assertion weakened; 17/17 | Backup → live: 4+/2- in one hunk, exactly as claimed; strict equality retained; all 16 other steps and 17 scenes unchanged | 366 `uitestanchor-uitest` ok/0; `uitest.json` `passed:true`, 17/17, step 14 `minimap bottom-right: yes` | **CONFIRMED** |
| INT-REGISTRY | `result_dir` app→variant3d, +9 additive `pending` rows (31→40), helper unregistered, `test_all.py` roots + `--path`; no Godot job | Both files vs backups: exactly the claimed changes; no existing entry altered; no atom/fixture edited | No runner job cited and none exists for this ticket (registry-only, per scope) | **CONFIRMED** (by diff; `--list` not re-executed — audit is read-only) |
| CFG-01 | menu/config defaults 320→240, land→mediterranean, plains→low_mountains/hills, rus/bav; data.gd untouched; no test edits | `menu.gd` 4 value lines + comment; `config.gd` all claimed built-in and fallback literals; `data.gd` not in owned set and unchanged | 312 `cfg01-selftest` ok/0 ⇒ 29/29; 313 `cfg01-uitest` ok/0 ⇒ 17/17 | **PARTIAL** — diff/gates CONFIRMED; one ancillary claim REFUTED (F-04) |
| ATOM-REPAIR | 9/9 atoms parse/load; 7 files minimally fixed, 2 unchanged; 0 parse errors; stated SE counts; assertions and `expected_pre_fix_failure` markers intact | 7 backups→live diffs are exactly the claimed inherited-field dedups, signature/type fixes, `is_empty()`→`has_area()`; `t_terrain_trees.gd` and `t_combo_trees_mines.gd` 0 diff lines; marker counts identical backup/live (`t_select_rect` 4/4 textual = 3 cited lines, `t_terrain_shore` 6/6, `t_combo_shore_mines` 0/0); `CHECK_NAMES` unchanged | 364 ok/0 SE0; 365 failed/1 SE1; 367 failed/1 SE0; 368 ok/0 SE1; 369 failed/1 SE1; 370 failed/1 SE1; 372 ok/0 SE0; 374 ok/0 SE0; 375 failed/1 SE0. Parse errors 0 in all nine; each SE is the one harness cast error at `_smallmap_harness.gd:134` | **CONFIRMED** (report's SE table matches artifacts exactly) |
| HARNESS-01 | One guarded `is` hunk in `count_categories()`, backup hash, job 384 SE=0 | `_smallmap_harness.gd.bak-HARNESS01` → live: one hunk at `:131-141`, `as Object` replaced by `if n is Dictionary / elif n is Object`; accumulator/`match`/5 APIs unchanged; backup SHA `9EBC563D…` matches report | 384 `harness01-smoke` **failed/exit 1** (atom's own `FAIL 21/22` headless verdict, unchanged from 365) but SE=0, `Invalid cast`=0 | **CONFIRMED** |

## 3. Cross-cutting findings (ranked)

**F-01 — MEDIUM — FINAL gate is not green in the current tree, despite the reports' 29/29 claims.**
`git show HEAD:variant3d/selftest.json` → `passed:false`, 26/29, failing `wall` ("stone wall
missing"), `shell`, `farm_cap` — the exact 240² failure signature documented in
`reports/CFG_02_no_menu_defaults.md:87-94`. Current worktree `variant3d/selftest.json`
→ `passed:false`, 28/29, failing `build`. `variant3d/config.json` is committed at
`map_width_tiles/height_tiles: 240`, yet `MAP_SMALL_01_report.md` has **not** landed and
`selftest.gd` carries uncommitted MAPSMALL diagnostic edits
(`ink.grow(0.6)` → `ink.grow(4.0)` at `selftest.gd:151-161`). The 29/29 claim is valid only
for job artifacts 312/337 (exit 0), not for the integrated state. Evidence:
`variant3d/selftest.json`, `git show HEAD:variant3d/selftest.json`,
`variant3d/config.json:41-42`, `git diff -- variant3d/scripts/selftest.gd`.

**F-02 — MEDIUM — TRN-SHADER claim C2 is stale relative to shipped code.**
Report C2/§5 index `5 + mod(abs(tile),22)`; the live
`variant3d/shaders/terrain_tileindex.gdshader:343-375` contains `alpha_patch_uv()` with
`dir/row/variant/half/opposite` decomposition and names `5 + mod(tile,22)` only as the
*old* map. This is a later, properly owned DALPHA-02 edit (backup
`terrain_tileindex.gdshader.bak-DALPHA02`, `reports/DALPHA_02_patch_mapping.md` §3,
job 382 ok/0 `PASS 6/6`), **not** evidence that TRN-SHADER edited a foreign file. No
report was amended to point at the superseding ticket.

**F-03 — INFO (resolved) — live-tree churn during the audit.**
At one mid-audit sample, `camera3d.gd.bak-CAM01` → live showed 4 hunks / 111+/20-, the
extras being MMJUMP-01 jump-helper code. By final verification those foreign hunks were
gone (MMJUMP-01 now has its own `inbox/backup/camera3d.gd.bak-MMJUMP01` and report), and
the diff is again exactly 2 comment-only hunks / 24+/4-. No CAM-01 claim was violated;
this is recorded only because the worktree was demonstrably being mutated concurrently.

**F-04 — LOW — TRN-GEOM's "384 insertions / 35 deletions" is no longer the full diff.**
Backup→live is now 603+/35-; the extra ~219 lines are RELIEF-01's opt-in relief-grid
tables and helpers (`world3d_terrain.gd:75-95,185-236`, report `RELIEF_01_stamping.md`
pending). 384/35 remains correct for TRN-GEOM's delivery (HEAD commit stat).

**F-05 — LOW — One CFG-01 ancillary claim is refuted by code.**
`CFG_01_skirmish_defaults.md:113,126` says the no-menu `map_type: land` is "superseded by
the new built-in `terrain_type`". `config.gd:429` reads
`text("gameplay.terrain_type", text("gameplay.map_type","mediterranean"))`; `config.json`
has no `terrain_type` key, so `land` *is* used. `CFG_02_no_menu_defaults.md:40-50`
already corrected this (isolation tickets 317/319). No code was changed by CFG-01 on
that basis, so the implementation verdict is unaffected.

**F-06 — INFO — No prohibited patterns found.**
Across all audited diffs: no deleted/relaxed assertion, no deleted
`expected_pre_fix_failure` marker, no invented donor constant presented as donor truth
(the 240 port-dropdown value, `WATER_SURFACE_Y=-0.25`, `5+mod`-then-DALPHA map, jitter
hashes and 25° tilt are all explicitly labelled PORT APPROXIMATION / UNVERIFIED), and
no donor binary/asset copied into the repo. The only expectation change,
UITEST-ANCHOR's `0.0→1.0`, is a donor-cited correction disclosed as such. All 25
backups named by the audited landed reports exist (`inbox/backup/*.bak-<TICKET>`), with
the reported byte sizes/hashes (e.g. `world3d.gd.bak-CAM02` SHA `66A37C32…`,
`world3d_terrain.gd.bak-TRNGEOM` SHA `E255059F…`, harness SHA `9EBC563D…`).

## 4. Missing backups

None. Every landed report's claimed backup is present in `inbox/backup/` and matches
its stated size/hash. The unlanded MAP-SMALL-01 files (`selftest.gd.bak-MAPSMALL01`,
`config.json.bak-MAPSMALL01`) and CFG-02's reverted backup
(`config.json.bak-CFG02`) also exist.

## 5. Open questions / not audited

1. `MAP_SMALL_01_report.md` and `TRN_DATA_implementation.md` had not landed; their
   diffs/jobs (338/345/354/360/363/371/376/379) were not audited as claims. MAP-SMALL-01
   work-in-progress is the proximate cause of F-01.
2. Will COORD re-run the FINAL selftest/uitest/clean gate after RELIEF-01, MMJUMP-01,
   S1-INPUT-FIX and MAP-SMALL-01 land, and regenerate a green `selftest.json`?
3. Should TRN-SHADER/TRN-GEOM/CFG-01 reports be amended with "superseded by DALPHA-02 /
   RELIEF-01 / CFG-02 correction" pointers (F-02/F-04/F-05)?
4. ATOM-REPAIR's four non-green headless verdicts (365/369/370 `FAIL`, 374
   `SKIPPED_HEADLESS FAIL 0/1`, 375 `FAIL 0/1`) are parse-only by design; the windowed
   capture ladder remains unrun and was not re-judged here (visual parity out of scope).
5. No visual/parity judgement was made on any ticket, per the audit charter.

## 6. Summary

| Verdict | Count | Tickets |
|---|---:|---|
| CONFIRMED | 10 | SEL-01, CAM-01, CAM-02, TRN-WATER, DECOR-01, HUD-01, UITEST-ANCHOR, INT-REGISTRY, ATOM-REPAIR, HARNESS-01 |
| PARTIAL | 3 | TRN-SHADER (C2 superseded), TRN-GEOM (stale diff-size statement), CFG-01 (one ancillary claim refuted, diff/gates fine) |
| REFUTED | 0 at ticket level | 1 sub-claim: CFG-01's "config.json map_type superseded" note (F-04) |

All cited runner tickets exist with the claimed status/exit; every reported pass count
that is present in stdout matches (337/312 selftest exit-0⇒29/29, 318/366 uitest 17/17,
329 probe 12/12, 342/382 6/6, 358 pool 19/19, 381 20/20). The only material integration
risk found is F-01: the committed/worktree selftest report is not green. No code, test,
config, report other than this one, or backup was edited by this auditor; no Godot job
was launched.
