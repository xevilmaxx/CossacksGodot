---
id: E01-GHOST-AUDIT
ticket: E01 (Wave E — BUILDING GHOST FINAL STAGE)
owner: E01 (read-only analysis subagent)
swarm: terrain_swarm_2026-11-25
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB
output: docs/terrain_swarm_2026-11-25/reports/E01_ghost_audit.md
scope: "Read-only. No .gd/.shader/.json/asset/test edited; no Godot job; no donor file opened; no gate claim. This report is the ONLY file written. All line numbers are from the current worktree read this pass."
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, PORT APPROXIMATION]
charter_refs: "CHARTER.md §1b item 3 (ghost must show LAST/completed build stage, green valid / red blocked, pixel-honest footprint); §3 guardrails"
---

# E01 — Building placement ghost: which mesh/stage is shown today

## 0. Answer in one line

**The ghost shows the FIRST construction stage (stage_0 / suffix `"1"`), not the last.**
The decisive line is `variant3d/scripts/world3d_fx.gd:645`:
`provider.call("_stage_mesh_info", sid, "1", false)` — the literal `"1"` is the
donor-named suffix for `floor(progress*4)==0`, i.e. `[0,0.25)` progress, the
foundation stage. The same first-stage hard-code is duplicated in the no-provider
fallback at `world3d_fx.gd:662` (`sid + "1.obj"`). OBSERVED.

---

## 1. Sources read this pass (all read-only)

| # | Path | Use / label |
|---|---|---|
| S1 | `docs/terrain_swarm_2026-11-25/CHARTER.md:81-84`, `:55-69` | Owner requirement + read-only/no-runner guardrails. OBSERVED |
| S2 | `docs/coord_swarm_2026-11-25/reports/DBUILD_01_building_stages.md:57-87`, `:154-170`, `:232-250` | Donor stage truth (`floor(progress*4)` → suffix 1..4), donor ghost truth (dummy + blink), port parity matrix. OBSERVED (report text) |
| S3 | `docs/coord_swarm_2026-11-25/reports/BUILD_STAGES_01.md:68-94`, `:177-189` | Stage selector implementation contract; base-mesh fallback when no stage OBJ. OBSERVED |
| S4 | `docs/coord_swarm_2026-11-25/reports/BUILD_STAGE_INTEGRATION_01.md:70-91`, `:164-186` | Stage art later landed; live selector is art-ready; suffix→stage boundary table. OBSERVED |
| S5 | `docs/coord_swarm_2026-11-25/reports/B_GHOST_DIAG.md:8-38` | Pre-fix diagnosis: flat green footprint box, no building mesh. OBSERVED |
| S6 | `docs/coord_swarm_2026-11-25/reports/B_GHOST_FIX.md:1-35` | The implemented fix that introduced `GhostBuildingStage0` via `_stage_mesh_info(sid,"1",false)`. OBSERVED |
| S7 | `docs/coord_swarm_2026-11-25/reports/SEASON_PLAN_01.md` | Read as instructed; season/atlas work, no ghost/stage coupling found. OBSERVED |
| S8 | `variant3d/scripts/world3d_fx.gd` | Ghost node creation, mesh resolution, tint/alpha, footprint, clear. OBSERVED |
| S9 | `variant3d/scripts/world3d_entities.gd` | Stage selector, `_stage_mesh_info()` resolver, live building stage swap. OBSERVED |
| S10 | `variant3d/scripts/world3d.gd` | `_sync_build_ghost()` gates, per-frame sync call, `set_build_ghost_pos()`. OBSERVED |
| S11 | `variant3d/scripts/input_controller.gd`, `hud.gd`, `game.gd`, `world.gd`, `main.gd` | sid set / cancel / place / 2D reference / boot wiring. OBSERVED |
| S12 | `variant3d/assets/models/obj/**`, `variant3d/assets/models/manifest.json` | On-disk stage art (`cen1.obj … cen4.obj`, `cen1a.obj … cen4a.obj`, `cena.obj`, base `cen.obj` present). OBSERVED |

**New-file build-stage module:** none exists. A recursive `Get-ChildItem -Filter "*stage*"`
under the repo returns only reports (S2–S4, `STAGE_IMPORT_01.md`, `QA_STAGE_IMPORT_01.md`)
and `inbox/backup/world3d_entities.gd.bak-BUILDSTAGES01`; `git status --short` shows only
`variant3d/selftest.json` modified plus this untracked swarm doc dir. The build-stage
module is **embedded in `world3d_entities.gd`** (`:290-292` constants, `:1785-1936`
selector/resolver/lifecycle), not a separate new file. OBSERVED (absence).

