---
id: F02
ticket: TERRAIN-SWARM-2026-11-25 / Wave F — ONLINE DONOR RESEARCH
title: "Donor building stages and placement ghost: what the hologram shows, and why our 3D ghost is stage 1"
owner: F02 (read-only research subagent)
created: 2026-11-25
status: COMPLETE
mode: READ-ONLY AUDIT — no code edits, no Godot jobs, one report only
labels: [observed, derived, inferred, UNVERIFIED]
---

# F02 — Almanac / building-stage / ghost-preview research

## 0. Scope and method

Charter read in full (`docs/terrain_swarm_2026-11-25/CHARTER.md`), including
§1b.3 (owner requirement: **ghost = LAST / completed stage, not first foundation**)
and §3 guardrails (separate OBSERVED / INFERRED / UNVERIFIED; no donor parity claim
without a donor A/B frame).

Sources required by the dispatch were fetched online:

| # | Source | Direct `webfetch` | Content actually obtained |
|---|---|---|---|
| S1 | `https://github.com/anyalink99/cossacks-3-almanac/blob/main/internals_en/scripts/building_mechanics_evidence.md` | OK (GitHub HTML) + `raw.githubusercontent.com` full text | Full 701-line doc, quoted below |
| S2 | EN reader page `.../docs_en/recon/world/economy/building_mechanics.md` | OK (GitHub HTML) + raw | Full 226-line doc |
| S3 | `http://cossacksworld.ucoz.co.uk/index/new_buildings/0-349` | **403** on direct GET | Full article text recovered from the search-engine index (websearch), incl. step 24.2 actor block; corroborated by two sibling ucoz pages (`/index/objects/0-226`, `/forum/28-52-1`, `/forum/26-666-1`, `/index/patch_notes_2017/0-336`) |
| S4 | `https://gamemechanicshoard.com/mechanic/ghost-preview` | 403 / transport error (both `https://` and `http://`) | Definition recovered verbatim from the search-engine index (websearch), incl. the "lying ghost" pitfall paragraph |

**Reliability note.** S1/S2/S1-animation are first-hand raw-file fetches (strongest).
S3/S4 are **indexed snapshots of the requested pages**, not live reads: the quotes
are verbatim as indexed, but page revision date/current live state is UNVERIFIED.
Where a conclusion rests only on S3/S4 it is labelled accordingly. No donor GPU A/B
frame exists, so **no donor visual-parity claim is made anywhere in this report**.

---

## 1. OBSERVED — donor build-stage asset model (S3)

The modding guide registers one *base/finished* mesh plus four numbered build-stage
meshes and two death meshes in the building's `.actor`:

