---
id: DEC-DEEP-corner-tags
ticket: "TERRAIN-SWARM-2026-11-26 / DEC-DEEP corner tags"
title: "Deep corner-tag rule: 24-byte setter callers, four-tag choice, random byte, 13-byte flags"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY
owner_file: docs/terrain_swarm_2026-11-26/reports/DEC_DEEP_corner_tags.md
targets:
  - "C:\\Games\\Cossacks 3\\cossacks.exe — t_87f0f3c130b0 (primary, every native call pinned)"
labels: [O, D, U, "PORT GUIDANCE"]
parity_claim: false
scope_guard: "Donor READ ONLY. No donor executable run, copied, committed or modified. No repo code/shader/config/asset/test/git edit. No Godot job. Exactly one repo file written: this report."
---

# DEC-DEEP — corner tags: callers, four-tag choice, random byte, 13-byte flags

## 0. Executive summary

1. **[O] One `tex` value never expands into four tags.** The 24-byte setter at `cossacks.exe:0x8326b8` (reached from DScript `SetTileIndex` at `0x6b1d50`, `call 0x8326b8` at `0x6b1d7b`) stamps **one `u8` tile into one corner of each of up to four adjacent 24-byte cell records**. A finished cell is therefore the overlap of up to four independent source-vertex writes.
2. **[O] Uniform `[T,T,T,T]` is the interior uniform-region case, not a setter rule.** If the four covering source vertices `(r,c)`, `(r,c+1)`, `(r+1,c)`, `(r+1,c+1)` all carry `T`, the cell is `[T,T,T,T]`. Tags differ exactly when those covering vertices carried different scalar ids (shore/cliff/road/desert/smoothing borders, sparse overwrites, map edges). There is **no neighbour comparison, no face-direction branch, no mask/sort/LUT at write time**.
3. **[O] Random byte is per-accepted-write Delphi `Random(256)` at record `+4`, not DScript `RandomExt`.** `0x403a0c`: `state@DAT_008f2008 = state*0x8088405+1`, return `(256*state)>>32 = state>>>24`. One draw per accepted target cell in `a`-outer/`b`-inner order, overwriting any prior variant. `0x81272f` is **not** the source — it disassembles as `CODE` garbage (`hlt` / `add` soup).
4. **[O] The 13-byte tail is never written by `0x8326b8`.** Layout `values[4]+flags[4]+override+override_rnd+control[2]+dirty` is initialized/serialized/pattern-stamped/brush-edited independently and can only replace a corner at render time via `0x830754`/`0x830818` when a terrain-object override is active. Shipped base/DLC maps retain the default tail.
5. **[D] Port recommendation:** keep scalar `tex` only as a source-vertex field; store `tags[4]+variant` per cell from ordered setter replay (or ingest baked bytes); build 1–4 alpha layers from sorted distinct final tags + occupancy mask + variant-selected patch. Do not derive transitions from `tile_id` bits; do not invent `record13` flags in the setter.

**No donor visual-parity claim is made.**

---

## 1. Target discipline and multi-pass method

