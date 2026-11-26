---
id: V37
ticket: "TERRAIN-SWARM-2026-11-26 / V37 — three integration-blocking minor conflicts (read-only)"
agent: "V37 (read-only verification subagent, DONOR-FIRST terrain swarm 2026-11-26)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_SOURCE_EDIT__NO_GIT_MUTATION__NO_RUNNER__NO_GODOT__NO_DONOR_EXECUTION
owner_file: docs/terrain_swarm_2026-11-26/reports/V37_minor_conflicts.md
files_created: [docs/terrain_swarm_2026-11-26/reports/V37_minor_conflicts.md]
files_edited: []
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION"]
parity_guard: "No donor binary executed, no donor GPU frame, no Godot job, no gate and no capture were used. Every port consequence is PORT APPROXIMATION. No donor visual parity is claimed (CHARTER.md:43-44,125)."
scope_guard: "Read-only: donor files opened read-only via Python bytes / PowerShell Get-Content; repo read via file reads, grep and git status --short. Two small throwaway verification scripts were written ONLY to C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\ (outside the repo). No repo file except this report was written."
multiple_passes: true
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
donor_root: "C:\\Games\\Cossacks 3"
---

# V37 — three minor, integration-blocking conflicts: paste-ready decisions

## Executive summary

1. **[O]/[D] `globalparams.cfg` has exactly 19 active flat keys, not 20.** Two fresh V37 instrument passes (Python latin-1 parse; PowerShell regex + `ReadAllLines`) both return 19, as do X20's four passes (`X20_cfg_decoder_prototype.md:104,204-214`) and F03's own 19-row dump and table (`F03_gen_config.md:66-89,438-457`). `:2-20` inclusive is 19 lines; `:21` is `section.end`, `:22` is empty. **The F03 executive-summary "20" (`F03:36`; also `:48,:459,:801,:878`) is an error. No 20th key exists or may be invented.** I01 already expects 19 (`decode_donor_cfg.py:399-409`); its `--check` must pass 19/19 count checks with one non-fatal documented exception `MP-1`.

2. **[O]/[D] Shader conflict — choose (b): require a COORD canonical rename to `variant3d/shaders/terrain_donor_shader.gdshader`.** I10 landed `variant3d/shaders/terrain_donor.gdshader` (`terrain_donor.gdshader:5`), but the canonical path is already named by V11 N13/CR5/Q3 (`V11_ownership_ledger.md:25,105,145,208,247`), `spec/12 §12.2:44`, `IMPLEMENTATION_PLAN.md:18` and V16-18 (`V16_contradiction_register.md:76`). The live composer `variant3d/scripts/terrain_donor_world.gd:35` binds the canonical path **first** and the alias second (`:36`, loop `:151`), so the rename is runtime-safe; three other live consumers also name the canonical path (`terrain_donor_mesh.gd:67,562`; `terrain_qa_harness.py:187`; `t_terrain_donor.gd:43`, the last with a wrong `res://scripts/` directory that must be fixed). Renaming one file is strictly less churn than rewriting the authoritative ledger, spec, plan and consumers.

3. **[O]/[D] Relief grid authority = F01's corrected offset `G = 8 + (w-1)*(h-1)`**, not X13's old-offset `G=1000/1912/2866`. V37 re-read the donor bytes at both offsets: X13's published cell bits reproduce **only** at the shifted old offsets (`hil1 (0,0)=0x3B605C14`, `k_ravine_1 (1,0)=0xBAAC7432/(0,1)=0xBA9D9F10`, `g_hil4 (28,4)=0x3FF55FDC`); at the corrected offsets they differ. Min/max still match at both windows because the extrema lie in the overlap — that coincidence is why X13's bit-exact min/max check did not catch the shift. **X23 is not landed at this read** (no `reports/X23*` file); no X23 values are invented.

> [!IMPORTANT]
> Labels: **[O]** literal read, **[D]** deterministic consequence of [O], **[I]** inference, **[U]** UNVERIFIED, **PORT APPROXIMATION** for port-authored substitutes. Paste-ready blocks below are text for COORD to apply; V37 applied none of them. No gate result and no parity verdict are implied.

---

## §0 Multiple-pass log (CHARTER.md:85-93)

