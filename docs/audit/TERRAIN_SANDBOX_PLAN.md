# TERRAIN_SANDBOX_PLAN.md — deterministic mini-map terrain sample harness (TS-2 design)

Status: **DESIGN ONLY (read-only lane)**. No Godot run, no edits to existing code were made.
Labels: `observed` = read directly from file/line; `derived` = logical consequence of observed code;
`inferred` = judgement; anything not confirmed by an actual run is marked **UNVERIFIED**.

---

## 1. Sources read (file:line)

| File | Lines | What it established |
|---|---|---|
| `app/scripts/main.gd` | 1–28 | CLI contract: `--screenshot`, `--cli`, `--seq`, `--dump-map`, `--config`, `--seed`, `--timeout`, watchdog promise |
| `app/scripts/main.gd` | 122–187 | `_ready()`: config load/apply (129–131), seed override (132–135), hard deadline (154–160), cli/dump early returns (162–168), capture dispatch (171–185) |
| `app/scripts/main.gd` | 222–251 | `_apply_menu_cfg()` — the ONLY place `map_size` is read (245–247), menu-only |
| `app/scripts/main.gd` | 506–536 | `_dump_map()` — sim-only JSON with `seed`, `map_w/h`, base64 terrain/height/tileblock, `meta` |
| `app/scripts/main.gd` | 538–598 | `_setup_full_game()` — `game.setup()` then `world.bind()`, `camera`, `hud`, `input_ctl`, `audio` |
| `app/scripts/main.gd` | 600–617 | `_setup_screenshot_window()` — no-focus, no-vsync window for windowed capture; early return if headless (601–602) |
| `app/scripts/main.gd` | 621–711 | `_parse_args()` — `--screenshot` (626–629), `--screenshot-frames` (630–633), `--config` (678–681), `--seed` (696–703), `--dump-map` (704–707) |
| `app/scripts/main.gd` | 719–721, 921–925 | `_quit()` and per-frame wall-clock watchdog |
| `app/scripts/main.gd` | 1042–1044, 1161–1201 | screenshot trigger after `screenshot_frames`; `_save_screenshot()` |
| `app/scripts/main.gd` | 1203–1213, 1215–1286 | `_is_blank()` and `_render_headless_image()` — **800×600 CPU map render, no GPU/textures** |
| `app/scripts/main.gd` | 1114–1141, 1301–1311 | `_candidate_paths()`/`_pick_target()`/`_write_bytes()` — relative paths land under workspace root (`app/...`) |
| `app/scripts/main.gd` | 1358–1379, 1404–1421 | sequence capture; headless/CLI sequences also use the CPU map render |
| `app/scripts/world.gd` | 12–28, 122–204 | renderer constants (`CHUNK_T=32`), `bind()` → `_prep_variants()`, `_build_masks()`, layers, fog arrays |
| `app/scripts/world.gd` | 211–241 | `_load_sprites()` — `tree_fir/oak/pine`, `rock`, `stone`, `field` |
| `app/scripts/world.gd` | 672–717 | `_prep_variants()` water waves; `_block_img()` loads `assets/terrain/blocks/<name>.png` |
| `app/scripts/world.gd` | 798–918, 920–945 | `_build_chunk()` continuous terrain + role masks + relief shading; `_sync_terrain_chunks()` builds ≤2 chunks/frame |
| `app/scripts/world.gd` | 111–120, 1064–1071, 1117–1214 | `_env_sprite_h()` 0.85–1.15 jitter; `_prop_tex()`; resource drawing (trees/stone/bush/ore/field) |
| `app/scripts/game.gd` | 20–42, 232–272 | map defaults (160), grid arrays, `setup()` → 6 gen stages, `setup_begin()` copies `Data.MAP_W/H` (234–235) |
| `app/scripts/game.gd` | 396–453, 425 | `_scatter_forest()`, `_scatter_bushes()` (**defined but never called**) |
| `app/scripts/game.gd` | 485–586, 588–595 | `_gen_patterns()` and `_generate_map()` |
| `app/scripts/game.gd` | 597–751 | `_gen_base()` — donor mask sampling, relief domes (644–658), water/shore (669–705), steep→rock (706–730) |
| `app/scripts/game.gd` | 753–874 | forests, seed wheat, richness ores, `_gen_finish()` |
| `app/scripts/game.gd` | 972–1080, 1115–1161, 1241–1262 | detail bitmaps, tileblock assignment, cliff/shore orientation, forest-border stamps |
| `app/scripts/config.gd` | 18–68, 200–229, 345–413 | defaults; `load_all()` base+overlay merge; `apply()` maps `gameplay.map_width_tiles`/`map_height_tiles` (379–380), seed (381), terrain_type/season/richness/relief (401–404) |
| `app/scripts/data.gd` | 23, 33–35, 109–115, 148–159, 179–188 | `TILE_M=2`, map/seed statics, window/quality, `set_quality()`, BIOME/RICHNESS/RELIEF and relief dome deltas |
| `app/scripts/mapgen.gd` | 13–18, 39–49, 112–199 | donor mask constants, deterministic `pick()`, normalized mask sampling at arbitrary `w,h` |
| `app/scripts/pattern_gen.gd` | 37–58, 130–162, 248–265 | `s=map_w/160`, stamp families, `area_scale` with `maxi(1, …)` counts (small maps still get ≥1 stamp/family) |
| `app/tools/godot_runner.py` | 25–33, 46–57, 309–392, 521–558 | single Godot door, FIFO ticket, hard process-tree kill, isolated result dirs, windowed + headless examples |
| `app/tools/compare_shots.py` | 1–19, 78–102, 105–129, 132–173 | Pillow comparator; SSIM-or-MAD; `--crop` normalized; 0.80 is explicitly a smoke threshold |
| `app/tools/AGENT_PROTOCOL.md` | 14–37, 39–53, 55–69 | never call Godot directly; **never `quit()` in `_initialize()`**; queue waits are not hangs; job budget |
| `docs/COMMANDS.md` | 42–61, 97–100, 294–319 | runner examples, windowed vs headless screenshot, comparison tool caveats |
| `app/shots/boost.json`, `islands.json`, `q_small.json`, `st2.json` | — | config overlay style; `islands.json` shows minimal overlay is legal; `q_small.json` uses an ineffective key |
| `app/assets/terrain/blocks/**`, `water_png/**`, `deco_png/**`, `masks/manifest.json` | glob + 1–1247 | blocks (grass/sand/sandsea/sandrock/rock/test/ground), 8 wave PNGs, 7 deco PNGs, mask water fractions |
| `app/assets/models/sprites/**`, `sprites_hi/**` | glob | tree_fir/oak/pine (both dirs), rock, stone, field; **no bush/stump sprite** |
| `app/config.json` | 20, 37–39 | fog_of_war false, 320×320, seed 20261113 |
| `app/project.godot` | 8, 23–26 | main scene `res://scenes/main.tscn`; `gl_compatibility` renderer |
| `app/scripts/camera.gd` | 12–31, 43–89 | zoom 1.0 default, position set to first town hall; no config/CLI camera key |
| `app/scripts/testbridge.gd` | (via main.gd 148–152, 927–928; COMMANDS.md 103–114) | UI click API only — not needed for terrain capture |

