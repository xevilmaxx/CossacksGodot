---
id: E04
ticket: "Building ghost final-stage QA atom design (decisive test/capture)"
swarm: TERRAIN-SWARM-2026-11-25
owner: E04 subagent (analysis / read-only)
created: 2026-11-25
status: PROPOSAL ONLY — NO ATOM CREATED, NO GODOT RUN, NO RUNNER JOB
labels: [observed, derived, inferred, UNVERIFIED, PORT APPROX]
outputs: [docs/terrain_swarm_2026-11-25/reports/E04_ghost_qa.md]
---

# E04 — decisive QA atom for the building-ghost FINAL-stage fix

## 0. Authority / scope statement

- This report is the ONLY file written by this agent. **No shared code was edited**;
  `variant3d/tests/t_ghost_final_stage.gd` below is a **proposal, not a created file**.
- **No Godot process was started, no runner job was submitted** (CHARTER §3 one-Godot
  rule; `docs/COMMANDS.md` §0 runner monopoly). The launch command in §8 is for COORD
  to run **after** E03's fix proposal and B06's landed change exist.
- **No headless PASS is claimed anywhere.** Headless is an explicit `SKIP_CAPTURE`,
  `passed=false`, non-PASS result (§7).
- Donor parity stays **UNVERIFIED**: there is no donor GPU A/B frame in this project.
  All colours/radii below are port-side, labelled **PORT APPROX**.

## 1. What must be proven (charter owner requirement 3, verbatim)

> "Phantom/ghost building preview must show the LAST (completed) build stage, not the
> first. Today the ghost shows the earliest foundation stage. Donor ghost-preview
> convention: a translucent hologram of the *finished* structure (green valid / red
> blocked). The ghost must be pixel-honest about footprint."
> — `docs/terrain_swarm_2026-11-25/CHARTER.md:81-84`

Decisive test = a **real 64×64 windowed 3D game** in which the ghost is shown, its
**mesh resource identity** is compared with the authoritative finished/final mesh and
with the foundation mesh, its **material alpha/tint** and **footprint geometry** are
measured, a **real windowed GPU PNG is saved while placement is active**, and the
cancel / place lifecycle is exercised end-to-end. A test that only reads a `stats`
dictionary or only parses source text is **not** decisive.

## 2. Code ground truth (OBSERVED — direct source reads this session)

| Fact | Evidence | Label |
|---|---|---|
| Ghost is driven by `hud.build_ghost_sid` (authoritative) → `world3d._sync_build_ghost()` → `fx.draw_ghost(sid, wp, ok)` | `world3d.gd:459-498`, `hud.gd:102`; FX instantiated as world3d child at `world3d.gd:603-611` | observed |
| FX root is `BuildGhost3D` with children `Footprint` (BoxMesh `1×0.05×1`) and primary building node `GhostBuildingStage0` | `world3d_fx.gd:877-907` | observed |
| **Pre-fix bug** (OBSERVED in `git diff` + backup): `_ghost_resolve_mesh()` first asked the entities provider for `_stage_mesh_info(sid, "1", false)` — the **foundation** art `hou1.obj` — and only fell back to the finished base mesh; node was literally named `GhostBuildingStage0` | `inbox/backup/world3d_fx.gd.bak-B06` (original `:634-657`, `:901-904`); `world3d_entities.gd:1819-1844` (`path := OBJ_DIR + sid + suffix + ".obj"`) | observed (pre-fix) |
| **B06 fix landed concurrently during E04 authoring**: finished base mesh `_mesh_info(sid,"building")` resolved FIRST, last-stage `"4"` only as fallback, `"1"` never requested; primary node renamed `GhostBuildingFinished`. The `Footprint` BoxMesh is still hidden whenever a building mesh resolves (fallback-only) | live `world3d_fx.gd:642-680` diff (`:_ghost_resolve_mesh`, `:_ensure_roots`); backup `world3d_fx.gd.bak-B06` | observed (post-fix) |
| Donor stage rule: suffixes `1..4` (`hou1.obj`…`hou4.obj` all exist on disk); finished building uses the base mesh `_mesh_info(sid,"building")` → `hou.obj`/GLB | `world3d_entities.gd:275-294, 1802-1811, 1867-1877`; `variant3d/assets/models/obj/hou{1,2,3,4}.obj`, `hou.obj` (glob-confirmed) | observed |
| Ghost material: `GHOST_OK=(0.20,1.00,0.30,0.45)`, `GHOST_BAD=(1.00,0.25,0.20,0.45)`; `_material()` → `TRANSPARENCY_ALPHA`, unshaded, emission, `CULL_DISABLED`; `_ensure_roots()` adds `DEPTH_DRAW_DISABLED`; `_update_ghost()` pulses alpha by `0.85+0.15*sin(_time*4)` | `world3d_fx.gd:141-142, 887-892, 990-1001, 1473-1483` | observed |
| Footprint overlay scale is `Vector3(r*2,1,r*2)` with `r = max(0.25, Data.BUILDINGS[sid].radius)`; it is **hidden** when a building mesh resolves (fallback only) | `world3d_fx.gd:591-592, 622-631, 1535-1540`; `data.gd:1303-1330` (`radius` = footprint, "estimated") | observed |
| Placement gate uses the **same** radius: `my_r0 = bld_rm(player,sid) or def.radius`, used for resource/building footprint collision | `game.gd:3962-4004`, `bld_rm` at `:1822` | observed |
| Cancel = right-click clears `hud.build_ghost_sid`; place = left-click clears it after `game.place_building`; `world3d._sync_build_ghost` then actively hides the FX ghost | `input_controller.gd:720-748, 858-859`; `world3d.gd:471-474` | observed |
| `place_building` spawns `finished=false`, `hp=25%`, sends builders → the entities module attaches a real `Building_<sid>_<id>_STATIC_POSE` MeshInstance3D with `build_stage_suffix="1"` and a `Scaffold_*` child while unfinished | `game.gd:4038-4102`; `world3d_entities.gd:1645-1682, 1851-1920` | observed |
| Windowed 3D capture seam: `--screenshot` boots the full game (menu skipped) and creates `main.capture_view3d` (`Screenshot3DViewport`, 1280×720, `UPDATE_ONCE`) holding world+camera; real GPU PNG comes from that texture | `main.gd:233-248, 1235-1253, 1849-1929`; fixture `small_map_64.json:1-16` (`render_mode=3d`, 64×64) | observed |
| `main` has its own screenshot saver that calls `_quit(0)`; the atom must freeze it (`screenshot_frames=1000000`, `screenshot_done=true`) before doing its own capture so it can continue to cancel/place assertions | `main.gd:68-71, 1730-1732, 1849-1930` | derived |
| Synthetic mouse delivery via `Input.parse_input_event` reaches `input_controller._unhandled_input` in windowed mode; event coords equal camera-viewport coords when root size == projection size (1280×720) | `t_select_rect.gd:321-340, 470-488`, CAM-RV-01 job-381 precedent cited there | observed (prior job) |

