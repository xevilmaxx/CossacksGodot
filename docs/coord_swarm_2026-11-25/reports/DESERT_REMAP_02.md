---
id: DESERT-REMAP-02
task: "Extend the port desert remap from 11 to all 38 donor case pairs"
date: 2026-11-25
status: DELIVERED__DATA_ONLY__FRESH_DONOR_READ_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB__NO_DONOR_COPY
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
outputs:
  - "variant3d/assets/terrain/atlas/desert_remap.json"
  - "docs/coord_swarm_2026-11-25/reports/DESERT_REMAP_02.md"
backup: "inbox/backup/desert_remap.json.bak-DESERT02"
donor: "C:\\Games\\Cossacks 3\\data\\scripts\\lib\\miscext.script:1429-1543 (READ-ONLY, bytes/latin-1; never executed, unpacked or copied)"
labels: [observed, derived, UNVERIFIED, PORT_APPROXIMATION, DATA_ONLY_NOT_EXECUTED]
visual_parity_claim: false
donor_parity_claim: false
---

# DESERT-REMAP-02 — all 38 donor desert case pairs in the port remap JSON

> **Scope guard.** Only two files written: `variant3d/assets/terrain/atlas/desert_remap.json` and
> this report, plus one backup file `inbox/backup/desert_remap.json.bak-DESERT02` taken before the
> edit. No other file was edited — not `winter_aliases.json`, not the atlas PNG or manifest, not
> any shader, not `world3d_terrain.gd` (SP-6), not tests, not `app/**`. The donor was re-read
> read-only this pass and was not copied, unpacked or executed. **No donor parity claim** is made.

## 1. Sources read this pass

| # | Source | What it supplied | Label |
|---|---|---|---|
| C1 | `docs/coord_swarm_2026-11-25/reports/DSEASON_01_season_visuals.md` | §4 rank 1 / C5: donor has **38 active** `_misc_SetDesert` case pairs at `miscext.script:1447-1502`, port had 11; top remaining seasonal visual gap; activity label `PLAIN_SCRIPT_ACTIVE`, native EXE execution UNVERIFIED | observed |
| C2 | `docs/coord_swarm_2026-11-25/reports/SP_03_desert_remap.md` | prior JSON schema, 11 direct + 1 height-gated pairs, target-index derivation, labels and open questions O1–O6 | observed |
| C3 | `docs/coord_swarm_2026-11-25/decomp/DEC_03_configs.md` | donor inventory/encoding convention: `data\game\var\generator.cfg` 70,074 B, 2367 lines, non-ASCII legacy text; supports the `desert_tiles` weights provenance | observed |
| C4 | `C:\Games\Cossacks 3\data\scripts\lib\miscext.script:1447-1502` (**fresh read, read-only**) | all 38 live `case oldnam of` pairs with exact 1-based lines; `//` alternatives excluded; gate `:1504-1505`, `koef=0.8` `:1513-1520`, mine `s` `:1531-1534`, env destruction `:1536-1537` | observed |
| C5 | `variant3d/assets/terrain/structs/presets_summer.json` (READ-ONLY) | 124 Summer names; source/target array positions (`index = line - 2`) | observed + derived |
| C6 | `variant3d/assets/terrain/atlas/tile_index_atlas.manifest.json` (READ-ONLY) | `layout[].name`, `status`, `source_png` for target verification | observed |
| C7 | `variant3d/assets/terrain/blocks/` (READ-ONLY existence check) | on-disk PNGs for all added targets | observed |

Evidence vocabulary: **observed** = literal bytes/lines read this pass; **derived** = index lookup over
observed arrays; **UNVERIFIED** = cannot be proven from readable data; **PORT APPROXIMATION** = a
port-chosen encoding not asserted as donor parity.

## 2. Donor citations — all 38 active pairs

Path prefix `scripts\lib\miscext.script:` below is relative to `C:\Games\Cossacks 3\data\`.
Line numbers are the exact 1-based lines freshly read this pass. `S###`/`T###` are array positions
in `presets_summer.json` (source/target ids respectively). The `OLD` column marks the 11 SP-3
entries preserved unchanged; `NEW` marks the 27 added entries. Every pair is stored verbatim —
no destination was invented or silently rewritten to a `desertN` id.

