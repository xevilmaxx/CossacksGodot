# Original files used in this build

All copied from the installed game at `C:\Games\Cossacks 3` by
`tools/copy_assets.py` (which lists every path). For the private use of the
person who owns the game, on their own computer. Must not be shared.

## Terrain textures (converted DDS → PNG)
- data/terrain/tiles/textures/grass1..5.dds → assets/terrain/grass1..5.png
  (in this build; copy_assets.py lists the full set grass1..10,
  grass_ground1..3, grass_sand1..2, rock1..9, sandrock1..3 for re-copying
  with Pillow: python tools/copy_assets.py --game PATH_TO_GAME)
- data/terrain/tiles/textures/ground1.dds → assets/terrain/dirt1.png
- data/terrain/tiles/textures/grass_rock1.dds → assets/terrain/rockgrass1.png

## Building ground decals (original dirt plates, kept as reference)
- data/terrain/decals/buildings/ukrcend.dds, ukrhoud.dds, ukrbard.dds,
  ukrstad.dds, ruscend.dds, eurgold.dds → assets/terrain/decals/*.dds
  (the game draws its own dirt ellipse in the same role/size; the DDS files
  stay in the folder as the original reference. Full list for re-copying in
  tools/copy_assets.py: ukr/rus shared + eur mines + bldsiz/helper.)

## UI (used directly, cropped by region like the original hud.mat does)
- data/hud/textures/ui/icons.bmp — building icons, resource icons, weapon icons
- data/hud/textures/ui/iconsunits.bmp — unit portraits (regions from data/hud/hud.mat)
- data/cursors/textures/bmp/*.bmp — 11 mouse cursors

## Sounds (OGG, used directly, 305 files)
- data/sounds/units/*.ogg — every unit sound (musket1..14, sabre, arrow,
  cannon, deaths, walking per type walkinfcloth/walkinfmetal/walkcavfast/,
  work sounds workwood/workstone/workconstruct, selection/selectpeasant…,
  shots shotcannon/shotmortar/shothowitzer/shotship…)
- data/sounds/interface/*.ogg — alarm, btnclick, construct and the rest
- data/sounds/ambient: ukr, rus, amb_atmosphere, amb_wind, amb_sea,
  amb_towneur, amb_windmill (music + ambience, played by audio.gd)

## Menu/shell sources (read, not copied)
- data/game/var/campaigns.cfg + battles.cfg -> assets/missions.json (tools/build_missions.py)
- data/game/var/generator.cfg TerrainTypes -> map types; startingsettings.cfg comments -> start options
- data/scripts/lib/country.script nation sids, squad.script officer/drummer slots,
  group.script grid math, formations.cfg masks, wallcustom.cfg BuilderPoints

## Gameplay numbers (read, not copied)
- data/scripts/dmscript.global, data/scripts/lib/unit.script, weapon.script,
  miscext2.script, player.script, data/game/var/hotkeys.cfg,
  data/cameras/camera.cfg, data/gui/menu.inc/* — every constant cited in
  MECHANICS.md

# Placeholders (recreated, not copied) + what was tried for maps/models

- Unit and building on-map visuals: top-down RTS shapes in player colours
  (walls/roofs/trim, mines with timber frames) with the original
  portraits/icons in the UI. The original's 3D meshes CAN be read here:
  `tools/convert_models.py` converts all 29 needed meshes (.oss units,
  .osm buildings/props) to `assets/models/obj/*.obj` + `tex/*.png`
  (see `assets/models/manifest.json` with vertex/face counts and bounds).
  Baked sprites (`tools/render_models.py` + Blender, EEVEE, shadeless):
  `assets/models/sprites/*.png` — 92 files, 8 directions x 9 units + 21
  single views (buildings face south). Unit/building textures are flattened
  to RGB on convert (`tools/convert_models.py`) because their DDS alpha
  channel is garbage (Blender would render them invisible otherwise).
- Animated sheets (`tools/bake_sprites.py` + Blender CPU-only Cycles,
  identical shadeless look, zero GPU load): the .oss bone-delta animation is
  skinned on CPU, actions come from `data/animations/aaf/*.aaf` frame ranges
  (paired via `data/actors/units/*.actor`), baked to
  `assets/models/anim/<sid>_<walk|idle|attack|death>.png` (8 dirs x sampled
  frames) + `index.json`. 54/54 unit sheets baked; 215 nation building sheets
  (`<nat>_<bld>.png` + `s1..s4` stages + `_dead`) bake with `--buildings`,
  incl. `<nat>ba2.osm` (Barracks 18c) + `<nat>dip.osm` (Diplomatic Center).
  Stage/rubble meshes have different topology than the finished mesh, so each
  stage is rebuilt as its own Blender object for its render.
- Trees (oak/pine), rocks, corn fields, hills, lakes, sand shores and dirt
  roads: drawn shapes in the original palette roles, clustered like the
  original patterns (data/pattern/*.pattern).
- Map layout: a new generated map in the original's style (open plains +
  forest belts + hills + lakes + farm fields). The original's .map files
  (data/maps/missions/*.map, 30-100 MB binary each, e.g. ausmis1.map,
  ukrmis1.map, battle1..8.map) are a closed binary format
  (`OSWMap13.Map.Ver[0.0]Build.Ver[2.0.0.2843]Core.Ver[1]`, UID + snapshot
  markers + opaque terrain/resource blocks). `tools/extract_map.py` reads
  what is readable — header, section-marker offsets and every placed-object
  name (e.g. auscen, rusbar.pikemanrus.1.1, ukrwwa.1; ~18k placements in
  ausmis1.map) — into `assets/maps/*.json` (+ `_summary.json`). The heightmap
  / tile grid itself has no public spec and cannot be loaded directly, so the
  port mimics the missions (nations, building/unit mix, symmetric starts)
  on its own procedural terrain instead.
- Computer-opponent behaviour: an approximation (original AI is compiled
  .aix data).
- All files above live in the same folder (app/assets/ + config.json), so
  the project runs from one folder on Windows, Linux and macOS.
\
## GUIDE3 newly used donor files
- data/cursors/textures/bmp/*.bmp + cur/*.cur (context + edge cursors)
- data/game/var/hotkeys.cfg (hotkey fidelity)
- data/gui/menu.inc/doupdatecursor.inc (cursor rules)
- data/gui/minimap.cfg (240px bottom-left, frustum)
\

See ../docs/WAIVERS.md for the two donor-asset waivers and the private-use compliance statement.

## C01-ASSET — additive derived nation art + relief props (derived, not copied)
Offline run: `tools/convert_models.py --nation-art --include-relief --manifest-name manifest_addendum.json`,
then `tools/convert_skins.py --index-name index_nation.json`. The addendum entries
were text-inserted into `assets/models/manifest.json` and `assets/models/skin/index.json`;
all 280 pre-existing manifest entries and all pre-existing asset bytes were left untouched.
- `data/actors/buildings/{rus,bav,pol,swe}/<nat>cen.osm` + matching
  `data/materials/buildings/<nat>/<nat>cen.dds` -> `assets/models/obj/<nat>cen.obj`
  (+ `.mtl`) and `assets/models/tex/<nat>cen.png` (first IDP2 frame -> OBJ; DDS -> PNG,
  garbage alpha dropped because `kind="building"`). `ruscen` is the distinct Russian hall
  (15,348 verts / 9,936 faces vs the Ukrainian-derived `cen.obj` 5,611 / 3,714).
- `data/actors/units/pea{rus,ukr,pol,aus,eng,spa,tur,sco}.oss` with the matching
  `data/materials/units/pea*.dds` -> `obj/pea*.obj` + `tex/pea*.png`; each nation's own
  `data/animations/aaf/pea*.aaf` -> flat-root skin JSON under `assets/models/skin/`
  via `tools/convert_skins.py` (per-nation ranges, e.g. `pearus k=486`).
- N07 T0 signature units `data/actors/units/{pikemanrus,musketeer18bav,pikeman18swe}.oss`
  (+ matching `.dds` and `.aaf`) -> `obj/*.obj`, `tex/*.png` and `skin/*.json`.
- `data/actors/env/terrainmesh{1,2,3,4}.osm` + `data/materials/env/terrainmesh{1,2,3,4}.dds` ->
  `assets/models/obj/terrainmeshN.obj` (+ `.mtl`) and `tex/terrainmeshN.png`
  (2048x2048 RGBA, donor alpha preserved: `kind="relief"` -> `force_opaque=False`).
  Placement truth was READ, not copied: `data/objects/env/terrainmeshN.prop`,
  `data/actors/env/terrainmeshN.actor`, `data/actors/actors.lib:1200-1213`,
  `data/pattern/pattern.lib` (112 `BaseName=terrainmeshN` records with per-object
  Scaling/Position/Direction), `data/scripts/common.inc/dogenerate.inc:1984-1985`.
  The OBJ keeps RAW donor units; authored per-object Scaling (0.3539-0.6562) is
  placement data for a later instancing consumer, never baked into the mesh.
- All files above are DERIVED OUTPUTS (vertex/UV/face lists and converted pixels, with
  donor citations in `assets/models/manifest.json`), NOT verbatim donor files. Donor
  `.osm/.oss/.dds/.aaf` binaries stay in the private install, are read only as bytes/text,
  and are never copied into the repo or executed. For private use of the game owner on
  their own machine only; never share, publish or redistribute (`README.md:220-224`,
  `app/CREDITS.md:1-5`, `docs/WAIVERS.md` compliance statement).
- Geometry is a STATIC bind pose / flat-root morph PORT APPROXIMATION (donor bone parent
  hierarchy unreadable). Winter `terrainmeshNw.dds`, desert `terrainmeshdesertN.dds` and
  `terrainplateau1..4.osm` are NOT converted. Visual donor parity is UNVERIFIED — no
  donor GPU A/B frame exists; adding these assets alone does not make hills visible.

## V49-TERRAIN-NEW — donor-derived pattern / cfg assets (2026-11-26, derived, not copied)

Offline readers (read-only donor; dry-run by default, explicit write required):
`python variant3d/tools/decode_donor_cfg.py --game "C:\Games\Cossacks 3" --out variant3d/assets/terrain_new/cfg`,
`python variant3d/tools/decode_pattern_lib.py --game "C:\Games\Cossacks 3" --write --out variant3d/assets/terrain_new/patterns`,
`python variant3d/tools/decode_donor_pattern.py --game "C:\Games\Cossacks 3" --no-dry-run --out variant3d/assets/terrain_new/patterns`.

Donor files READ (never copied, executed or committed):
`data/gen/{globalparams,localparams,mapcover,tilesmooth,tilesmooth_scripts}.cfg`,
`data/game/var/{generator,startingsettings}.cfg`,
`data/pattern/pattern.lib` (30,309,138 B, sha256 `f7b421b179dee5ad2b28e025c6b776d8eeccfbec74a93a13c3d1c9d9f10dc1c0`),
and 710 `data/pattern/*.pattern` binaries — per-file `source_sha256` values are recorded in
`variant3d/assets/terrain_new/patterns/pattern_decode_manifest.json` (`output_count: 710`,
`determinism_second_pass_equal: true`).

Written DERIVED outputs (labelled, not donor bytes):
`variant3d/assets/terrain_new/cfg/{constants.json,config_strings.json,manifest.json}` and
`variant3d/assets/terrain_new/patterns/*.json` (710 decoded pattern records,
`patterns/families/*.json` 64 family files, `family_index.json`,
`blend_test_vectors.json`, `pattern_decode_manifest.json`). Values are decoded numbers,
strings, labels and sha256 checksums; undecodable fields stay `null` + `UNVERIFIED`;
every emitted JSON carries `visual_parity_claim:false`. No TGA/DDS/OSM/OSS/.pattern/.map
or donor executable was written. `decode_donor_masks.py` and `build_terrain_new_atlas.py`
were not run in write mode: `terrain_new/{atlas,masks,schemas}` do not exist.

For private use of the game owner on their own machine only; never share, publish,
upload or redistribute. PORT APPROXIMATION — visual donor parity is UNVERIFIED; no
donor GPU A/B frame exists. Before any commit, replace the absolute donor install
path embedded in the current JSON outputs with `$COSSACKS3_DIR` / `source_rel`
(spec/11 §11.1; X15 §2.1).
