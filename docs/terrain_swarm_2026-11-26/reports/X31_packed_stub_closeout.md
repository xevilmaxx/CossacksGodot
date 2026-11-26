---
id: X31-PACKED-STUB-CLOSEOUT-2026-11-26
ticket: "TERRAIN-SWARM-2026-11-26 / X31 — close out the 'packed stub' question against the owner's 'decode every single bit' directive"
title: "X31 — packed stub closeout: exact .bind / WUS1 geometry, statically recoverable stub vs opaque payload, honest coverage statement"
agent: "X31 (read-only binary worker, DONOR-FIRST terrain swarm)"
created: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_DONOR_BINARY_EXECUTED__NO_GODOT_JOB
owner_file: docs/terrain_swarm_2026-11-26/reports/X31_packed_stub_closeout.md
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_guard: "NO DONOR VISUAL PARITY CLAIM. No donor GPU A/B frame exists; no donor binary was executed by this worker. 'Decoded' means bytes/opcodes recovered, never a behavioural or visual match."
scope_guard: "Donor at C:\\Games\\Cossacks 3 read only. No donor binary copied, written or run; no Godot job; no source/asset/config/test/git edit. Exactly one repo file written (this report)."
shared_session: "Craft Anything 0.6.1, deep mode, active target started and finished t_68474ddde43f (editor.exe); cossacks.exe t_87f0f3c130b0 kept open. Five auxiliary files were opened briefly for native_sections_list and closed; active target restored."
sources_read: "CHARTER.md, SWARM_BOARD.md, docs/decomp/DA_PE.md, reports/X01_decomp_corpus.md, reports/X02_editor_corpus.md, reports/X27_decode_coverage.md."
---

# X31 — packed-stub closeout

## 1. Executive summary

1. **[O] The packer is a thin, fixed-size tail section, not a whole-binary enclosure.** Five donor PEs carry a last-section blob of exactly **146,800 bytes (0x23D70)** at entropy **7.965**: `cossacks.exe`/`cossacks.cdx` VA `0x96c000–0x98fd70` (file `0x55C600`–EOF), `config.exe`/`config.cdx` VA `0x858000–0x87bd70` (file `0x44A600`–EOF), `editor.exe` VA `0xb6f000–0xb92d70` (file `0x75EA00`–EOF). Their `CODE` sections remain 4.1–6.4 MB of ordinary x86 at entropy 6.61–6.62 (§3, §4). The triage sentence "most of its real code is hidden until it runs" is a **generic heuristic**, contradicted by the measured section table (§5 C1).
2. **[O] The stub itself is statically readable x86, and a partial static decoder was actually recovered.** At the protected `.cdx` entries (`cossacks.cdx:0x96c310`, `config.cdx:0x858310`) sits a classic GetPC/stack-align/`ret`-into-OEP stub; its `call rel32 +0x6d` reaches a decoder at `0x96c3a0` that copies `0xF0` bytes from `EIP−0xF0` and rolling-XORs 59 dwords. Emulating that loop **on file bytes only** (no donor execution) yields a 240-byte packer descriptor containing the magic `0xC0DEC0DF`, image base `0x00400000`, and the **OEP as an RVA**: `0x004f1a08` → VA `0x8f1a08` for cossacks, `0x003ed85c` → VA `0x7ed85c` for config (§6). Both equal the *readable* `.exe` entry points.
3. **[D] Consequence that closes the question:** the `.cdx` protected variants wrap exactly the image already exposed by `cossacks.exe`/`config.exe`. The packed blob hides **no terrain code that is not already present in readable `CODE`**. `cossacks.exe` and `cossacks.cdx` even share byte-identical `.bind` content at start/mid/tail (§4.1, §5 C7).
4. **[O] What remains genuinely opaque:** the ~146 KB high-entropy payload body — no printable strings (`native_strings_browse(section=".bind")` → `not_found`), no discovered functions (five probes inside `cossacks.exe:.bind` → `not inside any discovered function`), no known packer magic (`UPX` 0 matches). Import thunks are in readable `.idata` (746 imports for `cossacks.exe`), so the stub's library surface is known, but its payload is not.
5. **[D] Static unpacker verdict, honestly:** a **partial** static decoder is feasible and demonstrated (§6); a **complete offline unpacker is not feasible under this charter** without emulating the whole packer — which is effectively executing donor code — and would yield nothing new because the OEP is already known and readable. No memory dump exists (DA_PE §4.2). `codex.dll`'s `WUS1` is a 101,376-byte Steam-runtime blob (95.4% of that tiny DLL), irrelevant to terrain; `GameOverlayRenderer.dll` is **not packed at all** (§4.6–4.7).
6. **[D] Terrain parity is not blocked by any packed byte.** The generator is plaintext DScript (`dogenerate.inc`, `generatemap.inc`, `texturemap.inc`, `smoothtiles.inc`; X03 972 line-cited excerpts), constants are in 7 cfg files (F03), and formats are byte-decoded (F01/F02/F04/F05/F06). Packed bytes are **2.152%** of the two terrain-relevant PEs (2.786% of all seven PEs), and ~0.002% of that was decoded here (§8). The real blockers are runtime activation, native kernels, pass counts, bindings and 23/34 missing anchors — all `[U]` in X27 §5. **PORT APPROXIMATION** until those are settled; no parity claim is made.

