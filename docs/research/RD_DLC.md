# RD — Cossacks 3 DLC/expansion/mods research + port gap estimate

Research agent **RD** (Research lane, `SWARM_OPS.md` §5b), 2026-11-21.
**Research only.** No Godot launch, no game-code edit, no donor file copied,
downloaded or converted. All donor paths below were inspected **read-only**.

## 0. Sources used (public, cited)

| # | Source | URL | What it established |
|---|---|---|---|
| S1 | Steam — Downloadable Content for Cossacks 3 (app 333420) | https://store.steampowered.com/dlc/333420/Cossacks_3/ | Authoritative DLC names, prices, release dates, one-line contents. Lists 9 SKUs incl. 5 content DLCs, Digital Deluxe Upgrade, 2 seasonal events, OST. |
| S2 | Wikipedia — Cossacks 3 §Downloadable content | https://en.wikipedia.org/wiki/Cossacks_3 | Per-DLC content summaries (nations, campaigns, scenarios, landscapes). Article itself flags "needs more citations"; cross-checked against S1/S3/S4. |
| S3 | CossacksHQ International — Downloadable contents | https://cossackshq.net/c3-downloadable-contents/ | Season-pass membership; separates paid DLCs from free Halloween / Winter Holiday / Summer Holiday updates. |
| S4 | Steam news (GSC announcements, reposted) — "The Golden Age – Release/Announcement" | https://store.steampowered.com/news/posts/?appids=333420&enddate=1504710790 | Detailed feature list for The Golden Age (8 historical battles, "Oranien boven!" Dutch campaign, 4 scenarios, Switzerland/Piedmont, 5 units, 2 soundtracks). |
| S5 | Wargamer.fr — "Trois nouveaux DLC pour Cossacks 3" (2017-04-28) | https://www.wargamer.fr/trois-nouveaux-dlc-pour-cossacks-3/ | Full announcement text for Rise to Glory, Guardians of the Highlands, Path to Grandeur (units, mechanics, AI assistant, nations, soundtracks). |
| S6 | CossacksHQ — Cossacks 3 Mods | https://cossackshq.net/cossacks-3-mods/ | Community mods (New Terrain, Rise of America, State vs Country Empire, MGraphics, Cossack Annihilation, sound mods). None physically present in the donor install (§3). |
| S7 | ModDB — Cossacks III mods | https://www.moddb.com/games/cossacks-iii/mods | Same conclusion: community mods are external downloads, not part of the local install. |
| S8 | Save Game Vault — Path to Grandeur | https://savegamevault.com/games/cossacks-3-path-to-grandeur/ | Corroborates 8 units (Sipahi, Coselete, Hajduk, Grenzer, Grenadier, Hussar, Portuguese 17c Pikeman/Jaeger), desert climate, Hungary/Portugal, Ottoman & Spanish campaigns. Secondary source. |
| S9 | CossacksHQ — Nations | https://cossacks3.fandom.com/wiki/Nations (Fandom) / https://cossackshq.net/cossacks3/ | 12 base nations; DLC nations added by each pack. |
| D1 | Donor install (read-only) | `C:\Games\Cossacks 3` | `dlcs/` tree, `data/scripts/lib/country.script`, `data/actors/units`, `data/maps/missions`, `steamscript.vdf`, `cossacks.ini`. |
| P1 | Port (read-only) | `app/assets/missions.json`, `app/scripts/{data,menu,main,pattern_gen}.gd`, `app/assets/models/anim/index.json`, `app/CREDITS.md`, `docs/DLC_INVENTORY.md`, `WAIVERS.md` | What the Godot port actually has. |

## 1. Named DLCs / expansions verified from public sources

**The example names in the task brief — "Rise of the Ottoman Empire", "Fire and
Ice", "Gold Edition", "Wings of Victory" — are NOT Cossacks 3 DLCs.** Searches
against S1–S3 and S5–S8 found no such Cossacks 3 products. "Ottoman Empire"
content exists only as the **Path to Grandeur** Ottoman campaign; "Gold Edition"
is at most a bundle SKU, not a named content pack. Marked **UNVERIFIED / likely
conflation with Cossacks 1–2 or another title**. They were *not* invented into
the table below.

