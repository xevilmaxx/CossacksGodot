---
id: BLD-04
ticket: "QA atom proposals for mine footprint parity + builder trapping (one report)"
swarm: TERRAIN-SWARM-WAVE-G / WAVE BLD
owner: BLD-04 subagent (analysis / read-only)
created: 2026-11-25
status: PROPOSAL ONLY — NO ATOM FILE CREATED, NO GODOT RUN, NO RUNNER JOB, NO PNG, NO RESULT JSON
labels: [observed, derived, inferred, UNVERIFIED, PORT APPROX]
outputs: [docs/terrain_swarm_2026-11-25/reports/BLD_04_qa.md]
parity_guard: "PORT APPROXIMATION — all extents/radii are port-side measurements from the live scene. No donor GPU A/B frame exists; donor parity stays UNVERIFIED (CHARTER §3, WAVE_G_CHARTER line 182)."
---

# BLD-04 — two decisive QA atoms (mine footprint parity, builder trapping)

## 0. Authority / scope statement

- Read first: `docs/terrain_swarm_2026-11-25/CHARTER.md`,
  `docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md` (Wave BLD rows, lines 171-183),
  and the atom patterns `G01_select_capture_atom.md`, `G02_ghost_atom.md`,
  `F2_05_qa.md`.
- **This report is the ONLY file written by this agent.** The two `.gd` atoms in
  §2.2 / §3.2 are **proposals, not created files**. No game code, config, fixture,
  gate, result JSON or PNG was touched. No backup was needed (no edit occurred).
- **No Godot process started, no runner job submitted.** WAVE-G standing rule
  (`WAVE_G_CHARTER.md:31`): only G04 owns the runner. The commands in §2.3/§3.3
  are for COORD; every runtime verdict here is **UNVERIFIED (NOT RUN)**.
- **No headless PASS.** Both atoms emit `capture_path = "SKIP_CAPTURE ..."`,
  `capture_status="SKIP_CAPTURE"`, `passed=false`, `verdict=SKIPPED_HEADLESS`,
  exit 1 when launched headless (D03 §6, G01 §2 Trap D, G02 §4, F2-05 §4).
- **Donor parity UNVERIFIED.** The owner's "about twice" is an observation of
  the current port, not a donor truth; the atoms measure the live port and gate
  only internal parity (indicator == placed mine). Labelled PORT APPROX.
- Sibling reports BLD-01/02/03 had **not landed** at authoring time (glob for
  `BLD_*` returned no files), so §1 is derived directly from source with cites.
  The atoms measure live geometry and therefore gate either fix without
  hard-coding its magnitude or its direction.

---

## 1. Source ground truth (OBSERVED — direct reads this session)

| Fact | Evidence | Label |
|---|---|---|
| Owner: ghost "+-" indicator must be the same size as the mine on the map; "now it's about twice". Builders get trapped inside the mesh and cannot finish; they must walk only around. | `WAVE_G_CHARTER.md:173` (BLD directive) | observed |
| Ghost ground indicator is `Footprint`, a `BoxMesh` of local size `(1, 0.05, 1)`, scaled in `draw_ghost()` to `Vector3(r*2, 1, r*2)` where `r = _building_radius(sid)` = `Data.BUILDINGS[sid].radius` floored at 0.25. Mine radius = 1.6 m ⇒ indicator full XZ span = 3.2 m × 3.2 m. | `world3d_fx.gd:909-916`, `:597-598`, `:1553-1558`; `data.gd:1342-1347` | observed + derived |
| `Footprint` is hidden whenever the finished art mesh resolves (`_ghost_mesh.visible = false`), so G02 check 7 is already RED. The **primary visible** ghost is `GhostBuildingFinished`, which uses the **same baked base mesh** the finished mine wears — its XZ span should equal the placed mine's by construction. | `world3d_fx.gd:621-637`, `:917-925`; `t_ghost_final_stage.gd:445-469` | observed |
| Placed building mesh = `Building_<sid>_<id>_STATIC_POSE`, `mi.mesh = _mesh_info(sid,"building").mesh`, transform from `_xf(id)` with basis scale 1 for buildings (only hidden entities and jittered wood res get non-1 scale). Manifest bbox for `mine_gold/iron/coal` = X 15.026 m, Z 15.822 m, H 1.913 m (OBJ vertices read directly), so the live mesh AABB is the authoritative extent — do **not** hard-code it in the atom. | `world3d_entities.gd:1657-1682`, `:1551-1593`, `:1110-1160`, `:1053-1107`; `assets/models/manifest.json` (`mine_*`); OBJ vertex scan | observed + derived |
| Build-placement handoff: `world.set_build_ghost_pos(SIM metres)` → `_sync_build_ghost()` resolves `mine` sid, checks `can_place`, calls `fx.draw_ghost(sid,pos,ok)`; `fx._update_ghost()` settles tint on FX's own frame. | `world3d.gd:424-437, 463-498, 784-786`; `world3d_fx.gd:580-604, 1491-1501` | observed |
| Mine legality/snap: `MINE_SITE_RADIUS=4.0 m`; `mine_deposits()` returns nodes with `hits==0 and max_hits==0`; `place_building("mine", pos, ...)` overwrites `pos = n.pos` for a matching deposit. Harness fallback: `_add_res(type, p, 0, 0.0)` creates a real permanent deposit. | `game.gd:19, 2420-2425, 3125-3142, 4032-4061, 4138-4157`; F2-05 §3.2 | observed |
| Builder work positions: order `"build"` targets `_work_slot(e, site.pos, block_r + 0.7)` = golden-angle ring at `ring_r + (id%3)*0.35`; builder walks there with `_step_move`, then hits every `BUILD_HIT_INTERVAL=1.25 s` for `BUILD_PROGRESS_PER_HIT*1.5 = 0.359*1.5 ≈ 0.539` progress. Finish when `progress >= build_time`, then `_on_building_finished` and order cleared. | `game.gd:5184-5218`, `:4899-4909`, `:3353`; `data.gd:63-64` | observed + derived |
| `place_building(..., send=true, builders)` orders each selected peasant via `cmd_build`; mine `build_time = 300*0.03125 = 9.375 s`. | `game.gd:4161-4202`; `data.gd:1342` | observed |
| Windowed capture seam: `--screenshot` skips menu + creates `main.capture_view3d` (1280×720); root backbuffer blank under gl_compatibility; main's own saver `_quit(0)`s after saving; main returns early when `ais` is empty (so the atom drives `game.tick()` + `world.sync()` itself). | `main.gd:233-248, 1235-1253, 1603, 1669-1672, 1849-1930`; `world3d.gd:682` | observed |
| 64² fixture exists. | `variant3d/tests/fixtures/small_map_64.json:1-16` | observed |

The pre-fix expectation (indicator ≠ mine; possible builder intrusion / stall) is
**INFERRED** from the owner directive and source. It is not a measured result —
no atom was run. `expected_pre_fix_failure` is provenance only and never flips
`passed` (G02 §1, F2-05 §1).

---

## 2. ATOM A — mine footprint parity (indicator extent == placed mine extent)

### 2.1 What makes it decisive

A is not a source grep and not a `stats` string. It (a) boots the **real 64² 3D
game windowed**, (b) finds a real ore deposit, (c) arms the **real build-mine
ghost** through `set_build_ghost_pos`/`_sync_build_ghost`, (d) reads the **live**
`Footprint` indicator mesh AABB × world-basis scale and the live
`GhostBuildingFinished` mesh AABB, (e) commits a real `place_building("mine", …)`,
lets `world.sync()` create the real `Building_mine_*_STATIC_POSE` node, and reads
**its** mesh AABB × world-basis scale, (f) computes both X and Z ratios, and
(g) saves a windowed GPU PNG of the indicator and a second of the placed mine.
Logic-only checks cannot pass without the real meshes being present and measured.

