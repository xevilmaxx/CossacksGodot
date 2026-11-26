---
id: V59
ticket: "TERRAIN-SWARM-2026-11-26 / V59 — read-only audit of I09 props module against donor truth"
agent: "V59 (worker subagent, DONOR-FIRST terrain swarm 2026-11-26; reports to COORD)"
owner_file: docs/terrain_swarm_2026-11-26/reports/V59_i09_audit.md
created: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_EDIT__NO_GODOT_JOB__NO_RUNNER_JOB__NO_DONOR_ACCESS
scope: "Only this report was written. No .gd/.gdshader/.json/.cfg/.import/asset/test/fixture/git/app edit; no Godot process, gate, capture or runner job; no donor binary executed, copied or committed."
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_claim: false
parity_guard: "No donor GPU A/B frame exists (CHARTER.md:43-44,122-130). Every visual statement here is [I]/[U]/PORT APPROXIMATION. NO DONOR PARITY CLAIM."
subject: "variant3d/scripts/terrain_donor_props.gd (44,448 B; SHA-256 C990F604F17B650E4F29F03335EEA70FB6C9ADCF83C385F7CD1CBDE82625C94B, read this pass)"
priors_read:
  - docs/terrain_swarm_2026-11-26/CHARTER.md
  - docs/terrain_swarm_2026-11-26/SWARM_BOARD.md
  - docs/terrain_swarm_2026-11-26/spec/07_RESOURCES.md
  - docs/terrain_swarm_2026-11-26/spec/08_FIELDS_AND_PROPS.md
  - docs/terrain_swarm_2026-11-26/reports/A04_landscape_props.md
  - docs/terrain_swarm_2026-11-26/reports/F07_mill_fields.md
  - docs/terrain_swarm_2026-11-26/reports/F08_flora_minerals.md
  - docs/terrain_swarm_2026-11-26/reports/V07_relief_asset_readiness.md
  - docs/terrain_swarm_2026-11-26/reports/V08_coordinate_scale.md
  - docs/terrain_swarm_2026-11-26/reports/V36_integration_checklist.md
  - docs/terrain_swarm_2026-11-26/reports/X16_prop_mesh_coverage.md
  - docs/terrain_swarm_2026-11-26/reports/X22_field_sowing_translation.md
  - variant3d/scripts/terrain_donor_props.gd
  - variant3d/scripts/terrain_donor_world.gd (read-only seam/caller check)
---

# V59 — I09 props module audited against donor truth

## 0. Verdict table (PASS/FAIL per mandated item)

| # | Audit item | Verdict | Decisive evidence (exact file:line) |
|---:|---|---|---|
| 1 | No `DONOR_UNITS=160` doubling; all distances in CELLS | **PASS** | `terrain_donor_props.gd:22-32,88-89,467,634,639-640`; V08 `reports/V08_coordinate_scale.md:40-55,142-143,247-273` |
| 2 | Hills/mountains, 19 forests, stone, mines, shore sandsea, swamp/lake, decor, 7×7 mill-field hook | **PASS** (representation) with one [U] rotation-sign divergence | props `:90-128,130-143,343-379,456-469,488-497`; F08 `:125-198`; F07 `:21-26`; A04 `:172-182` |
| 3 | Transformed instances from `pattern.lib` Objects with UNVERIFIED fallback; no invented transforms | **FAIL** (mechanism correct, live Objects feed not consumed) | props `:34-47,59-61,532-607,649-726,729-775`; `terrain_new/patterns/families/mng.json` `sections[].blocks[].records`; X16 `:58-64,97` |
| 4 | Converted asset paths exact; missing assets labelled UNVERIFIED | **FAIL** (paths exact; 4 UNVERIFIED labels stale) | props `:66-85,147-173,382-410`; on-disk `Test-Path` + JSON census below |
| 5 | Deterministic ordering; no synthetic scatter | **PASS** | props `:245-255,626,343-379,438-444`; full-file token scan below |
| 6 | `build(container, stamps, opts)` API / V36 `bind()` seam | **FAIL** (build exists, no `bind`; composer still calls `bind`) | props `:201-217`; composer `terrain_donor_world.gd:228-231,133-143`; V36 `:48,120,133,144,148` |
| 7 | Forbidden constructs and parity claims | **PASS** | props `:5-12,435-444,467-481`; full-file token scan; no numeric `DONOR_UNITS` assignment |

