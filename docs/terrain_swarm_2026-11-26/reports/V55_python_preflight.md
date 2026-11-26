---
id: V55
swarm: TERRAIN-SWARM-2026-11-26
title: "V55 — Python-only PREFLIGHT self-checks of the six terrain_new tools (exact exit codes and stdout)"
agent: "V55 (verification subagent; one-report-only; Python checks only)"
owner_file: docs/terrain_swarm_2026-11-26/reports/V55_python_preflight.md
status: OBSERVED_RESULTS__NO_GODOT__NO_RUNNER__NO_DONOR_WRITES__NO_GATE_RESULT__NO_PARITY_CLAIM
created: 2026-11-26
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_guard: "PORT APPROXIMATION / port-internal self-check results only. No donor GPU A/B frame exists and none was produced here (CHARTER.md:41,134-135; V21 GR-C08). Every PASS below is a source-internal check, not donor fidelity."
method: "[O] exact command exit code ($LASTEXITCODE), stdout/stderr captured to %TEMP%\\opencode\\v55\\*; [D] deterministic reading of those bytes and cited tool source; [I] attribution/recommendation; [U] unresolved. All Python runs used PYTHONPYCACHEPREFIX=C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\v55\\pycache."
governing_sources:
  - docs/terrain_swarm_2026-11-26/CHARTER.md
  - docs/terrain_swarm_2026-11-26/SWARM_BOARD.md
  - docs/terrain_swarm_2026-11-26/reports/V42_gate_commands.md
  - docs/terrain_swarm_2026-11-26/reports/V53_cli_reconciliation.md
  - variant3d/tools/{decode_donor_cfg.py,decode_pattern_lib.py,decode_donor_pattern.py,decode_donor_masks.py,build_terrain_new_atlas.py,terrain_qa_harness.py}
landing_note: "[O] V53_cli_reconciliation.md was NOT on disk at V55's first read (tool read returned file-not-found); it LANDED during V55's check window and was read afterwards. V53 §0.6/E12 records the same moving-tree symptom V55 hit. V42_gate_commands.md was read in full (391 lines). No V53/V42 content is re-adjudicated here."
---

# V55 — Python-only preflight: exact self-check results

## 0. Executive summary

1. **[O] All six required Python self-checks exit 0 on the final pass.** Observed summaries: cfg `7/7 hashes, 19/19 count checks`; `decode_pattern_lib.py` `CHECK SUMMARY: 50 PASS / 0 FAIL`; `decode_donor_pattern.py` `CHECK SUMMARY: PASS 30 / FAIL 0` with `BYTE CLOSURE: 710/710`; masks `CHECK SUMMARY: 18/18 PASS`; atlas `"mode": "PLAN_CHECK", "passed": true` with 21/21 plan checks true; QA harness `CHECK OK: 36/36 assertions passed` (§3). Two passes were run for every command; no threshold was changed and no tool was repaired by V55.
2. **[O] One first-pass failure occurred and was re-run, not skipped.** `decode_pattern_lib.py --dry-run --check` pass 1 exited **1** with `NameError: name 'build_family_docs' is not defined` (`decode_pattern_lib.py:1060` as executed). The source SHA-256 changed from `5F559FA3…` to `DDFB8688…` mid-window (mtime 2026-11-26T09:02:26Z); pass 2 and the final pass both exit 0 with 50 PASS / 0 FAIL. V53 independently observed the same transient (V53_cli_reconciliation.md:24,42). [I] Concurrent owner edit, **not** a persistent defect; owner **I03**.
3. **[O] The harness has no `--dry-run`.** `terrain_qa_harness.py --check` exits 0 (36/36); the extra probe `--dry-run --check` exits **2** with `terrain_qa_harness.py: error: unrecognized arguments: --dry-run` (argparse surface at `terrain_qa_harness.py:1145-1151`). This is a CLI-contract observation, not a tool failure; corroborated by V53 §2. Owner **COORD/I13 (N16)** for any documentation reconciliation.
4. **[O] `python -m py_compile` on all six tools exits 0**, twice, with `PYTHONPYCACHEPREFIX` redirected to temp (203 `.pyc` files there). No `__pycache__` was created by V55 in the repo; three repo `__pycache__` directories already existed at baseline (§5).
5. **[I] Git status alone cannot prove "no writes": all six tools and `variant3d/assets/terrain_new/` are untracked (`??`), so git collapses their contents.** The scoped `git status --short` lines were byte-identical before/after (7 lines). A stronger byte-level snapshot shows the shared tree **was** mutated during the window by other workers (three tool sources changed; 713 pattern JSONs appeared; mask PNGs written at 09:16Z). All V55 invocations were `--dry-run`/`--check` and every tool printed an explicit no-write line (§5). **No gate result, no donor parity claim.**