---

## 2. Current screenshot / map-gen flow (concise)

`observed` — `_ready()` parses argv (`main.gd:125–126`), builds `C3Config`, calls `load_all(config_path)` then `apply()` (`:129–131`), then applies `--seed` **after** the config (`:132–135`). Capture modes skip the menu: if `--screenshot` is present, `_setup_full_game()` runs (`:171–172`) → `C3Game.setup()` generates the full map (`:546–549`, `game.gd:222–231`) → `C3World.bind()` builds layers/fog (`:551–553`) → camera/hud/input/audio (`:555–598`) → `_setup_screenshot_window()` (`:183–184`, `:600–617`).

`observed` — each frame `_process()` ticks sim/world (`:947–998`); after `screenshot_frames` (default 120, `:52–54`, `:630–633`) `_save_screenshot()` runs (`:1042–1044`). **Windowed**: `await RenderingServer.frame_post_draw`, grab `get_viewport().get_texture().get_image()`, write PNG, `_quit(0)` (`:1173–1201`). **Headless**: it returns early and writes an 800×600 CPU map picture instead (`:1162–1172`, `:1217–1286`); the windowed path also falls back to that CPU picture if the viewport image is blank (`:1185–1199`). This distinction is decisive: **beauty comparison against donor stills requires the windowed path, not `--headless`.**

