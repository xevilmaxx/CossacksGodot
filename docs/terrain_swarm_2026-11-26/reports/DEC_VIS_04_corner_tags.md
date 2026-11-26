---
id: DEC-VIS-04
ticket: "TERRAIN-SWARM-2026-11-26 / DEC-VIS-04"
title: "Native SetTileIndex/GetTileIndex, exact four-corner expansion, RNG and 24+13-byte terrain records"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__OPEN_QUESTION_RESOLVED
owner_file: docs/terrain_swarm_2026-11-26/reports/DEC_VIS_04_corner_tags.md
targets:
  - "C:\\Games\\Cossacks 3\\cossacks.exe — t_87f0f3c130b0 (primary, every native call pinned)"
  - "C:\\Games\\Cossacks 3\\editor.exe — t_68474ddde43f (independent cross-check only)"
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_claim: false
scope_guard: "Donor read-only. No donor executable run, copied, committed or modified. No repo code/shader/config/asset/test/git edit. No Godot job. Exactly one repo file written: this report."
---

# DEC-VIS-04 — native tile accessors and exact corner-tag producer

## 0. Executive summary

1. **[O] The DEC-VIS-01 open question is resolved.** DScript `GetTileIndex` and `SetTileIndex` are registered at `cossacks.exe:0x69bc72–0x69bc91` to native wrappers `0x6b1d0c` and `0x6b1d50`. The setter reaches `FUN_008326b8` (`0x8326b8`), which stamps one `u8` tile into **one corner of each of up to four adjacent 24-byte cell records**, not into a scalar per-cell tile array.

2. **[O] Exact corner expansion.** With native array indices `r` (outer row pointer) and `c` (inner `0x18`-stride column), `SetTileIndex(r,c,tile)` executes `a=0..1`, `b=0..1` and, when `0 <= r-a < W` and `0 <= c-b < H`, writes:
   - `record[r-a,c-b].tag[a*2+b] = tile`;
   - `record[r-a,c-b].variant = DelphiRandom(256)`;
   - terrain change callback `FUN_0083276c(r-a,c-b)`.

   Therefore a cell receives `t0=T[r,c]`, `t1=T[r,c+1]`, `t2=T[r+1,c]`, `t3=T[r+1,c+1]`. In port `x=column, y=row` terms: `t0=T(y,x)`, `t1=T(y+1,x)`, `t2=T(y,x+1)`, `t3=T(y+1,x+1)`.

3. **[O] The random byte is not DScript `RandomExt`.** It comes from the separate Delphi LCG at `DAT_008f2008`: `state=(state*0x8088405+1) mod 2^32`; `Random(256)=(state*256)>>32`, equivalently `state>>>24`. One draw occurs for every accepted cell write, in `a`-outer/`b`-inner order. The runtime seed is time-derived (`QueryPerformanceCounter`, fallback `GetTickCount`), so the exact generation-time byte stream is not reproducible from `randkey1` alone.

4. **[O] `GetTileIndex` returns corner 0 only.** It reads the 24-byte record and returns byte `+0`; no-map and out-of-bounds calls return `0` through the default record. `GetTileName` likewise resolves byte `+0` through the active preset table.

5. **[O/D] The 24-byte head and 13-byte tail are now correctly separated.** The head is `tag[4]`, `variant`, reserved `[3]`, `collision/tag u32[4]`. The tail is signed corner values `[4]`, corner flags `[4]`, override tile, override random, two signed control bytes, and a dirty flag. `SetTileIndex` does **not** write the tail.

6. **[D] Prior D04/X29 map offsets were eight bytes early.** The native writer writes the full `(W+1)^2` height grid. The correct tile starts are `bonmis1 0xACD4D1`, `engmis4 0xA97F40`, `battle1 0x1FB2922`, and DLC `turmis1 0x21F83F3`. The prior anchor `quad_pos-16` must be `quad_pos-8`. This removes the supposed two-float height shortfall and restores the native field offsets.

7. **[O] Shore/cliff/desert handling is script-level id selection, not native setter special-casing.** The active `texturemap.inc` paths choose shore/cliff/road ids and then call `SetTileIndex`; `_misc_SetDesert` performs an exact name-remap pass. No active donor script auto-promotes slope cells to `rockNvf/vs` or `sandNf/s`; those are separate preset/material variants.

8. **[O] Record13 is a separate terrain-metadata channel.** It is default-initialized, loaded/saved with its dirty byte, copied from 13-byte `.pattern` tag records during `CollisionStand` stamping, and modified by native terrain brush/cliff paths. It can supply a render-time per-corner override tile through `FUN_00830754`/`FUN_00830818`.

**No donor visual-parity claim is made.**

---

## 1. Target discipline and multi-pass method

- Primary document pin: `t_87f0f3c130b0` (`cossacks.exe`, SHA-256 `87f0f3c130b0…`).
- Comparison document pin: `t_68474ddde43f` (`editor.exe`, SHA-256 `68474ddde43f…`).
- No target-open/select operation was performed. The global active target was not switched.
- Donor binaries and maps were read as bytes only. Nothing was executed or copied.
- Read first: DEC-VIS-01 §§3/5 and its open question, D08, D05, X08, D04/X29, current `terrain_donor_data.gd` / `terrain_donor_gen.gd`, donor `common.inc/texturemap.inc`, `smoothtiles.inc`, `loadtextureterrainfrombitmap.inc`, `dmscript.global`, and `_misc_SetDesert` / `_misc_SetSeason`.