**Pre-fix expectation (INFERRED, to be confirmed by E01/E03):** the mesh-identity,
no-foundation, visible-footprint and stable-alpha checks below will FAIL because the
baseline ghost resolves `hou1.obj` and hides the footprint. `expected_pre_fix_failure`
records that provenance; it never turns a failing check into a pass (same rule as
`t_select_rect.gd:178-188`).

## 3. Proposed atom — `variant3d/tests/t_ghost_final_stage.gd` (NOT created)

Owns only its own result JSON `res://tests/results/t_ghost_final_stage.json` and two
temp PNGs. No game code, config, manifest, fixture or gate edit.

### 3.1 Check list (every row is a real runtime assertion)

| # | Check name | Assertion | Pre-fix? |
|---|---|---|---|
| 1 | `boot_real_64_3d_game` | real `main.tscn` boot, `render_mode=="3d"`, `MAP_W==MAP_H==64`, `fx != null`, `capture_view3d != null` | no |
| 2 | `build_mode_entered` | `hud.build_ghost_sid == "hou"`; a peasant is selected; cost affordable | no |
| 3 | `ghost_node_exists` | `BuildGhost3D` found under `world.fx`; visible; building ghost MeshInstance3D found with non-null mesh | no |
| 4 | `ghost_mesh_is_final_finished` | ghost mesh resource **identity** equals `entities._mesh_info("hou","building").mesh` **or** `entities._stage_mesh_info("hou","4",false).mesh` (authoritative final/finished art) | **yes** (pre-fix binds `hou1`) |
| 5 | `no_foundation_mesh` | ghost mesh identity **!=** `_stage_mesh_info("hou","1",false).mesh`; no ghost child with meta `build_stage_suffix=="1"`; no `Scaffold_*` child; no child named `GhostBuildingStage0` | **yes** (pre-fix bound `hou1`) |
| 6 | `ghost_alpha_and_tint_ok` | shared ghost material is `TRANSPARENCY_ALPHA`, `CULL_DISABLED`, `DEPTH_DRAW_DISABLED`, albedo RGB ≈ `GHOST_OK` RGB, alpha in `[0.30,0.46]` (pulse band), emission RGB = albedo RGB | no — regression guard (rig existed pre-fix) |
| 7 | `footprint_matches_donor_mask` | `Footprint` node **visible**, BoxMesh `(1,0.05,1)`, scale `(2r,1,2r)` with `r = bld_rm(0,"hou") or def.radius` — the same mask radius `can_place()` uses | **yes** pre-fix **and still red post-B06** — see §7 open question |
| 8 | `png_during_placement` | real windowed PNG saved from `main.capture_view3d` **while ghost active**; non-black > 0.5; non-empty | no (headless skips) |
| 9 | `ghost_visible_in_pixels` | placement PNG vs post-cancel PNG differ by > 40 pixels in a 160px box at the ghost centre, and a majority of changed pixels are green-dominant | no — proves rendering, not art stage (a foundation ghost also renders) |
| 10 | `ghost_tint_blocked` | moving ghost onto the home town hall → `_sync_build_ghost` → tint ≈ `GHOST_BAD` RGB, same alpha band | no (colour path already exists) |
| 11 | `cleared_on_cancel` | right-click → `hud.build_ghost_sid==""` **and** ghost root hidden / `_ghost_active==false` | no |
| 12 | `converted_to_construction_node_on_place` | left-click at a clear site → new building entity `sid=="hou"`, `player==0`, `finished==false`, `hp==def.hp*0.25`; a real `Building_hou_<id>_STATIC_POSE` MeshInstance3D exists with `build_stage_suffix=="1"` and a scaffold child; ghost cleared | no |

No threshold is lowered and no assertion is deleted to make the baseline green.
Check 4 accepts two authoritative "final" conventions (finished base mesh **or** last
stage `4`) so the atom survives either E03 choice; it **rejects stage 1**, which is the
actual defect. If E03 names exactly one convention, COORD should tighten check 4 to
that single identity before promoting this atom to a red gate.

### 3.2 Full GDScript (proposal — verbatim, complete)

