---
id: FIX-MOVE
title: "FIX-MOVE — right-click ground order direction: full order-path trace, no remaining axis/sign defect in the 3D pick adapter"
owner: FIX-MOVE
scope: "READ-ONLY trace of variant3d/scripts/input_controller.gd + variant3d/scripts/picking3d.gd (the two owned scripts) and shared sim/camera files. NO source edits were required: the owned order path already passes the same SIM Vector2 frame the byte-identical sim expects, and the 160 m offset regression was fixed by FIX-SEL. One report only. No git, no app/, config, tests, world3d*.gd, main.gd or camera3d.gd edits."
date: 2026-11-24
status: VERIFICATION_PENDING__QUEUE_BUSY__NO_OWNED_EDIT
verdict: "Static trace: the right-click ground order reaches game.cmd_move(e, dest) with dest in SIM metres, top-left map origin, Vector2(x = world.x + MAP_W*TILE/2, y = world.z + MAP_H*TILE/2). No x/z swap, no sign flip, no pixel/metre residue. Shared sim computes dir = (aim - e.pos).normalized(), e.pos += dir*step and e.face = atan2(dir.y, dir.x), all in that same SIM frame; a direction dot product of +1 is therefore expected. The only measured destination defect in this path (offset (0,0) instead of (160,160), FIX-SEL jobs 260/266) is already fixed (jobs 276/279: exact dest (155,155)). The user's symptom is most consistent with (a) testing a pre-FIX-SEL build, or (b) a PORT-ONLY visual-facing artifact in the 3D renderer (`world3d_entities.gd:1031-1046`, yaw = -face; owned by another agent, NOT edited), or (c) normal sim steering around obstacles. Functional probe + parse + selftest are designed but PENDING: the Godot runner was busy at check time (now_serving=287, 1 pending, lock held) and the assignment requires waiting for the coordinator's all-clear before launching jobs."
---

# FIX-MOVE — right-click peasant movement direction

## 1. Boundaries / preserved work

Owned files inspected, **not modified**: `variant3d/scripts/input_controller.gd`,
`variant3d/scripts/picking3d.gd`. This report is the only file written.
No backups were needed because no owned source was changed.

Explicitly **not** touched: `app/scripts/game.gd`, `variant3d/scripts/game.gd`
(shared sim, byte-identical — SHA-256 `8649A865BE287C6FF61BEA4EF6E312C57FB20698DB95236054898D572DBF108C`
on both copies), `camera3d.gd` (CAM-SEAM, paused), `world3d*.gd`
(FIX-SELECTVIS / FIX-TERRAIN), `main.gd`, `app/`, `config`, `tests`, `docs` other
than this report. No git operations. No Godot job launched (queue busy — see §8).

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
   re-calibrated against the flat ray hit (`:87-88`). So for the shipped
   160×160 tile map (TILE_M = 2) the offset is exactly `(160, 160)` m.

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
  it does **no** frame conversion, projection or axis swap.
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
  camera's forward is -Z, screen-right is +X, screen-up is -Z. With the sim
  offset, **screen-up ⇒ SIM y decreases; screen-right ⇒ SIM x increases**,
  which matches the 2D canvas convention.
- More importantly, `ground_point()` casts through `cam.project_ray_origin()`
  / `project_ray_normal()` (`picking3d.gd:241-242`), which use the camera's real
  transform. Even if the donor yaw were later changed to non-zero, the ray hit
  would follow it; there is no hard-coded screen-to-axis mapping in the order
  path. The yaw assumption therefore cannot cause a *lateral* destination.
- `picking3d.gd:198-207` uses `Camera3D.unproject_position()` for the reverse
  (entity → screen) direction, the same projection the renderer uses.

## 4. Root-cause assessment

Ranked from the evidence:

1. **Stale build (most likely for "direction" complaints).** Before FIX-SEL,
   `_recalc_offset()` compared `cam.screen_to_world(centre)` with the flat Y=0
   ray hit. After V7-81 both are centred metres, so the calibration returned
   `(0,0)` and overwrote the required `(160,160)`; ground orders landed 160 m
   short (diagonally up-left from the click). Measured before: offset `(0,0)`,
   right-click `cmd_move` never fired in the probe (FIX-SEL jobs 260/266);
   after: offset `(160,160)`, exact dest `(155,155)` (jobs 276/279, report
   `FIXSEL_picking_orders.md:199-214`). If the user is running a build from
   before that fix, no new code change is needed — rebuild with current sources.
2. **PORT-ONLY visual facing (renderer, out of scope).**
   `world3d_entities.gd:1031-1046` maps SIM `e.face` to a mesh yaw with
   `yaw = -float(ed.get("face", 0.0))` and an explicit `PORT APPROXIMATION`
   comment. `game.gd:4442` sets `face = atan2(dir.y, dir.x)` (SIM travel
   direction). If the converted meshes' authored forward axis is not SIM +X,
   the unit will be drawn rotated relative to its travel vector and will look
   like it is strafing while the SIM position and destination are correct.
   This is a renderer/handoff issue owned by the world3d agents; **not edited
   here**. Model forward axis is not established by any source comment
   (`DEEPDEC_06_models_anim.md:258` lists yaw policy as open).
3. **Normal SIM steering (expected, byte-identical).** `game.gd:4425-4432`
   tries `dir.rotated(ang)` with `ang` up to ±105° when the direct step is
   blocked, so a peasant can briefly move obliquely around buildings/trees.
   This is present in 2D too and is not a port artifact.
4. **Formation / morale / stand-ground (ruled out for a lone peasant).**
   `formation_targets` gives a single unit exactly the click point;
   `cmd_stand_ground` (`game.gd:2920-2923`) clears the move order;
   `_update_morale` (`game.gd:4814`) explicitly excludes peasants from routing.

## 5. Exact diff

**No source diff.** Both owned scripts are unchanged by this ticket. The
functional offset fix is already present in `picking3d.gd:75-108` from FIX-SEL;
introducing another axis/sign conversion would break the verified
`(155,155)` destination and the byte-identical sim contract. This section is
intentionally "no change" rather than a speculative edit.

## 6. Verification — PENDING (queue busy)

Runner status at design time:
`now_serving = 287`, `pending = 1 [287]`, `godot.lock = HELD (age ~145 s)`.
Per assignment, no Godot job was launched; wait for the coordinator's
all-clear. All jobs below are prepared with unique `fixmove-` ids and will be
submitted serially through
`python variant3d\tools\godot_runner.py run --id <id> --timeout <t> --max-wait 900 -- --headless --path variant3d …`.

| Planned job id | Command tail | Purpose | Status |
|---|---|---|---|
| `fixmove-parse-pick` | `--check-only --script res://scripts/picking3d.gd` | parse owned adapter | PENDING |
| `fixmove-parse-input` | `--check-only --script res://scripts/input_controller.gd` | parse owned controller | PENDING |
| `fixmove-probe` | `--script res://tests/_fixmove_probe.gd` | 4-direction sign/axis + direction dot | PENDING |
| `fixmove-selftest` | `-- --self-test variant3d/selftest.json` | full 29/29 regression | PENDING |

### Probe design (to be created, run, then deleted)

`variant3d/tests/_fixmove_probe.gd` — `extends SceneTree`, defer all work to the
first frame (`call_deferred("_run")`), never `quit()` in `_initialize()` (the
known hang pattern, FIX-SEL job 260).

- `StubGame extends C3Game`: `MAP_W = MAP_H = 160`, `height_at() = 0`,
  `res_nodes = []`, `by_id`/`entities` contain one unit
  `id=10, sid="peasant", kind="unit", player=0, pos=(160,160), def.radius=0.5`,
  `pick_radius(e) -> 2.0`, and an override `cmd_move(e, pos)` that records
  `{id, pos}` into `move_calls` (and inherits nothing else from the sim).
