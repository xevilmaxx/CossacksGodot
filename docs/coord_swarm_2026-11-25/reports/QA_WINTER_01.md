---
id: QA-WINTER-01
task: "Independent second-agent verification of the Winter atlas artifacts"
agent: "QA-WINTER-01 (read-only verification worker, second agent)"
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB__NO_GIT_CHANGE__NO_DONOR_ACCESS
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
output: "docs/coord_swarm_2026-11-25/reports/QA_WINTER_01.md"
scope: "One report only. Independent re-read of the delivered Winter PNG, manifest and alias dictionary with Python 3.14 / Pillow and read-only git queries. No artifact regeneration, no use of SP-4's build tool or --check, no code/asset/config/test edit, no Godot runner job, no git mutation, no donor access."
verification_passes: 1
labels: [observed, derived, inferred, UNVERIFIED]
visual_parity_claim: false
no_repo_change_except_this_report: true
---

# QA-WINTER-01 — Independent verification of the Winter atlas

## 0. Discipline and label key

- **observed** — literal bytes/hashes/counts read this lane from disk, or literal output of a read-only command.
- **derived** — deterministic arithmetic/comparison over observed values (contiguity, set membership, byte equality of a crop vs a source).
- **inferred** — interpretation with a stated caveat; no runtime execution backs it.
- **UNVERIFIED** — cannot be proven from readable data (remote LFS availability, runtime season binding, final naming, any GPU result).

**No visual-parity claim.** No donor file was opened, no GPU A/B and no capture were run. Every statement below is about file bytes, schema and on-disk names only.

