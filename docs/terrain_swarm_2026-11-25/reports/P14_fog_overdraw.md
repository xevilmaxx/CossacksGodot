---
id: P14
ticket: TERRAIN-SWARM-2026-11-25 / Wave P / P14 (fog-overdraw fix PROPOSAL, read-only)
date: 2026-11-25
status: COMPLETE__READ_ONLY__NO_GODOT_JOBS__PROPOSAL_ONLY
labels: [observed, derived, inferred, UNVERIFIED]
files_created:
  - docs/terrain_swarm_2026-11-25/reports/P14_fog_overdraw.md
files_edited: []
godot_jobs_run: 0
runner_jobs_submitted: 0
parity_guard: "No donor GPU A/B frame exists (CHARTER §3); no capture or profiler was produced. Every code statement below is OBSERVED with file:line; every pixel-equivalence and structural-equivalence argument is a DERIVATION; every frame-time or FPS consequence is UNVERIFIED. This report does not claim donor parity and does not edit code."
---

# P14 — fog-overlay quad compaction: exact ready-to-apply proposal

## 0. Scope compliance

Read-only. Exactly one file created (this report). **No** `.gd`, shader, config, test or asset was
edited; no Godot process was started and no runner job was submitted
(`WAVE_G_CHARTER.md:31`, `:67-70`). Sources read:

| Source | Role |
|---|---|
| `docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md` | Wave P at `:60-89`, standing rule `:67-70` |
| `docs/terrain_swarm_2026-11-25/CHARTER.md` | guardrails `:55-69`, definition of done `:122-130` |
| `reports/P05_shader_cost.md` | §4.1 `:174-193`, §5 `:218-227`, §6.5 `:301-314`, §7 `:352`, §9 `:392-393` |
| `variant3d/scripts/world3d_fog.gd` | full file, 318 lines |
| `variant3d/tests/t_fog3d.gd` | full file, 192 lines |
| `variant3d/tests/_v716_probe.gd` | `FogOverlay` structural probe, 48 lines |
| `variant3d/tests/results/t_fog3d.json` | last green result (9 checks, PASS) |
| `variant3d/scripts/world3d.gd` | `:635-655`, `:682-700`, `:752-761` (bind/sync/alias) |
| `variant3d/scripts/data.gd:55`, `variant3d/config.json:47,56`, `variant3d/scripts/config.gd:488` | fog-mode defaults |
| `variant3d/shaders/terrain_tileindex.gdshader:198,456-466`, `variant3d/scripts/world3d_terrain.gd:743` | separate `fog_mode` uniform |
| `variant3d/tests/t_terrain_shore.gd` | grep for `fog|Fog` → **0 matches** |
| `git status --short` on the two fog files | clean; no concurrent owner's edit present |

**P07 status:** `reports/P07_node_count.md` has **not landed** at the time of writing (report
directory listing contains P01, P04, P05, P06 but no P07). No node-count finding is therefore folded
in; if P07 lands with an observation about the `FogOverlay` child or hidden-but-present nodes, COORD
should reconcile it against §2 before granting an implementation ticket.

**Label convention:** `[O]` literal code fact with file:line · `[D]` derivation from `[O]` ·
`[I]` analytical estimate, unmeasured · `[U]` requires a run/capture — UNVERIFIED.

---

## 1. Executive answer

1. **File:** `variant3d/scripts/world3d_fog.gd` only. It has **no current owner** in Wave G/P/M/H
   (`WAVE_G_CHARTER.md:39-58`, `:74-87`, `:97-104`, `:117-124`); P05 is read-only and only *proposes*
   the compaction at `P05_shader_cost.md:301-314`. COORD must grant exclusive ownership to an
   implementation ticket before anyone edits (CHARTER `:68`).
2. **Fix:** build and refresh a **compacted** fog mesh — emit a quad only when
   (a) `bool(Data.FOG_OF_WAR)` is true **and** (b) the tile's ladder alpha `> 0.0`. Keep the vertex,
   UV and colour arrays dense with a `tile → slot` map, and rebuild them on the existing change
   gate. No shader, uniform, public array, material or visibility-logic change.
