---
id: DBUILD-02
owner: DBUILD-02 (independent donor verification worker)
role: "Second-pass, read-only verification of DBUILD-01 building-stage claims; donor truth only"
date: 2026-11-25
status: COMPLETE — documentation only; no code edits, no runner jobs, no donor copies, no donor execution
donor: "C:\\Games\\Cossacks 3 (READ-ONLY; Python 3.14 bytes/latin-1 numbered dumps; no donor binary run or copied)"
method: "Fresh donor reads, two independent methods per load-bearing claim: (A) direct bytes/latin-1 numbered line dump; (B) a second consumer, a filesystem enumeration, an independent arithmetic path, or a second in-file branch. No reliance on DBUILD-01's own transcription."
labels: "observed / derived / inferred / UNVERIFIED"
output: "this report only (exclusive output path)"
---

# DBUILD-02 — Independent second-pass verification of donor building-stage claims

## 1. Sources

### 1.1 Prior reports read (full)

| # | Report | Role |
|---|---|---|
| S1 | `docs/coord_swarm_2026-11-25/reports/DBUILD_01_building_stages.md` | Subject of verification (all 287 lines read) |
| S2 | `docs/coord_swarm_2026-11-25/reports/DFX_01_pfx_effects.md` | Construction-dust-absent / damage-smoke claim chain (§7.4, §8, §11-12 read) |

### 1.2 Fresh donor files read (no path shorthand in this report)

