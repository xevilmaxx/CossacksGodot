---
id: X66-REMOVED-MASKS-2026-11-26
ticket: "TERRAIN-SWARM-2026-11-26 / X66 — decode the eight .removed gauss terrain masks flagged by X33"
title: "X66 — the 8 `.removed` Mediterranean gauss masks: full TGA decode, exclusion mechanism, start/shape audit"
agent: "X66 (read-only donor analysis worker, DONOR-FIRST terrain swarm)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_DONOR_BINARY__NO_GODOT_JOB
owner_file: docs/terrain_swarm_2026-11-26/reports/X66_removed_masks.md
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_guard: "NO DONOR VISUAL PARITY CLAIM. No donor GPU A/B frame exists and no donor binary was executed by this worker. 'Decoded' means bytes were read and pixels reconstructed by two independent decoders; it does not prove any line executes in the shipped EXE."
scope_guard: "Exactly one repo file written (this report). Donor at C:\\Games\\Cossacks 3 was opened read-only via Python open('rb')/os.stat/os.walk; no donor file written, copied or executed. Scratch scripts/JSON live only in C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\removed_masks\\. No source/shader/config/asset/test/git/Godot-runner state touched."
sources_read: "CHARTER.md, spec/03_MASK_TO_HEIGHT.md, reports/X33_donor_text_coverage.md, reports/F04_masks.md, reports/F03_gen_config.md; donor: generatemap.inc:120-199,285-454, data/game/var/generator.cfg:1-66, data/gen/terrainmasks/moddersread.txt:1-10, data/gen/terrainmasks.src/convert_rle.bat:1-5,852-953, four .src Mediterranean masters; cross-grep of 1,811 donor text files and of landed reports/ for '.removed'."
passes: "Pass 1 byte/header inventory of all 8; Pass 2 decode with F04 decoder + Pillow 12.1.1 decoder (independent instruments); Pass 3 channel/height statistics and start-component geometry; Pass 4 exact-shape duplicate search (pairwise, union-of-starts) and .src-master scaling; Pass 5 selector-glob and reference scan; Pass 6 contradiction table (§7)."
---

# X66 — The eight `.removed` gauss masks decoded (2026-11-26)

