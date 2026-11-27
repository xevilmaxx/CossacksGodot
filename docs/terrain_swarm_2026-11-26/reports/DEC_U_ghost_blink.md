# DEC-U-GHOST-BLINK — donor ghost colour source + blink function/period (static read-only)

- donor_pin: `t_87f0f3c130b0` = `C:\Games\Cossacks 3\cossacks.exe` (PE x86); data tree `C:\Games\Cossacks 3\data` read READ-ONLY, donor binary never executed. Multiple passes below; every literal carries a file + line address.
- context: `docs/terrain_swarm_2026-11-26/reports/DEC_U_aaf_art_audit.md` (esp. §2.3, [U]-G) and `IMPL-FX-ART` derived `variant3d/assets/fx/models/box.obj` + `variant3d/assets/fx/tex/box.png`; port `variant3d/scripts/world3d_fx.gd` `GHOST_OK/GHOST_BAD` + `sin` pulse currently labelled UNVERIFIED.
- worker: DEC-U-GHOST-BLINK. Exactly one repository file is written by this worker: this report. No code/Godot/git edits. No parity claim.

## 0. Headline verdict

- **[O] blink law recovered.** Donor ghost blink is `_unit_DoConstructionBlinkGameObject` (`data/scripts/lib/unit.script:6674-6805`): a `TXLifeColorEffect` keyed `'blink'` with 3 alpha keys `(maxalpha, minalpha, maxalpha)`, per-key `Time = totalTime = 0.525*1.25*(GetTimeSpeedFactor/10)`, `Loop=True`, blend override `bmTransparency`. All placement call sites pass `bUseColor=False`, so the effect runs in **alpha-only mode** (`UseAlphaChannel=True`, `UseColor=False`); the `cr/cg/cb` colour arms are **dead code on every observed path** (see §3). OK/BAD differ ONLY by: alpha floor (`0.35` vs `0.45`, ceiling `0.5` both), `UseEmission` (`False` vs `True`), plus a red emission pulse `(0.8,0,0)/(0.6,0,0)/(0.8,0,0)` written unconditionally in the create path.
- **[O] scale/offset/parent for the `box` dummy.** `DefaultScale 0.5³` is inherited from `data/objects/ref/refmisc.prop:210-213` (not overridden in `constructiondummy.prop`); offset `X/Y/Z=0`, `AutoOffset=True`, `OffsetCollideOption=ocoTerrain` (`refmisc.prop:259-265`); selection ring white `RGBA 1,1,1,1`, size `0.5` (`refmisc.prop:282-291`). `box` material = `box.dds` + `minfilter` only, no colour/alpha/blend keys (`data/materials/misc/misc.mat` §1); blending falls back to `refbase.mat` default `bmAlphaTest50`.
- **[O] `constructiondummy`/`box.mesh` is unreferenced by all readable script.** Zero hits for `constructiondummy` outside `player.script:200-228` comments/names, and `_player_CreateConstructionDummy*` has **no script caller** (creation is engine-native). The live placement ghost the scripts operate on (`gint_gui_pickedbldhnd`) is the **real building object** (`_player_CreateConstructionDummyBySID`: `CreatePlayerGameObjectHandleByHandle(plHnd, gc_racename_buildings, sid, …)` + hide child 0 + `SetGameObjectColIntMaskOptions(goHnd, True, False)`), positioned per-frame by `_misc_GUIProgressPickedBldUID` and destroyed on cancel. So `DONOR_GHOST_SCALE 0.5` applies **only if** the ghost instantiates the misc `box` dummy — the script evidence says the ghost is the building mesh at **its own prop scale**, blinked by the effect. This corrects the `IMPL-FX-ART` assumption; capture (§7) discriminates.
- **[U]-G-reduced, not closed.** Closed statically: alpha keys, emission flag/values, period formula, blend/loop flags. Still native-side (needs capture): `TXLifeColorEffect` key interpolation (linear vs smooth), meaning of `Time[i]` (segment duration vs key time), `GetTimeSpeedFactor` runtime values, and which mesh actually renders at placement (building vs `box.mesh`).

## 1. Pass P1 — `constructiondummy.prop` / `box.actor` / `box` material / inherited scale (full text)

