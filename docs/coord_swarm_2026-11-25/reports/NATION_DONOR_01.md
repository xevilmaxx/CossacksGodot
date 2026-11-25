---
id: NATION-DONOR-01
owner: NATION-DONOR-01
task: "Donor nation→unit/building/naval model mapping truth; port nation-key art-selection gap"
date: 2026-11-25
status: DELIVERED
mode: "donor READ-ONLY (python 3.14 bytes/latin-1); port READ-ONLY; no donor binary run, no donor copy, no code edit, no Godot run; this report is the only repo file written"
labels: [observed, derived, inferred, UNVERIFIED]
donor_root: "C:\\Games\\Cossacks 3"
port_root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
verification_passes: 2
visual_parity_claim: false
---

# NATION-DONOR-01 — donor nation→model mapping truth and port gap

## Goal / owner report

Owner report: *with default nations Russia vs Bavaria, the rendered models still look
Ukrainian; likely the nation model mapping is wrong or the menu config does not reach
generation.*

**Finding (observed):** the menu config **does** reach generation
(`variant3d/config.json:71-72` → `main.gd:281-285` → `game.gd:386`), but the port's
3D art is **keyed by base sid, not by nation**, and the manifest's "generic" art was
converted from **Ukrainian donor assets** (`peasant → peaukr.dds`,
`bar → ukrbar.dds`, etc.). No `rus*`/`bav*` 3D mesh or texture exists in the port.
Nation-key art selection exists as a probe (`world3d_entities.gd:639-722`) but falls
back to the base Ukrainian-keyed sid for both Russia and Bavaria. **No parity claim;
visual result UNVERIFIED.**

## 1. Sources

### 1.1 Required prior docs read (all in full)

| Doc | What it supplied |
|---|---|
| `docs/coord_swarm_2026-11-25/reports/DUNIT_01_unit_roster.md` | Donor roster/era/nation-unique sids (`DUNIT_01:243-270`), port parity matrix (`:274-323`), corrections (`:354-385`). |
| `docs/coord_swarm_2026-11-25/decomp/DEC_02_scripts.md` | `country.script` role (`:107`), DScript vocabulary, sidmask-adjacent country handling (`:520-526`), season/external-text rule. |
| `docs/coord_swarm_2026-11-25/decomp/DEC_05_terrain_formats.md` | Twice-verified method discipline (`:56-81`); terrain is unrelated to nation art, checked for overlap. |
| `docs/coord_swarm_2026-11-24/reports/V778_ship_skins.md` | 7 ship families are `.osm`/IDP2 static hulls with no skin tracks (`:113-116`); manifest sid→donor `.oss` mapping (`:58`); visual UNVERIFIED discipline. |
| `docs/research/RA_ROSTER.md` | 21 nations (`:55-83`), building nation prefixes `turbar/ukrbar/rusbar/...` (`:118-141`), G15 thin NATION_UNITS (`:220`), G17 path-family unverifiable from public sources (`:222`). |

### 1.2 Fresh donor reads (this pass; all READ-ONLY, `python` 3.14 `open(path,'rb').read().decode('latin-1')`)

| Tag | Donor path (relative to `C:\Games\Cossacks 3`) | Lines / bytes | Role |
|---|---|---|---|
| **CS** | `data\scripts\lib\country.script` | 4,283 lines | Nation id↔sid (`:5-78`), **building sidmask resolution** (`:138-268`), roster membership (`:2645-2728`), `chaika` (`:2894`), upgrades (`:937-1355`). |
| **AL** | `data\actors\actors.lib` | 964 entries | Definitive actor-name → `.actor` file registry: 574 buildings, 205 units, 104 env, 60 pfx, 21 misc. |
| **OB** | `data\objects\units\units.objects` (241 lines), `data\objects\buildings\*.prop`, `data\objects\units\*.prop` | 225 unit props, 652 building props | `LODActorName`, `DefaultMeshName`, `DefaultMaterialName`, season material swap. |
| **LO** | `data\locale\en\units.txt` | 1,396 lines | Nation block `:1-46`; `@%nat%*` / `@%com%*` building templates `:877-1011`. |
| **MAT** | `data\materials\units\*.dds`, `data\materials\buildings\<nat>\*.dds`, `commoneur/`, `commonrus/`, `commontur/` | 122 unit materials | Per-sid / per-nation textures. |
| **ACT** | `data\actors\units\*.oss` / `*.osm`, `data\actors\buildings\<nat>\*.osm` | — | Actual skinned/static geometry behind each actor. |

