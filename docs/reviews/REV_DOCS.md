# REV-1 — Status docs review (cold-readability & traceability)

Reviewer: **REV-1** (read-only test/doc desk) · Date: 2026-11-21 · Method: full read of every
`docs/STATUS_*.md` and `docs/RESUME.md`, checked against `docs/STATUS_TEMPLATE.md`,
`docs/DECISION_LOG.md`, `SWARM_BOARD.md`, `SWARM_OPS.md` §5c. Cross-links checked on disk;
decision/token collisions checked by grep (`\bD-\d{2}\b`) across all status docs.

Rubric: **APPROVE** = compliant, nit-level notes only · **WARN** = fixable compliance/notation
gaps · **BLOCK** = structural failure or misleading claim that would change a cold reader's action.

## Scorecard

| Doc | Score /10 | Missing elements | Trace errors | Required fixes | Verdict |
|---|---|---|---|---|---|
| `docs/STATUS_SKIRMISH.md` | 9 | **Decision trace absent** — zero `D-xx` decision ids in the whole file (grep-confirmed); the charter "why" is cited only to `SWARM_OPS.md` §0 (L16-17, L150-152). All 11 other template items present: YAML, 5 badges, 3 alerts, 2 Mermaid (flowchart L41, gantt L129), emoji priority table, task lists, `<details>`, Related footer, cold TL;DR, dense evidence, How to resume. | Bare `D-01` used for the **board ticket** (L8 ghost audit) at **L81, L94, L174, L175, L230, L248** — collides with **decision D-01** ("kill 6 leaked Godot processes", `DECISION_LOG.md:32`, taught as such in `RESUME.md:286`). L230/L248 have board context but still breach the "must" rule. | Add a short "Decision trace" section citing **D-12** (charter), **D-07** (decomp truth for P-30…P-33), **D-03/D-04/D-16** (gates/ownership/runner); replace all six bare `D-01` with `BOARD D-01`. Refresh L256 note that RESUME was "to be created" — it now exists. | WARN |
| `docs/STATUS_GRAPHICS.md` | 8 | Decision trace is **meta-only**: the sole id is `D-19` at **L16** ("this doc traces decisions"); no `D-12` trace for the charter (L137-140 cites `SWARM_OPS.md` §0 only). Otherwise structurally complete: YAML, 5 badges, alerts (IMPORTANT/WARNING/NOTE), 2 Mermaid (flowchart L39, gantt L116), emoji priority table, task lists, `<details>`, Related footer, TL;DR, evidence, How to resume. | Bare `D-01` for the board ticket at **L156** and in board list **L200** (same D-01 decision collision). | Add D-12/D-07/D-11/D-18/D-19 trace rows; change L156/L200 to `BOARD D-01`. Fix broken path `docs/ASSET_AUDIT.md` at **L32, L57, L58, L90** — the file is at repo root `ASSET_AUDIT.md` (L195/L218 cite it correctly). L185 cites generated `app/tests/results/summary.json`, absent on disk — label as "generated at runtime". | WARN |
| `docs/STATUS_AI.md` | 9 | **Decision trace absent** — no `D-xx` decision ids anywhere (grep-confirmed). All structural items present: YAML, 5 badges, 3 alerts, 2 Mermaid (flowchart L43, gantt L122), emoji priority table, task lists, `<details>`, Related footer, TL;DR, exceptionally strong `file:line` evidence, How to resume. | **L171** writes "Board D-01" — right entity, non-conforming notation; rule requires `BOARD D-01`. Otherwise the best disambiguation in the set: **L38-41** explicitly separates board **G-01** (AI audit) from research **RB G-01** (economy capture). DB-01/02/03 (L112/L114/L218) verified to exist in `docs/decomp/DB_SCRIPTS.md:147-149` — correct. | Add decision trace (D-07/D-12/D-17/D-18/D-19; D-06 only if claiming mass-army scale traces to roster scale); change L171 to `BOARD D-01`. Keep the G-01 warning — extend the same treatment to a global collision registry. No broken cross-links found. | WARN |
| `docs/STATUS_DECOMP.md` | 9 | None material. Best-in-set: dedicated **Decision trace** section (L198-218) with `timeline` + table, plus flowchart (L41), gantt (L149) = 3 Mermaid; all 12 template items present. Proactively discloses the one gap (no D-xx for the `.osm` refutation, L312-314). | No decision-id errors: D-07 (Coordinator, L216), D-12 (Owner, L217), D-11 (L113/L314), D-17/18/19 (L218) all match `DECISION_LOG.md`. Reference style `DD_MAPS.md`/`ev_…`/`fnd_…` resolves within `docs/decomp/`. | Optional: reconcile "6 downstream tickets" (**L59, L65**) with the 8 data rows in the LEFT table (**L132-139**, incl. DC T-1…T-6 and DA-1/DA-3); the extra rows are non-board tickets, so say "6 board tickets + 2 research lines". | APPROVE |
| `docs/RESUME.md` (master index) | 8 | Not a `STATUS_*` doc, so emoji-priority table / How-to-resume heading are N/A — it *is* the resume path. YAML, 10 badges, alerts, 4 Mermaid, `<details>` tables, Related footer, TL;DR, D-xx trace section all present. | **L326**: "Disjoint file ownership … D-04, D-05, D-06" — D-05 ("hundreds at once") and D-06 (roster→1000) are about scale, **not** ownership; should be D-04 only. **L362**: D-06 listed among "Coordinator rulings" while **L361** lists D-06 as an Owner decision (correct per `DECISION_LOG.md:37`) — internal contradiction. | Fix L326 (drop D-05/D-06) and L362 (remove D-06). Fix broken `docs/ASSET_AUDIT.md` at **L77** → root `ASSET_AUDIT.md`. L257 cites absent `app/tests/results/summary.json` — mark generated. Refresh stale index: **L212-218** and **L386** still call `STATUS_DECOMP.md` "in progress"; it landed during this review. | WARN |

