---
id: W06
worker: W06
wave: VISUAL
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_EDIT__NO_GODOT__NO_RUNNER__NO_GIT_WRITE
owner_file: docs/terrain_swarm_2026-11-26/reports/W06_performance_audit.md
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_claim: false
parity_guard: "No donor GPU A/B frame exists or was produced. This is a port-internal speed/usability audit only. NO DONOR PARITY CLAIM."
source_note: "The requested reports/P17_perf_audit.md does not exist anywhere in the repository (two glob passes). The closest landed performance audit, docs/terrain_swarm_2026-11-25/reports/G17_perf_audit.md, was read and is cited as G17 instead."
---

# W06 — donor-backend performance and usability audit

## 0. Executive summary

1. **[O] The only clean donor capture baseline is ticket 636: 45.555 s.** Ticket 633
   exited 0 in 36.498 s but has a real `SCRIPT ERROR` (`U64_MASK` parse failure), so I17
   did not run. Ticket 632 failed in 40.562 s with **93 `SCRIPT ERROR` lines**. Ticket 631
   selftest exited 0 in 63.342 s. Runner `run` is whole-process wall time, not a stage timer
   (`variant3d/tools/godot_runner.py:430-463`).
2. **[O]/[D] JSON text parsing is the largest identified donor-startup cost.** For seed
   20261113, I17 parses a 55,507,231 B `family_index.json`, 37 family JSONs totaling
   29,455,075 B, and 64 pattern JSONs totaling 30,346,581 B: **115,308,887 B**. I09 then
   parses the 55,784,815 B `pattern_lib_index.json`: **171,093,702 B (163.1 MiB) of JSON
   text** on the main thread in the clean 636 path.
3. **[O]/[D] I09's 55.8 MB parse buys no stamp props in the current feed shape.** The file
   self-describes as “metadata only” (`pattern_lib_index.json:2`) and has no per-pattern
   Objects map. `_try_feed()` falls through to `generator_families` and stores one record
   bucket named `generator_families`; `_collect_stamp()` looks up each stamp by its pattern
   name, so normal stamp names cannot match. This is a high-cost, zero-prop parse.
4. **[O]/[D] The clean capture does not use G17's 512 MiB legacy atlas.** I08 prefers
   `terrain_new/atlas/tile_index_atlas.png`, which is 2048×1024 RGBA (8 MiB decoded), not
   the legacy 16384×8192 atlas (512 MiB decoded). G17's ~683 MiB mip-chain concern applies
   to the legacy path, not this donor capture path.
5. **[U] No valid per-frame render measurement exists.** The capture logs contain no FPS,
   frame-time, draw-call or primitive counters. Existing headless telemetry reports zeros
   under the dummy renderer and is unusable. Structurally, terrain is one ArrayMesh/one
   surface and props are MultiMesh-batched; actual render cost remains unmeasured.
6. **[I] Proposed speed acceptance:** on the same MX130/1280×720/seed/config, three clean
   cold 240² donor captures must have **median runner wall ≤30.0 s, maximum ≤35.0 s, zero
   `SCRIPT ERROR`, and a valid saved PNG**. That is a ≥34% reduction from the clean 45.555 s
   baseline. This is a proposed port-internal target, not a donor-parity gate.

---

## 1. Scope, method and evidence discipline

- Read-only. Exactly one repository file is written: this report. No `.gd`, shader, config,
  asset, test, result JSON, `app/**`, donor file or git state was edited. No Godot process,
  runner subcommand or gate was run.
- Current donor modules read in full: `terrain_donor_inputs.gd`, `terrain_donor_data.gd`,
  `terrain_donor_gen.gd`, `terrain_donor_mesh.gd`, `terrain_donor_props.gd`,
  `terrain_donor_world.gd`; supporting reads: `main.gd`, `world3d.gd`,
  `tile_atlas_loader.gd`, `water3d.gd`, `testbridge.gd`, `godot_runner.py`.
- Required prior reports read: visual-wave charter, P01 pipeline audit, P07 node count,
  P08 quality knobs, V55 Python preflight, V42 gate commands. G17 was read in place of the
  absent P17 file. V59 was also read to reconcile the now-landed I03 feed.
