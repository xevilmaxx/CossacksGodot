# Unit sprite baking — definitive fix (2026-11-20)

How the project's animated unit sheets (`app/assets/models/anim/`) are baked
from the donor game (`C:\Games\Cossacks 3`), what was broken, and exactly what
was changed. Written after the peasant (`peaukr.oss`) was brought to reference
quality and verified frame by frame; the same pipeline then rolled out to all
54 unit keys.

## 1. Donor layout (what the original gives us)

```
C:\Games\Cossacks 3\data\actors\units\<base>.oss        skinned mesh + animation
C:\Games\Cossacks 3\data\animations\aaf\<base>.aaf     named action -> frame ranges
C:\Games\Cossacks 3\data\actors\units\attach\<base>_<tool>.oss   hand props
C:\Games\Cossacks 3\data\actors\units\attach\<base>_tools.actor  prop manifest
C:\Games\Cossacks 3\data\materials\units\<base>.dds     body texture
C:\Games\Cossacks 3\data\materials\units\peaaustools.dds  shared prop texture
```

### 1.1 `.oss` binary format (all integers little-endian)

Header: 6× int32 = `k, fps, bones, verts, faces, uvs`
(`k` = frame count, e.g. peaukr has 483 frames at 30 fps, 20 bones, 577 verts).

Then: verts (`k`×float32 xyz), faces (`3×int32` indices), uvs, uv-faces,
per-vertex weights (`int count` + `(bone_index, float)` pairs), then the
animation: `bones × frames` records of 7 floats.

A 7-float record is `(px,py,pz, rx,ry,rz,rw)`: bone translation + quaternion.
Verified: `|(rx,ry,rz,rw)| == 1.000` on every sampled bone/frame, and rest
frames read `(0,0,0,1)` — so the split and the `(x,y,z,w)` order are correct.

### 1.2 Named actions (`.aaf`)

Plain text: `"name",first,last,morph` per line, e.g. `peaukr.aaf`:

- `walk 1..20`, `idle 64..113`, `attack0 = workwood 237..254` (same chop),
  `workfood 278..299`, `workstone 217..234`, `construct 186..198`,
  `walkwood 22..41`, `walkfood 257..276`, `walkstone 43..62`,
  `idlewood 354..403`, `idlefood 405..454`, `idlestone 303..352`,
  `death 115..149`.
- Soldiers: `walk` + `walk0`/`walkprepare0` march variants; musket types fire
  with `attack1`, pike types thrust with `attack0`; grenadiers have
  `attack0/1/2`. The baker prefers `attack1` over `attack0` so gunpowder units
  don't play a melee lunge for `"attack"`.

The bind pose is already centred at the origin with feet at `z ~ 0`
(peaukr bind bbox `x ±0.72, y -0.23..0.29, z 0.01..2.0`). A model that looks
"lying on the ground" in an external viewer is a Y-up viewer showing Z-up
data — the file needs no corrective rotation.

### 1.3 Attach props (the hand tools)

Peasants keep tools as **separate one-bone meshes** with their own full-length
(483-frame) track over the same AAF timeline:

| file | verts | follows | used for |
|---|---|---|---|
| `peaukr_axe.oss` | 124 | hand | `workwood`, `attack` |
| `peaukr_hammer.oss` | 128 | hand (bone 7, exact) | `construct` |
| `peaukr_hoe.oss` | 148 | hand | `workfood` |
| `peaukr_pick.oss` | 62 | hand | `workstone` |
| `peaukr_bag.oss` | 172 | torso area | `walkfood`, `idlefood` |
| `peaukr_lumber.oss` | 1214 | shoulder | `walkwood`, `idlewood` |
| `peaukr_cart.oss` | 495 | trails 1.3 m behind | `walkstone`, `idlestone` |

(`peaukr_hammer` bone 0 == body bone 7 translation exactly at idle rest
frames — the manifest's `peaukr_tools.actor` lists all seven against the same
`peaukr.aaf`.) The in-mesh "tool" verts (e.g. peaukr bone 5, 23 verts) are a
sleeve/shoulder stub, **not** the tool — scaling them was tried and produced
a white board (see §3.5). All 8 peasant nations ship the same 7 attach files
under their own prefix; all share the `peaaustools.dds` texture.

## 2. Bugs found (with evidence)

### Bug 1 — rotations applied transposed (poses inhuman, tools detached)

