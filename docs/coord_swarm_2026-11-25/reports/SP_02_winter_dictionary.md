---
id: SP-02
task: "Winter tile-alias dictionary JSON for the 3D atlas"
agent: "SP-2 WINTER-DICT (micro-builder)"
date: 2026-11-25
status: DELIVERED__DATA_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB__NO_DONOR_COPY
scope: "Two files written ONLY — the new alias-dictionary JSON and this report. No code, shader, test, harness, config, existing asset, donor file or git state edited; no Godot runner job; no donor file opened or copied."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
outputs:
  - "variant3d/assets/terrain/atlas/winter_aliases.json"
  - "docs/coord_swarm_2026-11-25/reports/SP_02_winter_dictionary.md"
labels: [observed, observed-cited-second-hand, derived, UNVERIFIED, PORT APPROXIMATION]
verification_passes: 3
visual_parity_claim: false
---

# SP-02 — Winter tile-alias dictionary (3D atlas)

## 1. Goal and scope

Deliver **one new data file** that maps every Summer tile id/name to its donor Winter
alias and the on-disk art it resolves to, so a future season hook (SP-5/SP-6) can select
Winter art without inventing preset indices. This is a **data-only** ticket: no `.gd`,
`.gdshader`, test, harness, config or existing asset was touched, and no Godot job ran.

The file uses the existing Summer atlas manifest's conventions (`index`, `name`,
`source_png`, `kind`, `status`, `donor_evidence`; `index_dictionary.file` /
`index_dictionary.count`) and the sibling `atlas/desert_remap.json` header keys
(`id`, `schema_version`, `donor_access`, `visual_parity_claim`). Indices **0–123** are
taken verbatim from `presets_summer.json`; **no new index was invented**, and the numeric
suffix of `winterN.png` is treated strictly as a **texture filename**, never as a preset
id.

## 2. Sources read this task (all read-only)

| # | Source | Role / label |
|---|---|---|
| S1 | `docs/coord_swarm_2026-11-25/reports/SEASON_PLAN_01.md` | SP-2 spec, donor chain, blockers B1/B3/B4/B6, Q1, §7 label list (observed doc) |
| S2 | `docs/coord_swarm_2026-11-25/reports/DENV_01_environment.md` | donor season truth: `terrain.lib:12-15`, `terrain.presets:134-263`, `texturemap.inc` sites, `tiles.mat` resolution, gap ranking (observed doc) |
| S3 | `docs/coord_swarm_2026-11-25/decomp/DEC_05_terrain_formats.md` | 27 winter / 12 desert families, 112 DDS, `terrain.presets` two 124-entry sets, tile-id table §5.1 (observed doc) |
| S4 | `docs/coord_swarm_2026-11-25/reports/ATLAS_01_transport.md` | *landed concurrently this session*; 27 winter PNGs intentionally unpacked, desert ids 111–122, empty cells 86/110/123, no transport parity (observed doc) |
| S5 | `docs/audit/PIECES/winter_variant.md` | **complete 124-alias → texture map** (§1.2), shared alpha (§1.1), desert reuse, 4 unaliased, green `winter25` (§1.6/T6-T14) — donor read in an earlier pass |
| S6 | `variant3d/assets/terrain/structs/presets_summer.json` | 124 Summer names in index order (read directly this task) |
| S7 | `variant3d/assets/terrain/atlas/tile_index_atlas.manifest.json` | manifest schema, `index_dictionary`, `unused_shipped_blocks` 27 winter PNGs at `:3019-3048` (read directly this task) |
| S8 | `variant3d/scripts/game.gd:1617-1657` | existing `WINTER_ART` 124-pair map, used as the port-side cross-check of S5 (read directly this task) |
| S9 | on-disk `variant3d/assets/terrain/blocks/winter0.png … winter26.png` | 27 files, all integers 0–26, no gaps (read directly this task) |
| S10 | `variant3d/assets/terrain/atlas/desert_remap.json` | sibling SP-3 data file, header-key consistency only (read directly this task; not edited) |

