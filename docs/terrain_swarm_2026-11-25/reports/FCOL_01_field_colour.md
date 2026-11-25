---
id: FCOL-01
ticket: "WAVE FIELD-COLOUR — trace exactly how a field/food node gets its 3D colour; why fields read dark"
owner: FCOL-01 read-only subagent
created: 2026-11-25
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_RUNNER__NO_GODOT__NO_CODE_OR_ASSET_EDIT
governing: docs/terrain_swarm_2026-11-25/CHARTER.md §3 + WAVE_G_CHARTER.md :31 (only G04 runs Godot)
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, PORT APPROX]
parity_guard: "No donor GPU A/B frame, no current-tree 3D field capture. Donor parity and every final-pixel claim stay UNVERIFIED."
outputs: [docs/terrain_swarm_2026-11-25/reports/FCOL_01_field_colour.md]
---

# FCOL-01 — field colour, end to end

## 0. Verdict

**OBSERVED.** A sown field is a `food` node (`game.gd:2604`, `_add_res("food", p, 50, 0.6)`;
`game.gd:575-587` sets `hits = max_hits = 50`, so `g = 1`). In 3D it is drawn **only** as one
instance of the `res|field` MultiMesh (`world3d_entities.gd:1482-1500`, `:2093-2109`,
`:2322-2380`); the 2D `world.gd` decal path does **not** run in 3D mode (`main.gd:1103-1106`
builds `world3d.gd`, not `world.gd`). The instance colour is a stage tint copied verbatim from
the 2D canvas tint table (`world3d_entities.gd:2354-2371` vs `world.gd:2592-2603`): ripe
`Color(3.3, 2.5, 1.0, 0.70)` at `g=1`. That tint is applied as `vertex_color_use_as_albedo`
(`:1494-1495`) to a **StandardMaterial3D** whose albedo is the donor model texture
`assets/models/tex/shared/terrain/field.png` (manifest `:2581-2603`; resolver
`asset_paths.gd:70-93`; material `:635-653`). It is **not** applied to the bright 2D decal
`envfieldd.png`.

**DERIVED (measured pixels + sampled UVs).** The bound model texture is mostly black: whole
image RGB mean `(10.1, 11.5, 1.0)`, median `(0,0,0)`, only 15.8% of pixels with alpha > 8;
in its opaque part RGB mean ≈ `(68, 77, 6)` (almost no blue). Sampling the 544 faces of
`field.obj` at their UV centres, **72.8% of the samples land on alpha ≤ 8 / RGB < 16 (black)**
and the sampled RGB mean is `(19.3, 20.7, 2.0)`. Because the field is explicitly excluded
from alpha-scissor transparency (`world3d_entities.gd:646-648`: `if kind == "res" and sid != "field"`),
those black texels are **not discarded — they render as opaque black**. Multiplying black
by a >1 tint cannot recover brightness; only the ~27% stalk texels get any colour. This is the
numerically decisive reason the fields read dark, and it is the exact defect the 2D port already
worked around by bypassing this texture (`docs/audit/MICRO.md:122-124`,
`docs/audit/PIECES/field_crops.md:117`).

**DERIVED.** The lighting path is mismatched against the ground: terrain is
`render_mode ... unshaded` and self-lights with donor ambient+diffuse
(`terrain_tileindex.gdshader:43,154-158,305,422-427`, `v_packed ≈ (1.008,0.965,0.823)`),
whereas the field is an ordinary **shaded** StandardMaterial3D under a dim donor ambient
`(0.196,0.184,0.129) × 1.10` and a sun `(0.812,0.780,0.694) × 1.7`, exposure 1.45
(`world3d_terrain.gd:139-151,1114-1166`). Its thin vertical quads face a near-overhead sun at
grazing angles, so diffuse is small. **UNVERIFIED:** the exact Godot 4.7 BRDF result, whether
the OBJ importer actually bound `field.png` (the migrated `.mtl` points at a `field.png` that
does not exist in its own folder, §2.2), and whether instance-colour alpha is used — no
Godot run or capture was allowed by this ticket.