## 1. Scope, method and authority

- Read-only except this report. **No Godot process, no `godot_runner.py` subcommand (not even `status`), no `assert_clean`, no capture, no donor write, no source/config/asset edit, no git write.** Only `git status --short` was used (read-only, allowed by task).
- Windows / PowerShell, `python` (3.14.3, `C:\Python314\python.exe`), `;` separators, repo-root-relative quoted paths (`CHARTER.md:94`). `numpy 2.4.3` and `Pillow 12.1.1` were importable, so no dependency failure was encountered.
- `PYTHONPYCACHEPREFIX` was set for every Python invocation, including both `py_compile` runs. Temp artefacts: `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v55\{git_before.txt,git_after.txt,fs_before.txt,fs_after.txt,*_out.txt,*_err.txt,pycache\}`.
- **Multiple passes on anomalies** (`CHARTER.md:85-93`): every command was run twice (initial sweep + final sweep after source hashes stabilised); the one failing command additionally had source re-read and hash-stability check (3 s interval, two equal hashes), then pass 2 and final pass.
- **Moving tree [O]:** initial read of V53 returned file-not-found; a later glob found it and it was read (V53:1-162). V53 §0.6/E12 reports the same transient pattern-lib edit. Tool mtimes at final read: cfg 08:53:16Z, I02 09:02:21Z, I03 09:02:26Z, I04 09:02:24Z, I05 08:54:27Z, harness 08:55:24Z. Final source SHA-256s are in E10. All numbers in §3 are from the **final** pass unless a first pass is explicitly named.

## 2. Evidence table

