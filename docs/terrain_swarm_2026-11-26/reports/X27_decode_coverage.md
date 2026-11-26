---
id: X27-DECODE-COVERAGE-2026-11-26
ticket: "TERRAIN-SWARM-2026-11-26 / X27 — honest coverage audit of what 'decode EVERY SINGLE bit of the DONOR' actually achieved"
title: "X27 — donor decode coverage audit: decoded / partial / untouched by artifact class"
agent: "X27 (read-only coverage-audit worker, DONOR-FIRST terrain swarm)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_DONOR_BINARY__NO_GODOT_JOB
owner_file: docs/terrain_swarm_2026-11-26/reports/X27_decode_coverage.md
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_guard: "NO DONOR VISUAL PARITY CLAIM. No donor GPU A/B frame exists and no donor binary was executed by this worker. 'Decoded' means a labelled byte/line/instruction was recovered; it never implies a visual or behavioural match."
scope_guard: "Exactly one repo file written (this report). Donor at C:\\Games\\Cossacks 3 read only via already-landed reports; no donor file opened for writing, no code/asset/config/test/git/runner state touched."
sources_read: "CHARTER.md, SWARM_BOARD.md, spec/README.md, spec/00_EVIDENCE_INDEX.md, spec/01–14, and all landed reports listed in §7 of spec/00_EVIDENCE_INDEX.md; multiple passes on every count contradiction (§6)."
evidence_snapshot: "56 landed reports at final directory read; no code, asset or gate edits."
---

# X27 — Decode coverage audit (donor-first terrain swarm, 2026-11-26)

## 0. Executive summary

1. **[O] The owner's instruction "decode EVERY SINGLE bit of the DONOR" was executed as a *targeted* swarm, not a literal whole-donor decode.** What actually landed is: byte-exact formats for the terrain-relevant donor data (`.pattern` 710/710, `pattern.lib` plaintext, 4,466 terrainmask TGAs, 7 cfg files, 124 tile ids, the water/tile shader text), plus instruction-level reads of roughly two hundred named functions. Whole-binary pseudo-C corpora were bulk-exported (18,918 `cossacks.exe` functions; 22,384 `editor.exe` functions) but the tool's own flags mark **4,265 (22.54%)** and **12,254 (54.7%)** of them respectively as garbled/unstructured. [Sources: X01 §4.1, X02 §4]
2. **[D] The honest headline is "high coverage of terrain-relevant *data*, medium coverage of terrain-relevant *code*, near-zero coverage of runtime *activity*."** Every `.inc` statement is a passive `[*] = ;` text line; X03 recovered 972 verbatim excerpts and F03 all cfg literals, but **execution of those lines in the shipped EXE is `[U] CONFIRMED_UNVERIFIED` across all workers** (spec/00 §5 U10). No donor binary was run, so no compiled path was observed to consume any decoded value.
3. **[O] Binary coverage is further capped by discovery and packing.** X01 exported 18,918/18,918 *discovered* functions yet found **only 11 of 34** D01 terrain anchors present as entries (**23 absent**); `editor.exe` strings carry rich terrain vocabulary (104 `terrain`, 107 `water`, 103 `pattern`, …) with **0 code xrefs**. Both binaries have a packed/obfuscated `.bind` section (entropy 7.96) that was never unpacked. [X01 §4.3, X02 §1/§5.3, D01 E2]
4. **[O] Three classes are effectively untouched:** `config.exe` / `modman.exe` / `cdx` (only a cross-check byte sequence of the RNG LCG at `config.exe:0x33701b`, `modman.exe:0x191dc1`; no corpus, no VMT map, no `cdx` work at all); packed `.bind` stubs; and the 49 baked DLC mission `.map` files (2.877 GiB, deliberately deferred as closed campaign snapshots with no generator delta). [D02 §3 Anomaly B, F10 §0/§8]
5. **[D] "Every single bit" is not achievable under this charter's rules** (read-only donor, no execution, no GPU frame, built-in lifter garbles >1/5 to >1/2 of functions, packed sections undecodable). The realistic ceiling is: complete byte-level decode of readable *data* (achieved for the terrain subset) plus on-demand instruction reads of named functions, with all semantics that depend on runtime still labelled `[U]`/`PORT APPROXIMATION`. No parity claim is made or implied.

---

## 1. Method and conventions

- **What counts as DECODED [O]:** a literal byte, line, VA, opcode sequence or count was read and cited to a donor path:offset:line or a Craft Anything evidence id.
- **What counts as PARTIAL:** layout/values recovered but semantics, consumer or runtime effect remain `[I]`/`[U]`; or only a subset of the class was full-read.
- **What counts as UNTOUCHED:** no report read the artifact beyond a passing mention/cross-check.
- **Runtime activity** is tracked separately from decode: a fully decoded text file whose lines are `;`-prefixed is **DECODED-BUT-UNVERIFIED**, not "not decoded". This distinction is mandatory (CHARTER §2, spec/00 §5 U10).
- **Multiple passes** were applied to every count contradiction found (§6); the authoritative reading is the later, instrument-cross-checked one.

