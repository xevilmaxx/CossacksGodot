---
title: Donor-faithful terrain blending — implementable build plan (T4-DONOR-BLEND)
owner: T4-DONOR-BLEND (research / design only)
lane: research-design
decision_context: owner rejection of synthetic grass-gain / checkerboard terrain — "if donor already was able to do it why you cannot use same logics?"
updated: 2026-11-21
status: FINAL — next build ticket; no code edit, no Godot run, no donor binary copied
protocol: SWARM_OPS.md §5b-QUALITY — every claim cites file:line or a measured artifact and is labelled observed / derived / inferred / UNVERIFIED
files_changed_by_this_agent: docs/audit/TERRAIN_BLEND_DONOR_PLAN.md (this file only)
---

# Donor-faithful terrain blending (T4-DONOR-BLEND)

> [!IMPORTANT]
> This is a **research/design** deliverable. I read the donor **read-only** under
> `C:\Games\Cossacks 3`; no donor binary, TGA, DDS, `.cfg`, or `.inc` was copied
> into the repository. No Godot process was started. No file under `app/` was
> edited. All line numbers are 1-based and refer to files as read on 2026-11-21.
> The port files cited were read at their current working-tree state
> (`_composite_blocks` already exists — see §3).

---

## 0. Decision in one paragraph

The donor does **not** compute a continuous luminance/gain field. It stores a
**discrete TileBlock name (index) per map cell** in `terrain.presets`, resolves
that name to a texture (plus sub-atlas/rotation metadata) through
`tiles.mat`/`tiles.lib`, and makes adjacent art legal with a **3-pass,
probability-weighted compatibility smoother** (`smoothtiles.inc` +
`tilesmooth_scripts.cfg`). The port already reproduces the generator side
faithfully (`game.gd:_assign_tileblocks` → `tileblock[]`, `tbl_names`,
`smooth_summer.json`, 3 passes). The renderer then **caps the block set to 3
per chunk, washes rare names out to ≤25 % alpha with a 2×2 fractional coverage
grid, draws one continuous global `grass1` base, replaces ground variation with a
synthetic olive gain/patch field, and substitutes fixed textures for sand/rock
roles**. That is the whole defect. The fix is a `world.gd`-only change: draw at
most three **actual donor block crops** per chunk, each from a **per-cell exact
coverage mask** (0/1 per cell, one-tile anti-alias), use the chunk's dominant
donor block as the base instead of global `grass1`, delete the gain path, and let
the already-computed donor names — including `sandsea*`/`rock*` — drive every
ground role. No new RNG, no new generator pass, no new field.

---

## 1. Sources consulted (evidence base)

| Group | Sources |
|---|---|
| Donor plaintext | `data\scripts\common.inc\smoothtiles.inc` (full, 245 lines); `data\gen\tilesmooth_scripts.cfg` (64,017 B, 1,880-ish lines); `data\gen\tilesmooth.cfg` (2,796 B, 129 lines); `data\terrain\tiles\terrain.presets`; `data\terrain\tiles\tiles.lib`; `data\terrain\tiles\tiles.mat` |
| Prior audits | `docs/audit/TERRAIN_DONOR_PIPELINE.md` (§3.3, stage 5g, C23, rec 10), `docs/audit/TERRAIN_DONOR_ASSETS.md` (§3.2, §5), `docs/audit/TERRAIN_PORT_RENDER.md` (B1/B2, TR-1/TR-2), `docs/audit/TERRAIN_BEAUTY_TRIAGE.md`, `docs/audit/TERRAIN_REFERENCE_IMAGES.md` (TS-1), `docs/audit/PIECES/grass_mottled.md` |
| Port code | `app/scripts/game.gd:1128-1199,1290-1603`; `app/scripts/world.gd:20-79,187-202,655-701,818-856,960-1049,1090-1221,1507-1605`; `app/assets/terrain/structs/{presets_summer,smooth_summer,tileblocks}.json` |
| Perf artifacts | `app/.godot_queue/results/00000921_t3world-bench/stdout.txt:6` (`max_ms=125.05 mean_ms=97.12`); `app/.godot_queue/results/00000910_t3world-bench-t2/stdout.txt:6` (`114.52`); `app/shots/perf.md:221-251` (older `645.24` FAIL row) |

---

## 2. How the donor stores and smooths per-cell ground art

### 2.1 The three tables and their exact division of labour

