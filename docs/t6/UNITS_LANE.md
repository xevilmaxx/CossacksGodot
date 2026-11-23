# T6 UNITS LANE — parent T6-UNITS (session `ses_df83a0375ffen2khQT5GOSXtDv`)

**Role:** recursive-swarm lane parent for unit sprite fidelity. Owner directive:
reject monolithic baking — **many mini-bakers**, each bakes ONE unit first,
verifies frame-by-frame vs donor truth, then bakes the rest of its family.
Only verified staging output is eligible for integration.

**Authority / boundaries:** I own this lane doc and the integration request
(T6-U90). I do **not** edit `SWARM_BOARD.md`, `SWARM_OPS.md`,
`AGENT_PROTOCOL.md`, other lanes' files, shared engine files, or anything under
`app/assets/models/anim/**` (live assets — READ-ONLY until T6-U90 is granted by
the coordinator). Donor `C:\Games\Cossacks 3` is PRIVATE USE — never redistribute.

## Paths

- Project root: `C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3`
- Donor (read-only): `C:\Games\Cossacks 3`
- Blender 5.2: `C:\Program Files\Blender Foundation\Blender 5.2\blender.exe`
- Shared READ-ONLY reference: `app/tools/bake_sprites.py`, `compute_ortho.py`,
  `sheet_metrics.py`, `app/assets/models/anim/**`, `docs/UNIT_BAKING_FIX.md`,
  `docs/decomp/DC_FORMATS.md`
- Per-family owned by children: `app/tools/unit_bakers/<family>.py`,
  staging `app/shots/unit_pieces/<family>/`, report `docs/t6/reports/<ID>.md`

## Resource arbitration — Blender bake slots (max 2 concurrent, project-wide)

| Slot | Holder | State | Notes |
|---|---|---|---|
| A | T6-U02 (17c infantry) | GRANTED 2026-11-23 (after U01 release) | U01 reported "BAKE DONE — slot A free"; grant delivered for pikeman-first family bake; cossack/croat EXCLUDED (HOLD) |
| B | T6-U04 (cavalry) | GRANTED 2026-11-23 (after U05 release) | U05 reported "BAKE DONE — slot B free"; dragoon-first full-mount composite + rider-only A/B control |
| queue | T6-U07 | WAITING (phase 1 read-only in progress) | spawned child must finish truth + naval.py + report, then request a grant |
| released | T6-U05 (artillery) | DONE 2026-11-23 | 4/4 keys PASS, 17 sheets (incl. new scoped `death` + `multicannon.next`), 0 clips, 8/8 dirs, wheel composites correct |
| released | T6-U01 (peasants) | DONE 2026-11-23 | 9/9 keys PASS, 126 sheets, 153/153 checks, 0 clips, all 9 walk durations 1.08 s |
| released | T6-U06 (support cast) | DONE 2026-11-23 | 9/9 keys PASS, 33/33 sheets SHA-256 byte-identical to live (parent independently checked 2) |
| released | T6-U03 (18c infantry) | DONE 2026-11-23 | 5/5 keys PASS; 20 sheets, 0 CLIP, 8/8 dirs, live-index metadata MATCH; S05 R4/R5 honoured |

Rule: a child may not launch Blender until I reply with an explicit grant via
its sessionID. It must report the moment its bake finishes so the slot can be
reassigned. Read-only work is unlimited and needs no slot.

**Slot semantics (clarified 2026-11-23):** one grant = one family's
piece-by-piece bake session (first unit PASS → rest of that family), NOT a
single sheet. This keeps a family's camera/manifest consistent and limits
orchestration churn, while still capping Blender at exactly 2 concurrent
processes. A slot is released when the family's bake + per-unit verification
completes and the child reports "BAKE DONE — slot free"; I then grant it to the
next queued family. The max-2 cap is checked by `Get-Process blender` as well
as by child reports.

## Micro-task table

