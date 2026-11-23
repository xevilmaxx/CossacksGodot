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

## 5d. Worker liveness protocol (owner directive 2026-11-21)

The owner asked for PERIODIC checks so a slow or stuck worker is found and
unblocked instead of silently consuming time. Apply this on every notification
and at least every few minutes while a wave is running:

1. **Check** `python app\tools\worker_health.py --stall-min 10`. It reports, per
   board owner: last owned-file edit, last runner result, pending tickets, and
   a `STALLED` flag when all are quiet.
2. **Interpret** before acting: a quiet worker may be reading donor files or
   reasoning. `pending_jobs > 0` means it is in the FIFO, not stuck.
3. **Ping** any `STALLED` worker with a short status request (what are you
   doing, what are you blocked on, do you need an API/file-ownership grant).
4. **Unblock**, don't take over: fix shared-state problems (parse errors, dead
   lock, stale `now_serving`, missing declared static, file-ownership clash),
   grant a specific file if needed, or re-submit a lost job. Never silently
   duplicate or revert another worker's in-progress edit.
5. **Watch for cross-worker breakage**: one worker's unparseable file makes
   everyone's gates fail with `Failed to compile depended scripts`. Attribute
   the failure to the OWNER OF THE PARSE ERROR, not to the unlucky tester, and
   tell the tester not to revert correct work.
6. **Escalate** if a worker is quiet > 20 min with no pending job and no reply:
   re-assign its remaining ticket to a fresh worker with disjoint files.

## 6. Why the queue works this way

Godot is a single shared resource, so the runner serializes it with a FIFO
ticket lock. Workers are the parallel resource; files are partitioned so they
never contend. Review and QA are separate desks so nobody reviews their own
work. That is the whole design: **parallel people, serialized tools, gated
merges.**

## 7. Recursive swarm model (owner directive 2026-11-23 — T6 wave onward)

The owner asked for an **infinite recursive tree of mini-agents**: every
subagent may spawn its own helpers, every helper may spawn its own children,
and every parent periodically supervises its children so nothing gets stuck.
This section overrides the flat WIP-20 model for the T6 wave. The non-negotiable
gates (§3), quality-first rules (§5b-QUALITY) and the runner door (§3.1) stay in
force at EVERY depth of the tree.

### 7.1 Tree structure

```
Coordinator (primary agent — owns SWARM_BOARD.md, SWARM_OPS.md, final merges)
└── Lane parent (one per lane: TERRAIN, UNITS, WATER, RUST, RESEARCH, QA)
    ├── Micro-worker (ONE micro-task, ONE owned output set)
    │   ├── Helper (a still smaller piece: one measurement, one frame check…)
    │   └── Helper …
    └── Micro-worker …
```

- **Micro-task rule:** a ticket must be small enough that one worker can finish
  it in one sitting: ONE piece, ONE unit family, ONE file, ONE question. If a
  worker finds its task is bigger, it splits it and spawns children instead of
  growing the diff.
- **Fan-out:** a parent spawns as many children as its micro-task list needs.
  Prefer many tiny children over few big ones. Practical guidance: ≤ 8 direct
  children per parent at once; go deeper (grandchildren) rather than wider when
  a child's task is still compound.
- **Piece-before-whole rule (owner):** every helper tests ITS OWN simple piece
  (headless render + measurement + visual A/B) BEFORE any whole-system test.
  Whole-map / whole-roster / full-suite tests happen only at integration tickets,
  after the pieces pass. Never bake everything together first.

### 7.2 Models

| Role | Model reference | Notes |
|---|---|---|
| Lane parents | `opencode-go/hy4-flash-free#high` | orchestration variant |
| Micro-workers / helpers | `opencode-go/hy4-flash-free` | **PREFERRED** (owner directive 2026-11-23): the `opencode-go` provider pool; `opencode/hy4-flash-free` hit "Free usage limit reached" — use it only as secondary |
| Escalation (worker struggled ≥ 2 attempts, quota-blocked, or a task needs deeper reasoning) | `opencode-go/muse-spark-1.3-contributor#high` | parent re-spawns the SAME micro-task with this model |

Spawn children with the `subagent` tool: `agent: "general"`, `model` as above.
Children are background sessions: the call returns a `sessionID` immediately and
a notification arrives when the child goes idle. **Pass the returned sessionID
to follow up** with a specific child (status ping, unblock, new instructions).

**Observed runtime constraints (2026-11-23, WATER lane — binding for all lanes):**

1. **The `subagent` tool is NOT exposed inside child sessions.** Only the
   coordinator has it. Parents below the coordinator spawn their children as
   background OpenCode CLI sessions instead:
   `opencode run --agent general --model <model-ref> --session <unique-id> --title <title> --auto <prompt-text>`
   (prompt as a positional argument read from a file, NOT a `--prompt` flag;
   run it as a background shell job and tee output to a log file). Follow-ups
   to a child = another `opencode run --session <same-id>` with the new message.
   Record every child session id + log path in the lane doc.
   **Alternative (TERRAIN lane demonstrated):** create real subagent sessions
   through the OpenCode server API with `parentID` = the lane session,
   `agent: general`, `subagent: allow` — this preserves recursion natively.
   Either mechanism is acceptable; record which one the lane uses.