Independence: all measurements were made with fresh Python/Pillow code written to `%LOCALAPPDATA%\Temp\opencode\` (outside the repo). `build_winter_atlas.py`, its `--check` mode and SP-4's own result values were **not** used as verification input; SP-4's report was read as a claim to be tested.

## 1. Sources

| # | Source | Role / label |
|---|---|---|
| S1 | `docs/coord_swarm_2026-11-25/reports/SP_04_winter_atlas.md` | Builder's claims to test independently (observed doc) |
| S2 | `docs/coord_swarm_2026-11-25/reports/SP_02_winter_dictionary.md` | 124-entry alias dictionary spec (observed doc) |
| S3 | `docs/coord_swarm_2026-11-25/reports/LFS_PLAN_01.md` | Old-pointer / silent-fallback claim to re-check (observed doc) |
| S4 | `docs/coord_swarm_2026-11-25/reports/ATLAS_01_transport.md` | Summer baseline sizes/hashes/schema (observed doc) |
| S5 | `variant3d/assets/terrain/atlas/tile_index_atlas.manifest.json` | **Summer manifest read directly** (read-only; 60,677 B) |
| S6 | `variant3d/assets/terrain/atlas/tile_index_atlas_winter.png` + `.manifest.json` | Artifacts under test (read directly) |
| S7 | `variant3d/assets/terrain/atlas/winter_aliases.json` | SP-2 data consumed by the build (read directly) |
| S8 | `variant3d/assets/terrain/blocks/*.png` | Source art: existence, size, SHA-256 and pixel bytes (read directly) |
| S9 | read-only `git ls-files -s`, `git cat-file -s`, `git show :path`, `git status --porcelain` | Current pointer/index state (observed; no git mutation) |
| S10 | `variant3d/scripts/world3d_terrain.gd`, `variant3d/tests/t_season_overlay.gd` | Path constants, read only (observed filenames) |

Measured artifact hashes (SHA-256 of working-tree bytes, 4 MiB chunked; **observed**):

| File | Bytes | SHA-256 |
|---|---:|---|
| `tile_index_atlas_winter.png` | 124,463,306 | `5d0dd8f3042ec13d6989b357ffbc007dbd439237b8e7cfffe7bb98f18e3cbadb` |
| `tile_index_atlas_winter.manifest.json` | 79,837 | `ef4ab26e35650c20d57517974fbb4715ffae5252a0175c2218151195f95afba0` |
| `winter_aliases.json` | 81,335 | `ece3d51b01fe3a2b2988e3561979ecdbc6c901cf66621df96ff43058752b6b1d` |
| `tile_index_atlas.png` (Summer, control) | 179,912,941 | `a1f123a1072e07eb28f416a9d8541aae5ffd23891a1836904b3cb05eb84dcfbd` |
| `tile_index_atlas.manifest.json` (Summer, control) | 60,677 | `112e9ff5ed632dd36bb526a7b7fe2b19083d251745cf0c2705f551f7f3583bda` |

## 2. Independent verification table

| # | Criterion | Independent method | Observed result | Verdict | Labels |
|---|---|---|---|---|---|
| C1 | PNG dimensions and SHA | Pillow `Image.open` + `verify()` + reopen; chunked SHA-256 | `(16384, 8192)`, mode `RGBA`, format `PNG`, integrity OK; 124,463,306 B; SHA `5d0dd8f3…3badb` — exactly S1 §5. Pillow emitted a benign `DecompressionBombWarning` (134,217,728 px), not a decode failure. | **CONFIRMED** | observed |
| C2 | Manifest JSON validity; 124 contiguous indices | `json.load`; list equality with `range(124)` | Both manifests and the alias JSON parse. Winter `layout` = 124 rows, indices `0…123` contiguous, 124 distinct; Summer `layout` = 124 rows, same; aliases `entries` = 124, `0…123` contiguous. Names equal across Winter `layout` and aliases. Winter `kind` histogram `DIRECT 35 / FACE_BASE_REUSE 86 / EMPTY 3`; status `OK 121` + 3 explicit EMPTY text. | **CONFIRMED** | observed, derived |
| C3 | Each of the 124 entries' source PNG exists on disk | `os.path.exists` over alias `entries[].source_png` and non-null manifest `layout[].source_png` | Alias dictionary: **124/124** exist, 0 missing. Manifest: **121/121** non-null `source_png` exist, 0 missing; the other 3 rows (86/110/123) deliberately have `source_png: null`, `kind: EMPTY`. The three alias carriers point at `winter0.png`/`winter1.png`/`winter1.png` with `shared_alpha: true` but are **not** manifest sources. | **CONFIRMED** (alias-side 124/124; manifest-side 121/121 non-null) | observed, derived |
| C4 | Three empty cells truly empty/transparent | Pillow `crop` of each declared `cell_px`, `getextrema()` and raw `tobytes()` | idx 86 `[6144,5120,1024,1024]`, idx 110 `[14336,6144,1024,1024]`, idx 123 `[11264,7168,1024,1024]`: all four channel extrema `(0,0)`, and every byte of each 4,194,304-byte crop is zero. Truly transparent. | **CONFIRMED** | observed, derived |
| C5 | The 4 unaliased winter PNGs were not packed | Set membership of the 35 distinct packed source names; membership in `unused_shipped_blocks` | `winter18.png`, `winter23.png`, `winter24.png`, `winter26.png` all exist in `blocks/`; **0/4** appear in the packed set; **4/4** appear in Winter `unused_shipped_blocks` (77 entries total = 4 winter + 73 summer-only; Summer has 27). Distinct packed sources = 35 (23 `winterN` + 12 `desertN`). | **CONFIRMED** | observed, derived |
| C6 | 12 desert-reused entries point to real desert PNGs | Manifest rows containing `desert`, existence check, alias cross-reference | Exactly 12 rows, indices **111–122** → `desert1.png…desert12.png`, 12/12 exist; alias `kind` = `DESERT_REUSE` and alias `source_png` equals the manifest value for all 12. | **CONFIRMED** | observed, derived |
| C7 | Manifest schema matches Summer | Compare top-level key lists/order, `atlas` keys, layout-key union, `masks`, `shipped_tileblock`, counts | Top-level: 11 keys, **identical list and order** in both. `atlas` keys identical; blocks equal except `file` and `upscaled_sources` (Winter `[]` vs Summer 6 entries). Layout-key union equal **except** Summer's extra `upscale_label` on its 6 upscaled rows — Winter has none, matching S1 §3. `masks` block byte-for-byte equal as JSON; `shipped_tileblock` equal; `count` 124 in both `index_dictionary` blocks. Differing content (not schema): `generator`, `labels`, `index_dictionary.file/lines/donor_evidence`, `unused_note`. Note: S1 §3 prose says "13 top-level keys"; independently observed count is **11 in both** — a prose figure not reproduced here, with no effect on schema identity. | **CONFIRMED** (schema); prose count discrepancy noted | observed, derived |
| C8 | Spot-check ≥8 cells against declared source PNG | Independent Pillow `crop` → `tobytes()` vs `Image.open(source).convert("RGBA").tobytes()` | **12 cells checked** (indices 0, 1, 9, 21, 36, 86, 99, 105, 110, 111, 122, 123). All 9 filled non-desert/winter cells and both desert cells: RGBA byte-identical, RGB byte-identical, alpha extrema `(255,255)`; all sources are 1024×1024 mode `RGB`. The 3 empty cells are all-zero. See §3. | **CONFIRMED** (12/12; exceeds ≥8) | observed, derived |
| C9 | Path-name mismatch status on disk | Read constants; recursive glob for swapped-name files; list on-disk atlas filenames | Split state: renderer constant aligned, test constant not. **Observed filenames only in §4.** No `tile_index_winter_atlas*` file exists anywhere in the repo (glob: 0 matches). | **PARTIAL** | observed |
| C10 | S3's "index still holds the old pointer" / silent Summer-art fallback context | Read-only `git ls-files -s`, `git cat-file -s`, `git show :path`, `git status --porcelain` | Current index blob `cda2423a6ef6f10984add3636f18fc8d74cdd045` is a **134-byte** LFS pointer to `oid sha256:5d0dd8f3042ec13d6989b357ffbc007dbd439237b8e7cfffe7bb98f18e3cbadb`, `size 124463306`; `HEAD:` shows the same new pointer. Both Winter paths are tracked and clean. The old `6b251045…` / 74,986,953 pointer reported by S3 is **no longer present**. Runtime fallback behaviour and remote object availability remain UNVERIFIED. | **REFUTED** (as to current pointer state) | observed; runtime UNVERIFIED |

Supplementary independent checks (not in SP-4's published checklist): all **121** manifest `source_sha256` values match the SHA-256 of the on-disk source file (0 mismatches), and all **121** declared `source_size` values match Pillow's measured `(1024,1024)` (0 mismatches). **observed, derived.**

## 3. Pixel spot-check table (independent code)

Cell bytes = declared 1024×1024 crop of `tile_index_atlas_winter.png` (4,194,304 B RGBA). "RGBA match" = byte-for-byte equality with `convert("RGBA")` of the declared source PNG.

| idx | Declared source | Source mode/size | RGBA bytes match | RGB bytes match | Alpha extrema | Result |
|---:|---|---|---|---|---|---|
| 0 | `winter10.png` | RGB 1024×1024 | True | True | (255,255) | PASS |
| 1 | `winter9.png` | RGB 1024×1024 | True | True | (255,255) | PASS |
| 9 | `winter0.png` | RGB 1024×1024 | True | True | (255,255) | PASS |
| 21 | `winter22.png` | RGB 1024×1024 | True | True | (255,255) | PASS |
| 36 | `winter25.png` | RGB 1024×1024 | True | True | (255,255) | PASS |
| 86 | `null` (EMPTY) | — | all-zero bytes | all-zero bytes | (0,0) | PASS |
| 99 | `winter10.png` | RGB 1024×1024 | True | True | (255,255) | PASS |
| 105 | `winter25.png` | RGB 1024×1024 | True | True | (255,255) | PASS |
| 110 | `null` (EMPTY) | — | all-zero bytes | all-zero bytes | (0,0) | PASS |
| 111 | `desert1.png` | RGB 1024×1024 | True | True | (255,255) | PASS |
| 122 | `desert12.png` | RGB 1024×1024 | True | True | (255,255) | PASS |
| 123 | `null` (EMPTY) | — | all-zero bytes | all-zero bytes | (0,0) | PASS |

9 filled cells + 3 empty cells = **12/12 PASS**. This verifies the declared source→cell byte mapping only; it says nothing about how the atlas looks when rendered.

## 4. Path-name mismatch — observed filenames only

**Renderer:** `variant3d/scripts/world3d_terrain.gd:269-273` now declares
`WINTER_MANIFEST_PATH := "res://assets/terrain/atlas/tile_index_atlas_winter.manifest.json"` and
`WINTER_ATLAS_PATH := "res://assets/terrain/atlas/tile_index_atlas_winter.png"`; lines 269–270 carry a comment that the planned `tile_index_winter_atlas.*` name was corrected here. **Observed: aligned with the delivered artifact names.**

**Test:** `variant3d/tests/t_season_overlay.gd:59-60` still declares
`WINTER_MANIFEST_PATH := "res://assets/terrain/atlas/tile_index_winter_atlas.manifest.json"` and
`WINTER_ATLAS_PATH := "res://assets/terrain/atlas/tile_index_winter_atlas.png"`. **Observed: not aligned.**

**On disk** in `variant3d/assets/terrain/atlas/`, winter-related filenames observed:
`tile_index_atlas_winter.png` (124,463,306 B), `tile_index_atlas_winter.manifest.json` (79,837 B), `tile_index_atlas_winter.png.import` (993 B). A recursive `**/tile_index_winter_atlas*` glob returned **0 files**.

No constant or filename was changed by this lane; whether alignment is completed later is **UNVERIFIED**.

## 5. LFS pointer context (read-only re-check)

| Fact | Exact evidence | Label |
|---|---|---|
| Index entry for Winter PNG | `100644 cda2423a6ef6f10984add3636f18fc8d74cdd045 0 variant3d/assets/terrain/atlas/tile_index_atlas_winter.png` | observed |
| Pointer blob size | `git cat-file -s cda2423a6ef6f10984add3636f18fc8d74cdd045` → `134` | observed |
| Index/HEAD pointer text | `version https://git-lfs.github.com/spec/v1` / `oid sha256:5d0dd8f3042ec13d6989b357ffbc007dbd439237b8e7cfffe7bb98f18e3cbadb` / `size 124463306` | observed |
| Manifest tracked | `100644 20d13b247820ecca6b33173550de8477b40ef85e 0 variant3d/assets/terrain/atlas/tile_index_atlas_winter.manifest.json` | observed |
| Both paths clean | `git status --porcelain -- <png> <manifest>` → empty output | observed |
| Other working-tree changes | ` M docs/.../README.md`, ` M docs/.../SWARM_BOARD.md`, `?? docs/.../reports/AUDIO_SEL_02.md` — unrelated to the Winter atlas | observed |

