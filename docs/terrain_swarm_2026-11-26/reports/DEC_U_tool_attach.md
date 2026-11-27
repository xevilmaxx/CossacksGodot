---
id: DEC-U-TOOL-ATTACH
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: "WORKER DEC-U-TOOL-ATTACH — donor 1:1 peasant tool-attach decomp (read-only)"
owner_file: docs/terrain_swarm_2026-11-26/reports/DEC_U_tool_attach.md
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_ASSET_CONFIG_GODOT_GIT_EDIT
created: 2026-11-26
labels: [O, D, I, U, NO_PARITY_CLAIM, NO_APPROXIMATION]
parity_guard: "NO DONOR PARITY IS CLAIMED. No same-camera donor/port A/B frame was produced or examined. Every donor statement is a read-only file/line observation; every port statement is a read-only source line. 'Required conversion' names work to be done, not work done."
scope_guard: "Exactly one repo file written (this report). No source, shader, config, asset, fixture, test, runner, Godot, git or user-mod edit. Donor binary and donor data tree read READ-ONLY; no donor executable run, no donor bytes copied into the repo. Singleplayer skirmish only."
donor_pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe data tree C:\\Games\\Cossacks 3\\data read READ-ONLY. Pin cited, binary not executed here; passes below are text/directory/header reads only."
port_scope: "variant3d/scripts/{anim3d,world3d_entities}.gd + variant3d/tools/{convert_skins,bake_sprites}.py + variant3d/tools/unit_bakers/peasants.py + variant3d/assets/models/skin/index.json (read-only line citations)"
prior_reports_read:
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_aaf_art_audit.md ([U]-T framing corrected here, see §1)
  - variant3d T-table anim3d.gd:1356-1440 (state→action resolver, read in situ, not re-derived)
---

# DEC-U — peasant tool-attach decomp (donor 1:1)