**No gate was run, no Godot process was started, no capture exists, and no donor parity is claimed.**

## 1. Multiple-pass register (CHARTER.md:85-93)

No anomaly was accepted from a single reading.

| Pass | Instrument | Result / effect |
|---|---|---|
| P1 | Full `read` of `terrain_donor_props.gd` (1,022 lines) | Established all constants, API, feed logic, class mapping, stats, transform math |
| P2 | `grep` over the same file for `bind|DONOR_UNITS|rand|noise|scatter|hash|parity|PASS` | Only comment/string hits for `DONOR_UNITS`; no `func bind` (second, dedicated `grep func bind` → "No matches found"); no RNG/noise/scatter call; parity flags all negative |
| P3 | Independent `grep` on `terrain_donor_world.gd` + full read `:200-269,128-149` | Composer still calls `_call_adapt(_props,"bind",...)` at `:229`; `_call_adapt` returns false for a missing method (`:137-138`) |
| P4 | PowerShell `Test-Path` + `Get-ChildItem` counts over 15 asset paths | All 11 concrete OBJ/PNG paths present; `blocks/*.png`=112; `diffusewaves*.png`=8; `pattern_lib_index.json` ABSENT; `family_index.json` PRESENT |
| P5 | Python `json.loads` of `mountain_props.json`, `family_index.json`, `terrain_new/patterns/*.json` (713 files) | 112 relief records verified; `family_index.json` top-level `families` is a **list**; swamp/lake/relief pattern JSONs and `families/mng.json` Objects records now exist |
| P6 | Numeric replay of the 49-node lattice using Python `math` | I09 rotation (`props:356-357`) is a 90°-rotated mirror of X22's `rotate_y_45` (`X22:362-365`); centroids `(0, −0.600369)` vs `(−0.600369, 0)`. Donor `VectorRotateY` sign is [U], so this is a divergence from the cited translation, not a proven donor error |
| P7 | `glob` first reported `X16_prop_mesh_coverage.md` absent; explicit `Test-Path` + `Get-ChildItem X16*` then returned PRESENT | X16 landed mid-audit; read in full. I09's `X16_COVERAGE` label (`props:154`) is stale |
| P8 | SHA-256 of props (P1) vs V36 snapshot `E86389151F54EEB…` (`V36:99`) | I09 changed since V36: `DONOR_UNITS` fix landed, `bind()` still absent |

## 2. Item 1 — cell scale / `DONOR_UNITS` — **PASS**

- [O] The constant `DONOR_UNITS` appears **only in explanatory text/strings** (`props:24,88,467,634`), never as a numeric declaration or division. The only numeric scale is `TILE_M := 2.0` (`props:89`), explicitly documented as *horizontal world metres per cell for placement only* (`props:28-32`), which V08 calls donor-grounded (`V08:190-193`).
- [O] Prop cell offsets are integer-rounded donor `Position` values with **no ×2 and no `W/160`** (`props:634-640`); fractional-cell sampling is explicitly labelled PORT APPROX (`props:32,635`).
- [O] All recipe constants are cell-valued: keep-clear ellipses `[[5,7],[12,15],[22,18]]` (`props:104`, donor `dogenerate.inc:407-414`), mine stamp `8×10` (`props:99-100`, F08 E7), mine rings `3..5` (`props:101-102`, spec §07:16-24), field step `1.6981` / snap `2.401476` / clearances `1.52829`/`4.58487` (`props:105-112`, X22 `:321-339`).
- [D] V36's HIGH conflict C8 / V28 F-02 (`V36:133,148`) is **repaired in I09's current file** (hash drift P8). Composer/legacy paths were not re-audited here.
- **Fix:** none. Preserve the comment/string-only mentions; do not reintroduce `s = W/160`.

## 3. Item 2 — donor class coverage — **PASS** (representation; runtime gated by items 3 and 6)

