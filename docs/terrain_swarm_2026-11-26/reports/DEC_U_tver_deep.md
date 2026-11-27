---
id: DEC-U-TVER-DEEP-2026-11-27
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: "WORKER DEC-U-TVER-DEEP — class-B static angle T-VER (live version/menu values selecting branch)"
owner_file: docs/terrain_swarm_2026-11-26/reports/DEC_U_tver_deep.md
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION
created: 2026-11-27
pin: t_87f0f3c130b0 (cossacks.exe, 5,768,048 B, sha256 87f0f3c130b0…; Deep mode; already active, pinned via document= on every call)
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, NO_APPROXIMATION, PARITY_UNVERIFIED]
parity_status: UNVERIFIED
parity_claim: NONE
visual_parity_claim: false
verdict: "RESULT IS NOT GOOD for T-VER — port's pinned 92/240² does NOT byte-match shipped artifacts; live branch selectors stay [U]"
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
scope_guard: "Repo/doc reads + read-only donor disassembly/byte/text reads only. No donor binary executed/copied; no Godot process, runner job, gate, harness, replay or port capture run; no source/shader/asset/config/test/fixture/result-JSON/git state written. Exactly one repository file written: this report."
governing_sources:
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_u_classify.md (§2.2 T-VER/MDEN/HF/OBJ = class B; §4 B5)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_u_register_update.md (§2.1 T-VER row)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_final_register.md (T-VER/MDEN/HF/OBJ row)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_save_deep.md (P6 53-vs-92, P8 header hexdump)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_save_contract.md (P9 shipped header oracle)
  - docs/terrain_swarm_2026-11-26/reports/D04_map_format.md (TerrainMapBegin layout, tag grid, 37-B records)
  - docs/terrain_swarm_2026-11-26/spec/07_RESOURCES.md (version/size gate, V01 EV03/EV09)
---

# DEC-U-TVER-DEEP — live version/menu values selecting the mine-band / terrain-type branch (2026-11-27)

> **Required reviewer line, verbatim:** PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

> No metric, gate, replay pair, ROI, still, hash or "close" value constitutes parity. `parity.claim = NONE`, `parity.status = UNVERIFIED`, `visual_parity_claim = false`. This report closes **zero** P0 items, promotes **zero** `[U]`→`[D]` branch selectors, and makes **no parity claim**.

## 0. Question and answer in 30 seconds

**Question (class-B static angle B5):** which live values select the version-gated branches (`gRecordGeneratorVersion <80/<91`, `mapsize>2`, `v<91 → 6-way else N-way`, mine-band matrix) — i.e. `gDataVersion`, `gRecordGeneratorVersion`, `mapsize`, `gc_MaxTerrainTypeCount` — and does the port's pinned **92 / 240²** exactly match shipped artifacts?

**Answer:**

