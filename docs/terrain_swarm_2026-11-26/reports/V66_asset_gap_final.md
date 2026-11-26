---
id: V66
ticket: "TERRAIN-SWARM-2026-11-26 / V66 — FINAL asset-gap ledger for the fresh terrain module"
agent: "V66 (read-only verification subagent, 30-agent DONOR-FIRST terrain swarm)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_ASSET_GENERATION__NO_GODOT_JOB__NO_GATE__NO_PARITY_CLAIM
owner_file: docs/terrain_swarm_2026-11-26/reports/V66_asset_gap_final.md
files_created: [docs/terrain_swarm_2026-11-26/reports/V66_asset_gap_final.md]
files_edited: []
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION", "NO_PARITY_CLAIM"]
scope_guard: "File reads, grep, PowerShell Get-ChildItem/Test-Path/Get-Item, Python json key probe only. No asset generated, no source/shader/config/test/asset byte changed, no Godot process, no runner job, no gate, no capture, no git operation."
parity_guard: "No donor binary was run or copied; no donor GPU A/B frame exists. Donor visual parity stays UNVERIFIED (CHARTER.md:43-44,122-135). Nothing below is a PASS or a gate result."
input_reports: ["V62_asset_completeness.md (landed between V66 passes; read and reconciled)", "I15_asset_generation.md (ABSENT on disk)", "V53 CLI reconciliation (ABSENT on disk — commands reconstructed from tool source)"]
---

# V66 — FINAL asset-gap ledger (fresh `terrain_new` module)

## 0. Method — two independent disk passes + source trace

| Pass | Instrument | Result |
|---|---|---|
| A | PowerShell `Get-ChildItem -Recurse -File variant3d\assets\terrain_new`, full relative-path listing, sorted | Only directories `cfg/`, `patterns/`, `patterns/families/`. No `atlas/`, `masks/`, `lib/`, `schemas/`, no root `manifest.json`. |
| B | Independent PowerShell `Test-Path` sweep of 21 exact paths (root manifest, atlas pair, season pair, both feed paths, `lib/`, masks, cfg, schema, alpha/alphavert, legacy fallbacks, N6 tool) | Every `PRESENT`/`ABSENT` verdict in §2 confirmed by direct path test, not by listing inference. |
| C | Recount as a third sanity instrument: `Get-ChildItem … | Measure-Object` + length sum | **780 files / 242,316,351 bytes**; `cfg=3`, `patterns=777` (of which `families=64`); `atlas=0`, `masks=0`, `lib=0`, `schemas=0`. Independently reproduces V62 §0 P1/P2 and §5 census. |
| D | Source-level trace of `_load_feed()` / `_try_feed()` (`terrain_donor_props.gd:532-607`) against Python `json.loads` top-level keys of `family_index.json` and against `build_lib_index_doc()` (`decode_pattern_lib.py:761-824`) | New [D] finding V66-F1 (§4): generating the I03 index at I09's path still yields **zero props** and a **false "DONOR LITERALS" feed label**. Not a Godot run: runtime effect stays [U]. |

`V62_asset_completeness.md` landed **between** V66's first glob and this write. It is treated as an independent landed audit and reconciled, not overwritten. `I15_asset_generation.md` is still ABSENT (explicit `Test-Path` false). `V53` CLI reconciliation is **not on disk**: repo-wide literal search for `V53` returned 0 matches and `Test-Path` of the plausible report filename returned false. Therefore **every Python command in §3 is reconstructed [D] from the on-disk tool argparse/docstrings at cited lines, not quoted from V53.** No command below was executed by V66.

---

## 1. Complete runtime consumer → path map (I05–I12)

Legend: **[O]** file/line or on-disk observation · **[D]** static consequence · **[U]** unverified without a Godot run · **LFB** = labelled fallback (not a hard fail) · **ADV** = advisory only.

