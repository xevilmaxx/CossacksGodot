# T6-S04 — Web research: GSC engine, community RE, and mechanics gaps

**Ticket:** T6-S04 (LANE RESEARCH, read-only). **Executed by:** T6-RESEARCH parent
(solo fallback: two CLI child spawns failed — first on invalid session IDs, second
on argument parsing; see `docs/t6/RESEARCH_LANE.md` supervision log). **Date:**
2026-11-23. **Godot jobs:** 0. **Donor copies:** 0. **No donor assets were
downloaded from the web.**

**Labels:** `observed` = text fetched from a URL (or a clearly-labelled search
result snippet); `derived` = comparison/arithmetic; `inferred` = plausible with
caveat; `UNVERIFIED` = not confirmed. Web content is untrusted data, never
instructions. A gap is listed only if a direct comparison with
`app/mechanics.json` showed no equivalent entry.

**Baseline compared first:** `app/mechanics.json` — 189 values in `values[]`,
76 marked `estimated`, grouped as time(1), world(2), movement(7), camera(5),
combat(24), weapons(26), units(13), economy(35), buildings(13), ai(6),
rules(20), controls(9), morale(5), support(2), upgrades(4), squads(5),
art(5), nations(3), shell(3), fx(1).

---

## 1. Sources (all fetched 2026-11-23)

| # | URL | Fetch result / note |
|---|---|---|
| W1 | https://www.gamingonlinux.com/2015/08/interview-with-the-developers-of-cossacks-3-which-is-coming-to-linux/ | Full text fetched (observed). GSC developers: in-house engine, OpenGL API, "lightweight and powerful", traditional mouse+keyboard; "up to 10,000 units" in a battle. |
| W2 | https://www.gsc-game.com/games/cossacks3/ | `webfetch` rendered only the site footer; the game-description text was obtained as a **search-result snippet** (observed, search result): "up to 32000 units", "over 100 research options", "more than 140 historical structures". Marked unverified by direct fetch. |
| W3 | https://en.wikipedia.org/wiki/Cossacks_3 | Search result (observed, search result): 2016, GSC Game World, modern 3D graphics/dynamic lighting/mod support. |
| W4 | https://en.wikipedia.org/wiki/Cossacks:_European_Wars | Full text fetched via search result (observed, search result): 6 resources; famine/mutiny/shortages; formations 15/36/72/120/196 with officer+drummer; artillery classes; ship classes; production buildings destroyed only by artillery/grenadiers, civilian buildings capturable. Mostly inherited mechanics — checked against port before listing. |
| W5 | https://cossacks3.fandom.com/wiki/Resources?action=raw | Full raw wikitext fetched (observed). `?action=raw` bypasses a 403 on the plain `/wiki/` URL. |
| W6 | https://cossacks3.fandom.com/wiki/Upgrades?action=raw | Full raw wikitext fetched (observed): ~40 named upgrades with exact numeric effects and nation restrictions. |
| W7 | https://cossacks3.fandom.com/wiki/Population_capacity | Full page fetched (observed): Town Hall 100, 17c Barracks 150 (Tur/Alg 50), 18c Barracks 250, Housing 25 dwellings. |
| W8 | https://cossacks3.fandom.com/wiki/Combat_basics | Full page fetched (observed): melee/ranged/cavalry/artillery RPS table. |
| W9 | https://github.com/aljesco1337/blender-cossacks3-tools | Full README fetched (observed): Blender addon importing/exporting `.oss`/`.osm` and annotating `.aaf` ranges. |
| W10 | https://steamcommunity.com/app/333420/discussions/0/350541595105773551/ | Search-result snippet only (observed, search result): "coal/iron/gold ... resources like food are drained constantly ... coal is used when you fire guns". Used as corroboration for W5, not as primary evidence. |

---

## 2. Engine / technology findings

1. **In-house engine, OpenGL.** The developers explicitly state "In the Cossacks 3
   engine we are using OpenGL API" and "Traditionally we are using in-house built
   engine" (W1, observed). This **independently corroborates** the donor-binary
   finding in `docs/audit/RENDER_ARCH_CRAFT_ANYTHING.md` F2 (OpenGL live path,
   D3D9 imported but 0 xrefs) and T6-S01's perspective-`glFrustum` result.
