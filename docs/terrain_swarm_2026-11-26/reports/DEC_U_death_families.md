---
id: DEC-U-DEATH-FAMILIES
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: "WORKER DEC-U-DEATH-FAMILIES — donor 1:1 death/stage/attach inventory for the 11 unconverted building families"
owner_file: docs/terrain_swarm_2026-11-26/reports/DEC_U_death_families.md
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_ASSET_CONFIG_GODOT_GIT_EDIT
created: 2026-11-26
labels: [O, D, I, U, NO_PARITY_CLAIM, NO_APPROXIMATION, NO_SYNTHESIS]
parity_guard: "NO DONOR PARITY IS CLAIMED. No same-camera donor/port A/B frame was produced or examined. Every donor statement is a read-only file/line/byte observation; every port statement is a read-only source line. 'Required conversion' names work to be done, not work done."
scope_guard: "Exactly one repo file written (this report). No source, shader, config, asset, fixture, test, runner, Godot, git or user-mod edit. Donor binary and donor data tree read READ-ONLY; no donor executable run, no donor bytes copied into the repo. Singleplayer skirmish only."
donor_pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe (PE x86, 5,768,048 B, sha256 87f0f3c130b0...; carried [O] from docs/coord_swarm_2026-11-25/reports/DEC_01_binaries_rtti.md:60). Data tree C:\\Games\\Cossacks 3\\data read READ-ONLY. Pin cited; binary not executed here; this worker ran file/tree passes only (no binary-decomp calls), so evidence below is cited donor path:line/byte, verified by a second read pass where noted."
port_scope: "variant3d/scripts/world3d_entities.gd (BLD_DEATH_STEMS, _donor_death_suffix, _death_mesh_info) + variant3d/assets/models/buildings/manifest.json (IMPL-BUILDING-DEATH lane) + variant3d/assets/models/manifest.json (12 base sids) + variant3d/tools/convert_models.py (stage_models table) — all read-only line citations"
prior_reports_read:
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_aaf_art_audit.md (§2 mill/death art census, P4/P6 passes)
  - docs/terrain_swarm_2026-11-26/reports/F07_mill_fields.md (eurmil 8-mesh actor table E10-E13, death-missing rows)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_entities_art_collision.md (death anchors, ghost/rally/death)
  - docs/terrain_swarm_2026-11-26/reports/AUDIT_BUILDING_NATIONS.md (generic-sid probe, eur* alias gap)
  - variant3d/assets/models/buildings/manifest.json (IMPL-BUILDING-DEATH resolved + unresolved [U]-OTHER)
---

# DEC-U — donor death-family inventory for the 11 unconverted building families (1:1 donor port)

> READ-ONLY. Singleplayer skirmish only. No parity claim. No approximation endorsed.
> Each `[U]` ends in either a static verdict with cited bytes/lines, or a named GPU/runtime capture. Nothing is closed by a port fallback. Nothing is synthesised. No eurmil art is copied onto other sids.

## 0. Context and verdict up front

