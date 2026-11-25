# Z08 — HEIGHT WAVE ticket Z08-IMPL. This file is the FULL GDScript printed in
# docs/terrain_swarm_2026-11-25/reports/Z07_relief_props_qa.md §4, materialised
# VERBATIM (byte-for-byte from the fenced block) by the Z08 integrating owner.
# Created for hand-off / static inspection only: NO Godot process and NO runner
# job were run by Z08 (WAVE_G_CHARTER.md:31 — only G04 runs jobs).
#
# KNOWN INTERFACE GAP (recorded honestly in reports/Z08_impl.md, not weakened
# here): Z07 §2's contract expects one MeshInstance3D per prop, while Z08's
# landed consumer uses one static MultiMeshInstance3D batch per sid. The QA
# owner / G04 must reconcile the collector and `expected` count before this
# atom can go green; no threshold or assertion may be lowered to fake a PASS.
# Also note Z06 §1 corrected Z07 §1.1's 'authored scale 1' to a non-unit
# per-object Scaling 0.3539..0.6562; the atom's SCALE_WANT is deliberately
# left at Z07's published value and must be reconciled by that owner.

# Z07 — decisive QA atom: donor-driven terrainmesh relief props (64x64 / 320x320).
#
# DESIGN PRINTED IN docs/terrain_swarm_2026-11-25/reports/Z07_relief_props_qa.md
# ONLY. Z07 did NOT create this file, did NOT run Godot and did NOT submit a job.
# Only G04 runs jobs (WAVE_G_CHARTER.md:31). PORT APPROX QA thresholds; no donor
# parity claim. Expected to FAIL on the current tree (Z03 blockers B1-B4).
#
# Launch (Windows python, NO --headless; see report §5 for full runner command):
#   --path variant3d --script res://tests/t_relief_props_qa.gd --
#   --config <small_map_64_mountains.json> --screenshot <flag.png> --map-size 64
extends SceneTree

const MAIN_SCENE := "res://scenes/main.tscn"
const BASE_FIXTURE := "res://tests/fixtures/small_map_64.json"
const PROP_MANIFEST := "res://assets/terrain/terrainmesh_props.json"
const OUT_DIR := "res://tests/results"
const CAP_DIR := "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/z07_relief_props"
const RESULT_ID := "t_relief_props_qa"
const Data = preload("res://scripts/data.gd")

const WANT_SEED := 20261113
const TILE_M := 2.0
const DONOR_UNITS := 160.0
const SID_MIN_H := 6.9          # ticket band lower bound (mesh4 = 6.92, Z03:82)
const SID_MAX_H := 9.55         # mesh3 = 9.54; ticket's "9.5" is an approximation
const BBOX_TOL := 0.05
const SCALE_WANT := 1.0         # donor exempt from random rescale (Z03:85)
const SCALE_TOL := 0.02
const CENTRE_TOL_TILES := 1.0
const BASE_Y_TOL := 0.5
const RISE_CENTRE_MIN := 4.0
const RISE_FOOTPRINT_MIN := 2.0
const DIFF_LUMA_MIN := 0.06
const DIFF_RGB_SUM_MIN := 0.24
const DIFF_PX_PER_PROP_MIN := 200
const RISE_PX_MIN := 8
const OUTSIDE_DIFF_MAX := 0.01
const BOOT_LIMIT_MS := 120000
const RUN_LIMIT_MS := 300000

# Donor bbox heights decoded by Z03:82 (DERIVED). Decisive per-sid band.
const DONOR_H := {
    "terrainmesh1": 7.38, "terrainmesh2": 8.06,
    "terrainmesh3": 9.54, "terrainmesh4": 6.92,
}

var _id := RESULT_ID
var _checks: Array[Dictionary] = []
var _ok := true
var _finished := false
var _start_ms := 0
var _m: Dictionary = {}
var _frames_meta: Array[Dictionary] = []

var _cfg_arg := ""
var _shot_arg := ""
var _abs_config := ""
var _map_size := 64
var _main: Node = null
var _game = null
var _world: Node = null
var _terrain = null
var _cam = null
var _vp: SubViewport = null
var _manifest: Dictionary = {}
var _stamps: Array[Dictionary] = []
var _props: Array[MeshInstance3D] = []
var _props_meta: Array[Dictionary] = []
var _img_base: Image = null
var _img_wide: Image = null
var _img_sky: Image = null
var _last_camera_meta: Dictionary = {}

func check(name: String, cond: bool, detail: String) -> void:
    _checks.append({"name": name, "passed": cond, "detail": detail})
    if not cond:
        _ok = false
    print("Z07 %s %s - %s" % ["PASS" if cond else "FAIL", name, detail])

func _arg_value(flag: String) -> String:
    for src in [OS.get_cmdline_user_args(), OS.get_cmdline_args()]:
        var args := PackedStringArray(src)
        for i in range(args.size()):
            if str(args[i]) == flag and i + 1 < args.size():
                return str(args[i + 1])
    return ""