`*.country` files: **none on disk** (full recursive scan of donor root found zero; only
`country.script` matches `*country*`). A packed `.country` definition inside
`cossacks.cdx` is **UNVERIFIED** (not inspected). Task-premise `models/**`: no such
donor directory; the equivalent is `data\actors\**` + `data\objects\**` + `data\materials\**`.

### 1.3 Port reads (READ-ONLY)

`variant3d/config.json`, `variant3d/scripts/data.gd`, `variant3d/scripts/main.gd`,
`variant3d/scripts/game.gd`, `variant3d/scripts/world3d_entities.gd`,
`variant3d/assets/models/manifest.json` (172 models), `variant3d/assets/models/**/*.obj`
(172 files).

### 1.4 Verification

Every headline claim was re-read by a second independent means: (V1) targeted
line/entry extraction; (V2) full-file census / a different donor file / the port
manifest plus on-disk OBJ inventory. Labels: **observed** literal bytes/lines;
**derived** deterministic counting; **inferred** interpretation; **UNVERIFIED**
engine-side or not readable.

---

## 2. Donor mapping truth

### 2.1 Nation keys (observed, twice verified)

`CS:11-34` maps ids `0..23` to sids; `CS:48-73` is the inverse. `rus=4`, `ukr=5`,
`bav=18` (`CS:15,16,29`; `CS:54,55,68`). `LO:11-14,37-38` names Russia / Ukraine /
Bavaria. `CS:82-107` declares the boolean selectors `rus`, `ukr`, `bav` used by all
roster conditions.

### 2.2 Two distinct donor mechanisms (do not conflate)

1. **Units** — nation identity is encoded **in the unit sid itself**. The roster
   (`CS:2665-2728`) admits a nation-specific sid; each such sid has its own
   `.prop` → `LODActorName` → `.actor` → `.oss` → `.dds` chain. There is **no generic
   "skin" applied to a shared unit mesh** in readable donor data (observed: 225 unit
   props have only `LODActorName`/`DefaultMeshName`/`DefaultMaterialName`/
   `UseableMaterials[0]`; no `UseSeasonMaterial`, no `*Skin*` records).
2. **Buildings** — a **sidmask template** resolves a 3-letter family code to a
   nation-prefixed actor sid at load time (`CS:138-206`). Locale uses the same
   templates (`LO:877-1011`).

### 2.3 Nation → model mapping table

Columns: nation key | unit sid prefix/suffix | building prefix | ship prefix | example asset names | `path:line`.