1. **[O]** `IMPL-BUILDING-DEATH` converted exactly the `eurmil` family: 6 derived OBJs (`eurmil`, `eurmil_death1/2`, `eurmila`, `eurmil_death1a/2a`) + `eurmil/scaffold/debris` PNGs in `P:assets/models/buildings/` with provenance in `P:assets/models/buildings/manifest.json:24-237`, which explicitly lists `"[U]-OTHER death art for the other 11 mapped building families was NOT converted in this additive lane (scope: eurmil only)"` (`:238-243`).
2. **[O]** `P:scripts/world3d_entities.gd:325` reads `const BLD_DEATH_STEMS: Dictionary = {"mil": "eurmil"}` — one stem only — so `_death_mesh_info` (`:3046-3081`, `art_sid := stem + suffix`) resolves death art for `mil` alone; every other sid returns `{}` (explicit gap, `:3047-3049`) per the code comment at `:2899-2902`.
3. **[O, this worker]** Donor death art is PRESENT for all 11 remaining mapped families. Every family ships the same 4-file death set the eurmil lane converted: `<base>_death1.osm`, `<base>_death2.osm`, `attach/<base>_death1a.osm`, `attach/<base>_death2a.osm`, bound by the same 7-slot `.actor` / 7-slot attach `.actor` / `Mesh[5..6]`+`debris` `.prop` pattern, driven by ONE shared death-state selector (`ontagstates.inc:264-311` + `settagstates.inc:32-53` + `deathstage1/2.inc`). Nothing is absent or nameless; there is no `[U]` on donor paths. The only donor-side anomalies are degenerate-but-present meshes (§4).
4. **[D]** Conversion scope for full 1:1 coverage: 44 new derived OBJs (11 families × 4) + 11 albedo PNGs (all already exist in the port tex tree) + shared `debris`/`scaffold` PNGs (already exist) + manifest rows + one `BLD_DEATH_STEMS` line. File/line change list in §5; no edit performed here.

## 1. Method, labels, passes

- **[O]** = observed donor file line / directory entry / byte count / port line. **[D]** = arithmetic over cited [O]. **[I]** = reading without runtime proof. **[U]** = unresolved after the passes here.
- Path shorthands: `D:` = `C:\Games\Cossacks 3\data\` (read-only). `P:` = workspace `variant3d\`.
- `ev_` ids: this worker ran no binary-decomp calls, so there are no new Craft Anything binary evidence ids; the evidence is the cited donor `path:line`/byte itself, each verified by a second read pass where the ledger says so.

### 1.1 Pass ledger (multiple passes; strange-read log inline)

| Pass | Operation (read-only) | Result |
|---|---|---|
| P1 | `Get-ChildItem` `D:actors/buildings/ukr` + `ukr/attach` + `commoneur` + `commoneur/attach` with `-Filter *death*` | ukr parents 20 files (10 bases × 2), ukr attach 20, commoneur parents 24 (12 bases × 2), commoneur attach 24 [O] (§3). Second listing pass confirmed counts. |
| P2 | Full `Get-Content` reads: `D:actors/buildings/ukr/ukrcen.actor`, `.../commoneur/eursto.actor`, `.../ukr/attach/ukrcena.actor`, `.../commoneur/attach/eurmila.actor` | All four are 7-slot actors: base + `1..4` + `_death1` + `_death2` (parents), `a` + `1a..4a` + `_death1a` + `_death2a` (attach) [O] (§3). |
| P3 | `Select-String _death` line-number pass over the other 8 ukr family actors + `eurmar/eurtow` actors + `ukrcena/eurstoa` attach actors | Identical slot lines in every family: parents `:21-22` (`_death1`) / `:25-26` (`_death2`); attach `:23-24` (`_death1a`) / `:27-28` (`_death2a`) [O] (§3). |
| P4 | Per-prop grep pass over all 12 `D:objects/buildings/<base>.prop`: `Mesh[5]/Mesh[6]`, `Materials[5]/Materials[6]`, `DefaultScale`, `DefaultRollAngle`, `Mesh[0].DefaultMaterialName` | All 12 carry `Mesh[5]=<base>_death1a`, `Mesh[6]=<base>_death2a`, `Materials[5..6]=debris`, single-material parents; scales/rolls tabulated [O] (§3). Second pass on `ukrcen.prop:74-124` confirmed the full child-table block shape. |
| P5 | Full read `D:scripts/units/building.inc/ontagstates.inc:201-472` + full reads `settagstates.inc` (61 lines), `deathstage1.inc`, `deathstage2.inc` + `dmscript.global:183-184` | Shared death selector recovered: tag chain DeathStage1→DeathStage2, `_death<stage>` actor swap, child0 `...a`+`debris`, misc-child clear, `_unit_DoExplosion` call site `:309-311`, `gc_building_deathtime_0/1 = 30` [O] (§2). |
| P6 | Byte-size pass over all 48 death OSMs (`Get-Item .Length`) + first-64-byte hex read of `eursto_death1a` / `eurtow_death2a` / `eurmil_death1a` | All present; sizes §3 table. `eursto/eurtow _deathNa` are 660 B degenerate IDP2 stubs with identical headers [O] (§4). First attempt hit a PowerShell backtick-`` `a `` bell-escape quoting fault on the worker side (tooling, not donor); re-ran with string concatenation — sizes verified on the clean pass. |
| P7 | Port anchor reads: `world3d_entities.gd:320-328` (status consts), `:325` (stems), `:2881-2909` (stage/suffix), `:3041-3081` (`_death_mesh_info`), `P:assets/models/buildings/manifest.json` full, `P:assets/models/manifest.json` 12 sid rows `:1863-2138`, `convert_models.py:366-379` (12-family stage table) | Port converts/resolves `mil→eurmil` only; 12 base sids shipped; albedo PNGs present for all 12 (§5). |
| P8 | Cross-check vs `buildings/manifest.json:238-243` unresolved list + F07 E10-E13 + `BUILDING_DEATH_STATUS` (`world3d_entities.gd:320`) | Agreement: eurmil-only scope, `[U]-OTHER` open, `[U]-BURN`/`[U]-EX` carried, no contradiction found [D]. |

