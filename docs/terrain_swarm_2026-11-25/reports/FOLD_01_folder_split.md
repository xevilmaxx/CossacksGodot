---
id: FOLD-01
ticket: "Asset organization — split models obj/ into nation/<kind> and shared/<kind>"
title: "FOLD-01 — current asset/code inventory, deterministic sid->folder rule, reversible migration design"
owner: FOLD-01 subagent
created: 2026-11-25
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_MOVES__NO_CODE_EDIT__NO_RUNNER__NO_GODOT
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, "PORT APPROX"]
priors_read: [WAVE_G_CHARTER.md, CHARTER.md, N07_all_nations_assets.md, N06_nation_conversion.md, CREDITS.md, README.md, M03_impl.md]
parity_guard: "No donor GPU A/B frame exists (CHARTER.md:57-58,122-130). Folder layout is an organization change, not a visual/donor-parity claim."
scope: "Only this report is written. No file moved/copied/deleted, no .py/.gd/.json/.import edited, no Godot launched, no runner job submitted."
---

# FOLD-01 — asset folder split design (read-only)

> [!IMPORTANT]
> **Labels.** **OBSERVED** = literal file:line or on-disk count read this pass.
> **DERIVED** = deterministic consequence of observed data/code. **INFERRED** =
> reasonable reading without an engine run. **UNVERIFIED** = needs a Godot
> import/gate run (owned by G04 only, WAVE_G_CHARTER.md:31).
> The ticket's "280 manifest entries" is the **pre-C01-ASSET** count; see §1.4.

## 0. Direct answer

1. **OBSERVED** Today every converted mesh lives flat in
   `variant3d/assets/models/obj/` (299 `.obj` + 299 `.mtl`) and every albedo
   flat in `.../tex/` (193 `.png`); skins are flat (66 JSON + `index.json`).
   There is **no `glb/` directory**, yet code probes it. The 2D-only trees
   (`anim/`, `sprites/`, `sprites_hi/`) are already nation/kind split and are
   `.gdignore`d — `anim/` is the exact precedent the owner's request mirrors.
2. **DERIVED** The loaders do **not** read the manifest's `obj`/`texture_png`
   fields at runtime: they **compose** `res://assets/models/obj/<sid>.obj`,
   `.../tex/<sid>.png`, `.../glb/<sid>.glb` and `.../skin/<file>`. A raw folder
   move would silently turn nation meshes into `donor_bbox_proxy` boxes and
   would break stage/ghost mesh lookups. The migration must therefore be
   **manifest-driven path mapping first, physical move second**.
3. **DERIVED** A deterministic rule needs an explicit sid allow-list, not a
   prefix regex: `sco_highlandersword`, `serdiuk`, `strelet`, `mameluke` are
   nation-specific without a nation prefix; `peaaus/peaeng/peaspa/peatur` are
   multi-nation shared art (N07 §4.1). Proposed rule in §4 yields **38
   nation-specific** and **261 shared** sids out of the current 299.
4. **INFERRED** Safe sequence: freeze against C01-ASSET → backup byte-for-byte
   → copy to target with `.import`/MTL rewrites → switch manifest/index + one
   GDScript resolver → G04-only import + gates → *move* originals to a
   dated backup (not delete) → keep backup for one gate cycle. §7 has the
   exact steps and refusal conditions.
5. **UNVERIFIED** Whether Godot's OBJ importer resolves a rewritten MTL
   `map_Kd` and whether the new C01-ASSET files are currently imported at all
   (19 `.obj` + 19 `.png` have **no** `.import` sidecar on disk). No run was
   performed.

---

## 1. Current structure (all OBSERVED this pass)

### 1.1 `variant3d/assets/models/`

| Entry | Files on disk | Notes |
|---|---|---|
| `manifest.json` | 1 (220,968 B) | Top-level keys: `game`, `models`. `game = C:\Games\Cossacks 3`. |
| `obj/` | 878 | **299 `.obj`**, **299 `.mtl`**, **280 `.obj.import`**; no other files. |
| `tex/` | 367 | **193 `.png`**, **174 `.png.import`**. Extra PNG vs manifest = `mill_rotor.png`. |
| `skin/` | 67 | **`index.json`** + **66 `.json`** skins. |
| `anim/` | dirs: `alg aus bav buildings common den eng fra hun land_units naval_units net pie pol por pru rus sax sco spa swe swi tur ukr ven` + `.gdignore` | Already `<nation|common>/<kind>` — the layout precedent. Not 3D-loaded. |
| `sprites/`, `sprites_hi/` | `.gdignore` present | 2D bake artifacts, out of scope. |
| `glb/` | **absent** | Code has `GLB_DIR` and `ResourceLoader.exists()` probes (§2). |

Counts are from `Get-ChildItem` this pass; `.import` counts are the shipped
sidecars, not the 3,038 files under `variant3d/.godot/imported/`.

