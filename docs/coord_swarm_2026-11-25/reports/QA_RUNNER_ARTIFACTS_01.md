---
id: QA-RUNNER-ARTIFACTS-01
title: "QA-RUNNER-ARTIFACTS-01 — audit of runner result records, failed gate window (tickets 445–490)"
date: 2026-11-25
owner: QA-RUNNER-ARTIFACTS-01 (read-only QA subagent)
session_id: ses_dedbb6505ffe0cw9EmKYeTG6zY
status: COMPLETE
scope: "Read-only audit of variant3d/.godot_queue/results/*.json, result directories, status.json history, now_serving/counter/godot.lock, and today's coordination docs. No runner-state mutation, no code/config/test edits, no report other than this file."
snapshot_status_json_mtime: "2026-11-25T11:36:38.364208"
snapshot_status_json_size_bytes: 330737
snapshot_history_entries: 489
mutation_performed: false
---

# QA-RUNNER-ARTIFACTS-01 — runner result-record audit (failed gate window)

**Label convention used throughout:** `[observed]` = read directly from a file on disk;
`[derived]` = computed/cross-referenced from observed data; `[inferred]` = best-supported
explanation, not proven; `[UNVERIFIED]` = cannot be established from available evidence.

**No mutation performed.** This audit only read files and wrote this one report. No
submit/cancel/reset/unwedge/ack, no `now_serving` or `counter` edit, no code change.

---

## 1. Sources

| # | Source | What it supplied |
|---:|---|---|
| S1 | `variant3d/.godot_queue/status.json` (`history`, 489 entries; mtime 11:36:38) | authoritative aggregate result records: ticket, id, status, exit, wait, run, timeout, ack fields |
| S2 | `variant3d/.godot_queue/results/000004*.json` (per-job result files) | per-job status, exit, wait/run, and the `error` string carrying the exact `serving=N` overtake number |
| S3 | `variant3d/.godot_queue/results/000004NN_*` directories incl. `stdout.txt`/`stderr.txt` | output-file presence/size; empty result dirs for no-record tickets |
| S4 | `variant3d/.godot_queue/now_serving` = `500`, `counter` (= next_ticket) = `503`, `godot.lock` = `500 1795603031.344`, `jobs/` = `00000500,501,502.json` | current runner position `[observed]` |
| S5 | `docs/coord_swarm_2026-11-25/SWARM_BOARD.md` (session ids, per-ticket evidence) | job→owner mapping `[derived]` from id prefix / argv vs owner grant |
| S6 | `docs/coord_swarm_2026-11-25/reports/QA_PARITY_01.md` §2, §3, §4, §7 | claimed-green baseline ids; 452/453 skip confirmation; 446/447 harness-kill incident |
| S7 | `README.md:196-203,214`, `PROGRESS.md:38-43,69,194-195`, `FINAL_GATE_PLAN_01.md:74-77`, `QA_DOCS_01.md`, `MAPSIZE_01.md:64-65`, `MAP_SMALL_01_report.md:133-145`, `FX_IMPACT_01.md:194`, `S1_INPUT_FIX.md:156`, `UITEST_ANCHOR.md:64,86`, `QA_AUDIT_01:31-57,129`, `CONFIG_WIRE_HUD.md` | additional green/failed claims to cross-check |

**Live-runner caveat `[observed]`:** during this audit the `status.json` `history` length was
read as 486 entries on first access and 489 entries on the next; the snapshot above is the
later read. Tail entries are out of order (`…491,492,493,495,496,497,494,498,499`), i.e.
ticket 494 was appended late after 497. Counts below are valid for the stated snapshot only.

---

## 2. Artifact table — tickets 445–490

`exit=null` is shown as `null`. `stdout/stderr` column reports actual file state: `N B` =
file present with N bytes; `EMPTY` = zero-byte file; `absent (dir empty)` = result directory
exists but contains neither stdout.txt nor stderr.txt. Source: `J+H` = both JSON and history;
`J only` = JSON artifact exists but no history entry; `none` = no JSON, no history, empty dir.

