---
id: X29
title: "X29 — donor `.map` placement / record semantics: 37-byte tile re-verification, head/tail decode, GameObject records, undecodable register"
wave: X (verification, donor-first)
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_SOURCE_EDIT__NO_GIT_MUTATION__NO_RUNNER__NO_GODOT__NO_DONOR_BINARY_RUN
labels: [O, D, I, U, "PORT APPROXIMATION"]
owner_file: docs/terrain_swarm_2026-11-26/reports/X29_map_placement_semantics.md
scope: "READ-ONLY. Donor `C:\\Games\\Cossacks 3` was read with read-only Python and a read of the four named text scripts. No donor binary was executed, copied into the repo, or committed. Scratch scripts only in `%TEMP%\\opencode\\map_semantics\\`. No source/shader/config/asset/test/JSON/git edit; no Godot or runner job. Only this report was written."
parity_guard: "NO DONOR GPU A/B FRAME EXISTS. Every donor statement here is a structural/byte citation. All port statements are PORT APPROXIMATION. NO PARITY CLAIM, no PASS claim, no gate claim."
pre_read: "CHARTER.md, SWARM_BOARD.md, reports/D04_map_format.md, reports/V03_open_items_resolution.md, reports/F10_dlc_terrain.md, spec/01_WORLD_DATA_MODEL.md §5, docs/decomp/DD_MAPS.md — all re-read before any measurement."
---

# X29 — `.map` record and placement semantics

## Executive summary (5 lines)

1. **[O]** The 37-byte tile record is re-verified byte-for-byte in 3 deep-scanned maps (102,400 + 102,400 + 147,456 records) and header-anchored in all **37** base-install maps: 24-byte head + 13-byte tail; tile ids at `+8..11`, four `1.0f` at `+16..31`, `FFFF` at `+5..6`, byte `+12` a per-cell random byte, byte `+36` zero on disk. No owner/fog/resource/collision field exists in it.
2. **[O]/[D]** The authoritative **on-disk** height count is **`(W+1)^2 − 2`**, not the `(W+1)^2` loop read in `D04 §3.4`: 37/37 maps give `nh = (W+1)^2−2` with **zero** gap to the tile array (e.g. `bonmis1.map` grid `0xa68acd`, tile `0xacd4c9`, `nh=103,039`; `battle1.map` `0x1f21d1e`→`0x1fb291a`, `nh=148,223`). Structurally it is **W full rows of (W+1) floats + a final row of (W−1)**. The −2 cause stays **[U]**.
3. **[D]** The four named scripts do **not** describe the terrain tile record: `writenewp.inc`/`readnewp.inc` are **network/replay `RecordCustomBegin('ReadNewP')` object-spawn packets**, `serial.script` is a generic DScript save serializer (`gDataVersion=92`), and `miscext2.script` holds settings/coordinate bounds. Treating them as `.map` tile serializers is refuted in six passes (§5).
4. **[O]/[D]** Placements are `int32 15 + "GameObjectBegin"` records *after* `TerrainMapEnd`, with grammar `category, type, x, y, z, instance, type, category, owner, <packed runtime state>`; terrain-relevant types (`field`, `stones*`, `minegold/iron/coal`, `grassforest.*`, `pine*`, `palm`, `desert*`) are `env`-category, owner `env`. `miscext2.script:1627-1631` fixes world X/Z to `±W/2, ±H/2` in **tile units**; the middle float is height-bounded (`0.0`/`±2.964` peaks) but its exact grid binding is **[U]** after a contradictory second pass.
5. **[U]** Remaining undecodable bits (byte 12 consumer, `FFFF`, tag enum, 41-byte gap, header `u16 101`, packed GameObject state, per-map season, row/metre scale) are runtime/packed-only: no donor enum table, no writer call recovered, and donor execution is forbidden by `CHARTER.md:69`.

---

## 1. Method and multi-pass log (owner directive: no silent skips)

