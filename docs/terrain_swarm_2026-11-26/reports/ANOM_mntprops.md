---
id: ANOM_mntprops
ticket: "DEBUG run ticket 180 — relief bind props=0 batches=0 stamps=92 matched=0 (mediterranean/hills seed)"
agent: "worker ANOM-MNTPROPS (full 1:1 Cossacks 3 donor port, READ-ONLY, 2026-11-26)"
created: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_CODE_OR_ASSET_EDIT__NO_GODOT_JOB
owner_file: docs/terrain_swarm_2026-11-26/reports/ANOM_mntprops.md
labels: [O, D, I, U, "PORT APPROXIMATION"]
donor: "C:\\Games\\Cossacks 3 read in place only (text scan; no donor binary executed, copied or committed)"
scope: "Read-only decompilation: why exact-name relief-prop match yields matched=0 on a 92-stamp mediterranean/hills seed; which donor patterns carry terrainmesh1..4; whether mountains are recipe-reachable on this map; whether the 30-key port table misses any byte-proven association. Exactly one file written; no code/Godot/git/donor-execution."
priors_read:
  - variant3d/assets/terrain/mountain_props.json (header :1-17, by_pattern :18-191, pattern_meta :192-403, props records e.g. :404-470, derived_stats :2594-2661)
  - variant3d/scripts/world3d_relief.gd (:42 table, :51 RELIEF_SIDS, :94 bind log, :152-157 exact-name match, :158-173 sid/mesh gates)
  - docs/terrain_swarm_2026-11-26/reports/F02_pattern_lib.md (§5.3-5.4, E10/E18)
  - docs/terrain_swarm_2026-11-26/reports/F03_gen_config.md (§7.3 :711-713/:752, §7.2 :686-688)
  - docs/terrain_swarm_2026-11-26/reports/X03_dscript_corpus.md (Stage 8 D1:1621-1772, D1:1747-1766 call sites)
  - docs/terrain_swarm_2026-11-26/reports/DEC_DEEP_forest_generation.md (§4 D1:1540-1600, §10)
  - docs/terrain_swarm_2026-11-26/reports/X57_env_objects_decode.md (§4.2 E11, D1:398/:1749-1766)
  - docs/terrain_swarm_2026-11-26/reports/A04_landscape_props.md (E02/E03/E08, §mountains)
  - docs/terrain_swarm_2026-11-26/reports/V07_relief_asset_readiness.md (E03/E04, M4, §4 mountains row)
  - docs/terrain_swarm_2026-11-26/reports/COMPACT_PATTERNS_offline.md (:41-42 desert_mnt_14/15)
parity_guard: "Parity UNVERIFIED. No donor GPU A/B frame exists (CHARTER §3/§5). Nothing here is a donor-parity verdict. Chain 0/6. RESULT IS NOT GOOD."
---

# ANOM_mntprops — ticket 180 `matched=0` read-only decompilation

> `[O]` literal bytes/lines observed this pass (repo file `path:line` or donor `path:line` as transcribed in a landed report) · `[D]` deterministic set-difference/arithmetic over observed data · `[I]` best reading without an engine run · `[U]` UNVERIFIED · `PORT APPROXIMATION` = explicit port substitute, never donor truth. No donor binary was run/copied; no Godot job was submitted; no source/asset/test/config/git edit was made; only this report was written.

## 1. Verdict

1. **[D] `matched=0` is CORRECT for the described 92-stamp sample and says nothing about the recipe in general.** The port consumer matches `st.name` exactly against the 30 table keys (`variant3d/scripts/world3d_relief.gd:152-157`); the ticket's stamp families (forests/stone/hill/decor/plateau/plain) name none of the 30 keys, so `matched_stamps` must stay 0 and `props=0 batches=0` follows. This is a sample outcome, not a proof that mountains never occur on mediterranean/hills.
2. **[O]/[D] Mountains ARE recipe-reachable on a temperate (non-desert) mediterranean map.** The temperate arm of the shipped relief stage always issues `_misc_SetupPatternsByType(pGenerator, envplHnd, 'mountains', mnt)` (X03 Stage 8, `C:\Games\Cossacks 3\data\scripts\common.inc\dogenerate.inc:1758`), and every `relieftype 0..4` row sets `mnt > 0` (`dogenerate.inc:1621-1650`). `mediterranean` is a `TerrainTypes` shape-folder hint (`C:\Games\Cossacks 3\data\game\var\generator.cfg:8-10`), orthogonal to the `relieftype` roulette (`dogenerate.inc:1621-1622`). No landed donor text excludes `g_mnt_*` from mediterranean.
3. **[D] No byte-proven donor association is missing from the 30-key table that could be added from static data alone.** The landed full-lib census is 112 records / 30 sections (`mountain_props.json:2594-2596`); the 17 `terrainmesh1..4` patterns and 13 `terrainmeshdesert*` patterns below exhaust it. `desert_mnt_14/15` have cfg refs but no `pattern.lib` section (nothing static to add); `i_mnt_*` are already in the table though family-unreachable; plateau has zero `BaseName` refs (correctly excluded). Do NOT invent a 31st association.

