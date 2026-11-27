---
id: DEC-U-MORALE-AUDIT
worker: AUDIT-MORALE (subagent in full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
ticket: "Audit every remaining morale/famine-grace reference in variant3d/scripts/*.gd"
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
labels: [O, D, I, U]
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. Donor binary never executed/copied. Donor text scripts read as text only. No repo code/asset/config/Godot/git change: this report is the only file written."
network: "OUT OF SCOPE."
parity: "UNVERIFIED. No donor GPU A/B frame; no donor binary executed by this worker. No behaviour change. No parity claim."
upstream: "DEC_U_skirmish.md + DEC_U_skirmish_impl_patch.md + IMPL-SKIRMISH-LAWS; DFORM-01 morale-absence (via DEC-02/D-U cites); DEC_U_fear_runaway.md"
---

# DEC-U morale audit — every remaining morale/famine-grace reference (2026-11-26)

## 0. Authority and verdict up front

Donor ground truth (all pinned `t_87f0f3c130b0`, multiple passes):

- **Donor has NO numeric morale.** `DEC_U_skirmish.md` §2.6: greps over
  `data/scripts/lib` (+units/miscext) for `morale|rout|panic|flee|veteran|experience`
  → **0 matches**; `bfamine|bFamine|starv|hunger` → only `bfamine/bFamine` boolean +
  profile flag (`classes.script:3695,5122`; `player.script:122,295,304,320-321`;
  `profile.script:39`). DFORM-01 absence claim holds (cited via
  `DEC-02 §7.8 / decomp/DEC_02_scripts.md:984-986` +
  `reports/DFORM_01_formations_morale.md:149-218` in `data.gd:407-424`).
  Expected-negative binary passes `t_87f0f3c130b0`: P3
  `core_feature_find "RandomExt"/"bfamine"/"famine"`
  `ev_c3804981595ae8e32f7250a675c54ac38863fa5625a840905922e4652a93981f4`
  (0 hits — script-side, as designed); P4 `native_bytes_find "victorystate"+"bfamine"`
  negative; P5 `0D FC` pattern `ev_4dd1780e0bbdb16190c7009abf5f33f0a0d90092007f04019e45dd25ee1025bf`
  rejected as non-specific (`DEC_U_skirmish.md` §1 P1–P5).
- **Donor famine/rebellion EXISTS and is exact law.** `DEC_U_skirmish.md` §2.1 +
  impl-patch §1: `data/scripts/units/unit.inc/nothing.inc:450-506` (gate
  `gProfile.bFamine ∧ gPlayer[plInd].bfamine ∧ bplayable`, mode game/spectator,
  `not building ∧ not bnohungry`; inside-of-mine `:456-479` commented-out dead);
  death roll `:482`
  `(((difficulty>1) or lan_cached) and (RandomInt<50)) or ((difficulty=0) and
  (RandomInt<5)) or ((difficulty=1) and (RandomInt<12))` →
  `_unit_SetTagStates(go, essential_death)`; `_misc_RandomInt`
  `lib/misc.script:493-498` = `floor(random*gc_c1rand_to_random)`,
  `gc_c1rand_to_random=32768` (`dmscript.global:176`); rebellion `:487-497`
  gate `brebellion ∧ bmercenary ∧ (plInd<>mercenaryind) ∧ bplayable`,
  flip `(diff>1 ∧ RandomInt<6000) ∨ (diff=0 ∧ RandomInt<100) ∨ (diff=1 ∧ RandomInt<200)`
  → `_misc_ChangePlayer(go, mercHnd, False, False, True)`; upkeep engine
  `lib/player.script:270-322` (mult=100, speed=20000, `gc_time_to_frames(32)`,
  set/clear `:294-321`); **no grace timer, no HP drain**
  (`DEC_U_skirmish.md` §2.1; impl-patch: "`FAMINE_GRACE_S=120` /
  `FAMINE_DRAIN_PER_S=0.3` are a wrong-shape PORT INVENTION and must stop being
  consumed").
- **Donor squad/runaway replacement (not a morale meter).**
  Disband = count fraction `count < basecount*0.25` (rank-and-file, human-only;
  `dmscript.global:156; progress.inc:5-35,174-175; lib/squad.script:98-107`);
  shooter retreat = move-order mode `gc_obj_order_move_mode_runaway=2`,
  `runawaydelay=1.3, runawaydist=3.5` (`dmscript.global:198-199,657`;
  `lib/unit.script:7175-7238`; `miscext.script:628,1225,1258,1274`)
  (`data.gd:412-417`; `game.gd:6710-6715`; `DEC_U_fear_runaway.md` P5).
  The `*0.25` literal was **not re-read** this-ticket → replacement wiring stays
  `[U]` (`DEC_U_skirmish.md` §2.6/M1, §3-M1, §9-M1).

Classification key used below:

- **(a)** donor-absent, port-only extension, already correctly labelled
  `PORT APPROXIMATION / PORT INVENTION / DEPRECATED` → keep label, no code touch.
- **(b)** donor-present but unresolved `[U]` (donor law recovered, one sub-fact
  uncited) → keep explicit `[U]` tag, label-only.
- **(c)** accidentally unlabelled approximation that implies donor behaviour →
  needs a label-only comment patch (no behaviour change).

No behaviour change is made or proposed beyond comments. Parity UNVERIFIED.

## 1. Complete site register (current `variant3d/scripts/*.gd`)

Line numbers are as-read this pass; re-anchor by function name + verbatim text
(the tree is concurrently edited — cf. `DEC_U_collision_full.md` convention).

### 1.1 `data.gd` — constants + labels

| Site | Text | Class | Donor evidence | Remediation (label-only) |
|---|---|---|---|---|
| `data.gd:33` | `U10 morale (donor has NONE)` index comment | (a) correctly labelled | §2.6 0-hit grep | none — keep |
| `data.gd:407-424` | `PORT APPROXIMATION — INVENTED, NO DONOR EQUIVALENT` header (DEC-02 §7.8, DFORM-01 :149-218, 2,559 files / 373 code files 0 hits, `fear` only `progresswarai.inc:2799-2832`, disband fraction + runaway mode cites, "video pass estimate", "coincidental decimal match", "Do not delete/retune here") | (a) exemplar label | §2.6; §2.1 | none — keep verbatim |
| `data.gd:425` `MORALE_BASE := 70.0` | numeric base | (a) invention, labelled by :407-424 | §2.6 0 hits | none (deletion is MORALE-05, out of scope) |
| `data.gd:426` `MORALE_ROUT_THRESHOLD := 25.0` | rout threshold | (a) invention, labelled; comment explicitly denies `0.25` provenance | §2.6; disband `*0.25` not re-read → [U] | none — keep "coincidental decimal match" sentence |
| `data.gd:427-428` `MORALE_OFFICER_RADIUS := 12.0` / `MORALE_OFFICER_BONUS := 20.0` | officer aura geometry + bonus | (a) invention, labelled | §2.6 0 hits; no donor officer/morale radius row cited anywhere | none |
| `data.gd:429-430` `MORALE_DRUMMER_RADIUS := 10.0` / `MORALE_DRUMMER_BONUS := 10.0` | drummer aura geometry + bonus | (a) invention, labelled | §2.6 0 hits; MOVE-SPEED §5.4/§7-S3 full-lib `drummer.*speed\|march.*bonus` grep x0 (`data.gd:435-439`) | none |
| `data.gd:431` `MORALE_LOW_HP_PENALTY := 20.0` | wound penalty | (a) invention, labelled | §2.6 0 hits | none |
| `data.gd:432` `MORALE_FAMINE_PENALTY := 15.0` | famine→morale coupling | (a) invention, labelled (compounds the wrong-shape famine) | §2.1 (donor famine kills directly, never via a morale meter) | none — delete only with MORALE-04..06 |
| `data.gd:433` `OFFICER_DAMAGE_BONUS := 0.15` | officer damage aura | (a) invention, labelled (same header block) | §2.6 0 hits | none |
| `data.gd:434-439` `DRUMMER_SPEED_BONUS := 0.12` + `[O-negative]` comment | drummer speed aura | (a) invention, correctly labelled PORT APPROXIMATION `[U]` U-carry/U-formation family (T-FORM/T-CARRY) | MOVE-SPEED §5.4/§7-S3; `DEC_U_guard_sampler` §5 (runaway = move-mode order, NO speed scalar) | none — keep |
| `data.gd:446-452` `FAMINE_GRACE_S := 120.0` / `FAMINE_DRAIN_PER_S := 0.3` + `DEPRECATED / NOT CONSUMED BY THE SIM (donor has NO grace or HP drain)` | grace + drain | (a) deprecated invention, correctly labelled; resolved law = `floor(rand*32768)` roll in `game.gd` | §2.1; impl-patch §1 ("wrong-shape … must stop being consumed") | none — keep so `config.gd:647-648` still writes a defined static; do NOT rewire consumers to it |
| `data.gd:453-455` `[U]-U11-P` comment | `gProfile.bFamine` default uncited | (b) donor-present but unresolved | `profile.script:39` cited as experiment target, not as read literal (`DEC_U_skirmish.md` §2.1; impl-patch §1) | keep `[U]-U11-P` tag; settle only by reading `profile.script:39` + menu `famine` key default (experiment §9-U11-P) |
| `data.gd:456` `FAMINE_PROFILE_ENABLED := true` | port gate for the resolved roll | (b) labelled port gate, NOT a claimed donor literal | §2.1 gate law resolved; default itself [U] per :453-455 | keep; do not claim as donor literal |
| `data.gd:457-462` `PORT_MORALE_FAMINE_ENABLED := true` quarantine marker | explicitly "NOT read by any consumer", "Changing this value ALONE has NO effect" | (a) correctly labelled inert marker | §2.6 | none — wiring it is MORALE-03, retiring behaviour MORALE-04..06 |
| `data.gd:978-992` `SQUAD_XP_PER_KILL/PER_BONUS/CAP` + header (`experience`/`veteran` 0 donor hits, `INVENTION. LABEL ONLY`) | veteran/XP hardening | (a) invention, labelled | DFORM-01 :210 (0 code hits); donor tuples fixed per `formations.cfg`, snapshotted at set-time (`lib/player.script:809-812`) | none — removal is MORALE-05 |
| `data.gd:1725` `famine_rebellion: floor(random*32768) / misc.script:493-498 / G` | RNG ledger cite | donor-present resolved law | §2.1; `dmscript.global:176` | none |
| `data.gd:3842,3873,3956,3965,3981,4563` | `routing`/`route` words in move-speed/carry/ledger comments | false positives (path/credit routing, NOT morale rout) | n/a | none — optionally disambiguate "route (path)" vs "rout (morale)" if touched, not required |

### 1.2 `game.gd` — behaviour (all behaviour KEPT; labels only)

| Site | Text | Class | Donor evidence | Remediation (label-only) |
|---|---|---|---|---|
| `game.gd:20` | `U11/U10 (config.gd keys + selftest.gd morale …)` scope note | (a) pointer label | §2.1/§2.6 | none |
| `game.gd:495,508-511` player dict `"famine_t", "famine", "rebellion", upkeep_remains/resonlife` | `famine`/`rebellion` booleans = donor `bfamine`/`brebellion`; `famine_t`/`gold_famine_t` accumulators = port compat (v5 save + HUD) | mixed: flags (b-resolved, cf. §2.1 `player.script:294-321`); timers (a) port extension, already labelled "stay for v5 save + HUD compatibility" | §2.1 | none — do NOT delete timers (save compat); do NOT claim timers as donor |
| `game.gd:3108-3109` spawn `morale: Data.MORALE_BASE, routing: false … aur_off/aur_dru: false` | invented per-unit morale state | (a) invention, covered by `game.gd:6710-6719` + `data.gd:407-424` labels | §2.6 | none |
| `game.gd:4274` `e["routing"] = false` (reset helper) | rout flag reset | (a) part of invented stack | §2.6 | none |
| `game.gd:4978-4997` `officer_near` / `drummer_near` (`MORALE_OFFICER_RADIUS`, `MORALE_DRUMMER_RADIUS`) + `:4978` `Officer aura … raises damage, drummer raises speed/morale` | aura predicates | (a) invention, labelled via data header + §7-S3 note | §2.6 0 hits | none — keep; recommended one-line touch IF edited: append `PORT INVENTION — no donor officer/drummer morale radius` to the `:4978` comment (currently the only aura comment without the word PORT). (c)-adjacent but already covered by the cited constants; lowest priority |
| `game.gd:5028-5034` `effective_speed`: `aur_dru → ×(1+DRUMMER_SPEED_BONUS)` `PORT APPROXIMATION +12% [U]`, `routing → ×1.35` `PORT APPROXIMATION [U] … donor runaway has no speed scalar` | speed auras | (a) correctly labelled | §7-S3; guard-sampler §5 | none — keep verbatim |
| `game.gd:5036-5045` `effective_damage`: `officer_near → ×(1+OFFICER_DAMAGE_BONUS)` | damage aura | (a) invention; label lives on constant + `:7168` comment, NOT on this branch | §2.6 | (c) → add trailing ` # PORT INVENTION — no donor officer damage aura (U10)` to `:5043-5044` IF the line is ever touched; do not touch it for this alone |
| `game.gd:5669-5671` `FAMINE_ROLL_HARD := 50 / NORMAL := 12 / EASY := 5` | resolved donor thresholds | donor-present RESOLVED | §2.1 (`nothing.inc:482`); impl-patch §1 | none |
| `game.gd:5689` `draw is routed through sim_rng and LABELLED` | RNG stream label | donor value-claim withheld, stream `[U]-G1` | D02/X21/V01 | none |
| `game.gd:5863-5923` `_tick_upkeep_for_player`: upkeep bank + `bfamine/brebellion` set/clear (`:5886-5893` clear `iff res[food]>0 / res[gold]>=2`; `:5902-5918` set on shortfall, gold-gated on `consume>income`, `NO grace, no HP drain`) | resolved donor upkeep/flag law | donor-present RESOLVED | §2.1 (`player.script:270-322`); mine rate note `:233-238` stays open (shape re-check, not morale) | none — keep `RESOLVED` + `NO PARITY CLAIM` comments |
| `game.gd:6041-6045` `_nav_wanted`: comment `dynamic chases (attack/guard/rout)`, branch `if routing: return false` | `rout` = the invented morale-rout flag suppressing A* | (a) invented-stack consumer; comment word `rout` is correct in context | §2.6 | none — optionally spell `rout (morale-rout flag, PORT INVENTION)` if touched |
| `game.gd:6358-6383` `_tick_unit`: `:6359-6361` RESOLVED famine roll replaces grace/drain; `:6369-6370` aura sampling + `[U] U-formation/U-walkinterval — aura cadence PORT APPROX`; `:6378-6380` `video pass: morale … _update_morale(e, dt)`; `:6381-6383` rout gate | call sites | (a) morale side labelled; famine side resolved | §2.6 / §2.1 | none |
| `game.gd:6668-6708` `_tick_famine_rebellion` (+ header: RESOLVED roll, `gProfile.bFamine` default `[U]`, `bplayable/spectator`, `bnohungry`, mercenary tail `[U]-U11-M`) | resolved donor roll | donor-present RESOLVED except two explicit `[U]`s | §2.1 (`nothing.inc:450-506`, `misc.script:493-498`, `dmscript.global:176`) | keep both `[U]` tags open: (1) `gProfile.bFamine` default / menu key (§9-U11-P); (2) rebellion owner-flip target — port has no mercenary sid/slot, do NOT invent one |
| `game.gd:6710-6742` `_update_morale` (+ `:6710-6719` 10-line `[U] U10` PORT-INVENTION header) | whole numeric morale stack: recover-to-`want` ± officer/drummer/low-hp/famine terms, rate 6.0/3.0, rout on `< 25.0` (non-peasant), recover at `> threshold+25.0`, `post_event("rout")` | (a) invention, correctly labelled | §2.6 (0 hits; disband fraction + runaway mode are the donor replacements); blocked consumers `ai.gd:855`/`selftest.gd:411-415` named in header | none — keep header + behaviour; decomp plan MORALE-02..06 stays blocked as stated |
| `game.gd:6744-6769` `_tick_rout` (flee-to-home steering, 12 s cap) | invented rout locomotion | (a) invention under the same header | donor runaway = `move_mode_runaway=2` order, no 12 s / home-building law cited | none |
| `game.gd:7168` `officer aura + researched powder upgrades multiply the listed damage` | aura comment | (a) invention-adjacent; powder part is donor, aura part is port | §2.6 | (c) → IF touched, split: `officer aura (PORT INVENTION, U10) + researched powder upgrades (donor) multiply …`; do not touch for this alone |
| `game.gd:7310` `t["morale"] = 70.0` on peasant capture | invented reset (literal duplicates `MORALE_BASE`, not `Data.MORALE_BASE`) | (a) invention | §2.6 | (c) → IF touched, use `Data.MORALE_BASE` + trailing ` # PORT INVENTION (U10)`; value identical (70.0), behaviour unchanged; do not touch for this alone |
| `game.gd:7363-7365` `morale shock when hit … - 4.0` | invented hit shock | (a) invention; adjacent splash comment IS labelled, this branch relies on the `:6710` header | §2.6 | (c) → IF touched, append ` # PORT INVENTION (U10) — no donor morale-shock law`; do not touch for this alone |
| `game.gd:7410-7415` `_morale_shock` (`- 6.0` in 10 m) | invented AoE shock | (a) invention under the same header | §2.6 | same (c) conditional label as above |
| `game.gd:8887,9295` save lines `bexists,bgeology,bballoon,bfamine,brebellion,bai,bneutral` | donor flag names in save framing | donor-present shape `[O-shape]` | §2.11 (write*.inc/read*.inc pairs enumerable; byte framing still `[U]` §9-R1) | none — byte contract stays [U]-R1 |
| `game.gd:9481` `S1: famine/rebellion RandomInt=floor(random*32768) (G-attributed, [U]-G1-g)` | RNG ledger | resolved shape, stream `[U]` | §2.1 + D02/X21 | none |

### 1.3 `config.gd` — tunables passthrough (deprecated but present)

| Site | Text | Class | Remediation (label-only) |
|---|---|---|---|
| `config.gd:167-168` defaults `"morale_base": 70.0, "morale_rout_threshold": 25.0` | (a) deprecated invented defaults | none — removal retunes/deletes; MORALE-05 scope |
| `config.gd:173-174` defaults `"famine_grace_seconds": 120.0, "famine_drain_per_second": 0.3` | (a) deprecated wrong-shape defaults, superseded by resolved roll | none — keep so `Data.FAMINE_*` stays defined (`data.gd:446-452`); must NOT be consumed by sim |
| `config.gd:641-642` `Data.MORALE_BASE/ROUT_THRESHOLD = num(...)` | (a) passthrough | none |
| `config.gd:647-648` `Data.FAMINE_GRACE_S/DRAIN = num(...)` | (a) deprecated passthrough, NOT consumed by sim (verify: zero readers — see §2) | none |
| `config.gd:644` `DRUMMER_SPEED_BONUS`, `config.gd:169-170` officer/drummer economy keys | (a) same invented-aura family | none |

### 1.4 `ai.gd` / `selftest.gd` — consumers / harness

| Site | Text | Class | Donor evidence | Remediation |
|---|---|---|---|---|
| `ai.gd:52,400` `AI_FAMINE_WOODSTONE_FLOOR := 4` + cite `progresseconomicai.inc:795-799` "always have 4 peasants for wood and stone" famine recall | donor-present AI sampler literal (NOT morale) | DEC_U_skirmish §2.11-adjacent grounded literal | none — keep cite; not a morale system |
| `ai.gd:893-907` `_waves`: count `routing`, `if routing > maxi(3, size/4): retreat_t = 20.0`, retreat Regression | (a) invented-stack consumer (reads the port `routing` flag) | §2.6; header-blocked consumer (`game.gd:6717`) | none — gating/removal only with MORALE-04..06 + AI rewrite |
| `ai.gd:1331` (also `.bak-*` copies) `morale/rout 20 s -- no donor literal` | (a) correctly self-labelled | §2.6 | none; `.bak-*` files are not live code (ignore) |
| `ai.gd:1887` `fear writes NO stat/rout/guard-list/order` | donor-grounded fear note (the only `fear` = AI target-selection bool `progresswarai.inc:2799-2832`) | §2.6 | none |
| `selftest.gd:11,23` `"morale"`, `formations_morale` step lists | (a) harness exercises the invented stack | §2.6 | none — weakening/removal only with MORALE-05 + replacement trace (M1) |
| `selftest.gd:411-421` `video pass: officer holds morale, routing recovers` (`morale=10 → tick → assert morale>10 ∨ ¬routing`) | (a) asserts the invented model; header-blocked (`game.gd:6718`) | §2.6 | none |

## 2. FAMINE_GRACE / FAMINE_DRAIN consumption proof (multiple passes)

- `FAMINE_GRACE_S`: defined `data.gd:451`, written `config.gd:647`; **zero live
  readers** — the only file-line resembling a reader is the REMOVED shape in
  `DEC_U_skirmish_impl_patch.md` §1-patch (`if famine_t >= Data.FAMINE_GRACE_S`
  + `hp -= DRAIN*dt` + `morale -= 10*dt`), which the live `_tick_upkeep_for_player`
  (`game.gd:5863-5923`) does NOT contain (live code sets flags + timers only,
  drains nothing). Confirmed by grep: no `FAMINE_GRACE_S` / `FAMINE_DRAIN_PER_S`
  hit in `game.gd` outside the deprecation comment.
- `FAMINE_DRAIN_PER_S`: defined `data.gd:452`, written `config.gd:648`;
  **zero live readers** (same proof).
- Live famine path is the resolved roll only:
  `_tick_upkeep_for_player` (flags) → `_tick_famine_rebellion` (50/12/5 +
  6000/100/200, `FAMINE_PROFILE_ENABLED` gate) — `game.gd:5669-5671,5863-5923,6668-6708`.
- Therefore the task-brief phrase "deprecated but present" is accurate, and
  "present" means *defined + configurable*, never *consumed*. No resurrection:
  do NOT route any hp/morale/grace logic through these two statics.

## 3. Aura-branch audit (all aura sites listed — none missed)

`officer_near` (`game.gd:4979`), `drummer_near` (`game.gd:4989`),
`aur_off/aur_dru` sampling (`game.gd:6369-6370`, cadence labelled
`[U] U-formation/U-walkinterval`), `effective_speed` drummer ×1.12 + routing
×1.35 (`game.gd:5030-5033`, labelled), `effective_damage` officer ×1.15
(`game.gd:5043-5044`, (c)-conditional label above), `_update_morale` aura terms
(`game.gd:6726-6729`, labelled), `_priest_heal` (`game.gd:6771-…`, video-pass
estimate under the same invention header — heal radius/rate are
`PRIEST_HEAL_RADIUS/PER_S`, likewise donor-absent per `data.gd:407-424`).
Every aura branch either carries its own PORT label or sits under the
`data.gd:407-424` / `game.gd:6710-6719` headers. No unlabelled aura branch
implies donor behaviour except the four (c)-conditional one-liners above, all
of which are *fix-if-touched*, never *fix-now*.

## 4. Remediation list (label-only; no behaviour, no parity claim)

1. Keep every (a) label verbatim — especially `data.gd:407-424`,
   `data.gd:446-462`, `game.gd:5028-5034`, `game.gd:6710-6719`.
2. Keep both (b) `[U]`s open: `[U]-U11-P` (`gProfile.bFamine` default /
   menu key; experiment: read `profile.script:39` + menu `famine` default),
   `[U]-U11-M` (rebellion owner-flip target; do NOT invent a mercenary
   faction/player), `[U]-G1` stream attribution, `[U]-R1` save bytes.
3. The four (c) conditional one-liners (`game.gd:4978`, `game.gd:5043-5044`,
   `game.gd:7168`, `game.gd:7310`, `game.gd:7363-7365/7410-7415`) get a
   `PORT INVENTION (U10)` trailer **only if the line is otherwise edited**.
   No edit is authorised by this audit.
4. Do NOT: delete/retune any MORALE/FAMINE constant (MORALE-05 scope); wire
   `PORT_MORALE_FAMINE_ENABLED`; consume `FAMINE_GRACE_S/DRAIN`; invent a
   mercenary sid, a `*0.25`-wired disband, a runaway scalar, or any morale
   meter value. Replacement wiring stays `[U]` until experiment §9-M1
   (`squad.script:98-107` + `dmscript.global:156` + `progress.inc:5-35` +
   `CheckSquadsDisband` re-read, then the 4:1-butcher runtime trace).
5. Parity stays UNVERIFIED. This report makes no 1:1 claim for any site above;
   the RESOLVED famine-roll sites are donor-literal transcription with
   explicitly open neighbours (profile default, mercenary target, stream,
   save bytes), not a parity certificate.

## 5. Pass ledger (owner rule)

- Pass 1: full-tree `morale|MORALE|FAMINE_GRACE|FAMINE_DRAIN|PORT_MORALE|_update_morale|aura|rout|famine` grep over `variant3d/scripts/*.gd`
  (live files + `.bak-*` excluded from register); every live hit dispositioned in §1.
- Pass 2: per-site context reads (`data.gd:400-469,970-992`; `game.gd:505-511,3095-3110,4970-5045,5860-5923,6038-6045,6350-6383,6660-6779,7160-7174,7300-7420`;
  `config.gd:155-184,630-659`; `ai.gd:45-64,890-919,1325-1335,1880-1890`;
  `selftest.gd:405-429`) — confirmed zero live `FAMINE_GRACE/DRAIN` readers.
- Pass 3: donor re-anchor (`DEC_U_skirmish.md` §1 P1–P5 evidence ids, §2.1
  `nothing.inc:450-506` / `misc.script:493-498` / `dmscript.global:176` /
  `player.script:270-322`, §2.6 absence grep + runaway/disband cites,
  §3-M1/§9-M1 open experiments; impl-patch §1 patch text; `DEC_U_fear_runaway.md`
  P5) — every classification above cites its line.
- Donor binaries never executed; donor text read as text only
  (binary-side P1–P5 cites are prior-ticket records, not new runs).
