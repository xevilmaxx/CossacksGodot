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