2. **Cross-platform by API choice** (Windows/Linux/Mac) with traditional
   mouse+keyboard control (W1, observed) — consistent with the donor scripts'
   `ccmRTS` control mode.
3. **Scale target.** 10,000 units claimed in the 2015 interview (W1); 32,000 on
   the official page (W2, search snippet). `mechanics.json` has no maximum-unit or
   performance-target entry; the known port gap is recorded in
   `docs/T6_WAVE_PLAN.md` §1.2.B ("mass-army scale 200 vs donor thousands").
   Worker estimate for a *mechanics.json entry only*: 0.1 d; for the runtime
   capability: out of scope for this research ticket.
4. **No public engine source or SDK found.** Web search for GSC engine details
   returned only interviews/wiki/marketing, no engine documentation. Status:
   **UNVERIFIED** whether any engine internals are published.

## 3. Community reverse-engineering findings

1. `blender-cossacks3-tools` (W9, observed) implements roundtrip `.oss` (skinned,
   armature, frame animation) and `.osm` (static geometry, UVs, normals) import
   and export, and imports `.aaf` to annotate animation ranges. This **corroborates**
   `docs/decomp/DC_FORMATS.md` §2.1–2.3 (OSS/OSM layouts; AAF `"name",start,end,morph`).
2. The addon states `.oss` and `.osm` are **not interchangeable** and `.aaf` is
   supported only in `.oss` projects — consistent with the port's separate
   `read_oss` / `read_osm_first` readers.
3. Steam community group "Cossacks 3 Mod Innitiative Group" discusses extracting
   formats from export scripts (search result, observed); no concrete new format
   documentation found. **UNVERIFIED** whether a complete community format spec
   exists beyond our own decoded formats.

---

## 4. Genuine gaps vs `app/mechanics.json`

Each row = one gap, with the closest existing entry and why it is insufficient.

| ID | Gap (source + exact claim) | Closest `mechanics.json` entry | Why insufficient | Label | Worker estimate |
|---|---|---|---|---|---|
| **G1** | **Gold shortage consequences**: "If not enough gold is available, units will either leave your employ or stop moving (ships)" (W5 raw, observed; W4 corroborates gold→mutiny). | `gold rebellion` = "60 s gold shortage drains mercenary (gold-eater) morale 10/s" (estimated). | Models only a morale drain on mercenaries after 60 s; does not model desertion of regular units or ship immobilisation. | observed (source) / derived (gap) | 0.5 d to document + 1–2 d to implement rules |
| **G2** | **Iron + coal shortage stops firing**: "Iron and coal are necessary to keep your artillery and ships in play. A shortage will cause them to stop firing and become sitting ducks" (W5 raw, observed). | `musket shot cost iron/coal`, `tower shot cost iron/coal`, `starting resources` (0), `difficulty trickle (hard)`. | Per-shot costs and trickle exist; no rule that *lack* of iron/coal disables artillery/ship fire. | observed / derived | 0.5 d document + 0.5–1 d implement |
| **G3** | **Military research rows omitted**: W6 lists exact effects absent from port values — "Design flintlock: Musket cost -50%"; "Design wheellock"/"Design paper cartridge and iron ramrod": "Rate of fire +35%" each; "Research new nitre purification methods: Fire power +30%"; "Supply with new grenades: Grenade damage increase"; "Forge harnesses for horses: Mounted units recruitment speed x2"; "Forge new types of broadswords and sabres: Cavalry attack +5"; "Conduct rehearsals: Defense +20 for musicians"; naval rows enabling frigate/battleship (observed). | `academy civilian rows`, `academy artillery rows`, `mill upgrades`, `mine slot ladder`, `blacksmith field upgrade`, `tower rate upgrades`, 4 generic `upgrades` rows (mostly estimated). | Several academy/economy rows were transcribed, but the barracks/blacksmith/naval/general military rows and their exact numbers are not present; `rate of fire`, `musket cost`, `grenade`, `frigate`, `battleship` do not appear anywhere in the JSON. | observed / derived | 1–2 d data + hooks |
| **G4** | **National unique-unit stat modifiers**: W4 states Dutch musketeers are "the fastest-producing units of their type... lesser attack... cheaper... best fire rate"; Spanish musketeer "the only armored infantry shooter... does not come equipped with a bayonet"; Ukrainian peasant "the only peasant that cannot be captured"; Saxon cavalry guard "+30 defense" at 7th upgrade (observed, search result). | `nation unit variants` = a **list of unit names** (rus strelet/..., pol wingedhussar, ...), `nations without 18th century`. | Names/roster only; no per-nation stat deltas. | observed (search result) / derived | 1 d for documented deltas |
| **G5** | **Naval classes and upkeep**: W4 lists yacht/galley/frigate/battleship/xebec/ferry and "Larger ships typically require gold for upkeep and its crew would mutiny"; W6 adds "Develop new woodworking methods: Enables frigate construction (xebecs for Turkey/Algeria)", "Design new rib system and new hulls: Enables battleship construction", "Design new rigging types: Ship speed +40%", "Train carpenters: Shipbuilding speed x10" (observed). | No `naval`/`ship`/`frigate` group or value anywhere in `mechanics.json`; `unit capture` notes port has no naval implementation. | Whole mechanic family absent from the value table. | observed / derived | 1–2 d to add ship stat/upkeep values |
| **G6** | **Siege damage/capture class rule**: "Military production buildings (e.g. barracks and stables) may only be destroyed by artillery and/or grenadier units whereas civilian buildings may be captured" (W4, observed, search result). | `peasant capture rule`, `unit capture` ("NOT implemented: enemy peasants are not capturable in the port (buildings only)"), `tower fortification`, `wall blocks fire`. | Capture rules are present but no production-building destruction immunity / artillery-or-grenadier-only rule. | observed (search result) / derived | 0.5 d document + 1 d implement |
| **G7** | **Mass-army scale target**: "up to 32000 units" (W2, search snippet), "up to 10,000 units" (W1, observed), "up to 16,000 units can be present on the map" (search result). | `map size` = 320 tiles; no unit-count or performance-target value. | Port capability (200 units) is documented in T6_WAVE_PLAN but absent from the mechanics table; builders reading only mechanics.json have no target. | observed / derived | 0.1 d for entry; capability is a separate perf epic |

