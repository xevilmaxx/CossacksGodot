---
id: G23-LOADING-DESIGN
ticket: TERRAIN-SWARM-WAVE-G / G23 (read-only design proposal, follow-up to B02)
date: 2026-11-25
status: PROPOSAL__READ_ONLY__NO_CODE_EDITS__NO_GODOT_JOBS
labels: [observed, derived, inferred, UNVERIFIED]
files_created:
  - docs/terrain_swarm_2026-11-25/reports/G23_loading_design.md
files_edited: []
godot_jobs_run: 0
runner_jobs_submitted: 0
primary_target_file: variant3d/scripts/tile_atlas_loader.gd
parity_guard: "No donor GPU A/B frame exists (CHARTER §3). Nothing here claims donor parity. Every throughput/time/capacity figure is an analytical estimate carried over from G17 and stays UNVERIFIED until profiled on a real windowed run."
---

# G23 — minimal safe design: move atlas mipmap generation off the loading main thread

## 0. Scope compliance

Read-only. Exactly one file created (this report). No code, shader, config, manifest, test or
runner file was edited; no Godot process was started and no runner job was submitted
(WAVE_G_CHARTER § "Only G04 submits runner jobs"). No backup was taken and no edit was made —
backups are a **requirement of the future implementation ticket**, specified in §7.

Inputs read in full: `docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md`,
`docs/terrain_swarm_2026-11-25/CHARTER.md`, `reports/G17_perf_audit.md`,
`docs/coord_swarm_2026-11-25/UX_LOADING.md`. Grounding verified by direct read:
`reports/B02_atlas_impl.md`, `variant3d/scripts/tile_atlas_loader.gd` (all 494 lines),
`variant3d/scripts/world3d_terrain.gd` (`:600-729`, `:1295-1364`, symbol search),
`variant3d/scripts/main.gd` (`:500-694`), and
`variant3d/assets/terrain/atlas/tile_index_atlas.png.import`.

This is a **PROPOSAL only**. It is a follow-up to B02, whose exclusive file is
`variant3d/scripts/tile_atlas_loader.gd`; that file is the primary target of the proposed
change. Companion one-line awaits in two other-owned files are identified in §5 as separate
handoffs for COORD integration — they are described, not performed.

> **Snapshot note.** `UX_LOADING.md` and `G17_perf_audit.md` were written against an **older**
> `main.gd`. The on-disk `main.gd` now contains LOAD-ASYNC-01 additions (`load_ready`,
> `await RenderingServer.frame_post_draw`, readiness comment at `:665-676`). This proposal
> uses the on-disk state. Any future implementer must re-read before acting — reports are
> fixed artifacts, not live state.

## 1. OBSERVED — the code that matters, as on disk now

### 1.1 The exact synchronous call chain (OBSERVED)

`main.gd:584-589`:

```
if not await _loading_tick(0.90, "Loading art...", gen): return
if render_mode == "3d":
    world = make_world3d()
    world.bind(game)          # synchronous
    add_child(world)
```

