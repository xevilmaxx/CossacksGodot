---
id: V101
ticket: "TERRAIN-SWARM-2026-11-26 / V101 — X15 root-manifest presence + schema validation (read-only)"
agent: "V101 (read-only verification worker, 30-agent DONOR-FIRST terrain swarm)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_EDIT__NO_ASSET_WRITE__NO_GODOT_JOB__NO_GATE__NO_PARITY_CLAIM
owner_file: docs/terrain_swarm_2026-11-26/reports/V101_root_manifest.md
files_created: [docs/terrain_swarm_2026-11-26/reports/V101_root_manifest.md]
files_edited: []
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION", "NO_PARITY_CLAIM"]
multiple_passes: true
scope_guard: "File reads, PowerShell Test-Path/Get-Item/Get-FileHash/ConvertFrom-Json, Python os.walk/rglob/hashlib/json. Scratch scripts confined to C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/ (outside repo). No asset, source, shader, config, test, manifest, queue, git index or app/ byte changed."
parity_guard: "No donor binary was read or executed by V101, no donor GPU A/B frame exists, no Godot job/gate/capture was run. Nothing below is a gate PASS or a donor-visual-parity claim; parity stays UNVERIFIED (CHARTER.md:43-44,122-135)."
---

# V101 — X15 root-manifest presence + schema validation

## 0. Verdict and multiple-pass log

**[O] Final verdict:** `variant3d/assets/terrain_new/manifest.json` is **PRESENT** and carries all **19** X15 §2.1 root keys. It is **X15-conformant on the visible core keys** (`schema`, `version`, `pack`, `pack_id`, `labels`, `visual_parity_claim`, `counts`, `asset_index`) but has **four strict-schema deviations** detailed in §3/§4: non-canonical `generator`, sha256-pinned (not semver) `tool_versions`, `offset:"n/a"` on **all 5,256** entries, and 8 `validation.checks` instead of the X15 §2.1 "16 assertions". **PASS/FAIL is per-key below; this is not a gate result and not a parity claim.**

The file was **absent at the start of this audit** and landed **during** it — a real mid-audit write, not a read disagreement:

| Pass | Instrument | Result |
|---|---|---|
| A1 | PowerShell `Test-Path -LiteralPath variant3d\assets\terrain_new\manifest.json` | **False** |
| A2 | PowerShell `Get-ChildItem -Recurse -File` + length sum (saved listing) | **5,256 files / 358,196,527 B**, no root file; tiers atlas 8 / cfg 3 / lib 1 / masks 4,467 / patterns 777 |
| B1 | Python `os.walk` + streaming `hashlib` (1 MiB chunks) | **5,257 files / 364,646,949 B** — `manifest.json` (6,450,422 B) now present; reconciliation shows the **only** delta is that one root file |
| A3 | PowerShell `Get-Item` / `Get-FileHash -Algorithm SHA256` | Length **6,450,422**; `CreationTimeUtc` **09:29:10**, `LastWriteTimeUtc` **09:29:33**; SHA `2a6a8290…dfde` |
| B2 | Python `json.load` + `hashlib` | Same length and same SHA; top-level keys parse; file byte-stable on re-read |
| A4 | PowerShell `ConvertFrom-Json` (independent parser) | Same 19 keys and literals; SHA still `2a6a8290…dfde` |
| B3 | Python `rglob` re-enumeration after reports landed | Still 5,257 / 364,646,949; entry/count verification (§4–§6) unchanged |

**[O] Concurrent landings observed in this session:** the root manifest appeared between A2 and B1; the reports `I15_asset_generation.md` (creation 09:34:13 UTC) and `V89_final_asset_seal.md` (creation 09:29:41, last write 09:36:02 UTC) were **absent** at my first search and present by A4. This agrees with V89 §0 (four mid-audit landings: atlas, masks, lib, root manifest). Every verdict below is from the quiesced final snapshot; COORD should still re-read before acting.

**[O] Ownership note (no invention):** `SWARM_BOARD.md:168` lists **I15** as `RUNNING` with "No ticket definition found on disk — do not invent an owner"; its report later landed. The durable ownership ledger is **N6 / I05**: `V11_ownership_ledger.md:98` (tool `variant3d/tools/build_terrain_new_manifest.py`) and `:130` (output `terrain_new/manifest.json`, "I05 via N6"). The N6 tool is **still absent** from `variant3d/tools/**`; the manifest was actually emitted by an **out-of-repo temp script** (`generator = "COORD-delegate/I15 (temp/opencode/i15/build_root_manifest.py)"`, I15 §2 command line 63). Reproducibility therefore depends on a non-committed generator.