| Ticket | id | status | exit | wait s | run s | stdout / stderr | Source |
|---:|---|---|---:|---:|---:|---|---|
| 445 | mapsmall01-diag12-240 | failed | 1 | 346.7 | 171.6 | 1458 B / 3866 B | J+H |
| 446 | qaparity01-uitest | **NO RECORD** | — | — | — | absent (dir empty) | none |
| 447 | qaparity01-selftest | **NO RECORD** | — | — | — | absent (dir empty) | none |
| 448 | motionanim01-rotor-smoke | skipped | null | 1825.5 | 0.0 | absent (dir empty) | J+H |
| 449 | configwirer-smoke | skipped | null | 1800.2 | 0.0 | absent (dir empty) | J+H |
| 450 | weatherdriver01-smoke | skipped | null | 1773.0 | 0.0 | absent (dir empty) | J+H |
| 451 | audiosel02-smoke | skipped | null | 600.0 | 0.0 | absent (dir empty) | J+H |
| 452 | qaparity01-uitest | skipped | null | 1755.9 | 0.0 | absent (dir empty) | J+H |
| 453 | qaparity01-selftest | skipped | null | 1755.9 | 0.0 | absent (dir empty) | J+H |
| 454 | minimapquad01-boot | skipped | null | 1712.8 | 0.0 | absent (dir empty) | J only |
| 455 | mapsize01-selftest | failed | 1 | 1682.7 | 38.4 | 75 B / EMPTY | J+H |
| 456 | terraindarkfix2-p0 | skipped | null | 1638.9 | 0.0 | absent (dir empty) | J+H |
| 457 | sp06-sun-smoke | skipped | null | 1632.1 | 0.0 | absent (dir empty) | J+H |
| 458 | motionanim01-rotor-smoke-r2 | skipped | null | 1519.4 | 0.0 | absent (dir empty) | J+H |
| 459 | perf3d01-sync120 | **NO RECORD** | — | — | — | absent (dir empty) | none |
| 460 | perf3d01-dumpcfg | **NO RECORD** | — | — | — | absent (dir empty) | none |
| 461 | mapsmall01-selftest-240-r7 | failed | 1 | 1388.2 | 25.6 | 75 B / EMPTY | J+H |
| 462 | rotorasset01-import | skipped | null | 1344.9 | 0.0 | absent (dir empty) | J only |
| 463 | perf3d01-selftest | **NO RECORD** | — | — | — | absent (dir empty) | none |
| 464 | configwirer-smoke-r2 | ok | 0 | 1178.4 | 17.1 | 75 B / EMPTY | J+H |
| 465 | audiosel02-smoke | skipped | null | 1102.0 | 0.0 | absent (dir empty) | J+H |
| 466 | seasonpath01-smoke | skipped | null | 812.4 | 0.0 | absent (dir empty) | J+H |
| 467 | perf3d01-sync120b | **NO RECORD** | — | — | — | absent (dir empty) | none |
| 468 | audiosel02-drag | skipped | null | 490.1 | 0.0 | absent (dir empty) | J only |
| 469 | darkrowall-t_combo_shore_mines | skipped | null | 445.6 | 0.0 | absent (dir empty) | J+H |
| 470 | darkrowall-t_combo_trees_mines | skipped | null | 440.2 | 0.0 | absent (dir empty) | J+H |
| 471 | darkrowall-t_terrain_shore | skipped | null | 445.4 | 0.0 | absent (dir empty) | J+H |
| 472 | darkrowall-t_combo_all | skipped | null | 439.6 | 0.0 | absent (dir empty) | J+H |
| 473 | darkrowall-t_terrain_trees | skipped | null | 444.9 | 0.0 | absent (dir empty) | J+H |
| 474 | darkrowall-t_terrain_mines | **NO RECORD** | — | — | — | absent (dir empty) | none |
| 475 | darkrowall-t_combo_trees_shore | ok | 0 | 439.3 | 13.1 | 75 B / EMPTY | J+H |
| 476 | motionanim01-rotor-smoke-r3 | ok | 0 | 0.0 | 9.5 | 75 B / EMPTY | J+H |
| 477 | perf3d01-sync120c | ok | 0 | 0.0 | 160.0 | 281 B / 3847 B | J+H |
| 478 | rotorasset01-import-r2 | ok | 0 | 10.2 | 48.7 | 2538 B / EMPTY | J+H |
| 479 | weatherdriver01-smoke | ok | 0 | 48.6 | 10.9 | 75 B / EMPTY | J+H |
| 480 | sp06-sun-smoke-r2 | ok | 0 | 58.3 | 6.5 | 75 B / EMPTY | J+H |
| 481 | minimapquad01-boot2 | failed | 1 | 64.7 | 88.6 | 75 B / EMPTY | J+H |
| 482 | mapsize01-uitest | failed | 1 | 96.5 | 35.4 | 75 B / EMPTY | J+H |
| 483 | terraindarkfix2-p0-r2 | failed | 1 | 121.0 | 11.8 | 167 B / EMPTY | J+H |
| 484 | seasonpath01-smoke-r2 | failed | 1 | 106.3 | 10.2 | 75 B / 1045 B | J+H |
| 485 | mapsmall01-json-selftest | failed | 1 | 117.7 | 176.5 | 906 B / 3848 B | J+H |
| 486 | darkrowall-t_terrain_trees-r1 | ok | 0 | 294.2 | 4.8 | 75 B / EMPTY | J+H |
| 487 | audiosel02-smoke | ok | 0 | 296.3 | 8.5 | 75 B / EMPTY | J+H |
| 488 | weatherdriver01-smoke | ok | 0 | 242.5 | 4.9 | 1005 B / EMPTY | J+H |
| 489 | motionanim01-rotor-boot | failed | 1 | 221.3 | 134.3 | 243 B / 4145 B | J+H |
| 490 | perf3d01-selftestc | failed | 1 | 295.2 | 24.9 | 75 B / EMPTY | J+H |

