---
id: FIX-MOVE
title: "FIX-MOVE — right-click ground order direction: full order-path trace, no remaining axis/sign defect in the 3D pick adapter"
owner: FIX-MOVE
scope: "READ-ONLY trace of variant3d/scripts/input_controller.gd + variant3d/scripts/picking3d.gd (the two owned scripts) and shared sim/camera files. NO source edits were required: the owned order path already passes the same SIM Vector2 frame the byte-identical sim expects, and the 160 m offset regression was fixed by FIX-SEL. One report only. No git, no app/, config, tests, world3d*.gd, main.gd or camera3d.gd edits."
date: 2026-11-24
status: STATIC_TRACE_ONLY
verdict: "CLOSED — static trace complete, no source diff. The right-click ground order reaches game.cmd_move(e, dest) with dest in SIM metres, top-left map origin, Vector2(x = world.x + MAP_W*TILE/2, y = world.z + MAP_H*TILE/2). No x/z swap, sign flip or pixel/metre residue. The shared sim (byte-identical to 2D) computes dir = (aim - e.pos).normalized(), e.pos += dir*step and e.face = atan2(dir.y, dir.x) in that same frame; direction dot product = +1 on a clear path. The only measured destination defect (offset (0,0) instead of (160,160), FIX-SEL jobs 260/266) is already fixed (jobs 276/279: exact dest (155,155)). The user's report is therefore most consistent with a STALE PRE-FIX-SEL BUILD; the separate visual-facing ('strafe look') concern from mesh yaw = -face is being handled separately by FIX-COLOR in the 3D renderer. Per user speed request, all remaining parse/probe/selftest jobs were SKIPPED; no probe was created, so nothing to delete. No Godot jobs were launched by this ticket."
---

# FIX-MOVE — right-click peasant movement direction (STATIC_TRACE_ONLY)

## 1. Boundaries / preserved work

Owned files inspected, **not modified**: `variant3d/scripts/input_controller.gd`,
`variant3d/scripts/picking3d.gd`. This report is the only file written.
No backups were needed because no owned source was changed.

Explicitly **not** touched: `app/scripts/game.gd`, `variant3d/scripts/game.gd`
(shared sim, byte-identical — SHA-256 `8649A865BE287C6FF61BEA4EF6E312C57FB20698DB95236054898D572DBF108C`
on both copies), `camera3d.gd` (CAM-SEAM, paused), `world3d*.gd`
(FIX-SELECTVIS / FIX-TERRAIN / FIX-COLOR), `main.gd`, `app/`, `config`, `tests`,
`docs` other than this report. No git operations. No Godot process launched.

## 2. Full order path, exact file:line

### 2.1 Pixel → SIM ground destination

1. `input_controller.gd:555` — `var pw := _screen_to_world(mb.position)` runs for
   every world mouse-button event (minimap branches `:537-551` return earlier).
2. `input_controller.gd:455-462` — 3D seam: records the raw pixel in
   `_pick_screen` (`:461`), returns `picking.ground_point(p)` (`:462`).
3. `picking3d.gd:235-243` — `ground_point(screen)` builds
   `cam.project_ray_origin(screen)` / `cam.project_ray_normal(screen)` and returns
   `_to_sim(_ray_heightfield(o, d))`.
4. `picking3d.gd:148-171` — `_ray_heightfield()` marches the ray 1 m at a time
   against `game.height_at()` (SIM sampler), refines by 20 bisections and returns
   the world `Vector3` hit (centred X/Z metres, Y = terrain height).
5. `picking3d.gd:121-122` — `_to_sim(w) -> Vector2(w.x, w.z) + _world_to_sim`.
6. `picking3d.gd:75-108` — `_recalc_offset()`: after FIX-SEL,
   `_world_to_sim = (MAP_W*TILE_M/2, MAP_H*TILE_M/2)` deterministically; a
   camera exposing `jump_to_world` (i.e. `camera3d.gd`) is **never**
   re-calibrated against the flat ray hit (`:87-88`). For the shipped 160×160
   tile map (TILE_M = 2) the offset is exactly `(160, 160)` m.

