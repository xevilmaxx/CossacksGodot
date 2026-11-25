---
id: FOLD-03
ticket: "ASSET COMPLETENESS — exhaustive donor-vs-port mesh inventory (owner: 'maybe you skipped some obj files in donor')"
owner: FOLD-03 subagent
created: 2026-11-25
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_RUNNER__NO_GODOT__NO_DONOR_COPY
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, "PORT APPROX"]
priors_read: [WAVE_G_CHARTER.md, CHARTER.md, N07_all_nations_assets.md, Z03_donor_relief_props.md, C01_asset_impl.md]
parity_guard: "No donor GPU A/B frame exists (CHARTER.md:57-58, :122-130). 'Donor-derived' means file/byte provenance only, never a rendered-look claim. Every visual-impact statement below is UNVERIFIED. No Godot was launched, no runner job submitted, no donor file copied into the repo or executed."
scope: "This report is the ONLY repo file written. Donor installation read in place under C:\\Games\\Cossacks 3\\data (bytes + latin-1 text); port files read only; throwaway probe scripts/CSVs live in %TEMP%\\opencode (fold03_*.py/.csv), outside the repo."
state_note: "C01-ASSET was landing during this read: convert_models.py LastWriteTime 2026-11-25 15:52:22; manifest.json first observed at 299 entries (LastWriteTime 2026-11-25 15:58:15) and C01_asset_impl.md appeared before this report was written (status DELIVERED__...__RELEASED, its §0/§3/§8). All figures below use the LANDED 299-entry state; the pre-C01 baseline was 280 entries."
---

# FOLD-03 — exhaustive donor-vs-port mesh completeness inventory

> [!IMPORTANT]
> **Labels.** **OBSERVED** = literal on-disk listing, decoded donor binary header, or
> literal file:line read this pass. **DERIVED** = deterministic set arithmetic over
> observed paths. **INFERRED** = reading without a pixel-aligned donor A/B frame.
> **UNVERIFIED** = cannot be proven with the available instruments (no Godot, no
> donor GPU frame). **PORT APPROX** = an explicit port substitute, not donor truth.
> Every MISSING row carries its donor path (and donor `path:line` where a text file
> defines the reference), byte size and header vertex count. Visual consequences
> are UNVERIFIED throughout. **No donor parity claim anywhere in this report.**

---

## 0. Direct answer (OBSERVED + DERIVED)

1. **The donor mesh census is complete.** `data/` holds **17,001 files**; **4,232**
   are renderable mesh binaries — **3,897 `.osm` + 335 `.oss`**, **zero `.mesh`**.
   All live under `data/actors/`: `buildings` 3,464 / `units` 378 / `env` 273 /
   `pfx` 97 / `misc` 20. The 976 `.actor` files contain **4,278**
   `MeshObjects.LoadFromFile` references (3,950 `.osm` + 327 `.oss`), and
   **every referenced path resolves on disk** — no hidden mesh family behind an
   actor reference.
