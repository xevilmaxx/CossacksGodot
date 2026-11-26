# AUDIT — Terrain donor-asset coverage: 99 OBJs vs 235 feed BaseNames (I09 mapping)

---
id: AUDIT_TERRAIN_ASSET_COVERAGE
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_NO_GODOT_NO_GIT
owner_file: docs/terrain_swarm_2026-11-26/reports/AUDIT_TERRAIN_ASSET_COVERAGE.md
labels: [observed, derived, UNVERIFIED, "PORT APPROXIMATION", "NO_PARITY_CLAIM"]
scope_guard: "Read-only audit. No source, asset, config, test, manifest, git, app/, Godot, runner, gate or capture state touched. One repo file written (this report)."
parity_guard: "No donor binary was run or copied; no donor GPU A/B frame exists (CHARTER.md:43-44,122-135). Every visual statement is PORT APPROXIMATION or UNVERIFIED. No parity claim."
task_input_note: "The task brief cites '99 terrain OBJs' and '221 feed BaseNames'. Measured on current bytes: **99 `.obj` files** on disk (confirmed) but **235 distinct feed BaseNames**, of which **133 lack a converted sid** — not 221. The 221 figure does not reproduce from `props_index.json` (`distinct_basenames: 235`, `record_count: 39783`) or from an independent bundle walk (235 distinct, 39,783 records). All counts below are measured values; the 221 figure is treated as stale/superseded."
---

## 0. Method (two instruments + statute)

- **[O]** = observed on disk or at a cited file/line. **[D]** = deterministic set arithmetic / static trace over observed bytes. **[U]** = unverified without a Godot run. No instrument executed Godot, a gate, or a capture.
- Pass A: `variant3d/assets/terrain_new/props/props_index.json` (schema `terrain_new/props_preindex/v1`, `record_count 39783`, `distinct_basenames 235`, `family_count 77`, `section_count 668`) + full walk of all 77 `families/*.json` bundles (668 sections, 39,783 records — total cross-checks exactly).
- Pass B: `variant3d/assets/models/manifest.json` (299 models; 100 terrain/mining sids: 97 under `shared/terrain/` + 3 `mine_*` under `shared/buildings/`) + `Get-ChildItem` of `obj/shared/terrain/` (**99 `.obj` files**).
- Mapping replicated **byte-for-byte** from `variant3d/scripts/terrain_donor_props.gd:1257-1371` (`_sid_for_base` incl. `.N` variant-strip `:1261-1265`, `RELIEF_SIDS`, mine/field/pump/bushes/plantain/christmastree/stones/rock rules, `tree_` prefix, `tree_+stem` forest fallback, shore clamp branches) and `:1345-1371` (`_class_for`, `CLASS_PASS_ORDER:182-185`), applied to every one of the 39,783 feed records with its stamp (section) name.
- Cross-checks: X16 ledger (141 forest/stone/mine BaseNames, 75 exact + 3 fallback + 63 no-OBJ), V59 §4, V106 §3-§4 (39,780 nested `Objects` records; BaseName-as-`{value}` wrapper), V66, COMPACT_PROPS, `field_conversion.manifest.json`, latest capture `%TEMP%\opencode\v42\video\donor_240_final\capture.json` (24 frames, `seed 20261113`, `status CAPTURE_OK`, `parity.status UNVERIFIED`).

## 1. Headline numbers (all [D] over [O] bytes)

