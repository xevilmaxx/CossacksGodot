# AUDIT — Building nation variants (`shared/buildings` is not all shared)

Date: 2026-11-26 (UTC). Scope: read-only audit, no code/Git/Godot changes.
Inputs read: `variant3d/assets/models/obj/**/buildings/*.obj` (glob),
`variant3d/assets/models/manifest.json` (building entries + 4 nation `cen` entries),
`variant3d/scripts/asset_paths.gd`, `variant3d/scripts/game.gd` (nation selection,
`spawn("cen")`, `_spawn_sid`), `variant3d/scripts/world3d_entities.gd` (building mesh
binding, `_donor_building_prefix`, `_entity_mesh_sid`, `add_building`, `_mesh_info`),
`variant3d/scripts/data.gd` (`PLAYER_NATIONS`, `NATIONS`, `NATION_UNITS`, `resolve_sid`,
`BUILDINGS_BASE`). Donor `data/buildings/**` was not directly readable in this
workspace; donor evidence below comes from the `mesh`/`texture` provenance fields
stored per-entry in `manifest.json` (donor `.osm`/`.dds` source paths), not from a
fresh donor parse. No parity claim is made.

## 1. Finding (one paragraph)

`variant3d/assets/models/obj/shared/buildings/` is a mixed bucket: 8 of its base
meshes are Ukrainian-nation art filed as "shared", 4 are pan-European `commoneur`
art, 2 are wall/gate art with split `commonrus`/`commoneur` provenance, 3 are
nation-free environment mines, and only 4 genuinely nation-specific OBJs exist —
and they live outside `shared/` (`rus/bav/pol/swe/buildings/*cen.obj`). The port's
3D building selector (`world3d_entities.gd:_entity_mesh_sid` + `_donor_building_prefix`)
already encodes the donor prefix rule and probes disk read-only, so the only hall
that ever resolves `exact=true` is `cen` for rus/bav/pol/swe; every other
building/nation combination (including the default nation0=rus / nation1=bav game)
falls back to the `shared/` mesh with an explicit BLOCKED label. The fallback mesh
is frequently the *wrong nation's* art (Ukrainian) presented under a generic sid,
and for the `eur*` family the candidate stem can never hit because the converted
sid keeps the generic name (`mil`, not `eurmil`).

## 2. What is actually on disk

### 2.1 Nation-specific building OBJs (4 files, all `*cen`, all outside `shared/`)

| File | Manifest sid | Donor mesh (manifest `mesh`) | Donor tex |
|---|---|---|---|
| `obj/rus/buildings/ruscen.obj` | `ruscen` | `data/actors/buildings/rus/ruscen.osm` | `.../materials/buildings/rus/ruscen.dds` |
| `obj/bav/buildings/bavcen.obj` | `bavcen` | `data/actors/buildings/bav/bavcen.osm` | `.../materials/buildings/bav/bavcen.dds` |
| `obj/pol/buildings/polcen.obj` | `polcen` | `data/actors/buildings/pol/polcen.osm` | `.../materials/buildings/pol/polcen.dds` |
| `obj/swe/buildings/swecen.obj` | `swecen` | `data/actors/buildings/swe/swecen.osm` | `.../materials/buildings/swe/swecen.dds` |

Each has a matching nation texture (`tex/<nat>/buildings/<nat>cen.png`; verified
for `rus`, `swe`; `bav`/`pol` follow the same manifest `assets` pattern). There are
no `ukr/`, `tur/`, `alg/` (or any other nation) building folders, and no
nation-specific stage/ghost OBJs (`ruscen1`, `bavhou1`, …) anywhere.

### 2.2 `shared/buildings/` contents by true provenance (from manifest `mesh`)

Truly shared / nation-free (7 base sids):

- `wal.obj` — donor `data/actors/buildings/commoneur/eurswa.osm`, tex
  `.../materials/buildings/commonrus/eurswa.dds` (mixed commoneur/commonrus wall set).