- Pinned document: `t_87f0f3c130b0` (`cossacks.exe`, SHA-256 `87f0f3c130b0…`). Deep mode. Donor read as bytes/disassembly only; never executed/copied.
- Prior ground truth re-read: `DEC_SMALL_corner_tag_writer.md` (24-byte setter + uniform rule) and `DEC_VIS_04_corner_tags.md` §§3–8 (DScript registration, four-corner expansion, RNG, 24+13 layout, serializer correction, brush/record13 lifecycle).
- Passes in this job (all on `t_87f0f3c130b0`):
  - P1 — Containment: `native_function_find` for `0x8326b8`, `0x8302b0`, `0x8305a0`, `0x6b1d0c`, `0x6b1d50`, `0x830d8c`, `0x830754`, `0x80ec30` (proves high-VA functions are undiscovered; only `0x82ec5c`/`0x80ec30`/`0x403a0c` are discovered).
  - P2 — Setter opcode walk: `native_bytes_show` + `native_instruction_show` + `native_cursor_forward` stepping from `0x8326b8` for ~90 instructions (exact loop, bounds helper, row-pointer math, corner store, RNG call/store, callback, loop bounds).
  - P3 — Accessor/serializer walk: stepping from `0x8302b0` (load), `0x8305a0` (save), `0x82ec5c` (24-byte getter), `0x403a0c`/`0x50fba0` (RNG/bounds helpers).
  - P4 — DScript wrapper walk: stepping from `0x6b1d0c` (get) and `0x6b1d50` (set), pinning `call 0x82ec5c` and `call 0x8326b8`.
  - P5 — Brush/override walk: stepping from `0x830d8c` (brush set corner), `0x830754` + `0x830818` (render override), `0x80ec30` (clear corner flag path).
  - P6 — Caller/xref pass: `native_function_callers_list` for `sub_82ec5c` (10 sites) and `sub_403a0c` (15 discovered sites); `native_xrefs_list` for `0x8326b8` (0 refs — tool blind spot for undiscovered high VAs, documented); `native_data_show`/`native_bytes_show` for `0x8f2008`, `0x81272f`, `0x8f5d00`, `0x8fc33c`.
  - P7 — `core_evidence_show` audit to use only intact evidence ids; new findings `fnd_62/63/64` recorded.

---

## 2. Evidence register

### 2.1 This worker (all `t_87f0f3c130b0`)

| Evidence id | Source | Establishes |
|---|---|---|
| `ev_62867c10…` | `0x50fba0: cmp ecx,edx` | Bounds helper entry; `0x8326b8` calls it twice per candidate cell |
| `ev_6d21e3c7…` | `0x403a0f: imul edx,[ebx+0x8f2008],0x8088405` | Delphi LCG multiply; `ebx=0` so absolute `DAT_008f2008` |
| `ev_cf0eb488…` | `0x403a19: inc edx` | LCG `+1` (`mod 2^32`) |
| `ev_82cbb365…` | `0x403a1a: mov [ebx+0x8f2008],edx` | State store |
| `ev_17c7d817…` | `0x403a22: mov eax,edx` | Return high half after `mul edx` (`0x403a20`) |
| `ev_86d386f5…` | `0x403a20: mul edx` | `(range*state)>>32` range reduction |
| `ev_da8c05a1…` | `0x403a0c: push ebx` | `sub_403a0c` entry (26 B, 1 block) |
| `ev_f505b1a3…` | `native_function_study sub_82ec5c` complete dossier | 34 insns, `rep movsd ecx=6`, OOB default path, pseudocode |
| `ev_01c4ba7a…` | `native_function_callers_list sub_82ec5c` | 10 direct callers (see §4) |
| `ev_be530cd5…` | `native_function_callers_list sub_403a0c` | 15 discovered callers; undiscovered `0x8326b8` caller missing (limitation) |
| `ev_8582eec…` | `native_function_show 0x403a0c` | 26 B / 9 insns / 1 block |
| `ev_4f8831fd…` | `native_data_show 0x8f2008` | `DATA u32`, image value `0` |
| `ev_ec4aa830…` | `native_data_show 0x81272f` | `CODE u32 0x4cb90c00`; not a variant byte |
| `ev_50a7c761…` | `0x81272f: add [ecx+edi*4],cl` | Proves `0x81272f` decodes as garbage, not code |
| `ev_fdd75f3e…` – `ev_017f2bc5…` | `0x812710–0x81272d` stepping | `hlt`/`test/sahf/dec/add` soup around `0x81272f` |
| `ev_3b0f9b4b…` | `native_function_study sub_80ec30` | 33 blocks / 197 insns / 13 callees / 3 callers |
| `ev_1ec06c85…` | `native_bytes_show 0x8fc33c` 64 B | Default-record pointer table bytes |
| `ev_ffbaf231…` | `native_data_show 0x8f5d00` | Alpha LUT base (opaque `u32` typing only; table semantics from DEC-VIS-01) |

