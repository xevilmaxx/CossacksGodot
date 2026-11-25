---
id: M04
ticket: "Mill rotor decisive capture/probe atom — PROPOSAL (full GDScript in report only)"
swarm: TERRAIN-SWARM-WAVE-G
owner: M04 subagent
created: 2026-11-25
status: PROPOSAL__READ_ONLY__NO_ATOM_FILE__NO_GODOT__NO_RUNNER_JOB__NO_PNG
labels: [observed, derived, inferred, UNVERIFIED, PORT APPROX]
scope: "Exactly one new file: docs/terrain_swarm_2026-11-25/reports/M04_mill_qa.md. The atom below is a PROPOSAL for a later implementation owner. No .gd/.gdshader/config/fixture/result-JSON/PNG created or edited; no Godot process; no runner job; no donor access."
outputs:
  - docs/terrain_swarm_2026-11-25/reports/M04_mill_qa.md (this report, the only file written)
parity_guard: "PORT APPROXIMATION — the rotor is a 2D donor PNG bake on a billboard quad (world3d_entities.gd:231-264); the true donor .oss sail mesh (eurmilanim.oss) is UNVERIFIED and no donor GPU A/B frame exists. Donor parity stays UNVERIFIED (CHARTER §3, WAVE_G_CHARTER.md §11)."
---

# M04 — decisive mill-rotor capture/probe atom (PROPOSAL, not authored)

## 0. Boundary, authority and label key

- **Read before work:** `docs/terrain_swarm_2026-11-25/CHARTER.md` and
  `docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md` (both read in full this session),
  plus the reused patterns G01, G02, D03, E04 and the shipped atom files
  `variant3d/tests/t_ghost_final_stage.gd`, `t_select_rect_capture.gd`,
  `t_motion_capture.gd`, `mill_render_test.gd`.
- **One file written:** this report only. I did **not** create
  `variant3d/tests/t_mill_rotor_probe.gd`; the complete GDScript in §4 is a hand-off
  proposal for a later implementation owner. No game code, config, fixture, manifest,
  gate, result JSON or PNG was created or edited (disjoint ownership). No backup was
  needed (no existing file was touched).
- **No Godot was launched and no runner job was submitted.** WAVE-G standing rule
  (WAVE_G_CHARTER.md:31): only G04 submits runner jobs; all other Wave-G/analysis
  workers must not run Godot. Parse/runtime/visual behaviour of the atom below is
  therefore **UNVERIFIED**, never a PASS.
- Labels: **observed** = read directly from a cited file/line; **derived** = arithmetic
  or control-flow consequence of observed code; **inferred** = reasoned but not directly
  observed; **UNVERIFIED** = cannot be established without a real windowed run.
- **The atom proves internal rendering/state consistency, NOT donor parity.** The sail
  visual, spin direction and hub placement are donor-*derived* port constants on a
  billboard quad, not a donor GPU A/B comparison (see §9).

---

## 1. What the atom must decide (decomposition of the ticket)

| # | Ticket requirement | Decisive mechanism proposed |
|---|---|---|
| 1 | Boot a real 64² 3D game | Load `res://scenes/main.tscn`, assert `render_mode=="3d"`, `MAP_W==MAP_H==64`, real `game`/`world`/`camera`/`capture_view3d` (G02 `boot_real_64_3d_game`) |
| 2 | One mill at a fixed world position | Clear sim, `next_id=10`, `game.spawn("mil",0,Vector2(64,64),true)` → world origin `(0,0,0)`; assert `entities.size()==1` |
| 3 | Set the fixed camera | `_cam.set_process(false)`, margins 0, `jump_to_world((64,64))` → camera at `(0,h,back)` looking at the mill (G02 §`_configure`; camera3d.gd:264-282,444-452) |
| 4a | Rotor node exists | Find `MillRotor_10` under `Building_mil_10_STATIC_POSE`; MeshInstance3D with mesh, material, visible (G02 structural probe pattern) |
| 4b | Local offset on the mill's tip (not centre) | Assert `rotor.position ≈ (0.173, 5.235, 0)` from donor constants (world3d_entities.gd:247-252,1774-1776); |offset| > 4 m, x≈0, z≈0, ≠ centre |
| 4c | Rotation axis correct | Assert local Z (billboard normal) points at camera, X/Y lie in the sail plane; spin-rate meta = 0.75 rad/s; between frames the *relative* rotation is pure-Z (no tumble) |
| 4d | Whole-mill yaw (if any) puts sails toward camera | Record mill yaw (0 for buildings, world3d_entities.gd:1557-1559); assert world rotor +Z · to-camera > 0.95 — robust to any future yaw |
| 4e | Rotor actually animates over frames | Drive `world.sync(1/30)` deterministically; assert Δangle ≈ 0.75·Δanim_t ≈ 0.75 rad, far from a 4-blade 90° symmetry alias; assert rotor-local basis changes; corroborate with a pixel diff between two PNGs |
| 5 | Two WINDOWED PNGs (frame 0 / frame N) + frames.json | `capture_view3d` SubViewport `UPDATE_ONCE` + `await RenderingServer.frame_post_draw` + `get_texture().get_image().save_png()` (G01/G02/E04 seam); per-frame sidecar per `t_motion_capture.gd` |
| 6 | Exact runner command, unique id | §7; id `m04-mill-rotor-probe`; no `--headless` |
| 7 | headless = SKIP_CAPTURE / passed=false | `_initialize()` first branch mirrors G02: `verdict=SKIPPED_HEADLESS`, `capture_status=SKIP_CAPTURE`, `passed=false`, no PNG, exit 1 |
| 8 | Acceptance criteria | §8 |

---

## 2. Sources read (all read-only, OBSERVED)

