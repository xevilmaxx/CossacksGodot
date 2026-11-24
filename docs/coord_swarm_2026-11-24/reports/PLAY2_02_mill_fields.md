---
id: PLAY2-02
owner: PLAY2-02
scope: "Mill rotor + field generation: app/ 2D vs variant3d/ 3D"
date: 2026-11-24
status: COMPLETE — READ-ONLY AUDIT; no source, test, asset, Godot or git edits
charter: docs/coord_swarm_2026-11-24/PLAYABILITY2_CHARTER.md
---

# PLAY2_02 — mill rotor and field generation

## 0. Verdict (top line)

1. **"Mill has no propeller" — CONFIRMED in 3D.** The rotor is a **2D CanvasItem draw
   effect** that lives only in `world.gd`; the 3D runtime never instantiates that
   script. The 3D mill is one static donor `mil.obj` `MeshInstance3D` named
   `Building_mil_<id>_STATIC_POSE`, with **no rotor child and no per-frame rotation
   of buildings**. The donor-derived rotor PNG and metadata are present in
   `variant3d/assets/**` but are referenced only by the dormant 2D copy.
2. **"Does the mill generate fields?" — YES logically, NO visually in 3D.** The sim
   is byte-identical between variants (`game.gd` SHA-256 `8649A865…` in both) and
   `t_mill_logic` proves the 7×7 ring, resow and free regrow (6/6 PASS). The 3D
   layer feeds each field as an **identical static donor `field1.osm` mesh** and
   never reads `field_state()` / `field_growth01()`; depleted/regrowing fields look
   the same as ripe ones. The 3D field patch is also donor-sized (~58.5 × 51.9 m,
   manifest) at ~1.7 m sow spacing — derived overlap that makes individual fields
   hard to read. That is why field generation is "unclear" in play even though it
   works.
3. **No 3D equivalent test exists.** `t_mill_rotor` / `t_mill_logic` result JSONs in
   `variant3d/tests/results/` are byte-identical copies of the 2D results (same
   `unix_ms`), and the variant test scripts are byte-identical to `app/tests/**` and
   instantiate the **2D** `C3World` script. V7-1 previously listed a "NEW 3D test"
   as outstanding (`docs/coord_swarm_2026-11-24/reports/V71_mechanics_inventory.md:129`).

---

## 1. Evidence table — rotor

