---
id: V08
ticket: "WAVE V / V08 — donor↔port coordinate and unit contract (resolution before fresh module)"
agent: "V08 (read-only subagent, DONOR-FIRST terrain swarm 2026-11-26)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB__NO_GODOT_JOB
scope: "This report is the ONLY repo file written. No source/shader/config/asset/test/fixture/JSON/PNG/donor/queue/git edit; no Godot process, no runner job, no donor executable run, no donor binary copied."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
owner_file: docs/terrain_swarm_2026-11-26/reports/V08_coordinate_scale.md
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION"]
parity_claim: false
parity_guard: "No donor GPU A/B frame exists (CHARTER §3/§5). Every donor statement here is a read-only text/constant/byte observation or a deterministic consequence of cited text. All port representation choices are PORT APPROXIMATION. NO DONOR PARITY CLAIM."
sources_read:
  - docs/terrain_swarm_2026-11-26/CHARTER.md
  - docs/terrain_swarm_2026-11-26/SWARM_BOARD.md
  - docs/terrain_swarm_2026-11-26/spec/01_WORLD_DATA_MODEL.md
  - docs/terrain_swarm_2026-11-26/spec/10_STAGE_ORDER.md
  - docs/terrain_swarm_2026-11-26/reports/A01_data_model.md
  - docs/research/RC_TERRAIN.md
  - docs/terrain_swarm_2026-11-25/reports/G09_footprint.md
  - "DONOR (read-only text): data/scripts/dmscript.global, data/scripts/lib/misc.script, data/scripts/lib/miscext2.script, data/scripts/common.inc/generatemap.inc, data/scripts/common.inc/texturemap.inc, data/scripts/common.inc/dogenerate.inc"
  - "PORT (read-only): variant3d/scripts/{game,data,pattern_gen,world3d_relief,world3d_terrain,world3d_fx,config,main}.gd, variant3d/tools/donor_gen.py, variant3d/tests/fixtures/small_map_64.json, app/shots/g32_dump.json"
  - "Prior art cross-checks: docs/decomp/DB_SCRIPTS.md:67, docs/audit/GEN.md:199-203,398-409, docs/audit/TERRAIN_DONOR_PATTERNS.md:278-280, docs/coord_swarm_2026-11-25/reports/DTRN_02_donor_terrain_geometry.md:268-285, DTRN_05_donor_mines.md:80, docs/coord_swarm_2026-11-24/reports/G32_heightmap_world.md:117-123,137-139"
---

# V08 — donor↔port coordinate / unit contract

## 0. Executive summary

1. **[O] Donor grid side is a real map-cell count `W = GetMapWidth()`**, one of
   **256 / 320 / 480 / 640** (`data/scripts/lib/miscext2.script:19-26`;
   `data/scripts/dmscript.global:132-135`), with a hard cap of 640
   (`dmscript.global:78-81,132-135`). The port's `MAP_W=MAP_H=160`
   (`variant3d/scripts/game.gd:35-36`, `data.gd:33-34`), its config default 240
   (`config.gd:119-121`) and the 64² test fixture
   (`variant3d/tests/fixtures/small_map_64.json:1-17`) are **PORT
   APPROXIMATION / test-only aliases**, not donor sizes. 320² is the only size
   that is both a donor setting (`miscext2.script:20`) and an actual port dump
   (`app/shots/g32_dump.json` `map_w=map_h=320`).
2. **[D] Definitive cells-per-unit relation: 1 donor generator distance unit =
   1 map cell.** The donor adds `dst` directly to start positions expressed in
   `±GetMapWidth div 2` cells (`dogenerate.inc:402-405,435-438,521,559-655,658-709,1599-1602`),
   indexes `gPatternMask[floor(x+W/2)]` with those coordinates
   (`misc.script:3384-3405`; `dogenerate.inc:373`), and uses a strict 25-**cell**
   pattern grid (`dogenerate.inc:1335-1345`). **No donor text defines a
   2-cells-per-unit generator scale.**
3. **[D] `DONOR_UNITS = 160` in `variant3d/tools/donor_gen.py:59` and
   `variant3d/scripts/pattern_gen.gd:9` is PORT-INVENTED**, not donor-grounded.
   Its `s = W / 160` (`donor_gen.py:147-158,193`; `pattern_gen.gd:92`) doubles
   every donor-supplied cell distance and footprint at W=320 and multiplies it
   by 1.5 at the port's 240² default. The claim "1 unit = 2 cells" descends from
   `docs/decomp/DB_SCRIPTS.md:67` (quotes numbers only) →
   `docs/research/RC_TERRAIN.md:90` (calls them "donor units") →
   `docs/audit/GEN.md:199-203` → the two port constants. The donor arithmetic in
   §3/C1 refutes it.
4. **[O]+[D] A donor metre IS defined:** `gc_pixels_to_meter = 26.6666666`,
   `gc_meters_to_tile = 2`, `gc_pixels_to_tile = 53.3333333`,
   `gc_tiles_to_pixels = 0.01875` (`dmscript.global:170-173`). Read in the same
   direction as the other three constants, `gc_meters_to_tile=2` means **2
   metres per map tile/cell**, so `TILE_M=2.0` (`world3d_terrain.gd:130`,
   `data.gd:23`, `game.gd:16`) is donor-grounded for *horizontal* cell size.
   The port already encodes the same conversion (`data.gd:15-17`). What stays
   **[U]** is whether the stored `height` float is in those metres
   (`HEIGHT_SCALE=1.0`, `world3d_terrain.gd:131`) — no donor line assigns a unit
   to `TMapTerrainDataTile.height` (`dmscript.global:2026-2030`).