3. **Pixel identity is a derivation, not a measurement:** the deleted quads carry exactly
   `ALPHA = 0.0` (`world3d_fog.gd:41,128-133,159-160`) under `blend_mix, depth_draw_never`
   (`:154`), so they composite to `dst` unchanged `[D]`; this remains **UNVERIFIED** until a fresh
   capture with fog-of-war ON (none exists).
4. **FPS claim: UNVERIFIED.** At the shipped start `Data.FOG_OF_WAR = false`
   (`data.gd:55`, `config.json:47,56`, `config.gd:488`) the overlay is already invisible
   (`world3d_fog.gd:213`), so this change removes geometry that was **never rasterised** and the
   expected start-up frame-time delta is **zero `[D]`, UNVERIFIED by capture**. Any benefit exists
   only with fog-of-war enabled and partially revealed; its size is `[I]` and must not be quoted as
   a measured FPS gain.
5. **No test weakening:** `t_fog3d.gd` asserts array sizes, `bind`/`sync` API, no `Sprite2D` fallback
   and no hangs (`:157-189`) but **no quad/vertex/count assertion** — independently confirmed by grep
   over the whole file (0 matches for `quad|vertex|index|surface|mesh|color|alpha`). P05's statement
   at `:191-192` is confirmed.

---

## 2. OBSERVED — what the current code actually does

| Site | Fact |
|---|---|
| `:39-41` | Alpha ladder: `UNEXPLORED 0.78 / EXPLORED 0.30 / VISIBLE 0.00` — port state encoding from `app/scripts/world.gd:2251-2255`; not a donor value. |
| `:128-133` | `_alpha_for(i)` returns `0.0` when `fog_vis[i]==1`, else `0.30`/`0.78`. |
| `:154,158-160` | Inline shader: `blend_mix, unshaded, cull_disabled, depth_draw_never`; `ALBEDO = COLOR.rgb` (black), `ALPHA = COLOR.a`. Zero fetches. |
| `:184-203` | `_build_overlay()` appends **one quad per tile** for all `_map_w * _map_h` tiles: 4 verts, 4 UVs, 6 indices, 4 colours, with `base = _fog_vertices.size()` (so `base == i*4`). At 320² this is 102,400 quads `[D]` (P05 `:181-183`). |
| `:136-144` | `_set_tile_color(i, a)` writes colour into slots `i*4 … i*4+3`. |
| `:205-214` | One `ArrayMesh`, one `MeshInstance3D` named `FogOverlay`, `material_override`, `sorting_offset = 10.0`. |
| `:213,316-317` | `_overlay.visible = bool(Data.FOG_OF_WAR)` only at bind and inside the `changed` branch of `_update_fog()`. |
| `:218-228` | `_refresh_mesh()` early-returns if `_fog_vertices.is_empty()`, else `clear_surfaces()` + `add_surface_from_arrays(...)` from the stored arrays. |
| `:303-318` | Full-map pass; on any `fog_vis` transition it updates `_tile_alpha[i]`, calls `_set_tile_color(i,a)`, and calls `_refresh_mesh()` once when `changed`. |
| `:234-235` | `_update_fog()` early-returns when `Data.FOG_OF_WAR` is false. |
| `:47-50` | `fog_explored`, `fog_vis`, `fog_counts` are public and aliased by `world3d.gd:654-655`; their **semantics and size must not change**. |
| `world3d.gd:694-700,754-761` | `fog.sync(dt)` per frame; forced `_update_fog()` on F9 load; `fog_revision` bumps only when the aliased `fog_vis` actually changes. |

**Why compaction is safe `[D]`:** for an alpha-0 quad the blend equation is
`out = src.rgb * 0 + dst.rgb * 1 = dst.rgb`; `depth_draw_never` means no depth side effect; `cull_disabled`
means no other pass reads the tri. Removing those triangles cannot change a pixel. All remaining quads
share the same black colour, so their mutual blend order is irrelevant; `sorting_offset` is a
per-`MeshInstance3D` property, unchanged. `t_fog3d.gd` does not pin a quad count.

