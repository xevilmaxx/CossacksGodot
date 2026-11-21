---
title: Port-side AUDIT — terrain rendering (why the port looks flat)
owner: TPA-1
lane: port-audit (read-only)
decision: D-22 (quality-first)
updated: 2026-11-21
status: complete
scope: read-only. No Godot run, no code/asset edit. Donor assets not accessed (private-use rule SWARM_OPS.md §3.5).
---

# 🔬 Port-side AUDIT — terrain rendering

> [!IMPORTANT]
> Evidence-backed diagnosis of **why the port's terrain reads flat/unbeautiful**
> and concrete, single-file build tickets. Every finding is tagged `observed`
> (direct source read), `derived` (calculation from code) or `inferred`
> (attribution). Unmeasured visual claims are marked **UNVERIFIED**, never
> "done". Protocol: `SWARM_OPS.md` §5b-QUALITY, decision D-22.

**Files owned/changed by this agent:** `docs/audit/TERRAIN_PORT_RENDER.md` only.
**Godot runs:** none. **Donor assets accessed:** none. **Code edited:** none.
**Headline (all `observed` at source level):** the generator computes a rich,
donor-faithful per-cell `tileblock` map (all grass/sand/rock/sandsea/winter/desert
families + the exact 3-pass SmoothTileMap), but the renderer reads that map only
to derive a **single scalar mixing weight between two grass textures**. The
actual named tile-block art is never drawn. Shore/sand/rock "bands" are four
coarse `terrain[]`-type overlays, each a **single fixed texture** feathered by a
smooth alpha mask. That is the concrete mechanism behind "flat".

---

## 1. Sources read (file:line ranges)

| Source | Lines read | Purpose |
|---|---|---|
| `docs/audit/RENDER.md` | 1–365 (full) | prior visual-fidelity audit; claim verdicts; dmask-dead-path correction |
| `docs/audit/GEN.md` | 1–423 (full) | generator quality audit; D-24 320-tile context |
| `docs/STATUS_GRAPHICS.md` | 1–283 (full) | status, ownership map, open fidelity tickets P-20/21/32/36/46/47 |
| `docs/TERRAIN_GEN_RESEARCH.md` | 1–86 (full) | donor pipeline: pattern stamping, 3-pass coastline smoothing, donor texture families |
| `app/scripts/world.gd` | 1–1963 (full) | renderer — base, masks, chunks, water, decor, fog, FX |
| `app/scripts/game.gd` | 870–1179 (`_load_terrain_structs`, `_apply_detail_pass`, `_assign_tileblocks`, `_shore_tile_for`, `_cliff_tile_for`, `_apply_shore_cliffs`, `_tb_pick`); plus grep hits 38–39, 229–243, 307–326, 387–438, 518–595, 654–740, 801, 995–1006 | tile-block/terrain data production |
| `app/scripts/data.gd` | 23, 55, 113–126, 152–158, 179–197 | `TERRAIN_PX`, `TILE_M`, `SHOW_CENTROIDS`, quality presets, `TERRAIN_TINT` |
| `app/scripts/main.gd` | 883 (grep hit) | dead `terrain_masks` assignment |
| `app/assets/terrain/blocks/*.png` | glob | block family inventory (grass1..10, sand1..9, sandsea1..6, rock1..9, desert1..12, winter0..26, test0..25) |
| `app/assets/terrain/water_png/*.png` | glob | `diffusewaves0..7.png` (8 donor wave sheets) |
| `docs/research/RC_TERRAIN.md` | 105–122, 145–158, 174–187 | donor-vs-port matrix, season texture-swap gap, G1/G3/G7/G8 tickets |
| `SWARM_BACKLOG.md` | 44 (N-07 row) | perf constraint |
| `app/shots/perf.md` | 60–99 | N-07 telemetry (FPS/hitch NOT measured) |
| `docs/audit/CONFIG_EFFICIENCY.md` | 197–199, 227–228, 333 | chunk-Budget mechanism confirmation |

---

## 2. Render pipeline walkthrough

Every row below is `observed` at the cited source line unless tagged otherwise.