| Class | Exact I09 evidence | Donor authority | Caveat |
|---|---|---|---|
| Hills / mountains | `RELIEF_SIDS` `terrainmesh1..4` (`props:130-132`); ledger `112/20/45` (`:90-92`, cited `mountain_props.json:2594-2596`); fallback feed (`:61,542-545`); sid mapping (`:811-812`) | V07 E01–E04 (`V07:93-96`); A04 `:81,225-235`; `pattern.lib:337491-337492,:338480-338507` | Parsed table has exactly **112** records (P5). 23 desert records have no converted sid → `skipped_unknown_sid` (V07 M4 / `props:155,817-819`). Grass-free flat height cannot supply silhouette; no visual claim. |
| Forests | 19 family names (`props:135-143`) = F08 §3.1 list (`F08:125-145`); pass rates `0.0009/0.0009/0.00054` and `stn1/stn2` (`:93-97,456-463`); conifer gate `foreststype=0` (`:98,500`) | F08 E5/E6/§4 (`F08:93-95,119-121,276-288`); spec §08 `:57-62` | Rate constants are stored as **metadata only**; I09 performs no roulette/`Freq×0.2` placement (that belongs to I07). No forest prop instances can be produced until item 3 is fixed. |
| Stone | `_class_for` `d_stn`/`str_new`/`desert_stn` prefix (`:904`, `stone_quarries` in pass order `:125-128`) | F08 §3.2 `:160-176`; spec §07:66; A04 E26 (no literal "quarry" asset) | [O] All 7 `d_stn_1..7.json` exist on disk (P5). [U] Prefix matching does not validate the exact 1..7 range; `d_stn_99` would be accepted. Not a donor-constant invention, but membership should be checked against the family index. |
| Mines | `8×10` stamp (`:99-100`), `mng/mni/mnc` (`:103`), rings `3..5` (`:101-102`), stats `mine_recipe` (`:464-469`, unit string "MAP CELLS 1:1") | F08 E7/E8 (`F08:95-98,178-198`); spec §07 `:16-24,85-92` | Ring placement is **not implemented in I09** (correctly a generator/I07 concern); I09 only realises `Objects` records of accepted stamps. |
| Sea / shore | `SHORE_TILE_IDS=[93,97,98]` (`:116,488-491`); water depth/classify terms `-1.1/-0.25/-0.1` (`:113-115,492-497`) | A04 E18/E19 (`A04:177-178`); V07 E12 (`V07:105`); atlas `manifest.json:2284,2380,2404` | Tile/shader surface is owned by I08/I10 (`props:14-17`); I09 adds no shore geometry — correct channel separation, not missing coverage. |
| Swamps / lakes | class mapping (`:902-903`); anomalies preserved as UNVERIFIED (`:167-168`); `lake_big := plain*2*0` not "fixed" | A04 E20–E22 (`A04:154-156,432-463`); spec §08 `:47-55` | No swamp/lake stamp realisation until item 3; zero-height swamp must get no water plane (A04 R10). |
| Decor | pass order (`:127`), `dcr`/`d_tls`/`fern`/`reed`/`gift`/`christmas` mapping (`:909-912`) | A04 `:182,446-463`; V07 `:159` | Metadata/classification only. |
| Mill fields | `FIELD_ROWS/NODES/STEP/ANGLE/SNAP/CLEAR/COST` (`:105-112`); `mill_field_hook` (`:343-379`); returns `stamped:false, hook_only:true` (`:367-368`); snap matches donor (`:348-349`) | F07 E1/E2 (`:44-45`); X22 `:60-64,321-339,343-441`; spec §08 `:67-81` | [U] Rotation convention differs from X22: I09 `:356-357` gives centroid `(0,−0.600369)`, X22 `:362-365` gives `(−0.600369,0)` (pass P6). Donor `VectorRotateY` sign is UNVERIFIED (A04 R4); align with X22 or label the 90° mirror explicitly. No node, MultiMesh or terrain write is made — "hook only" is satisfied. |

## 4. Item 3 — Objects transforms / fallback — **FAIL**

**What passes.** The code path itself is donor-shaped and does not invent transforms:
- Feed priority is I03 `pattern_lib_index.json` → `family_index.json` → Z08 `mountain_props.json` (`:59-61,532-547`); fallback sets `fallback_used` and appends a labelled note (`:542-545`); absent feed → `NO_OBJECT_FEED`, zero instances (`:546-547`).
- Records are normalised from `BaseName`, `Position`, `Scaling`, `Up`/`yaw_deg` (`:649-670`); any non-finite transform is skipped as `skipped_no_transform` (`:667-670`); unknown/missing sid and missing mesh are separately counted (`:672-690`).
- Instance transform uses authored uniform scale, Y-yaw and a labelled Z-up→Y-up basis (`:770-775`), with every record instantiated (`selection_rule` at `:753`, A04 §4.2 "instantiate all records"). No RNG chooses or jitters a transform.

