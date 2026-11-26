---
id: V90
ticket: "TERRAIN-SWARM-2026-11-26 / V90 — final static syntax seal on all implementation files"
agent: "V90 (read-only static-check worker, DONOR-FIRST terrain swarm 2026-11-26; reporting to COORD)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_SOURCE_EDIT__NO_BACKUP_EDIT__NO_GIT_MUTATION__NO_RUNNER__NO_GODOT__NO_DONOR_ACCESS
owner_file: docs/terrain_swarm_2026-11-26/reports/V90_static_syntax_seal.md
files_created: [docs/terrain_swarm_2026-11-26/reports/V90_static_syntax_seal.md]
files_edited: []
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION"]
multiple_passes: true
parity_guard: "No donor binary, donor byte, donor GPU frame, Godot process, runner job, gate or capture was used by V90. No donor visual parity claim is made or implied (CHARTER.md:43-44,125). Every verdict below is a STATIC syntax/structure result only."
scope_guard: "Only file reads, Python `ast.parse`/`compile(PyCF_ONLY_AST)` via `python -B -c` with PYTHONPYCACHEPREFIX redirected to temp, read-only PowerShell (Get-Content/ReadAllLines/Get-FileHash/Select-String), and one report write were used. No .py/.gd/.gdshader/asset/manifest/config/queue/app/ byte or git state was changed."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
---

# V90 — final static syntax seal

## 0. Verdict in one line

**13/13 implementation files are STATIC PASS on their declared checks: 6/6 Python
files parse under CPython 3.14.3 (`ast.parse` + `compile(..., PyCF_ONLY_AST)`),
6/6 GDScript files have balanced brackets, consistent continuation-aware
indentation and zero duplicate `func` names, and 1/1 `.gdshader` has balanced
braces plus valid `shader_type` / `render_mode` / `uniform` syntax. Zero errors
were produced by any instrument. Godot's own parse/smoke is explicitly NOT run
here and remains COORD's next step. No parity claim.**

No file in scope produced a syntax error requiring a fix. **This is a static
seal, not a gate result, not a runtime verification, and not a donor-parity
claim.**

## 1. Context files read (and an honest absence)

| Required reading | Result |
|---|---|
| `docs/terrain_swarm_2026-11-26/CHARTER.md` | **Read** — all 137 lines; binding guardrails applied (read-only donor, labels, one report per worker, multiple passes on anomalies, no runner/Godot for analysis workers, no parity claim). |
| `reports/V55_python_preflight.md` | **ABSENT — not found.** Neither at the path given nor anywhere under the repo (two listing passes: `glob **/V55_python_preflight.md` → no files; directory enumeration of `docs/terrain_swarm_2026-11-26/reports/` → 107 entries, no V55). `docs/terrain_swarm_2026-11-26/REPORT_INDEX.md:24` independently records V50–V51/V53–V55 as never-landed. No content was invented on its behalf. |
| `reports/V65_patch_verification.md` | **Found at `docs/terrain_swarm_2026-11-26/reports/V65_patch_verification.md`** (not at the path given). **Read** — all 499 lines. Used for the prior-state hash table and for the alert that `gen.gd`/`props.gd` hashes drift between workers. |
| `reports/V83_final_forbidden_scan.md` | **ABSENT — not found.** Same two listing passes; `REPORT_INDEX.md:24` records V63–V77 as never-landed, which includes V83. No content was invented on its behalf. |

**[O] Two of the four requested context reports do not exist in this workspace.**
This does not block the static seal — the seal derives entirely from the current
bytes of the 13 target files — but COORD should know the brief referenced two
non-landed reports. No owner, finding or claim was fabricated for them.

## 2. Environment and instruments