func _ensure_dir(path: String) -> bool:
    var err := DirAccess.make_dir_recursive_absolute(path)
    return err == OK or DirAccess.dir_exists_absolute(path)

func _write_text(path: String, text: String) -> bool:
    var f := FileAccess.open(path, FileAccess.WRITE)
    if f == null:
        push_error("t_relief_props_qa: cannot write " + path)
        return false
    f.store_string(text)
    f.close()
    return true

# ---- headless / abort / finish ------------------------------------------------
func _skip_capture(reason: String) -> void:
    check("headless_guard", false, reason + " (no GPU; windowed job required)")
    _ensure_dir(CAP_DIR)
    _write_text(CAP_DIR + "/SKIP_CAPTURE.txt",
        "SKIP_CAPTURE\nreason: " + reason + "\nstatus: SKIP_CAPTURE\npassed: false\n")
    _m["status"] = "SKIP_CAPTURE"
    _m["reason"] = reason
    _m["headless"] = true
    _finish()

func _abort(reason: String) -> void:
    check("capture_run", false, reason)
    _m["status"] = "ABORTED"
    _m["reason"] = reason
    _finish()

func _finish() -> void:
    if _finished:
        return
    _finished = true
    var passes := 0
    for c in _checks:
        if bool(c.get("passed", false)):
            passes += 1
    var status := "PASS" if _ok else "FAIL"
    if str(_m.get("status", "")) == "SKIP_CAPTURE":
        status = "SKIP_CAPTURE"
    elif str(_m.get("status", "")) == "ABORTED":
        status = "ABORTED"
    _m["status"] = status
    var out := {
        "id": _id,
        "passed": _ok,
        "status": status,
        "passes": passes,
        "total": _checks.size(),
        "checks": _checks,
        "measured": _m,
        "frames_json": CAP_DIR + "/frames.json" if _frames_meta.size() > 0 else "",
        "frame_count": _frames_meta.size(),
        "capture_mode": "windowed SubViewport readback after RenderingServer.frame_post_draw",
        "expected_pre_fix_failure": true,
        "parity_guard": "PORT APPROX QA thresholds; internal props ON/OFF A/B only; NO donor GPU A/B; no donor parity claim",
        "script_error_note": "verify via variant3d/tools/smallmap_capture.py scan-stderr on runner stderr.txt",
        "unix_ms": Time.get_unix_time_from_system() * 1000.0,
    }
    var abs_dir := ProjectSettings.globalize_path(OUT_DIR)
    _ensure_dir(abs_dir)
    var path := "%s/%s.json" % [abs_dir, _id]
    _write_text(path, JSON.stringify(out, "\t"))
    print("Z07 RESULT_JSON: " + path)
    print("Z07 RESULT: %s %s %d/%d" % [status, "PASS" if _ok else "FAIL", passes, _checks.size()])
    # Headless is a deliberate non-pass: exit 1, never a fake PASS.
    call_deferred("quit", 0 if _ok else 1)

# ---- fixture validation (read-only) ------------------------------------------
func _resolve_config(given: String) -> String:
    if given.is_absolute_path():
        return given if FileAccess.file_exists(given) else ""
    var by_res := ProjectSettings.globalize_path("res://").path_join(given)
    if FileAccess.file_exists(by_res):
        return by_res
    return given if FileAccess.file_exists(given) else ""

func _validate_fixture() -> bool:
    var f := FileAccess.open(_abs_config, FileAccess.READ)
    if f == null:
        check("fixture_relief_mountains", false, "cannot read " + _abs_config)
        return false
    var parsed: Variant = JSON.parse_string(f.get_as_text())
    f.close()
    if not (parsed is Dictionary) or not ((parsed as Dictionary).get("gameplay", {}) is Dictionary):
        check("fixture_relief_mountains", false, "fixture has no gameplay object")
        return false
    var gp: Dictionary = (parsed as Dictionary).get("gameplay", {})
    var w := int(gp.get("map_width_tiles", 0))
    var h := int(gp.get("map_height_tiles", 0))
    var relief := str(gp.get("relief", ""))
    var ok := (w == _map_size and h == _map_size and relief == "mountains"
        and str(gp.get("render_mode", "")).to_lower() == "3d"
        and int(gp.get("random_seed", -1)) == WANT_SEED)
    check("fixture_relief_mountains", ok,
        "fixture=%dx%d mode=%s relief=%s seed=%d (mountains tier required: hills tier places 0 mountain stamps at 64²)" % [
        w, h, str(gp.get("render_mode", "")), relief, int(gp.get("random_seed", -1))])
    _m["fixture"] = _abs_config
    _m["fixture_map"] = [w, h]
    _m["fixture_relief"] = relief
    return ok

