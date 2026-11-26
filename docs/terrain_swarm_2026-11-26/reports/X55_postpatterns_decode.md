---
id: X55-POSTPATTERNS-DECODE-2026-11-26
ticket: "TERRAIN-SWARM-2026-11-26 / X55 — read-only decode of data/gen/bitmap/postpatterns.cfg"
title: "X55 — postpatterns.cfg format, literals, and consumer gating: authored-map only, DEFERRED for skirmish"
agent: "X55 (read-only decoder, DONOR-FIRST terrain swarm)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_DONOR_BINARY__NO_GODOT_JOB
owner_file: docs/terrain_swarm_2026-11-26/reports/X55_postpatterns_decode.md
labels: [O, D, I, U, "PORT APPROXIMATION", DEFERRED]
parity_guard: "NO DONOR VISUAL PARITY CLAIM. No donor GPU A/B frame exists and no donor binary was executed. 'Read' means bytes/lines were decoded read-only; it does not prove a line executes in the shipped game or that the port matches it."
scope_guard: "Exactly one repo file written (this report). Donor at C:\\Games\\Cossacks 3 was opened read-only with Python os.stat/open('rb'); no donor file was written, copied or executed; no source/shader/config/asset/test/git/Godot-runner state touched. Scratch only in %TEMP%\\opencode\\postpatterns\\."
sources_read: "CHARTER.md; reports/X33_donor_text_coverage.md; reports/F03_gen_config.md; spec/04_PATTERN_STAMPING.md; spec/07_RESOURCES.md; donor postpatterns.cfg (full decode); donor generatemap.inc, dogenerate.inc, dogeneratemissionmap.inc, initmapgen.inc, common.aix, generator.cfg (targeted reads); whole-tree filename xref; cossacks.exe/editor.exe literal-string scan."
passes: "P1 byte/line census; P2 token-based struct parse with balance check; P3 value/range/family aggregation; P4 consumer xref in donor scripts; P5 whole-donor filename xref + EXE string scan; P6 contradiction passes C1–C8 (§3)."
verdict: "DEFERRED for skirmish terrain generation. The single consumer is gated by (cPostStandPatterns) and (not bRandomMap); skirmish/random maps take the bRandomMap=True branch. No counts/weights/thresholds from this file are needed by the fresh skirmish module."
---

# X55 — `postpatterns.cfg` decode (2026-11-26)

## 0. Executive summary

1. **[O]** `C:\Games\Cossacks 3\data\gen\bitmap\postpatterns.cfg` is **269,140 B**, 9,815 lines (9,814 CRLF + a final `section.end` with **no** trailing CRLF), **pure ASCII** (0 bytes >127), no BOM, no comments. It is one `section` → `Missions` struct → **51 mission records** → one `Patterns` struct each → **1,911 pattern records**. Balanced 1/1 `section.begin`/`section.end` and **2,014/2,014** `struct.begin`/`struct.end` pairs. No malformed record: every pattern record has exactly `PatternName`, `X`, `Y`. (§2)
2. **[O]** The complete key vocabulary is **four keys**: `MissionName` (×51), `PatternName` (×1,911), `X` (×1,911), `Y` (×1,911). There is **no `Freq`, `Prob`, `Weight`, bitmap/category, decal, radius, or threshold key** anywhere in the file. It is a pure authored *placement list*, not a weight table. (§2.1–§2.2)
3. **[O]** 40 distinct `PatternName` literals; all 40 resolve inside `generator.cfg`'s 467 distinct `Pattern` names (§2.5). Distribution: **1,452 mine** records (`mng_*`/`mni_*`/`mnc_*`, 76.0%), **441 stone** (`d_stn_1..7`), **8 stoneforest** (`str_new_1..8`), **10 one-off relief/forest** records — all confined to `engmis1`. `X`/`Y` are signed **integers**, global range **X −156…156, Y −155…155** (§2.4).
4. **[O]** The **only consumer in the entire donor tree** is `data\scripts\common.inc\generatemap.inc:711-768` and `:895-960`. Both blocks are gated **`if (cPostStandPatterns) and (not bRandomMap) then`** (`:711`, `:895`); the config path is loaded at `:714` and `:898`. `bRandomMap := BoolRegister0` (`:61`). Skirmish/random generation sets `BoolRegister0 := True` (`dogenerate.inc:1563`) → `ExecuteState('GenerateMap')` (`:1565`) → **postpatterns block skipped**. Authored mission-map generation sets `BoolRegister0 := False` (`dogeneratemissionmap.inc:4`) → block runs, with `missionname` taken from an **editor form field** (`generatemap.inc:95-98,105`). (§4)
5. **[D]** 49/51 `MissionName` literals have a matching `data\gen\bitmap\<name>.bmp` source bitmap (the two exceptions are `bonmis1`, `bonmis2`); this ties the file to the `GenerateMapFromBitmap` editor workflow. Random maps instead take the `else` branch at `generatemap.inc:139-174`, where `folderpath := StringRegister0` (the `.\data\gen\terrainmasks\...` path from `generator.cfg`) and `*.tga` masks are enumerated — **not** `data\gen\bitmap\*.bmp`. (§4.3)
6. **[U]** Both consumer blocks use the donor `.inc` encoding `[*] = ;<DScript>`; all cited consumer lines are `;`-prefixed. Per F03 U5 / X27 §4 this is donor *intent*, not proven runtime liveness. The `not bRandomMap` gate is nevertheless an unambiguous structural fact of that source. The filename literal does **not** appear in `cossacks.exe` or `editor.exe` as a byte string (§4.4).
7. **[D] / DEFERRED — no skirmish relevance.** The file is an authored/saved-mission-map post-processing list. It supplies **no** seed, RNG, relief amplitude, tile weight, water threshold, mine-count constant, or forest/decal weight. The fresh skirmish module needs **nothing** from it. If authored-map generation is later scoped, §5 gives the literal numbers with citations. **No parity claim.**

