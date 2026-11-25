---
id: SP-04
task: "Build the Winter tile atlas (index-preserving, same schema as the Summer atlas)"
agent: "SP-4 WINTER-ATLAS (asset-tooling builder)"
date: 2026-11-25
status: DELIVERED__ASSET_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB__NO_DONOR_COPY__NO_GIT_ADD_COMMIT
scope: "Only the assigned outputs: a new build tool, a generated Winter PNG + manifest, and this report. No loader/shader/game/test/harness/config file edited; no donor file opened or copied; no Godot runner job; no git add/commit."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
outputs:
  - "variant3d/tools/build_winter_atlas.py"
  - "variant3d/assets/terrain/atlas/tile_index_atlas_winter.png"
  - "variant3d/assets/terrain/atlas/tile_index_atlas_winter.manifest.json"
  - "docs/coord_swarm_2026-11-25/reports/SP_04_winter_atlas.md"
labels: [observed, derived, inferred, UNVERIFIED, PORT APPROXIMATION]
verification_passes: 3
visual_parity_claim: false
donor: "Donor READ-ONLY and NOT opened this task. Every donor path:line fact is cited second-hand via SP-2 / DENV-01 / SEASON_PLAN-01 (which read it in earlier read-only passes). Only already-converted port PNGs were used."
---

# SP-04 — Winter tile atlas build (index-preserving swap)

## 1. Goal and result

Build the **Winter** counterpart of the V7-85 Summer tile atlas so a season hook
can bind a different texture **without changing any tile index or shader rule**
(SEASON-PLAN-01 §4.3, §5 SP-4, B4/B5). The result is one 16×8 / 1024² RGBA PNG
and a manifest with the **same top-level/field schema and the same 0–123
indices** as the Summer manifest; only the art resolved at each index changes.

**No visual parity claim.** No donor file was read, no GPU A/B was run, and no
attempt was made to judge how the result looks.

## 2. Sources read this task (all read-only)

| # | Source | Role / label |
|---|---|---|
| S1 | `docs/coord_swarm_2026-11-25/reports/SEASON_PLAN_01.md` | SP-4 spec, B1/B2/B4/B5, Q1/Q4, §7 label list (observed doc) |
| S2 | `docs/coord_swarm_2026-11-25/reports/SP_02_winter_dictionary.md` | 124-entry alias dictionary, 23 winter + 12 desert targets, 4 unmapped winter PNGs, shared alpha 86/110/123 (observed doc; donor cited second-hand) |
| S3 | `docs/coord_swarm_2026-11-25/reports/ATLAS_01_transport.md` | Summer PNG 179,912,941 B, 16×8 grid, 124/121/3 cells, split parts as regular blobs, LFS state (observed doc) |
| S4 | `variant3d/assets/terrain/atlas/tile_index_atlas.manifest.json` | **authoritative geometry, mask metadata, EMPTY-cell status text, packing label, shipped-id histogram** (read directly) |
| S5 | `variant3d/assets/terrain/atlas/tile_index_atlas.png` | pixel-byte spot-check of the packing method (read directly) |
| S6 | `variant3d/scripts/tile_atlas_loader.gd` | SP-5 `manifest_path` override + `single_atlas_path`, `_load_grid()` (read directly; not edited) |
| S7 | `variant3d/assets/terrain/atlas/winter_aliases.json` | SP-2 data: the 124 aliases consumed by the build (read directly) |
| S8 | `variant3d/assets/terrain/structs/presets_summer.json`, `assets/terrain/blocks/*.png`, `app/shots/g32_dump.json` | index order, converted port art, same dump histogram (read directly) |
| S9 | `variant3d/tools/build_tile_index_atlas.py` | reference implementation for paste/RGBA/compression semantics (read directly; not edited) |

Donor citations carried into the new tool header are **second-hand**:
`terrain.presets:134-263` (Winter 124-entry set), `texturemap.inc:525-526,605-606`
(`_winter` suffix), `tiles.mat` (23 winter + 12 reused desert textures), and
`reftile.lib:3-12` (packing engine-side → `APPROX_ATLAS_PACKING`), all via
SP-2 §3 / DENV-01 §3.3, §4 / SEASON-PLAN-01. Nothing in `C:\Games\Cossacks 3`
was opened, read, copied or executed.

## 3. Geometry and schema — derived from S4, not guessed

| Field | Value | Label |
|---|---|---|
| `grid` / `slots` | `[16, 8]` / `128` | observed (S4 `atlas`) |
| `cell_size` / `size` | `[1024,1024]` / `[16384,8192]` | observed (S4 `atlas`) |
| per-cell address | `cell_xy = [index % 16, index // 16]`; `cell_px = [x*1024, y*1024, 1024, 1024]` | derived from S4 `layout` (verified for all 124 rows) |
| named / filled / empty | `124 / 121 / 3` (empty = indices **86, 110, 123**, names `alpha0a/b/c`) | observed (S4) + derived (S2 `shared_alpha`) |
| RGBA canvas | transparent `(0,0,0,0)`; filled cells paste source RGB with alpha forced to 255 | observed method (S9, spot-checked against S5) |
| masks | `alpha.png` 512×256 mode L; `alphavert.png` 1024×512 mode L; copied **verbatim** from S4 `masks` (shared, no new donor read) | observed (S4) |
| alpha sub-rect ↔ tile mapping | not invented; donor formula/sub-rect engine-side | UNVERIFIED (S1 §7.1, S4 `masks[].note`) |
| empty-cell art | no shipped PNG; cell left transparent, nothing fabricated | observed (S2 §6-7; S4 status text reused byte-for-byte) |
| packing | uniform grid is `APPROX_ATLAS_PACKING` | PORT APPROXIMATION (S1 §7.1) |

