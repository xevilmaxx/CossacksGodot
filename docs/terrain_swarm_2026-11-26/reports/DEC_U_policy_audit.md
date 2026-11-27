# DEC_U Policy Audit — port extensions / policies / approximations affecting gameplay outcome (2026-11-26)

Status: READ-ONLY audit. No code, config, Godot, or git edit. Donor read-only, never executed.
Parity: UNVERIFIED. No parity claim. No number invented. No approximation passes as donor parity.

Scope: every remaining `PORT EXTENSION` / `PORT POLICY` / `PORT APPROXIMATION` in
`variant3d/scripts/*.gd` and `variant3d/config*.json` that can change a gameplay
outcome (victory, defeat, peace, scoring, AI, economy, movement, combat).
Visual-only labels (terrain blend, water shader, minimap tint, FOW tint, ghost
blink, camera FOV, selection marquee, season tint) are OUT of scope except where
noted as outcome-adjacent.

Classification used throughout:
- (a) provably donor-absent — keep as labelled extension, never a 1:1 gate.
- (b) donor-present but unresolved [U] — keep labelled, needs the cited capture.
- (c) accidentally unlabelled / stale label — remediation is label-only.

Donor report shorthand: VSTART = `DEC_U_victory_start.md`, SCENWIN =
`DEC_U_scenario_win.md`, MENUPEACE = `DEC_U_menu_peace.md`, AITHR =
`DEC_U_ai_thresholds.md`, CARRY = `DEC_U_carry.md`, MOVESPD =
`DEC_U_move_speed.md`, FEAR = `DEC_U_fear_runaway.md`.

---

## 1. Victory / defeat / scoring

### P1. Score-limit victory — (a) provably donor-absent. Keep gated, label-only.
- Port: `variant3d/scripts/data.gd:287-292` (`VICTORY := "destroy_all"`,
  `SCORE_LIMIT := 5000.0`, `PORT_EXTENSION_SCORE_VICTORY := false` with
  `[U]-U12 / PORT EXTENSION` comment); `variant3d/scripts/game.gd:8302-8311`
  (`"score"` branch reachable only behind the named opt-in flag);
  `variant3d/config.json:95-96` (`"victory": "destroy_all"`,
  `"score_limit": 5000`); same keys in `variant3d/config_donor_capture.json:96-97`.
- Donor: VSTART §1.3 `[O-absence]` — `startingsettings.cfg` key grep finds NO
  `victory`/`score`/`scorelimit`/`timelimit` key; the sole
  `victorystate := win` write in readable scripts is scenario-trigger-gated
  (`scenario.script:2995-3062`), never a skirmish auto-rule. SCENWIN §7/P10
  re-confirms ABSENT (sole `timelimit` hit is pause-menu `gc_pause_timelimit`).
- Verdict: (a). The 5000 has no donor counterpart. Current gating (default
  false, never a 1:1 law) is correct.
- Remediation (label-only): keep flag default false; do not default `VICTORY`
  to `"score"`; never gate 1:1 asserts on `SCORE_LIMIT`. Config-side: annotate
  `config.json` `gameplay.victory` / `gameplay.score_limit` as port-only keys
  in `_readme` (currently the `_readme` does not call them out — see §8 C1).

### P2. Team-win — donor law LANDED in game.gd; data.gd comment is STALE — (c) label-only.
- Port: `variant3d/scripts/game.gd:8155-8228` implements the two-phase donor
  law (`_misc_check_end_game`: roster gate over `roster_bexists`/sim teams,
  live gate over `_player_bexists` + `bleave`, win-stamp EVERY live non-leaver);
  `game.gd:8231-8248` `_surrender` (bleave + caller lose stamp, then re-check);
  `game.gd:8281-8317` `_check_victory` runs `_misc_check_end_game()` first,
  then scenario suppression, then peace gate. The old single-winner pick is
  explicitly retired at `game.gd:8312-8317`.
