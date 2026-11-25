---
id: NAVAL-NATION-01
owner: NAVAL-NATION-01 subagent (read-only planning worker)
date: 2026-11-25
area: donor per-nation ship family/skin truth and port naval art selection
mode: "READ-ONLY planning. No code edit, no donor copy/execution, no Godot/Blender/runner job, no git operation. Only this report written."
scope: "singleplayer skirmish naval art mapping only — missions/campaign/network stay deferred (D-12)"
donor: "C:\\Games\\Cossacks 3 (private use; bytes + latin-1 reads only; never run, copied or modified)"
compliance: "no parity claim; missing art labelled UNVERIFIED; no invented ship or nation names"
labels: [observed, derived, inferred, UNVERIFIED]
target_report_path: docs/coord_swarm_2026-11-25/reports/NAVAL_NATION_01.md
board_row: "SWARM_BOARD.md:309 (NAVAL-NATION-01, session ses_deda1f1c1ffdofVF07BacRyFG4, RUNNING at read time)"
status: COMPLETE — mapping read, claim adjudicated, ticket plan proposed; NO parity claim
---

# NAVAL-NATION-01 — donor nation mapping for ships/naval meshes (plan only)

## 0. Verdict up front

1. **Donor ships have no per-nation art.** All ship hulls, crew figures and skins are keyed by **ship family** (`yacht`, `yachttur`, `fishboat`, `frigate`, `galley`, `battleship`, `xebec`, plus `chaika`/`ferry`), never by nation. The shipyard roster in `country.script:3103-3111` adds the same family sids to every country's generic port with identical gates. [observed]
2. **"Ukrainian navy used for all" is REFUTED for naval**, at the file-provenance and donor-structure level. Port ship meshes/textures resolve to family paths (`units/<family>.osm`, `materials/units/<family>.dds`), not to Ukrainian donor paths such as `peaukr.dds` / `ukrcen.osm`. The Ukrainian-art fault documented for `peasant`/`cen` is real for **units and buildings**, not ships. [observed + derived]
3. **The exact place where nation would select ship art is `variant3d/scripts/world3d_entities.gd:695`, naval branch `:717-722`.** Its current probe-then-fallback shape (`<family><nat>` / `<nat>_<family>` stems, then base family) is **donor-correct**: no such nation stems exist, so the shared family is used. **No ticket should add nation remapping for ships** — that would invent art the donor does not have. [observed]
4. **Requested source `reports/NATION_DONOR_01.md` does not exist on disk** at read time (direct read returned "File not found"; also `OWNER_FAULTS.md:11,36` and `SWARM_BOARD.md:295` show that ticket still `RUNNING`). This report does not substitute for it; it covers naval only. [observed]

No parity claim is made: DDS pixels, attach transforms and rendered visuals remain **UNVERIFIED**.

---

## 1. Sources

### 1.1 Required reads and their availability