1. **`data\terrain\tiles\terrain.presets` — the name↔index registry.**
   `section.begin` → `SetName = Summer`, `WaterSet = Summer`, `DefaultIndex = 0`,
   `Blocks : struct.begin`, then 124 ordered `[*].TileBlock = <name>` entries
   (`terrain.presets:1-6` and following; Summer block `grass1 … alpha0c`). A
   second section is `SetName = Winter` with another 124 entries. The **index is
   the ordinal position in that list**; `MapGetTileIndexByTileBlock(name)` /
   `MapGetTileBlockByTileIndex(i)` are exactly this lookup
   (`smoothtiles.inc:51`, `:95-96`). This is what `SetTileIndex(x,y,i)` writes
   (`smoothtiles.inc:32`, `:242`). **Observed**: the port's
   `app/assets/terrain/structs/presets_summer.json` is *byte-for-byte the same
   124 names in the same order* (parsed comparison, 124/124 equal). So
   `game.tbl_idx` is the donor index space, not a port invention.

2. **`data\terrain\tiles\tiles.lib` and `tiles.mat` — geometry and texture
   resolution.** `tiles.lib` has one `TileBlockName` section per block with
   optional `TileSize`, `Rows`, `Cols`, `AngleX`, `AngleZ`
   (`tiles.lib:1-6` for `grass1…`, `:52-56` for `sand1: TileSize=64, Rows=2,
   Cols=2`); `terrain.lib` sets `TextureScale` X/Y/Z/W = 1 (TDR-3 §3.2:120).
   `tiles.mat` has **253 `Material.Name → Material.Texture.image` pairs**
   (`tiles.mat:1-5` for `grass1 → grass1.dds`; alias examples
   `rock1vf :143 → rock1.dds`, `sand1f :215 → sand1.dds`, `alpha0a :347 →
   grass1.dds`, `sand1_winter :558 → winter10.dds`). Of these, 124 are summer
   names and 124 are `*_winter` aliases resolving to only 35 unique DDS (23
   `winter*.dds` + 12 reused `desert*.dds`) — TDR-3 §3.2:118.
   **Consequence for the port**: 124 preset slots are backed by only 112 PNG
   files; 39 names are *aliases*, not missing art (§3.3/P3).

3. **`data\gen\tilesmooth_scripts.cfg` — compatibility tables (the file TDR-1
   left unread; now read).** Structure: one `TileSmoothLists` root, **22
   `SmoothTiles` sections**. Sections 0-9 are Summer, 11-20 are the same chains
   with `_winter` suffixes (winter art starts at `tilesmooth_scripts.cfg:934`),
   and sections 10/21 are empty terminators. Each section contains 3-9
   `TileNames` groups; each group contains 1-16 `(TileName, Prob)` pairs, e.g.
   section 0 at `:1-96`: group 0 `sandsea1/2/3/4 = 1`, group 1 `sandsea5=0.7,
   sandsea6=0.3`, group 2 `rock9=rock8=rock5=0` (:51-66), group 3
   `rock1..rock7=0.16, rock4=0.20` (:67-94). Probabilities **sum to 1 inside
   most groups** and a `Prob = 0` entry marks a group that must not be picked as
   a replacement but is still a valid *endpoint* of a compatible pair.
   **Observed (parsed)**: port `smooth_summer.json` is a faithful conversion of
   exactly the 10 summer sections — group counts match
   `[4,6,6,9,9,8,6,3,3,5]` in both, 141 entries, only four `prob:0` names
   (`rock9`, `rock8`, `rock5`, `test8`). The commented-out `sandrock` group at
   `tilesmooth_scripts.cfg:37-50` is correctly absent from port chain 0.

   Do **not** confuse this with `data\gen\tilesmooth.cfg` (2,796 B, 129 lines),
   a separate file of 64 *plain* `TileName` lists referenced by
   `globalparams.cfg:TileSmoothListFileName`; `smoothtiles.inc:5` loads
   **`tilesmooth_scripts.cfg`**, the probability tables. (`derived` distinction
   from the two call sites and file contents.)

### 2.2 The exact `SmoothTileMap` algorithm (donor fact)

Consumer: `smoothtiles.inc` (D5 in TDR-1). All steps below are `observed`.