| Stage | file:line | Mechanism | Beauty implication |
|---|---|---|---|
| Quality budgets | `data.gd:113-114,152-158`; `world.gd:28,126` | `TERRAIN_PX` = 8/12/16 (low/med/high); `TILE_M=2.0`; `view_scale=16 px/m`. | High preset gives 16 baked px per 2 m cell → 32 screen px/cell; detail budget is capped, not adaptive. |
| Block LRU warm-up | `world.gd:47-49,131-135` | `_block_img` pre-warms 12 common names; `BLK_CACHE=32` with touch-on-hit eviction. | Bakes stay cheap — a constraint any fix must respect. |
| Water sheet load | `world.gd:674-682` | **Only** `water_png/diffusewaves2.png` loaded; mirror-tiled to 1024 px. 7 sibling wave sheets exist (`water_png/`) but are never loaded. | Water has one source sheet, not the donor's wave set. |
| "4 wave variants" prep | `world.gd:683-691` | Four 256 px phase crops stored in `variants[3]`. **Dead:** repo-wide grep finds `variants` only at `:62,127,683,691` — never read by draw code. The comment at `:684-688` describes a mechanism that does not run. | No discrete wave animation; the advertised 4-frame shimmer is vestigial code. |
| Block image build | `world.gd:695-717` | `_block_img(nm)` loads `blocks/<nm>.png`, `_mirror_tileable` to 1024, one `adjust_bcs(1.0,1.12,1.0)` grain lift; LRU 32. | Every loaded donor block is available here — the asset is present, just unused by the draw path (see blocker B1). |
| Seamless crop | `world.gd:619-638,640-657` | `_mirror_tileable` (mirror X/Y/corner) + `_wrap_crop` (modular blits). | Anti-seam is real for whichever texture is sampled; not a beauty blocker. |
| **Base layer = ONE texture** | `world.gd:803-806` | `_wrap_crop(_block_img("grass1"), cx*S, cy*S, S)` — the entire chunk is one continuous grass1 crop; **no per-cell texture switch**. | `derived`: at high preset `cx*2048 mod 1024 = 0`, so every chunk samples grass1 from origin 0 → base detail repeats every 32 tiles (64 m). Seamless but visibly tiled. |
| **Mottling = hash weight over TWO grass textures** | `world.gd:814-837` | `block_at` (`:815-816`) returns the donor tile-block **name** only to compute `sum += 0.10 + 0.28*hash(name)` (`:831`), averaged over the 4 surrounding tiles into `mix_grid`; `grass7` is blended over `grass1` by that scalar via `_alpha_mask` (`:754-761`, `:835-837`). | **The named block art is discarded.** sand/rock/sandsea/desert/winter blocks all collapse to the same two grass textures with a different opacity. This is the single biggest flatness mechanism. |
| Role overlays | `world.gd:841-875` | `role_block = {1:"ground1", 2:"grass_ground2", 4:"grass_sand1", 5:"rock1"}`; loop over terrain types `[1,2,4,5,3]`; each builds a smooth 33×33 grid from `game.terrain[]` (`:853`) and blends **one** fixed crop via alpha mask (`:875`). | Sand band = feathered `grass_sand1` only (no `sandsea1..6` orientation); rock/cliff = `rock1` only (no `rock4/7/8` cliff orientation); dirt = `ground1` only. Coarse 4-texture wash instead of donor tile families. |
| Water overlay | `world.gd:860-870` | `phase = int(anim_t*12.0) % 1024` (`:864`); `_wrap_crop(ter_water, cx*S+300+phase, cy*S+700, S)` (`:865`); constant blue glaze `ter_blueA` dithered 60% (`:866-870`, built `:739-749`). | Water is one scrolling crop + flat blue tint. No foam, shoreline wet-sand, glints or current (RC_TERRAIN G8 `NO`). Shimmer occurs only when a chunk is **re-baked** (cache hit = frozen). |
| **Water timing / caching** | `world.gd:934-945,865` | `_sync_terrain_chunks` builds a chunk **once** and caches it in `terrain_chunks` (LRU 24). `anim_t` is sampled at bake time only. | `derived`: a standing camera never re-bakes, so the wave phase is frozen — "animated water" does not animate during idle view (P-21 still open per STATUS_GRAPHICS.md:148). |
| Season / relief | `world.gd:763-796,880-905` | `_season_tint()` returns a flat multiplicative colour + 0.34 alpha glaze (`:791-795`); `TERRAIN_TINT` summer/winter/desert at `data.gd:191-195`; relief darkens valleys (`shade = 0.10 - hh*0.04*rscale`, `:900`). | Winter/desert are a **colour glaze**, not a texture-family swap — `winter0..26`/`desert*` blocks are converted but unwired. Confirms RC_TERRAIN.md:117-120 at the current code level. |
| Supersample resolve | `world.gd:906-918` | Bilinear downsample 64→16 px (`:907-908`); `TEXTURE_FILTER_LINEAR` (`:915`); `Sprite2D z=-10` (`:916`). | No nearest-neighbour base scaling — rules out one common "flat" cause. |
| Chunk amortization | `world.gd:930-945` | Max **2** new chunks per `sync()`, LRU cap **24**, `queue_free()` on evict. | Same budget as N-07 (`SWARM_BACKLOG.md:44`); any fix must not raise per-bake cost past the <250 ms hitch target. **UNVERIFIED:** perf.md:92-93 records hitch/FPS `not measured`. |
| Decor redraw gate | `world.gd:957-971` | `res_layer.queue_redraw()` only when `moved or game.res_dirty != res_dirty` (`:960-962`). | `derived`: ground decor does **not** redraw per frame — no sway/animation possible without changing this gate. |
| Sprite helper + shadows | `world.gd:557-568` | `_draw_sprite` scales texture to `world_h*m`, anchors foot at `0.82` height (`:565`); contact circle only if `QUALITY!="low" and SHOW_CENTROIDS` (`:566-567`). | `SHOW_CENTROIDS` defaults **false** (`data.gd:125`) → the helper's shadow is off by default; decor relies on manual blobs (below). |
| **Trees** | `world.gd:1152-1180` | Baked sprite via `_prop_tex(["tree_fir","tree_fir","tree_pine","tree_oak"])` (`:1154`); dark olive lift `Color(1.18,1.26,1.06)` (`:1161`); height `_env_sprite_h(12.5,"tree")` = 12.5 m × 0.85–1.15 hash jitter (`:1115-120`, `:1160`); contact shadow via `_blob_rect` 24–34×12–17 px @0.16 (`:1158-1159`). Fallback: procedural pines/oaks (`:1163-1180`). | Static sprite/triangle clumps; no sway; height jitter is positional-hash, not time. Matches "bush/stump only" decor finding (RC_TERRAIN.md:154). |
| **Stumps** | `world.gd:1133-1140` | `_prop_tex(["tree_stump","rock","stone"])`, `_draw_sprite(..., 0.55, tint brown, **shadow=false**)` (`:1136`); fallback circle+rect (`:1138-1139`). | No contact shadow on the sprite path; flat 0.55 m stump. |
| **Bushes** | `world.gd:1141-1150` | `_prop_tex(["bush_rock","bush_sand","rock"])`, `_draw_sprite(..., 0.8, white, **shadow=false**)` (`:1144`); fallback 3 circles (`:1146-1149`). | No contact shadow on sprite path; single 0.8 m sprite, no animation. |
| **Rocks / ore** | `world.gd:1181-1227` | Rock `_prop_tex(["rock","stone"])`, height 2.8 m, `_blob_rect` shadow @0.2 (`:1184-1185`); ore outcrop 3.5 m + tinted ring + coloured circles (`:1199-1227`). | Static blobs; no cast shadow direction; ore halo is a flat ellipse. |
| **Fields** | `world.gd:1073-1115,1192-1194` | `_field_growth` from `hits/max_hits`, mill regrow over `game.sow_t/60` (`:1078-1085`); `_draw_field` draws stalk lines + head circles procedurally (`:1087-1115`); circle shadow @0.15 (`:1088`). Comment `:1076-1077` confirms **no crop-stage sprite exists**; donor `envfieldd/deco_png` decals present on disk but unused. | Fields are procedural sticks/beads, not donor `envfieldd` art — visible flatness in farms. |
| Fog | `world.gd:18-24,147-162,979-1021` | Per-tile alpha `ImageTexture` (0.78 unexplored / 0.30 explored / 0 visible), `FOG_OF_WAR` default **false** (`data.gd:55`). | With default config, fog is hidden; not a flatness cause in default shots. |

