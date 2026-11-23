---
title: REPORT — Donor skirmish menu research + menu overhaul
area: skirmish / menu / donor-research
owner: T-DOCS-4
updated: 2026-11-23
status: green-donor / amber-port
---

# REPORT — Donor skirmish menu research + menu overhaul

> [!IMPORTANT]
> One-stop record of **what the donor's skirmish lobby actually contains** and
> **what the Godot port now does about it**. Donor facts were re-read from the
> installed game at `C:\Games\Cossacks 3\` on 2026-11-23 — nothing here is
> copied from memory. Port facts were read from the working-tree scripts and
> from the committed test-result JSON. Every row carries evidence.

## 1. TL;DR / verdict

- **Donor spec is VERIFIED**: the lobby is a per-player list with columns
  **Player / Nation / Team / Color**, per-player **AI difficulty**, **2–8
  usable slots**, **4 team values + FFA**, and a fixed set of global map and
  "additional settings" dropdowns.
- **Port overhaul has LANDED in the working tree** (uncommitted at report time:
  `M app/scripts/menu.gd`, `main.gd`, `data.gd`, `config.gd`, `game.gd`,
  `world.gd`; `?? app/tests/t_menu_roster.gd`). It is **not a UI-only facade**:
  the roster reaches `Data.*` statics, `game.setup_begin`, team/ally logic and
  the game-over screen. `Data.MAX_PLAYERS` is now **12 — a PORT EXTENSION
  beyond the donor's 8 usable slots** — with Players 2..12, a full-screen
  two-column layout (left roster / right options, pinned action bar) and a
  12-colour minimap palette. The headless test result JSON is **30/30 PASS**.
- **Honest limits remain**: the donor's 10 named extra dropdowns (Balloon,
  Cannons, Peace Time, 18th Century, Capture, Dip.center/market, Pop limit,
  Adviser, Game Speed, Autosave) are **not implemented**; `allies` and
  `start_resources` are **emitted but unconsumed (UI-only)**; Map Shape / Relief
  use **reduced port enums**; and `t_menu_roster` is **not yet registered** in
  `app/tests/manifest.json`.

### Evidence labels used below

| Label | Meaning |
|---|---|
| **VERIFIED** | Read directly from the donor file at the cited `file:line` on 2026-11-23. |
| **INFERRED** | Deduced from verified donor code/data; the donor does not state it in so many words. |
| **UNVERIFIED** | No readable donor evidence; do not treat as donor truth. |
| **PORT-WIRED** | Port code carries the value into simulation state or a consuming system. |
| **PORT-UI-ONLY** | Port code displays or emits the value, but no simulator consumer reads it. |
| **GAP** | Not present in the port. |

---

## 2. Donor spec — lobby layout and per-player controls

Donor root: `C:\Games\Cossacks 3\data\`. All line numbers below are 1-based and
were checked against the files as installed.

### 2.1 Per-player columns and slot count

| Donor fact | Exact evidence | Label |
|---|---|---|
| Columns are **Player / Nation / Team / Color** | `locale\en\gui.txt:405-406` `customgame.text.player` → `Player`; `:407-408` `customgame.text.nation` → `Nation`; `:409-410` `customgame.text.team` → `Team`; `:411-412` `customgame.text.color` → `Color` | **VERIFIED** |
| There is a per-player colour dropdown (`FillComboBoxColors`) | `gui\menu.inc\showcustomgame.inc:129-139` | **VERIFIED** |
| Offline slot loop is `gc_MaxNonSpectatorsCount + 1` (9), with a comment "should be 1 more :(" | `gui\menu.inc\showcustomgame.inc:271-280` (`:278` `maxplayercount := gc_MaxNonSpectatorsCount+1`) | **VERIFIED** |
| `gc_MaxNonSpectatorsCount = 8` (and `gc_MaxPlayerCount = 12` for online) | `scripts\dmscript.global:97-98` | **VERIFIED** |
| Last slot is locked out of the AI dropdown and event changes ("remove for unlimit 8 players") | `gui\menu.inc\showcustomgame.inc:605-607`, `:655-657` | **VERIFIED** |
| ⇒ **8 usable player slots** offline | derived from the three rows above | **VERIFIED** (as an inference from explicit code + comment) |
| Minimum 2 players | No explicit donor constant found; a skirmish needs two sides | **UNVERIFIED / INFERRED** (port clamps to 2) |
| Exact on-screen widget arrangement of the player list | Not expressed in the readable `.inc`/locale text | **UNVERIFIED** (port reproduces the information in compact rows) |

### 2.2 Per-player Team and AI difficulty

| Donor fact | Exact evidence | Label |
|---|---|---|
| Team dropdown entries are exactly `-`, `1`, `2`, `3`, `4` (max 4 teams) | `gui\menu.inc\showcustomgame.inc:117-128` (`GUIListBoxAddItem(elmHnd,'-',0)` at `:123`; loop `for i:=1 to 4` at `:124-125`); creation at `:685-689` | **VERIFIED** |
| Per-player AI difficulty **replaces** a Human/Computer toggle: `None / Normal / Hard / Very Hard / Impossible` | `locale\en\gui.txt:153-154` `difficulty.0`=`None`, `:155-156` `Normal`, `:157-158` `Hard`, `:159-160` `Very Hard`, `:161-162` `Impossible`; loaded by `showcustomgame.inc:73-86`, `gc_MaxAIDifficultyCount = 4` at `scripts\dmscript.global:235` | **VERIFIED** |
| "None" means a human-controlled slot | Donor lists it as the zero-th difficulty, before the AI tiers | **INFERRED** |
| Port has no separate Human/Computer toggle; per-player AI difficulty **is** the control | port choice, not donor text | **UNVERIFIED** (port design decision) |

### 2.3 Global map options

| Donor control | Donor values | Exact evidence | Label |
|---|---|---|---|
| **Map Size** | 4: `Tiny`, `Normal`, `Large 2x`, `Huge 4x` | `gui\menu.inc\showcustomgame.inc:233-249` (`:243-246` adds 4 items with ids 3/0/1/2); labels `locale\needloc\new.txt:347-348` `map.size.tiny`=`Tiny`, `:45-46` `Normal`, `:47-48` `Large 2x`, `:49-50` `Huge 4x` | **VERIFIED** |
| **Map Shape / Terrain Type** | 9 named shapes **+ Random** (10 entries) | `gc_MaxTerrainTypeCount = 9` at `scripts\dmscript.global:236`; loop `0..gc_MaxTerrainTypeCount-1` at `showcustomgame.inc:146-154`; extra `text.random` at `:155` | **VERIFIED** |
| **Relief / Terrain Type** | 5 named reliefs **+ Random** = 6 entries | `gc_MaxReliefTypeCount = 6-1` at `scripts\dmscript.global:238`; loop at `showcustomgame.inc:164-168`; extra Random at `:169` | **VERIFIED** |
| **Starting Resources** | 4 named levels **+ Random** = 5 entries | `gc_MaxResourcesCount = 4` at `scripts\dmscript.global:239`; loop at `showcustomgame.inc:210-214`; extra Random at `:215` | **VERIFIED** |
| **Minerals / Resource mines** | 3 named levels **+ Random** = 4 entries | `gc_MaxResourceMinesCount = 3` at `scripts\dmscript.global:240`; loop at `showcustomgame.inc:224-228`; extra Random at `:229` | **VERIFIED** |
| **Season** | 3 base seasons (`Summer/Winter/Desert`) **+ Random**; Winter/Desert conditional on profile DLC flags | `gc_MaxSeasonCount = 3` at `scripts\dmscript.global:237`; loop/skip rules at `showcustomgame.inc:178-199`; extra Random at `:201` | **VERIFIED**; DLC gating at `:190-193` |
| **Allies** | `Default` / `Nearby` (maps to `additional.teams`) | `locale\en\gui.txt:849-853` `randommap.settings.teams`=`Allies`, `default`, `nearby`; value mapping `showcustomgame.inc:929-931`; serialized `miscext2.script:2379` | **VERIFIED** |

### 2.4 Extra donor dropdowns (the "additional settings" block)

The full serialized game-settings struct in `scripts\lib\miscext2.script`
(producer `:2364-2383`, consumer `:2626-2643`) is, in wire order:

```
gen.season, gen.terraintype, gen.relieftype, gen.resourcestart,
gen.resourcemines, gen.mapsize,
additional.startingunits,
additional.balloon, additional.cannons, additional.peacetime,
additional.century18, additional.capture, additional.marketdip,
additional.teams, additional.autosave, additional.limit,
additional.gamespeed, additional.adviserassistant
```

| Dropdown | Donor labels / values | Exact evidence | Label |
|---|---|---|---|
| Balloon Options | `Default` / `No Balloons` / `Balloons` | `locale\en\gui.txt:537-543`; enum use `showcustomgame.inc:876-879`; count at `:1024-1025` | **VERIFIED** |
| Cannons | `Default` / `No Cannons, Towers and Walls` / `Expensive Cannons` | `gui.txt:545-551`; `showcustomgame.inc:883-886`, `:1028-1029` | **VERIFIED** |
| Peace Time | `No Peace Time` / `10` / `15` / `20` / `30` / `45` / `60` / `90` / `120` / `180` / `240` min | `gui.txt:553-575`; `showcustomgame.inc:890-901`, count at `:1032-1033` | **VERIFIED** |
| 18th Century Options | `Default` / `Never` / `Immediately` | `gui.txt:577-583`; `showcustomgame.inc:905-908`, `:1036-1037` | **VERIFIED** |
| Capture | `Default` / `No Capturing Peasants` / `No Capturing Peasants or Centres` / `Artillery Only` | `gui.txt:585-593`; `showcustomgame.inc:912-916`, `:1040-1041` | **VERIFIED** |
| Dip. center and market (`marketdip`) | `Default` / `Without dip. center` / `Without market` / `Without both` / `Expensive mercenaries` | `gui.txt:839-849`; `showcustomgame.inc:920-925`, `:1044-1045` | **VERIFIED** |
| Pop limit (`limit`) | `Without limitation` / `%value% units` | `gui.txt:871-875`; label id `showcustomgame.inc:851`, value case `:936`, option count `:1051-1053` | **VERIFIED** |
| Adviser Assistant | `Default` / `With adviser` / `Without adviser` | `gui.txt:863-869`; `showcustomgame.inc:957-959`; DLC gate at `:46`, force-off at `:756-757` | **VERIFIED** |
| Game Speed | `CFG.VALUE.GAMESPEED` family | `showcustomgame.inc:852`, `:949`, `:984`, count `:1055-1060`; serialized `miscext2.script:2382`, `:2642` | **VERIFIED** (label family; individual ticks in locale) |
| Autosave | serialized as additional.autosave | `miscext2.script:2380`, `:2640`; **absent** from the 0..10 additional-options label case at `showcustomgame.inc:842-854` | **VERIFIED** (field); labels **UNVERIFIED** |
| Starting units (13th struct field) | `default` / `armysmall` / `armymedium` / `armylarge` / `peasantslot` / `differentnations` / `towers` / `cannons` / `cannonsandhowitzers` / `barrack18` / `barrack17` / `village` / `logcabins` / `union` | `showcustomgame.inc:843` (label id), `:858-872` (value cases), count `:1020-1021`; serialized `miscext2.script:2372`, `:2632` | **VERIFIED** |

### 2.5 Roster/nation constants

- `gc_MaxCountryCount = 24`, `gc_MaxCountryCountRelease = 13` —
  `scripts\dmscript.global:119-120` — **VERIFIED**. (The port's playable
  nation table has 21 sids including `sco`; `app/scripts/data.gd:222-234`.)
- Donor nation list is filled by `FillComboBoxCountries` —
  `showcustomgame.inc:87` — **VERIFIED**; exact per-slot id mapping is beyond
  the readable `.inc` — **UNVERIFIED**.

---

## 3. Port — before / after (what actually landed)

Working-tree state at report time: the overhaul is present but **uncommitted**.
This section describes code as read, not a released commit.

### 3.1 `app/scripts/menu.gd`

| | Before | After |
|---|---|---|
| Player pick | "Your nation" / "Enemy nation" / "Opponents" 1–3 / "Teams" `ffa`\|`2v1` | "Players" 2–12 (PORT EXTENSION; donor max 8) + "Team preset" `ffa`\|`2`\|`3`\|`4`, followed by `P1..Pn` rows rebuilt on change (`menu.gd:495-510`, `:432-451`) |
| Per-player state | none | parallel arrays `roster_nations`, `roster_teams`, `roster_ai`, `roster_names`, `roster_difficulty` (`menu.gd:28-37`) |
| Per-player row | n/a | Nation (all 21 port nations), Team (`-`,1,2,3,4 → `-1`,0,1,2,3), AI difficulty (5 donor labels), read-only Color swatch (`menu.gd:453-483`) |
| Map Size row | raw `240/320/400` | donor labels `Tiny/Normal/Large 2x/Huge 4x` with ids `240/320/400/480` (`menu.gd:529-532`) |
| Minerals | 3 options | 4 options, adds donor `Random` (`menu.gd:518`) |
| Starting resources / Allies | absent | two new rows (`menu.gd:519-524`) |
| `cfg` emitted | legacy keys only | legacy keys **plus** `players` roster, `allies`, `start_resources` (`menu.gd:697-719`) |
| Difficulty mapping | single global | donor ids retained in `ai_difficulty`, collapsed to sim `easy/normal/hard` in `difficulty` (`menu.gd:334-340`, `:485-493`) |
| Layout | narrow dialog | full-screen two-column skirmish view: left = players picker + column headers + roster rows, right = donor options, with a pinned action bar at the bottom (`ui_fullscreen_layout` PASS) |

Team preset math: `k` teams spread evenly (`int(i*k/players)`), so 4 players /
2 teams → `[0,0,1,1]` (`menu.gd:424-429`). FFA stores team `-1`.

### 3.2 `app/scripts/data.gd`

- `const MAX_PLAYERS := 12` (was 8; **PORT EXTENSION beyond the donor's 8 usable slots**) and the single shared cap used by menu/main/config/game (`data.gd:176-179`).
- Added `PLAYER_AI: Array` and `PLAYER_AI_DIFFICULTY: Array` statics (`data.gd:181-188`); empty array deliberately means "legacy fallback".
- `MAP_TYPES` still has **6** shapes (`data.gd:270-277`); `RELIEF_SCALE` still has **3** reliefs (`data.gd:206`).

### 3.3 `app/scripts/main.gd`

- `_apply_menu_cfg` now branches on a non-empty `cfg["players"]` array: `_apply_roster_cfg` is authoritative, else `_apply_legacy_roster_cfg` keeps old callers byte-stable (`main.gd:213-224`, `:253-303`).
- Roster mapping writes `PLAYER_COUNT`, `PLAYER_NATIONS`, `PLAYER_NAMES`, `TEAMS`, `PLAYER_AI`, `PLAYER_AI_DIFFICULTY` (`main.gd:256-282`). Team `-1` default preserved for FFA.
- Minerals `random` resolves deterministically from the map seed via a local `RandomNumberGenerator` (`main.gd:233-240`) — verified by test.
- `allies` / `start_resources` are explicitly documented as **unconsumed** (`main.gd:227-229`).
- Game-over scoreboard now iterates `game.players.size()` instead of hard-coded `2` (`main.gd:837`).

### 3.4 `app/scripts/config.gd`

- Saved configs may carry `gameplay.player_nations`, `player_ai`, `player_ai_difficulty` alongside legacy `nation0`/`nation1` (`config.gd:405-438`); caps use `Data.MAX_PLAYERS`.
- NOTE: `gameplay.start_resources` here is an **economy stock dict** (`config.gd:58`, `:389`), a different concept from the menu's donor "Starting Resources" enum. Do not conflate them.

### 3.5 `app/scripts/game.gd`

- `new_player()` gives every player an explicit `"team": -1` key (`game.gd:272-280`).
- `setup_begin()` clamps to `Data.MAX_PLAYERS`, reads per-slot AI from `Data.PLAYER_AI` with the old `i > 0` rule only as fallback (`game.gd:360-374`).
- `_is_ally()` treats negative team ids as FFA — two `-1` slots are **never** allies (`game.gd:2646-2661`).
- `MINE_MIN_SEP_TILES`/`_ore_spot_clear` changes also in this file belong to the **T-MINES-FIX** lane, not the menu overhaul; they are not credited here.

### 3.6 `app/scripts/world.gd`

- Known crash fixed: `_player_color(p)` used a 2-element literal and went
  out-of-bounds at `p >= 2`. Now a 12-entry `PLAYER_COLORS` constant with a
  `wrapi()` modulo fallback (`world.gd:1872-1887`). Palette mirrors the
  **12 bright colours** in the `hud.gd` minimap palette (`MM_PLAYER_COLORS`,
  also extended 8 → 12); that lane owns the palette.

### 3.7 `app/tests/t_menu_roster.gd`

- Headless, self-exiting test through the real `_apply_menu_cfg` path, now
  **30/30 PASS**: 6- and 10-player rosters plus `MAX_PLAYERS=12` / 12 start
  anchors, count/teams/AI flags/nations/per-slot difficulty, built sim players,
  FFA non-alliance, legacy path, seeded `random` minerals, team-preset math,
  donor options, the full-screen two-column layout, 12-colour palettes,
  UI row rebuild to 12 + emitted cfg, and the `_player_color` OOB case
  (`t_menu_roster.gd:44-164`).

---

## 4. Per-option status matrix

| Donor option | Port UI | Port consuming code | Verdict |
|---|---|---|---|
| Player / Nation columns (2–12 slots; donor 2–8) | "Players" + per-slot Nation | `Data.PLAYER_NATIONS`, `game.setup_begin` | **PORT-WIRED** (12 = PORT EXTENSION) |
| Team column (`-`,1,2,3,4) + Team preset | per-slot Team + preset rows | `Data.TEAMS`, `new_player.team`, `_is_ally` | **PORT-WIRED** |
| Color column | read-only swatch (12 colours; minimap palette also 12) | `world._player_color` palette, no gameplay effect | **PORT-UI-ONLY** (by design) |
| Per-player AI difficulty (5 tiers) | 5 donor labels | `roster_ai` → `Data.PLAYER_AI`; tiers collapsed to `easy/normal/hard`, donor id kept in `Data.PLAYER_AI_DIFFICULTY` | **PORT-WIRED** (tiers **not** distinct in sim) |
| Map Size (Tiny/Normal/Large 2x/Huge 4x) | donor labels | `map_size` → `Data.MAP_W/H` | **PORT-WIRED**; tile mapping 240/320/400/480 is **INFERRED** |
| Map Shape (9 + Random) | 6 port shapes from `Data.MAP_TYPES` | `terrain_type` → `Data.MAP_TYPE` → generator | **GAP** (3+ shapes and Random unsupported) |
| Relief (6) | 3 port reliefs | `relief` → `Data.RELIEF` → `RELIEF_SCALE` | **GAP** (Low/High Mountains, Highlands, Plateaus, Random) |
| Starting Resources (5) | row present, 5 donor labels | `cfg.start_resources` emitted; **no reader** | **PORT-UI-ONLY** (documented gap) |
| Minerals (4, incl. Random) | 4 labels | `richness` → seed-resolved → `Data.RICHNESS` | **PORT-WIRED** |
| Season (3) | 3 labels | `season` → `Data.BIOME` → terrain tint | **PORT-WIRED** (no donor Random option in port row) |
| Allies (Default/Nearby) | row present | `cfg.allies` emitted; **no reader** (start placement not implemented) | **PORT-UI-ONLY** (documented gap) |
| Starting units | derived from `Data.START_OPTION` row | `game.gd:2448-2467` | **PARTIAL** (no donor dropdown for its 14 values) |
| Balloon Options | none | none | **GAP** |
| Cannons (3) | none | none | **GAP** |
| Peace Time (11) | none | none | **GAP** |
| 18th Century (3) | none | none | **GAP** (separate 18c transition from START_OPTIONS exists) |
| Capture (4) | none | none | **GAP** (game capture mechanics exist but no lobby selector) |
| Dip. center and market (5) | none | none | **GAP** |
| Pop limit | none | none | **GAP** |
| Adviser Assistant | none | none | **GAP** (game.gd:2223 notes adviser path deferred) |
| Game Speed | none | none | **GAP** |
| Autosave | none | save slots exist but no setting | **GAP** |
| Nation cap 24 / Release 13 | port uses 21 sids | `Data.NATIONS` | **GAP** (roster size differs; deferred by P-24) |

---

## 5. Data shape

### 5.1 Menu → `cfg` (skirmish only)

```gdscript
{
  "mode": "skirmish",
  "players": [                         # only for mode == "skirmish"
    {
      "nation": "rus", "team": -1,     # -1 = free for all; 0..3 = team id
      "ai": false, "name": "Russia",
      "ai_difficulty": "none",         # donor id: none|normal|hard|veryhard|impossible
      "difficulty": "none"             # sim tier: none|easy|normal|hard
    }, ...
  ],
  "nation0": "rus", "nation1": "bav",  # legacy mirrors of players[0..1]
  "opponents": 1, "teams": "ffa",      # legacy mirrors (players.size()-1, team_preset)
  "terrain_type": "land", "map_type": "land",
  "richness": "med", "season": "summer", "relief": "plains",
  "start_option": "default", "difficulty": "normal",
  "map_size": 320, "seed": 12345,
  "allies": "default", "start_resources": "normal"   # emitted, not consumed
}
```

Historical battles and campaigns deliberately **omit** `players` and stay on
the legacy path (`menu.gd:707-718`).

### 5.2 `Data.*` statics after `_apply_roster_cfg`

`PLAYER_COUNT` (2..12; PORT EXTENSION) · `PLAYER_NATIONS: Array[String]` ·
`PLAYER_NAMES: Array[String]` · `TEAMS: Array[int]` (`-1` or `0..3`) ·
`PLAYER_AI: Array[bool]` · `PLAYER_AI_DIFFICULTY: Array[String]` (`easy/normal/hard`).

Legacy configs (no `players`) leave `PLAYER_AI` and `PLAYER_AI_DIFFICULTY`
**empty**, which `game.setup_begin` interprets as "slot 0 human, rest AI".

### 5.3 Team encoding

Donor UI label `-` → stored `-1` → FFA. Donor labels `1..4` → stored `0..3`.
`_is_ally` requires both slots to have a **non-negative** matching team; two
FFA slots are never allies. This is why `ffa_not_allied` is a test check.

---

## 6. Verification

| Check | Evidence | Result |
|---|---|---|
| 6- and 10-player rosters through real `_apply_menu_cfg` | `app/tests/results/t_menu_roster.json` checks `player_count`, `teams`, `ai_flags`, `nations`, `per_slot_difficulty`, `ten_player_*` | PASS |
| `MAX_PLAYERS=12`, 12 start anchors, 12-slot players picker | same JSON, `max_players_cap`, `start_positions_12`, `player_items_12` | PASS |
| Full-screen two-column layout + 12-colour palettes | same JSON, `ui_fullscreen_layout`, `ui_roster_columns`, `player_colors_12` | PASS |
| Sim builds 6 players with matching teams/AI | same JSON, `sim_players` | PASS |
| FFA (`team=-1`) creates 0 ally pairs | same JSON, `ffa_not_allied` | PASS |
| Legacy 1–3 opponents path unchanged | same JSON, `legacy_path` (`PLAYER_COUNT=3`, `TEAMS=[0,0,1]`, `PLAYER_AI=[]`) | PASS |
| Donor `Random` minerals deterministic for seed 777 | same JSON, `random_richness` (`rich` / `rich`) | PASS |
| Team preset 4 players / 2 teams → `[0,0,1,1]` | same JSON, `team_preset` | PASS |
| UI builds 2 rows, rebuilds to 12, emits full roster | same JSON, `ui_roster_rows_12`, `ui_emit_roster` | PASS |
| `_player_color(5)` and `(8)` no longer OOB, distinct | same JSON, `player_color_oob` | PASS |
| Result file total | `"passed": true`, 30 checks, `unix_ms` 1795449904441 (2026-11-23) | **30/30 PASS** |

Reproduce (single-door runner, per project rule):

```powershell
python app\tools\godot_runner.py run --id t-menu-roster --timeout 100 -- `
  --headless --path app --script res://tests/t_menu_roster.gd
```

