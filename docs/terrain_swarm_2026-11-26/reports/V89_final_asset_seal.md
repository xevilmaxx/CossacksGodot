---
id: V89
ticket: "TERRAIN-SWARM-2026-11-26 / V89 — FINAL asset-pack seal verification after I15/V78 (read-only)"
agent: "V89 (read-only audit subagent, 30-agent DONOR-FIRST terrain swarm)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_EDIT__NO_ASSET_GENERATION__NO_GODOT_JOB__NO_GATE__NO_PARITY_CLAIM
owner_file: docs/terrain_swarm_2026-11-26/reports/V89_final_asset_seal.md
files_created: [docs/terrain_swarm_2026-11-26/reports/V89_final_asset_seal.md]
files_edited: []
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION", "NO_PARITY_CLAIM"]
parity_guard: "No donor binary, donor byte, donor GPU frame, Godot process, runner job, gate or capture was used by V89. No donor visual parity claim is made; parity stays UNVERIFIED (CHARTER.md:43-44,125)."
scope_guard: "Read-only: file reads, grep, PowerShell Get-ChildItem/Test-Path/Get-FileHash/git status read-only, Python os.walk/json/hashlib/re on variant3d/assets/terrain_new/** plus consumer file:line reads. Scratch probe scripts were confined to C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/ (outside the repo). No asset, source, shader, config, test, manifest, queue, git index or app/ byte was changed."
multiple_passes: true
snapshot: "Authoritative snapshot at 2026-11-26T10:30:41 local: 5257 files / 364,646,949 B, including the root manifest.json (6,450,422 B) that landed during this audit. The tree was written concurrently (780 → 788 → 5255 → 5256 → 5257 files); see §0. Re-read immediately before COORD acts."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
verdict: "NO-GO for asset readiness (I09 feed path + schema + stability still open) — see §7. Root manifest now landed and passes X15 visible checks. No parity claim."
---

# V89 — FINAL asset-pack seal verification

## 0. Multiple-pass log (owner directive, CHARTER.md:85-93)