`D:data/objects/misc/constructiondummy.prop` (16 lines, complete):
```
{refurl=.\data\objects\ref\refmisc.prop}
mainproperty … CustomName = constructiondummy / BaseName = constructiondummy
actorproperty … LODActorName = box / DefaultMeshName = box.mesh
materialproperty … Mesh[0].DefaultMaterialName = box / Mesh[0].UseableMaterials[0] = box
```
No colour / alpha / blink / emission key exists in this file. `D:data/objects/misc/box.prop` is byte-identical in structure (`CustomName/BaseName = box`, same actor/material lines).

`D:data/actors/misc/box.actor` (complete): `ActorList.Items[0].Name = box.mesh`, `LODList.Items[0].MeshObjects.LoadFromFile = .\data\actors\misc\box.osm`.

`D:data/materials/misc/misc.mat` §1 (complete): `Material.Name = box`, `Texture.image = .\data\materials\misc\box.dds`, `Texture.minfilter = miLinearMipmapNearest`. No `BlendingMode`, no colour/alpha keys → engine default from `D:data/materials/ref/refbase.mat` (`BlendingMode = bmAlphaTest50`, ambient 0.25 / diffuse 0.78125, emission 0). So the `box` material contributes **texture only**; any translucency comes from the `TXLifeColorEffect` (which sets `UseBlendMode=True`, `BlendingMode=1 // bmTransparency`, `unit.script:6758-6760`).

Inherited placement constants from `D:data/objects/ref/refmisc.prop` (neither `.prop` overrides them):
- scale `DefaultScale X/Y/Z = 0.5` (`:210-213`), `DefaultScaleFactor = 1` (`:218`), AABB `±0.5` / sphere `0.5` (`:89-…`, collisionmeshproperty).
- offset `X/Y/Z = 0`, `AutoOffset = True`, `OffsetCollideOption = ocoTerrain` (`:259-265`).
- selection `SelectionSize = 0.5`, `SelectionColor Red/Green/Blue/Alpha = 1` (`:282-291`) — white, opaque; **not** a ghost tint (selection ring only).

## 2. Pass P2 — blink function verbatim (`data/scripts/lib/unit.script:6674-6805`)

```
6674 // _unit_DoConstructionBlinkGameObject
6676 procedure _unit_DoConstructionBlinkGameObject(goHnd, mode; bUseColor, bJustUpdate)
6679    var totalTime : Float = 0.525*1.25;              // = 0.65625 s per key at speed factor 10
6680    if (GetTimeSpeedFactor>0) then
6681    totalTime := totalTime*(GetTimeSpeedFactor/10);  // native GetTimeSpeedFactor; no script def (searched dmscript.global: no hit)
6682    var cr, cg, cb : Float = 1;  var cr0, cg0, cb0 : Float = 1;
6684    var minalpha, maxalpha : Float = 1;  var bemission : Boolean;
6687    gc_gui_blinkmode_canbuild : begin                // = 0 (dmscript.global:1119)
6688       cr0 := 0.7; cg0 := 0.7; cb0 := 0.7;  cr := 0.7; cg := 0.7; cb := 0.7;
6694       minalpha := 0.35;  maxalpha := 0.5;  bemission := False;
6698    gc_gui_blinkmode_cannotbuild : begin             // = 1 (dmscript.global:1120)
6699       cr0 := 0.9; cg0 := 0.2; cb0 := 0.1;  cr := 0.9; cg := 0.2; cb := 0.1;
6705       minalpha := 0.45;  maxalpha := 0.5;  bemission := True;
6711    if (bJustUpdate) then … else begin               // create path:
6736       BehaviourDestroy(GetEffectByKey(goHnd, 'blink'));
6737       effHnd := EffectCreateWithKey(goHnd, 'TXLifeColorEffect', 'blink', false);
6740-6760  UseAmbient/Diffuse/Specular/Shininess/TexOffset/TexScale/ShaderID=False; UseJustColorIfNoLight=True;
             UseFrontFace/BackFace=True; IgnoreFog/NoLighting=False; CurrIndex=0; Enable=True;
6753       Loop=True (// False); LoopBackward=False; BounceBackward=False; ZWrite=True; ZTest=True;
6758       UseBlendMode=True; UseCullFace=True; BlendingMode=1 (// bmTransparency); FaceCulling=0 (// fcCull)
6763    if (bUseColor) then begin                        // NEVER taken on observed paths (all callers pass False)
6765       UseAlphaChannel=False; UseColor=True;
6769-6778  Color[0]=(cr,cg,cb,maxalpha) Time[0]=totalTime; Color[1]=(cr0,cg0,cb0,minalpha) Time[1]=totalTime;
             Color[2]=(cr,cg,cb,maxalpha) Time[2]=0;
6782    else begin                                       // LIVE path:
6782       UseAlphaChannel=True; UseColor=False;
6787-6792  AlphaChannel[0]=maxalpha; [1]=minalpha; [2]=maxalpha; Time[0]=Time[1]=Time[2]=totalTime;
6793-6795  Emission[0]=(0.8,0,0,1); Emission[1]=(0.6,0,0,1); Emission[2]=(0.8,0,0,1);
6740       (shared) UseEmission=bemission;
6797-6798  for i:=childCount-1 downto 0: recurse (child, mode=0, bUseColor, bJustUpdate) — note mode 0 hits NEITHER
             case arm (0 = canbuild constant but passed as raw 0 AFTER the case already ran on the parent; children
             re-enter the case with mode=0 → canbuild arm: cr=0.7 grey, alpha 0.5/0.35, emission False).
6716-6728  bJustUpdate path (per-frame while dragging): bUseColor=False →
             AlphaChannel[0]=maxalpha, [1]=minalpha, Time[0..1]=totalTime, UseEmission=bemission.
```