| Pass | Instrument | Result |
|---|---|---|
| P1 | Raw UTF-8 string search in full EXE, not data-sections-only | Found `SetTileIndex`, `GetTileIndex`, `MapGetTileIndexByTileBlock`, `MapGetTileBlockByTileIndex` in `CODE`. |
| P2 | Registration routine `sub_69a70c` instruction/xref pass | Recovered exact signature→implementation pairs. |
| P3 | Deep/Ghidra pseudocode of wrappers and inner accessors | Recovered setter/getter control flow and record indexing. |
| P4 | Sequential raw instruction/byte pass through `0x8326b8`, `0x830d8c`, `0x403a0c` | Confirmed corner store, RNG call/store, loop bounds and callback at opcode level. |
| P5 | Caller/xref passes | Connected DScript wrappers, serializer, renderer, pattern stamper and record13 writers. |
| P6 | Independent `editor.exe` registration + Deep pseudocode | `0x77cb00 → 0x9ae158` and `0x77cabc → 0x9aa51c` reproduce the same algorithms. |
| P7 | Corrected shipped-map byte census | Sampled all records of `bonmis1`, `engmis4`, `battle1`, DLC `turmis1`; verified corner-sharing invariants, random coverage and default record13 tails. |
| P8 | Donor text pass for shore/cliff/road/desert/winter/detail stages | Separated active id selection from commented/dead code and from native corner expansion. |

---

## 2. Evidence register

| Evidence id | Source | What it establishes |
|---|---|---|
| `ev_75655ff0fb3254af18dc40c20f41aab35e84b6272007195cabdcfb654203aa80` | raw bytes `SetTileIndex` @`0x6a2f12` | Plaintext API name exists in `CODE`. |
| `ev_b22eb04169f81fcb059cbd10f298b180603d0ebef3388ca214c783bde3abe738` | raw bytes `GetTileIndex` @`0x6a2ed2` | Plaintext API name exists in `CODE`. |
| `ev_f4962774508d007233c80ae41fdecfce8e0461c84103668421690cab10d7556e` | `sub_69a70c` instructions | Registration pairs for get/set/name. |
| `ev_01e68ba07c62ad319de282d8be53d7ddbe95588e64e0715b24a46d52d5df28f8` | cstring `0x6a2ec8` | `function GetTileIndex(const i, j: Integer): Integer`. |
| `ev_ae997a291e899f41d8c54e16e87fffc59eb9711e6e5450018340360f14217fca` | cstring `0x6a2f08` | `procedure SetTileIndex(const i, j, tile: Integer)`. |
| `ev_3a438f86b7d022a94886a5d2fd884852247768c56319fb6032baebdaf283499e` | Deep `FUN_006b1d0c` | Get wrapper returns byte 0; no-map default 0. |
| `ev_a6b46bec244a20c87d89b44c8d40753b25f1e7eefc36533bcf2a3c035179cf10` | Deep `FUN_006b1d50` | Set wrapper narrows tile to `u8`, calls `0x8326b8`. |
| `ev_51f0077b64a45cd92898a9a27f15e1ba92653503ed8add5417ed3e757064b8b1` | Deep `FUN_008326b8` | Exact four-corner loop, bounds, RNG and callback. |
| `ev_a9224d969a6bd841ea90b45826b602900bd8e964be318c72adfc769aa75721c1` | `0x83271f` bytes `88 14 18` | Corner store `mov [eax+ebx],dl`. |
| `ev_785daea1d2d3e28382777e8c1acd7a5a947185a33af1328ca80d69773b4feb8d` | `0x832727` | `call 0x403a0c` after `eax=0x100`. |
| `ev_b9793342628dc8eb1492626459ecf04610978935fcf6894f6f55398d22b95be7` | `0x83272f` bytes `88 42 04` | Random result stored at record `+4`. |
| `ev_208b3390071b3de605c0cef1d0f4e4f006bec5976cf64e7a112518da8d28af3e` | Deep `FUN_00403a0c` | Delphi LCG and high-word range reduction. |
| `ev_e01e051addba0e97ed6cb28a060699f2516219fa340b8ed3a824c0c09e0d4440` | `sub_403a0c` assembly | `imul 0x8088405`, `inc`, `mul`, return `edx`. |
| `ev_7ad151c373f66e45e203b254f99b399d394d0fb09dcab3f7d8d8f71d5dbf0e10` | Deep `FUN_004033b8` | Runtime seed from QPC/GetTickCount. |
| `ev_1448daf1ad44f13b0a25cc51de466337042c1a6d16bb11ae5a76cbe5c1f39439` | Deep `sub_82ec5c` | 24-byte getter; default record on OOB. |
| `ev_a0fffbc44358b8a5f1ba5a91989641647cf547b6668b23de19bd60183bb7a0fb` | Deep `sub_82ebc0` | Four `u32` collision/tag values at `+8..+23`. |
| `ev_723448b3c04d6ac6203e9d435fc63d5afb85fbb67b95efdb77bb73226cc43055` | Deep `sub_82ed00` | 13-byte getter and default tail. |
| `ev_76b1bf7919baa40d1ae0b901c1a61ad737ef4e793e98b4fb7253c62b5ff5993f` | Deep `sub_82ed4c` | 13-byte setter, LOD invalidation and dirty flags. |
| `ev_8c6f4c757858038a105605abcc7e12ba876e8f0aec57e2c536714f518e5450da` | Deep `FUN_008305a0` | Native writer: full height grid, then 24+13 records; clears tail `+12`. |
| `ev_2acfe0798bdb32d3b1f0265b17e0bb7c411a02fb22a298d28ddb34da2f654b55` | Deep `FUN_008302b0` | Native reader; sets tail `+12=1`. |
| `ev_c702cb6dcf6bbde1384e295e248e523d506677fbb17ea4317c391ae8c7d9e68c` | Deep `sub_739d3c` | `TerrainMapBegin` save path reaches terrain serializer. |
| `ev_e0380cc31dbcaf8718e23027d241ac706a825c4022d515d3fbf52046508e5ebf` | Deep `FUN_0080fb2c` | Save wrapper calls `FUN_008305a0`. |
| `ev_182e07c11349dea8e9b0963f2334cdc3354a3f74e0a48eb8f7ad8ff53c160c36` | Deep `FUN_00830d8c` | Brush writes record13 corner, override, random and dirty byte. |
| `ev_dd12983d19d7564e32f9ad43d9809b8ac8990a868362f9a5a235b3fa0ce1bca0` | Deep `FUN_00830c68` | Brush increments a record13 corner and rewrites override/random/dirty. |
| `ev_ed6fdb770bace4f949bbf61dc5ee5ed2f0a9c848e3aef80ad3876477c65116ec` | Deep `FUN_00755c6c` | Pattern record13 first eight bytes rotate with pattern angle. |
| `ev_c176cc8193528500a8f570e5f914c7bf4ecccf5424bbe81125f92a78de2a3237` | Deep `sub_755f30` | `CollisionStand` pattern copy reaches `FUN_00755010`. |
| `ev_474e395c8291c9bfc5be8575d2fea48353f2057eabfe911a4acf54a4655e4093` | Deep `FUN_00830754` | Render-time corner override lookup. |
| `ev_65baa8fc53d8e99d98611ccc5c39209946e391722b372f9fc549686a8cb18db7` | Deep `FUN_00830818` | Record13 `+8` override selection/fallback. |
| `ev_ceb19ad83d1757d17a40c3bf90f356b087c69d4795c476afc868385529b0a657` | Deep `sub_812e34` | Final four tags are distinct-sorted and reduced to occupancy mask. |
| `ev_2520569326606c976e6dedce9f9d3dc69177a2ed226c46eb8115cebe1494955b` | editor `FUN_0077cabc` | Independent getter wrapper. |
| `ev_132a513a05e323010c5324c8f08cc601e78631461ef434ae9989d871f06c5815` | editor `FUN_0077cb00` | Independent setter wrapper. |
| `ev_3aa21b6ac10018bebaf2ca4d02f5833ef846ec66547cb19a7f7c593c464f303e` | editor `FUN_009ae158` | Same four-corner setter algorithm. |
| `ev_38f834d004f8bc9a42b50c5e7a75da9147cddd6abd8669e1544986aeda537aa1` | editor `FUN_009aa51c` | Same 24-byte getter/default behavior. |

