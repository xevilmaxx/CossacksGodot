---
id: DBIND-01
title: "DBIND-01 — read-only decode attempt on the packed .bind / WUS container"
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_DONOR_EXECUTED__NO_DONOR_COPIED__ONE_REPORT_ONLY
scope: "Exactly one report written. No repo code/config/asset/test/scene/shader/git edit, no runner job, no Godot run, no donor binary executed, unpacked or copied into the repo."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
donor: "C:\\Games\\Cossacks 3 (READ-ONLY; Python 3.14 bytes/struct/latin-1; capstone used for STATIC disassembly only; Craft Anything read tools; never executed)"
output: "docs/coord_swarm_2026-11-25/reports/DBIND_01_wus_bind.md"
labels: [observed, derived, inferred, UNVERIFIED]
methods:
  - "M-A independent PE section-header parse + whole/4K Shannon entropy + head/tail hex dumps"
  - "M-B cross-binary .bind byte equality by region + magic/string census + zlib/bz2/xz candidate scan + decompression attempts"
  - "M-C autocorrelation, byte-distribution baseline, XOR/ADD key-bias tests, long-run detection"
  - "M-D static (never executed) capstone x86 disassembly of the plaintext stub; PE/API-hash recognition"
  - "M-E Craft Anything core_packed_files_list / core_target_triage / app_folder_explain cross-check"
  - "M-F brute-force raw-deflate and raw-LZMA1 starts across the packed payload"
verdicts:
  eye_planes_RV_TRN_01: CONFIRMED_INFEASIBLE
  fov_RV_CAM_01: CONFIRMED_INFEASIBLE
  selection_predicate_RV_SEL_01: CONFIRMED_INFEASIBLE
dec_01_claim: "PARTIALLY CONFIRMED, PARTIALLY CORRECTED — encrypted payload is unverified, but .bind contains a large READABLE shared loader stub"
external_corroboration: "CODEX Steam-emu marker SHELL32.dll -> CODEX.!WUS! (web, GitHub issue) — inferred support only; donor bytes authoritative"
---

# DBIND-01 — packed `.bind` / WUS container: decode attempt and verdicts

## 0. Goal

Attempt a **read-only** decode of the donor's packed `.bind` / WUS regions to recover the three
constants that three prior reports left UNVERIFIED solely because they might live in packed code:

1. ground `gl_EyePlaneS[0]` / `gl_EyePlaneT[0]` / `gl_TextureMatrix[0]` values (RV-TRN-01 item A);
2. the numeric FOV / focal-to-projection conversion (RV-CAM-01 claim 3);
3. the native selection inside-box predicate (RV-SEL-01 open question 1).

Deliver either exact values with `path:offset`, or a byte-level proof of infeasibility. Independently
confirm or refute DEC-01's "packed content UNVERIFIED" claim. No donor file was executed, and no
donor bytes were copied into the repository.

Every byte claim below carries a **file offset** in `path:0x...` form (hex). Section-relative
offsets are written `.bind+0x...` with the corresponding file offset given at first use.
Labels: **observed** (literal byte/disassembly), **derived** (arithmetic/statistics on observed
bytes), **inferred** (interpretation with caveat), **UNVERIFIED**.

---

## 1. Sources

**Required prior reports (all read first):**

- `docs/coord_swarm_2026-11-25/decomp/DEC_01_binaries_rtti.md` (the brief's bare path
  `decomp/DEC_01_binaries_rtti.md` does not exist; the file lives under
  `docs/coord_swarm_2026-11-25/decomp/`).
- `docs/coord_swarm_2026-11-25/reports/RV_TRN_01_texgen_mask_reverify.md`
- `docs/coord_swarm_2026-11-25/reports/RV_CAM_01_fov_resolution.md`
- `docs/coord_swarm_2026-11-25/reports/RV_SEL_01_selection_reverify.md`

**Fresh donor reads this session (all read-only):**

- `C:\Games\Cossacks 3\cossacks.exe`, `.cdx`, `editor.exe`, `.cdx`, `config.exe`, `.cdx`,
  `modman.exe`, `.cdx`, `codex.dll` — whole files via `open(p,'rb').read()`; PE headers parsed
  independently of DEC-01 (M-A).