- `gat.obj` — donor `data/actors/buildings/commonrus/eurswa_gate.osm`, tex
  `commonrus/eurswa.dds`. Singletons: no `<sid>1..4`/`<sid>a` stage variants on disk.
- `mine_gold.obj`, `mine_iron.obj`, `mine_coal.obj` — donor
  `data/actors/env/mine<ore>.osm` + `data/materials/env/mine<ore>.dds`. Environment
  props, not nation architecture. No stage variants.
- `eurmilanim.obj` — donor `eurmilanim.oss` sail/anim reference used by the mill
  rotor billboard (`world3d_entities.gd` MILLFIX), not a placeable building mesh.
- `sto.obj`, `mil.obj`, `mar.obj`, `tow.obj` (+ full `<sid>1..4` / `<sid>a` stage
  families) — donor `data/actors/buildings/commoneur/eur<sid>.osm`
  (`eursto`, `eurmil`, `eurmar`, `eurtow`) + `commoneur` textures. Pan-European art
  shared across nations by donor design; the folder label is correct for these four.

Mislabeled as shared — actually Ukrainian nation art (8 base sids, each with a full
`<sid>1..4` + `<sid>a` stage/ghost family, e.g. `cen1..cen4`, `cena` at
manifest ~4868ff / ~5076):

- `cen.obj` ← `ukr/ukrcen.osm`, `hou.obj` ← `ukr/ukrhou.osm`,
  `bar.obj` ← `ukr/ukrbar.osm`, `sta.obj` ← `ukr/ukrsta.osm`,
  `bla.obj` ← `ukr/ukrbla.osm`, `aca.obj` ← `ukr/ukraca.osm`,
  `art.obj` ← `ukr/ukrart.osm`, `dip.obj` ← `ukr/ukrdip.osm`
  (all with `.../materials/buildings/ukr/ukr<sid>.dds` textures).

No converted base OBJs exist for sim sids `bar18` and `dock` (no manifest entry;
`_mesh_info` serves a bbox proxy). This is a mesh-coverage gap, not a nation bug,
but it rides the same fallback path.

## 3. How the donor chooses nation variants (as encoded / evidenced in-port)

- Units: nation identity IS the sid (`Data.resolve_sid(nat, sid)` ←
  `country.script`; `game.gd:_spawn_sid` applies it to `BATTLE_ARMY` only).
  `Data.NATION_UNITS` (`data.gd:294-306`) covers rus/bav/ukr/pol/tur/alg/swe/sco
  unit remaps. **There is deliberately no building remap**: `resolve_sid` only
  consults `NATION_UNITS`, and `game.gd:spawn("cen", i, c)` (`_spawn_starts`,
  :3200) plus all other building spawns keep the generic 3-letter sim sid
  (`cen`, `hou`, `bar`, …). The sim is nation-blind for buildings by design; the
  nation is carried on `players[i].nation` / `Data.PLAYER_NATIONS[i]`
  (`game.gd:431-442`, default `data.gd:208` `["rus","bav","pol","swe"]`, i.e.
  nation0=rus, nation1=bav unless the menu picks otherwise).
- Buildings: `%nat%` / `%com%` 3-letter-family prefix rule (`country.script:138-206`
  as re-encoded in `_donor_building_prefix`, `world3d_entities.gd:1197-1222`):
  `aca/art/ba2/bar/bla/cen/dip/hou/sta/tem` use the nation's own 3-letter prefix;
  `por` has nation overrides; `mil/tow/swa` resolve to `rus*` for rus/ukr, `tur*`
  for tur/alg, else `eur*`; `wwa`→`ukr`; `sto/mar`→`rus` (rus/ukr), `tur` (tur/alg),
  `spa` (spa/por); `blg/blg2`→`mis`; default `eur`. The donor 2D bake applies this;
  the 3D port only *probes* the resulting `<prefix><sid>` stem against converted
  OBJ/GLB on disk (`_nation_mesh_on_disk` → `AssetPaths.existing(sid, "obj"|"glb")`).