### 1.2 Manifest shape (OBSERVED)

280-entry backup: `inbox/backup/manifest.json.bak-C01ASSET`. Current shipped
manifest: **299 entries**. Per-entry fields include `sid`, `kind`, `mesh`
(absolute donor path), `texture` (absolute donor DDS), `directions`, `obj`
(absolute OS path), `texture_png` (absolute OS path), `bbox`, `verts`, `faces`.

| `kind` | Count | Contents |
|---|---|---|
| `building` | 129 | 17 core (`cen hou bar sta bla aca art dip sto mil mar tow wal gat mine_gold mine_iron mine_coal`) + 108 stage/scaffold (`<sid>[1..4][a]`, `<sid>a`) + 4 new nation halls. |
| `unit` | 73 | 62 pre-C01 roster sids + 8 peasants (`pearus peaukr peapol peaaus peaeng peaspa peatur peasco`) + 3 signature units (`pikemanrus musketeer18bav pikeman18swe`). |
| `relief` | 4 | `terrainmesh1..4` (new C01-ASSET). |
| `env` | 93 | trees, rocks, bushes, reeds, ferns, gifts, `field`, `stone`, `rock`. |

`skin/index.json`: **66 entries**, 7 `skipped` ships (`yacht yachttur fishboat
frigate galley battleship xebec`), 0 failed; each entry's `file` is a bare
filename (e.g. `"pearus.json"`), no subfolder.

### 1.3 `.import` facts (OBSERVED, migration-critical)

`variant3d/assets/models/obj/peasant.obj.import` contains
`source_file="res://assets/models/obj/peasant.obj"`,
`path="res://.godot/imported/peasant.obj-92469198782e682190a771b0742a26c0.mesh"`,
`uid="uid://d085oe4buqj82"`, `dest_files=[...same hash...]`.
**Verified this pass:** that hash equals
`md5(utf-8("res://assets/models/obj/peasant.obj"))` =
`92469198782e682190a771b0742a26c0`. This is exactly the rewrite rule already
used by `tools/migrate_anim_layout.py:11-21` and
`tools/migrate_anim_nations.py:6-17`.

- 280 `.obj.import` for 299 `.obj` → **19 new C01-ASSET OBJs have no sidecar**.
- 174 `.png.import` for 193 `.png` → **19 new C01-ASSET PNGs have no sidecar**.
- MTL files use a Windows-relative texture reference:
  `obj/peasant.mtl` → `map_Kd ..\tex\peasant.png`;
  `obj/ruscen.mtl` → `map_Kd ..\tex\ruscen.png`. Depth changes break this.

### 1.4 C01-ASSET concurrency (OBSERVED — do not overwrite)

`git status --short` shows **86** changes including uncommitted C01-ASSET
outputs and backups (`inbox/backup/{manifest.json,index.json,convert_models.py,
convert_skins.py,CREDITS.md}.bak-C01ASSET`). Diffing manifest vs its backup:

```
ADDED (19): ruscen bavcen polcen swecen
            pearus peaukr peapol peaaus peaeng peaspa peatur peasco
            pikemanrus musketeer18bav pikeman18swe
            terrainmesh1..4
REMOVED: none
```

`CREDITS.md:100-134` documents the additive run
(`convert_models.py --nation-art --include-relief --manifest-name
manifest_addendum.json`, `convert_skins.py --index-name index_nation.json`,
then text-insert into the shipped manifest/index).

