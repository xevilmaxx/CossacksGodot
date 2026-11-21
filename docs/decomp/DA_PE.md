# DA — Donor PE triage and decompilability (worker DA, §5a)

Prepared 2026-11-21 by decompiler agent **DA**. Companion to `docs/decomp/DC_FORMATS.md`
and `docs/decomp/DD_MAPS.md`. Answers: *which of the six donor PE files carry
gameplay/config truth, and is any of it recoverable statically despite packing?*

**Scope / compliance.** Read-only inspection of the locally installed donor at
`C:\Games\Cossacks 3`. No donor file was copied, converted or committed into this
repository; no donor executable was run; no Godot or game code was touched. Donor
material is **PRIVATE USE ONLY — never redistribute**. Only Craft Anything read
tools (`core_target_triage`, `core_target_open`, `core_overview_show`,
`core_evidence_browse`, `native_strings_find`, `native_strings_browse`,
`core_feature_find`, `native_functions_list`, `native_function_pseudocode`) plus
`core_finding_record` were used in the shared session; no brief/plan/handoff write.

Shared session: target `t_5096dee60379` (folder), plus `t_87f0f3c130b0`
(`cossacks.exe`) opened read-only for native analysis. Findings recorded:
**`fnd_13`**, **`fnd_14`**, **`fnd_15`**, **`fnd_16`**.

## 1. Evidence ids

| id | what it establishes |
|---|---|
| `ev_3e6df1626fba0e3b1d70a677860fa53cc311d9d3efca9fa54a9248c403784a01` | PE list: 6 executables in the donor root |
| `ev_e7533ff33eadc37298d3877bfad230213f3f00888319b896daa71be2b868abc6` | triage of `cossacks.exe`: 32-bit x86 PE, Delphi/C++Builder markers, stripped, `.bind` entropy 7.96 |
| `ev_5d43529134c6c65df88730b87b8bd213126fb0f01a1b23cd47679e11317dae98` | triage of `GameOverlayRenderer.dll`: stripped x86 DLL, OpenGL/Mantle imports, no packer hint |
| `ev_d2b04586e092e0ddd66a03c0d272fc027930c142e32abe83f0f48ed52770c8f4` | triage of `codex.dll`: stripped x86 DLL, MSVC (Rich header), `WUS1` entropy 7.91, imports steamclient.dll |
| `ev_9e39e5c8ef1bc8256794bb3db45b9ac3b15655428e004b2f508437f6d7c58ee1` | triage of `config.exe`: Delphi x86, `.bind` 7.97, stripped, 18 imports |
| `ev_4c06408a76b7571dd799180ade2672135844b84f0f63a68b43d75c671ac04de6` | triage of `config.cdx`: same signature, `.bind` 7.97 |
| `ev_0b468aeb94d957d4b7c3b732c5a4c2b8b8bc573688a87c3097988e0e37d9063a` | triage of `cossacks.cdx`: same signature, `.bind` 7.96, entry `0x96c310` |
| `ev_60b497434aa3e6cb68b019fd0a3b016ec0415ef6ec1a3189726faa8d3752f4c4` | overview of `cossacks.exe`: 18,918 functions / 12,073 strings / 746 imports from 18 libs; analysis limits |
| `ev_5b735a491cc638691498fe03747ea46d507f784402ed40fa0557c5a30f9227f1` | segment table: `CODE` 5.18 MB entropy 6.61; `.bind` 146,800 B entropy 7.96, r-x |
| `ev_2a19190c52e2532f76afd068ae8753ced5edaf8313dca8e515925eb4cfd18da0` | toolchain hints: Borland/Embarcadero markers; `.bind` high-entropy packer hint |
| `ev_529cd3776e1191662a9ed491776a5836c6363ae4ac08f2d5cabca0e40d977d16` | `native_functions_list`: 18,918 functions, generated names + import thunks |
| `ev_b0e5246a12e6fe1f1f18eb1d22acaecc02b13dc00be18a25c6c3fddd9eb15df8` | clean Ghidra pseudo-C for `FUN_00404628` — proves per-function decompilation works in CODE |
| `ev_a44201a25014c06c823b93c3c362b3801771a188373d708c85b86c1a22cb23c5` | `sub_401000` pseudo-C via clean-room lifter, partly unstructured — decoder quality varies |
| `ev_8c22d94c90b5befacd858f15d6ef63a07bd573949dc3900015585e1136d88c99` | first strings page: Delphi RTL strings in `DATA` (12073 total) |
| `ev_238c8015b7909d79fa22c73b8a440ac86b817dffbd2fda074063e1d4ec6ba92f`, `ev_d9c6e28bcfbe87f1ca6233632d24e92b7e4a56b545a35343ef92de0bd4af5457` | named RTTI: 111 `X*` class names, 474 `T*` form/class names |
| `ev_6f9dc93cd994b3359d88e75b1a5e4b38f5563707bf3b476a78e103e290076dfd`, `ev_33561ae3050f4498e4d94896c50762a89456113bf3f174fa261d29313e25528a`, `ev_349ae770ab369af910546678aaf8cd3252404920ddcf0c66063a54ed65e2b475` | `generator` → 2 RTTI strings; `Castle` → 3; `Path` → 7 |
| `ev_03b86831aed9dc64fd16a5bec433590858eac2ff6d3a1da148c3e0b4448ffaf4`, `ev_49a306dcd7f302588593650801438185264a1e26e0b34a4c41f7f747de6e3c4d`, `ev_cbff893fe3af1614ce719b081c25ad70cb8386fbf3f4af4e97b57d8529beb254`, `ev_a55f11205a94e89b311e75b7510970b5d670fb12e12ce91c788aa22b00ed4812` | `morale`, `AStar`, `terrainmask`, `Regiment` → 0 matches each |
| `ev_74b5910c371b143e7077790725d71b70af4037589f35d209458d31bd7f74c64e`, `ev_ec5fbf04b4598be4a6439fedc7e43da23a89e56fe21db5279c7bb12897beaeb3` | `formation` → 2 unrelated strings; `Generator` → 2 RTTI strings, 0 code xrefs / 0 named functions |