**Manifest schema identity (verified programmatically):** same 13 top-level keys
and same `atlas` block keys as S4; the `layout` field union matches S4 except
for `upscale_label`, which is *absent* because no Winter source needs upscaling
(all 35 distinct sources are already 1024² RGB). `kind` uses the Summer value
domain `DIRECT / FACE_BASE_REUSE / EMPTY` (35 / 86 / 3 — first use vs. reuse of
an already-packed source PNG); the SP-2 alias kind (`WINTER_PNG`/`DESERT_REUSE`)
is preserved in every cell's `donor_evidence` string. `masks` and
`shipped_tileblock` are equal to S4's blocks. `visual_parity_claim: false`.

## 4. Build tool

`variant3d/tools/build_winter_atlas.py` (16,746 B; git blob
`2fae10f2e18b5031685c63b6c0cd086f07d7756d`):

- reads geometry, masks, packing label and EMPTY status text from S4 at runtime;
  asserts 16×8 / 1024² / 16384×8192 / 128 before writing;
- validates S7: 124 entries, indices 0–123 contiguous, names equal to S8;
- treats S7 `shared_alpha: true` entries as EMPTY (cross-checked against S4's
  EMPTY indices) — their S7 `source_png` values are **donor alias carriers
  only**, not shipped art;
- resolves every other `source_png` inside `assets/terrain/blocks/`, checks
  1024×1024 size, records source SHA-256, pastes RGB into the RGBA canvas;
- never packs the four donor-unaliased PNGs (`winter18/23/24/26`); it lists them
  in `unused_shipped_blocks` together with the 73 summer-only PNGs not selected
  by Winter aliases (77 unused in total), with an explicit `unused_note`;
- recomputes the shipped-tile histogram from `g32_dump.json` (same indices),
  writes both outputs, then runs 16 self-checks including a **full 121-cell
  pixel-byte comparison**; `--check` re-verifies without rebuilding.

Determinism: the generated PNG is byte-identical to an LFS object already
present in the local cache (`5d0dd8f…`), so two independent runs produced the
same bytes. **derived** from SHA-256.

## 5. Artifacts and build time

| Artifact | Bytes | SHA-256 / git blob | Label |
|---|---:|---|---|
| `variant3d/assets/terrain/atlas/tile_index_atlas_winter.png` | **124,463,306** (≈124.5 MB) | `5d0dd8f3042ec13d6989b357ffbc007dbd439237b8e7cfffe7bb98f18e3cbadb` | observed |
| `variant3d/assets/terrain/atlas/tile_index_atlas_winter.manifest.json` | **79,837** | `ef4ab26e35650c20d57517974fbb4715ffae5252a0175c2218151195f95afba0` | observed |
| `variant3d/tools/build_winter_atlas.py` | 16,746 | git blob `2fae10f2e18b…` (byte-identical to HEAD; see §7) | observed |
| `docs/coord_swarm_2026-11-25/reports/SP_04_winter_atlas.md` | this report | — | observed |

**Build time:** 41.223 s for the full build + verification (`python
variant3d/tools/build_winter_atlas.py`); 15.416 s for a verification-only
re-run (`--check`). First attempt aborted on a local `NameError` before the
manifest was written; after the one-line fix the tool ran clean and the final
tool file is byte-identical to the version already in HEAD.

**No split-parts-only fallback was needed:** 255.7 GB free on the working drive
(observed via `shutil.disk_usage`).

## 6. Verification results

Pass 1 — tool self-check, **16/16 PASS**, `pixel_failures: []` (all 121 filled
cells' RGB bytes equal their source PNG bytes with alpha `(255,255)`; all 3
EMPTY cells are `(0,0,0,0)`).

Pass 2 — independent fresh Python/Pillow re-read:

| Check | Result |
|---|---|
| top-level key order/list == Summer manifest | PASS |
| `atlas` block keys == Summer | PASS |
| `layout` field union | PASS (Winter = Summer minus unused `upscale_label`) |
| `masks` block == Summer; `shipped_tileblock` == Summer | PASS |
| 124 indices contiguous 0–123; names == `presets_summer.json` | PASS |
| all 35 referenced source PNGs exist; 0 missing | PASS |
| PNG 16384×8192 RGBA, 124,463,306 B | PASS |
| 8-cell pixel spot-check: indices 0, 9, 36, 86, 110, 111, 122, 123 (winter art, green-grass art, desert reuse, 3 empty alpha cells) | PASS (8/8) |
| Summer PNG / manifest SHA-256 unchanged | PASS — `a1f123a1072e…` / `179,912,941 B` and `112e9ff5ed63…` / `60,677 B`, matching ATLAS-01 §2 |

