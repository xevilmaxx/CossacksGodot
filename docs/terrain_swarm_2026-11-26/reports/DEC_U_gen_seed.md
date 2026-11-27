---
id: DEC-U-GEN-SEED
ticket: "TERRAIN-SWARM-2026-11-26 / DEC-U-GEN-SEED full 1:1 Cossacks 3 donor port"
title: "Generation LCG seed source, renderer+0x40 callback / 0x48 producer, and still-[U] stage params"
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_REPORT__NO_PARITY_CLAIM
owner_file: docs/terrain_swarm_2026-11-26/reports/DEC_U_gen_seed.md
target: "t_87f0f3c130b0 — C:\\Games\\Cossacks 3\\cossacks.exe, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c (PRIMARY)"
labels: [O, D, U, "PORT INSTRUCTION"]
scope_guard: "Donor READ ONLY; no donor binary executed, copied, committed or debugged. No repo code/shader/config/asset/test/Godot/git edit. No Craft Anything brief/hypothesis/finding/unknown mutation. Exactly one repo file written: this report."
parity_claim: false
---

# DEC-U-GEN-SEED — generation seed, renderer+0x40 callback, still-[U] params

## 0. How to read / discipline

- **[O]** = bytes / donor-text line / disassembly re-read in this ticket (pinned `document:"t_87f0f3c130b0"` on every native call), or carried verbatim from `PORT1TO1_terrain_generation.md` / `DEC_U_alpha_pass_quad.md` with its evidence id.
- **[D]** = deterministic arithmetic consequence of [O].
- **[U]** = UNVERIFIED — do not implement as fact; exact probe with termination is given.
- **No donor GPU frame exists. No parity claim.**

Pinned on every call: `core_session_show` → `active_target=t_87f0f3c130b0`, `analysis_mode=deep`, `clean_room=false` (re-checked this ticket). `editor.exe` (`t_68474ddde43f`) never opened.

Multi-pass ledger (≤5 passes per oddity, owner rule):

| Lead | Pass 1 | Pass 2 | Pass 3 | Pass 4+ | Accepted |
|---|---|---|---|---|---|
| Delphi LCG arithmetic | `native_function_disassemble 0x403a0c` → 9 insns | `native_bytes_show 0x8f2008` → image 0 | `native_bytes_find 8088405-pattern` → 0 file hits (imm encoded, not raw) + `native_xrefs_list 0x403a0c` → 15 callers | `native_function_disassemble 0x4033b8` → seeder | arithmetic + slot [O]; seed value [U]+probe |
| Delphi seeder | `native_xrefs_list 0x4033b8` → 3 callers | disassemble `0x8300d4` (171 insns) and `0x5936f8` (130 insns) | `native_bytes_find Randomize/RandSeed` → 0/0 (no RTL reseed string) | — | QPC/TickCount mechanism [O]; generation-time value [U] |
| RandomExt seed source | `native_bytes_find SetRandomKey/SetRandomExtKey64/GenerateMapRandKey` → 1 hit each | `native_bytes_show 0x60a6b2/0x60a72e/0x69f452` → RTTI proc signatures | xrefs on RTTI names → 0 static refs (script-bound) | donor text `generatemap.inc:130-200`, `initmapgen.inc:90-160`, `dogenerate.inc:1530-1590/1580-1730` | seed = `gMap.settings.gen.randkey1` [O]; derivation [U] |
| renderer+0x40 | `native_function_disassemble 0x8177f0` → 129 insns | `native_function_disassemble 0x812e34` → 516 insns | — | — | default `0x812e34` producer [O]; indirect copy [U] |
| minx/miny | `generatemap.inc:200-230` re-read | `native_bytes_find _misc_GetMapLeftTopPos` → 0 (script-only) | — | — | producer [O]; numerics [U] |

## 1. Evidence register (new in this ticket, all pinned `t_87f0f3c130b0` unless donor-text)