```gdscript
# TEST-E04 / t_ghost_final_stage.gd — PROPOSAL ONLY, AUTHORED BY E04, NOT CREATED.
#
# Owns ONLY this file + res://tests/results/t_ghost_final_stage.json + two temp PNGs.
# No shared code/config/fixture/manifest/gate edit. AUTHORING ONLY: no Godot job,
# no runner ticket was taken by this agent.
#
# Decisive ghost-stage atom: real windowed 64x64 3D main.tscn boot, one building
# ("hou"), structural + resource-identity assertions on the FINAL-stage ghost mesh,
# alpha/tint, donor-mask footprint, windowed GPU PNG DURING placement, cancel and
# place lifecycle. Headless emits SKIP_CAPTURE / passed=false — NEVER a fake PASS.
#
# Launch (COORD, Windows `python`, one Godot at a time, AFTER E03/B06 land):
#   python variant3d\tools\godot_runner.py run --id e04-ghost-final --timeout 90 -- ^
#     --path variant3d --script res://tests/t_ghost_final_stage.gd -- ^
#       --config <ABS>\variant3d\tests\fixtures\small_map_64.json ^
#       --screenshot <TEMP>\e04_ghost_during.png ^
#       --no-ghost-png <TEMP>\e04_ghost_cancelled.png
extends SceneTree

const MAIN_SCENE := "res://scenes/main.tscn"
const DEFAULT_FIXTURE := "res://tests/fixtures/small_map_64.json"
const OUT_PATH := "res://tests/results/t_ghost_final_stage.json"
const Data = preload("res://scripts/data.gd")

# world3d_fx.gd:141-142, 887-892, 990-1001, 1473-1483 (PORT APPROX, world.gd:3509).
const GHOST_OK := Color(0.20, 1.00, 0.30, 0.45)
const GHOST_BAD := Color(1.00, 0.25, 0.20, 0.45)
const ALPHA_LO := 0.30                 # 0.45 * pulse floor 0.85 -> 0.3825; slack
const ALPHA_HI := 0.46                 # 0.45 * pulse ceiling 1.0
const EPS := 0.02
const SID := "hou"                     # one building; hou1..hou4 + hou.obj exist
const FINAL_SUFFIX := "4"              # donor last construction stage
const FOUNDATION_SUFFIX := "1"         # the defect: foundation/first stage

var _id := "t_ghost_final_stage"
var _checks: Array[Dictionary] = []
var _ok := true
var _finished := false
var _stage := 0
var _stage_frames := 0
var _headless := false
var _setup_ok := false
var _capturing := false

var _cfg_arg := ""
var _png_arg := ""
var _no_ghost_arg := ""
var _abs_config := ""
var _png_path := ""
var _no_ghost_path := ""

var _main: Node = null
var _game = null
var _world = null
var _fx: Node = null
var _cam = null
var _hud = null
var _ictl = null
var _picker = null
var _ents = null
var _ghost_root: Node = null
var _ghost_building: Node = null
var _footprint: Node = null

var _site := Vector2.INF
var _click_px := Vector2.INF
var _half := Vector2.ZERO
var _peasant = null
var _n_bld0 := 0
var _expected_final_mesh: Mesh = null
var _expected_final_source := ""
var _foundation_mesh: Mesh = null
var _img_ghost: Image = null
var _m: Dictionary = {}


func check(name: String, cond, detail: String = "", expected_pre_fix_failure: bool = false) -> void:
    _checks.append({
        "name": name, "passed": cond == true, "detail": detail,
        "expected_pre_fix_failure": expected_pre_fix_failure,
        "status": ("PASS" if cond == true else "FAIL"),
    })
    if cond == false:
        _ok = false
    print("TGHOST %s %s - %s%s" % ["PASS" if cond == true else "FAIL", name, detail,
        " [EXPECTED_FAILURE_PRE_FIX]" if expected_pre_fix_failure else ""])


func _arg_value(flag: String) -> String:
    for src in [OS.get_cmdline_user_args(), OS.get_cmdline_args()]:
        var args := PackedStringArray(src)
        for i in range(args.size()):
            if str(args[i]) == flag and i + 1 < args.size():
                return str(args[i + 1])
    return ""


func _resolve_config(given: String) -> String:
    if given.is_absolute_path():
        return given if FileAccess.file_exists(given) else ""
    var by_res := ProjectSettings.globalize_path("res://").path_join(given)
    if FileAccess.file_exists(by_res):
        return by_res
    if FileAccess.file_exists(given):
        return given
    return ""


func _goto(s: int) -> void:
    _stage = s
    _stage_frames = 0


func _find_named(root: Node, wanted: String) -> Node:
    var stack: Array[Node] = [root]
    while not stack.is_empty():
        var n: Node = stack.pop_back()
        if n.name == wanted:
            return n
        for c in n.get_children():
            stack.append(c)
    return null


func _find_building_ghost(root: Node) -> Node:
    # Structural probe, robust to a fix renaming "GhostBuildingStage0":
    # the primary ghost mesh is the MeshInstance3D under BuildGhost3D whose
    # mesh is non-null and whose material_override is the shared ghost material.
    var stack: Array[Node] = [root]
    while not stack.is_empty():
        var n: Node = stack.pop_back()
        if n is MeshInstance3D:
            var mi := n as MeshInstance3D
            var mv: Variant = mi.get("material_override")
            if mi.mesh != null and mv is StandardMaterial3D and n.name != "Footprint":
                return n
        for c in n.get_children():
            stack.append(c)
    return null


func _color_near(c: Color, want: Color) -> bool:
    return absf(c.r - want.r) <= EPS and absf(c.g - want.g) <= EPS and absf(c.b - want.b) <= EPS


func _write_result(verdict: String) -> void:
    var passes := 0
    for c in _checks:
        if bool(c.get("passed", false)):
            passes += 1
    var out := {
        "id": _id,
        "passed": (verdict == "PASS"),
        "verdict": verdict,
        "capture_status": ("PASS" if _img_ghost != null else "SKIP_CAPTURE"),
        "passes": passes,
        "total": _checks.size(),
        "checks": _checks,
        "measured": _m,
        "png_during_placement": _png_path,
        "png_after_cancel": _no_ghost_path,
        "headless": _headless,
        "no_headless_pass": "headless never reports PASS; SKIP_CAPTURE has passed=false",
        "runner_declaration": "COORD to run e04-ghost-final via variant3d/tools/godot_runner.py (status first); E04 authored only, no job submitted",
        "script_error_note": "verify via variant3d/tools/smallmap_capture.py scan-stderr on runner stderr.txt",
        "parity_label": "PORT APPROX — no donor GPU A/B frame; tint world.gd:3509, radius data.gd:1303 estimated",
        "unix_ms": Time.get_unix_time_from_system() * 1000.0,
    }
    var abs_dir := ProjectSettings.globalize_path(OUT_PATH.get_base_dir())
    DirAccess.make_dir_recursive_absolute(abs_dir)
    var f := FileAccess.open(ProjectSettings.globalize_path(OUT_PATH), FileAccess.WRITE)
    if f != null:
        f.store_string(JSON.stringify(out, "\t"))
        f.close()
    else:
        push_error("t_ghost_final_stage: cannot write result JSON")
    print("TGHOST RESULT_JSON: " + ProjectSettings.globalize_path(OUT_PATH))
    print("TGHOST RESULT: %s %d/%d" % [verdict, passes, _checks.size()])
    # SKIPPED_HEADLESS / SKIP_CAPTURE exit 0 as a DELIBERATE SKIP, never a PASS claim.
    call_deferred("quit", 0 if (verdict != "FAIL" and _ok) else 1)


func _initialize() -> void:
    if _finished:
        return
    _headless = DisplayServer.get_name() == "headless"
    _cfg_arg = _arg_value("--config")
    _png_arg = _arg_value("--screenshot")
    _no_ghost_arg = _arg_value("--no-ghost-png")
    if _headless:
        check("headless_guard", false,
            "SKIP_CAPTURE: 3D ghost + windowed GPU PNG need a real window; no fake PASS")
        _m["display_server"] = DisplayServer.get_name()
        _write_result("SKIPPED_HEADLESS")
        return
    if _cfg_arg == "" or _png_arg == "":
        check("launch_args", false, "need --config <small_map_64.json> and --screenshot <during.png> (menu skip)")
        _write_result("ABORTED_ARGS")
        return
    _abs_config = _resolve_config(_cfg_arg)
    if _abs_config == "":
        check("launch_args", false, "config fixture not found: " + _cfg_arg)
        _write_result("ABORTED_ARGS")
        return
    _png_path = _png_arg
    _no_ghost_path = (_no_ghost_arg if _no_ghost_arg != "" else _png_path.get_basename() + "_cancelled.png")
    _m["config"] = _abs_config
    _m["display_server"] = DisplayServer.get_name()
    var packed := load(MAIN_SCENE) as PackedScene
    if packed == null:
        check("boot_real_64_3d_game", false, "cannot load " + MAIN_SCENE)
        _write_result("ABORTED_BOOT")
        return
    _main = packed.instantiate()
    root.add_child(_main)
    _goto(0)  # wait for full 3D boot before inspecting


func _configure() -> bool:
    _game = _main.get("game")
    _world = _main.get("world")
    _cam = _main.get("camera")
    _hud = _main.get("hud")
    _ictl = _main.get("input_ctl")
    _ents = (_world.get("entities") if _world != null else null)
    _fx = (_world.get("fx") as Node) if _world != null else null
    var cv = _main.get("capture_view3d")
    var boot_ok := (_game != null and _world != null and _cam != null and _hud != null
        and _ictl != null and _ents != null and _fx != null and cv is SubViewport
        and str(_main.get("render_mode")).to_lower() == "3d"
        and int(_game.get("MAP_W")) == 64 and int(_game.get("MAP_H")) == 64)
    check("boot_real_64_3d_game", boot_ok,
        "render_mode=%s MAP=%sx%s fx=%s capture_view3d=%s" % [
        str(_main.get("render_mode")),
        str(_game.get("MAP_W")) if _game != null else "?",
        str(_game.get("MAP_H")) if _game != null else "?",
        str(_fx != null), str(cv is SubViewport)])
    if not boot_ok:
        return false

    # Freeze main's own saver (it calls _quit(0) after saving) and the sim/AI so
    # the ghost pose stays fixed through capture, cancel and place.
    _main.set("screenshot_frames", 1000000)
    _main.set("screenshot_done", true)
    _hud.visible = true
    var ais = _main.get("ais")
    if ais is Array:
        ais.clear()
    _main.set("speed", 0.0)
    _cam.set_process(false)
    _cam.edge_margin = 0.0
    _cam.corner_margin = 0.0
    var half_v := Vector2(float(_game.get("MAP_W")), float(_game.get("MAP_H"))) * Data.TILE_M * 0.5
    _half = half_v
    _cam.call("jump_to_world", half_v)
    _picker = _ictl.get("picking")
    check("picking3d_bound", _picker != null, "picking3d adapter exists for click projection")

    # Authoritative expected meshes, read from the SAME entities provider the
    # ghost uses — no invented art constant, no source-text-only assertion.
    var base_info: Dictionary = {}
    if _ents != null and _ents.has_method("_mesh_info"):
        base_info = _ents.call("_mesh_info", SID, "building")
    var stage4: Dictionary = {}
    if _ents != null and _ents.has_method("_stage_mesh_info"):
        stage4 = _ents.call("_stage_mesh_info", SID, FINAL_SUFFIX, false)
        var f0: Dictionary = _ents.call("_stage_mesh_info", SID, FOUNDATION_SUFFIX, false)
        _foundation_mesh = f0.get("mesh") as Mesh
    if base_info.get("mesh") is Mesh:
        _expected_final_mesh = base_info["mesh"] as Mesh
        _expected_final_source = "finished_base_mesh:" + str(base_info.get("source", "?"))
    elif stage4.get("mesh") is Mesh:
        _expected_final_mesh = stage4["mesh"] as Mesh
        _expected_final_source = "final_stage_" + FINAL_SUFFIX + ":" + str(stage4.get("source", "?"))
    _m["expected_final_mesh_source"] = _expected_final_source
    _m["foundation_mesh_id"] = _foundation_mesh.get_instance_id() if _foundation_mesh != null else -1
    check("final_art_available", _expected_final_mesh != null and _foundation_mesh != null,
        "finished/final mesh=%s foundation mesh=%s; OBJ dir has hou1..hou4 + hou.obj" % [
        str(_expected_final_mesh != null), str(_foundation_mesh != null)])

    # Clear test site + one peasant + affordable treasury.
    _game.entities.clear()
    _game.by_id.clear()
    _game.live_units.clear()
    _game.live_blds.clear()
    _game.grid.clear()
    _game.events.clear()
    for p in _game.players:
        p["entities"] = []
        if p.get("res") is Array:
            for i in range((p["res"] as Array).size()):
                p["res"][i] = 5000.0
    _game.next_id = 100
    _peasant = _game.spawn("peasant", 0, half_v + Vector2(-4.0, -3.0))
    for e in _game.entities:
        e["selected"] = (int(e.id) == int(_peasant.id))
    _n_bld0 = _game.buildings_of(0).size()
    var site := Vector2.INF
    for dz in range(-6, 7):
        for dx in range(-6, 7):
            var cand := half_v + Vector2(float(dx) * 2.0, float(dz) * 2.0)
            if bool((_game.call("can_place", 0, SID, cand) as Dictionary).get("ok", false)):
                var centred := cand - half_v
                var px: Vector2 = _cam.unproject_position(Vector3(centred.x, 0.0, centred.y))
                var vp: Vector2 = Vector2(_cam.get_viewport().size)
                if px.x > 40.0 and px.y > 40.0 and px.x < vp.x - 40.0 and px.y < vp.y - 40.0:
                    site = cand
                    _click_px = px
                    break
        if site != Vector2.INF:
            break
    _site = site
    _m["site_sim"] = [_site.x, _site.y]
    _m["click_px"] = [_click_px.x, _click_px.y]
    var site_ok := is_finite(_site.x) and is_finite(_click_px.x) and _peasant != null
    check("clear_site_selected", site_ok,
        "site=%s click=%s peasant=%s" % [str(_site), str(_click_px), str(_peasant != null)])
    if not site_ok:
        return false

    _hud.build_ghost_sid = SID
    _ictl._set_selection([_peasant])
    var gate: Dictionary = _hud.build_gate(SID, _site)
    check("build_mode_entered", str(_hud.build_ghost_sid) == SID
        and bool(gate.get("ok", false)) and not _game.get_selected().is_empty(),
        "sid=%s gate=%s selected=%d" % [str(_hud.build_ghost_sid), str(gate),
        _game.get_selected().size()])
    _setup_ok = true
    _apply_ghost(_site)   # hud sid -> world3d._sync_build_ghost -> fx.draw_ghost
    return true


func _apply_ghost(pos: Vector2) -> void:
    if _world == null or not _world.has_method("set_build_ghost_pos"):
        return
    _world.call("set_build_ghost_pos", pos)   # SIM map-origin metres
    _world.call("_sync_build_ghost")          # real per-frame handoff, synchronous


func _probe_ghost() -> void:
    _ghost_root = _find_named(_fx, "BuildGhost3D")
    _footprint = (_find_named(_ghost_root, "Footprint") if _ghost_root != null else null)
    _ghost_building = (_find_building_ghost(_ghost_root) if _ghost_root != null else null)
    var active_v: Variant = _fx.get("_ghost_active") if _fx != null else null
    _m["ghost_root_visible"] = (_ghost_root.visible if _ghost_root != null else false)
    _m["ghost_active"] = (active_v == true)


func _assert_ghost_structure() -> void:
    _probe_ghost()
    var exists := (_ghost_root != null and _ghost_root.visible and _ghost_building != null
        and (_ghost_building as MeshInstance3D).mesh != null)
    check("ghost_node_exists", exists,
        "root=%s visible=%s building=%s mesh=%s" % [
        str(_ghost_root != null), str(_ghost_root != null and _ghost_root.visible),
        str(_ghost_building.name) if _ghost_building != null else "<none>",
        str((_ghost_building as MeshInstance3D).mesh != null) if _ghost_building != null else "no"])
    if not exists:
        return

    # --- mesh identity: FINAL/finished, never FOUNDATION ---------------------
    var gm: Mesh = (_ghost_building as MeshInstance3D).mesh
    _m["ghost_mesh_id"] = gm.get_instance_id()
    _m["expected_final_mesh_id"] = _expected_final_mesh.get_instance_id() if _expected_final_mesh != null else -1
    var is_final := (_expected_final_mesh != null and gm == _expected_final_mesh)
    check("ghost_mesh_is_final_finished", is_final,
        "ghost_mesh=%d expected_final=%d (%s)" % [gm.get_instance_id(),
        _expected_final_mesh.get_instance_id() if _expected_final_mesh != null else -1,
        _expected_final_source], true)

    var suffix1_children := 0
    var scaffold_children := 0
    var stale_name_nodes := 0
    var stack: Array[Node] = [_ghost_root]
    while not stack.is_empty():
        var n: Node = stack.pop_back()
        if n.has_meta("build_stage_suffix") and str(n.get_meta("build_stage_suffix")) == FOUNDATION_SUFFIX:
            suffix1_children += 1
        if str(n.name).begins_with("Scaffold"):
            scaffold_children += 1
        if str(n.name) == "GhostBuildingStage0":   # pre-fix name must not survive
            stale_name_nodes += 1
        for c in n.get_children():
            stack.append(c)
    var no_foundation := (_foundation_mesh == null or gm != _foundation_mesh) \
        and suffix1_children == 0 and scaffold_children == 0 and stale_name_nodes == 0
    _m["ghost_suffix1_children"] = suffix1_children
    _m["ghost_scaffold_children"] = scaffold_children
    _m["ghost_stale_stage0_name_nodes"] = stale_name_nodes
    check("no_foundation_mesh", no_foundation,
        "ghost != foundation(%s); stage1 nodes=%d scaffold nodes=%d stale_stage0_names=%d" % [
        str(_foundation_mesh != null and gm != _foundation_mesh), suffix1_children,
        scaffold_children, stale_name_nodes], true)

    # --- alpha / tint ---------------------------------------------------------
    var mv: Variant = _ghost_building.get("material_override")
    if mv is StandardMaterial3D:
        var mat := mv as StandardMaterial3D
        var c := mat.albedo_color
        var rgb_ok := _color_near(c, GHOST_OK)
        var a_ok := (c.a >= ALPHA_LO and c.a <= ALPHA_HI)
        var rig_ok := (mat.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA
            and mat.cull_mode == BaseMaterial3D.CULL_DISABLED
            and mat.depth_draw_mode == BaseMaterial3D.DEPTH_DRAW_DISABLED
            and _color_near(mat.emission, Color(c.r, c.g, c.b)))
        var foot_mat: Variant = _footprint.get("material_override") if _footprint != null else null
        var shared := (foot_mat != null and (foot_mat as Variant).get_instance_id() == mat.get_instance_id())
        _m["ghost_albedo"] = [c.r, c.g, c.b, c.a]
        _m["ghost_transparency"] = mat.transparency
        _m["ghost_depth_draw"] = mat.depth_draw_mode
        check("ghost_alpha_and_tint_ok", rgb_ok and a_ok and rig_ok and shared,
            "albedo=%s want_rgb=%s alpha_ok=%s rig_ok=%s shared_mat=%s" % [
            str(c), str(GHOST_OK), str(a_ok), str(rig_ok), str(shared)])
    else:
        check("ghost_alpha_and_tint_ok", false, "material_override is not StandardMaterial3D")

    # --- footprint overlay vs the donor-derived collision mask ---------------
    if _footprint is MeshInstance3D:
        var fp := _footprint as MeshInstance3D
        var r_sim := 0.0
        if _game.has_method("bld_rm"):
            r_sim = float(_game.call("bld_rm", 0, SID))
        if r_sim <= 0.0:
            r_sim = maxf(0.25, float((Data.BUILDINGS[SID] as Dictionary).get("radius", 1.5)))
        var want := Vector3(r_sim * 2.0, 1.0, r_sim * 2.0)
        var bm_ok := (fp.mesh is BoxMesh and (fp.mesh as BoxMesh).size.is_equal_approx(Vector3(1.0, 0.05, 1.0)))
        var scale_ok := fp.scale.is_equal_approx(want)
        _m["footprint_radius_m"] = r_sim
        _m["footprint_scale"] = [fp.scale.x, fp.scale.y, fp.scale.z]
        check("footprint_matches_donor_mask", fp.visible and bm_ok and scale_ok,
            "visible=%s box=%s scale=%s want=%s r=bld_rm/def.radius=%.2f (PORT APPROX)" % [
            str(fp.visible), str(bm_ok), str(fp.scale), str(want), r_sim], true)
    else:
        check("footprint_matches_donor_mask", false, "no Footprint MeshInstance3D under BuildGhost3D", true)


func _image_metrics(img: Image) -> Dictionary:
    var w := img.get_width()
    var h := img.get_height()
    var nb := 0
    var sum := 0.0
    var step := 4
    var n := 0
    for y in range(0, h, step):
        for x in range(0, w, step):
            var c := img.get_pixel(x, y)
            if c.r > 8.0 / 255.0 or c.g > 8.0 / 255.0 or c.b > 8.0 / 255.0:
                nb += 1
            sum += 0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b
            n += 1
    return {"width": w, "height": h, "samples": n,
        "non_black_fraction": float(nb) / float(maxi(n, 1)),
        "mean_luma_0_1": sum / float(maxi(n, 1))}


func _diff_metrics(a: Image, b: Image, centre: Vector2, radius: int) -> Dictionary:
    var changed := 0
    var green_dom := 0
    var x0 := maxi(0, int(centre.x) - radius)
    var y0 := maxi(0, int(centre.y) - radius)
    var x1 := mini(a.get_width() - 1, int(centre.x) + radius)
    var y1 := mini(a.get_height() - 1, int(centre.y) + radius)
    for y in range(y0, y1 + 1, 2):
        for x in range(x0, x1 + 1, 2):
            var ca := a.get_pixel(x, y)
            var cb := b.get_pixel(x, y)
            if absf(ca.r - cb.r) + absf(ca.g - cb.g) + absf(ca.b - cb.b) > 0.06:
                changed += 1
                if ca.g > ca.r and ca.g > ca.b:
                    green_dom += 1
    return {"changed_px": changed, "green_dominant_px": green_dom,
        "box": [x0, y0, x1, y1]}


func _capture_async(is_during: bool) -> void:
    _capturing = true
    var cv := _main.get("capture_view3d") as SubViewport
    if cv == null or not is_instance_valid(cv):
        check("capture_image", false, "main.capture_view3d missing (windowed --screenshot boot required)")
        _capturing = false
        return
    cv.render_target_update_mode = SubViewport.UPDATE_ONCE
    var tex := cv.get_texture()
    if tex == null:
        check("capture_image", false, "null Screenshot3DViewport texture")
        _capturing = false
        return
    await RenderingServer.frame_post_draw
    if _finished:
        return
    var img: Image = tex.get_image()
    if img == null or img.is_empty():
        check("capture_image", false, "blank SubViewport image — no CPU fallback (main.gd:1906-1913)")
        _capturing = false
        return
    var path := (_png_path if is_during else _no_ghost_path)
    var dir := path.get_base_dir()
    if dir != "" and not DirAccess.dir_exists_absolute(dir):
        DirAccess.make_dir_recursive_absolute(dir)
    var err := img.save_png(path)
    check("capture_image", err == OK,
        "%s saved real windowed GPU frame %dx%d err=%d" % [
        "during" if is_during else "cancel", img.get_width(), img.get_height(), err])
    var metrics := _image_metrics(img)
    metrics["path"] = path
    metrics["bytes"] = (FileAccess.get_file_as_bytes(path).size() if FileAccess.file_exists(path) else 0)
    if is_during:
        _img_ghost = img
        _m["png_during"] = metrics
        check("png_during_placement", metrics["non_black_fraction"] > 0.5 and metrics["bytes"] > 0,
            "real 3D frame during placement: %s" % str(metrics))
    else:
        _m["png_after_cancel"] = metrics
        if _img_ghost != null:
            var d := _diff_metrics(_img_ghost, img, _click_px, 80)
            _m["ghost_pixel_diff"] = d
            check("ghost_visible_in_pixels", int(d["changed_px"]) > 40
                and int(d["green_dominant_px"]) > int(d["changed_px"]) / 2,
                "changed=%d green=%d box=%s (PORT APPROX evidence, not donor parity)" % [
                d["changed_px"], d["green_dominant_px"], str(d["box"])])
    _capturing = false


func _assert_blocked_tint() -> void:
    var home = _game.buildings_of(0)
    if home.is_empty():
        check("ghost_tint_blocked", false, "no home building to create a blocked site")
        return
    var hp: Vector2 = (home[0] as Dictionary).get("pos", Vector2.ZERO)
    _apply_ghost(hp)
    _probe_ghost()
    if _ghost_building == null:
        check("ghost_tint_blocked", false, "ghost vanished at blocked site")
        return
    var mv: Variant = _ghost_building.get("material_override")
    if mv is StandardMaterial3D:
        var c := (mv as StandardMaterial3D).albedo_color
        _m["ghost_albedo_blocked"] = [c.r, c.g, c.b, c.a]
        check("ghost_tint_blocked", _color_near(c, GHOST_BAD)
            and c.a >= ALPHA_LO and c.a <= ALPHA_HI,
            "blocked albedo=%s want_rgb=%s" % [str(c), str(GHOST_BAD)])
    else:
        check("ghost_tint_blocked", false, "no StandardMaterial3D ghost material")


func _send_mouse_button(p: Vector2, pressed: bool, right: bool) -> void:
    var ev := InputEventMouseButton.new()
    ev.position = p
    ev.global_position = p
    ev.button_index = MOUSE_BUTTON_RIGHT if right else MOUSE_BUTTON_LEFT
    ev.pressed = pressed
    Input.parse_input_event(ev)


func _event_coord(p: Vector2) -> Vector2:
    # Windowed identity (CAM-RV-01 job 381): root size == camera projection size.
    var proj: Vector2 = Vector2(_cam.get_viewport().size)
    var win: Vector2 = Vector2(root.size)
    if proj.x <= 0.0 or proj.y <= 0.0:
        return p
    return Vector2(p.x * win.x / proj.x, p.y * win.y / proj.y)


func _process(_dt: float) -> bool:
    if _finished or _capturing:
        return false
    _stage_frames += 1
    match _stage:
        0:
            if _stage_frames >= 3:
                if not _configure():
                    _write_result("ABORTED_SETUP")
                else:
                    _goto(1)
        1:
            if _stage_frames >= 3:
                _apply_ghost(_site)          # re-assert pose; synthetic motion can't move the ghost
                _assert_ghost_structure()    # checks 3..7
                _capture_async(true)         # PNG DURING placement
                _goto(2)
        2:
            if _stage_frames >= 2:
                _assert_blocked_tint()       # check 10
                _apply_ghost(_site)
                _goto(3)
        3:
            if _stage_frames >= 2:
                # Cancel through the real input seam, then verify FX teardown.
                _send_mouse_button(_event_coord(_click_px), true, true)
                _send_mouse_button(_event_coord(_click_px), false, true)
                _apply_ghost(_site) if str(_hud.build_ghost_sid) != "" else _world.call("_sync_build_ghost")
                _probe_ghost()
                var active_v: Variant = _fx.get("_ghost_active") if _fx != null else null
                var cleared := str(_hud.build_ghost_sid) == "" \
                    and (_ghost_root == null or not _ghost_root.visible) and active_v != true
                check("cleared_on_cancel", cleared,
                    "hud.sid=%s ghost_visible=%s active=%s" % [
                    str(_hud.build_ghost_sid),
                    str(_ghost_root != null and _ghost_root.visible), str(active_v)])
                _capture_async(false)        # baseline PNG after cancel
                _goto(4)
        4:
            if _stage_frames >= 3:
                # Re-enter placement and convert to a real construction node.
                _hud.build_ghost_sid = SID
                _ictl._set_selection([_peasant])
                _apply_ghost(_site)
                var before: Array = _game.buildings_of(0)
                _send_mouse_button(_event_coord(_click_px), true, false)
                _send_mouse_button(_event_coord(_click_px), false, false)
                _goto(5)
        5:
            if _stage_frames >= 3:
                var after: Array = _game.buildings_of(0)
                var made: Dictionary = {}
                for b in after:
                    if not before.has(b) and str((b as Dictionary).get("sid", "")) == SID:
                        made = b as Dictionary
                        break
                var def: Dictionary = Data.BUILDINGS[SID]
                var ok_node := false
                var node_detail := "no new building"
                if not made.is_empty():
                    var id := int(made.get("id", -1))
                    var node := _find_named(_ents, "Building_" + SID + "_" + str(id) + "_STATIC_POSE")
                    var suffix_v: Variant = (node.get_meta("build_stage_suffix") if node != null else null)
                    var scaff := _find_named(_ents, "Scaffold_" + SID + "_" + str(id))
                    ok_node = (node != null and (node as MeshInstance3D).mesh != null
                        and str(suffix_v) == FOUNDATION_SUFFIX and scaff != null)
                    node_detail = "id=%d finished=%s hp=%s node=%s suffix=%s scaffold=%s" % [
                        id, str(made.get("finished", "?")), str(made.get("hp", "?")),
                        str(node != null), str(suffix_v), str(scaff != null)]
                var finished_ok := (not made.is_empty() and bool(made.get("finished", true)) == false
                    and int(made.get("hp", 0)) == maxi(1, int(float(def.get("hp", 0)) * 0.25)))
                check("converted_to_construction_node_on_place",
                    finished_ok and ok_node and after.size() == _n_bld0 + 1
                        and str(_hud.build_ghost_sid) == "",
                    "%s; count %d->%d hud.sid=%s" % [node_detail, _n_bld0, after.size(),
                    str(_hud.build_ghost_sid)])
                _write_result("PASS" if _ok else "FAIL")
    return false
```