| Consumer | Exact path | Disk | Consequence at runtime |
|---|---|---|---|
| **I06** `terrain_donor_data.gd` | *none* — no `res://assets/...` reference | n/a | Asset absence cannot break I06; it reads an in-memory container ([O] V62 §3.7; V66 grep `FileAccess|load(|res://assets` → no matches). |
| **I07** `terrain_donor_gen.gd` | *none* — no `res://assets/...` reference | n/a | Same; the nearest reference is a comment at `:66` about legacy `mapgen.gd`/terrainmasks ([O] V62 §3.7). I07's second file `terrain_donor_tiles.gd` is ABSENT and optional (§2 row R18). |
| **I08** `terrain_donor_mesh.gd:57` | `res://assets/terrain_new/atlas/` | ABSENT directory | Parent of all I05 atlas outputs; no direct load of a directory. |
| I08 `:58` `NEW_ATLAS_SINGLE` | `res://assets/terrain_new/atlas/tile_index_atlas.png` | **ABSENT** | **LFB** `:379-380` → legacy `res://assets/terrain/atlas/tile_index_atlas.png` (`:60`, PRESENT, 179,912,941 B). No hard fail; a capture would measure legacy art. |
| I08 `:59` `NEW_ATLAS_MANIFEST` | `res://assets/terrain_new/atlas/tile_index_atlas.manifest.json` | **ABSENT** | **LFB** `:381-382` → legacy manifest (`:61`, PRESENT, 60,677 B): tile ids/grid come from V7-85. |
| I08 `:371` (season, only when `set_season()` called; no caller exists today) | `res://assets/terrain_new/atlas/seasons/<season>/tile_index_atlas.png` | **ABSENT** | Silent skip — `_res_exists()` false, no `push_error`; base atlas used. Latent shape conflict V66-F2. |
| I08 `:372` | `res://assets/terrain_new/atlas/seasons/<season>/tile_index_atlas.manifest.json` | **ABSENT** | Same silent skip. |
| I08 `:461-466` via `tile_atlas_loader.gd:482-494` | `res://assets/terrain/{atlas_parts,atlas}/{alpha,alphavert}.png` (legacy only) | PRESENT (legacy `atlas/` pair) | Loader is passed **only** `single_atlas_path`/`manifest_path` (`mesh.gd:383`); mask paths stay legacy constants `tile_atlas_loader.gd:67-68`. I05's new `atlas/alpha.png`, `atlas/alphavert.png` are **not** runtime-consumed as landed. |
| I08 `:67`, `:509-518` | `res://shaders/terrain_donor_shader.gdshader` | PRESENT (18,833 B) | Loads I10 shader; if absent, **LFB** to `terrain_tileindex.gdshader` (`:514`, PRESENT), else plain material (`:519-526`). Not a gap. |
| **I09** `terrain_donor_props.gd:59` `FEED_LIB_INDEX` | `res://assets/terrain_new/patterns/pattern_lib_index.json` | **ABSENT** | Primary object feed missing → chain to `:60` then `:61`. **LFB + shape defect**, see V66-F1. |
| I09 `:60` `FEED_FAMILY_INDEX` | `res://assets/terrain_new/patterns/family_index.json` | PRESENT but **unusable** (55,507,231 B; keys `description,families,family_count,heightfield_census,join_summary,labels,line_byte_offsets,object_census,pair_count,pattern_lib,schema,source,source_sha256,unverified_fields,visual_parity_claim`) | `_try_feed()` skips `families` (`:576`) and accepts no other record key → returns **false** (`:602-606`). Presence does not satisfy G3. |
| I09 `:61` `FEED_FALLBACK` | `res://assets/terrain/mountain_props.json` | PRESENT (66,519 B) | **Effective feed today**; selected at `:542-545`, `fallback_used=true`, labelled `TRANSFORM_FALLBACK … PORT APPROX`. If it were also absent: `NO_OBJECT_FEED … zero props instanced` (`:546-547`), graceful. |
| I09 `:62` `MODEL_MANIFEST` | `res://assets/models/manifest.json` | PRESENT | `_load_manifest():509-516`; absence only empties `_known_sids`/`_bboxes`, not a hard fail. |
| I09 `:65-84`, `:682`, `:735` | `assets/terrain/blocks/**`, `deco_png/envfieldd{,w}.png`, 3 mine OBJs, 8 wave sheets, `field.obj`, dynamic `AssetPaths.existing(sid,"obj")` | PRESENT | `asset_inventory():382-410` reports only; per-record mesh miss is a counted skip (`:682-690`), not a hard fail. |
| **I10** `terrain_donor_shader.gdshader` | *none* (no data-asset path) | n/a | Shader script itself PRESENT; no gap. |
| **I11** `main.gd` / `world3d.gd` seam; composer `terrain_donor_world.gd:110,154` | module scripts + shader paths only; no `terrain_new` data path | n/a | Asset absence cannot break the seam ([O] V62 §2/§3.6). |
| **I12** `t_terrain_donor.gd:44` `ASSET_MANIFEST` | `res://assets/terrain_new/manifest.json` | **ABSENT** | **ADV**: `optional_presence` advisory only (`:700-703`); included in the parity source scan (`:723-738`) but other modules supply explicit `visual_parity_claim=false`, so no fail. Spec/G10 blocker nevertheless. |
| I12 `:42` `MODULE_TILES` | `res://scripts/terrain_donor_tiles.gd` | ABSENT | **ADV** only (`:696`, `:174`); intentionally/ownership-undecided absent (V16-27). |
| I12 `:43` `MODULE_SHADER` | `res://shaders/terrain_donor_shader.gdshader` | PRESENT | No gap. |
| **I05** tool (producer obligations, not runtime loads by I05–I12) | 8 atlas outputs `:743-750` + 2 manifests `:767-768` + optional root manifest `:921-922,992-994` | all ABSENT except none | Produces §2 atlas rows; see §3 command A. |
| **I03** tool | `variant3d/assets/terrain_new/lib/pattern_lib_index.json` (`:7,21,51,760-762,1060`) | ABSENT | Tool's actual default output, **different directory** from I09's load path (V66-F3). |
| **I04** tool | `terrain_new/masks/mask_index.json` (`:611`), `terrain_new/masks/height/<tree>/<shape>/<stem>.height.png` (`:228`) | ABSENT | No I06–I12 consumer; spec/11 §11.4 + X19 layout gap. |
| **I01** tool (already landed) | `terrain_new/cfg/{constants,config_strings,manifest}.json` | PRESENT (3 files) | No runtime consumer; hygiene issue V66-F4 only. |

