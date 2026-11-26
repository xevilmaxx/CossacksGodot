---
id: X51
ticket: "TERRAIN-SWARM-2026-11-26 / X51 — FINAL read-only pass to close remaining [U] items with donor text + native binary tools"
agent: "X51 (read-only research subagent, 30-agent DONOR-FIRST terrain swarm 2026-11-26), reporting to COORD"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_CODE_EDIT__NO_SPEC_EDIT__NO_GODOT_JOB__NO_DONOR_EXECUTION
owner_file: docs/terrain_swarm_2026-11-26/reports/X51_close_unknowns_pass.md
files_created: [docs/terrain_swarm_2026-11-26/reports/X51_close_unknowns_pass.md]
files_edited: []
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_guard: "NO DONOR VISUAL PARITY CLAIM. No donor binary was executed, no donor GPU frame exists, no Godot job, no gate and no capture were run. RESOLVED below means a donor path:line/opcode or literal was recovered, never that the port matches the donor visually."
scope_guard: "Read-only. Donor at C:\\Games\\Cossacks 3 read via grep/file reads, PowerShell Get-Content/byte reads, and Craft Anything read-only core_*/native_* tools (Deep mode, both PE targets already open in the SHARED session). No core_brief/core_hypothesis/core_finding write (another worker's investigation memory was not touched); native tools were called with explicit document= ids so the shared active target was never switched. No repo file except this report written."
multiple_passes: true
tools_targets: "Craft Anything 0.6.1, analysis_mode=deep, clean_room=false; cossacks.exe target t_87f0f3c130b0 (SHA256 87f0f3c130b0…); editor.exe target t_68474ddde43f (SHA256 68474ddde43f…). Builtin clean-room lifter AND Deep Ghidra 12.2 lifter both used on anomalies (CHARTER.md:85-93)."
---

# X51 — FINAL read-only pass on the remaining `[U]` items

## 0. Executive summary