1. **`(a)`** Packed-CODE byte search (11 patterns, all pinned `document: t_87f0f3c130b0`): script-lowercase names **`gDataVersion`, `gRecordGeneratorVersion`, `mapsize`, `gc_Max`, `MaxTerrainTypeCount`, `TerrainTypeCount`, `RecordGenerator`, `TerrainTypes`, `Tiny` → 0 hits each** `[O]`. They live in donor **text** (`.script`/`.global`/`.inc`), not in packed CODE. Positive CODE hits are **other namespaces**: `DataVersion` ×1 (shell-failure strings, not the serial global), `MapSize` ×9 (TexMapSize/ShadowMapSize/PFX TexMapSize/DefaultMapSize property names), `Version` ×34, `OSWMap13` ×8, `GameMapRecord*` ×8, `TerrainMapBegin` ×2, `Map.Ver` ×5, `Build.Ver` ×5, `Core.Ver` ×6 — with VAs/file-offsets in §1. **No CODE-embedded version-value table and no CODE `mapsize`-enum table was found** `[O]` (absence in file bytes only; packed tail opaque per X31).
2. **`(b)`** Four shipped `.map` heads are **byte-identical in the envelope**: `35 00 00 00` (=53) + `OSWMap13.Map.Ver[0.0]Build.Ver[2.0.0.2843]Core.Ver[1] ` + UID + `GameMapSnapShotBegin/End` + `GameMapRecordBegin` `[O]`. Terrain extents are **320²** (ausmis1/bonmis1/engmis4) and **384²** (battle1), sub=4; 4th header word is **64** on 320-maps vs **25920 (0x6540)** on battle1-384 `[O]`, semantics `[U]`. **No `5C 00 00 00` (=92) and no mapsize word occur in any shipped envelope** `[O]`.
3. **`(c)`** Donor text scan: the **sole** `gDataVersion` assignment in the whole `data/` text tree is **`gDataVersion:=92` (`serial.script:27`)** `[O]`; `initmapgen.inc:57/62/72` assigns/copies `gRecordGeneratorVersion` new-game-vs-record `[O]`; `gc_MaxTerrainTypeCount = 9` (`dmscript.global:236`) `[O]`; mapsize enum `0→320, 1→480, 2→640, 3→256, else 320` (`donewgame.inc:42-46`, `miscext2.script:19`) `[O]`. **No settings/profile text override of the version exists** in scanned text `[O]`; no `.sav`-carried version value was dumped (needs owner paired-save battery).
4. **`(d)`** The port pins `C_BROKEN_GENERATOR_VERSION = 92` / `generate()` default `generator_version = 92`, and ships `config.json` `map_width/height_tiles = 240` (a declared **PORT DEBUG ALIAS**, donor sizes are `[256,320,480,640]`) `[O]`. Against the fixed header dump in §4: **92 ≠ shipped 53** on word 0, **240² ∉ {320², 384²}** shipped extents → **zero-mismatch termination FAILS on the first word; the port pin does NOT exactly match shipped artifacts.** Both selectors stay **`[U]`**; only the literals (92-as-current-script-word, 53-as-shipped-envelope-word, 9-as-count-literal, enum-as-text) are `[O]/[D]`.

---

## 1. Pass (a) — packed CODE byte search, all pinned `t_87f0f3c130b0`

Method: `native_bytes_find` (utf8+utf16le, exact case-sensitive) with `document: "t_87f0f3c130b0"`; contexts via `native_bytes_show`; function attribution via `native_function_find`. Session verified active target `t_87f0f3c130b0` (cossacks.exe, 5,768,048 B) before the first call. File-bytes limitation applies throughout: matches in compressed/packed regions or runtime-built strings are not seen; a 0-hit result is observed file-bytes absence, not proof of engine-side absence.

### 1.1 Negative results (script-namespace names have no packed-CODE literal) `[O]`

| # | Pattern | Hits | Evidence id | Disposition |
|---|---|---|---|---|
| P-a1 | `gDataVersion` | **0** | `ev_f85c6bf5…` | `[O]` file-bytes absence; name is script-text-only |
| P-a2 | `gRecordGeneratorVersion` | **0** | `ev_a9bb195f…` | `[O]` same |
| P-a3 | `mapsize` (lowercase) | **0** | `ev_e3592b6a…` | `[O]` same; the live enum `gMap.settings.gen.mapsize` is script-text-only |
| P-a4a | `MaxTerrainTypeCount` | **0** | `ev_e95a654a…` | `[O]` same |
| P-a4b | `TerrainTypeCount` | **0** | `ev_8bca812c…` | `[O]` same |
| P-a4c | `RecordGenerator` | **0** | `ev_eedef2b25…` | `[O]` same |
| P-a4d | `gc_Max` | **0** | `ev_84efe505…` | `[O]` same |
| P-a4e | `TerrainTypes` | **0** | `ev_ee9d88ee…` | `[O]` same (the `TerrainTypes`/`TerrainTypesDLC5` parser keys of `dogenerate.inc:1550-1557` are text-side) |
| P-a4f | `Tiny` | **0** | `ev_4e22be0c…` | `[O]` same (the `// tiny` comment of `dogenerate.inc:571` is text-side) |

