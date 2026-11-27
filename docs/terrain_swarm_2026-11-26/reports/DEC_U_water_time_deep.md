---
id: DEC-U-WATER-TIME-DEEP
worker: DEC-U-WATER-TIME-DEEP (subagent, full 1:1 Cossacks 3 donor port)
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
labels: [O, D, I, U]
scope: "One file only. Read-only. No donor execution, no parity claim."
upstream: "DEC_U_water_runtime.md §5.3; DEC_U_water_lib_params.md §5; DEC_U_water_shader_deep.md §5-U5"
---

# DEC-U-WATER-TIME-DEEP — U5 from four new angles (2026-11-26)

Prior: time law `(float)(double[C+0xc8]*double[C+0xc4])` at `0x854091`, `Speed=1.0`, writer of `C+0xc8` not found; port `_time += delta` scaffold labelled `[U5]`.
This ticket attacks U5 from four NEW static angles. **Nothing below promotes any time source to `[D]` without byte proof. U5 stays `[U]`.**

## 1. Method `[O]`

Pinned `t_87f0f3c130b0`, Deep mode, built-in 0.6.1 engine for bytes/xrefs (`core_session_show` active target `t_87f0f3c130b0`; prior Deep Ghidra pseudocode re-cited, not re-lifted — built-in reports `function_not_found` for water addresses, which is itself evidence below).
Read-only: `native_bytes_find` (text + LE patterns), `native_bytes_show` (absolute reads), `native_xrefs_list`, `native_function_find`, `native_address_show`. No donor binary executed, copied, or written. No repo code/shader/config/Godot/git change; exactly one file written (this report).

Pass ledger (owner rule ≤5 passes/function; every pass logged):

| # | Angle | Calls (new, this ticket) | Accepted? |
|---|---|---|---|
| P-a1 | raw `fld/fmul/fstp` sequence at `0x854091` | `DD 86 C8 00 00 00` → 1 hit; `D8 8E C4 00 00 00` → 1 hit; 64 B + 720 B dumps | **Accepted** — reader unique |
| P-a2 | xrefs from containing addr / binder base | `xrefs(0x854054)`, `xrefs(0x854091)`, `address_show`, `function_find` ×3 | **Accepted** — built-in DB empty / undiscovered |
| P-b1 | ctor `0x856080` layout + zeroing of `+0xc8` | 512 B + 200 B dumps | **Accepted** — zero proven |
| P-b2 | all `DD ?? C8 00 00 00` / `DC ??` / `D9 ??` + writer shapes `DD 9B/DD 98` / `C7 ?? C8` | 21 + 5 + 40 hits, paged; contexts at `0x50aee2/0x50af19/0x50afae/0x50b243/0x50b255/0x856cea/0x856d9f` | **Accepted** — candidates enumerated, ownership unproven |
| P-c | frame-delta literals + `DeltaTime/FrameTime` | `89 88 88 3C` → 0; `DeltaTime` 37 hits; `FrameTime` 1 hit; dumps | **Accepted** — no water link |
| P-d | `TimeSpeed/GameTime/GlobalTime` globals + tick imports | `TimeSpeed` 2; `GameTime` 3; `GlobalTime` 0; `GetTickCount/QueryPerformanceCounter` .idata only; `timeGetTime` 0; `Speed` 212 (unspecific) | **Accepted** — script RTTI only, no writer |

## 2. (a) Raw CODE search for the `0x854091` sequence + xrefs `[O]/[D]`

### 2.1 The reader is byte-unique `[D]`