## Systemic issues

1. **The `D-01` collision is unmanaged across the whole set.** It means both *decision* D-01
   (`DECISION_LOG.md:32`, kill leaked processes) and *board ticket* D-01 (L8 ghost audit,
   `SWARM_BOARD.md:11`). Nine occurrences were found (SKIRMISH ×6, GRAPHICS ×2, AI ×1); **none**
   uses the required `BOARD D-01`. Worse, the authoritative docs teach only the decision meaning
   (`RESUME.md:286`). Same class of hazard, handled well in one place only: the "two `G-01`s"
   (board AI audit vs RB capture gap) is warned about at `STATUS_AI.md:38-41` but not registered
   centrally. Recommend a one-line collision registry in `DECISION_LOG.md` §"How to use this log"
   and a global replace: ticket ids → `BOARD D-01`, decisions → `D-01` (or `DECISION D-01`).
2. **Decision tracing is uneven.** Only `STATUS_DECOMP.md` and `RESUME.md` have real D-xx
   traces. `STATUS_SKIRMISH.md` and `STATUS_AI.md` have none; `STATUS_GRAPHICS.md` cites only
   D-19 meta. D-19 (`DECISION_LOG.md:50`) mandates D-xx citations in *all* status docs — 3 of 5
   docs fail that mandate, typically citing `SWARM_OPS.md` §0 instead of D-12.
3. **Aspirational/generated paths are presented as present.** `docs/ASSET_AUDIT.md` (RESUME L77,
   GRAPHICS L32/L57/L58/L90) does not exist — the file is at repo root. `app/tests/results/summary.json`
   is cited as a live source in all docs and in `STATUS_TEMPLATE.md:105`, but is not on disk (a
   runtime artifact). `STATUS_TESTS.md` is indexed at `RESUME.md:212-218,386` but absent.
4. **RESUME's decision trace has two misattributions** (L326, L362) — because it is the first
   file every cold reader opens, these propagate faster than errors in area docs.
5. **Concurrency drift.** Docs landed while this review ran (STATUS_DECOMP.md and RESUME.md appeared
   between the first and second file listing). RESUME's index is already stale; it needs a refresh
   pass after the docs lane finishes.

## REPORT

- **Docs reviewed:** 5 — `STATUS_SKIRMISH.md`, `STATUS_GRAPHICS.md`, `STATUS_AI.md`,
  `STATUS_DECOMP.md`, `RESUME.md`. (`STATUS_TEMPLATE.md`, `DECISION_LOG.md`, `SWARM_BOARD.md`,
  `SWARM_OPS.md` read as governance references. **`STATUS_TESTS.md` requested in the task does not
  exist** at review time — not reviewed, not scored.)
