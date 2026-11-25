---
id: F2-01
title: "Audit: mill/farm field geometry, placement and why adjacent fields do not touch"
owner: F2-01 read-only auditor
date: 2026-11-25
scope: "ONE report only. NO Godot run, NO runner job, NO code/config/asset/test edit."
governing: "docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md §Wave F2 (F2-01) + docs/terrain_swarm_2026-11-25/CHARTER.md §3 guardrails"
status: DELIVERED
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED]
---

# F2-01 — mill fields audit

## 0. Verdict (one paragraph)

OBSERVED: every field is a `food` resource node created by `_sow_field_ring()` on a
**finished mill**; the candidate sites are a 7×7 lattice step `1.6981 m` rotated 45°
so nearest candidate centres are `√2·step = 2.4015 m` apart; the 3D field footprint
is deliberately scaled to that same `2.4015 m`; but the sow **clash radius is
`1.5·TILE = 3.0 m`**, which is larger than the candidate spacing and is tested
against all existing `food` nodes (including fields sown earlier in the same loop).
DERIVED: that clamp deletes every 2.4015 m neighbour, leaving an axis-aligned
sub-lattice with **minimum centre spacing `2·step = 3.3962 m`** (25 of 49 sites at
best, ≤24 once the mill-centre tile is blocked). The max visual footprint is
`2.4015 m` (3D) / `2.3 m` tall (2D), both **smaller than 3.3962 m**, so adjacent
fields leave a ~1 m gap. That is why they do not touch. The single lowest-risk
change is to lower the sow clash radius from `1.5·TILE` to `TILE` (2.0 m), which
restores the intended 2.4015 m spacing that the mesh scale already assumes,
without moving any node into a building or changing any visual size. A literal
"make them bigger" alternative (raise `FIELD_SPAN_M` and the 2D decal height to
≥3.4 m) also works but creates an UNVERIFIED building-visual-overlap risk because
the sim footprint radius stays 0.6 m. **No donor-parity claim; no Godot run.**

---

## 1. OBSERVED — exact code locations

### 1.1 Field creation and placement (the sim, both ports)

| What | variant3d `path:line` | app (2D analogue) `path:line` |
|---|---|---|
| Trigger: only a **finished mill** sows | `variant3d/scripts/game.gd:2488-2489` (`if e.sid == "mil": _sow_field_ring(e)`) | `app/scripts/game.gd:2095` |
| Mill-only guard in sower | `game.gd:2503-2505` | `app/scripts/game.gd:2109-2111` |
| `SOW_ROW := 7` (7×7) | `game.gd:2496` | `app/scripts/game.gd:2102` |
| `SOW_GOLD := 5` per field | `game.gd:2497`, paid `:2534-2536` | `app/scripts/game.gd:2140-2142` |
| `MAX_FIELDS_PER_MILL := 49` | `game.gd:2501`, checked `:2510-2511` | `app/scripts/game.gd:2116` (`MAX_FIELDS_PER_MILL`) |
| **Step** `1.6981 * TILE * 0.5` | `game.gd:2514` | `app/scripts/game.gd:2120` |
| **Placement grid/offset** `rr=r-3, cc=c-3; p = mill.pos + Vector2(cc-rr, cc+rr)*step` | `game.gd:2515-2519` | `app/scripts/game.gd:2121-2125` |
| Node creation `_add_res("food", p, 50, 0.6)` | `game.gd:2537`; typed/linked at `:2538-2539` | `app/scripts/game.gd:2143-2145` |
| `TILE := 2.0` | `game.gd:16` | `app/scripts/game.gd:16` |
| `Data.TILE_M := 2.0` (2D metres→px) | `variant3d/scripts/data.gd:23` | `app/scripts/data.gd:23` |
| `FIELD_MILL_RADIUS := 18.0` (**adoption / regrow** radius, NOT spacing) | `game.gd:205`, used `:2577`, `:2582` | `app/scripts/game.gd:157`, `:2183`, `:2188` |
| `FIELD_REGROW_TIME := 60.0` | `game.gd:204` | `app/scripts/game.gd:156` |
| Field node radius = `0.6 m`; food does **not** stamp `blocked` | `game.gd:568-579` (`if type not in ["food","bush","stump"]: set_blocked_circle(...)`) | identical in `app/scripts/game.gd` |
| `_add_res("food", …)` occurs **only** at the sower | `game.gd:2537` (sole hit) | `app/scripts/game.gd:2143` (sole hit) |

### 1.2 The clamps that keep fields apart / out of buildings

