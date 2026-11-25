---
id: B-NATION-PLAN2
owner: B-NATION-PLAN2 (READ-ONLY planning micro-worker)
date: 2026-11-25
status: DELIVERED — PLAN ONLY
mode: "read-only; donor TEXT reads only (never run/copied); no code/config/asset/test edit, no Godot run, no runner job, no git op; this report is the sole repo write"
labels: [observed, derived, inferred, UNVERIFIED]
parity_claim: none
scope: "completion plan for variant3d nation-key art: exact gap table, T2a/T2b/T2c micro-tickets, do-not-do list"
---

# B-NATION-PLAN2 — implementable completion plan (nation art)

## 0. Verdict up front

- The nation key reaches sim and renderer (`data.gd:294-306`, `game.gd:486-492`, `world3d_entities.gd:656-674`); the remaining defects are (a) **two false `exact=true` labels** on Bavaria's generic role substitutions and (b) **zero nation-keyed 3D art**, which is load-bearing and **BLOCKED**, not a code bug. [observed + derived; `QA_NATION_IMPL_01:49,56`; `QA_NATION_MODEL_01:51,81`]
- A "fix" that imports `rus*`/`bav*`/`eur*` meshes or invents `bavmil`/`bavpor` is out of scope for the three tickets below and contradicts donor truth (`NATION_DONOR_01:210`; `NAVAL_NATION_01:111`). [observed]
- No parity claim: `exact=true` means only "a file with that stem exists" (`NATION_DATA_01:195`; `QA_NATION_MODEL_01:50`). [observed]

## 1. Evidence base (all READ-ONLY)

| Tag | Source | Use |
|---|---|---|
| **P** | `variant3d/scripts/data.gd:294-306` (`NATION_UNITS`), `:1562` (`BATTLE_ARMY`), `:1565-1568` (`resolve_sid`), `UNITS_BASE` rows `:639,648,666,676,705,714,814,824,853,956,1011,1060` | current port tables |
| **G** | `variant3d/scripts/game.gd:486-492` (`_spawn_sid`), `:2879` (army spawn call), `:4113,:4119` (`train_unit` resolution) | sim-side sid resolution |
| **W** | `variant3d/scripts/world3d_entities.gd:656-674` (`_nation_of`), `:679-683` (`_nation_mesh_on_disk`), `:692-717` (`_donor_building_prefix`), `:737-777` (`_entity_mesh_sid`), `:203` (fallback label) | mesh selection + honest fallback |
| **M** | `variant3d/assets/models/manifest.json:5-11,24-30,100-103,309-315,328-334,1050-1053,1088-1091,1204-1205,1358` | donor provenance actually baked into port meshes |
| **U/C** | donor `data\scripts\lib\unit.script:656-662,771-785,931-937,969-976,1077-1081,1190-1197,1268-1277,1347-1353,1480-1488,1489-1496`; `country.script:138-206,161,2667,2693,2700,2710,2722,2726,2754,2767,2768,3103-3111` | donor stat/roster truth |
| **R** | `NATION_DONOR_01.md:105,181-192,208,210`; `NATION_DATA_01.md:65-97,143-152,158-164,195`; `NAVAL_NATION_01.md:20-22,79,81,111,136`; `QA_NATION_IMPL_01.md:40,46,49-50,56`; `QA_NATION_MODEL_01.md:31,50-51,81` | corroboration + QA caveats |

Read-only checks made this pass: current OBJ tree = **280** files, **0** nation-prefixed stems (only `peasant.obj` matches a `pea*` prefix; `manifest.json:5-11` shows it is Ukrainian-derived `peaukr`), corroborating `QA_NATION_MODEL_01:31`. Donor text scan finds `bavmil`/`bavpor` with **0** files, while `bavbar`/`rusbar`/`eurmil`/`eurpor` and `musketeer18bav`/`grenadierbav`/`pikemanrus`/`pearus`/`peaaus`/`chaika`/`yachttur` do exist — corroborates `NATION_DONOR_01:105,210` and `NAVAL_NATION_01:68,74`. [observed]

## 2. Exact gap table — `BATTLE_ARMY` sids, Russia vs Bavaria

