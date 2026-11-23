# Naval port plan — P-10 (worker agentAC)

Read-only donor evidence: `NAVAL_EVIDENCE.md`. Donor is **PRIVATE USE ONLY** —
never redistribute raw `.oss`/`.osm`/`.dds`/`.aaf`/`.acl` files. Only derived
sheets and `index.json` may enter `res://`.

## 1. Proof of feasibility — DONE (2026-11-21)

Exact mandated command (Blender 5.2.3 LTS; install dir prepended to PATH because
`blender` is not on PATH by default):

```
blender --background --factory-startup --python app/tools/bake_naval.py -- --game "C:\Games\Cossacks 3" --out app/assets/models/anim/naval --only yacht --size 160 --samples 4 --engine cycles
```

Result: **SUCCESS**, exit 0, Blender CPU Cycles @ 4 samples, 96 + 8 renders in
~20 s. No faked output; stdout showed:

```
naval read yacht: k=311 fps=30 bones=20 v=584 f=947; aaf=yacht.aaf acts=['attack0','death','idle','walk']
naval plan yacht/walk: frames=12 dur=9.333 ortho=6.047 center=(0.0, 0.0, 1.481)
naval sheet .../naval/yacht_walk.png 1280x1920
naval hull yacht: v=9364 f=7731 ortho=11.355 center=(0, -0.805, 3.214)
naval sheet .../naval/yacht_hull.png 1280x160
naval OK yacht
```

Produced files (only these; all scratch in `tempfile.mkdtemp()` under `%TEMP%`,
e.g. `C:\Users\MAXYM~1.OBO\AppData\Local\Temp\cossacks_naval_*`, never in res://):

| File | Verified evidence |
|---|---|
| `app/tools/bake_naval.py` | new thin wrapper; `py_compile` OK; reuses `bake_sprites.py` (K-01) for read/skin/sample/scene/material/mesh/camera/render helpers |
| `app/assets/models/anim/naval/index.json` | schema-identical to `anim/index.json`: `{yacht:{cell:160, actions:{walk:{...}, hull:{...}}}}` |
| `app/assets/models/anim/naval/yacht_walk.png` | 1280×1920, 296,180 B, alpha bbox (9,32)–(1217,1882), 1.87 % opaque — real 8-dir × 12-frame sheet |
| `app/assets/models/anim/naval/yacht_hull.png` | 1280×160, 64,940 B, alpha bbox (23,33)–(1242,152), 6.15 % opaque — visually confirmed 8 ship views |

### Critical discovery — do not integrate the `.oss` as the ship

- The animated `yacht.oss` (and the four identical 217,344-byte `.oss` files)
  is a **~584-vert humanoid crew figure with a pole**, using the normal land-unit
  `idle/walk/death/attack0` bone clips. Visually confirmed: `yacht_walk.png`
  renders a sailor, not a vessel.
- The **ship hull is the static `.osm`**: `yacht.osm` = 9,364 verts / 7,731 faces,
  bbox x −1.75..1.75, y −4.82..3.21, z −0.38..6.80 (hull + masts + rigging).
  `yacht_hull.png` is the real naval sprite.
- Both `bake_sprites.read_osm_first()` (K-01) and this wrapper's reader take the
  UV/face/vertex offsets from header longs **12/13/14** (132 / 92052 / 277596
  for `yacht.osm`). DC's byte-closure check (finding fnd_7,
  `docs/decomp/DC_FORMATS.md`) confirms both produce byte-identical arrays
  (9364 verts / 7731 faces / 11490 uvs / 7731 uvf) and the same bbox. My earlier
  claim of a 10/11/12 defect was a miscount of the 17-name header list and is
  **retracted** — no shared-reader fix is needed.

**Integration therefore needs two layers:** static hull (`hull` action) +
optional animated crew overlay (`walk`/`idle` action), composited in `world.gd`.

## 2. The seven families

`.oss` = animated rig available; `.osm` = static hull always available. All
families ship `_death1/_death2` wreck `.osm` files (wreck sprites, not yet baked).

