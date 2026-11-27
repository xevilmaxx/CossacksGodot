---
id: DEC-U-FEAR-RUNAWAY
worker: DEC-U-FEAR-RUNAWAY (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. Donor binary never executed/copied. Donor scripts read as text only (via prior-ticket transcripts + repo mirrors). No repo code/asset/config/Godot/git edit: this report is the only file written."
network: "OUT OF SCOPE. No multiplayer/netcode specified, audited, or changed."
parity: "NO PARITY CLAIM. No donor GPU A/B frame; no donor binary executed by this worker."
context: "DEC_U_guard_sampler.md left G1e open: runaway gate `unit.script:7366-7368`, guard-order keep `:7337-7340`, `runawaydist=3.5`, `runawaydelay=1.3`; fear must NOT interfere (no `fear:=true`, no `SearchEnemyInCell(...,4)` on that path). DEC_U_ai_thresholds.md recorded fear 30/400 rule as donor text (`[*]`)."
labels: "[O] verbatim donor literal (file:line) . [D] deterministic reading . [I] inference, flagged . [U] UNVERIFIED with exact experiment . PORT APPROXIMATION = port substitute to remove for 1:1"
---

# DEC-U-FEAR-RUNAWAY — exact runaway/fear law (2026-11-26)

## 0. Pass ledger (owner rule; every donor pass pinned `t_87f0f3c130b0`; donor read-only, never executed)

| # | Pass | Result / evidence |
|---|---|---|
| P1 | Pin re-assert | `t_87f0f3c130b0` per header (5,768,048 B, sha256 `87f0...4e16c`, matches GUARD-SAMPLER §0 / AI-THRESHOLDS §0 / SKIRMISH-TABLES §0). No binary executed, no copy. |
| P2 | `DEC_U_guard_sampler.md` §5 + §6-G1e re-read (pass 1 of 2) | EV-RUN: `_unit_IsRunAway` order-test `:7175-7179`, `_unit_DoRunAway` `:7182-7239`, `_unit_DoSearchVictim` guard keep `:7332-7340` + runaway call `:7366-7368`, shooter TryAttack fallback `:8151-8153`, standground victim search `:8415-8433` — all `[O]` live. EV-FEAR: fear `dist<30 / enForce>myForce`, `dist<400` nearest-weaker track, `SearchEnemyInCell(go,enX,enY,4)` `:2832-2838`, fallback `enForce>6 and dist<40` `:2892-2898` — all `[O]`-text (`[*]`). |
| P3 | `DEC_U_guard_sampler.md` §5 re-read (pass 2 of 2, guard-interplay focus) | EV-ORD: guard keep `bRemove=(attackobj) and (not _unit_IsGuard)` `:7337-7340`; `… or order=guard` preserve `:7332`; control-layer gates `control.script:317,398`; `_unit_DoRunAway` has NO guard exclusion — engine resolution of guard+runaway is native dispatch, `[U]`-G1e. |
| P4 | `DEC_U_ai_thresholds.md` §5–§6 + §7 items 5/10 re-read (pass 1 of 2) | EV-THR: shooter fallback gate `standtime = 0 or > 1.3 or (non-AI and diff ≤ normal)` (`unit.script:7367`); `runawaydist/delay` literals §1 (`dmscript.global:195-199`); `SearchVictim(…,6,…)` (`:8427`); fear = target-selection bool only, cell radius `4` (`:2838`); NO numeric morale in donor. |
| P5 | `DFORM_01_formations_morale.md` §(a)+(c) re-read + `DEC_02_scripts.md` D-08 re-read | EV-FORM: `gc_obj_order_move_mode_runaway=2` (`dmscript.global:657`); `deltadst := Clamp(minsearchdist-dst, 3*epsilon, 3.5)`; point placed away from threat, clamped 0.25 inside edge; `_unit_OrderMove(..., move_mode_runaway, True)`; trigger `:7364-7368`, also `:7603`, `:8152-8153`; runaway is an *exclusion* in `miscext.script:1225,1258,1274`, `unit.inc/nothing.inc:262-264`, `onendpointreached.inc:19`. `//` comments "make shooters less annoying when chasing" at `unit.script:7367,8152` are INTENT ONLY, not behaviour. Fear = 3 code hits, one AI local bool (`progresswarai.inc:2799,2817,2832`). |
| P6 | Port read-only inspection (no edit) | EV-PORT: `ai.gd:1054-1055` runaway consts (data only), `ai.gd:1116-1126` fear table (data only), `ai.gd:1257,1276-1277,1333` guard/fear non-interference rows, `ai.gd:1624-1817` GUARD-SAMPLER annex (inert/uncalled, G1e experiment `F100` at `:1790-1795`), `data.gd:1630-1640` donor AI consts, `game.gd` save keys per GUARD-SAMPLER §7 item 5 — §7 (no edit). |
| P7 | DSL re-check | `not X` on numeric lvalue = current-value read (SKIRMISH §0 proof). `[*] = ;` = engine-bound/disabled text: EV-RUN rows are LIVE; EV-FEAR rows are `[O]`-text with `[U]` activation. `//` comments (incl. the two "less annoying" notes) are never behaviour. |

## 1. Runaway law — exact, live (`lib/unit.script`)

**1.1 State predicate `[O]` live (`unit.script:7175-7179`).**
`_unit_IsRunAway := (orders[0].itype = move) AND (orders[0].info.progress = move_mode_runaway)`.
Move-mode enum `[O]`: `gc_obj_order_move_mode_runaway = 2` (`dmscript.global:657`, via DFORM-01 §(a) / DEC-02 D-08).

**1.2 Motion (`_unit_DoRunAway`, `:7182-7239`) `[O]` live.**
`deltadst := Clamp(minsearchdist - dst, 3*epsilon, 3.5)` (DEC-02 D-08 `:7189-7197`);
point placed on the line AWAY from the threat at that distance; clamped `±(hm-0.25)`
(0.25 inside map edge); a pre-existing runaway order is removed first (`:7201-7238`
per GUARD-SAMPLER P13); then `_unit_OrderMove(..., move_mode_runaway, True)` (`:7238`
shape per DFORM-01 §(a)). No HP/threshold/morale variable anywhere on this path `[D]`
(zero `morale|rout|panic|flee|veteran|experience` code hits per SKIRMISH §2.6, re-confirmed
AI-THRESHOLDS §6).

**1.3 Trigger gate (`_unit_DoSearchVictim`, `:7366-7368`) `[O]` live.**
Runaway is issued when a sub-`minsearchdist` victim appears AND the shooter is not
standground-gated: `(standtime = 0) or (standtime > 1.3) or (non-AI owner and difficulty ≤ normal)`
(GUARD-SAMPLER §5 / AI-THRESHOLDS §5–§6). Same gate duplicated in `_unit_TryAttack`
(`:8151-8153`) `[O]` live. Related victim-search sites: standground search `:8415-8433`
(`SearchVictim(…, 6, …)` at `:8427`), and a further trigger reference at `:7603`
(DFORM-01 §(a); exact predicate at `:7603` NOT transcribed this ticket — [U]-R4, §6).

**1.4 Which units enter runaway — NOT closed `[U]-R1.**
The gate lives in victim-search/attack code whose per-`usage` eligibility was never
transcribed: the two `//` "make shooters less annoying when chasing" notes (`:7367`,
`:8152`) are intent comments, not eligibility predicates. Donor-false-to-assert:
any claim of the form "only shooter/grenadier/horseshooter run" is UNVERIFIED until
R1 passes. The port must gate on the verbatim `:7366-7368` predicate alone, never on
an invented usage whitelist. No RNG draw on this path in any read line (no
`RandomExt`/`random` at `:7366-7368`, `:8151-8153` in the transcripts) — [U]-R5.

