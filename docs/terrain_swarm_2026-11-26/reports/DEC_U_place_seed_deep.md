---
id: DEC-U-PLACE-SEED-DEEP-2026-11-26
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: "WORKER DEC-U-PLACE-SEED-DEEP — class-B static angle T-SEED generation-time per-site draws"
owner_file: docs/terrain_swarm_2026-11-26/reports/DEC_U_place_seed_deep.md
status: DELIVERED__READ_ONLY__EXACTLY_ONE_REPORT__NO_PARITY_CLAIM
date: 2026-11-27
target: "t_87f0f3c130b0 — C:\\Games\\Cossacks 3\\cossacks.exe, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
labels: [OBSERVED, DERIVED, UNVERIFIED, NO_APPROXIMATION, PARITY_UNVERIFIED]
parity_status: UNVERIFIED
parity_claim: NONE
visual_parity_claim: false
scope_guard: "Donor READ ONLY; pinned document:\"t_87f0f3c130b0\" on every native call. No donor binary executed/copied/committed/debugged; no repo code/shader/config/asset/test/fixture/result/Godot/git edit; no Craft Anything brief/plan/finding/unknown mutation. Exactly one repository file written: this report."
---

# DEC-U-PLACE-SEED-DEEP — T-SEED generation-time per-site draws (packed CODE tables, wrapper arities, map headers, key1-only question)

## 0. Discipline / prior state

- **[O]** = bytes / import-name / disassembly re-read in this ticket (pinned `t_87f0f3c130b0`), or carried verbatim with evidence id.
- **[D]** = deterministic arithmetic / counting consequence of [O].
- **[U]** = UNVERIFIED — never implemented as fact; exact breakpoint dump + restart-changes-seed zero-mismatch termination given.
- **No donor GPU frame. No parity claim. No invented seed/derivation.**
- Prior accepted as [O], not re-litigated: Delphi LCG `sub_403a0c` (`state=(state*0x8088405+1) mod 2^32`, `out=state>>>24`), slot `0x8f2008` image 0, seeder `sub_4033b8` QPC-low-else-GTC (`DEC_U_genseed_deep`, `DEC_U_gen_seed`); RandomExt LCG `s=(s*0xFC0D+0x3C6EF35F) mod 2^32`, `f32(s/2^32)` at `0x60f64c–0x60f696`, divisor `2^32` at `0x60f698`, helpers `0x406718/0x4067b8` (`D02_seed_rng §4.2`, `spec/02_SEED_AND_RNG §2`); 11 `SetRandomKey(randkey1)` + 3 `SetRandomExtKey64(randkey0,randkey1)` reseed ledger (`X03`, `D02 §4.6`, `spec/02 §4–§5`); `TMapSettingsGen` two-u32 schema high=`randkey0`/low=`randkey1`, `GetRandomKey`→`randkey1` in filename (`D02 §4.1/§4.3`, `spec/02 §1`).
- Still-[U] entering this ticket: generation-time per-run Delphi state at `0x83272f`/`0x8f2008`; `GenerateMapRandKey` body/derivation; saved-map randkey byte mapping; whether key0 is truly discarded at runtime.

Multi-pass ledger (≤5 passes per oddity, owner rule; every native call pinned `document:"t_87f0f3c130b0"`):

