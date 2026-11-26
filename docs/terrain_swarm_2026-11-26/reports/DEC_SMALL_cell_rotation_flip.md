---
id: DEC-SMALL-02
ticket: "TERRAIN-SWARM-2026-11-26 / DEC-SMALL cell_rotation_flip"
title: "Donor terrain cell rotation / V-flip: source and corner mapping (read-only)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY
owner_file: docs/terrain_swarm_2026-11-26/reports/DEC_SMALL_cell_rotation_flip.md
targets:
  - "C:\\Games\\Cossacks 3\\cossacks.exe — t_87f0f3c130b0"
labels: [D, U]
parity_claim: false
scope_guard: "Donor READ ONLY. No donor executable run, copied, committed or modified. No repo code/shader/config/asset/test/git/Godot change. Exactly one repo file written: this report."
---

# DEC-SMALL — cell rotation / V-flip source and corner mapping

Resolves the open item from `DEC_VIS_01_uv_mapping.md` §7.1:
"The four corners are then rotated by the cell's rotation metadata and optionally
V-flipped … The exact runtime source of `cellRotation/cellFlip` is not recovered here **[U]**."

**Answer in one paragraph:** there is no per-cell rotation metadata in this producer.
The 2-bit rotation, the corner-order mirror, and the V-flip are **per-branch immediate
constants** pushed at the three UV-emit call sites inside `sub_812e34`
(`cossacks.exe`, `t_87f0f3c130b0`). They reach the corner helpers through a
frame-pointer passing trick (`push ebp` before the helper call), **not** through the
24-byte cell record, **not** through the 13-byte record, and **not** through the
material-descriptor bytes. Corner mapping is exactly
`slot = (corner + rot) & 3`, optionally `slot = 3 - slot`; V-flip is exactly
`v := 1.0 - v`. No parity claim is made.

## 1. Method (three passes, static only)

- Pass 1 — re-read `DEC_VIS_01_uv_mapping.md`; fetched `sub_812e34` disassembly
  (`ev_58d7418c…`, pre-existing) and Deep pseudocode (`ev_ceb19ad8…`,
  `FUN_00812e34`), plus pseudocode for `FUN_00812b4c` (`ev_6f767eed…`),
  `FUN_00812ccc` (`ev_e9694d0d…`), `FUN_00812b14` (`ev_da0c76f0…`),
  `FUN_00812c94` (`ev_2cc36770…`), `FUN_0082e2f4` (`ev_3498f84b…`),
  `FUN_0050db08` (`ev_70c790f9…`).
- Pass 2 — walked raw instructions of `FUN_00812b14` (`0x812b14`,
  entries `ev_235ca58a…`, `ev_8ea7f240…`, `ev_943ea4f6…`, `ev_7fc4ec4b…`)
  and `FUN_00812b4c` head (`0x812b4c`); builtin xref coverage check
  (`ev_60bf85d8…`: zero recorded xrefs — these addresses sit outside the
  builtin function DB, same limitation as DEC-VIS-01 §1).
- Pass 3 — walked raw call-site bytes `0x813188–0x813390` inside `sub_812e34`
  (push sequences + `call 0x812b4c` / `call 0x812ccc`) and read the flip
  constants at `0x812c90` (`ev_4be0c95b…`) and `0x812e30` (`ev_58eb274e…`).

## 2. Corner mapping (exact, byte-proven) [D]

`FUN_00812b14` at `0x812b14` (RGB helper), raw:

```text
0x812b14 push ebp
0x812b15 mov ebp, esp
0x812b17 mov edx, [ebp+8]            ; P = caller-passed frame pointer
0x812b1a cmp byte ptr [edx+0xc], 0   ; mirror flag
0x812b1e jne 0x812b33
0x812b20 and eax, 0xff               ; corner index (in EAX)
0x812b25 mov edx, [ebp+8]
0x812b28 movzx edx, byte ptr [edx+0x14] ; rotation byte
0x812b2c add eax, edx
0x812b2e and eax, 3
0x812b31 pop ebp / ret               ; slot = (corner + rot) & 3
0x812b33 and eax, 0xff
0x812b38 mov edx, [ebp+8]
0x812b3b movzx edx, byte ptr [edx+0x14]
0x812b3f add eax, edx
0x812b41 and eax, 3
0x812b44 mov dl, 3
0x812b46 sub dl, al
0x812b48 mov eax, edx / pop ebp / ret ; slot = 3 - ((corner + rot) & 3)
```

`FUN_00812c94` at `0x812c94` (alpha helper) is instruction-for-instruction the
same shape (`0x812c97 mov edx,[ebp+8]`, `0x812c9a cmp byte ptr [edx+0xc],0`,
`0x812ca8 movzx edx,byte ptr [edx+0x14]`, mirror leg at `0x812cb3`;
`ev_2cc36770…`). Deep pseudocode of both is identical
(`ev_da0c76f0…`, `ev_2cc36770…`).

V-flip is a separate, independent step in the UV writers, gated by each writer's
own stack slot `[ebp+0x10]`:

- RGB (`FUN_00812b4c`, e.g. `0x812ba6 cmp byte ptr [ebp+0x10],0` /
  `fld [0x812c90]` / `fsub`): `v := C - v`.
- Alpha (`FUN_00812ccc`, same pattern with `[0x812e30]`): `v := C - v`.