- Read-only Python/PowerShell inspection measured file sizes, JSON top-level shapes,
  selected I17 pattern counts/bytes, stderr error counts and result-envelope durations.
  `PYTHONDONTWRITEBYTECODE=1` was set; no artefact was written.
- Labels: **[O]** literal source/result/byte observation; **[D]** deterministic consequence;
  **[I]** inference; **[U]** unverified. Cost attribution without a stage timer is never
  presented as measured time.

---

## 2. Runner evidence: what is actually measured

### 2.1 Primary jobs

| Ticket | Job | Envelope | Script errors | Performance interpretation |
|---:|---|---|---:|---|
| 631 | `v42g-selftest` | ok, exit 0, **63.3419 s**, wait 0.0009 s | 0 | Legacy/default selftest; not donor-stage timing. Current `selftest.json` mtime 09:52:15Z matches this run. |
| 632 | `v42-cap-donor-240` | **failed**, exit 1, **40.5622 s** | **93** | Raw screenshot exists, but mesh ingest and 92 prop-stamp calls error. Not a valid clean baseline. |
| 633 | `v42-cap-donor-240b` | ok, exit 0, **36.4983 s** | **1** | I17 parse failure (`U64_MASK`); donor I07 receives empty inputs. Exit 0 is not a clean performance result. |
| 636 | `v42-cap-donor-240c` | ok, exit 0, **45.5551 s** | **0** | Clean donor capture baseline. One case-mismatch warning, but no script error. |

**Measured deltas, with limits:**

- **[D] 636 − 633 = +9.0567 s (+24.8%).** This is an *activation delta*: I17 becomes
  loadable and I07 receives real inputs in 636. It is not a clean measurement of I17 alone;
  code changed between jobs and 633 contains a parse failure.
- **[D] 633 − 632 = −4.0638 s.** A failed run without a donor mesh was slower than a later
  run with one. Therefore subtracting 632 from 633 cannot estimate mesh cost; error logging,
  code changes and runtime variance dominate.
- **[D] Selftest step work sums to 17.745 s** (`variant3d/selftest.json:12-186`). The remaining
  **45.5969 s** of ticket 631 is startup/setup/world/atlas plus harness overhead. It is a
  coarse whole-boot residual, **not** a mapgen-only measurement. The `save_load` step alone
  is 13.647 s (`selftest.json:163-168`).

### 2.2 V42 gate timing context

| Ticket(s) | Result | Use in this audit |
|---:|---|---|
| 607–614 | 8.19–12.96 s; mixed pass/fail | Early parse wave; failures and moving source make it unsuitable as a stable floor. |
| 616–624 | 4.68–8.82 s; mixed; final gen parse 624 = **4.7718 s ok** | Shows a headless parse-only process can still cost several seconds. |
| 625 | **207.2477 s ok** | Excluded: `argv` was passed as one space-containing string plus a second fragment; stderr also reports a missing icon. Not a valid shader-speed datum. |
| 626 / 627 | **9.0245 s ok / 8.0729 s ok** | Donor atom / render-mode context only; no stage timers. |
| 628 | result JSON missing | Do not infer a duration or result. |
| 629 | **9.8428 s failed** | Runs four small/240² generations with empty settings, then fails mesh/stub checks; not representative of full I17+I07 input cost. |
| 630 | **5.6581 s ok** | Render-mode process floor, not full game. |
| 634 / 635 | **4.1456 s / 3.9567 s ok** | Final I17/composer parse-only jobs; useful headless startup/import lower-bound context. |
| 637 | **146.0771 s ok** | UITest, not donor capture; stderr shows two full world/atlas setups. Not comparable to 636. |

---

## 3. Stage accounting: measured versus inferred