## 1. Two independent reads (required)

| Item | Python read (`json.load` / `hashlib`) | PowerShell read (`ConvertFrom-Json` / `Get-FileHash`) | Agreement |
|---|---|---|---|
| Bytes | 6,450,422 | 6,450,422 | YES |
| SHA-256 | `2a6a8290bde0743c7eb88b6b7e5eaea860b1079d5617a1af15ff5dca2268dfde` | `2a6a8290bde0743c7eb88b6b7e5eaea860b1079d5617a1af15ff5dca2268dfde` | YES |
| Root key set (19) | `asset_index, atlas_manifest_v7_85_keys, census_reference, commit_policy, counts, donor_root_policy, entries, generator, generator_version, inputs_never_committed, labels, labels_used, pack, pack_id, schema, tool_versions, validation, version, visual_parity_claim` | identical list after sort | YES |
| `entries` length | 5,256 | 5,256 | YES |
| Literals | `schema=terrain_new/manifest/v1`, `version=1`, `pack=terrain_new_v1`, `pack_id=terrain_new_v1-b7984b3cb162cdf9`, `visual_parity_claim=false` | same | YES |

No key was accepted from one instrument only.

## 2. PASS/FAIL per X15 §2.1 schema key

X15 source: `docs/terrain_swarm_2026-11-26/reports/X15_asset_manifest_skeleton.md:17-23,44-83` (`§2.1` key table, `§2.2` tuple, `§2.3` pack-id, `§2.4` atlas contract, `§2.5` skeleton).

| Key | Observed value (both reads) | Verdict |
|---|---|---|
| `schema` | `"terrain_new/manifest/v1"` | **PASS** |
| `version` | `1` (JSON int) | **PASS** |
| `pack` | `"terrain_new_v1"` | **PASS** |
| `pack_id` | `"terrain_new_v1-b7984b3cb162cdf9"`; independently recomputed (§5) | **PASS** |
| `generator` | `"COORD-delegate/I15 (temp/opencode/i15/build_root_manifest.py)"` | **FAIL vs X15 canonical** (`variant3d/tools/build_terrain_new_manifest.py`): key present, value points at an out-of-repo temp script; N6 tool absent |
| `generator_version` | `"1.0.0"` | **PASS** |
| `tool_versions` | 5 tools, each `sha256:<64hex>`; all five hashes match the on-disk tool bytes (§6) | **DEVIATION**: X15 `§2.1` specifies a tool→**semver** map naming 6 tools incl. `build_terrain_new_manifest.py` / `validate_terrain_new.py` and `_new.py` aliases (V11 CR6 treats PLAN names as canonical). Presence **PASS**, value type/name set **FAIL** |
| `labels` | `["[O]","[D]","[I]","[U]","PORT APPROXIMATION","NO_VISUAL_PARITY_CLAIM"]` — exact X15 §2.5 array | **PASS** |
| `labels_used` | 10 values, subset of X15 §2.5's 12 (omits `UNVERIFIED_EMPTY_CELLS`, `APPROX_ALPHA_INTENSITY_FORMULA`) | **PASS** (present/self-consistent); **MINOR DEVIATION** from example list |
| `donor_root_policy` | `"$COSSACKS3_DIR (value NOT recorded as an absolute path in committed output)"`; 0 absolute donor paths across all 787 JSONs (my sweep + V89 §4.1) | **PASS** |
| `inputs_never_committed` | exact 7-item X15 array | **PASS** |
| `atlas_manifest_v7_85_keys` | `top_level`, `atlas_keys`, `layout_entry_keys`, `additive_key` — X15 §2.4 lists reproduced verbatim | **PASS** |
| `entries` / provenance tuple | 5,256 records; 8/8 tuple fields in every record; sorted by `(source,offset,output)`; all `visual_parity_claim=false`; all 5,256 `output_sha256` verified against emitted bytes — see §4 | **MIXED**: field presence/ordering-of-logic **PASS**; `offset` value and physical key order **FAIL** (§4) |
| `asset_index` | 10 keys; every referenced path exists on disk (§6) | **PASS** |
| `counts` | `by_top` and `by_ext` match the independent census exactly: 5,256 files / 358,196,527 B excluding the manifest itself | **PASS** |
| `census_reference` | X15 census fields + `i15_generated_file_count=5256`, `i15_generated_bytes=358196527`, `i15_root_manifest_excluded_from_own_counts=true` | **PASS** |
| `commit_policy` | `safe_to_commit` / `never_commit` arrays present; consistent with X15 §2.5 licence guard | **PASS** |
| `validation` | `parity:false` and 8 `checks` strings | **DEVIATION**: X15 §2.1 calls for 16 assertions; 8 present. **PASS** on `parity:false` |
| `visual_parity_claim` | `false` at root and in all 5,256 entries | **PASS** |