| # | Observation (current source) | Evidence `path:line` | Kind |
|---|---|---|---|
| R1 | 2D rotor is a separate baked sprite; constants `MILL_HUB=(0.525,0.21)`, `MILL_SPIN=0.75 rad/s`, `MILL_ROTOR_ORTHO=6.352`; donor source is `eurmilanim.oss`. | `app/scripts/world.gd:199-208` | observed |
| R2 | Lazy load of the donor-baked `mill_rotor.png` through the nation-sheet resolver. | `app/scripts/world.gd:628-634`; asset `app/assets/models/anim/common/buildings/mill_rotor.png`, metadata `app/assets/models/anim/buildings/mill_rotor.json:1-5` | observed |
| R3 | Actual spin: `layer.draw_set_transform(hub, anim_t * MILL_SPIN, ...)`, quad span `MILL_ROTOR_ORTHO * view_scale`, hub at tower-cell fraction. | `app/scripts/world.gd:636-654` (esp. `:649-654`) | observed |
| R4 | Drawn only for a finished mill, inside the CanvasItem building pass. | `app/scripts/world.gd:2894-2895` | observed |
| R5 | Rotor presence forces per-frame building-layer redraw on an idle camera. | `app/scripts/world.gd:2105-2110` | observed |
| R6 | 3D mode selects `make_world3d()` → `world3d.gd`; `C3WorldScript` (`world.gd`) is used **only** in 2D mode. | `variant3d/scripts/main.gd:578-585`, `:977-984`, `:1043-1062` | observed |
| R7 | `world3d.gd` binds only terrain / entities / fx / fog / anim modules; no 2D world layer is added. | `variant3d/scripts/world3d.gd:594-645`, modules reported at `:658-672` | observed |
| R8 | 3D building creation is ONE static donor mesh (`Building_<sid>_<id>_STATIC_POSE`); only tint/meta/transform are set; **no child node**. | `variant3d/scripts/world3d_entities.gd:1091-1119` (name at `:1102`, `add_child(mi)` at `:1117`) | observed |
| R9 | `sync()` only rewrites `mi.transform = _xf(id)` for buildings; `_xf()` applies yaw **only for units**, never a rotor spin. | `variant3d/scripts/world3d_entities.gd:1279-1282`, `:1031-1058` | observed |
| R10 | `world3d.gd._update_anim()` is an explicit no-op. | `variant3d/scripts/world3d.gd:791-792` | observed |
| R11 | `anim3d.gd` has no building/rotor path; its "morph fields" are mesh vertex fields, not AAF actions. | `variant3d/scripts/anim3d.gd:165`, `:509`, `:533-534` | observed |
| R12 | 3D source itself documents the omission: 2D per-frame redraw for "growth bars and rotors … has no counterpart in this add/remove feed". | `variant3d/scripts/world3d.gd:358-373` (esp. `:369-372`) | observed |
| R13 | 3D copy of `world.gd` is byte-identical to the 2D one (SHA-256 `04750BDA…`), so the rotor code exists on disk but is unreachable in 3D play. | `Get-FileHash app/scripts/world.gd` vs `variant3d/scripts/world.gd` (identical); `variant3d/scripts/world.gd:628-654,2894-2895` | observed |
| R14 | Donor rotor bake source is real and read-only verifiable: `eurmilanim.oss` 55,388 B (header ints `k=251,fps=30,b=1,v=1098`), `eurmilanim.aaf` literal `AAF..1.."idle",1,249,morph`, `eurmil.dds` 5,592,560 B, `eurmil.osm` 128,876 B. | read-only byte/header probe at `C:\Games\Cossacks 3\data\...`; path literals in `variant3d/tools/bake_mill_rotor.py:57-62`, AAF note `:6`, frame-0 identity note `:64-72` | observed (bytes) / derived (frame semantics) |
| R15 | Bake renders the +Y face-on 4-blade rotor into a 320 px cell, `ortho=6.352`; tower cell is 6.627 m (`ukr_mil`). | `variant3d/tools/bake_mill_rotor.py:64-85`; `variant3d/assets/models/anim/buildings/mill_rotor.json:1-5`; `variant3d/assets/models/anim/buildings/buildings.json:578-589` | observed |

**Root cause (rotor):** the effect was implemented as a canvas draw inside the 2D
renderer (`world.gd:640-654`), and the 3D composition never ported it to a scene
node. Donor geometry for a true 3D sail exists (`eurmilanim.oss`), but no converter
or runtime consumer exists in `variant3d/scripts/`. This is a **visual-only gap**:
the mill building itself is fed correctly (`world3d.gd:344-348`).

---

## 2. Evidence table — fields / generation

