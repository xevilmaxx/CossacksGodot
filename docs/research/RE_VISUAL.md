# RE_VISUAL — Cossacks 3 donor vs Godot port: visual gap analysis

Research lane agent **RE**. Date 2026-11-21. Read-only pass: no Godot, no game-code edits,
no donor assets copied, **no image files written**. Work from project root.

---

## 0. Evidence legend (read this before the tables)

Everything below came to me as **text** from `websearch`/`webfetch`.
`webfetch` renders pages to markdown/text; it does **not** return pixels to me.
I therefore **could not actually look at any screenshot, trailer frame or YouTube
thumbnail**. Tag key:

| Tag | Meaning |
|---|---|
| **[D]** | Description in text: article prose, guide, wiki caption, mod description, video title/description, metadata. |
| **[I-unseen]** | A real image exists at the cited URL (confirmed by page/metadata) but I could not visually inspect it. |
| **[U]** | Unverifiable from text available to me. Do not treat as fact. |
| **[P-doc]** | Port state inferred from project docs I was allowed to read (`README.md`, `reference/videos.md`, `docs/guides/GUIDE4.md` §0100–0103 + Appendix B). I did **not** open `app/shots/**` images — only the file list. |

Where a caption describes image content (e.g. GamePro's gallery captions) I mark it
**[D-caption]**: it is a human's description of a picture, not my own observation.
Nothing in this document is an original visual observation by me. That is a deliberate,
stated limitation — see §5.

**Compliance:** no `.png/.jpg/.mp4` was created, downloaded or embedded. Donor images
remain at their source URLs only. This file contains URLs and text, nothing else.

---

## 1. Sources used

| # | URL | Type | What it yielded | Tag |
|---|---|---|---|---|
| S1 | https://store.steampowered.com/app/333420/Cossacks_3 | Store page | Scale claims (up to 32,000 units), 20 nations, 220 buildings, land **and sea** battles, "dynamic lighting"/3D. | [D] |
| S2 | https://www.cossacks3.com/en | Official site | "Impressive scale", 32,000 units, 20 nations, 220 historical buildings, naval armadas, randomly generated maps, DLC adds **winter and desert maps**. | [D] |
| S3 | https://steamdb.info/app/333420/screenshots | Trailer/screenshot index | Named trailers: "Cossacks 3 Official Trailer" (id 73319), "Prussia on the defensive!" (63867), more; screenshot_full assets exist. | [D]/[I-unseen] |
| S4 | https://www.gamepro.de/galerien/cossacks_3,99481.html | 3-page screenshot gallery, 18+ captions | Detailed **[D-caption]** visual beats: growing town/housing, mines, defence line with **officers and drummers changing formation**, musketeers holding a **bridge from elevated ground**, detailed units, **bombards shelling a tower under infantry cover**, walls already flattened, **objective/event text windows**, **line ships sinking a transport**, "huge sea battles", **up to ten thousand units marching simultaneously**, supply economy. | [D-caption] |
| S5 | https://commons.wikimedia.org/wiki/Category:Screenshots_of_Cossacks_3 | Wikimedia Commons category | **6** GSC-licensed screenshots, 1920×1080, in "Isometric video game screenshots"/"RTS screenshots" categories. Files exist; not inspected. | [I-unseen] |
| S6 | https://commons.wikimedia.org/wiki/File:Cossacks_3_screenshot_5.jpg | File page | 1920×1080 JPEG; Wikipedia uses it as the "In-game screenshot"; GSC permits publication under GFDL. | [I-unseen] |
| S7 | https://en.wikipedia.org/wiki/Cossacks_3 | Encyclopedia | Remake of 2000 Cossacks; "modern 3D graphics, updated models and textures, **dynamic lighting**, full mod support". | [D] |
| S8 | https://cossacks.fandom.com/wiki/Cossacks_3 | Wiki | 21 nations, 70+ unit types, 140+ buildings, **realistic physics of bullets and cannonballs**, landscape influences tactics, 16,000 units; Gallery lists artwork + promo screenshots + "Musketeer Animations Short Film". | [D]/[I-unseen] |
| S9 | https://cossacks3.fandom.com/wiki/Formations | Wiki | Requirements 15 inf / 40 cav + officer + musician; sizes 15/36/72/120/196/400 and cav 40/90/160; column/rank/square; attack/defence + Stand Ground bonus. | [D] |
| S10 | https://cossacks3.fandom.com/wiki/Combat_basics | Wiki | RPS table; 17c ranged **flee at min range**; 18c muskets gain melee; combined-arms layout; elevated artillery vs own troops; siege capture/destroy, bombards outrange towers. | [D] |
| S11 | https://www.gamepressure.com/cossacks3/user-interface/zd91b1 | UI guide, text-only extraction | Numbered HUD read-out: **(1)** population/limit, idle-villager icon, unused-mine slots; **(2)** resources right→left wood, food, stone, gold, iron, coal with worker counts in brackets and **red gold when upkeep exceeds income**; **(3)** game menu; **(4)** unit info/orders/recruit queue/tech panel; **(5)** minimap + player score; plus "window in the **lower-left corner**" for unit selection; hotkeys J/K/L line/column/square, F replenish, D/E attack toggle. | [D] |
| S12 | https://www.gamepressure.com/cossacks3 | Guide index | Confirms guide scope: interface, units, buildings, nations, economy, land **and sea** warfare. | [D] |
| S13 | https://steamcommunity.com/sharedfiles/filedetails?id=1718178217 ("Cossacks HD") | Steam Workshop mod, 5.1 GB, 5.4k subscribers | Enumerates the donor's visual systems explicitly: "**Lighting, shadows, trees, ground, terrain, water, effects, musket smokes and arrows** (2k textures), **clouds**, settlers' accessories, **minimap**, simultaneous sounds"; units/buildings unchanged by the mod; new menu background. | [D] |
| S14 | https://steamcommunity.com/app/333420/workshop | Workshop browse | 194 items; categories Visual(25), UI(24), Units(12), Overhaul(17), Maps(3). Named: "Multicannon Animation Fix", "HD Terrain", "Shiny textures pack", "Mass Army Mod", "Remove news popup". | [D] |
| S15 | https://www.youtube.com/cossacks3 | Official channel | 86 videos; "Cossacks 3 Official Trailer" 4:35 / 811K views; "Cossacks 3 diplomacy basics" 384K; OST clips for Piedmont/Switzerland. | [D] |
| S16 | https://www.youtube.com/watch?v=_2AuBsK1uPI | Video (ledger #1) | 2025 raiding gameplay, 40:31; title/description only, no transcript frames. | [D] |
| S17 | https://www.youtube.com/watch?v=cZW0AEupCaI | Video (ledger #2) | "Skirmish Gameplay… Multiplayer… Historical Battles", PC/HD. Shell/flow from title. | [D] |
| S18 | https://www.youtube.com/watch?v=BiOjYTalqJc | Video | "MASSIVE 20.000 UNITS BATTLE" — title-level scale claim. | [D] |
| S19 | https://www.youtube.com/watch?v=32CtFfcPG74 | Mod showcase video | "MOD SHOWCASE: REALISTIC BATTLEFIELD" — title-level visual-mod evidence. | [D] |
| S20 | https://www.youtube.com/watch?v=UBrAcKrGANs | Mod showcase video | "NEW TERRAIN MOD (SPRING)… An overhaul… New seasons" — terrain/season visual family. | [D] |
| S21 | https://www.youtube.com/watch?v=jXTcrgRfjQE | Mod showcase video | "STATE vs COUNTRY ++" — new troops, different upgrade structure, 1600–1763. | [D] |
| S22 | https://www.youtube.com/watch?v=IfPcyZNK-CM | Editor tutorial | Editor can create terrains, battles, soldiers, armies; chapters include Piece Mode — proves authored terrain/unit visual variety. | [D] |
| S23 | https://cossackshq.net/cossacks-3-mods | Mod index | New Terrain Mod (Ebel), State vs Country, Rise of America — visual overhaul lineage. | [D] |
| S24 | https://www.dlcompare.es/juegos/100016515/... | DLC store with captions | **[D-caption]** "winter battlefield scene, soldiers, buildings and explosions in a snowy landscape"; "soldiers in historic uniforms, a market and riders on horseback"; "aerial view of a battlefield with formations". | [D-caption] |
| S25 | https://gameboost.com/cossacks-3-rise-to-glory-dlc-00-20371 | DLC page | Rise to Glory adds **winter maps** to single- and multiplayer; new nations/environments; screenshots exist (13). | [D]/[I-unseen] |
| S26 | https://github.com/anyalink99/cossacks-3-almanac/blob/main/docs_en/recon/README.md | Recon doc index | Confirms visual-mechanical systems behind the imagery: shot preparation, **temporary projectile vision**, elevation bonuses, area damage, naval combat, fog of war, formations, pathfinding, random-map generation. | [D] |
| L1 | `reference/videos.md` (local, read) | 17-video ledger | Clone checklist §57–66: animated units, nation buildings, construction stages/rubble, formations, flee/bayonets, full roster, artillery battery spacing. | [P-doc] |
| L2 | `README.md` (local, read) | Project README | Port feature table: 54 unit sheets, 215 nation building sheets, 182 mechanics numbers, formations 15–400, top-bar/minimap HUD. Hero images `final_nations.png`, `g2_final.png`. | [P-doc] |
| L3 | `docs/guides/GUIDE4.md` §0100–0103, §0200–0228, Appendix B (local, read) | Implementation guide | Port render/runtime truth + gap list G01–G17 + footage ledger B01–B12. | [P-doc] |
| L4 | `app/shots/**` (file list only, read) | Screenshot inventory | ~100 PNG/JPG names incl. `ref_official.jpg`, `ref_city.jpg`, `ref_huts.jpg`, `ref_peasants.png`, `ref_contact.jpg`, `ours_musk_sprite.png`, `g4_menu_audit.png`, `g4_l8_ghost_audit.png`, `uidrive/01_menu.png`, `uidrive/02_skirmish.png`, `uidrive/04_game_hud.png`, `uidrive/05_game_units.png`, `session1/frame_00*.png`, `_qa_video_smoke/*.png`. **Names only — not opened.** | [P-doc] |

Local ledger cross-check: the 17 videos in `reference/videos.md` correspond to
S16/S17 above plus the other listed YouTube IDs; I did **not** re-watch them —
watch pages return only an HTML shell from this machine (as `reference/videos.md`
already documents), so all video observations remain [D] title/description level.

---

## 2. What is visible in the donor (by category)

Every line here is **[D]** or **[D-caption]** unless tagged otherwise.

- **UI / HUD** — top strip carrying population/limit, an *idle villager* shortcut icon and an
  *unused mine slots* indicator; six resources (wood, food, stone, gold, iron, coal) with
  worker counts in brackets, gold turning red on negative upkeep; a game/menu button;
  a contextual unit panel (orders, upgrades, recruitment queue, technologies); minimap
  plus player score; a lower-left unit-selection window (S11). Order buttons and
  formation buttons live in that unit panel (J/K/L line/column/square, F replenish,
  D/E attack toggle) (S9, S11, S12). The port's own footage notes objective/event
  **text windows** as the campaign storytelling device (S4).
- **Menu / setup shell** — singleplayer shell menu → Skirmish / Historical Battles /
  Campaigns (L1 #2); map options list = **Terrain / Relief / Richness / Season / Size /
  Teams** (L3 Appendix B02); campaign screen shows objectives and hero-unit recruitment
  (L1 #17). Official channel hosts a "diplomacy basics" explainer, so an in-game
  diplomacy panel is visible too (S15).
- **Units** — "hübsch gemacht und recht detailliert" / pretty, quite detailed unit models
  (S4); a dedicated "Musketeer Animations Short Film" exists in the wiki gallery (S8);
  mass line battle of 5000 musketeers vs 1500 dragoons with volley fire and morale routs
  (L1 #3); 18c lines with musketeers, grenadiers, officers and drummers (L1 #6); 17c
  cavalry charges and mounted archers/tatars/janissaries/sipahi (L1 #5, #15); a
  "Multicannon Animation Fix" mod implies cannon crews have distinct firing animation
  worth preserving (S14). Uniforms differ by nation and century, incl. winter coats
  on winter maps (S24, S25).
- **Buildings** — growing town with houses raising the unit cap (S4); mines as distinct
  worked sites (S4); a market and historic uniforms in DLC screenshots (S24); nation
  architecture differs — Ukrainian wooden, Russian red-brick, Ottoman domes (L2, L3 B04);
  construction stages and rubble/death states exist in the donor (L1 #3, L3 §0101).
  Walls and gates, towers and bombards are visibly distinct (S4, S10).
- **Terrain** — pale meadow under battles with worn flecks at farm edges, dark sod rings
  under forests, pale sand collars at lakeshores, packed dirt under towns/mines/quarries,
  pale quarry scars with grey cores, low hills and raised positions used by musketeers
  holding a bridge (L3 Appendix B01/B03/B10; S4). Editor lets authors paint relief,
  minerals, farms, trees/bushes and blockade zones (L3 §0009–0013; S22). Mods add
  "spring"/new-season terrain palettes (S20, S23).
- **Weather / seasons / time of day** — winter maps with snow, soldiers in winter coats,
  explosions in snow (S24, S25); DLC unlocks winter **and desert** map generation (S2);
  "new weather effects layered onto base game" (DLC description, S7-family / store text);
  season is a **map option** in the setup screen (L3 B02). **[U]** whether a day/night
  cycle or rain exists in the base 2016 build — no text I found confirms it.
- **Effects / smoke** — musket smoke and arrow volleys are explicitly named as visual
  systems by the "Cossacks HD" mod (S13); "volley smoke + morale rout + officers" is the
  footage ledger's description of the 5000v1500 battle (L3 B03); explosions in snowy
  landscapes (S24); projectile physics and temporary projectile vision for bullets and
  cannonballs (S8, S26); corpses/rubble persist on the field (L3 §0101).
- **Water / naval** — "battles on land **and at sea**", build "the greatest armadas"
  (S1, S2, S12); line ships sinking a transport ship full of troops; "gewaltige
  Seeschlachten" / huge sea battles (S4); ships are a listed unit class with naval
  combat rules (S26); an official "la Manche" campaign mission (S12). Water surface
  itself is a texture/lighting target of the HD mod (S13).
- **Formations / density** — line, column and square with officer + drummer visible
  (S4, S9, S11); explicit Stand Ground loading bar before the defence bonus applies
  (S9 + Steam guide S11-family); replenish absorbs loose units; battery spacing for
  artillery (L1 #6, L3 B06). Density: marketing 32,000 (S1/S2), wiki 16,000 (S8),
  gallery caption "up to ten thousand units marching at once" (S4), a community video
  titled "MASSIVE 20.000 UNITS BATTLE" (S18) — all consistent with *thousands visible
  at once*, not dozens.
- **Scale of presentation** — isometric/3D over a broad map, camera zoomed far enough
  that whole armies and towns read together (Commons category tags "Isometric video
  game screenshots", 1920×1080 originals, S5/S6); "aerial view of a battlefield with
  formations" (S24). Reviews note it looks "colorful, smooth and charming" at rest and
  moving slowly, degrading under heavy load (GameWatcher review, fetched earlier).

---

## 3. Visible in donor / present in port? (by category)

Port column is **[P-doc]** — inferred only from README / GUIDE4 / videos.md, not from
opening images. "Partial" means the docs describe an implementation but a known gap or
verification step remains.

| Category | Visible in donor (evidence) | Present in port? (docs-only inference) | Verdict |
|---|---|---|---|
| **UI** | Pop/limit + idle villager + unused-mine icon, 6 resources with worker brackets + red negative gold, unit panel with orders/recruit/techs, minimap + score, lower-left unit window (S11 [D]) | "top bar + speed, bottom selection + minimap 200px bottom-left + frustum + right-click orders, command card, control groups 1-9, double-click same-type, cursors, hotkeys" (L3 §0102 [P-doc]). Resource strip and score/idle/mine icons not described in port docs. | **Partial** — functional HUD exists; information density and iconography not documented at donor parity. Minimap side differs (donor lower-left window mentioned for units; minimap position not fixed by S11 text → [U]). |
| **Menu** | Skirmish / Historical / Campaign shell, 6 map options Terrain/Relief/Richness/Season/Size/Teams, objectives + hero units (L1 #2/#17 [D]; L3 B02 [D]) | Skirmish is the default launch; a menu overlay and `uidrive/01_menu.png`, `02_skirmish.png` shots exist (L2, L4 [P-doc]). L3 B02 explicitly: "port menu needs same 6 one day". | **Partial** — shell exists, map-option set incomplete. |
| **Units** | Detailed 3D models, dedicated musketeer animation film, 8-dir marching/firing/dying, nation + century variants, cannon animation (S4, S8, S14 [D]) | 54 baked sheets, 8 directions × walk/idle/attack/death, CPU-skinned from donor `.oss`; work/gather clips rolled out; 215 nation building sheets (L2, L3 §0103 [P-doc]). L3 G14 notes peasant walk can slide/moonwalk; L7 is the isolation ladder. | **Present, with polish gap** — asset coverage strong; animation fidelity still being verified. |
| **Buildings** | Nation-specific wooden/brick/dome architecture, houses, mines, markets, walls/gates, towers, bombards, construction + rubble (S4, S10, S24 [D]; L2 [P-doc]) | 215 nation sheets + stages s1–s4 + `_dead`, ghost now a transparent nation sheet (L8), placement rules (L2, L3 §0101/§0119 [P-doc]). | **Present** — closest category to donor parity. Naval buildings absent (see Water). |
| **Terrain** | Meadow/fleck, dark sod under trees, sand collars, worked dirt, quarry scar, low/walkable vs steep hills, seasons (L3 B01/B03/B10 [D]; S20 [D]) | 6 terrain ids, chunked blended tiles, coherent variant noise, masks, forest belts, stumps, hills with height[]/slope, random seed wired — L1–L5 "implemented; verification pass in progress" (L2, L3 §0200–0230 [P-doc]). No winter/desert biome switch. | **Present for the base biome; partial overall** — season/biome variants missing. |
| **Weather** | Winter snow maps, winter coats, desert maps, season as a setup option, "new weather effects" (S2, S24, S25 [D-caption]) | No weather/season system described anywhere in README or GUIDE4. `world.gd` has `anim_t` for dusk shading notes (L3 DO-L1.08) but no precipitation/season state. | **Absent** — largest clean visual hole in a land skirmish. |
| **Effects** | Musket smoke + arrows, volley smoke, cannonball/bullet physics, temporary projectile vision, explosions, corpses/rubble (S13, L3 B03, S26 [D]) | `FX_CAP 220`, projectiles, corpses, rubble, fog render-only, overlays shadow/ring_sel (L2, L3 §0100–0101 [P-doc]). **No smoke/muzzle-flash/arrow-trail emitter is described.** | **Partial / likely absent** — FX plumbing exists, signature smoke does not appear in docs. |
| **Water** | Ships of the line, transports, huge sea battles, naval combat rules, improved water texture (S1, S4, S26, S13 [D]) | "water: no donor tile (port paints flat blue + sparkle, variants[3])" (L3 §0169 [P-doc]); no ships, shipyard or naval AI mentioned in README/MECHANICS summary. Land-only singleplayer skirmish. | **Absent** — flat blue surface only; no naval layer. |
| **Formations** | 15–400 inf + officer/drummer, 40–160 cav, line/column/square, Stand Ground loading bar, replenish, battery spacing (S9/S11 [D]; L3 B06 [D]) | "15–400-man formations with officers + drummers, +2/+3 bonuses (+9/+9 on hold), morale, routs, priests" (L2 [P-doc]); F/J/K/L hotkeys, squad links, ghost ellipse (L3 §0102 [P-doc]). | **Present** — mechanics and visuals both documented. |
| **Scale** | 10k–32k claimed, thousands on screen, aerial-wide framing (S1, S4, S18, S24 [D]) | "pop cap per player 200..8000 via houses (**port uses 200 default**)" (L1 §55 [P-doc]); `FX_CAP 220`, `SPRITE_CELL 160`, LRU 24 on weak GPUs (L3 §0066–0072 [P-doc]). | **Partial / far below donor** — 200 default vs thousands is the most obvious "why is my army tiny?" gap. |

Summary: strongest parity = buildings, formations, units (assets). Weakest/absent =
weather, water/naval, effects smoke, scale, and menu options.

---

## 4. GAP LIST — ranked by player-visible impact

Ranking criterion: **how obvious the absence is in a normal gameplay screenshot**, not
engineering difficulty. Ticket counts assume the SWARM_OPS "AAA" policy — one small,
independently assignable ticket per file or donor family (§5), WIP 20, disjoint
ownership, green selftest 28/28 + uitest 17/17 after each.

| # | Gap | Why it reads as "not Cossacks" | Suggested ticket scope | Est. tickets |
|---|---|---|---|---|
| **1** | **Volley / musket smoke, muzzle flash, arrow trails, impact FX** | Every mass-battle reference names smoke first; "Cossacks HD" lists *musket smokes and arrows* as a headline visual system (S13), footage ledger B03 says "volley smoke" (L3). Port has projectiles but no documented smoke emitter (L3 §0100–0101). | (a) bake/author smoke+puff+flash sprite sheet from donor FX family; (b) emitter in `world.gd` FX layer tied to `fire_t`/volley events in `game.gd`; (c) arrow-trail + impact puffs + cap/LOD so `FX_CAP` holds on weak GPU; (d) screenshot acceptance vs L3 B03. | **4** |
| **2** | **Mass-army scale / unit density** | 10k–20k–32k claims (S1/S4/S18) vs port's 200 default (L1 §55). Zoomed-out screenshots look like a skirmish, not a mass battle. | (a) raise default/limit pop cap with house scaling; (b) unit LOD (skip anim frames / merge draw at far zoom) + perf bench; (c) AI massing thresholds + CLI soak at high counts. | **3** |
| **3** | **HUD information fidelity** | S11's HUD is information-dense: pop/limit, **idle villager**, **unused mine slots**, six resources with worker brackets, **red negative gold**, unit/order panel, minimap + score, lower-left unit window. Port docs describe a working but thinner HUD (L3 §0102); score/idle/mine icon readouts are undocumented. Always on screen → maximum exposure. | (a) top-bar resource strip + bracketed worker counts + red deficit state in `hud.gd`; (b) idle-villager / empty-mine indicator buttons wired to selection; (c) score readout + minimap/command-card layout audit vs S11. | **3** |
| **4** | **Weather, seasons, day/night** | Winter snow maps + winter coats + desert maps are a stated DLC pillar (S2, S24, S25); Season is a setup option (L3 B02); spring terrain mods (S20). Port has one base biome only. | (a) season palette/terrain variant family (grass→snow/sand) in terrain assets; (b) snow cover + falling-snow particle layer; (c) unit/building tint variants for winter uniforms; (d) map option wiring in menu + mapgen; (e) S25/S24 screenshot acceptance; (f) perf regression check. | **6** |
| **5** | **Naval / ships / sea combat** | "Battles on land and at sea" is on the official page and every store blurb (S1/S2); S4 has line ships sinking transports and "huge sea battles". Port water is flat blue with no ships (L3 §0169). Whole content pillar absent. | (a) ship sprite sheets (line ship, transport, galley) from donor; (b) shipyard + naval buildings; (c) water-movement/blocking path; (d) naval combat/damage; (e) transport cargo; (f) AI ship production; (g) mapgen shore/sea placement. | **7** |
| **6** | **Animated water surface + shoreline** | Water is a named HD-mod target (S13) and a major fraction of the frame on naval maps. Port paints flat blue + sparkle only (L3 §0169, DO-L1.09). | (a) animated wave/gain shader or scrolling variant for terrain type 3; (b) foam/collar transition against type 4 shore. | **2** |
| **7** | **Setup menu map options** | L3 Appendix B02: donor exposes Terrain/Relief/Richness/Season/Size/Teams; port menu "needs same 6 one day". First screen a player sees after launch. | (a) menu controls for the six options; (b) wire each into mapgen/config + persisted defaults. | **2** |
| **8** | **Cast shadows, dynamic lighting, clouds** | Wikipedia and GSC materials call out dynamic lighting (S7); "Cossacks HD" explicitly improves lighting, **shadows** and **clouds** (S13). Port's "shadow" is a selection overlay/footprint disc (L3 §0101), not cast shadows. | (a) directional cast-shadow pass for units/buildings/trees; (b) daylight tint ramp (already hinted by `anim_t` notes in DO-L1.08); (c) sky/cloud backdrop or ground cloud-shadow motes. | **3** |
| **9** | **Battlefield decor & small detail** | L3 G08 flags bushes/shrubs absent; L4 adds stumps; S13 mentions settlers' accessories; S4 notes detailed units and "worked" town ground. These are the 3-second-close-zoom credibility details. | (a) bush/shrub decal family near quarries/shores; (b) shore tufts + path-worn flecks; (c) field/crop visual strips around mills; (d) screenshot acceptance vs L3 B10's four pauses. | **3** |
| **10** | **Unit animation polish (walk / chop / reload / attack cycle)** | Donor has a dedicated musketeer animation film (S8) and cannon animation fix mod (S14); L3 G14 records slide/moonwalk and "attack looks like walk" in the port, with L7 as the isolation ladder. Motion is what separates "sprites" from "the game". | (a) finish L7 bake-vs-action-vs-metrics isolation for all 54 keys; (b) attack/reload cycle timing per weapon class; (c) cav charge/gallop cycle; (d) frame-by-frame acceptance capture. | **3** |

**Estimated total: 36 worker-tickets.** Prioritised subset if only the top 5 are
approved: **23 tickets**. Gaps 1–3 are the highest ROI (≈10 tickets) because they
change almost every gameplay screenshot; gaps 5–7 are the largest *scope* but appear
only on water/season maps.

Suggested ticket-family ownership (so tickets stay disjoint per SWARM_OPS §3.2):
FX/effects → FX worker; scale/AI → sim worker; HUD/menu → UI worker; weather/terrain →
landscape worker; naval → separate naval worker; animation → sprite-baking worker.

---

## 5. Unverifiable items and honesty notes

- **[U] I never saw an image.** All donor visual statements above are descriptions
  (captions, prose, mod lists, titles/metadata). `webfetch` returned text/markdown only.
  I cannot claim "I looked at the Steam screenshot and saw X." The six Commons files
  (S5/S6), the 1920×1080 DLC shots (S24/S25) and the YouTube thumbnails exist and are
  cited, but their pixels were not available to me. A human reviewer should open them
  before any ticket is finalised.
- **[U] Day/night cycle and rain in the base game** — not confirmed by any text found.
  Winter/desert seasons are confirmed; avoid scoping rain/day-night without a visual check.
- **[U] Donor minimap corner** — S11 numbers the minimap as item 5 but does not give a
  screen corner; it separately mentions a lower-left unit-selection window. The port's
  minimap is bottom-left (L3 §0102). Do not assert a mismatch without viewing S11's
  screenshot.
- **[U] Exact port appearance** — taken from README/GUIDE4 prose, not from opening
  `app/shots/**`. The `g4_menu_audit.png`, `g4_l8_ghost_audit.png`, `uidrive/*` and
  `final_nations.png` files are the ones a verifier should open to confirm rows in §3.
- **[U] "Shadows" in the port** — L3 mentions `shadow/ring_sel` overlays; whether a real
  cast-shadow pass exists was not described, so gap 8 is inferred, not proven.
- **[D vs fact] Marketing numbers conflict** (32,000 / 16,000 / 10,000 / 20,000). These
  are claims from different sources and years; all are reported, none endorsed. The
  ranked gap uses only the robust qualitative claim: *thousands on screen at once*.
- No copyrighted image, sprite, texture, mesh or video was saved. The only file
  created by this agent is this document.

---

## 6. Report summary (for the coordinator)

- **Sources used:** 26 web sources (official site/store, SteamDB trailer index, GamePro
  3-page gallery, Wikimedia Commons category + file page, Wikipedia, two wikis,
  gamepressure UI guide, Steam Workshop "Cossacks HD" + browse, official YouTube channel,
  gameplay/mod-showcase videos, DLC captions, almanac recon index) + 4 local reads
  (`reference/videos.md`, `README.md`, `GUIDE4.md` §0100–0103/§0200–0230/Appendix B,
  `app/shots/**` filename list).
- **Categories compared:** UI, menu, units, buildings, terrain, weather, effects,
  water, formations, scale (10/10).
- **Top 10 visual gaps:** (1) volley/musket smoke, (2) mass-army scale, (3) HUD
  information fidelity, (4) weather/seasons, (5) naval/ships, (6) animated water,
  (7) menu map options, (8) cast shadows/lighting, (9) decor/detail, (10) unit
  animation polish.
- **Estimated ticket count:** 36 total (23 for top 5).
- **Files changed:** `docs/research/RE_VISUAL.md` (new) only. No other file touched.