2. **The port is 299 models, not 280.** `variant3d/assets/models/manifest.json`
   has **299 entries** (280 base + C01-ASSET's 19 additive), **299 `.obj`**, 299
   `.mtl`, 193 `.png`, **0 `.glb`/`.gltf` anywhere in the repo**. The 299 entries
   name **296 unique donor mesh paths** (three donor meshes are reused by two sids
   each: `peaukr.oss`, `swordsmansco.oss`, `stones1.osm`).
3. **3,936 donor mesh files are not in the manifest** (4,232 − 296). This is not
   one forgotten folder: it is **2,906 nation building/stage/death meshes**,
   **396 common-family wall/tower/gate variants**, **307 unit meshes**,
   **174 env props**, **97 PFX meshes** and **20 misc meshes**. The hard-coded
   enumeration in `variant3d/tools/convert_models.py:165-496` plus the opt-in
   additive functions `:512-611` is the sole gate — every reader
   (`:48-107`) can parse these files.
4. **The genuinely parity-relevant misses, in priority order:** (a) relief
   *instancing* is still absent although `terrainmesh1..4` are now converted;
   `terrainplateau1..4` have no albedo/.prop/pattern link and cannot be placed
   by the same rule; (b) **31 `_horse.oss` mount meshes** — zero horse OBJs or
   manifest entries exist, so cavalry has no donor mount geometry; (c) the
   **Ukrainian `chaika` hull** (2619 verts) is the one missing ship hull;
   (d) **16 remaining nation halls** + **35 nation-specific soldier `.oss`**;
   (e) common-family walls/towers/gates/45° pieces (396) and mission bridges;
   (f) env variety (83 trees, 43 ground flora, 40 props).
5. **Deliberately out of scope / not a mesh:** all **97 PFX** meshes (mostly
   3,148-byte empty particle placeholders), **18 misc UI/editor markers**,
   weather (`clouds.weather` + DDS billboards — zero mesh), **deer/animals/birds
   (zero donor files exist)**, `terrainmeshdesert1..4`/`terrainmesh1w..4w`
   (material variants of the already-converted `terrainmesh1..4.osm`, no own
   `.osm`), and the 660-byte / 8-vert placeholder stage pieces.

---

## 1. Method and evidence classes (OBSERVED)

| Step | Instrument | Result |
|---|---|---|
| Whole-tree census | read-only recursive `Get-ChildItem` on `C:\Games\Cossacks 3\data` | 17,001 files; extension histogram (`.tga` 4,510, `.osm` 3,897, `.dds` 1,469, `.prop` 1,285, `.actor` 976, `.pattern` 710, `.oss` 335, `.aaf` 246 …) |
| Mesh header decode | throwaway `%TEMP%\opencode\fold03_probe.py`, `struct.unpack('<17i')` for IDP2 `.osm` (verts=idx6, faces=idx8) and `<6i` for `.oss` (verts=idx3, faces=idx4) | **4,232/4,232 parsed, 0 errors**; sizes and vertex counts in §5 are these decoded values |
| Actor cross-check | `Select-String 'MeshObjects\.LoadFromFile\s*='` over 976 `.actor` files | 4,278 refs → `.osm` 3,950 / `.oss` 327; **0 refs to a missing file**; no `.mesh` extension referenced |
| Port census | read-only `manifest.json` parse + recursive `Get-ChildItem` | 299 entries / 299 OBJ / 299 MTL / 193 PNG / 0 GLB; 296 unique donor paths |
| Set difference | `%TEMP%\opencode\fold03_classify.py` (relative actor path as key) | 3,936 missing; classified by family with a one-line reason each |

**Evidence convention for the tables below.** `donor: <path>` = OBSERVED on-disk
file, with bytes and header vertex count; `donor text: <path>:<line>` = a literal
donor text line read this pass; `port: <path>:<line>` = a literal repo line.
Every "should convert" judgement is **INFERRED**, and every "will look like"
statement is **UNVERIFIED**.

---

## 2. Donor mesh inventory by family (OBSERVED)

### 2.1 Top-level family counts

| Family | Files | `.osm` | `.oss` | Sub-folders / content |
|---|---:|---:|---:|---|
| `actors/buildings` | 3,464 | 3,423 | 41 | 25 folders: 21 nations + `commoneur`, `commonrus`, `commontur`, `mis` |
| `actors/units` | 378 | 137 | 241 | 191 root files + 187 `attach/` (horses, sails, flags, paddles, wheels, stages) |
| `actors/env` | 273 | 273 | 0 | trees, rocks/stones, flora, boats/carts/barrels, mines, relief props |
| `actors/pfx` | 97 | 45 | 52 | `debris` 39, `explosion` 16, `fire` 12, `impact` 9, `shot` 9, `projectile` 6, `trail` 6 |
| `actors/misc` | 20 | 19 | 1 | balloon/balloona, UI/editor markers, `rallypoint`, `movearrow`, `sphere` |
| **TOTAL** | **4,232** | **3,897** | **335** | `.mesh` files: **0** |

### 2.2 Building folder census (OBSERVED, one row per folder)

| Folder | n | Folder | n | Folder | n |
|---|---:|---|---:|---|---:|
| `aus` | 143 | `fra` | 141 | `pru` | 144 |
| `bav` | 152 | `hun` | 152 | `rus` | 142 |
| `sax` | 152 | `sco` | 152 | `spa` | 170 |
| `swi` | 152 | `tur` | 126 | `swe` | 142 |
| `ukr` | 142 | `ven` | 142 | `por` | 167 |
| `net` | 153 | `pie` | 153 | `den` | 152 |
| `eng` | 142 | `pol` | 143 | `alg` | 28 |
| `commoneur` | 173 | `commonrus` | 195 | `commontur` | 70 |
| `mis` | 36 | | | | |

Nation folders carry the base family mesh, four build stages, two death stages
and their `attach/` children; `commonrus` carries the wall/gate/tower/turn/variant
set for four wall families; `mis` carries four bridges plus four colliders.

### 2.3 Actor-reference cross-check (OBSERVED)

`donor text: actors/actors.lib:1200-1213` lists the 4 mountain + 4 plateau actors;
`:2639-2652` lists `misbridge1..4`; `:1150-1155` lists `balloon`/`balloona`;
`:1458-1494` lists `boat1..5` and `shipwreck1..3`. A direct read of
`donor: actors/env/terrainmesh1.actor:1-5` shows the canonical shape:

```
section.begin {refurl=.\data\actors\ref\refmountain.actor}
   ActorList.Items[0].Name = terrainmesh1.mesh
   ActorList.Items[0].LODList.Items[0].MeshObjects.LoadFromFile = .\data\actors\env\terrainmesh1.osm
section.end
```

**DERIVED:** because all 4,278 references resolve and no `.mesh` file or
`.mesh` reference exists, the `.osm`/`.oss` census of §2.1 is exhaustive for
renderable geometry. Non-mesh look families (weather, UI sprites, PFX emitters)
are documented in §7.

---

## 3. Port inventory (OBSERVED)

| Store | Count | Evidence |
|---|---:|---|
| `manifest.json` entries | **299** (building 129, unit 73, env 93, relief 4) | `variant3d/assets/models/manifest.json` (game header `C:\Games\Cossacks 3`); C01-ASSET §0/§3 |
| Unique donor mesh paths named by manifest | **296** | set of `manifest[].mesh` normalized to `actors/…`; duplicates: `peaukr.oss` (`peaukr`,`peasant`), `swordsmansco.oss` (`sco_highlandersword`,`swordsmansco`), `stones1.osm` (`stone`,`rock_stones1`) |
| On-disk `.obj` / `.mtl` | 299 / 299 | `variant3d/assets/models/obj/` |
| On-disk `.png` | 193 | `variant3d/assets/models/tex/` |
| `.glb` / `.gltf` | **0** repo-wide | recursive grep |
| `skin/index.json` | `count=66`, `entries=66`, `skipped=7`, `failed=0` | 55 base + 8 peasants + 3 signature skins (C01-ASSET §0) |
| Converted donor paths by folder | env 99, units 71, `buildings/ukr` 40 + `ukr/attach` 40, `commoneur` 21 + `commoneur/attach` 20, `commonrus` 1, `bav`/`pol`/`swe`/`rus` 1 each | same normalized set |

**C01-ASSET landing state (OBSERVED).** `convert_models.py:512-611` now holds four
opt-in additive tables (`nation_building_models` = 4 T0 halls,
`nation_peasant_models` = 8 peasants, `nation_signature_models` = 3 units,
`relief_models` = `terrainmesh1..4`); `main()` flags `--nation-art`
(`:624-627`, routed `:650-656`), `--include-relief` (`:628-630`, `:657-660`),
`--manifest-name` (`:631-634`, `:696-698`). Default invocation still emits the
280 base entries. `C01_asset_impl.md:17-35,301-332` records the 19 sids and 68
derived files. No donor binary was copied (`C01_asset_impl.md:357-361,453-462`).

---

## 4. Converted-vs-donor set difference (DERIVED)

| Family | Donor | Converted (unique paths) | Missing | Share missing |
|---|---:|---:|---:|---:|
| buildings | 3,464 | 126 | **3,338** | 96.4% |
| units | 378 | 71 | **307** | 81.2% |
| env | 273 | 99 | **174** | 63.7% |
| pfx | 97 | 0 | **97** | 100% |
| misc | 20 | 0 | **20** | 100% |
| **TOTAL** | **4,232** | **296** | **3,936** | 93.0% |

**DERIVED root cause (OBSERVED code).** `convert_models.py:165-243` names one
peasant base and 61 other unit bases; `:246-297` names 8 `ukr*`, 6 `eur*` and 3
env mines; `:300-381` names 108 `ukr*`/`eur*` stages; `:384-409` names 7 hulls;
`:412-496` names 93 env props. Readers `:48-107` already parse every donor mesh.
The blocker is enumeration, exactly as N07 §0/§2 and Z03 B1 concluded.

---

## 5. MISSING register — exact donor paths, sizes, header vertex counts, one-line reason

> Every row below is **OBSERVED** for path/bytes/verts (donor file read this pass).
> The reason column is **DERIVED** from code/config, **INFERRED** for parity
> priority. The visual consequence of any missing row is **UNVERIFIED**.

### 5.1 Relief / hills (highest owner-visible priority)

| Status | Donor path | Bytes | Verts | Reason (one line) | Label |
|---|---|---:|---:|---|---|
| **CONVERTED** | `data/actors/env/terrainmesh1.osm` (`actors.lib:1200-1201`) | 191,356 | 2,662 | C01-ASSET `terrainmesh1` sid; OBJ exists, but no instancing consumer — hills still not placed (C01 §6.3) | OBSERVED / placement UNVERIFIED |
| **CONVERTED** | `data/actors/env/terrainmesh2.osm` (`:1204-1205`) | 163,452 | 2,272 | same | OBSERVED / placement UNVERIFIED |
| **CONVERTED** | `data/actors/env/terrainmesh3.osm` (`:1208-1209`) | 156,092 | 2,177 | same | OBSERVED / placement UNVERIFIED |
| **CONVERTED** | `data/actors/env/terrainmesh4.osm` (`:1212-1213`) | 201,604 | 2,509 | same | OBSERVED / placement UNVERIFIED |
| **MISSING** | `data/actors/env/terrainplateau1.osm` (`actors.lib:1216-1217`) | 25,540 | 472 | no `.prop`, no albedo (`materials/env/terrainplateau*.dds` absent), zero `pattern.lib` `BaseName` refs → not placeable by the same rule (Z03 B5, C01 §3) | OBSERVED / placement UNVERIFIED |
| **MISSING** | `data/actors/env/terrainplateau2.osm` (`:1220-1221`) | 15,788 | 231 | same | OBSERVED |
| **MISSING** | `data/actors/env/terrainplateau3.osm` (`:1224-1225`) | 45,340 | 645 | same | OBSERVED |
| **MISSING** | `data/actors/env/terrainplateau4.osm` (`:1228-1229`) | 46,444 | 655 | same | OBSERVED |
| **NO OWN MESH** | `data/materials/env/terrainmeshdesert1..4.dds` + `data/objects/env/terrainmeshdesert1.prop:9-19` | 5,592,560 each | n/a | material variants: `LODActorName = terrainmesh1`, `DefaultMeshName = terrainmesh1.mesh`; **no `terrainmeshdesert*.osm` exists** → not a missed mesh | OBSERVED |
| **NO OWN MESH** | `data/materials/env/terrainmesh1w.dds` etc. | — | n/a | winter albedo variant of the same `.osm` (`terrainmesh1.prop:17-18`); no second mesh | OBSERVED |

### 5.2 Ships / naval

| Donor path | Bytes | Verts | Reason (one line) | Label |
|---|---:|---:|---|---|
| `data/actors/units/chaika.osm` | 167,612 | 2,619 | Ukrainian hull; 7 other hulls converted, `chaika` has no manifest entry/OBJ (N07 §4.3) — **should convert for naval parity** | OBSERVED / visual UNVERIFIED |
| `data/actors/units/chaika_death1.osm` / `chaika_death2.osm` | 195,820 / 163,668 | 3,167 / 2,663 | hull death stages — naval deferred (dead-ship state not implemented) | OBSERVED |
| `data/actors/units/attach/chaika_sail.osm` | 1,939,580 | 427 | sail rigging attach — naval deferred (no sail renderer) | OBSERVED |
| `data/actors/units/attach/chaika_flag1.oss`, `chaika_flag2.oss`, `chaika_paddle_l.oss`, `chaika_paddle_r.oss` | 57,580 / 56,988 / 84,532 / 84,532 | 44 / 32 / 160 / 160 | flags/paddles — naval deferred | OBSERVED |
| `data/actors/units/{fishboat,frigate,galley,yacht,yachttur}.oss` | 217,344 each | 584 each | generic crew figure (identical byte size), **not** the hull; `.osm` hull already converted → not needed for static-hull parity | OBSERVED / role INFERRED |
| `data/actors/units/attach/{battleship,frigate,galley,xebec,fishboat}_sail.osm` | 2,887,804–9,910,372 | 427–3,388 (e.g. `frigate_sail.osm` 9,910,372 B / 3,388 v; `battleship_sail.osm` 3,381,948 B / 1,150 v) | sail rigging — naval deferred | OBSERVED |
| `data/actors/units/attach/*_{flag1..4, paddle_l/r}.oss` (19 files) | 19,144–130,132 | 24–? (e.g. `frigate_flag1.oss` 19,144 B / 24 v) | ship flags/paddles — naval deferred | OBSERVED |
| `data/actors/units/*_death1.osm`, `*_death2.osm` and `<hull>1..4.osm` for the 7 converted hulls (≈40 files) | 15,372–935,692 | 8–21,061 | hull damage stages / superstructure pieces — naval deferred; 660-byte / 8-vert entries are empty placeholders | OBSERVED |

### 5.3 Nation halls — 16 missing of 21 (`ukr` + 4 T0 converted)

| Donor path | Bytes | Verts | Reason (one line) | Label |
|---|---:|---:|---|---|
| `data/actors/buildings/alg/algcen.osm` | 224,412 | 4,901 | T1 hall, reduced Algerian roster (`cen/hou` only) — parity tranche T1 | OBSERVED |
| `data/actors/buildings/aus/auscen.osm` | 538,500 | 13,104 | T1 hall — parity tranche T1 | OBSERVED |
| `data/actors/buildings/den/dencen.osm` | 1,147,412 | 26,550 | T1 hall — parity tranche T1 | OBSERVED |
| `data/actors/buildings/eng/engcen.osm` | 1,386,780 | 33,026 | T1 hall — parity tranche T1 | OBSERVED |
| `data/actors/buildings/fra/fracen.osm` | 548,244 | 12,826 | T1 hall — parity tranche T1 | OBSERVED |
| `data/actors/buildings/hun/huncen.osm` | 684,500 | 17,113 | T1 hall — parity tranche T1 | OBSERVED |
| `data/actors/buildings/net/netcen.osm` | 759,796 | 18,507 | T1 hall — parity tranche T1 | OBSERVED |
| `data/actors/buildings/pie/piecen.osm` | 1,700,028 | 40,095 | T1 hall — parity tranche T1 | OBSERVED |
| `data/actors/buildings/por/porcen.osm` | 2,403,756 | 50,556 | T1 hall — parity tranche T1 | OBSERVED |
| `data/actors/buildings/pru/prucen.osm` | 685,748 | 16,006 | T1 hall — parity tranche T1 | OBSERVED |
| `data/actors/buildings/sax/saxcen.osm` | 287,972 | 5,540 | T1 hall — parity tranche T1 | OBSERVED |
| `data/actors/buildings/sco/scocen.osm` | 270,708 | 6,823 | T1 hall — parity tranche T1 | OBSERVED |
| `data/actors/buildings/spa/spacen.osm` | 886,588 | 22,161 | T1 hall — parity tranche T1 | OBSERVED |
| `data/actors/buildings/swi/swicen.osm` | 418,820 | 10,193 | T1 hall — parity tranche T1 | OBSERVED |
| `data/actors/buildings/tur/turcen.osm` | 338,660 | 6,932 | T1 hall — parity tranche T1 | OBSERVED |
| `data/actors/buildings/ven/vencen.osm` | 1,356,308 | 32,800 | T1 hall — parity tranche T1 | OBSERVED |

Converted for contrast (OBSERVED): `ukrcen.osm` 227,428 B / 5,611 v (as generic
`sid=cen`), `ruscen` 609,492 B / 15,348 v, `bavcen` 491,740 B / 11,738 v,
`polcen` 645,884 B / 14,933 v, `swecen` 663,572 B / 15,862 v (C01 §3).
Albedo exists for all 21 (`data/materials/buildings/<nat>/<nat>cen.dds`), so
these are enumeration gaps, not missing art.

### 5.4 Nation units — 35 soldier variants + 2 placeholders + 31 mounts + 8 mission units

**5.4.1 Nation-specific soldier/officer `.oss` (35; all have matching `.dds`+`.aaf`, so conversion is table-only).** Each row OBSERVED; reason = "T1/T2 nation unit variant — not in any `convert_models()` table (N07 §5.2)"; visual outcome UNVERIFIED.

| Donor path (`data/actors/units/`) | Bytes | Verts | Donor path | Bytes | Verts |
|---|---:|---:|---|---:|---:|
| `archertur.oss` | 145,664 | 690 | `musketeer18den.oss` | 467,392 | 679 |
| `dragoon18fra.oss` | 474,896 | 785 | `musketeer18pru.oss` | 399,704 | 684 |
| `dragoon18net.oss` | 333,200 | 687 | `musketeer18sax.oss` | 402,440 | 720 |
| `dragoon18pie.oss` | 347,144 | 837 | `musketeeraus.oss` | 246,200 | 731 |
| `dragoonpol.oss` | 334,208 | 683 | `musketeernet.oss` | 477,344 | 795 |
| `drummerrus.oss` | 119,880 | 570 | `musketeerpol.oss` | 474,872 | 816 |
| `drummertur.oss` | 135,760 | 763 | `musketeerspa.oss` | 283,304 | 940 |
| `grenadierbav.oss` | 448,656 | 604 | `officerrus.oss` | 192,808 | 755 |
| `grenadierden.oss` | 449,748 | 701 | `officertur.oss` | 204,296 | 765 |
| `grenadierhun.oss` | 451,544 | 709 | `pandurhun.oss` | 431,104 | 594 |
| `grenadierpru.oss` | 440,776 | 573 | `pikemanpol.oss` | 261,728 | 757 |
| `grenadiersax.oss` | 445,304 | 633 | `pikemanpor.oss` | 234,968 | 575 |
| `guardcavalrysax.oss` | 355,460 | 608 | `pikemanspa.oss` | 216,928 | 603 |
| `hussarhun.oss` | 380,012 | 808 | `pikemanswi.oss` | 248,828 | 704 |
| `hussarpru.oss` | 403,780 | 684 | `pikemantur.oss` | 238,392 | 631 |
| `hussarswi.oss` | 311,668 | 766 | `reiterpol.oss` | 469,164 | 668 |
| `jagerpor.oss` | 374,720 | 558 | `reiterswe.oss` | 360,332 | 719 |
| `jagerswi.oss` | 399,880 | 864 | | | |

(plus `units/ferry_collider.osm` 724 B / 12 v and `units/unitbox.osm` 660 B /
8 v — non-character collision placeholders, deliberately deferred.)

**5.4.2 Mount meshes — 31 `_horse.oss`, all missing.** OBSERVED: **0 manifest
entries and 0 OBJs** contain "horse"; `convert_models.py:165-243` converts only
the rider `.oss`. Reason (one line, all rows): "cavalry mount attach — no horse
geometry is converted, so riders are mountless; SHOULD convert for visual parity
(attach transform is donor `.actor` data, UNVERIFIED)".

| Donor path (`data/actors/units/attach/`) | Bytes | Verts | Donor path | Bytes | Verts |
|---|---:|---:|---|---:|---:|
| `cossackdon_horse.oss` | 494,344 | 599 | `lightcavalry_horse.oss` | 484,992 | 807 |
| `cossackregister_horse.oss` | 494,344 | 599 | `mameluke_horse.oss` | 494,328 | 599 |
| `cossacksich_horse.oss` | 449,976 | 599 | `raidersco_horse.oss` | 483,576 | 599 |
| `croat_horse.oss` | 483,576 | 599 | `reiter_horse.oss` | 483,592 | 599 |
| `cuirassier_horse.oss` | 495,744 | 807 | `reiterpol_horse.oss` | 483,576 | 599 |
| `dragoon_horse.oss` | 530,824 | 599 | `reiterswe_horse.oss` | 492,216 | 674 |
| `dragoon18_horse.oss` | 484,992 | 807 | `sipahi_horse.oss` | 482,248 | 599 |
| `dragoon18fra_horse.oss` | 550,792 | 599 | `spakh_horse.oss` | 494,336 | 599 |
| `dragoon18net_horse.oss` | 484,992 | 807 | `tatar_horse.oss` | 494,344 | 599 |
| `dragoon18pie_horse.oss` | 484,992 | 807 | `vityaz_horse.oss` | 482,248 | 599 |
| `dragoonpol_horse.oss` | 484,992 | 807 | `wingedhussar_horse.oss` | 503,480 | 781 |
| `guardcavalrysax_horse.oss` | 492,216 | 674 | `hackapell_horse.oss` | 483,576 | 599 |
| `hetman_horse.oss` | 497,000 | 807 | `hussar_horse.oss` | 463,488 | 807 |
| `hussarhun_horse.oss` | 463,488 | 807 | `hussarpru_horse.oss` | 461,864 | 788 |
| `hussarswi_horse.oss` | 461,864 | 788 | `kingmusketeer_horse.oss` | 550,776 | 599 |
| `lancersco_horse.oss` | 494,344 | 599 | | | |

**5.4.3 Mission/special units (8).** `ferry.osm` 305,620 B / 6,912 v (mission
ferry hull — deferred); `ferry.oss`, `gauduk.oss` 476,880 B / 775 v,
`kingmusketeer.oss` 474,688 B / 757 v, `misdonkey.oss` 124,108 B / 639 v,
`misflagman.oss` 242,928 B / 660 v, `misgeneral.oss` 243,840 B / 648 v,
`mistrader.oss` 189,916 B / 552 v — reason: "mission-only actor, no port sid —
deliberately deferred".

**5.4.4 Animal/deer/bird check (OBSERVED negative).** A whole-tree filename scan
and a text scan of `*.txt/*.script/*.inc/*.cfg/*.lib/*.pfx/*.tree` found **zero**
deer/animal/bird mesh files and **zero** such PFX effect names (`@internet.random.animal.*`
locale keys are UI flavour text, not meshes). Reason: "no such donor asset exists —
nothing to convert". `gauduk` and `misdonkey` are unit actors, not wildlife.

### 5.5 Buildings — 3,338 missing (walls, towers, bridges, nation families, stages)

**5.5.1 Common-family wall/tower/gate variants (396 = `commoneur` 132 +
`commonrus` 194 + `commontur` 70).** Reason (one line): "non-`eur` common-family
variant — parity tranche T2; `convert_models.py:246-297` converts only `eur*`
and `eurswa_gate`". Representative exact rows (all OBSERVED):

| Donor path | Bytes | Verts | Note |
|---|---:|---:|---|
| `data/actors/buildings/commonrus/russwa_tower.osm` | 54,724 | 1,410 | tower piece, Russian wall family |
| `data/actors/buildings/commonrus/turswa_tower.osm` | 17,876 | 416 | tower piece, Turkish |
| `data/actors/buildings/commonrus/ukrwwa_tower.osm` | 29,876 | 749 | tower piece, Ukrainian wood/earth wall |
| `data/actors/buildings/commonrus/eurswa_tower.osm` | 16,292 | 280 | tower piece, European |
| `data/actors/buildings/commonrus/russwa_gate.osm` | 200,628 | 4,704 | gate, Russian (only `eurswa_gate` converted) |
| `data/actors/buildings/commonrus/turswa_gate.osm` | 66,756 | 1,518 | gate, Turkish |
| `data/actors/buildings/commonrus/ukrwwa_gate.osm` | 92,724 | 2,354 | gate, Ukrainian |
| `data/actors/buildings/commonrus/eurswa_45gate.osm` | 180,548 | 4,530 | 45° gate corner |
| `data/actors/buildings/commonrus/*swa_{v1,v2,45v1,45v2,turn,turnmirror}{1,2}.osm` | 8,740–34,524 | 156–899 | wall segment / corner variants (~60 files) |
| `data/actors/buildings/commoneur/eurwwa.osm` | 193,916 | 4,800 | wood/earth wall base — not converted (`eurswa.osm` is) |
| `data/actors/buildings/commoneur/attach/*swa*a.osm`, `*_death[12]a.osm` | 660 | 8 | empty scaffold/death attach placeholders — deferred |

**5.5.2 Mission bridges (4 + 4 colliders).** `donor text: actors.lib:2639-2652`;
`donor text: objects/buildings/misbridge1.prop:14,20,24,28,32,36` binds shared
albedo `materials/buildings/mis/misbridge.dds` (so "no albedo" is NOT the reason).

| Donor path | Bytes | Verts | Reason (one line) | Label |
|---|---:|---:|---|---|
| `data/actors/buildings/mis/misbridge1.osm` | 54,372 | 1,331 | mission bridge — no port sid / no placement consumer; deferred | OBSERVED |
| `data/actors/buildings/mis/misbridge2.osm` | 63,812 | 1,550 | same | OBSERVED |
| `data/actors/buildings/mis/misbridge3.osm` | 63,764 | 1,550 | same | OBSERVED |
| `data/actors/buildings/mis/misbridge4.osm` | 54,372 | 1,331 | same | OBSERVED |
| `data/actors/buildings/mis/misbridge{1..4}_collider.osm` | 980–1,780 | 16–26 | navigation collider, not a renderable mesh — deferred | OBSERVED |

**5.5.3 Nation own-family buildings + stages + deaths (2,906).** Exact path
template: `data/actors/buildings/<nat>/<nat><fam>{,1..4,_death1,_death2}.osm`
and `data/actors/buildings/<nat>/attach/<nat><fam>{a,1a..4a,_death1a,_death2a}.osm`,
`<nat>` ∈ 21 nations, `<fam>` ∈ `aca, art, ba2, bar, bla, cen, dip, hou, sta, tem,
por, wwa, …`. Breakdown by suffix class (OBSERVED): **base 486** (core
`<nat><fam>.osm` 188 of 200 missing — 12 converted), **stage 2,012**,
**death 408**. Reason (one line): "nation own-family/stage/death art — parity
tranche T2; only `ukr*`/`eur*` base and 108 stages are enumerated
(`convert_models.py:246-297,300-381`)". Per-nation missing counts:
`spa` 170, `por` 167, `net`/`pie` 153, `sco`/`hun`/`den`/`swi`/`sax` 152,
`bav` 151, `pru` 144, `aus` 143, `pol`/`ven`/`eng` 142, `swe`/`rus`/`fra` 141,
`tur` 126, `ukr` 62, `alg` 28.

Representative exact rows (all OBSERVED; same reason as above):

| Donor path | Bytes | Verts | Faces |
|---|---:|---:|---:|
| `data/actors/buildings/rus/rusaca.osm` | 746,940 | 18,423 | 12,409 |
| `data/actors/buildings/rus/rusbar.osm` | 232,964 | 6,114 | 3,467 |
| `data/actors/buildings/bav/bavba2.osm` | 770,548 | 19,606 | — |
| `data/actors/buildings/ukr/ukrpor.osm` | 525,300 | 12,930 | 8,876 |
| `data/actors/buildings/hun/huntem.osm` | 981,700 | 22,949 | 17,274 |
| `data/actors/buildings/ukr/attach/ukraca_death1a.osm` | 103,428 | 1,996 | 1,201 |

(These rows are illustrative; the full per-file byte/vertex table is deterministic
from the decoded `fold03_donor_mesh_full.csv` probe and the path template above.
`turba2.osm`, `ukrba2.osm` and `algba2.osm` do **not** exist in the donor — N07 §3.3 —
so they are not inadvertently listed as missed files.)
`bar18` and `dock` have no donor actor with that exact name — N07 §3.1 / `convert_models.py:276-280` — so they are **not** "missed donor files".)

