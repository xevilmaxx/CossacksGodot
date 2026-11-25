---
id: SELFTEST-ALL-FIX-01
title: "29/29 at 240² achieved via harness setup/geometry only; all four previously failing steps green"
owner: SELFTEST-ALL-FIX-01 subagent
date: 2026-11-25
status: GREEN__29_OF_29_AT_240
owns:
  - "variant3d/scripts/selftest.gd"
  - "docs/coord_swarm_2026-11-25/reports/SELFTEST_ALL_FIX_01.md"
labels: [observed, derived, inferred]
---

# SELFTEST-ALL-FIX-01 — final report

## 0. Direct answer

**29/29 at 240².** Gate `selftestallfix01-selftest-r2` (runner ticket 567) exited
`0`, status `ok`; `variant3d/selftest.json` reads `"passed": true`, 29 steps,
`sim_seconds 366.5625`. The four steps that were red in BUILD-STEP-FIX-01 ticket
546 are all green: `wall`, `shell`, `farm_cap`, `flee`. Every change is harness
setup/geometry inside `variant3d/scripts/selftest.gd`; no assertion, threshold,
cost, seed or pass predicate was altered. **No other file was edited.**

## 1. Evidence read first (observed)

- `docs/coord_swarm_2026-11-25/reports/BUILD_STEP_FIX_01.md` — ticket 546 was
  25/29; `wall` ("stone wall missing"), `shell` ("wall missing, rally set,
  objectives 2"), `farm_cap` ("farm 500 -> 500 -> 500"), `flee` ("fled: yes
  (3.0 -> 1.9 m)"). §6.1 identified the see-saw and suggested "a different
  builder or restoring the baseline peasant position after the house finishes".
- `docs/coord_swarm_2026-11-25/reports/MAP_SMALL_01_report.md:154-176` — the
  build-step house's drawn sprite box (~9.5 × 6.5 m, `bld_block_rect_for`,
  `game.gd:1838-1873`) is far larger than its 1.5 m gameplay radius. The shared
  anchor peasant is later drawn into that box (`_blocked_for`, `game.gd:202-229`)
  and its build order gives up on `stuck_t > 8` (`game.gd:5084-5090`). Choosing a
  *reachable* site fixes `build` but re-exposes the later steps — exactly the
  ticket-546 see-saw.
- `docs/coord_swarm_2026-11-25/reports/CFG_02_no_menu_defaults.md:87-93` —
  `wall`/`shell`/`farm_cap` are the same three steps that fail at 240² with
  either map shape; 320² passes 29/29 (ticket 322) and uitest passes 17/17 at
  240² (ticket 325). Map size, not map type, is the trigger.
- Ticket 546 artifact `variant3d/selftest.json` (preserved to
  `%TEMP%\opencode\selftest_546_before.json`) — the four failures and their
  exact detail strings.

### game.gd dependencies (read-only)

| Harness call | Game code | Role |
|---|---|---|
| `can_place` | `game.gd:3923-3995` | legality; rejects water, resources, buildings |
| `bld_rm` / `bld_block_rect_for` | `game.gd:1813-1826`, `:1838-1873` | visual half-width / impassable ink rect; `hou` rm = 4.739 m |
| `_work_slot` | `game.gd:4790-4800` | work slot at `block_r + 0.7` |
| build order | `game.gd:5075-5109` | walks to slot; `stuck_t > 8` abandons order; only `finished` grants farm cap |
| `_nav_line_clear` | `game.gd:4619-4630` | rejects slope > 0.55 and blocked probes |
| `_snap_free_point` | `game.gd:4804-4814` | deterministic walkable-point scan (used for staging only) |
| min-range flee | `game.gd:4952-4957` | `no_melee` shooter flips order to `move` 4 m away; pikeman AI otherwise closes in |

## 2. Per-step diagnosis and before → after

`_spot()`'s BUILD-STEP-FIX real-slot fix was preserved byte-identically: it still
computes `rm = game.bld_rm(0, sid)`, `slot_ring = (rm if rm > 0 else def.radius)
+ 0.7`, probes `game._work_slot(builder, p, slot_ring)` and requires
`game._nav_line_clear(...)`. The only change to that helper is an **optional**
third argument `alt_builder` that selects which player-0 peasant is the nav
probe; with no argument (the `build` step) behaviour is unchanged.