---

## 2. Evidence table (load-bearing counts)

| # | Evidence id / path | What it establishes | Label |
|---|---|---|---|
| E1 | X01 §4.1 (`craft-pseudocode-export.json`, 2,734,801 B) | cossacks.exe 18,918/18,918 discovered functions exported; 295,400,669 B; 14,653 structured / **4,265 unstructured (22.54%)**; 0 failures | [O] |
| E2 | X01 §4.3, X01 E13 | **11/34** D01 anchors present, **23/34 absent** from discovery set; `0x72d7f0` inside unstructured host `sub_72d64c` | [O]/[D] |
| E3 | X02 §4 (`garble_counts.txt`) | editor.exe 22,384/22,384 functions, 312,158,176 B; **12,254 (54.7%)** with ≥1 garble marker, 559 with ≥1,000; 62,898 strings, 0 terrain-code xrefs | [O] |
| E4 | D01 §0/§4 (`ev_0d83cdaa…` etc.) | 1,182 Delphi VMTs statically recovered, 64 terrain/world classes extracted; only 11 concrete functions multi-passed; ~45/64 ctors `[U]` | [O]/[U] |
| E5 | D02 §4.2 (`ev_3dfbf17f…`, `ev_6283059d…`) | exact LCG `s=(s*0xFC0D+0x3C6EF35F) mod 2^32`, output `f32(s/2^32)` at `0x60f64c`–`0x60f696`; identical bytes in editor/config/modman | [O]/[D] |
| E6 | X03 §0/§2 (spec/10_STAGE_ORDER.md:73) | 972 line-cited verbatim excerpts (1,300-line report); D1 2,103 / D2 1,059 / D3 289 / D4 963 / D5 246 / D6 171 / D7 466 / D8 2,367 lines; D9 7,013 lines targeted | [O] |
| E7 | F03 §2 SHA table | 7 cfg files fully hashed/parsed: 20 global keys, 13 local, 8 tile sections/30 names, 22 chains/118 active groups/282 active entries/86 names/Σ174.0168, 64 families/493 pairs, 19 presets/61 masks/276 legend entries | [O] |
| E8 | F09 §0 | editor.aix 173 `Name =` records; scripts/editor.inc 142 files; data/scripts 222 files; **367 text files / 109,581 logical lines** indexed; terrain subset full-read, rest keyword-indexed | [O] |
| E9 | F01 §4.1/E4 | `.pattern` size closure `8+4wh+54(w−1)(h−1)` verified **710/710**, zero residual; G=`8+(w−1)(h−1)`; 550,908 records; 678/680 min/max bit-exact | [O]/[D] |
| E10 | F02 §0/X05 | pattern.lib 30,309,138 B plaintext, 680 sections, 1,172,417 split lines, 205,571 struct pairs, 39,780 object records (39,783 incl. 6-space), 235 BaseName, 37-key prologue | [O] |
| E11 | F04 §0/§5 | 4,466 TGAs full-decoded (1,331 vanilla + 1,856 dlc5 + 1,279 src); R/G start-only, B all 256 values, h=`−1.1·B/255`; port only 56/1,331 (4.2%), 0/1,856 dlc5 | [O] |
| E12 | D04 §4/§7 | .map 37-byte record invariants 102,400/102,400 and 147,456/147,456; height count `(W+1)²−2` vs writer `(W+1)²` `[U]` after 6 passes; tag-grid/owner/collision `[U]` | [O]/[U] |
| E13 | F05 §1/§4 | 124 tile ids per season, 112 DDS (108 referenced), 245 `tiles.lib` sections, 253 `tiles.mat` sections; 36 face ids FACE_BASE_REUSE, 3 alpha sentinels EMPTY; cliffs/covers 0-byte | [O]/[D] |
| E14 | F06/D08/X17 | alpha.bmp 512×256 8bpp data@1070; alphavert.bmp 1024×512 24bpp; bmTransparency → `glBlendFunc(SRC_ALPHA, ONE_MINUS_SRC_ALPHA)` at VA 0x4ef991/0x88fbb0; **pass count `[U]` after 6 passes**, `tiaAlphaFromIntensity` `[U]`, tile→patch `[U]` | [O]/[D]/[U] |
| E15 | D06/X11 §1 | water.dev.frag/vert fully decoded (coast 0.57, exponents 170/120, 9-octave chop, foam 0.535); `FUN_00853ad4` 30 key names no bind; heightmapwaves0.tga alpha=255 all 65,536 px; hmapTex binding/plane Y `[U]` | [O]/[U] |
| E16 | F10 §0/§2/§3 | dlcs/ = 67 files / 3,089,187,248 B (49 .map + 18 .aix), zero terrain-generation assets; 365 new masks + 31 replaced in base install; season value in DLC maps `[U]` | [O]/[D] |
| E17 | P02 §0/§2/§4 | port terrain tree 2,358 files / 2,228,567,934 B; 110 terrain-relevant model sids; 1.545 GB dormant decals; only subset wired; all "wired" = static reachability, runtime `[U]` | [O]/[U] |
| E18 | V15 §4/X07 §4 | no reliable stills for mountains, sea, rivers/swamps, iron/coal mines ("highlands" wallpaper a 2-pass false positive); three-tier verdict vocabulary, parity always UNVERIFIED | [O]/[U] |
| E19 | V17 §0/§2 (point-in-time) | at audit time no spec section unconditionally READY; §00 missing; X09/X12/X18/X19/V03 orphaned then; §09 the only internally complete section | [O]/[D] |
| E20 | spec/00 §4.9/§5 | 16 post-V16 corrections P1–P16 and 22 consolidated UNVERIFIED items U1–U22; evidence-id transcription hygiene recorded | [O]/[D] |