| ID | Family / exact unit keys | sessionID | Bake-slot state | Per-unit PASS/FAIL | Evidence |
|---|---|---|---|---|---|
| T6-U01 | `peasant` + `ukr_peasant, rus_peasant, pol_peasant, aus_peasant, eng_peasant, spa_peasant, tur_peasant, sco_peasant` (9) | `ses_df82bd093ffevDgZ15CkqpjXl1` | GRANTED | — | — |
| T6-U02 | 17c infantry: `pikeman, roundshier, serdiuk, archer, strelet, cossack, pandur, croat, chasseur, highlander, jannisary` (11) | `ses_df82bbebdffelIrx2FjGSOcZrh` | WAITING (read-only phase) | — | — |
| T6-U03 | 18c infantry: `musk18, pikeman18, musketeer, grenadier, lightinfantry` (5) | `ses_df82bb3b7ffe3IH12e0vNfpsqw` | WAITING (read-only phase) | — | — |
| T6-U04 | cavalry: `dragoon, dragoon17, hussar, wingedhussar, cuirassier, reiter, lightcavalry, hackapell, tatar, sipahi, spakh, mameluke, vityaz, hetman, cossackdon, cossackregister` (16) | `ses_df82bac2effe131AkBKGVHXwN8` | WAITING (read-only phase) | — | — |
| T6-U05 | artillery: `cannon, howitzer, mortar, multicannon` (4) | `ses_df82ba349ffew1uaIZNOEeLNrz` | WAITING (read-only phase) | — | — |
| T6-U06 | support: `officer, officer18, drummer, drummer18, priest, pope, padre, mullah, bagpiper` (9) | `ses_df82bc671ffedCgRhkD77Qmfjr` | GRANTED | — | — |
| T6-U07 | naval: `yacht` + readable naval meshes (`NAVAL_EVIDENCE.md`) | `ses_df7fa7a2effe6vCrU1TQYdLoOq` | WAITING (phase 1 only, spawned 2026-11-23) | — | — |
| T6-U90 | INTEGRATION — verified staging sheets → live anim + index.json; ONE coordinator-granted owner; gates | not started | n/a | — | — |

## Bake queue / phase-1 results (supervision 2026-11-23)

| Order | Ticket | Phase 1 | First unit | Phase-1 highlights |
|---|---|---|---|---|
| — | U01 | **DONE — 9/9 PASS, slot A released** | `peasant` | 126 sheets / 14 actions × 9 keys, 8,928 cells, 153/153 checks, 0 edge clips, 7 props gripped (hammer 0.0000 m), gold-standard 4.136/(0.5,0.8569) body-only + 5.465/(0.5,0.8037) prop-inclusive both reproduced |
| — | U06 | **DONE — 9/9 PASS, slot B released** | `officer` | 33/33 sheets SHA-256-identical to live; GROUP_OK, zero CLIP, 8/8 dirs, no attach props (Bug 5 N/A) |
| 1 | U03 | **DONE — 5/5 PASS** | `musketeer` | 20 sheets, 0 CLIP, 8/8 dirs, GROUP_OK, live-index MATCH; pikeman18 9f/0.300s attack preserved; 3D foot-centroid 2.1 m = pike-geometry contamination, rendered body moved 11 px |
| 2 | U05 | PASS | `cannon` | artillery actors are COMPOSITE (body + 2 wheel .oss) with SEPARATE death .oss/.aaf — needs custom baker, not a `bake_unit` wrapper; wheels static; death ortho ≫ stand needs visual check |
| 3 | U02 | PASS (with HOLDs) | `pikeman` | 11 keys; pikeman drift 0.076 m, geometry gates match compute_ortho to 3 dp; **cossack FAIL 1.0306 m** and croat 0.4874 m HOLD for HOME diagnosis; horse-mount truth relayed to U04 |
| 4 | U04 | phase 1 in progress | `dragoon` | read-only LIVE-sheet crops done; notified about `cossacksich_horse.oss` / `croat_horse.oss` mount scope |
| 5 | U07 | **PHASE 1 PASS — on STANDBY** | `yacht` | k=311/fps=30 quats |q|=1, bone-0 drift needs de-travel; AAF 4 actions all 1..280 (9.333 s); hull .osm offsets 12/13/14 refuted 10/11/12 bug; derived framing == live index 0.000 delta; 24 build-stage files (sail/flags/dock) never hand-prop composites; live-path guard refuses exit 1 |