| # | Observation | Evidence `path:line` | Kind |
|---|---|---|---|
| F1 | Finishing a mill calls `_sow_field_ring(e)`. | `app/scripts/game.gd:2094-2095` (identical `variant3d/scripts/game.gd:2094-2095`) | observed |
| F2 | Donor-anchored ring: 7×7 rotated, 5 gold/tile, ≤49 fields, 50 hits, collision/water/resource skips. | `app/scripts/game.gd:2098-2147` (`SOW_ROW :2102`, `SOW_GOLD :2103`, cap `:2107`, `step :2120`, `_add_res("food", p, 50, 0.6)` `:2143`, tag `:2145`) | observed |
| F3 | Manual sow restores depleted own fields first; `construct` event posted on restore. | `app/scripts/game.gd:2152-2160`, `:2164-2171` | observed |
| F4 | Mill lookup / regrow gate / HUD counts: `FIELD_MILL_RADIUS=18`, `field_can_regrow`, `field_state`, `field_growth01`, `field_counts_for_mill`. | `app/scripts/game.gd:155-157`, `:2177-2205`, `:2210-2250` | observed |
| F5 | Per-tick regrow advances `regrow_t`/`growth`, sets `fields_anim`, restores at full. | `app/scripts/game.gd:2252-2274`; `fields_anim` declared `:158` | observed |
| F6 | AI mills re-sow on the legacy timer; human mills intentionally do not. | `app/scripts/game.gd:2276-2291` | observed |
| F7 | Sim byte-identical across variants (SHA-256 `8649A865…` both). | `Get-FileHash app/scripts/game.gd`, `variant3d/scripts/game.gd` | observed |
| F8 | 2D visual stages read the sim: `_field_growth`/`_field_state` delegate to `game.field_growth01()`/`field_state()`; `_draw_field` draws ripe/growing/regrowing/depleted with donor `envfieldd/w` decal, tint, timer bar and pulse. | `app/scripts/world.gd:2541-2561`, `:2561-2633`; decal resolver `:2523-2534`; dispatch `:2805-2808` | observed |
| F9 | 2D force-redraws resource layer while `fields_anim` is true. | `app/scripts/world.gd:2095-2104` | observed |
| F10 | 3D resource feed only **adds/removes** nodes on `res_dirty` / array-size change; explicitly declines the `fields_anim` redraw clause. | `variant3d/scripts/world3d.gd:358-387`; gate `:378-384` | observed |
| F11 | 3D keeps food nodes visible even when hits=0 (no state branch), then adds one static instance. | `variant3d/scripts/world3d.gd:395-404`; `variant3d/scripts/world3d_entities.gd:1122-1136` (`food → "field"` at `:1130-1131`), `:1147-1168` | observed |
| F12 | No 3D module anywhere reads `field_state` / `field_growth01` / `fields_anim`: grep hits are only `game.gd`, the dormant `world.gd`, and one comment in `world3d.gd:369`. | `grep -n "field_state\|field_growth01\|fields_anim" variant3d/scripts/**` | observed |
| F13 | 3D FX event table has no `construct` mapping, so the restore event from F3 produces no field FX. | `variant3d/scripts/world3d_fx.gd:110-116`, `_consume_events :481-500` | observed |
| F14 | 3D `field` mesh is donor `field1.osm`, bbox ≈58.5×51.9×20.5 m; `field` is exempt from env scaling (`factor=1.0`), so the native mesh is used at full donor size. | `variant3d/assets/models/manifest.json:537-553`; `variant3d/scripts/world3d_entities.gd:35-36`, `:113`, `:277-284`, `:662-701` | observed |
| F15 | Sow spacing is ~2.40 m between adjacent diamond cells (`step = 1.6981*TILE*0.5 = 1.6981 m`, TILE=2), i.e. ~14.4 m ring span vs 58 m mesh footprint. | `app/scripts/game.gd:2120-2125`; `variant3d/scripts/data.gd:23` (`TILE_M=2.0`) | derived |
| F16 | HUD/minimap do consume the state in both variants, so the player sees counts/colours but the 3D scene does not change. | `variant3d/scripts/hud.gd:657-658`, `:1801`, `:1812` | observed |

**Root cause (fields):** the *simulation* is shared and proven; the *3D visual*
never consumes the field-state API. `world3d.gd`'s resource feed is an add/remove
reconciler by design (`V7-80` gate), and `add_resource()` bakes one immutable
`field` mesh into a `res|field` MultiMesh. Depleted, regrowing, growing and ripe
fields are therefore represented identically, and the donor-sized patch makes the
ring read as one big ambiguous patch. This is a **visual/feedback gap**, not a
missing generator.

---

## 3. Evidence table — existing test reports

| # | Observation | Evidence | Kind |
|---|---|---|---|
| T1 | `t_mill_logic` 6/6 PASS: no wild food, mill stores food, 14 fields (cap 49), food reaches mill, paid resow 0→21, free regrow 0→50. | `app/tests/results/t_mill_logic.json:2-36` | observed artifact |
| T2 | `t_mill_rotor` only checks `viewport_texture` and `png_saved`; **no rotor pixel, hub, or spin assertion**. | `app/tests/results/t_mill_rotor.json:2-16`; `app/tests/mill_render_test.gd:62-75` | observed |
| T3 | `mill_visual_test.gd` asserts rotor asset, load, hub/fractions and `anim_t` advance — but increments `anim_t` manually and writes **no result JSON** (no `t_mill_visual` artifact exists). | `app/tests/mill_visual_test.gd:39-77`, `:81-88`; glob `**/tests/results/*mill*` (4 files only) | observed |
| T4 | 3D result JSONs are byte-identical to 2D, including `unix_ms=1795439349918.0` / `1795257599226.0` — not independent runs. | `variant3d/tests/results/t_mill_logic.json:36`, `t_mill_rotor.json:16` vs app copies | observed |
| T5 | 3D test scripts are byte-identical copies of 2D (SHA-256 `2FF59490…` for logic, `15970945…` for render) and instantiate `C3World` = **2D** `world.gd`. | hash probe; `variant3d/tests/mill_render_test.gd:8`, `:49-59`; `variant3d/tests/mill_logic_test.gd:8` | observed |
| T6 | `variant3d/tests/manifest.json:34-40` still registers `t_mill_rotor` → `mill_render_test.gd`, `windowed:true`; headless runs skip the PNG and pass trivially (`:39-44`). | `variant3d/tests/manifest.json:34-40`; `variant3d/tests/mill_render_test.gd:39-44` | observed |
| T7 | A prior inventory explicitly requested a "NEW 3D test (re-bind rotor to mesh/rig)". | `docs/coord_swarm_2026-11-24/reports/V71_mechanics_inventory.md:129` | observed (prior doc) |
| T8 | The PNG claimed saved by `t_mill_rotor` is not present in the current tree (`app/shots/mill_rotor_check.png` missing; `.import` only). | `read app/shots/mill_rotor_check.png` → not found; glob `app/shots/mill_rotor_check.png.import` | observed |

