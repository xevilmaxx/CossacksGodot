---
title: Deep audit — TERRAIN PORT DECOR (trees / bushes / stumps / ground decor)
owner: TPA-4 (TB-A4)
decision: D-22 / TERRAIN-BEAUTY WAVE Lane 1
updated: 2026-11-21
status: complete
scope: read-only. No Godot run, no code, script, asset, screenshot or status doc edited.
---

# 🔬 Deep audit — TERRAIN PORT DECOR

> [!IMPORTANT]
> Quality-first protocol (`SWARM_OPS.md` §5b-QUALITY, `docs/audit/README.md`,
> decision D-22). Every finding below is tagged `observed` (read directly from
> the named file:line or a PNG byte measurement), `derived` (logic followed from
> cited code) or `inferred` (judgement, explicitly labelled). Anything not
> confirmed in this lane is marked **UNVERIFIED**. No donor asset was accessed
> and no Godot process was run (`SWARM_OPS.md` §3.5 private-use rule).

**Files owned/changed by this agent:** `docs/audit/TERRAIN_PORT_DECOR.md` only
(per `SWARM_BOARD.md:143` TB-A4).
**Godot runs:** none. **Donor assets accessed:** none.

---

## 1. Sources read

**Port code / data (all read directly):**
- `app/scripts/world.gd` — `bind` `:122-204`, `_load_sprites` `:211-241`,
  `_draw_sprite` `:557-568`, `_blob_rect` `:521-525`, season/relief
  `:763-796` and `:876-904`, `_sync_terrain_chunks` `:920-945`, `sync`
  `:947-974`, `_hash`/`_prop_tex` `:1039-1071`, `_field_growth`/`_draw_field`
  `:1073-1115`, `_draw_resources` `:1117-1227`.
- `app/scripts/game.gd` — `_add_res` `:362-370`, `_paint_terrain` `:377-394`,
  `_scatter_forest` `:396-421`, `_scatter_bushes` `:423-453`, `_gen_patterns`
  `:482-586`, base terrain `:660-747`, `_gen_forests` `:753-766`,
  `_gen_resources` `:768-798`, `_gen_finish` `:835-869`, forest-border pass
  `:1078-1080` + `_stamp_forest_borders` `:1250-1262`, stump aging
  `:2940-2948`, chop→stump flip `:3995-4017`, build/footprint guard `:2745-2747`.
- `app/scripts/pattern_gen.gd` — `:1-267` (families, stamps, occupancy,
  `recipes` `:247-265`).
- `app/scripts/data.gd` — `TILE_M` `:23`, `MAP_W/H` `:33-34`, `RANDOM_SEED` `:35`,
  `UNITS`/`BUILDINGS` `:1150-1158`.
- `app/assets/terrain/patterns/donor_patterns.json` — read-only JSON parse:
  **37 families / 218 patterns**; decor family `dcr1/dcr2/dcr3`,
  `decor_big:["big_hill_1"]`, **15** `forests_*` families (observed with Python:
  `forests_leaf_big/med/small`, `mixed_big/med`, `pine_big/big_2/med/small`,
  `pinedrygreen_small`, `pinefir_big/med/small`, `spruce_big/med`).

**Inventory (glob + Pillow 12.1.1 on local PNG bytes):**
`app/assets/models/sprites/**`, `sprites_hi/**`, `tex/**`,
`app/assets/terrain/deco_png/**`, `app/assets/terrain/decals_png/**`,
`app/assets/models/anim/**`.

**Evidence dumps (read-only JSON):** `scans/scan_7.json`, `scan_8.json`,
`scan_9.json`, `scans/implpattern_7.json`, `_8.json`, `_9.json`
(counts in §2 / §4; snapshot-to-HEAD mapping is **UNVERIFIED** — no Godot run).

**Prior docs:** `docs/TERRAIN_GEN_RESEARCH.md`, `docs/research/RC_TERRAIN.md`,
`docs/audit/RENDER.md`, `docs/guides/GUIDE4.md` (L3 `:423-544`, L4 `:546-632`,
Appendices `:1125-1152`, TUNING-LOG `:2310`), `SWARM_BOARD.md`
(`:124-183`), `SWARM_BACKLOG.md` (N-07 `:44`), `app/shots/perf.md` (`:62-94`).

