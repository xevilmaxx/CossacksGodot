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
| A | — | FREE | U07 naval DONE (7/7 PASS, 12 sheets) |
| B | — | FREE | U04 cavalry DONE (18/18 keys + control PASS); M2/M3 scoped mounts appended |
| queue | — | EMPTY | **ALL LANE BAKES COMPLETE** — no Blender work remains; T6-U90 grant deferred to coordinator |
| released | T6-U02 (17c infantry) | DONE 2026-11-23 | 9/9 authorised keys PASS (7 checks each + visual); cossack/croat HOLD — NOT BAKED, never counted PASS |
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
| 3 | U02 | **DONE — 9/9 authorised PASS, 2 HOLD** | `pikeman` | 9 keys baked (7 checks each + visual); pikeman drift 0.076 m, geometry gates match compute_ortho to 3 dp; **cossack FAIL 1.0306 m / croat 0.4874 m stayed HOLD — NOT BAKED**; mount truth relayed to U04; U90 renderer foot-pin check flagged |
| 4 | U04 | **DONE — 18/18 + control PASS, slot B released** | `dragoon` | 76 sheets / 19-unit manifest; 16 family keys mounted + cossack/croat scoped mounts; all 7 checks OK, zero CLIP, ≥0.97 distinct; rider-only control matches LIVE byte-for-metric |
| 5 | U07 | **DONE — 7/7 PASS, slot A released** | `yacht` | 12 sheets: yacht/yachttur/fishboat/frigate/galley (hull+walk) + battleship/xebec (hull-only, no crew fabricated); all 8 dirs, 0 CLIP, GROUP_OK, own donor truth; main anim index still 54 keys, live naval index still ['yacht'] |

Parent rulings issued: (a) cossack/croat horse mounts belong to U04 cavalry, NOT U02 — U02 bakes riders only; (b) keep donor-exact durations (do not apply GUIDE4 `n*0.09`) and flag to T6-U90; (c) cossack/croat HOME wander stays HOLD pending measurement, no guessed fix.

## T6-U90 INTEGRATION REQUEST (parent → coordinator — DO NOT SELF-EXECUTE)

The UNITS lane has completed all seven family scopes with verified staging
output. **No live asset was written.** One coordinator-granted integration
owner must copy only the verified sheets below into `app/assets/models/anim/**`
and update index files behind the normal gates.

### Verified staging inventory (evidence: per-family manifests + reports)

| Ticket | Family | Staging dir | Verified keys | Sheets | Verdict |
|---|---|---|---|---|---|
| U01 | peasants | `app/shots/unit_pieces/peasants/` | 9 (peasant + 8 national) | 126 (+ crops) | 9/9 PASS, 153/153 checks, 0 clips; walk 1.08 s all 9 |
| U06 | support | `app/shots/unit_pieces/support/` | 9 | 33 | 9/9 PASS; **33/33 byte-identical to live → NO-OP** |
| U03 | 18c infantry | `app/shots/unit_pieces/infantry18/` | 5 | 20 | 5/5 PASS; live-index metadata MATCH → NO-OP |
| U05 | artillery | `app/shots/unit_pieces/artillery/` | 4 | 17 | 4/4 PASS; new scoped `death` + `multicannon.next` |
| U02 | 17c infantry | `app/shots/unit_pieces/infantry17/` | 9 authorised | 36 | 9/9 PASS; cossack/croat HOLD — NOT BAKED |
| U04 | cavalry | `app/shots/unit_pieces/cavalry/` | 16 + rider control | 68 | 16/16 + control PASS; M2/M3 mounts in progress |
| U07 | naval | `app/shots/unit_pieces/naval/` | 7 | 12 | 7/7 PASS; live naval index still `['yacht']` |

### Proposed index.json metric updates (integration owner to apply, not the lane parent)

1. **U01**: keep `duration=1.08` on all 9 walk actions (`donor_duration=0.667`
   is provenance only — S05 R1 hard guard). Stand group is prop-inclusive
   ortho **5.465** / anchor **(0.5, 0.8037)**; the 4.136 / (0.5, 0.8569)
   figure is the body-only sub-group, not a regression.
2. **U05**: adopt the **wheel-inclusive** shared stand/death camera groups and
   anchors from `artillery/staging_manifest.json` — old live centre/anchor
   values are rider-only and will misplace the composite guns. Add new scoped
   actions `death` (separate donor `.oss`/`.aaf`) and `multicannon.next`
   (0.8 s), each with its own donor-derived metrics. Do not re-time the
   donor-exact 3.3 s artillery walk.
3. **U04**: decide whether live keys switch from rider-only to the verified
   mounted sheets. Mounted dragoon stand ortho **4.200** / anchor
   **(0.5, 0.9922)**, death ortho 9.413; the rider-only A/B control reproduces
   live metrics byte-for-metric, so the mount is the only delta. If mounted
   sheets are adopted, use the staging manifests' group anchors. M2/M3
   (cossack/croat mounts) to be appended when their scoped bake reports PASS.
