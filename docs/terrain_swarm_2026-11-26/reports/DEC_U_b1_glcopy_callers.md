---
id: DEC-U-B1-GLCOPY-CALLERS-2026-11-26
worker: DEC-U-B1-GLCOPY (subagent in full 1:1 Cossacks 3 donor port)
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: "WORKER DEC-U-B1-GLCOPY — read-only static whole-binary caller/xref walk of every glCopyTexImage2D / glCopyTexSubImage2D helper (class-B angle B1)"
ticket: "Pin t_87f0f3c130b0, core_feature_find on gl-copy/texture literals, native_function_study (summary then complete) on 0x4afb3c / 0x4ed44c / every helper found via refs, core_evidence_browse paging. Byte-proven links only become [D] with evidence id + address; every ambiguous link stays [U] with the exact owner-only zero-mismatch GL-trace termination (≥2 frames + camera move, 0 mismatched binds/uniforms/bits). No water value promoted, no parity claim."
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
labels: [O, D, I, U, NO_APPROXIMATION, PARITY_UNVERIFIED]
parity_claim: NONE
parity_status: UNVERIFIED
visual_parity_claim: false
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32 x86, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. No donor binary executed, copied, committed or captured; no donor file written; no GPU frame taken. Every read pinned document=t_87f0f3c130b0."
scope_guard: "No repo code/asset/shader/config/test/fixture/result/Godot/git change. Exactly one repo file written: this report. No .bind unpacking."
multi_pass: true
tooling_constraint: "native toolset pruned. Only native_function_study was called among native_* (summary then complete); no native_bytes_*/native_xrefs_*/native_instruction_*/native_functions_*/native_address_* call. core_target_open parity checks, core_session_show, core_targets_list, core_overview_show, core_feature_find, core_evidence_browse and report tools only."
chain_status: "0/6 CLOSED"
verdict: "RESULT IS NOT GOOD — both copy imports have zero discovered users; address 0x4afb3c resolves only to the 437-insn container sub_4aff8c with 0 direct callers and one DATA reference (sub_4b0304 @0x4b0385), and 0x4ed44c is inside an undiscovered gap (function_not_found at every probe). The only byte-proven chain is sub_6760a0 -> sub_7744cc ->(data ref) sub_7715f4 ->(call @0x771b50) sub_4ed28c, which issues glTexImage2D@thunk @0x771b80 but NO copy call; the bind chain glBindTexture@thunk @0x4afb0c <- sub_88f8a8 @0x88f8c0 (23 sites / 7 callers) is disjoint. Zero uniform writers discovered. Reflection identity, scalar tuple and frame timing stay [U]; no water value promoted; no parity."
---

# DEC-U-B1-GLCOPY — gl-copy caller / reachability walk (read-only)

> **PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED.** No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass. `parity.claim = NONE`, `parity.status = "UNVERIFIED"`, `visual_parity_claim = false`, `chain = 0/6`, **`RESULT IS NOT GOOD`**.

## 0. Authority and discipline

