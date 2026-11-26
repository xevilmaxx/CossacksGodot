---
id: V53
swarm: TERRAIN-SWARM-2026-11-26
title: "V53 — verified CLI reconciliation for the terrain_new asset pack (read-only)"
agent: "V53 (verification subagent; one-report-only, read-only, no Godot)"
owner_file: docs/terrain_swarm_2026-11-26/reports/V53_cli_reconciliation.md
status: VERIFIED_CLI_SNAPSHOT__NO_ASSET_WRITES_BY_V53__NO_GATE_RESULT__NO_PARITY_CLAIM
created: 2026-11-26
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_guard: "PORT APPROXIMATION / port-internal CLI facts only. No donor GPU A/B frame exists and none was produced here; no donor-fidelity claim is made anywhere in this report (CHARTER.md:41,134-135)."
method: "[O] exact `python <tool> --help` output + `python <tool> --dry-run --check` exit codes + argparse source re-read (two passes) · [D] deterministic consequence of cited source · [I] recommendation · [U] unresolved. V53 ran ZERO Godot processes, ZERO runner jobs and ZERO write-mode commands."
landing_note: "I15_asset_generation.md is NOT on disk at read time (file read returned not-found); no I15 ticket text is assumed. SWARM_BOARD.md:145-147 still lists I14/I15/I16 as no-ticket/no-report although I16_qa_fixtures.md, V42_gate_commands.md and V44_code_review_r3.md are on disk — the filesystem is ahead of the board (board itself warns of this at SWARM_BOARD.md:7-11)."
---

# V53 — exact, verified CLI table for generating `terrain_new`

## 0. Executive summary

1. **[O] Six tools expose six *different* CLI shapes.** Only `decode_donor_cfg.py` writes on `--out` alone (`decode_donor_cfg.py:808`). `decode_pattern_lib.py`, `decode_donor_pattern.py`, `decode_donor_masks.py` and `build_terrain_new_atlas.py` require an explicit `--write` (or `--no-dry-run` for I02); `--out` alone is a no-op for those four (§2, E03). The QA harness has **no** `--write` and **no** `--dry-run`: `--out` + four inputs writes the report unconditionally (`terrain_qa_harness.py:1157-1161,1177-1180`).
2. **[O] I05's two discoveries are confirmed at source level.** (a) `build_terrain_new_atlas.py:927` sets `dry_run = not args.write`, so `--out` alone does not write; (b) `--cell 1024` is parsed but refused under `terrain_new` — as `commit_default` it fails `--check` (`no_forbidden_legacy_hash`, `build_terrain_new_atlas.py:844-846`) and is refused at write time by the legacy-byte-identity guard (`:955-958`); as `--hires-local` a write under `terrain_new` is refused at `:946-948`. Observed: `--cell 1024 --dry-run --check` → exit **1**; `--hires-local --dry-run --check` → exit **0** with `resolution_tier: local_hires` (E08).
3. **[O] All six self-checks pass in the current tree.** `--dry-run --check` (harness: `--check`) returned exit **0** for each: cfg `7/7 hashes, 19/19 counts`; pattern_lib `50 PASS / 0 FAIL`; pattern full battery + byte-closure; masks `18/18 PASS`; atlas `PLAN_CHECK passed:true`; harness `36/36` assertions (E06). No file was written by these runs.
4. **[O] Five of six tools refuse an `--out` inside the donor root with exit 2** (cfg `:803-806`, pattern_lib `:1083-1086`, pattern `:887-889` [+ legacy `assets/terrain` guard `:890-893`], masks `:597-602`, atlas `:932-933`); all five were observed to refuse with exit 2 (E07). The harness has no `--game` and no donor-root guard — it writes a QA report to an arbitrary `--out`, not a donor-derived asset.
5. **[D] The documented CLI in A03 (`A03_asset_pipeline.md:88-98,274-282`) is materially stale**: 14 catalogued mismatches (§4 M1–M14) include no `--pack`, no `--cfg`/`--gen-cfg-dir`/`--scripts`, no `--types`, no `--only`, no `--season`, `--cell` default 128 not 256, `--check` not uniformly "without donor", two named tools absent and wrong tool filenames. V11 CR6 (`V11_ownership_ledger.md:146`) already resolves the filename aliases; this report does not re-open that decision.
6. **[O] The tree is moving under this worker.** `decode_pattern_lib.py`'s default `--out` changed from `terrain_new/patterns` to `terrain_new/lib` between two `--help` calls, and a first `--dry-run --check` hit a transient `NameError` (exit 1) that was gone on re-run (exit 0) (E12). `terrain_new/cfg/` and `terrain_new/patterns/` were populated by other workers during the read window; V53 wrote neither. Every row below is a **point-in-time snapshot** after a final re-read of `--help` + argparse source.
7. **[U] No generation command in §3 was executed.** §3 commands are derived from verified flags and write-gating source; they are a plan for COORD/owners, not a claim that the outputs are complete or correct. No parity claim.

