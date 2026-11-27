# DEC_U_anim_deep — READ-ONLY static decompilation: animation blend / completion

Scope: full 1:1 Cossacks 3 donor port. Static read-only. No code, no Godot, no git, no donor execution, no copying. Parity UNVERIFIED. No approximations. No parity claim.

## 1. Target verification (before any finding)

- Donor opened read-only: `C:\Games\Cossacks 3\cossacks.exe`
- Pin: `t_87f0f3c130b0` — VERIFIED (active_target matches)
- SHA256: `87F0F3C130B027E7C4E72DC217EAE9D592982370D112E0D224897BC92AF4E16C` — VERIFIED (session target record matches; all evidence subjects carry same sha256)
- Mode: Deep (Ghidra language path not needed for these reads); host `windows-x86_64`; engine `builtin 0.6.1`; no donor binary executed.
- Tooling: only `core_target_open` (already open), `core_session_show`, `core_feature_find`, `native_function_study` (summary then complete), `core_evidence_browse` (paging). No other `native_*` called. No `.bind` unpacking. No port behaviour wired.

Context inputs (not re-verified here): `PORT1TO1_u_classify` lists animation blend/completion as owner-gated runtime `[U]`; port has T1–T26 families, 40 action names (set-difference empty), 63 tool skins, death families/ghost blink/PFX timing; `PORT1TO1_asset_gap_b` verified 40 actions minus T-referenced AAF tokens = empty. Those context claims are repeated as context only, not as findings of this report.

## 2. Method

1. `core_session_show` confirmed active target + pin + SHA256 above.
2. `core_feature_find` (case-insensitive) for: `animation`, `blend`, `frame`, `action`, `loop`, `anim3d`, `tmo`, `death`, `ghost` — plus disambiguation queries `anim`, `AlphaBlend`, `XAnimation`, `BONE`, `WGHT`, `AAF`, `.aaf`, `.tmo`, `skeleton`, `interpol`.
3. `native_function_study` summary-then-complete on: `0x4afb14` (blend thunk), `0x88fb78` (its sole caller), `0x653aaf` (AAF-substring control).
4. `core_evidence_browse` paging of `ev_c419c0083dd0641e84dce6d78845887824dc43cfb6f9dfe637e5d12af30599b8` (`assembly` rows 0–7, `callers` rows 0–4).

## 3. Byte-proven [D] facts (evidence id + address; nothing else asserted)

### [D1] Pin / hash — session record
- `t_87f0f3c130b0`, SHA256 `87f0f3c130b0...af4e16c` per `core_session_show`. Every evidence record below carries identical `subject.sha256`. No finding precedes this check.

### [D2] `animation` literal surface is one inert string, zero functions
- Evidence `ev_0ada956001334679f68b962494940dfa6df311d0508a9511be4fd66103c749f7`: query `animation` → 1 string `\\XAnimation` at `0x959080` with `references: []`; 0 function names, 0 imports, 0 functions involved. Cross-check `ev_7b018de06028ddcc69dd0aa244e75df207e8fa081971d4cbd46388b76dd62ab6` (`XAnimation`) and `ev_2f467165d38a41035e097ded723f2f5bfb534b7071047ebb50dad87d3cdebfce` (`anim` → `OSWAnimatedSprite` at `0x958d96` + same `0x959080`) confirm the only static surface. No blend-stage edge is attached to either string in the returned records.

### [D3] `blend` static surface is OpenGL state, not skeletal blend
- Evidence `ev_4ea33bf08dcc8108727827a625d52fe7837604db851778cbc7e70c109685bc70`: query `blend` → strings `glBlendFunc` at `0x90ae98`, `AlphaBlendValue` at `0x968914` (both `references: []`); 1 function `glBlendFunc@thunk` at `0x4afb14`; 1 import `glBlendFunc` (`opengl32.dll`, slot `0x907d90`, used_by `0x4afb14`).
- Evidence `ev_b555d32feb1cf20ad1244bfccadea23f1c63c64a72b8d44b087c481e2fbfe74a` (`native_function_study` complete on `0x4afb14`): 1 block / 1 instruction `jmp dword ptr [0x907d90]` at `0x4afb14`; callee `glBlendFunc`; single caller `sub_88fb78` at site `0x88fbb8`; outgoing refs `0x907d90` (`__imp_glBlendFunc`) and `0x4afaa9`. No animation-frame operand present.

