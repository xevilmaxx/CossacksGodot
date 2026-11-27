---
id: DEC-U-B2-UREG-CALLERS-2026-11-26
worker: DEC-U-B2-UREG-CALLERS (subagent in full 1:1 Cossacks 3 donor port)
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: "WORKER DEC-U-B2-UREG-CALLERS — read-only static whole-binary caller/xref sweep of FUN_0082f060 / FUN_0082f114 / FUN_00739bf8 / FUN_0082f86c (class-B angle B2)"
ticket: "Pin t_87f0f3c130b0, ≥5 passes/function. Decompile each new caller, record which writes h+0x50 / h+0x200 and any reachability to the 0x854250 draw-time GL bind gate. Byte-proven links only become [D] with evidence id + address; every [U] keeps the exact glBindTexture/glUniform1i/1f zero-mismatch capture termination. No water value promoted, no parity claim."
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
labels: [O, D, I, U, NO_APPROXIMATION, PARITY_UNVERIFIED]
parity_claim: NONE
parity_status: UNVERIFIED
visual_parity_claim: false
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32 x86, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. No donor binary executed, copied, committed or captured; no donor file written; no GPU frame taken. All reads pinned document=t_87f0f3c130b0."
scope_guard: "No repo code/asset/shader/config/test/fixture/result/Godot/git change. Exactly one repo file written: this report."
multi_pass: true
tooling_constraint: "native toolset pruned. Only native_function_study was called among native_* (summary then complete); no native_bytes_*/native_xrefs_*/native_instruction_*/native_functions_* call. core_target_open, core_session_show, core_overview_show, core_feature_find, core_evidence_browse and report tools only."
chain_status: "0/6 CLOSED"
verdict: "RESULT IS NOT GOOD — three of four target functions are not present in the incomplete builtin xref DB; the one discovered target (sub_739bf8 @0x739bf8) is a 7-instruction getter returning [obj+0xb4], not a +0x50/+0x200 writer and not a caller of the other three. Zero byte-proven h+0x50 writes (the +0x50 writes found are on unproven bases with three incompatible types), zero h+0x200 writes, zero direct reachability to glBindTexture@thunk/glTexImage2D@thunk or to the 0x854250 gate. Structural negatives only; no [U] value promoted; no parity."
---

# DEC-U-B2-UREG-CALLERS — caller / reachability sweep (read-only)

> **PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED.** No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass. `parity.claim = NONE`, `parity.status = "UNVERIFIED"`, `visual_parity_claim = false`, `chain = 0/6`, **`RESULT IS NOT GOOD`**.

## 0. Authority and discipline