- `DD 86 C8 00 00 00` (`fld qword [reg+0xc8]`) → **exactly 1 CODE hit**: `0x854091` (`ev_35b95844cc1ae55d1874f2fa5c2fea078048660333d241775a10d651491fef3a`, VA `0x854091`, file `0x453491`, section CODE).
- `DD 86 C8` short form → same single hit (`ev_0e51367a6b0b916d6215f7abe2108ff5e0b69a8ceae2b374ea9ce28530e8cc9e`).
- `D8 8E C4 00 00 00` (`fmul qword [esi+0xc4]`) → **exactly 1 CODE hit**: `0x854097` (`ev_2a0c94c5ba5ad23e0dd5343b2101ba0dd112ede5708a1d94d0216c856736fe2f`, file `0x453497`, CODE).
- 64 B at `0x854091` (`ev_66ea01d7fea6ac7c605712763d9d189f8d3c5d763d86b8111c99418b4b5b9aa2`): `dd 86 c8 00 00 00 | d8 8e c4 00 00 00 | 83 c4 fc | d9 1c 24 9b | ...` — i.e. `fld [esi+0xc8]; fmul [esi+0xc4]; add esp,-4; fstp dword [esp]` → `glUniform1f(time)` value on stack. Re-confirms prior `ev_bbdb…` reading; no new bytes contradict it.
- 720 B binder dump at `0x854080` (`ev_4932fac33c9bc73cc926e7f145468bcc314655236ee0d448000065166bc84e29`) re-observed: per-bit pushes `8b 53 xx / ff b6 <off>` with the time slot the only x87 `fld/fmul/fstp` triple in the 720 B window.

**`[D]` The `(dbl[+0xc8]*dbl[+0xc4])→float` reader exists exactly once in CODE. There is no second `fld [.+0xc8] + fmul [.+0xc4]` time-uniform site.**

### 2.2 Containing-function xrefs: built-in engine sees nothing `[O]`

- `native_xrefs_list(0x854054)` → 0 from / 0 to (`ev_c91824c6d6d490f8314185c78e6d3216351fd9fefd9139d118920913f1a3425e`, limitation `static_references`: computed-pointer refs not seen).
- `native_xrefs_list(0x854091)` → 0 from / 0 to (`ev_1fccb6227b069b45003a16190ed2b967775ab09b916584b7963b85c449b7eb25`, same limitation).
- `native_address_show(0x854091)` → no name/function/comment/bookmark (`ev_1407c1808fefb99ed9b0a8a8ba2e1543d138076786c8e7376bbdfb8cbc08e8dc`).
- `native_function_find(0x854091)` → `not inside any discovered function` (`ev_2141bc48cbf0ddb8957988b9e1485be7e8e61e681c1511466bf766db53d2bd96`, limitation `not_found`: absence is not proof).
- Same for `0x856530` / `0x856080` (`ev_89ebc19d791ce6191ba35c88337868da93d0dea8a312783201688eec4c60575d`, `ev_21c989f2dbbc23a800c90b28c69b13a9611aa5c99a94391a6e4ec8faa3b10b62`).

`[D]` Within the built-in 0.6.1 xref/function DB, the binder has **no static caller edge to follow to a `+0xc8` writer** — the DB is empty at these VAs (prior Deep/Ghidra function names `FUN_00854054/00856530/00856080` are not reproduced by this engine; `native_function_disassemble(0x856530)` → `function_not_found`). `[I]` A caller→writer walk needs the Deep engine's caller list or a full `e8`-scan from the Deep function bounds; it cannot be completed from the built-in DB alone. No caller is claimed.

## 3. (b) Constructor layout + all `+0xc8` reader/writer shapes `[O]/[D]/[U]`

### 3.1 Construction zeroes the accumulator `[D]`

- 512 B at `0x856080` (`ev_cda5534a4b56d58c8712438b3206710243a4b813d31139f545d7182926667836`) + 200 B head (`ev_6d64fcf92ac1b9db3ef22073816e5cea24259a90e679c8c5c11486268e27c669`): prologue `53 56 57 ...` then `... 33 c0 89 83 c8 00 00 00 89 83 cc 00 00 00 ...` = `xor eax,eax; mov [ebx+0xc8],eax; mov [ebx+0xcc],eax`.
- **`[D]` At construction the 8-byte slot `C+0xc8..0xcf` (time accumulator, double) is zeroed, so `time=0.0` at construction.** Re-confirms prior `ev_5aae…`. Object base in ctor is `EBX` = shader object; same register convention as binder `ESI`/`EBX` at `0x854091`/`0x856cea`.

