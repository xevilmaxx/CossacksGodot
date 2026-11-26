---
id: V111
ticket: "TERRAIN-SWARM-2026-11-26 / V111 — FINAL asset validation after I15/V78 (read-only)"
agent: "V111 (read-only audit subagent, 30-agent DONOR-FIRST terrain swarm, reporting to COORD)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_EDIT__NO_ASSET_GENERATION__NO_GODOT_JOB__NO_GATE__NO_PARITY_CLAIM
owner_file: docs/terrain_swarm_2026-11-26/reports/V111_asset_final.md
files_created: [docs/terrain_swarm_2026-11-26/reports/V111_asset_final.md]
files_edited: []
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION", "NO_PARITY_CLAIM"]
parity_guard: "No donor binary, donor byte, donor GPU frame, Godot process, runner job, gate or capture was used by V111. No donor visual parity claim is made; parity stays UNVERIFIED (CHARTER.md:43-44,125). File presence is existence evidence only, never a gate PASS or donor fidelity."
scope_guard: "Read-only: file reads, PowerShell Get-ChildItem/Test-Path/Get-FileHash/Select-String, git status --short / git ls-files, Python os.walk/json/hashlib/re over variant3d/assets/terrain_new/** and consumer file:line reads. Scratch scripts confined to C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/ (outside repo). No asset, source, shader, config, test, manifest, queue, git index or app/ byte was changed."
multiple_passes: true
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
snapshot: "Authoritative snapshot at V111 audit time: 5257 files / 364,646,949 B including the newly landed root manifest (6,450,422 B); 5256 / 358,196,527 B excluding it. Both instruments agree exactly."
verdict: "GO for asset-pack readiness (conditional) — see §7. NOT a gate PASS, NOT donor parity. Overall port/gate/parity readiness remains NO-GO / UNVERIFIED."
---

# V111 — FINAL asset validation after I15/V78

## 0. Multiple-pass log (owner directive, CHARTER.md:85-93)

| Pass | Instrument | Result | Effect |
|---|---|---|---|
| A1 | PowerShell `Get-ChildItem -LiteralPath … -File -Recurse`, per-tier + extension grouping | **5257 files / 364,646,949 B**; atlas 8/7,551,760 · cfg 3/3,575,402 · lib 1/55,784,815 · masks 4,467/52,757,561 · patterns 777/238,526,989 · ROOT 1/6,450,422 | Instrument 1 census |
| B1 | Independent Python `os.walk` + `os.path.getsize`, `/`-normalised | **5257 / 364,646,949**; identical per-tier numbers; EXT `.json` 787/316,396,255 · `.png` 4,470/48,250,694 | **A1 = B1 exactly; snapshot accepted** |
| A2 | Python `json.load` + `hashlib` over all 787 JSONs | 787 parse, 0 parse failures, **0 absolute donor paths**, **0 `visual_parity_claim:true`**, 0 missing | Instrument 1 (hygiene) |
| B2 | `grep` regex `[A-Za-z]:[\\/]|Games[/\\]Cossacks` over `*.json` | **0 matches** | Instrument 2 (hygiene), agrees |
| C2 | PowerShell `Select-String` for the same two patterns + `"visual_parity_claim":true` | **0 / 0 matches** | Instrument 3 (hygiene), agrees |
| A3 | Python `hashlib.sha256` recompute of 20 manifest `entries[].output_sha256` | **20/20 OK** | Instrument 1 (hash) |
| B3 | PowerShell `Get-FileHash -Algorithm SHA256` on 5 files | 4/4 comparable files match the manifest exactly; root manifest is excluded from its own entries by design (`census_reference.i15_root_manifest_excluded_from_own_counts:true`) | Instrument 2 (hash), agrees |
| A4 | PowerShell `Test-Path` sweep of consumer paths | root manifest PRESENT, atlas pair PRESENT, lib index PRESENT, schema ABSENT, patterns-side lib index ABSENT, winter pair ABSENT | Instrument 1 (presence) |
| B4 | Python `os.path.isfile` sweep of the same paths | Identical PRESENT/ABSENT matrix | Instrument 2 (presence), agrees |
| Diff vs V89 | V89 §0/§3/§5 baseline comparison | **Two post-V89 landings detected:** root `manifest.json` (absent → 6,450,422 B) and I09 feed constants `terrain_donor_props.gd:59-60` repointed from `patterns/` to `lib/` (C2 closed on presence) | A single pass against the old snapshot would have mis-sealed |