Manual stepping observations without separate evidence ids reuse the above plus `DEC_SMALL`/`DEC_VIS_04` anchors below; VA + bytes + mnemonic are quoted verbatim in §3.

### 2.2 Reused (still valid, not re-derived)

- `DEC_SMALL`: `0x83271f mov [eax+ebx],dl`, `0x832727 call 0x403a0c`, `0x83272f mov [edx+4],al`, `SetTileIndex` string `0x6a2f12`, `_misc_SetDesert` scalar call sites, `sub_82ec5c`/`sub_82ebc0`/`sub_82ed00` getters, renderer `0x812fca call 0x82ec5c`.
- `DEC_VIS_04`: registration `sub_69a70c`, Deep `FUN_006b1d0c/006b1d50/008326b8/00403a0c/004033b8`, `sub_82ec5c/82ebc0/82ed00/82ed4c`, serializer `FUN_008305a0/008302b0`, brush `FUN_00830d8c/00830c68`, pattern `FUN_00755c6c/00755010`, render `FUN_00830754/00830818`, `sub_812e34` mask path, default templates `record24@0x8f6164` / `record13@0x8fab6c`, corrected tile anchors.

---

## 3. The 24-byte setter: exact code

### 3.1 Entry and loop shape

`0x8326b8` is **not** in the built-in discovered-function set (`native_function_find`: “not inside any discovered function”), but its bytes are a normal function prologue:

```text
0x8326b8 55          push ebp
0x8326b9 8BEC        mov ebp,esp
0x8326bb 83C4EC      add esp,0xffffffec
0x8326be 53          push ebx
0x8326bf 56          push esi
0x8326c0 57          push edi
0x8326c1 894DF8      mov [ebp-8],ecx      ; param A (native r)
0x8326c4 8955FC      mov [ebp-4],edx      ; param B (native c)
0x8326c7 8BF0        mov esi,eax          ; terrain object
0x8326c9 33C0        xor eax,eax
0x8326cb 8945F0      mov [ebp-0x10],eax   ; a = 0 (outer)
```

Outer `a` at `[ebp-0x10]`, inner `b` in `ebx`:

```text
0x8326ce 33DB        xor ebx,ebx          ; b = 0
0x8326d0 8B7DFC      mov edi,[ebp-4]      ; edi = c_param
0x8326d3 2B7DF0      sub edi,[ebp-0x10]   ; edi = c - a
0x8326d6 8B45F8      mov eax,[ebp-8]      ; eax = r_param
0x8326d9 2BC3        sub eax,ebx          ; eax = r - b
0x8326db 8945F4      mov [ebp-0xc],eax
```

### 3.2 Bounds are on the target cell, via `0x50fba0`

```text
0x8326de 8B4E04      mov ecx,[esi+4]      ; W
0x8326e1 49          dec ecx              ; W-1
0x8326e2 33D2        xor edx,edx          ; 0
0x8326e4 8BC7        mov eax,edi          ; candidate (c-a)
0x8326e6 E8B5D4CDFF  call 0x50fba0
0x8326eb 84C0        test al,al
0x8326ed 744F        je 0x83273e          ; skip cell
... second check with [esi+8] (H) and [ebp-0xc] (r-b) ...
```

`0x50fba0` (stepped P3):

```text
0x50fba0 3BCA  cmp ecx,edx   ; max vs 0
0x50fba2 7C08  jl fail
0x50fba4 3BC2  cmp eax,edx   ; idx vs 0
0x50fba6 7C04  jl fail
0x50fba8 3BC8  cmp ecx,eax   ; max vs idx
0x50fbaa 7D03  jge ok
0x50fbac 33C0  xor eax,eax / ret
0x50fbaf B001  mov al,1 / ret
```