## 1. Evidence table

| # | Label | Source (file:line / read-only command) | Establishes |
|---:|---|---|---|
| E01 | [O] | `python variant3d\tools\<tool>.py --help` × 6, run twice (initial + final sweep); verbatim text in Appendix A | Exact flag surface, defaults and usage strings (no invented flag) |
| E02 | [O] | `decode_donor_cfg.py:783-795`; `decode_pattern_lib.py:1064-1079`; `decode_donor_pattern.py:858-870`; `decode_donor_masks.py:575-586`; `build_terrain_new_atlas.py:902-923`; `terrain_qa_harness.py:1141-1153` | argparse `add_argument` / mutually-exclusive groups match `--help` (pass 2) |
| E03 | [O] | `decode_donor_cfg.py:808,828-858,860-871`; `decode_pattern_lib.py:1078,1103-1113`; `decode_donor_pattern.py:876,1004-1010`; `decode_donor_masks.py:591,607-609`; `build_terrain_new_atlas.py:927,945-950,987-995`; `terrain_qa_harness.py:1157-1161,1177-1180` | Which flag actually writes; dry-run default; `--out`-only behaviour |
| E04 | [O] | `decode_donor_cfg.py:803-806`; `decode_pattern_lib.py:1083-1086`; `decode_donor_pattern.py:887-893`; `decode_donor_masks.py:597-602`; `build_terrain_new_atlas.py:932-933` | Donor-root (and legacy-root) output guards, exit 2 |
| E05 | [O] | `decode_donor_cfg.py:817-826,856-858`; `decode_pattern_lib.py:1116-1123`; `decode_donor_pattern.py:1012-1014`; `decode_donor_masks.py:474,605-606`; `build_terrain_new_atlas.py:844-852,998-1005`; `terrain_qa_harness.py:1132-1134,1155-1156,1193` | `--check` exit semantics per tool |
| E06 | [O] | `python ... --dry-run --check` × 5 + `python ... --check` × 1; full output captured, exit codes read from `$LASTEXITCODE` | All six exit 0; observed summaries quoted in §2 |
| E07 | [O] | Same six commands with `--out "C:\Games\Cossacks 3\data\gen\BAD"`; harness with `--dry-run --check` | 5 donor-root refusals exit 2; harness rejects `--dry-run` with argparse exit 2 |
| E08 | [O]/[D] | `build_terrain_new_atlas.py:87-88,910,912,939-943,946-950,955-958,844-852`; **[O]** `--cell 1024 --dry-run --check` exit 1 with the legacy-identity warning, `--hires-local --dry-run --check` exit 0 with `passed:true`/`local_hires`; **[D]** source attributes the cell-1024 failure to `no_forbidden_legacy_hash` (`:844-846`) | `cell 1024` accepted by argparse but refused under `terrain_new`; local hires tier is dry-run-only here |
| E09 | [O] | `A03_asset_pipeline.md:88-98,141,274-282`; `V11_ownership_ledger.md:146,171-172`; `V36_integration_checklist.md:170`; `V28_code_review_r1.md:73,77,85,93,99`; `V44_code_review_r3.md:87-88,152`; `I16_qa_fixtures.md:83,160` | Documented CLI claims to reconcile (§4) |
| E10 | [O] | `decode_pattern_lib.py:51,1059-1060`; `decode_donor_pattern.py:87`; read-only `Get-ChildItem variant3d\assets\terrain_new -Recurse` | Current output roots: I03 `terrain_new/lib`, I02 `terrain_new/patterns`; I01/I02 outputs present, `lib/`/`atlas/` absent at final read |
| E11 | [O] | `Test-Path` on `build_terrain_new_manifest.py` = False, `validate_terrain_new.py` = False; `I16_qa_fixtures.md:83` (N7 PENDING) | N6/N7 tools absent; only atlas `--emit-root-manifest` can write a root manifest |
| E12 | [O] | First `decode_pattern_lib.py --dry-run --check` → `NameError: build_family_docs is not defined`, exit 1; re-run of `--help`, source re-read and `--dry-run --check` → `50 PASS / 0 FAIL`, exit 0; `--out` default changed `patterns` → `lib` between `--help` calls | Concurrent implementation edits; CLI snapshot is point-in-time |
| E13 | [O] | `CHARTER.md:66-93` (read-only, labels, multi-pass, no parity) | Governing rules applied: two source passes per tool, no write-mode job |