**[O] No anomaly was accepted from one pass.** Every count, hash and hygiene result was reproduced by a second (or third) independent instrument. V89's three mid-audit landings are a standing warning; this audit's A1/B1 and A2/B2/C2 agreement is point-in-time only.

**Premise note [O]:** `V101_root_manifest.md` and `V78*` are **ABSENT** on disk (explicit `Test-Path` sweep); `V89 §0` already recorded that V78 has no ticket definition and I15 has no ticket definition in `SWARM_BOARD.md`/`REPORT_INDEX.md`. No owner or claim was invented for them. What *is* observable is their **effect**: the root manifest landed and the I09 feed path was corrected after V89. This report seals current bytes, not ticket names.

---

## 1. Executive summary

1. **[O] Pack census: two independent commands agree exactly — 5257 files / 364,646,949 B** including the new root manifest; **5256 / 358,196,527 B** excluding it. Five tiers present: `atlas` 8/7,551,760 · `cfg` 3/3,575,402 · `lib` 1/55,784,815 · `masks` 4,467/52,757,561 · `patterns` 777/238,526,989. Root files: 1 (`manifest.json`). `schemas/` tier is **ABSENT**. All 5257 files remain untracked (`git ls-files -- terrain_new/**` = 0; `git status --short` = one `??` directory row).
2. **[O] X15 root-manifest conformance: PASS.** `variant3d/assets/terrain_new/manifest.json` exists (6,450,422 B), carries **19/19** X15 §2.1 root keys with **0 missing / 0 extra**, the exact literal `schema:"terrain_new/manifest/v1"`, `version:1`, `pack:"terrain_new_v1"`, root `visual_parity_claim:false`, and **5256** entries each with the exact 8-key provenance tuple, sorted by `(source, offset, output)`. Deterministic `pack_id` recomputed from the canonical seed matches the stored value: **`terrain_new_v1-b7984b3cb162cdf9`**. 20/20 sampled `output_sha256` values recompute byte-exactly.
3. **[O] Donor-path hygiene: PASS across three tools.** 0 of **787** derived JSONs contain an absolute drive path or `Games/Cossacks`; 787/787 parse; 787/787 carry `visual_parity_claim:false`; 0 carry `true`; 0 missing. Extension census is only `.json` + `.png` — no raw donor TGA/DDS/BMP/PNG-transport, `.pattern`, `.lib`, `.map` or `.exe` in `terrain_new`.
4. **[O] I08 atlas pair: PASS (presence + static resolution).** `terrain_donor_mesh.gd:57-59` constants resolve to `atlas/tile_index_atlas.png` (4,211,707 B) and `atlas/tile_index_atlas.manifest.json` (149,449 B); `_atlas_paths():367-383` keeps the `terrain_new` branch and the labelled legacy fallback at `:379-382` is not taken. **[U]** No Godot job was run; a real GPU load is UNVERIFIED.
5. **[O] I09 lib index: PASS on presence at the current consumer path.** `terrain_donor_props.gd:59-60` now reads `res://assets/terrain_new/lib/pattern_lib_index.json` (55,784,815 B, PRESENT) — the V89 C2 path mismatch is closed by the consumer repoint. **[D] Latent functional caveat:** emulated `_try_feed():550-623` returns TRUE (64 dict records) but keys `_records` by the literal `"generator_families"` (`:616`), whereas `_collect_stamp():634` looks up by pattern name — so props would still be skipped at runtime. This is a code-shape defect for COORD, not an asset-presence failure.
6. **[D] GO/NO-GO: GO for asset-pack readiness (conditional).** Every asset-readiness item requested (census, X15 manifest, 20 SHA sample, hygiene, parity flag, I08 pair, I09 file) now PASSES. Conditions/caveats: schema absent (G11 validator blocked), winter season paths absent but latent, pack entirely untracked, GPU load and runtime feed behaviour UNVERIFIED, and the atlas sub-manifest still misses three X15 §2.4 keys. **This is not a gate PASS and not a donor parity claim** — parity remains UNVERIFIED / PORT APPROXIMATION.

