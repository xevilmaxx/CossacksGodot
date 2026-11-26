---
id: X18
swarm: TERRAIN-SWARM-2026-11-26
wave: X (verification, donor-first)
title: "Independent verification of F04's terrainmask channel / start / height finding — donor READ-ONLY"
ticket: X18
owner_file: reports/X18_mask_channel_verification.md
status: LANDED__READ_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB
created: 2026-11-26
donor_root: "C:\\Games\\Cossacks 3 (read-only; no donor binary executed, copied or committed)"
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, "PORT APPROXIMATION"]
parity_guard: "NO donor GPU A/B frame exists. NO donor-parity claim. All port statements are port-internal measurements or PORT APPROXIMATION."
tools: "Python 3.14.3 + Pillow 12.1.1 + numpy 2.4.3; scripts only in C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\mask_verify\\"
---

# X18 — Independent verification of F04's terrainmask finding

> Labels per `CHARTER.md:32-44`: **[O]** OBSERVED = literal donor byte / pixel
> statistic re-read this ticket; **[D]** DERIVED = deterministic arithmetic on
> observed data; **[I]** INFERRED; **[U]** UNVERIFIED = not provable from
> readable donor data; **PORT APPROXIMATION** = what the port does, explicitly
> *not* a donor claim. All donor paths are relative to `C:\Games\Cossacks 3\`.
> No donor file was written, executed or copied into the repo; no code/asset/
> config/test/git edit; no Godot runner job.

## 0. Executive summary

1. **[O] F04's headline is CONFIRMED, independently and exactly.** A fresh
   corpus-wide scan of all **1,331** vanilla `_gauss` masks (136,294,400 px)
   with a different toolchain (numpy + Pillow, not F04's decoder) reproduces
   F04's numbers **byte-for-byte**: R = {0: **136,289,275**, 255: **5,125**};
   G identical; B has all **256** values (0: **74,903,914**, 255: **47,429,165**).
   The count of non-start pixels with R≠0 or G≠0 is **0**. So R/G are zero on
   every non-start pixel and every one of the 5,125 R=G=B=255 pixels is a
   single-pixel white start. [O]
2. **[O] B→height relation CONFIRMED.** Donor `data/scripts/common.inc/
   generatemap.inc:4-7` defines `cWaterHeight = −1.1`; `:567` computes
   `hwater = cWaterHeight*(fb*(1+fr*3.5))`; `:574` calls
   `SetHeightData(hwater+hterrain)`. With `fr=0` on every shipped non-start
   pixel this reduces exactly to `h = −1.1·B/255`. The med/22 shoreline
   transect was reproduced exactly (`B = 0,2,13,49,114,193,251,255`).
   `h<−0.25` ⇔ `B ≥ 58` (port `mapgen.gd:212-215` uses the same formula). [O]
3. **[O] Header/format CONFIRMED** on 21 sampled masks and the full scan:
   image type **10** (RLE truecolour), colour-map type 0, ID length 0, depth
   **24** BGR, no alpha. Final masks 320×320, descriptor `0x00` (bottom-left);
   `.src` masters 256×256, descriptor `0x20` (top-left), cmap-depth byte 24.
   Raw header bytes `00 00 0A 00 … 40 01 40 01 18 00` at offsets `0x00–0x11`
   match F04 E3 exactly; payload begins at `0x12`. [O]
4. **[O] Non-vanilla trees CONFIRMED.** `.dlc5` (1,856 files, 7,616 starts,
   R/G = 0:190,046,776 / 255:7,616 **plus exactly 8 anomalous grey pixels** in
   the two files F04 named, at the exact coordinates F04 gave) and `.src`
   (1,279 files, 4,813 starts, B strictly binary {0:49,254,648, 255:34,565,896})
   both reproduce F04 §5.2–5.3. [O]
5. **[O] TWO minor F04 corrections found (do not affect the headline):**
   (a) `peninsulas/4pl_mask_peninsulas_5_gauss.tga` has **5 well-separated**
   starts (min separation **129.63 px**; `.src` master 104.02 px), **not** a
   1–2 px near-duplicate as F04 §8's exception table claims — it is a
   filename-prefix exception only, so the near-duplicate list is **five**, not
   six. (b) F04 E4's "bytes `ff 00 00` → R=0,G=0,B=255" misreads the first
   byte: `0xFF` is the RLE packet header (128-pixel raw run); the first actual
   pixel is BGR `00 00 00` → RGB(0,0,0), verified by decoded med/22 `[0,0]`.
   [O]
6. **[O] PORT APPROXIMATION** (no parity claim): three spot-checked port PNGs
   are pixel-identical to donor TGA pixels and `manifest.water` matches the
   `B≥58` fraction to <0.0005, but the port decodes only 56/1,331 vanilla
   masks, has no DLC5, block-averages at 240², substitutes its own coastal
   smoother, uses `forest=G/255` and keeps only the farthest start pair.

## 1. Evidence table

| # | Evidence (donor path:offset / path:line) | What it establishes | Label |
|---|---|---|---|
| X1 | Full numpy+Pillow scan of `data/gen/terrainmasks/**` (1,331 TGA, 136,294,400 px) | R/G exactly {0,255}; R0=136,289,275; R255=5,125; G identical; B distinct 256; non-start R/G≠0 = **0** | **[O]** computed |
| X2 | `data/gen/terrainmasks/nowater2/4pl_mask_nowater_176_gauss.tga:0x00-0x11` raw bytes `00 00 0A 00 00 00 00 00 00 00 00 00 40 01 40 01 18 00`; payload `0x12` | 18-byte header, itype 10, cmtype 0, depth 24, 320², desc 0x00 | **[O]** bytes |
| X3 | Same for `mediterranean/4pl_mask_mediterranean_22_gauss.tga:0x00-0x11` (SHA `159eb0a7…`) | identical format; F04 SHA prefix reproduced | **[O]** bytes/hash |
| X4 | 21-mask sample: independent manual RLE decoder vs Pillow 12.1.1 | **21/21 byte-for-byte identical**, incl. vertical orientation | **[O]** computed |
| X5 | `data/scripts/common.inc/generatemap.inc:4-7` | `cPlateauHeight=2.964`, `cHillHeight=…/2.25`, `cRavineHeight=−2.964`, `cWaterHeight=−1.1` | **[O]** text |
| X6 | `generatemap.inc:537-547` + `:563-574` (`:567` `hwater=…`, `:574` `SetHeightData`) | nearest-pixel sample `floor(x/mapwidth*trgwidth)`; height from `fb`, `fr`, class | **[O]** text |
| X7 | `generatemap.inc:565-566` | start skip only when `bRandomMap and fr=1 and fb=1` (white pixel) | **[O]** text |
| X8 | `data/scripts/common.inc/texturemap.inc:29-31` | `cWaterHeight=−0.25`, `cWaterShoreHeight=−0.1` → B≥58 / B≥23.2 when fr=0 | **[O]** text |
| X9 | `variant3d/scripts/mapgen.gd:212-215` | `hw = C_WATER*(cb/255)*(1+(cr/255)*3.5)`, `height=hw+relief(cr)`, `forest=cg/255` — same algebra; block average + own smoother are **PORT APPROXIMATION** | **[O]** port code |
| X10 | med/22 transect y=160 x=112..119 via fresh decoder | B `0,2,13,49,114,193,251,255` → h `0,−0.0086,−0.0561,−0.2114,−0.4918,−0.8325,−1.0827,−1.1` | **[O]+[D]** |
| X11 | Full scan of `terrainmasks.dlc5/**` (1,856 TGA) + two grey files | 7,616 starts; 8 grey px at F04's exact coords; 7 markers in both 8pl files | **[O]** computed |
| X12 | Full scan of `terrainmasks.src/**` (1,279 TGA) | B strictly 2-valued; 4,813 starts; desc 0x20 | **[O]** computed |
| X13 | 3 port PNG spot checks + `manifest.json` | pixel-identical (0 diff px); water manifest ≈ B≥58 fraction to <0.0005 | **[O]** port files / **PORT APPROXIMATION** |
| X14 | Start coordinate re-extraction on 6 F04 exception files | 5 near-duplicate files confirmed; `peninsulas_5` **not** near-duplicate (129.63 px) | **[O]** computed |

## 2. Method (reproducible, read-only; temp only)

All scripts live in `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\mask_verify\`:
`verify.py` (manual RLE TGA decoder + Pillow cross-check), `targets.py`,
`corpus.py` (numpy full-corpus histogram scan), `anomaly.py` (raw header dump
+ DLC5 grey-pixel pass + correct-width `.src` starts), `starts_check.py`
(start coords/pairwise distances), `port_check.py` (PNG/manifest spot check).
Raw results in `results.json`, `summary.txt`, `corpus.json` in the same temp
folder. No donor file opened for writing; no repo file written except this report.

1. **Independent manual decoder** (`verify.py`): read 18-byte header with
   `struct.unpack_from`, assert `itype∈{2,10}`, `cmtype=0`, `depth=24`; skip
   ID; decode RLE packets (`header&0x80` = repeat, `count=(header&0x7f)+1`);
   swap BGR→RGB; flip rows when descriptor bit `0x20` is clear (bottom-left
   origin). Produces top-down RGB bytes without using F04's parser.
2. **Second decoding method / multiple passes**: Pillow `Image.open().convert('RGB').tobytes()`
   compared byte-for-byte to the manual decoder for all 21 sampled masks,
   including every histogram-anomalous case (land_0 B-distinct 248, coastal_0
   238, land_176 B-distinct 1, peninsulas_5 five starts, the two DLC5 grey
   files, both `.src` top-left masters). All 21 agree exactly; no anomaly was
   accepted on a single pass. Raw header bytes were additionally dumped
   independently for three files.
3. **Corpus-wide scan** (`corpus.py`): numpy `bincount` per channel over all
   1,331 / 1,856 / 1,279 masks; exact white-pixel count via boolean mask;
   non-start R/G≠0 counted by `(~white)&((R≠0)|(G≠0))`. This is a genuinely
   independent instrument from F04's Python `Counter` reader.
4. **Height relation**: read `generatemap.inc:4-7,537-547,563-574` and
   `texturemap.inc:29-31` verbatim; compute `h=−1.1·B/255` per pixel and
   compare the med/22 transect to F04 §6; cross-check the port algebra at
   `mapgen.gd:212-215`.
5. **Start markers**: exact `(255,255,255)`; coordinates reported top-down,
   with width 320 for `_gauss` and 256 for `.src` (an initial width-320 assumption
   for `.src` was detected and corrected on the second pass — see §6).

## 3. Verification results per mask (21-mask spanning sample)

`R0/R255` and `G0/G255` are zero/255 counts; `B dist` = distinct B values over
non-start pixels; `RG≠0` = non-start pixels with R or G nonzero; `Pillow=` =
second-method byte agreement. All 16 vanilla masks cover all **8** vanilla
shape folders (2 each); 3 DLC5-only shapes and 2 `.src` masters added.

| Mask (folder/file) | dim | itype/depth/desc | R0/R255 = G0/G255 | B dist | starts | RG≠0 | Pillow |
|---|---|---|---|---:|---:|---:|:--:|
| continent/4pl_mask_continent_0_gauss | 320² | 10/24/0x00 | 102396/4 | 256 | 4 | 0 | = |
| continent/4pl_mask_continent_1_gauss | 320² | 10/24/0x00 | 102396/4 | 256 | 4 | 0 | = |
| continents/2pl_mask_continents_0_gauss | 320² | 10/24/0x00 | 102398/2 | 256 | 2 | 0 | = |
| continents/4pl_mask_continents_10_gauss | 320² | 10/24/0x00 | 102396/4 | 256 | 4 | 0 | = |
| islands/2pl_mask_islands_0_gauss | 320² | 10/24/0x00 | 102398/2 | 256 | 2 | 0 | = |
| islands/4pl_mask_islands_1_gauss | 320² | 10/24/0x00 | 102396/4 | 256 | 4 | 0 | = |
| land/4pl_mask_land_0_gauss | 320² | 10/24/0x00 | 102396/4 | 248 | 4 | 0 | = |
| land/4pl_mask_land_176_gauss | 320² | 10/24/0x00 | 102396/4 | 1 | 4 | 0 | = |
| mediterranean/4pl_mask_mediterranean_0_gauss | 320² | 10/24/0x00 | 102396/4 | 256 | 4 | 0 | = |
| mediterranean/4pl_mask_mediterranean_22_gauss | 320² | 10/24/0x00 | 102396/4 | 256 | 4 | 0 | = |
| nowater/4pl_mask_nowater_149_gauss | 320² | 10/24/0x00 | 102396/4 | 1 | 4 | 0 | = |
| nowater/4pl_mask_nowater_150_gauss | 320² | 10/24/0x00 | 102396/4 | 1 | 4 | 0 | = |
| nowater2/4pl_mask_nowater_170_gauss | 320² | 10/24/0x00 | 102396/4 | 1 | 4 | 0 | = |
| nowater2/4pl_mask_nowater_176_gauss | 320² | 10/24/0x00 | 102396/4 | 1 | 4 | 0 | = |
| peninsulas/2pl_mask_peninsulas_0_gauss | 320² | 10/24/0x00 | 102398/2 | 256 | 2 | 0 | = |
| peninsulas/4pl_mask_peninsulas_5_gauss | 320² | 10/24/0x00 | 102395/5 | 256 | **5** | 0 | = |
| DLC5 coastal/2pl_mask_coastal_0_gauss | 320² | 10/24/0x00 | 102398/2 | 238 | 2 | 0 | = |
| DLC5 rivers/2pl_mask_rivers_0_gauss | 320² | 10/24/0x00 | 102398/2 | 256 | 2 | 0 | = |
| DLC5 lakes/2pl_mask_lakes_0_gauss | 320² | 10/24/0x00 | 102398/2 | 256 | 2 | 0 | = |
| `.src` mediterranean/4pl_mask_mediterranean_22 | 256² | 10/24/**0x20** | 65532/4 | 2 | 4 | 0 | = |
| `.src` land/4pl_mask_land_0 | 256² | 10/24/**0x20** | 65532/4 | 2 | 4 | 0 | = |

All `idlen=0`, `cmtype=0`, `origin=(0,0)`; `.src` files carry `cmap_depth=24`
(unused because cmtype=0). SHA prefixes independently match F04 where
comparable: nowater2/176 `05fefad305f46e2f`, med/22 `159eb0a78b5132fe`,
islands/0 `540ef4fbdb595845`, peninsulas/0 `b342397d9b683604`, med/22 `.src`
`7ac2e9c812671577`. [O]

**Notable per-mask facts [O]:** `land_176` / all `nowater*` masks are exactly
zero height off starts (B=0 on all 102,396 non-start px; the four B=255 px are
the white starts) — so a mask-only height field is flat there; the ±2.964 m
values seen in earlier height dumps cannot come from these masks. `med/22`
mean h = −0.2247 m, 21,895 non-start px below −0.25 m (21.383%). `islands/0`
mean h = −0.6787 m, 64.2% water. Start coordinates for med/22 `(39,31),
(192,164), (62,262), (289,288)` and islands/0 `(99,68), (189,260)` reproduce
F04 §7 exactly.

## 4. Corpus-wide verification of the headline [O]

| Tree | Files | Starts | non-start R/G≠0 | R values | G values | B values |
|---|---:|---:|---:|---|---|---|
| `terrainmasks` (vanilla) | 1,331 | **5,125** | **0** | 0:136,289,275 · 255:5,125 | same | 256 distinct; 0:74,903,914 · 255:47,429,165 |
| `terrainmasks.dlc5` | 1,856 | 7,616 | **8** | 0:190,046,776 · 255:7,616 + 8 grey | same | 256 distinct; 0:115,932,222 · 255:54,462,154 |
| `terrainmasks.src` | 1,279 | 4,813 | 0 | 0:83,815,731 · 255:4,813 | same | **exactly 2**: 0:49,254,648 · 255:34,565,896 |

Vanilla per-file start-count histogram: 2→214 files, 3→228, 4→716, 5→17,
6→36, 7→112, 8→8 (sum 1,331 files; weighted sum 5,125 starts). Every start is
an isolated single pixel; where two starts are 1–2 px apart (five files) they
are still distinct single pixels. [O]

**Verdict:** F04 §5.1–5.3 corpus numbers are **independently reproduced with
zero numerical deviation**. F04's central claim — R/G are start-only, B is the
only continuous channel, 5,125 white starts — is **verified**. [O]

## 5. B→height / threshold verification [O + D]

- **[O] Donor constants** (`generatemap.inc:4-7`): `cWaterHeight=−1.1`;
  R class codes at `:21-32`; `cBColorWater=255`.
- **[O] Formula site** (`generatemap.inc:567,574`): `hwater =
  cWaterHeight*(fb*(1+fr*3.5))`; `SetHeightData(realx, realy, hwater+hterrain)`.
  `:569-573` adds `hterrain` only for the R classes plateau/hill/ravine;
  shipped R=0 ⇒ `hterrain=0`.
- **[D] Simplification:** with `fr=0`, `h = −1.1·(B/255)`, range `[−1.1, 0]`.
  `h<−0.25` (water/collision, `texturemap.inc:29-31`) ⇔ `B > 0.25·255/1.1 =
  57.95` ⇒ **B≥58**; `h<−0.1` (shore) ⇔ **B≥23.2**.
- **[O] Transect check** med/22, y=160, x=112..119: B `0,2,13,49,114,193,251,255`
  → h `0, −0.0086, −0.0561, −0.2114, −0.4918, −0.8325, −1.0827, −1.1` —
  identical to F04 §6. B is a monotone *water-bed field*, not a binary flag in
  `_gauss` masks (binary only in `.src`). [O]
- **[O] Port decode** (`mapgen.gd:212-215`) uses the same algebra at 320²;
  at 240² it averages 1–2 source pixels per cell and skips white starts —
  **PORT APPROXIMATION** of the donor nearest-pixel sample
  (`generatemap.inc:541-542`). The donor coastal smooth passes
  (`generatemap.inc:580-643`) are replaced by the port's 1/2/3-pass radius-1
  average — **PORT APPROXIMATION**, native kernels **[U]**.

## 6. Discrepancies found in F04 (both minor, headline unaffected) [O]

1. **`peninsulas/4pl_mask_peninsulas_5_gauss.tga` is not a near-duplicate.**
   F04 §8's exception table lists it as having "closest pair 1–2 px". Fresh
   extraction (manual decoder + Pillow, both agreeing) finds 5 starts at
   `(149,18),(251,98),(14,122),(66,269),(269,288)` with minimum pairwise
   distance **129.63 px** (40.5% of width). Its `.src` master likewise has 5
   starts, min **104.02 px**. It is a genuine 5-start mask whose filename says
   `4pl`, i.e. a **prefix exception only**. The actual 1–2 px near-duplicates
   are the other five files F04 lists: `land_113` (1.0), `land_114` (1.0),
   `med_51` (1.0), `med_62` (2.0), `islands_98` (2.0) — all confirmed. COORD
   should amend F04 §8's "six" to five near-duplicates + one prefix exception.
2. **F04 E4's first-pixel example is mis-parsed.** The `0xFF` at payload
   offset `0x12` is the RLE packet header (raw run of 128 pixels), not a pixel.
   The first actual pixel bytes are BGR `00 00 00` → RGB(0,0,0); decoded
   med/22 `[0,0]` and bottom-left `[319,0]` are both `[0,0,0]`. The
   "R=0,G=0,B=255" reading is wrong for that byte position, but the rest of
   F04's channel analysis stands.

Also noted (not a discrepancy): F04 §7's `.src` start coordinates were not
provided by F04; my first pass mistakenly used width 320 for `.src` (yielding
impossible x=296 on a 256-wide image), detected on the second pass and
corrected to width 256. Corrected `.src` med/22 starts: `(31,25),(154,131),
(50,210),(231,184)`; `.src` land_0: `(166,31),(40,56),(197,196),(47,213)`.

## 7. Implications for spec §03 (mask → height)

1. **[O] Spec §03 should ingest B as the sole continuous field.** R and G can
   be parsed but carry no class data on shipped assets; the R relief codes
   (255/191/96/112/48/88/64) and G forest/stone codes (255/127/64/128/192)
   described at `generatemap.inc:454-485` are **donor intent**, not present
   pixels. Do not synthesize relief/forest from R/G. [O]
2. **[O] Start detection = exact `(255,255,255)`**, skip that pixel in height
   (`generatemap.inc:565-566`). The donor keeps every start; the port's
   farthest-pair reduction (`mapgen.gd:96-117`) is **PORT APPROXIMATION**.
   Guard the five 1–2 px near-duplicate masks so two armies are not placed on
   one tile; treat `peninsulas_5` as a normal 5-start mask.
3. **[O] Water threshold must be `h<−0.25` (B≥58), not `B=255`.** Using B=255
   alone loses ~4–20 percentage points of water vs the donor formula
   (med/22 17.41% vs 21.39%; islands/0 53.75% vs 64.22%). [O]
4. **[O] Orientation:** descriptor bit `0x20` must be honoured (`_gauss`
   bottom-left `0x00`, `.src` top-left `0x20`); otherwise every mask mirrors.
5. **[I] Height ceiling from masks alone is 1.1 m**, so readable hills/
   mountains must come from the pattern relief-stamp stage (D05/F01 scope),
   not from mask R. Align spec §03 with §04 on this boundary.
6. **[O] PORT APPROXIMATION:** the port's 56 PNGs cover 56/1,331 vanilla masks,
   0/1,856 DLC5, and its 240² block averaging + substitute coastal smoother
   diverge from donor sampling (`generatemap.inc:541-542,580-643`).

## 8. Risks

- **Text-vs-runtime risk [U]:** all `.inc` lines are `[*] = ;` intent text;
  pixel statistics are hard [O], but actual execution of `generatemap.inc`
  in the shipped `cossacks.exe` is unverified (D03/D05 scope). No donor binary
  was run (charter rule).
- **Unit risk [U]:** "metres" is the name of the donor constant, not a
  recovered px→world conversion. Distances here are in mask pixels/fractions.
- **Instrument risk:** the two decoders agree on 21/21 sampled files, and the
  full-corpus scan used a third code path (numpy), so a shared parser bug is
  unlikely; `.src` origin handling required a deliberate second pass (§6).
- **Cross-report risk:** F04's other measurements (spacing percentiles, water
  distance, ASCII shapes) were not all re-derived here; this ticket verifies
  the channel/count/height claims and two specific exceptions, not every F04
  statistic.
- **Anomaly risk:** 5 near-duplicate start masks + 2 DLC5 grey-pixel files are
  real source-data quirks; a converter assuming `Npl == marker count` or
  `R,G,B∈{0,255}` will mis-handle them.

## 9. UNVERIFIED register (do not promote)

1. Runtime execution of `generatemap.inc`/`texturemap.inc` `[*] = ;` text.
2. `fa` value for a 24-bit donor TGA → road `broad` flag (`generatemap.inc:348-351`);
   no alpha byte exists in any mask.
3. Native kernels of `SmoothTerrain` and `_misc_SmoothTerrainCustom` (`generatemap.inc:580-643`).
4. Pixel→cm scale behind the published start-spacing rule.
5. Whether the 8 grey pixels are deliberate or a re-export defect.
6. Whether the four `.removed` masks are ever loaded.
7. Stage order of pattern stamps vs coastal smoothing in the shipping build.
8. Any donor GPU A/B frame — **none exists**; no parity claim of any kind.

## 10. Open questions (for COORD / other workers)

- **COORD:** amend F04 §8 (five near-duplicates + one prefix exception) and
  F04 E4 (first byte is an RLE packet header) in the integration log.
- **D03/D05:** confirm native sampling/smooth kernels and stamp-vs-smooth order.
- **F03:** does any cfg select `.src` masks or `bRandomMap` postprocess?
- **A01/A02:** adopt B-only height + `B≥58` water rule in spec §03; decide
  start handling and whether to ingest beyond 8 masks per shape.
- **A05:** add a QA gate asserting new converted PNGs are byte-identical to
  donor TGA pixels and that non-start R/G are zero (catches orientation flips
  and invented relief data).

## 11. Five-line summary

- **[O] VERIFIED:** a fresh numpy+Pillow scan of all 1,331 vanilla masks exactly reproduces F04 — R/G = {0:136,289,275, 255:5,125}, zero non-start R/G≠0, all 5,125 white pixels are single-pixel starts.
- **[O] VERIFIED:** format is 18-byte-header RLE truecolour 24-bit BGR (itype 10, 320² desc 0x00 bottom-left; `.src` 256² desc 0x20), no alpha; raw header bytes and SHA prefixes match F04.
- **[O] VERIFIED:** B→height is `h=−1.1·B/255` (`generatemap.inc:4-7,567,574`), med/22 transect reproduced exactly; water `h<−0.25` ⇔ B≥58; port `mapgen.gd:212-215` uses the same algebra (block-averaging/coastal smooth = PORT APPROXIMATION).
- **[O] VERIFIED:** DLC5 (1,856 files, 7,616 starts, 8 grey px at F04's coords) and `.src` (1,279 files, 4,813 starts, B binary) agree; two minor F04 errors found — `peninsulas_5` is not a near-duplicate (129.63 px), and E4 mis-parses the RLE header as a pixel.
- **NO donor GPU A/B frame exists; no donor-parity claim.** All port-side statements are port-internal measurements or PORT APPROXIMATION.

*End of X18. Exactly one report written. No donor binary executed or copied; no repo file other than this report modified; no Godot runner job; no parity claim.*