`world.bind()` → `world3d.gd:639 terrain.build()` (comment: "ONE full-grid mesh; no chunk
scheduling") → `world3d_terrain.gd:1301 build()` → `:1341 _load_atlas()` →
`:651 _atlas_loader.call("load")` → `tile_atlas_loader.gd:174 load()` → `:285` (`_load_single`)
or `:416` (`_load_split`) → `:350-356 _prepare_atlas_image()` →
`img.generate_mipmaps(false)`.

`_loading_tick()` (`main.gd:526-533`) awaits two `process_frame`s **before** the stage body,
not inside it. Therefore the whole 0.90 body — mip build **and** the subsequent
`ImageTexture.create_from_image()` upload — runs in one main-thread frame. This is the
structural cause G17 §1.3/§3.2 links to owner symptom S3.

### 1.2 The mip call and its invariants (OBSERVED)

`tile_atlas_loader.gd:350-356`:

```
func _prepare_atlas_image(img: Image) -> Image:
    if img.has_mipmaps():
        return img
    var err := img.generate_mipmaps(false)
    if err != OK:
        push_warning("... mipmap generation failed ...")
    return img
```

- Called **only** from `_load_single():285` and `_load_split():416`.
- `_load_array():427-479` is untouched; it has no mips (pre-existing correctness gap, G17 §3.2).
- Level 0 is not written by `generate_mipmaps`; B02 §4/§7 states level-0 pixels are
  byte-identical, and the single → split → array order, `_soft_fail` warnings, SHA-256 /
  byte-count reassembly, 16×8 manifest grid, index→slot maps, `manifest_path` /
  `single_atlas_path` overrides, season path pair and mask loading all live **outside** this
  function.
- `get_atlas_texture() -> Texture2D` (`:208-211`) is the stable binding surface;
  `world3d_terrain.gd:681` reads it, `:683-688` provides the split fallback, and `:721`
  binds it to `mat.set_shader_parameter("tile_atlas", _atlas_texture)`.

### 1.3 Overlay and readiness, as on disk now (OBSERVED)

- `_show_loading()` / `_set_loading()` / `_hide_loading()` at `main.gd:455-524`.
- `_loading_tick()` generation guard at `:526-533` (`gen != loading_gen` → false).
- Stage labels and awaits: 0.90 `"Loading art..."` at `:584`; 0.92 `"Wiring camera..."` at
  `:594`; … 1.0 `"Ready!"` at `:663`.
- After the final stage: `world.sync(0.0)` (`:661-662`), `await _loading_tick(1.0, "Ready!")`
  (`:663`), `await RenderingServer.frame_post_draw` for non-headless (`:667-670`), then
  `load_ready = true` and `_hide_loading()` (`:675-676`). LOAD-ASYNC-01's readiness comment
  at `:671-674` enumerates the gates.

**Derived consequence:** the existing `frame_post_draw` hold already keeps the overlay up
across the *first draw*. It does **not** help with S3: the freeze happens *inside* the 0.90
stage, while the overlay is on screen but the main thread is blocked. Making mips asynchronous
therefore requires a readiness gate **at the 0.90 boundary**, not a change to `_hide_loading()`.

### 1.4 Import settings (OBSERVED)

`tile_index_atlas.png.import`: `importer="texture"`, `type="CompressedTexture2D"`,
`compress/mode=0` (lossless), `mipmaps/generate=true`, `mipmaps/limit=-1`,
`process/fix_alpha_border=true`. B02 §1/§6 notes these flags are **bypassed at runtime**
because the loader decodes with `Image.load()` rather than resource `load()`. The winter atlas
`.import` carries the same `mipmaps/generate=true` edit (B02 §3).

## 2. Problem statement — DERIVED / INFERRED, with cost labels

- **DERIVED** from §1.1 + §1.2: B02 placed a brand-new CPU job (read 512 MiB base, write
  ~171 MiB of levels; G17 §3.1 arithmetic) inside a stage the owner already reported as
  freezing the window. This is new main-thread work on the exact stage G17 §6 flags as most
  likely to regress (0.90). Expect it to **worsen S3** — INFERRED (call chain + byte counts),
  **window drag UNVERIFIED**.
- **INFERRED / UNVERIFIED, carried from G17, not re-measured here:** theoretical floor
  ~35–70 ms at 10–20 GB/s; realistic single-threaded box-filter range "hundreds of
  milliseconds to a few seconds"; full-chain VRAM ≈683 MiB (+171 MiB, +33 %). None of these
  is a benchmark. They stay UNVERIFIED until profiled (§6 acceptance A6).
- **INFERRED residual risk:** even after moving mips off-thread,
  `ImageTexture.create_from_image()` still uploads ~683 MiB on the main thread inside the
  same stage. Removing the CPU build reduces the stall; it does not prove the window is
  draggable. The windowed drag test judges the **whole stage**, not just the mip step.
- S4 (work after overlay disappears) is a separate readiness/ordering symptom
  (`UX_LOADING.md` §1). The current on-disk `main.gd` already has LOAD-ASYNC-01's final hold;
  this proposal must not regress it, and must add an async-completion gate before it.

## 3. Proposal — invariants that must survive the fix

Any implementation of this ticket must preserve, verbatim (all OBSERVED today):

1. **Pixel bytes:** level-0 atlas Image is unchanged; mips are derived from the same decoded
   pixels with `generate_mipmaps(false)` (no renormalise, no synthetic dither/noise —
   CHARTER §3 / decision S-25-09). No colour value is invented.
2. **Fallback semantics:** `single → split → array` order, `_soft_fail` warning behaviour,
   SHA-256 + byte-count verification of the reassembled cache, "missing PNG" probe via
   `single_atlas_path`, and `_shader_atlas_loader` split fallback in
   `world3d_terrain.gd:683-688` all remain unchanged.
3. **Mode/planar contract:** `atlas_grid()` (16×8 from manifest), `get_index_to_slot()` /
   `get_slot_to_index()`, `tile_uv()` / `tile_layer()`, `get_reassembly_info()`, SP-5
   `manifest_path` / `single_atlas_path` overrides and SP-6 season pair are untouched.
4. **Bindings:** sampler names `tile_atlas` / `alpha_atlas` / `alphavert_atlas` and their
   assignment at `world3d_terrain.gd:721-724` are unchanged. Mask textures stay mip-less and
   `filter_nearest`. No shader edit.
5. **Sync callers:** headless/test modes call the synchronous `load()` and are unchanged in
   timing and return value. No test weakening; gates keep their thresholds.
6. **2D `app/` untouched** (CHARTER §5 item 3). No donor-parity claim.

## 4. Options

### Option A — RECOMMENDED: worker-thread mip build, added inside `tile_atlas_loader.gd`

The single substantive change is in B02's file. `generate_mipmaps(false)` is called on the
**same decoded local `Image`**, just on a `WorkerThreadPool` worker instead of the main
thread; `ImageTexture.create_from_image()` is still called on the main thread afterwards.
Because the operation and its input are identical, invariant 1 holds **by construction** —
only the executing thread changes.

Additive API sketch (GDScript, **uncompiled sketch — syntax/await semantics to be verified by
the implementer**; all thread-safety claims UNVERIFIED until profiled):

```
# tile_atlas_loader.gd — additive; existing load()/get_atlas_texture() kept intact
var _async_img: Image = null
var _async_task: int = -1
var _async_err: int = OK

func _build_mips_worker() -> void:
    if _async_img == null or _async_img.has_mipmaps():
        return
    _async_err = _async_img.generate_mipmaps(false)   # same call, same bytes

func load_async(p_tree: SceneTree, p_mode: String = "") -> bool:
    # Mirror load()'s mode resolution AND the single -> split -> array fallback order.
    # At the two sites that currently call _prepare_atlas_image(img):
    #   _async_img = img
    #   _async_task = WorkerThreadPool.add_task(Callable(self, "_build_mips_worker"))
    #   if p_tree == null:
    #       WorkerThreadPool.wait_for_task_completion(_async_task)   # headless/sync only
    #   else:
    #       while not WorkerThreadPool.is_task_completed(_async_task):
    #           await p_tree.process_frame                       # main thread stays free
    #   if _async_err != OK: push_warning(...)                    # same warning as :355
    #   _atlas_texture = ImageTexture.create_from_image(_async_img)  # MAIN thread
    # ...then the same masks/_loaded bookkeeping as load().
```

Design rules for the implementer:

- Keep `_prepare_atlas_image()` **unchanged** for synchronous callers; do not silently turn
  `load()` into a coroutine (it is called via `loader.call("load")` and expected to return a
  bool at `:651`). Add `load_async()` as a separate entry point.
- The `Image` must not be touched by the main thread while the task runs. Keep a strong
  reference (`_async_img`) for the task's lifetime; do not free/reset the loader until
  completion. `call_deferred` any signal emission back to the main thread — worker threads
  must not emit signals or touch the SceneTree.
- **Generation guard:** every `await` in the async path must be followed by the same
  `gen != loading_gen` check pattern used at `main.gd:547-548` etc., so a superseded Start
  click cannot bind a stale atlas or hide the overlay.
- Guarded degradation: if `WorkerThreadPool.add_task()` fails or the task reports an error,
  fall back to the existing synchronous `_prepare_atlas_image()` and emit the same warning —
  correctness first, S3 improvement second.
- Backup before edit: `inbox/backup/tile_atlas_loader.gd.bak-G23` (matching
  `.bak-B02` / `.bak-SP05` convention).

**Thread-safety / upload-ordering caveat:** Godot `Image` operations from a worker thread and
the exact cost of `generate_mipmaps(false)` are **UNVERIFIED** (G17 §7 item 3; B02 §6 item 3).
The implementation ticket must verify on a real windowed run before claiming the freeze is
fixed. This is why the label stays UNVERIFIED in this proposal.

### Option B — alternative: import-time mips (lower churn, narrower fix)

The `.import` flags are **already** `mipmaps/generate=true`, `compress/mode=0`, `limit=-1`
(§1.4) — B02 landed them but they never reach the runtime path. A one-file mitigation would
make `_load_single()` use the imported `CompressedTexture2D` (`load(single_atlas_path)`) when
it is available and correctly sized, falling back to the current `Image.load()` +
`_prepare_atlas_image()` path otherwise. `world3d_terrain.gd`, `main.gd` and the overlay need
**no** async changes; the 683 MiB upload remains but the CPU mip build disappears.

Limits, all **UNVERIFIED**:

- Covers **MODE_SINGLE only**. MODE_SPLIT reassembles to `user://` and has no import artifact,
  so it would keep the synchronous mip build — the fallback path would still freeze.
- Depends on `.godot/imported/*.ctex` being present and fresh; a stale/missing import yields a
  placeholder texture. Requires a guard (`get_size() == 16384×8192`, valid resource) and a
  real editor/`--import` reimport (B02 §6 item 4 — never run).
- Whether `process/fix_alpha_border=true` alters level-0 bytes is unverified; invariant 1
  must be checked by pixel comparison, not assumed.
- Switching from `Image.load()` to resource `load()` changes the transport mechanism and the
  path-with-spaces robustness comment at `:320-323`; verify before adopting.

**Recommendation:** use Option A as the fix (applies to both atlas modes, preserves transport
and byte semantics by construction). Keep Option B documented as a possible single-file
emergency mitigation for the common path only, not as the general solution. Do **not** do both
simultaneously — a fixed tree must have one mip source, or level-0 provenance becomes
ambiguous.

## 5. Companion handshakes required by Option A (describe only — other owners)

A loader-only edit cannot guarantee mips are ready at bind time: `world3d_terrain.gd:681/721`
grabs and binds `_atlas_texture` immediately after `load()` returns. The following minimal,
mechanical awaits are therefore **required** but belong to other-owned files and must be
separate tickets integrated by COORD — this agent did not touch them.

1. `variant3d/scripts/world3d_terrain.gd` (B04's file): `_load_atlas()` (`:605`) calls
   `await loader.load_async(get_tree())` instead of `_atlas_loader.call("load")` at `:651`;
   `build()` (`:1301`) awaits `_load_atlas()` at `:1341`; `bind()` awaits `build()` at `:639`.
   No logic, thresholds or names change — only `async`/`await` at three existing call sites.
2. `variant3d/scripts/main.gd` (LOAD-ASYNC-01's file): the 0.90 stage (`:586-589`) awaits
   `world.bind(game)`; the existing generation guard and the 0.92 onward stages stay as they
   are. The final `frame_post_draw` hold and `load_ready` gate (`:663-676`) stay **untouched**.

Alternative with fewer awaited signatures: keep `build()`/`bind()` synchronous and expose one
`await world.atlas_ready()` at the end of the 0.90 stage that waits for the loader task and
re-binds the material — but that adds a second texture-binding path and a double-upload risk,
so the straightforward await chain above is preferred.

### How the overlay stays visible until ready

- The overlay (`CanvasLayer` 30) is shown at `:543` and removed only at `:676`.
- The 0.90 stage must not complete until `load_async()` has finished its worker task **and**
  `ImageTexture.create_from_image()` has run on the main thread. Because the caller awaits,
  the stage body cannot fall through to 0.92 while mips are in flight.
- After 1.0, the existing `await RenderingServer.frame_post_draw` (`:667-670`) still holds the
  overlay for one fully drawn frame, so the first draw of the now-mipped texture stays behind
  it. Do not weaken or remove this hold.
- Generation guard after every new `await`: if `gen != loading_gen`, return without hiding.
- No readiness flag is removed or reordered; `load_ready = true` remains immediately before
  `_hide_loading()` (`:675-676`), matching `UX_LOADING.md` R4/R5.

## 6. Acceptance criteria (all UNVERIFIED until actually run)

- **A1 — window drag at 0.90 (primary, `UX_LOADING.md` R3 / G17 §6 R3).** Launch **windowed**
  via `launch_variant3d.bat` (never a runner job for a windowed game). Click Start. When the
  overlay label reads `"Loading art..."` (`main.gd:584`), drag the title bar **continuously for
  the whole duration of that stage**. The window must move without a frozen frame; the bar
  must advance to 0.92 `"Wiring camera..."` without a stall. Record the stage label and repeat
  at least three times: cold cache, warm cache, and forced split fallback
  (`single_atlas_path` probe). Any blocking stage is a FAIL — record the label, do not accept
  "two awaited frames between stages" as proof (§1.3). Status: **UNVERIFIED / PENDING**.
- **A2 — byte/pixel honesty.** Same seed, same scene: compare the on-screen output and the
  atlas `get_image()` level-0 bytes before vs after the change; require identical level-0
  pixels, unchanged `atlas_grid`, unchanged tile histogram, and unchanged seam metrics
  (`full_width_dark_rows == 0`, `dark_cols == 0`, luma floors from B02 §6 item 2). This is the
  guard on invariants 1 and 3. Status: **UNVERIFIED**.
- **A3 — fallback chain.** Missing-single probe → split; missing-split probe → array. Verify
  `_atlas_mode_loaded`, `get_reassembly_info()` and warnings are unchanged, and that no
  synchronous mip build remains on the main thread in split mode after the fix. Status:
  **UNVERIFIED**.
- **A4 — overlay readiness (R4/R5).** Inject a deliberately slow mip task; the overlay must
  remain visible until the task completes and `load_ready = true`; a superseded Start click
  must not hide it. Status: **UNVERIFIED**.
- **A5 — gates unchanged.** On a quiet, strictly serial queue: selftest 29/29, uitest 17/17,
  `t_render_mode`, `assert_clean.py --json` CLEAN; 2D `app/` untouched; no threshold, seed or
  `expected_pre_fix_failure` changed (`UX_LOADING.md` §6). Status: **UNVERIFIED / PENDING**.
- **A6 — retire the UNVERIFIED labels.** Instrument mip-build wall time (main-thread vs worker)
  on the real MX130 windowed context (`AUDIT3D_09_runtime_proof.md:27`) and report measured
  numbers. Until A1 and A6 pass, every time/bandwidth/capacity figure in G17 §2–§3 and §3.2
  remains an estimate, **not** a result, and the freeze fix is **not** claimed.

## 7. Handoff summary

| Item | Owner / file | Action | Status |
|---|---|---|---|
| Primary change | `variant3d/scripts/tile_atlas_loader.gd` (B02 follow-up) | Add worker-thread `load_async()`; keep sync `load()` and all fallback logic untouched; backup `inbox/backup/tile_atlas_loader.gd.bak-G23` | PROPOSED, not done |
| Companion awaits | `world3d_terrain.gd` (B04), `main.gd` (LOAD-ASYNC-01) | 3 + 1 mechanical `await` at existing call sites; no logic change | DESCRIBED, not done |
| Windowed drag at 0.90 | G04 (sole runner/windowed evidence owner) | A1 + A6, fresh unique id | UNVERIFIED / PENDING |
| Gates | COORD final gate, strictly serial | A5 | UNVERIFIED / PENDING |

**Bottom line:** the minimal safe fix is Option A — keep B02's exact level-0 pixels, mode
fallback and bindings, move only the `generate_mipmaps(false)` call to a `WorkerThreadPool`
worker, and await that completion inside the 0.90 `"Loading art..."` stage so the overlay
stays up until the mipped texture is bound. It is a follow-up to B02's file plus three small
owned handshakes. No freeze improvement, byte identity, gate result or donor parity is claimed
here: all remain **UNVERIFIED** until the windowed drag test and profiling land.

*End of G23 report.*