- Donor: SCENWIN §5 EV-E (`miscext2.script:3769-3844`, every global tick via
  `nothing.inc:646`) + team model EV-M (`player.script:2140-2172`); SCENWIN §9
  expressly CORRECTS VSTART §1.4/§5-4 ("no donor team rule / PORT POLICY"
  SUPERSEDED) and orders the §7 rewire that the port has now landed.
- Verdict: behaviour is donor-verbatim to the cited lines (LAN-human fixups
  correctly excluded as net out-of-scope). The defect is documentary:
  `data.gd:293-296` still says `"no donor rule / PORT POLICY" SUPERSEDED; port
  _winner_of_loser/_team_alive stays APPROX (game.gd out of scope)` — that was
  true when written, but `game.gd` is no longer out of scope: the donor law has
  landed there.
- Remediation (label-only): update the `data.gd:293-296` comment to cite
  SCENWIN §5/§7 and point at `game.gd:8168` as the landed implementation;
  retain APPROX only for `_player_bexists` internals (see P3) and the
  `winnerteam` init `-1` (same-outcome port choice per SCENWIN §5 edge note).
  No behaviour change.

### P3. Defeat liveness (`_player_bexists`) — (b) donor-present, unresolved.
- Port: `game.gd:8254-8258` (`_player_bexists`: peasant visible / human-inside-
  transport / built `cen`); `game.gd:8259-8271` `_check_player_exists`
  (first-transition `lose` + `victorystategametime`, `_misc_KillPlayerUnits`).
- Donor: VSTART §1.2/`progress.inc:60-148` (exists scan: peasant
  `visual_none+essential_none` / human inside-transport / built `usage=center`
  `farmused` shape; first-transition lose stamp + kill). Donor tag test is over
  engine state tags; the port maps to `not dead and not hidden` + transport +
  built `cen`.
- Verdict: (b). Liveness heads agree; the tag mapping is the documented gap
  (SCENWIN §7-4: keep as PORT APPROXIMATION with cite).
- Remediation (label-only): keep the APPROX tag on the mapping; close with the
  fixed-seed kill-tick experiment (lose-stamp tick identical over 3 runs).

### P4. Peace gate — (b) donor-present, ordering FIXED, literals/expiry still [U].
- Port: `game.gd:8295-8301` (no victory while `Data.PEACE_TIME > 0` and
  `time_s < Data.PEACE_TIME`, now AFTER `_misc_check_end_game`);
  `main.gd:365-370` + `config.gd:616-617` + `menu.gd:227-246,970-972`
  (menu tag → `DONOR_PEACE_TIME_INDEX_SECONDS` → seconds).
- Donor: MENUPEACE §§1-4 (12-entry enum `dmscript.global:1055-1066`, labels
  `gui.txt:553-575`, choice write `eventcustomgame.inc:60-79` storing the raw
  index, `gfloat_peacetime := _misc_GetPeaceTime(index)` with ×60 at
  `misc.script:4281`, `gbool_peacemode := (index <> default)`,
  expiry `nothing.inc:658-695` with STRICT `>`); SCENWIN §4.3 precedence
  (CheckEndGame ungated BEFORE peacetime expiry; expiry never writes
  victorystate).
- Verdict: (b). Precedence now matches donor (gate after CheckEndGame — the
  VSTART-era "gates _check_victory" wording is superseded, correctly noted at
  `game.gd:8298-8299`). Still [U]: final index→seconds literals (U-tail),
  `ptborder` destroy + minimap refresh on expiry (SCENWIN U-P1), strict-`>`
  boundary at exact equality.
- Remediation (label-only): keep peace as a timed protection rule, never a
  victory condition (VSTART §2: "NO peaceful victory/defeat/liveness write").
  Possible (c) inside the gate, see §8 C2 (time-base label).

---

## 2. AI

### P5. AI tick cadence — (b) donor-present, unresolved U-A6/U-A7.
- Port: `data.gd:399` (`AI_THINK_INTERVAL := 1.0`), `config.gd:662`
  (`ai.think_interval` default 1.0), `config.json:154` / capture `:154`
  (`"think_interval": 1.0`), `ai.gd:24,903` (`think_t`, `retreat_t` consumer),
  `ai.gd:1324` self-labels `1.0 vs donor 2.4 s -- PORT APPROXIMATION, U-A6/U-A7`.