**Observations on output emptiness `[observed]`:**
- All 19 skipped tickets have **no stdout/stderr files at all** (result dir empty) — not
  zero-byte files, but no files. Consistent with `run: 0.0`, i.e. Godot never launched.
- 10 `ok` jobs have a 75-byte stdout (engine banner) and a **zero-byte stderr**; the 75-byte
  stdout means the pass count for these jobs is **not** in stdout but in the generated gate
  report JSON (`selftest.json`/`uitest.json`) or derived from exit 0.
- `477`, `478`, `485`, `489` have large stderr (3847/3848/4145 B) with non-fatal warnings;
  exit status is authoritative.

---

## 3. Count summary — window 445–490 (46 tickets)

`[derived]` from S1+S2+S3, union of history and JSON artifacts.

| Status | Count | Ticket ids |
|---|---:|---|
| `skipped` | **19** | 448,449,450,451,452,453,454,456,457,458,462,465,466,468,469,470,471,472,473 |
| `ok` | **10** | 464,475,476,477,478,479,480,486,487,488 |
| `failed` | **10** | 445,455,461,481,482,483,484,485,489,490 |
| `timed-out` | **0** | (none in this window; ticket 494, just outside it, is `timed-out`, exit −9, run 256.3 s vs timeout 240 s) |
| `NO_RECORD` | **7** | 446,447,459,460,463,467,474 — empty result dirs, no JSON, no history entry |
| **Total** | **46** | |

History-only view `[derived]`: status.json contains 16 of the 19 skips; tickets **454, 462,
468 have a `skipped` JSON artifact but no history entry**. Therefore 10 tickets in the
window are absent from history (the 7 NO_RECORD plus those 3 JSON-only skips). This is a
real history/artifact inconsistency — flagged, not fixed.

Counter-check `[observed]`: `QA_PARITY_01.md:28` records an earlier global snapshot
(`failed 139, ok 278, timed-out 22` at completed 439) — consistent with the window's mix
of `ok`/`failed` and with skips being a later saturation phenomenon.

---

## 4. Overtake / next_ticket analysis

The runner records the exact serving position in each skipped job's `error` string
(`error: "ticket N was skipped (serving=M)"`). Two distinct skip causes exist `[observed]`:

1. **Overtake skip** — `serving > ticket`: `now_serving` advanced past a still-waiting ticket
   before it was dispatched. 17 of 19 skips in the window.
2. **Max-wait skip** — `ticket N waited > Xs for its turn`: no serving number. 2 skips
   (449 at 1800 s, 451 at 600 s). `[inferred]` these are queue-age expiry, not overtake.

