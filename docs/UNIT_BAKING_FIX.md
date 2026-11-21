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

## 10. L7 isolation audit (agentC, 2026-11-21)

`peasant_walk.png`: 1280x1920 RGBA = 8 cols (dirs) x **12 rows** at cell 160.
All 12 row strips have distinct hashes and every row differs from its
predecessor in 8/8 columns — `sample()` did NOT collapse to `[a,a,...]`.
Bake (suspect A) is FINE; no rebake proposed. Note 12 rows is above the
guide's eyeball expectation N=6..10 (donor `walk 1..20` sampled to 12).

`index.json -> peasant.actions.walk`: frames **12**, duration **0.667**,
loop **true**, ortho 5.465, centre [0,0,1.101], ax 0.5, ay 0.8037,
bbox [61,56,99,115], fig_h **0.3688**, foot **0.7188**, cx **0.5**.
Re-measuring the PNG cell-locally gives bbox [61,56,98,115],
fig_h 0.3688, foot 0.7188, cx 0.4969 — i.e. metrics (suspect B) DID run
and match the pixels (fig_h is not the 1.0 default, foot is not 0.82).
`sheet_metrics.py` loops `for act, ad in info["actions"]` and opens
`<key>_<action>.png` (per-action sheets, not a montage) — correct as-is.
No files changed; no Godot run needed.

Read-only code audit (GUIDE4 L7 truth table vs current code) — all deltas
below are in `world.gd` (another worker owns it) and match this doc's
§4/§9 fixes, so the GUIDE4 truth table is the stale artefact, not the code:
- L314 dir adds `+4` half-turn; guide L838/L902 expects no offset (§9 mirror).
- L324-331 anchors with ax/ay and scales with shared ortho; guide L839-840
  uses fig_h/foot/cx (§3 Bug 3).
- L309/L313 add a per-entity `phase` to the walk frame clock; guide L836
  uses bare `anim_t`.
- L246-253 stationary gather/build returns dedicated workwood/workfood/
  workstone/construct; guide L882-883 expects the `attack` sheet (§4).
- `game.gd` agrees with the guide: single `fire_t` assignment at L3157 in
  `_fire` after all gates; face at L2854 (attack), L3391 (gather),
  L3013 (build), L2756 (move). No duplicate artillery fire_t block.