**Stale line citations in the task brief (correction, `observed`):** the brief's
`game.gd:379-407 bushes`, `:674-731 groves`, `:2384-2388 stumps` do **not**
point at decor code in the current tree. Present-day locations are
`_scatter_bushes` `game.gd:425-453`, groves `game.gd:753-766` + `:855-858`,
and the stump flip at `game.gd:4006-4011`; `game.gd:2384-2388` is inside
`squad_remove()`. All citations in this report use current lines.

---

## 2. Decor pipeline table

| Stage | file:line | Mechanism | Naturalness implication (`observed`/`derived`) |
|---|---|---|---|
| Sprite bake / registration | `world.gd:211-241`; whitelist `:219` | Loads exactly `tree_fir, tree_oak, tree_pine, rock, stone, field` (+ unit/building sids). `tree_*` prefer `sprites_hi/<key>.png` (`:236-238`), single texture, no frame list. | **observed**: 3 tree sprites, each **1 static frame**, no direction sheet. No bush/stump/flower/crop-stage sprite is registered. |
| Sprite pick | `world.gd:1039-1071` `_prop_tex` | `_hash(pos)` → `names[int(h*n)%n]`; returns `frames[0]` or **null** when that key is absent (`sprites.get(pick, [])` `:1068`). | **derived**: a missing name is not a safe fallback — it returns null for that hash bucket only. GUIDE4 `:577` ("never null-draw") is wrong (§5). |
| Family stamping | `pattern_gen.gd:37-267`, recipes `:249-262` | Donor `.pattern` footprints scaled by `s = map_w/160` (`:47`), weighted pick (`:104-123`), rejection via occupancy (`:85-102`), elliptical keep-clear (`:164-178`). | **observed**: 37 families exist in JSON but only `forests_pine_small`, `stones`, `stoneforests`, `hills_dark`, `hills_light`, `decor`, `dcr1` are reachable (`:255-261`). `dcr2`, `dcr3`, `decor_big/big_hill_1`, spruce/leaf/pinefir/mixed-big families are present but **never stamped**. |
| Stamp → node | `game.gd:485-586` | Per stamp cell: forest → ≤10 wood nodes at 10% (`:543-545`); decor → bush at 10% (`:562-565`); stone/mine → terrain paint + nodes (`:549-581`). Filled sod disc `:503-524`. | **derived**: donor multi-object clumps are reduced to "≤10 random points inside a painted disc"; tree spacing inside a clump is uniform-random, not the donor's authored pattern geometry. |
| Sacred groves | `game.gd:753-766`, re-plant `:855-858` | 26 + 18 trees per start (scaled), paint type 2 first. | **observed**: fixed count and fixed offsets `(7,-7)`, `(-8,5)`, `(9,-8)`, `(-10,6)` tiles; identical shape at every start. |
| Bush scatter | `game.gd:425-453` | 40 attempts; near stone on terrain 1/5 at 50%, or terrain 4 at 30%; no blocking (`_add_res` guard `:368`). | **observed**: bushes are near-quarry/near-shore only; ≤40 attempts means a hard ceiling of 40 bushes from this path. |
| Chop → stump | `game.gd:4006-4015`; aging `:2940-2948` | Wood node becomes `type="stump"` with `stump_t=0`, unblocked same tick; removed after 60 s. | **observed**: stump is a **resource-node flag**, not a placed decor pattern. GUIDE4's "pale stumps dot the clearing" is simulated only by a tinted sprite/procedural disc. |
| Node → draw | `world.gd:1117-1227` | `_draw_resources`: stump `:1133-1140`, bush `:1141-1150`, wood `:1152-1180`, stone `:1181-1191`, ore `:1195-1227`, food `:1192-1194`. | **derived**: all decor lives on `res_layer` (z=1) and is culled by `view_rect.grow(64)` (`:1130`); no per-frame animation. |
| Scale / jitter | `world.gd:115-120`, `:1160`, `:1185`, `:1209` | `_env_sprite_h`: donor `envscales.cfg` values (`mine 0.3152, stone 0.329, tree 0.5`) × deterministic 0.85–1.15 hash jitter. Tree base 12.5 m, stone 2.8 m, mine 3.5 m. | **observed**: trees **do** have ±15 % size variation. Bushes/stumps use fixed `world_h` 0.8 / 0.55 and **no** env jitter (`:1144`, `:1136`). |
| Rotation / facing | `world.gd:557-568` | `draw_texture_rect` only; no `draw_set_transform`, no per-object angle stored on the node. | **observed**: every tree/bush/rock is an axis-aligned billboard with the same silhouette orientation. |
| Shadow | `world.gd:1158-1159` (tree `_blob_rect`), `:566-568` (generic `_draw_sprite` shadow) | Tree draws a soft dark ellipse unconditionally; bushes/stumps pass `shadow=false` (`:1144`, `:1136`); generic shadow is gated by `Data.SHOW_CENTROIDS` and `QUALITY != "low"`. | **derived**: trees have contact shadow; bushes/stumps have none (GUIDE4 `:510` "NO shadow disc" for bushes is intentional). |
| Season / relief | `world.gd:763-796`, `:880-890` | `_season_key()` → `Data.terrain_tint(season)` applied as a 0.34-alpha glaze to the **terrain chunk image** only. | **observed**: no per-prop sprite swap; a winter tree is the same olive sprite on tinted ground. No spring/autumn. |
| Crops | `world.gd:1073-1115` `_draw_field` | Procedural `draw_line` + `draw_circle` stalks; growth from `hits/max_hits` and `game.sow_t`. Code comment `:1075-1077` says no crop-stage sprite exists. `field.png` is loaded (`:219`) but never drawn (grep found no other reference). | **observed**: no donor field decal in render path; `deco_png/envfieldd.png` is used only by the preview tool `app/tools/gen_variant_maps.py:188`. |
| Redraw cadence | `world.gd:947-974`, `:960-962` | `res_layer.queue_redraw()` only when the view moved or `game.res_dirty` changed; `anim_t` advances every frame but feeds only mill rotor, water shimmer, unit bob/FX (`:963-968`, `:1358`, `:1415`, `:1570`). | **derived**: **decor cannot sway** — nothing re-draws `res_layer` on an idle camera. |

