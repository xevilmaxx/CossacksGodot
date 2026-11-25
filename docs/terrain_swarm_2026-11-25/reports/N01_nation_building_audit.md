---
id: WAVE-N-N01
title: "N01 — building sid -> nation 3D mesh audit (read-only)"
owner: N01
created: 2026-11-25
status: DELIVERED
labels: [OBSERVED, DERIVED, UNVERIFIED]
---

# N01 — nation building/mesh association audit (variant3d, read-only)

**Scope.** Trace building sid -> 3D mesh in `variant3d`: `data.gd` `BUILDINGS`,
nation prefixes, `world3d_entities.gd` `_mesh_info()` / sid resolution,
`assets/models/obj/<sid>.obj`, the starting-hall path in `game.gd`, and
`config.gd` defaults. Secondary reference: 2D `app/`. No code edits, no Godot
run, no runner jobs (Wave-N standing rule; WAVE_G_CHARTER.md:169). All verdicts
are from static file/byte reads only; a visual claim would need a real capture
and is **UNVERIFIED** here.

## 1. Direct answer to the owner

**OBSERVED (code+bytes):** the Russian starting (Town Hall) building is created
as a plain generic `spawn("cen", i, c)` with no nation-specific sid
(`variant3d/scripts/game.gd:2950`), and its 3D mesh is `assets/models/obj/cen.obj`
(`world3d_entities.gd:1146-1150`, file exists). That OBJ was converted from
donor **`ukrcen.osm` + `ukrcen.dds` (Ukrainian)**, not from a Russian actor:
`variant3d/assets/models/manifest.json:1050-1056`. The nation-aware selector
computes a Russian candidate `ruscen` and probes for it, but the probe fails, so
it falls back to the base sid `cen` with an explicit BLOCKED status
(`world3d_entities.gd:701-705, 753-777, 783-789, 206`). **There is no Russian
initial hall; it uses a Ukrainian mesh** (`cen` -> `ukrcen`). This corroborates
the previously landed diagnosis (`docs/coord_swarm_2026-11-25/reports/
NATION_DONOR_01.md` G7/G10, `NATION_MODEL_01.md:78`, `B_NATION_PLAN2.md:56`) by
independent byte reads this pass. Visual consequence on screen: **UNVERIFIED**
(no capture/run; also explicitly flagged UNVERIFIED in NATION_MODEL_01.md:13).

**DERIVED (from donor sidmask rule carried by report, not re-read this pass):**
donor's own `country.script:138-206` selects `ruscen` for Russia's hall,
distinct from `ukrcen` (both exist as 2D sheets: `variant3d/assets/models/anim/
rus/buildings/rus_cen.png` and `.../ukr/buildings/ukr_cen.png`, OBSERVED on
disk). N02 (donor truth) owns the primary confirmation.

## 2. Full chain (each hop, with file:line)

