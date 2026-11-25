---
id: N02-DONOR-NATION-OBJECTS
ticket: N02
wave: N (WAVE_G_CHARTER.md "Wave N — NATION OBJECT ASSOCIATIONS", lines 157-169)
title: "Donor truth — nation-specific starting hall and peasant meshes"
created: 2026-11-25
status: DELIVERED
labels: [OBSERVED, UNVERIFIED]
scope: READ-ONLY donor research. No runner, no code edits, no donor copies, no parity claim.
---

# N02 — Donor truth: nation-specific starting buildings & peasants

## 0. Scope and guardrails

Owner directive (WAVE_G_CHARTER.md:159): *"initial hall object of Russian nation should be
different; check association of 3D objects to nations correctness; also peasants are of
different form."* N02 is the **donor-truth** half (N01 = port audit, N03 = port peasant audit,
N04/N05 = fix/QA proposals). Per charter: analysis agents edit ONLY their report; no runner
jobs (G04 owns Godot); donor parity stays UNVERIFIED without a GPU A/B frame.

**No donor file was copied into the repo.** Everything below is a read of
`C:\Games\Cossacks 3\data` (the installed donor) plus public URLs. Nothing here claims our
port matches the donor — that is N01/N03/N04/N05/COORD territory.

Label key: **OBSERVED** = read directly from the cited donor file or fetched URL text.
**UNVERIFIED** = inferred, or the direct source could not be retrieved/decoded.

## 1. Sources consulted

Local donor (all READ-ONLY, absolute root `C:\Games\Cossacks 3\data`):
- `scripts\lib\country.script` — nation IDs, `_country_Init`, member/starting-building rules.
- `scripts\lib\unit.script` — `csid+'cen'` usage classification, peasant stat block.
- `scripts\common.inc\dogenerate.inc` — starting-unit generation.
- `locale\en\units.txt`, `locale\ru\units.txt` — object/unit display names.
- `objects\buildings\buildings.objects`, `objects\buildings\<sid>.prop`.
- `actors\buildings\<prefix>\<sid>.actor`/`.osm` — building mesh registration.
- `actors\units\pea*.actor`/`.oss`, `animations\aaf\pea*.aaf`,
  `materials\units\units.mat`/`.dds` — peasant mesh/animation/material set.
- `game\var\startingsettings.cfg` — national starting-army table.

Online (fetched this session):
- `https://raw.githubusercontent.com/anyalink99/cossacks-3-almanac/main/internals_en/scripts/building_mechanics_evidence.md`
- `https://raw.githubusercontent.com/anyalink99/cossacks-3-almanac/main/docs_en/recon/world/economy/peasant_extraction.md`
- `https://raw.githubusercontent.com/anyalink99/cossacks-3-almanac/main/internals_en/scripts/map_generation_evidence.md`
- `http://cossacksworld.ucoz.co.uk/index/new_buildings/0-349` — **403**; HTTPS transport
  error. Its content is only known via the CHARTER.md seed (`CHARTER.md:105-107`), so the ucoz
  claim is carried as UNVERIFIED below, corroborated by local files.

## 2. (a) Russian Town Hall / initial hall — sid and mesh

### Finding A1 — Russia's Town Hall sid is `ruscen`; mesh `ruscen.mesh` / `ruscen.osm`
**OBSERVED.**
- `scripts\lib\country.script:15` — `_country_GetSIDByID`: `4 : sid := 'rus'` (nation id 4);
  inverse at `:54` `'rus' : id := 4`. So the nation prefix string is literally `rus`.
- `scripts\lib\country.script:2823` — the donor registers each nation's center building as
  `_country_AddMember(country, csid+'cen', ... gc_ai_unit_center)`. For Russia this is
  `rus` + `cen` = **`ruscen`**, tagged as the *center* (Town Hall) building.