---

## 2. Tier census — two independent commands (task item 1)

Both commands were run at the same snapshot and agree exactly; the rows are A1 (PowerShell) and B1 (Python `os.walk`).

| Tier | Files | Bytes | Sub-breakdown | X15/V11 expected role | Verdict |
|---|---:|---:|---|---|---|
| `cfg/` | 3 | 3,575,402 | `constants.json`, `config_strings.json`, `manifest.json` (I01 side-car) | I01 G1/G2 + side-car | **PASS** |
| `patterns/` | 777 | 238,526,989 | 713 top-level JSON + 64 `families/` JSON; includes `family_index.json` 55,507,231 B | I02/I03 G3/G4/G5 | **PASS** |
| `lib/` | 1 | 55,784,815 | `pattern_lib_index.json` only — now the I09 consumer path | I03 canonical output → I09 G5 | **PASS** |
| `atlas/` | 8 | 7,551,760 | 4 PNG / 7,173,231 B + 4 JSON / 378,529 B (summer+winter atlas, alpha, alphavert, 2 alias tables, 2 manifests) | I05 G8/G9 → I08 | **PASS** (presence/static); 3 X15 §2.4 keys missing (§5.1) |
| `masks/` | 4,467 | 52,757,561 | 1 JSON (`mask_index.json` 11,680,098 B) + 4,466 `.height.png` / 41,077,463 B | I04 G6/G7 → X19 gap | **PASS** |
| `<ROOT>` | 1 | 6,450,422 | `manifest.json` (I15/X15 provenance manifest) | G10 X15 `terrain_new/manifest/v1` | **PASS** (§3) |
| `schemas/` | 0 | 0 | — | G11 validator input | **FAIL** (absent) |
| **TOTAL** | **5257** | **364,646,949** | `.json` 787 / 316,396,255 B · `.png` 4,470 / 48,250,694 B; **excluding root manifest 5256 / 358,196,527** | — | — |

**Instrument equality [O]:** A1 `TOTAL files=5257 bytes=364646949` with per-tier rows identical to B1 `TOTAL files=5257 bytes=364646949`. The two extension censuses were derived from the same two passes. No `.tga`, `.dds`, `.bmp`, `.pattern`, `.lib`, `.map`, `.exe` or `.ogg` appears — raw donor binary exclusion holds by extension census.

**Git state [O]:** `git status --short -- variant3d/assets/terrain_new` = `?? variant3d/assets/terrain_new/`; `git ls-files -- variant3d/assets/terrain_new/**` = **0**. Every byte is untracked; "seal" is a filesystem statement, not a commit statement.

---

## 3. Root manifest — X15 validation + 20-SHA sample (task item 2)

### 3.1 Key-set conformance: PASS