## 2. Evidence table

| ID | Evidence (repo `path:line`, donor `path:line`) | Label | Establishes |
|---|---|---|---|
| E01 | `variant3d/scripts/world3d_relief.gd:42` (`PROP_TABLE`), `:51` (`RELIEF_SIDS=terrainmesh1..4`), `:94` bind log format `props=%d batches=%d stamps=%d matched=%d`, `:152-157` exact-name gate (`st_name` empty-or-absent → skip; else `matched_stamps+1`), `:158-173` per-record sid/mesh gates | [O] | Zero-match mechanics: match is case-sensitive exact `has(st_name)`; hill/forest/stone/decor/plateau/plain names cannot hit |
| E02 | `variant3d/assets/terrain/mountain_props.json:1-17` header (`source=data/pattern/pattern.lib`, `source_sha256=f7b421b1…`, selection `PORT APPROX`), `:18-191` `by_pattern` 30 keys, `:192-403` `pattern_meta` section_lines, `:2594-2661` `derived_stats` (30 sections / 112 records / 20 port-stampable / 45 records / plateau 0) | [O] | Table scope: 30 keys = 7 `g_mnt_*` + 13 `desert_mnt_*` + 10 `i_mnt_*`; only 20/45 stampable per derived stats |
| E03 | Donor sections carrying `terrainmesh1..4` (section `Name` → `C:\Games\Cossacks 3\data\pattern\pattern.lib:<section_line>` from E02 `pattern_meta`, cross-checked to F02 §5.4 byte ranges and A04 E02/E03): `g_mnt_1:337461`, `g_mnt_2:340275`, `g_mnt_3:342333`, `g_mnt_4:345119`, `g_mnt_5:346869`, `g_mnt_6:349375`, `g_mnt_7:352189`, `i_mnt_big_1:391809`, `i_mnt_big_3:397787`, `i_mnt_big_4:405949`, `i_mnt_big_5:415035`, `i_mnt_big_2:423477`, `i_mnt_long_1:432899`, `i_mnt_long_2:441369`, `i_mnt_long_3:445779`, `i_mnt_long_4:453465`, `i_mnt_long_5:460479`; exemplar record lines `g_mnt_1:338480` (`BaseName=terrainmesh4`, F02 E10, byte 8733756), `g_mnt_1:338872/339320/339684/339852`, `g_mnt_3:343100/343828/344360/344668`, `g_mnt_5:347804/348112/348588/348756` (E02 `props[].line`) | [O] observed JSON literals / [D] donor line mapping via landed census | (1) Complete `terrainmesh1..4` carrier list: 17 patterns. `desert_mnt_*` carry only `terrainmeshdesert1..4` (E02 `:405-866`, e.g. `desert_mnt_1:1088428/1088456`), never `terrainmesh1..4` |
| E04 | `C:\Games\Cossacks 3\data\game\var\generator.cfg:660` family `mountains` = `g_mnt_1..7` (F03 §7.3 :711); `:693` `hills_dark` = `hil1..4` (F03 :712); `:714` `hills_light` = `g_hil1..9` (F03 :713); `:1867` `desert_mountains` = `desert_mnt_1..15` (F03 :752); F02 §5.3: only 13 `desert_mnt_*` lib sections exist, 4 refs unresolved (`desert_mnt_14`, `desert_mnt_15`, `k_plain_mid_12a/b`), and 217 sections incl. all `i_mnt_*` are in NO family | [O] landed transcription | Family membership: hills families never contain a terrainmesh carrier; only `g_mnt_*` (temperate) / `desert_mnt_*` (desert) are recipe members; `i_mnt_*` unreachable via cfg |
| E05 | `C:\Games\Cossacks 3\data\scripts\common.inc\dogenerate.inc:1621-1650` relieftype table (`0: plt 0.000010/mnt 0.000020/hil 0.000075`; `1: 0.000020/0.000002/0.000125`; `2: 0.000075/0.000075/0.000030`; `3: 0.000055/0.000120/0.000050`; `4: 0.000090/0.000035/0.000035`); `:1621-1622` random `relieftype := floor(RandomExt*5)` when `>4`; `:1737-1739` `mnt/plt/hil *= problarge`; temperate arm `:1758-1766` stamps `mountains/hill_dark/hill_light/plateau(_big/small)/plain_huge/ravine_big` with `mnt`, `plt/3`, `plt/1.5`, `hil/2`; desert arm `:1749-1753` stamps `desert_mountains/desert_plateau*` instead; `:1760` `ravine_medium` commented out | [O] as transcribed in X03 Stage 8 (donor lines carry `[*] = ;` text prefix; consumer semantics [U] per F03 F15) | (2) `mnt` is never zeroed by relieftype; temperate arm always offers the `mountains` group; `bDesert` (season==3) selects the arm, not the shape folder |
| E06 | `C:\Games\Cossacks 3\data\game\var\generator.cfg:2-11` `TerrainTypes[1].hint=1.Mediterranean path=.\data\gen\terrainmasks\mediterranean` (F03 §3.6 :312-325); `dogenerate.inc:1542-1565` terraintype→path→`StringRegister0`→`GenerateMap` (D03 E03); shape is a mask-folder choice, relief groups are stamped later at `:1747-1766` | [O] landed transcription | mediterranean selects masks, not relief families; no text ties mediterranean to exclusion of `mountains` |
| E07 | `variant3d/assets/terrain/mountain_props.json:2650-2660` `base_name_census` (`terrainmesh1:14/2:21/3:29/4:25`, desert `1:2/2:5/3:7/4:9`) + `plateau_records:0`; `world3d_relief.gd:33-34` `terrainplateau1..4` deliberately skipped (no albedo/.prop/`pattern.lib` link); COMPACT_PATTERNS_offline `:41-42` (`desert_mnt_14/15` unresolved); F02 §5.3 normaliser collisions/residuals | [O] | (3) Census closure: no 31st carrier in any landed scan (F02 E18: 39,780 records / 235 BaseNames); desert 14/15 and plateau add nothing static |
| E08 | V07 §4 mountains row + M4 (`mountain_props.json` 66,519 B / 112 records; only 22/45 stampable records use converted `terrainmesh1..4` sids, 23 desert records hit `skipped_unknown_sid` at `world3d_relief.gd:166-167`); A04 E08 (112 records / 30 sections / 20 stampable / 45 records) | [O] prior landed census | Table completeness and the desert-sid blind spot are already closed knowledge; nothing new to append |