| # | Label | Source (file:line / read-only command) | Establishes |
|---:|---|---|---|
| E01 | [O] | Tool headers and argparse: `decode_donor_cfg.py:46-103,761,782-859`; `decode_pattern_lib.py:30-37,1028-1061,1064-1123`; `decode_donor_pattern.py:59-67,852-1004`; `decode_donor_masks.py:21-29,574-606`; `build_terrain_new_atlas.py:35-42,860,902-1005`; `terrain_qa_harness.py:17-32,1038,1132,1141-1156` | Every flag used exists; dry-run/check semantics and no-write gating are source-backed, not assumed from prose |
| E02 | [O] | `python variant3d\tools\decode_donor_cfg.py --dry-run --check` ×2 → exit 0 both; stdout saved as `v55\final_cfg_out.txt` (7,874 lines), stderr 0 lines | `summary: 7/7 hashes, 19/19 count checks`; `check: hashes PASS counts PASS determinism PASS`; `dry-run: no files written` (`:761,819,852,857`) |
| E03 | [O] | `decode_pattern_lib.py --dry-run --check`: pass 1 exit 1 (stderr `NameError: name 'build_family_docs' is not defined` at `:1060` as executed); pass 2 and final exit 0, `CHECK SUMMARY: 50 PASS / 0 FAIL` | Transient concurrent edit followed by clean re-run; no repair by V55 (`:1120-1122`; V53:24,42) |
| E04 | [O] | `decode_donor_pattern.py --dry-run --check` ×2 → exit 0; stdout 763 lines | `PATTERN FILES: 710`, `BYTE CLOSURE: 710/710`, `DRY_RUN: yes (no files written)`, `CHECK SUMMARY: PASS 30 / FAIL 0`; two `CLOSURE AUDIT … ok=True` (`:736,748,981`) |
| E05 | [O] | `decode_donor_masks.py --dry-run --check` ×2 → exit 0; stdout 19 lines | 18 named `CHECK … PASS` rows; `CHECK SUMMARY: 18/18 PASS \| parity=UNVERIFIED \| no donor frame, no writes` (`:472`) |
| E06 | [O] | `terrain_qa_harness.py --check` ×2 → exit 0; 37 stdout lines; extra `--dry-run --check` → exit 2, empty stdout, argparse error on stderr | `CHECK OK: 36/36 assertions passed` (`:1132-1134`); `--dry-run` is not in the flag surface (`:1145-1151`; V53 §2) |
| E07 | [O] | `build_terrain_new_atlas.py --dry-run --check` ×2 → exit 0; stdout 207 lines | `"mode": "PLAN_CHECK", "passed": true`; 21 named plan checks all `true`; `"mode": "DRY_RUN (nothing written)"`; 8 output hashes (`:860,985,998-1005`) |
| E08 | [O] | `python -m py_compile <six tools>` ×2 with temp prefix → exit 0; temp pycache file count 203 | Syntax-valid on the final tree; bytecode isolated from repo (§5) |
| E09 | [O] | Read-only `git status --short` before/after; scoped lines identical (7 entries) and full-repo lines identical (132) | Git reports no *tracked* change; insufficient as a write-proof because all scoped paths are `??` |
| E10 | [O] | Byte/hash snapshot `v55\fs_before.txt` (327 files) vs `fs_after.txt` (1,039 files); final SHA-256: cfg `ABBF0571…50D85AB0E`, I03 `DDFB8688…840320`, I02 `00C0591A…407E6619`, I04 `667B71FB…F4EBDAA`, I05 `3A92D053…9904FF`, harness `5A3B9E77…311C5D8492` | Tree mutated *during* the window by other workers; final hashes pin exactly what the final pass tested |
| E11 | [O] | `Get-ChildItem variant3d\assets\terrain_new -Recurse` sorted by `LastWriteTimeUtc`; newest mask PNG 2026-11-26T09:16:07.5615842Z (`masks\height\src\peninsulas\4pl_mask_peninsulas_4.height.png`) | Concurrent I04-style write activity after V55's final Python pass; not attributable to V55's dry-runs |
| E12 | [O]/[I] | V53_cli_reconciliation.md:21-25,53-58,139 (landed mid-window); tool stdout no-write lines (E02/E03/E04/E05/E07) | Independent corroboration of all six exit codes and of the transient NameError; [I] write attribution to concurrent owners, not V55 |

`[I]` appears only where explicitly marked. `[U]` items are in §7. No gate result and no donor-parity claim appear anywhere in this report.

## 3. Per-command results table

Both passes used `PYTHONPYCACHEPREFIX=C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v55\pycache`. "Pass 2" = initial sweep; "Final" = re-run after sources stopped changing. Stdout/stderr were captured to files; counts below are exact line counts.