**[D]** consequence: no static CODE xref walk can start from these names; the B5 residual "live-settings dump" half (register prescription) is correctly aimed at **donor text + shipped-record reads**, not at a CODE literal.

### 1.2 `DataVersion` ×1 — shell strings, NOT the serial global `[O]`

- `native_bytes_find "DataVersion"` → **1 match**: VA **`0x683bb7`** (file `0x282fb7`, section CODE), inside `sub_683bb0+0x7` (`ev_f6c362c2…`, `ev_56e02a80…`).
- `native_bytes_show 0x683b80+96` (`ev_ac185e28…`) decodes ASCII: `…leShellCoreVersionFailed = …leShellDataVersionFailed = …leShellAuthC…` — a length-prefixed shell failure-message table. The hit is the tail of **`…ShellDataVersion…`**, unrelated to `serial.script`'s `gDataVersion`.
- No `0x5C` version-value literal is claimed from this site (single-byte `0x5C` is unsearchable — DEC_U_save_deep P6, re-affirmed, not re-attempted).

### 1.3 `MapSize` ×9 — property/API names, none is the `gen.mapsize` enum `[O]`

`native_bytes_find "MapSize"` → **9 matches** (`ev_afe29b6d…`; re-page `ev_db0b65db…` confirms total 9):

| VA | File off | Context (`native_bytes_show`) | What it is |
|---|---|---|---|
| `0x50bcad` | `0x10b0ad` | `…OSWPerlinPFX…TexMapSize…Smoothness…` (`ev_b4578753…`) | material property-table entry |
| `0x50cce7` | `0x10c0e7` | (same property-table run) | same table |
| `0x50d333` | `0x10c733` | (same property-table run) | same table |
| `0x69f783` / `0x69f7b3` | `0x29eb83` / `0x29ebb3` | `function GetShadowMapSize(): Integer … procedure SetShadowMapSize(size: Integer)` (`ev_b8628b83…`) | shadow-API RTTI names (CODE-embedded Delphi method strings) |
| `0x6db987` / `0x6db9df` | `0x2dad87` / `0x2daddf` | `function GetPFXPerlinPFXManagerTexMapSize(const managername: String): Integer …` (`ev_9c96adaa…`) | PFX-manager API RTTI names |
| `0x71c315` | `0x31b715` | `…FailStandCount…DefaultMapSize…TileSmoothPasses…` (`ev_bd23e922…`) | **CODE-embedded property table** (see below) |
| `0x71d1a3` | `0x31c5a3` | second `DefaultMapSize` literal (`ev_c9cd8573…`) | same table, second copy |

Property-table context (`ev_653949f3…`, VA `0x71c280+192`): `…FrequencyFactor…CellsResolution…FailStandCount…DefaultMapSize…TileSmoothPasses…` — each name framed as a length-prefixed CODE string with neighbouring `84 10 40 …` float-default words. So a CODE-embedded **generation-settings property table exists** with a `DefaultMapSize` row, but its numeric default word was **not** decoded in this pass (adjacent-word typing would be inference without the table schema) — recorded as structure `[O]`, value `[U]`. None of the 9 sites is `gMap.settings.gen.mapsize` (the `0→320…3→256` enum of §3).

### 1.4 `Version` ×34 — envelope-relevant subset isolated `[O]`

`native_bytes_find "Version"` → **34 matches** (`ev_1259be48…`): 27 CODE + 5 `.idata` import-name + 2 `.rsrc` UTF-16 hits. The envelope-relevant CODE subset (all in the `0x710xxx–0x716xxx` OSWMap/GameMap string run, §1.5):

- `Map.Ver` ×5: `0x710c05, 0x712795, 0x712d8d, 0x714245, 0x7163f9` (`ev_1f54248b…`).
- `Build.Ver` ×5: `0x710c10, 0x7127a0, 0x712d98, 0x714250, 0x716404` (`ev_7b8a6c66…`).
- `Core.Ver` ×6: `0x710c1d, 0x7127ad, 0x712da5, 0x71425d, 0x715e10, 0x716411` (`ev_080db544…`).
- Remaining CODE `Version` hits (e.g. `0x555bd5, 0x56bfe3, 0x607722…`, shell/GUI regions) were not individually contextualised — counted `[O]`, uninterpreted `[U]`; no version-value table is claimed from them.

