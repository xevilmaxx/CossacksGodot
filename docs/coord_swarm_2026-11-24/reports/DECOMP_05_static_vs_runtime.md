---
id: DECOMP-05
title: Static decompilation feasibility vs consented runtime unpacking (cossacks.exe)
area: donor / decompilation / terrain research
owner: DECOMP-05 (subagent)
date: 2026-11-24
status: AUDIT COMPLETE — no donor executed, no unpacking, no binary copied
tools: Craft Anything 0.6.1, native + runtime + frida toolsets enabled for discovery, Deep mode, clean_room=false
---

# Verdict (measured, not inferred)

**Meaningful STATIC decompilation IS feasible in this build of Craft Anything — but only function-by-function, not as a terrain-targeted or whole-program reconstruction.**

- Direct proof: two independent functions were lifted to real pseudo-C by the Ghidra Deep engine — the PE entry point `0x8f1a08` (113 lines, `ev_8fb27745…`) and an arbitrary discovered function `sub_60faa0` / `0x60faa0` (39 lines, `ev_2cbea617…`). The entry dossier is readable: DEP-setting check, single-instance mutex, window creation, `"Cossacks III"`, `MessageBoxA`, `WinExec` (`ev_ea50164c…`). The arbitrary function shows argument marshalling and a virtual call through `(**(code **)*puVar2)()` (`ev_2cbea617…`). This is **not** an empty or stub result.
- The clean-room built-in lifter also produced populated pseudocode, assembly, blocks, callers/callees and flow facets for both functions (`ev_deb2a847…`, `ev_11822820…`, `ev_845bf791…`).
- **What is NOT feasible statically:** reaching *terrain logic*. `core_feature_find` finds 4 terrain strings and **0 functions, 0 imports, 0 code references** (`ev_01c9b39d…`, `ev_b218360c…`). The overview's function list is incomplete (6,000,000-instruction cutoff) with **1,238 unresolved indirect jumps**, stripped `sub_…` names, and an explicit "absence is not proof" limitation (`ev_60b49743…`). The clean-room dossier recovers **no types** (`register_level`) and the arbitrary function's Ghidra dossier was **made on demand** because Ghidra had no function at that address (`ev_2cbea617…`).
- The packing hint is **localised, not global**: the 5,180,840-byte `CODE` segment has entropy 6.61 and was successfully analysed; the 146,800-byte `.bind` segment has entropy 7.96 (`ev_2a27e4cd…`). So "packed" does not mean "all code unreadable".
- `core_packed_files_list` **does not recognise `cossacks.exe` (or `editor.exe`) as any packed-file container** it can enumerate — no members, no paths, no evidence id (tool refused; exact error quoted below). The high-entropy `.bind` bytes are therefore **not** a readable, statically enumerable file archive with this toolset.

**Answer to "is runtime unpacking worth asking the user for?" — NO, not for the terrain-quality work.** It is a large consent, execution and anti-cheat/DRM risk for a marginal gain: at most ~146 KB of a 5.7 MB executable is high-entropy, the readable functions already decompile, and the terrain appearance logic is in external `.rsrc`/data scripts and shaders that neither static nor runtime decompilation of this PE will reveal. Ask only if the user explicitly wants the `.bind` payload recovered for its own sake.

# What was run (all read-only; shared session)

- Target already open: `t_87f0f3c130b0` (`cossacks.exe`, SHA-256 `87f0f3c130b0…e16c`). No `core_target_open` / `core_target_select` was called.
- `enable_toolset({toolset:"native"})` was idempotent (`enabled: []`). `runtime` and `frida` toolsets were later enabled **only to discover tool names**; no runtime tool was executed.
- No donor process launched, no Frida/GDB/Rizin session begun, no script loaded, no memory read, no unpacking, no donor bytes copied into the repo, nothing written into the repo during analysis. Only this report file was written.

# Evidence table