2. **Free-tier quota:** `opencode/hy4-flash-free` can return "Free usage limit
   reached". That counts as a failed spawn attempt; after 2 failures escalate
   the SAME micro-task to `opencode-go/muse-spark-1.3-contributor#high`
   (§7.3.4). Do not burn attempts retrying a quota-blocked model.
3. **This host is Windows:** the Python command is `python` (3.14), NOT
   `python3` (the Microsoft-Store alias trap). Blender is at
   `"C:\Program Files\Blender Foundation\Blender 5.2\blender.exe"` (not on PATH).
   Put both facts in every child prompt.

### 7.3 Parent supervision loop (anti-stuck, owner requirement)

Every parent, on each child notification AND at least every few minutes while
its lane is running:

1. **Check outputs, not promises:** read the child's report doc / output files.
   A child that went idle with no output file is suspect.
2. **Ping** quiet children with a short follow-up (what is done, what is
   blocked, what file/permission is needed). `pending` runner jobs = healthy
   queue wait, NOT stuck (§1b of AGENT_PROTOCOL).
3. **Unblock, don't take over:** grant a file, resolve an ownership clash,
   re-submit a lost runner job, or split the task smaller.
4. **Escalate:** a child that fails the same micro-task twice, or is silent
   > 20 min with no pending job and no reply, is re-spawned as a fresh session
   on `opencode-go/muse-spark-1.3-contributor#high` with the same owned files
   and the failed attempt's report attached as context.
5. **Aggregate:** the parent keeps its lane doc current (see 7.4) so the
   coordinator can read lane state cold at any time.

The coordinator runs the same loop over lane parents, plus
`python app\tools\worker_health.py --stall-min 10` and
`python app\tools\godot_runner.py status`.

### 7.4 Reporting tree (docs, cold-readable)

- Coordinator: `SWARM_BOARD.md` (state column — coordinator only), `docs/T6_WAVE_PLAN.md`.
- Lane parent: `docs/t6/<LANE>_LANE.md` — micro-task table (id, child session,
  owned files, state, evidence), updated on every child report.
- Every worker (any depth): `docs/t6/reports/<TICKET-ID>.md` — claim table with
  `observed` / `derived` / `inferred` labels, evidence paths, PASS/FAIL per
  acceptance criterion, open questions. Written BEFORE reporting done.
- No worker below the coordinator edits `SWARM_BOARD.md`, `SWARM_OPS.md`,
  `AGENT_PROTOCOL.md` or another lane's files.

### 7.5 Ownership and interference rules at depth

1. **Disjoint outputs:** each micro-worker owns exactly the files named in its
   ticket (new files preferred: `app/tools/pieces/<name>.py`,
   `app/tools/unit_bakers/<family>.py`, `rustport/**`, one report doc).
2. **Shared code is READ-ONLY below integration level.** `terrain_piece_render.py`,
   `bake_sprites.py`, `world.gd`, `game.gd`, `water_overlay.gdshader`,
   `anim/index.json` are read-only for piece workers. If a shared file must
   change, the worker reports the needed change; the lane parent requests an
   **integration ticket** from the coordinator, which grants ONE builder
   exclusive ownership, gated on the pieces passing first.
3. **Staging, not live:** piece outputs go to staging dirs
   (`app/shots/pieces/`, `app/shots/unit_pieces/<family>/`). Nothing lands in
   live asset dirs (`app/assets/models/anim/**`) except through an integration
   ticket with gates.
4. **Serialized resources stay serialized:** all Godot through `godot_runner.py`
   (unique ids `<ticket>-<purpose>`). **Blender bakes: max 2 concurrent
   project-wide** — the UNITS lane parent arbitrates bake slots; other lanes do
   not launch Blender without coordinator grant. Headless Python/Pillow piece
   work needs no runner and is fully parallel.
5. Backups before any edit of an existing owned file:
   `inbox\backup\<name>.bak-<ticket-id>`.

### 7.6 Acceptance ladder (piece → combo → small map → full map)

1. **Piece PASS:** headless render of the single piece + measurements inside
   donor-derived bands + visual A/B against donor reference
   (`C:\Users\Maxym.Oboyshev\Downloads\c3\`, donor assets at `C:\Games\Cossacks 3`).
   Metrics never override visual review (R-ARCH process rule).
2. **Combo PASS:** pieces composed (shore+water, grass+trees, ravine+grass…)
   still pass their criteria.
3. **Integration:** one builder wires accepted pieces into the engine; gates
   selftest 29/29 + uitest 17/17 + bake bench < 250 ms + scan_map green +
   determinism byte-identical where required.
4. **Full-map confrontation:** canonical whole-map PNG
   (`full_map_shot.py`, `map_w*tile_px × map_h*tile_px`) + in-engine captures,
   compared to donor reference; owner visual review is the final gate.