**The suspicion "multiplied by mask/lighting twice" is NOT supported for fields**
(`_acquire` is called with `tint = null` at `:2109`, so no `_tint_shader`/mask is applied;
Godot lighting is applied once). The real chain is **black texture × stage tint × shaded
lighting**, plus **no season tint at all**.

---

## 1. Method, labels, scope

- Read-only source, manifest, shader, and PNG pixel inspection (Pillow, inline `python -`, no
  file written except this report). No Godot process, no `godot_runner.py`, no runner job, no
  git write, no `app/` edit, no code/asset/config/test change.
- `OBSERVED` = literal file bytes / measured pixels / cited report text.
- `DERIVED` = arithmetic or sampling over observed values.
- `INFERRED` = explanation of what the owner sees, not a measured frame.
- `UNVERIFIED` = engine-runtime behaviour or final pixels requiring a Godot capture; none exists
  for the current tree (`G22_2d_vs_3d.md:37,145-149`; `G04_gate_log.md` as cited there).
- Files read per ticket: `WAVE_G_CHARTER.md`, `CHARTER.md`,
  `reports/F2_01_mill_fields_audit.md`, `reports/F2_03_fields_fix.md`,
  `reports/G22_2d_vs_3d.md`, plus the live sources listed below.

---

## 2. Exact 3D colour pipeline (one field, one frame)

### 2.1 Sim side — what colour input exists (OBSERVED)

| Step | `path:line` | Value / effect |
|---|---|---|
| Mill finished → sow | `variant3d/scripts/game.gd:2555-2556` | `_sow_field_ring(e)` on `sid == "mil"` |
| Sower | `game.gd:2570-2607` | 7×7 rotated lattice, step `1.6981 m` (`:2581`), clash `1.5*TILE = 3.0 m` vs `food/wood/stone` (`:2594-2599`) |
| Node created | `game.gd:2604` | `_add_res("food", p, 50, 0.6)` |
| Node fields | `game.gd:575-587` | `hits = max_hits = 50`, `growth = 1.0`, `radius = 0.6`; **no colour stored in sim** |
| State | `game.gd:2671-2679` | `hits/max_hits ≥ 0.75 → "ripe"` (so freshly sown = ripe) |
| Growth | `game.gd:2683-2689` | `field_growth01 = hits/max_hits` → `g = 1.0` at sow |

**DERIVED:** freshly sown field → `st = "ripe"`, `g = 1.0`; this is the tint row evaluated in §2.3.

### 2.2 Resource → mesh, material, batch (OBSERVED)

| Step | `path:line` | Value / effect |
|---|---|---|
| `food` → presentation sid | `world3d_entities.gd:2076-2077` | returns `"field"` |
| Mesh lookup | `world3d_entities.gd:1189-1236` | `_mesh_info("field","res")`; GLB none; OBJ via `AssetPaths.existing(sid,"obj")` → `res://assets/models/obj/shared/terrain/field.obj` because manifest maps it (`manifest.json:2598-2602`) and the file exists |
| Mesh bake | `world3d_entities.gd:1148-1185` | donor Z-up → Y-up, bbox-centred; surface material kept from the OBJ importer, else `_default_material()` |
| Default material | `world3d_entities.gd:635-653` | `StandardMaterial3D`, `albedo_texture = AssetPaths.existing(sid,"tex")`, `roughness = 1.0`, `metallic = 0.0`, `cull_mode = CULL_DISABLED`; **for `field`, transparency is left at default opaque** (`:646-648` explicitly excludes field from `TRANSPARENCY_ALPHA_SCISSOR`) |
| Mapped texture | `manifest.json:2600-2602`, `asset_paths.gd:70-93` | `res://assets/models/tex/shared/terrain/field.png` (512×256 RGBA); legacy flat copies are identical bytes (`:tex/field.png`, `inbox/backup/FOLD06_*/tex/field.png`) |
| MTL of mapped OBJ | `assets/models/obj/shared/terrain/field.mtl:1-3` | `Kd 1 1 1`, `map_Kd field.png` — **relative to the OBJ folder, where no `field.png` exists** (flat-root `obj/field.mtl:3` instead says `..\tex\field.png`) |
| Batch | `world3d_entities.gd:1482-1500` | key `res|field`, `mm.use_colors = true` (only batch that opts in; `:1489-1490`), and each surface material gets `vertex_color_use_as_albedo = true` if it is a `StandardMaterial3D` (`:1491-1495`) |
| Initial colour | `world3d_entities.gd:1586-1588` | `mm.set_instance_color(ix, Color(1,1,1,1))` at acquire |
| Resize | `world3d_entities.gd:1528-1548` | `_grow_batch()` re-applies colours from `_field_visual` |
| Decal paths | `world3d_entities.gd:359,435-440,563` | `FIELD_DECAL_SUMMER/WINTER` (`:313-314`) recorded in stats **only**; comment at `:435-436` says "the mesh keeps its own donor field albedo and uses per-instance tint" |
| 3D world selection | `main.gd:1103-1106` | `render_mode == "3d"` → `world3d.gd`; the `world.gd` `_draw_field()` path is not used for the 3D field |

