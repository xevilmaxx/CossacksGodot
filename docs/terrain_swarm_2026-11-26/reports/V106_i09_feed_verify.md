---
id: V106
ticket: "TERRAIN-SWARM-2026-11-26 / V106 — STATIC verification of COORD's I09 props-feed fix"
agent: "V106 (worker subagent, 30-agent DONOR-FIRST terrain swarm 2026-11-26; reports to COORD)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_EDIT__NO_GODOT_JOB__NO_GATE__NO_PARITY_CLAIM
owner_file: docs/terrain_swarm_2026-11-26/reports/V106_i09_feed_verify.md
files_created: [docs/terrain_swarm_2026-11-26/reports/V106_i09_feed_verify.md]
files_edited: []
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION", "NO_PARITY_CLAIM"]
multiple_passes: true
scope_guard: "Read-only: file reads, grep/Select-String, Test-Path/Get-Item, and bounded line-by-line / chunked Python scans of on-disk JSON. No source, shader, asset, config, test, manifest, git, app/, Godot, runner, gate or capture state touched. Scratch scripts live only in %TEMP%\\opencode\\. One repo file written (this report)."
parity_guard: "No donor binary was run or copied; no donor GPU A/B frame exists; no Godot process, gate or capture was produced. Every PASS below is a CURRENT-BYTES file:line / filesystem / static-trace verdict, NOT a gate result and NOT a donor-parity claim (CHARTER.md:43-44,122-135). All runtime effect remains [U]."
subject: "variant3d/scripts/terrain_donor_props.gd (1,038 lines, this pass) + variant3d/assets/terrain_new/lib/pattern_lib_index.json (55,784,815 B) + variant3d/assets/terrain_new/manifest.json (6,450,422 B)"
priors_read:
  - docs/terrain_swarm_2026-11-26/CHARTER.md
  - docs/terrain_swarm_2026-11-26/reports/V59_i09_audit.md
  - docs/terrain_swarm_2026-11-26/reports/V66_asset_gap_final.md
  - docs/terrain_swarm_2026-11-26/reports/V86_final_go_no_go.md
  - docs/terrain_swarm_2026-11-26/reports/X57_env_objects_decode.md
  - variant3d/scripts/terrain_donor_props.gd
  - variant3d/tools/decode_pattern_lib.py:761-824
  - variant3d/assets/terrain_new/lib/pattern_lib_index.json (bounded probes)
  - variant3d/assets/terrain_new/manifest.json (bounded probes)
---

# V106 — COORD's I09 feed fix, static verification

## 0. Verdict table — PASS/FAIL per mandated item

| # | Mandated verification item | Verdict | Decisive evidence (exact file:line) |
|---:|---|---|---|
| 1 | `FEED_LIB_INDEX` / `FEED_FAMILY_INDEX` point to `terrain_new/lib/pattern_lib_index.json`, which exists | **PASS** | `terrain_donor_props.gd:59-60`; `variant3d/assets/terrain_new/lib/pattern_lib_index.json` PRESENT 55,784,815 B (pass P3); `patterns/pattern_lib_index.json` ABSENT |
| 2 | `_try_feed()` parses I03 `generator_families` into `_family_of_pattern`, eliminating V66-F1's false "DONOR LITERALS" label | **FAIL** (parse present; advertised effect NOT achieved) | Parse: `props.gd:567-582` (assign `:582`); label unchanged at `:272-277`; feed accepted via `generator_families` at `:591-597,608-623` with `_records` keyed `"generator_families"` (`:616`) → `:634-638` misses → zero props, `_fallback_used=false` → false "DONOR LITERALS" label persists |
| 3 | `_try_feed` can produce NON-ZERO props from the lib index; index has nested `Objects` with BaseName/Position/Scaling that I09 reads | **FAIL** | Index DOES contain them: 668 `"block": "Objects"` / 39,783 `BaseName` / 39,783 `Scaling` (first record `pattern_lib_index.json:29388-29428`, `object_records_nested=39780` at `:27305`); but `_try_feed` scans only top-level keys (`props.gd:585-597`) and never walks `pattern_lib.sections[].blocks[].records[]` (`index:27368`) → `props_total` stays 0 (`props.gd:267`). Consumer-side blocker; see §6 |
| 4 | No `DONOR_UNITS=160` reintroduced; `visual_parity_claim:false` | **PASS** | `props.gd:24,88,467,650` are comment/string mentions only; no numeric `160` or `W/160` arithmetic; `visual_parity_claim:false` at `props.gd:435,480`, `index:1877030`, root `manifest.json` final member (pass P8) |

