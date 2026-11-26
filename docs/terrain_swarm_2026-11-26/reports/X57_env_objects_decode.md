---
id: X57
ticket: "TERRAIN-SWARM-2026-11-26 / X57 — decode donor env object registries and scale table"
title: "X57 — env.objects / objects.lib / envscales.cfg: format, record counts, terrain-prop relevance and call sites"
agent: "X57 (read-only donor-first analysis worker; DONOR-FIRST terrain swarm 2026-11-26)"
created: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_DONOR_BINARY__NO_GODOT_JOB
owner_file: docs/terrain_swarm_2026-11-26/reports/X57_env_objects_decode.md
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_guard: "NO DONOR VISUAL PARITY CLAIM. No donor binary was executed, no donor GPU A/B frame exists, no port file was edited. 'Read' means bytes/lines were decoded read-only."
scope_guard: "Exactly ONE repo file written (this report). Donor read in place at C:\\Games\\Cossacks 3. Scratch only in %TEMP%\\opencode\\env_objects\\. No runner job, no Godot process, no gate/capture, no source/shader/asset/config/test/git edit."
sources_read: "CHARTER.md; reports/X33_donor_text_coverage.md; reports/F08_flora_minerals.md; reports/X25_relief_silhouette_reference.md; reports/V28_code_review_r1.md; reports/V47_final_contradictions.md; spec/08_FIELDS_AND_PROPS.md; donor files cited in §1."
passes: "P1 path-existence + encoding/lines/SHA; P2 full line read of all three files; P3 record census + family grouping + prop-path existence; P4 corpus-wide 3,096-file text call-site scan; P5 cross-file contradiction passes C1–C6 (§7); P6 editor.aix/menu/mission-map consumption check."
donor_root: "C:\\Games\\Cossacks 3 (READ ONLY, private use)"
---

# X57 — donor environment-object text decode (2026-11-26)