Direct donor map/path offsets and byte census results are listed in §7; they are observations from read-only byte reads, not runtime execution.

---

## 3. Native DScript accessor path

### 3.1 Registration pairs

`sub_69a70c` uses the repeated pattern `mov ecx,<implementation>; mov edx,<signature>; call [esi+0x30]`:

| API | Signature VA | Registration site | Implementation VA |
|---|---:|---:|---:|
| `GetTileIndex` | `0x6a2ec8` | `0x69bc72 / 0x69bc77` | `0x6b1d0c` |
| `SetTileIndex` | `0x6a2f08` | `0x69bc83 / 0x69bc88` | `0x6b1d50` |
| `GetTileName` | `0x6a2f44` | `0x69bc94 / 0x69bc99` | `0x6b1d84` |

The earlier data-section-only searches missed these because the literals are in `CODE`.

### 3.2 Getter

Deep pseudocode, normalized:

```c
u8 GetTileIndex(i, j) {
    if (no_map) return 0;
    record24 r;
    Get24(terrain, i, j, &r);
    return r.byte0;
}
```

`FUN_0082ec5c` indexes `row[i] + j*0x18`. If `i<0 || i>=W || j<0 || j>=H`, it copies the 24-byte default at `PTR_DAT_008fc33c -> 0x8f6164`; its byte 0 is zero. There is no clamping and no majority vote over four corners.

### 3.3 Setter wrapper and inner operation

```c
void SetTileIndex(i, j, Integer tile) {
    if (no_map) return;
    SetTileIndexInner(terrain, i, j, (u8)tile);
}
```

The native integer is truncated to `u8`; there is no native `[0,123]` validation.

```c
void SetTileIndexInner(Terrain *t, int r, int c, u8 tile) {
    for (int a = 0; a < 2; ++a) {
        for (int b = 0; b < 2; ++b) {
            int rr = r - a;
            int cc = c - b;
            if (0 <= rr && rr < t->W && 0 <= cc && cc < t->H) {
                Record24 *p = &t->record24[rr][cc];   // row ptr + cc*0x18
                p->tag[a*2+b] = tile;                // 0x83271f
                p->variant = DelphiRandom(256);      // 0x832727 -> 0x83272f
                TerrainChanged(t, rr, cc);           // 0x832739 -> 0x83276c
            }
        }
    }
}
```

