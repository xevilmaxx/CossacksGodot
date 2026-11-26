---
id: X09
wave: X (cross-cutting data decode)
date: 2026-11-26
title: "X09 — `startingsettings.cfg` decoded: 19 start presets, 61 ASCII placement masks, 276 legend entries"
status: LANDED__READ_ONLY__NO_RUNNER__NO_CODE_EDIT
owner_file: docs/terrain_swarm_2026-11-26/reports/X09_starting_settings.md
donor_root: "C:\\Games\\Cossacks 3 (READ ONLY, private use; no donor binary executed, no donor file copied or committed)"
source: "C:\\Games\\Cossacks 3\\data\\game\\var\\startingsettings.cfg (116,920 B, 3,424 lines, CRLF)"
sha256: 17d4aeddaf4496594bda74e5f1fcc4f8ff0e149a5b2a53211c8f1eba200c111f
consumer: "C:\\Games\\Cossacks 3\\data\\scripts\\common.inc\\dogenerate.inc:230-396 (CreateUniqueStartingUnits)"
labels: ["[O] observed", "[D] derived", "[I] inferred", "[U] UNVERIFIED", "PORT APPROXIMATION"]
parity_claim: false
temp_outputs:
  - "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\startsettings_validate\\startsettings_index.json (all 61 masks + legend maps + line ranges)"
  - "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\startsettings_validate\\mask_grammar.json (symbol semantics + placement transform)"
---

# X09 — `startingsettings.cfg` placement masks decoded

## 0. Scope, labels, citation convention

All evidence is **read-only donor text**. Short forms:

| Short form | Full donor path |
|---|---|
| `SS:N` | `C:\Games\Cossacks 3\data\game\var\startingsettings.cfg`, 1-based line `N` |
| `DG:N` | `C:\Games\Cossacks 3\data\scripts\common.inc\dogenerate.inc`, 1-based line `N` |
| `ME:N` | `C:\Games\Cossacks 3\data\scripts\lib\miscext2.script`, 1-based line `N` |
| `DMG:N` | `C:\Games\Cossacks 3\data\scripts\dmscript.global`, 1-based line `N` |
| `F03 §8` | `reports/F03_gen_config.md` §8 (inventory already landed) |
| `D07 §3.x` | `reports/D07_resources_bin.md` §3.x (placement / `FillOwnerMap` already landed) |

Labels: **`[O]`** literal bytes/line read this session; **`[D]`** deterministic consequence of `[O]` values; **`[I]`** reading with a stated caveat; **`[U]`** no consumer recovered or activation unproven; **`PORT APPROXIMATION`** design input only. **No donor-parity claim is made anywhere in this report** — no donor A/B GPU frame was produced and no donor binary was executed. File SHA-256 matches F03 §2 exactly (`17d4aedd…111f`), so the inventory below is the same byte set F03 counted.

Interpretation guardrail inherited from D07: every relevant `.inc`/`.script` consumer line is prefixed `[*] = ;` (authoritative donor *intent* text, not proven runtime execution). Numeric/transform claims from those lines are `[O]` as text, with live activation `[U]`.

---

## 1. Executive summary

1. **`[O]` The "ASCII placement mask" is not a terrain mask, a resource map, or an occupancy/blocked grid. It is a relative starting-units-and-buildings stamp template.** Each non-`.` character is a *legend key*; the legend resolves it to a unit role (`gc_ai_unit_*` enum) or a named object (`basename`) owned by a country. The consumer resolves `role>0 → _country_GetMemberIDByAIRole(countryid,role)`, else `basename<>'' → _unit_ConvertObjSIDToID(countryid,basename)`, then calls `CreateUnit(plind,countryid,unitid,x,z,-90)` (`DG:342-359, :376`). This is the single decisive pass that settles the conflicting "start / player index / resource / blocked" readings of the alphabet (§3, §4.1).

2. **`[O]` The mask alphabet contains exactly 21 symbols: `.` plus 20 uppercase letters** `A B C E F G H K L O P Q R S T U V W X Z`. There is **no digit, no player-index symbol, no resource symbol and no blocked/terrain symbol** in any of the 61 masks (exhaustive character census, §4.2). All 61 grids are rectangular; dimensions span 6×26 … 34×41 with 24 distinct shapes (§4.3).

3. **`[O]` `X` (role 1 = `gc_ai_unit_peasant`) is the player start/peasant cluster**; in `startid=5` and `startid=13` the letter keys carry an explicit `countrysid`, so a letter *is* a nation's start point (e.g. `A=aus`, `F=fra`, `B=hun`). **`P` is normally role 23 `gc_ai_unit_infantry17`** (a 6×6 army block) but is `role=1 countrysid=pol` in `startid=5`. `O/B` are `officer17`/`drummer17`; `Q/W` are market buildings `misblg`/`misblg2` (`SS:133-167, :1576-1657, :2990-3012`; enum `SS:14-68`). F03 §8's gloss "X center, PTCenter" is imprecise and is corrected here by the consumer (§3 pass P4).

