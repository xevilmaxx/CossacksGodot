---
id: BUILD-STEP-FIX-01
title: "Exact root cause of the 240² `build` failure found; harness fix makes `build` pass, but the full gate is still RED (25/29) — BLOCKED"
owner: BUILD-STEP-FIX-01 subagent
date: 2026-11-25
status: BLOCKED__BUILD_STEP_GREEN__GATE_NOT_GREEN
owns:
  - "variant3d/scripts/selftest.gd"
  - "docs/coord_swarm_2026-11-25/reports/BUILD_STEP_FIX_01.md"
labels: [observed, derived, inferred]
---

# BUILD-STEP-FIX-01 — status report (honest, no further probes)

## 0. Direct answers to COORD's four questions

1. **Yes — the exact root cause of the `build` failure at 240² was identified with evidence**, not guessed (§2).
2. **Yes — one code edit was made, to `selftest.gd` only**; backup and all runner job ids are in §3–§4. No assertion was weakened.
3. **The gate is still RED.** At 240² the `build` step now **passes** (`selftest.json` step `build`, `passed: true`), but the integrated artifact from ticket 546 is **25/29**: `wall`, `shell`, `farm_cap`, `flee` fail. This is **not** 29/29.
4. **Blocker:** the minimal harness fix moves the house site enough to make `build` finish, but the same site-selection change leaves the later `wall`/`shell`/`farm_cap` steps red, and `flee` regressed in the same run. Those are additional harness-layout interactions inside my owned file, but well beyond the "minimal harness geometry" scope of this ticket, and COORD instructed me to stop probing rather than loop. `uitest` was **not run** (no re-submit loop; stopped on the status ping). The queue was busy (FIFO waits 160–645 s) but every submitted job executed; no job was lost to queue mutation.

---

## 1. Starting state read (observed)

- `variant3d/config.json`: when this ticket started the worktree had been reverted to `map_width_tiles`/`map_height_tiles` = **320** (`config.json:41-42` then; currently `:80-81`), with a concurrent agent re-adding the `features` block at `:16`. HEAD commit `83b77eaa` captured the MAP-SMALL-01 revert (config 320, `selftest.gd` back to the fixed 6–24 m ring).
- The integrated `variant3d/selftest.json` still read 28/29 with `build` failing (`"house built in 3.1 s of build time (cost 120 wood)"`, `passed: false`), matching QA-PARITY-01 §3.2 and FINAL_CHECKLIST C-1.
- The 28/29 artifact was produced with MAP-SMALL-01's **scaled + filtered** `_spot()`, which is present in history at `git show d1fb9e58:variant3d/scripts/selftest.gd` and differs from the reverted worktree only in `_spot()`. I restored that version as the correct baseline for this ticket (still my owned file).
- To test 240² **without editing `config.json`** (explicitly forbidden by the ticket), I used `main.gd:1307-1309 --config <path>` with a full copy of `config.json` carrying 240/240, written outside the repo at `%TEMP%\opencode\config_BUILDSTEP01_240.json` (`config.gd:273-293` merges the extra file over the base). All 240² jobs below used this override; no repo config file was edited by me.

## 2. Root cause — exact failing assertion (observed + derived)

The failing assertion is `selftest.gd` build step: `built = house.finished` after the fixed `_sim(25.0)` (`selftest.gd:257-267` in the pre-edit numbering; unchanged by my edit). It is **not** a cost/resource problem and **not** a too-small search ring:

- **Not cost/resources:** the step tops up wood by 500 (`selftest.gd:223`); `place_building` would return `{}` on affordability (`game.gd:3932-3935`) and the detail would read `0.0`. The artifact detail reads `3.1 s` = `Data.BUILDINGS.hou.build_time`, so the house **was** placed and paid for.
- **Not ring size / terrain blocking:** the decisive diagnostic (job 539) showed `_spot("hou", …)` returning a **near** site at `r = 6.0 m`: `near=(396.41, 64.17)`, `p=(399.30, 58.91)`, with `can_place` OK. So a legal, close tile existed.

The actual cause is a **harness radius mismatch** in MAP-SMALL-01's reachability filter:

- The build order walks to `slot = _work_slot(e, site.pos, site.block_r + 0.7)` (`game.gd:4949`).
- For sprite-drawn buildings `block_r = bld_rm(...)`, the **visual** half-width (`game.gd:1707-1712`); measured `rm = 4.739 m` for `hou`, **not** the 1.5 m gameplay radius. `_work_slot` (`game.gd:4657-4667`) therefore put the real work slot ~5.44 m from the site centre, while the harness checked `_nav_line_clear` at `def.radius + 0.7 = 2.2 m` (`selftest.gd:159-165` of the baseline).
- Diagnostic job 539, sampling `house.progress` every 1 s for the 25 s window, returned:
  `progress=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,53,53,107,161]`, end `progress=1.6171875` of `build_time=3.125`, `finished=false`, order still `build`, `stuck=0`.
  i.e. work began only at ~21 s and reached ~52 % when the fixed window expired. The un-blocked peasant had walked from `(396.41,64.17)` to `(396.32,53.64)` (~10.5 m) — a long detour to the *real* slot that the harness's wrong-radius nav check never tested.

Conclusion: a harness geometry/reachability bug, not a game bug. No game logic needed changing.

## 3. Backup and the one code edit (observed)

- **Backup:** `inbox/backup/selftest.gd.bak-BUILDSTEP01`, 34,094 bytes, copied before any edit from the then-current `variant3d/scripts/selftest.gd`.
- **Only code change:** `_spot()` in `variant3d/scripts/selftest.gd`. Before → after is exactly the diff shown by `git diff --no-index inbox/backup/selftest.gd.bak-BUILDSTEP01 variant3d/scripts/selftest.gd` (one hunk):
  - keeps the map-scaled ring (`span_m = min(MAP_W,MAP_H) * Data.TILE_M`, outer `0.25 * span_m`, step `max(6, 0.0125 * span_m)`), `can_place` legality, the ink-clear filter, 32-point angular sampling, and `return Vector2.INF` on failure;
  - **fixes** the reachability probe to use the same radius and slot the build order uses: `rm = game.bld_rm(0, sid)`, `slot_ring = (rm if rm > 0 else def.radius) + 0.7`, then `game._work_slot(builder, p, slot_ring)` and `game._nav_line_clear(builder, builder.pos, slot)`.
- All temporary `BUILDSTEP01DIAG` prints were removed before the final gate; `grep` for `BUILDSTEP01DIAG|prog_series|rejected_` in `selftest.gd` returns **no matches**. The build step itself is byte-for-byte unchanged from the backup (no `_sim(25.0)` change, no threshold, no assertion).
- **No other file edited.** In particular: `config.json`, `game.gd`, all tests other than `selftest.gd`, and `app/**` were not touched. `variant3d/selftest.json` was regenerated by the runner only. The temp 240² config lives outside the repo in the approved `%TEMP%\opencode` directory.

## 4. Runner jobs — all via `python variant3d\tools\godot_runner.py run` (no direct `godot`)

| Ticket | Job id | Purpose | Result |
|---:|---|---|---|
| 511 | `buildstep01-diag-240` | first diagnostic | failed at startup: my `slot` scoping parse error (`selftest.gd:153`) **plus** a concurrent agent's `hud.gd:496` parse error. Both fixed by their owners; I did not touch `hud.gd`. |
| 516 | `buildstep01-diag-240-r2` | diagnostic retry | timed out on Godot's own 120 s watchdog (`main.gd:209`: hard_limit default 120); no `--timeout` was passed to Godot. |
| 523 | `buildstep01-diag-240-r3` | build-only diagnostic | same Godot-side watchdog timeout. |
| 528 | `buildstep01-diag-240-r4` | build-only, Godot `--timeout 600` | failed as expected; produced `_spot()` site data; my `%v`/Rect2 print format error is visible in stderr. |
| 539 | `buildstep01-diag-240-r5` | decisive diagnostic | failed as expected; produced the progress series and `rm=4.739`, `block_r=4.739`, real slot `(396.04,53.71)` quoted in §2. |
| 546 | **`buildstep01-selftest`** | **final 240² gate**, `--config` temp 240, `--timeout 900` to Godot | **FAILED, 25/29** — wait 160.68 s, run 278.88 s, exit 1. |
| — | `buildstep01-uitest` | **not submitted** | stopped on COORD's status ping; no re-submit loop. |

