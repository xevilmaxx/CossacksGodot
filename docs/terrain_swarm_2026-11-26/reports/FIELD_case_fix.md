# FIELD CASE-FIX — `k_ravine_2` / `K_ravine_2.json` case-mismatch design report (READ-ONLY)

Status: RESULT IS NOT GOOD. Parity: UNVERIFIED. Chain: 0/6. No parity claim is made or implied.
This file is a design-only report. No source, asset, manifest, or config file was edited to produce it.
Rule: no runtime case-folding of names (no `to_lower()`/`to_upper()`/case-insensitive lookup on pattern names or paths).

## 1. Symptom (owner run)

Godot warning at runtime:

- Requested: `res://assets/terrain_new/patterns/k_ravine_2.json` (lowercase `k`)
- Stored: `res://assets/terrain_new/patterns/K_ravine_2.json` (uppercase `K`)
- Call chain: `_decode_pattern` (`variant3d/scripts/terrain_donor_inputs.gd:1080-1084`) → `_read_json` (`variant3d/scripts/terrain_donor_inputs.gd:131-135`).
- On Windows (case-insensitive FS) the open succeeds with a warning; on a case-sensitive export target the open fails and the pattern is skipped as `ABSENT`.

## 2. Byte-proven casing facts (read-only observations)

### 2a. Donor-cased filename — `pattern_decode_manifest.json`

`variant3d/assets/terrain_new/patterns/pattern_decode_manifest.json:3777-3785`:

- `"name": "k_ravine_2"` (line 3779) — lowercase cfg/section spelling.
- `"output": "K_ravine_2.json"` (line 3780) — uppercase `K`, the stamped on-disk filename.
- `"source": "data\\pattern\\K_ravine_2.pattern"` (line 3782) — donor file itself is uppercase `K`.
- `"source_sha256": "b262e1eb2f13476766aaef95d3eb7cf7579da723d3406bb2646e6d9f24500a8a"` (line 3783).
- `"status": "DECODED"`, `"label": "[O] DECODED grid+mask; tail semantics UNVERIFIED"` (lines 3778, 3784).

Sibling entries (`k_ravine_1.json`, `k_ravine_3.json`, …) are all lowercase; `K_ravine_2.json` is the sole case-only outlier in the `k_ravine_*` set (manifest lines 3770-3800).