`observed` — map generation is driven by `Data.MAP_W/H` (`game.gd:234–235`) which `config.gd:379–380` sets from `gameplay.map_width_tiles`/`map_height_tiles`. `C3MapGen.build()` samples a donor RGB mask into `w×h` cells (`mapgen.gd:112–199`), so shrinking `w,h` shrinks work without changing the feature mix in normalized coordinates (`derived`). `pattern_gen.gd:248–265` scales stamp counts by area but floors each at 1, so even a small map gets forest/stone/hill/decor stamps (`derived`, visually **UNVERIFIED**).

`observed` — all Godot launches must go through `godot_runner.py run --id … --timeout … -- …` (`AGENT_PROTOCOL.md:14–37`; `godot_runner.py:309–392`); the runner kills the process tree at timeout and isolates stdout/stderr into `app/.godot_queue/results/<ticket>_<id>/`.

---

## 3. Approach evaluation table

| Approach | Files touched | Risk | Runner-safe? | Verdict |
|---|---|---|---|---|
| **(a) New `--terrain-sample` flag in `main.gd`** | EDIT `main.gd` (`_parse_args`, `_ready` dispatch, possibly watchdog/screenshot path); NEW config + tool files | MED–HIGH: `main.gd` is contested shared code; any slip breaks the 28/28 selftest and 17/17 uitest (`AGENT_PROTOCOL.md:71–78`); duplicates logic `(c)` already provides | Yes (windowed `--path app`) | **Reject as primary** — needless churn; keep as fallback only if camera framing must be scripted |
| **(b) Standalone scene/script instantiating world/game with a synthetic map** | NEW `.tscn` + NEW `.gd` (≥2 new files), possibly a synthetic map builder | HIGH: must re-implement `world.bind()`/camera/fog/redraw/screenshot/exit wiring (`main.gd:538–617`, `world.gd:122–204`); easy to diverge from real visuals; re-creates the `quit()`-in-`_initialize()` temptation banned by `AGENT_PROTOCOL.md:36–37` | Technically yes, but needs its own watchdog; higher hang risk | **Reject as primary** — undermines the "real renderer" guarantee |
| **(c) Override map size + fixed seed via existing `--config` + `--seed`, captured windowed with `--screenshot`** | NEW `app/shots/terrain_sample.json`; NEW tool scripts. **NO existing file edited** | LOW: `config.gd:379–404` applies every needed key before `game.setup()` (`main.gd:129–131`); capture/dispatch/watchdog untouched; no `quit()` in `_initialize()`; zero merge conflicts | Yes — windowed example at `godot_runner.py:28–29` / `COMMANDS.md:97–98`; headless variant for cheap `--dump-map` scans | **RECOMMEND** — safest, reuses real renderer, avoids full map, zero code edits |

`observed` — why not just use `app/shots/q_small.json`: it contains `{"map_size": 64}` (`q_small.json:1`), but `map_size` is read only in `_apply_menu_cfg()` (`main.gd:245–247`), which is invoked from the menu path (`main.gd:194–209`), not from `--config`. `config.gd:379–380` reads `gameplay.map_width_tiles` / `map_height_tiles`. **`--config shots/q_small.json` therefore does not shrink the map in screenshot mode** — a concrete trap to avoid.

