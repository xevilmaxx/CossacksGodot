---
id: BLD-01
ticket: "WAVE BLD / TERRAIN-SWARM-WAVE-G"
title: "Audit — mine build-footprint radius chain vs the placed mine"
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_RUNNER__NO_CODE_EDIT
scope: "One report written. No runner job, no Godot launch, no code/asset/test/config/git edit. All numbers are from source text read this session plus deterministic arithmetic over parsed mesh vertices."
labels: [OBSERVED, DERIVED, UNVERIFIED]
owner_directive: '"when building mine it +- should be same size of mine on the map — now it is about twice" (WAVE_G_CHARTER.md:173)'
donor_parity_claim: false
---

# BLD-01 — Mine footprint chain audit

## 0. Mandate and method

Audit the mine placement **footprint chain**, find which radius is ~2× the placed
mine's size, with file:line and numeric values. Items named in the ticket:
`MINE_SITE_RADIUS`; the "cross/plus ghost indicator" in `world3d_fx.gd`;
`game.can_place()` / `bld_rm()` radius; the placed mine's mesh bbox and collision
footprint; the deposit mask. Compare with the donor mine-deposit footprint from
F2-02 (~2.4×2.5 cells) and the 2D `app/` indicator. No runner (G04 owns Godot);
donor remains primary, no parity claim.

Labels used literally:

- **OBSERVED** — a repo file line was read this session; or the mine OBJ vertex
  list was parsed this session (below).
- **DERIVED** — deterministic arithmetic over OBSERVED numbers.
- **UNVERIFIED** — not provable from readable code/text; no capture was run.

Unit base: `TILE := 2.0` m (`variant3d/scripts/game.gd:16`),
`TILE_M := 2.0` m (`world3d_fx.gd:91`), `Data.TILE_M` used by 2D `world.gd`.

---

## 1. Answer — the ~2× radius, and the exact numbers

**The radius that is out of scale by about 2× is `MINE_SITE_RADIUS = 4.0 m`
(`variant3d/scripts/game.gd:19`).** It is the *only* radius the mine build gate
uses, and it is ~2–2.5× the placed mine's on-map size depending on which
definition of "mine size" is taken:

| "Placed mine size" definition | Value (OBSERVED / DERIVED) | `MINE_SITE_RADIUS` ratio | Label |
|---|---|---|---|
| Gameplay / collision radius (`def.radius`, `bld_block_r`) | **1.6 m** radius, 3.2 m diameter (`data.gd:1342-1347`; `game.gd:1883-1888`) | 4.0 / 1.6 = **2.50×** (radius) / 8.0 / 3.2 = **2.50×** (diameter) | DERIVED |
| 2D on-map mine/deposit sprite width | **4.0 m** wide (`world.gd:2817`: `wpx = 2.0 * TILE_M * view_scale`), radius 2.0 m | 8.0 / 4.0 = **2.00×** (ring diameter vs sprite) / 4.0 / 2.0 = **2.00×** (radii) | DERIVED |
| Actual 3D placed mesh bbox (X × Z) | **15.0264 × 15.8218 m** (`manifest.json:1323-1330`; OBJ parsed) | ring diameter 8.0 m is **0.53×** the mesh; the mesh is **1.88×** the ring | OBSERVED + DERIVED |

So the honest, decisive statement is:

> **OBSERVED/DERIVED:** `MINE_SITE_RADIUS = 4.0 m` at `game.gd:19` is a
> *deposit-snap / legality* radius whose **8.0 m ring diameter is exactly 2×
> the 4.0 m mine marker drawn on the map** (`world.gd:2817`) and **2.5× the
> mine's 1.6 m gameplay/collision radius** (`data.gd:1342`; `game.gd:1883-1888`).
> Meanwhile the **placed 3D mine is 15.03 × 15.82 m** — i.e. the build-time
> ring/gate and the finished art disagree by roughly 2–4×, and the collision
> footprint understates the visible mesh half-width by ~4.7×.