`TerrainChanged` is an indirect callback, gated by `*(word *)(terrain+0x42) != 0`; it is a notification, not a record13 writer.

### 3.4 Independent editor cross-check

`editor.exe` registers the same signatures in `sub_7654e8`:

- `0x766a4e/0x766a53`: `GetTileIndex` → `0x77cabc`;
- `0x766a5f/0x766a64`: `SetTileIndex` → `0x77cb00`.

The inner editor functions `FUN_009ae158` and `FUN_009aa51c` reproduce the same corner loop, bounds checks, `Random(256)` store at `+4`, callback, and byte-0 getter. This is independent binary corroboration, not a reused cossacks.exe result.

---

## 4. Exact four-corner semantics

### 4.1 Coordinate convention

The native arrays use:

```text
record24[row_pointer_index][inner_index * 0x18]
```

To avoid ambiguous DScript `i/j` naming, this report calls them `r` and `c`. A port using `x=column`, `y=row` should map `r=y`, `c=x`.

For one setter call at source vertex `(r,c)`:

| `a` | `b` | Target cell | Corner offset |
|---:|---:|---|---:|
| 0 | 0 | `(r,c)` | `+0` |
| 0 | 1 | `(r,c-1)` | `+1` |
| 1 | 0 | `(r-1,c)` | `+2` |
| 1 | 1 | `(r-1,c-1)` | `+3` |

Thus, for a completed source field `T`, each cell is:

```c
cell[r,c].t0 = T[r,c];
cell[r,c].t1 = T[r,c+1];
cell[r,c].t2 = T[r+1,c];
cell[r,c].t3 = T[r+1,c+1];
```

This is why four adjacent cells contribute to the visual corner at a shared vertex.

### 4.2 Map-edge behavior

- Bounds are checked on the **target cell after subtraction**, not on the source vertex.
- Source `r=W` or `c=H` can still write the last row/column through `a=1` or `b=1`.
- Source `r=-1` or `c=-1` produces only out-of-bounds targets and writes nothing.
- There is no clamping, wrapping or replication.
- `GetTileIndex(W,*)` / `GetTileIndex(*,H)` is out of bounds and returns default `0`, even though `SetTileIndex(W,*)` / `SetTileIndex(*,H)` can affect edge cells.

This distinction matters because `texturemap.inc` uses inclusive `0..GetMapWidth` / `0..GetMapHeight` selection loops, while `smoothtiles.inc` writes back `0..GetMapWidth-1` / `0..GetMapHeight-1`.

### 4.3 Random-byte write order

For every accepted target, the setter overwrites `record+4`. It does not preserve a previous variant. Therefore the final variant is a property of the **last accepted setter call affecting that record**, not of the final tile id alone.

For a complete row-major source sweep `r=0..W`, `c=0..H`, the last writer of every cell is source `(r+1,c+1)` with `(a,b)=(1,1)`. For a `0..W-1` / `0..H-1` sweep, right/bottom edge records have different last writers. Sparse later passes such as the detail bitmap or desert remap can change the history again.

**Implementation consequence:** a scalar final tile grid is sufficient to reconstruct the four tags, but not the random byte. Exact variant replay requires the ordered setter-call log and the Delphi RNG state.

---

## 5. Random/variant source

### 5.1 Exact algorithm

`FUN_00403a0c(range)`:

```c
u32 state = DAT_008f2008;
state = state * 0x8088405u + 1u;       // modulo 2^32
DAT_008f2008 = state;
return (u32)(((u64)range * state) >> 32);
```

For `range=0x100`:

```text
variant = state >>> 24
```

Assembly facts:

- `0x403a0f`: `imul edx,[0x8f2008],0x8088405`;
- `0x403a19`: `inc edx`;
- `0x403a1a`: store state;
- `0x403a20`: `mul edx` with `eax=0x100`;
- `0x403a22`: `mov eax,edx`.

### 5.2 Seed and stream separation

- `DAT_008f2008` is initially zero in the executable image.
- `FUN_004033b8` reseeds it from `QueryPerformanceCounter().LowPart`, falling back to `GetTickCount()`.
- This is **not** DScript `RandomExt` at `0x9048d4/0x9048d8` and is not seeded by `SetRandomKey` / `SetRandomExtKey64`.
- The exact Delphi RNG state at an arbitrary donor generation point is therefore **[U]** from static bytes alone.

For a baked-map port, read `record+4` verbatim. For fresh generation, a deterministic substitute seed may be used only as an explicit **PORT APPROXIMATION**; it must not be described as donor RNG replay.

---

## 6. Correct 24+13-byte record layout

### 6.1 Flat 37-byte on-disk record

| Flat offset | Size | Field | Confidence / notes |
|---:|---:|---|---|
| `0..3` | 4 | corner tags `t0,t1,t2,t3` | [O] setter and renderer agree |
| `4` | 1 | random/variant byte | [O] Delphi `Random(256)` |
| `5..7` | 3 | reserved | [O] zero in all sampled maps; setter does not clear them |
| `8..23` | 16 | four `u32` collision/tag values | [O] `sub_82ebc0`; default `1.0f` each; **not blend weights** |
| `24..27` | 4 | record13 signed corner values | [O] min/max/normalize helpers and brush writers |
| `28..31` | 4 | record13 corner flags | [O] indexed as 2×2; exact flag enum semantics [U] |
| `32` | 1 | record13 override tile id | [O] `FUN_00830818` |
| `33` | 1 | record13 override random/variant | [O] brush writers |
| `34` | 1 | signed control/mode byte | [O] default `0xff`; exact name [U] |
| `35` | 1 | signed threshold/control byte | [O] default `0xff`; exact name [U] |
| `36` | 1 | dirty/loaded flag | [O] reader sets 1, writer clears 0 |