---

## 1. Evidence table

| Id | Source / donor path | What it establishes | Label |
|---|---|---|---|
| E1 | `data\gen\bitmap\postpatterns.cfg` full byte decode | 269,140 B; 9,815 lines; 0 non-ASCII; 1 section; 51 missions; 1,911 records; balanced structs | [O] |
| E2 | `postpatterns.cfg:1-25` | Verbatim grammar: `section.begin` → `Missions : struct.begin` → `[*]` → `MissionName` → `Patterns : struct.begin` → `[*]` → `PatternName`/`X`/`Y` → `struct.end` | [O] |
| E3 | `postpatterns.cfg:4,64,…,9610` (51 rows, §2.3) | Exact `MissionName` literals and per-mission record counts | [O] |
| E4 | `postpatterns.cfg:7,…,9809` (40 rows, §2.5) | Exact distinct `PatternName` literals, counts, first-occurrence lines | [O] |
| E5 | `postpatterns.cfg:3198`/`:1608`/`:1594`/`:5449` | Global coordinate extremes X −156/+156, Y −155/+155 | [O] |
| E6 | `data\scripts\common.inc\generatemap.inc:49,61,711-768` | Gate `(cPostStandPatterns) and (not bRandomMap)`; load `:714`; `MissionName` match `:722-723`; X/Y read as Float `:730-731`; mine `r=5` forest-mask clearing `:733-750`; forest mask clear `:754-767` | [O] text / [U] liveness |
| E7 | `generatemap.inc:895-960` | Second gated block: load `:898`; match `:904-905`; mine `r=3` object destruction `:915-936`; `y+3` high-tree removal `:937-953`; `_misc_CheckStandPattern` `:956` | [O] text / [U] liveness |
| E8 | `generatemap.inc:68-138` | `missionname` comes from `EditorFormClear/AddEditorFormInput('missionname','Mission Name',…)` and `GetEditorFormValue` | [O] text / [U] liveness |
| E9 | `generatemap.inc:139-174`; `dogenerate.inc:1563-1565` | Random branch uses `StringRegister0` mask folder + `*.tga`; skirmish sets `BoolRegister0 := True` before `GenerateMap` | [O] text / [U] liveness |
| E10 | `dogeneratemissionmap.inc:2-6`; `common.aix:51-61`; `initmapgen.inc:232` | `DoGenerateMissionMap` sets `BoolRegister0 := False`; both states registered; `initmapgen` calls `DoGenerate` | [O] text / [U] liveness |
| E11 | Whole-donor filename xref (case-insensitive, media skipped) | `postpatterns.cfg` occurs in **exactly one** file: `generatemap.inc` (6 distinct lines: 713,714,715,897,898,899) | [O] |
| E12 | `cossacks.exe` / `editor.exe` raw byte scan | `postpatterns`/`postpatterns.cfg`/`MissionName` literal: **0 hits** in both; `PatternName` present (DScript procedure names) | [O] |
| E13 | `parser` cross-check vs `var\generator.cfg` | All 40 postpattern names ∈ 467 distinct `Pattern` names; none new | [O]/[D] |
| E14 | `data\gen\bitmap\*.bmp` listing vs E3 | 49/51 mission names have a matching `<name>.bmp`; `bonmis1`, `bonmis2` do not | [O] |

---

## 2. Format decode

### 2.1 Grammar (`[O]`, `postpatterns.cfg:1-25` verbatim)