`[I]` appears only in §6 recommendations. `[U]` items are collected in §5/§6. No claim of donor visual parity is made or implied.

## 2. Per-tool CLI table

"Write trigger" = the condition under which bytes are emitted, verified from source (pass 2), not from prose. "Refuses donor-root `--out`" refers to exit-2 guards before any write.

| Tool (ticket) | Exact flags shown by `--help` | Write trigger | Dry-run default? | Refuses donor-root `--out`? | `--check` exit semantics | Observed `--dry-run --check` |
|---|---|---|---|---|---|---|
| `decode_donor_cfg.py` (I01) | `--game GAME`, `--out OUT`, `--check`, `--dry-run` (`-h`) | **`--out` alone** (and no `--dry-run`): `write = bool(args.out) and not args.dry_run` (`:808`); no `--write` flag exists | Yes **only when `--out` omitted** (`:793-794,808-809`) | Yes: "ERROR: --out must not be inside the donor root …", exit 2 (`:803-806`) | exit 0 only if hashes **and** counts **and** determinism pass (`:817-826`); exit 1 on any FAIL; exit 2 on bad `--game`/donor-root `--out`/read error (`:800,806,815`) | exit **0**: `check: hashes PASS counts PASS determinism PASS`, `summary: 7/7 hashes, 19/19 count checks`, `dry-run: no files written (pass --out to write)` |
| `decode_pattern_lib.py` (I03) | `--game GAME`, `--out OUT`, `--check`, mutually exclusive `--dry-run \| --write` | `--write` only (`dest="write"`, default False at `:1073-1078`; write loop `:1103-1113`). **`--out` alone does not write** | Yes (`:1075,1078`) | Yes: "REFUSED: --out is inside the read-only donor root", exit 2 (`:1083-1086`) | exit 1 on any FAIL, else 0 (`:1116-1123`); exit 2 on donor-root `--out`/read error (`:1086,1095`) | exit **0**: `CHECK SUMMARY: 50 PASS / 0 FAIL (no donor parity claim)` (first attempt exit 1 from a transient concurrent edit — E12) |
| `decode_donor_pattern.py` (I02) | `--game GAME`, `--out OUT`, mutually exclusive `--dry-run \| --no-dry-run` (`--no-dry-run` alias `--write`), `--check` | `--write` / `--no-dry-run` (`:864-868`); `dry_run = True if args.dry_run is None else args.dry_run` (`:876`); write block `:1004-1010`. **`--out` alone does not write** | Yes (`:865,876`) | Yes, exit 2 (`:887-889`); **also** refuses `--out` inside legacy `variant3d/assets/terrain` (`:890-893`) | exit 1 if `book.failed`, else 0 (`:1012-1014`); exit 2 on donor/legacy root or missing donor files | exit **0**: full F01/F02/X05/D05/X12 battery + `CLOSURE AUDIT … ok=True`; `DRY_RUN: yes (no files written)` |
| `decode_donor_masks.py` (I04) | `--game GAME`, `--out OUT`, `--check`, `--dry-run`, `--write` (NOT a mutually-exclusive group in `--help`) | `--write` **and not** `--dry-run` **and not** `--check`: `do_write = bool(args.write) and not args.dry_run and not args.check` (`:591`); write `:607-609`. **`--out` alone does not write**; **`--check` suppresses write** | Yes (`:583,591`) | Yes: "REFUSED: --out … is inside donor root", exit 2 (`:597-602`) | `run_check` returns 0 iff all vectors pass, else 1 (`:474`); `:605-606` returns it directly; exit 2 on donor-root `--out` | exit **0**: `CHECK SUMMARY: 18/18 PASS \| parity=UNVERIFIED \| no donor frame, no writes` |
| `build_terrain_new_atlas.py` (I05) | `--game GAME`, `--out OUT`, `--cell CELL`, `--hires-local`, `--check`, `--dry-run`, `--write`, `--emit-root-manifest` | `--write` only: `dry_run = not args.write` (`:927`), explicit mutual exclusion `:925-926`, writes `:987-994`. **`--out` alone does not write** (I05 discovery confirmed) | Yes (`:917,927`) | Yes: `ap.error("refusing --out inside donor root")`, exit 2 (`:932-933`) | `--dry-run --check` → `verify_plan` (`:999`, `:798-860`); `--write --check` → `verify_outputs` (`:863-899`); any failed check raises `SystemExit` (exit 1) at `:1001-1005` | exit **0**: `"mode": "PLAN_CHECK", "passed": true`; `--cell 1024` variant exit **1** (E08) |
| `terrain_qa_harness.py` (I13/N16) | `--dump-a DUMP_A`, `--dump-b DUMP_B`, `--seed-manifest SEED_MANIFEST`, `--policy {advisory,red}`, `--out OUT`, `--check` | `--out` **writes the report** when all four inputs are present (`:1157-1161,1177-1180`); no `--write`; no donor-asset output. `--policy red` refused without signed donor spec (`:1170-1172`) | **No `--dry-run` flag exists**; `--check` is the no-write self-test (`:1151-1156`) | **No** — no `--game`/donor-root guard (report path only) | `--check` → `self_check()` (`:1155-1156`), 0 iff all assertions pass (`:1132-1134`); full run returns 1 on hard FAIL (`:1193`), exit 2 for missing inputs/red policy/bad report (`:1161,1172,1175`) | `--check` exit **0**: `CHECK OK: 36/36 assertions passed`; `--dry-run --check` → argparse `unrecognized arguments: --dry-run`, exit 2 |

