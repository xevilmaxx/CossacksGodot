---
id: SP-08
title: "SP-8 — 64² season-overlay test atom (authoring report)"
owner: SP-8 (test-authoring micro-worker)
date: 2026-11-25
status: AUTHORING_ONLY__NO_GODOT_RUN__NO_RUNNER_JOB__NO_DONOR_ACCESS__NO_PASS_CLAIM
scope: "One new test file plus this report. No source/shader/asset/config/manifest/fixture/gate-file/git edit; no Godot launch, no queue ticket, no capture PNG, no result JSON produced."
owns:
  - "variant3d/tests/t_season_overlay.gd"
  - "docs/coord_swarm_2026-11-25/reports/SP_08_season_test.md"
labels: [SEASON_OVERLAY, DUMP_DRIVEN, 64X64, THREE_VARIANTS, WINDOWED_SUBVIEWPORT, SKIP_CAPTURE_GUARD, PENDING_DEP_GUARD]
evidence_labels: [observed, derived, inferred]
plan: "docs/coord_swarm_2026-11-25/reports/SEASON_PLAN_01.md:193 (SP-8 row), :159-174 (§4.3), :202-217 (B1..B10)"
matrix: "docs/coord_swarm_2026-11-25/TEST_MATRIX.md:11-12,29-46,53-75"
verdict: "NOT RUN — expected PENDING_DEP on the current tree; no PASS claimed; no donor parity claim"
---

# SP-08 — season-overlay atom (authoring report)

## 1. Goal

Author **one** new `extends SceneTree` atom that runs three season variants —
**default/summer**, **winter** and **desert** — over the *same* 64² fixture dump,
the *same* stub game/tileblock and the *same* `camera3d.gd` instance, and asserts:

1. `UV2.x` stays integral and inside the resolved manifest's index range for
   every built variant;
2. indices are **preserved** — Summer and Winter `UV2.x` are element-for-element
   identical (texture-only swap), and Desert `UV2.x` equals the SP-3 remap of the
   Summer value at every cell (name remap, not a palette swap);
3. the atlas manifest resolves for each built variant and `stats` reports the
   season's expected manifest path;
4. no internal script error path fired; the external stderr scan stays
   explicitly pending (GDScript cannot read its own stderr);
5. one windowed `SubViewport` PNG per built variant to a user-arg path —
   headless produces `SKIP_CAPTURE`, never a fake PASS;
6. result at `res://tests/results/t_season_overlay.json`, `call_deferred("quit")`.

This is an **authoring hand-off only**. No Godot process was launched and no
assertion was weakened.

---

## 2. Sources (all read-only this pass)

