---
id: DEC-U-NB4-2026-11-26
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: "WORKER DEC-U-NB4 — class-B candidate NB-4 GenerateMapRandKey body scan"
owner_file: docs/terrain_swarm_2026-11-26/reports/DEC_U_nb4.md
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
date: 2026-11-27
target: "t_87f0f3c130b0 — C:\\Games\\Cossacks 3\\cossacks.exe, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
labels: [OBSERVED, DERIVED, UNVERIFIED, NO_APPROXIMATION, PARITY_UNVERIFIED]
parity_status: UNVERIFIED
parity_claim: NONE
visual_parity_claim: false
scope_guard: "Donor READ ONLY; pinned document:\"t_87f0f3c130b0\" on every native call. No donor binary executed/copied/committed/debugged; no repo code/shader/config/asset/test/fixture/result/Godot/git edit; no Craft Anything brief/plan/finding/unknown mutation. Exactly one repository file written: this report."
---

# DEC-U-NB4 — `GenerateMapRandKey` body scan (NB-4, refines B3)

## 0. Discipline / prior state

- **[O]** = bytes / instruction re-read in this ticket (pinned `t_87f0f3c130b0`), or carried verbatim with evidence id.
- **[D]** = deterministic arithmetic / counting consequence of [O].
- **[U]** = UNVERIFIED — never implemented as fact; exact breakpoint dump + restart zero-mismatch termination given.
- **No donor GPU frame. No parity claim. No invented derivation.**
- Prior accepted as [O] (`DEC_U_place_seed_deep.md`, `DEC_U_genseed_deep`): `GenerateMapRandKey(var randkey0; var randkey1)` declaration at VA `0x69f452` (FO `0x29e852`) is a CODE-embedded RTTI string with 2 var-out args; `native_function_find` at `0x69f452`/`0x60a662` reports "not inside any discovered function"; all table VAs have 0 static xrefs (VM-dispatched via `FUN_00608238`); length-prefix `4A`=74 at `0x69f440`; 11× `SetRandomKey(randkey1)` + 3× `SetRandomExtKey64(randkey0,randkey1)` verbatim identity reseeds; Delphi LCG `sub_403a0c` + slot `0x8f2008` + seeder `sub_4033b8`.
- Entering-[U]: `GenerateMapRandKey` derivation body / arithmetic / var-out word order / map-name-or-settings input vs constants (U-KEY).

Multi-pass ledger (≤5 passes per oddity; every native call pinned `document:"t_87f0f3c130b0"`):

| Lead | Pass 1 | Pass 2 | Pass 3 | Pass 4+ | Accepted |
|---|---|---|---|---|---|
| (a) decl vs body | `bytes_show 0x69f440/0x69f452` 512 B re-read: both return RTTI text, not code [O] | `function_find 0x69f452` → null (not inside discovered function) [O] | LE-pointer scan `52 F4 69 00` → 0 hits (packed/registry indirection, not absence proof) [O] | — | decl VA is a string, body lives elsewhere |
| (b) registry carve | wildcard `BA ?? F4 69 00` → 4 hits `0x69ae52/63/74/85` (CODE) [O] | `function_find 0x69ae52` → inside `sub_69a70c` (entry `0x69a70c`, size 10872, 639 calls-out, 1 block — map-gen registrar, twin of `sub_608238`) [O] | `function_disassemble sub_69a70c` → 639 `(ecx,edx)` pairs; 8 with `edx` in `0x69f420–0x69f650`, incl `ecx=0x6ac244/edx=0x69f448` [D] | orientation check vs `sub_608238` (`ecx`=impl, `edx`=decl) | `GenerateMapRandKey` impl VA = **`0x6ac244`** [D] |
| (c) body decode (engine note) | `objdump disassemble` → `engine_missing` (no binutils); `rizin pd` → `engine_missing` (no Rizin) [O] | fell back to Deep-mode builtin stepping: `instruction_show` + `cursor_forward` from `0x6ac244` (avoids linear function-lift misalignment; `function_find 0x6ac244` is null by design) [O] | 60-step walk covers `0x6ac244–0x6ac2f0`: four sibling bodies (`Gen/Get/Set/GetGlobal/SetGlobal`) each `ret 8` [O] | focused re-reads of range/call/cdq/store/LCG bytes | exact arithmetic [D] (see §2) |
| (d) word-order cross-check | `instruction_show` Get pushes `0x6ac275/0x6ac278` + Set pops `0x6ac2aa/0x6ac2ad` [O] | `bytes_show 0x69f420` decl run + `0x69ae4d` registrar bytes [O] | helper `0x8484d0` / swap `0x8484ac` / singleton `0x705944` walks [O] | — | `+0x18=randkey1, +0x1c=randkey0` consistent both sides [D] |