| Source | Supply for this design |
|---|---|
| `variant3d/scripts/world3d_entities.gd:231-264` | Rotor is a donor 2D bake on a billboard quad; `ROTOR_TEX_PATH`, `MILL_HUB=(0.525,0.21)`, `MILL_SPIN=0.75`, `MILL_ROTOR_ORTHO=6.352`, `MILL_TOWER_ORTHO=6.627`, `MILL_TOWER_CX=0.4989`, `MILL_TOWER_FOOT=1.0`; spin-axis PORT APPROX label |
| `world3d_entities.gd:247-264, 1683-1686, 1697-1782` | `MillRotor_<id>` is a child of `Building_<sid>_<id>_STATIC_POSE`; `rotor.position=Vector3(hx,hy,0)`, `hx=(MILL_HUB.x−MILL_TOWER_CX)*ORTHO`, `hy=(MILL_TOWER_FOOT−MILL_HUB.y)*ORTHO`; meta `spin_rad_per_s` |
| `world3d_entities.gd:1551-1594` | `_xf()` yaw is 0 for buildings (only slot `class=="unit"` gets face-based yaw) → no whole-mill yaw today |
| `world3d_entities.gd:2014-2019, 2153-2188` | `sync(dt)` advances `_anim_t`; `rotor_spin=_anim_t*MILL_SPIN`; `face=Basis(rx,ry,d)` with `d` to camera; `rotor.transform=Transform3D(face*Basis().rotated(Vector3.FORWARD,spin),rotor.position)`; `stats["mill_rotor_angle_rad"]` and `stats["anim_clock_s"]` are the anim clock |
| `world3d.gd:329-354, 682-701` | `world.sync(dt)` reconciles new sim entities into presentation nodes (adds the mill + rotor) and delegates to `entities.sync(dt)` |
| `main.gd:1587-1672` | `main._process` early-returns when `ais` is empty → with `ais.clear()` the atom is the sole anim-clock driver; main's saver quits after saving (`:1730-1732,1930`) |
| `camera3d.gd:264-282, 444-452` | `jump_to_world` → `base=(target−half)`; camera at `base+(0,h,back)`, `look_at(base)`; SIM→centred convention |
| `data.gd:23,196` | `TILE_M=2.0`, `CAMERA_PITCH=-32°` → 64×64 tiles = 128×128 m, half = `(64,64)` m |
| `game.gd:16,2382-2406` | `spawn(sid,player,pos,finished)` stores sim `pos` verbatim |
| `G01_select_capture_atom.md`, `t_select_rect_capture.gd` | Windowed guard, `SKIP_CAPTURE`, `_write_bytes`/GPU seam, no-CPU-fallback rule, staged `_process` |
| `G02_ghost_atom.md`, `t_ghost_final_stage.gd` | Boot/configure pattern, `capture_view3d` async capture, verdict/headless semantics, argument resolution, single-write result guard |
| `D03_selection_probe.md` | "probe design, not authored" boundary, trap ledger, acceptance-criteria format, donor-parity label |
| `E04_ghost_qa.md` §3.2/§5/§6 | Decisive-atom structure; runner command form; headless never reports PASS |
| `t_motion_capture.gd:39-46,460-505` | `frames.json` format, per-frame metadata, image signature, frame-count checks |
| `mill_render_test.gd:34-76` | Earlier headless mill render: headless skips; windowed `root.get_texture()` is the *old* blank-prone seam — this atom uses `capture_view3d` instead (D03 Trap B) |
| `variant3d/tools/godot_runner.py`, `smallmap_capture.py` | Sole Godot door (`run`/`status`); read-only `stats`/`scan-stderr` (quoted from G01/G02) |

---

## 3. Geometry facts the assertions rely on (OBSERVED + DERIVED)

All numbers below are **derived** from the cited port constants; none is an invented
donor constant.

```
MILL_HUB        = (0.525, 0.21)     # world3d_entities.gd:247  (app/scripts/world.gd:203)
MILL_TOWER_CX   = 0.4989            # :251  (buildings.json ukr_mil:587)
MILL_TOWER_FOOT = 1.0               # :252  (buildings.json:584-585 / world.gd:696)
MILL_TOWER_ORTHO= 6.627             # :250  (buildings.json ukr_mil:579)
MILL_ROTOR_ORTHO= 6.352             # :249  (world.gd:208 / mill_rotor.json:3)
MILL_SPIN       = 0.75 rad/s        # :248  (app/scripts/world.gd:204/652)

hx = (MILL_HUB.x - MILL_TOWER_CX) * MILL_TOWER_ORTHO
   = (0.525 - 0.4989) * 6.627  = 0.0261 * 6.627  = +0.17296 m
hy = (MILL_TOWER_FOOT - MILL_HUB.y) * MILL_TOWER_ORTHO
   = (1.0 - 0.21) * 6.627     = 0.79   * 6.627  = +5.23533 m
rotor.position = Vector3(+0.17296, +5.23533, 0.0)   # :1774-1776
|rotor.position| = 5.2382 m  -> tower cap / sail hub, NOT the mill centre (0,0,0)
```

**DERIVED** — the offset's *Y* dominates (5.24 m of a ~5.9 m tower): the rotor sits on
the **tip/cap** of the mill, not at its geometric centre. Asserting `p.distance_to(want)
≤ 0.02 m` and `|p.y| > 4 m`, `|p.x| < 0.5 m`, `|p.z| ≤ 0.01 m`, `p ≠ Vector3.ZERO`
closes "on the tip, not centre" decisively.

**DERIVED** — rotor local axis: `face = Basis(rx, ry, d)` makes local **+Z** the
billboard normal toward the camera (`:2176`); `Basis().rotated(Vector3.FORWARD, spin)`
rotates **in the local XY plane about Z**, leaving local Z unchanged (`:2181`). Godot's
`Vector3.FORWARD == (0,0,-1)`; the source comment calls this "+Z (FORWARD)" and notes
that `BACK` would spin the other way (`ROTOR_SPIN_AXIS_STATUS`, `:258-264`). The
**sign** of the donor .oss spin is UNVERIFIED; the **axis** (billboard normal / local Z)
is what this atom asserts.

**DERIVED** — whole-mill yaw: `_xf()` sets `yaw=0` for a building (`class=="unit"` is
the only yaw branch, `:1559-1582`), so the parent basis is the identity and the
billboard alone aims the sails at the camera. The atom asserts the *composed world*
`rotor.global_transform.basis.z · to_camera > 0.95`, which stays correct if a later
patch adds a nonzero mill yaw and compensates the billboard — it tests the effect, not
the implementation detail; the yaw value is recorded as evidence.

**DERIVED** — determinism: with `ais.clear()` and `speed=0`, `main._process` returns
early (`main.gd:1603-1604`), so only the atom's explicit `world.sync(1/30)` calls
advance `_anim_t`. After 1 sync at frame 0 and 30 more to frame N:
`Δanim_t = 30/30 = 1.0 s`, `Δangle = 0.75 rad ≈ 43°`. A 4-blade sail has 90°
(`π/2 ≈ 1.571 rad`) symmetry; `0.75 rad` is ≥0.15 rad away from `k·π/2`, so the two
PNG frames are **not** symmetry-aliased into looking identical.

---

## 4. Proposed atom — FULL GDSCRIPT (in this report only; DO NOT create the file)

**Suggested path (for a later owner):** `variant3d/tests/t_mill_rotor_probe.gd`
(NEW file, loadable as `res://tests/t_mill_rotor_probe.gd`). It writes only
`res://tests/results/t_mill_rotor_probe.json` and the two temp PNGs + `frames.json`
passed on the command line. It reuses G01/G02/D03/E04 patterns verbatim in spirit;
no threshold or assertion is weakened. GDScript 4 syntax, Windows-safe, `python`.