## 2. Evidence table

All ids are Craft Anything evidence records; section/geometry calls used `path=` or explicit `document=` and did not leave a foreign target active.

| # | Evidence id / call | What it establishes | Label |
|---|---|---|---|
| E1 | `ev_e7533ff33…` (`core_target_triage cossacks.exe`) | x86 PE, Delphi/C++Builder, stripped, entry `0x8f1a08`, `.bind` hint 7.96 | [O] |
| E2 | `ev_0b468aeb…` (`core_target_triage cossacks.cdx`) | entry `0x96c310`, `.bind` 7.96, sha256 `1a88936e…` | [O] |
| E3 | `ev_9e39e5c8…`, `ev_4c06408a…` (`config.exe`/`config.cdx`) | entries `0x7ed85c` / `0x858310`, `.bind` 7.97 | [O] |
| E4 | `ev_2544b87d…` (`editor.exe`) | entry `0xa259b8`, `.bind` 7.96 | [O] |
| E5 | `ev_d2b04586…` (`codex.dll`) | MSVC Rich header, stripped, `WUS1` 7.91, Steam imports, sha256 `382a9594…` | [O] |
| E6 | `ev_5d435291…` (`GameOverlayRenderer.dll`) | x86 DLL, stripped, **no packer hint**, sha256 `e179bc6d…` | [O] |
| E7 | `ev_d5b51af0808dd609842ab36f411ca6cbd51212d8de038e641acfd28d3198239f` | `cossacks.exe` 10 sections with VA/file offset/size/entropy/permissions | [O] |
| E8 | `ev_9cfd34d1d72ae604568a926e33de7a7069e9028ab0331784eff929c8d41c16fd` | `editor.exe` 10 sections; `.bind` `0xb6f000–0xb92d70`, file `0x75EA00`, H 7.96488 | [O] |
| E9 | `ev_b8c0ac0cac2fc3bf4ca9914db670bd7f3196ea5a76e2ccbd430144b69d676c9c` | `cossacks.cdx` section table **identical** to `cossacks.exe` | [O] |
| E10 | `ev_7aa1c322…`, `ev_be601b18…` | `config.exe`/`config.cdx` section tables identical; `.bind` `0x858000–0x87bd70`, H 7.96510 | [O] |
| E11 | `ev_55ecec3db83417b719eb688c9b012d2321fde6d25431d85e2da6f5b5f44d916c` | `codex.dll`: `WUS0` virtual-only (raw 0, entropy null), `WUS1` raw 101,376 B H 7.90508 | [O] |
| E12 | `ev_0f1ba3738d082c5c27a28dd18966d94493c3fd07b7148384dc8a1136529b20cf` | `GameOverlayRenderer.dll`: `.text` H 6.491, no `.bind`/`WUS1` | [O] |
| E13 | `ev_47ddc674…` (`native_layout_show`) | image base `0x400000`; export table; imports; section names incl. `.bind` | [O] |
| E14 | `ev_967d3cb26e057478b6b150a1cb71c0f83416c6d4b5a143e0128140708f549670` / `ev_aba75a2c7e747bd6ce5263fcdaa9e15d1123a9450761bac8c442db88bd262e55` | `0xb6f000`→file `0x75ea00` **in `.bind`**; `0x76f000`→file `0x36e400` **in `CODE`** (resolves D09 contradiction) | [O] |
| E15 | `ev_3973d456…`, `ev_a6f6751e…` (256 raw bytes at `.bind` starts) | high-entropy noise, no prologue/magic at `0x96c000` / `0xb6f000` | [O] |
| E16 | `ev_aa924525…` (`0x8f1a08` bytes) + `ev_b6f454aa…` | `cossacks.exe` entry is normal `55 8b ec …` prologue in `CODE`, function `entry` | [O] |
| E17 | `ev_d8d44bce…` (`cossacks.cdx:0x96c310`, 96 B), `ev_1c464472…` (`config.cdx:0x858310`, 96 B), `ev_a7f9330e…` (`codex.dll:0x1004a7d0`, 96 B) | packed entry stubs decoded by hand (§4.2, §4.6) | [O]/[D] |
| E18 | `ev_e403d1bd…`, `ev_d695eaec…`, `ev_1ff58b69…` | entries recognised as function `entry` at `0x96c310` / `0x858310` / `0x1004a7d0` | [O] |
| E19 | `ev_bdb66206…` (`native_function_disassemble 0x96c310`) | lifter emits **1 instruction only** (`call 0x96c315`) — stub beyond that is not lifted | [O] |
| E20 | `ev_3c7a7fc4…`, `ev_daffb9ea…`, `ev_8409a133…` | decoder at `0x96c3a0`, helper/padding at `0x96c353`, 512 B of readable stub | [O] |
| E21 | `ev_9669c8ec…`, `ev_0b2e05ec…` | 240-byte encoded descriptor inputs at `0x96c220` / `0x858220` | [O] |
| E22 | `ev_047e9fc4…`, `ev_c12682fa…`, `ev_ec393fda…`, `ev_932c5cc1…`, `ev_8fd5a513…` | five `.bind` addresses in `cossacks.exe` → `function:null`, "not inside any discovered function" | [O]/[U] |
| E23 | `ev_a28e8e2f0a9ceef3de82a4a8edd3fbf7d15ee302af671b1458291321f75b2662`, `ev_d97e1bfb…`, `ev_a9dd1656…` | first 16 B, mid (`0x970000`) and tail (`0x98fd60`) of `.bind` byte-identical in `cossacks.cdx` | [O] |
| E24 | `ev_fe39d3cc8ce997da63dc49489636bba62e8a20d851d5cab74ca399750abeee16` | same 16 B signature absent from `config.exe` → per-build payload | [O] |
| E25 | `ev_58bc58061734a2625342eca4898f3a1d811514343e4c8847e3574bf62117cad1`, `ev_dec85bd41…`, `ev_ad951d85…` | `WUS1` appears once at file `0x220` (header section name); `.bind` once at `0x360`; `UPX` 0 matches | [O] |
| E26 | `ev_8fc7605552598682b4c4303229e4a7f5ae7cb56e00375509bb97a003f7ac39fb` | 746 imports in `cossacks.exe`, slots `0x907000–0x90b10c` (`.idata`), incl. `VirtualAlloc/Protect/Free`, `LoadLibraryA`, `GetProcAddress` | [O] |
| E27 | `ev_b77489b8cf5ea14e43a5f606b64d56bf179caef2d701c69c774a1ba3be7b18b6` | 11 imports in `codex.dll` incl. `VR_InitInternal`, `ValveHookScreenshots`, `VirtualAlloc` | [O] |
| E28 | `native_strings_browse(section=".bind")`, both open PEs | `not_found`: **no strings in `.bind`**; string-bearing sections are `.edata`, `.idata`, `.reloc`, `.rsrc`, `DATA` (no evidence id — tool error) | [O] |
| E29 | `native_objdump_run(section_headers)` ×7 | `engine_missing` — objdump not installed in this session; cross-instrument fallback unavailable | [O] |
| E30 | X01 §4.1/E2, X02 §4, X27 §2–§3 | 18,918/22,384 discovered functions exported; 4,265 (22.54%) / 12,254 (54.7%) garbled; 11/34 terrain anchors present | [O] |
| E31 | X03 §0, F03 §2, F01 §4.1, F02 §0, F04 §0, X27 §7 | generator logic in plaintext DScript; cfg literals; 710/710 `.pattern`; 680-section `pattern.lib`; 4,466 masks decoded | [O] |

