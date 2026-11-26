---
id: X01-DECOMP-CORPUS-2026-11-26
title: "Bulk pseudo-C corpus of cossacks.exe — full discovered-function coverage, term index, garbled multi-pass register"
owner: X01 (worker, DONOR-FIRST terrain swarm)
created: 2026-11-26
status: LANDED
target: t_87f0f3c130b0 (cossacks.exe, 5,768,048 B, x86 PE, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c)
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION"]
corpus_location: "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\cossacks3_decomp (outside repo; private-use donor derivative; never commit)"
scope: Read-only donor analysis. No donor binary executed, no binary copied into repo, no source/shader/config/git edits.
---

# X01 — bulk pseudo-C decompilation corpus + terrain-term index

## 1. Executive summary

1. **[O] Full corpus written.** All **18,918 of 18,918 discovered functions** of `cossacks.exe` were
   exported as individual pseudo-C files by 20 resumable `native_source_folder_write` calls into
   `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\cossacks3_decomp\` — **0 write failures,
   0 zero-byte files, 0 missing files** (§4). The state file records engine `clean-room lifter`.
2. **[O] Quality, not coverage, is the limiting factor.** The state file flags **4,265 / 18,918
   (22.54 %) functions `structured:false`** — i.e. garbled/unstructured pseudo-C. Only **14,653
   (77.46 %)** are structured. This is the DA_PE.md §4.5 warning, measured on the whole binary.
3. **[O] The term-grep deliverable is a *negative* result.** None of the requested terrain terms
   (`height, relief, pattern, water, shore, tile, forest, stone, mine, coal, iron, gold, field,
   mill, pump, camp, generator, randkey, terrain, cossacks map`) occurs anywhere in the clean-room
   corpus. The only hits are **import-thunk names** (`MaskBlt`, `glColorMask`, `glDepthMask`,
   `glBindTexture`, GDI bitmap APIs) with **no terrain semantics** (§5.2). Cause [D]: the lifter does
   not emit inline string literals, and gameplay literals are absent from the readable sections
   (DA_PE.md §4.4).
4. **[D] Text cannot anchor terrain; D01's RTTI/VMT method can.** `native_strings_find` and
   `core_feature_find` confirm RTTI strings such as `XMapGenerator`, `XTerrainDataLite`,
   `XTileSmooth`, `XPatternMask`, `XWater`, `HXHeightField` have **0 code cross-references** in this
   tool path. D01 (`reports/D01_rtti_function_anchors.md`) resolved that paradox: the names are
   *inline shortstrings inside RTTI records* of `TX*` classes. My corpus cross-check of 34 D01
   anchors found **only 11 present as function entries; 23 are absent from the engine's discovery
   set entirely** (§4.3). Full corpus coverage is therefore complete *relative to discovered
   functions only*, not relative to all real terrain code. **This is the single most important
   handoff from X01.**
5. **[O] Multi-pass contrast established (owner directive).** `native_function_pseudocode` selects
   `engine:"ghidra"` for correctly anchored functions and silently falls back to
   `engine:"clean-room lifter"` for mis-anchored ones. `native_function_study` always carries
   clean-room pseudo-C but adds assembly, callers/callees and string lists. Every garbled candidate
   below got three passes; unresolved ones are `[U] UNVERIFIED` with passes attempted (§6).
6. **[I] No parity claim.** The corpus is behavioural evidence for reimplementation only. It is
   register-level x86 pseudo-C, not Delphi source, and no donor GPU A/B frame exists. Everything
   semantic below is `PORT APPROXIMATION` until D01–D08/F-lane evidence is integrated.

## 2. Evidence table

| # | Evidence (id / path) | What it establishes | Label |
|---|---|---|---|
| E1 | `ev_31c589944fb992e809022e55fb791b98f7fd26f9387111693a7729cab94c060a` (`native_source_folder_write`, first 50 functions) | Export tool works; target sha256 `87f0f3c1…`; engine `builtin`; limitation `pseudo_code_inferred` + `discovery_capped` | [O] |
| E2 | `…\cossacks3_decomp\craft-pseudocode-export.json` (2,734,801 B) | 18,918 entries; fields `file`, `name`, `lines`, `structured`; `structured=false` on 4,265; target sha256 matches `t_87f0f3c130b0` | [O] |
| E3 | `…\cossacks3_decomp\*.c` (18,918 files, 295,400,669 B) | One `.c` per discovered function; 0 empty, 0 <40 B; min 4 / max 54,276 / avg 452 lines | [O] |
| E4 | `…\cossacks3_decomp\0000000000401000_sub_401000.c` | 202-line unstructured pseudo-C, `outsd/insb/popad` nonsense | [O] |
| E5 | `ev_9a65efcd61446c8811e32f0e9d49db15eb82a07e4594966919c1299442e9e774` (`native_function_study 0x401000`) | 35 blocks / 194 instructions / 2 callees / 0 callers / 21 incoming refs / 0 strings; end `0x407703` | [O] |
| E6 | `…\cossacks3_decomp\00000000005bef8c_sub_5bef8c.c` + `ev_296b4c4072bdfa84c1d9b88159f100132d45b0c7e2d024a7e113e14225c99f34` | 54,276-line unstructured file; dossier 19,420 blocks / 36,781 instructions / 112 callees / 0 callers / 22 unresolved indirect calls | [O] |
| E7 | `ev_56f52c1e79a81800b589e7b139aab34cef404a213b5a3ccbbcaf66f1b3bc72ca` (`native_function_study 0x4a67b8`) | 1 block / 10 instructions / 18 callers / clean x87 `fsqrt`+`fpatan` | [O] |
| E8 | `ev_3f49b8c80951d0817efe6759370ce92564a258f17ceacbba384cc6e00f129707` (`native_function_study 0x72d80a`) | Requested `0x72d80a` resolves to `sub_72d64c`; 38 blocks / 215 instructions / 11 callees / 0 callers; garbage | [O] |
| E9 | `ev_ad06ff1890584eda0dfa9bbc202b0d54a8062a41e4a668c27f731698dd976ac0` (`native_function_study 0x71d2fc`) | `TXMapGenerator.Create`: 261 instructions / 32 calls / 1 caller; Ghidra lift clean | [O] |
| E10 | `native_strings_find` / `core_feature_find` on 6 RTTI names (`XMapGenerator`, `XTileSmooth`, `XWater`, `XHeightField`, `XPatternMask`, `XTerrainDataLite`) | Each returns the `.rsrc` string with `references: []`; `functions: 0`, `imports: 0` | [O] |
| E11 | `native_functions_search` on 22 terrain terms | 0 terrain-named functions; only `MaskBlt@thunk`, `glColorMask@thunk`, `glDepthMask@thunk`, `glBindTexture@thunk`, bitmap/map thunks | [O] |
| E12 | `docs/decomp/DA_PE.md` §4.5, §3 (`ev_a44201a…`, `ev_b0e5246…`) | Prior-art warning: clean-room garbled vs Deep/Ghidra clean; decoder quality varies | [O] |
| E13 | `reports/D01_rtti_function_anchors.md` §3.3, §4 (E4–E27) | `TX*` VMT anchors; `TXTileSmooth` ctor 5-pass BLOCKED; ctor/dtor field symmetry | [O]/[D] |
| E14 | Target probe `core_session_show` / `core_targets_list` | Active target `t_87f0f3c130b0` throughout; Deep mode reported; second open target `t_68474ddde43f` (editor.exe) never activated | [O] |

**Method note (honesty).** A first background pass tried to count term-grep files with
`@(rg … | Measure-Object).Count`; this always returns `1` regardless of matches and was **discarded**.
All counts in this report come from the dedicated `grep` tool (ripgrep), the state file, or
PowerShell `ForEach-Object` without the `Measure-Object` wrapper.

## 3. Method

1. Confirmed active target and sha256 with `core_session_show` / `core_targets_list`; every tool
   call passed `document:"t_87f0f3c130b0"` explicitly. No other target was opened.
2. Created the corpus with `native_source_folder_write` — 1 × 50 functions (probe), 18 × 1,000,
   1 × 868 (final) = **20 calls**. The tool resumes from `craft-pseudocode-export.json`, skips
   finished functions, writes atomically, and refuses a different target sha256.
3. Verified output on disk with PowerShell: file count, byte totals, zero-byte check, state-file
   schema, `structured` flag histogram.
4. Grepped the corpus with the `grep` tool (ripgrep) for all requested terrain terms and for
   structural signals (`__asm("fsqrt")`, `fabs`, `fpatan`, thunk names), case-insensitive.
5. Cross-checked garbled/structural candidates with `native_function_study` (assembly, callers,
   callees, referenced strings, unresolved calls) and `native_function_pseudocode` (records its
   `engine`: `ghidra` vs `clean-room lifter`). See §6.
6. Cross-wired D01's VMT-anchored class table against the corpus state file and
   `native_function_find` to measure true coverage of known terrain code (§4.3).

**Guardrails observed:** read-only donor; no donor binary executed or copied; corpus lives only in
the approved temp folder; repository edits limited to this one report; no brief/plan/handoff writes
in the shared investigation; no runner jobs.

## 4. Corpus coverage

### 4.1 Export totals [O]

| Metric | Value |
|---|---:|
| Functions discovered by engine | 18,918 |
| Functions written | **18,918 (100 %)** |
| Remaining / failures / `replaced_missing` | 0 / 0 / 0 |
| Calls used | 20 (50 + 18×1,000 + 868) |
| `stopped_because` on final call | `finished` |
| `.c` files on disk | 18,918 (+ 1 state file) |
| Total `.c` bytes | 295,400,669 (~281.7 MiB) |
| State file | `craft-pseudocode-export.json`, 2,734,801 B, 18,918 entries |
| Zero-byte / <40-byte `.c` files | 0 / 0 |
| Lines per function | min 4, max 54,276, avg 452 |
| Structured (`structured:true`) | **14,653 (77.46 %)** |
| Unstructured (`structured:false`) | **4,265 (22.54 %)** |

### 4.2 Quality distribution [O]

`structured:false` is the lifter's own flag for unstructured/garbled output. The tail is extreme:
the ten largest files (0x5bef8c … 0x5c0238) are all unstructured and 50,398–54,276 lines each.
This is not "more detail"; it is the lifter walking bytes that are not code (§6.2).

### 4.3 Coverage of D01's terrain-class anchors [O]/[U]

34 addresses taken from `reports/D01_rtti_function_anchors.md` §3.3/§4 were checked against the
state file and `native_function_find`:

| Anchor | Class / role (D01) | Corpus | `structured` |
|---|---|---|---|
| `0x71d2fc` | TXMapGenerator.Create | present | True |
| `0x72d91c` | TXTileSmoothList override (candidate rule applier) | present | True |
| `0x851f18` | TXWaterManager.Create | present | True |
| `0x73ab88`, `0x73ac90` | TXWaterField virtuals | present | True |
| `0x8127e0`, `0x817a50` | TXHeightField virtuals | present | True |
| `0x849fcc` | TXCollisionMask.Create | present | True |
| `0x810b70` | TXTerrain virtual | present | **False** |
| `0x7d9fc4` | TXTopology.Create | present | **False** |
| `0x7650f0` | TXPatternMask override (579 lines) | present | **False** |
| `0x71d67c`, `0x59b6e8`, `0x59b724`, `0x82e1cc`, `0x82ea30`, `0x754cb0`, `0x754dd8`, `0x72d7f0`, `0x72fa68`, `0x72fc48`, `0x72fed4`, `0x851f94`, `0x73b520`, `0x80cd9c`, `0x875544`, `0x81868c`, `0x8139a0`, `0x8179c4`, `0x764cc0`, `0x7792a4`, `0x77cc40`, `0x84f3f0` | ctors/dtors/virtuals of terrain, tile, pattern, water, cliff, border classes | **absent as entries** | — |

- **11 / 34 present, 23 / 34 absent as entries.** `native_function_find` confirms representative
  absentees (`0x71d67c`, `0x59b6e8`, `0x754cb0`, `0x851f94`, `0x80cd9c`) are **not inside any
  discovered function** — genuinely missing from the corpus.
- `0x72d7f0` (D01's byte-clean `TXTileSmooth` ctor candidate) *is* inside discovered `sub_72d64c`
  at offset 420 — but that host is unstructured garbage (§6.3).
- **[D] Consequence:** "18,918/18,918" is honest for the *discovered set*, but must never be read
  as "the whole donor binary is decoded". Terrain constructors and destructors reached only by
  VMT/computed pointers are outside it.

## 5. Categorised function index

### 5.1 Category A — terrain subsystem anchors (D01 RTTI/VMT; corpus status noted)

Descriptions are one-line summaries of D01's pseudo-C reads; where X01 only checked presence, the
role is D01's `[I]` and is marked as such. All addresses are VAs in `cossacks.exe`.

| Entry | Label / class | One-line description | Corpus | Label |
|---|---|---|---|---|
| `0x71d2fc` | TXMapGenerator.Create | Allocates generator, creates 3 dynamic arrays and 14 fields, seeds `+0x18/+0x1c`, sets two floats to 1.0f | present, structured | [D] |
| `0x71d67c` | TXMapGenerator.Destroy | Frees exactly the arrays/objects created by `0x71d2fc` (ctor/dtor symmetry) | **absent** | [D] |
| `0x59b6e8` / `0x59b724` | TXTerrainDataLite.Create / Destroy | Zeroes holder fields / frees two owned strings | **absent** | [D] |
| `0x82e1cc` / `0x82ea30` | TXTerrainData.Create / Destroy | Full terrain holder with two list fields | **absent** | [D] |
| `0x754cb0` / `0x754dd8` | TXPattern.Create / Destroy | `.pattern` record: defaults 3/4/2, five 1.0f floats, three owned lists / inverse free | **absent** | [D] |
| `0x72d7f0` | TXTileSmooth ctor candidate | Raw bytes show Delphi ctor prologue; semantics unliftable (5-pass BLOCKED) | inside `0x72d64c`, unstructured | [U] |
| `0x72d91c` | TXTileSmoothList override | Candidate smoothing-rule applier; 20-line structured function | present, structured | [I] |
| `0x851f18` / `0x851f94` | TXWaterManager.Create / Destroy | Creates object at `+8`, shader at `+0x10`, sets `+0x1c = -1` / inverse teardown | present / **absent** | [D] |
| `0x73ab88`, `0x73ac90`, `0x73b520` | TXWaterField virtuals | Scene-object water-field virtuals; likely render/update hooks | 2 present structured, 1 absent | [I] |
| `0x8127e0`, `0x817a50`, `0x8139a0`, `0x8179c4`, `0x81868c` | TXHeightField virtuals | Height-field scene object virtuals (render/query/cache roles inferred) | 2 present structured, 3 absent | [I] |
| `0x80cd9c`, `0x810b70`, `0x875544` | TXTerrain virtuals | Terrain scene-object virtuals; `0x810b70` is 460 lines unstructured | 1 present unstructured, 2 absent | [I]/[U] |
| `0x7d9fc4` | TXTopology.Create | Sets cell bounds to `0x7fffffff/0x80000001`, allocates cell buffer | present, unstructured | [D]/[U] |
| `0x849fcc` | TXCollisionMask.Create | Passability mask holder, 26-line structured function | present, structured | [I] |
| `0x764cc0`, `0x7650f0` | TXPatternMask overrides | Pattern-mask scene object overrides; `0x7650f0` 579 lines unstructured | 1 present unstructured, 1 absent | [I]/[U] |
| `0x7792a4`, `0x77cc40` | TXTerrainBorders overrides | Terrain-border scene object virtuals | **absent** | [I] |
| `0x84f3f0`, `0x84f2c4` | TXCliffBlock overrides | Cliff scene-object virtuals | **absent** | [I] |

### 5.2 Category B — term-grep hits in the corpus (all low-value / false positives)

| Term | Corpus result | Functions | One-line description | Label |
|---|---|---|---|---|
| `mask` | 9 files | `0x408684` `MaskBlt@thunk` | GDI masked bitmap blit thunk (6 bytes) — **not** terrain mask | [O] |
| `mask` | caller | `0x4331f0` | Calls `MaskBlt@thunk` at line 130; generic GDI paint path | [I] |
| `mask` | 5 files | `0x4afb34`, `0x4afb64` `glColorMask/glDepthMask@thunk` | OpenGL colour/depth write-mask thunks | [O] |
| `mask` | callers | `0x4cffdc`, `0x5811ec`, `0x582914`, `0x5db3fc`, `0x88faf8` | Toggle colour/depth masks around render passes (UI/FX, no terrain evidence) | [I] |
| `texture` | 2 files | `0x4afb0c` `glBindTexture@thunk`, `0x88f8a8` | OpenGL texture bind thunk and one caller | [O] |
| `map` | 0 semantic hits | `0x4084d4`, `0x4084e4`, `0x4084fc`, `0x408584`, `0x40871c`, `0x408c4c` | GDI bitmap/map thunks (`CreateBitmap…`, `SetMapMode`, `MapVirtualKeyA`) — false positives | [O] |
| `height`, `relief`, `pattern`, `water`, `shore`, `tile`, `forest`, `stone`, `mine`, `coal`, `iron`, `gold`, `field`, `mill`, `pump`, `camp`, `generator`, `randkey`, `terrain` | **0 corpus files** | — | Clean-room lifter emits no inline string literals; DA_PE §4.4 explains absent gameplay literals | [O]/[D] |

**Evidence for the negative result:** dedicated `grep` over all 18,918 `.c` files; corroborated by
`native_functions_search` (0 terrain-named functions) and `native_strings_find` / `core_feature_find`
(RTTI strings only, `references: []`, `functions: 0`).

### 5.3 Category C — x87 math helpers surfaced by structural grep (Ghidra-verified)

These are *not* proven terrain routines; they are the only float-heavy functions with clean lifts
and are supplied as candidate primitives for D05/D06/D08 to test. `[I]` = inferred role.

| Entry | One-line description | Callers | Corpus | Label |
|---|---|---|---|---|
| `0x4a31c8` | Returns `sqrt(a² + b²)` — 2D Euclidean norm, 10 instructions | 6 | structured (10 lines) | [D] |
| `0x4a31e0`, `0x4a31fc`, `0x4a3224`, `0x4a328c`, `0x4a3418`, `0x4a3528`, `0x4a3910`, `0x4a3930` | Sibling `fsqrt` / `pfrsqrt` wrappers — vector length and normalisation primitives (roles inferred from instruction shape) | — | mostly structured | [I] |
| `0x4a67b8` | `fpatan(sqrt(C − x²), x)` — converts a cosine-like component to an angle; 10 instructions | 18 | structured (10 lines) | [D] |
| `0x4a6828`, `0x4a6838`, `0x4a67d4`, `0x4a6810`, `0x4a6e64` | Companion atan/sqrt helpers called from `0x4a70fc` | many | structured | [I] |
| `0x4a70fc` | `FUN_004a70fc(struct*, float out[3], char mode)`: selects axis pairs from a 12-field struct by mode byte, applies `ABS` against constant `_DAT_004a74d0`, writes 3 floats — candidate coordinate/normal transform | 1 (`0x657740`) | structured (262 lines) | [D]/[I] |
| `0x657740` | Wrapper: resolves object → struct via `0x705944`/`0x706090`/`0x4ca134`/`0x4a5048`, calls `0x4a70fc`, returns three floats — candidate 3D position/orientation getter | — | structured (31 lines) | [I] |
| `0x4f3e98` | 6-integer-argument float routine with nine `fabs` comparisons and many locals; purpose unresolved | — | **unstructured** (277 lines) | [U] |

### 5.4 Category D — garbled / mis-anchored (see §6)

`0x401000`, `0x5bef8c` (+ ~9 neighbours), `0x5bf090`, `0x72d64c` (hosting D01's `0x72d7f0`),
`0x4f3e98`. All `[U] UNVERIFIED`.

## 6. GARBLED / MULTI-PASS register (owner directive)

Rule applied: no function was silently skipped after one pass. Each candidate below records what
each pass produced. "Pass 1" = corpus file (clean-room lifter); "Pass 2" =
`native_function_pseudocode` (engine recorded in the response); "Pass 3" =
`native_function_study` (assembly / blocks / callers / callees / strings / unresolved calls).

### 6.1 `0x401000` — mis-anchored entry into data

- **Pass 1 (corpus):** `0000000000401000_sub_401000.c`, 202 lines, `structured:false`. Statements
  such as `__asm("outsd dx, [esi]")`, `__asm("popad")`, `al += 0x10`, `eax += 0x736c6146`.
- **Pass 2 (`native_function_pseudocode`):** returned `engine:"clean-room lifter"`, 8,307 chars,
  same garbage. **Ghidra did not lift it** — the fallback is itself a diagnostic.
- **Pass 3 (`native_function_study`, `ev_9a65ef…`):** 35 blocks / 194 instructions / size 432 B,
  entry `0x401000` but **end `0x407703`** (a 22 KB span), 2 callees (`sub_404628` at `0x4076d7`,
  `InterlockedIncrement@thunk` at `0x4076fa`), **0 callers**, 21 incoming references, 0 strings,
  unresolved indirect calls 0. Assembly starts `add al,0x10; inc eax; add [ebx],al; pop es; inc edx;
  outsd dx,[esi]` — not a function prologue.
- **Verdict:** `[U] UNVERIFIED`. Passes attempted: 3. The two "callees" belong to the real function
  at `0x404628`; `0x401000` is a false entry. Do **not** use its semantics; use `0x404628` instead
  (pass 2 gives clean Ghidra pseudo-C there).

### 6.2 `0x5bef8c` and the ~50k-line cluster — degenerate lifter cascade

- **Pass 1 (corpus):** `00000000005bef8c_sub_5bef8c.c`, **54,276 lines**, `structured:false`.
  Neighbours `0x5bf090` (54,069), `0x5bf194` (53,867), `0x5bf298` (53,661), `0x5bf39c` (53,456),
  `0x5bf4a0` (53,253), `0x5bf5a4` (53,034), `0x5bf800` (52,603), `0x5bfe70` (51,173),
  `0x5c0238` (50,398) — all unstructured. Body repeats `label_…`, `outsd/insb`, `pop`, flag tests.
- **Pass 2 (`native_function_pseudocode` on `0x5bef8c`):** `engine:"clean-room lifter"`,
  1,382,112 chars — identical degenerate pattern; no Ghidra lift. `0x5bf090` likewise 1,377,186
  chars, clean-room fallback.
- **Pass 3 (`native_function_study`, `ev_296b4c…`):** 19,420 basic blocks / 36,781 instructions /
  165 outgoing references / **112 callees** / **0 callers** / **0 referenced strings** /
  **22 unresolved indirect calls** / 1 incoming reference.
- **Verdict:** `[U] UNVERIFIED`. Passes attempted: 3 (plus `0x5bf090` independently). Almost
  certainly byte data mis-discovered as code; **excluded from terrain inference** but retained in
  the corpus as required (nothing silently skipped).

### 6.3 `0x72d80a` / `0x72d7f0` — TXTileSmooth ctor (cross-check of D01 E27)

- **Pass 1 (corpus):** **no file** at `0x72d80a`, `0x72d800`, `0x72d806` or `0x72d7f0`. The host
  `000000000072d64c_sub_72d64c.c` exists with 198 lines, `structured:false` (`salc`, `arg_4d *
  0x47061`, `pushfd` nonsense).
- **Pass 2 (`native_function_pseudocode` on `0x72d80a`):** `engine:"clean-room lifter"`, resolves
  to `sub_72d64c` — same garbage; Ghidra refuses the address.
- **Pass 3 (`native_function_study`, `ev_3f49b8…`):** 38 blocks / 215 instructions / 11 callees /
  0 callers / 0 strings. `native_function_find("0x72d7f0")` → `sub_72d64c`, offset 420.
- **Pass 4 (D01 E27, cited):** raw bytes at `0x72d7f0` are a clean Delphi ctor prologue
  (`53 56 84 d2 74 08 …`); five entry addresses all failed to lift.
- **Verdict:** `[U] BLOCKED`. Passes attempted: 4 (3 by X01 + D01's byte pass). Class identity is
  certain from VMT `0x72d6e8`; constructor semantics remain unverified.

### 6.4 `0x4a31c8` — Ghidra regression (opposite direction)

- **Pass 1 (corpus):** `00000000004a31c8_sub_4a31c8.c`, 10 lines, `structured:True`, reads
  `__asm("fsqrt")` — a clear `sqrt(a²+b²)`.
- **Pass 2 (`native_function_pseudocode`):** `engine:"ghidra"`, but body is
  `void FUN_004a31c8(void) { return; }` — **the x87 result is lost**.
- **Pass 3 (`native_function_study`):** 1 block / 10 instructions / 6 callers / 0 callees; assembly
  `fld [ebp+0xc]; fmul st,st(0); fld [ebp+8]; fmul st,st(0); faddp; fsqrt; ret 8`.
- **Verdict:** `[D]` behaviour recovered from passes 1+3; the Ghidra pass is incomplete for x87
  stack-return functions. **Do not assume Ghidra is always cleaner** — use both, as here.

### 6.5 `0x4f3e98` — float-heavy routine with unreliable lift

- **Pass 1 (corpus):** 277 lines, `structured:false`, nine `fabs` operations.
- **Pass 2 (`native_function_pseudocode`):** `engine:"ghidra"`, 4,090 chars, clean signature
  `FUN_004f3e98(int,int,int,int,int,int)` with many `float`/`float10` locals and a call to
  `FUN_004a2504`, but truncated before the decision logic.
- **Pass 3 (`native_function_study`):** large block/effect count; no strings; purpose not resolved.
- **Verdict:** `[U] UNVERIFIED`. Passes attempted: 3. Candidate only; no terrain claim.

## 7. Implications

1. **[O] The corpus is a working index, not a specification.** It is complete over the engine's
   discovery set and searchable in ~300 MB of text; it can answer "does this API/constant/callee
   occur and where" but **cannot answer terrain semantics by term grep**.
2. **[D] Anchoring must come from RTTI/VMT (D01), not strings.** X01 independently reproduced the
   0-code-xref observation and confirmed D01's resolution is the only viable route. Hand D01's
   anchor table + this corpus's presence map (§4.3) to D03–D08 as the starting point.
3. **[D] Discovery gaps are material.** 23 of 34 D01 terrain anchors have no discovered function
   at all. `native_function_study` / `native_function_pseudocode` can lift them *on demand* from a
   raw-byte address (as D01 did for `0x71d2fc`), so the correct workflow is: **D01 anchor → on-demand
   Ghidra lift → add to spec**, using the corpus only as a secondary cross-check.
4. **[I] Math primitives exist and are cleanly lifted.** The `0x4a31c8` / `0x4a67b8` / `0x4a70fc`
   cluster provides `sqrt(a²+b²)`, angle-from-cosine and a 3-float coordinate transform; D05/D06
   should test them against relief/water hypotheses before porting, not assume they are terrain code.
5. **[O] Quality triage must be mandatory.** 22.54 % of corpus files are flagged unstructured. Any
   downstream worker grepping the corpus must check `craft-pseudocode-export.json`'s `structured`
   flag and apply §6-style multi-pass verification before trusting a function.

## 8. Risks

| Risk | Impact | Mitigation |
|---|---|---|
| Corpus `structured:false` (4,265 functions) misread as truth | Wrong port rules | Check flag; multi-pass (§6); mark `[U]` |
| "18,918/18,918" misread as full-binary decode | False completeness claim | Always quote §4.3: 23/34 known terrain anchors absent |
| Ghidra fallback is silent | Garbage mistaken for clean lift | Record returned `engine` field; if `clean-room lifter`, treat as suspect |
| Ghidra loses x87 stack returns (`0x4a31c8`) | Valid primitive discarded | Compare corpus + assembly, not Ghidra alone |
| Corpus is donor-derived, private use | Licensing/contamination | Stays outside repo; never commit; no donor binary copied or run |
| Single shared Craft Anything target | Disturbing other workers | Explicit `document` on every call; never opened/switched a target |
| First grep count bug (`@(Measure-Object)`) | False "1 match" per term | Discarded; counts recomputed with dedicated grep tool |

## 9. UNVERIFIED register

| ID | Claim / item | Status | Passes attempted | Next owner |
|---|---|---|---|---|
| U-X01-01 | Terrain semantics of `0x401000` | `[U]` mis-anchored; do not use | 3 (corpus, Ghidra fallback, dossier) | D01/D02 |
| U-X01-02 | Terrain semantics of `0x5bef8c` + 9 neighbours, `0x5bf090` | `[U]` degenerate cascade | 3 (+1 on `0x5bf090`) | D01 (ignore) |
| U-X01-03 | `TXTileSmooth` ctor at `0x72d7f0` / `0x72d80a` | `[U] BLOCKED` — bytes clean, lift impossible | 4 (3 X01 + D01 byte pass) | D03 |
| U-X01-04 | `FUN_004f3e98` purpose | `[U]` unresolved float routine | 3 | D05 |
| U-X01-05 | `0x4a70fc` / `0x657740` are terrain coordinate/normal helpers | `[I]` role inferred only | 3 for `0x4a70fc`, 2 for `0x657740` | D05/D06 |
| U-X01-06 | The 23 D01 terrain anchors absent from corpus have correct semantics | `[U]` not in this corpus by construction | state-file lookup + `native_function_find` on 5 representatives | D01 on-demand lift |
| U-X01-07 | "Deep/Ghidra output is cleaner than clean-room" (DA_PE §4.5) | `[U]` in this session: true for `0x404628`, `0x4a67b8`, `0x71d2fc`; **false for x87 `0x4a31c8`** and unavailable for mis-anchored entries | 5 functions compared | all binary workers |
| U-X01-08 | Full binary decoded | `[U]` — only the engine's 18,918 discovered functions are decoded | export totals + D01 anchor gap | COORD |

## 10. Open questions

1. COORD decision: should the corpus be regenerated with a discovery pass that follows VMT pointers
   so D01's 23 missing terrain anchors are included? (X01 cannot change discovery settings.)
2. Should downstream workers be given a compact searchable manifest (address → file → `structured`)
   derived from the state file, or is the state file itself sufficient?
3. Can `0x4a70fc`'s mode byte (`0,2,4,1,3,5`) be mapped to terrain axis/slope semantics by D05/D06?
4. Is `_DAT_008f4c14` in `0x4a67b8` a radius² / scale constant tied to map or unit geometry? (Not
   resolved; constant left as observed data.)
5. Does DA_PE's "Deep/Ghidra" claim require a tool configuration not exposed by this MCP server, or
   is the per-function `engine` switch the whole story? U-X01-07.

## 11. Handoff

- Corpus: `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\cossacks3_decomp\` (18,918 `.c` + state
  file). **Read-only; never copy into the repo.** To search: `rg -i "<term>" <folder> --glob '*.c'`;
  to check quality: inspect `structured` in `craft-pseudocode-export.json`.
- To decompile a D01 anchor absent from the corpus: `native_function_pseudocode` with
  `document:"t_87f0f3c130b0"` and the raw-byte address, then record the returned `engine`.
- Target discipline: active target remained `t_87f0f3c130b0` for every call; `t_68474ddde43f`
  (`editor.exe`) was listed but never activated. Shared investigation brief/plan/handoff untouched.

*End of X01 report.*
