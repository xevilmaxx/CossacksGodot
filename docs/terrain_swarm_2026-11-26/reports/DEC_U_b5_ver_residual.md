---
id: DEC-U-B5-VER-RESIDUAL-2026-11-27
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: "WORKER DEC-U-B5-VER — residual B5 selector/live-settings angle: byte-proven native consumer of the version/envelope count or a settings-table read binding 53 vs 92"
owner_file: docs/terrain_swarm_2026-11-26/reports/DEC_U_b5_ver_residual.md
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION__NO_BIND_UNPACK
created: 2026-11-27
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe (x86 PE, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c). Verified by core_target_open BEFORE the first analysis call and by core_session_show AFTER the last call. Deep mode. Every native call pinned document=t_87f0f3c130b0. Binary never executed or copied."
labels: [OBSERVED, DERIVED, UNVERIFIED, NO_APPROXIMATION, PARITY_UNVERIFIED, NO_PARITY_CLAIM]
parity_status: UNVERIFIED
parity_claim: NONE
visual_parity_claim: false
chain: "0/6 CLOSED"
verdict: "RESULT IS NOT GOOD — no byte-proven native consumer of 53-vs-92 and no settings-table numeric default recovered; liveness and every numeric substitution stay [U]."
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
scope_guard: "Read-only donor static decomp only. No donor execution, no donor byte copy into the repo, no .bind unpacking, no source/shader/asset/config/test/fixture/result-JSON/Godot/git/user-mod state written. Only core_target_open, core_session_show, core_overview_show, core_feature_find, native_function_study and investigation/report core_* tools were used; core_evidence_browse was not needed; no native_* tool other than native_function_study was called. Exactly one repository file written: this report."
governing_sources:
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_b45_residual.md (§2 T-VER selector residual; string-table negatives; property tables at 0x842c30 / 0x71c280)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_tver_deep.md (shipped envelope 53/320²-384² vs port 92/240²; §1 CODE-literal census; §4 zero-mismatch failure)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_u_classify.md (§2.2 domain T all-B; §4 row B5 exact next static angle)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_u_register_update.md (§4 CLOSED-STATIC vs value-closure discipline; structural closure is not value closure)
---

# DEC-U-B5-VER-RESIDUAL — last native-selector / live-settings pass (2026-11-27)

> **Required reviewer line, verbatim:** PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

> No metric, gate, replay pair, ROI, still, hash or "close" value constitutes parity. `parity.claim = NONE`, `parity.status = UNVERIFIED`, `visual_parity_claim = false`. This report closes **zero** P0 items, promotes **zero** `[U]`→`[D]` selectors, invents **zero** version/mapsize values, wires **zero** port behaviour, and makes **no parity claim**. `blocking_unverified` remains non-empty; six-condition chain **0/6**; **`RESULT IS NOT GOOD`**.

> `[O]` = observed bytes/tool output, re-read where material. `[D]` = arithmetic/control-flow/structural consequence over cited `[O]`; every `[D]` carries an evidence id and a stated address. `[I]` = reading without runtime proof. `[U]` = unresolved after the passes here. `ev_…` ids are per-pass Craft Anything evidence ids on `t_87f0f3c130b0`, not port test ids.

## 0. Question, method and pass ledger

**Question (residual B5, exactly as scoped by `PORT1TO1_u_classify.md §4` row B5 after `DEC_U_b45_residual.md`):** is there any **byte-proven native consumer** of the shipped envelope version count (53) or a **settings-table read** that binds 53 vs 92 to the map-generator path — i.e. can T-VER's live selector be settled statically beyond the already-proven string-table negatives?

**Answer:** No. No such consumer and no such read was recovered. The string index does not contain any of the 17 version/envelope/generator-settings literals; the native regions that do carry those literals disassemble as data-as-code and are referenced only as **data** (never as an executed version comparison or a generator call); the settings table's 30 incoming references are all data references that pass the table address to a Delphi dynamic-array length routine; and a full immediate scan of the 3,115 disassembled instructions in the 13 studied functions found **no** standalone `0x35` (53), `0x5C` (92), `0x140` (320) or `0x180` (384) constant — the only such byte patterns are addressing displacements. Every liveness and every numeric substitution therefore stays `[U]` with the exact zero-mismatch terminations of §5.