Parent rulings issued: (a) cossack/croat horse mounts belong to U04 cavalry, NOT U02 — U02 bakes riders only; (b) keep donor-exact durations (do not apply GUIDE4 `n*0.09`) and flag to T6-U90; (c) cossack/croat HOME wander stays HOLD pending measurement, no guessed fix.

## Supervision log

- 2026-11-23: read SWARM_OPS §7, T6_WAVE_PLAN §1.2-B + LANE UNITS,
  AGENT_PROTOCOL, UNIT_BAKING_FIX, bake_sprites.py, DC_FORMATS. Discovered the
  `subagent` tool is not exposed directly in this session; spawning children via
  the OpenCode session API (`POST /api/session` with `parentID`, then
  `POST /api/session/{id}/prompt`) — the documented subagent mechanism.
- 2026-11-23: spawning U01 + U06 with bake slots, and U02–U05 read-only truth
  gatherers. U07 queued. Will supervise on every child-idle notification.
- 2026-11-23: **COORDINATOR DIRECTIVE ACKNOWLEDGED** — re-read SWARM_OPS §7.2.
  All new/replacement children use model `opencode-go/hy4-flash-free`
  (the `opencode/hy4-flash-free` pool is quota-blocked); every child prompt now
  carries the host facts (`python` 3.14 NEVER `python3`; Blender 5.2 path),
  the `opencode run --session/--auto` spawn mechanism and the escalation rule
  (`opencode-go/muse-spark-1.3-contributor#high` after 2 failures / >20 min).
  First U01 attempt was created on the quota-blocked `opencode/` pool but never
  received its prompt (0 messages, no quota error, no work done); it and a
  throwaway probe session were deleted. All 6 children were then re-spawned
  fresh on `opencode-go/hy4-flash-free` with identical tickets/owned files and
  prompts confirmed delivered (promptOk=true). Spawn helper:
  `%TEMP%\opencode\t6units\spawn.js` (Node API pattern from rustport/.lane/spawn.js;
  Node passes JSON args cleanly, PowerShell 5.1 mangles quotes).
- 2026-11-23: all 6 children show `busy` with no `idle` timestamp = agent loops
  running; no quota errors observed. Slots A/B held by U01/U06; U02–U05 in
  read-only phase 1.
- 2026-11-23: first output check — U01 wrote a real 24.5 KB
  `app/tools/unit_bakers/peasants.py` (KEYMAP for all 9 keys, imported
  `bake_sprites` primitives, staging-only paths, `--verify` mode).
- 2026-11-23: **spawn-tooling incident (resolved).** My first attempt to send a
  U03 follow-up called `spawn.js` (which has no `prompt` action) and re-ran the
  whole spawn, creating 6 duplicate children with the same owned files and two
  of them told they held bake slots. I immediately wrote `ctl.js` (proper
  create/prompt/get/delete actions, same authenticated Node pattern) and
  deleted all 6 duplicates; all 6 arrived `state=cancelled`, originals
  confirmed intact. Prepared commands were written to
  `%TEMP%\opencode\t6units\followup_u*.txt`. No double-bake occurred.
- 2026-11-23: U03/U05/U02 all finished phase 1 and requested bake slots;
  all three were given STANDBY follow-ups (no Blender) with queue order
  U03 → U05 → U02. U03 and U05 acknowledged; U02 received the mount-scope
  ruling. U03 corrected my file check: its `donor_truth.json` is stdout-only
  in `--truth-only` mode, so `app/shots/unit_pieces/infantry18/` is empty
  until the bake — lane doc amended accordingly.