### 5.6 Environment props — 174 missing of 273

| Name prefix family (donor `data/actors/env/`) | Missing n | Reason (one line) | Example exact row (OBSERVED) |
|---|---:|---|---|
| `terrainplateau1..4.osm` | 4 | no albedo/.prop/pattern link — not placeable (§5.1) | `terrainplateau2.osm` 15,788 B / 231 v |
| trees: `decortree*`, `burch*`, `drytree*`, `palm*`, `leaftree*`, `oak2..4`, `pine2..4`, `fir2..4`, `desert*` etc. | 83 | tree variant — decorative, deferred; only 4 fir/oak/pine + spruce/pinedry/pinesmall/firsmall/stump variants converted | `data/actors/env/christmastreea.osm` 843,572 B / 11,459 v; `desert2.1.osm` 635,268 B / 10,402 v |
| ground flora: `grass*`, `ivy*`, `lily*`, `plant*`, `horseradish*`, `burdock*`, `chamomile*`, `pitchers*` | 43 | ground-flora variant — deferred; only `bush1..4`/`flower1..3`/`plantain1..3`/`reed1..3`/`fern1..4` converted | `data/actors/env/grassforest1.osm` 178,116 B / 2,535 v |
| props: `boat1..5`, `cart1..5`, `smallcart1..4`, `barrel1..5`, `bags1..4`, `shipwreck1..3`, `pump1..3`, `stall1..2`, `trolley1..2`, `fence1..2`, `ladder1..2`, `hay`, `coal`, `field2..3` | 40 | decorative prop — deferred; `field1` converted only | `data/actors/env/shipwreck2.osm` 90,940 B / 2,247 v; `boat4.osm` 36,692 B / 740 v |
| rocks: `rocks2..4`, `desertstump1..4` (part), `landstone*` variants | 3 (+ stumps counted under trees) | rock/stone variant — deferred; `rocks1`, `stones1..10`, `smallstones1..6`, `landstone1..4`, `rocksea1..6`, `stonessea1..10` converted | `data/actors/env/rocks3.osm` 17,404 B / 265 v |
| other | 1 | `data/actors/env/coal.osm` — decorative, no own albedo; deferred | `coal.osm` 18,484 B / 356 v |