**Strange-read log:** (a) the `Select-Object Name` blank-column listing quirk noted in DEC_U_aaf_art_audit P8 was avoided by using `-ExpandProperty Name` throughout; (b) the P6 quoting fault (worker-side only, donor bytes untouched); (c) two donor content anomalies — 660 B `eursto/eurtow` death-attach stubs and byte-identical `ukrhou/ukrbla` attach sizes — recorded in §4, not resolved by invention. No branch polarity was guessed; no binary bytes were interpreted.

## 2. The shared donor death/stage/attach rule (all 12 families, one selector)

All families are driven by the same building script directory `D:scripts/units/building.inc/`; nothing below is family-specific.

### 2.1 Death entry: visual stage → delayed stage chain [O]

`settagstates.inc:32-53` (full file, 61 lines, read twice):

- Death while `iOldEssential=birth` → force visual `stage_1`, schedule `DeathStage2` after `gc_building_deathtime_1` (`:34-39`).
- Otherwise → cancel pending delayed state, schedule `DeathStage1` after `deathtime = gc_building_deathtime_0` (×2 when `_unit_GetUsage = gc_obj_usage_mine`, `:46-48`), force visual `stage_0` (`:44-51`).
- `dmscript.global:183-184`: `gc_building_deathtime_0 = 30; gc_building_deathtime_1 = 30;` — same 30/30 pair the port's `data.gd:108-109` carries as `DEC_U_BUILDING_DEATHTIME_FRAMES` with the explicit NOT-endorsed-as-TTL guard.

`deathstage1.inc` (full, 12 lines): sets `essential_death or visual_stage_1`, schedules `DeathStage2` after `gc_building_deathtime_1` (×2 for mines). `deathstage2.inc` (full, 20 lines): clears terrain collision for non-walls, `GameObjectRequestToDestroyByHandle`. Net visual sequence: ruin `_death1` (visual `stage_0`) for `deathtime_0`, then ruin `_death2` (visual `stage_1`) for `deathtime_1`, then destroy.

### 2.2 Death swap: actor, child, materials, explosion [O]

`ontagstates.inc:264-311` (`gc_statetag_essential_death` branch; `[*] = ;` intent lines, read in full at `:201-472`):