| # | Pass / instrument | Result | Accepted / rejected and why |
|---:|---|---|---|
| P1 | Fresh read-only `bytes` scan of `bonmis1.map`, `engmis4.map`, `battle1.map`; anchor tile array on the invariant `00 00 80 3f`×4 quad, validate FFFF at records 1/2 | All weight quads and reserved fields reproduce D04's flat map exactly | **Accepted** — independent re-derivation, not a re-quote |
| P2 | Compute `nh = (tile_off − grid_off)/4` for the same 3 maps | `103039 / 103039 / 148223` = `(W+1)^2−2` each; delta vs writer loop `(W+1)^2` = **−2**; gap = 0 B | **Accepted** as authoritative on-disk count |
| P3 | Extend P2 to **all 37** base-install `data/maps/missions/*.map` | 37/37 exact; W ∈ {320, 384, 512, 640}; sub=4 everywhere | **Accepted** — closes the count question at the corpus level |
| P4 | Dump the final 12 floats before the tile array and decompose rows at stride W+1 | `bonmis1`: 320 full rows ×321 + remainder row ×319; last 12 floats `00 00 00 00` | **Accepted** — gives the concrete row shape `(W+1)·W + (W−1)` |
| P5 | Full census of `+5,+6,+7,+12,+36` and the 1.0f quad over all records | `FFFF` 102399/102400 (only record 0 is `0000`); `+7`,`+36` zero 100%; `+12` all 256 values; quad 100% | **Accepted** |
| P6 | Byte-12 correlation: 8 coordinate-hash candidates with all 256 additive offsets, entropy conditional on tile id and on 64 height bins, horizontal/vertical neighbour equality | Modal hash rate ≈0.005 (random ≈0.0039); entropy 7.996 bits; neighbour equality 0.0037–0.0043 ≈ random; conditional entropy ≈7.75–7.95 | **Accepted** as "per-cell pseudo-random, no recovered rule"; meaning stays **[U]** |
| P7 | Read `writenewp.inc`, `readnewp.inc` in full | `RecordCustomBegin('ReadNewP')`, `RecordCustomWrite*` of boolean/race/base/posx/posz/roll/plind/id/uid/count; spawn `CreatePlayerGameObjectHandleByHandle(plhnd, race, base, posx, 0, posz)` | **Accepted with corrected scope**: these are *network* packets, not `.map` records. The task's suggested correlation is **refuted**, not silently assumed |
| P8 | Read `serial.script` header + grep for terrain/tile/map terms | 69 hits, all `GetGameObject*`, `TSquad`, `gMap.settings.gen.*`; **zero** tile/height/marker hits; `gDataVersion:=92` at `serial.script:27` | **Accepted**: generic DScript save layer; cannot decode the native tile block. Side result: F10 U5's version threshold `>=91` is satisfiable (92) |
| P9 | Read `miscext2.script` settings/coordinate sections | `mapsize` enum `:19-26` (0→320,1→480,2→640,3→256); settings fields `:2626-2631`; world bounds `:1627-1631` ±`GetMapWidth/Height div 2`; `_misc_SaveMap`/`LoadMap` at `:3152/:3161` | **Accepted**; supplies donor coordinate contract and the settings tuple |
| P10 | Raw token dump of first 4 `GameObjectBegin` records + census over 7,742 (bonmis1) / 10,521 (turmis1) records | Grammar and category/type/owner counts recovered (§6); all `bad=0` | **Accepted** |
| P11 | Placement middle float vs serialized height grid, pass 1: brute-force scale/offset/flip/transpose over non-clamped placements | `r≈0.992–0.995`, MAE 0.01–0.02, best `cell=W/2+x`, `row=W/2−z`, stride W+1 | **Rejected on pass 2** as zero-inflated (mass of `y=0` cells with `h=0`): exact match only 11–30% and distinctive units disagree |
| P12 | Placement middle float vs grid, pass 2: restrict to `|Y|>0.5`, both Z signs, 16 printed examples | `kingmusketeer` Y≈0.51–0.75 vs grid `2.964` (z−) / `−1.05` (z+); exact match ≤0.001 for distinctive values | **Contradiction preserved**: field is height-*bounded* but exact grid binding **[U]**, no meaning guessed |
| P13 | Header bytes at `mk+15…mk+39` for 3 maps | Field D04 called `u32 64 tile pixel size` is `40 00 00 00` in 22/37 maps but `40 65 00 00` in 15/37; as u16 LE that is `(64, 0)` or `(64, 101)` | **D04's single-field reading rejected**; low u16 constant 64, high u16 0/101 **[U]** |
| P14 | `turmis1.map` tile-id histogram via `import_donor_map.py --export-placements` (read-only) | Dominant ids resolve to `sandsea5`, `ground1_winter`, `grass9_winter`… yet F10 E38 found **zero** `winter` ASCII tokens in that file | **Reconciled**: ids are ordinals into a table that contains winter-named entries; the per-map season integer remains **[U]** (F10 U1) |