Net: `pw` is a `Vector2` in **SIM metres, top-left map origin, x right / y down**.

### 2.2 SIM destination → cmd_move

1. `input_controller.gd:648-649` — right-button press → `_right_order(pw)`.
2. `input_controller.gd:694-726` — filters selected player-0 units, resolves a
   possible entity/resource target (`_pick` / `_pick_res`, 3D seams at `:477-480`
   and `:805-808`), computes `form := _sel_formation(sel)` and
   `formation := game.formation_targets(sel, pw, form)` only when no entity is hit.
   For a single un-squaded peasant `formation_targets` returns `[pw]`
   (`game.gd:3313-3318`), so `dest == pw` exactly.
3. `input_controller.gd:735-740` — `var dest := formation[fi] … pw`, then
   `game.cmd_move(e, dest)` (or `cmd_attack_move` at `:738` when armed).

### 2.3 Shared sim frame check (READ-ONLY, byte-identical to 2D)

- `game.gd:2839-2851` — `cmd_move(e, pos: Vector2)` stores
  `e.order = {"type":"move","pos":pos}`, `e.move_target = pos`, `e.moving = true`;
  it does no frame conversion, projection or axis swap.
- `game.gd:3313-3359` — `formation_targets(sel, center, …)` operates directly on
  the SIM `center` with SIM offsets; no conversion.
- `game.gd:4417-4424` — `_step_move()` computes `to = aim - e.pos`,
  `d = to.length()`, `dir = to / max(d, 0.001)`.
- `game.gd:4425-4450` — each candidate step is `np = e.pos + d2*step` where
  `d2 = dir.rotated(ang)`; on success `e.pos = np` and `e.face = d2.angle()`
  (`:4441-4442`). With a clear path `ang = 0`, so the direction dot product
  `dir · (dest - e.pos).normalized()` is exactly `+1`.
- `game.gd:4781-4782` — `hold` (stand ground) only blocks idle auto-acquire; it
  cannot produce strafing.

**Frame verdict:** adapter output frame and sim input frame are identical
(SIM Vector2). Any x/z swap or sign flip would have to appear in `_to_sim` or
`_recalc_offset`; neither is present in the current source.

## 3. Camera yaw assumption (checked, no defect found)

- `camera3d.gd:46-51` declares yaw 0 (look toward -Z) as a PORT ASSUMPTION;
  donor yaw UNVERIFIED.
- `camera3d.gd:232-252` — `_apply_transform()` places the camera at
  `base + (0, h, h·cos(pitch)/-sin(pitch))` and calls `look_at(base, UP)`, so the
  camera's forward is -Z, screen-right is +X, screen-up is -Z. With the SIM
  offset, **screen-up ⇒ SIM y decreases; screen-right ⇒ SIM x increases**,
  matching the 2D canvas convention.
- More importantly, `ground_point()` casts through `cam.project_ray_origin()` /
  `project_ray_normal()` (`picking3d.gd:241-242`), which use the camera's real
  transform. Even if donor yaw were later non-zero, the ray hit follows it;
  there is no hard-coded screen-to-axis mapping in the order path. The yaw
  assumption therefore cannot cause a *lateral destination*.
- `picking3d.gd:198-207` uses `Camera3D.unproject_position()` for the reverse
  (entity → screen) direction, the same projection the renderer uses.

## 4. Root-cause assessment

1. **Stale build (most likely).** Before FIX-SEL, `_recalc_offset()` compared
   `cam.screen_to_world(centre)` with the flat Y=0 ray hit. After V7-81 both are
   centred metres, so the calibration returned `(0,0)` and overwrote the
   required `(160,160)`; ground orders landed 160 m short (diagonally up-left
   from the click). Measured before: offset `(0,0)` and no ground `cmd_move` in
   the probe (FIX-SEL jobs 260/266); after: offset `(160,160)`, exact dest
   `(155,155)` (jobs 276/279, `FIXSEL_picking_orders.md:199-214`). Rebuild with
   current sources; no new code change is needed.