## 2. Per-PE table

All six are **PE32 / x86 (32-bit), Windows**. "Usefulness" is relative to the Godot
singleplayer port; *observed* facts (imports, entropy, strings) are separated from
*inferred* roles below.

| Path | Kind | Architecture | Toolchain / packer | Usefulness for port | Evidence id |
|---|---|---|---|---|---|
| `C:\Games\Cossacks 3\cossacks.exe` | executable (main game, 5,768,048 B) | x86 32-bit | Delphi/C++Builder markers; **stripped**; `.bind` packed stub, entropy 7.96 | **Primary.** Large intact `CODE` section; RTTI class names expose subsystem map. No source, but per-function Ghidra decompilation is feasible | `ev_e7533ff3…`, `ev_60b49743…`, `ev_5b735a49…` |
| `C:\Games\Cossacks 3\config.exe` | executable (config tool) | x86 32-bit | Delphi/C++Builder; **stripped**; `.bind` entropy 7.97 | **Medium — indirect.** Carries the settings/keybind surface, but packed; harvest the equivalent donor *text* config families instead of decompiling the EXE | `ev_9e39e5c8…` |
| `C:\Games\Cossacks 3\config.cdx` | executable (`config.exe` variant) | x86 32-bit | Delphi/C++Builder; **stripped**; `.bind` entropy 7.97 | **Low.** Same 18-import signature as `config.exe`; no incremental truth expected (inferred) | `ev_4c06408a…` |
| `C:\Games\Cossacks 3\cossacks.cdx` | executable (`cossacks.exe` variant) | x86 32-bit | Delphi/C++Builder; **stripped**; `.bind` entropy 7.96; entry `0x96c310` inside `.bind` | **Low.** Same import signature and packer as the main EXE; likely a protected/bound build of the same engine (inferred) | `ev_0b468aeb…` |
| `C:\Games\Cossacks 3\GameOverlayRenderer.dll` | shared library (Steam overlay renderer) | x86 32-bit | Stripped; no toolchain/packer hint; imports `OPENGL32`, `mantle32`, `GDI32`, `IMM32`, `USER32`, `ADVAPI32`, `WINMM`, `PSAPI`, `ole32` | **None.** Steam overlay boilerplate (inferred from name + imports); no gameplay/config truth, do not port or redistribute | `ev_5d435291…` |
| `C:\Games\Cossacks 3\codex.dll` | shared library (Steam-side runtime) | x86 32-bit | **MSVC** (Rich header); **stripped**; packed `WUS1`, entropy 7.91; imports `steamclient.dll`, `GameOverlayRenderer.dll`, `SHELL32`, `SHLWAPI`, `ntdll` | **None.** Steam runtime boilerplate; packed and unrelated to game rules | `ev_d2b04586…` |

