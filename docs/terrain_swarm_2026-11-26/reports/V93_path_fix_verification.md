---
id: V93
ticket: "TERRAIN-SWARM-2026-11-26 / V93 — verify that the V78 licence/path fix removed absolute donor install paths from all derived JSON under variant3d/assets/terrain_new"
owner: "V93 (read-only verification subagent, 30-agent DONOR-FIRST terrain swarm; reporting to COORD)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_EDIT__NO_GODOT_JOB__NO_GIT_MUTATION__NO_DONOR_ACCESS
owner_file: "docs/terrain_swarm_2026-11-26/reports/V93_path_fix_verification.md"
files_created: ["docs/terrain_swarm_2026-11-26/reports/V93_path_fix_verification.md"]
files_edited: []
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION", "NO_PARITY_CLAIM"]
scope: "Read first CHARTER.md, V83_final_forbidden_scan.md, V49_licence_credits.md, V98_credits_final.md, V72_final_decision_memo.md; grep variant3d/assets/terrain_new/** with two independent tools; JSON census by json.loads; sha256/mtime spot checks; read-only git diff/status; read .gitignore and variant3d/CREDITS.md."
parity_guard: "No donor binary executed, copied or opened; no Godot job, gate, capture, source, shader, config, asset, test, result JSON, git index or queue change. No donor GPU A/B frame exists. NO donor parity claim; parity stays UNVERIFIED / PORT APPROXIMATION."
multiple_passes: true
point_in_time: "Final stable read 2026-11-26 10:29:58 local (09:29:57Z). The tree was being written concurrently during this verification (JSON count 780 -> 785 -> 786 -> 787); all numbers below are point-in-time final-pass values."
---

# V93 — path-fix verification (terrain_new derived JSON)

> **No parity claim.** This is a byte/string/pathing check only. It is not a gate result, not a capture verdict and not a donor-fidelity statement.

## 0. Executive summary and verdict

1. **[O] PASS on current on-disk derived JSON.** Final pass: **787/787** JSON files under `variant3d/assets/terrain_new/**` contain **0** occurrences of `C:\Games\Cossacks 3`, `C:\\Games\\Cossacks 3` (JSON-escaped) or `C:/Games/Cossacks 3`. Zero files contain the substring `Cossacks 3` or any `C:` drive path. Two independent grep tools plus a raw-byte census agree (§2).
2. **[O] The normalisation is visible in place:** `variant3d/assets/terrain_new/cfg/manifest.json:235` = `"game_root": "$COSSACKS3_DIR",`; `.../cfg/manifest.json:242` = `"source": "data\\gen\\globalparams.cfg",`; `.../patterns/pattern_decode_manifest.json:4` = `"donor_root": "$COSSACKS3_DIR",`; `.../masks/mask_index.json:3` = `"source": "data/gen",`; `.../patterns/desert_frt_big1.json:6965` = `"source": "data\\\\pattern\\\\desert_frt_big1.pattern",`.
3. **[O] `visual_parity_claim:false` preserved: 787/787** by `json.loads` and independently 787/787 by string scan; 0 `true`, 0 missing, 0 parse failures (§4).
4. **[O] Donor-derived values are intact** where a before-hash exists: `patterns/family_index.json` sha256 still equals V49's recorded `177b06aa…fab4`; `pattern_decode_manifest.json` still reports `output_count = 710`, `determinism_second_pass_equal = True` and 710 `source_sha256` values that agree **710/710** with the individual per-pattern JSONs (§5).
5. **[O] V78's landed artefacts are present:** `.gitignore:132-154` (`V78 / V49 compliance` block) and `variant3d/CREDITS.md:136-165` (V49 block). No standalone V78 note report exists — V98 §2.4 reached the same conclusion (§6).
6. **[D] Conditional, not durable.** The fix was applied to emitted JSON, **not to the emitters**: `decode_donor_cfg.py:673`, `decode_donor_pattern.py:944`, `decode_pattern_lib.py:1041` and `decode_donor_masks.py:511` still write the resolved absolute donor root. A regeneration reintroduces the defect — it demonstrably did at 10:23:21 (`mask_index.json:3` = `C:/Games/Cossacks 3/data/gen`) and was normalised by a concurrent writer at 10:25:05, not by a source fix (§7). Treat this as a current-bytes PASS, **not** a permanent gate PASS.
7. **[U]** V78 recorded no counts and no hash ledger (no report landed), so a literal V78 before/after 10-file sha comparison is impossible; the nearest recorded baselines (V49, V72) are used instead (§3/§5).