- CPython **3.14.3**, invoked as `python -B -c` with
  `PYTHONPYCACHEPREFIX=C:\Users\Maxym.Oboyshev\AppData\Local\Temp\v90_pycache`
  (confirmed printed by the interpreter). `-B` plus the redirected cache prefix
  guarantee **no `.pyc` was written into the project tree by V90**. (A read-only
  sweep found 33 pre-existing `.pyc` under `variant3d/` and others under `app/`,
  newest at 2026-11-26 10:04:28 — i.e. before V90's first instrument run; none
  was touched.) Targets were read as UTF-8 text only; **no target module was
  imported or executed**.
  - Instrument P-A: `ast.parse(src, filename=path)`.
  - Instrument P-B: `compile(src, path, 'exec', ast.PyCF_ONLY_AST)` followed by
    `ast.dump(...)` — an independent AST-construction/serialisation path.
- PowerShell state-machine scanner over `[System.IO.File]::ReadAllLines`:
  single/double quoted strings (with `\` escape), GDScript triple-quoted
  strings (`"""` / `'''`) and `#` comments are excluded before bracket
  counting, so braces inside string literals or comments are **not** counted.
  A per-line bracket delta is accumulated into a cross-line depth so that
  wrapped signatures/calls are recognised as continuations; indentation is
  checked with a prefix stack only when the line starts at cross-line depth 0.
  `func` names are captured with `^\s*func\s+([A-Za-z_][A-Za-z0-9_]*)` and
  compared in a per-file dictionary; each repeat is reported with both lines.
- Shader scanner: same style of state machine for `//` and `/* */` comments and
  quoted strings; brace depth, `shader_type`, `render_mode` and `uniform`
  statements validated by anchored regexes.

## 3. Multiple-pass log (owner directive, CHARTER.md:85–93)

| Pass | Instrument | Result | Effect on verdict |
|---|---|---|---|
| P1 | `ast.parse` on all 6 Python files, pass 1 | 6 × PASS, zero errors | Initial verdict |
| P2 | `compile(..., PyCF_ONLY_AST)` + `ast.dump` on all 6 Python files | 6 × PASS; AST char counts 104982 / 159509 / 126510 / 95390 / 127129 / 183347 | Independent confirmation; no anomaly |
| P3 | PowerShell scanner pass 1 (naive indent stack) on 6 GDScript files | Brackets balanced and **0 duplicate funcs**, but 7/7/3/12/0/0 "dedent-to-unknown-level" indent flags | **Anomaly — not accepted** |
| P4 | Inspection of all 39 flagged source lines (`data.gd:386-407`, `gen.gd:978-985,1280-1284,1503-1509,1677-1683`, `mesh.gd:313-339`, `props.gd:576-580,829-859`) | Every flag sits on a **wrapped signature/call** whose continuation line was mis-read by P3 as a new indent block (e.g. `data.gd:386-388`, `gen.gd:1504-1508`, `props.gd:851-858`) | P3 flags classified as **instrument false positives**, not source defects |
| P5 | PowerShell scanner pass 2 — continuation-aware depth carrying across lines | 0 duplicate funcs, 0 indent issues in all 6 files — but two instrumentation bugs remained: cumulative counters reused as per-line deltas (`depthEnd` 194/145/180/252/50/208) and a PowerShell division in the display string (bracket totals shown as `=1`) | **Verdict not accepted** |
| P6 | PowerShell scanner pass 3 — per-line deltas and corrected explicit counts | 6 × **PASS**; all `depthEnd=0`, all brackets equal, 0 dups, 0 indent issues, `finalState=normal` | GDScript verdict accepted |
| P7 | Shader brace/syntax scanner | 1 × **PASS**; braces 6-6, depth 0, minDepth 0, state normal, 1 `shader_type`, 1 `render_mode`, 24 `uniform`, 0 bad | Shader verdict accepted |
| P8 | Final re-run of P2 on all 6 Python files after gen.gd drift was observed | 6 × PASS (identical AST char counts) | Python seal holds on final bytes |
| P9 | Final re-run of P6 on all 6 GDScript files, with fresh SHA-256 | 6 × PASS; explicit counts e.g. `gen.gd` curly 51-51, square 304-304, round 1072-1072 | GDScript seal holds on final bytes |
| P10 | Extra re-run of `gen.gd` scanner against its newest hash `2BB553C0` | PASS, 51-51 / 304-304 / 1072-1072, depth 0, 71 funcs, 0 dups, 0 issues | Latest drifted bytes also clean |

**[O] No anomaly was silently skipped.** The only anomalies were (a) P3's
indent flags, resolved by source inspection at P4 as continuation artefacts and
eliminated by the corrected instrument at P5/P6, and (b) two bugs in V90's own
P5 instrumentation, corrected at P6. Neither was a defect in a target file.
One interpreter quote-glitch in V90's first attempt at the P2 one-liner produced
a `SyntaxError` in the *analysis command itself* (not in any target file); it
was rewritten and re-run successfully — recorded here for full transparency.

## 4. Python files — per-file results (all PASS)

Terrain toolchain under `variant3d/tools/`. Both instruments P-A and P-B passed
on every file; no `SyntaxError`, no exception, zero errors reported.

| File | Bytes | Lines | P-A `ast.parse` | P-B `compile(PyCF_ONLY_AST)` + `ast.dump` |
|---|---|---|---|---|
| `decode_donor_cfg.py` | 37682 | 876 | **PASS** | **PASS** — 104982 AST chars |
| `decode_pattern_lib.py` | 48586 | 1127 | **PASS** | **PASS** — 159509 AST chars |
| `decode_donor_pattern.py` | 45187 | 1018 | **PASS** | **PASS** — 126510 AST chars |
| `decode_donor_masks.py` | 28207 | 623 | **PASS** | **PASS** — 95390 AST chars |
| `build_terrain_new_atlas.py` | 44759 | 1010 | **PASS** | **PASS** — 127129 AST chars |
| `terrain_qa_harness.py` | 61675 | 1197 | **PASS** | **PASS** — 183347 AST chars |

**Exact errors:** none. No file emitted `SyntaxError`, `IndentationError`,
`TabError`, `UnicodeDecodeError`, or any other exception under either instrument.

## 5. GDScript files — per-file results (all PASS)

Bracket columns are `open-close` for curly `{}`, square `[]` and round `()`
**after strings and comments were stripped**. `depthEnd=0` means no bracket was
left open at EOF. `finalState=normal` means no string or comment was left open
at EOF. `issues` covers mixed tab/space indentation, irregular indent
characters, dedent-to-unknown-level, indent-not-nested and negative depth.

| File | Lines | curly | square | round | depthEnd | funcs | duplicate funcs | indent issues | finalState | Verdict |
|---|---|---|---|---|---|---|---|---|---|---|
| `scripts/terrain_donor_data.gd` | 733 | 37-37 | 117-117 | 302-302 | 0 | 31 | 0 | 0 | normal | **PASS** |
| `scripts/terrain_donor_gen.gd` | 2195 | 51-51 | 304-304 | 1072-1072 | 0 | 71 | 0 | 0 | normal | **PASS** |
| `scripts/terrain_donor_mesh.gd` | 831 | 29-29 | 82-82 | 332-332 | 0 | 29 | 0 | 0 | normal | **PASS** |
| `scripts/terrain_donor_props.gd` | 1022 | 49-49 | 171-171 | 548-548 | 0 | 34 | 0 | 0 | normal | **PASS** |
| `scripts/terrain_donor_world.gd` | 356 | 27-27 | 16-16 | 122-122 | 0 | 14 | 0 | 0 | normal | **PASS** |
| `tests/t_terrain_donor.gd` | 932 | 40-40 | 159-159 | 534-534 | 0 | 28 | 0 | 0 | normal | **PASS** |

**Exact errors:** none. No unbalanced bracket of any kind, no unterminated
string/comment, no duplicate `func` name, no indentation inconsistency.

Note on what this check is and is not: the duplicate scan is **within each
file**, on raw `func` declarations; it does not resolve GDScript's global
`class_name` cache, type inference, overload rules, `@` annotations, or any
semantic/type error. Those are Godot-parse concerns (§8).

## 6. Shader — per-file result (PASS)

`variant3d/shaders/terrain_donor_shader.gdshader`, 307 lines, SHA-256 prefix
`BB31B1EB`.

| Check | Observed | Verdict |
|---|---|---|
| Braces after `//` and `/* */` comment stripping | 6 open / 6 close, `depthEnd=0`, `minDepth=0` | **PASS** |
| String state at EOF | `normal` (no unterminated quote/comment) | **PASS** |
| `shader_type` | exactly 1 line, `shader_type spatial;` (`L1`) | **PASS** |
| `render_mode` | exactly 1 line, `render_mode blend_mix, unshaded, cull_disabled;` (`L50`), matches `render_mode <token>{,<token>};` | **PASS** |
| `uniform` declarations | 24 lines, all match `uniform <type> <name> [:<qualifiers>] [= <init>];` | **PASS** |
| Bad `uniform` / bad `render_mode` lines | 0 / 0 | **PASS** |
| Function bodies detected | `L199 void vertex()`, `L234 vec3 tile_rgb(...)`, `L251 vec2 alpha_patch_uv(...)`, `L266 void fragment()` | **PASS** (all inside the 6 balanced brace pairs) |

Uniform detail: 4 `sampler2D` (`tile_atlas`, `alpha_atlas`, `alphavert_atlas`,
`hmapTex`), 2 `vec2`, 4 `vec4`, 1 `mat4`, 12 `float`, 1 `int`, 3 `vec3` — 24
total, consistent with the scanner count. **Exact errors: none.**

This is a **basic structural parse only**. It does not compile GLSL, does not
validate Godot shader hint tokens against the engine's accepted enum, does not
resolve `uniform` names against `terrain_donor_mesh.gd`, and does not check
varying declarations across vertex/fragment stages. Those remain `[U]` for
COORD's Godot parse.

## 7. Snapshot, drift and hashes

SHA-256 prefixes were taken at the final verification pass. All reads were of
the current bytes; no file was restored to a prior state.

| File | Final SHA-256 (8 hex) | Note |
|---|---|---|
| `terrain_donor_data.gd` | `77D7BFA1` | identical to V65 §2 |
| `terrain_donor_gen.gd` | `2BB553C0` | **actively drifting** during V90 (see below) |
| `terrain_donor_mesh.gd` | `6AB8453A` | identical to V65 §2 |
| `terrain_donor_props.gd` | `C990F604` | identical to V65 §2 |
| `terrain_donor_world.gd` | `C98F34FE` | identical to V65 §2 |
| `t_terrain_donor.gd` | `3BF7E5FB` | identical to V65 §2 |
| `terrain_donor_shader.gdshader` | `BB31B1EB` | unchanged across all V90 passes |
| `decode_donor_cfg.py` | `ABBF0571` | unchanged across all V90 passes |
| `decode_pattern_lib.py` | `DDFB8688` | unchanged across all V90 passes |
| `decode_donor_pattern.py` | `00C0591A` | unchanged across all V90 passes |
| `decode_donor_masks.py` | `667B71FB` | unchanged across all V90 passes |
| `build_terrain_new_atlas.py` | `3A92D053` | unchanged across all V90 passes |
| `terrain_qa_harness.py` | `5A3B9E77` | unchanged across all V90 passes |

**[O] `terrain_donor_gen.gd` changed underneath this worker.** Observed sequence:
V65 recorded `0F6DB181`; V90's first line-count reading was 2187 lines; the
continuation-aware pass read 2194 lines with hash `C19088D0`; the next reading
was 2195 lines with `C19088D0`; the final re-run read 2195 lines with hash
`2BB553C0`; an extra dedicated pass re-verified `2BB553C0` as PASS. Every
observed version passed the same checks with the **same bracket totals
(curly 51-51, square 304-304, round 1072-1072) and 0 dups / 0 issues**, so the
drift did not invalidate the verdict. File `LastWriteTime` at observation was
2026-11-26 10:16:33 AM. **The seal is against the final bytes read (hash
`2BB553C0`); a later write by another worker would need re-sealing.** This is
recorded as an observation, not a complaint — V65 §1 already flagged this file
as drifting.

## 8. What V90 did NOT verify — open for COORD

1. **[U] No Godot parse / runner job / gate / capture was run.** Per the brief and
   CHARTER.md:80-82, this is COORD's next step. In particular, the
   `class_name C3TerrainData` global-cache question raised in V65 §6 (test
   `t_terrain_donor.gd:340` casting to it) is **not settled** by a static scan.
2. **[U] No GDScript semantic/type check.** Duplicate-name and bracket/indent
   balance do not catch type errors, unresolved identifiers, bad `@` annotations,
   wrong method arity, or shader uniform/varying mismatches.
3. **[U] No Python import/execution and no runtime behaviour of any decoder,
   harness or terrain script was tested.** `ast.parse` proves only that the file
   is syntactically well-formed for CPython 3.14.3.
4. **[U] Shader GLSL validation and Godot shader-hint validation were not run.**
   Only braces and statement syntax were checked.
5. **[D] The two requested context reports V55 and V83 are absent** (§1). V90 did
   not substitute or infer their contents.
6. **[U] PARITY:** no matched-seed donor GPU A/B frame exists. **No donor visual
   parity claim**; parity remains UNVERIFIED / PORT APPROXIMATION
   (CHARTER.md:43-44,125). A clean static seal says nothing about visual fidelity.

## 9. Invariants held by V90

- Read-only: no source, shader, asset, test, config, manifest, backup, queue or
  `app/` byte was created, modified or deleted; no git mutation.
- No Godot, no `godot_runner.py`, no donor binary, no donor file access, no
  network call, no gate and no capture.
- `-B` + temp `PYTHONPYCACHEPREFIX`: no `.pyc` written into the repo.
- Exactly one file written: this report.
- Multiple passes on every anomaly (§3); all failures were in V90's own
  instruments or in the brief's missing references, never silently skipped.
- No parity claim; all runtime/parity matters left `[U]` for COORD.

## 10. Handoff summary (5 lines)

1. **Verdict:** 13/13 implementation files are **STATIC PASS** — 6/6 Python
   (`ast.parse` + `compile(PyCF_ONLY_AST)`), 6/6 GDScript (balanced brackets,
   continuation-aware indent, 0 duplicate `func` names), 1/1 shader (balanced
   braces, valid `shader_type`/`render_mode`/24 uniforms).
2. **Errors:** **zero** under every instrument. The only flags raised were two
   false-positive classes in V90's own first-pass analyzers (§3 P3/P5), both
   diagnosed by source inspection and corrected before acceptance.
3. **Unresolved context:** `reports/V55_python_preflight.md` and
   `reports/V83_final_forbidden_scan.md` **do not exist** in this workspace;
   V65 was found under `docs/terrain_swarm_2026-11-26/reports/`, not the path in
   the brief. Nothing was invented for the absent reports.
4. **Drift:** `terrain_donor_gen.gd` was written concurrently during V90
   (`0F6DB181` → `C19088D0` → `2BB553C0`, 2187 → 2195 lines); every observed
   version passed with identical bracket totals. Seal is against hash `2BB553C0`.
5. **Guards:** read-only, multi-pass, no Godot/runner/gate/capture/donor access,
   no git mutation, one report written. **Godot parse smoke is COORD's next
   step; NO DONOR PARITY CLAIM — parity UNVERIFIED / PORT APPROXIMATION.**

*End of V90 report. Exactly one report written; no other file was created, edited or deleted.*
