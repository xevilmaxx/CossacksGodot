---
id: DEC-U-GENSEED-DEEP
ticket: "TERRAIN-SWARM-2026-11-26 / DEC-U-GENSEED-DEEP full 1:1 Cossacks 3 donor port"
title: "Generation seed deep probe: packed CODE name search, seeder xrefs, 0x8326b8 consumer, shipped-map seed"
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_REPORT__NO_PARITY_CLAIM
owner_file: docs/terrain_swarm_2026-11-26/reports/DEC_U_genseed_deep.md
target: "t_87f0f3c130b0 — C:\\Games\\Cossacks 3\\cossacks.exe, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c (PRIMARY)"
labels: [O, D, U, "PORT INSTRUCTION"]
scope_guard: "Donor READ ONLY; no donor binary executed, copied, committed or debugged. No repo code/shader/config/asset/test/Godot/git edit. No Craft Anything brief/hypothesis/finding/unknown mutation. Exactly one repo file written: this report."
parity_claim: false
---

# DEC-U-GENSEED-DEEP — generation seed deep probe (new angles)

## 0. How to read / discipline

- **[O]** = bytes / import-name / disassembly re-read in this ticket (pinned `document:"t_87f0f3c130b0"` on every native call), or carried verbatim from `DEC_U_gen_seed.md` / `D02_seed_rng.md` with its evidence id.
- **[D]** = deterministic arithmetic consequence of [O].
- **[U]** = UNVERIFIED — do not implement as fact; exact breakpoint dump with zero-mismatch termination is given.
- **No donor GPU frame exists. No parity claim.**
- Pinned on every call: `core_session_show` → `active_target=t_87f0f3c130b0`, `analysis_mode=deep`, `clean_room=false` (re-checked this ticket). `editor.exe` (`t_68474ddde43f`) never opened.
- Prior accepted as [O] and not re-litigated: Delphi `Random(256)` LCG `state=(state*0x8088405+1) mod 2^32`, `out=state>>>24` (`ev_6478320b…`, `sub_403a0c` 9 insns); state slot `0x8f2008` file-image `00 00 00 00` (`ev_0e686c8c…` / this-ticket `ev_cf6f78a8…`); seeder `sub_4033b8` = QPC-low-dword else GetTickCount (`ev_78bcf9c8…` / this-ticket `ev_1b1de45e…`).

Multi-pass ledger (≤5 passes per oddity, owner rule):

| Lead | Pass 1 | Pass 2 | Pass 3 | Pass 4+ | Accepted |
|---|---|---|---|---|---|
| (a) packed CODE name search | `native_bytes_find Randomize/RandSeed/SetRandSeed/srand` → 0/0/0/0 hits each | `native_bytes_find QueryPerformanceCounter/GetTickCount` → 2+2 `.idata` hits | `native_bytes_find Random` → 81 CODE hits / `Rand` → 104 total (100 paged) | `GetTickCount64/timeGetTime/GetSystemTime` → 0 each | names absent in CODE/file-bytes [O, coverage-limited]; QPC/GTC thunks are the only two time imports the seeder uses [O] |
| (b) seeder xrefs + startup writers | `native_xrefs_list 0x4033b8` → 3 callers (unchanged) | `native_bytes_find 08 20 8F 00` → 7 hits (all accounted) | `native_xrefs_list 0x8f2008` → 2 data refs, both inside `sub_4033b8` | disassemble `sub_5936f8/sub_59c000/sub_8300d4` + thunk xrefs | no startup writer besides seeder [O, static]; generation-time value [U]+probe |
| (c) `0x8326b8` consumer | `native_function_find 0x8326b8/0x832727/0x83272f` → not inside any discovered function | `native_bytes_show 0x8326b8` 512 B + `0x832820` 256 B | decode call-shaped bytes against known `sub_403a0c` prologue | classify all 15 static `Random` callers | `0x8326b8` site is undiscovered-code [O]; one-draw-per-cell + last-writer-wins carried [O]; generation-time stream position [U]+probe |
| (d) shipped-map seed override | D02 `bonmis1.map:0x18c0f1=0x44a108f9` + `donewgame.inc:33-37` carried | no `.map` ships in this repo (`**/*.map` → 0 files) | no new byte-proven map-seed mapping in this ticket | — | override claim refuted as unproven; stays [U] with byte-dump probe |