| Pass | Instrument | Conflict | Result | Effect |
|---|---|---|---|---|
| P1 | Python 3 `pathlib.read_bytes()` latin-1 split of `C:\Games\Cossacks 3\data\gen\globalparams.cfg` | #1 | 537 B, 22 CRLF, **19** active `Key = value` lines enumerated `:2-20` | Confirms X20, not F03 headline |
| P2 | PowerShell `[IO.File]::ReadAllText/ReadAllLines` + `[regex]::Matches('(?m)^[ \t]*([A-Za-z_]\w*)[ \t]*=')` | #1 | `regex_active_kv=19`, `physical_lines=22`, `kv_lines=19`, `line21=section.end`, `line22=[]` | Independent instrument agrees; no single-pass acceptance |
| P3 | Cross-read `X20_cfg_decoder_prototype.md:104,204-214` (4 passes) and `F03_gen_config.md:66-89,438-457` (19 rows) | #1 | X20 = 19; F03 dump/table = 19 rows; only F03 headline/F1/summary say 20 | Marks summary as error; no invented key |
| P4 | `grep` over whole repo for `terrain_donor_shader\|terrain_donor.gdshader` (15 hits) + `Test-Path`-equivalent glob of `variant3d/shaders/terrain_donor*` | #2 | Only landed shader is `terrain_donor.gdshader`; canonical filename absent; 3 consumers + composer name canonical | Favours rename over doc rewrite |
| P5 | Read `terrain_donor_world.gd:13,35-36,151` (composer) and `terrain_donor_mesh.gd:67,562`, `t_terrain_donor.gd:43`, `terrain_qa_harness.py:187` | #2 | Composer primary = canonical, alias = labelled fallback; consumers canonical; test path has wrong directory | Rename is runtime-safe; one test path fix required |
| P6 | Python `struct.unpack_from('<2i')` + `G` decode of 3 donor `.pattern` files at old and F01 offsets (script `v37_pattern_check.py`) | #3 | Same min/max at both windows; headers `hil1 25×41 N=960`, `g_hil4 33×59 N=1856`, `k_ravine_1 46×63 N=2790` | Min/max is not a discriminator; need P7 |
| P7 | Python f32-bit + SHA-256 discriminator over the same two windows (`v37_pattern_discriminator.py`) | #3 | X13's published bits match **OLD** windows exactly; corrected-window bits and grid SHAs differ for all 3 files | F01 corrected offsets accepted as authoritative for grid addressing |
| P8 | `glob docs/terrain_swarm_2026-11-26/reports/X23*` | #3 | No files found — X23 not landed | No X23 value quoted or invented |

**[O] No anomaly was accepted after a single reading.** Remaining unknowns are in §5.

---

## §1 Evidence table

