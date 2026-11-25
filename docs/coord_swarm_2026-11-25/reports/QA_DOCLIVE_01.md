---
title: QA-DOCLIVE-01 — living-docs reconciliation QA (read-only)
area: coordination / documentation QA
ticket: QA-DOCLIVE-01
session: ses_dedbedadfffezftdXZw2t7S4St
parent: ses_dee54b600ffeIJcid56WLwoxnL (COORD)
owner: COORD (verdicts); QA-DOCLIVE-01 (this report only)
author: QA-DOCLIVE-01 subagent
updated: 2026-11-25
status: complete
read_only: true — no doc/code edits, no runner jobs
labels: observed | derived | inferred | UNVERIFIED
snapshot_read: 2026-11-25 ~11:37 local (living docs; line numbers may drift)
---

# QA-DOCLIVE-01 — verify the living docs after the latest reconciliation edits

Read-only QA. This file is the **only** artefact produced; no living doc, source file or
runner job was touched. All line numbers are from a final re-read at ~11:37 local
(`SWARM_BOARD.md` re-read 11:37:29; `CORRECTIONS.md` / `README.md` / `PROGRESS.md` /
`GAPS.md` re-read 11:37:54–57). The board changed twice during this QA, so re-read before
acting on any line citation.

## Sources

| Source | Lines / scope used | Label |
|---|---|---|
| `docs/coord_swarm_2026-11-25/SWARM_BOARD.md` | live-session section `:14-33`; CFG-01 `:85`, `:109`; LIGHT-02 `:140`, `:208`; README-UPDATE-01 `:263`, `:282`; INVENTORY-01 `:265`, `:288`; CONFIG-DOC-01 `:275`, `:278`; Batch S `:234-257`; Batch O `:268-300` | observed |
| `docs/coord_swarm_2026-11-25/PROGRESS.md` | gates section `:184-200` (governance note `:186-190`, selftest row `:194`); decisions `:164-182`; QA-AUDIT log `:97-103` | observed |
| `docs/coord_swarm_2026-11-25/CORRECTIONS.md` | rows 57–60 `:105-109`; duplicate-chain notice `:111-115`; UNVERIFIED section `:117-139`; Summary `:169-180` | observed |
| `docs/coord_swarm_2026-11-25/README.md` | `:49`, `:118`, `:168`, `:194` (count); snapshot caveat `:137-156`; gate tables `:178-217` | observed |
| `docs/coord_swarm_2026-11-25/GAPS.md` | §1 `:15-25`; §2 `:27-44`; §3 watchlist `:46-61`; §4 confidence legend `:63-67` (`status: draft` at `:6`) | observed |
| `%TEMP%\opencode\session_status_check.py` | read-only SQLite helper (`mode=ro`), invoked with `OPENCODE_SESSION_ID` set to the COORD parent id | observed |
| `C:\Users\Maxym.Oboyshev\.local\share\opencode\opencode.db`, `session_v2` | direct children of COORD; `time_busy` / `time_idle` / `idle_outcome` / `time_updated` | observed |

**Method note (observed):** running the helper as this subagent returns `current:
ses_dedbedadfffezftdXZw2t7S4St`, `children: 0` because it filters on the *invoking* session.
Re-running it with `OPENCODE_SESSION_ID=ses_dee54b600ffeIJcid56WLwoxnL` (COORD, `parent_id =
NULL`, title `3D variant development tracking`) reproduces the authoritative query. This
exact caveat is already documented at `SWARM_BOARD.md:19-21`.

## Checks