---

## 3. Beauty-blocker table

`observed` = direct source read; `derived` = consequence computed from that code.

| # | Blocker | Evidence (file:line) | Severity | Donor comparison | Fix sketch (single file) |
|---|---|---|---|---|---|
| **B1** | **Named tile-block art is computed but never rendered.** `game.tileblock`/`tbl_names` (full donor families + 3-pass smoothing, `game.gd:1011-1080`) are read by the renderer **only** to produce a scalar `hash(name)` weight between grass1 and grass7 (`world.gd:815-816,831`). No cell ever draws its selected `sand*`/`rock*`/`desert*`/`winter*` texture. | `world.gd:815-816,831,836-837`; grep: only 2 tileblock references in renderer; `game.gd:1011-1080` | **P0 — root cause of flatness** | Donor `texturemap.inc` + `smoothtiles.inc`: every cell gets a specific TileBlock from tiled families, blended only at borders via 3 SmoothTileMap passes (`TERRAIN_GEN_RESEARCH.md:33-41,70-73`); port does the data pass but renders two grasses. | In `world.gd`: build a cached mirror-tiled atlas of the blocks actually present in a chunk and composite it in `_build_chunk` using the existing `_alpha_mask` grid (one cached crop per distinct block name, max a handful per chunk) instead of the `hash`-only mix. Keep bakes ≤ budget. |
| **B2** | **Shore/sand/rock bands are single fixed textures, not oriented donor families.** Sand = `grass_sand1`, rock = `rock1`, dirt = `ground1`, forest = `grass_ground2` only; the oriented `sandsea1/5/6` and cliff `rock4/7/8` tiles chosen in `game.gd:1082-1161` are never drawn. | `world.gd:841-875`; `game.gd:1082-1161` | **P0** | Donor keys shore tiles off the height gradient into 8 sectors and selects oriented beach/cliff tiles (`TERRAIN_GEN_RESEARCH.md:26-27`, `game.gd:1082-1161` comments). | In `world.gd`: replace the `role_block` constants with the per-cell block name for the role cells, using B1's atlas; verify a screenshot shows a multi-tile shore/cliff band. |
| **B3** | **Water is one sheet + flat blue glaze, cached so shimmer freezes.** Only `diffusewaves2.png` is loaded; the four prepared `variants[3]` are dead; phase sampled at bake time only; standing camera never re-bakes. | `world.gd:674-691,739-749,860-870,934-945`; grep `variants` | **P1** | Donor water is an animated wave surface with glints/current (`RC_TERRAIN.md:23,157`; G8). Port's one scrolling crop is a "cheap time-based shimmer" (`:861-863`) that stalls on cache hits. | In `world.gd`: either draw a small animated water overlay layer driven by `anim_t` per frame (no re-bake), or invalidate only water chunks on a coarse timer; delete dead `variants[3]`. |
| **B4** | **No blending into shoreline — feathered overlap of two coarse layers only.** Every role is a full-chunk crop cross-faded by an alpha grid; there is no wet-sand→water transition, foam, or per-tile coastal mask. | `world.gd:842-875` (`blend_rect_mask` loop) | **P1** | Donor `texturemap.inc` shore thresholds + 3-pass coastline smoothing (`TERRAIN_GEN_RESEARCH.md:26-27`). | In `world.gd`: add a thin coastal transition band from B1's atlas; screenshot acceptance at a coastline. |
| **B5** | **Season = flat colour glaze, not texture swap.** `winter0..26`/`desert*` blocks converted but unwired; `_season_tint` multiplies one alpha-0.34 colour over the whole chunk. | `world.gd:763-796,880-890`; `data.gd:191-195`; `TERRAIN_GEN_RESEARCH.md:73`; `RC_TERRAIN.md:117-120` | **P1** | Donor swaps the whole ground/prop texture set per season (`RC_TERRAIN.md:55,145-148`). | In `world.gd`: route winter/desert block families through B1's atlas when `_season_key()` is set; keep the tint as a light multiplier. |
| **B6** | **Decor has no cast shadows or animation; fields are procedural sticks.** Sprite contact shadows are disabled by default (`SHOW_CENTROIDS=false`); tree/rock blobs are static flat discs; stumps/bushes pass `shadow=false`; field has no donor decal. Decor never redraws per frame. | `world.gd:566-567,960-962,1133-1150,1158-1159,1184-1185,1087-1115`; `data.gd:125`; `RC_TERRAIN.md:154` | **P2** | Donor decor families (`dcr1-3`, animated trees) and `envfieldd` field decals exist on disk (`TERRAIN_GEN_RESEARCH.md:75`; `RC_TERRAIN.md:154`). | In `world.gd`: enable a directional soft shadow blob for tree/rock/stump/bush; draw `envfieldd` decal for `food` nodes; optionally drive a subtle sway via `anim_t` with a per-frame redraw gate. |
| **B7** | **Base texture repeats every 32 tiles at high/low preset.** `cx*S mod 1024 = 0` → all chunks sample grass1 from origin 0. | `world.gd:806`; `data.gd:158`; derived from `S=32*bpx`, `bpx=64`; corroborated `RENDER.md:204-210` | **P2** | Donor tiled patterns vary per cell and are smoothed; no global 64 m repeat. | In `world.gd`: use a chunk offset that advances by an irrational/prime stride mod 1024, or fold B1's per-cell atlas in so the base is not one repeat. |

