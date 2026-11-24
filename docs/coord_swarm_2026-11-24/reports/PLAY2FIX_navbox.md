---
id: PLAY2FIX-NAVBOX
scope: "FIX-P2-01 — add half-map SIM offset to hud3d_adapter.get_minimap_box() centred camera corners"
date: 2026-11-24
status: FIX_LANDED__PARSE_PASS__PROBE_PARTIAL__FAST_LANE_NO_SELFTEST
rules_kept: "edited only variant3d/scripts/hud3d_adapter.gd + this report; backup in inbox/backup; temp probe created and deleted; no git; owner FAST-LANE directive (parse + one probe only, no full selftest)"
visual_parity_claim: false
---

# PLAY2FIX-NAVBOX — minimap viewport-box frame fix

## 1. Root cause and donor/port evidence

`camera3d.get_viewport_corners()` returns **CENTRED** world metres
(`camera3d.gd:266-275,354-363`; PLAY2-01 E5,
`docs/coord_swarm_2026-11-24/reports/PLAY2_01_minimap_nav.md:43`); the camera
subtracts the half map once in `_apply_transform()` (`camera3d.gd:246-247`).
The minimap image and blips are indexed in **SIM tiles**
(PLAY2-01 E7, `PLAY2_01_minimap_nav.md:45`; `hud.gd:1541,1598,1656,1796`).
The adapter divided the centred corners by `TILE_M` with no offset, so negative
coordinates were clamped to 0 and the box collapsed toward the minimap's
top-left (PROVEN static root cause RC1, `PLAY2_01_minimap_nav.md:154-163`,
worked example `:122-129`; E6 at `:44`). Donor comparison for this atom is
inherited from PLAY2-01 E7/E18: no donor path:line exists for the 3D frustum box
(V717 §3, `V717_hud3d_adapter.md:74`); no donor number was invented here.

Contract preserved: inclusive `(x0,y0)`, exclusive `(x1+1,y1+1)`, `int()`
truncation, clamps and fallbacks unchanged
(`hud3d_adapter.gd:32-37,66-84`; V717 §2, `V717_hud3d_adapter.md:48-63`).

## 2. Exact diff — `variant3d/scripts/hud3d_adapter.gd`

```diff
@@ -57,6 +57,12 @@ func get_minimap_box() -> Rect2:
 		if not _finite(p):
 			continue
+		# PLAY2FIX-NAVBOX: camera3d.get_viewport_corners() returns CENTRED metres
+		# (camera3d.gd:266-275,354-363; PLAY2-01 E5), while the minimap image is
+		# SIM-tile indexed (PLAY2-01 E7: hud.gd:1541,1598,1656,1796). Convert to
+		# SIM metres before the tile mapping — the same half-map offset camera3d
+		# subtracts at :246-247. Do NOT change int()/clamps/exclusive end (V717:48-56).
+		p += Vector2(mw, mh) * Data.TILE_M * 0.5
 		# Same mapping as 2D hud.gd:1409-1412. The view_scale factors cancel:
 		#   int(canvas_px / pxm) == int(world_m / Data.TILE_M)
 		# 2D uses int() (truncate toward zero), so keep int() here too.
```
Final source `hud3d_adapter.gd:53-72`; the offset is one line at `:62`, before
`int()` at `:66-67`. Backup: `inbox/backup/hud3d_adapter.gd.bak-PLAY2FIX-NAVBOX`.

## 3. Runner jobs (variant3d runner, all serialized)

| Ticket | id | Result |
|---|---|---|
| 296 | `play2fix-navbox-probe-before` | `failed` — **INVALID baseline**: probe called `cam.bind()` before the camera entered the tree (`get_viewport()` null, corners empty, adapter returned full-map fallback). Not used as evidence. |
| 299 | `play2fix-navbox-parse` | `ok`, 5.28 s — `--headless --path variant3d --check-only --script res://scripts/hud3d_adapter.gd`. stderr empty. **PARSE PASS.** |
| 300 | `play2fix-navbox-probe-after` | `failed` (assertion exit 1), 4.06 s — valid measurements in stdout, stderr empty. All three x centres pass ±2; all three y centres are −3 tiles from the requested tile. See §4. |

