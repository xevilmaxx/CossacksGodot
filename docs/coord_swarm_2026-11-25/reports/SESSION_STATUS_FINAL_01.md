---
title: SESSION-STATUS-FINAL-01 — live/terminated agent counts after the refill
area: coordination
ticket: SESSION-STATUS-FINAL-01
created: 2026-11-25
snapshot_local: "2026-11-25 11:37:05–11:37:17 (wall clock, before/after bracket)"
status: final
mutation: none — read-only DB query and one report file only
---

# SESSION-STATUS-FINAL-01 — live/terminated counts after the refill

> **No mutation performed.** No code, board, or other doc was edited; no runner job was
> started. The only write is this report file.

Label convention used throughout: **[O]** observed directly in helper/DB output,
**[D]** derived by counting/comparison, **[I]** inferred (mapping/judgement),
**[U]** UNVERIFIED.

## 1. Method and helper invocation caveat

- Helper: `python C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\session_status_check.py`
  (read-only SQLite `mode=ro` against `C:\Users\Maxym.Oboyshev\.local\share\opencode\opencode.db`,
  `SELECT ... FROM session_v2 WHERE parent_id=? ORDER BY time_created`). **[O]**
- **Invocation trap:** run with this subagent's ambient `OPENCODE_SESSION_ID`
  (`ses_dedbb64faffevvN1Imbet9JkuQ`), the helper prints `current: ses_dedbb64faffevvN1Imbet9JkuQ`
  and `children: 0` — a subagent has no swarm children. **[O]** To query the swarm, the helper
  was re-run with `$env:OPENCODE_SESSION_ID="ses_dee54b600ffeIJcid56WLwoxnL"`. **[O]**
