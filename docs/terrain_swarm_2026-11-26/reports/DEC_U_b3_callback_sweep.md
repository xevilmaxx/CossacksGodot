---
id: DEC-U-B3-CALLBACK-2026-11-27
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: "WORKER DEC-U-B3-CALLBACK — B3 randkey derivation→generator/map-seed caller/consumer sweep"
owner_file: docs/terrain_swarm_2026-11-26/reports/DEC_U_b3_callback_sweep.md
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
created: 2026-11-27
target: "t_87f0f3c130b0 — C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
labels: [OBSERVED, DERIVED, UNVERIFIED, NO_APPROXIMATION, PARITY_UNVERIFIED]
parity_status: UNVERIFIED
parity_claim: NONE
parity_claim_code: NONE
visual_parity_claim: false
chain_status: "six-condition parity chain 0/6 CLOSED (carried from PORT1TO1_u_register2.md §6); this ticket closes 0 conditions"
verdict: "RESULT IS NOT GOOD — blocking_unverified non-empty; static caller/consumer bytes narrow structure only; every live timing/value item stays [U] with a zero-mismatch termination; no donor execution; no parity claim"
scope_guard: "READ-ONLY static decompilation. Donor never executed, copied, debugged, captured or committed. No repo source/shader/asset/config/test/fixture/result/Godot/git edit; no Craft Anything brief/plan/finding/unknown mutation; no .bind unpacking. Exactly one repository file written: this report. Every native call was pinned document:\"t_87f0f3c130b0\"."
tooling_constraint: "Only tools.craftanything.native_function_study among native_* tools was used, per worker mandate; core_target_open/select, core_session_show, core_targets_list, core_feature_find, core_investigation_show, core_evidence_browse and report tools only otherwise. native_bytes_find / native_xrefs_list / native_function_find / instruction_show are NOT available here; [D] facts from those instruments are carried verbatim with their original evidence ids and are never re-asserted as re-lifted."
governing_sources:
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_nb4.md  (U-KEY derivation formula CLOSED [D], impl 0x6ac244, slot map)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_place_seed_deep.md  (12-name CODE RTTI table, arities, 11+3 reseeds, probes)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_genseed_deep.md, DEC_U_gen_seed.md  (Delphi LCG + QPC/GTC seeder)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_nb5.md  (quad copy-site instruction map; U-copy-values)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_u_classify.md §4 B3  (this ticket's assignment)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_u_register2.md  (final 71-row register, 9 P0 OPEN, chain 0/6)
---

# DEC-U-B3 — `GenerateMapRandKey` caller/consumer callback sweep

> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

## 0. Discipline, target verification, tooling honesty

- **[O]** = bytes / instructions / text re-read this ticket, pinned `t_87f0f3c130b0`, or carried verbatim with its evidence id. **[D]** = deterministic consequence of [O]. **[U]** = UNVERIFIED, never wired to a value; exact dump + zero-mismatch termination in §7.
- **Target verified before any finding** (`core_session_show` + `core_targets_list`, both pinned, read-only): `active_target = t_87f0f3c130b0`, `path = C:\Games\Cossacks 3\cossacks.exe`, `bytes = 5768048`, `sha256 = 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c`, `analysis_mode = deep`, server `0.6.1`. The target was already open and active; **no `core_target_open`/`core_target_select` was issued**, so global session state was untouched. `core_investigation_show` read only (`revision 1`, no findings/hypotheses written by this ticket).
- **Tools actually used:** `core_session_show`, `core_targets_list`, `core_investigation_show`, `core_feature_find`, `native_function_study` (summary then complete per function), `core_evidence_browse` (function-part pages), read-only repo `read`/`grep`/`glob` of donor **text** (`data/scripts/lib/map.script`, `data/gui/menu.inc/*.inc`). **No other native tool.** The mandate's warning is respected: `0x6ac244` is **not a discovered function start** — `native_function_study({function:"0x6ac244"})` returned `bad_input / function_not_found` this ticket; the body is studied only via carried stepped-instruction evidence from `DEC_U_nb4.md`.
- **VA→file-offset convention [D]:** carried byte pairs `VA 0x69f452 ↔ FO 0x29e852` and `VA 0x60a6b2 ↔ FO 0x209ab2` give `FO = VA − 0x400000` for the CODE addresses cited here; FOs below are that arithmetic, not separately re-read this ticket. Donor text offsets are quoted as `path:line`.
- **No `.bind` unpacking, no donor execution, no parity claim.** The 6-condition chain is carried as **0/6 CLOSED**; `blocking_unverified` is non-empty, so **`RESULT IS NOT GOOD`** unconditionally.

## 1. Evidence ledger — new evidence minted this ticket

Every row's subject is `t_87f0f3c130b0` / sha256 `87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c`.

| Evidence id | Operation (pinned) | Establishes |
|---|---|---|
| `ev_3880bdc6cddc00470211a1d9d47bee8954698f96972024c217cd993021237c3c` | `core_feature_find "GenerateMapRandKey"` | 0 strings / 0 function names / 0 imports; `no_match` (string-index scope, not absence of CODE RTTI) [O] |
| `ev_c3804981595ae8e32f7250a675c54ac38863fa5625a8409059224652a93981f4` | `core_feature_find "SetRandomKey"` | 0 hits (same limitation) [O] |
| `ev_445ad58913bf03f2b3ffa41223cbf71993d047169a08c721b844ca9ed442565c` | `core_feature_find "randkey"` | 0 hits (same limitation) [O] |
| `ev_164c70a3d7bbdbc2f5f8490397923c185e08812591f0a27fa5ab2145f486f946` | `core_feature_find "MapGenerator"` | only `XMapGenerator` @ VA `0x959430`, 0 references — unrelated resource/RTTI name, **not** a randkey call site [O] negative |
| `ev_3e940d03915b364971b96df09ebb5798e41373f0ccd636f5d266eec41999dc48` | `native_function_study sub_403a0c` (summary then complete) | Delphi LCG 9 insns, slot `0x8f2008`, **15 call sites** enumerated (§3) [D] |
| `ev_6b798f50e882c33b08bcb8158e0773ffa0e7b2ee21a3c2daf778dc23a9280e54` | `native_function_study sub_4033b8` complete | QPC-else-GetTickCount seeder, two stores to `0x8f2008`, 3 caller sites [D] |
| `ev_9dcd975ce2a7237a4e917e95b2e6f4af173e7c0e90de2fa1e6d61c709f471808` | `native_function_study sub_69a70c` summary | map-gen registrar discovered: 3202 insns, 639 call-outs, 1 caller [O] |
| `ev_7ff62a202cb752b42b8e812eec35aa82ed113731bbd69b466f4e068be0b74d1b` | `core_evidence_browse` on `ev_9dcd97…`, part `callers` | sole caller `sub_706880` @ `0x70692b` [D] |
| `ev_44041fa5e768957018e5860841f1d413397cc23e6ed75eb57c2c6080cf790b81` | `native_function_study 0x608238` summary | script-API (`FUN_00608238`) registrar discovered: 1559 insns, 331 call-outs [O] |
| `ev_d60c7ec9bccfc61935a3991ff390eb282277baeacda17f53075fa14978f35441` | `core_evidence_browse` on `ev_44041f…`, part `callers` | same host `sub_706880` calls it @ `0x70691d` [D] |
| `ev_fe5b50c0e65a7654d31fb826dba1cee1f3ba27d18486b628dc272121ab4aff44` | `native_function_study sub_8484ac` complete | 14-insn `eax↔edx` swap helper; sole caller `sub_6ac2e0` @ `0x6ac2e9` [D] |
| `ev_42f7f31c73e09ef550acfb4185a2ad2a77b62de4a0e7f227f20b6d5bef3bdb1c` | `native_function_study sub_6ac2e0` complete | SetGlobal body: swap → singleton → `pop [eax+0x108]`, `pop [eax+0x10c]`, `ret 8` [D] |
| `ev_bdf7ae960630f0aa22390418ad93fa13b75ad8bfdd6d522be312d53457189913` | `native_function_study sub_705944` summary | singleton accessor discovered, 10 insns, 1885 callers [O] |
| `ev_63d5a6240bb2d252694aceeed07e3a7a6b507473a712428da549846c0562c6fe` | `native_function_study sub_818920` summary | 1650 insns, 105 callees, 1 caller [O] |
| `ev_ccc25f9d8628728e093b7bbf3e9a453e08aaf331364696aaa0cde26985a7573e` | `core_evidence_browse` on `ev_63d5a6…`, part `callers` | `sub_818920` called from `sub_8177f0` @ `0x8179b6` [D] |
| `ev_dbbaff9917636bfd64b66faa258acd944f10aa2317448f5c80c70ef3062607a7` | `native_function_study sub_818824` complete | 91 insns; caller `sub_818920` @ `0x8192f3`; `call sub_81ac54` @ `0x81887e`; row reads `+0x50`/`+0x54`; two `rep movsd, ecx=8` [D] |
| `ev_77f7eec8cb1d2c263c6af95a2d57d74683f0628f99c34f7fa0878b90567d7702` | `native_function_study sub_81ac54` complete | `call dword ptr [ebx+0x40]` @ `0x81ac68`; `mov eax,[ebx+0x44]` @ `0x81ac65`; `lea edx,[eax+0x50]` @ `0x81ac60`; caller `sub_818824` @ `0x81887e` [D] |
| `ev_6d8f75e8227256dcc2562b22dba69999a3a0f63641bab357bc2175f80cbdc847` | `native_function_study sub_812e34` summary | 516 insns, 87 blocks, **0 discovered callers**, 2 incoming data references [O] |
| `ev_9a66277ad76cf8b4ee74e29e92bd0705af41d8821579ca166861fce12bcf795a` | `core_evidence_browse` on `ev_6d8f75…`, part `incoming_references` | data refs only: `0x8127ca` from `sub_8127b8`, `0x8178b4` from `sub_8177f0`, both `kind=data` [D] |

Carried evidence (original ids retained, **not re-lifted here**): `DEC_U_nb4.md` `ev_c0d732fb…/ev_e3d17104…/ev_dc243dd3…/ev_073af193…/ev_2aee671b…/ev_ce1cf038…/ev_300506d7…/ev_54398df9…/ev_25e73327…/ev_ef51315b…/ev_6a0aed3e…/ev_b4e871c2…/ev_0c3cbed5…/ev_21cfd5f4…/ev_d4963f56…/ev_b9f0c5f9…`; `DEC_U_place_seed_deep.md` `ev_5cc4b3b8…/ev_727d454c…/ev_bb534909…/ev_c452cc1f…/ev_dbb1494a…/ev_9430c9dd…/ev_786be1f7…/ev_b3ff60d2…/ev_05ad4a86…/ev_ac5ccebc…/ev_81148ecd…`.

## 2. Reachable chain — derivation → generator/map seed

"Byte-proven" below means static bytes/instructions/text only. **No row is a runtime claim; no row wires a port value.**

| L | Link | Label | Byte proof (evidence id + `path:offset`) | What stays [U] |
|---|---|---|---|---|
| L1 | process start → Delphi seed slot `0x8f2008` | **[D] NEW** | `ev_6b798f50…`: `cossacks.exe` VA `0x4033bc`/FO `0x33bc` `call QueryPerformanceCounter@thunk (0x401450)`; `0x4033c3` `je 0x4033d0`; `0x4033c8` `mov [0x8f2008],eax`; `0x4033d0` `call GetTickCount@thunk (0x401458)`; `0x4033d5` `mov [0x8f2008],eax`. 3 caller sites `0x5937a0`/`0x59c011`/`0x8300e5`. | U-TIME (which branch live), U-SS (live seed word) |
| L2 | `0x8f2008` → `Random(range)` `sub_403a0c` | **[D] NEW** | `ev_3e940d03…`: VA `0x403a0f`/FO `0x3a0f` `imul edx,[ebx+0x8f2008],0x8088405`; `0x403a19` `inc edx`; `0x403a1a` `mov [ebx+0x8f2008],edx`; `0x403a20` `mul edx`; `0x403a22` `mov eax,edx`; `ret` @ `0x403a25`. ⇒ `s=(s*0x8088405+1) mod 2^32`, result `hi32(s·range)`, `0 ≤ result ≤ range−1`. | U-SS/U-ONLY (live state attribution) |
| L3 | `Random($7FFFFFFF)` → `(randkey0,randkey1)` at impl `0x6ac244` | **[D] CARRIED** (formula closed by `DEC_U_nb4 §2.1`, **not re-lifted** here) | `ev_c0d732fb…` (body head VA `0x6ac244`/FO `0x2ac244`), `ev_e3d17104…` (`mov eax,0x7fffffff` @ `0x6ac247`), `ev_dc243dd3…` (`call 0x403a0c` @ `0x6ac24c`), `ev_073af193…` (`cdq` @ `0x6ac251`), `ev_2aee671b…`–`ev_54398df9…` (store helper `0x8484d0`/FO `0x4484d0`). ⇒ `randkey0=0` constant, `randkey1=Random($7FFFFFFF)` single draw, `ret 8`. | U-INVOKE (does the body run, when, with what live pair) |
| L4 | impl `0x6ac244` ↔ decl `0x69f448` registration in `sub_69a70c` | **[D] CARRIED** + **[O] NEW** discovery context | Carried `ev_0c3cbed5…` row @ VA `0x69ae52`/FO `0x29ae52` `mov ecx,0x6ac244 / mov edx,0x69f448 / call [esi+0x30]`; `ev_21cfd5f4…`/`ev_d4963f56…` (640-ish pair census, 639 call-outs). NEW `ev_9dcd975c…` confirms `sub_69a70c` is discovered (3202 insns, 639 callees), `ev_7ff62a20…` sole caller `sub_706880` @ `0x70692b`/FO `0x30692b`. | U-INVOKE (VM dispatch activation timing) |
| L5 | shared registrar host `sub_706880` → script-API registrar `sub_608238` **and** map-gen registrar `sub_69a70c` | **[D] NEW** | `ev_44041fa5…` (`sub_608238` = 1559 insns/331 call-outs) + `ev_d60c7ec9…` (caller `sub_706880` @ `0x70691d`/FO `0x30691d`); `ev_7ff62a20…` (same host → `sub_69a70c` @ `0x70692b`/FO `0x30692b`). | Which native wrapper a given script call resolves to at run time (VM dispatch) |
| L6 | stored keys → generator/global slots via singleton `sub_705944` | **[D] NEW for global**; **[D] CARRIED for map** | NEW `ev_42f7f31c…` + `ev_fe5b50c0…`: `sub_6ac2e0` VA `0x6ac2e0`/FO `0x2ac2e0` `mov edx,[ebp+0xc]` (arg1=`randkey1`), `mov eax,[ebp+8]` (arg0=`randkey0`), `call 0x8484ac` (swap ⇒ `edx=randkey0`, `eax=randkey1`), `push edx`, `push eax`, `call 0x705944`, `mov eax,[eax+0x4c]`, `mov eax,[eax+0x1b0]`, `pop [eax+0x108]` ← `randkey1`, `pop [eax+0x10c]` ← `randkey0`, `ret 8`. `ev_bdf7ae96…` singleton (1885 callers). Carried map slots `+0x18=randkey1/+0x1c=randkey0` via `ev_25e73327…/ev_ef51315b…/ev_6a0aed3e…/ev_b4e871c2…`. | live object field values (engine state) |
| L7 | live script call → `map.settings.gen` pair | **[O] donor text** (not execution) | `C:\Games\Cossacks 3\data\scripts\lib\map.script:322` (uncommented): `GenerateMapRandKey(map.settings.gen.randkey0, map.settings.gen.randkey1);` — sole **live** call site found in donor text (`X51 §2.8 X51-E1` carried; re-read this ticket). | whether the line executes in a given menu path; live field bytes |
| L8 | menu intent call sites + reseed setters | **[O] donor text (`;`-prefixed intent)** | `data\gui\menu.inc\donewgame.inc:16` (same call, gated by `not gbool_gui_donewgamerestart`, `:15`), `:33` `SetRandomExtKey64(gMap.settings.gen.randkey0, …randkey1)`, `:34` `SetMapGeneratorRandomKey(pair)`, `:35` `SetGlobalMapGeneratorRandomKey(pair)`, `:37` `GetRandomKey` in generated map filename; `data\gui\menu.inc\initmapsettings.inc:8` (same call, commented). All re-read this ticket. | live generation-time timing; which setter instance wins |
| L9 | script API names → VM-dispatched wrappers | **[D] CARRIED arities** + **[O] NEW negative** | `ev_5cc4b3b8…` `SetRandomKey` VA `0x60a6b2`/FO `0x209ab2` (arity 1); `ev_727d454c…` `SetRandomExtKey64` VA `0x60a72e`/FO `0x209b2e` (arity 2 const); `ev_bb534909…`/`ev_786be1f7…` `GenerateMapRandKey` VA `0x69f452`/FO `0x29e852` (2 var-out) + map-key family `0x69f4a6/0x69f502/0x69f552/0x69f5b2`. 0 static xrefs (`ev_b3ff60d2…/ev_05ad4a86…/ev_ac5ccebc…`) = VM dispatch via `sub_608238` (L5). NEW `ev_3880bdc6…/ev_c3804981…/ev_445ad589…`: `core_feature_find` 0 hits for these literals (string-index scope only); `ev_164c70a3…`: only "MapGenerator" string is `XMapGenerator` @ `0x959430`, 0 refs. | wrapper body attribution, per-site draw counts (P0-7 owner) |
| L10 | `SetRandomKey`/`SetRandomExtKey64` → RandomExt LCG stream | **[O]/[D] CARRIED** | `DEC_U_place_seed_deep §3/§5`: 11 `SetRandomKey(randkey1)` + 3 `SetRandomExtKey64(randkey0,randkey1)` identity passes; RandomExt LCG `s=(s*0xFC0D+0x3C6EF35F) mod 2^32`, `f32(s/2^32)` @ `0x60f64c–0x60f696` with increment constant `5F F3 6E 3C` at 5 sites (`ev_81148ecd…`). | U-KEY2 strict key0-discard; live stream values; per-site counts |
| L11 | stage consumers (mask pick / ext-reseeds) | **[O] CARRIED text**, **not re-lifted** | `PORT1TO1_terrain_generation.md:105` cites `generatemap.inc:190` (`floor(RandomExt*count)`) before `:216`, `:513`, `:774` ext-reseeds. **Honesty finding this ticket:** the shipped `C:\Games\Cossacks 3\scripts\editor.inc\generatemap.inc` is a **9-line stub** (`MapExecuteState('DoGenerateMissionMap')`); the cited `:130-200` body is **not present in that file** as read here — it is carried from the earlier decoded corpus, not re-verified. | all live draws/state |
| L12 | indirect renderer path → quad copy target `sub_812e34` | **[D] NEW** | `ev_ccc25f9d…`: `sub_8177f0` → `sub_818920` call @ `0x8179b6`/FO `0x4179b6`; `ev_dbbaff99…`: `sub_818920` → `sub_818824` call @ `0x8192f3`/FO `0x4192f3`, `sub_818824` reads `[ebx+eax*8+0x50]` (RGB) / `[ebx+eax*8+0x54]` (alpha) @ `0x8188f2/0x8188f7`, two `rep movsd, ecx=8` @ `0x8188df/0x8188ef`, `call sub_81ac54` @ `0x81887e`; `ev_77f7eec8…`: `sub_81ac54` `call dword ptr [ebx+0x40]` @ `0x81ac68`/FO `0x41ac68`; `ev_9a66277a…` + `ev_6d8f75e8…`: `sub_812e34` has **0 discovered callers** and only 2 **data** refs (`0x8127ca` from `sub_8127b8`, `0x8178b4` from `sub_8177f0`) — indirect dispatch byte-proven, not inferred. | U-copy-values value dump; which stage invokes `+0x40` |

**Chain result:** 12 links enumerated; 8 carry a byte-proven static `[D]` or `[O]` citation, 4 are donor-text intent. **Zero links promote to live port behaviour.** Static closure ≠ value closure; structural closure ≠ behavioural closure (`PORT1TO1_u_register2 §0`).

## 3. All 15 `Random` (`sub_403a0c`) callers — byte-proven census [D]

Source: `ev_3e940d03915b364971b96df09ebb5798e41373f0ccd636f5d266eec41999dc48`, `native_function_study sub_403a0c`, field `incoming_references` (15 rows), pinned `cossacks.exe`. Call-site FO = VA − `0x400000` [D].

| # | Caller function | Call-site VA (FO) |
|---:|---|---|
| 1 | `sub_515b34` | `0x515be8` (`0x115be8`) |
| 2 | `sub_5936f8` | `0x5937aa` (`0x1937aa`) |
| 3 | `sub_59c810` | `0x59c8ca` (`0x19c8ca`) |
| 4 | `sub_710380` | `0x710a1f` (`0x310a1f`) |
| 5 | `sub_715eec` | `0x715fe1` (`0x315fe1`) |
| 6 | `sub_7160b8` | `0x716252` (`0x316252`) |
| 7 | `sub_71a0c8` | `0x71a322` (`0x31a322`) |
| 8 | `sub_71d2fc` | `0x71d343` (`0x31d343`) |
| 9 | `sub_7319c0` | `0x731a49` (`0x331a49`) |
| 10 | `sub_7c5958` | `0x7c5a11` (`0x3c5a11`) |
| 11 | `sub_7c5958` | `0x7c5ab9` (`0x3c5ab9`) |
| 12 | `sub_7c5958` | `0x7c5b68` (`0x3c5b68`) |
| 13 | *null (undiscovered caller)* | `0x7c5cf1` (`0x3c5cf1`) |
| 14 | `sub_806c74` | `0x806ca2` (`0x406ca2`) |
| 15 | `sub_808158` | `0x8081e5` (`0x4081e5`) |

**Census meaning [D] narrow:** 15 *call sites*, 12 distinct named discovered callers + 1 null caller. Crucially, **`0x6ac244` is absent from this list**, and `native_function_study("0x6ac244")` returns `function_not_found` this ticket. The `call 0x403a0c` at `0x6ac24c` lives in the undiscovered derivation body (carried stepped evidence `ev_dc243dd3…`). Therefore the census is the **discovered-function-visible** caller set, **not** a closed-world count of every `call 0x403a0c` byte in the image. Neither "the 15 are exhaustive" nor "the derivation call is absent" may be claimed. Attribution of any one site to generation-time tile drawing stays **[U]** (U-RANDOM-ATTRIB).

## 4. Derivation body and slot map — exact static law, no live value

- **Carried [D] (`DEC_U_nb4 §2.1`):** `GenerateMapRandKey` impl VA `0x6ac244` / FO `0x2ac244`, decl VA `0x69f448` / FO `0x29f448`, name hit `0x69f452` / FO `0x29e852`; body `mov eax,0x7fffffff; call sub_403a0c; cdq; push edx; push eax; call 0x8484d0; ret 8` ⇒ `randkey0 = cdq(eax)=0`, `randkey1 = Random($7FFFFFFF)` one draw. No map-name/settings pointer, no second draw, no QPC/TickCount read inside the body.
- **New [D] this ticket (`ev_42f7f31c…` + `ev_fe5b50c0…`):** the discovered sibling `sub_6ac2e0` (SetGlobal) re-proves the `(randkey1, randkey0)` low-to-high slot order independently of the carried stepping: swap helper `0x8484ac` exchanges `eax`/`edx`, then `pop [eax+0x108] ← arg1 (randkey1)`, `pop [eax+0x10c] ← arg0 (randkey0)`. The +`0x108/+0x10c` pair is byte-proven; the map object's `+0x18/+0x1c` pair remains carried `[D]` (undiscovered siblings `0x6ac264`/`0x6ac28c`/`0x6ac2b4` return `function_not_found` to `native_function_study` this ticket, so they were not re-lifted).
- **No promotion:** nothing here changes the port's caller-supplied keys, RNG streams, or any generator/map seed. `IMPL-RANDKEY-DERIV` is a label/telemetry lane only (`PORT1TO1_claim_recheck5 §150`), not a parity surface.

## 5. Script-text call/consumer inventory (read-only, [O] text)

| File:line | Text | Status |
|---|---|---|
| `data\scripts\lib\map.script:322` | `GenerateMapRandKey(map.settings.gen.randkey0, map.settings.gen.randkey1);` | uncommented / **live-looking** [O] text; no execution observed |
| `data\gui\menu.inc\donewgame.inc:16` | same call on `gMap.settings.gen`, gated by `:15` restart flag | `;`-prefixed intent [O] |
| `data\gui\menu.inc\donewgame.inc:33` | `SetRandomExtKey64(gMap.settings.gen.randkey0, gMap.settings.gen.randkey1);` | `;`-prefixed intent [O] |
| `data\gui\menu.inc\donewgame.inc:34` | `SetMapGeneratorRandomKey(pair)` | `;`-prefixed intent [O] |
| `data\gui\menu.inc\donewgame.inc:35` | `SetGlobalMapGeneratorRandomKey(pair)` | `;`-prefixed intent [O] |
| `data\gui\menu.inc\donewgame.inc:37` | `genMapName := 'game_v'+IntToStr(gDataVersion)+'k'+IntToStr(GetRandomKey)+'.map'`; `:42-49` mapsize `0→320,1→480,2→640,3→256` | `;`-prefixed intent [O] |
| `data\gui\menu.inc\initmapsettings.inc:8` | same call | `;`-prefixed intent [O] |
| `scripts\editor.inc\generatemapfrombitmap.inc:42/125/341` | `SetRandomExtKey64(randkey0, randkey1)` with editor-form input `:4-16` | `;`-prefixed intent [O] |
| `scripts\editor.inc\generatemap.inc:1-9` | only `MapExecuteState('DoGenerateMissionMap')` | **no** `:130-200` body in shipped file [O] negative |

All 972+ `.inc` excerpts are text intent; none was executed. This ticket adds no claim that any of these lines ran in a donor session.

## 6. What remains structurally unresolved (no invention)

- **Generation-time invocation:** the L4/L5 registration bytes prove *how* the VM can reach the derivation body, not *that* a given new-game run calls it. No breakpoint, write-watch, or trace was run.
- **Live RNG state:** `0x8f2008` write attribution, QPC-vs-GTC branch, and the per-run seed word are runtime facts; the 15-caller census is static only.
- **Key0 runtime discard:** the derivation yields `key0=0`, but the strict claim "no effect on any draw" still needs the ±1 probe because a shipped map/debugger could present non-zero `key0` to the 3 ext-reseeds.
- **Shipped-map override:** no byte→field mapping was found; no header word is quoted as a key.
- **Renderer copy values:** the indirect call chain is byte-proven; the copied row bytes and 4-iteration scatter values are not.
- **Absolute limits:** packed/`.bind` regions, VM-dispatched call sites, and undiscovered function bodies are outside the static view; zero/xrefs/coverage caveats carry from prior tickets (`file_bytes_only`, `static_references`, `data_sections_only`).

## 7. Still-[U] register — exact dump / zero-mismatch termination

> Authorised owner/COORD trace only. **Nothing here was run.** Each probe restarts at least once and terminates **only** on its stated zero-mismatch criterion. No value is wired into the port until then.

| ID | Item | Exact dump / experiment | Termination condition |
|---|---|---|---|
| **U-INVOKE** | runtime timing/occurrence of `GenerateMapRandKey` (impl `0x6ac244`) | Break at VA `0x6ac244`/FO `0x2ac244` and at decl-dispatch in `sub_69a70c` row `0x69ae52`; dump call count, `(randkey0,randkey1)` before/after, and caller return address for one full new-game generation; repeat after restart with identical menu settings | **Terminate** when the observed pair equals `(0, Random($7FFFFFFF))` on every hit with **zero mismatches** across ≥2 restarts, or when zero hits are recorded with the dispatch row exercised (refutes invocation for that path — record it, still no invented value) |
| **U-KEY-LIVE** | live menu-seed → pair | Two known menu seeds; dump `gMap.settings.gen.randkey0/1` before `initmapgen.inc:99` (`SetRandomKey(randkey1)`) | **Terminate** on a byte-exact closed form / 1:1 table over tested seeds with **zero mismatches**; restart with same menu seed must reproduce the pair (else wall-clock source proven, still no invention) |
| **U-KEY2** | strict runtime key0-discard | Fix `randkey1=K` (`K=1`, repeat `K=12345`), `key0=0` vs `key0=1`, all else equal (`W=H=320`, `shape=nowater2`, `version=92`, `minesdensity=1`, `spcount=4`, `season=0`, `b_random_map=true`); dump `D2:190` mask pick + first 3 `RandomExt` floats after each `D2:216/513/774` ext-reseed | **Terminate** when key0-only changes are bit-identical on all draws after draw #1 of each ext-stage and differ at most on draw #1 per the cross-term model, with **zero post-#1 mismatches** on both K values and two map sizes; any post-#1 divergence closes the field as *refuted* with the diverging draw index recorded |
| **U-MAP** | shipped-map seed override at `0x8f2008` | On a readable generated map: dump `gMap.settings.gen.randkey0/1` at load; hardware write-watch `0x8f2008` across load; regenerate from same settings | **Terminate** when (i) a map-load write to `0x8f2008` is captured with source VA (override proven), or (ii) `0x8f2008` is untouched across two map sizes while `randkey1` varies the stream (override refuted), **zero mismatches** on the untouched watch |
| **U-SS** | generation-time Delphi seed | Break at `0x83272f` (`mov [edx+4],al`); first hit of fresh generation: dump u32 `0x8f2008` **before** `call 0x403a0c` @ `0x832727` plus stored `al`; log `(cell-corner, state-before, byte)` for full fan-out | **Terminate** when every byte equals `state-before>>>24` with **zero mismatches**, pre-first-hit state recorded, and restart+same menu seed yields a different seed while same-process regeneration continues the stream |
| **U-ONLY** | exclusivity of the `0x8326b8` draw | Same break + write-watch on `0x8f2008` for whole generation; attribute every advance to its return address | **Terminate** when advance count equals accepted-cell count with **zero unattributed advances**, or the first unattributed advancer is recorded with VA (either outcome closes) |
| **U-TIME** | QPC-vs-GTC branch | Break at `0x4033bc`; log `eax` vs `je 0x4033d0` and the stored dword | **Terminate** when taken branch + stored dword equal post-`sub_4033b8` `0x8f2008` with **zero mismatch** on two cold starts |
| **U-RANDOM-ATTRIB** | which of the 15 `sub_403a0c` call sites (§3), if any, is the generation-time tile draw | Hardware write-watch on `0x8f2008` through one generation; attribute every LCG advance to one of the 15 sites (or the undiscovered `0x6ac24c` call / null `0x7c5cf1`) | **Terminate** when all advances map to a named site set with **zero unattributed advances**, or the first unattributed advancer is recorded with VA (either closes attribution; no draw-count invention) |
| **U-RESEED-COUNT** | 11+3 reseed firing order and per-site draw counts | Fixed keys and settings; log every `SetRandomKey`/`SetRandomExtKey64`/`RandomExt` VM dispatch with site id and draw index from generation start to mask pick | **Terminate** on a fully attributed ordered draw log with **zero missing/duplicate sites** across two seeds and two map sizes |
| **U-SCRIPT-ACTIVATION** | whether the commented/menu `;`-text call sites (§5) are live | Owner trace of `DoNewGame` / `InitMapSettings` / `GenerateMap` states with line-level hit log | **Terminate** when hit lines are byte-identical across ≥2 runs with **zero mismatches**, or non-activation is recorded for each cited line |
| **U-COPY-VALUES** | value-level bytes behind the L12 quad-copy map | Dump source rows `renderer+0x50+0x48·i` (RGB `+0x05`, alpha `+0x25`) and appended `Q` records at `+0x00/+0x10/+0x30` after `call [ebx+0x40]` | **Terminate** on a named byte dump reproduced for all four scatter indices across ≥3 cells including a multi-tag cell with **zero mismatching bytes** |
| **U-SHIPPED-MAP-BYTES** | saved-map word ↔ key mapping | Dump header words of two shipped maps vs live `gMap.settings.gen` pair at load | **Terminate** on one hypothesis with **zero mismatching words/floats** on both maps; otherwise stays `[U]` |

## 8. Port change list — **spec only, NO edits made**

1. Keep `IMPL-RANDKEY-DERIV` as label/data/telemetry, "NEVER read by generation"; cite L3 carried `[D]` evidence ids and L6 new `ev_42f7f31c…/ev_fe5b50c0…` for the `+0x108/+0x10c` slot order. Do not add map-name/settings inputs or a second draw.
2. Keep caller-supplied `randkey0/1` verbatim at all reseeds; do **not** substitute `key0=0` from the static formula into live paths (U-KEY2).
3. Keep the quad-copy lane label-only; cite L12 new evidence for the indirect `+0x40` dispatch, but wire no copied value (U-COPY-VALUES).
4. Add no `XMapGenerator`-derived behaviour: `ev_164c70a3…` is a 0-reference resource name, not a randkey consumer.
5. No `.bind` unpacking, no atlas/angle/height-field change, no test/gate weakening.

## 9. Claim register and verdict

| # | Claim | Label |
|---|---|---|
| 1 | Target verified `t_87f0f3c130b0` / sha256 `87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c` before any finding; no re-open, no memory mutation | `[O]` §0 |
| 2 | All 15 discovered `Random` (`sub_403a0c`) call sites enumerated with VA/FO; `0x6ac244` is absent and `function_not_found` — census is discovered-visible, not exhaustive | `[D]`+`[O]` §3, `ev_3e940d03…` |
| 3 | L1/L2 (LCG + seeder), L5 (shared registrar host), L6-global (`+0x108/+0x10c`), L12 (indirect renderer `call [ebx+0x40]` → 2 data-ref-only `sub_812e34`) byte-proven **new** with evidence ids | `[D]` §2, `ev_6b798f50…`, `ev_3e940d03…`, `ev_d60c7ec9…`, `ev_42f7f31c…`, `ev_77f7eec8…`, `ev_9a66277a…` |
| 4 | L3 derivation formula/impl↔decl registration, L9 arities/VM dispatch, L10 11+3 reseeds are **carried** `[D]`/`[O]`, not re-lifted under this ticket's tool constraint | `[D]`/`[O]` §1–§2 |
| 5 | Only live-looking randkey call in donor text is `map.script:322`; menu/editor call sites are `;`-intent; shipped `generatemap.inc` is a 9-line stub, so `:130-200` is carried, not re-verified | `[O]` §5 |
| 6 | Every live timing/value item in §7 stays `[U]` with an exact dump + zero-mismatch termination; no value invented, no static fact promoted to live port behaviour | `[O]`/`[D]` §7 |
| 7 | `parity.claim = NONE`, `parity.status = UNVERIFIED`, `visual_parity_claim = false`; six-condition chain **0/6 CLOSED**; `blocking_unverified` non-empty ⇒ **`RESULT IS NOT GOOD`** | `[O]`/`[D]` §0/§9 |

> **Verdict (verbatim governing form):** `port=UNVERIFIED`; `parity.claim = NONE`; `parity.status = "UNVERIFIED"`; `visual_parity_claim = false`; `blocking_unverified` non-empty (P0-1…P0-8 plus the domain tails); six-condition chain 0/6 CLOSED. **`RESULT IS NOT GOOD`.** No same-camera donor/port A/B frame exists; no approximation is authorised; no parity claim is made. Static caller/consumer closures never close class-A value/behaviour items.

*End of DEC-U-B3-CALLBACK. Read-only; exactly one repository file written (this report); no donor binary executed, copied, captured or committed; no source/shader/asset/config/test/runner/Godot/git/investigation-memory change; no `.bind` unpacking; parity UNVERIFIED.*