**No gate was run, no Godot process started, no capture produced, and no donor parity is claimed.**

## 1. Method — multiple passes (CHARTER.md:85-93)

No verdict was accepted from one reading. The two anomalies found (tool docstring vs actual bytes; the new parse branch not changing the label) were each re-instrumented.

| Pass | Instrument | Result / effect |
|---|---|---|
| P1 | Full `read` of current `terrain_donor_props.gd` (1,038 lines) | Captured all feed constants, `_load_feed`/`_try_feed`, label logic, `_collect_stamp`, `_normalize_record`, counters. File changed materially since V59/V86 (path constants + new `generator_families` branch). |
| P2 | Targeted `grep` of props for `DONOR_UNITS\|160\|visual_parity_claim`; second `grep` for `_try_feed\|_records\|generator_families\|pattern_lib\|_family_of_pattern` | 6 hits only: `:24,:88,:467,:650` (text) and `:435,:480` (parity). Confirmed exactly one `_try_feed` (`:550`) and one `_records` write site (`:616`). |
| P3 | `Test-Path` + `Get-Item` on 4 exact asset paths | `lib/pattern_lib_index.json` PRESENT 55,784,815 B; `patterns/pattern_lib_index.json` ABSENT; `patterns/family_index.json` PRESENT 55,507,231 B; `terrain_new/manifest.json` PRESENT 6,450,422 B. |
| P4 | Read `decode_pattern_lib.py:761-824` (`build_lib_index_doc`) | Source says `generator_families = family_groups` (`:770-777,:816`) with no object arrays and docstring "metadata only" (`:762-766,:784-787`). **Contradiction with P5** — see pass P9. |
| P5 | Bounded line-by-line Python stream probe of the 55 MB index (no `json.loads`, no full load) | 1,877,031 lines; enumerated 15 top-level keys; needle counts `BaseName` 39,783, `Position` 42,743, `Scaling` 39,783, `Up` 39,783, `"block": "Objects"` 668, `object_records_nested=39780` (`:27305`), `object_records_total=39783` (`:27306`), top-level `props/objects/Objects/by_pattern` = 0. |
| P6 | Targeted `read` of index `:27305-27434` and `:29355-29441` | Confirmed real nested record shape: section `"name"` (`:29370`), `blocks[]` → `"block": "Objects"` (`:29388`) → `records[]` (`:29390`) → `BaseName` **wrapper dict** with `value` (`:29392-29397`), `Position`/`Scaling`/`Up` as `W/X/Y/Z` dicts (`:29404-29427`), `line` (`:29428`). |
| P7 | Second independent bounded pass: indent-aware section-name → Objects-block ownership | 668 Objects blocks all attributed to section `name` = pattern name: `mng_1` block `:1122889` (name `:1122871`), `mng_2` `:1123749`, `g_mnt_1` `:539616` (name `:539598`), `brush_plt_1x1_mid` `:29388`. Data is keyed exactly as `_collect_stamp` needs — but not read. |
| P8 | Chunked byte scan of root `manifest.json` (1 MiB chunks) + tail slice | 509 per-entry `"visual_parity_claim":false`; final top-level member `"visual_parity_claim":false`; `"validation":{"parity":false,...}`. ASCII-safe output; no full parse. |
| P9 | Re-read tool source **and** re-probed actual file for the docstring/bytes contradiction | Accepted reading: `pattern_lib.sections[]` are plaintext `pattern.lib` index sections, so they include the donor `Objects[]` record lists; "metadata only" in the docstring means *no per-`.pattern` binary grid decode* (I02's job), not "no object records". Both preserved; V66-F1's premise that the generated index has no object fields is **refuted by current bytes**. |
| P10 | `grep` of `terrain_donor_world.gd` for `_props\|bind\|build(` | Composer seam repaired per V48 patch (b) at `world.gd:243-254`: direct `build(...)` call, no `bind()` dependency. Not a remaining blocker (agrees V86 row 11). |

## 2. Item 1 — feed paths — **PASS**

- [O] `FEED_LIB_INDEX: String = "res://assets/terrain_new/lib/pattern_lib_index.json"` (`props.gd:59`) and `FEED_FAMILY_INDEX: String = "res://assets/terrain_new/lib/pattern_lib_index.json"` (`props.gd:60`). Both are the canonical I03 output path; the stale `patterns/` path survives only in an explanatory comment at `:41`.
- [O] The target exists: `variant3d/assets/terrain_new/lib/pattern_lib_index.json`, 55,784,815 B (P3); `patterns/pattern_lib_index.json` is ABSENT. V66-F3 (path mismatch) and V86 rows 6/9 ("lib/ absent") are closed **on presence**.
- [D] `FEED_FAMILY_INDEX` now duplicates `FEED_LIB_INDEX`, so `_load_feed`'s second branch (`props.gd:540-541`) retries an identical path and is effectively dead; the old 55.5 MB `patterns/family_index.json` is no longer read. This is harmless for item 1 but means the `families`-Dictionary branch at `:559-566` has no live producer.
- **Fix:** none for this item. Note the stale comment at `:41` (cosmetic) if COORD edits I09 for item 3.

## 3. Item 2 — `generator_families` parse vs false label — **FAIL**

**What passes (the mechanical claim).**
- [O] The new branch is present at `props.gd:567-582`: it reads `root.get("generator_families")` (`:570`), requires an Array (`:571`), iterates family dicts (`:572-574`), takes `family` (`:575`) and `patterns` (`:576-577`), and writes `_family_of_pattern[str(pd["pattern"])] = fname` (`:579-582`).
- [O] The shape matches the real file: top-level `"generator_families": [` at `index:4`; each family has `family` (e.g. `"mng"`) and `patterns[]` whose entries carry a `pattern` key (first page of the index, read P4/P5). So the parse itself is correct and would label instance families donor-derived **if a record ever reached the instancer**.

**Why it fails (the advertised effect is not achieved).**
1. [O] The label logic is unchanged: `"DONOR LITERALS (I03 decoded feed)"` whenever `_fallback_used == false` and `_feed_source` is non-empty (`props.gd:272-277`); no reference to `_family_of_pattern`.
2. [O] `_load_feed` sets `_feed_source = FEED_LIB_INDEX` as soon as `_try_feed` returns true (`props.gd:537-538`), so `_fallback_used` stays false and the Z08 fallback at `:542-545` is never tried.
3. [O] `_try_feed` returns **true**: `generator_families` is a top-level Array and is **not** in the skip list (`props.gd:592-595`), so `source_map["generator_families"] = true` (`:596-597`); the `arr == true` branch then appends all 64 family dicts as "records" (`:608-614`), `_records["generator_families"]` is populated (`:616`), `found = 64` (`:617`) and the function returns true (`:623`).
4. [D] Consequently `_collect_stamp` looks up `_records.get(pattern_name)` (`props.gd:634`) — e.g. `"mng_1"`, `"g_mnt_1"` — finds nothing, increments `skipped_no_records` (`:635-638`), and **zero props** reach `_normalize_record`/`_add_to_batch`. `counts.props_total` stays 0 (`:267`).
5. [D] This is exactly V66-F1: a feed accepted on metadata, zero instances, and the false `DONOR LITERALS` provenance label. The new `_family_of_pattern` population cannot remove the label because it is downstream of a record lookup that never succeeds.
- **Fix:** not merely cosmetic — see §6 (label must be derived from actual instanced donor object records, or suppressed when `props_total == 0`).

## 4. Item 3 — can `_try_feed` produce non-zero props? — **FAIL**

### 4.1 The data IS in the index (so the blocker is consumer-side)

- [O] Bounded stream probe of `pattern_lib_index.json` (55,784,815 B, 1,877,031 lines): `"BaseName"` ×39,783, `"Position"` ×42,743, `"Scaling"` ×39,783, `"Up"` ×39,783, `"block": "Objects"` ×668, `object_records_nested = 39780` (`:27305`), `object_records_total = 39783` (`:27306`). Top-level keys: `description` `:2`, `family_count` `:3`, `generator_families` `:4`, `heightfield_census` `:10840`, `join_summary` `:26662`, `labels` `:26667`, `line_byte_offsets` `:26673`, `object_census` `:26924`, `pair_count` `:27313`, `pattern_lib` `:27314`, `schema` `:1876338`, `source` `:1876339`, `source_sha256` `:1876340`, `unverified_fields` `:1877024`, `visual_parity_claim` `:1877030`. There is **no** top-level `props`, `objects`, `Objects`, `by_pattern` or `records` key.
- [O] Concrete record: `pattern_lib.sections` starts at `:27368`; section `name = "brush_plt_1x1_mid"` at `:29370`, `blocks[]` with `"block": "Objects"` at `:29388`, `records[]` at `:29390`, first record `BaseName.value = "chamomile.2"` at `:29392-29397`, `Position.X/Y/Z` at `:29404-29409`, `Scaling.X/Y/Z` at `:29416-29421`, `Up.X/Y/Z` at `:29422-29427`, `line: 360` at `:29428`. Pass P7 confirmed 668 such blocks keyed by section `name`, including the stamp names I09 actually looks up: `mng_1` (`:1122871` name / `:1122889` block), `mng_2` (`:1123731`/`:1123749`), `g_mnt_1` (`:539598`/`:539616`).
- [D] So the required donor transforms exist and are keyed by pattern name. V59 §4 item 3 and V66-F1's *data-absence* premise are point-in-time stale; the assets caught up. The defect has moved entirely into the I09 consumer.

### 4.2 Why `_try_feed` still cannot reach them

- [O] `_try_feed` only inspects top-level keys: the preferred-key loop over `["props","objects","Objects","records","by_pattern"]` (`props.gd:585-589`) finds none, and the fallback loop (`:590-597`) adds only top-level **Arrays** not in the skip list. `pattern_lib` is a Dictionary (`:27314`), so it is never added to `source_map`; the sole survivor is `generator_families` (§3, item 2).
- [O] No code in `terrain_donor_props.gd` references `pattern_lib`, `sections`, `blocks` or `block == "Objects"` — second dedicated grep (P2) returns only the stale comment at `:41` and the constant at `:59`. There is no `families/*.json` loader (V59 §4 fix proposal) either; `FEED_FAMILY_INDEX` now points at the same index, so that route cannot supply objects.
- [D] `_collect_stamp` therefore misses every stamp (`props.gd:634-638`); `_records` contains only 64 family metadata dicts keyed `"generator_families"`. **Predicted `counts.props_total = 0`, `counts.skipped_no_records >= 1`, `feed.label = "DONOR LITERALS (I03 decoded feed)"`, `fallback_used = false`** — static trace only, runtime effect [U] (no Godot run by this worker).
- [D] A second, latent shape trap: even after adding the section walker, `_normalize_record` reads `BaseName` via `_s(...)` as a **String** (`props.gd:669`), while the JSON wraps it as `{label,line,literal,value}` (`index:29392-29397`). Passing the wrapper through would make `_sid_for_base` fail and increment `skipped_unknown_sid` (`:688-697`). The walker must unwrap `BaseName.value` (and the `Position`/`Scaling`/`Up` `X/Y/Z` members are already compatible with `_vec3` at `:991-1001`).

## 5. Item 4 — units / parity guards — **PASS**

- [O] `DONOR_UNITS` appears only in refutation text: header `:24`, constant comment `:88`, stats string `:467`, and `:650` ("no W/160, no x2"). No numeric assignment `= 160`, no `s = W/160` expression and no `/160` arithmetic anywhere in the file (P2). The only scale constant is `TILE_M := 2.0` at `:89`, documented as world-placement metres/cell only (V08 C2).
- [O] `visual_parity_claim: false` in both `_fresh_stats` constructors (`props.gd:435,480`), mirrored in `scale_contract` (`:480`); header guard `:5-12`; parity string `"UNVERIFIED — no donor GPU A/B frame"` at `:148,436`. Feed index top-level `"visual_parity_claim": false` (`index:1877030`). Root `manifest.json` ends with `"visual_parity_claim":false` and carries `"validation":{"parity":false,...}` (P8) with 509 per-entry false flags. No parity verdict string was found in props.gd (P2).
- **Fix:** none. Do not convert any internal label into a donor-parity verdict.

## 6. Exact remaining blocker and owner (props would still be zero)

**Blocker owner: I09 owner (`variant3d/scripts/terrain_donor_props.gd`) — consumer-side feed wiring and provenance label. Not an asset-generation blocker.**

1. **HIGH — object-feed reader missing.** Add a branch in `_try_feed` (`props.gd:550-623`) that walks `root["pattern_lib"]["sections"]` (`index:27368`), selects each section's `blocks[]` entry with `block == "Objects"` (`index:29388`), unwraps each `records[]` item's `BaseName.value` (`index:29392-29397`), and stores the record arrays in `_records[section["name"]]` (e.g. `mng_1` at `index:1122871`, `g_mnt_1` at `:539598`). Only then can `_collect_stamp`'s `_records.get(name)` (`:634`) resolve and `_normalize_record` (`:665`) produce transforms. Do **not** feed `generator_families` (metadata) or per-pattern 24-byte tails as records; keep the Z08 fallback and all `skipped_*` counters.
2. **HIGH — false provenance label.** Change `props.gd:272-277` so `"DONOR LITERALS"` requires at least one instanced donor object record (e.g. `counts["props_total"] > 0` and `not _fallback_used`); otherwise emit an explicit zero-props / UNVERIFIED label. Today the label is asserted while `props_total == 0` — the exact V66-F1 defect.
3. **COORD — gate assertion.** Assert `counts.props_total > 0` **and** `feed.fallback_used == false` **and** a `terrain_new` `feed.source`; never gate on `feed_source` alone (V66 §5.3, V86 rows 6/9). Composer seam is already repaired (`terrain_donor_world.gd:243-254`, V86 row 11), so it is not part of this blocker.
4. **[U] Runtime.** No Godot process, gate or capture was run; predicted zero props is a deterministic static consequence of the code paths above, not an observed runtime result. Everything remains **PORT APPROXIMATION / UNVERIFIED**, no donor parity claim.

## 7. Claim register

| # | Claim | Evidence | Label |
|---:|---|---|---|
| 1 | Both feed constants point to the existing `lib/pattern_lib_index.json` | `props.gd:59-60`; P3 Test-Path 55,784,815 B | [O] |
| 2 | `generator_families` → `_family_of_pattern` parse added and matches file shape | `props.gd:567-582`; `index:4` | [O] |
| 3 | False "DONOR LITERALS" label NOT eliminated; feed accepted on family metadata with zero props | `props.gd:272-277,537-538,591-597,608-623,634-638,267` | [O]/[D] |
| 4 | Lib index contains 39,780 nested `Objects` records with BaseName/Position/Scaling | `index:27305,27368,29388-29428`; P5/P6/P7 | [O] |
| 5 | `_try_feed` never reaches those records; props stay zero | `props.gd:585-597,616,634-638`; P2 negative grep | [O]/[D]/[U] |
| 6 | No `DONOR_UNITS=160`; `visual_parity_claim:false` in code and both JSON assets | `props.gd:24,88,467,650,435,480`; `index:1877030`; manifest tail | [O] |
| 7 | No gate, no Godot, no donor access; no parity claim | scope_guard, parity_guard | [O]/guard |

---
*End of V106. Exactly one repository file written (this report). Read-only static verification; no code, asset, config, test, manifest, git, app/, Godot, runner or gate state changed. No donor binary executed or copied. NO DONOR PARITY CLAIM.*