| Analysis call | Subject | Evidence id | Populated facets | Unavailable / empty facets |
|---|---|---|---|---|
| `core_target_triage` (reused from DECOMP-01, read back here) | `cossacks.exe` | `ev_e7533ff33eadc37298d3877bfad230213f3f00888319b896daa71be2b868abc6` | 18 libraries, 6 next steps, 3 recommended toolsets; 2 toolchain hints (Delphi/C++Builder); summary "packed or protected", "stripped" | Packer/toolchain are `inferred` heuristics; limitation `heuristic_hints` (markers can be faked) |
| `core_overview_show` (summary) | active target | `ev_60b497434aa3e6cb68b019fd0a3b016ec0415ef6ec1a3189726faa8d3752f4c4` | 18,918 functions, 12,073 strings, 746 imports, 18 libraries, 10 segments, 2 toolchain hints, 0 warnings | 4 limitations: `instruction_limit` (6M), `indirect_jumps_unresolved` (1,238), `stripped_binary`, `static_analysis_only`; `carries_target_content: false`; `coverage.status: partial` |
| `core_evidence_browse` (overview summary) | overview record | `ev_7596451f50d7405ce849d4a0244e0ac6cbde835b1c8a517359bb49fd10c7314c` | Same counts/limitations re-served | `carries_target_content: false`; `coverage: partial` |
| `core_evidence_browse` (segments rows) | overview record | `ev_2a27e4cdcf44dad4fab1863f5e7b39df0f4d3d5ccca9f6368833cf7308223d07` | 10 segments with entropy: `CODE` 6.61 (5.18 MB, r-x), `.rsrc` 5.08, `.bind` **7.96** (146,800 B, r-x), `.reloc` 6.72, `DATA` 4.25, etc. | `BSS` and `.tls` entropy `null`; no entropy value is proof of encryption |
| `native_functions_list` (offset 600) | active target | `ev_848aff467d3ce8e085bec72a4aadd7f4d870bd09f7b9c06b8ef1b982348c13f5` | 5 import thunks (`ReleaseDC@thunk`, `RemoveMenu@thunk`, …), `total: 18918` | — (thunks chosen only to test listing; not used for dossiers) |
| `native_functions_list` (offset 9000) | active target | `ev_2c3eede775f2c383b7700d6d3518f9d1d1093d858e7a386b28429269d87de4e6` | 12 generated functions, e.g. `sub_60faa0` (51 instructions, 144 B, 1 block, found by `prologue`) | All names `name_source: generated`; same 4 analysis limitations |
| `native_function_study(detail:"summary")` | `0x8f1a08` (entry) | `ev_deb2a847852bb677495cc382f81c91c3e25629b454a1383adfd3b99bde21b80c` | assembly 166, basic_blocks 18, body_ranges 18, callees 34, internal_calls 27, flow_nodes/edges/effects 166/39/39, outgoing_references 72, referenced_names 51, processes 2, threads 1, user_interface 2, unresolved_calls 0 | callers 0, incoming_references 0, comments 0, parameters 0, `flow_parameters` 0, `flow_parameter_uses` 0, jump_tables 0, `referenced_strings` 0; limitations `register_level`, `calling_convention_assumed`, `conditions_from_flags`, `unstructured_flow` (2 gotos), `pseudo_code_inferred`; `carries_target_content: false` |
| `native_function_study(detail:"summary")` | `sub_60faa0` (`0x60faa0`) | `ev_11822820b439c727560265770cfa67261c93a6f3abeb7095792041179a962353` | assembly 51, basic_blocks 1, body_ranges 1, callees 9, internal_calls 8, flow_nodes/edges/effects 51/16/11, outgoing_references 12, referenced_names 12, incoming_references 1 | callers 0, comments 0, parameters 0, `flow_parameters` 0, `flow_parameter_uses` 0, jump_tables 0, `referenced_strings` 0, `unresolved_calls` 1 / `unresolved_indirect_calls` 1; same register/type limitations; `carries_target_content: false` |
| `native_function_pseudocode` | `0x8f1a08` | `ev_8fb27745cfdcd87de8123c983ce02e5e1d38777db5f954af707a40a39c899437` | Ghidra 12.2, 113 lines; literal `"…DEP setting is set to AlwaysOn…"`, `"Can not be run twice"`, `"Cossacks III"`, WinExec / MessageBoxA / mutex logic | `deep_engine` (not original source); variables are `undefined4`/`char` (no real types); `carries_target_content: true` |
| `native_function_pseudocode` | `sub_60faa0` | `ev_2cbea617b5d9ad20619de81132edb10688eb18332224799a8e81c6cf91c934cb` | Ghidra 12.2, 39 lines, 5 `undefined4` params, virtual call `(**(code **)*puVar2)()`, exception-style SEH frames | `deep_engine` **and `made_on_demand`**: "Ghidra's analysis had no function here, so it made one starting at this address (for this session, never saved)"; no typed structs |
| `native_address_show` | `0x8f1a08` | `ev_61553709d6e38f8a1043e3b9dbc6ada7e78388d25d7b3668801c9ee21472e5f8` | `name: entry`, `function: entry/offset 0` | `comment`, `inline_comment`, `bookmarks` all `state: unavailable` ("no comment here", "not bookmarked") |
| `native_address_show` | `0x60faa0` | `ev_5c7216f10884a14849c58ce599e3e1a9fa7ac922a920e7a1c06ce524a6409f5e` | `name` and `function` available (`sub_60faa0`) | `comment`, `inline_comment`, `bookmarks` unavailable |
| `native_address_show` | `0x9587c3` (`XTerrainDataLite`) | `ev_8f00f700a691372ca1ef7bf3f00102b77abd07e0899995274d427cf925a3c436` | Address resolved in `.rsrc` | `function` unavailable ("not in executable code"), `name` unavailable ("no name at this address"), comment / inline comment / bookmarks unavailable |
| `native_function_show` | `0x8f1a08` | `ev_9703ae88114ea8191342a11f94dda301aa1c23cdbf75aff17bac93fe5c2705db` | end `0x8f1c5c`, size 596 B, 18 body ranges, 166 instructions, 34 calls out, `returns: true`, no truncation | `callers: 0`, `jump_tables: []`, `tail_calls: 0`, `unresolved_indirect_jumps: 0`; signature only `int64_t entry()` |
| `native_api_show` | `0x8f1a08` | `ev_ea50164c3b6bee9b8f2a5ddaf7f62396bd517c708dc916d2a21928aed269807e` | 7 API calls (MessageBoxA ×2, WinExec ×2, GetLastError, CloseHandle, ReleaseMutex), 27 internal calls, 0 unresolved indirect calls / jumps | No terrain/file-format APIs; library field `null` for all thunks |
| `core_evidence_browse` (summary) | entry dossier | `ev_d993e0b39c588d5427b53ba625a90c6543b2e18a22d7ab6b2a0786764acf7254` | All dossier counts re-served, `all-in-view` | `carries_target_content: false` |
| `core_evidence_browse` (summary) | arbitrary dossier | `ev_2559772501f1c804feddbbd6f016c06c1e0b5b3e56033527a4919a49a89d55ed` | All dossier counts re-served, `all-in-view` | `carries_target_content: false` |
| `core_evidence_browse` (`function-part` pseudocode) | entry dossier | `ev_845bf7918cf0c1a7e93f4166e6db0e92f697c92d6a3b20acd409a340a64e3b1e` | 4,327 UTF-16 units of clean-room pseudo-C, first page (`ecx = 6` loop, `sub_407d98`, `sub_4182ac`, …) | Paged: `at_end: false`, `next_offset: 192` |
| `core_evidence_browse` (`function-part` referenced_names) | entry dossier | `ev_108dfc21390ca142c29329d87f4bd4c13750569b29d005749ba58e6582cac09d` | 51 reference rows (calls and data refs to `sub_…`) | Paged: first 8 of 51 shown, `next_offset: 8` |
| `core_feature_find` | `"XTerrainData"` | `ev_b218360cfc5cea8f1d3bc9bd99346f27ab8d6be30d3d432f5cbf0d0e58c1c374` | 2 strings: `XTerrainDataLite` @ `0x9587c3`, `sXTerrainData` @ `0x958b75` | **0 function names, 0 functions, 0 imports, 0 string references**; limitation `no_match` ("built at run time, encrypted, or from a resource file; absence is not proof") |
| `core_feature_find` | `"terrain"` | `ev_01c9b39d9878aa3497437d984000116430bac9fbdc8b00f5d112eef84c910c62` | 4 strings: `EXTerrain` @ `0x958649`, `XTerrainDataLite`, `sXTerrainData`, `<XTerrainBorders` @ `0x9593b3` | **0 functions / imports / code references**; same `no_match` caveat |