---

## 3. Coverage matrix

Legend: **DECODED** = bytes/lines/opcodes recovered and cited; **PARTIAL** = layout/values recovered, semantics or full scope missing; **UNTOUCHED** = no substantive read. "Runtime" column is independent: **UNVERIFIED** = decoded but execution not proven; **N/A** = not applicable (data at rest).

### 3.1 Binaries

| Artifact | Decode status | Quantified coverage | What remains | Runtime |
|---|---|---|---|---|
| **cossacks.exe** (5,768,048 B) | **DECODED (data/code) + LARGE PARTIAL (semantics)** | 18,918/18,918 discovered functions exported (281.7 MiB); 14,653 structured / 4,265 garbled; 1,182 VMTs, 64 terrain classes; exact LCG; `.map` record; stamp `sub_755f30` 25,175 B/6,751 instr; water descriptor; blend factors | 23/34 terrain anchors absent from discovery; ~45/64 ctors `[U]`; 4,265 garbled functions treated as data; `.bind` packed; row-sign flip, global setter clamp, `HeightFieldMax` consumers, `PatternMaskStand`→occupancy, `SmoothTerrain` kernel all `[U]`; `GenerateMapRandKey` body `[U]` | **UNVERIFIED** (no execution) |
| **editor.exe** (7,874,416 B) | **DECODED (bulk+DFM) / SEMANTICS PARTIAL** | 22,384/22,384 functions (298 MiB); 62,898 strings; 104 terrain / 107 water / 103 pattern / 104 field vocabulary recovered; TFormMapGen VMT `0x33dfb8`, orchestrator `0x87b7ec`, 12-stage gate map; **12,254 (54.7%)** garble-marked, 559 ≥1,000 | 0 code xrefs on terrain strings → no function honest-labelled "generator"; data-as-code bands 0x5d8cac–0x5e36b0 and 0x849098+ need Deep re-lift; brush handlers (raise/lower, road polygons, water glints/currents, snow) have zero script hits, parameters `[U]` | **UNVERIFIED** |
| **config.exe / modman.exe** | **UNTOUCHED (except one byte cross-check)** | RNG byte sequence at `config.exe:0x33701b`, `modman.exe:0x191dc1` identical to cossacks LCG (D02 Anomaly B pass 5). No corpus, no VMT map, no section decode | Everything else: their terrain classes, DFM resources, config-file readers, any packed regions | **UNVERIFIED** |
| **cdx** | **UNTOUCHED** | No report mentions `cdx` at all (grep across reports: 0 hits). Not in any worker's assignment | Entire artifact | N/A |
| **packed `.bind` stubs** (entropy 7.96) | **UNTOUCHED** | cossacks `.bind` entropy 7.96 (D01 E2, D05 R3, D02 §6); editor `.bind` VA 0x76f000 size 0x23d70 (D09 §3); `0x42fb6c VirtualAlloc(RWX)` flagged possible unpack staging (X02 §5.2) | Never unpacked/executed. Potential secondary stamp paths, mesh builder (would settle X17 pass count), and RNG code are beyond this corpus | **UNVERIFIED** |

### 3.2 Donor text

