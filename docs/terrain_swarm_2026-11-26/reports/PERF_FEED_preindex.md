---
id: PERF-FEED
ticket: "TERRAIN-VISUAL-WAVE-2026-11-26 / PERF-FEED — offline props pre-index prototype"
worker: "PERF-FEED (worker subagent, donor-terrain VISUAL WAVE; reports to COORD)"
wave: VISUAL
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_EDIT__NO_GODOT__NO_RUNNER__NO_GIT_WRITE__NO_DONOR_WRITE
owner_file: docs/terrain_swarm_2026-11-26/reports/PERF_FEED_preindex.md
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_claim: false
parity_guard: "No donor GPU A/B frame exists or was produced; no donor binary was executed and no donor file was written. Every figure below is a Python-side, offline, read-only measurement on the committed derived JSON. NO DONOR PARITY CLAIM."
scope: "Read first: VISUAL_WAVE_CHARTER.md, reports/W06_performance_audit.md, reports/W07_props_visual_audit.md, reports/X15_asset_manifest_skeleton.md, variant3d/assets/terrain_new/lib/pattern_lib_index.json. Exactly one repo file written: this report. Prototype extractor + emitted JSON exist ONLY under %TEMP%/opencode/props_preindex/."
scratch: "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\props_preindex\\"
---

# PERF-FEED — deterministic offline pre-index of `pattern_lib_index.json`

## 0. Executive summary

1. **[O]** W06's largest single startup JSON is I09's
   `variant3d/assets/terrain_new/lib/pattern_lib_index.json`: **55,784,815 B
   (53.201 MiB)**, SHA-256 `a9fff8a1b7f5d35ce5697b1156be06247b58441203c2dd988f870849c3d91581`.
   W06 measured 171,093,702 B (163.1 MiB) of JSON text on the clean 636 path.
2. **[O]/[D]** A one-pass offline prototype reduces that one file to **78 compact
   JSON files totalling 11,015,153 B (10.505 MiB)** — **80.254% smaller**,
   0.19746× of the input — while preserving **39,780 records** and **235 distinct
   `BaseName` values**. Applied to W06's total, startup JSON text would fall from
   171,093,702 B to **126,324,040 B (120.472 MiB)**, a **44,769,662 B (26.17%)**
   reduction, with I17's 115.3 MB feed unchanged.
3. **[O]** Python 3.14.3 parse timing (no `tracemalloc`, 3 runs × 2 sessions, cold
   and warm): monolith **0.9471–1.2700 s**; loading the compact bundle with all
   records resident **0.2612–0.4825 s**; observed median speedup **2.76×–3.61×**.
   Traced peak allocation: monolith **149,509,487 B (142.583 MiB)** vs bundle
   resident **45,927,641 B (43.800 MiB)** = **3.255× lower**, and bundle
   streamed-and-discarded **4,842,346 B (4.618 MiB)** = ~30.9× lower.
   These are **Python measurements on this machine, not Godot timings** [U].
4. **[O]** Independent verification: **665/665 sections**, **39,780/39,780
   records**, **0 schema violations**, **0 bit-level float mismatches** against
   the source nested records, source SHA-256 unchanged, and two full rebuilds
   produced **byte-identical output** (all 78 files).
5. **[D]/[U]** The mandated count 39,780 is reached by including only records
   with `style == "nested"`. The source has **39,783** nested-Objects records;
   **3** records carry `style == "inline"` and are excluded. They are
   structurally identical to nested records, so this exclusion is a **policy
   choice to match the mandated count, not a data defect**. W07 counted 39,783.
   COORD/I03 must confirm the 3-record policy before adoption (§7, open item 1).
6. **[I]** No repo asset, code, shader, config, Godot process, runner job, git
   state or donor file was touched. Adoption is a COORD/I03 decision; this
   report makes **no parity claim**.

---

## 1. Scope, method and evidence discipline

- Read-only. Exactly one repository file written: this report. No `.gd`,
  `.json`, `.shader`, asset, test, result, `app/**`, donor file or git state was
  edited. No Godot process, runner subcommand, gate or capture was run.