Open question for the owning worker: the reported "skate/attack=walk"
symptom is not reproducible from A or B here; it must be a C-side selection
or a frame/duration stride mismatch (12f at 0.667s = 0.083 m/frame at
1.5 m/s, below the guide's ~0.13 m foot-length stride).
- FIX (agentC2): set `peasant.actions.walk.duration` 0.667 -> **1.08** (GUIDE4 DO-L7.06 `n*0.09`); stride = 1.5 m/s * 1.08 s / 12 = **0.135 m/frame** (~foot length). Only that JSON scalar changed; frames/loop/ortho/center/ax/ay/bbox/fig_h/foot/cx and all other unit keys untouched.

## 11. Roster-wide metric audit (agentSE, 2026-11-21, ticket P-26)

Audited all **54 keys / 299 actions** of `app/assets/models/anim/index.json` against
GUIDE4 DO-L7.02 (`GUIDE4.md` L850-857) and the DO-L7.06 stride rule (`duration ≈
frames*0.09` walk, `frames*0.12` attack, 1.2 s death). Pure-Python read/audit; **no
PNG rebake** (Blender CPU Cycles too slow) and no `.gd` edits.

### 11.1 Outlier table (pre-fix counts)

| Flag | Count | Disposition |
|---|---|---|
| `fig_h = 1.0` default (G1 "tiny men", D23) | **0** | Metrics ran on all 299 actions — D23 closed for the roster. |
| Missing `bbox/fig_h/foot/cx` | **0** | All 299 actions carry all four fields. |
| `cx` outside 0.40..0.60 | **0** | Every cx is 0.5 / 0.4969 / 0.5031. |
| `foot` outside 0.70..0.90 | **68** | Measured values 0.6813..0.95, **not** the 0.82 default; `world.gd:324` anchors with `ay` first (§3 Bug 3) so foot is only a fallback — left unchanged. |
| Walk `frames` outside 6..10 | **54** | All are 12 (donor `walk 1..20` sampled to 12); agentC §10 confirmed the bake — left unchanged. |
| Walk duration hyper-flap vs `n*0.09` | **12** | 8 national-peasant walks (0.667) + hussar/wingedhussar 0.533, hackapell/croat 0.567; see 11.2. |
| Walk duration too slow | **5** | cossack 1.6; cannon/howitzer/mortar/multicannon 3.3 (DO-L7.08 allows longer for slow artillery — left unchanged). |
| Attack duration below `n*0.12` | **50** | Systemic across every family (0.2..1.03 s vs `12*0.12=1.44`); out of scope for a small fix, see 11.4. |

### 11.2 Fix applied (8 scalar values, minimal diff)

Same defect as agentC2's base `peasant` fix: the 8 national-peasant variants still
had `duration = 0.667` on their `walk` action (12 frames → DO-L7.02 band
`1.08 ±30% = 0.756..1.404`; 0.667 is below it; stride `1.5*0.667/12 = 0.083 m`
per frame = foot slide). Changed **only** `actions.walk.duration` 0.667 → **1.08** on
`ukr_`, `rus_`, `pol_`, `aus_`, `eng_`, `spa_`, `tur_`, `sco_peasant`. Verified against
the pre-edit backup: exactly 8 changed lines, no other field or key touched, CRLF
preserved, JSON parses, 54 keys intact. (A 9th `0.667 → 1.08` in `git diff` vs HEAD is
agentC2's still-uncommitted base-`peasant` fix, not this ticket.)

### 11.3 Naval `index.json` schema verdict (read-only)

`app/assets/models/anim/naval/index.json` has **one key, `yacht`**, with unit-level
fields `{cell, actions}` — identical to main. Action-level fields are a strict
**subset** of main: `{frames, duration, loop, ortho, center, ax, ay, tool}`;
missing `bbox, fig_h, foot, cx`. Types of shared fields match exactly (int/float/
bool/list/null). Integration needs for the coordinator (game code owned by A,
naval assets by AC — **not edited here**):

1. `_anim_dir()` (`world.gd:264-271`) only resolves `res://assets/models/anim` (or
   `anim%d`); it never looks in `anim/naval/`. Sheets/keys must be merged into the
   main folder+index, or the resolver taught the subdir.
2. `world.gd:323` does `fig_h = a.get("fig_h", 1.0)` with no `ax/ay` equivalent —
   naval actions have no `fig_h`, so sailing sprites would hit the G1 default-1.0
   whole-cell scale (tiny men). Add the four metrics fields (sheet_metrics.py) or
   a naval-specific fallback. (`ay/ax` at 324-325 do have fallbacks and are set.)
3. `yacht.walk.duration = 9.333` for 12 frames (vs land `n*0.09 = 1.08`) and
   `yacht.hull` is 1 frame / `0.0` s static. Not a land-stride case; confirm the
   slow sail is intentional and that `hull` is never played as a looping action.

### 11.4 Open questions

- The 9 remaining walk outliers: are hussar/wingedhussar 0.533 and
  hackapell/croat 0.567 intentional gallops (DO-L7.08 suggests `n*0.07 = 0.84`,
  not `n*0.09`)? cossack 1.6 and artillery 3.3 may be intentional per DO-L7.08.
  Need a visual frame/stride check before touching these families.
- The 50 systemic short attack durations: DO-L7.06's `n*0.12` may not model a
  one-shot `fire_t` swing; changing all 50 would be a broad diff, so deferred to
  a dedicated animation-timing ticket with frame-level acceptance.
- The 68 `foot` outliers are real measurements; if visually wrong, re-run
  `sheet_metrics.py` rather than hand-editing numbers.

Verification: runner ticket `79 agentSE-selftest` (waited 139.6 s, ran 41.4 s),
`app/selftest.json` `passed: true`, **29/29 steps** (no failures). No PNG rebake,
no `.gd` edits. Backups: `inbox/backup/index.json.bak-agentSE`,
`inbox/backup/UNIT_BAKING_FIX.md.bak-agentSE`.

## 12. Scottish sheets + naval metric gap (IMPL-ASSETS, 2026-11-21; P-41 / P-45)

Quality-first: every number below was measured from the produced PNGs or read
from the donor install **read-only**; no donor file was copied into `res://`,
no `.gd` file was edited, and no bulk JSON change was made to satisfy a test.
Scratch (`cossacks_scottish_*` / `cossacks_naval_*`) lived in `%TEMP%`.

### 12.1 Donor evidence (observed, read-only)

`buildings.json` genuinely had **zero** `sco_*` keys (1506 keys / 20 prefixes)
— A-01's "14 already baked" claim was wrong. The donor does ship complete
Scottish building geometry and materials:

| Port key | Donor mesh (under `data\actors\buildings\sco\`) | Donor texture |
|---|---|---|
| `sco_cen` | `scocen.osm` (also `scocen1..4`, `scocen_death1/2`) | `data\materials\buildings\sco\scocen.dds` |
| `sco_hou` | `scohou.osm` (+ stages, rubble) | `...\scohou.dds` |
| `sco_bar` | `scobar.osm` (+ stages, rubble) | `...\scobar.dds` |

Scottish units are also present: `data\actors\units\swordsmansco.oss` (k=198,
fps=30, 22 bones, 786 verts, 1181 faces, 965 UVs; 177,064 B),
`data\animations\aaf\swordsmansco.aaf` (`walk 1..24`, `idle 28..77`,
`death 80..127`, `attack0 185..197`) and
`data\materials\units\swordsmansco.dds`. `highlander.oss` already feeds the
54-key main index, so this bake uses the Scotland-unique `swordsmansco` under
a new key to avoid a collision.

### 12.2 Real bake (not fabricated)

New tool `app/tools/bake_scottish.py` — thin wrapper over the portable
`bake_sprites.py` primitives (`bake_building`, `bake_unit`), Blender 5.2.3 LTS,
**CPU Cycles, 4 samples**, exit 0 in ~37 s:

```
blender --background --factory-startup --python app/tools/bake_scottish.py -- \
    --game "C:\Games\Cossacks 3" --anim app/assets/models/anim \
    --size 160 --samples 4 --engine cycles
```

Produced (all PNGs have ≥47 % ink on the finished building sheets and 12/12,
6/6, 12/12, 8/8 distinct frames per unit action; visually confirmed as a
stone Scottish town hall and a tartan swordsman with sword + targe):

| Sheets | Dimensions | Count |
|---|---|---|
| `sco_cen.png`, `sco_cen_s1..s4.png`, `sco_cen_dead.png` | 320×320 | 6 |
| `sco_hou.png`, `sco_hou_s1..s4.png`, `sco_hou_dead.png` | 320×320 | 6 |
| `sco_bar.png`, `sco_bar_s1..s4.png`, `sco_bar_dead.png` | 320×320 | 6 |
| `sco_highlandersword_{walk,attack}.png` | 1280×1920 | 2 |
| `sco_highlandersword_idle.png` | 1280×960 | 1 |
| `sco_highlandersword_death.png` | 1280×1280 | 1 |

Donor `.osm` bounds → ortho: cen 11.861 (10.34×10.59×9.15 m), hou 5.824
(5.20×4.91×4.70 m), bar 9.055 (8.09×7.81×6.75 m).

JSON added:
- `buildings.json`: **18** `sco_*` rows (1506→1524), same 5-field schema
  `{ortho, cell, ink, cx, rm}`; all 1506 pre-existing rows byte-identical,
  CRLF preserved. `sco_bar` ink touches y=0 — a minor top-edge clip shared
  with `fra_bar`; left as-is because the shared baker's framing was not
  changed (no guessed adjustment).
- New scoped `sco_units.json`: `{"sco_highlandersword": {cell:160,
  actions:{walk,idle,attack,death}}}` with the full 12-field action schema.
  **Integration note for IMPL-SIM:** load this as a *separate* index (mirroring
  `NAVAL_PORT_PLAN.md` §4); do **not** merge into `anim/index.json` —
  `t_anim_metrics` asserts exactly 54 keys. Sheets resolve as
  `res://assets/models/anim/sco_highlandersword_<action>.png`, same 8-dir /
  `+4` facing and `ax/ay` anchoring as other units. Its donor walk is
  `1..24 / 30 fps = 0.8 s` over 12 sampled frames; the port convention for
  other 12-frame walks is 1.08 s — choose one when wiring, do not guess here.
- 22 lossless `.import` sidecars (`compress/mode=0`) were added for the new
  sheets: every other anim PNG has one, and Godot's default would otherwise
  import them as lossy S3TC (§8 trap).

### 12.3 Naval metric gap (P-45, scoped to `naval/index.json`)

`t_anim_metrics` reported `yacht/walk` and `yacht/hull` missing
`bbox/fig_h/foot/cx`, with `hull.duration = 0.0`. Measured the final PNGs with
Pillow (`alpha > 8`, union of cell-local bboxes over all 8 dirs × frames);
the method was validated against `NAVAL_PORT_PLAN.md`'s whole-sheet bboxes
(walk (9,32)–(1217,1882), hull (23,33)–(1242,152)) and reproduced them exactly.

| action | bbox (cell-local) | fig_h | foot | cx |
|---|---|---|---|---|
| `yacht/walk` | [9,31,151,149] | 0.7375 | 0.9313 | 0.5 |
| `yacht/hull` | [23,33,137,152] | 0.7438 | 0.95 | 0.5 |

Added those four fields to both actions; `hull.duration` 0.0→**1.0** (frames
still 1). Fixed the root cause in `bake_naval.py` too: `bake_naval_hull()` now
emits 1.0, and `main()` measures every action sheet before writing
`index.json`, so a re-bake cannot drop the four fields again. `naval/index.json`
still has one key (`yacht`) and the same PNGs. `ax/ay` remain authoritative in
`world.gd`; the measured `foot` values exceed the land-only 0.90 test band but
the test only range-checks the main roster, and these are real measurements.

### 12.4 Verification and open items

- Pure-Python gate (temp, not in repo): **ALL PASS** — naval stored metrics
  equal re-measured pixels; main index still 54 keys; buildings old rows
  unchanged; every new sheet exists with matching ink bbox; no raw donor
  formats under owned `anim/` paths.
- `python app\tools\test_all.py --only t_anim_metrics t_naval` → **`no tests
  selected`, exit 1** — both ids are `pending` in `app/tests/manifest.json`,
  so the exact command selects nothing. With `--include-pending`:
  **`t_naval` PASS** (38.4 s, all 6 checks, including `naval_schema` deviations
  = 0); **`t_anim_metrics` FAIL** (269.04 s) on three *pre-existing* checks —
  `action_structure` (4 single-frame siege idles), `metric_ranges` (68 land
  feet), `walk_stride` (45 land walks). `main_index_54_units` and
  `naval_schema` both PASS. These belong to the separate P-45 adjudication;
  no bulk fix was attempted.
- Backups: `inbox/backup/bake_naval.py.bak-IMPL-ASSETS`,
  `naval_index.json.bak-IMPL-ASSETS`, `buildings.json.bak-IMPL-ASSETS`,
  `UNIT_BAKING_FIX.md.bak-IMPL-ASSETS`.
- Open: (a) naval `.import` sidecars were created by another worker during the
  test run (`git status` shows `naval/yacht_*.png.import`); this worker did not
  touch them — check their `compress/mode` in QA; (b) `sco_bar` top-edge clip;
  (c) `sco_highlandersword` walk duration convention; (d) the 14 other
  Scottish buildings/units were not baked (small, real set only).