- Real `camera3d.gd` Camera3D in the tree, `bind(game, 1.0)` (centre at SIM
  `(160,160)` → world origin); real `picking3d.gd` adapter `bind(game, cam)`;
  real `input_controller.gd` wired via `bind(game, world_stub, hud_stub, cam)`
  then `bind_3d(cam)` and `_set_selection([unit])`.
- Compute the unit's screen pixel with the same API the renderer uses:
  `cam.unproject_position(picking._to_world(unit.pos, 0.8))` (or the private
  helper via `picking.call("_screen_of", unit.pos, 0.8)`).
- Four clicks = that pixel offset by `±80` px in x and y (radius small enough
  to stay on ground, large enough to clear the 2 m pick fallback); feed each
  synthetic `InputEventMouseButton` (right, pressed) through
  `input._unhandled_input(ev)`; read `move_calls[-1].pos`.
- Assertions (per direction):
  * UP: `dest.x ≈ unit.x` (`|dx| < 0.5 m`) and `dest.y < unit.y - 0.5`;
  * DOWN: `dest.x ≈ unit.x` and `dest.y > unit.y + 0.5`;
  * LEFT: `dest.y ≈ unit.y` and `dest.x < unit.x - 0.5`;
  * RIGHT: `dest.y ≈ unit.y` and `dest.x > unit.x + 0.5`;
  * `dot = (dest - unit.pos).normalized() · ((aim - unit.pos).normalized())`
    where `aim = dest` (clear path) — expect `dot > 0.99` for all four;
  * `offset = picking._world_to_sim == (160,160)` and
    `ground_point(centre) == (160,160)` on flat terrain;
  * no `cmd_gather` / `cmd_attack` / `cmd_attack_move` calls (ground order only).
- Output: print `dest` and `dot` for all four clicks to stdout, write
  `variant3d/tests/results/fixmove_probe.json`, then delete both probe and
  result file after the final run (verify with `Test-Path` and
  `assert_clean.py --json` → CLEAN, 0 Godot processes, lock free).

Measured before/after destinations and dot products: **PENDING** (no job run).
Known historical datapoint from FIX-SEL (different probe): before offset
`(0,0)` → no ground `cmd_move`; after offset `(160,160)` → `dest=(155,155)`.

## 7. Preserved-work checklist

- [x] Only the two owned scripts were read; neither was edited.
- [x] Shared sim confirmed byte-identical (`game.gd` SHA-256 equal in `app/` and `variant3d/`).
- [x] `camera3d.gd` (CAM-SEAM, paused) not edited.
- [x] `world3d*.gd`, `main.gd`, `app/`, config, tests, other docs not edited.
- [x] No git operations.
- [x] No Godot process launched; runner left to other agents.
- [x] Probe not yet created (will be created and deleted within this ticket after all-clear).
- [ ] Parse × 2, probe, selftest 29/29 — **PENDING**.

## 8. Open questions / handoffs

1. **Visual facing** — please have the world3d entities owner verify the mesh
   forward axis against `world3d_entities.gd:1043` (`yaw = -face`). If the
   converted meshes face -Z, the correct yaw for a SIM travel direction
   `(dx, dz)` is `atan2(-dx, -dz)` (= face + π), not `-face`; that would make
   units *look* like they strafe while the order path is correct. No donor
   citation exists for yaw policy (`DEEPDEC_06_models_anim.md:258`).
2. **Build freshness** — confirm the user's build includes FIX-SEL
   (jobs 276/279/280). Otherwise the reported symptom is the old 160 m offset.
3. **Donor yaw** remains UNVERIFIED (`camera3d.gd:46-51`); the ray-cast order
   path is yaw-agnostic, but `_pixel_reach()` measures px/m along world X and
   would need an ellipse-aware footprint if a non-zero yaw is ever introduced
   (also noted in `FIXSEL_picking_orders.md:251-253`).
4. No visual A/B or windowed run was attempted; this report claims only the
   static frame analysis plus the pending functional probe.