| Source | Used for |
|---|---|
| `SEASON_PLAN_01.md:178-195` | SP-8 ticket row: 64² dump-driven overlay, assertions, "do not edit `_smallmap_harness.gd` — dump-driven design avoids needing `winter_tile_names`", gate SP-6/SP-7/TEST-HARNESS |
| `SEASON_PLAN_01.md:159-174` (§4.3) | derived port mapping: keep tileblock indices unchanged; Winter selects manifest + atlas by BIOME; Desert applies the name remap **before** UV2 assignment; switch texture, never accumulate atlases; no shader edit |
| `SEASON_PLAN_01.md:202-217` (B1..B10) | winter art present-but-unpacked; atlas memory; no donor GPU A/B; TRN-DATA/DALPHA co-ownership; **B9** flat `TERRAIN_TINT` is legacy art, not the donor swap; **B10** never weaken a test |
| `SEASON_PLAN_01.md:220-238,241-263` | PORT APPROX label set and Q1..Q8 (donor-unaliased winter cells, remap height gates, enum value 1 UNVERIFIED) |
| `docs/coord_swarm_2026-11-25/reports/TEST_01_smallmap_harness.md:183-226,228-255,269-305` | ladder/capture path, shared stub API, windowed readback, headless guard, FIFO + `_initialize()` quit trap, class-name cache rule |
| `docs/coord_swarm_2026-11-25/reports/TEST_P0_report.md:74-107,109-141,142-174,176-193,219-237` | exact assertion/citation style, `check()` with JSON null, harness consumption + embedded fallback, SKIP_CAPTURE never PASS, no-runner declaration |
| `docs/coord_swarm_2026-11-25/TEST_MATRIX.md:11-12,29-46,53-75` | same-map rule; V3D_02 refinement (4,096 verts / 7,938 tris / 4,096 UV2 / atlas (16,8) / shadow OFF); sequential protocol; "never weaken an assertion"; no donor parity until F0 |
| `variant3d/tests/_template_test.gd:1-38` | one feature / one verdict / result JSON / deferred quit |
| `variant3d/tests/t_terrain_only.gd:42-86,170-239,250-304,394-420,623-669` | `extends SceneTree` skeleton, null-status `check()`, PNG metrics mirror, `SubViewport` readback, failsafe |
| `variant3d/tests/fixtures/_smallmap_harness.gd:11-24,106-128` | `StubGame` shape and `make_stub_game(w,h,height,res_nodes,tileblock) -> Object`, whose `dump` mirrors `main.gd:737-741` |
| `variant3d/tests/fixtures/small_map_64.json:10-15` | fixture map size `64×64`, seed `20261113`, `render_mode=3d` |
| `variant3d/scripts/world3d_terrain.gd:252,461-491,1028-1065,1107-1194,1310-1401` | `V785_MANIFEST_PATH`, `_load_atlas()`, dump decode, `UV2.x = tile id`, `UV2.y` face mode, stats `atlas`/`atlas_path` shape |
| `variant3d/scripts/tile_atlas_loader.gd:66-86,99-118,310-317,389-405` | **SP-5 landed**: `manifest_path` config key + overridable var, default `V785_MANIFEST` |
| `variant3d/scripts/data.gd:199,219-225,227` | `BIOME` static var, legacy flat `TERRAIN_TINT`, **SP-1 landed** `SEASON_ENUM` |
| `variant3d/scripts/config.gd:82,430` | `"season": "summer"` default → `Data.BIOME` |
| `variant3d/tools/smallmap_capture.py:21-39,50-58` (READ-ONLY) | PNG metric definitions mirrored in GDScript; external stderr `SCRIPT ERROR` scan |
| `docs/coord_swarm_2026-11-25/reports/SP_02_winter_dictionary.md:10,80-103` + `variant3d/assets/terrain/atlas/winter_aliases.json:1-60` | **SP-2 landed concurrently**: file is `atlas/winter_aliases.json`, schema `{entries:[{index,name,winter_alias,source_png,kind,status,shared_alpha,…}]}`, 124 entries, no `presets_winter.json`; 23 winter + 12 desert reused PNGs on disk |
| `docs/coord_swarm_2026-11-25/reports/SP_03_desert_remap.md:9,58-103` + `variant3d/assets/terrain/atlas/desert_remap.json:53-78` | **SP-3 landed concurrently**: file is `atlas/desert_remap.json`, schema `{remap:{name:{source_index,atlas_index,target,…}}, height_gated:[…]}` — 11 direct + 1 height-gated (data only) |
| `docs/coord_swarm_2026-11-25/reports/ATLAS_01_transport.md:48-90` (landed; read this pass) | current transport: single 179,912,941 B PNG + matching split parts; 27 `winterN.png` intentionally unpacked, desert1..12 packed at 111–122; no winter atlas on disk |

---

## 3. What was authored

`variant3d/tests/t_season_overlay.gd` — a single self-exiting atom. Structure:

1. **Fixture-driven, dump-driven**: reads `small_map_64.json` (or a `--config`
   override) for width/height/seed, parses the 124-name `presets_summer.json`,
   and builds a deterministic 64² `tileblock` that spans the full index space.
   Heights are mild (axis delta ≪ `cDiff1=0.5`, `world3d_terrain.gd:161`), so
   `face = 0` and `shore_gate = false` at `world3d_terrain.gd:1126-1128` and
   `UV2.x` is exactly the dump tile id — an index-preservation check with no
   face/shore confounder. The harness's `dump` is what the module decodes
   (`world3d_terrain.gd:1028-1065`); **the harness file is not edited** and
   `winter_tile_names` is never required (SP-8 row).
2. **Three variants, one camera, one tileblock**: descriptors for `summer`,
   `winter`, `desert` are built up front with their expected manifest path and
   user-arg PNG path. A fresh `world3d_terrain.gd` instance is built, captured
   and freed per variant; the one `camera3d.gd` instance is bound once with
   `_process()` disabled (fixed frame, `camera3d.gd:484-581`). `C3Data.BIOME` is
   set per variant (`data.gd:199`) and restored to `summer` in `_finalize()`.