# ---- boot & freeze -----------------------------------------------------------
func _boot() -> bool:
    var packed := load(MAIN_SCENE) as PackedScene
    if packed == null:
        check("capture_run", false, "cannot load " + MAIN_SCENE)
        return false
    _main = packed.instantiate()
    root.add_child(_main)
    var ready := false
    for _i in range(240):
        await RenderingServer.frame_post_draw
        if _main != null and is_instance_valid(_main) \
                and _main.get("game") != null and _main.get("capture_view3d") != null:
            ready = true
            break
        if Time.get_ticks_msec() - _start_ms > BOOT_LIMIT_MS:
            break
    if not ready:
        check("capture_run", false, "real game boot did not expose game + capture_view3d")
        return false
    _m["boot_wall_ms"] = Time.get_ticks_msec() - _start_ms
    return true

func _configure() -> bool:
    _game = _main.get("game")
    _world = _main.get("world") as Node
    _cam = _main.get("camera")
    _vp = _main.get("capture_view3d") as SubViewport
    _terrain = _world.get("terrain") if _world != null else null
    var boot_ok := (_game != null and _world != null and _cam != null and _vp != null
        and _terrain != null and _terrain.has_method("height_at_world")
        and str(_main.get("render_mode")).to_lower() == "3d"
        and int(_game.get("MAP_W")) == _map_size and int(_game.get("MAP_H")) == _map_size)
    _m["boot_render_mode"] = str(_main.get("render_mode"))
    _m["boot_map_tiles"] = [int(_game.get("MAP_W")), int(_game.get("MAP_H"))] if _game != null else []
    check("real_game_boot", boot_ok,
        "render_mode=%s map=%s terrain_sampler=%s" % [str(_main.get("render_mode")),
        str(_m["boot_map_tiles"]), str(_terrain != null)])
    if not boot_ok:
        return false
    var vps := _vp.size
    check("capture_viewport_ready", vps.x == 1280 and vps.y == 720,
        "viewport=%s size=%dx%d" % [_vp.name, vps.x, vps.y])
    if vps.x != 1280 or vps.y != 720:
        return false

    # Freeze main's own saver and sim clock (G01/G02/t_motion_capture pattern).
    var ais = _main.get("ais")
    if ais is Array:
        (ais as Array).clear()
    _main.set("speed", 0.0)
    _main.set("acc", 0.0)
    _main.set("screenshot_frames", 1000000)
    _main.set("screenshot_done", true)
    _cam.set_process(false)

    # Relief tier + donor-driven mountain stamps (landed pattern_gen, no new code).
    var relief := str(Data.RELIEF)
    var pb: Variant = _game.get("_pattern_build")
    _stamps = []
    if pb is Dictionary:
        var sv: Variant = (pb as Dictionary).get("stamps", [])
        if sv is Array:
            for s in (sv as Array):
                if s is Object and str(s.get("kind")) == "mountain":
                    _stamps.append({
                        "name": str(s.get("name")),
                        "x": int(s.get("x")), "y": int(s.get("y")),
                    })
    var min_stamps := 3 if _map_size >= 320 else 1
    var tier_ok := (relief == "mountains" and _stamps.size() >= min_stamps)
    _m["relief_live"] = relief
    _m["mountain_stamps"] = _stamps
    check("relief_tier_live", tier_ok,
        "relief=%s mountain_stamps=%d (need >=%d)" % [relief, _stamps.size(), min_stamps])
    return tier_ok

# ---- derived donor link ------------------------------------------------------
func _load_manifest() -> bool:
    _manifest = {}
    if not FileAccess.file_exists(PROP_MANIFEST):
        check("prop_manifest_loaded", false,
            "missing " + PROP_MANIFEST + " (Z03 blocker B2: no pattern->prop link)")
        return false
    var f := FileAccess.open(PROP_MANIFEST, FileAccess.READ)
    var parsed: Variant = JSON.parse_string(f.get_as_text())
    f.close()
    if not (parsed is Dictionary):
        check("prop_manifest_loaded", false, "manifest is not a JSON object")
        return false
    _manifest = parsed as Dictionary
    var by_pattern: Variant = _manifest.get("by_pattern", {})
    var bbox: Variant = _manifest.get("bbox_m", {})
    var bbox_ok := by_pattern is Dictionary and bbox is Dictionary
    if bbox_ok:
        for sid in DONOR_H.keys():
            var v: Variant = (bbox as Dictionary).get(sid, -1.0)
            var hv := float(v) if v is float or v is int else -1.0
            if absf(hv - float(DONOR_H[sid])) > BBOX_TOL:
                bbox_ok = false
    check("prop_manifest_loaded", bbox_ok,
        "by_pattern=%d bbox_m=%s; donor bbox from Z03:82 (no donor bytes in runtime tree)" % [
        (by_pattern as Dictionary).size() if by_pattern is Dictionary else -1,
        str(bbox)])
    _m["prop_manifest"] = PROP_MANIFEST
    return bbox_ok

