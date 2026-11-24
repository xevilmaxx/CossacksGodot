---
id: PLAY2-04
owner: PLAY2-04
role: "Find why real play shows no building-placement phantom in the 3D variant although V7-76 reported draw_ghost wired"
date: 2026-11-24
status: READ_ONLY_DIAGNOSIS__NO_EDITS__NO_GODOT_LAUNCH
scope: "Read current app/ 2D flow and variant3d/ 3D flow; no source, config, test or git edits; no runner jobs."
---

# PLAY2-04 — build ghost missing in real 3D play

## 0. One-line answer

The ghost **sid is set correctly**, and `world3d.sync()` **does call** `fx.draw_ghost()`.
What breaks is the **point**: `world3d.gd:_ghost_world_pos()` feeds a **CENTRED**-frame
metre point (raw `Camera3D.screen_to_world()` after V7-81/CAM-SEAM) into consumers that
all require **SIM map-origin** metres (`game.in_bounds`, `can_place`, `resolve_mine_sid`,
and `world3d_fx.world_pos()` which subtracts `world_offset`). The point is therefore
either rejected by `in_bounds` (ghost actively hidden) or drawn ~half-map (320 m for the
shipped map) away from the cursor, off-screen. The documented input-side handoff that
would have supplied a correct SIM point (`set_build_ghost_pos()`) **has no caller**, and
the V7-76 probe supplied that value manually, masking both faults.

---

## 1. 2D reference flow (authoritative, all path:line current)

| Step | Evidence |
|---|---|
| Ghost sid declared | `app/scripts/hud.gd:89` `var build_ghost_sid := ""` |
| Build button/hotkey sets sid after cost gate | `app/scripts/hud.gd:881-890` (`build_gate` at `:884`, assignment `:888`); `app/scripts/input_controller.gd:872-878` (hotkey gate `:872-876`, assignment `:878`) |
| Mouse → ground (SIM map-origin metres) | `app/scripts/input_controller.gd:337-343`: `(get_viewport().get_canvas_transform().affine_inverse() * p) / world.view_scale` → `pw` |
| Placement confirmation uses that same SIM `pw` | `app/scripts/input_controller.gd:445-473`: `pos := pw` (`:446`), peasant gate (`:454-456`), `hud.build_gate(sid,pos)` (`:457-461`), `resolve_mine_sid` (`:465`), `can_place` echo (`:466-468`), `game.place_building(...)` (`:469`), clears sid (`:470-472`) |
| Ghost draws from HUD sid | `app/scripts/world.gd:3460-3469`: sid read (`:3464`), viewport mouse → canvas inverse → `/view_scale` (`:3467-3469`) — **same transform as input**, so ghost and click agree |
| Legality / colour | `app/scripts/world.gd:3470` `in_bounds`; `:3486` `resolve_mine_sid`; `:3493` `BUILDINGS` gate; `:3502-3503` `can_place().ok AND Data.can_pay`; `:3509` green `Color(0.2,1,0.3,0.5)` / red `Color(1,0.25,0.2,0.5)` |
| Rendering | `app/scripts/world.gd:3510` `world_to_px` (`:350`), `:3517-3530` translucent sprite drawn **on `fx_layer`** (comment at `:3520-3523` records that drawing on `bld_layer` made it silently vanish), `:3533` footprint ellipse, `:3535-3538` red X + reason hint; called at `:3630` |
| Perf cache only (not a state condition) | `app/scripts/world.gd:140-146`, `:3476-3492` (>2 px / sid change / 120 ms) |

**2D invariant:** ghost ground point and placement ground point are computed by the
*same* inverse transform, in the *same* SIM frame.

---

## 2. Current 3D flow and where it diverges