`observed` — the hang rule (`AGENT_PROTOCOL.md:36–37`, `godot_runner.py:10–12`) forbids `quit()` in `_initialize()`. Approach `(c)` never adds a script entry point: exit still happens via `_save_screenshot()` → `_quit(0)` (`main.gd:1201`, `719–721`) inside the proven `_process` + watchdog flow (`main.gd:921–925, 1042–1044`). **Verdict: compliant.**

---

## 4. Recommended design

### 4.1 Exact new/edited file list (no edits to existing files)

| File | Action | Purpose |
|---|---|---|
| `app/shots/terrain_sample.json` | NEW (only config change) | Overlay: 64×64 map, fixed seed, `mediterranean` water, `hills` relief, summer, high quality, fog off, 1280×720 |
| `app/tools/terrain_sample_shot.py` | NEW | Single entry point that (a) prints/execs the exact `godot_runner.py run …` command for the windowed PNG, (b) `--scan-seeds` runs cheap headless `--dump-map` jobs and reports terrain histograms, (c) verifies output is 1280×720 and non-blank. Calls the runner via `subprocess`, **never `godot` directly** |
| `app/tools/terrain_compare.py` | NEW | Pillow side-by-side contact sheet of the port PNG vs one or more `C:\Users\Maxym.Oboyshev\Downloads\c3\` stills; reuses `compare_shots.py` for per-pair scores (SSIM when available, MAD fallback) |
| `app/shots/terrain_sample.png` | GENERATED | Captured real-viewport PNG |
| `app/shots/terrain_sample_contact.png` | GENERATED | Comparison sheet |
| `app/shots/terrain_sample_seedscan.json` | GENERATED (optional) | Best-seed evidence from `--dump-map` |
| `docs/audit/TERRAIN_SANDBOX_PLAN.md` | THIS FILE | Design record (TS-2) |

Explicitly **unchanged**: `app/scripts/main.gd`, `world.gd`, `game.gd`, `config.gd`, `data.gd`, `mapgen.gd`, `pattern_gen.gd`, `app/tools/godot_runner.py`, `app/tools/compare_shots.py`, `app/config.json`, `docs/COMMANDS.md`.

### 4.2 Sample map specification

- **Size:** `64×64` tiles = `128×128 m` (`TILE_M=2`, `data.gd:23`). 4,096 cells vs 102,400 for 320² → ~1/25 the map work (`derived`). Exactly 2×2 chunks of `CHUNK_T=32` (`world.gd:25`), which matches the ≤2-chunks/frame build budget (`world.gd:935–937`) after a few frames — enough frames are given (120).
- **Fixed seed:** candidate `20261113` (project default at `config.gd:48`, `data.gd:35`), overridden by `--seed 20261113`. **UNVERIFIED** that this seed's mask contains all target features; lock the final seed only after the `--dump-map` scan in §4.3 (mask file recorded in `meta.mask.file`, `main.gd:522–529`).
- **Config overlay (exact keys):**
  ```json
  {
    "display": {"window_width": 1280, "window_height": 720, "quality": "high",
                "fog_of_war": false, "vsync": false,
                "units_opaque": true, "show_centroids": false},
    "gameplay": {"map_width_tiles": 64, "map_height_tiles": 64,
                 "terrain_type": "mediterranean", "relief": "hills",
                 "season": "summer", "richness": "rich",
                 "random_seed": 20261113},
    "ai": {"enabled": false}
  }
  ```
  `fog_of_war:false` is important (`app/config.json:20` already false; `boost.json:17` is true and must NOT be used) so the whole sample is visible for beauty comparison (`world.gd:201`, `979–1021`). `quality:"high"` keeps `TERRAIN_PX=16`, `SPRITE_CELL=160`, `FX_CAP=220` (`data.gd:148–159`).

- **What must be present, and how the existing code/assets supply it** (no new donor conversion needed for the baseline):

  | Feature | Mechanism (evidence) | Existing assets |
  |---|---|---|
  | Water body + shore collar | `map_type="mediterranean"` masks have 9–39% water (`masks/manifest.json:406–596`); height thresholds → terrain 3 water, terrain 4 sand collar (`game.gd:669–705`); oriented `sandsea1/5/6` shore tiles (`game.gd:1082–1113, 1150–1157`) | `assets/terrain/water_png/diffusewaves0–7.png` (8 files, renderer uses `diffusewaves2.png` at `world.gd:675–691`); `blocks/sandsea*.png`, `blocks/sand*.png`, `blocks/sandrock*.png` |
  | Ravine / hill with rock face | `relief:"hills"` adds 1 dome (`data.gd:188`) on top of the `domes` budget (`game.gd:644–658`, 7–13 tile radius); steep `|dh|>0.5` → terrain 5 rock + blocked (`game.gd:706–730`); cliff orientation `rock1/3/4/7/8` (`game.gd:1115–1161`); hill stamps paint terrain 5 (`pattern_gen.gd:258–259`, `game.gd:555–561`); relief shading (`world.gd:881–904`) | `blocks/rock1–9.png` (incl. `rock8` high-cliff), `blocks/grass_rock1.png`, `blocks/test*.png` transitions |
  | Conifer + broadleaf trees, varied size | Sacred groves (`game.gd:396–421, 753–767`) + forest stamps (`pattern_gen.gd:242–243, 255`, `game.gd:537–546`); per-tree texture pick (`world.gd:1064–1071`); 0.85–1.15 jitter (`world.gd:111–120`) | `assets/models/sprites/tree_fir.png`, `tree_pine.png`, `tree_oak.png` **and** `sprites_hi/` 512 px versions (`world.gd:219, 236–240`) |
  | Bushes | `decor`/`dcr1` stamps (`pattern_gen.gd:260–261`) → `_add_res("bush",…)` (`game.gd:562–565`); drawn procedurally (`world.gd:1141–1149`) | **No `bush*` sprite exists** (glob `app/assets/models/sprites*/**` = 0 hits); `assets/terrain/deco_png/groundexp0–3.png`, `envfieldd/dw.png`, `christmastreed.png` exist but are **not referenced by any script** (grep = 0 hits) → using them would need new wiring into `world.gd` (out of scope; see §8) |
  | Scattered rocks / stones | `stones`/`stoneforests` stamps (`pattern_gen.gd:256–257`) → stone nodes (`game.gd:567–576`); shadow + sprite draw (`world.gd:1181–1190`) | `assets/models/sprites/rock.png`, `stone.png` |
  | Ground texture variety | `_block_img()` mirror-tiles donor blocks to 1024 px (`world.gd:695–717`); continuous grass + grass7 meadow mix (`world.gd:806–837`); role blocks ground1/grass_ground2/grass_sand1/rock1 (`world.gd:841`); detail bitmaps + 3-pass smoothing (`game.gd:972–1006, 1241–1248`) | `blocks/grass1–10.png`, `grass_ground1–3.png`, `ground1.png`, `sand1–9.png`, `test0–25.png`, `rock1–9.png`; `structs/tile_lowground.png`, `tile_highground.png` |
  | Stumps (optional decor) | `_draw_resources()` stump branch (`world.gd:1133–1139`) | No `tree_stump` sprite → procedural fallback only |

  `observed`/`derived` — all required baseline sprites/blocks/water are already in `app/assets`; **no new donor conversion is required** for the first sample. Visual fidelity of the result remains **UNVERIFIED** until a capture is made.

### 4.3 Capture command (exact, windowed = real renderer)

From project root, via the only legal Godot door (`AGENT_PROTOCOL.md:18–28`):

```
python app\tools\godot_runner.py run --id ts2-terrain-sample --timeout 90 -- --path app -- --config shots/terrain_sample.json --seed 20261113 --screenshot shots/terrain_sample.png --screenshot-frames 120 --timeout 60
```

- No `--headless` → windowed viewport capture (`main.gd:1173–1201`). The runner permits this form (`godot_runner.py:28–29`, `COMMANDS.md:97–98`).
- `--config shots/terrain_sample.json` resolves to `app/shots/terrain_sample.json` (`config.gd:234–243`; same pattern as `COMMANDS.md:95`).
- `--seed 20261113` is applied after config (`main.gd:132–135`).
- Lands at **`app/shots/terrain_sample.png`** (relative path → workspace root via `main.gd:1114–1141`, written by `:1301–1311`). Runner logs: `app\.godot_queue\results\<ticket>_ts2-terrain-sample\stdout.txt` / `stderr.txt` (`godot_runner.py:317–320`). Success line in stdout: `screenshot saved: …` (`main.gd:1200`).
- Budget: 90 s runner hard timeout, 60 s in-game watchdog (`main.gd:154–157`, `--timeout` at `:674–677`), generous tool timeout ≥300000 ms per `AGENT_PROTOCOL.md:39–53`.

**Headless variant — seed scan only, NOT a beauty capture** (writes sim JSON fast, no GPU):

```
python app\tools\godot_runner.py run --id ts2-seedscan-20261113 --timeout 90 -- --headless --path app -- --config shots/terrain_sample.json --seed 20261113 --dump-map scans/terrain_sample_seedscan.json --timeout 60
```
`--dump-map` writes `seed`, `map_w/h`, base64 `terrain`/`height`/`tileblock`, and `meta.mask` (`main.gd:506–536`) → decode `terrain` and count values 2 (forest), 3 (water), 5 (rock) to accept/reject the seed. Repeat for a handful of seeds; stop at the first that meets §7 criterion 6.

### 4.4 Comparison method

1. **Score (reuse existing tool, no edits):** `python app\tools\compare_shots.py --shot app\shots\terrain_sample.png --ref "C:\Users\Maxym.Oboyshev\Downloads\c3\cossacks-3-v1-498085.jpg" --json` — that donor still is 1280×720 (verified), so `--crop` can isolate a terrain-only region and exclude HUD/units. The tool resizes/crops both to a common region (`compare_shots.py:78–102`) and prefers skimage SSIM, else normalized MAD (`:105–129`). **Do not treat 0.80 as a gate** (`COMMANDS.md:315–319`); record the number as a smoke metric and calibrate per region with the owner.
2. **Contact sheet (new `app/tools/terrain_compare.py`):** Pillow (`Image.open`/`convert("RGB")`/`LANCZOS` resize) builds a labelled side-by-side grid: port PNG on the left, each donor image (or its crop) on the right, output `app/shots/terrain_sample_contact.png`. Same comparator function can be imported from `compare_shots.py` for the per-cell scores.
3. Human review: compare hills/rock faces, shoreline, tree variety, bush/rock scatter and ground grain; explicitly ignore units (donor images contain infantry; port sample uses `start_peasants` default 8 at `config.gd:59` — optionally set `start_peasants: 0` in the overlay, **UNVERIFIED** that sim remains happy, or simply crop them out).

---

## 5. File-ownership table for the build phase

| File | Single owner role | Why |
|---|---|---|
| `docs/audit/TERRAIN_SANDBOX_PLAN.md` | **TS-2** (author; this design doc only) | Research/design lane deliverable; no code edits |
| `app/shots/terrain_sample.json` | **BUILDER-CONFIG** | One writer for the single config overlay; prevents seed/size drift |
| `app/tools/terrain_sample_shot.py` | **BUILDER-CAPTURE** | Owns the runner command, seed scan and PNG validation; sole writer of `app/shots/terrain_sample.png` and `app/shots/terrain_sample_seedscan.json` |
| `app/tools/terrain_compare.py` | **BUILDER-COMPARE** | Owns contact-sheet generation; sole writer of `app/shots/terrain_sample_contact.png`; reads (never edits) `compare_shots.py` |
| `app/scripts/main.gd` | **NO OWNER for this task — must stay unchanged.** If a later iteration proves camera framing must be scripted, assign exactly one builder: **BUILDER-MAIN** | Approach `(c)` needs no edit; contested shared file, keep it out of the build to avoid merge loss |
| `app/scripts/world.gd`, `game.gd`, `config.gd`, `data.gd`, `mapgen.gd`, `pattern_gen.gd` | No owner — unchanged | Harness is config/tooling only |
| `app/tools/godot_runner.py`, `app/tools/compare_shots.py` | No owner — read-only reuse | Stable infrastructure; no edit required |
| `docs/audit/TERRAIN_DONOR_*.md`, `docs/audit/TERRAIN_PORT_*.md` (e.g. existing `TERRAIN_DONOR_WATER.md`, `TERRAIN_PORT_HILLS.md`) | Other research agents (not TS-2) | Already owned by the 8 research docs; no overlap |
| `docs/COMMANDS.md` | Optional: **BUILDER-DOCS** only if owner approves; otherwise untouched | Avoid contested docs editing; not required for the harness |

No two roles write the same file; no new file overlaps the existing research-doc owners or the contested renderer/sim files.

---

## 6. Claim table

| Claim | Evidence | Method | Verdict | Correction |
|---|---|---|---|---|
| Headless `--screenshot` uses a CPU map render, not the real renderer | `main.gd:1162–1172`, `1217–1286`; `COMMANDS.md:99–100` | code/doc read | observed | — |
| Windowed `--screenshot` grabs the real viewport and writes a PNG, falling back to CPU render only if blank | `main.gd:1173–1201` | code read | observed | — |
| `--config` can shrink the map without code edits | `config.gd:200–229`, `345–381`; `main.gd:129–131` | code read | observed | — |
| `q_small.json`'s `map_size:64` shrinks the map in screenshot mode | `q_small.json:1` vs `config.gd:379–380` and `main.gd:245–247` | code read | observed | **CORRECTION:** `map_size` is menu-only; use `gameplay.map_width_tiles`/`map_height_tiles` |
| The runner accepts windowed Godot (no `--headless`) | `godot_runner.py:25–33`, `309–392`; `COMMANDS.md:97–98` | code/doc read | observed | — |
| `quit()` in `_initialize()` is banned; the chosen design avoids it | `AGENT_PROTOCOL.md:36–37`; `main.gd:719–721, 921–925, 1042–1044, 1201` | doc/code read | observed | — |
| Small maps still get forest/stone/hill/decor stamps | `pattern_gen.gd:248–265` (`maxi(1, …)`) | code read | derived | Visually **UNVERIFIED** |
| Donor mask features survive 64×64 sampling | `mapgen.gd:112–199` (normalized `sy0/sy1`, `sx0/sx1`) | code read | derived | **UNVERIFIED** until `--dump-map` histogram |
| The candidate seed `20261113` yields all required features | `mapgen.gd:39–49`; `manifest.json:406–596` | inference from mask table | **UNVERIFIED** | Must run the §4.3 seed scan and lock a seed with water≥5%, rock≥3%, forest≥5% |
| Bush/stump art exists as sprites | glob `app/assets/models/sprites*/**` → 0 bush/stump hits; `world.gd:1133–1149` procedural fallback | glob + code | observed | **CORRECTION:** procedural only |
| `app/assets/terrain/deco_png/**` is wired into the renderer | glob found 7 PNGs; grep `deco_png\|groundexp\|christmastreed\|envfield` in `app/scripts` → 0 hits | glob + grep | observed | **CORRECTION:** unused; new `world.gd` wiring needed (out of scope) |
| `_scatter_bushes()` populates bushes during mapgen | `game.gd:425–453`; grep shows only the definition | grep | observed | **CORRECTION:** never called; rely on `decor` stamps (`game.gd:562–565`) |
| `compare_shots.py` 0.80 threshold is a fidelity gate | `compare_shots.py:15–18, 139–141`; `COMMANDS.md:315–319` | doc/code read | observed | **CORRECTION:** smoke test only; calibrate per check |
| `testbridge.gd` is needed for the terrain sample | `main.gd:148–152, 927–928`; `COMMANDS.md:103–114` | code/doc read | observed | Not needed — it drives menu/HUD only; excluded |

---

## 7. Acceptance criteria for the harness itself

1. **One runner job, windowed:** command in §4.3 run with `--id ts2-…`, no `--headless`, runner result `status: ok`, `exit: 0`, stdout contains `screenshot saved:` (`main.gd:1200`). No direct `godot` invocation anywhere (`AGENT_PROTOCOL.md:14–17`).
2. **Real renderer, not fallback:** `app/shots/terrain_sample.png` exists and is **1280×720** (the CPU fallback is 800×600 — `main.gd:1164, 1188, 1196`). It is non-blank: >100 KB and multiple luminance levels (cf. `_is_blank()` logic at `main.gd:1203–1213`).
3. **Fast:** runner result `run` < 60 s and in-game watchdog not fired (`main.gd:923–925`); 120 frames complete (`main.gd:54, 1042–1044`).
4. **Clean concurrency:** 0 orphan Godot processes (`godot_runner.py doctor`/`status`, `app/tools/assert_clean.py`), FIFO result directory present, no duplicate ticket from re-submission (`AGENT_PROTOCOL.md:39–53`).
5. **Tiny map actually used:** captured PNG's stdout/`--dump-map` sibling reports `map_w=map_h=64` (not 320/160); config overlay proven applied.
6. **Seed content gate:** `--dump-map` terrain histogram for the locked seed has water(t=3)≥5%, rock(t=5)≥3%, forest(t=2)≥5%, plus recorded `meta.mask.file`; mask is one with shore/relief (e.g. `mediterranean` family, `manifest.json:406–596`).
7. **Comparison produced:** `app/shots/terrain_sample_contact.png` exists; at least one `compare_shots.py --json` score against a named `C:\Users\Maxym.Oboyshev\Downloads\c3\` still is recorded with method (`ssim`/`norm_mad`) and crop, explicitly labelled a smoke metric, not a pass/fail gate.
8. **Ownership/rollback clean:** `git status` shows only the one doc + the new harness files and generated outputs; no existing tracked file modified; per `AGENT_PROTOCOL.md:9–12` any future edit to an owned file requires a backup first.

---

## 8. Open questions

1. **Which exact seed/mask composition?** Candidate `20261113` is a placeholder; the `--dump-map` scan must decide. **UNVERIFIED.**
2. **Does windowed capture work in this swarm environment?** The runner supports it, but a live desktop/GPU is assumed. If unavailable, the capture silently becomes the 800×600 CPU map (`main.gd:1185–1199`) and the beauty comparison is invalid; then approach `(a)` or `(b)` with an explicit offscreen render would be needed. **UNVERIFIED.**
3. **Camera framing:** default view centres on the first town hall (`main.gd:558–562`, `camera.gd:16–31`); there is no CLI/config camera key. If the showcase feature is off-screen, either pick a seed whose features sit near the start, or authorize **BUILDER-MAIN** for a narrow `main.gd` change. **UNVERIFIED.**
4. **Deco assets:** `app/assets/terrain/deco_png/**` are unreferenced. Wire them into `world.gd` (contested file) or leave procedural bushes? Defer to owner.
5. **Units/HUD in comparison:** set `start_peasants: 0` in the overlay (config.gd:382 permits 0; sim side effects **UNVERIFIED**) or simply crop them out of both images.
6. **Ore saturation on a small map:** `richness:"rich"` adds +1 ore node per start (`data.gd:186`, `game.gd:803–814`) — may clutter a 64×64 sample; confirm visually.
7. **Chunk warm-up:** `_sync_terrain_chunks()` builds at most 2 chunks/frame (`world.gd:935–937`); 4 chunks need ≥2 frames, well inside the 120-frame budget — confirm the first PNG has no unbuilt black quadrants. **UNVERIFIED.**