```gdscript
# M04 / t_mill_rotor_probe.gd — PROPOSAL ONLY (M04_mill_qa.md §4).
# Not authored, not parsed, not run. A later implementation owner creates this file.
#
# Decisive mill-rotor probe: real windowed 64x64 3D main.tscn boot, ONE mill at a
# fixed world position, fixed camera, structural assertions on the rotor node,
# its tip-local offset, its spin axis, the sails-to-camera yaw, and animation over
# deterministically driven frames. Two windowed GPU PNGs (frame 0 / frame N) and a
# frames.json sidecar. Headless emits SKIP_CAPTURE / passed=false — NEVER a fake PASS.
#
# Launch (COORD only, Windows `python`, one Godot at a time, under the runner lock):
#   python variant3d\tools\godot_runner.py status
#   python variant3d\tools\godot_runner.py run --id m04-mill-rotor-probe --timeout 300 -- ^
#     --path variant3d --script res://tests/t_mill_rotor_probe.gd -- ^
#       --config <ABS>\variant3d\tests\fixtures\small_map_64.json ^
#       --screenshot <TEMP>\m04_mill\m04_frame_000.png ^
#       --frame-n <TEMP>\m04_mill\m04_frame_N.png ^
#       --frames-json <TEMP>\m04_mill\frames.json
extends SceneTree

const MAIN_SCENE := "res://scenes/main.tscn"
const OUT_PATH := "res://tests/results/t_mill_rotor_probe.json"
const Data = preload("res://scripts/data.gd")
const Ent = preload("res://scripts/world3d_entities.gd")   # same source as the live node

const SID := "mil"
const MILL_SIM := Vector2(64.0, 64.0)   # 64x64 map centre, SIM metres -> world (0,0,0)
const DT := 1.0 / 30.0                  # deterministic presentation step per sync()
const SPIN_STEPS := 30                  # frame N = 30 extra syncs after frame 0
const BOOT_FRAMES := 3
const POS_TOL := 0.02                   # metres, tip-offset tolerance
const AXIS_TOL := 0.02
const ANGLE_TOL := 0.05                 # rad, |measured - MILL_SPIN*dt_total|
const SYMMETRY_GUARD := 0.15            # rad, stay away from k*pi/2 sail symmetry

var _id := "t_mill_rotor_probe"
var _checks: Array[Dictionary] = []
var _ok := true
var _finished := false
var _stage := 0
var _stage_frames := 0
var _headless := false
var _capturing := false
var _capture_slot := 0

var _cfg_arg := ""
var _png0_arg := ""
var _pngn_arg := ""
var _frames_json_arg := ""
var _abs_config := ""

var _main: Node = null
var _game = null
var _world = null
var _cam = null
var _ents = null

var _mill_id := -1
var _mill_node: Node3D = null
var _rotor: MeshInstance3D = null
var _half := Vector2.ZERO
var _f0: Dictionary = {}
var _fn: Dictionary = {}
var _img0: Image = null
var _imgn: Image = null
var _m: Dictionary = {}


func check(name: String, cond, detail: String = "") -> void:
	_checks.append({"name": name, "passed": cond == true, "detail": detail})
	if cond != true:
		_ok = false
	print("TMILL %s %s - %s" % ["PASS" if cond == true else "FAIL", name, detail])


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


func _write_json(path: String, data: Dictionary) -> bool:
	var dir := path.get_base_dir()
	if dir != "" and not DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_recursive_absolute(dir)
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(JSON.stringify(data, "\t"))
	f.close()
	return true


func _write_result(verdict: String) -> void:
	# One terminal write: stage re-entry must never append duplicate checks.
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
		"capture_status": ("PASS" if (_img0 != null and _imgn != null) else "SKIP_CAPTURE"),
		"passes": passes,
		"total": _checks.size(),
		"checks": _checks,
		"measured": _m,
		"png_frame_0": _png0_arg,
		"png_frame_n": _pngn_arg,
		"frames_json": _frames_json_arg,
		"headless": _headless,
		"no_headless_pass": "headless -> SKIPPED_HEADLESS, passed=false, no PNG",
		"parity_label": "PORT APPROX — donor rotor PNG on a billboard quad; true .oss sail mesh UNVERIFIED; no donor GPU A/B frame",
		"script_error_note": "verify via variant3d/tools/smallmap_capture.py scan-stderr on runner stderr.txt",
		"unix_ms": Time.get_unix_time_from_system() * 1000.0,
	}
	var ok := _write_json(ProjectSettings.globalize_path(OUT_PATH), out)
	print("TMILL RESULT_JSON: " + ProjectSettings.globalize_path(OUT_PATH) + " ok=" + str(ok))
	print("TMILL RESULT: %s %d/%d" % [verdict, passes, _checks.size()])
	# SKIPPED_HEADLESS / ABORTED / FAIL all exit 1 — never a green envelope.
	call_deferred("quit", 0 if verdict == "PASS" else 1)


func _image_metrics(img: Image) -> Dictionary:
	var w := img.get_width()
	var h := img.get_height()
	var nb := 0
	var sum := 0.0
	var n := 0
	for y in range(0, h, 4):
		for x in range(0, w, 4):
			var c := img.get_pixel(x, y)
			if c.r > 8.0 / 255.0 or c.g > 8.0 / 255.0 or c.b > 8.0 / 255.0:
				nb += 1
			sum += 0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b
			n += 1
	return {"width": w, "height": h, "samples": n,
		"non_black_fraction": float(nb) / float(maxi(n, 1)),
		"mean_luma_0_1": sum / float(maxi(n, 1))}


func _image_signature(img: Image) -> Array[int]:
	var sig: Array[int] = []
	for i in range(16):
		sig.append(0)
	var w := img.get_width()
	var h := img.get_height()
	for by in range(4):
		for bx in range(4):
			var acc := 0.0
			var n := 0
			for y in range(by * h / 4, (by + 1) * h / 4, 8):
				for x in range(bx * w / 4, (bx + 1) * w / 4, 8):
					var c := img.get_pixel(x, y)
					acc += 0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b
					n += 1
			sig[by * 4 + bx] = int((acc / float(maxi(n, 1))) * 1000.0)
	return sig


func _diff_metrics(a: Image, b: Image, centre: Vector2, radius: int) -> Dictionary:
	var changed := 0
	var bright_delta := 0
	var x0 := maxi(0, int(centre.x) - radius)
	var y0 := maxi(0, int(centre.y) - radius)
	var x1 := mini(a.get_width() - 1, int(centre.x) + radius)
	var y1 := mini(a.get_height() - 1, int(centre.y) + radius)
	for y in range(y0, y1 + 1, 2):
		for x in range(x0, x1 + 1, 2):
			var ca := a.get_pixel(x, y)
			var cb := b.get_pixel(x, y)
			var d: float = absf(ca.r - cb.r) + absf(ca.g - cb.g) + absf(ca.b - cb.b)
			if d > 0.06:
				changed += 1
				if d > 0.20:
					bright_delta += 1
	return {"changed_px": changed, "strong_delta_px": bright_delta,
		"box": [x0, y0, x1, y1], "sample_step": 2}


func _stats() -> Dictionary:
	if _ents == null:
		return {}
	var st: Variant = _ents.get("stats")
	return st if st is Dictionary else {}


func _vec3_from(arr: Array) -> Vector3:
	return Vector3(float(arr[0]), float(arr[1]), float(arr[2]))


func _basis_from(rec: Dictionary) -> Basis:
	return Basis(_vec3_from(rec["rotor_basis_x"]),
		_vec3_from(rec["rotor_basis_y"]), _vec3_from(rec["rotor_basis_z"]))


func _record_frame(idx: int) -> Dictionary:
	var st := _stats()
	var d := {"index": idx}
	d["sim_time_s"] = float(_game.get("time_s"))
	d["anim_clock_s"] = float(st.get("anim_clock_s", -1.0))
	d["rotor_angle_rad"] = float(st.get("mill_rotor_angle_rad", -1.0))
	d["mill_rotor_count"] = int(st.get("mill_rotor_count", 0))
	d["mill_rotor_spin_axis_label"] = str(st.get("mill_rotor_spin_axis_label", "?"))
	d["mill_rotor_texture_fallback_used"] = bool(st.get("mill_rotor_texture_fallback_used", false))
	if _rotor != null and is_instance_valid(_rotor):
		var b: Basis = _rotor.transform.basis
		var gb: Basis = _rotor.global_transform.basis
		var to_cam: Vector3 = (_cam.global_position - _rotor.global_position).normalized()
		var p: Vector3 = _rotor.position
		var wp: Vector3 = _rotor.global_position
		d["rotor_local_pos"] = [p.x, p.y, p.z]
		d["rotor_basis_x"] = [b.x.x, b.x.y, b.x.z]
		d["rotor_basis_y"] = [b.y.x, b.y.y, b.y.z]
		d["rotor_basis_z"] = [b.z.x, b.z.y, b.z.z]
		d["rotor_world_pos"] = [wp.x, wp.y, wp.z]
		d["rotor_world_z"] = [gb.z.x, gb.z.y, gb.z.z]
		d["to_camera"] = [to_cam.x, to_cam.y, to_cam.z]
		d["sails_facing_dot"] = gb.z.dot(to_cam)
		# Projected rotor centre + a box radius from its full baked span.
		var cpx: Vector2 = _cam.unproject_position(wp)
		var xaxis: Vector3 = gb.x.normalized()
		var half_span: float = Ent.MILL_ROTOR_ORTHO * 0.5
		var edge: Vector2 = _cam.unproject_position(wp + xaxis * half_span)
		var radius: float = maxf(60.0, cpx.distance_to(edge) * 1.5)
		d["projected_px"] = [cpx.x, cpx.y]
		d["rotor_box_radius_px"] = int(radius)
		d["rotor_texture_status"] = str(_rotor.get_meta("rotor_texture_status", "?"))
	if _mill_node != null:
		d["mill_yaw_rad"] = _mill_node.transform.basis.get_euler().y
	var cp: Vector3 = _cam.global_position
	d["camera_pos"] = [cp.x, cp.y, cp.z]
	return d


func _assert_static() -> void:
	var mill_mi := _mill_node as MeshInstance3D   # Node3D has no `mesh` property
	var exists := (mill_mi != null and mill_mi.mesh != null
		and _rotor != null and is_instance_valid(_rotor)
		and _rotor.mesh != null and _rotor.material_override is StandardMaterial3D
		and _rotor.visible)
	_m["rotor_name"] = _rotor.name if _rotor != null else "<none>"
	_m["mill_node_name"] = _mill_node.name if _mill_node != null else "<none>"
	check("rotor_node_exists", exists,
		"mill=%s rotor=%s mesh=%s mat=%s visible=%s" % [
		str(_m["mill_node_name"]), str(_m["rotor_name"]),
		str(_rotor != null and _rotor.mesh != null),
		str(_rotor != null and _rotor.material_override is StandardMaterial3D),
		str(_rotor != null and _rotor.visible)])
	if not exists:
		return

	# --- (4b) local offset is on the mill's TIP, not its centre ----------------
	# Expected vector is computed from the SAME constants the live node uses
	# (world3d_entities.gd:247-252,1774-1776); no invented donor number.
	var hx: float = (Ent.MILL_HUB.x - Ent.MILL_TOWER_CX) * Ent.MILL_TOWER_ORTHO
	var hy: float = (Ent.MILL_TOWER_FOOT - Ent.MILL_HUB.y) * Ent.MILL_TOWER_ORTHO
	var want := Vector3(hx, hy, 0.0)
	var p: Vector3 = _rotor.position
	var on_tip := (p.distance_to(want) <= POS_TOL and absf(p.y) > 4.0
		and absf(p.x) < 0.5 and absf(p.z) <= 0.01
		and p.length() > 4.0 and not p.is_equal_approx(Vector3.ZERO))
	_m["rotor_local_pos"] = [p.x, p.y, p.z]
	_m["rotor_local_pos_expected"] = [want.x, want.y, want.z]
	_m["rotor_offset_from_centre_m"] = p.length()
	check("rotor_local_offset_on_tip", on_tip,
		"pos=(%.3f,%.3f,%.3f) want=(%.3f,%.3f,0) |off|=%.3fm (NOT centre)" % [
		p.x, p.y, p.z, want.x, want.y, p.length()])

	# --- (4c) spin axis / rate metadata ---------------------------------------
	var srpm: float = float(_rotor.get_meta("spin_rad_per_s", -1.0))
	var meta_ok := absf(srpm - Ent.MILL_SPIN) <= 0.001
	_m["spin_rad_per_s"] = srpm
	check("rotor_spin_axis_meta", meta_ok,
		"spin_rad_per_s=%.3f want=%.3f (world3d_entities.gd:248/1780)" % [srpm, Ent.MILL_SPIN])

	# Local +Z is the billboard normal toward the camera; X/Y lie in sail plane.
	var b: Basis = _rotor.transform.basis
	var cam_local: Vector3 = _mill_node.global_transform.affine_inverse() * _cam.global_position
	var d_local: Vector3 = (cam_local - p).normalized()
	var zdot: float = b.z.dot(d_local)
	var axis_ok := zdot > 0.98 and absf(b.x.dot(d_local)) < 0.05 and absf(b.y.dot(d_local)) < 0.05
	_m["local_spin_axis_dot_camera"] = zdot
	_m["local_x_dot_camera"] = b.x.dot(d_local)
	_m["local_y_dot_camera"] = b.y.dot(d_local)
	check("rotor_spin_axis_correct", axis_ok,
		"local+Z·to_cam=%.4f localX·cam=%.4f localY·cam=%.4f (axis local Z, PORT APPROX)" % [
		zdot, b.x.dot(d_local), b.y.dot(d_local)])

	# --- (4d) whole-mill yaw (if any) still puts sails toward the camera -----
	var gb: Basis = _rotor.global_transform.basis
	var to_cam: Vector3 = (_cam.global_position - _rotor.global_position).normalized()
	var facing: float = gb.z.dot(to_cam)
	var yaw: float = _mill_node.transform.basis.get_euler().y
	_m["mill_yaw_rad"] = yaw
	_m["sails_facing_dot_frame0"] = facing
	# Test the EFFECT, not the detail: a yaw is acceptable only if sails still face us.
	check("mill_yaw_puts_sails_toward_camera", facing > 0.95,
		"mill_yaw=%.4f rad (0 for buildings per _xf) world+Z·to_cam=%.4f" % [yaw, facing])


func _capture_async(slot: int) -> void:
	_capturing = true
	_capture_slot = slot
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
		check("capture_image", false, "blank SubViewport image — no CPU fallback (D03 Trap B)")
		_capturing = false
		return
	var path := _png0_arg if slot == 0 else _pngn_arg
	var err := img.save_png(path)
	var im := _image_metrics(img)
	im["path"] = path
	im["signature"] = _image_signature(img)
	im["bytes"] = FileAccess.get_file_as_bytes(path).size() if FileAccess.file_exists(path) else 0
	if slot == 0:
		_img0 = img
		_m["png_frame_0_metrics"] = im
	else:
		_imgn = img
		_m["png_frame_n_metrics"] = im
	check("capture_image", err == OK,
		"frame %s saved real windowed GPU frame %dx%d err=%d" % [
		"0" if slot == 0 else "N", img.get_width(), img.get_height(), err])
	_capturing = false


func _assert_animation() -> void:
	var a0: float = float(_f0.get("rotor_angle_rad", -1.0))
	var an: float = float(_fn.get("rotor_angle_rad", -1.0))
	var t0: float = float(_f0.get("anim_clock_s", -1.0))
	var tn: float = float(_fn.get("anim_clock_s", -1.0))
	var span: float = tn - t0
	var delta: float = an - a0
	var expected: float = span * Ent.MILL_SPIN
	var enough := delta > 0.25 and delta < 1.10 and absf(delta - expected) <= ANGLE_TOL
	var symmetric := false
	for k in range(0, 3):
		if absf(delta - float(k) * PI / 2.0) < SYMMETRY_GUARD:
			symmetric = true
	_m["angle_frame_0"] = a0
	_m["angle_frame_n"] = an
	_m["angle_delta_rad"] = delta
	_m["angle_expected_rad"] = expected
	_m["anim_span_s"] = span
	check("rotor_animates_over_frames", enough and not symmetric,
		"angle %.4f -> %.4f (delta %.4f rad, want %.4f = %.3f*%.3fs; 4-blade symmetry guard %s)" % [
		a0, an, delta, expected, Ent.MILL_SPIN, span, str(not symmetric)])

	# Relative rotation frame0->frameN must be PURE about local Z (no tumble).
	if _f0.has("rotor_basis_x") and _fn.has("rotor_basis_x"):
		var rel: Basis = _basis_from(_f0).inverse() * _basis_from(_fn)
		var rz: Vector3 = rel.z
		var stable := (absf(rz.dot(Vector3(0, 0, 1))) > 0.999
			and absf(rz.x) < AXIS_TOL and absf(rz.y) < AXIS_TOL
			and absf(rel.x.z) < AXIS_TOL and absf(rel.y.z) < AXIS_TOL)
		_m["relative_spin_axis"] = [rz.x, rz.y, rz.z]
		check("rotor_rotation_axis_stable", stable,
			"rel.z=(%.4f,%.4f,%.4f) must be (0,0,1) — spin axis fixed over frames" % [
			rz.x, rz.y, rz.z])
	else:
		check("rotor_rotation_axis_stable", false, "missing basis records")


func _assert_pixels() -> void:
	var m0: Dictionary = _m.get("png_frame_0_metrics", {})
	var mn: Dictionary = _m.get("png_frame_n_metrics", {})
	var ok0 := (_img0 != null and not _img0.is_empty()
		and int(m0.get("width", 0)) == 1280 and int(m0.get("height", 0)) == 720
		and float(m0.get("non_black_fraction", 0.0)) > 0.5)
	var okn := (_imgn != null and not _imgn.is_empty()
		and int(mn.get("width", 0)) == 1280 and int(mn.get("height", 0)) == 720
		and float(mn.get("non_black_fraction", 0.0)) > 0.5)
	check("png_frame_0_ok", ok0, "frame 0 windowed 1280x720 non-blank: %s" % str(m0))
	check("png_frame_n_ok", okn, "frame N windowed 1280x720 non-blank: %s" % str(mn))
	if not (ok0 and okn):
		return
	var arr: Array = _f0.get("projected_px", [-1.0, -1.0])
	var centre := Vector2(float(arr[0]), float(arr[1]))
	var radius: int = int(_f0.get("rotor_box_radius_px", 120))
	var d := _diff_metrics(_img0, _imgn, centre, radius)
	_m["rotor_pixel_diff"] = d
	_m["rotor_centre_px"] = [centre.x, centre.y]
	check("rotor_pixels_change", int(d["changed_px"]) > 40,
		"changed=%d strong=%d in rotor box %s (PORT APPROX visual evidence, not donor parity)" % [
		int(d["changed_px"]), int(d["strong_delta_px"]), str(d["box"])])


func _write_frames_json() -> void:
	var fixed := {
		"map": "64x64 tiles, TILE_M=2.0 (data.gd:23)",
		"mill_sid": SID,
		"mill_sim_pos_m": [MILL_SIM.x, MILL_SIM.y],
		"mill_world_pos_m": [MILL_SIM.x - _half.x, 0.0, MILL_SIM.y - _half.y],
		"camera_target_sim_m": [_half.x, _half.y],
		"camera_pos_frame0": _f0.get("camera_pos", []),
		"dt_per_sync_s": DT,
		"spin_steps_to_frame_n": SPIN_STEPS,
	}
	var constants := {
		"MILL_HUB": [Ent.MILL_HUB.x, Ent.MILL_HUB.y],
		"MILL_TOWER_CX": Ent.MILL_TOWER_CX,
		"MILL_TOWER_FOOT": Ent.MILL_TOWER_FOOT,
		"MILL_TOWER_ORTHO": Ent.MILL_TOWER_ORTHO,
		"MILL_ROTOR_ORTHO": Ent.MILL_ROTOR_ORTHO,
		"MILL_SPIN": Ent.MILL_SPIN,
		"source": "variant3d/scripts/world3d_entities.gd:247-253",
	}
	if _m.has("png_frame_0_metrics"):
		_f0["image"] = _m["png_frame_0_metrics"]
	if _m.has("png_frame_n_metrics"):
		_fn["image"] = _m["png_frame_n_metrics"]
	var fdata := {
		"format": "m04-mill-rotor-frames-1",
		"id": "m04-mill-rotor-probe",
		"capture": "windowed Screenshot3DViewport readback after RenderingServer.frame_post_draw",
		"config": _abs_config,
		"parity_label": "PORT APPROX — donor rotor PNG on a billboard quad; donor .oss sail mesh UNVERIFIED; no donor GPU A/B frame",
		"analysis_note": "CAPTURE + structural probe only; no donor parity or visual-fidelity claim in this file",
		"fixed": fixed,
		"constants": constants,
		"frames": [_f0, _fn],
	}
	var ok := _write_json(_frames_json_arg, fdata)
	check("frames_json_written", ok, _frames_json_arg)
	_m["frames_json"] = _frames_json_arg


func _initialize() -> void:
	if _finished:
		return
	_headless = DisplayServer.get_name() == "headless"
	_cfg_arg = _arg_value("--config")
	_png0_arg = _arg_value("--screenshot")
	_pngn_arg = _arg_value("--frame-n")
	_frames_json_arg = _arg_value("--frames-json")
	if _headless:
		check("headless_guard", false,
			"SKIP_CAPTURE: rotor pixels need a real window; no fake PASS (D03 §6 / G02 §4)")
		_m["display_server"] = DisplayServer.get_name()
		_write_result("SKIPPED_HEADLESS")
		return
	if _cfg_arg == "" or _png0_arg == "":
		check("launch_args", false,
			"need --config <small_map_64.json> and --screenshot <frame_000.png> (menu skip)")
		_write_result("ABORTED_ARGS")
		return
	_abs_config = _resolve_config(_cfg_arg)
	if _abs_config == "":
		check("launch_args", false, "config fixture not found: " + _cfg_arg)
		_write_result("ABORTED_ARGS")
		return
	# Derive companion paths if the caller only supplied --screenshot.
	if _pngn_arg == "":
		_pngn_arg = _png0_arg.get_basename() + "_frameN.png"
	if _frames_json_arg == "":
		_frames_json_arg = _png0_arg.get_base_dir().path_join("frames.json")
	_m["config"] = _abs_config
	_m["display_server"] = DisplayServer.get_name()
	var packed := load(MAIN_SCENE) as PackedScene
	if packed == null:
		check("boot_real_64_3d_game", false, "cannot load " + MAIN_SCENE)
		_write_result("ABORTED_BOOT")
		return
	_main = packed.instantiate()
	root.add_child(_main)
	_goto(0)   # wait for the full 3D boot before inspecting


func _configure() -> bool:
	_game = _main.get("game")
	_world = _main.get("world")
	_cam = _main.get("camera")
	_ents = (_world.get("entities") if _world != null else null)
	var cv = _main.get("capture_view3d")
	var boot_ok := (_game != null and _world != null and _cam != null and _ents != null
		and cv is SubViewport and str(_main.get("render_mode")).to_lower() == "3d"
		and int(_game.get("MAP_W")) == 64 and int(_game.get("MAP_H")) == 64)
	check("boot_real_64_3d_game", boot_ok,
		"render_mode=%s MAP=%sx%s entities=%s capture_view3d=%s" % [
		str(_main.get("render_mode")),
		str(_game.get("MAP_W")) if _game != null else "?",
		str(_game.get("MAP_H")) if _game != null else "?",
		str(_ents != null), str(cv is SubViewport)])
	if not boot_ok:
		return false

	# Freeze main's saver (it calls _quit(0) after saving) and its sim/AI loop so
	# the atom is the sole driver of the presentation anim clock (main.gd:1603-1604).
	_main.set("screenshot_frames", 1000000)
	_main.set("screenshot_done", true)
	var ais = _main.get("ais")
	if ais is Array:
		ais.clear()
	_main.set("speed", 0.0)
	_cam.set_process(false)
	_cam.edge_margin = 0.0
	_cam.corner_margin = 0.0
	_half = Vector2(float(_game.get("MAP_W")), float(_game.get("MAP_H"))) * Data.TILE_M * 0.5
	_cam.call("jump_to_world", _half)   # target=(64,64) -> camera looks at world origin

	# ONE mill at a FIXED world position: SIM (64,64) m -> world (0,0,0).
	_game.entities.clear()
	_game.by_id.clear()
	_game.live_units.clear()
	_game.live_blds.clear()
	_game.grid.clear()
	_game.events.clear()
	_game.next_id = 10
	var mill: Dictionary = _game.spawn(SID, 0, MILL_SIM, true)
	_mill_id = int(mill.get("id", -1))
	var mp: Variant = mill.get("pos", Vector2.ZERO)
	var one_mill := (_game.entities.size() == 1 and str(mill.get("sid", "")) == SID
		and mp is Vector2 and (mp as Vector2).is_equal_approx(MILL_SIM) and _mill_id == 10)
	_m["mill_id"] = _mill_id
	_m["mill_sim_pos"] = [MILL_SIM.x, MILL_SIM.y]
	check("one_mill_fixed_position", one_mill,
		"count=%d sid=%s pos=%s id=%d world=(%.1f,0,%.1f)" % [
		_game.entities.size(), str(mill.get("sid", "")), str(mp), _mill_id,
		MILL_SIM.x - _half.x, MILL_SIM.y - _half.y])
	if not one_mill:
		return false

	# Deterministic presentation sync: reconciles the mill into a real building
	# node and attaches the rotor (world3d.gd:329-354, world3d_entities.gd:1683-1686).
	_world.call("sync", DT)
	_mill_node = _find_named(_ents, "Building_%s_%d_STATIC_POSE" % [SID, _mill_id]) as Node3D
	_rotor = (_find_named(_mill_node, "MillRotor_%d" % _mill_id) as MeshInstance3D) if _mill_node != null else null
	_assert_static()
	if _rotor == null or not is_instance_valid(_rotor):
		return false
	_f0 = _record_frame(0)
	_m["rotor_count_frame0"] = int(_stats().get("mill_rotor_count", 0))
	return true


func _process(_dt: float) -> bool:
	if _finished or _capturing:
		return false
	_stage_frames += 1
	match _stage:
		0:
			if _stage_frames >= BOOT_FRAMES:
				if not _configure():
					_write_result("ABORTED_SETUP")
				else:
					_goto(1)
		1:
			if _stage_frames >= 2:
				_capture_async(0)     # WINDOWED PNG, frame 0 (anim clock = DT)
				_goto(2)
		2:
			if _stage_frames >= 2:
				for i in range(SPIN_STEPS):
					_world.call("sync", DT)   # sole anim-clock driver
				_fn = _record_frame(1)
				_assert_animation()
				_capture_async(1)     # WINDOWED PNG, frame N (anim clock = (N)*DT)
				_goto(3)
		3:
			if _stage_frames >= 2:
				_assert_pixels()
				_write_frames_json()
				_write_result("PASS" if _ok else "FAIL")
	return false
```

