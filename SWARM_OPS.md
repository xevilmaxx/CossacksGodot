# Swarm Operations — Cossacks 3 → Godot port

Operating model for the coordinated agent swarm. This is the source of truth for
roles, ticket states, and merge gates. Individual workers read
`app/tools/AGENT_PROTOCOL.md` for mechanical rules; this file defines the org.

## 0. Product charter (owner decision, 2026-11-21)

**In scope — this is "a good port":**
- Random skirmish maps, true seed variety, multiple AI opponents / teams on one
  map, and skirmish-only options (map type, size, richness, relief, season).
- All gameplay features available in a DONOR SKIRMISH: unit/building/upgrade
  roster, formations, squads, morale, economy, capture, AI behaviour — at least
  donor-equivalent, preferably better.
- Maximum graphics fidelity: donor-accurate sprites/metrics, smoke and effects,
  shadows, water, weather/seasons, decor, HUD fidelity, large-army scale.
- Performance that holds up with mass armies on weak GPUs.

**Deferred (do NOT spend build-lane slots):**
- Missions, campaigns, `.aix` triggers, `.map` mission geometry, all DLC mission
  packs, cutscenes/cinematics, and network/multiplayer. These stay documented
  as deferred, not as active tickets.

**Consequence:** research/decompilation output is filtered through this charter.
Generator, gameplay script, rosters, formats and visual truth are valuable;
mission-map RE and campaign triggers are parked. Any worker whose task is
deferred must be re-tasked, not merely left running.

## 1. Org chart

| Role | Workers | Authority |
|---|---|---|
| Coordinator | the primary agent | intake, assignment, file-ownership arbitration, final merge |
| Builders | A–L | implement assigned tickets inside their owned files only |
| Review | M | **read-only** gate: reviews every diff, can BLOCK merge |
| Review (test/doc desks) | REV-1…REV-3 | read-only review of new small tests, status docs and improvement proposals |
| Improvers | IMP-1…IMP-3 | propose scoped "better than donor" upgrades to skirmish AI, graphics and UX; no code edits unless granted |
| Feature triage | N | turns requests into tickets with acceptance criteria; no code edits |
| QA / release gate | O | runs the full acceptance suite through the runner; signs releases |
| Compliance | folded into M | private-use licence, protocol adherence, no direct `godot` calls |

## 2. Ticket lifecycle

```
INTAKE → TRIAGED → ASSIGNED → IN_PROGRESS → REVIEW → QA → DONE
                                    │           │      │
                                    └── BLOCKED ─┴──────┘
```

- **INTAKE** — request logged in `SWARM_BOARD.md` by the coordinator.
- **TRIAGED** — N adds scope, acceptance criteria, risk, and priority (P0–P3).
- **ASSIGNED** — coordinator grants exclusive ownership of named files.
- **IN_PROGRESS** — builder works; all Godot runs via `godot_runner.py`.
- **REVIEW** — M reviews the diff. Any protocol violation or unowned-file edit
  blocks the ticket. M never edits code.
- **QA** — O runs selftest (29/29), uitest (17/17), CLI soak, and the relevant
  screenshot through the runner. Any red gate blocks release.
- **DONE** — coordinator merges the ticket into the board's done column.

## 3. Non-negotiable gates

1. **One Godot at a time.** Every launch goes through
   `python app\tools\godot_runner.py run --id <worker>-<purpose> --timeout <s> -- <args>`.
2. **Disjoint file ownership.** A file belongs to exactly one active ticket.
3. **Backup before edit.** `inbox\backup\<name>.bak-<worker-id>`.
4. **Green before review.** `app/selftest.json` 29/29 and `app/uitest.json`
   17/17 must pass after every code change.
5. **No redistribution.** Donor assets (`C:\Games\Cossacks 3`) are private-use
   only. Never copy, upload, or publish them.
6. **Minimal diffs.** No "improvements" beyond the ticket. No renames of
   functions/fields other scripts call.

## 4. Board

Live ticket state lives in `SWARM_BOARD.md`. Only the coordinator edits the
state column; workers report status and the coordinator updates it.

## 5. Capacity policy (AAA scale)