## 3. Geometry table (exact, read-only)

Entropies are the tool's measured bits/byte; "raw" is `SizeOfRawData`. All five `.bind` sections **end exactly at EOF** (offset + 146,800 = file size).

| File | Section | VA range | File offset | Raw size | Entropy | Perms |
|---|---|---|---|---:|---:|---|
| `cossacks.exe` | `CODE` | `0x401000–0x8f1da8` | 1,024 (`0x400`) | 5,180,840 | **6.6092** | r-x |
| | `.idata` | `0x907000–0x90b10c` | 5,227,008 | 16,652 | 5.0783 | rw- |
| | `.rsrc` | `0x94c000–0x96b400` | 5,493,248 | 128,000 | 5.0809 | r-- |
| | `.bind` | `0x96c000–0x98fd70` | 5,621,248 (`0x55C600`) | **146,800** | **7.96479** | r-x |
| `cossacks.cdx` | all | **identical table** | identical | identical | identical | identical; entry `0x96c310` in `.bind` |
| `config.exe` | `CODE` | `0x401000–0x7eda64` | 1,024 | 4,115,044 | **6.6198** | r-x |
| | `.rsrc` | `0x839000–0x857e00` | 4,372,480 | 126,464 | 5.0949 | r-- |
| | `.bind` | `0x858000–0x87bd70` | 4,498,944 (`0x44A600`) | **146,800** | **7.96510** | r-x |
| `config.cdx` | all | **identical table** | identical | identical | identical | identical; entry `0x858310` in `.bind` |
| `editor.exe` | `CODE` | `0x401000–0xa25d34` | 1,024 | 6,442,292 | **6.6070** | r-x |
| | `.rsrc` | `0xa91000–0xb6e800` | 6,820,352 | 907,264 | 5.6160 | r-- |
| | `.bind` | `0xb6f000–0xb92d70` | 7,727,616 (`0x75EA00`) | **146,800** | **7.96488** | r-x |
| `codex.dll` | `WUS0` | `0x10001000–0x10032000` | none (virtual) | 0 | null | rwx |
| | `WUS1` | `0x10032000–0x1004b000` | 1,024 | **101,376** | **7.90508** | rwx |
| | `.rsrc` | `0x1004b000–0x1004c000` | 102,400 | 2,560 | 3.3846 | rw- |
| `GameOverlayRenderer.dll` | `.text` | `0x10001000–0x100ca46b` | 1,024 | 824,427 | **6.4908** | r-x |
| | `.rdata`/`.data`/`.rsrc`/`.reloc` | `0x100cb000+` | 825,856+ | 204,466 / 19,968 / 58,424 / 62,164 | 5.1888 / 4.3924 / 2.0707 / 6.7554 | — |