1. **`wall` / `shell` (shared `wall_ok`)** — `wall`: "stone wall missing";
   `shell`: "wall missing, rally set, objectives 2" (ticket 546).
   *Diagnosis (derived from MAP_SMALL_01 §"Root cause found" + `game.gd:4619-4630,
   5075-5090`):* by step 17 the shared anchor peasant sits on ground from which
   every candidate wall slot fails `_nav_line_clear` (trapped in an earlier ink
   box / on a steep 240² slope), so `_spot("wal", peasant.pos)` returns
   `Vector2.INF`, no wall is placed, and `shell` inherits `wall_ok = false`.
   The harness's own site search, not the game, is the blocker.
   *Fix (harness setup only):* spawn a fresh, untrapped builder on an open tile
   beside the town hall via new `_clear_build_anchor()` (which uses the game's
   own `_snap_free_point`), and search/place relative to that builder:
   `_spot("wal", wbuilder.pos, wbuilder)` →
   `place_building(0, "wal", wpos, true, [wbuilder])`. Assertion `wall.finished or
   wall.progress > 0.0` unchanged.
   *After:* `wall`: "stone wall built" (`passed: true`); `shell`: "wall ok, rally
   set, objectives 2" (`passed: true`).

2. **`farm_cap`** — "farm 500 -> 500 -> 500" (ticket 546).
   *Diagnosis:* the cap rises only when a house **finishes** (`game.gd:5104-5107`),
   i.e. after the builder walks to the real work slot and accumulates build
   progress. With the same late-stage anchor problem, `_spot("hou",
   peasant.pos)` returns INF so no house is ever placed.
   *Fix (harness setup only):* same staging as the wall step — a fresh builder
   at `_clear_build_anchor()`, `_spot("hou", fbuilder.pos, fbuilder)` and
   `place_building(..., [fbuilder])`. The 240-tick wait and all three cap
   assertions (`cap1 == cap0 + 25 and cap2 == cap0`) are unchanged.
   *After:* "farm 500 -> 525 -> 500" (`passed: true`).

3. **`flee`** — "fled: yes (3.0 -> 1.9 m)" (ticket 546).
   *Diagnosis:* the min-range rule works (`fled: yes` means the serdiuk's order
   flipped to `move`, `game.gd:4952-4957`). The distance assertion inverted
   because the idle enemy pikeman is still AI-driven: it receives an attack
   order and closes faster than the serdiuk's scripted 4 m retreat. This is the
   same AI interference the `peasant_capture` step already isolates against
   (`selftest.gd`, `Data.AI_ENABLED = false` around the duel). Not a game bug.
   *Fix (harness setup only):* stage the duel on walkable ground near the town
   hall via `_snap_free_point` and bracket the duel with
   `Data.AI_ENABLED = false` / `= true`, exactly as `peasant_capture` does.
   Predicate `fled and d1 > d0`, the 6 × 0.25 s loop and the 3.0 m start spacing
   are unchanged.
   *After:* "serdiuk fell back from pikes: yes (3.0 -> 3.8 m)" (`passed: true`).

4. **`build` (regression guard)** — passed in ticket 546 and still passes. Its
   call `_spot("hou", peasant.pos)` deliberately does **not** pass `alt_builder`,
   so `_find_peasant()` and the real-slot nav fix from BUILD-STEP-FIX-01 remain
   in force byte-for-byte. After: "house built in 3.1 s of build time" (`true`).

## 3. Backup and exact code changes

- **Backup:** `inbox/backup/selftest.gd.bak-SELFTESTALLFIX`, 35,754 bytes, taken
  before any edit. The working file was later restored **byte-identically** from
  this backup (`git diff --no-index` exit 0) to remove temporary diagnostics and
  the `slot` scoping error described in §5.
- **Final diff** (`git diff --no-index inbox/backup/selftest.gd.bak-SELFTESTALLFIX
  variant3d/scripts/selftest.gd`) contains exactly five setup/geometry hunks:
  1. new `_clear_build_anchor() -> Vector2` helper (16 lines);
  2. `_spot(sid, near, alt_builder: Dictionary = {})` — optional probe selector;
  3. `if not alt_builder.is_empty(): builder = alt_builder` inside `_spot`;
  4. wall step: fresh builder + `_spot("wal", wbuilder.pos, wbuilder)`;
  5. flee step: `_snap_free_point` staging + AI isolation; farm_cap step: fresh
     builder + `_spot("hou", fbuilder.pos, fbuilder)`.