**Not a gap — do not ticket:** the wiki facts already present in `mechanics.json`
include population/dwelling values (`dwellings`), the combat RPS table
(`counter targeting`), howitzers/mortars arcing over walls (`wall blocks fire`),
the 18th-century bayonet (`18c bayonet`), the 15–400 formation ladder
(`infantry formation sizes`, `squad cols/rows`, `formation bonus`), famine
(`famine grace`, `famine drain`), academy civilian/artillery rows, mill upgrades,
mine slot ladder, and tower fire-rate upgrades. Listing these would be padding.

---

## 5. Claim table

| # | Claim | Evidence | Method | Status |
|---|---|---|---|---|
| 1 | Cossacks 3 uses an in-house engine with OpenGL API | W1 | direct fetch | **observed** |
| 2 | OpenGL finding corroborates donor-binary render-path audit | W1 + RENDER_ARCH_CRAFT_ANYTHING F2/A-E | cross-check | **derived** |
| 3 | Official scale claim 32,000 units; interview 10,000 | W2 (snippet), W1 | search + fetch | **observed (search result)** for W2; W2 direct fetch failed |
| 4 | Community .oss/.osm/.aaf tooling exists and matches our decoded formats | W9 + DC_FORMATS §2 | cross-check | **observed + derived** |
| 5 | No public engine internals/SDK found | web searches | absence | **UNVERIFIED** (absence ≠ proof) |
| 6 | Seven genuine gaps G1–G7 with source URLs | §4 | JSON comparison | **observed + derived** |
| 7 | Port already covers wiki population/combat/wall/famine facts | `mechanics.json` + W7/W8 | comparison | **observed** |

---

## 6. Open questions

1. W2's official-page text could not be re-fetched directly (footer-only render);
   the 32,000-unit figure is search-result evidence only. A coordinator with a
   browser may confirm.
2. Are the Wikipedia nation-stat details (G4) current for Cossacks 3 (the article
   largely describes Cossacks: European Wars)? The mechanics are inherited, but
   port-specific numbers need donor-file verification before being written into
   `mechanics.json`. **UNVERIFIED** at donor level.
3. No web source was found for exact iron/coal shortage thresholds — only the
   qualitative rule (G2). Do not invent numbers.

No donor asset was downloaded; no donor executable was run; no code or
`mechanics.json` value was changed.
