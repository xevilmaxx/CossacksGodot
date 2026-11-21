# RB — Mechanics gap analysis (Research lane)

Agent: **RB** (Research lane, `SWARM_OPS.md` §5b). Date: 2026-11-21.
Scope: public-source research only. No Godot run, no game-code edit, no donor
asset download. All port findings below came from reading `app/mechanics.json`,
`app/MECHANICS.md`, root `README.md`, `app/scripts/data.gd`, `app/scripts/game.gd`
and `app/scripts/ai.gd`. Line numbers are from that same read.

> **Status key.** IMPLEMENTED = a code path exists and matches the public
> description. PARTIAL = exists but with reduced scope or an explicitly
> estimated value. MISSING = no code path found in this pass. UNVERIFIABLE =
> claimed in project docs but not confirmed in code here, or public sources
> conflict. "Estimated" in the port means *donor provenance unknown*; a code
> citation does not turn an estimated donor value into a sourced one.

---

## 1. Public sources used (all fetched/read this pass)

| # | Source | What it establishes |
|---|---|---|
| S1 | https://cossacks3.fandom.com/wiki/Combat_basics | RPS table (melee/ranged/cavalry/artillery); combined arms; 17c ranged **flee** when enemy too close; 18c musketeers become melee-capable; bombard for towers; siege = capture **or** destroy |
| S2 | https://cossacks3.fandom.com/wiki/Formations | Requirements (≥15 infantry / 40 cavalry, 1 officer, 1 musician); sizes 15/36/72/120/196/400 and 40/90/160; attack/defence bonus; separate Stand-Ground defence bonus |
| S3 | https://cossacks.fandom.com/wiki/Battle_tactics | Infantry formations +2 dmg/+2 def; heavy cavalry +1/+1; Stand Ground bigger bonus; ranged range bonus on high ground; hide behind hills vs cannon; multi-barrel grapeshot; **cannons auto-fire grapeshot at short range**; Gribovalle durability; Montgolfier recon; **economy buildings (townhall, market, mines, storehouse) are capturable, most military buildings are not**; **AI blows up mines before capture** |
| S4 | https://cossacks3.fandom.com/wiki/Upgrades | Full upgrade catalogue by building: Academy (geology, balloon, +85 hp, -75% build time, fortification +80, wheat/rye +40%, agronomist +50%, field +200%, woodworking +100%, mining +100%, miners +200%); military (bayonet cold steel +7, firepower +10/+15/+20/+30%, RoF +35%, flintlock cost -50%, steel grades +25% 18c melee, medical science heal-all, cuirass def +2); Barracks/Stable drills; artillery (+5/+10% range, +150% hp, +35% accuracy, multi-barrel, repair shops); Artillery Depot (cost -20%, build +40%); Mill +140/+250%; **Mine +5/+8/+10/+12/+15/+40 = 95**; Tower RoF +20/+20/+10%; Town Hall 18c |
| S5 | https://cossacks3.fandom.com/wiki/Capturing | Capture procedure (defeat non-capturable units, stand a military unit near target, repair afterwards); defend by guard or delete; **capturing enemy workers and a town hall of a nation you do not have doubles economy/military cheaply** |
| S6 | https://cossacks3.fandom.com/wiki/Mine | Mine on deposit, assign peasants, per-mine upgrades, **95-worker cap**, **capturable by enemy** |
| S7 | https://cossacks3.fandom.com/wiki/Market | Buy / sell / exchange resources; capturable; 450 wood; (wiki build time 286 s vs port 23.4 s — see G-14) |
| S8 | https://cossacks3.fandom.com/wiki/Tower | Fortification: **only cannons, ships, grenadiers or archers** can destroy; per-tower cannon upgrades cost much iron/coal |
| S9 | https://cossacks3.fandom.com/wiki/Hotkeys | Patrol = **P** (port uses Q); Ctrl+A/all, Ctrl+B/buildings, Ctrl+P/idle peasants, Ctrl+M/empty mines, Alt+M/minimap, D/E/V hold-fire system, R/K/L/F/J formation keys |
| S10 | https://www.gamepressure.com/cossacks3/formations/zf91b3 | Officer + drummer needed for infantry formations (after Academy); cavalry needs no officer; line/column/square semantics; formations **keep order after moving**; artillery battery spacing vs fortifications |
| S11 | https://steamcommunity.com/app/333420/discussions/0/350542145705166969/ (Toastytoast) | Exact bonuses: melee +2 atk/+3 def; Stand Ground +9/+9; shooters +2 firepower/+3 def, Stand Ground +2/+9; sizes 15..400; replenish from loose units; **17c muskets have no melee**; artillery batteries spread out |
| S12 | http://cossacksworld.ucoz.co.uk/index/0-95 | Infantry +3 def / melee +2 atk; cavalry line/wedge/U sizes 40/90/160 and shape-dependent bonuses; artillery formations give no stat bonus; **multibarrel cannot be formed** |
| S13 | https://cossacks.heavengames.com/ac/academy/formations/ | +2/+3 and +9/+9 table; morale can **disband a formation** (rear/flank attack, >30 % losses, officer/drummer/flagbearer death); experience raises formation bonuses |
| S14 | https://cossacks.heavengames.com/thegame/units/artillery/ | Grapeshot is horizontal, **cannot pass over walls/buildings/hills**; mortars are siege units |
| S15 | https://cossacks.heavengames.com/cgi-bin/forums/display.cgi?action=st&fn=1&tn=478 | Market first-mover gets best rates, then stabilises at worst (50 food …) — port rate only drifts downward |
| S16 | https://www.reddit.com/r/Cossacks3/comments/5my6zv/artillery/ | Grapeshot range tier between howitzer and musket; multiple shots before reload |