i.e. `0 <= idx <= max`. Two calls = `0<=c-a<W` and `0<=r-b<H`. No clamping, wrapping, or neighbour read.

### 3.3 Record address and corner store

```text
0x832701 8B4614      mov eax,[esi+0x14]   ; row-pointer table
0x832704 8B04B8      mov eax,[eax+edi*4]  ; row (c-a)
0x832707 8B55F4      mov edx,[ebp-0xc]    ; (r-b)
0x83270a 8D1452      lea edx,[edx+edx*2]  ; *3
0x83270d 8D04D0      lea eax,[eax+edx*8]  ; + (r-b)*24
0x832710 8945EC      mov [ebp-0x14],eax   ; record base
0x832713 8B45EC      mov eax,[ebp-0x14]
0x832716 8B5510...   mov edx,[ebp-0x10]   ; a
0x832719 8D0450      lea eax,[eax+edx*2]  ; + a*2
0x83271c 8A5508      mov dl,[ebp+8]       ; tile u8
0x83271f 881418      mov [eax+ebx],dl     ; record[a*2+b] = tile
```

Stride `*3*8 = 24` confirms the 24-byte record. Corner index is `a*2+b`; `a` selects the row pair, `b` the column within the pair.

### 3.4 Random byte and callback, then loops

```text
0x832722 B800010000  mov eax,0x100
0x832727 E8E012BDFF  call 0x403a0c        ; Delphi Random(256)
0x83272c 8B55EC      mov edx,[ebp-0x14]
0x83272f 884204      mov [edx+4],al       ; record+4 = variant
0x832732 8B4DF4      mov ecx,[ebp-0xc]
0x832735 8BD7        mov edx,edi
0x832737 8BC6        mov eax,esi
0x832739 E82E000000  call 0x83276c        ; TerrainChanged(rr,cc)
0x83273e 43          inc ebx
0x83273f 83FB02      cmp ebx,2
0x832742 758C        jne 0x8326d0         ; b loop
0x832744 FF45F0      inc dword [ebp-0x10]
0x832747 837DF002    cmp dword [ebp-0x10],2
0x83274b 7581        jne 0x8326ce         ; a loop
... pop edi/esi/ebx, mov esp,ebp, pop ebp, ret 4 ...
```

`0x83276c` (stepped): checks `*(word *)(eax+0x42)`, then indirect `call [ebx+0x40]` with the coordinates — a change notification, not a `record13` writer.

**Consequence:** for source vertex `(r,c)`:

| `a` | `b` | Target cell | Corner |
|---:|---:|---|---|
| 0 | 0 | `(r,c)` | `+0` |
| 0 | 1 | `(r-1,c)` or `(r,c-1)`* | `+1` |
| 1 | 0 | `(r,c-1)` or `(r-1,c)`* | `+2` |
| 1 | 1 | `(r-1,c-1)` | `+3` |

\* The two middle rows swap depending on which param is called `r` vs `c`; `DEC_VIS_04` §4 fixes the convention as `record[r-a,c-b].tag[a*2+b]`. The symmetry is exact — both are “one step back in one axis”. No code distinguishes faces, slopes, shores, or neighbours. The only condition is the two `0x50fba0` bounds tests on the **target** cell.

Per finished cell with source field `T`:

```text
cell[r,c].t0 = T[r,c]
cell[r,c].t1 = T[r,c+1]
cell[r,c].t2 = T[r+1,c]
cell[r,c].t3 = T[r+1,c+1]
```

---

## 4. Callers

### 4.1 The only proven `0x8326b8` caller: DScript `SetTileIndex`

Stepped wrappers (P4):