**No hard-fail path exists in I05–I12 as landed.** The only hard-fail neighbour is I08 `_load_atlas():424-436` → `build()=false`, which would trigger if *both* the new pair and the legacy pair were absent; both legacy files are PRESENT, so the labelled fallback works. This is a resilience observation, **not** a gate pass.

---

## 2. FINAL missing-asset ledger

`REQUIRED` = must exist before the first gate if that gate is to exercise the fresh donor-shaped path; `ADVISORY` = no I05–I12 runtime consumer, or explicitly optional/dormant as landed. Consequence codes: **LFB** labelled fallback · **SILENT** silent skip/counter-only · **ADV** advisory-only · **PRODUCER** no runtime load but blocks generation of a required path.

| # | Missing path | Exact consumer / obligation | Consequence | Producer (tool / ticket) | Gate class | Command (§3) |
|---|---|---|---|---|---|---|
| M01 | `res://assets/terrain_new/atlas/tile_index_atlas.png` | I08 `terrain_donor_mesh.gd:58`, fallback `:379-380` | **LFB** to 179.9 MB legacy atlas; no hard fail, but A/B would render legacy art | `build_terrain_new_atlas.py:92,744` / **I05** (V11 G8) | **REQUIRED (P0)** | A |
| M02 | `res://assets/terrain_new/atlas/tile_index_atlas.manifest.json` | I08 `:59`, fallback `:381-382` | **LFB** to legacy manifest; tile ids/grid from V7-85 | same tool `:93,767` / **I05** (G8) | **REQUIRED (P0)** | A |
| M03 | `res://assets/terrain_new/patterns/pattern_lib_index.json` | I09 `:59`, chain `:537-547` | **LFB** to family_index (unusable) then Z08 table; label `TRANSFORM_FALLBACK`. Even if emitted, shape defect V66-F1 | `decode_pattern_lib.py` default `lib/` `:51,1060` / **I03** (V11 G5) — path mismatch | **REQUIRED (P0)** + shape fix | B2 (path) + **no existing tool for shape** |
| M04 | `res://assets/terrain_new/manifest.json` | I12 `:44`; optional `:700-703`; I05 `:921-922,992-994` | **ADV** in code (optional presence false). Spec/G10, X15 `terrain_new/manifest/v1`, A03 §11.6 14-check closure blocked | I05 via **N6** (V11 G10); `build_terrain_new_manifest.py` **absent** | **REQUIRED (P0)** (code ADV — gate must assert explicitly) | A with `--emit-root-manifest` (partial, V66-F5) |
| M05 | `res://assets/terrain_new/atlas/alpha.png` | I05 `MASK_SPECS` `:101,745`; **no runtime consumer** as landed | **ADV**; I08 re-packs R→A from whatever transport loaded (`:405-421`) | `build_terrain_new_atlas.py` / **I05** (G8) | ADVISORY (P1) | A |
| M06 | `res://assets/terrain_new/atlas/alphavert.png` | I05 `:107,746`; loader uses legacy `atlas/alphavert.png` (`tile_atlas_loader.gd:482-494`) | **ADV** / silent legacy substitution | same / **I05** (G8) | ADVISORY (P1) | A |
| M07 | `res://assets/terrain_new/atlas/seasons/winter/tile_index_atlas.png` | I08 `:371` (dormant — no `set_season()` caller) | **SILENT** skip; summer art used. Shape conflict V66-F2 | **I05** (G9) | ADVISORY (P1, latent) | A + reconciliation decision |
| M08 | `res://assets/terrain_new/atlas/seasons/winter/tile_index_atlas.manifest.json` | I08 `:372` (dormant) | **SILENT** skip | **I05** (G9) | ADVISORY (P1, latent) | A + reconciliation decision |
| M09 | `res://assets/terrain_new/atlas/seasons/tile_index_atlas_winter.png` | I05 `WINTER_ATLAS_NAME` `:94,747` | no derived winter atlas; I08 would not look here (V66-F2). No runtime hard fail | **I05** (G9) | ADVISORY (P1) | A |
| M10 | `res://assets/terrain_new/atlas/seasons/tile_index_atlas_winter.manifest.json` | I05 `:95,768` | same as M09 | **I05** (G9) | ADVISORY (P1) | A |
| M11 | `res://assets/terrain_new/atlas/seasons/winter_aliases.json` | I05 `:96,748`; X15 `asset_index.season_aliases` | no derived alias table; legacy copy exists. No runtime hard fail | **I05** (G9) | ADVISORY (P1) | A |
| M12 | `res://assets/terrain_new/atlas/seasons/desert_aliases.json` | I05 `:97,749` | no derived desert table; desert itself X15 `UNVERIFIED`. No runtime hard fail | **I05** (G9) | ADVISORY (P1) | A |
| M13 | `res://assets/terrain_new/lib/pattern_lib_index.json` | `decode_pattern_lib.py:7,21,51,762,1060` (producer default, not a load path) | **PRODUCER**: I03's one coded output absent; neither M03 nor M14 can receive its records | **I03** | **REQUIRED (producer-side)** — path decision first | B1 (default) / B2 (redirect) |
| M14 | `res://assets/terrain_new/masks/mask_index.json` | spec/11 §11.4, V11 G6; **no I06–I12 load** | **ADV**; closes X19 `mask_decoder_gap`, not a runtime crash | `decode_donor_masks.py:611` / **I04** (G6) | ADVISORY (P2) | C |
| M15 | `res://assets/terrain_new/masks/height/<shape>/*.height.png` | spec/11 §11.4, V11 G7; **no I06–I12 load** | **ADV**; no derived height PNG tier | same tool `:228` / **I04** (G7) | ADVISORY (P2) | C |
| M16 | `res://assets/terrain_new/schemas/v1.schema.json` | spec/11 §11.4, V11 G11; **no I06–I12 load** | **ADV** unless N7 validator is in scope; no runtime hard fail | **I05** (G11) — **no writer on disk** | ADVISORY (P1) / gate-2 only if N7 used | **none — no tool command exists** |
| M17 | `variant3d/tools/build_terrain_new_manifest.py` (N6 producer, not an asset) | root-manifest producer referenced at `build_terrain_new_atlas.py:701` | **PRODUCER**: X15-conformant root manifest unobtainable; I05's `--emit-root-manifest` is atlas-only (V66-F5) | **N6 / COORD** — file absent | **REQUIRED** if G10 is a gate item | **none — tool absent; must be authored or folded into I05** |
| M18 | I09-compatible per-pattern object feed **shape** (not a path) | `_try_feed():569-607` needs `props`/`objects`/`Objects`/`records`/`by_pattern` keyed by stamp name | **SILENT** zero props + false `DONOR LITERALS` label if I03 index is merely generated (V66-F1) | no writer on disk | **REQUIRED (P0)** for any props/landscape gate | **none — no tool command exists** |