## 4. Where the port resolves the wrong / missing nation

Binding chain for every building: `add_building(e)` (:2211)
→ `_entity_mesh_sid(ed, base_sid, "building")` (:2223)
→ `_donor_building_prefix(nation, base_sid) + base_sid` (:1284)
→ `_nation_mesh_on_disk(candidate)` (:1291) → hit sets `sid=candidate, exact=true`,
miss keeps the generic sid with `NATION_MESH_FALLBACK_STATUS` (:1296) and the
Ukrainian-derived mesh (`manifest.json` `peasant→peaukr`, `cen/hou/bar/sta/bla/aca/art/dip→ukr*`,
:211). Nation comes from `ed["nation"]` → `game.players[p]["nation"]` →
`Data.PLAYER_NATIONS[p]` (`_nation_of`, :1161); entities carry no nation key
themselves. `AssetPaths.res_for/existing` (`asset_paths.gd:70-93`) maps only by
manifest `sid` → bucket path with a flat-tree legacy fallback — it has no nation
parameter, so all nation intelligence lives in the candidate stem, not the resolver.

Exact mapping for the default game (nation0=rus, nation1=bav) and other menu nations:

| Base sid | Donor-correct art for rus/bav | Candidate stem probed | On disk? | What the player sees (3D) |
|---|---|---|---|---|
| `cen` | `ruscen` / `bavcen` (own) | `ruscen` / `bavcen` | YES (4 nation OBJs) | Correct nation hall, `exact=true`. Only working case. |
| `cen` for ukr/pol/swe/tur/… | `ukrcen` / `polcen` / `swecen` / `turcen`… | same pattern | Only `polcen`, `swecen` exist; `ukrcen`, `turcen`, … absent | pol/swe correct; **ukr/tur/alg/aus/fra/… fall back to `shared/cen.obj`, which happens to BE `ukrcen` art — right look for ukr by accident, wrong look for everyone else, always labelled fallback**. |
| `hou/bar/sta/bla/aca/art/dip` (own-family) | `rus*` / `bav*` / nation-own | `rushou`, `bavhou`, … | NO (only `*cen` converted per nation) | **Wrong-nation**: Ukrainian `ukr<sid>` mesh under the generic sid for every nation, including rus and bav. Stage/ghost art (`<sid>1..4`, `<sid>a`) is likewise always the `ukr*` bake (`NATION_STAGE_GHOST_BLOCKED_STATUS`, :1300-1302). |
| `mil/tow` (`swa` has no sim sid) | rus/ukr→`rus*`, tur/alg→`tur*`, bav→`eur*` | `rusmil`, `eurtow`, … | NO | **Right donor family, wrong label/path**: the `shared/mil.obj` mesh IS donor `eurmil.osm` art, but the probe looks for sid `eurmil` (no manifest entry / OBJ), misses, and serves generic `mil` as `exact=false` BLOCKED. Same for `tow` (`eurtow`), `sto`/`mar` (`russto`/`eursto`/… vs generic `sto`). The pixels are the shared European set; the status line claims absence. |
| `wal/gat/mines` | shared env/common art | `eurwal`?/nation+`gat`… | NO (`wal`/`gat` singletons probed as nation stems only via generic families) | Correct shared art via fallback (these families are not in `OWN_FAMILIES` except through `swa`; `wal`/`gat`/`mine_*` have no nation variants to miss). |
| `bar18`, `dock` | unknown (no converted art) | `rusbar18`, `eurdock`, … | NO (no base OBJ either) | Bbox proxy (`donor_bbox_proxy`); out of nation scope. |

Two compounding defects:

1. **Missing-nation**: 8 `shared/` base meshes are `ukr*` conversions. Any non-ukr
   nation building `hou/bar/sta/bla/aca/art/dip/cen` (except the 4 converted
   `*cen`) renders Ukrainian architecture. The `NATION_MESH_FALLBACK_STATUS` label
   says so honestly, but the 3D picture is still wrong-nation.
2. **Wrong-stem for the shared-European family**: the converter stored donor
   `eur<sid>.osm` under the generic sid (`mil`, `sto`, `mar`, `tow`). The runtime
   probes the donor-correct prefixed sid (`eurmil`), which can never exist under
   the current manifest/bucket scheme, so `exact` is structurally unreachable for
   exactly the buildings whose art is already correct. (Symmetric note: if
   `rus*`/`tur*` variants of `mil/sto/mar/tow` are ever converted, the current
   probe WILL find them — the defect is only that the `eur*` default has no alias
   back to the generic sid.)

Stage/ghost meshes inherit both defects: `_entity_mesh_sid` (:1300) probes
`<nation><sid>1` and appends `NATION_STAGE_GHOST_BLOCKED_STATUS` whenever it is
absent — which is always (zero nation stage OBJs on disk) — while the base-stage
`<sid>1..4`/`<sid>a` OBJs actually bound are the `ukr*` (or `eur*`) bakes.

## 5. Smallest code/config fix (recommendation only — nothing was edited)

Do not reconvert art and do not touch the sim (sids, stats, `resolve_sid`,
`spawn`). The cheapest honest fix is a manifest/lookup alias, not new meshes:

1. **Add 4 `extra_assets` alias rows in `manifest.json`** (the `AssetPaths`
   `_assets` map already merges `extra_assets`, `asset_paths.gd:46-51`):
   `eurmil`, `eursto`, `eurmar`, `eurtow` → each pointing at the existing
   `shared/buildings/<sid>.obj` + `<sid>.png` bucket files. Effect: the
   donor-correct default candidate (`eurmil` for bav/pol/swe/…, `rusmil`/`turmil`
   still correctly BLOCKED until converted) resolves `exact=true` with zero new
   binaries, and the BLOCKED label stops misreporting present art as absent.
   Optionally add a `ukr<sid>`→`shared/<sid>` alias set for the 8 Ukrainian
   files so a future ukr probe is explicit rather than accidental — but keep it
   labelled fallback unless owner wants ukr claimed exact.
2. **If code may change at all, one-line guard in `_entity_mesh_sid`
   (`world3d_entities.gd:1283-1284`)**: when the probed prefixed candidate misses
   but the base sid's manifest `mesh` provenance already equals the donor-correct
   source for that nation (e.g. base `mil` IS `eurmil.osm` and nation maps to
   `eur`), return `exact=true` with a distinct `NATION_MESH_SHARED_EUR_STATUS`
   label instead of BLOCKED. This is a labelling-only change; mesh bytes are
   untouched. Without this, option 1 alone achieves the same result via data.
3. **Do NOT rename `shared/` or move the 8 `ukr*` files yet.** The 2D sprite
   pipeline (`assets.sprites` entries on the same manifest rows), the stage
   families (`<sid>1..4`/`<sid>a` share `tex_name`), and the flat-tree legacy
   fallback (`asset_paths.gd:59-67`) all key on the current bucket paths. A move
   without a converter rerun breaks sprites and rollback. If a later ticket
   converts `rus*/bav*/tur*` building OBJs, drop them in `<nat>/buildings/` with
   manifest `bucket` entries mirroring the 4 `*cen` rows — the existing probe
   picks them up with no code change.

Suggested acceptance check (read-only, no Godot needed): for each base building
sid × each `Data.NATIONS` key, print `candidate → hit/miss → served OBJ → donor
mesh provenance`; after option 1, `eur*` candidates for `mil/sto/mar/tow` must
show `exact=true` serving the existing `shared/` file, `*cen` for rus/bav/pol/swe
unchanged, and every other nation-building pair must still show the explicit
fallback/BLOCKED label (no silent "fixed").
