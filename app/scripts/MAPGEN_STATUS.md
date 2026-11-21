# MAPGEN_STATUS — audit note (worker agentQ, 2026-11-21)

Scope: `app/scripts/mapgen.gd` (`class_name C3MapGen`) and
`app/scripts/pattern_gen.gd` (`class_name C3PatternGen`) only.

## Liveness: BOTH ARE LIVE (not dead / legacy code)

Grep for `C3MapGen|C3PatternGen|mapgen|pattern_gen` across `app/scripts`
found live call sites in `game.gd`:

- `game.gd:440` — `C3PatternGen.build(MAP_W, MAP_H, int(Data.RANDOM_SEED),
  map_starts, terrain, 3, str(Data.BIOME))` inside `_gen_patterns()`.
- `game.gd:536` — `C3MapGen.build(str(Data.MAP_TYPE), int(Data.RANDOM_SEED),
  MAP_W, MAP_H, TILE, str(Data.QUALITY))` inside `_gen_base()`.
- `game.gd:564`, `game.gd:578` — `C3MapGen.WATER_SHORE` / `C3MapGen.WATER_DEEP`
  constants used for terrain typing in `_gen_base()`.

`_gen_base()` + `_gen_patterns()` are invoked by `game.gd::_generate_map()`,
so both helpers run on every map generation. The task's "may be legacy" hint
(GUIDE4 says generation lives in `_generate_map`) is only half right: the
orchestration lives in `game.gd`, but the height/forest field and the stamped
pattern descriptors come from these two classes. Do NOT delete or rewrite.

Other hits are comments/tools only (`export_donor_patterns.py`,
`donor_gen.py`, `test_drive.py`, `main.gd:252` comment).

## GUIDE4 L3 check (clustering / paint-then-clear / claims)

L3's actual clustering, paint-then-clear ordering and `cluster_zones` claims
live in `game.gd` (agentA's file), not in these helpers. These two are pure
data providers and do not paint terrain, clear trees, or call `_claim_cluster`:

- `pattern_gen.gd` enforces discrete, non-overlapping clusters with a global
  `occupied` footprint grid (the donor's `_misc_CheckStandPattern` /
  `gPatternMask` test) plus elliptical keep-clear zones at each start
  (CIRCLE1 inner army, CIRCLE2 mid gap). This satisfies L3's "clumps with
  gaps, never merged" intent and is stricter than game.gd's margin claims.
- `mapgen.gd` reproduces the donor RGB heightmask sampling and 3 coastal
  smoothing passes (1/2 for low/medium quality). No terrain painting here.
- `game.gd::_gen_patterns()` consumes the stamps and does the paint/c clear
  in the load-bearing order (add resource -> paint -> clear trees), so the
  paint-then-clear rule is upheld downstream, not violated here.

No L3 defect found inside these two files that warrants a code change.

## Hang-risk audit

- No `quit()` call and no `_initialize()` method in either file (both are
  `RefCounted` static helper classes). The protocol's `quit()`-in-`_initialize()`
  hang pattern does NOT apply.
- FIXED (mapgen.gd): `C3MapGen.build()` originally recursed without bound on a
  missing mask (`return build("land", seed + 1, ...)`). With a missing asset
  this never terminates (endless reload / stack overflow). Added an optional
  `depth` parameter with a flat-map fallback: retry "land" at most 4 times and
  return a flat empty map instead of recursing forever. Normal-path output is
  unchanged because all mask files are present (manifest + land/*.png exist).
  Backup: `inbox/backup/mapgen.gd.bak-agentQ`.

## Open questions (documented, not changed)

- `pattern_gen.gd:240-245`: the CIRCLE2 keep-clear mark is inside the
  per-start `for si` loop but marks ALL starts. For multi-start maps this makes
  later starts' near-start resource stamps avoid the larger CIRCLE2 zone while
  earlier starts do not (asymmetric starting resources). Moving the CIRCLE2
  mark to a separate loop after all per-start stamping would make it
  symmetric, but it changes deterministic stamp placement (and thus rng draw
  counts), so it is left for agentA/QA ownership to decide.
- Hardcoded TILE=2.0 in `pattern_gen.gd:58` (`svv.x / 2.0`) matches
  `Data.TILE_M := 2.0`; if TILE_M ever changes this line must follow.
- `stamp_family()` uses `rng.randi_range(2, map_w - 3)`; on a tiny map
  (map_w < 6) this is an inverted range. Current maps are 160x160, so safe.

## Verification (runner jobs)

- `agentQ-selftest` (ticket 33) actually executed: START (waited 286.72s),
  END failed after 27.19s run. The failure is NOT from this change:
  `app/selftest.json` = 28/29 steps passed, sole failure `farm_cap`
  ("farm 500 -> 500 -> 500") — a pre-existing game.gd defect owned by agentA.
  No crash / parser error from the edited mapgen.gd.
- `agentQ-uitest` (ticket 48) and `agentQ-uitest2` (ticket 84) were both
  SKIPPED by the runner, not run: `ticket ... was skipped (serving=...)`.
  Root cause is a runner bug, not this code: `godot_runner.py:290` treats any
  ticket older than `STALE_SEC`=300s as a dead holder and unwedge advances
  `serving` past legitimately-waiting tickets. With 30-48 jobs pending and
  waits of ~300-1200s, queued jobs reliably get reclaimed before their turn.
- A post-change uitest run by another worker did complete: `app/uitest.json`
  mtime 07:45:59 (after the 07:17:03 mapgen.gd edit) reports passed=True,
  17/17 steps. Combined with the fact that the edited code path only triggers
  on a MISSING mask (all mask files present), normal output is unchanged.
- Open question for coordinator/QA: fix the runner STALE_SEC reclaim so queued
  jobs are not skipped (affects the whole swarm, not just this ticket).