## Refusals with NO evidence id (recorded honestly)

| Call | Result | Consequence |
|---|---|---|
| `core_packed_files_list({path:"C:\\Games\\Cossacks 3\\cossacks.exe", limit:100})`, plus `contains:"terrain"`, `".map"`, `"grass"`, `"shader"`, `"dat"`, plus active-target call and `editor.exe` | All refused: `{"category":"target","code":"not_supported","message":"This file doesn't carry files in any way we recognise.","remediation":"Run core_target_triage to see what it is, or core_archive_show for ordinary archives. Readers: bun_program, node_sea, dotnet_bundle, godot_pck, pyinstaller, pyinstaller_pyz."}` | **No evidence id was minted** (a rejected tool call produces no evidence record; `core_evidence_show({operation:"core_packed_files_list"})` returned `total: 0`). Therefore the `.bind` section's 7.96 entropy is **not** explained by an enumerable packed-file container. No members/paths/sizes exist to report. |
| `native_objdump_run({operation:"section_headers"})` | Refused: `engine_missing` — "This needs objdump (GNU binutils or LLVM) installed." | No independent section-header evidence; the section table above comes only from `ev_2a27e4cd…`. |
| `core_plan_update` | Refused `stale_revision` (shared session revision advanced by another subagent) | Investigation memory is shared; no plan write from this subagent. |