Every ratio is measured; the atom never hard-codes which side is larger. The
decisive assertion is parity — ratio within `[0.847, 1.18]` on **both** axes —
plus an explicit guard that the ratio is **not** in the owner's "about twice"
band `[1.70, 2.30]`. The ghost-finished-mesh → mine ratio is a **control** that
must be ~1.0 (proves the measurement method is sound and localises any mismatch
to the `Footprint` indicator).

| # | Check | Assertion | Pre-fix? |
|---|---|---|---|
| 1 | `boot_real_64_3d_game` | real main, `render_mode==3d`, MAP 64×64, `world.fx`, `capture_view3d` | no |
| 2 | `deposit_found` | real `mine_deposits` node, `max_hits==0`, offset >0 and `<4.0`, source recorded | no |
| 3 | `mine_mode_armed` | `hud.build_ghost_sid=="mine"`, peasant selected, affordable, `resolve_mine_sid=="mine_"+type` | no |
| 4 | `ghost_indicator_measured` | `BuildGhost3D` found with `Footprint` MeshInstance3D and `GhostBuildingFinished` MeshInstance3D, finite XZ spans >0 | no |
| 5 | `indicator_visible_during_placement` | `Footprint.visible == true` (currently RED per G02 check 7: B06 hides it) | **yes** |
| 6 | `png_ghost_indicator` | real windowed GPU PNG during hover, 1280×720, non-blank | no (headless skips) |
| 7 | `mine_created` | `place_building` returns a new unfinished `mine_<type>` building, count +1 | no |
| 8 | `mine_mesh_measured` | real `Building_mine_*_STATIC_POSE` node found with finite mesh XZ spans >0 | no |
| 9 | `ghost_mesh_matches_mine_mesh` | control: `ghost_building_xz / mine_xz` within band on both axes | no — control |
| 10 | **`indicator_matches_mine_mesh_ratio`** | **decisive:** `footprint_xz / mine_xz` ∈ `[RATIO_MIN, RATIO_TOL]` on both axes | **yes** — owner's parity requirement |
| 11 | **`ratio_not_about_two`** | **decisive:** neither axis ratio lies in `[1.70, 2.30]` | **yes** — owner's "about twice" |
| 12 | `png_mine_placed` | second windowed GPU PNG after commit, non-blank | no |

### 2.2 Full GDScript (PROPOSAL — verbatim, complete; DO NOT create this file)

