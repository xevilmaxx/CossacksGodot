---
id: DARKROW-ALL-01
title: "Apply P0-GATE-01's metric correction consistently to every remaining piece atom"
owner: DARKROW-ALL-01 (test-atom consistency builder)
date: 2026-11-25
status: DELIVERED__7_PARSE_JOBS_GREEN__NO_WINDOWED_CAPTURE__NO_LADDER
scope: "Hand-edited only the seven granted variant3d/tests/t_*.gd atoms plus this report. Created seven backups under inbox/backup/*.gd.bak-DARKROWALL before the first edit. No harness, game code, shader, config, fixture, gate file, app/** or other report was hand-edited. Runner jobs regenerated only variant3d/.godot_queue/** artifacts (runtime outputs)."
owns:
  - "variant3d/tests/t_terrain_trees.gd"
  - "variant3d/tests/t_terrain_shore.gd"
  - "variant3d/tests/t_terrain_mines.gd"
  - "variant3d/tests/t_combo_trees_shore.gd"
  - "variant3d/tests/t_combo_trees_mines.gd"
  - "variant3d/tests/t_combo_shore_mines.gd"
  - "variant3d/tests/t_combo_all.gd"
  - "docs/coord_swarm_2026-11-25/reports/DARKROW_ALL_01.md"
backup: "inbox/backup/<name>.gd.bak-DARKROWALL — one exact pre-edit copy per atom (7 files)"
labels: [observed, derived, PORT_APPROX, UNVERIFIED]
parity_guard: "PORT APPROX — no donor GPU A/B exists (V3D_02 parity_guard). No donor parity is claimed."
validation: "Seven headless variant-runner --check-only jobs, one per atom, all END ok with SCRIPT ERROR == 0 (stderr 0 B each). No windowed capture, no ladder, no full gates, no direct godot invocation."
---

# DARKROW-ALL-01 — consistent dark-row applicability correction across all remaining atoms

## 0. Question

`P0-GATE-01` proved that `full_width_dark_rows` is a **water-band detector**
(`smallmap_capture.py:25-28`) and changed only `t_terrain_only.gd`: it records
the value as N/A and replaces the inapplicable hard assert with two strict,
applicable luma gates (`P0_GATE_01.md:74-90,176-186`). `FINAL_GATE_PLAN_01`
flagged that sibling atoms may still hard-assert the value and would fail for
**any** ground-only frame even after the terrain is fixed
(`FINAL_GATE_PLAN_01.md:242-248`).

This ticket applies that correction consistently to every remaining piece atom,
without weakening an assertion, lowering a threshold, deleting a check, or
touching a file outside the granted set.

## 1. Sources read (all read-only)

| Source | Used for |
|---|---|
| `docs/coord_swarm_2026-11-25/reports/P0_GATE_01.md:26-29,51-59,61-112,176-208` | The precedent: applicability correction, N/A record, `>=40`/`>=100` gates, no-weakening rule, open questions. |
| `docs/coord_swarm_2026-11-25/reports/METRIC_01_dark_rows.md:47-104,228-268` | Exact metric definition and design intent (water bands, not ground validity). |
| `docs/coord_swarm_2026-11-25/reports/PIXEL_01_p0_capture_review.md:19,37,73-83` | Measured dark frame: `mean_luma=13.271`, peak 28.4, 0 pixels ≥ luma 30. |
| `docs/coord_swarm_2026-11-25/reports/FINAL_GATE_PLAN_01.md:105-115,242-248` | Row-to-atom map; flagged uncorrected sibling asserts; water-bearing rows keep a gate. |
| `docs/coord_swarm_2026-11-25/TEST_MATRIX.md:42-44,67-68` | Water rows require zero dark rows; never weaken an assertion for green. |
| `docs/coord_swarm_2026-11-25/reports/TEST_P1_report.md:20-31`, `TEST_P2_report.md:20-29`, `TEST_P3_report.md:16-28`, `TEST_C1_report.md:20-30`, `TEST_C2_report.md:19-29`, `TEST_C3_report.md:29-38`, `TEST_C4_report.md:18-25` | Each atom's authored scope: which layers are present (water vs no water) and that no runtime/visual result is claimed. |
| Seven granted atoms + their `.bak-DARKROWALL` backups | `grep` of `full_width_dark_rows`, `dark_rows`, `mean_luma`, `max_luma`; line-by-line diffs of every edit. |
| `variant3d/tools/AGENT_PROTOCOL.md:41-59`; `docs/COMMANDS.md:8-9,28-36` | Runner-only rule, unique ids, `--check-only` form, no direct Godot. |

## 2. Classification (derived from each atom's authored fixture)