**On-disk census (passes A/B/C):** 780 files / 242,316,351 bytes; only `cfg/` (3), `patterns/` (713), `patterns/families/` (64). All untracked per V62 P5. Counts agree exactly with V62 §5 — no mid-audit write detected.

**Present-but-not-missing, for completeness:** `terrain_new/cfg/{constants,config_strings,manifest}.json`, `patterns/family_index.json` (shape-incompatible), 713 per-pattern JSON + 64 family JSON, I10 shader, all I08/I09 legacy fallbacks, `mountain_props.json`, `models/manifest.json`. Retired `terrain_donor.gdshader` alias and optional `terrain_donor_tiles.gd` are intentionally absent — **not** gaps.

---

## 3. Exact Python commands COORD must run

**Provenance of commands:** V53 CLI reconciliation report is ABSENT (§0). These are reconstructed **[D]** from on-disk argparse/docstrings at the cited lines. Windows form; run from the repo root with `python`. `--game` is read-only; every tool refuses `--out` inside the donor root. V66 ran **none** of them.

### A — I05 atlas tier + root manifest (M01, M02, M05–M12, partial M04)

Dry-run first (writes nothing; `--check` verifies the in-memory plan — `build_terrain_new_atlas.py:917,999`):

```
python variant3d\tools\build_terrain_new_atlas.py --game "C:\Games\Cossacks 3" --out variant3d\assets\terrain_new\atlas --cell 128 --dry-run --check
```

