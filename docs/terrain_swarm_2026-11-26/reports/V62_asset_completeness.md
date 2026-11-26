---
id: V62
ticket: "TERRAIN-SWARM-2026-11-26 / V62 — generated asset pack vs fresh-module load paths (read-only audit)"
agent: "V62 (read-only audit subagent, 30-agent DONOR-FIRST terrain swarm)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_ASSET_GENERATION__NO_CODE_EDIT__NO_GODOT_JOB__NO_GATE__NO_PARITY_CLAIM
owner_file: docs/terrain_swarm_2026-11-26/reports/V62_asset_completeness.md
files_created: [docs/terrain_swarm_2026-11-26/reports/V62_asset_completeness.md]
files_edited: []
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION", "NO_PARITY_CLAIM"]
parity_guard: "No donor binary, donor byte, donor GPU frame, Godot process, runner job, gate or capture was used by V62. Donor visual parity stays UNVERIFIED (CHARTER.md:43-44,125). Nothing below is a PASS or a gate result."
scope_guard: "Read-only: file reads, grep, PowerShell Get-ChildItem/Test-Path/Get-Item, Python os.walk/json/pathlib stat/parse, one git ls-files/status read. No asset, source, shader, config, test, backup, manifest, queue or app/ byte was changed."
multiple_passes: true
snapshot: "2026-11-26 audit read. The asset tree was stable across all three passes below (identical file count and byte total); see §0. Re-read before COORD acts."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
---

# V62 — asset completeness: what the fresh modules load vs what is on disk

## 0. Multiple-pass log (owner directive, CHARTER.md:85-93)

| Pass | Instrument | Result | Effect |
|---|---|---|---|
| P1 | PowerShell `Get-ChildItem -LiteralPath variant3d\assets\terrain_new -Recurse -File` + `-Recurse -Directory`, sorted | Only directories `cfg`, `patterns`, `patterns\families`; 780 files; no `atlas`, `masks`, `lib`, `schemas`, no root `manifest.json` | Basis of the presence map |
| P2 | Independent Python `os.walk` + `os.path.getsize`, `/`-normalised relative paths | **780 files / 242,316,351 bytes**; same path set as P1 (including the case-distinct `patterns/K_ravine_2.json`) | P1 and P2 agree; no mid-audit write detected |
| P3 | Third, explicit per-path `Test-Path -LiteralPath` sweep of 27 exact paths (§3) | Confirms each `PRESENT`/`ABSENT` verdict directly; no reliance on directory listing alone | Authoritative per-row verdict |
| P4 | Python `json.loads` probe of 4 emitted JSONs (top-level keys, `schema`, `families`, `visual_parity_claim`) | Schema/size sanity in §3; `family_index.json` has no I09-compatible feed key | [D] compatibility verdict in §4 |
| P5 | `git ls-files -- variant3d/assets/terrain_new/**` → **0**; `git status --short` → `?? variant3d/assets/terrain_new/` | Whole tier is **untracked**, creation-ledger only | Rollback remains delete-by-path (V36 §7); no commit claim |

**[O] No anomaly was accepted from one pass.** The V46/HANDOFF §2.2 statement that `assets/terrain_new/**` is entirely absent is **point-in-time stale**: the `cfg/` and `patterns/` tiers have since landed (P1/P2/P3). The `atlas/`, `masks/`, schema and root-manifest tiers have not.

**Doc-location note [O]:** the assigned `reports/V46_handoff_refresh.md` does not exist on disk; the V46 refresh is the frontmatter/§2/§5/§6/§7/§8 edit inside `docs/terrain_swarm_2026-11-26/HANDOFF.md`. `reports/I15_asset_generation.md` does not exist on disk (glob and filename sweep both empty). These absences are recorded, not worked around.

---

## 1. Executive summary