4. **`[D]` Preset selection and player-slot mapping are fully recovered from the consumer:** preset chosen by `startid == gMap.settings.additional.startingunits` **and** a data-version band; then, for player `plind`, the **first** country group whose `allowedcountries` contains that player's country sid wins (`break(ALLOWEDCOUNTRIES)`). `countrysid<>''` in a legend overrides the player's country; empty inherits `cid` (`DG:239-253, :268-281, :351-354, :385`).

5. **`[O]` The mask does NOT fix where a player starts on the map.** It is centred on `gMap.players[plind].startx/starty` (`DG:331-332`) — i.e. on the start already chosen by `RandomStartingPoints`, which reshuffles `arrStartPos[]` and rewrites `startx/starty` (`DG:1090, :1114-1117`). The mask defines the *shape of the camp* around that start, not the start coordinate. The `startid` comment enum (`gc_mapsettings_startingunits_*`, `SS:2-12`) and the `startingunits>default` gate (`DG:232, :1605, :1918`) show these are **skirmish map-setting presets, not mission-only data** (`[I]` on UI-semantics, `[U]` on live activation).

6. **`[O]` Relationship to D07:** the mask pass pre-stamps `gPatternMask` with circles **r=5 for buildings / r=1 for units** (`DG:365-373`, `_misc_FillPatternMaskCircle` `DG:34-50`) at the *original* start positions *before* `RandomStartingPoints` (`DG:1607` vs `:1615`), and creates the actual units *after* the shuffle at the *final* positions (`DG:1918-1921`). These circles are a fourth, distinct occupancy contribution alongside D07's three ellipses 5×7 / 12×15 / 22×18 (`DG:407-414`). **`FillOwnerMap` is a separate late 4-neighbour BFS over 160×160 cells and never reads this file** (D07 §3.9; `DG:2062`).

7. **`[O]` Two donor quirks recovered, not "fixed":** (a) the per-country-group `addresources` field exists in 9 groups but the consumer reads the *preset-level* `addresources` a second time (`DG:283` uses `pStartingSetting`, not `pCountry`), so the global stock is added twice for a matched group; (b) the 4 parallel legend arrays are `[0..15]` (`DG:293-296`) while the largest group has 14 entries — within bounds, so no overflow here.

8. **`[O]/[D]` Counts independently re-parsed from donor bytes agree with F03 §8:** 19 `startid` records (including the `-1` example and the empty `startid=0`), 61 masks/country groups, 276 legend entries, 20 distinct legend keys. Machine-readable index emitted in temp (§3).
9. **`[O]/[D]` The mask cell scale is now exact:** `unitradius = 10 × 0.01875 × 4 = 0.75` map cells (`DMG:665`, `DMG:173`, `DG:330`), so even the largest 34×41 mask spans only `25.5 × 30.75` cells — a compact relative camp template, not a full-map coordinate grid (§4.5, §9 U2 resolved).

---

## 2. Evidence table

| # | Claim | Label | Donor citation |
|---:|---|---|---|
| E1 | File identity / size / lines / hash | `[O]` | `SS:1-3424`; SHA-256 `17d4aedd…111f` (this session + F03 §2) |
| E2 | `startid` enum + role enum + nation id comments | `[O]` | `SS:2-12`, `SS:14-68`, `SS:70-85` |
| E3 | Example preset, 6-entry legend, 7×41 mask, literal rows | `[O]` | `SS:87-180`; legends `:132-167`; mask `:169-177` |
| E4 | `startid=0` has no `countries` block | `[O]` | `SS:181-184` |
| E5 | 19 presets / 61 masks / 276 legend entries / 20 keys | `[O]`/`[D]` | full re-parse `SS:87-3423`; `startsettings_index.json` |
| E6 | Consumer `CreateUniqueStartingUnits` exists and reads this file | `[O]` | `DG:230-396`; load at `:241-242` (`gc_filepath_startingsettings`) |
| E7 | Skirmish gate `startingunits > default` | `[O]` | `DG:232`, `:1605`, `:1918`; enum `SS:3` |
| E8 | Preset selection = `startid` + dataversion band | `[O]` | `DG:244-253` |
| E9 | Global `addresources` → player stock | `[O]` | `DG:255-263` |
| E10 | Country group = first `allowedcountries` match for player cid | `[O]` | `DG:265-281`, `:385-390` |
| E11 | Group `addresources` is read from preset handle (double-add quirk) | `[O]` | `DG:283-291` vs config `SS` group blocks |
| E12 | Legends → 4 arrays bound `[0..15]` | `[O]` | `DG:293-317`; max 14 entries (`SS:1574-1658`) |
| E13 | Mask dims = row count × max row length | `[O]` | `DG:318-329` |
| E14 | Mask centred on player start; `unitradius` comment `//0.75` | `[O]`/`[I]` | `DG:330-332` |
| E15 | Per-cell decode: skip `.`/space; legend match; role/basename→unitid | `[O]` | `DG:333-359` |
| E16 | `countryid` override from legend `countrysid`, else player cid | `[O]` | `DG:350-354` |
| E17 | `bOnlyModifyPatternMask` → circle r=5/1 into `gPatternMask`; else `CreateUnit` dir −90 | `[O]` | `DG:360-377`; circle helper `DG:34-50` |
| E18 | Mask pre-stamp before `RandomStartingPoints`; units after | `[O]` | `DG:1601-1607`, `:1615`, `:1914-1921` |
| E19 | Start positions shuffled by `RandomStartingPoints` | `[O]` | `DG:1090`, `:1114-1117` |
| E20 | Three keep-clear ellipses 5×7 / 12×15 / 22×18 | `[O]` | `DG:407-414`; D07 §3.6 |
| E21 | `differentnations` special path | `[O]` | `ME:799`; preset `SS:1538-1698` |
| E22 | `startid=13` comment `union`; 11 groups of nation pairs | `[O]` | `SS:2971-3424` |
| E23 | `startid=4` peasantslot: mask contains only `X`/`Q`/`W` | `[O]` | `SS:718-859`; mask `:773-780` |
| E24 | Rule ambiguity in earlier F03 §8 gloss | `[D]` | F03 §8 vs `DG:342-359` (this report corrects) |
| E25 | `unitradius = 10 × 0.01875 × 4 = 0.75`; config path literal | `[O]`/`[D]` | `DMG:665`, `DMG:173`, `DMG:1358`; `DG:84`, `:157`, `:330` |

