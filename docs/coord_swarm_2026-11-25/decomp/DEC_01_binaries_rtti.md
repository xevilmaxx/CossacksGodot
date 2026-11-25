---
id: DEC-01
title: Donor binaries, packer, RTTI and .cdx/codex files — deep decompilation record
area: donor decompilation (documentation only)
owner: DEC-01 micro-worker
date: 2026-11-25
status: COMPLETE — read-only, no donor executed, no donor bytes copied into repo
labels: observed | derived | inferred | UNVERIFIED
---

# DEC-01 — Donor binaries, packer, RTTI, `.cdx`/codex files

Private-use investigation record for the Cossacks 3 → Godot 4.x singleplayer port.

## 1. Goal

Document the installed donor's **root PE binaries and their companion files** as citable
evidence: identity, PE structure, packer/protection indicators, compiler/runtime markers,
imports/exports/resources, version strings, embedded paths, the Delphi class-name (RTTI)
surface, and — above all — what the `.cdx` files actually are. Every claim carries an
evidence id (`D1E##`) that resolves to an exact `path:offset` or an exact byte/list result
in §11. No claim is offered without a label.

**Constraints honoured (observed).** Donor opened **read-only** via Python 3.14 `bytes`
with latin-1 decoding only (`python`, never `python3`). No donor executable was run, no
donor file was copied/converted into the repository, no memory dump, Frida/GDB/rizin,
unpacking or network access. The only repository file written is this report. Analysis
scripts live in `%LOCALAPPDATA%\Temp\opencode\dec01_*.py` (outside the repo, not committed).
No binary blobs are pasted below — only short hex excerpts (≤64 B) and latin-1 strings.