| # | Donor path:line | Summer source (idx) | → Desert target (idx) | Target art | State / label | JSON citation |
|---:|---|---|---|---|---|---|
| 1 | `scripts\lib\miscext.script:1448` | `grass1` (0) | `sandsea5` (97) | `sandsea5.png` | OLD · DONOR_INDEX | `:1447-1502` (unchanged SP-3 range) |
| 2 | `:1449` | `grass3` (2) | `test22` (106) | `test22.png` | NEW · DONOR_INDEX | `:1449` |
| 3 | `:1450` | `grass5` (4) | `test22` (106) | `test22.png` | NEW · DONOR_INDEX | `:1450` |
| 4 | `:1451` | `grass7` (6) | `desert6` (116) | `desert6.png` | OLD · DONOR_INDEX | `:1447-1502` |
| 5 | `:1452` | `grass8` (7) | `desert6` (116) | `desert6.png` | OLD · DONOR_INDEX | `:1447-1502` |
| 6 | `:1454` | `ground1` (10) | `test16` (100) | `test16.png` | OLD · DONOR_INDEX | `:1447-1502` |
| 7 | `:1455` | `test2` (73) | `ground1` (10) | `ground1.png` | NEW · DONOR_INDEX | `:1455` |
| 8 | `:1456` | `test1` (72) | `ground1` (10) | `ground1.png` | NEW · DONOR_INDEX | `:1456` |
| 9 | `:1457` | `test3` (74) | `ground1` (10) | `ground1.png` | NEW · DONOR_INDEX | `:1457` |
| 10 | `:1462` | `grass2` (1) | `desert11` (121) | `desert11.png` | OLD · DONOR_INDEX | `:1447-1502` |
| 11 | `:1463` | `test7` (78) | `desert11` (121) | `desert11.png` | OLD · DONOR_INDEX | `:1447-1502` |
| 12 | `:1464` | `test8` (79) | `desert11` (121) | `desert11.png` | OLD · DONOR_INDEX | `:1447-1502` |
| 13 | `:1468` | `grass_ground1` (14) | `desert11` (121) | `desert11.png` | NEW · DONOR_INDEX | `:1468` |
| 14 | `:1469` | `grass_ground2` (15) | `sandsea5` (97) | `sandsea5.png` | NEW · DONOR_INDEX | `:1469` |
| 15 | `:1471` | `grass_ground3` (16) | `desert11` (121) | `desert11.png` | NEW · DONOR_INDEX | `:1471` |
| 16 | `:1472` | `rock1` (17) | `desert2` (112) | `desert2.png` | OLD · DONOR_INDEX | `:1447-1502` |
| 17 | `:1473` | `rock3` (19) | `sandrock6` (92) | `sandrock6.png` | NEW · DONOR_INDEX | `:1473` |
| 18 | `:1474` | `rock4` (20) | `sandrock6` (92) | `sandrock6.png` | NEW · DONOR_INDEX | `:1474` |
| 19 | `:1475` | `rock5` (21) | `test22` (106) | `test22.png` | NEW · DONOR_INDEX | `:1475` |
| 20 | `:1476` | `rock7` (23) | `desert4` (114) | `desert4.png` | OLD · DONOR_INDEX | `:1447-1502` |
| 21 | `:1477` | `rock8` (24) | `test22` (106) | `test22.png` | NEW · DONOR_INDEX (base case) | `:1477` |
| 22 | `:1479` | `rock9` (25) | `test23` (107) | `test23.png` | OLD · DONOR_INDEX | `:1447-1502` |
| 23 | `:1480` | `test0` (71) | `sandsea5` (97) | `sandsea5.png` | NEW · DONOR_INDEX | `:1480` |
| 24 | `:1482` | `test4` (75) | `sandsea5` (97) | `sandsea5.png` | NEW · DONOR_INDEX | `:1482` |
| 25 | `:1483` | `test6` (77) | `sandsea6` (98) | `sandsea6.png` | NEW · DONOR_INDEX | `:1483` |
| 26 | `:1484` | `test9` (80) | `desert6` (116) | `desert6.png` | NEW · DONOR_INDEX | `:1484` |
| 27 | `:1485` | `test12` (83) | `sandsea5` (97) | `sandsea5.png` | NEW · DONOR_INDEX | `:1485` |
| 28 | `:1486` | `test13` (84) | `sandsea6` (98) | `sandsea6.png` | NEW · DONOR_INDEX | `:1486` |
| 29 | `:1487` | `test14` (85) | `desert11` (121) | `desert11.png` | NEW · DONOR_INDEX | `:1487` |
| 30 | `:1490` | `sandrock2` (88) | `sandsea6` (98) | `sandsea6.png` | NEW · DONOR_INDEX (seashore) | `:1490` |
| 31 | `:1491` | `sandrock3` (89) | `sandsea5` (97) | `sandsea5.png` | NEW · DONOR_INDEX (seashore) | `:1491` |
| 32 | `:1492` | `sandrock4` (90) | `sandsea5` (97) | `sandsea5.png` | NEW · DONOR_INDEX (seashore) | `:1492` |
| 33 | `:1495` | `grass10` (9) | `sandsea1` (93) | `sandsea1.png` | NEW · DONOR_INDEX (empty group) | `:1495` |
| 34 | `:1496` | `test11` (82) | `sandsea1` (93) | `sandsea1.png` | NEW · DONOR_INDEX (empty group) | `:1496` |
| 35 | `:1497` | `grass6` (5) | `sandsea1` (93) | `sandsea1.png` | NEW · DONOR_INDEX (empty group) | `:1497` |
| 36 | `:1498` | `grass9` (8) | `sandsea1` (93) | `sandsea1.png` | NEW · DONOR_INDEX (empty group) | `:1498` |
| 37 | `:1499` | `test5` (76) | `sandsea1` (93) | `sandsea1.png` | NEW · DONOR_INDEX (empty group) | `:1499` |
| 38 | `:1501` | `alpha0a` (86) | `alpha0c` (123) | **none — EMPTY cell** | OLD · DONOR_INDEX / PORT_APPROXIMATION, target UNVERIFIED | `:1501` (unchanged) |