## 1. Evidence register (new in this ticket, all pinned `t_87f0f3c130b0`)

| Evidence id | Operation | Establishes |
|---|---|---|
| `ev_0d1ba7e8eabaa26c2a557a65d4ef55d1b6c8bf19d661d8e906bac6552ff0ef7d` | `native_bytes_find "Randomize"` limit 100 | 0 matches (utf8+utf16le) in file bytes [O, coverage-limited] |
| `ev_c0035a21090f5f027422cde497917d44541dbd3148735b3ba9cc8348269be9a7` | `native_bytes_find "RandSeed"` limit 100 | 0 matches [O, coverage-limited] |
| `ev_f1ea39ee5162d9fdbd14a4a2174885c61bd3ec388a1d23518c35a377e3d3e2b3` | `native_bytes_find "SetRandSeed"` limit 20 | 0 matches [O, coverage-limited] |
| `ev_4d53d8a2b54238e4b84903f1af9247892ecb31796791e4402256e94e5fc2e` | `native_bytes_find "srand"` limit 100 | 0 matches [O, coverage-limited] |
| `ev_8eaafb855dad2dcb00bb234dc0615454c3cbfc1b9239a5a8bce5fc41c2ba8a` | `native_bytes_find "QueryPerformanceCounter"` | 2 matches, both `.idata`: VA `0x907f00` (FO `0x4fd100`), VA `0x9084fc` (FO `0x4fd6fc`) [O] |
| `ev_65933877b3571d45e768e458a576b132f2bd93ae80a57b4b4d57cd7e6f` | `native_bytes_find "GetTickCount"` | 2 matches, both `.idata`: VA `0x907ef0` (FO `0x4fd0f0`), VA `0x908688` (FO `0x4fd888`) [O] |
| `ev_afe03dde8b58d9be1833638e3f71abcec75e2474624458e551a4a6c80156ab88` | `native_bytes_find "GetTickCount64"` | 0 matches [O, coverage-limited] |
| `ev_b7cb0b913856c9c3a9d2163278117818c891800bbe2a7faececb3ac8ae8fd0a1` | `native_bytes_find "timeGetTime"` | 0 matches [O, coverage-limited] |
| `ev_efd48e91209aad62301f245680300844a512bf92c9d3e8ee0a2a57a70a2b92a` | `native_bytes_find "GetSystemTime"` | 0 matches [O, coverage-limited] |
| `ev_2141bfb8a681ff9cf492e8de4161f5cc21ffe467f8c9979d731a6517dda0ba52` | `native_bytes_find "Random"` | 81 matches, all section CODE (e.g. `0x60199f/0x6019df/0x601a13/0x601a5b/0x601a93/0x601ad7` RTTI cluster, `0x60a662/0x60a68d/0x60a6b5/0x60a6e5/0x60a731` RandomExt API cluster, `0x69f4b5/0x69f511/0x69f567/0x69f5c7` GenerateMap cluster, `0x84179c…0x844c1c` map-gen cluster) [O] |
| `ev_f7fa4e3a02acbba00815dc222705d5a65bc1d3f7dc918fd2d0e916ad756ea79c` | `native_bytes_find "Rand"` | 104 total, 100 paged, same CODE distribution (superset of above; no `RandSeed` among them) [O] |
| `ev_1b1de45e0461ce2d069344910a60a706433510714ea26cd7dd17982cad666a67` | `native_function_disassemble 0x4033b8` | 15-insn seeder re-read: `call 0x401450 (QPC thunk)`; `je 0x4033d0`; `mov [0x8f2008],eax(QPC low)` else `call 0x401458 (GTC thunk); mov [0x8f2008],eax` [O] |
| `ev_6478320ba54b2ac3cd973aaffea0c78e31a97b729756fcca736e8e28840ced6d` (re-anchored `ev_f6a825e6d58c4990cb1d0f68f22113b6dc1fc1bfe2937ed79811ad495c9d15fa` raw 64 B at `0x403a0c`) | `native_function_disassemble 0x403a0c` + `native_bytes_show 0x403a0c` | LCG re-confirmed: `imul edx,[0x8f2008],0x8088405; inc edx; mov [0x8f2008],edx; mul edx; mov eax,edx` [O] |
| `ev_0d079d49e28b9db7ceb362bf7bb98e925e3e48be897307afef9e3419cd9aab16` | `native_bytes_show 0x4033b8` 64 B | raw seeder prologue/thunk bytes [O] |
| `ev_ae1405826dfa5859b067c9b6b43cc62e45ccdd8ce63bf49b1f4661bf1278239e` | `native_xrefs_list 0x4033b8` | 3 static callers, unchanged: `0x5937a0 (sub_5936f8)`, `0x59c011 (sub_59c000)`, `0x8300e5 (sub_8300d4)`; none is a generation reseed [O] |
| `ev_161e3a3cbcf028e3b15bfd1d0f49c4ec7896c99131b23e2ff43f02ba356f1855` | `native_xrefs_list 0x403a0c` | 15 static `Random` callers: `0x515be8,0x5937aa,0x59c8ca,0x710a1f,0x715fe1,0x716252,0x71a322,0x71d343,0x731a49,0x7c5a11/0x7c5ab9/0x7c5b68,0x7c5cf1,0x806ca2,0x8081e5`; high-VA `0x8326b8` tile-variant caller still undiscovered by the engine (static-tool limit) [O] |
| `ev_d0f75bc8edddf871876fdb759822b14f5c24927991f4f07d3e9f013dd9b0819b` | `native_bytes_find pattern "08 20 8F 00"` | 7 hits: `0x4033c9/0x4033d6` (seeder stores), `0x403a11/0x403a1c/0x403a2d/0x403a38` (LCG + neighbours), `0x8fcc0c` DATA (pointer table, not state) [O] |
| `ev_429265d621bd12776a4bbc34fe3cecd4e59efa6263898d6a148d4d464c98d36e` | `native_bytes_find pattern "6C 20 8F 00"` | 1 hit: `0x403a3e` (`0x8f206c = 2^-32` float scale of Delphi `Random()` float path `sub_403a28`) [O] |
| `ev_031d3a0a4183abfddc0f26191f49973180bfba819191dced5ea21f2550ee464e` | `native_xrefs_list 0x8f2008` | 2 data refs, both inside `sub_4033b8` (`0x4033c8`, `0x4033d5`); engine lists no `0x403a0c`-family data xref because that access is `[ebx+0x8f2008]` (ebx=0) immediate-form, covered by the pattern search above [O] |
| `ev_cf6f78a8a13ce64e18549d7907ffdd954814f417f293833a40e75e071ddcec2c` | `native_bytes_show 0x8f2008` 32 B | image `00 00 00 00 02 8d 40 00 …` (state word 0) [O] |
| `ev_0c0c3419a3ba1cf97956a20c439353949761a9a913f2417ff98be89c1eb93aa2` | `native_bytes_show 0x8f206c` 32 B | `00 00 00 00 00 00 f0 3d` + `… "Error…Runtime "` — float scale + adjacent Delphi RTL string, not a second seed slot [O] |
| `ev_22de716f8aae3d8504ef49bfc187e4235c584051e833495e8fb42c0b45c635c6` | `native_bytes_show 0x8326b8` 512 B | undiscovered-code prologue `55 8b ec 83 c4 ec 53 56 57 …` + `e8 e0 12 bd ff` call-shaped slot near the variant draw window [O] |
| `ev_0e0f8a6bbbd36993d85d5fafa13b5906e5ea2504eef1626d291a9944ada873c1` | `native_bytes_show 0x832820` 256 B | continuation of the same undiscovered region (variant-store tail + next setter prologue) [O] |
| `ev_a2ee858fdde53cc1b3a515896bdef8bee224ce7a36f449a513bc4fcfca646cde` / `ev_6056b9b2c5eaeade3a67456eedaf06a6548d727aa9f74c424ef5a595bc50b431` / `ev_9f6b32334c1cebd5b4dc38ff49b0653f306b7484e1f3a75d9f0518ed84dd528a` | `native_function_find 0x8326b8 / 0x83272f / 0x832727` | all three: "not inside any discovered function" (engine did not carve a function here) [O] |
| `ev_dfc2488e6b875241a200d623438a0f751a08827228830e7333b02691368a996e` | `native_function_disassemble sub_5936f8` 130 insns | startup/system init: `call 0x4033b8` at `0x5937a0`, then `Random(0x2710)` + 256-entry sin/cos table build (`call 0x403a28` loop `0x5937b9-0x593822`); not per-map [O] |
| `ev_f591fcb4addefeb5e79ee14057123ddd0b8b496f4522a0d20153df588494425e` | `native_function_disassemble sub_59c000` (head 2.5 KiB shown) | second `Randomize` caller: `call 0x4033b8` at `0x59c011` on an editor/map-geometry path (`call 0x59b780` grid tests follow); not on the `DoGenerate/SetTileIndex` path [O] |
| `ev_4570101bd534cca7f3225930024762b7e040a75fc4d542879c0c0d7f328c1f5b` (prior `ev_747dcea1…`) | `native_function_disassemble sub_8300d4` 171 insns | third `Randomize` caller: scatter/fill routine (`call 0x4033b8` at `0x8300e5`, then float-`Random` + `0x82eb00/0x82ee04/0x8308e8` field writes); not the `0x8326b8` tile path [O] |
| `ev_ea4a38c7947094e27901eec514ea07473e70e05a12f30b62703fa03efc03e18c` | `native_function_disassemble sub_806c74` (head) | representative static `Random` consumer shape: `mov eax,0x7fffffff; call 0x403a0c` at `0x806ca2`, `cdq; mov [esi+0x28],eax; mov [esi+0x2c],edx` — bounded-int draw, **not** the `mov eax,0x100` + `mov [edx+4],al` tile-variant shape [O] |
| `ev_b95bb7c1a9a080910d5305da3ddb19aad2329aa502eaa392da654280125e38a9` | `native_function_disassemble sub_808158` (head) | same bounded-int consumer shape at `0x8081e5` (`mov eax,0x7fffffff; call 0x403a0c`); object-construction path, not tile-variant [O] |
| `ev_32a4f01c77cd8d92eb11ed161cd653bf6c4c7ee1d1454812d7042c15dd2aded3` / `ev_77262360e700b123094350c42dbab22e4967cbaaec7920183440ea853f6277ec` / `ev_c290b31e218ae0dfaa859ce399ae66e75980f5617b7a83ed1d54e055f7149183` | `native_function_disassemble sub_515b34 / sub_59c810 / sub_710380` (heads) | further `Random` consumers are unit/AI/object paths (vtable `+0x2c/+0x3c/+0x44` calls; `0x59b7cc/0x82dff4` grid tests; `0x42e3c0/0x437030/0x737250` object wiring); none matches the `0x8326b8` fan-out prologue [O] |
| (inline, no evidence id returned) | `native_xrefs_list 0x401450 / 0x401458` | QPC thunk `0x401450` ← import `__imp_QueryPerformanceCounter (0x907254)`, → single static caller `0x4033bc (sub_4033b8)`; GTC thunk `0x401458` ← `__imp_GetTickCount (0x907250)`, → single static caller `0x4033d0 (sub_4033b8)` [O] |