**Line-drift note (observed):** S1 cites `game.gd:1427-1467` for `WINTER_ART`, but the
current file has the map at `game.gd:1617-1657` — consistent with the volatility warning
in DENV-01 §5 and concurrent SP-1/TRN-DATA edits. No `game.gd` edit was made here.

## 3. Donor citations

**Donor was NOT opened this task.** Every path:line fact below is cited **second-hand**
from S1–S5, which read the donor read-only in earlier passes. Labels: *observed (earlier
pass; cited here)* / *derived* / *UNVERIFIED* / *PORT APPROXIMATION*.

| Donor path:line | Literal / meaning | Citation source | Label |
|---|---|---|---|
| `data/terrain/tiles/terrain.presets:134-263` | Winter `SetName=Winter`, `WaterSet=Winter`, `DefaultIndex=0`; **124** `*_winter` `TileBlock` names | S1 §4.1, S2 §3.3, S3 §4.6 | observed (earlier pass) |
| `data/terrain/tiles/terrain.presets:2-6` | Summer 124-entry section — the source of port indices 0–123 | S3 §4.6; S7 `index_dictionary` | observed (earlier pass) |
| `data/scripts/common.inc/texturemap.inc:525-526,605-606` | **append `_winter`** to tile names when `GetSeasonType=2` — the alias rule encoded in this JSON | S1 §4.2, S2 §3.5/§4, S3 §5.3 | observed (earlier pass) |
| `texturemap.inc:639-640,927-928,950-951` | additional `_winter` append sites | S2 §4.1 | observed (earlier pass) |
| `data/terrain/tiles/tiles.mat` | resolves **124** aliases → **35 unique textures** = **23 `winter*.dds` + 12 unchanged `desert*.dds`**; `desertN_winter → desertN.dds` | S2 §3.3, S5 §1.1–1.2 | observed (earlier pass) |
| `data/terrain/tiles/terrain.lib:12-15` | Summer/Autumn/Spring → `Summer`; Winter → `Winter` (set selection) | S2 §3.1, S1 §4.1 | observed (earlier pass) |
| `data/resource.lib:14-15` | loads `terrain.presets` / `terrain.lib` — the above sets are active config | S2 §2.1, S1 §4.1 | observed (earlier pass) |
| `terrain.presets:138` (e.g. `grass1_winter`) | tile preset aliases append `_winter`; **prop materials append `w`** (`fir1w`) — not conflated here | S1 §4.2, S2 §4 | observed (earlier pass) |
| S5 §1.2 `:49-88` | alias → texture resolution table used for every `source_png` in this JSON | earlier read-only donor parse | observed (earlier pass) |
| S5 §1.1 `:41` / S2 §3.3 | `alpha0a/b/c` shared unchanged in the Winter preset; `tiles.mat` still carries `alpha0a_winter/alpha0b_winter/alpha0c_winter → winter0/winter1/winter1` | S5 `:41,82` | observed (earlier pass) |
| S5 §1.2 `:86,88` | `winter25` is green grass (0 % snow); `winter18/23/24/26` have **no** alias; 23 of 27 referenced | S5; S2 §3.3 | observed (earlier pass) |
| S1 §7 items 1/6, S4 §5.3 | atlas packing `APPROX_ATLAS_PACKING`; donor runtime of `;`-prefixed scripts `UNVERIFIED`; no transport parity | S1, S4 | UNVERIFIED / PORT APPROXIMATION |

Port-side facts read directly this task: S6 (124 names), S7 (27 unpacked winter PNGs,
empty cells `86/110/123`), S8 (124 alias pairs), S9 (27 files on disk). The 23 resolved
winter art files were measured pixel-identical to donor DDS in an earlier pass (S5 §1.6,
T6-T14 Step 1: 27/27 diff bbox `None`) — **this file makes no visual-parity or
transport-parity claim** on that basis.

## 4. JSON output — schema and exact entry count

`variant3d/assets/terrain/atlas/winter_aliases.json` (81,304 bytes before the header-key
alignment edit; revalidated after) contains:

- **Exactly 124 `entries`**, `index` **0–123** contiguous, names and order **identical**
  to `presets_summer.json:2-125`.
- Per entry: `index`, `name`, `winter_alias` (`<name>_winter`), `source_png`
  (`winterN.png` or reused `desertN.png`), `kind` (`WINTER_PNG` / `DESERT_REUSE`),
  `status`, `shared_alpha`, `donor_evidence[]`.
- `index_dictionary` mirrors the Summer manifest (`presets_summer.json`, `lines 2-125`,
  `count 124`); `winter_index_dictionary` records the donor section (`terrain.presets:
  134-263`, count 124) and `on_disk_port_file: null` — **no `presets_winter.json` was
  created** (S1 §3.3).
- `rules` block: `_winter` suffix + citation, set selection, alpha sharing, desert
  reuse, `index_preserving: true` and the explicit warning that `winterN`'s number is a
  **filename, not an index**.
- `coverage` block: counts plus a **27-row `winter_png_inventory`** so every on-disk
  winter PNG is accounted for, referenced or not.
- `limitations` block: donor second-hand, `APPROX_ATLAS_PACKING`, UNVERIFIED runtime,
  no GPU A/B, intentional duplication with `game.gd`, SP-3 separation.
- `visual_parity_claim: false`; label set `DONOR_INDEX_CITED_SECOND_HAND`,
  `DONOR_ART_ALIAS_CITED_SECOND_HAND`, `PORT_APPROXIMATION`, `UNVERIFIED`,
  `NO_VISUAL_PARITY_CLAIM`.

## 5. Which Summer ids map

**All 124 Summer ids (0–123) map.** No Summer name is left unmapped and no Winter alias
is orphaned. `shared alpha` = the donor Winter preset keeps that name unchanged while
`tiles.mat` still supplies a `_winter` art alias. `green grass` = donor maps it to
`winter25.png` (0 % snow); mapped for fidelity, flagged against use as a snow base.