Scope of verification: **headless code paths only**. No screenshot or manual
click-through of the rebuilt menu rows was performed for this report; widget
layout fidelity to the donor is **UNVERIFIED**.

---

## 7. Open gaps / next actions

1. **Register the test.** `t_menu_roster` is absent from
   `app/tests/manifest.json`; add it as `status: ready` so `test_all.py` picks
   it up and it stops being a one-off JSON.
2. **Commit or hand off the working-tree changes.** The overhaul is verified in
   the working tree, not in a commit. Until committed, a clean checkout does
   not contain it (cf. standing P-38 clean-checkout concern).
3. **Decide the 10 additional-settings dropdowns.** None are wired. Cheapest
   wins are likely Balloon / Cannons / Peace Time / 18th Century, which map to
   existing `START_OPTIONS`/tech concepts; Pop limit, Game Speed, Autosave and
   Adviser need new sim state.
4. **Consume `allies` and `start_resources`.** Both are emitted and ignored.
   `allies` needs a start-placement hint; `start_resources` needs a per-slot
   starting-stock multiplier (do **not** reuse the economy dict in
   `config.gd:389`).
5. **Map Shape / Relief coverage.** Port supports 6 of 10 shape options and 3
   of 6 relief options. Adding `Random` to Season and the missing relief
   values is a generator change, not a menu-only change.