- `:265-266` first death entry fires `OnDeath` once (production/upgrade flush per `ondeath.inc`).
- `:267-275` non-walls only: `case iVisual of stage_0 → stage := 1; stage_1 → stage := 2`, then `actor := <LODActorName> + '_death' + stage` and `SetGameObjectActorNameByHandle(myHnd, actor + '.mesh')`. **There is no `stage_2/3` arm** — stages 2/3 at death select no mesh on this line path ([U]-14, carried from `buildings/manifest.json:241`; no mesh invented here).
- `:277-279` destroy the progress-children behaviour; `:281-304` when children exist and not a gate: child0 ← `actor + 'a.mesh'` + visible + material **`debris`** (`:284-286`); every `gc_racetag_misc` child gets `BehaviourClear + EffectClear + RequestToDestroy` (`:289-298`); children `1..n-1` hidden (`:299-303`).
- `:309-311` the stated transition fires `_unit_DoExplosion(myHnd)` when entering death from none/birth-at-stage-2-or-3 ([U]-EX carried: call site recovered, no effect key in readable lines).
- `:313-335` wall-only tail (hide, unplayable, delayed destroy) — walls/gates (`wal`/`gat`) are outside the 12 mapped families and out of scope.

### 2.3 Birth-stage rule (construction, for completeness) [O]

`ontagstates.inc:240-259`: `birth` maps visual `stage_0..3 → 1..4` (`:242-245`), walls fold `stage := 1 + stage div 3` (`:247-248`), parent actor `<base><stage>.mesh` (`:250-251`), child0 `<base><stage>a.mesh` + `scaffold` (`:253-259`). This is the rule `convert_models.py:stage_models` (`:331-411`) already converts for all 12 families; death reuses the same child slot with `debris` instead of `scaffold`.

**[I] port-note (no edit):** the port's `_donor_raw_stage` (`world3d_entities.gd:2886-2896`) derives `stage = floor(hp/max_hp*4)` as a proxy for the donor `iVisual` tag the selector actually switches on (`:2881-2885` cites `unit.script:6583-6596` + `:240-259`). Whether hp-fraction equals the tag value at death is runtime-verification territory ([U] for the owner lane; out of scope for this inventory).

## 3. Per-family donor death art (all [O]; nothing absent, nothing nameless)

Uniform layout in every family (verified per-file in P2/P3):

- Parent actor `D:actors/buildings/<dir>/<base>.actor`: 7 slots; `_death1` Name/LoadFromFile at `:21-22`, `_death2` at `:25-26`.
- Attach actor `D:actors/buildings/<dir>/attach/<base>a.actor`: 7 slots; `_death1a` at `:23-24`, `_death2a` at `:27-28`.
- Child table `D:objects/buildings/<base>.prop` `autochildrenproperty` (≈`:74-114`, `ukrcen.prop:74-114` read in full): `Mesh[0]=<base>a`, `Mesh[1..4]=<base>1a..4a`, `Mesh[5]=<base>_death1a`, `Mesh[6]=<base>_death2a`; `Materials[0..4]=scaffold`, `Materials[5..6]=debris`; `Option = achildRequered`.
- Port sid mapping follows `convert_models.py:366-379` (the 12 non-wall rows). EUR aliases (`eursto/eurmar/eurtow`, AUDIT_BUILDING_NATIONS §5) resolve to the same donor bases; the port stores generic sids (`sto/mil/mar/tow`, manifest `:2038-2138`), so no separate alias conversion is needed — one stem per port sid.