- All scratch artefacts live in
  `%TEMP%\opencode\props_preindex\`: `explore.py`, `probe_delta.py`,
  `probe_inline.py`, `probe_families.py`, `extract_props_preindex.py`,
  `verify.py`, `finalize.py`, `metrics.json`, `out/props_index.json`,
  `out/families/*.json`. **Nothing from this scratch tree is proposed for
  commit as-is.**
- The extraction reads the 55.8 MB file **once** with `json.load()`, then walks
  `pattern_lib.sections[].blocks[]` in memory. It never re-reads the monolith.
- Labels: **[O]** literal byte/count/hash observation; **[D]** deterministic
  consequence; **[I]** inference; **[U]** unverified without a Godot run;
  **PORT APPROXIMATION** = port-side substitute. Cost attribution is never
  presented as a measured Godot stage time.
- Multiple-pass discipline: 8 separate probes (structure, field census,
  discrepancy hunt, inline inspection, family coverage, extraction, independent
  round-trip verification, determinism re-run). No anomaly was accepted from a
  single reading.

---

## 2. Source-shape findings [O]/[D]

### 2.1 Measured source census

| Metric | Value |
|---|---:|
| File bytes | 55,784,815 (53.201 MiB) |
| SHA-256 | `a9fff8a1b7f5d35ce5697b1156be06247b58441203c2dd988f870849c3d91581` |
| Top-level keys | 15 (`description, family_count, generator_families, heightfield_census, join_summary, labels, line_byte_offsets, object_census, pair_count, pattern_lib, schema, source, source_sha256, unverified_fields, visual_parity_claim`) |
| `pattern_lib.sections` | 680 (all names distinct, none empty) |
| `blocks[].block == "Objects"` | 668 |
| Other block kinds | `Waters` 37, `Decals` 10 |
| Sections with Objects blocks | 668 |
| Sections with ≥1 `style=="nested"` record | **665** |
| Nested Objects records (`style=="nested"`) | **39,780** |
| `style=="inline"` records (excluded) | **3** |
| Total Objects records (nested + inline) | **39,783** |
| Distinct `BaseName.value` (nested set) | **235** |
| Records missing any of the 5 fields | 0 |
| Non-numeric / non-finite vector components | 0 |
| Non-string / empty `BaseName.value` | 0 |

### 2.2 The 39,783 → 39,780 discrepancy

Three records have `style: "inline"` instead of `style: "nested"`. Every field
is present and the schema is otherwise identical:

| Section | BaseName | donor `line` |
|---|---|---:|
| `fb_6` | `firsmall1` | 533,933 |
| `fb_11` | `pinebroken2.2` | 534,589 |
| `fb_33` | `plantain` | 537,975 |

These three sections have no other Objects records, so they are absent from the
emitted bundle entirely (665 output sections, not 668). **[D]** Excluding them
is the only single deterministic predicate found that yields exactly the
mandated 39,780 while retaining all 235 distinct BaseNames — the three names
also occur among nested records, so the distinct count is unchanged.

### 2.3 What must be unwrapped — and what must not

**[O]** Only `BaseName` is a wrapper dictionary:
`{"label":"OBSERVED","line":N,"literal":"minegold","value":"minegold"}`.
The prototype emits only its `value` string. `Position`, `Direction`, `Up` and
`Scaling` are plain `{"W":…,"X":…,"Y":…,"Z":…}` dictionaries — they are **not**
`{value}` wrappers and must be copied verbatim, including `W`.

**[O] `Position.W` is not constant.** Observed values include integer `1`
(36,532 records), `0.999999821186066` (423), `0.999999940395355` (170),
`0.840595245361328` (283), `-350.601593017578` (919), `-61.2998085021973`
(213) and `-6213.37548828125` (72). `Direction.W`, `Up.W` and `Scaling.W` are
`0` in all 39,780 records. **[D]** Dropping `W` would silently destroy donor
data; the prototype retains it. This is a deliberate divergence from a purely
`_vec3()`-shaped (X/Y/Z-only) index.

**[O]** `RaceName`, `line`, `style`, `label` and `literal` are dropped. W07 §6
notes that `_normalize_record()` consumes only base/position/scale/up/yaw;
`RaceName` is not in the mandated field list.

---

## 3. Exact emitted schema [D]

### 3.1 `props_index.json`

```json
{
  "schema": "terrain_new/props_preindex/v1",
  "source": "variant3d/assets/terrain_new/lib/pattern_lib_index.json",
  "source_sha256": "a9fff8a1b7f5d35ce5697b1156be06247b58441203c2dd988f870849c3d91581",
  "source_bytes": 55784815,
  "record_rule": "pattern_lib.sections[].blocks[block=='Objects'].records[] where record.style=='nested'",
  "excluded_inline_records": 3,
  "record_count": 39780,
  "distinct_basenames": 235,
  "family_count": 77,
  "section_count": 665,
  "files": { "<section.name>": "families/<family>.json" },
  "families": { "<family>": "families/<family>.json" },
  "section_family": { "<section.name>": "<family>" },
  "visual_parity_claim": false
}
```

`files` has **665** entries (pattern/section name → file), `families` **77**,
`section_family` **665**. The index is **49,371 B**. The mandated
"pattern name → file" map is `files`; `families` and `section_family` are
added so a consumer can locate a section's array inside its family file.

### 3.2 `families/<family>.json` (77 files, 10,965,782 B total)

```json
{
  "family": "mng",
  "sections": {
    "mng4": [
      {
        "BaseName": "pinesmall1",
        "Position": {"X": 2.05330657958984, "Y": -3.37003257300239e-07,
                     "Z": 0.987769603729248, "W": 1},
        "Direction": {"X": 0, "Y": 1, "Z": 0, "W": 0},
        "Up": {"X": -0.891006469726563, "Y": 0, "Z": -0.453990578651428, "W": 0},
        "Scaling": {"X": 0.5, "Y": 0.5, "Z": 0.5, "W": 0}
      },
      {"BaseName": "minegold", "...": "..."}
    ],
    "mng_1": []
  }
}
```

Field contract, exhaustive:

| Key | Type | Rule |
|---|---|---|
| `family` | string | filename stem; family grouping key |
| `sections` | object | pattern/section name → array of records |
| record | object | **exactly** 5 keys: `BaseName`, `Position`, `Direction`, `Up`, `Scaling` |
| `BaseName` | string | `source_record.BaseName.value`, verbatim Unicode |
| `Position`/`Direction`/`Up`/`Scaling` | object | **exactly** 4 keys `X`,`Y`,`Z`,`W`, IEEE-754 shortest round-trip, verbatim from source |

Serialization: `json.dumps(..., ensure_ascii=False, separators=(",", ":"),
allow_nan=False)`, UTF-8, no trailing newline, sorted file/section key order,
original record order within a section. No timestamps, mtimes, absolute paths,
RNG state or hash-map iteration order participate.

### 3.3 Family grouping

Deterministic rule: `family = re.sub(r"_?\d+$", "", section_name) or section_name`.
Examples: `g_mnt_1`→`g_mnt`, `mng_1`→`mng`, `plt1`→`plt`,
`m_swamp_12_old`→`m_swamp_12_old`. This yields **77** families covering all 665
emitted sections; the authoritative top-level `generator_families` index maps
only 459/665 sections (it contains 504 names / 58 families), so it was **not**
used as the grouping key. **[D]** Grouping is metadata-free and reproducible
from section names alone.

### 3.4 Why per-family, not per-section

A first prototype emitted **665 per-section files**. Its bundle load measured
**13.337 s** under `tracemalloc` versus 6.431 s for the monolith under the same
tracing — **file-open fan-out dominated**. **[D]** 665 `open()` calls on Windows
cost more than parsing the extra metadata. Collapsing to 77 family files cut
traced bundle load to well below the monolith (§5). Per-section remains a
valid but slower alternative; per-family is the recommended layout.

---

## 4. Prototype algorithm (deterministic) [D]

1. Byte-stream SHA-256 + `os.path.getsize()` of the source (read-only).
2. **One** `json.load()` of `pattern_lib_index.json` into memory.
3. For each `section` in `pattern_lib.sections` (source order):
   - `name = str(section["name"]).strip()`;
   - for each `block` where `block["block"] == "Objects"`:
     - for each `record` where `record.get("style") != "inline"`:
       - assert the 5 mandated keys exist;
       - `BaseName ← record["BaseName"]["value"]`;
       - each vector ← `{X,Y,Z,W}` copied verbatim;
       - assert all 16 components finite and `BaseName` is a non-empty string;
       - append to `by_section[name]`, preserving source order.
4. Group sections by `family_of(name)`; sort family keys and section keys.
5. Emit 77 family files with compact separators, then `props_index.json`.
6. Independently re-parse the bundle and compare every field to a fresh source
   parse, bit-by-bit (§6).

**Consumer-facing contract (not implemented here):** `props_index.json["files"][stamp_name]`
gives the family file; `["sections"][stamp_name]` inside that file gives the
record array. This replaces W07 §7.1's nested walker without ever calling
`JSON.parse_string()` on the 55.8 MB metadata index.

---

## 5. Measurements

All figures from `metrics.json`; timing measured **without** `tracemalloc`
(tracing every allocation inflated parse time ~5× in pass 1), memory measured
in **separate** traced passes. Two independent full extractions were run.

### 5.1 Size

| Quantity | Bytes | MiB | Note |
|---|---:|---:|---|
| Input `pattern_lib_index.json` | 55,784,815 | 53.201 | SHA-256 `a9fff8a1…91581` |
| 77 family files | 10,965,782 | 10.458 | 665 sections, 39,780 records |
| `props_index.json` | 49,371 | 0.047 | 665 `files` + 77 `families` + 665 `section_family` |
| **Output total** | **11,015,153** | **10.505** | **0.19746× input; −80.254%** |
| W06 total startup JSON (unchanged I17) | 171,093,702 | 163.214 | W06 §0 |
| Projected total with bundle instead of monolith | 126,324,040 | 120.472 | −44,769,662 B, −26.17% **[D]** |

Largest emitted families [O]: `k_ravine_big_stone` 778,872 B / 2,758 records;
`j_big_plt` 645,343 B / 2,327; `k_ravine` 580,302 B / 2,062; `desert_plt`
449,272 B / 1,611; `k_plain` 436,216 B / 1,537.

### 5.2 Parse time — Python 3.14.3, Windows, 3 runs per pass

| Load | Runs (s) | Median (s) | Min (s) |
|---|---|---:|---:|
| Monolith 55.8 MB | 0.9471, 1.0927, 1.0410 / 1.1047, 1.2700, 1.1992 | 1.0410 / 1.1992 | 0.9471 |
| Bundle, all 39,780 records resident | 0.2612, 0.2887, 0.4060 / 0.4349, 0.4825, 0.3492 | 0.2887 / 0.4349 | 0.2612 |
| Bundle, streamed + discarded per family | 1.5956, 0.2940, 0.2508 / 1.8119, 0.4076, 0.3197 | 0.2940 / 0.4076 | 0.2508 |

- **[O]** Observed median speedup (monolith ÷ resident bundle): **2.757×** and
  **3.606×** across the two sessions; min-based **3.164×**.
- **[U]** Run-to-run variance is large (cold file cache on the first pass:
  bundle stream 1.5956/1.8119 s). Do not present a single speedup number as a
  stable benchmark.
- **[U]** No Godot `JSON.parse_string()` or `FileAccess.get_file_as_string()`
  timing was taken. W06's headless parse-only jobs (3.9567–4.7718 s whole
  process) are context, not a subtractable constant.

### 5.3 Peak traced allocation

| Load | Peak bytes | MiB | Ratio vs monolith |
|---|---:|---:|---:|
| Monolith parse | 149,509,487 | 142.583 | 1.00× |
| Bundle, all records resident | 45,927,641 | 43.800 | **3.255× lower** |
| Bundle, streamed + discarded | 4,842,346 | 4.618 | ~30.9× lower |

**[D]** The fair like-for-like comparison is resident-to-monolith (3.255×).
The streamed figure is a lower bound that assumes the consumer processes one
family at a time and does not retain all records. **[U]** `tracemalloc` counts
Python allocations only; Godot `Variant`/`Dictionary` overhead, GC and peak
RSS/VRAM are unmeasured (W06 §9 item 2 remains open).

---

## 6. Validation results

Independent verifier (`verify.py`) re-parsed source and bundle and compared
every record field:

| Check | Result |
|---|---|
| Source sections with ≥1 nested record / output sections | 665 / 665 |
| Source nested records / output records | 39,780 / 39,780 |
| Distinct `BaseName` source / output | 235 / 235 |
| Inline records excluded | 3 (as listed in §2.2) |
| Records with wrong key set | **0** |
| Vectors with wrong key set (not exactly X/Y/Z/W) | **0** |
| Bit-level float mismatches (`struct.pack(">d", …)`) | **0** |
| `visual_parity_claim` | `false` |
| Source SHA-256 after extraction | unchanged (`a9fff8a1…91581`) |
| Two complete rebuilds → all 78 files byte-identical | **yes** |
| All extractor self-checks (`metrics.json.validation`) | 9/9 `true` |

---

## 7. Validation checklist for COORD/I03 adoption

Run each item; treat any failure as a stop condition.

1. **Source anchor** — `sha256(pattern_lib_index.json)` =
   `a9fff8a1b7f5d35ce5697b1156be06247b58441203c2dd988f870849c3d91581` and
   byte length = 55,784,815. Refuse to build on a changed source.
2. **Mandated counts** — `record_count == 39780`,
   `distinct_basenames == 235`, `excluded_inline_records == 3`,
   `section_count == 665`, `family_count == 77`.
3. **Decide the 3-record policy [U]** — confirm that `fb_6/firsmall1`,
   `fb_11/pinebroken2.2`, `fb_33/plantain` are intentionally excluded. If all
   39,783 Objects records are required, change the predicate and expect
   39,783 records in 668 sections; do not silently switch conventions.
4. **Index completeness** — `len(files) == 665`, `len(families) == 77`,
   `len(section_family) == 665`; every `files` value is an existing file and
   every `families` value is an existing file; no orphan family files.
5. **Family file contract** — each family file parses; top-level keys are
   exactly `{family, sections}`; `family` equals filename stem; every section
   key exists in `section_family` and maps back to the same file.
6. **Record contract** — every record has exactly the 5 mandated keys; every
   vector object has exactly `X,Y,Z,W`; all components finite; `BaseName` a
   non-empty string; **no wrapper dictionaries remain** (no `value`/`label`/
   `literal`/`line` keys anywhere in a record).
7. **Round-trip** — bit-exact comparison against a fresh parse of the source
   nested records (float64 bits via `struct.pack(">d", …)`), for all 39,780
   records, including `Position.W`.
8. **Order** — records within each section retain source `records[]` order;
   assert with an index-by-index comparison, not a sorted comparison.
9. **Determinism** — two clean builds emit byte-identical files; no timestamps,
   mtimes, absolute donor paths or hash-order-dependent key sequences.
10. **Read-only** — source SHA-256 unchanged after the build; no output path
    resolves inside `variant3d/assets/**`; no repo file other than the adoption
    patch and this report is modified.
11. **Provenance** — `visual_parity_claim == false` in the index; labels
    `[O]/[D]/[I]/[U]` and `PORT APPROXIMATION` preserved in any downstream
    manifest per X15 §2.
12. **Runtime proof (owner-run, not done here)** — after I09 consumes the
    bundle, require `counts.props_total > 0`, `feed.fallback_used == false`,
    `feed.source` pointing at the bundle, zero `SCRIPT ERROR`, and the existing
    determinism/props atoms unchanged. This is a structural/self-consistency
    gate. **It is not a donor-parity gate.**

---

## 8. UNVERIFIED register / handoff

1. **[U]** Godot-side parse time and memory for the bundle are unmeasured; all
   timing/memory figures are Python 3.14.3 on this host. Do not extrapolate the
   2.76–3.61× ratio into the W06 ≤30 s wall target without an owner-run A/B.
2. **[U]** Peak RSS/VRAM, GC cost and any worker-thread behaviour remain
   unmeasured (W06 §9 items 2 and 4).
3. **[U]** The 3-record inline exclusion matches the mandated count but is a
   policy choice; W07's 39,783 convention is equally defensible. COORD/I03 owns
   the decision.
4. **[U]** No I09 consumer change was made. W07 §7.1–§7.4 (stamp Object
   acceptance, `BaseName` unwrap, full `Scaling`/`Position.Y`, provenance
   gating) and the lighting/material work are still required for `props_total >
   0`. This prototype only supplies a cheaper, correctly shaped feed.
5. **[U]** The compact bundle drops `RaceName`, `line`, `style`, `label` and
   `literal`. No current I09 consumer reads them [O from W07 §1.2 / §6], but a
   future consumer that needs provenance per record would have to go back to
   the source.
6. **[U]** Per-family 77-file layout is Windows-tested here; case-sensitive
   exports and packed-PCK access patterns were not tested. A single 11 MB
   compact file is a fallback if per-file lookup proves costly in Godot.
7. **[D]** No donor binary was executed, no donor GPU frame was read, and
   **no donor parity claim is made**. All conclusions are port-internal and
   read-only.

**COORD priority:** confirm §7 item 3 (39,780 vs 39,783) → adopt or reject the
77-family layout → have I03 implement the bundle reader with W07's consumer
fixes → owner-run a same-seed/same-config A/B with stage timers → only then
revisit W06's speed target. Until then, keep the legacy feed path unchanged.

*End of PERF-FEED. Exactly one repository report written; no code, asset,
Godot, runner, gate or git edits. NO DONOR PARITY CLAIM.*