Recovered donor law (literals [O], effect-key semantics [U] — engine-native):
| item | canbuild (0) | cannotbuild (1) |
|---|---|---|
| alpha keys | 0.5 → 0.35 → 0.5 | 0.5 → 0.45 → 0.5 |
| per-key time | `0.525*1.25*(speed/10)` = 0.65625 s @ speed 10 | same |
| triangle period (2 segments) | **1.3125 s @ speed 10**, scales linearly with `GetTimeSpeedFactor` | same |
| emission enable | False | True |
| emission keys (create path, both modes) | (0.8,0,0)/(0.6,0,0)/(0.8,0,0) written but disabled | same values, enabled |
| rgb keys | 0.7 grey — **written only in `bUseColor=True` branch, never executed** | 0.9/0.2/0.1 red — likewise dead |
| blend | override bmTransparency, loop, ZWrite+ZTest, cull fcCull | same |

Donor quirk recorded, not judged: `bemission` is assigned only inside the two case arms; any other `mode` value leaves it undefined (all live callers pass 0/1, so defined in practice).

## 3. Pass P3 — placement/selection flow: which object blinks

- `dmscript.global:1119-1120`: `gc_gui_blinkmode_canbuild = 0`, `gc_gui_blinkmode_cannotbuild = 1`.
- `_misc_GUIProgressPickedBldUID` (`data/scripts/lib/miscext2.script:1021-1199`): every frame while a building is picked — snap `mx/mz` to `floor(mx*2)/2+0.25`, resolve `cid/id/usage` from the go tag, `_misc_GetAdjustedBuildingPos` (±0.5/±1 search), `SetGameObjectPositionByHandle(goHnd, mx, my, mz)` (mouse Y; mine branch uses deposit Y via `_unit_FindMinePositionAndType`), `_misc_CanPlaceBuilding(…, gc_path_mincoldist, 0.26, 0.5, gc_path_minemincoldist, True)`, then `_unit_DoConstructionBlinkGameObject(goHnd, blinkMode, False, True)` (`:1076-1078` walls per-cell, `:1088-1091` single wall, `:1193-1196` general incl. port `bui` children at `±3 m` cardinals `:1150-1190`). Wall-cluster creation forces canbuild (`:965-972`, can-place test commented out).
- `_player_CreateConstructionDummyBySID` (`data/scripts/lib/player.script:202-218`): creates `CreatePlayerGameObjectHandleByHandle(plHnd, gc_racename_buildings, sid, px, RayCastHeight(px,pz), pz)` — the **building**, not the misc dummy — hides child 0 (`:210-212`), disables colormask (`SetGameObjectColIntMaskOptions(goHnd, True, False)`, `:214`), tags `cid*256+id` (`:216`). **No script caller exists** (searched all `lib/*.script` + `misc/*.inc` states + `player.script`); invocation is engine-native (GUI build-button path). Status: strong inference, creation call itself [U]-native.
- `_misc_GUICancelBuilding` (`miscext2.script:3902-3951`): destroys `gint_gui_pickedbldhnd` (walls: segment unwind vs full destroy).
- Key-colour (`_misc_ApplyKeyColorRecursiveChild`, `misc.script:5065-5084`) is applied at build start (`building.inc/initial.inc:137-138`, `ontagstates.inc:261-262,306-307`) via `SetGameObjectUniform4fByHandle(goHnd, 0, gKeyColor[…], a, False)` — a **uniform**, unrelated to the alpha/emission blink; ghost tint is not key-colour.
- `gui.script:240,270-274,392,421-425` `btn.dummy` hits are GUI button materials, unrelated. `SetGUIMiniMapPrimitiveBlink(prim, 0.2, …)` (`miscext2.script:268`) is minimap-only (0.2 s), unrelated to the 3D ghost.
- `control.script`: no `pickedbld`/`ConstructionDummy`/blink references (grep-verified) — placement confirmation lives in the native GUI state machine + `miscext2` progress/cancel above.

