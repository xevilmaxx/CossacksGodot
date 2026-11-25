---
id: P06-LOADING-PATH
ticket: TERRAIN-SWARM-2026-11-25 / Wave P / P06 (read-only loading-path audit)
date: 2026-11-25
status: COMPLETE__READ_ONLY__NO_GODOT_JOBS
labels: [observed, derived, inferred, UNVERIFIED]
files_created:
  - docs/terrain_swarm_2026-11-25/reports/P06_loading_path.md
files_edited: []
godot_jobs_run: 0
runner_jobs_submitted: 0
parity_guard: "No Godot run, no capture and no frame-time measurement was made. Every cost in this report is an analytical/structural estimate labelled INFERRED or UNVERIFIED; nothing here is a benchmark, an FPS claim, or a donor-parity claim (CHARTER §3)."
---

# P06 — startup / loading-path audit (main.gd → terrain → atlas → overlay hide)

## 0. Scope compliance and snapshot caveat

Read-only. Exactly one file created (this report); no code, shader, config, test or loader file
edited; no Godot process started and no runner job submitted (WAVE_G_CHARTER § "only G04 runs
Godot/runner jobs").

Inputs read in full: `WAVE_G_CHARTER.md` (Wave P), `docs/terrain_swarm_2026-11-25/CHARTER.md`,
`reports/G17_perf_audit.md`, `docs/coord_swarm_2026-11-25/UX_LOADING.md`.
**`G23_loading_design.md` does not exist on disk** — searched `*G23*`, `*loading*design*`, and all
of `docs/` for the string `G23`; the only reference is the P06 row in `WAVE_G_CHARTER.md:79`.
Any G23 content is therefore **UNVERIFIED / NOT AVAILABLE** to this audit; the loading design
actually used is `UX_LOADING.md` + G17 §1.3/§6.

Source verified directly (on-disk working tree, HEAD `8e9de1bf`): `variant3d/scripts/main.gd`,
`world3d.gd`, `world3d_terrain.gd`, `world3d_entities.gd`, `world3d_fx.gd`,
`tile_atlas_loader.gd`, `variant3d/scripts/data.gd`,
`variant3d/assets/terrain/atlas/tile_index_atlas.png.import`, plus the atlas PNG byte size.

**Important version note (OBSERVED):** the current `main.gd` is **not** the snapshot described in
`UX_LOADING.md:9` (clean at `49aa81f7`, "pre-directive"). It already contains the LOAD-ASYNC-01
changes: `load_ready` flag (`:154-157`, `:464`, `:675`), warm `world.sync(0.0)` (`:657-662`),
one `RenderingServer.frame_post_draw` hold (`:665-670`), extra stage ticks (`:594`, `:620`,
`:637`, `:648`, `:663`) and `_apply_3d_hooks()` (`:643`, `:1070-1074`). `git status` shows
`main.gd` clean, so these are committed at HEAD. All line numbers below are **current on-disk**;
where G17/UX_LOADING quote older lines for the same code I give both.

---

## 1. Complete startup timeline (interactive 3D path)

"Sync?" = does the stage body run to completion inside one main-thread frame (no worker, no
intra-stage yield)? "Overlay?" = is the `CanvasLayer` 30 from `_show_loading()` still alive?

| # | Stage / call site (current file:line) | Sync on main thread? | Likely cost (all UNVERIFIED until profiled) | Overlay visible? |
|---|---|---|---|---|
| 1 | `_ready()` → `_setup_menu()` — `main.gd:172-250`, `:252-255` | Yes | Construct one `C3MenuScript`, connect signal; negligible | **No** (menu only) |
| 2 | Start click → `_on_menu_chosen()` → `_apply_menu_cfg(cfg)` — `main.gd:257-260`, body `:274-375` | Yes | A few hundred `Data` static writes, `RandomNumberGenerator`, small dict loops; µs–low ms. No asset I/O. | **No** (menu still up until step 3) |
| 3 | `_do_async_load()` entry: gen bump, `menu.queue_free()`, `_show_loading()`, `_set_loading(0.02)`, 2× `process_frame` — `main.gd:535-546` (overlay built at `:462-506`, layer 30 at `:466`) | Yes (construction), then yields | Build ~8 Control nodes; negligible | **Yes — from `:543`** |
| 4 | Window size / fullscreen / vsync — `main.gd:549-554` | Yes | DisplayServer calls; possible one repaint; low | Yes |
| 5 | Sim stages `"Starting simulation..." → "Mustering armies..."` — `game.new/add_child` `:559-560`; `setup_begin` `:563`; `_gen_base` `:566`; `_gen_forests` `:569`; `_gen_resources` `:572`; `_gen_finish` `:575`; `_assign_tileblocks` `:578`; `setup_spawns` `:581`. Yields only **between** stages via `_loading_tick()` `:561,564,567,570,573,576,579` (body `:526-533`) | **Yes — each stage is one synchronous block.** Inter-stage awaits repaint the bar but cannot pump Windows messages *during* a stage | Each stage loops over the map grid (default 160×160 = 25,600 cells, `data.gd:33-34`) several times and allocates Packed arrays; plausibly tens–hundreds ms per stage on a weak CPU — **INFERRED / UNVERIFIED** | Yes |
| 6 | Loadsave + `game_over` connect — `main.gd:582-583` (body `:678-686`) | Yes | File read + JSON parse only if a save is requested; otherwise negligible | Yes |
| 7 | **`0.90 "Loading art..."`** — `_loading_tick` `:584`; `world = make_world3d()` `:587`; `world.bind(game)` `:588`; `add_child(world)` `:589` | **Yes — the single largest synchronous block** (full chain in §2) | Atlas PNG decode + CPU mip build + 683 MiB texture upload + full-grid mesh build + mask repack + water/environment + entity/FX/fog/anim bind; order **hundreds of ms to several seconds** — **INFERRED / UNVERIFIED** | **Yes** (label painted by the two awaits inside `:584`) |
| 8 | `0.92 "Wiring camera..."` — `main.gd:594-619`; `make_camera3d()` `:597`, `bind` `:599`, focus handoff `:608-613` | Yes | Load camera script, one Camera3D, focus lookup; low–moderate | Yes |
| 9 | `0.94 "Building interface..."` — `main.gd:620-636`; HUD `new/add_child/bind` `:622-625`, callbacks `:626-636` | Yes | HUD constructs many Control nodes (see P04/P12); moderate — **UNVERIFIED** | Yes |
| 10 | `0.96 "Wiring input..."` — `main.gd:637-647`; input `new/add_child/bind` `:639-641`, `_apply_3d_hooks` `:643`, `_set_selection` `:646`, `_create_ai_brains` `:647` | Yes | Picking/HUD 3D adapters, AI brain construction; moderate. **Note:** once `ais` is non-empty (`:647`), `_process()` stops early-returning (`main.gd:1603-1604`) and starts sim ticks + `world.sync(dt)` (`:1671`) **while the overlay is still up** | Yes |
| 11 | `0.98 "Starting audio..."` — `main.gd:648-662`; audio `:650-655`, objectives `:656`, **warm `world.sync(0.0)` `:661-662`** | Yes | Audio init; warm sync materialises lazily-built entity/FX state — **INFERRED**, cost UNVERIFIED | Yes |
| 12 | `1.0 "Ready!"` + one awaited draw — `main.gd:663`, `RenderingServer.frame_post_draw` `:667-670` | No (await) | First real draw; shader compile / texture upload may land here — **UNVERIFIED** | **Yes** (hold is deliberate, `:665-666`) |
| 13 | `load_ready = true` `:675`; `_hide_loading()` `:676` → `queue_free()` `:517-524` | Yes | Flag set + overlay freed; negligible | **Hidden here** — first point at which the layer is gone |
| 14 | Steady state `_process(dt)` — `main.gd:1587-1675`, `world.sync(dt)` `:1671` | Per-frame | Sim ticks, AI, entity/FX sync (owned by P01/P03/P04/P11/P12). Anything lazy still uploading after the first draw is **UNVERIFIED** | No |

**Timeline OBSERVATION:** the overlay is alive for the whole load (step 3 → step 13). Every
"heavy" item is a synchronous stage body; `await get_tree().process_frame` appears only
*between* stages (`_loading_tick()` `main.gd:531-532`) and once for the final draw (`:668`).
This is exactly the structure `UX_LOADING.md:55` calls the remaining freeze cause, and it is
still present at HEAD.

---

## 2. The `0.90 "Loading art..."` stage, expanded (the 3D bind chain)

All of the following executes **inside one main-thread frame**, between `main.gd:584` and
`main.gd:594`, with the overlay painted "Loading art..." and the Windows message pump blocked.

```
main.gd:587  make_world3d()            -> :1038 load("res://scripts/world3d.gd"), :1042 new()
main.gd:588  world.bind(game)          -> world3d.gd:599 bind()
  world3d.gd:603-623  instantiate 5 modules (terrain/entities/fx/fog/anim) via
                      _instantiate() :208-212  (ResourceLoader.exists + load)
  world3d.gd:637      terrain.bind(game)  -> world3d_terrain.gd:381 (only `_game = game`)
  world3d.gd:638-639  if height source: terrain.build()
                      -> world3d_terrain.gd:1301 build()
    :1303 invalidate()                  (drops prior atlas loader / texture refs; :1250-1293)
    :1304 _dump_from_game()             (base64 of height/terrain/tileblock)
    :1320-1324 decode w*h floats        (25,600 at default size)
    :1331 relief stamps                 (no-op: no marker in current dump)
    :1340 _decode_tile_indices()        (w*h loop, :1049)
    :1341 _load_atlas()                 -> world3d_terrain.gd:605-691
      :618  manifest JSON read
      :628  desert remap JSON read
      :629  load(tile_atlas_loader.gd); :643/:648 instantiate (default "single")
      :651  _atlas_loader.call("load")   -> tile_atlas_loader.gd:174-200
        :188 _load_single()
          :282 _load_image_at() -> :325 img.load()   [180 MB PNG -> 512 MiB RGBA8]
          :285 ImageTexture.create_from_image(_prepare_atlas_image(img))
               -> :350-356 _prepare_atlas_image()
                  :351 has_mipmaps() guard (false for Image.load PNG)
                  :353 img.generate_mipmaps(false)  [+171 MiB CPU mip chain]
               [create_from_image = main-thread GPU upload of the full chain]
          :288 _load_masks() -> :482-494 (alpha.png + alphavert.png decode)
      :661  atlas_grid from manifest
      :664-672 masks -> _repack_mask_alpha() :694-707
             :703-706 nested per-pixel GDScript loop:
                     512*256 + 1024*512 = 655,360 get_pixel/set_pixel pairs
      :681  get_atlas_texture() for the `tile_atlas` sampler
             [:682-687 array-mode fallback creates a SECOND split loader -> a second
              full atlas decode + mip build if single returns no 2D texture]
    :1360 splat/albedo PNG load (+ fallback :1362)
    :1371-1380 resize verts/norms/uvs/uvs2/inds arrays
    :1388-1518 per-cell mesh loops (w*h cells, then (w-1)*(h-1) index quads);
               per cell: _face_mode_at :788, _relief_face_at :829, _donor_cliff_name :885,
               _donor_shore_name :919, _tilt_face_normal :965 -> _normal_at :981
    :1527-1528 ArrayMesh.new() + add_surface_from_arrays()
    :1535  _tileindex_material() :714-754 (shader load + sampler params)
    :1561  _make_water3d() :1169 (water3d.gd load + build) -> fallback _make_water :1134
    :1564  _make_environment() :1194
  world3d.gd:640-642  entities.bind(game) -> world3d_entities.gd:362
                      (manifest parse :391-405) + _reconcile_entities() :329-410
                      (one add_unit/add_building/add_resource per live sim entity/node)
  world3d.gd:643-646  fx.bind(game) -> world3d_fx.gd:310 (_ensure_roots :319 etc.)
  world3d.gd:647-650  fog.bind(game), anim.bind(game, entities)
main.gd:589 add_child(world)            (whole 3D subtree attaches here)
```

### OBSERVED facts about the atlas path at HEAD

- `tile_atlas_loader.gd:353` still calls `img.generate_mipmaps(false)`; the guard at `:351`
  only skips sources that already carry mips (PNG via `Image.load()` does not).
- `_load_single()` (`:280-290`) and `_load_split()` (`:416`) both route through
  `_prepare_atlas_image()`. `MODE_ARRAY` (`:427-479`) builds a `Texture2DArray` without mips,
  but `_load_atlas()` `:682-687` then creates a dedicated split loader for the shader sampler —
  so array mode can pay for **two** atlas decodes/mip builds. UNVERIFIED in practice (default
  mode is `single`, `world3d_terrain.gd:288/:336`; no `terrain/tile_atlas_mode` override found in
  `project.godot` or `config.gd`).
- `terrain.invalidate()` (`world3d_terrain.gd:1250-1293`) nulls `_atlas_loader` and
  `_atlas_texture`, so a scene restart (HUD menu → reload, `main.gd:633-634`) rebuilds the atlas
  and mips from scratch. No cross-load cache exists.
- `tile_index_atlas.png` on disk is **179,912,941 bytes** (measured with `Get-Item` in this
  audit); `.import:26-27` has `mipmaps/generate=true`, `mipmaps/limit=-1`. The `.import` flags
  do **not** apply to the runtime `Image.load()` path (G17 §1.2/§3.2) — they only affect editor
  reimport (timing UNVERIFIED).

---

## 3. G17's +171 MiB mip-chain finding, placed on the timeline

G17 §3.1 (DERIVED from OBSERVED 16384×8192 dimensions) — reproduced for traceability:

| Level | Bytes |
|---|---:|
| L0 | 536,870,912 (512.0 MiB) |
| L1 | 134,217,728 (128 MiB) |
| L2 | 33,554,432 (32 MiB) |
| L3 | 8,388,608 (8 MiB) |
| L4 | 2,097,152 (2 MiB) |
| L5…L13 | ~1.0 MiB total |
| **Full chain** | **≈682.7 MiB** |
| **Added by B02** | **≈170.7 MiB (+33 %)** |

Consequences for this ticket:

1. **Where it lands:** `tile_atlas_loader.gd:353` runs inside the single synchronous step 7
   chain (`main.gd:584-589` → `world3d.gd:639` → `world3d_terrain.gd:1341/651` →
   `tile_atlas_loader.gd:285`). G17 §1.3 described this as the same structural cause as owner
   symptom S3. At HEAD the call chain is unchanged even though `main.gd` gained its
   readiness/frame-hold fixes. **INFERRED** from code; windowed drag **UNVERIFIED**.
2. **Memory traffic:** `generate_mipmaps(false)` must read 512 MiB of L0 and write ~171 MiB of
   smaller levels (≥683 MiB traffic) *after* the 180 MB PNG → 512 MiB decode; then
   `ImageTexture.create_from_image()` at `:285` hands ~683 MiB to the GPU on the main thread.
   G17's theoretical floor is 35–70 ms, realistic range hundreds of ms to a few seconds because
   the build is believed single-threaded (**INFERRED — Godot implementation not inspected**).
   Every one of these figures is **UNVERIFIED** here: no profile, no `nvidia-smi`, no run.
3. **VRAM capacity:** 683 MiB is ~33 % of a 2 GB MX130; a serious allocation risk on 1 GB
   (**INFERRED** from G17 §3.1; exact board VRAM and resident set **UNVERIFIED**). This is a
   hardware/capacity risk, not a per-frame throughput saving — G17 §5 says do not remove mips,
   `textureGrad` or `filter_linear_mipmap` to "fix" startup, because that restores the artifact
   the visual wave just removed.
4. **Not a post-hide task:** the mip build and `create_from_image` complete before `main.gd:676`.
   It is a **stage-body** stall (S3), not a post-hide stall (S4). Any GPU-side first-draw
   consequence of the upload remains **UNVERIFIED**.

---

## 4. Owner complaints S3 / S4 vs the current code

Recorded in `UX_LOADING.md:32-35` (`PROGRESS.md:106-109`):

- **S3 — "loading freezes the Windows window (cannot move it)."**
  Cause is structural and **still present at HEAD**: stage bodies are single main-thread blocks
  (`main.gd:563-581`, `:587-589`, `:597-619`, `:622-662`); `_loading_tick()` awaits only between
  them (`:531-532`). The loader comment at `main.gd:555-558` acknowledges this explicitly. B02's
  mip build (§3 above) is **new main-thread work added to the worst stage**, so S3 is plausibly
  worse than the snapshot UX_LOADING described. **INFERRED** (call chain + byte counts);
  windowed title-bar drag **UNVERIFIED**.
- **S4 — "after the loading screen disappears something is still loading and blocks normal use."**
  The current `main.gd` **has landed mitigations** that post-date UX_LOADING's snapshot:
  `load_ready` (`:157`, reset `:464`, set `:675`), warm `world.sync(0.0)` (`:661-662`) and a
  `frame_post_draw` hold (`:667-670`). So the original "overlay hidden before the last
  subsystem touched" ordering risk is substantially closed by *ordering plus one drawn frame*.
  Two gaps remain: (a) `load_ready` is a passive flag — `_process()` (`main.gd:1587-1675`) never
  checks it, and `_hide_loading()` (`:676`) is still unconditional with no assertion over
  world/HUD/input/FX readiness (UX_LOADING R4, `:70`); (b) lazy GPU work after the first draw is
  **UNVERIFIED**. Also note sim ticks start at `:647` (ais non-empty) while the overlay is still
  up — work happens *behind* the overlay, not after it. **INFERRED / UNVERIFIED**.
- **R3 acceptance** (drag title bar at every stage, `UX_LOADING.md:69,77-82`) must be re-run at
  the `0.90 "Loading art..."` stage specifically; it is the stage most likely to freeze. No
  such windowed observation exists in this audit.

---

## 5. Top 3 startup blockers (ranked) and minimal disjoint fixes

Ranking is by *expected main-thread block magnitude × likelihood*, all **INFERRED / UNVERIFIED**
(no profile exists). Fix ownership respects WAVE_G_CHARTER: P10→`anim3d.gd`, P11→
`world3d_entities.gd`, P12→`hud.gd`+`hud3d_adapter.gd`; the three fixes below touch **none** of
those files and need new tickets assigned by COORD.

### Blocker 1 — synchronous atlas decode + CPU mip chain + 683 MiB upload inside one stage

- **Exact sites:** `main.gd:584-589` (stage body, overlay up) → `world3d.gd:637-639` →
  `world3d_terrain.gd:1341`, `:651` → `tile_atlas_loader.gd:188`, `:282-285`, `:320-325`,
  `:350-356` (mip build at `:353`), plus the double-load fallback at
  `world3d_terrain.gd:682-687`.
- **Why #1:** it is the only newly added large cost (G17: +171 MiB / +33 % VRAM), it is a single
  synchronous block, it includes a 180 MB PNG decode and a ~683 MiB GPU hand-off, and it is
  nested inside the stage the owner already complained about. Magnitude **hundreds of ms to
  several seconds** — **UNVERIFIED**.
- **Minimal disjoint fix (owner: tile_atlas_loader.gd — future loader ticket, not P10-P12):**
  in `_prepare_atlas_image()` `tile_atlas_loader.gd:350-356`, run `generate_mipmaps(false)` in a
  `WorkerThreadPool` task and construct the `ImageTexture` on the main thread only after it
  completes; keep `create_from_image` and the level-0 bytes byte-identical so the B01 seam fix,
  the 16×8 grid and the index mapping do not change. Alternative with zero runtime mip cost:
  ship a pre-mipped source so `has_mipmaps()` at `:351` short-circuits — but that changes the
  asset pipeline and needs an art/parity decision. G17 §5 #1 flags the worker route as the
  highest-value change and warns that `Image` thread-safety / upload ordering need verification.
  Caller impact is at most one await/additional poll in `main.gd:584-589` (LOAD-ASYNC owner) —
  keep that change separate so file ownership stays disjoint. Risks **UNVERIFIED**.

### Blocker 2 — the whole `terrain.build()` body (full-grid mesh + mask repack + water) is one unsliced block

- **Exact sites:** `world3d.gd:639` ("ONE full-grid mesh; no chunk scheduling") →
  `world3d_terrain.gd:1301`, height decode `:1320-1324`, tile decode `:1340`, `_load_atlas`
  `:1341`, splat load `:1360`, mesh loops `:1388-1518`, mesh upload `:1527-1528`, material
  `:1535`, water `:1561`, environment `:1564`; **mask repack** `:671-672` → `:694-707`
  (655,360 `get_pixel`/`set_pixel` pairs).
- **Why #2:** even after Blocker 1 is fixed, this remains a monolithic synchronous stage at a
  default 160×160 grid (`data.gd:33-34`) with ~25.6 k vertex evaluations plus neighbour-sampling
  helpers per cell, and a GDScript per-pixel loop over two mask images. Expected **tens–hundreds
  of ms** — **INFERRED / UNVERIFIED**. It is the largest single *stage body* by line count and
  helper-call density.
- **Minimal disjoint fix (owner: world3d_terrain.gd — terrain file owner, disjoint from loader
  and main.gd):** hoist the two repacked masks out of `invalidate()`'s rebuild path into a
  season-keyed module cache (they are season-stable, so repeats after scene reload skip
  `:703-706` entirely), and/or replace the per-pixel `get_pixel`/`set_pixel` pairs with a bulk
  image operation. If the mesh loop still dominates after profiling, yield between row bands so
  the stage can be amortised — but that changes stage granularity and needs its own atom.
  Byte-for-byte visual output must be preserved; **no test weakening**. Benefit **UNVERIFIED**.

### Blocker 3 — mapgen stage bodies are unsliced (S3 window freeze); readiness still unasserted (S4)

- **Exact sites:** `main.gd:561,564,567,570,573,576,579` (the `_loading_tick` calls) and the
  stage bodies they bracket at `:563,566,569,572,575,578,581`; `_loading_tick()` awaits only at
  `:531-532`. Readiness: `load_ready` `:157/:675` is never read by `_process()` `:1587-1604`;
  `_hide_loading()` `:676` has no subsystem assertion; `_process()` begins sim at `:647`.
- **Why #3:** this is the *structural* cause of owner S3 and it predates B02 — each mapgen stage
  owns the main thread for its whole duration, so the Windows title bar cannot move even though
  the progress bar advances between stages. S4 is largely mitigated at HEAD (§4) but the
  assertion gap is real. Expected per-stage **tens–hundreds of ms** — **INFERRED / UNVERIFIED**.
- **Minimal disjoint fix (owner: main.gd — LOAD-ASYNC owner, disjoint from loader/terrain and
  from P10-P12):** keep stage order and all calls byte-identical, but move the heaviest pure-sim
  stage(s) into `WorkerThreadPool` tasks (or split them into row-band chunks with an await each)
  so the message pump runs *during* the stage; and add a single explicit readiness gate before
  `_hide_loading()` (`:675-676`) that checks world/terrain `_built`, HUD, input and audio are
  non-null, closing UX_LOADING R4. Do **not** edit `game.gd` (B03 ownership) — call the existing
  stage methods from `main.gd` only. Windowed drag test per `UX_LOADING.md:77-82` is required;
  result **UNVERIFIED**.

### Explicitly NOT recommended (G17 §5 #5)

Do not remove mips, revert `filter_linear_mipmap` to nearest, or drop `textureGrad` to speed up
startup — each restores one of the ranked artifact causes. Do not enable MSAA/anisotropy as a
substitute (`project.godot` sets neither; G17 §4). Lowering `mipmaps/limit` saves only a few MiB
because each level is ≤1/4 of its parent.

---

## 6. UNVERIFIED register — what must be measured before any claim

1. No Godot run, no capture, no frame time, no VRAM read. **All** times/sizes in §1-§5 are static
   or arithmetic, not measurements. FPS claims require a real capture/run (WAVE_G_CHARTER
   Wave P: "measured FPS claims require a real capture/run and are UNVERIFIED without one").
2. Whether `ImageTexture.create_from_image()` (`tile_atlas_loader.gd:285/:416`) uploads the full
   ~683 MiB chain synchronously at that line, or defers it to first draw — **UNVERIFIED**; this
   decides whether Blocker 1 is a stage-body stall or also a first-draw stall.
3. Whether Godot 4.x `generate_mipmaps(false)` is single-threaded and its actual cost on this
   CPU — **UNVERIFIED** (G17 §7 #3).
4. Exact MX130 board VRAM/clock and the rest of the resident VRAM set — **UNVERIFIED** (G17 §7 #2).
5. Cost of `_repack_mask_alpha()` `:703-706` and of the per-cell mesh loops `:1388-1518` on this
   machine — **UNVERIFIED**.
6. Whether any work continues after `main.gd:676` beyond ordinary `_process()` sync —
   **UNVERIFIED**; the warm sync + `frame_post_draw` mitigations are code-order evidence only.
7. `G23_loading_design.md` unavailable on disk (§0) — any G23-specific requirement is **UNVERIFIED**.
8. Donor parity remains **UNVERIFIED** throughout (CHARTER §3); nothing in this report compares
   to a donor frame.

**Measurement hook already in tree (OBSERVED):** `main.gd:1640-1647` prints
`PERF tick_ms=… ai_ms=… sync_ms=… steps_per_frame=…` every 120 frames. It measures sim/AI/sync,
**not** loading-stage time, render time or texture upload. P09 needs per-stage stopwatches around
`main.gd:563-662` plus a windowed drag observation; this audit supplies no such numbers.

---

## 7. Summary for COORD

- The interactive 3D startup is time-sliced only **between** stages (`_loading_tick()`
  `main.gd:526-533`); every stage body, including the entire 3D bind, is synchronous on the
  main thread with the overlay still visible (`main.gd:543` → `:676`).
- The single worst block is `main.gd:584-589` → `world3d.gd:637-639` →
  `world3d_terrain.gd:1341/651` → `tile_atlas_loader.gd:285/353`: 180 MB PNG decode, a CPU mip
  build adding ~171 MiB / +33 % VRAM (G17), and a ~683 MiB texture hand-off — all before
  `_hide_loading()` at `:676`. All magnitudes **UNVERIFIED**.
- Owner **S3** (window freeze) remains structurally explained by unsliced stage bodies and is
  plausibly worsened by B02's mip build. Owner **S4** (post-hide block) has landed mitigations
  at HEAD (`load_ready` `:675`, warm sync `:662`, `frame_post_draw` `:668`) but still lacks an
  explicit readiness assertion; residual GPU work is **UNVERIFIED**.
- Ranked blockers: **(1)** loader mip/decode (fix in `tile_atlas_loader.gd`), **(2)** terrain mesh
  + mask repack (fix in `world3d_terrain.gd`), **(3)** unsliced mapgen + readiness gate (fix in
  `main.gd`). All three are disjoint from P10/P11/P12 and need new tickets; none was implemented
  here.

*End of P06 report.*