### 3.3 Notes on the proposed code

- **Real mesh identity, not a text grep.** Checks 4/5 use `Mesh` object identity from
  the same entities provider the ghost consumes. A cosmetic rename or a `stats` string
  cannot satisfy them; only actually binding the finished/final mesh does.
- **Two final conventions accepted.** Check 4 accepts the finished base mesh
  (`hou.obj` via `_mesh_info`) or last stage `hou4.obj` via `_stage_mesh_info(...,"4")`.
  That is deliberately broader than one asset path but **never** accepts stage `1`.
  `expected_final_mesh_source` is recorded so the reviewer sees which one matched.
  This matches the **landed B06 order** (finished base first, last stage fallback) and
  would also have failed on the pre-fix `hou1` binding.
- **Rename-safe structural probe.** `_find_building_ghost()` finds the primary ghost
  mesh by "MeshInstance3D under `BuildGhost3D` with a StandardMaterial3D override",
  so it works with both the pre-fix `GhostBuildingStage0` name and the landed
  `GhostBuildingFinished` name; check 5 separately fails if the stale `Stage0` name
  survives anywhere in the ghost subtree.
- **Footprint honesty.** Check 7 compares the visible overlay half-extent with the
  exact radius the placement gate uses (`bld_rm(0,"hou")`, else `def.radius`). This is
  the port's collision-mask footprint; `data.gd:1303` labels `radius` "estimated", so
  the whole check is **PORT APPROX / UNVERIFIED donor parity**, not an invented donor
  constant.