`BATTLE_ARMY` = `pikeman:16, serdiuk:12, archer:8, cossack:8, officer:1, cannon:2` (`data.gd:1562`). Every entry is spawned through `spawn(_spawn_sid(i, sid), …)` (`game.gd:2879`), which calls `Data.resolve_sid(nat, sid)` (`game.gd:492`; `data.gd:1565-1568`), then the mesh sid is chosen by `_entity_mesh_sid()` (`world3d_entities.gd:737-777`), units branch `:751-760` and disk gate `:768-773`. This branch runs only when `battle_mode or army_mult>0` (`game.gd:2869`). [observed]

| Nation | Army sid (`data.gd:1562`) | `resolve_sid` result (`data.gd:295-296,1565-1568`) | Mesh sid selected (`world3d_entities.gd:751-760,765-774`) | Verdict today | Label + cite |
|---|---|---|---|---|---|
| rus | `pikeman` | identity (no `rus` key) | `pikeman` → donor `pikeman.oss` (`M:24-30`) | **WRONG/stand-in**: donor Russian pikeman is `pikemanrus`/Spearman (`C:2667`; `U:656-662`), which has no `UNITS_BASE` row or OBJ (`NATION_DATA_01:70`) | observed code + observed donor absence; inferred role |
| rus | `serdiuk` | `strelet` (`data.gd:295`) | `strelet` (OBJ ✓ `M:328-334`; donor `U:931-937`) | **CORRECT nation key**; `exact=true` donor-grounded | observed |
| rus | `archer` | identity | `archer` → generic `archer.oss` (`M:81`) | no Russia-specific archer in donor roster; identity is donor-correct | observed + inferred |
| rus | `cossack` | `cossackdon` (`data.gd:295`) | `cossackdon` (OBJ ✓ `M:803`; donor `U:1480-1488`, `C:2767`) | **CORRECT nation key** | observed |
| rus | `officer` | identity | `officer` → generic `officer.oss` (`M:138`) | **WRONG/stand-in**: donor `officerrus`/Commander (`U:1077-1081`, `C:2726`) has no port asset (`NATION_DATA_01:71`) | observed code + donor absence |
| rus | `cannon` | identity | `cannon` → generic `cannon.oss` (`M:157`) | no nation art in donor; not a nation gap | observed |
| bav | `pikeman` | identity | `pikeman` (generic; donor bav uses generic `pikeman`, `C:2685`) | donor-correct generic | observed |
| bav | `serdiuk` | `musketeer` (`data.gd:296`) | `musketeer` (OBJ ✓ `M:309-315`; donor generic `U:771-785`, bav in roster `C:2700`) | **MISLABELLED**: generic donor role substitute reported `exact=true`; bav's real uniques `musketeer18bav` (`U:969-976`, `C:2710`) / `grenadierbav` (`U:1268-1277`, `C:2722`) have no port asset (`NATION_DATA_01:94-95`) | observed code; `exact=true` finding `QA_NATION_MODEL_01:51`, `QA_NATION_IMPL_01:49` |
| bav | `archer` | identity | `archer` | no bav-specific archer in donor; identity donor-correct | observed + inferred |
| bav | `cossack` | `hussar` (`data.gd:296`) | `hussar` (OBJ ✓ `M:385`; donor generic `U:1347-1353`, bav in roster `C:2754`) | **MISLABELLED** same as `serdiuk` above; generic role substitute, not bav-unique art | observed; `QA_NATION_IMPL_01:49` |
| bav | `officer` | identity | `officer` (donor generic `officer18`, `C:2736`) | donor-correct generic | observed |
| bav | `cannon` | identity | `cannon` | no nation art in donor; not a nation gap | observed |

Secondary propagation: trained units use the same resolver (`game.gd:4119`, captured override `:4122-4124`), so the same two bav mislabels and the same two rus stand-ins apply to trained `serdiuk`/`cossack`/`pikeman`/`officer`. [derived; `QA_NATION_IMPL_01:54`]

### 2.1 Buildings/ships BLOCKED (no implementable mesh mapping)