- Donor: AITHR §1 (`TimeProgressAI = 2.4 s`, `dmscript.global:1486`,
  `progressai.inc:6` gate) + §8 U-A6 (binding `[*]` activation) / U-A7
  (plInd-stagger interleave with TICK_ORDER).
- Verdict: (b). Correctly labelled; port ticks 2.4× too often until U-A6/U-A7.
- Remediation (label-only): do not change the 1.0 default before U-A6/U-A7;
  close with the fixed-seed `lastprogressaitime`/`aidata` growth experiment.

### P6. AI food/economy thresholds — (b) donor-present, unresolved.
- Port: `data.gd` AI food/wood/stone thresholds + `ai.gd:31-38,155-158` food
  floors, 45 s horizon, `upkeep*45+230` reserve (`ai.gd:1325` admits the donor
  ladder has NO horizon); `ai.gd:257-268` economy shares 0.50/0.25/0.15
  (`ai.gd:1326` admits donor uses resbalance percent tables);
  `config.json:155-157` mirrors the 260/260/160 triple.
- Donor: AITHR §4 (`requiredFood = resbalance[food][0] + (farmused div 350)*5`,
  ladder 12–85; upgrade caps; mine-idea pacing).
- Verdict: (b). Right family, invented reserve shape. Keep labelled.
- Remediation (label-only): close per U-A1/U-A5 (600 s bestprojects sequence,
  mine-distance reqlevel 3/3).

### P7. AI force gate + quotas + misc constants — (b) donor-present, unresolved.
- Port: `ai.gd:868` `force < 260` wave gate + `ai.gd:676` `force >= 520`
  train-stop; `ai.gd:46-47,683-686` class-population quotas; `ai.gd:1331`
  (`min_cav 6, raid 12, drums/offs 1+bar/2, repair hp<0.7→2, defense 45/25,
  morale/rout 20 s … no donor literal`); `ai.gd:1225` `famine_port_floor 4`
  (same outcome, different mechanism [I]); `config.json:158-159`
  (`attack_force 120` sic — note the config default 120 vs code 260 split, both
  port-side); `data.gd` famine/morale rows.
- Donor: AITHR §2 (agressor raid `>= 5` once per player
  `progresswarai.inc:3562`; per-army `enForce` vs `myForce` with home ×8/×2 and
  3800/200 caps — NO global 260 gate); FEAR donor fear 30/400 as target-select
  bool only; guard-sampler thresholds `3000/6000/10000/20000` divisor 32768.
- Verdict: (b) for the threshold family (right numbers in several rows, wrong
  control loop — e.g. `16/36`, `32/36` are donor `armyMinCount` values applied
  as global quotas, AITHR §7 mismatch 7); the `260` force gate is invented
  (AITHR §7 mismatch 5). Morale/rout numerics are (a), see P9.
- Remediation (label-only): keep every value, keep `DONOR_PORT_GAP_NOTES`
  (`ai.gd:1323-1334`) and `DONOR_U_EXPERIMENTS` (`ai.gd:1338-1347`) as the
  register; close per U-A1..A8. Never treat `[O]`-text literals as proven
  runtime behaviour (AITHR activation notice).

---

## 3. Economy

### P8. Gather cadence / partial-load credit / fisher — (b) donor-present, unresolved.
- Port: `data.gd:347,354-356` (`BUILD_HIT_INTERVAL := 1.25`, self-labelled
  donor ANIM cadence reused as hit cadence, `[U] U-walkinterval`);
  `config.json:119-132` + capture `:119-135` (`interval: 1.25` uniform all
  three resources); `game.gd` `_tick_gather` `carry += 1` with
  `min(carry,hits)` ratio credit; `data.gd:3971-3974` self-labels interval,
  resamount, reston, fisher as PORT APPROXIMATION [U]-CAD/-PART/-FISH.
