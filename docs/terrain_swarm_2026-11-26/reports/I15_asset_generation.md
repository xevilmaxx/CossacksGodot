---
id: I15
ticket: "TERRAIN-SWARM-2026-11-26 / I15 — run the decoders, generate terrain_new asset pack"
agent: "I15 (implementation/asset-generation worker, DONOR-FIRST terrain swarm 2026-11-26)"
date: 2026-11-26
status: DELIVERED__DERIVED_ASSETS_ONLY__NO_DONOR_WRITE__NO_GODOT__NO_GIT
owner_file: docs/terrain_swarm_2026-11-26/reports/I15_asset_generation.md
files_created:
  - docs/terrain_swarm_2026-11-26/reports/I15_asset_generation.md
  - variant3d/assets/terrain_new/** (generated derived assets only; tier census in §4)
files_edited: []
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION", NO_PARITY_CLAIM]
parity_guard: "No donor GPU A/B frame, donor binary execution, donor byte copy, Godot job, gate, capture or git operation. All outputs are derived JSON/PNG and every emitted JSON carries visual_parity_claim:false. No donor visual parity is claimed."
scope_guard: "Writes confined to variant3d/assets/terrain_new/** and this one report. Donor at C:\\Games\\Cossacks 3 was READ ONLY. Scratch logs/scripts are outside the repo in C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/i15/."
---

# I15 — decoder execution + `terrain_new` asset pack generation

## 0. Executive summary

1. **[O] Final pack:** `variant3d/assets/terrain_new/**` = **5,257 files / 364,646,949 bytes**: `atlas/` 8 files, `cfg/` 3, `lib/` 1, `masks/` 4,467, `patterns/` 777, root `manifest.json` 1. 787 JSON files (all `visual_parity_claim:false`) + 4,470 PNG files. Zero `.tga/.dds/.bmp/.exe` files. Zero absolute donor-install paths in any JSON.
2. **[O] Missing tiers closed** after COORD follow-up (V62 found only `cfg/` + `patterns/`): atlas (8 outputs, 2048×1024, cell 128), masks (4,466 derived height PNGs + index), `lib/pattern_lib_index.json` (1 file), and root `manifest.json` (X15 schema, deterministic `pack_id terrain_new_v1-b7984b3cb162cdf9`).
3. **[D] Determinism:** every tool was run twice with identical inputs; per-run SHA-256 snapshot digests matched exactly. Root manifest regenerated twice: identical SHA-256 `2a6a8290bde0743c7eb88b6b7e5eaea860b1079d5617a1af15ff5dca2268dfde`.
4. **[O] CLI correction applied:** only `decode_donor_cfg.py` writes from `--out` alone (`decode_donor_cfg.py:808`). `decode_pattern_lib.py`, `decode_donor_pattern.py`, `decode_donor_masks.py` and `build_terrain_new_atlas.py` are **dry-run by default** and need explicit `--write`/`--no-dry-run` (current lines: `decode_pattern_lib.py:1073-1076`, `decode_donor_pattern.py:864-867`, `decode_donor_masks.py:583-585`, `build_terrain_new_atlas.py:917-926`). Every exact command is in §2.
5. **[U] Coworker concurrency:** tool files were edited live by their owners during this run (mtimes 09:53–10:02, line numbers shifted). The root manifest records the **final** tool SHA-256s (§5). An old `decode_pattern_lib.py --check` failure (6 checks) was already fixed by I03 before the `lib/` tier run; I patched no tool. The absolute-donor-path scrub was already applied by another worker at 10:12:32; I did **not** duplicate it. **No donor parity claim.**

## 1. Method / evidence key

**[O]** literal command output, path or hash computed this pass. **[D]** deterministic consequence (two-run byte comparison, counts). **[I]** inference. **[U]** UNVERIFIED / cannot be established without donor A/B. `PORT APPROXIMATION` = port substitute. All logs and helper scripts are under `C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/i15/` (outside repo; not committed).

| # | Evidence | Fact |
|---|---|---|
| E1 | `docs/terrain_swarm_2026-11-26/CHARTER.md:26-44,66-94` | Donor read-only; labels mandatory; no parity claim; Windows `;` |
| E2 | `spec/11_ASSET_CONVERSION.md:8-18,40-55,61-73`; `reports/X15_asset_manifest_skeleton.md:17-23,44-83` | Single output root; dry-run default; parity false in every manifest; X15 root-manifest schema and pack-id algorithm |
| E3 | `reports/V11_ownership_ledger.md:93-131` | G1–G11 derived-asset ownership; single root `variant3d/assets/terrain_new/**` |
| E4 | temp logs `*_dryrun*.log`, `*_write*.log`, `*_snap*.json`, `census_final.json` | Counts, exit codes, per-run hashes (this pass) |
| E5 | `Get-FileHash -Algorithm SHA256` on the 5 tool files | Tool versions recorded in root manifest |
| E6 | `reports/V49_licence_credits.md:23,78,162` | Pre-existing finding: 714 JSON files embedded the absolute donor path; remedied by another worker before this report |

## 2. Exact commands executed (repo root, PowerShell `;`)

Dry-run / check pass (all exit codes recorded):

```powershell
python variant3d/tools/decode_donor_cfg.py --dry-run --check --out variant3d/assets/terrain_new/cfg
python variant3d/tools/decode_pattern_lib.py --dry-run --check --out variant3d/assets/terrain_new/patterns
python variant3d/tools/decode_donor_pattern.py --dry-run --check --out variant3d/assets/terrain_new/patterns
python variant3d/tools/build_terrain_new_atlas.py --dry-run --check --out variant3d/assets/terrain_new/atlas --cell 128
python variant3d/tools/build_terrain_new_atlas.py --dry-run --check --out variant3d/assets/terrain_new/atlas --cell 128   # re-run after COORD follow-up
python variant3d/tools/decode_donor_masks.py --dry-run --check --out variant3d/assets/terrain_new/masks
python variant3d/tools/decode_pattern_lib.py --dry-run --check --out variant3d/assets/terrain_new/lib
```

Write pass (each command run **twice**, consecutively, with SHA-256 snapshot after each):

```powershell
python variant3d/tools/decode_donor_cfg.py --out variant3d/assets/terrain_new/cfg
python variant3d/tools/decode_pattern_lib.py --out variant3d/assets/terrain_new/patterns --write
python variant3d/tools/decode_donor_pattern.py --out variant3d/assets/terrain_new/patterns --no-dry-run
python variant3d/tools/build_terrain_new_atlas.py --out variant3d/assets/terrain_new/atlas --cell 128 --write
python variant3d/tools/decode_donor_masks.py --out variant3d/assets/terrain_new/masks --write
python variant3d/tools/decode_pattern_lib.py --out variant3d/assets/terrain_new/lib --write
python C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\i15\build_root_manifest.py variant3d/assets/terrain_new
```

`--help` was read for all five tools before the write pass, per COORD correction. `--hires-local`/`--cell 1024` was **never** used (licence guard; 179 MB legacy atlas stays uncommitted).

## 3. Dry-run counts and checks [O]

| Tool | Dry-run output counts | Exit / check summary |
|---|---|---|
| `decode_donor_cfg.py` | `2997 constants + 4868 unverified lines`; 3 in-process determinism documents | exit 0; hashes **7/7 PASS**, counts **19/19 PASS**, determinism **PASS**; documented exception MP-1 (F03 headline 20 vs observed 19) preserved, not patched |
| `decode_donor_pattern.py` (9:45 version) | 710 pattern files; byte closure **710/710**; pipeline `9bc45639874b9eff…` | exit 0; **PASS 29 / FAIL 0**; later current-version re-run **PASS 30 / FAIL 0** |
| `decode_pattern_lib.py` (9:48 version, `patterns/` target) | 65 planned JSON docs (64 families + 5 indexes + validation) | **exit 1; PASS 42 / FAIL 6** — see §6 |
| `build_terrain_new_atlas.py` | `cell=128`, `resolution_tier=commit_default`, `outputs=8`, `named_cells=124`, `filled_cells=121`, `empty_cells=3`, `face_cells=36`, `block_pngs=112`, sentinels `[86,110,123]` | exit 0; `PLAN_CHECK passed=true` |
| `decode_donor_masks.py` | inventory 4,466 TGA = vanilla 1,331 + dlc5 1,856 + src 1,279 | exit 0; self-test **18/18 PASS**, `parity=UNVERIFIED`, zero writes |
| `decode_pattern_lib.py` (current, `lib/` target) | 1 planned doc `pattern_lib_index.json`, sha256 `a9fff8a1b7f5d35…` | exit 0; **PASS 50 / FAIL 0** |

## 4. Generated tiers — final census [O]

Aggregate SHA-256 = `sha256` of sorted `relative_path \t byte_count \t sha256` lines (helper `snapshot.py`). Counts are final on-disk bytes after all concurrent coworker edits.

| Tier | Files | Bytes | Aggregate SHA-256 |
|---|---:|---:|---|
| `atlas/` | 8 | 7,551,760 | `1e9abaa1d44e8eac4b59842c8a81d0a9a17323724a689ba40809cdcb14e2ca81` |
| `cfg/` | 3 | 3,575,402 | `6a74c858244627d939b3da74b912a5705af8fd2e0b09df527f1dc63e0a5c322b` |
| `lib/` | 1 | 55,784,815 | `1f76c71d35b30170a789d72dd70c6de5b197e06044f097b1b9b60f1230b5e797` |
| `masks/` | 4,467 | 52,757,581 | `a0dffc2039cd86e0a55fe83d2a40bddcf37821d7d816727456c470c84917eec9` |
| `patterns/` | 777 | 238,526,989 | `2e7687ba3d76d9a4c9774fa30ad5fd6626688b4be1719ac7747712bc35136cf6` |
| `manifest.json` | 1 | 6,450,422 | `2a6a8290bde0743c7eb88b6b7e5eaea860b1079d5617a1af15ff5dca2268dfde` |
| **TOTAL** | **5,257** | **364,646,949** | `2e2f5604e4c327e4eec24a61a374ec92497e45bd87e901b9ccb019b97ca4a8a6` |

Extensions: `.json` 787 files / 316,396,255 B; `.png` 4,470 files / 48,250,694 B. No `.tga/.dds/.bmp/.exe` in the output root. The 4 atlas PNGs include the 2048×1024 cell-128 atlas; no 179 MB legacy atlas was regenerated.

Root manifest: `schema=terrain_new/manifest/v1`, `pack_id=terrain_new_v1-b7984b3cb162cdf9`, 5256 entry tuples (root manifest excluded from its own counts), `visual_parity_claim:false`.

## 5. Determinism (two consecutive runs, byte-identical) [D]

| Tool / artifact | Snapshot SHA-256 after run 1 | Snapshot SHA-256 after run 2 | Result |
|---|---|---|---|
| `decode_donor_cfg.py` (tool `ABBF0571…`) | `8421ff5fe39b9749a18ef204f6849ba3d559988a01bd8d956ad770535f62ea10` | same | IDENTICAL (pre-scrub bytes; 3 files) |
| `decode_pattern_lib.py` → `patterns/` (I03 old version) | `f566d1917cefdb0723ab0bf8cb8f8a091051aa3c70e1600771b69569b56fca28` | same | IDENTICAL (65 files) |
| `decode_donor_pattern.py` → `patterns/` | `11036c8c727ded8b060e80c137085c65cd92356413151ba6eff347b1cd9dfcfd` | same | IDENTICAL (777 files; pipeline `9bc45639874b9eff…`, blend `5b1af96314440d5c…`, manifest `eb9a99733a3b3179…`) |
| `build_terrain_new_atlas.py` | `501e651a7e30cbabffacae1f22feddfb9e3f18b1eb76b74905d8fb4a1958e122` | same | IDENTICAL (8 files) |
| `decode_donor_masks.py` | `631aed42ffc30949013fc06a6c2182c5690c5708360759875214f25787cbdc47` | same | IDENTICAL (4,467 files at check time) |
| `decode_pattern_lib.py` → `lib/` | `20ff202d6cdca95e2325cdf39284a8a3488c4b7aaaea86b8d6df3acf89db93c74` | same | IDENTICAL (1 file) |
| root manifest generator | `2a6a8290bde0743c7eb88b6b7e5eaea860b1079d5617a1af15ff5dca2268dfde` | same | IDENTICAL |

**[O] Concurrency caveats:** (1) `mask_index.json` changed once **after** the two-run mask check (mtime 10:25:05; one file differs, file count and total bytes unchanged), so the final `masks/` aggregate in §4 differs from the two-run snapshot above; no tool was patched. (2) `decode_donor_pattern.py --check` printed blend/manifest hashes that varied across dry-runs while its owning worker edited the tool (`d3c591…` → `5b1af9…` → `27df80…`); the two **consecutive write runs** were byte-identical. (3) cfg/patterns were scrubbed by another worker at 10:12:32 after their two-run check; final tier aggregates in §4 are post-scrub.

Final tool SHA-256 (working-tree bytes, recorded in root manifest):

| Tool | SHA-256 |
|---|---|
| `decode_donor_cfg.py` | `abbf0571647f318e1d88f3b1032eb1e39ca887afa9c671d348338ef50d85ab0e` |
| `decode_donor_pattern.py` | `00c0591aae0aef23d661a8aa9aae33fa807b3ea9b5c97d857520fa0d407e6619` |
| `decode_pattern_lib.py` | `ddfb86885b7dbf82802a385abaf1bc9e0b51236eba95e73f85da501386840320` |
| `decode_donor_masks.py` | `667b71fb3940c26fb3cea1416c7b3c7e9a87b8d86a76f5bc3d5c164f5f4ebdaa` |
| `build_terrain_new_atlas.py` | `3a92d053a3e361001fc305f0dbd98681702ba756124566d4408bbcfda99904ff` |

## 6. Failures / refusals reported (no tool patched)

1. **[O] `decode_pattern_lib.py` old-version `--check` exit 1, 42 PASS / 6 FAIL** (dry-run on `patterns/`, tool mtime 09:48). Exact check rows and code locations:
   - `object_records_39780_nested` observed `0`, expected `39780` — `decode_pattern_lib.py:1002-1004` (first read `:945-947`).
   - `object_records_inline_3` observed `39783`, expected `3` — `:1005-1006` (first read `:948-949`). Root cause candidate: `parse_blocks` `:287-298` classifies every `[*] : struct.begin` record as `inline` even though donor lines (verified read-only at `pattern.lib:359-362`) are nested.
   - `distinct_base_names_235` observed `0`, expected `235` — `:1007-1009`; `mng_embeds_minegold`, `mni_embeds_mineiron`, `mnc_embeds_minecoal` all observed `[]` — `:1027-1033`. Root cause candidate: `build_object_doc:701-706` reads `record["BaseName"]["value"]`, but `frame_to_record:317-329` unwraps child-struct values to bare scalars.
   - **Owner: I03 (N3).** COORD please relay. The current tool (SHA `ddfb8688…`) passes **50 PASS / 0 FAIL**; no patch by I15.
2. **[O] Write-flag mismatch (not a tool failure):** `--out` alone does not emit for `decode_pattern_lib.py` (`--write` needed, `:1073-1076`), `decode_donor_pattern.py` (`--no-dry-run`/`--write`, `:864-867`), `decode_donor_masks.py` (`--write`, `:583-585`), `build_terrain_new_atlas.py` (`--write`, `:917-926`). `decode_donor_cfg.py:808` writes from `--out` alone. Corrected commands used; see §2.
3. **[O] Previous ticket's `decode_donor_masks.py` gap is closed:** the tool now exists (28,207 B, tool SHA `667b71fb…`), `--check` 18/18 PASS; it was skipped only in the first ticket, then executed after COORD follow-up.
4. **[O] No `schemas/v1.schema.json`** was generated. No tool owns it and COORD's follow-up delegated only the root manifest; left as an explicit gap for COORD (X15 G11 / spec/11 §11.4).
5. **[U] No donor parity claim:** no donor GPU A/B frame exists. All labels remain `UNVERIFIED` / `PORT APPROXIMATION` where the tools emit them.

## 7. Compliance verification [O]

| Check | Result | Evidence |
|---|---|---|
| (a) every emitted path under `terrain_new` | PASS | `os.walk` root fixed to `variant3d/assets/terrain_new`; all 5,257 relative paths are under it; output guards in tools refused donor-root targets |
| (b) no donor binary / raw TGA/DDS copied | PASS | extension census `.tga=.dds=.bmp=.exe = 0`; only `.json` and `.png` present; donor read-only throughout |
| (c) every emitted JSON `visual_parity_claim:false` | PASS | 787/787 JSON parsed; `json_parity_false=787`, `missing_or_bad=0`, `true=[]` |
| (d) two consecutive runs byte-identical | PASS | §5 table (with concurrency caveats recorded) |
| (e) total bytes / file counts | PASS | §4 table; 5,257 files / 364,646,949 B |
| absolute donor path removed | PASS | `files_with_abs_donor_path=0`, `occurrences=0`; e.g. `cfg/manifest.json:235` now `"game_root": "$COSSACKS3_DIR"`; V49 report `:23,:78` documents the original defect |
| scrub ownership / no duplicate | OBSERVED | No `V78` report or scrub tool exists in `docs/terrain_swarm_2026-11-26/reports/` or `variant3d/tools/` at this read; the scrub was already applied in place to `variant3d/assets/terrain_new/**` at 10:12:32 by another worker. **I15 did not scrub any file.** Path of I15's read-only census helper: `C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/i15/census.py`; manifest helper: `…/i15/build_root_manifest.py` |

## 8. Handoff (5 lines)

1. **Verdict:** generated all five tiers + root manifest: 5,257 files / 364,646,949 B under `variant3d/assets/terrain_new/**`; 787/787 JSON carry `visual_parity_claim:false`; zero donor binaries/raw TGA/DDS.
2. **Determinism:** every tool run twice with identical per-run snapshot digests; root manifest regenerated byte-identical, `pack_id terrain_new_v1-b7984b3cb162cdf9`, SHA `2a6a8290bde0743c7eb88b6b7e5eaea860b1079d5617a1af15ff5dca2268dfde`.
3. **Flags:** write semantics corrected per `--help` (`--write` / `--no-dry-run`); old `decode_pattern_lib.py --check` 6 FAIL reported with file:line to COORD/I03, current tool 50/50 PASS; no tool patched.
4. **Caveats:** tool files edited live by owners; one `mask_index.json` rewrite after the two-run mask check; absolute-donor-path scrub already done by another worker (not duplicated); `schemas/v1.schema.json` still absent (COORD decision).
5. **Parity:** none — no donor GPU A/B frame, no donor binary executed, no gate/capture/git/Godot touched; parity stays **UNVERIFIED** / PORT APPROXIMATION.

*End of I15 report. Exactly one repo report written plus regenerated derived assets; no source, shader, config, test, git, donor or `app/` state changed.*
