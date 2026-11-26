---
id: TERRAIN-SWARM-2026-11-26 / X14 / spec/00_EVIDENCE_INDEX.md
title: "Definitive evidence index for the donor-first terrain specification (§01–§14)"
agent: "X14 (read-only evidence-index worker)"
date: 2026-11-26
status: LANDED__ONE_FILE_ONLY__READ_ONLY__NO_GODOT_JOB
owner_file: docs/terrain_swarm_2026-11-26/spec/00_EVIDENCE_INDEX.md
labels: [O, D, I, U, "PORT APPROXIMATION"]
evidence_snapshot: "56 landed reports in docs/terrain_swarm_2026-11-26/reports/ at final directory read; spec §01–§14 present (§00 is this file)."
parity_guard: "NO DONOR VISUAL PARITY CLAIM. No donor GPU A/B frame exists; no donor binary was executed by this worker. 'Authoritative' below means best cited evidence for a value/line/count, never visual fidelity."
scope_guard: "Exactly one repo file written (this one). No donor file was opened for writing; no code, asset, config, test, git or runner state touched."
---

# 00 — Evidence index (donor-first terrain spec §01–§14)

## 0. Executive summary

1. **[O]** This index registers every donor `path:line` / byte offset / CODE VA and every Craft Anything evidence id used by the **56 landed reports** read for this task, grouped by the spec section it supports. It is a lookup tool: find a claim in §01–§14, then find its citation here.
2. **[D]** The load-bearing chains are: `TMapTerrainDataTile` (`dmscript.global:2026-2030`) → `.map` 37-byte records (`sub_739d3c`/`sub_73a0b8`, D04); seed LCG (`0x60f64c`) → 11+3 stage reseeds (D02/X03/V01); mask B→height (`generatemap.inc:4-7,567-574`) → three smoothing passes (`:218-245,580-643`) (D03/F04/X03); `.pattern` size closure and true float grid offset `G=8+(w-1)(h-1)` (F01) → three stamp branches in `sub_755f30` (`0x755f30`, D05/X12); tile smoothing (22/118/282/86, ΣProb=174.0168) (`tilesmooth_scripts.cfg`, `smoothtiles.inc`, F03/X08/V20); 124 tile ids and `bmTransparency` (`F05/D08/F06/X17`); ring-indexed mines and ellipses (`dogenerate.inc`, D07/V12/X03); mill fields as 49-node runtime objects (`unit.script:6470-6570`, F07/X22).
3. **[D]** The definitive contradiction register is `reports/V16_contradiction_register.md` (27 clusters: 14 RESOLVED, 9 PRESERVED, 4 OPEN). Later reports (F01, X12, X17, V01, X19, X20/V20, X06, X09, X22, V17) add corrections that are **not** all folded into V16; §4 below records them with pointers.
4. **[U]** No donor visual parity exists. Every implementation consequence is `PORT APPROXIMATION`; tier-3 verdicts remain `UNVERIFIED` (V15 §2).

## 1. Method and conventions

