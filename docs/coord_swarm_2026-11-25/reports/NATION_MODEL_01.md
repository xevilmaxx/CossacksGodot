---
id: NATION-MODEL-01
owner: NATION-MODEL-01 (implementation builder subagent)
swarm: coord_swarm_2026-11-25
date: 2026-11-25
status: IMPLEMENTED__DONOR_GROUNDED_SELECTOR__EXACT_ART_BLOCKED__BUILD_ACTION_ADDED__PARSE_SMOKE_OK
scope: "Edited ONLY variant3d/scripts/world3d_entities.gd and this report. Donor READ-ONLY (country.script + actor/prop/material paths cited, nothing copied or executed). No game.gd/data.gd/menu/config/main edit; no asset, test, manifest or converter edit."
owns:
  - variant3d/scripts/world3d_entities.gd
  - docs/coord_swarm_2026-11-25/reports/NATION_MODEL_01.md
backup: inbox/backup/world3d_entities.gd.bak-NATIONMODEL01 (93,632 B, SHA-256 9C797DFBAD6864F61B9A38AAD4F4D4C600A64F79EEA4A34FB6302A9EB4E75199, identical at copy time)
labels: [DONOR_TRUTH, PORT APPROXIMATION, BLOCKED, UNVERIFIED, NO_VISUAL_PARITY]
parity_claim: none
---

# NATION-MODEL-01 — nation-aware 3D mesh selection + build-order action

> [!IMPORTANT]
> The nation now reaches mesh selection and the donor-grounded family probe
> runs for units / buildings / naval. **No exact-nation 3D art exists on disk**
> (0 nation-keyed OBJs among 172 original models), so the visible result is
> still the Ukrainian-derived base mesh. This is reported **BLOCKED**, not
> "fixed". `visual = UNVERIFIED`. No donor parity is claimed.

## 1. Inputs read before editing

| Input | Use |
|---|---|
| `reports/NATION_DONOR_01.md` (landed during work) | Donor truth: units are nation-coded **sids**, no skin swap; buildings resolve `%nat%`/`%com%` prefixes (`country.script:138-206`); rus/ukr share `rus*`, bav shares `eur*`, `bavmil`/`bavpor` do not exist; ships family-keyed except `yachttur`/`chaika`; port gap G1-G12/C4-C6. |
| `reports/NATION_FLOW_01.md` | Nation survives menu→config→`game.players[].nation` (`game.gd:386`) but is dropped at `spawn()` (`game.gd:2186-2191`) and at the 3D sid-only mesh key; `bav` absent from `NATION_UNITS`; tint is slot-indexed, explicitly NOT nation (`world3d_entities.gd:445,608-611`). |
| `reports/BUILD_ANIM_DIAG_01.md` | Root cause of wrong build animation: `_unit_action()` had no `order.type=="build"/"repair"` branch; 2D sibling maps build/repair→`construct` (`world.gd:489-490`); skin-export gap has a separate owner (`convert_skins.py`). |
| `reports/BUILD_STAGE_INTEGRATION_01.md` + `BUILD_ART_BATCH_01.md` | Stage selector is already art-ready; optional integration deferred (§7). |
| Donor `C:\Games\Cossacks 3\data\scripts\lib\country.script` (read-only) | `rus=4`, `ukr=5`, `bav=18` (`:15,16,29`); generic→nation unit sids `musketeer→strelet/rus`, `serdiuk/ukr`, `musketeersco/sco` (`:1031-1042`); building sidmask (`:138-206`). |
| `inbox/anim_nation_plan.json` / `anim_nation_undo.json` | Nation-first **2D** sheet layout `anim/<nation>/{units,buildings,naval}` and counts (units 312, buildings 1525, naval 12); 2D only, not 3D OBJs. |
| Owned file `variant3d/scripts/world3d_entities.gd` | Read `bind()`, `_mesh_info()` (`922-972` pre-edit), `_player_index()`, `add_unit()`, `add_building()`, `_unit_action()`, rotor/stage/tree/motion blocks at their edit seams. |
| Port read-only `data.gd:294-305,1563-1567`; `game.gd:2186-2197,3973-3985`; `world.gd:457-468,481-490` | Canonical `NATION_UNITS`/`resolve_sid()`, spawn dictionary, 2D nation and action precedents. |

