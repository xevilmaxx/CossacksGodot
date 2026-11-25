---
id: WAVE-N-N07
ticket: "N07 (Wave N) — COMPLETE donor->port asset gap matrix for ALL nations"
title: "N07 — all-nation building/unit asset matrix, converter capability, minimal per-nation tranche"
owner: N07 subagent
created: 2026-11-25
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_RUNNER__NO_CODE_EDIT__NO_DONOR_COPY__NO_GODOT
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, "PORT APPROX"]
parity_guard: "No donor GPU A/B frame exists (CHARTER.md:57-58, :122-130). 'Donor-derived' = file/byte provenance only, never a rendered-look claim. No Godot was launched, no runner job submitted, no donor file copied into the repo or executed."
scope: "Only this report is written in the repo. Read-only donor bytes/text at C:\\Games\\Cossacks 3; read-only port files; throwaway probe scripts in %TEMP%\\opencode."
supersedes: "N06_nation_conversion.md (Russia-only scope) for all-nation scope; N06 remains the authoritative exact-additive-manifest design and is incorporated by reference."
priors_read: [WAVE_G_CHARTER.md, CHARTER.md, N01_nation_building_audit.md, N03_peasant_forms.md, N06_nation_conversion.md, Z03_donor_relief_props.md, Z05_relief_prop_conversion.md, NATION_DONOR_01.md, NATION_MODEL_01.md, DEC_04_anim_formats.md]
---

# N07 — complete donor→port asset gap matrix, all nations

