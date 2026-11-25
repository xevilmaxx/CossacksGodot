---
id: MAP-SMALL-01
title: "240² no-menu default: harness site search + global features table — attempted, gates failed, both owned files reverted"
owner: MAP-SMALL-01 subagent
date: 2026-11-25
status: REVERTED__GATES_NOT_GREEN
owns:
  - "variant3d/scripts/selftest.gd"
  - "variant3d/config.json"
  - "docs/coord_swarm_2026-11-25/reports/MAP_SMALL_01_report.md"
evidence_labels: [observed, derived, inferred]
---

# MAP-SMALL-01 — honest result: 240² gate not achieved; both owned files restored

## Outcome

**Both owned files are byte-identical to their pre-ticket backups** and the
mandated 240² selftest gate never passed. `config.json` is back at 320×320 and
has **no `features` object**; `selftest.gd` is back to its original fixed-ring
`_spot()`. Per the ticket rule *"If any gate fails, revert BOTH files from
backups and report the evidence honestly"*, no net change is delivered. The
`features` addition requested in the coordinator's scope ping was prepared,
backed up and JSON-validated, but was necessarily removed by that same full
revert (details below).

## CFG-02 evidence restated (why this ticket existed)

From `CFG_02_no_menu_defaults.md`:

| Ticket | Job id | Gate | Config | Result |
| --- | --- | --- | --- | --- |
| 317 | `cfg02-selftest-r2` | selftest | 240² / mediterranean | failed, 26/29 — `wall`, `shell`, `farm_cap` |
| 319 | `cfg02-selftest-iso1` | selftest | 240² / land | failed, same 3 steps (map type ruled out) |
| 322 | `cfg02-selftest-iso2` | selftest | 320² / land | **ok, 29/29** |
| 325 | `cfg02-uitest` | uitest | 240² / land | **ok, 17/17** |

CFG-02 also corrected CFG-01: `config.json` has no `terrain_type` key, so
`config.gd` reads the present `gameplay.map_type` (`"land"`) directly; the
supersession claim was inaccurate. This ticket therefore left `map_type: land`
untouched. The relief resolves to hills via the fallback path, and 240 is the
port's Tiny dropdown value (`menu.gd:696-699`), not an invented donor number.

## Backups (both taken before any edit)

- `inbox/backup/selftest.gd.bak-MAPSMALL01` — 34,094 B, original fixed-ring file.
- `inbox/backup/config.json.bak-MAPSMALL01` — 14,409 B, 320² / `land`, no features.
- `inbox/backup/config.json.bak-CFGJSON` — 14,409 B, taken immediately before
  the `features` insertion (240² / `land`, no features).

Final state verified with `git diff --no-index` against both MAPSMALL01 backups:
**no differences**. `json.load` on the restored `config.json`: valid, map
320/320, `features` absent.

**Caveat — HEAD moved during this ticket:** after the revert, `git status` shows
both owned files as modified. `git diff` reveals that a concurrent commit made
during the run captured the in-flight `features` block and the last `_spot()`
revision into HEAD. The restored files are byte-identical to the pre-ticket
MAPSMALL01 backups as the ticket rule requires, so they appear as deletions
relative to that newer HEAD. No `git` command was run by me.

## What was attempted

### `_spot()` (selftest.gd:123-133 before → rewritten in place)

Before (original, 6–24 m fixed ring):

```
for r in [6.0, 10.0, 14.0, 18.0, 24.0]:
    for k in 8:
        var p := near + Vector2(cos(a), sin(a)) * r
        if bool(game.can_place(0, sid, p).get("ok", false)): return p
return Vector2.INF
```

After (several revisions; final attempted form): keep the historic 6/10/14/18/24 m
ring first, then extend outward with rings derived from the map's metre extent
(`span_m = min(MAP_W,MAP_H) * Data.TILE_M`): outer limit `0.25 * span_m`,
step `max(6, 0.0125 * span_m)` → **160 m / 8 m at 320², 120 m / 6 m at 240²**;
finer angular sampling (8→32) on the near rings; plus two *stricter* site
filters — reject a site whose drawn ink box (`game.bld_block_rect_for`) comes
within one tile + 0.75 m of the builder, and reject a site whose work slot
(`game._work_slot`) has no clear line from the builder (`game._nav_line_clear`).
The `game.can_place(...)` predicate and the `Vector2.INF` "no valid spot"
assertion were never changed, and no step's pass criteria, thresholds or
expected values were touched.

Search bounds before → after: **6–24 m fixed → 6–160 m at 320², 6–120 m at
240², with the original ring preferred first**. This was the harness-geometry
change the ticket asked for; it was reverted because it did not make the gate green.

### `config.json`

Before → after (attempted): `gameplay.map_width_tiles` / `map_height_tiles`
`320 → 240`; `gameplay.map_type` stayed `"land"`; all other keys unchanged.
Final: restored to 320/320 from the backup.

### Additive `features` section (owner ping)

Added a top-level `features` object mirroring all **21 leaf keys** of
`FEATURES_DEFAULTS` (`config.gd:46-84`): selection 5, terrain 6, water 3,
weather 1, camera 1, hud 3, render 1, gameplay 1 — exact values, no invention,
deep-merge compatible with `config.gd:378-384`. PORT APPROX / UNVERIFIED
values were carried verbatim (`terrain.texgen_mode`, `terrain.alpha_patch_mode`,
`water.surface_y`, `camera.fov_deg`); JSON has no comment syntax, so the labels
live in `config.gd` and are restated here rather than added as new keys.
`json.load` passed and 240² / `land` stayed intact with the block present.
It was removed by the mandatory full revert.