**Cross-tool facts [D]:** the only tool where `--out` alone writes is I01; the only tool that refuses legacy `assets/terrain` explicitly is I02; the only tool with a committed-vs-local tier guard is I05; the only tool with no donor-root concept is the harness. These are consequences of the cited lines, not parity claims.

## 3. Exact generation commands (copy-paste PowerShell)

Run from the repo root (`C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3`). `;` separators, quoted paths, `python` — per `CHARTER.md:94`. **V53 did not execute any of the write commands below**; they are derived from the verified flags in §2.

```powershell
# --- Stage A: derived assets under variant3d/assets/terrain_new/** -------------
# I01 cfg — writes BECAUSE --out is given (no --write flag exists).
python variant3d\tools\decode_donor_cfg.py --game "C:\Games\Cossacks 3" --out variant3d\assets\terrain_new\cfg --check

# I02 patterns — --out alone is inert; --write is mandatory.
python variant3d\tools\decode_donor_pattern.py --game "C:\Games\Cossacks 3" --out variant3d\assets\terrain_new\patterns --write --check

# I03 pattern-lib index — --write mandatory. Current default root is terrain_new\lib (NOT V11 G5's patterns/).
python variant3d\tools\decode_pattern_lib.py --game "C:\Games\Cossacks 3" --out variant3d\assets\terrain_new\lib --write --check

# I04 masks — --write mandatory; do NOT combine --check here (it suppresses the write).
python variant3d\tools\decode_donor_masks.py --game "C:\Games\Cossacks 3" --out variant3d\assets\terrain_new\masks --write

# I05 atlas, commit tier cell 128 — --write mandatory (--out alone is inert).
# --emit-root-manifest writes <out>/../manifest.json = terrain_new\manifest.json (atlas contribution only).
python variant3d\tools\build_terrain_new_atlas.py --game "C:\Games\Cossacks 3" --out variant3d\assets\terrain_new\atlas --cell 128 --write --emit-root-manifest --check

# --- QA report (I13/N16) — NOT a terrain_new asset ----------------------------
# Writes inbox\qa\terrain_qa_report.json (I16_qa_fixtures.md:88,141). No --write flag.
python variant3d\tools\terrain_qa_harness.py --dump-a <A_dump.json> --dump-b <B_dump.json> --seed-manifest <pinned_seed_manifest.json> --policy advisory --out inbox\qa\terrain_qa_report.json
```

Self-test / verification form only (no writes; **all six were actually run by V53**):

```powershell
python variant3d\tools\decode_donor_cfg.py --dry-run --check
python variant3d\tools\decode_pattern_lib.py --dry-run --check
python variant3d\tools\decode_donor_pattern.py --dry-run --check
python variant3d\tools\decode_donor_masks.py --dry-run --check
python variant3d\tools\build_terrain_new_atlas.py --dry-run --check
python variant3d\tools\terrain_qa_harness.py --check        # no --dry-run: passing it exits 2
```

**[I] Cautions on the commands above** (each traceable to a cited line):
- `--check` does **not** gate the write for I01/I03/I02/I05: they write first and may return 1 afterwards (`decode_donor_cfg.py:825-826,860-871`; `decode_pattern_lib.py:1103-1113,1122`; `decode_donor_pattern.py:1004-1013`; `build_terrain_new_atlas.py:987-1005`). A non-zero `--check` exit is therefore **not** proof that nothing was written. Run the self-test block *before* the write block.
- I04's `--check` suppresses writing entirely (`:591`), so it is intentionally omitted from the write command.
- For a **local, uncommitted** cell-1024 atlas (not a `terrain_new` asset, **not run by V53**), the only admissible form is `--hires-local --write --out <path OUTSIDE terrain_new>`; `--hires-local` with an out inside `terrain_new` is refused at `build_terrain_new_atlas.py:946-948`, and bare `--cell 1024` under `terrain_new` is refused at `:955-958` / fails `--check` at `:844-846`.