```text
0x6b1d50 push ebp / mov ebp,esp / call 0x705944 / cmp [eax+0x4c],0 / je 0x6b1d80
0x6b1d5e mov al,[ebp+0x10]   ; tile Integer -> u8 (narrowing, no [0,123] check)
0x6b1d75 mov ecx,[ebp+0xc]   ; j
0x6b1d78 mov edx,[ebp+8]     ; i
0x6b1d7b call 0x8326b8       ; <-- the setter
0x6b1d80 pop ebp / ret 0xc
0x6b1d0c ... call 0x705944 ... call 0x7101f8 ... call 0x82ec5c ... mov al,[ebp-0x18] ; GetTileIndex returns byte 0
```

`native_xrefs_list 0x8326b8` reports **0 references from / to** — expected because the function is undiscovered and high-VA cross-references are not in the clean-room index. This is a tool limitation, not evidence of no callers. The DScript path above is proven by direct disassembly; any additional native brush/pattern caller that reaches `0x8326b8` directly is **[U]** from the available index (no `objdump` engine in this environment; raw `E8`-rel scanning was not attempted to avoid false positives).

Donor-text callers all pass scalar ids (`texturemap.inc` shore/cliff/road, `smoothtiles.inc` write-back, `_misc_SetDesert`, detail bitmap): the fan-out is always in `0x8326b8`, never in script.

### 4.2 `sub_82ec5c`: the 24-byte reader and its 10 callers

Complete dossier `ev_f505b1a3…` (34 insns): bounds `edx vs [eax+4]`, `ebx vs [eax+8]`; in-bounds `lea ecx,[ebx+ebx*2]` + `lea esi,[row+ecx*8]` + `rep movsd ecx=6` (24 B); OOB copies the 24-byte default from `PTR [0x8fc33c] -> 0x8f6164`.

Direct callers `ev_01c4ba7a…`:

```text
sub_7203e4 @ 0x7204a2, 0x720d0b
sub_720da0 @ 0x720e44, 0x7211ab
sub_755920 @ 0x755a7f
sub_7d8a14 @ 0x7d9124, 0x7d91aa, 0x7d922e, 0x7d92b2
sub_812e34 @ 0x812fca   ; terrain-cell renderer/producer
```

`GetTileIndex` uses it and returns only `+0`; the renderer uses the full 24 B.

### 4.3 Serializer `0x8302b0` / `0x8305a0`

Both are undiscovered functions (address-show only) but step cleanly:

- `0x8302b0` (load): stream `read` (`vtable+0xc`) for `W/H`, `(W+1)^2` height floats, then per-cell 24 B + 13 B reads; sets tail `dirty=1`.
- `0x8305a0` (save): stream `write` (`vtable+0x10`) for `W/H`, `(W+1)^2` heights, then per-cell `ecx=0x18` (24 B) + `ecx=0x0d` (13 B) writes with `mov byte [eax+0xc],0` (clear dirty on save).

This confirms `DEC_VIS_04` §6: full height grid, interleaved 37-byte records, corrected anchors (`quad_pos-8`).

---

## 5. When the four tags differ

- **Interior uniform region:** all four covering vertices hold `T` → `[T,T,T,T]`. This is the `DEC_SMALL` uniform rule and matches all interior cells of shipped maps except boundary exceptions.
- **Transition border:** covering vertices hold different ids (e.g. grass source next to a sandsea source after shore selection, rock after cliff selection, desert remap, smoothing write-back, detail-bitmap sparse pass) → the cell records each neighbour’s id in its own corner. Example top-edge cell `[grass, sandsea, grass, sandsea]` is not computed — it is the residue of two different setter calls.
- **Map edges:** bounds on the target cell mean `(r,c)=(W,*)` / `(*,H)` can still write the last row/column through `a/b=1`; `(-1,*)` writes nothing. `GetTileIndex(W,*)` reads OOB default `0` while `SetTileIndex(W,*)` can write edge cells — an intentional asymmetry (see `DEC_VIS_04` §4.2).
- **Not a cause:** face direction (`bR/bRB/…`), slope/height, `tile_id` bit patterns, `record13` flags, or renderer LUT. Those are evaluated **before** (script id choice) or **after** (render mask) the setter, never inside `0x8326b8`. No `and/shr/test` on neighbours, no `0x8f5d00` LUT reference, and no second tile argument exist in the `0x8326b8` body.