---

## 3. Method and multi-pass register

**Tools:** PowerShell `[IO.File]::ReadAllLines` + `Get-FileHash`; Python 3 (`latin-1` decode) generic struct-tree parser emitting JSON **only** under `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\startsettings_validate\`. No donor executable was run, no donor file copied into the repo, no Craft Anything target changed, no Godot job, no repo source/asset/config edit, no git operation.

Parser grammar recovered `[O]`: `startingsettings : section.begin` → repeated `[*] : struct.begin` presets → `countries : struct.begin` → repeated `[*]` country groups → `allowedcountries[]`, `addresources`, `legends[]` (`key`/`role`/`countrysid`/`basename`) and `mask[]` rows. Tree depth and line numbers are preserved in the JSON index.

**Multi-pass on contradictory symbol meanings (owner directive):**

| Pass | Instrument | Result | Acceptance |
|---|---|---|---|
| P1 | Legend text census, all 276 entries (`SS:132-3420`) | 20 distinct keys; each entry has `key`, one or more of `role`/`countrysid`/`basename`; empty `role` coexists with `basename` | Suggests unit/building selectors, not terrain; but legend alone cannot prove semantics |
| P2 | Actual grid geometry (`SS:170-176`, `:774-779`, `:1661-1694`, `:3015-3020`) | `X`/letters form solid blocks and singletons; `.` is filler; **no digit or resource glyph anywhere** | Refutes "player index / resource / blocked char" readings `[O]` |
| P3 | Prior reports: F03 §8 ("X center, PTCenter, B drummer17, O officer17, Q/W market buildings") | Partly right (`X`,`O`,`B`,`Q`,`W`), but `P` gloss "TCenter" conflicts with the file's `role=23` and enum `gc_ai_unit_infantry17` | Kept as prior art, **not** authority |
| P4 | **Consumer decode** `DG:333-383` | `.`/space skipped; key→legend index; `role>0 → _country_GetMemberIDByAIRole`; `basename → _unit_ConvertObjSIDToID`; `CreateUnit(...)` or mask-circle stamp | **Accepted as decisive** `[O]`. Explains every observed grid shape and every legend field; supersedes P3 |
| P5 | Cross-check `X` identity: `SS:133-136` `role=1` ↔ `SS:16` `gc_ai_unit_peasant = 1` ↔ `DG:355-356` | Consistent | `X` = start/peasant cluster `[O]`/`[D]` |
| P6 | Cross-check nation-start letters: `SS:1576-1657` (14 keys `role=1 countrysid=…`) and `SS:2990-2999` (`A=aus`,`B=hun`) ↔ `DG:351-354` | Consistent | Letters can be nation start markers; slot comes from `countrysid`, not a digit `[O]` |
| P7 | Exhaustive char census over all 61 masks | Only `.` + 20 letters; all rows equal length per mask; max legend entries 14 ≤ array bound 16 | No hidden alphabet; no out-of-bounds `[O]`/`[D]` |
| P8 | Consumer call order `DG:1607` / `:1615` / `:1919` + `RandomStartingPoints` `:1114-1117` | Pre-stamp, shuffle, then create | Explains why the mask cannot be the authority on start coordinates `[O]` |
| P9 | Recursive constant grep across `data/**/*.global|*.script|*.inc|*.aix|*.cfg` for `gc_obj_radius_default`, `gc_tiles_to_pixels`, `gc_filepath_startingsettings` | `DMG:665` = `10`; `DMG:173` = `0.01875`; `DMG:1358` = `'.\data\game\var\startingsettings.cfg'`; independent `DG:84,157,330` uses of the same product | **Resolves U2**: `unitradius = 10 × 0.01875 × 4 = 0.75` `[O]`/`[D]`; also confirms the consumer file path literal |

**Accepted reading:** the alphabet is a *unit/building placement key alphabet*, scoped per country group. Ambiguity from F03 §8 is resolved by the consumer; the "start point / player index / resource / blocked" categories in the task brief map as follows: start point = `X`/nation-letter role-1 keys; player index = **not encoded** (comes from `plind` + `allowedcountries`); resource = **not encoded** (numeric `addresources`); blocked = **not encoded** (emergent `gPatternMask` circles after placement).

**Machine-readable outputs (temp only):**
- `startsettings_index.json` — 19 presets, every country group, all 61 masks with literal rows, all 276 legend entries, per-group legend maps, exact line ranges, dims and character sets.
- `mask_grammar.json` — symbol semantics, transform formula, selection rule, counts.

---

## 4. Mask grammar

### 4.1 Formal grammar `[O]`

```
startingsettings : section.begin
   [*] : struct.begin                         // preset  (SS:87 …)
      startid = <int>                         // matches gMap.settings.additional.startingunits
      dataversionmin = <int>                  // optional; 0/0 = always-eligible (DG:253)
      dataversionmax = <int>
      addresources : struct.begin             // food/wood/stone/gold/iron/coal
      countries : struct.begin
         [*] : struct.begin                   // country group (one becomes active per player)
            allowedcountries : struct.begin
               [*] = <country sid>            // 1..21 ids; match against player's cid
            struct.end
            addresources : struct.begin       // present in 9 of 61 groups (SS)/DG:283 quirk
            legends : struct.begin
               [*] : struct.begin
                  key = <1 char>              // mask alphabet glyph
                  role = <int>                // gc_ai_unit_* role id, or empty
                  countrysid = <sid|empty>    // non-empty overrides player country
                  basename = <obj sid|empty>  // used when role empty
               struct.end
            struct.end
            mask : struct.begin
               [*] = <row string>             // H rows, each exactly W chars
            struct.end
         struct.end
      struct.end
   struct.end