Result JSON: `variant3d/.godot_queue/results/00000546.json`. Fresh `variant3d/selftest.json` from ticket 546: `"passed": false`, 29 steps, `sim_seconds 323.3125`.

### Final 240² step state (ticket 546)

- **`build`: PASSED** — `{"detail": "house built in 3.1 s of build time (cost 120 wood)", "passed": true, "step": "build"}`. Before → after: **red → green** at 240².
- Still failing: `wall` ("stone wall missing"), `shell` ("wall missing, rally set, objectives 2"), `farm_cap` ("farm 500 -> 500 -> 500"), `flee` ("serdiuk fell back from pikes: yes (3.0 -> 1.9 m)").
- Therefore the integrated selftest gate is **NOT green**; per `main.gd:2032` a 25/29 report means exit 1, which job 546 confirms.

## 5. No weakening — explicit statement

No pass criterion, assertion, expected value, threshold, or `build_time`/cost constant was changed. The `build` step still calls `place_building` and still requires `house.finished` after exactly `_sim(25.0)`; the detail string is unchanged. The `_spot()` change makes the site probe **more accurate** (it validates the real work slot) and keeps every earlier legality filter; it does not bypass the game's `can_place` or affordability rules. No seed was gamed and no test was deleted.

## 6. Open questions / why BLOCKED

1. Selecting a site with a clear path to the *real* house slot fixes `build` but re-exposes the later `wall`/`shell`/`farm_cap` failures (MAP-SMALL-01 §"Root cause found" documented this same see-saw). A follow-up owner with a wider `selftest.gd` scope would need to choose a house site that is simultaneously quick to reach **and** clear of the anchor peasant's later path — e.g. by using a different builder or restoring the baseline peasant position after the house finishes. I did not attempt this: it exceeds "minimal harness geometry" and COORD asked me to stop.
2. `flee` failing while reporting `fled: yes` (`d1=1.9 < d0=3.0`) appeared only in the final run; it may be an order interaction with the new house site or unrelated churn. Not isolated here — **UNVERIFIED**.
3. `buildstep01-uitest` was not run; the 17/17-at-240 claim remains CFG-02 ticket 325 / QA-PARITY's integrated artifact, not re-proved by me.
4. `config.json` in the tree is currently 320/320 with a `features` block; the 240² "default" exists only in HEAD history (`d1fb9e58`) and in my temp validation override. COORD should decide who re-applies 240² and re-runs the gates once the remaining steps are fixed.
5. Queue waits of 160–645 s were normal FIFO behaviour. Two concurrent-edit incidents were observed and left untouched: the transient `hud.gd:496` parse error (job 511) and a rotating in-flight job set; no queue state was mutated by me.

## 7. Summary

| Item | Result |
|---|---|
| Root cause of `build` failure | Harness checked `_nav_line_clear` at `def.radius+0.7 = 2.2 m`; build order actually walks to `bld_block_r/bld_rm + 0.7 = 5.44 m` (`game.gd:4949`, `game.gd:1707-1712`). Detour consumed ~21 s; at t=25 s progress was 1.617/3.125 (~52 %). |
| Code edited | `variant3d/scripts/selftest.gd` only — `_spot()` reachability radius/slot; diagnostics removed. |
| Backup | `inbox/backup/selftest.gd.bak-BUILDSTEP01` (34,094 B). |
| `build` step at 240² | **RED → GREEN** (ticket 546). |
| Integrated 240² selftest gate | **STILL RED — 25/29** (`wall`, `shell`, `farm_cap`, `flee`). |
| `buildstep01-uitest` | Not submitted (stopped on COORD ping). |
| No weakening | Asserted explicitly: no pass criterion, threshold, assertion, cost or seed changed. |
| Verdict | **BLOCKED** — root cause identified and the named step fixed; the full gate needs a wider-scope follow-up, not another probe loop from this ticket. |
