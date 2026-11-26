---
id: DEC-SMALL-corner-tag-writer
ticket: "TERRAIN-SWARM-2026-11-26 / DEC-SMALL corner-tag writer"
title: "Donor corner-tag writer: where the four tag bytes come from + uniform-tile rule"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY
owner_file: docs/terrain_swarm_2026-11-26/reports/DEC_SMALL_corner_tag_writer.md
targets:
  - "C:\\Games\\Cossacks 3\\cossacks.exe — t_87f0f3c130b0 (every native call pinned with document:)"
labels: [O, D, U]
parity_claim: false
scope_guard: "Donor READ ONLY. No donor executable run, copied, committed or modified. No repo code/shader/config/asset/test/git edit. No Godot job. Exactly one repo file written: this report."
---

# DEC-SMALL — corner-tag writer

## 0. Answer (narrow scope only)

1. **[O/D] The four corner tag bytes do NOT come from a per-cell scalar `tex` field.** They are the head (`+0..+3`) of the 24-byte cell record consumed through `sub_82ec5c`, and each byte is written by the native setter inner at `cossacks.exe:0x8326b8` (reached from DScript `SetTileIndex`). One setter call with source vertex `(r,c)` and tile `T` writes `T` into **one corner of each of up to four adjacent cell records**, with bounds checked on the target cell after subtraction. Evidence: `ev_a9224d…` (`0x83271f mov [eax+ebx],dl`), `ev_b97933…` (`0x83272f mov [edx+4],al`), `ev_785dae…` (`0x832727 call 0x403a0c`), `ev_ee40c6…` / `ev_f80b56…` (`sub_82ec5c`), `ev_d5ae5a…` + `ev_524ea5…` (`sub_812e34:0x812fca call 0x82ec5c`), `ev_2fd9bf…` (`SetTileIndex @0x6a2f12`), `ev_f36110…` (donor-text call sites).
2. **[D] Simplest donor-grounded rule for a uniform-tile cell:** if every setter source vertex covering cell `(r,c)` carries the same tile `T`, the cell record is `[T,T,T,T]` — i.e. `tag[0]=tag[1]=tag[2]=tag[3]=T`. There is no expansion arithmetic (no `mod/div`, no mask-table lookup) at write time; the mask/sort/LUT work happens later in the renderer `sub_812e34` on the final four tags.

**No donor visual-parity claim is made.**

## 1. Method and target discipline

- Pinned document `t_87f0f3c130b0` (`cossacks.exe`, sha256 `87f0f3c130b0…`) on every native call. No `core_target_open/select` call; global active target was left on `t_68474ddde43f` and never changed by this worker.
- Donor read as bytes/disassembly only; never executed/copied.
- Pass 1: `native_function_show` + `native_function_disassemble` for `sub_82ec5c` / `sub_82ebc0` / `sub_82ed00`.
- Pass 2: `native_instruction_show` + `native_cursor_forward` walks around `0x8326b8`, `0x8302b0`, `0x8305a0`, and `native_function_instructions_list` + `native_xrefs_list` for `sub_812e34`.
- Pass 3: `native_instruction_show` re-reads for citable ids (`0x83271f`, `0x83272f`, `0x832727`, `0x812fca`), `native_bytes_find` for `SetTileIndex`, `core_text_read` for `miscext.script`.
- No garbled pass required a retry; resolved within 3 passes. Prior `DEC_VIS_01` §3.2 `[U]` ("exact expansion from one source `tex` into four corner tags") is closed by the writer loop below.

## 2. Evidence register (this worker, pinned `t_87f0f3c130b0`)