### 1.5 `OSWMap13` / `GameMapRecord*` / `TerrainMapBegin` — envelope framing literals `[O]`

| Pattern | Hits | VAs (all section CODE) | Evidence |
|---|---|---|---|
| `OSWMap13` | **8** | `0x710bfc` (file `0x30fffc`), `0x71278c, 0x712d84, 0x71423c, 0x71459c, 0x7148c0, 0x715e30, 0x7163f0` | `ev_de6bfd7b…` |
| `OSWMap13` full `OSWMap13` re-search | 8 (same set) | same | `ev_e7826ffa…` |
| `GameMapRecord` | **8** | `0x712800, 0x71281c, 0x712df8, 0x712e14, 0x714910, 0x71492c, 0x715e80, 0x715e9c` (files `0x311c00…`) | `ev_e38aff68…` |
| `TerrainMapBegin` | **2** | `0x73a028` (file `0x339428`), `0x73a6b4` (file `0x339ab4`) | `ev_62b24a5e…` (matches D04 P2) |

Envelope format-string context (`ev_9196e9…, ev_12aa9fdf…`):

- VA `0x710be0+96`: `…lancode… OSWMap13.Map.Ver[%s]Build.Ver[%s]Core.Ver[%d] …pattern…`
- VA `0x712760+128`: `Map saving… 0.0 … OSWMap13.Map.Ver[%s]Build.Ver[%s]Core.Ver[%d] … GameMapSnapShotBegin …`

**[D]**: the shipped envelope's `Map.Ver[0.0]Build.Ver[2.0.0.2843]Core.Ver[1]` (§2) is an instantiation of this exact CODE format string (`%s, %s, %d`). The three version **values** are record/session data, not CODE constants — no static CODE value is claimed.

---

## 2. Pass (b) — shipped `.map` headers (read-only `open(rb)` dumps)

Tools: temp-outside-repo Python (`%LOCALAPPDATA%\Temp\opencode\tver_*.py`), never executing donor binaries. Four specimens cover both D04 sizes and both save-deеп specimens.

### 2.1 Envelope: all four maps share one byte-identical head `[O]`

| File | Size (B) | Offset 0 word | Envelope string |
|---|---|---|---|
| `ausmis1.map` | 43,950,027 | `35 00 00 00` (=53) | `OSWMap13.Map.Ver[0.0]Build.Ver[2.0.0.2843]Core.Ver[1] ` |
| `battle1.map` | 56,117,715 | `35 00 00 00` (=53) | identical |
| `bonmis1.map` | 23,447,543 | `35 00 00 00` (=53) | identical |
| `engmis4.map` | 29,429,271 | `35 00 00 00` (=53) | identical |

Full head (ausmis1, representative; all four verified byte-equal through `GameMapRecordBegin`):

```
35 00 00 00 | 4F 53 57 4D 61 70 31 33 2E 4D 61 70 2E 56 65 72 5B 30 2E 30 5D
42 75 69 6C 64 2E 56 65 72 5B 32 2E 30 2E 30 2E 32 38 34 33 5D
43 6F 72 65 2E 56 65 72 5B 31 5D 20 | 00 00 00 11 55 49 44 <uid> 00
00… | 14 00 00 00 GameMapSnapShotBegin 00 00 00 00 12 00 00 00 GameMapSnapShotEnd
12 00 00 00 GameMapRecordBegin 00 00 00 00 00 01 00 00 …
```