**OBSERVED note.** `data/objects/env/terrainmeshdesert1.prop:9-19` and
`data/materials/env/terrainmeshdesert1..4.dds` are albedo variants, not missed
meshes (see §5.1). `coal.osm` (18,484 B / 356 v) has no matching albedo of its own
but is an env decoration; reason "no own albedo / decorative — deferred".

### 5.7 PFX — 97 missing of 97

| Subfolder | n | Reason (one line) | Example exact row (OBSERVED) |
|---|---:|---|---|
| `data/actors/pfx/debris/` | 39 | debris particle mesh — FX, not a static scene mesh; deferred | `debris_stone_1.osm` 5,204 B; `debris_wood_1.osm` 1,828 B |
| `data/actors/pfx/explosion/` | 16 | explosion emitter (mostly 3,148 B empty `.oss`) — FX deferred | `explbuilding1.oss` 453,800 B; `explcannon1.oss` 3,148 B |
| `data/actors/pfx/fire/` | 12 | fire/smoke emitter — FX deferred (port has its own smoke/GPU FX) | `buildfire1.oss` 3,148 B |
| `data/actors/pfx/impact/` | 9 | dust/water impact emitter — FX deferred | `impdust1.oss` 3,148 B |
| `data/actors/pfx/shot/` | 9 | muzzle-flash emitter — FX deferred | `shotmusket1.oss` 3,148 B |
| `data/actors/pfx/projectile/` | 6 | projectile mesh — FX deferred | `projcannonball.osm` 3,252 B |
| `data/actors/pfx/trail/` | 6 | trail emitter — FX deferred | `trailcannonball1.oss` 3,148 B |

