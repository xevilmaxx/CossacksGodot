---
id: DEC-U-NB2
worker: DEC-U-NB2 (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
ticket: "NB-2 HF/MDEN/OBJ residual (class-B B5 residual; refines DEC_U_relief_stamps + DEC_U_n17_gaps)"
date: 2026-11-27
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
labels: [O, D, I, U]
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. No donor binary executed, copied, committed, or captured. No donor file written. No GPU frame captured. All calls pinned document=t_87f0f3c130b0, Deep mode (engine 0.6.1, Ghidra-backed target already open; builtin clean-room lifter used for reads)."
scope_guard: "No repo code/asset/shader/config/test/fixture/result/Godot/git change. Exactly one repo file written: this report."
multi_pass: true
upstream: "PORT1TO1_b_angle_index.md NB-2 (HF/MDEN/OBJ residual, refines B5); DEC_U_relief_stamps.md (formula table [O], per-pattern Scale/Min/Max/Offset/TerrainScale + minangle/maxangle + Objects[] [U]); DEC_U_n17_gaps.md N17-G5/G6/G7/G8 (tail/binding/height-angle/tiles.lib [U]); DEC_U_tver_deep.md §2.2/§3.2/§4.2 (4th-word 64-vs-25920 residual)"
parity_status: UNVERIFIED
parity_claim: NONE
visual_parity_claim: false
verdict: "RESULT IS NOT GOOD for NB-2 static angle alone — CODE-embedded property/API tables + parser binding + shipped pattern.lib concretes byte-proven [O]/[D] below, but no per-pattern float is promoted into the generator, no angle/use rule is proven, no Objects[]-to-mesh binding is recovered; every value/behaviour item stays [U] with a map byte-dump zero-mismatch experiment; no approximation."
---

# DEC-U-NB2 — NB-2 HF/MDEN/OBJ packed-CODE search

> Authority: `[O]` = verbatim bytes/text/instruction lifted this ticket, pinned `t_87f0f3c130b0`, or verbatim shipped `pattern.lib` lines read read-only; `[D]` = deterministic consequence of `[O]`; `[I]` = interpretation; `[U]` = UNVERIFIED with settling experiment in §6. No parity claim. Port keeps all hooks NULL/missing until probes terminate.

## 0. What was asked and what is delivered

Execute class-B candidate NB-2 (`PORT1TO1_b_angle_index.md §3`): packed-CODE byte search for `HeightFieldScale`, `TerrainScale`, `HeightFieldMin`, `HeightFieldMax`, `ObjectsScale`, `ObjectsHeightOffset`, `minangle`, `maxangle`, `Objects` property/API names with VAs (CODE-embedded tables); inspect wrapper arities and any native consumer of those fields; check shipped `pattern.lib` data read-only for byte-proven values; only byte-proven results become `[D]`. All still-`[U]` items get map byte-dump zero-mismatch experiments. No invented float; no parity claim.

**Net result: property/API tables FOUND in CODE `[O]`; parser ctor binding FOUND `[O]/[D]`; wrapper arities byte-proven `[O]`; four shipped-section concretes transcribed `[O]`; everything else stays `[U]`.** Specifically:

- The `0x75c6a0–0x75ca2c` CODE-embedded property-name table (37+ entries incl. every NB-2 needle except `minangle`/`maxangle`) is byte-proven with VAs/file-offsets (§2).
- Its sole native consumer is `sub_75c314` (237 insns, `ev_e12db845…`): each name VA is passed as `edx` to a typed reader and stored into a fixed struct offset with a byte-proven default immediate (§3). `minangle`/`maxangle` have **zero** entries in this table and **zero** keys in `pattern.lib` — they exist only as `StandPatternWithAngle(+Adv)` call-site args (§4).
- `StandPattern` / `StandPatternWithAngle` / `StandPatternAdv` / `StandPatternWithAngleAdv` signature strings in CODE (`0x6a33e6–0x6a35c6+`) give byte-proven arities (§4); wrapper bodies/VAs remain undiscovered (no xrefs, `native_function_find` returns "not inside any discovered function"), so arg semantics stay `[U]`.
- Shipped `pattern.lib` (30,309,138 B) per-section `HeightField*/TerrainScale/Objects*/RotationAngle/Offset*` concretes for `brush_plt_15x15_2`, `hil1`, `g_hil4`, `k_ravine_1`, `g_mnt_1` transcribed `[O]` (§5). Full 680-section export NOT performed here — remaining 675 sections stay `[U]`.
- The 4th `TerrainMapBegin` word (64 on 320² vs 25920 on battle1-384) and the 16×8 atlas fallback literals were **not re-lifted** in this pass; carried `[U]` with experiments (§6, U-MDEN/U-ATLAS).

## 1. Multi-pass ledger (owner rule; all pinned `t_87f0f3c130b0`)

| Pass | What was done | Evidence ids (new this ticket unless noted) | Verdict |
|---|---|---|---|
| P1 | `native_strings_find` (data-sections only) for all 10 needles: `HeightFieldScale/TerrainScale/HeightFieldMin/HeightFieldMax/ObjectsScale/ObjectsHeightOffset/minangle/maxangle` **0 hits**; `HeightField` 1 hit (`.rsrc HXHeightField`); `Objects` 7 generic hits (none pattern) | `ev_07dfaf24…`, `ev_b7afcf01…`, `ev_cd81adc5…`, `ev_685972bd…`, `ev_7a8fd826…`, `ev_ba49cb96…`, `ev_4cdc84c1…`, `ev_3f210cb4…`, `ev_1d1fe218…`, `ev_d3e8bd91…` | `[O]` data-section absence (absence-in-search ≠ proof of absence, per tool limitation `data_sections_only`) |
| P2 | `native_bytes_find` (whole-file bytes) for every needle: all NB-2 property names **FOUND in CODE**; `minangle` 7, `maxangle` 10, `MinAngle` 8, `MaxAngle` 18, `HeightField` 48, `StandPattern` 4, `StandPatternWithAngle` 2 hits, all `section=CODE` with VAs + file offsets | `ev_602b449f…` (@0x75c7e0), `ev_0902cb24…` (@0x75c7fc), `ev_f92d668a…` (2), `ev_4d5ddc00…` (2), `ev_c205999a…` (@0x75c814), `ev_4ce3feef…` (@0x75c94c), `ev_3347c08a…` (7), `ev_9279790b…` (10), `ev_764085fb…` (8), `ev_9fb31ef1…` (18), `ev_4380cc65…` (48), `ev_05d1cd1d…` (rest), `ev_f0313e2b…` (4), `ev_eeee3a49…` (2), `ev_6e814f4d…` (Objects pages) | `[O]` CODE-embedded tables exist; strings-search 0s were a section-scope artefact |
| P3 | `native_bytes_show` 512 B dumps at `0x75c72c/0x75c7a8/0x75c814/0x75c94c/0x75c6a0/0x75c5e0/0x75c9c0/0x6a33e6/0x6a3450/0x6a35c6/0x5fe8a3/0x65bc9e` + pre-table bytes `0x75c5e0` + post-table code `0x75c9c0/0x75c9c8` + event table `0x541900` | `ev_298a203c…`, `ev_9f72ffac…`, `ev_65b97fb5…`, `ev_93de6c8a…`, `ev_e2a6a58a…`, `ev_66c317ed…`, `ev_c8071df8…`, `ev_e0701122…`, `ev_02653a87…`, `ev_01558dff…`, `ev_fdec1580…`, `ev_5c7c9267…`, `ev_8416ae26…` | `[O]` contiguous `name,00,…,FFFFFFFF,len` table `0x75c6a0–0x75ca2c`; `0x5fe8a3/0x65bc9e` angle hits are camera/group APIs, NOT pattern (negative) |
| P4 | `native_function_find` at 4 table/signature VAs (all "not inside any discovered function") + `native_data_show(cstring)` at 31 table `edx` VAs (all resolve) + `native_xrefs_list` at `0x75c72c/0x75c998/0x75c7e0/0x6a33e6` + `native_bytes_find(Objects, offset 100)` second page + `native_function_disassemble(sub_896b1c)` | `ev_5a824828…`, `ev_3ab81074…`, `ev_db4c6576…`, `ev_cf0e6a38…`, 31×cstring resolutions (no single ev; values in §3 table), `ev_3efa4919…` (0x75c72c←0x75c426), `ev_d6646014…`, `ev_3173a09d…`, `ev_5288576c…` (0x6a33e6 zero xrefs), `ev_4fa9e850…` (sub_896b1c 40 insns) | `[O]` table lives in undiscovered-code bytes, consumed by `sub_75c314`; signature tables have zero static xrefs (computed-pointer registration) |
| P5 | `native_function_study(sub_75c314, summary)` + full `native_function_disassemble(sub_75c314)` (237 insns) + `native_bytes_show(0x6a34fa)` full Adv signatures + `native_name_xrefs_list(StandPattern)` (`name_not_found`) | `ev_72967efb…`, `ev_e12db845…`, `ev_7a3e2207…`, `ev_1999fbdf…` | `[O]` every table VA→reader→offset→default binding (table in §3); arity strings byte-proven; no wrapper body localized |
| P6 | Shipped `pattern.lib` read-only: `default.grep` (`HeightFieldScale`, `Angle`, `Name = hil1/g_hil4/k_ravine_1/g_mnt_1`, `angle` 0, `minangle/maxangle` class 0 outside RotationAngle) + `default.read` lines 1–120, 33082–33141, 366470–366549, 549556–549595, 337462–337501 | file bytes `C:\Games\Cossacks 3\data\pattern\pattern.lib` (30,309,138 B): 5 sections transcribed §5 | `[O]` 5-section concretes + `RotationAngle=0` uniformity sample + `minangle/maxangle` key absence in lib |
| P7 | This file only written; no other file created/edited; donor never executed/copied | — | single-file discipline kept |

Starting-document conflicts: none (session already active on `t_87f0f3c130b0`, verified `core_session_show`/`core_targets_list` P1; no `core_target_open/select` issued; global active target untouched).

## 2. CODE-embedded tables `[O]`

Tool-scope note `[D]`: P1 `native_strings_find` 0s cover **data sections only** (`data_sections_only` limitation); P2 `native_bytes_find` hits are all `section=CODE` with VAs + file offsets. The 0s therefore prove "not a data-section string", not "not in binary". The tables below are whole-file byte facts.

### 2.1 Pattern-descriptor property table `0x75c6a0–0x75ca2c` (CODE)

Contiguous `name,00…00,FFFFFFFF,le32 len?,…` records (raw in `ev_e2a6a58a…`/`ev_66c317ed…`/`ev_298a203c…`/`ev_9f72ffac…`/`ev_65b97fb5…`/`ev_93de6c8a…`/`ev_c8071df8…`). Pre-table bytes at `0x75c5e0` (`ev_66c317ed…`) show the table starts after `sub_75c314` prologue/exception frames; post-table bytes at `0x75c9c0+` (`ev_c8071df8…`) show executable code resumes immediately (`55 8B EC 83 C4 D8…` = `push ebp; mov ebp,esp;…`, the tail of the registration blob / next routine). The table is **not inside any discovered function** (`ev_5a824828…`, `ev_3ab81074…`) — i.e. static data emitted into CODE, referenced by `sub_75c314` data xrefs (§3).

NB-2 needle VAs (all `section=CODE`, utf8):

| Needle | VA(s) | File offset(s) | Evidence | Note |
|---|---|---|---|---|
| `HeightFieldStand` | `0x75c72c` cluster start (record at `0x75c72c`) | `0x35bb2c` | `ev_298a203c…` + `ev_4380cc65…` | record `HeightFieldStand,00…FFFFFFFF 12000000` |
| `HeightFieldReplace` | `0x75c748` | `0x35bb48` | `ev_4380cc65…` (hit 11/48) | |
| `HeightFieldReplaceForWater` | `0x75c764` | `0x35bb64` | `ev_4380cc65…` (hit 12/48) | |
| `HeightFieldUseRndScale` | `0x75c788` | `0x35bb88` | `ev_4380cc65…` (hit 13/48) | |
| `HeightFieldMinScale` | `0x75c7a8` | `0x35bba8` | `ev_f92d668a…` (hit 1/2 is this prefix record) | contains `HeightFieldMin` as prefix — see §2.3 |
| `HeightFieldMaxScale` | `0x75c7c4` | `0x35bbc4` | `ev_4d5ddc00…` (hit 1/2 is this prefix record) | contains `HeightFieldMax` as prefix |
| `HeightFieldScale` | `0x75c7e0` | `0x35bbe0` | `ev_602b449f…` (1/1) | exact record |
| `TerrainScale` | `0x75c7fc` | `0x35bbfc` | `ev_0902cb24…` (1/1) | exact record |
| `ObjectsScale` | `0x75c814` | `0x35bc14` | `ev_c205999a…` (1/1) | exact record |
| `HeightFieldMin` (true) | `0x75c998` | `0x35bd98` | `ev_f92d668a…` (hit 2/2) | exact record, after `ObjAutoOffset` |
| `HeightFieldMax` (true) | `0x75c9b0` | `0x35bdb0` | `ev_4d5ddc00…` (hit 2/2) | exact record |
| `HeightFieldOffset` | `0x75c9c8` | `0x35bdc8` | `ev_05d1cd1d…`/`ev_c8071df8…` | record `…FFFFFFFF 11000000` then `Summer` |
| `ObjectsOffset` | `0x75c934` | `0x35bd34` | dump `ev_6e814f4d…`-adjacent (`dump_0x75c934`) | `ObjectsOffset,00…FFFFFFFF 13000000` |
| `ObjectsHeightOffset` | `0x75c94c` | `0x35bd4c` | `ev_4ce3feef…` (1/1) + `ev_93de6c8a…` | exact record |
| `Objects` (generic) | `0x75c6fc` (`GameObjectsStand`), `0x75c700`, `0x75c814`, `0x75c934`, `0x75c94c`, `0x75d4b8`, … + ~190 further CODE hits `0x4b6f21–0x8749a6` | file offsets `0x35bb00…` etc. | `ev_6e814f4d…` + first-page list (§1 P4) | only the 5 table records above are pattern-descriptor properties; the ~190 other `Objects` hits are unrelated class/library names (e.g. `0x958a3e ;OSWObjects`, `0x958b97 XMeshObjectsLibrary` in `.rsrc`, `ev_d3e8bd91…`) — never equated |
| `RotationAngle` | `0x75c82c` | `0x35bc2c` | `ev_65b97fb5…` | |
| `HeightFieldSmooth*` (4) | `0x75c844/0x75c860/0x75c880/0x75c8a0` | `0x35bc44…` | `ev_4380cc65…` + `ev_65b97fb5…` | `Smooth/SmoothRadius/SmoothFactor/SmoothOffset` |
| `IgnoreMatrix` | `0x75c968` | `0x35bd68` | cstring resolution P4 | |
| `ObjAutoOffset` | `0x75c980` | `0x35bd80` | cstring resolution P4 | |
| `OffsetX/OffsetZ` | `0x75c914/0x75c924` | `0x35bd14/0x35bd24` | cstring resolution P4 | |
| `Summer/NativeSeason/Autumn/Winter/Spring` | `0x75c9e4/0x75c9f4/0x75ca0c/0x75ca1c/0x75ca2c` | `0x35bde4…` | cstring resolution P4 + `ev_c8071df8…` | season gate block closing the table |

Full table order (VA → name, all `cstring`-resolved P4, `[O]`): `0x75c6b8 Name`, `0x75c6c8 Width`, `0x75c6d8 Height`, `0x75c6e8 TilesStand`, `0x75c6fc GameObjectsStand`, `0x75c718 DecalsStand`, `0x75c72c HeightFieldStand`, `0x75c748 HeightFieldReplace`, `0x75c764 HeightFieldReplaceForWater`, `0x75c788 HeightFieldUseRndScale`, `0x75c7a8 HeightFieldMinScale`, `0x75c7c4 HeightFieldMaxScale`, `0x75c7e0 HeightFieldScale`, `0x75c7fc TerrainScale`, `0x75c814 ObjectsScale`, `0x75c82c RotationAngle`, `0x75c844 HeightFieldSmooth`, `0x75c860 HeightFieldSmoothRadius`, `0x75c880 HeightFieldSmoothFactor`, `0x75c8a0 HeightFieldSmoothOffset`, `0x75c8c0 PatternMaskStand`, `0x75c8dc PatternMaskReverceStand`, `0x75c8fc CollisionStand`, `0x75c914 OffsetX`, `0x75c924 OffsetZ`, `0x75c934 ObjectsOffset`, `0x75c94c ObjectsHeightOffset`, `0x75c968 IgnoreMatrix`, `0x75c980 ObjAutoOffset`, `0x75c998 HeightFieldMin`, `0x75c9b0 HeightFieldMax`, `0x75c9c8 HeightFieldOffset`, `0x75c9e4 Summer`, `0x75c9f4 NativeSeason`, `0x75ca0c Autumn`, `0x75ca1c Winter`, `0x75ca2c Spring`. (`0x75c6a1/0x75c6a8` are exception-frame bytes, not names — `native_data_show` returns non-printable `�v…` there, `[O]` negative.)

### 2.2 Script-API signature table `0x6a33e6–0x6a36xx` (CODE)

Four contiguous `procedure/function …(…): …` records with `00…FFFFFFFF len` framing (`ev_e0701122…`, `ev_02653a87…`, `ev_01558dff…`, `ev_7a3e2207…`). Zero static xrefs to `0x6a33e6` (`ev_5288576c…`, 0/0) and `native_function_find` "not inside any discovered function" (`ev_db4c6576…`, `ev_cf0e6a38…`) — registration is via computed pointers at runtime (limitation `static_references`), so no wrapper body VA is recovered here `[O]` (absence-in-static-view, not proof of absence).

Byte-proven signature texts `[O]` (transcribed verbatim from dumps; never retyped from memory):

- `0x6a33e6`: `StandPatternWithAngle(const plhandle: Integer; const patternname: String; const standx, standz, rotangle, minangle, maxangle: Float)` (procedure; the `minangle, maxangle` bytes at `0x6a3450` file-off `0x2a2850`, `ev_02653a87…`, are the tail of this same record).
- `0x6a347e`: `procedure StandPattern(const plhandle: Integer; const patternname: String; const standx, standz, rotangle: Float)` (record `…FFFFFFFF c3000000`).
- `0x6a34fa`: `function StandPatternAdv(const plhandle: Integer; const patternname: String; const standx, standz, rotangle: Float; makegr, movetopar: Boolean; grname, parbase: String; parind: Integer): Integer` (`…FFFFFFFF e0000000`).
- `0x6a35c6`: `function StandPatternWithAngleAdv(const plhandle: Integer; const patternname: String; const standx, standz, rotangle, minangle, maxangle: Float; makegr, movetopar: Boolean; grname, parbase: String; parind: Integer): Integer` (followed by `GetPatternMaskWidth/Height/Value`, `GetPatternOffsetX…` getters, same framing `41/42/50/3d…`).

### 2.3 Prefix-collision warning `[D]`

`native_bytes_find(text="HeightFieldMin")` returns **2** hits because `HeightFieldMinScale` (`0x75c7a8`) contains `HeightFieldMin` as a prefix; likewise `HeightFieldMax`/`HeightFieldMaxScale`. The (Scale ↔ Min/Max) pairs are distinct records at distinct VAs with distinct parser offsets/defaults (§3). Any consumer that matches on prefix only would conflate them — the parser does not (separate `edx` immediates per call site, §3) `[D]` from `ev_f92d668a…` + `ev_4d5ddc00…` + disassembly.

### 2.4 Ruled-out `minangle`/`MaxAngle` hits (negatives) `[O]`

- `0x5fe8a3` cluster (`ev_fdec1580…`): `…minangle, minheightmaxangle, maxheightminangle… : Float` + `GetCameraFreeRotationInfo/SetCameraFocalLengthInfo` — camera API, not pattern.
- `0x65bc9e` cluster (`ev_5c7c9267…`): `MinAngleByHandle`, `GetGroupCollectingPointsMinAngleByHandle`, `SetGroupSmoothPoints…` — group API, not pattern.
- `0x541900` cluster (`ev_8416ae26…`): `THeightFieldGetHeightEvent(…x,y,z: Single…)`, `THeightFieldOption(hfoTextureCoordinates/hfoTwoSided)`, `THeightFieldOptions` — height-field **render/event** surface, carries no `Scale/Min/Max/Offset/TerrainScale` property in the dumped 512 B; never equated with the `0x75c6xx` descriptor table.
- `0x958aa2 HXHeightField` (`.rsrc`, `ev_1d1fe218…`) and the 7 `.rsrc/.idata Objects` hits (`ev_d3e8bd91…`) are resource/import names, not the descriptor table — never equated.

## 3. Native consumer: `sub_75c314` binds every table name to a struct offset `[O]/[D]`

`sub_75c314` (`0x75c314–0x75c6a0`, 237 insns / 8 blocks / 42 callees / 0 callers in discovered view, `ev_72967efb…`, full listing `ev_e12db845…`) is the pattern-descriptor ctor/parser. Each table VA is consumed exactly once as an `edx` immediate feeding a typed reader, whose result is stored to `[ebx+off]` (`ebx` = descriptor object). Single data xrefs proven for the sampled VAs: `0x75c72c←0x75c426` (`ev_3efa4919…`), `0x75c998←0x75c5d6` (`ev_d6646014…`), `0x75c7e0←0x75c497` (`ev_3173a09d…`); all other `edx` immediates are visible inline in the listing `[O]`.

| Table VA (`edx`) | Property `[O]` | Reader call `[O]` (immediates) | Store `[O]` | Default `[O]` (pushed immediate) | Reader-type inference `[I]` (not proven; calling convention assumed) |
|---|---|---|---|---|---|
| `0x75c6b8` | `Name` | `call 0x896bac` (+ `lea eax,[ebp-4]` / `call 0x405454` to `+0x14`) | `[ebx+0x14]` (string slot) | — (string) | string/enum reader |
| `0x75c6c8` | `Width` | `call 0x896a8c`, `ecx=0` | `[ebx+0x1c]` | `0` | int reader |
| `0x75c6d8` | `Height` | `call 0x896a8c`, `ecx=0` | `[ebx+0x20]` | `0` | int reader |
| `0x75c6e8` | `TilesStand` | `call 0x8967b4`, `cl=1` | `[ebx+0x18]` | `True` | bool reader |
| `0x75c6fc` | `GameObjectsStand` | `call 0x8967b4`, `cl=1` | `[ebx+0x19]` | `True` | bool reader |
| `0x75c718` | `DecalsStand` | `call 0x8967b4`, `cl=1` | `[ebx+0x1a]` | `True` | bool reader |
| `0x75c72c` | `HeightFieldStand` | `call 0x8967b4`, `cl=1` | `[ebx+0x39]` | `True` | bool reader |
| `0x75c748` | `HeightFieldReplace` | `call 0x8967b4`, `ecx=0` | `[ebx+0x3a]` | `False` | bool reader |
| `0x75c764` | `HeightFieldReplaceForWater` | `call 0x8967b4`, `ecx=0` | `[ebx+0x3b]` | `False` | bool reader |
| `0x75c788` | `HeightFieldUseRndScale` | `call 0x8967b4`, `ecx=0` | `[ebx+0x3c]` | `False` | bool reader |
| `0x75c7a8` | `HeightFieldMinScale` | `call 0x896b1c`, `push 0x3F800000` | `[ebx+0x40]` (x87 `fstp`) | `1.0f` | float reader (`sub_896b1c`, 40 insns, `ev_4fa9e850…`; `[ebp+8]` default → `[ebp-8]` fallback path) |
| `0x75c7c4` | `HeightFieldMaxScale` | `call 0x896b1c`, `push 0x3F800000` | `[ebx+0x44]` | `1.0f` | float reader |
| `0x75c7e0` | `HeightFieldScale` | `call 0x896b1c`, `push 0x3F800000` | `[ebx+0x48]` | `1.0f` | float reader |
| `0x75c7fc` | `TerrainScale` | `call 0x896b1c`, `push 0x3F800000` | `[ebx+0x68]` | `1.0f` | float reader |
| `0x75c814` | `ObjectsScale` | `call 0x896b1c`, `push 0x3F800000` | `[ebx+0x6c]` | `1.0f` | float reader |
| `0x75c82c` | `RotationAngle` | `call 0x896b1c`, `push 0x3F800000` | `[ebx+0x70]` | `1.0f` | float reader |
| `0x75c844` | `HeightFieldSmooth` | `call 0x8967b4`, `ecx=0` | `[ebx+0x4c]` | `False` | bool reader |
| `0x75c860` | `HeightFieldSmoothRadius` | `call 0x896a8c`, `ecx=0` | `[ebx+0x50]` | `0` | int reader |
| `0x75c880` | `HeightFieldSmoothFactor` | `call 0x896a8c`, `ecx=0` | `[ebx+0x54]` | `0` | int reader |
| `0x75c8a0` | `HeightFieldSmoothOffset` | `call 0x896a8c`, `ecx=2` | `[ebx+0x58]` | `2` | int reader (only non-zero int default in listing) |
| `0x75c8c0` | `PatternMaskStand` | `call 0x8967b4`, `ecx=0` | `[ebx+0x80]` | `False` | bool reader |
| `0x75c8dc` | `PatternMaskReverceStand` (donor spelling) | `call 0x8967b4`, `ecx=0` | `[ebx+0x81]` | `False` | bool reader |
| `0x75c8fc` | `CollisionStand` | `call 0x8967b4`, `cl=1` | `[ebx+0x82]` | `True` | bool reader |
| `0x75c914` | `OffsetX` | `call 0x896b1c`, `push 0` | `[ebx+0x74]` | `0.0f` | float reader |
| `0x75c924` | `OffsetZ` | `call 0x896b1c`, `push 0` | `[ebx+0x78]` | `0.0f` | float reader |
| `0x75c934` | `ObjectsOffset` | `call 0x8967b4`, `ecx=0` | `[ebx+0x7c]` | `False` | bool reader |
| `0x75c94c` | `ObjectsHeightOffset` | `call 0x8967b4`, `ecx=0` | `[ebx+0x7d]` | `False` | bool reader |
| `0x75c968` | `IgnoreMatrix` | `call 0x8967b4`, `ecx=0` | `[ebx+0x7e]` | `False` | bool reader |
| `0x75c980` | `ObjAutoOffset` | `call 0x8967b4`, `ecx=0` | `[ebx+0x7f]` | `False` | bool reader |
| `0x75c998` | `HeightFieldMin` | `call 0x896b1c`, `push 0x3F800000` | `[ebx+0x5c]` | `1.0f` (!) | float reader — default is one, not zero |
| `0x75c9b0` | `HeightFieldMax` | `call 0x896b1c`, `push 0x3F800000` | `[ebx+0x60]` | `1.0f` (!) | float reader — default is one, not zero |
| `0x75c9c8` | `HeightFieldOffset` | `call 0x896b1c`, `push 0` | `[ebx+0x64]` | `0.0f` | float reader |
| `0x75c9e4+0x75c9f4` | `Summer` + `NativeSeason` | `call 0x896bac` pair + `call 0x576914` | `[ebx+0x84]` | enum→bool | season-enum reader `[I]` |
| `0x75c9e4` | `Summer` (again) | `call 0x8967b4`, `cl=1` | `[ebx+0x85]` | `True` | bool reader |
| `0x75ca0c` | `Autumn` | `call 0x8967b4`, `cl=1` | `[ebx+0x86]` | `True` | bool reader |
| `0x75ca1c` | `Winter` | `call 0x8967b4`, `cl=1` | `[ebx+0x87]` | `True` | bool reader |
| `0x75ca2c` | `Spring` | `call 0x8967b4`, `cl=1` | `[ebx+0x88]` | `True` | bool reader |

Offsets `+0x39/+0x3a/+0x3b/+0x48/+0x4c/+0x5c/+0x60/+0x64/+0x68/+0x74/+0x78` agree with the carried `DEC_U_relief_stamps.md §2` parser map `[O]`; this pass adds the CODE VAs, the reader call sites, the pushed defaults, and the previously unbound tail (`+0x6c/+0x70/+0x7c/+0x7d/+0x7e/+0x7f/+0x80–0x82/+0x84–0x88`) `[D]`. Reader-type names (bool/int/float/string) are `[I]`: inferred from the `cl/ecx/push-f32` patterns and the `fstp [ebx+..]` vs `mov [ebx+..],eax/al` sinks, not from recovered prototypes. `sub_8967b4/896a8c/896bac` bodies were not disassembled here — their exact arity/contracts stay `[U]`.

Downstream stamp consumer (carried, not re-lifted): `sub_755f30` reads `+0x48` (Scale), `+0x5c` (Min pivot), `+0x64` (Offset), `+0x68` (TerrainScale) and **never** `+0x60` (Max, 0/6,751 insns) — `DEC_U_relief_stamps.md §2` `[O]`. New `[D]` consequence: `HeightFieldMax` IS parsed (`+0x60`, default `1.0f`) but has no in-stamp consumer; its consumers, if any, are editor/brush paths outside `sub_755f30` — still `[U]` (U-MAX carried).

`Objects*` consumer note `[D]`: `ObjectsScale` (`+0x6c`), `ObjectsOffset` (`+0x7c`), `ObjectsHeightOffset` (`+0x7d`), `IgnoreMatrix` (`+0x7e`), `ObjAutoOffset` (`+0x7f`) are **scalar gates/scales in the same descriptor struct**, parsed alongside the height fields. None of them is the `Objects[]` record list itself (record lists live in `pattern.lib` `Objects : struct.begin…[*]…`, §5). The `Objects[]→mesh` index binding (which mesh file per `BaseName`, authored-vs-rolled variation) has no consumer recovered here — stays `[U]` (U-OBJ carried, N17-G6).

## 4. Wrapper arities (byte-proven signature strings) `[O]`; bodies `[U]`

| Wrapper (CODE signature string VA) | Arity `[O]` (counted from the verbatim parameter list) | Returns `[O]` | Body VA / call edge |
|---|---|---|---|
| `StandPatternWithAngle` (`0x6a33e6`) | **7**: `plhandle: Integer` + `patternname: String` + `standx, standz, rotangle, minangle, maxangle: Float` (5×Float) | procedure (no result) | `[U]` — no wrapper body localized; `native_function_find` misses; zero static xrefs (`ev_5288576c…`); `native_name_xrefs_list` = `name_not_found` (`ev_1999fbdf…`) |
| `StandPattern` (`0x6a347e`) | **5**: `plhandle` + `patternname` + `standx, standz, rotangle` | procedure | `[U]` same as above |
| `StandPatternAdv` (`0x6a34fa`) | **10**: above 5 + `makegr, movetopar: Boolean` (2) + `grname, parbase: String` (2) + `parind: Integer` (1) | `: Integer` | `[U]` same as above |
| `StandPatternWithAngleAdv` (`0x6a35c6`) | **12**: above 7 + `makegr, movetopar` (2) + `grname, parbase` (2) + `parind` (1) | `: Integer` | `[U]` same as above |

`minangle`/`maxangle` status `[O]/[D]`: the lower-case pair occurs in CODE **only** as these two wrapper-arg suffixes (`ev_3347c08a…` 7 hits: `0x5fe8a3…` camera + `0x65bcc3` group-tail + `0x6a3450/0x6a3633` pattern-wrapper pair; `ev_9279790b…` 10 hits likewise) and the capitalised pair only in unrelated camera/group APIs plus the same wrapper records. There is **no** `minangle`/`maxangle` record in the `0x75c6a0–0x75ca2c` descriptor table (§2.1: the table jumps `RotationAngle → HeightFieldSmooth…`, `ObjAutoOffset → HeightFieldMin`), and `pattern.lib` contains **zero** `minangle/maxangle/MinAngle/MaxAngle` keys — `Angle` matches are `RotationAngle = 0` only (§5, `ev` grep series). So per-pattern angle numerics do not exist in either store `[D]` (within the searched bytes; `file_bytes_only` limitation applies — packed/computed regions unseen). Angle gating therefore can only come from the wrapper call-site args, whose native fork is the carried `sub_723748 +0x41` branch (`+0x41==0 → sub_75c228(90.0f…) → sub_755f30`; `!=0 → sub_755f30` direct; `DEC_U_relief_stamps.md §5` `[O]`). The `+0x34/+0x38` arg use and the accept/skip rule stay `[U]` (U-ANG carried, experiment in §6).

## 5. Shipped `pattern.lib` byte-proven concretes `[O]` (read-only)

Source: `C:\Games\Cossacks 3\data\pattern\pattern.lib`, 30,309,138 B, CRLF, 680 sections (carried structure `[O]` from relief_stamps §4 via F02/spec). Lines below read with repo `read`/`grep` tools only; no byte invented. Only the five listed sections are transcribed here; the other 675 sections were NOT dumped in this pass and stay `[U]` (U-HF).

Common shape `[O]` (all 5): `HeightFieldUseRndScale = False`, `HeightFieldMinScale = 1`, `HeightFieldMaxScale = 1`, `TerrainScale = 1`, `ObjectsScale = 1`, `RotationAngle = 0`, `PatternMaskStand ∈ {True,False}`, `PatternMaskReverceStand = True` (all five), `CollisionStand = True`, `OffsetX = 0`, `OffsetZ = 0`, `ObjectsOffset = False`, `IgnoreMatrix = False`, `ObjAutoOffset = False`, `HeightFieldOffset = 0`, `NativeSeason = Summer`, `Summer/Autumn/Winter/Spring = True`. (`ObjectsHeightOffset` varies; `HeightFieldSmooth*` vary; `HeightFieldMin/Max/Scale` vary — the rows that matter.)

| Section (line) | `HeightFieldScale` | `HeightFieldMin` | `HeightFieldMax` | `HeightFieldSmooth / R / F / O` | `ObjectsHeightOffset` | `Width×Height` |
|---|---|---|---|---|---|---|
| `brush_plt_15x15_2` (:1–39) | `-0.925000011920929` (:14) | `3.20392155647278` (:31) | `3.20392155647278` (:32) | `True / 1 / 4 / 1` (:18–21) | `False` (:28) | `18×18` (:3–4) |
| `hil1` (:33082–33118) | `0.649999976158142` (:33094) | `0` (:33111) | `3.86130237579346` (:33112) | `False / 2 / 4 / 0` (:33098–33101) | `True` (:33108) | `25×41` (:33083–84) |
| `g_hil4` (:366470–366506) | `1` (:366482) | `-4.32127315701247E-13` (:36499 sic :366499) | `1.91698789596558` (:366500) | `True / 3 / 4 / 2` (:366486–89) | `False` (:366496) | `33×59` (:366471–72) |
| `k_ravine_1` (:549556–549592) | `1` (:549568) | `-2.963627576828` (:549585) | `3.13982009887695` (:549586) | `False / 2 / 4 / 0` (:549572–75) | `False` (:549582) | `46×63` (:549557–58) |
| `g_mnt_1` (:337462–337498) | `1` (:337474) | `0` (:337491) | `0` (:337492) | `True / 3 / 4 / 2` (:337478–81) | `False` (:337488) | `43×38` (:337463–64) |

Notes `[O]/[D]`:

- `hil1` `Min=0/Max=3.8613…` vs X13-audited `hil1 Min=0/Max=0x40771F94`: same section, consistent shape (float-text vs hex-float dual views; no numeric equality asserted here — different precisions/section revisions possible; 1-ULP rule from relief_stamps U-X87 applies).
- `g_hil4` `Min=-4.32…E-13` (≈ −0 within 1 ULP of zero) vs X13 `Min=0xAAF3441C`: same warning — cited as two views, not equated `[D]`.
- `k_ravine_1` `Min=-2.9636…/Max=3.1398…` matches the N17-G5 triple-pattern probe table values (`-2.9636/max +3.1398`, `n17_gaps §6` `[O]`-carried) to the displayed 4-decimal precision; full-precision equality NOT asserted (no 80-bit replay here).
- `g_mnt_1` is the all-default corner: `Scale=1/Min=0/Max=0/Offset=0/TerrainScale=1/Smooth=True/R=3/F=4/O=2` — byte-proven, safe harness default, but still must be *fed* from the file, never hard-coded (experiment U-HF).
- `Objects[]` record shape `[O]` (carried + re-observed at `hil1 :33119+`, `g_hil4 :36507+`): `[*] → RaceName/BaseName/Position{X,Y,Z,W}/Direction/Up/Scaling{X,Y,Z,W}` (e.g. `hil1` first record `env/firsmall1` at `(1.2093505859375, 0.0269792154431343, 15.4023132324219)`; `g_hil4` first record `env/grass.3` scale `0.282740503549576`³). Counts/positions/scales per pattern stay `[U]` until the export diff (U-OBJ).
- `minangle/maxangle` key absence `[O]`: `grep -i angle` ≡ `RotationAngle = 0` only (30/30 sampled hits, §1 P6); literal `minangle`/`maxangle`/`MinAngle`/`MaxAngle` as standalone keys: **0 hits** outside `RotationAngle` in the grepped pages. (Whole-file byte certainty would need a full 30 MB scan; claimed only for the searched views + the five transcribed sections. Full-lib absence stays `[U]`-adjacent — folded into U-ANG experiment.)

No `pattern.lib` value is promoted into the port by this report (change list §7 is spec-only, NOT APPLIED).

## 6. Still-`[U]` register — map byte-dump zero-mismatch experiments

Common harness (never invent): pin `t_87f0f3c130b0`; `randkey0=0, randkey1∈{1,12345}`; `W=H=320` (repeat 256/640 once); `shape=nowater2`, `version=92`, `minesdensity=1`, `spcount=4`, `season=0`, `b_random_map=true`; fixed families/patterns bundle. Run port `generate()` twice; diff named arrays/counts. **Terminate an item only on zero mismatches across stated repeats; otherwise it stays `[U]`.**

| ID | Item | Donor `[O]` this ticket | Why still `[U]` | Fixed-seed comparison + termination |
|---|---|---|---|---|
| U-HF | per-pattern `HeightFieldScale/Min/Max/Offset/TerrainScale` concretes (675/680 sections) + `MinScale/MaxScale/UseRndScale` feed | 5-section floats `[O]` §5; offsets/defaults/readers `[O]/[D]` §3; X13 3-section floats carried `[O]` | 675 sections never dumped here; `rand(MinScale,MaxScale)` stream unmapped; `Max` consumer outside stamp unchecked | Dump `pattern.lib` floats for all 680 sections (record, line, float-text); replay X26 19-vector harness at true `G=8+N` on `g_mnt_1/g_hil4` + `hil1/k_ravine_1`; **terminate when 19/19 `f32step` bits reproduce with zero mismatches**. Never invent a Scale. Port keeps `random_scale_hook=NULL`, `global_setter_clamp_hook=NULL`, `stamp_precision_model="f32_each_op"` (relief_stamps §7 KEEP). |
| U-ANG | `minangle/maxangle` wrapper-arg use + `+0x34/+0x38`/`+0x41` arg routing + accept/skip rule | fork + `90.0f` + 4 arities `[O]` §§3–4; table/lib key absence `[D]` §4 | wrapper bodies undiscovered (0 xrefs); `sub_723748` arg mapping not re-isolated (6,751-insn pass not repeated) | Per-pattern record export + `+0x41==0/!=0` branch dump on fixed seed; **terminate when dumped angle floats reproduce accept/skip on `g_mnt_1` with zero mismatches**. Port keeps `minangle<=0 & maxangle>=90 → accept else accept-with-warning` stub. Full-lib `minangle` absence needs a whole-file `bytes_find` page-through (this ticket paged `minangle` 7/7, `maxangle` 10/10, `MinAngle` 8/8, `MaxAngle` 10/18 — remainder unpaged) — finish the page-through, then claim table-absence. |
| U-OBJ | `Objects[]→mesh` index binding (counts/positions/scales/materials) + per-instance variation source | 8-way dispatch + `+0x83`-gated fixups carried `[O]`; scalar gates `+0x7c–0x7f` + `+0x6c` bound here `[D]`; 2-section record heads `[O]` §5 | binding engine-side; 662-callee no-RNG observation carried, not re-traced | **Terminate on a per-pattern `Objects[]` export diff** (counts + `Position` + `Scaling` + material keys for the fixed bundle) with zero mismatches. Instancer stays missing by design; keep `objects_missing` telemetry + opaque `mesh_key`. |
| U-MAX | `HeightFieldMax` consumers outside stamp | parsed `+0x60` default `1.0f` `[O]` §3; 0/6,751 in-stamp reads carried `[O]` | editor/brush paths unchecked | **Terminate on a named outside-stamp consumer cite** (VA + bytes). Until then no port use of `Max` except decode/census. |
| U-S0 | `SmoothTerrain(x,−y,False,3)` kernel body | call shape carried `[O]` | body native undiscovered high VA (relief_stamps U-S0) | Byte-proven kernel dump reproducing `hook(height,w,h,bsmooth,3)`; keep `bsmooth_kernel=NULL/SKIP` + `bsmooth_pass=SKIPPED` until then. |
| U-MDEN | `minesdensity` rounds 3/4/5 + `gRecordGeneratorVersion` selectors + live `mapsize`/terraintype/profile overrides + 4th `TerrainMapBegin` word (64 vs 25920) | NOT lifted here (belongs to tver_deep residual; explicitly deferred by this ticket) | no new bytes | STATIC live-settings dump + `country.script`/`pattern.lib Objects[]` reads for `gc_MaxTerrainTypeCount`, `gRecordGeneratorVersion`, `mapsize`, rounds 3/4/5 (b_angle_index B5 sub-angle verbatim); resolve 4th word as tile-px vs mode/flags vs first tag word with ≥2 shipped heads (`35 00 00 00` + battle1-384) byte-compared. |
| U-ATLAS | 16×8 atlas fallback packing literals | NOT re-lifted here | — | Re-check fallback literals against per-block 1024² DXT1 transport (n17_gaps N17-G1/G2 experiment); never bake a packed grid without a `glTexImage2D` trace. |
| U-TAIL | `.pattern` 24 B tail + weight + 13 B tail semantics | structure/invariants carried `[O]` | no field proof | Typed field dump with zero mismatches; never map `id→mesh`. |
| U-RND/U-ROW/U-CLAMP/U-X87/U-SMP/U-OCC | feeds/precision/gating (carried) | §3 defaults + relief_stamps §2 opcodes carried | unchanged by this pass | Respective relief_stamps §6 / n17_gaps §6 probes stand; this ticket adds no new claim. |

## 7. File/line port change list — `terrain_donor_gen.gd` / `terrain_donor_mesh.gd` (NOT APPLIED, spec only)

All line numbers as read 2026-11-26 (relief_stamps §7 / n17_gaps §7 anchors). Additive/label-only except where marked KEEP. No parity claim attaches. **No edit made here.**

| # | File:line | Precise change (spec) | Why / authority |
|---|---|---|---|
| R-1 | `terrain_donor_gen.gd:2803-2821` | **KEEP** pivot `g=(g−Min)*Scale+Min` / `g*Scale`, three setters, two `getHeight` reads + `tbyte` spill. | relief_stamps R-1; X26 authoritative table; §3 offsets agree. |
| R-2 | `terrain_donor_gen.gd:344-352` | **KEEP** `F01_GRID_OFFSETS`; X13 shifts STALE note. | relief_stamps R-2. |
| R-3 | `terrain_donor_gen.gd:314-343` | **KEEP** 41-entry `STAMP_SMOOTH_PARAMS` census as transcribed. | relief_stamps R-3. |
| R-4 | `terrain_donor_gen.gd:396-400,1320-1326` | **KEEP** `bsmooth_kernel=NULL/SKIP`. | U-S0. |
| R-5 | `terrain_donor_gen.gd:402-405,2760-2764` | **KEEP** `random_scale_hook=NULL` + fixed-Scale fallback. | U-HF/U-RND. |
| R-6 | `terrain_donor_gen.gd:379-394` | **KEEP** `row_sign_hook/rotation_rounding_hook/global_setter_clamp_hook=NULL`, `f32_each_op`, `in_place`. | U-ROW/U-CLAMP/U-X87. |
| R-7 | `terrain_donor_gen.gd:2830-2834,2943-3008` | **KEEP** `Stand && Smooth` in-place post-pass, `/4.0`. | relief_stamps R-7. |
| R-8 | `terrain_donor_gen.gd:328` + `:784-792` | Optional comment-only: cite this report §5 five-section floats + §3 `+0x6c/+0x7c/+0x7d` gates in the `U-HF`/`U-OBJ` note. No logic change. | Makes IMPL probes explicit. |
| R-9 | `terrain_donor_gen.gd:3232-3238` + `:3101-3116` | **KEEP** opaque stamp + `objects_missing`; extend TODO to name `ObjectsScale(+0x6c, default 1.0, CODE VA 0x75c814, lib `ObjectsScale = 1` all sampled)` + `ObjectsOffset(+0x7c)/ObjectsHeightOffset(+0x7d)/IgnoreMatrix(+0x7e)/ObjAutoOffset(+0x7f)` scalar gates so a future hook implements them together. No synthesis. | §3 `[D]` + §5 `[O]`; U-OBJ probe. |
| R-10 | `terrain_donor_mesh.gd:84,262-337,743-772,1632-1648` | **NO STAMP CHANGE.** Keep `HEIGHT_SCALE=1.0`, corner-height PORT SUBSTITUTE label, `bind_height_grid` read-only. Mesh must not apply `Scale/Min/Offset/TerrainScale` a second time. | Prevents double-application of §3 formula. |
| R-11 | everywhere else | **NO OTHER EDIT.** No `[Min,Max]` clamp; no `Max` read; no `minangle` field invention; no `Objects[]` synthesised members; no 4th-word reinterpretation; no atlas literal change. | U-MAX/U-ANG/U-OBJ/U-MDEN/U-ATLAS. |

## 8. Bottom line + open registers

- **Newly closed-static this ticket:** CODE property table VAs+order (§2.1), `sub_75c314` name→offset→default→reader binding for all 37 table entries incl. every NB-2 needle (§3), 4 wrapper arities (§4), 5-section shipped concretes + `RotationAngle=0` sample + lib `minangle/maxangle`-key absence in searched views (§5), prefix-collision disambiguation (§2.3). These are static `[O]/[D]` only.
- **Open by design:** U-HF (675 sections + RND stream), U-ANG (wrapper bodies + arg routing + full-lib page-through), U-OBJ (mesh binding), U-MAX (outside-stamp consumer), U-S0, U-MDEN (settings + 4th word + atlas literals), U-TAIL, U-RND/U-ROW/U-CLAMP/U-X87/U-SMP/U-OCC. Each has a §6 zero-mismatch experiment; none may be filled with an invented float, kernel, clamp, angle rule, or mesh key.
- **No donor parity is claimed.** No donor frame/trace/A-B exists; no code/shader/asset/config/test/git/Godot edit was performed; exactly one repository file written (this report); `parity.claim = NONE`, `parity.status = "UNVERIFIED"`, `visual_parity_claim = false`; `blocking_unverified` non-empty so **RESULT IS NOT GOOD** while any §6 item is open.

*End of DEC_U_nb2. Exactly one repo file written (this report). Donor read-only; no binary executed/copied/committed. No parity claimed.*