Pin was verified before the first analysis call (`core_target_open` → `target_id t_87f0f3c130b0`, `sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c`, 5,768,048 B) and again after the last (`core_session_show` → same active target and hash, deep mode). `core_overview_show` (`ev_60b497434aa3e6cb68b019fd0a3b016ec0415ef6ec1a3189726faa8d3752f4c4`): 18,918 functions / 12,073 strings / 746 imports; limitations `instruction_limit` (discovery stopped after 6,000,000 instructions — function list incomplete), `indirect_jumps_unresolved` (1,238), `stripped_binary`, `static_analysis_only` (computed-pointer / run-time-only functions may be missing; **absence is not proof**).

| Pass | Operation (read-only, `document=t_87f0f3c130b0`) | Result |
|---|---|---|
| P1 | `core_feature_find` × 17 version/envelope/settings literals | **all 0** strings / 0 function names / 0 imports / 0 functions involved (§1.1) |
| P2 | `core_feature_find` × 12 control probes | tool functioning: `CreateFileA` 2 strings + 3 function names + 3 functions + 2 imports, `Ver` 54, `OSW` 79, `Map` 31, `kernel32` 5, etc. (§1.2) |
| P3 | `core_feature_find` string-list paging on `OSW` / `Ver` / `generator` / `serial` / `Terrain` / `Map` | indexed version-like surfaces are Delphi RTTI class names + PE file-version APIs, **all 0 references** (§1.3) |
| P4 | `native_function_study` (summary → complete) on `0x710be0`, `sub_710380`, `sub_405454`, `sub_405400` | envelope string region is data-as-code; string used only as data twice by a registration function (§2) |
| P5 | `native_function_study` on `0x683bb7` / `sub_683bb0` | shell `DataVersion` string region is data-as-code, 1 data ref (§3) |
| P6 | `native_function_study` on `0x71c30e` → `sub_71c0b4`, its 6 data-referencing functions, `sub_71c038`, `sub_406d50`, `sub_406ba4`, `sub_406e7c`, `sub_406b7c` | settings table is data-as-code; 0 code callers, 30 data refs; consumer is a dynarray set-length routine (§4) |
| P7 | Immediate scan over the 13 complete dossiers (3,115 instructions) | zero standalone version/size constants; only displacement bytes (§4.4) |
| P8 | `core_session_show` re-verification | active target and SHA unchanged; evidence ledger intact |

**Strange-read log / standing reserves.** `core_feature_find` searches the **extracted string index** (function names, imports), not raw file bytes; a 0 result is *absence from the index*, not engine-side or file-byte absence — the tool itself reports limitation `no_match`: "nothing matched; the text may be built at run time, encrypted, or come from a resource file (absence is not proof)". The prior reports' `native_bytes_find` positives for these same names (e.g. `OSWMap13` ×8 at `0x710bfc…`, `DefaultMapSize` ×2 at `0x71c30e/0x71d19c`) are CODE-embedded, length-framed strings and are **not** present in the index; both observations are consistent and neither is promoted to a value. `native_function_study` limitations apply throughout: `register_level`, `calling_convention_assumed`, `conditions_from_flags`, `pseudo_code_inferred`, plus `unstructured_flow` / `inline_asm` / `indirect_jumps_unresolved` on the data-as-code regions. A `callers: 0` count means **zero code calls**; it does not mean zero data references — the two are reported separately below. No donor binary executed; no donor bytes copied into the repo; no `.bind` unpacked.

## 1. Pass A — `core_feature_find` index census

### 1.1 All 17 target literals are index-absent [O]

Every call: `core_feature_find({query, document:"t_87f0f3c130b0", case_sensitive:true})`. Each returned `0 matching strings, 0 matching function names, 0 matching imports; 0 functions involved`, limitation `no_match`.