```gdscript
# TEST-BLD-04A / t_bld_mine_footprint.gd — PROPOSAL ONLY. AUTHORED BY BLD-04, NOT CREATED.
#
# Owns ONLY (when created by COORD) this file,
# res://tests/results/t_bld_mine_footprint.json and two temp PNGs. No shared
# code/config/fixture/gate edit. No Godot job taken by the authoring agent.
# Run windowed; headless => SKIP_CAPTURE / passed=false / exit 1.
#
#   python variant3d\tools\godot_runner.py run --id bld-04-minefoot-cap1 --timeout 120 -- ^
#     --path variant3d --script res://tests/t_bld_mine_footprint.gd -- ^
#       --config <ABS>\variant3d\tests\fixtures\small_map_64.json ^
#       --screenshot <TEMP>\bld_04_minefoot\ghost_indicator.png ^
#       --placed-png <TEMP>\bld_04_minefoot\mine_placed.png
extends SceneTree

const MAIN_SCENE := "res://scenes/main.tscn"
const OUT_PATH := "res://tests/results/t_bld_mine_footprint.json"
const Data = preload("res://scripts/data.gd")

const ORE := ["gold", "iron", "coal"]
const DT := 0.25
# Parity band around 1.0 (PORT APPROX, deliberately generous but far from 2x).
const RATIO_TOL := 1.18
const RATIO_MIN := 1.0 / RATIO_TOL        # 0.8475
const TWO_LO := 1.70
const TWO_HI := 2.30

var _id := "t_bld_mine_footprint"
var _checks: Array[Dictionary] = []
var _ok := true
var _finished := false
var _stage := 0
var _stage_frames := 0
var _headless := false
var _setup_ok := false
var _capturing := false

var _cfg_arg := ""
var _hover_png_arg := ""
var _placed_png_arg := ""
var _abs_config := ""
var _hover_png := ""
var _placed_png := ""

var _main: Node = null
var _game = null
var _world = null
var _fx: Node = null
var _cam = null
var _hud = null
var _ictl = null

var _dep := {}
var _dep_pos := Vector2.ZERO
var _dep_type := ""
var _peasant = null
var _n_bld0 := 0
var _mine := {}
var _mine_id := -1

var _ghost_root: Node = null
var _footprint: MeshInstance3D = null
var _ghost_building: MeshInstance3D = null
var _foot_xz := Vector2.ZERO
var _ghost_xz := Vector2.ZERO
var _mine_xz := Vector2.ZERO
var _ratio := Vector2.ZERO
var _ghost_ratio := Vector2.ZERO

var _m: Dictionary = {}
var _img_hover: Image = null
var _img_placed: Image = null


func check(name: String, cond, detail: String = "", expected_pre_fix_failure: bool = false) -> void:
    _checks.append({
        "name": name, "passed": cond == true, "detail": detail,
        "expected_pre_fix_failure": expected_pre_fix_failure,
        "status": ("PASS" if cond == true else "FAIL"),
    })
    if cond == false:
        _ok = false
    print("TBLD-04A %s %s - %s%s" % ["PASS" if cond == true else "FAIL", name, detail,
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


func _write_result(verdict: String) -> void:
    if _finished:
        return
    _finished = true
    var passes := 0
    for c in _checks:
        if bool(c.get("passed", false)):
            passes += 1
    var cap_status := "PASS" if (_img_hover != null and _img_placed != null) else "SKIP_CAPTURE"
    var out := {
        "id": _id,
        "passed": (verdict == "PASS"),
        "verdict": verdict,
        "capture_path": (_hover_png if _img_hover != null else "SKIP_CAPTURE — no windowed GPU frame; never a visual PASS"),
        "capture_status": cap_status,
        "passes": passes,
        "total": _checks.size(),
        "checks": _checks,
        "measured": _m,
        "png_ghost_indicator": _hover_png,
        "png_mine_placed": _placed_png,
        "headless": _headless,
        "no_headless_pass": "headless never reports PASS; SKIP_CAPTURE carries passed=false",
        "runner_declaration": "COORD to run bld-04-minefoot-cap1 via variant3d/tools/godot_runner.py (status first); BLD-04 authored only, no job submitted",
        "script_error_note": "verify via variant3d/tools/smallmap_capture.py scan-stderr on runner stderr.txt",
        "parity_label": "PORT APPROX — indicator scale from world3d_fx.gd:598, mine extent from live baked mesh AABB; no donor GPU A/B frame; donor parity UNVERIFIED",
        "unix_ms": Time.get_unix_time_from_system() * 1000.0,
    }
    var abs_dir := ProjectSettings.globalize_path(OUT_PATH.get_base_dir())
    DirAccess.make_dir_recursive_absolute(abs_dir)
    var f := FileAccess.open(ProjectSettings.globalize_path(OUT_PATH), FileAccess.WRITE)
    if f != null:
        f.store_string(JSON.stringify(out, "\t"))
        f.close()
    else:
        push_error("t_bld_mine_footprint: cannot write result JSON")
    print("TBLD-04A RESULT_JSON: " + ProjectSettings.globalize_path(OUT_PATH))
    print("TBLD-04A RESULT: %s %d/%d" % [verdict, passes, _checks.size()])
    call_deferred("quit", 0 if verdict == "PASS" else 1)


func _initialize() -> void:
    _headless = DisplayServer.get_name() == "headless"
    _cfg_arg = _arg_value("--config")
    _hover_png_arg = _arg_value("--screenshot")
    _placed_png_arg = _arg_value("--placed-png")
    if _headless:
        check("headless_guard", false,
            "SKIP_CAPTURE: ghost indicator + placed mine are 3D renders; need a window; no fake PASS")
        _m["display_server"] = DisplayServer.get_name()
        _write_result("SKIPPED_HEADLESS")
        return
    if _cfg_arg == "" or _hover_png_arg == "":
        check("launch_args", false,
            "need --config <small_map_64.json> and --screenshot <ghost_indicator.png> (menu skip)")
        _write_result("ABORTED_ARGS")
        return
    _abs_config = _resolve_config(_cfg_arg)
    if _abs_config == "":
        check("launch_args", false, "config fixture not found: " + _cfg_arg)
        _write_result("ABORTED_ARGS")
        return
    _hover_png = _hover_png_arg
    _placed_png = (_placed_png_arg if _placed_png_arg != ""
        else _hover_png.get_basename() + "_placed.png")
    _m["config"] = _abs_config
    _m["display_server"] = DisplayServer.get_name()
    var packed := load(MAIN_SCENE) as PackedScene
    if packed == null:
        check("boot_real_64_3d_game", false, "cannot load " + MAIN_SCENE)
        _write_result("ABORTED_BOOT")
        return
    _main = packed.instantiate()
    root.add_child(_main)
    _goto(0)


func _find_named(n: Node, wanted: String) -> Node:
    var stack: Array[Node] = [n]
    while not stack.is_empty():
        var cur: Node = stack.pop_back()
        if cur.name == wanted:
            return cur
        for c in cur.get_children():
            stack.append(c)
    return null


func _find_prefix(n: Node, prefix: String, suffix: String) -> Node:
    var stack: Array[Node] = [n]
    while not stack.is_empty():
        var cur: Node = stack.pop_back()
        if cur.name.begins_with(prefix) and cur.name.ends_with(suffix):
            return cur
        for c in cur.get_children():
            stack.append(c)
    return null


# World XZ FULL span of a rendered MeshInstance3D: local mesh AABB × the node's
# world-basis scale. Basis rotation (mine yaw 0) does not change axis lengths.
func _xz_span(mi: MeshInstance3D) -> Vector2:
    if mi == null or mi.mesh == null:
        return Vector2.ZERO
    var aabb: AABB = mi.mesh.get_aabb()
    var sx := mi.global_transform.basis.x.length()
    var sz := mi.global_transform.basis.z.length()
    return Vector2(aabb.size.x * sx, aabb.size.z * sz)


func _configure() -> bool:
    _game = _main.get("game")
    _world = _main.get("world")
    _fx = (_world.get("fx") as Node) if _world != null else null
    _cam = _main.get("camera")
    _hud = _main.get("hud")
    _ictl = _main.get("input_ctl")
    var cv = _main.get("capture_view3d")
    var boot_ok := (_game != null and _world != null and _fx != null and _cam != null
        and _hud != null and _ictl != null and cv is SubViewport
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

    _main.set("screenshot_frames", 1000000)
    _main.set("screenshot_done", true)
    _hud.visible = true
    var ais = _main.get("ais")
    if ais is Array:
        ais.clear()           # main._process returns early; we tick/sync ourselves
    _main.set("speed", 0.0)
    _cam.set_process(false)
    _cam.edge_margin = 0.0
    _cam.corner_margin = 0.0

    # Deterministic scene: clear entities but KEEP real deposits (res_nodes).
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
                p["res"][i] = 50000.0

    # Prefer an isolated real deposit so the ghost site is unambiguous.
    var deps: Array = _game.call("mine_deposits", ORE) as Array
    var best: Dictionary = {}
    var best_sep := -1.0
    var half := Vector2(float(_game.get("MAP_W")), float(_game.get("MAP_H"))) * Data.TILE_M * 0.5
    for d in deps:
        var dd: Dictionary = d as Dictionary
        var p: Vector2 = dd.get("pos", Vector2.ZERO)
        if not bool(_game.call("in_bounds", p)):
            continue
        var sep := INF
        for o in deps:
            var od: Dictionary = o as Dictionary
            if int(od.get("id", -1)) == int(dd.get("id", -2)):
                continue
            sep = minf(sep, p.distance_to(od.get("pos", Vector2.ZERO)))
        var score: float = (sep if is_finite(sep) else 999.0) - p.distance_to(half) * 0.01
        if score > best_sep:
            best_sep = score
            best = dd
    var dep_source := "mapgen"
    if best.is_empty():
        var fp := half + Vector2(10.0, 0.0)
        _game.call("_add_res", "gold", fp, 0, 0.0)
        deps = _game.call("mine_deposits", ORE) as Array
        for d in deps:
            var dd: Dictionary = d as Dictionary
            if Vector2(dd.get("pos", Vector2.ZERO)).is_equal_approx(fp):
                best = dd
                break
        dep_source = "harness_fixture"
    _dep = best
    _dep_pos = Vector2(_dep.get("pos", Vector2.ZERO))
    _dep_type = str(_dep.get("type", ""))
    _m["deposit_source"] = dep_source
    _m["deposit_pos_sim"] = [_dep_pos.x, _dep_pos.y]
    _m["deposit_type"] = _dep_type
    check("deposit_found", not _dep.is_empty() and ORE.has(_dep_type)
        and bool(_game.call("in_bounds", _dep_pos)),
        "deposit=%s pos=%s type=%s" % [dep_source, str(_dep_pos), _dep_type])
    if _dep.is_empty():
        return false

    _cam.call("jump_to_world", _dep_pos)
    _peasant = _game.call("spawn", "peasant", 0, _dep_pos + Vector2(-5.0, -4.0))
    for e in _game.entities:
        e["selected"] = (int(e.id) == int(_peasant.id))
    _hud.build_ghost_sid = "mine"
    _ictl.call("_set_selection", [_peasant])
    var rsid := str(_game.call("resolve_mine_sid", "mine", _dep_pos))
    _n_bld0 = (_game.call("buildings_of", 0, false) as Array).size()
    _m["resolved_sid"] = rsid
    check("mine_mode_armed", str(_hud.build_ghost_sid) == "mine" and _peasant != null
        and bool(_game.call("can_afford", 0, "mine", _dep_pos)) and rsid == "mine_" + _dep_type,
        "sid=%s resolved=%s want=mine_%s peasant=%s affordable=%s" % [
        str(_hud.build_ghost_sid), rsid, _dep_type, str(_peasant != null),
        str(_game.call("can_afford", 0, "mine", _dep_pos))])
    _setup_ok = true
    return true


func _apply_hover() -> void:
    _world.call("set_build_ghost_pos", _dep_pos)
    _world.call("_sync_build_ghost")
    if _fx.has_method("_update_ghost"):
        _fx.call("_update_ghost")


func _measure_indicator() -> void:
    _ghost_root = _find_named(_fx, "BuildGhost3D")
    _footprint = (_find_named(_ghost_root, "Footprint") as MeshInstance3D) if _ghost_root != null else null
    _ghost_building = (_find_named(_ghost_root, "GhostBuildingFinished") as MeshInstance3D) if _ghost_root != null else null
    _foot_xz = _xz_span(_footprint)
    _ghost_xz = _xz_span(_ghost_building)
    _m["footprint_xz_span_m"] = [snappedf(_foot_xz.x, 4), snappedf(_foot_xz.y, 4)]
    _m["ghost_building_xz_span_m"] = [snappedf(_ghost_xz.x, 4), snappedf(_ghost_xz.y, 4)]
    _m["footprint_scale"] = (str(_footprint.scale) if _footprint != null else "none")
    _m["footprint_visible"] = (_footprint.visible if _footprint != null else false)
    var gm: Dictionary = {}
    if _footprint != null and _footprint.mesh is BoxMesh:
        gm["local_box"] = str((_footprint.mesh as BoxMesh).size)
    _m["footprint_mesh"] = gm
    check("ghost_indicator_measured", _footprint != null and _ghost_building != null
        and _foot_xz.x > 0.0 and _foot_xz.y > 0.0 and _ghost_xz.x > 0.0 and _ghost_xz.y > 0.0,
        "footprint=%s ghost_building=%s (world XZ spans, metres)" % [
        str(_foot_xz), str(_ghost_xz)])
    # Strict visibility requirement retained from G02 check 7 — do NOT drop.
    check("indicator_visible_during_placement", _footprint != null and _footprint.visible,
        "Footprint.visible=%s (B06 hides it when art resolves; expected RED pre-fix)" % [
        str(_footprint != null and _footprint.visible)], true)


func _place_mine() -> void:
    var made: Dictionary = _game.call("place_building", 0, "mine", _dep_pos, true, [_peasant])
    _mine = made
    _mine_id = int(made.get("id", -1))
    var after: Array = _game.call("buildings_of", 0, false) as Array
    _m["mine_pos_sim"] = [Vector2(made.get("pos", Vector2.ZERO)).x,
        Vector2(made.get("pos", Vector2.ZERO)).y]
    check("mine_created", not made.is_empty() and after.size() == _n_bld0 + 1
        and bool(made.get("finished", true)) == false
        and str(made.get("sid", "")).begins_with("mine_"),
        "sid=%s finished=%s count=%d->%d" % [str(made.get("sid", "")),
        str(made.get("finished", "?")), _n_bld0, after.size()])


func _measure_mine_mesh() -> void:
    # world.sync() in the staging frame creates the real rendered node.
    var mi := _find_prefix(_world, "Building_mine_", "_STATIC_POSE") as MeshInstance3D
    _mine_xz = _xz_span(mi)
    _m["mine_mesh_xz_span_m"] = [snappedf(_mine_xz.x, 4), snappedf(_mine_xz.y, 4)]
    _m["mine_mesh_name"] = (mi.name if mi != null else "none")
    _m["mine_mesh_source"] = (str(mi.get_meta("mesh_source", "?")) if mi != null else "?")
    check("mine_mesh_measured", mi != null and _mine_xz.x > 0.0 and _mine_xz.y > 0.0,
        "node=%s XZ=%s (live baked mesh AABB × world basis)" % [
        (mi.name if mi != null else "none"), str(_mine_xz)])
    if mi == null:
        return

    if _ghost_xz.x > 0.0 and _ghost_xz.y > 0.0:
        _ghost_ratio = Vector2(_ghost_xz.x / _mine_xz.x, _ghost_xz.y / _mine_xz.y)
    _m["ghost_mesh_to_mine_ratio"] = [snappedf(_ghost_ratio.x, 4), snappedf(_ghost_ratio.y, 4)]
    var ctrl := _in_band(_ghost_ratio.x) and _in_band(_ghost_ratio.y)
    check("ghost_mesh_matches_mine_mesh", ctrl,
        "ghost_building/mine X=%.4f Z=%.4f band=[%.4f,%.4f] (control — proves measurement sound)" % [
        _ghost_ratio.x, _ghost_ratio.y, RATIO_MIN, RATIO_TOL])

    _ratio = Vector2(_foot_xz.x / _mine_xz.x, _foot_xz.y / _mine_xz.y)
    _m["indicator_to_mine_ratio"] = [snappedf(_ratio.x, 4), snappedf(_ratio.y, 4)]
    _m["ratio_band"] = [snappedf(RATIO_MIN, 4), RATIO_TOL]
    check("indicator_matches_mine_mesh_ratio", _in_band(_ratio.x) and _in_band(_ratio.y),
        "footprint/mine X=%.4f Z=%.4f want in [%.4f,%.4f] (PORT APPROX, owner parity)" % [
        _ratio.x, _ratio.y, RATIO_MIN, RATIO_TOL], true)
    var two_x := _ratio.x >= TWO_LO and _ratio.x <= TWO_HI
    var two_z := _ratio.y >= TWO_LO and _ratio.y <= TWO_HI
    _m["ratio_in_about_two_band"] = [two_x, two_z]
    check("ratio_not_about_two", not two_x and not two_z,
        "X=%.4f Z=%.4f must be outside [%.2f,%.2f] (owner: 'now about twice')" % [
        _ratio.x, _ratio.y, TWO_LO, TWO_HI], true)


func _in_band(r: float) -> bool:
    return is_finite(r) and r >= RATIO_MIN and r <= RATIO_TOL


func _capture_async(path: String, is_hover: bool) -> void:
    _capturing = true
    var cv := _main.get("capture_view3d") as SubViewport
    var key := "png_ghost_indicator" if is_hover else "png_mine_placed"
    if cv == null or not is_instance_valid(cv):
        check(key, false, "main.capture_view3d missing (windowed --screenshot boot required)")
        _capturing = false
        return
    cv.render_target_update_mode = SubViewport.UPDATE_ONCE
    var tex := cv.get_texture()
    if tex == null:
        check(key, false, "null Screenshot3DViewport texture")
        _capturing = false
        return
    await RenderingServer.frame_post_draw
    if _finished:
        return
    var img: Image = tex.get_image()
    if img == null or img.is_empty():
        check(key, false, "blank SubViewport image — no CPU fallback (main.gd:1906-1913)")
        _capturing = false
        return
    var dir := path.get_base_dir()
    if dir != "" and not DirAccess.dir_exists_absolute(dir):
        DirAccess.make_dir_recursive_absolute(dir)
    var err := img.save_png(path)
    var nb := 0
    var n := 0
    for y in range(0, img.get_height(), 4):
        for x in range(0, img.get_width(), 4):
            var c := img.get_pixel(x, y)
            if c.r > 8.0 / 255.0 or c.g > 8.0 / 255.0 or c.b > 8.0 / 255.0:
                nb += 1
            n += 1
    var frac := float(nb) / float(maxi(n, 1))
    var mk := "png_hover_metrics" if is_hover else "png_placed_metrics"
    _m[mk] = {"path": path, "w": img.get_width(), "h": img.get_height(),
        "non_black_fraction": snappedf(frac, 4), "err": err}
    if is_hover:
        _img_hover = img
    else:
        _img_placed = img
    check(key, err == OK and img.get_width() == 1280 and img.get_height() == 720
        and frac > 0.5,
        "saved real windowed GPU frame %dx%d err=%d non_black=%.3f" % [
        img.get_width(), img.get_height(), err, frac])
    _capturing = false


func _process(_dt: float) -> bool:
    if _finished or _capturing:
        return false
    _stage_frames += 1
    match _stage:
        0:
            if _stage_frames >= 4:
                if not _configure():
                    _write_result("ABORTED_SETUP")
                else:
                    _goto(1)
        1:
            if _stage_frames >= 3:
                _apply_hover()
                _measure_indicator()
                _capture_async(_hover_png, true)
                _goto(2)
        2:
            # Drive sim + presentation ourselves (main returned early: ais empty).
            _game.call("tick", DT)
            _world.call("sync", DT)
            if _stage_frames >= 4:
                _place_mine()
                _goto(3)
        3:
            _game.call("tick", DT)
            _world.call("sync", DT)
            if _stage_frames >= 4:
                _measure_mine_mesh()
                _capture_async(_placed_png, false)
                _goto(4)
        4:
            if _stage_frames >= 3:
                _write_result("PASS" if _ok else "FAIL")
    return false
```

