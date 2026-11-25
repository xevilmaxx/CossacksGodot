---
id: DBUILD-01
owner: DBUILD-01 (donor deep-dive micro-worker)
role: "Donor building construction stages, destruction stages, ghost/rally truth; read-only port parity check"
date: 2026-11-25
status: COMPLETE — documentation only; no code edits, no runner jobs, no donor copies, no donor execution
donor: "C:\\Games\\Cossacks 3 (READ-ONLY; Python 3.14 bytes/latin-1; no donor binary run or copied)"
method: "2 passes: (1) prior-report read (7 docs), (2) fresh donor byte/line reads across actors/buildings, objects/buildings, scripts/units/building.inc, scripts/lib/*.script, game/var/objcustom.cfg, pfx/*.{tree,pfx,mat}, sounds/interface/interface.snd. Key claims re-read by independent method."
labels: "observed / derived / inferred / UNVERIFIED"
output: "this report only"
---

# DBUILD-01 — Donor building construction / destruction / ghost–rally truth

## 1. Sources

### 1.1 Prior documents read (pass 1, all in full)

| # | Document | Used for |
|---|---|---|
| P1 | `docs/coord_swarm_2026-11-24/reports/PLAY2_04_build_ghost.md` | ghost frame regression diagnosis (CENTRED vs SIM); rally not measured |
| P2 | `docs/coord_swarm_2026-11-24/reports/PLAY2FIX_ghost.md` | F1 half-map conversion + F2 input handoff; measured 10/10 probe |
| P3 | `docs/coord_swarm_2026-11-24/reports/V776_ghost_rally.md` | ghost/rally forwarding, node counts, original probe method |
| P4 | `docs/coord_swarm_2026-11-24/reports/W31_build_rules.md` | sim build rules, default rally, refund, research gates |
| P5 | `docs/coord_swarm_2026-11-24/reports/W32_building_ux.md` | gating, build-ghost entry, rally discoverability/cursor |
| P6 | `docs/coord_swarm_2026-11-25/decomp/DEC_02_scripts.md` | script catalogue; `_unit_ControlBuildProgress` ref; PFX pool; no-weather finding |
| P7 | `docs/coord_swarm_2026-11-25/decomp/DEC_08_ui_strings.md` | rally = 3D object `rallypoint` scale 0.0525 roll 45; ghost = engine dummy + blink |
| P8 | `docs/coord_swarm_2026-11-25/reports/DFX_01_pfx_effects.md` | §7.4 "no construction dust; visible smoke = damage smoke"; FX port table |

### 1.2 Donor files freshly read (pass 2)

