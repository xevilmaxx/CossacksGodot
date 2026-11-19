This build contains the original game's own files, for the private use of the person who owns the game, on their own computer. It must not be shared or published.

# Cossacks 3 — singleplayer port (Godot)

A playable rebuild of the original's singleplayer: a skirmish battle
(economy, construction, army, computer opponent) plus a historical-battle
quick mode. All gameplay numbers were read from the original game's own
data files — see MECHANICS.md and mechanics.json.

## Run

- Normal: open the project in Godot (or run the exported game). The window
  opens as usual, 1280×720.
- Skirmish is the default mode (menu: nation pair, map type Land..Continent,
  starting option default..cannons). Officers form squads (F, J/K/L;
  F on a squad officer replenishes it), walls (W), rally points (R),
  speed buttons and objectives included. Units are animated sprites baked
  from the original meshes (walk/idle/attack/death, 8 directions); barracks
  train nation variants (Russian strelets, Turkish janissaries/sipahi,
  Polish winged hussars...). Add `--battle` for the historical-battle
  quick mode (both sides start with a ready army).

## Test options (never hang; all exit on their own)

- `--screenshot <file.png>` — draws ~120 frames, saves a PNG and exits.
  Windowed: captures the real viewport without taking focus. Headless:
  saves a CPU-rendered map picture instead, so the check works on any
  machine with no window and never hangs. A blank picture is never saved:
  the map render is used as a fallback.
- `--self-test <file.json>` — starts a game like a player would, drives it
  with scripted input, measures each core step from the game's state
  (move, gather, fight, build, train, mine, hud), saves the results and
  exits. Works with `--headless` for fast command-line testing:
  `godot --headless --path . -- --self-test report.json`
- `--cli [file.json] --cli-seconds N` — fast headless match, no window, no
  textures, no audio: both sides play (AI vs AI) as fast as the machine
  allows, running a few hundred ticks per frame with a 40 ms frame budget
  so the watchdog stays alive. Example:
  `godot --headless --path . -- --cli cli.json --cli-seconds 10`
- `--timeout <seconds>` — hard wall-clock limit for any mode (default 120 s
  for test modes; normal play has no limit). The process always exits.
- `--dump-config` / `--config <file>` — see which settings the game runs
  with, or run with another settings file (see config.json).

## Cross-platform

- Renderer: Compatibility (gl_compatibility) — same picture on Windows,
  macOS and Linux, fast on weak graphics cards.
- All paths are `res://` / `user://` or absolute; no Windows-only calls.
  Window focus flags are guarded by `OS.get_name()` (the window stays
  behind only on Windows; on macOS/Linux it stays raised but unfocused so
  drawing never stops).
- `export_presets.cfg` holds one-click presets: Windows Desktop
  (`build/windows/`), Linux (`build/linux/`), macOS (`build/macos/`).
  Open the project in Godot on any OS and export.
- Re-copying assets on another computer:
  `python tools/copy_assets.py --game PATH_TO_GAME` (needs Pillow only
  for the DDS → PNG terrain step; the PNGs/OGGs are already committed).

## Controls (from the original hotkeys.cfg)

- Left mouse: select (drag = box select) · Right mouse: move / gather /
  attack / enter construction · Delete: delete own selection (deny capture)
- A: attack-move · S: stand ground · C: stop standing · Ctrl+S: stop ·
  G: guard · Q: patrol here · D: hold fire · E: feuer frei (resume fire) ·
  V: engage (cancel stand ground) · Space: pause
- Ctrl+A: all units · Ctrl+P: idle peasants · Ctrl+B: all buildings ·
  Z: units of the same type
- Select peasants → build menu (keys C/H/B/S/L/E/O/I/M/R/T/N/W per building,
  2 = Barracks 18c, 3 = Diplomatic Center) · right-click a damaged friendly
  building with only peasants selected to repair it