| # | Check | Verdict | Exact line evidence | Label | Finding |
|---|---|---|---|---|---|
| (a) | Authoritative live-session section lists exactly the sessions currently BUSY | **OPEN** | `SWARM_BOARD.md:14` header is now "real-time method and snapshot"; `:23-27` gives one timestamped snapshot (11:32:51: 156 children / 137 IDLE / **19 BUSY**) and `:26` says counts "are inherently perishable; re-run the query before acting on them rather than trusting a static list". No session IDs are listed at all. Helper re-run at 11:35:34 returned `children: 160`, `BUSY_COUNT=21` (an intervening 11:34 read returned 23). | observed (file + DB); derived (drift 19→21/23) | The stale static ID list was correctly **removed** — that part of the reconciliation is sound. But the literal criterion is not met: nothing "lists exactly the sessions currently BUSY", and the embedded count is already stale. Set churns live (QA-BOARDLIVE-01 and PROP-W-PLAN-01 were BUSY at 11:34, gone by 11:35:34). |
| (b) | No duplicate CFG-01 / LIGHT-02 / CONFIG-DOC-01 / README-UPDATE-01 / INVENTORY-01 rows with conflicting states | **CONFIRMED** | CFG-01: one row `:85` **DONE** + removal comment `:109`. LIGHT-02: one row `:140` **DONE** + removal comment `:208`. CONFIG-DOC-01: one row `:278` **DONE** + removal comment `:275`. README-UPDATE-01: `:263` **DONE** (authoritative Batch R) and `:282` **DONE — TERMINATED** ("duplicate of authoritative Batch R row"), same session `ses_deddede29ffep3WHPBG8kRHQYW`. INVENTORY-01: `:265` **DONE — TERMINATED** ("duplicate of authoritative Batch O row") and `:288` **DONE**, same session `ses_dedd0b783ffeXGxtcSZa3SbA9o`. | observed | No conflict: the three removed duplicates exist only as HTML comments; the two surviving pairs are explicitly cross-annotated, share one session id, and both states mean *complete* (DONE vs DONE—TERMINATED). DB confirms both sessions `IDLE/DONE`, `succeeded`. |
| (c) | CORRECTIONS summary count equals max row id | **CONFIRMED** | Table rows are ids 1–60 contiguous; max id **60** at `CORRECTIONS.md:109`; Summary `:171` reads "**60 indexed corrections** across binaries, scripts, configs, terrain, maps, cameras, …". | observed + derived | Count and max id agree at 60. Rows 57–60 are `:105` (CFG-01/DEFAULTS-VERIFY refutation), `:107` (root files 24), `:108` (map field 55/32), `:109` (`.inc` 455/313). Duplicate-chain notice `:111-115` correctly names rows 14/51 and 28/52 as authoritative-later/claim-trail pairs. |
| (d) | README's corrections count matches CORRECTIONS | **OPEN** | `README.md:49` "**57 rows**"; `:118` "**57-row** donor corrections index"; `:168` "Canonical **57-row**"; `:194` "**57** indexed corrections". `CORRECTIONS.md:171` says **60**; rows 58–60 at `:107-109` post-date the README value. | observed | Numerically stale by 3. Secondary drift: README cites `CORRECTIONS.md:100-105,159-170` at `:49/:118/:168/:194`, but rows 51–60 now occupy `:98-109` and the summary is `:169-171`. |
| (e) | PROGRESS gate table no longer claims integrated LIVE 29/29 | **CONFIRMED** | `PROGRESS.md:184` header "Gates status (PER-JOB artifacts vs INTEGRATED state — audit-corrected…)"; `:186` "'LIVE' was too strong"; `:188` "integrated … 26/29 (HEAD) / 28/29 (worktree) … A per-job 29/29 does not imply the integrated tree is green; only the final gate reserved to COORD can claim that." | observed | The word LIVE appears only in the *rejection* of the old claim; the integrated state is explicitly 26/29 / 28/29. No integrated-LIVE claim remains. |

### Residual findings (related, not part of the five checks)