### [D4] Blend-stage call edge: `sub_88fb78` → `glBlendFunc@thunk` (cached render-state wrapper)
- Evidence `ev_c419c0083dd0641e84dce6d78845887824dc43cfb6f9dfe637e5d12af30599b8` (`native_function_study` complete on `0x88fb78`, VA `0x88fb78`, size 70, 4 blocks / 18 insns):
  - Guard: `cmp dl,[eax+0x130]` at `0x88fb78` / `jne 0x88fb88`; `cmp cl,[eax+0x132]` at `0x88fb80` / `je 0x88fbbd` (early-out `ret` at `0x88fbbd` when cached values match).
  - Store path `0x88fb88–0x88fb9a`: `mov [eax+0x130],dl`, `mov [eax+0x132],cl`, `mov [eax+0x131],dl`, `mov [eax+0x133],cl` — four byte field offsets `0x130/0x131/0x132/0x133` on the object in `eax`.
  - Enum translate: `mov eax,[eax*4+0x8fb1ac]` twice (at `0x88fba4` for `cl`, `0x88fbb0` for `dl`) — GL enum table base `0x8fb1ac`; `push`/`push` then `call 0x4afb14` at `0x88fbb8`.
  - Fan-in: 34 callers listed (e.g. `sub_4ef810` sites `0x4ef995/0x4ef9ba/0x4efa3a`; `sub_53dae0` `0x53db6f/0x53dc1e`; … `sub_886cf0` `0x886e95/0x8870df`). Zero referenced strings.
- Paging proofs: `ev_adf364227579d38041ca66147b9771494d7f89860b1267b6a1a770c760a5ff3e` (assembly rows 0–7, `next_offset: 8/18`); `ev_51f227e555f8d83746b862ba6f0a4ac87f1d947abe910b299854078c1497f8d2` (callers rows 0–4/34 with field names `caller/name/site`).
- Interpretation boundary: this is a render-state cache for `glBlendFunc` args. It is NOT evidence of skeletal/animation crossfade weights — no bone, frame-index, or time operand appears in the 18 instructions.

### [D5] `frame`/`BONE`/`WGHT` surface is a mesh-chunk tag table, not a blend program
- Evidence `ev_259760104f1a59115e448dab360cd6ff5d1912d6e87f757329e00a075d348978` (`frame`): 5 strings incl. 3D chunk-tag blob at `0x8f6214`: `FRAME 000.......LAYRPNTSPOLSSURFCOLRLUMIDIFFSPECREFLTRANGLOSSIDERFOPRIMGSMANVMAPTAGSPTAGVMADCLIPSTILFACECURVPTCHMBALBONEWGHTTXUVMORFSPOTSURFPARTSMGP`; only function is GDI `FrameRect@thunk` at `0x408984` (imports `FrameRect/DrawFrameControl/DefFrameProcA`); no animation function involved.
- Evidence `ev_3eb17917a367af6b6b01a5c49572d916e73e127ac1096a1f2a587426da39c8f4` (`BONE`) and `ev_45ab331ebfddb5002dea17cddeeae4b0b0299276716b5918f7374c245e9666e6` (`WGHT`) each resolve to the same single string at `0x8f6214` with zero functions/imports. `BONE`/`WGHT` are byte-present only as substrings of that tag blob; no field offset, no blend weight, no caller edge is attached in these records.

### [D6] `AAF` hits are VA-substring false positives, not format tokens
- Evidence `ev_a1f78f320339226fcbf051ed5765daca8f6d1759942aae616186f1165d5809b3` (`AAF`): 0 strings, 0 imports; 5 “function names” `sub_653aaf @0x653aaf`, `sub_74aaf8 @0x74aaf8`, `sub_7aaf04 @0x7aaf04`, `sub_7aaf10 @0x7aaf10`, `sub_8d3aaf @0x8d3aaf` matched only because the hex addresses contain `…aaf` (`why: ["name matches"]`).
- Control study `ev_57da91a824c2ce5b540f09aa82c72b54c0fce3eb5a504dab9a8d964ba9352269` (complete on `0x653aaf`): 1 block / 7 insns `0x653aaf–0x653aba` (`mov eax,ebx; pop edi/esi/ebx; mov esp,ebp; pop ebp; ret 8`) — a function epilogue reached via data ref from `0x653a95` (`sub_653990`); 0 callees, 0 strings, 0 API calls. No AAF parser, no action table, no frame literal. `.aaf` (`ev_78f478aa7f6d0227639f4f20144300c14f8bb884db2648fcf8416a3583c12c`) is likewise 0/0/0.