1. **[O]/[D] One genuinely new donor fact was recovered.** `cossacks.exe` and `editor.exe` both contain the **full compiled DScript signature** of `GenerateMapRandKey` as a length-prefixed string in the `CODE` section: `procedure GenerateMapRandKey(var randkey0: Integer; var randkey1: Integer)` (cossacks.exe file offset `0x29e848`-`0x29e892`, VA `0x69f448`-`0x69f492`; length prefix `0x4A` = 74 at `0x29e848`). This upgrades CORE-12 from "name string only" to "signature RESOLVED", but the **body/derivation is still absent** — zero static xrefs, no discovered function, no text body. **Do not invent a key-derivation formula.**
2. **[O] `hmapTex`'s only readable consumer is key-registration, not a texture bind.** Deep Ghidra decompile of `FUN_00853ad4` (VA `0x853ad4`) shows 30 calls to `FUN_00405454(param_1 + off, "name")`, with `hmapTex` at `+0x54`, `hmapW` `+0x58`, `hmapH` `+0x5c`, `hmapMin` `+0x60`, `hmapMax` `+0x64` … `cameraModel` `+0x78`. **No `glBindTexture`, no sampler unit, no plane math.** The shader text (`water.frag:8,246-248`) does read `hmapTex`, so the sampler role is observed; the **runtime texture/FBO identity and eye-plane numerics are still UNVERIFIED** (need GPU trace).
3. **[O] There is no fixed global "HeightField blend pass count" to recover.** Deep decompile of the stamp `FUN_00755f30` (VA `0x755f30`) shows three flag-gated blend branches (`+0x3a/+0x3b/+0x39`) and a **data-driven post-pass loop whose trip count is read from the pattern struct field at `+0x54`**, not a hardcoded constant. Text pass literals are only `TileSmoothPasses=6` (`globalparams.cfg:9`) and `SmoothPasses=1` (`localparams.cfg:12`) for the *tile-smoothing* chain, a different stage. Verdict: **RESOLVED in the negative** — implement as field-driven; no donor pass constant exists.
4. **[U] `bmTransparency` pass count stays UNVERIFIED.** The token occurs only as a material enum (`bmTransparency`) in `.mat`/`.lib` files; binary strings `tsDouble`, `ttExtended`, `TileXOffset` exist in CODE but no draw-pass loop or count was recovered in any pass. `tsDouble=1` is suggestive only — **assert no layer count**.
5. **[U] Row sign / `row_flip` stays UNVERIFIED.** Stamp rows index the `+0x28` float plane with the outer loop first (`(local_18 - iVar6)` before `(iVar7 - iVar5)`), but the file-row→world-y translation lives only in commented DScript (`generatemap.inc:242,574` `SetHeightData(x,y,res)` is `[*] = ;`). No `Flip`/`row_flip` field exists anywhere in `pattern.lib` (grep: 0 matches).
6. **[U] R1–R6 numeric ranges stay UNVERIFIED — and the 66 binary "R1" hits are a false positive.** GUIDE4.md:642,653-654 names only "height, radius, passage width, furrow count/depth/phase" (editor-manual provenance). Raw bytes around editor.exe VA `0x52db95`–`0x52dd80` are a **debugger register-name table** (CS/SS/DS/CR0–CR7/DR0–DR7/R8B–R15B/MMX/XMM), not relief ranges.
7. **[U] `cOffsetY=-0.5` runtime activity stays UNVERIFIED.** Two authored occurrences, **both `[*] = ;` commented**: `generatemap.inc:688,704` and the second-in-install `scripts/editor.inc/generatemapfrombitmap.inc:315,325`. No live consumer exists in readable text; the built-in engine found no `WaterFieldAdd` function (discovery hit its 6M-instruction cap), so execution cannot be proven read-only.
8. **[D] Relief grids: layout RESOLVED, semantic labels UNVERIFIED.** F01's `G = 8+(w-1)(h-1)` addresses every one of the 710 `.pattern` files; `generator.cfg` (`data/game/var/generator.cfg:67+`, 64 families) enumerates the active ids. Nothing in this pass changes the grid numbers, and no new value is invented.
9. **[U] No parity claim.** RESOLVED means "a donor literal/opcode was read", not "the port is faithful". COORD's DOCUMENT_ONLY short list is in §4.

---

## 1. Instruments, targets and evidence