### 2.3 Exact runner command (COORD only — unique id; windowed)

Check the FIFO first (`godot_runner.py:25-33,384-437,488-509`):

```powershell
python variant3d\tools\godot_runner.py status
```

Proceed only if the lock is free. From the project root, one PowerShell-safe
line (`python`, never `python3`; no `&&`; **no `--headless`**; unique id):

```powershell
python variant3d\tools\godot_runner.py run --id bld-04-minefoot-cap1 --timeout 120 -- --path variant3d --script res://tests/t_bld_mine_footprint.gd -- --config "C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\variant3d\tests\fixtures\small_map_64.json" --screenshot "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\bld_04_minefoot\ghost_indicator.png" --placed-png "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\bld_04_minefoot\mine_placed.png"
```

- Refresh the id (`-cap2`, …) if it already exists in
  `variant3d\.godot_queue\results\`. Result JSON:
  `variant3d\tests\results\t_bld_mine_footprint.json`; envelope/stderr under
  `variant3d\.godot_queue\results\<ticket>_bld-04-minefoot-cap1\`.
- Read-only after the run (no Godot):
  `python variant3d\tools\smallmap_capture.py stats "<TEMP>\bld_04_minefoot\ghost_indicator.png" "<TEMP>\bld_04_minefoot\mine_placed.png"`
  and `python variant3d\tools\smallmap_capture.py scan-stderr "<runner-results>\...\stderr.txt"`.
- **Headless variant** (never accepted as a visual PASS): add `--headless`
  before the first `--`; atom writes `capture_path="SKIP_CAPTURE ..."`,
  `capture_status="SKIP_CAPTURE"`, `passed=false`, `verdict=SKIPPED_HEADLESS`,
  exit 1, **no PNG**.

### 2.4 Acceptance criteria (Atom A)

| # | Criterion | Evidence | Verdict rule |
|---|---|---|---|
| 1 | Envelope `status=ok`, `exit=0`, argv has **no** `--headless` | `000NNNNN.json` | mandatory |
| 2 | `SCRIPT ERROR` count 0 | `scan-stderr` | mandatory |
| 3 | `run_mode` windowed, `headless=false`, `render_mode=3d`, MAP 64×64 | result JSON | mandatory |
| 4 | Checks 1-4, 7-8 true: real 64² boot, real deposit, mine mode, ghost indicator and placed mine meshes measured | result JSON | mandatory |
| 5 | Both PNGs exist, 1280×720, non-blank (>0.5) | `stats` + `*_metrics` | mandatory; missing → `UNVERIFIED (NO PNG)`, never PASS |
| 6 | **Decisive:** `indicator_matches_mine_mesh_ratio=true` — X and Z ratio each in `[0.847, 1.18]` | JSON check 10 + `measured.indicator_to_mine_ratio` | decisive |
| 7 | **Decisive:** `ratio_not_about_two=true` — neither axis in `[1.70, 2.30]` | JSON check 11 | decisive |
| 8 | **Control:** `ghost_mesh_matches_mine_mesh=true` (ghost finished mesh == placed mine; measurement is sound) | JSON check 9 | mandatory |
| 9 | `indicator_visible_during_placement` may be RED (G02 check 7 provenance); a fix should turn it GREEN with correct size | JSON check 5 | provenance, never weakening |
| 10 | Human reads PNGs: green footprint square matches the mine's on-screen size; placed mine visible | two PNGs | decisive (visual) |
| 11 | `expected_pre_fix_failure` only on checks 5/10/11; no threshold lowered, no assertion deleted | source diff vs this proposal | mandatory |
| 12 | No donor-parity claim; verdict labelled PORT APPROX / UNVERIFIED | report + JSON label | mandatory |

Overall PASS = 1-12. Pre-fix RED on check 10 (and possibly 5/11) is the
**expected baseline**, not a test defect. The ratio direction is UNVERIFIED
until run; the atom does not assume which side is larger.

---

## 3. ATOM B — builder trapping (every builder outside footprint, build finishes)

### 3.1 What makes it decisive

B boots the **real 64² 3D game windowed**, finds a real deposit, places a real
mine with **four** real peasants sent through `place_building(..., builders)`,
then drives the sim one fixed step per atom frame (`game.tick(DT)` +
`world.sync(DT)`), **sampling every builder's SIM position before AND after
each tick for N frames**. Every sample is tested against the live site's
`block_r` circle and (if present) `block_rect`. The atom asserts (i) zero
intrusions, (ii) progress never decreases, (iii) `finished==true` with
`progress >= build_time` inside the frame budget, and (iv) at completion every
builder still rings the building within a near band. A windowed GPU PNG records
the builders around the finished mine. Logic-only checks cannot pass without a
real finished building in the render.

| # | Check | Assertion | Pre-fix? |
|---|---|---|---|
| 1 | `boot_real_64_3d_game` | real main, `3d`, 64×64, `world.fx`, `capture_view3d`, `entities` | no |
| 2 | `deposit_found` | real ore deposit, source recorded | no |
| 3 | `construction_started` | new unfinished `mine_<type>` site, `block_r>0`, ≥4 builders, each order `build` targeting site | no |
| 4 | **`builders_never_inside_footprint`** | **decisive:** zero samples with `dist(site) < block_r - 0.05` or inside `block_rect` (grown by eps), across all builders × all frames × pre/post tick | **yes** — owner's trap |
| 5 | `progress_monotonic` | no sampled `progress < previous - 1e-4` | no |
| 6 | **`construction_reached_100pct`** | **decisive:** `site.finished==true` and `progress >= build_time - 1e-3` within N frames | **yes** — "construction finishes" |
| 7 | `builders_around_finished` | at finish each builder `block_r - eps <= dist <= block_r + 8 m` (ring the building, not trapped inside / lost) | no |
| 8 | `png_builders_finished` | real windowed GPU PNG, 1280×720, non-blank | no (headless skips) |

`N = 400` frames at `DT = 0.25 s` = 100 sim s, far above the 9.375 s mine
build time; the loop breaks at finish. `FOOT_EPS = 0.05 m` is sampling tolerance,
not a weakened predicate — the work ring sits ≥0.7 m outside `block_r`
(`game.gd:5191`).

### 3.2 Full GDScript (PROPOSAL — verbatim, complete; DO NOT create this file)

```gdscript
# TEST-BLD-04B / t_bld_builder_trap.gd — PROPOSAL ONLY. AUTHORED BY BLD-04, NOT CREATED.
#
# Owns ONLY (when created by COORD) this file,
# res://tests/results/t_bld_builder_trap.json and one temp PNG. No shared
# code/config/fixture/gate edit. No Godot job taken by the authoring agent.
# Run windowed; headless => SKIP_CAPTURE / passed=false / exit 1.
#
#   python variant3d\tools\godot_runner.py run --id bld-04-buildertrap-cap1 --timeout 150 -- ^
#     --path variant3d --script res://tests/t_bld_builder_trap.gd -- ^
#       --config <ABS>\variant3d\tests\fixtures\small_map_64.json ^
#       --screenshot <TEMP>\bld_04_buildertrap\builders_finished.png
extends SceneTree

