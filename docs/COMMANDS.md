# COMMANDS.md — every command for working on this port

> Run everything from the project root (`...\cossacks-3-3`).
> Quote paths with spaces. Never run `godot` without a self-exiting flag
> (`--screenshot`, `--self-test`, `--ui-test`, `--cli`, `--seq`, `--timeout`,
> `--dump-config`) — a bare run opens the game and never exits on its own.
> Headless runs need no GPU and work on any machine.

## 1. Play the game

```
godot --path app
```
Windowed skirmish (default Ukraine vs Russia). Menu: nation pair, map type
(Land..Continent), starting option (default..cannons), `--battle` for the
historical-battle quick mode. See `app/README.md` for controls.

## 2. Test it (all self-exiting; CI-safe)

```
:: 28-step sim self-test: move/gather/fight/build/train/mine/hud + volley,
:: heal, morale, upgrade, market, capture, squad/formation/bonus/replenish/flee
godot --headless --path app -- --self-test app/selftest.json

:: 17-scene UI user-journey test (menu, select, keys, build, train, squads,
:: rally, market, research, delete, speed) — drives the real input/HUD code
godot --headless --path app -- --ui-test app/uitest.json
:: one scene only (seconds instead of a full run):
godot --headless --path app -- --ui-test app/uit.json --ui-only squad_keys
:: scenes: menu_shell select_box order_keys build_flow train_flow squad_keys
::          rally_panel market_panel research_panel delete_key speed_pause
::          cursor_ctx groups minimap_frustum garrison_keys hotkeys_live save_load_ui

:: fast AI-vs-AI match, no window/textures/audio (both sides play)
godot --headless --path app -- --cli app/cli.json --cli-seconds 60
:: boosted start (test helper): same, but with resources to skip the opening
godot --headless --path app -- --config shots/boost.json --cli app/cli.json --cli-seconds 120

:: windowed screenshot (real viewport; falls back to a CPU map render)
godot --path app -- --screenshot app/shots/shot.png --timeout 90
:: headless screenshot (800x600 CPU map picture, never hangs, no GPU)
godot --headless --path app -- --screenshot app/shots/shot.png --timeout 90
```

## 2b. Clickable test API (windowed, real GUI — menu/HUD verification)

```
:: terminal 1: launch with the bridge (ALWAYS pass --timeout: the watchdog
:: UNCONDITIONALLY quits the process, so a run never hangs indefinitely)
godot --path app -- --test-api 8137 --timeout 280
:: terminal 2: drive the real GUI (menu -> skirmish screen -> game HUD ->
:: select-all units -> PNG screenshots of every stage)
python app/tools/test_drive.py --port 8137 --out app/shots/uidrive
```

The bridge (`app/scripts/testbridge.gd`, wired in `main.gd`) is a TCP
JSON-line API, one command per line, one JSON reply per line:
`ping`, `click {x,y,button}`, `key {key,ctrl,shift,alt}`, `buttons`
(visible buttons + canvas rects), `tree` (visible controls + rects + `vp`
viewport and `win` window sizes), `shot {path}`, `resize {w,h}`, `state`
(fps/frame/has_game/menu/game/layout), `wait {frames}`, `quit`.
Dumped rects are canvas coordinates — the same space synthetic
`InputEventMouseButton` positions live in — so they are directly clickable,
and screenshots are that canvas minified by the window stretch factor.
One fresh game launch per window size: mid-run window resize breaks
rendering (black screenshots), so never resize mid-run.
`app/tools/video_build.py` drives a full interactive build with the REAL OS
cursor (placement ghost follows a real cursor; synthetic motion does not move
it) and records an MP4: menu -> skirmish -> select peasants -> house icon ->
placement -> construction -> finished -> quit. The game window must stay
foreground and the mouse untouched during the run; focus is verified before
every real click.
`app/tools/record_session.py` is the hands-off variant: it only polls `shot`
+ `state` (read-only, never touches mouse/keyboard) while a HUMAN plays,
then assembles `session.mp4` + contact sheet when the game window closes.
This is the current fidelity workflow (video shows what stills hide).

## 3. Record gameplay video (sequences + MP4)

```
:: windowed journey: BOTH sides played by the AI at 4x, frames captured live
godot --path app -- --seq app/shots/j1 --seq-seconds 240 --seq-step 2 --speed 4 --config shots/boost.json --journey --timeout 400
:: headless timelapse instead (800x450 CPU map frames, zero GPU):
godot --headless --path app -- --seq app/shots/j1 --seq-seconds 120 --seq-step 2 --config shots/boost.json --cli app/cli.json --cli-seconds 120

:: assemble (needs ffmpeg on PATH: `winget install ffmpeg`):
python app/tools/seq_to_mp4.py --dir app/shots/j1 --fps 10
:: -> app/shots/j1/journey.mp4  (+ contact.png storyboard, always built)
:: contact sheet only (no ffmpeg needed, Pillow only):
python app/tools/seq_to_mp4.py --dir app/shots/j1 --contact-only
```

How it works: `--seq <dir>` saves `frame_%04d.png` every `--seq-step` sim
seconds until `--seq-seconds` (max 600 frames, then the process exits on its
own and writes `seq_index.json`). Windowed frames are the real viewport;
headless frames are the CPU map render. Higher `--speed` = shorter wall time
(a 240 s match at 4x takes ~1–2 min, GPU only briefly).

## 4. Config, battle, misc flags