## 4. Mismatches — documented CLI (A03 / ticket / other reports) vs actual implementation

Every row was re-read twice (prose + `--help` + argparse source) before being called a mismatch. "Resolved elsewhere" means another landed report already adjudicated the naming/ownership; no new decision is made here.

| # | Documented claim (file:line) | Actual implementation (file:line / `--help`) | Verdict |
|---:|---|---|---|
| M1 | A03:98 "writing requires explicit `--out`" for **every** decoder | True only for I01 (`decode_donor_cfg.py:808`). I02/I03/I04/I05 need `--write`/`--no-dry-run` (`decode_donor_pattern.py:864-868,1004`; `decode_pattern_lib.py:1073-1078,1103`; `decode_donor_masks.py:591,607`; `build_terrain_new_atlas.py:927,945`) | **MISMATCH** — I05 discovery confirmed; `--out` alone does not write for 4/5 tools |
| M2 | A03:274-276 filenames `decode_donor_pattern_new.py`, `decode_donor_cfg_new.py`, `decode_donor_mask_new.py` | Files on disk: `decode_donor_pattern.py`, `decode_donor_cfg.py`, `decode_donor_masks.py` | **MISMATCH** with A03, already **resolved** by V11 CR6 (`V11_ownership_ledger.md:146`): PLAN names canonical. Also plural `masks` in the real filename |
| M3 | A03:275 cfg `--cfg data/game/var/generator.cfg --gen-cfg-dir data/gen [--scripts]` | No such flags; cfg exposes only `--game/--out/--check/--dry-run` (`decode_donor_cfg.py:785-794`) | **MISMATCH** — 3 invented flags |
| M4 | A03:276 masks `[--types land,nowater2,mediterranean,…]` | No `--types`; tool decodes ALL 4,466 TGAs (`decode_donor_masks.py:577-585`, `--help` description) | **MISMATCH** |
| M5 | A03:277 atlas `[--season summer,winter]` | No `--season`; atlas flags end at `--emit-root-manifest` (`build_terrain_new_atlas.py:906-922`) | **MISMATCH** |
| M6 | A03:274 pattern `[--only FAMILY]` | No `--only` (`decode_donor_pattern.py:860-870`) | **MISMATCH** |
| M7 | A03:98 "All tools accept `--pack terrain_new_v1`" | Zero `--pack` occurrences across the six tool files (grep of `--pack\|--season\|--types\|--only\|--cfg\|--gen-cfg-dir\|--scripts` returned only `resolution_tier` hits in the atlas) | **MISMATCH** — pack id is embedded in emitted JSON, not a CLI input |
| M8 | A03:141 "default `--cell` is **256**" (yet same line recommends 128 as commit default) | `DEFAULT_CELL = 128` (`build_terrain_new_atlas.py:87`), `--cell` default 128 (`:910`), `--help` says 128 | **MISMATCH** — A03 self-contradiction resolved toward 128 in code |
| M9 | A03:278 `build_terrain_new_manifest.py`; A03:279/286 `validate_terrain_new.py` | Both `Test-Path` = False; I16 marks N7 PENDING (`I16_qa_fixtures.md:83,160`) | **MISMATCH / MISSING TOOL** — only atlas `--emit-root-manifest` writes a root manifest (`:992-994`, "atlas contribution only") |
| M10 | A03:282 "`--check` re-verifies hashes/sizes from committed manifests **without the donor**" | I01/I03/I02 re-read donor bytes for `--check` (`decode_donor_cfg.py:819-820`; `decode_pattern_lib.py:1088-1092`; `decode_donor_pattern.py:883-906`); I04/I13 are in-memory self-tests (`decode_donor_masks.py:474,605-606`; `terrain_qa_harness.py:1155-1156`); only I05 has `verify_outputs` and it needs `--write` (`build_terrain_new_atlas.py:863-899,999`) | **MISMATCH** |
| M11 | V11 G5 `terrain_new/patterns/pattern_lib_index.json`; V44 B1/R1 collision (I02 vs I03 both writing `patterns/`) | I03 now emits **only** `pattern_lib_index.json` under `terrain_new/lib` (`decode_pattern_lib.py:51,1059-1060`), default changed mid-session from `patterns` to `lib` (E12) | **MISMATCH with V11 G5**, but implements V44's requested one-writer-per-file fix. Needs COORD ratification (Q1) |
| M12 | V36:170 "Run each tool dry-run, then `--write` to the single root" | I01 has no `--write` — it writes on `--out` (`decode_donor_cfg.py:785-794,808`) | **MISMATCH** — generic instruction invalid for I01 |
| M13 | V28:73 MAJOR F-03 "`decode_donor_cfg.py --check` can never exit 0" (count 20 vs 19) | Observed `--dry-run --check` exit **0**: `7/7 hashes, 19/19 count checks`, determinism PASS; 20-vs-19 is emitted as NOTE MP-1, explicitly not a pass criterion (`decode_donor_cfg.py:822-825,844-846`) | **STALE point-in-time finding** — current tool does exit 0. No claim about V28's correctness at its own snapshot |
| M14 | A03:282 "every write is under `variant3d/assets/terrain_new/`" | Harness writes its report to arbitrary `--out` (canonical `inbox/qa/terrain_qa_report.json`, I16:88,141) — outside `terrain_new` | **MISMATCH** in scope of the "all tools" claim; harness is a QA report writer, not an asset writer. No donor-root guard (§2) |

