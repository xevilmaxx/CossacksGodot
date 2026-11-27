# PORT1TO1 — Terrain asset gap attack A (read-only static)

- id: PORT1TO1-ASSET-GAP-A
- swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
- role: "WORKER TERRAIN-GAPA — read-only static attack on the three PORT1TO1_terrain_assets gaps (668-vs-680 sections, death-OBJ bytes, desert_frt_un)"
- owner_file: `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_asset_gap_a.md`
- status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_ASSET_GODOT_GIT_DONOR_EDIT
- created: 2026-11-27
- labels: [O, D, I, U, NO_PARITY_CLAIM, NO_APPROXIMATION]
- parity_guard: "Parity UNVERIFIED. Chain 0/6. Blocking [U] non-empty. RESULT IS NOT GOOD. No donor GPU A/B frame exists; no donor binary was executed, no donor file opened or copied, no port byte changed. Every donor statement is a read-only report/spec line citation carried from landed reports; every port statement is a read-only on-disk observation verified this pass unless marked carried. No completeness is declared; no parity is claimed; no approximation is endorsed."
- scope_guard: "Exactly one repo file written (this report). No code, asset, config, shader, test, runner, Godot, git or donor edit. All counts below are read-only directory/file observations or citations of landed report/spec lines."
- prior_reports_read:
  - `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_terrain_assets.md` (the audited report; gaps NEW-1/NEW-2/NEW-5)
  - `docs/terrain_swarm_2026-11-26/reports/F02_pattern_lib.md` (donor 680-section source)
  - `docs/terrain_swarm_2026-11-26/reports/F03_gen_config.md` (64 cfg families, member lists)
  - `docs/terrain_swarm_2026-11-26/reports/F08_flora_minerals.md` (family catalogue, E16 name mismatch)
  - `docs/terrain_swarm_2026-11-26/reports/X16_prop_mesh_coverage.md` (F19 0/17, 75/3/63 mesh census)
  - `docs/terrain_swarm_2026-11-26/reports/DEC_U_death_families.md` (48 donor death OSMs, byte sizes, stubs)
  - `docs/terrain_swarm_2026-11-26/reports/COPY_PROPS_assets.md` (§2 index contract, §5 manifest)
  - `docs/terrain_swarm_2026-11-26/reports/COMPACT_PROPS_all_records.md` (665 -> 668 restoration)
  - `docs/terrain_swarm_2026-11-26/reports/AUDIT_TERRAIN_ASSET_COVERAGE.md` (668/77/235/39783 cross-check)
  - `docs/terrain_swarm_2026-11-26/spec/04_PATTERN_STAMPING.md`, `spec/00_EVIDENCE_INDEX.md`

## 0. Headline verdicts (all three gaps)

| # | Gap as flagged in PORT1TO1_terrain_assets | Finding this pass | Class |
|---|---|---|---|
| G1 | `props_index.json` sections 668 vs prior donor count 680 (NEW-1) | **Count-definition difference, not a missing-asset gap.** Donor 680 = all `section.begin`/`section.end` pairs; port 668 = sections contributing `Objects` records. F02 §5.1 block census gives 12 sections with no `Objects` block; 680 − 12 = 668 exactly. | [D] over [O] citations; per-name cross-check stays [U]-G1 |
| G2 | Death-OBJ bytes unverified for 11 non-eurmil families (NEW-2) | **Superseded in the existence sense: all 48 derived death OBJs are on disk** (12 stems × `_death1/2` + `_death1a/2a`, plus `.mtl` sidecars) under `variant3d/assets/models/buildings/models/`; script stems are 12/12 at `world3d_entities.gd:375`. **Byte-verification (hash/verts/bbox vs donor OSM sizes) was not performed — stays [U]-G2** with an exact condition. | [O] on-disk glob this pass; bytes [U] |
| G3 | `desert_frt_un` unresolved name (NEW-5) | **Mislabelled in PORT1TO1 NEW-5: `desert_frt_un` itself is resolved under its own name** (12 members, 12 pattern JSONs, family JSON with records on disk; F08 catalogue row gives contents). The genuinely unresolved alias is its sibling `desert_forests_big` (cfg `n_desert_frt_big1..17` vs lib/files `n_desert_frt_big_1..17`, F08 E16 / X16 F19 0/17) — **deliberately deferred pending the engine-normalisation decision**, not silently dropped. | [O]/[D]; normalisation stays [U]-G3 |

## 1. G1 — exact donor-derived source of the 680 count, and what 668 means

### 1.1 The 680 source (donor-derived, cited)