- `scripts\lib\unit.script:2368-2371` — `case objprop.sid of csid+'cen' : ... gc_obj_usage_center`
  confirms `<prefix>cen` is the Town Hall class; `:2381-2384` gives Russia-specific stats
  (4050 durability, `farm := 75`, drop-off 680/700) distinct from e.g. Austria `:2377`,
  France `:2378`, England `:2379`.
- `locale\en\units.txt:1077-1085` — the `.ext` tooltip for `turcen` reads *"Builds peasants.
  Peasants deliver stone, wood and food to the Town Hall ... Can be captured by the enemy"*;
  `algcen.ext` and `ruscen.ext` both `%include(units;turcen.ext)%`. So `ruscen` is the Russian
  Town Hall by the donor's own localisation.
- `objects\buildings\ruscen.prop` — `CustomName = ruscen`, `BaseName = ruscen`,
  `LODActorName = ruscen`, `DefaultMeshName = ruscen.mesh`, materials `ruscen` (summer) /
  `ruscenw` (winter).
- `actors\buildings\rus\ruscen.actor` — `ActorList.Items[0].Name = ruscen.mesh` and
  `...MeshObjects.LoadFromFile = .\data\actors\buildings\rus\ruscen.osm`; build stages
  `ruscen1.osm`..`ruscen4.osm`, ruin meshes `ruscen_death1.osm`/`ruscen_death2.osm`
  (all present in `actors\buildings\rus\`).
- Almanac `building_mechanics_evidence.md` explicitly names **"Russia Town Hall (`ruscen`)"**
  and **"Bavaria Town Hall (`bavcen`)"**, and lists `scocen`, `swecen` as Town Halls — i.e. the
  per-nation `<prefix>cen` convention (OBSERVED at URL).

**Mesh name answer:** Russia uses sid **`ruscen`**, mesh **`ruscen.mesh`** loaded from
**`data\actors\buildings\rus\ruscen.osm`** (609,492 bytes; build stages `ruscen1..4.osm`).

### Finding A2 — every playable nation has its OWN distinct hall mesh
**OBSERVED.** 21 `<prefix>cen.actor` + `<prefix>cen.osm` files exist, one per nation prefix
(algcen, auscen, bavcen, dencen, engcen, fracen, huncen, netcen, piecen, polcen, porcen,
prucen, **ruscen**, saxcen, scocen, spacen, swecen, swicen, turcen, ukrcen, vencen).
They are genuinely different binaries, not aliases — e.g. `ruscen.osm` 609,492 B,
`engcen.osm` 1,386,780 B, `fracen.osm` 548,244 B, `auscen.osm` 538,500 B,
`bavcen.osm` 491,740 B. `objects\buildings\buildings.objects` registers each `<prefix>.prop`.
So Russia's hall is **not** the generic European hall; the donor gives Russia a unique mesh.

### Finding A3 — the hall is NOT `rushou` (Izba)
**OBSERVED.** `locale\en\units.txt:1095-1098`: `@rushou -> "Izba"`, `@ukrhou -> "Hut"` —
these are the *house* (`csid+'hou'`, `gc_ai_unit_house`, country.script:2824), a different
building class from the Town Hall (`csid+'cen'`). Do not substitute `rushou` for `ruscen`.

### Finding A4 — exact engine call that spawns the initial hall at map start
**UNVERIFIED.** `scripts\common.inc\dogenerate.inc` places starting positions and 18
starting peasants (`CreateStartPointPeasants`, almanac map_generation_evidence.md §7) but the
actual Town-Hall spawn appears engine-side; the one scripted hook,
`dogenerate.inc:230,1919 CreateUniqueStartingUnits`, is present as commented text
(`[*] = ;` prefix) in this installed copy. The almanac describes a "Town Hall area" with
guaranteed nearby resources but does not expose a spawn line either. What *is* observed is the
nation→hall **rule** (Finding C1) and the hall's classification (Finding A1); the literal
spawn call is not pinned to a path:line. (The almanac's `ratuse` in the resource model is a
simulation placeholder, not a donor sid — no match in `data\scripts`, verified by grep.)

## 3. (b) Are peasants nation-specific?

### Finding B1 — YES: 8 distinct peasant sids, each with its own mesh, animation and texture
**OBSERVED.** `scripts\lib\country.script:2654-2662` maps nations to peasant sids:

| Peasant sid | Nations (OBSERVED, country.script:2655-2662) | EN name (locale\en\units.txt) |
|---|---|---|
| `peaaus` | aus, pru, bav, sax, swi | Peasant (`:471`) |
| `peaukr` | ukr | Peasant (`:478`, "cannot be captured") |
| `pearus` | **rus** | **Serf** (`:488-489`) |
| `peapol` | pol, hun | Peasant (`:492`) |
| `peaspa` | spa, ven, por, pie | Peasant (`:496`) |
| `peaeng` | fra, eng, swe, den, net | Peasant (`:500`) |
| `peatur` | tur, alg | Peasant (`:484`) |
| `peasco` | sco | Peasant (`:1231`) |

Each sid is a **separate asset triplet** in the donor:
- `actors\units\pea<X>.actor` → `...MeshObjects.LoadFromFile = .\data\actors\units\pea<X>.oss`
  and `Animations.LoadFromFile = .\data\animations\aaf\pea<X>.aaf` — verified for all 8
  (peaaus, peaeng, peapol, pearus, peasco, peaspa, peatur, peaukr).
- The 8 `.oss` are distinct binaries with different byte sizes: peaaus 293,664; peaeng
  366,312; peapol 368,008; **pearus 338,128**; peasco 285,760; peaspa 285,608; peatur
  317,456; peaukr 312,376. The 8 `.aaf` files likewise exist per nation.
- `materials\units\units.mat:324-350,579-580` defines 8 distinct materials each bound to its
  own texture: `pearus -> .\data\materials\units\pearus.dds`, `peaeng -> peaeng.dds`,
  `peaukr -> peaukr.dds`, etc. (all `pea*.dds` present).

### Finding B2 — Russian peasant is not merely renamed, it has different stats/form data
**OBSERVED.** `scripts\lib\unit.script:1190-1214` lists all 8 peasant sids in one shared stat
block, then applies nation overrides: `'rus' : begin ... consume[food] := 26` (vs generic 32
at `:1197`) and a different `SearchBuildVisionScore`; `'ukr' : bcapture := False`. The EN
locale calls `pearus` **"Serf"** while every other nation is "Peasant"
(`locale\en\units.txt:488-503`). The almanac `peasant_extraction.md` table gives the Russian
Serf a different food work-cycle (23 frames / 0.7188 g-s vs 22 frames / 0.6875 for most
nations).

### Finding B3 — exact silhouette / uniform difference by pixel
**UNVERIFIED.** The `.oss` files are compiled binary meshes (first bytes are non-text); I did
not decode vertices or render two peasants side by side, and no donor GPU A/B frame exists in
this swarm. Distinct mesh/animation/texture **assets** are OBSERVED (B1); the precise visual
silhouette/colour difference is INFERRED from those assets, not pixel-observed. Do not claim a
specific hat/colour/shape without a donor render.

### Finding B4 — native (RU) names in the installed locale
**UNVERIFIED.** `locale\ru\units.txt` / `units.lng` contain `?` placeholders in place of
Cyrillic letters under every encoding tried (cp1251, UTF-8, UTF-16), e.g. `@pearus -> ??????????`.
The trustworthy human name is the EN "Serf"/"Peasant" from Finding B1.

## 4. (c) The exact donor rule assigning starting buildings / units to a nation

### Finding C1 — buildings: `csid + <role suffix>`, with `cen` = Town Hall
**OBSERVED.** `scripts\lib\country.script`:
- `:2571` `procedure _country_Init(var country : TCountry; var csid : String)` — `csid` is the
  caller-supplied nation SID; `:2577-2579` `cid := _country_GetIDBySID(csid); country.sid := csid`.
- `:2822-2833` the building block:
  ```
  _country_AddMember(country, csid+'cen', ... gc_ai_unit_center);   // Town Hall
  _country_AddMember(country, csid+'hou', ... gc_ai_unit_house);    // house (Izba/Hut)
  _country_AddMember(country, csid+'bla', ... gc_ai_unit_smith);    // blacksmith
  _country_AddMember(country, csid+'sta', ... gc_ai_unit_stable);
  _country_AddMember(country, csid+'tem', ... gc_ai_unit_temple);
  _country_AddMember(country, csid+'aca', ... gc_ai_unit_academi);
  _country_AddMember(country, csid+'dip', ... gc_ai_unit_dipcenter);
  _country_AddMember(country, csid+'bar', ... gc_ai_unit_ba17);
  _country_AddMember(country, csid+'art', ... gc_ai_unit_artdepo);
  if (not tur) and (not alg) and (not ukr) then _country_AddMember(..., csid+'ba2'...);
  ```
  So for Russia the set is `ruscen, rushou, rusbla, russta, rustem, rusaca, rusdip, rusbar,
  rusart, rusba2` — each a distinct mesh set under `actors\buildings\rus\`.
- `:2926-2940,2954,3397` all production/drop-off/garrison links resolve through `csid+'cen'`
  (e.g. house and blacksmith require the Town Hall; `garr_BuildingsAll[0] := csid+'cen'`).
- `:2641` and `player.script:2622` build the static upgrade id as `csid+'cen'+'.1'`.

### Finding C2 — shared/national "common" buildings use a 3-way family prefix
**OBSERVED.** `country.script:2645-2652`:
```
if (rus) or (ukr) then commonName := 'rus'
else if (tur) or (alg) then commonName := 'tur'
else commonName := 'eur';
```
`:2835-2852` then adds common store/market/port objects as `commonName+'sto'` etc., with
exceptions (`:2839-2841` Poland uses `russto`; `:2843-2847` Spain/Portugal use `spamar`/
`spasto`). So the donor family split is `rus` / `tur` / `eur`, not one mesh per nation for
*every* building — but the **Town Hall is per-nation** (`csid+'cen'`).

### Finding C3 — units (peasants) use an explicit `if (nation)` table, NOT a suffix
**OBSERVED.** `country.script:2654-2662` (table in Finding B1). Infantry/other units use the
same style: e.g. `:2667` `if (rus) then 'pikemanrus'`, `:2693` `if (rus) then 'strelet'`,
`:2666` `if (pol) then 'pikemanpol'`, etc. Some units are shared across a family
(`:2685` one `'pikeman'` for fra/eng/spa/swe/pru/... ). So the donor rule is a **hybrid**:
nation-prefix concatenation for the standard building set, plus hand-authored `if (nation)`
branches for culturally specific units and family-shared meshes.

### Finding C4 — national starting army (non-default preset) is table-driven
**OBSERVED (partial).** `game\var\startingsettings.cfg` contains per-preset blocks with
`countrysid = rus` entries (e.g. `:1599-1604`, `:3078`) and role-tagged unit slots
(`role = 1` = officer/drummer family). Almanac `map_generation_evidence.md` §7/§0 states the
Default preset is **18 peasants** and a "national force" preset replaces them with an
Officer, Drummer and infantrymen. `dogenerate.inc:232,265-282` (`CreateUniqueStartingUnits`)
reads `gMap.players[plind].csid`, resolves `cid := _country_GetIDBySID(csid)` and filters
`allowedcountries` by that id — but in the installed copy this procedure's body is commented
(`[*] = ;`), so the *live* execution path is UNVERIFIED (version skew between almanac and
installed scripts). Either way it is a separate layer from the always-present Town Hall rule.

### Finding C5 — concise donor rule statement
**OBSERVED for the building/peasant assignment; derived label for the "initial" wording:**
> A nation is identified by a 3-letter SID (`rus`, `ukr`, `eng`, …, country.script:7-41).
> On country init (`_country_Init(country, csid)`) the donor builds that nation's object set by
> concatenating the SID with role suffixes — `csid+'cen'` is the Town Hall/center — and picks
> the peasant (and culturally specific infantry) through explicit `if (nation)` branches.
> Russia therefore gets `ruscen`/`ruscen.osm` as its hall and `pearus`/`pearus.oss` ("Serf")
> as its peasant; no other nation shares those two sids.

## 5. Evidence ledger

| # | Claim | Label | Citation |
|---|---|---|---|
| A1 | Russia hall sid `ruscen`, mesh `ruscen.mesh`←`ruscen.osm` | OBSERVED | `country.script:15,2823`; `unit.script:2368-2384`; `actor ruscen.actor`; `ruscen.prop`; `locale/en/units.txt:1077-1085` |
| A1 | Almanac names "Russia Town Hall (`ruscen`)" | OBSERVED | `.../internals_en/scripts/building_mechanics_evidence.md` (URL §1) |
| A2 | 21 distinct `<prefix>cen.osm`; `ruscen.osm` 609,492 B ≠ `engcen.osm` | OBSERVED | `actors/buildings/*/<prefix>cen.actor|.osm` (directory listing + byte sizes) |
| A3 | `rushou`=Izba is a house, not the hall | OBSERVED | `locale/en/units.txt:1095-1098`; `country.script:2824` |
| A4 | Literal spawn call for initial hall | UNVERIFIED | `dogenerate.inc:230,1919` commented; engine-side |
| B1 | 8 nation-specific peasant sids, each own `.oss`/`.aaf`/`.dds` | OBSERVED | `country.script:2654-2662`; `actors/units/pea*.actor`; `materials/units/units.mat:324-350,579-580` |
| B2 | `pearus`="Serf", food consume 26 vs 32 | OBSERVED | `locale/en/units.txt:488`; `unit.script:1190-1214`; almanac `peasant_extraction.md` |
| B3 | Pixel-level silhouette/uniform difference | UNVERIFIED | `.oss` are binary; no donor render (binary header inspected) |
| B4 | RU locale names | UNVERIFIED | `locale/ru/units.txt|units.lng` show `?` placeholders |
| C1 | `csid+'cen'` building rule | OBSERVED | `country.script:2571,2577-2579,2822-2833,2926-2940,3397` |
| C2 | `rus`/`tur`/`eur` family prefix for common buildings | OBSERVED | `country.script:2645-2652,2835-2852` |
| C3 | Peasant/units via `if (nation)` branches | OBSERVED | `country.script:2654-2662,2666-2693` |
| C4 | National starting-army table | OBSERVED / UNVERIFIED | `startingsettings.cfg:1599-1604,3078` OBSERVED; live path of `dogenerate.inc:230,1919` UNVERIFIED |
| — | ucoz build-stage page content | UNVERIFIED | URL 403 / HTTPS transport error; seed only at `CHARTER.md:105-107` |

## 6. Open questions (hand to N04/N05/COORD)
1. Does our port's Russian starting hall resolve to `ruscen.osm`, or to a shared/`engcen`-style
   mesh? (N01's job — this report only supplies donor truth.)
2. Do our starting peasants resolve one shared form for all nations, or the 8 donor sids?
   (N03.)
3. Which exact variant does the installed build use for the starting-army rule — the live
   table in `startingsettings.cfg`, or the commented `CreateUniqueStartingUnits` path?
4. Any pixel-level claim about the Serf's silhouette needs a donor render; none exists here.

## 7. Closing statement
This report documents donor structure only. It contains **no donor asset copies** and makes
**no donor-parity claim** for the port. All port-side associations are explicitly out of scope
(N01/N03). UNVERIFIED items are flagged rather than asserted.

*End of N02.*