## 3. Findings

### 3.1 (1) — donor patterns whose `Objects[]` carry `terrainmesh1..4` — exact names

**[O]/[D] 17 patterns. Donor path for every entry is `C:\Games\Cossacks 3\data\pattern\pattern.lib`. Section lines are E02 `pattern_meta.section_line` literals (1-based lib lines); record lines are E02 `props[].line` literals for the same pattern.**

| # | Pattern (table key) | Section line (`pattern.lib:<line>`, E02) | `terrainmeshN` bases in order (E02 `by_pattern`) | Exemplar record `line`s (E02 `props`) |
|---:|---|---|---|---|
| 1 | `g_mnt_1` | `:337461` | 4,3,2,4,3 | `:338480,:338872,:339320,:339684,:339852` |
| 2 | `g_mnt_2` | `:340275` | 3,4 | `:341378,:341406` |
| 3 | `g_mnt_3` | `:342333` | 2,4,1,3 | `:343100,:343828,:344360,:344668` |
| 4 | `g_mnt_4` | `:345119` | 2 | `:346138` |
| 5 | `g_mnt_5` | `:346869` | 3,3,2,1 | `:347804,:348112,:348588,:348756` |
| 6 | `g_mnt_6` | `:349375` | 2,4,3,3 | `:350198,:350982,:351290,:351514` |
| 7 | `g_mnt_7` | `:352189` | 3,1 | `:353712,:356904` |
| 8 | `i_mnt_big_1` | `:391809` | 2,3,4,2,3,3,4,1 | `:392856,:393696,:394004,:394200,:394844,:394900,:395348,:396608` |
| 9 | `i_mnt_big_3` | `:397787` | 2,4,3,3 | `:401970,:402222,:403678,:404098` |
| 10 | `i_mnt_big_4` | `:405949` | 1,2,4,2,3 | `:408144,:408368,:409180,:412400,:413856` |
| 11 | `i_mnt_big_5` | `:415035` | 3,2,3,4,4 | `:419106,:419694,:420618,:420842,:421150` |
| 12 | `i_mnt_big_2` | `:423477` | 2,4,3,1,3,1 | `:425560,:426428,:426624,:427800,:429256,:431020` |
| 13 | `i_mnt_long_1` | `:432899` | 1,3,2,3,4,4,2 | `:434618,:435206,:436746,:437250,:438706,:439434,:440106` |
| 14 | `i_mnt_long_2` | `:441369` | 4,3,4,1,3,1,2,3 | `:441940…` (E02 props block) |
| 15 | `i_mnt_long_3` | `:445779` | 4,3,4,1,2,4,4 | E02 `props.i_mnt_long_3` |
| 16 | `i_mnt_long_4` | `:453465` | 4,3,2,4,3,1,1,4 | E02 `props.i_mnt_long_4` |
| 17 | `i_mnt_long_5` | `:460479` | 2,2,2,4,3,3,2,1,4 | E02 `props.i_mnt_long_5` (`:466902` tail) |