| Atom | Row | Layers present | Class | Dark-row predicate |
|---|---|---|---|---|
| `t_terrain_trees.gd` | P1 | ground + trees, `no_water_cells`, hidden plane (`TEST_P1_report.md:20-28`) | ground-only | **inapplicable** → record N/A |
| `t_terrain_mines.gd` | P3 | ground + mines, zero water cells (`TEST_P3_report.md:16-26`) | ground-only | **inapplicable** → record N/A (no existing assert) |
| `t_combo_trees_mines.gd` | C2 | ground + trees + mines, no water (`TEST_C2_report.md:19-28`) | ground-only | **inapplicable** → record N/A |
| `t_terrain_shore.gd` | P2 | bounded water basin + shore (`TEST_P2_report.md:20-28`) | water-bearing | **applicable** → keep strict |
| `t_combo_trees_shore.gd` | C1 | P1 + P2 union, water plane present (`TEST_C1_report.md:20-30`) | water-bearing | **applicable** → keep strict |
| `t_combo_shore_mines.gd` | C3 | P2 + P3 union, water cells present (`TEST_C3_report.md:29-38`) | water-bearing | **applicable** → keep strict |
| `t_combo_all.gd` | C4 | terrain + trees + shore + mines (`TEST_C4_report.md:18-25`) | water-bearing | **applicable** → keep strict |

## 3. Per-atom before → after (with citations)

Line numbers are `variant3d/tests/<atom>.gd` in the backup vs the edited file.
Every "before" assertion was verified in the backup copy; every "after" line was
verified by re-reading the edited file and by full `git diff --no-index`.

| Atom | BEFORE (backup) | AFTER (edited) |
|---|---|---|
| `t_terrain_trees.gd` | `:694-695` hard `check("no_full_width_dark_rows", dark_rows == 0, "…expected 0…")`; no luma gates; `CHECK_NAMES` `:102` | `:707-709` same check is `null` with status `RECORDED_NOT_APPLICABLE`; value still in `_m["png_diff"]["full_width_dark_rows"]` (`:688`); new gates `ground_mean_luma >= 40` / `ground_max_luma >= 100` at `:712-715`; names at `:104-105`; headless/no-PNG skips at `:930-931,942-943`. |
| `t_terrain_shore.gd` | `:604-605` strict `png_full_width_dark_rows == 0`; no `max_luma`; `CHECK_NAMES` `:99` | Strict assert **byte-identical** at `:614-615`; new gates `:619-622`; `_image_metrics()` now computes whole-frame peak (`:503,:511-513,:527`); names in `CHECK_NAMES` `:104-105`, `CAPTURE_CHECK_NAMES` `:111`, headless loop `:945`. |
| `t_terrain_mines.gd` | **No dark-row check at all** (`grep`: 0 hits); PNG gate was `png_capture_windowed` at `:588-590`; no `_m` dictionary | New diagnostic member `:107`, set to `N/A … water-band predicate inapplicable` at `:621` and emitted in result `"png"` at `:434`; new whole-frame luma helper `:574-590`; new gates `:624-632` (hard FAIL if no frame captured). Rec.601 `mean_luma` A/B at `:543/:639` and all pre-fix/unverified markers untouched. |
| `t_combo_trees_shore.gd` | `:862-863` hard `full_width_dark_rows == 0` with `V3D_02 T2` detail; no `max_luma` | Strict assert **byte-identical** at `:875-876`; new gates `:880-883`; peak added at `:479,:487-489,:503`; names at `:125-126` (inserted **before** the four capture checks so the `CHECK_NAMES.size()-4` headless/abort window in `_fail_remaining` is unchanged); headless skips `:818-819`. |
| `t_combo_trees_mines.gd` | `:850-851` hard `full_width_dark_rows == 0`; `check()` typed `cond: bool` with no `status` (`:182`); no `max_luma` | `:874-876` record-only `RECORDED_NOT_APPLICABLE` (value still in `_m["png_metrics"]`); new gates `:879-882`; peak added at `:489,:497-499,:513`; names at `:108-109`. Enabling change: `check()` now accepts `Variant cond` + optional `status` (`:182-192`) and `finish()` counts `null` as a skip not a fail (`:204-220`). |
| `t_combo_shore_mines.gd` | `:803-804` hard `full_width_dark_rows == 0`; no `max_luma`; `CAPTURE_CHECK_NAMES` `:129` | Strict assert **byte-identical** at `:814-815`; new gates `:819-822`; peak added at `:460,:468-470,:486`; names in `CHECK_NAMES` `:125-126` and `CAPTURE_CHECK_NAMES` `:134`. |
| `t_combo_all.gd` | `:995-996` hard `full_width_dark_rows_zero == 0`; `:999-1001` mean luma **recorded only**; no peak; `no_new_seam_class` at `:1004-1008` | Strict assert **byte-identical** at `:1002-1003`; new gates `:1007-1010`; `max_luma_0_255` added to `_image_metrics` at `:485,:501-502,:526`; `no_new_seam_class` and `mean_luma_recorded` byte-identical. |