**Observed node counts from dumps** (read-only JSON, `res[].t`):
`scans/implpattern_7/8/9` (mtime 09:39, post-P-46): wood **264 / 264 / 251**,
bush **219 / 237 / 238**, stone 107/135/138, food 173/168/173, ore 8 each,
stump 0 at generation time. Older `scans/scan_7/8/9` (mtime 07:10) show wood
529/545/530 and bush 208/280/214. **UNVERIFIED** which dump exactly matches
current HEAD (no Godot run in this lane); the P-46 tuning log
(`GUIDE4.md:2310`) names `implpattern_*` as its post-fix run.

---

## 3. Asset inventory table

Dimensions measured with Pillow from local PNG bytes (`observed`).

| Sprite / asset | Path | Dimensions | Used for | Variety (`observed`/`derived`) |
|---|---|---|---|---|
| `tree_fir` (hi) | `app/assets/models/sprites_hi/tree_fir.png` | 512×512 | Wood node, ~50 % of picks | 1 frame, no rotation; also `sprites/tree_fir.png` 160×160, `tex/tree_fir.png` 1024×1024 (latter not loaded by `_load_sprites`) |
| `tree_pine` (hi) | `app/assets/models/sprites_hi/tree_pine.png` | 512×512 | Wood node, ~25 % | 1 frame; `sprites/` 160×160, `tex/` 512×512 |
| `tree_oak` (hi) | `app/assets/models/sprites_hi/tree_oak.png` | 512×512 | Wood node, ~25 % | 1 frame; `sprites/` 160×160, `tex/` 1024×1024 |
| `rock` | `app/assets/models/sprites/rock.png` | 160×160 | Stone, ore outcrop, **also bush/stump hash fallback** | 1 frame; `tex/rock.png` 1024×1024 unwired |
| `stone` | `app/assets/models/sprites/stone.png` | 160×160 | Stone, **stump hash fallback** | 1 frame; `tex/stone.png` 512×512 unwired |
| `field` | `app/assets/models/sprites/field.png` | 160×160 | Loaded at `world.gd:219`, **never drawn** | `tex/field.png` 512×256 also unwired; crops are procedural |
| `christmastreed` | `app/assets/terrain/deco_png/christmastreed.png` | 1024×1024 | **Unwired** — copied by `app/tools/copy_assets.py:122-124` only | Existing converted donor deco; possible 4th tree/season variant (visual suitability UNVERIFIED) |
| `envfieldd`, `envfielddw` | `app/assets/terrain/deco_png/{envfieldd,envfielddw}.png` | 512×512 each | **Preview tool only** `app/tools/gen_variant_maps.py:188` | Summer/winter field decal pair; not in `world.gd` |
| `groundexp0..3` | `app/assets/terrain/deco_png/groundexp{0,1,2,3}.png` | 512×512 each | **Unwired** (copied `copy_assets.py:125-127`) | Potential ground-scar / tuft decals, no code consumer |
| `bush_rock1..3`, `bush_sand1..3` | `app/assets/terrain/decals_png/` | **ABSENT** | Planned by `GUIDE4.md:500-512` | No dedicated bush sprite exists anywhere in `app/assets` |
| `tree_stump.png` | — | **ABSENT** | Planned by `GUIDE4.md:573-578` | No dedicated stump sprite; `GUIDE4.md:597` promised a rock-frame fallback but code can return null |
| `*_tree/bush` animation sheets | `app/assets/models/anim/**` | n/a | Units/buildings only | **No** tree/bush/stump sheet found (glob over `*tree*`, `*bush*`, `*stump*` under `models/`) |