Sources E7–E12. **Observation [O]:** the high-entropy region is a *bounded 1.86–3.16% tail* in the four game PEs, not the bulk of the program.

## 4. Per-file stub analysis

### 4.1 `cossacks.exe` (5,768,048 B, sha256 `87f0f3c1…`) — packed payload present, **entry NOT packed**

**[O]** Entry `0x8f1a08` lies in `CODE` (`0x401000–0x8f1da8`), is recognised as function `entry` (E16), and its first bytes `55 8b ec b9 06 00 00 00 6a 00 6a 00 49 75 f9 …` are a normal Delphi prologue. **[O]** `.bind` starts with high-entropy bytes `25 99 bb dd 4a fa bb bb 38 9f de bb 4e ec ae c9 …` (E15) and is not covered by any discovered function (E22). **[O]** Its `.bind` is byte-identical at start (`0x96c000`), middle (`0x970000`) and tail (`0x98fd60`) to `cossacks.cdx` (E9, E23). **[D]** The protected `.cdx` and this `.exe` carry the *same* packer blob; only the PE entry routing differs.

### 4.2 `cossacks.cdx` (5,768,048 B, sha256 `1a88936e…`) — protected entry, **stub statically decoded**

**[O]** Entry `0x96c310` is inside `.bind`; `native_function_find` returns function `entry`, but the disassembler emits only `call 0x96c315` (E18/E19). Hand-decoding the 96 raw bytes (E17) gives:

```
0x96c310  e8 00000000      call $+5              ; GetPC -> eax = 0x96c315
0x96c315  50 53 51 52 56 57 55                    ; save eax,ebx,ecx,edx,esi,edi,ebp
0x96c31c  8b 44 24 1c      mov eax,[esp+0x1c]     ; return address
0x96c320  2d 05000000      sub eax,5              ; EIP base = 0x96c310
0x96c325  8b cc            mov ecx,esp
0x96c327  83 e4 f0         and esp,-16            ; align stack
0x96c32a  51 51 51 50      push ecx,ecx,ecx,eax    ; pass EIP base
0x96c32e  e8 6d000000      call 0x96c3a0          ; decoder -> eax = OEP
0x96c333  83 c4 04         add esp,4
0x96c336  59 59 59         pop ecx,ecx,ecx
0x96c339  8b e1            mov esp,ecx
0x96c33b  89 44 24 1c      mov [esp+0x1c],eax     ; patch return address to OEP
0x96c33f  5d 5f 5e 5a 59 5b 58                    ; restore regs
0x96c346  c3               ret                    ; jump to unpacked image
```

At `0x96c353` a second GetPC helper appears with per-build constants `sub edx,0x03fafff7` / `xor edx,0xf3fa1281`, followed by `cc` padding, a `xor eax,eax; ret 8` stub and `64 a1 18 00 00 00 c3` (`mov eax, fs:[0x18]; ret` — TEB access, likely anti-debug/SEH) **[O] bytes / [I] role** (E20). The decoder proper at `0x96c3a0` is detailed in §6.

### 4.3 `config.exe` (4,645,744 B, sha256 `cddfee…`) — packed payload present, **entry NOT packed**

**[O]** Entry `0x7ed85c` is in `CODE` (`…–0x7eda64`). `.bind` `0x858000–0x87bd70` has the same size/entropy family but a **different payload** — the `cossacks` 16-byte signature does not occur (E24). No corpus or VMT map exists for this PE (X27 §3.1).

### 4.4 `config.cdx` (4,645,744 B, sha256 `613625…`) — protected entry, same stub family, different keys

**[O]** Entry `0x858310` in `.bind`, function `entry` (E18). Stub bytes (E17) are structurally **identical** to §4.2 for the first 0x2f bytes; the helper constants differ: `sub edx,0xb14821d7` / `xor edx,0xcc28285b`. **[D]** One packer family, per-build keys — a universal offline unpacker cannot be assumed.

### 4.5 `editor.exe` (7,874,416 B, sha256 `68474dd…`) — packed payload, **entry NOT packed**

**[O]** Entry `0xa259b8` in `CODE`; X02 §6 verified this as a clean, structured PE-startup function. `.bind` `0xb6f000–0xb92d70` (file `0x75EA00`) starts with high-entropy noise (E8/E15). **[O]** X02 §5.2 flagged `0x42fb6c VirtualAlloc(RWX)` as a *possible* unpack staging site — **[I]** only; no runtime evidence. **[O]** The earlier report's "editor `.bind` VA `0x76f000`" is an **RVA**, not a VA (§5 C2).