**[D] Explicit non-carriers:** the 13 `desert_mnt_1..13` sections (`:1087549,:1088991,:1089817,:1090587,:1091329,:1091903,:1092505,:1093107,:1093793,:1094395,:1095249,:1096187,:1097209`) carry ONLY `terrainmeshdesert1..4` (E02 `:19-67`, `:405-866`) and must not be cited as `terrainmesh1..4` evidence. Hills families (`hil1..4`, `g_hil1..9`) carry no `terrainmesh*` BaseName in any landed census (E04/E07).

### 3.2 (2) — reachability on a `mediterranean/hills` map; is `matched=0` correct?

- **[O]** The ticket's stamp families (forests/stone/hill/decor/plateau/plain) resolve in cfg terms to `forests_*`, `stones`/`stoneforests*`, `hills_dark`/`hills_light`, `decor`/`decor_big`, `plateau*`/`plain_*` (E04). None of those families contains a §3.1 name, and E01 matches by exact key — so **[D] `matched=0` is the only correct outcome for that 92-stamp list.** `props=0 batches=0` is then mechanical (no matched stamp → no records → no batches).
- **[D] That correctness is sample-local, NOT recipe-general.** Per E05 the temperate relief arm always calls the `mountains` group (`dogenerate.inc:1758`) with `mnt>0` in every relieftype row (`:1621-1650`; smallest `mnt=0.000002` at relieftype 1, never 0), scaled by `problarge` (`:1737`). A seed can therefore stamp `g_mnt_1..7` on any temperate map, mediterranean included. `mediterranean` only picks the mask folder (E06); `hills` only raises the `hil` roulette weight — neither gate removes the `mountains` call.
- **[O]/[D] DLC/desert confinement applies to the OTHER carriers, not to `g_mnt_*`.** `desert_mnt_*` are stamped only in the `bDesert` arm (`dogenerate.inc:1749`); a temperate mediterranean seed never offers them, so their 23 records correctly contribute `skipped_unknown_sid` rather than props even when a mountain stamp does occur (V07 M4). All `i_mnt_*` are in NO cfg family (E04/F02 §5.3) so the shipped `SetupPatternsByType` recipe never names them — they sit in the port table (E02) but are recipe-unreachable on ANY shipped map. Hills patterns (`hil*`/`g_hil*`) are stamped via `hil/2` (`dogenerate.inc:1764-1765`) and carry relief height, not `terrainmesh*` props.
- **[U] What is NOT proven:** which `relieftype` value (or fixed override) the ticket-180 seed used; the realised `mnt/plt/hil/problarge` floats for that seed; the RNG/stream position at the relief stage (D02 owns streams); whether the port's 92-stamp generator implements the E05 fan-out faithfully. No claim is made that the donor would also stamp zero mountains on this seed — only that the port's exact-name bind is consistent with the port's stamp list.

### 3.3 (3) — any missing byte-proven association addable from static data alone?

**[D] No. The 30-key table is already complete against every landed static census:**