```

### 4.2 Alphabet and per-symbol meaning `[O]`/`[D]`

| Symbol | Meaning resolved by consumer | Evidence |
|---|---|---|
| `.` | Empty — skipped (`schar<>'.' and schar<>' '`) | `DG:339` |
| any letter | Legend lookup key → unit role or named object | `DG:342-359` |
| `X` | `role=1` = `gc_ai_unit_peasant` — the start/peasant cluster | `SS:133-136`; `SS:16`; `DG:355-356` |
| `P` | normally `role=23` = `gc_ai_unit_infantry17` (6×6 army block); in `startid=5` `role=1 countrysid=pol` | `SS:139-142`; `SS:38`; `SS:1612-1615` |
| `O` / `B` | `basename=officer17` / `drummer17`, or roles 21 / 22 (also 5/6 in some groups) | `SS:145-154`; `SS:36-37` |
| `Q` / `W` | `basename=misblg` / `misblg2`, `countrysid=mis`; or `role=13` tower; `W` also `role=1 countrysid=swe` in `startid=5` | `SS:157-166`; `SS:28`; `SS:1618-1621` |
| `C` / `H` / `K` / `S` | `role=3` center / `role=30` cannon; `role=17` house / `role=31` howitzer; `role=9` stable; `role=14` smith or `role=1 countrysid=spa` | `SS:1865, :2034, :2601, :2089, :2583, :2444` |
| `A E F G L R T U V Z` | `role=1` + explicit `countrysid` → nation start markers in `startid=5`/`13`; `Z` also `misblg2` | `SS:1576-1657`; `SS:2990-2999` |

**Not in the alphabet** `[O]`: player index (digits), resource glyphs, blocked/terrain glyphs, spaces (the consumer tolerates `' '` but no row contains one).

### 4.3 Dimensions `[O]`/`[D]`

61 masks; `maskheight = number of [*] rows`, `maskwidth = max StrLength(row)` (`DG:322-329`); all masks rectangular (verified). Shape histogram (rows×cols → count, Σ=61): `6×26→1, 6×32→2, 6×33→11, 6×37→1, 6×41→12, 6×43→1, 6×44→1, 6×45→1, 7×40→2, 7×41→6, 7×48→2, 8×32→1, 8×41→2, 8×42→1, 9×32→2, 9×44→1, 9×45→1, 9×46→1, 10×26→1, 10×45→3, 11×45→4, 12×32→2, 29×46→1, 34×41→1`. Small templates (6–12 rows) are *relative camp layouts*; the two large ones (`startid=5` 34×41, `startid=9` ukra 29×46) are near-map-sized nation layouts.

### 4.4 Preset selection + country-group → player-slot mapping `[O]`

1. `curver := gRecordGeneratorVersion` for replays, else `gDataVersion` (`DG:234-238`).
2. Skip unless `gMap.settings.additional.startingunits > gc_mapsettings_startingunits_default` (`DG:232`). `startid=-1` (the "example", `SS:88-89`) and `startid=0` (`SS:181-184`, empty) are never selected through this path.
3. Iterate presets; require `startid == startingunits` **and** `((min=0 and max=0) or (min≤curver≤max))` (`DG:244-253`). This is why `startid=1..4` appear twice (bands `0..59` and `60..1000`, e.g. `SS:187-189` vs `SS:862-864`).
4. Add the preset's global `addresources` to the player (`DG:255-263`).
5. For each country group, walk `allowedcountries`; convert sid→id; the **first** group whose id equals the player's `cid` is the active group; `break(ALLOWEDCOUNTRIES)` (`DG:268-281, :385`).
6. Load that group's legends into parallel arrays `[0..15]` (`DG:293-317`) and its mask rows (`DG:318-329`).
7. For every non-empty cell, resolve `countryid` from legend `countrysid` **or inherit the player's `cid`** (`DG:350-354`), resolve `unitid` from `role` or `basename` (`DG:355-359`), and either stamp `gPatternMask` or create the unit (`DG:360-377`).

`[D]` Consequence: a "player slot" is **not** a mask symbol; it is the tuple `(plind, cid, selected preset, selected country group)`. In `startid=13` (`union`, `SS:2972`) each group holds a *nation pair* (`SS:2984-2987` aus/hun, `:3024-3027` tur/alg, …) and the mask's `A`/`B` are those two nations' role-1 starts (`SS:2990-2999`), so the mask fixes the two allied nations' *relative* camp positions. In `startid=5` (`differentnations`, `SS:1539`) one group covers all 21 nations and the 34×41 grid assigns each nation letter a distinct fixed cell (`SS:1661-1694`).

### 4.5 Placement transform `[O]` / `[D]` scale

```
unitradius = gc_obj_radius_default * gc_tiles_to_pixels * 4   (DG:330)
           = 10 * 0.01875 * 4 = 0.75                            (DMG:665, :173; [D])