| idx | summer name | winter alias | source png | kind | note |
|---:|---|---|---|---|---|
| 0 | `grass1` | `grass1_winter` | `winter10.png` | WINTER_PNG | — |
| 1 | `grass2` | `grass2_winter` | `winter9.png` | WINTER_PNG | — |
| 2 | `grass3` | `grass3_winter` | `winter2.png` | WINTER_PNG | — |
| 3 | `grass4` | `grass4_winter` | `winter3.png` | WINTER_PNG | — |
| 4 | `grass5` | `grass5_winter` | `winter4.png` | WINTER_PNG | — |
| 5 | `grass6` | `grass6_winter` | `winter16.png` | WINTER_PNG | — |
| 6 | `grass7` | `grass7_winter` | `winter1.png` | WINTER_PNG | — |
| 7 | `grass8` | `grass8_winter` | `winter21.png` | WINTER_PNG | — |
| 8 | `grass9` | `grass9_winter` | `winter0.png` | WINTER_PNG | — |
| 9 | `grass10` | `grass10_winter` | `winter0.png` | WINTER_PNG | — |
| 10 | `ground1` | `ground1_winter` | `winter11.png` | WINTER_PNG | — |
| 11 | `grass_sand1` | `grass_sand1_winter` | `winter21.png` | WINTER_PNG | — |
| 12 | `grass_sand2` | `grass_sand2_winter` | `winter1.png` | WINTER_PNG | — |
| 13 | `grass_rock1` | `grass_rock1_winter` | `winter9.png` | WINTER_PNG | — |
| 14 | `grass_ground1` | `grass_ground1_winter` | `winter5.png` | WINTER_PNG | — |
| 15 | `grass_ground2` | `grass_ground2_winter` | `winter4.png` | WINTER_PNG | — |
| 16 | `grass_ground3` | `grass_ground3_winter` | `winter5.png` | WINTER_PNG | — |
| 17 | `rock1` | `rock1_winter` | `winter12.png` | WINTER_PNG | — |
| 18 | `rock2` | `rock2_winter` | `winter13.png` | WINTER_PNG | — |
| 19 | `rock3` | `rock3_winter` | `winter13.png` | WINTER_PNG | — |
| 20 | `rock4` | `rock4_winter` | `winter17.png` | WINTER_PNG | — |
| 21 | `rock5` | `rock5_winter` | `winter22.png` | WINTER_PNG | — |
| 22 | `rock6` | `rock6_winter` | `winter15.png` | WINTER_PNG | — |
| 23 | `rock7` | `rock7_winter` | `winter14.png` | WINTER_PNG | — |
| 24 | `rock8` | `rock8_winter` | `winter16.png` | WINTER_PNG | — |
| 25 | `rock9` | `rock9_winter` | `winter20.png` | WINTER_PNG | — |
| 26 | `sand1` | `sand1_winter` | `winter10.png` | WINTER_PNG | — |
| 27 | `sand2` | `sand2_winter` | `winter10.png` | WINTER_PNG | — |
| 28 | `sand3` | `sand3_winter` | `winter20.png` | WINTER_PNG | — |
| 29 | `sand4` | `sand4_winter` | `winter10.png` | WINTER_PNG | — |
| 30 | `sand5` | `sand5_winter` | `winter0.png` | WINTER_PNG | — |
| 31 | `sand6` | `sand6_winter` | `winter0.png` | WINTER_PNG | — |
| 32 | `sand7` | `sand7_winter` | `winter0.png` | WINTER_PNG | — |
| 33 | `sand8` | `sand8_winter` | `winter0.png` | WINTER_PNG | — |
| 34 | `sand9` | `sand9_winter` | `winter0.png` | WINTER_PNG | — |
| 35 | `sand1f` | `sand1f_winter` | `winter0.png` | WINTER_PNG | — |
| 36 | `sand1s` | `sand1s_winter` | `winter25.png` | WINTER_PNG | green grass |
| 37 | `sand2f` | `sand2f_winter` | `winter0.png` | WINTER_PNG | — |
| 38 | `sand2s` | `sand2s_winter` | `winter0.png` | WINTER_PNG | — |
| 39 | `sand3f` | `sand3f_winter` | `winter1.png` | WINTER_PNG | — |
| 40 | `sand3s` | `sand3s_winter` | `winter0.png` | WINTER_PNG | — |
| 41 | `sand4f` | `sand4f_winter` | `winter10.png` | WINTER_PNG | — |
| 42 | `sand4s` | `sand4s_winter` | `winter0.png` | WINTER_PNG | — |
| 43 | `sand5f` | `sand5f_winter` | `winter0.png` | WINTER_PNG | — |
| 44 | `sand5s` | `sand5s_winter` | `winter1.png` | WINTER_PNG | — |
| 45 | `sand6f` | `sand6f_winter` | `winter1.png` | WINTER_PNG | — |
| 46 | `sand6s` | `sand6s_winter` | `winter1.png` | WINTER_PNG | — |
| 47 | `sand7f` | `sand7f_winter` | `winter1.png` | WINTER_PNG | — |
| 48 | `sand7s` | `sand7s_winter` | `winter1.png` | WINTER_PNG | — |
| 49 | `sand8f` | `sand8f_winter` | `winter0.png` | WINTER_PNG | — |
| 50 | `sand8s` | `sand8s_winter` | `winter2.png` | WINTER_PNG | — |
| 51 | `sand9f` | `sand9f_winter` | `winter1.png` | WINTER_PNG | — |
| 52 | `sand9s` | `sand9s_winter` | `winter2.png` | WINTER_PNG | — |
| 53 | `rock1vf` | `rock1vf_winter` | `winter12.png` | WINTER_PNG | — |
| 54 | `rock1vs` | `rock1vs_winter` | `winter12.png` | WINTER_PNG | — |
| 55 | `rock2vf` | `rock2vf_winter` | `winter13.png` | WINTER_PNG | — |
| 56 | `rock2vs` | `rock2vs_winter` | `winter13.png` | WINTER_PNG | — |
| 57 | `rock3vf` | `rock3vf_winter` | `winter13.png` | WINTER_PNG | — |
| 58 | `rock3vs` | `rock3vs_winter` | `winter13.png` | WINTER_PNG | — |
| 59 | `rock4vf` | `rock4vf_winter` | `winter17.png` | WINTER_PNG | — |
| 60 | `rock4vs` | `rock4vs_winter` | `winter17.png` | WINTER_PNG | — |
| 61 | `rock5vf` | `rock5vf_winter` | `winter22.png` | WINTER_PNG | — |
| 62 | `rock5vs` | `rock5vs_winter` | `winter22.png` | WINTER_PNG | — |
| 63 | `rock6vf` | `rock6vf_winter` | `winter15.png` | WINTER_PNG | — |
| 64 | `rock6vs` | `rock6vs_winter` | `winter15.png` | WINTER_PNG | — |
| 65 | `rock7vf` | `rock7vf_winter` | `winter14.png` | WINTER_PNG | — |
| 66 | `rock7vs` | `rock7vs_winter` | `winter14.png` | WINTER_PNG | — |
| 67 | `rock8vf` | `rock8vf_winter` | `winter16.png` | WINTER_PNG | — |
| 68 | `rock8vs` | `rock8vs_winter` | `winter16.png` | WINTER_PNG | — |
| 69 | `rock9vf` | `rock9vf_winter` | `winter20.png` | WINTER_PNG | — |
| 70 | `rock9vs` | `rock9vs_winter` | `winter20.png` | WINTER_PNG | — |
| 71 | `test0` | `test0_winter` | `winter4.png` | WINTER_PNG | — |
| 72 | `test1` | `test1_winter` | `winter6.png` | WINTER_PNG | — |
| 73 | `test2` | `test2_winter` | `winter7.png` | WINTER_PNG | — |
| 74 | `test3` | `test3_winter` | `winter8.png` | WINTER_PNG | — |
| 75 | `test4` | `test4_winter` | `winter0.png` | WINTER_PNG | — |
| 76 | `test5` | `test5_winter` | `winter10.png` | WINTER_PNG | — |
| 77 | `test6` | `test6_winter` | `winter4.png` | WINTER_PNG | — |
| 78 | `test7` | `test7_winter` | `winter10.png` | WINTER_PNG | — |
| 79 | `test8` | `test8_winter` | `winter21.png` | WINTER_PNG | — |
| 80 | `test9` | `test9_winter` | `winter10.png` | WINTER_PNG | — |
| 81 | `test10` | `test10_winter` | `winter0.png` | WINTER_PNG | — |
| 82 | `test11` | `test11_winter` | `winter1.png` | WINTER_PNG | — |
| 83 | `test12` | `test12_winter` | `winter5.png` | WINTER_PNG | — |
| 84 | `test13` | `test13_winter` | `winter5.png` | WINTER_PNG | — |
| 85 | `test14` | `test14_winter` | `winter5.png` | WINTER_PNG | — |
| 86 | `alpha0a` | `alpha0a_winter` | `winter0.png` | WINTER_PNG | shared alpha |
| 87 | `sandrock1` | `sandrock1_winter` | `winter1.png` | WINTER_PNG | — |
| 88 | `sandrock2` | `sandrock2_winter` | `winter10.png` | WINTER_PNG | — |
| 89 | `sandrock3` | `sandrock3_winter` | `winter19.png` | WINTER_PNG | — |
| 90 | `sandrock4` | `sandrock4_winter` | `winter19.png` | WINTER_PNG | — |
| 91 | `sandrock5` | `sandrock5_winter` | `winter1.png` | WINTER_PNG | — |
| 92 | `sandrock6` | `sandrock6_winter` | `winter0.png` | WINTER_PNG | — |
| 93 | `sandsea1` | `sandsea1_winter` | `winter19.png` | WINTER_PNG | — |
| 94 | `sandsea2` | `sandsea2_winter` | `winter2.png` | WINTER_PNG | — |
| 95 | `sandsea3` | `sandsea3_winter` | `winter2.png` | WINTER_PNG | — |
| 96 | `sandsea4` | `sandsea4_winter` | `winter19.png` | WINTER_PNG | — |
| 97 | `sandsea5` | `sandsea5_winter` | `winter19.png` | WINTER_PNG | — |
| 98 | `sandsea6` | `sandsea6_winter` | `winter3.png` | WINTER_PNG | — |
| 99 | `test15` | `test15_winter` | `winter10.png` | WINTER_PNG | — |
| 100 | `test16` | `test16_winter` | `winter10.png` | WINTER_PNG | — |
| 101 | `test17` | `test17_winter` | `winter10.png` | WINTER_PNG | — |
| 102 | `test18` | `test18_winter` | `winter7.png` | WINTER_PNG | — |
| 103 | `test19` | `test19_winter` | `winter8.png` | WINTER_PNG | — |
| 104 | `test20` | `test20_winter` | `winter0.png` | WINTER_PNG | — |
| 105 | `test21` | `test21_winter` | `winter25.png` | WINTER_PNG | green grass |
| 106 | `test22` | `test22_winter` | `winter1.png` | WINTER_PNG | — |
| 107 | `test23` | `test23_winter` | `winter25.png` | WINTER_PNG | green grass |
| 108 | `test24` | `test24_winter` | `winter10.png` | WINTER_PNG | — |
| 109 | `test25` | `test25_winter` | `winter25.png` | WINTER_PNG | green grass |
| 110 | `alpha0b` | `alpha0b_winter` | `winter1.png` | WINTER_PNG | shared alpha |
| 111 | `desert1` | `desert1_winter` | `desert1.png` | DESERT_REUSE | — |
| 112 | `desert2` | `desert2_winter` | `desert2.png` | DESERT_REUSE | — |
| 113 | `desert3` | `desert3_winter` | `desert3.png` | DESERT_REUSE | — |
| 114 | `desert4` | `desert4_winter` | `desert4.png` | DESERT_REUSE | — |
| 115 | `desert5` | `desert5_winter` | `desert5.png` | DESERT_REUSE | — |
| 116 | `desert6` | `desert6_winter` | `desert6.png` | DESERT_REUSE | — |
| 117 | `desert7` | `desert7_winter` | `desert7.png` | DESERT_REUSE | — |
| 118 | `desert8` | `desert8_winter` | `desert8.png` | DESERT_REUSE | — |
| 119 | `desert9` | `desert9_winter` | `desert9.png` | DESERT_REUSE | — |
| 120 | `desert10` | `desert10_winter` | `desert10.png` | DESERT_REUSE | — |
| 121 | `desert11` | `desert11_winter` | `desert11.png` | DESERT_REUSE | — |
| 122 | `desert12` | `desert12_winter` | `desert12.png` | DESERT_REUSE | — |
| 123 | `alpha0c` | `alpha0c_winter` | `winter1.png` | WINTER_PNG | shared alpha |