```
   1: section.begin
   2:    Missions : struct.begin
   3:       [*] : struct.begin
   4:          MissionName = engmis1
   5:          Patterns : struct.begin
   6:             [*] : struct.begin
   7:                PatternName = g_hil8
   8:                X = -23
   9:                Y = 136
  10:             struct.end
  11:             [*] : struct.begin
  12:                PatternName = g_frt_small_3
  13:                X = 69
  14:                Y = 45
  15:             struct.end
  16:             [*] : struct.begin
  17:                PatternName = d_stn_2
  18:                X = 62
  19:                Y = 52
  20:             struct.end
  21:             [*] : struct.begin
  22:                PatternName = big_hill_1
  23:                X = 18
  24:                Y = -21
  25:             struct.end
```

Template `[O]`:

```
section.begin
   Missions : struct.begin
      [*] : struct.begin                 // mission
         MissionName = <string>
         Patterns : struct.begin
            [*] : struct.begin           // placement
               PatternName = <string>
               X = <signed integer>
               Y = <signed integer>
            struct.end
            ... repeat ...
         struct.end
      struct.end
      ... repeat mission ...
   struct.end
section.end
```

Tail verbatim `[O]`: `postpatterns.cfg:9807-9811` is the last record (`mnc_5`, `X = 59`, `Y = -76`), followed by `:9812` `struct.end` (Patterns), `:9813` `struct.end` (mission `scemis12`), `:9814` `struct.end` (Missions), `:9815` `section.end` (no trailing CRLF).

### 2.2 Structural census (`[O]`, full-file token count)

| Token | Count |
|---|---:|
| `section.begin` / `section.end` | 1 / 1 |
| `Missions : struct.begin` | 1 |
| `Patterns : struct.begin` | 51 |
| `[*] : struct.begin` (mission + pattern records) | 1,962 = 51 + 1,911 |
| `struct.end` | 2,014 |
| `struct.begin` (all variants) | 1 + 51 + 1,911 = **2,014** — balanced |
| `MissionName` / `PatternName` / `X` / `Y` keys | 51 / 1,911 / 1,911 / 1,911 |
| comment lines (`//`, `;`, `#`) | 0 |
| blank lines | 1 (`:7918`, §3 C2) |
| malformed records | 0 |

### 2.3 Exact `MissionName` literals with line numbers (`[O]`)

`n` = number of `PatternName/X/Y` records in that mission; `mine/stone/decor` are `[I]` name-prefix groupings (mine = `mng|mni|mnc` substring; stone = `d_stn_*`; decor = the 18 remaining one-offs).