- Select blacksmith/academy/mill/artillery/tower/mine → upgrade buttons
  (incl. per-mine shaft ladder, per-tower cannon rows, 18th century at the
  Town Hall) · Select market → trade buttons
- Select officer → formation size buttons 15/36/72/120/196/400 (+ wedge for
  cavalry) · F forms a squad, F on its officer replenishes it
- Select wall segment → Gate button (click again to open/close)
- Mouse wheel: zoom · screen edges / arrows: scroll

## What is included from the original files

Terrain tiles, UI icon atlas, cursors, unit/building icons (from
hud/mat), all 305 sounds, 29 converted 3D meshes (`assets/models/obj/*.obj`
+ `tex/*.png` with `manifest.json`), and 4 extracted mission summaries
(`assets/maps/*.json` via `tools/extract_map.py`). Units, buildings, trees, rocks and fields render
as sprites baked from the original 3D models (.oss/.osm) and textures
(tools/render_models.py + Blender: 8 directions per unit, shaded like the
original sprites), with soft shadows, team rings, waving banners, idle/march
bob and the original icons; anything without a baked sprite falls back to a
matching procedural shape — see CREDITS.md for what is original and what is a placeholder.
Like the original, units never stack: box formations on group orders, work
slots around trees/rocks/sites, and a per-tick separation pass keep
`r1 + r2 + 0.35 m` clearance (see MECHANICS.md, config.json
economy.personal_space / formation_spacing).
Checked against the store screenshots for Cossacks 3 (town dirt plaza, roof
and forest look); no store images are shipped with the game.

## Maps and models: what could (and could not) be converted

- Maps: the original `.map` files are a closed binary (`OSWMap13…`,
  30–100 MB each). `tools/extract_map.py` pulls out what is readable —
  header, section offsets and ~18k placement names per mission — into
  `assets/maps/*.json`. The heightmap itself has no public spec, so the
  game builds its own map in the same style instead of loading it.
- Models: the original `.oss`/`.osm` meshes ARE converted here by
  `tools/convert_models.py` (29 units/buildings/props → `.obj` + `.png`).
  Full sprites are baked with Blender (`tools/render_models.py`) into
  `assets/models/sprites/*.png` (92 sprites: 8 directions x 9 units + 21
  single-view buildings/props); anything without a baked sprite falls back
  to a matching top-down shape.
- Re-run on another computer:
  `python tools/copy_assets.py --game PATH_TO_GAME`,
  `python tools/convert_models.py --game PATH_TO_GAME --out assets/models`,
  `python tools/extract_map.py --game PATH_TO_GAME --out assets/maps`.
\
## GUIDE3 controls
- Groups 1-9 (Ctrl+1 store, 1 recall, Shift+1 jump), double-click same-type, Shift-add.
- Command card: Attack-move A, Stand S, Hold fire D, Feuer frei E, Patrol Q, Guard G, Stop Ctrl+S.
- U unload garrison/town, R bombard (artillery) or rally context, Ctrl+M idle mines, Ctrl+backtick all peasants, Shift+Z add same type, Alt+M minimap, F5/F9 save/load, Esc menu.
- Quality presets high/medium/low (terrain_px, sprite_cell, fx_cap); save/load quicksave.json; context cursors.
\

## FPS readout (engine vs sim)

Top bar shows live ps ms u (render fps, frame ms EMA, live units). Rule of thumb: fps high + game sluggish = sim/design cost (ticks, AI, upkeep) - try the low quality preset in Options or fewer units; fps low = rendering cost - lower quality / window size.


## HUD readout + scalable interface

- Upper right corner shows a 3-digit FPS number (render fps only). High fps + sluggish game = sim cost: try the low quality preset in Options or field fewer units.
- All interface (menu, top bar, panels, minimap, dialogs) scales with the window between 1280x720 and 4K (factor 0.75-2.5x), in windowed and fullscreen: fonts, buttons and panels grow proportionally while the battlefield view itself is untouched.