Path shorthand: `C3\data\` prefix omitted below; `scripts\` = `C3\data\scripts\`.

- `actors\buildings\<nat>\<nat><bld>.actor` (eng/rus/fra/tur sampled, all 25 nation dirs enumerated): mesh-slot lists.
- `actors\buildings\<nat>\<nat><bld>{1..4}.osm`, `_death1.osm`, `_death2.osm`, base `.osm` (byte sizes compared).
- `actors\buildings\<nat>\attach\<nat><bld>{a,1a..4a,_death1a,_death2a}.osm` (scaffold meshes).
- `objects\buildings\<nat><bld>.prop` (`engcen.prop` read in full: 122 lines).
- `objects\misc\rallypoint.prop`, `actors\misc\rallypoint.actor`.
- `scripts\units\building.inc\{doprogressorders,ontagstates,settagstates,deathstage1,deathstage2,ondeath,ondestroy,delaydestroy,nothing}.inc`.
- `scripts\lib\unit.script` (`_unit_ControlBuildProgress` :6572-6608; `_unit_UnitsCanBuild` :10164-10177), `scripts\lib\miscext2.script` (:955-980, :1068-1095), `scripts\lib\weapon.script` (:605-621), `scripts\lib\country.script` (:4189-4202), `scripts\sound.script` (:129,:190,:215).
- `scripts\dmscript.global` (:5-41, :44-45, :129-131, :170-184, :1119-1120, :1263-1274).
- `game\var\objcustom.cfg` (`sid = engcen` :16782, `sid = enghou` :17463, `SmokePoints` blocks).
- `pfx\fx.tree`, `pfx\source.pfx`, `pfx\material.mat` (targeted key scan).
- `sounds\interface\interface.snd` (:80-121).
- `gui\menu.inc\onshortcut.inc:266-290`, `gui\menu.inc\eventunitcontrol.inc:486-500`, `scripts\units\unit.inc\setrallypoint.inc:1-34`, `scripts\units\unit.inc\onaclanimationreachedconstruct.inc:1-53`.

### 1.3 Port files read read-only (pass 2)

`variant3d/scripts/world3d_entities.gd`, `input_controller.gd`, `world3d_fx.gd`, `world3d.gd`, `audio.gd`, `main.gd:1744-1757`; `app/scripts/game.gd:4777`. No file was edited.

### 1.4 Verification policy

Every load-bearing claim has two independent reads: (a) direct Python `bytes`/`latin-1` numbered dump, and (b) either a second targeted dump, a filesystem enumeration, a different consumer of the same value, or the prior report's independent count. Where the two disagree or no second method exists, the claim is downgraded to **inferred** or **UNVERIFIED**.

---

## 2. Construction stages — observed truth

### 2.1 Mesh inventory (OBSERVED)

`actors\buildings\eng\engcen.actor:1-28` lists **7 mesh slots** for one building:

| Slot | Mesh name | File | Role |
|---|---|---|---|
| 0 | `engcen.mesh` | `engcen.osm` (1,386,780 B) | finished/base building |
| 1 | `engcen1.mesh` | `engcen1.osm` (535,716 B) | construction stage 1 |
| 2 | `engcen2.mesh` | `engcen2.osm` (966,340 B) | stage 2 |
| 3 | `engcen3.mesh` | `engcen3.osm` (1,256,820 B) | stage 3 |
| 4 | `engcen4.mesh` | `engcen4.osm` (2,017,308 B) | stage 4 |
| 5 | `engcen_death1.mesh` | `engcen_death1.osm` (1,694,324 B) | destruction stage 1 |
| 6 | `engcen_death2.mesh` | `engcen_death2.osm` (894,156 B) | destruction stage 2 |

Stage mesh sizes grow monotonically stage 1→4 and the death meshes are distinct geometry (OBSERVED by byte counts; no visual claim). The same 7-slot pattern was enumerated for **every** nation-specificactor: 25 nation dirs, all sampled actors show `4/2` stage/death counts (§2.4).

### 2.2 Progress → stage → mesh-name mapping (OBSERVED + DERIVED)

| Rule | Evidence | Label |
|---|---|---|
| Build progress is `hp / maxhp`, clamped to 1; monotonic (`newprogress > buildprogress`) | `scripts\lib\unit.script:6583-6590` | observed |
| At `hp >= maxhp`: essential tag → `none`, visual → `none` (finished) | `unit.script:6591-6592` | observed |
| Else `stage = floor(buildprogress * 4)` → visual tags stage_0..stage_3 | `unit.script:6596-6603`; identical formula for ship dummy at `units\building.inc\doprogressorders.inc:84-93` | observed (twice) |
| Visual tag 0/1/2/3 → mesh suffix `1/2/3/4`; `actor := LODActorName + IntToStr(stage); SetGameObjectActorNameByHandle(actor+'.mesh')` | `units\building.inc\ontagstates.inc:240-251` | observed |
| Wall special case: `stage := 1 + stage div 3` → only stage 1 or 2 (walls get 2 construction meshes, no death mesh) | `ontagstates.inc:247-248`; file enumeration `commonrus\*swa*` shows `2/0` | observed |
| Essential `none` (completion) → `SetGameObjectActorNameByHandle(LODActorName+'.mesh')` = base mesh; child scaffold switched to `detail` material and made visible | `ontagstates.inc:92-126` | observed |
| State-tag constants: birth `1 shl 1`, death `1 shl 2`, visual stage_0..3 `1 shl 21..24`, visual hide `1 shl 25` | `dmscript.global:6-7,26-29,41` | observed |

**Derived stage boundaries:** progress `[0,0.25)→stage_0/mesh1`, `[0.25,0.5)→stage_1/mesh2`, `[0.5,0.75)→stage_2/mesh3`, `[0.75,1.0)→stage_3/mesh4`; `progress=1` with `hp<maxhp` is clamped to 1 → `floor(4)=4`, which the `case` does not handle, leaving the visual tag unchanged (the previous stage mesh remains until completion). This edge case is **derived** from `unit.script:6594-6603`; no runtime capture exists.

### 2.3 Scaffold / attached props (OBSERVED)

`objects\buildings\engcen.prop:72-112` defines an `autochildrenproperty` auto-child:

- `BaseName = engcena`, `RaceName = buildings`, `DefaultMeshName = engcena.mesh` (`:86-88`).
- Seven child meshes **parallel to the parent's seven slots**: `engcena`, `engcen1a`, `engcen2a`, `engcen3a`, `engcen4a`, `engcen_death1a`, `engcen_death2a` (`:90-96`). The corresponding `.osm` files exist in `actors\buildings\eng\attach\` (enumerated).
- Materials: `scaffold` for slots 0-4, `debris` for slots 5-6 (`:97-105`); `Option = achildRequered` (`:106`).
- Scale `0.646` (`:115-117`), `DefaultRollAngle = 135` (`:121`); collision AABB `:63-70`, collision mask `:45-61`.

Runtime consumer (OBSERVED): during birth, the first child's actor is switched to `actor+'a.mesh'`, material set to `scaffold`, visible = true (`ontagstates.inc:253-259`); on death the same child becomes `actor+'a.mesh'` with material `debris` (`:281-287`), misc children destroyed and remaining children hidden (`:288-304`). The scaffold is therefore a **separate, stage-synchronised attach object**, not part of the building mesh.

### 2.4 Per-nation differences (OBSERVED by enumeration)

| Nation group | Building actors | Stages/death per actor | Note |
|---|---|---|---|
| aus, bav, den, eng, fra, hun, net, pie, pol, pru, rus, sax, sco, swe, swi, ven | 10 each | 4/2 all | aca, art, ba2, bar, bla, cen, dip, hou, sta, tem |
| tur, ukr | 9 each | 4/2 all | no `ba2`; ukr has `por` |
| por, spa | 11 / 12 | 4/2 all | extra `por` (port); spa also `sto`, `mar` |
| commoneur | 12 shared | 4/2 all | coa, gol, iro, mar, mil, por, sga, sto, swa, tow, wga, wwa |
| commontur | 5 shared | 4/2 all | mar, mil, por, sto, tow |
| alg | 2 (algcen, alghou) | 4/2 | relies on shared common actors |
| commonrus | wall segments + shared | **2/0** for walls; 4/2 for rus/tur/ukr shared buildings | walls use `stage := 1+stage div 3` and no death mesh |
| mis | 22 misc objects | 0/0 or 0/1-2 | non-buildable decor/tents/chests etc; no construction stages |

**Label:** counts observed; interpretation that every nation renders the same 4-step progression is **derived** from identical file structure + identical consuming script.

### 2.5 Build hit and completion sound (OBSERVED)

| Event | Sound | Citation |
|---|---|---|
| Each construction hammer hit | `_unit_RequestPlaySound(myHnd, gc_snd_ind_workconstruct)` — **`workconstruct` only, no FX call** | `units\unit.inc\onaclanimationreachedconstruct.inc:23-43`; constant `dmscript.global:1329`; library `sound.script:190` |
| Build progress per hit | `delta = gc_buildtime_progressperhit / buildtime`; hp += `round(maxhp*delta)` | `onaclanimationreachedconstruct.inc:25-37`; `dmscript.global:179-182` (`progressperhit = 10*0.03125*1.15 = 0.359375`) |
| Completion jingle | interface-library sound `'bld' + last3(sid)`, e.g. `bldhou`, `bldcen`; `+'tur'` for `turcen/algcen/turtem/algtem` | `units\building.inc\ontagstates.inc:146-153` |
| Completion jingle assets | `sounds\interface\interface.snd:80-93` (`bldcen`, `bldhou`, `bldbar`), `:120-121` (`bldcentur`); indices `dmscript.global:1263-1274` | observed (two methods: script + sound table) |

Gates on the completion jingle: human/interface player only (`GetPlayerIndexByHandle(...)=arg_obj.pl`) and not a wall (`ontagstates.inc:146`). A log message `gc_logmessagesid_buildingbuilt` is shown at `:155-166`.

---

## 3. Destruction stages and debris (OBSERVED / DERIVED)

### 3.1 Two-stage death sequence

| Step | Code | Effect | Timing |
|---|---|---|---|
| Death tag set | `settagstates.inc:32-53` | visual → stage_0 (`_death1` mesh) unless old essential was `birth` → stage_1 directly; schedule `DeathStage1` at `gc_building_deathtime_0` | constant `dmscript.global:183` = 30 engine frames |
| DeathStage1 | `deathstage1.inc:4-13` | set essential=death + visual_stage_1 (`_death2` mesh); schedule `DeathStage2` at `gc_building_deathtime_1`; mine ×2 | `dmscript.global:184` = 30 frames; mine doubling at `deathstage1.inc:8-9` |
| DeathStage2 | `deathstage2.inc:6-22` | clear terrain collision, topology update, `GameObjectRequestToDestroyByHandle` | — |
| Mesh switch | `ontagstates.inc:264-275` | `_death1` / `_death2` actor names by visual stage; **walls skip** (`:267`) | observed |
| Scaffold on death | `ontagstates.inc:281-304` | child actor → `..._deathNa.mesh`, material `debris`, misc children destroyed, other children hidden | observed |
| Explosion | `ontagstates.inc:309-311` | `_unit_DoExplosion` when killed from none, or from birth at stage 2/3; key `grenadeexp` per DFX-01 §7.5 / `weapon.script:275-276` | observed |
| Wall death | `ontagstates.inc:313-335` | no death mesh: effects cleared, invisible, `DelayDestroy` after `gc_unit_deathtime_3 = 4` frames | observed |

**Derived timing:** `gc_frames_to_time = 0.03125` (`dmscript.global:174`) ⇒ 30 frames ≈ 0.9375 s per stage, ≈1.875 s total (×2 for mines). Label: derived (units are engine-time frames; no wall-clock capture).

### 3.2 Destruction debris (OBSERVED)

- Building explosion weapons spawn physical debris: `weapon.script:605,609-611` — `PUEXPBLD`, `PUNOEXPBLD`, `PUEXP` on `gc_obj_explmedia_building` spawn **5–9 `debriswood` children**; `gDestructListBuilding` adds `debrisstone` (`:615-616`).
- `debriswood`/`debrisstone` projectiles defined `weapon.script:381-382` (gravity `gc_weapon_gravity_3`, propagation random), trails `fragtrail` (`:438-439`), props `objects\misc\pfx\debris_{wood,stone}.prop` (DFX-01 §3.3/§7.3).
- The scaffold attach's death mesh material is literally `debris` (`engcen.prop:104-105`; `ontagstates.inc:286`).

No separate "rubble pile" object was found; the visible rubble is the `_death1`/`_death2` meshes + flying debris projectiles. **Inferred** synthesis; each component is observed.

---

## 4. Ghost / rally / placement-validity rules

### 4.1 Build ghost (OBSERVED; appearance detail UNVERIFIED)

| Rule | Evidence |
|---|---|
| Entry gate: selected unit must include a peasant (`_unit_UnitsCanBuild`) and cost payable (`_unit_CanApplyCostByID`); only then create dummy | `gui\menu.inc\onshortcut.inc:270-283`; `scripts\lib\unit.script:10164-10177` |
| Ghost is a **game object** created on the misc player: `_player_CreateConstructionDummyBySID(miscplhnd, cid, sid, mx, mz)` at current mouse world coord | `onshortcut.inc:278-283`; `eventunitcontrol.inc:487-490` |
| Blink modes: `gc_gui_blinkmode_canbuild = 0`, `cannotbuild = 1`; `_unit_DoConstructionBlinkGameObject(hnd, mode, False, False)` | `dmscript.global:1119-1120`; `onshortcut.inc:286`; `eventunitcontrol.inc:493` |
| Validity driver: `_misc_CanPlaceBuilding(goHnd, plInd, usage, x, z, gc_path_mincoldist=1, 0.26, 0.5, gc_path_minemincoldist=3.24)` → canbuild / cannotbuild | `lib\miscext2.script:1075-1091`; constants `dmscript.global:44-45` |
| Wall mode additionally arms `gWallCluster.SetWallBuildMode(...)`; wall cells blink independently and single ghost hides when a cluster exists | `eventunitcontrol.inc:495-496`; `miscext2.script:965-972`, `:1082-1094` |
| Cancel: `_misc_GUICancelBuilding(True,False)` / `GameManagerCancelBrush`; cursor `crConstruct` index 7 (`construct.bmp`, hotspot 1,1) | P7 §6.4 (`onshortcut.inc:283-286`, `eventunitcontrol.inc:490-496`, `cursors.lib:152-160`) |
| **Ghost colour / size / exact mesh: UNVERIFIED** — no donor config defines it; engine dummy + blink only | P7 §6.4; P8 §7.4 |

Editor-only placement snap `x := floor(x*2)/2 + 0.25` (`onmousemove.inc:111-112`, P7 §6.4) is **not** the skirmish ghost and must not be ported as such.

Port-side (read-only, from P1/P2/P3 + fresh reads): 3D ghost state is translated in `world3d.gd:463-498` (sid → `in_bounds` → `resolve_mine_sid` → `Data.BUILDINGS` → `can_place(0,sid,wp).ok` → `_can_pay_building`), FIX-GHOST F1 converts the camera's CENTRED hit to SIM (`world3d.gd:424-436`) and F2 forwards the input's SIM point (`input_controller.gd:1298-1306`). FX draws a translucent green/red footprint box (`world3d_fx.gd:409-428`, `:610-622`, `:1062-1072`). No donor colour/size exists to compare against — **semantic parity, visual parity UNVERIFIED** (P2 §5).

### 4.2 Rally (OBSERVED)

| Rule | Evidence |
|---|---|
| Rally flag is a **3D game object**, not a GUI sprite: for each selected object with `brally` and `bcansetrally`, `CreatePlayerGameObjectHandleByHandle(..., 'rallypoint', rallyx, 0, rallyy)` + `_misc_CreateEffectZTest` | P7 §6.3 (`showrallypoints.inc:18-31`); freshly re-read |
| Object record: `objects\misc\rallypoint.prop:4-5` name, `:9-10` actor/mesh, **`:19-21` DefaultScale = 0.0525 (X/Y/Z)**, **`:25` DefaultRollAngle = 45**, `:29` terrain/water collide option; mesh `actors\misc\rallypoint.actor:2-3` → `rallypoint.osm` | OBSERVED (fresh read); corroborates P7's "scale 0.0525 roll 45" |
| Setting: right-click on selected trainer → `SelectedUnitsSetRallyPoint(x,z)` → `_unit_SetRallyPoint(goHnd,x,z,true,true)`, `gbool_gui_update_rallypoints := True` | P7 §6.3 (`onmousedown.inc:8-18`); `units\unit.inc\setrallypoint.inc:6-19` (uses last exit point; transport validity) |
| Spawn semantics: units spawn at last exit point (or port resource point); rally is the gather/exit point | `scripts\units\building.inc\doprogressorders.inc:247-270`; P4 §"default rally existed" (`game.gd:2087-2093`) |
| Default rally on completion and re-arm on capture (port-side rule, donor-derived) | P4 `:38-40,71-78` (W31) |
| Cursor: `crSetRallyPoint` index 8, FileIcon = `default.bmp` (no dedicated raster) | P7 §6.3 (`cursors.lib:161-167`) |

Port: `world3d.gd:505-523` walks selected player-0 buildings with a `rally` field → `fx.draw_rally(rp, 0)`; `world3d_fx.gd:433-446,824-855` builds a procedural pole + finial + foot + player-coloured plane pennant; markers cached by 0.5 m rounded point and expire after `RALLY_TTL = 2.0 s` (`:133`, `:1047-1059`). **APPROXIMATED** — the donor `rallypoint.osm`/`.dds` is private-use and uncopied; scale 0.0525 / roll 45 are not reproduced (port pole is 1.6 m).

---

## 5. Smoke / dust / debris truth — DFX-01 verification

### 5.1 DFX-01 restated

P8 §7.4/correction 7: "no construction dust FX exists; construction hits are sound-only; visible building smoke is damage smoke gated by HP thresholds; `buildingsmoke` = `fx.tree:418-442`, sources `source.pfx:1808-2159`; `GetOrCreate('buildingsmoke', effHnd)` at `building.inc\nothing.inc:78,383`."

### 5.2 Second method (independent of P8's chain reconstruction)

Four independent checks, all consistent with P8:

1. **Targeted key scan of effect data** (new method): `pfx\fx.tree` has 24 effects; grep for `construct|dust|build|birth` yields only `impactdust` (`:274-278`), `buildingsmoke` (`:418-442`), `buildingfire*`, `cannonexpbuilding`, `towersmoke` — **no construction-dust key**. `pfx\source.pfx` likewise has no construction source; `pfx\material.mat` has `buildingsmoke`/`buildingfire` only. Label: observed.
2. **Construction-hit consumer** (fresh read): `units\unit.inc\onaclanimationreachedconstruct.inc:23-43` advances build hp and calls `_unit_RequestPlaySound(..., gc_snd_ind_workconstruct)`; **no effect call anywhere in the file**. Label: observed.
3. **Smoke block is gated on `bbuilt`** (fresh read): `units\building.inc\nothing.inc:17-22` wraps the smoke logic in `if arg_obj.bbuilt then`; the unbuilt branch (`:298-307`) only does capture checks and `_unit_ControlBuildProgress` — no smoke. A building **under construction cannot emit `buildingsmoke`**. Label: observed.
4. **Smoke caller is the damage path**: `nothing.inc:75-78` creates a `point` at `smokePoints[i]` and calls `gEffectLibrary.GetOrCreate('buildingsmoke', effHnd)`. The `buildingsmoke` composition is fire/smoke (`fx.tree:422-442`), not dust. Label: observed.

**Verdict:** DFX-01 is **CONFIRMED and refined**. Refinement: the visible smoke is not merely "damage smoke at HP thresholds" — it is emitted **only by finished (`bbuilt`) buildings**, scales with damage from ~88.75 % HP down to the slow-death floor, and `bslowdeath` buildings keep burning at a clamped low HP. Construction dust is ABSENT in readable data; the named `buildfire*_birth` / `buildsmoke*_birth` / constructor `debris.dds` materials have **no readable consumer** → engine-internal birth FX **UNVERIFIED** (P8 §12 Q5).

### 5.3 Exact damage-smoke thresholds (OBSERVED formula / DERIVED numbers)

`units\building.inc\nothing.inc:31-83` (client/replay) and the near-identical `:336-386` (server/offline) — two independent reads of the same rule:

```
cSmokeHPLimit = 0.85
maxhp = objbase[pl][cid][id].maxhp
S = bslowdeath ? Max(gc_BuildingSlowDeathHP, maxhp div 4) : maxhp div 4   # dmscript.global:129 = 1999
smoke starts if smokecount > 0 OR (hp - S) < (maxhp - S) * 0.85
maxind = floor( (1 - ((hp - S)/0.85)/(maxhp - S)) * smokeCount ), min -1
emitters added one per (progresstick mod 7 == 0) with prob freq = min((1 - 0.5*diff/smokeCount)*0.8, 0.8)
```

Derived numbers:

- Non-slowdeath `S = maxhp/4` ⇒ first smoke when `hp < 0.85*maxhp + 0.15*(maxhp/4) = 0.8875*maxhp` (**88.75 % HP**).
- `maxind = 0` at that threshold; `maxind = smokeCount` at `hp = S` (full smoke).
- Slow-death buildings (`bslowdeath`, e.g. town halls): `S = max(1999, maxhp/4)`; when `hp <= 1999` and `>10` the HP is clamped to `1999 - floor(random*300)` (`lib\miscext.script:1149-1152`, :1410-1413; `dmscript.global:130` = 300), so the building smoulders instead of dying.
- `smokeCount` and each emitter's local position/normal come from `game\var\objcustom.cfg` `SmokePoints` blocks (e.g. `engcen` at `:16805+`, `enghou` at `:17470+`), parsed at `lib\country.script:4189-4202`; max 80 points (`dmscript.global:164`).

Label: formula observed; percentages/clamp consequences derived; no visual capture.

### 5.4 Port smoke/debris parity (read-only)

`world3d_fx.gd:63` explicitly records "NO construction dust: DFX-01 §7.4". The port's `smoke` FX is a generic crossed-quad effect with fixed `LIFE.smoke = 1.6 s` (`:75`, `:780-784`, `:993-996`) fed by generic `done`/`smoke` events; **no HP-threshold gate, no `buildingsmoke` binding, no smoke-point positions, no slow-death floor**. Death audio uses `deathbuilding1` (`main.gd:1745-1746`); completion audio uses `audio.building_sound(ev.kind)` (`main.gd:1752`, `audio.gd:412-421`, event from `app/scripts/game.gd:4777`) with donor-style `bldXXX` names but a fixed sid map + `construct` fallback and no interface-player/wall gate. Destruction debris projectiles: **not implemented** in the 3D port. Labels: port code observed; parity gaps derived.

---

## 6. Port parity matrix (read-only; donor truth primary)

| Donor feature (cite) | `variant3d` state (cite) | Verdict |
|---|---|---|
| 4 progressive construction meshes + base (`engcen.actor:1-19`; `unit.script:6596-6603`) | `world3d_entities.gd:1273-1305` — one static donor mesh per building, named `_STATIC_POSE`; `finished` only toggles mill rotor at `:1579` | **MISSING** |
| Scaffold auto-child with stage-matched meshes + `scaffold`/`debris` materials (`engcen.prop:72-112`; `ontagstates.inc:253-259,281-287`) | no scaffold node/material anywhere in entities/fx | **MISSING** |
| Walls use 2 stage meshes, no death mesh (`ontagstates.inc:247-248`; `commonrus` file count) | no wall-specific stage handling | **MISSING** |
| Per-hit build sound `workconstruct` (`onaclanimationreachedconstruct.inc:42-43`) | `audio.gd` has `work_sound()` for resources; no per-build-hit sound call found in 3D event path | **UNVERIFIED / likely absent** |
| Completion jingle `bld<sid>` human-only, non-wall (`ontagstates.inc:146-153`; `interface.snd:80-121`) | `main.gd:1752` + `audio.gd:412-421` on `done` event (`game.gd:4777`); `bldXXX` map + `construct` fallback | **PRESENT / APPROXIMATED** (no interface/wall gate; fixed map) |
| Death `_death1/_death2` meshes, 30+30 frames (`dmscript.global:183-184`; `deathstage*.inc`) | no death-stage mesh swap; buildings simply removed from `entities` | **MISSING** |
| Building explosion + 5-9 debris projectiles (`weapon.script:605-621`) | generic `explode` sphere+light (`world3d_fx.gd:785-791`); no debris children | **APPROXIMATED / MISSING debris** |
| Ghost = engine dummy + canbuild/cannotbuild blink (`onshortcut.inc:283-286`; `miscext2.script:1075-1091`) | green/red translucent footprint box; validity gates in `world3d.gd:463-498`; FIX-GHOST frame correction `:424-436`, handoff `input_controller.gd:1298-1306`; `world3d_fx.gd:409-428` | **SEMANTIC PARITY**, appearance **UNVERIFIED** (donor colour/size unknown) |
| Rally = 3D object scale 0.0525 roll 45 (`rallypoint.prop:19-25`) | procedural pole/pennant `world3d_fx.gd:824-855`; TTL 2 s (`:133`) | **APPROXIMATED** (no donor asset; scale/roll not reproduced) |
| Damage smoke at HP thresholds, `buildingsmoke`, smoke points (`nothing.inc:31-83`; `objcustom.cfg:16805+`) | generic smoke quad, fixed 1.6 s, event-driven (`world3d_fx.gd:75,780-784,993-996`); no HP gate | **APPROXIMATED / partial** |
| Construction dust absent (DFX-01 §7.4 + §5.2 above) | explicitly not implemented (`world3d_fx.gd:63`) | **PARITY (correct absence)** |
| Placement validity `gc_path_mincoldist=1`, minemincoldist=3.24 (`dmscript.global:44-45`; `miscext2.script:1086`) | `game.can_place(0,sid,wp)` + `resolve_mine_sid` + affordability (`world3d.gd:475-498`, W31/W32 gates) | **PARTIAL** (different constants; donor numeric rules not ported verbatim) |
| Editor snap `floor(x*2)/2+0.25` (`onmousemove.inc:111-112`) | no snap in 3D ghost | **N/A** (editor-only donor behaviour) |

No visual/GPU parity claim is made for any row; the harness cannot capture 3D pixels (P3/P8 honest limits).

---

## 7. Corrections / refinements to prior docs

1. **DFX-01 §7.4 refined** (confirmed, not overturned): construction dust is absent; additionally the damage-smoke block is gated on `bbuilt`, so **unfinished sites never smoke**. The onset threshold derives to ~88.75 % max HP for non-slowdeath, with a `1999 - rand(300)` smouldering floor for `bslowdeath` buildings — numbers not stated in P8.
2. **P7 §6.4 "ghost colour/size UNVERIFIED" stands**, and is now backed by a second method (targeted `onshortcut.inc`/`miscext2.script` read): the donor ghost is only a dummy + blink mode; there is no readable colour/geometry config to reproduce. The port's green/red box cannot be judged donor-exact.
3. **V776/P2 ghost framing**: P3 measured node state with a manual override; P1/P2 then found the real-play CENTRED-vs-SIM fault and fixed it. This report confirms the current port files contain F1 (`world3d.gd:424-436`) and F2 (`input_controller.gd:1298-1306`) — but **F2 runtime ordering remains UNVERIFIED** (P2 §5 Q2).
4. **Stage count wording**: earlier docs (e.g. W32 "under construction" HUD string) treat construction as a single state; donor truth is **4 discrete stage meshes + scaffold**, selected by `floor(progress*4)`.
5. **Death stages**: earlier FX/death docs cover unit `deathstage1..4` (4 stages); buildings have only **2** death stages with 30+30 frame timings and mine ×2. Do not generalise the unit sequence to buildings.
6. **Rally flag**: P7's "scale 0.0525 roll 45" independently re-verified at `rallypoint.prop:19-21,25` (fresh bytes) — **CONFIRMED**.
7. **Completion sound**: P8's FX list did not cover audio; the donor completion jingle is `bld<sid>` on the interface sound library (`interface.snd:80-121`), distinct from the per-hit `workconstruct`.

---

## 8. Open questions (UNVERIFIED)

1. **Stage mesh visual content** — `.osm` are binary; stage geometry progression is inferred from monotonically growing byte sizes and the mesh-name mapping, not from a rendered image.
2. **Ghost appearance** — donor dummy's rendered colour/size and the exact blink shader behaviour are engine-side; no readable config (P7 §6.4, P8 §12).
3. **Construction birth FX** — `buildfire*_birth`, `buildsmoke*_birth`, `materials\buildings\constructor\debris.dds` have no readable selector; engine-internal use UNVERIFIED.
4. **Smoke unit conversion** — `PixelRatio`, `Interval`, `AlphaTime` have no recovered conversion to seconds/metres (P8 §12 Q1); the 88.75 % HP threshold is exact in HP-ratio terms but its on-screen density is not captured.
5. **Port F2 ordering** — per-frame `set_build_ghost_pos()` vs `world.sync()` in a live windowed session remains one-frame-lag UNVERIFIED (P2 §5 Q2).
6. **Port stage visuals** — no selftest asserts construction/death stage meshes; whether the 2D port's `world.gd` draws any under-construction approximation was not part of this ticket's comparison scope.
7. **Wall/rally interaction** — wall actors have no death mesh and are excluded from scaffold child handling at `:253`/`:281` by `bgate`/`bwall`; exact wall-rally behaviour UNVERIFIED.
8. **Nation-specific completion jingles** — `bldcentur`/`bldtemtur` exist for four sids; other nation-specific jingle variants were not exhaustively enumerated beyond `interface.snd:80-121`.

---

## 9. Summary

- **Construction** is a 4-stage visual progression (`floor(progress*4)` → mesh suffix 1-4), plus a finished base mesh, with a **stage-synchronised scaffold attach child** (`scaffold` material) and 2 death meshes (`debris` material). Every nation-specificactor follows the pattern; walls use only 2 stages and no death mesh.
- **Destruction** is 2 timed stages (30+30 engine frames, ×2 mines): `_death1` → `_death2` → destroy, with an explosion and 5-9 wood/stone debris projectiles on building-media explosions.
- **Ghost** is an engine construction dummy with canbuild/cannotbuild blink gated by peasant presence + affordability + `_misc_CanPlaceBuilding`; donor colour/size is UNVERIFIED. **Rally** is a real 3D object (`rallypoint`, scale 0.0525, roll 45), selected-object gated, with exit-point spawn semantics.
- **DFX-01 confirmed with a second method**: no construction dust; visible building smoke is `buildingsmoke` on finished buildings only, onset ≈ 88.75 % HP, scaling to full smoke at the slow-death floor (1999 HP).
- **Port parity**: ghost/rally semantics and completion audio are present/approximated; the 4 construction stage meshes, scaffold, 2 death stages, HP-threshold smoke, and debris projectiles are **missing or approximated**. No visual-parity claim.

*End of DBUILD-01 report. Read-only donor recon; no donor executable run, no donor bytes copied, no code edits, no runner jobs. Every donor fact cites a path:line; uncertainties are labelled.*