**Confirmed matches (no mismatch)**, for balance: V11 G1/G2 `terrain_new/cfg/{constants,config_strings}.json` ↔ I01 `--out` default (`decode_donor_cfg.py:775-779`); V11 G3/G4 `terrain_new/patterns/**` ↔ I02 default (`decode_donor_pattern.py:87`); V11 G6/G7 `terrain_new/masks/**` ↔ I04 default (`decode_donor_masks.py:579`); V11 G8/G9 `terrain_new/atlas/**` ↔ I05 default (`build_terrain_new_atlas.py:79-80,908`); V42 E12/§3 and I16:51 harness flags and `--out` semantics ↔ source (E01/E02). **[D]** These agreements are path/flag identities only; they do not validate emitted content.

## 5. Risks

1. **[O] Tool surface is volatile.** I03's default `--out` changed `patterns` → `lib` between two `--help` calls and a transient `NameError` (exit 1) disappeared on re-run (E12). Any CLI table — including this one — is a snapshot. COORD should re-read `--help` before dispatching write jobs.
2. **[O] Outputs are already being generated by other workers.** `terrain_new/cfg/{constants.json,config_strings.json,manifest.json}` and `terrain_new/patterns/*.json` were present at final read (E10); `lib/` and `atlas/` were absent. **V53 wrote none of them** — only `--help`, `--dry-run --check`, and exit-2 refusal probes were run. Do not read presence as validation.
3. **[O] `--check` does not prevent writes for I01/I02/I03/I05.** A failed check can still leave a partially/fully written tree (§3 cautions). Pre-flight with the self-test block, then write, then re-verify.
4. **[O] Cell-1024 trap.** Bare `--cell 1024` under `terrain_new` fails `--check` (exit 1) and is refused at write (`build_terrain_new_atlas.py:844-846,955-958`); `--hires-local` writes under `terrain_new` are refused (`:946-948`). The dry-run check itself is expensive (>120 s observed for E08). **[I]** Treat any 1024 output as local/uncommitted outside `terrain_new`, never a committed asset.
5. **[O] Ownership of `pattern_lib_index.json` moved.** V11 G5 still says `patterns/`; the tool now emits `lib/` (M11). Without COORD ratification, a regeneration could recreate the exact two-writer collision V44 flagged (`V44_code_review_r3.md:87-88,152`).
6. **[O] Harness safety boundary differs from the decoders.** No donor-root guard, no `--game`, no `--dry-run`; `--out` writes unconditionally once four inputs exist (`terrain_qa_harness.py:1157-1161,1177-1180`). `--policy red` is refused without a signed donor spec (`:1170-1172`) — keep `advisory`.
7. **[U] No manifest/schema tool.** N6 and N7 are absent (E11); `schemas/v1.schema.json` (V11 G11) has no generator and the root `manifest.json` is only an "atlas contribution" via `--emit-root-manifest`. Full-pack provenance is therefore unverified.
8. **[U] Donor material is present and read by these tools** (`C:\Games\Cossacks 3` was reachable during E06/E07; cfg/pattern/pattern_lib read donor bytes). This is read-only private-use per `CHARTER.md:26-31`; no donor binary was executed by V53 and no donor bytes were copied into the repo by V53.
9. **[O] Stale documentation surface.** A03/V11/V28/V36/V44/SWARM_BOARD disagree with each other and with current files on several CLI points (§4). Following A03 verbatim would produce non-running commands (M3–M6, M9).
10. **[U] `--check` passing is not asset correctness.** All six self-checks are source-internal (hashes/counts/vectors/pattern invariants). None proves donor visual fidelity; no A/B frame exists or was produced.

## 6. Open questions