### Implementation notes for the later owner (do not weaken)

1. **Staged `_process`, no `await` inside it.** `_capture_async()` is a coroutine
   (`await RenderingServer.frame_post_draw`) called *from* `_process`; `_process`
   stays synchronous and returns `false` while `_capturing` is true. This is the exact
   G02 pattern and avoids the `SceneTree._process() -> bool` coroutine trap (D03 §4.3.2).
2. **No CPU fallback, no root texture.** `_capture_async` reads only
   `capture_view3d.get_texture().get_image()`; a null/blank/wrong-size image fails
   loudly. `mill_render_test.gd`'s `root.get_texture()` seam is deliberately not reused
   (D03 Trap B; `main.gd:1235-1238,1861-1863`).
3. **Deterministic animation.** Because `ais.clear()` makes `main._process` early-return,
   the atom's `world.sync(DT)` calls are the only clock source. Do **not** set
   `speed>0` or re-add AIs — that would make Δangle depend on wall-clock frame rate.
4. **Constants are read from the same script** (`preload` of `world3d_entities.gd`),
   so expected offset/spin follow any legitimate constant change; this is not a
   hard-coded donor claim.
5. **The yaw check tests the effect** (`world +Z · to_cam > 0.95`) and records the yaw,
   rather than requiring yaw==0; a future compensated yaw is not a false failure.