5. **[O] Origin, cell centres and the 2× collision grid are confirmed:** origin
   `−W/2, −H/2` cells (`misc.script:68-72`), object placed at cell centre
   `px+0.5` (`miscext2.script:945-958`), collision drawn at integer and ±0.5
   cell offsets (`texturemap.inc:56-129`), loop over `GetMapWidth*2`
   (`texturemap.inc:133-159`) with sub-cell step 0.5 (`dmscript.global:178`) and
   cap `2*640` (`dmscript.global:134-135`). `collision = Integer[4]` per height
   cell (`dmscript.global:80,2026-2029`) is the same 2×2 sub-cell information,
   not a competing layout. **[U]** engine-side consumption/indexing.
6. **[U] Row sign remains UNVERIFIED** (prior register `game.gd:98`,
   `Z04_height_only_design.md:98,454`); donor `generatemap.inc:537-547` maps
   bitmap row `y` to map coordinate `ty+y`, but the engine-Z ↔ file-row sign is
   not pinned by any read text. **[O] footprint unit** is 0.5 map cell per
   `.prop` collision-mask cell (`F02_almanac_building_ghost.md:151-164` +
   `dmscript.global:178`), but **no `.prop` mask data exists in this repo**
   (`G09_footprint.md:36-52`), so all port building/prop footprints are
   **PORT APPROXIMATION**.
7. **Fresh-module verdict:** parameterise `W,H` per instance; use donor cell
   distances **1:1** (drop `s=W/160`); resample donor masks as the donor does
   (`generatemap.inc:537-547`); allocate to the 640 cap; keep every existing
   dump key byte-identical and add new data only under the optional `fields`
   dict. Legacy 64²/160²/240²/320² atoms keep working behind the existing
   `build()` path; no existing atom is edited or weakened.

---

## 1. Method, labels and citation shorthand

Labels: **[O]** observed literal donor/port text or byte; **[D]** deterministic
consequence of cited lines; **[I]** inference without a donor A/B frame;
**[U]** UNVERIFIED; **PORT APPROXIMATION** (port-authored representation). No
donor parity claim is made anywhere in this report.

Donor root (read-only, private use): `C:\Games\Cossacks 3`. Short forms below:

- `D:dmscript.global:N` = `C:\Games\Cossacks 3\data\scripts\dmscript.global:N`
- `D:misc.script:N` = `C:\Games\Cossacks 3\data\scripts\lib\misc.script:N`
- `D:miscext2.script:N` = `C:\Games\Cossacks 3\data\scripts\lib\miscext2.script:N`
- `D:generatemap.inc:N` = `C:\Games\Cossacks 3\data\scripts\common.inc\generatemap.inc:N`
- `D:texturemap.inc:N` = `C:\Games\Cossacks 3\data\scripts\common.inc\texturemap.inc:N`
- `D:dogenerate.inc:N` = `C:\Games\Cossacks 3\data\scripts\common.inc\dogenerate.inc:N`

Port root: `C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3`;
`P:path:N` means `variant3d/path:N` unless `app/` is written explicitly.
No donor binary was executed or copied; donor masks were only measured
(read-only header bytes, 320×320 TGA) to cross-check the mask-sampling rule.
Per CHARTER §4 ("multiple passes on anomalies"), §3 records the passes taken on
the three contradictory numbers before a verdict was accepted.

---

## 2. Evidence table