2. **Visual-facing "strafe look" — separate renderer issue, handled by
   FIX-COLOR.** `world3d_entities.gd:1031-1046` maps SIM `e.face` to mesh yaw
   with `yaw = -float(ed.get("face", 0.0))` (explicit `PORT APPROXIMATION`
   comment), while `game.gd:4442` sets `face = atan2(dir.y, dir.x)` (SIM travel
   direction). If converted meshes' authored forward axis is not SIM +X, the
   unit is drawn rotated relative to its travel vector and *looks* like it is
   strafing although SIM position and destination are correct. FIX-COLOR owns
   this 3D renderer correction; it is out of scope here and **not edited**.
3. **Normal SIM steering (expected, byte-identical).** `game.gd:4425-4432`
   tries `dir.rotated(ang)` with `ang` up to ±105° when the direct step is
   blocked, so a peasant can briefly move obliquely around buildings/trees.
   Present in 2D too; not a port artifact.
4. **Formation / morale / stand-ground (ruled out for a lone peasant).**
   `formation_targets` gives a single unit exactly the click point;
   `cmd_stand_ground` (`game.gd:2920-2923`) clears the move order;
   `_update_morale` (`game.gd:4814`) explicitly excludes peasants from routing.

## 5. Exact diff

**No source diff.** Both owned scripts are unchanged by this ticket. The
functional offset fix is already present in `picking3d.gd:75-108` from FIX-SEL;
introducing another axis/sign conversion would break the verified
`(155,155)` destination and the byte-identical sim contract.

## 6. Verification — SKIPPED (user speed request)

Per the user's "speed up without much tests" request, **all remaining parse,
probe and selftest jobs were skipped**. No Godot job was launched by this
ticket, no temporary probe was created, and no result file needs deletion.
No runner job ids were consumed for FIX-MOVE.

Historical datapoint only (FIX-SEL, not re-run here): before offset `(0,0)` →
no ground `cmd_move`; after offset `(160,160)` → `dest=(155,155)`, selftest
29/29. The four-direction sign/axis and direction-dot probe designed earlier
for this ticket remains a future optional check, not a blocker for closure.

## 7. Preserved-work checklist

- [x] Only the two owned scripts were read; neither was edited.
- [x] Shared sim confirmed byte-identical (`game.gd` SHA-256 equal in `app/` and `variant3d/`).
- [x] `camera3d.gd` (CAM-SEAM, paused) not edited.
- [x] `world3d*.gd` (incl. FIX-COLOR's renderer work), `main.gd`, `app/`, config, tests, other docs not edited.
- [x] No git operations.
- [x] No Godot process launched; runner left to other agents.
- [x] No probe created; nothing to delete.
- [N/A] Parse × 2, probe, selftest — skipped by user speed request; ticket closed on static trace.

## 8. Handoffs / open questions

1. **Visual facing** — FIX-COLOR owns the 3D renderer correction for
   `world3d_entities.gd:1043` (`yaw = -face`). No donor citation exists for yaw
   policy (`DEEPDEC_06_models_anim.md:258`); handled separately from this ticket.
2. **Build freshness** — the reported symptom is expected to disappear on a
   build that includes FIX-SEL (jobs 276/279/280).
3. **Donor yaw** remains UNVERIFIED (`camera3d.gd:46-51`); the ray-cast order
   path is yaw-agnostic, but `_pixel_reach()` measures px/m along world X and
   would need an ellipse-aware footprint if a non-zero yaw is ever introduced
   (also noted in `FIXSEL_picking_orders.md:251-253`).
4. No visual A/B or windowed run was attempted; this report claims only static
   frame analysis plus the previously measured FIX-SEL datapoint.