| # | Command (repo root) | Pass | Exit | Stdout summary (verbatim key lines) | Stderr | Verdict [O] |
|---:|---|:---:|---:|---|---|---|
| 1 | `python variant3d\tools\decode_donor_cfg.py --dry-run --check` | 2 / Final | 0 / 0 | `dry-run: 2997 constants + 4868 unverified lines; no files written`; `check: hashes PASS counts PASS determinism PASS`; `summary: 7/7 hashes, 19/19 count checks`; `dry-run: no files written (pass --out to write)`; three `determinism PASS run1=… run2=…`; NOTE MP-1 (F03 summary 20 vs observed 19, explicitly not a pass criterion) | empty (0 lines both passes) | PASS; 7/7 hashes, 19/19 counts, expected values |
| 2a | `python variant3d\tools\decode_pattern_lib.py --dry-run --check` | 2 | **1** | 0 lines | `Traceback (most recent call last):` … `File "…decode_pattern_lib.py", line 1131, in <module>` / `line 1092, in main` / `line 1060, in load_context` / `docs = {"family_index.json": json_bytes(ctx["family_index_doc"])}` / `NameError: name 'build_family_docs' is not defined` | FAIL — transient source rewrite (§4) |
| 2b | same command | Final | 0 | 52 lines; 50 rows `[PASS] …`; `CHECK SUMMARY: 50 PASS / 0 FAIL (no donor parity claim)` | empty | PASS; owner I03 |
| 3 | `python variant3d\tools\decode_donor_pattern.py --dry-run --check` | 2 / Final | 0 / 0 | 763 lines; `PATTERN FILES: 710`; `BYTE CLOSURE: 710/710`; `PIPELINE_SHA256: 9bc45639874b9eff…`; `DRY_RUN: yes (no files written)`; `CHECK SUMMARY: PASS 30 / FAIL 0`; two `CLOSURE AUDIT … ok=True` | empty | PASS; 30/30 checks, 710/710 closure |
| 4 | `python variant3d\tools\decode_donor_masks.py --dry-run --check` | 2 / Final | 0 / 0 | 19 lines; 18 `CHECK … PASS` rows (inventory 1331/1856/1279, V1–V7 vectors, `three_water_notions`); `CHECK SUMMARY: 18/18 PASS \| parity=UNVERIFIED \| no donor frame, no writes` | empty | PASS; 18/18 |
| 5a | `python variant3d\tools\terrain_qa_harness.py --check` (task's documented form) | 2 / Final | 0 / 0 | 37 lines; 36 `OK …` rows incl. `52 register rows`, `25/16/11 class split`, `red refused without signed spec`, `no subprocess execution in harness source`; `CHECK OK: 36/36 assertions passed` | empty | PASS; 36/36 |
| 5b | extra probe: `…terrain_qa_harness.py --dry-run --check` | 1 | **2** | 0 lines | `usage: terrain_qa_harness.py [-h] [--dump-a …] … [--check]`; `terrain_qa_harness.py: error: unrecognized arguments: --dry-run` | Not a tool defect — unsupported flag; documented form is `--check` |
| 6 | `python variant3d\tools\build_terrain_new_atlas.py --dry-run --check` | 2 / Final | 0 / 0 | 207 lines; JSON report `"mode": "DRY_RUN (nothing written)"`, `"check": {"mode": "PLAN_CHECK", "passed": true, "checks": {…21 keys…}}`, all 21 true (`index_names_124_unique`, `slots_128_named_124_filled_121_empty_3`, `empty_sentinels_86_110_123`, `deterministic_manifest_bytes`, …), 8 output hashes, `"visual_parity_claim": false` | empty | PASS; 21/21 plan checks, expected 21/21 |
| 7 | `python -m py_compile variant3d\tools\decode_donor_cfg.py …decode_pattern_lib.py …decode_donor_pattern.py …decode_donor_masks.py …build_terrain_new_atlas.py …terrain_qa_harness.py` | 2 / Final | 0 / 0 | no stdout; temp pycache 203 files | empty | PASS; syntax valid |

**[D]** "Expected" values in the task (7/7 + 19/19 for cfg, 21/21 plan checks for atlas) were observed exactly. The task did not state expected totals for the other four; their observed totals are quoted verbatim above and are source-internal only. **[U]** None of these checks validates donor visual fidelity; no A/B frame exists.

## 4. Failures with owners

| # | Failure (exact message) | When | Passes attempted | Owner / ticket | Disposition |
|---:|---|---|---|---|---|
| F1 | `NameError: name 'build_family_docs' is not defined` at `decode_pattern_lib.py:1060` as executed (call chain `:1131 <module>` → `:1092 main` → `:1060 load_context`), exit 1 | Initial sweep only | 3: (a) failing run; (b) source re-read (on-disk `:1060` had become `docs = {"pattern_lib_index.json": json_bytes(ctx["lib_index_doc"])}`) + two equal hash checks 3 s apart; (c) pass 2 and final pass both exit 0, 50 PASS / 0 FAIL | **I03** (file owner per SWARM_BOARD.md:134) | Transient mid-edit execution; no source edited by V55. Corroborated by V53:24,42. **Not claimed as a persistent defect and not repaired.** |
| F2 | `terrain_qa_harness.py: error: unrecognized arguments: --dry-run`, exit 2 (extra probe only) | Initial sweep | 2: `--help`/argparse re-read (`terrain_qa_harness.py:1145-1151`) and task's actual `--check` form (exit 0) | **COORD/I13 (N16)** for CLI/documentation reconciliation; no code defect assigned | CLI-contract observation; the task's primary harness form `--check` passes. |
| F3 | cfg NOTE MP-1: F03 summary 20 vs observed 19 global keys | Emitted on both cfg passes | 2 passes; tool explicitly says it is "NOT a pass criterion" and no 20th key is invented (`decode_donor_cfg.py:822-825,844-846`) | **F03 / COORD** (documented contradiction, already preserved in V53 M13) | Not a failing check: exit 0, 19/19 observed count checks PASS. Recorded, not "fixed". |

**No tool was fixed, no assertion deleted, no threshold lowered, no failing check re-run until green.** F1 disappeared because the owner's source stopped changing, not because V55 altered anything.

## 5. Repo-write verification (no donor writes)

1. **[O] Requested check:** `git status --short -- variant3d/tools variant3d/assets/terrain_new` before and after all Python runs produced the **same 7 lines** (`?? variant3d/assets/terrain_new/` plus the six `?? variant3d/tools/*.py` files). Full `git status --short` also matched (132 lines each).
2. **[U] That result is not a write-proof.** Every scoped path is untracked, so git reports only the collapsed directory `variant3d/assets/terrain_new/`; new or changed files inside it are invisible to `git status` (E09).
3. **[O] Stronger byte-level snapshot** (path, length, SHA-256 for every file under both scopes): 327 files before → 1,039 after. Added: 713 `terrain_new/patterns/*.json` (e.g. `k_plain_mid_12.json`, `pattern_decode_manifest.json`, mtimes 09:01:42–09:01:46Z) and mask PNGs under `terrain_new/masks/height/**` (newest 09:16:07Z). Changed: three tool sources (I02/I03/I04 hashes in E10) and two repo `__pycache__` `.pyc` files.
4. **[I] Attribution:** V55's seven Python commands were all `--dry-run`, `--check`, or `py_compile` with `PYTHONPYCACHEPREFIX` set, and each tool printed an explicit no-write line (`decode_donor_cfg.py:857`; `decode_pattern_lib.py` dry-run default `:1078`; `decode_donor_pattern.py:981`; `decode_donor_masks.py:591`; `build_terrain_new_atlas.py:985`; harness self-test `:1151-1152`). **V55 wrote none of the files in (3).** The byte-level changes are consistent with concurrent I02/I03/I04 owners running write-mode jobs or plain Python without the prefix (three repo `__pycache__` directories already existed at baseline). Exact process-level attribution is **[U]** — no process audit was available to V55.
5. **[O] No donor write by V55.** The donor root `C:\Games\Cossacks 3` was only read by the tools (cfg/pattern_lib/pattern/masks read donor bytes; atlas/harness do not). No donor binary was executed or copied; `app/` was not touched and no git write was performed.

## 6. Risks

1. **[O] Volatile source surface** (E10/F1): a check can execute a half-written module. Any PASS is a point-in-time statement keyed to the final SHA-256 list in E10; re-read before trusting it (V53:24,130).
2. **[O] `--check` is not a write gate** for I01/I02/I03/I05 (V53:101,132). V55 used `--dry-run` explicitly, but COORD's write jobs must be sequenced after preflight, not combined with a `--check` assumed to be safe.
3. **[O] Git status is a weak write detector here** (§5.2): the relevant paths are untracked. Use hash snapshots, not git alone, when asserting "nothing was written".
4. **[O] Concurrency contaminates determinism evidence**: the tree changed between V55's two passes (327 → 1,039 files). Whole-file output hashes from different passes are not comparable across that boundary.
5. **[O] Self-checks are source-internal** (E02–E07): hashes, counts, byte closure, frozen bands. They do not prove asset correctness or donor fidelity (V53:139).
6. **[O] Harness surface differs from the decoders**: no `--game`, no donor-root guard, no `--dry-run`, `--out` writes unconditionally when inputs exist (`terrain_qa_harness.py:1145-1161`; V53:58,135). Passing `--dry-run` exits 2 (F2).
7. **[O] MP-1 residue** (F3): F03 prose says 20 keys while observed donor has 19; preserved as a recorded exception, not a pass criterion.

## 7. Open questions

1. **[I] COORD/I03:** confirm that the F1 transient is closed by the current `DDFB8688…` source (V55's final pass says yes) and that the owner intends `terrain_new/lib` as the output root (V53 §6 Q1). V55 made no ownership decision.
2. **[I] COORD:** reconcile the write-detection protocol for the swarm — should every worker take hash snapshots of untracked `variant3d/assets/terrain_new/**` before and after, given `git status` cannot see inside it?
3. **[I] COORD/I13:** annotate the harness CLI in A03/V21/V42 as `--check`-only (no `--dry-run`), or change the tool? V55 only reports the observed exit 2.
4. **[U] Attribution of the 713 pattern JSONs and mask PNGs written during the window:** which owner ran the write-mode jobs? V55 has no process evidence; COORD's dispatcher ledger may.
5. **[I] COORD:** should V55's final-pass source hashes (E10) be recorded as the pre-gate baseline, and who re-runs these six checks after the next owner edit?
6. **[U] No donor GPU A/B frame exists.** Whether one is obtainable at all remains COORD's open question; no R1–R6 acceptance card may be called donor parity on this evidence.

## 8. Honesty / scope statement

Exactly one file was written by V55: this report. All other artefact writes were temporary and outside the repo (`%TEMP%\opencode\v55\`). No `.py`, `.gd`, shader, config, fixture, result JSON, PNG, `app/` file, donor file or git state was edited by V55. **No Godot process was launched; no runner subcommand (`run`, `status`, `ack`, `cancel`, `reset`, `doctor`, `unwedge`) was executed; no gate was run; no gate result is claimed.** Every claim carries `[O]/[D]/[I]/[U]` and a command or file:line citation; contested surfaces were re-read twice (`CHARTER.md:85-93`). No threshold was lowered, no assertion deleted, no green result fabricated, and no donor-parity claim made. **PORT APPROXIMATION / port-internal self-check evidence only; donor parity remains UNVERIFIED.**

## 9. Five-line summary

1. **[O] All six final-pass Python self-checks exit 0:** cfg 7/7 hashes + 19/19 counts; pattern_lib 50 PASS / 0 FAIL; pattern 30/30 with 710/710 byte closure; masks 18/18; atlas PLAN_CHECK 21/21; harness 36/36.
2. **[O] One first-pass failure:** `decode_pattern_lib.py` exited 1 with `NameError: name 'build_family_docs' is not defined` during a concurrent source rewrite (hash `5F559FA3…` → `DDFB8688…`); three passes recorded, next and final passes clean; owner **I03**, no fix attempted.
3. **[O] Harness CLI:** `--check` exits 0 (36/36); extra `--dry-run --check` exits 2 (`unrecognized arguments: --dry-run`) — documented form is `--check`; owner **COORD/I13** for any reconciliation.
4. **[O] `py_compile` on all six tools exits 0 twice** with `PYTHONPYCACHEPREFIX` to `%TEMP%\opencode\v55\pycache` (203 files); scoped `git status --short` identical before/after, but all scoped paths are untracked so git is not a write-proof.
5. **[I] Byte-level snapshot shows concurrent workers mutated the tree** (327 → 1,039 files; three tool sources changed; pattern/mask assets appeared); V55 wrote only this report, ran no Godot/runner/gate, and makes **no donor-parity claim**.

*End of V55 Python preflight report.*