1. 112 records / 30 sections is the closed census (E02 `:2594-2596`; A04 E08; V07 M4). All 89 `terrainmesh1..4` records (14+21+29+25, E07) live inside the §3.1 seventeen; all 23 desert records live inside the 13 `desert_mnt_*`. No landed full-lib scan (F02 E18: 39,780 records / 235 BaseNames) names a 31st `terrainmesh*` carrier.
2. `desert_mnt_14` / `desert_mnt_15` are cfg refs (`generator.cfg:1867`, F03 :752) with NO `pattern.lib` section (F02 §5.3; COMPACT_PATTERNS_offline :41-42). There is no static `Objects[]` block to copy — nothing to add.
3. `i_mnt_big_*` / `i_mnt_long_*` (67 records) are ALREADY in the table (E02) despite being family-unreachable (E04). Adding them is done; wiring them to a recipe would require inventing a family binding — forbidden.
4. `terrainplateau1..4` have zero `BaseName` refs anywhere in the landed scans (E07; `world3d_relief.gd:33-34`). Exclusion is correct; synthesising a plateau→terrainmesh link would be fabrication.
5. Hills/forest/stone/decor/plateau/plain patterns in the ticket-180 stamp list have no `terrainmesh*` `Objects[]` in any landed census — mapping any of them to mountain props would be a fabricated association. **Do NOT add one.**

## 4. Mechanistic note (port bind)

**[O]** `world3d_relief.gd:152-157`: for each stamp, `st_name` is read; `if st_name.is_empty() or not props_table.has(st_name): continue`; else `matched_stamps+1` and every record of that key is instanced (subject to `:158-173` sid allow-list `RELIEF_SIDS` and mesh presence). The ticket log `stamps=92 matched=0` therefore means **zero of the 92 `st.name` strings equalled any of the 30 E02 keys** — exactly what §3.2 predicts for a forest/stone/hill/decor/plateau/plain sample. `skipped_missing_mesh`/`skipped_unknown_sid` stay 0 in that path because no record is ever reached (E01).

## 5. UNVERIFIED register (do not promote)

1. Native `StandPatternWithAngle` transform math, per-stamp `terrainmeshN` runtime choice, yaw sign, and any metres-per-unit factor (`world3d_relief.gd:21-35` labels; V07 U3).
2. Realised `relieftype`, `problarge`, `mnt/plt/hil` floats and RNG state for the ticket-180 seed (D02 stream territory).
3. Whether the port's 92-stamp generator faithfully implements the E05 fan-out/divisors (`plt/3`, `plt/1.5`, `hil/2`, `mnt*problarge`) or drops the `mountains` call on some path.
4. Exact float-grid byte boundary / sample count (`w*h` vs `(w+1)*(h+1)`) and any engine use of `HeightFieldMax` (V07 E17).
5. `Freq` semantics (weight vs count) and post-stamp `Freq*=0.2` damping constants (X03 §6 A11; DEC_DEEP §9).
6. Whether `i_mnt_*` / `j_big_plt_*` / `fb_*` sections are editor-only (F02 R3) — carried as absence-from-family only.
7. Any donor visual parity (no GPU A/B frame; CHARTER §3/§5).

## 6. Open questions

1. Which `relieftype` (0-4 or random) and which `bDesert` value did the ticket-180 seed actually take, and does the port log record them alongside `matched`?
2. Should the relief bind log also emit the unmatched stamp-family histogram so the next `matched=0` ticket is diagnosable without a re-run?
3. Who owns the mountain-fixture QA that WOULD produce `matched>0` (a `g_mnt_*`-seeded `small_map_64_mountains.json` + Z07 atom), given the current atom is stale (V07 E05)?

## 7. Claim register

| # | Claim | Evidence | Label |
|---|---|---|---|
| 1 | 17 patterns carry `terrainmesh1..4`; 13 desert patterns carry only the desert variant; hills carry none | E02+E03+E07 | [O]/[D] |
| 2 | `matched=0` is correct FOR this 92-stamp list (exact-name gate) | E01+§3.2 | [D] |
| 3 | `matched=0` is NOT proof mountains are excluded from mediterranean/hills generally; `mountains` group is always offered on the temperate arm with `mnt>0` | E04+E05+E06 | [O]/[D] |
| 4 | `i_mnt_*` are table-present but family-unreachable; `desert_mnt_*` are desert-arm-only; `desert_mnt_14/15` have no lib section | E04+E05+E07 | [O]/[D] |
| 5 | No static-only association is missing; do NOT invent one | E02+E07+§3.3 | [D] |
| 6 | No donor parity is claimed; engine transform/selection/streams stay UNVERIFIED | §5 + parity_guard | [U] |

*Chain 0/6. RESULT IS NOT GOOD (no mountain fixture, no QA run, no parity frame). End of ANOM_mntprops. Read-only; exactly this file written.*