Grouping (observed): `cossacks.exe`, `config.exe`, `config.cdx`, `cossacks.cdx`
share the same 18-library import set (`d3d9`, `opengl32`, `glu32`, `wininet`,
`wsock32`, `comctl32`, `oleaut32`, `PowrProf`, …). The two DLLs are the only PEs
with Steam/overlay imports.

## 3. What was actually recoverable

**Counts (observed).** `cossacks.exe`: 18,918 functions, 12,073 strings, 746
imports from 18 libraries (`ev_60b49743…`). Segment table (`ev_5b735a49…`):

| section | bytes | entropy | note |
|---|---:|---:|---|
| `CODE` | 5,180,840 | **6.61** | normal compiled x86 — bulk of game logic, statically analysable |
| `DATA` | 44,580 | 4.25 | Delphi RTL strings (`"Runtime error at …"`, CPU vendor IDs, format tables) |
| `.idata` | 16,652 | 5.08 | Win32/OpenGL import names |
| `.rsrc` | 128,000 | 5.08 | **Delphi RTTI + form resource names** |
| `.bind` | 146,800 | **7.96** | packed/encrypted stub; the only high-entropy section |

**Named type surface (observed).** 111 `X*` class names and 474 `T*` names were
recovered from `.rsrc` (`ev_238c801…`, `ev_d9c6e28…`). Representative gameplay-
relevant names:

- world / terrain: `XWorld`, `XGlobalMap`, `XMap`, `XTile`, `XTileSmooth`,
  `XTerrainDataLite`, `XTopology`, `XGrids`, `XCliff`, `XWater`, `XSeason`,
  `XSeasonType`, `XCollisionMask`, `XCollisionTags`, `XBits`, `XPattern`
- generation / scenario: `XMapGenerator`, `XCastleGenerator`, `XCastleScheme`,
  `XCastleCollection`, `XWallConstructor`, `XSchemeObject`, `XScenario`,
  `XTown`, `XPicked`, `XTrackNode`, `XTrackPoint`
- path / AI / scripting: `XPath`, `XPathTypes`, `XStateMachine`, `XGameObject`,
  `XBaseActor`, `XArmiesViewer`, `XDScriptParser`, `XDScriptBehaviour`,
  `XDScriptTrigger`, `XDScriptEditor`, `XQueryMachine`, `XDScriptSteamAPP`
- rendering / FX / UI: `XRenderer`, `XFOWRender` (fog of war), `XShadowMap`,
  `XSkyDome`, `XRenderPool`, `XParticleFX`, `XGui`, `XGuiLayer`, `XConfig`
- tool classes: `TFORMCONFIG`, `TFORMDWSDEBUGGER`, `TFORMSCRIPTEVALUATE`,
  `TAIXEDITOR`, `TAIXARGSEDITOR` — corroborates that `.aix` is the editor/script
  format handled by DD's lane.

**Gameplay term probes (observed, deliberately paged — not a full dump).**

| query | result | evidence |
|---|---|---|
| `generator` | 2 strings, both RTTI (`XMapGenerator`, `&XCastleGenerator`); 0 named functions, 0 code xrefs | `ev_6f9dc93…`, `ev_ec5fbf04…` |
| `Castle` | 3 RTTI strings (`XCastleCollection`, `&XCastleGenerator`, `XCastleScheme`) | `ev_33561ae…` |
| `Path` | 7 strings: Win32 path APIs + `XPath`, `XPathTypes` | `ev_349ae77…` |
| `formation` | 2 strings, both unrelated (`CallNtPowerInformation`, `Information`) | `ev_74b5910…` |
| `morale` / `AStar` / `terrainmask` / `Regiment` | 0 matches each | `ev_03b868…`, `ev_49a306…`, `ev_cbff893…`, `ev_a55f112…` |

**Decompilation feasibility (observed).** Function discovery works on the intact
`CODE` section; names are generated (`sub_…`, `FUN_…`) plus import thunks
(`ev_529cd3…`). In Deep mode the Ghidra lifter produced clean, readable pseudo-C
for `FUN_00404628` (`ev_b0e5246…`), which does a virtual call through an object
vtable — a normal Delphi pattern. So *per-function* truth is recoverable once a
function is anchored; the hard part is anchoring, not lifting.