4. **U02**: cossack/croat stay HOLD with **no live sheet change**. Before any
   donor-faithful claim, verify renderer-side foot-pin handling in
   `game.gd`/`world.gd` (S05 directive + U02 HOME-invariance proof:
   1.0306 m / 0.4874 m drift is rider-clip bone motion, not fixable by HOME).
5. **U07 naval**: main `anim/index.json` MUST stay at 54 keys. New vessel keys
   are staging-only and need a load path — either teach `_anim_dir()` to
   resolve `anim/naval/`, or ship a separate scoped index (per
   `NAVAL_PORT_PLAN.md` §4). Naval action schema lacks `bbox/fig_h/foot/cx`;
   add them or a naval-specific `fig_h` fallback. `yacht.walk.duration=9.333`
   is donor-intentional; `hull.duration=1.0` is now emitted by the baker.
   Sails/flags/dock stages are separate build-stage entities from their
   `.actor` mount truth — never composited as hand props.
6. **U06/U03**: already byte-identical / metric-identical to live — **do not
   re-copy**; record as verified-no-change.

### Flagged items NOT fixed by this lane (integration or separate tickets)

- Shared `build_mesh` UV-offset bug (mount UV indexed by body VERTEX count;
  donor verts≠uvs) — U04 worked around it locally in `build_mesh_two`;
  a separate ticket must fix the read-only reference for peasant tools.
- S05 unbaked donor actions (4/14/5/1/4 per sampled family) — runtime
  state→action binding is **UNVERIFIED**; add only as new scoped actions with
  own AAF truth, never substitute existing sheets.
- Godot `.import` sidecars with `compress/mode=0` for any newly copied PNG
  (UNIT_BAKING_FIX §8 lossy-VRAM trap).
- Gates for the integration owner: selftest 29/29, uitest 17/17,
  `t_anim_metrics`/`t_naval` check status, owner visual review.

### M2/M3 APPEND — FINAL OUTSTANDING BAKE COMPLETE (2026-11-23)

U04 reports the scoped cossack/croat mount sub-task COMPLETE, both keys
**PASS** (bake + re-verify, all 7 checks OK, 8/8 dirs, zero CLIP, exactly two
group signatures, donor-exact frames/durations, `tool: null`, foot-pin band N/A
per the standing ruling). This was the last bake in the lane; both slots are
free and no Blender process remains.

| Key | Mount | De-travel | Residual drift | Glue (diagnostic) | Stand / death ortho | Anchor | Verdict |
|---|---|---|---|---|---|---|---|
| `cossack` | `cossacksich_horse.oss` | NONE (best of 3) | 0.2444 m (vs rider 0.9904 / horse 1.6734) | 0.4643 m | 5.214 / 5.430 | (0.5, 1.0193) | **PASS** |
| `croat` | `croat_horse.oss` | HORSE-ROOT (best of 3) | 0.1888 m (vs none 0.2501 / rider 0.6038) | 0.3118 m | 4.847 / 5.985 | (0.5, 1.0048) | **PASS** |

Both 8-direction strips visually viewed: riders correctly seated on donor
horses, no clipping. Cossack walk 1..48 = 1.6 s, croat 1..17 = 0.567 s (both
donor-exact). No live anim/index/.gd write; U02's HOLD sheets untouched.
`cavalry.py` gained `--mount-keys` + per-key `DETRAVEL` (rider/none/horse),
`py_compile` clean. Cavalry staging is now **76 sheets / manifest 19 units**
(16 family × 4 + 4 rider-only control + 4 cossack + 4 croat).

**Integration note for the U90 builder:** M2/M3 now meet D-42 pre-ruling (a)'s
PASS condition. Use the staging manifest's per-key stand/death ortho and
anchors above; keep foot-pin band N/A and document residual drift — do not
claim a clean pin. U02's rider-only cossack/croat HOLD sheets remain
unchanged and are NOT to be overwritten by these mounted sheets unless the
coordinator explicitly rules that swap (D-42 (d) keeps HOLD / separate game-
code ticket).

### COORDINATOR D-42 — GRANT DEFERRED, PRE-RULINGS (acknowledged 2026-11-23)

Coordinator received the request and **deferred** (not denied) the U90 builder
grant until U04's M2/M3 scoped-mount verdict is appended — my own stated
completion condition. I keep U04 supervised to that verdict. Pre-rulings now
binding on the future integration owner (zero open questions at builder start):

- **(a)** U04 adopts the verified **MOUNTED** sheets for the 16 keys; M2/M3
  stay excluded until their own PASS. **M2/M3 PASSED 2026-11-23 and are
  appended below — the exclusion condition is now satisfied.**
- **(b)** Naval stays in `anim/naval/` + the naval index; main `index.json`
  FROZEN at 54 keys. `_anim_dir()` load-path is **DEFERRED** (world.gd
  contention: W04 scoped lines, TERRAIN T90 next) and belongs to open P-10.
- **(c)** U06/U03: SHA-verify and skip identical sheets — no re-copy churn.
- **(d)** cossack/croat remain HOLD; renderer foot-pin is a separate
  game-code ticket the coordinator will triage, NOT U90 scope.