| nation | unit sid prefix/suffix | building prefix (`%nat%` / `%com%`) | ship prefix | example asset names | donor `path:line` |
|---|---|---|---|---|---|
| **rus** | suffix `rus`: `pikemanrus`, `officerrus`, `drummerrus`; distinct sids `strelet`, `vityaz`, `cossackdon`, `pope`; peasant `pearus` | own: `rus*` (`rusaca/rusart/rusba2/rusbar/rusbla/ruscen/rusdip/rushou/russta/rustem`); common families resolve to **`rus*`** (`rusmil/rusmar/russto/rustow/ruspor/russwa`) | none; generic `yacht`/`galley`/`frigate`/…; no `yachtrus` | `.oss`: `pikemanrus.oss`, `strelet.oss`, `pearus.oss`; `.dds`: `pikemanrus.dds`, `pearus.dds`; `.osm`: `rusbar.osm`, `ruspor.osm` | `CS:2646-2647,2657,2667,2693,2726,2765-2769`; `AL:311,107,944,912`; `CS:175-179`; `OB:data\objects\buildings\rusbar.prop:9-18` |
| **bav** | distinct 18c sids `musketeer18bav`, `grenadierbav`; **no** `pikeman18bav`; shares `peaaus` peasant with aus/pru/sax/swi | own `bav*` (`bavaca/bavart/bavba2/bavbar/bavbla/bavcen/bavdip/bavhou/bavsta/bavtem`); common families resolve to **`eur*`** (`eurmil/eurmar/eursto/eurtow/eurpor/eurswa`) — `bavpor`, `bavmil` do **not** exist | none; generic hulls only | `.oss`: `musketeer18bav.oss`, `grenadierbav.oss`, `peaaus.oss`; `.dds`: `musketeer18bav.dds`, `grenadierbav.dds`; `.osm`: `bavbar.osm` | `CS:2655,2710,2722,1279,1342`; `AL:3187,3832,3836,900`; `CS:161-204` (no bav case → `eur`); `OB:data\objects\buildings\bavbar.prop:9-18` |
| **ukr** | distinct sids `serdiuk`, `cossacksich`, `cossackregister`, `hetman` (**ukr-only**, see Correction C3); peasant `peaukr`; ship `chaika` | own `ukr*` (`ukraca/ukrart/ukrbar/ukrbla/ukrcen/ukrdip/ukrhou/ukrsta/ukrtem/ukrpor/ukrwwa*`); common: `por`→`ukrpor`, `wwa`→`ukrwwa`, but `mil/tow/swa/sto/mar`→**`rus*`** | **`chaika`** (ukr-only ship sid); no `yachtukr` | `.oss`: `serdiuk.oss`, `cossacksich.oss`, `peaukr.oss`; `.osm`: `chaika.osm`, `ukrbar.osm`, `ukrpor.osm`; `.dds`: `serdiuk.dds`, `peaukr.dds` | `CS:2656,2696,2747,2760-2763,2894,3109`; `AL:463,531,924,976,1083`; `CS:167-196`; `OB:data\objects\buildings\ukrbar.prop:9-18` |
| **tur / alg** | `pikemantur`, `jannisary`, `archertur`, `spakh`, `sipahi`, `tatar`, `yachttur`, `officertur`, `drummertur`, `mullah`, `peatur` | own `tur*`; common families → **`tur*`** (`turmil/turmar/tursto/turtow/turpor`) | **`yachttur`** (distinct family sid, not a Turkey skin of `yacht`) | `pikemantur.oss`, `yachttur.osm`, `turbar.osm`, `turpor.dds` | `CS:1660-1672,2649-2650,2668-2671,2697,2770,2898,2909`; `AL:948,1047` |
| **pru / sax / den / swe / pol / sco / fra / eng / aus / spa / net / por / pie / swi / hun / ven** | suffix families `musketeer18pru`, `grenadierpru`, `hussarpru`; `musketeer18sax`, `grenadiersax`, `guardcavalrysax`; `pikemanpol`, `reiterpol`, `dragoonpol`; `pikemansco`, `swordsmansco`, `framegun`; `reiterswe`, `pikeman18swe`; `chasseur`, `kingmusketeer`, `dragoon18fra`; `highlander`, `musketeeraus`, `pikemanspa`, `jagerpor`, `gauduk`, `jagerswi` … | own `<nat>*` for the 18 "national" families; common families → **`eur*`** | generic hulls (no nation ship sid outside `yachttur`/`chaika`) | `musketeer18pru.oss`, `guardcavalrysax.oss`, `scoba2` (Castle) etc. | `CS:2666,2707-2724,2757-2759,2907-2908`; `AL:3832-3836` region |
| **shared/default if nation key ignored (derived)** | generic unit sid (`pikeman`, `musketeer`, `musketeer18`, `grenadier`, `dragoon`, `cossack`) — **one mesh for all nations sharing that family** | `%com%` fallback `tmpcsid := 'eur'` → `eur*` for every nation not in the `CS:167-200` case list; `%nat%` left unresolved would produce a literal `%nat%...` sid (**engine behaviour UNVERIFIED**) | family-keyed hull `yacht`/`galley`/`frigate`/`battleship`/`xebec`/`fishboat`/`ferry` | `pikeman.oss`, `musketeer.dds`, `eurpor.actor`, `eurmil.actor` | `CS:140-147,161-204`; `AL:67,71,856,928`; `LO:933-1011` |