Layout re-confirmed from prior + this ticket: `+0xc4` = Speed (float, `1.0` both paths), `+0xc8` = time accumulator (double), `+0x110` = scroll-scale float (second reader below), `+0xdc`=sampler unit, `+0xd8`=target, `+0xe0`=height obj, `+0xec`=shadow obj, `+0x184`=CustomEnable gate.

### 3.2 Every `DD ?? C8 00 00 00` shape in CODE `[O]`

`DD ?? C8 00 00 00` → **21 hits** (`ev_9400722e284be5777f3f3c8038d7987ab86f578489fdd434216fc15fb202ba13`):

| Shape | Semantics | VAs |
|---|---|---|
| `DD 83` | `fld qword [ebx+0xc8]` (load) | `0x50aee2/0x50af19/0x50af3c/0x50afae/0x5962dd/0x856cea/0x856cfb/0x856d9f/0x856db0` |
| `DD 80` | `fld qword [eax+0xc8]` (load) | `0x50b1fc/0x50b243/0x50b273/0x50b310` |
| `DD 9B` | **`fstp qword [ebx+0xc8]` (STORE — writer shape)** | `0x50af25/0x50af35/0x50aff4/0x5962e8` |
| `DD 98` | **`fstp qword [eax+0xc8]` (STORE — writer shape)** | `0x50b255/0x50b269/0x50b37a` |
| `DD 86` | `fld qword [esi+0xc8]` (the water time reader) | `0x854091` only |

`DC ?? C8 00 00 00` → 5 hits (`ev_e00dbf418b14f03c174a106696073734c578785635740c9bba19576ef52ce7b7`): `0x50ae8a/0x50aebf/0x50b180/0x50b1d0/0x596024` — `fadd/fmul/fsub/fdiv` double-memory forms, all in the `0x50axxx` cluster, none at water VAs.
`D9 ?? C8 00 00 00` → 40 hits (`ev_d1d046edf0f5860f4b438c7f53549bb6770664fe99814e4d6e001f2e3ff89df7`) — `fldcw/fst/fstp` float/single forms at unrelated VAs (`0x59b346/0x62965b/0x64axxx/0x67xxxx/0x6axxxx/0x71xxxx/0x73xxxx/0x7dxxxx/0x7fxxxx/0x80xxxx/0x86xxxx/0x87xxxx`), none in `0x854xxx/0x856xxx` water range.

### 3.3 Writer-shape contexts: real stores, unproven ownership `[O]/[U]`

Sampled contexts (all `[O]`):