**Important qualifier (UNVERIFIED):** the owner's phrase "about twice" is
ambiguous about *which* pair is 2×. Three candidate ~2× relations all exist in
the source and are tabulated in §6; the single radius singled out by the chain
as anomalous is `MINE_SITE_RADIUS` because it is the only mine-specific radius
and it is what `can_place()` uses *instead of* a footprint check. The
15 m-vs-4.7 m placed-mesh/deposit ratio is ~3.2× (§5), and the donor's own
built-mine/deposit ratio is ~2.1× (F2-02). A capture is needed to say which
pair the owner actually saw — **UNVERIFIED**.

---

## 2. Radius inventory (every number in the chain)

| # | Node | Value | Units / cells | File:line | Label |
|---|---|---|---|---|---|
| R1 | `TILE` / `TILE_M` | 2.0 | m (1 cell) | `game.gd:16`; `world3d_fx.gd:91` | OBSERVED |
| R2 | **`MINE_SITE_RADIUS`** | **4.0** | m = **2.0 cells**; ring ⌀ **8.0 m = 4 cells** | `game.gd:19` | OBSERVED |
| R3 | mine `def.radius` (all 3 ore types) | 1.6 | m = 0.8 cells; ⌀ 3.2 m | `data.gd:1342-1347` | OBSERVED |
| R4 | ghost `Footprint` box half-side `_building_radius()` | `max(0.25, def.radius)` = **1.6** for mines (fallback 1.5) | m; box side 3.2 m | `world3d_fx.gd:597-598,1553-1558`; base box `909-913` | OBSERVED |
| R5 | `bld_rm()` for mines | **0.0** (no baked nation sheet) | m | `game.gd:1868-1881`; buildings.json has no mine entries | OBSERVED |
| R6 | `bld_block_r()` for mines | falls back to `def.radius` = **1.6** | m | `game.gd:1883-1888` | OBSERVED |
| R7 | `bld_block_rect_for()` for mines | **empty `Rect2()`** (no `_bld_scale_key`) | none | `game.gd:1893-1901` | OBSERVED |
| R8 | `can_place()` mine gate radius | **4.0 m only** (R2); early `{ok:true}`, no footprint/building/water checks | m | `game.gd:4038-4061` | OBSERVED |
| R9 | `place_building()` snap radius | **4.0 m** (R2), snaps `pos = n.pos` | m | `game.gd:4153-4157` | OBSERVED |
| R10 | `resolve_mine_sid()` pick radius | **4.0 m** (R2) | m | `game.gd:3129` | OBSERVED |
| R11 | deposit-mask (dirt apron) radius | `3.0 * TILE` = **6.0 m** = 3 cells; ⌀ 12 m = 6 cells | m | `game.gd:379,1393,1546,2013`; stamp `628-635` | OBSERVED |
| R12 | `MINE_MIN_SEP_TILES` | 11.0 tiles = 22 m centre separation | tiles/m | `game.gd:34` | OBSERVED |
| R13 | placed mine mesh bbox (X / Z / H) | **15.0264 / 15.8218 / 1.9133** | m = 7.51 / 7.91 / 0.96 cells | `manifest.json:1323-1330`; OBJ parsed | OBSERVED |
| R14 | 2D deposit marker sprite | **4.0 × 4.0** (set by `wpx`, square 160² sprite) | m | `world.gd:2814-2825`; sprites 160×160 | OBSERVED |
| R15 | 2D placed mine sprite | **3.0 × 3.0** (`_env_sprite_h(3.0,"mine")`, jitter bypass) | m | `world.gd:3107-3114`, `:226-232` | OBSERVED |
| R16 | 2D ghost ring / cross radii | ring rx = `1.6 * 1.45 = 2.32 m`, ry = 1.152 m; cross X spans ±1.6 m (3.2 m) | m | `world.gd:3513,3533,3536-3537` | OBSERVED |
| R17 | donor snap radius | 1.5 cells = **3.0 m** | m | F2-02 `:262` (`dmscript.global:206`) | OBSERVED (donor text) |
| R18 | donor deposit visual | **4.736 × 4.987 m** = 2.37 × 2.49 cells | m/cells | F2-02 `:103,247` | OBSERVED (donor-derived, prior lane) |
| R19 | donor built-mine mask / plate | **10 × 10 m** = 5 × 5 cells | m/cells | F2-02 `:104,249-250` | OBSERVED (donor file read) |

---

## 3. The 3D ghost indicator — no cross/plus in `world3d_fx.gd`

