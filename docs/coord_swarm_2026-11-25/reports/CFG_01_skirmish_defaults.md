---
id: CFG-01
owner: CFG-01 subagent (small-feature builder)
date: 2026-11-25
status: complete-with-open-dependency
---

# CFG-01 — 3D variant default skirmish setup

## Goal

Change `variant3d/`'s default skirmish setup to **Russia vs Bavaria**, a **smaller map**, a **Mediterranean-with-hills** style map, and **no fog of war** — using only existing, donor/engine-valid keys and minimal value-only diffs.

## Current defaults observed (before edits)

| Setting | `config.gd` built-in DEFAULT | `menu.gd` (interactive skirmish) | `data.gd` statics | Runtime overlay |
| --- | --- | --- | --- | --- |
| Player 0 nation | `ukr` (`variant3d/scripts/config.gd:75`) | `rus` (`variant3d/scripts/menu.gd:21`) | `PLAYER_NATIONS = ["rus","bav",…]` (`data.gd:177`) | `rus` (`variant3d/config.json:71`) |
| Player 1 nation | `rus` (`config.gd:76`) | `bav` (`menu.gd:22`) | — | `bav` (`config.json:72`) |
| Map size (tiles) | 320×320 (`config.gd:72-73`) | 320 (`menu.gd:60`) | 160×160 (`data.gd:33-34`) | 320×320 (`config.json:41-42`) |
| Map shape / climate | `land` (`config.gd:77`, `:79`) | `land` (`menu.gd:55`, `:64`) | `MAP_TYPE = "land"` (`data.gd:198`) | `land` (`config.json:73`) |
| Relief | `plains` (`config.gd:82`) | `plain` (donor id, `menu.gd:67`) | `RELIEF = "plains"` (`data.gd:204`) | not present in `config.json` |
| Fog of war | `false` (`config.gd:51`, applied `:380`) | no fog key in menu | `FOG_OF_WAR = false` (`data.gd:55`) | `false` (`config.json:22`) |

So: **Russia vs Bavaria was already the interactive menu / config.json default**, and **fog of war was already off everywhere**. Those parts were left unchanged, as instructed ("if it's not already like that"). The 2D `app/` equivalents were read for orientation only and are unchanged (`app/scripts/config.gd:51,72-82`, `app/scripts/data.gd:33,55,194,200`, `app/scripts/menu.gd:21-22,55,60,64,67` — same pre-change values).

## Valid value tables (discovered, not invented)

### Nations — `variant3d/scripts/data.gd:231-243` (`NATIONS`, from `country.script`)

| Requested | Exact key | Evidence |
| --- | --- | --- |
| Russia | `rus` | `data.gd:234` → `{"name": "Russia"}` |
| Bavaria | `bav` | `data.gd:240` → `{"name": "Bavaria"}` |

Both exist; no key was invented. `bav` is also slot 1 of `PLAYER_NATIONS` (`data.gd:177`).

### Map sizes

| Source | Allowed values | Smallest sensible skirmish size |
| --- | --- | --- |
| Port skirmish dropdown | `240` Tiny, `320` Normal, `400` Large 2x, `480` Huge 4x — `menu.gd:696-699` | **240 (Tiny)** — chosen |
| Port option mapping doc | 240 / 320 / 400 / 480 tiles (explicitly an *inference*) — `docs/DONOR_OPTIONS_GAPS.md:34` | 240 |
| Donor `miscext2.script:19-26,45` | `mapsize` 0/1/2/3/else → 320/480/640/**256**/320 — `docs/coord_swarm_2026-11-24/reports/TERRAIN2_01_donor_pipeline.md:35` | literal donor Tiny = 256 |
| Community research | Tiny 256, Normal 320, Medium 400, Large 480, Very large 560, Huge 640 — `docs/research/RC_TERRAIN.md:59` | 256 |
| Engine clamp | `maxi(16, …)` — `config.gd:405-406` before edit (now `:407-408`) | 16 = floor only, not gameplay-valid |
| Test fixtures only | 64 (`tests/fixtures/small_map_64.json:13`), 128 (`small_map_128.json:13`) | explicitly NOT used as gameplay default |