- **[O]** File present at every V111 pass: `variant3d/assets/terrain_new/manifest.json`, **6,450,422 B**, valid JSON, single-line canonical form.
- **[O]** **19/19** X15 §2.1 root keys present, **0 missing / 0 extra**: `asset_index, atlas_manifest_v7_85_keys, census_reference, commit_policy, counts, donor_root_policy, entries, generator, generator_version, inputs_never_committed, labels, labels_used, pack, pack_id, schema, tool_versions, validation, version, visual_parity_claim`. The file order is alphabetical, **not** the X15 §2.1 display order (`order_exact_match = False`). **[D]** Non-blocking: JSON object member order is non-semantic and X15 §2.3's own canonical seed uses `sort_keys=True`; the key *set* is exact.
- **[O]** `schema = "terrain_new/manifest/v1"` (literal match), `version = 1`, `pack = "terrain_new_v1"`, `generator_version = "1.0.0"`, root `visual_parity_claim = false`.
- **[O] Entry tuple:** **5256** entries; **0** entries with a wrong key set — every entry has exactly `source, offset, output, source_sha256, output_sha256, label, decoder, visual_parity_claim`. Entries **are** sorted by `(source, offset, output)`. **0** null `output`, **0** null `output_sha256`. **776** non-null `source_sha256`; the remaining **4,480** nulls are **all** labelled `UNVERIFIED`, satisfying X15 §2.2's null rule.
- **[O] Cosmetic defect:** the common null-source label renders as `[U] UNVERIFIED \ufffd no source_sha256` — a U+FFFD replacement character where an em dash was intended. It does not affect parsing, key sets or hashes; logged for the writer.

### 3.2 Deterministic `pack_id`: PASS

- **[O]** Recomputed exactly per X15 §2.3 — `seed = {schema, version, pack, generator, generator_version, tool_versions, entries sorted by (source,offset,output), counts, visual_parity_claim:false}`; `json.dumps(sort_keys=True, separators=(",",":"), ensure_ascii=False) + "\n"`; `pack + "-" + sha256(...)[:16]`.
- **[O]** stored `terrain_new_v1-b7984b3cb162cdf9` = recomputed `terrain_new_v1-b7984b3cb162cdf9` → **match**. No timestamps, mtimes or absolute donor root enter the seed.

### 3.3 Sample of 20 SHA-256 recomputes: PASS (20/20)

Python `hashlib.sha256` (1 MiB streaming) over the on-disk file bytes, compared to `entries[].output_sha256`; evenly spaced across all 5256 entries.

| # | Output | Stored (12 hex) | Recomputed (12 hex) | Result |
|---:|---|---|---|---|
| 1 | `masks/mask_index.json` | 4f60de5c15ba | 4f60de5c15ba | OK |
| 2 | `patterns/fb_36.json` | 6480ef7e94fc | 6480ef7e94fc | OK |
| 3 | `patterns/m_swamp_11.json` | b962674a9048 | b962674a9048 | OK |
| 4 | `cfg/constants.json` | 81f73057ec05 | 81f73057ec05 | OK |
| 5 | `masks/height/dlc5/continents/2pl_mask_continents_6_gauss.height.png` | a595d7b6b071 | a595d7b6b071 | OK |
| 6 | `masks/height/dlc5/islands/3pl_mask_islands_11_gauss.height.png` | 5207c03268f8 | 5207c03268f8 | OK |
| 7 | `masks/height/dlc5/lakes/3pl_mask_lakes_12_gauss.height.png` | 90e02c1e0d08 | 90e02c1e0d08 | OK |
| 8 | `masks/height/dlc5/land/4pl_mask_land_42_gauss.height.png` | 5a5130651d20 | 5a5130651d20 | OK |
| 9 | `masks/height/dlc5/mediterranean/8pl_mask_mediterranean_11_…height.png` | 56a78a5127cf | 56a78a5127cf | OK |
| 10 | `masks/height/dlc5/peninsulas/3pl_mask_peninsulas_84_gauss.height.png` | 2b7176d24019 | 2b7176d24019 | OK |
| 11 | `masks/height/dlc5/rivers/8pl_mask_rivers_17_gauss.height.png` | 64d6a3d3b088 | 64d6a3d3b088 | OK |
| 12 | `masks/height/src/continents/4pl_mask_continents_53.height.png` | cd9606837d14 | cd9606837d14 | OK |
| 13 | `masks/height/src/islands/3pl_mask_islands_94.height.png` | f22b8b365293 | f22b8b365293 | OK |
| 14 | `masks/height/src/land/4pl_mask_land_34.height.png` | 7a47e15d49aa | 7a47e15d49aa | OK |
| 15 | `masks/height/src/peninsulas/2pl_mask_peninsulas_30.height.png` | e9afb0e254c9 | e9afb0e254c9 | OK |
| 16 | `masks/height/vanilla/continent/4pl_mask_continent_16_gauss.height.png` | 1e29a6d35487 | 1e29a6d35487 | OK |
| 17 | `masks/height/vanilla/continents/4pl_mask_continents_81_gauss.…height.png` | 8af60002c2a8 | 8af60002c2a8 | OK |
| 18 | `masks/height/vanilla/islands/4pl_mask_islands_31_gauss.height.png` | b0b0d7d6bfb5 | b0b0d7d6bfb5 | OK |
| 19 | `masks/height/vanilla/land/4pl_mask_land_60_gauss.height.png` | b6ea3d7b5600 | b6ea3d7b5600 | OK |
| 20 | `masks/height/vanilla/peninsulas/2pl_mask_peninsulas_13_gauss.height.png` | cd5974cee4f1 | cd5974cee4f1 | OK |