### 2.4 What the `%nat%` / `%com%` sidmask actually does (observed, `CS:138-206`)

```
CS:141   tmp := last 3 chars of sid
CS:142   tmpscid := '%nat%'
CS:144   '%com%' families: mil, por, tow, wwa, swa, sto, mar, gol, iro, coa
CS:145   '%mis%' families: blg, blg2
CS:147   sidmask := tmpscid + tmp
CS:158   if '%nat%' -> csid + tmp           // e.g. rus+bar = rusbar
CS:161-203 if '%com%' -> default 'eur', then:
           por        : ukr->ukr, rus->rus, tur/alg->tur, por->por      (CS:167-174)
           mil,tow,swa: rus/ukr->rus, tur/alg->tur                      (CS:175-180)
           wwa        : ->ukr                                            (CS:181-183)
           sto,mar    : tur/alg->tur, rus/ukr->rus, spa/por->spa         (CS:184-197)
           blg,blg2   : ->mis                                            (CS:198-200)
```
Second verification: `CS:2646-2652` declares `commonName` = `rus` for rus/ukr,
`tur` for tur/alg, else `eur`; `LO:877-931` uses `@%nat%` for the 10 national
buildings and `LO:933-1011` uses `@%com%` for mines/market/mill/storehouse/
shipyard/gate/wall/tower/palisade. The building material directories corroborate
the families (`data\materials\buildings\commoneur\eurpor.dds`,
`commonrus\ruspor.dds|rusmar.dds|rusmil.dds|russto.dds|rustow.dds|russwa.dds`,
`commontur\turpor.dds|turmil.dds|turmar.dds|tursto.dds|turtow.dds`,
`ukr\ukrpor.dds|ukrwwa.dds`).

**Key Russia/Bavaria/Ukraine difference (observed):** Russia and Ukraine share the
`rus*` common-family building art (mill, market, storehouse, tower, stone wall,
shipyard); Bavaria shares `eur*` common-family art. Their *own* barracks/town-hall/
stable sets are distinct (`rusbar`/`bavbar`/`ukrbar`, `AL:311,3187,463`), and only
Bavaria gets the two unique 18c infantry models (`musketeer18bav`, `grenadierbav`).

### 2.5 Actor → object → material chain (observed, twice verified)

- `AL:<line>` gives `LODActorName = <sid>` and the next line the `.actor` path.
- `data\objects\units\units.objects` lists each `.prop` (e.g. `:64` pikemanrus,
  `:202` musketeer18bav, `:49` pearus, `:52` peaukr, `:112` chaika).
- Each unit prop binds the **same sid** at three levels:
  `pikemanrus.prop:9-10,14` → `LODActorName = pikemanrus`, `DefaultMeshName =
  pikemanrus.mesh`, `Mesh[0].DefaultMaterialName = pikemanrus`; likewise
  `musketeer18bav.prop:9-10,14` and `peaukr.prop:9-10,14`.
- Therefore, in the donor, **sid == art key** for units. Choosing the wrong sid
  chooses the wrong mesh and texture together.

---

## 3. Substitution rules (era / skin / default fallback)