- 2026-11-23: U01/U06 still hold both slots and are actively rendering
  staging sheets (peasants: 17+ PNGs + index.json + verify_report.json;
  support: officer/officer18/drummer/drummer18/priest PNGs + manifest + viz).
  `Get-Process blender` shows exactly 2 processes — cap respected.
- 2026-11-23: **U06 officer independently re-verified by parent** (quality rule
  §5b-QUALITY.2): SHA-256 of staged vs live `officer_walk.png` and
  `officer_attack.png` are byte-identical
  (`50602707…7DC3`, `E207A7A3…B165`). U06's report §per-unit verdict officer =
  PASS stands. Parent visually viewed `viz/officer_dirs_strip.png` — 8 distinct
  azimuths, polearm gripped, no edge clips.
- 2026-11-23: U02 final rulings accepted and recorded in its report §7.2 —
  cossack/croat HOLD with foot-pin band N/A (HOME-invariance proof: pairwise
  drift cancels HOME, so no candidate HOME can fix it), mounts deferred to U04
  with §7.3 payload, donor-exact durations flagged to T6-U90.
- 2026-11-23: parent visually viewed `peasants/peasant_workwood.png` — axe
  gripped/swinging across all 10 frames × 8 dirs, no white-board, no clipping.
- 2026-11-23: **COORDINATOR DIRECTIVE (RESEARCH T6-S05) ACKNOWLEDGED + ROUTED.**
  Read `docs/research/T6_S05_anim_truth.md` (5 sampled families, 2 independent
  parsers, full agreement). Routed to all 6 children via their sessionIDs:
  - **U01 HARD GUARD:** `peasant.walk` 0.667 → **1.08 s** is a deliberate
    stride fix (P-26 / agentC2 §10 / agentSE §11.2, GUIDE4 DO-L7.06). Only
    intentional divergence in scope. Apply to all 9 walk keys; NEVER revert
    to donor 0.667 or recompute from sampled frames.
  - **ALL families:** unbaked donor actions (4/14/5/1/4) may be added ONLY as
    NEW scoped actions with own donor AAF truth; NEVER substitute an existing
    sheet for a missing state. Runtime binding is UNVERIFIED. Port `frames` =
    sampled pose count; keep donor-range-derived durations; keep identical-
    range pairs (peasant attack0/workwood, cannon attack0/attack1).
  - **U04 mounts (final reconciliation):** `dragoon18_horse` + each of the 16
    co-animated mounts IN SCOPE (`tool: null` stays correct — coverage gap).
    `cossacksich_horse`/`croat_horse` get a SEPARATE scoped bake after the 16
    keys, foot-pin band N/A with documented drift, plus FLAGGED U90 items.
    U02 stays rider-only HOLD; its files untouched.
  - **U02:** cossack/croat HOLD accepted; T6-U90 must verify renderer-side
    foot-pin handling in `game.gd`/`world.gd` (READ-ONLY for U02) before any
    donor-faithful claim; donor-exact durations preserved.
  - U04 also found a latent UV-offset bug in the shared `build_mesh` (mount UV
    indexed by body VERTEX count; donor verts≠uvs) — fixed locally in
    `build_mesh_two`, read-only reference untouched. FLAG for a separate
    ticket (affects peasant tool compositing).
- 2026-11-23: U01 peasant **PASS** (17/17 checks + visual, stand ortho 5.465 /
  anchor (0.5,0.8037), zero clips); historical 4.136/(0.5,0.857) reproduced
  as body-only sub-group. Remaining 8 keys baking in slot A. U04 phase 1 PASS
  (16 keys, mount compositing required, one shared rider de-travel; UV bug
  found and locally fixed).
- 2026-11-23: **U06 DONE** — all 9 support keys PASS (33/33 staged sheets
  SHA-256 byte-identical to live; frames/durations/ortho/center/ax/ay/tool
  match live index; GROUP_OK, edge-touch=0, 8/8 dirs, foot pin, death falls).
  Child confirmed "BAKE DONE — slot B free"; parent granted slot B to U03
  (musketeer-first) via sessionID. Queue now U05 → U02 → U04 → U07.
  Exactly 2 Blender processes max maintained (U01 + U03 once it starts).