No target was opened/selected; no investigation brief or plan was reset. Scratch artifacts live only in `%TEMP%\opencode\map_semantics\`.

---

## 2. Evidence table

| # | Donor path:offset / source | Observation | Label |
|---|---|---|---|
| E1 | `data/maps/missions/bonmis1.map` `mk=0x8d8a7d`, tag `0x8d8a9c`, 2nd header `0xa68ac5`, grid `0xa68acd`, tile `0xacd4c9..0xe6a4c9` | W=H=320, sub=4; `nh=103,039=(321)^2−2`; weights 102,400/102,400 | [O] |
| E2 | `engmis4.map` grid `0xa3353c`, tile `0xa97f38..0xe34f38` | W=320; `nh=103,039`; weights 102,400/102,400 | [O] |
| E3 | `battle1.map` `mk=0x1ce1cce`, grid `0x1f21d1e`, tile `0x1fb291a..0x24e691a` | W=384; `nh=148,223=(385)^2−2`; weights 147,456/147,456 | [O] |
| E4 | All 37 `data/maps/missions/*.map` headers | 37/37 `nh=(W+1)^2−2`, gap 0; W=320/384/512/640; header `sub=4` | [O]/[D] |
| E5 | `bonmis1.map:0xacd4c9` rec0 `00 00 00 00 00 00 00 00 00 4f 4f 4f b2 00 00 00 00 0000803f×4 00 00 00 00 00`; rec1 `…00 ff ff 00 4f 4f 4f 4f 59 …` | Flat 37-byte map reproduced; FFFF at +5..6 except rec0 | [O] |
| E6 | Full-record census, 3 maps | `+0..4`, `+7`, `+13..15`, `+32..35` = 0 (100%); `+16..31` = four 1.0f (100%); `+36` = 0 on disk (100%, loader sets 1 per `D04 §3.4`) | [O] |
| E7 | Byte-12 statistics, bonmis1/battle1 | 256/256 values, entropy 7.996 bits, neighbour equality ≈ random 0.0039, no coordinate hash | [O]/[D] |
| E8 | `data/scripts/units/global.inc/writenewp.inc:53-81`, `readnewp.inc:9-19` | Network custom record: boolean, race, base, posx, posz, roll, plind, id, uid, count; spawn at y=0 (`:20`, `readnewp.inc:38`) | [O] |
| E9 | `data/scripts/lib/serial.script:22-30`, full grep | `gDataVersion:=92`; generic `WriteInteger/ReadInteger` DScript serializer; no terrain/tile code | [O] |
| E10 | `data/scripts/lib/miscext2.script:19-26`, `:2626-2631`, `:1627-1631`, `:3152/:3161`, `:15/:27-28` | mapsize enum; `season/terraintype/relieftype/resourcestart/resourcemines/mapsize`; world bounds ±W/2, ±H/2; save/load calls; `randkey0/1` | [O] |
| E11 | `bonmis1.map:0xebd0ec` first `GameObjectBegin` (prefix `u32 15`) | `buildings`, `polcen`, `-23.75, 0.0, -140.75`, `polcen0.15978`, `polcen`, `buildings`, `player0`, then packed u32 state, mesh `polcen.mesh` at `0xebd42a` | [O] |
| E12 | Placement census `bonmis1.map` | 7,742 records: env 7,306 / units 396 / buildings 39 / misc 1; `field` 206, `grassforest.*` 385, `stones*` 111, `minecoal` 17, `mineiron` 16, `minegold` 14 | [O] |
| E13 | Placement census `dlcs/dlc3/data/maps/missions/turmis1.map` (read-only) | 10,521 records: env 9,332 / units 724 / buildings 245 / misc 220; `palm` 770, `desert1-5` 2,271, `field` 79, `minegolds` 10, `mineirons` 9, `minecoals` 11 | [O] |
| E14 | Middle-float histogram, bonmis1/turmis1 | Peaks at `0.0` (env 4,286 / 6,567) and `+2.964` (727 / 771); continuous values between; bounded ±2.964 | [O] |
| E15 | `bonmis1.map` distinctive units `kingmusketeer` x≈−142 z≈−142 | Y≈0.51–0.75 vs grid 2.964 (row W/2−z) or −1.05 (row W/2+z) → exact binding refuted | [O]/[U] |
| E16 | `variant3d/tools/import_donor_map.py:186-208,222-304,309-377` (read-only tool source) | `--survey` decodes 4 u8 ids + weight quad + named array + GameObject strings; tool itself labels all other fields UNVERIFIED | [O] (tool reading, prior art) |
| E17 | `bonmis1.map mk+27` bytes `40 00 00 00`; `ausmis3.map`/`battle1.map` `40 65 00 00` | u16 LE pair `(64,0)` vs `(64,101)` — D04's "tile pixel size u32" is not one field | [O] |
| E18 | `dlcs/**` F10 E1/E3 + this worker's turmis1 read | 49 baked DLC maps, read-only; `TMapSettingsGen` field names present, season value not decoded; zero `winter` token | [O]/[U] (F10 U1) |

All offsets are **file offsets** in the named donor map; all integers little-endian (x86, confirmed by `40 01 00 00` = 320).

---

## 3. Method — what was actually measured

Read-only Python (`bytes`, `struct`, `Counter`) against five named donor maps plus all 37 base-install maps and one DLC map; no decompression, no donor process. The tile array was located **without assuming the height count**: scan forward from `grid_off + W*W*4` for `struct.pack('<4f',1,1,1,1)`, take `candidate = pos−16`, and accept only if records 0/1/2/7/100/last carry the quad and records 1/2 carry `FF FF` at `+5..6` — the same invariant `import_donor_map.py::find_tile_grid` uses (`E16`). This makes the height measurement independent of the count being tested. Scripts were read as text; no script was executed.

---

## 4. Finding F1 — 37-byte record, re-verified `[O]`

Binary split (writer stride `0x18` then `0x0d`, `D04 §3.4`):

- **24-byte head** = flat bytes `0..23`
- **13-byte tail** = flat bytes `24..36`

| Flat byte(s) | Type | Measured value | Field reading | Label |
|---|---|---|---|---|
| 0–4 | `u8[5]` | `00` in 100% | reserved / zero prefix | [O] |
| 5–6 | `u16` LE | `FF FF` in all records **except record 0** (`00 00`) | "initialised/valid" sentinel; `−1` if signed — consumer **[U]** | [O]+[U] |
| 7 | `u8` | `00` 100% | zero | [O] |
| 8–11 | `u8[4]` | 36–48 distinct ids per map, one per 2×2 subtile | **tile ids** (ordinals; `D04 §4.3`, `E16`) | [O]/[D] |
| 12 | `u8` | all 256 values; entropy 7.996 bits; no spatial/tile/height rule | per-cell pseudo-random byte, **meaning [U]** | [O]/[U] |
| 13–15 | `u8[3]` | `00` 100% | zero | [O] |
| 16–19, 20–23 | `f32, f32` | `1.0f` 100% | weight[0], weight[1] (**in head**) | [O] |
| 24–27, 28–31 | `f32, f32` | `1.0f` 100% | weight[2], weight[3] (**in tail**) — the quad straddles the 24/13 boundary | [O] |
| 32–35 | `u8[4]` | `00` 100% | zero | [O] |
| 36 | `u8` | `00` on disk 100%; loader sets `1` in memory (`D04 §3.4`) | in-memory loaded flag | [O] |

Invariant counts: bonmis1 102,400/102,400; engmis4 102,400/102,400; battle1 147,456/147,456. The `FFFF` exception is **exactly one record, always record 0 at (x=0,y=0)** in every map checked (`E5`, P5). No second exception was found in any map. The four weights are always equal, so no weighting rule needs inventing.

**Correction to D04 (P13):** the 4-byte field at `mk+27` that D04 labelled "tile pixel size = 64 (matches `tiles.lib`)" is `40 00 00 00` in 22/37 maps but `40 65 00 00` in 15/37 (`E17`). As two u16 LE values it is `(64, 0)` or `(64, 101)`. The constant 64 survives; the second half is **[U]**. The decoder must not hard-code a single u32 there.

---

## 5. Finding F2 — head/tail semantics: what is **not** in the record `[O]/[U]`

The task asked to test owner / fog / resource / collision against the four named scripts. Multiple passes gave a clean **negative** result:

| Candidate | Test | Verdict |
|---|---|---|
| **Owner** | 24+13 bytes contain no string, no player ordinal, no pointer; byte 12 is uniform-random; owner strings `player0…player6`, `env` occur only in `GameObjectBegin` records (`E11`, E12) | **[O] absent from tile record**; lives in GameObject/Player records |
| **Fog / visibility** | No per-cell boolean (byte 12 has 256 values); `spec/01 §3` already calls fog a global shader/palette | **[O]/[I] absent**; per-cell fog would be PORT APPROX |
| **Resource pointer** | No id/pointer field; `ResourceBegin…ResourceEnd` is a separate stream section (DD_MAPS §3.1 marker census, `bonmis1.map:0x8d839e`) | **[O] absent**; resources are separate records |
| **Collision flags[4]** | No 4-flag group in the 37 bytes; the `(2W)^2` u32 tag grid at `mk+31` is the only collision-like array (`D04 §4.2`, values `0/0x0700/0x0A00/0x5700/0x6500/0x6D00/0x6E00`) | **[O] absent from record**; tag grid is **[I]** collision/mask, enum **[U]** |
| **`writenewp.inc`/`readnewp.inc` as tile serializers** | They open `RecordCustomBegin('ReadNewP')` and write/read boolean + race + base + posx + posz + roll + plind + id + uid + count (`E8`) | **[O] refuted**: these are network/replay spawn packets. The `y=0` in `CreatePlayerGameObjectHandleByHandle(…, posx, 0, posz)` explains ground placement but says nothing about the 37-byte record |
| **`serial.script` as tile serializer** | 69 hits, all game-object/army/player types; zero `TerrainMap*`, `GetTileIndex`, `height` grid hits; `gDataVersion:=92` (`E9`) | **[O] refuted**: generic DScript save layer. Native terrain I/O is `sub_739d3c`/`sub_73a0b8`/`FUN_008305a0`/`FUN_008302b0` (`D04`) |
| **`miscext2.script`** | Holds settings, `mapsize` enum, world bounds and `_misc_SaveMap/LoadMap` calls (`E10`) | **[O] corroborates settings/coordinates, not tile bytes** |

**Therefore the 13-byte tail is 8 bytes of `1.0f` weights + 4 reserved zeros + 1 loaded flag — not owner/fog/resource/collision.** The only still-unknown field in either half is byte 12 (and the `FFFF` sentinel).

---

## 6. Finding F3 — height-count discrepancy: authoritative count `[O]/[D]`

| Quantity | bonmis1 | engmis4 | battle1 | All 37 base maps |
|---|---:|---:|---:|---|
| W | 320 | 320 | 384 | 320/384/512/640 |
| `grid_off` | `0xa68acd` | `0xa3353c` | `0x1f21d1e` | varies |
| `tile_off` | `0xacd4c9` | `0xa97f38` | `0x1fb291a` | varies |
| observed `nh=(tile−grid)/4` | 103,039 | 103,039 | 148,223 | exactly `(W+1)^2−2` |
| `(W+1)^2` (binary writer loop, `D04 §3.4`) | 103,041 | 103,041 | 148,225 | +2 over observed |
| `(W+1)^2−2` | **103,039** | **103,039** | **148,223** | **match, 37/37** |
| `W^2` (old port reading) | 102,400 | 102,400 | 147,456 | short by `2W−1` |
| gap bytes at tile array | **0** | **0** | **0** | **0** |

Row decomposition (`bonmis1`, P4): **320 full rows × 321 values + a 319-value remainder row**; the last 12 floats before `tile_off` are `00 00 00 00`. General form: `W·(W+1) + (W−1) = (W+1)^2−2`. This is the **authoritative on-disk count**; the decoder should anchor on the quad (as `import_donor_map.py` does) or read `nh=(W+1)^2−2`. The "639-float post-grid run" of the old port is simply the tail of this row-major height grid, not a separate structure.

**Cause of the −2 remains [U]** after P2–P4 plus D04's P5/P7/P8: possibilities (writer loop bound misread in disassembly, trimming of two trailing boundary vertices, or a version-dependent path) are not distinguishable from bytes. The tile-array alignment itself rules out a simple +8-byte shift (D04 P8 rejected).

---

## 7. Finding F4 — GameObject / placement records `[O]/[D]`

### 7.1 Storage and grammar

Placements are **not** in the 37-byte grid and **not** authored by the four scripts; they are native records following `TerrainMapEnd` (bonmis1: `TerrainMapEnd` at `0xeaf4af`, first `GameObjectBegin` at `0xebd0ec`, i.e. after the tile array end `0xe6a4c9` and the camera/module substreams). Marker census (`bonmis1.map`, E11/E12): `TerrainMapBegin` ×1, `TerrainMapEnd` ×1, `GameObjectBegin` ×7,742, `GameObjectEnd` ×7,742, `ResourceBegin/End` ×1, `Player` ×55, `PlayersEnd` ×1, `Object` ×15,489, `GameMapEnd` ×1. `turmis1.map` has 10,521 `GameObjectBegin` records.

Grammar (raw token dump, E11; matches `import_donor_map.py::decode_placements`):

```
u32 15 | "GameObjectBegin"
lp_str category            ; "env" | "units" | "buildings" | "misc"
lp_str type                ; "field", "minegold", "pine1", "desert3", "polcen", "peatur", …
f32    x                   ; world X, tile units, −W/2..+W/2
f32    y                   ; height-bounded, exact meaning [U] (§7.3)
f32    z                   ; world Z, tile units, −H/2..+H/2
lp_str instance            ; "<type><n>.<uid>" e.g. "polcen0.15978"
lp_str type                ; repeat
lp_str category            ; repeat
lp_str owner               ; "env" | "player0".."player6" | "@pool" | "misc"
<packed runtime object state: u32s, flags, child names, mesh hint "<name>.mesh">
"GameObjectEnd"
```

The first two strings and the `(x,y,z)` triplet are **[O]**; `writenewp.inc:20` independently confirms the engine spawns at `(posx, 0, posz)` in ground mode. Everything after `owner` is a packed native state blob with no donor enum — **[U]**.

### 7.2 Which placements are terrain-relevant

| Class | bonmis1 (`env`, owner `env`) | turmis1 (`env`, owner `env`) | Terrain relevance for I02/I07 |
|---|---|---|---|
| Forest / trees | `pine1` 926, `firsmall1` 898, `pinesmall1` 781, `spruce1` 332, `fir` 234, `pinedry1` 233 | `palm` 770, `palmsmall*` 1,222, `desert1-5` 2,271, `palm1-5.*` 1,597 | Forest family, pattern-stamped; needs `type` + `x,z` |
| Understory / grass | `plantain` 719, `fern` 614, `grassforest.*` 385, `grass.*` 100 | `plantyellow` 2,025, `grassdesert.*` 336 | Mask-G forest class companion |
| Stone / quarry | `stones2-10` 111, `smallstones.1-6` 95 | `stonesdesert*` 79, `smallstonesdesert*` 95, `smallstonessea*` 56, `debris_stone` 88 | Stone mines family; F08/D07 ring→ore rule |
| Mines | `minegold` 14, `mineiron` 16, `minecoal` 17 | `minegolds` 10, `mineirons` 9, `minecoals` 11 | Gold/iron/coal per start; names match `F02 mng/mni/mnc` |
| Fields | `field` 206 | `field` 79 | Mill field runtime seeds (F07 49-node rule); decal spawned by `writenewp.inc:23-29` |
| Starts / players | buildings 39 (`polcen`, `ukrsta`, `eurmil`), units 396, owners `player0..player6` | buildings 245, units 724, owners `player0..player5`, `@pool` 220 | **Starts are player-owned units/buildings, not terrain tiles** |

Coordinate contract **[O]**: `miscext2.script:1627-1631` sets `minx=-GetMapWidth div 2`, `maxx=+…`, `minz=-GetMapHeight div 2`, `maxz=+…`; observed placement x/z ranges (bonmis1 ±156.5/−158…144.5) fit `±W/2`. For I02/I07 the portable fields are therefore **`category`, `type`, `x`, `z`, `owner`**; the middle float and the packed state are conditional.

### 7.3 The middle float — contradiction resolved as `[U]`, not guessed

- **Pass 1** suggested `y = sampled terrain height`: brute force over scale/offset/flip gave `r≈0.992–0.995`, MAE 0.01–0.02, best mapping `cell_x=W/2+x`, `row=W/2−z`, stride `W+1`.
- **Pass 2** refuted exactness: exact match only 11–30% of env placements; restricting to `|Y|>0.5` drops exact match to ≤0.001; `kingmusketeer` at x≈−142,z≈−142 has Y≈0.51–0.75 while the grid is `2.964` (z−) or `−1.05` (z+). Pass-1 `r` was inflated by the large mass of `Y=0` records over near-zero-height cells.
- **Pass 3**: the value is *height-bounded* — histogram peaks at `0.0` and exactly `±2.964` (E14), with continuous intermediates and occasional negative values (e.g. `smallstones.5` Y=−0.416, `grass.4` Y=−0.409), i.e. it is plausibly a vertical placement value sampled from *some* height field, possibly pre-smoothing or runtime-only.

**Verdict [U] CONFIRMED_UNVERIFIED**: "vertical placement value, bounded to the terrain-clamp range; exact grid binding and consumer not recovered." No field meaning is invented. Row sign (`W/2−z` vs `W/2+z`) also stays **[U]** as a *terrain* claim: it is suggested by pass 1 but contradicted by pass 2, and no GPU A/B exists.

### 7.4 DLC maps (F10's 49 baked maps, read-only)

`turmis1.map` (dlc3) was decoded but **not copied or run**. Its tile ids resolve through the repo ordinal mirror to names including `*_winter` while the file contains **zero** `winter` ASCII tokens (F10 E38, P14): **[D]** the ids are ordinals into a season-aware table, not embedded names; **[U]** the per-map `season` value (`TMapSettingsGen`, F10 U1) is not decoded. **[D] Implication:** the 2.877 GiB of DLC maps are a read-only *reference corpus* for baked placements and tile-id distributions, not skirmish-generation input (F10 §8.2).

---

## 8. What remains UNDECODABLE by static analysis, and why

| Bit | Label | Why static analysis cannot close it |
|---|---|---|
| Byte-12 consumer | **[U]** | Uniform 8-bit value; no donor enum, no X-ref from `sub_739d3c`/`sub_73a0b8` to a consumer; likely read by a runtime shader/sampler — needs a GPU frame or traced engine path |
| `FFFF` at `+5..6` and its sole record-0 exception | **[U]** | Looks like a `−1`/unset sentinel; no writer branch recovered that explains why cell (0,0) is exempt |
| `(2W)^2` tag-grid value enum (`0x07/0x0A/0x57/0x65/0x6D/0x6E` high bytes) | **[U]** | Values are ASCII-like, not a small enum; no tag table; `D04 U3` still open |
| 41-byte gap (`u32 256` + 37 zeros) at tag-grid end | **[U]** | Produced by sub-stream `FUN_007e6010` whose internals were not decoded (`D04 U5`) |
| −2 height-float shortfall cause | **[U]** | File count is authoritative but writer-loop/runtime trimming cannot be distinguished without executing/annotating the loader |
| Header `mk+27` high `u16 = 101` | **[U]** | Appears only as a constant in 15/37 maps; no producer/consumer in text or decoded native path |
| `+36` loader-set flag | **[O]** on disk / **[U]** purpose | `D04 §3.4` recovered the write/read but not what the flag gates |
| Packed `GameObjectBegin` state after `owner` | **[U]** | Native Delphi object image written verbatim (u32 flags, child names, `.mesh` strings); field boundaries depend on runtime classes, not on a public spec |
| Middle placement float exact binding | **[U]** | Bounded and height-like, but contradicted spatial match (§7.3); likely sampled before smoothing or from a runtime-only field |
| Per-map `season` in DLC maps | **[U]** | `TMapSettingsGen` field names only; values packed; zero `winter` token (F10 U1) |
| Row orientation / metres-per-cell for rendering | **[U]** | `miscext2.script:1627-1631` gives tile-unit bounds, but no donor GPU A/B fixes the mesh row sign or physical scale (D05 U1, V16) |
| Version-dependent 24-byte template path (`≥3`) | **[U]** | D04 U8: shipped maps all carry varied bytes `+8..12`, consistent with the raw path; no shipped example of the template path |

Donor execution is forbidden (`CHARTER.md:69`), so every one of these needs either a second native RE instrument or an owner-authorized runtime trace. None is guessed here.

---

## 9. Implications for spec §01 / §07 (PORT APPROXIMATION unless marked)

**spec/01 (world data model):**
1. §5's D04 note is **confirmed**, with one upgrade: the height count is now **[O] 37/37 maps = `(W+1)^2−2`**, decomposed as `W·(W+1)+(W−1)`; the `(W+1)^2` loop reading stays **[U]** as a *cause*. Decoders must anchor on the weight quad or use the observed count.
2. The `TMapTerrainDataTile` "collision Integer[4]" of §1 is **not** four flags in the on-disk 37-byte record: **[O]** the record holds no collision field; the collision-like data is the separate `(2W)^2` u32 grid, whose enum is **[U]**. Keep §1's struct as a *runtime/design* type, labelled PORT APPROXIMATION for on-disk fidelity.
3. §3's side-array list is **corroborated**: `owner` lives in GameObject records (`E12`), `fog` is global, `resource_id` lives in `ResourceBegin` blocks. Do not promote any of them into the tile record.
4. Add **[O]** donor coordinate contract `x,z ∈ [−W/2,+W/2]` in tile units (`miscext2.script:1627-1631`) and **[O]** `mapsize` enum `0→320,1→480,2→640,3→256` (`:19-26`); note shipped maps also carry W=512/384 (E4) — a size-source contradiction for COORD/I13.
5. **Correction** to D04 for the spec: `mk+27` is not a single `u32 64` field; it is `(u16 64, u16 0|101)` — **[U]** for the second half.

**spec/07 (resources — D07/F08 seam):**
6. Mine/forest/field/start placement is stored as `env`/player-owned GameObject records with `category+type+x+z+owner`, not in the terrain grid; the I02/I07 decoder should emit those five fields and leave the middle float / packed state **[U]**.
7. Type names in the records (`minegold/mineiron/minecoal`, `stones*`, `field`, `pine*/palm/desert*`) are the concrete join keys to `pattern.lib` object lists (F02/F08) and the 49-node mill-field rule (F07). Preserve them verbatim; do not re-derive a placement rule from the 37-byte record.
8. F10's baked DLC maps stay **read-only reference**; no per-map season decode is available, so any season choice in the port is PORT APPROXIMATION.

---

## 10. UNVERIFIED register

| # | Claim | Status | Passes attempted |
|---|---|---|---|
| U1 | Cause of `(W+1)^2−2` vs writer loop `(W+1)^2` | **[U]** | P2–P4 here + D04 P5/P7/P8; shifted-array hypothesis rejected |
| U2 | Byte-12 meaning / consumer | **[U]** | P6 (8 coordinate hashes ×256 offsets, entropy, autocorrelation) + D04 histogram |
| U3 | `FFFF` sentinel + record-0 exception | **[U]** | P5 full census; no enum/writer branch |
| U4 | Tag-grid value semantics | **[U]** | D04 P9 corrected histogram + DScript signature; no enum table |
| U5 | 41-byte gap producer | **[U]** | D04 save call sequence; `FUN_007e6010` undecoded |
| U6 | `mk+27` high u16 = 101 | **[U]** | P13 byte dump 3 maps + 37-map sweep; no producer |
| U7 | Placement middle float exact binding / row sign | **[U] CONFIRMED_UNVERIFIED** | P11 (accepted), P12/P13 (refuted), P14 histogram; no GPU frame |
| U8 | Packed GameObject state after `owner` | **[U]** | P10 raw token dump; native class layout not decoded |
| U9 | Per-map DLC season integer | **[U]** | F10 U1 + P14; zero `winter` token |
| U10 | `−1.1` height sentinel, physical metre scale | **[U]** | inherited D04 U6/V16; no A/B |
| U11 | Version-dependent 24-byte template path used by any shipped map | **[U]** | D04 U8; all shipped maps raw path |
| U12 | W=512 / W=640 vs DScript enum `{256,320,480,640}` | **[U]** contradiction | E4 (battle2/4/5 W=512) vs E10 `:19-26` (no 512) |

---

## 11. Open questions

1. **[U]** Will COORD fold the authoritative `(W+1)^2−2` count and the `mk+27` correction into `spec/01 §5` before I02's decoder is written?
2. **[U]** U12: are W=512 maps a legacy/battle-only format (so the DScript enum is not exhaustive), or does `mapsize` have an unrecovered value?
3. **[U]** Does any worker have a native X-ref for byte 12, or is it permanently runtime/shader-only? Until then it must stay opaque.
4. **[U]** The middle placement float needs a traced `GetHeightData`/spawn call (or a donor frame) before it can be named; should this be a D-lane ticket or left `[U]` permanently?
5. **[U]** Should I02 emit all four tile ids per cell with equal weights, or pick one subtile? Both are PORT APPROXIMATION; no weighting rule was recovered.
6. **[U]** F10 U1 (DLC season) and U7 (row sign) both need runtime evidence; no worker may close them from these bytes alone.

---

## 12. Compliance statement

No donor file was executed, copied into the repository, or committed. No Godot/runner job was submitted. No source, shader, config, asset, test, JSON, or git state was touched; this is the sole report authored by X29. Scratch scripts and outputs exist only under `%TEMP%\opencode\map_semantics\`. **No donor visual parity is claimed.**

---

## 13. Handoff summary (5 lines)

1. **[O]** 37-byte record re-verified across 3 deep scans + 37 map headers: 24+13 split, ids `+8..11`, quad `+16..31`, FFFF `+5..6` except record 0, byte 12 random; no owner/fog/resource/collision field in it.
2. **[O]/[D]** Authoritative on-disk height count is `(W+1)^2−2` in **37/37** maps (zero gap), shaped as `W·(W+1)+(W−1)`; the `(W+1)^2` loop remains a **[U]** cause, not the file count.
3. **[O]** `writenewp.inc`/`readnewp.inc` are network spawn packets and `serial.script` is a generic DScript save (`gDataVersion=92`) — **neither** serializes the tile record; owner/fog/resource/collision live in GameObject/Player/Resource/tag-grid structures instead.
4. **[O]/[D]** Placements are `GameObjectBegin` records with `category,type,x,y,z,instance,owner`; terrain-relevant classes are `env` (`field`, `stones*`, mines, forests, palms/desert*) with coordinate bounds `±W/2` tile units; the middle float is height-bounded but its grid binding is **[U]** after a refuted first pass.
5. **[U]** Eleven further items (byte-12 consumer, FFFF, tag enum, gap, header `u16 101`, packed state, DLC season, row/metre scale, W=512 contradiction) stay UNVERIFIED — packed/runtime-only; no parity claim.
