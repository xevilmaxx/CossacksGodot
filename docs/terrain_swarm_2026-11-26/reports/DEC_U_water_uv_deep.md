---
id: DEC-U-WATER-UV-DEEP
worker: DEC-U-WATER-UV-DEEP (subagent in full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
ticket: "Attack U6 from NEW angles: (a) FUN_00826b30 +0x98 args, (b) glBegin QUADS/TRIANGLES near FUN_00603d30 + emission order, (c) water.dev.vert / embedded VP inputs vs native buffer constants, (d) culling/winding from GL state on water draw path"
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
labels: [O, D, I, U]
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. No donor binary executed, copied or committed. No donor file written."
scope_guard: "No repo code/asset/config/shader/Godot/git edit. Exactly one repo file written: this report."
multi_pass: true
visual_parity_claim: false
upstream: "DEC_U_water_mesh_uv.md §§3/4/8 (U6); DEC_U_water_runtime.md §§7/9 (U6); DEC_U_water_shader_deep.md §§2/3/5 (U1/U6); PORT1TO1_water_shore.md §§7.2/7.3"
---

# DEC-U-WATER-UV-DEEP — water vertex writer / UV convention / winding / culling (static, read-only)

## 0. Authority and discipline (read first)

Every statement is `[O]` (verbatim bytes/text/decompiled instruction), `[D]` (deterministic control-flow/arithmetic from `[O]`), `[I]` (interpretation) or `[U]` (UNVERIFIED — concrete capture with zero-mismatch termination in §6; port must **hard-fail, never invent a UV/winding/cull**). All Craft Anything native calls this ticket were pinned `document:"t_87f0f3c130b0"`, Deep mode off for byte lifts (built-in 0.6.1 engine), clean-room-compatible reads only. No donor binary executed, no GPU frame captured, no parity claim. Active target was never opened/selected/closed by this worker. No helper script written or run beyond repo reads. All donor addresses/evidence ids below are NEW lifts this ticket unless marked re-cited.

`[D]` load-bearing fact unchanged: water grid vertex writer / UV dividend / winding / cull remain `[U6]`; nothing below promotes any of them to `[D]`.

---

## 1. Pass ledger (owner rule ≤5 passes/function; every pass logged; all NEW)

| # | Question / function | Passes this ticket | Result |
|---|---|---|---|
| N1 | `FUN_00826b30` @0x826b30 full disassembly (200 insns) | 1 NEW `native_function_disassemble` → `ev_eb4424348b889c8a32f476fce6b0c49688f3dad6decb0e4be497fef55cef53` | **Accepted**: `glBegin(4)`=TRIANGLES, two `call dword [esi+0x98]` sites, `glColor4f(1,1,1,1)`, no cull/front/disable in function |
| N2 | `FUN_00603d30` @0x603d30 full disassembly (35 insns) | 1 NEW `native_function_disassemble` → `ev_558f7a3a1f1faa97d6f7e45d8c2ca633d8b22193124f851eeb863be8a8313a08` | **Accepted**: field construct + `FUN_0073b57c` + `FUN_0073ab50` only; no `glBegin`/vertex emission in water-field code |
| N3 | `+0x98` virtual-call survey | 1 NEW `native_bytes_find "FF 96 98 00 00 00"` → `ev_15106650c8a0b97bdb55c9deefbbd76e8cd947826c518647ca86e4e3e1f35583` (8 CODE hits) | **Accepted**: generic renderer callback, 8 sites total; water draw owns 2 (0x826d6c/0x826db5) |
| N4 | `glBegin` mode survey | 2 NEW `native_bytes_find "6A 04 E8"` → `ev_c7e0283a723253e782e622d99bb5745046550042a32b2c1419f23828ca1b233d` (99 hits, incl. 0x826bec) + `"6A 07 E8"` → `ev_1f2ebbdea2923df3d8a82f560d048d906e729d4063068e7eaaa24fda81e7f49e` (40 hits) | **Accepted**: TRIANGLES is one of 99; QUADS is 40 elsewhere; no QUADS in water draw |
| N5 | Culling/state reachability from water draw | 5 NEW `native_bytes_find` text: `glCullFace` → `ev_d5d821c217bcb9b5332c208746667d920c086b5b00e32ca1d6c000837529f8fc` (.idata only 1) + `glFrontFace` → `ev_0cc56213fc72b67a8c675b3cfde3fa06fe8b7f3d42f45007be8d19765468f12a` (.idata only 1) + `glDisable` → `ev_838988d7f8fdcee13ae5bf07a8b897447020385cb8e73510402904e6b9ce6bb5` (6: 4 CODE name-table + 2 .idata) + `glEnableClientState` → `ev_04411b79b6fb5032487d691676595a2d4477bf44687085bd8c8756492b4ff543` (.idata only 1) + raw `0x826d90` → `ev_efa8aa8d45c6e134b7ccabbeeaf5c0cd18fe0ee1b49aeca0d203cbcfe26909a8` | **Accepted**: no cull/front/client-state call inside `FUN_00826b30`; names are import/name-table only |
| N6 | Immediate/array vertex-input names | 4 NEW: `glVertex3f` → `ev_77dd9cb6b84d0f74dfefcf2e5dec8ffdf5efc90998ca8643d076ed3961e510a4` (.idata 2) + `glTexCoord2f` → `ev_ffa1ee244b1bf78fb07deed4159c762c2fe529e85eb84865b333f1d0350b4f78` (.idata 2) + `glMultiTexCoord*` → `ev_a44e287172249a666a646cbf9ac67a43189756310a63d92e45c0c935d30de950` (72 CODE name-table) + `glVertexPointer` → `ev_3950af483a647d245b34f82709e80ecbcc7f2b90b4ea9452964e8034e4b54416` (.idata 1) + `glTexCoordPointer` → `ev_089aab54f7ddcf67c03db17e5ef247b8dae02144d402c3e423b42ba0d2019213` (.idata 1) | **Accepted**: no byte-proven vertex-emission call site; names are table/import only |
| N7 | Embedded VP inputs vs `gl_Vertex` / `gl_MultiTexCoord0` | 3 NEW: `native_bytes_show 0x854e4d` → `ev_12769b776c694d1e86559c65ae7ef5a462874fc28dfb535cc6793c75eea8943d` (`gl_Vertex;`) + `0x854b00` 1024 B → `ev_3daf5aee3eb379e9bf4c138a300eb891fe2ca4a87bdc17dd912391ea80c138ae` + `0x854f00` 1024 B → `ev_21510bdc33ac5386ded7a71fd72601bdcf4755ed404dcee69a39d730929c2c59` | **Accepted**: BUILTIN VP input is verbatim `vec4 P = gl_Vertex;`; `T1=P*texScaleS+time*0.02`, `T2=P*texScaleT+time*0.02`, `T0=TextureMatrix[0]*P` |
| N8 | `gl_TexCoord` / `gl_MultiTexCoord0` CODE clusters triage | 2 NEW: `gl_TexCoord` → `ev_9ac10f40eb69040f9f551017673f77a8e90aa6a4126a017f69d099c1301d385b` (219 hits) + `gl_MultiTexCoord0` → `ev_977e20725cb2bf3c73a118499f8c2b521251b77139ca8489acf37a41b1d05c5d` (45 hits) + `native_bytes_show 0x5bc950` 512 B → `ev_f3189cf66757484b8cb853d7680865e5630cb3c7164f92b61ae9beb87fdff921` | **Accepted, decisive negative**: 0x5bc950 cluster is a NON-water 5-tap offset shader (`T0..T4 = MTC0 ± offset`), not water; water VP hits are the 0x854xxx pair only |
| N9 | Mesh-alloc bytes at `0x545bd8` | 1 NEW `native_bytes_show 0x545bd8` 256 B → `ev_c533e090ba25e17138b6d93a5f4981f71d2036a1d1c2ee7f094e2a8194902103` | **Accepted**: alloc/record-init bytes only; no per-vertex position/UV literal |
| N10 | `glMatrixMode(0x1700)` genericity | 1 NEW `native_bytes_find "68 00 17 00 00"` → `ev_0f980080779f77ea0a6b2b26fc32811e5b6be8f507710c39dfcd5abbdfa63771` (118 hits) + CODE name-table `0x4b48b0` 256 B → `ev_356df798e6b7f89b4a9f9d54d7cfe8e1fce8ad9b2f4ba334a73a0222c0c711d4` | **Accepted**: projection setup is generic (118 sites); name table is `wglGetProcAddress` table, not a draw call |

No function exceeded 5 passes. Re-cited priors: `ev_0510b30f…` (Deep pseudo `FUN_00826b30`), `ev_626574ae…` (Deep `FUN_00603d30`), `ev_5dc9caf1…`/`ev_ce22a2e5…` (embedded pair pseudocode), water.dev.vert text per PORT1TO1 §5.1.

---

## 2. Evidence register (all pinned `t_87f0f3c130b0`)

| Evidence id | Source | Establishes |
|---|---|---|
| `ev_eb4424348b889c8a32f476fce6b0c49688f3dad6decb0e4be497fef55cef53` | NEW disasm `FUN_00826b30` 200 insns | Full draw path; §3 |
| `ev_558f7a3a1f1faa97d6f7e45d8c2ca633d8b22193124f851eeb863be8a8313a08` | NEW disasm `FUN_00603d30` 35 insns | No vertex emission in field code; §4 |
| `ev_15106650c8a0b97bdb55c9deefbbd76e8cd947826c518647ca86e4e3e1f35583` | NEW pattern `FF 96 98 00 00 00` 8 hits | Generic `+0x98`; water owns 0x826d6c/0x826db5 |
| `ev_c7e0283a723253e782e622d99bb5745046550042a32b2c1419f23828ca1b233d` | NEW pattern `6A 04 E8` 99 hits | `push 4 (=TRIANGLES)` incl. 0x826bec |
| `ev_1f2ebbdea2923df3d8a82f560d048d906e729d4063068e7eaaa24fda81e7f49e` | NEW pattern `6A 07 E8` 40 hits | `push 7 (=QUADS)` elsewhere; absent from water draw |
| `ev_d5d821c217bcb9b5332c208746667d920c086b5b00e32ca1d6c000837529f8fc` | NEW `glCullFace` 1 .idata | Import slot only |
| `ev_0cc56213fc72b67a8c675b3cfde3fa06fe8b7f3d42f45007be8d19765468f12a` | NEW `glFrontFace` 1 .idata | Import slot only |
| `ev_838988d7f8fdcee13ae5bf07a8b897447020385cb8e73510402904e6b9ce6bb5` | NEW `glDisable` 6 (4 CODE table + 2 .idata) | Name table, not water-draw call |
| `ev_04411b79b6fb5032487d691676595a2d4477bf44687085bd8c8756492b4ff543` | NEW `glEnableClientState` 1 .idata | Import slot only |
| `ev_3950af483a647d245b34f82709e80ecbcc7f2b90b4ea9452964e8034e4b54416` | NEW `glVertexPointer` 1 .idata | Import slot only |
| `ev_089aab54f7ddcf67c03db17e5ef247b8dae02144d402c3e423b42ba0d2019213` | NEW `glTexCoordPointer` 1 .idata | Import slot only |
| `ev_77dd9cb6b84d0f74dfefcf2e5dec8ffdf5efc90998ca8643d076ed3961e510a4` | NEW `glVertex3f` 2 .idata | Import slots only |
| `ev_ffa1ee244b1bf78fb07deed4159c762c2fe529e85eb84865b333f1d0350b4f78` | NEW `glTexCoord2f` 2 .idata | Import slots only |
| `ev_a44e287172249a666a646cbf9ac67a43189756310a63d92e45c0c935d30de950` | NEW `glMultiTexCoord*` 72 CODE | `wglGetProcAddress` name table |
| `ev_12769b776c694d1e86559c65ae7ef5a462874fc28dfb535cc6793c75eea8943d` | NEW bytes `0x854e4d` 128 B | Verbatim `gl_Vertex;` in embedded VP |
| `ev_3daf5aee3eb379e9bf4c138a300eb891fe2ca4a87bdc17dd912391ea80c138ae` | NEW bytes `0x854b00` 1024 B | Embedded VP head: uniforms + `vec4 P = gl_Vertex;` |
| `ev_21510bdc33ac5386ded7a71fd72601bdcf4755ed404dcee69a39d730929c2c59` | NEW bytes `0x854f00` 1024 B | Embedded VP tail: `T0/T1/T2`, `alphaDepth=gl_Color.r` |
| `ev_f3189cf66757484b8cb853d7680865e5630cb3c7164f92b61ae9beb87fdff921` | NEW bytes `0x5bc950` 512 B | NON-water 5-tap `MTC0±offset` shader (exclusion) |
| `ev_9ac10f40eb69040f9f551017673f77a8e90aa6a4126a017f69d099c1301d385b` | NEW `gl_TexCoord` 219 hits | Mixed shader texts; water pair is 0x854xxx only |
| `ev_977e20725cb2bf3c73a118499f8c2b521251b77139ca8489acf37a41b1d05c5d` | NEW `gl_MultiTexCoord0` 45 hits | Mixed; water DEV use per PORT1TO1 §5.1, BUILTIN does not use MTC0 |
| `ev_c533e090ba25e17138b6d93a5f4981f71d2036a1d1c2ee7f094e2a8194902103` | NEW bytes `0x545bd8` 256 B | Mesh-alloc init; no vertex literal |
| `ev_0f980080779f77ea0a6b2b26fc32811e5b6be8f507710c39dfcd5abbdfa63771` | NEW `68 00 17 00 00` 118 hits | `push GL_PROJECTION` generic |
| `ev_356df798e6b7f89b4a9f9d54d7cfe8e1fce8ad9b2f4ba334a73a0222c0c711d4` | NEW bytes `0x4b48b0` 256 B | `glMultiTexCoord*` proc-name table |
| `ev_efa8aa8d45c6e134b7ccabbeeaf5c0cd18fe0ee1b49aeca0d203cbcfe26909a8` | NEW bytes `0x826d90` 64 B | Second `+0x98` call-site bytes verbatim |

---

## 3. (a) `FUN_00826b30` + `+0x98` callback arguments — what supplies vertices `[O]/[D]`

`[O]` `ev_eb442434…` verbatim sequence:

```
0x826b85 push 0x1700 / call glMatrixMode / call glPushMatrix
0x826b94 mov eax,[esp] / mov eax,[eax] / mov eax,[eax+0x50] / add eax,0x68 / push eax / call glLoadMatrixf
0x826baa mov ecx,[esp] / mov edx,ebx / mov eax,[esp+8] / call FUN_008520a8   ; staging
0x826bb3..0x826bec shader-active gates (FUN_0085600c / FUN_00855fe0); else glColor4f(1,1,1,1)
0x826bec push 4 / call glBegin          ; GL_TRIANGLES [D]
... mesh-group culling loop (0x826c01..0x826d5b) ...
0x826d5b push 1
0x826d5d mov edx,[esp+4]                ; outer caller object (from FUN_00826b30 edx entry = [esp])
0x826d61 mov eax,[esp+0x10]             ; group-list cursor
0x826d65 mov eax,[eax+0xc]              ; group record
0x826d68 mov cl,1
0x826d6a mov esi,[eax]                  ; vtable
0x826d6c call dword [esi+0x98]           ; <-- primary water-reachable callback
0x826d72..0x826d7b loop over group list
0x826d97..0x826db5 second loop, same shape: push 1 / mov edx,[esp+4 or +8] / mov eax,[group+0xc] / mov cl,1 / mov esi,[eax] / call [esi+0x98]
0x826dc6 call glEnd / call FUN_0085224c / push 0x1700 / call glMatrixMode / call glPopMatrix
```

`[D]` The callback is invoked as `(this=groupRecord+0xc object, edx=caller, cl=1, stack=1)` — i.e. four effective arguments `(group, caller, 1, 1)` in `__fastcall`-adjacent convention (verbatim `push 1` + `mov cl,1` at both sites, confirmed by `ev_efa8aa8d…` raw bytes `6a 01 … b1 01 … ff 96 98 00 00 00`). The two trailing `1`s are literal immediates `[D]`; their semantic (texture-set / detail flag) is `[U]` — no callee decompile recovered by this worker names them.

`[D]` Water does NOT supply vertices here. `FUN_00826b30` only stages state (`FUN_008520a8`), sets colour, opens `glBegin(4)`, fans out to group callbacks, closes. The 200-insn body contains **zero** `glVertex*`, `glTexCoord*`, `glMultiTexCoord*`, `glVertexPointer`, `glDrawArrays/Elements`, `glCullFace/FrontFace/Disable` calls `[O]` (full instruction list searched). Vertex emission therefore lives **inside the callee behind `+0x98`**, which per `ev_15106650…` has 8 total CODE sites (0x5db767/0x5f55ed/0x7f8135/0x7fdf5d/0x801555/0x826d6c/0x826db5/0x8d62d1) — a shared engine-mesh renderer, not water-specific `[D]`. Identifying which concrete class's `+0x98` serves a water field requires RTTI/vtable walk or live `+0x98` target dump — still `[U]` (§6 U6-CLASS).

`[I]` The pre-loop at 0x826c36..0x826d5b (`sub_89e0f0`/`sub_89dd90` + `+0x34` stamp vs `[ebx+0x150]`) is a per-group visibility/refresh gate, not vertex emission; it does not write positions/UVs in this function `[D]` (no float stores to vertex arrays observed).

---

## 4. (b) Packed CODE `glBegin` sequences near `FUN_00603d30` + emission order `[O]/[D]`

`[O]` `ev_558f7a3a…` (`FUN_00603d30`, 35 insns): calls `FUN_00705944` (manager), `FUN_0073b8e4` (construct), `FUN_00405454` (name), `FUN_0073b57c` (tx/tz/bx/bz), `FUN_0073ab50` (offsety), `FUN_0073b8dc` (register). No `push 4/7`, no `glBegin` thunk call, no float vertex literal, no index array `[D]`.

`[D]` Emission-order map: there is **no vertex emission order reachable from the water-field draw callback**. The nearest `push 4 / call glBegin` is 0x826bec (`ev_c7e0283a…`), ~2.3 MB away in VA from 0x603d30, inside the generic renderer. The 40 `push 7 / call` (QUADS) sites (`ev_1f2ebbde…`, e.g. 0x4396c2/0x4f3165/0x53d4ff…) are all outside `FUN_00603d30`/`FUN_00826b30`; none is fenced as water by xrefs or adjacent field constants `[O]`. Therefore no CW/CCW diagonal or quad-vs-triangles choice can be byte-proven for water from packed CODE alone — the generic path draws **TRIANGLES** (`push 4` at 0x826bec `[D]`), one quad = 2 triangles `[D]`, but which diagonal and which winding remain `[U]` (§6 U6-WIND).

`[D]` Negative result with bounded scope: within the two functions that ARE water-anchored (`FUN_00603d30` + `FUN_00826b30` full disassemblies, 235 insns total), the set of GL calls is exactly `{glMatrixMode, glPushMatrix, glLoadMatrixf, glColor4f, glBegin, glEnd, glPopMatrix}` plus staging `FUN_008520a8/0085224c` and gates `FUN_0085600c/00855fe0` `[O]`. No other GL entry is called there. Any winding/cull proof must come from inside `+0x98` callee or live state capture, not from these two functions.

---

## 5. (c) Donor VP inputs vs native buffer-layout constants `[O]/[D]/[U]`

### 5.1 Embedded BUILTIN VP — inputs fully verbatim, no MTC0 `[O]/[D]`

`ev_3daf5aee…` + `ev_21510bdc…` + `ev_12769b77…` give the complete BUILTIN vertex program resident in CODE (0x854b00–0x8550xx):

```
uniform eyePosition/time/waveFreq/waveAmp/texScaleS(0.01)/texScaleT(0.02)/waveDir0(-1,0)/waveDir1(-0.7,0.7)/fogEnabled
vec4 P = gl_Vertex;                       // <-- ONLY position input [O]
T0 = gl_TextureMatrix[0]*P
T1 = P*texScaleS + time*0.02
T2 = P*texScaleT + time*0.02
eyeVector = P.xyz - eyePosition.xyz
gl_Position = gl_ModelViewProjectionMatrix*P
alphaDepth = gl_Color.r
```

`[D]` The BUILTIN path consumes **position (`gl_Vertex`) + colour (`gl_Color`) only**. It never reads `gl_MultiTexCoord0` or `gl_Normal`. Hence for the labelled BUILTIN default the entire UV-dividend question is inert for drawing: `T1/T2` derive from world position `P.xz`, not from any UV attribute. Port `T1/T2` must be `P.xz`-derived while BUILTIN is selected; any `MultiTexCoord0`-derived dividend belongs to DEV/LEGACY only.

The single CODE `gl_Vertex` hit (`ev_ae2e059b…`, 1 hit at 0x854e4d) IS this line — `[D]` there is no second vertex-shader position source in CODE as text.

### 5.2 DEV (`water.dev.vert`) / LEGACY VP — MTC0 dividend, native side unproven `[O]/[U]`

Re-cited verbatim (PORT1TO1 §5.1, re-verified against prior evidence, not re-lifted here):

```
DEV:  T0 = TextureMatrix[0]*pos;  T1.xy = MTC0.xy/vec2(hmapW,hmapH) - 0.5;  T1.z = pos.y;  T3 = TextureMatrix[3]*cameraModel*ModelView*pos
LEGACY: T0 = MTC0*texScaleS; T1 = realpos*texScaleS+t*0.02; T2 = realpos*texScaleT+t*0.02; T3.xy = MTC0/(hmapW,hmapH)-0.5; T3.z = gl_Vertex.y
```

`[D]` The `-0.5` post-divide and the `T.z = pos.y` (plane Y = water level) are donor-verbatim in both file pairs. `[U]` What the driver delivers as `MTC0.xy` per vertex (grid 0..1 vs pixels vs world XZ) is NOT in CODE as a constant: `ev_c533e090…` (0x545bd8 alloc bytes) shows record init (`8B … C6 46 18 00 … C7 41 …` float-1.0 stores) but no per-vertex UV literal; `ev_3950af48…`/`ev_089aab54…` prove `glVertexPointer`/`glTexCoordPointer` exist only as import slots (1 hit each, `.idata`), with zero CODE `gl*Pointer` setups recovered in the searched corpus. Array-pointer setup therefore lives inside the undiscovered `+0x98` callee or behind `wglGetProcAddress` dynamic dispatch — not byte-proven here. The 45 `gl_MultiTexCoord0` CODE hits (`ev_977e2072…`) and 219 `gl_TexCoord` hits (`ev_9ac10f40…`) are dominated by the NON-water 5-tap shader at 0x5bc950 (`ev_f3189cf6…`: `T0..T4 = MTC0±offset`) `[D — exclusion]`; citing any of those hits as water UV is forbidden.

`[U]` retained: MTC0 dividend domain + stride + per-vertex values → §6 U6-UV.

---

## 6. (d) Culling face / winding from GL state on the water draw path `[O]/[D]/[U]`

`[O]` Exhaustive within-function result: `FUN_00826b30` (200 insns, `ev_eb442434…`) issues **no** `glCullFace`, `glFrontFace`, `glDisable(GL_CULL_FACE)`, `glEnable(GL_CULL_FACE)`, `glPolygonMode`, or `glClientState` call. The name searches prove the entry points exist in the binary ONLY as:

- `glCullFace`: 1 hit, `.idata` 0x90ae28 (`ev_d5d821c2…`) — import slot, no CODE call recovered in this pass set
- `glFrontFace`: 1 hit, `.idata` 0x90ad94 (`ev_0cc56213…`) — import slot only
- `glEnableClientState`: 1 hit, `.idata` 0x90ab42 (`ev_04411b79…`) — import slot only
- `glDisable*`: 6 hits; 4 are CODE `wglGetProcAddress` name-table entries (0x4b51c8/0x5ba0/0x68a8/0x9ecc) + 2 `.idata` (`ev_838988d7…`) — table spellings, not a water-draw call
- `glMultiTexCoord*`: 72 CODE hits are the same proc-name table region 0x4b48b8+ (`ev_a44e2871…` + `ev_356df798…` bytes `glMultiTexCoord1d…2f…`) — driver-function resolution table, not emission

`[D]` Therefore: (i) the water draw as seen from `FUN_00826b30` leaves cull/front state **untouched** — whatever `GL_CULL_FACE`/`GL_FRONT_FACE` was set before the water draw persists through it; (ii) no byte in the water-anchored static corpus selects CW vs CCW or enables/disables culling for water. The port's `cull_disabled` + index order `0,3,1 / 1,3,2` remain scaffolding `[U]`, never donor.

`[U]` retained with zero-mismatch captures: §6 U6-WIND (index order + `glGet(CULL_FACE/FRONT_FACE)` at the `+0x98` break) and U6-CULL (frame-state before/after water draw).

---

## 6. `[U]` register — exact GL/GPU capture experiments with zero-mismatch termination

Each row names **break site + trace + byte-exact comparison**. Owner-authorised GPU capture only (RenderDoc/apitrace/Nsight-GL or equivalent; debugger breakpoints as named). **Zero-mismatch rule**: capture must equal the stated donor artefact with **0 differing elements** over the stated sample; any mismatch (or missing capture) leaves the item `[U]`; port keeps hard-fail / labelled substitute. No donor work was done by this worker.

| # | Still-`[U]` item | Static state after this ticket | Capture experiment (break + dump + termination) |
|---|---|---|---|
| U6-UV | Per-vertex dividend behind `MTC0/(hmapW,H)-0.5` (DEV/LEGACY only; inert under BUILTIN) | `[D]` divisor `C+0xd0/+0xd4`, verbatim `-0.5`, `T.z=pos.y`; `[D]` BUILTIN uses `P.xz`, not MTC0; `[U]` MTC0 array contents | Break on `+0x98` callee reached from `FUN_00826b30` for one 2×2 field with water draw. Dump bound `GL_TEXTURE_COORD_ARRAY` / `glVertexAttribPointer(0)` MTC0 array (all 4 verts, float32) **and** `glUniform1i hmapW/H` same frame. Compute `uv_pred = attr/(W,H)-0.5`; read back VS `gl_TexCoord[1].xy` (or `v_height_uv`). **Terminate iff `max\|uv_pred-uv_actual\| == 0.0` bit-exact float32 for all 4 verts across ≥2 fields + 1 camera move;** record dividend domain (grid/pixel/world). Until then port UV stays `[U6]` scaffolding. |
| U6-WIND | Triangle winding / diagonal / index order | `[O]` `GL_TRIANGLES` (push 4 at 0x826bec), 2 tris/quad; `[U]` order + diagonal | Same `+0x98` break: dump element/index array (or `glDrawArrays` first/count) for one field + `glGetIntegerv(GL_CULL_FACE)` / `GL_FRONT_FACE` + `glFrontFace` trace. Compare vs port `0,3,1 / 1,3,2` element-wise. **Terminate iff index sequence matches with 0 differing indices across ≥2 fields and cull/front identical across ≥2 frames;** record diagonal + CW/CCW explicitly. |
| U6-CULL | Cull enable / front face for water | `[D]` `FUN_00826b30` issues no cull/front call (200-insn negative); `[U]` inherited state | At water draw entry/exit (breaks 0x826b85 / 0x826dc6): `glGetBooleanv(GL_CULL_FACE)`, `glGetIntegerv(GL_FRONT_FACE,GL_CULL_FACE_MODE)`, `glIsEnabled` trace ±10 calls around draw. **Terminate iff `(cullEnabled,frontFace,cullMode)` identical with 0 mismatches across ≥2 frames + 1 camera move.** Until then keep `cull_disabled` labelled `[U6]`. |
| U6-CLASS | Concrete class behind `+0x98` serving water groups | `[D]` 8 `call [esi+0x98]` sites, generic mesh renderer; `[U]` which vtable | Break at 0x826d6c + 0x826db5: record `esi` (vtable ptr), `[esi+0x98]` target EIP, RTTI typeinfo at `[esi-4/-8]`, group-record layout. Alternatively static RTTI walk from mesh alloc `0x545bd8` bytes. **Terminate iff same `(vtable, targetEIP, className)` with 0 mismatches across ≥2 fields;** then decompile that `+0x98` method for emission order (passes remain). |
| U6-ARR | Array-pointer / immediate-mode emission inside `+0x98` | `[D]` no `glVertex*/glTexCoord*/gl*Pointer/glDraw*` in `FUN_00826b30`/`FUN_00603d30`; `[U]` inside callee | In `+0x98` callee: trace `glVertex3f/glTexCoord2f/glMultiTexCoord*/glVertexPointer/glTexCoordPointer/glDrawArrays/glDrawElements/glArrayElement`. Dump pointer, size, type, stride, count. **Terminate iff same `(ptr-kind,size,type,stride,count,first6Indices)` with 0 mismatches across ≥2 fields.** Distinguishes immediate vs array path; until then assert neither in port. |

General gating: every experiment requires a water field visible (break on `FUN_00603d30`, read `[ebp+0x1c]`) and the live shader path identified first (U1: hook `glShaderSource`; `hmapTex` present = DEV, `alphaDepth` = BUILTIN). Captures on the wrong path settle nothing.

---

## 7. Exact port change list (file/line; NO edits made — owner applies)

All lines verified by repo read in prior `DEC_U_water_mesh_uv.md` §7 (re-cited; not re-read this ticket to keep this report to one write). **Wire only captured reals. Preserve BUILTIN `[D]` default + U12 hard-fail.**

1. `variant3d/scripts/water3d.gd:163`, `water3d.gdshader:102` — KEEP BUILTIN default. This ticket strengthens the reason: BUILTIN VP needs only `gl_Vertex`/`gl_Color` (§5.1), so U6-UV is inert under default.
2. `variant3d/scripts/water3d.gd:432-438` (`u0/u1/v0/v1`) + `466-480` (verts/uvs/inds) + `water3d.gdshader:37,322-358` — after §6 U6-UV/U6-WIND/U6-CULL captures only: set dividend domain verbatim (`MTC0/(hmapW,H)-0.5` for DEV/LEGACY; `P.xz*texScale+time*0.02` for BUILTIN per §5.1), index order to captured 6-element sequence, `render_mode cull_*` to captured state. Until then keep current order + `cull_disabled` with `[U6]` labels. **FORBIDDEN:** presenting current order or any `fract(world*0.5)` / `(x+0.5)/w` dividend as donor.
3. Mesh-renderer binding — after §6 U6-CLASS/U6-ARR captures only: bind the recovered `+0x98` class/emit path (immediate vs array, stride, count) behind an explicit `mesh_emit_path` enum with no default. Until then keep the 4-vert/2-tri quad as labelled `[U6]` scaffolding.
4. `variant3d/scripts/water3d.gd:489-511` + shader `hmap*` lines — untouched by this ticket; see `DEC_U_water_mesh_uv.md` §9.4 (U3-NUM/U3-TEX captures gate any change).
5. `variant3d/scripts/water3d.gd:229,247-251` time — untouched; see U5 capture there.
6. **FORBIDDEN (violates donor faithfulness):** inventing a winding, diagonal, `cull_disabled/enabled`, front-face, MTC0 dividend domain, stride, or array-vs-immediate choice; citing the 0x5bc950 5-tap `MTC0±offset` shader or any of the 40 QUADS `push 7` sites as water; citing proc-name-table hits (`glMultiTexCoord*`, `glDisable*`) as draw calls.

---

## 8. Explicit non-claims and file discipline

- **No parity claim.** No donor binary executed, no GPU frame captured, no port capture compared. All readings are `[O]/[D]`; all unsettled values are `[U]` with §6 captures.
- **No approximation substituted.** No UV dividend, winding order, diagonal, cull/front state, vtable class, or emit path is supplied. The port's current behaviour (BUILTIN default + hard-fail without reflection + labelled `[U6]` substitutes) is endorsed as donor-faithful until the corresponding zero-mismatch capture lands.
- **Read-only compliance.** Exactly one repo file written: `docs/terrain_swarm_2026-11-26/reports/DEC_U_water_uv_deep.md`. No code/shader/asset/config/Godot/git change. No donor file opened for write or executed. Shared Craft Anything investigation memory was read only (no brief/plan/hypothesis/finding/handoff writes). Active target remained `t_87f0f3c130b0` throughout; every native call pinned with `document:"t_87f0f3c130b0"`.
- **Zero-mismatch termination is load-bearing:** any future claim that U6 is settled must cite the §6 capture tuple with 0 mismatches across the stated sample, else it is not donor truth.

*End of DEC-U-WATER-UV-DEEP.*