| Hop | Evidence | Label |
|---|---|---|
| `BUILDINGS_BASE` has generic sids only: `cen`, `hou`, `bar`, `bar18`, `dip`, `sta`, `bla`, `aca`, `sto`, `mil`, `mar`, `art`, `wal`, `gat`, mines, `tow`, `dock` — no nation-coded building sid. | `variant3d/scripts/data.gd:1304-1359`; live copy `:1550-1557` | OBSERVED |
| Nations and defaults: `NATIONS` includes `rus`; `NATION_UNITS` is **unit-only** (no building rows); `PLAYER_NATIONS = ["rus","bav","pol","swe"]`. | `data.gd:208, 278-290, 294-306` | OBSERVED |
| `config.gd` default `nation0 = "rus"`, `nation1 = "bav"`; apply reads them into `Data.PLAYER_NATIONS`. | `variant3d/scripts/config.gd:123-124, 540-559` | OBSERVED |
| `game.gd` writes `players[i]["nation"]` from the roster, so nation reaches sim. | `game.gd:430, 440-441` | OBSERVED |
| Starting hall: `spawn("cen", i, c)` for every player, same generic sid; starting peasants likewise `"peasant"`; extras `"tow"`/`"cannon"`; battle army via `_spawn_sid` (unit only). | `game.gd:2942-2980` | OBSERVED |
| `spawn()` stores nation **only on the player**, not on the entity (`id/kind/player/sid/def/...`); no `ed["nation"]` field. | `game.gd:2428-2439` | OBSERVED |
| `world3d_entities.gd` recovers nation from `ed.nation` -> `game.players[player].nation` -> `Data.PLAYER_NATIONS[player]`. For slot 0 default that is `"rus"`. | `world3d_entities.gd:660-683` | OBSERVED |
| `_donor_building_prefix("rus", family)`: own families `aca/art/ba2/bar/bla/cen/dip/hou/sta/tem` -> `rus`; common families `mil/tow/swa/sto/mar` -> `rus`; `wwa` -> `ukr`; others -> `eur`. So the candidate for `cen` is `ruscen`. | `world3d_entities.gd:695-726` | OBSERVED (code); donor basis is carried/`UNVERIFIED` this pass (NATION_DONOR_01 §2.4) |
| `_nation_mesh_on_disk()` probes `OBJ_DIR+candidate+".obj"` and `GLB_DIR+candidate+".glb"` only. | `world3d_entities.gd:686-692`; dirs `:84-85` | OBSERVED |
| `assets/models/obj/` contains 280 `.obj` files, **zero** with nation-prefixed stems (`rus*`, `ukr*`, `tur*`, `eur*`, `bav*`, `pol*`, `swe*`, `sco*`, `alg*`); `assets/models/glb/` does not exist. Only `sco_highlandersword.obj` and `spakh.obj` begin with a nation-like prefix, and these are unit sids, not building candidates (`sco_highlandersword` is a nation-coded unit sid, not an entity-prefix probe). | `variant3d/assets/models/obj/` full enumeration this pass; `world3d_entities.gd:84-85` | OBSERVED |
| Consequently `exact=false`, `sid = base_sid`, status = `NATION_MESH_FALLBACK_STATUS` ("BLOCKED … Ukrainian-derived base mesh reused … visual UNVERIFIED"). Telemetry keys `family|nation|base->sid` are recorded. | `world3d_entities.gd:780-800, 803-808, 205-206, 213` | OBSERVED |
| `add_building()` calls `_entity_mesh_sid(..., "building")` then `_mesh_info(sid, "building")`; node name/meta carry the fallback status. | `world3d_entities.gd:1645-1668` | OBSERVED |
| `_mesh_info()` tries GLB, then `<OBJ_DIR><sid>.obj`, then a bbox proxy; records `source`. | `world3d_entities.gd:1110-1160` | OBSERVED |
| Construction-stage/ghost art uses `<sid><1..4><a>.obj` (no nation prefix) and ghost resolves the finished base mesh first; therefore stage/ghost meshes are equally nation-blind. | `world3d_entities.gd:1819-1844`; `world3d_fx.gd:648-672` | OBSERVED |
| 2D comparison: `_bld_key()` builds `nat_sid` (e.g. `rus_cen`) and resolves a nation sheet first (`rus/buildings/rus_cen.png` exists); fallback is generic `sid`. The 2D app therefore **does** distinguish the Russian hall, unlike 3D. | `app/scripts/world.gd:611-626, 656-664, 880-895`; `variant3d/assets/models/anim/rus/buildings/rus_cen.png` | OBSERVED |