Engine honesty: the "engine Deep command" for this ticket is the Deep-mode (`analysis_mode: deep`) builtin instruction stepper. GNU objdump and Rizin are not installed on this host, so their lanes were attempted and refused; no linear `function_disassemble`/`pseudocode` lift is cited for the undiscovered `0x6ac2xx` bodies — every opcode below is a stepped `instruction_show` [O].

## 1. Evidence register (new in this ticket unless marked carried)

| Evidence id | Operation (pinned `t_87f0f3c130b0`) | Establishes |
|---|---|---|
| `ev_b9f0c5f9311cbabf29ceecc8ec9ae819e8c43f6496fc5bed5c9347d4d26aec87` | `native_bytes_find pattern "BA ?? F4 69 00"` | 4 CODE hits `0x69ae52/63/74/85` (`ba20f46900` etc = `mov edx, 0x69F4xx`) [O] |
| `ev_3c218fdef299f9daf2e50ba380cda91296b3d5e6d556fca3a091aced75e87581` | `native_function_find 0x69ae52` | inside `sub_69a70c +0x746` [O] |
| `ev_d4963f5618242ac9a7a99872241a15b935f291820c9b1938c9bd901ee45f1e80` | `native_function_show 0x69ae52` | `sub_69a70c` entry `0x69a70c`, end `0x69d184`, 10872 B, 3202 insns, 639 calls-out, 1 block [O] |
| `ev_21cfd5f4b619330635ca3df6b50df5b6d7c9d2f68e118a7715` (truncated id, full in ledger) | `native_function_disassemble sub_69a70c` | 639 `(ecx,edx)` pairs; 8 map-key pairs `ecx 0x6ac234–0x6ac320 / edx 0x69f420–0x69f61c`, incl `0x6ac244↔0x69f448` [O]/[D] |
| `ev_b3d6fc1f91b17942d208b2862063594728402dec4abbd401cc1993adc9a34908` | `native_bytes_show 0x69f440` 128 B | `RegenerateMapNeeded` + `GenerateMapRandKey(var randkey0…; var randkey1…)` decl run; `0x69f448` = decl base, `0x69f452` = name-hit inside it [O] |
| `ev_0c3cbed58ddf5a9fe435061b1af11ef816d153b9e01f331e8325a6135015ad33` | `native_bytes_show 0x69ae4d` 64 B | registrar instruction bytes `B9 34 C2 6A 00 / BA 20 F4 69 00 …` (`mov ecx,impl / mov edx,decl`) [O] |
| `ev_c0d732fb7f739231a5a411b43f4808cca65ca0709b441ba7015580ea1f94cab3` | `native_bytes_show 0x6ac244` 32 B | body head hex `55 8B EC B8 FF FF FF 7F E8 BB 77 D5 FF 99 52 50 …` [O] |
| `ev_e3d1710405af96d8df661351064efddfd0009a4fc08e3b2ba91945d81b155e0f` | `native_instruction_show 0x6ac247` | `mov eax, 0x7fffffff` (`b8ffffff7f`) [O] |
| `ev_dc243dd3898b231c1f950d3e758190bf2fc33d41cc13b43fb981dffa27da0109` | `native_instruction_show 0x6ac24c` | `call 0x403a0c` (`e8bb77d5ff`) [O] |
| `ev_073af1936740bb69e3f676d87cf86b44bab61146169d59c15611c7bdafdad485` | `native_instruction_show 0x6ac251` | `cdq` (`99`) [O] |
| `ev_2aee671b8484cc5a1e0014b12ec40417999f10634a1f7c4afbabcfe2b746cb6c` | `native_instruction_show 0x8484d3` | `mov ecx,[ebp+0xc]` [O] |
| `ev_ce1cf038fe45f8001c42556c887e1a36095a517d56a48903582b86019351100f` | `native_instruction_show 0x8484d6` | `mov [eax],ecx` [O] |
| `ev_300506d729d333c98a0b0472de2f9f0ca580037b154357759f7d9a37e88fbe7b` | `native_instruction_show 0x8484d8` | `mov eax,[ebp+8]` [O] |
| `ev_54398df9e475432737e0de45f95bf148a565387de50bb12f63449ac47dac0163` | `native_instruction_show 0x8484db` | `mov [edx],eax` [O] |
| `ev_6d21e3c7b880915c20667e49f6510bc56cf75e841da23b9a06996d98f9f5a4cd` | `native_instruction_show 0x403a0f` | `imul edx,[ebx+0x8f2008],0x8088405` (Delphi LCG step) [O] |
| `ev_25e733275215273b34650f0447100744a707f70135f0753f3805f3ea3efd41b5` | `native_instruction_show 0x6ac275` | Get: `push dword ptr [eax+0x1c]` [O] |
| `ev_ef51315b8c1df504b64205d4c4cb3551ed259391520230aa581b335bfb18eb36` | `native_instruction_show 0x6ac278` | Get: `push dword ptr [eax+0x18]` [O] |
| `ev_6a0aed3e8a55ae13c74c69dce371071be80245d707793e706088558c72a2e911` | `native_instruction_show 0x6ac2aa` | Set: `pop dword ptr [eax+0x18]` [O] |
| `ev_b4e871c236f6eea2389f5c2e2e49f016e5dcc5ac215c8b31619823dbf7e3a8af` | `native_instruction_show 0x6ac2ad` | Set: `pop dword ptr [eax+0x1c]` [O] |