1. **[O] The pack is partially generated.** `variant3d/assets/terrain_new/` exists with **780 files / 242,316,351 bytes**, in exactly three directories: `cfg/` (3 JSON), `patterns/` (713 JSON + `families/` 64 JSON). There is **no** `atlas/`, **no** `masks/`, **no** `lib/`, **no** `schemas/` and **no** root `manifest.json`. All 780 files are untracked (P5).
2. **[O] The landed tiers are the decoder tiers:** I01 (`cfg/`), I02/I03 (`patterns/`). The tiers that the runtime actually loads — I05's atlas and I09's primary object feed — are the ones still missing.
3. **[D] Two silent substitutions are live as landed.** (a) I08 cannot find the I05 atlas pair and falls back to the committed legacy 179,912,941 B atlas (`terrain_donor_mesh.gd:379-383` — labelled in stats, not hidden); (b) I09 cannot find either `terrain_new` feed it accepts and falls back to legacy `mountain_props.json` with an explicit `TRANSFORM_FALLBACK` label (`terrain_donor_props.gd:537-547`). Neither is a parse hard-fail; both mean an A/B run would measure legacy assets while reporting a donor backend.
4. **[O] I06 and I07 reference no `res://assets/...` path at all.** They consume an in-memory Object/Dictionary (`from_live_object`, `generate(data, p)`). Asset absence cannot directly break them; it breaks provenance and the props/mesh tiers instead.
5. **[D] `family_index.json` is present but not usable by I09 as landed** (§4 C1): it carries `families` (64) and 493 cfg pairs but none of the record keys/shapes `_try_feed()` accepts (`terrain_donor_props.gd:550-607`). Presence therefore does not satisfy the G3 feed role.
6. **[U]/PORT APPROXIMATION** No gate, determinism dump or capture was run. **No donor parity claim**; parity remains UNVERIFIED.

---

## 2. Audit set and instrument

Grep scope: `variant3d/**/*.gd` and `variant3d/**/*.gdshader` for `res://assets/terrain_new`, `manifest.json`, `patterns/`, `masks/`, `atlas/`, `cfg/`; plus `res://` enumeration of the eight named files (`terrain_donor_data.gd`, `terrain_donor_gen.gd`, `terrain_donor_mesh.gd`, `terrain_donor_props.gd`, `terrain_donor_shader.gdshader`, `main.gd`, `world3d.gd`, `t_terrain_donor.gd`), the N14 composer `terrain_donor_world.gd`, and the I05/I01–I04 tool output defaults. Producer ownership is taken from `reports/V11_ownership_ledger.md` rows **G1–G11, N1–N7, N10, N13**.

Result: I06/I07 = **zero** asset paths; I08 = 4 `terrain_new` atlas paths + shader + 2 legacy fallbacks; I09 = 2 `terrain_new` feeds + 10 legacy paths; I10 = zero asset paths; I11 composer = module scripts + 2 shader paths, no `terrain_new` data path; I12 = 1 `terrain_new` path (optional advisory) + module paths; I05 tool = 8 atlas outputs + optional root manifest.

---

## 3. Per-path audit

Legend: **[O]** on-disk/line observation; **[D]** static consequence; **[U]** cannot be proven without a Godot run. `PRESENT`/`ABSENT` are P3 `Test-Path` verdicts. "Producer" = V11 ledger owner, with the actual emitting tool noted where they differ.

### 3.1 Root manifest / schema

| # | Referenced by | Exact path (`res://` → repo) | Disk? | Sanity if present | Consequence if absent | Producer |
|---|---|---|---|---|---|---|
| 1 | I12 `t_terrain_donor.gd:44` (optional list `:696-699`); I05 `--emit-root-manifest` `:921-922,992-994` | `res://assets/terrain_new/manifest.json` → `variant3d/assets/terrain_new/manifest.json` | **ABSENT** | — | I12 advisory `optional_presence` = false only (**not** a hard fail). But G10 provenance, X15 `terrain_new/manifest/v1` pack-id, entry-tuple closure and A03 §11.6's 14 checks cannot run → **QA/gate blocker**. | **I05 via N6** (V11 G10); `build_terrain_new_manifest.py` (N6) itself absent |
| 2 | spec/11 §11.4; V11 G11 (not loaded by any module) | `res://assets/terrain_new/schemas/v1.schema.json` | **ABSENT** | — | No schema input for a validator; no runtime hard fail because no I06–I12 module reads it. Gate-2/validator blocker if N7 is used. | **I05** (G11) |