### 4.6 `codex.dll` (106,272 B, sha256 `382a9594…`) — `WUS1` packed, **Steam-side, no terrain role**

**[O]** Three sections: `WUS0` virtual-only (raw size 0, entropy null, rwx) = an uninitialised RWX buffer; `WUS1` raw 101,376 B at entropy 7.905 (E11); `.rsrc` 2,560 B entropy 3.385. Entry `0x1004a7d0` lies in `WUS1` and its bytes `80 7c 24 08 01 0f 85 d9 01 00 00 60 be 00 20 03 10 …` are a compact decoder/checksum loop **[O]/[I]**. **[O]** `WUS1` appears exactly once in the file, at header offset `0x220` (E25) — no embedded magic. **[O]** 11 imports include `VirtualAlloc/Protect/Free`, `LoadLibraryA`, `GetProcAddress` plus `VR_InitInternal` and `ValveHookScreenshots` (E27). **[D]** Consistent with a protected Steam runtime/overlay helper; DA_PE §4 and X27 §3.1 classify it out-of-scope. **[O]** Packed fraction 95.393% of this DLL, but only 101,376 B in absolute terms.

### 4.7 `GameOverlayRenderer.dll` (1,178,912 B, sha256 `e179bc6d…`) — **not packed**

**[O]** Triage reports no packer hint (E6); sections are ordinary `.text`/`.rdata`/`.data`/`.rsrc`/`.reloc` with entropies 6.49/5.19/4.39/2.07/6.76 (E12). No `.bind`, no `WUS1`. **[D]** The "packed stub" question does not apply to this file at all; it is Steam overlay boilerplate, ignore per DA_PE §6.

## 5. Multiple-pass contradiction register (owner directive)

No contradictory reading was skipped after one pass.

| # | Contradiction | Pass 1 | Pass 2 | Pass 3 | Accepted reading |
|---|---|---|---|---|---|
| C1 | Triage plain English: "packed or protected … most of its real code is hidden until it runs" vs DA_PE/X01: 5.18 MB `CODE` readable | `core_target_triage` text (E1) | `native_sections_list` exact per-section entropy (E7) | X01: 18,918 functions exported from `CODE`; X27 §3.1 | **[D]** Generic heuristic text; measured truth is *section-level* — only 2.545% of `cossacks.exe` is high-entropy. Quote sections, never the triage sentence. |
| C2 | D09/X27: editor `.bind` VA `0x76f000`, size `0x23d70` vs sections `0xb6f000–0xb92d70` | `native_sections_list` (E8) | `native_address_offset_show(0xb6f000)` → `.bind`, file `0x75ea00` (E14) | `native_address_offset_show(0x76f000)` → `CODE`, file `0x36e400` (E14) | **[O]** authoritative **VA `0xb6f000`**; `0x76f000` is the RVA. Size agrees (`0x23d70`=146,800). |
| C3 | DA_PE "entry inside `.bind`" generalised to all PEs vs `cossacks.exe` entry `0x8f1a08` | triage entry value (E1) | `native_bytes_show(0x8f1a08)` normal prologue (E16) | `native_function_find(0x8f1a08)` = `entry` in CODE (E16) | **[O]** only the **`.cdx`** variants have packed entries; `.exe` entries are in readable `CODE`. |
| C4 | Rounded entropy 7.96/7.97/7.91 vs exact | triage hints (E1–E5) | `native_sections_list` (E7–E12) | — | **[O]** exact: 7.96479 / 7.96510 / 7.90508. Both readings true at different precision. |
| C5 | `codex.dll` "packed WUS1 7.91" vs `WUS0` entropy null | triage (E5) | sections: `WUS0` raw 0 / entropy null, `WUS1` raw 101,376 (E11) | decode attempt at entry yields x86 (E17) | **[O]** `WUS0` is a virtual RWX buffer, not packed data; only `WUS1` is opaque. |
| C6 | "No function in `.bind`" vs "entry function at `0x96c310`" | five `.bind` probes → null (E22) | `native_function_find(0x96c310)` → `entry` (E18) | `native_function_disassemble` → 1 instruction (E19) | **[O]/[U]** only the entry stub is recognised; bulk undecoded. Absence is not proof (tool limitation). |
| C7 | `cossacks.exe` and `.cdx` same size/entropy but different sha | triage sha values (E1/E2) | section tables identical (E7/E9) | 16 B at start + mid + tail byte-identical (E23) | **[O]** same packer blob, different build headers/entry routing; both true. |
| C8 | `config.exe` vs `config.cdx` identical section tables | sections (E10) | `WUS`-style signature absent in `config.exe` (E24) | triage entries differ (E3) | **[O]** identical container geometry, different payload keys and entry location. |

## 6. Recoverability verdict — what was actually decoded

### 6.1 Statically recoverable **[O]/[D]**