Every statement below is `[O]` (bytes/instruction/xref row lifted this ticket, pinned `t_87f0f3c130b0`), `[D]` (deterministic consequence of `[O]` rows), `[I]` (interpretation, never wired), or `[U]` (UNVERIFIED, settled only by §7's capture). Prior-ticket VAs/pseudocode are **hypotheses only** and are never re-cited as evidence. Every `ev_…` id quoted was produced **this ticket** by `native_function_study`, `core_feature_find`, `core_overview_show` or read back with `core_evidence_browse` against the pinned target. No donor binary was executed; no value was promoted; no port file was edited.

Load-bearing result: **the sweep returns structural negatives plus one new byte-proven getter→field-store chain.** It does not close any behavioural `[U]` and it does not authorise a single water value.

## 1. Pin verification and discovery limit

| Check | Result | Evidence |
|---|---|---|
| Target id | `t_87f0f3c130b0` | `core_target_open` / `core_session_show` this ticket |
| SHA256 | `87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c` — exact match to the required pin | `core_target_open`, `core_session_show` |
| Binary | PE32 x86 Windows executable, 5,768,048 B | `core_target_open` |
| Overview | `18918 functions, 12073 strings, 746 imports from 18 libraries. Function discovery stopped at an analysis limit, so the function list is incomplete.` | `ev_60b497434aa3e6cb68b019fd0a3b016ec0415ef6ec1a3189726faa8d3752f4c4` `[O]` |

**Tool limitation, load-bearing:** the builtin lifter's xref DB is incomplete by its own report. A `function_not_found` result is **absence of a discovered entry, not absence of code**. It is never used as positive evidence of runtime absence.

## 2. Pass ledger (≥5 passes per studied function; every pass logged)

| Pass | Operation | Fresh read this ticket | Result |
|---|---|---|---|
| P1 | `native_function_study` **summary** | `sub_739bf8` + all 8 callers + chain/thunk functions | Counts and first references: `sub_739bf8` 7 insns / 42 call sites; 8 distinct callers enumerated §4; GL thunks located §6 |
| P2 | `native_function_study` **complete** | Same set | Full assembly, pseudo-C, basic blocks, `callers`, `callees`, `flow_*`, `native_api`. `sub_739bf8` = getter (§3) |
| P3 | Targeted facet scan | Every assembly row and callee row of all 8 callers scanned for `82f060 / 82f114 / 82f86c / 739bf8 / +0x50] / +0x200] / 4afb0c / 4afc34 / 854250 / 8520a8 / 856080 / 853ad4` | Zero hits for the three undiscovered targets, `+0x200]`, both GL thunks, `0x854250` and the prior staging addresses in all 8 callers (§5/§6) |
| P4 | Context windows | ±6 instruction windows around every `+0x50]` hit in `sub_710380`, `sub_739d3c`, `sub_73a0b8`, `sub_7393a8`, `sub_7d8a14` | Three incompatible `+0x50` semantics separated (§5) |
| P5 | `core_evidence_browse` paging + import cross-ref | Paged `callers` of `sub_7101f0` (200 rows: 0/64/128/192, `status complete` at 192); paged `assembly` of `sub_7d8a14` (12 pages) and `sub_710380` (8 pages); `core_feature_find` on `glBindTexture`, `glUniform1i`, `glUniform1f`, `glActiveTexture`, `glTexImage2D`, `Uniform`, `hmapTex`, `hmapW`, `HeightMapTexUnit`, `FUN_0082f060`, `sub_82f060` | 0 target addresses in the 200-caller list; 0 `+0x200]`/thunk rows in paged assembly; import asymmetry recorded (§6) |

No function consumed more than 5 passes. `native_function_study` on `0x82f060`, `0x82f114`, `0x82f86c` (`FUN_…`, `sub_…`, `0x00…` forms all tried) returned `function_not_found`; dense address probes around them (`0x82f050/0x82f058/0x82f064/0x82f070`, `0x82f0f0/0x82f110/0x82f118`, `0x82f860/0x82f870`) also failed, while probes at `0x82f880`/`0x82f8a0` resolved to `sub_82f87c`/`sub_82f89c` (§3). The three targets therefore have **no caller list available in this engine**; this is reported, not filled by inference.

## 3. The four target functions — status `[O]/[U]`

| Target | Discoverability this ticket | Byte-proven body / role | Standing |
|---|---|---|---|
| `FUN_0082f060` (`0x82f060`) | `function_not_found` in name and address forms; no containing function in dense probes | none lifted | Callers/body `[U]`; prior "float getter of `*(h+0x200)`" is hypothesis only |
| `FUN_0082f114` (`0x82f114`) | `function_not_found`; no containing function in probes | none lifted | Callers/body `[U]` |
| `FUN_00739bf8` (`0x739bf8`) | **discovered** as `sub_739bf8`, `ev_11e60953df7762586c3d1e1ce95c57e30c319aecb31c6b2f296f0622df65a9c6` | `push ebx; mov ebx,eax; mov eax,ebx; call 0x739bd8; mov eax,[eax+0xb4]; pop ebx; ret` — 7 insns, 1 block, 1 callee, 42 call sites, 0 strings. Reads `[obj+0xb4]`; writes no memory | `[O]/[D]` getter; **not** a `h+0x50`/`h+0x200` writer, and **not** a caller of the other three targets |
| `FUN_0082f86c` (`0x82f86c`) | `function_not_found`; nearest discovered entries are `sub_82f87c` @`0x82f87c` (`ev_a3f4a724b82421e61e03426cdda7a6407f352fa9fd0561ccb673886d79d3398c`) and `sub_82f89c` @`0x82f89c` (`ev_ae601812195bf1f57a462ffa89af50e2e7af67c22824577fc6d72bc42eee244d`), both 3-arg wrappers into `0x82fe94` (itself undiscovered) | `sub_82f89c` contains `fld dword [ebp+8]; fchs; fstp` — one float argument is negated before the call. `sub_82f87c` passes the same three args unmodified | `[O]` wrapper shape; `[U]` whether either is the prior `FUN_0082f86c`, and `[U]` any link from the negation to `hmapMin/Max`. **No value promoted.** |

`[D]` The `sub_739bf8` return chain is byte-proven end to end: `0x739bd8`: `mov eax,[eax+0x10]` → `call 0x7101f0` (`ev_e1bb3f1b24630ad6435000f6bcc00d9ed7daf34ff62e3c031d8929f874841331`); `0x7101f0`: `mov eax,[eax+0x58]; mov eax,[eax+0x34]; ret` (`ev_f0b208bc2a5373a80ff360723a90d3baabd53ec219412e3a5f4919f3ee133837`); `sub_739bf8` then returns `[[[arg+0x10]+0x58]+0x34]+0xb4`. Which engine object the initial `arg` is, and which uniform (if any) consumes that dword, stay `[U]`.

`[D]` A second byte-proven edge from the same family: `sub_851d44` (`ev_1fa98c180aee0f8466b01ba684d9238b7014797e36af2ec18426f35b3cbe3c6c`), called by `sub_7393a8`, does `0x851d53 call 0x739bd8`; `0x851d58 mov eax,[eax+0xc4]`; `0x851d5e mov eax,[eax+0x190]`; `0x851d64 mov edx,[ebx+0x10]`; `0x851d67 mov [edx+0xf0],eax` — or writes `0` at `0x851d74` on the null branch. This is a `+0xf0` store, **not** `h+0x50`/`h+0x200`.

## 4. Caller / reachability table — all 42 call sites of `sub_739bf8` in 8 callers

Callers are byte-proven from the dossier's `callers`/`incoming_references` lists (evidence per row). "Reaches gate / GL bind" means a **direct** call row to `0x854250`, `0x854054`, `0x4afb0c` or `0x4afc34` in this engine's assembly/callee list; indirect calls are counted separately and stay `[U]`.

| Caller (evidence) | Sites → `0x739bf8` | Writes `+0x50`? | Writes `+0x200`? | Direct → gate / GL bind? | Indirect (`target:null`) calls `[U]` |
|---|---|---|---|---|---|
| `sub_710380` `ev_404ef07408ab928d8c13053d14b80f8742b502a615bf208b2ad3bd3ca3b22689` | `0x7104f1` | **YES** on `ebx`: `0x7104b4 mov [ebx+0x50],eax` (return of `call 0x74e67c`); base identity `[U]` | NO | NO | 0 |
| `sub_739268` `ev_f70986052b4b1031f358731cb9a748a90a55a94d8528ec2680d4ecc1a9b3a9f9` | `0x7392ac, 0x7392bc, 0x73932d, 0x739341, 0x73934e` | NO | NO | NO | 0 |
| `sub_7393a8` `ev_a406e9e0b80e3db346b5b4ba35fb36253100b203c282d6db9692cf00cc12a15e` | `0x739632, 0x739641, 0x739653, 0x73966c, 0x739686, 0x739696, 0x7396b3` | `lea eax,[edi+0x50]` @`0x7397c3` → `call 0x405400` — **string clear**, not a handle store | NO | NO | 0 |
| `sub_73988c` `ev_bb7a7b2a1839f35fd3c8778ff5401477d8a39ad5747dc13c107602437b15ef64` | `0x739921, 0x73992c` | NO | NO | NO | 0 |
| `sub_739b6c` `ev_9a2251e8db3bcd1de06e90558587217644f2dd05eb809e13188e7478fceef763` | `0x739ba0, 0x739bab, 0x739bc3` | NO | NO | NO | 0 |
| `sub_739d3c` `ev_2fbfb23943624eea051259b29b0b5abe7fa7a85f95162ea557005b3b8809371a` | `0x739e2c` | NO — `0x739f5f mov edx,[ebx+0x50]` is a **read**, forwarded to `call 0x846a88` @`0x739f64` | NO | NO | **11** |
| `sub_73a0b8` `ev_1b70cd0be9b8cb8288c2b78772063881f6ec5e106f2e2d7fce7cf4578e17b10f` | `0x73a179, 0x73a2d2, 0x73a2ff, 0x73a3b0, 0x73a3cb` | **YES** but two other types: `0x73a242 mov byte ptr [eax+0x50],1` where `eax=[ebx+4]` (byte flag); `0x73a52a lea eax,[ebx+0x50]`→`call 0x405454` (string assign), `0x73a581 lea eax,[ebx+0x50]`→`call 0x405400` (string clear) | NO | NO | **15** |
| `sub_7d8a14` `ev_22aa91a6dc825f99c81a24ee5c1a4471d74576c5ad0b9556b5f48030a7eee29a` | `0x7d8a58, 0x7d8a72, 0x7d8a8c, 0x7d8aac, 0x7d8b0b, 0x7d8b69, 0x7d8be6, 0x7d8c46, 0x7d8d9a, 0x7d8dfa, 0x7d8e77, 0x7d8ed5, 0x7d90ce, 0x7d90ee, 0x7d9115, 0x7d919b, 0x7d921f, 0x7d92a3` | NO — only `[ebp-0x50]` stack locals (`fstp` @`0x7d8b91`, `0x7d8e22`) | NO | NO | **8** |

Totals: 42 call sites = 1+5+7+2+3+1+5+18. Distinct callers: **8**, all exhausted (0 unvisited xrefs remaining **in this engine's DB** — this settles the static xref question for `sub_739bf8` only, not the prior chain). `[D]` **No caller of `sub_739bf8` writes `+0x200`, and no caller directly calls `0x82f060`, `0x82f114` or `0x82f86c`.** Prior's `FUN_008520a8 ← FUN_00739bf8 → FUN_0082f86c` shape is **not reproducible** here: `0x8520a8` is undiscovered and does not appear among the 42 sites; `0x85203c` is also undiscovered, while `sub_852068` (`ev_2486a63d6cdac3f1c2fc98bfa616d1771745d594c90d6fb9d92346ac181517cb`) is called from `sub_73a0b8` @`0x73a3e4` and is a vtable-dispatch wrapper (`call dword ptr [esi+0xc]` @`0x85207b`) — its indirect target is `[U]`.

## 5. `+0x50` / `+0x200` write audit `[O]/[D]/[U]`

`[D]` **Three incompatible `+0x50` semantics were separated — none is proven to be `h+0x50`:**

1. **Object-pointer field** — `sub_710380` @`0x7104b4`: `[ebx+0x50] = eax` where `eax` is the return of `call 0x74e67c` (`eax=[0x74b85c]`, `ecx=ebx`, `dl=1` at `0x7104a8–0x7104af`). It is then dereferenced at `+0x168`, `+0x188`, `+0x68`, `+0xf8`, `+0x100`, `+0x150`, `+0x88`, `+0xac`, `+0xb4`. The base `ebx` has no type/identity recovered → `[U]`.
2. **Byte flag** — `sub_73a0b8` @`0x73a23f–0x73a242`: `eax=[ebx+4]; mov byte ptr [eax+0x50],1` — one byte on a sub-object, not a pointer and not a scalar tuple member → `[U]` identity.
3. **Delphi string field** — `sub_73a0b8` @`0x73a52a/0x73a581` and `sub_7393a8` @`0x7397c3`: `lea eax,[reg+0x50]` passed to `0x405454` (string assign) / `0x405400` (string clear), followed in `sub_7393a8` by byte defaults `[edi+0x54/0x55/0x56]=1` @`0x7397cb/0x7397d3/0x7397cf`. These are the same numeric offset on different bases with different content types — conflating them with the prior `h+0x50` would be invention.

`[D]` **New byte-proven getter→field-store chain** (all rows `ev_404ef074…`, `sub_710380`):
- `0x7104b7 mov eax,[ebx+0x5c]` → `0x7104ba call 0x739bd8` → `0x7104bf mov eax,[eax+0xdc]` → `0x7104c5 mov edx,[ebx+0x50]` → `0x7104c8 mov esi,[edx+0x168]` → `0x7104ce mov [esi+8],eax`.
- `0x7104dd call 0x739be4` → `0x7104e2/0x7104e5` → `0x7104eb mov [edx+0xc],eax`.
- `0x7104ee mov eax,[ebx+0x5c]` → `0x7104f1 call 0x739bf8` → `0x7104f6/0x7104f9` → `0x7104ff mov [esi+0x10],eax`.
- Later reads of `[ebx+0x50]` write `[eax+0xac]` @`0x7109a7` and `[eax+0xb4]` @`0x7109bc`.

`[D]` These are three adjacent dwords `+8/+0xc/+0x10` of the object at `[[ctx+0x50]+0x168]`. **Which dword (if any) is `hmapW/H/Min/Max`, which object (if any) is `h`, and whether this struct is a live water parameter block are all `[U]`.** No number from this chain is promoted.

`[D]` **`+0x200`: zero writes, zero reads** across all 8 caller bodies and across 12 paged assembly pages of `sub_7d8a14` and 8 of `sub_710380`. This is a negative over the discoverable corpus only; the prior getter inputs `*(h+0x200)` are not re-provable here and stay `[U]`.

## 6. GL bind / `0x854250` gate reachability `[O]/[D]/[U]`

| Import / API (evidence) | Import slot | Discovered users | Standing |
|---|---|---|---|
| `glBindTexture` `ev_6f77e127ec9150a63251e8fd4f5a4c547caf7abd6d4616bfd7bb4f72b3c2fa75` | `opengl32.dll` `0x907d94`; string @`0x90aea6` | thunk `glBindTexture@thunk` @`0x4afb0c` (`jmp [0x907d94]`), **1** user: `sub_88f8a8` | `[O]` |
| `glTexImage2D` `ev_0aeea7e6a55f8326bf2122973f43d880fd7efbc6b8ab729688c1ad9e11c51211` | `opengl32.dll` `0x907d00`; string @`0x90ac70` | thunk @`0x4afc34`, **12** sites: `0x4c29a4`×3, `0x55e240`×3, `0x5d2ad4`, `0x5d2b9c`, `0x5d2c68`×3, `0x7715f4` | `[O]` |
| `glCopyTexImage2D` (same `TexImage` query) | `opengl32.dll` `0x907d7c` | `used_by: []` — **zero discovered users** | Absence in incomplete DB ≠ runtime absence `[U]` |
| `glUniform1i` `ev_dff42170dae152ea0422aa7b22d15f8c31369657b3b6382745f5f16c530464b8` | none | 0 strings/functions/imports (`no_match` limitation logged) | `[U]` — not proven absent |
| `glUniform1f` `ev_27094eb6f16f5f89631524c4248bbdff7ece61e31043cd9298211ad2caaf1c73` | none | 0 matches | `[U]` |
| `glActiveTexture` `ev_fdda5ca0be94c447adb8a20855d5e7733f2e3c90802a340178b3aab7501a2d8f` | none | 0 matches | `[U]` |
| generic `Uniform` `ev_028f6c552181dcc4b07a4cfe7ada483b3e64da7d22e52b5331a8a46a2e2dc1ff` | none | 0 matches | `[U]` |
| `hmapTex` `ev_eab32206dbca80e3b6115a716fe408ea66b320c4fd60812cf9e82816738ccf48`, `hmapW` `ev_c8ac41757209e2697995194893e3cd5f4ebac0b894359d60634c4d2d641ea4b8`, `HeightMapTexUnit` `ev_6de6b748f8497b84ca4a377b1d9c9f22945407132261703856f1cbd650a76bb6` | — | 0 literal matches in this engine's string index (`no_match` limitation) | `[U]`; prior single-hit VAs are hypotheses only |

`[D]` The sole discovered `glBindTexture` user is `sub_88f8a8` (`ev_fe34ac76726ae8a6d5a8a3acfdc299eadec912967fdce64acd049740340c827c`): `0x88f8b5 cmp esi,[ebx+edi*4+0x90]`; `0x88f8bf push ecx` (target); `0x88f8c0 call 0x4afb0c`; `0x88f8c5 mov [ebx+edi*4+0x90],esi`; `0x88f8cc inc [0x8fb0d8]`. Its callers are `0x4ec794`, `0x4ecbd8`, `0x5d2234`, `0x5d27dc`, `0x5d2ad4`, `0x5d2b9c`, `0x5d2c68` — **disjoint from all 8 callers of `sub_739bf8`**. No byte-proven path from the swept caller set to a bind call exists in this engine.

`[D]` **No row in any studied assembly or callee list equals `0x854250`, `0x854054`, `0x8520a8`, `0x856080` or `0x853ad4`.** The prior gate (`C+0xe0 != 0 && [C+0xe0+8] != 0` at `0x854250`) and binder (`FUN_00854054`) are **not reachable in the discoverable graph**; they are prior-reported structure, not re-proven this ticket. Gate-dependent state stays `[U]`.

`[U]` Indirect calls remain the only possible bridge: `sub_739d3c` 11 `target:null` calls, `sub_73a0b8` 15, `sub_7d8a14` 8, plus `sub_852068 @0x85207b call dword ptr [esi+0xc]`. Resolving them needs a deeper xref pass or a live trace; neither was performed. No reachability claim is made.

## 7. `[U]` register — exact capture termination (unchanged)

Gating precondition for **every** row: water field visible (break `FUN_00603d30` @ `0x603d30`, read `[ebp+0x1c]`); live path identified first (hook `glShaderSource`: `hmapTex` present = DEV file pair `water.dev.vert/frag` per `water.lib:67-68`; `alphaDepth`/`deepColor` = BUILTIN embedded pair); height gate open at `0x854250` (`C+0xe0 != 0 && [C+0xe0+8] != 0` — closed gate voids the frame). Owner-authorised donor session only; forbidden to workers. Captures on the BUILTIN path settle nothing.

| # | Still-`[U]` item | Static state after this sweep | Capture experiment (break + trace + byte comparison) | Zero-mismatch termination |
|---|---|---|---|---|
| U3-TEX | `hmapTex` GL identity `(target, name, w, h)` + provenance class | `[U]` — 0 literal matches this engine; no byte-proven writer/ctor/store edge recovered; `glBindTexture` has only the unrelated cache thunk `sub_88f8a8` | At the `FUN_00854054` 7e.10 break (same draw as the U3-NUM tuple): record `glActiveTexture(GL_TEXTURE0+u)` with `u=C+0xdc`, `glBindTexture(target,name)`, `glUniform1i(hmapTex,u)`, `glGetTexLevelParameteriv(name,0,{WIDTH,HEIGHT,INTERNAL_FORMAT})` + sampler state; full-frame history of `name`: (a) FBO attachment (`glFramebufferTexture2D*` with that name), (b) copy dst (`glCopyTexImage2D/SubImage2D`), (c) upload-only (`glTexImage2D` with that size). Dump one 8×8 texel block + channel carrying height; log map name + `water.lib` hash | **Terminate iff the same `(target,name,w,h)` repeats with 0 mismatches across ≥2 frames + 1 camera move** on that map, and exactly one provenance class (a/b/c) accounts for `name` with 0 counter-examples. Mixed/unknown provenance ⇒ keep `bind_height_grid` substitute labelled `[U3]`; never promote art/`heightmapwaves0.tga`/neutral texel |
| U3-NUM | Live `(hmapW,hmapH,hmapMin,hmapMax)` for a named shipped map | `[U]` — `+8/+0xc/+0x10` stores in `sub_710380` are byte-proven but the struct, the object and the uniform mapping are not; live tuple values unrecovered; `+0x200` zero hits | Break `FUN_00854054` bits 7e.10–7f.1 (`0x854250–0x8542f0`) with the named map loaded + field visible. Record pushed `C+0xd0/+0xd4` ints, `C+0xe4/+0xe8` floats **plus** chain pointers (`layerObj`, `h`, `h+0x200`, `C+0xe0`, `[C+0xe0+8]`, and the `[[ctx+0x50]+0x168]` struct) and same-draw `glUniform1i/1f` hook values on `hmapW/H/Min/Max`. Name the map + `water.lib` hash | **Terminate iff the same 4-tuple repeats with 0 differing bits across ≥2 frames + 1 camera move** on that map; those 4 numbers (not `map_size`/`±2.96`/`±2.964`/clamp/`C+0x54` defaults, nor any `+8/+0xc/+0x10` value guessed from this sweep) become the port parameters **for that map only**. A second map needs its own row |
| B2-U-REG-CALL | Three undiscovered targets' callers/bodies + indirect bridge to the gate | `[U]` — `0x82f060/0x82f114/0x82f86c` absent from incomplete xref DB; 8/8 callers of `sub_739bf8` exhausted with 0 direct links to them, to `+0x200`, or to the gate/GL thunks; 34 unresolved indirect calls total across three callers | Static: re-run this sweep with a complete-function engine/Ghidra xref DB and resolve every `target:null` call in `sub_739d3c`/`sub_73a0b8`/`sub_7d8a14` and the `0x85207b` vtable call; live: break `0x854250` and record the return of each of the three getters with its argument object pointer | **Terminate iff each of the three functions has a visited body with 0 unvisited xrefs remaining and the gate-reaching caller is identified (or proven absent) with 0 counter-examples.** Until then no caller/value/identity is promoted; `hmapTex` stays `[U3]` |

General rule: any mismatch, closed gate, or wrong-shader-path frame voids the capture. **No parity follows from termination** — termination only authorises wiring the captured reals for the captured map/slot. No water value is promoted by this report.

## 8. Exact port stance (NO edits made — owner applies)

All relevant lines re-cited at repo HEAD via priors; verified present, untouched by this worker. **Wire only captured reals.**

1. `variant3d/scripts/water3d.gd:68` (`MAX_HEIGHT=2.96`), encode `:652`, `hmapMin/Max` binds `:668-669`, `max_height :763` — KEEP SUBSTITUTE + `[U3]` LABELS. FORBIDDEN: presenting `±2.96`/`±2.964`/clamp, or any value inferred from the `+8/+0xc/+0x10` stores, as recovered.
2. `variant3d/scripts/water3d.gd:486+` (`bind_height_grid`), `:655` (`height_tex`), hmap binds `:663-669` — KEEP SUBSTITUTE. No texture name/id/unit from this sweep.
3. Uniform-table `:143,146-147`, stats `:305,346`, ledger `:909,913,940` — LABEL-ONLY: cite this sweep (42 call sites / 8 callers of `sub_739bf8`; getter chain `+0xb4`; three incompatible `+0x50` semantics; zero `+0x200`; zero direct gate/GL path; three undiscovered targets); keep every `[U3]` tag.
4. FORBIDDEN: hard-coding any shipped-map `(W,H,Min,Max)`; inventing a texture name/id or unit; treating `sub_82f89c`'s float negation as `hmapMin/Max` without a byte-proven caller; equating any of the three `+0x50` stores with `h+0x50`; claiming the prior `0x8520a8` chain from this engine's xref DB.

## 9. Explicit non-claims and file discipline

- **No parity claim.** No donor binary executed, no GPU frame captured, no port capture compared. `parity.claim = NONE`, `parity.status = "UNVERIFIED"`, `visual_parity_claim = false`, `chain = 0/6`, **`RESULT IS NOT GOOD`** unconditionally.
- **No approximation substituted.** No texture name/size/unit, no shipped-map tuple, no conversion factor supplied. The decoded-grid substitute and `±2.96` span remain explicitly labelled `[U3]`.
- **No guess promoted.** The three undiscovered targets are `[U]`, not absent; zero-discovered-users for `glUniform1i/1f`/`glActiveTexture`/`glCopyTexImage2D` is `[U]`, not runtime absence; the near-target wrappers are `[O]` shapes with `[U]` identity.
- **Structural closure only.** The 8/8 caller exhaustion settles the `sub_739bf8` xref question within the incomplete DB; it does not close any behavioural `[U]` hanging off it.
- **Read-only compliance.** Exactly one repository file written: `docs/terrain_swarm_2026-11-26/reports/DEC_U_b2_ureg_callers.md`. No code/shader/asset/config/Godot/git change. No donor file opened for write or executed.
- **Claim register (audit-level):** (1) pin verified `t_87f0f3c130b0`/SHA256 — `[O]`; (2) discovery limit reported by the engine itself (`ev_60b497…`) — `[O]`; (3) `sub_739bf8` = getter returning `[obj+0xb4]`, 42 sites / 8 callers — `[O]/[D]` new; (4) byte-proven getter→`+8/+0xc/+0x10` field-store chain in `sub_710380` — `[O]/[D]` new; (5) three incompatible `+0x50` semantics, zero `+0x200` writes — `[O]/[D]` new; (6) no direct gate/GL-thunk reachability from the swept set; `glBindTexture` sole user `sub_88f8a8` disjoint — `[O]/[D]` new; (7) three targets undiscovered, identity/values/liveness all `[U]` with §7 termination — `[U]`; (8) no water value promoted, no parity — scope guard.

*End of DEC-U-B2-UREG-CALLERS.*