- UIDs differ per map (ausmis1 `UID108733367369411`, battle1 `UID884595181450305`, bonmis1 `UID423630422816850`, engmis4 `UID12002622587025`) `[O]`; every other envelope byte through `GameMapRecordBegin` is identical across the four files (`u32[0:16]` dump equal: `[53, 1297568591, 858878049, …]`) `[O]`.
- `0x35`-word scan of first 600 B: ausmis1 `[0]`, bonmis1 `[0]`, battle1 `[0, 79]`, engmis4 `[0, 78]` `[O]` — the second occurrence sits inside snapshot payload, not a second header.
- **[O] negative:** no `5C 00 00 00` (=92) occurs at offset 0 of any shipped map; no mapsize/enum word occurs anywhere in the 600-B envelope. The envelope carries **build identity (2843)** and **serial-53**, not the live `gDataVersion=92` word. Fresh-save `5C 00 00 00` stays a `[D]` prediction for an owner paired-save run (DEC_U_save_deep P6), not an observed shipped literal.

### 2.2 Terrain extents inside the same files `[O]` (values) / `[U]` (4th-word semantics)

| File | `TerrainMapBegin` file off | W | H | sub | 4th word |
|---|---|---|---|---|---|
| ausmis1 | 19,882,990 (`0x12f63ee`) | 320 (`0x140`) | 320 | 4 | **64** (`0x40`) |
| battle1 | 30,285,006 (`0x1ce1cce`) | 384 (`0x180`) | 384 | 4 | **25920** (`0x6540`) |
| bonmis1 | 9,276,029 (`0x8d8a7d`) | 320 | 320 | 4 | **64** |
| engmis4 | 9,057,516 (`0x8a34ec`) | 320 | 320 | 4 | **64** |

- Pre-marker bytes in all four: `…LoadFull 00 01 00 01 01 0B 00 00 00 ResourceEnd 0F 00 00 00 TerrainMapBegin` `[O]` — length-prefixed framing per D04 §4 (marker `u32 15` prefix confirmed in the `before_u32` dump).
- `[O]` W/H match D04 (320² trio, 384 battle1). `[U]` the 4th word: 64 on all 320-maps vs 25920 on battle1-384. D04 labelled it "tile pixel size (matches tiles.lib TileSize=64) [I]"; the battle1 divergence is new in this pass and its semantics (tile-px vs mode/flags vs first tag word) are **not** resolved here — no label is changed, no parity is claimed. Flagged as residual for the HF/MDEN follow-up, not as a T-VER branch input.

### 2.3 Record-version words near `GameMapRecordBegin` `[O]` position / `[U]` value mapping

- `GameMapRecordBegin` at file offset **147** in both ausmis1 and battle1 (snapshot envelope is fixed-length) `[O]`; `GameMapSnapShotBegin` at **97** `[O]`.
- Post-marker words (ausmis1): `00 00 00 00 | 00 01 00 00 | 00… | 8a 41 4a cd 23 bd 27 41 | 00…` ; (battle1): `…00 01 00 00 | 00… | 29 ae c7 0b 92 a9 0e 41 | 01 00 00 00 … C4 00 00 00 | 44 00 00 00 …` `[O]`.
- The serial `gDataVersion` word (expected `5C 00 00 00` on a fresh build-92 save) is **not identified** at a proven offset inside these build-53 records in this pass — the record-version field mapping needs the owner paired-save battery (P0-6 R1a). No byte is nominated as the version word here; the shipped `53` envelope word (§2.1) is the only byte-proven version value from shipped maps.

---

## 3. Pass (c) — donor settings/profile text for a version override (read-only)

Reads: `core_text_read` on donor text + whole-`data/` token grep (temp script, read-only). Nothing executed.

### 3.1 The version assignment graph — single writer `[O]`