- **Verdict counts:** APPROVE **1** (`STATUS_DECOMP.md`) · WARN **4** (SKIRMISH, GRAPHICS, AI, RESUME) · BLOCK **0**.
- **BLOCKs with exact file:line:** none. Closest-to-blocking items, all classified WARN because
  surrounding context disambiguates them and all are small, local fixes:
  `docs/STATUS_SKIRMISH.md:81,94,174,175,230,248`; `docs/STATUS_GRAPHICS.md:32,57,58,90,156`;
  `docs/STATUS_AI.md:171`; `docs/RESUME.md:77,326,362`.
- **Files created:** `docs/reviews/REV_DOCS.md` only. No doc, board or code file was modified;
  no Godot run.
- **Open questions:**
  1. Will `STATUS_TESTS.md` land, and which DOC agent owns it (`RESUME.md:386` still asks)? Re-review when it appears.
  2. Should `docs/ASSET_AUDIT.md` citations be repointed to root, or the file moved into `docs/`?
  3. Is `app/tests/results/summary.json` intentionally uncommitted? If so, docs/template should say "generated" rather than cite it as present.
  4. Confirm the fixes to `RESUME.md:326` (D-05/D-06 → D-04) and `RESUME.md:362` (remove D-06 from coordinator list).
  5. Who refreshes RESUME's area-doc index now that `STATUS_DECOMP.md` has landed?
  6. Should `D-01` be renamed/re-scoped in `DECISION_LOG.md` to remove the collision at source, rather than relying on `BOARD D-01` discipline forever?

---

## Reconciliation 2026-11-21 (IMPL-DOCS)

Docs worker **IMPL-DOCS** re-read `SWARM_OPS.md` §0/§5b-QUALITY,
`AGENT_PROTOCOL.md`, `SWARM_BOARD.md`, `DECISION_LOG.md`, `docs/audit/GEN.md`,
`docs/audit/CONFIG_VERIFY.md`, `docs/research/FORECAST.md` and
`STATUS_TEMPLATE.md`, then reconciled the owned status docs against the current
board, the 15 per-feature test verdicts and the deep-audit corrections. No Godot
runs, no `.gd` edits, no edits to `SWARM_BOARD.md` / `DECISION_LOG.md` /
`STATUS_TEMPLATE.md`. Every owned file was backed up to
`inbox/backup/<name>.bak-IMPL-DOCS` before editing.

### Findings fixed