| Artifact | Decode status | Quantified coverage | What remains | Runtime |
|---|---|---|---|---|
| **dogenerate.inc / generatemap.inc / texturemap.inc / smoothtiles.inc / …** (X03) | **DECODED (verbatim) / RUNTIME UNVERIFIED** | 972 line-cited excerpts; 12-stage call order verbatim; all stage constants (2.964/−1.1, ×3.5, R/G/B codes, 3 smoothing groups, water 2×320/−0.5, ellipses 5×7/12×15/22×18, mine radii 14+8R…, cSize 25); 5 contradictions + 13 anomalies multi-passed | Every line is `[*] = ;` intent; 16 X03 UNVERIFIED items (U1–U16) include key mixing, `SmoothTerrain` kernel, tile cfg contents, `gc_MaxTerrainTypeCount`, DScript local init; row-sign and width-as-y anomalies preserved | **UNVERIFIED** (the single biggest categorical gap) |
| **generator.cfg / startingsettings.cfg and 5 other cfg** (F03) | **DECODED (literals) / MEANINGS PARTIAL** | 7 files hashed; 20 global keys, 13 local, mapcover 1 zone with empty seasonal names, tilesmooth.cfg 8 sections/30 names, tilesmooth_scripts.cfg 22/118/282/86/Σ174.0168, generator.cfg 6+9 masks + 64 families/493 pairs, startingsettings.cfg 19 presets/61 masks/276 legend entries | Many key meanings `[I]/[U]` (`Size`, `CellsResolution`, castle keys, `Freq` consumer); no seed/RNG/water/mine constant in cfg (F14); `TileSmoothPasses=6` vs script 3 preserved; cfg points at `tilesmooth.cfg` while script loads `tilesmooth_scripts.cfg` | **UNVERIFIED** (consumer lines `;`-prefixed) |
| **rest of data/scripts (222 files)** (F09) | **PARTIAL** | Corpus-wide keyword index **367 files / 109,581 lines**; terrain subset full-read; ~22 native call names with argument order; ~20 DScript helper signatures recovered | Non-terrain 200+ files keyword-indexed only, not full-read; formal parameter names/types of native calls `[U]`; native kernels not in text | **UNVERIFIED** |
| **.aix / .inc editor corpus** (F09) | **PARTIAL** | editor.aix 173 `Name =` registrations, 142 editor.inc files; UserTerrain BMP path fully decoded (320×320 guard, classes cPlateau=1…cForest=5, 2.964/−1.1, two different water tests); editor states shown distinct from skirmish | Editor-only brushes have zero script hits (native editor.exe handlers, `[U]`); `postprocesssaver.inc` not fully read; 12 F09 UNVERIFIED items U1–U12 | **UNVERIFIED** |

### 3.3 Data formats

| Artifact | Decode status | Quantified coverage | What remains | Runtime |
|---|---|---|---|---|
| **`.pattern`** (F01) | **FORMAT DECODED 710/710; SEMANTICS PARTIAL** | closure `8+4wh+54(w−1)(h−1)` zero residual; 5 regions with exact offsets; G=`8+(w−1)(h−1)`; 550,908 `Rec24`; weights `4N−1` int32; 17/29 DPATTERN offsets corrected; 678/680 min/max exact | `Rec24.id` (0…255), `tail[4]`, PRE, weight values 0/99/100/101/200, `Tail13` i16 −1/255 & flag 0/1 all `[U]`; 2 stale sections; engine blend and row-flip `[U]`. **FULL w×h grids decoded for ~30 named patterns only; ~50+ active ids not bit-decoded (spec/00 U14)** | N/A (data at rest); blend use UNVERIFIED |
| **`pattern.lib`** (F02/X05) | **CONTAINER DECODED (plaintext)** | 30,309,138 B, 680 sections, 37-key prologue, 1,172,417 split lines, 205,571 struct pairs, 39,780 objects, 235 BaseName; 12 grid cross-checks bit-exact; 680 name→file (679 exact + 1 case) | Engine consumption of fields `[U]`; `m_swamp_12_old` 17×20 vs binary 18×23 quarantined; 30 `.pattern` files with no section; 217 sections in no family (editor brushes) | **UNVERIFIED** |
| **terrainmasks** (F04/D03) | **FULL-CORPUS DECODED** | 4,466 TGAs (1,331 + 1,856 + 1,279) inventory and pixel histograms; RLE 24bpp, final 320² bottom-left / src 256² top-left, no alpha; B all 256 values, h=`−1.1·B/255`, water B≥58; 5,125 white starts; 6 near-duplicate + 2 grey-pixel anomalies | Native `SmoothTerrain` / `_misc_SmoothTerrainCustom` kernels `[U]`; `fa`/road `broad` cannot be read from 24-bit files; port covers 56/1,331 and 0/1,856; 31 replaced dlc5 masks not per-pixel diffed | Script pixel formula decoded; **execution UNVERIFIED** |
| **`.map`** (D04) | **LAYOUT DECODED / SEMANTICS PARTIAL** | serializer `sub_739d3c`, loader `sub_73a0b8`; `(2W)²` tag grid; `(W+1)²−2` f32 heights; `W×H×37` records; 4×u8 tile ids + 4×1.0f weights; invariants on 102,400 and 147,456 records | height-count shortfall vs writer loop `[U]` after 6 passes; tag-grid enum, byte-12 variation, `FFFF` marker, per-cell collision flags[4], owner/visibility/resource pointer, 41-byte gap, `−1.1` sentinel all `[U]`; non-terrain sections not scanned | N/A (data at rest); runtime loader path UNVERIFIED |
| **alpha / alphavert / bmTransparency** (F06/D08/X17) | **BLEND MECHANISM DECODED / KERNELS UNVERIFIED** | alpha.bmp 512×256 8bpp; alphavert.bmp 1024×512 24bpp; alphanull.bmp all-zero; `bmTransparency`→`glBlendFunc(SRC_ALPHA, ONE_MINUS_SRC_ALPHA)` at VA 0x4ef991/0x88fbb0, table 0x8fb1c4/0x8fb1c8; exact shader crossfade equation | **composite pass count `[U]` after six passes**; `tiaAlphaFromIntensity` formula `[U]`; tile-id+direction→`gl_MultiTexCoord1` patch selector `[U]`; `glBlendEquation` extension tail `[U]` | **UNVERIFIED** |
| **tiles / presets** (F05) | **ID CHAIN DECODED / RENDER PARTIAL** | 124 ids/season; 112 DDS/108 referenced; 245 tiles.lib + 253 tiles.mat sections; 36 face ids + 3 alpha sentinels enumerated; 16×8 port atlas 121 filled/3 empty | 36 face cells are FACE_BASE_REUSE (25° tilt + alphavert eye-linear projection dropped); 3 sentinel cells are holes; `tsDouble/ttExtended` sub-tiling `[U]`; selection script fully commented; runtime dump samples only 31 ids (0–85) so gaps untested | **UNVERIFIED** |
| **water shaders** (D06/X11) | **SHADER TEXT DECODED / BINDING UNVERIFIED** | water.dev.frag/vert full constants; coast 0.57 / deep 1.07, exponents 170/120, particle 30, mat2, 9-octave chop, foam 0.535; `FUN_00853ad4` 30 keys no bind; heightmapwaves0.tga alpha=255 all 65,536 px; HeightMapWaves0 block all commented | `hmapTex` actual texture/FBO, sampler units, plane Y, reflection target, foam width `[U]`; missing donor stages `CalcTerrain`, `test_shadow`, fog mode 1, tile-side shore painting; `WaterSet=Winter` resolution `[U]` | **UNVERIFIED** |