| Site | Text (verbatim) | Standing |
|---|---|---|
| `data/scripts/lib/serial.script:22-28` | `global gDataVersion: Integer; global gSerialVersion: Integer; …` / **`gDataVersion:=92; gSerialVersion:=gDataVersion;`** | `[O]` sole assignment in the entire `data/` text tree (47-hit sweep: every other hit is a read/compare/gate) |
| `serial.script:37` | `WriteInteger(fs, gDataVersion);` in `_serial_BeforeProcWriter` | `[O]` stream opens with the version word |
| `serial.script:534` | `gSerialVersion:=gDataVersion;` (post-load) | `[O]` |
| `serial.script:2411` | `if gDataVersion<53 then SeekBuffer(…80*80) else …` | `[O]` version-gated reader (build-53 compat load-bearing) |
| `common.inc/initmapgen.inc:57` | `gRecordGeneratorVersion := gDataVersion;` (new-game path) | `[O]` fresh games run at **92** |
| `initmapgen.inc:62` | `ParserSetIntValueByKeyByHandle(pRMGenerator, 'ver', gDataVersion);` | `[O]` record stamps 92 |
| `initmapgen.inc:72` | `gRecordGeneratorVersion := ParserGetIntValueByKeyByHandle(pGen, 'ver');` (record path) | `[O]` authored/record games run at the **stored** `ver` — the T-VER branch input |
| `dogenerate.inc:236-238` | replay → `curver := gRecordGeneratorVersion` else `curver := gDataVersion` | `[O]` the live selector idiom |
| `menu.inc/donewgame.inc:37` | `'game_v'+IntToStr(gDataVersion)+'k'+IntToStr(GetRandomKey)+'.map'` | `[O]` filename embeds the live version |
| `menu.inc/showmainmenu.inc:153` | version label uses `IntToStr(gDataVersion)` | `[O]` menu displays the live word |

Version-gate lattice using `gRecordGeneratorVersion` (all `[O]` text observations, branch outcomes `[U]` without a live dump): `<53` (initmapgen :78/:103/:273/serial :2411), `<61` (dogenerate :1093), `<63` (initmapgen :84/:109), `<68` (:121), `<70/:573` bands, `<75/:606`, `<77` (:617/desert :735/:774/teams :1175), `<80` (:584/:628), `<89` (initmapgen :280/readres :9/readstats :16-:19), **`<90` corner (:660, `mapsize>2` conjunction)**, **`<91` DLC5 split (:1547)**, `>55` (readtimespeed :6), `>66/>70/>75/>81` (country.script :4247-4265), `>77` (:1175), `>78-or-0` (ontagstates :267), `=44` comment fossil (:1096).

### 3.2 `mapsize` enum and `gc_MaxTerrainTypeCount` — text values `[O]`, live menu/record values `[U]`

- `donewgame.inc:42-46` + `miscext2.script:19`: `case gMap.settings.gen.mapsize of 0: 320; 1: 480; 2: 640; 3: 256; else 320` `[O]` — hence **`mapsize>2` ≡ 256-cell TINY** (spec/07 V26 C2, re-verified verbatim, not re-derived).
- Receiver: `miscext2.script:2631` (`gc_MaxPlayerCount+5 : map.settings.gen.mapsize := istr`) and `roomdata` serialisation `:2370` (`…resourcemines…+mapsize…`) `[O]` — the live value arrives via multiplayer/setup parsing; **no live captured value exists** → stays `[U]`.
- `generatemap.inc:71-77` editor `mapsize` form (`Map Size (320-640)`, `NewMap(genmapsize, genmapsize, 0)`) `[O]` — editor path, not skirmish truth.
- `dmscript.global:236`: **`gc_MaxTerrainTypeCount = 9`** `[O]` (with `gc_MaxSeasonCount = 3`, `gc_MaxReliefTypeCount = 6-1` on the same line).
- `dogenerate.inc:1550-1557`: `v<91 → TerrainTypes + floor(RandomExt*6)` else `TerrainTypesDLC5 + floor(RandomExt*gc_MaxTerrainTypeCount)` `[O]` — the T-VER/MDEN branch the port must select.
- Live menu surface: `showcustomgame.inc:146/155/779` builds the terraintype listbox `0 … gc_MaxTerrainTypeCount-1` plus a `random` slot (`gc_MaxTerrainTypeCount` as item data), default index 1 `[O]`; **which entry is live in any session is unobserved** → `[U]`.
- No per-pattern `HeightField*`/`minangle/maxangle` numeric was lifted in this pass (belongs to the OBJ/HF residual, not T-VER).