**UNVERIFIED:** which material the Godot OBJ importer actually produced for the mapped OBJ — the
local `.godot/imported/*.mesh` is not in the repo and no Godot run was permitted. Two cases:
(a) importer material with no resolvable `map_Kd` → white Kd albedo; (b) texture resolved (e.g.
via the flat-root MTL/legacy path) → the dark `field.png` described in §3. Case (b) matches the
owner's "too dark" report and the existing audit finding (`docs/audit/MICRO.md:122-124`), but
**which one actually renders is UNVERIFIED without a capture**.

### 2.3 The colour numbers applied per frame (OBSERVED — literal code)

`world3d_entities.gd:2322-2385`, block `if key != "res|field": continue` (`:2335-2337`).
`st` and `g` come from `game.field_state()` / `game.field_growth01()` (`:2347-2353`).

| State | line | instance colour (RGBA) | `rel` (uniform X/Y/Z scale factor) |
|---|---|---|---|
| ripe | `:2358-2359` | `(3.3, 2.5, 1.0, clamp(0.42+0.28g,0,1))` → at `g=1`: `(3.3,2.5,1.0,0.70)` | `(1.6+0.7g)/2.3` → at `g=1`: `1.0` |
| growing | `:2361-2362` | `(0.9, 1.6, 0.7, clamp(0.45+0.30g,0,1))` | `(1.1+0.9g)/2.0` |
| regrowing | `:2364-2367` | `(lerp(0.9,3.3,g), lerp(1.5,2.5,g), 0.7, clamp(0.40+0.30g,0,1)*pulse)`, `pulse = 0.75+0.25 sin(...)` | `(1.1+0.9g)/2.0` |
| depleted | `:2370-2371` | `(0.30, 0.26, 0.16, 0.60)` | `0.68/4.6 = 0.1478` |

Then `s = field_scale * rel` (`:2374`), `xf.basis.scaled(Vector3(s,s,s))` (`:2375-2376`),
`mm.set_instance_color(i, col)` (`:2379`), `_field_visual[fid] = {state,color,scale}` (`:2380`).
`field_scale = FIELD_SPAN_M / native_span` (`:2330-2334`) with `FIELD_SPAN_M = 2.40148 m`
(`:311-312`) and native x-span `58.51857 m` (`manifest.json:2588-2594`) → `0.04104`.

**DERIVED:** freshly sown field → ripe, `g=1`, colour `(3.3,2.5,1.0,0.70)`, `s = 0.04104`,
footprint `2.40148 m` — the same numbers F2-01 `:79,108` measured.

Note the **blue channel is never > 1.0** in any stage, and in the dark model texture blue is only
≈ `6/255`; the result is a hyper-saturated yellow-green with almost no blue, not the donor's
gold `#94762E` (§5).

### 2.4 Lighting / shader path (OBSERVED)

- Field mesh: **StandardMaterial3D** (`world3d_entities.gd:635-653`), i.e. Godot's normal
  shaded path; no `render_mode unshaded`, no mask shader, no `_apply_tint` (resources call
  `_acquire(key,id,info,"res")` with `tint = null` at `:2109`; the tint shader is only reached
  for unit batches at `:1748`).