**DERIVED:** the repeated 3,148-byte `.oss` files are header-only particle
systems (24-byte header + minimal blocks), i.e. *not* renderable character or
prop meshes. `donor: pfx/fx.tree` (18,414 B) and `donor: pfx/source.pfx`
(80,545 B) define them as effects. No animal/bird PFX exists (§5.4.4).

### 5.8 Misc — 20 missing of 20

| Donor path | Bytes | Verts | Reason (one line) | Label |
|---|---:|---:|---|---|
| `data/actors/misc/balloon.osm` | 3,368,620 | 691 | hot-air balloon decorative actor (`actors.lib:1150-1151`) — no port sid; deferred | OBSERVED |
| `data/actors/misc/balloona.osm` | 2,005,108 | 412 | same | OBSERVED |
| `data/actors/misc/movearrow.oss` | 47,992 | 828 | editor/HUD move arrow — not a scene mesh | OBSERVED |
| `data/actors/misc/misarrowdown.osm` | 916 | 24 | UI marker — not a scene mesh | OBSERVED |
| `data/actors/misc/misattention.osm` | 5,028 | 108 | UI marker | OBSERVED |
| `data/actors/misc/miscircle.osm` | 12,244 | 336 | UI marker | OBSERVED |
| `data/actors/misc/miscrown.osm` | 3,508 | 89 | UI marker | OBSERVED |
| `data/actors/misc/miscrown2.osm` | 3,508 | 89 | UI marker | OBSERVED |
| `data/actors/misc/misflag.osm` | 149,340 | 2,391 | UI marker | OBSERVED |
| `data/actors/misc/misround.osm` | 8,660 | 112 | UI marker | OBSERVED |
| `data/actors/misc/misshield.osm` | 8,020 | 152 | UI marker | OBSERVED |
| `data/actors/misc/misshield2.osm` | 8,020 | 152 | UI marker | OBSERVED |
| `data/actors/misc/ptborder.osm` | 1,508 | 28 | editor border marker | OBSERVED |
| `data/actors/misc/ptborderwater.osm` | 5,540 | 110 | editor border marker | OBSERVED |
| `data/actors/misc/rallypoint.osm` | 1,956 | 40 | placement marker only (`EVIDENCE_INDEX.md` rally scale/roll) | OBSERVED |
| `data/actors/misc/sphere.osm` | 35,372 | 482 | editor/test primitive | OBSERVED |
| `data/actors/misc/testroof.osm` | 1,348 | 26 | test primitive | OBSERVED |
| `data/actors/misc/bui.osm` | 66,292 | 1,498 | editor primitive | OBSERVED |
| `data/actors/misc/box.osm` | 660 | 8 | 8-vert placeholder | OBSERVED |
| `data/actors/misc/box_calign.osm` | 1,012 | 24 | placeholder | OBSERVED |