| Lead | Pass 1 | Pass 2 | Pass 3 | Pass 4+ | Accepted |
|---|---|---|---|---|---|
| (a) packed CODE name search | `native_bytes_find` 12 terms: `SetRandomKey` 1 hit, `SetRandomExtKey64` 1 hit, `GenerateMapRandKey` 1 hit, `randkey0` 6 hits, `randkey1` 6 hits, `RandomExt` 3 hits, `GetRandomKey` 1, `GetRandomExtKey64` 1, `Set/GetMapGeneratorRandomKey` 1 each, `Set/GetGlobalMapGeneratorRandomKey` 1 each (all CODE) | `native_bytes_show` 256 B at all 12 VAs — full RTTI arities | `native_strings_find` `RandomExt`/`randkey`/`GenerateMap` → 0 each (DATA-only tool) vs bytes hits — explains D02 Anomaly A | `native_bytes_find "Random"` 81 hits sample + `"SetRandom"` 3 hits + `"GetRandom"` 3 hits with false-positive triage | names are CODE-embedded RTTI tables, not DATA strings [O] |
| (b) wrapper arities + derivation hunt | 256-B signature rows give exact arities (see §2) | `native_xrefs_list` at `0x60a662/0x60a6b2/0x60a72e/0x69f452/0x659f5f` → 0 refs each (script-bound via `FUN_00608238`, D02 `ev_1858bbfd…`) | length-prefix check at `0x69f440` (`4A`=74) + `0x69f452` signature, no code carve | 11+3 sites are donor-text `[*] = ;` identity reseeds (spec/02 §5, X03) — no native derivation operand found | arities [D]; derivation stays [U] |
| (c) shipped `.map` headers | repo `**/*.map` → 0 files | donor `data/maps/missions/*.map` glob → 38 mission maps (incl `bonmis1.map`) | carried `bonmis1.map:0x18c0f1=0x44a108f9` + version-13 word-index-2 note (`D02 §4.3`, `DEC_06 §7.1`) | no new header dump in this ticket (read-only glob only; no byte→field proof) | mapping stays [U] |
| (d) key1-only vs key0-discard | D02 `§4.2–§4.3` re-cited: `SetRandomKey(k)` lo=k/hi=k>>31; `SetRandomExtKey64` lo=k1/hi=k0 then hi=0 after first draw | `0x809640` 256-B LCG twin (`mov eax,0xFC0D` + `5F F3 6E 3C`) + `0x60f64c` 512-B re-read confirm constants present but wrapper body undiscovered | 11 sites pass `randkey1` verbatim; 3 sites pass `(randkey0,randkey1)` verbatim — no per-site mixing operand in text | — | verbatim pass [O]; runtime discard [U]+probe |

## 1. Evidence register (new in this ticket unless marked carried)