---

## 2. Evidence-labelled flow diagram (text)

Legend: `[O]` = OBSERVED at the cited `file:line`; `[D]` = DERIVED control-flow
consequence; `[U]` = UNVERIFIED (no runtime/visual capture). No Godot job was run.

```
                    SELECT A BUILDING TO CONSTRUCT
   [O] hud.gd:1100-1109  _on_build_pick(sid)
        |                build_gate(sid) :1103-1106; build_ghost_sid=sid :1107
   [O] input_controller.gd:1201-1213  hotkey path -> build_ghost_sid=sid :1212
        v
   [O] hud.gd:102  var build_ghost_sid := ""   (authoritative state, empty = no ghost)
        |
        +------------------ PER-FRAME HANDOFF ------------------+
        | [O] input_controller.gd:1360-1362  render_mode=="3d" &&
        |       picking!=null && sid!="" -> world.set_build_ghost_pos(
        |       _screen_to_world(mouse))  [SIM map-origin metres]
        | [O] world3d.gd:784-786  stores _ghost_pos + override flag
        | [O] world3d.gd:682,687  sync() -> _sync_build_ghost() every frame
        | [O] world3d.gd:471-498  gates in order:
        |       empty sid -> draw_ghost("") :473
        |       !finite point -> :477 ; !game.in_bounds -> :482
        |       sid = resolve_mine_sid(sid,wp) :485-486
        |       !Data.BUILDINGS.has(sid) -> :489
        |       ok = can_place(0,sid,wp).ok :492-495
        |       ok &= _can_pay_building(...) :496-497
        |       fx.draw_ghost(sid, wp, ok) :498
        v
   [O] world3d_fx.gd:574-598  draw_ghost(sid,pos,ok)
        | [O] :577-580  empty/invalid -> _ghost_active=false, root.visible=false, RETURN
        | [O] :584,589  p3 = world_pos(pos); _ghost_root.position = p3
        | [O] :591-592  r = _building_radius(sid); Footprint.scale=(r*2,1,r*2)
        | [O] :597      _ghost_swap_building_mesh(s)
        |                 [O] :615-632  on sid change:
        |                   _ghost_resolve_mesh(s) :621
        |                    [O] :643-645 provider._stage_mesh_info(sid,"1",false)  <== DEFECT
        |                    [O] :652-657 fallback provider._mesh_info(sid,"building")
        |                    [O] :662      fallback load obj/<sid>1.obj  (again stage 1)
        |                   mesh!=null -> GhostBuildingStage0.mesh=mesh; scale=ONE;
        |                                 visible=true; Footprint.visible=false :623-626
        |                   mesh==null -> building hidden; Footprint shown :628-631
        | [O] :598      stats["ghost_shown"] += 1
        | [O] :1473-1483 _update_ghost(): tint GHOST_OK/GHOST_BAD, alpha*0.85..1.0 pulse
        v
   [O] CLEARED ON PLACE / CANCEL
        place success  [O] input_controller.gd:744-747  build_ghost_sid="" (+select site)
        right-click    [O] input_controller.gd:858-860  build_ghost_sid=""
        Escape         [O] input_controller.gd:1153-1158 sid="" + menu closed + hint
        mode change    [O] input_controller.gd:446-451  _clear_pending_modes() sid=""
        -> next sync   [O] world3d.gd:471-473  fx.draw_ghost("",Vector2.ZERO,false)
        ->             [O] world3d_fx.gd:577-580  _ghost_active=false, root.visible=false
        [D] nodes are NOT freed: _ghost_building / _ghost_mesh / _ghost_mesh_cache
            persist and are reused; only visibility/active flag toggle.
```

---

## 3. What is actually shown — answers to the five trace questions

### 3.1 Model instantiated at the cursor — OBSERVED / DERIVED

- The ghost nodes are created **once, lazily**, in `world3d_fx.gd:882-907` (`_ensure_roots()`),
  not on each placement: `BuildGhost3D` (`Node3D`, `:883-886`), a `Footprint`
  `MeshInstance3D` (`:895-900`) and a **`GhostBuildingStage0` `MeshInstance3D`**
  (`:903-907`). No `OBJ`/`GLB` is loaded per frame; the mesh is swapped only on sid
  change (`world3d_fx.gd:618-620`) through the cache at `:637-638`. [O]