> "24.1 Grab following files you downloaded and renamed: `miscas1.osm`,
> `miscas2.osm`, `miscas3.osm`, `miscas4.osm`, `miscas_death1.osm`,
> `miscas_death2.osm` Put all these in `Cossacks 3\data\actors\buildings\mis\`"
>
> "24.2 Go to `Cossacks 3\data\actors\buildings\mis\miscas.actor` We'll add the
> buildstages and deathstage files here, adjust so it looks like this:
> `ActorList.Items[0].Name = miscas.mesh`
> `ActorList.Items[0].LODList.Items[0].MeshObjects.LoadFromFile = .\data\actors\buildings\mis\miscas.osm`
> `ActorList.Items[*] ... Name = miscas1.mesh ... miscas1.osm` … `miscas2.osm` …
> `miscas3.osm` … `miscas4.osm` … `miscas_death1.osm` … `miscas_death2.osm`"
>
> — S3, step 24 (http://cossacksworld.ucoz.co.uk/index/new_buildings/0-349)

Step 5 of the same guide states the baseline rule explicitly:

> "Note: If you do have deathstages/buildstages for your building, then you would
> add those .osm file names here. (See step 24.)"

**DERIVED (strong):** donor build meshes are `<sid>1.osm … <sid>4.osm`; suffix
`"1"` is the *first* (foundation/scaffold) mesh, suffix `"4"` is the *last*
build-stage mesh; the completed structure is the separate base mesh `<sid>.osm`
registered as `ActorList.Items[0]`. Death meshes `<sid>_death1/2.osm` are a
different `essential_death` path, not build stages.

### 1.1 Death stages — corroboration (S1, first-hand)

> "Models such as `bavcen_death1a` and `bavcen_death2a` depict the ruins, but they
> are not separate game objects."
>
> "`DeathStage1` runs after 30 seconds, changes the model to `<sid>_death1`, and
> schedules `DeathStage2` after another 30 seconds."
>
> — S1 §6.2 (building_mechanics_evidence.md; fn 28 = `data/scripts/units/building.inc/deathstage1.inc:5-11`)

This confirms stage meshes are selected by swapping the object's *model*, and that
death-stage selection is a separate state machine from build-stage selection.

---

## 2. OBSERVED — how build-stage meshes are selected during construction

### 2.1 Progress is a scalar; the mesh is a state-derived proxy (S1, first-hand)

> "The game calculates `delta`, `buildprogress`, and the durability increase
> whenever a `construct` animation finishes:
> `delta := gc_buildtime_progressperhit / buildtime`
> `buildprogress += delta`
> `hp += round(maxhp × delta)`, capped at `maxhp`"
>
> — S1 §3.1, fn 7 = `units/unit.inc/onaclanimationreachedconstruct.inc:25-37`

> "`construct` — building construction or repair." (13 frames = 0.406 g-sec)
>
> — almanac `internals_en/engine/animation_system.md` §2.1 / TL;DR
> (https://github.com/anyalink99/cossacks-3-almanac/blob/main/internals_en/engine/animation_system.md)

### 2.2 The engine's visual-stage FSM (S1-animation, first-hand)

The unit FSM `statetag` bitmask includes a **visual group that directly enumerates
the stage slots**:

> "| Visual | `visual_none`, `visual_stage_0..3`, `visual_hide` |"
>
> "When changing states, `.acl`-FSM selects the appropriate animation
> (for example, `walkfood` if `state = move_walk + resource_food`)."
>
> — animation_system.md §4 "Unit FSM and Animation Integration"

**DERIVED:** four visual stage slots `0..3` map onto the four donor meshes
`<sid>1..4.osm`. Stage selection is therefore **driven by the build-progress state
→ visual-stage tag → mesh swap**, not by the ghost and not by a separate art path.
`visual_none` / completion corresponds to the finished base `<sid>.osm`.

### 2.3 Editor `bstage X` proves progress→mesh selection (S3, indexed)

> "6. To have an unfinished building on your map, press enter and type:
> `bstage x` where X is the % (1-100) of the construction stage. Only works for
> buildings that have construction stages."
>
> — S3 sibling page `/index/objects/0-226`

> "`bstage` USAGE: `bstage %` EXAMPLE: `bstage 50` FUNCTION: Sets a building to
> an unfinished building state in % of its total building time. EXPLANATION:
> Select a building in Map Editor, type `bstage 0-100` and the building will show
> its unfinished building animation."
>
> "Perhaps a note: this only works for buildings that actually have the graphics
> for building stages, for example the SelFraDoms or GorFra dont have these
> graphics and make the buildings dissapear."
>
> — S3 sibling forum `/forum/28-52-1`

**DERIVED:** the donor itself selects the visible mesh from a percentage of total
build time; buildings with no stage art have **no** fallback stage mesh (they
vanish in the editor). This is a donor quirk we should NOT reproduce — our port
has an explicit `base_mesh_port_approximation` fallback (§4.2 below), which is
a deliberate improvement, not a parity defect.

### 2.4 `BUILDSTAGES` count (S3, indexed; Cossacks 1/2 engine lineage)

> "changing a building's BUILDSTAGES to 1 will speed the construction up
> immensely, so that they are built the instant a construction unit 'touches'
> the build-site. Changing it to 0 will make the build-site explode when placed."
>
> — S3 sibling forum `/forum/26-666-1`

 corroborates that the number of stage meshes is data-driven.

### 2.5 Footprint is *not* derived from the stage mesh (S1 + S2, first-hand)

> "**Footprint:** the collision mask in `<sid>.prop`; each mask cell spans
> 0.5 map cells (`gc_collision_size = 0.5`)." — S1 TL;DR
>
> "**The model bounds** (`CustomBoundingAABB`) used for rendering and selection
> are separate from the collision mask and usually smaller."
> "**Mask scale:** `ScaleFactor = 1` … The visual `DefaultScale = 0.662` does not
> affect collision." — S1 §1
>
> "The model visible on screen and the space it actually occupies may differ."
> "The visual boundary used for selection is calculated separately. An area that
> looks empty may therefore reject a foundation." — S2 "In brief" / "Building footprint"

**DERIVED:** the donor's placement legality is checked against the `.prop` mask,
**never** against the silhouette of whichever stage mesh happens to be displayed.
A ghost drawn from the stage-1 mesh silhouette is therefore doubly dishonest:
wrong *shape of building* and potentially wrong *footprint*.

Placement-adjacent donor history (S3, indexed) shows snapping/search behaviour
that can make a preview lie if recreated:

> "Implemented algorithm to search for proper place to construct a building,
> if current position is unavailable. Now the game would propose to use proper
> place nearby" — patch 05.05.17 (1.5.4.72.5195)
>
> "Improved the building allocation mechanism, now players can place buildings
> closer to trees." — patch 14.01.17 (1.2.5.60.4425)
>
> — `/index/patch_notes_2017/0-336`

---

## 3. OBSERVED — ghost-preview convention (S4, indexed snapshot)

> "**GHOST PREVIEW**
> A translucent hologram of a structure shown at the cursor before placement —
> green when valid, red when blocked — letting players see exactly what they're
> about to build and where.
> …
> Designers use ghost previews because construction is a commitment and the
> preview removes placement anxiety: rotation, footprint, snapping, and terrain
> conflicts all resolve visually before resources are spent …
> Key decisions: how much validity detail the ghost communicates (binary
> red/green versus specific blockers highlighted), whether ghosts can be queued
> as construction orders … and how the preview handles partial validity like a
> wall segment crossing a rock.
> **Pitfall: a lying ghost — any gap between what the preview showed and what
> placement actually produced (offset snapping, hidden clearance rules)
> destroys the trust the entire pattern exists to provide; the ghost must be
> pixel-honest.**"
>
> — https://gamemechanicshoard.com/mechanic/ghost-preview/

A related page returned by the same search (site: studyraid, a derivative
tutorial, **not** a donor source, use as generic design context only) states the
"final build piece" principle:

> "The most economical implementation begins with a simplified mesh or translucent
> proxy **derived from the final build piece**."
>
> — `https://app.studyraid.com/en/read/100582/4504713/visualizing-placement-ghost-previews`