| # | Rule | Donor evidence | Verdict |
|---:|---|---|---|
| R1 | **Nation-unit substitution by roster membership**: generic unit sid is replaced by a nation-specific sid in `country.script` (`rus`→`strelet`/`pikemanrus`/`pearus`; `bav`→`musketeer18bav`/`grenadierbav`/`peaaus`; `ukr`→`serdiuk`/`cossacksich`/`peaukr`). The nation key selects art **indirectly, via the sid**. | `CS:2655-2662,2666-2667,2693,2696,2707-2722,2747,2760-2769`; `DUNIT_01:243-270` | **observed**; cross-checked against `AL` and `MAT`. |
| R2 | **Era substitution is also a sid choice**: 17c/18c are different sids with different actors (`pikeman` vs `pikeman18`, `musketeer` vs `musketeer18`, `hussar` 18c-gated). Ukraine has no 18c barracks and is not in the generic 18c musketeer/grenadier lists. | `CS:2707,2720` (ukr absent); `AL:928,856` and `pikeman18.actor`/`musketeer18.actor`; `DUNIT_01:92-114,247,250` | **observed** for roster/model choice. |
| R3 | **Building nation-prefix substitution**: `%nat%`/`%com%` sidmask resolves to `<prefix><3-char family>` at load. | `CS:138-206`, `LO:877-1011`, `AL:311/3187/463/71/107/531` | **observed** (template + resolution + concrete actors). |
| R4 | **Season substitution is donor-side but applies to buildings only**: 574 of 652 building props set `UseSeasonMaterial = True` with summer/winter material pairs (`rusbar`→`rusbarw`, `bavbar`→`bavbarw`, `ukrbar`→`ukrbarw`). **0 of 225 unit props** have any season/skin field. | `data\objects\buildings\rusbar.prop:16-18`, `bavbar.prop:16-18`, `ukrbar.prop:16-18`; full `.prop` census this pass | **observed**. |
| R5 | **No `SkinName`/`UseSkin` records and no file with "skin" in its name** anywhere under donor `data`. Unit appearance is not a runtime skin swap over a shared mesh. | full filename census + prop-key census this pass | **observed** (absence). |
| R6 | **Default/fallback**: the generic family sid (`pikeman`, `musketeer`, `eur*` common buildings) is what remains when no nation-specific sid is selected; `%com%` defaults to `eur` for all unlisted nations. | `CS:140-147,161-204`; `AL:67,71,856,928` | **derived** from observed rules. |
| R7 | **Actor-resolution fallback when a `LODActorName` or mesh is missing**, any runtime material/season binding, and any packed `.country`/PE-side substitution table. | none readable | **UNVERIFIED** — engine-side; do not assert a fallback model name. |
| R8 | `sidmask` helper procedures are **never called by other DScript files** — they are engine-invoked hooks by name. | recursive scan of all 222 `data\scripts` files this pass | **observed** (no callers) / invocation **UNVERIFIED**. |

---

## 4. Port gap table (READ-ONLY, `file:line`)

`config.json:71-72` sets `nation0:"rus"`, `nation1:"bav"`. `_apply_menu_cfg`
reads them (`main.gd:275-276` fallbacks `ukr`/`rus`; `:281-285` roster path),
maps the roster into `Data.PLAYER_NATIONS` (`main.gd:377-410`, `:424-432`), and
`game.gd:386` writes `players[i]["nation"]`. So **the nation key does reach
generation** — the gap is downstream, in art selection and asset availability.