| Clamp | `path:line` | Effect |
|---|---|---|
| **Clash vs food/wood/stone: `n.pos.distance_to(p) < 1.5 * TILE` = 3.0 m** | `variant3d/scripts/game.gd:2526-2533`; `app/scripts/game.gd:2132-2139` | THE decisive spacing clamp (§2). Includes `food`, so previously sown fields reject their own neighbours. |
| `is_blocked(p)` (blocked tile grid) | `game.gd:2520` → `:522-525`, `set_blocked_circle` `:537-550` | Building/cliff circles make a candidate site be skipped. |
| Buildings stamp blocked circle of radius `bld_block_r` | `game.gd:2440-2443`; `bld_block_r` `:1837-1842`; mill `radius: 2.0` at `variant3d/scripts/data.gd:1330` | Mill's own footprint rejects field sites inside ~2 m. |
| Terrain skip `tt == 3 or 4 or 5` (water / shore / cliff) | `game.gd:2522-2525` | No fields on water or cliffs. Roads (`terrain == 1`) are NOT skipped. |
| `in_bounds(p)` | `game.gd:2516-2517` / `:516-517` | Map edge only. |
| Gold exhaustion `break` | `game.gd:2534-2535` | Limits total sown when treasury < 5. |
| `_CANPLACE_BLD_MARGIN := 16.0`, building-vs-resource check uses radius `my_r0 + n.radius` and refuses "Cornfield – pick open dirt" | `game.gd:190`, `:3986`, `:4024-4044` | New buildings cannot be placed on a field **centre**; the check uses the 0.6 m sim radius, not the visual footprint. |
| Roads are walkable and merely set `terrain = 1` | `game.gd:2343-2364` (esp. `:2356-2359`) | Nothing in `_sow_field_ring` excludes road tiles. |

### 1.3 Field mesh / decal size

| What | `path:line` | Value |
|---|---|---|
| Donor field mesh bbox | `variant3d/assets/models/manifest.json:1601-1615` | x `−29.2593…29.2593` = **58.51857 m**, y `−25.9626…25.9626` = 51.92523 m, z `−1.6559…18.7968` = 20.45267 m. Mesh `variant3d/assets/models/obj/field.obj`. |
| 3D target span constants | `variant3d/scripts/world3d_entities.gd:266-273` | `FIELD_STEP_M = 1.6981`; **`FIELD_SPAN_M = FIELD_STEP_M * 1.41421356237 = 2.40148 m`**; decal paths `envfieldd/w` at `:271-272`. |
| 3D scale application | `world3d_entities.gd:2199-2202`, `:2242-2247` | `field_scale = FIELD_SPAN_M / native_span`; `s = field_scale * rel`; instance basis scaled uniformly by `s` (native x-span = 58.51857 m). |
| 3D stage `rel` floors | `world3d_entities.gd:2223-2239` | ripe `(1.6+0.7g)/2.3` (0.696…**1.0**), growing/regrowing `(1.1+0.9g)/2.0` (0.55…1.0), depleted `0.68/4.6 = 0.148`. |
| 3D field instance batch / colour opt-in | `world3d_entities.gd:1406-1417`, `:1468-1471` | `res|field` is the only batch with `use_colors`; initial colour white. |
| 3D footprint actually measured earlier | `docs/coord_swarm_2026-11-24/reports/MILLFIX_rotor_fields.md:90-95` | ripe scale `0.04103784580629` = `2.40148/58.5186`; full-ripe footprint = **2.40148 m**. |
| 2D decal load | `variant3d/scripts/world.gd:2529-2539`; `app/scripts/world.gd:2529-2539` | `res://assets/terrain/deco_png/envfieldd.png` / `envfielddw.png`, memoised per season. |
| 2D field plate draw entry | `variant3d/scripts/world.gd:2561`, `:2805-2808`; `app/scripts/world.gd:2561`, `:2805-2808` | `_draw_field(p, h, _field_growth(n), n)`; `p = world_to_px(n.pos)` (`:2717`), `view_scale = PIXELS_PER_METER` (`world.gd:240`, `:351`). |
| **2D plate size** | `variant3d/scripts/world.gd:2586-2605`; `app/scripts/world.gd:2586-2605` | ripe `w = (1.6+0.7g)·TILE_M·view_scale` → max **4.6 m**; growing/regrowing `w = (1.1+0.9g)·TILE_M` → max 4.0 m; **`hh = w·0.5`** → max **2.3 m tall**; rect `Rect2(p.x−w/2, p.y−hh/2, w, hh)`. |
| 2D depleted plate | `world.gd:2574-2585` | `span0 = 0.34·view_scale`, drawn 0.68 m wide × 3 px tall + 7 stubble lines. |
| Decal alpha footprint | `variant3d/scripts/winter_field_decal.gd:14-15`, `:64-66` | DXT5 512², `a>8` bbox `(17,19,494,494)` → ~93% of the plate; season helper is **authoring-only, never wired in** (`winter_field_decal.gd:1-5`). |
| Field generation tool (not runtime) | `variant3d/tools/gen_variant_maps.py:188`, `variant3d/tools/copy_assets.py:98-99`, `field_crops.json:21232-21249` | Offline decal conversion; no placement geometry. |