Notes on the enabling change in `t_combo_trees_mines.gd`: without it a
`null` record-only check would be a type error and would be miscounted as a
hard FAIL. For every pre-existing call (`bool` cond, no `status`) the emitted
status remains exactly `PASS`/`FAIL`; only the new diagnostic uses the new path.

## 4. Backups

All created before the first edit, one exact copy per atom:

```
inbox/backup/t_terrain_trees.gd.bak-DARKROWALL       36609 B
inbox/backup/t_terrain_shore.gd.bak-DARKROWALL       36124 B
inbox/backup/t_terrain_mines.gd.bak-DARKROWALL       31156 B
inbox/backup/t_combo_trees_shore.gd.bak-DARKROWALL   34371 B
inbox/backup/t_combo_trees_mines.gd.bak-DARKROWALL   32795 B
inbox/backup/t_combo_shore_mines.gd.bak-DARKROWALL   31080 B
inbox/backup/t_combo_all.gd.bak-DARKROWALL           39260 B
```

No other backup file was created or overwritten by this ticket.

## 5. Validation — variant runner only, `--check-only`

All launches used the documented parse form (`AGENT_PROTOCOL.md:59`,
`CONFIG_WIRE_HUD.md:94`):

```
python variant3d\tools\godot_runner.py run --id darkrowall-<atom> --timeout 180 --max-wait 1800 -- --headless --path variant3d --check-only --script res://tests/<atom>.gd
```

No `--headless` capture script execution was requested: `--check-only` parses
and validates the script only. No windowed PNG, no ladder row, no full gate, no
direct `godot`, no terrain/shader/config/config-fixture edit to force a pass.

### 5.1 Successful validation jobs (one per atom)

| Atom | Winning id / ticket | Runner result | wait / run | stderr | SCRIPT ERROR |
|---|---|---|---|---|---|
| `t_terrain_trees.gd` | `darkrowall-t_terrain_trees-r1` / 486 | `END ok` | 294.17 s / 4.80 s | 0 B | **0** |
| `t_terrain_shore.gd` | `darkrowall-t_terrain_shore-r1` / 493 | `END ok` | 195.07 s / 8.75 s | 0 B | **0** |
| `t_terrain_mines.gd` | `darkrowall-t_terrain_mines-r2` / 501 | `END ok` | 150.50 s / 6.97 s | 0 B | **0** |
| `t_combo_trees_shore.gd` | `darkrowall-t_combo_trees_shore` / 475 | `END ok` | 439.27 s / 13.14 s | 0 B | **0** |
| `t_combo_trees_mines.gd` | `darkrowall-t_combo_trees_mines-r1` / 505 | `END ok` | 54.87 s / 8.26 s | 0 B | **0** |
| `t_combo_shore_mines.gd` | `darkrowall-t_combo_shore_mines-r1` / 506 | `END ok` | 0.00 s / 12.90 s | 0 B | **0** |
| `t_combo_all.gd` | `darkrowall-t_combo_all-r1` / 507 | `END ok` | 0.00 s / 10.67 s | 0 B | **0** |

`SCRIPT ERROR == 0` was checked per job on its own
`variant3d/.godot_queue/results/<ticket>_<id>/stderr.txt` (every file 0 bytes);
stdout is the 75-byte Godot 4.7.2 banner in each case.

### 5.2 Honest accounting of the failed attempts (no hidden re-runs)

The first batch was submitted in parallel. The runner's FIFO ticket advance is
not safe under simultaneous submissions: tickets 469-473 were reported
`skipped (serving=475)` and ticket 474 died with `PermissionError` on
`now_serving.tmp` before Godot launched. None of those six produced a parse
result; only ticket 475 ran. The remaining six atoms were then re-submitted
**one at a time**. Ticket 497 (`darkrowall-t_terrain_mines-r1`) produced a real
parse error from my edit — `SCRIPT ERROR: Parse Error: Identifier "_m" not
declared in the current scope (t_terrain_mines.gd:618)` — because that atom has
no `_m` dictionary. I fixed it by using the dedicated member
`_full_width_dark_rows_diag` (`:107,:434,:621`) and re-checked once (ticket 501,
`END ok`). No other job failed, and no job was re-run after a red *test* result.

### 5.3 What this validation does not prove

`--check-only` proves parse/compile validity, not runtime assertion outcomes,
not PNG appearance, and not `mean_luma`/`max_luma` values. No atom was executed
windowed here; ladder rows P1-C4 remain UNVERIFIED as before
(`FINAL_GATE_PLAN_01.md:224`). The strict gates are expected to fail on a
ground frame as dark as P0's 13.271/28.4 (`PIXEL-01:19,37`), but no such frame
was captured in this ticket.