> Labels follow `CHARTER.md:32-44`: **[O] OBSERVED** = literal donor byte or computed pixel
> statistic re-read this ticket; **[D] DERIVED** = deterministic arithmetic on observed data;
> **[I] INFERRED** = plausible reading, caveat stated; **[U] UNVERIFIED** = cannot be proved
> from the readable donor data; **PORT APPROXIMATION** = port-internal statement, explicitly
> not a donor claim. All donor paths are relative to `C:\Games\Cossacks 3\`.

## 0. Executive summary

1. **[O] All eight files are intact 320×320 RLE truecolour 24-bit TGAs, not corrupt.** Their 18-byte headers are byte-identical to the selectable `_gauss.tga` masks (`00 00 0A 00 00 00 00 00 00 00 00 00 40 01 40 01 18 00`; itype 10, 320², depth 24, descriptor `0x00` bottom-left, no alpha). Two independent decoders (F04's RLE reader and Pillow 12.1.1) produced **0 mismatched pixels out of 102,400 on each of the 8 files**. Sizes 36,168–48,422 B sit inside the selectable Mediterranean size range (vanilla 11,354–53,639 B; DLC5 11,358–53,671 B). **The "corrupt?" hypothesis is refuted.**
2. **[O] The exclusion mechanism is proven: the runtime selector glob is `*.tga`.** `data/scripts/common.inc/generatemap.inc:174` calls `ParserGetFilesInRoot(folderpath+'\*.tga')` and `:181` calls `ParserGetFilesInRoot(folderpath+'\'+IntToStr(i)+'pl*.tga')`; `:190-191` picks one entry at random. A file whose extension is `.removed` can never enter that list. This corroborates `V01_unverified_resolution.md:52,144` and resolves F04 §13 U6's "extension suggests exclusion" from `[U]` to `[O]` for the *mechanism* (the authoring *reason* remains partly `[U]`, §5).
3. **[O] The 8 files are 4 unique payloads, duplicated byte-for-byte across the vanilla and DLC5 roots.** Each of the four 256-bit SHA-256 values occurs exactly twice. The `.src` masters for indices 75/78/95/100 still exist at 256×256; their 4 white starts rescale exactly to the `.removed` 320² starts (§4), proving the `.removed` files are genuine `_gauss` postprocess outputs of shipped source art — not stray or fabricated data.
4. **[O] Channel statistics are identical in kind to the selectable masks:** R and G take only `{0: 102,396; 255: 4}` (the four pure-white starts); B has all 256 values with a 1..254 coastal ramp; therefore `h = −1.1·(B/255)` (F04 §6/§10) and no relief/forest class code exists off the starts. **No new height class, forest class or shape semantics are present.**
5. **[D]/[O] Per-file defect evidence is heterogeneous.** Index 75 clusters all 4 starts within 19.4–35.3 px (shipped Mediterranean p05 minimum spacing is 62.36 px vanilla / 66.10 px DLC5; p01 is only 2.0/38.08 px because a few shipped masks contain 1–2 px duplicate starts, F04 §8); index 78 clusters within 50.6–89.0 px; index 100's 4 starts are an **exact subset** of a selectable DLC5 8pl mask's starts on a **pixel-identical water shape**; index 95 has healthy spacing (min 154.25 px) but 2 starts lie within 2 px of another selectable mask's starts. DLC5 75 also has a selectable same-name `.tga` with the **same B shape but corrected, well-spread starts**. Exact authoring intent is not documented, so the *reason for removal* is `[U]` per file while the *effect* (exclusion from the glob) is `[O]`.
6. **[O] No runtime reference to any of the eight files exists.** A scan of 1,811 donor text files (29,865,050 B) found **zero** literal `.removed` strings in any mask/config/script; `generator.cfg:2-66` names only mask *folders*. The only shipped list naming these indices is the stale authoring helper `data/gen/terrainmasks.src/convert_rle.bat:853,925,928,947`, which still converts their hypothetical `_gauss.bmp` → `_gauss.tga` — it names the `.tga` form, never `.removed`, and is not a runtime selector. The port manifest has no `.removed` entry.
7. **[D] Verdict: DEFERRED / IRRELEVANT for skirmish ingestion.** They cannot be selected by the shipped generator, they add no new relief/forest codes or height range over the 1,331 selectable vanilla masks, and two DLC5 copies duplicate selectable shapes exactly. Indices 78 and 95 are unique B shapes but no donor evidence ties them to an additional skirmish class; ingesting them would be a deliberate authoring change, not a parity fix. **No parity claim.**

## 1. Evidence table

| # | Evidence (donor path:offset / path:line; tool) | What it establishes | Label |
|---|---|---|---|
| E1 | `data/gen/terrainmasks/mediterranean/*.removed` (4) and `data/gen/terrainmasks.dlc5/mediterranean/*.removed` (4); `os.stat` + `open('rb').read()[:18]` | Exact paths, sizes, headers; all 8 share the selectable `_gauss` header | [O] |
| E2 | F04 decoder `f04_decode.py:tga_decode` (reused from `%TEMP%\opencode`) + Pillow 12.1.1 `Image.open(...).convert('RGB')` | 8/8 files decode; 0/102,400 pixel mismatch between the two instruments | [O] |
| E3 | `generatemap.inc:174` `ParserGetFilesInRoot(folderpath+'\*.tga')`; `:181` `...'\'+IntToStr(i)+'pl*.tga'`; `:190-191` random pick; `:151-153` record-manager path override | Runtime selector glob excludes `.removed` | [O] |
| E4 | `data/game/var/generator.cfg:4-11` (vanilla Mediterranean path), `:34-37` (DLC5 Mediterranean path) | Config selects directories, never individual mask names or extensions | [O] |
| E5 | Full-text scan of 1,811 donor text files (`*.cfg/.inc/.script/.global/.source/.aix/.mat/.lib/.txt/.bat/.lst/.ini/.xml/.csv/.md/.log`, ≤8 MB each), 29,865,050 B | No literal `.removed` anywhere; the 10 unrelated "removed" hits are unit inside-list repair / locale text (`scripts/editor.aix:2531,2541`, etc.) | [O] |
| E6 | `data/gen/terrainmasks.src/convert_rle.bat:1-5,853,925,928,947` | The four indices appear as `_gauss.bmp → _gauss.tga` ImageMagick lines in a stale authoring list generated by `dir *.bmp /s/b >list.bat` | [O] |
| E7 | `data/gen/terrainmasks/moddersread.txt:3-8` | `Xpl_*_gauss.tga` = number of starts; `_gauss` = postprocessed from `.src`; source 256² → output 320² | [O] |
| E8 | Four `.src` masters `terrainmasks.src/mediterranean/4pl_mask_mediterranean_{75,78,95,100}.tga` (256², descriptor `0x20`) | Sources still ship; R={0,255} only, B strictly {0,255}; starts rescale exactly to the `.removed` starts | [O]/[D] |
| E9 | Full pixel decode + `collections.Counter` on R/G/B; `height_of()` from F04 §10 | Channel histograms, start components, height statistics per unique file (§5) | [O]/[D] |
| E10 | Pairwise comparison excluding the **union** of both files' start pixels | DLC5 `4pl_75.removed` ≡ DLC5 `4pl_75.tga` ≡ `8pl_27.tga` (B and full RGB diff 0); DLC5 `4pl_100.removed` ≡ `8pl_22.tga` (diff 0) | [O] |
| E11 | Start geometry: 8-connected components, pairwise Euclidean distances, edge distance, nearest non-start B≥250 within 48 px (F04 §2 method) | Start clustering / duplicate-start evidence (§4) | [O]/[D] |
| E12 | F04 §5.1–§5.3, §8 (selectable corpus baselines) | Selectable Mediterranean start-spacing p01/p05, R/G/B semantics, B ramp | [O] |
| E13 | `docs/audit/TERRAIN_DONOR_ASSETS.md:252`; F04 §13 U6; X33 §4.1/§4.3 row for the 8 files; X33 §7 Q2; V01 §52/§144 | Prior workers left "contents/deletion reason UNVERIFIED"; this report resolves contents and mechanism | [O] |
| E14 | `variant3d/assets/terrain/masks/manifest.json` and `**/*.png` grep for `removed` | No port asset references any `.removed` file | [O] |

## 2. Exact paths, headers, sizes and file identity

### 2.1 The eight paths (all `[O]`)

| Root | File (`…\mediterranean\`) | Bytes | SHA-256 (full) |
|---|---|---:|---|
| `data\gen\terrainmasks` | `4pl_mask_mediterranean_75_gauss.removed` | 48,422 | `4a27e7dfde6aafc656f5c4933c9c52bc4756e26809d322be88a5d5e0d1b7a8ef` |
| `data\gen\terrainmasks` | `4pl_mask_mediterranean_78_gauss.removed` | 36,168 | `e2a1301ae2d4c3be7873607215bdc70b14b567872ae0a5a2824a2087ecce4dd0` |
| `data\gen\terrainmasks` | `4pl_mask_mediterranean_95_gauss.removed` | 37,111 | `40f82f2a552305d32534989dd6fbb438af799831c6cb510fa4ce4418711ca23b` |
| `data\gen\terrainmasks` | `4pl_mask_mediterranean_100_gauss.removed` | 46,437 | `dfe61856d9587c0396cd592e0e6654007aadb6c372abe0131a613358c20170d1` |
| `data\gen\terrainmasks.dlc5` | `4pl_mask_mediterranean_75_gauss.removed` | 48,422 | `4a27e7dfde6aafc656f5c4933c9c52bc4756e26809d322be88a5d5e0d1b7a8ef` |
| `data\gen\terrainmasks.dlc5` | `4pl_mask_mediterranean_78_gauss.removed` | 36,168 | `e2a1301ae2d4c3be7873607215bdc70b14b567872ae0a5a2824a2087ecce4dd0` |
| `data\gen\terrainmasks.dlc5` | `4pl_mask_mediterranean_95_gauss.removed` | 37,111 | `40f82f2a552305d32534989dd6fbb438af799831c6cb510fa4ce4418711ca23b` |
| `data\gen\terrainmasks.dlc5` | `4pl_mask_mediterranean_100_gauss.removed` | 46,437 | `dfe61856d9587c0396cd592e0e6654007aadb6c372abe0131a613358c20170d1` |

**[O] Byte identity:** each SHA occurs exactly twice → **4 unique payloads**, duplicated root-to-root. Sum of all eight sizes = **336,276 B**, exactly X33 §4.1's aggregate. They are therefore **not** members of F04's "31 differing DLC5 common-shape TGAs" set: the same bytes ship in both roots.

### 2.2 Header and size vs selectable `.tga` masks (`[O]`)

| Property | 8 `.removed` files | Selectable `_gauss.tga` (F04 §4 / E3) |
|---|---|---|
| ID length / colour-map type | 0 / 0 | 0 / 0 |
| Image type | **10 = RLE truecolour** | 10 |
| Colour-map length / depth | 0 / 0 | 0 / 0 |
| Origin (x,y) | (0,0) | (0,0) |
| Width × height | **320 × 320** (`40 01`, `40 01`) | 320 × 320 |
| Pixel depth / byte order | 24, BGR | 24, BGR |
| Descriptor | `0x00` = bottom-left, 0 alpha bits | `0x00` |
| First payload bytes | `FF 00 00 00 FF 00 00 00 BF 00 00 00` (raw run, BGR 0,0,255) | same convention (F04 E4) |
| File size | 36,168–48,422 B | vanilla 11,354–53,639 (n=118); DLC5 11,358–53,671 (n=207) |
| Will `ParserGetFilesInRoot('\*.tga')` match? | **No** (extension `.removed`) | Yes |

**[D]** A naive "final mask = anything in the folder" count would give Mediterranean 122 files vanilla / 211 DLC5; the selector sees only **118 / 207**, which is exactly the F04/V01 count. The `.removed` extension is the sole discriminator.

## 3. Pass 1–2: integrity (two decoders, corruption hypothesis)

**[O] Method:** (a) F04's RLE reader was reused unchanged; it asserts `itype∈{2,10}`, `cmtype=0`, `depth∈{24,32}`, decodes every packet until `w*h*bpp` bytes are filled, swaps BGR→RGB and honours descriptor bit `0x20`; (b) Pillow 12.1.1 `Image.open()` (magic-byte detection, independent of file extension) `.convert('RGB')`.

| File (both roots, identical result) | F04 decoder | Pillow | Pixel mismatch | Land 320² payload fully consumed |
|---|---|---|---:|---|
| `_75_gauss.removed` | 320×320 | 320×320 | **0 / 102,400** | yes |
| `_78_gauss.removed` | 320×320 | 320×320 | **0 / 102,400** | yes |
| `_95_gauss.removed` | 320×320 | 320×320 | **0 / 102,400** | yes |
| `_100_gauss.removed` | 320×320 | 320×320 | **0 / 102,400** | yes |

**[D] Conclusion:** "corrupt or truncated" is **refuted** for all 8. The only anomaly is the filename extension, which is precisely what the selector keys on (E3).

## 4. Pass 3–4: start geometry and exact-shape duplicates

### 4.1 Source-master provenance (`[O]`/`[D]`)

The four 256² `.src` masters still ship. Their white starts, multiplied by 320/256 and rounded, reproduce the `.removed` starts **exactly** in all four cases:

| Index | `.src` file size / B values | `.src` starts (256²) | Rescaled → `.removed` starts (320²) |
|---:|---:|---|---|
| 75 | 5,722 B; B `0:40,771 / 255:24,765` | (107,121),(117,136),(124,120),(133,133) | (134,151),(146,170),(155,150),(166,166) ✔ |
| 78 | 4,500 B; B `0:42,880 / 255:22,656` | (95,188),(111,150),(143,198),(151,144) | (119,235),(139,188),(179,248),(189,180) ✔ |
| 95 | 4,487 B; B `0:44,507 / 255:21,029` | (23,15),(76,171),(166,87),(241,241) | (29,19),(95,214),(208,109),(301,301) ✔ |
| 100 | 5,541 B; B `0:48,244 / 255:17,292` | (44,213),(68,45),(152,189),(219,56) | (55,266),(85,56),(190,236),(274,70) ✔ |

**[D]** The `.removed` payloads are the normal `moddersread.txt:6-8` postprocess of shipped sources: binary B → 256-value gauss ramp, 256² → 320², top-left → bottom-left descriptor. They are not orphan files.

### 4.2 Start geometry (identical in both roots; `[O]`/`[D]`)

| Index | Start pixels (top-down x,y) | Min pair distance (px) | All pair distances (px) | Min edge distance | Nearest non-start B≥250 per start |
|---:|---|---:|---|---:|---|
| 75 | (134,151),(155,150),(146,170),(166,166) | **19.42** | 19.42, 20.40, 21.02, 21.93, 22.47, 35.34 | 134 | 16.97, 15.81, 18.38, 17.69 |
| 78 | (139,188),(189,180),(119,235),(179,248) | **50.64** | 50.64, 51.08, 61.39, 68.73, 72.11, 89.02 | 71 | 16.40, 17.69, 13.93, 17.03 |
| 95 | (29,19),(208,109),(95,214),(301,301) | 154.25 | 154.25, 200.35, 205.87, 213.34, 223.62, 391.80 | 18 | none within 48, 17.69, 17.03, 67.18 |
| 100 | (85,56),(274,70),(190,236),(55,266) | 138.29 | 138.29, 186.04, 189.52, 208.39, 212.13, 293.90 | 45 | 40.22, 46.32, 52.33, 20.81 |

**Baseline [O] (F04 §8, re-measured here on the 118/207 selectable Mediterranean `.tga`):** minimum start distance p01 = **2.0 px** (vanilla) / **38.08 px** (DLC5), p05 = **62.36 / 66.10 px**, p25 = **97.64 / 93.05 px**, p50 = **144.31 / 149.58 px**. The tiny vanilla p01 is caused by a handful of shipped masks with 1–2 px duplicate starts (F04 §8), so p05 is the meaningful "typical minimum" here.

- **[D] Index 75** places all four starts inside a 32×20 px box; its 19–35 px separations are ~0.06–0.11 of map width, far below the shipped p05 (62.36 px). Local land is plentiful (1,439–1,570 of 1,681 px in a 41×41 box), so this is a *spacing/layout* defect, not a "starts in water" defect. The same clustering exists in its 256² master.
- **[D] Index 78** has 50.64–89.02 px separations; below the vanilla p05 (62.36 px) for three of six pairs. Moderate clustering; its master shows the same pattern.
- **[O] Index 95** is well spread (min 154.25 px) and has one start with no water within 48 px (inland) — nothing anomalous in spacing; edge distance 18 px is above F04's shipped minimum of 6 px.
- **[O] Index 100** is well spread (min 138.29 px). Its significance is the exact duplicate-start/shape relationship below, not spacing.

### 4.3 Exact-shape duplicates (`[O]`; union-of-starts pixel comparison)

| `.removed` file | Selectable `.tga` with identical non-start pixels | Start relationship | Diff (B / full RGB) |
|---|---|---|---:|
| DLC5 `4pl_75.removed` | `4pl_mask_mediterranean_75_gauss.tga` | removed: 4 clustered starts; selectable: 4 well-spread starts **(no coincidence)** | 0 / 0 |
| DLC5 `4pl_75.removed` | `8pl_mask_mediterranean_27_gauss.tga` | 8 different starts on the same shape | 0 / 0 |
| DLC5 `4pl_100.removed` | `8pl_mask_mediterranean_22_gauss.tga` | **all 4 removed starts are an exact subset of the 8pl mask's 8 starts** | 0 / 0 |
| DLC5 `4pl_78.removed` | none (nearest B mean-abs-diff ≈48.9) | — | — |
| DLC5 `4pl_95.removed` | none (nearest ≈49.6) | — | — |
| all four vanilla `.removed` | none in the same root (nearest B mean-abs-diff 49.6–67.4) | — | — |

**[D]** The three exact matches hold over the union of both files' start pixels; a per-file-start-exclusion B-channel SHA found no collisions because start positions differ (a method artifact, not a contradiction — see §7 C4). The four `.src` masters are also unique among the 121 Mediterranean masters by the same per-file metric.

**[D] Cosine of the likely authoring story (kept as `[I]`, not promoted):** indices 75/100 were superseded by selectable masks carrying the *same* height/shape with corrected or extended start sets; index 78 was culled for tight starts; index 95 has no detectable data defect and its removal reason is `[U]`. **No donor document states any of these reasons**, so they are hypotheses constrained by the bytes, not recovered intent.

## 5. Channel statistics and height/shape relevance

### 5.1 Per-unique-file statistics (`[O]` decode, `[D]` height via F04 §10 formula)

All four: 102,400 px; **R = {0:102,396; 255:4}**, **G = {0:102,396; 255:4}** (the 4 pure-white starts). No relief code (255/191/96/112/48/88/64) and no forest/stone code (255/127/64/128/192) occurs off the starts.

| Index | B distinct / B=0 / B=255 / B=1 / B=254 | Height (excl. starts) min..max, mean | Neg. px | `h<−0.25` px | Land frac (B<58) | Largest land component |
|---:|---|---|---:|---:|---:|---:|
| 75 | 256 / 57,892 / 31,455 / 1,033 / 363 | −1.1..0, mean −0.3976 | 43.46% | 37.87% | 0.6213 | 63,623 px |
| 78 | 256 / 62,819 / 30,031 / 746 / 250 | −1.1..0, mean −0.3668 | 38.65% | 34.65% | 0.6534 | 66,911 px |
| 95 | 256 / 64,400 / 28,225 / 762 / 240 | −1.1..0, mean −0.3482 | 37.11% | 32.94% | 0.6706 | 68,668 px |
| 100 | 256 / 68,912 / 20,992 / 863 / 347 | −1.1..0, mean −0.2854 | 32.70% | 27.69% | 0.7231 | 64,346 px (2 comps ≥100 px) |

**[D] Interpretation:** with `fr=0` on every non-start pixel, `h = −1.1·(B/255)` exactly — the same authoritative mask→height statement as `spec/03_MASK_TO_HEIGHT.md:14-21`; all four stay in the selected-mask range **[−1.1, 0] m**. None can produce the ±2.964 m amplitudes (those belong to the pattern-stamp stage, F04 §6/§11). The water fractions and gauss ramp fall inside F04's Mediterranean range (B=255 fraction 0.027–0.326; these are 0.205–0.307). **No new height class or landscape class is encoded.**

### 5.2 Verdict (`[D]` with `[O]` evidence)

**DEFERRED / IRRELEVANT for skirmish terrain.** Reasons, each independently sufficient:

1. **Unreachable:** `generatemap.inc:174,181` only enumerates `*.tga`; the `.removed` extension guarantees these 8 never enter the skirmish random pick (E3). Changing that would be an authoring change, not a port fix.
2. **No semantic novelty:** R/G are start-only, B follows the already-decoded water-bed formula; the relief/forest stage lives in patterns (F04 §11), not here.
3. **Redundant where checked:** DLC5 75 and 100 duplicate selectable shapes exactly; 100's starts duplicate a selectable 8pl mask's starts exactly.
4. **No runtime or port reference:** E4, E5, E14.
5. **Unique shapes 78/95:** recorded above with full stats for completeness. They differ in *coastal outline* only (ASCII shapes in §6), not in class data; nothing in the donor ties them to an unimplemented skirmish feature. `[U]` whether an author considered them "bad map layouts" — the only measurable anomalies are listed in §4.2.

**PORT APPROXIMATION note (not a donor claim):** if COORD ever chose to enlarge Mediterranean variety by re-enabling unique shapes 78/95, that would require renaming (outside this read-only ticket) plus the F04 §11 guards: exact white-start detection, skip starts in height, and a spacing check for the 19–35 px cluster of index 75. This report does not do it and claims no parity.

## 6. Shape preview (ASCII, 48 cols × 16 rows; `~` deep water, `:`/`-` gauss ramp, `.` land)

Generated with F04's `ascii_map` on the four vanilla payloads (DLC5 copies are byte-identical). These are **portraits of the decoded B field**, not donor artwork.

```
75                                    78                                    95                                    100
....................................    ....................................    ....................................    ....................................
............::::::::..::~-:.......    .................................::    .......................::::.........    ...................::.::~~~~::......
......::~:::~~~~~~~~~~~~~~~~~:~~::    ................:::.::....:::~~::    ...............::.....:~~~~~~~~:.....    ...................:::~~~~~~~~:.....
......:~~~~~~~~~~~~~~~~~~~~~~~~~~::    ........:::~:::~~~~~~~::::~~~~~~~    ...........:::~~~:....:~~~~~~~~~~::~::    ........................::~~~~:::~:
........:~~~~~~~~~~~~~~~~~~~~~~~~~~~    .......:::~~~~~~~~~~~~~~~~~~~~~~~    .............~~~~~:....::~~~~~~~~~~~~    ......:::::.............:::~~~~~::
........::::::::...::~~~~~~::::::::    .......:~~~~~~~~~~~~~~~~~~~~~~~~~~    ..........:::~~~~~::::::....:....:~~~~    ....::~~~~~~....:~~:::::~:~~~~~~::
...:::.............:~~::.:...........    .........::~~~~~~~~~~~~~~~~~~~~~~    .........:~~~~~~~~~~~~~~~~~~~~~~:~~~~    .....::~~~~~~~:::::......:::::~~~~
...:~~~:~:::..............:~~~~~::::    ..........:~~~~~~~~~~~~~~~~~~~~~~    ............::~~~~~~~~~~~~~~~~~~~~~~~~    .....:::~~~~~~:.................-
....:~~~~~~~~::::~:..........::~~~~~    ..........::.:::::~~~~~~~~:::::~~~    .........:::~~~~~~~~~~~~~~~::~~~~~~~~    .......:~~~~~::~~::..........:~~~
..::~~~~~~~~~~::::..::::~~:.....:~~~~    ............::::::.....:~~::::::    ...........:::::~~~~~~~~~~~:.....::~~~~    ........:::~~~-~~~~::~:......:~~~
......:::::::......:~~~~~~~:.....:~~~    ............:~~~~~~~~~:~~~~~~~~~    ..................:::::~~~~~~~:.......::    .........:~~~~~~~~~~~~:::.....~~~
...............:~~~~~~~~~~~~~:....:~~    ...........:~~:::..:~~~~~~~~~~~~    .....:~~~~~:::.:~~~~~~~~~~~~~~:........    ..........::::~::~~~~~~~::.....:~
..........:::~:::~~~~~~~~~~~~~:..:::    ...............:::::~~~~:....:~~~    .....:~~~~~~~~~~~~~~~~~~~~~~~~::::.....    ................:~~~~~~~::..:..:
..........::~~~~~~~~~~~~~~~::::...:~    .............::~~~~~~~~:......:::    ......~~~~~~~~~~~~~~~~~~~~~~~~~~~:.....    ..................:~~~~~~~~~~~~-
.............:::::::::::.............    .............:~~~~~:.............    ........::::::::....:::::::.............    ....................:::::::~~::
....................................    ....................................    ....................................    ....................................
```
*(Rows are truncated to a readable width here; the full 48×16 output was printed in `%TEMP%\opencode\removed_masks\` and is reproducible from `x66_final.py`.)*

## 7. Multiple passes on contradictions (owner directive, `CHARTER.md:81-93`)

| # | Contradiction / anomaly | Passes taken | Accepted reading | Label |
|---|---|---|---|---|
| C1 | X33 §4.1 called the 8 "earlier `_gauss` variants, NEEDS READ"; F04 §13 U6 left "loaded by any config?" open | Pass 1 inventory; Pass 2 two-decoder decode; Pass 5 selector + full-text reference scan | Contents are **ordinary `_gauss` postprocess outputs**, verified; they are **not loadable** by the shipped selector. X33's "earlier variant" is correct only in the sense "produced from `.src` then renamed" | [O]/[D] |
| C2 | "Corrupt?" vs valid-looking extension | Pass 2 F04 decoder; Pass 2 Pillow; Pass 1 header/size vs selectable | Both instruments return 102,400 correct pixels with 0 mismatch → not corrupt; the anomaly is purely the extension | [O] |
| C3 | "Duplicate start positions?" — true for some, false for others | Pass 3 component detection + pairwise distances; Pass 4 exact-shape comparison | **Index 100 DLC5**: 4/4 starts exactly coincide with selectable `8pl_22` starts (and shape identical) → duplicate. **Index 75 DLC5**: clustered 19–35 px, no coincidence with selectable starts, but superseded by a same-shape `.tga` with corrected starts. **Index 78**: clustered, unique. **Index 95**: well-spaced, only 2 near-coincidences ≤2 px. Report per-file, never as a blanket claim | [O]/[D]/[U] |
| C4 | B-channel SHA excluding each file's own starts found **no** cross-file duplicate, yet pairwise comparison found exact equality | Pass 4 SHA metric; Pass 4 revised metric excluding the **union** of both files' start pixels | The first metric is invalid when files have different start counts/positions: start pixels are white (B=255) in one file but non-start (B≠255) in the other, so the excluded sequences differ. Union exclusion gives diff 0 → exact duplicates confirmed. Both results preserved, no silent harmonisation | [D] |
| C5 | `convert_rle.bat` appears to "reference" the four indices — are they still in a shipped mask list? | Pass 5 full-text scan (1,811 files); Pass 5 read `:1-5,852-953`; Pass 5 `generator.cfg:1-66`; Pass 5 port manifest grep | The batch is a **stale authoring helper** naming `.bmp → .tga` conversions, generated by `dir *.bmp /s/b`; it contains no `.removed` literal. `generator.cfg` names only folders. **No runtime or port reference exists.** Reported both facts | [O] |
| C6 | Vanilla indices 75/78/95/100 absent as `.tga`, but DLC5 index 75 present as both `.tga` and `.removed` with the same base name | Pass 1 per-root directory census; Pass 4 pixel comparison | DLC5 `4pl_75.tga` and `4pl_75.removed` share B/RGB exactly off starts but carry **different start sets**; the `.tga` is the selectable corrected variant. No contradiction in counts: vanilla 4pl 97 `.tga` + 4 `.removed`; DLC5 4pl 98 `.tga` + 4 `.removed` (F10's 4pl 102 = 98+4) | [O]/[D] |
| C7 | F04's global p01 spacing 63.25 px (all 1,331 vanilla) vs this report's Mediterranean-only p05 62.36 px (vanilla p01 is 2.0 px) | Pass 3 recomputation restricted to the 118/207 Mediterranean `.tga` files; compared with F04 §8 corpus-wide value; Pass 6 re-read of the percentile definition | Both true at different scopes/percentiles; a draft mislabelled 62.36 as p01 and was corrected to p05 after this pass. The p05 value is used for the layout comparison and labelled as such | [O]/[D] |

## 8. UNVERIFIED register (do not promote)

1. **[U]** The authoring *decision* that renamed these four files `.removed` in each root — no donor document states a rule or reason. Only the measurable defects of §4 are available.
2. **[U]** Whether index 95 was removed for a non-pixel reason (play-testing, duplicate theme, naming) — its starts and shape show no defect under the applied tests.
3. **[U]** Runtime execution of `generatemap.inc:174,181` in the shipped EXE: all lines are `[*] = ;` intent text (CHARTER §4; F04 §13.1). The glob's *literal pattern* is observed; its execution is not proven without a native probe.
4. **[U]** Whether the stale `convert_rle.bat` lines were ever run for these four indices (their `_gauss.bmp` inputs do not ship).
5. **[U]** Pixel→cm scale for the published start-spacing rule; only px and normalised fractions were measured.
6. **[U]** Any donor GPU A/B frame — none exists. **No donor-parity claim of any kind.**

## 9. Open questions for COORD / other workers

- **F10/V01:** this report resolves X33 §7 Q2 — the 8 `.removed` files are **not** the 31 differing DLC5 masks; each payload is byte-identical across the two roots. The 31-mask question remains open separately.
- **D03/D05:** confirm whether a QA/spacing check exists in native code that would explain the 19–35 px cluster of index 75; this worker found no text-level rule.
- **A01/A02:** if additional Mediterranean variety is ever wanted, indices 78/95 are the only unique shapes here; treat ingestion as an authoring change with the F04 §11 guards, not as a parity repair.
- **A05:** add a gate that rejects any converter output whose R/G are non-start-only — this would have made the `.removed` question answerable from pixels alone.

## 10. Five-line summary

- **[O]** 8 `.removed` files = 4 byte-identical pairs (vanilla/DLC5), 36,168–48,422 B each; all decode as intact 320² RLE-TGA 24-bit, 0/102,400 mismatch across two decoders — **not corrupt**.
- **[O]** `generatemap.inc:174,181` selects only `*.tga`; `.removed` is excluded by that glob; no donor text contains the literal `.removed`, `generator.cfg` names folders only, and the port manifest has no entry — **no runtime reference**.
- **[O]** R/G are start-only, B is the full 256-value gauss ramp, `h = −1.1·B/255` in [−1.1, 0] m; starts rescale exactly from shipped 256² `.src` masters — no new relief/forest/height class.
- **[D]** DLC5 `4pl_100.removed` duplicates a selectable `8pl_22` shape **and all four of its starts**; DLC5 `4pl_75.removed` duplicates two selectable shapes with bad clustered starts; `78` clusters moderately; `95` has no measurable defect — exact authoring reason `[U]`.
- **[D]** Verdict **DEFERRED / IRRELEVANT for skirmish**; full channel/height stats recorded; **no donor visual-parity claim**.

*End of X66. Exactly one repo file written (this report). No donor binary executed or copied; no repo file other than this report modified; no Godot runner job; scratch confined to `%TEMP%\opencode\removed_masks\`.*