| Pass | Instrument | Result | Effect |
|---|---|---|---|
| A1 | PowerShell `Get-ChildItem -LiteralPath variant3d\assets\terrain_new -File -Recurse`, per-tier + extension grouping | **780 files / 242,316,351 B**; only `cfg` (3 / 3,756,649) + `patterns` (777 / 238,559,702); `ROOT_FILES=0`; 100% `.json` | Baseline (matches V62 §5 / V49 §2.2 point-in-time) |
| B1 | Independent Python `os.walk` + `os.path.getsize`, `/`-normalised | **788 files / 249,654,151 B**; `atlas/` appeared (8 / 7,551,760); cfg/patterns shrank by 213,960 B | **[O/D] Live concurrent writer between A1 and B1** — not a hash contradiction |
| A2 | Re-run PowerShell count | **788 / 249,654,151**; atlas detail: summer PNG 4,211,707 B, winter PNG 2,738,328 B, alpha 55,242 B, alphavert 167,954 B, summer manifest 149,449 B, winter manifest 207,718 B, aliases 377/20,985 B | A2 now agrees with B1 |
| B2 | Python explicit presence sweep | root `manifest.json` ABSENT; `schemas/v1.schema.json` ABSENT; atlas pair PRESENT; both lib-index paths ABSENT; `masks/mask_index.json` ABSENT | Pre-mask tier state |
| A3 | PowerShell explicit `Test-Path` sweep | **5255 files / 302,411,732 B**; `masks/` appeared (4,467 / 52,757,581); `masks/mask_index.json` now PRESENT; root manifest still ABSENT | Second concurrent landing |
| B3 | Python `os.walk` census (Python pass `#3`) | **5255 / 302,411,732**; tiers atlas 8/7,551,760 · cfg 3/3,575,402 · masks 4,467/52,757,581 · patterns 777/238,526,989 | Independent agreement |
| A4 | PowerShell `Get-ChildItem` + `git status --short` (read-only) + `git ls-files` | **5256 / 358,196,547**; `lib/` appeared (1 / 55,784,815); `git ls-files -- terrain_new/**` = **0 tracked** | Third concurrent landing; whole tier untracked |
| B4 | Python census + explicit presence | **5256 / 358,196,547**; `lib/pattern_lib_index.json` PRESENT, `patterns/pattern_lib_index.json` still ABSENT | Path mismatch confirmed (§5) |
| A5 (then-final) | PowerShell authoritative pass | **5256 / 358,196,527**; masks bytes fell by 20 B (path normalisation); `ROOT_FILES=0`; root manifest ABSENT; schema ABSENT; `patterns/` lib index ABSENT; `lib/` lib index PRESENT | Authoritative PowerShell count at that moment |
| B5 (then-final) | Python `os.walk` (STAMP=2026-11-26T10:27:39) | **5256 / 358,196,527**; identical per-tier numbers to A5 | **A5 = B5 exactly; snapshot accepted at that moment** |
| A6/B6 | Python `json.load` + `hashlib` + regex sweep over all then-current 786 JSONs | 786 parse, 0 parse failures, **786/786 `visual_parity_claim:false`**, 0 missing, **0 absolute donor paths** | Integrity seal at that snapshot (superseded by I2's 787-JSON sweep) |
| H1/H2 | PowerShell `Get-FileHash -Algorithm SHA256` vs Python `hashlib` on the 4 atlas PNGs | Byte-identical hashes from both instruments | §4 sample verification |
| I1 | **Post-report-write** PowerShell `Get-ChildItem` re-check | **5257 / 364,646,949, ROOT_FILES=1** — the root `manifest.json` (6,450,422 B) landed *after* the first draft was written | Fourth landing; forced an update of this same report |
| I2 | Python `os.walk` + `json.load` census at 2026-11-26T10:30:41 | **5257 / 364,646,949**; `<root>` 1/6,450,422, atlas 8/7,551,760, cfg 3/3,575,402, lib 1/55,784,815, masks 4,467/52,757,561, patterns 777/238,526,989; **787 JSON / 0 parse failures / 787 `visual_parity_claim:false` / 0 absolute paths** | A7 = I2 exactly; snapshot accepted |
| I3 | Python `json.load` inspection of the new root manifest | All 19 X15 §2.1 keys present; `schema=terrain_new/manifest/v1`, `pack_id=terrain_new_v1-b7984b3cb162cdf9`, `visual_parity_claim:false`, 5256 ordered entry tuples (8/8 keys each, sorted by `(source,offset,output)`), `counts.by_top` equals the independent census exactly | §3 root-manifest verdict flipped FAIL → PASS |

**[O] No anomaly was accepted from one pass.** Four real landings (atlas, masks, lib, root manifest) and one 20-byte normalisation were caught only because both instruments were run repeatedly — including a *post-write* re-check that forced an update to this same report. A single-pass "seal" would have been wrong every time.

**Premise note [O]:** the name-tagged reports `V66_asset_gap_final.md` and `V78_licence-fix` do **not** exist on disk (filename sweep + `glob **/V66*`, `**/V78*` empty), and I15 has **no ticket definition** (`SWARM_BOARD.md:164`; `REPORT_INDEX.md:19,24`). No owner or claim was invented for them. What *is* observable is their **effect**: the atlas/masks/lib tiers landed mid-audit and the absolute donor paths were normalised mid-audit (§3). This report seals bytes, not ticket names.

---

## 1. Executive summary

1. **[O] The pack is now fully populated at tier level but still not sealable.** Authoritative snapshot: **5257 files / 364,646,949 B** — root `manifest.json` 1/6,450,422 · `atlas` 8/7,551,760 · `cfg` 3/3,575,402 · `lib` 1/55,784,815 · `masks` 4,467/52,757,561 · `patterns` 777/238,526,989. **`schemas/` is still absent.** All files untracked (`git ls-files -- terrain_new/**` = 0).
2. **[O] X15 root-manifest conformance: PASS on all visible checks.** The root `manifest.json` landed after the first draft of this report (pass I1) and carries all 19 X15 §2.1 keys, `schema=terrain_new/manifest/v1`, `pack=terrain_new_v1`, `pack_id=terrain_new_v1-b7984b3cb162cdf9`, `visual_parity_claim:false`, and **5256 ordered provenance tuples** with all 8 tuple keys, sorted by `(source,offset,output)`. Its `counts.by_top` equals the independent census exactly (5256 files / 358,196,527 B excluding itself). `cfg/manifest.json` remains an I01 side-car, not a substitute (V62 C5). **[U] `pack_id` was not independently recomputed** from the canonical seed (no `--check` run; read-only worker).
3. **[O] V78 donor-path hygiene: PASS at final snapshot.** 0 of 787 derived JSONs contain an absolute drive path or `Games/Cossacks`. A transient residual `"source": "C:/Games/Cossacks 3/data/gen"` at `masks/mask_index.json:3` was observed in pass B4 and was normalised to `"data/gen"` by A5 (another concurrent write). Final sweep: **0 hits**.
4. **[O] No raw donor binary in `terrain_new`: PASS.** Extension census is exactly `.json` (787 / 316,396,255 B) + `.png` (4,470 / 48,250,694 B). No `.tga`, `.dds`, `.pattern`, `.lib`, `.bmp`, `.map`, `.exe`. Two-instrument hash sample: the four atlas PNGs are compact `--cell 128` derivatives (4,211,707 / 2,738,328 / 55,242 / 167,954 B), **not** the 179,912,941 / 124,463,306 B legacy donor art transports (X15 §3.2).
5. **[O] I08 atlas pair: PASS on presence and static path resolution.** `terrain_donor_mesh.gd:57-59` constants resolve to two on-disk files; `_atlas_paths():367-383` takes the `terrain_new` branch, so the labelled legacy fallback at `:379-382` is **not** selected. PNGs are structurally valid (IHDR 2048×1024 / 512×256 / 1024×512) and the manifest supplies `atlas.grid=[16,8]`, `slots=128`, `named=124`, `filled=121`, `empty=3`, `layout` 124 entries — the keys `tile_atlas_loader.gd:313-317,429-443` reads. **[U]** No Godot job was run; actual GPU load is UNVERIFIED.
6. **[O/D] I09 lib index: FAIL.** `lib/pattern_lib_index.json` exists (55,784,815 B) but at the **I03 tool-default path** (`decode_pattern_lib.py:21,762,997,999,1060`), while I09 reads `patterns/pattern_lib_index.json` (`terrain_donor_props.gd:59`, used at `:537`) — **ABSENT**. The nominal second feed `patterns/family_index.json` is present but `_try_feed():550-607` returns **FALSE** for it (emulated: no `props/objects/Objects/records/by_pattern` dict, no non-skipped top-level Array-of-Dicts). I09 therefore still lands on the legacy Z08 `mountain_props.json` with `fallback_used=true` / `TRANSFORM_FALLBACK` (`:542-545`). V62 conflict C2 is **still open**.
7. **[D] GO/NO-GO: NO-GO.** Three blockers remain after the root manifest landed: I09 feed path mismatch (C2), schema absent, and the pack still being written at audit time (stability only point-in-time). Two secondary defects: atlas sub-manifest misses three X15 §2.4 keys, and the season path shapes still conflict (C3). Full matrix §7. **No parity claim.**

---

## 2. Tier census — two independent instruments, authoritative snapshot

Both commands were run at the final snapshot (after the root-manifest landing) and agree exactly; the per-tier rows are the I1 (PowerShell) and I2 (Python `os.walk`) results at 2026-11-26T10:30:41.

| Tier | Files | Bytes | Sub-breakdown | X15/V11 expected role | Verdict |
|---|---:|---:|---|---|---|
| `cfg/` | 3 | 3,575,402 | 3 JSON: `constants.json`, `config_strings.json`, `manifest.json` (I01 side-car) | I01 G1/G2 + side-car | **PASS** |
| `patterns/` | 777 | 238,526,989 | top level 713 JSON / 191,971,185 B; `families/` 64 JSON / 46,555,804 B; includes `family_index.json` 55,507,231 B | I02/I03 G3/G4/G5 | **PASS** (presence); feed shape still unusable by I09 (§5) |
| `lib/` | 1 | 55,784,815 | `pattern_lib_index.json` only | I03 tool default, not I09's path | **FAIL** (wrong path — §5) |
| `atlas/` | 8 | 7,551,760 | 4 PNG / 7,173,231 B + 4 JSON / 378,529 B; summer+winter atlas, alpha, alphavert, 2 alias tables, 2 manifests | I05 G8/G9 → I08 | **PASS** (presence); 3 schema keys missing (§5) |
| `masks/` | 4,467 | 52,757,561 | 1 JSON (`mask_index.json` 11,680,098 B) + 4,466 `.height.png` / 41,077,463 B | I04 G6/G7 → X19 gap closure | **PASS** |
| `schemas/` | 0 | 0 | — | G11 validator input | **FAIL** (absent) |
| root manifest | 1 | 6,450,422 | `manifest.json` only; landed during this audit (pass I1) | G10 X15 `terrain_new/manifest/v1` | **PASS** (§3) |
| **TOTAL** | **5257** | **364,646,949** | `.json` 787 / 316,396,255 B · `.png` 4,470 / 48,250,694 B | — | — |

**Instrument equality [O]:** I1 `files=5257 bytes=364646949 ROOT_FILES=1` = I2 `TOTAL_FILES=5257 TOTAL_BYTES=364646949`, with identical per-tier counts. Extension census contains **only** `.json` and `.png` — no binary donor types.

**Git state [O]:** `git status --short -- variant3d/assets/terrain_new` = 1 directory row (`?? …/terrain_new/`); `git ls-files -- variant3d/assets/terrain_new/**` = **0**. Nothing in the pack is tracked; "seal" is a filesystem statement, not a commit statement.

---

## 3. Root manifest — X15 conformance (task item 2): **PASS** (visible checks)

- **[O] `variant3d/assets/terrain_new/manifest.json` is PRESENT** (6,450,422 B) at the final snapshot. It was **absent** at A1/B2/A3/A5/B5 and appeared only at post-write pass I1 — a fourth mid-audit landing. `ROOT_FILES=1`.
- **[O] X15 §2.1 key set — all 19 present, none missing:** `asset_index, atlas_manifest_v7_85_keys, census_reference, commit_policy, counts, donor_root_policy, entries, generator, generator_version, inputs_never_committed, labels, labels_used, pack, pack_id, schema, tool_versions, validation, version, visual_parity_claim`.
- **[O] Literals:** `schema="terrain_new/manifest/v1"` · `version=1` · `pack="terrain_new_v1"` · `pack_id="terrain_new_v1-b7984b3cb162cdf9"` (16 lowercase hex suffix) · `visual_parity_claim=false`.
- **[O] X15 §2.2 ordered provenance tuple — present:** `entries` is a list of **5256** records; entry 0 has exactly `decoder, label, offset, output, output_sha256, source, source_sha256, visual_parity_claim` (8/8 tuple keys, no missing), e.g. `source="data/gen"`, `offset="n/a"`, `output="masks/mask_index.json"`, `source_sha256=null` with label `[U] UNVERIFIED — no source_sha256`, `visual_parity_claim=false`. Independent check: `entries == sorted(entries, key=(source, offset, output))` → **True**.
- **[O] Cross-validation [D]:** `counts` records `files_excluding_root_manifest=5256`, `bytes_excluding_root_manifest=358196527`, and `by_top` = `{atlas:8/7,551,760, cfg:3/3,575,402, lib:1/55,784,815, masks:4,467/52,757,561, patterns:777/238,526,989}` — **exactly** the independent A5/B5 census (5256 files / 358,196,527 B, i.e. the final 5257 total minus the manifest itself). `by_ext` = `{.json:786/309,945,833, .png:4,470/48,250,694}` for the same reason. `asset_index` has 10 keys (`alpha, alphavert, atlas, atlas_manifest, cfg, height_tiles, pattern_decode, pattern_families, pattern_lib, season_aliases`).
- **[O] `cfg/manifest.json` is not a substitute** (V62 C5): its top keys are `check_basis, count_checks, derived, documented_exceptions, game_root, multi_pass_audit, preserved_contradictions, schema_version, source_hashes, summary, tool, visual_parity_claim` — no `schema`, `pack`, `pack_id`, `entries`, `asset_index` or `census_reference`. Its `game_root` is correctly `$COSSACKS3_DIR` post-fix.
- **[U] Two honest limits:** (a) `pack_id` was **not independently recomputed** from the canonical seed — no `--check` tool run by this read-only worker; its well-formedness and internal consistency are observed, byte-level determinism is not proven. (b) The full X15 §2.5 `validation.checks` semantics (16 assertions) were not executed. **[U]** The pack is still being written; re-verify the manifest's hashes after quiescence.
- **[O] Consumer note:** `variant3d/tests/t_terrain_donor.gd:44` declares `ASSET_MANIFEST` and checks it only as **advisory** at `:700-703`; presence now makes that advisory true, but the atom still asserts no provenance semantics.

---

## 4. Donor-path hygiene and raw-binary exclusion (task items 3-4): **PASS at final snapshot**

### 4.1 Absolute donor install paths — PASS (with transient defect logged)

- **[O] Final sweep:** Python regex `[A-Za-z]:[\\/]` plus case-insensitive `Games/Cossacks` over all **787** JSON files (including the new root manifest) → **0 files with an absolute path**. Earlier grep literal `C:\Games\Cossacks 3` also returned 0 matches; `$COSSACKS3_DIR` and `source_rel` are present in `cfg/manifest.json:235,243,256,266,279`, `patterns/pattern_decode_manifest.json:4`, `cfg/constants.json:10,23,36,49` etc.
- **[O] Transient (B4, then fixed):** `masks/mask_index.json:3` briefly read `"source": "C:/Games/Cossacks 3/data/gen"` — the forward-slash form escaped the original backslash literal. By A5 it read `"source": "data/gen"`; the 20-byte masks delta in A5 is exactly this normalisation. **[D]** Two passes were required: a backslash-only check at B2 would have reported a false PASS, a backslash-only check at B4 would have missed the forward-slash hit.
- **[O] Manifest-level hygiene:** 787/787 JSON parse under `json.load`, **787/787 carry `visual_parity_claim:false`**, 0 missing, 0 with `true`.

### 4.2 No raw donor TGA/DDS/binary — PASS by extension census + two-instrument hash sample

| File (repo-relative) | Bytes | SHA-256 (PowerShell `Get-FileHash` = Python `hashlib`, both passes identical) | Reading |
|---|---:|---|---|
| `atlas/tile_index_atlas.png` | 4,211,707 | `ba69259f3cf3252488a100dfdbb6c57258c3772feb83d88866d4f56cf480e21c` | compact derived atlas; **not** legacy `a1f123a1…` 179,912,941 B (X15 §3.2) |
| `atlas/seasons/tile_index_atlas_winter.png` | 2,738,328 | `ead5cc890bb29c48d96bbe009cd8d0f8289ee57c6a57aff9d7af5c57b8e1cf44` | compact derived winter; **not** legacy `5d0dd8f3…` 124,463,306 B |
| `atlas/alpha.png` | 55,242 | `dfaf78d0c285920cd2009f74476a8d4647f3666efb7c6dcf0bfd1b44487b8ef7` | documented derived mask (equals X15 B_atlas_png #10) |
| `atlas/alphavert.png` | 167,954 | `c916ea98ddb7f8ccc9a4898f324540335d4d74ee5250f4774b9769c762afd245` | documented derived mask (equals X15 B_atlas_png #11) |
| `masks/height/dlc5/coastal/2pl_mask_coastal_0_gauss.height.png` (sample) | 1,782 | `519a6af36b491a54e8b4cb67b459864127766e367c1d4b8ec79b4def5c73430f` | 320×320 derived height PNG, not a donor TGA |
| `patterns/family_index.json` `source_sha256` entries | — | `f7b421b1…` anchor family retained | donor `pattern.lib` hash recorded as provenance, not copied bytes |

- **[O] Extension census is decisive:** across all 5257 files only `.json` (787) and `.png` (4,470) occur — zero `.tga`, `.dds`, `.bmp`, `.pattern`, `.lib`, `.map`, `.exe`, `.ogg`. No raw donor binary was written into `terrain_new`.
- **[U]** Only five PNGs were hash-sampled; the other 4,465 height PNGs were checked by extension/structure, not individually hashed. No donor binary was executed or read by V89.

---

## 5. Live consumer paths (task item 5): atlas PASS, lib index FAIL

### 5.1 I08 atlas pair — PASS (presence + static resolution), load itself UNVERIFIED

| Constant / line | Path | Disk | Consequence |
|---|---|---|---|
| `terrain_donor_mesh.gd:57-58` `NEW_ATLAS_SINGLE` | `res://assets/terrain_new/atlas/tile_index_atlas.png` | **PRESENT** (4,211,707 B, 2048×1024 valid IHDR) | `_atlas_paths():368-383` keeps the new path; legacy fallback at `:379-380` not taken |
| `terrain_donor_mesh.gd:59` `NEW_ATLAS_MANIFEST` | `res://assets/terrain_new/atlas/tile_index_atlas.manifest.json` | **PRESENT** (149,449 B) | Same; legacy manifest fallback at `:381-382` not taken |
| `terrain_donor_mesh.gd:371-372` season override | `atlas/seasons/winter/tile_index_atlas{.manifest}.png/json` | **ABSENT** | Season override skipped; I05's flat `atlas/seasons/tile_index_atlas_winter.*` is present but I08 never looks there (V62 C3). Latent — no `set_season()` caller |

- **[O] Static load compatibility:** I08 passes the two paths into `TileAtlasLoader` at `terrain_donor_mesh.gd:430` (`loader_script.new(atlas_mode_request, paths)`); the loader's `manifest_path` override is consumed at `tile_atlas_loader.gd:117`, `_load_grid():313-317` reads `manifest.atlas.grid`, and `_load_array():429-443` reads `atlas.grid` + `layout`. The new manifest provides `atlas.grid=[16,8]`, `slots=128`, `named_cells=124`, `filled_cells=121`, `empty_cells=3`, `cell_size=[128,128]`, `size=[2048,1024]`, `resolution_tier="commit_default"`, `layout` 124 entries, `visual_parity_claim:false` — all required values present.
- **[O] Secondary schema defect [D]:** the atlas manifest is **not** fully X15 §2.4 (V7-85) conformant — top-level keys `unused_shipped_blocks` and `unused_note` are missing, and `atlas.upscaled_sources` is missing. It adds `aliases, alpha_transport, blend, empty_sentinel_cells, face_cells, licence_guard, mipmaps, outputs, provenance`. These are **not** keys the loader reads, so they do not block the static load path, but a strict X15 validator would reject the sub-manifest.
- **[U] No Godot process, runner job, gate or capture was run (read-only worker).** "PASS" here means *the exact path constants resolve to structurally valid on-disk files and the loader's required keys exist*; a real GPU load remains UNVERIFIED.

### 5.2 I09 object feed — FAIL (lib index at a path I09 does not read)

| I09 candidate (consumer line) | Path | Disk | `_try_feed()` outcome |
|---|---|---|---|
| `terrain_donor_props.gd:59` `FEED_LIB_INDEX` (primary, used at `:537`) | `res://assets/terrain_new/patterns/pattern_lib_index.json` | **ABSENT** | false (file not found at `:551-552`) |
| `terrain_donor_props.gd:60` `FEED_FAMILY_INDEX` (secondary, `:540`) | `res://assets/terrain_new/patterns/family_index.json` | **PRESENT** (55,507,231 B) | **false** — emulated `:550-607`: no `props`/`objects`/`Objects`/`records`/`by_pattern` dict; no non-skipped top-level Array of non-empty Dictionaries. Top keys are `description, families(list,64), family_count, heightfield_census, join_summary, labels, line_byte_offsets, object_census, pair_count, pattern_lib, schema, source, source_sha256, unverified_fields, visual_parity_claim` |
| I03 tool default (`decode_pattern_lib.py:21,762,997,999,1060`) — **not read by I09** | `variant3d/assets/terrain_new/lib/pattern_lib_index.json` | **PRESENT** (55,784,815 B, final 787-JSON census includes it) | N/A to runtime; top keys `description, family_count, generator_families, heightfield_census, join_summary, labels, line_byte_offsets, object_census, pair_count, pattern_lib, schema, source, source_sha256, unverified_fields, visual_parity_claim`, `visual_parity_claim:false` |
| `terrain_donor_props.gd:61` `FEED_FALLBACK` (`:542-545`) | `res://assets/terrain/mountain_props.json` | PRESENT (legacy) | **TRUE — currently effective feed**, `fallback_used=true`, `TRANSFORM_FALLBACK` unverified entry appended |

- **[D] HIGH:** V62 conflict C2 persists after the mid-audit landing. The I03 writer emits `lib/pattern_lib_index.json`; I09 reads `patterns/pattern_lib_index.json`. Presence of the 55.8 MB file does **not** close G5. Copying/aliasing it alone is not sufficient either: the secondary feed's shape was verified false, and the new lib index would need its `generator_families` shape checked against `_try_feed()` before being counted as a working feed.
- **[O] Consequence:** any props/mesh capture would instance the legacy Z08 table while reporting a donor backend — a silent substitution, labelled in stats (`fallback_used=true`) but not a donor feed.

---

## 6. Remaining ABSENT paths with consumer file:line

| # | Exact path | Consumer file:line | Runtime consequence | Owner / ticket | Priority |
|---|---|---|---|---|---|
| 1 | `res://assets/terrain_new/schemas/v1.schema.json` | spec/11 §11.4; V11 G11; **no runtime module reads it** (grep `v1.schema.json` / `schemas/` over `variant3d/**` = 0 matches) | No hard fail; validator/gate-2 blocker if N7 is used | I05 (G11) | P1 |
| 2 | `res://assets/terrain_new/patterns/pattern_lib_index.json` | `variant3d/scripts/terrain_donor_props.gd:59` (`FEED_LIB_INDEX`), used at `:537` | Primary donor object feed unavailable → legacy Z08 fallback (§5.2) | I03 (V11 G5) | **P0** |
| 3 | `res://assets/terrain_new/atlas/seasons/winter/tile_index_atlas.png` | `variant3d/scripts/terrain_donor_mesh.gd:371` (season override) | Winter override skipped; flat `atlas/seasons/tile_index_atlas_winter.png` is present but unread (C3). Latent: no `set_season()` caller | I05 (G9) | P1 (latent) |
| 4 | `res://assets/terrain_new/atlas/seasons/winter/tile_index_atlas.manifest.json` | `variant3d/scripts/terrain_donor_mesh.gd:372` | Same as #3 | I05 (G9) | P1 (latent) |
| 5 | `res://scripts/terrain_donor_tiles.gd` | `variant3d/tests/t_terrain_donor.gd:42`, advisory `:700` | Advisory only; composer does not reference it. Not a `terrain_new` path — listed for completeness | I07 (N10) | Not blocker |
| 6 | `res://shaders/terrain_donor.gdshader` | V62 §3 #23 — retired alias (V37) | Intentionally absent; canonical `terrain_donor_shader.gdshader` present | A06 N7 | Not blocker |

**[O] Inverse finding (present but not at the consumer's path):** `variant3d/assets/terrain_new/lib/pattern_lib_index.json` exists (55,784,815 B, written by I03's own default per `decode_pattern_lib.py:21,762`) but no runtime module references that path. This is the C2 mismatch, not a missing file.

**[O] Nearly-ABSENT-but-landed during audit:** `atlas/**` (A1 absent → B1 present), `masks/**` (B2 absent → A3 present), `lib/**` (B3 absent → A4 present), and the **root `manifest.json`** (A5 absent → I1 present — after this report's first draft). Every one would have been recorded ABSENT by a single early pass.

---

## 7. Per-tier verdicts and GO/NO-GO

| Tier / gate item | Verdict | Evidence |
|---|---|---|
| `cfg/` | **PASS** | 3 files / 3,575,402 B; all JSON parse, `visual_parity_claim:false`, no absolute paths |
| `patterns/` | **PASS** (presence) | 777 files / 238,526,989 B; all JSON parse; **but** `family_index.json` unusable as I09 feed (§5.2) |
| `lib/` | **FAIL** | File exists at I03 default path; I09's `patterns/pattern_lib_index.json` absent — C2 open |
| `atlas/` | **PASS** (presence / static path) | I08 constants resolve to on-disk valid PNG + manifest; 3 X15 §2.4 keys missing; GPU load UNVERIFIED |
| `masks/` | **PASS** | 4,467 files / 52,757,561 B; transient forward-slash donor path normalised by final pass |
| `schemas/` | **FAIL** | absent; no module hard-fails, validator/gate-2 blocked |
| root manifest (X15 conformance) | **PASS** (visible checks) | 19/19 root keys, correct schema/pack/pack_id, 5256 sorted 8-key entry tuples, `visual_parity_claim:false`, counts match independent census; `pack_id` recomputation UNVERIFIED (§3) |
| donor-path hygiene (V78 effect) | **PASS** | 0/787 JSON with absolute donor path at final snapshot (transient logged §4.1) |
| raw donor binary exclusion | **PASS** | only `.json` + `.png`; two-instrument hash sample §4.2 |
| collective file/byte census | **PASS** | two independent commands agree exactly: 5257 / 364,646,949 B |
| pack stability / tracked state | **UNVERIFIED** | four mid-audit landings; 0 tracked files; re-read before any commit |

### **GO/NO-GO for asset readiness: NO-GO**

Reasons, in priority order:
1. **P0 — I09 object feed path mismatch (C2).** The 55.8 MB lib index landed after the audit began but at the writer's default path; I09 reads a different path, and the present secondary feed is shape-incompatible. The live props feed is still the legacy Z08 table.
2. **P1 — `schemas/v1.schema.json` absent.** No validator input; G11 unclosed.
3. **P1 — snapshot stability unproven.** The pack changed four times inside this audit (the root manifest after this report's first draft) and is entirely untracked; a re-census immediately before commit is mandatory.
4. **P1 — secondary defects:** atlas sub-manifest misses `unused_shipped_blocks`, `unused_note`, `atlas.upscaled_sources` (X15 §2.4); season path shapes still conflict (C3, latent).
5. **[U] Root manifest is present but not fully proven:** `pack_id` recomputation and the 16 `validation.checks` assertions were not executed; treat G10 as *structurally* closed, not *behaviourally* verified.

**GO conditions (all required before a seal can flip):** make I09's `patterns/pattern_lib_index.json` exist with a `_try_feed()`-accepted record shape (or change the consumer to the canonical path — V62 Q1) and confirm `stats.feed_source` is a `terrain_new` path with `fallback_used=false`; land the schema or retire G11 explicitly; re-run both independent census commands on a quiescent tree and confirm zero absolute paths and zero donor binaries; independently recompute `pack_id` and execute the X15 validation checks; add the missing V7-85 atlas keys and resolve C3. **No donor parity claim at any point** — parity remains UNVERIFIED / PORT APPROXIMATION (CHARTER.md:43-44,125).

---

## 8. Handoff summary (5 lines)

1. **Verdict: NO-GO.** Authoritative snapshot 5257 files / 364,646,949 B across root `manifest.json` + `atlas`/`cfg`/`lib`/`masks`/`patterns`; schema still absent; all files untracked. Root manifest passes visible X15 checks; `pack_id` recomputation UNVERIFIED.
2. **Two independent commands agree** (PowerShell `Get-ChildItem` = Python `os.walk`) at 10:30:41, after four mid-audit landings (atlas, masks, lib, root manifest) that a single pass would have mis-sealed.
3. **Hygiene PASS:** 0/787 derived JSONs with an absolute donor path (transient forward-slash hit in `masks/mask_index.json:3` normalised mid-audit); 787/787 `visual_parity_claim:false`; no donor binary in `terrain_new`.
4. **Consumer split:** I08's atlas pair is present and statically loadable; I09's lib index is present at the wrong path and its secondary feed is shape-incompatible, so the legacy Z08 feed is still live.
5. **Guards:** read-only worker; no asset/code/shader/config/test/git/Godot change; exactly one repo file written (this report); scratch probes outside the repo; **no donor parity claim** — parity stays UNVERIFIED.

*End of V89 report. Exactly one repo file written; no other file was created, edited or deleted.*