## 2. Donor citations

| Rule implemented | Donor / port source (read-only) |
|---|---|
| Nations reach generation; `players[i].nation` exists | `config.json:71-72` → `main.gd:281-285` → `game.gd:386` (NATION_DONOR_01 §4 / NATION_FLOW_01 hop 5). |
| Nation identity for units is the sid; no skin swap | `country.script:2645-2728`, `actors.lib`, `<sid>.prop:9-14`, `<sid>.oss/.dds` (NATION_DONOR_01 §2.2/§2.5/R5); port mirror `data.gd:294-305` `NATION_UNITS`, `:1564-1567` `resolve_sid()`. |
| Building `%nat%`/`%com%` 3-letter-family prefix | `country.script:138-206`; `%com%` default `eur` (`:161`), `por/wwa/sto/mar/tur/rus` overrides (`:167-196`); own families `<nat><family>` (`:158`). |
| Russia/Ukraine share `rus*` common buildings; Bavaria uses `eur*`; no `bavmil`/`bavpor` | `country.script:161-204`; `actors.lib:71,67,311,3187,463` (NATION_DONOR_01 C5). |
| Ships family-keyed; `yachttur` and `chaika` are distinct sids, not skins | `country.script:2894,3109`; `REPORT_ASSETS_BAKING.md:176`; `V778:113-116`. |
| Build/repair → AAF `construct` | `dmscript.global:13,926`; `unit.script:10877`; `peaukr.aaf:17` (186..198 @30 fps); 2D port precedent `world.gd:489-490`. |

## 3. Before → after (post-edit line numbers)

Backup baseline `inbox/backup/world3d_entities.gd.bak-NATIONMODEL01`; final diff **+197 / −3** (3 deletions = the old `MORPH_ACTION_MAP` label and two `var sid := ed.get("sid")` lines; every other change is additive).

| # | Before (backup) | After (live) | Change |
|---|---|---|---|
| 1 | No `Data` handle | `:93` | `const Data = preload("res://scripts/data.gd")` — read-only use of canonical `resolve_sid`/`NATION_UNITS`/`PLAYER_NATIONS`. |
| 2 | `MORPH_ACTION_MAP` documented 3 states | `:193` | Label now documents `build|repair->construct when measured speed < gate`; `CONSTRUCT_SKIN_STATUS` added at `:198`. |
| 3 | No nation labels | `:202-204` | `NATION_MESH_EXACT_STATUS`, `NATION_MESH_FALLBACK_STATUS` (**BLOCKED**, Ukrainian look not fixed), `NATION_MESH_BLOCKED_EVIDENCE`. |
| 4 | `bind()` stats had no nation/construct telemetry | `:465-470` | `nation_mesh_label`, `nation_mesh_fallback_label`, `nation_mesh_usage`, `nation_mesh_blocked_evidence`, `construct_action_status`. |
| 5 | No nation recovery helper | `:655-673` | `_nation_of(ed)`: explicit `ed["nation"]` → `game.players[player].nation` (`game.gd:386`) → `Data.PLAYER_NATIONS[player]`; never writes sim state. |
| 6 | No on-disk probe | `:678-683` | `_nation_mesh_on_disk(sid)` probes `OBJ_DIR`/`GLB_DIR` only. |
| 7 | No donor building prefix rule | `:691-727` | `_donor_building_prefix()` implements `country.script:138-206` (own families, por/wwa/sto/mar/tur/rus overrides, `eur` default). |
| 8 | `add_unit` used `ed.sid` directly (`:1409-1410`) | `:736-781`, `:1597` | `_entity_mesh_sid()` picks donor-grounded candidates: unit roster sid via `resolve_sid()`, or a base sid already present in the nation's `NATION_UNITS` value list; building prefix+family; naval **no stem** (family-keyed). Result feeds `_mesh_info()` and the batch key. |
| 9 | `add_building` used `ed.sid` directly (`:1436-1437`) | `:1637` | Same helper with `kind="building"`; per-node meta carries nation/exact/status. |
| 10 | `_unit_action()` had no build branch (`:1009-1016`) | `:1177-1199` | Added dead-first build/repair→`construct` gated by measured speed (`< WALK_SPEED_GATE_M_S`); travelling builders keep `walk`; all other branches byte-identical. |
| 11 | No usage telemetry | `:783-788` | `_record_nation_mesh()` counts `family|nation|base->mesh` choices in `stats`. |
| 12 | Rotor / stage / tree / motion blocks | unchanged | No edit inside those blocks (verified by diff: insertions only outside; `MORPH_ACTION_MAP` label and `_unit_action` branch are the two requested exceptions). |