| Finding | Verdict | Evidence | Label |
|---|---|---|---|
| `PROGRESS.md:194` still bolds "**29/29 repeatedly**" in the "This session (measured)" cell with no inline "per-job only" qualifier (it does cite per-job jobs 312/337 and says "final gate still reserved for COORD"). | OPEN (clarity) | `PROGRESS.md:194`; governance note `:186-190` | observed |
| README still describes PROGRESS as *contradicted* and mis-cites the line: "`PROGRESS.md:188` claims 29/29 repeatedly" — but `:188` now states 26/29 / 28/29; the bold phrase is at `:194`. | OPEN (cross-doc drift) | `README.md:137-144`, especially `:143`; `PROGRESS.md:186-194` | observed |
| `GAPS.md` remains `status: draft` (`:6`) while §2 carries late-wave LIGHT-02 / TERRAIN-DARK-FIX / season findings (`:35`, `:41-42`). No conflict with the five checks; housekeeping question only. | OPEN (minor) | `GAPS.md:6`, `:35`, `:41-42` | observed / inferred |
| `SWARM_BOARD.md:23-27` snapshot is self-labelled perishable; no correction is required for that design choice. | CONFIRMED | `SWARM_BOARD.md:23-27` | observed |

### DB snapshot detail for check (a) — observed, 11:35:34

`children: 160`, `BUSY_COUNT=21`. IDs below are mapped to board rows; 4 are the old
"authoritative" set, 17 are later Batch S/O/K waves, and one is this QA worker itself:

| Session | Board ticket / line |
|---|---|
| ses_dede47f36ffeaGALXfX3VRRfEG | AUDIO-SEL-02 `:272` |
| ses_deddede28ffePAlAptFGEy4kzn | PERF-3D-01 `:283` |
| ses_dedd5c6b9ffebY8CjZ2LHhmm8U | SEASON-TEST-PATH-01 `:290` |
| ses_dedbf5c9dffe4mdGt2dTO77GT1 | RECHECK-P0-01 `:238` |
| ses_dedbf5c9cffeJGUuUd4kuM4BPJ | RECHECK-S1-01 `:239` |
| ses_dedbf5c7bffdpJAj2a51MOZJ02 | QA-LINKS-02 `:242` |
| ses_dedbf5c78ffePdQ3lag7ysrYYr | DBUILD-02 `:243` |
| ses_dedbf5c76ffeCAAq15b0by5BNk | DONAVAL-02 `:244` |
| ses_dedbf5c74ffeDLQM3IjgeRqqcQ | QA-ATOM-STALE-02 `:245` |
| ses_dedbedb1effe077PkS0kvUcbKo | BUILD-STAGES-01 `:246` |
| ses_dedbedb1dffeTXMw40zNTmaHX1 | FIELD-WINTER-01 `:247` |
| ses_dedbedb1affeEuwiV0mWCxioor | MORALE-PLAN-01 `:248` |
| ses_dedbedaf9ffejr3WE6IIQbhDuF | FINAL-CHECKLIST-01 `:249` |
| ses_dedbedaf1ffeK1luRvYOin2v5Y | QA-CLEAN-02 `:250` |
| ses_dedbedae6ffeRQKk1qsDCty2Xk | DENV-02 `:251` |
| ses_dedbedae2ffeMiBmZSUTxXJ7z7 | DANIM-02 `:252` |
| ses_dedbedadfffezftdXZw2t7S4St | QA-DOCLIVE-01 `:253` (this worker) |
| ses_dedbb6506ffeTpu8SKK3Bt4lkC | GATE-FAIL-01 `:254` |
| ses_dedbb6505ffe0cw9EmKYeTG6zY | QA-RUNNER-ARTIFACTS-01 `:255` |
| ses_dedbb6501ffe1KC3EJCm7QQShu | README-FINAL-01 `:256` |
| ses_dedbb64faffevvN1Imbet9JkuQ | SESSION-STATUS-FINAL-01 `:257` |

Not BUSY at 11:35:34 but BUSY at 11:34: `ses_dedbf5c7fffdEM7oUSBra4zAKe`
(QA-BOARDLIVE-01, `:241`) and `ses_dedc825dfffe65At77RG2CJO98` (PROP-W-PLAN-01, `:293`)
— direct evidence of perishability. **UNVERIFIED:** the final count at gate time.

## Verdict