Coverage caveat (applies to every zero-hit row): `file_bytes_only` — compressed/encrypted/packed regions and run-time-built data are not seen, so a zero-hit is not proof of absence. It is consistent with reseeding being native-only (no script string), not a proof.

## 2. (a) Packed CODE byte search — `Randomize` / `RandSeed` / `SetRandSeed` / `srand` / QPC / GTC

### 2.1 RTL reseed names are absent from file bytes [O, coverage-limited]

Four literal searches (utf8+utf16le, pinned `t_87f0f3c130b0`):

- `Randomize` → 0 matches (`ev_0d1ba7e8…`).
- `RandSeed` → 0 matches (`ev_c0035a21…`).
- `SetRandSeed` → 0 matches (`ev_f1ea39ee…`).
- `srand` → 0 matches (`ev_4d53d8a2…`).

[D]: there is no script-visible or import-visible RTL reseed string in the stored file bytes. Combined with §3 (the only static writer of `0x8f2008` is `sub_4033b8`), the Delphi tile stream has no second native reseed shape in static data. This extends — not replaces — prior `Randomize`/`RandSeed` zero-hits with `SetRandSeed`/`srand` and fresh evidence ids.

### 2.2 Time-source imports: exactly the two thunks the seeder uses [O]

- `QueryPerformanceCounter` → 2 `.idata` hits: `0x907f00` (FO `0x4fd100`), `0x9084fc` (FO `0x4fd6fc`) (`ev_8eaafb85…`).
- `GetTickCount` → 2 `.idata` hits: `0x907ef0` (FO `0x4fd0f0`), `0x908688` (FO `0x4fd888`) (`ev_65933877…`).
- `GetTickCount64` / `timeGetTime` / `GetSystemTime` → 0 each (`ev_afe03dde…`, `ev_b7cb0b91…`, `ev_efd48e91…`).