| Query | Evidence id | Query | Evidence id |
|---|---|---|---|
| `OSWMap13` | `ev_b96ee72782207e377c5481bf80e1b03a90be004943115c96226132ab68bfebae` | `TileSmoothPasses` | `ev_86bb467fce7a1f92a5dc50bff3762a11aca49ea7bcb2b4daa4b20b54b6a57264` |
| `Map.Ver` | `ev_d9b5de590d1a94b19bf521a3075364233063ad2e246234eb005884b9c006eeb9` | `gRecordGeneratorVersion` | `ev_24ab78db50cd1070e206d64389670af5a6b3faa6a1ea2a5cd62a1289efc649df` |
| `Build.Ver` | `ev_13070181e07a38b2fcea0bfd757dd375bf7b37b09ac8c3c23d7960504cadac22` | `gDataVersion` | `ev_69b31eeb1b170403f68ed0975b49c13cca7c0c66654abc22af3e331a044071e3` |
| `Core.Ver` | `ev_ec43a2e6c5ab285996ec6e14a936677d4cd30963ca08d34908141eb405ae7143` | `mapsize` | `ev_9c2892a3aae1f049c4143cc82afe34ce5de56f04e0094fd8f71eba52ed2b4189` |
| `OSWMap13.Map` | `ev_c6c556aae0dfe2c661cf50a89132a25ca16f84b82ec3ad7e845eddfc75382f4e` | `TerrainTypesDLC5` | `ev_da977f44840232d6d0d9562e304ace3c4af3ff0fdcbac6718c00cd5e0fcdf088` |
| `GameMapRecordBegin` | `ev_ddb426927363ef95e4f2859614e088a52b372ac8837c90875d10caf3ac16b139` | `gc_MaxTerrainTypeCount` | `ev_149a2f0d15e52588cf9d3a338da375d8f74fe30264cb21820de089bddd6293c6` |
| `GameMapSnapShotBegin` | `ev_7a54a8a2d55cbd5e206ddf2bb195e16ee328b73551ed3c337916a1b831e712a4` | `ParserGetIntValueByKeyByHandle` | `ev_161b083f9d44ab5df9bfb8be229d2a3f50f206f85edde552b18ad743070f721a` |
| `TerrainMapBegin` | `ev_416b4f2f5a4124da37bfc663be1f460c938a798bb454caf139b417f37114310b` | `ParserGetFloatValueByKeyByHandle` | `ev_7d73935f924e94f012d7cb940ccec28ffbc922d6dd70d542665fd381e57acb63` |
| `DefaultMapSize` | `ev_e7631689c27031ee401c1c7ba8ffc37f1f983c421846a9ab9dfe8e187a6e902a` | | |

- **[D] consequence:** `core_feature_find` cannot start a string→code walk for any of these names. The B5 "live-settings dump" half therefore cannot be replaced by an index xref sweep: there is no indexed anchor from which to reach the generator path. This *narrows structure* only; per the discipline rule a structural closure is **not** a value closure.

### 1.2 Control probes prove the tool was working [O]

`kernel32`: 5 strings (`ev_6a79be703d91dc5e7fd9741731815c05f32ee5c33651e57ae50e53b7495db8ba`). `CreateFileA`: 2 strings, 3 function names, 3 functions, 2 imports (`ev_5d9f5e81e27eeebe4d8a6f52e534e8ac36cdcb34faafbba7e828940c16122b7a`). `OpenGL` 5 (`ev_de6451d3953f79f222c5e79857e34585a1a8d7d70b1848da6c8ceec54dfddd74`). `Direct3D` 2 + 1 import (`ev_7f145d0f08a0e026fef470eb7dfbbbb0b04e95232978914c3e0b51a3c667bf3d`). `Ver` 54 strings / 12 function names / 14 functions / 14 imports (`ev_ffe922c8c8b4c3b121ecbf92a396a408a3a929be43ed14d6230d3203236ab886`). `OSW` 79 (`ev_9b1bdf76dde5e6aaf230ed0f2fa8158824268056cc825b5cd46c259b2bb141bf`). `Map` 31/10/10/14 (`ev_0a4099d72cda1d719bb518a9345b68327aebe2068877abe40f41f25ebf9629d0`). `generator` 2 (`ev_8f4b5d263c9e86a3601508c61afab612bea5b7830c77ce4e351663adecc5661d`). `Terrain` 4 (`ev_9dad1f270a0f36352fcb15bfd7abe5b8468028c5643459e6c74236012f9ca45c`). `serial` 1 (`ev_cfbccdd4ba33802f1d3e6cbaab1bbc4e9dc7c7bdb1a27334ba5d6eb59d9c1a72`). Two extra negatives: `Map saving` 0 (`ev_2dd012a2fe1b7460338adbb995760b69a60cc9f9ed62ac5b3cbe9db6be06e7a2`) and `GameMap` 0 (`ev_15743afdce924f19ec5d244860f57e5aed1cc541e5a16fb04851b30743bde1ff`).