| line | MissionName | n | mine | stone | decor | X range | Y range |
|---:|---|---:|---:|---:|---:|---|---|
| 4 | `engmis1` | 11 | 0 | 1 | 10 | −116…69 | −127…136 |
| 64 | `rusmis4` | 60 | 45 | 7 | 8 | −145…145 | −131…140 |
| 369 | `engmis2` | 33 | 26 | 7 | 0 | −152…149 | −152…149 |
| 539 | `engmis4` | 7 | 7 | 0 | 0 | −76…104 | 55…129 |
| 579 | `ausmis1` | 17 | 14 | 3 | 0 | −139…150 | −146…142 |
| 669 | `ausmis2` | 31 | 21 | 10 | 0 | −145…142 | −134…140 |
| 829 | `ausmis3` | 24 | 16 | 8 | 0 | −142…132 | −143…142 |
| 954 | `ukrmis1` | 11 | 8 | 3 | 0 | −98…96 | −145…116 |
| 1014 | `ukrmis5` | 3 | 0 | 3 | 0 | −7…66 | −58…40 |
| 1034 | `rusmis5` | 11 | 7 | 4 | 0 | −142…111 | −121…147 |
| 1094 | `framis4` | 16 | 12 | 4 | 0 | −52…154 | −142…153 |
| 1179 | `framis5` | 12 | 9 | 3 | 0 | −103…143 | −53…104 |
| 1244 | `tutmis1` | 10 | 7 | 3 | 0 | −105…−7 | −119…64 |
| 1299 | `bonmis3` | 45 | 30 | 15 | 0 | −152…151 | −154…152 |
| 1529 | `bonmis1` | 62 | 47 | 15 | 0 | −155…156 | −150…155 |
| 1844 | `bonmis2` | 50 | 36 | 14 | 0 | −152…155 | −148…150 |
| 2099 | `polmis1` | 28 | 23 | 5 | 0 | −152…87 | −152…151 |
| 2244 | `polmis2` | 31 | 26 | 5 | 0 | −155…150 | −148…152 |
| 2404 | `polmis4` | 39 | 34 | 5 | 0 | −151…154 | −150…149 |
| 2604 | `scemis1` | 35 | 26 | 9 | 0 | −151…150 | −151…151 |
| 2784 | `scemis2` | 33 | 27 | 6 | 0 | −155…148 | −145…153 |
| 2954 | `scemis3` | 23 | 18 | 5 | 0 | −149…141 | −148…141 |
| 3074 | `scemis4` | 30 | 25 | 5 | 0 | −156…146 | −149…151 |
| 3229 | `scemis5` | 24 | 18 | 6 | 0 | −146…156 | −135…134 |
| 3354 | `swemis1` | 37 | 27 | 10 | 0 | −152…154 | −151…151 |
| 3544 | `swemis2` | 49 | 38 | 11 | 0 | −153…153 | −152…155 |
| 3794 | `swemis4` | 64 | 49 | 15 | 0 | −153…154 | −148…151 |
| 4119 | `swemis5` | 64 | 51 | 13 | 0 | −155…154 | −98…154 |
| 4444 | `prumis1` | 47 | 37 | 10 | 0 | −151…154 | −150…152 |
| 4684 | `prumis2` | 46 | 36 | 10 | 0 | −144…151 | −148…155 |
| 4919 | `prumis4` | 34 | 25 | 9 | 0 | −154…156 | −154…153 |
| 5094 | `prumis5` | 45 | 34 | 11 | 0 | −149…154 | −153…152 |
| 5324 | `scemis6` | 50 | 39 | 11 | 0 | −154…153 | −155…147 |
| 5579 | `scemis7` | 50 | 41 | 9 | 0 | −153…152 | −153…153 |
| 5834 | `scemis8` | 48 | 38 | 10 | 0 | −151…153 | −153…151 |
| 6079 | `scomis1` | 37 | 28 | 9 | 0 | −145…105 | −148…150 |
| 6269 | `scomis3` | 58 | 44 | 14 | 0 | −148…153 | −152…152 |
| 6564 | `scomis4` | 44 | 34 | 10 | 0 | −151…125 | −153…152 |
| 6789 | `spamis4` | 41 | 31 | 10 | 0 | −152…152 | −146…150 |
| 6999 | `spamis5` | 40 | 30 | 10 | 0 | −153…153 | −150…142 |
| 7204 | `turmis1` | 40 | 30 | 10 | 0 | −150…149 | −150…146 |
| 7409 | `turmis2` | 41 | 31 | 10 | 0 | −144…147 | −134…154 |
| 7619 | `turmis4` | 59 | 46 | 13 | 0 | −155…148 | −153…150 |
| 7920 | `netmis1` | 43 | 32 | 11 | 0 | −151…89 | −142…151 |
| 8140 | `netmis2` | 68 | 52 | 16 | 0 | −152…155 | −152…154 |
| 8485 | `netmis4` | 42 | 31 | 11 | 0 | −151…154 | −140…151 |
| 8700 | `netmis5` | 44 | 33 | 11 | 0 | −150…155 | −152…120 |
| 8925 | `scemis9` | 41 | 32 | 9 | 0 | −139…98 | −144…152 |
| 9135 | `scemis10` | 53 | 41 | 12 | 0 | −153…153 | −151…152 |
| 9405 | `scemis11` | 40 | 30 | 10 | 0 | −93…136 | −145…139 |
| 9610 | `scemis12` | 40 | 30 | 10 | 0 | −150…154 | −141…153 |
| | **SUM** | **1,911** | **1,452** | **441** | **18** | | |

No duplicate `MissionName` (`[O]`). Record counts range **3** (`ukrmis5`) to **68** (`netmis2`).

### 2.4 Exact `X` / `Y` literals (`[O]`)

- All 3,822 coordinate literals are **signed decimal integers** (no floats, no non-numeric values).
- **X min −156** at `postpatterns.cfg:3198`; **X max +156** at `:1608`, `:3293`, `:4923`.
- **Y min −155** at `:5449`; **Y max +155** at `:1594`, `:3789`, `:4824`.
- 313 distinct X values, 311 distinct Y values.
- Script reads them as floats (`ParserGetFloatValueByKeyByHandle`, `generatemap.inc:730-731`) and converts to indices `floor(x + (mapW div 2) + l)` and `floor(y + 2 + (mapH div 2) + k)` with `// +2 is visual offset` (`:744-745`) — **[O]** literal donor text, **[U]** runtime activation; the coordinate semantics are therefore **[I]** "centre-relative cell offsets". The ±156 magnitude is consistent with a 320-cell authored map (editor form `Map Size (320-640)`, `generatemap.inc:71`) but this is **[I]**, not a declared domain.

### 2.5 Exact distinct `PatternName` literals with counts and first line (`[O]`)