| Evidence id | Operation (pinned `t_87f0f3c130b0`) | Establishes |
|---|---|---|
| `ev_5cc4b3b817e1b22b3a79bcb15df10eba8292e638c28d619782593c0ef87a0a3d` | `native_bytes_find "SetRandomKey"` | 1 CODE hit: VA `0x60a6b2` (FO `0x209ab2`) [O] |
| `ev_727d454cb2e017ac93520adbfb4291bcf67a71fe4d61223d2b0c5484f98ca856` | `native_bytes_find "SetRandomExtKey64"` | 1 CODE hit: VA `0x60a72e` (FO `0x209b2e`) [O] |
| `ev_bb534909773590daf6239f352d4b8dfa5ce1847861e582c16cb664f9a0b67b88` | `native_bytes_find "GenerateMapRandKey"` | 1 CODE hit: VA `0x69f452` (FO `0x29e852`) [O] |
| `ev_c452cc1f04714b7b6b00a039edad702c6abb2603e4ed78106893927ae9cadce8` | `native_bytes_find "randkey0"` | 6 CODE hits: `0x69f469/0x69f4c3/0x69f521/0x69f575/0x69f5d7/0x6a46fd` [O] |
| `ev_dbb1494a5778da2eae7ba7d4ef5ff1227e383a7dc270ee87cee80dfb3c9e24e5` | `native_bytes_find "randkey1"` | 6 CODE hits: `0x69f480/0x69f4da/0x69f52b/0x69f58c/0x69f5e1/0x6a4707` [O] |
| `ev_9430c9dd8cd4e6e7a2481c424c25c94c8df873bda0c625dfaed75fcefa926a4b` | `native_bytes_find "RandomExt"` | 3 CODE hits: `0x60a662/0x60a6e5/0x60a731` [O] |
| `ev_6505bb5d39c5d4591c21863f1700f0a63c0b12bfaee46c563446b16ee4160050` | `native_bytes_find "GetRandomKey"` | 1 CODE hit: VA `0x60a68a` [O] |
| `ev_8e1705141779103ac4f60adc4e93855f0295725cabb4131b3bc13c612e5e9460` | `native_bytes_find "GetRandomExtKey64"` | 1 CODE hit: VA `0x60a6e2` [O] |
| `ev_5bfa44ac589371c7c44ae21333c90927cad24c7d31af13d203ffd6671609b17b` | `native_bytes_find "GetMapGeneratorRandomKey"` | 1 CODE hit: VA `0x69f4a6` [O] |
| `ev_2a753963cbe887e375524dcc323dd34d1c9462cb168ae16fe3761422cb41e1db` | `native_bytes_find "SetMapGeneratorRandomKey"` | 1 CODE hit: VA `0x69f502` [O] |
| `ev_524d766e187db08c8141bfeb9e918d063b9fd3c4951a562905a2f52ae7f53ac2` | `native_bytes_find "GetGlobalMapGeneratorRandomKey"` | 1 CODE hit: VA `0x69f552` [O] |
| `ev_9010e3cbd0e73836c87f3f75614862bcefbce2c6f34f76c49781417cc9f5234c` | `native_bytes_find "SetGlobalMapGeneratorRandomKey"` | 1 CODE hit: VA `0x69f5b2` [O] |
| `ev_69f3e4a3d2fe2c1ecb4429c92c3e34e79d31d1f4bf1f64f7341fd6c7ac3b31bc` | `native_bytes_show 0x60a662` 256 B | `RandomExt(): Float` + neighbours [O] |
| `ev_04a5ed37fe61a935e322aabbe2ff98e49b5c2827596717220a06fdab1273c5a1` | `native_bytes_show 0x60a68a` 256 B | `GetRandomKey: Integer` + `SetRandomKey(key: Integer)` [O] |
| `ev_cb3800794dc418f7a5a22c6b90a92efeb3b156bfbfa5917109db1ac9f8230dfa` | `native_bytes_show 0x60a6b2` 256 B | `SetRandomKey(key: Integer)` arity 1 [O] |
| `ev_3bbfcb781816af52f7eb1afba0ed341635b40fd5ba56d7c9f5bc9d0f9d3cbb58` | `native_bytes_show 0x60a6e2` 256 B | `GetRandomExtKey64(var key0; var key1)` arity 2 [O] |
| `ev_fb48fb2ac26853f4695267cdefd7d9e9737d62c2292935c2de923d15bf33ee2e` | `native_bytes_show 0x60a72e` 256 B | `SetRandomExtKey64(const key0,key1)` arity 2 [O] |
| `ev_9a4e14aa71d6ecf1164d10f4bb49f06143f5dedeaa60f0ecdc91f792bbd244d4` | `native_bytes_show 0x60a731` 256 B | tail of `SetRandomExtKey64` row [O] |
| `ev_786be1f7ae72e2682132b2a7b43900267cb640bfa337b5a00ae5b9d3a696dd7f` | `native_bytes_show 0x69f452` 256 B | `GenerateMapRandKey(var randkey0; var randkey1)` + `Get/SetMapGeneratorRandomKey` [O] |
| `ev_0da1300b078fe44a9bdf7cbc28e9795c7592b6e138e3e9895e745605851c4079` | `native_bytes_show 0x69f4a6` 256 B | `GetMapGeneratorRandomKey(var…)` + `SetMapGeneratorRandomKey(const…)` [O] |
| `ev_0ade22dff8b9b8fe3d171730ccdce4aab2e04f1a66aad10b54b18a09e8685cef` | `native_bytes_show 0x69f502` 256 B | `SetMapGeneratorRandomKey(const…)` + `GetGlobal…` [O] |
| `ev_276b5beb58e8d89dbf1a09d259367969484eb9764693a5b548fdfbc682419e4d` | `native_bytes_show 0x69f552` 256 B | `GetGlobalMapGeneratorRandomKey(var…)` + `SetGlobal…` [O] |
| `ev_794cee81c19ca5899dc870924ce2a40e31f12db6682989f30c004163c3e4dabd` | `native_bytes_show 0x69f5b2` 256 B | `SetGlobalMapGeneratorRandomKey(const…)` [O] |
| `ev_b7a88bc8aba8a89b79b2354e474f4a555f459b7cc68b970ed1c683a20585ab84` | `native_bytes_show 0x6a46fd` 256 B | trailing `(randkey0, randkey1: Integer)` fragment (further table row, not a derivation) [O] |
| `ev_e0c1c1ee5af1c25a9ab807761f6718b2fd59980757599b7b2d00302541111523` | `native_bytes_show 0x69f440` 256 B | length-prefix `4A`=74 before `GenerateMapRandKey` signature (X51 table shape) [O] |
| `ev_b3ff60d2d2107ebe52a91f5862e7f55a05d331c90694dc3177eef5d77dd4e3f0` | `native_xrefs_list 0x60a6b2` | 0 refs (script-bound, cf D02 `FUN_00608238`) [O] |
| `ev_05ad4a86e29d3be6b1c7d94448a2c8741df118e30b8e655e246746dbbe0c4397` | `native_xrefs_list 0x60a72e` | 0 refs [O] |
| `ev_ac5ccebc467753b3743d26e77a21f197a0f9a3f693b29545ff` | `native_xrefs_list 0x69f452` | 0 refs [O] |
| `ev_023cf48a392b726d98ae52a0bc333fa4ce2d1a6477c00c333fa4ceff47` | `native_xrefs_list 0x60a662` | 0 refs [O] |
| `ev_38c8e504b3666bf8160489629afd91f311a2256f4f828e5b961092abcb21079` | `native_strings_find "RandomExt"` | 0 DATA strings (limitation `data_sections_only`) — consistent with CODE-embedded RTTI [O] |
| `ev_dccf25f0ac91f8daaf960b6f5a88bd61c4dba151509616640772b73d433cd96e` | `native_strings_find "randkey"` | 0 DATA strings [O] |
| `ev_998049681e46621ec4aca732338610decafefa44fcfc8d35067662a1a94521` | `native_strings_find "GenerateMap"` | 0 DATA strings [O] |
| `ev_bf057defac1a22f483c9f3213293d7e59d04d00faf0852d5fa5519816bb44aa5` | `native_bytes_find "Random"` (5/81 paged) | 81 CODE hits incl RTTI cluster `0x60199f…` + map-gen `0x84179c…` [O] |
| `ev_629d74c53df9abb89a8e6f4bfed679fa65b0dcd824bb4fe95b52a793a9e2ac7e` | `native_bytes_find "SetRandom"` | 3 hits: `0x60a6b2`, `0x60a72e`, `0x659f5f` [O] |
| `ev_918798d4bb39641bb9240ad05c5291ee78050a68d348154f52b8e08c7e65bd36` | `native_bytes_show 0x659f5f` 256 B | `SetRandomOffsetByHandle(grhandle; randomoffset: Boolean)` — unrelated group API, triaged out [O] |
| `ev_496d6434ffc9383d2909034e5633798a3db4cfc9daa4c00c45c61c0cca9df6de` | `native_xrefs_list 0x659f5f` | 0 refs [O] |
| `ev_2d0b7d6ce3bb6c328004a610359f25f4e8d2a98a46b5870a8380b6ec09d01c2d` | `native_function_find 0x659f5f` | not inside known function [O] |
| `ev_69be0fe13c7c8d9f48d995653f3efdd1b00e28e8c1bd11f66c04420a1bc6f0` | `native_bytes_find "GetRandom"` | 3 hits: `0x60a68a`, `0x60a6e2`, `0x659fbb` (=`GroupGetRandomOffsetByHandle`, unrelated) [O] |
| `ev_81148ecd83a20ccfd5720dabe8e25eecea486f8c138798ad433a06e73dff252d` | `native_bytes_find pattern "5F F3 6E 3C"` | 5 hits: `0x60f66a`, `0x7281d7`, `0x72d2de`, `0x809664`, `0x8096ae` — increment word present in multiple LCG instances [O] |
| `ev_fead9f1f2a021e8d1475da5ac9c124b1a76c92bdb5dd0e8a49d84353cf4ee358` | `native_bytes_find pattern "0D FC"` | 33 hits incl `0x60f65e` etc — multiplier byte present; `0x60f65e` alone decodes as `or eax,0x330000fc`, so no per-hit semantic claimed [O] |
| `ev_c76e140082570ece8d72a362a7c0ad90f56377e21b3fa45376f3366f0a612268` | `native_bytes_show 0x809640` 256 B | `B8 0D FC 00 00` (`mov eax,0xFC0D`) + `5F F3 6E 3C` LCG twin instance [O] |
| `ev_4999a6cf08b6b2b5a6ca40c897f67973e5db2dcf556b125161a95359e1a333` | `native_bytes_show 0x60f64c` 512 B | RandomExt region raw bytes re-read [O] |
| `ev_a2f27ed1ba990b293cf7b8e351a695d98f182d2287d0028693a9656d233c8d7f` | `native_bytes_show 0x60f690` 64 B | continuation of same region [O] |
| `ev_ab695f5bb40f853580145ce1e4b480c057735df304493c2ea8ff4efe739fb4ca` | `native_bytes_show 0x60f640` 128 B | head of same region [O] |