| Step | Evidence | Verdict |
|---|---|---|
| Ghost sid declared / set | `variant3d/scripts/hud.gd:102`; button `variant3d/scripts/hud.gd:915-924` (`:922`); hotkey `variant3d/scripts/input_controller.gd:1020-1031` (`:1030`) | **OK** — real play does set the sid |
| Per-frame hook reached | `variant3d/scripts/main.gd:578-581` / `:1043-1046` build 3D world; `:615` / `:1084` `world.hud = hud`; `:1609-1612` `world.sync(dt)`; `variant3d/scripts/world3d.gd:677-690` calls `_sync_build_ghost()` at `:682` | **OK** — no `render_mode` branch skips it |
| FX module exists and is bound | `variant3d/scripts/world3d.gd:601` instantiates, `:639` `fx.bind(game)`; `world3d_fx.gd:161-170` bind, `:194-217` derives `world_offset = (MAP_W,MAP_H)*0.5*TILE_M` = **(320,320)** for shipped config (`variant3d/config.json:41-42`, `TILE_M=2.0` at `world3d_fx.gd:54`) | **OK** |
| Ghost node exists | `variant3d/scripts/world3d_fx.gd:539-551` creates `BuildGhost3D` + `Footprint` BoxMesh; `:340-359` `draw_ghost()` sets position/visible/colour; `:293-303` `sync()` → `_update_ghost()` (`:919-929`) | **OK** mechanically |
| **Input ground point (correct SIM)** | `variant3d/scripts/input_controller.gd:455-468`: 3D branch returns `picking.ground_point(p)` (`:460-462`); `picking3d.gd:235-243` returns `_to_sim(...)` = centred + `_world_to_sim` (`:121-127`); offset is deterministic half-map (`picking3d.gd:75-88`) after fixing the 160 m calibration bug documented at `:59-74` | **OK** — placement uses this at `input_controller.gd:555` / `:579-605` |
| **Ghost ground point (broken CENTRED)** | `variant3d/scripts/world3d.gd:421-432`: if no override, returns raw `cam.call("screen_to_world", vp.get_mouse_position())` (`:429`) with **no +half-map**. `camera3d.gd:266-275` raycasts against scene Y=0 → **centred** metres; camera sits in centred frame since V7-81 (`camera3d.gd:234-252`), confirmed by V7-81 report line 137 ("`screen_to_world()` still returns CENTRED world metres") | **ROOT CAUSE** |
| `set_build_ghost_pos()` handoff | `variant3d/scripts/world3d.gd:784-786` is the only definition; repo-wide grep finds **no call site**. The caller snippet is left as a comment at `:771-783` ("documented, NOT implemented here — input_controller.gd is owned by V7-75") | **ROOT CAUSE** (live path always takes the broken fallback) |
| Gates consume the wrong point | `world3d.gd:475-478` `game.in_bounds(wp)` (expects `[0,MAP_W*TILE)` — `game.gd:456-457`); `:480-481` `resolve_mine_sid(sid,wp)` (`game.gd:2685-2696` compares against SIM `n.pos`); `:487-490` `can_place(0,sid,wp)` (`game.gd:3592-3597`); `:491-492` affordability | **FAIL** — centred `wp` near the visible centre is negative in x/z, so `in_bounds` rejects and `:468`/`:477` actively call `draw_ghost("")` → `_ghost_active=false` → `visible=false` |
| FX placement consumes the wrong point | `world3d_fx.gd:350` `world_pos(pos)` → `:462-471` `Vector3(v2.x - world_offset.x, h, v2.y - world_offset.y)`. With centred `wp` this puts the footprint at scene `centred-(320,320)`, i.e. ~320 m from the camera's focused region | **FAIL** even when the gates happen to pass (e.g. centred x,z ≥ 0), the box is far off-screen |
| Node visibility / scale / material | `world3d_fx.gd:100-101` alpha 0.45; `:545-551` 0.05 m-thick box scaled `(r*2,1,r*2)`; `:922` `visible = _ghost_active` | Secondary visibility risk only; the decisive failure is `_ghost_active=false` or wrong XZ. No GPU capture exists to judge legibility (V776 report:12) |

### Direct answer to the four diagnostics in the task

1. **Is the ghost sid ever set?** Yes — `hud.gd:922` and `input_controller.gd:1030` run in
   both render modes; `main.gd:615` keeps `world.hud` live; `world3d.gd:462-465` reads it.
   The chain breaks *after* the sid, at the ground point.
