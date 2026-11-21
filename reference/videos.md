# Cossacks 3 — video & mechanics research (2026-11-18)

Method note: YouTube watch pages return only the HTML shell from this machine
(no stream transcription possible). Titles/descriptions were taken from search
snippets and watch-page titles; mechanics numbers below come from the Cossacks
wiki (cossacks3.fandom.com), gamepressure.com guide and Steam community guides,
cross-checked against the donor game's own scripts (see app/MECHANICS.md).

## Videos (17 distinct, incl. the two requested)

1. https://www.youtube.com/watch?v=_2AuBsK1uPI — "THE RAIDING GAME | COSSACKS 3 | GAMEPLAY | 2025" (user-requested). Raiding/cavalry harassment play: fast horse vs ranged, economy raids.
2. https://www.youtube.com/watch?v=cZW0AEupCaI — "GAMEPLAY [PC/HD]" (used by earlier pass). Singleplayer shell: menu → Skirmish/Historical Battles/Campaigns, nation pick, map options, objectives.
3. https://www.youtube.com/watch?v=UCMEXK-cD3E — "Cossacks 3: 5000 Musketeers VS 1500 Dragoons (Epic Battle)". Mass army line battles, volley fire, morale routs, huge unit counts.
4. https://www.youtube.com/watch?v=Z-07kQqiFIk — "Cossacks 3 - UKRAINE vs RUSSIA". Nation match-up, serdiuks/strelets, cossack cavalry.
5. https://www.youtube.com/watch?v=VviJ_E7BYTw — "17th Century Melee Cavalry Competition". Cavalry vs cavalry melee, fast-horse charge mechanics.
6. https://www.youtube.com/watch?v=F2y1LYujUlk — "HUGE 18TH CENTURY LINE BATTLE". 18c transition: musketeer18 lines, grenadiers, artillery batteries, officers/drummers.
7. https://www.youtube.com/watch?v=k-Ndvw0x_VI — "Cossacks 3 PC Gameplay/First Impressions (Leap of Faith)". Early economy: peasants, wood/food, houses, barracks.
8. https://www.youtube.com/watch?v=kaaG067gL18 — "Let's Battle Cossacks 3: 2 on 2". Comments confirm: food-gather upgrades early, iron mine early to sustain pike production, mine upgrades worth it (peacetime), early second town center.
9. https://www.youtube.com/watch?v=_G_8bcYB2H0 — "minimap timelapse 3vs3 AI only". AI macro behaviour: expansion rings, mass armies, map control.
10. https://www.youtube.com/watch?v=mk2fsEJeWMs — "Cossacks 3 Experience Gameplay" (8 min, no commentary). Skirmish loop overview.
11. https://www.youtube.com/watch?v=cUuGzr7874k — "Cossacks 3 Gameplay no commentary" (24:44). Full skirmish: build order, farms, mines, walls, army.
12. https://www.youtube.com/watch?v=XOjvyj6NXhE — same with commentary.
13. https://www.youtube.com/watch?v=YyT7Pn_3i-s — "online gameplay 2vs2 Ukraine, Poland vs Russia, Austria (#34)". Mixed-nation armies, winged hussars, formation micro.
14. https://www.youtube.com/watch?v=G_T0zI0a6U4 — "Cossacks 3 | 4v4 0pt | First Game Syndrome". Rules "0pt, 5k, 4v4, no peasant capture" → capture is a toggleable rule; peacetime settings exist.
15. https://www.youtube.com/watch?v=OpfbD1ALgTc — "BEST Nation Tier List 2024". Turkey/Algeria: NO 18th century, janissaries, sipahi, tatars; naval yachts.
16. MasterofRoflness playlist (13 videos): https://www.youtube.com/playlist?list=PLDg0b6qfevPsb6u1vzzk57vh0Caf-8h6n — Turkey/Prussia/Russia/England/Algeria/Venice/Ukraine/Spain/France/Austria/Poland skirmishes & MP.
17. https://www.youtube.com/watch?v=EXmHaUlSbBs — "Cossacks 3 Part 1 HISTORICAL CAMPAIGN". Campaign shell: objectives, hero units, village recruitment/capture.

## Mechanics facts (sourced)

### Formations (cossacks3.fandom.com/wiki/Formations + Steam guide by Toastytoast + gamepressure)
- Infantry formation needs: ≥15 same-type infantry + 1 officer + 1 drummer. Sizes: 15/36/72/120/196/400. Overflow stays loose.
- Cavalry formations: 40/90/160, NO officer needed; shapes rank/wedge/column; mostly geometric benefit.
- Artillery "battery": spaced line, defensive vs enemy artillery (spacing, not stat bonus).
- Bonuses (Steam guide): melee infantry +2 attack +3 defence; Stand Ground → +9 attack +9 armour. Ranged +2 firepower +3 defence; Stand Ground → +2 firepower +9 defence. (Pikeman wiki page says +7/+7 hold — use +9/+9, marked estimated.)
- Replenish: move same-type loose units near officer, click replenish → absorbed into formation.
- Officer+drummer trainable at barracks ONLY after Academy built (gamepressure).
- Formations keep their shape after moving; unformed mobs move as a mass.

### Combat (cossacks3.fandom.com/wiki/Combat_basics)
- RPS: melee-infantry good vs cavalry, poor vs ranged; cavalry excellent vs ranged & artillery; artillery very good vs infantry, poor vs cavalry; ranged good vs melee.
- 17c ranged units FLEE when enemy is closer than their minimum range (no melee). 18c musketeers/grenadiers gain bayonet melee.
- Combined arms layout: pikes front, howitzers behind, musket line hold-ground, long cannons rear, light cav flank, dragoons chase, heavy cav reserve.
- Siege: capture or destroy; bombards/mortars outrange towers.

### Units (wiki)
- Drummer 17c: hp 75, sight 6000 (px), cost food 60 gold 20, time 5 s, cannot fight, needs Academy; upgrade "Conduct rehearsals" +12 defence (706 food 50 gold).
- Pikeman 17c standard: hp 90, range 100 px, atk 8, armour [pike2 sword3 bullet7 arrow4 cannon40 grapeshot210] (matches donor unit.script; port already correct).
- Turkey: janissaries (gun infantry), light+heavy sipahi, tatars (mounted archers), mullah; Algeria similar; both NO 18th century.

### Economy (reddit r/Cossacks3 + wiki)
- Early food-gather upgrade and early iron mine are standard openers (pike production needs iron).
- Mine upgrades exist and are worth it (peacetime especially).
- Peasant capture is a match rule toggle ("no peasant capture" lobbies).
- Up to 32,000 units marketed; pop cap per player 200..8000 via houses (port uses 200 default).

## Clone checklist (priority order)
1. Animated original-model units (walk/idle/attack/death, 8 dirs) — every video shows marching/ firing/ dying animations; current port is static.
2. Nation-specific buildings & unit variants (20 nations) — videos show distinct tur/rus/pol architecture.
3. Construction stages + rubble (donor has `<nat><bld>1..4.osm` and `_death1/2.osm`).
4. Formation sizes/bonuses/stand-ground/replenish per wiki; academy gate for officer/drummer.
5. 17c ranged flee-at-min-range; 18c bayonet melee.
6. Full 17c/18c roster incl. nation uniques (janissary/sipahi/tatar/winged hussar/strelet/etc.).
7. Mine upgrades; early-iron AI opener; capture rule toggle.
8. Artillery battery spacing; cavalry wedge.
9. Keep: economy loop, upkeep/famine, morale rout, priests, market, walls, fog, minimap, objectives, speeds, AI, never-hang CLI tests.