const MAIN_SCENE := "res://scenes/main.tscn"
const OUT_PATH := "res://tests/results/t_bld_builder_trap.json"
const Data = preload("res://scripts/data.gd")

const ORE := ["gold", "iron", "coal"]
const DT := 0.25
const N_FRAMES := 400
const FOOT_EPS := 0.05
const NEAR_BAND := 8.0
const N_BUILDERS := 4

var _id := "t_bld_builder_trap"
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
var _abs_config := ""
var _png_path := ""

var _main: Node = null
var _game = null
var _world = null
var _fx: Node = null
var _cam = null
var _hud = null

var _dep := {}
var _dep_pos := Vector2.ZERO
var _dep_type := ""
var _site := {}
var _site_id := -1
var _site_pos := Vector2.ZERO
var _block_r := 0.0
var _block_rect := Rect2()
var _builders: Array = []
var _build_ids: Array[int] = []
var _finish_frame := -1

var _samples := 0
var _violations: Array[Dictionary] = []
var _min_dist := INF
var _max_dist_seen := 0.0
var _prev_progress := -1.0
var _progress_regressions := 0
var _traj: Array = []
var _final_dists: Array = []

var _m: Dictionary = {}
var _img: Image = null


func check(name: String, cond, detail: String = "", expected_pre_fix_failure: bool = false) -> void:
    _checks.append({
        "name": name, "passed": cond == true, "detail": detail,
        "expected_pre_fix_failure": expected_pre_fix_failure,
        "status": ("PASS" if cond == true else "FAIL"),
    })
    if cond == false:
        _ok = false
    print("TBLD-04B %s %s - %s%s" % ["PASS" if cond == true else "FAIL", name, detail,
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


func _write_result(verdict: String) -> void:
    if _finished:
        return
    _finished = true
    var passes := 0
    for c in _checks:
        if bool(c.get("passed", false)):
            passes += 1
    var out := {
        "id": _id,
        "passed": (verdict == "PASS"),
        "verdict": verdict,
        "capture_path": (_png_path if _img != null else "SKIP_CAPTURE — no windowed GPU frame; never a visual PASS"),
        "capture_status": ("PASS" if _img != null else "SKIP_CAPTURE"),
        "passes": passes,
        "total": _checks.size(),
        "checks": _checks,
        "measured": _m,
        "png_builders_finished": _png_path,
        "headless": _headless,
        "no_headless_pass": "headless never reports PASS; SKIP_CAPTURE carries passed=false",
        "runner_declaration": "COORD to run bld-04-buildertrap-cap1 via variant3d/tools/godot_runner.py (status first); BLD-04 authored only, no job submitted",
        "script_error_note": "verify via variant3d/tools/smallmap_capture.py scan-stderr on runner stderr.txt",
        "parity_label": "PORT APPROX — builder work ring from game.gd:5191 (PORT constant); no donor GPU A/B frame; donor parity UNVERIFIED",
        "unix_ms": Time.get_unix_time_from_system() * 1000.0,
    }
    var abs_dir := ProjectSettings.globalize_path(OUT_PATH.get_base_dir())
    DirAccess.make_dir_recursive_absolute(abs_dir)
    var f := FileAccess.open(ProjectSettings.globalize_path(OUT_PATH), FileAccess.WRITE)
    if f != null:
        f.store_string(JSON.stringify(out, "\t"))
        f.close()
    else:
        push_error("t_bld_builder_trap: cannot write result JSON")
    print("TBLD-04B RESULT_JSON: " + ProjectSettings.globalize_path(OUT_PATH))
    print("TBLD-04B RESULT: %s %d/%d" % [verdict, passes, _checks.size()])
    call_deferred("quit", 0 if verdict == "PASS" else 1)


func _initialize() -> void:
    _headless = DisplayServer.get_name() == "headless"
    _cfg_arg = _arg_value("--config")
    _png_arg = _arg_value("--screenshot")
    if _headless:
        check("headless_guard", false,
            "SKIP_CAPTURE: builders around a finished 3D building need a window; no fake PASS")
        _m["display_server"] = DisplayServer.get_name()
        _write_result("SKIPPED_HEADLESS")
        return
    if _cfg_arg == "" or _png_arg == "":
        check("launch_args", false,
            "need --config <small_map_64.json> and --screenshot <builders_finished.png> (menu skip)")
        _write_result("ABORTED_ARGS")
        return
    _abs_config = _resolve_config(_cfg_arg)
    if _abs_config == "":
        check("launch_args", false, "config fixture not found: " + _cfg_arg)
        _write_result("ABORTED_ARGS")
        return
    _png_path = _png_arg
    _m["config"] = _abs_config
    _m["display_server"] = DisplayServer.get_name()
    var packed := load(MAIN_SCENE) as PackedScene
    if packed == null:
        check("boot_real_64_3d_game", false, "cannot load " + MAIN_SCENE)
        _write_result("ABORTED_BOOT")
        return
    _main = packed.instantiate()
    root.add_child(_main)
    _goto(0)


func _configure() -> bool:
    _game = _main.get("game")
    _world = _main.get("world")
    _fx = (_world.get("fx") as Node) if _world != null else null
    _cam = _main.get("camera")
    _hud = _main.get("hud")
    var cv = _main.get("capture_view3d")
    var boot_ok := (_game != null and _world != null and _fx != null and _cam != null
        and _hud != null and cv is SubViewport
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

    _main.set("screenshot_frames", 1000000)
    _main.set("screenshot_done", true)
    _hud.visible = true
    var ais = _main.get("ais")
    if ais is Array:
        ais.clear()           # main returns early; we tick + sync deterministically
    _main.set("speed", 0.0)
    _cam.set_process(false)
    _cam.edge_margin = 0.0
    _cam.corner_margin = 0.0

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
                p["res"][i] = 50000.0

    var deps: Array = _game.call("mine_deposits", ORE) as Array
    var best: Dictionary = {}
    var half := Vector2(float(_game.get("MAP_W")), float(_game.get("MAP_H"))) * Data.TILE_M * 0.5
    for d in deps:
        var dd: Dictionary = d as Dictionary
        if not bool(_game.call("in_bounds", Vector2(dd.get("pos", Vector2.ZERO)))):
            continue
        best = dd
        break
    var dep_source := "mapgen"
    if best.is_empty():
        var fp := half + Vector2(10.0, 0.0)
        _game.call("_add_res", "gold", fp, 0, 0.0)
        deps = _game.call("mine_deposits", ORE) as Array
        for d in deps:
            var dd: Dictionary = d as Dictionary
            if Vector2(dd.get("pos", Vector2.ZERO)).is_equal_approx(fp):
                best = dd
                break
        dep_source = "harness_fixture"
    _dep = best
    _dep_pos = Vector2(_dep.get("pos", Vector2.ZERO))
    _dep_type = str(_dep.get("type", ""))
    _m["deposit_source"] = dep_source
    _m["deposit_pos_sim"] = [_dep_pos.x, _dep_pos.y]
    check("deposit_found", not _dep.is_empty() and ORE.has(_dep_type),
        "deposit=%s pos=%s type=%s" % [dep_source, str(_dep_pos), _dep_type])
    if _dep.is_empty():
        return false

    _cam.call("jump_to_world", _dep_pos)
    # Four peasants around the deposit: near + far, so pathing must go around.
    var offsets := [Vector2(6.0, 0.0), Vector2(0.0, 6.0),
        Vector2(-6.0, 0.0), Vector2(0.0, -6.0)]
    for i in range(N_BUILDERS):
        var want := _dep_pos + offsets[i]
        if bool(_game.call("is_blocked", want)) or not bool(_game.call("in_bounds", want)):
            want = _game.call("_snap_free_point", want,
                {"kind": "unit", "def": {"radius": 0.4}})
        var u: Dictionary = _game.call("spawn", "peasant", 0, want)
        if int(u.get("id", -1)) > 0:
            _builders.append(u)
            _build_ids.append(int(u["id"]))
    var made: Dictionary = _game.call("place_building", 0, "mine", _dep_pos, true, _builders)
    _site = made
    _site_id = int(made.get("id", -1))
    _site_pos = Vector2(made.get("pos", _dep_pos))
    _block_r = maxf(0.25, float(made.get("block_r", (made.get("def", {}) as Dictionary).get("radius", 1.6))))
    _block_rect = made.get("block_rect", Rect2())
    _m["site_sid"] = str(made.get("sid", ""))
    _m["site_pos_sim"] = [_site_pos.x, _site_pos.y]
    _m["block_r_m"] = snappedf(_block_r, 4)
    _m["block_rect"] = str(_block_rect)
    _m["builders_spawned"] = _build_ids.size()

    var orders_ok := 0
    for u in _builders:
        var o: Dictionary = u.get("order", {})
        if str(o.get("type", "")) == "build" and int(o.get("target", -1)) == _site_id:
            orders_ok += 1
    check("construction_started", not made.is_empty() and _site_id > 0
        and bool(made.get("finished", true)) == false and _block_r > 0.0
        and orders_ok == _builders.size() and _builders.size() >= N_BUILDERS,
        "sid=%s id=%d unfinished=%s block_r=%.2f builders=%d build_orders=%d" % [
        str(made.get("sid", "")), _site_id, str(bool(made.get("finished", true)) == false),
        _block_r, _builders.size(), orders_ok])
    if made.is_empty() or _site_id <= 0 or _builders.is_empty():
        return false
    _setup_ok = true
    return true


func _inside_footprint(p: Vector2) -> bool:
    if p.distance_to(_site_pos) < _block_r - FOOT_EPS:
        return true
    if _block_rect.size.x > 0.0 and _block_rect.size.y > 0.0:
        if _block_rect.grow(FOOT_EPS).has_point(p):
            return true
    return false


# Sample every live builder ONCE at a given instant; record intrusions/distances.
func _sample_builders(phase: String) -> void:
    for u in _builders:
        var id := int(u.get("id", -1))
        if bool(u.get("dead", false)):
            continue
        var p: Vector2 = Vector2(u.get("pos", Vector2.ZERO))
        var d: float = p.distance_to(_site_pos)
        _samples += 1
        if d < _min_dist:
            _min_dist = d
        if d > _max_dist_seen:
            _max_dist_seen = d
        if _inside_footprint(p):
            _violations.append({
                "frame": _stage_frames, "phase": phase, "builder": id,
                "pos": [snappedf(p.x, 3), snappedf(p.y, 3)],
                "dist": snappedf(d, 3), "block_r": snappedf(_block_r, 3),
            })


func _record_progress() -> void:
    var prog := float(_site.get("progress", 0.0))
    if _prev_progress >= 0.0 and prog < _prev_progress - 0.0001:
        _progress_regressions += 1
    _prev_progress = prog
    if _traj.size() < 60 and (_stage_frames % 10 == 0 or bool(_site.get("finished", false))):
        _traj.append({"frame": _stage_frames, "t": snappedf(float(_stage_frames) * DT, 3),
            "progress": snappedf(prog, 3),
            "pct": snappedf(prog / maxf(0.001, float(_site.get("def", {}).get("build_time", 1.0))) * 100.0, 2),
            "finished": bool(_site.get("finished", false))})


func _assert_builder_safety() -> void:
    _m["samples"] = _samples
    _m["violations"] = _violations.size()
    _m["violation_examples"] = _violations.slice(0, 12)
    _m["min_builder_dist_to_site_m"] = (snappedf(_min_dist, 4) if is_finite(_min_dist) else -1.0)
    _m["max_builder_dist_to_site_m"] = snappedf(_max_dist_seen, 4)
    check("builders_never_inside_footprint", _violations.is_empty() and _samples > 0,
        "samples=%d violations=%d min_dist=%.3f m block_r=%.3f m (PORT ring >= r+0.7)" % [
        _samples, _violations.size(),
        (_min_dist if is_finite(_min_dist) else -1.0), _block_r], true)


func _assert_completion() -> void:
    var bt := float((_site.get("def", {}) as Dictionary).get("build_time", 1.0))
    var prog := float(_site.get("progress", 0.0))
    var fin := bool(_site.get("finished", false))
    _m["finish_frame"] = _finish_frame
    _m["finish_sim_seconds"] = (snappedf(float(_finish_frame) * DT, 3) if _finish_frame >= 0 else -1.0)
    _m["final_progress"] = snappedf(prog, 4)
    _m["build_time"] = snappedf(bt, 4)
    _m["progress_regressions"] = _progress_regressions
    _m["trajectory"] = _traj
    check("progress_monotonic", _progress_regressions == 0,
        "regressions=%d over %d frames" % [_progress_regressions, _stage_frames])
    check("construction_reached_100pct", fin and prog >= bt - 0.001 and _finish_frame >= 0,
        "finished=%s progress=%.4f/%.4f frame=%d (N=%d, DT=%.2f)" % [
        str(fin), prog, bt, _finish_frame, N_FRAMES, DT], true)

    _final_dists.clear()
    var near_ok := true
    for u in _builders:
        if bool(u.get("dead", false)):
            near_ok = false
            continue
        var d: float = Vector2(u.get("pos", Vector2.ZERO)).distance_to(_site_pos)
        _final_dists.append(snappedf(d, 3))
        if d < _block_r - FOOT_EPS or d > _block_r + NEAR_BAND:
            near_ok = false
    _m["final_builder_distances_m"] = _final_dists
    check("builders_around_finished", near_ok and _final_dists.size() == _builders.size(),
        "distances=%s band=[%.2f, %.2f] m" % [str(_final_dists), _block_r - FOOT_EPS,
        _block_r + NEAR_BAND])


func _capture_async(path: String) -> void:
    _capturing = true
    var cv := _main.get("capture_view3d") as SubViewport
    if cv == null or not is_instance_valid(cv):
        check("png_builders_finished", false, "main.capture_view3d missing (windowed --screenshot boot required)")
        _capturing = false
        return
    cv.render_target_update_mode = SubViewport.UPDATE_ONCE
    var tex := cv.get_texture()
    if tex == null:
        check("png_builders_finished", false, "null Screenshot3DViewport texture")
        _capturing = false
        return
    await RenderingServer.frame_post_draw
    if _finished:
        return
    var img: Image = tex.get_image()
    if img == null or img.is_empty():
        check("png_builders_finished", false,
            "blank SubViewport image — no CPU fallback (main.gd:1906-1913)")
        _capturing = false
        return
    var dir := path.get_base_dir()
    if dir != "" and not DirAccess.dir_exists_absolute(dir):
        DirAccess.make_dir_recursive_absolute(dir)
    var err := img.save_png(path)
    var nb := 0
    var n := 0
    for y in range(0, img.get_height(), 4):
        for x in range(0, img.get_width(), 4):
            var c := img.get_pixel(x, y)
            if c.r > 8.0 / 255.0 or c.g > 8.0 / 255.0 or c.b > 8.0 / 255.0:
                nb += 1
            n += 1
    var frac := float(nb) / float(maxi(n, 1))
    _m["png_metrics"] = {"path": path, "w": img.get_width(), "h": img.get_height(),
        "non_black_fraction": snappedf(frac, 4), "err": err}
    _img = img
    check("png_builders_finished", err == OK and img.get_width() == 1280
        and img.get_height() == 720 and frac > 0.5,
        "saved real windowed GPU frame %dx%d err=%d non_black=%.3f" % [
        img.get_width(), img.get_height(), err, frac])
    _capturing = false


func _process(_dt: float) -> bool:
    if _finished or _capturing:
        return false
    _stage_frames += 1
    match _stage:
        0:
            if _stage_frames >= 4:
                if not _configure():
                    _write_result("ABORTED_SETUP")
                else:
                    _goto(1)
        1:
            # One fixed sim step + presentation sync per atom frame.
            _sample_builders("pre_tick")
            _game.call("tick", DT)
            _sample_builders("post_tick")
            _world.call("sync", DT)
            _record_progress()
            if bool(_site.get("finished", false)) and _finish_frame < 0:
                _finish_frame = _stage_frames
            if _finish_frame >= 0 or _stage_frames >= N_FRAMES:
                _assert_builder_safety()
                _assert_completion()
                _cam.call("jump_to_world", _site_pos)
                _goto(2)
        2:
            _world.call("sync", DT)
            if _stage_frames >= 4:
                _capture_async(_png_path)
                _goto(3)
        3:
            if _stage_frames >= 3:
                _write_result("PASS" if _ok else "FAIL")
    return false
```

### 3.3 Exact runner command (COORD only — unique id; windowed)

```powershell
python variant3d\tools\godot_runner.py status
```

```powershell
python variant3d\tools\godot_runner.py run --id bld-04-buildertrap-cap1 --timeout 150 -- --path variant3d --script res://tests/t_bld_builder_trap.gd -- --config "C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\variant3d\tests\fixtures\small_map_64.json" --screenshot "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\bld_04_buildertrap\builders_finished.png"
```

- Refresh the id (`-cap2`, …) if it already exists in
  `variant3d\.godot_queue\results\`. Result JSON:
  `variant3d\tests\results\t_bld_builder_trap.json`; envelope under
  `variant3d\.godot_queue\results\<ticket>_bld-04-buildertrap-cap1\`.
- Read-only after the run:
  `python variant3d\tools\smallmap_capture.py stats "<TEMP>\bld_04_buildertrap\builders_finished.png"`
  and `python variant3d\tools\smallmap_capture.py scan-stderr "<runner-results>\...\stderr.txt"`.
- **Headless variant:** add `--headless` before the first `--`; atom writes
  `capture_path="SKIP_CAPTURE ..."`, `capture_status="SKIP_CAPTURE"`,
  `passed=false`, `verdict=SKIPPED_HEADLESS`, exit 1, **no PNG**.

### 3.4 Acceptance criteria (Atom B)

| # | Criterion | Evidence | Verdict rule |
|---|---|---|---|
| 1 | Envelope `status=ok`, `exit=0`, argv has **no** `--headless` | `000NNNNN.json` | mandatory |
| 2 | `SCRIPT ERROR` count 0 | `scan-stderr` | mandatory |
| 3 | `run_mode` windowed, `headless=false`, `render_mode=3d`, 64×64 | result JSON | mandatory |
| 4 | Check 3 true: real unfinished mine, `block_r>0`, 4 builders each with `build` order on the site | JSON check 3 | mandatory |
| 5 | PNG exists, 1280×720, non-blank (>0.5) | `stats` + `png_metrics` | mandatory; missing → `UNVERIFIED (NO PNG)` |
| 6 | **Decisive:** `builders_never_inside_footprint=true`, `violations=0`, samples > 0 | JSON check 4 + `measured.violation_examples` | decisive |
| 7 | **Decisive:** `construction_reached_100pct=true`, `finished=true`, `progress>=build_time`, frame ≤ 400 | JSON check 6 + `measured.finish_frame` | decisive |
| 8 | `progress_monotonic=true` and `builders_around_finished=true` (all builders in `[r-0.05, r+8] m`) | JSON checks 5/7 | mandatory |
| 9 | Human reads PNG: finished mine with builder peasants visibly ringing it outside the walls | PNG | decisive (visual) |
| 10 | `expected_pre_fix_failure` only on checks 4/6; no threshold lowered, no assertion deleted | source diff vs this proposal | mandatory |
| 11 | No donor-parity claim; verdict labelled PORT APPROX / UNVERIFIED | report + JSON label | mandatory |

Overall PASS = 1-11. A pre-fix RED on check 4 (intrusion) or check 6 (stall)
is the **expected baseline**, not a test defect. Check 6 failing while check 4
passes is still a decisive finding (builders outside but construction stalls).

---

## 4. Verdict semantics (both atoms)

| Situation | `verdict` | `passed` | exit | PNG |
|---|---|---|---|---|
| All checks true, windowed PNG(s) saved | `PASS` | true | 0 | yes |
| Any evaluated check false (pre-fix expected failures marked) | `FAIL` | false | 1 | yes if reached |
| Headless launch | `SKIPPED_HEADLESS` | false | 1 | **none**; `capture_path="SKIP_CAPTURE ..."` |
| Bad args / boot / setup | `ABORTED_*` | false | 1 | none |

`passed` is computed solely as `(verdict == "PASS")`; a skip or abort can never
be reported as a pass. Both atoms use `call_deferred("quit", …)` only — never
bare `quit()` from `_initialize()`. Both freeze main's saver
(`screenshot_frames=1000000`, `screenshot_done=true`) before self-capture
(G01 Trap C), clear `ais` so main returns at `main.gd:1603`, and drive
`game.tick(DT)` + `world.sync(DT)` themselves. Both read **only**
`capture_view3d.get_texture().get_image()` — never `root.get_texture()`
(D03 Trap B). Both prefer a real mapgen deposit and record a
`harness_fixture` fallback (not a weakened assertion).

---

## 5. Observed / derived / inferred / UNVERIFIED ledger

- **OBSERVED:** every file:line cite in §1, read directly this session
  (`game.gd`, `data.gd`, `world.gd`-adjacent `world3d.gd`, `world3d_fx.gd`,
  `world3d_entities.gd`, `main.gd`, `manifest.json` + OBJ vertex scan, plus
  G01/G02/F2-05 reports and `t_mine_build.gd`/`t_ghost_final_stage.gd`).
- **DERIVED:** indicator full span `2r` from `world3d_fx.gd:598`; mine baked
  mesh AABB from live manifest/OBJ; `_work_slot` ring ≥`r+0.7`; the two stage
  machines, the parity band `[0.847,1.18]`, the "about twice" band
  `[1.70,2.30]`, `N=400`, `FOOT_EPS=0.05`, and the self-tick/sync loop.
- **INFERRED (to be confirmed by G04):** pre-fix Atom A check 10 (and 5/11)
  RED, check 9 GREEN (control); pre-fix Atom B check 4 may be RED and check 6
  may be RED if the trap stalls. These are expectations from the owner
  directive and source, **not results**. The direction/magnitude of the
  footprint mismatch is **UNVERIFIED until the atom runs** — the atom does
  not assume which side is larger.
- **UNVERIFIED / PORT APPROX:** no atom file was created; nothing was parsed by
  Godot or executed; no PNG/result JSON exists; the mine bbox/radius, ghost
  footprint constant and builder ring are port measurements; no donor GPU A/B
  frame exists; donor parity stays **UNVERIFIED**.
- **NOT DONE by BLD-04:** no Godot run, no runner job, no PNG, no result JSON,
  no `.gd`/config/fixture/gate edit, no parse check.

---

## 6. Handoff to COORD

1. Create the two atoms **verbatim** as `variant3d/tests/t_bld_mine_footprint.gd`
   and `variant3d/tests/t_bld_builder_trap.gd` (new files only; disjoint from
   BLD-01/02/03 owners). Backups are not needed for new files.
2. Land BLD-03 (footprint honesty + builder avoidance fixes) **before** promoting
   these atoms to gates, so the pre-fix RED baseline is preserved for comparison.
3. Run §2.3 and §3.3 one at a time under the one-Godot lock (`status` first).
   Inspect PNGs visually: footprint indicator matched to the mine's on-screen
   size; builders ringing the finished mine outside its walls. Keep
   `expected_pre_fix_failure` RED records as provenance; do **not** resolve any
   failure by weakening a check.
4. If a future fix renames `Footprint` / `GhostBuildingFinished` / the
   `Building_mine_*_STATIC_POSE` node, update `_find_named` / `_find_prefix` in
   Atom A — never delete check 10/11. If work-slot logic moves out of
   `_work_slot`, Atom B still measures real positions, so it keeps gating.

*End of BLD-04 report.*