| PatternName | n | first line | PatternName | n | first line |
|---|---:|---:|---|---:|---:|
| `big_hill_1` | 1 | 22 | `mnc_1` | 111 | 252 |
| `d_frt_big_1` | 1 | 52 | `mnc_2` | 102 | 257 |
| `d_frt_big_3` | 1 | 57 | `mnc_3` | 94 | 242 |
| `d_stn_1` | 84 | 107 | `mnc_4` | 88 | 237 |
| `d_stn_2` | 83 | 17 | `mnc_5` | 80 | 247 |
| `d_stn_3` | 75 | 117 | `mng_1` | 113 | 152 |
| `d_stn_4` | 63 | 122 | `mng_2` | 110 | 142 |
| `d_stn_5` | 56 | 127 | `mng_3` | 98 | 197 |
| `d_stn_6` | 45 | 132 | `mng_4` | 97 | 192 |
| `d_stn_7` | 35 | 137 | `mng_5` | 87 | 157 |
| `f_plt_big_2` | 1 | 27 | `mni_1` | 110 | 327 |
| `g_frt_big_1` | 1 | 47 | `mni_2` | 99 | 302 |
| `g_frt_small_3` | 1 | 12 | `mni_3` | 95 | 312 |
| `g_hil2` | 1 | 37 | `mni_4` | 85 | 307 |
| `g_hil4` | 1 | 42 | `mni_5` | 83 | 317 |
| `g_hil8` | 1 | 7 | `str_new_1` | 1 | 67 |
| `g_hil9` | 1 | 32 | `str_new_2` | 1 | 77 |
| | | | `str_new_3` | 1 | 82 |
| | | | `str_new_4` | 1 | 72 |
| | | | `str_new_5` | 1 | 87 |
| | | | `str_new_6` | 1 | 92 |
| | | | `str_new_7` | 1 | 97 |
| | | | `str_new_8` | 1 | 102 |

Counts sum to 1,911 `[D]`. All 40 names occur in `var\generator.cfg`'s `Pattern` set (467 distinct) `[O]/[D]`; **no new pattern namespace is introduced** by this config. The `Freq=0` base variants `mng4`, `mni4`, `mnc4` (`generator.cfg:73,102`, F03 §7.2/§7.3) are **never** referenced here `[O]`.

### 2.6 What is *not* in the file (`[O]`)

No `Freq`/`Prob`/weight fields (unlike `generator.cfg` and `tilesmooth_scripts.cfg` in F03); no bitmap path or category key; no decal/material key; no radius/count/threshold key; no season key; no seed/RNG key. The only numeric literals are the 3,822 X/Y integers. All radii and transforms live in the consumer script (§5), not in this file.

---

## 3. Multiple passes on contradictions and anomalies (owner directive)

| # | Contradiction / anomaly | Passes | Accepted reading | Label |
|---|---|---|---|---|
| C1 | Exact-line `struct.begin` count = **0**, but `struct.end` = 2,014 | P1 counted stripped lines exactly; P2 counted substring `struct.begin`; P3 decomposed into `Missions :`, `Patterns :`, `[*] :` variants | All `struct.begin` tokens are suffixed (`X : struct.begin`), so exact-line matching yields 0. Substring/total = **2,014**, matching 2,014 `struct.end`. Grammar is balanced. Token-based parsing is mandatory. | [O]/[D] |
| C2 | 9,814 CRLF vs 9,815 lines; hand arithmetic 9,814 | P1 counted CRLF and `splitlines()`; P6 inspected tail bytes and blank lines | File ends **without** a trailing CRLF (`section.end` is last) **and** has exactly one blank line at `:7918` (between `turmis4` and `netmis1`). 9,814 terminators + final unterminated line = 9,815 lines; blank line adds the +1 over the 9,814-line arithmetic. No silent harmonisation. | [O] |
| C3 | X33 §0/E14 described "`:4-24`" as the example records | P1 re-read `:1-25`; P3 parsed mission boundaries | `:4` is `MissionName = engmis1`; `:6-24` are only its first four records; the mission actually runs through `:62`. X33's citation is a *sample*, not the mission extent. The file has **51** missions / **1,911** records, not a single flat record. | [O]/[D] |
| C4 | 56 lines failed a strict `PatternName = <space>value` regex | P2 used flexible `PatternName\s*=\s*`; P6 isolated lines of form `PatternName =mnc_1` | **33** lines have no space after `=` (first `:372`, last `:532`; all `PatternName`). Indentation is also inconsistent (9 vs 8 spaces for `MissionName`; `:7912` has 14 spaces for `PatternName`). A fixed-column or exact-`'PatternName = '` parser would silently drop 33 values; token-based parse recovers all 1,911 with 0 malformed records. | [O] |
| C5 | Two near-identical post-pattern blocks (`:711` and `:895`) could be mistaken for dead duplication | P4 read both blocks in full and mapped stage order | They are **not** duplicates. Block 1 (`:711-768`) runs **before** `cTextureTerrain`/`cSmoothTile`/`cLoadTextureFromBitmap` (`:770-798`) and clears the forest mask around mine names with `r=5` (`:733-750`) plus a forest-mask sweep (`:754-767`). Block 2 (`:895-960`) runs **after** `cPlaceFreeForests` (`:801-893`), destroys nearby objects with `r=3` and at `y+3`, then calls `_misc_CheckStandPattern` (`:956`). Both share the same `not bRandomMap` gate. | [O]/[I] |
| C6 | X33 verdict "authored only; low direct skirmish impact" was a triage guess | P4 read consumer gating; P5 whole-tree xref; P5 EXE string scan | Upgraded from guess to **structural fact**: `(not bRandomMap)` at `:711`/`:895`; `BoolRegister0 := True` in skirmish `dogenerate.inc:1563`; `False` in `dogeneratemissionmap.inc:4`. Only consumer file in the donor; no EXE literal. Still **[U]** as to runtime liveness of `;`-prefixed DScript. | [O]/[D]/[U] |
| C7 | All mission names expected to have `data\gen\bitmap\*.bmp` source | P3 matched all 51 stems; P6 re-checked alternate spellings | **49/51** match exactly; `bonmis1`, `bonmis2` have **no** `.bmp` in `data\gen\bitmap` (only `bonmis3.bmp` exists). The names still occur as config keys and locale files; reason for the missing bitmaps **[U]**. | [O]/[U] |
| C8 | Could this file feed skirmish "bitmap categories" or decal/mine/forest weights? | P2 key census; P4 consumer read; P3 name cross-check vs `generator.cfg` | No. Only four keys; no weight fields. The 40 names are drawn from `generator.cfg`'s existing 467-name namespace. Weights, if any, come from `generator.cfg` `Freq` (F03 §7), not from this file. Any "bitmap category" is the editor's `inputbitmap` form field, not a key here. | [O]/[D] |

