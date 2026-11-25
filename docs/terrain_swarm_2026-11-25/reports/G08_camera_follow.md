---
id: G08
title: "G08 — Camera-follows-drag (F03 G1): minimal safe additive proposal, disjoint from B05's file"
owner: G08 (WAVE G standing swarm)
date: 2026-11-25
status: READ_ONLY__ONE_REPORT__NO_CODE_EDIT__NO_RUNNER
scope: "Exactly one new file written — this report. No repo code/config/asset/test/scene/shader/git edit. No Godot process or runner job. No donor execution."
charter: "docs/terrain_swarm_2026-11-25/CHARTER.md; WAVE_G_CHARTER.md assignment G08"
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, PORT_APPROXIMATION]
sources_read:
  - docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
  - docs/terrain_swarm_2026-11-25/CHARTER.md
  - docs/terrain_swarm_2026-11-25/reports/F03_selection_online.md
  - docs/terrain_swarm_2026-11-25/reports/D02_selection_quad_donor.md
  - docs/terrain_swarm_2026-11-25/reports/B05_selection_impl.md
  - docs/terrain_swarm_2026-11-25/reports/D01_selection_quad_audit.md
  - docs/coord_swarm_2026-11-25/reports/CAM_RV_01_view_rect_runtime.md
  - variant3d/scripts/camera3d.gd, input_controller.gd, config.gd, hud.gd, world3d.gd
  - variant3d/tests/t_view_rect_rv.gd (read only; no job submitted)
output: docs/terrain_swarm_2026-11-25/reports/G08_camera_follow.md
---

# G08 — camera-follows-drag: additive proposal

## 0. Goal and boundaries

F03's highest-priority gap is **G1**: the official 2016-11 patch says the **map moves with
you while you drag the selection frame**, so an army larger than one screen can be boxed.
B05 explicitly ruled this out of its grant and handed it to the **camera owner
(`camera3d.gd` / `world3d.gd`)** (B05 report §5 item 2, `:288-291`). WAVE G assigns G08 as a
**proposal only**, disjoint from B05's file (`input_controller.gd`).

Nothing below is a code change. Line numbers are from the current tree, read this task.

---

## 1. Donor text — OBSERVED; mechanism — UNVERIFIED

**OBSERVED (official text, quoted in F03 §Finding 1 and D02 §3.1).** GSC Steam announcement
*"The Cossacks 3 Mod Manager is here + selection frame dragging ability!"*, 12 Nov 2016.
English item 2 says the frame lets you "select your grand armies even if they take more place
than could fit on one screen". The RU text adds the decisive clause:

> "Добавлена рамка выделения. **Теперь, когда тянете рамку, карта двигается с вами.** …"
> ("Selection frame added. **Now when you drag the frame, the map moves with you.** …")

UA is identical in meaning ("… карта рухається з вами"). The 20.11.2016 patch (1.1.6.53.4130)
then fixed an error "when moving the camera simultaneously with the selection frame when
mouse and keyboard scroll speeds differed" (F03 S2; D02 §3.1), i.e. frame and camera pan run
**concurrently**.

**UNVERIFIED.** The *mechanism*: no donor script line ties a pan speed or edge-band width to
the drag state; `SetClipCursor` is only an almanac secondary mention; no donor GPU A/B frame
exists. D02 §6 conflict 3 is binding: **"Do not invent an edge-scroll speed."** F03 O2
(band/speed numbers) stays open. Therefore every numeric behaviour in §3 is **reused from
an existing donor-cited port path**, not newly invented; donor parity remains UNVERIFIED.

---

## 2. Port state (OBSERVED from code)