**Severity key:** P0 = directly causes the "flat/unbeautiful" reading; P1 = strong fidelity gap; P2 = polish.
**Important nuance (`observed`):** the port **does** blend — `_alpha_mask` writes coverage to the alpha channel (`:754-761`) and `blend_rect_mask` cross-fades over a full tile; the supersample downsample (`:907-908`) softens edges. So "no blending" is **not** the defect; the defect is *what* is being blended (B1/B2). This refines the `PARTIAL` verdict in `RENDER.md:72,216-222`.

---

## 4. Claim table

| # | Claim | Evidence | Method | Verdict | Correction |
|---|---|---|---|---|---|
| 1 | "Terrain tiles blend without seams" | `world.gd:754-761,837,875,907-908,915` | Source read; Godot `blend_rect_mask` alpha semantics (per RENDER.md §B.1) | **CONFIRMED for the operative path** — alpha masks + coherent grid + bilinear resolve | Visual seam check still **UNVERIFIED** (no windowed capture this audit); do not call it a beauty proof. |
| 2 | "Each map cell shows a random crop of the real texture" (header comment `world.gd:2-5`) | `world.gd:803-806,814-837`; grep tileblock | Source read + call-site grep | **CONTRADICTED** — `_crop_variant` (`:594-609`) is never called by `_build_chunk`; the base is ONE continuous grass1 crop and the block name only sets a mix scalar. | Header comment is stale; rewrite to describe continuous grass + role overlays, or make it true via B1. |
| 3 | "Random per-tile test7/8/9 speckles were removed because they checkerboarded" | `game.gd:1017-1024` | Source read | **CONFIRMED** (generator) — speckles removed; meadow variety now from detail bitmaps (`:1071-1077`) | None; but note the renderer does not use the resulting block variety (B1). |
| 4 | "Four wave variants animate water" | `world.gd:683-691,861-865`; grep `variants` | Source read + repo-wide grep | **CONTRADICTED** — `variants[3]` is dead; one `ter_water` crop scrolls only at bake time | Comment `:684-688` must be corrected; water "animation" is cache-dependent (B3). |
| 5 | "dmask anti-seam masks are the live seam defence" | `world.gd:727-750`, `main.gd:883`; `RENDER.md:158-184` | Prior audit + source read | **CONTRADICTED** — `_build_masks` returns `[]`; dmask array dead | Already ticketed P-36; this audit does not re-litigate it. |
| 6 | "No season texture swap in world.gd" (`RC_TERRAIN.md:117-118`) | `world.gd:763-796,880-890` | Source read | **PARTIAL / stale** — there is now a flat seasonal tint glaze, but still no winter/desert **block-family** swap | Update RC_TERRAIN phrasing: tint exists, texture swap absent. |
| 7 | "Water 0% on seeds 8/9 is a defect" | `GEN.md` claim 9 / branch E | Prior audit | **CONTRADICTED** there — land masks are correctly dry | Out of scope here; recorded only so this doc is not read as reopening it. |
| 8 | "<250 ms chunk-bake hitch is verified" | `SWARM_BACKLOG.md:44`; `app/shots/perf.md:92-93` | Source read | **UNVERIFIED** — perf.md records FPS/hitch `not measured`; only 2-chunks/frame + LRU 24 mechanisms confirmed (`CONFIG_EFFICIENCY.md:197-199`) | Treat 250 ms as a design target, not a passed gate; new tickets must add the measurement. |
| 9 | "Decor casts shadows / animates" | `world.gd:566-567,960-962,1133-1150`; `data.gd:125` | Source read | **CONTRADICTED** — helper shadow gated behind false-by-default flag; decor redraw gated on camera/dirty; no per-frame sway | Needs B6 to make it true. |