| Stage | Direct measurement | What can be inferred | Confidence |
|---|---|---|---|
| Startup / script import | Headless parse-only jobs 624/634/635 = 4.77/4.15/3.96 s; render-mode 630 = 5.66 s | Full windowed process startup is not isolated. Parse-only numbers are a lower-bound context, not a subtractable constant for captures. | [O] envelope; [U] full startup split |
| Legacy `game.setup()` / mapgen | No stage timer in `main.gd` or `game.gd` | Every donor capture first runs legacy setup (`main.gd:1100-1101`; async path `:568-586`). Selftest residual 45.60 s and historical ~43.6 s proxy show setup is substantial, but include other work. | [I] major; [U] exact |
| I17 input preparation | 633→636 activation delta +9.0567 s; 115.31 MB JSON text counted | Likely a dominant incremental cost in 636. The delta also includes I07 and code changes. | [O] bytes/delta; [I] attribution |
| I07 donor generation | No stage timer | Full-grid smoothing, water fields, tile/collision passes and diagnostics are material CPU work at 240². | [I] |
| I08 mesh / atlas / water | No stage timer; geometry and image sizes counted | Likely subsecond-to-few-second class, much smaller than JSON text; per-pixel water image and duplicate copies are avoidable. | [I] |
| I09 prop feed / instancing | No stage timer; 55.78 MB JSON counted | Likely major startup cost, currently with zero useful stamp lookup results. | [O] bytes/shape; [I] time |
| Per-frame render | None | Cannot derive FPS from a 10-frame capture's total process time. Headless zeros are invalid. | [U] |

---

## 4. Ranked bottlenecks and semantics-preserving optimizations

### Rank 1 — I09 parses a 55.8 MB metadata index that cannot key stamp props

**Evidence**

- `terrain_donor_props.gd:220-230` calls `_load_manifest()` and `_load_feed()` on every
  rebuild. `_try_feed()` reads and parses the whole file at `:550-554`.
- Canonical feed: `res://assets/terrain_new/lib/pattern_lib_index.json`,
  **55,784,815 B**. `FEED_LIB_INDEX` and `FEED_FAMILY_INDEX` point to the same file
  (`terrain_donor_props.gd:59-60`), but a successful first parse prevents a second parse.
- [O] The file's own description says “metadata only, no per-.pattern binary decode”
  (`pattern_lib_index.json:2`). Top-level keys include `generator_families`, `pattern_lib`,
  censuses and offsets; there is no `props`/`objects`/`Objects`/`records`/`by_pattern`
  dictionary.
- [D] `_try_feed()`'s fallback scan (`terrain_donor_props.gd:585-617`) therefore selects
  `generator_families` and stores 64 family dictionaries under `_records["generator_families"]`.
  `_collect_stamp()` later requests `_records.get(name)` for names such as `g_mnt_*`,
  `frt_*`, `mng_1` (`:626-643`), so no ordinary stamp name matches.
- The model manifest adds another 320,756 B JSON parse (`terrain_donor_props.gd:509-529`).

**Optimization**

1. Generate a compact **`props_by_pattern`** runtime index offline from the authoritative
   family `sections[] → blocks[]` Objects records. Key it exactly by stamp name and retain
   only fields consumed by `_normalize_record()` (`terrain_donor_props.gd:670-747`): base,
   position, scale, up/yaw, line and class/family provenance.
2. Load that compact index once and cache it across rebuilds. Preserve record order and a
   source hash/count manifest so the compacting step is byte-auditable.
3. Keep the Z08 fallback and all skip counters. Do **not** use per-pattern
   `object_records` tails as transforms; V59 §4 already distinguishes those tails from
   `pattern.lib` Objects.
4. Do not call `JSON.parse_string()` on the 55.8 MB metadata index at runtime.

**Semantic guard:** same stamp→record membership, same record order, same transforms, same
class/family assignment, same fallback behavior. Verify with a pre/post index diff and
existing determinism/props atoms.

### Rank 2 — I17 eagerly parses 115.3 MB of JSON for a 64-pattern bounded set

**Evidence**

- `_read_json()` performs whole-file `get_as_text()` + `JSON.parse_string()`
  (`terrain_donor_inputs.gd:79-93`).
- `_apply_patterns()` parses `FAMILY_INDEX` at `:528`, each selected family JSON at `:549`,
  and each selected pattern JSON through `_decode_pattern()` at `:480`/`:592`.
- The comment says “NEVER the 55.8 MB lib index” (`terrain_donor_inputs.gd:453-455`), but the
  configured `patterns/family_index.json` is itself **55,507,231 B** and has the same
  metadata-style top-level shape.