---

## 6. What SHOULD be converted for visual/feature parity (INFERRED priority)

| Rank | Gap | Exact donor count | Why it matters (INFERRED, visual UNVERIFIED) | Blocker (OBSERVED) |
|---:|---|---:|---|---|
| **P0** | Relief **instancing** | 4 assets already converted; 4 plateau props missing | Owner wants visible hills; assets exist but no consumer places them; `C01_asset_impl.md:429-441` lists the required raw-unit/Scaling/Position path | no runtime consumer; `world3d_terrain.gd:1515` `stats.not_done`; ownership contested by M03/P11 |
| **P1** | Cavalry **mount meshes** | **31** `_horse.oss` | 0 horse OBJs today — every cavalry unit is a rider with no donor mount; largest single visual-identity miss for units | `convert_models.py:165-243` enumerates rider only; attach transform donor-side |
| **P1** | Ukrainian **ship hull `chaika`** | 1 hull (+ rigging) | only hull of the 8-port roster without a converted mesh | `convert_models.py:384-409` 7-entry table |
| **P1** | Remaining **16 nation halls** | 16 | owner asked for correct nation hall association; 5 of 21 converted | additive table `:512-537` has only 4 T0 sids |
| **P2** | Nation **signature/soldier units** | 35 variants + 3 T0 already done | distinct uniforms for Russia/Bavaria/Sweden/etc.; current port uses generic forms | `:562-579` 3-entry signature table (T0 only) |
| **P2** | Common-family **walls/towers/gates/45° pieces** | 396 | wall/tower silhouette differs per nation; current port always `eur*` | `:246-297` hard-coded `eur*`; wall/gate variants need albedo folder mapping |
| **P2** | Mission **bridges** | 4 (+4 colliders) | a bridge on a mission map has no 3D geometry; shared albedo exists | no port sid, no placement consumer |
| **P3** | Env **variety** (trees/flora/props) | 126 (83+43+40 incl. overlaps) | donor landscapes vary by biome; port uses one tree/rock/flora per kind | `:412-496` enumerates a subset |
| **P3** | Naval rigging (sails/flags/paddles/death stages) | ≈90 | dead/sailing ship states; large meshes (up to 9.9 MB) | naval renderer absent — deferred, not a parser limit |