---

## 5. Recommendations — concrete build tickets

Constraints that apply to **every** ticket: read-only audit lane; the implementing
worker must back up the owned file (`SWARM_OPS.md` §3.3) and run the §7 gates of
`STATUS_GRAPHICS.md`. Perf budget (N-07, `SWARM_BACKLOG.md:44`): keep the
2-chunks/frame cap and LRU 24 (`world.gd:930-945`), keep a single-frame bake
hitch under 250 ms — a target that is currently **UNVERIFIED** and must be
measured as part of acceptance. Owner names are from `STATUS_GRAPHICS.md:202-214`.
`world.gd` is held by **AB** until P-09 (D-10) closes — coordinate before assigning.

### Ticket TR-1 — Render the donor tile-block atlas (owner AB; file `app/scripts/world.gd`)
- **Target:** `_build_chunk` base + mix, `world.gd:803-837`; reuse `_block_img` `:695-717` and `_alpha_mask` `:754-761`.
- **Change:** replace the `hash(name)` scalar mix with a cached, mirror-tiled crop per distinct `block_at` name present in the chunk; composite via the existing 33×33 smooth grid + `blend_rect_mask`. No changes to `game.gd` — consume the `tileblock`/`tbl_names` arrays as-is.
- **Acceptance:** (a) a windowed screenshot of the same seed/camera showing visibly different grass/sand/rock textures across adjacent cells (not one green wash); (b) `print`/instrument `_build_chunk` to show max single-bake time over 120 frames on the **low** preset is **< 250 ms**, with 2-chunks/frame and LRU 24 unchanged; (c) no new seams across a chunk border (adjacent-chunk pixel diff at the border ≤ existing baseline).