- Donor: CARRY §2 (per-(action,nation) AAF windows @30 fps: ukr 22/18/18 f, rus
  food 24 f — port 1.25 matches none); §3 (credit ONLY `resamount >=
  hitsneeded` clamped, `portion*eff div 100`, no ratio; partial load retained
  uncredited, same-res top-up, different-res discard `unit.script:5541-5545`,
  standstill `standtime>59`); §5-P-CARRY (fisher continuous
  `floor(rate*dt+progress)` accumulator, `fishingspeed = 12.0`,
  `fishingmax = 1000.0` — no producer fills `e.resamount` today).
- Verdict: (b). `hits` 22/14/20 and `carry` 45/28/40 already equal donor
  `hitsneeded` + `portion` [O-agreement]; the cadence, ratio credit, and fisher
  producer are the open deltas.
- Remediation (label-only — live-sim patch explicitly NOT applied here, owned
  by the carry worker): keep `1.25` tagged; close U-CAD (90/90 inter-hit gaps),
  U-PART (deplete-at-7/22 trace), U-FISH per CARRY §§5-6.

### P9. Morale / famine-grace / market-old-keys — (a) provably donor-absent for the invented behaviour; resolved donor tables already landed alongside.
- Port: `data.gd:425-456` (entire `MORALE_*` block + `OFFICER_DAMAGE_BONUS`
  0.15 / `DRUMMER_SPEED_BONUS` 0.12 self-flagged video-pass estimates;
  `FAMINE_GRACE_S 120` / `FAMINE_DRAIN_PER_S 0.3` marked DEPRECATED, no donor
  grace/HP-drain; `MARKET_RATE 0.65` / `MARKET_DRIFT` / `MARKET_RECOVERY_PER_S`
  marked DEPRECATED display-only; `PORT_MORALE_FAMINE_ENABLED` quarantine
  marker explicitly unread); `config.json:143-150` mirrors
  (`morale_base/rout_threshold`, `officer_damage_bonus`, `drummer_speed_bonus`,
  `priest_heal_per_second`, `famine_grace_seconds`, `famine_drain_per_second`,
  `market_rate`).
- Donor: AITHR §6 (P6–P8 greps: `morale/rout/panic/flee/veteran/experience` =
  0 hits across `data/scripts/lib` — no numeric morale in donor; port
  `MORALE_*`/auras/rout stay PORT APPROXIMATION, delete do not retune);
  `data.gd:468-488` already lands the RESOLVED per-resource market triplets
  (`lib/res.script:180-248`, DEC-U §2.2) beside the deprecated mirrors; famine
  50/12/5 roll law wired in `game.gd` (Patches 1b/1c) per `data.gd:447-449`.
- Verdict: (a) for the invented morale/famine-grace behaviour and the
  deprecated market scalar — keep quarantined/labelled, retire do not retune.
  The landed market triplets and famine roll are data + law, not extensions.
- Remediation (label-only): keep `PORT_MORALE_FAMINE_ENABLED` unread until the
  MORALE-03..06 tickets; keep deprecated mirrors only because `config.gd`/`hud.gd`
  still write/display them.

### P10. Queue / builders / tick guards — (a) port stability guards, labelled; one donor literal already adopted.
- Port: `data.gd:276-278` (`BUILD_QUEUE_LIMIT := DONOR_MAX_ORDER_COUNT = 12`
  `[O] dmscript.global:113` adopted; `MAX_BUILDERS_SENT := 8` PORT
  APPROXIMATION per mine/farm/btime tiers); `data.gd:333` (`TICK_MAX 0.25`
  port stability guard, `[U] U1`); `config.json:93-94,97` mirrors
  (`build_queue_limit 10` sic vs code 12 — config default lags the donor
  literal; `max_builders_sent 8`; `max_tick_seconds 0.25`).
- Donor: order-slot cap 12 [O] with the ORDER-vs-job caveat (`data.gd:273-275`,
  game-side rewiring out of scope); builder tiers per DEC-U-VICTORY-START §4.2.
- Verdict: (a) for `TICK_MAX` (no donor constant, never a gate); (b)-adjacent
  for `MAX_BUILDERS_SENT` (donor tiers exist, port number is an estimate).
  Both correctly labelled.