| # | Claim | Value |
|---|---|---|
| H1 | Disk OBJs in `obj/shared/terrain/` | **99** `.obj` files |
| H2 | Manifest terrain/mining sids (97 terrain + 3 `mine_*`) | **100** (`manifest.json` models[]) |
| H3 | Disk OBJs with **no** manifest sid | 2 (`field2.obj`, `field3.obj` — FIX-FIELD-ASSETS outputs; `field_conversion.manifest.json:647-655,686-725`; no `.import` sidecar, `:883`) |
| H4 | Manifest sids with **no** disk OBJ in terrain/ | 3 (`mine_gold/iron/coal` — live under `shared/buildings/`, wired at `terrain_donor_props.gd:75-79`) |
| H5 | Feed records / distinct BaseNames / sections / bundles | **39,783 / 235 / 668 / 77** (matches `props_index.json` exactly) |
| H6 | Records that would INSTANCE (`sid` ✓ and class ✓) | **22,816 (57.4%)** across **62 distinct sids** |
| H7 | `skipped_unknown_sid` (no converted sid) | **16,669 records (41.9%)**, **133 distinct BaseNames** |
| H8 | `skipped_unknown_class` (sid known, stamp class `other`) | **298 records (0.7%)** |
| H9 | `skipped_no_transform` | **0** (compact feed Positions are all finite) |
| H10 | `skipped_missing_mesh` (sid known but load fails) | **0 by construction** — every returned sid is manifest-known (`_has_sid`/`_clamped_sid` gate at `:1336-1342`); runtime `ResourceLoader.exists` is [U] but has no static trigger except the field2/3 sidecar note (H3), whose sids are unreachable anyway |
| H11 | Mill-field feed records | **0** — fields are script-sown via `mill_field_hook` (`:435-474`), never pattern stamps; `field.obj` has **zero** feed references |

H7 split: **108** `BASE_UNRESOLVED` BaseNames (desert scrub, grasses, weeds, palms, flowers, pumps, desert ores, `terrainmeshdesert1..4`, landstone, burch, lilies, …) + **25** `TREE_SID_UNRESOLVED` (`drytree*`, `leaftree*`, `pinebroken*`, `pinebrokenmoss*`, `pinestump*`, `pinedryswamp1`) = **133**, not 221 (see task_input_note).

## 2. OBJ side — which of the 99 disk OBJs the feed actually references

**Referenced: 62 manifest sids** (59 terrain + 3 mines). Per-sid instance counts are feed-driven (top: `tree_pine` 4,690; `tree_pinesmall1` 4,108; `plantain1` 3,981; `tree_firsmall1` 2,505; `tree_fir` 1,522; `tree_spruce1` 1,345; `tree_pinedry1` 1,181; `tree_oak` 1,137; `bush1` 1,083 incl. `bushes` 642 + `drybushes` 430; `terrainmesh1..4` 89 total (14/21/29/25); mines 18 (6 each); `stone` 73; `christmastree` 10; `gift1..6` 58; `reed1..3` 155; all 10 `rock_stonesN` + all 10 `rock_stonesseaN` + all 6 `rock_seaN` + `rock_smallstones1` + `rock_smallstonesea1`).

**Unreferenced manifest sids: 38 of 100** (nothing in the feed can ever select them):

| Reason | Sids (count) |
|---|---|
| Variant collapse — `.N` suffix stripped (`:1261-1265`), everything clamps to variant 1 | `rock_smallstones2..6` (5), `rock_smallstonesea2..6` (5), `plantain2`, `plantain3` (all `plantain.N` → `plantain1`) |
| Bare-name / plural rules never emit them | `bush2`, `bush3`, `bush4` (only `bush1` via `bushes`/`drybushes`); `flower1..3` (feed has `flowers`, no rule maps it); `fern1..4` (feed has bare `fern`, unmapped); `rock`, `field` (no feed record at all); `christmastreea`; `tree_firsmall2/3`, `tree_pinedry2/3`, `tree_spruce3` |
| No feed BaseName in their donor family | `tree_stump1..4` (feed `pinestump*` → `TREE_SID_UNRESOLVED`), `rock_landstone1..4` (feed `landstone*` → `BASE_UNRESOLVED`) |

Net: **62/99 disk OBJs reachable (62.6%)**; 37 disk OBJs are converted but unreachable through `_sid_for_base`, plus `field2/field3.obj` (no sid). The 15 already-converted but clamped-away variants (`rock_smallstones2-6`, `rock_smallstonesea2-6`, `plantain2/3`, `bush2-4`, `flower1-3`, `fern1-4`) are the cheapest density-variety lever in this report (action A1 — no new art).