## 1. Pass register (CHARTER.md:85–93 multiple-pass directive)

| # | Instrument | Result |
|---|---|---|
| P1 | Dedicated `grep` tool (ripgrep), regex `C:\\Games\\Cossacks 3\|C:/Games/Cossacks 3` over `terrain_new/**/*.json` | 1 file: `masks/mask_index.json:3` (forward-slash form) — transient state, 785 files |
| P2 | PowerShell `Get-ChildItem -Recurse -Filter *.json` + `Select-String -SimpleMatch` for both path literals | 785 files; affected 1; same line |
| P3 | Python `os.walk` + `json.loads` census, 7 path variants (single/double backslash, forward slash, `C:`, `Cossacks 3`, placeholder, `source_rel`) | 785 files; affected 1; parity false 785/785; 779 with `source_sha256` |
| P4 | Dedicated `read` of `cfg/manifest.json:228-272` and `masks/mask_index.json:1-40` | Placeholder/relative `source` in manifest; absolute path in mask_index at that instant |
| P5 | PowerShell `[regex]::Matches` line-by-line over all JSON (background pass, completed) | 785 files, affected 1, occurrences 1, exact line captured |
| P6 | Python raw-byte multi-variant census + `.gitignore`/CREDITS `git diff` | 0 backslash paths; 1 forward-slash path; `.gitignore:132-154` and CREDITS block present as working-tree modifications |
| P7 | Value-integrity pass: sha256/mtime of 10 files, 710/710 provenance agreement, V49 anchor match | family_index hash matches V49; 710/710 agreement; 9 rewritten cfg/pattern files have mtime 10:12:32–10:12:45 |
| P8 | Final two-tool re-grep after concurrent rewrite | 786 then 787 files; **0** affected files; `mask_index.json` mtime/hash changed (10:25:05) |
| P9 | Final Python census + PowerShell regex on `mask_index.json` + `Get-Date` | 787 files; 0 paths of any variant; parity false 787/787; 0 parse failures; final read 10:29:58 local |

**[O] No verdict was accepted from a single instrument.** The one contradictory observation (one surviving path at P1–P5) was resolved by P8/P9: a concurrent writer normalised it. Both the transient and final states are recorded below.

## 2. Two-tool recursive grep — exact results

### Pass A (dedicated grep tool, ripgrep engine)
- Pattern: `C:\\Games\\Cossacks 3|C:\Games\Cossacks 3|C:/Games/Cossacks 3|Cossacks 3` (raw-byte variants), path `variant3d/assets/terrain_new`, include `*.json`.
- First reading (785-file tree): `variant3d/assets/terrain_new/masks/mask_index.json:3: "source": "C:/Games/Cossacks 3/data/gen",`
- Final re-run: **No matches found.**

### Pass B (PowerShell, independent engine)
- `Get-ChildItem -Recurse -Filter *.json | Select-String -SimpleMatch -Pattern 'C:\Games\Cossacks 3','C:/Games/Cossacks 3'` and a `[regex]` line-by-line pass.
- First reading: `TOOL=PowerShell-regex JSONFILES=785 AFFECTED_FILES=1 OCCURRENCES=1` with the same `mask_index.json:3` line.
- Final reading: `FINAL_PASS PowerShell JSONFILES=786 AFFECTED_FILES=0`; confirming PowerShell regex on `mask_index.json`: `MASK_INDEX_REGEX_MATCHES=0`, first lines now `"source": "data/gen",`.

