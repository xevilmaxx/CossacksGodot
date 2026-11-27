---
id: DEC-U-UNIT-DEATH-ART
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: "WORKER DEC-U-UNIT-DEATH-ART — donor 1:1 static recovery of the exact UNIT death sequence"
owner_file: docs/terrain_swarm_2026-11-26/reports/DEC_U_unit_death_art.md
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_ASSET_CONFIG_GODOT_GIT_EDIT
created: 2026-11-26
labels: [O, D, I, U, NO_PARITY_CLAIM, NO_APPROXIMATION]
parity_guard: "NO DONOR PARITY IS CLAIMED. No same-camera donor/port A/B frame was produced or examined. Every donor statement is a read-only file:line/byte observation; every port statement is a read-only source line. 'Required donor-faithful replacement' names the algorithm to implement, not a claim it is implemented."
scope_guard: "Exactly one repo file written (this report). No source, shader, config, asset, fixture, test, runner, Godot, git or user-mod edit. Donor binary and donor data tree read READ-ONLY; no donor executable run, no donor bytes copied into the repo. Singleplayer skirmish only."
donor_pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE x86, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c. All binary-touching statements below are carried from prior pinned reports; this worker ran donor-TEXT passes only (no binary executed here)."
port_scope: "variant3d/scripts/world3d_entities.gd + variant3d/scripts/world3d_fx.gd (read-only line citations; no edit)"
prior_reports_read:
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_entities_art_collision.md (§4 U14 ghost/rally/death-smoke + TTLs [U]; §6 P5-P7)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_death_families.md (§2 shared building selector; §3-§5)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_ghost_blink.md (§2 blink law; §3 placement ghost)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_aaf_art_audit.md (AAF census)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_objects_anim_collisions_fx.md
---

# DEC-U — unit death art / TTL / corpse-removal decomp (donor 1:1)

> READ-ONLY. Singleplayer skirmish only. Network excluded. No parity claim. No approximation endorsed.
> Each `[U]` below ends in either a static verdict with cited file:line, or a named fixed-camera capture with a zero-mismatch termination rule. Nothing is closed by a port fallback. No art asset or TTL is invented.

## 0. Verdict up front

1. **[O]** Land-unit (infantry/cavalry) death uses **no mesh swap, no debris child, no ghost, no smoke, no explosion**. Same `.oss` mesh; AAF `death/death0/death1/death2` by weapon tag; 55° random roll for infantry; `acmPlayOnce/aamPlayOnce`; death-desync `IntervalFactor 0.7+random*0.6`. Corpse persists through a two-stage alpha fade (`1→0.4`, then `0.4→0`, key `'death'`, `TXLifeColorEffect`, `Loop=False`, `bmTransparency`) with a sink step between (`TXMoveRotateWaveBehaviour`, 10 nodes), then `RequestToDestroy`. All timings are the `gc_unit_deathtime_*` family with stated random dispersion (table §2).
2. **[O]** Artillery death **reloads props** to `<basename>_death` (`cannon_death.prop` etc.: `LODActorName=<base>_death`, material stays the base albedo, `FrameAnimationCyclesLibName=<base>_death`) and plays the single-row `<base>_death.aaf` `"death"` clip (e.g. `cannon_death.aaf:4` `[1,33]`). No `_death1/2` numbered meshes exist for artillery — that numbering is ships/buildings only.
3. **[O]** Ship death swaps hull meshes `<parent>_death1 → _death2` (timed, §3) + attach `<parent>_deathNa` child made visible; children `1..n-1` hidden. Child material is the **parent ship material** (e.g. `frigate`), NOT `debris` — the donor has the `debris` line present but commented out (`ontagstates.inc:992`), with a `yacht` hard-code exception. Ship death fires `_unit_DoExplosion` (destruct-list projectiles + `expflash`) and `deathship` sound only when entering from `essential_none` and built.
4. **[O]** `_unit_DoExplosion` is gated to **buildings and water units only** (`unit.script:11420ff`, `((bbuilding and usage<>weakwall) or (bship and usage<>fisher))`). Land units never explode at death — `grenadeexp/expflash` (`weapon.script:270-276,367,374; fx.tree:216-221,398`) are building/ship-death FX, never unit-corpse FX. `MyGameObjectPFXClear` in `DoDeath` affirmatively clears all PFX at death entry; zero smoke attaches at/after unit death.
5. **[O]** Ghost art (`constructiondummy`/`box.mesh`, `unit.script:6674-6805` blink) is **placement-only**, never a death visual. Rally point (`rallypoint.mesh`) is unrelated to death. Both stay `[U]` per `DEC_U_entities_art_collision.md §4.2` / `DEC_U_ghost_blink.md §8` for their own lanes; this report adds no new ghost/rally fact except the negative: **no ghost/rally call exists on any unit death path** (full `unit.inc/*.inc` grep, §1.1 P9).
6. **[U] time base.** All `gc_unit_deathtime_*` values are recovered literally (file:line table §2), but the wall-clock unit of `GameObjectMyDelayExecuteState('DeathStageN', time)` is **not proven in text** (seconds assumed by convention only — never asserted). Every still-`[U]` item (§5) carries a fixed-camera capture with zero-mismatch termination.