- **[O, carried]** `docs/terrain_swarm_2026-11-26/reports/F02_pattern_lib.md:17-25` — `pattern.lib` (30,309,138 B, 1,172,417 split lines) holds **680 top-level `section.begin`/`section.end` pairs, 680 unique `Name` values**, 205,571 matched `struct.begin`/`struct.end` pairs, byte arithmetic closed (680 spans + 679 × 2 B separators + trailing 2 B = file size). Evidence row E2 at `F02_pattern_lib.md:62`.
- **[O, carried]** `docs/terrain_swarm_2026-11-26/spec/04_PATTERN_STAMPING.md:9` — "**680 top-level sections**, 205,571 `struct.begin`/`struct.end` pairs"; fixed 37-field prologue in identical order for 680/680 (`:11`).
- **[O, carried]** `docs/terrain_swarm_2026-11-26/spec/00_EVIDENCE_INDEX.md:119` — full-scan row: 30,309,138 B plaintext, CRLF, 1,172,417 lines, **680 sections**, 205,571 struct pairs (F02 E1–E3; X05 E1–E4/E13).
- **[O, carried]** `docs/terrain_swarm_2026-11-26/reports/F03_gen_config.md:755-758` — cfg-side member lists that sum against the same lib (e.g. `desert_forests_unique` 12 members `desert_frt_un_1..12`).
- Prior-report shorthand "680 sections" (PORT1TO1 §0 table row, citing "F02/X05 [C]") therefore means **680 `section.begin` records in donor `pattern.lib`**, nothing narrower.

### 1.2 The 668 source (port, observed this pass)

- **[O, carried + consistent]** `props_index.json` declares `record_count 39783, distinct_basenames 235, family_count 77, section_count 668` (PORT1TO1 §0 [V]; AUDIT_TERRAIN_ASSET_COVERAGE §0 pass A re-walked all 77 `families/*.json` bundles: 668 sections, 39,783 records — total cross-checks exactly).
- **[O, carried]** `COPY_PROPS_assets.md:70-74` — index contract at copy time: `record_count` 39,780, `distinct_basenames` 235, `family_count`/`section_count` 77/665, `excluded_inline_records` 3, `files`/`families`/`section_family` lengths 665/77/665, `source_sha256 a9fff8a1…`, `source_bytes` 55,784,815.
- **[O, carried]** `COMPACT_PROPS_all_records.md:12-26` — restoring the 3 excluded inline records (`fb_6 → firsmall1`, `fb_11 → pinebroken2.2`, `fb_33 → plantain`) moved records 39,780 → **39,783** and **sections with Objects 665 → 668** (source monolith bytes unchanged at 55,784,815).
- **[O, this pass]** The index's own `record_rule` (observed in `variant3d/assets/terrain_new/props/props_index.json:1`): `"record_rule": "pattern_lib.sections[].blocks[block=='Objects'].records[]; all structurally valid nested and inline records"`. The index counts **only sections that contribute `Objects` records** — sections with no `Objects` block cannot appear in it by construction.

### 1.3 The reconciliation (deterministic arithmetic over cited values)

- **[O, carried]** `F02_pattern_lib.md:160-161` block-type census over all 680 sections: `Objects` only **618**; `Objects`+`Waters` **37**; **none 12**; `Objects`+`Decals[*]` **9**; `Objects[*]` **3**; `Objects`+`Decals` **1**.
- **[D]** Sections containing any `Objects` block: 618 + 37 + 9 + 3 + 1 = **668**. Sections with no `Objects` block: **12**. 668 + 12 = **680 exactly, zero residual**.
- **[D]** Verdict: 668 vs 680 is a **count-definition difference** (sections-with-`Objects` vs all `section.begin` records), fully explained by the 12 object-less sections excluded by the index's own `record_rule`. It is **not a real missing-asset gap**: no 12-section shortfall of convertible prop content follows, because object-less sections carry no `Objects[]` records to convert.
- **[I]** Plausible reading, unproven per-name: the 665 figure at COPY-PROPS time vs 668 now is the inline-record restoration (+3 `fb_*` sections whose only records were inline-style), a separate, already-documented step — not donor drift.
- **[U]-G1 (open, exact resolution condition):** name the 12 object-less sections from the donor-derived `lib/pattern_lib_index.json` (55,784,815 B class) and confirm **0 of the 12 names appear as keys in `props_index.json` `files`/`section_family`, and 668 + 12 = 680 with no duplicate-name collapse involved**. Closes iff the per-name cross-check returns exactly that. (Note the adjacent caveat, kept open but not conflated: F08 §8 R2 warns a naive `Name`-keyed dict collapses 680 → 665 over 15 duplicated coordinate-section names; the index evidently keys per-section, since it holds 668 > 665 — the dict-collapse hypothesis is therefore disfavoured but not per-name refuted.)