| # | File | Availability / use |
|---|---|---|
| S1 | `reports/NATION_DONOR_01.md` | **ABSENT** — direct read failed; `OWNER_FAULTS.md:11,36` and `SWARM_BOARD.md:295` confirm no landed report. Naval-relevant mapping re-derived here from donor + port instead. [observed] |
| S2 | `reports/DONAVAL_01.md` | Read in full. Hull/crew/attach/skin inventory, stat constants, port gap ranking; §2.4 skins, §3 V4/V8, §5.1 port state. |
| S3 | `reports/DONAVAL_02.md` | Read in full. Independent confirmation of skin presence, crew scope, tier-as-gate, radii/speed, shipyard actors; §3/§4 UNVERIFIED set unchanged. |
| S4 | `docs/coord_swarm_2026-11-24/reports/V778_ship_skins.md` | Read in full. §3.5 `:112-116`: 7 ships skipped as IDP2 static hulls; `PORT APPROXIMATION — NOT DONOR PARITY`, visual UNVERIFIED. |
| S5 | `docs/NAVAL_PORT_PLAN.md` | Read in full. §2 `:58-75` seven families; §4 `:127-139` 2D hand-off incl. `Data.resolve_sid` "no nation variant"; §5 `:198` stale material-presence question (closed by S2/S3). |
| S6 | `variant3d/scripts/world3d_entities.gd` | Read relevant ranges: `:200-203` labels, `:334-345` tint = player slot, `:653-680` nation helpers, `:683-739` `_entity_mesh_sid`, `:1540-1607` call sites. |
| S7 | `variant3d/scripts/data.gd` | Read relevant ranges: `:294-305` `NATION_UNITS`, `:1200-1299` ship defs, `:1354-1357` dock trains, `:1563-1567` `resolve_sid`. |
| S8 | `variant3d/assets/models/manifest.json` | Ship entries at `:3140,3159,3178,3197,3216,3235,3254`; donor mesh/texture path fields read via Python 3.14. |
| S9 | `docs/REPORT_ASSETS_BAKING.md:170-179` | `:176` decisive naval row: "Naval: no per-nation variants … `yachttur` is a distinct donor family/roster sid, not a Turkey skin of `yacht` … `common/naval` is donor-correct". |
| S10 | `inbox/anim_nation_plan.json` | `:63` `"common/naval": 12`; `:67` `"<nation>/naval": "no nation has ship sprites in the current data - do not create empty nation naval dirs"`. |
| S11 | `docs/coord_swarm_2026-11-25/OWNER_FAULTS.md:11,36,52-53` | Fault F2 context and absent-report snapshot. |
| S12 | `docs/coord_swarm_2026-11-25/reports/NATION_FLOW_01.md:60-68,70-79` | Menu→entity nation flow; `:67-68` ship/naval sid resolution; `:70-79` Ukrainian provenance restricted to units/buildings. |

### 1.2 Fresh donor reads (pass-2 style, this task, read-only)