## 4. Family coverage — fixed vs still missing

| Family | Behaviour | Status |
|---|---|---|
| **Units** | For `rus` `musketeer`→`strelet`, `serdiuk`→`strelet`, `cossack`→`cossackdon`; `ukr` `priest`→`pope`; `tur` `musketeer`→`jannisary`; `alg` `cossack`→`mameluke`; `swe` `cossack`→`hackapell`; `sco` `musketeer`→`sco_highlandersword`; base sids already nation-coded (`strelet`, `sco_highlandersword`, `pope`, …) recognised from `NATION_UNITS` values. | **Selector fixed** — real nation mesh chosen when the sim sid is still generic and the OBJ exists. Trained `rus` units arrive already resolved (identity) and are recognised via the value check. |
| **Buildings** | Donor prefix probes (`ruscen`, `bavbar`, `eurmil`, `eurpor`, `turbar`, `ukrpor`, …) run against disk. | **BLOCKED** — 0/172 original OBJs carry any nation prefix (checked: only `sco_highlandersword` has a nation-like stem). Always falls back to Ukrainian-derived `cen/hou/bar/sta/bla/aca/art/dip`. |
| **Naval / ships** | No nation stem probed: hulls are family-keyed; `yachttur`/`chaika` are distinct base sids already handled by `add_unit` if present. | **BLOCKED for nation skins by donor design** — `yacht`→`yachttur` remap is not invented; `chaika` has no manifest/OBJ entry (NATION_DONOR_01 G12). |
| **Bavaria** | No `NATION_UNITS` key (`data.gd:294-305`); `musketeer18bav`/`grenadierbav` absent from manifest+obj (G8); bav buildings probe `eur*`, none on disk. | **BLOCKED** — no bav-specific 3D art exists in the port. |
| **Russia** | `pikemanrus`/`officerrus`/`pearus`/`drummerrus` absent (G9); `rus*` building prefixes absent. | **PARTIAL** — nation-unit sids that exist (`strelet`, `cossackdon`, `vityaz`, `hetman`, `pope`) are selected; Russian peasant/town-hall art still missing. |

**Explicit non-claim:** the Ukrainian look is **NOT fixed**. It is caused by manifest asset selection (`peasant→peaukr.dds`, 8 core buildings→`ukr*.osm/ukr*.dds`, 0 rus/bav-keyed textures — NATION_DONOR_01 G7/G10/C6), which is outside this file's ownership.

## 5. Follow-up owners (NOT edited by this ticket)