| ID | Instrument / path | Passes | Observation | Label |
|---|---|---|---|---|
| X51-E1 | `grep` donor `data/**` for `GenerateMapRandKey` | 2 (text tree + whole donor root) | 3 matches: `data/scripts/lib/map.script:322` (**live call**, no `[*] = ;`), `data/gui/menu.inc/donewgame.inc:16`, `data/gui/menu.inc/initmapsettings.inc:8` (both commented). No body in text. | [O] |
| X51-E2 | `native_bytes_find` text `GenerateMapRandKey`, `path=` both PEs | 2 (cossacks.exe, editor.exe) | cossacks.exe file `0x29e852` / VA `0x69f452`, `section=CODE`, 18-byte ASCII `GenerateMapRandKey`; editor.exe file `0x36962e` / VA `0x76a22e`. Ev `ev_47be5042…`, `ev_6b218922…`. | [O] |
| X51-E3 | PowerShell raw byte read, cossacks.exe `0x29e820…0x29e920` | 1 | Full length-prefixed signature table: `procedure RegenerateMapNeeded()` at `0x29e820`; `FF FF FF FF 4A 00 00 00` + `procedure GenerateMapRandKey(var randkey0: Integer; var randkey1: Integer)` at `0x29e848`-`0x29e892`; then `GetMapGeneratorRandomKey(...)` and `SetMapGeneratorRandomKey(...)`. | [O] |
| X51-E4 | `native_functions_search` + `native_strings_find` for `GenerateMapRandKey`; `native_xrefs_list` at VA `0x69f452` / `0x76a22e` | 3 instruments × 2 binaries | 0 functions (discovery capped at 6,000,000 instructions), 0 categorised strings, **0 static xrefs**. Ev `ev_6064254c…`, `ev_7f93b025…`, `ev_4fdbcef2…`, `ev_303eebf5…`, `ev_2ffdab60…`, `ev_1e3058d7…`. | [U] |
| X51-E5 | `native_bytes_find` text `hmapTex`, cossacks.exe | 2 (string finder + raw bytes) | Builtin string finder: 0; raw bytes: file `0x45320c` / VA `0x853e0c`, `section=CODE`, 7-byte ASCII. `native_xrefs_list` at VA `0x853e0c`: 0 static xrefs. Ev `ev_e2af1311…`, `ev_e84579cc…`. | [O]/[U] |
| X51-E6 | `native_function_pseudocode` (Deep Ghidra 12.2) `0x853ad4`, `native_function_show`/`callees_list` (builtin) | 3 instruments | Deep: `FUN_00853ad4(int param_1)` calls `FUN_00405454(param_1+off, name)` ×30; `+0x54 "hmapTex"`, `+0x58 "hmapW"`, `+0x5c "hmapH"`, `+0x60 "hmapMin"`, `+0x64 "hmapMax"`, `+0x68 "shadowed"`, `+0x6c "shadowMap"`, `+0x70 "shadowSize"`, `+0x74 "shadowColor"`, `+0x78 "cameraModel"`, `+0x7c = DAT_00853eb8`. Builtin could not find the function (it is not in its capped discovery set) — **Deep reading accepted**, ev `ev_4ddab2aa…`. | [O] |
| X51-E7 | `native_function_pseudocode` (Deep) `0x755f30` | 2 (Deep full dossier + prior D05/X12 opcode reads) | Stamp `FUN_00755f30`: grid read `*(float *)(*(int *)(*(int *)(local_8+0x28) + (local_18 - iVar6)*4) + (iVar7 - iVar5)*4)`; three blend branches keyed on `*(char *)(local_8+0x3a/0x3b/0x39)`; post-pass `local_80 = *(int *)(local_8+0x54); do { FUN_00755db4(local_8); local_80--; } while(...)`. Ev `ev_c176cc81…`. | [O]/[D] |
| X51-E8 | `grep` donor `data/**` for `Passes|BlendPass|SmoothPass` | 1 | Only `globalparams.cfg:9 TileSmoothPasses = 6`, `localparams.cfg:12 SmoothPasses = 1`, `smoothtiles.inc:191/197 SmoothTileMap(...,passes)` with `for k:=0 to passes-1` (commented). Post-effect `BlurNumPasses=5`/`HDRNumPasses=5` are unrelated. No HeightField/bmTransparency pass literal. | [O] |
| X51-E9 | `grep` donor `data/**` for `bmTransparency`; `native_bytes_find` for `tsDouble`/`ttExtended`/`TileXOffset` | 2 (text + binary) | Text: hundreds of `BlendingMode = bmTransparency` enum uses (e.g. `terrain/ref/reftile.mat:17`, `reftilealpha.mat:17,126,235`) — enum only. Binary `tsDouble` cossacks `0x142f11`/VA `0x543b11`, editor `0x156cc5`/VA `0x5578c5`; `ttExtended` VA `0x543b62`; `TileXOffset` VA `0x544870`. No count loop. Ev `ev_9a7a7087…`, `ev_a85f28dd…`, `ev_085d4cc7…`, `ev_d6859b15…`. | [O]/[U] |
| X51-E10 | `read` donor shaders `data/shaders/water/water.frag`, `water.dev.vert/frag`, `hf.pvl.sm.vert`; `grep` `EyePlane|TextureMatrix` | 2 | `water.frag:8 uniform sampler2D hmapTex`, `:246 texture2D(hmapTex, gl_TexCoord[3].xy)`, `:247 h=hmapMin+fragColor.w*(hmapMax-hmapMin)`, `:248 if (gl_TexCoord[3].z>h)` — live shader read. `water.dev.frag:18,72` uses `p`. `water.dev.vert:15,20` uses `gl_TextureMatrix[0]/[3]`. `hf.pvl.sm.vert:30-32` uses `gl_EyePlaneS/T[0]` then `gl_TextureMatrix[0]`. | [O]/[U] |
| X51-E11 | `grep` donor `data/scripts/common.inc/generatemap.inc`, `scripts/editor.inc/generatemapfrombitmap.inc` for `cOffsetY` | 2 | `generatemap.inc:688 [*] = ; const cOffsetY = -0.5;`, `:704 [*] = ; WaterFieldAdd(..., cOffsetY);`; `generatemapfrombitmap.inc:315/325` identical. **All four `[*] = ;`.** `native_functions_search WaterFieldAdd`: 0 (discovery capped). | [O]/[U] |
| X51-E12 | `native_functions_search R1` editor.exe (66 hits) + raw byte read file `0x12cf40…0x12d340` | 2 | Cluster VA `0x52db95`–`0x52dd80` decodes as `CS/SS/DS/FS/GS, CR0..CR7, DR0..DR7, R8B..R15B, R8W..R15W, R8D..R15D, R8..R15, MMX0..7, XMM8..15` — debugger register-name table. Ev `ev_ac7f5115…`. | [O] |
| X51-E13 | `read` repo `docs/guides/GUIDE4.md:640-655` | 2 (targeted + prior V01 citation) | `:642 "R1 height, R2 radius, brush 1-9"`; `:653-654 "Relief gen params R1-R6 (height, radius, passage width, furrow count/depth/phase)"` — names only, no numeric ranges; `:634 "the same five tools"`. | [O] |
| X51-E14 | `grep` `data/pattern/pattern.lib` for `Flip|row_flip|Mirror|Row` | 1 | 0 matches. No row-flip flag/field in the plaintext pattern DB. | [O]/[U] |
| X51-E15 | `read` `data/game/var/generator.cfg:1-120`; `grep Name/Pattern/Freq` | 2 | 6 vanilla terrain-type paths (`:1-28`), 64 `Name =` pattern families (first: `mng:69`, `mni:98`, `mnc:127`, `desert_mng:156`, `plain_small:207`, `plain_medium:288`, `plain_big:389`, `plain_huge:446`…) with `Freq` weights; active relief ids enumerated. | [O] |
| X51-E16 | `read` required swarm docs (CHARTER, SWARM_BOARD, V27, V03, X27, V37) | 1 each | Baseline `[U]` ownership/dispositions; no earlier report supplies the values recovered in §2.3/§2.4 below. | [O] |