lx = startx - maskwidth*unitradius/2 ; ty = starty - maskheight*unitradius/2   (DG:331-332)
x = lx + n*unitradius ; z = ty + m*unitradius ; dir = -90                        (DG:362-364, :376)
```
`gc_obj_radius_default = 10` (`C:\Games\Cossacks 3\data\scripts\dmscript.global:665`) and `gc_tiles_to_pixels = 0.01875` (`:173`) are now `[O]` literals, so the donor's inline `//0.75` comment at `DG:330` is a **derived exact value**, not a guess. `[D]` A 41-column mask spans `41 × 0.75 = 30.75` map cells; a 6-row mask spans `4.5` cells; the 34×41 `differentnations` grid spans `25.5 × 30.75` cells — i.e. these are compact relative camp templates even at 41 columns, not full-map coordinates (cf. §10 Q6).

---

## 5. Findings with excerpts (exact line ranges + literal values)

### 5.1 Representative A — the `-1` "example" template (`SS:87-180`)

Legend (`SS:132-167`): `X→role1`, `P→role23 countrysid=pol`, `O→basename=officer17 (fra)`, `B→basename=drummer17 (fra)`, `Q→basename=misblg (mis)`, `W→basename=misblg2 (mis)`. Mask block `SS:169-177`, **7 rows × 41 cols**, literal (`SS:170-176`):

```
...........O..B............O..B..........
..........PPPPPP..XXXXXX..PPPPPP.........
..........PPPPPP..XXXXXX..PPPPPP.........
.Q........PPPPPP..XXXXXX..PPPPPP.......W.
..........PPPPPP..XXXXXX..PPPPPP.........
..........PPPPPP..XXXXXX..PPPPPP.........
..........PPPPPP..........PPPPPP.........
```
`[D]` Reads as two 6×6 `P` army wings flanking a 6×6 `X` peasant core, two `O`/`B` hero singletons above the wings and `Q`/`W` market buildings at the outer corners. `allowedcountries` has 21 sids (`SS:100-122`). The identical 7×41 mask is reused by `startid=1` group 0 (`SS:261-267`, preset `SS:185-311`) and by the `0..59` band copy (`SS:936-942`).

### 5.2 Representative B — `startid=4` "peasantslot" (`SS:718-859`)

Preset `SS:718-859`; `dataversionmin=60`, `dataversionmax=1000` (`SS:721-722`); global resources `food=20000, wood=0, stone=0, gold=0, iron=6000, coal=9000` (`SS:723-730`). Group 0 `SS:732`, 18 `allowedcountries` (`SS:733-752`). Mask block `SS:773-780`, **6 rows × 41 cols**, literal (`SS:774-779`):

```
........XXXXXXXX..XXXXXX..XXXXXXXX.......
........XXXXXXXX..XXXXXX..XXXXXXXX.......
.Q......XXXXXXXX..XXXXXX..XXXXXXXX.....W.
........XXXXXXXX..XXXXXX..XXXXXXXX.......
........XXXXXXXX..XXXXXX..XXXXXXXX.......
........XXXXXXXX..XXXXXX..XXXXXXXX.......
```
`[O]` Every cell that would be an army (`P`) is replaced by `X` (peasant role 1) — consistent with the `peasantslot` enum name (`SS:7`). This preset has two further groups: ukr `SS:782` (mask `SS:807-812`) and tur+alg `SS:815` (mask `SS:849-854`); the latter carries group `addresources` with `gold=1000` and empty other fields (`SS:828-836`), which the consumer does not read from the group handle (§1 item 7).