### 3.2 Atlas tier (I05 producer → I08 consumer)

| # | Referenced by | Exact path | Disk? | Sanity if present | Consequence if absent | Producer |
|---|---|---|---|---|---|---|
| 3 | I08 `terrain_donor_mesh.gd:58` `NEW_ATLAS_SINGLE` | `res://assets/terrain_new/atlas/tile_index_atlas.png` | **ABSENT** | — | **Labelled fallback** at `:379-380` to legacy `res://assets/terrain/atlas/tile_index_atlas.png` (PRESENT, 179,912,941 B). Not a hard fail; a capture would exercise legacy art. | **I05** (G8, `ATLAS_NAME` `:92,744`) |
| 4 | I08 `:59` `NEW_ATLAS_MANIFEST` | `res://assets/terrain_new/atlas/tile_index_atlas.manifest.json` | **ABSENT** | — | Labelled fallback at `:381-382` to legacy manifest (PRESENT, 60,677 B). Tile ids/grid/alpha come from the legacy V7-85 table. | **I05** (G8, `:767,770`) |
| 5 | I08 `:371` season override (season `"winter"`, lower-cased `:159-161`) | `res://assets/terrain_new/atlas/seasons/winter/tile_index_atlas.png` | **ABSENT** | — | Season override silently skipped; base atlas used. Shape conflict with I05's flat `seasons/tile_index_atlas_winter.png` — see §4 C3. No caller of `set_season()` exists in `variant3d/` today (grep), so dormant. | **I05** (G9) |
| 6 | I08 `:372` season override | `res://assets/terrain_new/atlas/seasons/winter/tile_index_atlas.manifest.json` | **ABSENT** | — | Same as #5. | **I05** (G9) |
| 7 | I05 `WINTER_ATLAS_NAME` `:94,744` | `res://assets/terrain_new/atlas/seasons/tile_index_atlas_winter.png` | **ABSENT** | — | No derived winter atlas; even if emitted, I08 would not look here (C3). Not a runtime hard fail. | **I05** (G9) |
| 8 | I05 `WINTER_ATLAS_MANIFEST` `:95,768` | `res://assets/terrain_new/atlas/seasons/tile_index_atlas_winter.manifest.json` | **ABSENT** | — | Same as #7. | **I05** (G9) |
| 9 | I05 `WINTER_ALIAS_OUT` `:96,748`; X15 `asset_index.season_aliases` | `res://assets/terrain_new/atlas/seasons/winter_aliases.json` | **ABSENT** | — | No derived alias table; legacy `assets/terrain/atlas/winter_aliases.json` still exists. Not a runtime hard fail for I06–I12. | **I05** (G9) |
| 10 | I05 `DESERT_ALIAS_OUT` `:97,749` | `res://assets/terrain_new/atlas/seasons/desert_aliases.json` | **ABSENT** | — | No derived desert table (desert scope itself carries X15 `UNVERIFIED`). Not a runtime hard fail. | **I05** (G9) |
| 11 | I05 `MASK_SPECS["alpha"]["out"]` `:101,745` | `res://assets/terrain_new/atlas/alpha.png` | **ABSENT** | — | No derived alpha mask in the new tier; I08 re-packs R→A from whatever atlas transport it loaded (`terrain_donor_mesh.gd:405-421`). Not a hard fail. | **I05** (G8) |
| 12 | I05 `MASK_SPECS["alphavert"]["out"]` `:107,746` | `res://assets/terrain_new/atlas/alphavert.png` | **ABSENT** | — | Same as #11. | **I05** (G8) |

### 3.3 Pattern / object-feed tier (I02/I03 producer → I09 consumer)