3. **Dependency gate**: `FileAccess.file_exists` plus source-text probes decide
   `READY` / `PENDING_DEP` per variant **before** any build. No file → no build,
   no PNG, and JSON checks carrying `status: "PENDING_DEP"`, `passed: null`.
4. **Windowed capture only**: root 1280×720, private `SubViewport` with its own
   `World3D`, `UPDATE_ONCE`, `await RenderingServer.frame_post_draw`,
   `get_texture().get_image()`, `save_png(<user-arg path>)`, non-blank guard with
   **no CPU fallback** (`main.gd:1846-1853`). Headless skips the viewport and
   every capture; verdict can never be PASS on that path.
5. **Result** at `res://tests/results/t_season_overlay.json`; all exits are
   `call_deferred("quit", …)`, never a direct quit from `_initialize()`. A
   failsafe inert after setup guards an aborted run.

---

## 4. Assertions (name → assertion → citation)

| Check (`<id>` = `summer` / `winter` / `desert`) | Assertion | Citation / basis |
|---|---|---|
| `summer_dictionary` | `presets_summer.json` parses to a non-empty array; entry count recorded | manifest `index_dictionary` (`tile_index_atlas.manifest.json:41-45`); SP-2 acceptance "124 entries in Summer index order" (`SEASON_PLAN_01.md:187`) |
| `harness_stub_shape` | helper exposes `MAP_W/MAP_H`, `height: PackedFloat32Array`, `tileblock: PackedByteArray`, `res_nodes: Array` | `_smallmap_harness.gd:11-24,118-128`; `TEST_01.md:230-239` |
| `sp5_manifest_override_api` | `TileAtlasLoader.new("single", {"manifest_path": …, "single_atlas_path": …})` exposes both overrides | `tile_atlas_loader.gd:77,86,99-118,313,405` — **PRESENT**, exercised without winter assets |
| `terrain_camera_scripts` | both module scripts load and instantiate | `t_terrain3d.gd:12-13`; TEST-01 Blocker 10 (no `class_name` reliance) |
| `<id>_dependency_state` | `PASS` when all required files/hooks present; `null/PENDING_DEP` when absent; `false` for a missing mandatory Summer baseline | `SEASON_PLAN_01.md:187-193`; `TEST_MATRIX.md:60-61,67-68` ("a failing row is evidence… never weaken") |
| `<id>_build_ok` | `world3d_terrain.build()` returns `true` | `world3d_terrain.gd:1025-1065`; `t_terrain3d.gd:197-204` |
| `<id>_manifest_resolves` | variant manifest parses to a Dictionary with `atlas.named_cells > 0` and non-empty `layout` | `tile_index_atlas.manifest.json:13-47`; `world3d_terrain.gd:468,1072-1080` |
| `<id>_manifest_grid` | manifest `atlas.grid == [16,8]` | V7-85 manifest `:23-26`; SP-4 keeps 16×8 (`SEASON_PLAN_01.md:189`); `TEST_MATRIX.md:34` |
| `<id>_atlas_selection` | `stats.atlas_path` / `stats.atlas.manifest` contains the variant's expected manifest path | `world3d_terrain.gd:1313-1314,1389-1397`; SP-8 acceptance "assert selected manifest/atlas path + `stats['atlas_mode']`" (`SEASON_PLAN_01.md:193`) |
| `<id>_uv2_entry_count` | exactly one surface and `UV2.size() == w*h` (4,096 at 64²) | `TEST_01.md:151`; `world3d_terrain.gd:1093-1107` |
| `<id>_uv2_x_in_range` | every `UV2.x` integral, `0 ≤ x ≤ named_cells−1`; out-of-range count must be **0** | V7-86 shader contract `world3d_terrain.gd:1117-1126,1194`; `TEST_MATRIX.md:34` (`UV2.x ∈ [0,85]` measured on the 64² fixture); `DALPHA-02` index-preserving shader rule (`SEASON_PLAN_01.md:211` B4) |
| `winter_dict_124_entries` | `atlas/winter_aliases.json.entries` has exactly 124 records | `SP_02_winter_dictionary.md:80-103`; `SEASON_PLAN_01.md:187` (124 names, no invented index) |
| `winter_entries_index_and_names` | indices 0–123 contiguous, `name` sequence equals `presets_summer.json`, `winter_alias == name + "_winter"` for every entry | `winter_aliases.json:18-47`; `texturemap.inc:525-526,605-606` via SP-02 §3; `winterN` suffix is a filename, not an index (SP-02 §7) |
| `winter_names_resolve` | every SP-2 `source_png` exists on disk (23 `winterN.png` + 12 reused `desertN.png`); 4 donor-unaliased PNGs stay unmapped, never invented | `SP_02_winter_dictionary.md:239-288`; `SEASON_PLAN_01.md:68-77,206` B1/Q1 |
| `desert_remap_parsed` | `atlas/desert_remap.json` has **11** direct `remap` records and **1** `height_gated` record | `desert_remap.json:53-78`; `SP_03_desert_remap.md:58-103` |
| `desert_remap_targets_resolve` | every SP-3 source/target index matches `presets_summer.json` **and** the packed manifest layout; height-gated record is resolved but labelled `DATA_ONLY_NOT_EXECUTED` (excluded from the UV2 expectation) | `SP_03_desert_remap.md:116-135`; `SEASON_PLAN_01.md:188,231-232` |
| `tileblock_index_preserved` | stub `tileblock` is byte-identical after all three builds | `SEASON_PLAN_01.md:164,191` ("tileblock indices unchanged; Summer dumps byte-identical") |
| `uv2_x_summer_winter_identical` | Summer and Winter `UV2.x` arrays equal element-for-element | `SEASON_PLAN_01.md:161-166` (1:1 rename at same preset index), `:211` B4 (shader index-preserving) |
| `uv2_x_desert_remap_consistent` | every Desert `UV2.x` equals SP-3's **11 direct** index remap of the Summer value at that cell; mismatches = 0. The height-gated row is data-only, so a `rock8` cell is expected to keep its Summer index | `SEASON_PLAN_01.md:149,168-170`; `SP_03_desert_remap.md:79-85,153-154` (SP-6 index-only, no height gating) |
| `no_script_errors_internal` | no internal error path (load/build/parse/abort) fired | `TEST_P0_report.md:160-163`; cannot be a full stderr claim in GDScript |
| `script_error_scan_external` | `null` / `PENDING_EXTERNAL_SCAN` — operator must run `smallmap_capture.py scan-stderr` on the runner `stderr.txt` | `TEST_01.md:92`, `TEST_P0_report.md:89,160-163`; never faked as PASS |
| `<id>_capture_image` | `SubViewport` texture non-blank; no CPU fallback | `main.gd:1815-1853`; `V770_viewport_capture.md:29-35` |
| `<id>_capture_saved` | `save_png(<user-arg path>) == OK` | `TEST_01.md:192-197`; `t_smallmap_terrain.gd:93-99` |
| `<id>_non_black_fraction` | `> 0.9`, pixel any RGB channel `> 8` | `smallmap_capture.py:26`; `V3D_02` T0 (`:134-153`) |
| `<id>_full_width_dark_rows` | `== 0`, row dark when `>90 %` of pixels luma `< 20` | `smallmap_capture.py:27-28`; `V3D_02` F6/T0 |