1. **[I] COORD:** ratify I03's new root `terrain_new/lib/pattern_lib_index.json` or restore V11 G5 `terrain_new/patterns/pattern_lib_index.json`? Updating the ledger and the tool in the same commit is forbidden without an explicit amendment (`V44_code_review_r3.md:88,152`; V28 Q1).
2. **[I] COORD:** annotate A03:88-98,274-282 as superseded (14 mismatches, §4) or task an owner to rewrite the documented CLI table? No A03/spec file was edited by V53.
3. **[I] COORD/I05:** who emits `terrain_new/schemas/v1.schema.json` (V11 G11) and the *complete* root `manifest.json` (G10), given N6 is absent and `--emit-root-manifest` is atlas-only?
4. **[I] COORD/I13:** with `validate_terrain_new.py` absent (N7 PENDING, I16:83), is `build_terrain_new_atlas.py --check` the only admissible pre-gate asset check, and who owns the validator?
5. **[I] Owner/COORD:** confirm the intended local cell-1024 output path outside `terrain_new` and whether any 1024 capture is in scope; V53 ran only the dry-run/check forms and makes no size-tier recommendation beyond the code's "local/uncommitted" label.
6. **[I] COORD:** should `--check` be moved *before* the write in I01/I02/I03/I05 so a failing check cannot emit files? (Currently only I04 suppresses write on `--check`.)
7. **[I] COORD:** SWARM_BOARD.md:145-147 has no I05/I15 report rows while tool files are present and I16/V42/V44 have landed; when is the board reconciled with the filesystem?

## 7. Honesty / scope statement

Exactly one file was written by V53: this report. No `.py`, `.gd`, shader, config, fixture, result JSON, PNG, `app/` file, git state or donor file was edited. **No Godot process was launched and no runner subcommand was executed.** The only tool invocations were `--help`, `--dry-run --check` (five donor tools) and `--check` (harness), plus dry-run probes with an `--out` inside the donor root (all exited 2 before any write) and the two expensive dry-run atlas tier checks. No write-mode command from §3 was executed by V53. Every claim carries `[O]/[D]/[I]/[U]` and a file:line or command citation; contested surfaces were re-read twice (`CHARTER.md:85-93`). No threshold was lowered, no assertion deleted, no green result fabricated, **no gate result claimed, and no donor-parity claim made**. **PORT APPROXIMATION / port-internal CLI evidence only; donor parity remains UNVERIFIED.**

## 8. Five-line summary

1. [O] Verified from `--help` + argparse source (two passes): only `decode_donor_cfg.py` writes on `--out` alone (`:808`); I02/I03/I04/I05 require `--write`/`--no-dry-run`; the harness writes its report on `--out` and has no `--dry-run`.
2. [O] I05 confirmed: `--out` alone does not write for the atlas (`:927`); `--cell 1024` under `terrain_new` fails `--check` (exit 1 observed) and is refused at write (`:844-846,955-958`); `--hires-local` writes under `terrain_new` are refused (`:946-948`).
3. [O] All six `--dry-run --check`/`--check` runs exit 0 (cfg 7/7+19/19, pattern_lib 50/0, masks 18/18, atlas `passed:true`, harness 36/36); five donor-root `--out` probes exit 2; harness `--dry-run` exits 2.
4. [D] A03's documented CLI has 14 concrete mismatches (invented `--pack/--cfg/--types/--only/--season`, `--cell` 256 vs 128, two absent tools, wrong filenames, `--check` semantics); V11 CR6 resolves only the filename aliases.
5. [U] Exact generation commands are supplied in §3 but were not run by V53; I03's output root moved to `terrain_new/lib`, N6/N7 are absent, and no parity claim is made.

## Appendix A — verbatim `--help` output (final sweep, 2026-11-26)

### A.1 `python variant3d\tools\decode_donor_cfg.py --help`

```
usage: decode_donor_cfg.py [-h] [--game GAME] [--out OUT] [--check]
                           [--dry-run]

I01 donor cfg decoder (read-only donor; dry-run default)

options:
  -h, --help   show this help message and exit
  --game GAME  donor install root, read only (default: C:\Games\Cossacks 3)
  --out OUT    output dir; writes only when given (default:
               variant3d/assets/terrain_new/cfg)
  --check      verify 7 donor SHA-256 + count checks against OBSERVED donor
               facts (19 global keys; F03 summary 20 is a recorded exception)
               + determinism; exit 0 only when all observed checks pass
  --dry-run    print plan and checks, write nothing (default when --out
               omitted)
```

### A.2 `python variant3d\tools\decode_pattern_lib.py --help`

