---
id: Z03
ticket: "HEIGHT WAVE / Z03 — donor truth: height field vs hand-authored 3D relief props"
agent: "Z03 (read-only donor + read-only local audit, subagent)"
date: 2026-11-25
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_RUNNER_JOB__NO_CODE_EDIT
scope: "This report is the ONLY repo file written. No source/shader/config/asset/test/JSON/PNG/donor/queue/git edit. No Godot process or runner job. Donor installation read in place (bytes/latin-1/struct/Pillow); nothing copied into the repo."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
donor_root: "C:\\Games\\Cossacks 3 (private use, read-only)"
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, PORT APPROX]
parity_guard: "No donor GPU A/B frame exists (CHARTER §3/§5). Pixel-to-object attribution is INFERRED/UNVERIFIED. NO DONOR PARITY CLAIM."
verdict: "DONOR HAS TWO RELIEF CHANNELS: (H) per-cell height field sculpted by .pattern float32 grids, and (P) hand-authored terrainmesh*.osm props 6.9-9.55 units tall that carry mountain silhouettes. PORT HAS NEITHER FULLY: analytic heights + 2 coarse grids, ZERO relief-prop OBJs/manifest entries, and no conversion/instancing path. BLOCKER is a hard-coded conversion table plus a missing pattern->prop data link and no consumer."
---

# Z03 — Donor relief: height field alone, or separate 3D relief props?

