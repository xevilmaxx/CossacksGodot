---
id: X33-TEXT-COVERAGE-2026-11-26
ticket: "TERRAIN-SWARM-2026-11-26 / X33 — donor-first TEXT-corpus read coverage and unread terrain text"
title: "X33 — what of the donor text corpus was actually read, and what terrain-named text remains unread"
agent: "X33 (read-only coverage worker, DONOR-FIRST terrain swarm)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_DONOR_BINARY__NO_GODOT_JOB
owner_file: docs/terrain_swarm_2026-11-26/reports/X33_donor_text_coverage.md
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_guard: "NO DONOR VISUAL PARITY CLAIM. No donor GPU A/B frame exists; no donor binary was executed by this worker. 'Opened' means bytes were read or keyword-indexed, never that a line executes in the shipped EXE or that the port matches the donor."
scope_guard: "Exactly one repo file written (this report). Donor at C:\\Games\\Cossacks 3 walked and sampled read-only via os.walk/os.stat/open('rb'); no donor file written, copied or executed; no source/shader/config/asset/test/git/Godot-runner state touched."
sources_read: "CHARTER.md, SWARM_BOARD.md, reports/X03_dscript_corpus.md, reports/F09_editor_script.md, reports/F03_gen_config.md, reports/X27_decode_coverage.md; cross-check grep over reports/ and spec/ under docs/terrain_swarm_2026-11-26/."
passes: "Pass 1 os.walk inventory; Pass 2 per-file text listing with worker tags; Pass 3 three competing text-extension definitions + terrain-keyword grouping; Pass 4 .prop/.actor plaintext magic check + corpus-wide citation intersection; Pass 5 line-count reconciliation and count-contradiction table (§3)."
---

# X33 — Donor TEXT-corpus read coverage (2026-11-26)

## 0. Executive summary