## 4. Pass P4 — `box.osm` / `box.dds` bytes + derived port assets

- `D:data/actors/misc/box.osm`: 660 B, `IDP2` v8 container, `SkinBitMap` section, single frame `FRAME 000` (printable-string dump; no vertex floats in cleartext — vertex data is binary). Derived `variant3d/assets/fx/models/box.obj` (610 B, 8 verts: unit cube `±0.5` in X/Y, `0..1` in Z pre-bake; `box.mtl` 47 B) is consistent with the `±0.5` AABB: **unit-cube geometry [O]**.
- `D:data/materials/misc/box.dds`: `DDS ` magic, 512×512, DXT1 (`FOURCC=DXT1`), 10 mips, 174904 B total. Block sampling (data offset 128): 32/40 spread blocks are byte-identical solid-red DXT1 (`c0=0xF801≈(1,0,0)`, `c1=0xF800`, idx `0x55` = full (2·c0+c1)/3 blend → uniform red texels); 8/40 blocks are a two-colour red/green pattern (`c0=0x07E0` green, `c1=0xF800` red). Reading: **red-dominant texture with minority detail blocks** — full pictorial decode needs an image pipeline (not done; no file written). Do NOT claim "solid red".
- `red.dds` / `yellow.dds` (same dir, same 174904 B, materials `red`/`yellow`, `bmOpaque`): share identical first two blocks but differ later (data-SHA red `196C…` ≠ yellow `6F5B…` ≠ box `C5B9…`). No script links either material to the ghost/placement path (zero hits for `red`/`yellow` material names in `lib/*.script` placement code) — their consumer is unrecovered; they are **not** the ghost OK/BAD source on current evidence.
- Derived `variant3d/assets/fx/tex/box.png` (2199 B) exists; pictorial fidelity of the conversion is outside this worker's scope (see `IMPL-FX-ART`).

## 5. Pass P5 — port anchors (`variant3d/scripts/world3d_fx.gd`, read-only)

| port line(s) | content | donor truth from this report |
|---|---|---|
| 177-178 | `GHOST_OK = Color(0.20,1.00,0.30,0.45)`, `GHOST_BAD = Color(1.00,0.25,0.20,0.45)` (`world.gd:3509`) | invented green/red; donor has NO rgb tint on live path — alpha 0.5/0.35 vs 0.5/0.45 + emission off vs red pulse |
| 460, 592, 1459-1476 | `DONOR_GHOST_SCALE 0.5`, `_donor_ghost` from `DONOR_BOX_OBJ/TEX`, honest `[U]-G` meta | scale 0.5³ correct **for the misc box object only**; script evidence says live ghost = building mesh at own scale |
| 1625-1651 | `_ghost_mat` fallback + `_ghost_building` share | same stand-in tint |
| 2299-2312 (`_update_ghost`) | `sin(_time*4.0)` pulse `0.85+0.15`, applied to `_ghost_mat` AND `_donor_ghost_mat` (`:2306-2312`) | donor period 1.3125 s·(speed/10) triangular alpha; `sin(4t)` ≈ 1.57 s sinusoidal — both value and waveform wrong; also tints donor box albedo, which donor never does |
| 94-97, 1054, 1471, 1474 | `[U]-G` labels | labels stay until capture passes |

## 6. File/line port change list for `world3d_fx.gd` (NOT applied — owner/IMPL worker applies after §7 capture)