### 3.4 Props, DLC, editor tools, engine internals

| Artifact | Decode status | Quantified coverage | What remains | Runtime |
|---|---|---|---|---|
| **props / models / animations / audio** | **STRUCTURAL PARTIAL** | F07/X22 field = 7×7=49 runtime nodes, size 1.6981 cells, 45°; F08/F02 235 BaseName, 39,780 object records; P02 port side 110 terrain-relevant model sids, 299 OBJ, 19 anim files; terrainmesh1..4 converted (112 records) | Per-pattern id→prop binding `[U]` (F01 U1); 39 spare shore rocks, 21 unused env-prop families, 6 unused wave sheets dormant; 1.545 GB building decals unbound; **audio not covered by any report**; animation use beyond mill rotor not enumerated; runtime placement rules mostly PORT APPROX | **UNVERIFIED** (no QA atom result for relief props) |
| **DLC maps** (F10) | **INVENTORY DECODED / PAYLOAD UNTOUCHED** | 67 files / 2.877 GiB (49 `.map` + 18 `.aix`); 365 new masks in base install; 31 replaced; season gating decoded | Baked terrain payload opaque; season integer in DLC maps `[U]`; folder→DLC manifest absent; "winter" map has zero `winter` tokens; deliberately deferred as campaign content | N/A |
| **editor-only tools** (F09/D09) | **UI SURFACE DECODED / HANDLERS UNTOUCHED** | DFM control labels (`HeightField*`, `Water Smooth Passes`, `Forest Patterns File`, plateau/hill/river factors, `AutoNormalizeTerrain`); TFormMapGen VMT + 12-stage flag map | Brush tool DScript names/params `[U]` (zero script hits, native editor.exe); editor DFM stream consumers not mapped; formal parameter semantics `[U]` | **UNVERIFIED** |
| **runtime engine internals** | **SMALL ISLANDS DECODED / MOSTLY UNTOUCHED** | D01 1,182 VMTs, 5 core ctor/dtor pairs verified; D02 3 RNG streams; X12 stamp formula 3 branches; D08/X17 blend setter; D04 serializers | ~45/64 ctors `[U]`; long virtual arrays meaning `[U]`; 23/34 anchors absent from discovery; `SmoothTerrain`/`PlateauTerrain`/`PaintTerrain`/`WaterFieldAdd` kernels `[U]`; global setter clamp `[U]`; mesh builder in `.bind`; no whole-binary semantic model | **UNVERIFIED** |

---

## 4. Decoded-but-unverified vs not-decoded (explicit separation)

**[D] This distinction is the single most common source of over-claiming in this swarm.**

**Category A — fully decoded, runtime activity UNVERIFIED (text/opcode recovered, execution unproven):**
- all 972 X03 excerpts (`dogenerate.inc`, `generatemap.inc`, `texturemap.inc`, `smoothtiles.inc`, `smoothforestborders.inc`, `postprocess.inc`);
- all F03 cfg literals (7 files hashed and parsed);
- the F09 editor DScript/native call catalogue and UserTerrain BMP algorithm;
- the `hwater+hterrain` mask formula and its F04 pixel proof (data confirmed; native execution not);
- the 124 tile id→DDS chain and 36 face variants (F05);
- the donor water/tile fragment shaders and the exact `bmTransparency` blend equation (D06/X11/D08/X17);
- the LCG recurrence and 11+3 reseed site list (D02/X03/V01).