## Gate evidence — all jobs went through `variant3d/tools/godot_runner.py`

No `godot` binary was invoked directly. No test atom, manifest, gate file or
other owned-external file was edited.

### 320² baseline (with an early `_spot` revision)

| Ticket | Job id | Gate | Result |
| --- | --- | --- | --- |
| 338 | `mapsmall01-selftest-320` | selftest, 300 s | **ok, 29/29** |

This proves the earliest revision did not regress the baseline; the **final**
`_spot` revision was never re-run at 320, so that claim is not made.

### 240² selftest iterations

| Ticket | Job id | Result |
| --- | --- | --- |
| 345 | `mapsmall01-selftest-240` | failed — 4 steps: `build`, `wall`, `shell`, `farm_cap` |
| 354 | `mapsmall01-selftest-240-r2` | failed — 3 steps: `wall`, `shell`, `farm_cap` |
| 385 | `mapsmall01-selftest-240-r3` | failed — same 3 |
| 412 | `mapsmall01-selftest-240-r4` | failed — 1 step: `build` |
| 425 | `mapsmall01-selftest-240-r5` | failed — `build` |
| 439 | `mapsmall01-selftest-240-r6` | failed — `build` |
| 461 | `mapsmall01-selftest-240-r7` | failed — `build` (queued 1388 s; run 25.6 s) |

Diagnostic jobs (temporary prints, all removed before the final runs): 360
`mapsmall01-diag-240`, 363 `mapsmall01-diag2-240`, 371 `mapsmall01-diag3-240`,
376 `mapsmall01-diag4-240`, 379 `mapsmall01-diag5-240`, 387 `mapsmall01-diag6-240`,
389 `mapsmall01-diag7-240`, 392 `mapsmall01-diag8-240`,
395 `mapsmall01-diag9-240` (aborted by a `Rect2.distance_to` parse error),
403 `mapsmall01-diag10-240`, 420 `mapsmall01-diag11-240`,
445 `mapsmall01-diag12-240`.

The original mandated 240² uitest id `mapsmall01-uitest-240` was **not run** in
this ticket; the 17/17-at-240 evidence remains CFG-02 ticket 325.

### JSON-addition validation (with `features` present, 240²)

| Ticket | Job id | Gate | Result |
| --- | --- | --- | --- |
| 485 | `mapsmall01-json-selftest` | selftest, 300 s | **failed**, 28/29 — `build` only |
| 494 | `mapsmall01-json-uitest` | uitest, 240 s | **timed out** (hard kill at 240 s); no fresh 17/17 verdict |

## Root cause found — CFG-02's inference was incomplete

Instrumented 240² runs showed `_spot()` **does** return valid build sites in the
original 6 m ring for `hou` and `wal` (e.g. `hou` at 6 m, `wal` at 6 m).
The failures are downstream of site legality:

1. The house placed by the `build` step has a drawn sprite box roughly 9.5 ×
   6.5 m (`game.bld_block_rect_for`, `game.gd:1515-1549`), far larger than its
   1.5 m gameplay radius. The anchor peasant later walks into that box during
   the mine phase. `game._blocked_for()` (`game.gd:159-189`) then rejects all
   16 probe directions around it (`free16 = 0`), the build order gives up on
   `stuck_t > 8` (`game.gd:4756-4759`), and `wall`/`farm_cap` see zero progress.
2. Rejecting trapping sites in `_spot()` fixes `wall` and `farm_cap` (they then
   pass), but the only remaining nearby house sites need a long detour, so
   `build` no longer finishes inside its fixed 25 s window
   (`selftest.gd:261-267`). Increasing angular resolution and adding a
   clear-work-slot requirement did not find a site satisfying both.

This is a harness-layout/timing interaction, not a wrong config value, and it
cannot be repaired by scaling the search ring alone. Fixing it within the
"no assertion/threshold changes" rule would require editing other steps of
`selftest.gd` (build-site timing or builder handling), which this ticket's
minimal-diff scope did not permit.

## No weakening

No pass criterion, threshold, expected value or assertion was changed at any
point. The additional site filters made `_spot()` stricter, never looser;
every temporary diagnostic print was removed before the final runs and the
final gate verdicts are the runner's own.

## Open questions

1. Should a follow-up ticket own the `build` step as well, so a house site can
   be chosen that is both quickly walkable and clear of the later peasant
   path? That is the only visible route to 29/29 at 240 without test weakening.
2. Why did `mapsmall01-json-uitest` hit the 240 s hard timeout when CFG-02's
   `cfg02-uitest` finished in 47 s at the same map size? Concurrent builders'
   work and queue load are candidates; not isolated here.
3. The `features` table is inert today (no consumer reads it). Should it be
   re-applied by its own small ticket once the small-map gate is green, rather
   than being coupled to this reverted change?

## Summary

Map-scaled `_spot()` and the 240² config were implemented and exercised
through the variant runner, but the final 240² selftest never reached 29/29
(best 28/29); the JSON `features` addition validated syntactically but its
selftest failed and its uitest timed out. Both owned files were therefore
restored byte-for-byte from their MAPSMALL01 backups. Nothing was faked green
and no assertion was weakened. The blocker is a builder-trapping visual
footprint plus the build step's fixed 25 s window, not the search-ring radius
CFG-02 inferred.