## 2. G2 — death-OBJ source bytes on disk

### 2.1 What exists in the port (observed this pass, glob of `variant3d/assets/models/buildings/models/`)

- **[O, this pass]** All **48 derived death OBJs are present** — 12 donor stems × 4 files (`<stem>_death1.obj`, `<stem>_death2.obj`, `<stem>_death1a.obj`, `<stem>_death2a.obj`), each with a `.mtl` sidecar, under `variant3d/assets/models/buildings/models/`. Stems observed: `ukrsta`, `ukrhou`, `ukrdip`, `ukrcen`, `ukrbla`, `ukrbar`, `ukrart`, `ukraca`, `eurtow`, `eursto`, `eurmil`, `eurmar` (4 files each = 48). Exact example paths: `variant3d/assets/models/buildings/models/eurmil_death1.obj`, `.../eurmil_death2a.obj`, `.../ukrcen_death1.obj`, `.../eursto_death1a.obj`, `.../eurtow_death2.obj` (full 48-path listing returned by the `*death*.obj` glob; no `no file found` for any of the 12 × 4 slots). Base meshes `eurmil.obj` / `eurmila.obj` also present in the same directory.
- **[O, this pass]** Script stems are 12/12: `variant3d/scripts/world3d_entities.gd:375` reads `const BLD_DEATH_STEMS: Dictionary = {"mil": "eurmil", "cen": "ukrcen", "hou": "ukrhou", "bar": "ukrbar", "sta": "ukrsta", "bla": "ukrbla", "aca": "ukraca", "art": "ukrart", "dip": "ukrdip", "sto": "eursto", "mar": "eurmar", "tow": "eurtow"}` (the two `.bak-*` files still carrying the 1-stem `{"mil": "eurmil"}` line are stale backups, not the live script).
- **[O, carried]** Donor side ships the same 4-file set per family with byte sizes tabulated in `DEC_U_death_families.md:94-106` (e.g. `eurmil` parents 174,580/136,748 B, attach 20,620/29,380 B; `eursto`/`eurtow` attach stubs **660 B** each, §4.1 degenerate-but-present IDP2 meshes).
- **[D]** PORT1TO1 NEW-2 ("stems resolve but no per-family death-OBJ listing was performed — treat as REPORTED-ONLY") is **superseded on existence**: the listing it asked for now returns 48/48 PRESENT. No `no file found` remains.

### 2.2 What would verify the bytes (not done — the [U])

- **[U]-G2 (open, exact resolution condition):** for each of the 48 port OBJs, record (a) `Get-Item .Length` + SHA-256, (b) vertex/face counts via the approved `convert_models.py:read_osm` path, (c) bbox, and check against the donor OSM byte sizes in `DEC_U_death_families.md:94-106` (parents + attach per family) with the explicit stub expectation that `eursto_death1a/2a` and `eurtow_death1a/2a` convert to near-zero-face meshes (660 B donor stubs — an honest near-empty gap, never a substituted mesh, never a 1×1×1 cube per the `world3d_entities.gd:3067-3072` guard note in DEC_U §4.3). Closes iff 48/48 rows are PRESENT with donor-size-plausible geometry **and** manifest rows carry `donor_bytes`/`donor_sha256`/verts/bbox per DEC_U §5 items 2–4. Byte comparison against donor `.osm` binaries is **not** claimed here (no donor file was opened); the condition above is port-artifact verification, not donor parity.

## 3. G3 — trace of `desert_frt_un` through port assets, reports and spec

### 3.1 `desert_frt_un` is resolved under its own name (byte-proven)

- **[O, carried]** Donor cfg family: `F03_gen_config.md:758` — `desert_forests_unique (2261)` = 12 members `desert_frt_un_1..12`, Freq 1 each.
- **[O, carried]** Donor contents: `F08_flora_minerals.md:144` — `desert_forests_unique (2261-2313)`, `desert_frt_un_1..12`, 30–79 objs/pattern, footprint 16–28 × 22–35, dominated by palm 149 / plantyellow 136 / palmsmall 84 / smallstonessea 47. Fully catalogued, no mismatch flag on this row.
- **[O, this pass]** Port patterns: `variant3d/assets/terrain_new/patterns/desert_frt_un_1.json` … `desert_frt_un_12.json` all present on disk (12 files; also enumerated in `X59_donor_bytes_seal.md:5134-5145`).
- **[O, carried + snippet-observed]** Port family bundle: `variant3d/assets/terrain_new/props/families/desert_frt_un.json` present (159,335 B, SHA-256 `ff8c8cda…` per `COPY_PROPS_assets.md:146`); its `sections` map carries `desert_frt_un_1` … with real `Objects` records (`smallstonessea`, `plantyellow`, `desert1`, `palmsmall` with Position/Direction/Up/Scaling — observed in-file this pass).
- **[D]** `desert_frt_un` is therefore **resolved under its own name** in all three tiers (cfg → lib/patterns → port family bundle). It is none of the three suspected states as applied to itself: not an unresolved alias, not a deferred asset, not renamed.