The baker built rotation matrices column-major (`M·v`). The donor stores
them row-major: with the textbook matrix the right hand skinned to
`(-0.98,-0.38,1.75)` (mirrored + raised) while its hammer sat 1.2 m away at
idle rest; 124 faces stretched `0.1 m → 3.6 m` (bind → skinned edge length),
rendering the infamous giant white bar. Transposed (`M�ᵀ`, i.e. the
conjugate rotation), the hand hangs at `(+0.36,-0.03,0.85)` with the tool
gripped at `(+0.27,+0.06,1.34)`. Verified bone by bone against the bind pose.
Fix: `qmat()` in `app/tools/bake_sprites.py` returns the transpose
(same fix mirrored into `compute_ortho.py`). Predicted peasant framing
tightened from 7.2 m to 4.1 m ortho with zero clips.

### Bug 2 — de-travel pinned the HEAD, not the root

The old code picked the max-weight bone as reference; on the peasant that is
the HEAD/HAT (bind `z 1.6..2.0`, 126 weight units), whose station offsets
(`y +1.15` in `workfood`) blew the shared union to ~6–8 m and made bodies
swing around a pinned hat. Fix: always bone 0 (hips/pelvis, stable, ±0.3 m
over the whole timeline). Standing clips re-base to one global HOME (root at
the first idle frame); `death` keeps a per-clip reference (its first frame ≈
standing) so the fall plays out instead of being pinned upright.

### Bug 3 — per-action centre/ortho (the build jump, off-centre soldiers)

Every action used to get its own camera centre/scale from its own union:
peasant `walk` centre `[-0.01,0.02]` vs `construct` `[+0.67,-0.35]` with ortho
2.92 vs 4.36; pikeman `walk` vs `attack` centres 1.7 m apart. Switching actions
teleported feet by ~0.7 m (peasants) and ~1.7 m (pikemen); ink-union anchors
(`cx=0.5` of a clipped union) put bodies beside their tile.
Fix: one shared `stand` group + one `death` group per unit — centre
`XZ=(0,0)` (the entity origin), `Z` = union mid-height, one ortho per group,
one projected ground anchor `(ax,ay)` per group stored in `index.json`
(`world.gd` prefers `ax/ay`, falls back to `cx/foot` for old sheets).

### Bug 4 — 3D-bounds margin clipped diagonal views

`max(dx,dy,dz)×1.4` underestimates diagonal projection (a long cannon barrel
at 45° spans the full cell; 16 sheets still touched edges). Fix:
`projected_ortho()` projects every skinned vertex of every frame through all
8 orthographic cameras (elevation 32°, same rig as the Blender `camera()`),
then fits **twice the largest single-side deviation** (`2·max|x0|,|x1|,|y0|,|y1|`,
×1.12 AA bleed) — spans are asymmetric (lunges reach `-2.0/+0.7`), so fitting
the width alone clips the long side.

### Bug 5 (missing feature) — attach props were never baked

The in-mesh stub is not the tool, so every peasant action rendered empty- or
stub-handed. Fix: per-action tool mapping baked into a **combined**
body+prop mesh (two materials: body texture + `peaaustools.dds`), skinned with
the prop's own track plus the body's root detravel so it stays glued:

- axe → `workwood`, `attack` · hammer → `construct` · hoe → `workfood`
- pick → `workstone` · lumber → `walkwood`, `idlewood`
- bag → `walkfood`, `idlefood` · cart → `walkstone`, `idlestone`

## 3. What the baker does now (`bake_unit`)

1. Parse `.oss`/`.aaf`; build the action plan (walk, idle, attack with
   `attack1`-first preference, work/construct, carry walks/idles, death).
2. Skin every sampled frame with the **transposed** quaternions; de-travel
   with bone 0 against global idle HOME (per-clip ref only for death).
3. Skin the action's attach prop with its own track + the same detravel.
4. Group union (`stand`/`death`) over body+prop verts → centre `(0,0,mid-z)` →
   projected long-side ortho (§2, bug 4) → one projected origin anchor.
5. Render 8 azimuths per frame (Blender: ortho camera, elevation 32°,
   emission/shadeless material, transparent film; Workbench engine for speed,
   identical look to Cycles for these unlit sprites), assemble
   `<key>_<action>.png` sheets (`cols=8`, `rows=frames`), write
   `index.json`: `{cell, actions:{frames, duration, loop, ortho, center,
   ax, ay, tool}}` plus measured `bbox/fig_h/foot/cx` fallbacks.

## 4. Game-side changes (`app/scripts/world.gd`)

- `_anim_action()`: carry-aware — moving peasants with `carry>0` play
  `walkwood/walkfood/walkstone`; loaded idles play `idlewood/idlefood/idlestone`;
  gather/build select `work*/construct` as before.