> **Label key:** `[O]` literal on-disk byte/line read this pass · `[D]` arithmetic or
> set consequence of observed literals · `[I]` best reading without an engine run ·
> `[U]` UNVERIFIED · **PORT APPROXIMATION** = port-side substitute, never donor truth.
> All donor paths below are under `C:\Games\Cossacks 3\`; line numbers are 1-based,
> bytes are 0-based. Every donor `.inc` line is `[*] = ;`-prefixed: **text OBSERVED,
> runtime activation UNVERIFIED** (F08 §0, spec/00 U10) — this caveat applies to every
> script citation and is not repeated each time. **No parity claim.**

## 0. Executive summary

1. **[O] The task's `data\env\envscales.cfg` does not exist.** `data\env\` exists but
   contains only `env.cfg`, `time.cfg` and clouds/colors/flares/lights/pfx/skydome
   assets; it has **no** scale table. The real file is
   `data\game\var\envscales.cfg` (25,612 B, 869 lines) — the path used by F08 E13 and
   X33 §4.2. The editor that loads it names that exact path (`createenvironemttest.inc:20`). See C1 (§7).
2. **[O] All three files are plain 7-bit ASCII, CRLF, no BOM.** `data\objects\env\env.objects`
   = 377 lines / 25,609 B / **354** `ObjectItems[*].PropertiesFileName=` records, 21
   blank lines, `section.begin`/`section.end` at `:1`/`:377`; all 354 referenced
   `.prop` paths exist on disk. `data\objects\objects.lib` = 65 lines / 1,687 B /
   **5** sections and **4** `ObjectCollection.LoadFromFile` bindings (env is the 4th,
   `Tag=40`, `objects.lib:43-52`). `data\game\var\envscales.cfg` = 869 lines /
   25,612 B / **1** `generator` section, `EnvGroups`, **26** groups, **122** entries,
   each with exactly one `scale`, `minscale`, `maxscale` (122 of each).
3. **[O]/[D] None of the three files contains a single placement coordinate,
   Direction, Up vector, rotation, weight or count of instances.** `env.objects` is a
   flat ordered *inventory* of prop paths; `objects.lib` is a collection registry;
   `envscales.cfg` is a scale/jitter reference table. Spatial placement remains the
   exclusive domain of `pattern.lib` `Objects[]` and the pass logic of F08; X25's
   silhouettes remain the geometric reference. These files **do** add (a) the complete
   env-prop name inventory and (b) **26-group / 122-entry dimensionless scale and
   jitter literals**, of which F08 quoted only representative lines.
4. **[O] Consumption splits cleanly.** `envscales.cfg` has exactly **one** text call
   site in 3,096 scanned donor text files: `scripts\editor.inc\createenvironemttest.inc:19-56`,
   registered as an editor menu command in `scripts\editor.aix:419-423`. It is an
   **editor diagnostic** that lays out rows of env props 8 cells apart. Its
   `scale` application is inside a commented-out block (`:46-47`); only `minscale`
   / `maxscale` are applied (`:48-57`). `objects.lib` is an **engine-level startup
   registry** (`data\resources\resource.lib:5 RacesFileName = .\data\objects\objects.lib`)
   → `objects.lib:51` loads `env.objects`; the env player exists in all modes
   (`player.script:639-640`, `init.script:231`) and skirmish generation stamps relief
   patterns into that player (`dogenerate.inc:398,1749-1766`). Mission `.map` files
   are binary `OSWMap13` blobs, not text consumers of these files.
5. **[O]/[D] I09 relevance is PARTIAL.** Donor-grounded per-prop scale multipliers
   and jitter bounds are extracted in §6 (e.g. mine `0.3152`, `1/1`; stones
   `0.25–0.4`, mostly `0.85/1.15`; field `0.033`, `1/1`; trees `0.425–0.91`). These
   are dimensionless prop scales, **not** a cell-to-world factor. Nothing in these
   three files supports a divisor of `160`: V47-41 (`DONOR_UNITS=160`) stays
   unresolved by this lane and is **DEFERRED** to COORD/I09 (§6.3).
6. **[O] Two internal donor contradictions are preserved, not harmonised:** (a)
   `field` scale is `0.033` in `envscales.cfg:9` but `0.03605085` in `field.prop:141`;
   (b) `horseradish.1` is listed twice (`envscales.cfg:757,763`) and `horseradish.2`
   is absent although `horseradish2.prop` is registered (`env.objects:142`). See C3/C4.

## 1. Evidence table

| # | Exact donor source | Establishes | Label |
|---|---|---|---|
| E1 | `data\objects\env\env.objects:1-377` (SHA-256 `e62602addf6f39387f0c8b7a4642df870c735654b7eadc50f125ded401e4a373`) | 354 props, lines 2–376; `section.begin` `:1`, `section.end` `:377`; 21 blanks | [O] |
| E2 | `data\objects\env\env.objects:2-4` = `.\data\objects\env\minegold.prop` / `mineiron.prop` / `minecoal.prop`; `:337-339` = `minegolds/mineirons/minecoals.prop` | Six ore props (summer + desert) | [O] |
| E3 | `data\objects\env\env.objects:16` `.\data\objects\env\field.prop`; `:187-190` `terrainmesh1..4.prop`; `:367-370` `terrainmeshdesert1..4.prop` | Field + 8 relief props | [O] |
| E4 | `data\objects\env\env.objects:5-15` stones/stones1..10; `:67-73` smallstones*.prop; `:244-267` shore rocks; `:269-278` lily/reed | Stone/shore prop families (§3) | [O] |
| E5 | `data\objects\objects.lib:1-14,16-27,29-40,42-53,55-65` (SHA-256 `0da956067a91cb0c1a288c8fc348cf0d680327d542c20e429ce807b96d7b6af7`) | 5 sections: units/buildings/misc/env/progress; `ObjectCollection.LoadFromFile` at `:12,25,38,51`; env `Name=env` `:43`, `Tag=40` `:52` | [O] |
| E6 | `data\resources\resource.lib:5` `RacesFileName = .\data\objects\objects.lib`; `data\scripts\resource.script:1` `const cresourcefilename='resource.lib'` | Engine-side pointer to the object registry; no DScript reads `RacesFileName` (negative scan) | [O]/[U] |
| E7 | `data\game\var\envscales.cfg:1-2` `generator : section.begin` / `EnvGroups : struct.begin`; `:3,38,589` comments `// CONSTANT SIZES`, `// ENVIRONMENT`, `// DECORATIONS` | Format and authored grouping | [O] |
| E8 | `data\game\var\envscales.cfg:5-13,16-37,39-109,111-868` (SHA-256 `5c3ac8f935ea23d457eba42a89e63999cbf6f84a01a8ded0f3d42cae3332789f`) | 26 groups / 122 records; scale range 0.033–1.02; min/max pairs only `(1,1)`, `(0.85,1.15)`, `(0.95,1.05)` | [O]/[D] |
| E9 | `scripts\editor.inc\createenvironemttest.inc:19-20` `ParserLoadFromFileByHandle(pEnvScales, '.\data\game\var\envscales.cfg')`; `:38-40` reads `scale/minscale/maxscale`; `:46-47` commented scale application; `:48-57` min/max application; `scripts\editor.aix:419-423` | Only explicit text consumer of `envscales.cfg`; editor-only | [O] |
| E10 | `data\scripts\lib\player.script:639-640` creates env player `gc_playerind_env`; `data\scripts\lib\init.script:231` `SetPatternPlayerName(gc_racename_env)`; `data\scripts\dmscript.global:943` `gc_racename_env = 'env'` | Env registry is available to generation, not just editor | [O] |
| E11 | `data\scripts\common.inc\dogenerate.inc:398` `GetPlayerHandleByName(gc_racename_env)`; `:1749-1766` `_misc_SetupPatternsByType(pGenerator, envplHnd, 'mountains'/...` | Skirmish relief stamps target the env player | [O] |
| E12 | `data\scripts\lib\misc.script:3805-3874` `_misc_FixEnvironmentObjectsScales`; caller `dogenerate.inc:2055` `//_misc_FixEnvironmentObjectsScales(False); // optimize first` | Runtime scale-fix routine exists but its generation call is commented | [O] |
| E13 | `data\objects\env\field.prop:139-145` `DefaultScale X=Y=Z=0.03605085`, `RandomScale=False`; `:148-150` `DefaultRollAngle = 45`; `:152-157` decal block commented | Field literal conflicting with E8; 45° roll corroborates F07/X22 | [O] |
| E14 | `data\objects\env\minegold.prop:35-40` `DefaultScale X=Y=Z=0.3152`; `stones.prop:158-163` `0.329`; `fir.prop:94-102` `0.5`, `RandomScale=True`, `0.85/1.15`; `plantain3.prop:78-86` `0.384/0.384/0.288`, `0.925/1.075` | Prop `scaleproperty` mirrors — but does not always equal — `envscales.cfg` | [O] |
| E15 | Corpus scan: 3,096 `.inc/.script/.global/.aix/.cfg/.lib/.objects/.prop/.txt/.source/.mat/.map` files; hits for `envscales` only in E7/E9 | Negative evidence for other (skirmish) call sites | [O] negative |
| E16 | `data\maps\missions\*.map` (68 `.map` + 34 `.aix`), sample `ausmis1.map` header `5\x00\x00\x00OSWMap13.Map.Ver[0.0]...` | Mission maps are binary; no text-level registry/scale call site | [O] |
| E17 | Scratch `%TEMP%\opencode\env_objects\x57_envscales_groups.json` (full 26-group/122-entry parsed table), plus `probe.py`, `count_check.py`, `find_calls.py`, `families.py`, `scaleprops.py` | Reproducible derivation, outside repo | [O] |