| DLC (official name) | Release | Content (public claims) | Donor folder on disk | In base install? |
|---|---|---|---|---|
| **Early Bird Pack** | 2016-09-20 (S3) | Pre-order bonus; cosmetic/content unspecified in S3. No mission maps in donor that can be attributed to it. | none identifiable | Pre-order-only; not a separate folder |
| **Days of Brilliance** | 2016-12-13 (S1,S2,S3) | Polish campaign; 5 historical scenarios; new units for old nations; **Denmark + Netherlands** as playable nations; soundtrack (S2,S3). | `dlc1` (inferred — see §2) | **Yes, physically present** |
| **Rise to Glory** | 2017-02-15 (S1/Steam; S2,S3 say 16 Feb) | Prussian + Swedish campaigns; 7 new units (3 wholly new); **snow/winter maps**; 3 scenarios; **Bavaria + Saxony**; ranked/ladder + Quick Play (S2,S5). | `dlc2` (inferred) | **Yes, physically present** |
| **Guardians of the Highlands** (mini-expansion; only one *not* in Deluxe Edition) | 2017-04-12 (S1,S2,S3; S5 says announced 11 Apr) | **Scotland** nation (new to series) with unique mechanics/units/buildings; Scottish campaign; **9 unique units**; "Personal Assistant" AI helper; new soundtrack (S2,S5). | `exp1` (inferred) | **Yes, physically present** |
| **Path to Grandeur** | 2017-05-16 (S1,S3,S8; some sources 16 Jun) | **Ottoman** + **Spanish** campaigns; **desert climate zone**; 8 unique units (Sipahi, Coselete, Hajduk, Grenzer, Grenadier, Hungarian Hussar, Portuguese 17c Pikeman/Jaeger, Portuguese unique Shipyard); **Hungary + Portugal**; own soundtracks (S2,S5,S8). | `dlc3` (inferred) | **Yes, physically present** |
| **The Golden Age** (final Deluxe Edition DLC) | 2017-08-24 (S1,S2,S4) | "Historical Battle" 8-player mode + 8 battles; **Dutch** campaign "Oranien boven!"; 4 scenarios (Dunkirk, Brazil, Caribbean, Portuguese Restoration); **Switzerland + Piedmont**; 5 units (Swiss 17c Pikeman, Jaeger, Mounted Jaeger; Piedmont Padre, 18c Dragoon); 2 soundtracks (S4). | `dlc4` (inferred) | **Yes, physically present** |
| **Christmas Gift** / Winter Holiday (free seasonal event) | 2017-06-22 SKU date; holiday 2016/2017 (S1,S3) | Holiday gift mission ("help Santa save Christmas", S1); previously released winter event content. | `winter` (inferred) | **Yes, physically present** |
| **Summer Fair** / Summer Holiday (free seasonal event) | 2017-06-22 (S1,S3) | Seasonal event content. | `summer` (inferred) | **Yes, physically present** |
| **Halloween** (free update) | Halloween 2016 & 2017 (S3) | Seasonal event content. | none identifiable | No separate folder |
| **Digital Deluxe Upgrade**, **OST** (21 tracks, WAV, S1) | 2016-09-20 / 2017-06-22 | Bundle / soundtrack SKUs — no mission maps attributable. | none | n/a |

**Mods:** S6/S7 list community mods (New Terrain, Rise of America, State vs
Country Empire, MGraphics, Cossack Annihilation, sound mods). None are present
as files in the donor install's `dlcs/`, `scripts/` or root. Out of port scope
and **not downloaded**. Marked **UNVERIFIABLE** whether any mod was ever
installed then removed.

## 2. Physically present on disk (read-only donor listing)