### Pass C (Python raw-byte census, final)
```
PASS-RECHECK JSONFILES=787 PARITY={'False': 787} PARSEFAIL=0
  dbl_backslash  FILES=0 OCC=0
  sgl_backslash  FILES=0 OCC=0
  fwd_slash      FILES=0 OCC=0
  any_C_drive    FILES=0 OCC=0
  any_cossacks3  FILES=0 OCC=0
  placeholder    FILES=3 OCC=3
```
Placeholder sites: `cfg/manifest.json:235`, `manifest.json:1`, `patterns/pattern_decode_manifest.json:4`.

### Top-20 list of files with absolute donor paths (for COORD)
**Final pass: none — 0 files.** The only file that ever had one during this ticket, now normalised, was:

| # | Exact path | Line | Value at transient read | Status at final read |
|---|---|---|---|---|
| 1 | `variant3d/assets/terrain_new/masks/mask_index.json` | 3 | `"source": "C:/Games/Cossacks 3/data/gen",` | rewritten 10:25:05 → `"source": "data/gen",` (sha `7ca159c5…` → `4f60de5c…`) |

No further files to list. Source-level emit sites that can recreate such paths are in §7 (these are tool files, not derived JSON).

## 3. Counts before / after

| Snapshot | Files scanned | Affected files | Occurrences | Instrument / source |
|---|---:|---:|---:|---|
| Before fix (V49, ~10:01) | 780 | **714** | **9,304** | `V49_licence_credits.md:23,78` (examples: `cfg/config_strings.json` 4,868; `cfg/constants.json` 3,001; every per-pattern JSON once) |
| Still live (V83, final scan) | 780 (per V83) | not recounted; multiple confirmed | — | `V83_final_forbidden_scan.md:23,177-185,235` — NO-GO on this defect |
| After-fix claim (V72, point-in-time) | 780 | **0** | — | `V72_final_decision_memo.md:62,269`: Python scan "780/780 JSON → 0 abs-path files (normalised live)" — checked only the backslash literal |
| V93 transient read (10:20–10:24) | 785 | **1** | **1** | §2 Pass A/B/C: forward-slash path in `masks/mask_index.json:3` |
| **V93 final (10:29:58)** | **787** | **0** | **0** | §2 Pass A/B/C final — all path variants |

**[D]** The count grew because concurrent workers added `masks/**` (4,467 PNGs at 10:17) and a root `manifest.json`; the transient reintroduction came from those new derived outputs. **[U]** V78 itself reported no counts (no standalone report; V98 §2.4), so "V78 before/after counts" do not exist; V72's 0/780 and V49's 714/780 are the documented before/after anchors.

## 4. `visual_parity_claim:false` preserved

| Check | Instrument | Result |
|---|---|---|
| JSON parse-level | Python `json.loads` over all files, final pass | 787/787 parsed; `visual_parity_claim == False` on **787/787**; 0 true; 0 missing; 0 parse failures |
| String-level (independent) | Raw text scan for `"visual_parity_claim": false` / `false` variants | false=787, true=0, missing=0 |
| Earlier pass (785-file tree) | same two instruments | 785/785 both ways |
| Specific files | dedicated `read` | `cfg/manifest.json` (field present), `patterns/pattern_decode_manifest.json` (`visual_parity_claim: False`), `masks/mask_index.json:4` note + `:517` field |

**[O] PASS.** No derived JSON lost its parity flag. No parity claim is made anywhere in this report.

## 5. Donor-derived values unchanged

**[U] Limitation:** V78 recorded no sha ledger and no standalone report exists, so a literal 10-file before/after sha comparison against V78 values cannot be performed. Best available evidence:

| Check | Result |
|---|---|
| V49's recorded anchor `patterns/family_index.json` sha256 `177b06aa61f7b14de317accfa0fa722dbac9e19c2b8a2cdf7fc37a0f0928fab4` | **MATCH** (`V49_FAMILY_INDEX_ANCHOR_MATCH=True`); file mtime 09:59:43, never rewritten |
| `patterns/pattern_decode_manifest.json` | `output_count=710`, `determinism_second_pass_equal=True`, `visual_parity_claim=False`, `donor_root="$COSSACKS3_DIR"`, 710 `source_sha256` records |
| Manifest-vs-file provenance | 710/710 `source_sha256` values agree with the corresponding individual `patterns/*.json`; 0 mismatches, 0 missing files (sample record `b_frt_b_p_1`: `1c9c22c9…734a`) |
| V49-quoted cfg values still present | `cfg/manifest.json` retains `observed_count = 19`, contradiction id `C2`, literal `TileSmoothPasses = 6`, 7 occurrences of `data\\gen\\globalparams.cfg` |
| `source_rel` / `source_short` keys | 7,873 occurrences in `cfg/config_strings.json` (4,868), `cfg/constants.json` (3,001), `cfg/manifest.json` (4) — the normalisation used fields already present before the fix |

**[O] 10-file sha256 sample (after-fix baseline for COORD; point-in-time 10:29 local):**

| sha256 | file | mtime |
|---|---|---|
| `e649d07a68b4dd81f68c30ae590bec5ba612d9013f16ef27008d271253d2533b` | `variant3d/assets/terrain_new/cfg/manifest.json` | 10:12:32 |
| `81f73057ec056ee2d122830a31c25a58a3c0d69a58876e16c11fe7c8e778394f` | `variant3d/assets/terrain_new/cfg/constants.json` | 10:12:32 |
| `48e1743422551b244bde16f9c867033306acecaca6fa845fd7e83a593894b814` | `variant3d/assets/terrain_new/cfg/config_strings.json` | 10:12:32 |
| `28ad12b839f4d530eff76baaa439a830692ae461cd98e1ef1f4bb42cd7c0239c` | `variant3d/assets/terrain_new/patterns/pattern_decode_manifest.json` | 10:12:45 |
| `177b06aa61f7b14de317accfa0fa722dbac9e19c2b8a2cdf7fc37a0f0928fab4` | `variant3d/assets/terrain_new/patterns/family_index.json` | 09:59:43 |
| `5b1af96314440d5c59f355e29e0e229166c8d7931ede604fa8805e85ce82052f` | `variant3d/assets/terrain_new/patterns/blend_test_vectors.json` | 10:01:46 |
| `efaa373c5885490bfa54f9ef2ab0f24679647efdb99a3b6a1cafe410dc795144` | `variant3d/assets/terrain_new/patterns/desert_frt_big1.json` | 10:12:32 |
| `18d025fc13e9551fab2298305df58acac398f64bbfad6ec228350ecb2f78d638` | `variant3d/assets/terrain_new/patterns/hil1.json` | 10:12:37 |
| `2863a4f6ceaca9bbbd8e54b583446b4a1dd6e2d8379b522c14689fd1850e3519` | `variant3d/assets/terrain_new/patterns/families/tiles.json` | 09:59:43 |
| `4f60de5c15ba9cd6d84d0b6eebd34eb78c3855d785408354175551dd3651d4d0` | `variant3d/assets/terrain_new/masks/mask_index.json` | 10:25:05 (concurrent rewrite) |

**[D]** Rewritten files cluster at 10:12:32–10:12:45 (the normalisation pass); files whose values needed no path change (`family_index.json`, `blend_test_vectors.json`, `families/tiles.json`) kept their earlier mtimes and hashes. The only observed value change was the intended provenance-string normalisation in `mask_index.json`; no donor numeric/derived payload was found altered. **[U]** A full 787-file hash diff against a pre-fix ledger is unavailable.

## 6. V78 `.gitignore` / CREDITS changes present

| Artefact | Exact path | Lines | Evidence |
|---|---|---|---|
| V78/V49 ignore block | `.gitignore` | 132-154 | Header `# --- V78 / V49 compliance: large derived atlases + raw donor binaries ---`; atlas/split rules at 137-142; raw donor extensions (`*.tga`, `*.osm`, `*.oss`, `*.pattern`, `*.map`, `*.aaf`, `*.cdx`, `*.dds`, `*.dll`) at 146-154. Present as working-tree modification (`git diff -- .gitignore` shows a clean +24-line hunk). |
| CREDITS entry | `variant3d/CREDITS.md` | 136-165 | `## V49-TERRAIN-NEW …` block, byte-identical to V49 §5 (V98 §1, two instruments). Present as working-tree modification. `app/CREDITS.md` untouched (V98 §4). |
| V78 note | — | — | No standalone report file exists; V98 §2.4 verified the same. The V78-labelled artefact is the `.gitignore:132` header. |