- [O] For seed 20261113, deterministic selection loads:
  - 1 family index: **55,507,231 B**;
  - 37 family files: **29,455,075 B**;
  - 64 pattern files: **30,346,581 B**;
  - I17 total: **115,308,887 B (110.0 MB)**.
- Those 64 patterns contain **126,617 grid cells** total: only 506,468 B of float32 grid
  data plus 126,617 B of occupancy, versus 30.35 MB of JSON text.
- `MAX_PATTERNS=64` is enforced at `terrain_donor_inputs.gd:41,570-590`. The cap bounds
  count, not bytes.

**Optimization**

1. Precompute a compact runtime bundle containing only:
   - family → ordered `{name,freq}` members needed by roulette;
   - the exact selected pattern names and their `w,h,grid,flags,occupancy` fields.
2. Parse the bundle once per seed/config and cache it. A binary/PackedFloat32 representation
   is preferable; if JSON is retained, strip all metadata/line offsets/census fields.
3. Alternatively make pattern decode lazy by name. Family roulette needs only names/freqs;
   the grid is needed only when `_pattern(name)` is actually consumed. Preserve the exact
   selected-name set and order.
4. A reduced pattern set is safe **only after a reachability proof** for the current stage
   path. `_setup_patterns_by_type()` currently draws names and records candidates but does
   not call `_pattern()` or stamp (`terrain_donor_gen.gd:2026-2039`), so many eagerly decoded
   grids are unused today. Do not silently exploit that incomplete behavior; record the set
   hash and keep all semantically reachable patterns.

**Semantic guard:** same family members/frequencies, same seed rotation, same pattern names,
same float bits, same occupancy bytes, same flags, same load skips.

### Rank 3 — legacy map generation and donor generation both run synchronously

**Evidence**

- Full setup calls `game.setup()` before constructing the world
  (`variant3d/scripts/main.gd:1100-1115`). The interactive loader likewise runs
  `setup_begin/_gen_base/_gen_forests/_gen_resources/_gen_finish/_assign_tileblocks/setup_spawns`
  synchronously at `main.gd:568-586`.
- Donor composer then refreshes the live legacy view and runs I07 into a separate I06
  container (`terrain_donor_world.gd:207-240`).
- In the interactive loader, all donor I17/I07/I08/I09 work is inside the single
  `world.bind(game)` block at `main.gd:589-596`. `_loading_tick()` yields only **between**
  stages (`main.gd:531-538`), not during JSON parsing or generation.

**Optimization**

1. Cache seed/config-keyed generated inputs and compact feeds for repeated loads/rebuilds.
2. Split long legacy stages into cooperative sub-steps with yields while preserving exact
   call order and RNG draws. This improves window responsiveness without changing output.
3. A worker thread is appropriate only for pure CPU work on detached data, such as parsing
   a compact JSON/binary bundle into plain Variant/Packed arrays, **after** a Godot
   thread-safety test. Keep `ResourceLoader`, `ImageTexture`, node creation, `MultiMesh`, and
   all scene-tree mutation on the main thread.
4. Removing legacy generation entirely would require proving that donor-owned generation
   can also reproduce spawns/entities/nav/state expected by the rest of the game. That is
   not a semantics-neutral optimization and is not recommended as a silent change.

### Rank 4 — I07 full-grid passes and unconditional diagnostics

**Evidence**

- `_mask_to_height()` scans all cells (`terrain_donor_gen.gd:843-922`); `_channel()` copies
  and rescans each channel (`:925-955`).
- `_smooth_chain()` performs one land pass plus three coastal passes
  (`:961-982`). Each coastal cell may call `_has_water_5x5()` (`:1011-1017`), up to 25
  neighbor reads. At 240² this is up to **4.32 million** water-neighbor checks, plus
  230,400 smoothing cell visits across four passes.
- `_water_fields()` always loops a fixed 320² field grid: **102,400 blocks**
  (`:1028-1052`).
- Tile classification, collision and three H/V tile-smoothing passes add more full-grid
  work (`:1071-1121`, `:1130-1182`, `:1295-1330`).
