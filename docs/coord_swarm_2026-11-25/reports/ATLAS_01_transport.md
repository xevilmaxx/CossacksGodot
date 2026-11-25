---
id: ATLAS-01
task: "M11 — verify the 3D tile-atlas transport fallback modes and document the 180 MB LFS risk"
agent: ATLAS-01
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB__NO_DONOR_COPY
scope: "One report only. Read-only filesystem + existing artifacts; no code, asset, config, test or git edit; no Godot job; no donor access."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
output: "docs/coord_swarm_2026-11-25/reports/ATLAS_01_transport.md"
labels: [observed, derived, inferred, UNVERIFIED]
verification_passes: 2
visual_parity_claim: false
parity_guard: "No GPU A/B and no fresh-clone run was executed in this lane. Every cross-mode visual-equivalence statement is derived from code/hashes or UNVERIFIED."
note: "Citations re-verified against the loader AFTER a parallel SP-5 edit added `manifest_path` (455 -> 470 lines). `world3d_terrain.gd` and the shader line numbers were re-checked and unchanged."
---

# ATLAS-01 — Tile-atlas transport fallback modes and the 180 MB LFS risk

## 0. Label key and discipline

- **observed** — read directly this lane from a repo file, a git object, or a measured byte/hash.
- **derived** — deterministic consequence of observed code/hashes (e.g. reassembly hash equality ⇒ lossless transport).
- **inferred** — interpretation with a stated caveat; no runtime execution backs it.
- **UNVERIFIED** — cannot be proven from readable data (e.g. remote LFS object availability, donor engine transport).

Every headline number was counted/hashed twice by two different means (§3, §8). "Mode" below means a transport of the *same* donor-grounded V7-85 atlas, never a different art set; no donor parity is claimed for any transport (DTRN-01 M11: `DTRN_01_donor_terrain_pipeline.md:409`).

## 1. Sources

**Task-named reports / docs (all read in full this lane):**

| # | Path | Role |
|---|---|---|
| S1 | `docs/coord_swarm_2026-11-24/reports/V785_tile_atlas.md` | A1 single PNG + manifest + masks; `:48-57` sizes/hashes, `:59-192` 124-cell layout, `:238-245` UNVERIFIED items, `:251` open LFS question |
| S2 | `docs/coord_swarm_2026-11-24/reports/V791_dual_mode_atlas.md` | split parts + loader; `:38-52` zip-vs-split, `:54-78` manifest/masks, `:80-106` API, `:111-146` job history, `:196-274` single restored / default / GitHub caveat |
| S3 | `docs/coord_swarm_2026-11-25/reports/V3D_02_terrain_render_audit.md` | P12 `:97`; "already correct" #10 `:113`: single→split→array, big PNG and parts both on disk |
| S4 | `docs/coord_swarm_2026-11-25/reports/DTRN_01_donor_terrain_pipeline.md` | M11 `:409`; recipe #10 `:480-482`; Q6 `:504-506` |
| S5 | `docs/coord_swarm_2026-11-25/decomp/DEC_05_terrain_formats.md` | donor has no transport: `:126-138` (112 `.dds` + 3 `.bmp`), `:326-399` `.map` records, `:507-519` corrections; text configs, not a binary atlas/transport |
| S6 | `variant3d/scripts/tile_atlas_loader.gd` | re-read in full, **470 lines** after a parallel SP-5 edit — loader under audit |
| S7 | `variant3d/scripts/world3d_terrain.gd` | `:249-255,273-332,461-536,543-582,1216-1233,1313,1389-1401` — wired binding layer (re-checked current) |
| S8 | `variant3d/shaders/terrain_tileindex.gdshader` | `:60,66,72,83,91,325-330,358-371,381-413` — sampler declarations and sample sites (re-checked current) |
| S9 | `docs/coord_swarm_2026-11-25/reports/DENV_01_environment.md` | `:530,537-538,596-597` — desert ids 111–122 packed; 27 `winterN.png` explicitly unpacked |
| S10 | `.gitattributes`, `.gitignore`, `git ls-files`, `git cat-file -s`, `git show :path`, `git check-attr`, `git check-ignore`, `git lfs ls-files --all`, `git config --get-regexp '^lfs\.'` | read-only git/LFS state |
| S11 | `docs/coord_swarm_2026-11-25/reports/SEASON_PLAN_01.md` | `:189-191,208,252` — planned winter atlas doubles LFS/disk/VRAM burden (context only) |