Pass 3 — `--check` re-verification of the written artifacts: **16/16 PASS**.

Coverage: 124 Summer ids mapped; 112 resolve to `winterN.png` (23 distinct
files), 12 reuse `desertN.png`; 27/27 on-disk winter PNGs accounted for
(23 referenced, 4 deliberately unmapped). Counts **derived** from S7 and the
generated manifest; pixel equality **observed**; runtime behaviour **UNVERIFIED**.

## 7. Coordination facts discovered (read-only; COORD decisions)

1. **Pre-existing tracked paths / LFS divergence.** Commit `0628b3cf step`
   already tracked `variant3d/tools/build_winter_atlas.py` (byte-identical to
   the tool written here) and a **3-line LFS pointer** at
   `tile_index_atlas_winter.png`: `oid sha256:6b251045f815…814`,
   `size 74,986,953`. My run replaced that pointer with the real PNG
   `5d0dd8f…` / 124,463,306 B, which is byte-identical to an older LFS object
   already in the local cache. The manifest path was untracked. **No git
   add/commit was performed.** COORD must decide which object becomes the
   committed LFS pointer, and whether the manifest is tracked. **observed**;
   reason for the older object's differing bytes **UNVERIFIED**.
2. **Path-name mismatch (important for SP-6/SP-8).** This task's exclusive
   outputs are `tile_index_atlas_winter.*`, but the currently landed renderer
   and test constants point at `tile_index_winter_atlas.*`:
   `variant3d/scripts/world3d_terrain.gd:269-270` and
   `variant3d/tests/t_season_overlay.gd:59-60` (also `SP_08_season_test.md:157`).
   I did **not** edit those files. COORD must align the constants with the
   actual artifact names (or rename the artifacts); until then a Winter
   capture would point at a missing path. **observed**; final naming
   **UNVERIFIED**.
3. Other concurrent working-tree modifications (`SWARM_BOARD.md`,
   `world3d_fx.gd`, `world3d_terrain.gd`, `TERRAIN_DARK_01.md`) were left
   untouched.

## 8. LFS / clone-size warning

- The Winter PNG is **124,463,306 B**, above GitHub's ~100 MB per-file limit
  (`tile_atlas_loader.gd:19-22`, ATLAS-01 §6). It must be LFS-tracked (134-B
  pointer in-tree) or split into parts; LFS/clone transport is **COORD's call**
  (SEASON-PLAN-01 Q4, ATLAS-01 §7.5).
- LFS solves the per-file ceiling, **not** clone size: the existing Summer split
  parts are 90,000,000 + 89,912,941 B of ordinary Git blobs (~180 MB on every
  clone), and a Winter split would add comparable regular-blob weight.
  **derived** from ATLAS-01 §6.1.
- Remote LFS-object availability for either OID and a true fresh-clone run are
  **UNVERIFIED** (no network operation was performed).
- Operational instruction if LFS is chosen: `git lfs install` *before* clone,
  then `git lfs pull`, and confirm the Winter PNG is 124,463,306 B with SHA-256
  `5d0dd8f…` — a 134-B file is the pointer, not the image.

## 9. Labels and limits

- **observed** — literal file bytes, hashes, manifests, counts read this task.
- **derived** — arithmetic over observed values (cell addresses, counts,
  clone-size consequences, determinism from equal hashes).
- **inferred** — the index-preserving swap will not require a shader edit
  (SP-6 must still be wired and exercised); path mismatch consequence in §7.2.
- **UNVERIFIED** — donor runtime activity of `;`-prefixed season scripts,
  donor `tsDouble` packing, alpha sub-rect mapping, remote LFS availability,
  final artifact naming, any GPU pixel result.
- **PORT APPROXIMATION** — 16×8 uniform packing and shared masks; no donor
  transport equivalent exists.
- **No visual parity claim.** "Grain changed" may only be asserted
  structurally (different `source_png` resolution and atlas path), never as
  "looks donor-like" (SEASON-PLAN-01 B3, SP-8 Q7).

## 10. What remains

- **SP-6 (renderer hook, other owner):** select `manifest_path` +
  `single_atlas_path` from BIOME (`world3d_terrain.gd:269-270,280,289,870-878`),
  keep indices untouched, switch the bound texture *instead of* accumulating
  both atlases (512 MiB RGBA8 each), and fix/align the path constants in §7.2.
- **SP-8 / a real GPU capture:** run the 64² dump-driven season overlay,
  assert the selected atlas path is actually loaded (`stats["atlas_mode"]`,
  loaded mode, grid, texture size), and record a matched-camera capture with
  those stats. No donor A/B or visual-parity conclusion is permitted without
  one. **UNVERIFIED** until then.

---

*End of SP-04. Tool generated PNG + manifest; 3 verification passes; no donor
access, no runner job, no existing loader/shader/game/test file edited, no git
add or commit, no visual parity claim.*