1. `:177-178` — replace `GHOST_OK/BAD` rgb with donor alpha law; keep names as mode flags only. Suggested: `GHOST_OK_ALPHA := [0.5, 0.35, 0.5]`, `GHOST_BAD_ALPHA := [0.5, 0.45, 0.5]`, `GHOST_BAD_EMISSION := [Color(0.8,0,0), Color(0.6,0,0), Color(0.8,0,0)]`, `GHOST_KEY_TIME := 0.525*1.25` (× `GetTimeSpeedFactor/10` equivalent), all citing `unit.script:6679-6707`.
2. `:2299-2312` `_update_ghost` — replace `sin(_time*4.0)` with triangle phase `fmod(_time_scaled, 2*T)/(2*T)` lerping maxalpha→minalpha→maxalpha; drive **alpha + emission-energy only**, never `albedo_color` rgb; stop writing `c` into `_donor_ghost_mat.albedo_color` (`:2311`). `UseEmission=False` for OK (but keep writing the red emission keys, disabled — donor does).
3. `:6753-6760` flags — set donor ghost material to transparent blend + ZWrite/ZTest on, loop; record `LoopBackward/BounceBackward=False` in a comment (no Godot equivalent needed).
4. `:1459-1476` `_init_donor_ghost` — after §7: if capture shows the ghost is the building mesh, repoint the donor ghost at the staged building mesh instance (own prop scale, mouse-Y/`RayCastHeight` placement per `player.script:207`, `miscext2.script:1100-1135`) and demote `box.obj` binding to fallback; update `:1474` status string accordingly. Do NOT delete the box binding before capture passes.
5. `:260-265`-style placement constants — no change: `±0.5/±1` adjust search (`miscext2.script:1038-1075`) is sim-side, out of `world3d_fx.gd` scope; noted for the placement worker.
6. Labels `:94-97, 1054, 1471, 1474, 448` — flip `[U]-G → [O]` with `unit.script` + capture ids only when §7 terminates with zero mismatch.

## 7. Fixed-camera capture spec for any still-[U] item (zero-mismatch termination; never invent colour/blink)

- **E-GHOST-CAP (discriminates mesh + measures blink):** singleplayer skirmish, fixed camera (record pos/yaw/pitch/fov + `GetTimeSpeedFactor` value on screen or logged), order one building (e.g. mill), hold ghost unconfirmed ≥ 4 s sweeping OK→BAD→OK ground, then confirm, then re-pick and cancel. Log per frame: rendered mesh id (`box.mesh` vs building sid mesh), material/blend state, sampled framebuffer rgb+alpha of ghost pixels, frame counter + game-time.
- **Termination (all required, zero mismatch or the item stays [U]):** (a) mesh id constant across ≥ 120 consecutive ghost frames and matching the script-inferred source; (b) measured alpha period within ±1 frame of `2×0.525×1.25×(speed/10)` s with triangle shape (max→min→max, no sinusoid shoulder) over ≥ 3 consecutive cycles in EACH mode; (c) OK alpha floor 0.35±0.02, BAD floor 0.45±0.02, ceiling 0.5±0.02 (read back via framebuffer against known background or engine alpha readout); (d) BAD shows red emission lift, OK shows none; (e) scale = building prop scale (or 0.5³ box if mesh reads `box.mesh`) within ±1 cm; offset Y = mouse/RayCast height ±1 cm. Any mismatch → report ids, keep `[U]-G`, do not tune constants to fit.
- **Out of scope for this capture:** `TXLifeColorEffect` interpolation internals (native), `GetTimeSpeedFactor` table (log value, don't derive), box.dds pictorial decode (converter pipeline's job).

## 8. Residual unknowns (explicitly NOT recovered — no guess recorded)

- Whether `constructiondummy`/`box.mesh` ever instantiates at runtime (zero script references; creation call native). Discriminated by E-GHOST-CAP (a).
- `TXLifeColorEffect` `Time[i]` semantics (segment length vs absolute key time) and key interpolation (linear assumed by triangle reconstruction — engine-native, capture §7(b) decides observably).
- `GetTimeSpeedFactor` value table (native; log at capture).
- Full `box.dds` pictorial content (block-sampled only, §4) and `box.osm` binary vertex decode (unit cube confirmed via derived OBJ + AABB, not via binary parse).
- `red.dds`/`yellow.dds` consumer (materials exist, no placement-link found).

No donor parity, similarity score, threshold or gate PASS is claimed. All donor reads were text/directory/byte-inspection against pin `t_87f0f3c130b0`; no donor binary was executed.