**Instrument note (CHARTER §4 multiple-pass rule):** every binary anomaly was read with at least two instruments — builtin string finder **and** raw `native_bytes_find` for name strings; builtin lifter **and** Deep Ghidra for function bodies; `native_xrefs_list` for code consumers. Where the builtin engine's function discovery was capped at 6,000,000 instructions, its "0 matches" is explicitly labelled *partial, not proof of absence*; the Deep reading was accepted for `FUN_00853ad4` and `FUN_00755f30`.

---

## 2. Item-by-item verdicts

For each item: **exact search → what was found → verdict**. All paths are donor unless marked `repo:`.

### 2.1 Row sign (file row vs map row) — **UNVERIFIED**

- **Search:** `grep "row|Row|SetHeight|HeightField|hmap" C:\Games\Cossacks 3\data\scripts\common.inc\generatemap.inc`; `grep "Flip|row_flip|Mirror|Row" data\pattern\pattern.lib`; Deep `native_function_pseudocode 0x755f30` on cossacks.exe; `native_functions_search "Row"` (regex).
- **Found:** `generatemap.inc:242 [*] = ; SetHeightData(x, y, res);`, `:574 [*] = ; SetHeightData(realx, realy, hwater+hterrain)`, `:1051 [*] = ; DeleteFileStream(...+'bitmaprow.bmp')` — all authored/commented. Stamp native reads the `+0x28` plane as `[row][col]` via `local_18` (outer) then `iVar7` (inner) — the row→`+0x28` indexing half is confirmed. `pattern.lib` has **zero** `Flip`/`row` tokens. Builtin `native_functions_search Row`: 0 (capped discovery).
- **Verdict:** **UNVERIFIED** — the file-row→world-y sign is set by the commented DScript caller, and no readable consumer converts a stamp file row into a signed world coordinate. The stamp opcode fixes index order, not the sign. No value invented. (Maps to V27 CORE-01 / V16-O10 row-flip half / X03-U2 / P06-V13.)