- 2026-11-23: **U03 DONE** — all 5 infantry18 keys PASS (20 sheets, 0 CLIP,
  8/8 dirs, GROUP_OK, centre XZ=(0,0), ax=0.5, live-index metadata MATCH,
  Bug 5 N/A). Child confirmed "BAKE DONE — slot B free"; parent granted
  slot B to U05 (cannon-first composite bake). Queue now U02 → U04 → U07.
- 2026-11-23: **U01 DONE** — 9/9 peasant keys PASS: 126 sheets, 8,928 cells,
  153/153 checks, 0 edge clips, shared stand/death groups, 7 attach props
  gripped (hammer 0.0000 m to body bone 7), every frame/dir distinct by hash.
  All 9 walk durations 1.08 s with raw 0.667 retained as `donor_duration`
  (S05 hard guard honoured). Gold standard reconciled: body-only
  4.136/(0.5,0.8569) and prop-inclusive 5.465/(0.5,0.8037). Family batch hit
  a 20-minute shell timeout; sco re-baked separately 11:40:04. Child
  confirmed "BAKE DONE — slot A free"; parent granted slot A to U02 with
  cossack/croat EXCLUDED (HOLD). Queue now U04 → U07.
- 2026-11-23: slots A/B active with exactly 2 blender.exe processes (U02
  infantry17 PID 25836, U05 artillery PID 21904) — cap respected.
- 2026-11-23: U07 (naval) spawned as the 7th child on
  `opencode-go/hy4-flash-free` (`ses_df7fa7a2effe6vCrU1TQYdLoOq`, prompt
  confirmed delivered) in PHASE-1-ONLY mode since read-only work is unlimited:
  donor truth for yacht + `NAVAL_EVIDENCE.md` meshes, `naval.py` mini-baker,
  and a report; no Blender until an explicit grant. Known naval integration
  gaps (naval/index schema subset, `_anim_dir()` subdir blind spot, 9.333 s
  walk, hull duration 1.0) are recorded as T6-U90 items, not to be fixed by
  the child.
- 2026-11-23: **U05 DONE** — 4/4 artillery keys PASS: 17 sheets incl. new
  scoped `death` (separate donor .oss/.aaf) and `multicannon.next` (0.8 s);
  0 clips, 8/8 dirs, wheel composites match donor, death ortho diffs visually
  confirmed (mortar 4.95 vs 2.51, multicannon 6.93 vs 4.91). U90 must take
  the new wheel-inclusive shared anchors from staging, not old live values.
  Slot B released → granted to U04 (dragoon + rider-only A/B control).
- 2026-11-23: **U07 phase 1 PASS** — `naval.py`, donor truth and report
  written; framing reproduced live index with 0.000 delta; guard test
  refusing `app/assets/models/anim/naval` passed. Requested a slot; put on
  STANDBY (A=U02, B=U04 both busy), next after U04 in queue.

## Required child evidence (method)

For each unit: parse donor `.oss`/`.aaf`; bake sheets with the family mini-baker
(reuse proven reader/camera/skinning from `bake_sprites.py` — import or copy with
attribution, never edit the original); verify frame-by-frame vs donor AAF truth
(action durations, frame counts, foot pin/de-travel, attach props, per-action
camera, 8 directions) using the UNIT_BAKING_FIX checklist + sheet_metrics-style
measurements + visual inspection of rendered PNGs; write a per-unit PASS/FAIL
verdict. Bake ONE unit, verify, then the rest of the family. Outputs ONLY to
`app/shots/unit_pieces/<family>/`. Report `docs/t6/reports/<ID>.md` with an
observed/derived/inferred claim table before reporting done.

## Escalation

After 2 failed attempts or >20 min silence with no progress, re-spawn the same
micro-task with model `opencode-go/muse-spark-1.3-contributor#high` (variant
`high`), attaching the failed report. Ping quiet children via their sessionID.
