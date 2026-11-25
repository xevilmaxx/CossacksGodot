---
id: SEASON-PLAN-01
task: "Concrete small-ticket plan for winter/desert tile-set swapping in the 3D variant"
date: 2026-11-25
status: DELIVERED__PLAN_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB__NO_DONOR_COPY
scope: "Read-only planning. This report is the ONLY file written. No port .gd/.gdshader/.json/asset/config/test edited; no Godot runner job; no donor file opened, executed or copied; no test weakened."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
output: "docs/coord_swarm_2026-11-25/reports/SEASON_PLAN_01.md"
labels: [observed, derived, inferred, UNVERIFIED, PORT APPROXIMATION]
verification_passes: 3
visual_parity_claim: false
donor: "C:\\Games\\Cossacks 3 (READ-ONLY; NOT opened this task — all donor path:line facts are cited second-hand from DENV-01 / DEC-05 / DTRN-01, which read them in earlier read-only passes)"
---

# SEASON-PLAN-01 — concrete small-ticket plan: winter/desert tile-set swapping (3D)

## 1. Goal

Turn the DENV-01 finding ("winter set swap, desert set swap and cloud/weather are the port's
top three visual gaps") and the DEC-05 / DTRN-01 atlas findings into a **minimal, ordered,
one-file-per-ticket implementation plan** for the 3D variant. This document is a **plan
only**: it establishes exactly what is on disk, reconstructs the donor swap chain from
already-audited citations, defines the ticket sequence with owner file / change / donor
citation / acceptance / gate, and records blockers that must not be papered over.

In scope: (a) atlas expansion path with exact new file names and size implications;
(b) season → atlas / tile-dictionary selection hook; (c) prop-material suffix `w`;
(d) verification on the 64² fixture with a season overlay; (e) what must stay labelled
PORT APPROXIMATION.

Out of scope (explicitly, per DENV-01 §5.3): clouds/weather, sky rework, fog enabling,
snow PFX, lens flare, day/night. None of those are proposed here.

---

## 2. Sources

All read this task, none edited.

| # | Source | Role / label |
|---|---|---|
| S1 | `docs/coord_swarm_2026-11-25/reports/DENV_01_environment.md` | donor season/climate truth: enum, `_misc_SetSeason` / `_misc_SetDesert`, `_winter` vs `w` suffixes, active-vs-alternative matrix, port gap ranking (observed, 2 passes) |
| S2 | `docs/coord_swarm_2026-11-25/decomp/DEC_05_terrain_formats.md` | 112 tile DDS, 27 winter / 12 desert families, `terrain.presets` two 124-entry sets, `gc_meters_to_tile=2` (observed, 2 passes) |
| S3 | `docs/coord_swarm_2026-11-25/reports/DTRN_01_donor_terrain_pipeline.md` | C4 family counts, C5 index dictionary, M6 season gap, §7 fix recipe item 7 (observed/derived) |
| S4 | `docs/coord_swarm_2026-11-25/GAPS.md` | Light/environment row (line 41), Verification gap (line 42), prior-failure watchlist §3 (inferred/coordination) |
| S5 | `docs/coord_swarm_2026-11-25/PLAN_IMPLEMENTATION.md` | ticket discipline: one file / one builder / backup / targeted runner job / no test weakening (coordination) |
| S6 | `variant3d/scripts/tile_atlas_loader.gd` (READ-ONLY) | three-mode atlas loader, `single_atlas_path` override, hardcoded V785 manifest path (observed) |
| S7 | `variant3d/scripts/world3d_terrain.gd` (READ-ONLY) | atlas load/bindings, name dictionary, per-cell UV2.x selection, stats (observed) |
| S8 | `variant3d/scripts/data.gd` (READ-ONLY) | `BIOME`, flat `TERRAIN_TINT` (observed) |
| S9 | `variant3d/scripts/config.gd` (READ-ONLY) | `gameplay.season` default and `Data.BIOME` assignment (observed) |
| S10 | `variant3d/scripts/game.gd`, `main.gd` (READ-ONLY) | existing `WINTER_ART` / `winter_tile_names` data and dump schema (observed) |
| S11 | `docs/coord_swarm_2026-11-25/reports/DALPHA_02_patch_mapping.md` | shader tile→alpha patch selection, PORT APPROX label, no-parity stance (observed) |
| S12 | on-disk Python 3.14 reads of `variant3d/assets/terrain/**` and `variant3d/tests/fixtures/_smallmap_harness.gd` | inventory, verified 3× (observed) |

Evidence labels throughout: **observed** = literal file bytes/lines read (port this task; donor
via S1–S3 earlier passes); **derived** = deterministic arithmetic over observed values;
**inferred** = best reading with caveat; **UNVERIFIED** = cannot be proved from readable data;
**PORT APPROXIMATION** = port-chosen value/transport explicitly not claimed as donor parity.

---

## 3. On-disk inventory (verified 3× — counts stable across all passes)

### 3.1 Winter / desert PNGs

| Path | Count | Names | Label |
|---|---:|---|---|
| `variant3d/assets/terrain/blocks/winter*.png` | **27** | `winter0.png … winter26.png` (all integers 0–26, no gaps) | observed, 3 passes (PowerShell `-Filter`, Python `re.match`, third Python `os.walk`) |
| `variant3d/assets/terrain/blocks/desert*.png` | **12** | `desert1.png … desert12.png` | observed, 3 passes |
| `variant3d/assets/terrain/blocks/*.png` total | **112** | matches donor's 112 tile DDS conversions (S2 §3.3; S3 C3) | observed, 3 passes |

**Finding:** winter art is **present but unpacked**, not missing. The V7-85 manifest lists all 27
`winterN.png` in `unused_shipped_blocks` with `unused_note` = *"27 winterN.png ship but have no
index in presets_summer.json; they belong to the Winter set and are intentionally not packed"*
(`variant3d/assets/terrain/atlas/tile_index_atlas.manifest.json`, `unused_shipped_blocks` 27
entries; S1 §5.2 cites lines `:3019-3048`). S3 Q6 / C9 are therefore resolved: Desert art is
reachable, Winter art is not. This corrects any premise that winter PNGs must be re-converted.

### 3.2 Atlas geometry and spare-cell arithmetic

| Field | Value (manifest `atlas` block) | Label |
|---|---|---|
| `grid` | `[16, 8]` = 16 cols × 8 rows | observed |
| `slots` | **128** | observed |
| `named_cells` | **124** (indices 0–123) | observed |
| `filled_cells` | **121** | observed |
| `empty_cells` | **3** (`alpha0a` idx 86, `alpha0b` idx 110, `alpha0c` idx 123 — no shipped PNG) | observed |
| **spare cells** | **128 − 124 = 4** (indices 124–127) | derived, 3 passes |
| `cell_size` / `size` | `[1024,1024]` / `[16384,8192]` | observed |
| `packing_label` | `APPROX_ATLAS_PACKING (donor tsDouble/ttExtended is engine-side, UNVERIFIED)` | observed |
| `tile_index_atlas.png` | **179,912,941 bytes** (~180 MB) | observed, 3 passes |
| raw RGBA8 GPU footprint | 16384×8192×4 = **536,870,912 B = 512 MiB** per atlas | derived |

Desert placement: `desert1..12` are packed at indices **111–122** (manifest `layout`;
`presets_summer.json` list positions 111–122; S1 §5.2). Winter-sourced layout entries: **0**.

**Spare-cell verdict:** 4 spare slots cannot hold 27 winter art PNGs, let alone a 124-entry
Winter dictionary. Expanding in place to a 16×16 grid would make a 16384×16384 PNG
(≈4× pixels, ≈720 MB compressed / 2 GiB RGBA8) — rejected as non-minimal. **The minimal atlas
expansion is a separate Winter atlas** (SP-4 below), which also keeps the Summer atlas and
all existing dumps byte-identical.

### 3.3 Winter atlas / manifest / dictionary existence

| Query | Result | Label |
|---|---|---|
| any `*winter*manifest*` / `*winter*atlas*` / `*winter*preset*` under `variant3d/assets/**` | **none** | observed, 3 passes |
| `variant3d/assets/terrain/structs/` | `presets_summer.json` (124 names), `smooth_summer.json`, `tileblocks.json`, `water.json`, 2 authoring BMPs — **no `presets_winter.json`** | observed |
| `variant3d/assets/terrain/atlas/` | `tile_index_atlas.png`, `tile_index_atlas.manifest.json`, `alpha.png`, `alphavert.png` — **no winter atlas** | observed |

### 3.4 Port season hooks that already exist (and their limits)

| Site | Value | Limitation | Label |
|---|---|---|---|
| `data.gd:199` | `static var BIOME := "summer"` | string-only; never maps to donor 0/2/3 enum | observed |
| `data.gd:219-225` | `TERRAIN_TINT` winter `(0.86,0.91,1.0)`, desert `(1.0,0.90,0.70)`, `terrain_tint()` returns a **flat colour** | donor swap is tile-set + lighting table, not a tint (S1 §5.2) | observed + PORT APPROX |
| `config.gd:82` / `:430` | `"season": "summer"`; `Data.BIOME = text("gameplay.season", …)` | string-only | observed |
| `world3d_terrain.gd:170` | `V785_MANIFEST_PATH` const — single, hardcoded Summer manifest | no season branch | observed |
| `world3d_terrain.gd:273-332` | `_load_atlas()` loads manifest via `_read_json(V785_MANIFEST_PATH)` (:280) and constructs loader via `loader_script.new(atlas_mode)` (:289) | atlas choice fixed; `stats["atlas_mode"]` reports transport only (:1094) | observed |
| `world3d_terrain.gd:870-878` | `_tile_name_index` / `_tile_index_name` built from manifest `layout` | Summer dictionary only | observed |
| `world3d_terrain.gd:924-992` | per-cell `tid` → face/shore overrides → `uvs2[i] = Vector2(tid, face)` | no BIOME consultation | observed |
| `tile_atlas_loader.gd:58,63,68,75,103-104` | `SINGLE_ATLAS`, `V785_MANIFEST`, `CONFIG_SINGLE_PATH_KEY`, `single_atlas_path` override | **`manifest_path` is NOT overridable** — `_load_grid()` `:297-303` and `_load_array()` `:390` read the const directly | observed |
| `game.gd:1427-1467` | `WINTER_ART` 124-entry alias map (winter names / desert reuse) | data only; "world.gd keeps ownership of the season tint / art swap" (:1423-1425) | observed |
| `game.gd:1469-1479,1699-1706` | `winter_tile_names`, `winter_block_for()`, populated only when `Data.BIOME == "winter"` | **not in the dump** — `main.gd:741` emits only `tileblock`; the 64² stub harness has no such field (`_smallmap_harness.gd:11-23`) | observed |
| `variant3d/assets/terrain/decals_dds/*w.dds` | **226** building winter decals (and 226 PNG counterparts) | tree/plant `w` art (`fir1w`, `field1w`, …) **absent** — search returned 0 | observed |

---

## 4. Donor swap chain (citations second-hand from S1–S3; donor not opened this task)

### 4.1 Season enum and set selection

| Donor path:line | Literal / meaning | Label |
|---|---|---|
| `scripts\lib\map.script:250` | `map.settings.gen.season` default `0` | observed (via S1 §3.5) |
| `scripts\dmscript.global:237` | `gc_MaxSeasonCount = 3` → 0/1/2 implied; value `1` **UNVERIFIED** | observed + UNVERIFIED |
| `scripts\lib\miscext2.script:3318-3323` | UI toggle `season=2 → _misc_SetSeason(0)`, else `_misc_SetSeason(2)` (only 0↔2) | observed |
| `scripts\dogenerate.inc:4`, `:2079` | desert branch `gMap.settings.gen.season = 3` | observed |
| `terrain\tiles\terrain.lib:12-15` | `seasons.Summer/Autumn/Spring = Summer`; `seasons.Winter = Winter` (`resource.lib:15` loads it) | observed (S1 §3.1) |
| `terrain\tiles\terrain.presets:2-6` / `:134-263` | Summer and Winter **124-entry** sets; Winter names `*_winter`, `alpha0a/b/c` shared (`resource.lib:14` loads it) | observed (S1 §3.3; S2 §4.6; S3 C5) |
| `terrain\tiles\tiles.season:2-3` | `TexName=grass1`, `Summer=grass1`; **no Winter/Desert entry** — a stub, not the swap mechanism | observed (S1 §3.2) |
| `terrain\tiles\tiles.mat` (via S1 §3.3) | resolves 124 Winter aliases to **23 `winter*.dds` + 12 reused `desert*.dds`**; `winter18/23/24/26` have no alias; `winter25` is green grass | observed in S1, not re-parsed here |

### 4.2 What the two swap functions do

| Function / source | Effect | Label |
|---|---|---|
| `_misc_SetSeason` — `scripts\lib\miscext.script:1547-1625+` | `SetSeasonType(season)` (:1549); destroy `leaftree` objects in winter, conifers survive (:1568-1576; restated `dogenerate.inc:1975-1982`); building child material `detail → detailw` (:1578-1599); alpha tiles `alpha0a ↔ alpha0b` (:1609-1625) | observed text; runtime activity UNVERIFIED (all `.inc` lines carry `;`) |
| `_misc_SetDesert` — `scripts\lib\miscext.script:1429-1543` | explicit per-cell remap `grass1→sandsea5`, `grass7/8→desert6`, `ground1→test16`, `grass2/test7/test8→desert11`, `rock1→desert2`, `rock7→desert4`, `rock9→test23`, `alpha0a→alpha0c` (:1447-1502); `rock8` height-gated → `desert2` (:1504-1505); dry height `koef=0.8` (:1513-1520); mine basename suffix `s` (:1531-1534); other env objects destroyed (:1536-1537) | observed text, remap **not** a palette swap; runtime UNVERIFIED |
| `scripts\common.inc\texturemap.inc:525-526,605-606,639-640,927-928,950-951` | append **`_winter`** to tile names when `GetSeasonType=2` | observed (S1 §4) |
| prop `.prop` files (via S1 §4): `grass.prop:36-42`, `fir.prop:33-43`, `leaftree.prop:33-43`, `field.prop:58-76`, `palm.prop:34-44`, `desert1.prop:32-42` | winter material suffix **`w`** (`fir1→fir1w`, `field1→field1w`, `plantsatlas→plantsatlasw`), `UseableWinterMaterials`, `UseSeasonMaterial=True` | observed via S1; prop art absent in port (§3.4) |
| `env\colors\colors.lib:94-97` / `:98-101` | winter table 6 / desert table 7 override only `ShadowBlendingDiffuse`; all 12 `.palette` files byte-identical (`:3-14`) | observed (S1 §2.5, §3.7) |
| `game\var\generator.cfg:1629-1655` | `desert_tiles` weights `1000/0/1000/100` | observed (S1 §3.5) |

**Two suffixes must not be conflated:** tile preset aliases append `_winter`
(`terrain.presets:138`), prop materials append `w` (`fir1w`). The cloud preset field
`season=2` (`clouds.presets`) maps to neither — **UNVERIFIED**; do not encode it (S1 §2.7/Q4).

### 4.3 Derived port mapping (the core design decision)

Donor Winter is a **1:1 rename at the same preset index**, resolved to art by `tiles.mat`.
Therefore the minimal port implementation is:

1. Keep `tileblock` indices **unchanged** for all seasons (summer dumps stay byte-identical).
2. Select the **manifest + atlas PNG by BIOME**: Summer → existing `tile_index_atlas.*`;
   Winter → new `tile_index_winter_atlas.*`. The Winter manifest carries `*_winter` names whose
   `source_png` points at the already-on-disk `winterN.png` (or reused `desertN.png`).
3. Desert has **no separate donor preset section** — apply the `miscext.script:1447-1502`
   name remap to the tile index **before** UV2 assignment, using the already-packed
   `desert1..12` indices 111–122.
4. Switch the bound texture, **never accumulate both atlases** (§3.2 memory). No shader edit:
   `DALPHA-02`'s `alpha_patch_uv()` decomposes `UV2.x`, which is index-preserving here (§6 B4).

This design is **derived** from observed donor/port facts, not a claim of donor runtime parity.

---

## 5. Ordered ticket plan (plan only — no ticket has been executed)

One owner file per ticket. Every ticket obeys `PLAN_IMPLEMENTATION.md` §3: backup to
`inbox/backup/<name>.bak-<TICKET>`, minimal diff, donor `path:line` citation or explicit
`UNVERIFIED` + `PORT APPROXIMATION`, unique runner job id, one report, COORD merges.

| ID | File owner (EXCLUSIVE) | Change | Donor citation | Acceptance | Gate |
|---|---|---|---|---|---|
| **SP-1 SEASON-ENUM** | `variant3d/scripts/data.gd` | Add `SEASON_ENUM := {"summer":0,"winter":2,"desert":3}` + `season_enum(biome)`; comment `TERRAIN_TINT` as **legacy flat tint, NOT the donor swap mechanism** (do not delete — 2D sibling consumes it). | `map.script:250`; `dmscript.global:237`; `miscext2.script:3318-3323`; `dogenerate.inc:4,2079`; `miscext.script:1549` (via S1) | Enum round-trip for 0/2/3; value `1` stored as UNVERIFIED, never guessed; Summer default and all seed dumps byte-identical. | none |
| **SP-2 WINTER-DICT** | `variant3d/assets/terrain/structs/presets_winter.json` (NEW data file) | Author exactly **124** Winter names in Summer index order: `*_winter` except `alpha0a/b/c` shared and `desertN_winter → desertN` reuse. | `terrain.presets:134-263`; `terrain.lib:14`; `tiles.mat` alias resolution (S1 §3.3) | 124 entries, indices 0–123 identical to `presets_summer.json`; every target resolves to an on-disk `winter0..26` or `desert1..12` PNG; no invented index; `winter18/23/24/26` recorded as donor-unaliased. | SP-1 (optional; may parallel) |
| **SP-3 DESERT-REMAP** | `variant3d/assets/terrain/structs/desert_remap.json` (NEW data file) | Per-case Summer-name → Desert/set-name table from `_misc_SetDesert`; include `rock8` height gate, `koef=0.8` and mine `s` as **labelled data only** (not executed in this ticket). | `miscext.script:1447-1502`, `:1504-1505`, `:1513-1520`, `:1531-1537`; `generator.cfg:1629-1655` | Every source key exists in `presets_summer.json`; every target resolves to a packed atlas index (desert 111–122, `sandsea*` 93–98, `alpha0c` 123); runtime-gated entries labelled UNVERIFIED. | none |
| **SP-4 WINTER-ATLAS** | `variant3d/tools/build_season_atlas.py` (NEW tool; the only code file) | Emit `variant3d/assets/terrain/atlas/tile_index_winter_atlas.manifest.json` + `variant3d/assets/terrain/atlas/tile_index_winter_atlas.png` (+ optional `variant3d/assets/terrain/atlas_parts_winter/`). Pack the 27 on-disk winter PNGs (+12 reuse desert) into the same 16×8 / 1024² grid; same manifest schema and label set; **no donor read/copy**. Size: +≈180 MB PNG; +512 MiB raw RGBA8 if resident; parts ≈45 MB ×4. | `terrain.presets:138-261`; `reftile.lib:3-12` (packing is engine-side → `APPROX_ATLAS_PACKING`); S1 §3.3 | Manifest loads after SP-5; SHA-256 recorded; 27/27 winter names consumed or explicitly listed unused; grid stays 16×8 (4 spare cells remain spare); GitHub >100 MB / LFS caveat copied from `tile_atlas_loader.gd:19-22`. | SP-2 |
| **SP-5 ATLAS-HOOK** | `variant3d/scripts/tile_atlas_loader.gd` | Add a `manifest_path` config key/override **parallel to** `single_atlas_path` (`:68`, `:103-104`); consume it in `_load_grid()` (`:297-303`) and `_load_array()` (`:390`); default stays `V785_MANIFEST` so Summer is byte-identical. | `terrain.lib:12-15`; `resource.lib:14-15` (set-selection **mechanism**, not a literal donor value) | `TileAtlasLoader.new("single", {"manifest_path":…, "single_atlas_path":…})` loads the winter atlas; default path and fallback chain unchanged; no new indices. | SP-4 |
| **SP-6 RENDER-HOOK** | `variant3d/scripts/world3d_terrain.gd` | Const BIOME → `{manifest, single_atlas_path, dict}` table; `_load_atlas()` (`:280`,`:289`) selects both paths; `_tile_index_name` (`:870-878`) from selected manifest; for desert apply `desert_remap.json` to `tid` before `uvs2[i]` (`:924-992`); report selected manifest/atlas in stats (`:1094`,`:1170-1179`). **No shader edit.** | `terrain.lib:12-15`; `terrain.presets:2-6,134-263`; `texturemap.inc:525-526,605-606` (`_winter`); `miscext.script:1429-1543` (desert remap); `miscext.script:1547-1625` (season swap); `colors.lib:94-101` (lighting-table data only → PORT APPROX) | Same seed Summer vs Winter changes the **atlas path in stats and tile grain**, not only colour; desert indices appear; Summer dump byte-identical; face/shore code (`:934-985`) untouched; 0 fallback-material cells. | SP-1..SP-5 **and TRN-FACE merged** (co-owner of this file) |
| **SP-7 PROP-W** | `variant3d/scripts/world3d_entities.gd` | Winter prop material suffix `w` for listed families; remove `leaftree` instances; building child `detail → detailw`; absent art falls back with explicit PORT APPROX label, no invented asset. | `grass.prop:36-42`, `fir.prop:33-43`, `leaftree.prop:33-43`, `field.prop:58-76`, `palm.prop:34-44`, `desert1.prop:32-42` (via S1 §4); `miscext.script:1568-1576`, `:1589-1596`; `dogenerate.inc:1975-1982` | Winter fixture has **0** leaftree; suffix applied only to listed families; no new art invented; Summer fixture byte-identical. | **DECOR-01 merged** (co-owner); winter prop art missing → fallback (B1b) |
| **SP-8 VERIFY** | `variant3d/tests/t_season_atlas.gd` (NEW) | 64² **dump-driven** season overlay: set `Data.BIOME` to summer/winter/desert, build the fixture, assert selected manifest/atlas path + `stats["atlas_mode"]`, grain difference via distinct source-PNG/histogram counts, all 27 winter names resolve, desert indices reachable, 0 fallback cells, Summer reproducibility. Write result JSON; `call_deferred(quit)`. | none (verification of SP-1..SP-7) | PASS **alone** on 64² via `variant3d/tools/godot_runner.py`; fails before SP-6; **no test weakened**; no donor A/B or visual-parity claim; runner job id recorded. **Do not edit** `_smallmap_harness.gd` — dump-driven design avoids needing `winter_tile_names`. | SP-6, SP-7, TEST-HARNESS merged (consume only) |

**Ordering rationale:** data files (SP-1..SP-3) precede the generator (SP-4); generator precedes
loader override (SP-5); loader override precedes renderer hook (SP-6); renderer hook precedes
props (SP-7, independent art path) and verification (SP-8). No ticket edits `game.gd`,
`main.gd`, the shader, or the test harness.

---

## 6. Blockers (do not weaken tests or claims to clear them)

| # | Blocker | Evidence / label | Effect on plan |
|---|---|---|---|
| **B1** | **Winter PNGs are present, not missing** — 27 on disk, intentionally unpacked. | `manifest.unused_shipped_blocks` (27 entries, S1 §5.2 `:3019-3048`); §3.1 verified 3× — **observed** | Not an art blocker. SP-4 is pure packing; no donor copy or reconversion is needed. `winter18/23/24/26` have no donor alias and `winter25` is green grass (S1 §3.3, **observed**) — SP-2 must record these, not invent replacements. |
| **B1b** | **Prop-material `w` art is missing.** 0 files matching `fir1w`/`field1w`/`palm*w`/etc.; only 226 building `*_w.dds` decals (+226 PNG) exist. | §3.4 search — **observed** | SP-7 can only swap families whose art exists; all others must be a labelled PORT APPROX fallback. Full prop fidelity needs a separate donor-to-port art ticket (Q6). |
| **B2** | **Atlas memory.** Current PNG 179,912,941 B (>GitHub ~100 MB/file — `tile_atlas_loader.gd:19-22`); raw RGBA8 512 MiB per atlas; a second atlas adds ≈180 MB disk and another 512 MiB VRAM if both bound; split parts add ≈180 MB in `user://` cache. | §3.2 — **observed** (file size) + **derived** (footprint) | Winter atlas must be loaded **instead of**, never alongside, the Summer atlas (SP-6). LFS or `atlas_parts_winter/` required for clones. In-place grid expansion rejected. |
| **B3** | **No donor GPU A/B** at a matched camera; all port visual judgements structural. | GAPS.md line 42 + watchlist #1; S1 §1.2; S3 Q11 — **observed** (absence) | Parity stays **UNVERIFIED**. SP-8 asserts structure/grain, not pixels; metrics must not override visual review (GAPS §3 #3). Never write "looks donor-like". |
| **B4** | **TRN-DATA (`variant3d/scripts/game.gd`) conflict.** `WINTER_ART` + `winter_tile_names` already exist (`game.gd:1427-1479,1699-1706`) but are **absent from the dump** (`main.gd:741` emits only `tileblock`) and from the 64² stub (`_smallmap_harness.gd:11-23`). TRN-DATA owns this file for `tilesmooth_scripts.cfg` parsing. | §3.4, §5 SP-6 — **observed** | SP-2..SP-6 deliberately leave `game.gd`/`main.gd` untouched: Winter alias is encoded **in the new manifest by construction**, Desert remap in a new JSON. Summer path stays byte-identical, satisfying TRN-DATA's acceptance. A future "single source of truth" refactor must be coordinated with TRN-DATA (Q3). |
| **B5** | **DALPHA-02 (shader) conflict.** The shader's tile→alpha patch rule is already a labelled PORT APPROX (`DALPHA_02_patch_mapping.md:12,140-142`) keyed on `floor(abs(tile))`. | S11 — **observed** | SP-6 switches the **bound texture**, preserves all indices, so `alpha_patch_uv()`, `mask_to_alpha=1.0`, `unshaded`, face planes and `uv_repeat` stay byte-identical. No shader edit; do not ask the shader owner to re-derive patch indices per season. |
| **B6** | **Donor runtime activity UNVERIFIED.** All `texturemap.inc` / `dogenerate.inc` / `onloadfull.inc` season lines carry the donor `;` prefix; `_misc_SetSeason`/`_misc_SetDesert` callers are not proven active in the shipped build. | S1 §7 Q6; S3 Q9 — **UNVERIFIED** | Implement donor **intent**, label the mechanism PORT APPROXIMATION; do not assert "donor runs this at runtime". |
| **B7** | **Season enum value `1` and cloud `season=2` are UNVERIFIED.** `gc_MaxSeasonCount=3` implies 0/1/2; only 0/2/3 are readable. | S1 §3.5, §7 Q4/Q5 — **UNVERIFIED** | SP-1 maps only 0/2/3; no code path for value 1; cloud field is not used anywhere in this plan. |
| **B8** | **Co-ownership of `world3d_terrain.gd` (TRN-FACE) and `world3d_entities.gd` (DECOR-01).** These files are owned by other tickets in `PLAN_IMPLEMENTATION.md`. | S5 lines 33-34 — **observed** | SP-6 and SP-7 must be sequenced **after** those tickets are merged; re-read the files immediately before editing (S1 §5 volatility note). |
| **B9** | **Flat `TERRAIN_TINT` would be mistaken for the swap.** Donor winter/desert are set swaps + `colors.lib` lighting tables, not a colour multiply. | `data.gd:219-225`; S1 §5.2/§8 — **observed** | SP-1 must comment it as legacy, not remove it (2D sibling). SP-8 must assert **grain/atlas change**, not merely a tint change. |
| **B10** | **Never weaken a test to get green** (GAPS §3 #8; S5 §3). | GAPS.md line 55 — **observed** | SP-8 adds an atom; it does not retune `t_terrain3d.gd`, the 21 structural checks, or any existing assertion. Existing 29/29 + 17/17 gates stay untouched. |

---

## 7. What must stay labelled PORT APPROXIMATION / UNVERIFIED

Carry these labels into every new file and report; do not silently upgrade them:

1. **Atlas packing** — 16×8 grid, V7-85 manifest order, `APPROX_ATLAS_PACKING`; donor
   `tsDouble`/`ttExtended` is engine-side and commented (`reftile.lib:3-12`).
2. **Sand1/sand2 256→1024 NEAREST upscale** — `APPROX_SAND_UPSCALE` (`tiles.lib:53-63`).
3. **Tile→alpha patch choice** — `DALPHA-02` **PORT APPROXIMATION — donor engine rule UNVERIFIED**.
4. **Eye-plane texgen / world-ground UV** — TRN-SHADER approximation; not a donor literal.
5. **Face promotion + 25° tilt** — TRN-GEOM **PORT APPROXIMATION**, donor promotion rule UNVERIFIED.
6. **Flat season tint** — `data.gd:219-225`, legacy port art, **not** donor swap.
7. **Desert height `koef=0.8`, mine suffix `s`, rock8 height gate** — donor text-observed,
   runtime UNVERIFIED; SP-3 stores them as labelled data, SP-6 does not apply height scaling.
8. **Lighting-table difference** — `colors.lib:94-101` overrides only `ShadowBlendingDiffuse`;
   all `.palette` bytes identical. Any port colour compensation is PORT APPROX.
9. **Fog / sky / clouds / snow** — out of scope; `fog_mode=0` stays (mode bridge UNVERIFIED,
   S1 §2.10 correction C4); do not enable fog to "make winter look cold".
10. **Prop `w` fallback** — missing art (B1b) means partial fidelity only.

---

## 8. Open questions (do not guess)

1. **Q1** What should the four donor-unaliased winter cells (`winter18/23/24/26`, plus the
   green `winter25`) sample in the new manifest? Donor alias list is observed (S1 §3.3); a
   replacement choice would be invented. **UNVERIFIED** — record as explicit unused/legacy.
2. **Q2** Should desert dry-land height `koef=0.8` (`miscext.script:1513-1520`) be applied to
   the mesh? It requires a `world3d_terrain.gd` height edit beyond SP-6's index-only scope and
   is runtime-UNVERIFIED. Deferred; label if implemented later.
3. **Q3** Single source of truth for the Winter alias map: `game.gd:1427-1467` (data only, not
   in dumps) vs the new `presets_winter.json` / manifest. Duplication is intentional here to
   avoid a TRN-DATA co-edit; consolidation needs TRN-DATA coordination.
4. **Q4** Winter atlas transport for clones: Git LFS or `atlas_parts_winter/` split parts?
   Both are PORT choices with no donor analogue (B2). Needs COORD decision before SP-4 ships.
5. **Q5** Does the donor winter/desert `colors.lib` table need a 3D lighting counterpart?
   Separate from tile art; would require a shader/rig owner; not in this minimal plan.
6. **Q6** Can the missing tree/plant `w` art (`fir1w`, `field1w`, …) be converted from donor
   for full prop fidelity? Requires a donor-read ticket; **UNVERIFIED** availability in port.
7. **Q7** What structural threshold proves "different grain" without a donor A/B? Proposed:
   distinct resolved `source_png` set and atlas path change, **not** pixel metrics that could
   override visual review (GAPS §3 #3).
8. **Q8** Do the `;`-prefixed donor swap scripts execute in the shipped build? Same caveat as
   S1 Q6 / S3 Q9 — **UNVERIFIED**; plan implements intent only.

---

## 9. Summary

**Inventory (verified 3×):** 27 winter PNGs (`winter0..26`) and 12 desert PNGs (`desert1..12`)
are on disk in `variant3d/assets/terrain/blocks/` — winter art is **unpacked, not missing**.
The 124-cell atlas has 128 slots, 121 filled, 3 empty, and only **4 spare cells**: too few for
a Winter set, so the minimal path is a **separate Winter atlas** whose PNG is ≈180 MB
(512 MiB raw RGBA8), loaded *instead of* the Summer atlas. No winter atlas/manifest/dictionary
exists today.

**Donor chain (from S1–S3, donor not opened this task):** `terrain.lib:12-15` aliases
Summer/Autumn/Spring to one set and Winter to another; `terrain.presets:134-263` holds the
124-entry Winter dictionary; tile aliases get `_winter`, prop materials get `w`; desert is a
`gen.season=3` in-place name remap (`miscext.script:1447-1502`), not a palette swap; season
enum is 0/2/3 with value 1 UNVERIFIED.

**Plan:** 8 ordered tickets — SP-1 enum (data.gd), SP-2 Winter dictionary (new JSON), SP-3
Desert remap (new JSON), SP-4 Winter atlas build (new tool + generated PNG/manifest), SP-5
loader manifest override, SP-6 renderer selection hook, SP-7 prop `w`, SP-8 64² season-overlay
test. Each has one owner file, a donor citation, an acceptance and a gate; none edits donor,
`game.gd`, `main.gd`, the shader, or the harness.

**Blockers:** missing prop `w` art (tile art is fine), ~180 MB/512 MiB atlas memory and the
GitHub 100 MB limit, no donor GPU A/B, TRN-DATA co-ownership of `game.gd`, DALPHA-02's
index-preserving shader contract (which is why **no shader edit** is needed), UNVERIFIED donor
runtime activity, and the TRN-FACE/DECOR-01 co-owned files. No test is weakened and visual
parity is not claimed.

*End of SEASON-PLAN-01. One report written; no donor binary opened/copied/executed; no Godot
job; no code, asset, config, test or git state changed.*