## 3. Feed side — the 133 BaseNames without OBJs (16,669 records)

Top-25 by instance count ([O] counts, [D] mapping):

| Instances | BaseName(s) | Family / note |
|---|---|---|
| 1,319 / 682+13 | `palm` / `palmsmall*` | Desert forest (`desert_frt*`, X16 rows 69-72) — **no converted mesh** |
| 1,348 | `fern` (+`fern.1` 41) | Mixed/leaf forest understory; converted `fern1..4` exist but bare `fern` has no rule (X16 rows 21-22 PARTIAL) |
| 1,315 | `plantyellow*` | Desert weed; no mesh (X16 rows 98-99) |
| 1,262 / ~828 / ~633 | `desert1*` / `desert3*` / `desert4`, `desert5`, `desert2` | Desert scrub; no mesh (X16 rows 9-14) |
| 896+247 / 192+… / 247 | `chamomile.1/.2` / `burdock*` / `burch*` | Meadow weeds; no mesh (X16 rows 6-8, F13) |
| 855 | `plantainyellow` | Same actor as `plantain1` (`plantain1.mesh`, X16 row 97 G3) — mapping-only unlock |
| 837 | `plant*` + `plantyellow.1` | No mesh (X16 rows 91-92, 99) |
| ~4,500 weeds | `grass*`, `grassforest*`, `grassleafforest*`, `grasschamomile`, `grassdesert*` | No mesh for any (X16 rows 32-50) — the single largest skipped block |
| 421 / 371 | `horseradish*` / `flowers*` | No mesh / mapped-name miss (`flowers` vs `flower1..3`, X16 rows 28-31, 51-52) |
| 233+… / 151+… / 145+… / 82+… / 22+… / 169 | `drytree*` / `leaftree*` / `pinebroken*` / `pinebrokenmoss*` / `pinestump*` / `pinedryswamp1` | `TREE_SID_UNRESOLVED` — dead/damaged-tree actors with no conversion (X16-adjacent forest gap) |
| 24 / 9 | `pump1/2/3` / `minegolds/irons/coals` | Explicit skips: `PUMP_PROP` (`:1276-1278`, F07 §3.4), `DESERT_ORE_PROP` (`:1272-1274`, F08 R7) |
| 23 | `terrainmeshdesert1..4` (2/5/7/9) | `BASE_UNRESOLVED`; `DESERT_SIDS` UNVERIFIED (`:210`, V59 item 73) |
| ~100 | `landstone*`, `burch*`, `lil1/lily*`, `decortree3*`, `stonesdesert*` spelling variants | No mesh / no rule |

## 4. Skipped classes and families (`_class_for`, `CLASS_PASS_ORDER`)