Counts from this table: **38/38** active donor pairs; **11 OLD** preserved byte-for-byte as parsed
objects, **27 NEW** added. **1 additional** non-`case` rule remains in the separate `height_gated`
block: donor `rock8 → desert2` at `:1504-1505` when `0.1 < h < 2.9 and (h > 1.8 or h < 1)`
(unchanged from SP-3). It is an override of case 21, not a 39th `case` pair.

### 2.1 Excluded donor text (not active cases)

| Donor lines | Literal | Why excluded |
|---|---|---|
| `:1458-1460` | `//'grass2' / 'test7' / 'test8' → sandrock1` | `//`-commented alternatives; live cases at `:1462-1464` used instead |
| `:1467` | `//'grass_ground1' → test23` | `//`-commented; live `:1468` → `desert11` |
| `:1470` | `//'grass_ground3' → test22` | `//`-commented; live `:1471` → `desert11` |
| `:1478` | `//'rock9' → test23` | `//`-commented; live `:1479` → `test23` (same destination, but only one live line is cited) |

### 2.2 Ordering nuance (recorded in JSON notes, not "fixed")

`test2/test1/test3 → ground1` (`:1455-1457`) coexists with `ground1 → test16` (`:1454`). The donor
loop computes `newnam` once from `oldnam` (`:1443-1447`) and never chains, so both pairs are stored
verbatim. No destination was "corrected" to `test16`.

## 3. What changed in the JSON

1. **Added 27 `remap` entries** (table §2, `NEW` rows) with `target`, `atlas_index`, `source_index`,
   `target_source_png`, exact `donor_line`, `label` and explanatory `note`, matching the SP-3 schema.
2. **Added one `extension` block** recording this ticket, the fresh donor read, before/after counts
   (11 → 38), the 27-case count rationale, and the no-invention/art-verification statement.
3. **Scoped two stale SP-3 sentences** (`scope`, `donor_access`) to SP-3 so the file no longer claims
   the donor was never opened; the fresh read is described in `extension.donor_access`.
4. **Refreshed the `validation` block and `unverified` array** to the 38-case truth; `target_categories`
   now lists the additional packed Summer-set targets (`ground1` 10, `sandrock6` 92, `test22` 106).
5. **Untouched:** all 11 original `remap` entries; `height_gated`; `data_only_not_executed`
   (`koef = 0.8`, mine suffix `s`, env destruction, `desert_tiles` weights `1000/0/1000/100`);
   `scope_clarifications`; `port_reference`; `labels`; `source`. Schema version remains 1.

**Backup:** `inbox/backup/desert_remap.json.bak-DESERT02` (9,395 bytes) was copied from the SP-3
JSON before any edit; it is the byte-exact pre-extension file.

## 4. Validation (Python 3.14, read-only)

