---
id: A06-INTEGRATION
ticket: TERRAIN-SWARM-2026-11-26 / Wave A / A06 (integration + rollback plan, DESIGN ONLY)
date: 2026-11-26
status: DELIVERED__DESIGN_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB__NO_GODOT__NO_DONOR_ACCESS
owner_file: docs/terrain_swarm_2026-11-26/reports/A06_integration.md
files_created: [docs/terrain_swarm_2026-11-26/reports/A06_integration.md]
files_edited: []
labels: [observed, derived, inferred, UNVERIFIED, PORT APPROXIMATION]
parity_guard: "No Godot run, no capture, no donor frame and no gate was produced by A06. Donor visual parity stays UNVERIFIED (CHARTER.md:43-44, :125). This report designs a switch whose DEFAULT IS LEGACY; any later 'donor looks better' statement would need a real matched-seed captured A/B owned by COORD/G04."
scope_guard: "Read-only analysis. No script, shader, config, asset, test, project.godot, git or app/ file was edited. Implementation is for future COORD-assigned workers; this report only allocates file ownership and gives exact commands."
---

# A06 — integration + rollback plan for a donor-faithful terrain module in `variant3d/`

## Executive summary

1. **[O] The seam already exists in shape but not in key.** `main.gd` has an additive renderer
   switch (`render_mode`, `main.gd:120-124`, read at `:185-186`) and a single world factory
   (`make_world3d()`, `main.gd:1037-1045`, called at `:586-589` and `:1103-1106`). `world3d.gd`
   already composes six modules behind dynamic `load()` with one constant per script
   (`world3d.gd:108-116`) and one instance var per module (`world3d.gd:133-139`), instantiated in
   `_instantiate()` (`world3d.gd:213-226`) and wired in `bind()` (`world3d.gd:604-692`).
   **Design:** add a *second, independent* switch `terrain_backend` with default `"legacy"`;
   it selects only *which terrain script* `world3d.gd` loads. No other module's construction,
   no camera/HUD/input seam and no `app/` byte changes.
2. **[O] The config seam needs no new config.gd edit to work.** `C3Config.text()` is generic
   (`config.gd:406`), so `main.gd` can read `cfg.text("features.terrain.backend", "legacy")`
   exactly as it reads `gameplay.render_mode` (`main.gd:185`). The `features.terrain` table
   already exists (`config.gd:54-63`). An optional typed accessor `feature_terrain_backend()`
   following `config.gd:441-442` is *deferred to the config owner* — not required for stage 2.
3. **[D] The new module can be fed by the EXISTING dump contract with zero producer changes.**
   `world3d_terrain.gd:_dump_from_game()` (`world3d_terrain.gd:926-963`) already synthesises
   `{map_w, map_h, height (base64 f32), tileblock (base64 u8)}` from the live `game`, and
   `main.gd:_dump_map()` already writes the same keys (`main.gd:791-798`). The new module must
   be a *read-only consumer* of these keys plus live `game` fields; it must never write
   `height[]`, `blocked[]`, `tileblock`, RNG state or `pattern_stamps` (same guard as Z08,
   `world3d_relief.gd:3-8`).
4. **[O] The hard invariants are already asserted on disk.** `t_render_mode.gd:34-42,79-100`
   pins the declared 2D default and the legacy constructors; `t_terrain_only.gd:522-556,598-616`
   pins `1 / w*h / (w-1)(h-1)*2 / w*h` mesh+UV2 counts, face modes, `flat_grid_promoted == 0`,
   `atlas_grid == [16,8]` and `shadow_enabled == 0`; the atlas manifest pins `named_cells=124`
   over a 16×8 grid (`tile_index_atlas.manifest.json:13-45`). These are the acceptance floor
   for **both** backends; only the legacy backend must be byte-identical.
5. **[O] Rollback must copy from `inbox/backup/*.bak-<TICKET>` over the working tree — never
   `git reset --hard` / `git checkout .` / `git clean`.** At this read `git status` shows
   uncommitted foreign edits in `game.gd` (Y08b), `project.godot` (Y11) and
   `terrain_tileindex.gdshader` (Y10), with backups `.bak-Y10` / `.bak-Y11`. A blanket git
   restore would silently destroy them (§7). `[D]` All A06 commands below are therefore
   file-scoped `Copy-Item` operations with recorded SHA-256.

---

## 1. Evidence table