**Decision:** 240. It is the smallest *selectable port skirmish size* and keeps the lobby dropdown coherent (`menu.gd:699` lists 240, not 256). The donor's literal Tiny is 256; 256 is not an option in the port's skirmish UI, so adding it would have meant changing the option table (more than a default-value edit). Limitation recorded below.

### Map type / climate and relief

| Kind | Existing keys | Evidence |
| --- | --- | --- |
| Map shape (generator family) | `land`, **`mediterranean`**, `peninsulas`, `islands`, `continents`, `continent` | `data.gd:279-286` (`MAP_TYPES`, from `generator.cfg TerrainTypes`); donor shape table `data.gd:299-310`, with `coastal → mediterranean` at `:306` |
| Relief (donor ids used by menu) | `plain`, **`low_mountains`**, `high_mountains`, `highlands`, `plateaus`, `random` | `data.gd:315-322` (`DONOR_RELIEF`); `low_mountains → hills` at `:317`, `highlands → hills` at `:319`, `high_mountains → mountains` at `:318` |
| Relief (sim tiers used by config) | `plains`, **`hills`**, `mountains` | `data.gd:204`, `:215`; resolved by `main.gd:302-315` |

**Decision:** `mediterranean` + `low_mountains` (menu) / `hills` (config). This is the closest existing coastal-with-gentle-relief combination; no new "mediterranean_hills" key was invented.

### Fog of war

| Key | Location | Value |
| --- | --- | --- |
| `display.fog_of_war` | `config.gd:51` (default), `:382` (apply), `config.json:22` | `false` |
| `Data.FOG_OF_WAR` | `data.gd:55` | `false` |
| Consumer | `world3d_fog.gd:213,234,317`, `world.gd:345,2259,2267`, `hud.gd:1552,1582` | overlay hidden when false |
| Menu | no fog key anywhere in `menu.gd` | nothing to set |

**Decision:** no fog mechanic was added and no value was changed — "no fog of war" was already the default on every path.

## Changes made (before → after)

All edits are value-only; comments explaining existing values were preserved.

`variant3d/scripts/menu.gd` (interactive skirmish defaults):
- `:55` `var map_type := "land"` → `"mediterranean"`
- `:60` `var map_size := 320` → `240` (short CFG-01 comment added)
- `:64` `var terrain_type := "land"` → `"mediterranean"`
- `:67` `var relief := "plain"` → `"low_mountains"` (existing comment kept, mapping note appended)
- `:21-22` `nation0/nation1` left as `rus`/`bav` — already correct.

`variant3d/scripts/config.gd` (built-in defaults and their apply() fallbacks):
- `:72-73` 320 → 240; `:75-76` `ukr`/`rus` → `rus`/`bav`
- `:77`, `:79` `land` → `mediterranean`; `:82` `plains` → `hills`
- `:217` `player` names `["Ukraine","Russia"]` → `["Russia","Bavaria"]` (keeps display names consistent with the new nation pair)
- `:407-408`, `:429`, `:432`, `:434-435`, `:471-472`, `:555` — matching fallback literals updated so a config constructed without the gameplay section gets the same defaults
- `:51`, `:382` fog left at `false` — already correct.

`variant3d/scripts/data.gd`: **unchanged**. Fog is already off (`data.gd:55`), nations are already `rus`/`bav` (`data.gd:177`), and its `MAP_W = 160` (`data.gd:33`) is already smaller than 320. `MAP_TYPE`/`RELIEF` there are documented donor-baseline values ("the ones from the original game", `data.gd:28-31`) that config/menu always override; changing them would misstate donor truth rather than change the skirmish default.

## Backups created

- `inbox/backup/config.gd.bak-CFG01` (27,315 bytes, original)
- `inbox/backup/menu.gd.bak-CFG01` (38,692 bytes, original)

`data.gd` was not changed, so no backup was taken.

## Validation