| Class | Records | Instanced | `unknown_sid` | `unknown_class` | Verdict |
|---|---|---|---|---|---|
| `forests` | 23,399 | 16,787 (71.7%) | 6,612 | 0 | Healthiest; losses are all weeds/palms/dead-trees above |
| `hills_mountains` | 3,770 | 2,597 | 1,173 | 0 | Mountain stamps carry non-relief props; desert_mnt scrub + `terrainmeshdesert` (23) + grasses/ferns in `g/i_mnt` stamps all skip |
| `mines` | 220 | 152 | 68 | 0 | 9 desert ores + 59 weeds inside `mng/mni/mnc` stamps |
| `shore` | 691 | 663 (96.0%) | 28 | 0 | Near-complete: `k_rock` + `rocksea/stonessea/smallstonessea` bases resolve |
| `stone_quarries` | 809 | 549 | 260 | 0 | `d_stn/str_new/desert_stn/stones` stamps; desert-stone material variants reuse base mesh (X16 G3) |
| `swamps_lakes` | 3,806 | 1,901 (49.9%) | 1,905 | 0 | Worst ratio after `other`: lake/swamp stamps are weed-heavy (`grassforest`, `fern`, `plant`) |
| `decor` | 1,543 | 167 (10.8%) | 1,376 | 0 | Only `reed*/gift*/christmas*` under `dcr/d_tls/big_hill` instance; the rest is unmapped meadow |
| `mill_fields` | 0 | 0 | 0 | 0 | By design (H11); hook-only, activation [U] |
| **`other`** | 5,545 | **0** | 5,247 | **298** | **Every record dies**: whole-stamp skip. Sections: `desert_plt*` (1,163), `k_plain*` + `k_plain_mid*` (~900), `k_ravine*` (~700), `j_big_plt*` (~900), `desert_plain*` (~350), `g_hil*`, `plt*`, `str_*`/`b_str_*`, `k_small_plain*`, `hil*`, `fb_*`, `k_pump_*` (24 pump records), `desert_mng/mni/mnc_*_a`, `new_year*`, bare `gift2/3/4` (1 each — **sids exist yet class kills them**) |

Families effectively absent from any instance run: all desert-scrub/palm assemblages, all pure-grass/weed assemblages, lake-interior weed fills, `k_pump` (no art), `new_year` beyond the single christmastree rule, and every `plt/plain/ravine` stamp family.

## 5. Missing-mesh / unknown-sid instance accounting (for the composer gate)

- `skipped_unknown_sid` = **16,669** (41.9% of the feed). This is the dominant loss term — not missing meshes.
- `skipped_unknown_class` = **298**, all with convertible sids (`gift2/3/4`, pines/plantains/bushes inside plain/ravine stamps).
- `skipped_missing_mesh` = **0 statically** (H10); `skipped_no_transform` = **0**.
- Latest capture telemetry (`donor_240_final/capture.json`): `backend.donor_stats` carries **no I09 block** — the run exercised the Z08 legacy relief path (`world_stats.relief_props`: `stamp_count 93`, `prop_count 0`, `skipped_unknown_sid 0`, `skipped_missing_mesh 0`, label PORT APPROX/UNVERIFIED). So the §1-§4 counts are **[D] static-trace predictions** of `terrain_donor_props.gd` over the compact feed, with runtime effect **[U]** until a composer run asserts `counts.props_total > 0 && feed.fallback_used == false` (V66 §5.3, V106 §6.3). `visual_parity_claim: false` end-to-end; capture `parity.status: UNVERIFIED`.

## 6. True donor props vs decorative names (no synthetic assets; no parity claim)

- **True donor props — converted art, instanced (22,816 records, 62 sids):** `terrainmesh1..4` (mountain silhouette carriers, DEC-VIS-02 donor-order path), `mine_gold/iron/coal` (donor `DefaultScale 0.3152`, `MINE_PROP_SCALE`), `tree_pine/fir/spruce1-2-4/oak` + small/dry variants, `rock_stones1..10`, `rock_stonessea1..10`, `rock_sea1..6`, `rock_smallstones1`, `rock_smallstonesea1`, `stone`, `bush1`, `reed1..3`, `gift1..6`, `christmastree`, `plantain1`. All donor `.prop → .actor → .osm` chains per X16 C.1; materials/LODs stay PORT APPROXIMATION.
- **Decorative names with no converted art (all 16,669 skipped records):** every grass/weed/flower/scrub/palm/dead-tree/lily/pump/desert-mesh name in §3. They are real donor `Objects[]` records (positions/transforms exported, V106 P5) with no derived mesh — instancing them would require conversion, never synthesis.

## 7. Ranked actions — five concrete, donor-grounded, no-synthetic-asset steps