**Cross-instrument (A3 vs B3) [O]:** PowerShell `Get-FileHash -Algorithm SHA256` matched the manifest for `atlas/tile_index_atlas.png` (`ba69259f…`), `atlas/tile_index_atlas.manifest.json` (`cae72322…`), `lib/pattern_lib_index.json` (`a9fff8a1…`) and `masks/mask_index.json` (`4f60de5c…`). The root manifest itself has no self-entry by design (`census_reference.i15_root_manifest_excluded_from_own_counts = true`), so its hash is not comparable through `entries[]`.

**[U]** Only 20 of 5256 output hashes were recomputed this pass; the other 5236 are asserted by the manifest and were verified by V89's earlier 786-JSON sweep plus the pack_id closure. No donor binary was read or executed.

---

## 4. Hygiene — absolute donor paths and parity flag (task items 3-4)

### 4.1 Absolute donor install paths: PASS (three tools)

- **[O]** Python `json.load` + regex `[A-Za-z]:[\\/]` and case-insensitive `Games[/\\]Cossacks` over all **787** derived JSONs: **0 hits**. This covers both backslash (`C:\Games\Cossacks 3`) and forward-slash (`C:/Games/Cossacks 3`) forms — V89's transient forward-slash defect at `masks/mask_index.json:3` does not recur.
- **[O]** `grep` tool with the same combined regex over `terrain_new/**/*.json`: **0 matches**.
- **[O]** PowerShell `Select-String` over the same file set with both patterns: **0 matches**.
- **[O]** 787/787 JSON parse successfully (0 parse failures). Manifest-level `donor_root_policy` and `inputs_never_committed` record `$COSSACKS3_DIR` and donor-relative paths only.

### 4.2 `visual_parity_claim:false`: PASS

- **[O]** Python: **787/787** derived JSONs carry `visual_parity_claim:false` — 0 missing, 0 `true`, 0 other. This includes the root manifest, all 5256 manifest entries, the atlas sub-manifest, `cfg/manifest.json`, `family_index.json`, `lib/pattern_lib_index.json` and `masks/mask_index.json`.
- **[O]** PowerShell `Select-String '"visual_parity_claim"\s*:\s*true'`: **0 hits**. Root manifest `validation.parity = false`.
- **[O] NO PARITY CLAIM.** No donor GPU A/B frame exists; parity remains `UNVERIFIED` / `PORT APPROXIMATION` (CHARTER.md:43-44,125). Nothing in this report elevates a tier above 2 in the V15 vocabulary.