- **[D]:** the 17 zero results in §1.1 are a property of the *index vs CODE-embedded string* split, not a broken tool. They do **not** contradict the prior reports' raw-byte hits; nor do the raw-byte hits supply a native consumer.

### 1.3 The indexed "version" surfaces are a different namespace [O]

Paging the positive string lists (`ev_9b1bdf76…`, `ev_ffe922c8…`, `ev_8f4b5d26…`, `ev_9dad1f27…`, `ev_cfbccdd4…`, `ev_0a4099d7…`) shows the only version-like indexed strings are:

- Delphi RTTI class names at `0x958xxx–0x959xxx`: `XMapGenerator @0x959430`, `XTerrainDataLite @0x9587c3`, `sXTerrainData @0x958b75`, `EXTerrain @0x958649`, `XGlobalMap @0x9593e2`, `OSWSerializer @0x958679`, `SXDScriptMap @0x959572` — every one `references: []`, and `core_feature_find` reports 0 functions involved.
- PE **file**-version APIs/resources: `GetFileVersionInfoSizeA @0x908a90`, `GetFileVersionInfoA @0x908aaa`, `VerQueryValueA @0x908a7e`, `version.dll @0x908a70`, `VS_VERSION_INFO @0x96b10a`, `FileVersion @0x96b20e`, `ProductVersion @0x96b322`, `GetVersion @0x907f1a` — all `references: []`; plus `: unknown archive version  @0x953c9c` (`references: []`).

- **[D]:** these are the OS/PE build-version and class-RTTI namespaces, **not** the serial `gDataVersion` / record `ver` / envelope-count namespace. None yields a function, so none is a candidate native consumer of 53 vs 92. No value is read from any of them.

## 2. Pass B — envelope format string: data, not an executed version consumer

`native_function_study` on the CODE address `0x710be0` (the envelope format-string anchor cited in `DEC_U_tver_deep.md §1.5`) resolves to `sub_710be0`:

- Complete dossier `ev_7443cdc5111c0bc99eae44bb6a000fd1bbb7d314a2a76cc44b1eb9e4db77aa58`: 1 block / 2 instructions / `body_ranges [[0x710be0,0x710be4]]`, `xor [esi], ch` @`0x710be0`, `xor [eax], al` @`0x710be2`, `callers: 0`, `callees: 0`, `referenced_strings: []`, `unresolved_calls: []`. The summary (`ev_c80d8db599d97bec6cc86a0e4c1eca2371e079f1734f5e2ca9a0d43fffced083`) records **2 incoming references**. **[O] → [D]:** ASCII format-string bytes disassembled as nonsense instructions; the region is data, not an executed selector.

- The 2 incoming references (complete dossier) are both `kind: "data"` from `sub_710380`, at **0x7103d4 → 0x710be0** and **0x71069b → 0x710be0**. `sub_710380` complete dossier `ev_eec6cf7ea8c15d54575b50c0b3c4d1856f5d1784cb760c4fc30d812a131e6b4e`: 5 blocks / 498 instructions / 100 calls / **0 callers** / 130 referenced names; byte window `0x7103c0..0x7103e8`: `mov eax,ebx` (`0x7103c0`), `call 0x42e3c0` (`0x7103c2`), `mov byte [ebx+0x198],0` (`0x7103c7`), `lea eax,[ebx+0x19c]` (`0x7103ce`), **`mov edx,0x710be0` (`0x7103d4`)**, `call 0x405454` (`0x7103d9`), `mov dl,1` (`0x7103de`); second window `0x710687..0x7106a7`: `lea eax,[ebx+0x78]` / `call 0x405400` (`0x71068a`) / `lea eax,[ebx+0x7c]` / `call 0x405400` (`0x710692`) / `push eax` (`0x71069a`) / **`mov eax,0x710be0` (`0x71069b`)** / `mov [ebp-0x24],eax` / `mov byte [ebp-0x20],0xb`.

- `sub_405454` complete `ev_f8cfed49e0673cf56057abde6482d110b671f5b1ca42af4c730d799ef88ed6d5`: `lock inc/dec dword [edx-8]`, `xchg [eax],edx`, `call 0x402eac` — a Delphi **refcounted string-slot assignment**. `sub_405400` complete `ev_87d4812d9628bd20cb97f8b1ee5f5cacd840d409adf63369c587e22bd78b17a5`: `mov dword [eax],0`, `lock dec [edx-8]`, `call 0x402eac` — a Delphi **string clear/release**.