Coverage caveat (every zero-hit row): `file_bytes_only` + `data_sections_only` + `static_references` — packed/`.bind`/run-time-built data and VM-dispatched calls are not seen; zero is not proof of absence.

## 2. (a) Packed CODE tables — what is byte-proven [O]/[D]

### 2.1 CODE-embedded RTTI names with VAs [O]

All hits are `section CODE`, `matched utf8`, pinned `t_87f0f3c130b0`:

- `RandomExt` → 3 CODE hits: `0x60a662`, `0x60a6e5`, `0x60a731` (`ev_9430c9dd…`).
- `SetRandomKey` → `0x60a6b2` (FO `0x209ab2`) (`ev_5cc4b3b8…`); `SetRandomExtKey64` → `0x60a72e` (FO `0x209b2e`) (`ev_727d454c…`).
- `GetRandomKey` → `0x60a68a`; `GetRandomExtKey64` → `0x60a6e2` (same table run).
- `GenerateMapRandKey` → `0x69f452` (FO `0x29e852`) (`ev_bb534909…`); `GetMapGeneratorRandomKey` → `0x69f4a6`; `SetMapGeneratorRandomKey` → `0x69f502`; `GetGlobalMapGeneratorRandomKey` → `0x69f552`; `SetGlobalMapGeneratorRandomKey` → `0x69f5b2`.
- `randkey0` → 6 CODE hits `0x69f469/0x69f4c3/0x69f521/0x69f575/0x69f5d7/0x6a46fd`; `randkey1` → 6 CODE hits `0x69f480/0x69f4da/0x69f52b/0x69f58c/0x69f5e1/0x6a4707`.
- `Random` → 81 CODE hits (D02+X03 distribution: RTTI cluster `0x60199f…`, `GenerateMap*` `0x69f4b5…`, map-gen `0x84179c…`); `Rand` superset behaviour carried from `DEC_U_genseed_deep` (no `RandSeed` among extras).
- `SetRandom` → 3 hits, but `0x659f5f` is `SetRandomOffsetByHandle(grhandle; randomoffset: Boolean)` + `GroupGetRandomOffsetByHandle` at `0x659fbb` — unrelated group/grid API, triaged out (`ev_918798d4…`, `ev_69be0fe1…`). Only the two table hits are seed APIs.
- `native_strings_find` for `RandomExt`/`randkey`/`GenerateMap` → 0 each (`ev_38c8e504…`, `ev_dccf25f0…`, `ev_99804968…`) with `data_sections_only` limitation — this **explains** D02 Anomaly A and proves the names live in CODE-embedded declaration tables, not DATA strings. [D]