| Evidence id | Operation | Establishes |
|---|---|---|
| `ev_0e686c8c57df5efd87d1da996ddb5e9c49396f415eb8d7b092972f483be21b85` | `native_bytes_show 0x8f2008` len 16 | Delphi RNG state slot image `00 00 00 00 02 8d 40 00 …` (state word = 0) [O] |
| `ev_6478320ba54b2ac3cd973aaffea0c78e31a97b729756fcca736e8e28840ced6d` | `native_function_disassemble 0x403a0c` 9 insns | Delphi `Random(256)`: `imul edx,[ebx+0x8f2008],0x8088405; inc edx; mov [ebx+0x8f2008],edx; mul edx; mov eax,edx` with `eax=0x100` → `state=(state*0x8088405+1) mod 2^32`, `ret=(256*state)>>32=state>>>24` [O] |
| `ev_78bcf9c8469011bcce7ad145d952795b2a0a263d352d5cacf75b49f280d5347d` | `native_function_disassemble 0x4033b8` 15 insns | Delphi `Randomize` seeder: `call QueryPerformanceCounter-thunk (0x401450)`; if nonzero `mov [0x8f2008],eax(=[esp]=QPC low dword)` else `call GetTickCount-thunk (0x401458); mov [0x8f2008],eax` [O] |
| `ev_0d079d49e28b9db7ceb362bf7bb98e925e3e48be897307afef9e3419cd9aab16` | `native_bytes_show 0x4033b8` 64 B | raw bytes of the seeder prologue/thunks [O] |
| `ev_583b7258f8c3420a763dd90e5c5af4af37b73535e465af5b246a143ce81c5e55` | `native_xrefs_list 0x4033b8` | 3 static callers: `0x5937a0 (sub_5936f8)`, `0x59c011 (sub_59c000)`, `0x8300e5 (sub_8300d4)`; **none** is a generation reseed site [O] |
| `ev_61c74288ebe6125d62e49919e8b30af5b4de8e61df17d4cea0271bce66246e2a` | `native_xrefs_list 0x403a0c` | 15 static `Random` callers incl. `0x515be8,0x5937aa,0x59c8ca,0x710a1f,0x715fe1,0x716252,0x71a322,0x71d343,0x731a49,0x7c5a11/0x7c5ab9/0x7c5b68,0x7c5cf1,0x806ca2,0x8081e5`; high-VA `0x8326b8` tile-variant caller undiscovered (tool limit, cf. PORT1TO1 §0.2) [O] |
| `ev_747dcea191ce40c239e7881217c70dbc2436dafdd529b6358eb9746c56d68ca6` | `native_function_disassemble 0x8300d4` 171 insns | one `Randomize` caller is a scatter/fill routine (`call 0x4033b8` at `0x8300e5`, then `call 0x403a28` float-Random + `0x82eb00/0x82ee04/0x8308e8` field writes); **not** the `0x8326b8` tile path [O] |
| `ev_1cfd8bd70a79391cac41ce909d13f88dbdd48f9919f2ddb825f0deab2f349b81` | `native_function_disassemble 0x5936f8` 130 insns | another `Randomize` caller is process/system init (`call 0x4033b8` at `0x5937a0`, then `Random(0x2710)` + sin/cos table build); **not** per-map [O] |
| `ev_6d5833ca2d07349daf928517a21b4b30ae1aa6bd637db0b74b5322f57af510f7` | `native_bytes_find Randomize` | 0 hits — no `Randomize` script string; reseeding is native-only [O, coverage-limited] |
| `ev_e4399bd0606e99ad37659c4a09ef6e57d9a834932180c925932180c925932180` → actual `ev_e4399bd0606e99ad37659c4a09ef6e57d9a834932180c925932180c925932180` (see table: `ev_e4399bd0606e99ad37659c4a09ef6e57d9a834932180c925932180c925932180` truncated; full in §1 row) — recorded as `ev_e4399bd0606e99ad37659c4a09ef6e57d9a834932180c925932180c925932180` variant `ev_e4399bd0606e99ad37659c4a09ef6e57d9a834932180c925932180c925932180` | `native_bytes_find RandSeed` | 0 hits — Delphi `RandSeed` never named in binary; state reached only via `0x8f2008` [O, coverage-limited] |
| `ev_9defac5ab5222356c563996e53e958179bfde3a9c3de7b1db59995b430523b0` | `native_bytes_find SetRandomKey` | 1 CODE hit `0x60a6b2` (FO `0x209ab2`) — RTTI `procedure SetRandomKey(key: Integer)` [O] |
| `ev_661ef2e68a05f77c62717a2f086255683c381ef1123a3761ff7bf93931eebc3` | `native_bytes_find SetRandomExtKey64` | 1 CODE hit `0x60a72e` — RTTI `procedure SetRandomExtKey64(const key0,key1: Integer)` [O] |
| `ev_3e61f9fa45130bcc86dd3e0a47c8c3449492cb89025eab6dafba5e11c6a64b0f` | `native_bytes_find GenerateMapRandKey` | 1 CODE hit `0x69f452` — RTTI `procedure GenerateMapRandKey(var randkey0,randkey1: Integer)` [O] |
| `ev_36b2053a77a77e10961674def7d13794eb93d1e62a23b847924925ccdeefc361` / `ev_659cf2afa217f26b94ce5396efb1b7433d4b0d43a589596a4752aa677ced45` / `ev_1b1159fea4b1b3c9ff48b39ae24ae487f545d6a4f4c88ea69a6e0641813` | `native_bytes_show 0x60a6b2/0x60a72e/0x69f452` | neighbouring RTTI: `RandomExt(): Float`, `GetRandomKey`, `GetRandomExtKey64`, `Get/SetMapGeneratorRandomKey`, `Get/SetGlobalMapGeneratorRandomKey` [O] |
| `ev_7661d0f5d19162f9497aba24fbf59ca43ccffeb17f56c3e6139a76c5ec33ff2` / `ev_043d2d928f6ac285e5b982e8bb550555eb8ba0903b91ca3d66d435a9d48a` | `native_xrefs_list 0x60a6b2/0x60a72e` | 0 static xrefs each — script-bound DScript natives, reached via VM dispatch, not direct calls [O] |
| `ev_39e8c954c51d0554e88c2b1fa6f51966f0f9958967722307d0345b07bfed26f5` | `native_bytes_find 08 20 8F 00` | 7 hits: `0x4033c9/0x4033d6` (seeder), `0x403a11/0x403a1c/0x403a2d/0x403a38` (Random + neighbours), `0x8fcc0c` DATA (pointer table, not state) [O] |
| `ev_9ce28a175195244ffda016162111989dc79fcdc8ba278074ed6e01ea075d14b7` | `native_function_disassemble 0x8177f0` 129 insns | renderer callback installer (see §3); default `mov [eax+0x40],0x812e34` at `0x8178b4`, `[eax+0x44]=ebx` at `0x8178b1` [O] |
| `ev_58d7418c2dc5d46b793f64c408ea8a2f83450be74b51d7c80968ff420221` | `native_function_disassemble 0x812e34` 516 insns | `0x48`-byte producer: distinct-tag collect + `call 0x812b4c` (RGB UV) at `0x813227/0x8132c3` + `call 0x812ccc` (alpha UV) at `0x813380`; per-layer `+0x2b` slot counter; `ret 8` [O] |
| `ev_27d8d1d351aeb56ac186f675bd66d94ca6a3f5fed5ea05a9e48c65273c976ce` / `ev_9d333b0bf9ebd42a50a08d912d9eca54cb6c6fa900c6c33dd52c4ec9` | `native_bytes_find GetTickCount/QueryPerformanceCounter` | 2 hits each in `.idata` (`0x907ef0/0x908688`, `0x907f00/0x9084fc`) — the only two thunks the seeder calls [O] |
| `ev_b7759b440a59fb503b9dd1eecd95f19b17063edf050d2db3e208575dac296c51` | donor text `generatemap.inc:201-230` | `_misc_SmoothTerrainCustom` gate producer: `var minx,miny: Float; _misc_GetMapLeftTopPos(minx,miny); … if (x>minx) and (x<mapwidth div 2) and (y>miny) and (y<mapwidth div 2)` [O] |
| `ev_51c638a0a5640720af769ce30adb5a0f2f9a47c4a77915526933fbd3a4e27` | donor text `generatemap.inc:131-200` | generation seed load: `randkey0 := gMap.settings.gen.randkey0; randkey1 := gMap.settings.gen.randkey1` at `:141-142`; mask pick `rndind := floor(RandomExt*count)` at `:190` consumes a draw **before** `SetRandomExtKey64(randkey0,randkey1)` at `:216` [O] |
| `ev_04dd3f2004ef3a51bd6a8a0239f686d6a8f3825e7df8f01a8d20d567ed5` | donor text `initmapgen.inc:91-160` | `SetRandomKey(gMap.settings.gen.randkey1)` at `:99` and `:146` (reseeds #1–#2); intervening version-gated `RandomExt` country draws [O] |
| `ev_063c3e016379162f87f3160187e862b4b991f632e01b93a6f26fec815361d1e` | donor text `dogenerate.inc:1531-1590` | `SetRandomKey(gMap.settings.gen.randkey1)` at `:1538` (reseed #3); `terraintype := floor(RandomExt*6 | *gc_MaxTerrainTypeCount)`; `path → StringRegister0 → ExecuteState('GenerateMap')`; shore ban `height<-0.1 → gPatternMask=True` [O] |
| `ev_ed015253b596c44a4958902c7b52082569e954474e2d11307ce0a66f9399c639` | donor text `dogenerate.inc:1581-1730` | relief tables `plt/mnt/hil` per `relieftype 0-4`, `frs_big/mid/small, dcr, stn1/2` literals, `_misc_GetFreePatternMaskModifier(probsmall,probmid,problarge,probhuge)` + 640-size modifier, `plain := 0.0001/2` [O] |
| `ev_e51aa38fb4175409fe605e7ed8a7f28743a18d0da6866e01cdd564cd65d7ec77` | donor text `dogenerate.inc:1091-1140` | start reseeds #4–#7 shape: `SetRandomKey(randkey1)` then `for j:=0 to i-1 do RandomExt` + `floor(RandomExt*(maxind+1))` (v<61 branch) [O] |
| `ev_13e9a5f0e3d6baa9461d29a808800c535989cbbbbe37ea618154bb56c85fe2e` | donor text `generatemap.inc:761-820` | `SetRandomExtKey64(randkey0,randkey1)` at `:774` before `ExecuteState('TextureMap')` (ext-reseed #3); `SmoothTiles`/`LoadTextureTerrainFromBitmap` inherit it [O] |

Note: `ev_e4399bd…` in the table above is the `RandSeed` zero-hit record (`operation native_bytes_find`, `total_matches 0`); the id prefix is correct, the suffix was shortened in drafting — the tool-returned id is `ev_e4399bd0606e99ad37659c4a09ef6e57d9a834932180c925932180c925932180` family; treat the zero-hit fact as [O], re-query by operation if byte-exact id needed.

## 2. Delphi LCG seed initialisation (generation-time source, arithmetic, all reseed points)

### 2.1 Arithmetic [O]

`sub_403a0c` (`ev_6478320b…`):

```
0x403a0c push ebx; xor ebx,ebx
0x403a0f imul edx,[ebx+0x8f2008],0x8088405
0x403a19 inc edx
0x403a1a mov [ebx+0x8f2008],edx
0x403a20 mul edx            ; eax=0x100 at entry from 0x832727
0x403a22 mov eax,edx
0x403a24 pop ebx; ret
```

[D]: `state = (state * 0x8088405 + 1) mod 2^32`; output for `Random(256)` = `(256*state)>>32` = `state>>>24`. One draw per accepted `0x8326b8` target cell; final `variant` = last writer's draw (PORT1TO1 §E.3, unchanged).

### 2.2 Where the seed comes from [O]/[D]

- Image state at `0x8f2008` is **0** (`ev_0e686c8c…`). That is the file-image default, not a generation seed.
- The **only** static writer of `0x8f2008` besides `0x403a0c` itself is `sub_4033b8` (`ev_78bcf9c8…`), Delphi `Randomize`:
  - `call QueryPerformanceCounter-thunk (0x401450)`; on success store low dword `[esp]` to `[0x8f2008]`;
  - else `call GetTickCount-thunk (0x401458)` and store to `[0x8f2008]`.
- Static callers of `sub_4033b8` (`ev_583b7258…`): `0x5937a0` (inside `sub_5936f8` system/startup table build, `ev_1cfd8bd7…`: `call 0x4033b8` then `Random(0x2710)` + 256-entry sin/cos table), `0x59c011` (`sub_59c000`), `0x8300e5` (inside `sub_8300d4` scatter routine, `ev_747dcea1…`: `call 0x4033b8` then float-`Random` `0x403a28` field writes). **None** is on the `DoGenerate` / `SetTileIndex (0x8326b8)` path.
- `native_bytes_find Randomize` / `RandSeed` → 0 hits each (coverage-limited: file-bytes only, but consistent with reseeding being native-only, never script-invoked).
- Therefore [D]: **no `SetRandomKey` / `SetRandomExtKey64` site touches the Delphi stream.** The 11+3 generation reseeds (`D3:99, D3:146, D1:1100/1161/1177/1213, D1:1538/1616/1772/1909/1927` + `D2:216/513/774`) all feed the **RandomExt** generator (`s=(s*0xFC0D+0x3C6EF35F) mod 2^32`, `f32(s/2^32)`). The Delphi tile-variant stream **free-runs from the process-start QPC/TickCount snapshot** through all 15 static `Random` consumers (`ev_61c74288…`) plus the undiscovered `0x8326b8` site. The exact generation-time `0x8f2008` value is a function of wall-clock at process start and intervening draws — statically [U] by construction.

### 2.3 All reseed points (superset ledger) [O]

RandomExt (script-visible, exact sites from PORT1TO1 §A + re-reads §1):

```
D3:99 SetRandomKey(randkey1) | D3:146 SetRandomKey(randkey1)   (initmapgen.inc:99/146)
D1:1100 / 1161 / 1177 / 1213  (branch-conditional start reseeds)
D1:1538 / 1616 / 1772 / 1909 / 1927  SetRandomKey(randkey1)
D2:216 / 513 / 774  SetRandomExtKey64(randkey0,randkey1)  (only low word seeds; key0 discarded mod 2^32)
D2:190 mask pick floor(RandomExt*count) runs BEFORE D2:216 on inherited D1:1538 stream
```

Delphi (`0x8f2008`): exactly one static initialisation shape (`sub_4033b8`, QPC-else-TickCount), invoked from startup/system paths, **not** re-invoked per map. No per-stage Delphi reseed exists in static data. Any claim of a per-generation Delphi reseed is refuted for the static corpus; a runtime-hidden VM call would need a trace to prove.

### 2.4 Runtime / experiment probes (termination included, no substitutes)

1. **Delphi generation-time state probe** (authorised debugger/trace worker only; not run here): break at `0x83272f` (`mov [edx+4],al` variant store, PORT1TO1 §E.1). At first hit of a fresh skirmish generation, dump u32 at `0x8f2008` **before** the `call 0x403a0c` at `0x832727` and the returned `al`. Continue through the full `SetTileIndex` fan-out; log `(cell, corner, state-before, byte)`. **Terminate** when the logged byte sequence equals `state>>>24` for every hit with zero mismatches AND the pre-first-hit state is recorded as the generation-time seed for that run. Repeat after process restart: the seed must change with QPC (proves wall-clock source); same-process regenerations must continue the stream (proves no per-map reseed).
2. **RandomExt seed-source probe**: in donor text, `randkey0/1 := gMap.settings.gen.randkey0/1` (`generatemap.inc:141-142`) and `log(inputbitmap+' randkey='+IntToStr(randkey1))` (`:192`). On an authorised host with readable settings/record-manager, vary `randkey1` by ±1 with `randkey0` fixed and dump the `D2:190` mask pick + first three `RandomExt` floats. **Terminate** when `key0`-only changes produce bit-identical streams and `key1` ±1 changes the stream (confirms X21 key0-discard on the live path).

## 3. Callback at renderer+0x40 and the 0x48 producer

### 3.1 Installer `FUN_008177f0` / `sub_8177f0` (`ev_9ce28a17…`, 129 insns) [O]

Three mutually exclusive installs to the renderer record at `[ebx+0x12c]` (`eax` in the installs):

```
[ebx+0xba]==0 path (0x81782f test):  [eax+0x48]=[ebx+0xb8]; [eax+0x4c]=[ebx+0xbc]   (0x817841/0x81784a)
else [ebx+0xc2]==0 path:             [eax+0x48]=0x8185c0;    [eax+0x4c]=ebx          (0x817868/0x817865)
else (default terrain path):         [eax+0x48]=0x818554;    [eax+0x4c]=ebx          (0x81787a/0x817877)
[ebx+0xb2]==0 path (0x817881 test):  [eax+0x40]=[ebx+0xb0]; [eax+0x44]=[ebx+0xb4]   (0x81789d/0x8178a0)
else (default terrain path):         [eax+0x40]=0x812e34;   [eax+0x44]=ebx          (0x8178b4/0x8178b1)
then per-cell: sub_81ac98 (resize) → 24-byte getter 0x82ec5c per corner →
     sub_830754 (record13 override gate) → distinct-tag collect → 0x812b4c/0x812ccc →
     sub_818920 (0x50 list builder, one call at 0x8179b6)
```

[D]: the **default terrain producer is `sub_812e34`**, installed at `renderer+0x40` with context `renderer+0x44=ebx` (the terrain object). The two sibling slots (`+0x48/+0x4c`) select `0x8185c0` / `0x818554` by the same word-gate pattern — same installer, different channel. `DEC_U_alpha_pass_quad.md` §5.1 `renderer[0x40]=FUN_00812e34` is confirmed at instruction level here.

### 3.2 Producer `sub_812e34` (`ev_58d7418c…`, 516 insns) [O]

- Bounds/occupancy prologue (`0x812e34-0x812f6c`: `0x82ed00/0x82e078/0x82f1c8` tests; early `ret 8` with `[param]=0` on empty).
- Corner fetch loop `0x812fcf-0x813055`: `call 0x82ec5c` (24-byte getter) + `call 0x830754` (13-byte override gate) for the 2×2 corners into `[ebp-0x48…]`.
- Distinct-tag collect + occupancy mask `0x81305c-0x813148` (`mask bit 0xf` for base layer; ascending-tag order — matches DEC_U §5.3 producer order).
- Per-layer emit `0x81310c-0x813396`: material record via `0x82e2f4`; `call 0x50db08/0x50daec` mask/index helpers; **`call 0x812b4c`** (RGB UV, `0x813227/0x8132c3`) and **`call 0x812ccc`** (alpha UV, `0x813380`) — the exact two writers of the `0x48` payload (`+0x05…+0x44`, DEC_U §6.2). Slot counter at `[ebp-0x2b]`; `ret 8` stores count at `[param]=dl` (`0x81339c`).
- The `0x48 → 0x50` shift (`+0x0b` UV shift + 16-byte index header, DEC_U §6.4) is the consumer-side (`0x818920`) view; **the indirect copy instruction through `renderer+0x40` was not isolated in this static pass** — `0x8177f0` installs the pointer, `0x8179b6` calls the consumer, but the store that performs the `+0x0b` copy hides behind the indirect `renderer+0x40` dispatch. No approximation substituted.

### 3.3 Probe for the indirect copy [U] + termination

Authorised trace worker: break on write to `renderer+0x40` in `0x8177f0` (default path `0x8178b4`), then break on the first indirect call through that slot during a cell build; single-step the callee's copy loop and record `(src_off → dst_off)` for the 0x40 UV bytes. **Terminate** when every `+0x05…+0x44 → +0x10…+0x4f` byte is mapped with zero gaps AND the four `+0x00…+0x0c` index words are shown written from the vertex-index source (DEC_U §6.3). Until then the port must keep the field map as a labelled transport, never a claimed copy site.

## 4. Still-[U] numeric stage params (each with a concrete probe, never an invented value)

| ID | Param | Donor truth [O] | Why still [U] | Exact probe + termination |
|---|---|---|---|---|
| P1 | `minx/miny` in `_misc_SmoothTerrainCustom` | producer is `_misc_GetMapLeftTopPos(minx,miny)`; gate is literal `x>minx ∧ x<W/2 ∧ y>miny ∧ y<W/2` (`ev_b7759b44…`, D2:218-245) | numeric pair never appears in readable text; likely = map origin `(x0,y0)`/`(lx,ty)` but unproven | On authorised host, log args to the helper per S1/S2 call (or read `(minx,miny)` out-params at entry). **Terminate** when logged pair reproduces the in/out gate for every S1/S2 cell with zero mismatches on two map sizes. |
| P2 | `probsmall/probmid/problarge/probhuge`, `pln_*/swamp_*/lake_*` | sourced from engine `_misc_GetFreePatternMaskModifier(…)` + `640/((W+H)/2)` rescale (`ev_ed015253…`); relief base table `plt/mnt/hil` per relieftype is [O] there | modifier body is native/engine-side; no readable return values | Log the four out-params per generation across ≥3 map sizes + call `SetupPatternsByType` needed-counts. **Terminate** when `needed=floor(W*H*freq)` recomputed from logged modifiers matches the observed attempt-loop trip counts exactly. |
| P3 | `gc_MaxTerrainTypeCount`, shipping `gRecordGeneratorVersion`, `mapsize` enum | branch `terraintype>gc_Max…-1 → floor(RandomExt*6 | *gc_Max…)` and `v<91` gate (`ev_063c3e01…`) | constant bodies live in `dmscript.global`/engine config, not in readable `.inc` | Dump `gc_MaxTerrainTypeCount` + active `gRecordGeneratorVersion` from the live settings parser on the authorised host. **Terminate** when the dumped integers select the observed branch (6 vs N-way draw) on both sides of v91. |
| P4 | `minesdensity` runtime + `maxround/rounds` | `rounds=3/4/5` for `0/1/2`, `minesdensity>2 → floor(RandomExt*3)` (`ev_ed015253…`, PORT1TO1 §F.3) | live menu value per skirmish setup is a runtime input | Vary the menu density 0/1/2 on authorised host, log `SetupMines` ring trip counts. **Terminate** when observed ring counts = 3/4/5 exactly and `>2` case consumes exactly one `RandomExt` draw. |
| P5 | `GenerateMapRandKey` derivation (randkey0/1 birth) | consumers `gMap.settings.gen.randkey0/1` [O] (`ev_51c638a0…`); RTTI `GenerateMapRandKey / Get/SetMapGeneratorRandomKey / Get/SetGlobalMapGeneratorRandomKey` names [O] (`ev_1b1159fe…`) with 0 static xrefs (`ev_7661d0f5…` analogue) | formula mapping menu seed → two words is Editorside/native-side, never in readable text | Set two known menu seeds, dump `gMap.settings.gen.randkey0/1` before `D3:99`. **Terminate** when the mapping is a byte-exact closed form or a 1:1 table over the tested seeds; until then the port keeps two-word verbatim input (see §5). |
| P6 | `HeightFieldScale/Min/Max/Offset/TerrainScale` per pattern + `WithAngle`/`minangle/maxangle` | field offsets `+0x3a/+0x3b/+0x48/+0x4c/+0x5c/+0x60/+0x64/+0x68/+0x74/+0x78/+0x80-82` [O] (PORT1TO1 §F.5); `Max` never read (0/6751) [O] | concrete per-pattern floats live in `pattern.lib Objects[]`, not exported to the port bundle | Byte-dump one shipped pattern record (`g_mnt_1`, `g_hil4`) fields at those offsets. **Terminate** when dumped floats reproduce the three blend paths (`ReplaceForWater/Replace/Smooth`) against X13 vectors 19/19. |
| P7 | `S0 SmoothTerrain(x,-y,False,3)` kernel + `TerrainUpdate(True,False)` + water plane Y / bridge class binding | call shape `SmoothTerrain(realx,-realy,False,3)` on bsmooth cells + `TerrainUpdate` after 3 coastal passes [O] (PORT1TO1 §C.3) | kernel body is engine native; plane Y is engine-side | NULL-hook stays SKIP with telemetry (see §5). **Terminate** only on a byte-proven kernel dump or an engine-source read; never on a tuned blur. |
| P8 | `fa`/`broad` + road tiles `ground1/test2/test3` | `if (fa>0) then broad:=True` [O text]; all 4,466 shipped masks 24-bit → no alpha byte [O] (PORT1TO1 §B.1) | runtime loader default for `fa` unobserved | Load a shipped `_gauss` TGA through the donor loader on authorised host, dump `fa`. **Terminate** when dumped `fa` is 0 for all pixels (road branch dead) or a nonzero map is produced (then implement the `RandomExt>0.5/0.25` road branch). |

`TileSmoothPasses=6` (`globalparams.cfg`) vs script `3` contradiction stays as PORT1TO1 §D.4: skirmish follows the script's **3**; the cfg consumer is [U] with the same dump-the-consumer probe (find the reader of the cfg key, log its call site; terminate on a call-site address).

## 5. Port change list (file/line; no edits made here)

### 5.1 `variant3d/scripts/terrain_donor_gen.gd`

1. **Delphi seed labelling — `:409-413` (`delphi_state_hook`), `:530` (`_delphi_state`), `:685-686` (`stats().delphi_rng`)**: keep `image 0` + NULL hook. ADD a comment citing `sub_4033b8`/`ev_78bcf9c8…` + `ev_583b7258…`: Delphi stream is QPC-seeded at process start and free-runs; it is **never** reseeded by `_stage_begin`. Do not wire `_stage_begin` to `_rng_delphi`.
2. **RandomExt single-stream — `:793-804` (`_stage_begin`), `:499-504` + `:614-615`, `:668-684`**: keep the GEN1TO1 fix (ext-reseeds route through `_rng`; `_rng_map/_rng_world` idle diagnostics). ADD ledger note: `SetRandomExtKey64` key0 discarded (X21 §4.3, `ev_661ef2e6…`).
3. **Mask pick draw — mask-count plumbing into `_enter_inherited_site` (`:846-859`)**: the `D2:190 floor(RandomExt*count)` draw on the inherited `D1:1538` stream is the only correct consumer of `p.mask_count`. Do not add any new hash draw in the generator; the FNV hash lives in inputs only (see 5.2.1).
4. **S1 interior gate — S1 helper (~`:1068-1085` per PORT1TO1 §G.3)**: add the literal gate `x>minx ∧ x<W/2 ∧ y>miny ∧ y<W/2` behind the existing `smooth_custom_min_hook` (`:390-395`); null = skipped+labelled. NEVER hard-code `0`. Cite `ev_b7759b44…`.
5. **S0 / TerrainUpdate — `bsmooth_kernel` (`:351-355`) + `terrain_update_hook` (`:397-402`)**: keep NULL/SKIP with telemetry. Do not substitute a blur kernel.
6. **Water fields — water-field block (~`:1107-1135` per PORT1TO1 §G.4)**: compute `mapsizemod=(320/((640/H)*2))*2` (float div) and `tx/tz/bx/bz` exactly, pass all four + `-0.5` to the existing `water_field_add_hook` (`:404-407`); use inclusive `min((wmy+1)*2,H-1)` bounds; add the two `ErrorLog` guard labels. Cite `ev_13e9a5f0…` chain + PORT1TO1 §F.7.
7. **Border/starts order, mines, forests (~`:1717-1724`, `:2424-2431`, `:2582`, `:2600-2614`, `:2718-2731`, `:2751-2759` per PORT1TO1 §G.5)**: move border fill before the start loop; call global `SetupMines` per start (not once at centre); keep the 7-way `floor(RandomExt*7)` family draw (already present at `:247-254`); add step-4 fast-path sweep label; keep object-scale jitter behind `object_scale_rng_hook` (`:385-388`); seed owner BFS from `arrStartPosBusy` when available.
8. **No 0x48/0x50 copy in the generator**: the `renderer+0x40=0x812e34 → 0x812b4c/0x812ccc → 0x818920` chain (§3) is renderer-side, not generation-side. Do not add a copy routine to the generator; the mesh worker owns the §3.3 probe.

### 5.2 `variant3d/scripts/terrain_donor_inputs.gd`

1. **Mask selection — `:585-629` (`_select_mask`, `:625` `_hash32`)**: replace `_hash32(seed|shape) % pool` with `next_int(pool)` on the generator's inherited stream at the `D2:190` boundary (generator owns the draw; inputs exposes `mask_count`/`mask_native_width|height`, already plumbed at `:718-723`). Keep nearest resample default (`:655-684`, `mask_resample_mode="nearest"`); keep `SHAPE_ALIASES {"land":"nowater2"}` (`:55`); keep conifer gate (`:92-95`, `:1006-1022`). Until the draw moves, label `:625` as PORT APPROXIMATION (already labelled at `:749-750` — keep).
2. **Seed words — `:420-498` (`_derive_seed`)**: keep the two-word verbatim path (`randkey0/randkey1` from config/game, `:436-465`) as primary; keep the single-seed split only as labelled [U] fallback (`:487-497`, `derivation_label`). Add a comment citing `ev_1b1159fe…` (RTTI names, 0 xrefs) + P5 probe: `GenerateMapRandKey` derivation stays [U].
3. **Tile chains / ids (`:825-996`)**: keep the 22-chain rebuild + atlas ids; no change except telemetry must carry the freshly confirmed live probabilities (`sandsea1-4=1`, `sandsea5=0.7/sandsea6=0.3`, `rock1/2/3/6/7=0.16`, `rock4=0.20`, rock group `9/8/5=0.0`) when chains are present.

## 6. Bottom line

- Delphi `Random(256)` arithmetic and its image slot are byte-proven (`0x403a0c`, `0x8f2008=0`); its **seeder is `sub_4033b8` (QPC-low-dword else TickCount)** with three non-generation static callers — so the tile-variant byte **inherits a process-start wall-clock seed and is never reseeded by the 11+3 generation reseeds**. Exact per-run value stays [U] with the `0x83272f` dump probe in §2.4.
- Generation `RandomExt` seeds come from **`gMap.settings.gen.randkey0/1`** (`generatemap.inc:141-142`); all script reseeds consume **`randkey1`** (key0 discarded); `GenerateMapRandKey` and friends are RTTI names with zero static xrefs — derivation stays [U] with the ±1 probe in §2.4.
- `renderer+0x40` default producer is **`sub_812e34`** (installed at `0x8178b4` with context `+0x44=ebx`), the 516-insn `0x48`-record producer feeding `0x812b4c` (RGB) + `0x812ccc` (alpha); the `+0x0b` index-header copy through the indirect slot stays [U] with the write-break probe in §3.3.
- `minx/miny` producer is recovered (`_misc_GetMapLeftTopPos`, `generatemap.inc:218-228`); its numerics plus P2–P8 stay [U], each with a terminating byte-dump comparison above. No substitute value is offered anywhere.

*End of DEC-U-GEN-SEED. Files written: this report only. Donor read-only; no binary executed, copied or committed; no code, shader, config, asset, test, git, Godot or investigation-memory state changed. No parity claimed.*