`0x812c90` and `0x812e30` both contain `00 00 80 3F` = `1.0f`
(`ev_4be0c95b…`, `ev_58eb274e…`). So V-flip is exactly `v := 1.0 - v`.

Base corner order (unchanged from DEC-VIS-01 §7.1): slots 0..3 correspond to
`(x,y)`, `(x+64,y)`, `(x+64,y+64)`, `(x,y+64)`; writer strides 8 bytes
(`lea eax,[ebx+eax*8+5]` RGB, `lea eax,[ebx+eax*8+0x25]` alpha).

## 3. Runtime source: per-branch constants, not cell metadata [D]

The helpers take no explicit rotation pointer argument. Every call site does
`push ebp` immediately before `call 0x812b14 / 0x812c94`
(RGB: `0x812b7b`, `0x812bb9`, …; alpha: `0x812ce9`, …), so the helper's
`[ebp+8]` is the **caller's frame pointer**, and `[P+0xc]` / `[P+0x14]` are the
caller's own stack slots: mirror flag = writer arg at `[ebp+0xc]`,
rotation = writer arg at `[ebp+0x14]`, V-flip = writer arg at `[ebp+0x10]`
(the slot tested directly by the writer body). The writer's output context
likewise arrives as the caller's frame (`[ebp+0x28]` = caller EBP;
`edx = [edx-4]` = output layer base; alpha insets at `[edx-8]`/`[edx-0xc]`).

`sub_812e34` pushes literal immediates for all three slots at all three UV-emit
call sites (frame slot order `[ebp+8],[+0xc],[+0x10],[+0x14]` = last four pushes):

| Call site in `sub_812e34` | Pushes (first→last) | mirror `[+0xc]` | V-flip `[+0x10]` | rot `[+0x14]` | Corner mapping |
|---|---|---|---|---|---|
| RGB, mask/full-variant branch, `call 0x812b4c` at `0x813227` (pushes `0x813210–0x813216`: `0,1,0,0`) | `0,1,0,0` | 0 | 1 | 0 | identity; `v := 1-v` |
| RGB, tsDouble branch, `call 0x812b4c` at `0x8132c3` (pushes `0x8132ac–0x8132b2`: `0,0,1,0`) | `0,0,1,0` | 1 | 0 | 0 | `slot = 3 - corner`; no V-flip |
| Alpha, tsDouble branch, `call 0x812ccc` at `0x813380` (pushes `0x81336a–0x813370`: `2,1,0,1`) | `2,1,0,1` | 0 | 1 | 2 | `slot = (corner+2) & 3`; `v := 1-v` |

Consistent with Deep `FUN_00812e34` (`ev_ceb19ad8…`): branch 1 passes
`(uVar14=0, uVar15=0, uVar16=1, uVar17=0)`; branch 2 passes `(0,1,0,0)`;
alpha passes `(p4=1, p5=0, p6=1, p7=2)`. The path selector itself is the material
entry byte `[edi+0xc]` (`0x813155 mov al,[edi+0xc]` / `sub al,1`: `0 → 0x813167`
mask path, `1 → 0x813235` tsDouble path) — a **different** `+0xc` from the
helper's frame slot; do not conflate them.

## 4. The 13-byte record does not supply rotation [D]

`sub_812e34` reads the 13-byte record via `FUN_0082ed00` (call at `0x812eb2`)
into a stack buffer passed only to `FUN_0082e078` (call at `0x812eba`).
No byte of that buffer reaches any of the three UV call sites above: the only
per-cell bytes consumed downstream are the four corner tags and the random byte
(`[ebp-0x44]` → `FUN_0050db08`/`FUN_0050daec` LUT parity, `ev_70c790f9…`).
The hypothesised "13-byte record rotation/flags byte" has **no static consumer
in this producer** — rejected for `sub_812e34`. (Full semantics of 13-byte
`+9..+0xb` remain what DEC-VIS-01 DEC-U4 says: unrecovered.)

## 5. UNVERIFIED register ( مباراة small additions to DEC-VIS-01 DEC-U1..U8)

- **[U-S1] Other callers.** Builtin xref DB has no coverage of
  `0x812b14/0x812b4c/0x812c94/0x812ccc` (`ev_60bf85d8…` total_to=0;
  `function_not_found` for `0x812b4c`), so further static callers passing
  different rotation constants cannot be enumerated here. Only the three
  `sub_812e34` sites above are proven.
- **[U-S2] Loader origin of the path byte.** Which script/material load writes
  descriptor `+0xc` (mask vs tsDouble) is unchanged [U] (loader `FUN_00544548`
  per DEC-VIS-01; not re-examined — out of scope for this small job).

## 6. Bottom line

Port guidance (no parity claim): UV corner order needs no per-cell rotation
field from the terrain records. Emit RGB corners in identity order for
mask/full-variant layers with `v := 1-v`; mirrored (`3 - corner`) without V-flip
for tsDouble RGB; rotated by 2 (`(corner+2) & 3`) with `v := 1-v` for tsDouble
alpha. The random byte still feeds only the patch LUTs, never rotation.

*End of DEC-SMALL cell_rotation_flip. Files written: this report only. Donor
read-only; no binary executed/copied; no code, shader, config, asset, test, git
or Godot state changed. No parity claim.*
