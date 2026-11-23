# Donor skirmish options — port support / gaps (T-MENU-ROSTER)

Source: owner-verified donor reads (`en\gui.txt`, `showcustomgame.inc`,
`miscext2.script`). The canonical serialized struct is
`season,terraintype,relieftype,resourcestart,resourcemines,mapsize,startingunits,
balloon,cannons,peacetime,century18,capture,marketdip,teams,autosave,limit,
gamespeed,adviserassistant`. The menu emits all of these plus the 2..12 `players`
roster and legacy aliases. Data ids live in `app/scripts/data.gd` (`DONOR_*`).

**Port extension: up to 12 players (donor max 8 non-spectators).** The donor's
`gc_MaxNonSpectatorsCount = 8` (`dmscript.global:97-98`); `gc_MaxPlayerCount =
12` counts pseudo/spectator slots. The owner explicitly asked for MORE
skirmish players, so the port raises the shared `Data.MAX_PLAYERS` cap to 12,
adds four start anchors (`game.gd _start_positions` slots 8..11), four colour
lanes (`world.gd PLAYER_COLORS`, `menu.gd ROSTER_COLORS`) and a full-screen
two-column skirmish layout. This is a **PORT EXTENSION beyond donor spec**,
not a donor-faithful value. Existing 2..8-player maps are unchanged (the
original eight start slots keep their exact order and RNG stream).

Status legend: **wired** = affects the sim; **approximated** = UI value resolves
to the nearest port behaviour; **UI only** = exposed + emitted + persisted in
saved configs, but the sim does not act on it. Nothing here is faked.

| Option | Donor values | Status | Port behaviour / note |
|---|---|---|---|
| Players / roster | 2..8 slots (donor); **2..12 in this port — PORT EXTENSION**; columns Player/Nation/Team/AI/Color | wired | Full-screen skirmish: left column = Players picker + column headers + up to 12 rows, right column = donor options. Per-slot nation (all 21), team `-`/1..4, AI difficulty dropdown; P1 defaults human. Original eight start slots/colours unchanged; slots 9..12 are port-extension anchors/colours. Layout of donor widget list inferred; information is verified. |
| Team preset + per-slot team | Free for all / 2 / 3 / 4 teams; per-slot `-`..`4` | wired | Preset distributes team ids evenly, individual rows can override. `team < 0` = FFA (never an alliance). |
| AI difficulty per player | None / Normal / Hard / Very Hard / Impossible | wired (partial) | `None` = human; other values set `is_ai`. Very Hard / Impossible map to the sim's `hard` global tier; per-slot tiers are recorded in `Data.PLAYER_AI_DIFFICULTY`, the AI brains still use one global `AI_DIFFICULTY`. |
| Season | (donor season list) Summer / Desert / Winter | wired | `Data.BIOME`, terrain tint. |
| Map shape / Map Shape | Land, Mediterranean, Peninsulas, Islands, Several Continents, Single Continent, Coastal, Lakes, Rivers, Random | approximated | Generator mask families are only land/mediterranean/peninsulas/islands/continents/continent. Several Continents→continents, Single Continent→continent, Coastal→mediterranean, Lakes→islands, Rivers→peninsulas. `Random` resolves from the map seed to a real mask family. Donor exact masks are not reproduced. |
| Relief / Terrain Type | Plain, Low Mountains, High Mountains, Highlands, Plateaus, Random | approximated | Sim relief tiers are plains/hills/mountains. Low Mountains/Highlands→hills, High Mountains/Plateaus→mountains. `Random` is seed-resolved. |
| Starting resources | Normal, Rich, Thousands, Millions, Random | wired | Scales the config's base `START_RESOURCES` by 1/4/25/1000; `Random` seed-resolves the tier. |
| Minerals | Poor, Medium, Rich, Random | wired | `Random` seed-resolves to low/med/rich; richness drives ore nodes and mine clusters. |
| Map size | Tiny, Normal, Large 2x, Huge 4x | wired (labels) | Port metric mapping is an inference: 240 / 320 / 400 / 480 tiles. |
| Starting units | donor Start Options | wired | `Data.START_OPTION` (army/tower/cannon preset). |
| Difficulty | Easy / Normal / Hard | wired | `Data.AI_DIFFICULTY`. |
| Balloon | Default / No Balloons / Balloons | UI only | Port has no balloon unit/visibility system. Emitted + persisted in `Data.BALLOON_MODE`. |
| Cannons | Default / No Cannons Towers Walls / Expensive Cannons | wired (partial) | `No Cannons Towers Walls` refuses artillery training. `Expensive Cannons` is emitted/persisted but cost scaling is not implemented. |
| Peace time | No, 10, 20, 30, 40, 50, 60, 90, 120, 180, 240 min | wired | Block victory awards before `PEACE_TIME` seconds; combat is unchanged. |
| 18th century | Default / Never / Immediately | UI only | Port roster has 18c variants selected by nation, no global century switch. |
| Capture | Default / No Capturing Peasants / No Peasants or Centres / Artillery Only | wired | Gates peasant conversion, centre capture and which units may capture buildings. |
| Dip.center & market | Default / Without dip.center / Without market / Without both | UI only | Building spawning is mapgen-owned; no per-building suppression yet. |
| Pop limit | Without limitation / 25 / 50 / 100 / 200 / 500 units | wired | `train_unit` refuses new units at the cap (0 = unlimited). |
| Adviser | Default / With / Without | UI only | HUD is another lane; `Data.ADVISER_MODE` recorded only. |
| Autosave | Off / On / Every 5 min (labels unverified — English guesses) | wired (partial) | Main's `_process` saves to `user://quicksave.json` every 600 s (`On`) or 300 s (`Every 5 min`). Donor labels were not readable. |
| Allies | Default / Nearby | UI only | Donor start-placement hint; port start placement is mapgen-owned. |
| Teams (legacy key) | `ffa` / preset id | wired | Kept as legacy alias; per-slot teams and `players` are authoritative. |

## Out of scope donor dropdowns

Start Options beyond the port's six `START_OPTIONS`, plus donor-only controls
not present in the verified list above (e.g. extra market/diplomacy toggles),
are intentionally not added. They are not claimed as supported.

## Verification

`python app/tools/godot_runner.py run --id t-menu-roster --timeout 100 -- \
    --headless --path app --script res://tests/t_menu_roster.gd`
checks the roster mapping, team/AI flags, FFA, the 10-player cfg (4-team cycle,
10-entry AI array, 10 start slots), `MAX_PLAYERS=12` / 12 start anchors, legacy
path, seeded `Random` values, preset math, the full-screen two-column layout
with 12 roster rows + 5 donor column headers, the 12-colour palettes and the
emitted donor key set.

The 12-player extension is already documented above (intro + Players / roster
row): `MAX_PLAYERS=12`, 12 start anchors and 12-colour palettes are covered by
`t_menu_roster` (30/30 PASS).

Minimap HUD palette: `hud.gd MM_PLAYER_COLORS` (another lane's file) now has
**12 bright entries** (T-HUD-12, extended 8 → 12), so ids 0..11 are all distinct
on minimap blips — no neutral-tint fallback. World/roster colours are distinct
for all 12 slots.