| Port sid | Donor base (dir) | Parent `.actor` death slots | Attach `.actor` death slots | `.prop` child `Mesh[5/6]` + `Materials[5/6]` | Scale / Roll [O] | Death OSM bytes parent / attach [O] | Port status |
|---|---|---|---|---|---|---|---|
| `cen` | `ukrcen` (`ukr/`) | `ukrcen.actor:21-22` `_death1`, `:25-26` `_death2` | `attach/ukrcena.actor:23-24` `_death1a`, `:27-28` `_death2a` | `ukrcen.prop:97-98,106-107` `ukrcen_death1a/2a` + `debris`×2 | 0.424 / 135 (`:117-123`) | 46,588 / 38,836 · attach 35,156 / 43,028 | **[U]-OTHER — not converted** |
| `hou` | `ukrhou` (`ukr/`) | `ukrhou.actor:21-22` / `:25-26` | `attach/ukrhoua.actor` (same slot lines per P3 pattern) | `ukrhou.prop:91-92,100-101` + `debris`×2 | 0.316 / 135 (`:111-117`) | 150,676 / 129,708 · attach 8,020 / 10,132 | **[U]-OTHER — not converted** |
| `bar` | `ukrbar` (`ukr/`) | `ukrbar.actor:21-22` / `:25-26` | `attach/ukrbara.actor` (same) | `ukrbar.prop` `ukrbar_death1a/2a` + `debris`×2 (P4) | 0.424 / 45 | 53,124 / 51,516 · attach 24,196 / 32,548 | **[U]-OTHER — not converted** |
| `sta` | `ukrsta` (`ukr/`) | `ukrsta.actor:21-22` / `:25-26` | `attach/ukrstaa.actor` (same) | `ukrsta.prop` `ukrsta_death1a/2a` + `debris`×2 (P4) | 0.4142 / 45 | 35,372 / 47,428 · attach 26,596 / 39,652 | **[U]-OTHER — not converted** |
| `bla` | `ukrbla` (`ukr/`) | `ukrbla.actor:21-22` / `:25-26` | `attach/ukrblaa.actor` (same) | `ukrbla.prop` `ukrbla_death1a/2a` + `debris`×2 (P4) | 0.735 / 135 | 395,436 / 293,588 · attach 8,020 / 10,132 (≡ hou, §4) | **[U]-OTHER — not converted** |
| `aca` | `ukraca` (`ukr/`) | `ukraca.actor:21-22` / `:25-26` | `attach/ukracaa.actor` (same) | `ukraca.prop` `ukraca_death1a/2a` + `debris`×2 (P4) | 0.41 / 45 | 242,140 / 128,636 · attach 103,428 / 134,820 | **[U]-OTHER — not converted** |
| `art` | `ukrart` (`ukr/`) | `ukrart.actor:21-22` / `:25-26` | `attach/ukrarta.actor` (same) | `ukrart.prop` `ukrart_death1a/2a` + `debris`×2 (P4) | 0.395 / 315 | 275,148 / 124,156 · attach 35,140 / 41,132 | **[U]-OTHER — not converted** |
| `dip` | `ukrdip` (`ukr/`) | `ukrdip.actor:21-22` / `:25-26` | `attach/ukrdipa.actor` (same) | `ukrdip.prop` `ukrdip_death1a/2a` + `debris`×2 (P4) | 0.48 / 315 | 223,084 / 96,868 · attach 61,236 / 88,132 | **[U]-OTHER — not converted** |
| `sto` | `eursto` (`commoneur/`), alias `eursto` | `eursto.actor:21-22` `_death1` (full read P2), `:25-26` `_death2` | `attach/eurstoa.actor:23-24` `_death1a`, `:27-28` `_death2a` | `eursto.prop` `eursto_death1a/2a` + `debris`×2 (P4) | 0.665 / 45 | 55,556 / 47,668 · attach **660 / 660 stubs** (§4) | **[U]-OTHER — not converted** |
| `mil` | `eurmil` (`commoneur/`) | `eurmil.actor:20-27` (F07 E11; manifest `:9`) | `attach/eurmila.actor:2-28` (full read P2; manifest `:10`) | `eurmil.prop:87-88,96-97` + `debris`×2 | 0.43 / 45 (`:107-113`) | 174,580 / 136,748 · attach 20,620 / 29,380 | **[O] CONVERTED** (`buildings/manifest.json:52-186`) |
| `mar` | `eurmar` (`commoneur/`), alias `eurmar` | `eurmar.actor:21-22` / `:25-26` | `attach/eurmara.actor` (same slot lines per P3 pattern) | `eurmar.prop` `eurmar_death1a/2a` + `debris`×2 (P4) | 0.463 / 135 | 248,540 / 162,828 · attach 24,436 / 69,252 | **[U]-OTHER — not converted** |
| `tow` | `eurtow` (`commoneur/`), alias `eurtow` | `eurtow.actor:21-22` / `:25-26` | `attach/eurtowa.actor` (same) | `eurtow.prop` `eurtow_death1a/2a` + `debris`×2 (P4) | 0.54 / 45 | 128,716 / 89,236 · attach **660 / 660 stubs** (§4) | **[U]-OTHER — not converted** |