---

## 6. Random / variant byte

### 6.1 Exact algorithm (`0x403a0c`)

Stepped P3 (11 insns):

```text
0x403a0c push ebx
0x403a0d xor ebx,ebx
0x403a0f imul edx,[ebx+0x8f2008],0x8088405
0x403a19 inc edx
0x403a1a mov [ebx+0x8f2008],edx
0x403a20 mul edx          ; edx:eax = eax * state
0x403a22 mov eax,edx
0x403a24 pop ebx / ret
```

With `eax=0x100` from `0x832722`:

```text
state = (state * 0x8088405 + 1) mod 2^32
return (256 * state) >> 32 = state >>> 24
```

`native_function_show ev_8582eec…`: 26 B, 1 block, 9 insns. 15 discovered callers `ev_be530cd5…`; the `0x8326b8` call site is undiscovered so it does not appear in that list (same high-VA index limitation).

### 6.2 `0x81272f` is not the source — refuted

Task context cited “random byte at `0x81272f`”. `native_data_show ev_ec4aa830…` places `0x81272f` in `CODE` with value `0x4cb90c00`; stepping `0x812710–0x81275f` yields:

```text
0x812710 hlt / 0x812711 test al,0x4c / 0x812719 sahf / ... / 0x81272f add [ecx+edi*4],cl / 0x812732 dec esp ...
```

This is data/constant bytes mis-decoded as instructions, not a live RNG byte. The per-record variant is `record+4` written at `0x83272f` (`mov [edx+4],al`). Any port use of `0x81272f` as randomness must be removed.

### 6.3 Seed and stream — [U] for generation-time values

- `DAT_008f2008` reads `0` in the image (`ev_4f8831fd…`); `FUN_004033b8` reseeds from `QueryPerformanceCounter` (fallback `GetTickCount`) per `DEC_VIS_04` §5.2.
- Separate from DScript `RandomExt` (`0x9048d4/0x9048d8`, `s*0xFC0D+0x3C6EF35F`).
- One draw per accepted cell write in `a`-outer/`b`-inner order; final `variant` = last writer’s draw. For a full `0..W`/`0..H` sweep the last writer of cell `(r,c)` is source `(r+1,c+1)`; `0..W-1` sweeps and later sparse passes change history.
- Exact generation-time seed/stream position is **[U]** from static bytes. Baked maps: ingest `+4` verbatim. Fresh generation: use a distinct Delphi LCG stream and label any fixed seed **PORT APPROXIMATION**.

`record13` override random (`+9`) is a separate Delphi draw in brush paths (`0x830d8c`/`0x830c68`), not the `record+4` stream position.

---

## 7. The 13-byte tail and its relation to the four tags

### 7.1 Layout (confirmed `DEC_VIS_04` §6)

```text
+0..+3  s8 corner values
+4..+7  u8 corner flags (2x2, index (subrow&1)*2+(subcol&1))
+8      override tile id
+9      override random
+10     signed mode/control (default 0xff)
+11     signed threshold/control (default 0xff)
+12     dirty/loaded flag (reader sets 1, writer clears 0)
```

Defaults: `record24@0x8f6164 = 00 00 00 00 00 00 00 00 | 00 00 80 3f x4`; `record13@0x8fab6c = 00*10 ff ff 00`.

### 7.2 `SetTileIndex` never touches it

`0x8326b8` writes only `tag[a*2+b]` and `variant+4` plus the `0x83276c` notification. No `+8`/`+9`/`+12` store, no `0x20`-table (`record13` row table at `terrain+0x20`) reference exists in its body. `GetTileIndex` never reads it.