- **PE structure:** all section names, VAs, raw offsets, sizes, perms and entropies (§3).
- **Imports/thunks:** 746 imports for `cossacks.exe` at slots `0x907000–0x90b10c` in readable `.idata`, including the classic unpack primitives `VirtualAlloc`, `VirtualProtect`, `VirtualFree`, `LoadLibraryA`, `GetProcAddress`, `CreateThread` (E26). **[I]** presence is consistent with a stub but shared with the Delphi RTL; not proof of which imports the stub uses. `codex.dll`: 11 imports (E27).
- **Stub code:** the GetPC/stack-align/ret-into-OEP entry stub and the 0x96c3a0 decoder are fully readable x86 (§4.2, §6.2); the engine itself lifts only one instruction (E19), so this was recovered by manual byte decode + raw-byte reads.
- **No plaintext strings in `.bind`** (E28) — so any string-based recovery is impossible there.
- **No known packer signature** — `UPX` 0 matches (E25); generic unpackers have nothing to key on.

### 6.2 Demonstrated partial static decode (no donor execution) **[O]/[D]**

The decoder at `0x96c3a0` (E20) was hand-decoded:

```
0x96c3a0  push ebp; mov ebp,esp; sub esp,0x840; push esi
0x96c3aa  mov dword [ebp-0x140],0xF0          ; copy counter
0x96c3b4  lea eax,[ebp-0x5c0]; mov [ebp-0x278],eax
0x96c3c0  mov ecx,[ebp+8]; sub ecx,0xF0       ; source = EIP_base - 0xF0
0x96c3c9  mov [ebp-0x13c],ecx
0x96c3cf  loop: copy 0xF0 bytes [src] -> stack buffer at [ebp-0x5c0]
0x96c415  key = first dword of copied buffer
0x96c42a  count = 0xEC >> 2 = 59 dwords
0x96c448  loop: out[i] = in[i] XOR key; key = in[i] (original); i++  (59×)
0x96c4ac  cmp dword [ptr], 0xC0DEC0DF         ; magic validation
0x96c4b7  jmp far into .bind (+0x1E5F)        ; continuation of unpacker
```

Emulating only this loop on file bytes (input `0x96c220`, file `0x55C820`, 240 B, E21) produced:

| Slot | `cossacks.exe` / `.cdx` | `config.cdx` | Interpretation [D] |
|---|---|---|---|
| 0 | `0x12997921` | `0x83191cfe` | initial rolling-XOR key (per build) |
| 1 | `0xC0DEC0DF` | `0xC0DEC0DF` | **magic independently confirmed** by the `cmp` at `0x96c4ac` — validates the emulation |
| 2 | `0x00400000` | `0x00400000` | PE image base |
| 3 | `0x0056c310` | `0x00458310` | protected entry RVA → VA `0x96c310` / `0x858310` |
| 4 | `0x00000310` | `0x00000310` | stub offset in `.bind` |
| 5 | `0x00002860` | `0x00002860` | packer-family constant |
| 6 | `0x004f1a08` | `0x003ed85c` | **OEP RVA** → VA `0x8f1a08` (`cossacks.exe` entry) / `0x7ed85c` (`config.exe` entry) |
| 12 | `0x00023d70` | `0x00023d70` | `.bind` size (146,800) |
| 13 | `0xd433aa35` | `0xb63c256d` | per-build hash/key |
| 18/19 | `0x0050728c` / `0x00507288` | `0x0040128c` / `0x00401288` | import-slot RVAs (`GetModuleHandleA` / `GetProcAddress`) |

Sources: E21 + the static emulation (computed in-session from raw bytes only). **[D] This is the closeout result:** the protected variants' unpacked entry is *identical* to the entry of the already-readable `.exe`. The packer wraps an image we can already read; it does not conceal a second terrain implementation.

### 6.3 What is NOT statically recoverable **[U]**

- The remaining ~146 KB payload body: entropy 7.965, no strings, no functions, no signature (E15/E22/E25/E28).
- The continuation at `0x96c4b7+` (further XOR loops, field checks at `[ebp+8]+0x10/+0x18/+0x2c`, a `0xE8`-byte zeroing loop, bounds `<=0x280`) — readable as bytes but **not lifted or emulated**; no full unpacker produced.
- Any runtime-only state: decrypted strings, resolved imports, unpacked buffers, GL bindings, pass counts.
- Original Delphi source, identifiers, comments (DA_PE §4.6).
- **No memory dump is available** (DA_PE §4.2) and executing the donor is forbidden (CHARTER §4).

**Verdict [D]:** a **partial** static decoder is feasible and demonstrated; a **complete** static unpacker is **not feasible under this charter** — it would require emulating the whole stub (functionally running donor code) and the result would merely re-derive the already-readable `.exe` image. No parity implication follows.

## 7. Tool recommendations (free where possible)

