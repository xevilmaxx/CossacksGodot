---
id: F07
ticket: "TERRAIN-SWARM-2026-11-26 / Wave F / F07"
title: "Donor-grounded decode of mill + field landscape assets and the mill→field rule"
owner: "F07 swarm worker (read-only; one report only)"
created: 2026-11-26
status: DELIVERED__READ_ONLY__NO_RUNNER__NO_CODE_EDIT
donor_root: "C:\\Games\\Cossacks 3\\data (READ-ONLY, private use)"
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
labels: [O, D, I, U, "PORT APPROXIMATION"]
visual_parity_claim: false
scope: "One report written. No donor binary executed or copied; no code/asset/config/test/git edit; no Godot run or runner job."
governing: "docs/terrain_swarm_2026-11-26/CHARTER.md §2/§4; SWARM_BOARD.md F07"
prior_art: "2026-11-25 reports F2_01, F2_02, M01, M02, FCOL_01/02/03 (grep-read first); all treated as secondary, re-verified here where decisive"
---

# F07 — mill and field landscape assets: donor decode, port inventory, recipe

## 0. Executive summary

- **[O] The donor has no "field pattern family."** Zero of 710 `data/pattern/*.pattern` files and zero `pattern.lib` records name a mill or field object (`BaseName = field` / `BaseName = mil`: 0 hits). Mill fields are created **by script**, not stamped by a terrain pattern. `frt_*` (248 files) is the **forest** family (objects `grassforest.2`, `pine1`, `pinesmall1`), and `k_pump_*` (15 files) is a **decorative water-pump** family (objects `pump1`, `horseradish`, `plantain`). Both were candidates in the ticket; both are rejected as field sources.
- **[O] Exact mill→field rule** (`D:scripts/lib/unit.script:6468-6570`): a **7×7 = 49-node** lattice, node step `size = 1.6981` **map cells**, rotated **45°** by `VectorRotateY(...,45)`, base snapped by `size2 = √2·size ≈ 2.401476` cells with an X offset `+size` and a Z offset `+size·0.5`; per node a 5×5 grid of `gc_collision_size = 0.5` cells (rotated 45°) must be collision-free, and resources within `rad/3 ≈ 1.52829` cells (`food/wood/stone`) or `rad ≈ 4.58487` cells (ores) reject the node. Cost is **5 gold per field** (`unit.script:1691-1693`).
- **[O] Trigger chain:** mill completion orders one field (`ontagstates.inc:140-145`), map start seeds all built mills (`generatemap.inc:1009-1025`), a completed field order reseeds (`doprogressorders.inc:130-135`), AI uses the same routine. All four callers are `[*] = ;`-commented `.inc` text — **runtime activation [U]**, as recorded in F2-02.
- **[O]/[D] Crop stages/seasons:** the donor field is a **food resource with no time-based growth stages** in any readable script; visual variety is **3 random crop meshes** (`field1/2/3.osm`) × **5 summer materials** (`field`, `field1..4`) with explicit winter twins (`fieldw`, `field1w..4w`) selected by `UseSeasonMaterial = True` (`field.prop:30-127`). Ground decal uses `envfieldd`/`envfielddw` with **byte-identical alpha** and a `texscalefix = 1.3` size/UV multiplier (`misc.script:4286-4306`). The port's 4 states (`ripe/growing/regrowing/depleted`, 60 s regrow, 18 m mill radius) are **PORT APPROXIMATION**, not donor rules.
- **[O] Port conversion is European-only and lossy:** 10 mill OBJs from `eurmil*` (no death stages, no Rus/Turk bodies), one `field.obj` from `field1.osm` with `field1.dds` albedo, one baked 320² rotor PNG standing in for `eurmilanim.oss`, two field decals, six mill ground decals. No `field2/3`, no `field*w`, no crop-material variants, no pump family, no `.oss`, no mill winter body texture.
- **[D] Decisive unit finding (corrects F2-01's prescription):** with `gc_meters_to_tile = 2` (`dmscript.global:171`), donor node spacing is `1.6981 × 2 = 3.3962 m` and donor food clearance is `1.52829 × 2 ≈ 3.0566 m`; the port's clash threshold `1.5·TILE = 3.0 m` is therefore **approximately donor-correct in metres**, while the port's sow step `1.6981 m` is **half** the donor spacing. Lowering the port clash radius to `2.0 m` (F2-01's recommendation) would restore 49 nodes but pack them at `2.4015 m`, i.e. **~71 % of donor spacing** — [D], under the 2 m/cell reading whose only evidence is the single constant at `dmscript.global:171` ([U] for engine-level confirmation).
- **[I] No donor-parity claim:** no donor GPU frame exists, no Godot run was made, and the donor decal `w` unit is still undefined in readable data.

---

## 1. Method, labels, scope