- Scripts in `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\`:
  `dbind01_struct.py`, `dbind01_scan.py`, `dbind01_transform.py`, `dbind01_disasm.py`,
  `dbind01_brute.py`, `dbind01_pe.py`, `dbind01_stub.py`, `dbind01_stub2.py`,
  `dbind01_stub3.py`, `dbind01_final.py`, `dbind01_last.py`, `dbind01_keys.py`.
  `capstone 5.0.9` was pip-installed **into that temp directory only** (`...\Temp\opencode\pylibs`)
  for static disassembly; no donor code was run.
- Craft Anything read tools (M-E): `core_packed_files_list`, `core_target_triage`,
  `app_folder_explain`.
- External, **supporting only**: web search identified `codex.dll`'s `WUS` marker as the CODEX
  Steam-emulator DLL-name redirection (`SHELL32.dll` → `CODEX.!WUS!`), documented in a GitHub
  issue on the CODEX Steam emulator. This explains the name; donor bytes remain authoritative.

---

## 2. Section / entropy maps (M-A)

Independent PE parse (DOS `e_lfanew`, COFF, optional header, 40-byte section headers) reproduced
DEC-01's header values and adds a **per-4K** entropy profile (all numbers **observed/derived**):

| File | Section | RVA | rsize | file raddr | whole-section entropy | 4K-block entropy profile |
|---|---|---:|---:|---:|---:|---|
| `cossacks.exe` | `CODE` | `0x1000` | 5,180,928 | `0x400` | 6.609 | (statically analysed before) |
| `cossacks.exe` | `.rsrc` | `0x54c000` | 128,000 | `0x53d200` | 5.081 | — |
| `cossacks.exe` | **`.bind`** | `0x56c000` | **146,800** | **`0x55c600`** | **7.9648** | `6.27, 5.58, 6.35, 7.96, 7.96, … 7.95` (36 blocks) |
| `editor.exe` | **`.bind`** | `0x76f000` | 146,800 | `0x75ea00` | 7.9649 | `6.21, 5.58, 6.36, 7.95, … 7.94` |
| `config.exe` | **`.bind`** | `0x458000` | 146,800 | `0x44a600` | 7.9651 | `6.26, 5.58, 6.34, 7.95, … 7.93` |
| `modman.exe` | **`.bind`** | `0x42c000` | 146,800 | `0x41e000` | 7.9636 | `6.23, 5.58, 6.34, 7.96, … 7.93` |
| `codex.dll` | `WUS0` | `0x1000` | **0** | `0x400` | 0.000 | virtual size 0x31000, flags `0xe0000080` |
| `codex.dll` | **`WUS1`** | `0x32000` | 101,376 | **`0x400`** | **7.9051** | 25 blocks, 7.70–7.88; last block 6.75 (zero tail) |

**Critical observation (derived).** The whole-section entropy of ~7.965 is an *average that hides a
two-region structure*: the first three 4K blocks are 5.58–6.35, the remaining ~134 KB is 7.94–7.96.
DEC-01's uniform "high-entropy stub" description is therefore only true of the tail.

**Section boundary bytes (observed).** `cossacks.exe:0x55c5e0..0x55c5ff` (last 32 bytes before
`.bind`) are all `00`; `cossacks.exe:0x55c600` begins
`25 99 bb dd 4a fa bb bb 38 9f de bb 4e ec ae c9 …`. `codex.dll:0x400` begins
`25 dd df ff e8 0a 00 08 46 68 00 03 21 66 12 20 …`. No magic, table or file marker sits at
either boundary — these are raw payload bytes, not a container header.

**Entry redirect (observed, independently re-derived).** `cossacks.exe:0x128` =
`08 1a 4f 00` (RVA `0x4f1a08`, in `CODE`); `cossacks.cdx:0x128` = `10 c3 56 00`
(RVA `0x56c310` = `.bind+0x310`, file `0x55c910`). The same `+0x310` holds for editor
(`0x76f310`), config (`0x458310`) and modman (`0x42c310`). SHA-256 values independently
recomputed match DEC-01 §3 exactly (e.g. `cossacks.exe`
`87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c`).

---

## 3. `.bind` / WUS structure findings

### 3.1 Three-region layout — the central new result

Cross-binary byte equality by region (M-B; fraction of identical bytes at the same offset,
six pairs of the four EXEs, **derived**):

| Region | Size | Cross-binary equality | Interpretation |
|---|---:|---:|---|
| `.bind+0x0000..0x02ff` (`cossacks.exe:0x55c600..0x55c8ff`) | 768 B | **0.0000** | per-binary encrypted/obfuscated header |
| `.bind+0x0300..0x2bff` (`cossacks.exe:0x55c900..0x55f1ff`) | 11,264 B | **0.9840–0.9841** | **shared plaintext x86 loader stub** |
| `.bind+0x2c00..0x23d6f` (`cossacks.exe:0x55f200..0x58036f`) | 135,536 B | **0.0036–0.0042** | per-binary high-entropy payload |

The whole-section equality previously measured as ~7.4 % is fully explained by the middle
region: `0.077 × 0.984 + 0.923 × 0.0039 ≈ 0.080`. It is **not** evidence of a shared cipher.

**Inferred layout:** a 768-byte per-binary header, a common plaintext self-relocating loader of
~11.25 KB, then a per-binary encrypted/compressed payload. This is consistent with the entropy
profile of §2 and with the `.cdx` entry landing *inside* the plaintext region.

### 3.2 The plaintext stub is readable x86 (correction to DEC-01)

Static capstone disassembly (M-D, never executed):

- `.bind+0x310` (`cossacks.exe:0x55c910`), the `.cdx` entry, is a valid position-independent
  prologue: `e8 00 00 00 00` (`call +0x315` to capture EIP), then
  `50 53 51 52 56 57 55` (push eax/ebx/ecx/edx/esi/edi/ebp),
  `8b 44 24 1c` / `2d 05 00 00 00` (recover `0x310` from the return address),
  `8b cc` / `83 e4 f0` (align stack), `e8 6d 00 00 00` (`call +0x3a0`), epilogue and `c3`.
  **Observed**; this is a conventional self-relocating entry stub, not an opaque blob.
- `.bind+0x347` (`cossacks.exe:0x55c947`) is a second similar stub with per-binary immediates:
  `81 ea 56 54 be 1a` (`sub edx,0x1abe5456`) at `cossacks.exe:0x55c95b`, then
  `8b 12` (`mov edx,[edx]`), `81 f2 f3 fa ff f7` (`xor edx,0xf7fffaf3`) at
  `cossacks.exe:0x55c963`. The four EXEs carry four different 32-bit pairs here:
  game `0x1abe5456 / 0xf7fffaf3`, editor `0x11e9e23e / 0x24bdba92`,
  config `0xb14821d7 / 0xcc28285b`, modman `0x502dfcaf / 0xf2739262` (**observed**,
  `cossacks.exe:0x55c95b`, `editor.exe:0x75ed5b`, `config.exe:0x44a95b`,
  `modman.exe:0x41e35b`). **Inferred**: per-binary obfuscation/pointer keys; their role is
  UNVERIFIED.
- `.bind+0x400..0x17ff` (`cossacks.exe:0x55ca00..0x55e1ff`): 1,161 consecutive decoded
  instructions, **0 %** privileged/nonsense opcodes (`cli`, `salc`, `daa`, `in`, `hlt`, `int3`,
  …). `.bind+0x1c00..0x1fff` (`cossacks.exe:0x55e600..0x55e9ff`): 244 more, also 0 %.
  By contrast `.bind+0x0000..0x0089` has 12.7 % and `.bind+0x0300..0x03ff` has 24.5 % such
  opcodes — i.e. the first 0x300 bytes and scattered islands are *not* code. (**derived**)
- The code is a **manual PE mapper / API resolver**. Four `PE\0\0` byte hits in each `.bind`
  are *not embedded PE files*; they are `81 39 50 45 00 00` = `cmp dword ptr [ecx],0x4550`
  immediate operands at `.bind+0x9f4`, `+0x1499`, `+0x1db0`, `+0x20d1`
  (`cossacks.exe:0x55cff4`, `0x55da99`, `0x55e3b0`, `0x55e6d1`). The surrounding code reads
  `0x5a4d` (`MZ`), adds `[header+0x3c]` (`e_lfanew`), checks `Machine == 0x14c` and
  `SizeOfOptionalHeader == 0xe0`, then walks `PE+0x78` (the data-directory array) — all
  **observed** static disassembly. No preceding `MZ` has `e_lfanew` pointing at them
  (**observed** absence, `dbind01_pe.py`).
- API names are resolved by a **hash loop** with a custom 32-bit constant
  `81 f2/f1 ed 81 87 48` = `xor reg,0x488781ed` repeated at `.bind+0x1204`, `+0x12a6`,
  `+0x134d`, `+0x13f1` (`cossacks.exe:0x55d804`, `0x55d8a6`, `0x55d94d`, `0x55d9f1`), inside
  `shl reg,1` / conditional-XOR sequences — i.e. a CRC-style bit loop. Bit-reversal of
  `0x488781ed` is `0xb781e112`, which is **not** standard CRC-32/32C/IEEE (derived); the exact
  hash model is **UNVERIFIED**.
- A 223-byte zero run at `.bind+0x2a91` (`cossacks.exe:0x55f091`), immediately after a
  plausible epilogue `33 c0 5e 8b e5 5d c3` (`xor eax,eax; pop esi; mov esp,ebp; pop ebp; ret`),
  marks the end of the stub region (**observed**).
- Only five short byte-runs differ between the game and editor stub: `+0x300..0x30f`
  (16 B), `+0x35b..0x35e` (4 B), `+0x363..0x366` (4 B), `+0x2b70..0x2bbd` (78 B) and
  `+0x2bbf..0x2bff` (65 B) — **derived**, `dbind01_last.py`. The two 78/65-byte blocks are
  high-entropy per-binary material (**observed**, `cossacks.exe:0x55f170`, `:0x55f1bf`);
  **inferred** to be key/identity data, role UNVERIFIED.

### 3.3 `codex.dll` / WUS is not a container either

- `codex.dll:0x1f8` = `WUS0` (rsize 0, vsize 0x31000, flags `0xe0000080`);
  `codex.dll:0x220` = `WUS1` (raddr `0x400`, rsize 101,376, flags `0xe0000040`);
  `codex.dll:0x400` begins `25 dd df ff …`; entry RVA `0x4a7d0` lies in `WUS1`
  (**observed**).
- Export directory at `codex.dll:0x19810`: 2 functions `ShellExecuteA` / `ShellExecuteW`
  at RVA `0x32266` / `0x32244` (file `0x666` / `0x644`). Their first bytes
  `8f b3 05 5b 08 33 …` / `89 02 59 06 73 b1 …` do not decode as a clean export thunk
  (**observed** + **inferred**); a few x86 fragments exist inside `WUS1` (e.g. a strlen-like
  loop at `codex.dll:0x490`: `80 38 00 75 04 33 c0 8d 50 01 8a 08 40 84 c9 75 f9`,
  and `c2 04 00` = `ret 4` at `codex.dll:0x4c2`) but there is no readable member table.
- No `WUS`, `CODEX`, `.dll`, `.exe` or `PE\0\0` string/magic inside `WUS1`; only 2 incidental
  `MZ` byte pairs (**observed** absence, `dbind01_keys.py` / `dbind01_brute.py`).
- The `WUS` name is corroborated externally as the CODEX Steam-emulator marker (web), which
  explains `codex.dll`'s `wus.dll` export name and `steam_api.dll`'s
  `CODEX\0!WUS!\0` redirection at `steam_api.dll:0x2d6a4` (**observed** there; role **inferred**).

---

## 4. Decode attempts and results (M-B, M-C, M-F)

All attempts operated on raw bytes only; nothing was executed or written to the repo.

| Attempt | Method | Result | Label |
|---|---|---|---|
| zlib/gzip/bz2/xz header census over all 5 files | valid `78 ?` CMF/FLG (checksum), `BZh[1-9]`, `fd 37 7a 58 5a 00` | **0 valid candidate headers** in any file (**cossacks.exe**, **editor.exe**, **config.exe**, **modman.exe**, **codex.dll**) | observed (absence) |
| raw-deflate brute force at every plausible start | `zlib.decompressobj(-15)` at 109,723 offsets of `cossacks.exe:.bind` (and 109,739 editor, 77,629 `WUS1`) | 48 / 36 / 47 outputs ≥64 B, all repetitive garbage (e.g. `]]]]]]]]…`, `…cccc…`); **no container member** | derived |
| raw LZMA1 brute force, 3 dict sizes (64 K, 1 M, 8 M), `lc=3 lp=0 pb=2`, every payload offset | `lzma.LZMADecompressor(FORMAT_RAW)` | **0 successes** across all sizes/offsets | derived |
| repeating-key XOR / ADD bias, key lengths 1,2,4,8,16,32,64 | best column frequency per key offset | max 2.53 % at keyLen 64 vs ~0.39 % uniform baseline; no column resembling plaintext (`0x00`/space dominance) — consistent with random/encrypted | derived |
| autocorrelation of `.bind` at lags 1..256 + selected | equal-byte fraction | lag-1 = 1.81 %, median 0.89 %, min 0.39 %; no strong periodic key | derived |
| embedded archive/PE magic inside `.bind` / `WUS1` | `MZ`, `PE\0\0`, `PK\x03\x04`, `7z`, `Rar!`, XZ, `!WUS!`, `OSWPak` | `PE\0\0` ×4 explained as **code immediates** (§3.2); `MZ` ×6/×2 are incidental byte pairs; no archive magic | observed + derived |
| target constant sweep in all packed regions | case-insensitive ASCII + UTF-16LE for 21 tokens (`gl_EyePlaneS`, `EyePlaneS/T`, `gl_TextureMatrix`, `GetCameraFieldOfViewByFocalLength`, `viewportdimension`, `Sensor`, `FocalLength`, `17.27`, `2.899`, `0.005`, `GameManagerStartSelection`, `GetGameObjectSelectionSizeByHandle`, …) | **NONE** in any of the five packed regions | observed (absence) |
| Craft Anything container check (M-E) | `core_packed_files_list` on `cossacks.exe`, `cossacks.cdx`, `editor.exe`, `codex.dll` | all refused: `{"code":"not_supported","message":"This file doesn't carry files in any way we recognise."}` — independent reproduction of DEC-01 `D1E29` | observed |
| Craft Anything folder check (M-E) | `app_folder_explain` on `C:\Games\Cossacks 3` | 17,528 entries examined, complete; "native code, no bigger runtime recognised" — no packer/archive identified | observed |
| Craft Anything triage (M-E) | `core_target_triage` on 4 targets | "appears to be packed or protected"; evidence cited is section entropy — tool labels its own packer hint **weak** | observed / inferred |

### 4.1 Decoded members

**None.** No container, member table, file list, embedded PE, compressed stream or plaintext
script/shader was recovered from `.bind` or `WUS1`. The only readable content is the shared
loader stub described in §3.2, and it contains no engine values — only PE-parsing control flow,
API-hash arithmetic and per-binary keys. No unpacked code was executed at any point.

---

## 5. Verdicts on the three unresolved constants

All three verdicts are **CONFIRMED_INFEASIBLE by static read-only means**. This is not a claim
that the values do not exist at runtime; it is a byte-level demonstration that no static route
in the packed regions yields them, and that no readable donor source contains them (per the
three prior reports). No value was invented.

### 5.1 Eye planes / texture matrix (RV-TRN-01 item A)

**CONFIRMED_INFEASIBLE** (no exact value recovered).

Byte-level reasons:

1. `gl_EyePlaneS[0]`, `gl_EyePlaneT[0]`, `EyePlaneS`, `EyePlaneT` have **0** hits in all five
   packed regions (M-F sweep; case-insensitive ASCII + UTF-16LE) and 0 hits across the 12
   binaries and 16,564 donor text files per RV-TRN-01 §3.
2. The only readable material in `.bind` is the loader stub
   (`cossacks.exe:0x55c900..0x55f1ff`), which contains no matrix/plane assignment — it parses
   PE headers and resolves API hashes (§3.2).
3. The ~135 KB per-binary payload (`cossacks.exe:0x55f200..0x58036f`) has entropy ~7.95,
   cross-binary equality ~0.4 %, no compression header, no archive table, and no simple
   XOR/ADD key (§4). Its decode algorithm is not identifiable from the readable stub: no
   memory-destination XOR/decrypt loop exists in the 1,405 cleanly decoded stub instructions
   (the only `xor/add/sub [mem]` hits are in the non-code header islands).
4. RV-TRN-01's authored-neighbour facts remain the best available and are **not** eye-plane
   values: ground material is `mappingmode=tmmUser`, `TextureScale=1`, S/T=(1,0,0,0)/(1,0,0,0)
   (`reftile.mat:34,38-48`); the face-alpha planes are a different refkey
   (`reftile.mat:120-170`). Keep the port's world-XZ projection labelled **PORT APPROX**.

### 5.2 Numeric FOV / focal conversion (RV-CAM-01 claim 3)

**CONFIRMED_INFEASIBLE** (no exact value recovered).

Byte-level reasons:

1. `GetCameraFieldOfViewByFocalLength` appears exactly once in readable code — the VM
   declaration at `cossacks.exe:0x1fe0e6` — and **0** times in any packed region (M-F). The
   native body is not in readable bytes.
2. No sensor/gate float32 constant exists in the EXE (RV-CAM-01 §D: `36.0`, `20.25`,
   `121.4885`, `1200.0` all 0 hits), and none exists in `.bind`/`WUS1` (no matching ASCII,
   UTF-16 or recognisable float table in the entropy-mapped regions).
3. `viewportdimension`, `Sensor`, `FieldOfView` have 0 hits in the packed regions and 0 donor
   script call sites (RV-CAM-01 claim 4); the runtime call path is therefore unknown.
4. The shared loader contains no projection maths; the payload cannot be enumerated (§4).

Therefore the arithmetic reconciliation in RV-CAM-01 stands unchanged: 2.90° and 17.27° are
coherent 16:9 vertical conversions of 36 mm / 216 mm *horizontal* sensors at `f=400`, but the
sensor choice is **UNVERIFIED**. Keep `FOV_DEG_ASSUMED = 17.27` as a labelled port approximation;
no donor-grounded replacement was found.

### 5.3 Native selection inside-box predicate (RV-SEL-01 open question 1)

**CONFIRMED_INFEASIBLE** (no predicate recovered).

Byte-level reasons:

1. `GameManagerStartSelection`, `GetGameObjectSelectionSizeByHandle`, `spmRunTime` and
   generic `inside`/`Rect` token probes have **0** hits in all five packed regions (M-F).
   The script-side API declarations (`cossacks.exe:0x29f74e`, `0x29f7fa`, `0x240a3a`) are
   declarations, not the native bodies.
2. The readable stub is generic loader code with no selection/geometry predicates.
3. The payload is not enumerable or decodable by any method in §4, so a native body cannot be
   read from it.
4. No donor script calls `GetGameObjectSelectionSizeByHandle` (RV-SEL-01 §"intent vs runtime"),
   so the centre-vs-AABB-vs-frustum question cannot be settled from script text either.

The authoritative selection spec in RV-SEL-01 §"Final authoritative donor selection spec" stays
valid for script-side facts; the inside-box predicate must remain **UNVERIFIED**. Do not invent
one.

---

## 6. Corrections to DEC-01 and the RV reports

1. **DEC-01 §4 / §12 — "`.bind` is a high-entropy stub; the `+0x310` stub is not statically
   readable": CORRECTED (material).** The per-4K profile (§2) shows the first three blocks at
   5.58–6.35, and the region `.bind+0x0300..0x2bff` is 98.4 % identical across four binaries and
   disassembles as clean x86 with 0 % privileged-opcode noise. The `.cdx` entry at `+0x310`
   (`cossacks.exe:0x55c910`) is a valid self-relocating prologue (§3.2). Only `.bind+0x2c00+`
   is genuinely opaque.
2. **DEC-01 §7 — "uniform `+0x310` offset … one generic injected loader stub occupying the
   first ~0x310 bytes": REFINED.** `+0x310` is the *entry point inside* a ~0x2c00-byte shared
   stub, not the stub's size. The per-binary header before it is only 0x300 bytes.
3. **DEC-01 §12 open question 2 — "what does the `+0x310` stub do, where does it jump":
   PARTIALLY ANSWERED.** Its first instructions, the aligned-stack call to `.bind+0x3a0`, the
   manual PE validation (`MZ`/`PE`/`0x14c`/`0xe0`) and the CRC-style API hash loop
   (`0x488781ed`) are now readable and cited (§3.2). The final transfer target into the payload
   is still **UNVERIFIED** — no decrypt/decompress loop was identified.
4. **DEC-01 §4 — "packed content UNVERIFIED": INDEPENDENTLY CONFIRMED for the payload, but
   does not apply to the whole section.** `core_packed_files_list` refusal reproduced exactly
   (§4); no container of any kind was found. The encrypted tail remains UNVERIFIED content.
5. **DEC-01 §7 conclusion (`.cdx` is an entry-redirected copy of `.exe`): CONFIRMED** by
   independent hash and byte comparison, plus Craft Anything's entry-point VAs
   (`cossacks.exe` `0x8f1a08` in `CODE`; `cossacks.cdx` `0x96c310` in `.bind`).
6. **RV-TRN-01 §3 line 102 / §6 F0 ("`.bind` entropy 7.96 ⇒ engine code cannot be statically
   decoded for constants"): NUANCE, CONCLUSION RETAINED.** Some engine-adjacent code *is*
   statically decodable, but it is loader code containing no engine constants; none of the four
   RV-TRN-01 verdicts changes.
7. **RV-CAM-01 §D ("native body not recoverable from strings"): CONFIRMED and extended** — also
   not recoverable from any packed byte region (§5.2).
8. **RV-SEL-01 open question 1 ("native inside-box predicate … body not read"): CONFIRMED** —
   no predicate in readable or decodable bytes (§5.3).
9. **WUS identity (new, supporting).** `WUS` is the CODEX Steam-emulator marker, not a
   documented packer format. This explains `codex.dll`'s section names and export DLL name
   (`codex.dll:0x1984c` `wus.dll`); **inferred** from donor bytes + external corroboration.
   The `.bind` section itself predates and is independent of the Steam-emulator layer.

---

## 7. Open questions

1. **UNVERIFIED:** what algorithm transforms `.bind+0x2c00..+0x23d6f` into executable code/data?
   Standard zlib/gzip/bz2/xz/raw-deflate/raw-LZMA1, archive magics and short repeating XOR/ADD
   keys are all excluded (§4); the readable stub exposes no candidate decode loop.
2. **UNVERIFIED:** do the per-binary pairs at `cossacks.exe:0x55c95b` / `:0x55c963` and the
   78/65-byte blocks at `cossacks.exe:0x55f170` / `:0x55f1bf` form the payload key, an image
   identity, or unrelated data? Four different pairs were observed (§3.2).
3. **UNVERIFIED:** is `0x488781ed` a custom CRC polynomial/hash seed, and which API names does
   it resolve? Bit-reversal (`0xb781e112`) matches no standard CRC-32 variant.
4. **UNVERIFIED:** does the encrypted payload actually contain the three constants (eye planes,
   FOV conversion, selection predicate), or only DRM/loader code? Its size (~135 KB) is
   compatible with a small embedded DLL, but that is **inferred**, not established.
5. **UNVERIFIED:** the final jump target of the stub and the mechanism that transfers control
   from the loader to the original `CODE` entry.
6. **UNVERIFIED:** `codex.dll` `WUS0` has rsize 0 and vsize `0x31000`; whether that virtual
   region is populated at runtime and used by the stub is unknown without execution.
7. **UNVERIFIED:** whether a live GL/native trace (explicitly out of scope here) is the only
   remaining route to the three constants.

---

## 8. Summary

Five independent read-only methods attacked the packed `.bind` / WUS regions. The decisive new
result is a **three-region layout** that DEC-01 missed: a 768-byte per-binary header
(`cossacks.exe:0x55c600..0x55c8ff`), a **shared plaintext x86 loader stub** of 11,264 bytes
(`cossacks.exe:0x55c900..0x55f1ff`, 98.4 % identical across four EXEs, containing the `.cdx`
entry at `cossacks.exe:0x55c910`), and a per-binary ~135 KB high-entropy payload
(`cossacks.exe:0x55f200..0x58036f`). The stub is a self-relocating manual PE mapper with a
CRC-style API hash loop using the non-standard constant `0x488781ed`
(`cossacks.exe:0x55d804`); it contains no engine values.

No container was found. `core_packed_files_list` refused all four targets exactly as DEC-01
reported; no zlib/gzip/bz2/xz header, no archive or PE magic, no raw-deflate or raw-LZMA1 stream,
no repeating XOR/ADD key and no member table exists in the packed regions. The `PE\0\0` hits are
code immediates, not embedded files. Consequently **no members were decoded** and **none of the
three constants was recovered**.

Verdicts: ground eye-plane/texture-matrix values **CONFIRMED_INFEASIBLE**; numeric FOV/focal
conversion **CONFIRMED_INFEASIBLE**; native selection inside-box predicate **CONFIRMED_INFEASIBLE**
— each with the byte-level reasons in §5. DEC-01's "packed content UNVERIFIED" claim is confirmed
for the payload but corrected for the section as a whole, which is partly readable. RV-TRN-01's,
RV-CAM-01's and RV-SEL-01's existing labels and port recommendations stand unchanged; no
port value was substituted and no visual-parity claim is made.

No donor binary was executed, unpacked or copied into the repository; only this report was
written.

*End of DBIND-01.*