### 2.2 `HeightField` blend pass count — **RESOLVED in the negative (no fixed constant)**

- **Search:** `grep "Passes|PassCount|BlendPass|SmoothPass|Blend" data/**`; Deep `native_function_pseudocode 0x755f30`.
- **Found:** the only pass literals in the donor belong to the *tile-smoothing* stage: `globalparams.cfg:9 TileSmoothPasses = 6`, `localparams.cfg:12 SmoothPasses = 1`, `smoothtiles.inc:191/197 SmoothTileMap(...,passes)` with `for k := 0 to passes-1` (`[*] = ;`). In the stamp `FUN_00755f30` the blend is three flag-gated branches on `+0x3a/+0x3b/+0x39` (ReplaceForWater / Replace / additive), and the *smooth* post-pass trip count is `local_80 = *(int *)(local_8 + 0x54)` — **read from the pattern instance struct**, decremented in a `do/while` around `FUN_00755db4(local_8)`. No hardcoded global height-blend pass number exists in the opcode.
- **Verdict:** **RESOLVED** — implement the stamp as three flag branches plus a struct-field-driven post-pass; there is no donor pass constant to copy. **Residual `[U]`:** mapping native struct field `+0x54` to a named `pattern.lib` key was not recovered; do not assert one. (Maps to V27 CORE-16/LATE-03/X03-U3, kept `[U]` only for the field-name mapping.)

### 2.3 `bmTransparency` pass count — **UNVERIFIED**

- **Search:** `grep "bmTransparency" data/**`; `native_bytes_find` for `tsDouble`, `ttExtended`, `TileXOffset` in both PEs; re-read X17's cited factor table (`0x8fb1ac`) via Deep pseudo-C of `0x4ef810` (carried forward from X17/D08 — not re-derived here).
- **Found:** text hits are exclusively the material enum `BlendingMode = bmTransparency` (e.g. `reftile.mat:17`, `reftilealpha.mat:17,126,235`, `decals.mat:17`) and DScript `SetBehaviourIntProperty(effHnd,'BlendingMode',1); // bmTransparency` (`unit.script:6760`, commented instances in `unit.inc/deathstage*.inc`). Binary name strings: `tsDouble` (cossacks VA `0x543b11`, editor VA `0x5578c5`), `ttExtended` (VA `0x543b62`), `TileXOffset` (VA `0x544870`) — all in `CODE`, all with 0 static xrefs. **No draw-pass loop, loop bound or second blend draw was recovered.**
- **Verdict:** **UNVERIFIED** — factors/equation remain `[D]` from X17 (`glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)`, VA `0x4ef991`; no `glBlendEquation` import), but the **number of composite passes is not recoverable** from text or static code. `tsDouble` is a flag name, not evidence of exactly two passes. Keep the two-layer Godot blend explicitly `PORT APPROXIMATION`. (V27 CORE-08, V27 §7 "composite pass count" — stays DOCUMENT_ONLY.)

### 2.4 `hmapTex` runtime planes — **PARTIALLY RESOLVED (key-only confirmed) / planes UNVERIFIED**