**Why it fails.** The authoritative Objects feed is not wired, so no forest/stone/mine/swamp/lake transform can reach the instancer:
1. [O] `FEED_LIB_INDEX = res://assets/terrain_new/patterns/pattern_lib_index.json` (`:59`) **does not exist** on disk (pass P4; Python `rglob` found 0 copies).
2. [O] `FEED_FAMILY_INDEX` (`:60`) **does exist** (55,507,231 B) but is metadata: top-level `families` is an **array**, while `_try_feed` only reads `families` when it is a `Dictionary` (`:560-566`). Its other keys are metadata dicts/ints, so `source_map` stays empty and `_try_feed` returns false (`:574-606`). No family→pattern membership is populated; `_family_of_pattern` stays empty and every record falls back to `UNVERIFIED:<class>` (`:698-700`).
3. [O] The real donor Objects arrays **are now on disk** at `variant3d/assets/terrain_new/patterns/families/<family>.json`. Example: `families/mng.json` `sections[1].blocks[block="Objects"].records[0]` has `BaseName.value="plant"` (line 713326), `Position.X/Y/Z`, `Scaling.X/Y/Z`, `Up.X/Y/Z`, and 11 records for `mng_1` — matching F08's worked example (`F08:194-198`). I09 has no loader for this shape.
4. [O] Per-pattern `terrain_new/patterns/*.json` (713 files) carry `relief_float_grid` (H channel) and `object_records` that are the **24-byte `.pattern` tail** (`{id,f4,tail4,u,v}`), not `pattern.lib` Objects — F08 §3.6 (`F08:240-255`) refutes treating their counts (63/2072/323) as objects. Feeding those to `_normalize_record` would only produce `skipped_no_transform`; I09 correctly does not do so.
5. [D] Effective result today: only 22 of the 45 "stampable" Z08 mountain records can map to a converted sid; forest/stone/mine/drainage records are all skipped. X16 independently confirms `mountain_props.json` contains **no** forest/stone/mine transforms (15 literal greps = 0 hits; `X16:58-64,97`) and rates all 141 such BaseNames `PARTIAL`/`MISSING` with gap G4 (`X16:77-83,114-115`).

**Fix (I09 owner, no gate weakening):** add a third feed branch that reads `terrain_new/patterns/families/*.json`, walks `sections[]` → `blocks[]` where `block == "Objects"`, unwraps `BaseName.value`, `Position.X/Y/Z`, `Up.X/Y/Z`, `Scaling.X/Y/Z`, `line`, and passes those dictionaries to `_normalize_record`; set `transform_source = "DONOR LITERAL (I03 Objects[])"`. Keep the Z08/PORT APPROX fallback and the `skipped_no_transform` counters. Do **not** feed `per-pattern object_records` (tail) as transforms.

## 5. Item 4 — asset paths and UNVERIFIED labels — **FAIL**

**Exact paths verified present** (PowerShell `Test-Path`, pass P4), all cited by I09:
`res://assets/models/obj/shared/terrain/field.obj` (`:66`), `res://assets/terrain/deco_png/envfieldd.png` and `envfielddw.png` (`:67-70`), `res://assets/models/obj/shared/buildings/mine_{gold,iron,coal}.obj` (`:71-75`), `res://assets/terrain/water_png/diffusewaves0..7.png` (`:76-85`), `res://assets/terrain/blocks` with exactly 112 PNGs (`:65,401`), `mountain_props.json` (`:61`), `manifest.json` (`:62`). Manifest bboxes for the 4 relief sids were re-read and match V07 E02 (`manifest.json`: z spans 7.38/8.06/9.54/6.92).