| # | Where a nation key should select art | Port implementation (`file:line`) | Actual behaviour for `rus`/`bav` | Label |
|---:|---|---|---|---|
| G1 | Train-list: generic sid → nation unit | `data.gd:294-305` `NATION_UNITS`, `:1564-1567` `resolve_sid`; `game.gd:3976-3985` | `rus` maps `musketeer→strelet`, `cossack→cossackdon`, `priest→pope`; **`bav` has no key** → identity. `ukr` maps only `priest→pope`; `pol/tur/alg/swe/sco` partial. | **observed** |
| G2 | Entity spawn carries the resolved sid, not nation | `game.gd:2186-2197` (`spawn` dictionary has `id/kind/player/sid/def/...`, no `nation`) | `_entity_mesh_sid` must recover nation from player state (`world3d_entities.gd:639-664`). | **observed** |
| G3 | Nation-aware mesh sid for units | `world3d_entities.gd:688-706` — `resolve_sid(nation, base_sid)`, candidate only when `rsid != base_sid` | For `bav`, `rsid == base_sid` → candidate `""` → base sid. For `rus`, the train step already resolved `strelet`, so `resolve_sid("rus","strelet")` is identity → base sid. | **observed** |
| G4 | Nation-aware mesh sid for buildings | `world3d_entities.gd:711-714` — probes `nation + "_" + base_sid` (e.g. `rus_bar`, `bav_bar`) | No `<nat>_<sid>.obj`/`.glb` exists (172 OBJs, zero nation-prefixed stems, `portsid07`) → always falls back to base sid. | **observed** |
| G5 | Nation-aware mesh sid for ships | `world3d_entities.gd:707-710` — probes `base_sid + nation` (e.g. `yachtrus`) | Donor has no such family for rus/bav; `yachttur` is a distinct sid already in the manifest. Probe is a no-op for the default pair. | **observed** / donor basis at `CS:167-174` |
| G6 | On-disk probe | `world3d_entities.gd:669-673` `_nation_mesh_on_disk` | Checks `OBJ_DIR+stem+".obj"` / `GLB_DIR`; no nation-prefixed stems on disk → `exact=false`, uses `NATION_MESH_FALLBACK_STATUS` (`:195-198`, `:720`). | **observed** |
| G7 | Manifest art keyed by sid | `manifest.json` + `world3d_entities.gd:87,375-391` | `peasant → data\actors\units\peaukr.oss` / `peaukr.dds`; `cossack → cossacksich.oss/.dds`; `cen/hou/bar/sta/bla/aca/art/dip → data\actors\buildings\ukr\ukr*.osm` and `ukr*.dds`. **8 ukr-keyed building textures; 0 rus-keyed; 0 bav-keyed.** | **observed** (manifest read twice: JSON + OBJ inventory) |
| G8 | Bavaria's unique art | donor `AL:3832,3836`, `MAT:musketeer18bav.dds/grenadierbav.dds`; port manifest | neither `musketeer18bav` nor `grenadierbav` is in the 172-model manifest or 172 OBJs. Even a correct `bav` mapping would have no mesh. | **observed** |
| G9 | Russia's unique art | donor `pikemanrus.oss/strelet.oss/pearus.dds`; port manifest has `strelet`, `vityaz`, `cossackdon`, `hetman`, `pope` but **not** `pikemanrus`, `officerrus`, `pearus`, `drummerrus` | Russian-specific starting infantry/officer/peasant art is absent; the generic `pikeman`/`officer`/`peasant` (Ukrainian `peaukr` for peasant) is used instead. | **observed** |
| G10 | "Ukrainian look" source in visible buildings | `manifest.json` `cen/hou/bar/sta/bla/aca/art/dip` → `ukr*`; `_entity_mesh_sid` fallback `:717-720`; building draw `:1564-1573` | Every nation, including rus and bav, renders Ukrainian-derived town hall/housing/barracks/stable/blacksmith/academy/artillery/diplomatic meshes. This is the direct source of the owner's observation. | **observed** (data path); **visual parity UNVERIFIED** |
| G11 | Default-nation fallbacks that can look Ukrainian even when config is set | `main.gd:275` fallback `ukr`; `:654` and `:1177` `audio.start_music(str(game.players[0].get("nation","ukr")))` | Only relevant if `game.players[0].nation` is missing; `game.gd:386` normally sets it. Not the primary cause for the default config. | **observed** code, impact conditional |
| G12 | `chaika` (ukr unique ship) | donor `CS:2894,3109`, `AL:1083`, `ACT:chaika.osm`; port | no `chaika` manifest entry or OBJ (7 shipped ships are `yacht/yachttur/fishboat/frigate/galley/battleship/xebec`, `V778:113-116`). | **observed** |

**Summary of the gap:** there is no place in the port where the nation key selects
3D art *successfully*. `data.gd:294-305`/`1564-1567` select a **unit sid** only for
7 nations and a handful of generic sids; `world3d_entities.gd:688-722` then probes
for nation-specific 3D art that does not exist on disk and falls back to the
sid-keyed manifest, whose default art is Ukrainian-derived.

---

## 5. Corrections to prior docs / assumptions