- `generate()` unconditionally calls `data.stats()` (`:509-512`), which copies and sorts
  all 57,600 heights and builds histograms (`terrain_donor_data.gd:599-733`). I08 later
  sorts and bins the heights again (`terrain_donor_mesh.gd:593-617`).

**Optimization**

1. Precompute a water-near mask once using the same 5×5 rule, then reuse it for all three
   coastal passes. An integral image or separable box filter is equivalent if boundary
   behavior is preserved.
2. Hoist invariant channel normalization and avoid repeated `Object.get/set` in inner
   loops where the concrete I06 type is known.
3. Make diagnostics optional or compute one shared histogram/decile result. Stats must
   remain diagnostics-only and must never feed generation.
4. Keep arithmetic order, in-place smoothing behavior, strict comparison operators and RNG
   draw counts unchanged.

### Rank 5 — I08 duplicate typed-array copies, mesh loops and per-pixel water image

**Evidence**

- `_as_float_array()` duplicates an existing PackedFloat32Array
  (`terrain_donor_mesh.gd:216-221`); `_ingest()` allocates another `_height` and copies it
  again (`:274-280`). Byte arrays have the same duplicate-then-copy pattern (`:243-257`,
  `:281-292`).
- Build allocates five packed arrays and fills 57,600 vertices, normals, UVs and UV2s,
  then 342,726 indices (`:727-787`). Raw array payload is about **3.50 MiB**:
  57,600 vertices, 114,242 triangles, one surface.
- `_normal_at()` and `_face_mode_at()` are called per vertex (`:752`, `:765`), each
  re-reading neighboring heights (`:313-355`).
- `_make_water()` calls `water3d.bind_height_grid()` (`:574-587`), which performs 57,600
  `Image.set_pixel()` calls (`water3d.gd:305-320`).
- `_height_deciles()` and `_make_stats()` add another full sort/bin pass
  (`terrain_donor_mesh.gd:593-627`).

**Optimization**

1. Use read-only CoW aliases for `_height`, `_tex` and `_relief_mask` instead of duplicate
   plus second copy. The I06 live contract already specifies read-only use
   (`terrain_donor_data.gd:382-407,455-475`).
2. Fill UV/UV2 and indices in tight typed loops; combine normal/face neighbor reads where
   it preserves exact values.
3. Build the water alpha image through a direct byte buffer / `Image.create_from_data`
   path rather than one `Color` + `set_pixel()` call per cell.
4. Make mesh diagnostics optional or reuse I06's already-computed height statistics.

**Semantic guard:** identical vertex positions, normals, UV/UV2 bits, triangle order,
water alpha bytes and one-surface topology.

### Rank 6 — MultiMesh instancing will become a hot path once the feed is corrected

**Evidence**

- `_add_to_batch()` creates one `MultiMesh` per `class|family|sid`
  (`terrain_donor_props.gd:750-777`).
- It increments `mm2.instance_count` for every record (`:779-783`), then resolves mesh
  existence/path and writes the transform (`:785-796`).
- `_batch_classes()` scans all batch keys for every instance (`:798-815`). Mesh/bbox/sid
  resolution is repeated per record (`:693-711`, `:750-759`, `:785-790`).
- [U] Current clean captures instantiate zero useful stamp props because of Rank 1, so
  there is no measured MultiMesh cost yet.

**Optimization**

1. Two-pass build: normalize/count placements per batch, allocate each `MultiMesh` once,
   then write transforms.
2. Cache sid→mesh path, mesh resource and bbox per build; maintain per-class batch counts
   incrementally instead of rescanning `_batches`.
3. Preserve batch key, record order and transform math exactly.

### Rank 7 — repeated atlas/mask preparation is real but not the legacy 683 MiB problem

**Evidence**

- I08 chooses the new atlas when present (`terrain_donor_mesh.gd:367-383`). The selected PNG
  is **4,211,707 B, 2048×1024 RGBA, 8 MiB decoded**. Masks are 512×256 and 1024×512 L.
- The legacy PNG is 179,912,941 B, 16384×8192 RGBA, 512 MiB decoded. G17's ~683 MiB mip
  chain is therefore **not** the active donor-capture atlas path.