| ID | Source (donor path:line / repo file:line / command) | Observation | Label | Consequence |
|---|---|---|---|---|
| E1 | `C:\Games\Cossacks 3\data\gen\globalparams.cfg:1-22` (P1/P2) | 537 B, 22 CRLF; keys at `:2-20`; `:21 section.end`; `:22 empty` | [O] | 19 keys is the byte truth |
| E2 | P1 enumerated key list | `Size, Sharpness, TileChangeFactor, FrequencyFactor, CellsResolution, FailStandCount, DefaultMapSize, TileSmoothPasses, TileSmoothListFileName, CastlesFileName, PatternPlayerName, PatternPlayerRace, CastlePlayerName, CastlePlayerRace, CastlePatternsPlayerName, CastlePatternsPlayerRace, AddCastles, CastlePlateauFactor, CastleType` | [O] | Exactly 19 names; no 20th slot |
| E3 | `F03_gen_config.md:36,48,459,801,878` | "20 flat generation knobs" / "20 flat keys" / F1 "20 keys" / summary "20 global knobs" | [O] | F03 summary-level error; §3.1/§4 are self-contradictory at 19 rows |
| E4 | `F03_gen_config.md:459` | Claim "3 non-empty strings" but file has 2 (`:10,:12`), 10 numeric/bool (`:2-9,:18,:19`), 7 empty (`:11,:13-17,:20`) = 19 | [D] | Even F03's own breakdown arithmetic is stale; confirmed by X20 MP-1 |
| E5 | `X20_cfg_decoder_prototype.md:104,204-214` | Structural / regex / byte / verbatim / F03-cross-check passes all give 19; "no 20th key was guessed" | [O]/[D] | Prior verdict corroborated by two fresh V37 instruments |
| E6 | `variant3d/tools/decode_donor_cfg.py:399-409`, `:404` | `add("C01", ..., 19, ...)` with documented exception MP-1 | [O] | I01 is already correct; do not raise expectation to 20 |
| E7 | `decode_donor_cfg.py:53` | `"structure": "1 section, 20 flat keys (:1-21)"` | [O] | Stale label still emitted into `manifest.json::source_hashes`; one-line fix needed |
| E8 | `decode_donor_cfg.py:404-499`, `:781-785`, `:810-812` | 19 count checks (`C01`–`C19`); `rc=1` only if hashes/counts/determinism fail; documented exceptions are printed, not fatal | [D] | Correct `--check` expectation is exit 0 with `19/19` and an `MP-1` NOTE |
| E9 | `spec/09_EDITOR_PARAMETERS.md:11` | `1 section, 20 flat keys` | [O] | Load-bearing spec sentence to replace |
| E10 | `spec/00_EVIDENCE_INDEX.md:52`, `V17_spec_readiness.md:57`, `X09_starting_settings.md:67` | "20 global keys" repeated; V17 marks §09 READY on that premise | [O] | Secondary stale references for COORD |
| E11 | `variant3d/shaders/terrain_donor.gdshader:1-5` | Landed I10 file is the **only** shader on disk; header self-declares `terrain_donor.gdshader` | [O] | I10 path exists; canonical path does not |
| E12 | `V11_ownership_ledger.md:25,105,145,208,247`; `spec/12_QA_AND_INTEGRATION.md:44`; `IMPLEMENTATION_PLAN.md:18`; `V16_contradiction_register.md:76` | Canonical = `terrain_donor_shader.gdshader`; A06 N7 alias retired (CR5) | [O]/[D] | Authoritative docs already agree; renaming preserves them |
| E13 | `variant3d/scripts/terrain_donor_world.gd:13,35-36,146-175` | Composer binds `DONOR_SHADER_PATH` (canonical) first, `DONOR_SHADER_ALIAS` (alias) second; loop tries both; labelled fallback if neither exists | [O] | Rename is runtime-safe; alias becomes inert but harmless |
| E14 | `variant3d/scripts/terrain_donor_mesh.gd:67,509-529,562`; `variant3d/tools/terrain_qa_harness.py:187`; `variant3d/tests/t_terrain_donor.gd:43` | Mesh and QA tool name canonical path; test names canonical basename but under `res://scripts/` instead of `res://shaders/` | [O] | One test path correction required after rename |
| E15 | `A06_integration.md:149` | A06 N7 historical row names `terrain_donor.gdshader` | [O] | Historical claim, already retired by V11 CR5; no rewrite strictly required |
| E16 | `F01_pattern_format.md:21,43-56,79-82,92-93,326-395,448-462` | `G = 8 + (w-1)*(h-1)`; 710/710 closure; 678/680 bit-exact min/max; 17/29 DPATTERN offsets shifted; corrected 8×10 tables; `hil1 G=968`, `k_ravine_1 G=2798`, `k_ravine_big_stone_1 G=8225` | [O]/[D] | F01 is authoritative for grid byte address |
| E17 | P6/P7 donor re-read: `hil1.pattern` (old 1000 vs F01 968), `g_hil4.pattern` (1912 vs 1864), `k_ravine_1.pattern` (2866 vs 2798) | Old windows: X13 bits `3B605C14 / 40771F94 / 000000DB`, `3FF55FDC`, `BAAC7432 / BA9D9F10 / C03DAC13`. F01 windows: `00000000 / 3E8F5C29 / 00000000`, `3D53C32A`, `00000000 / 00000000 / B1A736BB`; grid SHA-256 prefixes differ for all three | [O]/[D] | X13 vectors are shifted-window data; not grid-address authority |
| E18 | `X13_blend_test_vectors.md:24-25,59-61,82-84,167-177,242-244` | X13 explicitly accepts `G=1000/1912/2866` from F02/X05; min/max bit-exact 3/3; branch formulas from D05 F4 accepted separately | [O] | Keep X13's **formula** verdict; retire its **offset** verdict |
| E19 | `spec/04_PATTERN_STAMPING.md:22-25,53-62,69-90` | Spec still says "at the verified offsets" without a formula; §6 contains the D05 formula (X13 confirms it) | [O] | Precise §04 replacement sentence supplied in §4 below |
| E20 | `variant3d/tools/decode_donor_pattern.py:26,349` | I02 production tool already uses `G=8+(w-1)*(h-1)` [F01 §4.4] | [O] | I02 needs no offset change; only spec text lags |
| E21 | P8 `glob reports/X23*` — no files | X23 report not landed at this read | [O] | No X23 values available; do not attribute any to X23 |
| E22 | `git status --short` (V37 read) | `main.gd`/`world3d.gd` modified, many untracked reports/tools/shaders including `terrain_donor.gdshader`; no canonical shader file | [O] | Rename must be COORD's single file-scoped operation; no blanket restore |