- `_draw_anim()` (+ corpse preview): anchor with `ax/ay` when present
  (fallback `cx/foot`); fallback chain `walkwood→walk`, `idlewood→idle`,
  `work*/construct→attack→idle` so old sheets without carry clips keep working.
- `compute_ortho.py` is now audit-only (torso rule + projection math mirror the
  baker; it prints expected vs baked orthos, writes nothing).
- `sheet_metrics.py` fills `bbox/fig_h/foot/cx` fallbacks, never overwrites
  `ax/ay`, and prints `CLIP` alarms for any union touching a cell edge.

## 5. Verification (per unit, before rollout)

`verify_sheets.py <key>`: every sheet present, shared stand ortho/centre/anchor
(`GROUP_OK`), zero edge-touching cells over all dirs×frames, anchor fields set.
Plus eyeballing: full-frame strips per action (all dirs) and hand close-ups;
`construct`/`workwood` must show the implement gripped and swinging, carry
walks must show the load (lumber bundle / sack / cart), death must fall.

Peasant reference numbers: stand ortho `4.136`, anchor `(0.5, 0.857)`, zero
clips on 992 standing cells; `GROUP_OK`. Pikeman re-verified with the same
pipeline (shared anchor, no clips).

## 6. Rollout procedure (all 54 unit keys)

```bat
blender --background --factory-startup --python app/tools/bake_sprites.py -- --game "C:\Games\Cossacks 3" --out "app\assets\models\anim" --size 160 --engine workbench
python app/tools/sheet_metrics.py --dir app/assets/models/anim
python <tmp>\verify_sheets.py <every key>     :: expect GROUP_OK + zero CLIP lines
godot --headless --path app -- --self-test app/selftest.json   :: must stay passed
```

Rollout completed 2026-11-20: all 54 keys baked (one transient
`tmp\cell.png` write error on `pol_peasant`, clean on retry), full audit
`verify_all`: **ALL PASS** (shared stand ortho/centre/anchor per unit, zero
edge-touching cells), sim self-test `passed: True`.

Caveats: peasant variants differ in skeleton (18–24 bones), so attach grip
bones must be re-verified per nation prefix before extending `ATTACH_ACTIONS`
beyond `peaukr`; cavalry riders bake without their `attach/*_horse.oss` mounts
yet (separate follow-up); the white-board lesson stands — never scale meshes
for readability, composite the donor's own prop meshes instead.

## 7. Open follow-ups

- Cavalry: combine rider `.oss` with `attach/<base>_horse.oss` the same way.
- Ships: `attach` sails/flags/paddles are separate build stages, not in-place props.
- `ukr_peasant` etc. duplicate the 8 donor bases; per-nation tool UV/texture
  differences (only `peaaustools.dds` ships) to confirm visually.
- Headless `--screenshot` currently writes nothing in this environment; visual
  in-game proof still needs a windowed capture or the `test_drive.py` bridge.

## 8. Import & bloat notes (2026-11-20)

Two project-level traps made even correct sheets look bad and huge:

- Every baked PNG was imported as **lossy VRAM (S3TC, quality 0.7)** — the
  per-file default (`compress/mode=2`, `vram_texture`). At 160 px cells that
  smears 30 px figures into mush, which is why the game looked worse than the
  PNGs. Fix: all `anim/*.png.import` set to `compress/mode=0` (lossless;
  ~173 KB `.ctex` per sheet instead of 2.4 MB S3TC), orphan `*.s3tc.ctex`
  files (~385 MB) deleted from `.godot/imported`.
- The baker's scratch dir (`anim/tmp/`: converted donor textures, per-cell
  renders — **833 MB**) lived inside `res://`, so Godot imported all of it.
  Fix: scratch moved to the system temp dir (`bake_sprites.py` `main()`),
  `anim/tmp/` deleted. Re-bakes reconvert donor textures on demand (seconds).

Sheet total is ~280 MB PNG (vs donor units ~212 MB meshes+textures) — inherent
to 8-dir × ~10-frame RGBA sprites; figures lazy-load per drawn unit.

## 9. Facing mirror (2026-11-20)

Compass check (`peasant_walk` dirs 0/2/4/6 + `pikeman_attack` pike direction,
plus a skin-pixel front/back recount that overturned the first reading)
proved the bake runs 180° off the game's facing angle: game dir 0
(eastward move) must pick the east-facing cell (col 4), not col 0. The first
attempt mirrored (`posmod(4 - d)`, fixing E/W but flipping N/S. Correct map
is a half-turn: `world.gd` `_draw_anim` and the corpse preview now use
`dir = posmod(dir + 4, 8)`. Verified at file level (pike thrust matches
movement compass); sim self-test still green.