**Test verdict:** 2D sim is proven; 2D rotor rendering is only weakly proven (a
save-error check plus a non-recorded visual test); **3D rotor and 3D field visuals
have no test at all**.

---

## 4. Smallest donor/2D-grounded fix plan (NOT implemented)

Separation: root causes are stated in §1–§2; everything below is a **proposal**.
No file was changed by this agent.

### R (P0) — attach a donor-derived spinning sail to the 3D mill

- **Owner:** `variant3d/scripts/world3d_entities.gd` **only** (new test file owned by
  the implementation ticket). Do **not** edit `world.gd`, `game.gd`, `main.gd`,
  the 2D assets, or the donor.
- **Data source (all already in-repo):**
  - sprite `variant3d/assets/models/anim/common/buildings/mill_rotor.png` and
    `variant3d/assets/models/anim/buildings/mill_rotor.json:1-5`
    (`cell=320`, `ortho=6.352`, 4-blade face-on bake);
  - 2D constants `app/scripts/world.gd:203-208` (`MILL_HUB`, `MILL_SPIN`,
    `MILL_ROTOR_ORTHO`), draw math `:649-654`;
  - tower cell geometry `variant3d/assets/models/anim/buildings/buildings.json:578-589`
    (`ortho=6.627`, `cell=320`, `ink`, `cx=0.4989`; `foot=ink[3]/cell` per
    `app/scripts/world.gd:694-698`), mill bbox
    `variant3d/assets/models/manifest.json:335-342`.
- **Change shape:** in `add_building()` (`:1091-1119`, after `add_child(mi)` at
  `:1117`), when `sid == "mil"`, add one child `MeshInstance3D` named
  `MillRotor_<id>` — billboarded, alpha-cutout textured quad, span 6.352 m,
  hub placed by mapping `MILL_HUB` fractions through `cx`/`foot` into the baked
  local frame. In `sync()`'s building loop (`:1279-1282`) set the child's in-plane
  angle from the module's existing clock `_anim_t` (`:1190`) times `MILL_SPIN`
  (0.75 rad/s). Tag the node with a `visual_status` meta reading
  "PORT APPROXIMATION — donor 2D rotor bake, visual UNVERIFIED". No new donor
  bytes, no sim change.
- **Deliberate limitation:** a spin-billboarded bake is a port stand-in, not a true
  3D lattice sail. A donor-faithful rotor mesh from `eurmilanim.oss` (header
  `v=1098`, `fps=30`, frame-0 identity per `bake_mill_rotor.py:64-72`) is a
  **follow-up**, not part of the smallest fix. Do not claim donor parity.

### F (P0/P1) — make field state visible in the 3D scene

- **Owner:** `variant3d/scripts/world3d_entities.gd` (it owns the `res|field`
  MultiMesh at `:1147-1168`). `variant3d/scripts/world3d_fx.gd` is the optional
  owner of a lightweight stage/timer marker; **terrain is not recommended**
  (fields are sim resources, not heightfield/splat data).
- **Data source:** `game.field_state()` / `field_growth01()` /
  `field_counts_for_mill()` (`game.gd:2210-2250`), `fields_anim` (`:158`, `:2274`),
  and node fields `hits/max_hits`, `growth`, `regrow_t`, `mill`. For the ripe
  overlay, reuse the existing donor decals `variant3d/assets/terrain/deco_png/envfieldd.png`
  / `envfielddw.png` that the 2D renderer already uses at
  `app/scripts/world.gd:2523-2534,2586-2605` — no new donor art.