Every statement below is `[O]` (bytes / instruction / xref row lifted **this ticket**, pinned `t_87f0f3c130b0`), `[D]` (deterministic consequence of `[O]` rows), `[I]` (interpretation, never wired) or `[U]` (UNVERIFIED, settled only by §7's capture). Prior-ticket VAs, pseudocode and instruction reads are **hypotheses only** and are never re-cited as this ticket's evidence — in particular the prior `native_instruction_show` claim of `jmp [__imp_glCopyTexImage2D]` at `0x4afb3c` and the prior `call 0x4afb3c` at `0x4ed44c` could **not** be re-proved with the pruned toolset and are kept `[U]`.

Every `ev_…` id quoted was produced **this ticket** by `core_overview_show`, `core_feature_find`, `native_function_study` (summary then complete), or `core_evidence_browse`, and read back against the pinned target. No donor binary was executed; no value was promoted; no port file was edited.

Load-bearing result: **the walk returns a structural negative plus one new byte-proven data-reference chain.** It closes no behavioural `[U]` and authorises no water value.

## 1. Pin verification and discovery limit

| Check | Result | Evidence |
|---|---|---|
| Target id | `t_87f0f3c130b0` (active) | `core_session_show`, `core_targets_list` this ticket |
| SHA256 | `87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c` — exact match to required pin | `core_session_show`, `core_targets_list` |
| Binary | PE32 x86 Windows executable, 5,768,048 B, 18 libraries, 746 imports | `core_session_show`, `core_overview_show` |
| Discovery limit | `18918 functions, 12073 strings, 746 imports from 18 libraries. Function discovery stopped at an analysis limit, so the function list is incomplete.` Limitations: `instruction_limit` (6,000,000 instructions), `indirect_jumps_unresolved` (1238), `stripped_binary`, `static_analysis_only` — "absence is not proof" | `ev_60b497434aa3e6cb68b019fd0a3b016ec0415ef6ec1a3189726faa8d3752f4c4` `[O]` |

**Tool limitation, load-bearing:** `native_instruction_show`, `native_bytes_find`, `native_xrefs_list`, `native_address_show` and `native_functions_*` are unavailable to this worker. The only native dossier source is `native_function_study`, whose lifter misaligns across the import-thunk stub table (§3). A `function_not_found` result is **absence of a discovered entry, not absence of code**, and is never positive evidence of runtime absence.

## 2. Pass ledger (≤5 passes per studied function; every pass logged)

| Pass | Operation | Fresh read this ticket | Result |
|---|---|---|---|
| P1 | `native_function_study` **summary** | `0x4afb3c`, `0x4ed44c`, `sub_4aff8c`, `sub_4ed28c`, `sub_7715f4`, `0x4afb0c`, `sub_88f8a8`, gap probes `0x4ed300/0x4ed38c/0x4ed3b5/0x4ed400/0x4ed430/0x4ed448/0x4ed450/0x4ed460` | `0x4afb3c` resolves to container `sub_4aff8c` (437 insns, 0 callers); `0x4ed44c` and every gap probe `function_not_found`; `sub_4ed28c` 1 caller; `sub_7715f4` 0 callers; bind thunk 1 caller; `sub_88f8a8` 23 callers (§3–§4) |
| P2 | `native_function_study` **complete** | Same discovered set + refs-discovered `sub_4b0304`, `sub_7744cc`, `sub_6760a0` | Full assembly, pseudo-C, `callers`, `callees`, `incoming_references`, `outgoing_references`, `native_api`, `unresolved_calls` (§3–§5) |
| P3 | Literal sweep | `core_feature_find` on `glCopyTexImage2D`, `glCopyTexSubImage2D`, `CopyTex`, `glBindTexture`, `glUniform1i`, `glUniform1f`, `glUniform`, `glActiveTexture`, `glCopyTexImage1DEXT`, `glCopyTexImage2DEXT`, `glCopyTexSubImage1DEXT`, `glCopyTexSubImage2DEXT`, `glFramebufferTexture2DEXT`, `wglGetProcAddress`, `glGenTextures`, `hmapTex`, `HeightMapTexUnit`, `reflectionMapBound` | Both copy imports present with `used_by: []`; all EXT copy names, all uniform names, `hmapTex` and `HeightMapTexUnit` = `no_match` `[U]`, not absence (§3) |
| P4 | `core_evidence_browse` paging | `summary` of `ev_322cefb…`; `callers`/`incoming_references` of `sub_4ed28c`, `sub_7715f4`, `0x4afb0c`, `sub_88f8a8`; **all 10 assembly pages of `sub_7715f4`** (offsets 0…576, `at_end:true` at 576/594) and **all 7 pages of `sub_4aff8c`** (offsets 0…384, `at_end:true` at 384/437) | 0 copy-thunk rows in any paged assembly; copy/relevant sites listed §4/§5 |
| P5 | Context windows + disjointness | ±16 insn window around `0x771b50`, full 20-insn body of `sub_88f8a8`, 14-insn tail of `sub_4ed28c`, caller-set comparison of copy chain vs bind chain | Byte-proven upload constant pushes and bind-cache store; 0 address overlap between the two chains (§6) |

No function consumed more than 5 passes. Refs discovered at P2 (`sub_4b0304` data ref → `0x4aff8c`; `sub_7744cc` data ref → `sub_7715f4`; `sub_6760a0` call → `sub_7744cc`) were promoted to studied helpers in the same ticket and are in the tables below.

## 3. Copy-import / thunk inventory `[O]/[D]/[U]`

| Item | Fresh read this ticket | Standing |
|---|---|---|
| `glCopyTexImage2D` import | `ev_5d16822153f938186252b9e667d9c37d39d08af14fa9edabd0858ce1d53c6adb`: `opengl32.dll` slot `0x907d7c`, string @`0x90ae4c`, `used_by: []` | `[O]` present as import + name; **zero discovered users** `[O]`; zero discovered users is **not** runtime absence `[U]` |
| `glCopyTexSubImage2D` import | `ev_90859ec9c768ea91a2cc22d85d67a0e6e7078c89243474274d6c63cb834452ff`: slot `0x907d78`, string @`0x90ae36`, `used_by: []` | same `[O]`/`[U]` distinction |
| `CopyTex` aggregate | `ev_15481a9ab7cf44113ab5996f1feb28e2f09447f138e172cf8167c109d668ddc3`: exactly 2 strings (`0x90ae36`, `0x90ae4c`) + 2 imports, both `used_by: []`, 0 functions, 0 function names | `[D]` in the engine's index there is **no discovered copy thunk function** and no import user for either spelling |
| Address `0x4afb3c` | `native_function_study("0x4afb3c")` → containing function `sub_4aff8c`, entry `0x4aff8c`, end `0x4b0115`, size 1551 B, 183 blocks / 437 insns, `callers: 0`, `incoming_references: [{from:0x4b0385, function:sub_4b0304, kind:"data", to:0x4aff8c}]` — `ev_322cefb2a7416cdaf151c2efe46ca004b8e392f7148723d6f8d789c38d35ca0a`; browse summary `ev_80193879f4d8fc338785c3e55ef989bf00ca6afa97f142c77159d31ad5db7aa7` | `[D]` zero **direct** call sites to the container; one **data** reference only. `[U]` whether `jmp [__imp_glCopyTexImage2D]` actually sits at `0x4afb3c` — the paged assembly at `0x4afb39/0x4afb3f` decodes as `add [ebx+0x7c25ffc0], cl` / `jge 0x4afad1` (lifter misalignment), and no dossier row equals `jmp [0x907d7c]` |
| Import-thunk region `0x4afb44/0x4afb4c/0x4afb54` | Each address resolves to the **same** 437-insn dossier (counts identical to `sub_4aff8c`), not a separate function; `core_feature_find("glCopyTexSubImage2D@thunk")` = `no_match` `ev_d91a44e0d78d1c6e185ad76a2bfcad6a20ab2ffdce11f648787969572891ff94` | `[D]` no separately discovered SubImage thunk; `[U]` dynamic `wglGetProcAddress` dispatch (below) |
| Address `0x4ed44c` (the prior singleton `call 0x4afb3c`) | `native_function_study("0x4ed44c")` → `function_not_found`; probes at `0x4ed38c`, `0x4ed3b5`, `0x4ed400`, `0x4ed430`, `0x4ed448`, `0x4ed450`, `0x4ed460` all `function_not_found` | `[U]` body, call site and argument sources are unavailable in this engine; prior `e8 eb 26 fc ff` read is not re-cited |
| EXT copy names | `glCopyTexImage1DEXT` `ev_13a0724104f7b579a0026b67cc634ff85da1d8bc460f7e39d5a434a2860a6ad2`, `glCopyTexImage2DEXT` `ev_9cd5a3e29bd3d8ba9194a407115873f19466d9ba598fa38d962310a2628c439c`, `glCopyTexSubImage1DEXT` `ev_fc0a3e754a9aa10d428db35798945308179515a7942a50c326d964345f177666`, `glCopyTexSubImage2DEXT` `ev_cbf081ed47491b859fbb39865be6d8ea504155fdd6a9c076d07920a96d28408a`, `glFramebufferTexture2DEXT` `ev_8b12e6cc9413577b617907336ab9caa1c67e2893541343667f6cbc9ea3333bb1` — all 0 strings / 0 imports / 0 functions, `no_match` | `[U]` with `no_match` limitation; not proof of absence |
| Dynamic resolution | `wglGetProcAddress` import slot `0x907bbc`, string @`0x90a7bc`, `used_by: []` — `ev_fd3248d0df4b5a933e235dae15dd2dcb064c38b4bec6c4330676fdc712a9ed28`. `glGenTextures` slot `0x907d48`, string @`0x90ad84`, `used_by: []` — `ev_da2ef3d0d7dfc3fb7d99a75d502419e6d108083354a30ef35325aa6a8f25113f` | `[O]` imports present, no discovered users; `[U]` whether EXT copy/FBO entry points are resolved at runtime |
| Texture/uniform literals | `glUniform1i` `ev_dff42170…`, `glUniform1f` `ev_27094eb6…`, `glUniform` `ev_ce18deaa…`, `glActiveTexture` `ev_fdda5ca0…`, `hmapTex` `ev_eab32206…`, `HeightMapTexUnit` `ev_6de6b748…`, `reflectionMapBound` `ev_b10628de…` — all 0 matches, `no_match` | `[U]` no uniform writer or reflection name is discoverable in this engine; see §7 |

## 4. Caller / reachability table

"Reaches copy thunk" means a **byte-proven call or data-reference row to `0x4aff8c`/`0x4afb3c`/`0x907d7c`/`0x907d78`** in this engine's assembly/xref lists. Every row cites this ticket's evidence and address.

| Helper (evidence) | Byte-proven edges with site | Reaches copy thunk? | Writes texture-id / uniform state? | Standing |
|---|---|---|---|---|
| `sub_4aff8c` @`0x4aff8c` `ev_322cefb2…` | `0 callers`; incoming **data** `0x4b0385 ← sub_4b0304`; 11 callees (10 internal + `glGetString@thunk` @`0x4b0074`); 116 outgoing refs (import stubs `0x4afb14…0x4aff84`) | **NO** direct call; the only inbound edge is a data reference `[D]` | NO | `[D]` negative for direct reachability; `[U]` function-pointer dispatch |
| `sub_4b0304` @`0x4b0304` `ev_63d90b0162af8a492d36959f459a36ae43cf555a86d8bb8ab311a45123714c1f` | 7 callers: `0x4c0e27` (self-site), `sub_4d24d8` @`0x4d25fc/0x4d2626/0x4d26d2`, `sub_544be8` @`0x544fa3`, `sub_54504c` @`0x54536d/0x54567a`; `0x4b0385 mov eax,[0x4aff8c]` (data); callees `glGetError@thunk` ×2, `gluErrorString@thunk`, `sub_4055f8`, `sub_410dd4`, `sub_404d54`, `sub_405400` | only the **data** ref above `[D]` | NO | `[D]` error-string/extension-probe helper; `[U]` any indirect transfer through the data ref |
| `sub_4ed28c` @`0x4ed28c–0x4ed38b` `ev_16ab8d2ea3da7328f60ade30d6514492e808924eba19b58a9e8b47d116b5d012`; callers `ev_011e38618c8044975307ec0d8402cf58a14c5e15262b07a30f59b659b16593ae`, incoming `ev_77928eca46405b88cc5d787511b58fbbdc9b7a331976b3842dcd6cf00d96d763` | 1 caller `sub_7715f4` @`0x771b50`; callees `0x4ed24c` @`0x4ed2e2/0x4ed359`, `0x4ed258` @`0x4ed2ed`, `glHint@thunk` @`0x4afbdc` ×3 (`0x4ed316/0x4ed327/0x4ed338`); tail `0x4ed38a ret` | **NO** row to copy/gap in dossier `[D]` | NO | `[U]` fall-through into undiscovered `0x4ed38c…` cannot be re-proved here |
| `sub_7715f4` @`0x7715f4–0x771bdf` `ev_db7bd0ec07450e7c48897e1b5106e17a5f84be8cb84a75bbc33ce2175559e3e8`; callers `ev_f6aa37e503e5a7232c0f1d2278b2a61170ada361247769fdce78dfdf10670110` (empty), incoming `ev_f60012772796639296a544a839d7e0b4341a257037a0649644bd1ef6ab1cd380` | 0 direct callers; incoming **data** `0x774506 ← sub_7744cc`; calls `sub_771c0c` @`0x771b32`, `sub_4ed28c` @`0x771b50`, `glTexImage2D@thunk(0x4afc34)` @`0x771b80`, `sub_4ed284` @`0x771b87`, `sub_4c0710` @`0x771ba0`, `sub_4c18c0` @`0x771bd4`; **10 unresolved** indirect calls @`0x771710/0x7717e9/0x771979/0x771b98/0x771baa/0x771bb3/0x771bc7/0x771b6b/0x771b74/0x771b44` | **NO** copy-thunk row in 594 paged assembly rows `[D]` | NO uniform write; upload call only `[D]` | `[D]` texture-upload head; `[U]` reflection identity of the uploaded name |
| `sub_7744cc` @`0x7744cc–0x774582` `ev_78b7e0e9eb4438dae4635773e53a20eb4399b7656e79fc0ce34caba5e609f0a6` | 1 caller `sub_6760a0` @`0x6760b9`; `0x774506 mov eax,[0x7715f4]` classified `kind:"data"`; callees `sub_4058b0`, `sub_5a1f74`, `sub_7763f8`, `sub_425a7c`, `sub_774478`, `sub_89dd90`, `sub_405400` | data ref only, **not** a call `[D]` | NO | `[U]` control transfer into `sub_7715f4` is not byte-proven |
| `sub_6760a0` @`0x6760a0–0x6760ce` `ev_1276f84d812fccf49208c7936a5d24463e9badbddfe65d320d0a2ea71c3ec48b` | 0 callers; 3 callees `sub_705944` @`0x6760a3`, `sub_710248` @`0x6760ab`, `sub_7744cc` @`0x6760b9`; 0 unresolved | NO | NO | `[D]` named head of the recovered data-path; `[U]` its own entry (0 static callers) |
| Gap `0x4ed38c…0x4ed44c` | no dossier at 8 probed addresses | prior single copy site lives here | unknown | `[U]` whole region |
| `glBindTexture@thunk` @`0x4afb0c` `ev_dd740c627a0e53323b8de706749be8212bd2985cf638d3648036c648fb93e6e6`; callers `ev_faeaf6207d84c153b4dae74e0d6b71055ade64d64471dc8d88c76a0f491c016d` | 1 insn, 1 callee, 1 caller `sub_88f8a8` @`0x88f8c0` | NO | **is** the bind API boundary | `[D]` single discovered user |
| `sub_88f8a8` @`0x88f8a8–0x88f8d9` `ev_cbb26573848302c9de758ac3d00d2c67ff5b0765661b41f74143fd6c1bc786e4`; callers `ev_04836c198a979c41c68487bfc3186054b8a63d47be019f0f6dbb00ef29c7706d` | **23 caller sites / 7 distinct functions**: `sub_4ec794` @`0x4ec7d7/0x4ec86c/0x4ec8fc`, `sub_4ecbd8` @`0x4ecc3b/0x4ecd12/0x4ecde4`, `sub_5d2234` @`0x5d233f/0x5d236e/0x5d239c/0x5d23d5/0x5d245b/0x5d26ba/0x5d26ee/0x5d2717/0x5d2740/0x5d2766`, `sub_5d27dc` @`0x5d27fc/0x5d2962`, `sub_5d2ad4` @`0x5d2afb`, `sub_5d2b9c` @`0x5d2bd5`, `sub_5d2c68` @`0x5d2c8f/0x5d2d4e/0x5d2e0d`; 1 callee (bind thunk) | NO | **YES** — texture-id cache store + counter (§5) | `[D]` texture-id state writer; `[U]` which texture the slot holds |

Totals this ticket: **1** import-side copy thunk container with **0** direct callers and **1** data reference; **1** recovered 3-hop data/call chain into `sub_4ed28c`; **0** byte-proven edges into the copy gap; **10** unresolved indirect calls in the upload head; **23/23** bind-cache caller sites exhausted in this engine's DB.

## 5. Texture-id / uniform state write audit `[O]/[D]/[U]`

`[D]` **The only byte-proven texture-id state writer found is `sub_88f8a8`** (all rows `ev_cbb26573…`, 20 insns, pinned):

- `0x88f8b2 mov esi,[ebp+8]` — incoming texture-id argument.
- `0x88f8b5 cmp esi,[ebx+edi*4+0x90]` / `0x88f8bc je 0x88f8d2` — hit/miss test against an indexed cache array.
- `0x88f8be push esi`; `0x88f8bf push ecx`; **`0x88f8c0 call 0x4afb0c`** (bind thunk).
- `0x88f8c5 mov [ebx+edi*4+0x90],esi` — cache store; `0x88f8cc inc dword ptr [0x8fb0d8]` — global counter.
- `0x88f8d6 ret 4`.

`[D]` **Zero** `glUniform1i` / `glUniform1f` / `glUniform` / `glActiveTexture` strings, imports, functions or call rows exist in this engine's index (`ev_dff42170…`, `ev_27094eb6…`, `ev_ce18deaa…`, `ev_fdda5ca0…`, all `no_match`). No uniform writer is reachable from either chain in the discoverable graph; this is a **bounded negative**, not runtime absence `[U]`.

`[D]` **One byte-proven upload path, not a copy:** `sub_7715f4` pushes `0` @`0x771b58`, `0x1401` @`0x771b5a`, `0x1908` @`0x771b5f` before `0x771b80 call 0x4afc34` (`glTexImage2D@thunk`), immediately after `0x771b50 call 0x4ed28c`. `[I]` the pushed constants are consistent with a GL upload format/type triple; the interpretation is not wired and no texture name, size or unit is taken from it.

`[D]` **No value promoted.** The cache store at `0x88f8c5` is a slot write on an untyped base (`ebx`); which slot (if any) is `hmapTex`, which texture (if any) is a reflection map, and which scalar (if any) is `hmapW/H/Min/Max` are all `[U]`.

## 6. Reachability conclusion `[O]/[D]/[U]`

`[D]` **The copy-chain address set and the bind-chain address set are disjoint.** Copy chain: `{0x4aff8c, 0x4b0304, 0x6760a0, 0x7715f4, 0x7744cc, 0x4ed28c, gap 0x4ed38c…0x4ed44c}`. Bind chain: `{0x4afb0c, 0x88f8a8, 0x4ec794, 0x4ecbd8, 0x5d2234, 0x5d27dc, 0x5d2ad4, 0x5d2b9c, 0x5d2c68}`. No address appears in both sets; no row in any studied assembly or callee list equals `0x4afb3c`, `0x907d7c`, `0x907d78`, `0x4afb44` or a copy import call.

`[D]` The prior `glBindTexture` "one discovered user" result is re-proved independently here: `0x4afb0c` has exactly one caller, `sub_88f8a8 @0x88f8c0` (`ev_faeaf620…`); its 23 caller sites are enumerated in §4. Nothing in that 23-site set reaches the copy chain.

`[U]` The only possible bridges are unresolved/indirect: the `0x4b0385` data reference, the `0x774506` data reference, the 10 `target:null` calls in `sub_7715f4`, and the undiscovered fall-through at the end of `sub_4ed28c`. None was resolved; no reachability claim is made.

`[U]` Reflection provenance (FBO attachment vs framebuffer copy vs static upload), reflection identity, scalar tuple and frame timing are **not** settled by static bytes. U12/U4* remain `[U]` hard-failed: no reflection texture scalar tuple, no grey fallback, no water value.

## 7. `[U]` register — exact owner-only capture termination (unchanged)

Gating precondition for **every** row: water field visible (break `FUN_00603d30` @`0x603d30`, read `[ebp+0x1c]`); live path identified first (hook `glShaderSource`: `hmapTex` present = DEV file pair `water.dev.vert/frag`; `alphaDepth`/`deepColor` = BUILTIN embedded pair); height gate open at `0x854250` (`C+0xe0 != 0 && [C+0xe0+8] != 0` — a closed gate voids the frame). **Owner-authorised donor session only; forbidden to workers.** Captures on the BUILTIN path settle nothing.

| # | Still-`[U]` item | Static state after this walk | Owner-only capture experiment | Zero-mismatch termination |
|---|---|---|---|---|
| B1-COPY-THUNK | Whether `0x4afb3c` is the sole copy thunk and `0x4ed44c` its sole call site | `[U]` — import slots `0x907d7c`/`0x907d78` have `used_by: []`; `0x4afb3c` resolves only to the 437-insn container with 0 direct callers; the lifter misaligns across the stub; `0x4ed44c` is `function_not_found` | Owner GL trace: breakpoint at `0x4ed44c` and at the thunk region; log every `glCopyTexImage2D`/`glCopyTexSubImage2D` with dst name, level, format, src rect and call stack; log `wglGetProcAddress` results for both names | **Terminate iff the same single thunk + single call site accounts for 100% of copy calls with 0 mismatched dst names/rects across ≥2 frames + 1 camera move.** Any second thunk/caller or any mismatch ⇒ keep `[U]`, model no reflection copy |
| B1-COPY-HEAD | Head that enters the recovered copy chain | `[U]` — data refs `0x4b0385 → sub_4aff8c`, `0x774506 → sub_7715f4`; `sub_6760a0 → sub_7744cc` call; 10 unresolved indirect calls | Same trace: record the stack at each copy call and name the callback/vtable that enters `sub_7715f4`; enumerate every xref at each hop | **Terminate iff every hop has a visited body with 0 unvisited xrefs remaining and the head repeats with 0 counter-examples across ≥2 frames + 1 camera move.** Otherwise `[U]`; no head promoted |
| U12-A (reflection identity) | Reflection texture `(target, name, w, h)` + provenance class | `[U]` — no copy-dst name recovered; both copy imports have 0 discovered users; EXT names `no_match` | At the bind gate: record `glActiveTexture(GL_TEXTURE0+u)`, `glBindTexture(target,name)`, full-frame history of `name`: (a) FBO attachment, (b) copy dst, (c) upload-only; dump one 8×8 texel block + channel carrying height; log map name + `water.lib` hash | **Terminate iff the same `(target,name,w,h)` repeats with 0 mismatches across ≥2 frames + 1 camera move on that map and exactly one provenance class accounts for `name` with 0 counter-examples.** Mixed/unknown ⇒ keep `reflectionMapBound=false` substitute labelled `[U3]`; never promote art texture |
| U3-TEX | `hmapTex` GL identity / unit | `[U]` — 0 literal matches (`ev_eab32206…`); the only texture-id writer is the untyped cache at `0x88f8c5` | Hook `glBindTexture`/`glUniform1i` in the same draw as the U3-NUM tuple; record unit `u` and `(target,name)`; verify the slot `ebx+edi*4+0x90` identity | **Terminate iff the same bind + uniform pair repeats with 0 mismatched binds/uniforms across ≥2 frames + 1 camera move;** otherwise no name/id/unit from this sweep |
| U3-NUM | Live `(hmapW,hmapH,hmapMin,hmapMax)` for a named shipped map | `[U]` — no uniform writer discovered; no scalar tuple; no water value | Break `FUN_00854054` bits `7e.10–7f.1` (`0x854250–0x8542f0`) with the named map loaded and field visible; record pushed ints/floats plus chain pointers and same-draw `glUniform1i/1f` values; name map + `water.lib` hash | **Terminate iff the same 4-tuple repeats with 0 differing bits across ≥2 frames + 1 camera move on that map.** Those numbers (not any default, not any constant from this sweep) become port parameters for that map only; a second map needs its own row |
| U-B1-FRAME | Frame timing / draw-order of copy vs bind | `[U]` — no frame counter or timing writer recovered in any studied dossier | In the same owner trace, log frame ordinal + camera pose for every copy/bind/uniform event; compare event order frame to frame | **Terminate iff event order and frame ordinal repeat with 0 mismatched bits across ≥2 frames + 1 camera move.** Any order flip ⇒ keep timing `[U]`; no timing value promoted |

General rule: any mismatch, closed gate, or wrong-shader-path frame voids the capture. **No parity follows from termination** — termination only authorises wiring the captured reals for the captured map/slot. No water value is promoted by this report.

## 8. Exact port stance (NO edits made — owner applies)

All relevant lines re-cited at repo HEAD via priors; verified present, untouched by this worker. **Wire only captured reals.**

1. `variant3d/scripts/water3d.gd:68` (`MAX_HEIGHT=2.96`), encode `:652`, `hmapMin/Max` binds `:668-669`, `max_height :763` — KEEP SUBSTITUTE + `[U3]` LABELS. FORBIDDEN: presenting `±2.96`/`±2.964`/clamp, or any value inferred from this sweep, as recovered.
2. `variant3d/scripts/water3d.gd:486+` (`bind_height_grid`), `:655` (`height_tex`), hmap binds `:663-669` — KEEP SUBSTITUTE. No texture name/id/unit/provenance from this sweep is wired.
3. Uniform-table `:143,146-147`, stats `:305,346`, ledger `:909,913,940` — LABEL-ONLY: cite this sweep (2 copy imports with 0 discovered users; 0 direct callers of `0x4aff8c`; 1 data ref from `sub_4b0304`; gap `0x4ed44c` undiscovered; `sub_6760a0→sub_7744cc→data→sub_7715f4→sub_4ed28c→glTexImage2D` upload; 23 bind-cache sites in 7 callers; 0 uniform writers). Keep every `[U3]` tag.
4. FORBIDDEN: hard-coding any shipped-map `(W,H,Min,Max)`; inventing a reflection texture name/id/unit or provenance class; treating `0x88f8c5`'s cache store as `hmapTex`; claiming the `0x4ed44c → 0x4afb3c` call from this engine's xref DB; modelling a copy-based reflection; promoting any constant pushed at `0x771b58–0x771b5f`.

## 9. Explicit non-claims and file discipline

- **No parity claim.** No donor binary executed, no GPU frame captured, no port capture compared. `parity.claim = NONE`, `parity.status = "UNVERIFIED"`, `visual_parity_claim = false`, `chain = 0/6`, **`RESULT IS NOT GOOD`** unconditionally.
- **No approximation substituted.** No reflection texture name/size/unit, no shipped-map tuple, no conversion factor, no frame timing supplied.
- **No guess promoted.** Both copy imports with zero discovered users stay `[U]`, not proven absent; `0x4afb3c`'s exact thunk instruction and `0x4ed44c`'s call stay `[U]` under the pruned toolset; all `no_match` literals stay `[U]`; the data-reference hops stay data references, not calls.
- **Structural closure only.** The 23/23 bind-cache caller sites and the 1/1 `sub_4ed28c` caller site are exhausted **within the incomplete DB**; this does not close any behavioural `[U]`, including U12/U4* (hard-failed).
- **Read-only compliance.** Exactly one repository file written: `docs/terrain_swarm_2026-11-26/reports/DEC_U_b1_glcopy_callers.md`. No code/shader/asset/config/Godot/git change. No donor file opened for write or executed. No `.bind` unpacking. No water value promoted.
- **Claim register (audit-level):** (1) pin verified `t_87f0f3c130b0`/SHA256 — `[O]`; (2) discovery limit + tool limitations `ev_60b497…` — `[O]`; (3) two copy imports, both `used_by: []`, 0 discovered copy-thunk functions — `[O]/[D]`; (4) `0x4afb3c` → `sub_4aff8c`, 0 callers, 1 data ref from `sub_4b0304 @0x4b0385` — `[O]/[D]` new; (5) `0x4ed44c` and 7 gap probes `function_not_found` — `[U]` bounded; (6) `sub_6760a0 → sub_7744cc →(data) sub_7715f4 →(call @0x771b50) sub_4ed28c → glTexImage2D@thunk @0x771b80`, 10 unresolved indirect calls — `[O]/[D]` new; (7) `glBindTexture@thunk` 1 user `sub_88f8a8 @0x88f8c0`, 23 sites/7 callers, cache-store rows — `[O]/[D]` re-proved; zero uniform writers — `[U]` bounded; (8) two chains disjoint, no byte-proven copy reachability — `[O]/[D]` new; (9) reflection identity, scalars, frame timing `[U]` with §7 termination; no water value, no parity — scope guard.

*End of DEC-U-B1-GLCOPY-CALLERS.*