# What a consented runtime-unpacking workflow would require (IN PRINCIPLE — nothing below was executed)

Discovered by `list_toolsets` (`runtime`: 14 tools, `frida`: 9 tools, initially disabled) and `search`; enabling a toolset only changes this connection's visible tool list.

| Exact tool | What it would do | Risk / consent note (verbatim sense from the tool docs) |
|---|---|---|
| `tools.craftanything.frida_devices_find` | List local/USB/remote Frida devices | Lowest risk; no target started. Passing `remote` does not contact it; reachability/auth unverified. |
| `tools.craftanything.frida_targets_list` | `frida-ps` process/app listing on a device | Read-only enumeration; needs exactly one of `device_id` or `remote`. |
| `tools.craftanything.frida_session_begin` | Managed session: `mode:"attach"` + `pid`, or `mode:"spawn"` + absolute `program` + `argv` | "This records the session; code runs only when you load or resume a script" — but spawn/attach still requires the user's permission to touch a live process. |
| `tools.craftanything.frida_script_run` | Load/run an instrumentation script in a session and capture output | "Executing a script runs foreign code, so this is consent-gated and changes the target." A memory-reading script would still alter process timing and may trip anti-cheat/DEP. |
| `tools.craftanything.frida_instrument_run` | One-call attach/spawn + script + `duration_ms` (≤60000) + detach | "Executes foreign code, so it is consent-gated and destructive." Highest-risk single call. |
| `tools.craftanything.frida_session_continue` | Resume a spawned paused session | "Executes foreign code (the target's own), so this is consent-gated." |
| `tools.craftanything.frida_session_show`, `frida_script_forget`, `frida_session_end` | Inspect/forget/end managed sessions | Bookkeeping; `frida_session_end` "Never kills the target process." |
| `tools.craftanything.native_rizin_session_begin` / `native_rizin_session_command_run` / `native_rizin_session_end` | Debugger stopped before first instruction or attach by pid; commands such as `dm` (maps), `px` (bytes), `dc`, `db` | "Starting a program or attaching to one asks for consent"; commands "can run the program and change its memory, so this asks for consent"; a `dc` that never stops keeps running. |
| `tools.craftanything.native_gdb_session_begin` / `native_gdb_command_run` / `native_gdb_session_end` | GDB MI loading a program (not running it); commands can `run`, call functions, use GDB shell/Python | `session_begin` only loads; `command_run` "asks for consent". On this Windows host GDB/objdump may be absent (objdump already reported `engine_missing`). |
| `tools.craftanything.native_window_capture` | Start program, wait for window, screenshot, optional UI tree, close | "It runs the program, so it needs consent." |
| `tools.craftanything.runtime_walkthrough_record` / `runtime_ui_walkthrough_record` / `runtime_ui_read` / `runtime_captures_compare` | Scripted run/UI observation, optional file-change snapshot (path/size/sha256 only) | "Runs code, so it needs your OK"; bounded by duration/output/files, whole process group killed on timeout/cancel; `sandbox` is bubblewrap (Windows host likely unavailable). |
| `tools.craftanything.apple_calls_observe` | lldb launch with breakpoints | macOS only — not applicable to this Windows x86 donor. |
| `tools.craftanything.core_packed_files_unpack` | Write files carried inside a recognised container | **NOT USED and DO NOT USE on the donor**: it writes a new folder and a manifest; the donor is not a recognised container anyway. |