- **Pixel evidence.** Checks 8/9 save two real windowed GPU frames (during placement
  and after cancel) from `main.capture_view3d` and measure a green-dominant diff at the
  ghost centre. This proves the ghost actually rendered, beyond state assertions.
- **`expected_pre_fix_failure` is provenance only** (`t_select_rect.gd:178-188`
  precedent): it never flips `passed`, never lowers a threshold, and the atom still
  exits 1 while any evaluated check fails.
- **Traps avoided:** deferred `quit()` (never bare `quit()` in `_initialize`);
  `main`'s saver frozen before self-capture (it `_quit(0)`s); `Input.parse_input_event`
  in windowed mode only; `set_build_ghost_pos` re-asserted per stage because synthetic
  motion does not move the OS cursor; `Rect2` API not used; array/hostile calls guarded
  via `has_method`/`is Dictionary`.

## 4. Windowed PNG capture during placement (exact plan)

1. Launch **windowed** (no `--headless`) with `--config small_map_64.json` and
   `--screenshot <TEMP>\e04_ghost_during.png` (menu skip; `main.gd:233-248`).
2. Freeze `main`'s saver so it cannot `_quit(0)` mid-atom; keep `main.capture_view3d`
   (the real `Screenshot3DViewport`) alive as the capture target.