| # | Claim | Exact evidence (`path:line`) | Label |
|---:|---|---|---|
| E1 | Donor grid ∈ {320,480,640,256} by `mapsize` 0/1/2/3; default branch 320 | `D:miscext2.script:19-26` | [O] |
| E2 | Map/collision/terrain-data cap 640; collision cap 2×640 | `D:dmscript.global:78-81,132-135` | [O] |
| E3 | `TMapTerrainDataTile = {height:Float, tex:Integer, collision:Integer[4]}` on `[640][640]` | `D:dmscript.global:2026-2035` | [O] |
| E4 | Declared collision tag values 0,10,80,101,87,110,109,85,95 | `D:dmscript.global:83-92` | [O] |
| E5 | Metre/pixel/tile conversion constants | `D:dmscript.global:170-173` | [O] |
| E6 | `gc_collision_size = 0.5` (collision sub-cell = 0.5 map cell) | `D:dmscript.global:178` | [O] |
| E7 | Origin `−(W div 2), −(H div 2)` in map-cell coordinates | `D:misc.script:68-72` | [O] |
| E8 | Object placed at cell centre `px+0.5`; indexed at `px+W/2` | `D:miscext2.script:945-958,960-963` | [O] |
| E9 | Height read/written at integer cell coordinates `realx=floor(lx+x)` | `D:texturemap.inc:56-80`; `D:generatemap.inc:556-574` | [O] |
| E10 | Collision written at integer and ±0.5 offsets; 2× enumeration loop; sub-cell centre `x/2+0.25` | `D:texturemap.inc:56-129,133-159` | [O] |
| E11 | Height/water constants `2.964 / 2.964÷2.25 / −2.964 / −1.1` | `D:generatemap.inc:4-7` | [O] |
| E12 | Classify thresholds `cMaxHeight=2.96`, `cWaterHeight=−0.25`, `cWaterShoreHeight=−0.1` | `D:texturemap.inc:29-31` | [O] |
| E13 | Bitmap→map nearest sampling `bitmapx=floor((x/mapwidth)*trgwidth)` | `D:generatemap.inc:537-547` | [O] |
| E14 | Generator start/position range `±GetMapWidth div 2` cells | `D:dogenerate.inc:402-405,435-438,1599-1602` | [O] |
| E15 | Mine distance `dst` added directly to start cell coordinate | `D:dogenerate.inc:521,559-655,704-709` | [O]+[D] |
| E16 | Mine corner logic uses `±maphW±24` where `maphW=W div 2` | `D:dogenerate.inc:437,658-697` | [O] |
| E17 | Tiled patterns on strict 25-cell grid; `realx=round(x*25+12−W/2−1)` | `D:dogenerate.inc:1330-1359` | [O] |
| E18 | Pattern stamp coordinates indexed into `gPatternMask[floor(x+W/2)]` | `D:misc.script:3384-3405`; `D:dogenerate.inc:373` | [O] |
| E19 | Placement budget `needed=floor(W*H*freq)`, `trycount=floor(256*320²/(W*H))` with 0.65 factor when larger | `D:misc.script:3681-3705` | [O] |
| E20 | Relief frequency size modifier `640/((W+H)/2)` when W/H ≠ 640 | `D:dogenerate.inc:1718-1724` | [O] |
| E21 | `gPatternMask` cleared over constant `cMapSize=640` | `D:dogenerate.inc:444-451` | [O] |
| E22 | Donor tile masks are 320×320 TGA (measured header bytes) | `C:\Games\Cossacks 3\data\gen\terrainmasks\land\4pl_mask_land_0_gauss.tga:12-13` | [O] |
| E23 | Port `DONOR_UNITS=160`, comment "1 unit = 2 map cells; map=320 cells"; `s=n/DONOR_UNITS` | `P:tools/donor_gen.py:54-59,147-158,188-193`; `P:scripts/pattern_gen.gd:9,92` | [O] PORT APPROX |
| E24 | Port grid defaults/fixtures 160², 240², 64²; measured dump 320² | `P:scripts/game.gd:35-36`; `P:scripts/data.gd:33-34`; `P:scripts/config.gd:119-121`; `P:tests/fixtures/small_map_64.json:8-14`; `app/shots/g32_dump.json` keys `map_w=map_h=320` | [O] PORT APPROX |
| E25 | Port flat index, centre vertices, inverse | `P:scripts/game.gd:520-521`; `P:scripts/world3d_terrain.gd:1300-1314,1718-1726` | [O] PORT APPROX |
| E26 | Port `TILE_M=2.0`, `HEIGHT_SCALE=1.0`, plus port's own metre conversion comment | `P:scripts/world3d_terrain.gd:130-132`; `P:scripts/data.gd:15-23` | [O] / [U] for height unit |
| E27 | Port dump schema base64 f32 + u8, additive opt-in keys | `P:scripts/world3d_terrain.gd:926-963,1225-1250` | [O] |
| E28 | No `.prop` collision-mask data in repo; port footprints sprite/radius based | `docs/terrain_swarm_2026-11-25/reports/G09_footprint.md:36-52,54-65,81-87`; `P:scripts/game.gd:1868,4212-4249`; `P:scripts/world3d_fx.gd:582-600,1555-1560` | [O] PORT APPROX |
| E29 | Prior reporting calls mine radii "donor units" ×2 cells/unit | `docs/research/RC_TERRAIN.md:90`; `docs/decomp/DB_SCRIPTS.md:67`; `docs/audit/GEN.md:199-203,405-409`; `docs/coord_swarm_2026-11-25/reports/DTRN_05_donor_mines.md:80` | [I] contradicted — see §3 |
| E30 | Prior report says mine bands are in map cells | `docs/coord_swarm_2026-11-25/reports/DTRN_05_donor_mines.md:80` | [D] retained |

---

## 3. Multi-pass resolution of contradictory numbers (CHARTER §4)

### C1 — Are `14+RandomExt*8` etc. "donor units" (2 cells each) or map cells?

| Pass | Instrument | Result |
|---:|---|---|
| 1 | Prior art: `DB_SCRIPTS.md:67` quotes the numbers; `RC_TERRAIN.md:90` labels them "donor units" and adds ×2; `GEN.md:199-203` adopts 320 cells = 160 units. | Competing claims. `DTRN_05_donor_mines.md:80` calls the same bands **map cells** and derives 28–44 m. |
| 2 | Re-read `D:dogenerate.inc:402-405,435-438,521,559-655,658-709,1599-1602` in full. | `x0/y0 = ±(W div 2)`; `startx` bounds checked against exactly that; `arrStartPos = startx`; `px = dst` rotated and added as `round(newpointx+px)`; corner case `±maphW±24` with `maphW = W div 2`. **One coordinate space throughout: map cells.** Mixing cell-based `maphW` with 2-cell "units" inside one addition would be an engine bug; no donor comment hints at it. |
| 3 | Independent instruments: `D:misc.script:3384-3405` stamps into `gPatternMask[floor(x+W/2)]` (cell grid); `D:dogenerate.inc:1335-1345` places tiles on a 25-**cell** grid; `D:texturemap.inc:56-62,133-137` indexes height by integer cells and collision by half-cells; `D:miscext2.script:954-958` places a building at cell centre `px+0.5`. | All confirm the generator/object/pattern coordinate unit is the **map cell**. `D:misc.script:3686-3704` and `D:dogenerate.inc:1718-1724` show the donor scales *counts/frequencies* with W, never a 2-cells-per-unit distance constant. |

**Final reading [D]:** donor radii are **map cells**. "1 donor unit = 2 cells" is
a port label for an abandoned 160-tile baseline, not donor text. The only donor
"160" in this context is `W/2` for a 320-cell map (`D:dogenerate.inc:437`), not
a generator unit constant. `miscext2.script:19-26` contains no 160 value at all.

Arithmetic check that makes the two readings distinguishable (TILE_M=2 m/cell):

| Reading | Ring 0 | In cells | In metres |
|---|---:|---:|---:|
| Port `DONOR_UNITS=160` (`pattern_gen.gd:9,92`) | 14–22 "units" | 28–44 | 56–88 |
| Donor text (`dogenerate.inc:596,709`) | 14–22 cells | 14–22 | 28–44 |