### 1.4 Mill relationship (separate from fields)

| What | `path:line` |
|---|---|
| Rotor is a mill-only billboarded child | `variant3d/scripts/world3d_entities.gd:1683-1698`, `:1774-1780`; spin `angle = _anim_t * MILL_SPIN` at `:2153-2158` |
| `MILL_SPIN = 0.75`, `MILL_HUB = (0.525,0.21)`, `MILL_TOWER_ORTHO = 6.627`, `MILL_TOWER_CX = 0.4989` | `world3d_entities.gd:247-252` |
| Mill is only referenced by field via `sid == "mil"` + `finished` + id link + radius | `game.gd:2488-2489`, `:2503-2505`, `:2538-2539`, `:2571-2585` |

OBSERVED: there is **no code coupling** between rotor/mill visual size and field size; field footprint is set solely by `FIELD_SPAN_M` and the stage `rel` factor.

---

## 2. DERIVED — the geometry that creates the gap

All arithmetic below is over OBSERVED constants; it is arithmetic, not a Godot run.

1. `step = 1.6981 * TILE(2.0) * 0.5 = 1.6981 m`.
2. Candidate sites are `(u,v)·step` with `u = cc−rr`, `v = cc+rr`, `rr,cc ∈ [−3,3]`, so `u ≡ v (mod 2)` — a 45°-rotated square lattice. Nearest candidate neighbour distance `= √2·step = 2.401476 m` (matches `FIELD_SPAN_M` at `world3d_entities.gd:270`).
3. Clash threshold is `1.5·TILE = 3.0 m` (`game.gd:2529`) and the compared set includes `food` (`:2528`) — fields are `food` (`:2537`) and are appended to `res_nodes` during the loop (`:2537-2539`), so earlier fields reject later ones.
4. Since `2.401476 < 3.0`, every immediate lattice neighbour is rejected. Next-shortest lattice vector is `(2,0)`/`(0,2)` → `2·step = 3.3962 m > 3.0`, so those survive.
5. Read-only simulation of `game.gd:2515-2533` (idealised: no blocked tiles, no terrain/gold rejection, loop order `r=0..6, c=0..6`): **25 of 49** sites accepted; pairwise minimum distance **3.3962 m**; next distances 4.8030, 6.7924 m. Site `(0,0)` is the mill centre — `is_blocked()` removes it in the real game, so **≤24** actual fields. The `MAX_FIELDS_PER_MILL = 49` cap is therefore never the binding limit.
6. 3D full-ripe footprint = `58.51857 · (2.401476/58.51857) · rel(1.0) = 2.401476 m` (confirmed by MILLFIX probe `:94`). Gap to actual centre spacing `3.3962 − 2.4015 = 0.9947 m` → **fields cannot touch in 3D**. For `g<1`, `rel<1` makes the gap larger (e.g. `g=0.5` ripe → 2.036 m footprint → 1.36 m gap).
7. 2D ripe plate (`:2588-2591`, `TILE_M=2`): `4.6 m` wide × `2.3 m` tall. Against the axis-aligned 3.3962 m centre grid: horizontal neighbours **overlap** by 1.20 m, vertical neighbours leave a **1.096 m gap** → visually a set of merged horizontal bands with gaps between rows, not a contiguous field block.
8. With the decal alpha inset (~93% of the plate, `winter_field_decal.gd:64-66`), visible coverage is slightly smaller again.

---

## 3. INFERRED

- The clash radius `1.5·TILE` was meant to keep fields off **other** resources (trees/stone/wild food), but because fields themselves are `food`, it also acts as a field-vs-field spacing clamp. The intent is visible in `game.gd:2492-2495` (donor cSeedWheat comment) and `world3d_entities.gd:266-268` ("diagonal neighbour sqrt(2)*step … replacing the 58.5 m donor field bbox"): the intended footprint and the candidate spacing were designed to be equal, and the 3.0 m clamp accidentally broke that equality.
- `FIELD_MILL_RADIUS = 18.0 m` and the donor `58.5 m` field bbox are easy to confuse with field size; neither is the on-screen footprint. The 18 m value only governs regrow adoption; the 58.5 m value is the donor mesh that MILLFIX deliberately scaled down.
- The dot at `world3d_entities.gd:267` ("game.gd:2120") is a **stale citation**: variant3d `game.gd:2120` now sits inside `_cliff_tile_for()`; the live sow step is `game.gd:2514` (app copy `app/scripts/game.gd:2120` is still correct). Anyone editing must use the live lines.