---

## §2 Decision 1 — flat-key count: 19, F03 summary is an error

### Verdict [O]/[D]

The authoritative count is **19** active flat keys in `C:\Games\Cossacks 3\data\gen\globalparams.cfg` (`:2-20` inclusive). File is 537 B / 22 CRLF lines, SHA-256 prefix `15a8dc64…` (matches `F03:48` and `X20:86`). `:21` is `section.end`; `:22` is empty. Two fresh instruments and X20's four passes agree. **The "20" in F03's executive summary (`:36`), inventory row (`:48`), breakdown (`:459`), finding F1 (`:801`) and hand-off (`:878`) is an error** — not a recoverable key. Mark it as such; never invent a 20th key (CHARTER.md:83-84).

### Paste-ready replacement for `spec/09_EDITOR_PARAMETERS.md`

Replace line 11 (table row) with exactly:

```
| `data/gen/globalparams.cfg` | 537 | 22 | 15a8dc64… | 1 section, **19 flat keys** (`globalparams.cfg:2-20`; `:21` = `section.end`, `:22` empty) |
```

Add this sentence at the end of `spec/09 §1` (after the "All CRLF" paragraph at lines 19-20):

```
[O] `globalparams.cfg` has exactly 19 active flat keys (`globalparams.cfg:2-20` inclusive); the "20" in `reports/F03_gen_config.md:36,48,459,801,878` is a summary-level error, not a missing key — confirmed by two independent V37 re-reads and X20's four passes (`reports/X20_cfg_decoder_prototype.md:104,204-214`), and no 20th key may be invented.
```

### Paste-ready `--check` expectation for I01

`decode_donor_cfg.py:404` already expects 19. The only code text to fix is the stale label at `:53`:

```python
        "structure": "1 section, 19 flat keys (:2-20)",
```

Command and expected result (paste-ready; V37 did **not** run it):

```powershell
python variant3d\tools\decode_donor_cfg.py --game "C:\Games\Cossacks 3" --check
```

```
check: hashes PASS counts PASS determinism PASS
summary: 7/7 hashes, 19/19 count checks
NOTE MP-1 globalparams.cfg active key=value lines (source data\gen\globalparams.cfg:2-20; ... F03 summary 20 vs observed 19 ... no 20th key invented)
exit code 0
```

`C01` must show `expected=19`, `pass1_structural=19`, `pass2_regex=19`, `pass3_bytes=19`, `result=PASS`. The `MP-1` line is a **non-fatal documented exception** (`decode_donor_cfg.py:643-666,802-804`); exit 1 is reserved for a real hash/count/determinism failure (` :781-785`). Do **not** change C01 to 20 to match F03, and do not let the NOTE be treated as a FAIL.

---

## §3 Decision 2 — shader path: choose (b), COORD canonical rename

### Verdict [D]

**Require the canonical rename by COORD**; do not rewrite the authoritative ledger/spec/plan to accept I10's alias.

Grounds: (1) the canonical name is already fixed by V11 CR5/N13, `spec/12 §12.2`, PLAN I10 and V16-18 (E12); (2) the I11 composer `variant3d/scripts/terrain_donor_world.gd:35` tries the canonical path **first** and only then the alias (`:36,151`), so renaming cannot break binding; (3) the mesh (`:67,562`) and QA rollback (`:187`) already name the canonical path; (4) renaming one landed file plus one stale header line is a smaller, auditable change than editing five authoritative documents plus three consumers.

