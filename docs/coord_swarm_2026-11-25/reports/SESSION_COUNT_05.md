---
title: SESSION-COUNT-05 — real-time live/terminated count (second refresh)
area: coordination
ticket: SESSION-COUNT-05
created: 2026-11-25
snapshot_local: "2026-11-25 12:13:51 (single coherent read; DB MAX time_updated 12:13:50)"
status: final
mutation: none in workspace — only this report file was written; read-only DB queries only
---

# SESSION-COUNT-05 — real-time live/terminated count (second refresh)

> **No workspace mutation performed.** No board, doc, or code file was changed; no runner job
> was started; every SQLite connection was opened with `mode=ro`. The only workspace file
> written is this report. Four throwaway Python query scripts were placed in the approved temp
> folder `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\` (outside the workspace) so the
> parent id could be hard-coded without PowerShell quoting ambiguity; they are not part of the
> deliverable. **[O]**

Label convention: **[O]** observed directly in DB/file output, **[D]** derived by counting or
comparison, **[I]** inferred (interpretation/judgement), **[U]** UNVERIFIED.

## 1. Method

- Direct Python `sqlite3` query against
  `C:\Users\Maxym.Oboyshev\.local\share\opencode\opencode.db`, opened as
  `sqlite3.connect("file:...?mode=ro", uri=True)`. **[O]**
- Query: `SELECT id,title,time_created,time_updated,time_archived,time_busy,time_idle,
  idle_outcome FROM session_v2 WHERE parent_id=? ORDER BY time_created`, with
  `parent_id = 'ses_dee54b600ffeIJcid56WLwoxnL'` **hard-coded** in the script. The supplied
  ambient-env helper was **not** used unchanged: as a subagent its `OPENCODE_SESSION_ID` sees
  **0 children**. Same method as `SESSION_COUNT_02.md` §1 and `SESSION_STATUS_FINAL_01.md` §1. **[O]**
- `session_v2` stores epoch **milliseconds**; local machine offset is **UTC+1**, so formatted
  times below use local time (`datetime.fromtimestamp`) and match the convention of
  `SESSION_COUNT_02.md` (11:44:52 local = 10:44:52 UTC). Wall clock at query: **12:13:51
  local / 11:13:51 UTC**. **[O]**
- State rule (identical to the helper and all prior reports): `time_archived` set ⇒ ARCHIVED;
  else `time_busy` set and `time_idle` unset ⇒ BUSY/RUNNING; else `time_idle` set ⇒
  IDLE/DONE; else UNKNOWN. Terminated = IDLE/DONE with `idle_outcome` `succeeded` or
  `interrupted`. **[O]**
- Board test: each BUSY id was matched literally against every `ses_*` id in
  `docs/coord_swarm_2026-11-25/SWARM_BOARD.md` (385 lines, **211** unique ids at read time).
  **[O]/[D]** The board is being edited concurrently — it had 159 ids at `SESSION_COUNT_02`
  time and 211 at this read, so the board figure is itself a snapshot. **[O]/[I]**

## 2. DB summary — headline snapshot 2026-11-25 12:13:51

| Metric | Value | Label |
|---|---|---|
| Total direct children of `ses_dee54b600ffeIJcid56WLwoxnL` | **220** | **[O]** |
| BUSY / RUNNING (`time_busy` set, `time_idle` unset) | **12** | **[O]/[D]** |
| IDLE / DONE (`time_idle` set) | **208** | **[O]/[D]** |
| ARCHIVED | 0 | **[O]** |
| UNKNOWN | 0 | **[O]** |
| IDLE `idle_outcome=succeeded` | **206** | **[O]** |
| IDLE `idle_outcome=interrupted` | **2** | **[O]** |
| BUSY `idle_outcome` | all `None` | **[O]** |
| `MAX time_updated` | **2026-11-25 12:13:50** (11:13:50 UTC) | **[O]** |
| Wall clock of query | 2026-11-25 12:13:51 | **[O]** |

`MAX time_updated` tracks the query wall clock because the live children update continuously;
it is a snapshot instant, not a stored constant. **[O]/[I]**

The two `interrupted` rows are unchanged from prior reports and remain excluded from the live
count: **[O]**

| Session id | Title | `time_idle` | `idle_outcome` | Label |
|---|---|---|---|---|
| ses_dee4f6ff7ffemIl1UwfIe9qQyz | Decompile donor configs | 09:41:07 | interrupted | **[O]** |
| ses_dee4f6ffaffervR4Ohf2PqdtmR | Decompile donor scripts | 09:41:12 | interrupted | **[O]** |

## 3. Every BUSY / RUNNING session (12 rows, complete)

All ids, titles, `time_busy` and `time_updated` are **[O]**. The board column is **[D]** (literal
id match against `SWARM_BOARD.md`); ticket names come from the matching board line. **[U]** for
any board attribution beyond the literal row.

| # | Session id | Title (DB) | `time_busy` | `time_updated` | Board row |
|---|---|---|---|---|---|
| 1 | ses_dedb6bb3dffe9gXQE3haVeunHp | Fix build selftest step | 11:38:42 | 12:11:31 | BUILD-STEP-FIX-01 (Batch T) |
| 2 | ses_dedb5cfdbffe9rh6Oh2C7HL1zS | Responsive top bar and speed dropdown | 11:39:42 | 12:07:10 | UI-TOPBAR-01 (Batch T) |
| 3 | ses_dedad36a5ffeWEolNmXHw5gRb0 | Fix nation model mapping | 11:49:08 | 12:13:50 | NATION-MODEL-01 (Batch U) |
| 4 | ses_deda1f2a2ffem2UIrpVyBEPDM1 | Plan nation units data | 12:01:25 | 12:13:47 | NATION-DATA-01 (Batch V) |
| 5 | ses_ded9c45f4ffe3Z4JWZzJG3Llab | Fix desert remap consumer | 12:07:36 | 12:12:49 | DESERT-CONSUMER-FIX-01 (Batch W) |
| 6 | ses_ded9bde82ffev3B2QRfQKLu4RM | Session count check | 12:08:03 | 12:13:47 | SESSION-COUNT-05 (Batch W) — **this verifier** |
| 7 | ses_ded99b6fbffe5YkoyCEpjSGOIO | Fix BATTLE_ARMY nation sids | 12:10:24 | 12:13:11 | NATION-SPAWN-IMPL-01 (line 323) |
| 8 | ses_ded9948b4ffdihVZGPzw4gbpvf | Run HUD layout atom | 12:10:52 | 12:12:49 | HUD-LAYOUT-RUN-01 (line 324) |
| 9 | ses_ded9948acffdBy47HgCPgAEC6k | Capture real map with relief on | 12:10:52 | 12:12:50 | RELIEF-VISUAL-01 (line 326) |
| 10 | ses_ded9948a0ffdBoQFS42ZHXWjGU | Verify desert consumer fix | 12:10:52 | 12:13:49 | QA-DESERT-FIX-01 (line 327) |
| 11 | ses_ded99489affee09KLS0Rxr5VYL | Plan stage mesh integration | 12:10:52 | 12:13:48 | BUILD-STAGE-INTEGRATION-01 (line 328) |
| 12 | ses_ded994896ffeQ5hhZ4xdQrikIz | Verify speed dropdown donor gap | 12:10:52 | 12:13:50 | QA-SPEED-01 (line 329) |

Composition: 2 survivors from the 11:44:52 BUSY set (#1–2) + 10 post-reference spawns
(#3–12) = 12. **[D]** All 12 carry a literal board row (**0 missing** — see §6b). **[D]**

## 4. Comparison with `SESSION_COUNT_02.md`

| Source | Snapshot (local) | Total | BUSY | IDLE | Interrupted | `MAX time_updated` | Label |
|---|---|---|---|---|---|---|---|
| `QA_BOARDLIVE_01.md` | 11:32:51 | 156 | 19 | 137 | not stated | 11:32:50 | **[O from file]** |
| `SESSION_STATUS_FINAL_01.md` | 11:37:05–11:37:17 | 162 | 23 | 139 | 2 | ≈11:37:04 | **[O from file]/[D]** |
| `SESSION_COUNT_02.md` | 11:44:52 | 180 | 20 | 160 | 2 | 11:44:52 | **[O from file]** |
| **This report** | **12:13:51** | **220** | **12** | **208** | **2** | **12:13:50** | **[O]/[D]** |
| Δ vs COUNT-02 (11:44:52 → 12:13:51) | +28m59s | **+40** | **−8** | **+48** | **0** | — | **[D]** |

### 4a. Explanation of the +40 total — observed spawns only

- **40 children** have `time_created > 11:44:52`. **[O]** Their ids/titles are the 40 rows in the
  NEW_SPAWNS set; the earliest is `ses_dedb0f7b1...` "Rebaseline desert season assertions"
  at 11:44:59 and the latest are the six `ses_ded9948*` / `ses_ded99489a*` spawns at
  12:10:51–12:10:52. **[O]** 180 + 40 = **220**. **[D]**
- No child row was deleted: ARCHIVED = 0 and the id set is monotonically growing. **[O]/[D]**

### 4b. Explanation of BUSY 20 → 12 and IDLE 160 → 208 — observed spawns/terminations only

- Of the **20 BUSY ids listed in `SESSION_COUNT_02.md` §3**, **18 are now IDLE/DONE**, every one
  with an observed `time_idle` in the window 11:44:53–12:09:46 and `idle_outcome=succeeded`.
  **[O]** Full observed list (id — title — `time_idle`): `ses_dedbedb1e...` Implement building
  stages — 11:45:40; `ses_dedbedae2...` Verify animation clip table — 11:44:53;
  `ses_dedbb6501...` Refresh README final state — 11:55:50; `ses_dedb76937...` Fix stale doc
  claims — 11:50:42; `ses_dedb7155d...` Plan clean-gate ack resolution — 11:49:36;
  `ses_dedb5890a...` Async loading and usable post-load — 12:09:46; `ses_dedb52b4c...` Author
  responsive HUD test atom — 11:55:48; `ses_dedb52b3d...` Document UX loading fixes — 11:48:04;
  `ses_dedb412e9ffe8...` Author load responsiveness probe — 11:52:20; `ses_dedb412e9ffdN...`
  Verify UX doc coverage — 11:46:28; `ses_dedb412e6...` Audit final checklist coverage —
  11:53:35; `ses_dedb4114c...` Session count refresh — 11:46:28; `ses_dedb410dd...` Verify
  donor resource panel truth — 11:56:32; `ses_dedb39c7f...` Fix dark-row atom parse error —
  11:51:40; `ses_dedb39c25...` Implement morale label gate — 11:55:12; `ses_dedb2bfb7...`
  Prepare runner mutual-exclusion fix — 11:54:30; `ses_dedb263ca...` Recheck final P0 capture —
  11:45:53; `ses_dedb263a5...` Plan queue drain and final gates — 11:50:20. **[O]**
- Only **2** of the 11:44:52 BUSY ids remain BUSY: `ses_dedb6bb3d...` (BUILD-STEP-FIX-01) and
  `ses_dedb5cfdb...` (UI-TOPBAR-01). **[O]**
- Of the **40 new spawns**, **10 are BUSY** now and **30 are already IDLE/DONE** (`succeeded`).
  **[O]/[D]** BUSY: 20 − 18 + 10 = **12**. **[D]** IDLE: 160 + 18 + 30 = **208**. **[D]**
- Independent check: **49** children have `time_idle > 11:44:52`. **[O]** That is 18
  ref-BUSY terminations + 30 new-spawn terminations + **1** further row,
  `ses_deddb4a21...` "Fix dark-row asserts all atoms" (idle 11:47:52), which was **not** in
  COUNT-02's 20-row BUSY list although its stored `time_busy` predates the reference. **[O]/[U]**
  A naive DB-state replay at 11:44:52 therefore yields **21** BUSY, not 20. The one-row
  discrepancy is UNVERIFIED (likely a resume/`time_busy` refresh or a perishable snapshot;
  see §6 Q2). It does not change the headline counts, which are taken from the final read. **[I]**

### 4c. Volatility bracket (why the number must carry a timestamp)

Three coherent reads in this check, same method: **[O]**

| Read (local) | `MAX time_updated` | Total | BUSY | IDLE |
|---|---|---|---|---|
| 12:11:49 | 12:11:49 | 220 | **16** | 204 |
| 12:13:29 | 12:13:28 | 220 | **13** | 207 |
| **12:13:51 (headline)** | **12:13:50** | **220** | **12** | **208** |

Between the first and final read, 3 more workers terminated; no new child spawned in that
~2-minute window (`TOTAL` stayed 220). **[O]/[D]** The headline uses the final coherent read.
**[D]** The BUSY count fell 20 → 16 → 13 → 12 across ~29 minutes since COUNT-02. **[O]**

## 5. VERDICT

### 5a. Current swarm size vs the owner directive

- Owner directives on the board: "sustained **15–20 agents**" (Batch K), "final small tickets
  (owner: keep **15–20 agents**)" (Batch O), "keep agent count high" (Batch I), "more agents,
  faster edits" (Batch H). **[O from file]** Line numbers are omitted because the board is being
  edited concurrently and shifts during a check. **[I]**
- Headline live count is **12 BUSY/RUNNING** (of 220 total). **[O]/[D]** That is **3 below the
  15 floor** — **outside the owner's 15–20 band on the low side at this instant**. **[D]/[I]**
  Earlier reads in this same check were **16 (in band)** at 12:11:49 and **13 (below floor)** at
  12:13:29, so the verdict is snapshot-limited: the swarm decayed through the band during the
  check rather than holding a steady size. **[O]/[I]**
- The 12 include **this verifier session** (`ses_ded9bde82...`); excluding the verifier, the
  productive swarm is 11. **[D]/[I]** No new children spawned after 12:10:52, so the decline is
  termination-driven, not a starvation of the spawn pipeline within the observed window. **[O]/[I]**

### 5b. Running sessions with no board row — 0 of 12

Literal id match against all **211** `ses_*` ids in `SWARM_BOARD.md` found a row for **every**
BUSY/RUNNING session. **[O]/[D]** The six newest BUSY sessions (#7–12) sit on explicit
`RUNNING` rows at lines 323–329 (NATION-SPAWN-IMPL-01, HUD-LAYOUT-RUN-01, RELIEF-VISUAL-01,
QA-DESERT-FIX-01, BUILD-STAGE-INTEGRATION-01, QA-SPEED-01); the seventh row in that block,
LOAD-PROBE-RUN-01 / `ses_ded9948acffeUhYcFSDE1ndsVw` (line 325), has already terminated
and must not be counted as live. **[O from file]/[D]** This is a marked
change from `SESSION_COUNT_02.md` §5b, which found **17 of 20** running sessions unlisted. **[D]**

- **Open list of running sessions missing from SWARM_BOARD: none at this snapshot.** **[D]**
- Caveat: the board now *over*-reports liveness. **59 board rows (58 unique session ids)** still
  carry a `RUNNING` label while the DB shows them IDLE/DONE. **[O]/[D]** Examples include
  BUILD-STAGES-01 (idle 11:45:40), DANIM-02 (11:44:53), README-FINAL-01 (11:55:50),
  LOAD-ASYNC-01 (12:09:46), QA-PATCH-VERIFY-01 (12:09:46), and QA-SPEED-01's sibling
  `ses_ded9bde88...` (12:11:26). **[O]** These must not be counted as live. **[D]**

**Net:** the DB shows a live swarm of 12, below the 15–20 directive at the headline instant; the
board's *live roster* is complete for currently-running sessions but still stale for dozens of
terminated ones. **[I]**

## 6. Open questions

1. Is the 12-live reading a transient trough (several long-lived workers still running since
   11:38–12:01) or the start of a sustained wind-down? Counts fell 16 → 13 → 12 in two minutes
   with no new spawns; only a fresh hard-coded query can answer. **[U]**
2. Why does a DB-state replay at 11:44:52 yield 21 BUSY (`ses_deddb4a21...` included) when
   COUNT-02 recorded 20? Does `time_busy` get refreshed on resume after `time_idle` was set?
   The final headline counts are unaffected, but the attribution of the +48 IDLE delta carries
   this one-row ambiguity. **[U]**
3. The directive is phrased both "15–20 agents" and "keep agent count high"/"20+". Is 12 a
   breach to be corrected by a refill wave, or an intentional drain into final gates? **[O from
   file]/[U]**
4. The board is being edited concurrently (159 → 211 unique ids during this check). What will
   its final RUNNING-row set be when COORD stops editing? The 59 stale rows were measured at
   one instant. **[O]/[U]**
5. Should `session_status_check.py` accept an explicit parent id, or default to the parent when
   the ambient session has zero children? Not changed — read-only task. **[I]**

## 7. Summary

- Single coherent read at **12:13:51 local** (`MAX time_updated` **12:13:50**): **220** direct
  children of `ses_dee54b600ffeIJcid56WLwoxnL`, **12 BUSY/RUNNING**, **208 IDLE/DONE**
  (206 `succeeded`, 2 `interrupted`), 0 ARCHIVED/UNKNOWN. **[O]/[D]**
- vs `SESSION_COUNT_02.md` (180/20/160 @11:44:52): **+40 total / −8 BUSY / +48 IDLE**, fully
  explained by 40 observed new spawns, 18 observed terminations of prior-BUSY ids, 2 surviving
  BUSY ids, 10 new BUSY spawns and 30 new spawns already idle. **[O]/[D]**
- Volatility: BUSY 20 → 16 (12:11:49) → 13 (12:13:29) → 12 (12:13:51); no new spawns after
  12:10:52. **[O]**
- **Verdict:** 12 live is **below the owner's 15–20 floor** at the headline instant (it was 16,
  inside the band, two minutes earlier); **0 of 12 running sessions lack a board row**, but 59
  board rows still label terminated sessions RUNNING. **[D]/[I]**
- Immutability: **no workspace mutation** — `mode=ro` DB queries plus this report only. **[O]**