Commit-tier write (`:919,945-950`; `--cell 128` is the only committed tier, spec/11 §11.4; outputs at `:743-750,767-768`):

```
python variant3d\tools\build_terrain_new_atlas.py --game "C:\Games\Cossacks 3" --out variant3d\assets\terrain_new\atlas --cell 128 --write --check
```

Root manifest contribution (`:921-922,992-994`) — **only if COORD accepts the partial schema**, see V66-F5:

```
python variant3d\tools\build_terrain_new_atlas.py --game "C:\Games\Cossacks 3" --out variant3d\assets\terrain_new\atlas --cell 128 --write --emit-root-manifest --check
```

Never use `--hires-local` under `terrain_new` (`:912-914,935-948`); cell 1024 reproduces shipped legacy atlas bytes and is local/uncommitted only.

### B — I03 pattern-lib index (M03, M13)

Dry-run + validation (`:31-33,1071-1078`):

```
python variant3d\tools\decode_pattern_lib.py --game "C:\Games\Cossacks 3" --dry-run --check
```

Write to the tool's canonical default `terrain_new/lib/pattern_lib_index.json` (`:51,1060`):

```
python variant3d\tools\decode_pattern_lib.py --game "C:\Games\Cossacks 3" --write --check
```

Redirect to the path I09 actually loads (`:1069` `--out`; basename fixed at `:1060`). **Ownership collision**: the tool docstring `:20-29` says it emits only under `lib/`; COORD must choose the canonical path before running this form:

```
python variant3d\tools\decode_pattern_lib.py --game "C:\Games\Cossacks 3" --out variant3d\assets\terrain_new\patterns --write --check
```

**Neither form fixes M18** — see V66-F1. Do not mark M03 closed on `stats.feed_source` alone; assert `props_total > 0` and `fallback_used=false`.

### C — I04 mask tier (M14, M15)

`--check` returns before writing (`decode_donor_masks.py:605-606`); write requires `--write` and no `--check` (`:591`):

```
python variant3d\tools\decode_donor_masks.py --game "C:\Games\Cossacks 3" --out variant3d\assets\terrain_new\masks --check
python variant3d\tools\decode_donor_masks.py --game "C:\Games\Cossacks 3" --out variant3d\assets\terrain_new\masks --write
```

Emits `mask_index.json` (`:611`) and `height/<tree>/<shape>/<stem>.height.png` (`:228`).

### D — I01 cfg regeneration (already present; hygiene only — does **not** fix V66-F4)

Write mode requires `--out`; `--dry-run` prints only (`decode_donor_cfg.py:787-795,802-809`):

```
python variant3d\tools\decode_donor_cfg.py --game "C:\Games\Cossacks 3" --out variant3d\assets\terrain_new\cfg --check
```

### E — I02 per-pattern decode (already landed; reference only, not a missing asset)

```
python variant3d\tools\decode_donor_pattern.py --game "C:\Games\Cossacks 3" --out variant3d\assets\terrain_new\patterns --no-dry-run --check
```

(`:856-870`; `--write` is the alias of `--no-dry-run`.)

### F — Missing assets with **no** existing generating command