| Tool | What it would add | What it still cannot recover |
|---|---|---|
| **Ghidra** (free, x86 PE loader) | Import PE at image base `0x400000`; define `.bind` as code at `0x96c000` and disassemble the stub/decoder; Jython/Python script to replay the 240-byte XOR descriptor (already done here) | Cannot decompress the 146 KB payload without emulating the packer; no runtime strings/bindings; x87 stack-return lifts can regress (X01 §6.4) |
| **radare2 / Cutter** (free) | `aaa`, `pd 200 @ 0x96c3a0`, `wxs`/`xe` scripting for the XOR loop; quick entropy/byte-histogram views | Same ceiling; discovery still capped by indirect jumps |
| **ImHex** (free) | Pattern-language description of the 240-byte descriptor, entropy heatmap over `.bind`, bitwise/XOR transforms on selected ranges | Hex/byte-level only: no decompilation, no control-flow emulation |
| **IDR — Interactive Delphi Reconstructor** (free) | Delphi VMTs, class hierarchy, DFM streams — but that surface is already harvested by D01 (1,182 VMTs) and X02 (DFM labels) | Cannot unpack; no runtime semantics |
| **Unicorn Engine + Python** (free library) | Could emulate the stub *from file bytes* without launching the donor process; would confirm OEP and descriptor | Would be executing donor code in emulation — outside/gray under CHARTER §4 "never execute a donor binary"; needs owner approval and adds nothing beyond §6.2 |
| **x64dbg / OllyDbg** (free) | Trivial dump of unpacked image at OEP | **Prohibited**: requires running the donor; no memory dump exists today (DA_PE §4.2) |
| **objdump** | Cross-check section headers | `engine_missing` in this session (E29) — external install required; not used |