## 6. Coverage of all 27 on-disk `winterN.png`

`alias_count` = how many of the 124 Summer ids resolve to that art file.
**23 referenced, 4 deliberately unmapped** (27 total; no gaps in 0–26).

| file | alias_count | status | note |
|---|---:|---|---|
| `winter0.png` | 19 | MAPPED | — |
| `winter1.png` | 15 | MAPPED | — |
| `winter2.png` | 5 | MAPPED | — |
| `winter3.png` | 2 | MAPPED | — |
| `winter4.png` | 4 | MAPPED | — |
| `winter5.png` | 5 | MAPPED | — |
| `winter6.png` | 1 | MAPPED | — |
| `winter7.png` | 2 | MAPPED | — |
| `winter8.png` | 2 | MAPPED | — |
| `winter9.png` | 2 | MAPPED | — |
| `winter10.png` | 13 | MAPPED | — |
| `winter11.png` | 1 | MAPPED | — |
| `winter12.png` | 3 | MAPPED | — |
| `winter13.png` | 6 | MAPPED | — |
| `winter14.png` | 3 | MAPPED | — |
| `winter15.png` | 3 | MAPPED | — |
| `winter16.png` | 4 | MAPPED | — |
| `winter17.png` | 3 | MAPPED | — |
| `winter18.png` | 0 | UNMAPPED_DONOR_UNALIASED | No tiles.mat alias (winter_variant.md:88); deliberately unmapped - no replacement invented (SEASON_PLAN-01 Q1/B1) |
| `winter19.png` | 5 | MAPPED | — |
| `winter20.png` | 4 | MAPPED | — |
| `winter21.png` | 3 | MAPPED | — |
| `winter22.png` | 3 | MAPPED | — |
| `winter23.png` | 0 | UNMAPPED_DONOR_UNALIASED | No tiles.mat alias (winter_variant.md:88); deliberately unmapped - no replacement invented (SEASON_PLAN-01 Q1/B1) |
| `winter24.png` | 0 | UNMAPPED_DONOR_UNALIASED | No tiles.mat alias (winter_variant.md:88); deliberately unmapped - no replacement invented (SEASON_PLAN-01 Q1/B1) |
| `winter25.png` | 4 | MAPPED | Green grass, 0% snow (winter_variant.md:86); mapped only for sand1s/test21/test23/test25 - not a snow base |
| `winter26.png` | 0 | UNMAPPED_DONOR_UNALIASED | No tiles.mat alias (winter_variant.md:88); deliberately unmapped - no replacement invented (SEASON_PLAN-01 Q1/B1) |