**OBSERVED:** a full read of `world3d_fx.gd` (functions/constants at `:84-302`,
ghost block `:578-689`, node construction `:895-925`, `_building_radius`
`:1553-1558`) finds **no cross/plus/plus-sign indicator at all**. The only
build-placement overlay primitives there are:

1. `Footprint` — a `MeshInstance3D` named `"Footprint"` (`:912`) holding a
   `BoxMesh` of size `(1.0, 0.05, 1.0)` (`:909-910`), scaled each ghost frame by
   `(r * 2.0, 1.0, r * 2.0)` where `r = _building_radius(s)` (`:597-598`).
   With `def.radius = 1.6 m` this is a **3.2 × 3.2 m** ground box (R4).
2. `GhostBuildingFinished` — the translucent finished-base mesh (`:921-925`,
   `:621-638`), **scale `Vector3.ONE`** (`:630`).

**Decisive detail for mines (OBSERVED):** `_ghost_swap_building_mesh()` sets
`_ghost_mesh.visible = false` whenever a finished mesh resolves (`:628-632`).
`mine_gold`/`mine_iron`/`mine_coal` base art **does** resolve — the OBJs exist
(`assets/models/obj/mine_*.obj`, manifest `kind: "building"` at `:1317`) and
`_ghost_resolve_mesh()` step 1 (`:657-662`) calls `_mesh_info(sid,"building")`.
Therefore for a mine the 3.2 m `Footprint` box is **hidden**; the visible 3D
ghost is only the finished mine mesh at scale 1. It is the **same baked mesh**
the placed building wears (`world3d_entities.gd:1660-1682`), so the 3D ghost
mesh and the placed 3D mesh are **1.00×, not 2×** (DERIVED).

**Where the actual X/cross is (OBSERVED):** the red "blocked" cross is drawn in
the 2D path — `world.gd:3536-3537` (and byte-identical
`app/scripts/world.gd:3536-3537`): two `draw_line`s through `p ± (r, ±r*0.5)`
with `r = gr = def.radius * view_scale = 1.6 m` (`:3513`, `:3534`). Its span is
3.2 m horizontally, 1.6 m vertically (R16). It is drawn only when `ok == false`
(`:3535`). The ticket's attribution "cross/plus ghost indicator size in
`world3d_fx.gd`" is **UNVERIFIED / contradicted by this tree** — the cross is a
2D `world.gd` artifact; `world3d_fx.gd` contributes only the hidden footprint
box and the full-size hologram.

---

## 4. `can_place()` / `bld_rm()` — why the gate has no footprint radius

**OBSERVED** (`game.gd:4032-4104`):

- Mine branch `:4038-4061`: spatial-hash deposit query over a
  `±MINE_SITE_RADIUS` box (`:4045-4046`), accept `distance < 4.0` (`:4050`),
  then **early return `{ok:true}`** at `:4061`. It never executes
  `var _mr = bld_rm(...); my_r0 = ... def.radius` (`:4068-4069`), the
  resource-footprint scan (`:4071-4092`), the building clearance
  `my_r0 + block_r + 0.3` (`:4094-4101`), or `is_blocked()` (`:4102`).
- Non-mine branch uses `bld_rm()` (`:4068`) → `def.radius` fallback (`:4069`).
- `bld_rm()` (`:1868-1881`) reads `buildings.json` `rm`; mines have no entry
  (checked), so **0.0** → `bld_block_r()` (`:1883-1888`) = `def.radius = 1.6 m`;
  `bld_block_rect_for()` (`:1893-1901`) returns empty `Rect2()` for mines.

**DERIVED:** the mine is the one building whose legality depends on a
*deposit-detection radius* (4.0 m) rather than its own footprint. That is the
structural source of the scale confusion: the 4.0 m number "feels like" a
footprint radius but is a snap/legality radius. The red X in the 2D ghost is
driven by exactly this verdict (`world3d.gd:491-498` → `draw_ghost`), so a hover
>4 m from a deposit shows a blocked cross even though the finished 15 m mine
mesh would comfortably cover that ground.

---

## 5. Placed mine mesh bbox and collision footprint (the other half of the gap)

**OBSERVED:** `manifest.json:1323-1330` (identical bbox for gold/iron/coal at
`:1342-1349`, `:1361-1368`):