### 2.2 Wrapper arities, byte-proven from 256-B signature rows [D]

Reading the contiguous declaration bytes (`ev_69f3e4a3…` … `ev_b7a88bc8…`):

| Declaration (exact bytes) | VA | Arity [D] |
|---|---|---|
| `function RandomExt(): Float` | `0x60a662` | 0 in → Float |
| `function GetRandomKey: Integer` | `0x60a68a` | 0 in → Integer |
| `procedure SetRandomKey(key: Integer)` | `0x60a6b2` | 1 in (`key`) |
| `procedure GetRandomExtKey64(var key0: Integer; var key1: Integer)` | `0x60a6e2` | 2 var-out |
| `procedure SetRandomExtKey64(const key0, key1: Integer)` | `0x60a72e` (+tail `0x60a731`) | 2 const-in |
| `procedure GenerateMapRandKey(var randkey0: Integer; var randkey1: Integer)` | `0x69f452` (prefix `4A` at `0x69f440`) | 2 var-out |
| `procedure GetMapGeneratorRandomKey(var randkey0: Integer; var randkey1: Integer)` | `0x69f4a6` | 2 var-out |
| `procedure SetMapGeneratorRandomKey(const randkey0, randkey1: Integer)` | `0x69f502` | 2 const-in |
| `procedure GetGlobalMapGeneratorRandomKey(var randkey0: Integer; var randkey1: Integer)` | `0x69f552` | 2 var-out |
| `procedure SetGlobalMapGeneratorRandomKey(const randkey0, randkey1: Integer)` | `0x69f5b2` | 2 const-in |