### 7.3 Writers (stepped P5, consistent with `DEC_VIS_04` §8)

| Path | Exact write |
|---|---|
| New/reset map | Fill every tail with `00*10 ff ff 00` |
| Load/save | `0x8302b0` reads 13 B then `+12=1`; `0x8305a0` sets `+12=0` then writes 13 B |
| Pattern stamp (`sub_755f30` → `FUN_00755c6c` → `FUN_00755010` → `FUN_0082ed4c`) | If `CollisionStand`, copy 13-byte pattern tag record; rotate first 8 bytes with pattern angle |
| `0x830d8c` brush set | `mov [eax+edx],cl` (corner value) + `mov [edi+8],al` (override tile) + `call 0x403a0c` / `mov [edi+9],al` (fresh Delphi rnd) + `mov byte [edi+0xc],1` (dirty); full sequence `0x830e2f–0x830e48` stepped |
| `0x830c68` brush add | Signed delta to corner values; rewrite `+8/+9/+12` |
| `0x80ec30` (33 blocks, `ev_3b0f9b4b…`) | Bounds via `0x50fba0` + `0x82dff4` subcell resolve + `0x80e1a4/0x83068c/0x80e26c` helpers; clears one of `+4..+7` and sets `+12=1` |
| `0x830bf8` threshold | If signed `+10>=0` and `+11 < max(+0..+3)`, set `+10=0xff`, `+12=1` |

`0x82dff4(coord,0,…)` subcell rule (even `coord-1..coord`, odd `coord..coord+1`) and corner index `(subrow&1)*2+(subcol&1)` match the 24-byte corner ordering.

### 7.4 Render-time relation (the only tag interaction)

`0x830754` loops the clipped subcell block, checks `terrain+0x30` object table, and calls `0x830818` per corner. `0x830818` (stepped):

```text
bounds via 0x50fba0; eax = [ebx+0x20][...]; al = [eax+edx*0xd+8]  ; record13+8
if (al > 0x80 unsigned) scan 3x3 neighbourhood for (s8)+8 >= 0 ...
return override tile or 0xffffffff
```

`0x830754` writes the returned byte to the caller’s out-param when an associated object is active (`cmp [eax+0xa4],0` gate stepped at `0x8307e4`). `sub_812e34` then sorts distinct final tags and builds the occupancy mask (`t0=8,t2=4,t1=2,t3=1`, base/full handling, 16-entry LUT at `0x8f5d00`).

So: **13-byte flags never create tags; they can only substitute one corner id at render time when the object-override gate fires.** Shipped maps (all default tails) never exercise this path in their serialized bytes.

Flag-enum names for `+4..+7` and control names for `+10/+11` remain **[U]** — byte accesses and behaviours are proven, authoritative field names are not recovered.

---

## 8. Port recommendations for alpha layers

1. **Data model.** Per cell store `tags[4]:u8`, `variant:u8`, `collision[4]:u32`, plus `rec13_vals[4]:s8`, `rec13_flags[4]:u8`, `rec13_override:u8`, `rec13_ornd:u8`, `rec13_ctl[2]:s8`, `rec13_dirty:u8`. Keep scalar `tex` only as a diagnostic or as the source-vertex field for fresh generation (`vertex_tiles[W+1][H+1]` or ordered `set_tile_calls` log).
2. **Setter.** Implement exactly:
   ```text
   set_tile(r,c,tile):
     for a in 0..1:
       for b in 0..1:
         rr=r-a; cc=c-b
         if 0<=rr<W and 0<=cc<H:
           cell[rr,cc].tags[a*2+b]=tile & 0xff
           cell[rr,cc].variant=delphi_random(256)  # separate LCG stream
           mark_dirty(rr,cc)
   ```
   Bounds on the **target** cell; `a`-outer/`b`-inner order; `get_tile(r,c)` returns `tags[0]` or `0` OOB.