# ---- prop discovery & geometry checks ---------------------------------------
func _collect_props(node: Node) -> void:
    if node == null:
        return
    if node is MeshInstance3D and node.is_in_group("terrainmesh_props"):
        _props.append(node as MeshInstance3D)
    for c in node.get_children():
        _collect_props(c)

func _sim_of(wp: Vector3) -> Vector2:
    return Vector2(wp.x + float(_game.get("MAP_W")) * TILE_M * 0.5,
                   wp.z + float(_game.get("MAP_H")) * TILE_M * 0.5)

func _prop_height(mi: MeshInstance3D) -> float:
    if mi.mesh == null:
        return 0.0
    return mi.mesh.get_aabb().size.y * absf(mi.scale.y)

func _prop_radius(mi: MeshInstance3D) -> float:
    if mi.mesh == null:
        return 0.0
    var a := mi.mesh.get_aabb().size
    return maxf(a.x, a.z) * maxf(absf(mi.scale.x), absf(mi.scale.z)) * 0.5

func _probe_props() -> bool:
    _props = []
    _collect_props(_world)
    var by_pattern: Dictionary = (_manifest.get("by_pattern", {}) as Dictionary) \
        if _manifest.get("by_pattern", {}) is Dictionary else {}
    var expected := 0
    for st in _stamps:
        var sids: Variant = by_pattern.get(str(st.get("name")), [])
        if sids is Array and not (sids as Array).is_empty():
            expected += 1
    var count_ok := (_props.size() == expected and expected > 0)
    check("relief_prop_instances_exist", count_ok,
        "prop_nodes=%d expected=%d (1 per donor-linked mountain stamp; zero is a FAIL, not a PASS)" % [
        _props.size(), expected])
    _m["prop_count"] = _props.size()
    _m["prop_expected"] = expected
    if not count_ok:
        return false

    var by_cell: Dictionary = {}
    for st in _stamps:
        by_cell[Vector2i(int(st.get("x")), int(st.get("y")))] = str(st.get("name"))
    var sids_ok := true
    var pos_ok := true
    var scale_ok := true
    var base_ok := true
    var silhouette_ok := true
    _props_meta = []

    for mi in _props:
        var sid := str(mi.get_meta("terrainmesh_sid", ""))
        var stamp_name := str(mi.get_meta("stamp_name", ""))
        var stamp_cell: Vector2i = mi.get_meta("stamp_cell", Vector2i(-1, -1))
        var sim := _sim_of(mi.global_position)
        var cell := Vector2i(int(sim.x / TILE_M), int(sim.y / TILE_M))
        var wp := Vector2(mi.global_position.x, mi.global_position.z)
        var ground := float(_terrain.call("height_at_world", wp))
        var hgt := _prop_height(mi)
        var rad := _prop_radius(mi)
        var top_y := mi.global_position.y + hgt
        var rise_centre := top_y - ground

        # donor sid = one of the sids baked for this stamp's donor pattern name
        var allowed: Array = []
        if by_pattern.has(stamp_name) and by_pattern[stamp_name] is Array:
            allowed = by_pattern[stamp_name]
        var sid_ok := (sid in allowed) and DONOR_H.has(sid)
        sids_ok = sids_ok and sid_ok

        # position round-trip: prop cell == donor stamp cell within 1 tile
        var dc := Vector2(float(cell.x - stamp_cell.x), float(cell.y - stamp_cell.y)).length()
        var pos_one := (dc <= CENTRE_TOL_TILES and by_cell.has(stamp_cell)
            and str(by_cell[stamp_cell]) == stamp_name)
        pos_ok = pos_ok and pos_one

        # authored scale 1 and donor bbox band 6.9..9.55 (ticket "9.5" is approx)
        var s := mi.scale
        var scale_uniform := (absf(s.x - SCALE_WANT) <= SCALE_TOL
            and absf(s.y - SCALE_WANT) <= SCALE_TOL
            and absf(s.z - SCALE_WANT) <= SCALE_TOL)
        var band := (hgt >= SID_MIN_H and hgt <= SID_MAX_H)
        var baked := float(DONOR_H.get(sid, -1.0))
        var bbox_match := absf(hgt - baked) <= BBOX_TOL
        scale_ok = scale_ok and scale_uniform and band and bbox_match

        base_ok = base_ok and absf(mi.global_position.y - ground) <= BASE_Y_TOL

        # silhouette above terrain: centre and 8 footprint samples
        var max_ground := ground
        for k in range(8):
            var a := float(k) * PI * 0.25
            var q := wp + Vector2(cos(a), sin(a)) * rad
            max_ground = maxf(max_ground, float(_terrain.call("height_at_world", q)))
        var sil_ok := (rise_centre >= RISE_CENTRE_MIN
            and (top_y - max_ground) >= RISE_FOOTPRINT_MIN)
        silhouette_ok = silhouette_ok and sil_ok

        _props_meta.append({
            "name": mi.name, "sid": sid, "stamp_name": stamp_name,
            "stamp_cell": [stamp_cell.x, stamp_cell.y],
            "prop_cell": [cell.x, cell.y], "cell_delta_tiles": dc,
            "world_pos": [mi.global_position.x, mi.global_position.y, mi.global_position.z],
            "sim_pos": [sim.x, sim.y], "ground_y": ground,
            "height_world": hgt, "radius_world": rad, "top_y": top_y,
            "rise_centre": rise_centre, "rise_over_footprint": top_y - max_ground,
            "scale": [s.x, s.y, s.z], "bbox_baked_h": baked,
            "selection_rule": "PORT APPROX" if allowed.size() > 1 else "single donor sid",
        })

    check("prop_sids_donor_driven", sids_ok,
        "all sids in baked per-pattern lists; multi-sid selection stays PORT APPROX/UNVERIFIED")
    check("prop_positions_donor_driven", pos_ok,
        "all prop cells match their donor stamp cells within %.1f tile" % CENTRE_TOL_TILES)
    check("prop_scale_authored", scale_ok,
        "scale in [%.2f,%.2f], height in [%.2f,%.2f] and within %.2f of baked bbox" % [
        SCALE_WANT - SCALE_TOL, SCALE_WANT + SCALE_TOL, SID_MIN_H, SID_MAX_H, BBOX_TOL])
    check("prop_base_on_terrain", base_ok,
        "base Y within %.1f m of terrain.height_at_world" % BASE_Y_TOL)
    check("silhouette_rises_above_terrain", silhouette_ok,
        "top >= centre+%.1f m and >= max-footprint+%.1f m (geometry, not pixels)" % [
        RISE_CENTRE_MIN, RISE_FOOTPRINT_MIN])
    _m["props"] = _props_meta
    return sids_ok and pos_ok and scale_ok and base_ok and silhouette_ok