### 5.3 Representative C — `startid=5` "differentnations" (`SS:1538-1698`)

Preset header `SS:1538-1548` (`//gc_mapsettings_startingunits_differentnations` at `:1539`, `startid=5` at `:1540`, all six resources `=5000` at `:1542-1547`). One group `SS:1550`, 21 `allowedcountries` (`SS:1551-1573`), 14 legend entries (`SS:1575-1658`) mapping `A=aus, F=fra, E=eng, S=spa, R=rus, U=ukr, P=pol (all role 1)`, `W=swe, G=pru, V=ven, T=tur, L=alg` (role 1), plus `Q=misblg`, `Z=misblg2`. Mask block `SS:1660-1695`, **34 rows × 41 cols**; key literal rows:

```
1661: ....................Q....................
1674: ........AAAAAAAAAAAA..PPPPPPPPPPPP.......
1676: ........FFFFFFFFFFFF..WWWWWWWWWWWW.......
1678: .Q......EEEEEEEEEEEE..GGGGGGGGGGGG.....Z.
1680: ........SSSSSSSSSSSS..VVVVVVVVVVVV.......
1682: ........RRRRRRRRRRRR..TTTTTTTTTTTT.......
1684: ........UUUUUUUUUUUU..LLLLLLLLLLLL.......
1694: ....................Z....................
```
`[D]` This is a whole-map station layout: each nation's 12-cell band is a distinct fixed nation start, and `Q`/`Z` market buildings sit at top-centre and bottom-centre plus left/right edges. Corroborated by `ME:799`, which special-cases `startingunits <> differentnations` in a later unit-cleanup pass.

### 5.4 Representative D — `startid=13` "union" (`SS:2971-3424`)

Header `SS:2971-2981` (`//gc_mapsettings_startingunits_union` at `:2972`, `food=1000`, others 0). **11 country groups**, each a nation pair: aus/hun (`:2984-2987`), tur/alg (`:3024-3027`), ukr/rus (`:3064-3067`), spa/por, ven/pie, eng/net, swe/den, fra/swi, pol/pru, bav/sax, and sco alone (group 10, `:3383`). Group 0 mask `SS:3014-3021`, **6 rows × 33 cols**, literal (`SS:3015-3020`):

```
.................................
.................................
........AAAAAAAA..BBBBBBBB.......
.................................
.................................
.................................
```
Legends `SS:2989-3012`: `A→role1 countrysid=aus`, `B→role1 countrysid=hun`, `Q→misblg`, `W→misblg2`. `[D]` The same 6×33 grid is reused for each pair with `A`/`B` re-bound to that pair's nations — the mask fixes the *relative* start offset of two allied players; absolute placement still comes from `startx/starty`.

### 5.5 Full preset ledger `[O]`

`startid → comment (line) | preset line range | groups | group mask line ranges (rows×cols)`

| startid | enum comment (SS line) | lines | groups | mask ranges (dims) |
|---:|---|---:|---:|---|
| -1 | `example` (:88) | 87-180 | 1 | 170-176 (7×41) |
| 0 | `default` (:182) | 181-184 | 0 | — |
| 1 | `armysmall` (:186 / :861) | 185-311; 860-986 | 2;2 | 261-267 (7×41), 301-307 (7×41); 936-942, 976-982 |
| 2 | `armymedium` (:313 / :988) | 312-500; 987-1175 | 4;4 | 374-379, 413-418, 452-457, 491-496; 1049-1054, 1088-1093, 1127-1132, 1166-1171 |
| 3 | `armylarge` (:502 / :1177) | 501-717; 1176-1393 | 4;4 | 575-581, 627-633, 667-672, 706-713; 1250-1256, 1302-1308, 1342-1348, 1382-1389 |
| 4 | `peasantslot` (:719 / :1395) | 718-859; 1394-1537 | 3;3 | 774-779, 807-812, 849-854; 1450-1455, 1483-1488, 1525-1532 |
| 5 | `differentnations` (:1539) | 1538-1698 | 1 | 1661-1694 (34×41) |
| 6 | `towers` (:1700) | 1699-1823 | 3 | 1753-1758, 1790-1795, 1814-1819 |
| 7 | `cannons` (:1825) | 1824-1986 | 3 | 1884-1892, 1930-1938, 1975-1982 |
| 8 | `cannonsandhowitzers` (:1988) | 1987-2175 | 3 | 2053-2064, 2108-2119, 2162-2171 |
| 9 | `barrack18` (:2177) | 2176-2347 | 3 | 2236-2241, 2276-2281, 2315-2343 (29×46) |
| 10 | `barrack17` (:2349) | 2348-2523 | 3 | 2414-2422, 2463-2471, 2511-2519 |
| 11 | `village` (:2525) | 2524-2827 | 4 | 2608-2618, 2677-2687, 2745-2755, 2813-2823 |
| 12 | `logcabins` (:2829) | 2828-2970 | 3 | 2882-2891, 2920-2929, 2957-2966 |
| 13 | `union` (:2972) | 2971-3424 | 11 | 3015-3020 ×11 |