Thunk-level xrefs (inline results, §1): `0x401450` (QPC) is called from exactly one static site `0x4033bc` inside `sub_4033b8`; `0x401458` (GTC) from exactly one static site `0x4033d0` inside `sub_4033b8`. [D]: no other static caller taps either time source through those thunks. A run-time `GetProcAddress`-built time call would not appear here — hence [U] for the generation-time value, with the probe in §6.1.

### 2.3 `Random` / `Rand` CODE distribution (the table the blend/tick pattern could not give)

`Random` → 81 CODE hits (`ev_2141bfb8…`): the DScript `RandomExt/Random/GetRandomKey/SetRandomKey` RTTI cluster (`0x60199f…0x601ad7`, `0x601c8c/0x601cc4/0x6024e6`, `0x60a662/0x60a68d/0x60a6b5/0x60a6e5/0x60a731/0x60af2e`), the `GenerateMap*` cluster (`0x69f4b5/0x69f511/0x69f567/0x69f5c7`, `0x6a3b72`, `0x6baa85/0x6baad1`), and the map-generation script cluster (`0x84179c…0x844c1c`, `0x8057d4/0x8065a7/0x8067af/0x80800b`, `0x833009/0x837705/0x838478…`, `0x83e09c…`). `Rand` → 104 total (100 paged, `ev_f7fa4e3a…`), a strict superset — no `RandSeed`/`SetRandSeed` hides among the extra hits. This answers the "CODE tables like blend/tick" angle: the RandomExt family lives in CODE RTTI, and the RTL `Randomize`/`RandSeed` family does not appear at all.