- Primary mesh source: `provider.call("_stage_mesh_info", sid, "1", false)` at
  `world3d_fx.gd:643-645`. The provider is the sibling `entities` instance found
  read-only via `get_parent().get("entities")` at `:604-612` (`world3d.gd:131`,
  instantiated at `:605`). [O]
- Resolver: `world3d_entities.gd:1819-1844` — path `OBJ_DIR + sid + suffix + ".obj"`
  (`:1826`), so suffix `"1"` resolves to **`obj/<sid>1.obj`**, baked Z-up→Y-up and
  bbox-normalised by `_bake_mesh()` (`:1837`, with `source =
  "obj_stage_zup_bbox_normalised"` at `:1838`). Verified on disk: `cen1.obj`,
  `cen2.obj`, `cen3.obj`, `cen4.obj` all exist (S12). [O]
- Fallbacks, in order: finished **base** mesh `_mesh_info(sid, "building")`
  (`world3d_fx.gd:652-657`), then unbaked direct load of `<sid>1.obj` → `<sid>.obj` →
  `<sid>.glb` (`:662-664`, labelled PORT APPROXIMATION / UNVERIFIED at `:658-661`),
  then the flat `Footprint` box (`:628-631`). [O]

### 3.2 Stage index — OBSERVED / DERIVED

- `BUILD_STAGE_STEPS = 4`, `BUILD_WALL_MAX_STAGE = 2`,
  `BUILD_STAGE_SUFFIXES = ["1","2","3","4"]` at `world3d_entities.gd:290-292`. [O]
- `_build_stage_suffix()` at `world3d_entities.gd:1805-1811`:
  `raw = clampi(floor(_build_progress01*4),0,3)`; `mesh_stage = raw+1`; walls fold
  to `mini(1+raw/3, 2)`. Hence suffix **`"1"` ⇔ raw 0 ⇔ progress `[0,0.25)`** =
  **first/foundation stage**; suffix **`"4"` ⇔ raw 3 ⇔ `[0.75,1.0)`** = **last
  construction stage**; finished buildings use suffix `""` (base mesh) at
  `world3d_entities.gd:1869-1877`. [O + D]
- Donor rule (from DBUILD-01 §2.2): `unit.script:6596` and
  `ontagstates.inc:240-251` map `floor(progress*4)` → visual tags → mesh suffix
  1..4; wall `1+stage div 3` at `ontagstates.inc:247-248`. Stage names/suffixes
  are donor-observed; the port's `progress/build_time` counter (rather than donor
  `hp/maxhp`) is labelled UNVERIFIED (S3 §7). [O via S2/S3]
- **The ghost hard-codes suffix `"1"` at `world3d_fx.gd:645` and `:662`**, so it
  previews the first foundation mesh for every sid, regardless of how complete the
  finished structure is. [O]

### 3.3 Alpha / tint — OBSERVED / DERIVED

- `GHOST_OK := Color(0.20, 1.00, 0.30, 0.45)` (green) and
  `GHOST_BAD := Color(1.00, 0.25, 0.20, 0.45)` (red) at `world3d_fx.gd:141-142`. [O]
- `_material()` at `:990-1001`: `TRANSPARENCY_ALPHA`, `SHADING_MODE_UNSHADED`,
  emission enabled at 0.35 energy, `CULL_DISABLED`; ghost material additionally
  `depth_draw_mode = DEPTH_DRAW_DISABLED` at `:892`, and both ghost nodes have
  `cast_shadow = OFF` at `:899`/`:906`. [O]
- `_update_ghost()` at `:1473-1483`: `c = GHOST_OK if _ghost_ok else GHOST_BAD`,
  `c.a *= 0.85 + 0.15*sin(_time*4.0)` → effective alpha ≈ **0.38–0.45**; writes
  `albedo_color` and `emission`. The **same** `_ghost_mat` is `material_override`
  for both the footprint (`:898`) and the building mesh (`:905`), so the green/red
  validity tint and blink apply to the building silhouette too. [O + D]