- **[D]:** the only byte-proven native uses of the envelope format string are (i) storing it as a field value at `ebx+0x19c` via a string-assign helper and (ii) constructing a short string on the stack. Neither is a comparison against a version integer, and neither calls a generator routine. The `0xb` at `0x7106a3` is a string-length byte in that construction; it is **not** a version or mapsize value and is not decoded as one. With `sub_710380` at 0 code callers, no caller-side version branch is localized from this region.

## 3. Pass C — shell `DataVersion` string: data, not an executed consumer

`native_function_study` at `0x683bb7` resolves to `sub_683bb0` (`ev_41a5ffdfc547825d44d95d47a94ab5caa5c875f9a8700b9d2b842aebefad69a6`, summary `ev_42c7ba9225da8b13e78760c224b7a547830b2048fad61952af5cbef4b40c7e76`): 4 blocks / 10 instructions / 1 incoming reference / `referenced_strings: []`; assembly `insb [edi],dx` @`0x683bb0`, `push 0x446c6c65` @`0x683bb3`, `imul ebp,[edi+0x6e],0x6c696146` @`0x683bbf`, `and fs:[0xffff0020],bh` @`0x683bc6` — **ASCII bytes read as instructions** (`0x446c6c65` ≈ "elleF", `0x6c696146` ≈ "Faili" fragments of `…ShellDataVersionFailed`). The single incoming reference is `kind: "data"` from `sub_67e420` @`0x67f651`. **No executable version consumer** is present; no `0x35` / `0x5C` version constant occurs in the dossier. This re-affirms `DEC_U_tver_deep.md §1.2` ("shell strings, NOT the serial global") with a different tool and adds the data-reference characterization.

## 4. Pass D — settings table: 30 data refs, no decoded default, no generator binding

### 4.1 The "function" over the table is data-as-code [O]→[D]

`native_function_study 0x71c30e` resolves to `sub_71c0b4` (summary `ev_74a84c26e4fea1db3b632e414377e336ca7fd3934528666714e9b2e0cf2d3243`; complete `ev_85467957f6fa2ab75623a91a9dc23191980a8c5d8d2f4c5006aed8ed37a8251a`): 407 blocks / 922 instructions / `callers: 0` / `callees: 6` (5 indirect, unnamed; 1 direct `sub_71c038`) / **5 unresolved indirect calls** (`0x71c4e4, 0x71c512, 0x71c568, 0x71c27d, 0x71c22e`) / 1 unresolved indirect jump / `referenced_names: 4` (a jump to `sub_71c038` and three `data` refs to `sub_401084` at `0x71c2c7 / 0x71c319 / 0x71c55e`). Pseudocode is `outsb / bound / arpl / imul` nonsense over ASCII property-name bytes — the expected signature of a data table disassembled as code. Its direct target `sub_71c038` (`ev_79e423a38bfc8dfc0329cf7b4f1c813dab6e57ef25b12302477f0d944268c82c`) is **one instruction, `ret`** — a no-op stub. **No table schema, no field type tag, no default word and no generator call is decoded from this region.**

### 4.2 The 30 incoming references are all DATA, from 6 functions [O]→[D]

`incoming_references` in `ev_85467957…`: 30 entries, every one `kind: "data"`, `callers: 0`:

| Function | Data-ref count | Evidence id (complete dossier) | Example sites |
|---|---:|---|---|
| `sub_71d2fc` | 8 | `ev_0b228dac100000d4f71a9e24394a1583a22822d5ae144f6ed2e6557d7acd7224` | `0x71d381, 0x71d3a0, 0x71d3bf, 0x71d3de, 0x71d402, 0x71d426, 0x71d44a, 0x71d4b6` |
| `sub_71da24` | 8 | `ev_5c40d7071aabf4c47f39815b8da5b2de60fda3aa7786eab94b6543de18397216` | `0x71da3b, 0x71da64, 0x71da90, 0x71dabc, 0x71daed, 0x71db1e, 0x71db4f, 0x71dbe2` |
| `sub_71e06c` | 8 | `ev_3cc03bec5ad6a3ecb231aa5c8042e670dde335b594346f1f656cd52f099d657a` | `0x71e083, 0x71e0a0, 0x71e0bd, 0x71e0da, 0x71e0f7, 0x71e114, 0x71e131, 0x71e188` |
| `sub_71ef40` | 1 | `ev_9c6bfd2aecdf60786e9769f22bae370315120c71ed4781bd58ae55627be31125` | `0x71f3f7` |
| `sub_71f968` | 1 | `ev_02e9b2d4a2830394848499cbf45cb42c200f7d8316c736140fe063823c33367e` | `0x71fcc4` |
| `sub_71fdc4` | 4 | `ev_aab76219328dfa9a2cd0c18b2c4776e61dbe036518d284047f8e030ea44da3fc` | `0x71fe0d, 0x71ffc6, 0x71ffe1, 0x71ffef` |