**Cross-check against owner's worry.** No `obj` family was silently skipped by
an I/O failure: all 296 manifest meshes parse, and the converter's readers
handled 335/335 `.oss` and all `.osm` in N07 §2 / Z03 §1. The misses are
**enumeration + no consumer**, not corrupt files. The one true "no art" case is
`terrainplateau1..4` (§5.1) and the 660-byte empty placeholders.

---

## 7. Deliberately out of scope (with exact reason)

| Item | Count | Reason | Evidence / label |
|---|---:|---|---|
| PFX meshes (debris/explosion/fire/impact/shot/projectile/trail) | 97 | particle emitters, mostly 3,148-B empty `.oss`; not static scene meshes; FX is a separate renderer concern | `data/pfx/fx.tree`, `source.pfx`; OBSERVED |
| Misc UI/editor markers + test primitives | 18 | `misarrowdown`, `miscircle`, `miscrown`, `misflag`, `misshield`, `ptborder`, `rallypoint`, `sphere`, `box`, `testroof`, `bui` etc. — editor/HUD/collision, not world art | `actors/misc/` listing; OBSERVED |
| Weather | 0 meshes | `data/env/clouds/clouds.weather` (510 B) + 12 DDS billboards (`soft*/dark*/storm*/volume*`); no mesh to convert | `clouds.weather:1-19`; OBSERVED |
| Deer / animals / birds | 0 | no donor mesh and no PFX name; locale `animal` keys are flavour text | whole-tree scan; OBSERVED negative |
| `terrainmeshdesert1..4`, `terrainmesh1w..4w` | 0 own meshes | material variants of already-converted `terrainmesh1..4.osm` | `objects/env/terrainmeshdesert1.prop:9-19`; OBSERVED |
| `terrainplateau1..4` | 4 | no albedo, no `.prop`, zero `pattern.lib` `BaseName` refs → not placeable by the same rule | Z03 B5, C01 §3; OBSERVED / selection UNVERIFIED |
| 660-byte / 8-vert stage & attach placeholders | ~200+ | empty donor placeholders, not geometry | header decode; OBSERVED |
| 2D `app/` sprite bakes | 2,930 PNG | separate 2D pipeline (`app/tools/bake_sprites.py`, `bake_naval.py`, `bake_scottish.py`); these are sprite sheets, not OBJs, and `app/**` is not owned/edited here | `app/assets/**` census; OBSERVED |
| Winter albedos of all families (`<nat><fam>w.dds`) | 0 meshes | albedo-only; converter emits one texture per sid; season binding engine-side | N07 §3.3; UNVERIFIED engine-side |