[D]: no hidden third parameter, no default, no `mix64`/`stable_hash(sid)` operand appears in any signature row. The trailing `(randkey0, randkey1: Integer)` at `0x6a46fd` is a further table row fragment, not a derivation body.

## 3. (b) 11+3 reseed sites — no statically decodable derivation [O→U]

- `native_xrefs_list` at every table name VA (`0x60a662/0x60a6b2/0x60a72e/0x69f452`, plus control `0x659f5f`) → **0 refs each** (`ev_b3ff60d2…`, `ev_05ad4a86…`, `ev_ac5ccebc…`, `ev_023cf48a3…`, `ev_496d6434…`). [O]
- [D]: the wrappers are reached only through the DScript native registry (`FUN_00608238`, carried D02 `ev_1858bbfd…`: `RandomExt→0x60f64c`, `SetRandomKey→0x60f6a4`, `SetRandomExtKey64→0x60f6dc`, …), i.e. VM-dispatched, never by a direct static `call`. The `static_references` limitation therefore applies: absence of xrefs is consistency, not a closed-world proof.
- The 11+3 sites themselves are donor-text `[*] = ;` identity passes (`D3:99/146`, `D1:1100/1161/1177/1213/1538/1616/1772/1909/1927` all `SetRandomKey(randkey1)`; `D2:216/513/774` all `SetRandomExtKey64(randkey0,randkey1)` verbatim — `spec/02 §5`, `X03`, `V01 P1/P2`). No derivation expression, no hash, no per-stage salt appears at any site in the readable text. [O, carried]
- Searched for an explicit derivation body: length-prefix at `0x69f440` confirms the X51 signature table (`4A`=74 + `GenerateMapRandKey…`), but `native_function_find` at `0x69f452`/`0x60a662` reports "not inside any discovered function", and no `b9 <declVA>` / pointer-to-string scan has ever returned a hit (D02 Anomaly D, X51-E4). [O]
- [D, narrow]: the static corpus contains **signatures + identity call sites, but no key-derivation function**. Any `GenerateMapRandKey` time/hardware/network formula stays **[U]** (probe §6 U-KEY). No invented derivation; `mix64` remains refuted as PORT APPROXIMATION (spec/02 §5, C8).

## 4. (c) Shipped `.map` headers — read-only check, no mapping proven

- Repo workspace `**/*.map` → **0 files** (re-checked this ticket). No repo map can byte-prove anything. [O]
- Donor read-only glob `C:\Games\Cossacks 3\data/maps/missions/*.map` → **38 mission maps** (`ukrmis1-5`, `tutmis1-2`, `rusmis1-5`, `framis1-5`, `engmis1-5`, `bonmis1-3`, `battle1-8`, `ausmis1-5`, incl `bonmis1.map`). Directory listing only; no binary executed/copied. [O]
- Carried [O] (`D02 §4.3`, `DEC_06_map_formats §7.1`): sampled `bonmis1.map:0x18c0f1 = 0x44a108f9`; version-13 maps place a large u32 at aligned word index 2, version-7 maps vary — consistent with `randkey1` but byte→field mapping never closed.
- [D, narrow]: nothing in this ticket ties a shipped-map header word to `0x8f2008` or to the `(randkey0,randkey1)` pair. The override claim ("a shipped map embeds a seed that overwrites process-start Delphi state") is **refused as unproven** and stays **[U]** with the map-load watch probe (§6 U-MAP). No header word is quoted as a key here.

## 5. (d) Do the 11+3 reseeds consume key1 only? Is key0 truly discarded?

Byte-proven structure (carried D02 `§4.2–§4.3`, re-anchored this ticket by constants re-read):

- `SetRandomKey(k)`: `state_lo=k`, `state_hi=k>>31` (sign extension) — normal skirmish `k≥0` ⇒ `hi=0`. [O]
- `SetRandomExtKey64(k0,k1)`: `state_lo=k1`, `state_hi=k0` at install, then the LCG's `mod 2^32` forces `hi=0` after the **first** draw; `k0` affects only draw #1 via the 64×64 cross term (`D02 §4.2` worked example `randkey0=0x44a108f9,randkey1=0` → first state exactly `0x3C6EF35F`). [O]/[D]
- The 11 `SetRandomKey` sites pass **`randkey1` verbatim** — `key0` never enters those stages. [O]
- The 3 `SetRandomExtKey64` sites pass **both words verbatim** (`randkey0,randkey1`) — so `key0` *is* presented to the engine three times per generation (`generatemap.inc:216/513/774`, with the `:190` mask pick running on the inherited stream *before* `:216`). [O]