`DTRN_05_donor_mines.md:80` and `GEN.md:201-203` both quote 28–44 as the target
*metres*; they reach it either by treating a cell as 1 m
(`DTRN_05`) or by treating port cells as 1 m (`GEN`). Both silently drop the
port's own ×2 and `TILE_M=2`. The port generator therefore currently places
ring-0 ore **twice as far as the donor text specifies** at 320² (and 1.5× at
240²). This is a **PORT APPROXIMATION**, not donor-faithful behaviour.

### C2 — Is the donor cell size in metres confirmed or UNVERIFIED?

| Pass | Instrument | Result |
|---:|---|---|
| 1 | `docs/coord_swarm_2026-11-24/reports/G32_heightmap_world.md:117-123` lists "donor terrain cell size in metres" as UNVERIFIED; `P:scripts/world3d_terrain.gd:105-106` repeats that comment. | Appears UNVERIFIED. |
| 2 | Re-read `D:dmscript.global:170-173` and the three sibling pixel constants; checked `P:scripts/data.gd:15-23`, which already writes `meters = pixels/26.6666666; tiles = meters/2`. | A donor metre **is** defined; `gc_meters_to_tile=2` is "metres per tile" by the same directional convention as `gc_pixels_to_tile=53.3333`. |
| 3 | Cross-check `D:dmscript.global:205-209` (`gc_gameplay_captureradius = 214/gc_pixels_to_tile ≈ 4 tiles`), `D:miscext2.script:960-963` (object coordinates in cells), and `D:miscext2.script:954` (cell centre +0.5). | Consistent with 1 cell = 1 tile = 2 m; no contrary donor constant found. |

**Final reading [O]+[D]:** the horizontal cell size (2 m) is donor-grounded;
`TILE_M=2.0` is **not** a port invention. `[U]` remains the *vertical* unit of
stored `height` (`D:dmscript.global:2026-2030` types it `Float` only;
`P:scripts/world3d_terrain.gd:131` asserts metres without donor backing).
The stale "UNVERIFIED" comment at `P:scripts/world3d_terrain.gd:105-106` and the
"donor-grounded" comment at `:130` are both partially right; §7 gives the exact
wording COORD should adopt.

### C3 — `collision[4]` per cell vs 2× collision grid: competing or identical?

| Pass | Instrument | Result |
|---:|---|---|
| 1 | A01 E1/E2 (`reports/A01_data_model.md:33,51,112,154`) treats them as alternatives and leaves the choice to D04. | Apparent contradiction. |
| 2 | `D:dmscript.global:80,134-135` → 4 tags/cell and 2× cap; `D:dmscript.global:178` → 0.5 cell; `D:texturemap.inc:83-129` writes at `x, x−0.5, y, y−0.5` (four sub-positions per cell); `:133-159` walks `0..2W` at `x/2+0.25`. | Both are descriptions of the same 2×2 sub-cell information. |
| 3 | `D:dmscript.global:83-92` lists all declared tag values ≤110. | u8 narrowing is safe for **declared** tags [D]; custom/unknown tags [U]. |

**Final reading [O]+[D]:** the DScript struct declares four integer collision
tags per height cell (`D:dmscript.global:80,2026-2029`) and the 2× loop / 0.5
step (`D:texturemap.inc:83-159`; `D:dmscript.global:134-135,178`) shows those
four tags carry the 2×2 sub-cell information. This V08 report does **not**
claim that the persisted `.map` binary stores them as four tags inside each tile
record: the concurrently landed `D04_map_format.md:17,161,182-183,278` reports
a separate `(2W)²` **u32** tag grid in the `.map` stream and **no** per-tile
`flags[4]` in the 37-byte record ([I]/[U], D04-owned). Storage width/order is
therefore D04's call; the fresh module may expose `u8[4]`-per-cell plus a derived
`(2w)*(2h)` view as a **PORT APPROXIMATION**, labelled as such, while the
importer follows D04. Engine consumption of that view is **[U]**
(`MapDrawCollision` is a script API; no script reads the `collision[4]` array
directly).

---

## 4. Findings per question

### Q1 — Donor grid sizes vs port 160 / 64² / 240² / 320²: actual cells-per-unit relation

**[O] Donor sizes** (`D:miscext2.script:19-26`): `mapsize` 0→320, 1→480, 2→640,
3→256, else 320. Cap 640 (`D:dmscript.global:132-135`). Public mod docs add
720 / 400 / 560 (`docs/research/RC_TERRAIN.md:25,27,59`) — **[I]/[U]** for the
vanilla binary; do not add them to the base allowed set.

**[O] Port sizes**: 160 fallback (`P:scripts/game.gd:35-36`,
`P:scripts/data.gd:33-34`), 240 config default (`P:scripts/config.gd:119-121`,
`P:scripts/menu.gd:60,725-726`), 64² test-only fixture
(`P:tests/fixtures/small_map_64.json:8-14`), 320² measured dump
(`app/shots/g32_dump.json`). 128² also exists as a fixture
(`P:tests/fixtures/small_map_128.json`). None of 64/128/160/240 is a donor
`mapsize` value.

**[D] Cells-per-unit**: **1 generator distance unit = 1 map cell** (§3/C1).
The only legitimate "scale" in donor text is a *mask resampling* factor: the
320×320 mask is sampled by `floor((x/W)*320)` for any W
(`D:generatemap.inc:537-547`, mask size measured at E22). At 640² one mask pixel
covers 2 map cells; at 256² it covers 0.8 cells (nearest sampling, no
interpolation). This is a bitmap→grid relation, **not** a generator-unit
relation.

### Q2 — Is `DONOR_UNITS=160` donor-grounded or port-invented?

**Verdict [D]: PORT-INVENTED.** Exact lines:

- Port: `P:tools/donor_gen.py:59` — `DONOR_UNITS = 160.0   # donor coordinate scale: 1 unit = 2 map cells; map=320 cells`;
  `:147-158` `s = n / donor_units`, `:193` `self.s = n / DONOR_UNITS`.