- **Search:** `grep "cOffsetY|hmapTex|EyePlane|TextureMatrix|bmTransparency|GenerateMapRandKey" C:\Games\Cossacks 3` (176 hits); read `water.frag`, `water.dev.vert/frag`, `hf.pvl.sm.vert`; `native_bytes_find "hmapTex"`; `native_xrefs_list` VA `0x853e0c`; Deep `native_function_pseudocode 0x853ad4`; builtin `function_show`/`callees_list` as second instrument.
- **Found:** the *only* native consumer readable is `FUN_00853ad4`, which **registers uniform-name strings only**: `+0x54 "hmapTex"` (ev `ev_4ddab2aa…`), alongside `hmapMin/hmapMax/hmapW/hmapH` and 25 other names; there is no `glBindTexture`, `glActiveTexture`, sampler-unit assignment or eye-plane arithmetic in that function. Shader text proves the sampler is read (`water.frag:246-248` uses `gl_TexCoord[3]`); `hf.pvl.sm.vert:30-32` shows the general `gl_EyePlaneS/T[0]` → `gl_TextureMatrix[0]` idiom, but no water-specific numeric plane value is authored anywhere.
- **Verdict:** **RESOLVED** for the claim "*`hmapTex` is a uniform-name key with no texture bind in the setter*" (donor `cossacks.exe` VA `0x853ad4`/`0x853e0c`, Deep opcode). **UNVERIFIED** for bound texture/FBO identity, sampler units and runtime eye-plane/tr texture-matrix numerics — these are GL state produced at runtime and cannot be recovered without a GPU trace; the packed `.bind` section (entropy 7.96) was not unpacked. No value invented. (V27 CORE-04/05/06, V16-O11.)

### 2.5 R1–R6 numeric ranges — **UNVERIFIED (and one false positive cleared)**

- **Search:** `grep "R1|R2|R3|R4|R5|R6" docs/guides/GUIDE4.md`; `native_bytes_find "R1"` editor.exe (66 hits); raw byte read editor.exe file `0x12cf40…0x12d340`; V01/V03 cross-read.
- **Found:** GUIDE4.md:642,653-654 names R1/R2 and "R1–R6 (height, radius, passage width, furrow count/depth/phase)" — parameter *names* from the editor manual, **no numeric ranges**. The 66 binary "R1" hits are at VA `0x52db95`–`0x52dd80` and decode to a debugger register-name table (`CS/SS/DS/CR0-7/DR0-7/R8B..R15B/MMX/XMM`) — unrelated to terrain relief. No editor DFM control label or native literal carries a relief range.
- **Verdict:** **UNVERIFIED / DOCUMENT_ONLY** — the only source is a third-party editor manual naming parameters; no donor numeric range exists in readable text or discovered code. Inventing a range would violate CHARTER.md:83-84. (V27 CORE-29, X03-U9, V21 GR-B02 advisory.)

### 2.6 `row_flip` — **UNVERIFIED**

- **Search:** `grep "Flip|row_flip|Mirror|Row" data\pattern\pattern.lib` (0 matches); Deep stamp decompile (§2.1); `native_functions_search "Row"` (0, capped).
- **Found:** no `row_flip`/`Flip` field or flag in the 680-section plaintext DB; the stamp's row-first indexing is observed but the sign convention is authored in commented DScript only. Pattern-level `HeightFieldScale` values in `pattern.lib` are **both positive and negative** (e.g. `:14 -0.925`, `:94 +0.925`, `:214 -0.925`, `:254 +0.925`, `:294 1.175`, `:24428 1.5`, `:33094 0.65`), which shows sign is per-pattern *data*, not a single global flip flag — but it does **not** settle the file-row→world-y orientation.
- **Verdict:** **UNVERIFIED** — no readable consumer sets or applies a row-flip; preserve the spec's `row_flip="UNVERIFIED"` label and do not add a flip in the port. (V27 CORE-01/V16-O10/X03-U2.)

### 2.7 Water field `cOffsetY = -0.5` runtime activity — **UNVERIFIED**

- **Search (2 passes, whole donor root):** `grep "cOffsetY|hmapTex|EyePlane|TextureMatrix|bmTransparency|GenerateMapRandKey" C:\Games\Cossacks 3` → 176 hits; targeted `grep cOffsetY` on both occurrences.
- **Found:** exactly two authored water occurrences, **both `[*] = ;`**: `data/scripts/common.inc/generatemap.inc:688 const cOffsetY = -0.5;` and `:704 WaterFieldAdd('x'+…, tx, tz, bx, bz, cOffsetY);`; identical at `scripts/editor.inc/generatemapfrombitmap.inc:315/325`. All other `cOffsetY` hits are GUI layout constants (`gui/menu.inc/showsettings.inc:35-38,654-657…`, value 56) — unrelated. `native_functions_search "WaterFieldAdd"` cossacks/editor: 0 functions (discovery capped), so no native body was recovered to prove the call executes.
- **Verdict:** **UNVERIFIED** — the `-0.5` value is observed as authored intent in two commented files; **runtime execution cannot be proven under the read-only charter**. Keep water-field offset as `PORT APPROXIMATION`/`[U]`; do not assert the donor executes it. (V27 CORE-03, V16-O11.)