## 2. Distance / delay sources `[O]`

- `gc_unit_runawaydelay = 1.3` (`dmscript.global:198`; AI-THRESHOLDS §1 cites `:195-200`,
  DFORM-01 cites `:198-199` — same literal, line-window variance only).
- `gc_unit_runawaydist = 3.5` (`dmscript.global:199`, same windows).
- `gc_unit_searchvictimattargetdist = 6` (`dmscript.global:197` per AI-THRESHOLDS §1;
  the `:8427` `SearchVictim(…, 6, …)` call is consistent with it `[D]`, not proven identical — [U]-R6.
- Mode enum `gc_obj_order_move_mode_runaway = 2` (`dmscript.global:657`).
- Port already lands the two literals as DATA: `ai.gd:1054-1055`, `data.gd` AI consts;
  values are right, wiring is absent (see §7).

## 3. Guard-order preservation (LIVE; fear absent here)

- `_unit_DoSearchVictim` keeps a guard order when retargeting `[O]` live:
  `bRemove = (attackobj) and (not _unit_IsGuard)` (`:7337-7340`); the
  `FastCompareDistanceFirstNearThenLast … or order = guard` alternative (`:7332`)
  likewise preserves it (GUARD-SAMPLER §5).
- Control layer refuses move/attack reassignment on guard holders `[O]` live
  (`control.script:317,398`).
- `_unit_DoRunAway` itself carries NO guard exclusion in any read line, so runaway
  CAN be issued onto a guard — but victim-search never strips the guard order to do
  it. Whether the native engine then holds or flees is engine dispatch, `[U]`-G1e
  (kept, with its F100 capture, §6-R2).
- Runaway mode is also an *exclusion* (not an entry) in gather/target/end-point logic
  `[O]`: `miscext.script:1225,1258,1274`; `unit.inc/nothing.inc:262-264`;
  `onendpointreached.inc:19` (DFORM-01 §(a)). Exact exclusion semantics per site NOT
  transcribed — [U]-R3, never invented.

## 4. Fear setting / clearing sites (`units/global.inc/progresswarai.inc`, ALL `[O]`-text `[*]`)

- **Set site (primary)** `:2798-2832`: `myForce = squad0 count`; per enemy army with
  `landCount > 0`: `enForce = cavalry + infantry + shooters` (mortars commented OUT,
  `:2810`); `dist < 30 and enForce > myForce → fear := true` (skip attack);
  elif `dist < 400 and enForce <= myForce and dist < nearDist` → track nearest weaker
  (`:2832-2838`: `not fear and nearDist < MaxInt → _unit_SearchEnemyInCell(go, enX, enY, 4)`).
- **Fallback track** `:2892-2903`: `enForce > 6 and dist < 40 and dist < minDist` →
  retreat-to-safe-position path (`:2907+`).
- **Clearing site: NOT FOUND in any read line.** No `fear := false` reset, no
  per-tick/per-army re-initialisation, no scope/lifetime statement was transcribed in
  GUARD-SAMPLER, AI-THRESHOLDS, TABLES, or DFORM-01. Whether `fear` is a per-call
  local (re-initialised each invocation) or persists across ticks is therefore
  `[U]-R7` — the single largest fear unknown. Never assume auto-clear per frame.
- **Fear writes NOTHING else in the visible text `[O]`-text:** no stat, no rout meter,
  no guard-list add/remove, no order write (GUARD-SAMPLER §5). Fear NEVER touches
  `guards/defenders/freewarriors/agressors` membership in any read line.
- **Activation caveat (header of AI-THRESHOLDS):** every `progresswarai.inc` line is
  `[*]`-stored text. Literals (30 / 400 / 4 / 6 / 40) are `[O]`-text; engine execution
  of the selector is itself `[U]` until proven.

## 5. Interaction with target selection

- Fear path (TEXT): sets skip-attack for the outmatched army; otherwise selects the
  nearest weaker enemy and performs ONE cell search of radius 4
  (`_unit_SearchEnemyInCell(go, enX, enY, 4)`, `:2832-2838`). `SearchEnemyInCell`
  internals (fplmask/enemyplmask scan, `:4832-4850`) are LIVE (GUARD-SAMPLER P14) but
  the fear call-site passing `4` is TEXT-gated with the selector.
- Runaway path (LIVE): fires inside victim-search/attack evaluation on a
  sub-`minsearchdist` threat; moves own unit away; never calls `SearchEnemyInCell`
  and never sets `fear` on any read line.
- Cross-writes found: NONE. No read line shows fear causing runaway, runaway causing
  fear, or either touching guard lists or `standtime`. The port implements them as two
  disjoint mechanisms (§7 items 3–4) and proves the disjointness per-run (R2).

## 6. Still-`[U]` register — fixed-seed combat captures, zero-mismatch termination

General harness (all items): pin `t_87f0f3c130b0` donor texts; fixed fixture seed
`(key0=0x44A108F9, key1=0x00000001)` per RNG-LEDGER §4-S6/X21 §5; headless fixed-`dt`;
canonical JSON state hash (players, entities, four AI lists + per-building defenders,
RNG S/G counters, `guardsCount/guardsTotal`, order0 itype/progress, `standtime`,
`fear` locals where observable). Process-attached donor observation only (donor binary
never executed BY THIS WORKER — captures are owner-authorised replays, results compared
as hashes). **Termination: run the FULL series; ANY single mismatch vs the stated donor
expectation keeps the item `[U]` and forbids wiring; zero mismatches across the FULL
series closes it.** Never fit/invent a usage gate, draw, stream, distance, or reset.
No text-only row is activated by a capture — captures only CONFIRM; activation of
`[*]` rows additionally requires the `[*]`-binding proof (AI-THRESHOLDS header).

| # | Item | Static state after this ticket | Exact capture (owner-authorised; no donor binary by worker) |
|---|---|---|---|
| R1 | Runaway unit eligibility (which usages enter) | Gate `:7366-7368` grounded §1.3; per-usage eligibility NOT transcribed | Series E60: one unit of every `usage` enum value (both `bai`, difficulties 0–4, `standtime` forced 0 then >1.3, fixed sub-`minsearchdist` threat, not standground), log `_unit_DoRunAway` issued/not per unit. Expect: issue pattern matches `:7366-7368` predicate with NO usage term. Pass = 60/60 match, 0 mismatches. Until green, port gates on the verbatim predicate only, never a usage whitelist. |
| R2 | Runaway × guard-order resolution + fear non-interference (adopts GUARD-SAMPLER G1e F100 verbatim) | Runaway gate + guard keep LIVE §1–§3; engine resolution + fear activation `[U]` | Series F100: posted guards + free defenders + agressors, fixed threat at sub-`minsearchdist`, both `bai`, difficulties 0–4, `standtime` 0/>1.3; log `_unit_DoRunAway` issues + order0 itype/progress + guard-list membership before/after; parallel fear setup (`dist<30` stronger / `dist<400` weaker) asserting NO guard-list delta. Pass = runaway issues match `:7366-7368` gate 100/100 AND guard lists unchanged by fear runs, 0 mismatches. |
| R3 | Runaway-as-exclusion sites (`miscext` / `nothing.inc` / `onendpointreached.inc`) | Cite-only pointers from DFORM-01 §(a); semantics NOT transcribed | Series X30: drive gather/target/end-point flows with order0 = move/runaway preset vs normal move, log branch taken at `miscext.script:1225,1258,1274`, `nothing.inc:262-264`, `onendpointreached.inc:19`. Expect: exclusion taken exactly when `_unit_IsRunAway` true. Pass = 30/30 match, 0 mismatches. Until green, port models ONLY the `:7175-7179` predicate as data, never the exclusion behaviour. |
| R4 | Second trigger `:7603` + standground search `:8415-8433` exact predicates | `:8151-8153` duplicates `:7366-7368` `[O]`; `:7603`/`:8415-8433` predicates NOT transcribed | Series T40: standground shooters + moving shooters vs closing threat at `minsearchdist ± ε`, difficulties 0–4; log victim-search branch + runaway issue at each of `:7366-7368`, `:7603`, `:8151-8153`, `:8415-8433`. Expect: `:7366-7368` = `:8151-8153` always; `:7603`/`:8415-8433` logged as-observed (noLantern). Pass = 40/40 on the two grounded sites, 0 mismatches; `:7603`/`:8415-8433` rows stay `[U]` until their predicates are transcribed + matched. |
| R5 | RNG-stream attribution on the runaway path | No draw in any read line; NOT proven draw-free | Series D50: fixed X21 vector, G counter snapshotted around each `:7366-7368`/`:8151-8153` evaluation + each `_unit_DoRunAway` motion; log S/G counter deltas. Expect: zero S draws, zero G draws on this path. Pass = 50/50 runs with 0 deltas, 0 mismatches. Any delta → site recorded as drawing + stream labelled, never ignored. |
| R6 | `searchvictimattargetdist=6` vs `:8427` literal-6 identity | Both `[O]`; identity `[D]`-suspect only | Series V20: vary `gc_unit_searchvictimattargetdist` donor-side (owner-authorised config probe) or transcription-compare `unit.script:8415-8433` full text; log `:8427` radius argument. Expect: argument is the literal `6` or the named const — recorded, never assumed. Pass = verbatim text match, 0 mismatches. |
| R7 | Fear scope/lifetime/clearing (biggest fear unknown) | Set sites `[O]`-text §4; NO clearing site found | Series C40: force `fear:=true` setup (`dist<30`, stronger enemy), then remove the threat (move enemy beyond 400 / destroy it) and step the AI; log `fear` value + attack resumption tick over 40 runs. Expect: recorded as-observed (local re-init vs persist). Pass = deterministic lifetime rule reproduced 40/40, 0 mismatches, PLUS full `[*]`-binding proof for the selector before any port wiring. Until then `DONOR_AI_FEAR_*` stays data-only. |

## 7. Concrete port change list for `ai.gd` / `game.gd` / `data.gd` (this worker edited nothing)

All items add DONOR-VERBATIM values or explicitly labelled placeholders. None invents a
usage gate, distance, delay, draw, stream, or reset. None touches save version, existing
keys, or I11 seam paths. User `config.json` overrides win over every default below.

1. **`data.gd:1637-1640` — FIX `DONOR_AI_FEAR_*` comments to §4 (values unchanged).**
   `DONOR_AI_FEAR_NEAR := 30.0` ← `progresswarai.inc:2805` (`dist<30 and enForce>myForce → fear`,
   `[DONOR-TEXT]`); `DONOR_AI_FEAR_TRACK := 400.0` ← `:2812` (`dist<400` nearest-weaker track,
   `[DONOR-TEXT]`); ADD `DONOR_AI_FEAR_CELL_R := 4` ← `:2832-2838`, `DONOR_AI_FEAR_FALLBACK :=
   {enforce_gt: 6, dist_lt: 40}` ← `:2892-2898`, all tagged `[DONOR-TEXT][U]-R7`; ADD comment
   `fear clearing site NOT FOUND in read text — no auto-clear assumed`.
2. **`data.gd` (near `:1630-1637`) — ADD runaway const block (values already in `ai.gd:1054-1055`; cite here).**
   `DONOR_RUNAWAY_DELAY := 1.3` (`dmscript.global:198`); `DONOR_RUNAWAY_DIST := 3.5` (`:199`);
   `DONOR_RUNAWAY_MODE := 2` (`:657`); `DONOR_SEARCHVICTIM_AT_TARGET_DIST := 6` (`:197`,
   identity with `:8427` arg `[U]`-R6). Tag the block `[LIVE] unit.script:7175-7239`.
3. **`ai.gd:1116-1126` (`DONOR_TARGET` fear rows) — keep DATA-ONLY, tag `[U]`-R7.**
   No behaviour change. Append per-row `[DONOR-TEXT]` + clearing-unknown pointer to §6-R7.
   Do NOT add a `fear:=true` branch or a `SearchEnemyInCell(...,4)` call anywhere in runtime
   until R7 passes with the `[*]`-binding proof.
4. **`ai.gd:1276-1277` (fear/runaway rows) — PROMOTE runaway half to `[LIVE]`, keep fear half TEXT.**
   `shooter_runaway_gate` stays verbatim (`standtime = 0 / > 1.3 / non-AI and diff <= normal`,
   `us:7366-7368 [LIVE]`) and becomes the SOLE gate of the new runtime helper (item 5);
   `fear_non_interference` stays `[DONOR-TEXT][U]-R7` (never called).
5. **`ai.gd` runtime (movement/combat, cf. GUARD-SAMPLER §7 item 6) — wire ONLY the live runaway gate (R2-gated).**
   New `_unit_do_runaway(victim, threat)` implementing §1.2 verbatim
   (`deltadst = clamp(minsearchdist - dst, 3*eps, 3.5)`, point away from threat, clamp
   `±(hm-0.25)`, drop pre-existing runaway order, issue move with mode 2), called ONLY
   under the verbatim §1.3 predicate (no usage whitelist — [U]-R1). Guard-order keep
   (`:7337-7340`, never strip guard to retarget) rides along. Until R2 green: helper
   present but UNCALLED, labelled `[U]`-R2. `fear` and `SearchEnemyInCell(...,4)` are
   NOT referenced by this helper.
6. **`game.gd` spawner/tick/save — ADD live-runaway plumbing only (no behaviour until item 5 wired).**
   Per-unit: record `standtime`, `standground`, owner `bai`, difficulty at the analogue of
   `unit.script:7366-7368` so the gate CAN run; order0 carries `{itype, progress}` with
   `progress = 2` meaning runaway (`:7175-7179`). Save: ADD key `order_runaway : bool`-equivalent
   (order0 itype/progress already persist per GUARD-SAMPLER §7 item 5 — reuse, do not duplicate);
   never rename/remove existing v5 keys, never bump version. `fear` gets NO save key
   (no donor field found — adding one would invent state).
7. **Telemetry/format.** Every value above carries `unit.script:<line>` /
   `progresswarai.inc:<line>` / `dmscript.global:<line>` / `control.script:<line>` /
   `miscext.script:<line>` cite in comment; every remaining estimate keeps
   `PORT APPROXIMATION` + `[U]` tag with its §6 series; `visual_parity_claim=false`;
   unresolved = [R1…R7 above + G1a…G1f per GUARD-SAMPLER §6 + U-A1…U-A8 per AI-THRESHOLDS §8
   + G1-a…G1-h per RNG-LEDGER §5]. `ai.gd` stays the ONLY behaviour file these items touch
   (plus its `data.gd` consts and `game.gd` spawner/save plumbing); no other
   `variant3d/scripts/*.gd` changes in this workstream.

## 8. Explicit non-claims and file discipline

- NO PARITY CLAIM. No donor binary executed, no donor GPU frame captured, no port capture
  compared. Live items rest on donor text `[O]` with file:line; TEXT items are labelled with
  their `[*]` activation caveat; open bits list exact captures in §6.
- Two scope corrections disclosed, not smoothed over: (a) AI-THRESHOLDS §1 line-window
  `:195-200` vs DFORM-01 `:198-199` is the SAME two literals (delay 1.3 / dist 3.5), not two
  sources; (b) the "make shooters less annoying" notes (`:7367`, `:8152`) are `//` intent
  comments, never eligibility proof — R1 stays open because of them, not closed by them.
- One absence disclosed as load-bearing: NO `fear := false` / re-init site exists in any
  read line (R7). The port must not assume per-frame auto-clear.
- No approximation substituted for a resolved law. Per-usage runaway eligibility, exclusion
  semantics, `:7603`/`:8415-8433` predicates, runaway-path draws, const-vs-literal identity,
  and fear lifetime stay `[U]` with zero-mismatch captures; the port must hard-fail or label,
  never silently substitute.
- Read-only compliance: exactly one repo file written (this report). All donor passes were
  text re-reads of prior-ticket transcripts pinned to `t_87f0f3c130b0` plus read-only repo
  inspection; shared investigation memory was read, never written; no target opened/selected;
  no code/asset/config/Godot/git edit.

*End of DEC-U-FEAR-RUNAWAY.*