- `ok` originates in `can_place(...).ok` plus `_can_pay_building()` at
  `world3d.gd:491-497`, stored to `_ghost_ok` at `world3d_fx.gd:583`. This satisfies
  the "green valid / red blocked" half of CHARTER §1b.3; the donor ghost's literal
  colour/size/blink appearance is UNVERIFIED (`DBUILD_01:166-168`, S5 §2.6). [O/U]

### 3.4 Footprint outline — OBSERVED / DERIVED

- A single flat box: `BoxMesh.size = Vector3(1.0, 0.05, 1.0)` at
  `world3d_fx.gd:893-894`, node `Footprint` at `:895-897`. [O]
- Scaled to the building's sim radius: `_building_radius(sid)` at `:591` reads
  `Data.BUILDINGS[sid].radius`, floor 0.25, default 1.5 (`:1535-1540`); scale
  `Vector3(r*2.0, 1.0, r*2.0)` at `:592` → a 5 cm-high, `2r × 2r` ground plate. [O+D]
- **When a stage/base mesh resolves, the footprint is hidden** (`Footprint.visible =
  false` at `:626`); it is shown only as the labelled no-art fallback (`:631`).
  Therefore today, with stage art on disk, the player sees the tinted stage-0 mesh
  and **no persistent footprint outline**. This is relevant to the charter's
  "pixel-honest footprint" clause: the baked mesh is bbox-normalised with its
  **own** stage bbox (`world3d_entities.gd:1830-1842`), while the ground plate is
  a radius circle-square approximation from `Data.BUILDINGS`; their extents are
  not asserted equal. [O + D; exact visual match UNVERIFIED]

### 3.5 Cleared on place / cancel — OBSERVED / DERIVED

| Trigger | Site | Effect |
|---|---|---|
| Successful place (no Shift) | `input_controller.gd:744-747` | `hud.build_ghost_sid = ""`, then select the new site |
| Right-click cancel | `input_controller.gd:858-860` | `hud.build_ghost_sid = ""` |
| Escape cancel | `input_controller.gd:1153-1158` | sid cleared, build menu closed, "Build cancelled - no resources spent" hint |
| Other mode engage | `input_controller.gd:446-451` | `_clear_pending_modes()` clears sid |
| Next FX frame | `world3d.gd:471-473` → `world3d_fx.gd:577-580` | `draw_ghost("")` sets `_ghost_active=false`, `_ghost_root.visible=false` |
| Idle suppression | `world3d_fx.gd:1476-1477` | `_update_ghost()` also hides root when `_ghost_active==false` |

[D] The `MeshInstance3D` nodes and `_ghost_mesh_cache` are retained; the clear is a
visibility/active flag change, not a free. `_ghost_building_sid` (`:620`, `:277`)
is only changed on the next non-empty sid swap, so a re-entry with the same sid
after a cancel reuses the cached first-stage mesh. [O+D]

---

## 4. The defect (root cause)

> **OBSERVED:** `variant3d/scripts/world3d_fx.gd:645` —
> `var stage_info: Dictionary = provider.call("_stage_mesh_info", sid, "1", false)`
>
> **OBSERVED:** `variant3d/scripts/world3d_fx.gd:662` — direct fallback path
> `"res://assets/models/obj/" + sid + "1.obj"` — same hard-coded first stage.
>
> **OBSERVED:** `variant3d/scripts/world3d_fx.gd:271-275` and `:904` name the
> node/state `GhostBuildingStage0` / "stage-0 building preview", baking the wrong
> assumption into the identifiers as well as the call.
>
> **DERIVED:** suffix `"1"` maps to `raw = floor(progress*4) = 0` → progress
> `[0,0.25)` — the **first** construction mesh — per
> `world3d_entities.gd:1805-1811` and `:292`; the **last** construction stage is
> suffix `"4"` (`raw=3`), and the **finished/completed** structure is the base
> mesh (suffix `""`) at `world3d_entities.gd:1869-1877`.