Scale/roll line citations: `ukrhou.prop:111-117`, `eurmil.prop:107-113` read with line numbers (P4/P6); remaining six ukr + `eursto/eurmar/eurtow` values grepped with matching `DefaultScale/DefaultRollAngle` context lines (P4 table). All 12 parent materials are the single family albedo (`Mesh[0].DefaultMaterialName = <base>`, e.g. `ukrhou`, `eurmil`).

Stage rule (identical for every row): death entry visual `stage_0` → `<base>_death1.mesh` + child0 `<base>_death1a.mesh` + `debris`; visual `stage_1` → `<base>_death2.mesh` + child0 `<base>_death2a.mesh` + `debris` (`ontagstates.inc:267-286`); `DeathStage1` advances `stage_0 → stage_1` after `deathtime_0` (×2 mines), `DeathStage2` destroys after `deathtime_1` (×2 mines). No visual `[U]`: mesh selection is fully determined by readable lines; only burn duration/smoke stop ([U]-BURN) and the explosion payload ([U]-EX) stay open, both carried, neither family-specific.

## 4. Donor anomalies (observed, not papered over)

1. **[O] `eursto`/`eurtow` death-attach stubs.** `eursto_death1a/2a.osm` and `eurtow_death1a/2a.osm` are each exactly **660 B**; first-64-byte hex of `eursto_death1a` and `eurtow_death2a` is byte-identical (`49-44-50-32-08-…-94-02-00-00`, IDP2 v8 header + near-empty frame table) while `eurmil_death1a` (20,620 B) diverges after the shared 16-byte prefix. **[I]** They look like degenerate/empty debris-child meshes, yet the donor still binds them at `Mesh[5..6]` with `debris` and the selector still swaps them in (`ontagstates.inc:284-286` has no size guard). **[U]-STUB:** whether the donor renderer shows, skips, or culls a 660 B mesh is a GPU/runtime capture; the port conversion must convert the stubs as-is (whatever `read_osm` decodes to — possibly zero faces) and must NOT substitute eurmil or scaffold art. Precise capture: kill a `sto`/`tow` building on camera, screenshot the `_death1→_death2` window, compare against the converted stub OBJ face count.
2. **[O] `ukrhou ≡ ukrbla` attach sizes.** `ukrhou_death1a`/`ukrbla_death1a` = 8,020 B each, `_death2a` = 10,132 B each. Shared geometry or coincidence is unverified — recorded only; each family still converts from its own donor path, never by copying hou→bla.
3. **[O] Port `_death_mesh_info` AABB guard (`world3d_entities.gd:3067-3072`).** A zero-depth derived AABB is replaced by a `1×1×1` box. If the sto/tow stubs decode to zero faces, `_death_obj_mesh` (`:2971-3013`) returns null first (`vv.is_empty() or tris.is_empty__`), so the guard never fires and the sid stays an explicit `{}` gap — verify at conversion time that a stub converts to an honest gap rather than a unit cube labelled as debris.

## 5. Port change list (file/line; NOT applied — no edit performed here)