| Check | Result |
|---|---|
| `python -c "import json; json.load(open(r'...\desert_remap.json', encoding='utf-8'))"` | **PASS** (17 top-level keys, no syntax error) |
| Donor `case` lines freshly parsed from `:1447-1502` | **38** |
| `remap` entries before → after | **11 → 38** (added **27**) |
| `remap` source keys vs donor source names | **38/38** set-equal; 0 missing, 0 extra |
| Original 11 entries object-equal to backup | **11/11 unchanged** |
| `height_gated`, `data_only_not_executed`, `scope_clarifications`, `port_reference`, `labels`, `source` object-equal to backup | **6/6 unchanged** |
| Sources present in `presets_summer.json` | **38/38** (plus 1 gated source = 39/39) |
| Targets present in `presets_summer.json` / manifest `layout` | **38/38** (plus 1 gated target = 39/39) |
| `source_index` / `atlas_index` equal array positions | **38/38** |
| Declared `target_source_png` equals manifest `source_png` | **38/38** (including `null` for `alpha0c`) |
| Targets with on-disk PNG under `variant3d/assets/terrain/blocks/` | **37/38**; the single exception is pre-existing `alpha0c` |
| Added cases with a missing / unverified art target | **0/27** |
| Donor pair + destination match for all 38 remap entries | **38/38** (10 originals retain SP-3's range citation `:1447-1502`; exact per-line citations are in §2) |
| New ids / invented destinations | **0 / 0** |
| Donor parity claim / visual A/B / Godot runner job | **none** |

## 5. Unresolved or missing targets

| Target | Case | Status | Handling |
|---|---|---|---|
| `alpha0c` (index 123) | `alpha0a → alpha0c`, donor `:1501` | **UNVERIFIED / PORT APPROXIMATION** — manifest `status: UNVERIFIED`, `source_png: null`, no shipped PNG; SP-3 also records it as an alias to `grass1.dds` (DEC-05:435) | **Pre-existing**, unchanged from SP-3. Index-only alias; no art fabricated. This is the only unresolved target in the extended table. |

**No added case required an UNVERIFIED/missing label:** all 27 added targets resolve to a named
manifest cell with `status: OK` and an on-disk PNG. No destination was fabricated where donor art
was absent.

## 6. Open questions (do not guess)

1. **Count wording.** DSEASON-01 §4 rank 1 says "26 missing pairs" and separately mentions the base
   `rock8 → test22` (`:1477`) as missing. Counting that base case gives **27** additions and the 38-case
   total requested by this ticket. Both numbers are reconciled in §2 and `extension.count_note`.
2. **Runtime activity.** All 38 are unprefixed, active plain-`.script` case lines (`PLAIN_SCRIPT_ACTIVE`
   per DSEASON-01 §3), but whether `_misc_SetDesert` executes in the shipped EXE is **UNVERIFIED**.
   This table encodes donor text intent only.
3. **`rock8` double representation.** Base `→ test22` (`:1477`) and gated `→ desert2` (`:1504-1505`) are
   both stored. The consumer must honour the height-gated override *after* the base case if it ever
   applies gates; SP-6 is index-only and does not apply the gate. No gate was executed here.
4. **Chained remaps.** `test1/2/3 → ground1` vs `ground1 → test16` is preserved verbatim; donor
   single-pass semantics are inferred from `:1443-1447`, not proven at runtime.
5. **`alpha0c` semantics.** EMPTY/transparent cell vs donor alias to `grass1.dds` remains unresolved
   (SP-3 O4 / DSEASON-01 §6 Q4). Needs the alpha/dash owner; not changed here.
6. **Consumer confirmation.** SP-3 O1 (path `atlas/` vs `structs/`) and SP-6's actual consumption of
   the extended table remain unconfirmed; this ticket is data-only.
7. **Unpacked desert ids.** `desert1/3/5/7/8/9/10/12` still have no explicit donor remap source;
   likely generator weights + smoothing (SP-3 O3). No pair invented for them.

## 7. Summary

DESERT-REMAP-02 extended `variant3d/assets/terrain/atlas/desert_remap.json` additively from **11**
to **38** donor `_misc_SetDesert` case pairs using a fresh read-only donor read of
`miscext.script:1447-1502`: the 11 SP-3 entries are byte-equivalent as parsed objects, and **27**
missing pairs were added with exact `path:line` citations and verified source/target indices, manifest
declarations and on-disk art. The separate height gate and all `koef`/mine-suffix/env-destruction/
`desert_tiles` data-only fields are untouched. Validation: JSON parse PASS, 38/38 donor pairs covered,
38/38 sources and targets resolve, 37/38 targets have art (the sole exception is the pre-existing
`alpha0c` EMPTY cell), 0 invented destinations, 0 added unresolved targets.

**No other file was edited** (apart from the backup and this report). The Winter alias JSON, atlas
PNG and manifest, shaders, `world3d_terrain.gd`, tests and `app/**` were not touched. No donor file was
copied, unpacked or executed; no Godot job was run. **No donor parity or visual-parity claim is made**;
native donor runtime activity stays UNVERIFIED.

*End of DESERT-REMAP-02. One JSON extended, one backup and one report written.*