6. **One result write.** `_write_result` returns early if `_finished`; stage 3 cannot
   append duplicate checks before the deferred `quit` lands (G02 correction).

---

## 5. Artifacts the atom produces (all under a unique Temp folder)

| Artifact | Name / purpose |
|---|---|
| PNG frame 0 | `<TEMP>\m04_mill\m04_frame_000.png` — real windowed 1280×720 GPU frame at `anim_clock = DT`, rotor angle ≈ 0.025 rad |
| PNG frame N | `<TEMP>\m04_mill\m04_frame_N.png` — same fixed camera at `anim_clock = 31·DT ≈ 1.033 s`, rotor angle ≈ 0.775 rad (Δ≈43°) |
| `frames.json` | `<TEMP>\m04_mill\frames.json` — `format=m04-mill-rotor-frames-1`, two frame records, `fixed` mill/camera/clock fields, `constants` from `world3d_entities.gd`, parity label |
| Result JSON | `variant3d\tests\results\t_mill_rotor_probe.json` — checks, verdict, measured, three output paths, headless flag, parity label |

Illustrative `frames.json` shape (values are **expected**, not observed — the atom has
not run):

```json
{
  "format": "m04-mill-rotor-frames-1",
  "id": "m04-mill-rotor-probe",
  "capture": "windowed Screenshot3DViewport readback after RenderingServer.frame_post_draw",
  "parity_label": "PORT APPROX — donor rotor PNG on a billboard quad; donor .oss sail mesh UNVERIFIED; no donor GPU A/B frame",
  "analysis_note": "CAPTURE + structural probe only; no donor parity or visual-fidelity claim in this file",
  "fixed": {
    "mill_sid": "mil",
    "mill_sim_pos_m": [64.0, 64.0],
    "mill_world_pos_m": [0.0, 0.0, 0.0],
    "camera_target_sim_m": [64.0, 64.0],
    "dt_per_sync_s": 0.033333,
    "spin_steps_to_frame_n": 30
  },
  "constants": {
    "MILL_HUB": [0.525, 0.21],
    "MILL_TOWER_CX": 0.4989,
    "MILL_TOWER_FOOT": 1.0,
    "MILL_TOWER_ORTHO": 6.627,
    "MILL_ROTOR_ORTHO": 6.352,
    "MILL_SPIN": 0.75,
    "source": "variant3d/scripts/world3d_entities.gd:247-253"
  },
  "frames": [
    {
      "index": 0, "anim_clock_s": 0.0333, "rotor_angle_rad": 0.025,
      "rotor_local_pos": [0.173, 5.235, 0.0],
      "mill_yaw_rad": 0.0, "sails_facing_dot": 0.99,
      "projected_px": [640, 330], "image": {"path": "...m04_frame_000.png", "bytes": 0}
    },
    {
      "index": 1, "anim_clock_s": 1.0333, "rotor_angle_rad": 0.775,
      "rotor_local_pos": [0.173, 5.235, 0.0],
      "mill_yaw_rad": 0.0, "sails_facing_dot": 0.99,
      "projected_px": [640, 330], "image": {"path": "...m04_frame_N.png", "bytes": 0}
    }
  ]
}
```