- Port: `P:scripts/pattern_gen.gd:9` — `const DONOR_UNITS := 160.0   # donor map = 320 cells = 160 generator units`; `:92` `var s := float(map_w) / DONOR_UNITS`.
- Port: `P:scripts/world3d_relief.gd:27-30` explicitly labels this conversion
  "PORT APPROX — ... `s = MAP_W / DONOR_UNITS` from the EXISTING port pattern
  generator"; `:48` re-declares the constant.
- Donor `D:dmscript.global`: `:78-81` map/terrain cap 640 and 4 collision tags;
  `:132-135` 640 cap and `2*` collision cap; `:170-173` metre/pixel/tile
  constants; `:178` collision 0.5 cell; `:2026-2035` tile record. **No 160 and
  no "2 cells per unit".**
- Donor `D:miscext2.script:19-26`: 320/480/640/256 only; `:945-963` object
  coordinates and cell-centre +0.5; `:960` uses `gc_MaxMapWidth div 2` = 320
  as a *cap-array offset*, not a unit count.
- Donor `D:texturemap.inc:56-80,133-159`: height indexed by integer cells,
  collision by half-cells; no generator unit.
- Donor `D:generatemap.inc:4-7,537-574`: amplitudes and mask→cell sampling;
  no generator unit.
- Donor `D:dogenerate.inc:402-405,437,521,559-655,704-709,1335-1345,1599-1602`:
  every distance is in the same map-cell coordinate space (§3/C1).

The only donor-side 160s found are `gc_formation_maxcount=160`
(`D:dmscript.global:166`, unrelated) and `maphW=160` for a 320-cell map
(`D:dogenerate.inc:437`). **Neither defines a generator unit.**

### Q3 — `TILE_M = 2.0`: is a donor metre defined anywhere?

**[O] Yes** — `D:dmscript.global:170-173`. `[D]` 1 map cell/tile = 2 m;
`TILE_M=2.0` at `P:scripts/world3d_terrain.gd:130`, `P:scripts/data.gd:23`,
`P:scripts/game.gd:16` is donor-grounded for horizontal spacing; the port's own
comment at `data.gd:15-17` already states the same conversion.
**[U]** vertical: no donor line assigns a unit to `height`
(`D:dmscript.global:2026-2030`); `HEIGHT_SCALE=1.0`
(`P:scripts/world3d_terrain.gd:131`) and "height[] is already metres" remain
PORT APPROXIMATION. Mesh units in `.osm` / `.pattern` also remain **[U]**
(`docs/coord_swarm_2026-11-25/reports/DTRN_02_donor_terrain_geometry.md:275`
is conditional: "If 1 donor unit ≈ 1 cell ≈ 2 m"; `docs/terrain_swarm_2026-11-26/reports/A04_landscape_props.md:175,258`
keep raw donor units with no metre factor). Do **not** conflate "mesh raw
unit", "map cell" and "metre".

### Q4 — Confirmed vs UNVERIFIED coordinate details

| Item | Status | Evidence / consequence |
|---|---|---|
| Grid side = `W` cells, 256/320/480/640 | [O] | `D:miscext2.script:19-26`; `D:dmscript.global:132-135` |
| Origin `−W/2, −H/2` cells | [O] | `D:misc.script:68-72`; port `P:scripts/world3d_terrain.gd:1300-1301,1310-1312` |
| Cell centre `+0.5` | [O] | `D:miscext2.script:954,958`; port `:1310-1312` |
| Flat index `i=y*W+x` | PORT APPROX [D] | `P:scripts/game.gd:520-521`; donor uses 2D `gMapMask[x,y]` (`D:generatemap.inc:544-546`) |
| Inverse world→cell | PORT APPROX [D] | `P:scripts/world3d_terrain.gd:1718-1726` |
| Row sign (file row → map row / Godot Z) | **[U]** | `P:scripts/game.gd:98`; `Z04_height_only_design.md:98,454`; donor row→`ty+y` at `D:generatemap.inc:541-542,556-560` does not pin engine-Z sign |
| Horizontal metre/cell = 2 | [O]+[D] | `D:dmscript.global:170-173` |
| Stored height unit = metre | **[U]** | `D:dmscript.global:2026-2030`; `P:scripts/world3d_terrain.gd:131` |
| Collision = 4 tags/cell declared; 2× grid; sub-cell 0.5 cell | [O] script / [I] binary map | `D:dmscript.global:80,134-135,178,2026-2029`; `D:texturemap.inc:56-129,133-159`; separate `(2W)²` u32 tag grid in `.map` per `D04_map_format.md:17,161,182-183` |
| Declared tag values fit u8 | [D] | `D:dmscript.global:83-92` (max 110); custom tags **[U]** |
| Engine-side collision array indexing / consumption | **[U]** | only write API `MapDrawCollision` visible in scripts |
| `.prop` mask cell = 0.5 map cell | [O] (almanac + constant) | `docs/terrain_swarm_2026-11-25/reports/F02_almanac_building_ghost.md:151-164`; `D:dmscript.global:178` |
| `.prop` mask data available in port | **No [O]** | `docs/terrain_swarm_2026-11-25/reports/G09_footprint.md:36-52` |
| Port building footprint radius (`bld_rm`, `def.radius`) and ghost radius | PORT APPROX [O] | `P:scripts/game.gd:1868,4212-4249`; `P:scripts/world3d_fx.gd:582-600,1555-1560`; divergence first reported at `G09_footprint.md:81-87` |
| `.pattern` `w×h` in map cells; object transform | [O] footprint / **[U]** transform | `docs/audit/TERRAIN_DONOR_PATTERNS.md:278-280`; `D:misc.script:3402-3405`; `StandPatternWithAngle` engine-side (`P:scripts/world3d_relief.gd:21-32`) |

### Q5 — Supporting 256/320/480/640 without breaking 160²/240²/320² atoms

