---
id: MAPSIZE-01
owner: MAPSIZE-01 subagent (small implementation builder)
date: 2026-11-25
status: reverted-after-gate-failure
scope: "Only variant3d/scripts/menu.gd (value-only) and this report. Donor READ-ONLY. Validation via variant3d/tools/godot_runner.py only."
---

# MAPSIZE-01 — donor skirmish map sizes in `menu.gd`

## Outcome

**Change attempted, then reverted.** Both mandated gates failed (runner
`END failed`, exit 1, no report written by either job). Per the task rule
*"If any step fails, revert from backup and report the exact failing step with
evidence — do not weaken a test or game the seed"*, `variant3d/scripts/menu.gd`
is restored byte-identically from `inbox/backup/menu.gd.bak-MAPSIZE01`.

## 1. Donor citations (re-read directly, READ-ONLY)

`C:\Games\Cossacks 3\data\gui\menu.inc\donewgame.inc:42-49` — active
`[*] = ;` script:

| stored `mapsize` | `genMapSize` | line |
|---:|---:|---|
| 0 | 320 | `:43` |
| 1 | 480 | `:44` |
| 2 | 640 | `:45` |
| 3 | **256 (Tiny)** | `:46` |
| else | 320 | `:47-48` |

GUI order is Tiny(3), Normal(0), Large(1), Huge(2) —
`showcustomgame.inc:243-246`; default combo index 1 → Normal 320
(`showcustomgame.inc:247`). Port dropdown before this task:
`menu.gd:726` = `240 / 320 / 400 / 480` (labels Tiny / Normal / Large 2x /
Huge 4x), which matches neither donor set — see
`DMAPGEN_01_skirmish_options.md:59-75,311-312`.

## 2. Backup

`inbox/backup/menu.gd.bak-MAPSIZE01` — 41,609 bytes, created before any edit
from the pre-change `variant3d/scripts/menu.gd`.

## 3. Before → after (attempted)

`variant3d/scripts/menu.gd`, two sites, value + citation comment only:

| Site | Before | After (tested) | Final (reverted) |
|---|---|---|---|
| `:60` default | `var map_size := 240          # CFG-01: Tiny, the smallest port skirmish size option` | `var map_size := 256          # MAPSIZE-01: donor Tiny (donewgame.inc:42-49)` | 240 / CFG-01 comment |
| `:723-726` Map size row | comment `Tiny=240, Normal=320, Large 2x=400, Huge 4x=480`; ids `240 / 320 / 400 / 480` | comment `MAPSIZE-01: donor values 256/320/480/640 (donewgame.inc:42-49); GUI order ... (showcustomgame.inc:243-246)`; ids `256 / 320 / 480 / 640` | original comment and ids |

Labels (`Tiny`, `Normal`, `Large 2x`, `Huge 4x`), row order, and every other
option on `:723-735` were left byte-identical. `git diff --no-index` against
the backup showed exactly the two hunks above and nothing else. 256 is donor
Tiny and is smaller than the 320 baseline the owner wanted changed.

## 4. Validation — variant runner only

No `godot` binary was invoked directly; no test or seed was touched.

| Ticket | Job id | Gate | Result |
|---:|---|---|---|
| 455 | `mapsize01-selftest` | `--headless --path variant3d -- --self-test variant3d/selftest.json` (timeout 300) | **END failed**, exit 1; waited 1682.65 s, ran 38.38 s |
| 482 | `mapsize01-uitest` | `--headless --path variant3d -- --ui-test variant3d/uitest.json` (timeout 240) | **END failed**, exit 1; waited 96.51 s, ran 35.42 s |

Evidence: `variant3d/.godot_queue/results/00000455.json`,
`00000482.json`, and their `<ticket>_<id>/stdout.txt` + `stderr.txt`.
Both jobs' stdout contains only the engine banner
(`Godot Engine v4.7.2.stable.official.ed1daf0bf ...`, 75 bytes) and stderr is
empty — neither job reached its test body and neither wrote a report:
`variant3d/selftest.json` has mtime 10:57:24 and `variant3d/uitest.json` 10:51:54,
both **before** these jobs finished (11:21:28 / 11:24:28). The stale
`uitest.json` reads `passed: true`, 17/17, but it is not from job 482.