**Hazard (OBSERVED):** the 19 new manifest entries' `obj` and `texture_png`
point at the *staging directory*
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\c01as_stage\{obj,tex}\…`,
**not** at `variant3d/assets/models/`. `render_models.py:397-408` reads those
fields and will `SKIP` those 19 sids until they are normalized. This is a
pre-existing C01-ASSET issue; FOLD-01 must not silently "fix" it, but the
migration plan must record it and refuse to base path mapping on those fields.

---

## 2. Every path-constructing / path-reading code path (OBSERVED)

### 2.1 3D runtime readers

| File:line | What it does | Split impact |
|---|---|---|
| `scripts/world3d_entities.gd:84-87` | `OBJ_DIR`, `GLB_DIR`, `TEX_DIR`, `MANIFEST_PATH` constants. | Must gain resolver; constants kept as legacy fallback. |
| `:421-435` | Reads `manifest.json` **only** for `bbox` (`_bbox`) and donor `texture` (`_donor_texture_paths`). Does **not** read `obj`/`texture_png`. | Natural home for a new `assets`/`res` map. |
| `:438-445` | `ResourceLoader.exists(OBJ_DIR + sid + ".obj")` / GLB availability telemetry. | Must use resolver or counts drop. |
| `:449-450` | Tree pool requires OBJ **and** `TEX_DIR + sid + ".png"`. | Both sides must resolve. |
| `:456-460` | Stage/scaffold probes `OBJ_DIR + s + "1.obj"` / `"a.obj"`. | Stage sids inherit parent bucket. |
| `:471-473` | Stats report `obj_dir`, `glb_dir`, `tex_dir` strings. | Update labels only. |
| `:614`, `:1023-1024` | Albedo `TEX_DIR + sid + ".png"`. | Resolver for tex. |
| `:718-722` `_nation_mesh_on_disk()` | `ResourceLoader.exists(OBJ_DIR + sid + ".obj") or GLB_DIR…` — **this is the gate that makes nation art visible**. | **Critical**: with subfolders, every exact-nation probe fails and `NATION_MESH_FALLBACK_STATUS` is emitted falsely. |
| `:1172-1188` `_mesh_info()` | GLB then OBJ load. | Resolver for both. |
| `:1300-1304` `_load_obj_topology()` | `FileAccess.open(OBJ_DIR + sid + ".obj")` for per-vertex morph indexing. | Resolver; must not fall back to imported topology. |
| `:1812`, `:1861-1862` | `ROTOR_TEX_IMPORT_PATH` (`tex/mill_rotor.png`), `ROTOR_TEX_PATH` (`anim/common/buildings/mill_rotor.png`), `ROTOR_META_PATH` (`anim/buildings/mill_rotor.json`). | Leave `anim/` untouched; `mill_rotor.png` is the one non-manifest tex. |
| `:1902-1911` `_stage_mesh_info()` | `OBJ_DIR + sid + suffix + ("a.obj" if scaffold else ".obj")`, bbox from manifest `art_sid`. | Resolver must support suffixed sids. |

`_entity_mesh_sid()` (`:776-830`) uses `_donor_building_prefix()` (`:731-756`)
and `Data.resolve_sid()` (`:798`) to produce candidate **sids**, then probes
them through `_nation_mesh_on_disk()`. The sid logic stays; only the probe
path changes.

### 2.2 Other runtime readers

| File:line | What it does | Split impact |
|---|---|---|
| `scripts/world3d_fx.gd:652-672` | Calls provider `_mesh_info`/`_stage_mesh_info` (safe). | No change if provider is fixed. |
| `scripts/world3d_fx.gd:678-680` | Standalone fallback hard-codes `res://assets/models/obj/<sid>.obj`, `/glb/<sid>.glb`, `/obj/<sid>4.obj`. | Must use same resolver or ghost fallback misses. |
| `scripts/anim3d.gd:112-113` | `SKIN_INDEX_PATH` + `SKIN_ASSET_DIR`. | Index **must stay at skin root**; `file` values may become relative subpaths with no GDScript change. |
| `scripts/anim3d.gd:809-836` | `_ensure_shipped_skins()`: reads index `entries[].file`, then `_load_shipped_skin(SKIN_ASSET_DIR + file_name)`. | Rewrite 66 `file` strings; code unchanged. |
| `scripts/anim3d.gd:842-847` | `_load_shipped_skin()` validates `c3_skin_v1`. | Schema unchanged. |
| `:106` `MORPH_COORD` / `convert_skins.py:64` / skin `coord` strings | Documentation strings naming `assets/models/obj/<sid>.obj`. | Stale text; update in owned doc pass (not a loader). |

### 2.3 Offline tools (OBSERVED)

| File:line | What it does | Split impact |
|---|---|---|
| `tools/convert_models.py:640-641` | `obj_dir = out/obj`, `tex_dir = out/tex`. | Needs `--layout mapped` or per-entry destination. |
| `:677-679`, `:686-687` | Writes `obj_dir/<sid>.obj`, `mtl_name`, `tex_dir/<sid>.png`; manifest `obj`/`texture_png` = absolute OS paths. | Must emit target tree + new `res` map; normalize the 19 temp paths. |
| `:678`, `:133-137` | `write_mtl(..., os.path.join("..","tex", tex_name))` → `map_Kd ..\tex\<name>.png`. | Needs depth-aware relative path or same-folder mirror (§5). |
| `:631-634`, `:651-654` | `--manifest-name` additive discipline (280 base entries untouched). | Preserve; additive runs must use the same sid→bucket rule. |
| `tools/convert_skins.py:258`, `:284-290`, `:329` | Writes `out/<sid>.json` + `out/index.json`; `--index-name` additive. | Skin tree mirror = change `out` per entry or rewrite `index.file` post-copy. |
| `tools/render_models.py:397-408` | Reads manifest `obj`/`texture_png` absolutely; `SKIP` on missing. | 19 C01 entries currently stale; target tree requires map-based resolution. |
| `tools/migrate_anim_layout.py:2-33`, `tools/migrate_anim_nations.py:2-24` | Existing dry-run / apply / rollback / verify migration pattern with exact `.import` byte rewrites and undo log. | **Reuse this exact pattern** for FOLD-01 (precedent, not a new invention). |