**Category B — not decoded at all (or only named/sampled):**
- `cdx` (zero mentions); full `config.exe` / `modman.exe` semantics; packed `.bind` sections;
- 4,265 garbled cossacks functions and 12,254 garble-marked editor functions (data-as-code clusters excluded from inference);
- 23/34 D01 terrain anchors outside discovery; ~45/64 class constructors; `TXTileSmooth.Create` BLOCKED after 4–5 passes;
- `GenerateMapRandKey` body, saved-map key byte mapping, RNG instance class identities;
- native kernels `SmoothTerrain`, `PlateauTerrain`, `PaintTerrain`, `WaterFieldAdd`, tile smoothing pass engine;
- `.pattern` field semantics (`id`, weights, `Tail13`, PRE), engine blend/row-flip/global clamp;
- `.map` height-count cause, tag-grid enum, owner/collision/resource fields;
- `tiaAlphaFromIntensity`, tile→patch selector, `bmTransparency` pass count, `hmapTex` binding/plane Y;
- baked DLC map terrain payload and season values; audio; full animation inventory;
- any donor GPU frame / visual outcome for the five V15 classes.

**[I] Consequence:** a port can be *structurally* faithful to Category A while still being behaviourally divergent in Category B. The swarm's own labels (PORT APPROXIMATION / UNVERIFIED) are the only honest bridge.

---

## 5. Ranked top-10 remaining bits that actually block terrain parity

Ranking = (importance to a faithful terrain frame) × (probability current port is wrong without it). All items are `[U]` unless noted.

| # | Blocker | Evidence / citations | Why it blocks | Owner to settle |
|---|---|---|---|---|
| 1 | **Runtime activation of the `;`-prefixed DScript corpus** | X03 §0/§6 U; F03 F15; F09 U8; spec/00 §5 U10; V17 X5 | If the shipped EXE does not execute these lines (or a native path differs), *every* cloned constant and stage is an approximation. Cannot be proven without donor execution (forbidden). | Owner/COORD (accept as declared UNVERIFIED) |
| 2 | **Stamp height kernel: row-sign flip, global setter clamp, blend order, `HeightFieldMax` consumers** | D05 U1/U3/U6; X12 U1/U2; X03 U2; spec/00 U2/U3/U4/U5; V16 O10 | Determines the actual relief silhouette from the decoded float grids; the part most visibly wrong in the legacy port (flat relief). | D03/D05 binary lane |
| 3 | **`bmTransparency` composite pass count + neighbor-tile patch selector + `tiaAlphaFromIntensity`** | X17 §4.3/U-X17-1/3/4; D08 §7; F06 U-F06-3/4/7; spec/00 U8/U9 (6 passes) | Layer geometry and alpha conversion decide shore/cliff feathering; the port's `rgb*a` is provably non-donor but the correct replacement's layer count is still a guess. | GPU trace / `.bind` decode |
| 4 | **`hmapTex` binding, FBO/sampler units, shader plane Y, missing water stages** | D06 §11 #1/#5; X11 §4/§9; D01 E19 water cluster; spec/00 U7; V16 O11 | Water surface animation and alignment cannot be matched; `heightmapwaves0.tga` is a decoy (alpha=255), so a naive bind produces wrong water. | D06/D08/I10 + GL trace |
| 5 | **Exact RNG replay: `GenerateMapRandKey`, saved-map key bytes, per-instance class identity, draw counts** | D02 U1–U6; V01 U13/spec/00 U13; X21 (vectors not verified against live donor) | Same seed ⇒ byte-identical output fails if key derivation or discarded draws differ; blocks the determinism gate that everything else relies on. | D02/V01 + known-key replay (read-only) |
| 6 | **`.pattern` semantic fields and full relief grids for ~50+ active ids** | F01 E13/E17 + U1–U9; spec/00 U14 (only ~30 grids bit-decoded) | Byte layout closed but id→prop mapping, per-cell weights/collision flags and most grids unknown; without them stamps place the wrong objects or wrong heights. | F01/A03 recipe, D01 RTTI loader struct |
| 7 | **`.map` height-count anomaly + 37-byte record semantics** | D04 U1–U8 (6 passes); spec/00 E1–E3 | Faithful authored-map import and any A/B against shipped maps need the exact grid length, tag enum and owner/collision/resource fields. | D04/D05/D06/D08 |
| 8 | **Native call kernels `SmoothTerrain`, `PlateauTerrain`, `PaintTerrain`, `WaterFieldAdd`** | F09 U1–U4; X03 U3; D03 U; D06 U | Only script-visible wrapper parameters are known; S0 smoothing and water-field plane handling stay approximate. | D03/D06 binary lane |
| 9 | **Whole code coverage gaps: 23/34 anchors, 4,265 garbled functions, `.bind` packed section, 12,254 editor garble functions** | X01 §4.3/§6/U-X01-08; X02 §5.4/§6; D01 §7; D05 R3; X02 §7 | Whole subsystems (TXTileSmooth ctor, TXTerrain/TXHeightField virtuals, mesh builder, editor brushes) are unread. A VMT-pointer-following discovery pass or Deep Ghidra re-lift is required. | COORD tool/config decision |
| 10 | **No donor GPU A/B frame / no visual references for 5 classes** | V15 §4 V-E01…V-E20; X07 §4/§7; spec/00 U1/U22; V16-12/O3 | Not a decode defect but an epistemic ceiling: parity is unmeasurable and no "closer to donor" claim is admissible. The `highlands` still is a confirmed false positive. | Owner (capture) |