**Exact failing step with evidence.** The pre-gate selftest snapshot (taken
before my edit, copied to `%TEMP%\opencode\selftest.json.before-mapsize01`)
reads `passed: false`, 28/29, with exactly one failure:

```
{'detail': 'house built in 3.1 s of build time (cost 120 wood)',
 'passed': False, 'step': 'build', 'wall_ms': 506}
```

That `build` failure is pre-existing and unrelated to this change: selftest /
uitest take the no-menu path (`main.gd:230-231` → `_setup_full_game()`), while
`menu.gd` values are applied only on the interactive menu path
(`main.gd:253-256` → `_apply_menu_cfg()`). Concurrent jobs in the same window
failed the same way — ticket 461 `mapsmall01-selftest-240-r7` (exit 1, banner
only), 481 `minimapquad01-boot2` (exit 1), 485 `mapsmall01-json-selftest`
(exit 1) — while unrelated `--check-only` jobs succeeded. The gates were not
green in this working tree regardless of my two-line value edit.

## 5. Revert status

* `variant3d/scripts/menu.gd` restored from backup;
  `git diff --no-index backup working` exits 0 (byte-identical).
* **Caveat (transient, now resolved):** a concurrent auto-commit by another
  agent — `49aa81f7` "step", 2026-11-25 10:55:05 +0100 — captured my edited
  file into HEAD *before* the gates ran, so for a short window HEAD held
  256/320/480/640 while the working tree was back at 240. A later auto-commit
  by the same external process — `d1fb9e58` "step", 11:30:13 +0100 — picked up
  the revert. Final HEAD content is again `map_size := 240` and ids
  `240/320/400/480`, and `git status` shows no change to `menu.gd`. I did not
  commit, stage, or rewrite history; the owner should still be aware that the
  change was briefly present in HEAD.
* Gate jobs wrote runner artifacts under `variant3d/.godot_queue/results/`;
  these are runner output, not hand edits.

## 6. Files touched

* Edited then restored: `variant3d/scripts/menu.gd` — **no net working-tree change**.
* Created: `inbox/backup/menu.gd.bak-MAPSIZE01`, this report.
* Copied (outside repo, evidence only): `%TEMP%\opencode\selftest.json.before-mapsize01`.

**No other file was edited.** `config.json` (MAP-SMALL-01), `config.gd`,
`game.gd`, `selftest.gd`, all tests, `app/**`, `selftest.json` and
`uitest.json` were untouched by me; their working-tree differences belong to
other agents or to runner output.

## 7. Open questions

1. Why do every selftest/uitest job in the 11:21–11:24 window exit 1 with only
   the engine banner? Needs COORD / harness owner diagnosis (asset-import race
   or a concurrent in-flight script edit are candidates; not proven here).
2. `reports/MAP_SMALL_01_report.md` has not landed (SWARM_BOARD still shows
   MAP-SMALL-01 RUNNING), although `selftest.gd:128-134` already contains its
   scaled `_spot()` ring and `config.json:41-42` is 240×240. The viability of
   256 for the *interactive* skirmish path is therefore unproven by these gates.
3. If MAPSIZE-01 is retried and lands, the no-menu default (`config.json:41-42`,
   240×240) is owned by MAP-SMALL-01 and would stay at 240 unless that owner
   aligns it to 256.

## 8. Summary

Donor values are Tiny 256 / Normal 320 / Large 480 / Huge 640
(`donewgame.inc:42-49`) with GUI order Tiny, Normal, Large 2x, Huge 4x
(`showcustomgame.inc:243-246`). I backed up `menu.gd`, applied the value-only
240/320/400/480 → 256/320/480/640 change with the default set to donor Tiny
256, and ran both mandated variant-runner gates. Both failed at the runner
level (exit 1, no report written); the latest available selftest report fails
at `build` (28/29) before my edit, and other agents' gates failed in the same
window. Per the rule I reverted `menu.gd` from backup and report no delivered
change, with the caveat that a concurrent commit temporarily placed the edit
in HEAD. No test was weakened, no seed gamed, and no other file was edited.
