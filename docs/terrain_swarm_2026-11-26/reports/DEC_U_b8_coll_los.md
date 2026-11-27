---
id: DEC-U-B8-COLL-LOS
worker: "DEC-U-B8-COLL (subagent, full 1:1 Cossacks 3 donor port)"
date: 2026-11-27
role: "B8 class-B task — finish STATIC census/audit: per-sid radius/mask, Rotate/Reflect/tmoRotate, centred origin + inertia, 12-float ctpoEqual/LOS set"
owner_file: docs/terrain_swarm_2026-11-26/reports/DEC_U_b8_coll_los.md
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION__NO_BIND_UNPACKING
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32 x86, 5,768,048 B, sha256 87F0F3C130B027E7C4E72DC217EAE9D592982370D112E0D224897BC92AF4E16C; verified before first finding and re-verified after last pass via core_session_show"
labels: "[O] verbatim byte/text · [D] deterministic reading of [O] · [I] reading without runtime proof · [U] UNVERIFIED with zero-mismatch termination"
parity_status: UNVERIFIED
parity_claim: NONE
visual_parity_claim: false
chain: "0/6 CLOSED; no condition promoted by this worker"
verdict: "RESULT IS NOT GOOD — blocking_unverified non-empty; no donor GPU A/B frame; no approximation; no parity claim"
scope_guard: "Read-only static decompilation only. No source/shader/asset/config/test/fixture/result/Godot/git edit; no donor execution, capture, copy or patch; no .bind unpacking. Exactly one repository file written: this report."
---

# DEC-U-B8-COLL — static census/audit of collision radius, mask, centred origin and the 12-float LOS/ctpo set (2026-11-27)

> **Required reviewer line, verbatim:** PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

## 0. Result in one paragraph

Class-B item **E-COLL / LOS** (`PORT1TO1_u_classify.md:103,201`) is advanced by a **static-only** census pinned to the verified donor. New **byte-proven [D]** results: (i) the `core_feature_find` literal inventory is fully enumerated for the task's literals, including exact addresses and 0-hit negatives with the engine's explicit `no_match`/absence-is-not-proof limitation; (ii) all five collision mask helper bodies are recovered with exact instruction counts, field offsets, bounds tests, centred index arithmetic, complete static caller/callee edges and a paged `core_evidence_browse` read-back, including a **new** fourth helper `sub_7d9694` and a **new** distinction between two distinct record layouts (write path via `+0x4→+0x8→+0xa0/+0xa4/+0xa8`; read/gate path via `+0x4→+0x14→+0x4/+0x8/+0xc` with `+0x65` gate and `+0x1c` occupant id); (iii) the donor text census closes 369/354/15 building masks, 0/140 unit masks, 18 whole-tree `objprop.radius` overrides, **zero** `Rotate`/`Reflect`/`tmoRotate` overrides in all 369 building props with class defaults at exact `path:line`, and **four** previously unrecorded `ctpoEqual`/`ctpoGreater` consumer sites. Nothing was promoted: all per-sid **live** values, all runtime footprint semantics and all LOS math results stay `[U]` with their exact zero-mismatch captures. `parity.claim = NONE`, `parity.status = UNVERIFIED`, six-condition chain `0/6`, **`RESULT IS NOT GOOD`**.

---

## 1. Method and pass ledger

VA convention: addresses quoted are the tool's `0x` VAs. `core_feature_find` searches the built-in engine's **indexed NUL-terminated string / import / discovered-function inventory**; a 0 there is a null result **in that index**, not a proof of byte absence (the tool itself returns `no_match: "nothing matched; the text may be built at run time, encrypted, or come from a resource file (absence is not proof)"`). Delphi length-prefixed CODE registration strings are outside that index; the prior `native_bytes_find` hits for `TraceLineQuadTree`/`GetFOWLOSData`/CODE `ctpoEqual` are **carried evidence from `DEC_U_nb3.md`/`DEC_U_collision_full.md`, not re-proved here**. `native_function_study` was called `detail:"summary"` then `detail:"complete"` for every studied function; big facets were paged with `core_evidence_browse`.