- Terrain: `terrain_tileindex.gdshader:43` `render_mode blend_mix, unshaded, cull_disabled`;
  the donor light is folded into the shader: `ambient_rgb = (0.196,0.184,0.129)` (`:154`),
  `diffuse_rgb = (0.812,0.780,0.694)` (`:157`), `v_packed = ambient + diffuse` (`:305`),
  `rgb = rgb * mix(1.0,a,mask_to_alpha) * v_packed + v_specular` (`:427`). The mask is multiplied
  into **terrain** albedo here; it is **not** a field input.
- Water: `water3d.gdshader:21` also `unshaded`.
- World rig shared by both paths: `world3d_terrain.gd:139` `DONOR_AMBIENT = (0.196,0.184,0.129)`,
  `:140` `DONOR_DIFFUSE = (0.812,0.780,0.694)`, `:149` `EXPOSURE = 1.45`,
  `:150` `AMBIENT_ENERGY = 1.10`, `:151` `SUN_ENERGY = 1.7`; ambient at `:1135-1139`,
  sun colour/energy at `:1151-1152`, shadows disabled `:1153-1161`, sun direction
  `(-0.3447,0.9387,0)` (`:138`, shader `:150`).
- `v_packed` **DERIVED** ≈ `(1.008, 0.965, 0.823)` — near-unity self-lighting for the ground.
  The field has no such compensation: it is `albedo × (ambient + sun·NdotL)` with `albedo`
  dominated by black texels. **INFERRED:** this is why a field can read dark next to bright
  ground even though its instance tint contains values >1. **UNVERIFIED** without a frame.

### 2.5 Season swap (OBSERVED — absent in 3D)

- `world3d_entities.gd` has **zero** season/winter calls in the field path (grep: only `:315,
  :359, :435-440, :563`, all stats/labels). `FIELD_DECAL_WINTER` (`:314`) is never loaded as a
  field texture.
- `variant3d/scripts/winter_field_decal.gd:1-5` states it is **authoring-only, not registered or
  wired**; `:89-90` `decal_path()`, `:100-103` `decal_color()` (winter `(117,111,97)/255`,
  summer `(77,68,46)/255`); repo-wide grep finds **no caller** outside that file.
- Consequence: the 3D field keeps the summer stage tint in every season, and no winter decal is
  bound. The 2D app does the opposite (§5). **UNVERIFIED:** a winter capture was not produced.

---

## 3. The texture itself — measured pixels and UV coverage (OBSERVED + DERIVED)

Pillow/numpy, read-only, current tree. `tex/shared/terrain/field.png` (the mapped bucket) and
the legacy `tex/field.png` are **byte-identical** in content:

| Image | Size | Whole-image RGB mean | Median | Alpha > 8 | Opaque-region RGB mean |
|---|---|---|---|---|---|
| `models/tex/shared/terrain/field.png` | 512×256 | `(10.1, 11.5, 1.0)` | `(0,0,0)` | 15.8% | `(62.8, 71.1, 6.0)` at a>8; `(68.4,77.7,6.5)` at a>200 |
| `models/sprites/shared/terrain/field.png` | 160×160 | `(2.2, 2.4, 0.1)` | `(0,0,0)` | 40.5% | — |
| `terrain/deco_png/envfieldd.png` | 512×512 | `(75.6, 67.5, 45.2)` | `(73,65,43)` | 79.6% | ≈ donor summer opaque `(77.2,68.4,46.1)` |
| `terrain/deco_png/envfielddw.png` | 512×512 | `(115.9, 110.9, 97.0)` | `(115,112,98)` | 79.6% | ≈ donor winter opaque `(116.7,111.1,97.1)` |

The mapped image visually is **thin dark-olive stalks on a fully transparent/black background**.
`.import` (`field.png.import:18-35`) uses uncompressed import, `mipmaps/generate=false`,
`process/premult_alpha=false` — i.e. alpha=0 texels really store RGB 0.

**DERIVED UV probe (new, read-only):** parsed `field.obj` (546 verts, 573 UVs, 544 faces, **0
vertex normals**), sampled each triangle at its UV centroid using the mapped texture:

- 544/544 faces sampled; `alpha <= 8` on **72.8%** of samples; `max(RGB) < 16` on **72.8%**;
- sampled RGB mean `(19.3, 20.7, 2.0)`, median `(0,0,0)`;
- mesh UV v range `[-0.004, 1.003]`, concentrated in `v ≈ 0.50…1.00` (the stalk band).