**Key set completeness: 19/19 present, 0 missing, 0 extra.** No donor parity claim anywhere.

## 3. Provenance tuple detail — `§2.2`

Required chain: `source:offset → output → source_sha256 → output_sha256 → label → visual_parity_claim:false` (X15 §2.2 adds `decoder`; the manifest has 8/8 fields).

- **PASS — fields present:** every one of the 5,256 entries has `source`, `offset`, `output`, `source_sha256`, `output_sha256`, `label`, `decoder`, `visual_parity_claim`. Missing-key count **0**.
- **PASS — sorting:** `entries == sorted(entries, key=(source, offset, output))` → **True**.
- **PASS — parity literal:** 5,256/5,256 entries `visual_parity_claim:false`; no `true`.
- **PASS — null discipline:** `output_sha256` null count **0**; `source_sha256` null count **4,480** (plus 776 non-null, all 64-hex); every null-`source_sha256` entry carries an `UNVERIFIED` label; null-without-UNVERIFIED count **0**. X15's rule that a null *output* needs an UNVERIFIED label is vacuously satisfied.
- **PASS — SHA closure:** 5,256/5,256 `output_sha256` values recomputed from the emitted files match; output-missing **0**, output-not-covered-by-any-entry **0**. (V89 §3 declared this unverified; V101 closes it.)
- **FAIL — `offset` value:** **5,256/5,256** entries have `offset:"n/a"`. X15 `§2.2` requires a byte range `0xNN..0xMM`, or `path:line` until F02 publishes record boundaries. `"n/a"` is neither, so the `source:offset` locator half of the chain is not X15-conformant even where `source_sha256` is non-null (e.g. `patterns/K_ravine_2.json` ← `data/pattern/K_ravine_2.pattern`, 64-hex source hash but offset `"n/a"`).
- **FAIL — physical key order:** every entry is emitted as `decoder, label, offset, output, output_sha256, source, source_sha256, visual_parity_claim` (alphabetical, from canonical `sort_keys=True`), not the documented chain order `source, offset, output, source_sha256, output_sha256, label, decoder, visual_parity_claim`. Semantically all fields are present; the **written** tuple order does not match X15 §2.2/§2.5.

## 4. Deterministic `pack_id` — recomputed, PASS