- `0x50aee2` 220 B (`ev_2124b0c9b00d64a6c651789abc514f163c9fe4a8778559682fac94472e995b77`): `dd 83 c8 ...; dc a3 c0 ...; dd 9b a8 ...` interleaved with `8b 83 d0 00 00 00` (`mov eax,[ebx+0xd0]`) and float compares `dfe0/0f82...` — an interpolation/clamp loop over a struct with `+0xc0/+0xc8/+0xd0` doubles.
- `0x50af19` 300 B (`ev_4e6c76ee50121d46d94ba351c3188d3badd6a0b5252ea2d62958df5082fb8744`): same idiom; `dd 9b c8` stores bracketed by `dd 83 c8` loads and `dc 83 c0/dc 5b 68` arithmetic.
- `0x50afae` 200 B (`ev_2277e66beb91e8dab9c5e0e763a65cf87cd345b88bc567af8508e557127822a9`): `dd 83 c8; dc a3 c0; dd 9b a8` + `8b 43 60/64` + `89 83 c0/c4/42/44` integer stores — struct copy with neighbouring `+0xc0..+0xd0`.
- `0x50b243/0x50b255` 200–320 B (`ev_e5de032730c2b0f685258d35787ba690d0ab820453bef1ade0b6ff06f10ae8c5`, `ev_59ab113b155dc53510320294d44443a70b7a86ae64ecc105c4a2577e0e66c3c5`, `ev_678b3e3e6f28fb1dbda35cde0236c3db6b42e89a80d3791c485ad460f9ddc195`, `ev_9da6cf8d709300be12e255c1d9dff54511dfcb1db9595d78f0e84843b278b0b9`): base pointer from stack `8b 45 fc` (`mov eax,[ebp-4]`), then `dd 80 c8` loads / `dd 98 c8` stores, with `8b 45 fc dd 98 a8/c0` and `74 36` branches — same family, `EAX`-based object, not the water `EBX/ESI` shader object.
- `C7 ?? C8 00 00 00` (`mov dword [reg+0xc8],imm32` prefix) → 11 hits (`ev_17443a8e4b6bc202243f52983907b3fe0acac704f26c7445177128f8ac895c4a`): `0x44b80b/0x55fa92/0x568dcb/0x59a26e/0x703f35/0x764ced/0x7c7148/0x7efd81/0x80225f/0x809fa5/0x8d0995` — 6-byte prefixes only (need 10 B for full `C7 ... imm32` decode); **none in `0x854xxx/0x856xxx`**, so none is a water-ctor-style dword zeroing outside `0x856080`.
- `C7 ?? C4 ... 00 80 3F` (`mov [.+0xc4],1.0f` Speed init) → **0 hits** (`ev_f1e26b413ebb7526ec754003d66cd231876cebf4901d4f1f02d6158dad53b02d`): Speed is not initialised by an immediate `1.0f` store anywhere in CODE (consistent with ctor `fld1/fstp` or copy-from-layer, not an imm store).

**Verdict `[U]` (ownership):** the `DD 9B C8` stores at `0x50af25/0x50af35/0x50aff4` (new this ticket — extends prior "only `0x50b255/269/37a`" claim) and the `DD 98 C8` stores at `0x50b255/0x50b269/0x50b37a` (`ev_0fe2991a81254aecc7023ebf09b1f19f8edcd39e4f32b916af90794c560a08b5`; `DD 9E C8` variant → 0 hits `ev_9d48f6f60e587b49f2dfe796b72d2c6965fe3101919b6aac09171da4448c4b1f`) are **real double-stores to some struct's `+0xc8`**, but every context shows a different base (`[ebp-4]`/`EBX` in a `0x50axxx` code region ~3 MB from water) and a different field neighbourhood (`+0xa8/+0xc0/+0xd0` arithmetic, `+0x60` field ops) from the water shader object whose `EBX/ESI+0xc8` is read at `0x854091`/`0x856cea`. **No byte ties any of these stores to the water shader object.** They must NOT be claimed as the water writer. Prior "unrelated object" assessment stands, now with the `0x50afxx` family added to the same unproven set.

### 3.4 Second reader in the water selector: scroll uses the same accumulator `[D]`

- `0x856cea` 320 B (`ev_78c3584ff224881acb087c37b197dec8e8b392e61c35fbd1a2fdae214ea6fb7d`): `dd 83 c8 00 00 00 | d8 8b 10 01 00 00 | d9 5c 24 30 | ...` = `fld qword [ebx+0xc8]; fmul dword [ebx+0x110]; fstp ...` — the exact scroll idiom prior cited (`(float)*dbl[+0xc8] * float[+0x110]`).
- `0x856d9f` 220 B (`ev_040de51c06593df0291535e6c0f1c1305e979cdbd6a9f72662c86f58dbc50286`): same `dd 83 c8 ... d8 8b 20/24 01 ...` pair.
- **`[D]` The water-region `+0xc8` double has exactly two CODE readers: the `time` uniform at `0x854091` and the texture-scroll multiply in `FUN_00856530` (`0x856cea/0x856d9f` family). Both read the same accumulator; neither writes it.**