- **Roster size: 1000 tickets (scaled x10 from 100).** The active backlog holds
  up to 1000 small, independently assignable tickets (one file or one donor
  family each), populated from worker findings and the RA–RE research reports.
- **WIP limit: 20 live workers.** At most 20 builders/reviewers/QA are active at
  once. This is a Kanban work-in-progress limit, not a cap on throughput: as a
  ticket reaches DONE, the next roster ticket is assigned to the freed slot.
- **Why not 100 concurrent editors:** there are ~166 assignable source files, but
  Godot is a single serialized resource behind `godot_runner.py`, and the core
  simulation (`game.gd`) is one file. Running 100 live agents would multiply
  context/cost and notification load without increasing real parallelism.
  A roster of 100 with WIP 20 gives the same coverage with bounded wait times.
- **Godot queue is the throughput throttle.** Every test job is a FIFO ticket in
  the runner. `max wait` in its telemetry is the anti-starvation SLA.

## 5a. Decompilation lane (parallel, no runner cost)

Decompilers (DA–DE) use Craft Anything against the installed donor at
`C:\Games\Cossacks 3` to turn closed formats and scripts into documented,
evidence-backed port knowledge. They never run the donor, never copy donor
files into the repo, and do not use the Godot runner. Only the coordinator
writes the shared Craft Anything brief/plan/handoff; decompilers use read tools
and `core_finding_record`, then write their own `docs/decomp/*.md` reports with
evidence ids. The donor `cossacks.exe` is a stripped, likely-packed 32-bit PE
(Delphi/C++Builder markers, `.bind` section entropy 7.96) — expect limited
static decompilation value and prioritise text scripts and asset formats.

## 5b. Research lane (parallel, no runner cost)

Web-research agents (RA–RE) are a separate lane: they use web search/fetch only,
never launch Godot, never edit game code, and never download donor assets into
the repo. They produce gap analyses under `docs/research/` with cited sources
and a worker estimate per gap. Because they do not contend for the Godot runner
or source files, they run outside the WIP-20 build limit.

## 5b-QUALITY. Quality-first protocol (owner directive, 2026-11-21)

The owner explicitly asked for a **deep, unhurried analysis** of every
implementation and decompilation. Breadth stops here; the following rules
override the earlier "ship waves" tempo:

1. **Evidence before edits.** No speculative fixes. Every change must cite a
   donor file/constant, a runner result, or a decompilation evidence id.
2. **Independent re-verification.** A finding is not accepted until a second
   agent (or the same agent via a different method) confirms it. One grep is
   not proof; one passing test is not proof of fidelity.
3. **Separate observation from inference.** Use `observed` / `derived` /
   `inferred` labels exactly as Craft Anything does; never promote an inference
   to a fact because it is convenient.
4. **No "good enough".** A port claim must name its acceptance evidence. If it
   cannot be measured, mark `UNVERIFIED`, not `done`.
5. **Deep-audit outputs** go to `docs/audit/<AREA>.md` with a claim table:
   claim | evidence | verification method | verdict | required correction.
6. **Configurability and efficiency are required in the final port but are a
   LATER tranche** (owner: "quality first"). Capture them in the audit docs as
   explicit future tickets; do not sacrifice fidelity for speed now.

## 5c. Documentation lane (parallel, no runner cost)

Documenters (DOC-1…) turn worker reports into durable, readable markdown. They
never edit code, never run Godot, and never re-derive facts from scratch — they
cite existing reports, board entries, runner results and evidence ids.

Every area gets one `docs/STATUS_<AREA>.md` following `docs/STATUS_TEMPLATE.md`:
current state, what is DONE, what is LEFT with criticality P0–P3, owners,
acceptance gates, evidence, and a "How to resume" section. `docs/RESUME.md` is
the master index. An area doc must be readable cold by a human or a fresh agent
with no prior context.

## 6. Why the queue works this way

Godot is a single shared resource, so the runner serializes it with a FIFO
ticket lock. Workers are the parallel resource; files are partitioned so they
never contend. Review and QA are separate desks so nobody reviews their own
work. That is the whole design: **parallel people, serialized tools, gated
merges.**