**DERIVED** — the two PNGs must be *distinct*: `Δangle ≈ 0.75 rad` and the 4-blade
sail symmetry period is `π/2 ≈ 1.571 rad`; the `SYMMETRY_GUARD` in the atom rejects a
Δangle within 0.15 rad of `k·π/2`, so frame N cannot accidentally coincide with a
rotationally-identical pose. `frames.json` lets a second agent read the clock, angle,
basis, camera and rotor centre without re-running Godot (G05/C04 protocol).

---

## 6. Headless / verdict semantics (NOT weakened)

| Situation | `verdict` | `passed` | `capture_status` | exit |
|---|---|---|---|---|
| All checks true, both windowed PNGs saved | `PASS` | true | `PASS` | 0 |
| Any evaluated check false | `FAIL` | false | `SKIP_CAPTURE` | 1 |
| Headless launch | `SKIPPED_HEADLESS` | false | `SKIP_CAPTURE` | 1 |
| Bad args / fixture / boot / setup | `ABORTED_*` | false | `SKIP_CAPTURE` | 1 |

- The headless branch (`_initialize()` first guard) writes the result JSON with
  `passed=false`, **no PNG and no `frames.json`**, and defers `quit(1)`. There is no
  code path where a headless run reports `PASS` (G02 §4, D03 §6).