- Donor files were opened read-only under `C:\Games\Cossacks 3\data`. Binary `.osm`/`.oss` headers and vertex arrays were decoded **in memory** with the same `struct` layouts documented by the port's read-only bake tool (`app/tools/bake_sprites.py:91-103,551-560`); `bpy` was deliberately not imported and no donor asset was written into the repo.
- `D:` = `C:\Games\Cossacks 3\data\`; repo paths are relative to the workspace root. Offsets in `pattern.lib` are 0-based byte offsets; all line numbers are 1-based as read this session.
- **[O]** = donor/repo byte or line read here (binary geometry decoded in memory is OBSERVED). **[D]** = deterministic arithmetic over observed values. **[I]** = plausible reading, not proven. **[U]** = cannot be proven from readable donor text. **PORT APPROXIMATION** = port-authored stand-in, explicitly not donor-verified.
- Deference rule: where F2-02 / M02 / FCOL-02 already established donor truth, this report re-reads the decisive lines and adds the **asset-size inventory, pattern-family disambiguation, unit reconciliation and conversion gaps** rather than restating their whole claim tables.

---

## 2. Evidence table

| # | Evidence (donor path:line / offset) | Fact | Label |
|---|---|---|---|
| E1 | `D:scripts/lib/unit.script:6470-6570` | `_unit_DoSeedWheat`: 7×7, `size=1.6981`, `cScale=1.09245`, `cRollAngle=0`, 45° rotation, `size2=√2·size`, 25-cell collision scan, food/wood/stone clearance `rad/3`, ore clearance `rad`, `WriteNewP` creation, cost applied | [O] |
| E2 | `D:scripts/lib/unit.script:6497-6499` | Snap asymmetry: `px := floor((px+size)/size2)*size2`, `pz := floor((pz+size*0.5)/size2)*size2` | [O] |
| E3 | `D:scripts/lib/unit.script:1691-1693` | `'field'`: `objbase.price[gold] := 5`, `usage := gc_obj_usage_field` | [O] |
| E4 | `D:scripts/units/building.inc/ontagstates.inc:140-145`; `D:scripts/units/building.inc/doprogressorders.inc:130-135`; `D:scripts/common.inc/generatemap.inc:1009-1025`; `D:scripts/units/global.inc/progresseconomicai.inc:3688-3697` | All mill→seed call sites; all are `[*] = ;`-prefixed text | [O] text / activation [U] |
| E5 | `D:scripts/lib/misc.script:4286-4306` | `_misc_PlaceFieldDecal`: `w=h=scale*goScale*1.3`, `texscale*=1.3`, `texOff=−0.15`; no colour term | [O] |
| E6 | `D:scripts/units/global.inc/writenewp.inc:23-29`; `readnewp.inc:41-47` | Callers pass `scale=60`, `angle=45` or `225` — commented text | [O] text / activation [U] |
| E7 | `D:objects/env/field.prop:30-39,41-129,139-150,152-157` | 3 usable meshes (`field1/2/3`), 5+5 season materials, `DefaultScale=0.03605085`, `DefaultRollAngle=45`, `decalproperty` commented out | [O] |
| E8 | `D:actors/env/field.actor:1-11` | `field1.mesh`/`field2.mesh`/`field3.mesh` → `field1/2/3.osm` | [O] |
| E9 | `D:terrain/decals/decals.lib:37-44`; `:1-35` | `envfieldd`: summer `envfieldd`, winter `envfielddw`, `width=height=2`; template defaults `width=height=4`, `texscale=1/1`, `epsilon=0.01` | [O] |
| E10 | `D:terrain/decals/decals.lib:128-132,711-717,983-989` | Mill ground decals `eurmild`/`rusmild`/`turmild` + winter twins; eur inherits 4×4, rus/tur 8×8 | [O] |
| E11 | `D:actors/buildings/commoneur/eurmil.actor:2-27`; `attach/eurmila.actor:2-28`; `attach/eurmilanim.actor:2-6` | Body 8 `.osm` (base + 4 build + 2 death), scaffold 7 `.osm`, sail 1 `.oss` + 1 `.aaf` | [O] |
| E12 | `D:animations/aaf/eurmilanim.aaf:1-4` | `"idle",1,249,morph`; in-memory decode of `eurmilanim.oss`: `k=251`, `fps=30`, 1 bone, 1098 verts, 550 faces, bbox x ±2.996233, y [−1.897957,−1.040952], z [2.627196,8.619664] | [O] |
| E13 | In-memory decode (E12 parser) + `D:objects/buildings/eurmil.prop:106-114` | Axle disc centre donor (0,−1.469455,5.623430), axle tip donor y=−1.897957; spin axis donor Y; 251/30 = 8.367 s → 0.751 rad/s; `DefaultScale 0.43`, `DefaultRollAngle 45` | [O] / [D] |
| E14 | `D:pattern/pattern.lib` offset 23804850 (`pump_01`), 1229903 (`frt_s_p_1`); `D:game/var/generator.cfg:1538-1600,1061-1089` | `pump` family 15 patterns (obj `pump1`, `horseradish`, `plantain`); `forests_pine_small` family uses `frt_s_p_1..6` (obj `grassforest.2`, `pine1`, …) | [O] |
| E15 | Scan of all 710 `D:pattern/*.pattern` and `pattern.lib` | `field` 0, `mil` 0, `frt` 248, `pump` 15; `BaseName = field` 0, `BaseName = mil` 0 | [O] scan |
| E16 | `D:scripts/dmscript.global:171,178,206,313,952` | `gc_meters_to_tile=2`; `gc_collision_size=0.5`; `gc_gameplay_findminepositionradius=1.5`; `gc_obj_usage_field=6`; `gc_basename_field='field'` | [O] |
| E17 | `D:game/var/envscales.cfg:5-11` | `field` scale 0.033, min=max=1 (no jitter) | [O] |
| E18 | `D:materials/env/env.mat:50-149,864-973` (via FCOL-02, re-cited) | Field crop materials: summer `field1..4`/`field`, winter `field1w..4w`/`fieldw`; Ambient=Diffuse=0, Emission warm `(232,218,195)/255` or neutral `200/255` | [O] secondary |
| E19 | repo: `variant3d/assets/models/manifest.json` entries `mil`, `mil1..4`, `mila`, `mil1a..4a`, `field`; `world3d_entities.gd:302-324,1915-1940,2322-2339,2351-2416`; `game.gd:2722-2765,2830-2847` | Port converted European mill family + one field mesh; donor-grounded rotor hub but baked-PNG stand-in; port field lattice/states differ from donor | [O] |
| E20 | repo: `variant3d/assets/terrain/patterns/donor_patterns.json` (`patterns` 282, `families` 43) | 146 `frt` records converted as relief-cell lists only; **0** pump family; no field/mill family | [O] |
| E21 | hash comparison (SHA-256) of 4 `*_mild*.dds` pairs | `variant3d/assets/terrain/decals_dds/{eurmild,eurmildw,rusmild,turmild}.dds` are byte-identical to donor `D:terrain/decals/buildings/*.dds` | [O]/[D] |
| E22 | `D:objects/env/pump.prop`, `pump1/2/3.prop`; `D:actors/env/pump.actor:1-11`; `D:materials/env/pump.dds` | Pump is an env prop family with 3 meshes and one 512² DDS | [O] |

---

## 3. Asset-by-asset inventory

### 3.1 Mill buildings (European family actually converted)

All donor sizes are bytes from directory enumeration; roles are from the cited actor/prop lines. "Port" column names the converted runtime asset, or **—** (none).

| Donor path | Size | Role | Port asset | Status |
|---|---:|---|---|---|
| `D:actors/buildings/commoneur/eurmil.osm` | 128,876 | finished tower, bound by `eurmil.actor:2-3` | `variant3d/assets/models/obj/shared/buildings/mil.obj` (244,468 B) | converted [O] |
| `D:actors/buildings/commoneur/eurmil1.osm` | 29,316 | build stage 1 | `.../mil1.obj` (52,206) | converted [O] |
| `D:actors/buildings/commoneur/eurmil2.osm` | 47,604 | build stage 2 | `.../mil2.obj` (85,977) | converted [O] |
| `D:actors/buildings/commoneur/eurmil3.osm` | 82,924 | build stage 3 | `.../mil3.obj` (152,079) | converted [O] |
| `D:actors/buildings/commoneur/eurmil4.osm` | 145,780 | build stage 4 | `.../mil4.obj` (268,816) | converted [O] |
| `D:actors/buildings/commoneur/eurmil_death1.osm` | 174,580 | destroyed stage 1 (`eurmil.actor:20-22`) | — | **missing** [O] |
| `D:actors/buildings/commoneur/eurmil_death2.osm` | 136,748 | destroyed stage 2 (`eurmil.actor:23-26`) | — | **missing** [O] |
| `D:actors/buildings/commoneur/attach/eurmila.osm` | 96,740 | scaffold, finished | `.../mila.obj` (168,608) | converted [O] |
| `.../eurmil1a.osm` / `2a` / `3a` / `4a` | 136,060 / 200,324 / 185,388 / 195,556 | scaffold build stages | `.../mil1a.obj` (252,451) / `mil2a.obj` (374,479) / `mil3a.obj` (347,098) / `mil4a.obj` (365,834) | converted [O] |
| `.../eurmil_death1a.osm` / `death2a.osm` | 20,620 / 29,380 | destroyed scaffold | — | **missing** [O] |
| `D:actors/buildings/commoneur/eurmil.actor` | 1,751 | 8-mesh actor manifest | represented implicitly by manifest.json | converted [O] |
| `D:actors/buildings/commoneur/attach/eurmila.actor` | 1,914 | 7-mesh scaffold manifest | implicit | converted [O] |
| `D:objects/buildings/eurmil.prop` | 4,088 | scale 0.43, roll 45, 5×5 diamond collision mask (`eurmil.prop:45-52,106-114`) | not converted (sim uses `data.gd:1330` radius 2.0) | PORT APPROXIMATION |
| `D:materials/buildings/commoneur/eurmil.dds` | 5,592,560 | 2048² DXT5, 12 mips, summer body | `models/tex/shared/buildings/mil.png` (3,998,174 B, 2048² RGBA) | converted [O] |
| `D:materials/buildings/commoneur/eurmilw.dds` | 5,592,560 | winter body | — | **missing** [O] |
| `D:terrain/decals/buildings/eurmild.dds` / `eurmildw.dds` | 1,398,256 each | ground dirt plate, summer/winter | `terrain/decals_dds/eurmild.dds` + `decals_png/eurmild.png` (534,876) / `...w` (2,605,746) — **byte-identical DDS** | present; 3D unused [O] |

Other cultures (same six-slot layout per M02: body, build stages, scaffold, rotor):

| Donor path | Size | Role | Port asset | Status |
|---|---:|---|---|---|
| `D:actors/buildings/commonrus/rusmil.osm` | 49,508 | Russian tower | — | **missing** [O] |
| `D:actors/buildings/commonrus/rusmil{1..4}.osm` | 45,972 / 64,300 / 66,420 / 82,756 | Russian build stages | — | **missing** [O] |
| `D:actors/buildings/commonrus/rusmil_death{1,2}.osm` | 105,460 / 93,524 | Russian destroyed | — | **missing** [O] |
| `D:actors/buildings/commonrus/attach/rusmila.osm` | 70,372 | Russian scaffold | — | **missing** [O] |
| `D:actors/buildings/commontur/turmil.osm` | 256,228 | Turkish tower | — | **missing** [O] |
| `D:actors/buildings/commontur/turmil{1..4}.osm` | 98,820 / 127,172 / 144,308 / 94,356 | Turkish build stages | — | **missing** [O] |
| `D:objects/buildings/{rusmil,turmil}.prop` | 4,055 / 4,172 | roll 45 / 135; different masks | — | **missing** [O] |
| `D:materials/buildings/common{rus,tur}/rusmil{,w}.dds`, `turmil{,w}.dds` | 5,592,560 each | rus/tur body art | — (only `rusmild`/`turmild` ground decals exist) | **missing** [O] |

### 3.2 Rotor / sail

| Donor path | Size | Role | Port asset | Status |
|---|---:|---|---|---|
| `D:actors/buildings/commoneur/attach/eurmilanim.oss` | 55,388 | skinned sail mesh; 251 keys, 30 fps, 1 bone, 1098 verts, 550 faces (E12) | — (no `.oss`/OBJ conversion) | **missing as geometry** [O] |
| `D:actors/buildings/commonrus/attach/rusmilanim.oss` | 45,708 | Russian sail, 878 verts | — | **missing** [O] |
| `D:animations/aaf/eurmilanim.aaf` / `rusmilanim.aaf` | 30 / 30 | `"idle",1,249,morph` | — | **missing** [O] |
| `D:actors/buildings/commoneur/attach/eurmilanim.actor` | 373 | binds `.aaf` + `.oss` | — | **missing** [O] |
| `D:objects/buildings/attach/eurmilanim.prop` | 1,577 | `fasoNone`, `aamLoop`, mill material | — | **missing** [O] |
| (derived bake, donor-sourced) | — | 320² face-on sail sheet | `models/anim/common/buildings/mill_rotor.png` (36,081 B) + importable copy `models/tex/shared/buildings/mill_rotor.png` (36,081 B) + `mill_rotor.json` (107 B) | **PORT APPROX stand-in**; port hub now decoded from `.oss` (`world3d_entities.gd:302-306,1924-1939`) [O]/[D] |
| `D:sounds/ambient/amb_windmill.ogg` | (audio) | distance-driven windmill bed, `gui.script:3234,3281-3302` | `variant3d/assets/sounds/amb_windmill.ogg` (981,042 B) | converted [O] |

### 3.3 Field crop art and field decals

| Donor path | Size | Role | Port asset | Status |
|---|---:|---|---|---|
| `D:actors/env/field1.osm` | 26,524 | crop mesh variant 1; 546 verts / 544 faces; bbox x ±29.259292, y ±25.962615, z [−1.655891,18.796782] | `models/obj/shared/terrain/field.obj` (44,551 B) — identical vertex count, faces, bbox | converted [O] |
| `D:actors/env/field2.osm` | 23,932 | crop mesh variant 2; 495 verts / 496 faces; bbox x ±27.20179, z to 16.46915 | — | **missing** [O] |
| `D:actors/env/field3.osm` | 26,308 | crop mesh variant 3; 546 verts / 544 faces; bbox x ±26.98836, z to 16.46915 | — | **missing** [O] |
| `D:actors/env/field.actor` | 663 | binds the three meshes | implicit | converted [O] |
| `D:objects/env/field.prop` | 5,216 | scale 0.03605085, roll 45, random mesh × season materials; decal binding commented | not converted; port sim uses 0.6 m radius | PORT APPROXIMATION [O] |
| `D:materials/env/field1.dds` | 174,928 | 512×256 DXT5 crop albedo (summer) | `models/tex/shared/terrain/field.png` (48,365 B, 512×256 RGBA) | converted [O] |
| `D:materials/env/field.dds`, `field2..4.dds` | 174,928 each | other summer crop albedos | — | **missing** [O] |
| `D:materials/env/fieldw.dds`, `field1w..4w.dds` | 174,928 each | winter crop albedos | — (metadata only: `prop_winter_materials.json:114-133` says `port_art_exists:false`) | **missing** [O] |
| `D:materials/env/field5/6/7{,w}.dds` | 174,928 each | authored but **unreferenced by any prop** (scan: only `env.mat` mentions them) | — | deliberately out of scope [O] |
| `D:terrain/decals/env/envfieldd.dds` | 349,680 | 512² DXT5 ground decal, summer; 2×2 descriptor | `terrain/deco_png/envfieldd.png` (615,507 B) | converted, pixel-identical per FCOL-02 FC14 [O] secondary |
| `D:terrain/decals/env/envfielddw.dds` | 349,680 | winter twin, identical alpha | `terrain/deco_png/envfielddw.png` (659,209 B) | converted [O] secondary |
| `D:materials/env/pump.dds` | 349,672 | pump env albedo | — | **missing** [O] |

### 3.4 Pattern families (candidate names, disambiguated)

| Donor family | Files | Actual content | Port representation | Status |
|---|---:|---|---|---|
| `frt_*` | **248** | forest vegetation patterns; `frt_s_p_1` = Width 11 × Height 11, objects `grassforest.2`, `pine1`, `horseradish.1`, `pinesmall1` (`pattern.lib` offset 1229903; `generator.cfg:1061-1089` maps `frt_s_p_1..6` to `forests_pine_small`) | 146 records in `donor_patterns.json`, relief `cells` only (e.g. `frt_s_p_1` → `w:11,h:11,cells:[[dx,dy]…]`); no object lists | **NOT a field family**; partial conversion (146/248; all `desert_frt_*` 12/72, `n_small_frt*` 0/41) [O]/[D] |
| `k_pump_*` | **15** | decorative pump clusters; `pump_01` = Width 8 × Height 7, objects `pump1`, `horseradish`, `plantain` (`pattern.lib` offset 23804850; `generator.cfg:1538-1600` family `pump`, Freq=1 each) | **0** records, no `pump` family in `donor_patterns.json`; no pump prop/tex assets in port | **NOT a field family**; unconverted [O] |
| field / mill patterns | **0** | no `.pattern` file or `pattern.lib` record names a field or mill object (E15) | n/a | confirms script-driven placement [O] |

---

## 4. Findings

### 4.1 The exact rule by which fields appear around a mill

**Trigger (all [O] text, activation [U]).** Four paths converge on the same routine:
1. Mill finishes construction → usage `gc_obj_usage_mill` → `_unit_OrderProduce(myHnd, cid, fieldid, 1)` (`ontagstates.inc:140-145`).
2. Map start with `cSeedWheat = True` and not a random map → every built, alive mill is seeded (`generatemap.inc:1009-1025`).
3. Completion of an order whose usage is `gc_obj_usage_field` → `_unit_DoSeedWheat(myHnd, False)` (`doprogressorders.inc:130-135`).
4. AI economic AI calls the same routine (`progresseconomicai.inc:3688-3697`).

**Shape and count ([O]).** `cRow = 7`, `cCount = 49` (`unit.script:6475-6476`). Candidate `i` has
`dirX = -((cRow-0.5)*size/2) + (i mod cRow)*size` and the same for `dirZ`, then `VectorRotateY(dirX, dirY, dirZ, 45)` (`:6491-6494`). This is a **square 7×7 lattice rotated 45° in the ground plane**, not a circle and not an annulus. Its centroid is offset −0.600369 cells in X after rotation ([D] from the 49 candidates); pre-rotation coordinate range is −5.518825…+4.669775 cells.

**Radius / extent ([D] over E1).** Maximum centre distance from the lattice origin is **7.804797 cells ≈ 15.61 m** (2 m/cell); rotated X range −7.8048…+6.6041 cells, Z range ±7.2044 cells. The "field radius" is therefore a **rotated square of half-diagonal ~7.8 cells**, not a circular radius. Per-node clearance scan spans a further ±2 half-cells (`:6506-6511`).

**Orientation ([O]/[D]).** Node lattice rotated **45°**; each field prop has `DefaultRollAngle = 45` (`field.prop:148-150`); the ground decal is placed with `angle = 45` or `225` (`writenewp.inc:26-28`, commented). Mill body itself has `DefaultRollAngle = 45` (eur/rus) or `135` (tur) (`eurmil.prop:112-114`, M02 §4). No camera-facing or wind-driven rotation exists in donor readable data (M02 §5) — the port's rotor billboard history is PORT APPROX; the current port uses a fixed axle (`world3d_entities.gd:2328-2339`).

**Position snap ([O]).** `size2 = sqrt(2*size*size) ≈ 2.401476` cells; `px` snapped with `+size`, `pz` with `+size*0.5` (`unit.script:6497-6499`) — the half-`size` Z offset is a donor detail absent from the port.

**Clearance / rejection ([O]).** 5×5 grid of `gc_collision_size = 0.5` (`:6506-6521`; `dmscript.global:178`); any `GetMapCollisionTag > 0` or out-of-map → reject. Resource scan radius `rad = size*0.9*3 = 4.58487` cells (`:6527-6528`); `food/wood/stone` clearance `rad/3 = 1.52829` cells, `gold/iron/coal` clearance `rad = 4.58487` cells (`:6536-6538`). Since **1.52829 < 1.6981** (spacing), sibling field nodes (registered as `gc_resource_type_food`, `env.inc/initial.inc:48`) do **not** reject each other — the decisive donor fact for "touching fields" ([D], agrees with F2-02 F5).

**Economy ([O]).** 5 gold per field (`unit.script:1691-1693`); no cost lump sum; the port charges the same (`game.gd:2723,2760-2762`).

**Crop stages / seasons ([O]).** No time-based growth stage was found in any readable donor script for `field` (scan: only usage registration, cost, decal call and seed routine). Variety is positional/random (3 meshes × 5 materials), season is explicit (`UseSeasonMaterial = True`, `field.prop:58-76,87-126`; `decals.lib:40-41`). The donor crop mesh is authored unlit/emissive (E18); the decal is lit `bmTransparency` with `imagebrightness=1` (FCOL-02 FC3/FC4). The port's `ripe/growing/regrowing/depleted` machine, 60 s regrow and 18 m adoption radius (`game.gd:211-212,2830-2847`) are **PORT APPROXIMATION** with no donor counterpart found ([U] for any hidden state machine compiled into the binary).

### 4.2 Rotor decode and port fidelity

- Donor sail is a **separate skinned `.oss` child** spawned by name (`+'anim'`) with **no explicit offset** (`miscext2.script:876-878`, `building.inc/initial.inc:130-135`; M02 §3.1). Its relative placement is baked into vertex coordinates.
- In-memory decode (E12): 251 keys @ 30 fps = 8.367 s → **0.751 rad/s** ([D]); single bone, quaternion about **local Y**; blade plane donor XZ, slab thickness 0.857 m in donor Y; axle disc centre donor (0,−1.469455,5.623430), front-face tip donor y=−1.897957.
- `eurmil.osm` tower bbox z [−0.002851,5.914006]; tip is 0.2866 below the cap. These are the numbers the port now uses at `world3d_entities.gd:302-306,1928-1939` ([O] port). Spin sign and the 320² 2D bake on a quad remain **PORT APPROXIMATION** (`world3d_entities.gd:279,290,306`).
- **Gap:** the port has no donor `.oss` geometry, no `.aaf`, no `rusmilanim`, and no death-stage meshes; it renders a face-on baked PNG on a fixed quad. Body yaw 0 is now donor-grounded (no billboard), but the sail sheet is still a proxy ([O]/[I]).

### 4.3 Pattern families: `frt` and `k_pump` are not fields

- `frt` = forest. `frt_s_p_1` objects are trees/weeds (`pattern.lib` offset 1229903), and `generator.cfg:1061-1089` places the family under `forests_pine_small`. It is relevant to F08, not to field placement. Port has 146/248 converted, relief cells only.
- `k_pump_*` = ornamental pumps. `pump_01` contains one `pump1` prop and weeds (`pattern.lib` offset 23804850); `generator.cfg:1538-1600` lists 15 family entries with `Freq = 1`. No port assets or family exist. A pump is a decorative well, **not** an irrigation or crop-stage mechanism for mill fields ([I] — no donor script links pumps to fields; full-tree search found no `k_pump` outside `generator.cfg` and `pattern.lib`).
- No pattern stamps fields or mills. This matters for the port: **terrain-pattern conversion alone will never place mill fields**; the mill seeding rule must be implemented as a separate script stage.

### 4.4 Port representation and gaps (counts)

| Layer | Donor | Port | Gap |
|---|---:|---:|---|
| Mill body meshes (eur family) | 8 | 5 (+5 scaffold) | 2 death stages + 2 death scaffolds missing |
| Mill culture families | 3 | 1 (eur, renamed `mil*`) | rus/tur bodies, props, textures missing |
| Rotor `.oss` / `.aaf` | 2 / 2 | 0 / 0 | replaced by 1 baked PNG + metadata |
| Mill body textures | 6 (3 summer + 3 winter) | 1 (`mil.png`) | 5 missing |
| Mill ground decals | 6 DDS + 6 descriptors | 6 DDS byte copies + 6 PNG; used only in 2D (`world.gd:771-780,2910-2913`) | 3D never loads them ([O] grep in `world3d_*.gd`) |
| Field crop meshes | 3 | 1 | 2 missing |
| Field crop textures | 16 (8 referenced + 8 unreferenced `5/6/7`) | 1 (`field1.dds`→`field.png`) | all winter + 3 referenced summer missing |
| Field ground decals | 2 | 2 | complete; winter never bound in 3D ([O] `world3d_entities.gd:314,448` only) |
| Field patterns | 0 | 0 | none needed |
| `frt` patterns | 248 | 146 (relief only) | 102 missing, object lists absent |
| `k_pump` patterns | 15 | 0 | family absent |
| Pump props/meshes/textures | 1 prop + 3 meshes + 1 DDS | 0 | all missing (ornamental) |

Ground-decal caveat ([O]): `_bld_decal()` builds `res://assets/terrain/decals_png/{nat}{sid}d.png` and is called with the **player nation** (`world.gd:2910-2913`, `data.gd:208` = `rus/bav/pol/swe`). Only `rusmild.png` exists among those nations; `bav/pol/swe` players get no mill dirt plate even in 2D.

### 4.5 Unit reconciliation — correction to F2-01

F2-01 recommended lowering the port clash radius from `1.5·TILE = 3.0 m` to `TILE = 2.0 m` to restore 49 touching fields. Re-deriving from donor constants:

| Quantity | Donor | Port |
|---|---|---|
| node spacing | 1.6981 cells = **3.3962 m** ([D], 2 m/cell) | `step = 1.6981·TILE·0.5 = 1.6981 m` (`game.gd:2740`) |
| food clearance | 1.52829 cells = **3.0566 m** ([D]) | `1.5·TILE = 3.0 m` (`game.gd:2755`) |
| lattice orientation | 45° (`unit.script:6494`) | 45° initially (`game.gd:2745`), but diagonal neighbours are rejected → surviving sub-lattice is axis-aligned ([D], F2-01 §2) |
| accepted count | up to 49, siblings allowed ([D]) | 25 idealised, ≤24 real (F2-01 §2, port simulation) |
| footprint target | crop mesh `58.518572 × 0.03605085 = 2.1096 m`; decal `60 × 0.03605085 × 1.3 = 2.812` in undefined units ([D]) | `FIELD_SPAN_M = √2·1.6981 = 2.40148 m` (`world3d_entities.gd:312`), mesh scaled by 58.518572 → 2.40148 m |

**[D] Under the 2 m/cell reading, the port's 3.0 m clash is already close to donor's 3.0566 m, and the surviving port spacing 3.3962 m exactly equals donor spacing in metres.** The port's actual defects are therefore (a) **half-scaled sow step**, (b) **25 instead of 49 nodes**, (c) **axis-aligned instead of 45° surviving lattice**, and (d) a **footprint scaled to 2.40148 m**, which is ~71 % of donor spacing and ~114 % of the donor crop mesh's prop-scaled width. Lowering the clash to 2.0 m would fix count but produce 49 nodes at **2.4015 m**, i.e. ~71 % of donor spacing — a **PORT APPROXIMATION**, not donor parity. [U]: `gc_meters_to_tile = 2` has **no consumer anywhere in readable donor scripts** (single hit at `dmscript.global:171`), so the 2 m/cell reading is inherited from DTRN-05/F2-02 and remains unconfirmed engine-side.

---

## 5. Concrete donor-grounded recipe for variant3d

**PORT APPROXIMATION overall.** No donor GPU A/B frame exists; the following reproduces *readable donor rules*, not verified pixels.

1. **Placement stage, separate from terrain patterns.** After a mill is `finished`, call one seeding routine (`game.gd:2715,2907` already hooks this). Do not expect `donor_patterns.json` to carry fields — it cannot (E15/E20).
2. **Lattice:** generate exactly 49 candidates (`cRow=7`), `dir = (-(6.5·size/2) + (i mod 7)·size, -(6.5·size/2) + (i div 7)·size)` with `size = 1.6981` **map cells**, rotate each by 45° in the ground plane, then add the mill position snapped by `size2 = √2·size` with X offset `+size`, Z offset `+size·0.5` (`unit.script:6475-6499`). If the port keeps 2 m cells, `step` must be `1.6981·TILE = 3.3962 m`, **not** 1.6981 m.
3. **Acceptance:** for each candidate reject if any of 25 half-cell collision samples (5×5 grid, rotated 45°, spacing `gc_collision_size=0.5` cells) hits collision; reject if any food/wood/stone is within 1.52829 cells (3.0566 m) or ore within 4.58487 cells (9.1697 m) of the candidate (`unit.script:6504-6548`). Do **not** add a field-vs-field exclusion beyond this — donor's 1.52829 cell clearance is smaller than the 1.6981 cell spacing, so siblings survive ([D]).
4. **Economy:** charge 5 gold per accepted node (`unit.script:1691-1693`). No lump sum, no free ring.
5. **Orientation:** rotate the crop instance by 45° (`field.prop:148-150`), and draw the ground decal at 45°/225° (`writenewp.inc:26-28`). Keep the mill body yaw at its authored value (eur/rus 45°, tur 135°: `eurmil.prop:112-114`, M02 §4); do not billboard the sail (M02 §5.1).
6. **Art binding:** use the converted `field.obj` (donor `field1.osm`) and `field.png` (`field1.dds`) for the crop, and `envfieldd.png`/`envfielddw.png` for the ground, with the donor's `texscalefix = 1.3` **geometry/UV** multiplier and `−0.15` UV offset (`misc.script:4298-4305`). The emission tint `(232,218,195)/255` is donor-grounded (`env.mat:58-69`); the 0.22 energy in `world3d_entities.gd:323` is **PORT APPROX** and must be labelled as such.
7. **Scale reconciliation:** the donor crop prop is scaled `0.03605085` (`field.prop:139-145`) and the decal uses `scale=60` with that same `goScale` (`writenewp.inc:26-28`); the port's `FIELD_SPAN_M` shortcut (2.40148 m) must be declared **PORT APPROXIMATION** until the unit of `GetDecalDataByHandle().w` is recovered ([U]). A donor-sized crop instance should be ~2.11 m wide ([D] over `58.518572 × 0.03605085`), larger than the port's current 2.40148 m only after the 1.3× decal is added.
8. **Seasons:** select the winter crop material set `field1w..4w`/`fieldw` when the season is winter (`field.prop:68-76,95-101`) and the winter decal `envfielddw` (`decals.lib:40-41`); alpha is shared, only RGB changes. If the winter DDS PNGs are not converted, reuse the summer crop texture with a labelled **PORT APPROX** winter tint — never claim donor parity.
9. **Stages:** the donor has **no time-based crop stage** in readable text. Keep the port's 4-stage machine only as a gameplay layer and label it **PORT APPROXIMATION**; if visual parity is the goal, prefer the donor's 3 random crop meshes × 5 material variants once those assets are converted.
10. **Rotor:** keep the decoded donor hub/axis path (`world3d_entities.gd:302-306,1928-1939`) and mark the 320² PNG quad as a stand-in; converting `eurmilanim.oss` to a real skinned mesh with its 251-key morph is the donor-faithful follow-up, with spin sign still [U].

---

## 6. Implications

- The port's field geometry problem is **not** primarily a texture or tint problem (FCOL-01/02 already showed the dark albedo mechanism). It is a **placement/unit-scale mismatch**: donor cells were read as metres in `game.gd:2740` and `world3d_entities.gd:312`, while `TILE=2.0` and `gc_meters_to_tile=2` both say one map cell is 2 m.
- Any "make fields touch" change must state which target it serves: **donor spacing (3.3962 m, 49 nodes)** or **current port visual pitch (2.4015 m)**. The two are not the same; conflating them is how F2-01 and the earlier mesh-scale workaround diverged.
- Pattern conversion work (F01/F02) and prop work (F08) should not be expected to yield fields: the donor has no field pattern. A dedicated mill-seeding stage is required.
- The missing winter crop textures and mill body winter texture are the largest concrete art gaps for season parity; the two field decals are the only complete season pair.
- The byte-identical donor DDS copies under `variant3d/assets/terrain/decals_dds/` (E21) are existing port state; this report did not add or remove them, but their presence conflicts with the charter's "no donor binaries copied" rule and is flagged under Risks for COORD adjudication.

---

## 7. Risks

1. **Unit risk [U]:** `gc_meters_to_tile = 2` is a single donor constant with no in-script consumer. If it means "2 tiles per metre" instead of "2 metres per tile", the whole §4.5 reconciliation inverts. Resolve from binary (`D02`/`D05`) before changing `game.gd:2740`.
2. **Activation risk [U]:** every mill→seed caller is a `[*] = ;`-commented `.inc` line. The routine itself is active-looking `misc.script`/`unit.script` text; retail execution is not proven. A binary anchor (D01/D07) is needed before treating the 49-node rule as live behaviour.
3. **Decal-unit risk [U]:** `w` from `GetDecalDataByHandle` has no documented unit; the derived `≈2.812` and crop `≈2.11 m` are readings, not measurements.
4. **Visual risk:** enlarging fields to donor spacing while keeping the 0.6 m sim radius and 2 m building clearance (`game.gd:2763`, `can_place` checks) may overlap mill art or roads; no capture exists to gate this.
5. **Licensing/charter risk:** six mill-ground DDS files in the port are byte-identical donor binaries (E21); COORD must decide whether to keep, replace with derived PNG-only assets, or remove. Worker F07 changed nothing.
6. **Counter-risk to F2-01:** adopting that report's clash-radius reduction would move the port *away* from donor spacing under the 2 m/cell reading; do not apply it as a "donor fix".

---

## 8. UNVERIFIED register (do not promote)

1. Runtime activation of every `[*] = ;`-prefixed donor `.inc` seeding/decal caller (E4, E6).
2. Engine-side meaning of `gc_meters_to_tile = 2` / `UseParentTLFToPosition=False` / `AutoOffset=True` (E16, M02 §8).
3. Unit of `GetDecalDataByHandle().w/h` and therefore the exact donor field overlap ratio.
4. Whether all 49 sown nodes survive the donor environment scan (creation/list timing inside the loop).
5. Real per-map field count for the shipped map: blocked tiles, cliffs, water, roads and treasury all affect it.
6. Any donor growth-stage state machine compiled into the binary; none found in readable scripts.
7. Which random `field1..4` material is chosen per node; `field`/`fieldw` warm emission may never be drawn.
8. Donor spin sign in world space and the 45°/135° yaw→screen mapping without a GPU frame.
9. Visual effect of the port's emission energy 0.22, instance-colour alpha, and shaded-vs-unshaded lighting mismatch.
10. Whether any DLC/expansion adds mill/field patterns (F10 scope).
11. No donor GPU A/B frame and no Godot capture were produced by this ticket — **no parity claim**.

---

## 9. Open questions

- **Q1 (D02/D05):** can the binary confirm `gc_meters_to_tile` semantics and thus settle 3.3962 m vs 1.6981 m node spacing?
- **Q2 (D01/D07):** is `_unit_DoSeedWheat` reachable in the retail binary, and from which mill states?
- **Q3 (F01/F02):** does `pattern.lib` contain any other object-list field (e.g. under a non-`field` BaseName) that places crops on map generation? Current scan says no.
- **Q4 (A03):** should `field2/3.osm` + all `field*w.dds` be converted, or should the port keep one mesh and label the rest PORT APPROX?
- **Q5 (A04):** if 49 donor-spaced fields are rendered, does the 2.11 m prop-scaled crop plus 2.812-unit decal actually touch at 3.3962 m? Needs a donor frame or at minimum a labelled render probe.
- **Q6 (COORD):** what to do with byte-identical donor DDS files already in `variant3d/assets/terrain/decals_dds/`?

---

## 10. Summary (five lines)

1. **[O] Donor mill fields are script-sown, not pattern-stamped:** 7×7 = 49 nodes, 1.6981-cell step, 45° rotation, `size2 = √2·size` snap, up to ~7.8-cell half-diagonal, 5 gold each.
2. **[O] `frt_*` (248) is forest and `k_pump_*` (15) is decorative pumps; neither creates fields, and no pattern names a field or mill.**
3. **[O]/[D] Donor clearance 1.528 cells < spacing 1.6981 cells, so siblings survive; with 2 m/cell the port's 3.0 m clash is donor-close but its 1.6981 m step is half donor.**
4. **[O] Port has 10 eur-mill OBJs, 1 field OBJ, 1 field texture, 2 field decals, a baked rotor PNG; missing death stages, rus/tur mills, winter crops, field2/3, `.oss`/`.aaf`, pump family.**
5. **[I] Recipe: add a dedicated 49-node donor-spaced seeding stage, donor seasons, donor decal scaling, keep stage machine labelled PORT APPROX; no parity claim without a donor A/B frame.**

*End of F07 report. One report written. No donor binary executed or copied; no code, asset, config, test, git or Godot-runner state changed.*