3. **Variant.** Never consume DScript `RandomExt` for `+4`. Baked maps: copy bytes. Fresh maps: instantiate the Delphi LCG (`state=state*0x8088405+1`, `byte=state>>>24`) as its own stream and expose seed/state explicitly as **PORT APPROXIMATION**.
4. **Do not port `0x81272f`.** It is not randomness; remove any use.
5. **Layers.** Per cell: apply `rec13` object override only through the `0x830754`/`0x830818` gate; `distinct=sorted_unique(final_tags)`; mask bits `t0=8,t2=4,t1=2,t3=1`; base/full rule (`count==1 or id==distinct[0] or mask==0xf → 0xf`); patch = `AlphaLUT[mask]` keyed by `variant`; emit one layer per distinct id. Never decompose `tile_id` bits into masks.
6. **Uniform fast path.** `[T,T,T,T]` → single opaque layer; skip transition patches. Split cells → 2–4 ordered layers with the LUT patch above.
7. **Importer.** Anchor at `quad_pos-8` (four `1.0f` at record `+8`); read full `(W+1)^2` heights; stride 37 B; preserve `+5..+7`, all collision words, all `rec13` bytes, and boundary exceptions verbatim.
8. **Tests.** One interior setter write touches exactly 4 records at offsets `0,1,2,3`; `(W,H)` writes only edge cells; `(-1,*)` writes nothing; OOB get returns `0`; known LCG state yields `state>>>24` in exact loop order; full-sweep variant history differs on right/bottom edge vs full-vertex sweep; shipped anchors in `DEC_VIS_04` §7 parse cleanly; interior shared-corner invariants hold with only boundary exceptions.

---

## 9. UNVERIFIED register

| ID | Item | Status |
|---|---|---|
| DEC-DEEP-U1 | Additional direct native callers of `0x8326b8` beyond DScript `0x6b1d50` | **[U]** Built-in xrefs report 0 for undiscovered high VAs; only the DScript path is proven by disassembly. No other caller is claimed. |
| DEC-DEEP-U2 | Delphi RNG seed/stream position at any generation start | **[U]** Algorithm proven; image state `0`, runtime QPC/tick reseed, shared stream with other engine calls. Needs runtime capture. |
| DEC-DEEP-U3 | Semantic names for `rec13 +4..+7` flags and `+10/+11` controls | **[U]** Accesses proven; authoritative enum/field names not recovered. |
| DEC-DEEP-U4 | Exhaustive indirect writers of `rec13` flags | **[U]** Direct `FUN_0082ed4c` callers + `0x830d8c/0x830c68/0x80ec30` paths censused; computed-pointer writes not proven absent. |
| DEC-DEEP-U5 | Face ids `rockNvf/vs`, `sandNf/s` as active generation output | **[U]** No active donor text or native setter special-case found; treat as separate material variants, not setter promotion. |
| DEC-DEEP-U6 | Donor visual parity | **[U]** No GPU A/B frame; no parity claim. |

---

## 10. Bottom line

The rule the port asked for is vertex fan-out, not per-cell expansion: `SetTileIndex(r,c,T)` writes `T` into corner `a*2+b` of each in-bounds cell `(r-a,c-b)` and refreshes that cell’s Delphi variant byte. Four equal tags mean four equal neighbours; any split means the neighbours disagreed — shore against grass, rock against grass, desert remap, smoothing write-back, or an edge/sparse overwrite. The 13-byte tail lives on a separate channel and only substitutes a corner at render time under the object-override gate.

Implement four tags plus ordered variant history (or ingest baked bytes), sort distinct tags, and drive alpha layers from the occupancy mask — not from one `tex` value.

*End of DEC-DEEP. Files written: this report only. Donor read-only; no binary executed/copied; no code, shader, config, asset, test, git or Godot state changed. No parity claim.*