Coverage caveat: `file_bytes_only` + `static_references` + `not_found`-means-undiscovered (not absent) apply to every zero/null row, as in the prior ticket. Pointer-LE scans that miss are consistency, not closed-world proof.

## 2. Body decode — exact arithmetic [D]

### 2.1 `GenerateMapRandKey` impl at `0x6ac244` (decl `0x69f448`, name-hit `0x69f452`)

Stepped listing (`instruction_show` + `cursor_forward`, 12 insns to `ret 8`):

```asm
0x6ac244  55                push ebp
0x6ac245  8bec              mov ebp, esp
0x6ac247  b8ffffff7f        mov eax, 0x7fffffff
0x6ac24c  e8bb77d5ff        call 0x403a0c        ; Delphi Random(range)
0x6ac251  99                cdq                   ; edx = sign(eax)
0x6ac252  52                push edx
0x6ac253  50                push eax
0x6ac254  8b550c            mov edx, [ebp+0xc]    ; edx = @randkey1 (2nd var-out)
0x6ac257  8b4508            mov eax, [ebp+8]      ; eax = @randkey0 (1st var-out)
0x6ac25a  e871c21900        call 0x8484d0          ; store helper
0x6ac25f  5d                pop ebp
0x6ac260  c20800            ret 8                 ; stdcall, 2 args
```

Store helper at `0x8484d0` (8 insns to `ret 8`):

```asm
0x8484d0  55                push ebp
0x8484d1  8bec              mov ebp, esp
0x8484d3  8b4d0c            mov ecx, [ebp+0xc]    ; ecx = first-pushed word (hi)
0x8484d6  8908              mov [eax], ecx        ; *randkey0 = hi
0x8484d8  8b4508            mov eax, [ebp+8]      ; eax = last-pushed word (lo)
0x8484db  8902              mov [edx], eax        ; *randkey1 = lo
0x8484dd  5d                pop ebp
0x8484de  c20800            ret 8
```

[D] consequences:

1. **Single input constant: `0x7fffffff`.** No map-name pointer, no settings pointer, no second constant, no second `Random` call, no time/hardware source is loaded in this body. The only call before the store is `sub_403a0c` with `eax=0x7fffffff`.
2. **`sub_403a0c` is Delphi `Random(range)`** (carried + re-anchored `imul edx,[ebx+0x8f2008],0x8088405` at `0x403a0f`): `state=(state*0x8088405+1) mod 2^32` stored at `0x8f2008`; `mul edx` then `mov eax,edx` returns the high dword `(state_lo × range) >> 32`. With `range=0x7fffffff` the return satisfies `0 ≤ eax ≤ 0x7ffffffe`.
3. **`cdq` forces `key0 = 0`.** `eax` is non-negative by (2), so `cdq` sets `edx=0` deterministically. Push order is `push edx` (hi=0) then `push eax` (lo=Random), so at the helper `*randkey0 = hi = 0`, `*randkey1 = lo = Random(0x7fffffff)`.
4. **Var-out word order [D]:** `eax=[ebp+8]` is the 1st var parameter (`randkey0`), `edx=[ebp+0xc]` the 2nd (`randkey1`) — standard register passing, confirmed by all four siblings using the same convention. `*randkey0` receives the `+0xc` stack word (hi), `*randkey1` the `+0x8` word (lo).