[D, narrow]: "key0 is discarded" is true only in the post-first-draw sense. A strict runtime claim — "key0 has zero effect on every draw of every stage" — is **not byte-proven**: draw #1 after each of the 3 ext-reseeds still folds `key0` through the multiply, and per-object instances (`sub_7281bc` state `+0x18/+0x1c`, `0x408a57` state `+0x108/+0x10c`, three setters in `donewgame.inc:33-35` seeding different owners) have unanchored setter bodies (D02 U3/U6). It therefore stays **[U]** with the ±1 probe (§6 U-KEY2). The port keeps `reseed_from_key64` storing `key0` ledger-only and seeding `s=k1` (labelled approximation) until that probe terminates.

LCG constant note for honesty: `5F F3 6E 3C` recurs at 5 CODE sites (`0x60f66a/0x7281d7/0x72d2de/0x809664/0x8096ae`, `ev_81148ecd…`) and `B8 0D FC` reappears at `0x809640` (`ev_c76e1400…`) with the same twin shape as `0x60f64c` (`ev_4999a6cf…`); but the isolated `0D FC` byte pair also occurs 33× including a non-LCG `or eax,0x330000fc` at `0x60f65e` — so per-hit semantics are **not** claimed beyond the D02-anchored `0x60f64c–0x60f696` + `0x809640` + `0x7281bc` instances. No new arithmetic is asserted here.

## 6. Still-[U] fields — breakpoint dumps with zero-mismatch + restart termination

> Authorised debugger/trace worker only. Nothing here was run (donor execution prohibited). Each probe restarts the process at least once and terminates only on zero mismatches. No value is wired into the port until then.

### U-KEY — `GenerateMapRandKey` derivation (menu-seed → randkey0/1)

- Set two known menu seeds; dump `gMap.settings.gen.randkey0/1` before `initmapgen.inc:99` (`SetRandomKey(randkey1)`).
- **Terminate** when the mapping is a byte-exact closed form or 1:1 table over the tested seeds with zero mismatches. **Restart check:** regenerate from the same menu seed after restart — pair must reproduce exactly (else wall-clock/hardware source proven, still no invention).
- Port keeps two-word verbatim input.

### U-KEY2 — key0-discard at runtime (the §5 strict claim)

- Fix `randkey0=0,randkey1=K` (primary `K=1`; repeat `K=12345`), then `randkey0=0x44a108f9,randkey1=K` with everything else identical (`W=H=320`, `shape=nowater2`, `version=92`, `minesdensity=1`, `spcount=4`, `season=0`, `b_random_map=true`).
- Dump the `D2:190` mask pick + first three `RandomExt` floats after each `D2:216/513/774` ext-reseed, plus stage-`SetRandomKey` draws.
- **Terminate** when either (i) `key0`-only changes are bit-identical on **all** draws after draw #1 of each ext-stage AND differ at most on draw #1 exactly per the cross-term model (discard proven with the stated first-draw exception), or (ii) any post-#1 draw differs (discard refuted — record the diverging draw index and stage). Zero mismatches on the stated repeats required. **Restart-changes-seed check does not apply here** (fixed keys); instead repeat on two map sizes.

### U-MAP — shipped-map seed override

- On an authorised host with a readable generated map (`game_v…k….map`): (1) dump `gMap.settings.gen.randkey0/1` at load; (2) watch `0x8f2008` across map-load; (3) regenerate from the same menu settings.
- **Terminate** when either (i) a map-load write to `0x8f2008` is captured with its source VA (override proven), or (ii) `0x8f2008` is untouched by map-load across two map sizes while `randkey1` varies the RandomExt stream (override refuted, zero-mismatch on the untouched watch).

### U-SS — generation-time Delphi seed (`0x83272f` probe, carried tightened)

- Break at `0x83272f` (`mov [edx+4],al`). At the **first** hit of a fresh skirmish generation, dump u32 at `0x8f2008` **before** the `call 0x403a0c` at `0x832727` and the stored `al`. Log `(cell-corner, state-before, byte)` for the full `SetTileIndex` fan-out.
- **Terminate** when (i) every byte equals `state-before>>>24` with zero mismatches, AND (ii) the pre-first-hit state is recorded as that run's seed. **Restart-changes-seed:** restart + same menu map ⇒ seed must differ (QPC-wall-clock proof); same-process regeneration must continue the stream (no per-map reseed proof).