### 3.1 Honest answer on "finished vs first"

- **OBSERVED (S4):** the generic convention is a hologram of *a structure* with
  green/red validity and a *pixel-honest* footprint. S4 does **not** explicitly
  say "the last stage"; that specific claim is in our charter §1b.3 as an owner
  requirement, not as a sentence in S4.
- **UNVERIFIED:** that Cossacks 3 itself displays a finished-structure hologram
  at placement. None of the required sources contains a Cossacks-3-specific
  screenshot or script line describing the in-game placement ghost mesh. The
  owner's "last stage" requirement is therefore authoritative for our port
  **as an explicit product decision**, but must not be written up as a verified
  donor behaviour. (This is exactly the charter's OBSERVED-vs-UNVERIFIED rule.)
- **DERIVED, strong:** what the donor *does* show when a foundation is placed is
  the **first** stage mesh (§2.1–2.3): progress 0 → visual_stage_0 → `<sid>1.osm`.
  Showing that same mesh in the *pre-placement ghost* is precisely the "ghost
  shows first foundation" defect the owner reported — the ghost previews the
  *starting scaffold*, not the *committed result*.

---

## 4. AUDIT OF OUR PORT (read-only; file paths for the fix)

### 4.1 The 3D ghost currently resolves **stage "1"** — the first foundation

`variant3d/scripts/world3d_fx.gd:634-657` `_ghost_resolve_mesh()`:

```
639: # 1) Read-only call into the sibling entities module: already-baked,
640: # bbox-normalised stage-0 mesh. Stage-0 = suffix "1" (donor
641: # floor(progress*4), DBUILD_01 §2.2 carried cite); resolver at
642: # world3d_entities.gd:1796-1821, suffix rule at :1782-1788.
645:  var stage_info: Dictionary = provider.call("_stage_mesh_info", sid, "1", false)
...
650: # Fallback within the provider: finished base mesh
652: if provider.has_method("_mesh_info"):
653:     var base_info: Dictionary = provider.call("_mesh_info", sid, "building")
```

`variant3d/scripts/world3d_fx.gd:901-907` `_ensure_roots()`:

```
901: # Primary ghost node: actual stage-0 building mesh, transparent via the
902: # shared _ghost_mat (GHOST_OK/GHOST_BAD + pulse in _update_ghost).
903: _ghost_building = MeshInstance3D.new()
904: _ghost_building.name = "GhostBuildingStage0"
```

`variant3d/scripts/world3d_fx.gd:574-598` `draw_ghost(sid, pos, ok)` calls
`_ghost_swap_building_mesh(s)` → `_ghost_resolve_mesh(s)`; green/red comes from
`_ghost_mat` (`_update_ghost()` at `:1473-1483`, `GHOST_OK/GHOST_BAD`, 0.5 alpha
style). The mesh is *transparent via a single shared material*, so no donor
texture is copied — good, and consistent with the "translucent hologram" pattern.

**CONFIRMED (OBSERVED locally):** the 3D placement ghost is the **first-stage
foundation mesh**, with the finished base mesh reachable only as a *fallback*
when stage art is missing. This is the exact inversion of the owner's requirement.

### 4.2 The 2D port already does the right thing — an internal inconsistency

`variant3d/scripts/world.gd:3516-3519`:

```
3516: # transparent building: nation sheet if baked, else static sprite, else ring only
3517: var ghost_tex: Texture2D = _bld_tex({"player": 0, "sid": sid, "finished": true, "progress": 1.0, "def": def})
```

`variant3d/scripts/world.gd:742-753` `_bld_tex()` only walks the construction
stage sprites when `not e.finished`; with `finished:true` it returns the
**completed building sprite**. So the 2D ghost already shows the finished
building; only the 3D ghost regressed to stage 1. That is strong internal
evidence for the recommended fix, independent of any external claim.

### 4.3 Footprint honesty in our port (partial, keep as-is)

- `variant3d/scripts/world3d_fx.gd:591-592` draws the ground footprint box from
  `_building_radius(s)`, and `:1535-1540` reads `Data.BUILDINGS[sid].radius`.
- `variant3d/scripts/game.gd:3932-3986` `can_place()` validates against the same
  radius (`bld_rm(player, sid)` / `def.radius`, `_mr`) plus terrain and resources.
- Therefore the *indicator* and the *verdict* currently share one radius source —
  a genuine "pixel-honest" property worth preserving.
- **UNVERIFIED / residual risk:** our radius-circle model is a PORT APPROX of the
  donor's 0.5-cell collision mask (S1 §1); the donor mask can reject an area that
  "looks empty" (S2). The ghost also draws no per-cell mask overlay, so partial
  validity (S4: "a wall segment crossing a rock") is not communicated. Do not
  claim donor footprint fidelity; label it PORT APPROX.

### 4.4 Green / red validity (already correct, do not regress)

`variant3d/scripts/world3d.gd:463-498` `_sync_build_ghost()` mirrors
`world.gd:3460-3509` and feeds `can_place()` + affordability into
`fx.draw_ghost(sid, wp, ok)`; `world.gd:3509` uses
`Color(0.2,1.0,0.3,0.5)` green / `Color(1.0,0.25,0.2,0.5)` red. The UI/hotkey
state is `hud.build_ghost_sid` (`variant3d/scripts/hud.gd:102,1107,1522`;
`input_controller.gd:1205-1212,1356-1362`). No change needed for validity colour.

### 4.5 Stage-mesh selection for *actual construction* (do not change)

`variant3d/scripts/world3d_entities.gd` is correct-by-design and should be left
alone:

- `:290` `BUILD_STAGE_STEPS = 4` (donor `unit.script:6596`),
  `:293` `BUILD_STAGE_LABEL` explicitly "visual UNVERIFIED".
- `:1805-1811` `_build_stage_suffix()` = `floor(progress01 * 4)` clamped to
  `0..3` → suffix `"1".."4"`; walls `1 + stage div 3` → `"1"/"2"`.
- `:1819-1844` `_stage_mesh_info()` resolves `<sid><suffix>.obj`, with
  `base_mesh_port_approximation` when no art exists.
- `:1851-1897` `_sync_building_stages()` swaps the placed building's mesh by
  suffix and tags meta `build_stage_suffix` / `build_stage_source`.
- Telemetry at `:500-507` records `build_stage_rule`,
  `build_stage_art_status` etc. — structural only, "visual UNVERIFIED".

This is the donor progress→visual-stage→mesh pipeline (§2.2) and must remain the
source of truth for *construction*. Only the ghost's choice of mesh is wrong.

---

## 5. CONCRETE RECOMMENDATION (audit only — no edits made by F02)

**Goal:** make the placement ghost show the **LAST / completed** structure while
leaving in-progress construction meshes and all validity logic untouched.

1. **Primary change — `variant3d/scripts/world3d_fx.gd`, `_ghost_resolve_mesh()`
   at `:634-657`.** Reverse the resolution order: ask the sibling entities
   provider for the **finished base mesh first**
   (`provider.call("_mesh_info", sid, "building")`, current lines 652-657),
   cache it in `_ghost_mesh_cache`, and set `stats["ghost_mesh_source"]` to the
   finished/base value. Only if that returns no `Mesh`, fall back to the **last**
   stage suffix `"4"` via `provider.call("_stage_mesh_info", sid, "4", false)`.
   **Remove the stage `"1"` request at line 645** from the ghost path (it is the
   first foundation and is the reported bug). Update the stale comments at
   `:639-642` and `:650` to say "finished hologram (owner §1b.3); last stage
   fallback", and remove the "stage-0" wording.
2. **Optional clarity — same file, `_ensure_roots()` `:901-904`.** Rename the
   node `"GhostBuildingStage0"` → `"GhostBuildingFinished"` and its comment to
   match. **Check `variant3d/tests/t_fx3d.gd` (`:165`, `:218-221`) and any other
   string-match assertions before doing so** — they assert the `draw_ghost` API,
   not the node name, so this is expected to be safe, but must be re-run.
3. **Keep untouched:** `variant3d/scripts/world3d_entities.gd` (all of
   `_build_stage_suffix`, `_stage_mesh_info`, `_sync_building_stages`) — that is
   the *construction* mesh selector and already matches the donor pipeline.
4. **Keep untouched:** validity/colour path `variant3d/scripts/world3d.gd:463-498`,
   `variant3d/scripts/world.gd:3460-3509`, `variant3d/scripts/hud.gd`,
   `variant3d/scripts/input_controller.gd`. Green = ok / red = blocked is the
   documented convention (S4) and is already implemented.
5. **Preserve footprint honesty:** keep `variant3d/scripts/world3d_fx.gd:591-592`
   and `:1535-1540` reading the same radius source as `can_place()`
   (`variant3d/scripts/game.gd:3932-3986`). If a future change introduces the
   donor mask, update the ghost indicator and `can_place()` **together** — never
   draw a footprint from the finished mesh silhouette (S1 §1: mask vs.
   `CustomBoundingAABB` are separate). Label the whole thing PORT APPROX.
6. **Labels / documentation:** any new comment or report text must say
   "owner requirement §1b.3" for "last stage", and "generic convention (S4)" for
   hologram/green-red; it must NOT say "verified donor ghost = finished mesh".
   Donor-parity stays UNVERIFIED (no A/B frame).
7. **Verification for the implementing agent (Wave E):** re-run variant selftest
   (29/29), uitest (17/17 — `scripts/uitest.gd:160-167` covers ghost→site→builder
   flow), `t_render_mode`, `assert_clean` CLEAN; add a telemetry assertion that
   `stats["ghost_mesh_source"]` for a sid with stage art resolves to the
   finished/base source, not `stage_obj`/suffix `"1"`. Per charter §3, back up
   before editing (`inbox/backup/<file>.bak-<TICKET>`) and use one Godot runner at
   a time only if a job is actually required.

---

## 6. Direct answers to the four dispatch questions

| Question | Answer | Confidence |
|---|---|---|
| What model does the placement ghost show — first foundation or finished? | Donor *placed* object at 0% shows the first stage mesh `<sid>1.osm` (§2). S4 defines the ghost as a hologram of the structure and demands pixel-honesty; it does not itself state "last stage". Our **3D ghost explicitly requests suffix `"1"`** (`world3d_fx.gd:645`) — first foundation — while our 2D ghost already uses `finished:true` (`world.gd:3517`). | OBSERVED locally / DERIVED donor; "finished donor ghost" UNVERIFIED |
| Green/red validity? | Yes — generic convention: "green when valid, red when blocked" (S4); our port implements it in `world.gd:3509` and `world3d.gd:463-498`. Donor-3D-specific colour shade UNVERIFIED. | OBSERVED (S4 + local) |
| Footprint honesty? | Required by S4 ("the ghost must be pixel-honest"). Donor legality uses a `.prop` collision mask independent of the visible mesh (S1 §1, S2); our port uses one shared radius for both indicator and `can_place()` — honest within the port, PORT APPROX vs donor mask; no per-cell mask/partial-validity overlay. | DERIVED / UNVERIFIED parity |
| How are build-stage meshes selected during construction? | Progress scalar (`buildprogress`) → FSM visual tag `visual_stage_0..3` → mesh swap among `<sid>1..4.osm`; completed state uses base `<sid>.osm`; editor `bstage X` sets the % and shows the unfinished animation; death stages are a separate `essential_death` state machine. Our port mirrors this in `world3d_entities.gd:1805-1897`. | OBSERVED (S1, S1-animation, S3) |
| Owner requirement | Ghost = **LAST stage / completed structure**. Implement by resolving finished base mesh first, last stage `"4"` as fallback, never `"1"` (§5.1). This is an owner product decision, not a verified donor claim. | OWNER DIRECTIVE (charter §1b.3) |

---

## 7. URL inventory

- S1 evidence doc: https://github.com/anyalink99/cossacks-3-almanac/blob/main/internals_en/scripts/building_mechanics_evidence.md
  (raw: https://raw.githubusercontent.com/anyalink99/cossacks-3-almanac/main/internals_en/scripts/building_mechanics_evidence.md)
- S1 animation doc: https://github.com/anyalink99/cossacks-3-almanac/blob/main/internals_en/engine/animation_system.md
- S2 EN reader: https://github.com/anyalink99/cossacks-3-almanac/blob/main/docs_en/recon/world/economy/building_mechanics.md
  (raw: https://raw.githubusercontent.com/anyalink99/cossacks-3-almanac/main/docs_en/recon/world/economy/building_mechanics.md)
- S3 new_buildings guide: http://cossacksworld.ucoz.co.uk/index/new_buildings/0-349
- S3 siblings: http://cossacksworld.ucoz.co.uk/index/objects/0-226 ,
  http://cossacksworld.ucoz.co.uk/forum/28-52-1 ,
  http://cossacksworld.ucoz.co.uk/forum/26-666-1 ,
  http://cossacksworld.ucoz.co.uk/index/patch_notes_2017/0-336
- S4 ghost preview: https://gamemechanicshoard.com/mechanic/ghost-preview
- Generic context only (not donor): https://app.studyraid.com/en/read/100582/4504713/visualizing-placement-ghost-previews

*End of F02 report. Read-only: no code files were modified; no Godot jobs submitted.*