## 1. Method, labels, passes

- **[O]** = observed donor file line / directory entry / byte count / port line. **[D]** = arithmetic over cited [O]. **[I]** = reading without runtime proof. **[U]** = unresolved after the passes here.
- Path shorthands: `D:` = `C:\Games\Cossacks 3\data\` (read-only). `P:` = workspace `variant3d\`.
- This worker ran **donor-text multi-passes only** (no donor binary executed, no Craft Anything binary-decomp call). Evidence for each pass is the cited donor `path:line` itself, verified by a second read where the ledger says so. Pin `t_87f0f3c130b0` is cited for corpus identity; binary VAs below are carried from prior pinned jobs, not re-derived here.

### 1.1 Pass ledger (multiple passes; strange-read log inline)

| Pass | Operation (read-only) | Result |
|---|---|---|
| P1 | `dmscript.global:183-194` TTL block + `:1003-1006` unit types + `:1250,1303-1309,1334` sound indices | `gc_unit_deathtime_0=2/_1=20/_2=20/_2art=30/_3=4/_0ship=10/_1ship=10/_2ship=35/_3ship=30` [O]; `inf=0/cav=1/art=2/ship=3` [O]; `deathart=52/deathbld=53/deathinf=54/deathcav=55/explcannon=57/explhowitzer=58/deathship=83` [O] |
| P2 | Full read `unit.inc/ontagstates.inc` death branch (~`:555-625`) + `DoDeath` proc head | Entry: `OnDeath` once → `DoDeath` (PFX clear, playable/track/pick off, `acmPlayOnce/aamPlayOnce`, controler off, 4× `OnState*Reached` cleared, collision off, inf-only ±55° roll) [O]; hide-branch (`acmNone/aamNone`, `DeathStage4` after `_3`) vs built-branch (`DeathStage1` after `_0`/`_0ship`) vs unbuilt-ship-branch (hide + `DeathStage4`) [O] |
| P3 | P2 continued: weapon→anim select, artillery reload, desync, sound select | `none→death/0→death0/1→death1/2→death2` with `_unit_IsAnimationExists` fallback to `death` [O]; artillery `ReloadGameObjectProperties(hnd,'',basename+'_death')` + post-switch `GameObjectResetFrameAnimationBlend` [O]; `IntervalFactor 0.7+random*0.6` [O]; sound `inf→deathinf/cav→deathcav/art→deathart`, ship `deathship` on `iOldEssential=none` entry [O] |
| P4 | Full reads `unit.inc/deathstage1..4.inc` (4 files) | DS1 fade `1→0.4` key `'death'` + dispersion `time := 2+time-random*(time/1)` + `Delay DeathStage2` [O]; DS2 sink `TXMoveRotateWaveBehaviour` 10-node `0.05` step (`0.125` art, `0.625` ship) + `DeltaTime 0.99` kick + dispersion `disp=random*(deftime/1.2)` [O]; DS3 fade `0.4→0` + dispersion `2+time-random*time` [O]; DS4 `BehaviourClear + RequestToDestroy` [O] |
| P5 | Full reads `unit.inc/ondeath.inc` + `ondestroy.inc` + `settagstates.inc` death arm | `OnDeath`: walk-sound counter removal + scenario-list removal + `SwitchTo('Nothing')` + `_unit_DestroyObj` [O]; `OnDestroy` re-enters `OnDeath` if `not bdead` [O]; set-tag death arm forces `stage_0` for water units, strips `move_walk/turn→idle`, clears `execute_move` [O] |
| P6 | `unit.script:11420ff` `_unit_DoExplosion` full body + `weapon.script:270-276,367-390,554-558,614-622` + `fx.tree:216-221,398` | Explosion gated buildings/ships only; per-mask-cell `RandomExt<0.33` spawn from `gDestructListBuilding/Ship` + terminal `expflash` [O]; destruct lists = `debrisstone×2 + PUEXPBUILDINGDEATH(grenadeexp)` / `debriswood×2 + PUEXPKORDEATH(grenadeexp)` [O]. Land units excluded by the gate [D] |
| P7 | `sound.script:127-136,343-361` library registration + `D:sounds/units/` listing | `deathart1-2/deathbuilding1-2/deathinf1-6/deathcav1-6/deathship(×3)` + `burn1-7` + `cannonexpl1-3` sample files [O]; `deathinf/cav/art` indices reused for the `36x` variant lanes [O] |
| P8 | `actors/units/peaukr.actor` + `objects/units/peaukr.prop` + `refunit.prop` full reads | Peasant actor: single mesh `peaukr.mesh`, no `_death` slot, `FrameAnimationCyclesLibName=peaukr` [O]; child0 = tools (`axe/bag/cart/hammer/hoe/lumber/pick`, all `peaaustools`) [O]; unit AABB `(-0.25,-0.10,-0.25)..(0.25,0.90,0.25)`, scale `0.5³` inherited [O] |
| P9 | Grep `D:scripts/units/unit.inc/*.inc` for `ebris|moke|renade|xpflash|_DoExplosion|DoSemi|MoveRotateWave|gc_snd` + `objects/units/*.prop` for `_death|debris` | Land `.prop` files: **zero** `_death`/`debris` hits; only ships (`frigate/chaika/ferry/fishboat/galley/battleship/xebec/yacht/yachttur` `Mesh[5/6]=*_death1a/2a` [O]) and artillery `_death` props. `debris` string: zero hits in `unit.inc/*.inc` except the commented-out ship line [O]. Zero smoke/grenade attaches on death paths [O-negative] |
| P10 | `actors/units/cannon(_death).actor` + `cannon_death.prop` + `cannon(_death).aaf` + `frigate.actor` + `frigate.aaf` + `hussar.aaf` + `frigate.prop:74-114` | Artillery: `cannon_death.aaf` = 1 row `"death",1,33` [O]; `cannon_death.prop` material `cannon`, cycles `cannon_death` [O]. Ship: 7-slot actor (`frigate..4 + _death1/2`), `frigate.aaf` = 4 identical `[1,280]` rows (`idle/walk/death/attack0`) [O]; `hussar.aaf` `death [49,119]` [O]; `peaukr.aaf` `death [115,149]` [O]; `musketeer.aaf` `death [433,495]/death1 [498,559]/death0 [564,628]` [O]; ship attach `Mesh[5/6]=*_death1a/2a`, materials all `frigate` (not debris) [O] |
| P11 | `_death*` byte sizes under `actors/units/` + `mortar/howitzer/multicannon/framegun_death.oss` + `peaukr_tools` attach | Ship `_death1/2.osm` 106–935 KB present [O] (§3 table); artillery `_death.oss` 77–193 KB present [O]; land inf/cav have no death mesh at all [O-negative] |
| P12 | Port reads `world3d_entities.gd` (death consts, `_death_mesh_cache`, stage rule, sync) + `world3d_fx.gd` (LIFE, DONOR_DEATH_FX_TTL, ghost) + `data.gd` (`PUEXPBUILDINGDEATH`, `PUEXPKORDEATH`, deathtime consts) | Port building-death lane complete; **unit-corpse fade/sink/TTL/dispersion/death0-2 gating not implemented** — port resolves `dead→death` only (MORPH_ACTION_MAP) [O]. No port line drives `TXLifeColorEffect 'death'` or `TXMoveRotateWaveBehaviour` for units [O-negative] |

**Strange-read log (required):** (a) `Get-Content -Skip` is not a parameter in the available PowerShell build — switched to `Select-Object -First/-Last` windowing; donor bytes untouched. (b) `dmscript.global` lives at `D:scripts/dmscript.global`, not `D:scripts/lib/` — first probe missed, re-pathed. (c) `frigate.aaf` rows are four byte-identical `[1,280]` ranges (donor quirk: one shared 280-frame take aliased to four names) — recorded, not normalised. (d) `ontagstates.inc:992` keeps a commented-out `SetGameObjectMaterialNameByHandle(child,'debris')` next to the live `yacht` hard-code — the comment is evidence of a reverted debris decision, not a live path. No branch polarity was guessed; no binary bytes were interpreted in this job.

## 2. Exact unit death sequence (donor text, in order)

### 2.1 Death entry — `unit.inc/ontagstates.inc` `switchEssential=essential_death` arm (~`:555-625`)

1. `if (not arg_obj.bdead) and ((not bship) or (arg_obj.bbuilt))` → `GameObjectExecuteStateByHandle(myHnd,'OnDeath')` once [O]. `OnDeath` (`ondeath.inc`): remove walk-sound counters, drop scenario-group membership, `SwitchTo('Nothing')`, then `_unit_DestroyObj` [O].
2. `DoDeath(myHnd)` [O]:
   - `SetGameObjectMyPlayableObject(False)`, track `mmNone`, rotate `trmNone`, **`MyGameObjectPFXClear`** (all attached PFX destroyed — zero smoke/fire survives death entry [O]), `SetGameObjectMyPicked(false)` [O].
   - Non-water only: `acmPlayOnce + aamPlayOnce` [O]. (Water units keep the mode set by the ship branch.)
   - `AnimationControlerEnabled(False)`; clear `OnStateStartCycles/EndCycles/FBEndCycles/Direction/EndPoint/CollectingPointReached` [O]; `SetGameObjectMyCollisionDetection(False)` [O].
   - Infantry only (`_misc_GetUnitType=inf`): `GameObjectMyRoll(-55+random*110)` degrees [O] — the corpse scatter. Cavalry/artillery/ships: no roll [O-negative].
3. Branch [O]:
   - `iVisual=hide` (inside mine/transport): `DoDeath` + `acmNone/aamNone` + `OnStateDestroy=''` + cancel + `DelayExecuteState('DeathStage4', gc_unit_deathtime_3)` — destroy after `_3`, no corpse visual at all [O].
   - `arg_obj.bbuilt` (normal case): cancel + `DelayExecuteState('DeathStage1', SwitchFloat(gc_unit_deathtime_0, gc_unit_deathtime_0ship, bship))` [O]; then ship vs land split (§2.2/§2.3). `gc_unit_deathtime_0(_ship)` is therefore the **death-anim play window** before fading starts [D].
   - Unbuilt ship: hide + `DelayExecuteState('DeathStage4', gc_unit_deathtime_3)` [O].

### 2.2 Land branch (infantry / cavalry / artillery, `bship=False`)

1. Weapon→anim [O] (`ontagstates.inc` ~`:580-590`): `none→death`, `0→death0`, `1→death1`, `2→death2`; fallback to `death` if the weapon anim is absent (`_unit_IsAnimationExists` guard) [O]. Port impact: `death0/1/2` gating is donor law; the port's `dead→death` single mapping is a stand-in (see §6 U-A).
2. `DoDeath` runs **after** anim selection (comment in source: "run animation after do death") [O]; then [O]:
   - artillery only (`_misc_GetUnitType=art`): `ReloadGameObjectProperties(hnd,'',basename+'_death')` — swaps the prop to `<base>_death.prop` (material stays the base albedo, e.g. `cannon`; cycles switch to `<base>_death`, whose AAF holds the single `"death"` row) [O]. Infantry/cavalry: **no prop reload, no mesh swap** [O-negative].
   - `GameObjectMySwitchToTreeAnimationCyclesBlend(anim, False,False,False,False, 6, 8)` (blend 6/8 = `min/maxFrameBlend`) [O]; artillery second `GameObjectResetFrameAnimationBlend` after switch [O].
   - `SetGameObjectIntervalFactorByHandle(myHnd, 0.7+random*0.6)` — per-corpse anim-speed desync, visual only [O].
3. Sound (land, `gSoundManager.bprocess` gate) [O]: `inf→gc_snd_ind_deathinf (54)`, `cav→deathcav (55)`, `art→deathart (52)`; `none→none` (silent). Samples: `deathinf1-6.ogg / deathcav1-6.ogg / deathart1-2.ogg` (`sound.script:127-134`, `D:sounds/units/`) [O].
4. No explosion, no PFX attach, no debris, no ghost on this path [O-negative] (gate §4).

### 2.3 Ship branch (`bship=True`)

1. Entry (built, from `essential_none`): `DoDeath` + `_unit_DoExplosion` + `deathship` sound (`gc_snd_ind_deathship=83`, sample `deathship.ogg` ×3 registrations) [O] (`ontagstates.inc` ~`:571-579`). Explosion = §4 payload. From any other old-essential: `DoDeath` only, no explosion, no sound [O].
2. `_death1` shows immediately (the ship-tail actor swap at the file end, `case iVisual of stage_0→1 / stage_1→2`: `actor := LODActorName+'_death'+stage`, child0 `actor+'a.mesh'` visible, children `1..n-1` hidden) [O]. `DeathStage1` (after `_0ship`) additionally forces `visual stage_1` (`_unit_SetTagStates(stage_1)`) [O] → swap advances to `_death2`.
3. Fisher (`usage=fisher`) excluded from explosion [O] (gate includes `usage<>fisher`).

### 2.4 TTL family — `dmscript.global:183-194` (all [O], units stated as raw numbers)

| Key | Value [O] | Role [O] (which delay it feeds) |
|---|---|---|
| `gc_unit_deathtime_0` | `2` | land death-anim window → `DeathStage1` |
| `gc_unit_deathtime_1` | `20` | DS1 fade `1→0.4` window → `DeathStage2` (land, dispersed) |
| `gc_unit_deathtime_2` | `20` | DS2 sink window → `DeathStage3` (land inf/cav, dispersed; base for ships/art below) |
| `gc_unit_deathtime_2art` | `30` | DS2 sink window for artillery (no dispersion) |
| `gc_unit_deathtime_3` | `4` | DS3 fade `0.4→0` window → `DeathStage4` destroy (land, dispersed; also hide-branch direct destroy) |
| `gc_unit_deathtime_0ship` | `10` | ship `_death1` window → DS1 |
| `gc_unit_deathtime_1ship` | `10` | ship DS1 window → DS2 (no fade applied to ships) |
| `gc_unit_deathtime_2ship` | `35` | ship sink window → DS3 |
| `gc_unit_deathtime_3ship` | `30` | ship DS3 window → DS4 destroy |

Dispersion (land inf/cav only; ships and artillery skip it) [O]:
- DS1: `time := 2+time-random*(time/1)`, i.e. `time' ∈ (2, 2+time]` [D].
- DS2: `disp := random*(deftime/1.2); time := deftime-disp`, i.e. `time ∈ [deftime/6, deftime)` [D].
- DS3: `time := 2+time-random*time`, i.e. `time ∈ (2, 2+time]` [D].
- Death desync `0.7+random*0.6` multiplies anim speed only, not the stage delays [O].

**[U]-T (time base).** The unit of `DelayExecuteState` and of the `Time[i]` keys is not stated in any readable line. `gc_frames_to_time=0.03125` (`dmscript.global`, carried) is a candidate divisor and `StateMachineInterval` for units is `100` (`refunit.prop`) / `135` peasants / `60` artillery (`*.prop`), but no line binds the death delays to either clock. No seconds claim is made here; capture E-T (§5.1) measures it.

## 3. `_death1/2` mesh / skin windows (per class)

### 3.1 Infantry / cavalry (land, non-artillery) — NO mesh swap [O]

- Actor holds the single live mesh only (e.g. `peaukr.actor`: `peaukr.mesh ← peaukr.oss`; `hussar.actor` pattern identical) [O]. No `_death` actor/prop/aaf-swap line exists for these classes [O-negative, P9].
- Death skin = the AAF `death*` rows on the **same mesh** [O]: `peaukr.aaf` `death [115,149]`; `hussar.aaf` `death [49,119]`; `musketeer.aaf` `death [433,495] / death1 [498,559] / death0 [564,628]` (weapon-gated) [O]. All rows `morph`, no loop token (carried pattern).
- Peasant tools child (child0 `peaukr_tools`, 7 meshes, `peaaustools` material) is **not** hidden/cleared by the land death branch (no child line on that path) — the corpse keeps its tools [O-negative]. (Contrast building/ship branches which explicitly clear/hide.)

### 3.2 Artillery (land) — prop reload to `<base>_death`, single `"death"` clip [O]

- Death set (all present [O], P11): `cannon_death.actor/.oss` (103,564 B), `howitzer_death` (101,940 B), `mortar_death` (77,240 B), `multicannon_death` (193,672 B), `framegun_death` (85,140 B); AAFs `cannon/howitzer/mortar/multicannon/framegun_death.aaf` each 1 row `"death"` (cannon `[1,33]` cited) [O].
- Prop window [O] (`cannon_death.prop:4-19`, pattern identical for the other four): `CustomName/BaseName=<base>_death`, `LODActorName=<base>_death`, `DefaultMeshName=<base>_death.mesh`, `Mesh[0] → material <base>` (e.g. `cannon` — the gun keeps its paint, no `debris`), `FrameAnimationCyclesLibName=<base>_death` [O].
- Wheels (`*_wheel_left/right.oss`, `TXRollBehaviour` in `initial.inc`) are separate child actors; no death-branch line shows/hides them — static verdict: unknown whether they persist on the corpse ([U]-W, capture E-W §5.4).

### 3.3 Ships — numbered ruin meshes + attach child, parent material [O]

- Hull windows [O] (byte sizes P11): `frigate_death1.osm` 925,780 B / `_death2` 935,692 B; `battleship` 658,276/535,324; `galley` 397,284/295,420; `xebec` 431,692/363,372; `yacht` 422,852/356,092; `yachttur` 271,500/340,916; `chaika` 195,820/163,668; `ferry` 488,116/429,796; `fishboat` 120,324/106,884 [O]. Actor: 7 slots `frigate..4 + _death1/2` (`frigate.actor`) [O]; attach `.prop` `Mesh[5/6]=*_death1a/2a` (P9 grep) [O].
- Swap rule [O] (`ontagstates.inc` ship tail): `stage_0→_death1`, `stage_1→_death2`; child0 ← `actor+'a.mesh'` + visible; children `1..n-1` hidden [O]. Material: all attach slots keep the **parent ship material** (`frigate.prop` `Materials[0..6]=frigate`) [O]; the `debris` assignment exists only as a commented-out line (`:992`) [O]; `yacht` forces `SetGameObjectMaterialNameByHandle(child, parentactor)` hard-code [O].
- Ship AAF window [O]: `frigate.aaf` = 4 rows all `[1,280]` (`idle/walk/death/attack0`) — one shared take aliased; death plays `aamLoop`-family mode inherited from the actor header (`AnimationMode=aamLoop`) while the land branch forces `acmPlayOnce/aamPlayOnce` at entry [O]. Whether the hull anim actually advances during the sink is [U]-S (§5.5).

## 4. Debris / ghost / smoke / explosion materials (mostly negative — this is the finding)

1. **Debris mesh at unit death: NONE.** No land death path references `debris`; the only `debris` strings in the unit lane are the commented-out ship line and the building lane (`ontagstates.inc` building `:284-286`) [O, P9]. `debrisstone/debriswood` exist only as **projectile FX payloads** inside `gDestructListBuilding/gDestructListShip` (`weapon.script:614-622`), spawned by `_unit_DoExplosion` for buildings/ships [O]. A land corpse never spawns them [D].
2. **Ghost at death: NONE.** `TXLifeColorEffect` key `'blink'` (`unit.script:6674-6805`, `DEC_U_ghost_blink.md §2`) is driven only by `_misc_GUIProgressPickedBldUID` during placement [O, carried]. Zero callers on death paths [O, P9]. The death fade uses a **separate** effect key `'death'` (DS1/DS3 `DoSemiTransparent`) with `UseColor=False/UseAlphaChannel=True`, `Loop=False`, `bmTransparency`, `ZWrite+ZTest`, `fcCull` [O] — same flag block as the blink but different key, keys, and loop flag. Port must not reuse the ghost material for corpses.
3. **Smoke/fire at unit death: NONE.** `DoDeath` runs `MyGameObjectPFXClear` first [O]; DS1–DS3 attach no PFX (only `TXLifeColorEffect 'death'` + `TXMoveRotateWaveBehaviour`) [O]. `buildingsmoke/buildingfire` are building-damage states, never unit death [O, carried]. `grenadeexp/expflash` are building/ship-explosion FX (§2.3, §6 P6) [O].
4. **Ship explosion payload [O]** (`unit.script:11420ff` + `weapon.script:367,374`): `gDestructListBuilding` → `debrisstone, debrisstone, PUEXPBUILDINGDEATH(grenadeexp, radius `_misc_PixelsToTiles(10)`, `slightup`, PlayOnce)`; `gDestructListShip` → `debriswood, debriswood, PUEXPKORDEATH(grenadeexp, radius `PixelsToTiles(50)`)` [O]; ship scatter = 25 shots at `px+(0.5-RandomExt*tiles_to_pixels*180)`, `py+tiles_to_pixels*60/3` [O]; terminal `gEffectLibrary.GetOrCreate('expflash', hnd)` [O]. Building scatter uses the mask-cell + `RandomExt<0.33` gate with `explY = py+0.3+aabbmod+zmod` (`0.3` magic constant, same as C1, per source comment) [O].

## 5. Still-[U] items — fixed-camera death captures (zero-mismatch termination; no asset/TTL invented)

General capture rig (all E-captures): singleplayer skirmish, fixed camera (record pos/yaw/pitch/fov + `GetTimeSpeedFactor` on screen), one victim class per run, script-state log (`essential_death` entry, `DeathStage1..4` fires, `OnDeath`/`OnDestroy`) with frame counter + game-time. Background: flat terrain, known albedo, no other FX. Success = all bullets pass with cited capture ids; any mismatch keeps the item `[U]`.

- **E-T ([U]-T, TTL wall-clock + dispersion law).** Kill one `peaukr` (land), one `cannon` (art), one `frigate` (ship) on camera. Log `DeathStage1..4` fire times (game-time + frame). Termination: (a) stage gaps equal `gc_unit_deathtime_*` values × ONE common factor `k` within ±1 frame across all three classes (k recorded, never pre-assumed 1 s or 1/32 s); (b) 5 consecutive land corpses show DS1 gaps inside `(2,2+_1]` and DS2 gaps inside `[_2/6,_2)` with uniform-looking scatter (rejects point values); (c) artillery shows zero dispersion (gaps constant ±1 frame); (d) `0.7+random*0.6` changes only anim speed, never gap length (cross-check anim frame counter vs gap). Until then no `FRAMES_TO_TIME` conversion is applied to unit TTLs.
- **E-C ([U]-C, corpse fade/sink curve).** Same land kill, sample corpse framebuffer alpha + Y position per frame from death entry to destroy. Termination: (a) alpha reads `1→0.4` over DS1 window then `0.4→0` over DS3 window within ±0.05 against known background (linear assumed only if samples fit; otherwise record the engine curve, do not fit by invention); (b) Y drops exactly `10×0.05=0.5 m` (inf/cav) / `10×0.125=1.25 m` (art) during DS2, Bezier shape per `lsmBezierSpline`; (c) `DeltaTime 0.99` kick visible as a single-frame alpha step at DS2 entry; (d) destroy frame = DS4 fire frame (no lingering). Ship run separately: sink `10×0.625=6.25 m`, no fade (alpha constant 1) until destroy.
- **E-A ([U]-A, `death0/1/2` gating + AAF windows).** Kill one `musketeer` at each weapon tag (`none/0/1/2`) on camera with anim-name log. Termination: played clip ∈ {`death`,`death0`,`death1`,`death2`} per tag with the `musketeer.aaf` ranges (`death [433,495]` etc.), fallback to `death` when the tagged row is absent (peasant control: always `death [115,149]`); port `dead→death` single mapping stays labelled stand-in until then.
- **E-W ([U]-W, artillery wheels + tools children on corpse).** Kill one `cannon` + one `peaukr` (with tools) on camera, log child visibility per frame. Termination: child list + visibility constant from death entry to destroy (wheels/tools present-or-absent recorded, not assumed); any hide/clear line found is cited, else the corpse keeps all children.
- **E-S ([U]-S, ship `death1→death2` swap frame + anim advance).** Sink one `frigate` + one `yacht` on camera. Termination: (a) mesh id reads `<parent>_death1.mesh` from death entry until DS1 fire, then `<parent>_death2.mesh` (±1 frame); (b) child0 reads `<parent>_deathNa.mesh` visible with parent material (`frigate`/`yacht`, never `debris`); (c) `_death2` persists through DS2/DS3 to DS4 destroy; (d) `expflash` + ≤25 `grenadeexp` projectiles only on `none→death` built entry, never on later stages.
- **E-X ([U]-X, sound binding).** Same kills with audio log. Termination: land `deathinf/deathcav/deathart` sample plays once at death entry (variant index random, `cLoudMedium/cFreqLow`); ship `deathship` once; unbuilt-ship and hide-branch deaths silent; no `explcannon/explhowitzer/cannonexpl` on any unit death (those belong to firing, not dying).

## 6. Port change list — `world3d_entities.gd` / `world3d_fx.gd` (file/line; NOT applied)

Each row: port site [O] (read-only) → donor fact [O]/[D] → required replacement + donor assets. No row claims implementation. Building-death rows (`BLD_DEATH_*`) are already implemented and are cited only where the unit lane touches them.

| # | Port file:line (current [O]) | Donor fact (this job [O]/[D]) | Required donor-faithful replacement + required donor assets |
|---|---|---|---|
| U1 | `world3d_entities.gd:228` `MORPH_ACTION_MAP` `dead→death` single; `:2039-2050` death branch; `:2189-2201` `iEssential from ed.dead` | Weapon→anim law `none→death/0→death0/1→death1/2→death2` + exists-fallback (`ontagstates.inc` ~`:580-590`) [O]; AAF windows `peaukr death [115,149]`, `hussar [49,119]`, `musketeer death [433,495]/death1 [498,559]/death0 [564,628]`, `cannon_death [1,33]`, `frigate 4×[1,280]` (§3) [O] | Resolve death clip by live weapon tag with fallback; gate on per-sid AAF census. Assets: per-sid `.aaf` rows (already in repo census) + `<base>_death.aaf` ×5 artillery |
| U2 | same sites; no prop-reload line for units [O-negative] | Artillery `ReloadGameObjectProperties(hnd,'',basename+'_death')` (`ontagstates.inc` ~`:593-596`) [O]; `cannon_death.prop:4-19` material `<base>`, cycles `<base>_death` [O] | On artillery death, swap prop/material/cycles to `<base>_death` set; inf/cav keep live prop. Assets: `actors/units/{cannon,howitzer,mortar,multicannon,framegun}_death.oss` (77–193 KB) + 5 `_death.prop` + 5 `_death.aaf` |
| U3 | same sites; no roll/desync line [O-negative] | Inf-only roll `-55+random*110` + global desync `0.7+random*0.6` (`ontagstates.inc` DoDeath + ~`:599`) [O] | Apply roll to inf corpses only; multiply death-anim speed by `0.7+random*0.6`. No asset; script-only |
| U4 | no `TXLifeColorEffect 'death'` corpse fade in `world3d_entities.gd`/`world3d_fx.gd` [O-negative]; `world3d_fx.gd:131-150` LIFE table is port-only | DS1 fade `1→0.4` + DS3 `0.4→0`, key `'death'`, `UseAlpha+NoColor`, `Loop=False`, `bmTransparency`, ZWrite/ZTest, `fcCull`, children recursed (`deathstage1.inc:7-60`, `deathstage3.inc:6-59`) [O]; dispersion §2.4 [O] | Implement corpse fade as labelled `'death'` effect with the two key windows + dispersion; never reuse ghost `'blink'` keys (`GHOST_OK/BAD_ALPHA`, `world3d_fx.gd:199-204`) or LIFE stand-ins. No asset |
| U5 | no `TXMoveRotateWaveBehaviour` corpse sink [O-negative] | DS2 sink: 10 nodes, step `0.05` (land) / `0.125` (art) / `0.625` (ship), speed `0.011/disp` (`0.022` art, `0.022*2.5` ship, ×`speedFactor/10`), `lsmBezierSpline`, `DeltaTime→0.99` kick (`deathstage2.inc:15-64`) [O] | Implement sink with per-class step/speed + dispersion `disp=random*(_2/1.2)` (land inf/cav only). No asset |
| U6 | `_death_mesh_cache/_death_prev` + `:3144-3169` `_donor_death_suffix` + `:3302-3310` + `:3442-3477,3583` building-only swap [O] | Ship swap `<parent>_death1/2` + child `<parent>_deathNa` visible, `1..n-1` hidden, parent material (frigate), yacht hard-code (`ontagstates.inc` ship tail + `:992`) [O]; sizes §3.3 [O] | Reuse the stem/suffix machinery for ships: `frigate/chaika/ferry/fishboat/galley/battleship/xebec/yacht/yachttur` `_death1/2(.osm)` + `*_death1a/2a` attach with parent-ship material (never `debris`). Assets: 18 ship `_death.osm` + 18 attach (byte sizes §3.3) |
| U7 | `data.gd:1153,1160` `PUEXPBUILDINGDEATH/PUEXPKORDEATH` rows exist [O]; no unit-death explosion guard in entities [O-negative] | `_unit_DoExplosion` gate buildings/ships only + destruct lists + 25-shot ship scatter + `explY=py+0.3+aabbmod+zmod` + `expflash` tail (§4.4) [O] | Gate ALL death-explosion spawns on `bbuilding or bship` (fisher excluded); land corpses spawn nothing. Assets: `grenadeexp/expflash` sheets already in the building lane (`world3d_fx.gd:402-429`); no new unit asset |
| U8 | `world3d_fx.gd:131 LIFE` + `:402-429 DONOR_DEATH_FX_TTL` (building keys) [O] | Unit TTLs `gc_unit_deathtime_0..3(_ship/_art)` + dispersion (§2.4) [O]; time base [U]-T | Add labelled `DONOR_UNIT_DEATH_TTL = {0:2, 1:20, 2:20, 2art:30, 3:4, 0ship:10, 1ship:10, 2ship:35, 3ship:30}` as DATA ONLY; wire to stage scheduler only after E-T fixes the clock. Never copy `DONOR_DEATH_FX_TTL` or `LIFE` values across |
| U9 | `world3d_entities.gd:365` `DONOR_STATE_MAP_COMPLETION_LABEL` cites `unit.script:11075,11085` delays [O] | Same delays are `gc_unit_deathtime_0(_ship)` feeding `DeathStage1` (§2.1) [O] | Keep the label; append `_1/_2(_art)/_3(_ship)` + dispersion formulas once U8 lands. No asset |
| U10 | sound path plays `deathbuilding1` (`main.gd:1795-1797`, carried via `BLD_DEATH_SOUND_*`) [O] | Unit sounds `deathinf/deathcav/deathart/deathship` (`sound.script:127-136`, samples `D:sounds/units/death{inf1-6,cav1-6,art1-2,ship}.ogg`) [O]; land-art gets `deathart`, ships `deathship` on `none`-entry only [O] | Play the per-unittype sample at death entry (not at stage fires); hide/unbuilt-ship deaths silent. Assets: the 15 `death*.ogg` unit samples (already on disk, uncopied) |
| U11 | `:2720` dead/hidden cull; `:3733-3754` DeathStage2 building ownership note [O] | Unit destroy = DS4 `BehaviourClear + RequestToDestroy` after `_3(_ship)` (hide-branch: direct) [O]; `OnDestroy` re-fires `OnDeath` if `not bdead` [O] | Drive corpse removal from the DS1→DS4 chain (E-T clock), not from sim `dead=true` alone; keep building `DeathStage2` ownership untouched. No asset |

Required donor asset manifest (unit lane; not copied here): `actors/units/{cannon,howitzer,mortar,multicannon,framegun}_death.oss` + 5 `_death.actor` + 5 `_death.prop` + 5 `_death.aaf`; ship `actors/units/{battleship,chaika,ferry,fishboat,frigate,galley,xebec,yacht,yachttur}_death{1,2}.osm` + attach `*_death{1,2}a` meshes + parent ship materials; AAF death rows per sid (`peaukr/hussar/musketeer/...`); sound samples `D:sounds/units/death{inf1-6,cav1-6,art1-2,ship}.ogg`; script sources `D:scripts/units/unit.inc/{ontagstates,settagstates,ondeath,ondestroy,deathstage1-4}.inc` + `D:scripts/lib/{unit.script:11420ff,weapon.script:270-276/367-390/614-622,sound.script:127-136}` + `D:scripts/dmscript.global:183-194,1003-1006,1303-1309,1334` + `D:pfx/{source.pfx:1003-1169 grenadeexp/grenadesmoke,fx.tree:216-221,398}`.

## 7. Claim register

| # | Claim | Label |
|---|---|---|
| 1 | Land death = same-mesh AAF `death*` + inf-only ±55° roll + `acm/aamPlayOnce` + PFX clear + `0.7+random*0.6` desync; no mesh/debris/ghost/smoke/explosion | [O] `ontagstates.inc` death branch + DoDeath; P9 negative grep |
| 2 | Artillery death reloads `<base>_death` prop (base-albedo material, `<base>_death` cycles, single `"death"` clip) | [O] `cannon_death.actor/.prop/.aaf`, `ontagstates.inc` reload line |
| 3 | Ship death = `_death1→_death2` + `...a` child visible + `1..n-1` hidden + parent material (yacht hard-code; `debris` commented out) + explosion/sound on `none`-entry only | [O] ship tail + `:992` + `frigate.actor/.prop/.aaf` + sizes |
| 4 | TTLs `2/20/20/30art/4 + 10/10/35/30ship` with land-only dispersion `(2,2+t]`, `[t/6,t)`, `(2,2+t]` | [O] `dmscript.global:183-194` + DS1-3 sources; [D] interval arithmetic |
| 5 | Corpse visuals = fade `1→0.4` (DS1) + sink 10-node Bezier 0.5/1.25/6.25 m (DS2) + fade `0.4→0` (DS3) + destroy (DS4); ships skip fades | [O] `deathstage1-4.inc` full reads |
| 6 | `_unit_DoExplosion` + `grenadeexp/expflash` + destruct lists are building/ship-only; land units excluded by gate | [O] `unit.script:11420ff` + `weapon.script` + `fx.tree` |
| 7 | Death sounds `deathinf/cav/art/ship` (+ `deathbuilding` for buildings, carried); samples on disk | [O] `sound.script` + `D:sounds/units/` |
| 8 | Ghost/rally/death-smoke are not unit-death visuals (placement-only / N/A / pre-death-only) | [O-negative] P9 grep + carried ghost/placement + smoke reports |
| 9 | Delay/FX `Time[i]` wall-clock unit unproven; no seconds or `×0.03125` conversion endorsed | [U]-T, capture E-T |
| 10 | Port differs at §6 U1-U11; each has a donor-faithful replacement algorithm; `game.gd/data.gd/picking3d.gd` untouched by this worker | [O] port lines + donor facts |
| 11 | Every [U] has a fixed-camera capture (E-T/C/A/W/S/X) with zero-mismatch termination; none closed by fallback | [D] this report |
| 12 | Any port visual equals donor death motion/colour/FX | **Denied** — no same-camera donor/port A/B exists; parity UNVERIFIED |

## 8. Scope statement

Exactly one repository file was written by this worker: this report. All donor reads were read-only against pin `t_87f0f3c130b0` (data-tree text/directory/byte inspection; no donor binary executed; no donor bytes copied). No source, shader, config, asset, fixture, test, runner, Godot, git or user-mod state was changed. No donor parity, similarity score, threshold or gate PASS is claimed. Network is out of scope.

*End of DEC-U-UNIT-DEATH-ART.*
