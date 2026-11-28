# Enemy-camera video, Muse Spark 1.3 visual QA, and click diagnostic

Date: 2026-11-27. Runner tickets 226-229 + MCP QA host. Port-internal QA only;
no donor execution, no donor frame, no parity claim.

## 1. Enemy-camera video

Owner authorised positioning the camera on the enemy for tests. The verified
`cossacksgodotmcp` host was launched on the QA 64×64 donor-backend config
(seed 20261113). MCP `camera.pan_to` targeted the enemy start
`start[1]=(15.0,117.0)` sim metres (from the click diagnostic below); the
camera clamped/settled at `(39.04,102.77)` — the closest legal target at that
zoom. `game.tick` advanced 0.75 s, then `game.screenshot` and
`video.record_frames` (12 frames, 0.03125 s step) captured the view.

Evidence: `%TEMP%\opencode\v42\enemy_video\enemy_still.png`,
`...\enemy_video\contact.png` (12-frame sheet),
`...\enemy_video\enemy_video_manifest.json`, and
`%TEMP%\opencode\v42\mcp_gamecraft\vid_0002..0013.png`.
These are QA frames, NOT parity artifacts.

## 2. Muse Spark 1.3 analysis (model `opencode-go/muse-spark-1.3-contributor`)

Asked to rank visible defects, distinguishing observation from inference:

1. **Severe — terrain mottling**: grass is desaturated olive with pervasive
   grey-purple blotches at repeating scale across the frame. Inference:
   splat/noise layer weight or texture colour-space issue.
2. **Severe — trees as bare sticks**: ~50% of centre/top-right stems are thin
   black trunks with no canopy; survivors are small yellow-green blobs.
   Inference: trunk-only LOD or failed foliage alpha-scissor / missing leaf
   texture. Related code: `world3d_entities.gd:1157-1175` uses
   `TRANSPARENCY_ALPHA_SCISSOR 0.5` on donor-derived res albedo PNGs; donor
   `alphaMode` is UNVERIFIED (V7-2 Table B1), so this is a labelled PORT
   APPROXIMATION, not a recovered donor rule.
3. **Major — resource nodes as neon discs**: two hard-edged lime discs with
   dark rubble centres. Inference: decal material unshaded / radius too large.
4. **Moderate — blue ring on church dome**: bright blue polygonal ring around
   the cupola in every frame. Inference: procedural selection/owner ring
   (`world3d_fx.gd:2273-2327`, PORT APPROXIMATION) anchored or coloured on the
   wrong sub-mesh. Needs a fixed-camera close-up to separate ground-ring
   perspective from a real Y-offset defect.
5. **Minor — QA framing**: buildings clipped at left, right 60% empty. Shot
   artifact of MCP pan clamping, not a renderer bug.

No temporal flicker; missing water is the known U4* hard-fail and was not
re-flagged. All five are recorded as OPEN visual observations; none is
promoted to a donor claim or a gate PASS.

## 3. Click / selection diagnostic (owner's "starts from bottom-right" report)

New read-only probe `variant3d/tests/t_click_diag.gd` (no game-code edits):
boots the real 64×64 game, prints `map_starts`, then for every entity projects
its SIM position with `cam.unproject_position()` and asks
`picking3d.ground_point()` / `pick()` what that pixel resolves to (ticket 229).

- `root_vp=(64,64)`, `cam_vp=(64,64)` in headless; `unproject_position()`
  nevertheless emits 1280×720-space pixels (documented headless quirk,
  `t_select_rect.gd:267-274`).
- For every entity: `ground_point(px)` returned the entity's own SIM position
  with **0.00 m error** — the pixel→ground mapping has no offset or flip.
- `pick(px)` returned the correct id for isolated entities; in tight clusters
  it returned a neighbour id (units overlap at ≤2 m spacing), which is a
  priority/depth tie-break question, not a coordinate origin error.
- Enemy entities project far off-screen because the camera starts at player 0;
  hence the MCP pan/clamp for the video.

Conclusion so far: no bottom-right offset is reproducible in the pixel→ground
or pixel→pick path. The remaining candidates are (a) the marquee overlay's
canvas-transform mapping (`input_controller.gd:246-263`) under a non-identity
window/canvas transform, or (b) the procedural owner ring's anchor
(`world3d_fx.gd:2283-2317`). No fix invented until the exact interaction is
reproduced with the owner's window size/config.