```
bbox = [-7.1415634, 7.8848081,  -7.9127426, 7.9090848,  -1.5513978, 0.3618934]
```

Parsed all 1,065 `v` lines of each OBJ this session (deterministic, no engine):
X span **15.0264 m**, Y span **15.8218 m**, Z span **1.9133 m** — byte-for-byte
consistent with the manifest bbox. Under `_bake_mesh` (`world3d_entities.gd:
1053-1107`), `(x,y,z) → (x, z, -y)`, so the footprint in world X/Z is
**15.03 × 15.82 m** and height 1.91 m.

**Scale check (OBSERVED/DERIVED):** `_mesh_info()` `:1110-1130` sets
`factor = 1.0` for `kind == "building"` (the envscale `0.3152` at `:123` applies
only to `kind == "res"`), so `scale = target_h / native_h = 1.0`; `_xf()` `:1589`
uses `s = 1.0` for buildings. Hence the placed mine is the **full 15 m bbox**,
not a scaled-down deposit. For comparison the same donor mesh used as an *env
prop* (deposit) is scaled by 0.3152 → 15.0264 × 0.3152 = **4.736 m**, exactly
F2-02's donor deposit width (R18). This is a clean DERIVED cross-check.

Collision footprint (OBSERVED): `bld_block_r = 1.6 m`, `bld_block_rect = empty`.
**DERIVED:** 15.03 m mesh width / 3.2 m collision diameter = **4.70×**;
mesh half-width 7.51 m / collision radius 1.6 m = **4.70×**. The visible mine
is ~4.7× wider than its own collision/gameplay circle. `MINE_MIN_SEP_TILES =
11` (22 m) keeps deposits apart, so this overlap is not caught by generation.

Deposit mask (OBSERVED): `mine_mask` (`:57`) is stamped with radius `3.0*TILE =
6.0 m` at `:379`, `:1393`, `:1546`, `:2013` through `_mark_mine_mask()`
`:628-635`; `_finalize_mine_tiles()` `:382-385` paints those cells as neutral
`ground1`. The worked-ground apron is thus a **12 m / 6-cell disc** (R11),
~1.25× the 15 m mesh width but ~3.75× the 3.2 m collision diameter.

---

## 6. Ratio table — all ~2× candidates (DERIVED)

| Pair | Ratio | Matches "about twice"? | Label |
|---|---|---|---|
| `MINE_SITE_RADIUS` ⌀ 8.0 m ÷ 2D mine marker 4.0 m | **2.00×** | **YES — exact** | DERIVED |
| `MINE_SITE_RADIUS` 4.0 m ÷ mine collision radius 1.6 m | **2.50×** | loosely | DERIVED |
| deposit-mask radius 6.0 m ÷ collision diameter 3.2 m | **1.88×** | loosely (unit mismatch) | DERIVED |
| placed mesh width 15.03 m ÷ ring ⌀ 8.0 m | **1.88×** | loosely (inverse direction) | DERIVED |
| donor built mine 10 m ÷ donor deposit 4.736 m | **2.11×** | **YES — donor's own 2×** (F2-02:252) | DERIVED from F2-02 |
| port placed mesh 15.03 m ÷ donor deposit 4.736 m | **3.17×** | no — larger than donor | DERIVED |
| port snap radius 4.0 m ÷ donor snap radius 3.0 m | **1.33×** | no (known, L05:75) | DERIVED |
| placed mesh width 15.03 m ÷ collision ⌀ 3.2 m | **4.70×** | no | DERIVED |

**Reading:** if the owner meant "the build ring/marker is ~2× the mine on the
map", the exact match is the **8 m `MINE_SITE_RADIUS` ring vs the 4 m 2D mine
marker** (first row, 2.00×). If they meant "the built mine is ~2× the ore
deposit it sits on", that is the **donor's own relation** (2.11×) which our port
exceeds at 3.17× (fifth/sixth rows). If they meant "the ghost is ~2× the placed
mine", **no code path supports it**: the 3D ghost mesh is the identical 15 m
mesh (§3, 1.00×). Which interpretation is correct needs a windowed capture —
**UNVERIFIED** and explicitly not tested here (no runner).

---

## 7. Comparison with the donor and the 2D `app/` indicator