Also consulted (search results, not fetched in full):
`https://cossacks3.fandom.com/wiki/Grenadier`, `.../wiki/Town_Hall`,
`.../wiki/Population_capacity`, `.../wiki/Wall`, `.../wiki/Housing`,
`https://steamcommunity.com/app/333420/discussions/0/154642321537629720/`.

---

## 2. Mechanics checklist

| Mechanic | Donor behaviour (source) | Port implementation (file:line) | Status |
|---|---|---|---|
| Damage formula −shield −prot, min 1 | `_misc_DoDamage`; min 1 hp (MECHANICS.md §Damage) | `data.gd:820-837`, `game.gd:3229-3247` | PARTIAL — **P-06** off-by-one: `WK` arrow=5/cannonball=7 (`data.gd:233`) indexes 6-slot `prot` (`data.gd:831-834`) |
| Fast-horse vs arrow/bullet −5 | same, `_misc_DoDamage` | `data.gd:823-825` | IMPLEMENTED |
| Unfinished-building shield ÷3 | same | `data.gd:826-830` | IMPLEMENTED |
| Weapon-kind protection array | 6 slots `[pike,sword,bullet,cannister,arrow,cannonball]` (`data.gd:235`) | `data.gd:235`, `game.gd:3230-3238` | PARTIAL (see P-06) |
| RPS counter table (melee/ranged/cav/arty) | S1 RPS table | `game.gd` target scoring not verified in this pass; documented as estimated in `mechanics.json:1292-1298` | UNVERIFIABLE |
| Volley smoke, arrow/cannon flight + dispersion | artillery/arrow dispersion, smoke (MECHANICS.md video pass) | `data.gd:83-85`, `game.gd` firing FX | IMPLEMENTED |
| Friendly fire / splash | splash hurts everyone (MECHANICS.md video pass) | `game.gd` splash path (`_apply_hit` from blast) | IMPLEMENTED |
| Artillery deploy 2 s | guns unlimber before firing (estimated) | `data.gd:82`, `game.gd:2799` | PARTIAL (donor value estimated) |
| Muskets don't melee in 17c; flee at min range | S1, S11 | `data.gd:265,275` `no_melee`; `game.gd:2882-2884` fall back 4 m | IMPLEMENTED |
| 18c bayonet / second melee weapon | S1, S11; grenadier has musket+bayonet+sword | `data.gd:360-362,371-373`, `game.gd:1765-1771` | IMPLEMENTED (inherent), but **upgrade** missing (G-03) |
| Grapeshot at short range | S3, S8, S16 | `data.gd:318-319,384-385`, `_pick_weapon` `game.gd:1765-1771` | IMPLEMENTED |
| Grapeshot blocked by walls/hills | S14 | flat shots stop at walls (`MECHANICS.md` S4); not re-verified in code here | UNVERIFIABLE |
| Mortar only buildings | S3, S14 | `data.gd:395 only_buildings`, `game.gd:3525-3526` | IMPLEMENTED |
| Tower fortification immunity | S8 | `game.gd:3227` allows only cannonball/cannister/arrow/firearrow; grenade uses `cannonball` kind (`data.gd:360`) | IMPLEMENTED |
| Tower/garrison RoF upgrades | S4, S8 | `data.gd:751-756` 3 tower upgrades; `game.gd:3528` garrison doubles shots | IMPLEMENTED |
| Formations: sizes 15..400 / 40..160 | S2, S10, S11 | `data.gd:222`, `game.gd:1809` `cmd_form_size`; `mechanics.json:975-988` | IMPLEMENTED |
| Formation bonuses +2/+3, hold +9/+9 | S11, S12, S13 | `game.gd:1737-1763` (`_formation_atk`/`_formation_def`) | IMPLEMENTED |
| Heavy cavalry +1/+1 (hold +5/+4) | S3, S12 | `game.gd:1745-1750,1761-1763` | IMPLEMENTED |
| Formation keeps order after moving | S10 | `game.gd` formation offsets (`cmd_form_size`); not re-verified here | UNVERIFIABLE |
| Formation morale/disband on 30 % losses, officer death | S13 | `game.gd` morale exists but squad disband rule not found | MISSING |
| Officer aura +15 % dmg / +20 morale, 12 m | estimated (video pass), MECHANICS.md | `data.gd:72-73,78`, `game.gd:2157+` | PARTIAL (donor value estimated) |
| Drummer +12 % speed / +10 morale, 10 m | estimated | `data.gd:74-75,79`, `game.gd:2157+` | PARTIAL (estimated) |
| Priest heal 5 hp/s in 8 m | estimated | `data.gd:80-81`, `game.gd` healer path | PARTIAL (estimated) |
| Medical science "heal all live units" | S4 | no upgrade id in `UPGRADES_BASE` `data.gd:698-781` | MISSING (G-06) |
| Morale 70, rout <25, shock on hit | estimated (video); routed troops run home | `data.gd:70-71`, `game.gd:1237-1238,2804-2808,3054-3103,3245-3276` | PARTIAL (donor numbers estimated) |
| Stand ground / hold fire D/E/V | S9 | `game.gd:1635-1650` | IMPLEMENTED |
| Delete own selection (deny capture) | S5 | `game.gd:2612+` | IMPLEMENTED |
| Replenish from loose units at officer | S11 | `game.gd:1776-1806` | IMPLEMENTED |
| Capture enemy **peasants** | S5 | `game.gd:3212-3225` — implemented; docs claim otherwise (G-10) | IMPLEMENTED (docs stale) |
| Capture **buildings** — town hall, market, mines, storehouse | S3, S5, S6, S7 | **only `cen` has `capture:true`** (`data.gd:650`); capture loop handles mines (`game.gd:3573`) but flag absent | MISSING (G-01) |
| Capture requires defeating non-capturable units / guard defence | S5 | capture loop only checks proximity (`game.gd:3537-3557`) | PARTIAL (G-09) |
| Capturing foreign town hall unlocks that nation | S5 | ownership flip only (`game.gd:3563-3577`) | MISSING (G-07) |
| AI blows up mines before capture | S3 | `ai.gd` no such rule found | MISSING (G-11) |
| Gather 22/45 food, 14/28 wood, 20/40 stone | donor `dmscript.global` | `data.gd:225-229` | IMPLEMENTED |
| Mine income 1.664/s per peasant | donor `player.script` | `data.gd:54` | IMPLEMENTED |
| Mine slot ladder II..VII to 95 | S4, S6 | `data.gd:763-780` (+5/8/10/12/15/40) | IMPLEMENTED |
| Upkeep ÷625 | donor `player.script` | `data.gd:56`, `game.gd:2468` | IMPLEMENTED |
| Famine grace 120 s, drain 0.3 hp/s | estimated | `data.gd:86-87`, `game.gd:2529` | PARTIAL (estimated) |
| Market barter with commission + drift | S7, S15 | `data.gd:88-89`, `game.gd:2130-2155` | PARTIAL (G-08, G-14) |
| Build progress 0.359 s/hit, 30 builders | donor | `data.gd:49-51` | IMPLEMENTED |
| Cost escalation ×3 town halls / ×1.5 others | Steam guide (MECHANICS.md) | `game.gd:2274` | IMPLEMENTED |
| Repair damaged own buildings | S5 | `game.gd:2603-2609,2968`; AI uses it `ai.gd:378-386` | IMPLEMENTED |
| Garrison cap 10, heal 2 hp/s | GUIDE3 estimate | `game.gd:1684-1704,3528-3533` | PARTIAL (estimated) |
| 18c transition + national exclusions (ukr/tur/alg) | S4; Ukraine wiki | `data.gd:167-178` `no18c`; `game.gd:2028,2080,2252`; `data.gd:709` | IMPLEMENTED |
| bar18 / dip / cen_18c prerequisites | S4; `Town_Hall` wiki | `data.gd:657,660,709`; `MECHANICS.md` S2 | IMPLEMENTED |
| Mill +140/+250 %, field upgrades | S4 | `data.gd:715-720` | IMPLEMENTED |
| Artillery range/accuracy/hp/multibarrel | S4 | `data.gd:741-750` | IMPLEMENTED |
| Firepower tier upgrades + RoF + flintlock cost | S4 | only `bla_bullet1` `data.gd:703-704` | MISSING (G-02) |
| Bayonet +7 / steel grades +25 % melee | S4 | none | MISSING (G-03) |
| Cavalry recruit ×2 / +5 atk / defence / drills | S4 | only `sta_horse1` `data.gd:711-712` | MISSING (G-04) |
| Barracks/Stable drill upgrades, new grenades | S4 | none | MISSING (G-05) |
| Foundry cost −20 %, build speed +40 %, repair shops | S4 | none | MISSING (G-08) |
| Naval (shipyard, xebec/frigate/battleship, fishing) | S3, S4, S9 | none in shipped code; **already ticket P-10 (owner AC, IN_PROGRESS)** | MISSING (tracked) |
| Squad experience raises bonuses | S13 | none found | MISSING |
| Patrol hotkey P | S9 | `config.gd:111` => Q (`mechanics.json:598-602`) | PARTIAL (G-12) |
| Worker cap per food node (2 vs 3) | Steam discussion vs `MECHANICS.md:364` (food 3) | `mechanics.json:1331-1335` says 2 | UNVERIFIABLE (G-13) |
| Building build times (market 286 s, tower 1500 s) | S7, S8 | `data.gd:673,689` (23.4 s / 123 s) | UNVERIFIABLE (G-14) |