> [!IMPORTANT]
> **Donor is truth.** Labels used throughout: **OBSERVED** (literal donor line, decoded
> donor bytes, or direct on-disk file listing), **DERIVED** (arithmetic/control-flow
> consequence of observed values), **INFERRED** (best reading without a pixel-aligned
> donor A/B), **UNVERIFIED** (not provable with the files/instruments available),
> **PORT APPROX** (an explicit port substitute, not donor truth). All donor paths are
> under `C:\Games\Cossacks 3\`; all local paths under the repo root. No donor binary
> was executed or copied. **No donor parity claim.**

---

## 0. Mandate and method

Ticket Z03 asks three questions plus one height-range question:

- **(a)** Which donor object supplies the *visible* hills/cliffs in the reference samples —
  the height field alone, or the separate hand-authored 3D mountain/plateau/ravine props
  (`terrainmesh*.osm`, 7–10 units tall) and relief `.pattern` float32 grids?
- **(b)** Are those props converted into this port's assets? (search
  `variant3d/assets/models` for terrainmesh/hill/mountain/ravine/cliff OBJs and manifests)
- **(c)** If absent, what is the exact asset-conversion path and the blocker?
- **(d)** Are donor heights ever exaggerated, or only ±2.964?

Documents read (orientation, not new evidence): `WAVE_G_CHARTER.md`,
`docs/terrain_swarm_2026-11-25/CHARTER.md`,
`docs/coord_swarm_2026-11-25/reports/DTRN_02_donor_terrain_geometry.md`,
`DPATTERN_01_relief_grids.md`, `RELIEF_01_stamping.md`, `RELIEF_02_stamp_marker.md`,
and sibling `reports/Z02_hills_invisible.md` (consistency check only).

New direct evidence in this report: (i) donor text/binary reads in place
(`generatemap.inc`, `dogenerate.inc`, `pattern.lib`, `.prop`, `.actor`, `actors.lib`,
8 relief `.osm`, 2 mountain `.pattern`, 13 `.map`, 5 relevant `.dds`); (ii) local
recursive listings of `variant3d/assets/models/**`, `variant3d/assets/terrain/**`,
`variant3d/tools/**`; (iii) local source reads of `convert_models.py`,
`export_donor_patterns.py`, `world3d_terrain.gd`, `world3d_entities.gd`, `game.gd`,
`data.gd`, `main.gd`, `pattern_gen.gd`, `config.gd`.

---

## 1. Donor truth — there are TWO relief channels

### 1.1 Channel H — the height field (per-cell float grid)

| Fact | Evidence | Label |
|---|---|---|
| Base amplitudes `cPlateauHeight=2.964`, `cHillHeight=2.964/2.25`, `cRavineHeight=−2.964`, `cWaterHeight=−1.1` | donor `data/scripts/common.inc/generatemap.inc:4-7` (`[*] = ;` = live source, not comment — RV-SEL-01 convention) | **OBSERVED** |
| Height from mask R/G/B: `hwater = −1.1*(fb*(1+fr*3.5))`; plateau `+2.964*fr`, hill `+1.31733*fr`, ravine `−2.964*fr` | donor `generatemap.inc:567,570-574` | **OBSERVED** |
| Grid = centred engine grid (256/320/480/640 by map size); collision on a 2× grid with `cDiff1=0.5`/`cDiff2=0.55` from the *same* field | donor `generatemap.inc:541-574`, `miscext2.script:19-26`, `texturemap.inc:63-64,133-138`, `dmscript.global:132-135`; DTRN-02 C3/C5/C12 | **OBSERVED** |
| Relief patterns carry their own `w*h` float32 height windows; min/max match `pattern.lib` `HeightFieldMin/Max` bit-exactly (26/26 patterns) | donor `data/pattern/*.pattern` decoded; `pattern.lib:351-352,6805-6806,549585-549586…`; DPATTERN-01 §2/§3/§4.7 | **OBSERVED** |
| Those grids are *authored shapes*: ravine floor ≈−2.96 with asymmetric +3.14 lip; plateau caps broad/flat ≈3.2–3.5; hills narrow crests | donor `k_ravine_1`, `plt1/plt2`, `hil1` decodes, DPATTERN-01 §4.1–4.5 | **OBSERVED** (grid), **INFERRED** (visual reading) |
| Final height is baked into `.map` as `float32[W*H]`, row-major | `variant3d/tools/import_donor_map.py:113-174` (read-only decoder); DTRN-02 C16 | **OBSERVED** |
| Grey vertical cliff faces are **tile art**, not separate geometry: `rock1..9vf` / `rock1..9vs` materials use `data/terrain/tiles/textures/rock1..9.dds`, gated by collision tag + height class and steepness | donor `data/terrain/tiles/tiles.mat` (`Material.Name = rock1vf…`, `refkey=verticalfront/verticalside`), `reftile.mat`, `texturemap.inc:433-447,592-601`; DTRN-02 C13/C15 | **OBSERVED** (materials/rules), **UNVERIFIED** (runtime binding) |

Channel H therefore supplies **shallow relief and ravine/plateau *floor* shapes**, plus
the *art* of steep faces. It cannot, by itself, supply a tall 3D silhouette: at the
port's `TILE_M=2.0` a 320² map is 640×640 m while the height span is ≤5.93 m
(DTRN-02 §6) — mean gradient well under 1% (Z02 rank 1). Donor metres-per-cell is
**UNVERIFIED** (DTRN-02 C20), so that gradient argument is a port-scale derivation,
not a donor constant.

### 1.2 Channel P — the hand-authored 3D relief props

| Fact | Evidence | Label |
|---|---|---|
| Four mountain props `terrainmesh1..4` and four plateau props `terrainplateau1..4` are IDP2 `.osm` meshes under `data/actors/env/`; actors bind `refmountain.actor` | donor `data/actors/actors.lib:1200-1213` (mesh), `:1216-1229` (plateau); `data/actors/env/terrainmeshN.actor`; direct actor read | **OBSERVED** |
| Decoded bboxes (direct `.osm` header read, first frame): `terrainmesh1` 2,662 v / 5,305 f, x[−14.02,13.89] y[−13.52,13.45] **z[0.07,7.45]**; mesh2 z[−0.03,8.03]; mesh3 z[0.01,**9.55**]; mesh4 z[0.01,6.93]; plateau1 z[−5.35,5.35]; plateau2 z[−0.24,**10.93**]; plateau3 z[−0.32,2.84]; plateau4 z[−0.52,4.34] | donor `data/actors/env/terrainmesh{1..4,plateau1..4}.osm`, 68-byte IDP2 header + `<3f I>` vertex records | **OBSERVED** |
| Mountain family patterns have **all-zero height grids** and embed prop references: `g_mnt_1` `HeightFieldMin=0`/`Max=0` (`pattern.lib:337491-337492`) and its `.pattern` float window @1562 is all 0.0 (43×38); `g_mnt_3` likewise (`pattern.lib:342363-342364`, window @1124 all 0.0, 32×37). 112 `BaseName = terrainmeshN` records across `pattern.lib`; `g_mnt_1 → terrainmesh4` at `pattern.lib:338482` | direct donor reads this ticket; DPATTERN-01 §4.6/§6 | **OBSERVED** |
| Props have their **own albedo**, not a height-field tile: `data/objects/env/terrainmesh1.prop:14` `Mesh[0].DefaultMaterialName = terrainmesh1`, `:18` winter `terrainmesh1w`; `data/materials/env/terrainmesh1.dds` 5,592,560 B, 2048² RGBA. The texture is a grey radial/striated rock field with olive edges (previewed read-only) | donor `.prop` / `.dds` direct read; DPATTERN-01 T7/T8 | **OBSERVED** (file/texture), **INFERRED** (visual match to reference cliff faces) |
| Relief props are exempt from the generic random rescale: `if StrExists(basename,'terrainmesh') or StrExists(basename,'stones') then continue` | donor `data/scripts/common.inc/dogenerate.inc:1984-1985` | **OBSERVED** → **DERIVED** authored scale 1 |
| `terrainplateau1..4` have actors but **no** `data/objects/env/terrainplateau*.prop` and **zero** `BaseName = terrainplateau*` records in `pattern.lib` | direct donor negative scans; DPATTERN-01 §6 | **OBSERVED** (negative) → selection/placement **UNVERIFIED** |
| Runtime selection among multiple `terrainmeshN` inside one mountain `Objects` list is engine-side; no plaintext consumer found | DPATTERN-01 §9 Q4; DTRN-02 §9 Q5 | **UNVERIFIED** |

---

## 2. (a) Which donor object supplies VISIBLE hills/cliffs in the reference samples?

**Reference samples used** (paths cited in `CHARTER.md:23-25`):
`C:\Users\Maxym.Oboyshev\Downloads\c3\cossacks-3-v1-498085.jpg` (sample A),
`…\articolo-787.jpg` (sample B), plus the 12-shot folder `…\c3\`. Direct read of
samples A and B (plus `large_1.webp`, `899956545_preview_…jpg`, `523480776.jpg`,
`cossacks-3-guardians-of-the-highlands-…-wallpaper-3.jpg`): the dramatic relief is
concentrated in A — steep-sided, flat-topped grey-rock mesas/ravines with radial
striations; B shows shallow depressions; the other four are mostly flat/forest/building
shots. No tall pointed mountain is unambiguously present in the 12 samples.

**Answer, split by feature class:**

1. **Mountain / hill silhouettes (the 7–10-unit class in the ticket):** donor supplies
   these with **Channel P props**, not the height field. The decisive donor fact is that
   mountain pattern height grids are all-zero (`g_mnt_1`, `g_mnt_3` direct decode;
   `pattern.lib:337491-337492`) while the same patterns list `terrainmeshN` objects
   (`pattern.lib:338482`) whose meshes are 6.93–9.55 units tall and ~26–28 units wide.
   The port's own Z02 reached the same conclusion from DTRN-02 alone
   (`Z02_hills_invisible.md:63-65,128,330`). **OBSERVED** (config + bboxes); the
   identification of any *particular* pixel as a prop is **INFERRED** — no donor GPU A/B
   exists.

2. **Ravines / plateau mesas visible in samples A and B:** donor supplies the **shape**
   through **Channel H** — relief `.pattern` float32 grids stamped into the height field
   (plateau caps ≈3.2–3.5, ravine trough ≈−2.96 with asymmetric lip, DPATTERN-01 §4.1–4.5),
   with the grey vertical faces painted by the `rockNvf`/`rockNvs` tile art on steep
   cells (`tiles.mat`, `texturemap.inc`). The sample-A grey radial striations visually
   resemble the `terrainmesh1.dds` rock texture more than the `rock1/rock8.dds` tile
   textures, so a *prop contribution* to those faces is **INFERRED (plausible, unproven)**;
   it must not be asserted. **OBSERVED** (donor shape config + material names),
   **UNVERIFIED** (which object produced a given sample pixel).

3. **What is NOT donor truth:** "the height field alone produces the visible hills"
   is refuted for mountains (zero grid + props) and is at best an incomplete reading for
   ravines (grid + cliff tile art + possible props). Conversely "the props produce all
   visible relief" is also unproven — plateaus/ravines have real height grids.

**No parity claim.** Sample identification is pixel-level inference; only a donor GPU
A/B frame could settle it, and none exists (`CHARTER.md:57-58`, Z02 §5).

---

## 3. (b) Are those props converted into this port's assets?

**No — zero relief-prop geometry or manifest entries.** Direct recursive audit:

| Local path | Finding | Label |
|---|---|---|
| `variant3d/assets/models/obj/*.obj` | 280 OBJs, extension census: `.obj` 280, `.mtl` 280, `.json` 62, `.png` 2,292, `.import` 2,572. Names: units, buildings/stages, ships, trees, `rock*`, `stone`, `field`, bushes/flowers/gifts. **No** `terrainmesh*`, `hill*`, `mountain*`, `ravine*`, `cliff*` OBJ. | **OBSERVED** (negative) |
| `variant3d/assets/models/manifest.json` | 280 model entries; `game = C:\Games\Cossacks 3`. A sid search for `terrainmesh|terrainplateau|mountain|ravine|cliff|hill` returns nothing; only `rock`/`stone` decorative sids (39 of them). | **OBSERVED** (negative) |
| `variant3d/tools/convert_models.py:412-496` (`env_models()`) | Hard-coded table: trees, `rock`/`stone`/`field`, `rock_stones1..10`, `rock_smallstones1..6`, `rock_landstone1..4`, `rock_sea1..6`, `rock_smallstonesea1..6`, `rock_stonessea1..10`, bushes/flowers/plantain/reed/fern, christmas trees, gifts. **No relief prop entry.** | **OBSERVED** |
| `variant3d/assets/terrain/patterns/donor_patterns.json` | 982,264 B; `source = C:/Games/Cossacks 3/data/pattern/*.pattern + data/game/var/generator.cfg`; 43 families / 282 patterns; `families["mountains"] = [g_mnt_1..g_mnt_7]` present. String count: `terrainmesh` **0**, `terrainplateau` **0**. Per pattern only `{"w","h","cells"}`. | **OBSERVED** (negative) |
| `variant3d/tools/export_donor_patterns.py:139-155` | Exporter writes only mask cells + family weights; no sculpt config, no `Objects`/`BaseName` prop links. | **OBSERVED** |
| `variant3d/assets/terrain/prop_winter_materials.json` | Contains 4 `terrainmesh1w..4w` entries with donor `materials/env/env.mat:1416,1420,1424,1428`. **Names/materials only — no meshes.** | **OBSERVED** |
| `variant3d/scripts/world3d_terrain.gd:91-93,1515` | Explicit comments: mountain grids are all-zero and embed props, "they are deliberately NOT in these tables; props are a separate ticket"; `stats.not_done` lists `"mountain terrainmesh props"`. | **OBSERVED** |
| Repo-wide `*.gd` grep for `terrainmesh` | No instantiation/placement consumer anywhere (only the comment above). | **OBSERVED** (negative) |

The *only* grey cliff art present locally is the terrain tile atlas path
(`rockNvf`/`rockNvs` switched by `world3d_terrain.gd:164-175,805-836,1340-1354`),
which is Channel H art, not prop geometry.

---

## 4. (c) Exact asset-conversion path and blocker

### 4.1 The path that already exists (observed)

`variant3d/tools/convert_models.py` is the canonical donor→port geometry converter:

1. `read_osm()` at `:74-99` parses the IDP2/MD2-style header (`<17i`, 68 B), UVs,
   triangles and **first-frame** vertices (`<3f I`). It already reads exactly the
   `terrainmesh*.osm` format (verified here by decoding all 8 relief props with the
   same layout).
2. `write_obj()` at `:114-131` writes `assets/models/obj/<sid>.obj` plus `.mtl`;
   `write_mtl()`/`convert_texture()` at `:133-158` write `assets/models/tex/<sid>.png`
   from the donor `.dds` with Pillow.
3. `main()` at `:499-562` enumerates the models from the hard-coded
   `unit_models()` + `building_models()` + `ship_models()` + `env_models()` tables
   (plus `stage_models()` behind `--include-stages`), converts each, records
   `sid / mesh / texture / bbox / verts / faces` into `assets/models/manifest.json:559-560`.
   Invocation: `python variant3d/tools/convert_models.py --game "C:\Games\Cossacks 3" --out variant3d/assets/models`.
4. The runtime already loads converted OBJs by sid from `res://assets/models/obj/`
   and reads bboxes from `manifest.json` — `variant3d/scripts/world3d_entities.gd:84,87,410,1146,1258`.

**Exact minimal insertion for relief props (proposal, not executed):**

- Add `terrainmesh1..4 → ("terrainmesh1".."terrainmesh4", "terrainmesh1".."terrainmesh4")`
  rows to `env_models()`'s table at `convert_models.py:422-486`, using donor
  `data/actors/env/terrainmeshN.osm` + `data/materials/env/terrainmeshN.dds`
  (the function builds those paths at `:489-495`). Add a second sid per prop for
  `terrainmeshNw` if winter materials are required (`terrainmeshN.prop:17-18`,
  `prop_winter_materials.json`). `terrainplateau*` has **no** donor `.prop`, so it
  cannot use the same `(mesh, texture)` rule — **UNVERIFIED** how it is authored.
- Re-run the converter command above → produces `obj/terrainmeshN.obj`, `.mtl`,
  `tex/terrainmeshN.png` and 4 new manifest entries; no donor binary is copied.
- Add a placement consumer: donor pattern `Objects`/`BaseName` links
  (`pattern.lib:338482` etc.) must reach a mountain stamp, then one prop instance
  at the stamp centre with **authored scale 1** (`dogenerate.inc:1984-1985`).

### 4.2 Blockers (why this is not a one-line fix)

| # | Blocker | Evidence | Label |
|---|---|---|---|
| B1 | **Hard-coded conversion enumeration.** `env_models()` does not list relief props; `main()` never sees them. 280 manifest entries, zero relief props. | `convert_models.py:412-496,519-524`; manifest audit §3 | **OBSERVED** |
| B2 | **No pattern→prop data link in the port.** `donor_patterns.json` has `terrainmesh` count 0 and per-pattern fields only `w/h/cells`; `export_donor_patterns.py:139-155` never parses `pattern.lib` `Objects`/`BaseName`. The 112 donor `BaseName = terrainmeshN` records are absent locally. | §3 table; `export_donor_patterns.py:139-155` | **OBSERVED** |
| B3 | **No runtime consumer / instancing owner.** `world3d_terrain.gd` builds one heightfield mesh; `stats.not_done` lists props; no `.gd` reads a prop list. `world3d_entities.gd` is contested by M03/P11 (Z02 §4.4), so COORD must grant ownership. | `world3d_terrain.gd:1515`; repo grep; Z02 §4.4 | **OBSERVED** (port), grant **UNVERIFIED** |
| B4 | **Selection rule engine-side / UNVERIFIED.** Which `terrainmeshN` a mountain stamp picks (5 in `g_mnt_1`); no plaintext consumer. Any port choice is PORT APPROX. | DPATTERN-01 §9 Q4; DTRN-02 §9 Q5 | **UNVERIFIED** |
| B5 | **`terrainplateau1..4` unplaceable by the same path.** No `.prop`, zero `pattern.lib` `BaseName` refs — donor itself does not generator-stamp them. | direct donor negative scans; DPATTERN-01 §6 | **OBSERVED**, selection **UNVERIFIED** |
| B6 | **Season materials.** Props swap `terrainmeshN` ↔ `terrainmeshNw`; converter emits one texture per sid, so a winter sid/second conversion pass is needed. | `terrainmesh1.prop:17-18`; `prop_winter_materials.json` | **OBSERVED** |
| B7 | **No visual proof of placement correctness.** Which stamp centre, exact world scale, overlap with starts/build slots, and whether a 64² seed even has a mountain stamp cannot be validated without a fresh capture; donor GPU A/B absent. | `CHARTER.md:57-58`; Z02 §5 | **UNVERIFIED** |

Z02 classifies this as its "Stage C — correct but NOT minimal" option and requires a
new derived-data tool (e.g. `variant3d/tools/bake_terrainmesh.py` built on
`convert_models.py:75`), new derived assets, and an instancing hook
(`Z02_hills_invisible.md:279-295`). This report confirms that assessment with direct
donor/local evidence and adds blockers B2 and B6.

---

## 5. (d) Are donor heights ever exaggerated, or only ±2.964?

**Answer: the *nominal generator constants* are ±2.964, but donor heights are NOT
universally bounded by ±2.964, and there is no plaintext global "exaggeration"
multiplier. The apparent exaggeration comes from (i) per-pattern authored clamps and
(ii) the 3D props, both of which exceed the nominal band.**

1. **Nominal band (OBSERVED).** `generatemap.inc:4-7`: plateau +2.964, hill +1.31733,
   ravine −2.964, water bed −1.1. Two decoded random maps (bonmis1, engmis4) are
   exactly clamped to ±2.964 (DTRN-02 C10, §6).

2. **Real mission maps exceed it (OBSERVED — new direct scan this ticket).** I reused
   the read-only decoder `variant3d/tools/import_donor_map.py:113-174` on 13 donor
   `.map` files. Five exceed the ±2.964 band:

   | Donor map | min | max | cells with \|h\|>2.9641 |
   |---|---:|---:|---:|
   | `data\maps\missions\ausmis2.map` | −2.964000 | **+3.164026** | 3 |
   | `data\maps\missions\ausmis3.map` | −1.259804 | **+3.046386** | 120 |
   | `data\maps\missions\ausmis5.map` | −2.964000 | **+3.321129** | 706 |
   | `data\maps\missions\battle4.map` | **−3.540826** | +3.058012 | 257 |
   | `data\maps\missions\ausmis1.map` | −1.222419 | +3.092545 | 11 |

   Eight others (incl. `ukrmis4`, `engmis1`, `tutmis1`, `rusmis3`, `bonmis3`,
   `battle1`, `battle3`, `ausmis4`) stay within ±2.964. **DERIVED:** ±2.964 is a
   common ceiling, not a hard universal clamp; the cause of the excess is
   **UNVERIFIED** (engine-side stamp clamp / authored mission data).

3. **Pattern grids themselves exceed ±2.964 (OBSERVED, DPATTERN-01 §3).** `plt3` max
   **+4.7413**, `hil1` max **+3.8613** (scale 0.65), `k_ravine_4` min **−3.0660**,
   `k_ravine_2` min −3.2365, `k_ravine_big_stone_1` min −2.9636/max +0.1739. The
   per-pattern `HeightFieldMin/Max` literals equal the decoded grid min/max exactly.

4. **Props are far above the band (OBSERVED).** `terrainmesh3` z up to **9.55**,
   `terrainplateau2` up to **10.93** — roughly 2–3.7× the +2.964 ceiling in the same
   donor units. This is the real "exaggeration" of visible mountain relief.

5. **No global exaggeration control found (UNVERIFIED negative).** Per-pattern
   `HeightFieldScale` values are mostly 1.0 with ±0.925, 1.175, 0.8, 1.5, 0.65 on a
   few patterns (`pattern.lib`; DPATTERN-01 §5.2); the sculpt config has **zero**
   plaintext script consumers (9,520 hits only in `pattern.lib`). No donor
   `HEIGHT_GAIN`/`exaggeration` setting exists in the files read.

6. **Port-side comparison (PORT APPROX, not donor).** `data.gd:246` defines
   `RELIEF_SCALE = {plains:1.0, hills:1.5, mountains:2.2}` and `game.gd:1194-1210`
   multiplies the analytic dome term by it; but the composite is then clamped to
   ±2.964 (`game.gd:1254-1274`, `RELIEF_PLATEAU`/`RELIEF_RAVINE`). Therefore the port
   never emits heights beyond ±2.964, and its 2.2× dome scale is a **port-authored
   substitute**, not a donor constant. It does not reproduce the donor's out-of-band
   mission-map heights or the props' 7–10-unit relief.

---

## 6. Claim register

| # | Claim | Evidence | Label |
|---|---|---|---|
| 1 | Donor has both a height-field channel and a 3D prop channel | §1.1, §1.2 | **OBSERVED** |
| 2 | Mountain patterns have zero height grid and carry `terrainmeshN` props | `pattern.lib:337491-337492,338482`; direct `.pattern`/`.osm` decode | **OBSERVED** |
| 3 | Relief props are 6.93–10.93 units tall | direct IDP2 bbox decode of 8 `.osm` | **OBSERVED** |
| 4 | Mountain/hill silhouettes in donor come from props | §2 item 1; Z02 §2 rank 2 | **OBSERVED** (config) / **INFERRED** (pixels) |
| 5 | Sample-A/B ravine shape comes from height-field pattern stamps + cliff tile art | DPATTERN-01 §4; `tiles.mat`; §2 item 2 | **OBSERVED** (config) / **UNVERIFIED** (pixel attribution) |
| 6 | Port has zero relief-prop OBJs/manifest entries | §3 table | **OBSERVED** (negative) |
| 7 | Converter can read the format but never enumerates the props | `convert_models.py:74-99,412-496,519-524` | **OBSERVED** |
| 8 | Exact blocker chain B1–B7 | §4.2 | **OBSERVED** / **UNVERIFIED** as marked |
| 9 | Donor heights sometimes exceed ±2.964 | 13-map direct scan, §5.2 | **OBSERVED**; cause **UNVERIFIED** |
| 10 | No donor global height-exaggeration multiplier in plaintext | §5.5 | **UNVERIFIED** (negative) |
| 11 | Port dome scale 2.2 is PORT APPROX and final heights are still clamped ±2.964 | `data.gd:246`; `game.gd:1194-1210,1254-1274` | **OBSERVED** (port), **PORT APPROX** |

---

## 7. Open questions (UNVERIFIED — do not guess)

1. Which object exactly produced the grey striated faces in sample A — prop texture,
   `rockNvf/vs` tile art, or both? Needs a donor GPU A/B; none exists.
2. Runtime selection rule among several `terrainmeshN` in one mountain `Objects` list.
3. `terrainplateau1..4` authoring/placement (no `.prop`, no `pattern.lib` refs).
4. Does any donor map/skirmish path actually place props in the two reference-map
   screenshots? Engine-side, no plaintext consumer.
5. Cause of the 5 mission maps exceeding ±2.964 (stamp clamp order vs authored data).
6. Exact donor metres-per-cell / height unit (DTRN-02 C20), needed to convert prop
   units to port metres without inventing a scale.
7. Winter prop material handling if relief props are ever converted (second sid).
8. Draw-call cost of adding props (P02/P11) and ownership grant for instancing.

---

## 8. Summary — direct answers

- **(a)** Donor's *mountain/hill silhouette* is supplied by the separate 3D props
  (`terrainmesh*.osm`, 6.93–9.55 units tall), because mountain `.pattern` grids are
  all-zero; donor's *ravine/plateau floor shape* is supplied by the `.pattern` float32
  grids stamped into the height field, with steep faces painted by `rockNvf/vs` tile
  art. For samples A/B specifically, the pixel-to-object attribution is
  **INFERRED/UNVERIFIED** — no donor GPU A/B. **No parity claim.**
- **(b)** **No.** `variant3d/assets/models/obj/` has 280 OBJs and none is a
  terrainmesh/hill/mountain/ravine/cliff mesh; `assets/models/manifest.json` has
  280 entries and zero relief props; `donor_patterns.json` has zero prop links;
  only `prop_winter_materials.json` names `terrainmesh1w..4w` (materials only).
- **(c)** The path is `convert_models.py:read_osm()` → `write_obj()`+`convert_texture()`
  → `manifest.json`, enumerated by `env_models()`; add relief-prop rows there, re-run
  with `--game/--out`, then add a pattern→prop data link and an instancing consumer.
  Blockers: B1 hard-coded table, B2 no prop link in derived data, B3 no consumer and
  contested file ownership, B4 engine-side selection UNVERIFIED, B5 plateau props
  unplaceable by the same rule, B6 winter materials, B7 no visual proof.
- **(d)** Donor nominal amplitudes are ±2.964, **but** 5 of 13 directly decoded mission
  maps exceed it (max +3.321, min −3.541); pattern grids reach +4.741/−3.066; props
  reach 9.55/10.93 units. No plaintext global exaggeration multiplier was found; the
  port's 2.2× dome scale is a PORT APPROX and its final heights remain clamped ±2.964.

*End of Z03. Read-only; one report; no runner job; no donor file copied or run;
no code, asset, config or test edit; no donor parity claim.*