| # | Pass | Evidence / result |
|---|---|---|
| P0 | Pin before any finding; re-pin after last pass | `core_session_show`: target `t_87f0f3c130b0`, PE, 5,768,048 B, sha256 `87f0f3…4e16c`, deep mode. `[O]` |
| P1–P5 | `core_feature_find` on `Rotate`, `Reflect`, `tmoRotate`, `ctpoEqual`, `ctpoGreater`, `ctpo`, `LOS`, `radius`, `mask`, `Collision`, `Inertia`, `XCollision`, `OctreeRayCast`, `RayCast`, `TraceLine`, `GetFOWLOSData`, `SortRayCastList` | 17 evidence ids §2.1–2.2. `[O]`/reported as indexed counts |
| P6 | `native_function_study` summary→complete ×7 | §2.2, 7 evidence ids |
| P7 | `core_evidence_browse` paging ×5 | §2.2, 5 evidence ids; one partial page (`next_offset:60`) |
| P8 | `native_function_study` at `0x6a8412`, `0x84981e`, `0x6a7f5b` | All three refused `function_not_found` — no discovered function at the FOW registration string, the CODE `ctpoEqual` false-positive address or the `TraceLineQuadTree` string address. No evidence id (tool refusal). Blind spot; not an anti-edge `[D]` |
| P9 | Read-only donor text greps (`Get-Content`/`Select-String`) | §2.3, exact `path:line`; shell output only, no evidence id |
| P10 | Read-only repo report reads (`PORT1TO1_u_classify.md`, `DEC_U_nb3.md`, `DEC_U_collision_full.md`, `DEC_U_inertia_rtti.md`) | Prior anchors and zero-mismatch captions carried forward unchanged |

---

## 2. What is byte-proven `[D]` (counts, call edges, field offsets, literal table rows)

### 2.1 Literal table rows — `core_feature_find`, indexed inventory `[O]`