### 3.3 Settings/profile override sweep — none found `[O]` (scoped)

- 47-hit whole-`data/` sweep for `gDataVersion|gRecordGeneratorVersion` across `.script/.global/.inc/.cfg/.aix`: exactly **one** assignment site (`serial.script:27`); all others are reads, gates, or stamp/parse calls (§3.1) `[O]`.
- `data/game/var/` holds `generator.cfg` (with the `TerrainTypesDLC5` struct, `:29`), `startingsettings.cfg` (no `mapsize` token — presets, not the live word), `battles/campaigns/formations/hotkeys/random/units/wallcustom/envscales/objcustom.cfgs` — **no `ver`/version key in any scanned cfg** `[O]` (scoped to token grep, not a full-schema audit).
- No `.sav`/`.save`/`.profile` version carrier was produced or dumped by this worker; the prior full-tree absence observation (`PORT1TO1_owner_decisions_update.md`, also carried in `PORT1TO1_p0_final_status.md:59`) is **cited, not re-proven** here. Profile verbs (`UserSaveProfile(Ext)`, `StateMachineGlobalVariablesSaveToStack`) remain engine-opaque. **A live settings/profile override is therefore `[U]` pending the owner paired-save/store snapshot battery — nothing in scanned text performs one.**

---

## 4. Pass (d) — does the port's pinned 92/240² exactly match shipped artifacts?

### 4.1 What the port pins (repo file:line, read-only) `[O]`

| Port pin | Location | Literal |
|---|---|---|
| Generator version default | `variant3d/scripts/terrain_donor_gen.gd:268` | `C_BROKEN_GENERATOR_VERSION: int = 92  # gDataVersion, serial.script:27` |
| `generate()` default | `terrain_donor_gen.gd:697-698` | `generator_version: int — default 92 (serial.script:27)`; `mapsize: int — mapsize>2 = 256-cell TINY (donewgame.inc:46)` |
| Donor sizes | `variant3d/scripts/terrain_donor_data.gd:44-46` | `DONOR_SIZES := [256, 320, 480, 640]`; `PORT_DEBUG_ALIASES := [160, 64, 240]`; `ALLOWED_SIZES := [256, 320, 480, 640, 160, 64, 240]` |
| QA/config grid | `variant3d/config.json:81-82` (+ `config_donor_capture.json`) | `map_width_tiles = 240, map_height_tiles = 240` — a declared debug alias, not a donor enum member |

### 4.2 Fixed-seed map/header dump (the comparison artifact)

Fixed inputs (no execution; bytes as stored): the §2.1 envelope of all four maps + §2.2 W/H + §3.1/§3.2 text values + §4.1 port pins.

```
# fixed header dump (observed, all four maps agree through GameMapRecordBegin):
off0 : 35 00 00 00                                   (=53)
env  : OSWMap13.Map.Ver[0.0]Build.Ver[2.0.0.2843]Core.Ver[1]␣
snap : GameMapSnapShotBegin … GameMapSnapShotEnd  GameMapRecordBegin
terrain: ausmis1/bonmis1/engmis4 W=320 H=320 sub=4 w4=64
         battle1                 W=384 H=384 sub=4 w4=25920(0x6540)
text   : gDataVersion:=92 | gc_MaxTerrainTypeCount=9 | mapsize 0→320,1→480,2→640,3→256
port   : generator_version=92 | grid 240² (debug alias) | DONOR_SIZES 256/320/480/640
```

### 4.3 Zero-mismatch termination (fails → stays `[U]`)

Termination criterion (from the register): dumped integers select the observed branch with **0 mismatching words** across ≥2 shipped maps plus an owner paired-save `5C 00 00 00` control.