**DERIVED:** the two independent causes of F2 ("Russia/Bavaria render with
Ukrainian art") are (a) the 3D OBJ set has no nation-prefixed variants, so the
donor-derived probe can never hit; (b) the base OBJs themselves were converted
from a Ukrainian donor asset selection (manifest), so even the "correct"
generic sid carries Ukrainian geometry/texture. Nation recovery in code works;
art selection is the failure point.

## 3. EVERY building whose 3D mesh does not match the nation implied by sid/role

Definition of "mismatch" used here: a building instantiated for nation **N**
gets a mesh whose donor actor path in `manifest.json` is keyed to a **different**
nation prefix (or to no nation at all where the donor sidmask requires one).
"3D mesh" means the OBJ actually loaded plus its donor `.osm/.dds` provenance.
Line numbers: manifest entry `M:<line>`, table row `D:<line>`, selector code
`V:<line>`. `M:` lines are the first matching manifest `sid` entries read this
pass. All visuals UNVERIFIED (no capture).

### 3A. Ukrainian meshes reused by every nation (the eight core own-family buildings)

For **any** nation (including `rus`), these sids resolve to Ukrainian donor
art. The selector computes a nation candidate (`ruscen`, `bavbar`, ...)
(`V:777`), probes (`V:688-692`), misses, falls back (`V:783-789`).

| sid | role / nation implied | 3D mesh actually loaded (OBJ + donor source) | manifest | mismatch label |
|---|---|---|---|---|
| `cen` | Town Hall — own family, `rus` -> `ruscen` | `cen.obj` <- `buildings/ukr/ukrcen.osm` + `ukrcen.dds` | M:1050-1056 | **OBSERVED** byte; donor-correct Russian art UNVERIFIED (N02) |
| `hou` | House — own family, `rus` -> `rushou` | `hou.obj` <- `ukrhou.osm/.dds` | M:1071-1072 | OBSERVED byte |
| `bar` | Barracks — own family, `rus` -> `rusbar` | `bar.obj` <- `ukrbar.osm/.dds` | M:1090-1091 | OBSERVED byte |
| `sta` | Stable — own family, `rus` -> `russta` | `sta.obj` <- `ukrsta.osm/.dds` | M:1109-1110 | OBSERVED byte |
| `bla` | Blacksmith — own family, `rus` -> `rusbla` | `bla.obj` <- `ukrbla.osm/.dds` | M:1128-1129 | OBSERVED byte |
| `aca` | Academy — own family, `rus` -> `rusaca` | `aca.obj` <- `ukraca.osm/.dds` | M:1147-1148 | OBSERVED byte |
| `art` | Artillery — own family, `rus` -> `rusart` | `art.obj` <- `ukrart.osm/.dds` | M:1166-1167 | OBSERVED byte |
| `dip` | Diplomatic — own family, `rus` -> `rusdip` | `dip.obj` <- `ukrdip.osm/.dds` | M:1261-1262 | OBSERVED byte |

This set exactly matches the 8 ukr-keyed buildings reported in NATION_DONOR_01
G7/G10. **The Russian initial hall is row `cen`: its mesh is Ukrainian.**

### 3B. Common-family buildings: Ukrainian/European mesh vs Russian sidmask (no Russian mesh exists on disk)

Donor sidmask (carried) says Russia wants `rus*` common-family art; the port
manifest converted `eur*` instead. No `russto`/`rusmil`/`rustow`/`rusmar`/
`russwa`/`russga` OBJ exists.

| sid | nation-implied mesh (rus/ukr) | actual 3D mesh (OBJ + donor source) | manifest | mismatch label |
|---|---|---|---|---|
| `sto` | storehouse -> `russto` | `sto.obj` <- `commoneur/eursto.osm/.dds` | M:1183 | OBSERVED byte; donor rule UNVERIFIED this pass |
| `mil` | mill -> `rusmil` | `mil.obj` <- `commoneur/eurmil.osm/.dds` | M:1202 | OBSERVED byte |
| `mar` | market -> `rusmar` | `mar.obj` <- `commoneur/eurmar.osm/.dds` | M:1221 | OBSERVED byte |
| `tow` | tower -> `rustow` | `tow.obj` <- `commoneur/eurtow.osm/.dds` | M:1240 | OBSERVED byte |
| `wal` | wall -> `russwa` | `wal.obj` <- `commoneur/eurswa.osm` (texture dir `commonrus`) | M:1278 | OBSERVED byte |
| `gat` | gate -> `russga` | `gat.obj` <- `commonrus/eurswa_gate.osm` (mixed commonrus path, eur* name) | M:1297 | OBSERVED byte |
| `mine_gold` | ore mine -> `rusgold`-style common | `mine_gold.obj` <- `env/minegold.osm` (env keyed, no nation) | M:1316 | OBSERVED byte; nation requirement UNVERIFIED |
| `mine_iron` | ore mine -> common | `mine_iron.obj` <- `env/mineiron.osm` | M:1335 | OBSERVED byte |
| `mine_coal` | ore mine -> common | `mine_coal.obj` <- `env/minecoal.osm` | M:1354 | OBSERVED byte |

For **Turkey/Algeria** these same common buildings want `tur*`; the selector's
candidates (`tursto`, `turmil`, `turtow`, `turmar`, `turswa`, ...) also miss
(zero `tur*.obj`), so the same eur*/env meshes are reused — also a mismatch
(OBSERVED byte, UNVERIFIED visual).

### 3C. Buildings with no 3D art at all (role/nation mismatch by absence)

| sid | table row | situation | label |
|---|---|---|---|
| `bar18` | D:1313-1315 | No manifest entry, no `bar18.obj`, no bbox row; 2D has `rus_bar18`/`bav_bar18` sheets (variant3d anim/rus|bav), 3D has none. Falls to bbox proxy. Also explicitly excluded from ghost stage path (world3d_fx.gd:664-665). | OBSERVED absence; proxy visual UNVERIFIED |
| `dock` | D:1357-1358 | No manifest entry, no `dock.obj`, no bbox row; 2D has no `rus_dock` sheet either. Falls to proxy. | OBSERVED absence |
| `tem`, `por` (temple, shipyard-family) | none in `BUILDINGS_BASE` | Donor own/common family exists; port has no row, no OBJ. | OBSERVED absence |

`assets/models/obj/` per-stage files (`cen1..4`, `hou1..4`, etc.) exist but are
also unprefixed Ukrainian-derived (`manifest.json:3273+` shows `cen1` ->
`ukrcen1.osm`), so they do not fix the mismatch (OBSERVED).

### 3D. Correct-by-identity exceptions (no mismatch)

- `yachttur` (D:1358, M:1392): donor ship art is family/roster-keyed, not a
  nation skin; `yachttur` is a distinct sid (`units/yachttur.osm`), not
  Ukrainian-derived. 3D branch is deliberately `pass` (`V:778-779`). No
  mismatch established (OBSERVED code; donor basis UNVERIFIED this pass;
  NATION_DONOR_01 G5/NAVAL_NATION_01 carried).
- `sco_highlandersword.obj`, `spakh.obj` etc. are unit meshes, not building
  meshes; out of N01 scope (see N03).

## 4. Nation prefix rules used by the selector (OBSERVED code)

`_donor_building_prefix(nation, family)` (`V:701-726`):
- own families `aca/art/ba2/bar/bla/cen/dip/hou/sta/tem` -> `<nation>` (e.g.
  `ruscen`, `bavbar`, `ukrcen`);
- `por`: own prefix only for `ukr/rus/tur/alg/por`;
- `mil/tow/swa` and `sto/mar`: `rus` for `rus/ukr`, `tur` for `tur/alg`,
  else default;
- `wwa` -> `ukr`; `blg/blg2` -> `mis`; everything else -> `eur`
  (`country.script:161` default, carried).

Because no prefixed OBJ exists, **every one of these candidates fails the probe**.
The fallback status text is honest and explicitly states the Ukrainian look is
NOT fixed (`V:206, 213`).

## 5. 2D vs 3D comparison (secondary reference)

| | 2D `app/` | 3D `variant3d/` |
|---|---|---|
| Building key | `nat_sid` from `Data.PLAYER_NATIONS` (`world.gd:611-626`), e.g. `rus_cen` | `<prefix><sid>` concatenated (`world3d_entities.gd:777`), e.g. `ruscen`; probe then fallback |
| Art coverage | Per-nation baked PNGs exist, e.g. `rus/buildings/` 78 PNGs (incl. `rus_cen`, `rus_bar18`), `ukr` 72, `tur` 72, `bav` 78, `pol/swe` 78, `sco` 18, `alg` 36 (`app/assets/models/anim/<nat>/buildings/`, OBSERVED) | 280 generic OBJs, 0 nation-prefixed (OBSERVED) |
| Russian hall | `rus/buildings/rus_cen.png` and `.../rus_cen_s1..s4.png` exist (`app` + `variant3d` anim trees, OBSERVED) | `cen.obj` <- `ukrcen.osm` (OBSERVED) |
| Result | Russian hall visually distinct from Ukrainian | Russian hall identical Ukrainian mesh (data path OBSERVED; visual UNVERIFIED) |

Both trees ship the same `buildings.json` (215874 bytes each, OBSERVED), so the
2D key vocabulary (`rus_cen`, etc.) is available; only the 3D OBJ conversion is
missing. The 2D app's `_bld_decal()` also uses `{nation}{sid}` keys
(`world.gd:725-740`), again nation-aware.

## 6. Labels and limits

- **OBSERVED** — direct reads this pass: `data.gd:1304-1359, 208, 278-306`;
  `config.gd:123-124, 540-559`; `game.gd:430, 441, 2428-2439, 2942-2980`;
  `world3d_entities.gd:84-85, 660-692, 695-800, 1110-1160, 1645-1668,
  1819-1844, 205-213`; `world3d_fx.gd:648-672`; `app/scripts/world.gd:
  611-626, 656-664, 725-740, 880-895`; manifest lines; OBJ/PNG enumeration.
- **DERIVED** — donor `country.script:138-206` prefix rule and its UTC mapping
  are taken from the already-landed NATION_DONOR_01/NATION_DATA_01 reports,
  not re-read from donor this pass; the mismatch verdicts labelled "OBSERVED
  byte" are certain about *what mesh the port loads*, while donor correctness
  of the alternative is N02's scope.
- **UNVERIFIED** — on-screen appearance, donor GPU A/B parity, engine-side
  actor-resolution fallback (NATION_DONOR_01 R7), and any claim about packed
  `.country` data. No Godot run and no capture were made (standing rule).

## 7. Hand-off to N02/N04/N05

- N02 should confirm `ruscen` vs `ukrcen` actor files and Russian peasant
  (`pearus`) / starting-hall sid from donor primaries.
- N04 (fix proposal) must respect the already-landed guardrails: do **not**
  invent `rus*/bav*/eur*` OBJ names or `bavmil`/`bavpor` (donor has none;
  NATION_DONOR_01 G8/C5), and do not edit code/assets until COORD grants
  ownership. The missing art owner is `manifest.json` + `assets/models/obj/`,
  not `world3d_entities.gd`.
- N05 QA atom should capture slot-0 `rus` hall and compare with a `ukr` slot,
  with a real windowed capture; no claim of donor parity without a donor frame.

*End of N01 report.*