### U-ONLY — exclusivity of the `0x8326b8` draw (carried)

- Same break + hardware write-watch on `0x8f2008` for the whole generation; attribute every advance to its return address.
- **Terminate** when advance count equals accepted-cell count with zero unattributed advances, or the first unattributed advancer is recorded (either outcome closes the field).

### U-TIME — QPC-vs-TickCount branch (carried)

- Break at `0x4033bc`; log `eax` vs `je 0x4033d0`.
- **Terminate** when the taken branch + stored dword equal post-`sub_4033b8` `0x8f2008` with zero mismatch on two cold starts.

## 7. Port change list (file:line; no edits made here)

Carried from `DEC_U_gen_seed §5` / `DEC_U_genseed_deep §7` / `DEC_U_placement §8`, deltas **[NEW]** this ticket:

1. Delphi hook (`delphi_state_hook`, image 0 + NULL hook): keep. **[NEW]** cite `ev_5cc4b3b8…`/`ev_727d454c…` absence-of-second-vocabulary note is *not* a reseed proof — cite instead seeder/xref closure from `DEC_U_genseed_deep`. Never wire `_stage_begin` to `_rng_delphi`.
2. RandomExt single-stream + `SetRandomExtKey64` ledger: keep routing all ext-reseeds through `_rng` with idle diagnostics. **[NEW]** cite this-ticket arity table (§2.2): `SetRandomKey` arity 1, `SetRandomExtKey64` arity 2 const, `GenerateMapRandKey` arity 2 var-out. Amend the key0 comment to the §5 strict form: "hi=0 after first draw; first-draw cross-term only; runtime discard [U] (U-KEY2)".
3. `GroupGetRandomOffsetByHandle` / `SetRandomOffsetByHandle` (`0x659f5f/0x659fbb`): **do not wire** — triaged as unrelated grid API (`ev_918798d4…`). Add a one-line guard comment so a future `SetRandom*` grep does not re-absorb it.
4. Signature table cite: `0x60a662…0x60a731` + `0x69f440…0x69f5b2` + `0x6a46fd` fragment as the CODE-embedded RTTI anchor; note `native_strings_find` 0-hits are a tool limitation, not absence (`ev_38c8e504…` etc).
5. Mask pick / S1 gate / S0 / water / border / mines / forests / `Objects[]`: unchanged (`DEC_U_placement §8 P-PLACE-01..16`); this ticket adds no stage param.
6. Time-source imports (`0x907f00/0x9084fc` QPC, `0x907ef0/0x908688` GTC): informational only, never copied into the port (U-TIME owns the branch).

## 8. Bottom line

- **(a) NEW:** 12-name packed CODE search complete with VAs/FOs: seed API lives in two CODE RTTI runs (`0x60a662…0x60a731` RandomExt family; `0x69f440…0x69f5b2` + `0x6a46fd` map-key family); DATA-string search is 0 by tool design. Full signature arities byte-proven (§2.2). Third `SetRandom*`/`GetRandom*` hits triaged as unrelated group API.
- **(b) NEW:** all table VAs have 0 static xrefs (VM-dispatched via `FUN_00608238`); 11+3 sites are verbatim identity passes with no derivation operand; `GenerateMapRandKey` length-prefix re-confirmed but body still absent — derivation stays [U] (U-KEY).
- **(c) NEW:** 0 repo maps; 38 donor mission maps exist; no new header→key mapping proven — override stays [U] (U-MAP).
- **(d) NEW:** verbatim `randkey1` (11×) vs verbatim pair (3×) proven; LCG structure proves hi-zeroing after first draw, but strict runtime key0-discard stays [U] (U-KEY2) because draw #1 still folds `key0` and per-object setter bodies are unanchored.
- Delphi per-run seed at `0x83272f`/`0x8f2008` stays [U] (U-SS/U-ONLY/U-TIME). No invented seed/derivation. No parity claim.

*End of DEC-U-PLACE-SEED-DEEP. Files written: this report only. Donor read-only; no binary executed, copied or committed; no code, shader, config, asset, test, git, Godot or investigation-memory state changed. No parity claimed.*