## 3. (b) `sub_4033b8` callers and every startup writer of `0x8f2008` / `0x8f206c`

### 3.1 Caller set is closed at three, all non-generational [O]

`native_xrefs_list 0x4033b8` (`ev_ae140582…`) returns exactly the prior triple, re-verified this ticket:

1. `0x5937a0` inside `sub_5936f8` — process/system init: `call 0x4033b8` then `mov eax,0x2710; call 0x403a0c`, storing to `[0x8fcc0c]`-pointed slot, then a 256-entry sin/cos table loop over float-`Random` `0x403a28` (`ev_dfc2488e…`, 130 insns). [D]: startup table build, not per-map.
2. `0x59c011` inside `sub_59c000` — map-geometry/editor-shaped path (`call 0x59b780/0x82dff4` grid tests follow, `ev_f591fcb4…`). [D]: not on the `DoGenerate` / `SetTileIndex (0x8326b8)` path — it never reaches the tile fan-out prologue of §4.
3. `0x8300e5` inside `sub_8300d4` — scatter/fill routine (`call 0x4033b8`, then float-`Random` + `0x82eb00/0x82ee04/0x8308e8` writes, `ev_4570101b…` / prior `ev_747dcea1…`). [D]: not the `0x8326b8` tile path.

### 3.2 No other static writer of the state slot exists [O, static]