## 4. (c) Packed CODE floats / delta-time literals near shader-update `[O]/[U]`

- Float `1/60 = 0x3C888889` LE `89 88 88 3C` → **0 CODE hits** (`ev_6b82af6f35f2e4d003de6c94276e425a80c80dac9ffd86fbb8ce966e7f385a90`). No packed `0.0166667f` constant exists in the image (limitation: `file_bytes_only` — packed/computed-at-runtime not seen; absence is not proof of absence at runtime).
- `DeltaTime` → 37 hits (`ev_d3ad77447d8a8da1c86a9b2ab29c9327ded6ab652160c2b9260159c1d003814d`); head at `0x50a36b` 200 B (`ev_3dd073ac93b5d62440f65f1d138d4e21adbf8ecfb122d4ed6490abd991efe6ca`): `DeltaTime/MinDeltaTime/FixedDeltaTime/Mode/SleepLength/OnProgress` — a script-property RTTI block (`Float` fields), in the same `0x50axxx` neighbourhood as the `+0xc8` arithmetic cluster. `[I]` plausibly the frame-clock owner, but **no CODE byte links this block to the water shader object or to `+0xc8`** — co-location in one `0x50axxx` region is not a data-flow edge.
- `FrameTime` → 1 hit `0x6a5006` (`ev_db1980b1b1dcc48ea12a24ed56590b704643f89cce36963baffbab5d4aca8a63`), 160 B context (`ev_e630cd555796e2e8d57e88b20a13982e613fb0bfe7d06aa9f305213318e50275`): `FrameTime: Float … ResetPerformanceMonitor … GetAppSaveDirectoryPath … GetFogEnable` — script RTTI again, no water link.
- **`[U]` No frame-delta literal or `DeltaTime/FrameTime` field is byte-proven to feed water `C+0xc8`.** Do not wire `DeltaTime` into the port's time path without the §7 capture.

## 5. (d) Global `gGameTime` / `TimeSpeed` hypothesis `[O]/[U]`

- `TimeSpeed` → 2 hits (`ev_c4dd3bcbe1fad61db487e25557848915a4037c6b4abcf68d83dfdac02b529bc6`): `0x69f9a5/0x69f9d9`; 160 B context (`ev_e05a296e04c8dee79d8b81ae533a6d620cc22212e0d604c39a9b23b69dbbd95b`): `TimeSpeedFactor(factor: Float)` + `function GetTimeSpeedFactor(): Float` — **script-callable wrappers**, not a global variable write.
- `GameTime` → 3 hits (`ev_3e438b4bbc87056539d2291737090f78b9f7eef73f74ea86126b0475eb0800f9`): `0x6812c5` is `GameTime: String` (localisation/config string, context `ev_bb4585e5724e1edb79a107099080143b05e2a190bc5da28606a38aff9fb0d89c8`, surrounded by `LanPublicServerProfInfo/LanTerminateGame/LanShutdown` — unrelated); `0x69faf9/0x69fb21` context (`ev_dc44828ee328d83dbe2b45abfc831e5d1db0d16268ae2867723bed09b6ef10c9`): `GameTime(): Float … procedure SetGameTime(val: Float) … function GetRealTime(): Float … GetSeasonType` — **script getters/setters**, no CODE store to water `+0xc8` recovered.
- `GetRealTime` → 1 hit `0x69fb4a` (`ev_0434121e7738091bf37765ad7198d41b76ecfb562427accbcddd1d141eefe95c`); `SetGameTime` → 1 hit `0x69fb1e` (`ev_dc540ad9ec7eb967a712c3fc40e6801122da8dcf9de723e88afd3001d729b9c5`). Both inside the same script-RTTI table as above.
- `GlobalTime` → **0 hits** (`ev_dba01c95a06e1bc000591f64bd4ff317d0911704e2abdc4ddcd709a3888d8046`). No `GlobalTime` symbol exists in the image.
- `GetTickCount` → 2 hits, both `.idata` import names `0x907ef0/0x908688` (`ev_27d8d1d351aeb56ac186f675bd66d94cad6a3f5fed5ea05a9e48c65273c976ce`); `QueryPerformanceCounter` → 2 hits, both `.idata` `0x907f00/0x9084fc` (`ev_9d333b0bf9ebd42a24f5aa50a08d912d9eca54cb47c6faaa900c6c33dd52c4ec`); `timeGetTime` → **0 hits** (`ev_b7cb0b913856c9c3a9d2163278117818c891800bbe2a7faececb3ac8ae8fd0a1`). Imports exist; **no thunk-to-water xref recovered** (built-in xref DB empty at water VAs, §2.2).
- `Speed` → 212 hits (`ev_d800a69caf10b3efa65a9c0387e62057986c8d4e35b0c833c473e823666abe4e`, sample `0x446a5a/0x446bb0/...`) — too generic to attribute; not used as evidence.