| Comparison | Result | Label |
|---|---|---|
| Port 92 vs shipped envelope word 0 (53) | **MISMATCH** (first word differs) | `[O]` mismatch; 92 remains current-script-word only |
| Port 240² vs shipped 320²/384² | **MISMATCH** (240 ∉ shipped extents; 240 is a port debug alias) | `[O]` mismatch |
| Port `mapsize>2`=tiny reading vs shipped record `ver` | **UNTESTED** (no shipped record `ver`/live menu value dumped) | `[U]` |
| Port `v>=80`/`v>=91` band assumption vs live selector | **UNTESTED** (live `gRecordGeneratorVersion` undumped) | `[U]` |
| `gc_MaxTerrainTypeCount` = 9 | text-literal match, **not** a live-menu dump | `[O]` literal / `[U]` liveness |

**Verdict for (d): the port's pinned 92/240² does NOT exactly match shipped artifacts.** 92 is byte-proven only as the *current* `serial.script:27` literal (fresh-save prediction `5C 00 00 00` is `[D]`, unobserved); shipped maps are build-2843 serial-53 artifacts with 320²/384² terrain. The 240² QA grid matches no shipped extent and no donor enum member. No value is promoted: T-VER/MDEN selectors stay `[U]` until the owner runs the live-settings dump + paired-save battery (record `ver` integers on both sides of v91, menu mapsize/terraintype indices, re-save `5C…` control) with the zero-mismatch criterion above.

---

## 5. Claim register (audit-level; no parity)

| # | Claim | Label |
|---|---|---|
| 1 | 11 packed-CODE patterns searched pinned `t_87f0f3c130b0`: 8 script-namespace patterns 0-hit; `MapSize` 9 hits (all property/API names, VAs in §1.3); `DataVersion` 1 hit (shell strings `0x683bb7`); `Version` 34 hits (envelope subset `Map/Build/Core.Ver` VAs in §1.4); `OSWMap13` 8 / `GameMapRecord` 8 / `TerrainMapBegin` 2 / envelope format string at `0x710be0` (`Map.Ver[%s]Build.Ver[%s]Core.Ver[%d]`) | `[O]` this pass (evidence ids in §1) |
| 2 | Four shipped heads byte-identical through `GameMapRecordBegin`: `35 00 00 00` + `OSWMap13.Map.Ver[0.0]Build.Ver[2.0.0.2843]Core.Ver[1] ` + per-map UID + snapshot framing; `GameMapRecordBegin`@147, `GameMapSnapShotBegin`@97; terrain 320²×3 + 384×1, sub=4, w4 64 vs 25920 | `[O]` §2 (hex dumps) |
| 3 | Sole version writer `gDataVersion:=92` (`serial.script:27`); record/new-game fan-out (`initmapgen.inc:57/62/72`); gate lattice; mapsize enum `0→320,1→480,2→640,3→256`; `gc_MaxTerrainTypeCount=9`; menu listbox shape | `[O]` donor text reads, §3 |
| 4 | No settings/profile text override found in scanned text; full-tree `.sav` absence cited from prior work, not re-proven; live menu/record values unobserved | `[O]` scoped / `[U]` liveness |
| 5 | Port pins 92 + 240² do not byte-match shipped 53-envelope / 320²-384² extents; zero-mismatch termination fails at word 0; all T-VER branch selectors stay `[U]` | `[O]/[D]` §4 |
| 6 | No donor binary executed, no GPU frame captured, no harness/gate/replay run, no port capture compared by this worker | `[O]` scope guard |
| 7 | `parity.claim = NONE`, `parity.status = UNVERIFIED`, `visual_parity_claim = false`; no approximation adopted; exactly one repository file written | `[O]` scope guard |

> **Verdict (governing form):** `port=UNVERIFIED`; `parity.claim = NONE`; `parity.status = "UNVERIFIED"`; `visual_parity_claim = false`; T-VER/MDEN selectors (`gRecordGeneratorVersion`, `mapsize`, live terraintype index) remain `[U]`; six-condition chain unchanged by this report. **No invented version; no parity claim.**

*End of DEC_U_tver_deep. Read-only; exactly one repository file written; no source/asset/config/test/runner/Godot/git/donor-execution; parity UNVERIFIED.*