- Byte pattern `08 20 8F 00` (little-endian `0x8f2008`) → 7 hits (`ev_d0f75bc8…`): `0x4033c9/0x4033d6` (the two seeder stores), `0x403a11/0x403a1c/0x403a2d/0x403a38` (LCG body + immediate neighbours), `0x8fcc0c` DATA (pointer table holding `0x8f2008` as a value, not a store to it).
- Pattern `6C 20 8F 00` (`0x8f206c`) → 1 hit: `0x403a3e` (`ev_429265d6…`), the `2^-32` scale load of the float `Random()` path — a read, not a seed write.
- `native_xrefs_list 0x8f2008` → 2 data refs, both inside `sub_4033b8` (`0x4033c8`, `0x4033d5`; `ev_031d3a0a…`). The LCG's `[ebx+0x8f2008]` accesses (ebx=0) do not register as data xrefs, which is why the pattern search is the controlling enumeration.

[D]: the static corpus contains exactly one initialisation shape for the Delphi stream (`sub_4033b8`, QPC-else-TickCount) and zero per-map reseed shapes. Any claim of a per-generation Delphi reseed is refuted for the static corpus; a VM-dispatched hidden call would need a run-time trace to prove (probe §6.1). The `0x8f206c` slot is a constant (`2.3283064365386963e-10`), never a seed.

## 4. (c) The `0x8326b8` tile-variant `+4` byte consumer

### 4.1 What is byte-proven [O]

- `native_function_find` at `0x8326b8`, `0x832727` (`call 0x403a0c` site per PORT1TO1 §E.1), and `0x83272f` (`mov [edx+4],al` variant store) all return "not inside any discovered function" (`ev_a2ee858f…`, `ev_6056b9b2…`, `ev_9f6b3233…`). [O]: the engine did not carve a function here — the tile setter lives in undiscovered/jump-table-reached code.
- `native_bytes_show 0x8326b8` 512 B (`ev_22de716f…`) shows a standard setter prologue (`55 8b ec 83 c4 ec 53 56 57 …`), bounds/compare scaffolding, and a call-shaped `e8 e0 12 bd ff` slot inside the draw window; `native_bytes_show 0x832820` 256 B (`ev_0e0f8a6b…`) continues the region (variant-store tail + next setter prologue). Raw bytes step cleanly; no disassembly is invented where the engine has none.
- Carried [O] (PORT1TO1 §E.1, re-cited not re-carved): one `Random(256)` draw per accepted target cell (`mov eax,0x100` entry → `call 0x403a0c` at `0x832727` → `mov [edx+4],al` at `0x83272f`), up to four 24-byte records per u8 tile (2×2 a-outer/b-inner fan-out), last-writer-wins for `variant`.

### 4.2 State-advance timing [D] + whether it is the only generation-time Delphi draw [O→U]

[D]: by the LCG arithmetic, each accepted cell advances `0x8f2008` exactly once (`state=(state*0x8088405+1) mod 2^32`) and the stored byte equals `state>>>24` at that instant. The store at `+4` is therefore a pure function of the pre-draw state; there is no second draw per cell in the described shape.

Is it the only generation-time Delphi draw? Static answer: **no other `0x8326b8`-shaped (`mov eax,0x100` + `mov [edx+4],al`) consumer was found**, and every classified static `Random` caller uses a different shape:
`sub_806c74`/`sub_808158` draw `mov eax,0x7fffffff; call 0x403a0c; cdq; mov [esi+0x28/0x38],eax` (bounded-int object draws, `ev_ea4a38c7…`, `ev_b95bb7c1…`); `sub_515b34`/`sub_59c810`/`sub_710380` are unit/AI/object wirings (vtable/grid/helper calls, `ev_32a4f01c…`, `ev_77262360…`, `ev_c290b31e…`). The remaining 8 static callers were classified in prior tickets as non-tile paths. BUT the undiscovered region around `0x8326b8` could hide sibling draws, and run-time dispatch could add more — so "only generation-time Delphi draw" stays **[U]** with the counting probe in §6.2. No exclusivity is claimed.