Cross-check with the existing Summer manifest: its three empty cells are indices
**86 (`alpha0a`), 110 (`alpha0b`), 123 (`alpha0c`)** (S7 `:3019-3048`; S4 §3). These are
exactly the three entries flagged `shared_alpha: true` here; their `source_png` values
(`winter0.png`/`winter1.png`/`winter1.png`) are **donor alias carriers only** — this JSON
does not fabricate a shipped PNG or claim those atlas cells become filled in Winter.

## 7. Deliberately unmapped, and why

| Item | Decision | Reason |
|---|---|---|
| `winter18.png`, `winter23.png`, `winter24.png`, `winter26.png` | **unmapped** (`status: UNMAPPED_DONOR_UNALIASED`, `alias_count: 0`) | No `tiles.mat` alias exists (S5 `:88`, S2 §3.3). Picking a replacement would be **invented** art selection — forbidden by S1 Q1/B1. They remain listed in `winter_png_inventory` so the 27/27 coverage is explicit. |
| Preset index for any `winterN.png` | **not assigned** | Donor Winter is a 1:1 same-index rename (S1 §4.3). `winter10.png` is texture art for index 0 (`grass1`), **not** preset index 10. No index was derived from a filename. |
| `presets_winter.json` | **not created** | SP-2's exclusive output is `atlas/winter_aliases.json`; a second preset table would duplicate ids and break the "no invented index" rule (S1 §3.3, B4). |
| Winter atlas PNG / manifest | **not generated** | SP-4 scope; ~180 MB PNG / 512 MiB RGBA8, LFS/parts transport undecided (S1 B2, S4 §6/§8). |
| `winter25.png` as a snow base | **mapped but flagged** | Donor aliases `sand1s`/`test21`/`test23`/`test25` do reach it (S5 `:84-86`), so omitting it would be unfaithful; it is green grass, 0 % snow, and must not be chosen as a snow tile. |
| Desert height `koef=0.8`, mine `s`, rock8 gate | **not encoded** | SP-3 (`desert_remap.json`) scope; this file records only art aliases for the 12 reused `desertN.png`. |
| Prop material `w` families | **not encoded** | Different suffix and different files; no `fir1w`/`field1w` art on disk (S1 B1b). |