All paths absolute under `C:\Games\Cossacks 3\data\` unless stated. Each file was opened `rb`, decoded `latin-1`, split into numbered lines; byte count and NUL count recorded (all script/config files: 0 NUL).

| # | File | Lines examined | Bytes / lines |
|---|---|---|---|
| D1 | `scripts\lib\unit.script` | 6570-6610 | 560,101 / 12,381 |
| D2 | `scripts\units\building.inc\doprogressorders.inc` | 1-20, 75-105 | 26,651 / 416 |
| D3 | `scripts\units\building.inc\ontagstates.inc` | 85-340 | 27,317 / 472 |
| D4 | `scripts\units\building.inc\settagstates.inc` | 1-61 (full) | 2,897 / 61 |
| D5 | `scripts\units\building.inc\deathstage1.inc` | 1-16 (full) | 569 / 16 |
| D6 | `scripts\units\building.inc\deathstage2.inc` | 1-25 (full) | 1,108 / 25 |
| D7 | `objects\buildings\engcen.prop` | 1-122 (full) | 4,360 / 122 |
| D8 | `actors\buildings\eng\engcen.actor` | 1-28 (full) | 1,709 / 28 |
| D9 | `actors\buildings\eng\*.osm` + `actors\buildings\eng\attach\*.osm` | filesystem enumeration + sizes | — |
| D10 | `actors\buildings\<25 nations>\*.osm` | filesystem enumeration, 25 dirs | — |
| D11 | `scripts\dmscript.global` | 1-45, 160-186, 1260-1276, targeted finds | 91,341 / 2,400 |
| D12 | `scripts\lib\weapon.script` | 375-445, 600-625 | 68,889 / 1,266 |
| D13 | `objects\misc\pfx\debris_stone.prop`, `debris_wood.prop` | existence + sizes | 3,380 / 3,061 |
| D14 | `objects\misc\rallypoint.prop` | 1-30 (full) | 1,078 / 30 |
| D15 | `actors\misc\rallypoint.actor`, `actors\misc\rallypoint.osm` | 1-5 + existence | 234 / 1,956 |
| D16 | `scripts\units\unit.inc\onaclanimationreachedconstruct.inc` | 1-54 (full) | 3,032 / 54 |
| D17 | `scripts\lib\sound.script` | 180-220 | 28,196 / 586 |
| D18 | `scripts\units\building.inc\nothing.inc` | 1-90, 290-390 | 29,774 / 497 |
| D19 | `pfx\fx.tree` | targeted key find | — |
| D20 | `game\var\objcustom.cfg` | targeted finds (`sid = engcen`, `SmokePoints`) | — |
| D21 | `sounds\interface\interface.snd` | targeted finds (`bldcen`, `bldhou`, `bldbar`) | — |

Temporary analysis scripts lived only in `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\` (`dbuild2_dump.py`, `dbuild2_find.py`, `dbuild2_inventory.py`). No file outside the exclusive output path was written in the repository.

### 1.3 Verification policy

Every load-bearing claim has **two independent reads**: (A) direct numbered bytes/`latin-1` dump, and (B) a different consumer of the same value, a filesystem enumeration with byte sizes, a second in-file branch, or independent arithmetic from separately read constants. Where method B is only textual corroboration of dead code, or where only one method exists, the label is downgraded and stated explicitly.

---

## 2. Verification table

Legend: **observed** = literal bytes/text/filesystem read; **derived** = arithmetic or control flow following directly from observations; **inferred** = strong but indirect synthesis; **UNVERIFIED** = no readable evidence or no runtime capture. *A* and *B* mark the two independent methods.

### 2.1 The six required claims

| Claim | DBUILD-01 position | Independent evidence (A + B) | Verdict |
|---|---|---|---|
| **`floor(progress*4)` selects one of 4 construction stages** | §2.2: progress `hp/maxhp`, monotonic; `stage=floor(buildprogress*4)` at `unit.script:6596-6603`; "identical formula for ship dummy" at `doprogressorders.inc:84-93`; boundaries `[0,.25)→mesh1 … [.75,1)→mesh4` (derived) | **A** D1 `:6582-6605`: `newprogress:=hp/maxhp` (`:6583-6584`), accepted only if `newprogress>buildprogress` (`:6589-6590`), completion at `hp>=maxhp` (`:6591-6592`), clamp `if buildprogress>1 then :=1` (`:6594-6595`), `var stage: Integer=floor(buildprogress*4)` (`:6596`), `case stage of 0..3 → gc_statetag_visual_stage_0..3` (`:6598-6603`), `SetTagStates(essential_birth or visualtag)` (`:6604-6605`). **B** D3 `:240-251` is the independent consumer: `stage_0→1, stage_1→2, stage_2→3, stage_3→4`, `actor:=LODActorName+IntToStr(stage)`, `SetGameObjectActorNameByHandle(actor+'.mesh')`; wall override `stage:=1+stage div 3` (`:247-248`). D8 `:2-27` lists the 7 mesh names and D9 confirms the 4 stage `.osm` files with byte sizes. Derived boundaries follow exactly from `floor`. | **CONFIRMED**. Formula + consumer: **observed** (twice); boundaries: **derived**. See correction C1 for the ship-dummy caveat and C2 for the `stage=4` edge. |
| **Stage-synchronised scaffold attach** | §2.3: `engcen.prop:72-112` auto-child `engcena`, meshes `[0..6]` parallel to parent, materials `scaffold` (0-4) / `debris` (5-6), `achildRequered`, scale `0.646` (`:115-117`), roll `135` (`:121`); runtime consumers `ontagstates.inc:253-259,281-287` | **A** D7 `:72-112`: `autochildrenproperty` `Enabled=True`, `ClassName=AutoChildrenProperty`, `BaseName=engcena` (`:86`), `RaceName=buildings` (`:87`), `DefaultMeshName=engcena.mesh` (`:88`), `Mesh[0]=engcena … Mesh[4]=engcen4a … Mesh[5]=engcen_death1a, Mesh[6]=engcen_death2a` (`:90-96`), `Materials[0..4]=scaffold`, `[5,6]=debris` (`:99-105`), `Option=achildRequered` (`:106`). Scale `0.646` at `:115-117`, roll `135` at `:121`. **B** D9 attach enumeration: all 7 `.osm` exist with distinct sizes (`engcena.osm` 660 B; `1a` 138,228; `2a` 198,940; `3a` 248,268; `4a` 298,996; `death1a` 46,484; `death2a` 85,276). Third check: D3 `:253-259` birth switches child to `actor+'a.mesh'` + `'scaffold'` + visible; `:281-287` death switches to `_deathNa.mesh` + `'debris'`; `:112-127` completion switches to `actor+'a.mesh'` + `'detail'` + visible. | **CONFIRMED** — **observed** (definition, files, and runtime consumer), three independent methods. |
| **2 death stages at 30 / 30 frames, mine ×2** | §3.1: `settagstates.inc:32-53`, `deathstage1.inc:4-13`, `deathstage2.inc:6-22`; `dmscript.global:183-184 = 30`, `:174 = 0.03125` ⇒ ~0.9375 s/stage; mine doubling | **A** D4 `:32-53`: non-wall death switch; birth shortcut sets visual `stage_1` and schedules `DeathStage2` at `gc_building_deathtime_1` (`:36-39`); otherwise visual `stage_0` and schedules `DeathStage1` at `gc_building_deathtime_0` (`:46-50`) with `deathtime:=deathtime*2` for `gc_obj_usage_mine` (`:47-48`). D5 `:5-11`: `essential_death or visual_stage_1`, schedule `DeathStage2` at deathtime_1, mine ×2 (`:8-9`). D6 `:8-15`: terrain collision clear + `GameObjectRequestToDestroyByHandle`. **B** D11 `:183=30`, `:184=30`, `:174 gc_frames_to_time=0.03125`, `:175 gc_time_to_frames=32` — independent arithmetic: 30×0.03125 = 0.9375 s/stage, 1.875 s for two stages. D3 `:269-275` maps death visual `stage_0/1 → _death1/_death2`, skipped for walls (`:267`); D8 `:20-27` + D9 byte sizes prove both death meshes exist. | **CONFIRMED** — sequencing and constants **observed** (twice); seconds **derived** (engine-time frames, no wall-clock capture). See correction C3 for the mine×2 asymmetry. |
| **Debris projectiles on building explosion** | §3.2: `weapon.script:605,609-611` spawn 5-9 `debriswood` on `gc_obj_explmedia_building`; `gDestructListBuilding` adds `debrisstone` (`:615-616`); weapons `:381-382`, trails `:438-439`; "no rubble pile" synthesis **inferred** | **A** D12 `:605` `PUEXP/building → 5,9,'debriswood'`; `:609` `PUEXPBLD/building → 5,9`; `:610` `PUNOEXPBLD/building → 5,9`; `:606` also wood. `:614-617` `gDestructListBuilding` = `debrisstone`, `debrisstone`, `PUEXPBUILDINGDEATH`. `:381-382` `debrisstone`/`debriswood` weapons: gravity `gc_weapon_gravity_3`, `gc_weapon_propagation_random1`, count `9`, `cInfinite`. `:438-439` `cFXTrailDebrisWood/Stone`. **B** D13: `objects\misc\pfx\debris_stone.prop` (3,380 B) and `debris_wood.prop` (3,061 B) exist independently of the weapon script; D7 `:104-105` + D3 `:286` show the scaffold death mesh material is literally `debris`. | **CONFIRMED** — **observed** (twice). The "rubble = death meshes + flying projectiles, no separate pile object" synthesis remains **inferred**, as DBUILD-01 itself states. |
| **Rally object scale 0.0525 / roll 45** | §4.2 (and correction 6): `objects\misc\rallypoint.prop:19-21,25` — "CONFIRMED" | **A** D14 (full 30-line dump, 1,078 B, 0 NUL): `CustomName`/`BaseName = rallypoint` (`:4-5`), `LODActorName = rallypoint` (`:9`), `DefaultMeshName = rallypoint.mesh` (`:10`), `DefaultScale.X/Y/Z = 0.0525` (`:19-21`), `DefaultRollAngle = 45` (`:25`), `OffsetCollideOption = ocoTerrainWater` (`:29`). **B** D15: `actors\misc\rallypoint.actor:2-3` binds `rallypoint.mesh → rallypoint.osm`, and `rallypoint.osm` exists (1,956 B). | **CONFIRMED** — **observed**, two independent files. Exactly matches DBUILD-01; no correction needed. |
| **Visible building smoke onset ≈ 88.75 % HP** | §5.3: `nothing.inc:31-83` (client/replay) + `:336-386` (server/offline), `cSmokeHPLimit=0.85`, `S = bslowdeath ? Max(1999, maxhp div 4) : maxhp div 4`, onset `hp < 0.85·maxhp + 0.15·S = 0.8875·maxhp`; §5.2: smoke only on `bbuilt` buildings; DFX-01 §7.4 "no construction dust" | **A** D18 `:17-22`: block requires `not bdead` **and** `bbuilt`; `:31` `const cSmokeHPLimit = 0.85`; `:32` `maxhp`; `:34-37` `S := Max(gc_BuildingSlowDeathHP, maxhp div 4)` if `bslowdeath`, else `maxhp div 4`; `:38` gate `(smokecount>0) or ((hp-S)<((maxhp-S)*0.85))`; `:43` `maxind := floor((1-((hp-S)/0.85)/(maxhp-S))*smokeCount)`; `:58-61` tick-gated emitter with `freq=Min((1-0.5·diff/smokeCount)·0.8,0.8)`; `:67-78` spawn `point` at `smokePoints[i]` + `gEffectLibrary.GetOrCreate('buildingsmoke', effHnd)`. **B** D18 has a second, near-identical branch at `:293-390`: the unbuilt branch `:298-307` does only capture checks + `_unit_ControlBuildProgress`, while `:336-386` repeats the identical formula and `GetOrCreate` at `:383`. Independent constants D11 `:129=1999`, `:130=300`, `:164=80`; D19 `fx.tree:418-442` `buildingsmoke` effect exists while grep for `construct` yields **0** hits (only `impactdust` at `:274-278` is dust-keyed); D20 `sid = engcen` at `:16782` with `SmokePoints` block at `:16805` and `enghou` at `:17470`. Arithmetic check: `S=M/4` ⇒ onset `M(0.85+0.15/4)=0.8875·M`. | **CONFIRMED** — formula and `bbuilt` gate **observed** (twice); 88.75 % **derived**; on-screen density **UNVERIFIED** (no runtime capture). `maxhp div 4` is integer division, so the exact integer HP cut-off may be up to ~0.0375·maxhp below the ideal ratio; "≈88.75 %" is the correct label (see C4). |

### 2.2 Supporting claims sampled from DBUILD-01

| Claim | DBUILD-01 position | Independent evidence (A + B) | Verdict |
|---|---|---|---|
| 7 mesh slots for one building; stage sizes grow 1→4 | §2.1 (exact byte sizes quoted) | **A** D8 `engcen.actor:1-28` lists `engcen.mesh`, `engcen1..4.mesh`, `engcen_death1.mesh`, `engcen_death2.mesh` with matching `.osm` paths. **B** D9 sizes match DBUILD-01 **exactly**: base 1,386,780; 1: 535,716; 2: 966,340; 3: 1,256,820; 4: 2,017,308; death1: 1,694,324; death2: 894,156. | **CONFIRMED — observed** (twice). Visual content of `.osm` remains **UNVERIFIED** (binary; no render). |
| State-tag bit constants | §2.2: `dmscript.global:6-7,26-29,41` | **A** D11 `:5-7` essential none/birth/death = `1 shl 0/1/2`; `:25-30` visual none `1 shl 20`, stages `1 shl 21..24`, hide `1 shl 25`; `:41` visual mask. **B** D3 `:240-263` birth consumer and `:264-275` death consumer masks match; D1 `:6597-6603` initialises `visualtag` from these constants. | **CONFIRMED — observed** (twice). DBUILD-01's table omits `gc_statetag_visual_none = 1 shl 20` (`:25`); immaterial. |
| Wall special case: 2 construction meshes, no death mesh | §2.2 `:247-248`; §2.4 commonrus `2/0`; §3.1 wall death | **A** D3 `:247-248` `if bwall then stage := 1+stage div 3` ⇒ from `stage∈{1,2,3,4}` only `1` or `2`; D3 `:267` skips death-mesh swap for walls; `:313-335` wall death clears FX, hides, `DelayDestroy` at `gc_unit_deathtime_3`. **B** D10 enumeration: 44 wall-like `commonrus` bases have `1.osm`+`2.osm` and no `3.osm`/death (e.g. `eurswa_v`, `russwa_gate`, `turswa_tower`); `eurswa_45gate`, etc. D11 `:190 gc_unit_deathtime_3=4`. | **CONFIRMED — observed** (twice). |
| Per-nation 4/2 pattern | §2.4 table: 10 actors per nation, all 4/2; commonrus 2/0 walls + 4/2 shared | **A** D10 enumeration across **25** nation dirs: e.g. `eng/fra/rus/pru/...` each 10 bases with all four stage `.osm` + both death `.osm`; `commoneur` 12/12, `commontur` 5/5, `tur` 9/9, `ukr` 10/10, `por` 11, `spa` 12, `alg` 2, `commonrus` 5×4/2 + 44×2/0. **B** D8 actor list + D9 file sizes for the sampled `engcen` chain. | **CONFIRMED for the canonical buildable actors** — **observed** (enumeration). See correction C5: extra `<nat>ba` and `<nat>xxxb` meshes in several dirs do **not** follow 4/2. |
| Per-hit construction sound `workconstruct`, no FX call | §2.5 / §5.2 item 2: `onaclanimationreachedconstruct.inc:23-43`, constant `dmscript.global:1329`, library `sound.script:190` | **A** D16 full dump: `:23 if not bbuilt`, `:25-37` `delta := gc_buildtime_progressperhit/buildtime`, `buildprogress += delta`, `deltahp := round(maxhp*delta)`, clamp to maxhp, `:42-43` `_unit_RequestPlaySound(myHnd, gc_snd_ind_workconstruct)`. No `GetOrCreate`/effect call anywhere in the 54-line file. **B** D11 `:1329 gc_snd_ind_workconstruct=78`, `:179-182` `progressperhit = 10 × 0.03125 × 1.15 = 0.359375`; D17 `scripts\lib\sound.script:190` binds index to `workconstruct1..12`; D19 `fx.tree` has zero `construct` hits. | **CONFIRMED — observed** (twice). Path correction C6: DBUILD-01 §1.2 writes `scripts\sound.script`; the real path is `scripts\lib\sound.script`. |
| Completion jingle `bld<sid>`, human-only, non-wall | §2.5: `ontagstates.inc:146-153`; `interface.snd:80-121`; `dmscript.global:1263-1274` | **A** D3 `:146-152`: gate `gSoundManager.bprocess and not bwall and (interface player index = arg_obj.pl)`, `sndname := 'bld'+SubStr(sid,Length-2,3)`, `+'tur'` for `turcen/algcen/turtem/algtem`, `_misc_PlaySound(gc_snd_lib_interface, sndname)`. **B** D11 `:1237 gc_snd_lib_interface='interface'`, `:1263-1274` indices 13-24 for `bldcen/bldhou/.../bldcentur/bldtemtur`; D21 `interface.snd:80-81 bldcen`, `:84-85 bldhou`, `:92-93 bldbar`, `:120-121 bldcentur`. | **CONFIRMED — observed** (twice). |
| `buildingsmoke` is a fire/smoke composition, not construction dust | DFX-01 §7.4; DBUILD-01 §5.1-5.2 | **A** D19 `fx.tree:418 effectname=buildingsmoke` with four layers (`:422 buildingfirestart`, `:427 buildingsmokestart`, `:432 buildingfire`, `:437 buildingsmoke`). **B** D18 `:78`/`:383` are the only readable `GetOrCreate('buildingsmoke', …)` consumers; D19 key search `construct` = 0 hits, `dust` only `impactdust` (`:274-278`). | **CONFIRMED — observed** (twice). Engine-internal `buildfire*_birth` / `buildsmoke*_birth` selectors remain **UNVERIFIED** (no consumer found; DBUILD-01 §8 Q3 agrees). |

---

## 3. Corrections / refinements to DBUILD-01

1. **C1 — Ship-dummy "second read" is commented-out code.** `doprogressorders.inc:82-94` (`ProgressShipDummy`) carries the same `floor(progress*4)` text at `:84`, but every code line in the file is prefixed with the OSW comment marker `[*] = ;` (confirmed D2 `:1-20` and `:75-105`; the whole 416-line file is inert). DBUILD-01 §2.2 labels this "observed (twice)". **Refinement:** it is valid textual corroboration of the formula's *form*, but it is **not** a second live consumer. The real independent live consumer is `ontagstates.inc:240-251` (D3). Verdict on the formula is unchanged (CONFIRMED), but the "two live reads" wording should be corrected.
2. **C2 — `stage=4` edge case is reachable, and DBUILD-01's phrasing is slightly imprecise.** The clamp at `unit.script:6594-6595` applies to `buildprogress` carried from `onaclanimationreachedconstruct.inc:33` (`buildprogress += delta`), where `delta` is fractional while HP advances by `round(maxhp*delta)` (D16 `:34-37`). The two can diverge, so `buildprogress` may reach 1 while `hp < maxhp`; then `floor(4)=4` matches no `case` branch (`:6598-6603`) and `visualtag` stays `gc_statetag_visual_none` (`:6597`). DBUILD-01's "previous stage mesh remains until completion" is a reasonable reading, but the actual effect on `SetTagStates` (`_unit_SetTagStates(hnd, essential_birth or visual_none)`, `:6604-6605`) is **derived and not runtime-verified**; flag as **UNVERIFIED** for the on-screen result, not for the arithmetic.
3. **C3 — Mine doubling is not applied on the birth→stage_1 death shortcut.** `settagstates.inc:36-39` schedules `DeathStage2` at `gc_building_deathtime_1` **without** the `gc_obj_usage_mine` ×2 check present at `:47-48` and `deathstage1.inc:8-9`. DBUILD-01 §3.1/§9 says "×2 mines" generically. **Refinement:** ×2 applies to the completed-building `DeathStage1` path and to `DeathStage1` itself; an under-construction (birth-state) mine dies on a single 30-frame delay.
4. **C4 — 88.75 % is exact only for real-valued `maxhp/4`.** `nothing.inc:37` uses integer `maxhp div 4`; the HP gate at `:38` is evaluated on integer `hp`. For a building of `maxhp=M`, onset is `hp < 0.85M + 0.15·floor(M/4)`, which can sit up to `0.0375M` below `0.8875M` depending on `M mod 4`. "≈88.75 % HP" remains the correct label; do not hard-code a `0.8875` multiplier into a port and expect donor-exact integer thresholds.
5. **C5 — Per-nation file inventory has extra non-conforming meshes.** DBUILD-01 §2.4 tables "10 each, 4/2 all" for most nations. The enumeration (D10) confirms this for the **canonical buildable actors**, but several dirs also contain e.g. `<nat>ba` with **one** stage `.osm` (`engba`, `rusba`, `ausba`, …) and `<nat>xxxb` variants with **zero** stage/death `.osm` (bav/den/hun/net/pie/sax/sco/swi/por each show 11 such names). `mis` yields 19 base names by this method (DBUILD-01 §2.4 says 22 misc objects — likely counted from `.prop` records). None of this affects the construction-stage claim for buildable buildings; it only narrows the scope of the word "all".
6. **C6 — Source path typo.** DBUILD-01 §1.2 cites `scripts\sound.script (:129,:190,:215)`; the file is `scripts\lib\sound.script` (D17). Its `:190` content is correct as quoted.
7. **C7 — `gc_snd_ind_workconstruct` library uses 12 variants**, not a single sample: `sound.script:189-190` loops `i:=1 to 12` over `workconstruct<i>` (D17). DBUILD-01's "per-hit sound `workconstruct`" is correct; this is a detail, not a contradiction.

No claim among the six required ones was **refuted**. All refinements above preserve the original verdicts.

---

## 4. Open questions (UNVERIFIED after this pass)

1. **Stage mesh visual content** — `.osm` are binary; monotonic size growth + mesh-name mapping is **derived**, not a rendered observation. No donor GPU capture was made.
2. **Ghost appearance / blink shader** — out of this pass's fresh-read scope; DBUILD-01 §4.1's "engine dummy + canbuild/cannotbuild blink; colour/size UNVERIFIED" stands untouched. Entry-gate scripts (`onshortcut.inc`, `eventunitcontrol.inc`, `miscext2.script`) were **not** re-read here and are carried from DBUILD-01, not independently re-verified by DBUILD-02.
3. **`stage=4` on-screen outcome** (C2) — derived control flow only; no runtime capture.
4. **Smoke on-screen density / unit conversion** — `PixelRatio`, `Interval`, `AlphaTime` have no recovered seconds/metres conversion (DFX-01 §12 Q1). The 88.75 % HP onset is exact in ratio terms but its visual intensity is **UNVERIFIED**.
5. **Construction birth FX** — `buildfire*_birth` / `buildsmoke*_birth` / `constructor\debris.dds` have no readable selector; engine-internal use **UNVERIFIED**.
6. **Slow-death clamp** — DBUILD-01 §5.3 cites `lib\miscext.script:1149-1152,1410-1413` for the `1999 - floor(random*300)` floor; those lines were **not** freshly re-read in this pass. The constant side (`dmscript.global:129-130`) **was** re-verified.
7. **Mine death timing for birth-state buildings** (C3) — derived from the missing ×2 in `settagstates.inc:39`; no runtime test.
8. **Port parity rows** in DBUILD-01 §6 were not re-audited here; this ticket is donor-truth-only. No port file was edited or re-verified.

---

## 5. Summary

| Required claim | DBUILD-01 | DBUILD-02 verdict | Evidence strength |
|---|---|---|---|
| `floor(progress*4)` → 4 construction stages | confirmed | **CONFIRMED** | observed ×2 + derived boundaries; ship-dummy second read is dead code (C1) |
| Scaffold stage-synchronised attach | confirmed | **CONFIRMED** | observed ×3 (prop + filesystem + runtime consumer) |
| 2 death stages, 30 + 30 frames, mine ×2 | confirmed | **CONFIRMED** | observed ×2 + derived 0.9375 s/stage; mine ×2 asymmetry (C3) |
| Debris projectiles | confirmed | **CONFIRMED** | observed ×2; "no rubble pile" remains inferred |
| Rally scale 0.0525 / roll 45 | confirmed | **CONFIRMED** | observed ×2 |
| Smoke onset ≈ 88.75 % HP | confirmed | **CONFIRMED** | formula observed ×2; percentage derived; integer-division caveat (C4) |

**Bottom line:** DBUILD-01 survives independent second-pass verification on every load-bearing building-stage claim. Seven minor refinements (C1-C7) tighten wording, scope and one source path; none changes a verdict. Six claims were each checked twice by independent methods. No code edits, runner jobs, donor copies or donor execution occurred; the only repository file written is this report.

*End of DBUILD-02 report. Read-only donor recon. Every donor fact cites a `path:line` or a filesystem enumeration; uncertainties are labelled.*