Prerequisites before any of the above could be considered:

1. **Explicit, separate user consent**, stating: the donor game will be executed or attached to; which tool and mode (spawn vs attach); maximum duration; whether memory may be read/dumped; where any captured bytes may be written (**never the repository**); and acceptance that the game may write saves/settings, contact network services (`wsock32.dll`, `wininet.dll` are imported), trip anti-cheat/DEP (the entry itself checks an "AlwaysOn" DEP setting), or crash.
2. A containment decision: run from the existing install directory `C:\Games\Cossacks 3` (it needs its data files) with a bounded timeout, and snapshot only path/size/hash of files it touches if the user permits.
3. Lowest-risk order: `frida_devices_find` → `frida_targets_list` (no code executed) →, only if the user has the game running, `frida_session_begin({mode:"attach", pid})` → a **read-only** script via `frida_script_run` that enumerates module ranges and searches for unpacked Delphi class names / a decrypted `.text` → `frida_session_show` → `frida_session_end`. Spawn/`frida_instrument_run`/debugger `run` are the escalation path, not the default.
4. The "unpacked image" would be captured through Frida script output or debugger memory commands — Craft Anything has **no dedicated process-memory-dump tool**; any dump is a script/debugger action and therefore consent-gated. Analysing it would require opening it as a **new target in a separate session** (this audit forbids `core_target_open`).
5. Cleanup: end the session, verify no repository writes, and compare any watched paths. None of this guarantees a gain: the terrain strings are `.rsrc` metadata and the appearance logic lives in external scripts/shaders.

# Honest recommendation for the terrain-quality work

1. **Do not request runtime unpacking.** The evidence does not show a whole-program packing wall: the main `CODE` segment is analysable, two functions decompiled successfully, and only a 146 KB `.bind` segment is highly entropic. Runtime execution adds consent, stability, network and anti-cheat risk for a small, uncertain payoff.
2. **Prefer static analysis of the donor's external data**, which is where the terrain appearance actually lives: read-only `app_folder_explain({path:"C:\\Games\\Cossacks 3"})`, `core_archive_show` / `core_packed_files_list` on data archives (not on `cossacks.exe`, which is not a recognised container), and `native_strings_find` / `core_feature_find` on script/config/shader text files. This preserves the existing audit-only constraints and produces citable evidence.
3. Use the executable only for what it genuinely supplies: the Delphi class/unit name table already documented in DECOMP-01 (`OSWGeometry`, `HXHeightField`, `XTerrainDataLite`, `XTile`, …) confirms a heightfield/tile/material architecture, and the decompiled entry confirms startup/DEP/window handling — **neither is a terrain rendering algorithm**.
4. If a later task genuinely requires the `.bind` contents, ask the user explicitly and separately; treat it as a new consented operation, not as a continuation of this audit.

**Requires user consent: any execution of the donor executable, any attach to a running game process, any Frida/GDB/Rizin session, any memory read or dump, and any unpack/extract of donor bytes. This report records principles only; none of those operations were performed.**