### 2.4 Explicitly out of scope / unrelated (OBSERVED)

- `scripts/tile_atlas_loader.gd:70-71` — `assets/terrain/...` atlas manifests; unrelated.
- `scripts/world3d_terrain.gd:257,277`, `scripts/mapgen.gd:36`,
  `tools/build_tile_index_atlas.py`, `tools/pack_tile_atlas_split.py` — terrain atlas, unrelated.
- `scripts/data.gd:314-316` (`anim/land_units/sco_units.json`),
  `game.gd:1872-1905` (`anim/buildings/buildings.json`),
  `world.gd:193,399-413,503-528,886,3157`,
  `tools/unit_bakers/*`, `tools/compute_ortho.py:17`,
  `tools/normalize_cx.py:11`, `tools/compute_buildings.py:16` — 2D bake tree,
  already split, must not be touched.
- `variant3d/tests/manifest.json` — registry of `res://tests/*.gd` only; **no**
  model/obj/tex paths. Grep of `variant3d/tests/**/*.gd` found no hard-coded
  `assets/models/obj|tex|skin` paths; nearest are `t_anim_metrics.gd:17-18`
  (2D anim index) and `t_ghost_final_stage.gd:39` (sid `"hou"`, not a path).
  Test path risk is therefore **low but not zero** (stats-label strings may
  mention old dirs; no assertion was found to hard-code a count of 299/280).
- Doc strings that will go stale: `CREDITS.md:54-55,100-118`,
  `MECHANICS.md:425-426,481-482`, `README.md:43-48`.

---

## 3. Nation vs shared facts (from N07 + current disk)

### 3.1 OBSERVED / cited from N07

- 21 nation keys (`data.gd:278-290`), 19 building sids, 62 unit sids in
  `UNITS_BASE`, 7 naval keys (`data.gd`, verified: `yacht fishboat yachttur
  galley frigate xebec battleship` all carry `"naval": true`).
- Every nation has its own `<nat>cen.osm/.dds`; port converted only `ukrcen`
  as generic `cen` (N07 §3.1-3.2). C01-ASSET has now added 4 halls:
  `ruscen bavcen polcen swecen` (`CREDITS.md:105-109`).
- 8 distinct donor peasant forms; `peaukr` is the base of generic `peasant`
  (N07 §4.1). C01-ASSET added all 8. `peaaus` serves aus/pru/bav/sax/swi;
  `peaeng` serves fra/eng/swe/den/net; `peaspa` serves spa/ven/por/pie;
  `peatur` serves tur/alg; `peapol` serves pol/hun; `pearus` rus only;
  `peasco` sco only.
- Common-family buildings resolve to `rus*`/`tur*`/`spa*`/`eur*` per
  `country.script:138-206` (N07 §3.4); port only converted `eur*`. They are
  **not nation-owned** and belong in `shared/buildings`.
- `yachttur` is a distinct roster hull sid, not a skin (N07 §4.3); no nation
  mismatch established. Keep it in `shared/naval_units` (INFERRED choice).
- `bar18` and `dock` have **no** OBJ/manifest entry (N07 §3.1); nothing to move.

### 3.2 INFERRED — semantics caveat

`cen` is Ukrainian-derived but generically named; under a sid-based rule it
lands in `shared/buildings`, **not** `ukr/buildings`. Creating a `ukrcen`
alias sid to fix that is a separate owner decision (C01-ASSET added `peaukr`
but no `ukrcen`). Do not silently reclassify by donor prefix — that would
violate determinism and reintroduce the N01/N07 provenance bug.

---

## 4. Deterministic sid -> folder classification rule (DERIVED proposal)

```
classify(sid, manifest_kind):
    if sid in NAVAL_SIDS:                     kind = "naval_units"
    elif manifest_kind == "building":         kind = "buildings"
    elif manifest_kind == "unit":             kind = "land_units"
    elif manifest_kind == "relief":           kind = "relief"     # extra bucket
    elif manifest_kind == "env":              kind = "env"        # extra bucket
    nation = NATION_SID.get(sid, "")
    if nation == "" or sid in SHARED_MULTINATION: nation = "shared"
    return nation + "/" + kind
```

**`NAVAL_SIDS`** (OBSERVED `data.gd`): `yacht fishboat yachttur galley
frigate xebec battleship`.

**`SHARED_MULTINATION`** (DERIVED from N07 §4.1/§4.4): `peaaus peaeng peaspa
peatur peasant pope mullah bagpiper`. Also all stage/scaffold sids, mines,
common-family buildings, every `env` sid and every `relief` sid are naturally
unlisted in `NATION_SID` and therefore shared.

**`NATION_SID` explicit allow-list** (DERIVED: C01-ASSET on-disk sids + N07
§4.2/§6; no regex):