| # | Referenced by | Exact path | Disk? | Sanity if present | Consequence if absent | Producer |
|---|---|---|---|---|---|---|
| 13 | I09 `terrain_donor_props.gd:59` `FEED_LIB_INDEX` (primary feed) | `res://assets/terrain_new/patterns/pattern_lib_index.json` | **ABSENT** | — | Primary donor object feed unavailable → `_load_feed()` tries #14 then falls to #26 (`:537-547`). **Not** a hard fail; labelled `TRANSFORM_FALLBACK`. | **I03** (V11 G5). Actual tool default is `lib/pattern_lib_index.json` — see §4 C2. |
| 14 | I09 `:60` `FEED_FAMILY_INDEX` (secondary feed) | `res://assets/terrain_new/patterns/family_index.json` | **PRESENT** | 55,507,231 B; parses; `schema="terrain_new/pattern_lib/v1"`, 64 families, 493 pairs, `visual_parity_claim:false`; **no** `props`/`objects`/`records`/`by_pattern` key and no top-level record array → **[D] `_try_feed()` returns false** (`:574-607`) | Nominal fallback #2 is unusable, so I09 lands on #26. If this file *were* absent the outcome would be identical. | V11 G3 assigns **I02**; actual writer is **I03** (`V28 F-01` owner collision) |
| 15 | spec/11 §11.4; V11 G4 | `res://assets/terrain_new/patterns/families/<family>.json` (64 files) | **PRESENT** (64) | 46,555,804 B total; e.g. `mountains.json` 935,886 B, `schema="terrain_new/pattern_lib/v1"`, `visual_parity_claim:false`; relief/object tails labelled UNVERIFIED | No runtime I06–I12 module loads these directly. Not a hard fail. | V11 G4 assigns **I02**; actual writer is **I03** (V28 F-01) |
| 16 | `decode_pattern_lib.py:7,21,762,1060` (actual default output, not a module load) | `variant3d/assets/terrain_new/lib/pattern_lib_index.json` | **ABSENT** | — | The one output I03 is coded to emit is missing entirely; neither consumer path (#13 nor #14) can receive its records. | **I03** |

### 3.4 Mask tier (I04)

| # | Referenced by | Exact path | Disk? | Sanity if present | Consequence if absent | Producer |
|---|---|---|---|---|---|---|
| 17 | spec/11 §11.4; V11 G6 (no I06–I12 module load) | `res://assets/terrain_new/masks/mask_index.json` | **ABSENT** | — | The `masks/height/**` A03 route stays missing — exactly the X19 `mask_decoder_gap` finding. No runtime hard fail (I07 reads live data via I06); QA/asset-layout blocker. | **I04** (G6) |
| 18 | spec/11 §11.4; V11 G7 (no I06–I12 module load) | `res://assets/terrain_new/masks/height/<shape>/*.height.png` | **ABSENT** | — | See #17; no derived height PNG tier. | **I04** (G7) |

### 3.5 cfg tier (I01)

| # | Referenced by | Exact path | Disk? | Sanity if present | Consequence if absent | Producer |
|---|---|---|---|---|---|---|
| 19 | V11 G1; `decode_donor_cfg.py:776,788` (no I06–I12 module load) | `res://assets/terrain_new/cfg/constants.json` | **PRESENT** | 1,345,489 B; `{constants:[{active,key,label,line,raw_value,source,…}]}`; `visual_parity_claim:false` present. **[O] `source` values embed `C:\Games\Cossacks 3\...` absolute donor paths** — conflicts with spec/11 §11.1 invariant 1 / X15 §2.1 `donor_root_policy` | N/A (present). No runtime module reads it, so absence would be a decoder-tier/QA gap, not a hard fail. | **I01** (G1) |
| 20 | V11 G2; same tool | `res://assets/terrain_new/cfg/config_strings.json` | **PRESENT** | 2,397,559 B; `{entries:[…]}`; `visual_parity_claim:false` present; same absolute-donor-path leak as #19 | N/A (present). | **I01** (G2) |
| 21 | `decode_donor_cfg.py` side-car (not in G1–G11) | `res://assets/terrain_new/cfg/manifest.json` | **PRESENT** | 13,601 B; `schema_version="1.0"`, `tool="decode_donor_cfg.py/I01"`, `summary` 19/19 count + 7/7 hash checks, `visual_parity_claim:false` | N/A. **[D] Not the G10 root manifest** — the shared basename is a confusion risk, not a substitute for #1. | **I01** |

### 3.6 Shader / module / fallback paths (I08, I10, I11, I12)

| # | Referenced by | Exact path | Disk? | Sanity if present | Consequence if absent | Producer |
|---|---|---|---|---|---|---|
| 22 | I08 `:67`; I11 composer `:35`; I12 `:43` | `res://shaders/terrain_donor_shader.gdshader` | **PRESENT** | 18,833 B, V37 canonical name; old alias absent (HANDOFF §2.1) | If absent, I08 uses a labelled legacy-shader/plain-material fallback (`:507-520,559-563`), not a hard fail. | **I10** (V11 N13; script asset, not a decoder) |
| 23 | I11 composer `:36` labelled inert alias | `res://shaders/terrain_donor.gdshader` | **ABSENT** | — | None: intentionally retired by V37; canonical #22 loads first. | A06 N7 alias — retired |
| 24 | I12 `MODULE_TILES` `:42`, optional list `:696` | `res://scripts/terrain_donor_tiles.gd` | **ABSENT** | — | I12 advisory only; composer does not reference it. No hard fail. | **I07** (N10; ownership undecided V16-27) |
| 25 | I08 fallback pair `:60-61,379-382` | `res://assets/terrain/atlas/tile_index_atlas.png` + `tile_index_atlas.manifest.json` | **PRESENT** (179,912,941 B / 60,677 B) | V7-85 legacy pair; hashes match X15 census E8/B_atlas_png | If these were also absent, I08's atlas load would **hard fail** (`_load_atlas():424-436` → `build()=false`). They are present, so the fallback path works. | Legacy conversion tools (pre-I-wave) |
| 26 | I09 `FEED_FALLBACK` `:61`, selected `:542-545` | `res://assets/terrain/mountain_props.json` | **PRESENT** | 66,519 B; contains `props`/`by_pattern`, the shape `_try_feed()` accepts; labelled Z08 table | Currently the **effective** feed. If absent too, `_feed_source` stays empty → "NO_OBJECT_FEED … zero props instanced, none invented" (`:546-547`) — graceful, zero props. | Legacy conversion tools |
| 27 | I09 `MODEL_MANIFEST` `:62` → `_load_manifest():509-516` | `res://assets/models/manifest.json` | **PRESENT** | 320,756 B | If absent, `_known_sids`/`_bboxes` stay empty; no hard fail. | Legacy conversion tools |
| 28 | I09 `:65-84` inventory set: `assets/terrain/blocks`, `deco_png/envfieldd{ w}.png`, 3 mine OBJs, 8 wave sheets, `field.obj` | `res://assets/terrain/{blocks,deco_png,water_png}/…`, `res://assets/models/obj/shared/{terrain,buildings}/…` | **PRESENT** | `asset_inventory():382-410` reports these; no failure on absence, it only appends to `missing[]` | If absent, props are skipped/labelled; not a hard fail. | Legacy conversion tools |

**I06 / I07 explicit negative finding [O]:** `grep res://` over `terrain_donor_data.gd` and `terrain_donor_gen.gd` returned **zero matches**. Neither module reads any `manifest.json`, `patterns/`, `masks/`, `atlas/` or `cfg/` path. The nearest path-like references are comments (`terrain_donor_gen.gd:66` about `mapgen.gd`/terrainmasks). Therefore no asset in `terrain_new/**` is a direct load dependency of the data or generation stage.

---

## 4. Present-but-incompatible and path-shape conflicts

| ID | Conflict | Evidence | Consequence |
|---|---|---|---|
| C1 | `family_index.json` has 64 `families` and 493 cfg pairs but no I09 feed records; `_try_feed()` skips `families` and only accepts `props`/`objects`/`Objects`/`records`/`by_pattern` or a non-skipped top-level record array | `family_index.json` top-level keys (P4); `terrain_donor_props.gd:550-607` | **[D] HIGH** — the present G3 file cannot serve as the props feed; I09 silently operates on the legacy Z08 table (`fallback_used=true`, "PORT APPROX FALLBACK"). Fixing this requires a feed key/shape, not just generating the file. |
| C2 | I09 expects `patterns/pattern_lib_index.json` (`V11 G5`); I03 is coded to emit `lib/pattern_lib_index.json` (`decode_pattern_lib.py:7,21,762,1060`). Both are absent | §3 #13/#16 | **[D] HIGH** — even a successful I03 `--write` to its default would not satisfy I09. One canonical path + one writer must be chosen. (Related to V28 F-01: I03 also writes I02-owned G3/G4.) |
| C3 | I08 season template is `atlas/seasons/<season>/tile_index_atlas{.manifest}.json` (`terrain_donor_mesh.gd:371-372`); I05 emits flat `atlas/seasons/tile_index_atlas_winter{.manifest}.png/json` (`:94-95,744,767-768`) | §3 #5/#6 vs #7/#8 | **[D] MEDIUM (latent)** — no `set_season()` caller exists today, but once seasons are wired the I05 winter outputs will be invisible to I08 and summer art will be used. Reconcile both sides before any season capture. |
| C4 | Both landed cfg JSONs embed absolute `C:\Games\Cossacks 3\...` donor paths in `source` values | P4; §3 #19/#20; spec/11 §11.1 invariant 1; X15 §2.1 `donor_root_policy` | **[O] MEDIUM** — violates "no absolute private path in committed bytes" if these untracked files are committed. Normalise to donor-relative paths before commit. |
| C5 | `cfg/manifest.json` (13.6 KB, I01 side-car) vs missing root `manifest.json` (G10) | §3 #1 vs #21 | **[D] LOW/MEDIUM** — a worker may mistake the cfg side-car for the pack manifest and declare G10 satisfied. It is not; it has no `schema`, `pack_id`, `entries` or `asset_index`. |
| C6 | I05 `--emit-root-manifest` writes an **atlas-contribution-only** root manifest (`build_terrain_new_atlas.py:921-922,992-994`), whereas X15 §2 requires ~19 root keys including `entries`, `asset_index`, `census_reference`, `commit_policy`, `validation` | X15 §2.1-2.5; V11 G10 "I05 (via N6)" | **[U] MEDIUM** — running I05 with that flag may produce a file at the right path but the wrong schema. Verify against X15 before treating G10 as closed. |

---

## 5. Counts (P3 verdicts)

| Group | Rows | PRESENT | ABSENT |
|---|---:|---:|---:|
| `terrain_new` paths referenced by runtime code (I08 ×4, I09 ×2, I12 ×1) | 7 | 1 (#14, but shape-incompatible per C1 → **0 usable**) | 6 |
| `terrain_new` paths referenced only by tool defaults / V11 ledger / spec (G1–G11 + I05 outputs) | 14 | 4 (#15, #19, #20, #21) | 10 |
| **All `terrain_new` paths audited** | **21** | **5** | **16** |
| Non-`terrain_new` load/fallback paths (I08/I10/I11/I12) | 7 | 5 (#22, #25 pair, #26, #27, #28) | 2 (#23 retired alias, #24 optional tiles) |
| **Grand total** | **28** | **10** | **18** |

**On-disk census (P1/P2):** `patterns/` 713 JSON / 192,003,898 B · `patterns/families/` 64 JSON / 46,555,804 B · `cfg/` 3 JSON / 3,756,649 B · **total 780 files / 242,316,351 B**, all untracked (P5). Directory-level presence: `cfg`, `patterns`, `patterns/families` only; `atlas`, `masks`, `lib`, `schemas` absent.

---

## 6. Prioritized "must generate before gate" list

Ordered by runtime consequence, not by ticket number. Nothing here was generated by V62.

1. **P0 — I05 atlas pair:** `terrain_new/atlas/tile_index_atlas.png` + `tile_index_atlas.manifest.json` (§3 #3/#4). Run I05 in `--write` commit-tier (`--cell 128`), then assert I08 stats `atlas.paths` actually points inside `terrain_new/atlas/`, not at the legacy fallback. Until then any mesh/capture step measures the 179.9 MB legacy atlas; the donor backend can look "built" while rendering legacy art.
2. **P0 — I03 object feed at the path I09 reads:** `terrain_new/patterns/pattern_lib_index.json` (§3 #13, C2), with a record shape `_try_feed()` accepts (C1). Do not count the present `family_index.json` as satisfying this. Verify `stats.feed_source` is a `terrain_new` path and `fallback_used=false` before any props/capture gate.
3. **P0 — root pack manifest:** `terrain_new/manifest.json` (§3 #1, C5/C6). Required by X15 §2 (pack-id, entries, asset_index, visual_parity_claim:false) and A03 §11.6's 14 checks; I12 treats it as advisory only, so a gate must assert it explicitly. Do not accept `cfg/manifest.json` as a substitute.
4. **P1 — remaining I05 atlas tier:** `atlas/alpha.png`, `atlas/alphavert.png`, `atlas/seasons/tile_index_atlas_winter.png`, `atlas/seasons/tile_index_atlas_winter.manifest.json`, `atlas/seasons/winter_aliases.json`, `atlas/seasons/desert_aliases.json` (§3 #7-#12). Resolve C3 (season directory shape) in the same pass so winter is actually selectable.
5. **P1 — schema:** `terrain_new/schemas/v1.schema.json` (§3 #2) if N7/validator is in scope; otherwise retire G11 explicitly rather than leaving it silently absent.
6. **P2 — I04 mask tier:** `terrain_new/masks/mask_index.json` + `masks/height/<shape>/*.height.png` (§3 #17/#18). No I06–I12 module loads these, so this closes the spec/11 layout and X19 gap rather than a runtime crash.
7. **P3 — hygiene on what already landed:** normalise the absolute donor paths in `cfg/constants.json` / `cfg/config_strings.json` (C4) before commit; settle the I02-vs-I03 writer collision on `family_index.json`/`families/*.json` (V28 F-01) so a second decoder run cannot clobber the feed; decide whether N6 (`build_terrain_new_manifest.py`) is a real second tool or folded into I05 (C6).
8. **Not blockers:** I10 canonical shader is present; the retired alias and optional `terrain_donor_tiles.gd` are intentionally absent; the legacy fallbacks (#25-#28) are present and functional.

---

## 7. Open questions for COORD

1. **Q1.** C1/C2: is the single canonical object-feed path `patterns/pattern_lib_index.json` (I09/V11 G5) or `lib/pattern_lib_index.json` (I03 tool default)? Who repairs which side under one-owner-per-file (V11 §6)?
2. **Q2.** C6: does I05's `--emit-root-manifest` output count as G10, or is X15 §2's full root manifest still owed by N6? A wrong-schema file at the right path is worse than an absent one.
3. **Q3.** C3: will COORD align I08's `seasons/<season>/…` template to I05's flat `seasons/tile_index_atlas_winter…` output, or change I05's output layout?
4. **Q4.** C4: are the untracked cfg JSONs with embedded `C:\Games\Cossacks 3\...` paths to be regenerated donor-relative before any commit/LFS decision?
5. **Q5.** Should the V46/HANDOFF §2.2 blanket statement "`assets/terrain_new/**` absent" be refreshed once COORD re-verifies the live tree, given that `cfg/` and `patterns/` have since landed and V62 must not edit HANDOFF?

---

## 8. Handoff summary (5 lines)

1. **Verdict:** the pack exists but is incomplete against what the fresh modules load: 780 files / 242,316,351 B in `cfg/` + `patterns/` only; no `atlas/`, `masks/`, `schemas/` or root `manifest.json` (two independent filesystem passes + a third explicit `Test-Path` sweep agree).
2. **Live substitutions:** I08 silently uses the legacy V7-85 atlas pair (labelled in stats); I09 uses the legacy Z08 `mountain_props.json` table (`fallback_used=true`) because both `terrain_new` feeds are absent or shape-incompatible.
3. **Producer split:** I01/I02/I03 outputs have landed; I04/I05 outputs have not. I06/I07 read no asset paths at all; I12's only `terrain_new` reference is an optional advisory.
4. **Must-generate before gate:** I05 atlas pair → I03 feed at I09's path with a compatible shape → X15-conformant root manifest, then the rest of the atlas/season tier, schema, and mask tier.
5. **Guards:** read-only audit; no asset generation, code/shader/config/test edit, Godot job, runner job, gate or capture by V62; 5 path-shape conflicts recorded; **no donor parity claim** — parity stays UNVERIFIED / PORT APPROXIMATION (CHARTER.md:43-44,125).

*End of V62 report. Exactly one repo file written; no other file was created, edited or deleted.*