The two PNG metrics are evaluated **only** in the windowed path; structural
checks run in headless mode too. The result JSON carries `id`, `passed`,
`verdict`, per-check `status` (`PASS` / `FAIL` / `PENDING_DEP` /
`PENDING_EXTERNAL_SCAN` / `SKIPPED`), `passes`/`fails`/`skipped_or_pending`,
per-variant summary (status, missing deps, manifest, PNG path, capture status,
`atlas_mode`, UV2 out-of-range count), the full `measured` dictionary,
`script_error_note`, `skip_reason` and `parity_label`.

**Verdict rule (no fake PASS):** any evaluated `false` → `FAIL`; else any
`PENDING_DEP` variant → `PENDING_DEP`; else headless → `SKIP_CAPTURE`; else all
three built and all three PNGs `PASS` → `PASS`. `passed` is true **only** for
`PASS`. Exit code is 0 when no evaluated check failed — matching the P0
precedent (`TEST_P0_report.md:236-239`); the JSON verdict, not the exit code,
is the authoritative gate result.

---

## 5. Dependency handling (observed this pass)

| Ticket | File / hook | State on disk | Atom behaviour |
|---|---|---|---|
| SP-1 | `data.gd:227` `SEASON_ENUM` | **present** | `C3Data.BIOME` used as the season selector; enum not re-declared |
| SP-2 | `assets/terrain/atlas/winter_aliases.json` (NOT the planned `structs/presets_winter.json`) | **present** (124 `entries`, 23 winter + 12 desert-reuse PNG targets) | Consumed directly by `winter_entries_index_and_names` / `winter_names_resolve`; does **not** by itself unblock Winter |
| SP-3 | `assets/terrain/atlas/desert_remap.json` (NOT the planned `structs/desert_remap.json`; see `SP_03` O1) | **present** (11 direct + 1 height-gated records) | Consumed by `desert_remap_parsed` / `desert_remap_targets_resolve`; does **not** by itself unblock Desert |
| SP-4 | `assets/terrain/atlas/tile_index_winter_atlas.manifest.json` + `.png` | **absent** | Winter → `PENDING_DEP` (27 `winterN.png` source blocks are present, `blocks/winter0..26`; only the packed atlas is missing — `ATLAS_01_transport.md:66`) |
| SP-5 | `tile_atlas_loader.gd:77,86,99-118,313,405` `manifest_path` | **present** | Exercised directly by `sp5_manifest_override_api` with the Summer path; no winter asset needed |
| SP-6 | render hook in `world3d_terrain.gd` (BIOME → manifest/atlas table, desert remap before UV2) | **absent** (no `BIOME` / `desert_remap` in that file) | Winter and Desert → `PENDING_DEP`; the atom asserts the hook via `stats` atlas path and UV2 behaviour once landed |
| SP-7 | prop `w` | not probed (out of scope for a terrain-overlay atom) | no prop assertions |