---

## 4. Single change that makes adjacent fields touch (no building/road overlap)

### Recommended primary — lower the sow clash radius (one line per port)

`variant3d/scripts/game.gd:2529`: `if n.pos.distance_to(p) < 1.5 * TILE:` → `if n.pos.distance_to(p) < TILE:`
(mirror in `app/scripts/game.gd:2135`).

Why this is the decisive single change:

- Threshold `2.0 m < 2.401476 m`, so immediate lattice neighbours are admitted; the full 7×7 lattice (49 sites, minus blocked/terrain/gold) is sown at **2.4015 m**, which **equals `FIELD_SPAN_M`** (`world3d_entities.gd:270`). Fully ripe 3D fields then touch exactly (edge-to-edge) with no scale change.
- It does **not** enlarge any visual footprint, move any node, or relax `is_blocked()` / terrain / `in_bounds()` / `can_place()` — so no field is newly placed inside a building or onto water/cliff, and no new field visual overlaps a building footprint. Buildings still reject field centres via `blocked` (`game.gd:2520`, `:2440-2443`) and `can_place()` (`game.gd:4043-4044`).
- Roads are unchanged: they were already allowed (`terrain==1` not in the skip list at `:2524`), so this change does not introduce a new road overlap.
- Cost: up to 49 × 5 = 245 gold per mill (vs ~24 × 5 = 120 today) — a sim-economy side effect, not a geometry risk.
- Limitation: only fully ripe fields (`g=1`, `rel=1.0`) touch; growing/regrowing/depleted fields remain smaller by their `rel` factor (`:2223-2239`). 2D plates still have `hh = w/2 = 2.3 m` vs 2.4015 m spacing — a ~0.1 m residual vertical gap.

### Literal "make them bigger" alternative — raise the target footprint

`variant3d/scripts/world3d_entities.gd:270`: `FIELD_SPAN_M = FIELD_STEP_M * 1.41421356237` (2.4015 m) → e.g. `FIELD_STEP_M * 2.0 + margin` (≈3.4–3.5 m), with a mirror bump to the 2D plate height at `variant3d/scripts/world.gd:2591` / `app/scripts/world.gd:2591` (`hh`), so the plate covers ≥3.3962 m.

- This makes fields touch at the **actual** 3.3962 m centre spacing without touching sowing, clash, cost, or mill positions.
- Risk: the visual half-span grows from 1.20 m to ~1.70 m while the sim radius stays 0.6 m (`game.gd:2537`) and building clearance is `my_r0 + 0.6` (`game.gd:4036-4037`). Whether the enlarged plate overlaps the mill art (tower cell 6.627 m from `MILL_TOWER_ORTHO`, `world3d_entities.gd:250`) or a neighbouring building/road is **UNVERIFIED** without a render — flag for F2-03/F2-05 to gate with a capture.

Hand-off: F2-02 should confirm donor cSeedWheat spacing/footprint before either knob is changed; F2-03 owns the final choice. No donor parity is asserted here.

---

## 5. UNVERIFIED / open questions

- No Godot process, runner job, screenshot, or donor A/B was produced for this ticket (per charter). All visual outcomes above are DERIVED/INFERRED from code.
- Donor truth (actual field decal world size around a mill, cSeedWheat collision rule, whether donor fields truly form a contiguous block): **UNVERIFIED**, assigned to F2-02.
- Whether the current 2.4015 m 3D field plate already visually overlaps the mill at 3.3962 m centre distance (mill tower cell 6.627 m) is **UNVERIFIED**; no capture exists.
- The 25/49 accepted-site count is an idealised simulation; real counts also depend on `blocked` tiles, terrain 3/4/5, cliff/road tiles, and treasury. Exact count on the shipped map is **UNVERIFIED**.
- `winter_field_decal.gd` is deliberately inert (authoring-only, `:1-5`); its season/colour constants do not affect placement or size. Treating it as a live decal path would be wrong.
- The stale `world3d_entities.gd:267` citation to `game.gd:2120` should be corrected by whichever owner later edits that file (not this read-only ticket).

*End of F2-01 report.*