So the **exact byte-proven derivation** is:

```pascal
procedure GenerateMapRandKey(var randkey0, randkey1: Integer);
begin
  randkey1 := Random($7FFFFFFF);  // Delphi Random, one draw, 0..$7FFFFFFE
  randkey0 := 0;                 // cdq sign word of the non-negative draw
end;
```

No map name, no map settings, no `mix64`/`stable_hash`, no `QPC`/`TickCount`, no constant pair is returned: `key0` is a **constant 0** and `key1` is a **single Delphi-`Random` draw**. [D]

### 2.2 Word-order cross-check via Get/Set siblings [D]

- `GetMapGeneratorRandomKey` (`0x6ac264`): `call 0x705944` (singleton) → `mov eax,[eax+0x4c]` → `mov eax,[eax+0x1a8]` → `push [eax+0x1c]` → `push [eax+0x18]` → same `call 0x8484d0`. Hence stored `+0x1c → *randkey0`, `+0x18 → *randkey1`.
- `SetMapGeneratorRandomKey` (`0x6ac28c`): `mov edx=[ebp+0xc]` (=val1), `mov eax=[ebp+8]` (=val0) → `call 0x8484ac` (register swap: saves/restores cross so `eax↔edx`) → `push edx` (=val0) → `push eax` (=val1) → singleton → `pop [eax+0x18]` (=val1) → `pop [eax+0xc]`…`[eax+0x1c]` (=val0). Same layout: **`+0x18 = randkey1, +0x1c = randkey0`**. [D]
- `Get/SetGlobalMapGeneratorRandomKey` (`0x6ac2b4`/`0x6ac2e0`) repeat the identical push/pop pair on `+0x108/+0x10c`: `+0x10c = randkey0`, `+0x108 = randkey1`. [D]
- All five bodies end `ret 8` (stdcall, callee cleans 2 args). [O]

### 2.3 What was NOT found (kept narrow)

- No `b9 <declVA>` direct-call planting was ever needed: registration is indirect (`mov ecx,impl / mov edx,decl / mov eax,ebx / mov esi,[eax] / call [esi+0x30]`), which is why flat `xrefs_list` and LE scans at the decl VA are 0 — VM-dispatched, consistent with `DEC_U_place_seed_deep` D02 `FUN_00608238` note. [D, narrow]
- The registrar orientation `ecx=impl, edx=decl` is proven by the 8-pair `0x69f420–0x69f61c ↔ 0x6ac234–0x6ac320` run plus the `sub_608238` twin shape (262 pairs, all `ecx` in code / `edx` in decl-table runs). [D]
- Whether the engine ever calls `GenerateMapRandKey` at runtime (call-site census), and the live `(key0,key1)` values for a given menu seed, remain runtime questions — see §4 probes. The **derivation formula itself** is closed [D]; its **invocation timing** is not.

## 3. Bottom line

- **(a) NEW [D]:** `GenerateMapRandKey` body located — decl `0x69f448` (name-hit `0x69f452`) ↔ impl **`0x6ac244`** via map-gen registrar `sub_69a70c` (`0x69ae52` row: `mov ecx,0x6ac244 / mov edx,0x69f448 / call [esi+0x30]`).
- **(b) NEW [D]:** exact arithmetic — `eax=0x7fffffff; call Random; cdq; store(hi→randkey0, lo→randkey1)` ⇒ **`randkey0=0` constant, `randkey1=Random($7FFFFFFF)` single draw**. No map-name/settings input, no constant pair, no second draw.
- **(c) NEW [D]:** var-out word order — 1st var (`eax`) = `randkey0` = hi word; 2nd var (`edx`) = `randkey1` = lo word; stored layouts `+0x18/+0x1c` (map) and `+0x108/+0x10c` (global) both hold `(randkey1, randkey0)` low-to-high.
- U-KEY derivation is therefore **CLOSED [D]** at the formula level. U-KEY2 (runtime key0-discard), U-MAP (shipped-map override), U-SS/U-ONLY/U-TIME (Delphi per-run stream) are untouched by this ticket and stay [U] with their existing probes.

## 4. Still-[U] fields (unchanged ownership; narrowed by §2)

### U-KEY2 — runtime key0-discard (call `DEC_U_place_seed_deep §6`)