- **Change shape (minimal):** extend `sync()` with a small pass over resource slots
  whose sid is `field`; set per-instance colour/scale on the `res|field` batch to
  mirror 2D's four stages (ripe gold, growing green, regrowing green-gold + timer
  pulse, depleted bare stubble) and/or add one small FX marker per
  non-ripe field. Keep it read-only on the sim: no `res_nodes` mutation and no
  `res_dirty` bump. **Also** rescale the field instance footprint from the sow
  spacing (`game.gd:2120`, `step=1.6981*TILE*0.5`) instead of the raw 58 m donor
  bbox (`manifest.json:544-551`) so individual fields are legible; if that is
  deferred, record the overlap as an accepted limitation, not a fix.
- **Optional, not required:** map `post_event("construct", pos, "field")`
  (`game.gd:2171`) to a short 3D FX via `world3d_fx.gd:EVENT_FX` (`:112-116`).

### T — acceptance probe (implementation wave, new files only)

Add **new** ids (do not overwrite the copied `t_mill_rotor`/`t_mill_logic`
results), e.g. `t_mill_rotor3d` and `t_mill_fields3d`, registered in
`variant3d/tests/manifest.json`:

1. Bind `world3d.gd` to a fresh `game`, `Data.AI_ENABLED=false`, spawn a finished
   `mil` on clear ground, call `world.sync(0.1)` twice.
2. **Rotor structural:** `_nodes[mill.id]` has a child named `MillRotor_*`; record
   its angle, call `world.sync(0.5)`, assert Δangle ≈ `0.5 * 0.75` rad (±0.02),
   assert hub local y is within 0.5 m of the tower-cap estimate from
   `MILL_HUB`/`buildings.json:578-589` (this is the alignment gate).
3. **Field feed:** `game.field_counts_for_mill(mill.id)` total > 0 and equals the
   number of `res|field` instances registered for mill-owned food nodes.
4. **Field visual state:** set a mill field's `hits=0`, tick the sim into
   `regrowing`, call `world.sync(0.1)`; assert its 3D visual state (instance
   colour/scale/meta or FX marker) differs from a ripe sibling, then assert
   `_restore_field` makes it match again. No sim values may change from the
   visual pass.
5. **Visual gate:** one Camera3D screenshot focused on the mill in two rotations;
   a sail-coloured region must appear above the tower and differ between frames.
   Gold field patches must visibly change after harvesting a field. Label this
   "port approximation, donor parity UNVERIFIED".
6. **Regression:** `app/scripts/**` unchanged (hash gate); `t_mill_logic` still
   6/6; the shared `game.gd` hash unchanged.

---

## 5. UNVERIFIED / open questions

- No 3D runtime screenshot of a mill or its fields exists in the tree
  (`variant3d/shots` absent); no donor-render A/B was performed in this wave.
- The PNG that `t_mill_rotor` claims to have saved (`app/shots/mill_rotor_check.png`)
  is missing from the current tree; the 2D rotor's on-screen appearance cannot be
  confirmed from the artifact.
- The exact 2D-sheet → 3D-OBJ hub mapping (and whether a billboarded quad keeps a
  face-on sail through a full 360° in Godot 4) is a derived proposal, not a
  measured result; the acceptance probe's hub/Δangle checks are the gate.
- Field overlap (~58 m donor mesh vs ~2.4 m sow spacing) is **derived** from bbox
  and constants, not measured in the engine; it may be partially masked by the
  current terrain/decal arrangement.
- Donor rotor `.oss`/`.aaf` were probed at header level only; frame-0 identity and
  the 1..249 morph range come from the bake script + AAF literal, not from a donor
  render. No donor art was copied.
- Winter/summer field-decal selection for a 3D field overlay (`_season_key()` is
  a 2D helper) has no verified 3D source.
- Windmill ambience in 3D (audio bed + Camera2D-proximity issue) is out of this
  scope; see `AUDIT3D_06` for the separate positional-audio finding.
- All prior docs/board rows claiming mill/fields "DONE" describe the **2D / sim**
  implementation (`docs/coord_swarm_2026-11-24/GAPS.md:12`,
  `docs/SWARM_BOARD.md:80-81,95`); they were treated as UNDONE for 3D until
  verified here, per charter rule.