| Nation | Sids |
|---|---|
| `rus` | `ruscen`, `pearus`, `pikemanrus`, `strelet`, `vityaz`, `cossackdon` |
| `bav` | `bavcen`, `musketeer18bav` |
| `pol` | `polcen`, `peapol`, `wingedhussar` |
| `swe` | `swecen`, `pikeman18swe`, `hackapell` |
| `ukr` | `peaukr`, `serdiuk`, `hetman`, `cossackregister` |
| `sco` | `peasco`, `sco_highlandersword`, `pikemansco`, `swordsmansco`, `musketeersco`, `archersco`, `officersco`, `lancersco`, `raidersco` |
| `tur` | `jannisary`, `sipahi`, `spakh`, `tatar` |
| `alg` | `mameluke` |
| `aus` | `croat`, `pandur` |
| `fra` | `chasseur` |
| `eng` | `highlander` |
| `pie` | `padre` |

**Why explicit:** `sco_highlandersword` (prefix `sco_` but roster key), `serdiuk`
(Ukraine-unique, no prefix), `strelet` (Russia-unique, no prefix) prove a
prefix rule is insufficient. `peatur` has a nation-looking prefix but is
shared by two nations — it is overridden into `shared`.

### 4.1 Resulting manifest partition (DERIVED, computed this pass)

| Bucket | sids |
|---|---|
| `rus/buildings` | 1 (`ruscen`) |
| `bav/buildings`, `pol/buildings`, `swe/buildings` | 1 each |
| `rus/land_units` | 5 |
| `bav/land_units` | 1 |
| `pol/land_units`, `swe/land_units` | 2 each |
| `ukr/land_units` | 4 |
| `sco/land_units` | 9 |
| `tur/land_units` | 4 |
| `alg/land_units`, `eng/land_units`, `fra/land_units`, `pie/land_units` | 1 each |
| `aus/land_units` | 2 |
| `shared/buildings` | **125** (17 core + 108 stages; includes generic `cen`, all mines) |
| `shared/land_units` | **33** (incl. `peasant`, `peaaus/peaeng/peaspa/peatur`, `pope`, `mullah`, `bagpiper`, all generic soldiers) |
| `shared/naval_units` | **7** |
| `shared/env` | **93** |
| `shared/relief` | **4** |
| **Total** | **299** (38 nation-specific + 261 shared) |

Texture basenames are **192** unique (many stage sids reuse the base texture,
e.g. `cen1.texture_png` → `cen.png`); no texture is referenced from two
different buckets (computed). `mill_rotor.png` is the sole disk PNG with no
manifest entry and must stay at `tex/` root (or be explicitly added to the
plan).

---

## 5. Complete target tree (DERIVED design)

```
variant3d/assets/models/
├── manifest.json                     # stays at root; + "assets"/"res" map (§6)
├── obj/
│   ├── shared/
│   │   ├── buildings/<sid>.obj + <sid>.mtl + <sid>.obj.import      (125 sids)
│   │   ├── land_units/<sid>.obj + <sid>.mtl + <sid>.obj.import     (33)
│   │   ├── naval_units/<sid>.obj + <sid>.mtl + <sid>.obj.import    (7)
│   │   ├── env/<sid>.obj + <sid>.mtl + <sid>.obj.import            (93)
│   │   └── relief/<sid>.obj + <sid>.mtl + <sid>.obj.import         (4)
│   ├── rus/buildings/ruscen.* ; rus/land_units/{pearus,pikemanrus,strelet,vityaz,cossackdon}.*
│   ├── bav/{buildings/bavcen,land_units/musketeer18bav}.*
│   ├── pol/{buildings/polcen,land_units/{peapol,wingedhussar}}.*
│   ├── swe/{buildings/swecen,land_units/{pikeman18swe,hackapell}}.*
│   ├── ukr/land_units/{peaukr,serdiuk,hetman,cossackregister}.*
│   ├── sco/land_units/{9 sids}.*
│   ├── tur/land_units/{4 sids}.*
│   ├── alg/land_units/mameluke.* ; aus/land_units/{croat,pandur}.*
│   ├── eng/land_units/highlander.* ; fra/land_units/chasseur.* ; pie/land_units/padre.*
│   └── glb/                          # absent today; keep reserved, mirror tree if added
├── tex/<identical relative bucket path>/<texture_basename>.png + .png.import
├── skin/
│   ├── index.json                    # stays at root; entries[].file becomes e.g. "rus/land_units/pearus.json"
│   └── <identical relative bucket path>/<sid>.json   (66 skins; no building/naval skins)
├── anim/                              # UNCHANGED (already nation-first, .gdignore)
├── sprites/ , sprites_hi/             # UNCHANGED (2D bake, .gdignore)
```

Two owner-facing decisions are required before apply (flagged, not assumed):