| Evidence id | Source | Claim |
|---|---|---|
| `ev_f80b566f65384e901fc3f691eead991c72db8812a14a9b375588b4af935ce52e` | `native_function_show 0x82ec5c` | `sub_82ec5c` at `0x82ec5c`, 80 B, 7 blocks, 34 insns. |
| `ev_ee40c6c5a25d2ac5412a3765203835913a11cd51fa7a11cd3dcc39540776e42d` | `native_function_disassemble 0x82ec5c` | Copies 6 dwords (`rep movsd ecx=6`) with stride `ebx+ebx*2` / `*8` = `0x18`; OOB falls back to default at `[0x8fc33c]`. = 24-byte record getter. |
| `ev_fd57ee29b45f791255b3f6d60c6d79e036bdd06aadd036105cbfa758e2bb9fb` | `native_function_show 0x82ebc0` | `sub_82ebc0` at `0x82ebc0`, 76 B, 38 insns. |
| `ev_9786c249a962ff37f65e4b6a5146873d9c0c44ed085287e6b21d935aa3cfb859` | `native_function_disassemble 0x82ebc0` | Same bounds prologue, then `lea esi,[eax+ecx*8+8]` + 4×`movsd` = 16 B at record `+8` (four `u32` collision/tag values). |
| `ev_2844da7cf755f590944d27ed3701e543a635408fdf60473abb207434526d003` | `native_function_show 0x82ed00` | `sub_82ed00` at `0x82ed00`, 74 B, 38 insns. |
| `ev_7f6e758e054f58272457f381af1fafe293539963f65757befba01b41aa74d40b` | `native_function_disassemble 0x82ed00` | `imul ecx,ebx,0xd` stride + `mov eax,[eax+0x20]`, then 3×`movsd`+`movsb` = 13 B record getter; OOB default at `[0x8fc820]`. |
| `ev_5d88d52979590c1ca534415a4377ae948bbe703f9f5635ee39cdb4e018c6574f` | `native_function_show 0x812e34` | `sub_812e34` at `0x812e34`, 1395 B, 87 blocks. = terrain-cell renderer/producer. |
| `ev_2f2ab37bc1bd65997b358caca25d9648077edbf70d992ce4b95574897fa5670b` | `native_function_instructions_list 0x812e34` (516 insns) | Renderer body examined; mask/`0xf` compare at `0x8132e5` consistent with `DEC_VIS_01` §5.2. |
| `ev_d5ae5a9c47a4b7997e36e98f408d7c4bd2a04be9ebacc44e37c590e5c299e487` | `native_xrefs_list 0x82ec5c` | 10 referrers; `sub_812e34:0x812fca call 0x82ec5c` proves the renderer consumes the 24-byte record via this accessor. |
| `ev_524ea55a988da896e586ebe4086e979bf9af18ce5a26db012d0ed004cc76f4fc` | `native_instruction_show 0x812fca` | `call 0x82ec5c` — the exact renderer→record call site. |
| `ev_a9224d969a6bd841ea90b45826b602900bd8e964be318c72adfc769aa75721c1` | `native_instruction_show 0x83271f` | `88 14 18 mov [eax+ebx],dl` — corner store: tile byte `dl` into `tag[ebx]`. |
| `ev_785daea1d2d3e28382777e8c1acd7a5a947185a33af1328ca80d69773b4feb8d` | `native_instruction_show 0x832727` | `e8 e012bdff call 0x403a0c` after `mov eax,0x100` — Delphi `Random(256)` for the variant byte. |
| `ev_b9793342628dc8eb1492626459ecf04610978935fcf6894f6f55398d22b95be7` | `native_instruction_show 0x83272f` | `88 42 04 mov [edx+4],al` — RNG result stored at record `+4` (per-cell random/variant byte). |
| `ev_db71929d79a4b1b23b4e647f9d0bfa5ce41cd652302d8319309ab92711440951` | `native_instruction_show 0x8302b0` | `53 push ebx` — reader `FUN_008302b0` entry (builtin function index misses it; instruction read succeeds). Corroborates `DEC_VIS_01 ev_aacd86…` / `DEC_VIS_04` reader. |
| `ev_8257a3073164dc074ebb9c8c460a27a6b8e2ff74ee73b61326064eb8ac8f689a` | `native_instruction_show 0x8305a0` | `53 push ebx` — writer `FUN_008305a0` entry. Corroborates `DEC_VIS_01 ev_81b6d7…` serializer (full height grid, then 24+13 records). |
| `ev_2fd9bf5f96dc1814bedf076e79a32fad2798da51eb30d0b73edb7d758f6a90b8` | `native_bytes_find "SetTileIndex"` | 1 match in `CODE` at VA `0x6a2f12` (file offset `0x2a2312`). Plaintext API name lives in `CODE`, which is why data-section-only searches missed it. |
| `ev_f3611017e0c14f116e6b2d4666deee6f7d27a312652d6104eb64ce5b31c2011c` | `core_text_read miscext.script:1421–1480` | `_misc_SetDesert` loops `y=0..mapheight, x=0..mapwidth`, reads `GetTileIndex(x,y)` / `GetTileName(x,y)`, maps names, calls `SetTileIndex` — i.e. donor script call sites pass scalar tiles; the native setter does the corner fan-out. |