`[D]` 19 presets; groups with masks summed over all 19 records = `1+0+2+4+4+3 +2+4+4+3 +1+3+3+3+3+3+4+3+11` = **61**; legend entries **276** (all in `startsettings_index.json`).

---

## 6. Relationship to `FillOwnerMap` and D07's keep-clear ellipses

1. **`gPatternMask` contributions are additive and staged** `[O]`:
   - D07 ellipse **5×7** (`cCircle1`) stamped in `CreateStartPoint` before near mines (`DG:407-408`, D07 §3.6);
   - D07 ellipse **12×15** (`cCircle2`) after the stoneforest pass (`DG:410-411`, `:769`);
   - D07 ellipse **22×18** (`cCircle3`) at the end of `SetupStartingResources` (`DG:413-414`, `:947`);
   - **X09 circles r=5 (buildings) / r=1 (units)** from every non-empty cell of the active mask (`DG:365-373`, helper `DG:34-50`), stamped via `CreateUniqueStartingUnits(i, True)` **before** `RandomStartingPoints` (`DG:1607` vs `:1615`).
   All feed the same boolean `gPatternMask` consumed by `_misc_CheckStandPattern(Ext)` (D07 §3.7). There is no semantic water/rock branch in that checker; the circles are pure occupancy.
2. **Ordering quirk** `[O]`/`[I]`: the occupancy stamp (`:1607`) uses the *pre-shuffle* `gMap.players[i].startx/starty`, while actual unit creation (`:1919`) uses the *post-shuffle* position written at `DG:1116-1117`. When `RandomStartingPoints` reassigns slots, the reserved circle footprint and the created camp can be at different locations. This is donor text as shipped; it is reported, not repaired.
3. **`FillOwnerMap` is unrelated to this file** `[O]`: it is a 4-neighbour BFS over `gc_scangrid_mapwidth/gc_scangrid_size = 640/4 = 160` cells, seeded from player starts, running late at `DG:2062`, *after* units and props (D07 §3.9, §3.10 stage 11). It never reads `startingsettings.cfg`, never touches `gPatternMask` circles and never decodes mask glyphs. Its only shared input is the player start coordinate (`startx/starty`) — the same coordinate that centres the mask at `DG:331-332`.
4. **`differentnations` special case** `[O]`: `ME:799` branches on `startingunits <> differentnations` during a later cleanup of unused peasant-type units — a second, independent consumer of the same UI setting.
5. `PORT APPROXIMATION`: if the port implements starting resources, it must keep these as **four separate occupancy contributions** and keep the pre-shuffle/post-shuffle ordering, rather than folding the mask circles into D07's three ellipses.

---

## 7. Implications for spec §07 and §10 — `PORT APPROXIMATION` (not parity claims)

**§07 (resources / starts):**
1. Model `addresources` as **player starting stock**, not deposits: `food/wood/stone/gold/iron/coal` added at `DG:255-263`, consistent with D07 §3.8 (`dogenerate.inc` stock additions), not per-deposit capacity.
2. Preserve the double-add quirk (`DG:283` reads `pStartingSetting` again) or document an explicit port policy; do not silently drop the per-group `addresources` blocks without a decision.
3. Keep mine/stone/forest placement owned by `SetupMines` / `SetupStartingResources` (D07). The ASCII masks add **units and buildings only**; they do not place ore deposits or food fields.
4. Model the mask circles (r=5 buildings / r=1 units) as an additional occupancy prefill alongside the 5×7 / 12×15 / 22×18 ellipses; keep `FillOwnerMap` as a late ownership BFS, not a placement stage.