### [D7] Null surfaces (absence recorded, not proof of absence)
- `loop` `ev_f7bd3755f12559701363af19f59e1267dfde829f99ec5e80dc7fdd58d7a28cb6`: 0 strings / 0 functions / 0 imports.
- `anim3d` `ev_77d53b1b571373cde8635654545038cf5c10f5c4043d62b66f7c5eb662868051`: 0/0/0.
- `death` `ev_a8cf8ca2351f1de0d06f69275f4ccf279de4f692350569bb43d00d73cf6b55df`: 0/0/0.
- `ghost` `ev_5c5020d519a36b0f2fcd038b836003e7a8b8c572b907e18b07029888d9daaa2d`: 0/0/0.
- `.tmo` `ev_179d2040b8f8dd4c3f57d613ede7e226334451b283c3e85382de34cd78e069fe`, `skeleton` `ev_40fee5ff4d8fb895f8bad9e80b49d8c892510aca444a2d5aa1e7763726237bf9`, `interpol` `ev_41041e321104b5bfd51bbb647b37860bb1a3bbf3cf7843c187916745de93217d`: each 0/0/0.
- `tmo` bare `ev_edf63e996e3ef8020a941cfb802b89fbf6131a11333be1ae593abe04072246e2` hits only Win32/GL thunks containing substring `tmo` (`GetModuleFileNameA/GetModuleHandleA/SetStretchBltMode/glLightModelfv/glLightModeli` at `0x4013a0/0x4013a8/0x407cd4/0x4082a4/0x4082b4/0x40873c/0x4afd24/0x4afd2c`) — no animation function.
- `action` `ev_290adf60f9e358f4d2ed83e938977187fb862a1024fe090f87e4dc37a17e6aae`: 108 strings are Delphi/VCL `TAction/ActionList/Action*` IDE/debugger names (`0x95a395…0x96947f`, e.g. `ActionDebugStepOver/Into/Run`, `ActionLoadFile/SaveFile/Execute/Thread`); 0 function names, 0 functions involved. No unit-action/completion binding is attached.
- `AlphaBlend` `ev_1eee582c76543b20bb724613b0db439cb0e3249450b8820237e18c18a9f5e8e5`: single string `AlphaBlendValue` at `0x968914`, 0 functions — render constant name only.

## 4. Owner-gated runtime [U] (no static value exists above; zero-mismatch capture required)

Every item below stays `[U]`. Nothing in §3 supplies its value; no value is invented, estimated, or wired into the port:

- [U1] Skeletal blend weights / crossfade curves between T1–T26 families and the 40 action names.
- [U2] Blend-stage selection: which of the 34 `sub_88fb78` callers (if any) sits on an animation path vs. UI/ghost/PFX alpha path — requires owner-only runtime trace with exact call-stack capture; static fan-in alone does not decide it.
- [U3] Completion thresholds / end-of-action events (what fires “action done”).
- [U4] Per-frame interpolation (lerp/slerp choice, tick-to-frame mapping, loop wrapping).
- [U5] Death families, ghost-blink timing, PFX timing attached to frames.
- [U6] Any mapping of T-referenced AAF tokens to the 40 actions (asset-gap set-difference is an asset-side check, not a blend-program proof).
- [U7] Field layouts beyond the four bytes `eax+0x130–0x133` and table `0x8fb1ac` in [D4]; no animation-struct offsets recovered.
- Termination rule: each [U] closes only on owner-supervised, zero-mismatch runtime capture (same donor build, same asset set, frame-exact log). Static Decomp alone cannot close them.

## 5. Parity / chain status

- Parity: UNVERIFIED. No parity claim made. No port behaviour wired. No `.bind` unpacking performed.
- Decomp chain: 0/6. RESULT IS NOT GOOD.
- No invented values. No approximations. All addresses/literals above are byte-proven with evidence id + VA; everything else is explicitly [U].