- The loader still decodes and generates mips synchronously
  (`tile_atlas_loader.gd:280-290,350-356`). I08 repacks both masks with per-pixel
  `get_pixel/set_pixel` (`terrain_donor_mesh.gd:405-421`). `invalidate()` drops references
  (`:801-819`), so a rebuild repeats the work.

**Optimization**

1. Cache prepared atlas/mask `ImageTexture`s across rebuilds, keyed by path/season/manifest.
2. Repack mask R→A with a direct byte buffer or a tiny shader, preserving exact alpha.
3. Move only pure `Image.generate_mipmaps()` work to a worker after a thread-safety test;
   create/upload `ImageTexture` on the main thread. Given the 8 MiB donor atlas, this is a
   lower-priority optimization than JSON compaction.

---

## 5. Usability findings independent of raw speed

1. **[O] Exit 0 is not a clean capture.** Ticket 633 has an I17 parse error; ticket 632 has
   93 script errors. Performance acceptance must require stderr `SCRIPT ERROR=0`, not just
   envelope `status=ok`.
2. **[O] Ticket 632's error flood is concentrated and avoidable:** one mesh operand error
   at `terrain_donor_mesh.gd:183` and 92 repeated Object→Dictionary errors at
   `terrain_donor_props.gd:628`, totaling 995 stderr lines. Normalize Object stamps once or
   skip/report them once; do not emit a full backtrace per stamp.
3. **[O] The interactive loader can still freeze during “Loading art...”.** The donor
   composer's I17/I07/I08/I09 work is one synchronous `world.bind()` body
   (`main.gd:589-596`). Inter-stage awaits do not make that body responsive.
4. **[O] A portability warning remains:** 636 requests `k_ravine_2.json` while the file is
   stored as `K_ravine_2.json` (`terrain_donor_inputs.gd:475-480`; 636 stderr:1-11). Windows
   opens it; case-sensitive exports will not.
5. **[D] Quality knobs do not address the dominant costs.** P08 correctly identifies the
   live 3D knobs, but `fx_cap`, fog/minimap cadence and quality presets do not touch I17/I09
   JSON parsing or the duplicate generation path. Do not spend A/B arms on inert knobs.

---

## 6. Per-frame render assessment

**Observed structure**

- Terrain build creates one indexed `ArrayMesh`, one surface and one `MeshInstance3D`
  (`terrain_donor_mesh.gd:718-798`); `terrain_draw_calls_expected=1` at `:645`.
- The world builds terrain once in `bind()` (`world3d.gd:657-666`). `sync()` does not rebuild
  it (`world3d.gd:716-729`).
- Props use one `MultiMeshInstance3D` per `class|family|sid`
  (`terrain_donor_props.gd:750-777`). This is the right general direction for instance
  count, but batch count and overdraw are unmeasured.
- Terrain shadow casting is off (`terrain_donor_mesh.gd:792`); no terrain shadow map is
  submitted.

**Unavailable measurements**

- Capture stdout has no FPS/frame-time/draw-call/primitive data.
- `t_terrain_trees.json:185-194,220-225` records zeros under the headless dummy renderer;
  those are not GPU measurements.
- A 10-frame screenshot's 45.555 s process wall cannot be divided by 10 to obtain frame
  time; startup dominates.

**Conclusion:** there is no evidence to rank shader ALU, terrain fill rate or MultiMesh
rendering above startup JSON/generation costs. Do not change the shader or reduce art based
on these capture envelopes.

---

## 7. Profiling plan for COORD / performance owner

### 7.1 Add stage timers without changing behavior

Instrument with `Time.get_ticks_usec()` and export additive diagnostics only:

1. `game.setup()` total and each legacy setup stage (`main.gd:568-586` or `:1100-1101`).
2. `I17.build()`: mask, constants, family index, family docs, pattern decode.
3. `I07.generate()`: mask/height, each smoothing pass, water fields, texture tiles,
   collision, tile smoothing, starts/mines, relief/forest stages, diagnostics.
4. `I08.build()`: ingest, atlas decode, mip generation, mask repack, vertex/normal/UV2
   loops, ArrayMesh submission, water image, stats.
5. `I09.build()`: model manifest, feed parse, stamp collection, normalization, batch
   allocation, transform writes.
6. First rendered frame and screenshot-save timestamp, separate from process exit.