## 6. Explicit no-weakening statement

- **No threshold was lowered.** Every new gate uses exactly P0's `>=40.0` and
  `>=100.0` (`P0_GATE_01.md:84-85,92-112`); these are ~3× and ~4× the measured
  dark-frame values, chosen to fail the defect, not fit it.
- **No existing assertion was deleted.** Four water-bearing dark-row asserts
  remain byte-identical (`t_terrain_shore.gd:614-615`,
  `t_combo_trees_shore.gd:875-876`, `t_combo_shore_mines.gd:814-815`,
  `t_combo_all.gd:1002-1003`); `non_black_fraction > 0.9`,
  `no_full_height_dark_cols`, `no_new_seam_class`, all structural/category
  checks and all `EXPECTED_PRE_FIX_FAILURE` / `UNVERIFIED` markers are unchanged.
- **Nothing was converted from hard to record-only except three ground-only
  predicates that are inapplicable by construction**: `t_terrain_trees.gd`,
  `t_combo_trees_mines.gd` (pre-existed) and `t_terrain_mines.gd` (which had no
  such predicate; an N/A diagnostic was added instead). Their values remain
  recorded (`_m["png_diff"]`, `_m["png_metrics"]`, result `"png"`), auditable
  exactly as in P0 (`P0_GATE_01.md:178-181`).
- **Applicability, not relaxation**: the corrected atoms gain two *hard* gates
  that did not exist before. A water-free frame can no longer pass by being
  uniformly dark; a water-bearing frame must still have zero dark rows AND
  clear both luma floors. `TEST_MATRIX.md:67-68` is respected.
- No terrain/shader/atlas/camera/config/fixture/harness code was touched to
  manufacture a green result. `TEST_MATRIX.md:67-68` and the P0 precedent
  (`P0_GATE_01.md:176-186`) are respected.

## 7. Open questions / UNVERIFIED

1. **No donor GPU A/B exists**; `>=40` and `>=100` remain PORT APPROX, as in P0
   (`P0_GATE_01.md:190-192`). They are not donor calibration.
2. **No runtime measurement.** `--check-only` gives no new luma numbers. Whether
   a post-fix windowed P1-C4 frame clears `>=40`/`>=100` is UNVERIFIED and is
   for COORD's ladder, not this ticket.
3. **`max_luma >= 100` on a sky-free healthy frame** may be strict; if a future
   donor/healthy ground capture proves a lower peak valid, that needs a separate
   evidence-backed ticket — it must not be relaxed here (`P0_GATE_01.md:203-206`).
4. **Out-of-scope sibling:** `variant3d/tests/t_season_overlay.gd:767` still
   hard-asserts `id + "_full_width_dark_rows" == 0`. It is **not** in this
   ticket's granted ownership and was **not** edited; if that atom captures a
   water-free frame it needs its own applicability ticket.
5. **Runner race:** parallel `godot_runner.py run` submissions advanced
   `now_serving` concurrently and skipped five tickets / crashed one. All
   validation was subsequently done sequentially. No runner/tool code was
   changed by this ticket.
6. **Headless behaviour** of the new gates was not exercised (parse-only); the
   SKIP/UNVERIFIED paths added to the skip lists were not run.

## 8. Summary

- Classified all seven remaining atoms by authored layer content and applied
  P0-GATE-01 consistently: **three ground-only** atoms record the water-band
  metric as N/A; **four water-bearing** atoms keep their strict `==0` assert.
- Added the same strict, applicable gates `ground_mean_luma >= 40` and
  `ground_max_luma >= 100` to **all seven**, including the whole-frame peak
  computation each atom previously lacked.
- Kept every structural/category/PNG assertion and every pre-fix marker
  byte-identical; no threshold lowered, no check deleted, no green-washing.
- Seven backups created first; full diffs reviewed; one self-introduced parse
  error found by the runner and fixed before final validation.
- Seven sequential `--check-only` jobs, one winning job per atom, all
  `END ok` with `SCRIPT ERROR == 0`. No windowed capture, no ladder, no full
  gates, no direct Godot.
- **No other file was edited by this ticket.** The only hand edits are the
  seven granted atoms, their seven backups and this report. A concurrent
  builder's `step` commits (`1d67e32b`, `d1fb9e58`, `83b77eaa`) picked up the
  working tree, so the seven atoms and backups no longer appear as unstaged in
  `git status`; commit `83b77eaa` contains exactly my final `_m` fix. All other
  changes visible in `git status`/those commits belong to concurrently active
  builders; runner-generated `.godot_queue/**` artifacts are runtime outputs,
  not hand edits.

---

*End of DARKROW-ALL-01. One applicability correction per atom, no weakening, no runner-code change, no donor-parity claim.*