---

## 5. Live consumer paths (task item 5)

### 5.1 I08 atlas pair — PASS (presence + static resolution); GPU load UNVERIFIED

| Constant / line | Path | Disk | Consequence |
|---|---|---|---|
| `terrain_donor_mesh.gd:57-58` `NEW_ATLAS_SINGLE` | `res://assets/terrain_new/atlas/tile_index_atlas.png` | **PRESENT** 4,211,707 B | `_atlas_paths():368-383` keeps the new path; legacy fallback at `:379-380` not taken |
| `terrain_donor_mesh.gd:59` `NEW_ATLAS_MANIFEST` | `res://assets/terrain_new/atlas/tile_index_atlas.manifest.json` | **PRESENT** 149,449 B | Legacy manifest fallback at `:381-382` not taken |
| `terrain_donor_mesh.gd:371-372` season override | `atlas/seasons/<season>/tile_index_atlas{.manifest}.png/json` | winter variant **ABSENT** | Season override skipped; latent — no `set_season()` caller (§6 #2/#3) |

- **[O]** Static compatibility holds: the sub-manifest supplies `atlas.grid=[16,8]`, `slots=128`, `named_cells=124`, `filled_cells=121`, `empty_cells=3`, `size=[2048,1024]`, `cell_size=[128,128]`, `resolution_tier`, `layout` (124 entries) and `visual_parity_claim:false` — the keys `tile_atlas_loader.gd` reads.
- **[O] Secondary X15 §2.4 defect (unchanged from V89):** the sub-manifest is missing top-level `unused_shipped_blocks`, `unused_note` and `atlas.upscaled_sources`, and adds `aliases, face_cells, empty_sentinel_cells, mipmaps, blend, alpha_transport, licence_guard, outputs, provenance`. These are **not** loader-read keys, so the static load path is unaffected; a strict X15 §2.4 validator would reject the sub-manifest.
- **[U]** No Godot process, runner job, gate or capture was run. "PASS" means the path constants resolve to structurally valid on-disk files with the required keys; an actual GPU load is UNVERIFIED.

### 5.2 I09 object feed — PASS on file presence; latent record-key defect [D]

| Consumer line | Path | Disk | `_try_feed()` outcome (emulated) |
|---|---|---|---|
| `terrain_donor_props.gd:59` `FEED_LIB_INDEX` (primary, used at `:537`) | `res://assets/terrain_new/lib/pattern_lib_index.json` | **PRESENT** 55,784,815 B | Top keys include `generator_families` (64 dicts); `_try_feed():550-623` returns **TRUE** |
| `terrain_donor_props.gd:60` `FEED_FAMILY_INDEX` (secondary, `:540`) | same `lib/pattern_lib_index.json` | PRESENT | Not reached when primary succeeds |
| `terrain_donor_props.gd:61` `FEED_FALLBACK` (`:542-545`) | `res://assets/terrain/mountain_props.json` | PRESENT (legacy) | Not reached; `fallback_used` should be `false` |
| old `patterns/pattern_lib_index.json` | `res://assets/terrain_new/patterns/pattern_lib_index.json` | **ABSENT** | No longer a consumer path — `:59-60` were repointed; only a stale comment remains at `:41` |

- **[O] V89 C2 is closed on presence:** the 55.8 MB index now sits at the exact path the consumer reads, and the previously shape-incompatible `patterns/family_index.json` is no longer the nominal second feed. The `generator_families` branch added at `:567-582` (V66-F1) supplies pattern→family mapping.
- **[D] Latent functional caveat (not asset presence):** emulating `:590-617` with the actual file's key types, `source_map` resolves to `["generator_families"]` and `found = 64`, so `_try_feed()` returns true and `_records` is keyed by the literal name `"generator_families"` at `:616`. But `_collect_stamp()` looks up `_records.get(pattern_name)` at `:634`, while pattern names live in `generator_families[].patterns[].pattern`. Unless a name literally equals `"generator_families"`, records will be skipped (`skipped_no_records`) and zero props instanced — even though `fallback_used=false` would label the feed as donor. This needs a COORD code fix; V111 made no edit. **[U]** No Godot run was performed to confirm the runtime count. Independently corroborated by the sibling report `V106_i09_feed_verify.md:33-35,64-106` (also static-only), which further found 39,780 nested `Objects` records under `pattern_lib.sections[]` that `_try_feed()` never walks; its predicted `props_total = 0` and false `"DONOR LITERALS"` label are the same defect. This is a consumer-side blocker, not an asset-generation blocker; V111 does not elevate it to a gate or parity result.
- **[O]** `asset_index.pattern_lib` in the root manifest correctly points at `lib/pattern_lib_index.json`, consistent with the consumer.

---

## 6. Remaining ABSENT runtime paths with consumer file:line (task item 6)

| # | Exact path | Consumer file:line | Runtime consequence | Priority |
|---:|---|---|---|---|
| 1 | `res://assets/terrain_new/schemas/v1.schema.json` | spec/11 §11.4; V11 G11; root manifest `commit_policy.safe_to_commit[]`. **No runtime module reads it** (grep over `variant3d/**` for `v1.schema.json` / `schemas/` = 0 consumer matches) | No hard runtime fail; G11 validator / gate-2 input blocked | **P1** |
| 2 | `res://assets/terrain_new/atlas/seasons/winter/tile_index_atlas.png` | `variant3d/scripts/terrain_donor_mesh.gd:371` (season override, `_atlas_paths()`) | Winter override skipped; flat `atlas/seasons/tile_index_atlas_winter.png` is present but unread (V62 C3). Latent: no `set_season()` caller | P1 (latent) |
| 3 | `res://assets/terrain_new/atlas/seasons/winter/tile_index_atlas.manifest.json` | `variant3d/scripts/terrain_donor_mesh.gd:372` | Same as #2 | P1 (latent) |
| 4 | `res://scripts/terrain_donor_tiles.gd` | `variant3d/tests/t_terrain_donor.gd:42`, advisory at `:174`, `:700` | Advisory only; composer does not reference it. Not a `terrain_new` path — listed for completeness | Not blocker |
| 5 | `res://shaders/terrain_donor.gdshader` | `variant3d/scripts/terrain_donor_world.gd:36` (`DONOR_SHADER_ALIAS`, used at `:151`); V62 §3 #23 | Intentionally absent retired alias (V37); canonical `terrain_donor_shader.gdshader` is present | Not blocker |

**Resolved since V89 (no longer blockers):** root `manifest.json` (V89 §6 #1) is now PRESENT and X15-conformant; `patterns/pattern_lib_index.json` (V89 §6 #3) is no longer referenced — the consumer was repointed to `lib/`. **Inverse finding:** `lib/pattern_lib_index.json` is present and is now the canonical I09 path (V89's "present but unreferenced" note is superseded).

**[O] Nearly-ABSENT-but-landed after V89:** root `manifest.json` and the I09 feed repoint. Both would have been recorded ABSENT/broken by a stale single-pass read.

---

## 7. Per-tier verdicts and GO/NO-GO

| Tier / gate item | Verdict | Evidence |
|---|---|---|
| `cfg/` | **PASS** | 3 files / 3,575,402 B; JSON parses, `visual_parity_claim:false`, no absolute paths |
| `patterns/` | **PASS** | 777 files / 238,526,989 B; JSON parses; no raw donor binary; feed-shape caveat is a code issue (§5.2) |
| `lib/` | **PASS** | 1 file / 55,784,815 B at the exact I09 consumer path (`props.gd:59-60`); hash matches manifest |
| `atlas/` | **PASS** (presence / static path) | I08 constants resolve to valid on-disk PNG + manifest; 3 X15 §2.4 keys missing; GPU load UNVERIFIED |
| `masks/` | **PASS** | 4,467 files / 52,757,561 B; no donor path; sampled sha match |
| `<ROOT>` manifest (X15 §2.1-2.3) | **PASS** | 19/19 keys, schema literal, 5256 ordered tuples, `pack_id` recomputed, 20/20 sha sample |
| `schemas/` | **FAIL** | absent; no runtime hard-fail, but G11 validator input missing |
| donor-path hygiene (V78 effect) | **PASS** | 0/787 JSON with an absolute donor path across three tools |
| `visual_parity_claim:false` | **PASS** | 787/787 JSON; 0 true; root `validation.parity=false` |
| raw donor binary exclusion | **PASS** | only `.json` + `.png`; two-instrument hash sample |
| collective file/byte census | **PASS** | two commands agree exactly: 5257 / 364,646,949 B (5256 / 358,196,527 excluding root manifest) |
| I08 atlas pair | **PASS** (static) | presence + key compatibility; load UNVERIFIED |
| I09 lib index | **PASS** (presence) | file at consumer path; latent `_records` keying defect logged |
| pack stability / tracked state | **UNVERIFIED** | 0 tracked files; two passes agree point-in-time only; re-census before commit |

### **GO/NO-GO for asset readiness: GO (conditional)**

All six requested validation items pass at the V111 snapshot. The four V89 NO-GO blockers reduce to two non-blocking gaps: root manifest is now present and X15-conformant; I09's canonical lib index now exists at the path the consumer reads.

**Conditions attached to the GO (all outside a read-only asset worker's remit):**
1. **P1** — land `schemas/v1.schema.json` or explicitly retire G11; until then no strict validator run.
2. **P1 (latent)** — fix the I09 record-key mismatch (`terrain_donor_props.gd:616` vs `:634`) so the accepted feed actually instances donor props; then verify with a real Godot run.
3. **P1 (process)** — the pack is 100% untracked; re-run both census commands on a quiescent tree immediately before commit.
4. **P2** — add `unused_shipped_blocks`, `unused_note`, `atlas.upscaled_sources` to the atlas sub-manifest for strict X15 §2.4 conformance; resolve the C3 season path shapes.
5. **Permanent** — no donor parity claim. Parity stays `UNVERIFIED` / `PORT APPROXIMATION`; no gate was run for today's tree. GO here is **asset-pack byte readiness only**, not a gate PASS, not a cloned terrain, not a donor match.

**Explicitly NOT granted:** gate readiness, runtime/visual parity, commit readiness. Those remain **NO-GO / UNVERIFIED** per CHARTER.md §7 and V81 §1/§3/§7.

---

## 8. Handoff summary (5 lines)

1. **Verdict: GO (conditional) for asset-pack readiness.** Authoritative snapshot **5257 files / 364,646,949 B** (5256 / 358,196,527 excluding root manifest); two independent commands agree exactly.
2. **X15 root manifest PASS:** 19/19 keys, exact schema literal, 5256 sorted provenance tuples, `pack_id` `terrain_new_v1-b7984b3cb162cdf9` recomputed, **20/20** SHA samples match; key order is alphabetical not display order (non-semantic).
3. **Hygiene PASS across three tools:** 0/787 derived JSONs with an absolute donor path; 787/787 `visual_parity_claim:false`; no donor binary in `terrain_new`; **no parity claim**.
4. **Consumer split resolved on presence:** I08 atlas pair present and statically loadable; I09 lib index present at the repointed `lib/` path (V89 C2 closed). Latent code defect: `_records` keyed by `"generator_families"` not pattern name → props may be skipped.
5. **Guards:** read-only worker; no asset/code/shader/config/test/git/Godot change; exactly one repo file written (this report); scratch probes outside the repo; parity stays UNVERIFIED / PORT APPROXIMATION.

*End of V111 report. Exactly one repo file written; no other file was created, edited or deleted.*