**Verdict `[U]`:** there is **no byte-proven global** (`gGameTime`, `TimeSpeed` variable, tick counter) that writes water `C+0xc8`. The only time-like CODE strings are script-RTTI wrappers (`GetTimeSpeedFactor/GetRealTime/SetGameTime/GameTime`), which prove a script API exists but prove nothing about the per-frame water accumulator input. Do not invent a `gGameTime * TimeSpeed` source.

## 6. Claim register

`[D]` (byte-proven, may be used by port):
1. Time formula `(float)(*(double*)(C+0xc8) * *(double*)(C+0xc4))`, reader unique in CODE (`0x854091/0x854097`; §2.1).
2. `C+0xc4 = Speed = 1.0` on both construction paths (re-cited `ev_513e…/ev_5aae…/ev_227e…`; no imm-store form exists, §3.3).
3. `C+0xc8..0xcf = 0` at construction (`0x856080` bytes `33 c0 89 83 c8/89 83 cc`; §3.1) → `time=0` at construction.
4. Same `+0xc8` double is the scroll accumulator (`fld [ebx+0xc8]; fmul [ebx+0x110]` at `0x856cea/0x856d9f`; §3.4).
5. `CustomEnable=False → C+0x184=0` both paths → CUSTOM unreachable (re-cited; unchanged).

`[U]` (must stay labelled, hard-fail/parameter, never invented):
- **U5-writer**: no CODE store is proven to target the water shader object's `+0xc8`. Candidate shapes `DD 9B C8` (`0x50af25/0x50af35/0x50aff4`) and `DD 98 C8` (`0x50b255/0x50b269/0x50b37a`) are real stores to *some* `+0xc8` but ownership is unproven (§3.3).
- **U5-clock**: no delta literal, `DeltaTime/FrameTime` field, `GameTime/TimeSpeed` global, or tick-counter thunk is byte-linked to `+0xc8` (§§4–5).

No parity claim. No approximation substituted.

## 7. Still-`[U]` settling captures — exact, zero-mismatch (owner-authorised GPU/debug session only)

Forbidden to workers under read-only rule. Gating precondition for every row: one water field visible (break `FUN_00603d30 @0x603d30`, read `[ebp+0x1c]`), live path identified first (U1: hook `glShaderSource`; `alphaDepth/deepColor` = BUILTIN).

