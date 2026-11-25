---
id: E05
ticket: "TERRAIN-SWARM-2026-11-25 / E05 — donor build-stage mesh naming → port ghost path"
owner: "E05 (read-only naming-resolution worker)"
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_CODE_EDIT__NO_GODOT_JOB
scope: "Exactly one new report (this file). Donor files read READ-ONLY; no donor copy/execute/render; no Godot/runner job; no code, asset, manifest or config edit."
donor: "C:\\Games\\Cossacks 3\\data (READ-ONLY; PowerShell numbered dumps + direct .actor/.prop reads + byte-size enumeration)"
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, "PORT APPROXIMATION", "NO_VISUAL_PARITY"]
output: "docs/terrain_swarm_2026-11-25/reports/E05_ghost_mesh_naming.md"
governing_rule: "CHARTER.md §3 (observations/inference/UNVERIFIED separated; no donor parity without A/B frame) and §1b.3 (ghost must show LAST/completed build stage, translucent, footprint-honest)."
---

# E05 — Donor build-stage mesh naming → the exact ghost path B06 should use

> [!IMPORTANT]
> **Decision for B06 (resolved, with evidence below):**
> 1. The donor's **finished building is the BASE mesh** — `engcen.osm` for the sampled
>    town hall — not `<sid>4.osm`. Stage `1..4` meshes are the four *under-construction*
>    stages; completion switches the actor back to the base mesh (`.prop DefaultMeshName`,
>    `ontagstates.inc:92-126`, `unit.script:6591-6592`).
> 2. Therefore the ghost path for a finished-structure hologram is, **in priority order**:
>    - **PRIMARY** `res://assets/models/obj/<sid>.obj` via `provider.call("_mesh_info", sid, "building")`
>      — the finished/base building mesh;
>    - **FALLBACK** `res://assets/models/obj/<sid>4.obj` via `provider.call("_stage_mesh_info", sid, "4", false)`
>      — the **last discrete construction stage**, only if the base returns no `Mesh`;
>    - **NEVER** suffix `"1"` (`<sid>1.obj`) — that is the current first-foundation defect.
> 3. This agrees with the two landed E/F reports: F02 §5.1 ("finished base first, last stage
>    `4` as fallback, never `1`") and E02 §5/§8 (both resources exist for 12 sids).
> 4. **UNVERIFIED:** the donor's own placement-ghost geometry is an engine dummy with no
>    readable colour/size/mesh config (DBUILD-01 §4.1; F02 §3.1). "Show the finished
>    structure" is the **owner's product directive** (`CHARTER.md §1b.3`), not a proven
>    donor behaviour. No visual-parity claim is made.

---

## 1. Sources (all read READ-ONLY this pass)

| # | Source | What it supplied | Label |
|---|---|---|---|
| D1 | `C:\Games\Cossacks 3\data\actors\buildings\eng\engcen.actor` (full, 28 lines) | 7 named mesh actors, each with one `LODList.Items[0].MeshObjects.LoadFromFile` `.osm` binding | OBSERVED (direct read) |
| D2 | `C:\Games\Cossacks 3\data\actors\buildings\eng\engcen*.osm` (byte-size enumeration) | Exact byte sizes of base / stages 1-4 / death 1-2 | OBSERVED (filesystem) |
| D3 | `C:\Games\Cossacks 3\data\objects\buildings\engcen.prop` (full, 122 lines) | `LODActorName=engcen`, `DefaultMeshName=engcen.mesh` (base), scaffold auto-child mesh list | OBSERVED (direct read) |
| D4 | `C:\Games\Cossacks 3\data\actors\ref\refbuilding.actor` (full, 23 lines) | `ActorList.Items[0].LODList.Items[0]` is the single mesh slot per named actor | OBSERVED (direct read) |
| D5 | `C:\Games\Cossacks 3\data\actors\actors.lib` (grep) | Buildings section registers every `<nat><bld>.actor` path; actor is the engine-side mesh container | OBSERVED |
| D6 | `C:\Games\Cossacks 3\data\scripts\lib\unit.script:6578-6605` | Live progress formula `hp/maxhp`, `floor(progress*4)`, completion at `hp>=maxhp` → essential `none` | OBSERVED (direct numbered dump; 0 `[*]` prefixes = live Pascal) |
| D7 | `C:\Games\Cossacks 3\data\scripts\units\building.inc\ontagstates.inc:240-259` | Stage→suffix `1..4`, wall fold `1+stage div 3`, `SetGameObjectActorNameByHandle(actor+'.mesh')`, scaffold `actor+'a.mesh'` | OBSERVED text (OSW `.inc` serialized form — caveat C1) |
| R1 | `docs/coord_swarm_2026-11-25/reports/DBUILD_01_building_stages.md:57-113,154-170,232-249` | 7-slot inventory, `floor(progress*4)` mapping, completion→base, ghost dummy, port parity | OBSERVED (report) / inherited donor cite |
| R2 | `docs/coord_swarm_2026-11-25/reports/DBUILD_02.md:66-85,89-99` | Independent confirmation of DBUILD-01 6 claims; correction C1 (dead-code claim) | OBSERVED (report) |
| R3 | `docs/coord_swarm_2026-11-25/decomp/DEC_04_anim_formats.md:62-80,359-379` | `.osm` = static variant / construction stage / LOD mesh; `algcen.osm` 224,412 B static building | OBSERVED (report) / inherited cite |
| R4 | `docs/coord_swarm_2026-11-25/reports/E02_final_stage_assets.md:47-55,123-159,176-181` | Port stage-family inventory, exact loader map, ghost blocker; 12 art sids vs 7 blocked | OBSERVED (report) / on-disk enumeration |
| R5 | `docs/terrain_swarm_2026-11-25/reports/F02_almanac_building_ghost.md:214-230,330-386` | Owner directive vs UNVERIFIED donor ghost; recommended base-first/4-fallback resolution | OBSERVED (report) |
| R6 | `docs/terrain_swarm_2026-11-25/reports/A12_config_knobs.md:179` | Config knob K8: `"1"` shipped vs final `"4"`; no readable donor ghost config | OBSERVED (report) |
| R7 | `docs/coord_swarm_2026-11-25/reports/BUILD_STAGES_01.md:38-66,84-93`; `BUILD_ART_C_01.md:145-162` | Port OBJ naming `<sid><s>[a].obj`, stage art present for 12 sids, base fallback otherwise | OBSERVED (report) |
| P1 | `variant3d/scripts/world3d_entities.gd:1819-1844,1851-1936` | `_stage_mesh_info()` path construction, `_sync_building_stages()` selector | OBSERVED (direct read) |
| P2 | `variant3d/scripts/world3d_fx.gd:634-678,903-907` | Current ghost resolver: suffix `"1"` first, base fallback; node `GhostBuildingStage0` | OBSERVED (direct read) |
| P3 | `variant3d/assets/models/obj/**` + `variant3d/assets/models/manifest.json` | On-disk OBJ stems `cen`, `cen1..4`, `cen1a..4a`, `cena`; manifest sids match | OBSERVED (glob + grep) |
| U1 | `http://cossacksworld.ucoz.co.uk/index/new_buildings/0-349` (charter §6 seed; direct fetch 403) | Build stages `<sid>1..4.osm`, death `<sid>_death1/2.osm`, registered in `<sid>.actor`; editor `bstage X` sets stage % | UNVERIFIED direct page (403) — corroborated by charter seed + `cossacksworld .../objects/0-226` web-search snippet ("bstage x … % (1-100)") |
| U2 | `https://raw.githubusercontent.com/anyalink99/cossacks-3-almanac/main/internals_en/scripts/building_mechanics_evidence.md` (fetched) | Construction progress `delta=0.359375/buildtime`, repair, walls, destruction sequence; **no** per-stage mesh naming | OBSERVED (web) — naming not covered |

Label convention: **OBSERVED** = literal bytes/text/file read this pass; **DERIVED** = arithmetic or control-flow consequence; **UNVERIFIED** = no readable evidence or no runtime/visual capture. No donor file was copied, executed or rendered. Visual parity is **NO_VISUAL_PARITY** throughout.

---

## 2. Donor naming convention — resolved

### 2.1 The seven mesh slots (OBSERVED: D1/D2/D3)

`engcen.actor:2-27` (direct read) binds **seven named actors**, each with exactly one mesh
via `LODList.Items[0].MeshObjects.LoadFromFile`:

| Actor name (`.mesh`) | `.osm` path | Bytes (D2) | Role | Stage index |
|---|---|---:|---|---|
| `engcen.mesh` | `engcen.osm` | 1,386,780 | **BASE = finished building** | — (completion) |
| `engcen1.mesh` | `engcen1.osm` | 535,716 | construction stage 1 | 0 |
| `engcen2.mesh` | `engcen2.osm` | 966,340 | construction stage 2 | 1 |
| `engcen3.mesh` | `engcen3.osm` | 1,256,820 | construction stage 3 | 2 |
| `engcen4.mesh` | `engcen4.osm` | 2,017,308 | **construction stage 4 = LAST build stage** | 3 |
| `engcen_death1.mesh` | `engcen_death1.osm` | 1,694,324 | destruction stage 1 | — |
| `engcen_death2.mesh` | `engcen_death2.osm` | 894,156 | destruction stage 2 | — |

Two independent readings confirm this is the canonical pattern, not a one-off:
`DBUILD_01 §2.1/§2.4` quotes identical sizes and enumerates 25 nation dirs; `DBUILD_02 §2.2`
re-measured the byte sizes **exactly** (base 1,386,780; 1: 535,716; 2: 966,340;
3: 1,256,820; 4: 2,017,308; death1: 1,694,324; death2: 894,156). **OBSERVED, twice.**

**Size caveat (DERIVED, not visual):** stage sizes grow monotonically 1→4, but stage 4
(2,017,308 B) is *larger* than the base (1,386,780 B). Byte count is **not** a claim that
stage 4 is "more finished" than the base — `.osm` are binary and no donor render exists
(DBUILD-01 §8 Q1; R3). The *role* of each mesh comes from the runtime selector, below.

### 2.2 Are base meshes already the finished building? — **YES** (OBSERVED/DERIVED)

Three independent pieces of evidence:

1. **Default actor:** `engcen.prop:8-11` — `LODActorName = engcen`,
   `DefaultMeshName = engcen.mesh`. The object's default (and completion) mesh is the
   **base**, not any digit-suffixed stage. (D3)
2. **Live progress formula:** `unit.script:6591-6592` — at `hp >= maxhp` the donor sets
   `_unit_SetTagStates(hnd, gc_statetag_essential_none or gc_statetag_visual_none)`, i.e.
   completion drops the birth/stage tags; `unit.script:6596-6603` assigns stage visual
   tags only in the **else** branch (`hp < maxhp`). (D6)
3. **Completion mesh switch:** `ontagstates.inc:92-126` (cited by DBUILD-01 §2.2 and
   verified independently by DBUILD-02 §2.1) switches the object to
   `LODActorName+'.mesh'` — the **base** — when the essential tag becomes `none`, and
   switches the scaffold child to `'detail'` material. (D7 via R1/R2)

**Conclusion:** `<sid>.osm` (base) is the **finished structure** the donor actually
displays when construction completes. `<sid>4.osm` is the last *under-construction*
mesh (progress `[0.75, 1.0)`, still `hp < maxhp`); it is **not** the completed building.
This is the distinction E05 was asked to resolve.

### 2.3 Progress → stage → mesh-name mapping (OBSERVED, two readers)

| Step | Evidence | Result |
|---|---|---|
| `buildprogress = hp/maxhp`, monotonic | `unit.script:6583-6590` (D6, live Pascal) | 0..1 counter |
| `stage = floor(buildprogress*4)` | `unit.script:6596` (D6) | 0,1,2,3 |
| visual tag `stage_0..3` | `unit.script:6598-6603` (D6) | 4 discrete stages |
| `stage_0..3 → mesh 1/2/3/4`; `actor := LODActorName+IntToStr(stage)`; `SetGameObjectActorNameByHandle(actor+'.mesh')` | `ontagstates.inc:241-251` (D7) | `<sid>1..4.mesh` |
| walls: `stage := 1+stage div 3` | `ontagstates.inc:247-248` (D7) | only `<sid>1` / `<sid>2`, no death mesh |
| scaffold child `actor+'a.mesh'`, material `scaffold` | `ontagstates.inc:253-259` (D7); `engcen.prop:72-112` (D3) | `<sid>a`, `<sid>1a..4a` |
| completion → base `<sid>.mesh` | `unit.script:6591-6592` + `ontagstates.inc:92-126` (R1/R2) | finished structure |

**Derived stage boundaries:** `[0,0.25)→1`, `[0.25,0.5)→2`, `[0.5,0.75)→3`,
`[0.75,1.0)→4`; completion (`hp>=maxhp`) → base. A `buildprogress=1` while `hp<maxhp`
edge has no `case` branch (`unit.script:6598-6603`) — derived, no runtime capture
(DBUILD-02 C2).

### 2.4 How the `.actor` LODList wires stages (OBSERVED: D1/D4/D5)

- `actors.lib:1-…` registers one `LODActorFileName` per building, e.g.
  `.\data\actors\buildings\aus\auscen.actor` (D5). The `.actor` is the engine's
  named-mesh container for that object.
- `refbuilding.actor:17-22` shows the inherited mesh slot shape:
  `ActorList.Items[0].LODList.Items[0]` (one LOD entry with binormal/tangent/weight
  texcoord indices). `engcen.actor` then creates **seven** `ActorList.Items[*]` structs,
  each overriding `LODList.Items[0].MeshObjects.LoadFromFile` with a different `.osm`
  (D1).
- **Important semantic (DERIVED):** in these building actors `LODList.Items[0]` is the
  *single geometry binding per named actor*, **not** a distance-LOD chain. The stage
  selection is performed by **swapping the actor name** at runtime
  (`SetGameObjectActorNameByHandle(actor+'.mesh')`, `ontagstates.inc:251`), not by
  walking LOD levels. The online guide's phrasing "registered in `<sid>.actor`
  (`LODList.Items[0].MeshObjects.LoadFromFile`)" (charter §6) describes exactly this
  registration mechanism.
- Online corroboration: the charter §6 seed states build stages are `<sid>1..4.osm`,
  death `<sid>_death1/2.osm`; the CossacksWorld **Objects** page confirms the editor
  command `bstage x` sets the build-stage percentage (U1 web-search snippet). The
  building_mechanics guide (U2) confirms the progress arithmetic but does not describe
  per-stage mesh filenames. **Direct fetch of the new-buildings page returned 403**, so
  the filename claim rests on the charter seed + direct local donor reads, not on a
  fetched online page.

---

## 3. Port mapping — what is actually on disk (OBSERVED: P3/R4/R7)

The converter emits Godot `res://` paths rooted at the `variant3d` project. For a
stage-family sid the 9 suffixes are:

| Donor source | Port OBJ path | Loader in `world3d_entities.gd` | Meaning |
|---|---|---|---|
| `<sid>.osm` (base) | `res://assets/models/obj/<sid>.obj` | `_mesh_info(sid,"building")` (`:1110-1160`) | **finished building** |
| `<sid>1.osm` | `res://assets/models/obj/<sid>1.obj` | `_stage_mesh_info(sid,"1",false)` | first foundation |
| `<sid>2.osm` | `res://assets/models/obj/<sid>2.obj` | `_stage_mesh_info(sid,"2",false)` | stage 2 |
| `<sid>3.osm` | `res://assets/models/obj/<sid>3.obj` | `_stage_mesh_info(sid,"3",false)` | stage 3 |
| `<sid>4.osm` | `res://assets/models/obj/<sid>4.obj` | `_stage_mesh_info(sid,"4",false)` | **last construction stage** |
| `<sid>a`/`1a..4a` scaffold | `res://assets/models/obj/<sid>[1-4]a.obj` | `_stage_mesh_info(sid,suffix,true)` | scaffold auto-child |
| `<sid>_death1/2.osm` | **none** | — | not converted anywhere |

Path construction is literal: `world3d_entities.gd:1825-1826`
`art_sid := sid + suffix + ("a" if scaffold else "")`,
`path := OBJ_DIR + sid + suffix + ("a.obj" if scaffold else ".obj")`, with
`OBJ_DIR = "res://assets/models/obj/"` (E02 §4.1; P1). Verified on disk: `cen.obj`,
`cen1.obj … cen4.obj`, `cen1a.obj … cen4a.obj`, `cena.obj`, and manifest sids `cen`,
`cen1`, `cen4`, `cen4a` (P3).

**Availability (E02 §3, observed):** 12 of 19 buildable sids have the full family —
`cen, hou, bar, sta, bla, aca, art, dip, sto, mil, mar, tow`. Seven are blocked:
`wal`, `gat`, `mine_gold/iron/coal` (base OBJ only, no stage art), and `bar18`, `dock`
(no OBJ at all → `_mesh_info` bbox proxy). No death meshes exist.

### 3.1 The current ghost is the exact inversion of the requirement (OBSERVED: P2/R4/R5)

`world3d_fx.gd:645` calls `_stage_mesh_info(sid, "1", false)` — the **first foundation** —
with `provider.call("_mesh_info", sid, "building")` only as a fallback (`:652-657`);
the node is named `GhostBuildingStage0` (`:904`). F02 §4.2 notes the 2D port already does
it correctly (`world.gd:3517` uses `finished:true`). E02 §6 and F02 §5.1 independently
recommend base-first / stage-4-fallback / never stage-1. R6 K8 records the shipped `1`
vs final `4` distinction. No code was changed by this ticket.

---

## 4. Resolved decision table for B06

| Question | Resolved answer | Evidence | Label |
|---|---|---|---|
| Which `.osm` is stage 1? | `<sid>1.osm` (smallest stage; progress `[0,0.25)`) | D1/D2/D6/D7; R1 §2.2 | OBSERVED + DERIVED |
| Which is stage 4? | `<sid>4.osm` (last construction stage; progress `[0.75,1.0)`, still unfinished) | D1/D2; `unit.script:6596-6603`; R1 §2.2 | OBSERVED + DERIVED |
| Which is the base/finished mesh? | `<sid>.osm` — default actor, selected at completion | D3 `:9-10`; D6 `:6591-6592`; R1/R2 `:92-126` | OBSERVED + DERIVED |
| Are base meshes already the finished building? | **YES** — base is what the donor shows when `bbuilt` is true; stage 4 is not | same as above | OBSERVED + DERIVED |
| How does `.actor` LODList wire stages? | 7 named actors, each with one `LODList.Items[0]` mesh file; runtime swaps actor name by suffix, LODList[0] is not a distance ladder | D1/D4/D5/D7 | OBSERVED + DERIVED |
| Port OBJ names? | `<sid>.obj` (finished), `<sid>1..4.obj` (stages), `<sid>[1-4]a.obj` (scaffold); no death OBJ | P3/R4/R7 | OBSERVED |
| **Exact ghost path B06 should use** | **PRIMARY** `res://assets/models/obj/<sid>.obj` via `_mesh_info(sid,"building")`; **FALLBACK** `res://assets/models/obj/<sid>4.obj` via `_stage_mesh_info(sid,"4",false)`; **never** `"1"` | §2.2 + R4 §5 + R5 §5.1 | RESOLVED (owner directive) |
| What about `wal`/`gat`/mines/`bar18`/`dock`? | No stage art → base OBJ is the only honest result; `bar18`/`dock` have no base OBJ → documented PORT APPROX proxy; do not fabricate stage files | R4 §3/B2, §5 | OBSERVED |
| Footprint honesty | Keep the ground box from `Data.BUILDINGS[sid].radius` and the same radius in `can_place()`; do **not** derive footprint from the finished mesh silhouette (donor collision mask ≠ `CustomBoundingAABB`) | R5 §4.3/§5.5; D3 `:45-70` | OBSERVED / PORT APPROX |

**Why base over stage 4 as primary:** the owner's wording "LAST (completed) build stage"
is ambiguous — it can mean the last *construction* mesh (`<sid>4.obj`) or the completed
structure (`<sid>.obj`). The donor runtime settles it: completion selects the base mesh.
A ghost of the **finished** structure must therefore use the base first. Stage 4 is the
correct *fallback* and is strictly better than stage 1, but it is still a `finished=false`
mesh. This resolves the ambiguity E02 §6 and F02 §5 left open ("choose one policy
explicitly") in favour of the base.

---

## 5. Still UNVERIFIED / caveats (do not promote)

1. **Donor ghost appearance** — engine dummy + canbuild/cannotbuild blink; colour, size
   and exact mesh are UNVERIFIED (DBUILD-01 §4.1; F02 §3.1). "Finished hologram" is an
   owner product decision (`CHARTER.md §1b.3`), **not** a verified donor behaviour.
2. **`.osm` visual content** — binary; stage progression and "stage 4 looks nearly
   finished" are derived from byte sizes and filenames, never rendered. No donor GPU A/B
   exists (CHARTER §3; DBUILD-01 §8 Q1). No visual parity claimed.
3. **Stage 4 vs base bbox/extent** — each stage has its own manifest bbox; the ghost must
   use the resolved art's bbox (or base fallback) via the existing bake path, not a
   hand-supplied scale. Per-stage silhouette correctness UNVERIFIED.
4. **Direct-fetch of `new_buildings` guide** — HTTP 403; filename convention rests on
   the charter §6 seed plus direct local donor reads and the `bstage x` Objects page
   snippet. Almanac building_mechanics (U2) does not enumerate mesh names.
5. **OSW `.inc` serialization caveat (C1):** `ontagstates.inc:240-259` and other building
   `.inc` files store code with a `[*] = ;` prefix (466/472 lines in `ontagstates.inc`;
   also 490/497 in known-live `nothing.inc`, 55/61 in `settagstates.inc`). DBUILD-02
   correction C1 called `doprogressorders.inc` "dead code" on account of that prefix;
   since the same prefix appears in the live smoke path, that "dead code" inference is
   **UNVERIFIED** and should not be relied on. The load-bearing progress formula comes
   from live `unit.script` (0 prefixed lines), and the mesh-name mapping comes from the
   `.actor`/`.prop` files — both unaffected by this caveat.
6. **`wal`/`gat` donor mapping** — gate stage `.osm` exist but are unreferenced; wall
   attach meshes are 660-byte placeholders (E02 B5). Do not convert from guesswork.
7. **Completion scaffold `<sid>a`** — 10 of 12 base scaffolds are 8-vert IDP2 minimal
   meshes; their visual role is UNVERIFIED and they are not part of the ghost decision.
8. **No runtime evidence** — no Godot job was run for this ticket; all port code
   statements are structural reads only.

---

## 6. Summary

- Donor convention (engcen example, OBSERVED): base `engcen.osm` = finished building;
  `engcen1/2/3/4.osm` = construction stages 1-4 (stage 4 = last build stage);
  `engcen_death1/2.osm` = ruins. Seven named actors in `engcen.actor`, each bound through
  `LODList.Items[0].MeshObjects.LoadFromFile`; stage selection swaps the actor name by
  suffix, it is not a distance-LOD ladder.
- **Base meshes are already the finished building** — confirmed by `DefaultMeshName`,
  the live `hp>=maxhp` completion branch, and the completion actor switch.
- Port files (OBSERVED): `res://assets/models/obj/<sid>.obj` = finished,
  `<sid>1..4.obj` = stages, `<sid>[1-4]a.obj` = scaffolding; 12 art-bearing sids,
  7 blocked, no death OBJs.
- **B06's ghost path (RESOLVED):** `res://assets/models/obj/<sid>.obj` first (finished
  base, `_mesh_info(sid,"building")`), `res://assets/models/obj/<sid>4.obj`
  (`_stage_mesh_info(sid,"4",false)`) as fallback, never `<sid>1.obj`; keep the
  footprint box and green/red validity untouched.
- **UNVERIFIED:** donor ghost appearance, `.osm` visual content, stage-vs-base silhouette,
  direct online guide fetch, OSW `.inc` caveat, blocked-sid approximations. No visual or
  donor parity claim.

*End of E05 report. Read-only donor recon; no code edits, no donor copies, no Godot jobs.
Every donor fact cites a path:line or a filesystem enumeration; uncertainties are labelled.*