**§10 (stage order):**
5. Insert the mask consumer into the canonical order at the two observed points: pre-stamp at `D1:1605-1607` (before `RandomStartingPoints` at `:1615`), create units at `D1:1918-1921` (after the shuffle and after the relief/global passes, before the final `SetRandomKey` at `:1927`). The existing §10 item 7 ("starts + border keep-clear", D1:1586–1616) and item 10 ("units + scale", D1:1914–2027) already bracket these sites; X09 supplies the exact sub-steps.
6. Preserve per-stage re-seeding: the mask decode itself draws no `RandomExt`, but it sits between the `SetRandomKey` at `DG:1538` and the one at `:1616`, and again before `:1927` (cf. §10 §2 / X03's 11 re-seed sites). Do not collapse into a single RNG stream.
7. Treat `startid` as the UI starting-units preset (`gc_mapsettings_startingunits_*`), gated by `> default`; `startid=-1` (example) and `startid=0` (default, empty) must not be instantiated by the mask path.

---

## 8. Risks

- **Activation risk (highest):** all cited consumer lines carry the donor `[*] = ;` comment prefix; the algorithm is authoritative *intent*, not proven live execution (D07 U1). No donor run was permitted.
- **Scale risk — RESOLVED by P9:** `unitradius = 10 × 0.01875 × 4 = 0.75` is now `[O]`/`[D]` (`DMG:665`, `DMG:173`, `DG:330`). Remaining risk is interpretive: `0.75` is in the coordinate space used by `gPatternMask[floor(x+W/2)]`, and the port's cell/pixel contract (V08) must match it.
- **Data-version risk:** `curver` is `gDataVersion` / `gRecordGeneratorVersion`; which band (0..59 vs 60..1000) a retail skirmish takes was not resolved from this file (cf. D07 U4).
- **Group-selection risk:** "first matching `allowedcountries` group wins" is read from the literal `break(ALLOWEDCOUNTRIES)` at `DG:385`; the outer preset loop has no break, so two version-banded presets are both *evaluated* but only one can match the band (non-overlapping ranges) `[D]`.
- **Quirk-preservation risk:** double `addresources` and pre-/post-shuffle mismatch may be donor bugs; reproducing them verbatim vs normalising is a COORD policy decision, not a decode error.
- **Character-scope risk:** legend arrays `[0..15]` are per country group; the same glyph (e.g. `P`, `W`, `S`) has different meanings in different groups. A global glyph→unit map would be wrong.
- **No parity claim:** no donor GPU A/B frame; no capture; no runner job.

---

## 9. UNVERIFIED register (with passes attempted)

| # | Item | Passes attempted | What would settle it |
|---|---|---|---|
| U1 | Live activation of the `[*] = ;` consumer text | P1–P8 (text + consumer decode); no binary execution allowed; D07 P1–P5 likewise found no named native function | Donor runtime trace / approved replay inspection |
| U2 | ~~Numeric value of `gc_obj_radius_default` / `gc_tiles_to_pixels`~~ **RESOLVED** | P9 recursive grep found `DMG:665 = 10`, `DMG:173 = 0.01875`; P8/P9 cross-check with `DG:84,157,330` | `[O]`/`[D]` — `unitradius = 0.75` exact; no longer UNVERIFIED |
| U3 | `gDataVersion` / `gRecordGeneratorVersion` value selecting the `0..59` vs `60..1000` bands | `DG:234-253`, `SS:188-189/862-864` read; no literal in this cfg | D02 / saved-record analysis (same as D07 U4) |
| U4 | Whether the shuffled-start mismatch (mask circles at pre-shuffle start, units at post-shuffle start) is observable in retail | `DG:1607/1615/1114-1117/1919` read twice | Runtime trace; remain `[I]` on consequence |
| U5 | `_unit_ConvertObjSIDToID`/`_country_GetMemberIDByAIRole` resolution for every `basename` value (e.g. `misblg`) | legend census + consumer call read; the unit databases were not opened | F08 / unit-SID index cross-check |
| U6 | Whether per-group `addresources` are live in any other consumer | `DG:283` read; only one consumer found in the searched script/game roots | Full-repo xref of `addresources`; currently judged dead in this path `[O]` text / `[U]` overall |
| U7 | Exact role-id → unit-name mapping for all 54 enum roles at runtime | enum `SS:14-68` is comments; no runtime table read | F08 / `country.presets`-style unit-role table |
| U8 | Visual result of any mask (camp silhouette) | none — no capture, no donor frame | A05 harness + owner A/B verdict |

---

## 10. Open questions

1. COORD policy: reproduce the double-`addresources` and the pre-/post-shuffle circle mismatch verbatim, or normalise them with an explicit `PORT APPROXIMATION` note?
2. Which `startid` values are reachable from the actual skirmish UI (0–9 only, or 10–13 as well)? `SS:2349/2525/2829/2972` name four extra enums absent from the `SS:2-12` comment list.
3. Does `RandomStartingPoints` always reassign a slot, or can `newind` equal the original index (making the circle stamp and unit placement coincide)? (`DG:1104-1118`.)
4. How does the engine treat a mask glyph with neither `role` nor `basename` (e.g. legends with both empty)? `unitid` stays 0 and nothing is created by the literal code (`DG:355-360`) — confirm no fallback.
5. Are the 9 group-level `addresources` blocks a leftover from an older consumer, or does another engine path read them? (U6.)
6. Does `startid=5`'s 34×41 grid map to absolute map tiles (fixed nation positions) or is it still centred on a chosen start? The consumer says centred (`DG:331-332`) and the derived span is only `25.5 × 30.75` cells (`unitradius=0.75`, §4.5), which favours "relative template" — but a full-map-looking layout still warrants an A/B check.

---

## 11. Closing statement

X09 recovered the `startingsettings.cfg` mask format from donor bytes and, crucially, identified and decoded its consumer in `dogenerate.inc`: the "ASCII placement masks" are **per-country-group, relative starting-unit/building templates**, not terrain, resource, player-index or blocked-cell masks. Every claim is cited to `SS:N` / `DG:N`; three representative presets are quoted verbatim with exact line ranges; all 61 masks and 276 legend maps are indexed in JSON under the approved temp directory. Multi-pass verification resolved the ambiguous glyph semantics against the consumer rather than trusting the earlier F03 gloss. No repo source/asset/config/git change, no Godot job, no donor execution or copy — and **no donor-parity claim**.

*End of X09. One report written in the repo; two JSON files written in temp only.*