Keep timer values out of simulation decisions, RNG and gate thresholds.

### 7.2 Startup runs

- Use the exact 636 config/seed/path: 240², seed 20261113, 1280×720, 10-frame screenshot.
- Run **three cold processes**, strictly one runner job at a time. Record OS file-cache state
  and do not run other Godot jobs concurrently.
- Also measure an in-process donor `invalidate()/build()` rebuild to quantify cacheable work.
- Reconcile stage sum against runner `run`; report startup, teardown and unaccounted time
  separately.

### 7.3 Per-frame runs

- After warm-up, capture 300 fixed-camera frames at 1280×720. Record p50/p95 frame time,
  FPS, process/physics time, draw calls and primitives using the existing monitor surface
  in `testbridge.gd:243-250` plus `Performance.TIME_FPS`.
- Diagnostic visibility A/Bs: terrain only, props only, both. Keep the same camera, seed,
  materials and simulation state; visibility changes are measurement-only.
- Record terrain vertices/triangles, prop instances, MultiMesh batch count and distinct
  sids. If available, take one RenderDoc/Godot frame capture on the MX130 for GPU-side
  fill and texture evidence.
- Do not treat headless dummy-renderer counters as evidence.

### 7.4 Responsiveness and semantic verification

- During interactive load, drag the Windows title bar at every stage. No stage may freeze
  dragging; the overlay must remain until `load_ready=true` (`main.gd:670-683`).
- For every optimization, compare same-seed height/tile/collision hashes, RNG draw ledger,
  family counts, stamp order, prop record order/transforms and mesh arrays before/after.
- Require zero `SCRIPT ERROR`, valid 1280×720 PNG, existing gates green, and `app/**`
  byte-untouched. Visual comparisons are port-internal only; no parity claim.

---

## 8. Speed acceptance target

**Proposed primary target [I]:**

- Same MX130, Windows, OpenGL Compatibility, 1280×720, donor backend, 240², seed 20261113,
  same config and 10-frame screenshot.
- Three cold runs: **median runner wall ≤30.0 s**, **maximum ≤35.0 s**.
- **Zero `SCRIPT ERROR`**, valid non-blank PNG, screenshot diagnostics present, no queue wait.
- No interactive loading stage may block window dragging; no post-overlay blocking.

This is a 15.555 s (34.2%) reduction from the clean 636 baseline. It is intentionally a
whole-process usability target, not a claim about any single unmeasured stage.

**Profiling budgets to diagnose, not silently relax [I]:**

- I17 compact-input stage ≤2.0 s.
- I09 compact-feed + instancing stage ≤1.0 s after the feed is correct.
- I08 mesh/atlas/water stage ≤3.0 s.
- Any remaining unexplained synchronous block >2.0 s gets a dedicated owner/ticket.

A per-frame FPS acceptance number should be set only after §7.3 establishes a real baseline;
inventing one now would be test weakening by another name.

---

## 9. UNVERIFIED register / handoff

1. Exact startup, legacy mapgen, I17, I07, I08 and I09 stage times are **[U]**; only whole
   process envelopes and file/loop sizes are measured.
2. Exact JSON parse memory expansion, peak RSS/VRAM and GC cost are **[U]**.
3. Per-frame FPS, frame time, draw calls, primitives and GPU bottlenecks are **[U]**.
4. Worker-thread safety for any proposed Godot API is **[U]** until a focused test proves it.
5. Ticket 633 is not a clean baseline; ticket 632 is failed; there is no controlled
   same-code legacy-vs-donor A/B in these artifacts.
6. G17's legacy atlas mip concern is not active in the selected donor atlas path; actual
   donor atlas timing is still **[U]**.
7. No donor binary was executed, no donor GPU frame was read, and **no donor parity claim
   is made**. All optimizations are port-internal and semantics-preserving proposals.

**COORD priority order:** compact/correct I09 feed → compact/cache I17 inputs → instrument
and time-slice the synchronous legacy+donor boot → optimize I07/I08 loops → two-pass
MultiMesh → establish a real per-frame baseline.

*End of W06. Exactly one report written; no code, Godot, runner, gate, asset or git edits. NO DONOR PARITY CLAIM.*