- **Buildings (BLOCKED):** `_donor_building_prefix()` (`world3d_entities.gd:692-717`) produces donor-valid candidates (`ruscen`, `bavbar`, `eurmil`, `rusmil`, …) at `:762`, but `_nation_mesh_on_disk()` (`:679-683`) misses all of them (0 prefixed OBJs, §1), so `:765-774` falls back to base sid. Those base meshes are Ukrainian-derived (`cen`→`ukrcen.osm/.dds` `M:1050-1053`; `bar`→`ukrbar.osm/.dds` `M:1088-1091`). This is the direct source of the "looks Ukrainian" report; **no code ticket here fixes it**. [observed; `NATION_DONOR_01:190`; `QA_NATION_MODEL_01:81`]
- **`bavmil`/`bavpor` must not be invented:** donor has 0 such files (§1); Bavaria's common families resolve to `eur*` (`NATION_DONOR_01:105,210`; `country.script:161-204`), and the port already carries `eurmil` provenance at `M:1204-1205`. [observed]
- **Naval (parked, not a defect):** naval branch is deliberately `pass` (`world3d_entities.gd:763-764`); donor ship art is family-keyed (`NAVAL_NATION_01:20,79,81`), `yachttur` is a distinct base sid (`M:1358`; `NAVAL_NATION_01:68`), and `chaika` has no port OBJ (`NATION_DONOR_01:192`). Adding `rus_yacht`/`yachtrus` would invent art (`NAVAL_NATION_01:111,136`). [observed]

## 3. T2a — `variant3d/scripts/data.gd` only (ONE builder, exclusive ownership)

Goal: lock the exact, asset-backed `NATION_UNITS` rows and prevent blocked rows from being added. Current block `data.gd:294-306`; resolver `:1565-1568` rejects any target not in `UNITS` (`:1568`).

| Action | Exact row / value | Donor cite | Port condition | Label |
|---|---|---|---|---|
| **KEEP byte-identical** | `"rus": {"serdiuk": "strelet", "musketeer": "strelet", "cossack": "cossackdon", "dragoon": "cossackdon", "priest": "pope"},` (`data.gd:295`) | `strelet` `U:931-937`/`C:2693`; `cossackdon` `U:1480-1488`/`C:2767`; `pope` `NATION_DATA_01:60` | `UNITS_BASE` `:824,:1060,:1011`; OBJ ✓ | observed |
| **KEEP byte-identical** | `"bav": {"serdiuk": "musketeer", "cossack": "hussar"},` (`data.gd:296`) | bav in generic `musketeer` `C:2700`/`U:771-785`; bav in `hussar` `C:2754`/`U:1347-1353` | `UNITS_BASE` `:814,:853`; OBJ ✓ | observed |
| **KEEP** | `ukr :297`, `pol :298`, `tur :299`, `alg :300`, `swe :301`, `sco :305` | `NATION_DATA_01:143-152` | targets in `UNITS` | observed |
| **ADD — OPTIONAL, SIGN-OFF GATED** | extend `rus` row with `"reiter": "vityaz"` | `vityaz` is rus unique heavy cav `C:2768`/`U:1489-1496`; generic `reiter` excludes rus `C:2773` | `UNITS_BASE` `:956`; `vityaz.obj` ✓ | inferred role; **deferred** `NATION_DATA_01:147` because AI orders generics and selftest traces shift |
| **DO NOT ADD** | `rus.peasant→pearus`, `rus.pikeman→pikemanrus`, `rus.officer→officerrus`, `rus.drummer→drummerrus`, `bav.musk18→musketeer18bav`, `bav.grenadier→grenadierbav`, `bav.peasant→peaaus` | donor sids exist `U:656-662,969-976,1077-1081,1190-1197,1268-1277` | no `UNITS_BASE` row and no OBJ → `resolve_sid` rejects at `:1568` | observed absence; `NATION_DATA_01:65-97,148-150`; `NATION_DONOR_01:188-189` |

Acceptance probe (read-only, **no full gate**): static content check — every target of every row in `data.gd:294-306` is a top-level `UNITS_BASE` key and has `obj/<target>.obj`; `rus` and `bav` rows match byte-for-byte except an explicitly signed-off `reiter` add; MORALE banners/constants verified by **content hash**, not line number (`NATION_DATA_01:158-164`; `QA_NATION_IMPL_01:40`). Optional `--check-only` parse smoke only; no selftest/uitest gate. [derived]