See §6 (recipe) and §7 (spec deltas). Core rule: the fresh module owns `W,H`;
the legacy atoms own their dumps. The module must not assert a donor-only size
on the legacy `build()` path, must not retype existing keys, and must derive
all offsets/counts from `W,H` rather than `Data.MAP_W` or `DONOR_UNITS`.

---

## 5. Definitive coordinate / scale table

| Quantity | Donor value/rule | Donor evidence | Port today | Port evidence | Label | Fresh-module rule |
|---|---|---|---|---|---|---|
| Map side | `W ∈ {256,320,480,640}`, cap 640 | `D:miscext2.script:19-26`; `D:dmscript.global:132-135` | 160 fallback / 240 config / 64² fixture / 320² dump | `P:scripts/game.gd:35-36`; `P:scripts/config.gd:119-121`; `P:tests/fixtures/small_map_64.json:8-14`; `app/shots/g32_dump.json` | [O] + PORT APPROX | `w,h` per instance; donor set strict only in donor-mode flag; legacy sizes accepted at legacy boundary |
| Generator distance unit | 1 unit = 1 map cell (no separate unit) | `D:dogenerate.inc:402-405,704-709,1599-1602`; `D:misc.script:3384-3405` | `DONOR_UNITS=160`, `s=W/160` | `P:tools/donor_gen.py:59,147-158,193`; `P:scripts/pattern_gen.gd:9,92` | [D] vs PORT APPROX | use donor numbers **1:1**; `scale=1.0`; keep `s` only in legacy path |
| Mine rings | 14–22 / 32–42 / 70–82 / 22–38 **cells** (version/size gated) | `D:dogenerate.inc:559-655` | same numbers ×`W/160` | `P:scripts/pattern_gen.gd:13,92` | [D] vs PORT APPROX | cell radii, W-independent; version gates from `data.gd:36-43` |
| Tiled pattern grid | 25 cells | `D:dogenerate.inc:1335-1345` | 25 "donor units" ×s | `docs/terrain_swarm_2026-11-25/reports/A04_tile_diversity.md:329`; `P:scripts/pattern_gen.gd:92` | [O] vs PORT APPROX | 25 cells at every W |
| Pattern footprint `w×h` | map cells | `docs/audit/TERRAIN_DONOR_PATTERNS.md:278-286`; `D:misc.script:3402-3405` | scaled by `s` | `P:tools/donor_gen.py:147-170` | [O] + [U] transform | 1:1 cell mask, clip at borders; transform PORT APPROX |
| Mask→grid sampling | `floor((x/W)*TGA_W)` nearest | `D:generatemap.inc:537-547`; mask 320² (E22) | exported masks, nearest | `P:scripts/mapgen.gd` (via A01 E7) | [O] | same formula at 256/320/480/640 |
| Placement budget | `needed=floor(W*H*freq)`; `trycount=floor(256*320²/(W*H) * (0.65 if >320))` | `D:misc.script:3684-3704` | richness-based counts | `P:scripts/pattern_gen.gd:391` (via DTRN_05 C20) | [O] vs PORT APPROX | adopt donor budget formula |
| Relief frequency modifier | `640/((W+H)/2)` when W/H≠640 | `D:dogenerate.inc:1718-1724` | `s`-scaled counts | `P:scripts/pattern_gen.gd:92` | [O] vs PORT APPROX | apply donor modifier, no `s` |
| Horizontal cell size | 2 m | `D:dmscript.global:170-173` | `TILE_M=2.0` | `P:scripts/world3d_terrain.gd:130`; `P:scripts/data.gd:23` | [O]+[D] | keep 2.0, expose as derived constant |
| Vertical height unit | **[U]** (Float, no unit in donor text) | `D:dmscript.global:2026-2030` | `HEIGHT_SCALE=1.0` | `P:scripts/world3d_terrain.gd:131` | [U] | keep raw float; never multiply |
| Origin | `−W/2` cells → `−W m` (at 2 m/cell) | `D:misc.script:68-72` | `(x+0.5−w/2)*TILE_M` | `P:scripts/world3d_terrain.gd:1300-1312` | [O] | derive from instance `w,h` |
| Cell centre | `+0.5` cell offset | `D:miscext2.script:954,958` | same | `P:scripts/world3d_terrain.gd:1310-1312` | [O] | keep |
| Collision | 4 tags/cell = 2×2 sub-cells; 0.5 cell step; cap 2×640 | `D:dmscript.global:80,134-135,178`; `D:texturemap.inc:83-129,133-159` | one `blocked[]` byte/cell + dump keys | `P:scripts/game.gd:43`; `P:scripts/world3d_terrain.gd:926-963` | [O] core / PORT APPROX port | `u8[4N]` core + derived `(2w)*(2h)` view |
| Row sign | file row → map row sign unknown | `D:generatemap.inc:541-542` (row→`ty+y` only) | index `z*w+x` | `P:scripts/world3d_terrain.gd:1309` | **[U]** | metadata flag `row_flip:"UNVERIFIED"`, never assert |
| Building footprint | `.prop` mask 1 cell = 0.5 map cell | `F02_almanac_building_ghost.md:151-164`; `D:dmscript.global:178` | sprite/radius PORT APPROX | `P:scripts/game.gd:1868,4212-4249`; `P:scripts/world3d_fx.gd:582-600` | [O] unit / no port data | keep side table, label PORT APPROX, never derive mask from art |
| Dump | n/a (runtime `.map` format D04-owned) | `D:dmscript.global:2026-2035` | `map_w/map_h/height/tileblock` (+ optional keys) | `P:scripts/world3d_terrain.gd:926-963,1225-1250` | [O] port | additive `fields` only; top-level keys byte-identical |

---

## 6. Labelled port recipe for the fresh module