3. Enter build mode, set the ghost to a clear site, force `world._sync_build_ghost()`
   synchronously, assert structure, then set `UPDATE_ONCE`, `await frame_post_draw`,
   read `get_texture().get_image()` and `save_png()` to the `--screenshot` path. This is
   the same GPU seam `main.gd:1849-1929` uses, so the PNG is a genuine 1280×720 3D frame
   with the translucent ghost in it — not a CPU map substitute.
4. Save a second PNG after cancel to the `--no-ghost-png` path and compute the pixel diff
   in-atom (no shared tool edits).
5. **External, read-only verification** (after the runner job, no Godot):
   ```
   python variant3d\tools\smallmap_capture.py stats <TEMP>\e04_ghost_during.png <TEMP>\e04_ghost_cancelled.png
   python variant3d\tools\smallmap_capture.py scan-stderr "<runner-results>\<ticket>_e04-ghost-final\stderr.txt"
   ```
   A human/second agent should open the during-PNG and confirm a translucent *finished*
   house (not a foundation slab), green ring/footprint, and no ghost after cancel.
   `stats` is diagnostic only; no donor A/B exists.

## 5. Verdict semantics

| Situation | `verdict` | `passed` | exit |
|---|---|---|---|
| All 12 checks true, windowed PNG saved | `PASS` | true | 0 |
| Any evaluated check false (pre-fix expected for #4/#5/#6/#7/#9) | `FAIL` | false | 1 |
| Headless launch | `SKIPPED_HEADLESS` | false | 0 (deliberate skip) |
| Bad args / fixture / boot | `ABORTED_*` | false | 0 |

Headless never writes a PNG and never reports `PASS` (§0). A pre-fix `FAIL` is the
**expected red baseline**, not a test defect; do not "fix" it by weakening checks.

## 6. Exact runner command (COORD only; one Godot at a time)

Check the queue first (CHARTER §3: a job may be in flight):

```
python variant3d\tools\godot_runner.py status
```

Then, from the project root, **windowed** (no `--headless`), unique id `e04-ghost-final`.
Single line (PowerShell-safe — no `&&`, no `^` continuation; Windows `python`, never
`python3`, CHARTER §3):

```
python variant3d\tools\godot_runner.py run --id e04-ghost-final --timeout 90 -- --path variant3d --script res://tests/t_ghost_final_stage.gd -- --config "C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\variant3d\tests\fixtures\small_map_64.json" --screenshot "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\e04_ghost_during.png" --no-ghost-png "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\e04_ghost_cancelled.png"
```

- Refresh the unique id if `e04-ghost-final` is already used in
  `variant3d\.godot_queue\results\`. The second `--` passes the user args to the atom.
- Results: `variant3d\.godot_queue\results\<ticket>_e04-ghost-final\stdout.txt` /
  `stderr.txt`; atom JSON: `variant3d\tests\results\t_ghost_final_stage.json`.
- **E04 did not submit this job.** Only COORD runs it, after B06/E03 land, under the
  one-Godot lock. No direct `godot ...` invocation.

## 7. Observed / inferred / UNVERIFIED ledger

- **OBSERVED:** all code facts in §2 (source + asset glob reads this session).
- **DERIVED:** the atom design, the two-capture diff, the need to freeze `main`'s saver,
  and the acceptance of either final convention.
- **INFERRED:** the **pre-fix** baseline (`world3d_fx.gd.bak-B06`) fails checks #4/#5
  (foundation binding) and #7 (footprint hidden). The **landed B06** code should pass
  #4/#5/#6/#9; confirm by running §6. Check 7 is expected to remain RED until the
  footprint overlay is shown while the finished mesh is bound (see open question).
- **UNVERIFIED / PORT APPROX:** donor parity of tint (`world.gd:3509` port constant),
  donor mask radius (`data.gd:1303` estimated), stage-art visual fidelity, and the
  claim that the ghost "matches the donor finished hologram". No donor GPU A/B frame
  exists; `smallmap_capture.py` itself prints "qualitative comparison only". E02/E05
  may refine the final-stage asset policy; E04 did not invent a donor constant.
- **Open question for COORD (must resolve before this atom is a gate):** the landed
  B06 still sets `_ghost_mesh.visible = false` whenever a building mesh resolves
  (`world3d_fx.gd:_ghost_swap_building_mesh`), so check 7 (`footprint overlay visible`)
  will stay RED even though the mesh-stage bug is fixed. The charter says the ghost
  "must be pixel-honest about footprint" (`CHARTER.md:84`) — decide whether to (a) make
  the footprint overlay visible alongside the finished mesh, or (b) re-scope check 7
  to geometry-only. E04 does **not** weaken the check: it records the geometry and
  keeps the visibility requirement explicit. If a later fix replaces the `Footprint`
  child with a donor-mask decal under another name, the integrating owner must update
  `_probe_ghost()`/check 7 — not delete it.

## 8. Handoff

- E03 owns the exact fix contract (which authoritative mesh the ghost binds). E04's
  atom is ready to gate that fix: green only when the ghost stops showing `hou1` and
  binds finished/final art with honest footprint, alpha/tint, lifecycle and a real
  windowed PNG.
- COORD: create the proposed file verbatim (or merge with E03's naming), run §6 once
  under the runner lock, inspect the two PNGs, and keep the pre-fix `FAIL` evidence as
  the baseline for the post-fix `PASS` comparison.
- End of E04 report.