## 4. T2b — `variant3d/scripts/world3d_entities.gd` only (ONE builder, exclusive ownership; after T2a)

Goal: make selection labels honest for the two Bavarian role substitutions; preserve all donor-valid, disk-gated behaviour and the existing fallback.

- **Exact function:** `_entity_mesh_sid()` at `world3d_entities.gd:737-777`. Units remap at `:758-760`; disk hit sets `exact=true` at `:768-773`; status chosen at `:774`.
- **Defect to fix:** when `rsid != base_sid` but `rsid` is a **generic donor family sid** (`musketeer` from `data.gd:296`, `hussar` from `data.gd:296`), the disk hit at `:769-772` sets `exact=true`, i.e. a generic mesh is reported as exact nation art (`QA_NATION_MODEL_01:51`; `QA_NATION_IMPL_01:49`). Russian remaps (`strelet`, `cossackdon`) remain genuinely donor-grounded and must stay `exact=true` (`U:931-937`, `U:1480-1488`). [observed + derived]
- **Minimal change (inferred design, owner must choose constant name):** gate `exact` on the target being donor nation-coded, not merely present on disk — e.g. add an explicit "role substitution" status/label alongside `NATION_MESH_FALLBACK_STATUS` (`:203`) and set `exact=false` when the resolved sid is in the generic-role set `{"musketeer","hussar"}` produced by `data.gd:296`. Keep `candidate` and `candidates` output unchanged for traceability; do **not** alter `_donor_building_prefix()` (`:692-717`) or the naval branch (`:763-764`). [inferred]
- **Fallback when OBJ absent (already correct — do not rewrite):** `:765` `var sid := base_sid`, `:774` `status := NATION_MESH_FALLBACK_STATUS`; `_mesh_info()` donor-bbox proxy for no OBJ/GLB (`NATION_SPAWN_01:52`). Same path covers `ruscen`/`bavbar`/`eurmil` misses (`world3d_entities.gd:762,768-774`). [observed]
- **Protected regions (byte-identical):** rotor/stage/tree/motion blocks (`QA_NATION_IMPL_01:45`); no `.obj`/manifest write (`QA_NATION_MODEL_01:46`). [observed]

Acceptance probe (read-only, **no full gate**): temp probe outside the repo (precedent `QA_NATION_MODEL_01:29`) calling `_entity_mesh_sid()` for the 12-row matrix of §2 plus: `rus/buildings cen` → `chosen=cen`, `candidate=ruscen`, `exact=false`; `bav/buildings mil` → `eurmil`, `exact=false`; `bav/buildings bar` → `bavbar`, `exact=false`; `rus,bav/naval yacht` → `candidates=[]`, `sid=yacht`. Assert **after fix**: `rus/serdiuk→strelet exact=true`, `rus/cossack→cossackdon exact=true`, `bav/serdiuk→musketeer exact=false`, `bav/cossack→hussar exact=false`. Compare to the existing pre-fix verbatim probe lines at `QA_NATION_MODEL_01:60-70` (which lack bav remaps — open question `:87`). Parse smoke + temp probe only; no gate job. [derived]

## 5. T2c — naval layer: PARK (no file owner, no edit)

Reason: donor naval art is family-keyed (`NAVAL_NATION_01:20,79,81`); the current probe-then-fallback is donor-correct (`world3d_entities.gd:763-764`; `NAVAL_NATION_01:22,111`); no nation ship stem exists on disk (§1) and inventing one is explicitly rejected (`NAVAL_NATION_01:136`). `chaika` is a separate missing-family gap, not a nation gap (`NATION_DONOR_01:192`; `NAVAL_NATION_01:132`). [observed]

Optional future ticket (separate test-file owner, **not** part of T2a/T2b/T2c): NN-01 naval-invariance atom at `variant3d/tests/t_naval_nation.gd` (`NAVAL_NATION_01:144`). Parking probe (read-only, no edit): for 7 families at `data.gd:1358` × `{rus,bav}`, assert `_entity_mesh_sid` returns `family=naval`, `sid=base_sid`, `candidates=[]`, `exact=false`, and no `<nat>_<family>.obj`/`<family><nat>.obj` exists. [derived]