| ID | Label | Evidence | What it fixes in this design |
|---|---|---|---|
| E01 | [O] | `docs/terrain_swarm_2026-11-26/CHARTER.md:26-30,57-61,64,83-84` | Work only in `variant3d/`; fresh module composed by `world3d.gd`, legacy retained behind a switch; gates 29/29 + 17/17 + `t_render_mode` + CLEAN + `app/` byte-identical; no invention |
| E02 | [O] | `SWARM_BOARD.md:37,39-45` | A06 owns only `reports/A06_integration.md`; COORD alone integrates |
| E03 | [O] | `main.gd:120-124,185-186,586-589,1037-1045,1103-1106` | Where `terrain_backend` is declared/read/propagated; two world-construction sites, both need the switch set **before** `world.bind(game)` |
| E04 | [O] | `world3d.gd:108-116,133-139,213-226,604-650,674-692,739-751` | Module-constant/instance/bind/stats/test-hook seam; relief depends on terrain's `height_at_world` |
| E05 | [O] | `config.gd:42-86,54-63,398-416,441-442` | `features.terrain` table exists; generic `text()`/`flag()` accessors; accessor pattern to copy later |
| E06 | [O] | `world3d_terrain.gd:926-963,969-995,1084-1106,1219-1233,1461-1464` | Dump contract, tileblock decode, single water-plane binding, build body — the module API the new module must mirror |
| E07 | [O] | `main.gd:791-803` (`dump` keys + `relief_stamps` flag) and `:799-801` ("byte-identical" note) | Producer extensions must be flag-gated and default-off; stage 2 requires none |
| E08 | [O] | `t_render_mode.gd:34-42,79-100,118-126`; `variant3d/selftest.json` 29 step names; `variant3d/uitest.json` 17 step names | Exact gate expectations that the switch must not perturb |
| E09 | [O] | `t_terrain_only.gd:522-556,598-616`; `tile_index_atlas.manifest.json:13-45`; P16 §4 `:304-323` | Mesh/UV2/atlas/water/shadow invariants; tileblock bytes read-only |
| E10 | [O] | `TRN_GEOM_implementation.md:22-32,85-89,120-125`; `TRN_DATA_implementation.md:18-28,66-70,79`; `TRN_WATER_implementation.md:46-69`; `TRN_SHADER_implementation.md:45-55,118-130` | Landed baseline that the new module must not re-patch: face gates, tile diversity, water literals, shader texgen |
| E11 | [O] | `STATUS_WAVE7_PHASE2.md:17-63` | Current green gates (jobs 254/255/256) and the standing UNVERIFIED qualifications |
| E12 | [O] | `git status --short` at read: `M variant3d/scripts/game.gd`, `M variant3d/project.godot`, `M variant3d/shaders/terrain_tileindex.gdshader`; `?? inbox/backup/project.godot.bak-Y11`, `.bak-Y10`; `git rev-parse --short HEAD` = `0e9783f2` | Live conflict set; `HEAD` ≠ working tree for three files, so backups must copy the working tree |
| E13 | [O] | `Y08_checkerboard.md:1-29`; `Y10_anisotropic.md:20-23,42-48`; `Y11_aniso_level.md:15-17,38-48` | Ownership of the in-flight edits and their exact backup tickets |
| E14 | [O] | `P16_terrain_geometry.md:31-35,375-399`; `world3d_relief.gd:3-8,86-92` | Prior backup/rollback recipe and the read-only-sim discipline to reuse |
| E15 | [D] | E04 + E06 + E10 | A sibling module can be dropped into `world3d.gd` without editing `world3d_terrain.gd` at all; that is what makes rollback a one-line script-path change |
| E16 | [U] | No donor GPU A/B, no capture, no runner job by A06 | Any visual acceptance for stage 3 is a future COORD/G04 measurement, not a claim here |

---

## 2. Design

### 2.1 The switch (exact seam, default legacy)

**[O] Current state.** `render_mode` is declared `var render_mode := "2d"` (`main.gd:124`),
with the explicit warning "do not put the literal 3d value on this line; t_render_mode.gd checks
that the declared default is unambiguously 2D" (`main.gd:120-124`). It is read from
`cfg.text("gameplay.render_mode", "2d")` (`main.gd:185`) and gates the 3D construction at
`:586-589` and `:1103-1106`. `world3d.gd` has no terrain-specific switch: it always loads
`TERRAIN_SCRIPT := "res://scripts/world3d_terrain.gd"` (`world3d.gd:108`) in `bind()`
(`:609`, called by `:643-645`).

**[D] Proposed seam — four edits, all COORD-owned, all default-inert:**

1. **`main.gd` (COORD)** — declare a new, separate variable next to `render_mode`, e.g.
   `var terrain_backend := "legacy"`. **Constraint [O]:** do not alter the `render_mode`
   declaration line or any regex target in `t_render_mode.gd:35-42` — a new independent line
   is invisible to those patterns. Then, immediately after `main.gd:185-186`, read
   `terrain_backend = str(cfg.text("features.terrain.backend", "legacy")).to_lower()`.
   Normalise unknown values to `"legacy"` so a typo can never silently become donor.
2. **`main.gd` (COORD)** — at **both** construction sites (`main.gd:586-589` and
   `:1103-1106`), insert `world.set_terrain_backend(terrain_backend)` between
   `make_world3d()` and `world.bind(game)`. **[D] Both sites are required**: the selftest path
   (`:1103`) and the normal skirmish path (`:586`) are separate; patching only one leaves a
   hidden inconsistent backend. Guard the call with `has_method()` so an older test double
   `world.gd` still binds (same null-safe idiom as `main.gd:789-790`).