| # | Item | Static state after this pass | Capture (break + dump + termination) |
|---|---|---|---|
| U5-TIME | live `time` values | `[D]` formula + `Speed=1.0`; `[U]` writer/clock | Hook `glUniform1f` on the `time` location from the U1 program (wrapper `FUN_004c0f90 @0x4c0f90`, ptr `0x8fc724`, `ev_84eb…` re-cited). Log `(frame, uniform-location, float-value)` ≥3 frames over ≥2 s with camera moving. **Terminate only on:** (i) constant `0.0` — 0 differing samples over a 10 s window → `time=0 [D]`-by-capture; **or** (ii) varying — ≥3 strictly increasing samples with per-frame deltas logged, 0 missed frames. Until then port keeps `_time += delta` only as labelled `[U5]` scaffolding (re-cited `water3d.gd:251`), never presented as recovered. |
| U5-WRITER | writer EIP of `C+0xc8` | `[D]` construction zero; `[U]` all stores in §3.3 unowned | If U5-TIME varies: HW write-watchpoint (8 B) on shader `C+0xc8` from binder `ESI` at `0x854091` (or `EBX` at `0x856cea`). Record faulting EIP + disassembly + base-register object identity (`EBX/ESI/EAX` provenance back to `FUN_00851bdc` layer ptr vs `FUN_00856080` ctor). **Terminate only on:** single writer EIP firing every frame, 0 missed frames, and `0-ULP` reproduction `uniform == (float)(dbl[+0xc8]*dbl[+0xc4])` across the ≥3 logged frames. If watchpoint never fires while uniform varies → record as contradicting observation, keep `[U]`, do not invent a source. |
| U5-CLOCK | `DeltaTime/GameTime/TickCount` linkage | `[O]` script RTTI + `.idata` imports exist; `[U]` no water edge | Only after U5-WRITER fires: read the writer's source operand back to `DeltaTime/MinDeltaTime` (`0x50a36b` block), `GameTime/SetGameTime/GetRealTime` (`0x69faf9` block), or tick-thunk return. Dump the source value same frame as the uniform. **Terminate only on:** identical `(source-value, +0xc8, uniform)` tuple, 0 mismatches, 2 frames + move. Any gap → keep `[U]`, keep port hard-fail/parameter, never alias `DeltaTime` silently. |

U1/U3/U4*/U6/U12 use `DEC_U_water_runtime.md §9` / `DEC_U_water_lib_params.md §6` / `DEC_U_water_shader_deep.md §5` experiments verbatim; untouched by this worker.

## 8. Exact port guidance (no edits made — owner/COORD applies)

1. Keep `variant3d/scripts/water3d.gd:251` (`_time += delta`) and `water3d.gdshader:78` (`time`) **as labelled `[U5]` scaffolding**. Append/retain comment `time=(float)(dbl[+0xc8]*dbl[+0xc4]), Speed=1.0 (lib :42; 0x854091 ev_35b9/ev_2a0c/ev_66ea)` — already required by `DEC_U_water_lib_params.md §7.5`.
2. Do NOT wire `DeltaTime` (`0x50a36b`), `FrameTime` (`0x6a5006`), `GetTimeSpeedFactor` (`0x69f9a5`), `GetRealTime/SetGameTime` (`0x69faf9`), `GetTickCount`/`QueryPerformanceCounter` (`.idata`), or any `gGameTime*TimeSpeed` product into the port. All are `[U]` per §§4–5.
3. Do NOT treat the `0x50af25/0x50af35/0x50aff4` or `0x50b255/0x50b269/0x50b37a` stores as the water writer in code or comments beyond "unproven candidate shapes" (§3.3).
4. Keep `visual_parity_claim=false` and `unresolved=[U1,U3,U4*,U5,U6,U12]` until the §7 captures supply 0-mismatch tuples.

## 9. Explicit non-claims and file discipline

- **No parity claim.** No donor binary executed, no GPU frame captured, no port capture compared. All readings are `[O]/[D]` re-cited or new `[O]` above; all unsettled values are `[U]` with §7 captures.
- **No approximation substituted.** No time source, clock, delta literal, or writer is asserted beyond the byte-proven reader + construction zero.
- **Read-only compliance.** Exactly one repo file written: `docs/terrain_swarm_2026-11-26/reports/DEC_U_water_time_deep.md`. No code/shader/asset/config/Godot/git change. No donor file opened for write or executed. No Craft Anything investigation memory written (brief/plan/hypothesis/finding/handoff untouched; evidence ids cited, not asserted as findings).

*End DEC-U-WATER-TIME-DEEP (complete).*