All paths relative to `C:\Games\Cossacks 3\`. Python 3.14, `open(..., 'rb'/'r', encoding='latin-1')`; probes ran from `%TEMP%` as inline `-c` commands, **nothing written into the repo or donor**.

| Group | Paths | Method |
|---|---|---|
| Ship skins | `data\materials\units\*.dds` | directory listing + byte sizes |
| Ship roster | `data\scripts\lib\country.script:3100-3111` | latin-1 line slice |
| Nation-prefixed ship art scan | whole `data\` tree | filename scan for `<nat>_<ship>`, `<ship>_<nat>`, `<ship><nat>` over 20 nation codes × 9 ship names |
| Port ship art scan | `variant3d\assets\models\{obj,tex}\*` | existence check for 9 family names + nation variants |

---

## 2. Donor ship families / skins → port art mapping

### 2.1 Donor truth (per-family, not per-nation)

| Ship family | Donor hull | Donor skin (hull atlas) | Crew `.oss` | Rotor of family | Port OBJ | Port PNG | 2D hull sheet |
|---|---|---|---|---|---|---|---|
| `yacht` | `data\actors\units\yacht.osm` (`DONAVAL_01.md:58`) | `data\materials\units\yacht.dds` 2,796,368 B (`:104`) | yes (`:78`) | yacht | `obj\yacht.obj` | `tex\yacht.png` | `common\naval\yacht_hull.png` |
| `yachttur` | `data\actors\units\yachttur.osm` (`:59`) | `data\materials\units\yachttur.dds` 2,796,368 B (`:104`) | yes (`:78`) | **distinct family**, not a Turkey skin of yacht (S9 `:176`; port code `:718-719`) | `obj\yachttur.obj` | `tex\yachttur.png` | `common\naval\yachttur_hull.png` |
| `fishboat` | `data\actors\units\fishboat.osm` (`:60`) | `data\materials\units\fishboat.dds` 1,398,256 B (`:103`) | yes (`:78`) | fishboat | `obj\fishboat.obj` | `tex\fishboat.png` | `common\naval\fishboat_hull.png` |
| `frigate` | `data\actors\units\frigate.osm` (`:61`) | `data\materials\units\frigate.dds` 5,592,560 B (`:102`, correction V1 `:206`) | yes (`:78`) | frigate | `obj\frigate.obj` | `tex\frigate.png` | `common\naval\frigate_hull.png` |
| `galley` | `data\actors\units\galley.osm` (`:62`) | `data\materials\units\galley.dds` 5,592,560 B (`:102`) | yes (`:78`) | galley | `obj\galley.obj` | `tex\galley.png` | `common\naval\galley_hull.png` |
| `battleship` | `data\actors\units\battleship.osm` (`:63`) | `data\materials\units\battleship.dds` 5,592,560 B (`:102`) | no (`:80`) | battleship | `obj\battleship.obj` | `tex\battleship.png` | `common\naval\battleship_hull.png` |
| `xebec` | `data\actors\units\xebec.osm` (`:64`) | `data\materials\units\xebec.dds` 5,592,560 B (`:102`) | no (`:80`) | xebec | `obj\xebec.obj` | `tex\xebec.png` | `common\naval\xebec_hull.png` |
| `chaika` (extended) | `data\actors\units\chaika.osm` (`:65`) | `data\materials\units\chaika.dds` 5,592,560 B (fresh scan) | no (`:80`) | chaika | **absent** | **absent** | **absent** |
| `ferry` (extended) | `data\actors\units\ferry.osm` (`:66`) | `data\materials\units\ferry.dds` 5,592,560 B (fresh scan) | yes — 6th crew (`:79`) | ferry | **absent** | **absent** | **absent** |

**Shared, non-national atlas:** `data\materials\units\xebeca.dds` 2,796,344 B is the common attach/rigging atlas (`DONAVAL_01.md:105,108`; `units.mat:434-442`, `<ship>.prop` bindings), **not** a nation skin and not an alternate xebec hull. `misflagman.dds` 349,680 B is a flagship-flag material (`:106`).

**Nation-independent roster (fresh read):** `data\scripts\lib\country.script:3103-3111` adds `fishboat` (tier 0), `yacht`/`yachttur` (1), `ferry` (2), `galley` (4), `frigate`/`chaika`/`xebec` (5), `battleship` (6) to `member := commonNamePort{commonName+'por'}` for **every country** with the same `<cid>+'art'` / `enablefrigate` / `enablebattleship` gates. No nation selects a different ship sid. [observed]

**Fresh negative scan:** over the entire donor `data\` tree, no file named `<nat>_<ship>`, `<ship>_<nat>` or `<ship><nat>` exists for 20 nation codes × 9 ship names. The only superficial match is `yachttur*`, which is the family name, not a nation prefix (S9 `:176`). [observed]

### 2.2 Port inventory (what actually exists)

| Layer | Path | Count / state | Citation |
|---|---|---|---|
| 3D hull mesh | `variant3d/assets/models/obj/<family>.obj` + `.mtl` + `.import` | **7** families (yacht, yachttur, fishboat, frigate, galley, battleship, xebec); chaika/ferry absent | manifest `:3140,3159,3178,3197,3216,3235,3254`; fresh scan |
| 3D hull texture | `variant3d/assets/models/tex/<family>.png` | **7** matching PNGs; no `<nat>_<family>.png` | fresh scan |
| Manifest provenance | `manifest.json:models[].mesh/texture` | e.g. `yacht` → `units\yacht.osm` / `materials\units\yacht.dds` — **family paths, not Ukrainian paths** | manifest `:3140-3146`; `NATION_FLOW_01.md:67` |
| 2D hull sheets | `app/assets/models/anim/common/naval/<family>_hull.png` | **7**; no `<nat>/naval` directory | fresh glob; S10 `:63,67`; S9 `:176` |
| 2D naval index | `app/assets/models/anim/naval_units/index.json` | bare family keys only | `NATION_FLOW_01.md:68`; S10 `:99` |
| Animated skins | `variant3d/assets/models/skin/index.json` | 55 land units; ships skipped as IDP2 | S4 `:112-116` |
| Ship sim defs | `variant3d/scripts/data.gd:1209-1299` | 7 `naval:true` defs; `dock.trains` at `:1357` lists all 7 | S7 |
| Nation unit map | `variant3d/scripts/data.gd:294-305` | **no ship entries**; `resolve_sid` `:1564-1567` returns ship sids unchanged | S7 |

---

## 3. Exact art-selection point and verdict on "Ukrainian navy used for all"

### 3.1 The selection point [observed]

`variant3d/scripts/world3d_entities.gd:695` `_entity_mesh_sid(ed, base_sid, kind)` is the single helper that chooses a mesh sid per entity:

- `:696-705` — nation from `_nation_of()` (`:653-671`: `ed.nation` → `game.players[player].nation` → `Data.PLAYER_NATIONS`); family set to `buildings` for `kind=="building"`, else `naval` when `def.naval==true` (ships), else `units`.
- `:690-694` — donor-evidence comment: `country.script` maps generic roster sids to nation **units**; building art is `<nat>_<sid>` **2D only**; "naval hulls are family-keyed with no per-nation skin".
- `:717-722` — **naval branch**: probes `base_sid + nation` then `nation + "_" + base_sid` (e.g. `yachtrus`, `rus_yacht`). Comment at `:718-719`: "Donor hulls are family-keyed; yachttur is a distinct family sid, not a Turkey skin of yacht … Probe literal donor-derived stems only, never invent art."
- `:727-736` — first existing stem wins; otherwise `sid = base_sid`, `exact=false`, status `NATION_MESH_FALLBACK_STATUS`.
- `:202-203` — statuses: `NATION_MESH_EXACT_STATUS` and `NATION_MESH_FALLBACK_STATUS`. The fallback text explicitly says "donor naval hulls are family-keyed" and cites Ukrainian donor paths only for `peasant`/`cen`.
- Call sites: `add_unit` `:1552-1559` passes `kind="unit"` but the `def.naval` check at `:704` routes ships into the naval branch; batch meta written at `:1572-1578`. `add_building` `:1593-1607`.

**Conclusion [derived]:** this is the exact place where nation *could* select ship art. The correct donor-faithful decision is to keep the shared family: the probed nation stems do not exist on disk (§2.2), so fallback to `<family>` is the intended, donor-correct outcome. A future "fix" that adds `rus_yacht.obj` or recolours a Ukrainian hull would be invented art and must be rejected.

### 3.2 Claim adjudication

| Claim | Verdict | Evidence |
|---|---|---|
| "Ukrainian navy used for all" (donor level: Ukraine has unique ships reused by every nation) | **REFUTED** [observed] | Donor ship skins are `data\materials\units\<family>.dds`; no nation-prefixed ship file exists in the full `data\` scan; `country.script:3103-3111` gives all nations the same family roster; S9 `:176`. |
| "...in the port's ship art provenance" | **REFUTED** [observed] | Manifest ship entries use `units\<family>.osm` / `materials\units\<family>.dds` (`:3140-3254`), not `peaukr.dds`/`ukrcen.dds`. 7 OBJ/PNG are family-named; no `<nat>_<family>` ship art exists. 2D uses `common/naval` (S10 `:67`). |
| "...as an explanation of the Russia/Bavaria wrong-art fault" | **PARTLY REFUTED / SCOPE CORRECTION** [derived] | S11 F2 and S12 `:70-79` document Ukrainian-derived art for `peasant`, `cen`, `hou`, `bar`, `sta`, etc. — units/buildings. Ships are excluded by S9 `:176` and `:203`. The fault may be real for units/buildings but **does not generalise to naval**. |
| "Port ships are nation-aware today" | **STRUCTURALLY TRUE, ART-NO-OP** [observed+derived] | `world3d_entities.gd:695-739` now resolves nation for ships, but every candidate stem misses on disk, so output sid is always the base family. Contrast S12 `:66-67`, which predates this helper and describes ships as plain sid-only — **doc drift**, not current state. |
| "Visual result matches the donor" | **UNVERIFIED** | No DDS pixel decode, no rendered A/B; `NATION_MESH_*` statuses are explicitly `PORT APPROXIMATION — NOT DONOR PARITY`; S4 visual UNVERIFIED. |

---

## 4. Gap ranking (naval-nation planning scope)

| Rank | Gap | Evidence | Impact | Label |
|---:|---|---|---|---|
| 1 | **No landed `NATION_DONOR_01.md`** root mapping report; naval must re-derive donor truth locally | direct read failed; `OWNER_FAULTS.md:11,36`; `SWARM_BOARD.md:295` | Units/buildings nation mapping truth still absent; naval conclusion here is independent of it | observed |
| 2 | **No naval nation-invariance assertion** — no test asserts ship mesh/texture sid is family-constant across `rus`/`bav`/`ukr`/`tur` | no `t_naval_nation` atom found; only the silent probe/fallback at `:717-736` | A future editor could add invented nation ship art without detection; F2 acceptance test (`OWNER_FAULTS.md:53`) names ships but has no landed gate | observed / derived |
| 3 | **Doc drift**: `NATION_FLOW_01.md:66-67` says ships are sid-only; current code routes through `_entity_mesh_sid` (`:1552-1559`) | compare S12 `:66-67` with `world3d_entities.gd:695,704-705` | Planners may "fix" a non-existent naval nation bug | observed |
| 4 | **`chaika` / `ferry` have no port art** (OBJ/PNG/2D sheet/index key) | §2.1 rows; fresh scan; `DONAVAL_01.md:270` Q8 | Not a nation gap — a missing-family gap. Any ticket must label art **UNVERIFIED**, not reuse a Ukrainian or other family's mesh | observed / UNVERIFIED |
| 5 | **Composite attach art absent** (sail/flag/paddle/ladder, animated flags 1–4) | `DONAVAL_01.md:84-96,250`; `world3d_entities.gd:1414-1415` sail child only for mill | Ship visual is a bare hull; rigging is not nation-specific either | observed |
| 6 | **DDS pixels / rendered naval visuals UNVERIFIED** | `DONAVAL_01.md:217,268`; S4 `:214-217` | No visual parity claim possible; a rendered A/B is required before any claim | UNVERIFIED |

Explicitly **not** ranked as a gap: per-nation ship skins — the donor has none, so their absence is correct, not a defect.

---

## 5. Minimal ticket plan (proposals only; no files edited)

| Ticket | Owner file | Scope / change | Validation | Labels |
|---|---|---|---|---|
| **NN-01 — Naval nation-invariance gate** (primary) | NEW `variant3d/tests/t_naval_nation.gd` (atom only; `world3d_entities.gd` unchanged) | For each of the 7 ship sids and nations `rus`, `bav`, `ukr`, `tur` (and empty nation), call `_entity_mesh_sid` with a `def` carrying `naval:true`; assert `family == "naval"`, `sid == base_sid`, `exact == false`, `status == NATION_MESH_FALLBACK_STATUS`; assert no `obj/<family><nat>.obj`, `obj/<nat>_<family>.obj`, `tex/<family><nat>.png` exists. Do **not** author or copy any art. | Headless atom via `variant3d/tools/godot_runner.py`; zero invented assets; report `passed:true` with per-assertion rows. Windowed capture of a `rus` and a `bav` skirmish can corroborate but is not a substitute for the atom. | observed inputs; no parity claim |
| **NN-02 — Scope the fallback label** (small, optional) | `variant3d/scripts/world3d_entities.gd:203` | Reword `NATION_MESH_FALLBACK_STATUS` so the `peasant`/`cen` Ukrainian-provenance example is explicitly labelled "units/buildings only; naval hulls are family-keyed and shared". No behaviour change, no new art. | Re-run structural gate that reads `nation_mesh_label` meta (`:1576`); selftest `passed:true`; assert label still contains `PORT APPROXIMATION — NOT DONOR PARITY`. | observed; visual UNVERIFIED |
| **NN-03 — Doc reconciliation** (no code) | `reports/NATION_FLOW_01.md:66-67` and this report's §3.1 | Add a note that the current `_entity_mesh_sid` naval branch supersedes the earlier "ships are sid-only" line; keep the Ukrainian-provenance table scoped to units/buildings. | Re-read both files after edit; no gate job required. | observed |
| **NN-04 — `chaika`/`ferry` family art** (deferred, separate scope decision) | `variant3d/assets/models/manifest.json` + `variant3d/tools/convert_models.py` + `assets/models/{obj,tex}/` | Only if the coordinator expands from 7 families: derive from `chaika.osm`/`ferry.osm` + their `.dds`; **no nation stems**. Until then label art **UNVERIFIED / absent**. | Manifest entry + OBJ/PNG presence + `DONAVAL_01.md` stat table parity of data (not visual); no parity claim. | missing art UNVERIFIED |

Sequencing: NN-01 first (it locks the correct behaviour), then NN-02/NN-03, then NN-04 only on explicit scope grant. Nothing here grants code ownership; NN-01/NN-02 need the owning agent's grant before any edit.

---

## 6. Open questions

1. **UNVERIFIED — visual identity.** No DDS pixel decode or rendered ship A/B was made; this report decides provenance/naming only.
2. **UNVERIFIED — donor runtime binding.** `DONAVAL_01.md:108` finds ship material choice prop-driven, with no plaintext nation switch; engine-side per-nation overrides, if any, were not ruled out. [inferred absence]
3. **UNVERIFIED — attach transforms** for sail/flag/paddle/ladder (`DONAVAL_01.md:96,217`); not nation-specific, but blocks full naval visual parity.
4. **UNVERIFIED — captured-nation ships.** `game.gd:3982-3987` applies a captured-nation override for units; whether ships are affected was not traced here (naval flow is deferred with missions/campaign).
5. **OPEN — scope of `chaika`/`ferry`** (`DONAVAL_01.md:270` Q8); no port art, so any inclusion needs new family assets, not nation art.
6. **OPEN — `NATION_DONOR_01.md`** still `RUNNING` (`SWARM_BOARD.md:295`); when it lands, re-check that its unit/building mapping does not assert a naval nation skin contrary to S9 `:176`.
7. **UNVERIFIED — owner screenshot for F2.** `OWNER_FAULTS.md:53` records no on-disk image; which entities (units vs buildings vs ships) actually rendered with wrong art was not measured here.

---

## 7. Summary

- Read all five requested readable sources; the sixth (`NATION_DONOR_01.md`) is **absent** and was reported as such rather than invented.
- Fresh donor scan confirms ship families and skins are **family-keyed**: 7 core + 2 extended hulls with per-family `.dds`, one shared rigging atlas (`xebeca.dds`), and a single generic shipyard roster for all countries (`country.script:3103-3111`). No nation-prefixed ship file exists anywhere in donor `data\`.
- Port inventory: 7 ship OBJ/MTL/PNG families with manifest paths `units/<family>.osm` / `materials/units/<family>.dds`; 7 2D `common/naval/<family>_hull.png`; no nation naval art on either side; `chaika`/`ferry` art missing (**UNVERIFIED**).
- Exact selection point is `world3d_entities.gd:695`, naval branch `:717-722`. Because the probed stems cannot exist, the shared family fallback is **donor-correct**; no nation remap ticket is needed for ships.
- **"Ukrainian navy used for all" is REFUTED** for naval at the provenance/structure level. The Ukrainian-art problem documented for `peasant`/`cen` is a units/buildings issue and must not be transferred to ships.
- Four minimal tickets proposed (naval-invariance gate first), each with an owner file and validation. **No code edit, no donor copy, no runner job, no parity claim; all missing art labelled UNVERIFIED.**

---

*NAVAL-NATION-01 — donor private-use read-only; only `docs/coord_swarm_2026-11-25/reports/NAVAL_NATION_01.md` written in the repo. Missions/campaign/network deferred (D-12).*