Paste-ready COORD operation (file-scoped; V37 does not execute it):

```powershell
Rename-Item -LiteralPath 'variant3d\shaders\terrain_donor.gdshader' -NewName 'terrain_donor_shader.gdshader'
```

Verify afterwards: `Test-Path -LiteralPath 'variant3d\shaders\terrain_donor_shader.gdshader'` → `True`; alias path → `False` (composer's alias loop stays inert, labelled A06 N7).

### Exact one-line change for every file that mentions the path

| File:line | Current text | One-line change |
|---|---|---|
| `variant3d/shaders/terrain_donor.gdshader:5` (after rename: `terrain_donor_shader.gdshader:5`) | `// Owner file (ONLY repo file written by I10): variant3d/shaders/terrain_donor.gdshader` | `// Owner file (ONLY repo file written by I10): variant3d/shaders/terrain_donor_shader.gdshader` |
| `variant3d/tests/t_terrain_donor.gd:43` | `const MODULE_SHADER := "res://scripts/terrain_donor_shader.gdshader"  # I10 (V11 N13)` | `const MODULE_SHADER := "res://shaders/terrain_donor_shader.gdshader"  # I10 (V11 N13)` (fix `scripts`→`shaders`) |
| `docs/terrain_swarm_2026-11-26/reports/V11_ownership_ledger.md:25,105,145,208,247` | already canonical `terrain_donor_shader.gdshader` | **No change** — authoritative; `:59` retains the historical A06 alias claim as evidence |
| `docs/terrain_swarm_2026-11-26/spec/12_QA_AND_INTEGRATION.md:44` | already canonical | **No change** |
| `docs/terrain_swarm_2026-11-26/IMPLEMENTATION_PLAN.md:18` | already canonical (notes `variant3d/scripts/terrain_donor_shader.gdshader`) | **No change to the basename**; optional directory correction to `variant3d/shaders/terrain_donor_shader.gdshader` — see Open question Q2 |
| `docs/terrain_swarm_2026-11-26/reports/V16_contradiction_register.md:76` | already canonical (V16-18) | **No change** |
| `docs/terrain_swarm_2026-11-26/reports/A06_integration.md:149` | A06 N7 `variant3d/shaders/terrain_donor.gdshader` | **No change** — historical claim, already retired by V11 CR5; optional suffix `(RETIRED — V11 CR5; canonical terrain_donor_shader.gdshader)` if COORD wants zero ambiguity |
| `variant3d/scripts/terrain_donor_world.gd:13,35-36` | canonical primary + labelled alias fallback | **No change** — alias is explicitly labelled and harmless after rename; optional retirement is Q3 |
| `variant3d/scripts/terrain_donor_mesh.gd:67,562`; `variant3d/tools/terrain_qa_harness.py:187` | already canonical | **No change** |

**No doc edit is required for the rename itself** — that is the point of choosing (b). If COORD instead chooses (a), the mandatory doc rewrites would be V11 `:25,105,145,208,247`, `spec/12:44`, `IMPLEMENTATION_PLAN:18`, `V16:76`, plus composer `:35-36`, mesh `:67,562`, QA `:187` and I12 test `:43` — 10+ edits, all against an already-authoritative ledger. V37 recommends (b).

---

## §4 Decision 3 — relief grids: F01 corrected offsets are authoritative

### Verdict [O]/[D]

**Authoritative byte address:** `G = 8 + N`, `N = (w-1)*(h-1)`, with `filesize = 8 + 4*w*h + 54*N` (710/710 closure; `F01_pattern_format.md:21,43-56,79-82,448-462`). Specifically `hil1 G=968`, `g_hil4 G=1864`, `k_ravine_1 G=2798`, `k_ravine_big_stone_1 G=8225` (already correct). I02's production tool already implements this (`decode_donor_pattern.py:26,349`).

**Superseded for grid addressing:** X13's `G=1000/1912/2866` (`X13_blend_test_vectors.md:24-25,59-61,243-244`), inherited from F02/X05/DPATTERN shifted windows. V37's bit discriminator (P7, §1 E17) reproduces X13's published cell bits **only** at the old offsets; corrected windows give different bits and different grid SHA-256 prefixes for all three files. The min/max agreement at both windows (`P6`) is a coincidence of overlapping extrema and is not evidence for the old address.

**Still authoritative from X13:** the D05 F4 blend formula (`X13:103-116,204-208`) and its warning that the task/spec §6 `Replace` literal is incomplete. Retire X13's *offset* claim only; do not discard its *formula* verdict. **X23 has not landed** (P8), so no X23 value is quoted, presumed or invented.

### Paste-ready replacement sentence for `spec/04_PATTERN_STAMPING.md`

Replace the first bullet of §4 (currently `spec/04_PATTERN_STAMPING.md:55-57`) with exactly this one sentence:

```
- `decode_donor_pattern.py` (I02) must decode the `.pattern` float grid at the **corrected byte offset `G = 8 + (w-1)*(h-1)`** (`filesize = 8 + 4*w*h + 54*(w-1)*(h-1)`, 710/710 closure, F01 §4.1–§4.2 / E4 / E8–E11) and the object tail; X13's `G=1000/1912/2866` bit vectors come from shifted DPATTERN windows and are **superseded for grid addressing**, their bit-exact `HeightFieldMin/Max` agreement being a coincidence of overlapping extrema only.
```

Optional companion (not required by this decision, offered for consistency with §1): replace `spec/04 §1` bullet at `:22-25` with:

```
- 12 float-grid cross-checks against `.pattern` bytes at the **corrected** `G = 8 + (w-1)*(h-1)` reproduce `pattern.lib` `HeightFieldMin/Max` bit-exactly for 678/680 sections (F01 E11); the older F02/X05/DPATTERN `G` values are shifted windows and must not be used as stamp offsets.
```

---

## §5 Affected files and tickets

| Area | Files / tickets | Action owner | Action |
|---|---|---|---|
| Count | `spec/09_EDITOR_PARAMETERS.md:11` (+ sentence after `:20`); `spec/00_EVIDENCE_INDEX.md:52`; `reports/F03_gen_config.md:36,48,459,801,878`; `reports/V17_spec_readiness.md:57`; `reports/X09_starting_settings.md:67` | COORD | Apply §2 replacements; mark F03 summary "20" an error; revisit §09 READY verdict |
| Count | `variant3d/tools/decode_donor_cfg.py:53` | COORD / I01 | Change stale `structure` label to 19; keep C01=19 (`:404`); `--check` must stay 19/19, exit 0 |
| Shader | `variant3d/shaders/terrain_donor.gdshader`, `variant3d/shaders/terrain_donor_shader.gdshader`, `variant3d/tests/t_terrain_donor.gd:43` | COORD / I10 / I12 | File-scoped rename + header line + test path fix |
| Shader | `V11_ownership_ledger.md`, `spec/12:44`, `IMPLEMENTATION_PLAN.md:18`, `V16:76`, `A06:149`, composer `:35-36`, mesh `:67,562`, QA `:187` | COORD | No change under decision (b); optional directory/A06 suffix clean-up only |
| Grids | `spec/04_PATTERN_STAMPING.md:55-57` (optional `:22-25`) | COORD | Apply §4 replacement sentence |
| Grids | `reports/X13_blend_test_vectors.md:24-25,59-61,243-244`; `reports/F01_pattern_format.md:50,79-82,326-395` | COORD / I02 | Relabel X13 offset as superseded; keep D05 F4 formula authoritative; I02 already correct |
| Register | `SWARM_BOARD.md` contradiction register; `V16_contradiction_register.md`; `V21_gate_register.md` | COORD | Log these three closures/verdicts; no worker edits these files |

---

## §6 Risks

| # | Risk | Label | Mitigation |
|---|---|---|---|
| R1 | Someone "fixes" the missing 20th key to match F03's summary | [D] HIGH | Donor bytes have 19 named keys; inventing one violates CHARTER.md:83-84; keep MP-1 as documented exception |
| R2 | I01's stale `structure` string at `:53` keeps emitting "20 flat keys" in `manifest.json` after C01 passes | [O] MEDIUM | Apply the one-line label fix; verify emitted manifest text, not only counts |
| R3 | `--check` is expected to fail because X20's prototype exited 1 | [D] MEDIUM | X20's exit 1 was the *prototype's* mismatch; I01's production code expects 19 and should exit 0 (`:781-785`) |
| R4 | Composer's alias fallback hides a missing canonical shader after rename | [D] MEDIUM | Verify with `Test-Path` that canonical exists and alias does not; composer telemetry `shader_path` must report canonical (`terrain_donor_world.gd:317`) |
| R5 | I12's `MODULE_SHADER` under `res://scripts/` silently reports "absent" even after rename | [O] MEDIUM | Apply the `:43` path fix; re-read `t_terrain_donor.gd` telemetry |
| R6 | X13's bit vectors are reused as grid-address authority because their min/max match | [D] HIGH | Use F01 `G=8+(w-1)*(h-1)`; the P7 discriminator shows cell bits and grid SHAs differ |
| R7 | X23 lands later with different values and invalidates §4 | [U] MEDIUM | §4 is explicitly F01-based; COORD must re-adjudicate if/when `reports/X23*` lands |
| R8 | Doc line numbers drift as COORD lands other integrations | [U] MEDIUM | Re-read each cited line immediately before applying any paste-ready text |
| R9 | Any visual improvement from the shader rename is mistaken for donor parity | [U]/PORT APPROX HIGH | No donor GPU A/B frame exists; `visual_parity_claim` stays false (CHARTER.md:43-44,125) |

---

## §7 Open questions for COORD

1. **Q1.** Approve marking `reports/F03_gen_config.md:36,48,459,801,878` as an error (19, not 20) and revising `V17_spec_readiness.md:57` §09 READY rationale accordingly?
2. **Q2.** Confirm decision (b) rename by COORD, and whether `IMPLEMENTATION_PLAN.md:18`'s directory (`variant3d/scripts/terrain_donor_shader.gdshader`) should also be corrected to `variant3d/shaders/...` (basename already canonical).
3. **Q3.** After rename, keep `terrain_donor_world.gd:36` `DONOR_SHADER_ALIAS` as a labelled inert fallback, or retire the constant and the alias branch at `:151` in a separate COORD commit?
4. **Q4.** Should `A06_integration.md:149` receive an explicit `(RETIRED — V11 CR5)` suffix, or stay untouched as a historical claim?
5. **Q5.** Adopt the optional `spec/04 §1` companion sentence (§4 above) as well as the mandatory §4 bullet replacement?
6. **Q6.** If/when X23 lands, who re-adjudicates F01-vs-X13 grid offsets (F01/COORD) and updates X13's vectors?
7. **Q7.** Should I01's `MP-1` NOTE be suppressed once F03/spec are corrected, or retained permanently as provenance that the discrepancy existed?

---

## §8 Five-line hand-off summary

1. **[O]/[D] 19, not 20:** two fresh re-reads (Python + PowerShell regex/`ReadAllLines`) plus X20's four passes and F03's own 19-row dump/table confirm 19 flat keys at `globalparams.cfg:2-20`; F03's summary "20" is an error; no key invented.
2. **Paste-ready:** replace `spec/09:11` with the 19-key row and add the error-marking sentence; change `decode_donor_cfg.py:53` label to 19; expect `--check` exit 0 with `7/7` hashes, `19/19` count checks and a non-fatal `MP-1` NOTE.
3. **Shader decision (b):** COORD renames I10's landed `variant3d/shaders/terrain_donor.gdshader` to canonical `terrain_donor_shader.gdshader`; composer binds canonical first, so no doc rewrite is needed; only the shader header line and `t_terrain_donor.gd:43` (`scripts`→`shaders`) change.
4. **Grid decision:** F01's corrected `G = 8 + (w-1)*(h-1)` is authoritative (X13's `1000/1912/2866` bits reproduce only at shifted windows); §4 supplies the exact `spec/04` replacement sentence; X23 not landed, no values invented.
5. **Guards:** 8 multi-pass readings recorded; donor read-only; zero repo edits except this report, zero Godot jobs, zero gates; all port consequences are `PORT APPROXIMATION` — **no donor parity claim**, parity stays UNVERIFIED.

*End of V37 report. Exactly one repo file written; no source, shader, config, asset, test, backup, git, queue, runner, Godot or `app/` state changed.*