| Literal | Evidence id | Indexed result (exact counts / addresses) |
|---|---|---|
| `Rotate` | `ev_0af219e687cb6e0d4ebf314bec255df0e57a3b9f54555f8bf0c39ef2ab06c996` | 2 strings: `glRotatef` `0x90a94e`, `glRotated` `0x90a95a`; 1 function `glRotatef@thunk` `0x4afde4`; 2 imports `opengl32.dll!glRotatef` slot `0x907c28` (used by that thunk), `glRotated` slot `0x907c2c` (unused). **No collision-mask rotation symbol.** |
| `Reflect` | `ev_acd8eb1b941d87c6d1d51bbc0745b275a16db895b150e4d3446f3e0a2439129a` | 0 strings / 0 function names / 0 imports / 0 functions; `no_match` limitation. |
| `tmoRotate` | `ev_0d0e07c6b74f838a63f30b70b482bea2d139e24dd69f9c110d9b6bda4b030cb3` | 0/0/0/0; `no_match` limitation. |
| `radius` | `ev_80962208bb04bfa65599888f3e8312a22396fb05729f8d65227d0af438ece4b2` | 0/0/0/0; `no_match` limitation. No engine radius symbol is indexed. |
| `mask` | `ev_d7fd3791b6a5a456ad5f9f547f6ad5938e5b9dca785666d0e7197fd009d108e0` | 7 strings: `MaskBlt` `0x908ce2`, `glDepthMask` `0x90adf8`, `glColorMask` `0x90ae60`, **`XCollisionMask` `0x9589c7`**, `DXPatternMask` `0x9593c5`, `Mask` `0x959658`, `5MaskUtils` `0x95965e`; 3 thunks `MaskBlt@thunk 0x408684`, `glColorMask@thunk 0x4afb34`, `glDepthMask@thunk 0x4afb64`; imports slots `0x907594`, `0x907d80`, `0x907d68`. |
| `Collision` | `ev_2daac0e793ee0c0b4ca0ea202144aaf019dbae38719ff7caf4cfb5a65d5e6d7f` | 3 strings, 0 functions, 0 imports: `XCollisionMask 0x9589c7`, `XCollisionTags 0x958a13`, `3XCollisionInertia 0x95972b`. |
| `Inertia` | `ev_80e7c6b0485fa552b2a345c592a3f843be28d81deb9f63dec00152884aee37bf` | 1 string `3XCollisionInertia 0x95972b`, 0 functions, 0 imports. Bare `XCollisionInertia` is not indexed. |
| `XCollision` | `ev_def1845ba450d789e5905ce0aa7b4b28cdc3904c958270d223df4206898add0a` | same 3 strings as `Collision`; 0 functions, 0 imports. |
| `ctpoEqual` | `ev_f2bf23b485652f25a875ff37300e0cc5dcd32a7c5d12d67e464ff4ae51fb6a4d` | 0/0/0/0; `no_match`. |
| `ctpoGreater` | `ev_f5b85f9387709dfd00a382be0bfebbf5ee830d391ef3b330310d827f97eee79f` | 0/0/0/0; `no_match`. |
| `ctpo` | `ev_06e52c538fdf75e1a75da32758efab52faaa35b1a51c54575b76487c9ef1bcd3` | 0/0/0/0; `no_match`. |
| `LOS` | `ev_6b92caf5f208771082eae49d7cf0837a78ad93b8006cdfa24c5235653de4ab9d` | 41 strings, 9 "functions", 10 imports — the 9 function-name hits are `Close*`/`closesocket` thunks (substring `los`), **not** line-of-sight code `[D]`. Relevant strings are Delphi/VCL form names only: `LOSWScene 0x9583f2`, `lOSWBehaviours 0x95923f`, `LOSWMovement 0x9592e5`, `LOSWFullScreenViewer 0x959481`. |
| `OctreeRayCast` | `ev_ed3e0fd0199b18601a5e5bd2122e09d86ea38faa5d2719ecde82ca78c168bcc2` | 0/0/0/0; `no_match`. |
| `RayCast` | `ev_ffccf495980f633925d174a4ad1e53de23cd5ebd02ad23d4ad124e8f3f58f482` | 0/0/0/0; `no_match`. |
| `TraceLine` | `ev_38e20cfa22fd9455c1c14f6495f4e5a42b73093e8aa42527151271fb717ed79a` | 0/0/0/0; `no_match`. |
| `GetFOWLOSData` | `ev_be8575b24af2ca658b9f3c3907485b142a0f9864816c376a39144fee18b08b3e` | 0/0/0/0; `no_match`. |
| `SortRayCastList` | `ev_dcfd60f585b8a4d0aeb0e3fdc23304eafaf03bf556c642594f208c2afb194730` | 0/0/0/0; `no_match`. |

`[D]` from these rows: the only indexed collision class names are the three `.rsrc` strings; there is **no** indexed engine symbol for radius, raycast, LOS routine, ctpo option or mask transform. This is an inventory result under a stated index limitation, never a claim that the engine lacks those facilities at runtime.

### 2.2 Native function census — summary→complete, paged `[D]`

All dossiers carry `confidence:"inferred"` with the engine's stated limitations (`register_level`, `calling_convention_assumed`, `conditions_from_flags`, `pseudo_code_inferred`; `unstructured_flow`/`inline_asm` on the two large dispatchers). Instruction counts, addresses, field offsets and call edges are byte-proven; **pseudo-C names/types are reading aids, not recovered types**.