Corroboration: `variant3d/assets/terrain_new/lib/pattern_lib_index.json:876458-876460` records `"name": "k_ravine_2"` with `"pattern_file": "K_ravine_2.pattern"`; line 1876342 records the donor bytes `data\pattern/K_ravine_2.pattern` with sha256 `b262e1…00a8a` (same hash as the manifest's `source_sha256`).

### 2b. Family side spells it lowercase — `family_index.json` + family file

- `variant3d/assets/terrain_new/patterns/family_index.json:70-75`: family `ravine_medium`, `cfg_line: 540`, `output: families/ravine_medium.json`, `pattern_count: 9`.
- `variant3d/assets/terrain_new/patterns/families/ravine_medium.json:469-470`: entry `"match": "k_ravine_2", "pattern": "k_ravine_2"` (lowercase), with `source_line_start: 555365`, `cfg_line: 547`, `join: "exact"` (lines 460-475).
- `family_index.json` census owner lists (e.g. line 796 inside `heightfield_census … owners`) likewise spell it lowercase `k_ravine_2`.
- So the mismatch is exactly: family/cfg key = lowercase `k_ravine_2`; stamped artifact + donor source = uppercase `K_ravine_2`.

### 2c. The exporter already knew — `export_donor_patterns.py:28`

`variant3d/tools/export_donor_patterns.py:27-29` (mirrored at `app/tools/export_donor_patterns.py:27-29`):

```python
ALIASES = {
    "k_ravine_2": "K_ravine_2",
}
```

with the comment (lines 22-26, 58) that these are "explicit, documented case fixes" accepted "only if a real .pattern file exists". This is the byte-proven source of the `k_ravine_2 → K_ravine_2` alias: exporter-time, one-entry, donor-file-existence-gated — NOT runtime case-folding.

### 2d. On-disk state (read-only glob)

Glob `variant3d/assets/terrain_new/patterns/*ravine_2*` returns exactly one file: `K_ravine_2.json` (uppercase `K`). (Observed on a case-insensitive Windows FS, so absence of a lowercase twin cannot be proven from here; on a case-sensitive target only the uppercase byte sequence exists.)

## 3. Every code site that builds a lowercase path for this name

All in `variant3d/scripts/terrain_donor_inputs.gd` (`PATTERN_DIR := "res://assets/terrain_new/patterns/"`, line 65):

| Site | Code | Effect for `k_ravine_2` |
|---|---|---|
| 1080 | `_decode_pattern`: `var path: String = PATTERN_DIR + name + ".json"` | builds `…/k_ravine_2.json` (lowercase) → the warning path; `FileAccess.file_exists` + `_read_json` at 1081-1084 |
| 1242 | `skipped.append("ABSENT " + PATTERN_DIR + n + ".json …")` (compact branch) | lowercase label for a missing compact key |
| 1244 | `FileAccess.file_exists(PATTERN_DIR + n + ".json")` (file branch, EXACT_PATTERNS loop) | lowercase existence probe |
| 1259 | `FileAccess.file_exists(PATTERN_DIR + n + ".json")` (file branch, family-pool loop) | lowercase existence probe for family names incl. `k_ravine_2` |
| 1279 | `loaded.append("PATTERN " + PATTERN_DIR + n + ".json")` | lowercase label recorded on success |
| 1256 | comment: "Exact-key lookup never aliases K_ravine_2 to k_ravine_2." | documents the current no-alias policy that produces the warning |
| 419 | `"ABSENT " + PATTERN_DIR + str(missing_name) + ".json …"` (compact `missing_family_pattern_files` loop) | lowercase label; compact manifest itself lists `"k_ravine_2"` in `missing_family_pattern_files` (`variant3d/assets/terrain_new/patterns/compact/manifest.json:1`) |

Name provenance (why `name` is lowercase): `_pattern_entry_name` (`terrain_donor_inputs.gd:148-154`) returns the `match` string verbatim and explicitly "never … case-fold a name" — so `k_ravine_2` flows unchanged from `families/ravine_medium.json:469` into every site above.

## 4. Proposed minimal fix — two options, one recommended

### Option A (RECOMMENDED): one-entry explicit alias constant — preserves donor casing

Add a single-entry, literal, reviewable constant next to `SHAPE_ALIASES` (line 74), e.g.:

```gdscript
const PATTERN_FILE_ALIASES: Dictionary = {"k_ravine_2": "K_ravine_2"}
```

Resolution rule (design): `var fname: String = str(PATTERN_FILE_ALIASES.get(name, name))`, then build `PATTERN_DIR + fname + ".json"` at sites 1080/1242/1244/1259/1279 (and 419 for label consistency). Dictionary keys/values stay in one `[O]` label block.

Byte-proven source of the single entry (all three must be cited in the implementing diff's comment):

1. Manifest: `pattern_decode_manifest.json:3779-3782` (`name k_ravine_2` → `output K_ravine_2.json` ← `source …K_ravine_2.pattern`).
2. Family row: `families/ravine_medium.json:469-470` (`match`/`pattern` = lowercase `k_ravine_2`).
3. Exporter precedent: `export_donor_patterns.py:28` (`"k_ravine_2": "K_ravine_2"`).

Why it preserves donor casing: the stored filename bytes `K_ravine_2.json` are never touched; only the lookup key is translated, and only for this one enumerated name.

Why it is safer than Option B: zero bytes change on disk; no hash/manifest churn; no export-tool or census updates; the alias is greppable, single-purpose, and cannot affect any other name because it is an exact-key lookup, not a fold.

Why it is NOT runtime case-folding: no `to_lower`/`to_upper`/case-insensitive comparison is introduced; any future case-only donor outlier would warn exactly as today until explicitly enumerated.

### Option B (NOT recommended): rename the file to lowercase `k_ravine_2.json`

Consequences (full churn, hence rejected as the primary proposal):

- File bytes unchanged but path bytes change → every stored hash/index entry naming `K_ravine_2.json` must be re-stamped: `pattern_decode_manifest.json:3780` (`output`), `manifest.json` asset census, `V62`-style byte censuses, compact `manifest.json` (`missing_family_pattern_files` entry `"k_ravine_2"` would resolve and change roundtrip accounting), and any `.import`/editor metadata referencing the old path.
- Breaks the exporter invariant: `export_donor_patterns.py:28` maps onto `K_ravine_2`; a re-run of the exporter would re-create the uppercase file, resurrecting the mismatch.
- Contradicts donor casing: the donor ships `K_ravine_2.pattern` (manifest line 3782, lib index line 876460); renaming the port artifact to lowercase moves AWAY from donor bytes, while Option A keeps artifact bytes identical to the donor-cased stamp.
- Verdict: Option B does not preserve donor casing and is less safe. Documented here only so the choice is explicit.

## 5. Why this fix is label/path-only, changes no donor value, and cannot assert parity

- The fix alters only the filename string used in `FileAccess`/`FileAccess.open` calls and in `skipped`/`loaded` diagnostic labels. It does not touch any decoded value: no `relief_float_grid` element, no `Min`/`Scale`/`Offset`/`TerrainScale`/`Replace` flag, no weight, frequency, seed, rotation, or selection logic changes.
- The decoded content of `K_ravine_2.json` is already labelled `[O] DECODED grid+mask; tail semantics UNVERIFIED` (manifest line 3778); routing the loader to the correct file does not verify the decode itself.
- Parity remains UNVERIFIED because: (a) no donor-execution comparison is performed here; (b) row-sign, global-clamp, and tail-semantics questions are independently open (see `_decode_pattern_doc` label at `terrain_donor_inputs.gd:1125`: "row sign / global clamp [U]; no parity claim"); (c) this report performed zero executions and zero file writes.
- Compact path note: `compact/manifest.json:1` lists `k_ravine_2` under `missing_family_pattern_files` with `roundtrip: PASS` and `visual_parity_claim: false`; the alias fix concerns the file-loader path only and must not be cited as compact-bundle coverage of this pattern.

## 6. Acceptance checklist for the implementing worker (not performed here)

1. Alias constant added with all three byte-proven citations (manifest 3779-3782, family row 469-470, exporter line 28).
2. All five path-building sites (1080/1242/1244/1259/1279) plus label site 419 resolve through it; no `to_lower`/`to_upper` anywhere in the diff.
3. Owner run re-checked on a case-sensitive listing: no `Case mismatch` warning for `ravine_2`, and `skipped` contains no new `ABSENT …ravine_2…` entry.
4. Report-back references this file; parity stays UNVERIFIED and chain stays 0/6.