## 5. (d) Shipped map seed — override or not?

Byte-proven facts only:

- Carried [O] (D02 §4.3–4.4, `DEC_06_map_formats.md §7.1`): `SetRandomExtKey64(k0,k1)` installs `state_lo=k1, state_hi=k0`; `GetRandomKey` returns `state_lo=randkey1`, embedded in the generated map filename (`donewgame.inc:37`); sampled version-13 maps place a large u32 at aligned word index 2, consistent with `randkey1` but mapping still [U] there.
- This ticket: workspace glob `**/*.map` returns **0 files** — there is no shipped map in the repo to byte-dump, so no override can be byte-proven here.
- No donor-text or binary evidence in this ticket shows a map-load path writing `0x8f2008`. The three static `Randomize` callers (§3.1) are startup/scatter paths, and the 11+3 generation reseeds all target the RandomExt stream, never the Delphi slot.

[D, narrow]: nothing in the static corpus supports "a shipped map embeds a seed that overrides process-start Delphi state." The claim is **refused as unproven** and stays **[U]** with the map-load probe in §6.3. No invented seed, no parity claim. A run-time trace that watches `0x8f2008` across map-load vs fresh-generation is the only admissible closer.

## 6. Still-[U] fields — each with a breakpoint dump and zero-mismatch termination

> Authorised debugger/trace worker only. Nothing here was run in this ticket (donor execution prohibited). Each probe restarts the process at least once (restart-changes-seed check) and terminates only on zero mismatches.

### U-SS — generation-time Delphi seed value (the `0x83272f` probe)

- Break at `0x83272f` (`mov [edx+4],al`). At the **first** hit of a fresh skirmish generation, dump u32 at `0x8f2008` **before** the `call 0x403a0c` at `0x832727` returns and the stored `al`. Log `(cell-corner, state-before, byte)` for the full `SetTileIndex` fan-out.
- **Terminate** when (i) every logged byte equals `state-before>>>24` with zero mismatches, AND (ii) the pre-first-hit state is recorded as that run's generation-time seed. **Restart-changes-seed check:** restart the process and regenerate the same menu map; the seed must differ (QPC-wall-clock proof). Same-process regeneration must continue the stream (no per-map reseed proof). Until then the port keeps `image 0 + NULL hook`, never wired to generation.

### U-ONLY — is the `0x8326b8` draw the only generation-time Delphi draw?

- Same `0x83272f` break plus hardware write-watch on `0x8f2008` for the whole generation. Count every state advance; attribute each to its return address (distinguish `0x832727` vs any other `call 0x403a0c` reached at run time).
- **Terminate** when the advance count equals the accepted-cell count with zero unattributed advances (then exclusivity is proven for that build/map), or the first unattributed advance's caller is recorded (then exclusivity is refuted with an address — either outcome closes the field).

### U-MAP — shipped-map seed override

- On an authorised host with a readable generated map (e.g. `game_v…k….map`): (1) dump `gMap.settings.gen.randkey0/1` at load; (2) watch `0x8f2008` across map-load; (3) regenerate from the same menu settings.
- **Terminate** when either (i) a map-load write to `0x8f2008` is captured with its source address (override proven, cite the writer VA), or (ii) `0x8f2008` is untouched by map-load across two map sizes while `randkey1` varies the RandomExt stream (override refuted, zero-mismatch on the untouched watch). No byte dump may be approximated.

### U-TIME — QPC-vs-TickCount branch taken at process start

- Break at `0x4033bc` (`call QPC thunk`): log `eax` (nonzero = QPC path, store `[esp]` low dword) vs `je 0x4033d0` taken (TickCount path, `call 0x401458`).
- **Terminate** when the taken branch and stored dword equal the post-`sub_4033b8` `0x8f2008` image with zero mismatch on two cold starts. Decides which wall-clock source seeded the run; never hard-code one.