**PARTIAL — 3 CONFIRMED (b, c, e), 2 OPEN (a, d), plus 3 residual clarity items.**
The reconciliation edits are structurally sound: duplicates are merged/annotated,
CORRECTIONS is internally consistent at 60, and the PROGRESS gate table no longer asserts
an integrated LIVE 29/29. The two open items are pure count/snapshot drift in the README
and the live-session snapshot, both already self-flagged as perishable in the docs. No
prohibited state (DONE vs RUNNING) was found in any of the five audited duplicate rows.

## Open questions

1. **What is the authoritative BUSY count for sign-off?** (UNVERIFIED) The DB is live;
   19 (board `:24`), 23 (11:34 read) and 21 (11:35:34 read) were all observed within
   minutes. `SESSION-STATUS-FINAL-01` (`:257`, RUNNING at 11:37) is the likely closer.
2. **Will `README-FINAL-01` (`:256`, RUNNING at 11:37) fix 57→60?** (inferred from its
   scope "refresh README with final reconciliations"; outcome UNVERIFIED). If it lands
   after this QA, edits 1–2 below may already be applied — re-read first.
3. **Should the "29/29 repeatedly" cell at `PROGRESS.md:194` be relabelled per-job?** (OPEN;
   `README.md:143` currently calls it contradicted, which is itself stale).
4. **Is `GAPS.md:6` `status: draft` intentional?** (observed + inferred; no evidence it
   was part of this reconciliation).

## Recommended exact COORD edits (NOT made by this QA)

1. `README.md:49,118,168,194` — replace **57** with **60**; change the citation
   `CORRECTIONS.md:100-105,159-170` to `CORRECTIONS.md:98-109,169-171` so it covers rows
   51–60 and the Summary line. Suggested wording at `:49`: "**60 rows** (DOC-03 snapshot
   50; rows 51–60 landed since — `CORRECTIONS.md:98-109,169-171`)".
2. `README.md:141-144` — rewrite the stale sentence so it reflects the *corrected* PROGRESS:
   "…and is now **audit-corrected** — the gate header at `PROGRESS.md:184` is 'PER-JOB
   artifacts vs INTEGRATED state', the note at `:186-190` rejects 'LIVE' and records 26/29
   HEAD / 28/29 worktree; the bold '29/29 repeatedly' at `:194` refers to per-job jobs
   312/337 only." This removes the wrong `PROGRESS.md:188` citation.
3. `PROGRESS.md:194` — inline qualifier for the measured cell: "**per-job 29/29** (jobs
   312, 337; 320² control 322); **integrated 26/29 HEAD / 28/29 worktree** (`QA_AUDIT_01`);
   final gate not run".
4. `SWARM_BOARD.md:23-27` — **no edit needed**; keep the method-first, self-labelled
   perishable snapshot. Explicitly **do not** reintroduce a static session-ID list.
   If a refresh is wanted, let `SESSION-STATUS-FINAL-01` supply it with a new timestamp.
5. `CORRECTIONS.md` — **no edit needed** (count already 60). Optionally add a one-line
   pointer in §"How to use this index" that README still carried 57 until README-FINAL-01
   lands, but do not duplicate the count in two files.
6. `GAPS.md` — no edit for this QA; decide `status: draft` at `:6` separately.

## Summary

Five checks: **3 CONFIRMED / 2 OPEN**. Row-duplicate discipline (b), CORRECTIONS count
(c) and the PROGRESS "LIVE" correction (e) all pass. README's corrections count is 57 vs
CORRECTIONS' 60 (d), and the live-session section no longer lists BUSY sessions and its
19-session snapshot has drifted to 21–23 (a). Both are stale-number issues with exact
lines identified above; neither requires a code change. All findings are labelled
observed / derived / inferred / UNVERIFIED; the final gate remains COORD-only and the
integrated selftest remains NOT GREEN (`PROGRESS.md:186-190`, `README.md:203`).
This QA stayed read-only: no living doc, code file or runner job was modified.