Full selftest: **NOT RUN** — skipped under the owner's FAST-LANE directive
("NO full selftest"). No visual/screenshot parity claim.

## 4. Measured box centres (job 300, 160×160 stub map, 1280×1280 headless viewport)

Raw measured centred corners are in job 300 stdout; "before" is the old mapping
(no half offset) applied to **those same measured corners** inside the temp
probe, so the before/after pair is from one valid camera measurement, not from
the invalid job 296. Box centre = `(x0+x1)/2, (y0+y1)/2` from the inclusive
adapter Rect2 (V717 exclusive-end conversion at `hud3d_adapter.gd:75-76`).

| SIM focus | old-map box (before) | old-map centre | fixed adapter box (after) | fixed centre | want | delta |
|---|---|---|---|---|---|---|
| (160,160) | [0,0,6,7] | (3.0,3.5) | [73,67,86,87] | **(79.5,77.0)** | (80,80) | (−0.5,−3.0) |
| (40,40) | [0,0,0,0] | (0.0,0.0) | [13,7,26,27] | **(19.5,17.0)** | (20,20) | (−0.5,−3.0) |
| (280,280) | [53,47,66,67] | (59.5,57.0) | [133,127,146,147] | **(139.5,137.0)** | (140,140) | (−0.5,−3.0) |

`Rect2.get_center()` (adds the exclusive +1) gives (80.0,77.5),
(20.0,17.5), (140.0,137.5) — same −3 y bias. The fix moves the box from the
top-left to the correct tile column/row; x is within ±0.5 of target on all
three cases. The uniform y=−3 residual is frustum geometry, **not** a remaining
half-map error: measured centred corners at centre focus are
(−12.89,−24.33),(12.89,−24.33),(7.85,14.82),(−7.85,14.82): the AABB of a
fixed −32° tilt / FOV 17.27° perspective ground quad is centred ≈4.75 m
(2.4 tiles) north of the camera focus, plus `int()` truncation. Camera
`_target` stayed exactly at the requested SIM point in all three cases.

Evidence: `variant3d/.godot_queue/results/00000300_play2fix-navbox-probe-after/stdout.txt:3-197`
and `.../00000299_play2fix-navbox-parse/stdout.txt`.
The temp probe `variant3d/tests/_play2fix_navbox_probe.gd` and its JSON result
were deleted after the run; no test file remains.

## 5. Open questions

1. **±2 tolerance:** x passes, y misses by exactly 3 tiles on all three cases
   because of perspective AABB asymmetry, not the frame conversion. Owner
   ruling needed: widen the y tolerance to 3 for this probe, or accept the
   current axis-aligned frustum box (V717 open Q2, `V717_hud3d_adapter.md:125-128`).
   No code change made to force the centre onto `_target` — that would change
   the projection contract and is outside FIX-P2-01.
2. **Full selftest 29/29 not measured** (FAST-LANE directive); verification
   remains partial. If the owner reopens the gate, run
   `python variant3d\tools\godot_runner.py run --id play2fix-navbox-selftest --timeout 180 -- --headless --path variant3d -- --self-test variant3d/selftest.json`.
3. No donor path:line for the 3D minimap box was re-read in this atom; no
   visual/windowed parity claim (`visual_parity_claim: false`).

## 6. Files changed

- `variant3d/scripts/hud3d_adapter.gd` — one offset line + six comment lines.
- `docs/coord_swarm_2026-11-24/reports/PLAY2FIX_navbox.md` — this report.
- Backup artifact only: `inbox/backup/hud3d_adapter.gd.bak-PLAY2FIX-NAVBOX`.
- Probe created and deleted; no `hud.gd`, `camera3d.gd`, `main.gd`, `app/`,
  config, test or git edit.