**[D] Cheapest high-value fixes** (data already decoded, only integration needed): port-side mask coverage 56→1,331 (F04), tile face/sentinel repair (F05), 8 wave sheets instead of 1 (P02), 680-record pattern.lib index with corrected offsets (F01/X05), full `tilesmooth_scripts.cfg` 118 active groups (F03). These are PORT APPROXIMATION reductions, not parity claims.

---

## 6. Multiple passes on count contradictions (owner directive)

Each contradiction below was re-read in both source reports before the authoritative count was accepted.

| # | Contradiction | Passes | Accepted reading | Authority |
|---|---|---|---|---|
| C1 | X03 excerpts "972" – not printed in X03 itself | spec/10_STAGE_ORDER.md:73 + X03 report length (1,300 lines) | **972 line-cited verbatim excerpts** (X03 contains many more physical lines because each excerpt includes context) | spec/10 §73 |
| C2 | `BaseName` 39,780 vs 39,783 | F02 E18 vs X05 E13, re-read | **39,780** at 9-space indent; **39,783** includes 3 at 6-space. Both true; cite F02 form | spec/00 §4.12 |
| C3 | pattern.lib lines 1,172,417 vs 1,172,416 | F02/X05 split vs CRLF pairs | **1,172,417 split lines / 1,172,416 CRLF** | spec/00 §4.11 |
| C4 | 282 / 310 / 320 smoothing counts | F03 §6 + V20 §3.2 + X08, three passes | one object at three granularities: **310 TileName lines (282 active), 320 Prob tokens (282 active + 38 dead)** | spec/00 §4.9 |
| C5 | `TileSmoothPasses` 6 vs 3; `tilesmooth.cfg` vs `tilesmooth_scripts.cfg` | F03 §4, D06 P22, X11 §7.2 | **preserved donor contradiction**; script value 3 / `tilesmooth_scripts.cfg` followed for skirmish, never promote 6 | SWARM_BOARD C2/C3 |
| C6 | D9 7,013 vs 6,765 lines; `plain_medium` 24/67.6875 vs 31/74.6875 | X03 §6 A7 two instruments | audit numbers wrong; byte size 250,432 matches ⇒ same install; use **7,013 / 24 / 67.6875** | X03 A7 |
| C7 | B>58 vs B≥58 water threshold | X19 E5/E20 vs F04 §6 | `B>58` ⇒ integer B≥59; `h<−0.25` ⇔ B≥58.2; med/22 mismatch 22 px. Cite both with rule | spec/00 §4.13 |
| C8 | 240² vs 320² canonical capture | A05 E14, P03 E19, V16-20, V21 MP7, multiple passes | **OPEN** – both literals exist; no canonical size pinned | V16 O3, COORD/I13 |
| C9 | Structured/unstructured "100% decoded" | X01 §4.1 vs §4.3 | 18,918/18,918 is honest **for discovered functions only**; 23/34 anchors absent ⇒ never say "whole binary decoded" | X01 U-X01-08 |
| C10 | blend factors UNVERIFIED (F06) vs exact (D08/X17) | V16 C-C three passes | factors `[D]` exact; **pass count still `[U]`** after six X17 passes | V03 C-C, X17 §4.3 |

---

## 7. Honest verdict

**[D] "Every single bit of the DONOR" is not achievable under the 2026-11-26 charter, and it was not achieved.** What *was* achieved is a reproducible, labelled decode of the terrain-relevant readable data and a small set of instruction-level function reads, sufficient to *specify* a donor-shaped pipeline but not to *verify* that the donor executes it:

- **Achieved (data):** byte-closure of all 710 `.pattern` files; plaintext closure of `pattern.lib` (680 sections); full-corpus pixel decode of 4,466 terrainmask TGAs; full literal parse of 7 cfg files; 124-id tile chain; both water/tile shader sources; exact 32-bit LCG; 37-byte `.map` record and blend factors.
- **Achieved (code):** 1,182 VMTs / 64 terrain classes anchored; 5 ctor/dtor pairs verified; stamp blend branches, RNG recurrence, serializers and GL blend setter recovered at opcode level.
- **Not achieved:** whole-binary semantics (garbled 22.5%/54.7%, 23/34 missing anchors, `.bind` packed, config/modman/cdx untouched), native kernel internals, data-field semantics (pattern records, `.map` tags, pass count), DLC payloads, and above all **any runtime observation** — no donor binary was run, no GPU frame exists.