---

## 4. Consumer analysis — skirmish relevance

### 4.1 The two consumer blocks (`[O]` literals, `[U]` liveness)

`generatemap.inc:49` declares `const cPostStandPatterns = True;`.

Block 1 — `generatemap.inc:711-768` (forest-mask preparation):
- `:711` `if (cPostStandPatterns) and (not bRandomMap) then`
- `:713-715` `_parser_ParserTemporary(True)` → `ParserLoadFromFileByHandle(pPostPatterns, '.\data\gen\bitmap\postpatterns.cfg')` → `ParserSelectByHandleByKey(..., 'Missions')`
- `:719-723` loop missions, `ParserGetValueByKeyByHandle(pMission,'MissionName')`, compare `if (name=missionname)`
- `:725-731` enumerate `Patterns`, read `PatternName`, `X`, `Y` (as Float)
- `:732` `_misc_StandPatternPlaceMask(patternName, x, y, 0, tmpPatternMask)`
- `:733-750` **mine special case**: `if StrExists(patternName,'mng') or StrExists(...,'mni') or StrExists(...,'mnc') then const r = 5; for k:=-round(r) to floor(r*2)-1 do for l:=... if VectorDistance(x,0,y,x+l,0,y+k)<r then tmpPatternMask[floor(x+(mapW div 2)+l), floor(y+2+(mapH div 2)+k)] := True;` (bounds-checked at `:746`)
- `:754-767` sweep all cells; where `tmpPatternMask[x,y]`, clear `gMapMask[x+i,y+j].forest` for `i=-1..1`, `j=-1..2` when `gMapMask[x,y].forest=cGForest`

Block 2 — `generatemap.inc:895-960` (object placement):
- `:895` same gate; `:897-899` same load; `:901-905` mission loop/name match; `:907-913` pattern loop and X/Y read
- `:915-936` **mine special case `r=3`**: `GetGameObjectsInRadius(x,y,r,...)`; destroy objects whose `baseid` is `gc_baseid_nil`, or `gc_baseid_res` with resource type not wood/none; `VectorDistance(posX,0,posZ,x,0,y)<r`
- `:937-953` second radius pass centred at `y+3` removing high trees (`gc_resource_type_wood`)
- `:956` `_misc_CheckStandPattern(patternName, envplHnd, x, y, 0, True, False, 0)`

### 4.2 The decisive gate (`[O]` text, `[D]` consequence)