1. **`shared/env` and `shared/relief` are extra buckets** not named in the
   ticket. All 97 `env`+`relief` sids must live somewhere; placing them under
   `shared/buildings` or `shared/land_units` would be false. Alternative:
   leave them flat at `obj/` root for this tranche. (INFERRED, needs owner.)
2. **`shared/` vs the existing `anim/common/` convention.** `anim/` uses
   `common/`; the ticket says `shared/`. Use `shared/` for the new tree and
   document the mapping; do not rename `anim/common`. (INFERRED.)

**MTL rule if obj+tex mirror into the same bucket folder:** rewrite
`map_Kd ..\tex\<name>.png` → `map_Kd <name>.png` (texture basename from
manifest `texture_png`, **not** the sid — stage sids differ). If tex is left
flat (lower-risk fallback), rewrite to `map_Kd ..\..\tex\<name>.png`.
Godot-side correctness of either form is **UNVERIFIED** without a runner.

---

## 6. Loader strategy: manifest-driven `res://` paths + legacy fallback (DERIVED)

Do **not** rely on absolute OS paths already in `obj`/`texture_png`: 19 of
them are stale temp paths (§1.4), and res:// paths are portable. Add a new
per-entry field, leaving all existing fields byte-identical:

```json
{
  "sid": "ruscen",
  "kind": "building",
  "assets": {
    "obj": "res://assets/models/rus/buildings/ruscen.obj",
    "tex": "res://assets/models/rus/buildings/ruscen.png"
  },
  "...": "all 280/299 original fields unchanged"
}
```

Build `_asset_paths: Dictionary` in the same manifest loop at
`world3d_entities.gd:421-435`, plus:

```gdscript
func _res_for(sid: String, ext: String, suffix: String = "") -> String:
    # ext in {"obj","tex","glb"}; prefer manifest assets map,
    # fall back to today's composed path until a bucket is migrated.
    var e: Dictionary = _asset_paths.get(sid, {})
    var mapped := str(e.get(ext, ""))
    if mapped != "":
        return mapped.get_basename() + suffix + "." + ("png" if ext == "tex" else ext)
    return (TEX_DIR if ext == "tex" else (GLB_DIR if ext == "glb" else OBJ_DIR)) \
        + sid + suffix + "." + ("png" if ext == "tex" else ext)
```

(`get_basename()` + suffix is the stage/scaffold rule for `obj`; textures keep
the manifest basename. Exact implementation is a separate owned ticket.)

Replace, one by one: `:440`, `:444`, `:449-450`, `:458-460`, `:614`, `:721`,
`:1023-1024`, `:1172`, `:1184`, `:1300`, `:1909`; mirror the same helper into
`world3d_fx.gd:678-680` (or delete that fallback in favour of the provider).
`anim3d.gd` needs **no code change** if `skin/index.json` `file` values become
bucket-relative strings while `index.json` stays at `skin/` root.

Properties of this design:

- **Staged**: unmapped sids keep today's exact behavior; each bucket can be
  switched independently (e.g. `rus/buildings` first, `shared/env` last).
- **Reversible**: removing the `assets` entries restores legacy composed
  paths; no Godot scene/UID references are hard-coded in our code (all meshes
  are loaded by path at runtime — OBSERVED at `:1174-1188`).
- **No test weakening**: stats keys (`obj_available`, `mesh_sources`,
  `nation_mesh_usage`) stay the same; gates can still assert exactness.

Alternative rejected: pure code-composed paths with a GDScript bucket table —
duplicates the manifest, drifts when C01-ASSET adds sids, and needs a code edit
per new asset. Godot `[remap]`/`ResourceUID` path tricks were considered but
are **UNVERIFIED** and are not needed.

---

## 7. Exact reversible migration sequence (INFERRED procedure, OBSERVED precedent)

Precedent: `tools/migrate_anim_layout.py:23-33` and
`tools/migrate_anim_nations.py:19-24` already implement dry-run / apply /
rollback / verify with exact byte rewrites and an undo log. Reuse that shape.

**Step 0 — freeze (owner/COORD gate).** Snapshot `git status --short` and the
sha256 of `manifest.json`, `skin/index.json`, all `.obj/.mtl/.png/.import`.
Require C01-ASSET to finish or explicitly hand off. Refuse to start if any
tracked/untracked model path changes during the run (re-check hash immediately
before Step 3). FOLD-01 itself writes no files.

**Step 1 — plan (read-only).** Generate `inbox/FOLD_01_asset_plan.json`:
`sid -> {kind, bucket, src OS path, dst res path, texture basename, skin file,
sha256, import rewrite triples}`. Apply §4 rule; assert 299 sids, 192 unique
textures, no two sids map to the same target path (case-insensitive check),
no target that collides with an existing file. Include the 19 C01 temp-path
anomalies as explicit warnings, not silent fixes.