So the specific precondition behind S3's warning (a stale old-OID pointer at the Winter path) is **not present now**. This does **not** prove a fresh clone will smudge the object, nor that the renderer binds it: both are **UNVERIFIED** (no network operation, no runner job).

## 6. Verdict

| Criterion | Verdict | Exact basis |
|---|---|---|
| C1 PNG dimensions + SHA | **CONFIRMED** | 16384×8192 RGBA; 124,463,306 B; `5d0dd8f3042ec13d6989b357ffbc007dbd439237b8e7cfffe7bb98f18e3cbadb` |
| C2 Valid JSON, 124 contiguous indices | **CONFIRMED** | 124 rows `0…123` in each of 3 JSON files; kinds 35/86/3 |
| C3 All 124 entries' source PNG exist | **CONFIRMED** | aliases 124/124; manifest 121/121 non-null, 3 null by design |
| C4 Three empty cells transparent | **CONFIRMED** | indices 86/110/123, 4,194,304 zero bytes each |
| C5 Four unaliased winter PNGs not packed | **CONFIRMED** | 0/4 packed, 4/4 in 77-entry unused list |
| C6 Twelve desert-reused entries real | **CONFIRMED** | 12/12 `desert1.png…desert12.png` exist at indices 111–122 |
| C7 Schema matches Summer | **CONFIRMED** | 11 identical top-level keys; only `upscale_label` extra in Summer layout union; masks/shipped_tileblock equal |
| C8 Pixel spot-check ≥8 cells | **CONFIRMED** | 12/12 cells byte-equal (9 filled + 3 empty) |
| C9 Path-name mismatch status | **PARTIAL** | renderer aligned at `world3d_terrain.gd:272-273`; test not aligned at `t_season_overlay.gd:59-60`; 0 swapped-name files on disk |
| C10 Old-pointer / silent-fallback context | **REFUTED** (current state) | HEAD+index pointer is new OID `5d0dd8f3…`, 134 B, both paths tracked and clean; runtime/remote still UNVERIFIED |