The recurring byte pattern in each is `sub_71c0b4 (data, table base) → call sub_406d50` (e.g. `0x71d381 → 0x71d387`, `0x71da3b → 0x71da41`, `0x71e083 → 0x71e089`, `0x71f3f7 → 0x71f3fd`, `0x71fcc4 → 0x71fcca`, `0x71fe0d → 0x71fe13`) or `→ call sub_406e7c` (the `0x71ffc6/0x71ffe1/0x71ffef` group). In the `sub_71da24`/`sub_71e06c` runs the next call is `sub_71d8d4`; in `sub_71d2fc`/`sub_71e06c` other rows are `sub_71c678`, `sub_71c6c8`, `sub_71c718`, `sub_71c5d8`.

### 4.3 The consumer is a generic Delphi array/string runtime helper, not a version reader [O]→[D]

- `sub_406d50` (`ev_a15636bea6071d3e539a06cddc67f1a70b83fbf7f087928883f5729ad4c26444`): 1 block / 4 instructions — `push esp` @`0x406d50`, `add dword [esp],4` @`0x406d51`, `call 0x406ba4` @`0x406d55`, `ret` @`0x406d5a`; called from **201** places. A stack-fixup thunk.
- `sub_406ba4` (`ev_61f9b115c8e63c27af545242f6092f3090faf9a6895e568f3bfc242ea84695ac`): 28 blocks / 156 instructions, `imul esi` @`0x406c1c`, `idiv ebx` @`0x406c25`, refcount/length header at `[ebp-0x18]`, recursive `call 0x406ba4` @`0x406d34`, `ret 4` — a Delphi **dynamic-array set-length** routine. No version key, no `0x35`/`0x5C`, no generator call.
- `sub_406e7c` (`ev_5a7cac61cc75ab2945cd9a1851cc005391f2b145060f50c828f04fc632cecb9a`): 7 blocks / 22 instructions, `lock dec dword [ecx-8]` @`0x406e88`, `call 0x402eac` @`0x406eaf`, called from 103 places — a Delphi **interface/string release** helper.
- `sub_406b7c` (`ev_59a8febb4f4368127ea3442575e2ae32837c36118b0c087ad2caa0ed57334bf6`): `call 0x406b74; dec eax; ret`, called from 224 places — trivial runtime helper.

**[D]:** the settings-table address is consumed as an *item in a data/array construction*, not as a numeric default and not by a version comparator. No byte-proven callee in these dossiers is a generator routine (the remaining callees are unnamed `sub_…` addresses, not byte-named as generator functions). The `DefaultMapSize` / `TileSmoothPasses` row values therefore remain **undecoded**; a numeric binding to 53 or 92 is refused.

### 4.4 Immediate scan — no 53 / 92 / 320 / 384 constant [O]→[D]

Across the complete assembly arrays of all 13 studied functions (`sub_710380` 498, `sub_710be0` 2, `sub_683bb0` 10, `sub_71c0b4` 922, `sub_71d2fc` 261, `sub_71da24` 196, `sub_71e06c` 102, `sub_71ef40` 423, `sub_71f968` 303, `sub_71fdc4` 199, `sub_406ba4` 156, `sub_405454` 29, `sub_405400` 14 = **3,115 instructions**), a token scan for `0x35`, `0x5c`, `0x140`, `0x180` found **no standalone immediate**. Every occurrence is an addressing displacement, e.g. `mov [ebx+0x5c], esi` @`0x710491`, `mov eax,[eax+0x5c]` @`0x71efce`, `mov ecx,[edx+0x5c]` @`0x71f9dc`, `mov [ebp-0x3c], eax` @`0x71efc8`, `lea eax,[ebx+0x140]` @`0x710a96`; the `sub_71c0b4`, `sub_683bb0`, `sub_710be0` and helper dossiers contain none at all.