# ---- safety: starts / buildings / paths --------------------------------------
func _clearance() -> bool:
    var map_scale := float(_game.get("MAP_W")) / DONOR_UNITS
    var start_clear_m := 14.0 * map_scale  # CIRCLE1 max=7 donor cells -> 2*7*scale m
    var starts: Variant = _game.get("map_starts")
    var start_ok := true
    var bld_ok := true
    var path_ok := true
    var blocked_inside := 0

    for pm in _props_meta:
        var sim := Vector2(float((pm.get("sim_pos") as Array)[0]),
                           float((pm.get("sim_pos") as Array)[1]))
        var rad := float(pm.get("radius_world", 0.0))
        if starts is Array:
            for st in (starts as Array):
                if start_ok and Vector2(sim.x, sim.y).distance_to(st as Vector2) < start_clear_m:
                    start_ok = false
        if _game.entities is Array:
            for e in (_game.entities as Array):
                if not (e is Dictionary) or str((e as Dictionary).get("kind", "")) != "building":
                    continue
                var ed: Dictionary = e
                var pos: Vector2 = ed.get("pos", Vector2.ZERO)
                var r := float(_game.call("bld_rm", int(ed.get("player", -1)), str(ed.get("sid", ""))))
                if r <= 0.0:
                    var df: Variant = ed.get("def", {})
                    r = float((df as Dictionary).get("radius", 2.0)) if df is Dictionary else 2.0
                if sim.distance_to(pos) < r + rad:
                    bld_ok = false
        var tmin := Vector2i(int((sim.x - rad) / TILE_M), int((sim.y - rad) / TILE_M))
        var tmax := Vector2i(int((sim.x + rad) / TILE_M), int((sim.y + rad) / TILE_M))
        var bl: Variant = _game.get("blocked")
        if bl is PackedByteArray:
            for yy in range(maxi(0, tmin.y), mini(int(_game.get("MAP_H")), tmax.y + 1)):
                for xx in range(maxi(0, tmin.x), mini(int(_game.get("MAP_W")), tmax.x + 1)):
                    if (bl as PackedByteArray)[yy * int(_game.get("MAP_W")) + xx] != 0:
                        blocked_inside += 1

    # Reachability: BFS on blocked[] from each start to every other start.
    var bl2: Variant = _game.get("blocked")
    if starts is Array and bl2 is PackedByteArray and (starts as Array).size() >= 2:
        var w := int(_game.get("MAP_W"))
        var h := int(_game.get("MAP_H"))
        var ba: PackedByteArray = bl2
        var sa: Array = starts
        var first: Vector2 = sa[0]
        var seen := PackedByteArray()
        seen.resize(w * h)
        var q: Array[int] = []
        var sx := clampi(int(first.x / TILE_M), 0, w - 1)
        var sy := clampi(int(first.y / TILE_M), 0, h - 1)
        seen[sy * w + sx] = 1
        q.append(sy * w + sx)
        var head := 0
        while head < q.size():
            var cur: int = q[head]
            head += 1
            var cx := cur % w
            var cy := cur / w
            for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
                var nx := cx + (d as Vector2i).x
                var ny := cy + (d as Vector2i).y
                if nx < 0 or ny < 0 or nx >= w or ny >= h:
                    continue
                var ni := ny * w + nx
                if seen[ni] != 0 or ba[ni] != 0:
                    continue
                seen[ni] = 1
                q.append(ni)
        for i in range(1, sa.size()):
            var t: Vector2 = sa[i]
            var tx := clampi(int(t.x / TILE_M), 0, w - 1)
            var ty := clampi(int(t.y / TILE_M), 0, h - 1)
            if seen[ty * w + tx] == 0:
                path_ok = false

    check("props_clear_of_starts", start_ok,
        "prop centre >= CIRCLE1 keep-clear %.1f m for every start (donor-grounded pattern-gen rule)" % start_clear_m)
    check("props_clear_of_buildings", bld_ok,
        "prop centre >= bld_rm() + prop footprint radius for every building")
    check("props_do_not_block_paths", blocked_inside == 0 and path_ok,
        "blocked cells inside prop footprints=%d; all starts mutually reachable=%s" % [
        blocked_inside, str(path_ok)])
    _m["start_clear_m"] = start_clear_m
    _m["blocked_inside_prop_footprints"] = blocked_inside
    _m["all_starts_reachable"] = path_ok
    return start_ok and bld_ok and blocked_inside == 0 and path_ok