With a **non-transparent** material (`world3d_entities.gd:646-648`), those black texels are drawn
opaque. This is the mechanism that makes the ripe tint `(3.3,2.5,1.0)` ineffective on most of
the field surface. `docs/audit/PIECES/field_crops.md:117` independently recorded the same art as
"an unlit black sheaf"; `docs/audit/MICRO.md:122-124` says the 2D port deliberately bypassed
`field.png` because it is "unlit black stalks".

**UNVERIFIED:** whether the OBJ importer resolved `map_Kd field.png` (§2.2). If it did not and
the material albedo is white `Kd`, the black-texel mechanism does not apply; that alternative
would make fields *bright yellow*, not dark — inconsistent with the owner's report but not
provable either way without Godot.

---

## 4. Why the tint numbers alone do not explain "dark" (DERIVED / INFERRED)

1. Ripe instance colour `(3.3,2.5,1.0,0.70)` has RGB > 1; on a *bright* albedo it would
   over-brighten. So a multiplier < 1 on the **tint** is not the cause.
2. The alpha `0.42…0.70` is < 1. If the field material were transparent, this would blend the
   field toward the ground and reduce contrast; but `world3d_entities.gd:646-648` leaves field
   opaque, so alpha is *expected* to be ignored. **UNVERIFIED** for the OBJ-importer material.
3. The decisive multiplier < 1 is the **texture**: opaque stalk RGB ≈ `(0.267,0.302,0.025)`
   sRGB and 72.8% of sampled surface at RGB ≈ 0. This is the "multiplier <1" the owner asked
   about — it lives in the texture, not in the tint code.
4. No mask double-multiply on fields: the `mask_to_alpha` fold at
   `terrain_tileindex.gdshader:427` is terrain-only; the field batch never gets `_apply_tint`
   (`:2109`, tint = null). Lighting is applied once by StandardMaterial3D.
5. Lighting mismatch (§2.4) and missing winter branch (§2.5) compound the darkness.

---

## 5. 2D comparison — `_field_decal()` appearance (OBSERVED + DERIVED)

The 2D app (and the identical `variant3d/scripts/world.gd` copy) uses a completely different
art path:

| Item | `path:line` | Value |
|---|---|---|
| Decal loader | `app/scripts/world.gd:2529-2539` (variant3d copy `world.gd:2529-2539`) | `envfieldd.png` / `envfielddw.png`, memoised per season |
| Winter selection | `world.gd:2572-2573` | `_season_key() == "winter"` → `envfielddw.png` |
| Draw | `world.gd:2604-2605` | `res_layer.draw_texture_rect(dec, Rect2(...), false, tint)` — **canvas modulate** over the bright donor decal |
| Ripe tint | `world.gd:2592` | `(3.3,2.5,1.0, 0.42+0.28g)` — same numbers the 3D code copied |
| Winter tint | `world.gd:2602-2603` | `Color(1.0,1.0,1.06,0.78)` (neutral over the grey winter decal) |
| Size | `world.gd:2588-2591` | ripe `w = (1.6+0.7g)·TILE_M·view_scale` (max 4.6 m), `hh = w/2` (max 2.3 m) |

**DERIVED arithmetic:** 2D ripe peak modulate on `envfieldd` opaque mean =
`(75.6×3.3, 67.5×2.5, 45.2×1.0) = (249, 169, 45)` (pre-clamp, then alpha 0.70 blended over
grass) — a saturated gold. 2D winter = `(115.9,110.9,97.0) × (1,1,1.06) ≈ (116,111,103)` —
the donor grey `#756F61`. The 3D path uses none of this: it multiplies the stage tint onto the
black model texture and has no winter override.

**Screenshot evidence already on record (OBSERVED via cited reports, not re-run):**
- `docs/audit/PIECES/field_crops.md:81-88`: donor screenshots `523480776.jpg` and
  `Cossacks3AttackingVillage.webp` wheat fields measured golden mean `(148,118,46)` /
  `(146,112,37)` = `#94762E`/`#927025`, 31.8–46% golden pixels, hard rectangular edges.