| Review finding | Fix applied | Where |
|---|---|---|
| **D-01 collision** (systemic #1; SKIRMISH ×6, GRAPHICS, AI) | Board-ticket references now written **BOARD D-01**; decision D-01 (kill 6 leaked Godot processes) kept distinct and a collision note added to each doc's decision trace | `STATUS_SKIRMISH.md`, `STATUS_GRAPHICS.md`, `STATUS_AI.md`, `RESUME.md` |
| **Uneven decision tracing** (systemic #2; D-19 mandate) | Real `D-xx` traces added; every status doc now cites **D-23** (release gate PASS) and **D-24** (320 map size); D-07/D-12/D-17/D-18/D-19/D-20/D-22 also cited | all five `STATUS_*.md`, `RESUME.md` |
| **`docs/ASSET_AUDIT.md` broken path** (systemic #3) | Repointed to repo-root `ASSET_AUDIT.md` | `STATUS_GRAPHICS.md` (4 sites), `RESUME.md` |
| **`summary.json` presented as present** (systemic #3) | Labelled "generated at runtime by `test_all.py`"; 14 per-test JSONs cited instead | `STATUS_TESTS.md`, `STATUS_GRAPHICS.md`, `RESUME.md` |
| **`STATUS_TESTS.md` absent from index** (systemic #3, open Q1) | Document landed and linked directly; index note refreshed | `RESUME.md` §5 |
| **RESUME L326 misattribution** (systemic #4) | Ownership rule now cites **D-04 only** (D-05/D-06 are scale decisions) | `RESUME.md` §8 |
| **RESUME L362 internal contradiction** (systemic #4) | D-06 removed from coordinator list; D-22 moved to Owner list; D-23 added to Desk list | `RESUME.md` §9 |
| **Stale release gate (FAIL / "runner deadlock" / "UNSIGNED")** | Updated to **PASS (D-23)** — fresh O5 jobs #149–152 — across every doc; older FAIL sections marked superseded history | all five `STATUS_*.md`, `RESUME.md`, `FORECAST.md` |
| **Stale map size "160x160"** (P-49, deep-GEN Q) | Set to **320 working size (D-24)** with the `s`/`area_scale`/`mscale` coupling documented | `app/scripts/MAPGEN_STATUS.md:71`, `STATUS_SKIRMISH.md`, `RESUME.md`, `FORECAST.md` |
| **Deep-audit corrections not reflected** | Added GEN forest-fleck/cliff branches (P-46/P-47), CONFIG_VERIFY ignored-teams confirmation (P-42), DECOMP formation correction (P-30/P-37/P-38) | `STATUS_SKIRMISH.md`, `STATUS_GRAPHICS.md`, `STATUS_AI.md`, `STATUS_DECOMP.md` |
| **Test verdicts missing/stale** | 14 result JSONs summarised as **8 green / 6 red / 1 pending (08:55 snapshot; live churn)** (`t_weather`); area-level green/red named | all five `STATUS_*.md`, `RESUME.md` |
| **Board drift** | P-40…P-49, P-42 BLOCKED and DONE/partial states folded into DONE/LEFT tables; `FORECAST.md` gained §1b board snapshot (~60 open of 72 rows) | `STATUS_SKIRMISH.md`, `STATUS_AI.md`, `RESUME.md`, `FORECAST.md` |

### Remain open

1. **D-01 rename at source** — `DECISION_LOG.md` still names the decision D-01;
   the `BOARD D-01` discipline is documented in four docs but the collision is not
   removed at source. Coordinator-owned file — intentionally not edited.
2. **`summary.json` still uncommitted** — now correctly labelled "generated";
   14 `<id>.json` files are on disk; `summary.json` appeared mid-pass as a partial
   (`count: 1`) generated aggregate. Whether to commit a full aggregate is an
   owner decision.
3. **Test-verdict figure is a moving target** — at pass start the 14 JSONs read
   **4 green / 10 red / 1 pending**; by 08:55 concurrent re-runs (IMPLSIM /
   IMPSHELL / IMPRENDER) moved them to **8 green / 6 red / 1 pending**; the task
   brief said **5/9/1**. `t_weather` is the only stable PENDING. All docs now
   carry a dated snapshot plus a pointer to `app/tests/results/*.json` as the live
   source of truth. Also note `summary.json` appeared mid-pass with `count: 1`
   (a partial `t_audio_events` run), so it is not an aggregate of all 15.
4. **`t_weather` pending** — genuine compile bug (`PackedByteArray.hash()` at
   `app/tests/t_weather.gd:145,149,156`, REV-2 BLOCK). No result JSON.
5. **P-48 method discrepancy** — board/audit HAND-OFF B-2 prescribed scan radius
   **5→6**, but the seed-8 distance table (iron at exactly 10.0 m; only 15/18
   deposits beyond 12 m) shows that change **regresses clear 94%→83%**. IMPL-DOCS
   applied the inclusive-boundary fix (`>`→`>=`) in `scan_map.py:76`, achieving the
   predicted **94%→100%**. Board P-48 and `docs/audit/GEN.md` §6.2 need updating.
6. **Board/DECISION_LOG/TEMPLATE untouched** — per ownership; P-04 still reads
   BLOCKED on the board although selftest is 29/29 (D-21/D-23 reconcile the docs).
7. **Concurrency drift** — checks are a 2026-11-21 snapshot; live board state may
   have moved during this pass.

### Report

- **Owned files backed up and edited:** `app/tools/scan_map.py`,
  `app/scripts/MAPGEN_STATUS.md`, `docs/STATUS_SKIRMISH.md`,
  `docs/STATUS_GRAPHICS.md`, `docs/STATUS_AI.md`, `docs/STATUS_TESTS.md`,
  `docs/STATUS_DECOMP.md`, `docs/RESUME.md`, `docs/research/FORECAST.md`,
  plus this append to `docs/reviews/REV_DOCS.md`.
- **Verification:** `python app/tools/scan_map.py --dir scans` (pure Python; no
  Godot) before/after — seed-8 `clear 94` RED removed, reach 6/6, remaining REDs
  are patches/mean and seed-9 cliff (P-46/P-47). No runner jobs used.