| Family | animated `.oss`? | Static hull / direction variants | Unit `.aaf` actions | Extra part `.aaf` clips |
|---|---|---|---|---|
| `battleship` | **no** | `.osm` + 1–4 + death1/2 | idle, walk, death, attack0 (1–280) | `_flag` idle; `_sail` idle/idle_to_walk/walk/walk_to_idle |
| `fishboat` | yes (217,344 B) | `.osm` + 1–4 + death1/2 | idle, walk, death, attack0 (1–280) | `_paddle` idle/idle_to_walk/walk/walk2/walk_to_idle; `fishboata` idle |
| `frigate` | yes (217,344 B) | `.osm` + 1–4 + death1/2 | idle, walk, death, attack0 (1–280) | `_flag` idle; `_sail` idle/idle_to_walk/walk/walk_to_idle |
| `galley` | yes (217,344 B) | `.osm` + 1–4 + death1/2 | idle, walk, death, attack0 (1–280) | `_flag` idle; `_paddle` + `_sail`, each idle/idle_to_walk/walk/walk2/walk_to_idle |
| `xebec` | **no** | `.osm` + 1–4 + death1/2 | idle, walk, death, attack0 (1–280) | `_flag` idle; `_sail` idle/idle_to_walk/walk/walk_to_idle |
| `yacht` | **yes — baked** | `.osm` + 1–4 + death1/2 | idle, walk, death, attack0 (1–280) | `_flag` idle; `_sail` idle/idle_to_walk/walk/walk_to_idle |
| `yachttur` | yes (217,344 B) | `.osm` + 1–4 + death1/2 | idle, walk, death, attack0 (1–280) | `_sail` idle/idle_to_walk/walk/walk_to_idle |

Other naval families present in the donor but not in the seven ship families:
`chaika` (sail/flag/chaikaa), `ferry` (paddle/ladder). Decorative `boat1..5.osm`
and `shipwreck1..3.osm` live in `data\actors\env`, not `units`.

`data\animations\acl` naval clips (9): `battleship`, `fishboat`, `frigate`,
`galley`, `shippaddle`, `shipsail`, `xebec`, `yacht`, `yachttur` — text
descriptors (e.g. `yacht.acl` begins `section.begin ... refkey=.idle`); they
encode state transitions to feed action selection, not extra geometry.

Materials: `data\materials\units\<family>.dds` exists for at least
`battleship`, `fishboat`, `yacht`, `yachttur`; verify `frigate`/`galley`/`xebec`
before baking (the wrapper will raise a clear `FileNotFoundError` per key).

## 3. Exact additional bake commands

All from project root. Prepend Blender once per shell session:
`$env:PATH = "C:\Program Files\Blender Foundation\Blender 5.2;" + $env:PATH`

Animated families (produce `<key>_walk.png` + `<key>_hull.png` + index entry):

```
blender --background --factory-startup --python app/tools/bake_naval.py -- --game "C:\Games\Cossacks 3" --out app/assets/models/anim/naval --only fishboat --size 160 --samples 4 --engine cycles
blender --background --factory-startup --python app/tools/bake_naval.py -- --game "C:\Games\Cossacks 3" --out app/assets/models/anim/naval --only frigate  --size 160 --samples 4 --engine cycles
blender --background --factory-startup --python app/tools/bake_naval.py -- --game "C:\Games\Cossacks 3" --out app/assets/models/anim/naval --only galley   --size 160 --samples 4 --engine cycles
blender --background --factory-startup --python app/tools/bake_naval.py -- --game "C:\Games\Cossacks 3" --out app/assets/models/anim/naval --only yachttur --size 160 --samples 4 --engine cycles
```

Hull-only families (no `.oss`):

```
blender --background --factory-startup --python app/tools/bake_naval.py -- --game "C:\Games\Cossacks 3" --out app/assets/models/anim/naval --only battleship --hull-only --size 160 --samples 4 --engine cycles
blender --background --factory-startup --python app/tools/bake_naval.py -- --game "C:\Games\Cossacks 3" --out app/assets/models/anim/naval --only xebec      --hull-only --size 160 --samples 4 --engine cycles
```

Optional extra actions for the animated families (uses the same wrapper):

```
... --only yacht --action idle --no-hull --size 160 --samples 4 --engine cycles
... --only yacht --action death --no-hull --size 160 --samples 4 --engine cycles
... --only yacht --aaf yacht_sail.aaf --action walk --no-hull --size 160 --samples 4 --engine cycles
```

`--aaf` redirects to the sail/flag sub-clips; note the wrapper currently writes
the sheet as `<key>_<action>.png`, so baking both `yacht.aaf` and
`yacht_sail.aaf` `walk` would collide — rename the sail sheet (or add a suffix
flag) before doing that in bulk. Every command reuses the same `index.json` and
merges new actions into the existing entry.

## 4. Integration points (for the coordinator, AFTER A closes)

Ownership reminder: `game.gd` / `data.gd` are A's until A-01 closes; `world.gd`
is D's (P-09) until it closes. These are **hand-off notes only** — AC edited none
of them.

### `app/scripts/data.gd` (A)
- Add naval sids to `Data.UNITS` (declared at `data.gd:785`; unit defs around
  `:330–:640`). Start with `yacht`; mirror the shape of existing defs: `hp`,
  `speed` (water speed, ~2–4 m/s), `price`, `build_time`, `weapons` (cannonball
  range), `prot[6]`, `radius` (~1.5–2 m for a hull — much larger than a man),
  `icon: Rect2(...)`. Add a flag such as `"naval": true` so movement code can
  branch.