### U-KEY — `GenerateMapRandKey` derivation (carried, tightened)

- Set two known menu seeds; dump `gMap.settings.gen.randkey0/1` before `initmapgen.inc:99` (`SetRandomKey(randkey1)`).
- **Terminate** when the menu-seed→`(key0,key1)` mapping is a byte-exact closed form or 1:1 table over the tested seeds. Port keeps two-word verbatim input until then.

## 7. Port change list (file/line; no edits made here)

Carried from `DEC_U_gen_seed.md §5`, deltas from this ticket marked **[NEW]**:

1. `variant3d/scripts/terrain_donor_delphi.gd` or `terrain_donor_gen.gd` Delphi hook (`delphi_state_hook`, `stats().delphi_rng`): keep `image 0` + NULL hook. **[NEW]** cite this ticket `ev_1b1de45e…` + `ev_ae140582…` + `ev_d0f75bc8…`: exactly one static init shape, two time thunks, no per-map reseed. Never wire `_stage_begin` to `_rng_delphi`.
2. RandomExt single-stream + `SetRandomExtKey64` key0-discard: keep. **[NEW]** cite `ev_2141bfb8…` CODE distribution as the RTTI anchor; RTL names stay absent (`ev_0d1ba7e8…`, `ev_c0035a21…`, `ev_f1ea39ee…`, `ev_4d53d8a2…`).
3. Time-source imports: informational only. **[NEW]** `0x907f00/0x9084fc` (QPC), `0x907ef0/0x908688` (GTC) are `.idata` names, never copied into the port; the U-TIME probe owns the branch question.
4. Tile-variant consumer: keep one-draw-per-cell + last-writer-wins labelling. **[NEW]** cite undiscovered-code evidence (`ev_a2ee858f…`, `ev_22de716f…`, `ev_0e0f8a6b…`) so a future function-carve does not silently change the draw count; U-ONLY probe gates any exclusivity comment.
5. Mask-pick draw, S1 gate, S0/`TerrainUpdate`, water fields, border/starts order, mines/forests, no `0x48/0x50` copy in the generator: unchanged from `DEC_U_gen_seed.md §5.2–5.8`; this ticket adds no new stage param, so no line changes beyond the citation updates above.

## 8. Bottom line

- **(a) NEW:** `Randomize`/`RandSeed`/`SetRandSeed`/`srand` → 0 file-byte hits each; `QueryPerformanceCounter`/`GetTickCount` → exactly the two `.idata` pairs the seeder's thunks use (`0x907f00/0x9084fc`, `0x907ef0/0x908688`); `GetTickCount64`/`timeGetTime`/`GetSystemTime` → 0 each; `Random` → 81 CODE hits anchoring the RandomExt RTTI distribution. No second reseed vocabulary exists in static bytes.
- **(b) NEW:** `sub_4033b8` callers re-verified closed at three (`0x5937a0` startup table, `0x59c011` geometry path, `0x8300e5` scatter path); `0x8f2008` has no other static writer (7-pattern hits all accounted; 2 xrefs both inside the seeder); `0x8f206c` is the `2^-32` scale constant, not a seed.
- **(c) NEW:** `0x8326b8/0x832727/0x83272f` sit in engine-undiscovered code (512 B + 256 B byte-reads step cleanly); one-draw-per-cell arithmetic stands, exclusivity stays [U] with a counting watch.
- **(d) NEW:** no shipped `.map` in the repo to byte-prove anything; no static writer ties map-load to `0x8f2008`; override claim stays [U] with a map-load watch probe.
- Every still-[U] field carries a breakpoint dump that terminates only on zero mismatches plus a restart-changes-seed check. No invented seed. No parity claim.

*End of DEC-U-GENSEED-DEEP. Files written: this report only. Donor read-only; no binary executed, copied or committed; no code, shader, config, asset, test, git, Godot or investigation-memory state changed. No parity claimed.*