| Ticket | Exact `error` text (from JSON) | serving | overtake Δ (serving − ticket) |
|---:|---|---:|---:|
| 448 | `ticket 448 was skipped (serving=464)` | 464 | **+16** |
| 450 | `ticket 450 was skipped (serving=461)` | 461 | **+11** |
| 452 | `ticket 452 was skipped (serving=461)` | 461 | **+9** |
| 453 | `ticket 453 was skipped (serving=461)` | 461 | **+8** |
| 454 | `ticket 454 was skipped (serving=465)` | 465 | **+11** |
| 456 | `ticket 456 was skipped (serving=461)` | 461 | **+5** |
| 457 | `ticket 457 was skipped (serving=458)` | 458 | **+1** |
| 458 | `ticket 458 was skipped (serving=461)` | 461 | **+3** |
| 462 | `ticket 462 was skipped (serving=475)` | 475 | **+13** |
| 465 | `ticket 465 was skipped (serving=475)` | 475 | **+10** |
| 466 | `ticket 466 was skipped (serving=467)` | 467 | **+1** |
| 468 | `ticket 468 was skipped (serving=475)` | 475 | **+7** |
| 469 | `ticket 469 was skipped (serving=475)` | 475 | **+6** |
| 470 | `ticket 470 was skipped (serving=475)` | 475 | **+5** |
| 471 | `ticket 471 was skipped (serving=475)` | 475 | **+4** |
| 472 | `ticket 472 was skipped (serving=475)` | 475 | **+3** |
| 473 | `ticket 473 was skipped (serving=475)` | 475 | **+2** |
| 449 | `ticket 449 waited > 1800s for its turn` | — | max-wait skip (1800.2 s) |
| 451 | `ticket 451 waited > 600s for its turn` | — | max-wait skip (600.0 s) |

`[derived]` The three dominant overtake fronts are **serving 461** (six tickets: 450, 452,
453, 456, 458 — plus 457 skipped at 458), **serving 465** (454), and **serving 475** (eight
tickets: 462, 465, 468, 469, 470, 471, 472, 473 — plus 466 skipped at 467). The largest
single overtake is 448 → 464 (+16).

Corroboration `[observed]`:
- `QA_PARITY_01.md:39-40` independently records 452/453 as `skipped … (serving=461)`.
- `QA_PARITY_01.md:97` discloses that tickets 446/447 died when the QA worker's 60 s
  background shell was killed, and that its cleanup wrongly cancelled 448/449 (their owners
  were told to resubmit with `-r2` ids: 458 for rotor, 464 for configwirer). 458 and 464 were
  then themselves skipped (458→461) and ok (464) respectively. Tickets 446/447 have no result
  record at all, matching the empty dirs in §2.
- `PROGRESS.md:38-43` documents an earlier precedent: COORD's `unwedge` advanced 2000 empty
  tickets and the bogus skipped JSONs were deleted; `now_serving` was restored to 312 to
  match `next_ticket`. `[inferred]` this is why some historical skipped JSONs are absent,
  but it does **not** explain the 454/462/468 JSON-without-history state in this window.
- Current runner position `[observed]`: `now_serving=500`, `counter/next_ticket=503`,
  `godot.lock='500 1795603031.344'`, `jobs/` contains 500/501/502 — the queue is still live,
  so all counts are perishable.

---

## 5. Which owner submitted which job (window 445–490)

Owner mapping is `[derived]` from the job-id prefix / `argv` script against the exclusive
file grant and session id in `SWARM_BOARD.md`. It is not a provenance field in the result
record — the result JSON contains no owner/session field `[observed]`. Exception:
QA-PARITY-01's own report states 446/447/452/453 are its jobs `[observed]`.

| Owner (SWARM_BOARD id) | Session id | Window ticket ids |
|---|---|---|
| MAP-SMALL-01 | `ses_dee1ffa4dffeNE1DyOlFaHFllL` | 445, 461, 485 |
| MOTION-ANIM-01 | `ses_dedf02a91ffe4WC7rm8cJUkFU7` | 448, 458, 462, 476, 478, 489 |
| CONFIG-WIRE-RELIEF | `ses_dede47f35ffeJtm9VwqT6yGQNB` | 449, 464 |
| WEATHER-DRIVER-01 | `ses_dede47f33ffejvS2MRfuAE33S6` | 450, 479, 488 |
| AUDIO-SEL-02 | `ses_dede47f36ffeaGALXfX3VRRfEG` | 451, 465, 468, 487 (and 495 just outside) |
| QA-PARITY-01 | `ses_dede47f21ffeN0cMxpshIcpAOZ` | 446, 447 (killed), 452, 453 (skipped) |
| MINIMAP-QUAD-01 | `ses_dedf02a90ffdT7nAiMWDUbpMQj` | 454, 481 |
| MAPSIZE-01 | `ses_dede3a392ffe6P3B6Ttaon7o44` | 455, 482 |
| TERRAIN-DARK-FIX | `ses_dedec4474ffee1ghS4x7WOLRug` | 456, 483 (and 491 just outside) |
| SP-6 / season renderer hook | `ses_dedf28b63ffeWAnI54lgoZm6sz` | 457, 480 |
| PERF-3D-01 | `ses_deddede28ffePAlAptFGEy4kzn` | 459, 460, 463, 467, 477, 490 |
| SEASON-TEST-PATH-01 | `ses_dedd5c6b9ffebY8CjZ2LHhmm8U` | 466, 484 |
| DARKROW-ALL-01 | `ses_deddb4a21ffeMNC2rRgf4X3t4F` | 469–475, 486 (and 493 just outside) |