- Add a producing building to `Data.BUILDINGS` (`:786`, defs `:640–:680`): no
  `dock`/`shipyard` exists today. Add `"dock"` with `"trains": ["yacht", ...]`;
  `train_unit()` (`game.gd:2301–2329`) already gates strictly on
  `building.def.trains`, so this is the only training hook needed.
- `Data.resolve_sid(nat, sid)` (`game.gd:2305`) — ensure naval sids pass through
  unchanged (no nation variant), or add explicit naval aliases.

### `app/scripts/game.gd` (A)
- `_blocked_for()` (`game.gd:79`) and `BLK_WATER := 255` (`:37`): water cells are
  hard blockers for all units. Add a naval branch that **allows water** and
  blocks land/shore for `"naval": true` entities (ships must not walk on grass).
- `_step_move()` (`game.gd:2703+`) and `_nav_wanted()`/`_nav_repath()` (`:2670–2700`):
  the A* grid and the rotated-probe steering both call `_blocked_for`, so the
  naval branch propagates automatically; verify slope checks (`:2758`) do not
  reject water and that the 13-probe fallback still works on open water.
- Spawn point on train completion: ships must appear in water adjacent to the
  dock, not on the dock's land tile (same area as `train_unit` spawn logic).
- Build rules: `cmd_build` water checks at `game.gd:2215` and `:2245` already
  reject water for buildings — keep that; only unit movement changes.
- `apply_damage` protection indexing (`data.gd:831–834`, ticket P-06) affects
  ships too — resolve P-06 before assigning naval combat.

### `app/scripts/world.gd` (D / P-09)
- `anim_index` is loaded from `_anim_dir() + "/index.json"` at `world.gd:142`.
  Add a second load for `res://assets/models/anim/naval/index.json` into a
  separate `naval_index` (do **not** merge into the existing `anim_index`: the
  `hull` pseudo-action would pollute `_anim_action`'s fallback chain at
  `:278–291`). `_anim_dir()` (`:264–271`) already handles the `SPRITE_CELL`
  variant directory; mirror that for the naval dir.
- `_draw_anim()` (`world.gd:273–341`) builds the sheet path as
  `%s/%s.png % [_anim_dir(), key + "_" + act]` (`:294`). Add a naval equivalent
  that resolves `<key>_<act>.png` under the naval dir and uses the same
  `ortho`/`ax`/`ay` scaling math (`:323–340`) — the hull's `ortho=11.355` is
  already in the index, so true donor-scale sizing works without a new constant.
- `_draw_units()` (`world.gd:1355+`, call at `:1387`): for a naval entity, draw
  the static `hull` sheet first, then composite the small crew sheet
  (`walk`/`idle`) at the hull's deck anchor. The crew `ortho=6.047` and hull
  `ortho=11.355` are different groups; use a fixed deck offset (e.g. hull
  `ay` minus ~0.18 of the hull cell) rather than the crew's own `ay`, which is
  ground-anchored for a walking man.
- `_anim_action()` (`world.gd:235–262`) — naval units have no `gather/build/
  carry` orders; map `moving → walk`, idle → `idle` (currently not baked for
  yacht; add with `--action idle`), attack → `attack0` (rename or alias).
- `_sprite_for()` / `SPRITE_ALIAS` (`world.gd:81–84, :208–222`): no alias change
  needed if naval sids are added to `Data.UNITS`, but `_load_sprites()`
  (`:169–199`) will probe `assets/models/sprites/yacht_*.png` and find none;
  harmless (falls through to procedural shapes), yet the naval branch must take
  priority over those fallbacks (same priority as `__anim__` at `:1389`).
- Wreck/death: `yacht_death1/2.osm` exist; bake later as a `dead` sheet and draw
  via `_draw_corpses()` (`world.gd:1358`) if wrecks are wanted.

## 5. Open questions

1. Should ships be a new `kind` (e.g. `kind:"ship"`) rather than a flagged
   `kind:"unit"`? Affects `game.gd:2368` tick dispatch and HUD selection.
2. What real donor stats (hp/speed/range/price) should the 7 hulls use? The port
   has no naval mechanics data; current plan estimates only.
3. Direction convention: hull sheet dir 2 already reads as a bow-on view and
   dir 6 as stern-on. Confirm `e.face` +4 mapping at `world.gd:314` is correct
   for ships or needs a −4 yaw offset.
4. Sail/paddle/flag sub-clips (`.aaf`/`.acl`) are separate meshes/animations not
   yet read by the wrapper. Is a second animated overlay layer in scope, or is
   static hull + crew sufficient for acceptance N-11 ("≥1 naval sid with 8-dir
   baked sprite, buildable from a dock")?
5. `frigate`/`galley`/`xebec` material `.dds` presence not yet confirmed; check
   before running the batch commands.
6. ~~`bake_sprites.read_osm_first` offset bug~~ **RETRACTED** — DC refuted it
   (fnd_7): both readers use longs 12/13/14 and return byte-identical arrays.
   No action needed.