**Conclusion (`observed`):** the port has **three dedicated tree sprites, two
rock sprites, one unused field sprite, and zero dedicated bush/stump/crop-stage
sprites**. No primitive unit sheet is reused for decor; the reuse is the
*rock* sprite standing in for bushes/stumps via the `_prop_tex` fallback chain.

---

## 4. Gap table (port vs donor)

| # | Port | Donor / reference | Evidence | Impact (`derived`/`inferred`) | Tag |
|---|---|---|---|---|---|
| G1 | 3 static tree sprites (fir/pine/oak), 1 frame each | **15** `forests_*` families: pine_big/big_2/med/small, pinefir_big/med/small, spruce_big/med, mixed_big/med, leaf_big/med/small, pinedrygreen_small, plus stoneforests/forest species from NTM S8 | `world.gd:219,236-240,1154`; `donor_patterns.json` family list; `RC_TERRAIN.md:27,86` | Canopy reads as three repeated silhouettes across the whole map; no spruce/leaf/mixed identity | **observed** (counts), **inferred** (visual read) |
| G2 | No sway / no wind | NTM advertises "animated trees" (`RC_TERRAIN.md:27`) | `world.gd:960-962` (no idle redraw), `:557-568` (no transform) | Forests look frozen; biggest "terrain beauty" gap in motion | **observed** code, impact **inferred** |
| G3 | No per-tree rotation; all billboards axis-aligned | Donor objects are world meshes with arbitrary yaw | `world.gd:557-568`; no angle stored in `res_nodes` (`game.gd:363-364`) | Repeated identical outline; breaks canopy rhythm | **observed** |
| G4 | Size jitter ±15 % exists but species all share 12.5 m base | Donor envscales: fir 0.5, stone 0.329, mine 0.3152 with min/max 0.85/1.15; species-specific mesh heights | `world.gd:105-120,1160` | Partial fidelity: variation is present but species-blind; no 4 size buckets/canopy tiers | **observed** |
| G5 | Bushes have no sprite; 2/3 of hash buckets produce procedural circles, 1/3 produces a **rock texture** | Donor decor comes from `dcr1-3`, `str_*`, desert/hill tuft patterns; GUIDE4 L3.10 planned 6 bush decals | `world.gd:1141-1149`, `:1064-1071`; no bush PNG in `app/assets`; `GUIDE4.md:497-512` | Rock-shaped bushes on sand/quarry edges; "naturalness" actively harmed | **derived** from code+inventory; visual result **UNVERIFIED** (no shot inspected this lane) |
| G6 | Stumps have no sprite; hash can return null → brown rect fallback, or brown-tinted rock/stone | GUIDE4 expects `tree_stump.png` then a guaranteed rock fallback | `world.gd:1133-1139`, `:1068`; `GUIDE4.md:573,577` | Cleared forest shows brown rocks instead of cut trunks | **derived** |
| G7 | Only `dcr1` of `dcr1/2/3`; `big_hill_1` in JSON but never stamped | `generator.cfg` decor families `dcr1-3`, `decor_big big_hill_1` | `pattern_gen.gd:259-261`; JSON parse (§1) | Decor density/geometry confined to one 184-cell pattern | **observed** |
| G8 | Forest-border pass paints only `grass5`/`rock9` tileblock; comment promises bushes | Donor `smoothforestborders.inc` tufts + shrubs | `game.gd:1078-1079` vs `:1250-1262` | Stale comment; forest edges have no soft shrub fringe | **observed** |
| G9 | Season affects terrain glaze only, not props | NTM Spring/Autumn texture sets; donor season swaps prop textures | `world.gd:763-796,880-890`; `RC_TERRAIN.md:27,149` | Winter/snow trees and autumn palettes absent | **observed** |
| G10 | Crops are procedural lines; donor field decal unwired | Donor `envfieldd/w` field decals + crop stages | `world.gd:1073-1115`; `app/tools/gen_variant_maps.py:188` | Flat "yellow circles" read as markers, not wheat (`RENDER.md:320`) | **observed** |
| G11 | Trees/bushes do not cast real shadows; tree uses a static blob, generic shadow is debug-gated | Donor lighting with object shadows | `world.gd:1158-1159,566-568` | Props look pasted onto ground; shadow never moves with sun (sun model UNVERIFIED) | **observed** code, donor side **UNVERIFIED** |
| G12 | Cluster layout partly donor-derived but reduced to ≤10 random points per stamp; groves are fixed offsets | Authored multi-object `.pattern` masks + per-family separation | `game.gd:503-545,753-766`; `pattern_gen.gd:65-83` | Trees evenly jittered inside a disc rather than clumped/speciated as authored | **derived** |
| G13 | No stump ageing variants (only 60 s delete) | Donor harvested-state texture / work transform | `game.gd:2940-2948`; `GUIDE4.md:532-534,601-611` | Old stumps vanish instead of fading; no charcoal/rot stages | **observed** |