| Source line | Literal | Meaning |
|---|---|---|
| `generatemap.inc:61` | `var bRandomMap : Boolean = BoolRegister0;` | gate source `[O]` |
| `generatemap.inc:711`, `:895` | `if (cPostStandPatterns) and (not bRandomMap) then` | config read **only when not random** `[O]` |
| `generatemap.inc:68-83` | `if (not bRandomMap) then … EditorFormClear('GenerateMapFromBitmap') … AddEditorFormInput('mapsize','Map Size (320-640)'…)` | authored-map editor workflow `[O]` |
| `generatemap.inc:85-138` | `if (not bRandomMap) then … AddEditorFormInput('missionname','Mission Name',missionname) … missionname := GetEditorFormValue('missionname') … gMap.name := missionname` | `MissionName` key comes from the editor form `[O]` |
| `dogenerate.inc:1563-1565` | `BoolRegister0 := True; StringRegister0 := path; ExecuteState('GenerateMap');` | **skirmish/random** generation sets `True` → gate closed `[O]` |
| `dogeneratemissionmap.inc:4-6` | `BoolRegister0 := False; StringRegister0 := ''; ExecuteState('GenerateMap');` | authored mission-map generation sets `False` → gate open `[O]` |
| `initmapgen.inc:232` | `ExecuteState('DoGenerate');` | normal map init takes the `DoGenerate` (skirmish) path `[O]` |
| `common.aix:51-61` | registers `DoGenerate` → `dogenerate.inc` and `DoGenerateMissionMap` → `dogeneratemissionmap.inc` | both are exposed states `[O]` |

**Conclusion `[D]`:** the config affects **editor-generated / saved authored mission maps only**. It is never reached by the skirmish random-map path. Runtime liveness of the commented DScript remains **[U]** (F03 U5, X27 §4); the *gating structure* is independent of that caveat.

### 4.3 Cross-checks that reinforce the verdict

- Random branch `generatemap.inc:139-174` sets `folderpath := StringRegister0` (`:171`), which skirmish fills with a `generator.cfg` terrain-mask path (`dogenerate.inc:1560-1564`), then enumerates `folderpath+'\*.tga'` (`:174`) — i.e. skirmish masks come from `data\gen\terrainmasks*`, **not** `data\gen\bitmap\*.bmp` and not this config. `[O]`/`[D]`
- 49/51 mission keys have a matching `data\gen\bitmap\<name>.bmp` (§3 C7) — the config is a companion to those authored bitmaps. `[O]`
- All 40 pattern names are already in `generator.cfg` (§2.5) — the file adds no new generation vocabulary. `[O]/[D]`

### 4.4 Exhaustive consumer search (`[O]`)

- Case-insensitive whole-donor filename scan (excluding large media) for `postpatterns`: **one file**, `data\scripts\common.inc\generatemap.inc`, 6 distinct lines (713, 714, 715, 897, 898, 899). No other script, config, `.aix`, `.lib`, `.mat`, mission, or locale file references it.
- Raw byte scan of `cossacks.exe` and `editor.exe`: `postpatterns`, `postpatterns.cfg`, `MissionName` → **0 hits** in both. (`PatternName` is present in both as DScript procedure-name strings, e.g. `procedure StandPatternWithAngle(...)`, but that is a different symbol.) This is consistent with the path living only in the DScript text, and gives **no** evidence of a separate native loader. `[O]`

---

## 5. Numbers the fresh module would need — **only if authored-map generation is scoped**

**For skirmish random maps: none. DEFERRED.** No count, weight or threshold from this file enters the skirmish pipeline (§4.2/§4.4).

If COORD later scopes authored/saved mission maps, the donor-literal inputs are (`[O]` text, `[U]` liveness unless noted):

| Item | Literal | Citation |
|---|---|---|
| Config path | `.\data\gen\bitmap\postpatterns.cfg` | `generatemap.inc:714`, `:898` |
| Selection key | `MissionName = <editor form value>` | `postpatterns.cfg:4,64,…,9610`; `generatemap.inc:98,105,723,905` |
| Record counts | 51 missions, 1,911 placements (40 distinct names) | §2.2–§2.5 |
| Family split `[I]` | 1,452 `mng/mni/mnc`; 441 `d_stn_1..7`; 8 `str_new_1..8`; 10 one-off hill/forest/plateau | §2.3 SUM, §2.5 |
| Coordinate type | signed integer in config, read as Float by script | `postpatterns.cfg:8-9` etc.; `generatemap.inc:730-731` |
| Coordinate → cell | `floor(x + (mapW div 2) + l)`, `floor(y + 2 + (mapH div 2) + k)`; `+2 is visual offset` | `generatemap.inc:744-745` |
| Mine mask-clear radius | `const r = 5`; loop `k,l = -round(r) .. floor(r*2)-1`; `VectorDistance < r`; clear 3×4 forest window (`i=-1..1`, `j=-1..2`) | `generatemap.inc:735-749`, `:759-765` |
| Mine object-clear radius | `const r = 3`; second pass centred at `y+3` for high trees | `generatemap.inc:917`, `:918`, `:938`, `:950` |
| Mine name test | `StrExists(patternName,'mng') or … 'mni' or … 'mnc'` | `generatemap.inc:733`, `:915` |
| Final stand call | `_misc_CheckStandPattern(patternName, envplHnd, x, y, 0, True, False, 0)` | `generatemap.inc:956` (cf. spec/04 §3 `_misc_CheckStandPattern` rejection sampling; spec/07 §3) |
| Pattern-name namespace | all 40 ∈ `generator.cfg` 467 names; `Freq` weights stay in `generator.cfg` | §2.5; F03 §7 |