| Function | Evidence id | Counts `[O]` | Byte-proven structure `[D]` |
|---|---|---|---|
| `sub_755168` `0x755168` | `ev_059c599f83b831f0085079a9b5e4509f71b8dac33b3384c2da0e8373d0b36545` | 62 B, 5 blocks, 27 insns, 2 callers, 1 callee; `ev_10be73e3b5fe3cd2dfa18847715073c26e068431accc2f33007f3ee31adeb786` paged pseudo-C 391 UTF-16 units, `at_end:true` | `mov ebx,[eax+4]` → `mov esi,[ebx+8]`; `edi=[esi+0xa4]`; `sar edi,1; jns; adc edi,0`; `edx+=edi`; `eax=[esi+0xa0]`; `sar eax,1; jns; adc eax,0`; `ecx+=eax`; `call 0x764e04` @`0x75519a`. For a non-negative dimension the `sar/adc` pair is `floor(dim/2) = (dim-1)>>1` — centred write. Callers: `sub_755f30` sites `0x756392`, `0x7563b8`. |
| `sub_764e04` `0x764e04` | `ev_c9de88113d729dabee2d2cef45eea7d1a989e8ffd6bd18c11a805f80dd8a6057`; callers paged `ev_d686542025ce20076344260fdd34adcb2ff412f1769e73da2dde0aafddf966ff` (5/5, `at_end:true`) | 46 B, 6 blocks, 16 insns, **5 callers**, 0 callees | Bounds `0<=edx<[eax+0xa4]`, `0<=ecx<[eax+0xa0]`; `[eax+0xa8]` row-pointer table; row `[eax+edx*4]`; byte store `mov [eax+ecx],dl` @`0x764e2b`. Callers: `sub_73c330` @`0x73d2c5`, `0x73d339`, `0x73d3ee`, `0x73d45b`; `sub_755168` @`0x75519a`. |
| `sub_7550f8` `0x7550f8` | `ev_dec2dad4f32485bcdff983010a0c2760ecd54bfd0d6b568b702609b4fa9585c0` | 111 B, 18 blocks, 52 insns, 4 callers, 0 callees | **Different record**: `[eax+4]`→`[+0x14]`→record; outer dim `[esi+8]`, inner dim `[esi+4]`; centred tests `-(outer>>1) < edx < outer>>1` and `-(inner>>1) < ecx < inner>>1`; `edx+=outer>>1`; row table `[esi+0xc]`; `ecx+=inner>>1`; `[edx+ecx*4]`; occupant read `[eax+0x1c]` @`0x75515d`. Callers: `sub_755f30` @`0x756bae`, `0x756bde`, `0x756c0f`, `0x756c41`. |
| `sub_75505c` `0x75505c` | `ev_242fd29488da35457500c7320cb23501f4757c68d2e35c89705b36201f6db436`; assembly p.40–59 `ev_a5e62b601601314a2dd51fafd8353d3d7f447144e7eba43fda42cfc7dcfd1bd3` (20/68, `next_offset:60`) | 154 B, 20 blocks, 68 insns, 4 callers, 1 callee | Same centred bounds and `[esi+0xc]`/`+0x1c` layout as `sub_7550f8`; byte gate `cmp byte ptr [esi+0x65],0` @`0x7550c0`; if nonzero `call 0x7d9694` @`0x7550d1`; then occupant write `mov [eax+0x1c],edx` @`0x7550eb`. Callers: `sub_755f30` @`0x756bcb`, `0x756bfc`, `0x756c2d`, `0x756c60`. |
| `sub_7d9694` `0x7d9694` **(NEW this pass)** | `ev_e2041ddba658b1e3b2f4cd3e60b474d5b3afcb8702e24765c81e5f9ddbf985f7`; callers `ev_7a5d0ab6480a312ebbec1665bb428202f1c6d6dae8f371c89a13931cf473bd2c` (3/3); flow_effects `ev_69d94a6eb2a99a79402124a6a50c46ef7fc3d90514c4b2edff7cb9c052524e9c` (21/21) | 306 B, 15 blocks, 108 insns, 3 callers, 5 callees | Reads `[ebx+0x68]` 3-stride record list (X at `+0`, byte at `+4`), `[ebx+0xc]` row table, occupant `[eax+0x1c]`, and `[ebx+0x54]` object fields `+0x14`/`+0x28` saved at `0x7d96cc`/`0x7d96d2` and restored at `0x7d97b4`/`0x7d97ba`; calls `sub_406b7c` ×2 (`0x7d96a7`,`0x7d96d8`), `sub_84a7d8` ×2 (`0x7d973e`,`0x7d976f`), `sub_7d98e4` (`0x7d978d`); writes occupant `mov [eax+0x1c],edx` @`0x7d9764` and restores prior occupant @`0x7d97a1`. Callers: `sub_75505c` @`0x7550d1`, `sub_7d77bc` @`0x7d77ee`, `sub_84d080` @`0x84d5d8`. Semantics are `[I]` — no name/type is recovered; the byte-proven fact is the call edge and the field traffic, not a "rotation" or "mirror" claim. |
| `sub_755f30` `0x755f30` | `ev_ed57855c0a723d2bf9995595ceb89e76ef66946ef0ebee56bd6c690a21035a36` (summary only; not fully paged) | 6,751 insns, 234 blocks, 662 callees, 5 callers, 1,066 flow effects; `2802` instructions without a C rule | Byte-proven count only. It is the shared caller of all four centred helpers at the ten sites listed above; no semantic claim is made about this dispatcher. |
| `sub_73c330` `0x73c330` | `ev_5e7424767de8e78d86449ef9d0bed38a04e156644e672340778bf3883f52c10e` (summary only) | 1,456 insns, 208 blocks, 253 callees, 1 caller, 4 unresolved indirect calls | Byte-proven count only; four direct call edges into `sub_764e04` listed above. |