| Asset | Why no command |
|---|---|
| `schemas/v1.schema.json` (M16) | No writer for a `schemas/` file exists in `variant3d/tools/**` (full tool listing read). |
| X15-conformant root `manifest.json` (M04/M17) | N6 tool `build_terrain_new_manifest.py` absent; I05's flag emits an explicitly **PARTIAL** atlas-only manifest (`build_terrain_new_atlas.py:700-701`). |
| I09-compatible per-pattern feed shape (M18) | `decode_pattern_lib.py` emits metadata only (`:762-766,783-823`); `decode_donor_pattern.py` emits per-pattern files, not the single keyed feed `_try_feed()` expects. |
| Season path realignment (M07/M08 vs M09/M10) | Code/output-layout decision, not asset generation. |

---

## 4. Findings beyond V62 (all static; runtime effect [U])

- **V66-F1 — HIGH [D].** Even after running command B2, `pattern_lib_index.json` has no `props`/`objects`/`Objects`/`records`/`by_pattern` key, but it *does* have a top-level `generator_families` **array** (`decode_pattern_lib.py:816`) that is not in `_try_feed()`'s skip list (`terrain_donor_props.gd:576-578`). `_try_feed()` therefore returns **true** (`:607`) with `_records` keyed only by `"generator_families"`. `_collect_stamp()` looks up `_records.get("<stamp name>")` (`:618`) → empty → `skipped_no_records` (`:619-621`) → **zero props instanced**, while `stats.feed.label` reports `"DONOR LITERALS (I03 decoded feed)"` (`:275-276`) because `_fallback_used=false`. This is worse than the current labelled Z08 fallback: a false provenance label. Confirmed by Python key probe of the sibling `family_index.json` (same doc envelope) and source trace; **not** confirmed by a Godot run. Gate must assert `props_total > 0`, not just `feed_source`.
- **V66-F2 — MEDIUM, latent [D].** I08 season template `atlas/seasons/<season>/…` (`mesh.gd:371-372`) vs I05 flat `atlas/seasons/tile_index_atlas_winter…` (`:94-95,747,768`). Once seasons are wired, I05's winter outputs are invisible to I08. No `set_season()` caller exists today (V62 §3.2 #5), so dormant. Agrees with V62 C3.
- **V66-F3 — HIGH [D].** I09 reads `patterns/pattern_lib_index.json` (`:59`); I03 emits `lib/pattern_lib_index.json` (`:51,1060`). A successful default I03 run cannot satisfy I09. Agrees with V62 C2; V66 adds the command B2 redirect and the ownership-collision caveat.
- **V66-F4 — MEDIUM [O].** `cfg/constants.json` and `cfg/config_strings.json` embed absolute `C:\Games\Cossacks 3\...` donor paths in `source` values, contrary to spec/11 §11.1 invariant 1 / X15 `donor_root_policy`; re-running command D reproduces them. Agrees with V62 C4.
- **V66-F5 — MEDIUM [U].** `cfg/manifest.json` (13.6 KB, I01 side-car) is **not** the G10 root manifest; I05's `--emit-root-manifest` produces a schema-incomplete file (`:700-701`). Do not close G10 on either. Agrees with V62 C5/C6.
- **V66-F6 — [O].** `V53` CLI reconciliation report and `I15_asset_generation.md` are both absent; §3 commands are tool-source reconstructions. This is a documentation gap, not an asset gap.

---

## 5. Handoff verdict (no parity claim)

1. **Minimum REQUIRED before the first gate:** M01+M02 (I05 atlas pair), M04 (X15-conformant root manifest), M03 **and** M18 (object feed at I09's path *with a compatible record shape*). M13 is the producer-side prerequisite; M17 is owed unless G10 is explicitly retired. Absent M18, a props/landscape gate would measure the legacy Z08 table or instance zero props.
2. **ADVISORY for the first gate:** M05–M12 (remaining atlas/season tier), M14–M16 (masks/schema), M16 unless N7 is in scope. These close spec/11 §11.4 layout, X19 and season readiness, not a runtime hard fail.
3. **Assertions COORD should add to any gate run:** I08 `stats.atlas.paths` points inside `terrain_new/atlas/` (not `terrain/atlas/`); I09 `stats.feed.source` is a `terrain_new` path **and** `fallback_used=false` **and** `counts.props_total > 0`; I12 `optional_presence` for `manifest.json` is true. None of these was run by V66.
4. **No gate, no capture, no generator command was executed.** Every file/byte is unchanged by V66 except this one report. **No donor parity claim** — parity remains `UNVERIFIED`, label `PORT APPROXIMATION` throughout (CHARTER.md:43-44,122-135).

*End of V66 report. Exactly one repo file written; no other file created, edited or deleted.*