| # | Prior claim | This report | Verdict |
|---:|---|---|---|
| C1 | `RA_ROSTER.md:222` G17: "exact donor model/sprite file paths per unit/building … UNVERIFIABLE FROM PUBLIC SOURCES — private install only" | Private-read donor now gives exact chains (`CS` roster → `AL:<line>` → `units.objects:<line>` → `<sid>.prop:9-14` → `.oss/.osm` + `.dds`). Still UNVERIFIED: engine binding/fallback. | **RESOLVED for path families**; engine side remains UNVERIFIED. |
| C2 | `DUNIT_01:319`: `chaika` "MISSING from UNITS_BASE (mesh exists, V7-63)" | No `chaika` manifest entry and no `chaika.obj` in `variant3d/assets/models` (172/172). 7 shipped ships per `V778:113-116` exclude chaika. | **STALE for variant3d**: mesh is absent, not merely unwired. |
| C3 | `DUNIT_01:249` lists `hetman` under Russia | `CS:1982-1984` and `CS:2760-2763` are `if (ukr)`; `hetman` is **Ukraine-only**. Russia gets `cossackdon`+`vityaz` (`CS:2765-2769`). | **CORRECTED**. |
| C4 | Owner hypothesis "menu config does not reach generation" | Config `rus`/`bav` reaches `main.gd:281-285` → `Data.PLAYER_NATIONS` (`:410`) → `game.gd:386`; sim train resolution also consumes it (`game.gd:3976`). The failure is **art availability + Ukrainian-keyed manifest defaults**. | **REFUTED as primary cause** (code path observed). |
| C5 | Implied assumption that every nation has a full prefixed building set | `bavpor`/`bavmil` do not exist; Bavaria uses `eurpor`/`eurmil` (`CS:161-204`, `AL:71,67`). Russia/Ukraine share `rus*` common buildings (`CS:175-196`). | **CORRECTED**. |
| C6 | "Models still look Ukrainian because a wrong nation key is chosen" | No nation key produces *any* nation-specific 3D mesh in the port (0 prefixed OBJs); the Ukrainian look is from manifest asset selection, not a mis-set nation key. | **REFINED** (G7-G10). |

---

## 6. Open questions / UNVERIFIED

1. Engine-side resolution when `LODActorName`/mesh is missing; whether a default
   actor is substituted. No plaintext rule found (R7).
2. Any `.country` records packed in `cossacks.cdx` — not inspected. No `*.country`
   file exists on disk.
3. Whether the two `sidmask` helpers are invoked by the engine with the live
   player's country id (no DScript callers, R8); the resolution logic is observed,
   the call site is **UNVERIFIED**.
4. Runtime season material binding (`UseSeasonMaterial` consumer) is engine-side;
   only the `.prop` declarations are observed.
5. Visual parity of any port mesh vs donor actor is **UNVERIFIED** — no donor A/B
   render or screenshot was made here. No parity claim.
6. Whether `main.gd:654/:1177` music fallback ever fires in the default config —
   code observed, runtime state not measured (no Godot run).
7. `yachttur`/`chaika` at-sea appearance in the port (distinct hull sid vs skin)
   — manifest membership observed; visual result UNVERIFIED.

---

## 7. Summary

- Donor truth: nation identity for **units is the sid** (distinct `.oss`/`.dds` per
  nation-unique unit); for **buildings it is a `%nat%`/`%com%` 3-letter-family
  prefix** resolved against `actors.lib` (964 entries). Russia/Ukraine share the
  `rus*` common-building family; Bavaria uses `eur*`. Ships are family-keyed except
  `yachttur` (tur) and `chaika` (ukr). (observed, twice verified)
- Substitution: roster sid choice (`CS:2655-2728`), era sid choice, building
  nation-prefix sidmask (`CS:138-206`), building-only season materials
  (`rusbar.prop:16-18` etc.). No donor unit skin swap exists in readable data.
  Engine fallbacks UNVERIFIED.
- Port: the nation key reaches generation (`config.json:71-72` → `main.gd:281-285`
  → `game.gd:386`), but `bav` is absent from `NATION_UNITS` (`data.gd:294-305`);
  `world3d_entities.gd:688-722` probes for nation-prefixed meshes that do not exist
  (0 prefixed OBJs), and the sid-keyed manifest uses Ukrainian donor art for the
  generic peasant and all eight core building families. That is the concrete,
  observed origin of the "looks Ukrainian" report.
- Corrections: G17 path families resolved (C1); chaika mesh absent in variant3d
  (C2); hetman is ukr-only (C3); config-reach hypothesis refuted as primary cause
  (C4); Bavaria uses `eur*` common buildings (C5).
- **No donor binary was executed, copied or modified; no donor bytes entered the
  repo; no code, asset, config, board or test was edited. Only this report was
  written. No visual-parity claim is made.**

*End of NATION-DONOR-01.*