---

## 5. Claim table

| Claim | Evidence | Method | Verdict | Correction |
|---|---|---|---|---|
| "Trees are single flat sprites with no variety" | `world.gd:219,236-240,1154` — 3 species × 1 frame; no rotation | Source read + asset glob | **PARTIAL** — no animation/rotation is confirmed, but there are 3 species and ±15 % size jitter (`:115-120`) | Restate: "3 static species billboards, size-jittered but unrotated and unanimated" |
| "No size variation" | `world.gd:115-120` `_env_sprite_h` 0.85–1.15 hash jitter | Source read | **CONTRADICTED** | Jitter exists; the real gap is species-blind base height, not absence of variation |
| "Trees/bushes sway" | `world.gd:960-962` redraw only on move/dirty; `anim_t` used elsewhere (`:1358,1415,1570`) | Source read | **CONTRADICTED** | No prop animation; sway would need a deliberate redraw/shader change |
| "Bushes use dedicated bush sprites" | `world.gd:1142` names `bush_rock/bush_sand`; no such PNG in `app/assets` | Glob + source read | **CONTRADICTED** | Deterministic fallback to procedural circles or the `rock` sprite |
| "If the stump sprite is missing, `_prop_tex` returns the rock frame (never null)" | `GUIDE4.md:577` vs `world.gd:1064-1071` (`sprites.get(pick, [])` → empty → `null`) | Source read | **CONTRADICTED** | `_prop_tex` returns null when the hash selects an unregistered key; the brown-rect fallback at `:1137-1139` is live |
| "Crops use a sprite / crop stages exist" | `world.gd:1073-1115` procedural; `:219` loads `field` but no draw call references it | Source read + grep | **CONTRADICTED** | `field.png` loaded-but-unused; `envfieldd/w` used only by the preview tool |
| "Seasonal decor variants exist" | `world.gd:763-796,880-890` terrain-only tint; no prop branch | Source read | **CONTRADICTED** | Only a 0.34-alpha terrain glaze; no prop swap, no spring/autumn |
| "Trees cast shadows, bushes/stumps do not" | `world.gd:1158-1159` tree blob; `:1144,1136` `shadow=false` | Source read | **CONFIRMED at code level** | Generic `_draw_sprite` shadow is additionally debug-gated (`:566`), so normal play relies on the tree blob |
| "Donor dcr1-3 / big_hill_1 / all forests_* are used" | `pattern_gen.gd:249-262` recipes vs 37-family JSON (§1) | Source read + JSON parse | **CONTRADICTED** | Only `dcr1`; `big_hill_1` and 11+ forest families are unreachable |
| "`game.gd:2384-2388` creates stumps" | `game.gd:2384-2388` is inside `squad_remove()`; stump flip at `:4006-4011` | Source read | **CONTRADICTED** | Task-brief line numbers are stale; use current lines |
| "Forest-border stamps add bushes" | `game.gd:1078-1079` comment vs `:1250-1262` code (tileblock only) | Source read | **CONTRADICTED** | Comment is aspirational; no bush node is created there |
| "On felling, a stump appears and is removed after 60 s" | `game.gd:4006-4015`, `:2940-2948` | Source read | **CONFIRMED** | No correction |
| "Decor counts are ~250 wood / ~230 bush" | `scans/implpattern_7/8/9` `res[].t` counts (§2) | JSON parse | **CONFIRMED for those dumps; UNVERIFIED for HEAD** | No Godot run here; do not treat as current-build telemetry |
| "RC_TERRAIN.md:118 'no season texture swap in world.gd'" | `world.gd:763-796,880-890` now applies a terrain glaze | Source read | **CONTRADICTED / stale** | A terrain-level tint exists; only the *prop* sprite swap is absent |