Default templates:

```text
record24 @0x8f6164:
00 00 00 00 00 00 00 00 00 00 80 3f 00 00 80 3f 00 00 80 3f 00 00 80 3f

record13 @0x8fab6c:
00 00 00 00 00 00 00 00 00 00 ff ff 00
```

### 6.2 Serializer

`FUN_008305a0` writes:

```c
write_u32(W);
write_u32(H);
for (r = 0; r <= W; ++r)
  for (c = 0; c <= H; ++c)
    write_f32(height[r][c]);          // full (W+1)^2

for (r = 0; r < W; ++r)
  for (c = 0; c < H; ++c) {
    write_bytes(record24[r][c], 0x18);
    record13[r][c].dirty = 0;
    write_bytes(record13[r][c], 0x0d);
  }
```

`FUN_008302b0` reads the same structure and sets `record13.dirty=1` after each tail read. A version-dependent raw/template path exists for the 24-byte head, but the shipped records sampled here carry the full head.

### 6.3 Correction to D04 / X29

The prior reports anchored the tile array at `quad_pos-16`. In the native record, the four `1.0f` collision/tag values begin at record `+8`, so the correct anchor is:

```text
tile_offset = quad_pos - 8
```

Consequences:

| Map | Prior reported tile offset | Correct tile offset | Height floats | Correct byte delta |
|---|---:|---:|---:|---:|
| `bonmis1.map` | `0xACD4C9` | **`0xACD4D1`** | `103041=(321)^2` | `0x64A04` |
| `engmis4.map` | `0xA97F38` | **`0xA97F40`** | `103041=(321)^2` | `0x64A04` |
| `battle1.map` | `0x1FB291A` | **`0x1FB2922`** | `148225=(385)^2` | `0x90C04` |
| DLC `turmis1.map` | — | **`0x21F83F3`** | `103041=(321)^2` | `0x64A04` |

The native writer’s `(W+1)^2` loop is correct. The prior `(W+1)^2-2` “authoritative” count and the shifted claims “tags at +8..+11”, “random at +12”, and “weights straddle the 24/13 boundary” were artifacts of the eight-early anchor.

---

## 7. Shipped-map record sampling

All counts below are from corrected record starts and a 37-byte stride. No map was executed or modified.

| Map | Records | Distinct `(t0,t1,t2,t3)` tuples | Variant values present | Reserved/weight violations | Non-default record13 |
|---|---:|---:|---:|---:|---:|
| `bonmis1` | 102,400 | 9,207 | 256/256 | 0 / 0 | 0 |
| `engmis4` | 102,400 | 14,510 | 256/256 | 0 / 0 | 0 |
| `battle1` | 147,456 | 2,573 | 256/256 | 0 / 0 | 0 |
| DLC `turmis1` | 102,400 | 5,532 | 256/256 | 0 / 0 | 0 |

Representative records:

```text
bonmis1 rec0 head: 00 4f 4f 4f b2 00 00 00 | 00 00 80 3f ×4
bonmis1 rec0 tail: 00 00 00 00 00 00 00 00 00 00 ff ff 00

engmis4 rec0 head: 0a 49 0a 0a 79 00 00 00 | 00 00 80 3f ×4
engmis4 rec0 tail: 00 00 00 00 00 00 00 00 00 00 ff ff 00

battle1 rec0 head: 61 79 79 79 15 00 00 00 | 00 00 80 3f ×4
battle1 rec0 tail: 00 00 00 00 00 00 00 00 00 00 ff ff 00

turmis1 rec0 head: 61 79 79 79 39 00 00 00 | 00 00 80 3f ×4
turmis1 rec0 tail: 00 00 00 00 00 00 00 00 00 00 ff ff 00
```

### 7.1 Shared-corner invariant test

For interior cells, the exact setter geometry predicts:

```text
R[r,c].t0 == R[r,c-1].t1
R[r,c].t0 == R[r-1,c].t2
R[r,c].t1 == R[r-1,c].t3
R[r,c].t2 == R[r,c-1].t3
```

Results:

- `battle1`: zero mismatches for all four relations.
- `bonmis1`: zero for the first two; one `t2`/left-`t3` and three `t1`/up-`t3` exceptions, all on the right or bottom boundary.
- `engmis4`: zero for the first three; one `t1`/up-`t3` exception on the right boundary.
- `turmis1`: zero for the first three; three `t1`/up-`t3` exceptions, all on the bottom row.

These isolated edge exceptions are consistent with inclusive vertex-border writes followed by cell-range write-back or later sparse edits. They are not evidence for a different interior corner rule. An importer should preserve them, not “repair” them.

### 7.2 Record13 census

Every sampled base and DLC record has the default tail:

```text
+0..+9 = 0
+10 = 0xff
+11 = 0xff
+12 = 0
```