`[UNVERIFIED]` which specific agent *process* issued each submit command; the board maps
owners to file grants and session ids, not to ticket numbers. `[inferred]` id prefixes such
as `configwirer-` → CONFIG-WIRE-RELIEF (its smoke checks `res://scripts/main.gd`, the file
that owner held) and `darkrowall-t_*` → DARKROW-ALL-01 are reliable but not recorded as such.

---

## 6. Claim verification — "green" job ids in today's docs

Artifact truth column is `[observed]` from S1+S2+S3. For ids whose stdout has no PASS string,
the pass count is **derived from exit 0 + the generated gate report**, exactly as
`QA_PARITY_01.md:50-58` does (`main.gd:2032` ⇒ exit 0 only when `report.passed`). No stdout
PASS string was found for 312/313/318/337/366/440/426/430 `[observed]`.

| Id | Job id / claim | Where claimed | Actual artifact (status / exit) | Verdict |
|---:|---|---|---|---|
| 312 | `cfg01-selftest` — selftest 29/29 | QA_PARITY_01:50, README:196, PROGRESS:194 | ok / 0 | **CONFIRMED** |
| 313 | `cfg01-uitest` — uitest 17/17 | QA_PARITY_01:51, README:197, SWARM_BOARD:85 | ok / 0 | **CONFIRMED** |
| 318 | `sel01-uitest` — uitest 17/17 | QA_PARITY_01:52, README:197 | ok / 0 | **CONFIRMED** |
| 329 | `sel01-probe-shift` — 12/12 | QA_PARITY_01:53, S1_INPUT_FIX | ok / 0, stdout `PASS 12/12` | **CONFIRMED** |
| 337 | `sel01-selftest-final` — selftest 29/29 | QA_PARITY_01:54, README:196, SEL_01:14,77 | ok / 0 | **CONFIRMED** |
| 366 | `uitestanchor-uitest` — 17/17, bottom-right | QA_PARITY_01:55, UITEST_ANCHOR:64,86, README:197 | ok / 0 | **CONFIRMED** |
| 381 | `camrv01-smoke3` — 20/20 | QA_PARITY_01:56, SWARM_BOARD:145 | ok / 0, stdout `PASS 20/20` | **CONFIRMED** |
| 414 | `s1inputfix-run2` — S1 23/23 | QA_PARITY_01:57, S1_INPUT_FIX:156, README:201 | ok / 0, stdout `PASS 23/23` | **CONFIRMED** |
| 420 | `mapsmall01-diag11-240` | MAP_SMALL_01_report:141 — listed as **diagnostic**, not green | **failed / 1** | **FAILED** |
| 426 | `configui01-smoke` — smoke ok | SWARM_BOARD:205, CONFIG_UI_01 | ok / 0, stderr 0 B | **CONFIRMED** |
| 430 | `configwires-smoke` — windowed drag 23/23 | SWARM_BOARD:209, QA_DOCS_01:64 | ok / 0, stderr 0 B | **CONFIRMED** |
| 434 | `fximpact01-smoke` — `t_fx3d` 13/13 | QA_PARITY_01:58, FX_IMPACT_01:194, README:203 | ok / 0, stdout `PASS 13/13` | **CONFIRMED** |
| 438 | `configwires-drag` — 23/23 | QA_DOCS_01:64, RECHECK_S1:158 | ok / 0, stdout `PASS 23/23` | **CONFIRMED** |
| 440 | `configwireh-uitest` — 17/17 | README:197, SWARM_BOARD:211, FINAL_GATE_PLAN:77 | ok / 0 | **CONFIRMED** |
| 441 | `terraindarkfix-p0` — P0 gates PASS | SWARM_BOARD:207 | ok / 0, stdout `PASS 22/22` | **CONFIRMED** |
| 455 | `mapsize01-selftest` | MAPSIZE_01:64 itself records END failed | **failed / 1**, wait 1682.7 s | **FAILED** |
| 482 | `mapsize01-uitest` | MAPSIZE_01:65 records END failed; :74 says the 17/17 came from elsewhere | **failed / 1** | **FAILED** |
| 495 | `audiosel02-drag` — 23/23 | RECHECK_S1:158 (post-audit re-run) | ok / 0, stdout `PASS 23/23` | **CONFIRMED** |
| 452 | `qaparity01-uitest` | QA_PARITY_01:40 (declares skipped) | skipped, exit null | **SKIPPED** |
| 453 | `qaparity01-selftest` | QA_PARITY_01:39 (declares skipped) | skipped, exit null | **SKIPPED** |
| 446 / 447 | `qaparity01-*` attempt 1 | QA_PARITY_01:37-38 (killed by 60 s harness timeout) | no JSON, no history, empty dir | **NO_ARTIFACT** |
| 448 / 449 | rotor / configwirer originals | QA_PARITY_01:97 (wrongly cancelled) | skipped, exit null | **SKIPPED** |