- That ID is the root orchestrator `ses_dee54b600ffeIJcid56WLwoxnL` ("3D variant development
  tracking", `parent_id = None`); it is this subagent's direct parent, and board-listed workers
  `AUDIO-SEL-02` (`ses_dede47f36ffeaGALXfX3VRRfEG`) and `PERF-3D-01`
  (`ses_deddede28ffePAlAptFGEy4kzn`) both have `parent_id` equal to it. **[O]** Hence it is the
  authoritative "current session" for the board's live-session query. **[D]**
- Helper state rule: `time_archived` → ARCHIVED; else `time_busy` set and `time_idle` unset →
  BUSY/RUNNING; else `time_idle` set → IDLE/DONE; else UNKNOWN. No ARCHIVED or UNKNOWN rows
  appeared. **[O]**

## 2. DB output summary (snapshot 11:37:05–11:37:17)

| Metric | Value | Label |
|---|---|---|
| Total direct children of orchestrator | **162** | **[O]** |
| BUSY / RUNNING (`time_idle` unset, `time_busy` set) | **23** | **[O]/[D]** |
| IDLE / DONE (`time_idle` set) | **139** | **[O]/[D]** |
| ARCHIVED / UNKNOWN / OTHER | **0** | **[O]** |
| IDLE breakdown: `idle_outcome=succeeded` | 137 | **[O]** |
| IDLE breakdown: `idle_outcome=interrupted` | 2 (`ses_dee4f6ff7ffemIl1UwfIe9qQyz` DEC-03 configs; `ses_dee4f6ffaffervR4Ohf2PqdtmR` DEC-02 scripts) | **[O]** |
| BUSY `idle_outcome` | all `None` | **[O]** |

Counts are **volatile**: the first helper pass read `children: 160` / 21 BUSY / 139 IDLE, then
two new children (`ses_dedb8f593...`, `ses_dedb8f583...`, both `busy=11:36:16`) appeared before
the bracketed final read of `children: 162` / 23 BUSY / 139 IDLE. **[O]** The bracketed final run
is the snapshot used below. Re-run the helper immediately before any board edit. **[I]**

## 3. Every BUSY / RUNNING session (id, title, `time_updated`)

All 23 rows below are **[O]**; the "Board row" attribution is **[I]** where a board ticket
matches by session id, **[U]** where no board row exists (title-only attribution).

| # | Session id | Title (DB) | `time_busy` | `time_updated` | Board row | In live section? |
|---|---|---|---|---|---|---|
| 1 | ses_dede47f36ffeaGALXfX3VRRfEG | Wire selection sound caller | 10:48:42 | **11:37:04** | AUDIO-SEL-02 (Batch O) | yes |
| 2 | ses_deddede28ffePAlAptFGEy4kzn | Measure 3D perf hotpaths | 10:54:51 | **11:37:00** | PERF-3D-01 (Batch O) | yes |
| 3 | ses_dedd5c6b9ffebY8CjZ2LHhmm8U | Align season test atlas paths | 11:04:47 | **11:36:50** | SEASON-TEST-PATH-01 (Batch O) | yes |
| 4 | ses_dedbf5c9dffe4mdGt2dTO77GT1 | Recheck P0 capture | 11:29:16 | **11:37:00** | RECHECK-P0-01 (Batch S) | no |
| 5 | ses_dedbf5c9cffeJGUuUd4kuM4BPJ | Recheck S1 capture | 11:29:16 | **11:36:44** | RECHECK-S1-01 (Batch S) | no |
| 6 | ses_dedbf5c7bffdpJAj2a51MOZJ02 | Recheck doc link fixes | 11:29:16 | **11:37:04** | QA-LINKS-02 (Batch S) | no |
| 7 | ses_dedbf5c78ffePdQ3lag7ysrYYr | Verify donor building truth | 11:29:16 | **11:36:50** | DBUILD-02 (Batch S) | no |
| 8 | ses_dedbf5c76ffeCAAq15b0by5BNk | Verify donor naval corrections | 11:29:16 | **11:37:03** | DONAVAL-02 (Batch S) | no |
| 9 | ses_dedbf5c74ffeDLQM3IjgeRqqcQ | Audit stale atom results | 11:29:16 | **11:36:47** | QA-ATOM-STALE-02 (Batch S) | no |
| 10 | ses_dedbedb1effe077PkS0kvUcbKo | Implement building stages | 11:29:49 | **11:37:00** | BUILD-STAGES-01 (Batch S) | no |
| 11 | ses_dedbedadfffezftdXZw2t7S4St | Verify living docs fixes | 11:29:49 | **11:37:03** | QA-DOCLIVE-01 (Batch S) | no |
| 12 | ses_dedbedb1dffeTXMw40zNTmaHX1 | Plan winter field decal | 11:29:49 | **11:36:36** | FIELD-WINTER-01 (Batch S) | no |
| 13 | ses_dedbedaf9ffejr3WE6IIQbhDuF | Write final checklist | 11:29:49 | **11:35:48** | FINAL-CHECKLIST-01 (Batch S) | no |
| 14 | ses_dedbedb1affeEuwiV0mWCxioor | Plan morale removal | 11:29:49 | **11:36:59** | MORALE-PLAN-01 (Batch S) | no |
| 15 | ses_dedbedaf1ffeK1luRvYOin2v5Y | Recheck clean gate quiescent | 11:29:49 | **11:36:58** | QA-CLEAN-02 (Batch S) | no |
| 16 | ses_dedbedae6ffeRQKk1qsDCty2Xk | Verify donor fog sky reversal | 11:29:49 | **11:36:23** | DENV-02 (Batch S) | no |
| 17 | ses_dedbedae2ffeMiBmZSUTxXJ7z7 | Verify animation clip table | 11:29:49 | **11:37:00** | DANIM-02 (Batch S) | no |
| 18 | ses_dedbb6505ffe0cw9EmKYeTG6zY | Audit runner result artifacts | 11:33:40 | **11:37:00** | none in board **[U]** | no |
| 19 | ses_dedbb6501ffe1KC3EJCm7QQShu | Refresh README final state | 11:33:40 | **11:36:59** | none in board **[U]** | no |
| 20 | ses_dedbb64faffevvN1Imbet9JkuQ | Recheck live session count | 11:33:41 | **11:36:58** | none — **this subagent** **[O]** | no |
| 21 | ses_dedbb6506ffeTpu8SKK3Bt4lkC | Diagnose gate startup failures | 11:33:41 | **11:36:50** | none in board **[U]** | no |
| 22 | ses_dedb8f593ffeWDu1dbADp9AvHh | Build winter prop name map | 11:36:16 | **11:36:58** | none in board **[U]** | no |
| 23 | ses_dedb8f583ffeUzlq4aITt2b3HA | Verify prop winter plan counts | 11:36:16 | **11:36:59** | none in board **[U]** | no |

Composition: 3 original live-section workers + 14 Batch S workers + 6 board-unlisted workers
= 23. **[D]** Note `time_updated` for this subagent itself advances while it runs — its own row
is part of the live count. **[O]/[I]**

## 4. Comparison to `SWARM_BOARD.md` live-session section (lines 14–35)

Board claims **140 children / 135 IDLE/DONE / 5 BUSY/RUNNING**, and at lines 29–35 that "only 4
sessions remain BUSY/RUNNING". **[O from file]** DB at 11:37 says **162 / 139 / 23**. **[O]**

### 4a. The 5 board-listed entries, current DB state

| Board line | Session / ticket | Board state | DB state @11:37 | Result |
|---|---|---|---|---|
| 23 | ses_dede47f36ffeaGALXfX3VRRfEG / AUDIO-SEL-02 | BUSY / RUNNING | BUSY, idle=-, outcome=None, upd 11:37:04 | still live **[O]** |
| 24 | ses_deddede28ffePAlAptFGEy4kzn / PERF-3D-01 | BUSY / RUNNING | BUSY, idle=-, outcome=None, upd 11:37:00 | still live **[O]** |
| 25 | ses_dedd5c6b9ffebY8CjZ2LHhmm8U / SEASON-TEST-PATH-01 | BUSY / RUNNING | BUSY, idle=-, outcome=None, upd 11:36:50 | still live **[O]** |
| 26 | ses_dedc825dfffe65At77RG2CJO98 / PROP-W-PLAN-01 | BUSY / RUNNING | **IDLE/DONE**, idle 11:35:33, outcome=succeeded | **now TERMINATED — board stale** **[O]** |
| 27 | ses_dedc5f56fffehXY13hwbbbUbV1 / QA-DOCS-02 | TERMINATED (struck through) | IDLE/DONE, idle 11:27:58, outcome=succeeded | terminated; board already correct **[O]** |

**Listed but now terminated:** PROP-W-PLAN-01 (and QA-DOCS-02, already struck). **[D]**
**Running but missing from the live section:** the other 20 BUSY sessions — 14 Batch S rows
(#4–17 above) plus 6 rows with no board row at all (#18–23 above). **[D]**

### 4b. Secondary sweep — other board "RUNNING"/"REPORT DELIVERED" rows now terminated

Outside the live section, these board rows are also IDLE/DONE in the DB with `outcome=succeeded`
(all **[O]**; idle times local): `QA-BOARDLIVE-01` ses_dedbf5c7fffdEM7oUSBra4zAKe 11:35:02;
`DARKROW-ALL-01` ses_deddb4a21ffeMNC2rRgf4X3t4F 11:14:38; `MINIMAP-QUAD-01`
ses_dedf02a90ffdT7nAiMWDUbpMQj 11:27:25; `LINKS-01` ses_dedd0b77affePHsOgnl49CI27l 11:26:37;
`QA-ATOM-RESULTS-01` ses_dedcdf2c3ffeeNnd0m5fmCmM6R 11:23:20; `DESERT-REMAP-02`
ses_dedc825e3ffeCybE4oju7Ds2Az 11:25:55; `SP8-STATUS-01` ses_dedc825deffegTIEqiL78uxsGw
11:26:32; `MAP-SMALL-01` ses_dee1ffa4dffeNE1DyOlFaHFllL 11:10:46; `MOTION-ANIM-01`
ses_dedf02a91ffe4WC7rm8cJUkFU7 11:33:13; `SP-6` ses_dedf28b63ffeWAnI54lgoZm6sz 11:25:45;
`TERRAIN-DARK-FIX` ses_dedec4474ffee1ghS4x7WOLRug 11:09:59. Terminated workers must not be
counted as live. **[D]**

## 5. Toggle test on the 5 original live entries via `idle_outcome`

Rule applied: `idle_outcome ∈ {succeeded, interrupted}` **and** `time_idle` set ⇒ terminated ⇒
**excluded** from live count; `idle_outcome=None` and `time_idle` unset ⇒ live ⇒ **included**.
**[D]**

| # | Session | `idle_outcome` | `time_idle` | Toggled state | Counted as live? |
|---|---|---|---|---|---|
| 1 | AUDIO-SEL-02 ses_dede47f36ffeaGALXfX3VRRfEG | None | - | BUSY/LIVE | **yes** |
| 2 | PERF-3D-01 ses_deddede28ffePAlAptFGEy4kzn | None | - | BUSY/LIVE | **yes** |
| 3 | SEASON-TEST-PATH-01 ses_dedd5c6b9ffebY8CjZ2LHhmm8U | None | - | BUSY/LIVE | **yes** |
| 4 | PROP-W-PLAN-01 ses_dedc825dfffe65At77RG2CJO98 | succeeded | 11:35:33 | **TERMINATED** | **no** |
| 5 | QA-DOCS-02 ses_dedc5f56fffehXY13hwbbbUbV1 | succeeded | 11:27:58 | **TERMINATED** | **no** |

Result: of the 5 original entries, **3 remain live and 2 are now terminated**; the terminated two
are confirmed excluded from the 23-BUSY total. **[O]/[D]** The only `interrupted` outcomes in the
whole child set are DEC-02/DEC-03 and they are already IDLE, so they are likewise not counted.
**[O]**

## 6. VERDICT

**Snapshot time: 2026-11-25 11:37:05–11:37:17 local (bracketed helper run).** **[O]**

The refill did not replace the live set — it **added** to it. The board's authoritative live
count is stale by one terminated original worker and by 20 new running workers: actual
**162 children, 23 BUSY/RUNNING, 139 IDLE/DONE**. **[O]/[D]** The three surviving originals
(AUDIO-SEL-02, PERF-3D-01, SEASON-TEST-PATH-01) are genuinely still running; PROP-W-PLAN-01
finished at 11:35:33 (`succeeded`) and must be struck. **[O]** Six currently BUSY sessions have
no board row at all. **[D]/[U]** Counts moved 160→162 during this check, so any published figure
must carry a snapshot timestamp. **[O]/[I]**

### Recommended exact board edit — NOT applied

Replace `SWARM_BOARD.md` line 19 with: **[I]**

```markdown
**162 direct child sessions; 139 are IDLE/DONE (terminated), 23 are BUSY/RUNNING** (snapshot
2026-11-25 11:37:05–11:37:17; volatile — re-run `session_status_check.py` with
`OPENCODE_SESSION_ID=ses_dee54b600ffeIJcid56WLwoxnL` immediately before publishing).
```

Replace the table at lines 21–27 and the paragraph at lines 29–35 with a 23-row BUSY table using
the id / ticket / `time_busy` / `time_updated` values in §3 above, plus these notes: **[I]**

```markdown
| Session id | Ticket | State | `time_busy` | `time_updated` |
| ...all 23 rows from SESSION_STATUS_FINAL_01 §3, in that order... |

PROP-W-PLAN-01 (ses_dedc825dfffe65At77RG2CJO98) is now TERMINATED (`time_idle` 11:35:33,
`idle_outcome=succeeded`) — strike it. QA-DOCS-02 remains TERMINATED. The 3 surviving original
workers are AUDIO-SEL-02, PERF-3D-01, SEASON-TEST-PATH-01. Fourteen Batch S workers and six
board-unlisted workers (ses_dedbb6505..., ses_dedbb6501..., ses_dedbb64fa... [this status
check], ses_dedbb6506..., ses_dedb8f593..., ses_dedb8f583...) are also BUSY/RUNNING. Every
other session id in this board is TERMINATED (`time_idle` set, `idle_outcome` succeeded or
interrupted). DEC-02/DEC-03 ended `interrupted` by explicit cancellation after their complete
reports landed; that is a terminated state, not a running one. Do not re-spawn these workers
to ask for status.
```

No other board section was recommended for rewrite; §4b rows should be marked TERMINATED in
their own batch tables if COORD wants full consistency. **[I]**

## 7. Open questions

1. Are the 6 board-unlisted BUSY sessions legitimate swarm workers needing board rows, or stray
   subagents? Their titles suggest follow-on work (winter prop name map, prop winter plan counts,
   runner artifacts, README final, gate startup failures, this status check), but attribution is
   title-only. **[U]**
2. The tally changed 160→162 in ~40 s. What is the final count at the moment COORD edits the
   board? Requires a fresh helper run; the number in this report is a snapshot, not a constant.
   **[U]**
3. Several IDLE rows have `time_updated` ≈ 11:37:00 while `time_idle` is much earlier (e.g.
   ses_dee1ffa4d... idle 11:10:46/upd 11:37:00; ses_dedec4474... idle 11:09:59/upd 11:37:00;
   ses_deddb4a21... idle 11:14:38/upd 11:36:59). Does this indicate resume/re-idle cycles, or
   DB housekeeping? It does not change their terminated classification under the helper rule.
   **[U]**
4. Confirmed intent that DEC-02/DEC-03 `interrupted` are accepted terminal states, not pending
   restarts? The board already states this. **[O from file] / [I]**
5. Reproduction hazard: any agent running the helper from its own subagent context gets
   `children: 0`. Should the helper default `OPENCODE_SESSION_ID` to the parent when the ambient
   session itself has zero children? (Not changed — read-only task.) **[I]**

## 8. Summary

- **162** direct children of the orchestrator; **23 BUSY/RUNNING**, **139 IDLE/DONE** (137
  succeeded, 2 interrupted); snapshot **11:37:05–11:37:17**. **[O]/[D]**
- Of the board's 5 original live entries, **3 remain live** and **2 are now terminated**
  (PROP-W-PLAN-01 newly; QA-DOCS-02 already) — terminated workers excluded from the live count.
  **[O]/[D]**
- Board live-section counts (140/135/5 and "4 remain") are stale; 20 BUSY sessions are missing
  from it, 6 of them absent from the board entirely. **[D]/[U]**
- Exact replacement text was recommended in §6 and **was not applied**.
- **No mutation performed:** only read-only DB queries plus the creation of this report file.