**Donor (from F2-02, OBSERVED donor text / DERIVED arithmetic):**

- Deposit visual **4.736 × 4.987 m ≈ 2.37 × 2.49 cells** (F2-02 `:103`, `:247`).
- Built-mine collision mask **5 × 5 cells = 10 × 10 m**, dirt plate 5 × 5
  (F2-02 `:104`, `:249-250`); donor itself notes built ≈2× deposit
  (F2-02 `:252-254`).
- Snap radius **1.5 cells = 3.0 m** (F2-02 `:262`, `:351`); port uses 4.0 m —
  already flagged as unresolved in L05 `:75`, `:284`.

**Port 2D indicator (OBSERVED, identical in `variant3d/scripts/world.gd` and
`app/scripts/world.gd`):**

- Ghost sid resolved with the same 4.0 m `resolve_mine_sid` (`:3486`); green/red
  from the same `can_place` (`:3502`), so the 2D ghost inherits R2 verbatim.
- Ghost ring `_ground_ellipse(..., gr*1.45, gr*0.72)` with
  `gr = def.radius * view_scale = 1.6 m` → **rx 2.32 m / ry 1.15 m** (`:3513,
  3533`) — ~4.64 m across, i.e. ~1.16× the 4.0 m deposit marker.
- Invalid cross X: **3.2 m** horizontal span (`:3534-3537`) = the mine collision
  diameter, not the 8 m legality ring.
- Placed mine sprite **3.0 × 3.0 m** (`:3114`, `:226-232`); deposit marker
  **4.0 × 4.0 m** (`:2817`). So the 2D map already shows deposit slightly larger
  than the placed mine (1.33×), never 2×.

**DERIVED conclusion:** the 2D app's ground indicator is scaled from
`def.radius` (1.6 m), while the mine's *legality* is scaled from
`MINE_SITE_RADIUS` (4.0 m) and the 3D art is a 15 m mesh. Three different size
authorities coexist for one object; `MINE_SITE_RADIUS` is the one that is ~2×
the on-map mine marker and the one that decides where the mine can go.

---

## 8. UNVERIFIED register — do not promote

1. Which on-screen pair the owner's "about twice" refers to — no windowed
   capture, no Godot run (G04 owns the runner). All three ~2× relations in §6
   are DERIVED from code, not observed pixels.
2. Whether any size shown in-game is perceived as the "+" / cross indicator:
   `world3d_fx.gd` has no cross; the X is 2D-only and red/blocked-only.
3. Visual parity with the donor built mine — no donor GPU A/B frame exists
   (CHARTER.md:55-69, 122-131); the 2.11× donor ratio is text-derived from
   F2-02, not a measured frame.
4. Runtime activation of donor `.inc`/commented scripts quoted by F2-02 —
   F2-02's own caveat; carried forward, not re-proven here.
5. Whether the 15 m mine mesh is what the owner calls "mine on the map" in the
   3D view, versus the 3.0–4.0 m 2D sprite — not observable without a capture.

---

## 9. Hand-off to BLD-03 / COORD (proposal seeds, no edits made here)

- The radius to examine first is `MINE_SITE_RADIUS = 4.0 m` (`game.gd:19`);
  the donor value is 3.0 m (F2-02 `:262`) — already an open decision (L05:75).
- Independently of the snap radius, the **size authority** is split:
  ghost footprint uses `def.radius` (`world3d_fx.gd:597-598,1553-1558`),
  gate uses `MINE_SITE_RADIUS` (`game.gd:4045-4055`), mesh uses the 15 m donor
  bbox (`manifest.json:1323-1330`), collision uses 1.6 m
  (`game.gd:1883-1888`), and the apron uses 6.0 m (`game.gd:379`). BLD-03 should
  pick *one* authority for the mine footprint indicator if footprint honesty is
  the goal (cf. G09/E04 strict check 7), and state the PORT APPROX label.
- Do **not** touch `can_place()`/`bld_rm()` without a fresh gate plan: changing
  the mine gate from 4.0 m to a footprint radius changes green/red verdicts,
  `t_mine_build`, `unified_mine_test`, and F2-04's snap atom (F2-04:266-267).

*End of BLD-01. One report written. No runner, no Godot, no code, asset, config,
test, git or capture state changed.*