### Ticket TR-2 — Replace coarse role overlays with oriented shore/cliff blocks (owner AB; file `app/scripts/world.gd`)
- **Target:** `role_block` map and overlay loop, `world.gd:841-875`.
- **Change:** for terrain roles 4 (sand) and 5 (rock/cliff), feed the per-cell `game.tileblock` name (which already encodes `sandsea1/5/6`, `rock4/7/8` via `game.gd:1082-1161`) into TR-1's atlas instead of the constants `grass_sand1`/`rock1`. This is a **world.gd-only** change; `game.gd` needs no edit.
- **Acceptance:** windowed coastline screenshot showing ≥3 distinct beach/cliff tiles in the band, compared with the current single-tile version; frame-time budget unchanged from TR-1.

### Ticket TR-3 — Correct the wave-variant dead code and make shimmer real (owner AB; file `app/scripts/world.gd`)
- **Target:** `_prep_variants` `:683-691`, water overlay `:860-870`, comment `:684-688`.
- **Change:** delete the unused `variants[3]` prep (or wire it to an animated per-frame water overlay drawn outside the cached chunk); fix the comment. If animation is kept cache-based, add a coarse invalidation timer for water chunks only.
- **Acceptance:** two windowed frames 1 s apart with a standing camera show a different wave phase (measured by a pixel-diff of a water-only crop > 0); comment no longer claims an unused mechanism; bake budget unchanged.