**Tool note.** Craft Anything `core_investigation_show` was called and reported
`stored_in: "session (no project open)"`, `revision: 0`, no findings; to avoid writing
investigation memory shared with other subagents, all evidence below was minted locally
from exact byte reads, as the lane charter permits ("otherwise cite exact `path:offset`
plus a short hexdump/latin-1 excerpt").

---

## 2. Prior docs read (all read before analysis)

| Document | What it contributed / where this report extends or corrects it |
|---|---|
| `docs/decomp/DA_PE.md` | Evidence ids `ev_e7533ff3…`, `ev_60b49743…`, etc.; 6-PE triage, `.bind` 7.96, `WUS1` 7.91, 111 `X*` / 474 `T*` names, 18,918 functions / 12,073 strings. Corrected here: entry-section attribution, "Rich" interpretation, `.exe` vs `.cdx` identity. |
| `docs/decomp/DECOMP.md` | **Not present** on disk — read attempted, `File not found`. Recorded honestly. |
| `docs/audit/DECOMP.md` | Independent re-verification discipline: separate observed/derived/inferred; "a count is only as good as its parser". Its DA row explicitly left PE triage UNVERIFIED — this report partially closes that gap with a different method. |
| `investigation.cany/investigation/{brief,findings,hypotheses,plan,handoff}.md` | `fnd_4`: entry `0x8f1a08` "packed loader"; `hyp_1`: rules live in data/scripts because EXE is packed; handoff: `native_strings_find` zeros for unit names. This report confirms the *data lives outside* half, refines the packed-entry claim. |
| `docs/coord_swarm_2026-11-24/reports/DECOMP_01_craft_anything_donor.md` | Original target table + SHA of `cossacks.exe`; entry `0x8f1a08` **attributed to `.bind`** — corrected here. |
| `…/DECOMP_05_static_vs_runtime.md` | Static decompilation feasible function-by-function; `core_packed_files_list` refuses `cossacks.exe`; `.bind` is not an enumerable archive. No runtime unpacking recommended. Accepted, not re-run. |
| `…/DECOMP_04_strings_config.md` | `native_strings_find` is data-sections-only; whole-file `native_bytes_find` finds `SphereHeight`, `hmapTex`, etc. in `CODE`; leading punctuation on `.rsrc` names is a prefix byte. Confirmed independently by hexdump here (§8). |
| `docs/coord_swarm_2026-11-25/decomp/README.md` | Governing rules, report table, evidence-index expectation. |

---

## 3. File inventory

All sizes and hashes from direct read; SHA-256 truncated only where shown. `D1E01`, `D1E08`.

| File | Bytes | SHA-256 (first 16 hex) | PE summary |
|---|---:|---|---|
| `cossacks.exe` | 5,768,048 | `87f0f3c130b027e7` | PE32 x86, 10 sec, entry RVA `0x4f1a08` (in `CODE`), imagebase `0x400000`, subsystem 2 (GUI) |
| `cossacks.cdx` | 5,768,048 | `1a88936e831966d` | same sections; entry RVA `0x56c310` (in `.bind` +`0x310`) |
| `editor.exe` | 7,874,416 | `68474ddde43fe4a` | PE32 x86, 10 sec, entry RVA `0x6259b8` (in `CODE`) |
| `editor.cdx` | 7,874,416 | `1ff4020ccbd77db` | entry RVA `0x76f310` (in `.bind` +`0x310`) |
| `config.exe` | 4,645,744 | `cddfee5587f2895` | PE32 x86, 10 sec, entry RVA `0x3ed85c` (in `CODE`) |
| `config.cdx` | 4,645,744 | `613625b3789d16e` | entry RVA `0x458310` (in `.bind` +`0x310`) |
| `modman.exe` | 4,463,984 | `0d7db745f7f0787` | PE32 x86, **9 sec** (no `.edata`), entry RVA `0x3c5648` (in `CODE`) |
| `modman.cdx` | 4,463,984 | `23d6a9a386f1870` | entry RVA `0x42c310` (in `.bind` +`0x310`) |
| `codex.dll` | 106,272 | `382a9594091017` | PE32 x86 DLL, 3 sec (`WUS0`, `WUS1`, `.rsrc`), entry RVA `0x4a7d0`, imagebase `0x10000000` |
| `steam_api.cdx` | 213,072 | `5d58f6ea6d46d4` | PE32 x86 DLL, 5 sec, 778 exports; differs from `steam_api.dll` by 11 bytes |
| `steam_api.dll` | 213,072 | `1538b7859ad7de` | PE32 x86 DLL, Valve Steam Client API, 778 exports |
| `GameOverlayRenderer.dll` | 1,178,912 | `e179bc6d239621` | PE32 x86 DLL, Valve overlay, 14 exports |
| `cossacks.ini` | 161 | `7d75ed2244f974` | text (Delphi `section.begin` format), not PE |
| `editor.ini` | 451 | `3ef1ab6f03749a` | text, not PE |
| `steam_emu.ini` | 1,712 | `39c321a95f9806` | CODEX Steam-emulator config, not PE |
| `steamscript.vdf` | 680 | `f6feb07fd4f84b` | Steam install script (Valve KeyValues), not PE |

**Section table, `cossacks.exe` (observed, `D1E03`; cross-checked against raw header bytes
at `0x100` and against `cossacks.cdx`, whose table is byte-identical).** `rsize` = raw size,
`raddr` = raw file offset; entropy is Shannon entropy of the raw section bytes.

| Section | RVA | vsize | rsize | raddr | Entropy | Flags (observed) | Notes |
|---|---:|---:|---:|---:|---:|---|---|
| `CODE` | `0x1000` | 5,180,840 | 5,180,928 | `0x400` | **6.609** | `0x60000020` (code/execute/read) | bulk game logic; statically analysable |
| `DATA` | `0x4f2000` | 44,580 | 45,056 | `0x4f1200` | 4.217 | `0xc0000040` (init data/read/write) | Delphi RTL strings |
| `BSS` | `0x4fd000` | 36,977 | 0 | `0x4fc200` | 0.000 | `0xc0000000` | uninitialised |
| `.idata` | `0x507000` | 16,652 | 16,896 | `0x4fc200` | 5.035 | `0xc0000040` | import descriptors/names |
| `.edata` | `0x50c000` | 149 | 512 | `0x500400` | 1.845 | `0x50000040` | 3 export names only |
| `.tls` | `0x50d000` | 44 | 0 | `0x500600` | 0.000 | `0xc0000000` | TLS |
| `.rdata` | `0x50e000` | 24 | 512 | `0x500600` | 0.211 | `0x50000040` | 24 bytes |
| `.reloc` | `0x50f000` | 248,196 | 248,320 | `0x500800` | 6.715 | `0x50000040` | base relocations |
| `.rsrc` | `0x54c000` | 128,000 | 128,000 | `0x53d200` | 5.081 | `0x50000040` | **Delphi RTTI/unit names + Windows resources** |
| `.bind` | `0x56c000` | 146,800 | 146,800 | `0x55c600` | **7.965** | `0x60000000` (code/execute, *not* marked writable or initialised) | high-entropy stub |

`editor.exe`, `config.exe`, `modman.exe` have the **same section names, same per-section
entropy profile and the same 146,800-byte `.bind`**; only `.rsrc` size differs materially
(editor 907,264 B vs game 128,000 B — consistent with the editor's large form/property
resource set). `D1E04`–`D1E06`.

**Optional-header values, `cossacks.exe` (observed, `D1E02`).** `e_lfanew = 0x100`;
`Machine = 0x14c` (i386); `NumberOfSections = 10`; `TimeDateStamp = 0x2A425E19`;
`SizeOfOptionalHeader = 224`; `Characteristics = 0x81ae`; magic `0x10b` (PE32);
`AddressOfEntryPoint = 0x4f1a08`; `BaseOfCode = 0x1000`; `BaseOfData = 0x4f2000`;
`ImageBase = 0x400000`; `SectionAlignment = 4096`; `FileAlignment = 512`;
`MajorSubsystemVersion = 4`; `Subsystem = 2` (Windows GUI); `CheckSum = 0`;
`NumberOfRvaAndSizes = 16`.

**Double verification of the header:** (a) `struct.unpack_from` of the optional header,
(b) direct hexdump of `cossacks.exe:0x128` = `08 1a 4f 00 00 10 00 00`, i.e. entry RVA
`0x004F1A08` followed by `BaseOfCode = 0x1000`; (c) the same field read on all eight
EXE/CDX pairs produced mutually consistent values (`D1E09`). Header-vs-body cross-check:
VA `0x9587c3` (a `.rsrc` RTTI name) maps to file offset `0x5499c3` via
`0x53d200 + (0x9587c3 − 0x400000 − 0x54c000)`; the byte there is the start of
`XTerrainDataLite` (`D1E17`), matching the earlier DECOMP-01 mapping exactly.

---

## 4. Packer / runtime assessment

| Claim | Label | Evidence |
|---|---|---|
| All five game/config EXEs and `codex.dll`/`steam_api*.dll` are 32-bit PE32 (`Machine 0x14c`, magic `0x10b`). | **observed** | `D1E02`–`D1E07` |
| One 146,800-byte section named `.bind` exists in every one of the four game/config EXEs, with raw entropy **7.964–7.965**; `codex.dll` has `WUS1` at **7.905**. All other sections are ≤6.73. | **observed** | `D1E03`–`D1E07` |
| The `.bind` bytes look high-entropy enough to be compressed or encrypted, and the compiler timestamp `0x2A425E19` is the classic Borland/Delphi fixed stamp. | **inferred** (heuristics; markers can be faked) | `D1E02`, `D1E11`, `D1E16`, `D1E28` |
| Whether `.bind` actually contains packed code, encrypted data, or simply a large random-looking table is **UNVERIFIED** — no donor process was run, no memory dump taken, and Craft Anything `core_packed_files_list` refused both `cossacks.exe` and `codex.dll` as "not a container" (independently reproduced here, matching `DECOMP_05`). | **UNVERIFIED** | `D1E11`, `D1E29`; prior `DECOMP_05` §refusals |
| The packer is **localised, not global**: `CODE` (5.18 MB, entropy 6.61) is present as ordinary x86 and was previously decompiled function-by-function by Craft Anything/Ghidra (`FUN_00404628`, entry, `sub_7ab704`). Nothing in this report contradicts that. | **derived** from `D1E03` + prior reports | `D1E03`, prior `DA_PE.md` §3, `DECOMP_05`, `DECOMP_04` §8 |
| The 4-byte `AddressOfEntryPoint` is the **only** field changed between each `.exe` and its `.cdx` twin (3 differing bytes at `0x128`–`0x12a`; the high byte was already `0x00`). | **observed**, verified twice (full-file byte diff + raw hexdump) | `D1E09` |
| `.bind` content is **not** a shared, enumerable archive: hashes differ per binary (`f76f3a33…` game, `73d66fc4…` editor, `9852cc40…` config, `f3ba06f8…` modman), but each `.exe`/`.cdx` twin shares the same `.bind` hash. | **observed** | `D1E11` |
| No runtime unpacking is justified for the port: at most ~146 KB of a 5.7 MB EXE is high-entropy, and gameplay values live in external `data/**` text (§10). | **inferred** (port prioritisation, not a byte fact) | `D1E03`, `D1E20`, prior `DECOMP_05` verdict |

**Compiler/runtime markers (observed, `D1E16`, `D1E26`, `D1E28`):**
- `cossacks.exe:0x4e379c` contains `Delphi%.8X\0\0…ControlOfs%.8X%.8X` — a Delphi RTL
  exception-format string, not a version string.
- `editor.exe:0x3205ae` and `0x320696` contain `Borland\C++Builder` and
  `Borland\C++Builder\` — explicit C++Builder linkage.
- Delphi unit names in `.rsrc`: `System`, `SysUtils`, `SysInit`, `Math`, `Forms`, `IniFiles`,
  `Clipbrd`, `FastMM4`, `IdUDPClient`, `OSWGeometry`, … (`D1E18`). `FastMM4` is the Delphi
  memory manager; Indy (`Id*`) is the Delphi networking library.
- **Correction to a tempting reading:** the 8 `Rich` byte-hits in each game EXE are **not**
  MSVC Rich headers. `cossacks.exe:0x86b6` sits inside the ASCII run
  `2004 - 2011 Pierre le Riche / Professional Softw…` (`D1E26`). The `codex.dll` `Rich` at
  file offset `0xe0` **is** a real Rich header (it sits immediately before the PE signature
  at `0x100`), so that specific DA claim stands (`D1E07`).

---

## 5. Imports, exports, resource tables, version info

**Imports of interest (observed, `D1E12`).** The four game/config EXEs share the same 27
descriptor names (some duplicated descriptors): `kernel32.dll`, `user32.dll`, `advapi32.dll`,
`oleaut32.dll`, `version.dll`, `gdi32.dll`, `ole32.dll`, `comctl32.dll`, `imm32.dll`,
`shell32.dll`, `wininet.dll`, `comdlg32.dll`, **`GLU32.dll`, `opengl32.dll`, `d3d9.dll`**,
`winmm.dll`, `wsock32.dll`, **`PowrProf.dll`**. `editor.exe` additionally imports
`winspool.drv`; `modman.exe` omits `d3d9.dll`.

`codex.dll` imports `KERNEL32.DLL`, `GameOverlayRenderer.dll`, `ntdll.dll`, `PSAPI.DLL`,
`SHELL32.dll`, `SHLWAPI.dll`, **`steamclient.dll`**.
`steam_api.dll` imports `KERNEL32.dll`, `ADVAPI32.dll` and a DLL literally named
**`CODEX`** (`D1E12`, `D1E25`). `GameOverlayRenderer.dll` imports `WINMM`, `IMM32`,
`KERNEL32`, `USER32`, `GDI32`, `ADVAPI32`, `ole32`, `PSAPI` — Steam overlay boilerplate.

**Exports (observed, `D1E13`).**

| File | Export DLL name | Functions / names | Representative names |
|---|---|---|---|
| `cossacks.exe` | `engine.exe` | 3 / 3 | `AmdPowerXpressRequestHighPerformance`, `NvOptimusEnablement`, `SFEncodeDT` |
| `editor.exe` | `editor.exe` | 3 / 3 | same three |
| `config.exe` | `config.exe` | 2 / 2 | `AmdPowerXpressRequestHighPerformance`, `NvOptimusEnablement` |
| `modman.exe` | — | no export directory | — |
| `codex.dll` | **`wus.dll`** | 2 / 2 | `ShellExecuteA`, `ShellExecuteW` |
| `steam_api.dll` / `.cdx` | `steam_api.dll` | **778 / 778** | `SteamAPI_Init`, `SteamUser019`-style call-result helpers, … |
| `GameOverlayRenderer.dll` | `GameOverlayRenderer.dll` | 14 / 14 | `IsOverlayEnabled`, `OverlayHookD3D3`, `VulkanSteamOverlayPresent`, … |

The two GPU-vendor exports are a standard DOS/Windows trick to request the discrete GPU;
they are **not** gameplay API. `SFEncodeDT` is the only game-specific export name, and its
implementation is not studied here (**UNVERIFIED** role).

**Resource table (observed, `D1E14`).** Top-level resource directory at `.rsrc:0` (file
`0x53d200`): all four game/config EXEs carry **9 ID-type resources**
`#1` cursor, `#2` bitmap, `#3` icon, `#5` dialog, `#6` string, `#10` RCDATA,
`#12` group cursor, `#14` group icon, `#16` version. `codex.dll` carries only `#16`
(version); `steam_api.dll` carries `SCID` + `#16`; `GameOverlayRenderer.dll` carries
`SCID`, `WEVT_TEMPLATE`, `#1`, `#11`, `#12`, `#16`. Double check: the same nine type IDs
were obtained from the directory headers and independently from the UTF-16 string scan
which found `VS_VERSION_INFO`, `StringFileInfo`, `040904E4`, `VarFileInfo`, `Translation`
(`D1E15`).

**Version resources (observed, `D1E15`).**

| File | CompanyName | FileVersion | ProductName | ProductVersion |
|---|---|---|---|---|
| `cossacks.exe` | GSC Game World | **2.0.0.1199** | Cossacks 3 | 1.0.0.0 |
| `editor.exe` | GSC Game World | **2.0.0.2843** | Cossacks 3 | 1.0.0.0 |
| `config.exe` | GSC Game World | **2.0.0.2098** | Cossacks 3 | 1.0.0.0 |
| `modman.exe` | GSC Game World | **2.0.0.2116** | Cossacks 3 | 1.0.0.0 |
| `codex.dll` | **ACME Corporation** | n/a | **WUS** | 01.00.00.01 |
| `steam_api.dll` | Valve Corporation | 03.42.61.66 | Steam Client API | 01.00.00.01 |
| `GameOverlayRenderer.dll` | Valve Corporation | 04.69.34.61 | Steam Game Overlay Renderer | 01.00.00.01 |

`codex.dll` also declares `InternalName = WUS` and
`FileDescription = "o()xxxx[{::::::::::::::::::::::::::::::::::>"` (a joke string),
corroborating its internal section names `WUS0`/`WUS1` and export DLL name `wus.dll`.
The four different `FileVersion` values show these are four distinct builds, not copies
of one binary (derived).

---

## 6. RTTI / class-name catalog

**Format observation (`D1E17`, twice verified).** The `.rsrc` unit/class table is a
sequence of Delphi **short strings**, each preceded by a length/flag byte, e.g.:

```
cossacks.exe:0x549848  10 45 58 54 65 72 72 61 69 6e 00 10 15 58 52 65 6e 64 65 72 50 6f 6f 6c 00
                       ·  E  X  T  e  r  r  a  i  n  ·  ·  ·  X  R  e  n d e r P o o l  ·
```

The byte `0x10` before `EXTerrain`, the `0x15` before `XRenderPool`, and the `0xf9`
before `XTerrainDataLite` are **prefix/length metadata, not part of the class name** —
matching DECOMP-04's `native_data_show` correction. Label: **observed** bytes;
**inferred** that this is Delphi RTTI/unit metadata (it is not a live-string table: prior
`core_feature_find` returned 0 functions/xrefs for these names).

**Count discipline.** My curated scan (ASCII runs ≥3 chars in `.rsrc`, regex
`[A-Za-z_][A-Za-z0-9_]{2,40}`, garbage filter requiring ≥3 distinct letters) yields
**3,730 curated tokens**, of which **112 are `X*`/`EX*`/`HX*` names** and **~886 are
`T*`-prefixed strings** (the latter mostly *form field/property* names like `Top`,
`TabOrder`, `TMenuItem`, not distinct classes). This differs from DA_PE's "111 `X*` and
474 `T*`" only because of filter choice — **derived**, not a contradiction.

**Porting-relevant subset, with exact offsets (`D1E18`; `VA = file offset + 0x40FC00` for
the `.rsrc` range; all label **observed** as strings, **inferred** as RTTI metadata).**

| Subsystem | Names (file offset → VA) |
|---|---|
| Terrain / heightfield | `EXTerrain` `0x549849→0x958649`; `XTerrainDataLite` `0x5499c3→0x9587c3`; `XTerrainData` `0x549d75→0x958b75`; `XTerrainBorders` `0x9593b4`; `HXHeightField` `0x549ca2→0x958aa2`; `XHeightField` (CODE, DECOMP-04); `XTile` `0x549be9→0x9589e9`; `XTileSmooth` `0x54a616→0x959416`; `XTileSeason` `0x9593a5`; `XTopology` `0x549ea7→0x958ca7`; `XCliff` `0x54a59d→0x95939d`; `XColorTable` `0x549cb9→0x958ab9`; `XBrush` `0x5499d6→0x9587d6`; `XPattern` `0x54a571→0x959371`; `XGrids` `0x54a84f→0x95964f`; `XBits` `0x54a913→0x959713`; `XCollisionMask` `0x549bc7→0x9589c7`; `XCollisionTags` `0x549c13→0x958a13` |
| World / map / generation | `XWorld` `0x549be0→0x9589e0`; `XMap` `0x549ca?→0x958ab2`; `XGlobalMap` `0x54a5e2→0x9593e2`; `XMapGenerator` `0x54a630→0x959430`; `XCastleCollection` `0x54a2d6→0x9590d6`; `XCastleScheme` `0x54a672→0x959472`; `XWallConstructor` `0x54a2ea→0x9590ea`; `XSchemeObject` `0x54a64f→0x95944f`; `XScenario` `0x54a6d3→0x9594d3`; `XTown` `0x54a60e→0x95940e`; `XPicked` `0x54a2fd→0x9590fd`; `XTrackNode` `0x54a5d5→0x9593d5`; `XTrackPoint` `0x549a01→0x958801`; `XSeason` `0x54a593→0x959393`; `XSeasonType` `0x54a310→0x959110` |
| Render / FX / sky / water | `XRenderer` `0x54a6df→0x9594df`; `XRenderPool` `0x549855→0x958655`; `XShadowMap` `0x549c96→0x958a96`; `XSkyDome` `0x549d52→0x958b52`; `XHorizonRender` `0x549ef1→0x958cf1`; `XFOWRender` `0x549f0d→0x958d0d`; `XWater` `0x54a58a→0x95938a`; `XWaterShader` `0x958c10` (CODE/`.rsrc`, DECOMP-04); `XClouds` `0x54a807→0x959607`; `XAir` `0x549cd8→0x958ad8`; `XStars` `0x549cdf→0x958adf`; `XEnvironment` `0x549d5d→0x958b5d`; `XPHDR` `0x549ce8→0x958ae8`; `XPHDRFilterShader` `0x549d05→0x958b05`; `XPHDRGaussShader` `0x549d19→0x958b19`; `XLightShader` `0x549c87→0x958a87`; `XXLightSourceManager` `0x549d3b→0x958b3b`; `XParticleFX` `0x549f78→0x958d78`; `XDecalSet` `0x54a565→0x959365`; `LXShaderLOD` `0x95862e` |
| Camera / script / AI | `IXDScriptCamera` `0x54a810→0x959610`; `XCamera` `0x958b6b`/`0x959066` (from prior handoff; not re-derived here — **UNVERIFIED** by this worker); `XStateMachine` `0x549a0f→0x95880f`; `XGameObject` `0x5499eb→0x9587eb`; `XBaseActor` `0x549fbb→0x958dbb`; `XArmiesViewer` `0x54a718→0x959518`; `XDMScript` `0x549f1a→0x958d1a`; `XDScriptParser` `0x54a450→0x959250`; `XDScriptBehaviour` `0x54a497→0x959297`; `XDScriptTrigger` `0x54a512→0x959312`; `XDScriptEditor` `0x54a822→0x959622`; `XQueryMachine` `0x54a478→0x959278`; `XDScriptSteamAPP` `0x54a12b→0x958f2b`; `dsCompiler` `0x54a884→0x959684`; `dsDebugger` `0x958fb2` |
| OSW engine units (48 curated) | `OSWGeometry` `0x54980f→0x95860f`, `OSWVectorTypes` `0x54981d`, `OSWUtils` `0x54982e`, `OSWSerializer` `0x549879`, `OSWOpenGL` `0x549958`, `OSWGraphicsFormats` `0x549964`, `OSWTextureCombiners` `0x549e20`, `OSWAtmosphere` `0x54a03e`, `OSWFileOSS` `0x54a0c8`, `OSWFileOSM` `0x54a0eb`, `OSWFileLWO` `0x54a0d5`, `OSWParticleFX` `0x549f68`, `OSWAnimatedSprite` `0x549f96`, `OSWPad`→`OSWPak` `0x54ab30`, `OSWGPUExport` `0x54aed0`, `OSWSound`/`OSWSMOpenAL`/`OSWSMFMOD` `0x54a3aa`/`0x54a3df`/`0x54a402`, `OSWKeyboard` `0x54a432`, `LOSWMovement` `0x54a4e5` — full 48-name list in `D1E18` |
| Forms / tools (UTF-16 resource names, `D1E15`) | `TFORMCONFIG` `0x53e2cc`, `TFORMDBGCTRL` `0x53e2e4`, `TFORMDWSDEBUGGER` `0x53e2fe`, `TFORMHELLOSCREEN` `0x53e320`, `TFORMSCRIPTEVALUATE` `0x53e342`, `TFORMSTATEMACHINES` `0x53e36a`, `TFRMDEBUG` `0x53e390`, `TFRMSCRIPTFIELDS` `0x53e3a4`, `TMAINFORM` `0x53e3c6`, `TMEMOEDITOR` `0x53e3da`, `TPROGRESSFORM` `0x53e3f2`, `TAIXEDITOR` `0x53e27a`, `TAIXARGSEDITOR` `0x53e27a`, `TAIXVARSEDITOR` `0x53e2ae` |

**Editor delta (`D1E19`, observed).** `editor.exe` carries **8,090 curated tokens not
present in `cossacks.exe`** (name-set difference, method-dependent). Representative:
`AdvancedCameraEditor`, `AdvancedMapGeneratorItem`, `AdvancedTerrainBorder`,
`AdvancedResetHeightFieldItem`, `AdvancedModifyTilesetSeason1`, `AdvancedReplaceCliffTypeItem`,
`AngleCollisionTagCollection`, `AfrmCustomShader`, `AtmosphereRadius`, `AutoRayCast`,
`AutoNormalizeTerrain`, `AlphaFade`, `AvgLumR/G/B`, `AnimationNameMove`,
`AnimationNameStand`, `AccelerationModeCameraMove`. This is a strong **inferred** signal
that the editor, not the game EXE, is where terrain/camera/shader *parameter surfaces*
are named — consistent with prior DECOMP-04's "values live in external data".

**Caveat (observed + inferred).** These names are **metadata with no established code
xrefs** (`DECOMP_01`, `DECOMP_05`, `DECOMP_04` §4 all report 0 functions/0 xrefs per name).
They map *subsystems*, not implementing functions. Treating them as a class hierarchy to
replicate in Godot would be an unjustified inference.

---

## 7. The `.cdx` files and the `codex` runtime

**Primary result (observed; verified twice by full-byte diff and raw hexdump, `D1E09`).**
Each `.cdx` is **byte-identical to its `.exe` twin except for the 4-byte PE
`AddressOfEntryPoint` field at file offset `0x128`** (only its low 3 bytes differ):

| Pair | `.exe` bytes @`0x128` → entry RVA | `.cdx` bytes @`0x128` → entry RVA | Entry section |
|---|---|---|---|
| cossacks | `08 1a 4f 00` → `0x4f1a08` | `10 c3 56 00` → `0x56c310` | `CODE` → **`.bind` +0x310** |
| editor | `b8 59 62 00` → `0x6259b8` | `10 f3 76 00` → `0x76f310` | `CODE` → **`.bind` +0x310** |
| config | `5c d8 3e 00` → `0x3ed85c` | `10 83 45 00` → `0x458310` | `CODE` → **`.bind` +0x310** |
| modman | `48 56 3c 00` → `0x3c5648` | `10 c3 42 00` → `0x42c310` | `CODE` → **`.bind` +0x310** |

The uniform `+0x310` offset into `.bind` across four unrelated binaries (derived) is
consistent with one generic injected loader stub occupying the first ~0x310 bytes of
the section; the remaining ~146 KB is per-binary encrypted/packed content (`D1E11`,
different hashes). **Inferred**: the `.cdx` entry stub runs first and transfers control to
the original program — but the stub is *not* statically readable here, so the exact
transfer mechanism is **UNVERIFIED** (no donor was executed).

**Corroborating `codex` file family (all observed):**
- `codex.dll` — internal name `WUS`, export DLL name `wus.dll`, sections `WUS0`/`WUS1`,
  real MSVC Rich header at `0xe0`, imports `steamclient.dll` + `GameOverlayRenderer.dll`
  (`D1E07`, `D1E12`, `D1E13`, `D1E15`).
- `steam_api.dll:0x2d6a4` contains the imported DLL name **`CODEX\0!WUS!\0…`**; its
  `.cdx` twin has **`SHELL32.dll\0…`** in exactly those 11 differing bytes (`D1E25`).
- `steam_emu.ini:0` is a Steam-emulator config: `AppId=333420`, `UserName=CODEX`,
  `Language=russian`, `DLCUnlockall=1`, interface pins `SteamClient017`, `SteamUser019`,
  and a `[Crack]` section of 4 key/value hashes (`D1E23`).
- `steamscript.vdf` sets `DisableNXShowUI` on `cossacks.exe`, `config.exe`, `editor.exe`
  (DEP compatibility) and opens a firewall rule "Cossacks 3 Game" (`D1E24`).

**Conclusion (inferred, high confidence but not runtime-proven):** `.cdx` = *Codex-patched
copy of the same executable*: the original PE bytes are untouched, the entry is redirected
into the injected `.bind` stub, and the `codex.dll`/`steam_api.dll`/`steam_emu.ini` trio is
the accompanying Steam emulator. The `.exe` files keep their original `CODE` entry and
are therefore the better static-analysis targets. This is a packaging/protection detail
of this private install, **not** a Cossacks 3 game system to port.

---

## 8. Strings of porting interest

All offsets below are file offsets in `cossacks.exe` unless noted; label **observed** as
bytes, **inferred** as to role. Config-key semantics were independently decompiled by
DECOMP-04 §8 (`sub_7ab704`); those interpretations are cited, not re-derived here.

| Category | Exact token(s) | Offset(s) | Reading |
|---|---|---|---|
| Version/product | `Cossacks III` | `0x4d2af0`, `0x4f118c` | window title / message-box literal; `Version 1.0` at `0x49386c` |
| Version helpers | `GetBuildVersion`, `GetMapVersion`, `GetCoreVersion`, `GetMapCoreVersion`, `BuildVersion`, `FileGameMapVersion`, `MapCoreVersion`, `ProjectBuildVersion` | `0x20a344`, `0x20a370`, `0x20a398`, `0x20a3c4`, `0x31084c`, `0x30e7ff`, `0x30e82c`, `0x30f292` | **observed** identifiers for build/map-version checks; values external |
| Camera / DOF keys | `MinFocalLength`, `MaxFocalLength`, `FocalLength` | `0x7abf6b`, `0x7abf83`, 16 CODE hits (`DECOMP_04`) | camera restriction object fields (`DECOMP_04` §8) |
| Terrain/restriction keys | `SphereHeight`, `SphereHeightMin`, `MinHeightMinAngle`, `HeightTarget`, `HeightTargetMin`, `SphereLength`, `SphereLengthMin` | `0x7abc44`, `0x7abc5c`, `0x7abe5c`, … | passed to config readers `FUN_008959f8`/`FUN_00896b1c` |
| Fog keys | `DynFogDepth`, `DynFogStart`, `DynFogEnd`, `DynFogDensity`, `DynFogPower`, `DynFogOffset` | `0x7ac0ac` (only hit with xref), `0x5fe437`, `0x5fe46b` (0 xrefs) | boolean/floats on a camera object — **not** a terrain-fog shader parameter (DECOMP-04) |
| Water/effect schema | `waterAmount`, `fresnelPower`, `fresnelBias`, `hdrMultiplier`, `waveFreq`, `waveAmp`, `distFactor`, `bumpFactor`, `texScaleS`, `texScaleT`, `waveDir0`, `waveDir1`, `fogEnabled`, `hmapTex`, `hmapW`, `hmapH`, `hmapMin`, `hmapMax`, `shadowed`, `shadowMap`, `shadowSize`, `shadowColor`, `cameraModel`, `reflectionMap` | around `0x853d00`–`0x8556e4`; `hmapTex` `0x853e0c` | a coherent **parameter-schema initializer** (DECOMP-04 §8). Only string assignment is proven; texture binding/shader use **UNVERIFIED** |
| Generic extensions | `.map` (8 hits), `hmapTex`, `xdds` (`0x5499a3`), `OSWGraphicsFormats` (`0x549964`) | `0x737eec`…; `0x853e0c`; `0x9587a3` | `.map` paths/extension in `CODE`; `.hmap`, `.dds`, `.tga`, `water.dev` are **absent from the whole file** (DECOMP-04 §3) — asset names live in `data/**` |
| External DLL paths | `steamapp.dll` `0x2ec088`, `steamwrap.dll` `0x2ec5d0`/`0x2ee408`, `fmod.dll` `0x16a2d8`, `ogg.dll`/`vorbis.dll`/`vorbisfile.dll` `0x16fb30`…, `openal32.dll` `0x16fffc`, `editor.exe` `0x317788`, `cossacks.exe` `0x4ea0f4`, `update.exe` `0x4ef1c0`, `engine.exe` `0x500446` | observed | runtime dependencies; **inferred** audio stack = FMOD + Ogg/Vorbis + OpenAL |
| Registry paths | `\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers` | `0x206afc`, `0x206c8c` | DEP/compat layer check, corroborated by `steamscript.vdf` |
| Encryption/compression | `deflate 1.0.4 Copyright 1995-1996 Jean-loup Gailly` `0x4f3190`, `inflate 1.0.4 … Mark Adler` `0x4f32bc`, `2004 - 2011 Pierre le Riche / Professional Softw…` `0x86b6` | observed | zlib/compression libraries compiled in — a *plausible* source of `.bind` entropy (inferred) |

Embedded *absolute* paths (`C:\…`) were **not** found in the game binaries; the only
absolute-looking path is `steam_emu.ini`'s `%SystemDrive%\Users\Public\Documents\Steam\CODEX\333420`
(`D1E23`). This is a **UNVERIFIED** absence for path strings constructed at runtime.

**`cossacks.ini` (full text, `D1E21`, observed):** `GameSaveDirectoryPath=cossacks`,
`LogFileEnabled = false`, `LogFileRoot = false`, `LogFileName = cos`, `HideHelloScreen = true`,
wrapped in `section.begin`/`section.end`. **Porting note:** save directory is a single
relative name — no absolute user path is hard-coded.

**`editor.ini` (full text, `D1E22`, observed):** adds `EditorMap =`, `FullScreen = false`,
`DisableDebug = false`, `NoGUI = false`, `FixSize = false`, `FixPos = false`,
`FixSize.Width/Height/Left/Top = 800/600/50/50`, `AutoRunState = OnAutoRunEditor`,
`ConstLODFactor = 1.0`, plus the same logging/save keys. `ConstLODFactor` is a concrete
editor-side LOD tuning knob (**observed** key; value semantics **UNVERIFIED** in code).

---

## 9. Corrections to prior docs

1. **`DECOMP_01` / `DA_PE`: "`cossacks.exe` entry `0x8f1a08`, section `.bind`."**
   **Contradicted.** The VA `0x8f1a08` is correct (`0x4f1a08 + ImageBase 0x400000`), but
   `0x4f1a08` lies in `CODE` (RVA `0x1000`–`0x4f1da8`, i.e. `0x4f0a08` into the section),
   **not** in `.bind` (RVA `0x56c000`–`0x58fd70`). Only the `.cdx` entry `0x96c310` (VA;
   RVA `0x56c310`) is in
   `.bind`. Evidence `D1E02`, `D1E03`, `D1E09`, `D1E10`; double-verified by struct parse,
   raw hexdump, and section-membership computation across all 8 files.
2. **"`.cdx` is a different/protected *build* of the same engine."** **Refined.** It is the
   **same file byte-for-byte** except 3 entry-point bytes; there is no separate build,
   no different code, and the same `.bind` bytes exist in the `.exe` too. `D1E09`, `D1E11`.
3. **"Rich header ⇒ MSVC toolchain" for the game EXEs.** **Contradicted for the four game
   EXEs** (`Rich` hits are the ASCII substring in "Pierre le Riche"); **stands for
   `codex.dll`** (Rich at `0xe0` immediately before `PE\0\0`). `D1E07`, `D1E26`.
4. **"111 `X*` / 474 `T*` classes."** **Method-dependent, not wrong.** My filter finds
   112 `X*`-prefixed names and ~886 `T*`-prefixed *strings*, most of which are form
   field/property names rather than classes. Do not read these counts as stable class
   totals. `D1E18`.
5. **"Delphi/C++Builder marker" (weak heuristic).** **Strengthened:** explicit
   `Borland\C++Builder` at `editor.exe:0x3205ae`, `Delphi%.8X` at
   `cossacks.exe:0x4e379c`, `0x2A425E19` timestamp, and Delphi unit/`FastMM4`/Indy names.
   `D1E16`, `D1E28`, `D1E18`.
6. **DA_PE's six-PE table** omitted `steam_api.dll`/`steam_api.cdx`; this is a scope
   difference, not an error. `codex.dll`'s "Steam-side runtime" role is now corroborated
   by its `steamclient.dll` import, `wus.dll` export name and the CODEX emulator config.
   `D1E07`, `D1E12`, `D1E13`, `D1E23`.

---

## 10. Porting implications

1. **Analyse the `.exe`, never the `.cdx`.** The `.exe` has the original `CODE` entry;
   decompilation effort should target `cossacks.exe` / `editor.exe` / `config.exe` as-is.
   The `.cdx` twins add no code. (`derived` from `D1E09`, `D1E10`.)
2. **Do not port the Steam/Codex layer.** `codex.dll`, `steam_api*.dll`,
   `GameOverlayRenderer.dll`, `steam_emu.ini`, `steamscript.vdf` are distribution/DRM
   plumbing of this private install. The Godot singleplayer port needs none of it; the
   `steamscript.vdf` `DisableNXShowUI` hint only explains an old DEP quirk.
   (`inferred` from `D1E07`, `D1E12`–`D1E15`, `D1E23`, `D1E24`.)
3. **The binaries are a subsystem map, not a rules source.** The only numbers recovered
   from the EXE are *parser field offsets and key names* (`SphereHeight`, `DynFogDepth`,
   camera/water schema), not gameplay values. Rules and values remain in `data/**` text
   — the standing conclusion of `hyp_1`, DA-3 and DECOMP-04. (`derived`.)
4. **Use the RTTI catalog as a module checklist, not a class tree.** It confirms the donor
   has heightfield, tile, colour-table, colour-shader, FOW, sky, water, cloud, season,
   map/castle generator, script and GUI abstractions — useful for deciding *which*
   Godot subsystems need an analogue, but with 0 code xrefs it cannot dictate algorithms.
   (`inferred` from `D1E17`–`D1E19`.)
5. **Editor is a richer naming source than the game EXE** for camera/terrain/shader
   parameters (8,090 extra tokens); route DEC-07 (cameras/shaders) and DEC-05 (terrain)
   to `editor.exe`/`editor.ini` first. (`derived` from `D1E19`, `D1E22`.)
6. **`FileVersion` values** (`cossacks.exe` 2.0.0.1199 vs editor 2.0.0.2843 etc.) are a
   provenance check: if a later donor install has different versions, re-run DEC-01 before
   reusing any offsets. (`derived` from `D1E15`.)

---

## 11. Evidence index

| id | Exact source / result |
|---|---|
| `D1E01` | `Get-ChildItem C:\Games\Cossacks 3 -File` — 22 files; sizes in §3. |
| `D1E02` | `cossacks.exe` optional header via `struct.unpack_from` at `e_lfanew+4+20` (`0x118`); fields in §3; cross-checked with `D1E09` hexdump. |
| `D1E03` | `cossacks.exe` 10 section headers at `0x118+224 = 0x1f8`; table in §3; raw `.bind` at `0x55c600`: `25 99 bb dd 4a fa bb bb …`. |
| `D1E04` | `editor.exe` header/sections: entry RVA `0x6259b8`, `.rsrc` RVA `0x691000` size 907,264, `.bind` RVA `0x76f000` size 146,800 entropy 7.965. |
| `D1E05` | `config.exe` header/sections: entry RVA `0x3ed85c`, `.rsrc` 126,464, `.bind` RVA `0x458000`. |
| `D1E06` | `modman.exe` header/sections: 9 sections (no `.edata`), entry `0x3c5648`, `.bind` RVA `0x42c000`. |
| `D1E07` | `codex.dll` header: `nsec=3`, `TimeDateStamp=0x577AA96F`, `ImageBase=0x10000000`, exports DLL name `wus.dll`; sections `WUS0` (rsize 0), `WUS1` entropy 7.905 at `0x400`, `.rsrc` 2,560 B; `WUS1:0x400` = `25 dd df ff e8 0a 00 08 …`; `0xe0` = `52 69 63 68 e5 76 28 63 …` (Rich). |
| `D1E08` | SHA-256 for all 16 targets, e.g. `cossacks.exe` `87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c`. |
| `D1E09` | Full-byte diffs (3 bytes @`0x128`–`0x12a` for each EXE/CDX pair) + hexdumps: `cossacks.exe:0x128` `08 1a 4f 00`, `cossacks.cdx:0x128` `10 c3 56 00`; analogous for other 3 pairs; `steam_api` diff 11 bytes @`0x2d6a4`–`0x2d6ae`. |
| `D1E10` | Entry membership computed for 8 files: all `.exe` in `CODE`, all `.cdx` in `.bind` at `+0x310`. |
| `D1E11` | `.bind` SHA-256 prefixes: game `f76f3a3398faf8b6115d04aa`, editor `73d66fc47f7a1a844840b3b1`, config `9852cc40b76240f70c3bca72`, modman `f3ba06f8aeeb8e188cb7788f`; `cossacks.cdx` = game hash. |
| `D1E12` | Import descriptor name lists for 7 PEs (§5). |
| `D1E13` | Export directory parse for 8 PEs (§5), including `codex.dll` → `wus.dll`/`ShellExecuteA/W`. |
| `D1E14` | Resource directory headers at each `.rsrc:0+12`: 9 ID types for game/config EXEs; 1 for `codex.dll`; `SCID`+`#16` for `steam_api.dll`. |
| `D1E15` | UTF-16LE printable runs in `.rsrc`: `cossacks.exe:0x55c30a` `VS_VERSION_INFO`, `0x55c3bc` `GSC Game World`, `0x55c428` `2.0.0.1199`, `0x55c504` `Cossacks 3`, `0x55c540` `1.0.0.0`; form class names `0x53e27a`–`0x53e3f2`. |
| `D1E16` | `cossacks.exe:0x4e379c` = `44 65 6c 70 68 69 25 2e 38 58 …` (`Delphi%.8X`); `editor.exe:0x3205ae` = `42 6f 72 6c 61 6e 64 5c 43 2b 2b 42 75 69 6c 64 65 72 …`. |
| `D1E17` | `.rsrc` hexdumps: `cossacks.exe:0x549848` `10 45 58 54 65 72 72 61 69 6e 00 10 15 …`; `:0x5499c2` `f9 58 54 65 72 72 61 69 6e 44 61 74 61 4c 69 74 65 …`; `:0x549ca1` `10 48 58 48 65 69 67 68 74 46 69 65 6c 64 …`; `:0x5499a2` `10 78 64 64 73 00 10 7e …`. |
| `D1E18` | Curated RTTI/unit scan of `cossacks.exe:.rsrc` (3,730 tokens; 112 `X*`, 48 OSW; subset tabulated in §6; full group listing in temp output). |
| `D1E19` | `editor.exe` curated name set minus `cossacks.exe` = 8,090 tokens (sample in §6). |
| `D1E20` | Whole-file ASCII scan of `cossacks.exe` (tokens/offsets in §8); plus `0x86b6` context `2004 - 2011 Pierre le Riche / Professional Softw…`. |
| `D1E21` | `cossacks.ini` full 161 B latin-1 text (§8). |
| `D1E22` | `editor.ini` full 451 B latin-1 text (§8). |
| `D1E23` | `steam_emu.ini` full 1,712 B latin-1 text: `AppId=333420`, `UserName=CODEX`, `[Crack]` hashes. |
| `D1E24` | `steamscript.vdf` full 680 B text: `DisableNXShowUI` for 3 EXEs + firewall rule. |
| `D1E25` | `steam_api.dll:0x2d6a0` = `74 65 57 00 43 4f 44 45 58 00 21 57 55 53 21 00 …` (`…CODEX\0!WUS!\0…`); `steam_api.cdx:0x2d6a0` = `74 65 57 00 53 48 45 4c 4c 33 32 2e 64 6c 6c 00 …` (`…SHELL32.dll\0…`). |
| `D1E26` | `cossacks.exe:0x86b6` context — "Rich" is part of "Pierre le Riche", not a Rich header. |
| `D1E27` | Pair sizes identical (5,768,048 / 7,874,416 / 4,645,744 / 4,463,984) but SHA-256 differ (§3). |
| `D1E28` | `TimeDateStamp` decode: `0x2A425E19` = 1992-06-19 (classic Borland/Delphi stamp); `codex.dll` `0x577AA96F` = 2016-07-04; `steam_api.dll` `0x572906DC` = 2016-05-03; overlay `0x5B86FD25` = 2018-08-29. |
| `D1E29` | Independent cross-check: `core_packed_files_list` on `C:\Games\Cossacks 3\cossacks.exe` and `…\codex.dll` both rejected with `{"category":"target","code":"not_supported","message":"This file doesn't carry files in any way we recognise."}` — no member list minted; confirms the `.bind` payload is not an enumerable container. |

---

## 12. Open questions

1. **UNVERIFIED:** does `.bind` contain packed game code, encrypted data, or just a
   large table? Answering it requires executing the donor (prohibited without separate
   consent) or an equivalent memory dump; DECOMP-05 recommends against asking.
2. **UNVERIFIED:** what does the `.bind +0x310` stub actually do, and where does it
   jump? No static disassembly was attempted here (bytes are high-entropy and the
   entry is not in a readable code section).
3. **UNVERIFIED:** `SFEncodeDT` — the single game-specific export. Role unknown.
4. **UNVERIFIED:** `XCamera` exact offsets (`0x958b6b`/`0x959066`) come from the old
   handoff, not re-derived by this worker; `IXDScriptCamera` `0x959610` **was** re-derived.
5. **UNVERIFIED:** runtime semantics of `ConstLODFactor` (`editor.ini`) and the
   water-schema keys beyond string assignment (see DECOMP-04 §8).
6. **Method question:** the `T*`/`X*` counts are parser-dependent; if DEC-02 needs a
   canonical count, fix the regex/filter in one place and rerun across all four EXEs.
7. **Provenance:** the four `FileVersion` values differ; do all donor lanes reference the
   same installation snapshot? If not, offsets may drift between builds.

---

## 13. Summary

- The donor root contains **four paired EXE/CDX game tools**, a **CODEX Steam emulator**
  (`codex.dll` = internal `WUS`, `steam_api.dll` importing `CODEX`, `steam_emu.ini` with
  `[Crack]`), and two genuine Valve Steam DLLs. (`observed` + `inferred`.)
- All four `.cdx` files are **byte-identical** to their `.exe` twins except the 3-byte
  `AddressOfEntryPoint`, which is redirected from `CODE` into the pre-existing `.bind`
  section at a uniform `+0x310`. This is the report's strongest new structural result
  (double-verified). (`observed`/`derived`.)
- The packer signal is **localised**: `.bind`/`WUS1` at ~7.9–8.0 entropy, `CODE` at ~6.61
  and statically analysed before; whether the high-entropy bytes are real packed code is
  **UNVERIFIED** and not worth runtime consent for this port.
- Compiler/runtime identity is Delphi/C++Builder (explicit `Borland\C++Builder`,
  `Delphi%.8X`, `0x2A425E19`, `FastMM4`, Indy, `.rsrc` short-string RTTI), with a Rich
  header only on the MSVC-built `codex.dll`.
- The RTTI catalog gives a **module checklist** (heightfield/tile/colour-table, map/castle
  generation, FOW, sky/water/cloud/PHDR, DMScript, GUI/tools) but **zero code anchors**;
  editor.exe carries 8,090 extra parameter/menu names — the better source for DEC-05/07.
- The one clear correction to prior docs is the **entry-section attribution** of
  `cossacks.exe` (`CODE`, not `.bind`); the `.cdx` entry is the one in `.bind`.

*DEC-01 · private use only · donor never executed or copied · only this report written.*