# ---- capture -----------------------------------------------------------------
func _image_stats(img: Image) -> Dictionary:
    var w := img.get_width()
    var h := img.get_height()
    var first_l := img.get_pixel(0, 0).get_luminance()
    var varied := false
    var sum_l := 0.0
    var n := 0
    for yy in range(0, h, maxi(1, h / 8)):
        for xx in range(0, w, maxi(1, w / 8)):
            var l := img.get_pixel(xx, yy).get_luminance()
            sum_l += l
            n += 1
            if l - first_l > 0.02:
                varied = true
    return {"w": w, "h": h, "mean_luma": sum_l / maxf(1.0, float(n)), "blank": not varied}

func _set_camera(sim_target: Vector2, height_m: float) -> Dictionary:
    # Fixed donor-pitch camera (-32°, camera3d.gd:278-282). Height is set directly
    # (20..58 m donor band); process disabled so no edge-scroll drift occurs.
    _cam.call("jump_to_world", sim_target)
    _cam.set("height", height_m)
    _cam.set("height_target", height_m)
    _cam.call("_apply_transform")
    await RenderingServer.frame_post_draw
    var half := Vector2(float(_game.get("MAP_W")), float(_game.get("MAP_H"))) * TILE_M * 0.5
    var target := str(_cam.get("_target"))
    _last_camera_meta = {
        "target_sim": target,
        "height_m": height_m,
        "pitch_deg": float(Data.CAMERA_PITCH),
        "world_position": [float(_cam.global_position.x), float(_cam.global_position.y),
                            float(_cam.global_position.z)],
        "camera_current": (_cam.get_viewport().get_camera_3d() == _cam),
        "viewport": _vp.name,
        "sim_half_m": [half.x, half.y],
    }
    return _last_camera_meta

func _capture(tag: String) -> Image:
    _vp.render_target_update_mode = SubViewport.UPDATE_ONCE
    await RenderingServer.frame_post_draw
    var img: Image = _vp.get_texture().get_image()
    var st := _image_stats(img) if img != null and not img.is_empty() else {"blank": true}
    var retries := 0
    while bool(st.get("blank", true)) and retries < 4:
        _vp.render_target_update_mode = SubViewport.UPDATE_ONCE
        await RenderingServer.frame_post_draw
        img = _vp.get_texture().get_image()
        st = _image_stats(img) if img != null and not img.is_empty() else {"blank": true}
        retries += 1
    if img == null or img.is_empty() or bool(st.get("blank", true)):
        _abort("flat/blank 3D image for " + tag + " after %d retries (no CPU fallback)" % retries)
        return null
    var path := "%s/z07_%s.png" % [CAP_DIR, tag]
    img.save_png(path)
    var f := FileAccess.open(path, FileAccess.READ)
    var bytes := f.get_length() if f != null else -1
    if f != null:
        f.close()
    _m["capture_" + tag] = {"path": path, "bytes": bytes, "stats": st,
                            "blank_read_retries": retries, "camera": _last_camera_meta}
    return img