Owner lane: IMPL-BUILDING-DEATH (assets) + world3d_entities.gd owner (code). All lines re-read 2026-11-26; re-anchor before applying (concurrent-owner caveat per IMPL_U_aaf_triggers §5 convention).

1. **`P:scripts/world3d_entities.gd:325`** — extend `BLD_DEATH_STEMS` with the 11 donor-grounded stems (port sid → donor base; aliases need no rows since sids are generic):
   `{"mil":"eurmil","cen":"ukrcen","hou":"ukrhou","bar":"ukrbar","sta":"ukrsta","bla":"ukrbla","aca":"ukraca","art":"ukrart","dip":"ukrdip","sto":"eursto","mar":"eurmar","tow":"eurtow"}`. No other code change: `_donor_death_suffix` (`:2903-2909`) and `_death_mesh_info` (`:3046-3081`, `art_sid := stem + suffix + ("a" if scaffold)`, `path := BLD_DEATH_DIR + "models/" + art_sid + ".obj"`) are already stem-driven; `_fire_donor_death_fx` (`:3089-3100`) is family-agnostic. Also update the `eurmil`-only comments at `:87-88`, `:341-343`, `:3041-3043` when stems land.
2. **`P:assets/models/buildings/manifest.json`** — append 44 mesh rows (`<stem>_death1/2`, `<stem>_death1a/2a` for the 11 stems; donor `donor_bytes` from §3 table; `donor_sha256`/verts/bbox via the approved `convert_models.py:read_osm` path) + 11 texture rows reusing existing albedo PNGs (`P:assets/models/tex/ukr/buildings/{cen,hou,bar,sta,bla,aca,art,dip}.png`, `P:assets/models/tex/shared/buildings/{sto,mil,mar,tow}.png` — all observed present) with `mtl_material=<base-albedo>` for parents and the existing `../tex/debris.png` for all 22 `*a` meshes (donor `Materials[5..6]=debris`, §3). `scaffold.png`/`debris.png` already exist (`tex/`); `eurmil.png` precedent at manifest `:188-204`. Move `[U]-OTHER` (`:242`) to resolved-per-family.
3. **`P:assets/models/manifest.json`** — no death rows needed (death art lives in the `buildings/` lane manifest per `BLD_DEATH_MANIFEST`, `:322`); base-sid rows `:1863-2138` already cover all 12 families. Only action: none, recorded so no lane adds `_death` sids here by mistake.
4. **`P:tools/convert_models.py`** — the 12-family table at `:366-379` already maps every needed `(actor folder, actor base, texture folder, texture base)`; a death-table function mirroring `stage_models` (`:330-411`) needs exactly: parents `<base>_death{1,2}.osm` + `<base>` albedo DDS, attach `<base>_death{1,2}a.osm` + existing `constructor/debris.dds` (`materials/buildings/constructor/debris.dds`, cf. manifest `:221-236`), pointed at `P:assets/models/buildings/` outputs. `wal`/`gat` stay excluded per `:357-358`.
5. **Captures required before any visual claim (all [U], none blocking conversion):** R-STUB sto/tow stub rendering (§4.1); R-BURN burn duration/smoke stop ([U]-BURN, `world3d_entities.gd:328`); R-EX explosion payload ([U]-EX, `:327`); R-STAGE stage_2/3-at-death mesh selection ([U]-14, manifest `:241`) — donor `case` covers only stage_0/1 (`ontagstates.inc:269-272`).

## 6. No-parity / no-synthesis statement

No donor/port A/B frame was produced or examined. All 48 donor death OSMs are present and named; where donor art is degenerate (sto/tow 660 B stubs) the report keeps `[U]-STUB` with a precise capture instead of substituting geometry. No eurmil mesh, material, or bbox is reused for any other sid anywhere in this inventory. The 11 `[U]-OTHER` rows above name donor bytes + conversion targets only — closing them requires the owner lane's conversion + the §5 captures, not this report.