- §2 proves every *fresh* `GenerateMapRandKey` output has `key0=0`, so the 3 `SetRandomExtKey64(randkey0,randkey1)` sites install `(0, K)`. The strict claim "key0 has zero effect on every draw" still needs the ±1 probe because a *shipped map or debugger* could still present non-zero `key0` to those sites.
- Probe (authorised trace worker only): fix `randkey1=K` (`K=1`, repeat `K=12345`), run `key0=0` vs `key0=1` with everything else identical (`W=H=320`, `shape=nowater2`, `version=92`, `minesdensity=1`, `spcount=4`, `season=0`, `b_random_map=true`); dump the `D2:190` mask pick + first three `RandomExt` floats after each `D2:216/513/774` ext-reseed. **Terminate** when `key0`-only changes are bit-identical on all draws after draw #1 AND differ at most on draw #1 per the cross-term model, with zero mismatches on both `K` values and two map sizes.

### U-MAP / U-SS / U-ONLY / U-TIME — carried verbatim from `DEC_U_place_seed_deep §6`

- U-MAP (map-load `0x8f2008` watch), U-SS (`0x83272f` first-hit `state-before>>>24` + restart-changes-seed proof), U-ONLY (write-watch attribution), U-TIME (`0x4033bc` branch) unchanged. **Restart-changes-seed zero-mismatch termination:** restart + same menu settings ⇒ `GenerateMapRandKey` pair must differ across restarts (Delphi stream seeded from wall-clock `sub_4033b8`) while same-process regeneration continues the stream; any same-seed-same-pair repeat is a mismatch (refutes wall-clock seeding, still no invention).

## 5. Port change list (file:line; no edits made here)

1. `GenerateMapRandKey` port stub: replace "unknown derivation [U]" with §2 formula `randkey0 := 0; randkey1 := DelphiRandom($7FFFFFFF)` — labelled **[D] byte-proven**, citing `ev_e3d17104…/ev_dc243dd3…/ev_073af193…/ev_2aee671b…–ev_54398df9…`. Keep the single-draw / single-`Random`-call shape; do not add map-name/settings inputs.
2. `Get/SetMapGeneratorRandomKey` + `Get/SetGlobal…` field map: wire `+0x18/+0x108 ← randkey1`, `+0x1c/+0x10c ← randkey0` (citing `ev_25e73327…/ev_ef51315b…/ev_6a0aed3e…/ev_b4e871c2…`). Keep `ret 8` stdcall shape in any native shim note.
3. Keep `SetRandomExtKey64` ledger storing `key0` (now proven `0` at fresh-generation) and seeding `s=key1`; amend the U-KEY2 comment to the narrowed form in §4 (first-draw cross-term only for non-zero `key0` presentations).
4. Registrar cite: `sub_69a70c` (`ev_d4963f56…`) rows `0x69ae4d–0x69aec4` (`ev_0c3cbed5…`) as the CODE anchor for `0x6ac244↔0x69f448`; note flat-xref absence is VM-dispatch, not proof of non-registration.

## 6. Claim register (audit-level; no parity)

| # | Claim | Label |
|---|---|---|
| 1 | `GenerateMapRandKey` impl is `0x6ac244`, registered from `sub_69a70c` row `mov ecx,0x6ac244/mov edx,0x69f448` | `[D]` §1–§2 |
| 2 | Body = `mov eax,$7FFFFFFF; call Random(sub_403a0c); cdq; store(hi→key0, lo→key1)`; `key0=0` constant, `key1=Random($7FFFFFFF)` one draw; no name/settings input, no constant pair | `[D]` §2.1 |
| 3 | Var-out order 1st=`randkey0`=hi, 2nd=`randkey1`=lo; stored `+0x18/+0x108`=`randkey1`, `+0x1c/+0x10c`=`randkey0` | `[D]` §2.2 |
| 4 | objdump/Rizin lanes unavailable on host (engine_missing, attempted); stepping used Deep-mode builtin `instruction_show`/`cursor_forward`, no linear-lift claim on undiscovered bodies | `[O]` §0 |
| 5 | `parity.claim=NONE`, `parity.status=UNVERIFIED`, `visual_parity_claim=false`; no donor executed, no frame compared, no value wired until §4 probes terminate | `[O]` scope guard |

> Verbatim governing line: PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

*End of DEC-U-NB4. Files written: this report only. Donor read-only; no binary executed, copied or committed; no code, shader, config, asset, test, git, Godot or investigation-memory state changed. No parity claimed.*