Statuses (57 rows): IMPLEMENTED 28 · PARTIAL 12 · MISSING 12 · UNVERIFIABLE 5.

---

## 3. GAP LIST (player-visible skirmish first)

### G-01 — Only the Town Hall is capturable (P0, 1 ticket)
- **Source:** S3 ("any economy building (townhall, market, mines, storehouse)
  can [be captured]," most military buildings cannot); S5, S6, S7.
- **Code:** `data.gd:650` is the *only* building with `"capture": true`;
  `sto`/`mil`/`mar`/`mine_gold`/`mine_iron`/`mine_coal` (`data.gd:669-688`) have
  no flag. The capture routine already handles mines (`game.gd:3573`), so the
  behaviour is half-wired.
- **Scope:** owner of `data.gd` (currently A per board) adds `capture:true` to
  the economy buildings; add 1 selftest step that captures a market or mine.
  Decide explicitly whether `hou`/`art`/`tow` stay non-capturable (S3/S8 imply
  towers are fortifications). No `game.gd` change needed.
- **Tickets:** 1 data + selftest ticket.

### G-02 — Firepower upgrade tree collapsed to one upgrade (P0, 3 tickets)
- **Source:** S4 Academy: rifled barrel +10 %, granular powder +15 %, sulphur
  +20 %, nitre +30 % firepower; wheellock +35 % RoF; paper cartridge +35 % RoF;
  flintlock musket cost −50 %.
- **Code:** only `bla_bullet1` (+20 % bullet, +10 % cannonball) at
  `data.gd:703-704`; `research()` `game.gd:2019` applies `damage_mult` but
  there is no `rof_mult`/`cost_mult` effect for weapons.
- **Scope:** (a) data rows in `UPGRADES_BASE`; (b) apply `rof_mult` in the
  firing cooldown path; (c) apply `cost_mult` to shot resource cost + UI/HUD
  labels. Keep existing `damage_mult` path for the firepower tiers.
- **Tickets:** 3 (data, sim, HUD).

### G-03 — Bayonet / steel-grades upgrades missing (P0, 2 tickets)
- **Source:** S4: "Design bayonet … cold steel weapons +7"; "Research new steel
  grades: 18c musketeer/grenadier melee attack efficiency +25 % (not Turkey or
  Algeria)"; blacksmith "Forge bayonets and broadswords for infantry +5 melee".
- **Code:** port gives musk18/grenadier a hard-coded 8-dmg sword
  (`data.gd:360-362,371-373`) with no research path; `no18c` already tracks
  tur/alg (`data.gd:167-178`).
- **Scope:** add upgrade rows + a `melee_mult` effect applied to the 2nd weapon
  in `_pick_weapon`/damage; gate by `no18c`.
- **Tickets:** 2 (data + sim), 1 more if a distinct icon/HUD label is required.

### G-04 — Cavalry upgrade tree missing (P1, 2 tickets)
- **Source:** S4 blacksmith: harnesses = mounted recruitment ×2; broadswords/
  sabres = cavalry attack +5; academy riding drill = cavalry defence;
  stable fencing drill/firing practice.
- **Code:** only `sta_horse1` (+10 % sword) `data.gd:711-712`.
- **Scope:** add 4–5 rows with `train_speed_mult` (new effect), `damage_mult`
  gated to cavalry units, and `prot_bonus` gated to cavalry.
- **Tickets:** 2 (new effect handling in `research`/`train_unit`, data rows).

### G-05 — Barracks/Stable drill upgrades missing (P1, 2 tickets)
- **Source:** S4: physical training (defence), rehearsals (musician defence
  +20), fencing drill (melee), firing practice (ranged), new grenades (damage).
- **Code:** absent from `UPGRADES_BASE` `data.gd:698-781`.
- **Scope:** rows + `damage_mult` for melee/ranged/grenade kinds, `prot_bonus`
  for musicians (drummer sid) and generic defence.
- **Tickets:** 2.

### G-06 — Medical science (heal all live units) missing (P1, 1 ticket)
- **Source:** S4 Academy "Develop medical science — heals all live units".
- **Code:** only priest heal (`data.gd:80-81`), no instant global heal effect.
- **Scope:** add `aca_med1` upgrade + one-shot heal effect in `research()`.
- **Tickets:** 1.

### G-07 — Foreign town-hall capture does not unlock that nation (P1, 2 tickets)
- **Source:** S5: capturing enemy workers and a town hall of a nation you do
  not have "allows you to double your economy and military cheaply".
- **Code:** `game.gd:3563-3577` flips `e.player`, score and farm cap only; no
  nation/train-list change. `resolve_sid` (`data.gd:800-804`) keys off a static
  player nation.
- **Scope:** store captured nation on the player, let `resolve_sid` train that
  nation's variants; AI/HUD update.
- **Tickets:** 2 (sim + HUD/AI).

### G-08 — Foundry / repair-shop / market-rate refinements missing (P1, 2 tickets)
- **Source:** S4 Artillery Depot: foundry mechanization cost −20 %, new
  metalworking build speed +40 %, "Finance artillery repair shops" repairs all
  artillery. S15: market rate drifts to a floor, not monotonically downward.
- **Code:** no such effects in `UPGRADES_BASE`; `game.gd:2152` uses
  `MARKET_DRIFT` decreasing rate down to `0.35` and never recovers.
- **Scope:** add `cost_mult`/`build_mult` for artillery and a repair-all
  effect; make market rate recover toward a floor per S15 (verify floor value —
  currently UNVERIFIABLE).
- **Tickets:** 2 (one for foundry/repair, one for market rate).

### G-09 — Capture preconditions and guard defence not enforced (P1, 1 ticket)
- **Source:** S5: first "defeat all enemy non-capturable units", then stand a
  military unit near the target; guard capturable assets; repair afterwards.
- **Code:** `game.gd:3537-3557` captures purely on proximity, no guard or
  non-capturable-unit check; garrison only halves speed (`game.gd:3555-3556`).
- **Scope:** add a "guarded" state (guard order or nearby defender) that blocks
  or slows capture until defenders are gone.
- **Tickets:** 1.

### G-10 — Documentation contradicts code on unit capture and worker caps (P1, 1 doc ticket)
- **Source:** S5, S2, S9, S11.
- **Code:** `app/MECHANICS.md:540-542` and `mechanics.json:1143-1148` say
  "capturing enemy units (peasants) NOT implemented", but `game.gd:3212-3225`
  captures them (and selftest step `peasant_capture` is DONE — board P-03).
  Separately `mechanics.json:1331-1335` says 2 peasants per food node while
  `MECHANICS.md:364` says food 3 / wood 2 / stone 3. Hotkey patrol is Q in
  `config.gd:111` but P in S9.
- **Scope:** owner I (`mechanics.json`/`MECHANICS.md`, IN_PROGRESS) corrects
  these three entries; coordinator decides Q vs P (donor `hotkeys.cfg` may
  override the wiki — mark as UNVERIFIABLE until checked).
- **Tickets:** 1 doc-only ticket (no game code).

### G-11 — AI does not deny mines by demolition (P2, 1 ticket)
- **Source:** S3: "Computer foes often tend to blow up their mines before they
  are captured."
- **Code:** `ai.gd` (`_raids`, `_waves`, `_repair`) has no self-denial rule.
- **Scope:** when an enemy capturer is within capture radius of an AI mine,
  delete it (and optionally its deposits) before completion.
- **Tickets:** 1 (`ai.gd`, owner G).

### G-12 — Hotkey deviations (P3, 1 ticket)
- **Source:** S9 patrol P; port Q (`config.gd:111`).
- **Code:** `config.gd:111`, `mechanics.json:598-602`.
- **Scope:** confirm donor `hotkeys.cfg` value; if wiki is right, change key
  and HUD label. Low skirmish impact.
- **Tickets:** 1.

### G-13 — Formation morale/disband and experience missing (P2, 2 tickets)
- **Source:** S13: rear/flank attacks, being fired on while attacking, >30 %
  losses or officer/drummer death can disband a formation; experience raises
  bonuses (+5/+7 … +15 def).
- **Code:** `game.gd:3054-3103` handles unit morale/rout but no squad-level
  disband or experience scaling was found.
- **Scope:** squad integrity check + `squad.experience` bonus in `_formation_*`.
- **Tickets:** 2.

### G-14 — Build-time / rate discrepancies (P3, 1 doc+data ticket, UNVERIFIABLE)
- **Source:** S7 market build 286 s, S8 tower 1500 s vs port `data.gd:673`
  23.4 s and `data.gd:689` 123 s. S15 market rate floor.
- **Code:** port values come from donor `unit.script` frames (documented), so
  the wiki "seconds" may use a different time unit. Do not change numbers
  without resolving the unit mismatch.
- **Scope:** reconcile units, annotate whichever is wrong.
- **Tickets:** 1 research/doc ticket.

### Already tracked — do not re-ticket
- **Naval** (S3/S4/S9): ticket **P-10**, owner AC, IN_PROGRESS
  (`NAVAL_EVIDENCE.md`). My research supports the waiver overturn (S3 ships
  fire back, S4 naval upgrades, S9 shipyard hotkey).
- **Damage protection off-by-one**: ticket **P-06**, BLOCKED (data.gd owned by
  A). Confirmed at `data.gd:233,831-834`.

---

## 4. Priority summary / estimate

Top 10 player-visible gaps in priority order: **G-01, G-02, G-03, G-04, G-05,
G-06, G-07, G-08, G-09, G-10**.

| Bucket | Gaps | Worker tickets |
|---|---|---|
| P0 (G-01..G-03) | 3 | 6 |
| P1 (G-04..G-10) | 7 | 11 |
| P2/P3 (G-11..G-14) | 4 | 5 |
| **Total new tickets** | **14 gaps** | **22** |

Plus 2 already-tracked items (P-06, P-10) that need no new ticket.
Highest value per ticket: **G-01** (one data flag set unlocks the whole donor
economy-capture game loop, which the sim already supports).

### Explicitly unverifiable in this pass
- RPS target scoring and "formation keeps order after moving" (claimed in
  project docs / S1, S10 but the exact code path was not re-read here).
- Grapeshot blocked by walls/hills (S14) — documented in `MECHANICS.md` but
  not re-verified in `game.gd`.
- Exact donor morale/aura numbers, garrison heal, famine, market rate,
  artillery deploy time — all marked `estimated:true` in `mechanics.json`;
  public sources describe the behaviour, not the numbers.
- Market build time 286 s (S7) / tower 1500 s (S8) vs port frames — unit
  mismatch unresolved.
- Patrol hotkey P (S9) vs Q (`config.gd:111`) — donor `hotkeys.cfg` is
  authoritative for the port and was not re-read here.

---

## 5. Files changed

- `docs/research/RB_MECHANICS.md` — new (this file). No other file edited.