`B_GHOST_FIX.md:18` explicitly states the fix "resolves its mesh through the
provider's already-baked, bbox-normalised stage-0 path `_stage_mesh_info(sid,
"1", false)`". That was correct for the prior ticket's acceptance ("transparent
building, not a green quad"), but it contradicts CHARTER §1b item 3: *"Phantom/
ghost building preview must show the LAST (completed) build stage, not the
first ... a translucent hologram of the finished structure."* [O + D]

**Consequence:** the ghost is a translucent hologram, but of the **earliest
foundation mesh** (`cen1.obj` etc., S12), not of the finished structure. Live
sites, by contrast, begin at the same `"1"` stage (`game.gd:2335` sets
`progress = 0.0`, `finished = false`; `world3d_entities.gd:1872-1877` selects
suffix `"1"`) and advance through `"2"`, `"3"`, `"4"` to the base mesh. So the
preview at cursor shows the site at day zero, not the promised result. [O + D]

**Fix location (NOT applied — read-only ticket):** the minimal semantic change is
`world3d_fx.gd:645` `"1"` → `"4"` (last construction stage) or `""` with
`_mesh_info(sid,"building")` (finished base mesh), plus `:662` direct-load fallback
and the `Stage0` labels at `:271`/`:904`; stage art for both branches is already on
disk (`cen4.obj`, `cen.obj`, S12) and `_stage_mesh_info()` at
`world3d_entities.gd:1819-1844` accepts a suffix argument. Whether the charter's
"LAST (completed)" means suffix `"4"` or the finished base mesh (`""`) is an
**UNVERIFIED interpretation** of the owner wording; the donor completion state
uses the base mesh (`DBUILD_01:84`, `BUILD_STAGES_01:88`), so `"finished"` base is
the donor-aligned reading. No parity claim is made. [D/U]

---

## 5. Search coverage (all named files)

| File | Ghost/preview/build-stage findings |
|---|---|
| `world3d_fx.gd` | Primary implementation: `:141-142` tints, `:269-282` state, `:574-598` draw, `:604-688` mesh resolution, `:882-907` nodes, `:1473-1483` tint/pulse, `:1535-1540` radius. **DEFECT at `:645`, `:662`.** |
| `world3d_entities.gd` | Stage module: `:290-292` constants, `:1785-1844` selector/resolver, `:1851-1936` live swap. Only "ghost" hit is `:1996` (unrelated deferred-free comment). No ghost-preview node. |
| `world3d.gd` | `:463-498` gate chain, `:682-687` per-frame call, `:784-786` pos handoff, `:131/:605` entities provider. |
| `input_controller.gd` | `:451`, `:744-747`, `:858-860`, `:1153-1158`, `:1201-1213`, `:1360-1362`, `:1377-1378` — sid set/clear/handoff/hint. |
| `hud.gd` | `:102` sid declaration, `:1100-1109` menu pick + gate, `:1222` cost gate comment, `:1522` sid check. (No mesh/stage logic.) |
| `game.gd` | `:2335` new site `finished=false, progress=0`, `:3932` `can_place`, `:4038` `place_building`, `:5061`/`:5110-5116` progress→finished. No ghost mesh. |
| `world.gd` (2D sibling) | `:3460-3514` `_draw_ghost()` — 2D tinted footprint rect (`:3509` colour, `:3513` radius), 120 ms verdict cache. Reference only; not the 3D ghost. |
| `main.gd` | No ghost/preview/build_stage keyword hits. Boot wiring of `world.hud` cited second-hand at `world3d.gd:459-461`; not re-read here. [O/U] |
| `uitest.gd`, `testbridge.gd`, `t_fx3d.gd` | Test-only sid set / hover comments (`uitest.gd:165-167`, `testbridge.gd:86,117`, `t_fx3d.gd:221`). Not production ghost code. |

---

## 6. Labels and limitations

- **OBSERVED:** literal current-tree bytes/lines cited above; on-disk stage OBJs
  (`cen1..cen4`) verified this pass; report text from S2–S7 read in full.
- **DERIVED:** suffix→progress mapping, control-flow of the clear path, node reuse,
  footprint scale arithmetic, and the root-cause conclusion.
- **INFERRED:** that the owner's complaint ("first stage instead of last") is
  caused by the `:645`/`:662` hard-code — the chain is exact, but no runtime probe
  was run to observe the rendered silhouette.
- **UNVERIFIED:** rendered 3D pixels / donor ghost appearance / whether "LAST
  (completed)" means suffix `"4"` or the finished base mesh; no GPU A/B exists
  (CHARTER §3, DBUILD_01 §6). No donor file was opened this task.
- **PORT APPROXIMATION:** the whole translucent building ghost is port-side art
  reuse, explicitly labelled as such at `world3d_fx.gd:271` and `B_GHOST_FIX.md:35`.
- **Guardrails honoured:** no code/config/asset/test edit; no Godot job or runner
  query; no gate/selection quad touched; no donor copy; exactly one report written.

*End of E01 report.*