- `variant3d/scripts/game.gd:2702-2740` — starting army spawns literal generic sids; route through `Data.resolve_sid()` for nation variety (NATION_FLOW_01 D2).
- `variant3d/scripts/data.gd:294-305` — add `bav` `NATION_UNITS` entries only if donor-valid 18c unit sids are converted into 3D art.
- `variant3d/assets/models/manifest.json` + `variant3d/assets/models/obj/` — supply non-Ukrainian `rus*`/`bav*`/`eur*` meshes and textures; this is the load-bearing fix for the reported visual issue.
- `variant3d/tools/convert_skins.py:69-73` + regenerated skin JSON — export `construct` frames (`expected [186,188,191,193,196,198]`); until then the build-action branch can snap to death 149 / attack0 237 (BUILD-ANIM-DIAG-01 §5 step 2). `anim3d.gd` needs **no** change.
- `inbox/backup`/asset owners — STAGE-IMPORT-01: 108 new stage OBJs have **0** `.obj.import` sidecars, so runtime `load()`/render is UNVERIFIED.

## 6. Validation (variant runner only; no direct `godot`)

<!-- JOB_RESULTS -->

## 7. Optional stage integration — reported as a separate ticket

`BUILD_STAGE_INTEGRATION_01.md` proposes per-stage bbox lookup, tint re-application after mesh swap and honest stage labels. **Not applied here**, for three recorded reasons: (1) the original NATION-MODEL-01 grant froze BUILD-STAGES-01 stage logic byte-identically; (2) the plan's own owner decisions Q1 (completion scaffold), Q3 (tint policy) and Q5 (bbox authority) are unresolved; (3) two runner jobs were already queued against this file, so editing the stage block mid-flight would invalidate their evidence. `BUILD_ART_BATCH_01.md` has landed and its 172-asset hash / 280-manifest gates pass, but the Godot `load()` gate and all 108 stage `.obj.import` sidecars remain pending (STAGE-IMPORT-01). Hand off C1/C5/C7 to a BUILD-ART-C owner; no stage constant, selector or sync block was changed by this ticket.

## 8. Open questions / explicit UNVERIFIED

1. **UNVERIFIED** — visual result of any nation selector choice; no donor/port A/B capture or headless render was made.
2. **UNVERIFIED** — whether a future nation-prefixed 3D mesh (e.g. `ruspeasant.obj`) would be legal donor art or an invention; no such asset was created and none is proposed.
3. **UNVERIFIED** — captured-nation sids (`game.gd:3982-3987`) resolve through the same helper only if a matching mesh exists on disk; no special case was added.
4. **UNVERIFIED** — the V7-74 morph path in `sync()` still keys frames from the raw `ed.sid`; when a registered donor skin exists, a morph re-acquire may bypass the nation-resolved static key. Shipped runtime has no registered skin (file header), so this is latent only. Kept byte-identical per owner constraint.
5. **UNVERIFIED** — `construct` pose frames until the skin-export owner lands; `pose_for` may snap 186..198 to death 149 / attack0 237.
6. **UNVERIFIED** — whether `main.gd:275` `ukr` fallback ever fires (not primary cause; config path observed correct).
7. **UNVERIFIED** — donor engine fallback when an actor/mesh is missing (`country.script` hooks are engine-invoked; no DScript caller).

## 9. Summary

- Nation is now derived from reachable state (`ed.nation` → `game.players[].nation` → `Data.PLAYER_NATIONS[]`) and used to select donor-grounded mesh families for units, buildings and ships; all candidates are probed on disk and no asset name is fabricated.
- Unit-family selection is **fixed** for the 7 nations with `NATION_UNITS` mappings and for base sids already nation-coded. Building and naval nation art is **BLOCKED** (0 matching OBJs); the Ukrainian-derived base fallback is explicitly labelled BLOCKED / NOT VISUALLY FIXED.
- A minimal donor-cited build/repair→`construct` action branch was added to `_unit_action()`, preserving dead-first priority, the MOTION-ANIM-01 speed gate and every other branch.
- Backup taken before first edit; protected rotor, stage, tree and motion blocks preserved; no file other than the two owned paths was edited. No donor byte copied, no sim data changed, no visual-parity claim made.