X15 §2.3 algorithm, applied to the committed manifest by V101 (independent of I15's generator):

```
canonical_json(o) = json.dumps(o, sort_keys=True, separators=(",",":"),
                               ensure_ascii=False) + "\n"        # UTF-8
seed = {schema, version, pack, generator, generator_version, tool_versions,
        entries: sorted(entries, key=(source, offset, output)),
        counts, visual_parity_claim: false}
pack_id = pack + "-" + sha256(canonical_json(seed)).hexdigest()[:16]
```

- Recomputed: `terrain_new_v1-b7984b3cb162cdf9`
- Committed:  `terrain_new_v1-b7984b3cb162cdf9` → **match, PASS**
- Suffix is 16 lowercase hex. Seed excludes wall-clock time, mtimes, absolute donor root, `\` vs `/`, and `--out`.
- Note: the manifest does **not** carry the `pack_id_algorithm` explanatory key shown in the X15 §2.5 skeleton (that key is absent from the §2.1 table); recomputation still succeeds from the documented §2.3 rule. V89 §3 explicitly left this as `[U]`; V101 closes it.
- **Caveat [U]:** this proves the committed id matches the canonical seed of the committed bytes; it does **not** prove two clean generator runs are byte-identical (no `--check` was run here; I15 §5 reports two identical generator runs at SHA `2a6a8290…dfde`). Tool bytes were edited by other workers mid-wave (I15 §0.5), so a later rebuild with different tool hashes would legitimately change `pack_id`.

## 5. Per-tier file counts and SHAs (computed from actual files)

Tier aggregate = `sha256( utf8( join(sorted("relpath\tbyte_count\tsha256"), "\n") + "\n" ) )`; rows use paths **relative to the tier root** (the total uses paths relative to `terrain_new/`). Recomputed on the final snapshot; all counts, byte sums and digests match I15 §4 exactly.

| Tier | Files | Bytes | Aggregate SHA-256 | Manifest cross-check |
|---|---:|---:|---|---|
| `atlas/` | 8 | 7,551,760 | `1e9abaa1d44e8eac4b59842c8a81d0a9a17323724a689ba40809cdcb14e2ca81` | `counts.by_top.atlas` exact; 8/8 entry SHAs verified |
| `cfg/` | 3 | 3,575,402 | `6a74c858244627d939b3da74b912a5705af8fd2e0b09df527f1dc63e0a5c322b` | exact; 3/3 verified |
| `lib/` | 1 | 55,784,815 | `1f76c71d35b30170a789d72dd70c6de5b197e06044f097b1b9b60f1230b5e797` | exact; 1/1 verified |
| `masks/` | 4,467 | 52,757,581 | `a0dffc2039cd86e0a55fe83d2a40bddcf37821d7d816727456c470c84917eec9` | exact; 4,467/4,467 verified |
| `patterns/` | 777 | 238,526,989 | `2e7687ba3d76d9a4c9774fa30ad5fd6626688b4be1719ac7747712bc35136cf6` | exact; 777/777 verified |
| root `manifest.json` | 1 | 6,450,422 | `2a6a8290bde0743c7eb88b6b7e5eaea860b1079d5617a1af15ff5dca2268dfde` | self-excluded from its own `counts` |
| **TOTAL** | **5,257** | **364,646,949** | `2e2f5604e4c327e4eec24a61a374ec92497e45bd87e901b9ccb019b97ca4a8a6` | = manifest's 5,256 / 358,196,527 + itself |

`counts.by_ext`: `.json` 786 / 309,945,833 B and `.png` 4,470 / 48,250,694 B **excluding** the root manifest (787 / 316,396,255 B including it) — both recomputed and matched. Extensions across the whole tree are exactly `.json` + `.png`; no `.tga/.dds/.bmp/.pattern/.lib/.exe`.

`asset_index` resolution, all **10/10 present**: `atlas/tile_index_atlas.png`, `atlas/tile_index_atlas.manifest.json`, `atlas/alpha.png`, `atlas/alphavert.png`, `atlas/seasons/winter_aliases.json`, `lib/pattern_lib_index.json`, `patterns/family_index.json`, `patterns/pattern_decode_manifest.json`, `masks/mask_index.json`, `cfg/constants.json`.

`tool_versions` hash pins, all **5/5 match on-disk tool bytes**: `decode_donor_cfg.py abbf0571…`, `decode_donor_pattern.py 00c0591a…`, `decode_pattern_lib.py ddfb8688…`, `decode_donor_masks.py 667b71fb…`, `build_terrain_new_atlas.py 3a92d053…` (full values in the manifest). The temp generator that wrote the manifest is **not** among them.

## 6. Consumer / blocker status

- **At pass A1 (manifest absent)** the only consumer affected was **I12** `variant3d/tests/t_terrain_donor.gd:44` — `const ASSET_MANIFEST := "res://assets/terrain_new/manifest.json"`. It is consumed only as an **advisory** at `:700-703` (`optional_presence`, `FileAccess.file_exists`) and as one of the source-scan paths at `:723-738` (`visual_parity_claim_false`, `:735`). There is **no hard-fail gate** on it. With the manifest now present, that advisory is `true` and its `visual_parity_claim:false` is present — **static PASS only**, no Godot run.
- **Producer:** N6 `variant3d/tools/build_terrain_new_manifest.py` is **absent** (`V11_ownership_ledger.md:98,130`; I05 via N6); I05's `--emit-root-manifest` emits an explicitly PARTIAL atlas-only object (`build_terrain_new_atlas.py:695-714,921-922,992-994`). The delivered file came from I15's temp script instead. **Tooling ownership remains open even though the file now exists.**
- **Not closed by this manifest (out of V101 scope, recorded for COORD):** V89 §1.6/§5 — I09 reads `patterns/pattern_lib_index.json` (`terrain_donor_props.gd:59`) while I03 wrote `lib/pattern_lib_index.json`; `schemas/v1.schema.json` absent. These keep the pack NO-GO in V89; V101 does not claim otherwise.

## 7. Honest ceiling

- All findings are **static** (file reads, hashes, parsed JSON). No Godot job, gate, runner, capture, asset write or git operation was performed by V101; the only repo file written is this report.
- **No donor parity claim.** `visual_parity_claim` is `false` everywhere; the pack is `PORT APPROXIMATION` with donor-path provenance only. There is no donor GPU A/B frame (CHARTER.md:43-44,122-135). `pack_id` determinism is verified against the committed bytes, not by re-running the out-of-repo generator.
- Point-in-time: the tree was still being written by other workers during this audit; COORD must re-read `manifest.json` and re-run the §4/§5 checks after quiescence before treating any of this as a seal.

*End of V101 report. Exactly one repo file written: this report. No other file created, edited or deleted.*