### Ticket TR-4 — Wire winter/desert block families (owner AB; file `app/scripts/world.gd`)
- **Target:** `_season_key`/`_season_tint` `:772-796`, tint glaze `:880-890`.
- **Change:** when `_season_key()` is `"winter"`/`"desert"`, select the corresponding `winter*`/`desert*` block names in TR-1's atlas; reduce the flat tint to a light multiplier. No `data.gd` change needed (`TERRAIN_TINT` already exists).
- **Acceptance:** one screenshot per season of the same seed showing season-specific ground texture detail (not only a colour cast); `winter0..26` files demonstrably loaded (instrument `_block_img`).

### Ticket TR-5 — Make fields use the donor decal + enable decor contact shadows (owner AB; file `app/scripts/world.gd`)
- **Target:** `_field_growth`/`_draw_field` `:1073-1115`, decor branches `:1133-1227`, `_draw_sprite` `:557-568`, redraw gate `:960-962`.
- **Change:** draw `res://assets/terrain/deco_png/envfieldd.png` for `food` nodes (scale/anchor like other props); enable one shared soft shadow blob for stump/bush/tree/rock by passing a shadow texture rather than relying on the `SHOW_CENTROIDS`-gated circle. Optionally gate a subtle per-frame decor redraw via `anim_t`.
- **Acceptance:** windowed farm screenshot showing the field decal; per-prop shadow visible in a zoomed crop; if animation is added, a frame-time measurement stays under the N-07 budget.

### Ticket TR-6 — Instrument and record the chunk-bake hitch (owner QA O; file `app/shots/perf.md`)
- **Target:** `app/shots/perf.md:69-99` (currently `not measured` at `:92-93`).
- **Change:** add a headless/windowed bench that records max single-frame chunk-bake time over 120 frames on the **low** preset, with the 2-chunks/frame + LRU 24 settings unchanged; log the runner job id.
- **Acceptance:** `perf.md` contains a measured max-hitch number and a PASS/FAIL against the 250 ms N-07 target; replaces the current "NOT MEASURED" rows.

**Deliberately not filed as code tickets here:** the generator work (P-46/P-47) and QA calibration (P-48) already exist in `docs/audit/GEN.md`, and the dmask cleanup P-36 already exists in `RENDER.md`. This audit adds no duplicate ticket and proposes no `game.gd`/`data.gd` edit — the missing behaviour is in the renderer.

---

## 6. Open questions

1. **Visual confirmation of B1/B2.** Source-level mechanism is `observed`; the actual on-screen "flatness" is **UNVERIFIED** without a windowed capture. Who may run a windowed build and supply same-seed before/after shots? (Compare `docs/UNIT_BAKING_FIX.md` §7: headless `--screenshot` writes nothing here.)
2. **World.gd ownership/contention.** AB holds `world.gd` until P-09 closes (`STATUS_GRAPHICS.md:206`). Are TR-1…TR-5 assigned to AB after P-09, or to a new owner? Cross-file edits are a REVIEW BLOCK (§3).
3. **Exact donor shore/cliff family mapping.** The port's `game.gd:1082-1148` mapping to `sandsea`/`rock` names is documented as donor-derived by code comments, but was not re-decompiled here (`TERRAIN_GEN_RESEARCH.md` donor scripts were not accessed). Confirm with decomp lane before changing names.
4. **Perf budget reality.** N-07's <250 ms is a target, not a passed gate (`app/shots/perf.md:92-93`). TR-6 must measure before TR-1…TR-5 can claim "within budget".
5. **Water animation approach.** Per-frame overlay vs cache invalidation: does any GPU/shader budget rule forbid an extra animated water layer? (P-21 owns water/weather; coordinate before implementing TR-3.)
6. **Decor sprite availability.** `_prop_tex` names (`tree_stump`, `bush_rock`, `bush_sand`) depend on sprites being loaded at `world.gd:211-241`; whether each resolves is **UNVERIFIED** without a sprite-inventory check at runtime. If absent, TR-5 falls back to procedural shapes.

---

**Bottom line:** the port's terrain is flat not because it lacks donor art or blending, but because the renderer throws away the donor tile-block map it already computes and composites a handful of fixed textures with smooth alpha masks. Fixing that in `world.gd` (TR-1/TR-2) is the highest-leverage change; perf must be measured (TR-6) before it can be called within the N-07 budget.