3. **`world3d.gd` (COORD)** — add
   `const TERRAIN_DONOR_SCRIPT := "res://scripts/terrain_donor_world.gd"` beside `:108-116`
   and `var terrain_backend := "legacy"` beside `:133-139`. Add
   `func set_terrain_backend(mode: String) -> void` that accepts only `"legacy"`/`"donor"`
   (else `"legacy"`), stores the value, and **refuses to switch after `bind()` has run**
   (`push_error` + keep current module) — a mid-game swap would orphan the water plane and
   relief MultiMeshes (`world3d.gd:646-650`, `world3d_terrain.gd:1461-1464`). In `bind()`
   replace the fixed `terrain = _instantiate(TERRAIN_SCRIPT)` at `:609` with
   `terrain = _instantiate(TERRAIN_DONOR_SCRIPT if terrain_backend == "donor" else TERRAIN_SCRIPT)`.
   Everything else at `:641-692` stays: `terrain.bind(game)` → `terrain.build()` gated by
   `_has_height_source()` (`:231-238`, `:644-645`) → `relief.bind(game, terrain)` (`:649-650`).
4. **`world3d.gd` stats (COORD)** — add `"terrain_backend": terrain_backend` and the chosen
   script path to the `stats` dict at `:674-692`. **[D]** This is the sole observability hook
   QA needs to prove which backend a capture/gate actually used; without it an A/B is
   unverifiable. Do not rename or remove existing stats keys (`t_*` atoms read them by string).
   **No `config.gd` edit is required**: the generic `text()` accessor at `config.gd:406`
   suffices. A typed `feature_terrain_backend()` (`config.gd:441-442` pattern) is a
   *separate deferred ticket* owned by the config owner, to avoid an ownership collision.

**[O] Why this is safe for `t_render_mode`:** the test asserts the *declared* 2D default,
the presence of `make_world3d`/`make_camera3d`, a render-mode branch, and the retained
legacy constructors (`t_render_mode.gd:79-100`). No assertion mentions a terrain key. The
new variable's default literal is `"legacy"`, not `"2d"`/`"3d"`, so none of `b1/b2/b3` at
`_default_is_2d()` (`t_render_mode.gd:39-42`) can match. **[D] Expected result stays
10/10 PASS, `seam_missing=false`** (status baseline job 256, `STATUS_WAVE7_PHASE2.md:61`).

**[D] Config override for A/B (no committed file):** pass a temporary JSON via the existing
`--config` flag (`main.gd:1338-1341`) containing
`{"features":{"terrain":{"backend":"donor"}}}`; `--dump-config` (`main.gd:1342-1344,197-199`)
will echo the merged key through `cfg.dump()`. Never commit that temp file.

### 2.2 New files, exact paths and ownership (parallel-implementation allocation)