**[D] Recommendation to COORD:** no new unpacking work is justified for terrain parity. If a tool pass is commissioned at all, it should be a Ghidra/radare2 **stub-only** annotation plus a VMT-pointer-following discovery pass to shrink the 23/34 missing anchors and 22.54%/54.7% garbled sets (X27 blocker #9) — not a packer attack.

## 8. Implications for terrain parity — final coverage statement

1. **[O] The generator is not in `.bind`.** The terrain algorithm is plaintext DScript — `dogenerate.inc`, `generatemap.inc`, `texturemap.inc`, `smoothtiles.inc`, `smoothforestborders.inc`, `postprocess.inc` — with 972 line-cited verbatim excerpts (X03; E31). All cfg literals are in 7 text files (F03). `.pattern` (710/710), `pattern.lib` (680 sections), 4,466 terrainmask TGAs, tile ids and shaders are byte-decoded (F01/F02/F04/F05/F06/X11; E31). None of these is packed.
2. **[O] The executable half needed for terrain is readable.** `cossacks.exe` has a 5.18 MB `CODE` section at entropy 6.609 with 18,918 exported pseudo-C functions (X01); terrain classes are anchored via RTTI/VMT (D01). The gap there is *anchoring and lifter quality*, not packing: 11/34 known anchors present, 22.54% garbled (E30).
3. **[D] The packed `.cdx` variants add no terrain information.** Their descriptor OEP resolves to the same VA as the readable `.exe` entry (§6.2). The 146,800-byte blob is a protected wrapper, not a second generator implementation.
4. **[D] Honest fraction genuinely undecodable:**

   | Scope | Bytes | Packed | % |
   |---|---:|---:|---:|
   | 7 PEs inspected (incl. 2 Steam DLLs) | 29,987,184 | 835,376 | **2.786%** |
   | 2 terrain-relevant PEs (`cossacks.exe`, `editor.exe`) | 13,642,464 | 293,600 | **2.152%** |
   | Of that, statically decoded here (descriptor + stub) | — | ~304 | ~0.002% of the two PEs |
   | Residual opaque, terrain-relevant | — | ~293,296 | **~2.150%** |

   Per file: `cossacks.exe` 2.545%, `cossacks.cdx` 2.545%, `config.exe`/`config.cdx` 3.160%, `editor.exe` 1.864%, `codex.dll` 95.393% (irrelevant), `GameOverlayRenderer.dll` 0%. **[I]** Across the whole donor by bytes, the larger un-decoded mass is the 49 baked DLC `.map` files (2.877 GiB), deliberately deferred as campaign snapshots with no generator delta (F10/X27) — a scope decision, not a packer defect.
5. **[D] Why this does not block terrain parity:** parity is limited by *semantics and runtime*, not by the 2.15% opaque tail. X27 §5 ranks the true blockers as: runtime activation of `;`-prefixed DScript (UNVERIFIED), stamp height kernel row-sign/clamp/blend, `bmTransparency` pass count, `hmapTex` binding, exact RNG replay, pattern field semantics, `.map` anomalies, native kernels, whole-code coverage gaps, and absence of a donor GPU A/B frame. None is resolved by unpacking `.bind`. All downstream implementation remains **PORT APPROXIMATION** until those are settled.
6. **[D] Coverage statement:** "decode every single bit" is **not achieved** under read-only/no-execution rules (X27 §7). What *is* achieved is byte-level closure of terrain-relevant readable data plus on-demand instruction reads of named functions, and now a precise, bounded account of the packed residue. **No donor visual parity claim is made or implied by this report.**

## 9. UNVERIFIED register

| ID | Claim / item | Status | Passes attempted / why unresolved | Next owner |
|---|---|---|---|---|
| U-X31-01 | Full contents of any 146,800-byte `.bind` payload | **[U]** opaque | triage (E1–E4), sections (E7–E10), raw bytes (E15/E23), strings (E28), functions (E22), signature search (E25); no execution/dump permitted | COORD — declare out-of-scope; do not commission |
| U-X31-02 | Continuation of unpacker past `0x96c4b7` | **[U]** bytes read, semantics not emulated | 512 B read (E20), manual decode of first 0x110 B; further loops not lifted | Optional Ghidra annotation only |
| U-X31-03 | Whether `0x42fb6c VirtualAlloc(RWX)` is unpack staging in `editor.exe` | **[U]/[I]** | X02 §5.2 corpus call only; no runtime evidence | D09 (leave `[U]`) |
| U-X31-04 | Exact identity of packer product / version | **[U]** | no `UPX` magic (E25), no other signature probed exhaustively; heuristic Delphi hint only (E1) | Not needed for terrain |
| U-X31-05 | `WUS0` purpose in `codex.dll` | **[I]** virtual RWX buffer | sections (E11) + entry bytes (E17); no runtime | Out-of-scope (Steam) |
| U-X31-06 | Whether `.bind` contains terrain-relevant runtime-only strings | **[U]** but **no evidence for it** | `native_strings_browse(.bind)` → `not_found` (E28); 0 matches never prove absence in encrypted data; OEP equals readable `.exe` entry (§6.2) | COORD — low risk, declare `[U]` |
| U-X31-07 | Byte-identity of entire `.bind` between `.exe` and `.cdx` (not just 3 samples) | **[U]** partial | start/mid/tail 16-B signatures (E23); section tables identical (E9) | Low value; not blocking |
| U-X31-08 | Ghidra/radare2 re-lift of `0x96c310` stub beyond 1 instruction | **[U]** | engine disassembler emitted 1 instruction (E19); manual byte decode used instead | Optional tool pass |
| U-X31-09 | objdump-based section cross-check | **[U]** tool unavailable | `native_objdump_run` → `engine_missing` (E29) on all 7 files | Install externally if ever needed |
| U-X31-10 | Runtime consumption of the decoded descriptor fields (slot 5 `0x2860`, slot 13 hash) | **[U]/[D]** | static emulation (§6.2) recovers values, not use; continuation not emulated | Optional static-analysis ticket |

## 10. Open questions

1. **COORD:** accept §8.4 as the final honest packed-byte fraction (2.786% of 7 PEs / 2.152% of terrain-relevant PEs) and close the "packed stub" ticket, or commission a *stub-only* Ghidra annotation pass (U-X31-08)?
2. **COORD:** should the `.cdx` variants be formally declared out-of-scope with the reason "protected wrapper whose OEP resolves to the already-readable `.exe` entry" (§6.2), consistent with DA-4?
3. **Owner:** is any read-only runtime/GL trace obtainable? It would settle X27 blockers #1/#3/#4, but it cannot be obtained under today's "never run donor" rule.
4. **D01/D03:** will the VMT-pointer-following discovery pass be commissioned to shrink the 23/34 missing anchors — the one code-coverage gap that *does* touch terrain (X27 blocker #9)?
5. **F01:** will full `w×h` relief grids be exported for the ~50+ active pattern ids currently only indexed (X27 U14)?PACKED bytes are not the cause.
6. **COORD:** how should the 49 baked DLC `.map` files be recorded — deferred (current) or explicitly out-of-scope — so the "every single bit" denominator is unambiguous?

## 11. Five-line summary (for COORD)

1. **[O]** Measured all seven PEs: five carry a 146,800-byte, entropy-7.965 `.bind`/`WUS1` tail (2.545% / 3.160% / 1.864% per game PE; `codex.dll` 95.4%, `GameOverlayRenderer.dll` 0%); `CODE` remains 6.61–6.62 and readable.
2. **[O]/[D]** The protected `.cdx` entry stub is readable x86; a 240-byte rolling-XOR descriptor was decoded **from file bytes only**, yielding magic `0xC0DEC0DF`, image base `0x400000` and OEP RVAs `0x4f1a08`/`0x3ed85c` — exactly the readable `.exe` entries `0x8f1a08`/`0x7ed85c`.
3. **[U]** The remaining ~146 KB per PE is opaque (no strings, no discovered functions, no packer signature); a full static unpacker is not feasible under read-only/no-execution rules and would recover nothing new — no memory dump exists.
4. **[D]** Contradictions resolved by multi-pass: editor `.bind` VA is `0xb6f000` (`0x76f000` is RVA); only `.cdx` entries are packed; entropy 7.96/7.97/7.91 are rounded 7.96479/7.96510/7.90508.
5. **[D]** Genuinely undecodable = 2.786% of seven PE bytes, 2.152% of the two terrain-relevant PEs; terrain logic lives in plaintext DScript/cfg and readable CODE, so packing does **not** block terrain parity — all implementation stays **PORT APPROXIMATION**, no donor visual parity claim.

*End of X31 report. Exactly one repo file written; no donor binary executed or copied; no source, asset, config, test, git or Godot/runner state changed; no donor visual parity claim.*