**Two independent skip conditions to implement** (the ticket's "fully transparent / fog-mode-off"):

| Condition | Test | Rationale |
|---|---|---|
| Fully transparent tile | `_alpha_for(i) <= 0.0` (i.e. `fog_vis[i]==1`) | alpha ladder `:41,128-133` → no pixel contribution `[D]` |
| Fog mode off | `not bool(Data.FOG_OF_WAR)` | overlay is invisible anyway (`:213`); emitted quads are never drawn `[O/D]` |

---

## 3. Exact proposed fix — `variant3d/scripts/world3d_fog.gd`

Implementation is **proposal only**. Line numbers refer to the current 318-line file; each hunk
names the current range. Tabs are literal GDScript indentation. The hunks rely only on symbols
already present plus three new members and one new private function.

### Hunk A — new state members (after current `:60`)

```gdscript
var _tile_alpha: PackedFloat32Array = PackedFloat32Array()
var _tile_slot: PackedInt32Array = PackedInt32Array()  # P14: tile i -> compacted quad slot; -1 = no quad
var _fog_h: PackedFloat32Array = PackedFloat32Array()   # P14: cached height grid for rebuilds
var _fog_enabled: bool = false                          # P14: last Data.FOG_OF_WAR seen by sync()
```

`_tile_alpha` stays `n`-sized and keeps its meaning; `_tile_slot` is the only new index indirection.

### Hunk B — `bind()`, replace current `:97-113`

Old (`:97-113`): the `fog_counts`/`_tile_alpha` resize, timer reset, `_built = _build_overlay()`, the
`for i in n: _tile_alpha[i] = _alpha_for(i); _set_tile_color(i, ...)` loop, `_refresh_mesh()`,
`_update_fog()`.

New:

```gdscript
	fog_counts = PackedInt32Array()
	fog_counts.resize(n)
	_tile_alpha = PackedFloat32Array()
	_tile_alpha.resize(n)
	# P14: dense tile -> quad-slot map and cached height grid.
	_tile_slot = PackedInt32Array()
	_tile_slot.resize(n)
	_tile_slot.fill(-1)
	# game.height is optional: the t_fog3d.gd stub has no such field. Use a
	# flat y=0 overlay there; in a real game sample the generated height grid
	# (variant3d/scripts/game.gd:44, :364). Alignment with world3d_terrain.gd's
	# dump-derived heights is an OPEN QUESTION (see report).
	_fog_h = PackedFloat32Array()
	var hs_bind = game.get("height")
	if hs_bind is PackedFloat32Array and (hs_bind as PackedFloat32Array).size() == n:
		_fog_h = hs_bind
	_fog_enabled = bool(Data.FOG_OF_WAR)

	_fog_timer = float(Data.FOG_INTERVAL)
	_fog_tick = 0
	_fog_last_pos.clear()
	_fog_unit_count = 0
	_built = _build_overlay()
	if not _built:
		return
	# P14: one compacted build pass replaces the per-tile append loop + colour loop.
	_rebuild_geometry()
	_refresh_mesh()
	_update_fog()
```

The four-line height comment is moved **verbatim** from current `:175-178`; the OPEN QUESTION is
not silently dropped. The public arrays are still sized `n` before any mesh work, so
`world3d.gd:654-655` still aliases full-size arrays and `t_fog3d.gd:175-178` still passes.

### Hunk C — `sync()`, replace current `:116-125`

```gdscript
func sync(dt: float) -> void:
	if game == null or not _built:
		return
	# P14: rebuild the compacted quad set when the fog mode is toggled at runtime.
	# Do NOT write _overlay.visible here: the existing transition write at the
	# end of _update_fog() is preserved byte-for-byte (no behaviour change).
	var enabled: bool = bool(Data.FOG_OF_WAR)
	if enabled != _fog_enabled:
		_fog_enabled = enabled
		_rebuild_geometry()
		_refresh_mesh()
		return
	# 2D gates the recount on FOG_INTERVAL (world.gd:833-836, :336). dt is
	# sim-agnostic; this accumulator keeps the same cadence.
	_fog_timer -= dt
	if _fog_timer > 0.0:
		return
	_fog_timer = float(Data.FOG_INTERVAL)
	_update_fog()
```

The early-return on a toggle frame leaves `_fog_timer` untouched, matching the pre-existing cadence.
The toggle itself keeps the old visibility semantics: `FogOverlay` becomes visible only on the next
`changed` branch (`_update_fog()` end), so no visual behaviour is introduced.

### Hunk D — new `_rebuild_geometry()`, insert after `_alpha_for()` (between current `:133` and `:136`)

```gdscript
# P14 — compacted fog geometry. A tile emits a quad only when fog mode is ON and
# its ladder alpha is > 0; ALPHA_VISIBLE=0.0 tiles are dropped under blend_mix.
# Triggered from bind(), sync() mode transitions and _update_fog() changes, so
# the mesh always mirrors the public fog_* arrays. No shader/uniform/array change.
func _rebuild_geometry() -> void:
	var n: int = _map_w * _map_h
	if _tile_slot.size() != n:
		_tile_slot.resize(n)
	if _tile_alpha.size() != n:
		_tile_alpha.resize(n)
	_tile_alpha.fill(0.0)
	_tile_slot.fill(-1)
	_fog_vertices = PackedVector3Array()
	_fog_uvs = PackedVector2Array()
	_fog_indices = PackedInt32Array()
	_fog_colors = PackedColorArray()
	if not bool(Data.FOG_OF_WAR):
		return
	for ty in range(_map_h):
		for tx in range(_map_w):
			var i: int = ty * _map_w + tx
			var a: float = _alpha_for(i)
			_tile_alpha[i] = a
			if a <= 0.0:
				continue
			var wy: float = (_fog_h[i] if _fog_h.size() == n else 0.0) + FOG_Y_OFFSET
			# Centred tile-corner mapping mirrors variant3d/scripts/world3d.gd:215-220.
			var wx: float = (float(tx) - float(_map_w) * 0.5) * _tile_m
			var wz: float = (float(ty) - float(_map_h) * 0.5) * _tile_m
			var base: int = _fog_vertices.size()
			_fog_vertices.append(Vector3(wx, wy, wz))
			_fog_vertices.append(Vector3(wx + _tile_m, wy, wz))
			_fog_vertices.append(Vector3(wx + _tile_m, wy, wz + _tile_m))
			_fog_vertices.append(Vector3(wx, wy, wz + _tile_m))
			_fog_uvs.append(Vector2(0.0, 0.0))
			_fog_uvs.append(Vector2(1.0, 0.0))
			_fog_uvs.append(Vector2(1.0, 1.0))
			_fog_uvs.append(Vector2(0.0, 1.0))
			_fog_indices.append_array([base, base + 2, base + 1, base, base + 3, base + 2])
			for k in 4:
				_fog_colors.append(Color(0.0, 0.0, 0.0, a))
			_tile_slot[i] = base / 4
```

Quad geometry, winding (`base, base+2, base+1, base, base+3, base+2`), UVs, `FOG_Y_OFFSET` and the
centred corner mapping are copied byte-for-byte from current `:187-203`; only the guard and the
slot write are new. `base / 4` is integer division because `base` is an `int`; the defensive
resizes are inert in the normal bind path.

### Hunk E — `_set_tile_color()`, replace current `:136-144`

```gdscript
func _set_tile_color(i: int, a: float) -> void:
	# P14: tile i maps to a compacted slot, not i*4; -1 means no quad was emitted.
	var slot: int = -1
	if i >= 0 and i < _tile_slot.size():
		slot = _tile_slot[i]
	if slot < 0:
		return
	var base: int = slot * 4
	if base + 3 >= _fog_colors.size():
		return
	var c := Color(0.0, 0.0, 0.0, a)
	_fog_colors[base] = c
	_fog_colors[base + 1] = c
	_fog_colors[base + 2] = c
	_fog_colors[base + 3] = c
```

This is the critical remap: without it, a revealed tile would later tint whichever tile now occupies
slot `i`. The map is deterministic (row-major, skip-if-transparent), so tinting stays aligned `[D]`;
actual GPU correctness remains `[U]` until the fog atom is run by G04.

### Hunk F — `_build_overlay()`, replace current `:168-203` with the shell; keep `:205-215` unchanged

```gdscript
func _build_overlay() -> bool:
	# P14: the quad arrays are produced by _rebuild_geometry() (bind / mode toggle /
	# fog-state change). This function owns only the mesh + material shell.
	_fog_vertices = PackedVector3Array()
	_fog_uvs = PackedVector2Array()
	_fog_indices = PackedInt32Array()
	_fog_colors = PackedColorArray()
```

Unchanged after it: `_overlay_mesh = ArrayMesh.new()` … `add_child(_overlay)` / `return true`
(current `:205-215`), including `_overlay.name = "FogOverlay"`, `sorting_offset = 10.0`,
`_overlay.visible = bool(Data.FOG_OF_WAR)` and `_make_fog_material()` (current `:147-165`).
The quad loop is **moved**, not duplicated — it now lives only in Hunk D.

### Hunk G — `_refresh_mesh()`, replace current `:218-221`

```gdscript
func _refresh_mesh() -> void:
	if _overlay_mesh == null:
		return
	_overlay_mesh.clear_surfaces()
	# P14: fog mode off / all tiles visible -> no surface, not a stale full-grid mesh.
	if _fog_vertices.is_empty():
		return
```

The original early-out at `:219` would have left a stale surface when the last quad disappears;
moving `clear_surfaces()` above it is required for the compaction to actually take effect. Remaining
lines `:222-228` (`arrays` + `add_surface_from_arrays`) are unchanged.

### Hunk H — `_update_fog()` change gate, replace current `:311-318`

```gdscript
		var a: float = _alpha_for(i)
		_tile_alpha[i] = a
		_set_tile_color(i, a)
		changed = true
	if changed:
		# P14: every vis transition crosses the alpha-0 boundary, so the
		# compacted quad set must be rebuilt before the surface is refreshed.
		_rebuild_geometry()
		if _overlay != null:
			_overlay.visible = bool(Data.FOG_OF_WAR)
		_refresh_mesh()
```

`_set_tile_color(i,a)` / `_tile_alpha[i] = a` are retained even though `_rebuild_geometry()` rewrites
both — they are harmless and keep the change-gate structure recognisable. `changed` is only set on a
`fog_vis` flip (`:308-314`), and every such flip changes alpha across `0.0` (`0.78|0.30 ↔ 0.0`),
so the rebuild cadence matches the set of quads that must appear/disappear `[D]`.

### Line-number and citation impact

Unlike `terrain_tileindex.gdshader` (502-line invariant, `P05:354-357`) **no report pins a line count
for `world3d_fog.gd`**. Hunk F removes ~30 lines and Hunk D adds ~35, so P05's cited fog anchors
(`:174-193`, `:218-228`, `:301-314`, `:352`) shift after implementation; P14 is read-only and does
not rewrite them — COORD should refresh those citations when integrating. No test reads those line
numbers (`t_fog3d.gd` uses constant strings only).

### Backup instruction (before any edit)

From the workspace root, with the file still untouched:

```powershell
Copy-Item -LiteralPath variant3d\scripts\world3d_fog.gd -Destination inbox\backup\world3d_fog.gd.bak-P14
Test-Path inbox\backup\world3d_fog.gd.bak-P14
Get-FileHash -Algorithm SHA256 variant3d\scripts\world3d_fog.gd, inbox\backup\world3d_fog.gd.bak-P14
```

Naming follows `CHARTER.md:66` (`inbox/backup/<file>.bak-<TICKET>`) and the existing
`inbox/backup/*.bak-P*` convention. The two hashes must match before editing. Rollback is a straight
`Copy-Item` back. **No backup was created by P14** (read-only ticket).

---

## 4. Acceptance criteria

All three named acceptance items are checks on the **proposed** patch; P14 has not run them.

### 4.1 `t_fog3d` — must stay green, unweakened

- Run only by **G04** (`WAVE_G_CHARTER.md:31,67-70`), unique id, never by the implementer or P14.
- The last green baseline is `variant3d/tests/results/t_fog3d.json`: 9 checks, `status: PASS`.
- Must still pass all nine: `module_loads`, `instance_created`, `bind_api`, `sync_api`,
  `sync_callable`, `fog_explored_exposed` (size 12), `fog_vis_exposed` (size 12),
  `no_fullmap_sprite2d`, `no_new_hangs` (`t_fog3d.gd:148-189`).
- Structural companion `_v716_probe.gd:32-40` requires the `FogOverlay` child to remain a
  `MeshInstance3D` with a mesh surface. **Caveat:** with the shipped default fog off the new
  `_refresh_mesh()` emits **zero** surfaces, so that probe's `overlay_mesh_surface_count` would
  read 0 instead of 1. The probe is marked TEMPORARY / "not a manifest test" (`_v716_probe.gd:3`)
  and is not in the gate set; still, COORD should decide whether to re-run it with
  `Data.FOG_OF_WAR = true` rather than treat a 0 as a regression. No manifest test pins a surface
  count.
- **Do not** add, delete, loosen or invert any assertion in `t_fog3d.gd`; no quad-count assertion is
  added as a "test fix" (that would be test weakening in reverse and is unnecessary).

### 4.2 `fog_mode = 0` donor default — must remain untouched

- `terrain_tileindex.gdshader:198` declares `uniform float fog_mode = 0.0;` with the donor
  citation `colors.lib:36` / `TERRAIN2-01 E65`; `world3d_terrain.gd:742-743` binds `0.0`
  explicitly with donor cite `colors.lib:23,34-43` / `DTRN-01 C20`. The shader branch at
  `:456-466` is therefore runtime-not-taken `[O/D]` (P05 `:68-70`).
- The compaction is **GDScript-only**. `world3d_fog.gd` never references `fog_mode`, never edits the
  terrain shader, and must not be used as a pretext to change `fog_mode`, `fog_color`, `fog_density`
  or the `:478-502` A/B block. Donor camera default `DynFogDepth=False` in game mode
  (`world3d_fog.gd:21`) confirms there is no donor view-depth fog to preserve here.
- Do **not** conflate this with fog-of-war: the overlay's mode gate is `Data.FOG_OF_WAR`, whose
  shipped default is `false` (`data.gd:55`, `config.json:47,56`, `config.gd:488`). Hunks D/G make
  that off-state emit **no geometry**, which is pixel-neutral because the overlay is invisible
  already (`:213`) `[D]`.

### 4.3 Water / shore gates — must remain untouched

- `t_terrain_shore.gd` contains **zero** `fog` references (grep result), asserts exactly one water
  plane and one module, and the hard `WATER_LEVEL = −0.25` invariant (`P05:167-168`, A10 §4).
- The patch touches **only** `world3d_fog.gd`: do not edit `water3d.gd`, `water3d.gdshader`,
  `water_overlay.gdshader`, `world3d_terrain.gd`, `terrain_tileindex.gdshader`, or
  `t_terrain_shore.gd`. The `FogOverlay` node is a sibling of `WaterPlane` under the same 3D root;
  changing its index buffer cannot alter water geometry, uniforms or the single-plane count `[D]`.
- Full gate set after integration (all owned/executed by G04): variant selftest 29/29, uitest 17/17,
  `t_render_mode`, `t_terrain_shore`, `t_fog3d`, `assert_clean CLEAN`, 2D `app/` untouched —
  CHARTER `:128-130`.

### 4.4 Visual / performance evidence

- Pixel identity with fog-of-war ON and a partially revealed map requires a fresh windowed capture
  with `fog_of_war = true`; **no such capture exists** → pixel claim UNVERIFIED.
- **All FPS/frame-time claims are UNVERIFIED.** No capture, profiler, GPU timer or disassembly was
  produced by P14, and the ticket forbids running Godot. In particular: "zero quads after full
  reveal" is a count `[D]`, not a measured saving; "start-up FPS improves" is contradicted in
  expectation by the shipped `FOG_OF_WAR = false` default `[D]` and is UNVERIFIED either way.
- Secondary cost to watch: `_rebuild_geometry()` adds one extra full-map `n`-loop on every changed
  fog tick (Hunk H) and on mode toggles. At 320² this is a non-trivial additional CPU pass; whether
  it outweighs the removed transparent triangles is **UNVERIFIED** without a profiled run. This is
  the main reason to require a capture rather than assuming a win.

---

## 5. UNVERIFIED register / open questions

1. Pixel identity of the compacted mesh — needs a fresh fog-enabled capture (§4.4).
2. Any FPS, frame-time, blend-bandwidth or draw-call number — none measured; all `[I]` at best.
3. Whether `Data.FOG_OF_WAR` can be toggled at runtime in 3D in a way that bypasses `world3d_fog.sync()`
   (e.g. `main.gd:1561-1562` writes `world.fog_sprite.visible`, which in 3D is the
   `FogVisibilityProxy3D` node from `world3d.gd:620-622`, not the overlay). Hunk C handles toggles
   only through `sync()`; a bypass path would leave geometry stale until the next `changed` tick —
   UNVERIFIED, and unchanged from today's visibility behaviour.
4. The pre-existing explored-but-not-visible alpha staleness: `_update_fog()` skips on
   `fog_vis[i] == v` (`:308`), so `fog_explored 0→1` without a visibility flip leaves
   `_tile_alpha[i]` at `0.78` instead of `0.30`. Hunk D derives slot membership from `_alpha_for(i)`
   (which would say `0.30`) while writing `_tile_alpha[i]` from the same value — this could alter
   the **stored** `_tile_alpha` for such tiles relative to today's stale `0.78`. The rendered colour
   is rewritten from `_alpha_for(i)` in both old (`:201-203`) and new paths, so no visual change is
   expected `[D]`, but the internal `_tile_alpha` value change is UNVERIFIED against any consumer
   (grep shows only internal uses at `:60,100,110-111,312`). If strict internal parity is required,
   change Hunk D's membership test to `_tile_alpha[i]` from the previous state instead; flag for
   COORD.
5. Whether `_v716_probe.gd`'s surface-count expectation should be updated for the fog-off default —
   COORD decision, not P14's (§4.1).
6. P07 node-count findings, if that report lands, may add a hidden-node observation not considered
   here (§0).

---

## 6. Bottom line for COORD

- Safe, output-identical-by-derivation proposal: **one file**, `variant3d/scripts/world3d_fog.gd`,
  no shader/uniform/test/config change; skip alpha-0 tiles and skip all tiles when fog mode is off;
  rebuild only on the existing change gate plus a mode-toggle branch.
- Requires an **exclusive-ownership grant** before implementation (no current owner) and the backup
  `inbox/backup/world3d_fog.gd.bak-P14` before the first edit.
- Expected start-up benefit is **nil** at shipped defaults (`FOG_OF_WAR = false`); any benefit is
  conditional on fog being enabled and is **UNVERIFIED** — do not publish an FPS number without a
  real capture run by G04.
- Preserve the three acceptance anchors: `t_fog3d` green and unweakened; `fog_mode = 0.0` donor
  default untouched; water/shore gates and files untouched.

*End of P14 report. Read-only; one report; zero code edits; zero Godot/runner jobs; no donor-parity or FPS claim.*