- **(e)** `build_mesh` UV-offset bug: separate ticket.
- **(f)** Unbaked actions: new scoped only, never substitute.
- **(g)** Lossless `.import` sidecars (`compress/mode=0`) for every newly
  copied PNG.
- **(h)** U05 wheel-inclusive anchors + scoped `death`/`next` adopted;
  3.3 s walk untouched.
- **(i)** U01 1.08 s walk guard preserved.
- **(j)** Revert = pre-change SHA manifest + git HEAD.
- Frigate raw-center adjudication **endorsed** (fix-the-check, gate untouched)
  — same class as T15/T07.
- 2026-11-23: **M2/M3 APPENDED — LANE BAKES COMPLETE.** cossack (NONE
  de-travel, 0.2444 m residual) and croat (HORSE-ROOT, 0.1888 m residual)
  scoped mounts both PASS with 7/7 checks, zero CLIP, 8/8 dirs, donor-exact
  durations; documented glue/drift with foot-pin band N/A. Cavalry staging
  76 sheets / 19 units. Both slots free, no Blender process. Integration
  request is now complete; T6-U90 builder grant is the coordinator's next
  action per D-42. Parent stops here — no live asset writes.
- 2026-11-23: **D-42 acknowledged** in the integration request above; pre-rulings
  (a)–(j) are now binding on the future U90 builder. Grant stays deferred until
  the M2/M3 verdict appends. Verified via U04's live session log that the
  scoped sub-task is actually running: `cavalry.py --mount-keys cossack`
  launched after py_compile=0 and a pure-Python scoped check confirming
  cossack NONE drift 0.2444 m / croat HORSE-ROOT 0.1888 m, both mount
  closures and UV bounds OK. No escalation needed.
- Builder gates: selftest 29/29, uitest 17/17, `t_anim_metrics`/`t_naval`
  status, owner visual review.

These pre-rulings supersede the corresponding "decide whether" phrasing in my
proposals above. I do not spawn, grant, or execute U90 myself.

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
- 2026-11-23: **U02 DONE** — 9/9 authorised 17c infantry keys PASS (7 checks
  each + visual sheet inspection); cossack/croat stayed HOLD — NOT BAKED and
  never counted PASS. Slot A released → granted to U07 (yacht-first). All 7
  families have now had a bake slot; only U04 (cavalry) and U07 (naval) are
  still baking. Queue empty.
- 2026-11-23: **U07 yacht PASS** — Blender exit 0 (~53 s), `--verify` ALL PASS:
  crew walk 12f/9.333 s, hull 1f/1.0 s, 8/8 dirs, zero CLIP, GROUP_OK,
  anchors identical to live, 0.000000 framing delta; build stages never
  composited; live naval assets/index/.gd untouched. Slot A released, then
  CONTINUATION GRANTED for other scoped vessels (yachttur, fishboat, frigate,
  galley, static-hull battleship/xebec) — one new key at a time with own
  donor truth, no sheet substitution, main index stays 54 keys, all U90 flags
  recorded not fixed.
- 2026-11-23: **U07 continuation — first FAIL adjudicated.** yachttur and
  fishboat PASS (own donor files); frigate STOPPED at a verifier-only ortho
  delta 0.002 (19.435 baked vs 19.437 derived) — child correctly made no fix.
  Parent ruling: derivation artefact, NOT a sheet defect — `donor_truth()`
  projected a 3-decimal-rounded center (19.436550) while `bake_hull()` used
  the raw center (0.0, 0.0641665, 5.4675090 → 19.435420). Adjudication: align
  the truth derivation to the raw-center projection in U07's OWN naval.py;
  do NOT touch the 0.002 tolerance or any shared file. Re-verify all 4 staged
  keys; if clean, continue galley → battleship → xebec. Recorded as a
  methodological correction, not a gate weakening.
- 2026-11-23: **U07 DONE** — full naval family 7/7 PASS after the ruling:
  frigate PASS with raw-center-derived 19.435 (old rounded-centre 19.437),
  all 4 previously staged keys re-verified with no regression, galley +
  battleship + xebec added (hull-only keys fabricate no crew action). Final
  report has per-key verdict table, derivation-ruling evidence and U90 flags.
  12 PNG sheets, 7-key staging manifest; main anim index still 54 keys,
  live naval index still ['yacht']. Slot A released. Only U04 remains.
- 2026-11-23: **U04 16/16 PASS + rider-only A/B CONTROL PASS** — 68 sheets,
  all 6 checks OK on every key, zero CLIP, distinct ≥0.97, donor-exact
  frames/durations, one shared stand + one death group, ax=0.5. Dragoon
  mounted stand ortho 4.200 / anchor (0.5,0.9922) matched Phase-1 prediction;
  rider-only control reproduced LIVE metrics byte-for-metric (mount is the
  only delta). Local `build_mesh_two` UV fix verified visually on all 16
  horses (correct UV mapping, riders glued, fall together in death). Slot B
  released, then RE-GRANTED (with an explicit confirmation after a message
  crossing) for the final M2/M3 cossack/croat scoped mount sub-task — foot-pin
  band N/A, documented de-travel/drift, U02 HOLD untouched.

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