Detection uses `FileAccess.file_exists` for files and a text probe for code
hooks, exactly as the task directs. A missing dependency produces **no build,
no PNG, no fake PASS**: the relevant checks are recorded as `PENDING_DEP` with
`passed: null`, and the overall verdict becomes `PENDING_DEP` with
`passed: false`. The data-only tickets SP-2/SP-3 landed at `atlas/` paths with
concrete schemas — the atom was aligned to those bytes, not to the proposed
plan paths. Once SP-4/SP-6 land, the same atom runs all three variants without
edits; if a required file exists but the schema differs from the recorded
shape, that is a **FAIL** (integration defect), not a silent downgrade.

---

## 6. Expected pre-implementation state (NOT observed)

Predicted on the current tree, derived from the facts in §5 — **not a run
result**:

- **Summer**: expected to build — 1 surface / 4,096 verts / 7,938 tris /
  4,096 `UV2` / `UV2.x` equal to the deterministic tileblock ids inside
  `[0,123]` / atlas mode `single` / V785 manifest resolves / stats path is the
  V785 manifest. This mirrors the measured 64² baseline (`TEST_01.md:148-154`,
  `TEST_MATRIX.md:33-35`). **Expected, not run — do not report as a pass.**
- **Winter**: expected `PENDING_DEP` — SP-2 data is present, but the SP-4
  winter manifest/PNG and the SP-6 selection hook are absent. No winter PNG
  captured.
- **Desert**: expected `PENDING_DEP` — SP-3 data is present, but the SP-6
  remap hook is absent. No desert PNG captured.
- **Headless run**: expected verdict `SKIP_CAPTURE`, `passed: false`, Summer
  structural checks still evaluated. Never a PASS.
- **Windowed run**: expected verdict `PENDING_DEP`, only the Summer PNG written
  (assuming `--summer-png` is supplied); the `script_error_scan_external` row
  stays `PENDING_EXTERNAL_SCAN` until the operator scans stderr.
- **If a later run fails a Summer structural check**, that is evidence against
  the current port code — not a reason to weaken the predicate
  (`TEST_MATRIX.md:60-61,67-68`; `SEASON_PLAN_01.md:216` B10).
- **No donor A/B frame exists** at 64² (`TEST_MATRIX.md:46`), so no structural
  or pixel metric here can establish donor visual parity (B3).

---

## 7. PORT APPROXIMATION / UNVERIFIED carried forward

1. Atlas packing 16×8 / V7-85 order is `APPROX_ATLAS_PACKING`; donor
   `tsDouble`/`ttExtended` is engine-side (`SEASON_PLAN_01.md:224-225`).
2. `UV2.x = tile id`, `UV2.y` face mode, 25° face tilt and eye-plane texgen are
   port contracts / PORT APPROX, not donor literals (`:226-229`).
3. Flat `TERRAIN_TINT` is legacy art, **not** the donor swap — this atom never
   judges a season by colour (`:215` B9).