- **[D]:** treating a `+0x5c` struct offset as "version 92", a `+0x140` offset as "size 320", or an isolated `0xb` string-length byte as a version is a numeric substitution with **zero byte proof** and is refused. No value is invented; nothing is wired into the port.

## 5. Still-`[U]` — exact zero-mismatch terminations

| ID | Statement | Termination (zero mismatch, else stays `[U]`) |
|---|---|---|
| U-TVER-SELECTOR | Live integers selecting the version-gated branches (`gRecordGeneratorVersion` `<80/<91`, `mapsize>2` ≡ 256-cell TINY, `v<91 → 6-way else N-way`, mine-band matrix, 16×8 fallback); which live `gDataVersion` / `gRecordGeneratorVersion` / `mapsize` / `gc_MaxTerrainTypeCount` values are active in a session | **Owner live-settings dump + paired-save battery**: record `ver` integers on both sides of v91, menu mapsize/terraintype indices, and the re-save `5C 00 00 00` control, compared against fixed shipped heads (`35 00 00 00`=53 envelope, `OSWMap13.Map.Ver[0.0]Build.Ver[2.0.0.2843]Core.Ver[1]`, terrain 320²×3 + 384×1, sub=4, w4 64 vs 25920) with **0 mismatching words** across ≥2 shipped maps plus the paired-save control. Until then 92 is the current-script-word literal only and 240² is a port debug alias. **Not run by this worker.** |
| U-TVER-NATIVE-VALUE | Any CODE-constant version/mapsize default (a `DefaultMapSize` numeric default, a `ver` constant, a mapsize-enum jump table) | **Typed table-schema decode**: table schema (field length / type tag / default-word layout) byte-proven from a second anchor (a second table instance with the same framing, or a reader function consuming the framing), then the default word read through that schema — never by guessing adjacent bytes. §4 found data refs and a generic array helper, **not** a schema anchor; no default word was read. |
| U-B5-NATIVE-CONSUMER (new residual) | A byte-proven **executable** native consumer of the envelope count (53) or of a settings-table default on the generator path | **Computed-pointer-respecting xref trace** from a version-comparison or generator call site into `0x710be0`/`0x683bb7`/`0x71c0b4`, byte-proving a compare/branch on a version integer and the table schema for any consumed default, followed by the §U-TVER-SELECTOR 0-mismatch dump on ≥2 shipped maps + paired-save control. Passes P1–P7 found only index absence, data-as-code regions, data-only references and generic runtime helpers; no such consumer exists in the recovered bytes. One matching call site does not close it; the zero-mismatch dump is mandatory. |
| U-LIVENESS | Liveness of every dumped literal and of the 30 data references / 6 referencing functions | A donor session capture (owner-authorised, forbidden to this worker) showing the read executes and which value it carries, then the same 0-mismatch dump above. Static data references prove only structure; they do not establish that any row is read in a skirmish session. |

**Denied by this report:** any promotion of 53, 92, 240, 320, 384, 9, `0xb`, `+0x5c` or `+0x140` into a byte-proven generator constant; any claim that the 30 data references are executed version comparisons; any claim that the index 0-hits prove engine-side absence; any port behaviour change or value wiring; any parity or near-parity claim.

## 6. Claim register (audit-level; no parity)