### 2.8 `GenerateMapRandKey` — **SIGNATURE RESOLVED / body UNVERIFIED**

- **Search:** `grep GenerateMapRandKey data/**` and whole donor root; `native_functions_search` (2 binaries); `native_strings_find` (2 binaries); `native_bytes_find` text (2 binaries); `native_xrefs_list` at both VAs; PowerShell raw-byte read around cossacks.exe `0x29e820`.
- **Found:** 3 text call sites (`map.script:322` **live**, `donewgame.inc:16` + `initmapsettings.inc:8` commented). Raw bytes show the compiled DScript **signature** at cossacks.exe file `0x29e848`-`0x29e892` (VA `0x69f448`-`0x69f492`), length `0x4A`: `procedure GenerateMapRandKey(var randkey0: Integer; var randkey1: Integer)`; adjacent `GetMapGeneratorRandomKey` / `SetMapGeneratorRandomKey` signatures. editor.exe same string at file `0x36962e` / VA `0x76a22e`. No text body; no discovered function; **0 static xrefs** at the name VAs in both binaries.
- **Verdict:** **PARTIALLY RESOLVED** — signature and both `var Integer` parameters are `[O]` with path/opcode; **the derivation body remains UNVERIFIED** (a DScript bytecode body is not present as readable text and has no code xref). All generation stages re-seed `randkey1` verbatim (D02/C-G), so replay fidelity does not need the derivation. **Do not invent a hash/mix formula.** (V27 CORE-12 stays DOCUMENT_ONLY for the body; signature is a new fold-in for spec/02.)

### 2.9 Full relief grids for the 5 families — **LAYOUT RESOLVED / semantics UNVERIFIED**

- **Search:** `read data/game/var/generator.cfg:1-120`; `grep Name|Pattern|Freq` in it; cross-read F01/X27/V01/V37 for grid coverage; `grep` pattern.lib for Flip/Row (§2.6).
- **Found:** `generator.cfg:67+` enumerates 64 named pattern families with per-pattern `Freq` (first active families `mng`, `mni`, `mnc`, `desert_mng/mni/mnc`, `plain_small`, `plain_medium`, `plain_big`, `plain_huge` at `:69-493`); 6 vanilla terrain-type mask paths at `:1-28`. F01's closure `filesize = 8+4wh+54(w-1)(h-1)` (710/710, zero residual) and `G = 8+(w-1)(h-1)` address the float grid of every `.pattern` file; V01 U13/X27 report ~26–30 grids bit-verified vs ~50+ active ids. No new grid bits were decoded in this pass (no need — the address is closed), and no id/weight/tail semantics were recovered.
- **Verdict:** **RESOLVED for byte addressability** (`G = 8+(w-1)(h-1)`, F01 §4.1–4.2, generator.cfg family list); **UNVERIFIED for the remaining semantic labels** (`Rec24.id`, 4-byte tail, `int32[4N-1]` weights, `Tail13` flags) and for which ~50+ active ids have been bit-verified end-to-end. I02 can emit every full grid plus `null`+`UNVERIFIED` for semantics; **no values invented**. (V27 CORE-18/X03-U14/spec/00 U14.)

---

## 3. Multiple-pass log (CHARTER.md:85-93)