6. **Per-slot difficulty fidelity.** `veryhard` and `impossible` collapse to
   `hard` in the sim; the donor id survives in config only. Decide whether to
   implement real tier behaviour or label the limitation in the UI.
7. **Nation roster size.** Donor `gc_MaxCountryCount = 24` (Release 13) vs 21
   port sids; tied to P-24. Do not silently widen the dropdown beyond what the
   sim can field.
8. **Layout fidelity.** The per-player row arrangement is an inference, not a
   donor byte match. A screenshot comparison is still owed.
9. **Removed/legacy callers.** Confirm `uitest`/`selftest`/saved loads still
   pass after the roster branch; `legacy_path` covers the mapping, not the full
   gates.

---

## 8. Evidence index

**Donor (read 2026-11-23, root `C:\Games\Cossacks 3\data\`):**

- `locale\en\gui.txt:153-162` (AI difficulty), `:405-412` (Player/Nation/Team/Color), `:523-593` (additional-setting labels), `:839-875` (marketdip/teams/adviser/limit labels).
- `locale\needloc\new.txt:45-50`, `:347-348` (Map Size labels).
- `gui\menu.inc\showcustomgame.inc:73-86` (AI fill), `:87` (nations), `:117-128` + `:685-689` (teams), `:129` (colours), `:141-232` (shape/relief/season/resources/minerals/size fills), `:233-249` (map size), `:271-280` + `:605-607` + `:655-657` (slots), `:842-872` + `:876-959` (additional-setting label/value maps), `:1018-1063` (option counts).
- `scripts\dmscript.global:97-98` (player caps), `:119-120` (country caps), `:235-240` (option counts).
- `scripts\lib\miscext2.script:2364-2383` (settings serialize), `:2626-2643` (deserialize).

**Port (working tree, 2026-11-23):**

- `app/scripts/menu.gd:28-59`, `:292-493`, `:495-556`, `:697-719`.
- `app/scripts/main.gd:213-303`, `:837`.
- `app/scripts/data.gd:176-188`, `:206`, `:222-234`, `:270-277`.
- `app/scripts/config.gd:58`, `:389`, `:405-438`.
- `app/scripts/game.gd:272-280`, `:360-374`, `:2448-2467`, `:2646-2661`.
- `app/scripts/world.gd:1872-1887`.
- `app/tests/t_menu_roster.gd:1-164`; `app/tests/results/t_menu_roster.json`.
- Related status context: `docs/STATUS_SKIRMISH.md` §4 (P-14/P-18/P-19/P-42), `docs/research/RC_TERRAIN.md` §2.1.

---

**Related:** [docs/STATUS_SKIRMISH.md](STATUS_SKIRMISH.md) ·
[docs/research/RC_TERRAIN.md](research/RC_TERRAIN.md) ·
[docs/STATUS_TESTS.md](STATUS_TESTS.md)