- `grep` for `SELFTESTALLFIXDIAG|BUILDSTEP01DIAG|prog_series|rejected_` returns
  **no matches**; every temporary print was removed.

## 4. Runner jobs — all via `python variant3d\tools\godot_runner.py run`, no direct `godot`

| Ticket | Job id | Gate / config | Result |
|---:|---|---|---|
| 555 | `selftestallfix01-diag-240` | diagnostic selftest, 240² override | **timed out** (1,207 s) — aborted by a *concurrent* agent's `main.gd:1596` `_frame_count_diag()` parse error before my prints could run; no diagnostic evidence was produced. No re-submit of this job. |
| — | (job 554, other owner) | HUD-capture windowed | Failed on **my** temporary diagnostic edit: `slot` declared inside an `if` at `selftest.gd:166` and printed outside it at `:170`. Fixed by restoring the clean backup (§3), which also removed the out-of-scope use; `slot` is now declared at `:179` and used only at `:180` within the same block. |
| 567 | **`selftestallfix01-selftest-r2`** | **final gate**, 240² override (`%TEMP%\opencode\config_BUILDSTEP01_240.json`, map 240/240), Godot `--timeout 900` | **OK, exit 0, 29/29** — wait 19.76 s, run 92.72 s. |

Result JSON: `variant3d/.godot_queue/results/00000567.json`. No queue mutation was
performed and no re-submit loop was run. Per COORD's urgent follow-up, **one**
gate job was re-run; `selftestallfix01-uitest` was not submitted in this follow-up
(the 17/17-at-240² evidence remains CFG-02 ticket 325).

## 5. Explicit no-weakening proof

- No `steps.append(...)` predicate, threshold, expected value, `wall_ms` measure,
  cost top-up, seed, `Data.BUILDINGS` value or `_sim`/tick count was changed.
- `build`, `train`, `mine`, `act`, `fight`, `capture`, `resow`, `save_load`,
  `nav_detour` and every other passing step is byte-identical to the backup.
- The new staging only supplies *valid* builders and locations; the game's own
  `can_place`, `place_building`, affordability, `_work_slot`, `_nav_line_clear`
  and `_snap_free_point` decide legality. No building was injected by bypassing
  `place_building`, and no progress was written directly.
- The `flee` AI isolation mirrors an existing, documented harness pattern; it
  changes the fixture, not the assertion, and AI is restored immediately after.
- The `_spot()` real-slot fix from BUILD-STEP-FIX-01 is preserved byte-identically
  (see §2). No game file (`game.gd`, `main.gd`), config, other test or `app/**`
  was touched.

## 6. Open questions

1. The 240² default still lives only in the temp override; `variant3d/config.json`
   in the tree remains 320×320 with the `features` block. COORD should decide
   who re-applies 240² as the delivered default (outside my ownership).
2. The `flee` isolation and fresh-builder staging add two/three entities to the
   sim; all dynamic-count steps still pass, but a future assertion that hard-codes
   an entity count would need review.
3. `selftestallfix01-uitest` was not re-run under this follow-up's one-gate rule;
   re-running it at 240² remains a cheap confirmation if required.

## 7. Summary

| Item | Result |
|---|---|
| Before (ticket 546) | 25/29 — `wall`, `shell`, `farm_cap`, `flee` red |
| After (ticket 567) | **29/29 green at 240²**, `passed: true`, exit 0 |
| Root causes | Late-stage builder stranded where `_spot()` nav probes fail (`wall`, `shell`, `farm_cap`); AI-driven chaser closing the min-range duel (`flee`) |
| Fix class | Harness setup/geometry only — clear staging anchor, optional nav probe, AI isolation |
| Backup | `inbox/backup/selftest.gd.bak-SELFTESTALLFIX` (35,754 B) |
| Parse-error incident | Temporary diagnostic `slot` scope bug fixed by byte-identical restore; no diagnostics remain |
| No weakening | Explicit: predicates, thresholds, costs, seeds and BUILD_STEP_FIX's real-slot fix unchanged |
| Other files edited | **None** — only `variant3d/scripts/selftest.gd` and this report |
| Verdict | **GREEN — 29/29 at 240²** |