| # | Anomaly | Pass 1 | Pass 2 | Pass 3 | Final reading |
|---|---|---|---|---|---|
| M1 | `GenerateMapRandKey` has no body | `grep` text tree (3 call sites only) | `native_functions_search`/`native_strings_find` both PEs (0, capped) | `native_bytes_find` + raw byte decode + xrefs (signature found, 0 xrefs) | Signature `[O]`; body `[U]` |
| M2 | `hmapTex` "0 strings" from builtin finder | `native_strings_find` → 0 | `native_bytes_find` → 1 at VA `0x853e0c` | Deep `FUN_00853ad4` decompile + builtin `function_show` (builtin not found) | Key-only registration `[O]`; bind/planes `[U]`; Deep accepted |
| M3 | Stamp row order / blend count | `grep` DScript (all commented) | Deep `FUN_00755f30` decompile (row-first grid, 3 branches, field-driven loop) | prior D05/X12 opcode reads (same three branches) | Index order `[O]`; sign `[U]`; no fixed pass constant `[O]` |
| M4 | "R1" looks like a relief parameter | `native_bytes_find` → 66 hits | raw byte decode of the cluster → debugger register table | GUIDE4.md names-only | False positive cleared; ranges `[U]` |
| M5 | `cOffsetY=-0.5` runtime | text grep (2 files, both commented) | whole-root grep (GUI constants disambiguated) | `native_functions_search WaterFieldAdd` → 0 (capped) | Authored intent `[O]`; execution `[U]` |
| M6 | `bmTransparency` pass count | text grep (enum only) | binary name strings (`tsDouble` etc.) | X17 six-pass factors/equation (no count) | Count `[U]` |

No anomaly was accepted after a single reading. Absence under a capped instrument is labelled partial, never proof.

---

## 4. Short list for COORD — genuinely unresolvable under read-only rules (keep DOCUMENT_ONLY)

1. **Row sign / `row_flip` file-row→world-y** — only commented DScript; no `Flip` field; no readable consumer. Keep `row_flip="UNVERIFIED"`; do not add a flip.
2. **`bmTransparency` composite pass count** — enum + `tsDouble` name only, no draw-pass loop; GPU trace or packed `.bind` needed. Keep PORT APPROX two-layer blend, no asserted layer count.
3. **R1–R6 numeric ranges** — editor-manual names only; binary "R1" hits are a debugger register table. No donor numbers exist; assert none.
4. **Water `cOffsetY=-0.5` runtime activity** — two authored `[*] = ;` files; no native body/xref; execution unprovable without running the donor.
5. **`hmapTex` bound texture/FBO, sampler units, eye-plane numerics** — setter is key-only `[O]`; actual GL state needs a trace. Keep binding `[U]`.
6. **`GenerateMapRandKey` body** — signature now `[O]`, derivation still absent. Re-seed verbatim; do not invent a mix/hash.
7. **Full semantic labels for relief grids** (`Rec24.id`, tail, weights, `Tail13`) and the exact set of bit-verified active ids — layout closed, semantics unrecoverable from static bytes.
8. **`HeightField` struct-field `+0x54` name mapping** — pass count is data-driven `[O]`, but the native field name is not mappable to a `pattern.lib` key; do not assert one.

These are **not** gate blockers under V27's DOCUMENT_ONLY disposition, but none may be promoted to a PASS or a donor value.

---

## 5. Handoff / guards

1. **[O] Net change to the `[U]` register:** one upgrade (`GenerateMapRandKey` signature RESOLVED), one negative resolution (no fixed `HeightField` blend pass count), one partial confirmation (`hmapTex` key-only setter), one false positive cleared (editor.exe "R1"), and five items explicitly reconfirmed UNVERIFIED with the searches and reasons above.
2. **[D] No implementation numeric was invented.** Every RESOLVED verdict cites a donor path:line or VA/opcode; every UNVERIFIED verdict states the missing readable consumer or the instrument limitation.
3. **[U] Shared-session hygiene:** no `core_brief`/`core_hypothesis`/`core_finding` write; all native calls used explicit `document=` ids; the active target (cossacks.exe) was not changed; no donor binary executed.
4. **[U] No parity claim.** Nothing here certifies donor visual fidelity; parity stays UNVERIFIED (CHARTER.md:43-44,125).

*End of X51 report. Exactly one repo file written; no source, shader, config, asset, test, git, Godot, runner or `app/` state changed; donor read only.*