### 3.2 What PORT1TO1 NEW-5 actually conflated, and the real open item

- **[O, carried]** The genuinely unresolvable-at-audit-time family is the sibling `desert_forests_big`: cfg names `n_desert_frt_big1..17` (no underscore, `F03_gen_config.md:755`, `generator.cfg:2006-2078`) have no `pattern.lib`/file match against the actual `n_desert_frt_big_1..17` (`F08_flora_minerals.md:104` E16, `:145` row "**0 resolvable** … **name mismatch E16** [U]"; `X16_prop_mesh_coverage.md:48-51` — the 17 unresolved members are exactly `n_desert_frt_big_1..17`, family F19 0/17 at `:290`, `:373`).
- **[D]** PORT1TO1 NEW-5 ("`desert_frt_un.json` + `n_desert_frt_big_1..17` resolution … F08 E16 still governing") merged two distinct families into one gap: E16 governs `desert_forests_big`, never `desert_frt_un`. Corrected reading: `desert_frt_un` = resolved; `desert_forests_big` naming = **deliberately deferred** (F08 §7 item 8 and §9 U3/X16 U-X16-4 keep the cfg↔lib normalisation question open with an explicit no-silent-fix policy, cf. V89 hygiene cited in NEW-5).
- **[O, this pass]** The port holds `variant3d/assets/terrain_new/props/families/n_desert_frt_big.json` (305,108 B per `COPY_PROPS_assets.md:198`) and `patterns/n_desert_frt_big_1.json` … (enumerated `X59_donor_bytes_seal.md:5646-5650`), i.e. the lib-named (`_1`-style) sections are indexed — consistent with "resolved under another (normalised lib) name" at the asset level.
- **[U]-G3 (open, exact resolution condition):** whether the donor engine normalises `n_desert_frt_big1` → `n_desert_frt_big_1` (and `k_pump_1..9` → `k_pump_01..09`) or those picks simply fail (F08 E16/U3; X16 U-X16-4). Closes iff a donor-text authority for the join semantics is cited (first-match parser `_misc_SelectPatternListParser` at `misc.script:3573-3580` per F08 E1/D already favours exact-match-first; the normaliser stays PORT APPROXIMATION until engine consumption is anchored) **or** the family is formally quarantined per the V89 no-silent-fix hygiene with the quarantine recorded in the family bundle metadata. Either outcome keeps `desert_frt_un` untouched — it was never the affected name.

## 4. Cross-cutting notes

- The three "prior 680" sightings inside PORT1TO1 itself (props_index row, NEW-1 evidence line, §2 row 3) all cite F02/X05 without a `path:line`; the citable donor-derived sources are now pinned in §1.1 (`F02_pattern_lib.md:17-25`, `spec/04_PATTERN_STAMPING.md:9`, `spec/00_EVIDENCE_INDEX.md:119`).
- No donor file was opened, executed, or copied by this worker; all donor facts are carried citations. No port file was created, edited, or hashed beyond directory/file-name observation and one in-file snippet read.
- Open unknowns remaining: [U]-G1 (per-name 12-section cross-check), [U]-G2 (48-OBJ byte/vert/bbox verification + manifest rows), [U]-G3 (engine name-normalisation vs quarantine). Each carries its exact zero-mismatch/resolution condition above; nothing is closed by approximation.

## 5. Verdict (binding wording)

- Parity UNVERIFIED. Chain 0/6. Three [U] items OPEN ([U]-G1, [U]-G2, [U]-G3). RESULT IS NOT GOOD while blocking_unverified is non-empty.
- G1 is a count-definition difference with exact arithmetic closure (668 + 12 = 680); G2 existence is superseded (48/48 death OBJs on disk) with byte-verification open; G3 is a mislabel corrected (`desert_frt_un` resolved; `desert_forests_big` naming deliberately deferred).
- No completeness is declared; no parity is claimed; no approximation is made or endorsed in this report.