1. **A1 — Per-variant mapping reuse (zero new art; ~15 sids, variety only).** Route `smallstones.N → rock_smallstonesN`, `smallstonessea.N → rock_smallstoneseaN`, `plantain.2 → plantain2`, `plantain.3 → plantain3` instead of clamping everything to variant 1 (`:1340-1342` + dot-strip `:1263-1265` review). Unlocks already-converted `rock_smallstones2-6`, `rock_smallstonesea2-6`, `plantain2/3` (currently 0 instances) and, with `bushes.1`-style aliases, `bush2-4`/`flower1-3`/`fern1-4`. Cost: a few extra MultiMesh batches; instance budget unchanged. No parity claim.
2. **A2 — Bare-name mapping aliases (zero new art; ~4,000+ instances).** Add `fern → fern1`, `flowers → flower1`, `plantainyellow → plantain1` (donor material-variant caveat per X16 rows 21/28/97, G3), `drybushes.1 → bush1`, `stonesdesert*` material note. All targets are converted OBJs on disk; change is confined to `_sid_for_base` + an UNVERIFIED material-variant label each.
3. **A3 — Palm + desert-scrub converter batch (desert density).** Convert `palm/palmsmall` and `desert1..5` (+`plantyellow`) OSM→OBJ with exact-vertex/topology checks per the FIX-FIELD-ASSETS pattern (`field_conversion.manifest.json` invariants). Unlocks ~5,500 forest-class records (`palm` 1,319, `desert1` 1,262, `desert3` ~830, `desert4/5` ~630, `plantyellow` 1,315) that no mapping edit can reach. No `.pattern`/height work; meshes only + manifest sids.
4. **A4 — Understory converter batch (ground-cover density; largest count).** Convert the grass/weed set (`grass*`, `grassforest*`, `grassleafforest*`, `chamomile*`, `burdock*`, `horseradish*`, `plant*`, `flowers*` actor set) as instanced cross-quads with donor albedo + `alpha-scissor 0.5 / cull-disabled` binding already used at `:1241-1246`. ~4,500+ records; MultiMesh absorbs the count (batch-per-sid growth is bounded — one batch per new sid). Winter `*w` materials stay UNVERIFIED (X16 E5).
5. **A5 — `other`-class stamp rules + remaining converter gaps (5,545 records).** (a) Add `_class_for` prefixes: `plt*/desert_plt*/desert_plain*` → `forests` (weed fill) or `stone_quarries` where bases are stones; `k_plain*/k_ravine*/k_small_plain*/hil*/g_hil*/str_*/b_str_*/fb_*` → matching class by base; this alone rescues the 298 `unknown_class` records and re-labels 5,247 weed sid-skips into the right class counters. (b) Convert `pump1..3` (F07 §3.4, 24 records) and `terrainmeshdesert1..4` materials (23 records, `DESERT_SIDS`). (c) Gate assertion per V66 §5.3/V106 §6: `props_total > 0 && fallback_used == false && feed.source ∈ terrain_new/` — never gate on `feed_source` alone (V66-F1).

## 8. Explicit non-claims and open unknowns

- No donor GPU A/B frame; all density/efficiency statements are about record counts and batch structure, not visual parity (CHARTER.md:43-44,122-135).
- Efficiency: 22,816 predicted instances fold into ≤62 MultiMesh batches (class|family|sid keys, `:1084`); A1 adds variety at ~+15 batches, no instance-count change. LOD 0..150 / 0..2500 semantics stay [U] (`:130-131`, `:398-432`).
- Task-figure discrepancy: "221 feed BaseNames lack OBJs" is superseded by measured **133/235** (this report, reproducible by re-running the §0 mapping over `families/`). X16's "63/141 MISSING" is consistent but scoped to forest/stone/mine families only.
- Runtime counters (`skipped_*`, `props_total`, `matched_stamps`) remain **[U]** until an I09 composer run lands them in capture telemetry; current `donor_240_final` predates/omits the I09 path (§5).

*End of audit. Exactly one repo file written; no code, asset, config, test, manifest, git, app/, Godot, runner, gate or capture state created, edited or deleted. NO DONOR PARITY CLAIM.*