`[D]` boundary: the two record layouts above are byte-distinct; conflating them (as a single "`+0xa8` row table everywhere" reading) would be wrong. The `+0x65` gate and the `sub_7d9694` reassign edge are byte-proven; what the gate means at game level is **not**.

### 2.3 Donor text census — exact `path:line` `[O]`/`[D]`

Paths below are under the read-only `C:\Games\Cossacks 3\data\` tree; shell read-only `Get-Content`/`Select-String`, no donor execution and no copying.

| Item | Exact result |
|---|---|
| Building mask census | `objects/buildings/*.prop` = **369** files; **354** carry own `[*] = <01...>` rows; **15** do not: `algaca, algart, algbar, algbla, algdip, algsta, algtem, misdecor1…misdecor8`. `objects/units/*.prop` = **140** files; **0** carry mask rows. `[O]` count; `[D]` 354+15=369. |
| Rotation / mirror key overrides | **0** of the 369 building props contain any `Rotate =`, `Reflect =` or `tmoRotate =` line. Class defaults: `objects/ref/refbuilding.prop:44 Rotate=0`, `:46 Reflect=False`, `:48 tmoScale=False`, `:49 tmoRotate=False`, `:52 tmoScale=False`, `:53 tmoRotate=False`. For contrast, `objects/ref/refunit.prop:44 Rotate=0`, `:46 TransformMaskOptions`, `:47 tmoScale=False`, `:48 tmoRotate=True`, `:50 TransformChildrenMaskOptions`, `:52 tmoRotate=False`, with `:40 Enabled=False` — the `tmoRotate=True` belongs to a **disabled** unit mask, not a building footprint. `[O]` lines; `[D]` no per-sid building override exists, so every building footprint inherits `Rotate=0`/`Reflect=False`/`tmoRotate=False`. `DefaultRollAngle` (45/135/0 in prior reports) is visual yaw, not a mask-layer key — carry-forward, not re-decided here. |
| Radius constants | `scripts/dmscript.global:665-678`: default 10, horse 15, artillery 15, fishboat 40, ferry 70, yacht 35, yachttur 50, chaika 45, galley 80, frigate 90, xebec 80, battleship 90, formation_default 8, formation_horse 12 (px). Conversions `:170 gc_pixels_to_meter=26.6666666`, `:171 gc_meters_to_tile=2`, `:172 gc_pixels_to_tile=53.3333333`, `:178 gc_collision_size=0.5`. `[O]` exact literal rows; metre conversions remain `[D]` arithmetic, never a live radius. |
| Radius override consumers | Whole-tree `scripts/**` grep for `objprop.radius :=` returns **exactly 18 lines**, all in `scripts/lib/unit.script`: `1323,1421,1547,1667` (horse), `1700,1736,1769,1797,1827` (artillery), `1858` (fishboat), `1876` (yacht), `1907` (yachttur), `1925` (galley), `1962` (frigate), `1992` (xebec), `2002` (battleship), `2016` (chaika), `2036` (ferry). `[O]` — the static half of prior `U12-ships-open` is now closed; no radius constant is invented and no neighbour sid is copied. |
| ctpo set | Definitions `scripts/dmscript.global:94 gc_TestPriorityOption_Water='ctpoEqual'`, `:95 gc_TestPriorityOption_Land='ctpoGreater'`. **Four consumer sites (NEW this pass)**: `scripts/lib/serial.script:247 SetGroupTestPriorityOptionByHandle(grHnd, gc_TestPriorityOption_Land)`; `scripts/lib/squad.script:730 …_Water`, `:735 …_Land`; `scripts/progress/progress.inc/nothing.inc:162 TopologyGetPathExt(quadTree, gc_collisiontag_water, gc_TestPriorityOption_Water)`. Whole-tree grep returns no other read. `[O]` sites and literal values; engine comparison semantics stay `[U]` (§3). |
| 12-float LOS set | `scripts/misc/projectile.inc/nothing.inc:52` declares `var px,py,pz,nx,ny,nz: Float`; `:55` dead `OctreeRayCastIntersectChildren` comment; `:56` live `var rayCast : Boolean = OctreeRayCastIntersect(trgHnd, sx,sy,sz, dx,dy,dz, px,py,pz, nx,ny,nz)` — **handle + 12 floats** (origin/direction/hit/normal); `:59-63` `if rayCast then dst := VectorDistance(sx,sy,sz,px,py,pz); if dst<2`. AABB/toggle sites: `scripts/lib/control.script:184,300`, `scripts/lib/misc.script:2285` (comment), `:2352`, `scripts/lib/player.script:509` (`…Enabled … False`), `scripts/lib/unit.script:11805` (`… True`). `[O]` call shape only; result math stays `[U]` (§3). |
| Inertia text rows | `scripts/dmscript.global:969-974` (`1/1.5/3` mass, `0.16/0.1/0.1` radius). `objects/ref/refunit.prop:100-116` and `objects/ref/refbuilding.prop:102-118` carry identical numerics (`UncollideDelta 0.05`, `CIMass 1`, `CIIntersectRadius 0.16`, `CIMaxDistKoef 2`, `CIDeltaStep 0.005`, `CIRotationSpeed 5`, `CIStuckAngle 5`, `CIEpsilonAngle 4`, `CIEpsilonShift 0.001`, `CIEpsilonMove 0.02`, `CIDistExtPointEpsilon 0.005`, `CIAvoidPointMaxAngle 60`, `CIMaxCollideCounter 7`; units `CIEnabled/CIMovable=True`, buildings `False/False`). Whole-tree grep for the four stand/attack globals returns **only the four definition lines** — zero reads. `[O]`; consumer/solver stays `[U]` (§3). |

---

## 3. What remains `[U]` — nothing promoted; exact zero-mismatch termination

A static literal or a byte-proven field offset is **never** promoted to a live port value. Every row below ends in an owner-authorised capture with `0` mismatches as its sole termination; a metric, a still, a fallback or a port-internal "close" never substitutes.

| `[U]` id | Unresolved question (static evidence already collected) | Exact zero-mismatch termination |
|---|---|---|
| U-B8-LIVE-RADIUS | Live radius used by each sid at a given tick; whether `objprop.radius` (broadphase/separation) and the placement disc read the same value. Text constants and 18 override consumers are `[O]`/`[D]` §2.3; the binding to live engine state is not. | **C-CAP-2**: per ship sid, straight lane past a surveyed 1-cell gap, fixed seed/speed, 3 trials × 9 sids; first-contact vs pass-through frame dumped. Pass = contact order matches `35<40<45<50<70<80<90` px with **0 inversions**; first mismatch stops and is filed. |
| U-B8-LIVE-MASK | Full `(nation,sid)→(w,h,rows[])` live dump plus the 15 mask-less fallback path. Static census 354/369/15 and the sampled verbatim bitmaps are carried `[O]`; the 369-file live dump was **not** performed by this worker. | **C-CAP-1**: flat surveyed cell; place each sid at 4 yaw rotations plus one mask-less sid; dump occupancy in `(w+4)×(h+4)`. Pass = centred `sub_755168` prediction matches **all cells, all placements, 0 mismatched cells** (even-width bias included). |
| U-B8-FOOTPRINT-SEM | Runtime effect of `Rotate=0`/`Reflect=False`/`tmoRotate=False`, of the `[esi+0x65]` gate and of the `sub_7d9694` reassign call; `DefaultRollAngle` visual-yaw vs footprint orientation. Static key census is closed §2.3; runtime transform is not. | Same **C-CAP-1** orientation matrix + a gated-occupancy dump at the same 4 yaws: pass = **0 mismatched cells** across gate-on and gate-off runs; any orientation-dependent difference without a byte-proven rule keeps `[U]`. |
| U-B8-CTPO-SEM | Engine truth table of `ctpoEqual`/`ctpoGreater` and which of the four consumer sites types which call; no engine symbol is indexed (§2.1) and the indexed `ctpo` strings are absent under the stated `no_match` limitation. | **C-CAP-4**: unit behind wall / ridge / open water; call `OctreeRayCastIntersect` and `GetGameObjectRayCastAABBByHandle` pairwise while toggling `SetGameObjectRayCastIntersectEnabledByHandle` and `SetTerrainRayCastPrecison`; log `(hit, px,py,pz, nx,ny,nz)` and the priority option. Pass = typed signature + `ctpoEqual/ctpoGreater` truth table with **0 mismatches** in log ids; any unmatched row keeps `[U]`. |
| U-B8-LOS-MATH | All LOS results: blocker set, hard-block vs height/slope vs topology trace, step count, 12-float output interpretation, `dst<2` meaning. 12-float call shape is `[O]`; no body/loop/step literal is recovered. | **E-OCC** (`DEC_U_nb3.md §4`, carried): fixed camera, `GetFOWLOSData(x,z)` dumps only, one transect at 1.0-unit steps ±(res+8); control then hill / wall / forest interposition. Pass = all three dumps **cell-identical to control with 0 mismatches** (pure radius disc); else fit the rule and require it to predict a second, rotated transect with **0 mismatches**. Any flapping cell keeps `[U]`. |
| U-B8-FOW-EDGE | Byte-proven caller chain from `GetFOWLOSData`/TLOS to `TraceLineQuadTree(Ext)`. This pass: `core_feature_find` 0 hits for both names under the index limitation; `native_function_study` refused all three registration/false-positive addresses (P8). Prior `DEC_U_nb3.md` zero xrefs are carried under a known computed-pointer blind spot. | Only a **code-level cross-reference** resolving the registration table yields a byte-proven edge; runtime side = E-OCC above with **0 mismatched cells** on both transects. String adjacency never closes it. |
| U-B8-INERTIA-SOLVER | Live mass→separation law, stand/attack consumer, RTTI field offsets/count/types, `3` prefix meaning. Text rows `[O]`; four stand/attack globals have zero script reads `[O]`; no engine symbol is indexed. | **S-OFFSETS / S-STAND / S-RADIUS / S-SOLVER** (`DEC_U_inertia_rtti.md §6`, carried): field-name sets identical across 10 units × 2 states; separation-vs-mass law predicted across 3 pairings × 20 trials and 2 geometries × 30 trials with **0 mismatched separations/frames**; order-swap run 10 trials **0 mismatches**. |
| U-B8-RAYCAST-TOGGLE | Effect of the two `SetGameObjectRayCastIntersectEnabledByHandle` sites and `SetTerrainRayCastPrecison(0.0000001)` on the 12-float LOS result. Sites are `[O]`; their runtime state is not. | Fold into **C-CAP-4**: toggle-on/off dump pairs must reproduce the typed truth table with **0 mismatches** across the full matrix; no guessed precision constant is ported. |

Explicit non-inventions by this worker: no per-sid radius value beyond the cited literals; no mask bitmap beyond the cited props; no blocker list (not hills, forests, walls, buildings or units), no slope, no step count, no `prior`/`quadtree` value, no `FOWElevation` effect, no ctpo truth table, no inertia solver curve, no RTTI layout. No `.bind` file was unpacked.

---

## 4. Scope, claim register and verdict

| # | Claim | Label |
|---|---|---|
| 1 | Pin `t_87f0f3c130b0` / sha256 `87f0f3…4e16c` verified before first finding and re-verified after last pass; deep mode, target never opened/closed/select-changed by this worker. | `[O]` P0/P10 |
| 2 | Literal inventory counts and addresses for all 17 queried literals, with `no_match` absence-is-not-proof limits, are exactly as §2.1. | `[O]`/`[D]` 17 ev ids |
| 3 | Five collision helpers plus two dispatchers have byte-proven sizes, instruction/block counts, field offsets and complete static call edges; two distinct record layouts are byte-distinct; `sub_7d9694` is a new gated callee. | `[D]` §2.2, 7 ev ids + 5 browse ids |
| 4 | 369/354/15 building and 140/0 unit mask census; 0 rotation/mirror overrides in the 369; 18 whole-tree radius overrides; 4 ctpo consumer sites; 12-float LOS call shape; inertia text rows and zero stand/attack reads. | `[O]`/`[D]` §2.3 `path:line` |
| 5 | No static literal was promoted to live behaviour; every unresolved item keeps its named zero-mismatch capture; static closure is not value closure. | `[D]` §3 + governing rule `PORT1TO1_u_register_update.md:44-45` |
| 6 | `parity.claim = NONE`; `parity.status = "UNVERIFIED"`; `visual_parity_claim = false`; six-condition chain **0/6**; no donor GPU A/B frame, no harness/gate/replay, no port capture compared. | `[D]` governing parity register |
| 7 | Verdict **`RESULT IS NOT GOOD`** while `blocking_unverified` is non-empty (P0-1…P0-8 plus tails); E-COLL/LOS remains `[U]` after this static pass. | `[D]` `PORT1TO1_u_classify.md:12,28,230` + §3 |

**Scope statement.** Exactly one repository file was written by this worker: `docs/terrain_swarm_2026-11-26/reports/DEC_U_b8_coll_los.md`. No source, shader, asset, config, test, fixture, result JSON, backup, queue, Godot, runner, gate or git state was changed. The donor binary was read as bytes only, pinned, never executed, captured, copied or patched; donor text was read read-only; no `.bind` unpacking; no native craftanything tool other than `native_function_study` was called (all other instrumentation `core_*`/report tools). **Parity UNVERIFIED. No parity claim. `RESULT IS NOT GOOD`.**

*End of DEC-U-B8-COLL-LOS.*