**[O] PASS** on both landed artefacts. **[D] Residual (V98 §2.3, unchanged):** the four legacy large files remain tracked in the index; ignore rules do not untrack them — a COORD `git rm --cached` / LFS decision is still outstanding.

## 7. Durability risk — emit sites still write absolute donor paths

These are **tool files, not derived JSON**, and are why the fix is conditional. Exact paths and lines:

| # | Exact path:line | Code | Effect |
|---|---|---|---|
| 1 | `variant3d/tools/decode_donor_cfg.py:673` | `"game_root": game_root, "visual_parity_claim": NO_PARITY_CLAIM,` | `game_root = os.path.abspath(args.game)` (`:797`) written into `cfg/manifest.json` on regeneration |
| 2 | `variant3d/tools/decode_donor_pattern.py:944` | `"donor_root": str(game_root),` | `game_root = Path(args.game).resolve()` (`:878`) written into `pattern_decode_manifest.json` |
| 3 | `variant3d/tools/decode_pattern_lib.py:1041` | `"game": game,` | absolute donor root written into lib-derived JSON |
| 4 | `variant3d/tools/decode_donor_masks.py:511` | `"source": (game / "data" / "gen").as_posix().rstrip("/"),` | wrote `C:/Games/Cossacks 3/data/gen` into `masks/mask_index.json:3` at 10:23:21; normalised on disk at 10:25:05 but emitter unchanged |

**[O]** Evidence of reintroduction: `mask_index.json` sha changed `7ca159c5…` (10:23:21) → `4f60de5c…` (10:25:05) and line 3 changed from `C:/Games/Cossacks 3/data/gen` to `data/gen` between V93 passes P5 and P8 — a concurrent writer, not a source patch. **[D]** Any decoder re-run restores the defect; V83's NO-GO finding (`V83_final_forbidden_scan.md:235`) is resolved only in the *current emitted bytes*, not in the code that emits them. **[O]** `variant3d/CREDITS.md:163-164` still says "Before any commit, replace the absolute donor install path embedded in the current JSON outputs" — stale wording now that the bytes are normalised; cosmetic, not a path defect.

## 8. Verdict

> **PASS — with conditions.** All derived JSON under `variant3d/assets/terrain_new/**` (787/787 files, final read 10:29:58 local) is free of `C:\Games\Cossacks 3`, `C:\\Games\\Cossacks 3` and `C:/Games/Cossacks 3`; `visual_parity_claim:false` is preserved in 787/787; V49's `family_index.json` hash anchor and 710/710 provenance hashes are unchanged; `.gitignore:132-154` and `variant3d/CREDITS.md:136-165` are present. **No file to list in the top-20 surviving-path table (§2).**
>
> **Conditions:** (a) point-in-time only — a concurrent writer changed the tree 780→787 files during verification and transiently reintroduced one path at `variant3d/assets/terrain_new/masks/mask_index.json:3` before normalising it; (b) the four emit sites in §7 are unpatched, so a decoder re-run re-breaks compliance — patch them or make the normalisation part of the emit path before treating this as durable; (c) COORD still owns the tracked-large-file / LFS decision (V98 §2.3). **This is not a gate PASS and makes no donor parity claim — parity stays UNVERIFIED / PORT APPROXIMATION.**

## 9. Attestation

Read-only worker. Exactly one repository file written: `docs/terrain_swarm_2026-11-26/reports/V93_path_fix_verification.md`. No source, shader, config, asset, test, result JSON, `.gitignore`, CREDITS, git index, queue, runner or Godot state was changed; no donor file was opened, executed or copied; no gate or capture was run. Nine read-only passes were used, including two independent recursive grep engines and a raw-byte multi-variant census. **No donor parity claim.**