1. **[O] Seven assigned donor trees contain 12,322 files / 4,124,893,688 B (≈3.84 GiB).** Of these, the *core text* corpus (`.cfg/.inc/.script/.global/.source/.aix/.mat/.lib/.txt`, 403 files / 7,590,170 B) and the *wide text* corpus (core + plaintext `.prop/.actor/.objects`, 2,668 files / 12,300,968 B) are the only artifacts to which a "text was read today" claim can apply. Binary `.tga/.bmp/.dds/.osm/.oss` files are inventory-only here (they are other workers' lanes).
2. **[O] The three named workers opened 371 core-text files = 92.1% of the file count, but only 5,152,806 B = 67.9% of the core-text bytes.** F09's 364 files (`data\scripts\**` 222 + `scripts\editor.inc\**` 142) were *keyword-indexed*, not full-read; F03 added 7 configs; X03's 8 full reads and 1 targeted file are subsets of those sets. Measured by lines the coverage is lower: **113,945 / 191,538 = 59.5%** of core-text lines were inside an opened file.
3. **[D] "Read" at the level that can be verbatim-quoted is far smaller: 25 files / 837,268 B (6.2% of core-text files, 11.0% of core-text bytes)** are full-read or line-cited by the three named workers (X03 8 full + `misc.script` targeted; F03 7 full; F09 10 editor `.inc` files with line citations). Strictly *fully* read by X03/F03: **14 unique files / 517,106 B (3.5% of files)**. The rest of the 371 are index hits only **[U]** as to runtime and content.
4. **[O] Terrain-named files total 4,774: 4,466 `.tga` masks (already full-corpus decoded by F04 — not "unread") + 308 others.** Of the 308 non-mask terrain-named files, only **29 (9.4%)** were opened by the named three; **279 (90.6%)**, 134,497,720 B, were not. **258** of those 279 are not even basename-cited in any landed swarm report.
5. **[D] The single largest genuinely unopened terrain-named text file is `C:\Games\Cossacks 3\data\gen\bitmap\postpatterns.cfg` (269,140 B)**: `Missions → PatternName/X/Y` records (e.g. `:4-24` `g_hil8`, `g_frt_small_3`, `d_stn_2`, `big_hill_1`) — authored-mission prop scatter, absent from F03's "7 cfg" set, from F09 and from X03. Priority read for authored-map scope; low direct impact on skirmish random maps.
6. **[U] Count contradiction preserved:** F09 reports 367 files / 109,581 lines; this inventory measures 364 files / 106,073 physical lines in the two F09 trees, +`scripts\editor.aix` 2,879 +`data\gui\menu.inc\donewgame.inc` 172 = 109,124, leaving a **457-line residual [U]** (line-count convention or one further adjacent file). No number was silently harmonised (§3).
7. **[D] These are coverage facts, not parity facts.** Every quoted donor line remains `;`-prefixed intent (spec/00 U10; X27 §4); all port consequences are **PORT APPROXIMATION**. No donor parity claim is made or implied.

## 1. Evidence table

| Id | Source / donor path | What it establishes | Label |
|---|---|---|---|
| E1 | `C:\Games\Cossacks 3\data\scripts\**` (os.walk) | 222 files / 4,373,442 B; all text-like; 177 `.inc`, 29 `.script`, 13 `.aix`, 1 `.global`, 1 `.source`, 1 `.txt` | [O] |
| E2 | `C:\Games\Cossacks 3\scripts\editor.inc\**` | 142 files / 523,316 B; all `.inc` (134 at root + 8 under `editor\`) | [O] |
| E3 | `C:\Games\Cossacks 3\data\gen\**` | 4,571 files / 172,373,799 B; 4,466 `.tga`, 87 `.bmp`, 8 `.removed`, 6 `.cfg`, 3 `.txt`, 1 `.bat` | [O] |
| E4 | `C:\Games\Cossacks 3\data\game\var\**` | 11 files / 1,948,790 B; all `.cfg` | [O] |
| E5 | `C:\Games\Cossacks 3\data\materials\**` | 866 files / 3,004,681,973 B; 844 `.dds`, 15 `.mat`, 1 `.lib`, 6 `.bmp` | [O] |
| E6 | `C:\Games\Cossacks 3\data\objects\**` | 1,290 files / 3,576,430 B; 1,285 `.prop`, 4 `.objects`, 1 `.lib` | [O] |
| E7 | `C:\Games\Cossacks 3\data\actors\**` | 5,220 files / 937,415,938 B; 3,897 `.osm`, 976 `.actor`, 335 `.oss`, 10 `.tlf`, 2 `.lib` | [O] |
| E8 | F03 §2 | 7 cfg files parsed: `gen\globalparams.cfg`, `gen\localparams.cfg`, `gen\mapcover.cfg`, `gen\tilesmooth.cfg`, `gen\tilesmooth_scripts.cfg`, `var\generator.cfg`, `var\startingsettings.cfg` | [O] |
| E9 | X03 §0 table | D1–D8 full (7 scripts + `var\generator.cfg`); D9 `data\scripts\lib\misc.script` targeted ranges only, 7,013 lines | [O] |
| E10 | F09 §0/§7 | 222 + 142 files keyword-indexed; terrain subset full-read; 367 files / 109,581 logical lines reported; `postprocesssaver.inc` explicitly not fully read (U11) | [O]/[U] |
| E11 | Pass 4 magic check | `.prop` (`data\objects\env\field.prop`) and `.actor` (`data\actors\ref\refobj.actor`) begin with plaintext `section.begin`; `.osm` (`data\actors\env\terrainmesh1.osm`) begins `IDP2` binary; `.removed` is binary TGA payload | [O] |
| E12 | Pass 4 citation intersection (all landed `docs\terrain_swarm_2026-11-26\**\*.md`) | 50/308 non-mask terrain-named basenames cited somewhere; 258 not cited; of 279 not opened by named three, 21 cited by other workers (D03/F04/F05/F07/F08/A04/D08/F10/X22) | [O]/[D] |
| E13 | X27 E6/E8 | Independent prior counts: X03 972 excerpts; F09 367 files / 109,581 lines; both inherited, not re-derived here | [O] |
| E14 | `data\gen\bitmap\postpatterns.cfg:1-24` | `Missions` records bind `PatternName = g_hil8 / g_frt_small_3 / d_stn_2 / big_hill_1` to `X/Y` | [O] |

## 2. Coverage numbers

### 2.1 Inventory by tree (all `[O]`, read-only `os.stat`)

| Donor tree (`C:\Games\Cossacks 3\…`) | Files | Bytes | Core-text files | Core-text bytes | Terrain-named files |
|---|---:|---:|---:|---:|---:|
| `data\scripts\**` | 222 | 4,373,442 | 222 | 4,373,442 | 5 |
| `data\gen\**` | 4,571 | 172,373,799 | 9 | 340,741 | 4,479 |
| `data\game\var\**` | 11 | 1,948,790 | 11 | 1,948,790 | 1 |
| `scripts\editor.inc\**` | 142 | 523,316 | 142 | 523,316 | 21 |
| `data\materials\**` | 866 | 3,004,681,973 | 16 | 226,413 | 63 |
| `data\objects\**` | 1,290 | 3,576,430 | 1 | 1,687 | 90 |
| `data\actors\**` | 5,220 | 937,415,938 | 2 | 175,781 | 115 |
| **TOTAL** | **12,322** | **4,124,893,688** | **403** | **7,590,170** | **4,774** |

### 2.2 Coverage percentage — three honest denominators

| Denominator | Files | Bytes | Lines | Opened by named three | File % | Byte % | Line % |
|---|---:|---:|---:|---|---:|---:|---:|
| All files in 7 trees | 12,322 | 4,124,893,688 | — | 371 files / 5,152,806 B | **3.0%** | **0.12%** | — |
| Core text (`.cfg/.inc/.script/.global/.source/.aix/.mat/.lib/.txt`) | 403 | 7,590,170 | 191,538 | 371 files / 5,152,806 B / 113,945 lines | **92.1%** | **67.9%** | **59.5%** |
| Wide text (core + `.prop/.actor/.objects`, all plaintext `[O]` E11) | 2,668 | 12,300,968 | 314,056 | 371 files / 5,152,806 B / 113,945 lines | **13.9%** | **41.9%** | **36.3%** |

**[D] Opening is not reading.** Sub-division of the 403 core-text files:

| Depth of read | Unique files | % of 403 | Bytes | % of 7,590,170 | Basis |
|---|---:|---:|---:|---:|---|
| Keyword-indexed only (F09) | 346 | 85.9% | 4,315,538 | 56.9% | F09 §0/§7: 364 files minus the 18 F09-tree files that X03/F09 line-cite |
| Line-cited / targeted / full | 25 | 6.2% | 837,268 | 11.0% | X03 8 full + `misc.script` targeted; F03 7 full; F09 10 editor `.inc` line-cited (minus 1 overlap) |
| Of which strictly full-read by X03+F03 | 14 | 3.5% | 517,106 | 6.8% | E8+E9, `generator.cfg` counted once |
| Never opened by named three | 32 | 7.9% | 2,437,364 | 32.1% | §4.2 table |

**[D] Read depth for terrain-named files:** 308 non-mask terrain-named files → 29 opened (9.4%) → 25 of those line-cited/indexed within F03/X03/F09 file sets; 279 not opened (90.6%, 134,497,720 B); 258 not cited by any landed report (83.8%).

## 3. Multiple passes on count contradictions (owner directive)

| # | Contradiction | Passes | Accepted reading | Label |
|---|---|---|---|---|
| C1 | "TEXT corpus": 403 vs 407 vs 2,668 files | Pass 1 used a text-extension set excluding `.objects` (403 / 7,590,170 B); Pass 2 added `.objects` (407 / 7,687,162 B); Pass 4 sampled magic bytes and proved `.prop`/`.actor`/`.objects` are plaintext, giving wide corpus 2,668 / 12,300,968 B | **Report both**: core=403 (script/config/material/lib/txt), wide=2,668 (adds `.prop/.actor/.objects`), with 407 as the intermediate `.objects`-only variant. Never call one number "the" corpus without naming its extension set | [O]/[D] |
| C2 | X03 "8 files fully" vs 9-row D1–D9 table | Pass 1 read X03 §0 table; Pass 2 re-read X03 §0 D9 row and §2b E21 | **8 full** (D1–D8; 7 scripts + `var\generator.cfg`) + **1 targeted** (`data\scripts\lib\misc.script`, 7,013 lines, E21 ranges only) | [O] |
| C3 | F09 "367 files / 109,581 lines" vs measured 364 / 106,073 | Pass 3 `os.walk` two trees = 364 files, 106,073 `\n`-split lines; Pass 5 added `scripts\editor.aix` (2,879) + `data\gui\menu.inc\donewgame.inc` (172) = 109,124; searched `data\gui` for a 457-line candidate (22 files in 300–650 range, none uniquelydetermined) | **Accept 364 files in-scope [O]; 109,124 lines reproducible; 457-line residual [U]**, likely one adjacent file or a logical-vs-physical line convention. Preserve F09's 109,581 as reported, do not silently replace | [O]/[U] |
| C4 | F03 "5 `data\gen` cfg" vs 6 `.cfg` in `data\gen\**` | Pass 1 extension census (6); Pass 2 per-file list; Pass 5 read `data\gen\bitmap\postpatterns.cfg:1-24` | F03 parsed the **5 root-level** `data\gen\*.cfg`; the 6th is `data\gen\bitmap\postpatterns.cfg` (269,140 B) and was **never opened** by F03/F09/X03 | [O] |
| C5 | Terrain-named 4,774 vs 308 vs 258 | Pass 1 keyword-on-stem (4,774); Pass 3 excluded 4,466 `data\gen\terrainmasks*\**\*.tga` (F04 decoded) → 308; Pass 4 intersect with named-worker sets → 29 opened / 279 not; intersect basenames with all landed report text → 258 uncited, 21 cited elsewhere | All four numbers true at different granularities; cite with the filter stated | [O]/[D] |
| C6 | F09 "142 editor.inc files / 222 data/scripts files" vs inventory | Pass 1 and Pass 3 both returned 142 and 222 exactly | **Confirmed [O]**; no contradiction | [O] |

## 4. Unread terrain-relevant files

**Name filter [O]:** case-insensitive stem contains one of `terrain, relief, water, tile, mask, pattern, field, forest, stone, mine, season, generator, collision`. **"Opened"** = file lies under F09's two indexed trees or is one of F03's 7 configs (X03 files are subsets). **"Cited elsewhere"** = basename occurs in any landed report/spec markdown (Pass 4); this is weaker than "read in full" and is used only to avoid calling a file untouched when another worker quoted it.

### 4.1 Aggregate by family (all bytes `[O]`)

| Family / representative donor path | Not opened by X03/F09/F03 | Bytes | Cited elsewhere | One-line triage verdict |
|---|---:|---:|---:|---|
| `C:\Games\Cossacks 3\data\gen\bitmap\postpatterns.cfg` | 1 | 269,140 | 0 | **NEEDS READ** (authored-mission pattern scatter; cheap; low skirmish impact) |
| `C:\Games\Cossacks 3\data\gen\terrainmasks*\**\*.removed` (4 per folder × 2) | 8 | 336,276 | 0 | **NEEDS READ** — same RLE-TGA decoder as F04/D03; earlier `_gauss` variants |
| `C:\Games\Cossacks 3\data\gen\bitmap\ext\tile_lowground.bmp`, `tile_highground.bmp` | 2 | 614,512 | 2 | **LIKELY IRRELEVANT** — already R-channel decoded by D08 §4.4 |
| `C:\Games\Cossacks 3\data\objects\**\*.prop` (terrain-named) | 90 | 360,846 | 7 | **NEEDS READ** — plaintext prop bindings (mesh/material/scale/decal); focus uncited winter/desert variants |
| `C:\Games\Cossacks 3\data\actors\**\*.actor` (terrain-named) | 28 | 21,174 | 4 | **NEEDS READ** — plaintext actor→mesh LOD mapping; cheap |
| `C:\Games\Cossacks 3\data\materials\env\*.dds` (terrain/water/mine/stone/forest/field-named) | 63 | 130,436,608 | 15 | **LIKELY IRRELEVANT for summer skirmish**; **NEEDS READ** only if winter/desert art is in scope (DDS is readable, not packed) |
| `C:\Games\Cossacks 3\data\actors\**\*.osm` (terrain-named) | 81 | 2,440,276 | 6 | **BLOCKED BY PACKED FORMAT** — proprietary `IDP2` mesh (E11); needs the existing in-memory decoder, not a text read |
| `C:\Games\Cossacks 3\data\actors\**\*.oss` (terrain-named) | 6 | 18,888 | 0 | **BLOCKED BY PACKED FORMAT** — binary animation stream; no text-level triage possible |
| `C:\Games\Cossacks 3\scripts\editor.inc\**` (terrain-named `.inc`, F09-indexed only) | 12 | 26,146 | 0 | **NEEDS READ** — editor algorithms (plateau grid, terrain data save/load, collision tools) not line-cited by F09 |
| `C:\Games\Cossacks 3\data\scripts\misc\projectile.inc\onterraincollide.inc` | 1 | 536 | 0 | **LIKELY IRRELEVANT** — projectile collision handler, not terrain generation |
| **TOTAL non-mask terrain-named not opened** | **279** | **134,497,720** | **21** | — |

**[D] Explicit exclusion:** the 4,466 `.tga` files under `data\gen\terrainmasks\`, `terrainmasks.dlc5\` and `terrainmasks.src\` match the name filter but were **full-corpus pixel-decoded by F04** (X27 E11). They are *not* counted in the unread set. Their `moddersread.txt` companions were read by D03/F04/F10, though not by the three named workers.

### 4.2 Each unopened core-text file (32 rows)

Verdict key: **NR** = NEEDS READ; **LI** = LIKELY IRRELEVANT; **BP** = BLOCKED BY PACKED FORMAT (none in this table).

| Donor path (`C:\Games\Cossacks 3\…`) | Bytes | Name-keyword | Why it might matter | Verdict |
|---|---:|---|---|---|
| `data\gen\bitmap\postpatterns.cfg` | 269,140 | pattern | `Missions→PatternName/X/Y` binds relief/forest/stone motifs to authored maps (`:4-24`); absent from F03's cfg set | **NR** (authored only) |
| `data\gen\terrainmasks\moddersread.txt` | 849 | folder `terrain` | Documents `_gauss` 256²→320² mask production; content already quoted by D03 E02/F04 E1 | **LI** (landed via other workers) |
| `data\gen\terrainmasks.dlc5\moddersread.txt` | 849 | folder `terrain` | Same convention for DLC5 masks; quoted by F10 E11 | **LI** |
| `data\gen\terrainmasks.src\moddersread.txt` | 849 | folder `terrain` | Same convention for source (256²) masks | **LI** |
| `data\game\var\battles.cfg` | 47,340 | — | Scenario battle definitions; may reference authored terrain but no generator constants | **LI** |
| `data\game\var\campaigns.cfg` | 42,925 | — | Campaign metadata; not a terrain-generation source | **LI** |
| `data\game\var\envscales.cfg` | 25,612 | — | Prop/object scale table; A04 E14 cites `:16-36`, F08 cites `:161-255` — full read would settle scale constants | **NR** |
| `data\game\var\formations.cfg` | 63,886 | — | Unit formations | **LI** |
| `data\game\var\hotkeys.cfg` | 5,316 | — | Input bindings | **LI** |
| `data\game\var\objcustom.cfg` | 1,564,524 | — | Object customisation overrides; could affect terrain prop appearance, no cited terrain lines | **LI** (medium value, large) |
| `data\game\var\random.cfg` | 51 | — | Tiny random-map toggle/config candidate | **NR** (cheap) |
| `data\game\var\units.cfg` | 258 | — | Unit table | **LI** |
| `data\game\var\wallcustom.cfg` | 11,884 | — | Wall customisation | **LI** |
| `data\materials\materials.lib` | 695 | — | Index of `.mat` libraries; resolves which `.mat` governs env/terrain | **NR** (cheap) |
| `data\materials\buildings\buildings.mat` | 84,978 | — | Building materials; not terrain-class art | **LI** |
| `data\materials\env\env.mat` | 70,044 | — | Field crop, water, mine and terrain materials; F07 E18 cites `:50-149,864-973` only | **NR** (full) |
| `data\materials\misc\misc.mat` | 2,581 | — | Misc materials | **LI** |
| `data\materials\pfx\pfx.mat` | 14,324 | — | Particle FX materials (snow FX is not the editor snow brush — F09 §2.6) | **LI** |
| `data\materials\ref\refbase.mat` | 2,774 | — | Material reference template | **LI** |
| `data\materials\ref\refbuilding.mat` | 2,780 | — | Reference template | **LI** |
| `data\materials\ref\refbuildingnormal.mat` | 3,077 | — | Reference template | **LI** |
| `data\materials\ref\refcubemap.mat` | 1,514 | — | Reference template | **LI** |
| `data\materials\ref\refmipmap.mat` | 11,140 | — | Reference template; mip policy may affect terrain tiles | **NR** (low) |
| `data\materials\ref\refmountainnormal.mat` | 3,099 | — | Mountain normal-map template (name filter misses "mountain"); relief shading | **NR** (cheap) |
| `data\materials\ref\refnormal.mat` | 1,167 | — | Normal-map template | **LI** |
| `data\materials\ref\refnormalmap.mat` | 907 | — | Normal-map template | **LI** |
| `data\materials\ref\refpfx.mat` | 260 | — | PFX template | **LI** |
| `data\materials\ref\refunit.mat` | 2,812 | — | Unit template | **LI** |
| `data\materials\units\units.mat` | 24,261 | — | Unit materials | **LI** |
| `data\objects\objects.lib` | 1,687 | — | Object-library index → `.objects` files, incl. `env.objects` | **NR** (cheap) |
| `data\objects\buildings\buildings.objects` | 50,564 | — | Building object registry | **LI** |
| `data\objects\env\env.objects` | 25,609 | — | Environment prop registry (terrainmesh/mine/stone/field); A04 cites `:2-4,337-339` only | **NR** (full) |
| `data\objects\misc\misc.objects` | 2,802 | — | Misc object registry | **LI** |
| `data\objects\units\units.objects` | 18,017 | — | Unit object registry | **LI** |
| `data\actors\actors.lib` | 175,040 | — | Actor/LOD registry; A01 E15/A04 E24/F08 quote `:1200-1229`, `:1517`, `:1589` only | **NR** (full for winter/desert LODs) |
| `data\actors\ref\refactors.lib` | 741 | — | Actor reference template (LOD/material library defaults) | **NR** (cheap) |

**Table count check [O]:** 4 (`data\gen`) + 9 (`data\game\var`) + 16 (`data\materials`) + 5 (`data\objects`) + 2 (`data\actors`) = **36 rows**. The `403 − 371 = 32` figure in §2.2 counts only the *core* extension set; the table additionally includes 4 plaintext `.objects` files from the wide set (`buildings.objects`, `env.objects`, `misc.objects`, `units.objects`) so that every unopened object registry is visible. Both counts are preserved, not reconciled away.

### 4.3 Complete per-file appendix

Appendix A below lists **all 279 non-mask terrain-named files not opened by X03/F09/F03**, with byte size and the triage verdict explicitly. It is generated from the same Pass-3/Pass-4 inventory and citation intersection; no donor file was modified.

**Verdict codes:** **NR** = NEEDS READ; **LI** = LIKELY IRRELEVANT (for summer skirmish); **BP** = BLOCKED BY PACKED FORMAT (proprietary binary, needs a decoder). Paths are relative to `C:\Games\Cossacks 3\`. "cited" = basename occurs in at least one landed report/spec markdown (weaker than a full read).

| Donor path (relative) | Bytes | Keyword(s) | Why it might matter | Verdict |
|---|---:|---|---|---|
| `data\actors\env\field.actor` | 663 | field | Plaintext actor-to-mesh LOD binding for a terrain family; cited elsewhere (not by X03/F09/F03) | **NR** |
| `data\actors\env\grassforest.actor` | 1179 | forest | Plaintext actor-to-mesh LOD binding for a terrain family | **NR** |
| `data\actors\env\grassleafforest.actor` | 723 | forest | Plaintext actor-to-mesh LOD binding for a terrain family | **NR** |
| `data\actors\env\landstone.actor` | 927 | stone | Plaintext actor-to-mesh LOD binding for a terrain family | **NR** |
| `data\actors\env\minecoal.actor` | 226 | mine | Plaintext actor-to-mesh LOD binding for a terrain family | **NR** |
| `data\actors\env\minegold.actor` | 226 | mine | Plaintext actor-to-mesh LOD binding for a terrain family; cited elsewhere (not by X03/F09/F03) | **NR** |
| `data\actors\env\mineiron.actor` | 226 | mine | Plaintext actor-to-mesh LOD binding for a terrain family | **NR** |
| `data\actors\env\smallstones.actor` | 1425 | stone | Plaintext actor-to-mesh LOD binding for a terrain family | **NR** |
| `data\actors\env\smallstonessea.actor` | 1461 | stone | Plaintext actor-to-mesh LOD binding for a terrain family | **NR** |
| `data\actors\env\stones.actor` | 2291 | stone | Plaintext actor-to-mesh LOD binding for a terrain family; cited elsewhere (not by X03/F09/F03) | **NR** |
| `data\actors\env\stonessea.actor` | 2351 | stone | Plaintext actor-to-mesh LOD binding for a terrain family | **NR** |
| `data\actors\env\terrainmesh1.actor` | 237 | terrain | Plaintext actor-to-mesh LOD binding for a terrain family; cited elsewhere (not by X03/F09/F03) | **NR** |
| `data\actors\env\terrainmesh2.actor` | 223 | terrain | Plaintext actor-to-mesh LOD binding for a terrain family | **NR** |
| `data\actors\env\terrainmesh3.actor` | 223 | terrain | Plaintext actor-to-mesh LOD binding for a terrain family | **NR** |
| `data\actors\env\terrainmesh4.actor` | 223 | terrain | Plaintext actor-to-mesh LOD binding for a terrain family | **NR** |
| `data\actors\env\terrainplateau1.actor` | 229 | terrain | Plaintext actor-to-mesh LOD binding for a terrain family | **NR** |
| `data\actors\env\terrainplateau2.actor` | 229 | terrain | Plaintext actor-to-mesh LOD binding for a terrain family | **NR** |
| `data\actors\env\terrainplateau3.actor` | 229 | terrain | Plaintext actor-to-mesh LOD binding for a terrain family | **NR** |
| `data\actors\env\terrainplateau4.actor` | 229 | terrain | Plaintext actor-to-mesh LOD binding for a terrain family | **NR** |
| `data\actors\misc\ptborderwater.actor` | 221 | water | Plaintext actor-to-mesh LOD binding for a terrain family | **NR** |
| `data\actors\pfx\debris\debris_stone.actor` | 5468 | stone | Plaintext actor-to-mesh LOD binding for a terrain family | **NR** |
| `data\actors\pfx\impact\impwaterlarge1.actor` | 310 | water | Plaintext actor-to-mesh LOD binding for a terrain family | **NR** |
| `data\actors\pfx\impact\impwaterlarge2.actor` | 310 | water | Plaintext actor-to-mesh LOD binding for a terrain family | **NR** |
| `data\actors\pfx\impact\impwaterlarge3.actor` | 310 | water | Plaintext actor-to-mesh LOD binding for a terrain family | **NR** |
| `data\actors\pfx\impact\impwatersmall1.actor` | 310 | water | Plaintext actor-to-mesh LOD binding for a terrain family | **NR** |
| `data\actors\pfx\impact\impwatersmall2.actor` | 310 | water | Plaintext actor-to-mesh LOD binding for a terrain family | **NR** |
| `data\actors\pfx\impact\impwatersmall3.actor` | 310 | water | Plaintext actor-to-mesh LOD binding for a terrain family | **NR** |
| `data\actors\ref\refstone.actor` | 105 | stone | Plaintext actor-to-mesh LOD binding for a terrain family | **NR** |
| `data\actors\buildings\commonrus\eurswa_gatecollision.osm` | 40324 | collision | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\field1.osm` | 26524 | field | Proprietary IDP2 mesh payload for a terrain family; cited elsewhere (not by X03/F09/F03) | **BP** |
| `data\actors\env\field2.osm` | 23932 | field | Proprietary IDP2 mesh payload for a terrain family; cited elsewhere (not by X03/F09/F03) | **BP** |
| `data\actors\env\field3.osm` | 26308 | field | Proprietary IDP2 mesh payload for a terrain family; cited elsewhere (not by X03/F09/F03) | **BP** |
| `data\actors\env\grassforest1.osm` | 178116 | forest | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\grassforest2.osm` | 172476 | forest | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\grassforest3.osm` | 145876 | forest | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\grassforest4.osm` | 100276 | forest | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\grassforest5.osm` | 82668 | forest | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\grassleafforest1.osm` | 55156 | forest | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\grassleafforest2.osm` | 69908 | forest | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\grassleafforest3.osm` | 95316 | forest | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\landstone1.osm` | 11044 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\landstone2.osm` | 13708 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\landstone3.osm` | 13860 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\landstone4.osm` | 10180 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\minecoal.osm` | 55876 | mine | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\minegold.osm` | 55876 | mine | Proprietary IDP2 mesh payload for a terrain family; cited elsewhere (not by X03/F09/F03) | **BP** |
| `data\actors\env\mineiron.osm` | 55876 | mine | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\smallstones1.osm` | 11044 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\smallstones2.osm` | 13708 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\smallstones3.osm` | 13860 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\smallstones4.osm` | 10180 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\smallstones5.osm` | 15588 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\smallstones6.osm` | 12820 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\smallstonessea1.osm` | 11044 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\smallstonessea2.osm` | 13708 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\smallstonessea3.osm` | 13860 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\smallstonessea4.osm` | 10180 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\smallstonessea5.osm` | 15588 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\smallstonessea6.osm` | 12820 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\stones1.osm` | 9500 | stone | Proprietary IDP2 mesh payload for a terrain family; cited elsewhere (not by X03/F09/F03) | **BP** |
| `data\actors\env\stones10.osm` | 4140 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\stones2.osm` | 7316 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\stones3.osm` | 2796 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\stones4.osm` | 7492 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\stones5.osm` | 10308 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\stones6.osm` | 4324 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\stones7.osm` | 13532 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\stones8.osm` | 12012 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\stones9.osm` | 8324 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\stonessea1.osm` | 7644 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\stonessea10.osm` | 5740 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\stonessea2.osm` | 7620 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\stonessea3.osm` | 3308 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\stonessea4.osm` | 7420 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\stonessea5.osm` | 9500 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\stonessea6.osm` | 4460 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\stonessea7.osm` | 11764 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\stonessea8.osm` | 7060 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\stonessea9.osm` | 5476 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\terrainmesh1.osm` | 191356 | terrain | Proprietary IDP2 mesh payload for a terrain family; cited elsewhere (not by X03/F09/F03) | **BP** |
| `data\actors\env\terrainmesh2.osm` | 163452 | terrain | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\terrainmesh3.osm` | 156092 | terrain | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\terrainmesh4.osm` | 201604 | terrain | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\terrainplateau1.osm` | 25540 | terrain | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\terrainplateau2.osm` | 15788 | terrain | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\terrainplateau3.osm` | 45340 | terrain | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\env\terrainplateau4.osm` | 46444 | terrain | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\misc\ptborderwater.osm` | 5540 | water | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\pfx\debris\debris_stone_1.osm` | 5204 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\pfx\debris\debris_stone_10.osm` | 3172 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\pfx\debris\debris_stone_11.osm` | 2452 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\pfx\debris\debris_stone_12.osm` | 1252 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\pfx\debris\debris_stone_13.osm` | 1252 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\pfx\debris\debris_stone_14.osm` | 1396 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\pfx\debris\debris_stone_15.osm` | 1252 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\pfx\debris\debris_stone_16.osm` | 1988 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\pfx\debris\debris_stone_17.osm` | 1012 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\pfx\debris\debris_stone_18.osm` | 2500 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\pfx\debris\debris_stone_19.osm` | 1204 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\pfx\debris\debris_stone_2.osm` | 5188 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\pfx\debris\debris_stone_20.osm` | 1012 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\pfx\debris\debris_stone_21.osm` | 1252 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\pfx\debris\debris_stone_3.osm` | 7540 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\pfx\debris\debris_stone_4.osm` | 4916 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\pfx\debris\debris_stone_5.osm` | 1444 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\pfx\debris\debris_stone_6.osm` | 1444 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\pfx\debris\debris_stone_7.osm` | 1444 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\pfx\debris\debris_stone_8.osm` | 1444 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\pfx\debris\debris_stone_9.osm` | 3316 | stone | Proprietary IDP2 mesh payload for a terrain family | **BP** |
| `data\actors\pfx\impact\impwaterlarge1.oss` | 3148 | water | Binary animation stream for a terrain prop | **BP** |
| `data\actors\pfx\impact\impwaterlarge2.oss` | 3148 | water | Binary animation stream for a terrain prop | **BP** |
| `data\actors\pfx\impact\impwaterlarge3.oss` | 3148 | water | Binary animation stream for a terrain prop | **BP** |
| `data\actors\pfx\impact\impwatersmall1.oss` | 3148 | water | Binary animation stream for a terrain prop | **BP** |
| `data\actors\pfx\impact\impwatersmall2.oss` | 3148 | water | Binary animation stream for a terrain prop | **BP** |
| `data\actors\pfx\impact\impwatersmall3.oss` | 3148 | water | Binary animation stream for a terrain prop | **BP** |
| `data\gen\bitmap\ext\tile_highground.bmp` | 307256 | tile | Tile detail bitmap; D08 already decoded the R channel; cited elsewhere (not by X03/F09/F03) | **LI** |
| `data\gen\bitmap\ext\tile_lowground.bmp` | 307256 | tile | Tile detail bitmap; D08 already decoded the R channel; cited elsewhere (not by X03/F09/F03) | **LI** |
| `data\gen\bitmap\postpatterns.cfg` | 269140 | pattern | Authored-mission pattern placement config (Missions/PatternName/X/Y); cited elsewhere (not by X03/F09/F03) | **NR** |
| `data\gen\terrainmasks.dlc5\mediterranean\4pl_mask_mediterranean_100_gauss.removed` | 46437 | mask | Earlier _gauss mask variant; RLE-TGA payload under a .removed name | **NR** |
| `data\gen\terrainmasks.dlc5\mediterranean\4pl_mask_mediterranean_75_gauss.removed` | 48422 | mask | Earlier _gauss mask variant; RLE-TGA payload under a .removed name | **NR** |
| `data\gen\terrainmasks.dlc5\mediterranean\4pl_mask_mediterranean_78_gauss.removed` | 36168 | mask | Earlier _gauss mask variant; RLE-TGA payload under a .removed name | **NR** |
| `data\gen\terrainmasks.dlc5\mediterranean\4pl_mask_mediterranean_95_gauss.removed` | 37111 | mask | Earlier _gauss mask variant; RLE-TGA payload under a .removed name | **NR** |
| `data\gen\terrainmasks\mediterranean\4pl_mask_mediterranean_100_gauss.removed` | 46437 | mask | Earlier _gauss mask variant; RLE-TGA payload under a .removed name | **NR** |
| `data\gen\terrainmasks\mediterranean\4pl_mask_mediterranean_75_gauss.removed` | 48422 | mask | Earlier _gauss mask variant; RLE-TGA payload under a .removed name | **NR** |
| `data\gen\terrainmasks\mediterranean\4pl_mask_mediterranean_78_gauss.removed` | 36168 | mask | Earlier _gauss mask variant; RLE-TGA payload under a .removed name | **NR** |
| `data\gen\terrainmasks\mediterranean\4pl_mask_mediterranean_95_gauss.removed` | 37111 | mask | Earlier _gauss mask variant; RLE-TGA payload under a .removed name | **NR** |
| `data\materials\env\field.dds` | 174928 | field | Authored seasonal/desert texture variant for a terrain prop family; cited elsewhere (not by X03/F09/F03) | **LI** |
| `data\materials\env\field1.dds` | 174928 | field | Authored seasonal/desert texture variant for a terrain prop family; cited elsewhere (not by X03/F09/F03) | **LI** |
| `data\materials\env\field1w.dds` | 174928 | field | Authored seasonal/desert texture variant for a terrain prop family; cited elsewhere (not by X03/F09/F03) | **LI** |
| `data\materials\env\field2.dds` | 174928 | field | Authored seasonal/desert texture variant for a terrain prop family; cited elsewhere (not by X03/F09/F03) | **LI** |
| `data\materials\env\field2w.dds` | 174928 | field | Authored seasonal/desert texture variant for a terrain prop family; cited elsewhere (not by X03/F09/F03) | **LI** |
| `data\materials\env\field3.dds` | 174928 | field | Authored seasonal/desert texture variant for a terrain prop family; cited elsewhere (not by X03/F09/F03) | **LI** |
| `data\materials\env\field3w.dds` | 174928 | field | Authored seasonal/desert texture variant for a terrain prop family; cited elsewhere (not by X03/F09/F03) | **LI** |
| `data\materials\env\field4.dds` | 174928 | field | Authored seasonal/desert texture variant for a terrain prop family; cited elsewhere (not by X03/F09/F03) | **LI** |
| `data\materials\env\field4w.dds` | 174928 | field | Authored seasonal/desert texture variant for a terrain prop family; cited elsewhere (not by X03/F09/F03) | **LI** |
| `data\materials\env\field5.dds` | 174928 | field | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\env\field5w.dds` | 174928 | field | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\env\field6.dds` | 174928 | field | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\env\field6w.dds` | 174928 | field | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\env\field7.dds` | 174928 | field | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\env\field7w.dds` | 174928 | field | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\env\fieldw.dds` | 174928 | field | Authored seasonal/desert texture variant for a terrain prop family; cited elsewhere (not by X03/F09/F03) | **LI** |
| `data\materials\env\grassforest.dds` | 1398256 | forest | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\env\grassforestw.dds` | 1398256 | forest | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\env\grassleafforest.dds` | 1398256 | forest | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\env\grassleafforestw.dds` | 1398256 | forest | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\env\landstone.dds` | 174904 | stone | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\env\landstonew.dds` | 174904 | stone | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\env\minecoal.dds` | 5592560 | mine | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\env\minecoals.dds` | 5592560 | mine | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\env\minecoalw.dds` | 5592560 | mine | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\env\minegold.dds` | 5592560 | mine | Authored seasonal/desert texture variant for a terrain prop family; cited elsewhere (not by X03/F09/F03) | **LI** |
| `data\materials\env\minegolds.dds` | 5592560 | mine | Authored seasonal/desert texture variant for a terrain prop family; cited elsewhere (not by X03/F09/F03) | **LI** |
| `data\materials\env\minegoldw.dds` | 5592560 | mine | Authored seasonal/desert texture variant for a terrain prop family; cited elsewhere (not by X03/F09/F03) | **LI** |
| `data\materials\env\mineiron.dds` | 5592560 | mine | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\env\mineirons.dds` | 5592560 | mine | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\env\mineironw.dds` | 5592560 | mine | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\env\plantswateratlas.dds` | 1010160 | water | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\env\plantswateratlasw.dds` | 1010160 | water | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\env\smallstones.dds` | 174904 | stone | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\env\smallstonesdesert.dds` | 174904 | stone | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\env\smallstonesdesertw.dds` | 174904 | stone | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\env\smallstonessea.dds` | 174904 | stone | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\env\smallstonesseaw.dds` | 174904 | stone | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\env\smallstonesw.dds` | 174904 | stone | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\env\stones.dds` | 174904 | stone | Authored seasonal/desert texture variant for a terrain prop family; cited elsewhere (not by X03/F09/F03) | **LI** |
| `data\materials\env\stonesdesert.dds` | 174904 | stone | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\env\stonesdesertw.dds` | 174904 | stone | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\env\stonessea.dds` | 174904 | stone | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\env\stonesseaw.dds` | 174904 | stone | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\env\stonesw.dds` | 174904 | stone | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\env\terrainmesh1.dds` | 5592560 | terrain | Authored seasonal/desert texture variant for a terrain prop family; cited elsewhere (not by X03/F09/F03) | **LI** |
| `data\materials\env\terrainmesh1w.dds` | 5592560 | terrain | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\env\terrainmesh2.dds` | 5592560 | terrain | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\env\terrainmesh2w.dds` | 5592560 | terrain | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\env\terrainmesh3.dds` | 5592560 | terrain | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\env\terrainmesh3w.dds` | 5592560 | terrain | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\env\terrainmesh4.dds` | 5592560 | terrain | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\env\terrainmesh4w.dds` | 5592560 | terrain | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\env\terrainmeshdesert1.dds` | 5592560 | terrain | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\env\terrainmeshdesert2.dds` | 5592560 | terrain | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\env\terrainmeshdesert3.dds` | 5592560 | terrain | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\env\terrainmeshdesert4.dds` | 5592560 | terrain | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\pfx\impwaterlarge1.dds` | 22000 | water | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\pfx\impwaterlarge2.dds` | 22000 | water | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\pfx\impwaterlarge3.dds` | 22000 | water | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\pfx\impwatersmall1.dds` | 22000 | water | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\pfx\impwatersmall2.dds` | 22000 | water | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\materials\pfx\impwatersmall3.dds` | 22000 | water | Authored seasonal/desert texture variant for a terrain prop family | **LI** |
| `data\objects\env\field.prop` | 5216 | field | Plaintext prop binding: mesh/material/scale/decal for a terrain family; cited elsewhere (not by X03/F09/F03) | **NR** |
| `data\objects\env\grassforest.prop` | 3913 | forest | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\grassforest1.prop` | 3882 | forest | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\grassforest2.prop` | 3882 | forest | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\grassforest3.prop` | 3882 | forest | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\grassforest4.prop` | 3920 | forest | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\grassforest5.prop` | 3918 | forest | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\grassleafforest.prop` | 3065 | forest | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\grassleafforest1.prop` | 3070 | forest | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\grassleafforest2.prop` | 3070 | forest | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\grassleafforest3.prop` | 3070 | forest | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\landstone.prop` | 3433 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\landstone1.prop` | 3438 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\landstone2.prop` | 3438 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\landstone3.prop` | 3438 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\landstone4.prop` | 3438 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\minecoal.prop` | 1396 | mine | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\minecoals.prop` | 1401 | mine | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\minegold.prop` | 1398 | mine | Plaintext prop binding: mesh/material/scale/decal for a terrain family; cited elsewhere (not by X03/F09/F03) | **NR** |
| `data\objects\env\minegolds.prop` | 1403 | mine | Plaintext prop binding: mesh/material/scale/decal for a terrain family; cited elsewhere (not by X03/F09/F03) | **NR** |
| `data\objects\env\mineiron.prop` | 1398 | mine | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\mineirons.prop` | 1403 | mine | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\smallstones.prop` | 3939 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\smallstones1.prop` | 3947 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\smallstones2.prop` | 3947 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\smallstones3.prop` | 3947 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\smallstones4.prop` | 3944 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\smallstones5.prop` | 3944 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\smallstones6.prop` | 3944 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\smallstonesdesert.prop` | 4095 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\smallstonesdesert1.prop` | 4103 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\smallstonesdesert2.prop` | 4103 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\smallstonesdesert3.prop` | 4103 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\smallstonesdesert4.prop` | 4100 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\smallstonesdesert5.prop` | 4100 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\smallstonesdesert6.prop` | 4100 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\smallstonessea.prop` | 4218 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\smallstonessea1.prop` | 4226 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\smallstonessea2.prop` | 4226 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\smallstonessea3.prop` | 4226 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\smallstonessea4.prop` | 4223 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\smallstonessea5.prop` | 4223 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\smallstonessea6.prop` | 4223 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\stones.prop` | 5717 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family; cited elsewhere (not by X03/F09/F03) | **NR** |
| `data\objects\env\stones1.prop` | 5720 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family; cited elsewhere (not by X03/F09/F03) | **NR** |
| `data\objects\env\stones10.prop` | 5720 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\stones2.prop` | 5717 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\stones3.prop` | 5714 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\stones4.prop` | 5720 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\stones5.prop` | 5720 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\stones6.prop` | 5720 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\stones7.prop` | 5717 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\stones8.prop` | 5717 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\stones9.prop` | 5717 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\stonesdesert.prop` | 5969 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\stonesdesert1.prop` | 5972 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\stonesdesert10.prop` | 5972 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\stonesdesert2.prop` | 5969 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\stonesdesert3.prop` | 5966 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\stonesdesert4.prop` | 5972 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\stonesdesert5.prop` | 5972 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\stonesdesert6.prop` | 5972 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\stonesdesert7.prop` | 5969 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\stonesdesert8.prop` | 5969 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\stonesdesert9.prop` | 5969 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\stonessea.prop` | 5715 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\stonessea1.prop` | 5718 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\stonessea10.prop` | 5718 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\stonessea2.prop` | 5715 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\stonessea3.prop` | 5712 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\stonessea4.prop` | 5718 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\stonessea5.prop` | 5718 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\stonessea6.prop` | 5718 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\stonessea7.prop` | 5715 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\stonessea8.prop` | 5715 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\stonessea9.prop` | 5715 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\terrainmesh1.prop` | 757 | terrain | Plaintext prop binding: mesh/material/scale/decal for a terrain family; cited elsewhere (not by X03/F09/F03) | **NR** |
| `data\objects\env\terrainmesh2.prop` | 757 | terrain | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\terrainmesh3.prop` | 757 | terrain | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\terrainmesh4.prop` | 757 | terrain | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\terrainmeshdesert1.prop` | 787 | terrain | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\terrainmeshdesert2.prop` | 787 | terrain | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\terrainmeshdesert3.prop` | 787 | terrain | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\env\terrainmeshdesert4.prop` | 787 | terrain | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\misc\collision.prop` | 1602 | collision | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\misc\collision2x2.prop` | 887 | collision | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\misc\gatecollision.prop` | 2094 | collision | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\misc\pfx\debris_stone.prop` | 3380 | stone | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |
| `data\objects\misc\projectile.prop` | 764 | tile | Plaintext prop binding: mesh/material/scale/decal for a terrain family; cited elsewhere (not by X03/F09/F03) | **NR** |
| `data\objects\misc\ptborderwater.prop` | 2143 | water | Plaintext prop binding: mesh/material/scale/decal for a terrain family | **NR** |

**Appendix check [O]:** 279 rows, 134,497,720 bytes — matches §4.1 total (279 files / 134,497,720 B).

## 5. Ranked shortlist for a future worker

Ranking = (terrain relevance) × (probability the current port is wrong without it) × (cheapness of the read). All expected consequences are **PORT APPROXIMATION** until a donor frame exists.

| # | File(s) (`C:\Games\Cossacks 3\…`) | Bytes | Payoff | Verdict |
|---:|---|---:|---|---|
| 1 | `data\gen\bitmap\postpatterns.cfg` | 269,140 | Only unopened cfg in `data\gen\**`; explicit pattern→X/Y placement for authored missions; closes a real corpus hole | **NEEDS READ** |
| 2 | `data\objects\env\env.objects` + `data\objects\objects.lib` | 27,296 | Complete env prop list (terrainmesh, mine, stone, field) and library wiring; current evidence is 3 cited lines in A04 | **NEEDS READ** |
| 3 | `data\gen\terrainmasks\mediterranean\*.removed` and `terrainmasks.dlc5\mediterranean\*.removed` (8 files) | 336,276 | Earlier `_gauss` mask variants; F04/D03 decoder can be reused verbatim; may explain a 31-mask replacement discrepancy (X27 E16) | **NEEDS READ** |
| 4 | `scripts\editor.inc\plateaugenerator2.inc` | 13,844 | F09 read `plateaugenerator1/3` but not 2; `:4-18` gives a 4-unit plateau `cSize=4`, `cMapWidth=cMapHeight=320` auto-tiling grid — direct plateau algorithm | **NEEDS READ** |
| 5 | `scripts\editor.inc\loadmapterraindata.inc` / `savemapterraindata.inc` / `savetextureterraintobitmap.inc` | 6,735 | Authored-map terrain serialize/deserialize path; complements D04's `.map` record decode | **NEEDS READ** |
| 6 | `data\game\var\envscales.cfg` | 25,612 | Only partial reads today (A04/F08); full scale table influences mine/stone/tree sizing | **NEEDS READ** |
| 7 | `data\materials\env\env.mat` + `data\materials\ref\refmountainnormal.mat` + `materials.lib` | 74,438 | Terrain/water/mine/field material bindings and mountain normal template; F07 cited 200 lines of `env.mat` only | **NEEDS READ** |
| 8 | Uncited terrain-named `data\objects\env\*.prop` (83 files) | 339,871 | Plaintext mesh/material/scale/decal bindings incl. winter/desert variants; cheap bulk read | **NEEDS READ** (winter/desert scope) |
| 9 | `data\actors\ref\refactors.lib` + uncited `*.actor` (24) | 18,498 | Actor/LOD bindings for relief and mine families; cheap | **NEEDS READ** |
| 10 | Winter/desert `data\materials\env\*.dds` (48 uncited) | 106,142,184 | Visual variety only; no generator constant; expensive and not needed for summer skirmish | **LIKELY IRRELEVANT** unless scope expands |

## 6. Risks

| # | Risk | Label / evidence | Mitigation |
|---|---|---|---|
| R1 | 92.1% "file coverage" misread as 92% of donor text understood | F09 364 files were keyword-indexed, not full-read (E10); only 11.0% of core-text bytes line-cited | Always quote file %, byte %, and line-cited count together |
| R2 | Counting `.tga` masks as "unread terrain text" | 4,466 TGAs match the name filter but were decoded by F04 (X27 E11) | Exclude `data\gen\terrainmasks*\**\*.tga` and state the exclusion |
| R3 | "Cited elsewhere" promoted to "read in full" | Pass 4 basename matching cannot distinguish a one-line citation from a full read (E12) | Treat citation as a flag only; use "not opened by named three" as the hard claim |
| R4 | Wide-text denominator (2,668) confused with core-text (403) | `.prop`/`.actor`/`.objects` proved plaintext (E11) but were outside the three named workers' assignment | Name the extension set on every percentage |
| R5 | `.osm`/`.oss` treated as text because they sit beside plaintext `.prop` | `IDP2` binary magic (E11); X27 §3.4 says `.osm/.oss` need a decoder | Mark **BLOCKED BY PACKED FORMAT**, never "read" |
| R6 | F09 line residual suppressed | 457-line mismatch (C3) | Preserve as `[U]`; do not publish 109,581 as this worker's measurement |
| R7 | `postpatterns.cfg` assumed skirmish-relevant | Its records are `MissionName`-keyed (E14), not generator families | Verdict stays "authored-mission only; low skirmish impact" |
| R8 | Coverage report read as a parity statement | No donor execution, no GPU frame; all lines `;`-prefixed (spec/00 U10, X27 §4) | No parity claim; every port consequence labelled PORT APPROXIMATION |

## 7. Open questions

1. **COORD:** should `data\gen\bitmap\postpatterns.cfg` be assigned as a small standalone read (269 KB), or declared authored-mission-only out of scope?
2. **COORD/F04:** do the 8 `.removed` gauss variants belong to the 31 DLC5 mask replacements (X27 E16), or are they stale files? One decoder pass would settle it.
3. **F07/F08/A04:** can the 83 uncited `.prop` files be triaged in one batch read, and which are winter/desert-only?
4. **D04:** do `loadmapterraindata.inc` / `savemapterraindata.inc` describe the same binary payload as the `.map` serializer `sub_739d3c` (X27 E12), or a separate editor format?
5. **Owner:** is authored-map import in scope? If not, the `postpatterns.cfg`, plateau-generator and `.removed` shortlist items drop to LIKELY IRRELEVANT for skirmish.
6. **F09/COORD:** can the 457-line discrepancy in the 109,581-line index claim be resolved by naming the 367th file and the line convention? Currently `[U]`.
7. **D03/F04:** does `refmountainnormal.mat` bind a normal map used by the relief shader, or is it an unused reference template? Cheap to answer, relevant to relief shading.

## 8. Five-line summary (for COORD)

1. **[O]** 7 donor trees = 12,322 files / 4,124,893,688 B; core text = 403 files / 7,590,170 B, wide text (with plaintext `.prop/.actor/.objects`) = 2,668 files / 12,300,968 B.
2. **[O]** Named workers opened 371 core-text files (92.1% of files, 67.9% of bytes, 59.5% of lines); only 25 files / 837,268 B (6.2% / 11.0%) were line-cited or full-read, 14 strictly full.
3. **[O]** Terrain-named files = 4,774; 4,466 are F04-decoded masks; of the 308 others, 29 were opened and **279 (134,497,720 B) were not**, 258 of those uncited by any landed report.
4. **[D]** Top unread text: `data\gen\bitmap\postpatterns.cfg` (269,140 B), then `env.objects`/`objects.lib`, 8 `.removed` gauss masks, `plateaugenerator2.inc`, editor terrain save/load scripts and `envscales.cfg`.
5. **[U]** F09's 367 files / 109,581 lines vs measured 364 / 109,124 leaves a 457-line residual preserved as UNVERIFIED; all verdicts here are read-coverage facts, **PORT APPROXIMATION**, with no donor parity claim.

*End of X33 report. Exactly one repo file written (this report); donor trees accessed read-only; no donor binary executed or copied; no source, asset, config, test, git or Godot/runner state changed.*