func _project_boxes() -> Array[Dictionary]:
    var boxes: Array[Dictionary] = []
    for pm in _props_meta:
        var wp: Array = pm.get("world_pos", [0.0, 0.0, 0.0])
        var x := float(wp[0]); var y := float(wp[1]); var z := float(wp[2])
        var hgt := float(pm.get("height_world", 0.0))
        var rad := float(pm.get("radius_world", 0.0))
        var base_px: Vector2 = _cam.unproject_position(Vector3(x, y, z))
        var top_px: Vector2 = _cam.unproject_position(Vector3(x, y + hgt, z))
        var left_px: Vector2 = _cam.unproject_position(Vector3(x - rad, y, z))
        var right_px: Vector2 = _cam.unproject_position(Vector3(x + rad, y, z))
        var r := Rect2(minf(base_px.x, left_px.x), minf(top_px.y, base_px.y),
            absf(right_px.x - left_px.x), absf(base_px.y - top_px.y)).grow(4.0)
        boxes.append({
            "sid": pm.get("sid", ""), "name": pm.get("name", ""),
            "rect": [r.position.x, r.position.y, r.size.x, r.size.y],
            "base_px": [base_px.x, base_px.y], "top_px": [top_px.x, top_px.y],
            "in_view": (r.position.x >= 0 and r.position.y >= 0
                and r.end.x <= 1280 and r.end.y <= 720 and r.get_area() > 400.0),
        })
    return boxes

func _pixel_diff(a: Image, b: Image, boxes: Array[Dictionary]) -> Dictionary:
    var inside_changed := 0
    var outside_changed := 0
    var outside_total := 0
    var top_changed: Dictionary = {}
    for bi in boxes:
        if not bool(bi.get("in_view", false)):
            continue
        var rArr: Array = bi.get("rect", [0.0, 0.0, 0.0, 0.0])
        var r := Rect2(float(rArr[0]), float(rArr[1]), float(rArr[2]), float(rArr[3]))
        var x0 := clampi(int(r.position.x), 0, 1279)
        var y0 := clampi(int(r.position.y), 0, 719)
        var x1 := clampi(int(r.end.x), 0, 1280)
        var y1 := clampi(int(r.end.y), 0, 720)
        var cnt := 0
        var min_y := 720
        for yy in range(y0, y1):
            for xx in range(x0, x1):
                var ca := a.get_pixel(xx, yy)
                var cb := b.get_pixel(xx, yy)
                var dl := absf(ca.get_luminance() - cb.get_luminance())
                var dr := absf(ca.r - cb.r) + absf(ca.g - cb.g) + absf(ca.b - cb.b)
                if dl >= DIFF_LUMA_MIN or dr >= DIFF_RGB_SUM_MIN:
                    cnt += 1
                    min_y = mini(min_y, yy)
        top_changed[str(bi.get("name", ""))] = {
            "changed_px": cnt,
            "topmost_changed_y": min_y,
            "projected_base_y": float((bi.get("base_px", [0.0, 0.0]) as Array)[1]),
            "upward_rise_px": maxf(0.0, float((bi.get("base_px", [0.0, 0.0]) as Array)[1]) - float(min_y)),
        }
        inside_changed += cnt
    # Outside-change control: fixed camera + frozen sim => only props may change.
    for yy in range(0, 720, 4):
        for xx in range(0, 1280, 4):
            var in_any := false
            for bi in boxes:
                var rArr2: Array = bi.get("rect", [0.0, 0.0, 0.0, 0.0])
                var r2 := Rect2(float(rArr2[0]), float(rArr2[1]), float(rArr2[2]), float(rArr2[3]))
                if r2.has_point(Vector2(xx, yy)):
                    in_any = true
                    break
            var ca2 := a.get_pixel(xx, yy)
            var cb2 := b.get_pixel(xx, yy)
            if in_any:
                continue
            outside_total += 1
            if absf(ca2.get_luminance() - cb2.get_luminance()) >= DIFF_LUMA_MIN:
                outside_changed += 1
    var frac := float(outside_changed) / maxf(1.0, float(outside_total))
    return {"inside_changed_px": inside_changed, "per_prop": top_changed,
            "outside_change_fraction": frac, "outside_samples": outside_total}