2. **Is `_ghost_world_pos()` using a stale/out-of-viewport mouse?** Not intrinsically:
   `world3d.gd:425-429` re-reads `vp.get_mouse_position()` every `sync()` and the ray is
   built from the same viewport (`camera3d.gd:267`). No viewport-size/staleness evidence was
   found. A *frame* mismatch exists, not a staleness bug. (In headless/screenshot runs the
   mouse can legitimately be `(0,0)`; that is why probes used the override.)
3. **Does `screen_to_world(mouse)` return centred or SIM metres, and is there a 160 m
   offset?** It returns **CENTRED** (scene X/Z) metres — `camera3d.gd:266-275`, camera in
   centred frame after `camera3d.gd:234-252` (V7-81); `camera3d.gd:435-438` explicitly
   converts back with `centre + _map_half()` for clamping. `draw_ghost` expects **SIM**
   (`world3d_fx.gd:471` subtracts `world_offset`). The gap is exactly `world_offset`,
   `(320,320)` m on the shipped map; the same family of half-map offset that broke picking
   and is documented at `picking3d.gd:59-74` ("Ground clicks then landed 160 m short of the
   sim point"). For a 160-tile map it is 160 m; for the shipped 320-tile config it is 320 m.
4. **Did the V7-76 probe mask it?** Yes. V776 report lines 72-77 state the stub HUD had
   `build_ghost_sid = "hou"` and the ghost point was **manually fed** through
   `set_build_ghost_pos(Vector2(12,14))`, with an 8×8 stub game (`world_offset=(8,8)`,
   report line 88). That bypassed both the camera-frame fallback and the absent input
   caller. It measured node-tree state only (report lines 11-12: no GPU/visual parity),
   so `visible=false→true` proved the API chain, not on-screen placement. The shipped
   `variant3d/selftest.json` contains **no** `ghost` assertion, and `tests/t_fx3d.gd:218-222`
   only checks that `draw_ghost()` is callable.

---

## 3. Ranked root causes

| Rank | Cause | Evidence | Effect in real play |
|---|---|---|---|
| **P0-1** | Frame regression: `_ghost_world_pos()` returns CENTRED metres from post-V7-81 `screen_to_world()`, but every downstream consumer expects SIM map-origin metres. V7-76 was written against the old camera that effectively returned SIM (`camera3d.gd` cited as `:167-176` in `world3d.gd:176,419,772`; it is now `:266-275`). | `world3d.gd:421-432`; `camera3d.gd:266-275`, `:234-252`, `:435-438`; `game.gd:456-457,3592-3597`; `world3d_fx.gd:462-471`; V781 report `:137`; `picking3d.gd:59-74` | Ghost cleared by `in_bounds` (mostly) or drawn half-a-map away; no preview at cursor |
| **P0-2** | The correct-SIM input handoff was never wired: `set_build_ghost_pos()` has zero callers; documented only at `world3d.gd:771-783`. | `world3d.gd:784-786`; repo-wide grep; `input_controller.gd:455-468,555,579-605` (input has the right SIM `pw` but never forwards it) | P0-1 cannot be bypassed in real play; ghost and placement also disagree even if both render |
| **P1-1** | Verification gap: V7-76 probe used the manual override and a tiny stub; no selftest/ghost assertion, no pixel check. | V776 report `:12,:72-77,:88`; `variant3d/selftest.json` (no `ghost`); `tests/t_fx3d.gd:218-222` | Regression shipped green |
| **P1-2** | Stale contract comments mislead future owners: `world3d.gd:175-179`, `:416-419`, `:771-783` still call the camera point "sim-metre (map-origin)" and cite `camera3d.gd:167-176`; `world3d.gd:269-272` still says `get_viewport_corners()` returns map-origin sim with "no half-map shift" although V7-81 made it centred. | `world3d.gd:175-179,269-272,416-419,771-783`; `camera3d.gd:435-438` | Same-frame bugs stay invisible; (`_update_view_rect()` at `:245-291` is a sibling stale-consumer, PLAY2-01/roadmap scope) |
| **P2-1** | Flat Y=0 ray vs height-field: `_ghost_world_pos()` uses `screen_to_world()`; the correct input path uses `picking3d.ground_point()` which ray-marches terrain (`picking3d.gd:145-171,235-243`). Also flagged in V776 report open Q2 `:130-134`. | `camera3d.gd:266-275`; `picking3d.gd:145-171` | Even after the P0 fix, ghost may sit slightly off on slopes; adopt the input handoff for exact parity |
| **P2-2** | Ghost is a thin (0.05 m) translucent (alpha 0.45) box with no sprite/outline; legibility under the real camera UNVERIFIED (no GPU capture). | `world3d_fx.gd:100-101,545-551`; V776 report `:11-12`; AUDIT3D-06 `:126-129` | Possible secondary "hard to see" complaint after the P0 fix; do not treat as the primary cause |

---

## 4. Smallest fix plan (exact ownership; NOT implemented)

### Fix task F1 — P0-1, single-file, **owner: `world3d.gd` (V7-76 owner)**

In `variant3d/scripts/world3d.gd:_ghost_world_pos()` (`:421-432`), convert the camera's
centred hit to SIM **before returning it**. Minimal, null-safe, reuses the already-used
half-map expression at `world3d.gd:249-251`:

```gdscript
	var wp = cam.call("screen_to_world", vp.get_mouse_position())
	if wp is Vector2 and is_finite((wp as Vector2).x) and is_finite((wp as Vector2).y):
		var hw := float(_int_prop(game, "MAP_W", 0)) * float(Data.TILE_M) * 0.5
		var hh := float(_int_prop(game, "MAP_H", 0)) * float(Data.TILE_M) * 0.5
		return (wp as Vector2) + Vector2(hw, hh)   # centred -> SIM map-origin
```

- This makes **all four** downstream consumers correct at once (`in_bounds`,
  `resolve_mine_sid`, `can_place`, `fx.world_pos`), because `fx.world_pos()` subtracts
  the same half-map `world_offset` (`world3d_fx.gd:194-217,462-471`).
- Keep the override branch (`:422-423`) unchanged.
- Update only the stale comments at `:175-179`, `:416-419`, `:771-783` to say the fallback
  point is CENTRED from `camera3d.gd:266-275` and is converted to SIM here; fix the stale
  `camera3d.gd:167-176` citation. Do **not** change `camera3d.gd`, `picking3d.gd`, `hud.gd`,
  `input_controller.gd`, `world3d_fx.gd`, `game.gd`, config or tests.
- Alternative for the same owner: route the fallback through `picking3d.ground_point()`
  (height-field accurate) instead of the flat ray; larger change, fold with F2 if desired.

### Fix task F2 — P0-2, **owner: `variant3d/scripts/input_controller.gd` (V7-75 owner)**

Wire the already-documented handoff so the ghost uses the *exact same* SIM point as
placement (`input_controller.gd:555,580`) instead of a second projection:

- In `C3Input._process()` (`:1160-1190`), after the existing
  `_screen_to_world(get_viewport().get_mouse_position())` used for the drag overlay
  (`:1168`), or in a cheap always-run line near it, add:
  ```gdscript
  if world != null and world.has_method("set_build_ghost_pos"):
      world.set_build_ghost_pos(pw)   # pw is SIM metres from picking3d.ground_point()
  ```
- Do this **only while `hud.build_ghost_sid != ""`** (or unconditionally — the world's
  `_sync_build_ghost()` already clears on empty sid at `world3d.gd:466-469`); no `cmd_*`,
  hotkey, cursor or placement semantics change. Keep the 2D path byte-identical (guard with
  `if render_mode == "3d"`).
- F1 and F2 are complementary: F1 fixes the fallback for every caller (headless, tests,
  any future owner); F2 removes the dual-projection divergence and the slope residual.
  If only one ticket is allowed, **F1 alone is the smallest complete fix** for the reported
  symptom.

### Fix task F3 — verification, **owner: whoever lands F1/F2; new test file only**

Add a regression probe (temporary or promoted into `variant3d/tests/`) that asserts the
frame and the visible ghost; `variant3d/selftest.json` currently has no ghost step.

---

## 5. Acceptance probe (exact, must fail before F1/F2 and pass after)

No Godot launch was performed by PLAY2-04 (charter hard rule). Procedure for the fixing owner:

1. **Set up real modules.** SceneTree stub bound like V7-76 but with a **real**
   `camera3d.gd` + `picking3d` + `world3d.gd` + `world3d_fx.gd`: `MAP_W=MAP_H=320`,
   `TILE_M=2.0`, `half=(320,320)`, viewport 1280×720, `world.hud = hud`, `fx.bind(game)`
   (assert `fx.world_offset == Vector2(320,320)` and `stats.world_offset_source ==
   "game.MAP_W/MAP_H"`). Bind `picking3d` to the same camera (as `input_controller.bind_3d`
   does at `:114-126`).
2. **Project a known SIM site to screen.** Choose a legal, flat, unblocked SIM point
   `sim` (e.g. near the town hall, well inside `[0,640)`). Compute
   `screen = cam.unproject_position(Vector3(sim.x-320.0, 0.0, sim.y-320.0))` (the renderer's
   centred frame). Assert:
   - `cam.screen_to_world(screen).distance_to(sim - Vector2(320,320)) < 0.5` (documents
     the CENTRED contract; this is the regression detector);
   - `picking.ground_point(screen).distance_to(sim) < 0.5` (SIM inverse; placement path).
3. **Frame the mouse there and start build mode without any override.**
   Set `hud.build_ghost_sid = "hou"` (the real HUD/hotkey path is `:922`/`:1030`), then
   call `world.sync(0.016)` **without** calling `set_build_ghost_pos()`. Assert
   `world._ghost_pos_override == false` — this is what the old V7-76 probe bypassed.
4. **Assert visible, correct place, correct colour (ok):**
   - `fx._ghost_active == true` and `fx._ghost_root.visible == true`;
   - `fx._ghost_sid == "hou"`, `fx._ghost_ok == true`;
   - `fx._ghost_root.position` (XZ) ≈ `Vector3(sim.x-320, height, sim.y-320)` within ≤2 m
     (perspective Y=0 skew tolerance; V781 report `:158,:168` measured ~4.76 m y skew at
     map centre, so use XZ only);
   - `cam.unproject_position(fx._ghost_root.position)` lands within the same few pixels
     as `screen` — i.e. ghost is under the mouse;
   - `fx._ghost_mat.albedo_color.g > fx._ghost_mat.albedo_color.r` (green).
5. **Assert deny colour:** repeat with a blocked/wet site or an unaffordable treasury;
   expect `fx._ghost_ok == false` and `albedo_color.r > albedo_color.g`.
6. **Assert agreement with placement:** from the same `screen`, check
   `input_ctl._screen_to_world(screen) ≈ sim` and that the ghost's recovered SIM point
   (`fx._ghost_root.position.x + 320, ...z + 320`) ≈ `sim`. Before F1 this fails because
   the ghost is cleared or sits at `centred-(320,320)`.
7. Run `python variant3d/tools/godot_runner.py run --id play2-04-ghost ...` (headless
   parse + probe) and the full variant selftest; assert `passed:true, 29/29`.

---

## 6. UNVERIFIED / open

- **No visual parity claim.** This diagnosis is static source + prior-result reading only;
  no Godot launch, no screenshot, no pixels. The 320 m displacement is computed from the
  frame contract and `world_offset`, not observed on a GPU capture.
- Whether the translucent 0.05 m box is legible on real terrain after F1/F2 (P2-2) —
  UNVERIFIED.
- `get_mouse_position()` staleness in a real windowed session — no evidence found; not
  the cause of the reported symptom.
- Sibling stale consumer `world3d.gd:_update_view_rect()` (`:245-291`, stale comment
  `:269-272`) now treats centred corners as SIM; whether any current `view_rect` consumer
  is measurably affected was not traced here. Out of PLAY2-04 scope; hand to PLAY2-01/roadmap.
- `hud3d_adapter.gd:79-88` forwards raw centred `screen_to_world()` to HUD consumers;
  whether every minimap caller re-adds the half-map is PLAY2-01's scope.
- Whether V7-76's rally markers suffer the same centred-vs-SIM mismatch
  (`world3d.gd:_sync_rally()` at `:500-525` uses `e.rally`, which is SIM, so they should be
  fine) — not measured here.

*End of PLAY2-04 report.*