**[I] Realistic ceiling:** with read-only static analysis, the maximum honest coverage is "all readable terrain-relevant data bytes + all on-demand instruction reads of named functions", with every runtime-dependent claim permanently `[U]`/`PORT APPROXIMATION`. Lifting that ceiling requires either (a) a VMT-pointer-following discovery pass + a second lifter (Deep Ghidra/IDR) to shrink the garbled/missing function set, or (b) a permitted donor runtime/GL trace to settle Category-A execution and the pass-count/binding questions — both outside today's rules. **No donor visual parity claim is made, now or on the strength of any report audited here.**

---

## 8. Risks

| # | Risk | Label / evidence | Mitigation |
|---|---|---|---|
| R1 | "18,918/18,918 and 22,384/22,384" misread as full-binary decode | X01 §4.3, X02 §4 | Always quote 11/34 anchors and 22.54%/54.7% garble alongside the export totals |
| R2 | Category A (decoded text) promoted to "donor does X" | `;`-prefixed lines everywhere; spec/00 U10 | Keep `[U]` on runtime; no donor execution was permitted |
| R3 | "Converted asset exists" read as "feature implemented" | P02 §0/§6; `world3d_terrain.gd:1515 not_done` | Static reachability ≠ runtime load; require capture |
| R4 | Face/sentinel/sand-upscale tile gaps invisible because dump samples only ids 0–85 | F05 G1–G7, E15 | Add a tile-histogram gate forcing ids 86–123 coverage before any shore/cliff verdict |
| R5 | Count contradictions silently resolved in favour of the wrong report | §6 C1–C10 | Preserve both literals, cite authority, never lower a band |
| R6 | Packed `.bind` assumed empty | D05 R3, X02 §7, X17 §4.3 | "Absence is not proof"; mark `[U]`, not absent |
| R7 | No visual references misread as "no acceptance possible" | V15 §2 tier vocabulary | Use tier-1 structure / tier-2 self-consistency, parity stays UNVERIFIED |
| R8 | This audit is a point-in-time snapshot; more reports/spec integration land concurrently | V17 §8 risk 2, X14 §4.9 | COORD re-check the directory before any dispatch; no report was edited here |

---

## 9. Open questions

1. **COORD:** will a VMT-pointer-following discovery pass + Deep Ghidra re-lift be commissioned to reduce the 23 missing anchors and the 4,265/12,254 garbled functions (blocker #9)?
2. **Owner:** is any read-only donor runtime/GL trace obtainable (known-key `.map` replay pack, GPU capture) to settle runtime activation, pass count and `hmapTex` binding — the three largest Category-B gaps?
3. **COORD:** how should `cdx` be handled — declared out-of-scope with reason, or assigned? No report currently mentions it.
4. **D02/V01:** can the saved-map key byte mapping be validated from a known-key generated `.map` without executing the donor?
5. **D03/D05:** will row-sign flip and global setter clamp ever be lifted above `[U]`, or accepted as permanent declared unknowns?
6. **F01/A03:** will full `w×h` grids for all ~50+ active relief ids be exported, or only the ~30 bit-decoded ones?
7. **F10/COORD:** is the 1,856-mask DLC5 corpus in scope (port currently 0/1,856)? If yes, who converts it; if no, record the explicit out-of-scope reason.
8. **COORD/I13:** pin canonical 240²/320² overlays and fresh baselines; parity must remain UNVERIFIED until a donor frame exists.

---

## 10. Five-line summary (for COORD)

1. **[O] Data formats are the success story:** 710/710 `.pattern`, 680-section plaintext `pattern.lib`, 4,466 terrainmasks, 7 cfg files, 124 tile ids and both shader sources are byte-exactly decoded and cited.
2. **[O] Binary coverage is "complete over discovered functions only":** 18,918/18,918 and 22,384/22,384 exported, but 4,265 (22.54%) / 12,254 (54.7%) garbled, 11/34 terrain anchors present, and the `.bind` section (entropy 7.96) never unpacked.
3. **[O] Three classes are untouched:** `config.exe`/`modman.exe` (one RNG byte cross-check only), `cdx` (zero mentions), and the 49 baked DLC maps (2.877 GiB, deliberately deferred).
4. **[D] The dominant gap is not decode but runtime:** all 972 X03 excerpts and all cfg literals are `;`-prefixed intent; pass count, `hmapTex` binding, native kernels and pattern field semantics remain `[U]` after multiple passes.
5. **[D] "Every single bit" is not achievable under read-only/no-execution rules;** the honest ceiling is labelled data closure + on-demand code reads, and no donor visual parity claim is made.

*End of X27 report. Exactly one repo file written; no donor binary executed or copied; no source, asset, config, test, git or Godot/runner state changed; no donor parity claim.*