- Remediation (label-only): fix the `config.json:93` `build_queue_limit: 10`
  vs donor `12` skew by relabelling the config default (do not silently
  change behaviour in this ticket); keep `TICK_MAX` never gated.

---

## 4. Movement

### P11. Speed scalars + spacing + uphill — PORT APPROXIMATION, donor-negative where proven.
- Port: `game.gd:5027-5033` (`effective_speed`: `aur_dru` +12% via
  `Data.DRUMMER_SPEED_BONUS`, `routing` ×1.35); `data.gd:349-356`
  (`PERSONAL_SPACE 0.35`, `FORMATION_SPACING 1.2`, `BUILD_HIT_INTERVAL` reuse
  note); `game.gd:6238-6239` (`esp *= 0.6` uphill); `config.json:141,144`
  mirrors (`personal_space`, `formation_spacing`, `drummer_speed_bonus`);
  `data.gd:1789` (EVERY `UNITS_BASE` `"speed"` value is PORT APPROXIMATION).
- Donor: MOVESPD §5.4/§7-S3+S6 (full-lib `drummer.*speed|march.*bonus` grep ×0;
  runaway issues a move-mode order with NO speed scalar, FEAR §5; separation
  is `XCollisionInertia` [U] + `unitRadius*0.8/*0.5` pitch
  `group.script:131-148`; formation bonuses damage/shield-only; zero
  terrain-cost rows [O-negative], gates BINARY; `walkintervalfactor` is anim
  playback rate `unit.script:595-598/11054-11173`, NOT velocity).
- Verdict: (b) for the drummer/routing/spacing/`speed`-ladder family (donor
  rotate law `rotatespeed*2.225` and ladders landed DATA-ONLY, consumers
  unwired — T-FORM/T-CARRY/T-SPEED/T-TURN/T-ACCEL/T-TERRAIN terminators at
  `game.gd:5015-5021`); the `0.6` uphill scalar is the limiting case of (a):
  with zero donor cost rows proven, there is affirmatively no donor uphill
  scalar to recover — keep labelled, remove/gate only when T-TERRAIN closes.
- Remediation (label-only): values kept verbatim, NO retune/removal
  (`game.gd:5023-5026`); never present the `speed` ladder as donor-verified
  locomotion (MOVESPD §7 S1/S3/S6).

---

## 5. Combat

### P12. Officer damage aura + combat scalars — (b) donor-present family, aura unresolved.
- Port: `game.gd:5035-5044` (`effective_damage`: `melee_mult`, cavalry mults,
  `officer_near` × `1.0 + Data.OFFICER_DAMAGE_BONUS`); `data.gd:433`
  (`OFFICER_DAMAGE_BONUS := 0.15`); `game.gd:7166` (landed `art_acc`
  multiplier, kept never reverted); `game.gd:7246`, `7366` (projectile flight
  / wall-splash PORT APPROXIMATION notes).
- Donor: formation damage/shield bonuses are donor-verbatim
  (`formations.cfg`, MOVESPD §5.3); officer/drummer SLOT getters exist, but no
  sampled officer damage-AURA scalar was recovered in the cited sweeps; native
  flight behaviour (DEC_U_flight_native) and wall splash engine path stay [U].
- Verdict: (b). Keep labelled; close with the formation/aura capture family
  (T-FORM) rather than by retuning 0.15.
- Remediation (label-only): no retune of 0.15 / `art_acc`; cite per-kind
  weapon rows where donor-verbatim (weapon/unit.script tails per DEC_U_weapon_tail).

### P13. Cooldown / deploy / decay rows — donor law partially landed; residual mismatches stay tagged (b).
- Port: `data.gd:4559-4567` itemises the known deltas WITHOUT applying them:
  `UNITS_BASE[*].weapons[].cd` re-derive from mount pause frames (D1);
  `game.gd:4900` writes `1.0` where donor gold-upkeep poor-shot is `2.0`
  (`unit.script:8208-8209`, U-D5); `game.gd:4910,4915,4920` 0.25 deploy-tick /
  0.5 wall-ridge vetoes with NO donor counterpart (vetoes write literal `1.0`,
  `unit.script:8280-8281`); `game.gd:4513/5347-5349` decay + `:4739-4741`
  double-decrement (donor decays once/tick).