Walk details (same pinned target, ids above are the citable anchors): `0x8326b8 push ebp / mov ebp,esp …` → bounds checks via `call 0x50fba0` → `0x832701 mov eax,[esi+0x14]` / `0x832704 mov eax,[eax+edi*4]` (row pointer) → `0x83270a–0x832719` address math (`edx+edx*2`, `*8`, `+edx*2` = `col*0x18 + corner`) → `0x83271f` store → `0x832722 mov eax,0x100` → `0x832727` RNG → `0x83272f` variant store → `0x832739 call 0x83276c` terrain-changed callback → inner `inc ebx / cmp ebx,2` (`0x83273e–0x832742`) and outer `inc [ebp-0x10] / cmp 2` (`0x832744–0x83274b`): `a`-outer / `b`-inner 2×2 loop.

## 3. Where the four tag bytes come from

- **Storage:** `record24[cell].tag[0..3]` = bytes `+0..+3` of the `0x18`-stride array at terrain `+0x14`, read by `sub_82ec5c` (`ev_ee40c6…`) and consumed by the renderer at `0x812fca` (`ev_524ea5…`, `ev_d5ae5a…`).
- **Producer:** `0x8326b8` (setter inner behind DScript `SetTileIndex`, string at `0x6a2f12`, `ev_2fd9bf…`). Pseudostructure from the walk:
```c
// r = outer row vertex, c = inner col vertex, tile = u8
for (a = 0; a < 2; a++)
  for (b = 0; b < 2; b++) {
    rr = r - a; cc = c - b;
    if (0 <= rr < W && 0 <= cc < H) {
      record24[rr][cc].tag[a*2+b] = tile;   // 0x83271f
      record24[rr][cc].variant    = DelphiRandom(256); // 0x832727 -> 0x83272f
      TerrainChanged(rr, cc);               // 0x832739
    }
  }
```
- **Consequence for one cell:** with source-vertex field `T`, `cell[r,c].t0=T[r,c]`, `t1=T[r,c+1]`, `t2=T[r+1,c]`, `t3=T[r+1,c+1]` (same convention as `DEC_VIS_04` §4; native names them `r/c`, port maps `r=y, c=x`). Bounds are on the target cell, so source `r=W`/`c=H` can still write the last row/column; source `-1` writes nothing. `GetTileIndex` returns corner 0 only.
- **Not the source:** `sub_82ebc0` (`+8` collision/tag `u32[4]`), `sub_82ed00` (13-byte metadata tail), and the random byte at `+4` are separate channels; none of them synthesises the four tags. Donor text (`ev_f36110…`, plus `texturemap.inc` / `smoothtiles.inc` / `generatemap.inc` call sites cited in the task) selects scalar ids and calls `SetTileIndex` — the fan-out is entirely in the native loop above.

## 4. Simplest donor-grounded rule for a uniform-tile cell

- If all covering source vertices hold tile `T` (flat fill, or interior of a uniform region away from edges/sparse overwrites), then:
```text
tag[0] = T; tag[1] = T; tag[2] = T; tag[3] = T.
```
- The renderer then sees one distinct tag, emits one layer, and (per `DEC_VIS_01` §5.2) forces the alpha mask to zero/full for the base layer — i.e. no transition patch is inferred from `T` alone. Any rule deriving a transition mask from `tile_id` bits is therefore not donor-grounded.
- Variant byte `+4` is overwritten on every accepted setter hit (`ev_b97933…`), so its final value is last-writer history, not a function of `T`; for baked maps ingest it verbatim. Exact fresh-generation replay needs the ordered setter log plus the Delphi LCG state — **[U]** for the seed value from static bytes alone (algorithm proven in `DEC_VIS_04` §5; seed is QPC/tick-derived), but this does not affect the tag rule above.

## 5. Bottom line

The four corner tags are vertex-stamped copies of scalar `SetTileIndex` arguments, one corner per neighbouring cell, via `0x8326b8:0x83271f`. A uniform-tile cell is `[T,T,T,T]`. **No parity claim.**

*End of DEC-SMALL. Files written: this report only. Donor read-only; no binary executed/copied; no code, shader, config, asset, test, git or Godot state changed.*