func _capture_all() -> void:
    if Time.get_ticks_msec() - _start_ms > RUN_LIMIT_MS:
        _abort("capture deadline exceeded")
        return
    var sim_target := Vector2(float(_game.get("MAP_W")), float(_game.get("MAP_H"))) * TILE_M * 0.5
    if not _props_meta.is_empty():
        var p0: Array = _props_meta[0].get("sim_pos", [sim_target.x, sim_target.y])
        sim_target = Vector2(float(p0[0]), float(p0[1]))  # fixed: first prop centre
        for pm in _props_meta:
            var pp: Array = pm.get("sim_pos", [0.0, 0.0])
            sim_target = (sim_target + Vector2(float(pp[0]), float(pp[1]))) * 0.5

    # Frame 0 — props HIDDEN, wide fixed camera: internal A/B baseline.
    for mi in _props:
        mi.visible = false
    var cam0 := await _set_camera(sim_target, float(_cam.get("max_height")))
    _img_base = await _capture("wide_props_off")
    var boxes0 := _project_boxes()
    _frames_meta.append({"frame": 0, "png": "z07_wide_props_off.png",
        "props_visible": false, "camera": cam0, "boxes": boxes0,
        "image": _image_stats(_img_base) if _img_base != null else {"blank": true}})

    # Frame 1 — props SHOWN, same camera: required WINDOWED PNG #1 (wide hills).
    for mi in _props:
        mi.visible = true
    var cam1 := await _set_camera(sim_target, float(_cam.get("max_height")))
    _img_wide = await _capture("wide_props_on")
    var boxes1 := _project_boxes()
    _frames_meta.append({"frame": 1, "png": "z07_wide_props_on.png",
        "props_visible": true, "camera": cam1, "boxes": boxes1,
        "image": _image_stats(_img_wide) if _img_wide != null else {"blank": true}})

    # Frame 2 — props SHOWN, low 22 m skyline camera: required PNG #2.
    var cam2 := await _set_camera(sim_target, 22.0)
    _img_sky = await _capture("skyline_props_on")
    var boxes2 := _project_boxes()
    _frames_meta.append({"frame": 2, "png": "z07_skyline_props_on.png",
        "props_visible": true, "camera": cam2, "boxes": boxes2,
        "image": _image_stats(_img_sky) if _img_sky != null else {"blank": true}})

    var two_ok := (_img_wide != null and _img_sky != null and _img_base != null)
    check("two_windowed_pngs", two_ok,
        "wide_props_on + skyline_props_on (plus props-off baseline) at 1280x720, non-blank")
    if not two_ok:
        return

    # INTERNAL props-ON/OFF pixel A/B at an identical camera (NEVER a donor A/B).
    var diff := _pixel_diff(_img_wide, _img_base, boxes1)
    var visible_boxes := 0
    var per_ok := 0
    for k in (diff.get("per_prop", {}) as Dictionary).values():
        var pd: Dictionary = k
        visible_boxes += 1
        if int(pd.get("changed_px", 0)) >= DIFF_PX_PER_PROP_MIN \
                and float(pd.get("upward_rise_px", 0.0)) >= float(RISE_PX_MIN):
            per_ok += 1
    var ab_ok := (visible_boxes > 0 and per_ok == visible_boxes
        and float(diff.get("outside_change_fraction", 1.0)) < OUTSIDE_DIFF_MAX)
    check("internal_ab_pixel_proof", ab_ok,
        "props with >=%d changed px and >=%d px upward silhouette: %d/%d; outside-change=%.4f (must be <%.2f)" % [
        DIFF_PX_PER_PROP_MIN, RISE_PX_MIN, per_ok, visible_boxes,
        float(diff.get("outside_change_fraction", 1.0)), OUTSIDE_DIFF_MAX])
    _m["pixel_ab"] = diff
    _m["visible_prop_boxes"] = visible_boxes

    var fdata := {
        "format": "z07-relief-props-frames-1",
        "id": _id,
        "capture": "windowed Screenshot3DViewport readback after RenderingServer.frame_post_draw",
        "config": _abs_config, "map_size": _map_size, "relief": str(Data.RELIEF),
        "seed": WANT_SEED, "sim_clock": "frozen (speed=0, ais cleared)",
        "parity_guard": "internal ON/OFF A/B only; NOT a donor GPU A/B; no donor parity claim",
        "thresholds_label": "PORT APPROX QA thresholds, not donor constants",
        "frames": _frames_meta,
        "pixel_ab": diff,
    }
    var ok_json := _write_text(CAP_DIR + "/frames.json", JSON.stringify(fdata, "\t"))
    check("frames_json_written", ok_json, CAP_DIR + "/frames.json")
    _m["frames_json"] = CAP_DIR + "/frames.json"

# ---- entry -------------------------------------------------------------------
func _initialize() -> void:
    if _finished:
        return
    _start_ms = Time.get_ticks_msec()
    if DisplayServer.get_name() == "headless":
        _skip_capture("DisplayServer is headless")
        return
    _cfg_arg = _arg_value("--config")
    _shot_arg = _arg_value("--screenshot")
    if _cfg_arg == "" or _shot_arg == "":
        _abort("need --config <small_map_64_mountains.json> and --screenshot <flag>")
        return
    var ms := _arg_value("--map-size")
    _map_size = int(ms) if ms != "" else 64
    if _map_size != 64 and _map_size != 320:
        _abort("--map-size must be 64 or 320")
        return
    _abs_config = _resolve_config(_cfg_arg)
    if _abs_config == "" or not FileAccess.file_exists(_abs_config):
        _abort("fixture not found: " + _cfg_arg)
        return
    _m["config"] = _abs_config
    _m["screenshot_flag"] = _shot_arg
    _m["map_size"] = _map_size
    _m["display_server"] = DisplayServer.get_name()
    _ensure_dir(CAP_DIR)
    if not _validate_fixture():
        _finish()
        return
    if not await _boot():
        _finish()
        return
    if not _configure():
        _finish()
        return
    if not _load_manifest():
        _finish()
        return
    if not _probe_props():
        _finish()
        return
    if not _clearance():
        _finish()
        return
    await _capture_all()
    _finish()