**Overall:** every artifact-level criterion is **CONFIRMED** with exact values above. The only non-confirmed items are the test-constant alignment (**PARTIAL**) and the now-stale old-pointer warning (**REFUTED** as to current git state). **No visual-parity claim is made or implied.**

## 7. Open questions (UNVERIFIED — do not guess)

1. Does the configured GitHub LFS endpoint actually hold `5d0dd8f304…`? Local cache and a correct in-tree pointer are proven; no network probe was run.
2. Will a real season capture bind `tile_index_atlas_winter.*` and record `stats["atlas_mode"]`, loaded mode, grid and texture size? No runner job was launched here (SP-8 scope).
3. Will `t_season_overlay.gd:59-60` be aligned to `tile_index_atlas_winter.*`, or will the artifacts be renamed? Only current filenames were observed.
4. What produced the 993-B `tile_index_atlas_winter.png.import` sidecar? Observed on disk; provenance not investigated and not in S1's output list.
5. Why does S1 §3 state "13 top-level keys" when both manifests have 11? Prose discrepancy with no functional effect; cause not investigated.
6. Provenance of the superseded `6b251045…` (74,986,953 B) object remains UNVERIFIED; not re-investigated here.
7. Any GPU pixel identity, donor parity or visual result: **UNVERIFIED**, explicitly out of scope.

## 8. Summary

Independent re-reading confirms the delivered Winter atlas is internally consistent with its own manifest, the alias dictionary and the Summer schema: a 124,463,306-B / `5d0dd8f3…` 16384×8192 RGBA PNG; 124 contiguous indices; all declared sources present and hash-correct; 3 genuinely transparent empty cells; the 4 unaliased winter PNGs unused; 12 desert reuses intact; identical schema to Summer; and 12/12 independently spot-checked cells byte-identical to their declared sources. The git pointer at the Winter path now names the **new** OID, contradicting the stale-pointer precondition recorded in LFS-PLAN-01. Renderer constants match the on-disk names; the season test constants do not.

**No file was edited by this verification except this report itself.** No code, asset, config, test, harness or git change; no runner job; no donor access; no visual-parity claim.

*End of QA-WINTER-01. One report written; read-only second-agent verification only.*