| Step | Donor line | Operation |
|---|---|---|
| Load config, resolve names to preset indices, accumulate `SumProb` per group | D5:4-6, :35-60 | `Items[0..63]`, each `SmoothTiles[0..23]`, each `SmoothTile[0..15]` with `{TileName, TileIndex, Prob}` (types D5:9-26) |
| Snapshot tile indices | D5:27, :30-32 | `atilemap[i,j] := GetTileIndex(i,j)` — all smoothing is against the snapshot, then written back once |
| Roulette pick | D5:63-80 | `rnd := RandomExt * SumProb`; walk group entries, pick first `prob>0` where `rnd < tmp` |
| Neighbour resolution `GetNeighbourTiles(t1,t2)` | D5:84-187 | Scan all 64 chains; for each, find the group index `ind1` of `t1` and `ind2` of `t2` (record `prob==0` flags, D5:112-121). Choose the chain with the **smallest `abs(ind1-ind2)`**, with `ind1 ≠ ind2`, both ≥0 (D5:126-136). `rock5`/`rock2` special case at D5:124-125 is a no-op self-assignment. |
| Compatibility decision | D5:139-181 | `abs(i1-i2)=1` and at least one endpoint `prob>0` → **compatible, no change** (D5:142-156). `i1-i2=2` → replace tile 1 with a roulette pick from group `(i1+i2)/2` (D5:159-163). `i2-i1=2` → replace tile 2 the same way (D5:165-169). Distance >2 → replace the tile on the **farther** group with a pick from `nearer+1` (D5:171-180). No chain contains both names → leave both unchanged (D5:182-186). |
| Sweeps | D5:191-235 | Per pass: horizontal sweep `i=mini..maxi-1, j=minj..maxj` (`:200-215`), then vertical sweep `j=minj..maxj-1, i=mini..maxi` (`:218-233`), both calling `GetNeighbourTiles` only when the two indices differ (`:205`, `:223`). |
| Invocation | D5:237, :240-242 | **`SmoothTileMap(0, 0, GetMapWidth, GetMapHeight, 3)`** — 3 passes, then `SetTileIndex` write-back. |

`globalparams.cfg:TileSmoothPasses = 6` (TDR-3 §5) is a separate editor-facing
knob; the script path that actually runs for random maps is hard-coded to **3**
at D5:237. Use 3. (`derived` from the call site; no donor binary was read.)

### 2.3 What the donor *does not* do