All steps below are **PORT APPROXIMATION** as representation choices; donor
numbers/rules are labelled **[O]/[D]** inline. No donor parity claim.

1. **Container.** `w,h,n=w*h` instance fields (never `Data.MAP_W`). Accept donor
   sizes `[256,320,480,640]` in donor mode; accept legacy `[64,128,160,240,320]`
   only when constructed by the legacy atom path. Allocate core SoA arrays
   `height:f32[n]`, `tex:u8[n]`, `collision4:u8[4n]` (E3/E4 [O]), plus an optional
   derived `(2w)*(2h)` collision view (E10 [O], engine use [U]).
2. **Coordinates.** `offset = −0.5*w*TILE_M` / `−0.5*h*TILE_M`; centre
   `(x+0.5+offset_x, height[i]*1.0, y+0.5+offset_z)`; inverse
   `x = clamp(p.x/TILE_M + w/2 − 0.5)`. TILE_M=2.0 [O]+[D]; HEIGHT_SCALE=1.0
   [U]; row sign metadata `"UNVERIFIED"`.
3. **Mask stage.** For any W, sample the 320² donor mask with
   `sx=floor(x*src_w/w)`, `sy=floor(y*src_h/h)` (`D:generatemap.inc:541-542`
   [O]); store `mask_r/g/b` as generation scratch. Do not invent bilinear
   interpolation (donor uses nearest/floor).
4. **Relief/water.** Use donor amplitudes `2.964 / 1.31733… / −2.964 / −1.1`
   (`D:generatemap.inc:4-7` [O]) and classify thresholds `−0.25 / −0.1`
   (`D:texturemap.inc:29-31` [O]) exactly, at every W. Height float stays raw
   ([U] unit).
5. **Pattern placement.** Decode `.pattern` `w,h` and footprint mask as map
   cells (E17/E18 [O]); stamp 1:1 into the cell grid, clipping at edges. Use the
   donor budget `needed=floor(W*H*freq)` and `trycount` formula
   (`D:misc.script:3684-3704` [O]) and the size modifier
   `640/((W+H)/2)` (`D:dogenerate.inc:1718-1724` [O]). **Remove**
   `s=W/DONOR_UNITS` from the fresh path; leave the legacy scaled path intact
   for atoms. Per-object `Scaling/Position/Direction` remain **[U]** engine-side
   (`P:scripts/world3d_relief.gd:21-32`).
6. **Mines / keep-clear / rings.** Use `dst` numbers from
   `D:dogenerate.inc:559-655` as **cells** at all W; keep-clear ellipses 5×7 /
   12×15 / 22×18 (`D:dogenerate.inc:407-414` [O]); 25-cell tile grid
   (`:1335-1345` [O]). Version gates from `P:scripts/data.gd:36-43` [O port].
7. **Collision.** Emit `u8[4]` per cell using declared tags
   (`D:dmscript.global:83-92` [O]); derive the 2× view with sub-cell centres
   `((cx+0.5)*0.5 − w/2)*TILE_M`, `cx∈[0,2w)`. Tag range/custom tags [U].
8. **Dump boundary.** Keep `map_w`, `map_h`, `height` (base64 f32-LE),
   `tileblock` (base64 u8) exactly as produced at
   `P:scripts/world3d_terrain.gd:926-963`; new arrays go under one optional
   `fields` dict; missing/short ⇒ zeros; version mismatch ignored; old `build()`
   (`P:scripts/world3d_terrain.gd:1225-1250`) never interprets `fields`. This is
   the mechanism that keeps 64²/160²/240²/320² atoms byte-identical.
9. **No-go list.** No new donor constant, no synthetic noise/dither, no
   `HEIGHT_SCALE` multiplier, no `TILE_M` change, no gate/threshold edit, no
   `app/` edit, no donor parity claim, no row-sign guess.

---

## 7. Implications for spec §01 and §10

### §01 `docs/terrain_swarm_2026-11-26/spec/01_WORLD_DATA_MODEL.md`

- **§2 row "Allowed W=H" (`:30`)** — keep {256,320,480,640} [O], but amend
  "160 = port debug alias" to enumerate **64/128/160/240/320** as port-only
  aliases with exact citations (E24); 320 is the single overlap.
- **§2 row "Cell centre" (`:32`)** — add donor witness
  `D:miscext2.script:954,958` (object at `px+0.5`) and origin
  `D:misc.script:68-72`; currently cited only to a prior report.
- **§2 row "Metres per cell" (`:36`)** — change from "TILE_M=2.0 is port-only,
  UNVERIFIED" to: **"[O] donor constant `gc_meters_to_tile=2`
  (`dmscript.global:171`), [D] 1 cell = 2 m; [U] stored height unit."**
  This resolves A01 §9 item 8 partially.
- **§2 row "Row sign" (`:35`)** — stays **[U]**; add `D:generatemap.inc:541-542`
  as the row→map-y evidence that is *not* a row-sign proof.
- **§1/§4 collision (`:14,33,53,112,154`)** — replace the "either/or" with
  "[O] `collision[4]` is the 2×2 sub-cell set; expose both views; tag values
  ≤110 [D], engine consumption [U]". Add `D:dmscript.global:83-92,178` and
  `D:texturemap.inc:83-129,133-159`.
- **§5 dump contract (`:55-62`)** — unchanged; V08 adds no new key. Record that
  the dump carries `map_w/map_h` (`:926-963`), so a 640² dump can coexist with
  a 240² one.

### §10 `docs/terrain_swarm_2026-11-26/spec/10_STAGE_ORDER.md`

- **§2 "Placement grid: strict 25-unit grid" (`:47`)** — correct to
  **25 map cells** (`D:dogenerate.inc:1335-1345` [O]); "unit" is a port label
  here and misleads implementers into applying `W/160`.