Thus the shipped maps do not exercise record13 corner values/flags or override tiles in their serialized tile arrays. Runtime object-associated override behavior remains a separate native path.

---

## 8. When record13 values/flags are written

`SetTileIndex` never writes record13. The observed native lifecycle is:

| Operation | Function path | Exact write |
|---|---|---|
| New/reset map | `sub_721850 -> FUN_0082ed4c(default)` | Fill every tail with `00×10 ff ff 00`. |
| Load | `FUN_008302b0` | Read 13 bytes, then set `+12=1`. |
| Save | `FUN_008305a0` | Set `+12=0`, then write 13 bytes. |
| Pattern stamp | `sub_755f30 -> FUN_00755c6c -> FUN_00755010 -> FUN_0082ed4c` | If `CollisionStand` (`pattern+0x82`) and occupancy byte is zero, copy the pattern’s 13-byte tag record; rotate bytes `+0..+7` with pattern angle; bytes `+8..+12` stay with the record. |
| Dirty/recalculate | `FUN_0080d024`, `FUN_0080d62c`, `FUN_0080ddd8`, brush wrappers `FUN_0080f4a8/5dc/710/848/978` | Set/clear `+12` while recalculating or invalidating render state. |
| Brush set corner | `FUN_00830d8c` | For a clipped 2×2 subcell block: write selected `+0..+3`, `+8=override_tile`, `+9=DelphiRandom(256)`, `+12=1`; call `FUN_00830bf8`. |
| Brush add corner | `FUN_00830c68` | Add a signed delta to selected `+0..+3`; rewrite `+8`, `+9`, `+12`; call `FUN_00830bf8`. |
| Clear one corner flag | `FUN_0080ec30` | Clear one of `+4..+7`, set `+12=1`, write through `FUN_0082ed4c`. |
| Threshold invalidation | `FUN_00830bf8` | If signed `+10>=0` and `+11 < max(+0..+3)`, set `+10=0xff` and `+12=1`. |

For `FUN_0082dff4(coord,0,...)`, the subcell neighborhood is:

```text
even coord: coord-1 .. coord
odd  coord: coord   .. coord+1
```

The corner index written is `(subrow & 1)*2 + (subcol & 1)`, matching the same 2×2 ordering as the 24-byte tags.

A census of direct `FUN_0082ed4c` callers found no routine that synthesizes `+4..+7` from a scalar tile id. Those flags originate in pattern payloads/defaults or are modified by terrain editing; inventing them during `SetTileIndex` would be wrong.

### 8.1 Render-time use of record13 `+8`

Before forming layers, `sub_812e34` calls `FUN_00830754` for each corner. That helper checks associated terrain objects and may replace the record24 tag with `FUN_00830818`:

```c
override = record13[cell].byte8;
if ((u8)override < 0x80) return override;
for each in-bounds cell in the 3×3 neighborhood:
    if ((s8)record13[neighbor].byte8 >= 0)
        return record13[cell].byte8;
return -1;
```

This is the native face/object override channel. It is distinct from script-level shore/cliff/desert id selection and from the four record24 tags themselves.

---

## 9. Shore, cliff, road, desert, winter and face overrides

### 9.1 Active shore selection

`texturemap.inc:433–528`:

- Gate: `gMapMask[ix,iy].b > 0` and (`height < -0.25` or `height < -0.1`).
- Gradient: `dirX=lh-rh`, `dirY=th-bh`; proceed only if length `>0.01`.
- Normalize; `VectorAngle(1,0,0,dirX,0,dirY)`, negate if `dirY<0`; shore adds `180`.
- Exact sector result:

| Post-angle window | Sector | Tile |
|---|---|---|
| `[-22.5,22.5)` | `bR` | `sandsea6` |
| `[22.5,67.5)` | `bRB` | `sandsea6` |
| `[67.5,112.5)` | `bB` | `sandsea1` |
| `[112.5,157.5)` | `bLB` | `sandsea5` |
| `[157.5,202.5)` | `bL` | `sandsea6` |
| `[202.5,247.5)` | `bLT` | `sandsea6` |
| `[247.5,292.5)` | `bT` | `sandsea1` |
| otherwise | `bRT` | `sandsea5` |

Then append `_winter` when `GetSeasonType=2`, resolve by name, and call `SetTileIndex`. The native setter does not know this is a shore.

### 9.2 Active cliff/edge selection

`texturemap.inc:557–608`:

- Trigger: `x=GetMapWidth` or `y=GetMapHeight` or `GetMapCollisionTagInRadius(realx,realy,0,False)>0`.
- Uses the **pre-angle**; first matching window wins:

| Pre-angle window | Face | Tile before height override |
|---|---|---|
| `[22.5,67.5]` | `bRB` | `rock4` (`rock6` assignment is commented) |
| `[120,170]` | `bLB` | `rock7` |
| `[-45,45]` | `bR` | `rock4` |
| `[45,135]` | `bB` | `rock1` |
| `[-135,-45]` | `bT` | `rock4` |
| otherwise | `bL` | `rock3` |

Height overrides, in order:

```text
Abs(height) > 2.7 -> rock8
Abs(height) > 2.4 -> rock4
Abs(height) < 0.1 -> no write
```

Then winter suffix and `SetTileIndex`.

### 9.3 Roads

`texturemap.inc:617–642`, only where `gMapMask[x,y].broad`:

```text
first RandomExt draw  > 0.5 -> ground1
otherwise second draw > 0.25 -> test2
otherwise                 -> test3
```