4. Desert height `koef=0.8`, mine suffix `s`, `rock8` height gate are
   text-observed but runtime UNVERIFIED; SP-3 stores them as labelled data and
   this atom does not execute them (`:231-232`).
5. Winter `winter18/23/24/26` are donor-unaliased and `winter25` is green
   grass; the atom requires resolution, never invents replacements (Q1 / B1).
6. Donor swap-script runtime activity is UNVERIFIED (B6); the atom implements
   the derived intent, not a "donor runs this" claim.
7. PNG non-black/dark-row metrics are internal consistency only; no donor
   reference frame and no second-agent visual re-check occurred here.

---

## 8. Open questions

1. **SP-2 schema (resolved, but watch drift)**: the atom reads the landed
   `entries[]` structure with contiguous indices and `name + "_winter"` aliases
   (`SP_02` §4/§8). If SP-2 revises the schema, the atom FAILS rather than
   silently skipping — by design. `alpha0a/b/c` are flagged `shared_alpha` and
   remain donor alias carriers only, never fabricated atlas cells (SP-02 Q3).
2. **SP-3 schema (resolved, but watch drift)**: the atom reads the landed
   `remap` (11 direct) + `height_gated` (1) records and asserts exact counts.
   The `rock8` height gate, `koef=0.8`, mine `s` and env destruction stay
   `DATA_ONLY_NOT_EXECUTED`; if a future SP-6 *does* apply the gate, the UV2
   consistency expectation must be extended by the owning ticket.
3. **SP-6 activation and data path**: whether the renderer hook reads
   `C3Data.BIOME` directly or another selector, and whether it reads SP-2/SP-3
   from `atlas/` (where they landed) or the `structs/` paths in the plan. The
   atom sets `C3Data.BIOME` and verifies the *effect* through `stats` + UV2;
   path drift would be an integration FAIL, not an excuse to weaken a check.
4. **Desert index-preservation interpretation**: "index-preserving" is read
   as (a) tileblock bytes unchanged, (b) Summer/Winter UV2 identical, (c)
   Desert UV2 a strict 1:1 function of Summer UV2 via SP-3. If COORD intends
   literal element equality across all three variants, that would contradict
   the donor remap (`miscext.script:1447-1502`) and needs a decision.
5. **Runtime cost**: three sequential builds each load a ~180 MB atlas PNG
   (512 MiB raw RGBA8 per atlas, `SEASON_PLAN_01.md:82,208`). Whether a single
   runner job can fit the timeout, and whether Winter and Summer atlases must
   be unloaded between variants (B2), is unverified until a runner owner runs
   it. The atom frees each terrain before the next build but does not force a
   texture cache flush.
6. **Second-agent capture re-check** and donor reference frames remain the
   matrix owner's responsibility (`TEST_MATRIX.md:58-59,75`, F0 blocked).
7. **Registration** is intentionally absent: `manifest.json` / `test_all.py`
   changes are a separate integration ticket (`TEST_01.md:257-267`). Launch by
   hand through the serialized runner until then.

---

## 9. No-runner declaration

No Godot process was launched; no `godot_runner.py` ticket was requested; no
queue lock was touched; no capture PNG or `t_season_overlay.json` was produced;
no donor file was read, executed or copied; no source, shader, asset, config,
manifest, fixture, gate file or git state was edited. Only
`variant3d/tests/t_season_overlay.gd` and this report were written.

Proposed (**NOT executed**) launch form for a future owner — windowed, through
the serialized runner, Windows `python` (never `python3`), user args after the
second `--` (`TEST_01.md:188,192-197`):

```
python variant3d\tools\godot_runner.py run --id SP-8-season --timeout 180 -- \
  --path variant3d --script res://tests/t_season_overlay.gd -- \
  --summer-png C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/test01_smallmap/season_summer.png \
  --winter-png C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/test01_smallmap/season_winter.png \
  --desert-png C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/test01_smallmap/season_desert.png
```

Then, externally and read-only:
`python variant3d\tools\smallmap_capture.py stats <png>` for each captured PNG
and `python variant3d\tools\smallmap_capture.py scan-stderr <stderr.txt>`
(`SCRIPT ERROR == 0`). A headless variant of the same command produces
`SKIP_CAPTURE`, never PASS.

---

*End of SP-08. Authoring only: no Godot run, no runner job, no donor access, no
test weakened, no PASS claim, no donor visual-parity claim.*