**Step 2 — backup.** Copy (do not move)
`variant3d/assets/models/{obj,tex,skin}`, `manifest.json`, `skin/index.json`
and all `.import` sidecars into `inbox/backup/models_FOLD01_<UTC>/`. Write an
`inbox/FOLD01_undo.json` with exact src/dst pairs and original bytes for every
rewritten file (mirrors `anim_nation_undo.json`).

**Step 3 — copy-then-switch (apply, no deletions).**
1. Create target directories; **copy** each `.obj`, `.mtl`, `.png`, `.json` to
   its bucket. Originals remain byte-identical.
2. For each copied `.obj.import`/`.png.import`, byte-replace exactly three
   fields: `deps/source_file`, `remap/path`, `deps/dest_files[0]` (and any
   duplicate dest entries), using `hash = md5(utf-8(new res:// source path))`;
   compute the `.mesh`/`.ctex` suffix exactly as the existing sidecar. Preserve
   `uid`, `params`, line endings, all other bytes.
3. Rewrite each copied `.mtl` `map_Kd` per §5 (texture basename from manifest).
4. Add `assets` objects to the manifest copies and rewrite the 66 `file`
   strings in the skin index copy. Do **not** modify the originals yet.
5. Apply the GDScript resolver edits (§6) as a separate owned change with its
   own `inbox/backup/*.bak-FOLD01` files.

**Step 4 — validate (G04-only runner, per WAVE_G_CHARTER.md:31).**
- Python static gate: every manifest sid resolves to an existing file at its
  mapped `res://` path **or** at the legacy composed path; sidecar
  `source_file` equals the mapped path; `path` hash matches recomputed md5;
  no `res://res://`; MTL `map_Kd` target exists; counts equal the plan table
  (38 nation / 261 shared; 299 obj, 192+1 tex, 66 skins).
- Godot import: allow reimport, then check `mesh_sources` does **not** gain
  `donor_bbox_proxy`, `obj_available` does not drop, `nation_mesh_usage`
  shows exact hits for `ruscen/pearus/pikemanrus/…`, skin count stays 66.
- Existing gates unchanged: selftest 29/29, uitest 17/17, `t_render_mode`,
  `t_ghost_final_stage`, `assert_clean CLEAN`; windowed captures show no new
  seams/proxy boxes vs pre-migration frames.
- **Refusal condition:** if any count/stat differs, stop. Do not delete.

**Step 5 — switch originals aside (still reversible).** Only after Step 4 is
green, atomically move the old flat files into
`inbox/backup/models_FOLD01_predelete/<UTC>/` (do **not** `rm`), keeping the
old `manifest.json`/`index.json` backups from Step 2. Legacy fallback in §6
means a partial switch cannot produce missing assets.

**Step 6 — observation window.** Keep the predelete backup for one full gate
cycle. Rollback = restore the backed-up flat tree + manifest/index + code
patch from `FOLD01_undo.json`, then reimport (G04). Delete the backup only on
explicit owner instruction.

**Step 7 — follow-ups, separate owners.** Update doc strings (CREDITS,
MECHANICS, README), `tools/render_models.py`/`convert_models.py` output layout,
and normalize C01-ASSET's 19 temp-path manifest fields. No code change in this
ticket.

---

## 8. Risk register

