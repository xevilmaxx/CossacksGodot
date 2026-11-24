# Wave 4 — zoom speed, fluidity, default zoom-out (owner directive 2026-11-24)

Owner: "optimize zoom in zoom out speed and fluidity, start the game more zoomed out."

All claims UNDONE until verified in current source. Recon-first where ownership is
contested; no direct godot; gates unchanged.

## Ownership

| ID | Owned files | Scope |
|---|---|---|
| W4-1 | `app/scripts/camera.gd`, `app/scripts/main.gd` | Zoom math/clamp/smoothing, wheel-step response, lower (more zoomed-out) startup default, donor camera.cfg values |
| W4-2 (OPEN — W3-2 closed 2026-11-24) | `app/scripts/input_controller.gd` | Wheel/zoom input rate, zoom-to-cursor fluidity, key zoom if any — session `ses_df31853faffeuyLDrqdL0cKZJz` |

W3-2 CLOSED and released `input_controller.gd`; W4-2 started after that.
W4-1 owns main.gd (W2-6 CLOSED) and camera.gd (no active owner).

**Overlap ruling (coordinator, after owner flagged similar objectives):** both tickets
say "zoom speed/fluidity", but implementation is split by layer, not duplicated:
- W4-1 is AUTHORITATIVE for zoom state/target, smoothing/interpolation, clamps,
  and the more-zoomed-out startup default. It defines the public camera API
  (`set_zoom_target()` / `zoom_step(dir)`) and the smoothing speed.
- W4-2 owns ONLY input translation: wheel delta / key events → calls to W4-1's API,
  zoom-to-cursor anchor requests, and single-notch jank avoidance. It must NOT add
  its own smoothing/tween/default and must not edit camera.gd/main.gd.
Both agents were messaged with this boundary; reports must state the exact API used.

Reports: `reports/W4##_*.md`. Backups: `inbox/backup/<name>.bak-W4##`.
Final gate after all W3 + W4 reports land.