There are two DScript RNG draws on the non-`ground1` branch. These draws are separate from the Delphi RNG used for record24 `+4`.

### 9.4 Smoothing and detail write-back

- `smoothtiles.inc` runs three horizontal-then-vertical in-place passes and then calls `SetTileIndex(i,j,atilemap[i,j])` for `0..GetMapWidth-1`, `0..GetMapHeight-1`.
- This is not a direct scalar-array write in the donor: every cell write can change four neighboring records and consumes up to four Delphi RNG draws.
- `loadtextureterrainfrombitmap.inc` is entirely commented. If enabled as authored intent, it selects low/high BMP by `h<0.1`, computes `tex=floor(r*255) div 2`, and writes only cells whose `GetTileIndex(x,y)==0` and resolved tile name is non-empty.

### 9.5 Desert remap

`_misc_SetDesert` (`miscext.script:1427–1543`) loops `y=0..mapheight`, `x=0..mapwidth`, reads **only** `GetTileIndex(x,y)` / `GetTileName(x,y)` (corner 0), applies this exact active map, resolves the new name, and calls `SetTileIndex` only when the new index is `>=0`:

| Old name | New name |
|---|---|
| `grass1` | `sandsea5` |
| `grass3`, `grass5` | `test22` |
| `grass7`, `grass8` | `desert6` |
| `ground1` | `test16` |
| `test2`, `test1`, `test3` | `ground1` |
| `grass2`, `test7`, `test8` | `desert11` |
| `grass_ground1`, `grass_ground3` | `desert11` |
| `grass_ground2` | `sandsea5` |
| `rock1` | `desert2` |
| `rock3`, `rock4` | `sandrock6` |
| `rock5` | `test22` |
| `rock7` | `desert4` |
| `rock8` | `test22` |
| `rock9` | `test23` |
| `test0`, `test4`, `test12` | `sandsea5` |
| `test6`, `test13` | `sandsea6` |
| `test9` | `desert6` |
| `test14` | `desert11` |
| `sandrock2` | `sandsea6` |
| `sandrock3`, `sandrock4` | `sandsea5` |
| `grass10`, `test11`, `grass6`, `grass9`, `test5` | `sandsea1` |
| `alpha0a` | `alpha0c` |

Special override after the case:

```text
oldnam == rock8 AND 0.1 < h < 2.9 AND (h > 1.8 OR h < 1) -> desert2
```

There is no desert RNG draw. The routine may also multiply non-water height by `0.8` when `bModifyHeight` is true, but that is a height operation, not part of corner-tag expansion.

### 9.6 Winter and face ids

- `texturemap.inc` appends `_winter` to shore/cliff/road names when `GetSeasonType=2`.
- `_misc_SetSeason` swaps `alpha0a` ↔ `alpha0b` across the inclusive map loop.
- `rockNvf/vs` and `sandNf/s` exist in `terrain.presets` / `tiles.lib` with separate material `refkey`s, but no active donor script was found that promotes a slope cell to those ids. Native `SetTileIndex` treats every `u8` identically.
- Therefore the legacy port’s slope→face-id promotion must not be presented as recovered active donor generation behavior. Record13/object override and explicit face ids are separate mechanisms.

---

## 10. Donor-shaped per-cell layer/mask producer

For a baked map, start with the serialized 24-byte head. For live generation, replay the ordered native-style setter calls so both tags and variant history are correct.

```c
ProduceCell(cell, record13, scene_objects):
    t[0..3] = record24.tag[0..3];
    variant = record24.variant;                  // +4, Delphi RNG byte

    for each corner k:
        if AssociatedOverrideObject(scene_objects, cell, k):
            t[k] = ResolveRecord13Override(record13, cell);  // 0x830754/0x830818

    distinct = sorted_unique(t);                // ascending, 1..4 entries
    for each id in distinct:
        mask = 0;
        if (id == t[0]) mask |= 8;
        if (id == t[2]) mask |= 4;
        if (id == t[1]) mask |= 2;
        if (id == t[3]) mask |= 1;

        if (distinct_count == 1 || id == distinct[0] || mask == 0xf)
            effective_mask = 0xf;              // base/full handling per producer
        else
            effective_mask = mask;

        alpha_patch = AlphaLUT(effective_mask, variant);
        EmitLayer(id, alpha_patch);             // DEC-VIS-01 §5 UV rules
```

The exact 16-pair alpha LUT is at `cossacks.exe:0x8f5d00` and is fully transcribed in DEC-VIS-01 §5.3. The important input is the **final four corner tags after record13/object override**, not `tile_id` bits.

---

## 11. Port gaps and concrete recommendations

### 11.1 Current gap

- `terrain_donor_data.gd` carries only `tex: PackedByteArray` plus four collision bytes. It has no four corner tags, variant byte or record13 channel.
- `terrain_donor_gen.gd` writes `data.set_tex(i,id)` directly for shore/cliff/default/desert-like selection, smoothing and detail. It does not model neighbour-corner writes or the Delphi RNG.
- `terrain_donor_mesh.gd` builds one scalar tile-id texture and one surface; it does not emit the donor’s 1–4 sorted distinct-tag layers per cell.

### 11.2 Recommended data model

Add, without replacing existing scalar diagnostics:

```text
cell.tags[4]                 u8[4]
cell.variant                 u8
cell.collision_tags[4]       u32[4]
cell.record13.values[4]      s8[4]
cell.record13.flags[4]       u8[4]
cell.record13.override_tile  u8
cell.record13.override_rnd   u8
cell.record13.control[2]     s8[2]
cell.record13.dirty          u8
```

Keep an optional ordered `set_tile_calls` log or a `vertex_tiles[W+1][H+1]` source field for fresh generation.

### 11.3 Setter and RNG

- Implement `set_tile_index(r,c,tile)` exactly as §4, including target-after-subtraction bounds and `a`-outer/`b`-inner order.
- Implement `get_tile_index(r,c)` as corner 0 with OOB/no-map default 0.
- Use a distinct Delphi LCG stream for `record24.variant`; never consume DScript `RandomExt` for it.
- For baked maps, ingest the stored variant. For fresh maps, expose the Delphi seed/state explicitly and label any deterministic choice **PORT APPROXIMATION**.

### 11.4 Importer correction

- Locate the four-`1.0f` collision/tag quad and set `tile_off = quad_pos - 8`.
- Read exactly `(W+1)^2` height floats before the tile array.
- Parse interleaved 24+13 records at stride 37.
- Preserve `+5..+7`, all collision values, record13 bytes and boundary exceptions verbatim.
- Update any diagnostics that still report tags at flat `+8..+11` or random at `+12`.

### 11.5 Generation and overrides

- Apply shore/cliff/road/desert/winter rules as id-selection stages before the native-style setter.
- Preserve the exact desert table and the two-draw road branch.
- Do not infer face ids from slope unless a separate donor source proves that promotion.
- Keep record13 initialization/pattern-copy/brush logic separate from tile-id assignment.

### 11.6 Renderer

- Carry four final tags and variant into the layer producer.
- Apply record13/object override only through the recovered conditions.
- Sort distinct tags ascending; compute mask bits `t0=8,t2=4,t1=2,t3=1`; use the exact alpha LUT and DEC-VIS-01 UV arithmetic.
- Emit one layer per distinct tag. Do not derive transition masks from `tile_id` bits.

### 11.7 Verification vectors

Add deterministic tests for:

1. One interior setter call changes exactly four records at offsets `0,1,2,3`.
2. Source `(W,H)` writes only the bottom-right edge cell(s); source `(-1,*)` writes nothing.
3. OOB getter returns 0; in-bounds getter returns corner 0.
4. Known Delphi LCG state produces expected `state>>>24` bytes in exact loop order.
5. Full `0..W-1` write-back leaves right/bottom variant history different from full `0..W` sweep.
6. Corrected map anchors and representative records in §7.
7. Interior shared-corner invariants; boundary exceptions remain unchanged.
8. Four distinct final tags produce four ordered layers and the expected occupancy masks.

---

## 12. UNVERIFIED register

| ID | Item | Status / next evidence |
|---|---|---|
| DEC-VIS-04-U1 | Exact Delphi RNG state at a donor generation start | **[U]** Algorithm is proven; seed is QPC/tick-derived and other engine calls consume the same stream. Need runtime capture or a donor-provided seed. |
| DEC-VIS-04-U2 | Full semantic names/enums for record13 flags `+4..+7` and controls `+10/+11` | **[U]** Byte accesses and several behaviors are proven; no authoritative field-name table recovered. |
| DEC-VIS-04-U3 | Exhaustive indirect writers of record13 flags | **[U]** All direct `FUN_0082ed4c` callers and the direct `0x830d8c/0x830c68` writers were censused; computed/indirect paths are not proven absent. |
| DEC-VIS-04-U4 | Runtime activity of commented `texturemap.inc` / `smoothtiles.inc` / detail text | **[U]** Donor execution forbidden. Authored intent is exact; live execution not observed. |
| DEC-VIS-04-U5 | Any packed `.bind` alternate tile API implementation | **[U]** Main EXE path and independent editor path agree; packed-code absence is not proven. |
| DEC-VIS-04-U6 | Final global draw-pass ordering after display-list/material grouping | **[U]** Per-cell producer order is proven; global runtime grouping remains outside this worker. |
| DEC-VIS-04-U7 | Donor visual parity | **[U]** No donor GPU A/B frame; no parity claim. |

---

## 13. Bottom line

The donor does not expand a tile id by assigning one id to a cell. `SetTileIndex` treats the id as a **vertex/source value**, stamps it into the matching corner of up to four neighboring cell records, and refreshes each affected record’s variant from a separate time-seeded Delphi LCG. `GetTileIndex` exposes only corner 0.

The 24-byte record head and 13-byte metadata tail are distinct. Record13 is initialized, serialized, pattern-stamped and brush-edited independently; it can override a corner at render time but is not produced by `SetTileIndex`. Shore, cliff, road, desert and winter behavior is script-level id selection before the setter, not hidden native tile-id arithmetic.

The prior map reports’ eight-early tile anchor also explains their apparent two-float height shortfall. With the corrected anchor, the native writer’s full `(W+1)^2` height grid and the 24+13-byte record layout agree exactly with shipped map bytes.

A donor-shaped port therefore needs four corner tags plus the ordered variant history, not another scalar tile-id approximation. **No parity claim is made.**

*End of DEC-VIS-04. Files written: this report only. Donor read-only; no binary executed/copied; no code, shader, config, asset, test, git or Godot state changed.*