| # | Risk | Evidence / label | Mitigation |
|---|---|---|---|
| R1 | `.import` sidecars become stale on move (`source_file`, cache hash, `dest_files`, uid). | 280 `.obj.import`, 174 `.png.import`; hash verified as md5(res path) — **OBSERVED** | Exact byte rewrites per `migrate_anim_nations.py:6-17`; preserve uid; undo log. |
| R2 | 19 new OBJ + 19 new PNG have no sidecar; runtime may be proxying them today. | 299-280 / 193-174 counts — **OBSERVED**; engine behavior **UNVERIFIED** | Let G04 reimport before and after; assert zero new `donor_bbox_proxy`. |
| R3 | Godot resource cache / `ResourceLoader.exists()` path caching; imported meshes keyed by hash+uid. | `.godot/imported/` has 3,038 files — **OBSERVED** | Copy-then-switch + reimport; keep legacy paths alive until gates pass; don't reuse uids. |
| R4 | Windows case-insensitive filesystem vs case-sensitive exported builds. | Platform = win32 — **OBSERVED**; Linux behavior **UNVERIFIED** | Lowercase-only target names; case-insensitive collision preflight in Step 1. |
| R5 | Tests hard-code paths. | Grep: **no** model obj/tex/skin paths in `tests/*.gd`; only 2D anim index paths (`t_anim_metrics.gd:17-18`) and sid `"hou"` (`t_ghost_final_stage.gd:39`) — **OBSERVED** | Low risk; still run full gates; don't touch 2D anim trees. |
| R6 | C01-ASSET concurrent new files / uncommitted state. | 86 changed paths, 19 added manifest sids, backups present — **OBSERVED** | Step 0 freeze + hash re-check; plan regenerated; no FOLD-01 writes to their files. |
| R7 | 19 manifest entries point to temp staging paths, not the repo. | `ruscen.obj` → `…\Temp\opencode\c01as_stage\obj\ruscen.obj` — **OBSERVED** | Plan ignores those fields; normalize in Step 7; warn `render_models.py:401`. |
| R8 | `_nation_mesh_on_disk()` probes flat OBJ_DIR; nation art in subfolders would be reported as fallback. | `world3d_entities.gd:718-722`, `:819`, `:209` — **OBSERVED** | Resolver first; assert `nation_mesh_usage` exact hits in gates. |
| R9 | Stage/ghost path composition. | `:1909`, `world3d_fx.gd:678-680` — **OBSERVED** | Suffix-aware resolver; nation stage sids inherit parent bucket when they land. |
| R10 | MTL relative texture path breaks at new depth; `map_Kd` uses Windows backslashes. | `obj/*.mtl` + `convert_models.py:133-137,678` — **OBSERVED** | Same-folder mirror or depth-aware rewrite; engine correctness **UNVERIFIED**. |
| R11 | Stage sids reuse a different texture basename (`cen1` → `cen.png`). | Manifest inspection — **OBSERVED** | Tex mapping by `texture_png` basename, never by sid. |
| R12 | `mill_rotor.png` is not manifest-driven. | 193 disk PNG vs 192 manifest basenames — **OBSERVED** | Keep at `tex/` root or list explicitly in plan. |
| R13 | 97 env/relief sids have no bucket named in the ticket. | Manifest kinds — **OBSERVED** | Add `shared/env`, `shared/relief` or leave flat — owner decision (§5). |
| R14 | `shared/` vs `anim/common/` naming inconsistency. | `anim/` dir listing — **OBSERVED** | Document mapping, don't rename existing tree. |
| R15 | `glb/` absent but code probes it; adding it later needs the same rule. | `world3d_entities.gd:85,1172-1183` — **OBSERVED** | Reserve `glb/`; mirror buckets if V7-8 lands. |
| R16 | Missing `bar18`/`dock` → no files to move; folder split must not pretend to add them. | N07 §3.1 — **OBSERVED (doc)** | Plan is empty for these sids. |
| R17 | Doc/provenance strings become stale. | CREDITS/MECHANICS/README citations §2.4 — **OBSERVED** | Separate owned doc pass. |
| R18 | No donor parity claim. | CHARTER §3/§5 — **OBSERVED** | This is a layout change only; visual result **UNVERIFIED**. |

---

## 9. Open questions / UNVERIFIED register

1. **Owner decision:** approve `shared/env` + `shared/relief` buckets, or keep
   env/relief flat? (§5)
2. **Owner decision:** mirror `tex/` and `skin/` into the same tree (recommended
   here) or split `obj/` only in tranche 1?
3. **Owner/COORD decision:** who owns the GDScript resolver edits? FOLD-01 is
   read-only; `world3d_entities.gd` is also contested by M03/P11 (WAVE_G_CHARTER
  .md:102-104).
4. **UNVERIFIED:** whether the 19 C01-ASSET files are currently imported and
   loaded (no `.import` sidecars; no Godot run allowed for this agent).
5. **UNVERIFIED:** Godot OBJ importer's handling of rewritten MTL `map_Kd` in
   the new folder depth.
6. **UNVERIFIED:** whether any scene/UID resource reference outside our code
   points at an old mesh path (grep found none in `.gd`/`.json`; scenes were
   not exhaustively enumerated).
7. **INFERRED:** `peaukr` (ukr bucket) and generic `peasant` (shared bucket)
   duplicate the same donor geometry; keep both as an alias-pair with a note,
   or dedupe later? Dedupe is **not** part of this ticket.
8. **UNVERIFIED:** `yachttur` could arguably go to `tur/naval_units`
   (identity-only, N07 §4.3); kept in `shared/naval_units` conservatively.

---

## 10. Attestation

- Read-only: no file in `variant3d/`, `inbox/`, `docs/` (other than this
  report), no manifest/index, no `.import`, no test, no config, no git state
  was modified. No file was moved, copied or deleted.
- No Godot launched, no runner job submitted (WAVE_G_CHARTER.md:31).
- No donor file copied into the repo or executed; donor facts are cited from
  N07/N06/CREDITS, not re-derived from bytes this pass.
- **One repo file written:**
  `docs/terrain_swarm_2026-11-25/reports/FOLD_01_folder_split.md`.
- **No donor parity claim.** Visual result of any future migration is
  UNVERIFIED until a real gate/capture exists.

*End of FOLD-01 report.*