**Four stale UNVERIFIED labels (the FAIL):**
| I09 line | Label text | On-disk truth (pass P4/P5/P7) |
|---|---|---|
| `:172` `"FAMILY_INDEX": "UNVERIFIED — I03 family_index.json absent; per-family counts fall back to class buckets"` | `terrain_new/patterns/family_index.json` **exists** (55.5 MB; keys `families`, `pattern_lib`, `join_summary`, …). The fallback is real, but the stated cause (absence) is false; `_family_of_pattern` is empty because of the list-vs-Dictionary schema (`:560-566`). |
| `:153` `"FLOAT_WINDOWS": "UNVERIFIED — relief float windows not exported; I02 owns them (V07 E06/E17)"` | `terrain_new/patterns/plt1.json`, `g_hil1.json`, `g_mnt_1.json`, `mng_1.json`, … all have `status="DECODED"` and a populated `relief_float_grid` (e.g. `plt1` 2,014-cell grid; `g_mnt_1` 1,634 cells). V07's negative finding is point-in-time, not current. |
| `:167` `"SWAMP_LAKE_EXPORT": "UNVERIFIED — swamp/lake families absent from donor_patterns.json (V07 E16)"` | True for the **legacy** `donor_patterns.json`, false for the fresh root: `m_swamp_small_1.json`, `l_lake_big_1.json`, `k_swamp_1.json`, `k_lake_1.json` etc. exist under `terrain_new/patterns/`. |
| `:154` `"X16_COVERAGE": "UNVERIFIED — X16_prop_mesh_coverage report not landed at this write"` | `reports/X16_prop_mesh_coverage.md` is now LANDED (pass P7) and supplies the exact BaseName→mesh coverage ledger (`X16:46-83,105-120`). |

Also [O] `asset_inventory()` (`:382-410`) checks field decals, mine meshes, wave sheets and block count, but **not** `FIELD_OBJ` (`:66`) and neither feed path (`:59-61`) — it can report a complete inventory while the feeds that drive all props are missing.

**Fix:** refresh those four strings to current on-disk truth (distinguish "legacy export absent" from "fresh export present but not consumed"); add `FileAccess.file_exists` checks for `FIELD_OBJ`, `FEED_LIB_INDEX`, `FEED_FAMILY_INDEX` in `asset_inventory()`. Keep genuinely missing items (desert/winter relief, mill death stages, rus/tur mills, rotor `.oss`/`.aaf`, winter crops, field2/3, pumps, 3D decal UV, mine record binding, shore substrate, lake_big anomaly, activation) labelled UNVERIFIED at `:155-171`.

## 6. Item 5 — determinism / no synthetic scatter — **PASS**

- [O] Stamp iteration is the caller's order (`:245-248`), each record visited in feed order with no sort and no RNG (`:626`); emission follows the fixed `CLASS_PASS_ORDER` (`:125-128,250-255`), and `order` is assigned from `p_out.size()` (`:645`).
- [O] `mill_field_hook` is a closed-form 49-node computation from one cell (`:343-379`); the snap uses donor `floor(...)` arithmetic (`:348-349`).
- [O] Full-file token scan (P2): no `rand/randi/randf/randomize`, no `Noise`/`FastNoise`, no hash-based scatter, no per-cell dither. Stats explicitly declare `no_synthetic_scatter`, `no_noise_field`, `no_rng_draw`, `render_only` (`:440-444`, repeated `:478-480`).
- [O] Render-only is borne out by code: container `height` is read at `:933-941`; no write to `height`/`collision`/`blocked`/`nav_version`/`pattern_stamps` exists (second grep, only a comment at `:36`).
- [D] `roundf` at `:636-637` and `_clamped_sid` variant clamping at `:885-887` are deterministic; both are already labelled PORT APPROX / [U] (`F08:234-238`, `props:806-807`). Same inputs ⇒ same batch transforms. **Unrun** (no Godot job by this worker).

## 7. Item 6 — public API / V36 `bind()` seam — **FAIL**

- [O] I09 exposes exactly the requested API: `func build(p_container: Object, p_stamps: Array, p_options: Dictionary = {}) -> Dictionary` (`:211-217`), plus `rebuild()/stats()/unverified()/props()/set_props_visible()/set_lod_enabled()/update_lod()/mill_field_hook()/asset_inventory()/clear()` (`:201-209`).
- [O] There is **no `bind()` method** in I09 (dedicated `grep "func bind"` → no matches; P2/P3). V36 already recorded this as A6/C4 (`V36:120,144`), and the current props hash differs from V36's snapshot but the defect persists.
- [O] The composer still calls `_call_adapt(_props, "bind", [game, _data, _mesh])` at `terrain_donor_world.gd:229`, then `_call_adapt(_props, "build", [])` at `:231`. `_call_adapt` returns false when `has_method` is false (`:137-138`), so `_props_applied=false` and **`build()` is never invoked**: zero props, zero batches, regardless of items 2–5.
- [D] Even if `bind()` were added, `build([])` passes an empty stamp array; it only works if `_container.meta["pattern_stamps"]` exists (`props:234-239`). The adapter must pass real stamps and `{"terrain": _mesh}` so `_terrain` is set (`props:214`) for `height_at_world` grounding (`props:929-931`).

