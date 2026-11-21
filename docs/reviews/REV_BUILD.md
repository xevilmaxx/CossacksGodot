---
title: REV-3 — independent build-lane diff review
reviewer: REV-3 (read-only desk)
date: 2026-11-21
scope: post-re-scope working tree (D-12 skirmish charter)
status: complete
---

# 🔍 REV-3 — Build lane review

Read-only review. **No Godot runs, no code edits.** Exactly one output file: this
report. Baseline: `git status --short`, `git diff --stat` (59 tracked files,
+1125/−313) plus direct reads of untracked runner files. Gate template from
`docs/COMMANDS.md` §10; gates from `SWARM_OPS.md` §3; decisions from
`docs/DECISION_LOG.md`. Earlier M review (`REVIEW_REPORT.md`) is a prior snapshot;
several of its BLOCKs are now resolved (see Protocol health).

## Verdict counts

| APPROVE | WARN | BLOCK |
|---|---|---|
| **5** | **5** | **0** |

No merge-blocking protocol violation found in the ten highest-risk files.

## 10-column gate table (COMMANDS §10)

| Ticket | Owner | Owned files | Owned-only? | Backup present? | Diff within scope? | Shared symbols renamed? | Godot direct-call grep | Verdict | Evidence |
|---|---|---|---|---|---|---|---|---|---|
| A-01 / P-01–03 (+ P-23/P-24 work) | A | game.gd, selftest.gd, data.gd | Y — `git status` shows only A-owned files | `inbox/backup/game.gd.bak-agentA`, `data.gd.bak-agentA` ✓ | **N** — `game.gd:79-95,192-197,2026,2116-2152,2223,3187-3225,3288,3538-3546` adds whole combat tree + build-site rule; `data.gd:175,187,644-687,819-868` adds nations/units/upgrades. Beyond "fix build step" (gate 6) | N — `effective_damage` gains optional `e: Dictionary = {}` (game.gd:2223); single caller updated (game.gd:3225); backward compatible | 0 hits | **WARN** | `git diff -- app/scripts/game.gd app/scripts/data.gd` |
| A-01 (data.gd portion) | A | data.gd | Y | `data.gd.bak-agentA` ✓ | **N** — P-23 combat upgrades (19 rows) + P-24 Scotland/bagpiper/cossack variants, not A-01 | N | 0 hits | **WARN** | `data.gd:175,187,644-687,819-868` |
| P-09 | AB | world.gd, rotor assets, `_mill_tmp/**` | Y — board row P-09 | `world.gd.bak-agentAB` ✓ | Y — `world.gd:69-77,351-371,840-843,1124-1125` is mill rotor only | N | 0 hits | **APPROVE** | `git diff -- app/scripts/world.gd`; `_mill_tmp` gone, `mill_rotor.png` derived bake only |
| G-01 (+ P-18 teams) | G | ai.gd | Y — board row G-01 | `ai.gd.bak-agentG` ✓ | Y — `ai.gd:258,363-376,403-411,421-430,439,472-484` = placement, chat spam, stale raid, multi-enemy waves | N — `_is_enemy` is new, no rename | 0 hits | **APPROVE** | `git diff -- app/scripts/ai.gd` |
| B-01 (+ P-12/P-15) | B | main.gd, scan_map.py, scans/** | Y — `git status` | `main.gd.bak-agentB`, `.bak-agentB2` ✓ | WARN — `main.gd:119,133-136,664-670,1065,1091-1095` = `--seed random` (P-15), `chop`→`workwood` (P-12), `_candidate_paths` (B-01). 3 tickets in one file | N | 0 hits | **WARN** | `git diff -- app/scripts/main.gd` |
| H-01 (+ P-18 rows) | H / G? | menu.gd, scenes/** | WARN — board gives menu.gd to H-01 and to unassigned P-18; **two backups** (`bak-agentH`, `bak-agentG`) imply two writers | `menu.gd.bak-agentH`, `menu.gd.bak-agentG` ✓ | WARN — `menu.gd:15,29,348-393,409-415` mixes seed UI (H-01) with Opponents/Teams + cfg emit (P-18) | N | 0 hits | **WARN** | `git diff -- app/scripts/menu.gd` |
| Q-01 | Q | mapgen.gd, pattern_gen.gd, MAPGEN_STATUS.md | Y — board row Q-01 | `mapgen.gd.bak-agentQ` ✓ | Y — `mapgen.gd:110-141` bounds mask recursion (liveness fix) | N — `build()` gains optional `depth: int = 0`; callers at `game.gd:443,539` unaffected | 0 hits | **APPROVE** | `git diff -- app/scripts/mapgen.gd` |
| C-01 / P-26 | C/C2, SE | anim index.json, docs | WARN — C-01, P-26 and P-34 all name `anim index.json`; two backups present | `index.json.bak-agentC2`, `index.json.bak-agentSE` ✓ | Y (values) — eight `walk.duration` 0.667→1.08 (lines 7,4538,4865,5192,5519,5846,6173,6500); board C-01 note still says "1-field diff" (stale) | N | 0 hits | **WARN** | `git diff -- app/assets/models/anim/index.json` |
| D-16 / D-14 | Coordinator | godot_runner.py (new) | Y — coordinator tool | N/A (new file) | Y — all four D-16/D-14 fixes present and correct (below) | N | runner is the sanctioned launcher only | **APPROVE** | read of `app/tools/godot_runner.py` |
| Z-01 / D-13 | Z | assert_clean.py (new), CLEAN_GATE.md | Y — board row Z-01 | N/A (new file) | Y — read-only gate, `failed` excluded (D-13), `acknowledged` honoured (D-14) | N | 0 hits | **APPROVE** | read of `app/tools/assert_clean.py` |

## Per-file / ticket verdict and action

| File / ticket | Verdict | Evidence | Required action |
|---|---|---|---|
| `app/scripts/game.gd` — A-01 + combat tree | **WARN** | Owned file, backup ✓, tabs ✓ (`git diff --check` clean), gate 4 green. But A-01 is scoped to the `build` step; hunk at `game.gd:2116-2152` implements 19 P-23 upgrades and `:79-95` a build-site rule — gate 6 scope creep. | Coordinator: split P-23/P-24 out of A-01 or re-scope A-01; no code change needed for merge safety. Confirm `_blocked_for` fix is A's intended `build` repair, not D's reported-but-unowned defect. |
| `app/scripts/data.gd` — A | **WARN** | `data.gd:175,187,644-687,819-868` adds Scotland + 4 unit rows + 19 upgrades (P-23/P-24), outside A-01. Shared table keys only appended, no renames. | Same re-scope as game.gd; update board P-23/P-24 from INTAKE to attributed work. |
| `app/scripts/world.gd` — P-09 | **APPROVE** | Rotor-only diff, `world.gd.bak-agentAB` present; M's earlier missing-backup BLOCK and gate-5 `_mill_tmp` exposure are resolved (`_mill_tmp` deleted from tree). Derived bake `mill_rotor.png` stays private-use (D-07/§3 gate 5). | None. |
| `app/scripts/ai.gd` — G-01 | **APPROVE** | All hunks map to AI audit (placement, chat spam, stuck raid ids, multi-enemy waves) and P-18 teams; `ai.gd.bak-agentG` present. | None. Note QA O still needs a CLI soak after merge. |
| `app/scripts/main.gd` — B-01 | **WARN** | `--seed random` and `chop` fix are P-15/P-12 work riding on B-01; both tickets show unassigned/BLOCKED on the board. Signature/field additions are backward compatible. | Update board P-12/P-15 (B is sole owner of main.gd while B-01 open); no rollback needed. |
| `app/scripts/menu.gd` — H-01 + P-18 | **WARN** | Two worker backups (`agentH`, `agentG`) for one file; board lists menu.gd under H-01 **and** unassigned P-18 → gate 2 ambiguity. UI additions are new rows/widgets, no renames; tabs ✓. | Coordinator to name one owner for the Opponents/Teams rows and fix the board's owned-files cell. Verify uitest 17/17 after layout shift (currently green). |
| `app/scripts/mapgen.gd` — Q-01 | **APPROVE** | Bounded recursion prevents the missing-mask infinite loop (D-01 orphan class); `depth` param is optional, callers unchanged; `mapgen.gd.bak-agentQ` ✓. | None. |
| `app/assets/models/anim/index.json` — C-01/P-26 | **WARN** | Eight identical 0.667→1.08 walk fixes = P-26; backups from C2 and SE present, but P-34 also owns this file. Board C-01 "1-field diff" note is stale. | Coordinator to state that P-26 covers all eight keys and update C-01/P-34 ownership note. |
| `app/tools/godot_runner.py` — D-16 | **APPROVE** | Verified below; all four fixes present. | None (cosmetic: one mojibake `?` in a comment around `wait_for_turn`). |
| `app/tools/assert_clean.py` — D-13/D-14 | **APPROVE** | `FAILURE_STATUSES = {"timed-out","error","skipped"}` (D-13 ✓); `check_history()` skips `acknowledged` entries (D-14 ✓); no writes/kills. | None. |

## D-16 runner-fix verification (all present, correct)

| Fix | Location | Result |
|---|---|---|
| Advance-before-cleanup | `cmd_run` `finally`: `release_godot_lock()` → `advance_serving(ticket)` → unlink retry loop → `record(result)` | ✅ `now_serving` cannot be pinned by a `PermissionError` on job-file unlink |
| PID-based dead-holder reclaim | `wait_for_turn`: `dead_holder = holder is None or not pid_alive(holder_pid)`; reclaim only on `dead_holder or (lock_stale and not lock_free)` | ✅ age alone no longer skips live waiters (the 48/84 bug); `pid_alive()` uses `tasklist`/`kill(pid,0)` |
| `unwedge` | `unwedge()` + subparser; refuses if `godot.lock` held or any Godot alive; writes `skipped` results and advances | ✅ present |
| `ack` | `cmd_ack()` + subparser; sets `acknowledged`/`ack_reason`/`ack_at` in result and `status.json` | ✅ present; consumed by `assert_clean.py` |

## Protocol health

- **D-12 skirmish charter: COMPLIANT.** No build-lane diff implements missions,
  campaigns, `.aix` triggers, DLC mission maps or network/multiplayer. The only
  mission-adjacent edit is `app/tools/build_missions.py:1,15-23,108-115` —
  portability (`COSSACKS3_DIR`, `Path`), not mission content. New `t_*.gd` tests
  contain no campaign/network strings. P-16/P-17 remain DEFERRED; `docs/DLC_INVENTORY.md`
  is documentation only (watch item, no build slot).
- **Gate 1 (single Godot):** 0 direct `godot` calls in any changed/new builder
  file. Only `godot_runner.py:359` launches it (`Popen([GODOT, ...])`);
  `pgrep`/`pkill` hits in the runner and `assert_clean.py` are process inspection.
- **Gate 2 (disjoint ownership):** 3 ambiguous files — `menu.gd` (H vs G/P-18),
  `index.json` (C/C2 vs SE vs P-34), `world.gd` (board lists D and AB, though
  current diff is AB-only). All are WARN, none BLOCK.
- **Gate 3 (backups):** present for every owned tracked file in scope. New tool
  files are N/A. M's earlier `world.gd.bak-agentD` gap is moot under AB's P-09
  ownership.
- **Gate 4 (tests):** `app/selftest.json` `"passed": true` (**29/29** steps, all
  true); `app/uitest.json` `"passed": true` (**17/17**). QA_REPORT.md's earlier
  red `farm_cap` and M's red selftest are now resolved. ⚠️ Protocol still says
  28/28 (`AGENT_PROTOCOL` §2, `COMMANDS` §9) while the suite is 29 steps — docs
  need reconciling so the gate claim stays truthful (D-15/D-26).
- **Gate 5 (no redistribution):** raw donor assets untouched; derived bakes
  (`mill_rotor.png`, naval assets) are private-use; `_mill_tmp` scratch removed
  (P-09). M's earlier gate-5 BLOCK is closed.
- **Gate 6 (minimal diffs):** the only real weakness — `game.gd`, `data.gd`,
  `main.gd`, `menu.gd` bundle several tickets. No functional defect found; all
  signatures changed only by adding optional/default parameters.
- **Clean gate (D-13/D-14):** `assert_clean.py --json` currently reports
  **DIRTY**: 1 live Godot process (a legitimately *serving* selftest job, lock
  `held_recent` at 69 s — not an orphan) and 5 unacknowledged historical
  failures in `status.json` (ticket 86 `timed-out`; 88, 90, 91, 93 `skipped`
  with "ticket N was skipped (serving=N+1)"). Likely submitter processes killed
  by short tool timeouts (`AGENT_PROTOCOL` §1b) rather than a D-16 regression,
  but QA O must `ack` resolved tickets / re-run `assert_clean.py` before release.

## Files created

- `docs/reviews/REV_BUILD.md` (this file only). No code, no Godot runs.

## Open questions

1. Which ticket owns the P-23 combat tree and P-24 nation rows now in `game.gd`/`data.gd`? A-01 must be re-scoped or the work split (gate 6).
2. `menu.gd` has backups from both agentH and agentG — who wrote the Opponents/Teams rows (P-18 is unassigned on the board)?
3. Does P-26 authorise all eight `index.json` duration edits, or must C-01's "1-field diff" note and P-34's file ownership be restated?
4. P-12/P-15 were implemented by B while B-01 owns `main.gd` — confirm board states should move to DONE.
5. Reconcile the 28-step protocol text with the 29-step suite (D-15/D-26).
6. Are the 5 unacked runner failures infra artifacts or PID-reclaim false positives? Coordinator to `ack`/reset and re-gate before O signs release.