> [!IMPORTANT]
> **Labels.** **OBSERVED** = literal file:line, decoded donor byte, or direct on-disk
> listing read this pass. **DERIVED** = deterministic consequence of observed code/data.
> **INFERRED** = reading without a pixel-aligned donor A/B. **UNVERIFIED** = not provable
> with the instruments available (engine-side resolution, visuals, runtime skin form).
> Donor paths are under `C:\Games\Cossacks 3\`; port paths under the repo root.
> **No donor parity claim anywhere in this report.**

## 0. Direct answer

**OBSERVED + DERIVED (byte-level, all 21 nation keys in `data.gd:278-290`).**

1. **Buildings.** The port converts **17** core building sids from a **single nation's**
   donor art: 8 own-family sids from `ukr/*` (`cen hou bar sta bla aca art dip`),
   6 common-family sids from `commoneur/eur*` (`sto mil mar tow wal gat`), and 3 mines
   from `env` (`mine_gold/iron/coal`). `bar18` and `dock` have **no** OBJ at all.
   The donor has a distinct hall mesh+albedo for **21/21** nations
   (`<nat>cen.osm` + `<nat>cen.dds`), a distinct own-family set for **20/21** nations
   (Algeria only has `cen`/`hou`), and 18 nations with the `ba2` barracks variant.
   **Zero** nation-prefixed building OBJs exist in the port (280 OBJs, all unprefixed).
   Every non-Ukrainian nation therefore renders Ukrainian/European-derived art.
2. **Units.** The port converts **62** unit sids from **62** donor `.oss` bases, but
   only **one** nation peasant (`peasant ← peaukr`) and no nation variants for most
   soldier/officer/drummer families. The donor has **8** distinct peasant
   `.oss/.dds/.aaf` sets and **72** nation-specific `.oss` files that were never
   converted (including `pikemanrus`, `officerrus`, `drummerrus`,
   `musketeer18bav`, `grenadierbav`, `guardcavalrysax`, `hussarpru`, `jagerpor`,
   `dragoon18pie`, `pearus`, …). `skin/index.json` registers 55 skins + 7 skipped
   ship hulls; **no** nation peasant skin is registered.
3. **Converter capability is not the blocker.** `convert_models.py:48-107` already
   reads every IDP2 `.osm` and every 24-byte-header `.oss` correctly: fresh pass
   parsed **39/39** targeted assets, **335/335** `.oss` files reach exact size closure
   (all `fps=30`), and **246/246** `.aaf` files parse with declared count = row count
   (1,434 morph rows). The blocker is **enumeration** — hard-coded tables
   (`:165-496`) name exactly one nation for buildings, one peasant base, seven ships,
   and no nation variants. Same root cause as Z05 R1/Z05 §2.1 for relief props and
   N06 §0 for Russia.
4. **Minimal per-nation set** (§6): 21 nation halls + 8 peasant bases (7 new besides
   `peaukr`) + one signature unit per nation (13 new, 8 already converted). Phased:
   T0 = four default nations first (§6.1), T1 = remaining 17, T2 = common buildings/stages.

**Scope note.** The owner's ticket says "all 20 nations"; the port's `NATIONS` table
actually has **21** keys (`data.gd:278-290`: aus, fra, eng, spa, rus, ukr, pol, swe,
pru, ven, tur, alg, net, den, por, pie, sax, bav, hun, swi, sco). This report covers
**all 21**; the extra key is likely `ven`/`pie` or the DLC `sco`. Donor `country.script`
also has pseudo-nations (`tat`, `lit` at `:131-132`) that are not buildable `NATIONS`
keys and are out of scope.

---

## 1. Baseline inventory (OBSERVED this pass)

| Store | Count / content | Evidence |
|---|---|---|
| Port nations | **21** keys; `PLAYER_NATIONS = ["rus","bav","pol","swe"]` | `variant3d/scripts/data.gd:278-290, 208` |
| Port building sids | **19** core: `cen hou bar bar18 dip sta bla aca sto mil mar art wal gat mine_gold mine_iron mine_coal tow dock` | `data.gd:1304+` (extracted by brace-depth parse this pass) |
| Port unit keys | **62** in `UNITS_BASE` (incl. 7 ships); **8** nations in `NATION_UNITS` | `data.gd:638+`, `:294-306` |
| Port converted models | **280** manifest entries / **280** OBJs: 62 unit, 125 building (17 base + 108 stage), 93 env | `variant3d/assets/models/manifest.json` (`game=C:\Games\Cossacks 3`); OBJ directory census |
| Port skins | `skin/index.json`: `count=55`, `total_bytes=3,720,747`, 55 `entries` + 7 `skipped` ships + 0 `failed`; one peasant entry (`peasant` ← `peaukr`, 577 verts, 20 bones, `k=483`, 30 frames) | `variant3d/assets/models/skin/index.json:1`; N03 §4; N06 §2.2 |
| Nation-prefixed port OBJs | **0** of 280 (`rus*`, `bav*`, `ukr*`, `tur*`, `eur*`, `pol*`, `swe*`, `sco*`, `fra*`, …). Only `sco_highlandersword.obj`/`spakh.obj` start with nation-like stems but are roster unit sids. | OBJ filename census this pass; N01 §2 row 6 |
| Donor building folders | **25**: 21 national + `commoneur`, `commonrus`, `commontur`, `mis` | `C:\Games\Cossacks 3\data\actors\buildings\` listing |
| Donor unit binaries | **126** `.oss`, **65** `.osm`, **121** unit `.dds`; **335** `.oss` total under `data/actors` | recursive census this pass |
| Donor animation | **246** `.aaf` recursively (194 top-level + `pfx`), **1,434** morph rows, all parse | this pass; DEC-04 §4.3; DANIM-01 `:87-91`; SWARM_BOARD.md:61 |
| Donor peasants | **8** `.oss`+`.dds`+`.aaf`: `pearus peaukr peapol peaaus peaeng peaspa peatur peasco` | directory listing + `country.script:2655-2662,2915-2922` |

---

## 2. Can `convert_models.py` parse the nation assets? — YES (OBSERVED, fresh)

| Capability | Code | Fresh evidence this pass | Label |
|---|---|---|---|
| `.oss` reader (header `<6i`, 24 B; verts/faces/uvs/uv-faces/weights/bone-major animation) | `convert_models.py:48-71` | 335/335 `.oss` under `data/actors` read to **exact size closure** (0 anomalies); header `fps` = **30** on all 335 | OBSERVED (fresh) |
| `.osm` reader (IDP2 `<17i`, 68 B header, `<3f I>` vertices, `(0,2,1)` winding swap) | `:74-99`; `read_mesh()` magic dispatch `:102-107` | 39/39 targeted `read_mesh()` calls succeeded (21 `<nat>cen.osm`, 8 peasant `.oss`, 10 signature `.oss`); relief props independently confirmed 8/8 exact closure in Z05 §1 | OBSERVED (fresh) |
| `.aaf` action ranges (line 2 declared count, rows `"name",first,last,morph`) | consumed by `convert_skins.py:208-227` (per N06 §2.2) | 246/246 files have declared count == morph-row count; 1,434 rows; 0 anomalies. Core peasant ranges identical across all 8 (`idle 64..113`, `walk 1..20`, `death 115..149`, `attack0 237..254`, `construct 186..198`); non-core differ (`workfood` `pearus 281..304`, `peapol 278..301`, others `278..299`) — N06 §1.3 | OBSERVED (fresh + N06) |
| Format documentation / bind-pose status | DEC-04 §4.1/§4.2/§4.3, `decomp/SUMMARY.md:82-92`; `SWARM_BOARD.md:61` ("335/335 exact size closure … 246/246 parse"); `CORRECTIONS.md:60,98` (DEC-04 frame-0 claim refuted by DANIM-01: frame 0 **is** bind in 335/335) | cited | OBSERVED (docs) / UNVERIFIED (native skin form) |

**Critical distinction (DERIVED).** Parseability is format-level; conversion is
enumeration-level. `main()` (`:519-520`) builds its model list from five hard-coded
tables: `unit_models()` `:165-243` (one peasant base `peaukr`, 62 port sids),
`building_models()` `:246-297` (8 `ukr*`, 6 `eur*`, 3 env mines), `ship_models()`
`:384-409` (7 hulls), `env_models()` `:412-496`, `stage_models()` `:300-381`
(108 stages, all `ukr*`/`eur*`). Nothing enumerates nation variants. Adding an asset
requires a new table row + a manifest entry; no reader/writer change is needed.
Identical conclusion in N06 §0/§2 (Russia), Z05 §2.1 (relief props).

**No parser limitation found for any nation asset.** The only format caveat is N06 B5:
`pearus.oss` has `k=486` while the other seven have `483`, so any hard-coded 483-frame
ceiling would drop late frames; `convert_skins.py` derives ranges per AAF (`:215-227`),
so this is a consumer rule to verify, not a converter defect.

---

## 3. Building gap matrix — every port sid × every nation

### 3.1 Core buildings: converted provenance vs donor availability

Donor prefix rule (OBSERVED, `country.script:138-206`, re-read this pass):
own families `aca/art/ba2/bar/bla/cen/dip/hou/sta/tem` → `<nat><family>`;
`%com%` families `mil/por/tow/wwa/swa/sto/mar/gol/iro/coa`, with overrides
`por`: ukr→ukr, rus→rus, tur/alg→tur, por→por, else eur;
`mil/tow/swa`: rus/ukr→rus, tur/alg→tur, else eur;
`wwa`→ukr; `sto/mar`: rus/ukr→rus, tur/alg→tur, spa/por→spa, else eur;
`blg/blg2`→mis.

| Port sid | Converted OBJ ← donor source (manifest) | Correct donor family / prefix | Nation-specific donor `.osm`+`.dds` available | Verdict |
|---|---|---|---|---|
| `cen` (Town Hall) | `cen.obj` ← `actors/buildings/ukr/ukrcen.osm` + `materials/buildings/ukr/ukrcen.dds` (M:1050-1056) | own `cen` → `<nat>cen` | **21/21** nations have `<nat>cen.osm` + `<nat>cen.dds` (full list §3.2) | **MISMATCH for 20 nations**; Russia gets `ukrcen` (N01 §1) |
| `hou` | `hou.obj` ← `ukr/ukrhou.*` (M:1069) | own `hou` | **21/21** | MISMATCH for 20 |
| `bar` | `bar.obj` ← `ukr/ukrbar.*` (M:1088) | own `bar` | **20/21** (no `algbar`; Algeria has only `cen/hou`) | MISMATCH for 20 |
| `sta` | `sta.obj` ← `ukr/ukrsta.*` (M:1107) | own `sta` | 20/21 (no alg) | MISMATCH for 20 |
| `bla` | `bla.obj` ← `ukr/ukrbla.*` (M:1126) | own `bla` | 20/21 (no alg) | MISMATCH for 20 |
| `aca` | `aca.obj` ← `ukr/ukraca.*` (M:1145) | own `aca` | 20/21 (no alg) | MISMATCH for 20 |
| `art` | `art.obj` ← `ukr/ukrart.*` (M:1164) | own `art` | 20/21 (no alg) | MISMATCH for 20 |
| `dip` | `dip.obj` ← `ukr/ukrdip.*` (M:1259) | own `dip` | 20/21 (no alg) | MISMATCH for 20 |
| `sto` (storehouse) | `sto.obj` ← `commoneur/eursto.*` (M:1183) | common `sto` | `russto`/`eursto`/`tursto`/`spasto` all exist (§3.3) | MISMATCH for rus/ukr/tur/alg/spa/por (port always `eur`) |
| `mil` (mill) | `mil.obj` ← `commoneur/eurmil.*` (M:1202) | common `mil` | `rusmil`/`eurmil`/`turmil` exist | MISMATCH for rus/ukr/tur/alg |
| `mar` (market) | `mar.obj` ← `commoneur/eurmar.*` (M:1221) | common `mar` | `rusmar`/`eurmar`/`turmar`/`spamar` exist | MISMATCH for rus/ukr/tur/alg/spa/por |
| `tow` (tower) | `tow.obj` ← `commoneur/eurtow.*` (M:1240) | common `tow` | `rustow`/`eurtow`/`turtow` exist | MISMATCH for rus/ukr/tur/alg |
| `wal` (stone wall) | `wal.obj` ← `commoneur/eurswa.osm`, texture `commonrus/eurswa.dds` (M:1278) | common `swa` | `eurswa`/`russwa`/`turswa`/`ukrwwa` meshes exist; **all** their albedos live in `commonrus/` (split folder — no missing art) | MISMATCH for rus/ukr/tur/alg |
| `gat` (gate) | `gat.obj` ← `commonrus/eurswa_gate.osm` + `commonrus/eurswa.dds` (M:1297) | common `swa_gate` | `eurswa_gate`/`russwa_gate`/`turswa_gate`/`ukrwwa_gate` exist in `commonrus/` | MISMATCH for rus/ukr/tur/alg |
| `mine_gold` | `mine_gold.obj` ← `env/minegold.*` (M:1316) | env prop, **no nation prefix** | `data/actors/env/minegold.osm` + `data/materials/env/minegold.dds` | NO nation mismatch (env-keyed); UNVERIFIED whether generator picks nation-specific ore props |
| `mine_iron` | `mine_iron.obj` ← `env/mineiron.*` (M:1335) | env prop | exists | same |
| `mine_coal` | `mine_coal.obj` ← `env/minecoal.*` (M:1354) | env prop | exists | same |
| `bar18` | **NO manifest entry, NO OBJ** | own `ba2` (18/21 nations have `<nat>ba2.osm/.dds`; **ukr, tur, alg do not**) | donor art exists for 18 nations | **MISSING** in port; 2D has `rus_bar18`/`bav_bar18` sheets (N01 §3C) |
| `dock` | **NO manifest entry, NO OBJ** | donor `por` (shipyard) family exists as `eurpor/ruspor/turpor/ukrpor/porpor` | donor art exists (5 families) | **MISSING** in port; no donor `dock` actor (convert_models.py:279-280) |
| `yachttur` | `yachttur.obj` ← `actors/units/yachttur.osm` (M:1392) | distinct Turkey ship sid, family-keyed hull | donor `.osm` exists | CORRECT-BY-IDENTITY (not a skin); N01 §3D |

**Stage art.** 108 stage/scaffold entries (`cen1..4`, `cen1a..4a`, `cena`, … for 12
sids) are converted from the **same** `ukr*`/`eur*` donor folders
(`convert_models.py:300-381`, manifest `:3273+`). They are therefore nation-blind;
even after adding a nation hall OBJ, build/ghost stages still show Ukrainian art
(N06 B3, N01 §2 row 7).

### 3.2 All-nation hall availability (OBSERVED this pass)

Every nation has a distinct hall mesh+albedo in the donor; none is converted.

| Nation | Donor hall mesh (bytes) | Donor albedo | Port OBJ |
|---|---|---|---|
| aus | `data\actors\buildings\aus\auscen.osm` (538,500) | `data\materials\buildings\aus\auscen.dds` | none (`cen.obj` = ukrcen) |
| fra | `…\fra\fracen.osm` (548,244) | `…\fra\fracen.dds` | none |
| eng | `…\eng\engcen.osm` (1,386,780) | `…\eng\engcen.dds` | none |
| spa | `…\spa\spacen.osm` (886,588) | `…\spa\spacen.dds` | none |
| rus | `…\rus\ruscen.osm` (609,492) | `…\rus\ruscen.dds` | none |
| ukr | `…\ukr\ukrcen.osm` (227,428) | `…\ukr\ukrcen.dds` | `cen.obj` (Ukrainian base) |
| pol | `…\pol\polcen.osm` (645,884) | `…\pol\polcen.dds` | none |
| swe | `…\swe\swecen.osm` (663,572) | `…\swe\swecen.dds` | none |
| pru | `…\pru\prucen.osm` (685,748) | `…\pru\prucen.dds` | none |
| ven | `…\ven\vencen.osm` (1,356,308) | `…\ven\vencen.dds` | none |
| tur | `…\tur\turcen.osm` (338,660) | `…\tur\turcen.dds` | none |
| alg | `…\alg\algcen.osm` (224,412) | `…\alg\algcen.dds` | none |
| net | `…\net\netcen.osm` (759,796) | `…\net\netcen.dds` | none |
| den | `…\den\dencen.osm` (1,147,412) | `…\den\dencen.dds` | none |
| por | `…\por\porcen.osm` (2,403,756) | `…\por\porcen.dds` | none |
| pie | `…\pie\piecen.osm` (1,700,028) | `…\pie\piecen.dds` | none |
| sax | `…\sax\saxcen.osm` (287,972) | `…\sax\saxcen.dds` | none |
| bav | `…\bav\bavcen.osm` (491,740) | `…\bav\bavcen.dds` | none |
| hun | `…\hun\huncen.osm` (684,500) | `…\hun\huncen.dds` | none |
| swi | `…\swi\swicen.osm` (418,820) | `…\swi\swicen.dds` | none |
| sco | `…\sco\scocen.osm` (270,708) | `…\sco\scocen.dds` | none |

`ruscen` vs `ukrcen` are genuinely different geometry (15,348 v / 9,936 f vs
5,611 v / 3,714 f; distinct bboxes) — N06 §1.1. The same is structurally true for
every other nation (byte sizes above all differ); **visual silhouette UNVERIFIED**.

### 3.3 Own-family availability per nation (OBSERVED)

Families present as both `<nat><fam>.osm` and `<nat><fam>.dds`:

| Family | Coverage | Nations missing it |
|---|---|---|
| `cen`, `hou` | 21/21 | — |
| `bar`, `sta`, `bla`, `aca`, `art`, `dip`, `tem` | 20/21 | `alg` (Algeria only ships `cen`/`hou`) |
| `ba2` (→ port `bar18`) | 18/21 | `ukr`, `tur`, `alg` |

Winter albedos (`<nat><fam>w.dds`) exist for every family above; the converter emits
only the summer albedo (N06 §1.4, Z05 R4). Season material selection is engine-side /
UNVERIFIED (`country.script` sidmask `UseSeasonMaterial` per NATION_DONOR_01 R4).

### 3.4 Common-family resolved prefix per nation (OBSERVED from `country.script:138-206`)

`*)` = donor `.osm` + `.dds` both present at the resolved prefix; `?` = mesh present
but albedo lives in a different folder (`commonrus`), not an absent asset.

| Nation | `mil`/`tow` | `sto`/`mar` | `por` | `swa` (wall/gate) |
|---|---|---|---|---|
| rus | `rus*` | `rus*` | `rus*` | `russwa*` mesh in `commonrus`, tex in `commonrus` |
| ukr | `rus*` | `rus*` | `ukr*` | `ukrwwa*` (wall family, mesh+tex `commonrus`) |
| tur | `tur*` | `tur*` | `tur*` | `turswa*` |
| alg | `tur*` | `tur*` | `tur*` | `turswa*` |
| spa / por | `eur*` | `spa*` | `eur*` / `porpor` | `eurswa?` |
| all other 15 | `eur*` | `eur*` | `eur*` | `eurswa?` |

Port converts only `eur*` for all of these; no `rus*`/`tur*`/`spa*`/`por*` common-family
OBJ exists. **MISMATCH** for the 6 nations with non-`eur` resolutions (rus, ukr, tur,
alg, spa, por) in `sto/mar/por`; for 4 (rus, ukr, tur, alg) in `mil/tow/swa`.

---

## 4. Unit gap matrix — every `UNITS_BASE` key

Columns: port sid → donor `.oss` base (manifest) → donor nation variants present
(`.oss`; the same stem has matching `.dds` and `.aaf` unless noted) → port OBJ + skin
entry → verdict. `*` marks a nation suffix. All 62 port sids have a manifest entry, an
OBJ and (for non-ships) a skin entry; the gap is **which nation's** art was converted.

### 4.1 Peasants and worker variants

| Port sid | Donor base | Donor nation variants | Port OBJ / skin | Verdict |
|---|---|---|---|---|
| `peasant` | `peaukr` | `peaaus* peaeng* peapol* pearus* peasco* peaspa* peatur* peaukr*` | `peasant.obj`, `peasant.json` ← `peaukr.oss/.dds/.aaf` (manifest:5-11; skin index:1) | **7 of 8 nation forms absent**; generic key is alias of Ukrainian (N03 §1/§4) |

Nation→peasant grouping (OBSERVED `country.script:2655-2662,2915-2922`, twice-declared):

| Donor peasant | Nations using it | Port 3D status |
|---|---|---|
| `pearus` | rus | absent (N06 proposes `pearus.obj`+skin) |
| `peaukr` | ukr | present as generic `peasant` |
| `peaaus` | aus, pru, **bav**, sax, swi | absent |
| `peapol` | pol, hun | absent |
| `peaspa` | spa, ven, por, pie | absent |
| `peatur` | tur, alg | absent |
| `peaeng` | fra, eng, swe, den, net | absent |
| `peasco` | sco | absent |

All 8 `.oss` files are distinct binaries with distinct bone/vertex/face counts and
byte-distinct `.dds` (N06 §1.2); AAF core action ranges are identical, non-core
ranges differ (§2). Bavaria/Sweden have no 2D `<nat>_peasant` sheet set and already
fall back to `peasant` in 2D (N03 M5, N06 §5) — adding 3D art for them would be an
owner decision (N06 B10).

### 4.2 Infantry, cavalry and support (soldiers / officers / drummers)

| Port sid | Donor base | Donor nation variants (unconverted marked `NEW`) | Port OBJ / skin | Verdict |
|---|---|---|---|---|
| `pikeman` | `pikeman` | `pikeman`, `pikemanpol NEW`, `pikemanrus NEW`, `pikemansco`, `pikemanspa NEW`, `pikemanpor NEW`, `pikemanswi NEW`, `pikemantur NEW` | `pikeman.obj/.json` ← `pikeman.*` | 6 nation variants absent; Scottish one converted |
| `roundshier` | `roundshier` | `roundshier` only | converted | no nation variants in donor |
| `serdiuk` | `serdiuk` | `serdiuk` only | converted | Ukraine-unique sid already converted |
| `archer` | `archer` | `archer`, `archersco`, `archertur NEW` | converted | 1 nation variant absent |
| `cossack` | `cossacksich` | `cossacksich` only | converted (`cossack.obj`) | Ukraine-unique; no variants |
| `dragoon` | `dragoon18` | `dragoon18`, `dragoon18fra NEW`, `dragoon18net NEW`, `dragoon18pie NEW` | converted | 3 variants absent |
| `officer` | `officer` | `officer`, `officerrus NEW`, `officersco`, `officertur NEW` | converted | 2 variants absent |
| `cannon` | `cannon` | `cannon` (plus death/wheel aux `.oss`, unconverted) | converted | no nation variants |
| `officer18` | `officer18` | `officer18` only | converted | — |
| `drummer` | `drummer` | `drummer`, `drummerrus NEW`, `drummertur NEW` | converted | 2 variants absent |
| `priest` | `priest` | `priest` only | converted | — |
| `grenadier` | `grenadier` | `grenadier`, `grenadierbav NEW`, `grenadierden NEW`, `grenadierhun NEW`, `grenadierpru NEW`, `grenadiersax NEW` | converted | **5 variants absent** |
| `musk18` | `musketeer18` | `musketeer18`, `musketeer18bav NEW`, `musketeer18den NEW`, `musketeer18pru NEW`, `musketeer18sax NEW` | converted | **4 variants absent** (Bavaria's unique musketeer among them) |
| `howitzer` | `howitzer` | `howitzer` | converted | — |
| `mortar` | `mortar` | `mortar` | converted | — |
| `musketeer` | `musketeer` | `musketeer`, `musketeeraus NEW`, `musketeernet NEW`, `musketeerpol NEW`, `musketeersco`, `musketeerspa NEW` | converted | 4 variants absent |
| `strelet` | `strelet` | `strelet` only | converted | Russia-unique musketeer already converted |
| `pikeman18` | `pikeman18` | `pikeman18`, `pikeman18swe NEW` | converted | Sweden's 18c pikeman absent |
| `dragoon17` | `dragoon` | `dragoon`, `dragoonpol NEW` | converted | 1 variant absent |
| `hussar` | `hussar` | `hussar`, `hussarhun NEW`, `hussarpru NEW`, `hussarswi NEW` | converted | 3 variants absent |
| `wingedhussar` | `wingedhussar` | only | converted | Poland-unique already converted |
| `cuirassier` | `cuirassier` | only | converted | — |
| `reiter` | `reiter` | `reiter`, `reiterpol NEW`, `reiterswe NEW` | converted | 2 variants absent |
| `lightcavalry` | `lightcavalry` | only | converted | — |
| `lightinfantry` | `lightinfantry` | only | converted | Turkey/Algeria use generic (roster `CS:2671,2676`) |
| `tatar` | `tatar` | only | converted | Turkey-unique |
| `sipahi` | `sipahi` | only | converted | Turkey-unique |
| `jannisary` | `jannisary` | only | converted | Turkey-unique |
| `spakh` | `spakh` | only | converted | Turkey-unique |
| `mameluke` | `mameluke` | only | converted | Algeria-unique |
| `vityaz` | `vityaz` | only | converted | Russia-unique |
| `hetman` | `hetman` | only | converted | Ukraine-unique (NATION_DONOR_01 C3 corrected) |
| `croat` | `croat` | only | converted | Austria-unique |
| `pandur` | `pandur` | `pandur`, `pandurhun NEW` | converted | 1 variant absent |
| `chasseur` | `chasseur` | only | converted | France-unique |
| `highlander` | `highlander` | only | converted | England-unique |
| `pope` | `pope` | only | converted | rus/ukr priest |
| `padre` | `padre` | only | converted | Piedmont priest |
| `mullah` | `mullah` | only | converted | tur/alg priest |
| `drummer18` | `drummer18` | only | converted | — |
| `multicannon` | `multicannon` | only (+ aux wheels unconverted) | converted | — |
| `cossackdon` | `cossackdon` | only | converted | Russia-unique |
| `hackapell` | `hackapell` | only | converted | Sweden-unique |
| `sco_highlandersword` | `swordsmansco` | only | converted | Scotland-unique (`bake_scottish.py:52-53`) |
| `cossackregister` | `cossackregister` | only | converted | Ukraine-unique |
| `bagpiper` | `bagpiper` | only | converted | Scotland/England |
| `pikemansco` / `swordsmansco` / `musketeersco` / `archersco` / `officersco` / `lancersco` / `raidersco` | same stems | `sco` only (plus non-sco variants of the shared stems, listed above) | all converted | Scotland set |
| `framegun` | `framegun` | only (+ aux wheels) | converted | — |

**Unconverted nation-specific `.oss` total: 72** (full list in §5.2), of which 7 are
peasants and 13 are the recommended signature units (§6).

### 4.3 Naval keys (7)

`yacht`, `fishboat`, `yachttur`, `galley`, `frigate`, `xebec`, `battleship` all convert
from IDP2 `.osm` hulls (`convert_models.py:384-409`, manifest `:1392+`); skins are
`skipped` (no skin tracks, V7-63). Hulls are family-keyed, not nation skins:
`yachttur` (Turkey) and `chaika` (Ukraine) are distinct sids. `chaika` has a donor
`.osm` + `.dds` + `.aaf` but **no** manifest entry/OBJ (NATION_DONOR_01 G12/C2).
No nation mismatch established for the 7 shipped hulls (OBSERVED code; donor basis
UNVERIFIED engine-side).

### 4.4 `NATION_UNITS` remaps (`data.gd:294-306`) — OBSERVED

| Nation | Remaps | Target sids converted? | Verdict |
|---|---|---|---|
| rus | `serdiuk→strelet`, `musketeer→strelet`, `cossack→cossackdon`, `dragoon→cossackdon`, `priest→pope` | all 3 targets present | Sim remap works, but Russia's *peasant* and *hall* are still Ukrainian |
| bav | `serdiuk→musketeer`, `cossack→hussar` | targets present but **generic**, not donor `musketeer18bav`/`grenadierbav` | NATION_MODEL_01 §8 item 3b: generic target, conservatively labelled fallback |
| ukr | `priest→pope` | present | partial |
| pol | `cossack→wingedhussar` | present | Poland gets a distinct cavalry mesh already |
| tur | `serdiuk/musketeer→jannisary`, `cossack/dragoon→sipahi`, `priest→mullah` | all present | Turkey distinct units already |
| alg | `serdiuk/musketeer→jannisary`, `cossack→mameluke`, `dragoon→spakh`, `priest→mullah` | all present | Algeria partly distinct |
| swe | `cossack→hackapell` | present | Sweden distinct cavalry |
| sco | `drummer→bagpiper`, `musketeer/serdiuk→sco_highlandersword` | present | Scotland distinct |

**UNVERIFIED engine-side (N03 M6 / N06 B2):** `sync()` samples animation with the raw
sim sid (`world3d_entities.gd:2111,2127-2142` per N06 §4.1), so a nation-remapped
static mesh can disagree with the morph/skin — latent today because remap targets are
converted sids, but it becomes active as soon as nation peasants are wired.

---

## 5. Complete unconverted donor asset register (later tranches)

### 5.1 Donor path families (exact, OBSERVED)

| Asset class | Exact donor path template | Converted by current `convert_models.py`? |
|---|---|---|
| Nation hall | `data\actors\buildings\<nat>\<nat>cen.osm` + `data\materials\buildings\<nat>\<nat>cen.dds` | only `ukr` (as `cen`) |
| Nation own-family building | `data\actors\buildings\<nat>\<nat><aca\|art\|ba2\|bar\|bla\|dip\|hou\|sta\|tem>.osm` + `data\materials\buildings\<nat>\<nat><fam>.dds` | only `ukr` 8 families |
| Common-family building | `data\actors\buildings\commoneur\eur<mil\|sto\|mar\|tow\|swa>.osm`, `commonrus\rus<mil\|sto\|mar\|tow\|swa>.osm`, `commontur\tur<mil\|sto\|mar\|tow\|swa>.osm`, `commonrus\<eur\|rus\|tur\|ukr>swa_gate.osm`; albedos mostly in `commonrus\` | only `eur*` (6 sids) |
| Nation peasant | `data\actors\units\pea<X>.oss` + `data\materials\units\pea<X>.dds` + `data\animations\aaf\pea<X>.aaf` | only `peaukr` (as `peasant`) |
| Nation soldier/officer/drummer | `data\actors\units\<base><nat>.oss` + `data\materials\units\<base><nat>.dds` + `data\animations\aaf\<base><nat>.aaf` | only 8 Scottish + selected nation-unique sids |
| Ship hull | `data\actors\units\<hull>.osm` + `data\materials\units\<hull>.dds` | 7 of 8 (`chaika` absent) |
| Mine | `data\actors\env\mine<gold\|iron\|coal>.osm` + `data\materials\env\mine<...>.dds` | 3 (env-keyed) |

### 5.2 All 72 unconverted nation-specific `.oss` (OBSERVED, this pass)

`archertur`, `cannon_death`, `cannon_wheel_left`, `cannon_wheel_right`,
`dragoon18fra`, `dragoon18net`, `dragoon18pie`, `dragoonpol`, `drummerrus`,
`drummertur`, `ferry`, `fishboat`, `framegun_death`, `framegun_wheel_left`,
`framegun_wheel_right`, `frigate`, `galley`, `gauduk`, `grenadierbav`,
`grenadierden`, `grenadierhun`, `grenadierpru`, `grenadiersax`,
`guardcavalrysax`, `howitzer_death`, `howitzer_wheel_left`, `howitzer_wheel_right`,
`hussarhun`, `hussarpru`, `hussarswi`, `jagerpor`, `jagerswi`, `kingmusketeer`,
`misdonkey`, `misflagman`, `misgeneral`, `mistrader`, `mortar_death`,
`mortar_wheel_left`, `mortar_wheel_right`, `multicannon_death`,
`multicannon_wheel_left`, `multicannon_wheel_right`, `musketeer18bav`,
`musketeer18den`, `musketeer18pru`, `musketeer18sax`, `musketeeraus`,
`musketeernet`, `musketeerpol`, `musketeerspa`, `officerrus`, `officertur`,
`pandurhun`, `peaaus`, `peaeng`, `peapol`, `pearus`, `peasco`, `peaspa`,
`peatur`, `pikeman18swe`, `pikemanpol`, `pikemanpor`, `pikemanrus`,
`pikemanspa`, `pikemanswi`, `pikemantur`, `reiterpol`, `reiterswe`,
`yacht`, `yachttur`.

(The last two and `ferry/fishboat/frigate/galley` are ship `.oss` crew/hull auxiliaries
already covered by `.osm` hull conversion or mission props — not a nation-art gap.)

---

## 6. MINIMAL additive set — one distinct hall + peasant + signature unit per nation

**Principle.** Additive only. Generate into a staging directory with a separate
manifest/index name, then text-insert entries **before** the current first entry so
all 280 existing manifest objects and 55 skin entries stay byte-identical (N06 §3,
Z05 §4). OBJ/MTL/PNG names **equal the donor sid** so the existing on-disk probe
(`world3d_entities.gd:686-692, 777`) can find them without inventing names.

### 6.1 Tranche T0 — four default nations (`config.gd:123-124`, `data.gd:208`)

| Nation | Hall donor (new OBJ) | Peasant donor (new OBJ+skin) | Signature unit donor (new OBJ+skin) | Already in port? |
|---|---|---|---|---|
| rus | `rus\ruscen.osm/.dds` → `ruscen.obj` | `pearus.oss/.dds/.aaf` → `pearus` | `pikemanrus.oss/.dds/.aaf` → `pikemanrus` (or reuse converted `strelet`) | peasant/hall/sig all new |
| bav | `bav\bavcen.osm/.dds` → `bavcen.obj` | `peaaus.oss/...` → `peaaus` (shared with aus/pru/sax/swi) | `musketeer18bav.oss/...` → `musketeer18bav` | all new |
| pol | `pol\polcen.osm/.dds` → `polcen.obj` | `peapol.oss/...` → `peapol` | `wingedhussar` **already converted** | hall+peasant new |
| swe | `swe\swecen.osm/.dds` → `swecen.obj` | `peaeng.oss/...` → `peaeng` (shared with fra/eng/den/net) | `pikeman18swe.oss/...` → `pikeman18swe` | all new |

T0 total: **4 halls + 3 peasants + 3 new signature units = 10 new OBJ/MTL/PNG triads**,
plus 3 new skin JSONs (peasants) + 3 (signature units).

### 6.2 Tranche T1 — remaining 17 nations

| Nation | Hall donor | Peasant donor | Signature unit donor | Signature already converted? |
|---|---|---|---|---|
| ukr | `ukrcen` (base `cen.obj` already converted) | `peaukr` (base `peasant.obj`; duplicate-or-alias choice N06 B12) | `serdiuk` / `hetman` | YES — keep |
| aus | `auscen` | `peaaus` (shared with bav) | `croat` / `pandur` | YES — keep |
| fra | `fracen` | `peaeng` (shared with swe) | `chasseur` | YES — keep |
| eng | `engcen` | `peaeng` | `highlander` / `bagpiper` | YES — keep |
| spa | `spacen` | `peaspa` | `musketeerspa.oss/...` (NEW) | NO |
| pru | `prucen` | `peaaus` | `musketeer18pru.oss/...` (NEW) | NO |
| ven | `vencen` | `peaspa` | **no donor-unique unit** (generic `pikeman`/`musketeer`); hall+peasant only | n/a |
| tur | `turcen` | `peatur` | `jannisary` / `spakh` | YES — keep |
| alg | `algcen` | `peatur` (shared with tur) | `mameluke` | YES — keep |
| net | `netcen` | `peaeng` | `musketeernet.oss/...` (NEW) | NO |
| den | `dencen` | `peaeng` | `musketeer18den.oss/...` (NEW) | NO |
| por | `porcen` | `peaspa` | `jagerpor.oss/...` (NEW) | NO |
| pie | `piecen` | `peaspa` | `dragoon18pie.oss/...` (NEW) | NO |
| sax | `saxcen` | `peaaus` | `guardcavalrysax.oss/...` (NEW) | NO |
| hun | `huncen` | `peapol` | `pandurhun.oss/...` (NEW) | NO |
| swi | `swicen` | `peaaus` | `jagerswi.oss/...` (NEW) | NO |
| sco | `scocen` | `peasco` | `swordsmansco` / `lancersco` | YES — keep |

T1 new-art counts: **17 halls + 4 peasants** (`peaspa`, `jagerpor` is a unit;
`peaeng/peaaus/peapol/peatur/peasco` — of these `peaspa` and `peasco` are new;
`peaeng/peaaus/peapol/peatur` land in T0/T1 as needed) + **8 new signature units**
(spa, pru, net, den, por, pie, sax, hun, swi = 9 if all; ven has none).

### 6.3 Tranche T2 — depth, not minimum

Common-family art per §3.4 (`rus*`, `tur*`, `spa*`, `porpor`, wall/gate variants),
construction stages per nation (9 stage OSMs per hall, N06 §1.4), winter albedos
(`<nat><fam>w.dds`), `chaika` (Ukraine ship), `bar18`/`dock` gaps. All need the
same additive-table + manifest-insertion discipline; none is required for "distinct
hall + peasant + signature unit".

### 6.4 Wiring prerequisites (proposal only — no edits made by N07)

- **Presentation-only nation map.** Add a donor-derived peasant/file map in
  `world3d_entities.gd:_entity_mesh_sid()` units branch (N06 §4.1); **do not** add
  `NATION_UNITS.peasant` — `resolve_sid()` rejects sids absent from `UNITS_BASE`
  (N06 B1, `data.gd:1565-1568`). Keep sim stats on `peasant`.
- **Animation sid.** Store the nation-resolved sid on the presentation slot and use
  it in `sync()` for `has_skin`/`pose_for`/`_morph_mesh` (N06 §4.1, N03 M6); keep
  per-nation AAF ranges, especially `pearus k=486` (N06 B5).
- **Labels.** Update `NATION_MESH_FALLBACK_STATUS`/`NATION_MESH_BLOCKED_EVIDENCE`
  (`world3d_entities.gd:206,213`) in the same change so telemetry stops claiming
  "0 prefixed OBJs" once art lands. Keep "visual UNVERIFIED".
- **Byte discipline.** Default converter run must remain the untouched 280-entry
  pipeline; use `--nation-art --manifest-name …` (N06 §2.1) / `--include-relief`
  (Z05 §2.3) style opt-in flags and text insertion. Never re-run into `manifest.json`.
- **No stage/ghost parity claim.** Stage meshes remain Ukrainian-derived until T2.

---

## 7. UNVERIFIED / open register

1. **On-screen appearance of any nation mesh** — no donor GPU A/B frame and no Godot
   run (CHARTER §3/§5). "Ukrainian-derived" is provenance, not a rendered-look claim.
2. **Engine-side actor-resolution fallback** when an actor/mesh is missing
   (NATION_DONOR_01 R7); `sidmask` helpers have no DScript caller (R8).
3. **Runtime season-material binding** (`UseSeasonMaterial` consumer) — engine-side.
4. **Exact geometry silhouette difference** for the 20 non-Ukrainian halls and
   non-`peaukr` peasants — byte-distinct assets are OBSERVED, visual difference
   INFERRED only (N06 §1.1/§1.2, Z05 R1).
5. **Rig fidelity.** Donor `.oss` bone-parent hierarchy is unreadable; port skins are
   flat-root PORT APPROX (DEC-04 §6, anim3d.gd:66, N03 §6, N06 B4).
6. **AAF per-nation runtime behaviour** (fps=30, action selection for `pearus k=486`,
   non-core `workfood` differences) — data OBSERVED, behaviour UNVERIFIED (N06 B5).
7. **Algeria's reduced building roster** (`cen/hou` only) — whether the port should
   model this as a gameplay limitation is an owner decision, not a donor-text fact.
8. **Venice/Piedmont signature units** — donor assigns generics (`CS:2685,2700,2720`);
   no donor-unique `.oss` exists, so "one signature unit" cannot be satisfied from
   donor art without invention. Hall + peasant is the honest minimum for those two.
9. **Whether the owner's "20 nations" excludes one specific key** — all 21 keys in
   `data.gd:278-290` are covered; no key was dropped.
10. **`bar18`/`dock` port omission** — donor art exists for `ba2` (18 nations) and
    `por` (5 variants) but port has neither; no donor actor is named `dock`
    (`convert_models.py:279-280`).

---

## 8. Claim register

| # | Claim | Evidence | Label |
|---|---|---|---|
| 1 | 21 nation keys; 19 building sids; 62 unit keys; 8 NATION_UNITS nations | `data.gd:278-290, 1304+, 638+, 294-306, 208` (brace-depth parse) | OBSERVED |
| 2 | 280 OBJ/manifest entries; 0 nation-prefixed OBJ | manifest + OBJ census | OBSERVED |
| 3 | 8 core buildings from `ukr`, 6 common from `eur`, 3 mines from `env`; `bar18`/`dock` absent | `convert_models.py:246-297`; manifest M:1050-1354 | OBSERVED |
| 4 | All 21 nations have `<nat>cen.osm`+`.dds`; own-family 20/21; `ba2` 18/21 | donor directory census this pass | OBSERVED |
| 5 | Common-family prefix resolution per nation | `country.script:138-206` (re-read) | OBSERVED |
| 6 | 8 peasant forms, 3 with distinct non-core AAF ranges | donor census + AAF parse + N06 §1.3 | OBSERVED |
| 7 | 62 donor unit bases converted; 72 nation-specific `.oss` unconverted | manifest + `.oss` set difference | OBSERVED / DERIVED |
| 8 | Converter parses all relevant formats: 39/39 targeted, 335/335 oss closure, 246/246 aaf | this pass; DEC-04 §4; DANIM-01 | OBSERVED (fresh) |
| 9 | Minimal set = 21 halls + 8 peasants + ~21 signature units (13 new) | §6 | DERIVED |
| 10 | Visual parity for any of the above | none | UNVERIFIED |

---

## 9. Supersession and attestation

- This report **supersedes N06's Russia-only scope** for all-nation coverage. N06
  remains authoritative for the exact additive manifest/skin insertion procedure,
  `ruscen` bbox/vertex numbers, and blockers B1–B12; Z05 remains authoritative for
  relief-prop conversion (a different asset class). N01/N03 remain authoritative for
  the port resolution chain and the single-peasant-form diagnosis; N07 extends both
  from Russia to every nation.
- **Read-only:** no `.gd`, `.json`, `.py`, asset, config, test, queue or Git state was
  modified. No runner job was submitted, no Godot launched (WAVE_G_CHARTER.md:31,169).
  No donor file was copied into the repo or executed; all donor access was in-place
  bytes/text reads. Throwaway probe scripts live in `%TEMP%\opencode`.
- **One repo file written:** `docs/terrain_swarm_2026-11-25/reports/N07_all_nations_assets.md`.
  **No donor parity claim.**

*End of N07 report.*