`C:\Games\Cossacks 3\dlcs\` contains exactly **7 directories**. Full file
inventory and byte totals are in `docs/DLC_INVENTORY.md` (worker AD) — my
independent listing agrees with it: **67 files, 49 `.map` + 18 `.aix`, ≈2.88 GiB
total**. Every file sits under `<folder>\data\maps\missions\`.

| Folder | Mission stems | Files | Folder→DLC mapping |
|---|---|---|---|
| `dlc1` | `polmis1–5`, `scemis1–5` | 10 `.map` + 10 `.aix` | Days of Brilliance |
| `dlc2` | `prumis1–5`, `scemis6–8`, `swemis1–5` | 13 `.map` | Rise to Glory |
| `dlc3` | `spamis1–5`, `turmis1–5` | 10 `.map` + 4 `.aix` | Path to Grandeur |
| `dlc4` | `netmis1–5`, `scemis9–12` | 9 `.map` + 2 `.aix` | The Golden Age |
| `exp1` | `scomis1–5` | 5 `.map` | Guardians of the Highlands (Scotland) |
| `summer` | `celmis2` | 1 `.map` + 1 `.aix` | Summer Fair / Summer Holiday |
| `winter` | `celmis1` | 1 `.map` + 1 `.aix` | Christmas Gift / Winter Holiday |

**⚠ UNVERIFIABLE:** the folder names are opaque (`dlc1..dlc4`, `exp1`,
`summer`, `winter`) and contain **no manifest** naming a DLC. The mapping above
is an **inference** from (a) mission-stem nation prefixes (`pol`=Poland,
`pru`=Prussia, `swe`=Sweden, `spa`=Spain, `tur`=Turkey, `net`=Netherlands,
`sco`=Scotland), (b) `sce*` = "scenario" runs that continue across DLCs, and
(c) Steam release content. `steamscript.vdf` and `cossacks.ini` contain no DLC
name mapping. It is strongly supported but not directly proven.

**No mesh/texture/sound families exist in `dlcs/`.** All portable-looking
content (nation meshes, units, buildings, sounds, terrain) lives in the **base**
`data/` tree, which the port already reads. The DLCs add mostly *mission maps*
plus rules/roster data compiled into the base engine and scripts.

## 3. What the port currently has (read-only)

| Aspect | Evidence | Status |
|---|---|---|
| Nations | `app/assets/missions.json` lists **20** nations: 12 base + `net,den` (DoB), `bav,sax` (RtG), `hun,por` (PtG), `pie,swi` (TGA). **No `sco`.** | DLC nations 8/9 present; **Scotland missing** |
| Donor nation registry | `data/scripts/lib/country.script` has `sco` as **id 21** (after `swi`=20) — donor knows Scotland. | Confirms a real, not invented, gap |
| Campaign IDs | `missions.json` lists `netcam, scecam3, swecam, scecam, scocam, spacam, turcam, prucam, polcam, celcam` and `battle1..8`. | IDs present |
| Campaign mission lists | Populated: `tutcam`(2), `netcam`(5=netmis), `scecam3`(4=scemis9-12), `swecam`(4=scecam2+scemis6-8), `scecam`(5=scemis1-5), `auscam/engcam/ukrcam/ruscam/fracam`(5 each), `boncam`(3). **Empty:** `polcam, prucam, spacam, turcam, scocam, celcam`. | **32 DLC mission IDs unwired** (polmis/prumis/swemis/spamis/turmis/scomis ×5 + celmis ×2) |
| UI behaviour | `app/scripts/menu.gd:293-306` builds one button per mission ID; empty arrays produce **no buttons**. Mission pick only sets nations/map/start (`menu.gd:312-316`); no `.map` is loaded. | Missing missions are invisible to players |
| Unit data | `app/scripts/data.gd` already defines `sipahi` (:507), `highlander` (:590), `padre` (:608), `hussar`/`wingedhussar`/`grenadier` etc. | DLC unique units partly modelled |
| Unit animation sheets | `app/assets/models/anim/index.json` — 54 keys. `sipahi, highlander, padre, hussar, wingedhussar, grenadier` = **present**; `coselete, hajduk, grenzer, jaeger, sco` = **absent**. 1,806 PNG files total. | Partial |
| Scotland buildings | `app/assets/models/anim/sco*.png` = **14 sheets** already baked from donor `<nat>_<bld>.osm`. | Visuals partly ready; nation not selectable |
| Climates | `app/scripts/data.gd:161` `BIOME := "summer"` with comment "summer / winter / desert"; `main.gd:217` reads `biome` from config; `pattern_gen.gd:126-127` has `desert_` family mapping. `app/assets/terrain/blocks/winter*.png` (27) and `desert*.png` (12), `sand*.png` (4) exist. | Climate **assets + plumbing largely present**; per-mission climate not wired |
| Historical battles | `battle1..8` in `missions.json`; `app/assets/maps/battle1.json` extracted. `battle*.map` are 8-player, multiplayer-oriented. | Partially present; multiplayer out of private-SP scope |
| DLC map geometry | `app/assets/maps/*.json` = only `ausmis1, battle1, rusmis1, ukrmis1` (+`_summary`). **No DLC stem.** `.map` heightmap has no public spec (`app/CREDITS.md:75-85`); `extract_map.py` reads header/placement names only. | Not portable directly; procedural mimic required |
| Cinematics | `data/video` contains only an empty 64-byte `video.lib` (per `docs/DLC_INVENTORY.md` §2). **WAIVED** in `WAIVERS.md` (decision Q4). | Non-gap |
| Naval | Waiver **withdrawn** (`WAIVERS.md` update); 54 readable ship meshes → port ticket **P-10**. Relevant to Path to Grandeur's Portuguese unique Shipyard. | Adjacent ticket, not my lane |
| Music | `app/assets/sounds` = 305 OGG (base ambient/music `ukr, rus, amb_*`). No DLC-specific soundtracks identified. | Cosmetic gap |

## 4. GAP LIST — portability, ticket scope, worker-ticket estimate

Legend: **[P]** playable · **[C]** cosmetic · **[N]** cinematic.
"Tickets" = small, independently assignable worker tickets per the 100-ticket
roster model. Estimates assume private-use, singleplayer-skirmish scope; no
multiplayer, no redistribution.

| ID | Gap | Class | Portability estimate | Suggested ticket scope | Tickets |
|---|---|---|---|---|---|
| G1 | **Scotland not selectable** — donor `sco` id 21 exists; 14 `sco` building sheets + `highlander` unit/anim baked, but no nation entry, no `sco` roster or UI. | [P] | **Low–Medium**: nation registration is config/data-only; 9 unique units + "new game mechanics" push it up. Reuse existing `sco*.png` and `highlander` assets (no new donor conversion needed). | (a) register `sco` in `missions.json`+`data.gd`; (b) Scottish roster/unique stats + icon mapping; (c) Highland mechanics + QA | **3** |
| G2 | **32 DLC mission IDs unwired**: empty campaign arrays in `polcam/prucam/spacam/turcam/scocam/celcam`, plus `swemis1–5` absent from `swecam` (7 clusters). | [P] | **Low**: extend `missions.json` mission arrays; each mission resolves to a procedural setup (nations, start army, map type), consistent with `menu.gd` design. No donor binary needed. | One ticket per mission cluster: `polmis`, `prumis`, `swemis`, `spamis`, `turmis`, `scomis`, `celmis` (or 1 combined data ticket + 1 QA) | **7** (min 2) |
| G3 | **DLC map geometry/layout** — 49 closed `.map` files, ~2.9 GiB; no public heightmap spec. | [P] | **Low feasibility / High effort**: cannot decode; mimic each mission on procedural terrain like existing `ausmis1` etc. `extract_map.py` can supply nation/unit mix from placement names. | One "DLC mission mimic" ticket per cluster, paired with G2 (reuse extraction output); 1 spike ticket to test `extract_map.py` on a DLC `.map` | **7 + 1 spike** |
| G4 | **DLC-unique unit visuals missing**: `coselete, hajduk, grenzer, jaeger` absent from 54-key anim index. ⚠ **UNVERIFIABLE** whether donor has distinct `.oss` meshes — my read-only glob found no `coselete/hajduk/grenzer/jaeger*.oss`; donor *does* have `hussarhun/hussarswi/grenadier{hun,sax,bav,den,pru}.oss`, so many "unique units" are likely stat/name aliases on shared meshes, not new art. | [P]+[C] | **Medium** if alias-only (data + icon remap); **High** if distinct meshes must be baked. Verify donor meshes first. | (a) read-only mesh/alias audit; (b) alias+stat mapping in `data.gd`; (c) any genuinely new bake | **2–4** |
| G5 | **Climate per mission not wired** — winter (RtG) and desert (PtG) textures + `BIOME`/pattern plumbing already present. | [P]+[C] | **Low**: assign `biome` per mission in config; assets exist. Verify `summer`/`winter` preset naming collision flagged by AD. | (a) per-mission biome field; (b) QA both climates | **2** |
| G6 | **DLC soundtracks / stinger music** (Highlands, Hungary, Portugal, Switzerland, Piedmont, Golden Age ×2) — not identified under `app/assets/sounds`. | [C] | **Medium**: donor OGGs must be located read-only and privately copied/converted; no code risk. | One ticket per soundtrack family (group by DLC) | **2** |
| G7 | **18 compiled `.aix` mission AI blobs** — no public spec; port AI is already an approximation (`app/CREDITS.md:86-87`). | [P] | **Low priority / High effort**: do not attempt decode; reuse existing port AI with per-mission force/starter config. ⚠ UNVERIFIABLE whether `.aix` is decodable. | 1 "defer + document" ticket, 1 optional config-only AI tuning ticket | **1** (defer) |
| G8 | **Historical Battle 8-player mode** (Golden Age) — `battle1..8` IDs + 1 map extract exist; multiplayer out of private-SP scope. | [P] | **Low** for singleplayer replay of the 8 battles; **N/A** for netcode (out of scope). | 1 ticket to expose battle1..8 as SP skirmish presets | **1** |
| G9 | **"Personal Assistant" AI helper** (Highlands) — new mechanic, absent. | [P] | **High**: new subsystem (build advice + idle-peasant routing) touching `game.gd`/`hud.gd`; core sim is one contended file. | 2 tickets (advice logic; UI + routing), 1 QA | **3** |
| G10 | **Portuguese unique Shipyard / naval** (PtG) — cross-reference to withdrawn waiver → port ticket **P-10** (54 readable meshes). | [P] | **Medium** (mesh evidence recorded in `NAVAL_EVIDENCE.md`); already a separate ticket — do not duplicate here. | Track under P-10; add "Portugal shipyard" acceptance criterion | **0** here |
| G11 | **Cinematics** — empty `video.lib`, no video files, waiver Q4. | [N] | **N/A — WAIVED.** | None | **0** |
| G12 | **Free seasonal event maps** (`celmis1`, `celmis2`, Halloween) — covered by G2/G3 clusters; possible festive décor. | [P]+[C] | **Low**: config + optional reskin using existing seasonal terrain. | Folded into `celmis` cluster (G2/G3) | **0** (folded) |

**Estimated worker-ticket count:** **≈24–31** for full DLC coverage
(G1 3 + G2 7 + G3 8 + G4 2–4 + G5 2 + G6 2 + G7 1 + G8 1 + G9 3 = 29–31;
round down to 24 if G3/G2 are batched and G4 resolves to aliases).
**Minimum viable "DLC present in UI" slice:** **~10 tickets** (G1 nation 3,
G2 combined missions 2, G5 climate 2, G8 battles 1, G6 grouped audio 2) —
this makes all 9 nations selectable and all campaign IDs clickable without
decoding any donor binary.

**Suggested priority order (triaged by impact/cost):** G1 → G2 → G5 → G8 →
G3 (spike first) → G4 → G6 → G9 → G7. G11 is closed; G10 is P-10's lane.

## 5. Unverifiable claims (explicit)

1. **Folder→DLC name mapping** (§2) is inferred, not manifest-backed.
2. **The task-brief example DLC names** ("Rise of the Ottoman Empire", "Fire and
   Ice", "Gold Edition", "Wings of Victory") returned no Cossacks 3 product in
   S1–S3/S5–S8; treated as non-existent for this title, not asserted absolutely.
3. **Exact release-day discrepancies** (Rise to Glory 15 vs 16 Feb; Path to
   Grandeur 16 May vs 16 Jun) — different sources disagree; S1 (Steam) preferred.
4. **Whether donor has distinct meshes** for Coselete/Hajduk/Grenzer/Jaeger —
   my glob found none, but only a filename-level check was performed.
5. **`.aix` decodability** — counted by extension/size only, never decoded.
6. **Whether any community mod was ever installed** in the donor — no mod files
   found; absence of evidence only.
7. **Exact per-DLC unit counts** (Wikipedia "5 units" vs S4's itemised list for
   TGA; "7 new units, 3 completely new" for RtG; "9 unique" for Scotland; "8"
   for PtG) are announcements, not verified against donor asset files.
8. **No Godot run** was performed; all port state is from static file reads, so
   runtime behaviour of empty-campaign buttons is inferred from `menu.gd` code.

## 6. Compliance

No donor file was copied, converted, uploaded, published or committed. All
donor paths point to the owner's local `C:\Games\Cossacks 3`. Cross-referenced
with `docs/DLC_INVENTORY.md` (AD), `WAIVERS.md`, `app/CREDITS.md` and
`SWARM_OPS.md` §3.5 — this report adds no waiver and changes no scope decision.
Files changed by me: **only this file** (`docs/research/RD_DLC.md`).