| Check | Result |
| --- | --- |
| `python variant3d\tools\godot_runner.py run --id cfg01-selftest --timeout 300 -- --headless --path variant3d -- --self-test variant3d/selftest.json` | ticket 312, runner END **ok** (191.18 s); `variant3d/selftest.json` → `passed: true`, 29 steps |
| `python variant3d\tools\godot_runner.py run --id cfg01-uitest --timeout 240 -- --headless --path variant3d -- --ui-test variant3d/uitest.json` | ticket 313, runner END **ok** (216.23 s); `variant3d/uitest.json` → `passed: true`, 17 steps |
| `python variant3d\tools\assert_clean.py --json` | `clean: true`, verdict **CLEAN**, 0 processes, lock free, no failures |

No test was edited or weakened; no `godot` binary was invoked directly. My source edits are limited to the two owned scripts (`config.gd`, `menu.gd`); `app/` and all tests/manifests/shaders are untouched, so the 2D shipping gates are unaffected.

Note on a generated artifact: the mandated selftest command writes its result back to `variant3d/selftest.json`, so that tracked output file was regenerated by the runner (all 29 steps still pass). Its numeric details differ from the committed copy — e.g. gold 245.024 → 113.152, shots 73 → 78 — because `config.json` has no `terrain_type`/`relief` keys, so the changed built-in defaults in `config.gd` now select Mediterranean + hills even on the menu-skipping path, which changes map generation. This is runner output, not a hand edit to a test. `variant3d/uitest.json` was regenerated too but its content is byte-identical to the committed copy. Other untracked test files visible in `git status` were added by concurrent swarm agents, not by CFG-01.

## Any part NOT done and why (no invention)

1. **`variant3d/config.json` still hard-codes 320×320 and legacy `map_type: land`** (`:41-42`, `:73`). It is not in my ownership, so I could not edit it. `main.gd:175-177` loads and applies it at startup, so a *menu-skipping / headless* run still gets a 320×320 map (the shape/relief did become Mediterranean + hills through the new `config.gd` fallback, because `config.json` has no `terrain_type`/`relief` key). The interactive skirmish path is fully correct because `menu.gd` emits its own values via `_emit_start()` (`menu.gd:897-914`) and `main.gd:364-367,289-315` applies them. Making the no-menu *map size* consistent needs that file assigned to an owner.
2. **Donor literal Tiny is 256, port dropdown is 240.** I used 240 so the option button shows the actual selected value; I did not add a 256 entry (that would change the option table, not a default).
3. **No single "Mediterranean-with-hills" preset key exists.** I combined the existing `mediterranean` shape with `low_mountains` (sim `hills`); no new climate/relief key or fog flag was invented.
4. **Fog was already off** — nothing to change; no new "no fog" flag was created.

## Open questions

- Should COORD assign `variant3d/config.json` to an owner to change its `map_width_tiles`/`map_height_tiles` (320 → 240) and `map_type` (`land` → `mediterranean`), so `--dump-config` / selftest-style no-menu runs match the interactive skirmish default?
- Confirm that 240 (port Tiny) is preferred over the donor-literal 256; if 256 is required, the dropdown option table in `menu.gd:699` must change too, which is outside a default-value-only edit.
- If a stronger "hills" look is wanted, the alternative existing donor id is `highlands` (`data.gd:319`, also → sim `hills`); `low_mountains` was chosen as the gentler fit for "some hills".

## Summary

Russia vs Bavaria and no fog were already the 3D variant's interactive defaults and were left intact. I changed the remaining skirmish defaults — map size 320 → **240** (Tiny, smallest port option), map shape `land` → **`mediterranean`**, relief `plain`/`plains` → **`low_mountains`/`hills`** — in `menu.gd` and the matching `config.gd` built-in/fallback values, with two backups. Both variant gates and the clean gate pass. The one unresolved dependency is `config.json` (not owned), which still pins the no-menu map to 320×320 (its legacy `map_type: land` is superseded by the new built-in `terrain_type`, so shape/relief are already Mediterranean + hills even there).