```
godot --headless --path app -- --dump-config            :: print effective settings, exit
godot --headless --path app -- --dump-config --config shots/boost.json
godot --path app -- --config shots/boost.json --battle  :: historical battle, boosted start
godot --headless --path app -- --self-test app/selftest.json --seed 7   :: fixed map seed
godot --headless --path app -- --cli app/cli.json --cli-seconds 30 --timeout 120
godot --path app -- --screenshot app/shots/x.png --speed 8 --timeout 60  :: fast-forward shot
```

Key `app/config.json` sections: `gameplay` (map size, start resources,
victory), `economy` (rates, upkeep, famine, market), `ai` (thresholds, force,
peasants, difficulty), `display` (window, pixels-per-meter, fog, quality,
terrain_px, sprite_cell, fx_cap, fog_interval, minimap_interval),
`controls.hotkeys`, `units`/`buildings` (display names). `app/shots/boost.json` is the committed
test helper (2000/2000/1500 start resources). **Note:** a `--config` file
*replaces* the keys it contains — including `ai.*` and `gameplay.map_*` —
so boosted runs must keep those keys in sync with `config.json`.
`user://options.json` (from in-game Options) merges as a third layer.
`--bench` writes `app/shots/bench.json` (fps + sim_ms_per_tick @600 units).

## 5. Asset pipeline (Blender CPU-only, Pillow)

```
:: animated unit sheets (CPU skinning + Blender CPU Cycles, shadeless):
"C:\Program Files\Blender Foundation\Blender 5.2\blender.exe" --background --factory-startup --python app\tools\bake_sprites.py -- --game "C:\Games\Cossacks 3" --out "app\assets\models\anim" --only peasant,serdiuk --size 160 --engine cycles --samples 4
:: all 54 unit keys incl. 8 nation peasants (see table in bake_sprites.py main()):
... -- --game "C:\Games\Cossacks 3" --out "app\assets\models\anim" --size 160 --engine cycles --samples 4
:: nation buildings + stages + rubble ( Ukrcen..swidip, ba2=bar18, dip ):
... -- --game "C:\Games\Cossacks 3" --out "app\assets\models\anim" --buildings --size 320 --engine cycles --samples 4
:: then ALWAYS:
godot --headless --path app --import

:: one-off converters (Pillow only, no Blender):
python app/tools/copy_assets.py --game "C:\Games\Cossacks 3"      :: terrain/UI/sounds
python app/tools/convert_models.py --game "C:\Games\Cossacks 3" --out assets/models
python app/tools/extract_map.py --game "C:\Games\Cossacks 3" --out assets/maps
python app/tools/build_missions.py                                :: missions.json
```

## 6. Quick JSON checks (no Godot boot)

```
python -c "import json; d=json.load(open('app/mechanics.json')); print(len(d['values']))"
python -c "import json; d=json.load(open('app/selftest.json')); print(d['passed'], [s['step'] for s in d['steps'] if not s['passed']])"
python -c "from PIL import Image; im=Image.open('app/assets/models/anim/ukr_cen_s1.png'); print(im.size, im.mode)"
```

## 7. When to use what

| Goal | Command |
|---|---|
| Play | `godot --path app` |
| Prove the sim works | `--self-test` (28 steps, ~1 min headless) |
| Prove the UI works like the original | `--ui-test` / `--ui-only <scene>` (17 scenes) |
| Prove the AI plays/em* | `--cli` (+ `--config shots/boost.json` to skip the opening) |
| See it move (video) | `--seq ... --journey` windowed, then `seq_to_mp4.py` |
| Fast map timelapse, no GPU | `--seq` + headless `--cli` |
| Still picture, any machine | `--screenshot` (headless = CPU map) |
| New/changed PNGs | `--import` before any run that loads them |
| Repro a layout | `--seed N` (selftest/CLI/screenshot/seq) |

\* AI note (measured): the donor-tuned opening is *slow* — first loads land
at ~60 s, mass armies need 10+ min natural. For quick validation use the
boosted config; natural runs are for timelapses.

## 8. Troubleshooting

- `Required object "rp_texture" is null` → PNG not imported: run `--import`
  (the code null-guards and falls back).
- Parse Error on a script you edited → indentation must be TABS; a missing
  comma in a dict literal; restore from `inbox/backup/<name>.bak2` and redo.
- `ui-test` hangs → a runtime error repeats every frame until the watchdog
  fires; run with `--timeout 60` and read the first `SCRIPT ERROR` above the
  watchdog line (usually a wrong field name - see Appendix C of guides/GUIDE2.md).
- Self-test `wall` fails after mapgen edits → a resource cluster blocks the
  build site; keep guaranteed deposits ≤ 20 tiles out and tight (±2 tiles).
- CLI shows identical 8/15 units forever → check `ai.max_peasants` /
  `gameplay.map_*`: the shipped `config.json` (and any `--config` file)
  override the code defaults.
- Blender `ModuleNotFoundError: PIL` → the baker inserts `tools/blender_py`
  into sys.path itself; reinstall with the Blender-bundled pip (see GUIDE2).
- NEVER EEVEE/GPU rendering. NEVER run godot without a self-exiting flag.
- PC is weak: run ONE heavy job at a time (bake XOR long CLI XOR windowed
  capture); headless checks are cheap and can overlap.

## 9. Acceptance gates (what "done" means here)

- `selftest.json`: `passed: true`, all 28 steps true.
- `uitest.json`: `passed: true`, all 17 scenes true (or each `--ui-only` true).
- `cli.json`: exits 0, both sides grow over time, no errors.
- `seq_index.json`: `frames` > 10, `journey.mp4` plays (ffprobe shows streams).
- `g2_final.png`-style screenshot: nation buildings, animated units, HUD intact.
- `mechanics.json` documents every number with `source` (+ `"estimated": true`
  where the port chose the value).