- `passed` in the result JSON is computed **solely** as `(verdict == "PASS")`.
- Exit 1 for headless is deliberate: an envelope with `exit != 0` can never be mistaken
  for a green capture (conservative vs G02's exit-0 skip; stronger anti-false-green).

---

## 7. Exact runner command — for COORD only, NOT executed by M04

**Before submitting** — one-Godot rule (`CHARTER.md` §3; WAVE_G_CHARTER.md:31):

```powershell
python variant3d\tools\godot_runner.py status
```

Proceed only when `godot.lock` is free (or wait in the FIFO). Never invoke `godot`
directly; never submit two jobs. Unique id: **`m04-mill-rotor-probe`** (refresh to
`-probe2` if that id is already present under `variant3d\.godot_queue\results\`).
Single line from the project root (PowerShell-safe, Windows `python`, no `&&`, no
`--headless`):

```
python variant3d\tools\godot_runner.py run --id m04-mill-rotor-probe --timeout 300 -- --path variant3d --script res://tests/t_mill_rotor_probe.gd -- --config "C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\variant3d\tests\fixtures\small_map_64.json" --screenshot "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\m04_mill\m04_frame_000.png" --frame-n "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\m04_mill\m04_frame_N.png" --frames-json "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\m04_mill\frames.json"
```

- First `--` is consumed by the runner; the second separates Godot engine args from
  atom user args (G02 §5, D03 §5).
- `--screenshot` is **only** the menu-skip flag (`main.gd:230-244`); the atom writes
  both PNGs itself and disarms main's saver.
- Expected envelope: `variant3d\.godot_queue\results\000NNNNN.json` plus
  `000NNNNN_m04-mill-rotor-probe\stdout.txt` / `stderr.txt`; atom JSON:
  `variant3d\tests\results\t_mill_rotor_probe.json`.

Read-only post-run verification (no Godot):

```powershell
python variant3d\tools\smallmap_capture.py stats "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\m04_mill\m04_frame_000.png" "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\m04_mill\m04_frame_N.png"
python variant3d\tools\smallmap_capture.py scan-stderr "C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\variant3d\.godot_queue\results\000NNNNN_m04-mill-rotor-probe\stderr.txt"
```

Expect both PNGs 1280×720, `non_black_fraction > 0.5`, `full_width_dark_rows == 0`,
and `script_error_lines == 0`. `stats` is qualitative only; the authoritative
structural/axis/animation verdict is the in-atom assertions.

---

## 8. Acceptance criteria (all mandatory for a PASS)

| # | Criterion | Evidence required |
|---|---|---|
| 1 | Runner envelope `status=ok`, `exit=0`, `argv` has **no** `--headless`, id `m04-mill-rotor-probe` | `000NNNNN.json` |
| 2 | `SCRIPT ERROR` count 0 | `smallmap_capture.py scan-stderr` on runner `stderr.txt` |
| 3 | Result JSON `verdict=PASS`, `passed=true`, `capture_status=PASS`, `headless=false` | `t_mill_rotor_probe.json` |
| 4 | `boot_real_64_3d_game` true (`render_mode=3d`, 64×64, real camera/entities/capture viewport) | result JSON |
| 5 | `one_mill_fixed_position` true: exactly one `mil`, SIM `(64,64)`, world `(0,0,0)`, id 10 | result JSON + `frames.json.fixed` |
| 6 | `rotor_node_exists` true: `MillRotor_10` under `Building_mil_10_STATIC_POSE`, meshed, material, visible | result JSON |
| 7 | `rotor_local_offset_on_tip` true: `position ≈ (0.173, 5.235, 0) ±0.02 m`, `|offset|>4 m`, not centre | result JSON `measured.rotor_local_pos*` |
| 8 | `rotor_spin_axis_meta` true (`spin_rad_per_s=0.75`) and `rotor_spin_axis_correct` true (local +Z·camera >0.98, X/Y in sail plane) | result JSON `measured.local_spin_axis_dot_camera` |
| 9 | `mill_yaw_puts_sails_toward_camera` true: world rotor +Z · to-camera >0.95; yaw recorded (0 today) | result JSON `measured.sails_facing_dot_frame0` |
| 10 | `rotor_animates_over_frames` true: Δangle ≈ 0.75 rad = `MILL_SPIN·Δanim_t` ±0.05 rad, >0.25 rad, not symmetry-aliased | result JSON `measured.angle_*` + `frames.json` |
| 11 | `rotor_rotation_axis_stable` true: relative frame0→N rotation pure about local Z (`rel.z≈(0,0,1)`) | result JSON `measured.relative_spin_axis` |
| 12 | `png_frame_0_ok` and `png_frame_n_ok` true: both real windowed 1280×720 GPU PNGs, non-blank | two PNGs + `stats` + result JSON |
| 13 | `frames_json_written` true; `frames.json` has two frame records, `fixed` + `constants` fields, and `rotor_pixels_change` true (>40 changed px in rotor box) | `frames.json` + result JSON |
| 14 | No donor-parity claim: both JSONs carry `parity_label` PORT APPROX / UNVERIFIED; report §9 labels donor parity UNVERIFIED | JSONs + this report |

**Overall PASS = all 1–14.** If a PNG is missing/blank, the honest verdict is
`UNVERIFIED (NO PNG)`, never a visual PASS from JSON alone (D03 §6/§8, `RECHECK_S1`
precedent quoted in D03/G01). A failed structural/axis/animation check is a genuine
`FAIL`, not to be "fixed" by lowering a threshold.

---

## 9. Observed / derived / inferred / UNVERIFIED ledger

- **OBSERVED (direct source reads this session):** `world3d_entities.gd:231-264,
  247-253, 309-315, 1683-1686, 1697-1782, 1551-1594, 2014-2019, 2153-2188`;
  `world3d.gd:329-354, 682-701`; `main.gd:1587-1672, 1730-1732, 1861-1930,
  1235-1253`; `camera3d.gd:264-282, 444-452`; `game.gd:16, 2382-2406`;
  `data.gd:21-23,196`; G01/G02/D03/E04 reports and the shipped atom files
  `t_ghost_final_stage.gd`, `t_select_rect_capture.gd`, `t_motion_capture.gd`,
  `mill_render_test.gd`; `small_map_64.json` usage in those atoms.
- **DERIVED:** tip offset `(0.173,5.235,0)` and `|offset|=5.24 m`; 64×64→128×128 m
  world with half `(64,64)`; mill at SIM `(64,64)`→world origin; frame-0 angle 0.025 rad
  and frame-N 0.775 rad after 30×(1/30) s with `MILL_SPIN=0.75`; 4-blade π/2 symmetry
  guard; `main._process` early-return makes the atom the sole clock driver; the
  billboard local-Z axis is the correct spin axis; exit-1 headless guard choice.
- **INFERRED (to be confirmed by a real run):** with the landed code all 14 criteria
  should pass; the two PNGs should show a face-on sail rotor in two distinct poses at
  world origin; `capture_view3d` composites the mill identically to the window.
  These are expectations, **not results**.
- **UNVERIFIED / PORT APPROX:** donor sail visual fidelity, the true donor `.oss`
  spin direction/hub semantics (`ROTOR_SPIN_AXIS_STATUS`, `ROTOR_STATUS` are port labels),
  whether `mill_rotor.png` binds or degrades to the white fallback quad, and **all donor
  parity** — no donor GPU A/B frame exists under this charter.
- **NOT DONE by M04:** no `.gd` atom created; no Godot process; no runner job; no PNG;
  no result/frames JSON; no parse check. Everything runtime-related awaits the
  implementation owner and G04's single windowed run under the one-Godot lock.

---

## 10. Handoff

- **COORD / implementation owner:** if this atom is adopted, create
  `variant3d/tests/t_mill_rotor_probe.gd` **from §4 verbatim**, then hand the §7
  command to **G04** (sole runner owner) under the FIFO lock. Keep all 14 criteria;
  do not flip the headless branch to a pass, do not drop the symmetry guard, do not
  re-scope the yaw check to "yaw==0", and do not weaken the tip-offset tolerance.
- **G05 / C04 visual review:** open both PNGs plus `frames.json`; confirm a face-on
  four-blade sail at the tower cap in two distinct poses, a fixed camera, and a
  readable per-frame clock/angle record. Report observations with frame numbers from
  `frames.json` (`CAPTURE_RECHECK.md:52`, `C04_visual_review.md:72,168`). No donor
  parity conclusion from smoothness or appearance.
- **If a future change moves the rotor to the mill centre, spins it about X/Y, or
  turns the sails away from the fixed camera,** the corresponding check (7/8/9/10/11)
  must go RED and stay RED; the integrating owner updates the probe — not the
  threshold.

*End of M04 report.*