- Verdict: (b). The ledger itself (`data.gd:4547-4567`) is the correct
  label-only posture: literature cites with per-line provenance, live-sim
  patch owner-applied elsewhere.
- Remediation (label-only here): apply only in the owning combat ticket; until
  then the `1.0`, `0.25`, `0.5`, and double-decrement sites stay tagged
  PORT APPROXIMATION + [U]-D1.

### P14. TICK_ORDER v1 + RNG stream use — (b) frozen approximation, correctly labelled.
- Port: `game.gd:5460,5821,8439` (`TICK_ORDER v1 PORT APPROXIMATION [U]-O1`);
  `ai.gd:1363-1368,1446-1451` (port `rng`/`gen_rng` are Godot generators,
  `floor(RandomExt*n)` wrapper missing — PORT APPROXIMATION; inert donor
  `floor` helpers provided but UNWIRED); `game.gd:378` (mix64 seed fold
  labelled, no donor body).
- Donor: tick-order slice laws recovered (DEC_U_tick_order / DEC_U_tick_driver);
  RNG ledger (DEC_U_rng_ledger, X21 vectors) recovers stream identity LCG +
  per-site draw counts, with cross-site interleave [U]-U-A7 / stagger [U]-O1c.
- Verdict: (b). Freezing v1 and labelling is the correct posture until the
  §5 U-O1c/U-O6 fixed-seed hash experiments pass (3 seeds, 0 mismatches).
- Remediation (label-only): no reorder, no stream rewiring in this ticket.

---

## 6. Scoring / telemetry

- `players[].score` accumulation feeds ONLY the P1 opt-in branch; no other
  consumer gates victory/defeat on score. Save keys `victorystate_int`,
  `roster_bexists`, `bleave`, `victorystategametime`, `scenario_active`,
  `donor_progress`, `projectiles`-as-extension (`game.gd:8389-9039`) are
  ADDITIVE telemetry / PORT EXTENSION contract, never a byte-parity claim —
  correctly labelled, no gameplay effect. (a)-adjacent; no action.

---

## 7. Classification summary

| ID | Site | Class | Donor anchor |
|----|------|-------|--------------|
| P1 score victory (5000 + flag + config keys) | data.gd:287-292; game.gd:8302-8311; config.json:95-96 | (a) absent | VSTART §1.3; SCENWIN §7/P10 |
| P2 team-win (law landed; comment stale) | game.gd:8155-8248,8281-8317 vs data.gd:293-296 | (c) stale label | SCENWIN §5 EV-E/EV-M, §7-1, §9 |
| P3 defeat liveness mapping | game.gd:8254-8271 | (b) U | VSTART §1.2; SCENWIN §7-4 |
| P4 peace gate + literals + expiry | game.gd:8295-8301; menu/main/config chain | (b) U | MENUPEACE §§1-4; SCENWIN §4.3; U-P1 |
| P5 AI think 1.0 vs 2.4 | data.gd:399; ai.gd:1324; config | (b) U-A6/A7 | AITHR §1/§8 |
| P6 AI food/economy shape | ai.gd:1325-1326; data/config thresholds | (b) U-A1/A5 | AITHR §4/§7 |
| P7 AI force gate/quotas/misc | ai.gd:868,676,683-686,1331,1225; config 158-159 | (b); 260 invented | AITHR §2/§7; FEAR |
| P8 gather cadence/ratio/fisher | data.gd:347,354-356,3971-3974; config 119-132; game _tick_gather/_fisher_deliver | (b) U-CAD/U-PART/U-FISH | CARRY §§2-3/5-6 |
| P9 morale/famine-grace/market-old | data.gd:425-467; config 143-150 | (a) absent behaviour | AITHR §6 P6-8; DEC-U §2.1-2.2 |
| P10 queue/builders/tick guards | data.gd:276-278,333; config 93-94,97 | (a) guards; 12 [O] | VSTART §4.1-4.2 |
| P11 drummer/routing/spacing/uphill/speed ladder | game.gd:5027-5033,6238-6239; data.gd:349-356,1789; config 141,144 | (b); uphill limiting-(a) | MOVESPD §§1/5.1/5.3/5.4/§7 |
| P12 officer aura / art / splash | game.gd:5035-5044,7166,7246,7366; data.gd:433 | (b) | MOVESPD §5.3; flight/wall [U] |
| P13 cooldown/deploy/decay deltas | data.gd:4559-4567; game.gd:4900,4910-4920,4513,4739-4741 | (b) U-D1/D5 | unit.script cites therein |
| P14 tick order + RNG use | game.gd:5460,5821,8439; ai.gd:1446-1451; game.gd:378 | (b) U-O1/A7/G1 | tick_order/tick_driver/rng_ledger/X21 |