## 6. What must NOT be done

1. **No invented `bavmil`/`bavpor`** (0 donor files, §1; `NATION_DONOR_01:210`; bav uses `eur*` `NATION_DONOR_01:105`). [observed]
2. **No new `rus*`/`bav*`/`eur*` OBJ, texture or manifest rename** as part of these tickets; 0 exist (`QA_NATION_MODEL_01:81`; §1) and rewriting manifest provenance would fabricate donor paths (`M:5-11,1050-1053`). Separate asset ticket only. [observed + inferred]
3. **No `NATION_UNITS` rows targeting blocked sids** (`pikemanrus`, `officerrus`, `pearus`, `drummerrus`, `musketeer18bav`, `grenadierbav`, `peaaus`, `dragoon18`, `ferry`, `chaika`): no `UNITS_BASE`/OBJ (`NATION_DATA_01:65-97,148-150`; `NATION_DONOR_01:188-189,192`). [observed]
4. **No naval nation remap** (`yachtrus`, `rus_yacht`, recoloured hull): donor has none (`NAVAL_NATION_01:20,81,111,136`; `world3d_entities.gd:763-764`). [observed]
5. **No entity `nation` field, no `spawn()` signature edit, no test-driver/gate edit** (`NATION_SPAWN_01:83-85`; `QA_NATION_IMPL_01:46`). [observed + derived]
6. **No MORALE banner byte changes** in `data.gd` (`NATION_DATA_01:158-164`; `QA_NATION_IMPL_01:40`); verify by content, not line number, because the `bav` insert shifted later lines. [derived]
7. **No `hetman` for Russia**: donor assigns it to Ukraine only (`NATION_DONOR_01:208`; `C:2760-2763`). [observed]
8. **No parity/visual claim**: `exact=true` = file-exists only (`NATION_DATA_01:195`; `QA_NATION_MODEL_01:50`); patron-facing "Ukrainian look" stays **BLOCKED** until an asset owner lands meshes (`QA_NATION_IMPL_01:56`). [observed]
9. **No full gate / runner job / direct `godot` / git op** from these micro-tickets; probes only, per this plan's scope. [plan constraint]

## 7. Sequencing & acceptance summary

`T2a` (data.gd builder, exclusive) → `T2b` (world3d_entities.gd builder, exclusive, consumes T2a's rows) → `T2c` parked with no owner. File sets are disjoint; no two tickets edit the same file. [derived]

| Ticket | Owner file | Pass condition (probe only) |
|---|---|---|
| T2a | `variant3d/scripts/data.gd` | all row targets in `UNITS` + OBJ; MORALE content hashes equal; no blocked row added |
| T2b | `variant3d/scripts/world3d_entities.gd` | 12-row matrix + bav remaps `exact=false`; building/naval misses still fall back; protected blocks byte-identical |
| T2c | none (parked) | structural assertion `candidates=[]` for naval; no nation ship art authored |

## 8. Open questions (UNVERIFIED)

1. Runtime `nation_mesh_usage` histogram still not observed in any artifact (`QA_NATION_MODEL_01:50-51`); no exact dict can be reported. [observed absence]
2. Whether T2b's role-substitution rule is implemented as a new status constant or a boolean refinement is an owner design call; this plan does not pick the identifier. [inferred]
3. Whether `rus.reiter→vityaz` (T2a optional) is accepted needs an owner decision plus seed-trace re-baseline (`NATION_DATA_01.md:147,212`). [inferred]
4. Whether `app/scripts/game.gd` mirror needs the same spawn edit remains UNVERIFIED (`NATION_SPAWN_01:99`; `QA_NATION_IMPL_01:70`). [UNVERIFIED]
5. No donor render or port screenshot was examined; visual outcome of every selection remains UNVERIFIED. [UNVERIFIED]

*End of B-NATION-PLAN2 — no code, asset, config, test, runner job or git operation; no donor binary executed or copied; no visual-parity claim.*