---

## 8. Claim register

| # | Claim | Evidence | Label |
|---:|---|---|---|
| 1 | 17,001 donor files; 4,232 meshes (3,897 `.osm`, 335 `.oss`, 0 `.mesh`) | recursive read-only census + header decode | OBSERVED |
| 2 | 976 `.actor` files, 4,278 mesh references, 0 dangling | `Select-String 'MeshObjects\.LoadFromFile\s*='` | OBSERVED |
| 3 | Port = 299 manifest entries / 299 OBJ / 0 GLB; 296 unique donor paths | `manifest.json` + disk census | OBSERVED |
| 4 | 3,936 donor meshes absent from manifest | set difference §4 | DERIVED |
| 5 | C01-ASSET added 19 sids (4 halls, 8 peasants, 3 units, 4 relief) and landed mid-this-pass | `convert_models.py:512-611`, `manifest.json` 15:58:15, `C01_asset_impl.md:17-35` | OBSERVED |
| 6 | 16 halls missing, 188 of 200 core own-family base buildings missing | §5.3 / §5.5.3 header tables | OBSERVED |
| 7 | 31 horse mounts missing; 0 horse OBJs/entries | §5.4.2 | OBSERVED |
| 8 | `chaika` hull missing; other 7 hulls converted | §5.2 / `convert_models.py:384-409` | OBSERVED |
| 9 | `terrainmesh1..4` converted but not instanced; `terrainplateau1..4` unplaceable | §5.1; C01 §6.3; Z03 B5 | OBSERVED / placement UNVERIFIED |
| 10 | No deer/animal/bird mesh, no weather mesh | §5.4.4 / §7 | OBSERVED negative |
| 11 | Any rendering, silhouette or visual difference from a missing asset | none — no Godot, no donor A/B | UNVERIFIED |
| 12 | Runtime season/material/attach resolution for any of the above | no plaintext consumer found | UNVERIFIED |

---

## 9. Attestation

- **Read-only:** only this report was written in the repo. No `.gd`, `.py`,
  `.json`, asset, config, test, queue or Git state was modified by FOLD-03.
  Probe scripts and CSVs live in `%TEMP%\opencode\` and are throwaway.
- **No runner, no Godot.** WAVE_G_CHARTER.md:31 (only G04 runs Godot) honoured.
- **No donor file copied, executed or unpacked.** All donor access was in-place
  byte/text reads under `C:\Games\Cossacks 3\data`.
- **No donor parity claim.** "Converted" means a derived OBJ/MTL/PNG exists with
  donor-byte provenance; it never means a rendered frame matches the donor.

*End of FOLD-03 report.*