| # | Observation | Source (current tree) | Label |
|---|---|---|---|
| P1 | Drag state lives **only** in `input_controller.gd` (B05's file): `drag_start`, `dragging`, `_drag_current`, `_rect_ground_anchor`, `_sel_ground_start`, `_mm_dragging`; the node joins group `"c3_input"`. | `input_controller.gd:29-42,77,167` | OBSERVED |
| P2 | The world selection rect is recomputed **every `_process` frame** from the press-frozen SIM anchor plus the live cursor ground point, and applied live in 3D. The visible yellow box is built from fixed **screen** pixels `Rect2(drag_start, cur-start).abs()`. | `input_controller.gd:653-665,671-702,1484-1537` | OBSERVED |
| P3 | B05 froze `_rect_ground_anchor` precisely so a mid-drag camera pan/zoom does **not** slide the world rect off the visible box; the world rect therefore **extends** as the camera moves while `drag_start` stays fixed in screen space — the anti-S7 shape. | `input_controller.gd:35-42,850-857,974-989`; D04 §"Offset" `:162` | OBSERVED + DERIVED |
| P4 | `camera3d.gd:_process()` **already has** a donor-grounded mouse/keyboard edge-scroll + middle-drag pan: band `edge_margin=8` / `corner_margin=24`, depth ramp `1+3d²` (cap 4×), log dwell (cap 3×, total 6×), speed `profile*4` (default `0.5 → 2.0`), all **zoom-independent**, `dt` clamped to 0.05, then `clamp_pos()`. It is gated by `not middling` **only** — no LMB-drag test, **no minimap test**. | `camera3d.gd:144-168,589-686`; `data.gd:164-167`; DEEPDEC-01 §6 item 5 | OBSERVED |
| P5 | Minimap pan also writes `_target`: `input_controller._minimap_reposition()` calls `camera.call("jump_to_world", wp)`; `hud.gd:_cam3d_jump()` calls `camera.call("jump_to_world_donor_offset", wp)`. Both jump APIs are byte-sensitive (§4). | `input_controller.gd:402-418`; `hud.gd:1635-1658`; `camera3d.gd:444,560` | OBSERVED |
| P6 | F03 G1 / D02 item 14 / B05 `:226,:272` state "no camera-follows-drag". Against P4 this is a **discrepancy**: a *generic* edge scroll exists and fires while LMB is held; what is absent is a **drag-scoped, opt-in, minimap-aware** follow, and the minimap case is actively unsafe (P4 vs P5 both write `_target`). | F03 `:283`; D02 `:166`; B05 `:226,272`; code P4/P5 | DERIVED — flagged for COORD, not resolved here |
| P7 | `camera3d.PROCESS_PRIORITY = -100` (pan before `world.sync()`/HUD box). `input_controller._process` has default priority 0, so a camera pan applied in the camera's `_process` is visible to the same frame's world-rect recompute (P2). | `camera3d.gd:168`; `input_controller.gd:1484` | OBSERVED + DERIVED |
| P8 | Config is a static singleton `ConfigScript.active`; feature getters use `value()/num()/flag()` with baked defaults. `camera3d.bind()` already reads raw `cfg.num("camera.*", default)` keys without adding getters (`:196-208`). | `config.gd:46-86,268-271,389-404,425-473`; `camera3d.gd:190-208` | OBSERVED |

Consequence: **do not add a second pan implementation**. Reuse P4's existing, donor-cited
path; the new work is a *gate* around it plus one config key. This also satisfies D02's
"do not invent an edge-scroll speed" and F03 G9 (avoid the S7 "box shifts instead of
resizing" failure).

---

## 3. Proposal — minimal safe additive patch

### 3.1 File / function

**Sole implementation file: `variant3d/scripts/camera3d.gd`.** No edit to
`input_controller.gd` (B05's file), `world3d.gd`, `hud.gd`, `config.gd`, any test, or any
scene. (`config.gd` needs no change — see §5.)

Add, all inside `camera3d.gd`:

1. **Two new fields** near the edge-scroll tunables (`:144-156`):
   `var _marquee_follow_on_drag: bool = false` and
   `var _marquee_follow_input: Object = null` (lazily resolved via
   `get_tree().get_nodes_in_group("c3_input")`, null-safe; never caches a freed node).
2. **Seed the flag in `bind()`** (`:190-208`), null-safe like the existing camera keys:
   `if cfg != null: _marquee_follow_on_drag = cfg.flag("features.selection.camera_follow_on_drag", false)`.
   When no config instance is active (isolated atoms), the flag is `false`.
3. **One new private helper** `_marquee_follow_state(m: Vector2) -> Dictionary` (or two
   small bool helpers) that returns `{drag_active, pointer_on_minimap, follow}`:
   - `drag_active` = an input node is found, `render_mode == "3d"`, `dragging == true` and
     `drag_start != Vector2.INF` (read via `get()` on the group member — no type dependency
     on B05's file, no new public method there);
   - `pointer_on_minimap` = `input._mm_dragging == true` **or** the cached minimap rect
     (`_minimap_screen_rect()` via dynamic `call`) contains `m`; if either source is
     unavailable, treat as **not on minimap** and let the drag test decide;
   - `follow` = `_marquee_follow_on_drag and drag_active and not pointer_on_minimap
     and (edge_margin > 0.0 or corner_margin > 0.0)`.
4. **One existing condition line changed in `_process()`** (`:614`), from
   `if not middling:` to
   `if not middling and _follow_gate_allows(m, drag_active, follow, pointer_on_minimap):`
   with the helper returning `true` when (a) no marquee drag is active **and** the pointer
   is not over the minimap — preserving today's generic edge scroll verbatim — or (b) a
   drag is active and `follow == true`. When a drag is active and the key is **off**, or the
   pointer is on the minimap, the mouse-edge contribution is suppressed; arrow keys, middle
   drag, zoom, `_apply_transform()` and `clamp_pos()` are **not** touched.

**No new `_target +=` write, no new speed constant, no new band constant, no new camera
API.** The existing `dir` / `depth` / `dwell` / `mouse_m` block (`:612-686`) stays exactly as
it is; it is simply allowed or disallowed during a drag. That is the whole feature.

### 3.2 Why this composes with the selection quad without touching B05's file

- The yellow frame keeps `drag_start` in fixed screen pixels (P2/P3), so it **never shifts
  with the view** — the S7 "box shifts instead of resizing" failure mode is structurally
  excluded.
- The world rect keeps extending because `_drag_world_rect()` re-unprojects the *live*
  cursor pixel each frame against the panned camera, against the press-frozen SIM anchor
  (P2/P3). Priority order (P7) makes that happen in the same frame.
- The minimap viewport box (`hud3d_adapter.get_minimap_box()`) reads the live camera
  transform, so it follows the pan with no code change.

### 3.3 S2 "keyboard and mouse scroll speeds differed" — handled by reuse

The patch never introduces a follow-specific speed. During a drag, pan goes through the
same `dir` and the same `speed = key_m if arrows else mouse_m * mouse_mult` expression
(`:681-684`); `mouse_m` and `key_m` both derive from the donor `profile.script:17-20`
keys (`mouse_scroll_speed_profile`, `key_scroll_speed_profile`, default 0.5). A single
code path cannot run the two speeds at different rates, so the donor fix is preserved by
construction rather than re-implemented with a guessed constant. (Donor numeric equality is
still UNVERIFIED; this is a **PORT APPROXIMATION** of the fix.)

---

## 4. Compatibility guarantees (hard constraints on the implementer)

### 4.1 CAM-RV-01 — keep the 20/20 view_rect atom unchanged and green

`variant3d/tests/t_view_rect_rv.gd` (job 381 = 20/20) must be **byte-identical** and must
still produce 20/20. The patch guarantees this four ways:

1. **Jump API untouched.** The atom sets a known pose with
   `_cam.call("jump_to_world", _half)` at `:232`. `jump_to_world()` (`camera3d.gd:444-453`)
   stays byte-identical; the follow code never calls it.
2. **view_rect chain untouched.** `get_viewport_corners()` (`:397-405`),
   `get_view_rect()` (`:409-421`) and `world3d._update_view_rect()` (`world3d.gd:247-293`)
   are not edited. The atom's independent expectation (`:253-296`) and
   `view_rect_equals_expected` (`:312`), `minimap_box_consistent_with_view_rect` (`:372`),
   `view_rect_stable_after_clicks` (`:432`) therefore still measure the same quantities.
3. **The atom already neutralises edge scroll** by zeroing `_cam.edge_margin` and
   `_cam.corner_margin` at `:236-237`, then asserts `camera_pose_stable`
   (`_target` drift < 0.5 m, `:441`). The new gate deliberately inherits that
   neutralisation: its band test is exactly `edge_margin > 0 or corner_margin > 0`. With
   both zero, `follow == false` even if someone flips the config key — the pose cannot
   drift. **No new independent margin/speed field may be introduced**, or this
   neutralisation would be bypassed.
4. **The atom never drags.** It drives two button pairs for double-click (`:392-401`),
   so `drag_active == false` and the gate is false on every frame. Config default is also
   false. Net: the new code is a no-op in that atom.

### 4.2 MMJUMP-02 — jump APIs byte-identical

`camera3d.gd:444-453 jump_to_world()` (plain-centre, used by CAM-RV-01 *and* by
`input_controller.gd:412` for minimap click/drag) and `:560-587 jump_to_world_donor_offset()`
(donor-offset, used only by `hud.gd:1657`) must remain **byte-identical**, including their
comments and constants at `:62-75`. The follow helper:
- does **not** call either method;
- does **not** call `apply_external_target()` (`:511`) either — that would create a second
  `_target` writer with its own memo invalidation and could disturb `camera_pose_stable`;
- writes `_target` only through the pre-existing `_target += dir*speed*dt` statement at
  `:684`, already guarded by `clamp_pos()`.

### 4.3 Disable follow on minimap drag

Explicitly required, and currently unsafe (P4/P5): while `_mm_dragging` is true, or the
pointer lies inside `hud.minimap_rect.get_global_rect()`, `follow == false` and the mouse
edge-scroll contribution is suppressed for that frame. The minimap jump owns `_target`
exclusively. B05's `_cancel_drag()` (`input_controller.gd:234-240,779-795,951-962`) already
clears `dragging` on minimap entry, so this is belt-and-braces, not the sole guard. The
gate must not suppress arrow-key or middle-drag panning on those frames.

### 4.4 Do-not-copy checks retained

- Wall bug (F03 Finding 5, D02 item 36): follow does not touch the entity filter in
  `_apply_rect_selection()`; the "select a wall, then box-select units" regression stays
  valid.
- No `spmFrame` literal, no Ctrl-drag remove, no screen-space `select_in_rect()` substitute
  is introduced (D02 §6 conflicts 1-2; S-25-06 keeps the world ground rect).

---

## 5. Opt-in config key and reversibility

**Key:** `features.selection.camera_follow_on_drag` — **bool, default `false`**.

- Read with `cfg.flag("features.selection.camera_follow_on_drag", false)` in
  `camera3d.bind()`, the same null-safe raw-key pattern already used at `:196-208`.
- **No `config.gd` edit needed**: `flag()` (`:402-404`) already returns the fallback when a
  key or the whole `features` section is absent. (If COORD prefers a typed getter and a
  defaults entry, add `"camera_follow_on_drag": false` to `FEATURES_DEFAULTS.selection`
  (`:47-53`) and a `feature_selection_camera_follow_on_drag()` getter beside `:438-439` —
  but that widens file ownership, so it is **not** part of this minimal proposal.)
- **Reversible:** set the key to `false` (or delete it) and the port returns to its exact
  current behaviour; no persisted state, no migration, no test expectation changes. The
  key gates only the new drag-scoped allowance — it deliberately does **not** disable the
  pre-existing generic edge scroll, which stays as shipped.
- **Optional companion keys, only if a future owner needs tuning** (not required, and not
  to be invented as donor literals): reuse `camera.edge_depth_gain`, `camera.edge_depth_max`,
  `camera.edge_dwell_*`, `camera.edge_total_max` and `camera.mousescrollspeed` (`:198-208`).
  Do **not** add a `camera_follow_speed` constant.

---

## 6. Acceptance criteria / verification plan (proposal only — nothing run here)

All checks are for a **future implementation owner with runner access**; G08 ran no Godot
process and submitted no job.

1. **Static gate:** `t_view_rect_rv.gd` untouched → re-run yields **20/20**, in particular
   `view_rect_equals_expected`, `minimap_box_consistent_with_view_rect`,
   `view_rect_stable_after_clicks`, `camera_pose_stable`.
2. **Static gate:** `jump_to_world()` and `jump_to_world_donor_offset()` bodies (including
   constants `:58-75`) compare byte-identical to the current tree; no new caller added.
3. **Opt-in OFF:** windowed drag to the right edge for N frames with the key absent →
   camera `_target` unchanged by the follow path (generic edge-scroll baseline only);
   overlay still anchored; selected ids unchanged.
4. **Opt-in ON:** same drag → `_target.x` advances, overlay `get_selection_rect()` still
   reports the original press pixel as its corner (S7 guard), world-rect right edge
   advances, and an own player-0 unit that was initially off-screen becomes selected.
5. **Minimap:** with `_mm_dragging` true → no follow contribution; camera target equals the
   minimap jump result; no drift from edge scroll on subsequent frames.
6. **Regressions:** selftest 29/29, uitest 17/17, `t_render_mode`, `assert_clean` CLEAN;
   2D `app/` untouched; wall-bug regression still passes.
7. **Labels:** any numeric band/speed retained is labelled PORT APPROXIMATION / UNVERIFIED
   for donor parity; no donor-literal claim is made.

---

## 7. Open questions — UNVERIFIED / for owner decision

1. **Q1 (mechanism).** Edge band width, pan speed and cursor clamping behind "карта
   двигается с вами" are not recoverable from the official prose (D02 §8 q3, F03 O2/O3).
   Reusing P4's tunables is an honest PORT APPROXIMATION, not a reconstructed donor value.
2. **Q2 (scoping).** P6 discrepancy: is F03/D02/B05's "no camera pan while dragging" simply
   stale relative to the existing edge-scroll code, or is there a runtime reason the pan is
   suppressed during an LMB drag that static reading misses? A windowed, no-code probe by
   the runner owner could settle it before implementation; G08 could not run one.
3. **Q3 (behaviour change).** Suppressing generic edge scroll while the pointer is over the
   minimap fixes a real `_target` fight (P4 vs P5) but changes shipped feel. Needs owner
   sign-off if it is considered beyond the ticket.
4. **Q4 (test surface).** CAM-RV-01's neutralisation relies on zeroed margins; if a future
   owner adds an independent follow band, 20/20 can silently drift. Recommend a static
   audit item asserting the gate reads only `edge_margin`/`corner_margin`.
5. **Q5 (2D path).** This proposal is 3D-only (`render_mode == "3d"`); the 2D `app/` camera
   stays byte-identical. Whether the donor feature should also be mirrored in 2D is an
   owner decision outside this ticket.

---

## 8. Summary

Donor intent is **OBSERVED** (official 12 Nov 2016 RU/UA text "when you drag the frame, the
map moves with you", plus the 20 Nov 2016 frame/camera coexistence fix); the donor
**mechanism is UNVERIFIED**, so no edge-scroll speed or band may be invented. The port
already carries a donor-cited generic edge-scroll pan in `camera3d.gd:_process()` that fires
during an LMB drag but is not drag-scoped, not opt-in and not minimap-aware — a discrepancy
with F03 G1 that COORD should note. The minimal safe additive proposal is therefore a
**gate, not a second pan**: one private helper + one config flag in `camera3d.gd`, reusing
the existing `dir`/depth/dwell/speed/`clamp_pos()` path, with a single condition-line change
at `:614`. `jump_to_world()` and `jump_to_world_donor_offset()` stay byte-identical; the
CAM-RV-01 view_rect atom stays untouched and is additionally protected by inheriting its
zero-margin neutralisation; follow is hard-disabled on minimap drag; and the whole feature
is reversible with `features.selection.camera_follow_on_drag = false` (default).

No code, config, asset, test, scene, shader, Godot job or git state was changed. Exactly one
report file was written.