**Do not** invent weights for this file: it has none, and any "frequency" a port assigns would be a new constant (charter §4 "no invention").

---

## 6. Implications for the port (`PORT APPROXIMATION` — not parity claims)

1. **`DEFERRED` for the fresh skirmish module.** Do not add a `postpatterns` decoder stage to the skirmish pipeline; it would be an invented stage with no donor consumer on that path. The donor's skirmish placement is `dogenerate.inc` `SetupMines`/`SetupStartingResources` + `generator.cfg` `Freq` + `.pattern` occupancy (spec/04 §3–§6, spec/07 §1–§3, F03 §7), none of which reads this config.
2. **`PORT APPROXIMATION` if authored maps are scoped:** transcribe the 51 mission blocks verbatim (§2.3), keep integer X/Y, keep the 1,452/441/8/10 family split, and reproduce the two gated passes in their donor order (mask-clear → texture/smooth → free forests → object-clear+stand). Preserve the `r=5` / `r=3` / `y+3` literals; do not round, normalise or "fix" them.
3. **`[U]` guard:** every consumer line is `[*] = ;<code>` donor intent. A port claiming behavioural equivalence for authored maps would need a live capture; none exists.
4. **No parity claim.** This report establishes format and gating only; it does not show that any of these placements appears in a shipped frame.

---

## 7. UNVERIFIED register

| # | Item | Why UNVERIFIED |
|---|---|---|
| U1 | Runtime liveness of `generatemap.inc` consumer blocks | all lines are `[*] = ;` DScript-in-config encoding (F03 U5 / X27 §4); no live trace |
| U2 | Whether `DoGenerateMissionMap` is callable from shipped UI | registered in `common.aix:58-61`, but no in-script caller found; likely editor-driven |
| U3 | Coordinate units/domain | centre-relative cell offsets inferred from `generatemap.inc:744-745`; no declared domain; magnitude fits 320² only `[I]` |
| U4 | Why `bonmis1`/`bonmis2` lack `data\gen\bitmap\*.bmp` | 49/51 match; no alternate stem found |
| U5 | Whether the two blocks' stage ordering is intentional or accidental | structural reading of `:711` before `:770`, `:895` after `:893`; no comment states intent |
| U6 | Whether any native (binary) path reads this config without the filename literal | EXE string scan found 0 hits; an obfuscated/constructed path cannot be excluded |
| U7 | Semantic meaning of `mng/mni/mnc` in this file | gold/iron/coal reading is `[I]` per spec/07 §5 and F03 §7.2; the file itself only supplies names |

---

## 8. Open questions / hand-off

1. **COORD:** accept `DEFERRED` for skirmish; do not schedule a `postpatterns` stage in the fresh module unless authored-map generation is added to scope.
2. **F09/D03:** confirm whether `DoGenerateMissionMap` is reachable from the shipped game or editor-only (U2); that sets the scope of §5.
3. **D08/F04:** if authored maps are scoped, confirm the `+2 visual offset` and 320/640 map-size relationship against the bitmap dimensions of `data\gen\bitmap\<mission>.bmp`.
4. **A02/A04:** note that the 40 pattern names here are a *placement subset* of `generator.cfg`, not extra families; do not double-count them as new generation rules.
5. **X33 integration:** update the coverage verdict for `postpatterns.cfg` from "NR (authored only)" to "decoded, DEFERRED for skirmish" with this report's citations.

---

## 9. Five-line hand-off summary

1. `[O]` `postpatterns.cfg` decoded fully: 269,140 B, 9,815 lines, 1 section / 51 `MissionName` missions / 1,911 `PatternName-X-Y` records, 40 distinct names, balanced 2,014/2,014 structs, only four keys.
2. `[O]` No weight, bitmap-category, decal, radius or threshold key exists in the file; X/Y are signed integers (−156…156 / −155…155).
3. `[O]/[D]` Sole consumer is `generatemap.inc:711-768` and `:895-960`, both gated `(cPostStandPatterns) and (not bRandomMap)`; skirmish sets `BoolRegister0 := True` (`dogenerate.inc:1563`) and skips them; authored maps set `False` (`dogeneratemissionmap.inc:4`).
4. `[O]` Whole-donor xref finds no other consumer, and neither EXE contains the filename literal; `[U]` liveness of `;`-prefixed DScript preserved.
5. **`DEFERRED`** — no count/weight/threshold from this file is needed by the fresh skirmish module; §5 lists the literals only for a hypothetical authored-map stage. **No donor visual-parity claim.**

*End of report.*