## 8. JSON validation

Commands run with the environment's `python` (3.14), from the repo root:

```
python -c "import json; json.load(open(r'...\variant3d\assets\terrain\atlas\winter_aliases.json', encoding='utf-8'))"
```

Result: `JSON parse OK` — repeated after the header-key alignment edit
(`id=WINTER-ALIASES-01`, `schema_version=1`, `entries=124`).

Invariants checked programmatically (all PASS):

| Check | Result |
|---|---|
| `entries` count / `index` sequence | 124 / `0…123` contiguous |
| `entries[].name` order == `presets_summer.json` | `True` |
| Every `winter_alias` == `name + "_winter"` | `True` (124/124) |
| Every `source_png` exists in `assets/terrain/blocks/` | `True` (0 missing) |
| Distinct winter targets / desert targets | 23 / 12 (= 35 textures) |
| On-disk winter PNGs / inventory rows | 27 / 27 |
| `DESERT_REUSE` entries | 12 |
| `shared_alpha` indices | `[86, 110, 123]` (matches manifest empty cells) |

No `.py` helper was written into the repo; the two throwaway probes live outside it in
`%LOCALAPPDATA%\Temp\opencode\`.

## 9. Open questions (do not guess)

1. **Q1** What should the 4 donor-unaliased winter PNGs (`winter18/23/24/26`) do in a
   future Winter atlas? No donor alias selects them; SP-4 must either pack them as
   unreachable art or explicitly list them unused. **UNVERIFIED** — no replacement chosen.
2. **Q2** Should `winter25.png` be reachable at all given it is green grass? Kept mapped
   for donor fidelity and flagged; a renderer may legitimately exclude it from snow
   selection, but that is a policy decision, not a data correction.
3. **Q3** For `alpha0a/b/c`, the donor preset shares the name while `tiles.mat` supplies
   `_winter` art aliases. Whether a renderer should swap art on those mask-carrier cells
   is engine-side and **UNVERIFIED** (DEC-05 §4.6 / DENV-01 Q6). This JSON only records
   the alias.
4. **Q4** Single source of truth: this JSON duplicates `game.gd:1617-1657 WINTER_ART`.
   Consolidation (S1 B4/Q3) needs TRN-DATA coordination; duplication is intentional.
5. **Q5** Do the `;`-prefixed `texturemap.inc` season lines execute in the shipped donor
   build? Literal rule is observed; runtime activity **UNVERIFIED** (S1 B6, S2 Q6).
6. **Q6** Which transport (Git LFS vs `atlas_parts`-style split) a future Winter atlas
   uses is a COORD decision (S1 Q4; S4 §6/§8). Not decided here.
7. **Q7** No donor GPU A/B was run. Grain/atlas differences must be asserted structurally
   (S1 B3/SP-8), never as "looks donor-like".

## 10. Summary

**One new data file delivered:** `variant3d/assets/terrain/atlas/winter_aliases.json`
with **exactly 124 entries**, indices **0–123** taken from `presets_summer.json`, each
carving a Summer name to its donor `_winter` alias (`texturemap.inc:525-526,605-606`,
`terrain.presets:134-263`) and to on-disk art resolved via `tiles.mat` (S5 §1.2).
**All 124 Summer ids map**; 112 resolve to `winterN.png` art (23 distinct files) and 12
reuse `desertN.png` unchanged. **All 27** on-disk `winterN.png` are covered in
`winter_png_inventory`: **23 referenced, 4 deliberately unmapped** (`winter18/23/24/26`,
no donor alias — no replacement invented). The three alpha mask carriers are flagged
shared and match the manifest's empty cells 86/110/123.

Validation: `python -c json.load` PASS plus eight invariant checks PASS. No index was
invented, no donor parity claimed for unpacked art, and all donor citations are marked
second-hand. Labels `PORT APPROXIMATION` / `UNVERIFIED` / `NO_VISUAL_PARITY_CLAIM` are
retained.

**No other file edited.** Donor not opened, copied or executed; no code, shader, test,
harness, config or existing asset changed; no Godot runner job; no git state change by
this ticket.

*End of SP-02. Two files written: the JSON and this report.*