**Fix (COORD-adjudicated, single-owner):** change `terrain_donor_world.gd:228-231` to call `build(_data, stamps, {"terrain": _mesh})` with the I07/I06 stamp array, and assert `stats.built == true && counts.props_total > 0`. Alternatively add a thin `bind(g, data, mesh)` in I09 that stores inputs and delegates to `build`; do **not** call both paths. Update V36 C4 when repaired.

## 8. Item 7 — forbidden constructs / parity claims — **PASS**

- [O] No numeric `DONOR_UNITS=160` assignment or `W/160` expression (item 1). No donor constant invented: every numeric constant at `:89-121` carries a donor `path:line` comment; `FOREST_BORDER_*` values are attributed via X03 (`props:119-121`), and `WEEKLY_CONSTANT` is explicitly recorded as *not found and not invented* (`:171`).
- [O] No synthetic noise/dither/scatter/RNG (item 5). No "food rect" stage (`:340-342,366-368` hook only; X22 `:53` confirms zero food rects in `SetupStartingResources`).
- [O] `visual_parity_claim` is `false` in both stats constructors (`:435,480`); `parity` is `UNVERIFIED — no donor GPU A/B frame` (`:148,436`); file header guard at `:5-12`; `asset_inventory()` label "no visual parity claim" (`:409`). There is no `PASS`/parity verdict string anywhere in the file (P2).
- [O] No forbidden alias trap: `DONOR_UNITS` survives only as a *negative* string ("no multiplier") at `:467`; it cannot affect arithmetic.
- **Fix:** none. Retain the guards; do not turn any internal cue into a donor-parity verdict.

## 9. Open items handed to COORD

1. **HIGH** — repair the composer→I09 adapter (item 6); until then any "props wired" statement is false even though the module is well-formed.
2. **HIGH** — wire the I03 `families/*.json` Objects feed into I09 (item 3); this is the single change that would turn forest/stone/mine/swamp/lake props from zero to donor-record-driven. Do not use `terrain_new/patterns/<name>.json` `object_records` (24-byte tail).
3. **MEDIUM** — refresh the four stale UNVERIFIED strings and add feed existence checks to `asset_inventory()` (item 4).
4. **MEDIUM** — decide the field lattice rotation convention: align to X22 `:362-365` or label the 90° mirror explicitly (item 2, pass P6).
5. **MEDIUM** — add explicit family-membership validation for `d_stn_1..7` / `str_new_1..8` instead of prefix-only matching (`:904`).
6. **UNVERIFIED** — no gate, no capture, no donor frame. Everything above is static [O]/[D]; parity remains UNVERIFIED.

## 10. Claim register

| # | Claim | Evidence | Label |
|---:|---|---|---|
| 1 | I09 dropped the `DONOR_UNITS=160` multiplier; distances are cells | props `:22-32,88-89,634-640`; V08 `:40-55` | [O]/[D] |
| 2 | All owner-listed classes are represented with cited donor constants and a stage order | props `:90-143,343-379,456-497`; F08/F07/A04 cites | [O] |
| 3 | The Objects→transform→MultiMesh path is donor-shaped but currently fed only by the Z08 mountain fallback | props `:532-607,649-775`; X16 `:58-64` | [O]/[D] |
| 4 | Concrete converted paths cited by I09 all exist; four UNVERIFIED labels are stale | P4/P5/P7; props `:147-173` | [O] |
| 5 | Ordering is deterministic and no synthetic field/RNG exists | props `:245-255,440-444`; P2 | [O] |
| 6 | `build()` exists but composer calls absent `bind()` → props inert | props `:211-217`; world.gd `:228-231,137-138`; V36 `:120` | [O]/[D] |
| 7 | No parity claim, no donor binary touched, no gate run by V59 | this report scope guard; props `:5-12,435,480` | [U] / guard |

*End of V59. Exactly one report written. Read-only audit; no code, asset, config, test, git, Godot, runner or gate state changed. No donor binary executed or copied. NO DONOR PARITY CLAIM.*