> READ-ONLY. Singleplayer skirmish only. No parity claim. No approximation endorsed.
> Each `[U]` ends in a named fixed-camera close-up capture with a zero-mismatch
> termination criterion. Nothing is closed by a port fallback. No body mesh is
> ever reused as a tool (the stub verts inside the body mesh are NOT the tool —
> port's own 2D baker already states this at `bake_sprites.py:349`).

## 0. Method, labels, passes

- **[O]** = observed donor file line / directory entry / binary header words / port
  line. **[D]** = arithmetic over cited [O]. **[I]** = reading without runtime
  proof. **[U]** = unresolved after the passes here.
- Path shorthands: `D:` = `C:\Games\Cossacks 3\data\` (read-only).
  `P:` = workspace `variant3d\`.
- `ev_` ids are not binary-decomp ids; the evidence is the cited donor
  `path:line` (or header words) itself, verified by a second read pass where noted.
- Donor `.oss` headers below are raw little-endian `<6i k,fps,b,v,fc,t` words
  (field semantics from the port reader `convert_skins.py:144` /
  `docs/decomp/DC_FORMATS.md:46-64`, themselves read-only citations). No donor
  binary was executed; headers were read as bytes, never run.

### 0.1 Correction to DEC_U_aaf_art_audit [U]-T (read first)

The audit (§2.1 P8, §4 [U]-T) reported "no `peaukr_*` tool file in
`D:actors/units`" and concluded tool motion "has no `.oss`". That premise is
**refuted**: the audit globbed only the parent dir. Pass P1 here shows all
7 tool tracks live one level down in `D:actors/units/attach/` (ev_P1), each
nation's 7 tools plus its own `_tools.actor`. [U]-T-as-framed is therefore
CLOSED (not by capture, by refutation with cited bytes). What remains is
narrower and precisely stated in §4: (T-A) runtime proof of the child
swap/visibility per frame, and (T-B) port-side 3D implementation proof.
No synthesis was ever needed; none is proposed.

### 0.2 Pass ledger (multiple passes; strange-read log inline)

| Pass | Operation (read-only) | Result |
|---|---|---|
| P1 | `Get-ChildItem D:actors` recurse `peaukr_*`, `*tool*`, `*attach*`; `D:objects` recurse `peaukr*` | 56 `pea<nat>_<tool>.oss` (8 nations × 7) + 8 `<nat>_tools.actor` under `D:actors/units/attach/`; `peaukr_tools.prop` under `D:objects/units/attach/`; `peaukr.prop` autochildren = `peaukr_tools` [O] (§1) |
| P2 | Full read `peaukr_tools.actor` + `peaukr_tools.prop` + `pearus_tools.actor:1-30` | 7 attach slots in fixed order axe,bag,cart,hammer,hoe,lumber,pick; ALL slots share the nation's own `.aaf`; `peaukr_tools.prop` carries NO offset/rotation/scale keys [O] (§1–§2) |
| P3 | Full read `peaukr.prop` autochildren + `pearus.prop` autochildren; BaseName check of all 8 `*_tools.prop` | All 8 nations: `BaseName=<nat>_tools`, `DefaultMeshName=<nat>_axe.mesh`, material `peaaustools` ×7 [O] (§1) |
| P4 | `<6i` header words of `peaukr.oss` + 7 `peaukr_<tool>.oss` + `pearus.oss`/`pearus_axe.oss`/`peasco_hammer.oss` | Body `k=483,fps=30,b=20`; EVERY tool `fps=30, b=1, k=body k` (483 ukr / 486 rus); per-tool v/fc/t in §2 table [O] (§2) |
| P5 | Full re-read `peaukr.aaf` + `pearus.aaf` (second pass vs audit §1) | 18 rows each; ukr `death 115..149`, rus `workfood 281..304 / idlefood 408..457 / walkfood 259..278 / reaction 459..484` (nation-shifted, max 484 ≤ k=486) [O] (§2) |
| P6 | Full read `_unit_ManagePeasantAttach` (`unit.script:6981-7019`) + 4 call sites | Complete action→actorInd map + visibility rule; call sites `unit.script:11068-11069`, `movie.script:657`, `ontagstates.inc:534`, `nothing.inc:63` [O] (§3) |
| P7 | `dmscript.global:868-934` constants + `DoSetupMoveAnimation` (`unit.script:10856-10954`) + `DoSetupMoveAnimation` aix/poverty variant (`ontagstates.inc:302-343`) | `gc_actor_peasant_{axe,bag,cart,hammer,hoe,lumber,pick}=0..6`; extract→work*, build→construct, resource→carry anims; blend `0,0` + reset on the work path [O] (§3) |
| P8 | Per-nation count of `pea*.oss` in attach/ (expect 8×7) | 8 nations × exactly 7 [O] (§1) |
| P9 | `units.mat:1-40` + `refunit.prop:231-243` + `refunitattach.prop` full | `peaaustools→peaaustools.dds` (one shared tool texture); both refs `DefaultScale 0.5³`, no rotation/offset keys on the attach [O] (§2) |
| P10 | Port grep `convert_skins.py` / `bake_sprites.py:343-409` / `peasants.py:203-243` / `anim3d.gd:79-98,258` / `world3d_entities.gd:1945-2045` | 3D skin pipeline has NO attach handling; 2D sprite baker ALREADY skins attach tools; `anim3d.gd:258` T22 note stale; `_unit_action` work/carry complete, zero tool-child code [O] (§5) |

**Strange-read log:** one anomaly, resolved inside the pass. `pearus_axe.oss`
reports `k=486` while `peaukr_axe.oss` reports `k=483`. Re-read of both bodies
(`pearus.oss k=486,b=22`; `peaukr.oss k=483,b=20`) plus both AAFs (rus max
frame 484, ukr max 481) shows the invariant is per-nation (`k_tool =
k_body ≥ max AAF frame`), not cross-nation. Not a corruption; recorded as
[D] in §2. Second anomaly: `peaukr.aaf` here reads `death 115..149` while
older notes carried `death 115..149` — identical; no drift. No branch polarity
was guessed; no binary bytes were interpreted beyond the cited `<6i` header.

---

## 1. Exhaustive donor glob: tool-attach meshes / materials / hooks

### 1.1 Meshes — `D:actors/units/attach/` (ev_P1/P8) [O]

56 files, 8 nations × 7 tools, every nation complete:

| Nation base | Tools present (`<base>_{axe,bag,cart,hammer,hoe,lumber,pick}.oss`) |
|---|---|
| `peaaus` / `peaeng` / `peapol` / `pearus` / `peasco` / `peaspa` / `peatur` / `peaukr` | 7/7 each (P8 group count) |

8 actor manifests `D:actors/units/attach/<base>_tools.actor` (ev_P1/P9).
`peaukr_tools.actor` (full read, ev_P2): `ShaderLODList 26 / 23` (body actor
uses `18 / 11` — shading-LOD difference recorded, effect unrecovered, folded
into [U]-T-B), `Animations.LoadFromFile = .\data\animations\aaf\peaukr.aaf`
(the SAME timeline as the body), 7 `ActorList.Items` in fixed order:

`[0]=peaukr_axe.mesh → attach/peaukr_axe.oss`, `[1]=bag`, `[2]=cart`,
`[3]=hammer`, `[4]=hoe`, `[5]=lumber`, `[6]=pick`.

`pearus_tools.actor:1-30` (ev_P4b) repeats the identical structure against
`pearus.aaf`. Slot order == `gc_actor_peasant_*` index order (§3).

### 1.2 Object bindings — `D:objects/units/*.prop` + `attach/*_tools.prop` [O]

- `peaukr.prop` autochildren (ev_P2): child `BaseName = peaukr_tools`,
  `DefaultMeshName = peaukr_axe.mesh`, 7 `Mesh[]` names
  (`peaukr_{axe,bag,cart,hammer,hoe,lumber,pick}.mesh`), `DefaultMaterialName
  = peaaustools`, 7 `Materials[] = peaaustools`.
- `pearus.prop` autochildren (ev_P10): identical shape with `pearus_*` stems.
- All 8 `D:objects/units/attach/<base>_tools.prop` (ev_P2/P11):
  `CustomName = BaseName = <base>_tools`, `LODActorName = <base>_tools`,
  `DefaultMeshName = <base>_axe.mesh`, `UseableMeshes[0..6] = True`,
  `Mesh[0..6].DefaultMaterialName + UseableMaterials[0] = peaaustools`.
  **No `Offset*`, `Position*`, `Rotation*`, `Scale*`, or per-action key
  exists in any of these files** (full-file reads). The attach ride-along
  transform is therefore the identity relative to the parent in every text
  source examined — runtime confirmation is [U]-T-A, not assumed.

### 1.3 Materials [O]

- `D:materials/units/units.mat:18-19` (ev_P11): `Material.Name = peaaustools`
  → `.\data\materials\units\peaaustools.dds` (`tfDefault`). ONE shared tool
  texture for all 8 nations (body textures stay per-nation `pea<nat>.dds`).
- `D:materials/units/peaaustools.dds` present on disk (ev_P7b listing).
- Scale refs: `D:objects/ref/refunit.prop:231-243` and
  `D:objects/ref/refunitattach.prop` (full read, ev_P4a) both declare
  `ScaleProperty DefaultScale X=Y=Z=0.5`, `RandomScale=False`,
  `Min/MaxScaleFactor=1`, `DefaultScaleFactor=1`; attach
  `DirectionUp (0,1,0) / DefaultUp (1,0,0)` equals the unit default.
  [D]: uniform 0.5³ inherited by both parent and child; no per-tool scale.

### 1.4 Animation hooks (all donor call sites) [O]

| Site | Lines | Role |
|---|---|---|
| `D:scripts/lib/unit.script:6981-7019` | `procedure _unit_ManagePeasantAttach` | THE map (§3) |
| `D:scripts/lib/unit.script:11068-11069` | sim tag engine, after anim select | `usage=peasant ∧ childCount>0 ∧ anim<>'' → ManagePeasantAttach` |
| `D:scripts/lib/movie.script:632-657` | `_movie_UnitPlayAnimation` tail | same call after `SwitchToTreeAnimationCyclesBlend(0,maxblend)` + mode set |
| `D:scripts/units/unit.inc/ontagstates.inc:533-534` | aix OnTagStates tail | same call, `myHnd` |
| `D:scripts/progress/progress.inc/nothing.inc:60-63` | poverty/progress walk switch | same call after deferred walk switch (`min/maxFrameBlend 6/8` locals) |

No other script references any `pea*_tools`, `actorInd`, or tool mesh name
(tree-wide `Select-String` for `ManagePeasantAttach` returned exactly these 6
hits across 5 files; `peaukr_axe`/`peaaustools` outside actors/objects/materials:
zero script hits). The hook surface is closed at these 5 sites.

---

## 2. Per-action attach table: mesh, frames, skin track, transform

### 2.1 The map (`unit.script:6991-7012`, ev_P6) [O]

`childHnd = GetGameObjectGOHandleChildByHandle(goHnd, 0)`; default
`bVisible=True`, `actorInd` unset unless matched:

| Donor anim (action) | actorInd (`dmscript.global:928-934`) | Mesh attached | Visible |
|---|---|---|---|
| `workfood` | 4 `gc_actor_peasant_hoe` | `<base>_hoe.mesh` | yes |
| `workwood` | 0 `gc_actor_peasant_axe` | `<base>_axe.mesh` | yes |
| `workstone` | 6 `gc_actor_peasant_pick` | `<base>_pick.mesh` | yes |
| `construct` | 3 `gc_actor_peasant_hammer` | `<base>_hammer.mesh` | yes |
| `attack0` | 0 `gc_actor_peasant_axe` | `<base>_axe.mesh` | yes |
| `walkfood` / `idlefood` | 1 `gc_actor_peasant_bag` | `<base>_bag.mesh` | yes |
| `walkwood` / `idlewood` | 5 `gc_actor_peasant_lumber` | `<base>_lumber.mesh` | yes |
| `walkstone` / `idlestone` | 2 `gc_actor_peasant_cart` | `<base>_cart.mesh` | yes |
| `''`, `walk`, `idle`, `death`, any other | — | (previous mesh hidden) | **NO** |

Effect when visible: `SetGameObjectActorIndexByHandle(childHnd, actorInd)`
then `SetGameObjectVisibleByHandle(childHnd, bVisible)` (`unit.script:7014-7016`).
"Carry" in the task = the six `walk*/idle*` rows (resource in hands); they are
ordinary AAF windows on the shared timeline, not a separate system.

### 2.2 Frames: shared AAF timeline, per-nation windows [O/D]

The attach actor loads the nation's own `.aaf` (ev_P2), so the tool plays the
**same action window** as the body. Donor windows re-read in P5:

| Action | `peaukr.aaf` window | `pearus.aaf` window (nation shift proof) |
|---|---|---|
| `workfood` | 278..299 | 281..304 |
| `workwood` / `attack0` | 237..254 | 237..254 |
| `workstone` | 217..234 | 217..234 |
| `construct` | 186..198 | 186..198 |
| `walkfood` / `idlefood` | 257..276 / 405..454 | 259..278 / 408..457 |
| `walkwood` / `idlewood` | 22..41 / 354..403 | 22..41 / 357..406 |
| `walkstone` / `idlestone` | 43..62 / 303..352 | 43..62 / 306..354 |
| `reaction` | 456..481 (no tool: hidden) | 459..484 |

[D]: never copy one nation's window onto another sid (port already honours
this: `convert_skins.py:80-81` per-sid lookup; `anim3d.gd:106-113`).

### 2.3 Skin tracks: YES, donor provides one per tool [O]

`<6i k,fps,bones,v,fc,t` header words (ev_P4/P12):

| `.oss` | k | fps | b | v | fc | t | bytes |
|---|---|---|---|---|---|---|---|
| `peaukr.oss` (body) | 483 | 30 | 20 | 577 | 921 | 733 | 312376 |
| `peaukr_axe.oss` | 483 | 30 | **1** | 124 | 138 | 130 | 20876 |
| `peaukr_bag.oss` | 483 | 30 | **1** | 172 | 268 | 209 | 25780 |
| `peaukr_cart.oss` | 483 | 30 | **1** | 495 | 413 | 523 | 39524 |
| `peaukr_hammer.oss` | 483 | 30 | **1** | 128 | 108 | 138 | 20316 |
| `peaukr_hoe.oss` | 483 | 30 | **1** | (audited by port reader, see note) | | | |
| `peaukr_lumber.oss` | 483 | 30 | **1** | 1214 | 746 | 1220 | 70348 |
| `peaukr_pick.oss` | 483 | 30 | **1** | 62 | 96 | 88 | 18044 |
| `pearus.oss` (body) | 486 | 30 | 22 | 527 | 864 | 662 | 338128 |
| `pearus_axe.oss` | 486 | 30 | **1** | 124 | 138 | 130 | 20960 |
| `peasco_hammer.oss` | 483 | 30 | **1** | 128 | 108 | 138 | 20316 |

Note on `peaukr_hoe.oss`: its header was dumped in the P4 batch (byte
signature `E3 01 / 1E / 01-bone` identical to the axe/hammer family); the
per-vertex counts are read by the same port reader at conversion time, never
hand-copied here — the converter (`bake_sprites.read_oss`) already parses all
seven tools for the 2D path (`peasants.py:213-222` per-tool `bones/verts/faces/
k/fps` audit block). No value above is synthesised; any single number can be
re-dumped with the retained procedure in §4.

[D] invariants, usable as conversion gates:
- `k_tool == k_body` per nation (483 ukr incl. `peasco`, 486 rus),
  `max AAF frame ≤ k` (481 ≤ 483 ukr; 484 ≤ 486 rus).
- `b_tool == 1`, `fps_tool == 30 == fps_body`. Tool motion is a rigid
  single-bone track on the shared frame timeline — no multi-bone tool rig
  exists anywhere in the attach tree.
- Bone-track byte volume check: `axe 20876 B` vs body `312376 B` — the tool
  is NOT baked into body vertices (independent payload).

### 2.4 Offset / rotation / scale per action [O/D, remainder → U]

- Offset: **no donor key** (full-file reads §1.2; zero script transform args
  at §1.4 sites). The tool's world placement is baked into its own
  single-bone track (`anim[0][frame]` position+quaternion), sampled at the
  SAME donor frame index as the body.
- Rotation: **no donor key** (same evidence). Orientation rides in the
  tool track quaternion.
- Scale: uniform `0.5³` inherited from refs (§1.3); identical for parent and
  child, therefore relative scale = 1.
- [D]: the attach is fully described by `(actorInd, visible, sharedFrame)` —
  there is no per-frame offset table to recover and none to invent.

---

## 3. State→action→tool chain (donor text, for the port change list)

- Work selection: `unit.script:10865-10874` (`extract` + resource type →
  `workfood/workwood/workstone`), aix mirror `ontagstates.inc:302-312`;
  work path plays with **blend `0,0` + `GameObjectResetFrameAnimationBlend`**
  (`unit.script:10891-10893`) — the tool and body stay frame-locked because
  both switch on the same call.
- Build: `unit.script:10877` (`action_build → construct`), aix
  `ontagstates.inc:316-320` (`bBlend=True`, then the same `0,0` early-out at
  `:329-343`); attack: `unit.script:10878-10883` / `ontagstates.inc:322-328`
  (`weapon_none/0 → attack0`, hence peasant melee shows the **axe**).
- Carry: `unit.script:10898-10922` (resource → `idlefood/idlewood/idlestone`
  stationary, `walkfood/walkwood/walkstone` moving), poverty variant
  `nothing.inc:18-20`; walk cascade `nothing.inc:27-58` with
  `_unit_IsAnimationExists` fallback to `walk`.
- Peasant gating of the attach call itself: `unit.script:11068`
  (`usage=gc_obj_usage_peasant ∧ childCount>0 ∧ anim<>''`).
- `movie.script:644-657`: movie window uses `maxblend=5 iff bBlend`
  (NOT the sim 6/8) and still ends in `ManagePeasantAttach` — tool logic is
  identical on the movie path.

---

## 4. True gaps [U] — fixed-camera close-up captures, zero-mismatch criterion

- **[U]-T-A donor runtime proof of the swap.** Text shows actor-index swap +
  visibility on child 0 with no transform keys (§1.2, §2.4), but absence in
  text is not a runtime trace. **Capture (donor-attached game, fixed camera,
  close-up on one peasant per action):** run `workfood/workwood/workstone/
  construct/attack0` + `walkfood/walkwood/walkstone` + `idlefood/idlewood/
  idlestone` + `walk/idle/death` (12 tool-visible + 3 hidden cases); log per
  frame `(actionWindowFrame, child0 actorInd, child0 visible, tool mesh name)`.
  **Termination (zero-mismatch):** all 15 cases reproduce §2.1 exactly —
  right mesh per action, `visible=false` on every `walk/idle/death` frame —
  with 0 mismatching frames across the FULL windows (22–50 frames each, not
  thumbnails). Until then §2.1 stays `[O]-text + [U]-runtime`.
- **[U]-T-B port 3D implementation proof.** The port 3D path renders body
  motion only (no tool-child node exists — §5). After the §5 change list
  lands: **fixed-camera, same donor frame index, tool-mask pixel diff = 0**
  per action window (donor tool silhouette vs port tool render, body excluded
  by mask), plus occlusion parity where the cart/lumber overlaps the body.
  This single capture also covers the `ShaderLOD 26/23 vs 18/11` shading
  difference (§1.1) — if tool pixels match at 0 mismatch, shading is proven;
  until then tool shading stays UNVERIFIED and no parity is claimed.
  **Termination:** 0 mismatching pixels on the tool mask for every sampled
  donor frame of all 8 tool-visible actions; hidden cases must show 0 tool
  pixels. Never synthesize: any nation/action whose `.oss` is absent (none
  are — 56/56 present) renders tool-detached and labelled, never a body-mesh
  reuse.

---

## 5. Exact port change list (file/line; no code written here)

Each row: port site **[O]**, donor fact **[O]/[D]**, required donor-faithful
replacement. **No row is implemented here.**

| # | Port file:line (current [O]) | Donor fact (this job [O]/[D]) | Required replacement + required donor assets |
|---|---|---|---|
| C1 | `P:tools/convert_skins.py:80-81` per-sid lookup; `:103` `ACTIONS_REQUESTED` (now incl. work/carry windows per `P:assets/models/skin/index.json` header); `:143-180` `read_oss`; `:207` `sample_frames`; `:360-372` export — **zero attach handling** (only attach special-case is the sail at `:117-125,285`) | 56 tool tracks `D:actors/units/attach/<base>_<tool>.oss`, `b=1, fps=30, k=k_body`, same-nation `.aaf` (`peaukr_tools.actor`, `pearus_tools.actor:1-30`); action→tool map `unit.script:6991-7012`; shared texture `units.mat:18-19` | Extend the converter: for each peasant sid base, ingest the 7 attach `.oss` (gate `b==1`, `k==body k`, `fps==30`; reject-and-label otherwise), sample the SAME per-action donor frames already exported for the body (`sample_frames`), emit per-sid `attach` entries `{tool, donor_oss, v, fc, t, anim[0][frame] positions+quats}` into the skin JSON + index schema bump. Assets: the 56 attach `.oss` + 8 `_tools.actor` (already on disk) — no new donor art, no byte invention |
| C2 | `P:assets/models/skin/index.json` header (`count=66`, per-sid `actions` incl. work/carry since C1 landed) — entries carry **no attach slots** | Same donor facts as C1 | Add per-peasant-entry `attach` block (7 tools × donor path + body-identical frame lists for the actions that show them per §2.1); hidden actions carry no attach frames. Through the approved converters only |
| C3 | `P:scripts/anim3d.gd:79-98` `AAF_ACTIONS` (windows present, reuse); `:258` T22 `"tool prop has no .oss bone tracks [U]-T"` — **STALE, refuted by §2.3**; `:340,:359,:752,:767` pose/`_frame_at` paths return body frame only | Tool tracks exist (`k/fps/b` §2.3) on the shared AAF timeline; tool frame == body frame (same switch call `unit.script:10891-10893`, same index into `k`) | Correct the T22 note to cite the attach `.oss` headers + `peaukr_tools.actor`; add `attach_for(sid, action)` (action→tool table mirroring `unit.script:6991-7012` + `dmscript.global:928-934` indices, gated by C2 slot presence) and return the tool track frame (bone 0 at the same donor frame index) alongside the body pose. No new windows, no alias, no fallback invention |
| C4 | `P:scripts/world3d_entities.gd:1945-2045` `_unit_action` (work `workfood/workwood/workstone`, carry `walk*/idle*`, `construct`, `attack0` all resolved; `:2008-2026` availability-gated chains); `:228` `MORPH_ACTION_MAP`; `:304` `ACTION_SELECTION_STATUS` ("tool-mesh attach [U]-T"); `:237` `CONSTRUCT_SKIN_STATUS` — **zero tool-child node code** (only `attach` hits are rotor/scaffold/smoke comments) | Swap+visibility semantics `unit.script:6988,7014-7016` (child 0, `SetGameObjectActorIndexByHandle` + `SetGameObjectVisibleByHandle`); identity relative transform (§2.4); `peaaustools.dds` material (§1.3); hidden for `walk/idle/death/''` | Add one tool-child `MeshInstance3D` under each peasant unit node, driven by the ALREADY-resolved `_unit_action` token through the §2.1 map: `visible + meshIndex` per action, hidden otherwise; identity local transform (no offset/rotation keys exist — none invented); material `peaaustools` via the approved `peaaustools.dds→PNG` path (the 2D baker already converts it at `bake_sprites.py:497`); missing-slot fallback = child hidden + per-sid DATA GAP label (never a body mesh, never another nation's tool). Update the three status strings' `[U]-T` pointers to this report |
| C5 | `P:tools/bake_sprites.py:343-409` `ATTACH_ACTIONS` + `peasants.py:203-243` attach audit — 2D path already skins tools (`axe:[workwood,attack]`, `hammer:[construct]`, `hoe:[workfood]`, `pick:[workstone]`, `lumber:[walkwood,idlewood]`, `bag:[walkfood,idlefood]`, `cart:[walkstone,idlestone]`) | Same §2.1 map (modulo the port's `"attack"` bridge token for donor `attack0`) | No change required on the 2D path; cite as the proven in-repo reader of the attach `.oss` layout for C1/C3 (`read_oss` handles `b=1` tracks today). Note the port bridge: `"attack"→axe` must resolve through `ACTION_ALIAS attack→attack0` first (`anim3d.gd:102-104`), matching donor `attack0→axe` |

Port sim/renderer rows outside this worker's attach scope (loop/clamp policy,
blend install, state→AAF triggers `[U] U2` owned by the active DEC_U state-map
work, `has_action` gating) are **not restated** to avoid a second source of truth.

Required donor asset manifest (through approved converters; **not copied here**):
`D:animations/aaf/pea<nat>.aaf` (8 files, per-nation windows) +
`D:actors/units/pea<nat>.oss` (8 bodies) +
`D:actors/units/attach/pea<nat>_{axe,bag,cart,hammer,hoe,lumber,pick}.oss`
(56 tool tracks) + `D:actors/units/attach/pea<nat>_tools.actor` (8 manifests) +
`D:objects/units/pea<nat>.prop` + `D:objects/units/attach/pea<nat>_tools.prop`
(16 bindings) + `D:materials/units/{pea<nat>.dds ×8, peaaustools.dds,
units.mat:18-19}` + hook texts `D:scripts/lib/{unit.script:6981-7019,
11068-11069, movie.script:632-657}` + `ontagstates.inc:533-534` +
`nothing.inc:60-63` + `dmscript.global:868-934`.

---

## 6. Claim register

| # | Claim | Label |
|---|---|---|
| 1 | 56 attach `.oss` (8 nations × 7 tools) + 8 `_tools.actor` + 8 `_tools.prop` exist; all slots share the nation's own `.aaf`; material `peaaustools` ×7 per nation; texture `peaaustools.dds` shared | [O] P1/P2/P3/P8/P9/P11 |
| 2 | Audit [U]-T premise ("no tool `.oss`") refuted — files were in `attach/`, outside the audit's glob | [D] this report §0.1 |
| 3 | Action→tool→visibility table (§2.1): `workfood→hoe, workwood→axe, workstone→pick, construct→hammer, attack0→axe, walk/idle food→bag, wood→lumber, stone→cart`; hidden for `''/walk/idle/death/else` | [O] `unit.script:6991-7012` + `dmscript.global:928-934` |
| 4 | Tool headers: `b=1, fps=30, k=k_body` (483 ukr/sco, 486 rus); `max AAF frame ≤ k` per nation | [O] header words; [D] invariant |
| 5 | No donor offset/rotation/scale keys on any attach binding, prop, ref, or hook call; inherited scale uniform `0.5³`; relative attach transform = identity in text | [O] full-file reads; runtime remainder → [U]-T-A |
| 6 | Port 3D skin pipeline ignores attach; 2D baker already consumes it; `anim3d.gd:258` note stale; `_unit_action` resolves all tool actions but spawns no tool node | [O] port lines §5 |
| 7 | Every [U] (T-A donor runtime, T-B port proof) has a fixed-camera close-up capture with a zero-mismatch termination criterion; none closed by fallback; no tool synthesised, no body mesh reused | [D] this report §4 |
| 8 | Any port visual equals donor tool motion/shading | **Denied** — no same-camera donor/port A/B exists; parity UNVERIFIED |

## 7. Scope statement

Exactly one repository file was written by this worker: this report. All donor
reads were read-only against pin `t_87f0f3c130b0`'s data tree
(`C:\Games\Cossacks 3\data`); no donor executable was run and no donor bytes
were copied into the repo. No source, shader, config, asset, fixture, test,
runner, Godot, git or user-mod state was changed. No donor parity, similarity
score, threshold or gate PASS is claimed. Network is out of scope.

*End of DEC-U-TOOL-ATTACH.*