## 2. Format, counts and exact literals

### 2.1 `data\objects\env\env.objects` — flat prop-path inventory

**[O] Format:** OSW text parser syntax, one `section.begin` / `section.end` pair, no
nested structs, no comments. Every nonblank record is exactly
`ObjectItems[*].PropertiesFileName=.\data\objects\env\<stem>.prop` (leading `.\`,
backslashes, no quotes). Counts: **377 physical lines = 1 header + 354 records +
21 blank lines + 1 footer**. 354 unique paths, zero duplicates, **all 354 exist on
disk** (read-only `os.path.isfile`). SHA-256 in E1.

Exact representative literals **[O]**:

| Path:line | Literal |
|---|---|
| `data\objects\env\env.objects:1` | `section.begin` |
| `:2` | `ObjectItems[*].PropertiesFileName=.\data\objects\env\minegold.prop` |
| `:4` | `ObjectItems[*].PropertiesFileName=.\data\objects\env\minecoal.prop` |
| `:16` | `ObjectItems[*].PropertiesFileName=.\data\objects\env\field.prop` |
| `:187-190` | `...\terrainmesh1.prop` … `...\terrainmesh4.prop` |
| `:244-249` | `...\rocksea1.prop` … `...\rocksea6.prop` |
| `:337-339` | `...\minegolds.prop`, `...\mineirons.prop`, `...\minecoals.prop` |
| `:367-370` | `...\terrainmeshdesert1.prop` … `...\terrainmeshdesert4.prop` |
| `:377` | `section.end` |

**[O]/[D] Terrain-relevant families (count, exact line range):**

| Family | N | Lines |
|---|---:|---|
| Summer ores `minegold/mineiron/minecoal` | 3 | 2–4 |
| Desert ores `minegolds/irons/coals` | 3 | 337–339 |
| `field` | 1 | 16 |
| `terrainmesh1..4` / `terrainmeshdesert1..4` | 4 + 4 | 187–190 / 367–370 |
| `stones`, `stones1..10` | 11 | 5–15 |
| `smallstones` + `smallstones1..6` | 7 | 67–73 |
| `landstone` + `landstone1..4` | 5 | 130–134 |
| `rocks` | 1 | 184 |
| `rocksea1..6` | 6 | 244–249 |
| `stonessea`, `stonessea1..10` | 11 | 250–260 |
| `smallstonessea`, `smallstonessea1..6` | 7 | 261–267 |
| `smallstonesdesert` + `1..6` | 7 | 341–347 |
| `stonesdesert` + `1..10` | 11 | 349–359 |
| `lily`, `lily1..5` / `reed`, `reed1..3` (shore water) | 6 + 4 | 269–274 / 275–278 |
| `fir`,`fir1..4`,`firsmall`,`firsmall1..4` | 10 | 17–26 |
| `pine`,`pine1..4`, `pinebroken*`, `pinebrokenmoss*` | 15 | 27–46 |
| `pinesmall`,`pinesmall1..4` | 5 | 32–36 |
| `spruce`,`spruce1..4` | 5 | 47–51 |
| `pinedry*`, `pinedryswamp*` | 10 | 52–61 |
| `drytree*` | 5 | 62–66 |
| `pinestump*` | 5 | 74–78 |
| `burch*`, `burchbroken*`, `burchsmall*`, `burchstump*` | 26 | 79–104 |
| `leaftree*`, `oak*` | 5 + 5 | 105–109 / 110–114 |
| `fern*` / `bushes*` / `drybushes*` | 5 / 4 / 4 | 115–119 / 120–124 / 125–129 |
| `burdock*` / `horseradish*` | 4 / 4 | 135–138 / 140–143 |
| `grass*` / `plant*` / `chamomile*` / `grasschamomile` | 6 / 6 / 3 / 1 | 145–150 / 151–156 / 158–160 / 161 |
| `plantain*` / `flowers*` / `grassforest*` / `grassleafforest*` | 4 / 4 / 6 / 4 | 163–166 / 168–171 / 173–178 / 179–182 |
| `ivy` / `rocks` (decor) | 1 / 1 | 186 / 184 |
| `decortree1,11,12,13,2,21,22,23,3,31,32,33` | 12 | 192–203 |
| `bags/barrel/cart/coal/fence/hay/ladder/pitchers/smallcart/stall/trolley/boat/shipwreck` (decor/mission) | 38 | 205–242 |
| `pump*` / `gift*` + `christmastree*` | 4 / 9 | 301–304 / 306–314 |
| `palm*`,`palmsmall*` | 10 | 279–288 |
| `plantainyellow*`, `plantyellow*` | 4 + 6 | 290–293 / 294–299 |
| `desert1..5` + `.1/.2/.3` variants | 20 | 316–335 |
| `grassdesert*` / `desertstump*` | 6 / 5 | 361–366 / 372–376 |

**[D] Interpretation:** this is a *superset* of the families F08 catalogued. It
includes decor and mission props (boats, carts, barrels, shipwrecks, pump, gifts) and
shore/lily/reed families that `generator.cfg` F08 found unreferenced. It supplies
**no** `Position`, `Direction`, `Up`, `Scaling`, `Freq`, `minscale` or `maxscale`
field — only names. It therefore cannot replace F08's `pattern.lib` object arrays or
X25's geometry.

### 2.2 `data\objects\objects.lib` — five-section collection registry

**[O] 65 lines / 1,687 B / 5 sections** (SHA-256 E5). Exact literals:

| Path:line | Literal |
|---|---|
| `data\objects\objects.lib:2,12,13` | `Name=units`, `ObjectCollection.LoadFromFile=.\data\objects\units\units.objects`, `Tag=10` |
| `:17,25,26` | `Name=buildings`, `...\buildings\buildings.objects`, `Tag=20` |
| `:30,38,39` | `Name=misc`, `...\misc\misc.objects`, `Tag=30` |
| `:43,45,46-49,51,52` | `Name=env`, `Priority=100`, `Enabled=True`, `GlobalStateMachineEnabled=False`, `GroupsStateMachineEnabled=False`, empty intervals, `ObjectCollection.LoadFromFile=.\data\objects\env\env.objects`, `Tag=40` |
| `:56,60-63,64` | `Name=progress`, `GlobalStateMachine.LoadFromFile=.\data\scripts\progress\progress.aix`, `Tag=50` (no `ObjectCollection`) |

**[O]/[D]** All four `ObjectCollection` targets exist on disk (verified). The fourth
(`:51`) is the only text-level edge from the registry to `env.objects`. No terrain
placement/scale data exists here. X33 E6 reported 4 `.objects` files in `data\objects\**`;
these are exactly the four collections E5 lists — consistent, no contradiction.

### 2.3 `data\game\var\envscales.cfg` — scale/jitter reference table

**[O] Format:** CRLF ASCII, single `generator : section.begin` (`:1`), one
`EnvGroups : struct.begin` (`:2`), 26 anonymous `[*] : struct.begin` group records,
each with `group = <name>` and a `list : struct.begin` of `[*]` entries carrying
`name`, `scale`, `minscale`, `maxscale`; closes at `:867-869`. Three authored comment
bands: `// CONSTANT SIZES` (`:3`), `// ENVIRONMENT` (`:38`), `// DECORATIONS` (`:589`).

**Counts [O]/[D]:** 122 `name`, 122 `scale`, 122 `minscale`, 122 `maxscale` lines;
26 groups; scale range **0.033–1.02**; observed jitter pairs only
`(1,1)`, `(0.85,1.15)`, `(0.95,1.05)`.

**Exact literals [O] (selected, path `data\game\var\envscales.cfg`):**

| Line(s) | Literal(s) |
|---|---|
| `:5-11` | `group = field`, `name = field`, `scale = 0.033`, `minscale = 1`, `maxscale = 1` |
| `:16-34` | `group = mines`; `name = minecoal/minegold/mineiron`, each `scale = 0.3152`, `minscale = 1`, `maxscale = 1` |
| `:40-106` | `group = stones`; scales in file order `0.329, 0.329, 0.37, 0.4, 0.324, 0.313, 0.328, 0.25, 0.25, 0.25, 0.25`; all `0.85/1.15` |
| `:111-155` | `group = smallstones`; `0.25, 0.209, 0.209, 0.236, 0.25, 0.25, 0.25`; `0.85/1.15` |
| `:162,168,174,180,186`; `:197,203,209,215,221`; `:372,378,384,390,396` | `fir`, `firsmall`, `spruce1`: scale `0.5` for all 15 entries; `0.85/1.15` |
| `:231-259` | `pine1` group: `0.475` ×5; `0.85/1.15` |
| `:266-294` | `pinesmall1`: `0.55, 0.535, 0.56, 0.61, 0.5`; `0.85/1.15` (confirms F08 E12 suffix entries `pine1.1:237`, `firsmall1.1:202`, `smallstones.1:120`, `plantain.3:832`) |
| `:441-469` | `pinestump`: `0.91, 1, 0.817, 1.02, 0.817` — contains the table maximum `scale = 1.02` at `:460` |
| `:751-773` | `horseradish`: `0.369` ×4, names `horseradish`, `horseradish.1` (`:757`), `horseradish.1` again (`:763`), `horseradish.3` (`:769`) — see C4 |
| `:814-836` | `plantain`: `0.412, 0.417, 0.436, 0.384`; `0.85/1.15` |
| `:595,601,607,613`; `:804-806` | `grass` `0.27` ×4 with `0.95/1.05`; `grasschamomile` `0.3` with `0.95/1.05` |

**[D] Full 26-group census** (group, entries, line band, scale values in file order;
min/max factor sets are only the three pairs above):

| Group | N | Lines | Scale values |
|---|---:|---|---|
| field | 1 | 5–13 | 0.033 |
| mines | 3 | 16–37 | 0.3152 ×3 |
| stones | 11 | 40–108 | 0.329, 0.329, 0.37, 0.4, 0.324, 0.313, 0.328, 0.25 ×4 |
| smallstones | 7 | 111–155 | 0.25, 0.209, 0.209, 0.236, 0.25 ×3 |
| fir | 5 | 158–190 | 0.5 ×5 |
| firsmall | 5 | 193–225 | 0.5 ×5 |
| pine1 | 5 | 228–260 | 0.475 ×5 |
| pinesmall1 | 5 | 263–295 | 0.55, 0.535, 0.56, 0.61, 0.5 |
| pinebroken1 | 5 | 298–330 | 0.64, 0.82, 0.69, 0.55, 0.5 |
| pinebrokenmoss1 | 5 | 333–365 | 0.64, 0.63, 0.705, 0.742, 0.5 |
| spruce1 | 5 | 368–400 | 0.5 ×5 |
| pinedry1 | 5 | 403–435 | 0.65, 0.618, 0.706, 0.76, 0.5 |
| pinestump | 5 | 438–470 | 0.91, 1, 0.817, 1.02, 0.817 |
| leaftree | 5 | 473–505 | 0.425 ×4, 0.504 |
| burch | 7 | 508–552 | 0.38, 0.374, 0.366, 0.341, 0.415, 0.434, 0.354 |
| burchstump | 5 | 555–588 | 0.807, 0.915, 0.807 ×3 |
| grass | 4 | 591–617 | 0.27 ×4 |
| grassforest | 4 | 620–646 | 0.475 ×4 |
| fern | 5 | 649–681 | 0.43 ×5 |
| drybushes | 5 | 684–716 | 0.5 ×5 |
| burdock | 4 | 719–745 | 0.356 ×4 |
| horseradish | 4 | 748–774 | 0.369 ×4 (one duplicated name — C4) |
| chamomile | 3 | 777–797 | 0.147 ×3 |
| grasschamomile | 1 | 800–808 | 0.3 |
| plantain | 4 | 811–837 | 0.412, 0.417, 0.436, 0.384 |
| flowers | 4 | 840–868 | 0.281, 0.263, 0.29, 0.29 |

**[D] Coverage gap:** none of the 26 groups names `terrainmesh*`, `rocksea*`,
`stonessea*`, `smallstonessea*`, `lily*`, `reed*`, `pump*`, `gift*`, `christmastree*`,
`boat*`, `palm*`, `desert*`, `plantyellow*` or `terrainmeshdesert*`. I09 cannot source
relief/shore/desert/decor scales from this table.

## 3. Relation to terrain props — what is and is not new versus F08/X25

1. **[O] `env.objects` confirms the inventory side of F08 E12's object chain.**
   `BaseName → .prop → LODActorName → actors.lib → .actor → .osm` (F08 §3.5) needs a
   registered `.prop`; `objects.lib:51` supplies that collection. The registry covers
   every family F08 used (ores, stones, conifers, leaf trees, bushes/weeds) **plus**
   shore rocks and lily/reed, relief `terrainmesh*`, desert variants and event decor.
2. **[D] It adds no placement or scale data beyond F08/X25.** The only fields are
   `PropertiesFileName` paths. F08's per-`Objects[]` positions/directions/scales
   (`pattern.lib:713323-713633` for `mng_1`, etc.) and X25's per-mesh OBJ geometry
   remain the only sources of placement/silhouette numbers. No new weight, frequency
   or instance-count rule appears here.
3. **[O]/[D] `envscales.cfg` adds complete *scale* literals beyond F08's sampled
   lines.** F08 E13 quoted the mine `0.3152` (`envscales.cfg:15-37`) and stone
   `0.25–0.4` (`:39-109`) ranges and E12 quoted four suffix lines; §2.3 above exhausts
   all 122 entries. This is additive **scale** data, never placement data.
4. **[D] No file supplies a metres-per-cell or world-unit conversion.** The suffix
   variant scales are multipliers on the prop's own `DefaultScale`, not tile sizes.
   X25's 25–28-unit mesh bounding boxes and `TILE_M=2.0` remain a port frame
   (`world3d_relief.gd:49`, X25 E07), not a donor fact.

## 4. Consumption: skirmish generation vs editor/mission maps

### 4.1 `envscales.cfg` — editor-only, with a doubly-disabled `scale`

**[O] Call site (the only one in the 3,096-file text scan, E15):**

```
scripts\editor.inc\createenvironemttest.inc:18   var plHnd := GetPlayerHandleByIndex(gc_playerind_env);
scripts\editor.inc\createenvironemttest.inc:19   var pEnvScales := _parser_ParserTemporary(True);
scripts\editor.inc\createenvironemttest.inc:20   ParserLoadFromFileByHandle(pEnvScales, '.\data\game\var\envscales.cfg');
scripts\editor.inc\createenvironemttest.inc:21   var pEnvGroups := ParserSelectByHandleByKey(pEnvScales, 'EnvGroups');
scripts\editor.inc\createenvironemttest.inc:24   var groupcount := ParserGetCountByHandle(pEnvGroups);
scripts\editor.inc\createenvironemttest.inc:29-31  (per group) group / list
scripts\editor.inc\createenvironemttest.inc:37-40  (per entry) name / scale / minscale / maxscale
scripts\editor.inc\createenvironemttest.inc:43-44  const offx = 8; const offy = 8;
scripts\editor.inc\createenvironemttest.inc:45     CreatePlayerGameObjectHandleByHandle(plHnd, gc_racename_env, name, posx, 0, posz);
scripts\editor.inc\createenvironemttest.inc:46-47 {if (scale>0) then SetGameObjectScaleByHandle(goHnd, scale, scale, scale);}
scripts\editor.inc\createenvironemttest.inc:48-57 if minscale<>1 / maxscale<>1 → spawn a side copy scaled by intrinsic × factor
```

**[O] Registration:** `scripts\editor.aix:419-423` `Name = CreateEnvironemtTest` /
`UsedFile = True` / `UsedFileName = .\scripts\editor.inc\createenvironemttest.inc`.
**[O] Preconditions** are editor UI only: `EditorFormClear('message')` (`:4`), map
height ≥ 256 (`:5-10`), `GetCountOfPlayers≥gc_playerind_env` (`:12-16`).
**[D] Verdict:** this is an **editor size-inspection tool** (rows of props 8 cells
apart with min/max comparison copies), not a generation input. Every line is
`[*] = ;` commented **[U] as to execution**, and even if executed the `scale` value
is read (`:38`) but its application is inside a `{...}` comment (`:46-47`). The
`minscale`/`maxscale` multipliers are applied only to side-by-side test copies
(`:48-57`), not to the main spawned object.

**[O] Negative evidence:** no `generator.cfg`, `dogenerate.inc`, `generatemap.inc`,
`misc.script` or any other donor text reads `envscales.cfg`, `EnvGroups`, `minscale`
or `maxscale` from a file (E15; the many `MinScaleFactor` hits are `.prop` fields).
`_misc_FixEnvironmentObjectsScales` (`misc.script:3805-3874`) samples 100 freshly
created env objects to clamp outliers, but its generation call is commented:
`dogenerate.inc:2055 //_misc_FixEnvironmentObjectsScales(False); // optimize first`.
**[D]** Therefore the table's *runtime* role beyond the editor tool is **[U]**.

### 4.2 `objects.lib` / `env.objects` — engine registry used by generation and editor alike

- **[O]** `data\resources\resource.lib:5 RacesFileName = .\data\objects\objects.lib`
  points the engine (not a DScript call) at the registry. `data\scripts\resource.script:1`
  uses `resource.lib` for localisation, not for object loading. No text call site reads
  `RacesFileName` **[U]** engine-side consumption.
- **[O]** `objects.lib:51` loads `env.objects`; `objects.lib:43-52` gives the env
  collection `Tag=40` and no state machines.
- **[O]** The env player is created in normal play: `player.script:637-642`
  (`CreatePlayerInsert(gc_racename_env, ..., gc_playerind_env)`) and
  `init.script:231 SetPatternPlayerName(gc_racename_env)`. `dmscript.global:943`
  fixes `gc_racename_env = 'env'`.
- **[O]** Skirmish generation clears and stamps into that player:
  `initmapgen.inc:23-25` and `initmap.inc:24-26` (`ClearPlayerGameObjectsByHandle`),
  `dogenerate.inc:398`, and `:1749-1766`
  `_misc_SetupPatternsByType(pGenerator, envplHnd, 'mountains' | 'plateau_big' |
  'plain_huge' | 'ravine_big' | 'hills_dark' | 'hills_light' | desert_* , …)`.
- **[D] Verdict:** `objects.lib`/`env.objects` are **not editor/mission-only**: they
  are the startup object registry required to resolve the `BaseName`s that
  `pattern.lib` stamps into the env player during skirmish generation. The exact
  engine moment at which `ObjectCollection.LoadFromFile` populates the registry is
  **[U]** (no DScript call site; no binary run in this lane).
- **[O]/[D] Mission maps:** `data\maps\missions\` holds 68 binary `.map` files plus
  34 script `.aix`; `ausmis1.map` begins `OSWMap13.Map.Ver[0.0]Build.Ver[2.0.0.2843]`.
  They are not text consumers of these three files. F08/X33's `postpatterns.cfg`
  authored-mission scatter is a separate lane (X33 §4.1).

## 5. Sizes already cross-checked against other reports

- **[O]** F08 E13's mine literal is confirmed both in `envscales.cfg:20,26,32`
  (`scale = 0.3152`) and in `data\objects\env\minegold.prop:37` (`DefaultScale X=0.3152`),
  matching `pattern.lib:713429` (`Scaling=0.315200001001358`, F08 §3.3). **No jitter**
  for mines: `minscale = maxscale = 1` (`envscales.cfg:21-22,27-28,33-34`).
- **[O]** F08 E13's stone range is confirmed: `envscales.cfg:44,50,56,62,68,74,80,86,92,98,104`
  = `0.329,0.329,0.37,0.4,0.324,0.313,0.328,0.25×4`; jitter `0.85/1.15` per entry.
- **[O]/[D]** X25 §4.3's mine silhouette note ("mines are not a silhouette source")
  is consistent: 3 ore meshes are flat and identical in X25 E09; these files provide
  only a `0.3152` scale multiplier, no extra height.
- **[O]** X25's per-record `mountain_props.json` scale range `0.4460–0.6400` comes
  from `pattern.lib`; `envscales.cfg` has **no** `terrainmesh` group, so it neither
  confirms nor corrects those scales.

## 6. I09 extraction — donor-grounded scales, and the DEFERRED item

### 6.1 Directly usable dimensionless literals for I09

**[O]/[D] All values below are multipliers on a prop's intrinsic `DefaultScale`
(`data\objects\env\<name>.prop scaleproperty`), i.e. dimensionless; no metre/cell
conversion is present in any of the three files.** Cite with the exact line:

| Prop class | `scale` literal(s) | min/max factors | Donor path:line |
|---|---|---|---|
| Field | `0.033` | `1 / 1` | `data\game\var\envscales.cfg:9-11` |
| Gold/iron/coal ore | `0.3152` ×3 | `1 / 1` | `:20-22,26-28,32-34` |
| Desert ores | **not listed** | — | `env.objects:337-339` only |
| Stones `stones..stones10` | `0.329,0.329,0.37,0.4,0.324,0.313,0.328,0.25×4` | `0.85 / 1.15` | `:43-106` |
| Small stones `.1..6` | `0.209–0.25` | `0.85 / 1.15` | `:114-151` |
| Fir / firsmall / spruce | `0.5` ×15 | `0.85 / 1.15` | `:162-224,371-399` |
| Pine | `0.475` ×5 | `0.85 / 1.15` | `:232-256` |
| Small pine (`.1..4`) | `0.535–0.61` | `0.85 / 1.15` | `:266-291` |
| Leaftree / burch (`oak` has **no** group) | `0.341–0.504` | `0.85 / 1.15` | `:477-501 / :512-548` |
| Grass / grassforest | `0.27` / `0.475` | `0.95 / 1.05` | `:595,601,607,613 / :624,630,636,642` |
| Fern / drybushes / plantain / flowers | `0.43 / 0.5 / 0.384–0.436 / 0.263–0.29` | `0.85 / 1.15` | `:653-681 / :688-716 / :815-836 / :844-863` |
| Terrainmesh / shore rocks / desert / pump / gift | **absent from table** | — | §2.3 coverage gap |

**[O] Cross-source caution for I09:** `field.prop:141-143` sets `DefaultScale
X=Y=Z=0.03605085`, **not** `0.033`; `plantain3.prop:80-82` sets `X=Y=0.384, Z=0.288`
while `envscales.cfg:832-834` gives a single `scale = 0.384` with `0.85/1.15`, whereas
the prop's own jitter is `0.925/1.075` (`plantain3.prop:85-86`). The table is a
reference/diagnostic summary, **not** a byte-exact mirror of `scaleproperty`. Use
`.prop` when binding a single instance; use `envscales.cfg` only as the donor-cited
group-level reference. `[D]`

### 6.2 Field-specific donor facts relevant to spec §08 §8 / I09

- **[O]** `field.prop:31-34` `LODActorName = field`, `DefaultMeshName = field1.mesh`,
  `RandomMeshName = True`; `:41-101` seasonal `field*`/`field*w` material swaps;
  `:148-150` `DefaultRollAngle = 45` (independent corroboration of F07's 45° sow
  rotation). `:152-157` the `decalproperty` (`envfieldd`) block is **commented out**.
- **[D]** These are prop/scaleproperty facts, not a new sowing rule; the 49-node/
  1.6981-cell recipe stays F07/X22 territory. No count/position data is added here.

### 6.3 DEFERRED — no donor citation for a world-unit divisor

**[U]/DEFERRED.** V28 F-02 / V33 / V36 C8 / V47-41 flag I09's
`DONOR_UNITS=160` as a port invention and ask for a donor path:line or removal.
This lane searched all three files and their direct call sites: there is **no**
`160`, no metres-per-cell constant, no `TILE_M`, no cell↔world factor and no
`DONOR_UNITS` equivalent (E15 negative + full line reads §2). The scales recovered
above are multipliers, so they **cannot** justify dividing prop dimensions by 160.
COORD/I09 must resolve the unit question from V08 (`1 donor distance = 1 map cell`)
and the I07 cell-space transform; this worker issues **no** value and **no** verdict.

## 7. Multiple passes on contradictions (CHARTER.md:88-93)

| # | Contradiction / anomaly | Pass 1 | Pass 2 | Pass 3 | Accepted reading |
|---|---|---|---|---|---|
| C1 | Task names `data\env\envscales.cfg`; F08/X33 name `data\game\var\envscales.cfg` | `os.path.exists` on both: real = `game\var`, `data\env\envscales.cfg` MISSING | `os.walk data\env`: only `env.cfg`, `time.cfg`, clouds/colors/flares/lights/pfx/skydome | Editor call site quotes `.\data\game\var\envscales.cfg` (`createenvironemttest.inc:20`); `data\env\env.cfg:1-27` is lighting/skydome (LensFlare*/Moon*/LightSourceManager) | **[O]** Only `data\game\var\envscales.cfg` exists; task path is a misnomer. `data\env\env.cfg` is unrelated. Both paths preserved in text. |
| C2 | F08 E13 "stones 0.25–0.4 with ±15% jitter" vs `.prop` jitter fields | Read all 11 stone scales (`:43-106`): min 0.25, max 0.4 ✓ | `stones.prop:158-164` has `DefaultScale 0.329` but **no** `RandomScale`/Min/Max; `fir.prop:100-102` has `RandomScale=True 0.85/1.15` | `envscales.cfg` jitter is `0.85/1.15` for every stones entry; `.prop` of some families differs (plantain3 `0.925/1.075`) | **[O]** F08's cfg-level reading stands; runtime jitter source is `.prop scaleproperty` and is **[U]** for envscales-driven generation. No harmonisation. |
| C3 | `field` scale `0.033` (cfg) vs `0.03605085` (prop) | Regex census: `envscales.cfg:9 scale = 0.033` | `field.prop:141-143 DefaultScale X=Y=Z=0.03605085`, `RandomScale=False` (`:145`) | Read editor reader: `scale` parsed at `:38`, applied only inside commented block `:46-47`; comment band says `// CONSTANT SIZES` (`:3`) | **[O]** Two distinct donor literals; reason for difference **[U]**. Report both; do not overwrite either. |
| C4 | `horseradish.1` duplicated, `horseradish.2` missing | Entry census found 26 groups/122 names; duplicate `[('horseradish.1', 2)]` | Numbered raw dump: `:751 horseradish`, `:757 horseradish.1`, `:763 horseradish.1`, `:769 horseradish.3` | `env.objects:142` registers `horseradish2.prop`; `.prop` exists on disk | **[O]** Genuine donor typo: `.2` never appears in the cfg; the editor test would spawn `.1` twice. Engine/generator effect **[U]** (no generation call site). |
| C5 | Is `envscales.cfg` consumed by skirmish generation? | 3,096-file keyword scan → only editor `.inc` + its `.aix` registration | Broader scan for `minscale/maxscale/SetGameObjectScale` → editor tools, `.prop` fields, `misc.script` runtime sampler, no generator reader | `dogenerate.inc:2055` scale-fix call commented; `createenvironemttest.inc:46-47` scale apply commented | **[O]/[U]** Editor-only is the accepted reading for this table; engine-side implicit load **[U]**. Negative scope stated (E15). |
| C6 | Are the registries editor/mission-only? | Text scan found no `.map` consumer; maps are binary | `player.script:639-640`, `init.script:231`, `dmscript.global:943` show env player in normal play | `dogenerate.inc:398,1749-1766` stamps relief into `envplHnd` via `_misc_SetupPatternsByType` | **[O]/[D]** `objects.lib`/`env.objects` are general startup registries used by generation too; exact engine load moment **[U]**. |

## 8. UNVERIFIED register (do not promote)

1. Whether `cossacks.exe`/`editor.exe` implicitly loads `envscales.cfg` outside the
   cited editor command (no binary run in this lane; E15 negative is text-only).
2. Runtime activation of every `[*] = ;` line in `createenvironemttest.inc`,
   `dogenerate.inc`, `initmapgen.inc` and `misc.script`.
3. The engine-side moment/API by which `RacesFileName`/`ObjectCollection.LoadFromFile`
   populate the env object collection (no DScript call site).
4. Semantics of the `scale` field beyond the editor test — it is read but its only
   application is commented (`createenvironemttest.inc:46-47`); the `0.033` vs
   `0.03605085` field discrepancy (C3) remains unexplained.
5. Why `horseradish.2` is absent from the cfg while `horseradish2.prop` exists (C4).
6. Whether any desert/shore/relief prop has an implicit scale source outside these
   files (no group in `envscales.cfg`; X25 §7 items 2–3 still open).
7. Any cell↔world or metre-per-unit conversion — **DEFERRED** to COORD/I09 (§6.3).
8. All visual parity: no donor GPU A/B frame; no claim.

## 9. Claim register

| # | Claim | Evidence | Label |
|---|---|---|---|
| 1 | Real path is `data\game\var\envscales.cfg`; `data\env\envscales.cfg` absent | C1, E7, E9 | [O] |
| 2 | `env.objects` 377 lines / 354 records / 354 unique existing `.prop` paths; no placement/scale fields | E1–E4, §2.1 | [O]/[D] |
| 3 | `objects.lib` 65 lines / 5 sections / 4 collections; env `Tag=40` at `:51-52` | E5, §2.2 | [O] |
| 4 | `envscales.cfg` 869 lines / 26 groups / 122 entries / 122 scale+min+max triples; range 0.033–1.02; factor pairs only 3 | E7, E8, §2.3 | [O]/[D] |
| 5 | Only text consumer of `envscales.cfg` is an editor tool; its scale application is commented out | E9, E15, C5 | [O]/[U] |
| 6 | Object registries are used by skirmish generation via the env player | E10, E11, C6 | [O]/[D] |
| 7 | I09 can use donor scale/jitter multipliers; no cell↔world divisor exists here — DEFERRED | §6.1, §6.3, E13, E14 | [O]/[U] |
| 8 | `field` 0.033 vs 0.03605085 and `horseradish.1` duplicate are preserved donor anomalies | C3, C4 | [O] |
| 9 | No donor parity claim; no donor binary run; no repo file but this report written | scope_guard, parity_guard | [O] |

## 10. Temp artifacts (outside repo)

`%TEMP%\opencode\env_objects\`: `probe.py` (path/encoding/SHA), numbered Latin-1
dumps of the three donor files, `find_calls.py`/`find_calls2.py` (corpus call-site
scans), `contexts.py`/`chain.py`/`maps.py`/`scaleprops.py`/`families.py` (call-site
context, registry chain, mission-map format, prop `scaleproperty`, family counts),
`count_check.py`, `grouptable.py`, `x57_envscales_groups.json` (full parsed table).
No artifact from this list was written into `variant3d/`, `docs/`, or any donor path.

---
*End of X57. Exactly one report written. Donor READ ONLY; no binary executed, copied
or committed; no Godot job, gate, capture, source, shader, config, asset, test or git
change. No donor visual parity claim.*