```
usage: decode_pattern_lib.py [-h] [--game GAME] [--out OUT] [--check]
                             [--dry-run | --write]

Decode donor pattern.lib (plaintext CRLF section DB) into labelled JSON

options:
  -h, --help   show this help message and exit
  --game GAME  donor install root (read-only), default 'C:\\Games\\Cossacks 3'
  --out OUT    derived output directory, default
               C:\Users\Maxym.Oboyshev\Documents\Craft
               Anything\cossacks-3-3\variant3d\assets\terrain_new\lib
  --check      run the full validation suite; exit 1 on any FAIL
  --dry-run    print the emission plan only (DEFAULT)
  --write      actually write derived JSON under --out
```

### A.3 `python variant3d\tools\decode_donor_pattern.py --help`

```
usage: decode_donor_pattern.py [-h] [--game GAME] [--out OUT] [--dry-run |
                               --no-dry-run] [--check]

I02: decode donor data/pattern/*.pattern into derived JSON (dry-run default).

options:
  -h, --help            show this help message and exit
  --game GAME           read-only donor install root (default:
                        C:\Games\Cossacks 3)
  --out OUT             derived JSON output dir (default:
                        variant3d/assets/terrain_new/patterns/)
  --dry-run             print only; default
  --no-dry-run, --write
                        actually write derived JSON
  --check               run F01/F02/X05/D05/X12 validation battery; exit non-
                        zero on FAIL
```

### A.4 `python variant3d\tools\decode_donor_masks.py --help` (options block; long description abbreviated)

```
usage: decode_donor_masks.py [-h] [--game GAME] [--out OUT] [--check]
                             [--dry-run] [--write]

Decode ALL donor terrain masks into DERIVED height tiles + a labelled index.
I04 / TERRAIN-SWARM-2026-11-26. Donor is READ-ONLY; only derived PNG/JSON is
ever written. No donor TGA byte is copied into the repository, no donor binary
is executed, no visual-parity claim is made (CHARTER.md:26-30,41-44,125).
[…long F04/X19/A02 ground-truth paragraph and usage examples omitted…]

options:
  -h, --help   show this help message and exit
  --game GAME  donor install folder (default: $COSSACKS3_DIR or
               C:/Games/Cossacks 3)
  --out OUT    derived-asset output root (default:
               variant3d/assets/terrain_new/masks)
  --check      Python-only self-test against F04/X19 vectors; writes nothing
  --dry-run    explicit dry run (already the default); writes nothing
  --write      actually emit derived PNG/JSON (default is dry-run)
```

### A.5 `python variant3d\tools\build_terrain_new_atlas.py --help`

```
usage: build_terrain_new_atlas.py [-h] [--game GAME] [--out OUT] [--cell CELL]
                                  [--hires-local] [--check] [--dry-run]
                                  [--write] [--emit-root-manifest]

Commit-safe donor-indexed terrain atlas compiler (I05). DRY-RUN BY DEFAULT;
--write to emit; --game is read-only.

options:
  -h, --help            show this help message and exit
  --game GAME           donor install root; licence guard only, never read or
                        copied
  --out OUT             output directory (default
                        variant3d/assets/terrain_new/atlas)
  --cell CELL           cell size for the commit tier (default 128)
  --hires-local         force cell 1024, local UNCOMMITTED capture tier;
                        refuses writes under terrain_new
  --check               verify committed outputs, or the in-memory plan with
                        --dry-run
  --dry-run             explicit dry-run (already the default; writes nothing)
  --write               explicitly emit derived assets (mutually exclusive
                        with --dry-run)
  --emit-root-manifest  also write <out>/../manifest.json (atlas contribution
                        only)
```

### A.6 `python variant3d\tools\terrain_qa_harness.py --help`

```
usage: terrain_qa_harness.py [-h] [--dump-a DUMP_A] [--dump-b DUMP_B]
                             [--seed-manifest SEED_MANIFEST]
                             [--policy {advisory,red}] [--out OUT] [--check]

I13 QA harness driver (terrain_qa_report/1). Read-only donor, no Godot/runner
job, no parity claim, no threshold lowering.

options:
  -h, --help            show this help message and exit
  --dump-a DUMP_A       run-A --dump-map JSON (pinned seed/size)
  --dump-b DUMP_B       run-B --dump-map JSON (same pinned seed/size)
  --seed-manifest SEED_MANIFEST
                        pinned generation/capture key manifest JSON
  --policy {advisory,red}
                        advisory (default) or red (red requires a signed donor
                        spec)
  --out OUT             report JSON output path
  --check               Python-only self-test; no inputs, no files written
```

*End of V53 CLI reconciliation. Verified flags only; no asset writes, no Godot, no gate result, no donor-parity claim.*