Prior reports are treated as claims, not as evidence replacing a current read: where S1/S2/S3 and the disk disagree, the **current byte/code read wins**. During this lane a parallel agent applied SP-5 to S6 (`manifest_path` override, 455→470 lines); every S6 citation below is to the **post-edit** file, and the semantic consequence is called out in §4.1.

## 2. File inventory on disk (observed)

Project-relative paths; `variant3d/assets/terrain/atlas/` and `variant3d/assets/terrain/atlas_parts/`. All sizes are `Path.stat().st_size`; all hashes are SHA-256 of the working-tree bytes.

| File | Bytes | SHA-256 (first 12) | Supports | Notes |
|---|---:|---|---|---|
| `atlas/tile_index_atlas.png` | **179,912,941** | `a1f123a1072e…` | `single` | 16384×8192 RGBA; byte-identical to S1 §2 / S2 §9.1 |
| `atlas/tile_index_atlas.manifest.json` | 60,677 | `112e9ff5ed63…` | all three (grid + layout) | 124 rows; grid `[16,8]` |
| `atlas/alpha.png` | 55,242 | `dfaf78d0c285…` | all three (mask) | L 512×256 |
| `atlas/alphavert.png` | 167,954 | `c916ea98ddb7…` | all three (mask) | L 1024×512 |
| `atlas_parts/tile_index_atlas.part000` | **90,000,000** | `019f0f9d7ea1…` | `split` (+ array's shader fallback, §5) | raw byte slice 0…89,999,999 |
| `atlas_parts/tile_index_atlas.part001` | **89,912,941** | `295a527ce8c4…` | `split` (same) | raw byte slice 90,000,000…179,912,940 |
| `atlas_parts/split_manifest.json` | 3,061 | `7453b52cc603…` | `split` | part order/hashes; `verification.matches: true` |
| `atlas_parts/alpha.png` | 55,242 | `dfaf78d0c285…` | all three (mask) | **byte-identical** to `atlas/alpha.png` |
| `atlas_parts/alphavert.png` | 167,954 | `c916ea98ddb7…` | all three (mask) | **byte-identical** to `atlas/alphavert.png` |

Full hashes (observed): single `a1f123a1072e07eb28f416a9d8541aae5ffd23891a1836904b3cb05eb84dcfbd`; part000 `019f0f9d7ea1430131189881db58e3f3fa138eb76209d643d53e698b73dd525f`; part001 `295a527ce8c402d8c8c80775538a6a0c0e6859fa94a758194cc096db0faba1be`; alpha `dfaf78d0c285920cd2009f74476a8d4647f3666efb7c6dcf0bfd1b44487b8ef7`; alphavert `c916ea98ddb7f8ccc9a4898f324540335d4d74ee5250f4774b9769c762afd245`. All match S1 §2, S2 §2 and both manifests. **No `.import` sidecar, no extra part, no third mode asset exists in either directory** (observed via recursive listing).

`array` mode's inputs are the 112 block PNGs in `variant3d/assets/terrain/blocks/`; **0** of the 85 unique `layout[].source_png` names are missing on disk (observed). `winterN.png` files exist but are listed as `unused_shipped_blocks` (27 entries) in the V7-85 manifest — intentionally not packed (observed; S9 `:530,596-597`). Desert `desert1.png`…`desert12.png` are **packed at ids 111–122** as `DIRECT` cells (observed; S9 `:530`).

## 3. Self-consistency of split/array parts (counts verified twice)

| Check | Pass 1 | Pass 2 (different method/chunk size) | Result |
|---|---|---|---|
| `layout` entries | 124 | 124 (`sum(1 for _ in enumerate)`) | PASS |
| id set | `{0…123}`, 124 distinct | `set(range(124))` equality | PASS |
| named / filled / empty | 124 / 121 / 3 | 124 / 121 / 3 (`source_png is None`) | PASS |
| empty indices | `86, 110, 123` (`alpha0a/b/c`) | same | PASS |
| kinds | `DIRECT 85`, `FACE_BASE_REUSE 36`, `EMPTY 3` | same | PASS |
| unique `source_png` for filled cells | 85 | 85 | PASS |
| manifest `grid` / `cell_size` / `size` / `slots` | `[16,8]` / `[1024,1024]` / `[16384,8192]` / 128 | same | PASS |
| `cell_xy == (index%16, index//16)` for all rows with a cell field | True | True | PASS |
| part sizes vs `split_manifest.parts[].bytes` | `[True, True]` | `[True, True]` | PASS |
| part hashes vs manifest | `[True, True]` | `[True, True]` | PASS |
| concat(part000, part001) | 179,912,941 B / `a1f123a107…` | 179,912,941 B / `a1f123a107…` (4 MiB chunks) | PASS |
| reassembled == single PNG bytes | True | True | PASS |
| reassembled == `split_manifest.verification` | True | True | PASS |
| mask hashes equal across `atlas/` and `atlas_parts/` | `[True, True]` | — | PASS |
| array-mode missing block PNGs | `[]` | — | PASS |
| `upscaled_sources` entries | 6 (`sand1/sand2` 256²→1024², NEAREST) | — | PASS, labelled APPROX (S1 `:194`) |
| shipped tile ids resolvable | 31 distinct (manifest `shipped_tileblock`), `unresolved_ids: []` | — | PASS (S1 `:225-236`) |

Conclusion: split parts are **complete and self-consistent** (lossless byte transport, verified by hash twice); array inputs are complete; grid/cell/empty accounting agrees across both manifests and the observed disk. **derived** from hashes; no claim about GPU rendering follows.

## 4. Fallback order (loader) — `path:line` (post-SP-5 line numbers)

### 4.1 Mode resolution at construction (`observed`)

| Priority | Source | Citation |
|---:|---|---|
| 1 | ctor first arg as `String`/`Variant` (`TileAtlasLoader.new("array")`) | `tile_atlas_loader.gd:99-107` |
| 2 | ctor `Dictionary` key `tile_atlas_mode` | `:102-109`, key const `:75` |
| 3 | `ProjectSettings.get_setting("terrain/tile_atlas_mode")` (read-only) | `:110-113`, const `:74` |
| 4 | default `MODE_SINGLE` | `:80`, `:118`, `set_mode()` `:124-127` (unknown value → `single`) |

Two caller overrides are read at `:114-117`: `single_atlas_path` (const `:76`) and — **new in the parallel SP-5 edit** — `manifest_path` (const `:77`, key `manifest_path`, default `V785_MANIFEST` at `:86`). **Correction to the pre-edit state:** the V7-85 manifest path is now overridable; it is consumed by `_load_grid()` at `:313` and `_load_array()` at `:405`, while `split` still reads the fixed `SPLIT_MANIFEST` const at `:70`/`:336`. The stated default is unchanged, so the Summer chain and all disks measured here are unaffected. `single_atlas_path` exists precisely so a caller can simulate a clone without the big PNG (`:82-84`; S2 §9.4 job 250).

### 4.2 `load()` chain (`tile_atlas_loader.gd:174-200`, `observed`)

| Step | Condition | Action | Citation | On failure |
|---:|---|---|---|---|
| 0 | any explicit `p_mode` | `set_mode(target)` then `_reset()` | `:175-179` | — |
| 1 | `mode == "array"` | `_load_array()` **only** (no further fallback) | `:181-182`, `:403-455` | `_fail()` → false |
| 2 | `mode == "split"` | `_load_split()` **only** (no further fallback) | `:183-184`, `:335-397` | `_fail()` → false |
| 3 | otherwise (`single`, default) | `_load_single()` | `:186-189`, `:280-290` | `_soft_fail()` (warning, no `push_error`) `:164-168`, `:284` |
| 4 | single failed | `push_warning` → **set `mode = "split"`** → `_load_split()` | `:190-194` | warning `:191`; `_reset()` `:192` |
| 5 | split failed | `push_warning` → **set `mode = "array"`** → `_load_array()` | `:195-200` | warning `:197`; `_reset()` `:198`; returns `_load_array()` |

`get_mode()` (`:130-131`) therefore reports the **actual** mode after mutation, not the requested one. S2 §9.2 documents the same chain; S3 `:113` lists it as "already correct". **derived**: the chain only runs from `single`; asking for `array` or `split` explicitly never degrades.

Per-mode internals (`observed`):

- **single** `:280-290`: `_load_grid()` → `_load_image_at(single_atlas_path)` (`:320-332`, `res://` first, `globalize_path()` fallback) → `ImageTexture.create_from_image()` → `_load_masks()` (`:288`) → `_loaded = true`. No parts, no SHA, no `user://` write.
- **split** `:335-397`: read `split_manifest.json` (`:336`) → `_load_grid()` (`:339`) → expected hash/bytes/parts (`:340-345`) → write `user://tile_atlas_cache/tile_index_atlas.png` in 1 MiB chunks while hashing (`:78`, `:347-378`) → size+SHA check, delete cache on mismatch (`:383-386`) → decode (`:388-394`) → masks. Write target is `user://`, never `res://` (`:72-73`; S2 §3).
- **array** `:403-455`: read selected manifest + grid + layout (`:404-414`) → skip `source_png == null` **before** `str()` to avoid literal `"<null>"` (`:420-426`; S2 §4 item 6) → load block PNGs (`:430-433`) → NEAREST upscale 256²→1024² for sand1/sand2 (`:434-437`) → RGBA8 (`:438-439`) → `Texture2DArray.create_from_images()` (`:447-452`) → masks (`:453`).

Wired consumer `world3d_terrain.gd:461-520` (`observed`): instantiate with requested mode (`:477`), `load()` (`:480`), read chosen mode via `get("current_mode")` with defensive fallback to `get_mode()` (`:486-489`), grid from loader (`:490`), masks R→A repacked (`:493-501`, `:523-536`). **derived**: `current_mode` is *not* declared anywhere in the loader (repo-wide grep), so the `get_mode()` branch is the live one; no regression is implied because `get_mode()` reports the post-fallback mode.

## 5. Sampler-path comparison (do modes sample different texture sets?)

### 5.1 What the shader actually declares and samples (`observed`)

| Sampler / uniform | Declaration | Sample site |
|---|---|---|
| `uniform sampler2D tile_atlas` | `terrain_tileindex.gdshader:60` | `tile_rgb()` `:325-330`: `uv = (vec2(col,row)+local_uv)/atlas_grid`, `texture(tile_atlas, uv).rgb` |
| `uniform sampler2D alpha_atlas` | `:66` | `texture(alpha_atlas, alpha_patch_uv(v_tile, v_alpha_uv)).a` `:412` (patch math `:358-371`) |
| `uniform sampler2D alphavert_atlas` | `:72` | `texture(alphavert_atlas, mask_uv).a` `:405` (face planes `:402-404`) |
| `uniform sampler2D shadow_map` | `:83` | `shadow_tap()` `:375-379` (shadow off in stats, S3 P3) |
| `uniform vec2 atlas_grid` | `:91` | `:326-329`; bound from manifest (`world3d_terrain.gd:553`) |

Repo-wide grep of `variant3d/`: **no `sampler2DArray` declaration** and **no call** to `get_tile_array()`, `get_index_to_slot()`, `tile_uv()` or `tile_layer()` outside `tile_atlas_loader.gd` itself (`observed`). The 121-layer array and its index→slot map are built and exposed but **dormant** in the wired path — `stats` even says so at `world3d_terrain.gd:1399-1400`.

### 5.2 Per-mode binding

| Mode | `tile_atlas` source | Mask source | Sampler type used by shader |
|---|---|---|---|
| `single` | `_atlas_texture = _atlas_loader.get_atlas_texture()` from the 179,912,941-B PNG (`world3d_terrain.gd:510`; loader `:280-290`) | loader `_load_masks()` (`:288` → `:458-470`); R→A at `:500-501` | 2D atlas, `atlas_grid` from manifest |
| `split` | same call; texture from reassembled `user://` cache (loader `:335-397`) | same | **same 2D atlas** (byte-identical, §3) |
| `array` | `get_atlas_texture()` returns `null` in array mode (loader `:208-211`); `world3d_terrain.gd:511-516` creates a **second loader in `split` mode** and takes *its* 2D atlas | both loaders read the same mask files (`atlas_parts/` first, then `atlas/`, loader `:464-468`) | **same 2D atlas**, supplied by the split fallback; the `Texture2DArray` is not bound |

`_tileindex_material()` binds all four samplers at `world3d_terrain.gd:550-553` (+ donor lighting `:559-564`); material is selected only when live tile indices **and** atlas art exist (`:1217-1233`), otherwise the V7-82 splat `StandardMaterial3D` is used (`:585-601`, `:1228-1232`).

### 5.3 Comparability verdict

- **No mode switch changes the texture set sampled by the currently wired shader.** `single` and `split` produce byte-identical atlas images (§3, SHA verified twice); `array` renders through a dedicated `split` loader for the 2D sampler (`world3d_terrain.gd:511-516`). Masks are byte-identical in both directories (§2) and repacked by the same function. **derived** from code + hashes; no GPU A/B was run, so pixel identity is **inferred, not measured**.
- **Latent divergence (not currently wired):** the loader's `tile_uv()` returns a cell offset in `single`/`split` but `Vector2.ZERO` in `array` (`:239-247`), and `tile_layer()` returns `-1` outside array (`:252-255`). These are documented in S2 §3 and were exercised by job 250, but no wired consumer calls them. If a future A3/season hook binds `get_tile_array()` or consumes `tile_uv()`/`tile_layer()` (cf. S11 SP-5/SP-6), array mode **would** sample a different texture object/path, making captures non-comparable unless the mode is pinned. **inferred**.
- **Capture hygiene:** `stats["atlas_mode"]` (`:1313`) and `stats["atlas"]["requested_mode"/"loaded_mode"/"grid"/"texture_size"]` (`:1389-1400`) expose the chosen transport. Compare frames only at the same `loaded_mode`, same grid `(16,8)` and same texture size `(16384,8192)`; pin via `set_atlas_mode()` (`:317-330`). **derived**.
- **Array mode is not a full substitute if parts vanish:** `world3d_terrain.gd:512-515` requires the split loader to supply the 2D sampler, so with parts missing `_load_atlas()` returns false and the splat fallback material is selected (`:1228-1232`). **derived** from code; UNVERIFIED at runtime (no job run this lane).
- Donor-side transport: donor binds one tile `.dds` + one alpha `.bmp` per draw (S5 `:126-138`, `:457-461`; S4 `:409` labels a "transport" as ENGINE). No single/split/array equivalent exists in readable donor data; **observed** for absence of a file, **UNVERIFIED** for engine internals. No donor parity is claimed for any mode.

## 6. Git / LFS state and fresh-clone risk

### 6.1 Observed git state

| Fact | Evidence | Label |
|---|---|---|
| `*.png filter=lfs diff=lfs merge=lfs -text` | `.gitattributes:1` | observed |
| Single PNG **is committed via LFS**: index blob is a 134-byte pointer, text `version https://git-lfs.github.com/spec/v1 / oid sha256:a1f123… / size 179912941` | `git ls-files --stage` blob `b4745dc…` (134 B via `git cat-file -s`); `git show :variant3d/assets/terrain/atlas/tile_index_atlas.png` | observed |
| LFS object present locally at full size 179,912,941 B | `.git/lfs/objects/a1/f1/a1f123…` | observed |
| `git lfs ls-files --all` lists the atlas oid and both masks (`a1f123a107 *`, `dfaf78d0c2 *`, `c916ea98dd *`) | command output | observed |
| Split parts are **regular git blobs**, **not** LFS: sizes 90,000,000 and 89,912,941 via `git cat-file -s`; `git check-attr filter` → `unspecified` | `git ls-files --stage`, `git cat-file -s`, `git check-attr` | observed |
| Neither the parts nor the PNG are ignored | `git check-ignore -v` → no output | observed |
| LFS endpoint configured (`lfs.https://github.com/xevilmaxx/CossacksGodot.git/info/lfs.access basic`) | `git config --get-regexp '^lfs\.'` | observed |
| Working tree is clean for both directories | `git status --porcelain` → empty | observed |
| Manifest status still says `RESTORED__DEFAULT_MODE_SINGLE__KEEP_UNCOMMITTED_OR_LFS` | `split_manifest.json:16` | observed — **stale/misleading**: the file *is* committed, via LFS (S2 §9.3 wrote the caveat as hypothetical) |
| Loader header comment at `:19-22` repeats the same "must stay UNCOMMITTED (or be tracked with Git LFS)" caveat | current loader `:19-22` | observed — stale comment; behaviour unchanged |

**Correction to inherited reports:** S2 §9.3 and `DOC_01_all_docs_synthesis.md:177` say the PNG "must stay uncommitted or be tracked with Git LFS". The current repo has taken the second option: it is LFS-tracked and committed. S3 `:113` ("big PNG and parts both present on disk") remains accurate.

### 6.2 Fresh-clone scenarios (`inferred`/`derived` unless stated)

| Scenario | What lands at `atlas/tile_index_atlas.png` | Loader behaviour | Result |
|---|---|---|---|
| A — `git lfs install` before clone, object retrievable from remote | full 179,912,941-B PNG | `_load_single()` succeeds; mode stays `single` | works, no warning |
| B — LFS not installed / skipped (`GIT_LFS_SKIP_SMUDGE=1`) / object unavailable | 134-byte LFS pointer text | `Image.load()` on pointer text fails → `_soft_fail` warning (`:284`) → warning (`:191`) → `mode="split"` → reassembly from parts (present as regular blobs) → same hash | works with warnings, **derived** from code + pointer bytes; not executed |
| C — parts also absent (partial clone / sparse checkout excluding `atlas_parts/`) | pointer or PNG | single fails → split fails → array builds from blocks, but `world3d_terrain.gd:512-516` needs a split loader for the 2D sampler → `_load_atlas()` false → splat fallback `:1228-1232` | degraded/flat art; **derived**, UNVERIFIED at runtime |

Risk summary:

1. **Per-file limit risk is mitigated** — LFS keeps the 180 MB PNG out of the Git blob store (134 B pointer in-tree), so the normal GitHub ~100 MB/file ceiling is not hit (S2 `:38-52`; S11 `:208`).
2. **Clone-size risk is NOT mitigated** — the two split parts are ordinary Git blobs totalling **179,912,941 B** (§6.1). A fresh clone downloads ~180 MB of parts even with LFS disabled, and a further ~180 MB LFS download in scenario A. **derived**.
3. **LFS quota/bandwidth and remote-object availability** are UNVERIFIED: no network access was used, so whether the configured GitHub LFS endpoint still holds `a1f123…` cannot be confirmed here. If it does not, every clone silently degrades to scenario B.
4. **Silent transport drift**: a capture taken in scenario A (`single`) and one in B (`split`) are comparable in art bytes (§5.3) but have different `loaded_mode`; without recording `stats["atlas_mode"]` an analyst could misattribute a visual delta to the shader. **inferred**.
5. **Dual-state risk**: `single_atlas_path` override (`:82-84`, `:114-115`) can point at the LFS pointer file and exercise the fallback deliberately (S2 job 250), which is not the same as a real fresh clone. The task premise "fallback never exercised on a fresh clone" (S4 M11 `:409`) remains **UNVERIFIED**: no fresh-clone job artifact exists in the repo; job 250 was a simulated missing-file run (S2 §9.4 `:260`).

## 7. Minimal documented mitigation (report-only; no edits made)

Recommended documentation/operational steps, ordered, none requiring a code change:

1. **Keep `.gitattributes:1` LFS rule and keep the PNG LFS-tracked.** Do not untrack it, do not re-add it as a regular blob, do not delete the split parts. This is the existing, verified state (§6.1).
2. **Add an explicit clone instruction to the project docs:** `git lfs install` *before* clone; after clone run `git lfs pull` (or `git lfs fetch --all`), then verify `git lfs ls-files` lists `a1f123a107…` and that `atlas/tile_index_atlas.png` is 179,912,941 bytes / SHA-256 `a1f123…dcfbd`. If it is 134 bytes, it is a pointer, not an image.
3. **Document the fallback contract for fresh clones:** pointer file ⇒ `single` warns and auto-falls to `split` (parts are regular blobs, so they survive any normal clone) ⇒ same atlas bytes. Tell capture operators to read `stats["atlas_mode"]`, `stats["atlas"]["loaded_mode"]`, grid and `texture_size` before comparing frames, and to pin the mode with `set_atlas_mode()` for A/B work (§5.3).
4. **Correct the stale manifest status text** (documentation follows, no edit here): `split_manifest.json:16` should say the source is *committed via Git LFS*, not "KEEP_UNCOMMITTED_OR_LFS", so future lanes do not delete a tracked file. The loader header `:19-22` carries the same stale caveat.
5. **State the residual cost plainly:** LFS solves the per-file ceiling, not the ~180 MB of regular Git blobs in `atlas_parts/`; any future second atlas (S11 SP-4) doubles the LFS object *and* the parts burden, so its transport must be decided before that atom (S11 `:208`, `:252`).
6. **Do not claim donor parity for any transport.** All three are port-side representations of the donor-grounded V7-85 atlas; the donor has no equivalent (S4 M11, S5 §3.3).

## 8. Open questions (UNVERIFIED — do not guess)

1. Is the LFS object `a1f123…` actually retrievable from the configured GitHub endpoint? No network probe was permitted; scenario A is conditional on this.
2. Has the single→split→array chain ever run in a *fresh clone*? No artifact found; S2 job 250 simulated a missing single PNG via `single_atlas_path` only.
3. Is array mode's dormant 121-layer `Texture2DArray` intentional, or should a later atom bind it? Binding it would change the sampler path and break capture comparability unless pinned (§5.3).
4. The parallel SP-5 edit added `manifest_path` (`:77`, `:86`, `:116-117`, `:313`, `:405`) for a season atlas. If that hook is wired, which atlas/manifest will a capture bind, and how will `loaded_mode` + atlas path be recorded? Default remains the V7-85 Summer path, so nothing measured here changed.
5. Does any external CI check the working-tree PNG size/hash before a capture? None was found in this read-only pass.
6. Runtime pixel identity across modes (single vs split vs array) has **no** GPU A/B; byte identity is proven, pixel identity is **inferred** only.
7. Donor engine's actual tile-texture binding/pass structure remains engine-side (S5 `:507-519`); no transport parity claim is possible.

## 9. Summary

The three transports are **complete and self-consistent on disk**: one 179,912,941-B LFS-tracked PNG for `single`, two lossless regular-blob parts (90,000,000 + 89,912,941 B) whose concatenation re-hashes to the exact PNG SHA-256 (verified twice), and 85 on-disk block PNGs feeding a 121-layer `Texture2DArray`; grid `[16,8]`, 124 named / 121 filled / 3 empty cells (`86,110,123`), desert ids 111–122 packed, all 27 winter PNGs intentionally unpacked (**observed/derived**).

Fallback is `single → split → array`, triggered only from the default `single` mode; explicit `array`/`split` requests do not degrade (`tile_atlas_loader.gd:174-200`, **observed**). The wired shader uses **three 2D samplers and no `sampler2DArray`**; in array mode `world3d_terrain.gd:511-516` starts a second split loader to supply the same 2D atlas, so **no mode change alters the texture set sampled today** — captures are comparable in art bytes, but pixel identity is **inferred, not measured**, and `stats["atlas_mode"]` must be pinned/recorded. A future consumer of `tile_uv()`/`tile_layer()`/the array would introduce a genuinely different sampler path (**inferred**).

The 180 MB PNG risk is **real but partly mitigated**: it is already committed via Git LFS (134-B pointer in-tree, full object local), so the GitHub per-file limit is avoided — correcting S2 §9.3's "keep uncommitted" wording — but the split parts are regular blobs of the same total size, so fresh clones still transfer ~180 MB, and a clone without LFS gets a pointer that the loader treats as a missing image and falls back to split (**derived**). Remote LFS-object availability, a true fresh-clone run and any visual parity remain **UNVERIFIED**. No code, asset, config, test or git state was changed by this lane; no runner job was launched; no donor file was read or copied.

*End of ATLAS-01. One report written; read-only verification only.*