- `field_crops.md:38,43-47`: donor decal bytes are olive/brown `#4D442E` (summer) and grey
  `#756F61` (winter); the gold in screenshots is a **render-time tint**, not the DDS.
- `docs/audit/PIECES/T6-T13.md:23-29` lists in-repo piece-render PNGs
  `app/shots/pieces/t6_field_crops*.png` (Pillow/noGodot previews, **not** in-engine frames).
- **No 3D field capture exists:** G22 `:37,145-149` records that no fresh 3D frame was captured
  (G04 blocked), and the P0 frame `p0_final_formula.png` is terrain-only/pre-fix. Therefore
  every "appears dark" assertion about the current 3D tree remains **UNVERIFIED**; only the
  numeric mechanism above is OBSERVED/DERIVED.

---

## 6. Root-cause ranking (labels attached)

| Rank | Cause | Label | Evidence |
|---|---|---|---|
| 1 | Wrong texture bound to the 3D field albedo: dark cut-out `field.png` (72.8% black at mesh UVs) instead of the bright `envfieldd.png` decal; field excluded from alpha scissor so black texels render | **OBSERVED + DERIVED** (cause), **INFERRED** (that this is what the owner sees), **UNVERIFIED** (importer binding, final pixels) | `world3d_entities.gd:435-436,635-653,646-648,1489-1495`; `manifest.json:2598-2602`; measured pixels/UV probe §3; `MICRO.md:122-124` |
| 2 | No season branch in 3D: winter decal/tint never applied; stage tints from summer run year-round | **OBSERVED** | `world3d_entities.gd` grep (only stats at `:315,359,435-440,563`); `winter_field_decal.gd:1-5,89-103`; contrast `world.gd:2572-2573,2602-2603` |
| 3 | Lighting-path mismatch: field shaded by Godot rig, ground self-lit unshaded; thin vertical quads get little sun | **OBSERVED** (rig/shader modes), **INFERRED** (visual effect) | `world3d_terrain.gd:139-151,1114-1166`; `terrain_tileindex.gdshader:43,154-158,305,427`; `world3d_entities.gd:635-653` |
| 4 | Instance-colour alpha 0.42–0.70 could blend/attenuate if transparency is on | **UNVERIFIED** | `world3d_entities.gd:2358-2367`; `:646-648` expects opaque |
| 5 | Mask/lighting applied twice to field | **REFUTED for field** (mask is terrain-only; lit once) | `world3d_entities.gd:2109` (tint=null), `terrain_tileindex.gdshader:427` |
| 6 | Sow spacing/size causing fields to look small/sparse (not colour) | **OBSERVED** from prior reports, out of colour scope | `F2_01:103-110`, `F2_03:28-39` |

---

## 7. UNVERIFIED register / hand-off

1. No Godot run, runner job, or capture — mandated by `WAVE_G_CHARTER.md:31`. All final-pixel
   statements are predictions; donor parity stays UNVERIFIED (`CHARTER.md:57`).
2. Whether Godot 4.7's OBJ importer bound `field.png` from the migrated `.mtl` (missing local
   `field.png`) or left a white-Kd material: **UNVERIFIED**; decisive for ranking cause 1.
3. Whether `vertex_color_use_as_albedo` on a `MultiMesh` with >1 RGB and alpha <1 behaves as
   assumed in the current engine, and how sRGB import of `field.png` feeds the BRDF:
   **UNVERIFIED** (engine internals; no runtime probe).
4. A winter field frame is needed to confirm cause 2 visually; none exists.
5. Field stage tints are copied from the 2D canvas path (`world3d_entities.gd:2324-2326`
   comment cites `world.gd:2588-2613`, which has since moved to `:2588-2605`) — that citation is
   stale; the numeric values themselves still match (`world.gd:2592-2601`).
6. No donor-parity claim is made for any proposed colour correction; any fix must keep the
   existing donor art (`envfieldd/w.png`, `field.png`) and carry a PORT APPROX label if UVs are
   invented for a 3D decal (3D UV mapping is explicitly UNVERIFIED at
   `world3d_entities.gd:315,435-436`).
7. This ticket wrote only this report. No backup needed (no edit occurred).

*End of FCOL-01 report.*