No luminance gain field, no checkerboard speckle pass, no global grass base,
no patch grid, no continuous mask between unrelated textures. Every land cell
gets one discrete TileBlock; the only "blending" is (a) the compatibility
smoother choosing a third *named* tile at illegal boundaries and (b) the tile
art itself being authored to meet its neighbours. `SetupTiles()` is dead
(TDR-1 C8), so meadow variety comes from the `tile_low/highground` bitmap
detail pass plus the tiled-pattern stamp layer — not from synthetic noise.
(`observed` from TDR-1 C8/C23, D5 full read; `inferred` attribution of "no
continuous field" from the absence of any such API in the smoothing script.)

---

## 3. What the port already computes, and the missing link

### 3.1 Generator side — already donor-faithful, do not touch

| Port artifact | State | Evidence |
|---|---|---|
| `tileblock[PackedByteArray]` | Full `MAP_W*MAP_H` per-cell donor TileBlock **index**; water = `BLK_WATER=255` | `game.gd:36-38`, `:1334`, `:1370` |
| `tbl_names` / `tbl_idx` | 124 summer names loaded from `presets_summer.json`, exact donor order; name→index dict | `game.gd:43-45`, `:1128-1138` |
| `tbl_smooth` | 10 donor summer chains loaded from `smooth_summer.json` | `game.gd:44`, `:1136-1138` |
| Base roles | donor height thresholds → road/grass_ground/sand/rock indices | `game.gd:1345-1391` |
| Oriented shore/cliff | 8-sector `sandsea1/5/6`, `rock4/7/8` chosen by height gradient | `game.gd:1421-1498` |
| **3-pass smoother** | `_smooth_tilemap(brng,3)` → horizontal then vertical sweeps; `_tb_pick` roulette over `prob`; group-distance rule identical to D5:126-180 | `game.gd:1395`, `:1500-1589` |
| Detail / forest border / mine apron | `tile_low/highground` R÷2 detail, `grass5`/`rock9` edge tiles, `ground1` mine apron; port-authored guards | `game.gd:1294-1321`, `:1591-1603`, `:1386-1390` |
| Winter art names | `winter_tile_names[]` + `WINTER_ART` alias map (summer indices unchanged) | `game.gd:1140-1198`, `:1415-1419` |

`game.gd` needs **no edit**. Its RNG stream, dumps, and byte layout stay
unchanged (§4.5).

### 3.2 Renderer side — the missing link (all `observed` at source level)

| Blocker | Port mechanism | Why it kills donor fidelity |
|---|---|---|
| **B1 — cap + wash** | `_build_chunk` counts distinct names, keeps `_rank_blocks(counts, BLOCKS_PER_CHUNK=3)`; `_composite_blocks` builds coverage from a **2×2 neighbourhood average** of the four surrounding cells' names | `world.gd:63`, `:1530-1546`, `:1183-1215`. For a cell whose name appears in only one of the four neighbours the coverage node is **0.25**, so a rare `sandsea5` or `rock8` is drawn at ~25 % alpha over grass. The donor index is effectively discarded visually even though it is read. |
| **B2 — global base** | `var img := _wrap_crop(_block_img(_winter_art("grass1")), cx*S, cy*S, S)` | `world.gd:1523`. Every chunk starts from the same donor grass1 texture, regardless of what its cells' tileblock names are. This is the "global grass1 base" the owner rejected. |
| **B3 — synthetic gain / patch grid** | `_grass_gain()` olive bright/dark overlays + precomputed hard-grain texture; `_build_grass_hard_tex()` at setup; constants `GRASS_PATCH_*`, `GRASS_HARD_*`, `_gain_at()` | `world.gd:664-701`, `:1036-1037`, `:590-658`. No donor analogue; explicitly flagged as port-authored in `PIECES/grass_mottled.md:191-193`. This is the rejected "synthetic luminance gain". |
| **B4 — fixed role textures** | `role_block = {1:"ground1", 2:"grass_ground2"}` and sand/rock passes use `BLOCKS_PER_ROLE=2`, `max_alpha=0.55, falloff=1.7`; water uses a substrate wash | `world.gd:64`, `:1552-1593`, `:1286-1351`. The per-cell `sandsea*`/`rock*` names are fed through a separate softened role pass instead of being the ground itself. |
| **B5 — unresolved aliases** | `_block_img(nm)` loads `blocks/<nm>.png`; on failure it fills flat `Color(0.4,0.45,0.25)` | `world.gd:966-988`. **39 of 124 summer preset names have no PNG** (`sand1f/s`, `rock1vf/vs`, `alpha0a/b/c`, …); donor resolves them via `tiles.mat` aliases. The renderer silently draws flat green for them. `Rows/Cols/AngleX/AngleZ` from `tiles.lib` are entirely ignored (the data *is* present in `tileblocks.json`, 245 entries). |
| **B6 — port grain lift** | `im.adjust_bcs(1.0, 1.12, 1.0)` on every block | `world.gd:982`. A 12 % contrast lift not present in the donor pixels. Port-authored. |

**The missing link is therefore not data — it is the renderer's coverage and
selection policy.** Fixing B1+B2+B3+B4+B5 in `world.gd` is sufficient.

---

## 4. Renderer change design (build ticket TB-DONOR-BLEND)

**Scope:** one file, `app/scripts/world.gd`, plus data-only reads of existing
JSON. No `game.gd`, `data.gd`, shader, or asset conversion changes for the core
ticket. Back up `world.gd` before editing; owner per `TERRAIN_BEAUTY_TRIAGE.md:37`
is RENDER-1 (coordinate — this plan does not reassign ownership).

### 4.1 Hard rules for this ticket

1. **One mirror-tiled crop per distinct donor block name**, sampled at a single
   **continuous world-space offset** per name (existing `cx*S + coff` behaviour,
   `world.gd:1219-1220`) — no per-cell random crop, no per-cell jitter.
2. **Per-cell exact coverage**: a cell's own name gets coverage 1 inside that
   cell and 0 elsewhere; no 2×2 fractional average. One-tile bilinear feather
   at name borders only (no synthetic field). Donor legality at borders comes
   from the upstream 3-pass smoother (§2.2), not from new renderer logic.
3. **No global grass1 base**: the base crop is the most frequent donor block
   name in the chunk, read from `game.tileblock`; it is a normal donor tile.
4. **No synthetic luminance gain, no patch grid, no olive gain field**: remove
   the `_grass_gain()` call and the hard-grain precompute from the ground path.
   `_face_collar`, water overlay/shader, season tint, and relief shading are
   left unchanged in this ticket (scope limit; flagged as port approximations
   in §6).
5. **Bounds unchanged**: `BLK_CACHE := 32` (`world.gd:59`), `BLOCKS_PER_CHUNK := 3`
   (`:63`), max **3 distinct block crops per chunk**, 2-chunks/frame cap and
   LRU-24 chunk cache (`world.gd:1160-1182`). Baseline bake is `max_ms=125.05`
   (job 921, `.../00000921_t3world-bench/stdout.txt:6`); target `<250 ms`.
   `BLOCKS_PER_ROLE` becomes unused (role passes are absorbed into the base
   pass); leave the constant but grep must show 0 draw-path call sites.

### 4.2 Functions to add / modify (target lines are current `world.gd`)

| # | Function | Target line | Change |
|---|---|---|---|
| F1 | `const BLOCK_ALIAS` (new, 39 summer aliases + winter handled by existing `winter_block_for`) | near `:59-64` | Literal dict `{"sand1f":"sand1", "rock1vf":"rock1", "alpha0a":"grass1", …}`, authored from `tiles.mat:143,215,347,558,…`. This is **data transcription**, not new art. |
| F2 | `_block_key(name: String) -> String` (new) | just above `_block_img` (`:966`) | Resolve alias → PNG stem; append `#r<row>c<col>` when `Rows/Cols>1` (read `tileblocks.json`, already loaded by tooling — load it once in `_load_terrain_structs` or add a small `BLOCK_GEOM` const generated from that file). Cache key is the **resolved art key**, so LRU 32 counts distinct textures, not distinct preset names. |
| F3 | `_block_img(nm)` (modify) | `:966-988` | Accept a resolved key: crop the `(row,col)` sub-rect from the loaded PNG before `_mirror_tileable` (donor `Rows/Cols` from `tileblocks.json:139-145,650-665` / `tiles.lib:53-56,329-339` (`sand1` 2×2; `test10` 16×16; `test11` 32×32). Caveat: `test10/11` metadata implies a 2048² sheet while the converted PNGs are 1024² (TDR-3 §3.2), so their exact sub-rect mapping is **UNVERIFIED** at runtime — validate or exclude those two names in the first build). Apply `anglez` as a 2-D rotation of the sub-tile (25°); `anglex` remains a documented approximation (UNVERIFIED donor semantics, §6). Set the grain lift `1.12 → 1.0` (B6) so donor pixels are used as converted. Keep LRU 32 touch-on-hit eviction unchanged (`:968-987`). |
| F4 | `_cell_cover(cx, cy, N)` (new) | just above `_composite_blocks` (`:1174`) | Build one `N=CHUNK_T` RGB8 grid per selected name. Single pass over `CHUNK_T²` cells: skip `game.tileblock[ti] == BLK_WATER` (coverage 0, water overlay owns those cells); resolve `_art_name(ti)` → `_block_key` → selected-name index; write `1` to that name's grid node, `0` elsewhere. Grids are a partition of unity (exactly one name =1 per land node). No 2×2 loop, no `role_filter`. |
| F5 | `_composite_blocks` (modify signature/body) | `:1174-1221` | Replace the 2×2 average loop (`:1192-1215`) with F4's grids. Keep `_alpha_mask(..., S)` bilinear resize (`:1218`) — that is the only border feather, one tile wide. Drop `role_filter`, `max_alpha`, `falloff` parameters (the softened role wash is deleted). Keep the cached crop + `blend_rect_mask` composite (`:1219-1221`). With disjoint 0/1 grids the per-pixel coverage sums to 1, so no normalisation pass and no full-resolution GDScript pixel loop — this is what protects the bake budget. |
| F6 | `_build_chunk` base + name selection (modify) | `:1523` and `:1530-1546` | Compute `counts` from `game.tileblock` via `block_at`/`_art_name` as today (`:1527-1537`), but take `names = _rank_blocks(counts, BLOCKS_PER_CHUNK)` **including `sandsea*`/`rock*`** (delete the filter at `:1542-1545`). `dominant = names[0]`. Base: `_wrap_crop(_block_img(_block_key(dominant)), cx*S, cy*S, S)` — no hardcoded `grass1`. Then `F5(names)` composites the same base name (harmless full-coverage blit) and the other ≤2 names. Total distinct block crops = **≤3**. |
| F7 | `_build_chunk` role loop (modify) | `:1552-1593` | Delete `_role_block_names` and the `role_block` constants. For `t in [1,2,4,5]` **no separate pass** — their cells are already drawn by their per-cell donor names in F6. Keep `t == 3` (water substrate `_shore_substrate` + existing GPU overlay) exactly as-is. `_role_block_names` (`:1147-1165`) and `BLOCKS_PER_ROLE` become dead. |
| F8 | `_build_chunk` gain removal (modify) | `:1603-1605` | Delete the `_grass_gain(img, cx, cy, S, N)` call (`:1604`). Keep `_face_collar` and the season/relief block (`:1605-1630`) unchanged. In `_build_masks`, delete `_build_grass_hard_tex()` (`:1037`) so the patch texture is never built. `_gain_at`/`GRASS_PATCH_*`/`grass_hard_tex` become dead; remove in a follow-up cleanup if desired, but grep must show 0 ground-path call sites for this ticket. |
| F9 | warm-up (modify) | `:187-202` | Pre-warm the **resolved keys** of the common donor names actually used by the new base path (`grass1..10`, `ground1`, `grass_ground*`, `sand1..9`, `rock1..9`, `sandsea1..6`, `test2/3`) rather than raw names. Keeps the cold-cache portion of the 125 ms bake from returning. |

### 4.3 Why this is donor-faithful rather than another invention

- Tile selection is **not recomputed**: the renderer consumes `game.tileblock`
  indices exactly as the donor consumes `atilemap` after `SmoothTileMap`
  (`game.gd:1395` ↔ `smoothtiles.inc:237`). No RNG, no extra passes, no new
  thresholds.
- The art is the **same converted donor pixel data** (`app/assets/terrain/blocks/`,
  112 PNG = 112 donor DDS, TDR-3 §3.2:94-115), now with alias/sub-atlas
  resolution restored from `tiles.mat`/`tiles.lib` instead of a flat-green
  fallback.
- Border legality remains the donor compatibility tables' job (§2.2); the
  renderer's bilinear 1-tile feather is only anti-aliasing, not a "look".
- Removing the gain field restores TS-1's measured low-amplitude donor grain
  (clean grass hi-freq ≈2.96 from real block art, not an olive overlay).

### 4.4 Bounded cost / cache behaviour

- `BLK_CACHE = 32` LRU stays; resolved art keys are the cache entries (39 alias
  names collapse onto ~4 base PNGs, so the working set shrinks).
- ≤3 `_wrap_crop` + `blend_rect_mask` composites per chunk (one base + two
  overlays) vs today's 3 base + up to 2 per role (up to ~7). F5's single pass
  also removes ~14 redundant 33×33 grid rebuilds noted at `world.gd:1180-1182`.
- New per-bake work: one `CHUNK_T²` (1,024) cell loop instead of four
  `(CHUNK_T+1)²` × neighbour loops; `_alpha_mask` still resizes 33²/32² → S.
  Expected net **cheaper** than the current path. Treat this as `inferred`, not
  a measured speed-up: the implementing worker must re-run `BAKE_BENCH` and
  report `max_ms`.
- Instrument `_build_chunk` to log, once per bake: number of distinct names,
  names chosen, resolved art keys, and bake time. This makes A1/A5 (§5)
  measurable without a windowed capture.

### 4.5 Keeping summer byte-identical

"Byte-identical" is interpreted the way this codebase uses it at
`game.gd:1142-1145` and `TDR-3` P0-2: **the data and season-selection path**, not
the rendered pixels (which must change — that is the fix).

1. **No `game.gd` edit at all.** `tileblock`, `tbl_names`, `tbl_idx`,
   `tbl_smooth`, `winter_tile_names`, and the RNG streams stay exactly as they
   are; a 20-seed dump before/after must hash identically (A6).
2. `presets_summer.json` / `smooth_summer.json` are read-only; the port's
   Summer index space remains the donor's 124-slot order (§2.1).
3. `_art_name(ti)` keeps its summer branch verbatim
   (`world.gd:1113-1121`): when `_winter_on()` is false it returns
   `game.tbl_names[game.tileblock[ti]]`. Alias/sub-atlas resolution is seasonal-
   neutral texture plumbing, not a season branch.
4. No new `RandomNumberGenerator`, no `_reseed_stage`, no new writes to
   `game.terrain`, `game.height`, `blocked`, `res_nodes`.
5. QA must **not** use "summer screenshot pixel-identical to baseline" as a gate
   for this ticket: a successful fix necessarily changes those pixels. If a
   rollback lever is required for one capture cycle, gate F6/F7 behind a
   project setting (`donor_blend`, default off) and flip it only after A1-A5
   pass — but do not weaken the criteria.

---

## 5. Measurable acceptance criteria — TERRAIN-ONLY test

Use a fixed seed, a land-dominant 64×64 (or larger) generated map, **no trees,
no objects, no water in the sampled crop**, camera at 720p so one tile = 32 px.
Capture one 200×200 px ground crop plus the corresponding `tileblock` dump.
All thresholds below are `derived`/port design choices **except** the TS-1
numbers, which are `observed` from `TERRAIN_REFERENCE_IMAGES.md:111-114,174,179`.

| ID | Criterion | Method | Target | Basis |
|---|---|---|---|---|
| **A1** | Distinct donor block names actually visible | From the dump, count distinct non-water donor names in the 200×200 cell window (`N_gt`). Classify each rendered 32×32 cell against the cached resolved block crops (nearest mean-abs-diff after allowing the world-space offset); count `N_vis`. Log both. | `N_vis ≥ 3` whenever `N_gt ≥ 3`, and `N_vis ≥ N_gt` for `N_gt ≤ 3`; **0** cells rendered by the flat-green fallback (`world.gd:975-976`) or by any gain overlay. Also TS-1 #2: ≥4 tonal patches in the crop. | `derived` from ≤3-composite cap + TS-1:174 |
| **A2** | Border compatibility after smoothing | For every 4-neighbour land pair in a 20-seed dump, find whether both names occur in a common `tbl_smooth` chain; if so, read their group indices. Count pairs with group distance >1. Run the same seed twice and diff. | **0** incompatible pairs after the existing 3 passes; **0** diff between identical seeds. Pairs with no shared chain are reported separately, not silently counted. | donor D5:126-180, :237; port `game.gd:1538-1589` |
| **A3** | Luminance statistics | Pillow: L-std on the 200×200 crop; hi-freq = mean abs(image − `GaussianBlur(5)`); 8-bin luminance histogram at ≥3 % occupancy. Same crops/method as TS-1. | Clean-grass crop: std **8.6 ±3**, hi-freq **2.96 ±1.5**; relief grass crop: std **25-40**, hi-freq **3-12**; **≥3 of 8 bins** at ≥3 %. | `TERRAIN_REFERENCE_IMAGES.md:111-114,174,179` (observed) |
| **A4** | Zero grid / checkerboard periodicity | 2-D normalised autocorrelation of the high-pass residual (crop minus 5-px blur); read lags `(32,0)`, `(0,32)` and integer multiples up to 4 tiles. | Correlation at every tile-spacing lag **< 0.20** and no local maximum **> 0.25**; record the measured peak. Baseline from the current gain build must be recorded in the same table. | `derived` design threshold; checkerboard history `GUIDE4.md:2008`, `SCAN_CALIBRATION.md:135`; no donor number exists — do **not** label as donor fact |
| **A5** | Bake budget | `BAKE_BENCH` low/p x=8, 120 frames, unchanged 2-chunks/frame + LRU 24 + `BLK_CACHE 32`; read engine-emitted `max_ms`. | `max_ms < 250`; regression vs current `125.05 ms` (job 921) must be ≤ +125 ms. Log job id and line. | `SWARM_BACKLOG.md:44`; `app/shots/perf.md:221-251`; `00000921…/stdout.txt:6` |
| **A6** | Summer data byte-identical | Generate 20 fixed seeds before/after; compare base64 `tileblock`, `tbl_names`, `tbl_smooth`, `winter_tile_names`, terrain/height dumps. | **0** differing bytes; no new RNG draws (instrument `_reseed_stage` count). | `game.gd:1142-1145`, §4.5 |
| **A7** | No synthetic field in code | grep the ground path for `_grass_gain(`, `grass_hard_tex`, `GRASS_PATCH_`, `_gain_at(`, `_block_img("grass1")`, `role_block`, `_role_block_names(`. | 0 hits in the `_build_chunk` ground path; `_face_collar`/water/season/relief calls unchanged from baseline. | §4.1 rules 3-4 |

**Reporting rule:** publish a single table with A1-A7 PASS/FAIL plus the raw
numbers (`N_gt`, `N_vis`, names used, incompatible pair count, std, hi-freq,
autocorrelation peak, `max_ms`, dump hash). A criterion without a number is
UNVERIFIED, not PASS. No windowed visual claim ("looks donor-like") may be used
as a substitute for A1-A4.

---

## 6. Claim table — donor fact vs port-authored approximation

Vocabulary: **observed** = literal line/artifact read; **derived** = arithmetic
or code-path consequence; **inferred** = attribution with a stated caveat;
**UNVERIFIED** = not confirmed by the files read. The **Class** column is the
explicit separation the owner asked for.

| # | Claim | Class | Evidence | Verdict | Use / correction |
|---|---|---|---|---|---|
| D1 | A land cell stores a discrete TileBlock **index** into a 124-entry Summer preset; winter is a parallel 124-entry preset | **donor fact** | `terrain.presets:1-6` and following 124 entries; second `SetName=Winter` section; `smoothtiles.inc:32,242`; TDR-3 §3.2:119 | observed | Keep port index space; do not invent a continuous field |
| D2 | `tiles.mat` maps 253 names to textures; 39 summer names are aliases of existing PNGs, not missing art | **donor fact** | `tiles.mat:1-5,143,215,347,558`; TDR-3 §3.2:118; parsed 39 missing names in port `blocks/` | observed + derived | Implement F1/F2; never draw flat green for a preset name |
| D3 | `tiles.lib` carries `Rows/Cols/AngleX/AngleZ`; donor tile art can be a sub-atlas of one texture | **donor fact** | `tiles.lib:52-56`; `tileblocks.json:139-145,650-665` (already exported) | observed | Implement sub-rect crop; angle semantics UNVERIFIED (see U1) |
| D4 | `tilesmooth_scripts.cfg` is 22 sections: 10 Summer + 10 Winter chains + 2 empty terminators; port `smooth_summer.json` is a faithful copy of the 10 Summer chains | **donor fact** | `tilesmooth_scripts.cfg:1-96,97,934,…`; parsed 22 sections and group counts `[4,6,6,9,9,8,6,3,3,5]`; `smooth_summer.json` parsed 141 entries | observed | Trust `tbl_smooth`; no table regeneration needed for Summer |
| D5 | smoother: 64 chains, min group-distance match, roulette replacement, horizontal then vertical sweeps, 3 passes | **donor fact** | `smoothtiles.inc:9-26,63-80,84-187,191-237` | observed | Port `game.gd:1500-1589` already mirrors it; do not re-implement in the renderer |
| D6 | 3 passes is authoritative for random maps despite `TileSmoothPasses=6` in `globalparams.cfg` | **donor fact** | `smoothtiles.inc:237` vs TDR-3 §5 | derived | Keep `passes=3` |
| P1 | Port computes donor-faithful per-cell names and a 3-pass smoother | **port (verified)** | `game.gd:1323-1419,1421-1589` | observed | Generator is out of scope |
| P2 | Port renderer caps to 3/2 names and uses 2×2 fractional coverage, washing rare names to ~0.25 alpha | **port approximation** | `world.gd:63-64,1183-1215,1538-1546` | derived | Root cause B1 → replace with exact per-cell coverage |
| P3 | 39 preset names resolve to a flat-green fallback at runtime | **port defect** | 39 names absent from `blocks/` (parsed); `world.gd:973-976` | observed → derived | F1/F2 |
| P4 | Olive gain field, hard-grain texture and patch grid are port-authored; no donor analogue | **port approximation** | `world.gd:590-658,664-701,1036-1037`; `PIECES/grass_mottled.md:191-193` | observed + inferred | Remove per rule 3; do not defend as "donor logic" |
| P5 | Global `grass1` base and fixed role textures are port-authored | **port approximation** | `world.gd:1523,1552-1593` | observed | Replace with dominant donor block + per-cell names |
| P6 | The 1.12 contrast lift in `_block_img` is port-authored | **port approximation** | `world.gd:982` | observed | Set to 1.0 (F3) |
| P7 | Continuous world-space crop offset per block name is a port seam solution; donor relies on compatible tile art, not on a shared crop offset | **port approximation** | `world.gd:1219-1220,818-856` vs D5 (`observed`); attribution `inferred` | inferred | Keep as anti-seam plumbing; do not describe as donor mechanic |
| P8 | Current bake is `max_ms=125.05` (job 921); the `645.24` row in `perf.md` is an older run and is stale for this ticket | **port measurement** | `00000921_t3world-bench/stdout.txt:6`; `app/shots/perf.md:221-251` | observed | Use 125.05 as baseline, 250 as gate |
| P9 | "Summer byte-identical" means data/dump identity, not pixel identity; pixels must change | **port design rule** | `game.gd:1142-1145`; owner decision context; derived from A6 necessity | derived | QA gate A6, not "pixel-identical" |
| U1 | Exact donor shading semantics of `AngleX=25` / `AngleZ=25` (rotation vs perspective shear, which axis, sign) | **UNVERIFIED** | `tiles.lib` only stores numbers; no donor binary/decompile read | UNVERIFIED | Apply `anglez` as 2-D rotation, document `anglex` as approximation; do not claim donor-exact |
| U2 | Whether the RGBA alpha dropped in DDS→PNG conversion affected tile art | **UNVERIFIED** | TDR-3 §3.2:117 (112 donor RGBA → 112 port RGB) | UNVERIFIED | Out of scope; if blending gaps appear, reconvert preserving alpha in a later ticket |
| U3 | Whether donor's own 3-pass smoother always reaches 0 incompatible adjacent pairs on every seed | **UNVERIFIED** | D5 algorithm observed; no donor map dump available | UNVERIFIED | A2 target is 0 for pairs sharing a chain; if residual >0, report and escalate, do not add a fourth pass |
| U4 | Step ordering: port runs `SmoothTileMap` before the bitmap-detail and forest-border passes; donor runs `SmoothTiles` after `TextureMap` | **port deviation** | `game.gd:1395,1402,1405` vs TDR-1 stage 5f/5g (`generatemap.inc:770-789`) | derived | Leave unchanged in this ticket (byte-identical rule); record as a known, separate fidelity gap |

---

## 7. Open questions

1. **Ownership of `world.gd`** — RENDER-1 per `TERRAIN_BEAUTY_TRIAGE.md:37`; this
   plan assigns no owner. Coordinate before editing.
2. **`anglex` handling (U1)** — accept an approximate 2-D treatment for the
   first build, or defer all angle variants and log them as a divergence?
   Recommend: `anglez` rotation only; report `anglex` names in the bench log.
3. **Strict-pixel regression** — if QA insists on a pixel-identical summer
   baseline, use the one-cycle feature-flag rollback in §4.5; it must not relax
   A1-A4.
4. **Winter smooth chains in the cfg** — sections 11-20 exist with `_winter`
   names; the port only exposes `WINTER_ART` (summer→`winterN`), not a
   `smooth_winter.json`. Out of scope here; note as a follow-up ticket, not a
   blocker for the donor-faithful Summer blend.
5. **Face collar** (`_face_collar`, `world.gd:1364-1496`) is render-only and
   synthesizes lit/shadow ramp + rock8/rock1 overlays. It is *not* the rejected
   grass-gain field and is left untouched, but it is a port approximation and
   should be listed in any future "donor-only" cleanup.

---

## 8. End state

One file written by this agent: `docs/audit/TERRAIN_BLEND_DONOR_PLAN.md`.
No donor asset copied. No Godot run. No `app/` edit. The next build worker has an
implementable, bounded `world.gd` ticket with fixed target lines, a fixed
coverage/alias policy, a 125.05 ms baseline and a 250 ms gate, and seven
measurable terrain-only acceptance criteria that separate donor fact from port
approximation.