- **Sources read (multiple passes):** CHARTER.md, SWARM_BOARD.md, spec/README.md, spec/01–14, and all reports listed in §7 (coverage manifest). Every numbered report evidence table was read; where a claim appeared in two reports with different line numbers, ids or spellings, both source reports were re-read before inclusion (see §4.9).
- **Labels:** `[O]` observed literal donor byte/line/VA or direct file:line; `[D]` derived arithmetic/control-flow consequence of observed data; `[I]` interpretation with caveat; `[U]` UNVERIFIED; `PORT APPROXIMATION` = port-authored substitute. A label in the "Label" column applies to the **citation**, not to a visual outcome.
- **Paths:** donor paths are relative to `C:\Games\Cossacks 3\` unless marked `PORT` (repo-relative) or `VA` (virtual address in `cossacks.exe`, PE32 SHA-256 `87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c`). `editor.exe` is `68474ddde43f…`. `D1`–`D9` shorthand follows X03 §0: D1 `data/scripts/common.inc/dogenerate.inc`, D2 `…/generatemap.inc`, D3 `…/initmapgen.inc`, D4 `…/texturemap.inc`, D5 `…/smoothtiles.inc`, D6 `…/smoothforestborders.inc`, D7 `…/postprocess.inc`, D8 `data/game/var/generator.cfg`, D9 `data/scripts/lib/misc.script`.
- **Evidence ids:** Craft Anything ids are per-call 64-hex strings. Where a report printed only a prefix (`ev_13f00ea1…`), this index preserves the report's form and points to the report's evidence table; full ids are given where a second report supplied them (e.g. X12 E1 gives `ev_13f00ea1ed28…` in full). **Evidence-id hygiene:** an id is never promoted on one reading; see §4.9.

## 2. Load-bearing quick map (claim → section → primary citation)

| Claim | Section | Primary citation | Label |
|---|---|---|---|
| Per-cell triple `{height:Float, tex:Integer, collision:Integer[4]}` | §01 | `dmscript.global:2026-2030` (A01 E1); `.map` split D04 §4.3 | [O] |
| `.map` 37-byte record = 24 B + 13 B; 4×u8 tile ids + 4×1.0f weights | §01 | `sub_739d3c`/`sub_73a0b8` VA `0x739d3c`/`0x73a0b8`; `bonmis1.map:0xacd4c9` (D04 E1–E3) | [O] |
| Two 32-bit keys; LCG `s=s*0xFC0D+0x3C6EF35F mod 2^32` | §02 | CODE VA `0x60f64c`–`0x60f696`; `0x60f698=2^32` (D02 E3/E4/E7) | [O]/[D] |
| 11 `SetRandomKey` + 3 `SetRandomExtKey64` sites; identity re-seed | §02/§10 | D3:99,146; D1:1100,1161,1177,1213,1538,1616,1772,1909,1927; D2:216,513,774 (X03 E02; V01 EV04–06) | [O] |
| `h = -1.1*fB*(1+3.5*fR) + {2.964/1.31733/-2.964}*fR` | §03 | D2:4-7,559-575 (X03 §5c; D03 E7; F04 §10) | [O] text / runtime [U] |
| Shipped masks: R=G=0 off starts; B all 256 values; water B≥58 | §03 | `terrainmasks/**` full decode (F04 E11/E18; X19 E19/E20) | [O] |
| `.pattern` closure `8+4wh+54(w-1)(h-1)`; `G=8+(w-1)(h-1)` | §04 | all 710 files (F01 E4/E8–E11) | [O]/[D] |
| `pattern.lib` plaintext, 680 sections, 37-field prologue, 39,780 objects | §04 | `pattern.lib:1-39,1171115-1172415` (F02 E1–E3/E18; X05 E1–E4/E13) | [O] |
| Stamp: Min pivot, Max unused, Offset additive; 3 blend paths | §04 | `sub_755f30` `0x7563e8`–`0x7566e9` (D05 E8/E9; X12 E5/E11) | [O] |
| Water levels −1.1 / −0.5 / −0.25 / −0.1; S0/S1/S2 smoothing | §05 | D2:7,688,704; D4:29-31; D2:580-643 (D06 §2; X03 §5d/5e) | [O] text / runtime [U] |
| `FUN_00853ad4` hmapTex = key name, no bind | §05 | VA `0x853ad4`, key `0x853e0c` at `+0x54` (D06 `ev_4ddab2aa…`, `ev_ac379e04…`) | [O]/[D] |
| Shore `sandsea1/5/6`, 8×45°; cliff 6-branch | §05 | D4:474-529,557-611 (D06 §7; F05 E08; X03 §5f) | [O] text / runtime [U] |
| 124 ids/season; faces 35–52/53–70; alphanull 86/110/123 | §06 | `terrain.presets:6-129,138-261`; `tiles.mat:346-359` (F05 E01/E04; F06 §5.1; X06 E01–E07) | [O] |
| `bmTransparency` = GL blend SRC_ALPHA/ONE_MINUS_SRC_ALPHA | §06 | VA `0x4ef991`, `0x88fbb0/0x88fbb7`; table `0x8fb1c4/0x8fb1c8` (D08; X17 E1–E16) | [O]/[D] |
| Tile smoothing 22 chains/118 active/282 active entries/86 names/Σ174.0168; 3 passes | §06/§10 | `tilesmooth_scripts.cfg:1-1863`; `smoothtiles.inc:237` (F03 §6; X08 E01–E12; V20 E01–E13) | [O]/[D] |
| Mines ring→ore→256 tries; bands 14+8R/32+10R/70+12R/22+16R | §07 | D1:525,544-557,595-601,639-645 (D07 E4; V12 §2; X03 §8) | [O] |
| Keep-clear ellipses 5×7 / 12×15 / 22×18 | §07 | D1:407-416,769,947,984 (V01 EV09; V12 §2) | [O] |
| Field = 7×7=49 runtime nodes, size 1.6981 cells, 45° | §08 | `unit.script:6470-6570` (F07 E1; X22 X-E01–E10) | [O] text / runtime [U] |
| cfg constants: 20 global keys, 13 local keys, 64 families/493 pairs | §09 | `globalparams.cfg:1-22`, `localparams.cfg:1-20`, `generator.cfg:67-2366` (F03 §2–§7) | [O] |
| Stage order 1–12 in `DoGenerate` | §10 | D1:1530-2100 (X03 §4; A02 §1) | [O] |
| Lua/DScript `;` prefix ⇒ intent, activation `[U]` | all | every `.inc` line in D1–D7 (X03 §0; D03 §6; V16 O5) | [O]/[U] |

## 3. Evidence tables by spec section

### §01 — World data model (`01_WORLD_DATA_MODEL.md`)

| Evidence id / path:line / VA | What it proves | Reports | Label |
|---|---|---|---|
| `dmscript.global:2026-2030` `TMapTerrainDataTile={height:Float,tex:Integer,collision:Integer[4]}` via `DEC_05_terrain_formats.md:411`, `DTRN_02:191`, `DTRN_01:115` | Authoritative per-cell triple; new module must be SoA | A01 E1 | [O] (field order/stride `[U]` A01 E22) |
| `dmscript.global:80,134-135`; `texturemap.inc:133-134`; `gc_terraindata_collision=4`, `gc_MaxColMapWidth=2*640` | Collision count and 2× grid | A01 E2; V08 E2/E4 | [O] |
| `miscext2.script:19-26`; `dmscript.global:132-133`; `donewgame.inc:42-49` | Grid sizes 256/320/480/640; cap 640; port 160 is debug alias | A01 E3; V08 E1; V12 | [O] |
| `game.gd:521`, `world3d_terrain.gd:1309-1312`; `TERRAIN2_01:136-138` | Flat index `y*W+x`, cell-centre formula | A01 E4/E5; V08 E25 | [O]/PORT APPROX |
| `generatemap.inc:413-480`; `dmscript.global:473-480` | Source-bitmap R=class, G=forest, B=water, A=road (authoring **intent**; shipped pixels contradict, see V16-22) | A01 E6/E7; X19 E11–E16 | [O] text / pixel [U] |
| `texturemap.inc:29-31`; `generatemap.inc:7` | −0.25 water / −0.1 shore / −1.1 basin | A01 E12; D03 E10; D06 §3.1 | [O] |
| `pattern.lib:338482/344362/348758/356906` | Relief props are instantiated 3D objects, not height bumps | A01 E15; A04 E03; V16-13 | [O] |
| `world3d_terrain.gd:926-963,1229-1243` | Dump contract `{map_w,map_h,height,tileblock}` additive extension | A01 E18/E19; P01 E15; A06 E06 | [O] PORT APPROX |
| `cossacks.exe` CODE VA `0x71c78c` `TXMapGenerator` VMT / ctor `0x71d2fc` / dtor `0x71d67c` (`ev_7acd734c…`, `ev_449ce07c…`, `ev_103b50c8…`, `ev_0d83cdaa…`) | RTTI→function anchor; no code xrefs to `X*` strings (unit names inside RTTI records) | D01 E4/E5/E10/E14 | [O]/[D] |
| CODE VA `0x59b6bc` `TXTerrainDataLite` (ctor `0x59b6e8`, dtor `0x59b724`, `ev_39e5b170…`, `ev_cf4fbd82…`, `ev_12fa0455…`) | Compact terrain holder; relevant to `.map` loader | D01 E6/E15/E16; D04 | [O]/[D] |
| `editor.exe` VA `0x5b2ee3` cross-check (`ev_7d708c70…`) | Same class in second binary | D01 E29 | [O] |
| `data\maps\missions\bonmis1.map` file offsets `0x8d8a7d` marker, `mk+31` tag grid, `0xa68ac5` W/H, `grid_off=0xa68acd`, `tile_off=0xacd4c9` (`fnd_30`–`fnd_32`; ev ids `ev_5c678e52…`, `ev_1c68a76f…`, `ev_d4bcdab5…`, `ev_b6b947…`) | On-disk `.map` layout: `(2W)²` u32 tags, `(W+1)²−2` f32 heights, `W*H*37` tile records | D04 §2/§4 | [O]/[U] for shortfall |
| 37-byte record bytes 8–11 four u8 tile ids, 16–31 four `1.0f`, byte 36 forced 0/1 (`bonmis1` 102,400/102,400 invariants) | Donor tile ids available to decoder; port `import_donor_map.py` emits zero placeholder | D04 §4.3; P04 #3 | [O] |
| `dmscript.global:170-175` (`gc_pixels_to_meter=26.6666666`, `gc_meters_to_tile=2`, `gc_pixels_to_tile=53.3333333`, `gc_tiles_to_pixels=0.01875`); `gc_collision_size=0.5` at `:178` | Scale constants; mine radii are **map cells**, not 160 "donor units" | V08 E5/E6/C1; V01 EV15; D07 :182 | [O]/[D] |
| `miscext2.script:945-963`; `misc.script:68-72` | Object placed at cell centre `px+0.5`, origin `−W/2,−H/2` | V08 E7/E8 | [O] |
| `world3d.gd:108,609`; `main.gd:120-124,185,587,1104` | Seam unapplied at read; one `TERRAIN_SCRIPT`; two construction sites | V04 E10; V05 §2; V11 E4; A06 E03/E04 | [O] |
| `game.gd:2151-2166` Y08/Y08b collapse; `world3d_relief.gd:3-8,86-253` | Landed read-only props consumer, no re-apply | V04 E05/E11; P01 E19 | [O] |

### §02 — Seed and RNG (`02_SEED_AND_RNG.md`)

| Evidence id / path:line / VA | What it proves | Reports | Label |
|---|---|---|---|
| `ev_1858bbfd695a985a6714c2bbe0a110faa7af2880b5f5ddd31f25614b5e97a695` | `FUN_00608238` DScript native registry: `RandomExt→0x60f64c`, `GetRandomKey→0x60f69c`, `SetRandomKey→0x60f6a4`, `GetRandomExtKey64→0x60f6bc`, `SetRandomExtKey64→0x60f6dc`, `Random→0x60e47c`; no `RandomInt/RandomFloat` | D02 §2 | [O] |
| `ev_3526b7da4de6db7c011e8e090b9a733576bb2c7cecb03be81e4496318228c169`; `ev_dbb98317…` | Declaration strings in CODE at file `0x209a62/0x209ae5/0x209b31` (VA `0x60a662/0x60a6e5/0x60a731`); data-section tools miss them | D02 §2/§3 anomaly A | [O] |
| `ev_3dfbf17f1bd9757f8dc35812a1b4b8dc2568d6ed0dbd306975d5ce43cdefe173`; `ev_de4333ad…`; `ev_f4c7db72…`; `ev_6283059d…` | LCG multiply helper `0x406718` (`ret 8`), modulo `0x4067b8` with divisor `2^32`, output divisor `4294967296.0` at `0x60f698`; raw x87 tail recovers float32 output | D02 §4.2 | [O]/[D] |
| CODE VA `0x60f64c`–`0x60f696`; multiplier `0xFC0D`, increment `0x3C6EF35F`, state `0x9048d4/d8` | Exact recurrence; high word discarded after first draw | D02 §4.2; spec/02 §2 | [D] |
| `ev_14126307a277fb94960c790fc45a959cc408ae4528b7e43ea27ec8ac8dfaa335` | `donewgame.inc:16,33-37` seed generation + three native setters + map filename from `GetRandomKey` | D02 §2 | [O] |
| `donewgame.inc:16,33-37,42-49` | `mapsize` enum 0→320,1→480,2→640,3→256; three owner instances seeded back-to-back | V01 EV08; X09; D02 §4.4 | [O] |
| `ev_00a36e27…`, `ev_b305f68f…`, `ev_0214d722…`, `ev_c06572cb…`, `ev_16bb0349…`, `ev_d53dcd01…` | Re-seed sites and fixed consumed draws (`foreststype` at D1:5-6, `minesdensity` before `:1616`) | D02 §2/§4.6 | [O] |
| `ev_843ff3a7…`, `ev_9419ae7e…`, `ev_35cf1117…` | Second RNG instance `sub_7281bc` (state `this+0x18/+0x1c`, 15 callers), Delphi `Random()` LCG `0x8088405+1`, scale `2^-32` at `0x8f206c` | D02 §4.5 | [O] |
| D3:99,146; D1:1100,1161,1177,1213,1538,1616,1772,1909,1927; D2:216,513,774 | 11 `SetRandomKey` + 3 `SetRandomExtKey64`, all identity (no `mix64`) | X03 E02/§6 A10; V01 EV04–06; D07 §3.10 | [O] |
| `dogenerate.inc:990-997`; `GetRandom(n)=floor(RandomExt*n)` | Script wrappers; no engine `RandomInt` | D02 §4.5; spec/02 §2 | [O] |

### §03 — Mask → height (`03_MASK_TO_HEIGHT.md`)

| Evidence id / path:line / VA | What it proves | Reports | Label |
|---|---|---|---|
| `ev_0a09d5c4f21b8b28206ffa7e8ed61fb1c07977d4dff9e9aff3f3eaec0b72aa73` | `generator.cfg:2-28` shape paths; live Land = `nowater2` (`land` commented) | D03 E01; F03 §7.1; F04 E2 | [O] |
| `ev_4c82ba26d3eb2970c69e7fe7dd51b8e7b7728bcaf8d73e18c01a393f929ad9f0` | `moddersread.txt:1-10`: `Xpl_*_gauss`, 256²→320² offline gauss | D03 E02; F04 E1 | [O] |
| `generator.cfg:171-191`; D2:139-216 (`ev_6cda8d15…`) | Folder glob, first `i+'pl*.tga'` family, `rndind=floor(RandomExt*count)` | D03 E04; X03 §5a | [O] |
| `ev_2d298dd2ba7b3d3e7a6732a81c55546aa2892996e700e205e402cf8e636318d6` (`generatemap.inc:4-38`) | Height/color constants and R/G/B code table | D03 E06; X03 §5a | [O] |
| `ev_6cda8d150b662b4a87cc54c5a5e849a3c97e0b2749ed1234bc68b9e98b7f42c2` (`D2:552-578,580-644`) | Height formula and three-pass smoothing chain | D03 E07/E09; X03 §5c/5d | [O] text / native kernel [U] |
| `ev_2cd0004c9d109087aea981834a251d7dc2df6d1c04198e448b5943e8ef4311eb` (`D2:218-245`) | `_misc_SmoothTerrainCustom` kernel; effective coefficient land 0.125, coast ≈1.428571 | D03 E08; X03 §5d; spec/05 §2 | [O]/[D] |
| `ev_67d271f20816e529e4166db7fec25c23491b598686f41e9b771537da85823587`; `ev_84858098…`, `ev_200e3149…` | Offline Gaussian `rs=Round(r*2.57+0.5)`, radii 0.00001/0.925, editor-only | D03 E11/E12; X03 §5h | [O] |
| `ev_59cfe17d…`, `ev_e98db75…`, `ev_f40477f…`, `ev_b5b5b3e…` | No `terrainmask`/`_gauss`/TGA-footer/PostProcessSaver strings in EXEs; formula lives in DScript text | D03 E14/E15 | [O]/[D] |
| `cossacks.exe:0x78bcbf` `mov [esp+0x1c],0xbf8ccccd` (`ev_b3163af…`, `ev_dc7ecbd…`) | Compiled `-1.1f` is a nearest-point baseline, **not** the water constant | D03 E16/§2 | [O]/[D] |
| `ev_c99fdb5…`, `ev_783ab62…` (`terrainmasks/land/4pl_mask_land_100_gauss.tga:0x00-0x11`) | Type-10 RLE 24 bpp 320², descriptor 0, `TRUEVISION-XFILE.` footer | D03 E17; F04 E3/E4 | [O] |
| `data/gen/terrainmasks/**` 1,331 files; `.src` 1,279; `.dlc5` 1,856 | Full-corpus decode: R/G zero except 5,125 white starts; B all 256 values; `h=−1.1*B/255` | F04 E11/E18; D03 E18 (sampled at write time) | [O] |
| `data/gen/terrainmasks/mediterranean/4pl_mask_mediterranean_22_gauss.tga:0x12` (SHA `159eb0a7…`), med/22 transect B `0,2,13,49,114,193,251,255` | Measured negative height ramp; water at B≥58 | F04 E4/§6/§7.2; X19 E20 (B=58 off-by-one) | [O]/[D] |
| `ev_461b4b9d7c82d918be8a8d26bc73f30b0caa4de257bf50e85834ece7a43fa34e` (`texturemap.inc:29-31,66-75`) | −0.25/−0.1 classification gated by `gMapMask.b>0` | D03 E10; D06 §2; X03 §5f | [O] |
| `PORT variant3d/scripts/mapgen.gd:25-30,180-238`; `PORT import_donor_masks.py:92-98` | Formula correct at 320²; BUG-1 (`B>58`), BUG-2 (starts as water), BUG-3 (coastal gate always true), BUG-4 (`land` vs `nowater2`) | X19 E5–E10/§2; F04 §9 | [O] port / PORT APPROX |
| `PORT variant3d/assets/terrain/masks/manifest.json:1-29`, 56 PNGs | 56/56 pixel-identical to donor; 4.2 % coverage, zero DLC5 | F04 E12/§9; A03 E7; X19 E4 | [O]/PORT APPROX |

### §04 — Pattern stamping (`04_PATTERN_STAMPING.md`)

| Evidence id / path:line / VA / byte | What it proves | Reports | Label |
|---|---|---|---|
| `pattern.lib:1` byte 0; `:1-39`; `:2-38`; `:1171115-1172415`; full scan | 30,309,138 B plaintext, CRLF, 1,172,417 split lines, **680** sections, 205,571 struct pairs, 37-key prologue (Min +30, Max +31) | F02 E1–E3; X05 E1–E4; X12 | [O] |
| `pattern.lib:6805-6806` bytes 173,669/173,710 (`plt2`); `:33111-33112` bytes 854,933/854,956 (`hil1`); `:366499-366500` bytes 9,458,861/9,458,904 (`g_hil4`); `:549585-549586` bytes 14,196,248/14,196,285 (`k_ravine_1`); `:730045-730046` bytes 18,877,479/18,877,518 (`k_ravine_big_stone_1`) | Prior "byte offsets" are 1-based **line** numbers; all five field byte starts confirmed 5/5 | F02 E5–E9/E10; X05 E7–E11 | [O]/[D] (F02 §5.2 *section span* column wrong 4/5 — X05 A2/V16-16) |
| `pattern.lib:359-387`; `:638257-638286`; full `BaseName` scan | Nested `Objects`/`Waters`/`Decals`; 39,780 object records at 9-space indent, 235 distinct BaseName | F02 E11/E12/E18; X05 E13 (39,783 incl. 3 at 6-space) | [O] |
| `generator.cfg:67-154,69,98,127,156,2314` | 64 family groups / 493 `Pattern`/`Freq`, four duplicate names; mines are **not** a named family | F02 E13/E14; X03 §2b; F03 §7 | [O] |
| `pattern.lib:713410,715244,716910,1170134,1171156,1168944` | `minegold`/`mineiron`/`minecoal` nested props in `mng/mni/mnc` | F02 E15; F08 E7; F07 E14 | [O]; interpretation [I] |
| 12 grid cross-checks: `plt1` G=1972, `plt2` G=2266, `hil1` G=1000, `g_hil4` G=1912, `k_ravine_1` G=2866, `k_ravine_7` G=4832, `k_ravine_big_stone_1` G=8225, `g_mnt_1` G=1562 (all lib min/max bit-exact) | Config extrema reproduce float32 grid min/max | F02 §5.8; X05 E12; D05 E14 | [O]/[D]; **F01 corrects G** (below) |
| `*.pattern` all 710 files: `filesize=8+4wh+54(w-1)(h-1)`; `G=8+(w-1)(h-1)`; regions header 8 B, mask N B, float `4wh`, PRE 4 B, `24N` records, `16N−4` weights, `13N` tail (`ev` n/a — Python bytes) | Exact byte layout; **true** grid offset, 17/29 DPATTERN offsets shifted; 678/680 min/max exact | F01 E1–E11/E21/E22; X05 | [O]/[D] |
| `fb_1.pattern:0x0000,0x0008,0x0040,0x0160`; `hil1.pattern G=968=0x3c8`; `k_ravine_1.pattern G=2798=0x0aee`; `k_ravine_big_stone_1.pattern G=8225=0x2021` | Worked byte offsets; 550,908 records with four `1.0f` | F01 E5/E7/E8–E10/E12/E13 | [O] |
| `pattern.lib:549563/549564/549573-549575`; `:337470-337493`; `HeightFieldScale=0.649999976158142` (`hil1`), `-0.925` brush, `k_ravine_1 Min=-2.963627576828 Max=3.13982009887695` | Stamp flags and float literals (F02 §5.5 omitted 0.65 — V16-17) | V01 EV17; D05 E13/F6; X05 A3 | [O] |
| `sub_755f30` VA `0x755f30`–`0x75c187` (file `0x355330`–`0x35c187`), 25,175 B, 234 blocks, 6,751 instr (`ev_13f00ea1…`; full X12 `ev_13f00ea1ed28ddf24de9e05c19cde14784b86fa896e91e6b1f869eafc8df9bf3`; `ev_e65fb8fd5f384bfa7d7e8268fbe0cbe0d9fcdf67855cdc06403c5588794101f3`) | Stamp anchor; multiple entry points | D05 E1/E7/E8; X12 E1–E4/E15 | [O] |
| `0x7563e8`–`0x7566e9` x87 (`ev_3c1cac6e…`; full X12 `ev_a92017af639d80f9376ed2455cdc2b64fe9ea1204148e91c4241e7405b1caff5`) | Three branches: ReplaceForWater `g*Scale+Offset`; Replace `base_h+g_piv+Offset`; Smooth `h1+(base_h−h0)*TerrainScale+g_piv+Offset` | D05 E9/F4; X12 Claim 4; V01 §4.5 | [O] |
| `fsub [p+0x5c]`, `fmul scale`, `fadd [p+0x5c]` at `0x75660d/610/616`; **zero** `[…+0x60]` operands in 6,751 instr | Min pivot; Max never read in stamp; additive term `Offset +0x64` | D05 E15; X12 Claim 5 (P4/P5) | [O] |
| `sub_75c314` VA `0x75c314`–`0x75c6a1`, 237 instr; offsets Stand `+0x39`, Replace `+0x3a`, ReplaceForWater `+0x3b`, UseRndScale `+0x3c`, Scale `+0x48`, Smooth `+0x4c`, Radius/Factor/Offset `+0x50/+0x54/+0x58`, Min/Max/Offset `+0x5c/+0x60/+0x64` (`ev_44c61fad…`; full X12 `ev_938f5d4f…`, `ev_e2e21ffe…`) | Config-field→struct-offset map, cross-checked in `editor.exe:0x8cc7ae` | D05 E4/E5; X12 E7–E10/E17 | [O]/[D] |
| `sub_755db4` smooth, `/4.0f` at `0x755ee4`; `2.0f` `0x75c1a4`, `0.5f` `0x75c1a8` (`ev_32b5f7f1…`, `ev_dfd5cff8…`, `ev_f3919238…`) | Smooth post-pass = Factor iterations of 4-neighbour mean, divisor hardcoded 4.0 | D05 E10/E11/F5; X12 E11 | [O] |
| DScript registration `0x69a70c`, signature `0x6a3474`, impl `0x6b28d8` (`ev_60b49743…` etc.) | Stamp call chain — **corrected** by X12: `0x6b28d8 → 0x75c228 → sub_755f30`; `0x6b2878`/`0x6b2b60` are siblings | D05 E6/E7; X12 Claim 2 | [O]/[D] |
| `pattern.lib:905523+2/+3` lib 17×20 vs `m_swamp_12_old.pattern:0-7` binary 18×23 (21,860 B) | Genuine donor header contradiction; quarantine, never abort parse | F02 E17; X05 E6; V16-04/O1 | [O] |
| `globalparams.cfg:1-22` no `HeightField*` keys (`ev_38b552b9…`) | Sculpt constants come from `pattern.lib`, not cfg | D05 E12/F6; F03 §3.1 | [O] |

### §05 — Water and shore (`05_WATER_SHORE.md`)

| Evidence id / path:line / VA | What it proves | Reports | Label |
|---|---|---|---|
| `ev_4ddab2aaf1927d0c86177156a5a33b574679cd493b0eb4d053a95f779c2268f6` (`native_function_pseudocode("0x853ad4")`) | `FUN_00853ad4` assigns 30 key names into `+0x04…+0x78`, `hmapTex=+0x54`, f32 `1.99999988` at `+0x7c`; **no texture bind** | D06 §2/P10; X11 §2 | [O]/[D] |
| `ev_ac379e04cf32eaff4d2272cd5f80b49fc6ee7369473f9843c9dd8d4fb17262ce` (`8d4354ba0c3e8500`) | Unique `hmapTex` key reference at VA `0x853bdb`, file `0x452fdb` | D06 §2 | [O] |
| `ev_5a3356c0f5944123f8ea3324f6beccff23ba74502021b8fa003b627ba6a4797b`; `ev_19089834…`, `ev_cf7b42dd…`, `ev_d560126c…`, `ev_5b97f1e7…`, `ev_d94dda94…` | Raw descriptor assignment chain / neighbouring keys `reflectionMap`, `waveMap` | D06 P6/P7 | [O] |
| `ev_642dcfbb94d624415accd6c06796b7c5a1f1f929b5357326f607e2194734b96b`; `ev_a22c66b450f789163e4486ded3e2868a0af6bc6ec024fcc1470f2671229167bc`; `ev_99fde295d8ee5bbd4249cb99e67408701d38aff17b17dc50950445d865ef926e` (`water.dev.frag:1-50,61-105,165-234`) | Coast fade 0.57 / deep 1.07, exponents 170/120, particle 30, colours, mat2, shifts, 9-octave chop, foam peak 0.535, `hmapTex.w` depth test only | D06 §2/§6; X11 §3 | [O] |
| `ev_532af48372ada2a8491dd79f7540a3fa5886e4fe462e6e315aa8db692aa50ec3` (`water.dev.vert:1-30`; **id corrected** after first draft) | Flat passthrough; `gl_TexCoord[1].z=pos.y`; no displacement | D06 §2/§5.2; X11 §2 | [O] |
| `ev_53377109fe6806b0707eb3004f264f6df837db5088dc48f248af0c8859e460cc`; `ev_2c6662253590cd2c759fb60b23c907bcb0113e1da18402b3bb70a9dadebd3cfb` (`water.lib:1-71`; `water.mat:1-106`) | Shipped shader pair pinned; `HeightMapWaves0` block all commented; heightmapwaves0.tga alpha=255 all 65,536 px | D06 §2/P18; X11 §2 | [O] |
| `ev_f4f0e5d056203dc831fc717c44922a9e24250dbb54b14cf2085f92ae7b095cbb` (`generatemap.inc:686-707`) | `cOffsetY=-0.5`, `WaterFieldAdd(...,-0.5)` (runtime `[U]`) | D06 §2/§3.2; X03 §5e | [O] text / [U] runtime |
| `ev_461b4b9d7c82d918be8a8d26bc73f30b0caa4de257bf50e85834ece7a43fa34e` (`texturemap.inc:463-530`) | Shore gate `mask.b>0 ∧ h<−0.25/−0.1`, 8×45° sectors, `sandsea1/5/6` | D06 §2/§7.1; F05 E08 | [O] text |
| `ev_f5d967c54d94326cabda2ebbeab89ea366f1c10702ebe8d14a5db205f6afbde2` (`tilesmooth_scripts.cfg:5-36`) | sandsea5=0.7, sandsea6=0.3, rock9/8/5=0 | D06 §2; F03 §6.4 | [O] |
| `ev_d1d7ea4878ea5801629924fe6babec501a9c35a23490f384d074d7d98dba8776` (`smoothtiles.inc:190-239`); `ev_bcc394eef001bba493521e260211feb0db8cb9cab3cfd27553c097ebca50e059` (`globalparams.cfg:1-22`) | 3 live passes vs cfg 6 — preserved contradiction V16-02 | D06 §2; F03; V20 | [O]/[D] |
| `ev_7bf36259e8e006453e403f0bb9404918e2e706ff3bd25fbb3992c737529f6ab6` (`misc.script:5271-5346`); `ev_e04c40ede2ce7534f6ce3d0638b1859ca1c7cdf2efbf07c28dcd5053501ac895`; `ev_57b8cb760afa6ef7995a869a21d8a6ff292e74934701914caac6367a2c803a57` (`dmscript.global:818-822`) | Bridges = objects + collision tag 10; water-border radius 3; `fordtyp` is formation field, no ford rule | D06 §8; V16-19 | [O]/[U] |
| `cossacks.exe` VA `0x4ef991`/`0x88fb78`/`0x88fbb0`/`0x88fbb7`; table `0x8fb1c4`/`0x8fb1c8` (`ev_45ddf934…`, `ev_57122746…`, `ev_5071f34e…`, `ev_ef6544a2…`, `ev_4d202b29…`, `ev_c4086bd0…`) | `bmTransparency` → `glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA)`; pass count `[U]` | D08 §3.5; X17 E1–E16 | [O]/[D] |

### §06 — Tile ids and atlas (`06_TILE_AND_ATLAS.md`)

| Evidence id / path:line / VA | What it proves | Reports | Label |
|---|---|---|---|
| `ev_e742a78dec8f173dfe6e16a07a5d9c340d8b0a1e9bcb73689b74b783e51852eb` (`terrain.presets:1-263`) | 124 Summer ids `:6-129` + 124 Winter `:138-261`, `DefaultIndex=0` | F05 E01; D08 §1; X06 E01 | [O] |
| `ev_d77d8ef5283af0cb3b19494fac2c02bab05c147fd6a6ea7da9f79202198ca829` (`tiles.lib:1-909`); shell read `tiles.mat:2-4,142-213,346-360` | 245 geometry sections, 253 material sections, 108 distinct DDS paths; `rock1vf`→`rock1.dds`, `alpha0a/b/c`→`grass1.dds`+`alphanull` | F05 E03/E04; D08 §1 | [O] |
| `ev_5290720ccc5de1cd29d83da402582f564ec70e2780554654e3e3e92c2915b53a` (`reftile.lib:1-13`); `ev_27661ad31d177b3e546ccbb7b676091f73fc4ecc823d410d31334f28fe40959f` (`reftile.mat:1-170`) | `tsDouble`/`ttExtended`, offsets 0.1/0.2; face materials `alphavert`, scale 0.125, eye-linear planes; `bmTransparency` | F05 E05/E06; F06 E12; D08 §1 | [O]; arithmetic [U] |
| `ev_9b3ca2f71167b25e760f247f3f10a3f6b2ec519ef238b64cd7a7199e51bcff46` (`texturemap.inc:1-963`) | shore/road/cliff selection constants; **all code lines `;`-commented** | D08 §2; F05 E08 | [O] text / runtime [U] |
| `ev_58552bae6226d2c3de4d5eee847ec05c8a1e5260199faaba3f1514d4442baef6` (`smoothtiles.inc:1-246`); `ev_de3fdab7fe79bd91a5d2e46040012bc8d88e00b56cd684b9991d459a8482616a` (`tilesmooth_scripts.cfg:1-1863`); `ev_6c695743fac333b983c6f7e411176844cb8f54a484ca73517664625cfb22af51` (`tilesmooth.cfg:1-129`) | 3 passes; 22/118/282/86/Σ174.0168; plain 8-section table not loaded by script | D08 §2; F03; X08; V20 | [O]/[D] |
| `ev_e6f506430c087eef585bfab67b46033ec20d078093d04e6719f072242fbb082d` (`loadtextureterrainfrombitmap.inc:1-49`) | Detail pass 320² BMPs, `tex=floor(r*255) div 2`, only where id 0; commented | D08 §2/§3.4 | [O] text / [U] |
| `F06-E1…E18`: `reftile.mat:6,17`; `reftilealpha.mat:17,126,235,30-37`; `hf.pvl.smx3.frag:13-14,17,50`; `hf.pvl.sm.vert:34`; `alpha.bmp` header bytes 0..53 (512×256, 8 bpp, data@1070); `alphavert.bmp` 1024×512 24 bpp; `alphanull.bmp` BITMAPCOREHEADER all-zero; `cossacks.exe:949234` enum | Shader does no mask math; mask is framebuffer alpha; patch geometry 8×4×64²; patch means/constants; port `rgb*a` at shader `:427` is PORT APPROX | F06 §1/§3–§6; D06 §7; X17 | [O]/[U] |
| `PORT tile_index_atlas.manifest.json:13-46`; `build_tile_index_atlas.py:84-88,130-133,148-176,181-208` | 16×8 grid, 124 named / 121 filled / 3 EMPTY, `FACE_BASE_REUSE` 36, `(i%16,i//16)` — all PORT APPROX | F05 E12/E13; D08 §3.1; X06 E01/E02 | [O] port / PORT APPROX |
| X06 temp `audit_data.json`, `fft_all.json`, `corrected_st.json` | 121/121 cell crops exact; `grass_ground3=fliplr(grass_ground1)`; rock anisotropy; three-pass corrected structure tensor | X06 E04/E09–E12 | [O]/[D] port-only |
| `ev_64eb217c56f50781fe8dfcea998a4d1ea16b97b00ec9d1ac9ad380cf95cfdee0` (`hf.pvl.sm.vert:1-50`); `ev_97d7b6610065914af91a1a1c9aeb0d7f944c0a3f24d9cb2c257248eda84100a5` (`FUN_004ec3f0`); `ev_79fc1710f7640c1e8e0e7e177c227c0ba735667ba9f8c4cdc569d11934ab1f9c` | Eye-plane texgen modes 1/2/7; default planes at `cossacks.exe:0x8f4aa4/0x8f4ab4/0x8f4ac4/0x8f4ad4`; per-frame values `[U]` | D08 §1/§3.6; V20 E17/E18 | [O]/[D] |

### §07 — Resources (`07_RESOURCES.md`)

| Evidence id / path:line | What it proves | Reports | Label |
|---|---|---|---|
| `ev_43fb1f88f544a4d5b54cd478b07331afd25fb9fb6edd130d27f4b6087f993041` | 17 `XMapGenerator` literals, first VA `0x71c0a5` / file `0x31b4a5` in CODE; 0 named native functions | D07 §2/§3.1 | [O] |
| `ev_85467957f6fa2ab75623a91a9dc23191980a8c5d8d2f4c5006aed8ed37a8251a`, `ev_f4a62967ae4974643fee198e39735e904d9c8dc54c302c75462af363e9db13f8` | `sub_71c0b4` pseudo-C rejected: `0x71c0a5` is ASCII lifted as `pop eax` | D07 P4a; V12 §0 | [O]/[D] |
| `ev_a33507f945c695b4938dfc77d81d382482d54de32bb737f4172e9f2b58e780b4` (`D1:522-721`) | `SetupMines`: ring→ore→256 angle attempts; `trycount=256`, rounds 3/4/5 | D07 E4; X03 §8; V12 §2 | [O] |
| D1:525,528-535,537,544-557,559-654,658-697,704-713 | Full mine radius matrix, version gates, corner relocation; **ring radii shared by 3 ores** (per-ore belief refuted) | X03 §8; V12 §2; V16-07 | [O] text |
| D1:407-416,769,947,984; `serial.script:27 gDataVersion:=92`; `initmapgen.inc:57,72` | Ellipses 5×7/12×15/22×18 centred `(x,y+2)`; shipped version band `v>=80`, `v>=90` | V01 EV03/EV09; V12 §2 | [O] |
| `donewgame.inc:42-49` | `mapsize>2` = enum 3 = **256-cell tiny** map; default 320/480/640 use `mapsize<=2` rows | V01 EV08/P4; V12 C-V3 | [O]; D07 §3.4 example superseded |
| `ev_7733cb431b61599d4c73794296090e9ecad0cff6205c43d04501979fb352109a`, `ev_5200df4fe71ca6a611639834b9c14c2c1de6f894c6e22fdc03f7b51af8700f06` (`D1:722-1081`) | `SetupStartingResources`: 6 stone/forest placements, no food rects | D07 E3; V12 C-V4; X03 §9 | [O] |
| `ev_71484fdd28d67bc4032b55c39c5b162ee1a029fd343d91b772b262dd80c285f4`, `ev_32fd9062bfd74afda5f78f6234f406bb32c71d7240d92c9a1db9ce031b7df7cb`, `ev_5826ad276cc90d2a8b5d6b65e21051141fc0c56556fcaebe80dbf58b7f4d0e3e` (`misc.script:3384,3516,3681`) | Two-phase occupancy checker; `needed=floor(W*H*freq)`, `trycount=floor(256*320²/(W*H))` | D07 §2/§3.7; X03 §3.13 | [O] |
| `dmscript.global:55-59,57-58`; D1:1361-1428,2062-2068 | `FillOwnerMap` wavefront BFS on 160×160, late, terrain-agnostic | D07 §3.9; V12 §2; X03 §11 | [O] |
| `res.script:23-32`; `initial.inc:49-51,74-103`; `dmscript.global:794-797` | Ore ids 4/5/6, `hp:=0`; no finite deposit amount | D07 §3.8; V12 C-V9; V15 V-E12 | [U] for capacity |
| X09 E1–E24: `startingsettings.cfg:1-3424` (SHA `17d4aedd…111f`), `SS:2-12,14-68,87-180`, `DG:230-396,342-359,1601-1607,1914-1921` | 19 presets, 61 ASCII masks, 276 legend entries; mask = relative unit/building stamp centred on start, not terrain mask; r=5/1 pre-stamp circles | X09 §0/§2 | [O]/[U] runtime |
| F08 E1–E19: `generator.cfg:69-153,802-908`, `pattern.lib:713285,715147,716813,713323-713633`, `unit.script`, `envscales.cfg:15-37` | Forest/stone/mine object lists in `pattern.lib`, ≠ binary 24-byte tail; `Freq` roulette ×0.2 floor 1e-4 | F08 §2 | [O] |
| V08 C1 (`miscext2.script:19-26`, `dogenerate.inc:402-405,437,658-697`, `misc.script:3384-3405`) | Mine bands are map cells; "1 donor unit = 2 cells" refuted | V08 E1/E14–E16/§3; V01 EV15 | [O]/[D] |

### §08 — Fields and props (`08_FIELDS_AND_PROPS.md`)

| Evidence id / path:line | What it proves | Reports | Label |
|---|---|---|---|
| A04 E01–E28: `generatemap.inc:4-7,567-574`; `pattern.lib:337491-337492,338480-338507`; `actors/env/terrainmesh*.osm`; `generator.cfg:446-754,1290-1533`; `decals.lib:37-43`; `misc.script:4284-4306`; `unit.script:6475-6548`; `dmscript.global:206` | Three independent channels (height windows / object props / tile art); per-class donor source and port state; no asset named "quarry" | A04 §2/§3 | [O]/[I] |
| `ev` n/a — `PORT assets/terrain/mountain_props.json:1-17` (SHA `f7b421b1…dc1c0` of `pattern.lib`), `CREDITS.md:119-124`; `world3d_relief.gd:86-253` | 112 `terrainmeshN` records converted; MultiMesh consumer exists but QA atom never run | A03 E4/E5; A04 E07–E10; V13 S1 | [O]/[U] |
| X22 X-E01–X-E25: `unit.script:6468-6570,1691-1693`; `dmscript.global:178,170-173`; `writenewp.inc:23-29`; `readnewp.inc:41-47`; `field.prop:30-38,139-150`; `decals.lib:38-43` | 7×7=49 nodes, `size=1.6981`, 45°, `size2=√2·size`, 25 half-cell collision samples, rad 4.58487/1.52829, cost 5 gold; runtime decal 45/225 & 1.3× | F07 E1–E22; X22 §2/§3 | [O] text / [U] runtime |
| `PORT game.gd:2722-2767`; `world3d_entities.gd:311-319` | Port sow step half donor, clash radius near-correct in metres, no collision/ore check, no decal call — PORT APPROX | F07 §4.5; X22 X-E22/E23 | [O] port |
| V-E01…V-E20 (V15 §1) | Three-tier verdict vocabulary; no donor still reference for mountains/sea/rivers/swamps/iron-coal mines | V15; X07 §2 | [O]/[D]/[U] |
| X07 12 stills in `C:\Users\Maxym.Oboyshev\Downloads\c3\` (e.g. `cossacks-3-v1-498085.jpg`, `523480776.jpg`, `large_1.webp`) | Third-party, unknown build/camera; direction-of-movement only; "highlands" filename false positive | X07 §2/§3; V15 V-E01 | [O] still / [U] parity |

### §09 — Editor parameters and cfg (`09_EDITOR_PARAMETERS.md`)

| Evidence id / path:line / SHA | What it proves | Reports | Label |
|---|---|---|---|
| `globalparams.cfg` 537 B / 22 lines SHA `15a8dc64a91dc4e72f45a997d6f6a5b770b2b77786518f48a75e04ab95727a51`; complete literal `:1-22` (Size 512, Sharpness 0.6, TileChangeFactor 0.3, FrequencyFactor 0.000013, CellsResolution 1, FailStandCount 16, DefaultMapSize 256, TileSmoothPasses 6, TileSmoothListFileName `tilesmooth.cfg`, PatternPlayerName `pattern`, AddCastles False, CastlePlateauFactor 5) | All cfg literals; no seed/water/mine constants | F03 §2/§3.1/§4; V01 | [O] |
| `localparams.cfg` 508 B SHA `8d174830…`; `:3-16` 13 keys | Editor local record; tiny heights not skirmish scale | F03 §3.2/§5.1 | [O] |
| `mapcover.cfg` 1,196 B SHA `ff0a7bf4…`; `:1-40` | One zone/height zone/tile, all four seasonal names empty | F03 §3.3/§5.2 | [O] |
| `tilesmooth.cfg` 2,796 B SHA `1753533e…`; `:1-129` 8 sections/30 names; `tilesmooth_scripts.cfg` 64,017 B SHA `b82c8884…a531b433`; 22/130/310/86/Σ174.0168 | Weighted vs plain table contradiction (V16-03) | F03 §2/§6; X08 E01; V20 E12/E13 | [O] |
| `generator.cfg` 70,074 B SHA `f8a5cd2e…`; `:2-66` 6+9 masks; `:69-2314` 64 families/493 pairs; `startingsettings.cfg` 116,920 B SHA `17d4aedd…` | Family/mask/starter inventory | F03 §2/§7/§8; X09 | [O] |
| `ev_c48723aea4991ea0a5f0b4096aa4a76ecd244e41680a530132ff7aa356d47521` (104 `.rsrc` strings, `references: []`); `ev_447f029ed1d516fbf1cec297ee7687352488798fed7afa1a974514e7f030a815` (22,384 functions) | Strings alone are not anchors; VMT/DFM tables are | D09 §1/§2 | [O] |
| `editor.exe` `0x33dfb8` `TFormMapGen` VMT; method `ButtonGenerateClick=0x7400d0`, `ButtonApplyGlobalParamsClick=0x73fe50`; orchestrator VA `0x87b7ec` (file `0x47abec`); flag map `+0x90..+0x9b` | 12-stage boolean gate map and cfg-control mapping | D09 §3–§5; `ev_6b832a6a…`, `ev_0e2fb698…`, `ev_0f4e51a0…` | [O]/[D] |
| F09 E01–E21: `editor.aix:1-4,710,722,841,853`; `editor.inc/generatemap.inc:2-9`; `generatemapfrombitmap.inc:4-105,142-364`; `generatewaterfields.inc:4-113`; `scaleplateauterrain.inc:4-43`; `textureterrain.inc:17-342` | Editor states distinct from skirmish; editor-only debug and brush constants | F09 §1 | [O] text / runtime [U] |
| `dmscript.global:818-822` (`gc_WaterBorderSize=3`), `:83-92` tag constants | Collision tag vocabulary used by editor and generator | D06 §8; V08 E4 | [O] |

### §10 — Stage order (`10_STAGE_ORDER.md`)

| Evidence id / path:line | What it proves | Reports | Label |
|---|---|---|---|
| X03 E01–E21 (D1:1530-2100 verbatim) | Canonical 12-call order: tiled patterns → reseed → settings → GenerateMap → shore prefill → starts/keep-clear → relief → forest/stone/decor → units/scale → owner BFS → borders → finalize | X03 §3/§4; A02 §1 | [O] |
| D1:1335 `cSize=25`, inclusive loops; `round(x*25+12−W/2−1)` | Tiled-pattern grid | X03 §3 Stage 3; A02 | [O] |
| D2:770-798 (`SetRandomExtKey64:774` → `TextureMap:776` → `SmoothTiles:786` → detail:795); `//MapGeneratorSmoothTiles` dead at `:784` | Texture→tile-smooth→detail sub-order | X03 §5f; D08 §3.2; V20 E10 | [O] |
| D1:1625-1649 relieftype 0–4 triples; D1:1688-1693,1713-1739,1757-1765 pass rates; D1:1984-1985 winter leaftree delete; D1:1998 scale dead-band 0.05; D6:100-113,151 `fb_*`; D1:2075-2084 season tables | Per-stage numeric constants verbatim | X03 §3/§4; V01 EV11; F08 | [O] |
| D1:522-717 SetupMines; D1:720-980 SetupStartingResources; D1:1370-1428 FillOwnerMap; D1:2062-2068 late pass | Resource stage order and RNG boundaries | X03 §3 Stages 7/8/11; D07 §3.10; V12 | [O] |
| X03 §6 A1–A13 (D4:222 `try0:=1 to 1`; D6:151 `break`; D1:1735 vs :1812 lake; D2:818 editor-only; D1:2006 vs D2:984-998 scale; D8 7,013 lines / plain_medium 24/67.6875; D2:565 `fr/fb` start skip; D4:214 TODO; D5:124-125 no-op; D4:564 asymmetric bound) | 13 anomalies with two-pass verdicts; implement quoted text, not A02 pseudo-code | X03 §6; V16-09a…09f | [O]/[D] |
| `serial.script:27`; `initmapgen.inc:57,72`; V01 §3 | No donor key derivation; A02 `mix64` diverges | V01 EV03/EV04; spec/02 §5 | [O] |
| A02 §2 E01–E28 (`TERRAIN_DONOR_PIPELINE.md` C1–C28) | Original design evidence set, now partly superseded by landed D/F/X reports | A02 §2; V17 E8 | [O]/[U] |

### §11 — Asset conversion (`11_ASSET_CONVERSION.md`)

| Evidence id / PORT path:line | What it proves | Reports | Label |
|---|---|---|---|
| A03 E1–E18: `donor_gen.py:44-45,74-85,97-129`; `export_donor_patterns.py:27-38,83-103,139-158`; `donor_patterns.json:1` (`donor_units=160`); `CREDITS.md:119-124,125-130`; `mountain_props.json:1-17`; `import_donor_masks.py:1-9,31-36,78-104`; `build_tile_index_atlas.py:84-100,136-178,181-221,224-265`; `build_winter_atlas.py:20-39`; `pack_tile_atlas_split.py:11-31,58-65,249-265`; `tile_atlas_loader.gd:62-77,99-118,174-200`; `B02_atlas_impl.md:63-75,168-179` | Conversion routes already on disk; invariants (one-way, disjoint `terrain_new/**`, `null`+UNVERIFIED, `visual_parity_claim:false`, dry-run default) | A03 §1/§2; spec/11 | [O] port / PORT APPROX |
| P04 #1–#17 (`parse_terrain.py:1-12`; `extract_map.py:56-111`; `import_donor_map.py:113-174,186-209,450,462-465`; `donor_gen.py:25-27,62-71,74-85,191`; `export_donor_patterns.py:139-147`; `build_tile_index_atlas.py:34-40,113-127`; `convert_models.py:48-158,591-596`; `scan_map.py:478-493`) | Tool disposition: keep readers/cross-checks, retire synthesis, zero tileblock and blob noise | P04 §2–§5; spec/11 §11.7 | [O] port |
| F01 E4/E11; X05 temp `patternlib_index.json`; V11 N1–N7 | Now-decodable `.pattern` grid + `pattern.lib` index; canonical new tool names | F01/X05/V11 | [O]/[D] |
| `variant3d/assets/terrain_new/**` output contract; atlas `--cell 128` (2048×1024); 179,912,941 B shipped atlas uncommitted/LFS | Deterministic compiler target | A03 §2.2; P04 #8 | [D]/PORT APPROX |

### §12 — QA and integration (`12_QA_AND_INTEGRATION.md`)

| Evidence id / PORT path:line | What it proves | Reports | Label |
|---|---|---|---|
| A05 E01–E18: `main.gd:751-810`; `full_map_shot.py:191-227`; `game.gd:52,749,1267-1274`; `donor_gen.py:49-59`; `terrain_ab_metric.py`; `compare_shots.py`; `config.json:24-31,35-77`; `assert_clean.py:13-18,33-42`; `C01_metric_tool.md`; `A11_reference_metrics.md`; `G21_acceptance_checklist.md` | Five dump streams, SHA-256 identity at 64²/240²/320², advisory structural gates, admissible visual protocol | A05 §1–§4; spec/12 §12.6 | [O]/[D] |
| P03 E01–E22: `godot_runner.py:47-53,488-509,615-652`; `assert_clean.py:33-42,262-288`; `main.gd:3-5,1255-1371`; `t_render_mode.gd:5,44-126`; `t_map_variety.gd:15-17,184-259`; `scan_map.py:446-510`; `terrain3d_shot.py:25-30`; `full_map_shot.py:87-94,133-181`; `config.json` 240²/seed 20261113 | Gate CLI inventory; stale green JSONs; mixed `app/`/`variant3d/` path aperture | P03 §1–§4; V06 | [O] |
| V06 E01–E20: `selftest.json:2,12`, `uitest.json:2,3`, five result JSONs with 2026-11-25 mtimes; `.godot_queue/counter=607`; `status.json` 41 leak entries/3 unacked 575,582,585; `godot_runner.py ack :586-611`; `assert_clean.py:154-156` | Green-but-stale; remediation = ack with reasons, regenerate fresh with unique ids | V06 §2–§4; V16-21 | [O]/[D] |
| V04 §1 E01–E17 & §2 SHA table: HEAD `e234ac9b`; clean `variant3d/`/`app/`; `world3d.gd` `44EE96C0…`, `main.gd` `3859B605…`, `config.gd` `160F08C0…`, `tests/manifest.json` `408F4C83…` (40 tests) | Stale uncommitted-edit premise refuted; exact rollback hashes | V04; V11 E1–E4; V16-10/23/24 | [O] |
| V05 §2/§4; A06 E01–E16 (`main.gd:120-124,185-186,586-589,1103-1106`; `world3d.gd:108-116,609,674-692`) | Authoritative two-file seam, default legacy, no legacy edits | V05; A06; spec/12 §12.1; V16-01 | [D] |
| V11 E1–E15, EDIT E1–E4, NEW N1–N22 | One owner per file; `I11-SEAM`, `I11-COMPOSER`, `I12`, `I13`; `COORD-I11` suffix; `terrain_new/**` root | V11; V16-18; spec/12 §12.2 | [D]/PORT APPROX |
| V13 E01–E13: `t_relief_props_qa.gd:30,284-311,785-787`; `mountain_props.json:11-18`; `t_sheet_load.gd:8-12`; `terrain3d_shot.py:25-26,120`; PIL cp313 vs system Pillow 12.1.1 | Three stale-reference groups; not non-negotiable gates; no threshold lowering | V13 §1–§4 | [O] |
| V15 V-E01…V-E20; X07 12 stills | Three-tier verdicts; `parity.status=UNVERIFIED`; tier 2 never implies tier 1 | V15 §1–§2; spec/12 §12.6 | [O]/[U] |

### §13 — Prior-wave memory (`13_PRIOR_WAVE_MEMORY.md`)

| Evidence id / path:line | What it proves | Reports | Label |
|---|---|---|---|
| P06 §2 (12 ranked rejected approaches): `terrain=5` gradient Y01/Y02/L03; `HEIGHT_SCALE` fudge; S-25-09 dither; tile-art relief; forced cliff art; H03/H05/H04 heightmap-as-albedo refutations | Root-cause chain for maze/flat relief/shore gaps | P06 §1–§2; spec/13 §2; V16-15 | [O]/[D] |
| P06 §5.1 "3 uncommitted source edits" | Stale: V04/V05/V11/V16-10 supersede (committed in `e234ac9b`) | P06; V04; V16-10 | [O] stale |
| P06 28 open items V-01…V-28; `V03_open_items_resolution.md` absent at V17 read | V17 marks orphan; COORD must retire or assign | P06; V17 §4 | [U] |
| V09 E (3-pass read): `app/scripts/game.gd:1682,1689,1095-1096`; `variant3d/scripts/game.gd:2097,2134,1272-1273` | 2D order `generatemap.inc:776→786→795` vs flipped 3D; `_noise2` dither in **both** trees; fresh module uses 2D order | V09 §0/§5; V16-11 | [O]/[D] |
| `actors.lib:1200-1213`; `world3d_relief.gd:3-8,86-253` | 112 relief-prop records; silhouette from objects, not height bump | P06; A04; V16-13 | [O] |

### §14 — Current pipeline (`14_CURRENT_PIPELINE.md`)

| Evidence id / PORT path:line | What it proves | Reports | Label |
|---|---|---|---|
| P01 E01–E20: `config.json:75-77,107`; `config.gd:513-515,535-538`; `data.gd:35,229-235`; `main.gd:179-190,563-578,791-803`; `game.gd:361-370,918-925,946-1148,1254-1310,2015-2170`; `mapgen.gd:34-61,145-238`; `pattern_gen.gd:76-760`; `world3d.gd:604-661`; `world3d_terrain.gd:926-963,1220-1464`; `terrain_tileindex.gdshader:43,274-476` | Legacy stage trace, five RNG streams, dump/mesh boundary; divergence labels | P01 §2/§3; spec/14 | [O] port |
| P01 E08 `game.gd:149,264-266`; P01 E11 `:1278-1310` | `gen_rng` reseeds inert; collision pass writes `blocked` only (no `terrain=5`) | P01; V16-08 | [O] |
| P01 E14 `:604-661`; V05 §4 | P01 one-file vs A06 two-file seam reconciled; P01 owns *where*, A06 *how* | P01; V05; V16-01 | [D] |
| P02 `t_relief_props_qa.gd:30`; `mountain_props.json` live | Asset inventory gap (same as V13 S1) | P02; V13 | [O] |
| P05 E23; V09 §5 | Two donor-authored forest-interior lists preserved behind flagged switch | P05; V09; V16 O12 | [O]/[D] |

## 4. Duplicate, contradiction and correction notes

### 4.1 V16 register — authoritative map (all rows point here)

`reports/V16_contradiction_register.md` §2 is the definitive register. Short index: V16-01 seam RESOLVED; V16-02 (`TileSmoothPasses=6` vs 3) PRESERVED; V16-03 (`tilesmooth.cfg` vs `tilesmooth_scripts.cfg`) PRESERVED; V16-04 (`m_swamp_12_old`) PRESERVED/O1 OPEN; V16-05 (`alphanull` 86/110/123 vs port 8 zeros) PRESERVED; V16-06 water levels RESOLVED; V16-07 ring-vs-ore RESOLVED; V16-08 11+3 reseeds RESOLVED/O8; V16-09a–09f A1–A7 RESOLVED; V16-10 git state RESOLVED; V16-11 2D/3D order RESOLVED with preserved sub-item; V16-12 stills-vs-data PRESERVED; V16-13 mountain grids RESOLVED; V16-14 A05 S7 advisory RESOLVED; V16-15 clamp refuted RESOLVED; V16-16 F02 byte spans RESOLVED; V16-17 `hil1 0.65` RESOLVED; V16-18 ownership RESOLVED/O6/O7; V16-19 DLC5 rivers OPEN/O2; V16-20 240² vs 320² OPEN/O3; V16-21 stale gate JSONs RESOLVED/O4; V16-22 mask R channel OPEN/O5; V16-23 V04 landing RESOLVED; V16-24 hash drift RESOLVED; V16-25 water chain PRESERVED/O11; V16-26 unowned script OPEN; V16-27 I07 two files OPEN. Its OPEN register O1–O14 carries named owners.

### 4.2 Post-V16 corrections (re-read source reports before adopting)

| # | Conflict / transcription | Authoritative reading | Source |
|---|---|---|---|
| P1 | D05 call chain `StandPattern→0x6b28d8→0x6b2878→0x6b2b60→sub_755f30` | **X12 rejects the intermediates**: `0x6b28d8→FUN_0075c228(0x75c228)→sub_755f30 @0x75c240`; `0x6b2878`/`0x6b2b60` are sibling natives calling the stamp directly. Stamp anchor/formulas unaffected. | X12 Claim 2; spec/04 §6 still carries old chain |
| P2 | `smouthes`/`alpha` factor status: F06 U-F06-2 says GL blend factors UNVERIFIED | **D08 + X17 resolve factors** to SRC_ALPHA/ONE_MINUS_SRC_ALPHA at VA `0x4ef991`/`0x88fbb0`; only **pass count** stays `[U] CONFIRMED_UNVERIFIED`. spec/06 §5 and spec/05 §7 still use the old shorthand. | D08 §3.5; X17 E1–E16/§3.3 |
| P3 | F02 §5.8 `G` values (`hil1` 1000, `k_ravine_1` 2866, `k_ravine_big_stone_1` 8225) used as true float-plane starts | **F01** proves true `G=8+(w−1)(h−1)` (`hil1` 968, `k_ravine_1` 2798, `k_ravine_big_stone_1` 8225 unchanged); 17/29 DPATTERN offsets shifted. F02/X05 values reproduce min/max from a shifted window. | F01 E8–E10/E21; V16-15/U5 |
| P4 | `gRecordGeneratorVersion` `[U]` (X03 §8 U7; D07 U4) | **V01 EV03** `serial.script:27 gDataVersion:=92`, `initmapgen.inc:57,72` ⇒ shipping `v>=80`, corner `v>=90`, DLC5 `v>=91`. | V01 §3/P3; D07 §6 U4 superseded |
| P5 | `mapsize>2` labelled "large"/"tiny" inconsistently (D07 §3.4 example uses 320) | **V01 P4/EV08** `donewgame.inc:46` ⇒ enum 3 = 256-cell tiny map; default 320/480/640 use `mapsize<=2` rows. V12 C-V3 refuses the semantic label; keep literal gate. | V01 §4.3; V12 C-V3; V08 |
| P6 | D08 §3.1 table puts sand ids at 17–25 and rock at 26–34 | **F05 §3, X06 E05, X03 E18** agree: rock base **17–25**, sand base **26–34**, faces 35–70. D08 table is a row-label swap. | F05 E01/§3; X06 E05; V16-05 |
| P7 | D07 shore citation `:1557-1564`; `var dst` declared `:536` | **V12 C-V1/C-V2**: shore loop at `dogenerate.inc:1568-1581` (`cWaterShoreHeight` at `:1576`); `var dst` at `:537` **inside** ring loop. D07 conclusion (no `i=2`) stands. | V12 §1; X03 §6 |
| P8 | D07 "ring 4/5 skipped"; D07 U4 unknown version; V01/V12 corrections | `continue` consumes innermost-k name draw (V12 C-V7); no food rects (C-V4); zero-init `dst` policy (C-V5). | V12 §1/§4; V01 §1 item 6 |
| P9 | `tilesmooth_scripts.cfg` counts 282 vs 310 vs 320 | **V20 §3.2**: same object at three granularities — 310 `TileName` lines (282 active/28 commented), 320 `Prob` tokens (282 active + 38 dead alternatives). 22/130/118/86/Σ174.0168 unchanged. | V20 E12; F03 §6; X08 §4 |
| P10 | X08 chain first-line C00=3 vs F03 C00=4 | Same chain: X08 cites `[*]` record, F03 cites `SmoothTiles : struct.begin` one line lower. No conflict. | X08 §4; F03 §6.3 |
| P11 | F08 `pattern.lib` "1,172,416 lines" vs F02/X05 "1,172,417 split lines / 1,172,416 CRLF" | Terminator convention: split count vs CRLF-pair count. Cite F02/X05 form. | F08 §0; F02 E2; X05 E2 |
| P12 | X05 39,783 `BaseName` lines vs F02 39,780 | F02 counts 9-space object records; X05 adds 3 at 6-space indent. Both true. | X05 E13; F02 E18 |
| P13 | X19 F04 "BUG-1 B>58" vs F04 "B≥58" | `B>58` means integer B≥59; `h<−0.25` ⇔ B≥58 (`-1.1*58/255=-0.250196`). Med/22 mismatch 22 px. | X19 E5/E20; F04 §6 |
| P14 | D03 U4 "full R/G census still running" | **F04** completed the 1,331/1,279/1,856 full decode; D03's sampled finding is superseded. | D03 §7; F04 E11/E18; V16-22/O5 |
| P15 | V17 §4 lists X12/X09/X18/X19/V03 as orphans | At V17 read they were absent; at this index final read X12, X09, X19 and F01/X17/V20/V13/V16/V01 had landed; X18 and V03 remain absent — retire or assign. | V17 §4; directory glob |
| P16 | `DONOR_UNITS=160` "1 unit = 2 cells" (A03 E3/A05 E6/port tools) | **V08 C1** three-pass resolution: radii are map cells; "160 units" is an abandoned port baseline. | V08 E23/E29/E30; V01 EV15 |

### 4.3 Evidence-id transcription hygiene (multiple passes performed)

- **D01 E17** first draft mistyped `ev_644cd89c…` twice; re-queried with `native_function_pseudocode` and corrected. D01 §1 correction log retained; no conclusion depends on discarded spelling.
- **D06 `water.dev.vert`** evidence id mistyped in §2 first draft; replaced with fresh verbatim `ev_532af48372ada2a8491dd79f7540a3fa5886e4fe462e6e315aa8db692aa50ec3`. Donor path `:1-30` remains primary.
- **X12 E15** supplies the full id `ev_e65fb8fd5f384bfa7d7e8268fbe0cbe0d9fcdf67855cdc06403c5588794101f3` for D05's abbreviated `ev_e65fb8fd…`; X12 E1 supplies full `ev_13f00ea1…`; X12 E5 full `ev_a92017a…`. Verified by re-reading D05 §1 and X12 §1.
- **X17 E40/E42** re-run D08's `ev_5071f34e…` and `ev_b2304697…` under pinned `document:` after D08 recorded a shared-target race; both retained. D08 §2 note and X17 §2 agree.
- **D08** discarded one early `native_name_xrefs_list(glBlendFunc)` result from the wrong target; X17 independently re-derived `ev_c4086bd0…`.
- **V16-16** F02 §5.2 byte spans for `hil1`/`g_hil4`/`k_ravine_1`/`k_ravine_big_stone_1` were copied from family ends; correct section ends 895,878 / 9,534,168 / 14,346,835 / 19,157,731. Field byte starts 5/5 correct.
- **Common prefix rule:** ids printed as `ev_XXXXXXXX…` in a report must be looked up in that report's evidence table before use as a citation; this index does not invent suffix characters.

## 5. Consolidated UNVERIFIED register (do not promote)

| # | Item | Status / owner | Settled by |
|---|---|---|---|
| U1 | Donor visual parity (all classes) | `[U]` no GPU A/B frame; owner/COORD | Only real donor GPU capture |
| U2 | Row-sign flip / file-row→centred world y | `[U]` D05 U1; X12 U1; V16 O10 | D05/D03 follow-up or replay fixture |
| U3 | Global height-setter clamp `sub_7551a8→sub_0059b934` | `[U]` D05 R4; X12 U2; V16 O10 | D05 follow-up |
| U4 | `HeightFieldMax` consumers outside stamp | `[U]` D05 Q3; X12 Claim 5 limit | Editor/binary lane |
| U5 | `PatternMaskStand`/`PatternMaskReverceStand` → occupancy byte | `[U]` D05 U6; X12 U6 | Binary pass |
| U6 | `SmoothTerrain` native kernel power/lerp | `[U]` D1:591 only call site; V01 U6/R1 | DScript native handler decode |
| U7 | `hmapTex` actual texture/FBO, sampler units, plane Y | `[U]` D06 §11 items 1/5; X11; V16 O11 | GL trace / `.bind` decode |
| U8 | `bmTransparency` composite pass count / draw order | `[U]` CONFIRMED_UNVERIFIED after D08 6 passes + X17 6 passes | GPU trace / mesh builder |
| U9 | `tiaAlphaFromIntensity` formula; tile→alpha patch selector | `[U]` F06 U-F06-3/4/7; X17 U-X17-3/4 | Engine decode |
| U10 | Runtime activity of all `;`-prefixed `.inc` lines | `[U]` across D1–D7, F03 F15, X08 U1, V20 §2 | Donor runtime trace (forbidden this wave) |
| U11 | `R1–R6` relief numeric parameters | `[U]` V01 U12/P8; GUIDE4 names only | Editor manual / binary |
| U12 | Start-spacing 0.7 cm / 1.5–2 cm | `[U]` V01 U10; modder changelog only | Saved-record analysis |
| U13 | `GenerateMapRandKey` body / saved-map key bytes / RNG instance classes | `[U]` D02 U1–U3/U5/U6; V16 O8 | Binary lane |
| U14 | Full `w×h` grids for all ~50+ active relief ids | `[U]` V01 U13/R6; F01 678/680 min/max but only 30 grids decoded bit-exactly | F01/A03 recipe |
| U15 | `m_swamp_12_old` header policy | `[U]` OPEN V16 O1 | COORD + I02/I03: quarantine, binary 18×23 authority |
| U16 | DLC5 rivers/lakes scope; ford rule | `[U]` OPEN V16 O2/V16-19 | COORD + F10 |
| U17 | Canonical capture size 240² vs 320² | `[U]` OPEN V16 O3 | COORD/I13: pin both overlays |
| U18 | Mask R channel semantics (`ENGINE/UNVERIFIED`) | `[U]` OPEN V16 O5; F04 measured zero, script intent differs | F04 landed; COORD align spec text |
| U19 | `terrain_new_assets.gd` owner; I07 two-file assignment | `[U]` OPEN V16 O6/O7 | COORD |
| U20 | Unowned X18/V03 tickets | `[U]` V17 §4 | COORD retire/assign |
| U21 | All gate JSONs fresh for today's tree | `[U]` V06/P03; green JSONs dated 2026-11-25 | COORD runner jobs with unique ids |
| U22 | QA visual outcome / "closer to donor" | `[U]` V15 tier 3; X07 stills inadmissible for parity | Owner A/B verdict |

## 6. Open questions (routing)

1. **COORD:** fold post-V16 corrections P1–P16 into the affected spec sections (§02 §1, §04 §6, §05 §2/§7, §06 §5, §07 §1/§3, §10 §2/§4, §13). No worker may edit those files.
2. **COORD/I02/I03:** adopt V16 O1 quarantine policy for `m_swamp_12_old`; use F01 `G=8+(w−1)(h−1)` in `decode_donor_pattern.py`; emit `UNVERIFIED` for record semantics.
3. **COORD/I04:** implement mask decoder from F04/X19 recipe; fix BUG-1/2/3/4 only in the **new** tool; raw R stored unchanged with `ENGINE/UNVERIFIED` label.
4. **D03/D05:** row flip and global setter clamp (U2/U3) — keep `[U]`, no invented value.
5. **D06/D08/I10:** decide whether to port `CalcTerrain`, `test_shadow`, fog mode 1, tile-side shore painting and tile smoothing (V16 O11); keep `hmapTex` an open key.
6. **D02/V01:** settle RNG instance word order and saved-map byte mapping (U13) before any numeric replay claim.
7. **F10/COORD:** DLC5 `rivers` mask path exists but no skirmish placement rule — keep `OUT_OF_SCOPE`, invent no ford threshold.
8. **I13:** pin explicit 240² and 320² capture overlays; re-run all five gates with unique ids and mtime-after-START; acknowledge 575/582/585 with reasons (V06 §4.1).
9. **F07/X22/I09:** implement mill-field seeding as a separate runtime stage; port's half-step sow and missing decal/ore checks are PORT APPROX.
10. **Owner:** only a real matched-seed donor GPU frame can lift any tier-3 verdict to a parity statement. Until then, **no parity claim**.

## 7. Coverage manifest — all landed reports read for this index

| Report | Evidence ids / registers used | Sections |
|---|---|---|
| `A01_data_model.md` | E1–E22 | §01 |
| `A02_algorithm.md` | E01–E28, C1–C28 | §10 |
| `A03_asset_pipeline.md` | E1–E18 | §11 |
| `A04_landscape_props.md` | E01–E28 | §08 |
| `A05_qa_harness.md` | E01–E18 | §12 |
| `A06_integration.md` | E01–E16 | §12 |
| `D01_rtti_function_anchors.md` | E1–E30, correction log | §01/§09 |
| `D02_seed_rng.md` | 14 full ids, U1–U7 | §02 |
| `D03_mask_pipeline.md` | E01–E18, P1–P5 | §03 |
| `D04_map_format.md` | 9 evidence ids, fnd_30–32, P1–P10 | §01 |
| `D05_relief_stamp.md` | E1–E15, P1–P10, U1–U8 | §04 |
| `D06_water_shore.md` | 22 full ids, P1–P22 | §05/§06 |
| `D07_resources_bin.md` | 10 full ids, fnd_1–5, U1–U8 | §07 |
| `D08_tile_select_bin.md` | 22 ids, fnd_22–26 | §05/§06 |
| `D09_editor_binary.md` | 16 ids, fnd_27/28 | §09 |
| `F01_pattern_format.md` | E1–E22 | §04 |
| `F02_pattern_lib.md` | E1–E18, U-F02-1…9 | §04 |
| `F03_gen_config.md` | file SHA table, F1–F15, U1–U12 | §09 |
| `F04_masks.md` | E1–E13 | §03 |
| `F05_tile_mapping.md` | E01–E16 | §06 |
| `F06_alpha_masks.md` | F06-E1…E18 | §06 |
| `F07_mill_fields.md` | E1–E22 | §08 |
| `F08_flora_minerals.md` | E1–E19 | §07/§08 |
| `F09_editor_script.md` | E01–E21 | §09 |
| `P01_pipeline_audit.md` | E01–E20 | §14 |
| `P02_asset_inventory.md` | asset paths/manifest | §11/§12 |
| `P03_gates_capture.md` | E01–E22 | §12 |
| `P04_tool_audit.md` | tools #1–#17 | §11 |
| `P05_2d_reuse.md` | E table, V16-11 sub-item | §13 |
| `P06_prior_wave_distill.md` | §2 12 rejections, 28 open items | §13 |
| `V01_unverified_resolution.md` | EV01–EV24, U1–U16/R1–R9 | §02/§03/§04/§07/§10 |
| `V04_tree_conflicts.md` | §1 E01–E17, §2 SHA table | §12 |
| `V05_seam_reconciliation.md` | §2 evidence, §4 patch sketch | §12/§14 |
| `V06_gate_remediation.md` | E01–E20 | §12 |
| `V07_relief_asset_readiness.md` | §2 evidence | §08/§12 |
| `V08_coordinate_scale.md` | E1–E30, C1 | §01/§07 |
| `V09_2d_order_transplant.md` | §2 evidence | §13 |
| `V11_ownership_ledger.md` | §1 E01–E15, EDIT E1–E4, NEW N1–N22 | §12 |
| `V12_resource_spec.md` | C-V1…C-V9, §2 evidence | §07 |
| `V13_stale_qa_refs.md` | E01–E13, S1–S3 | §12 |
| `V15_acceptance_without_reference.md` | V-E01…V-E20 | §08/§12 |
| `V16_contradiction_register.md` | E01–E16, V16-01…27, O1–O14 | all |
| `V17_spec_readiness.md` | E1–E13, X1–X10 | all |
| `V20_smoothing_reconciliation.md` | E01–E20 | §06/§10 |
| `V21_gate_register.md` | §3 evidence | §12 |
| `X01_decomp_corpus.md` | E1–E14 | §01/§10 |
| `X02_editor_corpus.md` | §2 evidence | §09 |
| `X03_dscript_corpus.md` | E01–E21, §6 A1–A13 | §10 |
| `X05_pattern_lib_validation.md` | E1–E14, A1–A4 | §04 |
| `X06_atlas_visual_audit.md` | E01–E12 | §06 |
| `X07_visual_reference_index.md` | 12-image table | §08/§12 |
| `X08_tile_smooth_engine.md` | E01–E14, vectors V1–V11 | §06 |
| `X09_starting_settings.md` | E1–E24 | §07 |
| `X11_water_translation.md` | D06 id chain, §2 evidence | §05 |
| `X12_stamp_verification.md` | E1–E18, P1–P14 | §04 |
| `X17_blendfunc_verification.md` | 34 ids, §1 table | §06 |
| `X19_mask_decoder_gap.md` | E1–E21, BUG-1…4 | §03 |
| `X22_field_sowing_translation.md` | X-E01…X-E25 | §08 |

*End of spec/00_EVIDENCE_INDEX.md. Exactly one repo file written; donor read-only throughout; no donor binary executed, no Godot job, no donor visual parity claim.*