---

## 6. Recommendations — concrete, file-scoped build tickets

**Staging gate (respect owner directive, `SWARM_BOARD.md:157-169`):** these are
Lane-2 build candidates. Per the directive they must **first be validated on the
mini-map sample (TB-B0)** against TS-1's reference criteria; no full-map
generator edit is triaged while that sample fails. Each ticket below owns **one
file**; coordinator assigns the builder (`SWARM_BOARD.md:171-176`: `world.gd` →
one render builder, `game.gd` → one sim builder, `pattern_gen.gd` → one generator
builder, `copy_assets.py` → one asset builder). TPA-4 owns **none** of them.

**N-07 performance constraint (verbatim target, `SWARM_BACKLOG.md:44`):** keep the
`world.gd` marker of **2 chunks/frame + LRU 24**, and on the **low preset** keep
max frame hitch over **120 frames < 250 ms**, with G17 not regressed. Any ticket
that adds a per-frame draw must re-measure this gate and report the number;
"0 frame-time regression" below means that gate, not a vibe.

| Ticket (owner TBD) | Single file / target line | Change | Acceptance criterion |
|---|---|---|---|
| **TB-B-D1 — no rock-as-bush** | `app/scripts/world.gd:1064-1071`, `:1133-1150` | Make `_prop_tex` return null (not a rock) for unregistered deco names, or add a dedicated deco pool; keep procedural bush/stump fallback deterministic | 0 bushes resolve to the `rock`/`stone` texture; every bush/stump node draws a dedicated deco texture **or** the procedural fallback; capture `g4_deco_fallback.png` on the sample and inspect; selftest 29/29 + uitest 17/17; **N-07 hitch <250 ms**, 2 chunks/frame + LRU 24 unchanged |
| **TB-B-D2 — tree canopy variety** | `app/scripts/world.gd:1154-1162` | Keep 3 species but add 4 size buckets inside the existing 0.85–1.15 jitter and 4 deterministic yaw variants (`draw_set_transform` or pre-rotated frames) | Screenshot shows ≥3 canopy silhouettes × ≥4 apparent sizes in one grove; 0 new textures; no RNG draw added to `game.gd`; **0 frame-time regression (N-07 <250 ms)** |
| **TB-B-D3 — cheap sway (P2, perf-gated)** | `app/scripts/world.gd:960-962`, `:1151-1162` | Optional: per-tree `sin(anim_t·ω + phase)` displacement with a bounded redraw/shader path; abort if the gate fails | Visible sway at 100 % zoom with phase decorrelated by position; **no new Node2D/Sprite2D**; low-preset 120-frame max hitch still <250 ms; 2 chunks/frame + LRU 24 unchanged; G17 not regressed |
| **TB-B-D4 — decor family coverage** | `app/scripts/pattern_gen.gd:249-262` | Add `dcr2`, `dcr3`, `decor_big` to `recipes` (and one spruce/leaf forest family only after TB-V1 sign-off) | ≥3 decor families reachable from `recipes`; `donor_patterns.json` family names resolve; `scan_map.py` patch/decor metrics stay in band; **default-seed determinism byte-diff gate updated deliberately, not silently broken** (adding stamps shifts the RNG stream — see P-46 log) |
| **TB-B-D5 — forest-edge shrubs** | `app/scripts/game.gd:1250-1262` | Either implement the bush fringe promised by `:1078-1079` (edge cells with exactly one forest neighbour, ≤20 % chance) or delete the stale comment | Dump shows >0 bush nodes created in this pass on a fixed seed; bush nodes keep `hits=0`, `radius=0.3`, never block; no change to grove reach; **N-07 unaffected** (generation-time only) |
| **TB-B-D6 — decal conversion (asset lane)** | `app/tools/copy_assets.py:122-127` | Convert `bush_rock1..3`, `bush_sand1..3`, `tree_stump` donor decals via the existing private-use conversion path (no raw donor binaries committed) | 7 PNGs + `.import` present with dimensions recorded in §3; licence/private-use note in the ticket; `world.gd` untouched by this builder |
| **TB-B-D7 — seasonal prop variant** | `app/scripts/world.gd:1151-1162` (reads `_season_key()` `:772-776`) | Wire the already-converted `christmastreed.png` (or deco tint) for the winter season; keep summer path byte-identical | Winter sample screenshot shows season-specific decor; summer screenshot pixel-identical to baseline; 1 extra texture resident; **N-07 hitch <250 ms** |
| **TB-B-D8 — crop decal** | `app/scripts/world.gd:1078-1115` | Draw `envfieldd`/`envfielddw` as the field base when present, retaining procedural stalks/growth as fallback | Field reads as a tilled decal in the sample; depleted field still shows bare stubble; `game.sow_t` growth stages unchanged; **N-07 hitch <250 ms** |