**[D] One file per owner; A06 owns none of them.** All paths are relative to repo root.
The current charset/tabs convention follows `world3d.gd:6` ("TABS ONLY") and the dynamic-load
rule `world3d.gd:7-8` (**no `class_name`** on new `.gd` scripts — a fresh global class is not
in `.godot`'s cache until an editor import through the serialized runner).

| # | Exact path | Kind | Owner (future ticket) | Contract / boundary | Touches existing file? |
|---|---|---|---|---|---|
| N1 | `variant3d/scripts/terrain_donor_world.gd` | `Node3D` composer, **the only script `world3d.gd` loads** | T-MOD (COORD assigns) | Public API exactly `bind(game)`, `build() -> bool`, `invalidate()`, `has_chunk_or_fallback()`, `height_at_world(Vector2) -> float`, `stats`; composes N2–N5; builds ONE full-grid mesh; builds the single water node via N6 | No |
| N2 | `variant3d/scripts/terrain_donor_mask.gd` | `RefCounted`, pure data | T-MASK (A01/A02 spec owner) | mask decode → blur → smooth stage; input = dump dict + derived JSON; no Node, no rendering, no RNG draws on sim streams | No |
| N3 | `variant3d/scripts/terrain_donor_height.gd` | `RefCounted`, pure data | T-HEIGHT (D05 spec owner) | height field assembly / relief stamp / shore classification; writes only its own arrays | No |
| N4 | `variant3d/scripts/terrain_donor_tiles.gd` | `RefCounted`, pure data | T-TILES (D08/F05 spec owner) | tile id selection + atlas index mapping; **reads** `tile_atlas_loader.gd` and `tile_index_atlas.manifest.json` read-only; emits UV2 pairs | No |
| N5 | `variant3d/scripts/terrain_donor_props.gd` | `Node3D` sibling of Z08 | T-PROPS (A04 spec owner) | hills/mountains/fields/shore/forest/quarry/mines props from dump + `pattern_stamps`; read-only on sim (Z08 guard `world3d_relief.gd:3-8`); **does not replace** `world3d_relief.gd` | No |
| N6 | `variant3d/scripts/terrain_donor_water.gd` (or reuse `water3d.gd` **read-only**) | `Node3D` | T-WATER | Must reproduce `world3d_terrain.gd:1084-1106`: `build(w,h)` before `add_child`, `bind_height_grid(height,w,h)`, one plane renamed `WaterPlane`, node `Water3D`; if reuse, N1 calls the existing script, do not edit it | No |
| N7 | `variant3d/shaders/terrain_donor.gdshader` (**ONLY if** A03/A04 prove the existing shader cannot express the donor stage) | shader | T-SHADER | New file only; **must not edit** `terrain_tileindex.gdshader` (Y10's uncommitted one-line change, `Y10_anisotropic.md:20-23`); preserve sampler names/atlas grid/`shadow_enabled=0`/`mask_to_alpha` contract | No |
| N8 | `variant3d/tools/terrain_donor_compile.py` | Python decoder/compiler | T-TOOLS (A03/F01 spec owner) | donor `.pattern`/terrainmask/cfg bytes → derived JSON; donor read-only, no donor binary copied (CHARTER.md:26-30) | No |
| N9 | `variant3d/tools/terrain_donor_verify.py` | Python replay/compare | T-QA (A05 spec owner) | same-seed byte replay, histogram, dump-key check; read-only; feeds A05 harness | No |
| N10 | `variant3d/assets/terrain/donor_derived/*.json` (+ `manifest.json` with SHA + labels) | derived assets | T-TOOLS | labelled `[O]/[D]/[I]/[U]`/`PORT APPROXIMATION`; **no donor binaries**; distinct from `assets/terrain/atlas/**` so the atlas contract is untouched | No |
| N11 | `variant3d/tests/t_terrain_donor.gd` | atom | T-QA | tests new module + seam only; **appends** to `tests/manifest.json` LAST (owner V7-38 convention, `STATUS_WAVE7_PHASE2.md:176-177`); no existing assertion weakened | `tests/manifest.json` (append-only, separate owner) |
| N12 | `docs/terrain_swarm_2026-11-26/spec/**` | spec | COORD | written from cited A01–A05+D/F findings before N1–N6 are implemented (CHARTER.md:49-61) | No |

**[I] Ordering:** N12 → N8/N10/N9 → N2/N3/N4/N5 → N6/N7 → N1 → seam edits (§2.1) → N11.
This keeps the switch in COORD hands until every module exists and parses, so a partial
land can never flip a gate onto a half-built backend.

### 2.3 `game.gd` data flow / dump contract

**[O] Producer.** `game.gd` holds `terrain` (PackedByteArray), `blocked`, `height`
(PackedFloat32Array) and `tileblock` (PackedByteArray, `game.gd:53`, one uint8/cell per
`world3d_terrain.gd:110-116`). `main.gd:_dump_map()` serialises all four plus starts,
clusters, resources and meta (`main.gd:791-798`); the `relief_stamps` marker is added only when
`feature_terrain_relief_stamps` is true (`main.gd:784-803`, default false at `config.gd:62`).
**[O] Live consumer path.** `world3d_terrain.gd:_dump_from_game()`
(`world3d_terrain.gd:926-963`) accepts an explicit `dump`/`map_dump`/`self_base` dictionary
first (`:929-932`), otherwise synthesises `{map_w, map_h, height: base64(grid.to_byte_array()),
tileblock: base64(tileblock)}` (`:955-963`). `_decode_tile_indices()` accepts base64 **or**
a live `PackedByteArray` and falls back to `game.tileblock` (`:969-995`). `build()` decodes
`height` with `Marshalls.base64_to_raw` + `decode_float(i*4)` (`:1227-1243`).

**[D] Contract the new module must honour (stage 2 — no producer edit):**

| Key | Source | Type / encoding | New module use | Write? |
|---|---|---|---|---|
| `map_w`, `map_h` | `main.gd:792` / `world3d_terrain.gd:955-956` | `int` | grid dims; 240² default (`config.gd:120-121`) and 160²/320² fixtures (`P16:51-57`) | NO |
| `height` | `main.gd:795` / `world3d_terrain.gd:958` | base64 of little-endian float32, `w*h` values (metres, `HEIGHT_SCALE=1.0` at `world3d_terrain.gd:131`) | relief/mask/water input | NO |
| `tileblock` | `main.gd:796` / `world3d_terrain.gd:962` | base64 of uint8, `w*h`; `BLK_WATER=255` (`game.gd:52`) | tile id / atlas UV2.x input | NO |
| `dump`, `map_dump`, `self_base` | `world3d_terrain.gd:929-932` | `Dictionary` override | test doubles & saved dumps | NO |
| `relief_stamps` | `main.gd:802-803` | Array of `{name,cx,cy}` | opt-in stamp markers only | NO |
| live `game` fields | `game.gd`/`world3d.gd:334-338`, `world3d_relief.gd:120+` | `terrain`, `blocked`, `res_nodes`, `mine_mask`, `pattern_stamps`, `map_starts`, `cluster_zones`, `map_meta`, `get_selected()` | prop placement + read-only reconciliation | NO |

**[D] Rules:** (a) N1 reuses the same `_dump_from_game()` recipe verbatim (copy the *shape*,
not the file — no edit to `world3d_terrain.gd`); (b) an absent key must degrade to the existing
splat/fallback behaviour, never invent a value (CHARTER.md:83-84); (c) any *new* producer key
(e.g. mask channel arrays) must be added in `main.gd:_dump_map()` behind
`features.terrain.backend == "donor"` **and** default-off, because `main.gd:799-801` explicitly
requires the flag-off dump to stay byte-identical; (d) same seed ⇒ byte-identical replay, per
`t_map_variety.gd:69-89` (`TRN_DATA:68`); the correct reading of "byte-identical" is
*reproducible per seed*, not equal to pre-ticket bytes (`TRN_DATA:66-70`).

### 2.4 Staged rollout gates

**[D] Stage 0 — reports + spec (no code).** Gate: all 30 reports landed; COORD cross-checks
contradictions and writes `spec/` (`SWARM_BOARD.md:39-43`). No gates run by A06.

**[D] Stage 1 — tools + derived assets only (switch still legacy).** Land N8/N9/N10. Gate:
Python parse of donor bytes is reproducible; derived JSON carries SHA + labels; **no Godot
gate is claimed**; `git status --short -- app/` empty.

**[D] Stage 2 — module lands behind the switch, default legacy.** Land N2–N6 then N1 and the
four §2.1 seam edits. **Gate (all must pass, no assertion relaxed):**
`variant3d/selftest.json` `passed:true` 29/29; `variant3d/uitest.json` `passed:true` 17/17;
`t_render_mode` PASS 10/10 `seam_missing=false`; `t_terrain3d` 6/6; `t_terrain_only`,
`t_combo_all`, `t_combo_trees_shore`, `t_combo_trees_mines`, `t_season_overlay`,
`t_map_variety` green; `assert_clean CLEAN`; `--dump-config` shows `backend=legacy`;
`git status --short -- app/` empty. `[O]` Gate commands from `STATUS_WAVE7_PHASE2.md:243-259`
via `python variant3d\tools\godot_runner.py run --id <UNIQUE> ...` (README.md:129-153).

**[D] Stage 3 — opt-in A/B, still default legacy.** Run the same gates with a temp
`--config` override selecting `"donor"`; add N11. Gate: all functional gates still green;
two same-seed runs byte-identical (height/tileblock/UV2 dumps); structural invariants
§2.5 hold; exactly ONE water plane and no `SCRIPT ERROR`; matched-seed windowed capture
+ histogram read by a second agent. **[U] Visual parity is NOT a gate** until a real donor
GPU frame exists (CHARTER.md:43-44, :125).

**[D] Stage 4 — flip default (owner decision only).** Change
`features.terrain.backend` default to `"donor"` in `config.gd:54-63` **by the config owner**,
with a new `config.gd.bak-<TICKET>`, then re-run the full stage-2 gate list with the new
default and `t_render_mode` unchanged. Do not flip the default in the same commit as module
landing — that would make rollback ambiguous.

**[D] Stage 5 — retire legacy (separate ticket).** Only after owner sign-off: remove
`TERRAIN_SCRIPT` from `world3d.gd:108` and the legacy branch in `bind()`. Keep every `.bak`
file; never delete history to "clean up".

### 2.5 What must remain byte-identical / invariant

| Item | Requirement | Evidence | Applies to |
|---|---|---|---|
| 2D `app/**` | Zero edits; all 2D gates stay in `app/` (selftest 29/29 job 1342, uitest 17/17 job 1341, CLEAN 1340) | CHARTER.md:26-30; `STATUS_WAVE7_PHASE2.md:27,298`; README.md:46-55 | whole plan |
| selftest 29 step names/order | `move … nav_detour` exactly; no step added/renamed | `variant3d/selftest.json` steps; `STATUS_WAVE7_PHASE2.md:24` | whole plan |
| uitest 17 step names/order | `menu_shell … save_load_ui` exactly | `variant3d/uitest.json` steps; `STATUS_WAVE7_PHASE2.md:25` | whole plan |
| `t_render_mode` hard 2D default | declared `render_mode` default `"2d"`; legacy `C3WorldScript.new()` / `C3CameraScript.new()` and `world.bind(game)` / `camera.bind(world)` still present; 10/10, `seam_missing=false` | `t_render_mode.gd:34-42,79-100,118-126`; `main.gd:120-124,591-593,601-603` | whole plan |
| atlas contract | manifest `grid [16,8]`, `slots 128`, `named_cells 124`, `index_dictionary` = `presets_summer.json:2-125` (124 names); shader `atlas_grid == (16,8)`; no new atlas file, no reindex, no donor binaries | `tile_index_atlas.manifest.json:13-45`; `t_terrain_only.gd:598-609`; `world3d_terrain.gd:258-273,611-628` | both backends |
| water binding | ONE plane named `WaterPlane` (from `WaterPlane3D`), node `Water3D`, built before `add_child`, `bind_height_grid(height,w,h)`; fallback `_make_water` only if module fails; donor literals `water_level=-0.25`, `shore_height=-0.1`, `max_height=2.96`, `coast_fade_depth=0.57/1.07`, `water_surface_y=-0.25` PORT APPROX | `world3d_terrain.gd:1084-1106,1459-1464`; `TRN_WATER_implementation.md:46-61`; `config.gd:64-67` | both backends |
| UV2 / mesh invariants | `surface_count==1`, `vertex_count==w*h`, `triangle_count==(w-1)(h-1)*2`, `uv2_count==w*h`, UV2.x integral in `[0,123]`, UV2.y∈{0,1,2}, `face_hist_sum==w*h`, `flat_grid_promoted==0`, `tileblock` bytes never written, `shadow_enabled==0` | `t_terrain_only.gd:522-556`; P16 §4 `:304-323`; `TRN_GEOM:85-89` | both backends (structural); **byte-identical values only for legacy** |
| height/resource projection | `height_at_world` ~0.001 m; resource Y ~0.02 m; relief props consume it | `world3d.gd:646-650,748-751`; P16 §4 `:315` | both backends |
| face/rock/shore gates | `DONOR_FACE_TILT_DEG=25`, cliff gates `abs(h)>2.7→rock8` / `>2.4→rock4`, shore ids 93/97/98, `cDiff1=0.5/cDiff2=0.55` remain as landed (APPROX) | `TRN_GEOM:49-90`; P16 §2 `:104-114` | legacy byte-identical; donor may re-derive only with cited spec |
| gate governance | no assertion deleted, no threshold lowered, no synthetic noise/dither (S-25-09), no fake A/B | CHARTER.md:83-84; `TRN_DATA:24-28`; P16 §2 `:99-121` | whole plan |

**[D] Critical distinction:** for `backend=legacy`, outputs (mesh, UV2, stats keys, dump bytes)
must be **byte-identical to today's working tree** — that is what makes the switch a true
rollback. For `backend=donor`, only the **structural** invariants above are required; its tile
ids/heights may legitimately differ from legacy by design (the same tension TRN-DATA resolves
at `:66-70`). Any donor-side change to a boundary in the table needs a new owner-approved
contract, not a silent exception.

### 2.6 Conflict register — in-flight edits and how to avoid double-apply

| Conflict | Observed state [O] | Avoidance [D] |
|---|---|---|
| Y08b `game.gd` checkerboard fix | `git status`: `M variant3d/scripts/game.gd`; diff at `:390-399` nests the `tileblock[ci]=g0` write inside the radius test; `Y08_checkerboard.md:59-62` | **Never edit `game.gd`** in A06 or N1–N6; new module is read-only on sim. If a dump producer change is later required, append new flag-gated keys to `main.gd:791-803`, never restore `game.gd` from `HEAD`. Keep `.bak-TRNDATA` / current state intact. |
| Y10 shader | `M variant3d/shaders/terrain_tileindex.gdshader`, one-line `:60` sampler→`filter_linear_mipmap_anisotropic`, backup `.bak-Y10` (`Y10_anisotropic.md:20-23,42-48`) | N7 must be a **new** shader file; do not re-apply TRN-SHADER's or Y10's diff. If no new shader is needed, touch neither file. |
| Y11 project settings | `M variant3d/project.godot`, one line `textures/default_filters/anisotropic_filtering_level=4`, backup `.bak-Y11` (`Y11_aniso_level.md:15-17,38-48`) | A06 needs no project settings; do not copy `project.godot` from `HEAD` and do not "normalise" it during rollback. |
| Prior-wave patches already in `HEAD` | TRN-GEOM / TRN-SHADER / TRN-WATER / TRN-DATA files are clean in `git status` at `HEAD 0e9783f2` | Treat them as landed baseline; do not re-apply their diffs. N1 must *compose* the existing water shader/script, not duplicate its literals into a second implementation. |
| P16 build-time optimisation proposal | `P16_terrain_geometry.md:31-35` warns its diff was written against a tree where B04 was still uncommitted; §7 `:375-399` gives `.bak-P16` recipe | P16 was **never applied** by A06 and is out of scope. Do not `git apply` it onto today's tree; if COORD later assigns it, re-base on the working tree and take a fresh backup. A06 does not create `.bak-P16`. |
| Wave-7 integration follow-up (V7-3/4) | `STATUS_WAVE7_PHASE2.md:170,229-231` lists `main.gd/world3d.gd/config.gd` as a deferred integration batch | §2.1 *is* that batch's terrain slice; keep it to the four listed edits so no other owner's deferred seam (camera/input/HUD) is pre-empted. |
| 2026-11-26 swarm concurrency | `SWARM_BOARD.md:8-37`: all 30 workers QUEUED; A01–A05 write only reports; D/F/P waves are read-only; COORD integrates (`:39-45`) | No source collision expected from analysis workers. If COORD spawns implementation workers for N1–N11, enforce one-file-per-owner and backup-before-edit (`CHARTER.md:73-75`). A06 claims only its own report. |

---

## 3. Exact backup + rollback commands

**[D] Ticket suffix for this integration: `A06INT`** (seam files) and **`A06MOD`** (new files
created by N1–N11). Rule **[O] from P16 §7 `:380-385`**: copy the *working-tree* file (which
contains Y08b/Y10/Y11), never `git show HEAD:...`; do not overwrite older backups
(`.bak-TRNGEOM`, `.bak-TRNDATA`, `.bak-Y10`, `.bak-Y11`, `.bak-P16` are all distinct tickets).

### 3.1 Pre-edit backup (run from repo root, PowerShell; `;` separates statements)

```powershell
cd "C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3"; git status --short; git rev-parse --short HEAD
Copy-Item -LiteralPath 'variant3d\scripts\main.gd'    -Destination 'inbox\backup\main.gd.bak-A06INT'    -Force
Copy-Item -LiteralPath 'variant3d\scripts\world3d.gd' -Destination 'inbox\backup\world3d.gd.bak-A06INT' -Force
Copy-Item -LiteralPath 'variant3d\scripts\config.gd'  -Destination 'inbox\backup\config.gd.bak-A06INT'  -Force
Get-FileHash -Algorithm SHA256 -LiteralPath 'inbox\backup\main.gd.bak-A06INT','inbox\backup\world3d.gd.bak-A06INT','inbox\backup\config.gd.bak-A06INT' | Format-Table -AutoSize
```

**[O] `config.gd.bak-A06INT` is a precaution only**: §2.1 plans no config.gd edit in stage 2;
it is needed only for stage 4 (config owner). Take it anyway so the flag default cannot be
flipped without a recoverable copy.

### 3.2 New-file backup / rollback inventory

**[D]** New files have no pre-edit content; their "backup" is the exact creation ledger.
Record it once, before rollback:

```powershell
Get-ChildItem -LiteralPath 'variant3d\scripts','variant3d\shaders','variant3d\tools','variant3d\tests' -Filter '*terrain_donor*' -Recurse | Select-Object -ExpandProperty FullName
```

Rollback of stage 2 = restore the three seam files **and remove only N1 (+ N11 if landed)**;
N7/N8/N9/N10 may remain inert (nothing references them while `backend=legacy`).

### 3.3 Rollback commands (file-scoped, non-destructive to foreign edits)

```powershell
cd "C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3"
Copy-Item -LiteralPath 'inbox\backup\world3d.gd.bak-A06INT' -Destination 'variant3d\scripts\world3d.gd' -Force
Copy-Item -LiteralPath 'inbox\backup\main.gd.bak-A06INT'    -Destination 'variant3d\scripts\main.gd'    -Force
# Only if stage 4 flipped the default:
Copy-Item -LiteralPath 'inbox\backup\config.gd.bak-A06INT'  -Destination 'variant3d\scripts\config.gd'  -Force
# Then verify hashes equal the values recorded in §3.1:
Get-FileHash -Algorithm SHA256 -LiteralPath 'variant3d\scripts\world3d.gd','variant3d\scripts\main.gd','variant3d\scripts\config.gd' | Format-Table -AutoSize
# Disable the new module without deleting derived assets (safe partial rollback):
Remove-Item -LiteralPath 'variant3d\scripts\terrain_donor_world.gd' -Force
# Remove the appended test only if it was registered by this ticket:
Remove-Item -LiteralPath 'variant3d\tests\t_terrain_donor.gd' -Force
```

**[D] `tests/manifest.json` is append-only**: if N11 was registered, remove **that one entry**
by its id with a JSON-aware edit by the manifest owner (V7-38 convention,
`STATUS_WAVE7_PHASE2.md:177,199`) — do not restore the whole manifest from `HEAD`.

### 3.4 Forbidden during any rollback

```powershell
# DO NOT RUN ANY OF THESE — they destroy Y08b/Y10/Y11 uncommitted work (E12/E13):
# git reset --hard
# git checkout -- .
# git clean -fd
# Copy-Item <(git show HEAD:...)> ...
```

**[D] Post-rollback gate:** re-run the §2.4 stage-2 gate list; confirm `--dump-config` reports
`backend=legacy`, `t_render_mode` 10/10 `seam_missing=false`, selftest 29/29, uitest 17/17,
`assert_clean CLEAN`, and `git status --short -- app/` empty. Record new job ids in
`STATUS_WAVE7_PHASE2.md` by the owner of that living doc, not by A06.

---

## 4. Implications

1. **[D] The switch is a one-line behaviour change, not a rewrite.** Because `world3d.gd`
   already delegates terrain to a dynamically loaded Node (`world3d.gd:108,213-226,609,643-645`),
   the new module can be developed and parsed in isolation; the legacy path stays literally
   the same script. This is the cheapest way to honour the charter's "legacy retained behind a
   switch until A/B passes" (`CHARTER.md:57-61`).
2. **[D] `world3d.gd` is the only integration owner that must change for stage 2.** `main.gd`
   supplies the flag; `config.gd` needs no edit until stage 4; `game.gd`, both shaders,
   `project.godot`, `app/`, the atlas and all 2D tests need no edit at all.
3. **[D] The dump contract is already sufficient.** No `main.gd:_dump_map()` change is needed
   for stage 2/3; that keeps `main.gd:799-801`'s byte-identical flag-off dump guarantee and
   avoids a producer/consumer co-commit.
4. **[D] The new module inherits two live dependencies**: `world3d_relief.gd` needs
   `height_at_world()` (`world3d.gd:646-650,748-751`) and the landscape must contain exactly
   one water plane with the legacy name (`terrain3d_sandbox.gd:122` seam-mask hook, cited at
   `world3d_terrain.gd:1086-1105`). N1 must implement both or relief/water QA breaks even
   though the mesh itself is correct.
5. **[D] "Default legacy" is a safety property, not a temporary inconvenience.** It makes
   every stage reversible with three `Copy-Item` commands and lets the same gate battery judge
   both backends, which is the only honest way to later claim an improvement.

## 5. Risks

| Risk | Label | Mitigation |
|---|---|---|
| Switch applied at only one of the two `make_world3d()` sites (`main.gd:586` vs `:1103`) → selftest uses one backend, skirmish another | [D] | Make both edits in one commit; assert `stats.terrain_backend` in both paths (§2.1 item 4) |
| New module writes sim state (height/tileblock/RNG) → deterministic gates and 2D save/load diverge | [D] | Z08-style read-only guard (`world3d_relief.gd:3-8`) in N1–N5; verify with same-seed dump replay (`t_map_variety.gd:69-89`) |
| `t_render_mode` fails because the new variable is mistaken for a render-mode literal | [D] | Keep `render_mode` declaration line byte-identical (`main.gd:120-124`); `terrain_backend` default is `"legacy"`, matching none of `t_render_mode.gd:39-42` |
| Two water planes / renamed node breaks the sandbox seam and dark-band QA | [D] | Reuse `water3d.gd` read-only and follow `world3d_terrain.gd:1084-1106` exactly; assert one `WaterPlane` in N11 |
| Atlas drift (new atlas file or index remap) breaks UV2.x `[0,123]` and `grid [16,8]` | [D] | N4 reads the manifest read-only; no new atlas asset; N7 only if required and then as a new shader preserving sampler names |
| Uncommitted Y08b/Y10/Y11 edits lost by a broad restore | [O]/[D] | File-scoped `Copy-Item` only; §3.4 forbidden list; verify `git status` before and after |
| Donor-parity pressure flips the default before a real A/B | [U] | Stage 4 is an owner decision with its own config backup; A06 makes no parity claim (CHARTER.md:125) |
| 320² maps fail although 240²/160² pass | [U] | Explicitly test `MAP_W/MAP_H` 240² default (`config.gd:120-121`) plus 160²/320² fixtures (P16 §1) in stage 3 |
| Concurrent Godot jobs corrupt `.godot` import cache (observed TRN-DATA job 411, `TRN_DATA:77`) | [O] | One Godot at a time via `godot_runner.py run --id <UNIQUE>` (CHARTER.md:80-82); implementation workers ask COORD first |

## 6. UNVERIFIED register

1. **[U]** No donor GPU A/B frame exists; every visual expectation in this plan is structural. Donor parity remains UNVERIFIED (`CHARTER.md:43-44,125`; `STATUS_WAVE7_PHASE2.md:37-39,62-63`).
2. **[U]** A06 ran no Godot process, no runner job, no `git apply` and no capture; all gate outcomes quoted are prior reports (`STATUS_WAVE7_PHASE2.md:17-63`), not measurements by this ticket.
3. **[U]** The exact line numbers for §2.1 edits are the working tree at `HEAD 0e9783f2` with three foreign files modified (E12). Re-read before applying; line offsets drift (P16 §3.1 `:291-300`).
4. **[U]** Whether COORD will assign N1–N11 to distinct implementation workers, and the ticket suffix actually used for backups (`A06INT`/`A06MOD` are this report's proposal, not yet reserved).
5. **[U]** Whether the donor-faithful pipeline can satisfy UV2.x `[0,123]` without a tile-atlas extension; that depends on D08/F05 spec findings not yet landed.
6. **[U]** Whether the donor-generated height field changes `height_at_world()` enough to move resource Y / prop placement outside the 0.001 m / 0.02 m tolerance; stage 3 must measure, not assume.
7. **[U]** Whether `feature_terrain_backend` should be a typed `config.gd` accessor at stage 2 or only at stage 4; §2.1 chooses the zero-conflict generic `text()` read.
8. **[U]** Donor constants needed by N2–N5 (seed/RNG, mask blur, relief stamp, water level) are still being decoded by waves D/F today; no value is invented here (CHARTER.md:40-44,83-84).

## 7. Open questions

1. **Q1 (COORD):** Who owns `main.gd` and `world3d.gd` for the four §2.1 edits? `STATUS_WAVE7_PHASE2.md:170,229-231` calls this a deferred V7-3/4 follow-up batch with no id yet.
2. **Q2 (A05/G04):** What exact matched-seed capture + histogram threshold constitutes stage-3 acceptance, given that no donor frame may be used as ground truth? A05's harness must define it before stage 3.
3. **Q3 (A01/A02):** Should the donor pipeline *replace* `game.gd`'s tile/height generation or only *reinterpret* its output? This report assumes reinterpret (read-only consumer); replacing it would require a producer ticket and new dump keys behind the flag.
4. **Q4 (F05/D08):** Can the donor tile set be expressed inside the existing 124-name summer atlas, or is a new atlas a separate owner-approved contract change? §2.5 assumes no new atlas.
5. **Q5 (COORD):** Should `t_terrain_donor.gd` (N11) assert structural invariants only, or also pin a golden dump hash per seed? A golden hash would be stronger but freezes donor-derived bytes before the spec lands.
6. **Q6 (config owner):** At stage 4, does `"donor"` become the default in `FEATURES_DEFAULTS` (`config.gd:54-63`) or only in a shipped `config.json`? The former affects `--dump-config` baselines and needs `.bak-<TICKET>`.
7. **Q7 (COORD):** Does the final 3D status live in `STATUS_WAVE7_PHASE2.md` or a new `STATUS.md`? Historically open (`STATUS_WAVE7_PHASE2.md:315-317`); gate job ids must land somewhere authoritative.

---

*End of A06 report. Exactly one report written; no source, shader, config, asset, test, runner, git or `app/` edit; no Godot job; no donor access; no parity claim. Default remains legacy.*