**Derived summary:** of the 13 ids explicitly given in the task list
(312/313/337/366/414/420/426/430/434/440/455/482 + etc.), **9 are CONFIRMED**
(312,313,337,366,414,426,430,434,440), **3 are FAILED** (420,455,482), **0 are
NO_ARTIFACT** among them. NO_ARTIFACT applies only to 446/447, which no doc claims green.
`[UNVERIFIED]` no claim id in the list has a green prose claim backed by an absent artifact
— the "prose only" risk is the inverse: all cited green ids 312/313/337/366/440 have real
`ok` envelopes but **no pass-count string in stdout**, so the 29/29 and 17/17 numbers come
from exit semantics plus the gate-report JSON, not from the runner stdout `[observed]`.

---

## 7. Open questions

1. `[UNVERIFIED]` Why do tickets 454, 462, 468 have `skipped` JSON artifacts but **no
   status.json history entry**, while 448/449/451/etc. have both? Possible late/partial write
   or a history rebuild — not determinable from the files read.
2. `[UNVERIFIED]` Why do tickets 446, 447, 459, 460, 463, 467, 474 have result directories
   but no JSON and no history? QA_PARITY_01:97 explains 446/447 (harness kill); the other
   five have no recorded explanation in the docs read.
3. `[UNVERIFIED]` Exact cause of the overtake at serving 461/465/475 — dead-holder
   reclamation vs. harness-managed background PIDs. QA_PARITY_01:110 lists this as an open
   question too; no runner mutation was attempted here to investigate.
4. `[UNVERIFIED]` Whether the 448/449 `-r2` resubmissions fully recovered the two gates:
   458 (rotor r2) was itself skipped; 464 (configwirer r2) is ok. No final green rotor smoke
   is obvious in this window other than 476 (`motionanim01-rotor-smoke-r3`, ok).
5. `[UNVERIFIED]` Whether status.json will remain consistent as the live runner advances
   past 500 — counts in §3 are a snapshot of a changing file.
6. `[UNVERIFIED]` Ownership of tickets 459/460/463/467 (PERF-3D-01 by id prefix) — those
   jobs have no result record, so no evidence of what ran.

---

## 8. Summary

- `[observed]` In tickets 445–490 the runner produced **19 skipped, 10 ok, 10 failed,
  0 timed-out**, plus **7 tickets with no record at all** (empty result dirs).
- `[derived]` Skips dominate: 17 are confirmed overtake skips with exact serving positions
  (largest 448 → 464, +16), 2 are max-wait expiries. The three overtake fronts were serving
  **461**, **465** and **475**.
- `[observed]` Skipped jobs left **no stdout/stderr files** and zero run time; no gate result
  can be attributed to them.
- `[derived]` All 13 green-claim ids audited resolve to real artifacts except 420/455/482,
  which are actually `failed`; no claimed-green id is "prose only" at the envelope level.
  However, for 312/313/337/366/440 the pass counts themselves are not in stdout.
- `[observed]` A history/artifact inconsistency exists (454/462/468 JSON-only) and seven
  window tickets have no result record; both are reported, not repaired.

**Mutation statement: none.** No runner state, queue file, lock, `now_serving`, `counter`,
job, code, config, test, backup or any other report was changed by this audit. The only file
written is `docs/coord_swarm_2026-11-25/reports/QA_RUNNER_ARTIFACTS_01.md`.