All builders: back up before edit, run every Godot job through `godot_runner.py`
with unique ids, and pass **29/29 self-test + 17/17 UI test** before REVIEW
(`SWARM_BOARD.md:174-175`).

---

## 7. Open questions

1. **Which dump matches HEAD?** `scans/implpattern_*` is labelled post-P-46 by
   `GUIDE4.md:2310`; confirming exact counts needs a fresh `--dump-map` run,
   which this read-only lane did not perform. QA to confirm.
2. **Visual consequence of G5/G6 is code-derived only.** No screenshot was
   inspected in this lane; a windowed/sample capture must confirm whether bushes
   actually appear as grey rocks and stumps as brown rocks before TB-B-D1 is
   prioritised above D2.
3. **Sway vs perf (N-07).** Is any per-frame decor redraw acceptable at all, or
   should sway be limited to the mini-map sample only? Coordinator decision.
4. **Donor decals for bush/stump.** GUIDE4 L3.10's six PNGs were never converted
   (`copy_assets.py:122-127` copies different deco files). Confirm private-use
   approval before TB-B-D6.
5. **Is `christmastreed.png` usable as a generic decor variant?** TS-1's
   reference-image spec (TB-V1) should judge it before TB-B-D7.
6. **Species mix for G1.** Should spruce/leaf/mixed be added to the *renderer*
   first, or only to `pattern_gen.gd` recipes? This is a staging-order decision
   across two disjoint owners (world.gd vs pattern_gen.gd).
7. **Shadow gating.** `world.gd:566` makes the generic sprite shadow conditional
   on `Data.SHOW_CENTROIDS` (a debug flag) — confirm with the render owner whether
   that is intentional or a latent "shadows off in normal play" defect.
8. **`envfieldd/w` and `groundexp*` are unwired.** TPA-2's
   `docs/audit/TERRAIN_PORT_ASSETS.md` should corroborate the inventory in §3
   before any of these assets are scheduled.

---

## Files changed

- `docs/audit/TERRAIN_PORT_DECOR.md` (new) — this report only.

No code, script, index, asset, screenshot or status document was modified. All
analysis artifacts were read in place; no files were written outside the single
deliverable.