No (c) unlabelled gameplay approximation was found EXCEPT the two
documentation/config items in §8, both label-only.

---

## 8. Accidentally unlabelled / stale labels (c) — label-only fixes, no behaviour change

- C1. `config.json:95-96` (`gameplay.victory`, `gameplay.score_limit`) and the
  identical `config_donor_capture.json:96-97` keys carry no port-only note,
  while the code side (`data.gd:287-292`, `game.gd:8302-8304`) is explicitly
  `PORT EXTENSION`. The `_readme` (config.json:3-18) documents several other
  port-only keys (`render_mode`, `terrain.backend`, `color_unify`) but not
  these two. Fix: append `_readme` lines `gameplay.victory / score_limit:
  PORT EXTENSION — no donor counterpart (VSTART §1.3); score branch inert
  unless Data.PORT_EXTENSION_SCORE_VICTORY=true`. Label-only.
- C2. `data.gd:293-296` staleness (see P2). Fix: rewrite the tail comment to
  `team-win law LANDED at game.gd:8168 per SCENWIN §5 (miscext2.script:
  3769-3844); _player_bexists mapping + winnerteam init stay APPROX`.
  Label-only.
- C3 (boundary). `game.gd:8300` compares port `time_s` against `Data.PEACE_TIME`
  where the donor compares `gametime > gfloat_peacetime` (MENUPEACE §4,
  strict-`>`). The seconds SOURCE chain is labelled; the `time_s`-vs-`gametime`
  identity and the exact-equality boundary tick are not labelled at the gate.
  Fix: tag the line `PORT APPROXIMATION [U]: time-base identity + == boundary
  vs donor gametime>peacetime`. Label-only; close with the same fixed-seed
  peace-expiry run as U-P1.

---

## 9. Remediation list (all label-only unless a donor law already recovered)

1. P1: keep `PORT_EXTENSION_SCORE_VICTORY=false`; annotate config keys (C1).
2. P2/C2: refresh the `data.gd:293-296` comment to the landed SCENWIN law.
3. P3/P4/C3: keep APPROX tags; run the fixed-seed lose-tick / peace-expiry /
   time-base experiments before relabelling anything.
4. P5–P7: keep `DONOR_PORT_GAP_NOTES` + `DONOR_U_EXPERIMENTS`; no default
   changes before U-A1..A8 pass.
5. P8/P13: carry/combat rewrites belong to their owning workers (CARRY §5,
   weapon-tail D-series); this ticket changes no live line.
6. P9/P10: keep quarantine/deprecated markers; fix config `build_queue_limit`
   10-vs-12 skew by relabelling, not by silent behaviour change.
7. P11/P12/P14: keep values verbatim; close via T-FORM/T-CARRY/T-SPEED/T-TURN/
   T-ACCEL/T-TERRAIN and the TICK_ORDER hash gates.
8. Re-scan rule for the next worker: any new gameplay number without a
   `file:line` donor cite + `[O]/[D]/[I]/[U]` tag + report id defaults to (c)
   and must be labelled before merge.

Parity: UNVERIFIED. No approximations introduced, no parity claimed.