| # | Claim | Label |
|---|---|---|
| 1 | Pin re-verified before/after: `t_87f0f3c130b0`, sha256 `87f0f3c130b0…`, deep mode; `core_overview_show` reports 18,918 functions / 12,073 strings / 746 imports with `instruction_limit` (6M insns), 1,238 unresolved indirect jumps, stripped + static-only caveats | [O] `ev_60b497434aa3…`, `core_target_open`/`core_session_show` |
| 2 | `core_feature_find`: all 17 version/envelope/settings literals 0 strings / 0 function names / 0 imports / 0 functions involved, limitation `no_match`; 12 control probes positive → tool working; result is index-vs-CODE split, not engine-side absence | [O] §1.1 table + §1.2 |
| 3 | Indexed version-like strings are Delphi RTTI (`XMapGenerator @0x959430`, `XTerrainDataLite @0x9587c3`, `sXTerrainData @0x958b75`, `OSWSerializer @0x958679`, …) and PE file-version APIs/resources (`GetFileVersionInfoA @0x908aaa`, `VerQueryValueA @0x908a7e`, `VS_VERSION_INFO @0x96b10a`, `FileVersion @0x96b20e`, `ProductVersion @0x96b322`), all `references: []`, 0 functions involved — a different namespace from serial `ver` | [O]/[D] `ev_9b1bdf76…`/`ev_ffe922c8…`/`ev_8f4b5d26…`/`ev_9dad1f27…`/`ev_cfbccdd4…` |
| 4 | Envelope string region `0x710be0` = `sub_710be0` data-as-code (2 nonsense insns, 0 callers); referenced only as **data** twice by `sub_710380` at `0x7103d4` (`mov edx,0x710be0` → `call sub_405454`) and `0x71069b` (`mov eax,0x710be0` → stack short-string build); `sub_405454` = refcounted string-slot assign, `sub_405400` = string clear; no compare/generator call | [O]/[D] `ev_7443cdc5…`, `ev_eec6cf7e…`, `ev_f8cfed49…`, `ev_87d4812d…` |
| 5 | Shell `DataVersion` region `0x683bb7` = `sub_683bb0` data-as-code (10 ASCII-as-insn words, incl. immediates `0x446c6c65`/`0x6c696146`), 1 data ref from `sub_67e420` @`0x67f651`; no executable version consumer | [O]/[D] `ev_41a5ffdf…` |
| 6 | Settings table `0x71c0b4` = 922-insn/407-block data-as-code with 0 code callers, 5 unresolved indirect calls and tail-call to 1-insn `ret` stub `sub_71c038`; **30 data refs** from 6 functions (`sub_71d2fc` 8, `sub_71da24` 8, `sub_71e06c` 8, `sub_71ef40` 1, `sub_71f968` 1, `sub_71fdc4` 4), each passing the table address to thunk `sub_406d50` → dynarray set-length `sub_406ba4` or to release helper `sub_406e7c`; no schema/default/generator binding recovered | [O]/[D] `ev_85467957…`, `ev_79e423a3…`, `ev_0b228dac…`, `ev_5c40d707…`, `ev_3cc03bec…`, `ev_9c6bfd2a…`, `ev_02e9b2d4…`, `ev_aab76219…`, `ev_a15636be…`, `ev_61f9b115…`, `ev_5a7cac61…` |
| 7 | Immediate scan of 3,115 instructions in 13 functions: zero standalone `0x35`/`0x5c`/`0x140`/`0x180`; all matches are displacements (`[ebx+0x5c]`, `[ebp-0x3c]`, `[ebx+0x140]`). No numeric substitution byte-proven | [O]/[D] dossiers in §4.4 |
| 8 | Port pins (`C_BROKEN_GENERATOR_VERSION=92`, `generate()` default 92, `config.json` 240²) still fail the first word against shipped 53 envelope / 320²-384² extents per `DEC_U_tver_deep.md §4`; **cited, not re-derived**; no value promoted here | [D] carried from governing sources |
| 9 | No donor binary executed, no GPU frame captured, no harness/gate/replay run, no port capture compared, no `.bind` unpacked, no donor bytes copied; exactly one repository file written | [O] scope guard + session re-check |
| 10 | `parity.claim = NONE`, `parity.status = UNVERIFIED`, `visual_parity_claim = false`; chain **0/6 CLOSED**; `RESULT IS NOT GOOD`; no approximation authorised | [D] §§0–5 + scope guard |

> **Verdict (governing form):** `port=UNVERIFIED`; `parity.claim = NONE`; `parity.status = "UNVERIFIED"`; `visual_parity_claim = false`; `blocking_unverified` non-empty; six-condition chain **0/6 CLOSED**. The last static selector/settings angle is exhausted without a byte-proven native consumer of 53-vs-92 and without a typed settings-table default; T-VER liveness and all numeric substitutions remain `[U]` under the §5 zero-mismatch terminations. **`RESULT IS NOT GOOD`.** No same-camera donor/port A/B frame exists; no approximation is authorised; no parity claim is made.

*End of DEC_U_b5_ver_residual. Read-only; exactly one repository file written; no source/asset/config/test/runner/Godot/git/donor-execution/donor-copy/.bind-unpacking; parity UNVERIFIED.*