- **§2 "Mines ... radii D1:525,:528-534,:594-645" (`:49`)** — state that these
  radii are **map cells**, not 2-cell units (§3/C1), and that A02's inherited
  `RC_TERRAIN.md:90` label is **[I] contradicted**. Implementation must not
  multiply by `W/160`.
- **Add two donor-grounded W-scaling rules** missing from §2:
  `needed=floor(W*H*freq)` / `trycount=floor(256*320²/(W*H)*0.65)`
  (`D:misc.script:3684-3704` [O]) and `640/((W+H)/2)` frequency modifier
  (`D:dogenerate.inc:1718-1724` [O]); arrays capped at 640
  (`D:dogenerate.inc:444-451`; `D:dmscript.global:132-135`).
- **Add mask resampling rule** `floor((x/W)*320)` (`D:generatemap.inc:537-547`
  [O]) as the stage-5 bridge between 320² authored masks and 256/480/640 grids.
- **§4 cross-check queue (`:65-69`)** — add "V08 unit contract" as resolved for
  grid/cell/metre, with row sign, height unit, engine collision indexing and
  `.prop` mask shape still **[U]**.

---

## 8. Risks

| # | Risk | Severity | Mitigation |
|---:|---|---|---|
| R1 | Fresh module copies `DONOR_UNITS=160` and silently doubles all radii/footprints at 320/240 | **high** | §6 step 5: `scale=1.0`; assert in review that no `W/160` expression exists in the fresh path; legacy path left byte-identical |
| R2 | Reader treats `gc_meters_to_tile=2` as "2 tiles per metre" and sets `TILE_M=0.5` | high | §3/C2 directional convention cross-check (E5); keep 2.0; no change to existing atoms |
| R3 | u8 collision narrowing wrong for custom tags | medium | declared tags ≤110 [D]; keep metadata `collision_width:"declared-u8 / custom [U]"` |
| R4 | Row-sign guess flips relief/masks and is mistaken for a fix | medium | keep `row_flip:"UNVERIFIED"`; no visual claim until a donor A/B frame exists (none) |
| R5 | 640² arrays overflow 320-sized port scratch buffers | medium | allocate to cap 640 at every stage (`dogenerate.inc:447-450`, `dmscript.global:132-135`); use instance `W` for bounds |
| R6 | "Donor parity" claimed from this report | high (epistemic) | all donor facts are text/constant observations; **NO DONOR PARITY CLAIM** |
| R7 | COORD edits spec §01/§10 while other workers cite the old "UNVERIFIED metre" wording | low | V08 supplies exact replacement sentences in §7; no worker edits spec files |
| R8 | Mine ring "metres" in old reports (28–44 m) used as proof of the 2-cells/unit reading | medium | §3/C1 arithmetic shows both readings were quoted as metres with inconsistent cell assumptions; final reading is donor-text based |

---

## 9. UNVERIFIED register (must not be promoted)

1. **No donor GPU A/B frame exists** — no visual/parity claim (`CHARTER.md:41,72,126`).
2. **Stored `height` unit** — `Float` only (`D:dmscript.global:2026-2030`);
   `HEIGHT_SCALE=1.0` PORT APPROX (`P:scripts/world3d_terrain.gd:131`).
3. **File-row → map-row / Godot-Z sign** — [U] (E4 of §4; prior `game.gd:98`,
   `Z04:454`).
4. **Engine collision indexing/consumption of `collision[4]`** — [U]; only
   `MapDrawCollision` writes are visible (`D:texturemap.inc:83-159`). Whether
   the binary's `(2W)²` u32 grid is the same data as the script struct's four
   tags is D04-owned [I]/[U] (`D04_map_format.md:17,161,182-183,278`).
5. **Custom collision tag range beyond declared 0..110** — [U].
6. **`.prop` collision-mask shape/scale in the port** — no file/decoded mask
   (`G09_footprint.md:36-52`); almanac 0.5-map-cell claim is [O] text only.
7. **`.osm` mesh unit ↔ metre factor and `StandPatternWithAngle` transform** —
   [U] (`DTRN_02:275`; `P:scripts/world3d_relief.gd:21-32`).
8. **720 / 400 / 560 map sizes** — mod/public-doc only
   (`docs/research/RC_TERRAIN.md:25,27,59`); not in `miscext2.script:19-26`.
9. **`.map` runtime binary layout and field offsets** — D04-owned; V08 does not
   claim the port arrays equal `.map` records (A01 E21/E22).
10. **Exact donor key-derivation / RNG stage mix** — D02-owned; unaffected here.

---

## 10. Open questions

1. Does COORD want the fresh module to keep `s=W/160` as an explicitly
   labelled legacy compatibility mode for seed-replay atoms, or remove it from
   all fresh paths and mark the old dumps as a different contract? (V08
   recommends: keep only behind the legacy boundary.)
2. Should `TILE_M` be elevated from `const` to an instance field on the
   container (still default 2.0) so a future donor-height-unit finding can be
   applied without a shader edit?
3. D04: does the runtime `.map` record store four tags per height cell in the
   order implied by `D:texturemap.inc:83-129`, or in a different sub-cell order?
4. D05/D06: if stored height is not metres, should `HEIGHT_SCALE` remain 1.0
   and the unit conversion be applied at render time instead?
5. F01/F02: can any donor `.prop` collision mask be decoded read-only to give
   the fresh module a donor-grounded building footprint table? (G09 says none
   is currently in-repo.)
6. Should the 240² config default (`P:scripts/config.gd:119-121`) be changed to
   a donor size (320) as part of integration, or left as a labelled port
   approximation to keep atoms green? (COORD/owner decision; V08 makes no edit.)

---

*End of V08. One report written. No code, shader, config, asset, test, fixture,
git, Godot or runner state changed. Donor text and mask headers were read
only; no donor binary was executed or copied. NO DONOR PARITY CLAIM.*