## 4. Packed / stripped limits

1. **Stripped, all six PEs.** No symbols or local names; every function is
   `sub_…`/`FUN_…`. Recovered `X*`/`T*` names are *RTTI/resource names*, and those
   strings carry **0 code cross-references** (`ev_ec5fbf04…`), so they map
   modules but do not point at the implementing functions.
2. **Packed stub at entry.** The entry point of `cossacks.cdx` is `0x96c310`,
   inside `.bind` (`0x96c000`–`0x98fd70`); that section has entropy 7.96 and is
   not statically readable. `codex.dll` similarly carries `WUS1` at 7.91. The
   packer cannot be unpacked here because running donor executables is
   prohibited — no memory dump is available. `config.exe` / `config.cdx`
   (`.bind` 7.97) and `cossacks.exe` share this protection.
3. **Analysis is incomplete.** Function discovery stopped after 6,000,000
   instructions; 1,238 indirect jumps are unresolved; functions reached only via
   computed pointers or at run time are absent. *Absence is not proof that a
   gameplay routine does not exist.* (`ev_60b49743…`)
4. **Strings are section-limited.** `native_strings_*` reads data sections only;
   text built at run time, encrypted by the packer, or stored in a closed format
   is not listed. The 0-match term results above therefore do **not** prove those
   mechanics are absent from the game — they prove they are not exposed as plain
   strings in this PE.
5. **Decoder quality varies.** A function decoded by the fallback clean-room
   lifter (`sub_401000`, `ev_a44201a…`) produced garbled, unstructured pseudo-C,
   while the same binary's Deep/Ghidra output is clean (`ev_b0e5246…`). Every
   decompiled function must be sanity-checked before its semantics are trusted.
6. **No source equivalence.** Even a cleanly decompiled function yields C-like
   logic, not the original Delphi source, identifiers or comments. Any port must
   treat it as behavioural evidence to be reimplemented, not code to copy.

## 5. Backlog estimate (worker tickets)

Actionable truth **was** found: a subsystem map from RTTI, confirmation that
Ghidra decompilation of `CODE` functions is viable, and a clear split between
game binaries and irrelevant Steam DLLs. Recommended finite backlog:

| # | Ticket | Basis | Risk | Size |
|---|---|---|---|---|
| DA-1 | Map the 111 RTTI `X*` classes to Godot module boundaries (world/terrain, path, map & castle generation, FOW, scripting, GUI, config), reusing the donor text config families for actual parameter truth | `fnd_16` | low | 1 ticket |
| DA-2 | **Timeboxed spike:** anchor 2–3 subsystems (`XMapGenerator`, `XCastleGenerator`, `XPath`) to concrete CODE functions via vtable/call-graph pointers rather than string xrefs; bail out after the cap | `fnd_15`, `fnd_16` | high (stripped, no string xrefs) | 1 spike ticket |
| DA-3 | Harvest the `config.exe` settings surface from donor *text* families (`generator.cfg`, `formations.cfg`, `hotkeys.cfg`, `units.cfg`, `startingsettings.cfg`) instead of decompiling the packed EXE; cross-lane with the text agent | `fnd_14`; text-lane evidence in ledger | low | 1 ticket |
| DA-4 | Close `GameOverlayRenderer.dll` and `codex.dll` explicitly as out-of-scope (no port, no redistribution) and record the rationale | `fnd_13` | trivial | 0.5 ticket |

**Total ≈ 3.5 tickets (round to 3–4).** Only DA-2 is high-risk; cap it as a
timebox and fall back to the text-config truth if it returns no anchored functions.
No ticket should attempt to unpack or execute any donor PE.

## 6. Bottom line

- Steam overlay boilerplate: `GameOverlayRenderer.dll`, `codex.dll` — **ignore**.
- Game/config binaries: `cossacks.exe` (primary), `config.exe` (settings surface),
  `config.cdx` / `cossacks.cdx` (protected variants, low value).
- The main EXE is packed **only at a small stub**; its 5.18 MB `CODE` section and
  RTTI class-name table remain readable, so static truth is recoverable — but
  names don't lead to functions, and gameplay literals are mostly absent, so the
  highest-value output for the port is the **subsystem map (DA-1)** and the
  **text-config truth (DA-3)**, not a full decompilation.
