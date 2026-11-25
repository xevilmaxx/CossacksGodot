---
id: RELIEF-LIVE-DIAG-01
title: "Read-only diagnosis — why LIVE skirmish terrain is flat / shows pale marks even with relief_stamps enabled"
agent: "RELIEF-LIVE-DIAG-01 (read-only diagnosis subagent, coord swarm 2026-11-25)"
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB__NO_DONOR_ACCESS
scope: "One new file only: this report. No source, asset, config, test, PNG, JSON, shader, git or donor edit; no Godot job; no ladder advancement."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
live_tree: "variant3d/ (task's main.gd:788-803 and game.gd:1092 match variant3d, not app/)"
labels: [observed, derived, inferred, UNVERIFIED]
parity_guard: "PORT APPROX — internal consistency only. No donor GPU A/B frame exists; no donor parity is claimed."
verdict: "CONFIRMED: the config flag gates ONLY the --dump-map key; live boot builds terrain from game.height[], which is shaped by game.gd:_shape_stamp_relief() using ANALYTIC profiles over donor footprints — no donor float32 relief grid ever reaches live height. Bright marks are best explained by tile-id art (test7/test8) placed by donor detail-bitmap bytes on flat cells, not by relief."
output: docs/coord_swarm_2026-11-25/reports/RELIEF_LIVE_DIAG_01.md
---

# RELIEF LIVE DIAG 01 — real cause of white marks / flat land in LIVE skirmish terrain

> [!IMPORTANT]
> Donor is truth. Every claim below is labelled **observed** (literal source line,
> decoded file field, or direct read-only measurement), **derived** (control-flow
> or arithmetic consequence of observed lines), **inferred** (attribution without
> a pixel-aligned donor A/B), or **UNVERIFIED**. Nothing was edited; no Godot
> process was run; no donor file was read, copied or executed. **No donor parity
> claim** is made. No synthetic noise, higher amplitude or fabricated hill is
> proposed as a fix — donor grids/props only.

---

## 0. Mandate and boundary

The submitter of RELIEF-VISUAL-01 observed that the config flag gates only
`_dump_map()` (`main.gd:788-803`) and that live boot terrain renders `game.height`
shaped by `game.gd:_shape_stamp_relief()` (`game.gd:1092`) via `world3d.gd`.
TERRAIN-MARKS-01 proved the P0 flat 64² harness cannot show hills and that the
relief flag explains the *dump-only* absence; the owner, however, sees a real
generated map. This report answers, from source only:

1. what relief grids (if any) actually shape **live** `game.height`;
2. whether donor `plt2`/ravine/plateau grids are used or only synthetic masks;
3. whether `game.height` is later overwritten/clamped;
4. how `test7/8/9` or `rock8/rock4` tile ids could paint bright marks **without**
   a height change;
5. the ranked root causes, the smallest discriminating probe, and the single
   owner file for a fix.

`RELIEF-VISUAL-01` is still `RUNNING` on the swarm board
(`docs/coord_swarm_2026-11-25/SWARM_BOARD.md:326`); no report frame from it was
available to this worker. All visual attribution here is therefore inferred.

---

## 1. Sources (all read-only)

### 1.1 Live source — `variant3d/` (the tree the task's line numbers match)

| # | File | What was read |
|---|---|---|
| S1 | `variant3d/scripts/game.gd` | `:44-75` height/constants; `:306-318` setup; `:685-809` `_gen_patterns()`; `:861-868` `_generate_map()`; `:870-993` `_shape_stamp_relief()`; `:995-1134` `_gen_base()` (base height, domes, stamp call, global clamp, collision); `:1773-1807` `_apply_detail_pass()`; `:1812-1907` `_assign_tileblocks()`; `:1949-1995` `_cliff_tile_for()` / `_apply_shore_cliffs()`; `:2016-2086` smoothing; `:2102-2123` `height_at()`. |
| S2 | `variant3d/scripts/main.gd` | `:751-810` `_dump_map()` — producer loop `:767-783`, gate `:788-803`, dump dict `:791-798`. |
| S3 | `variant3d/scripts/config.gd` | `:54-61` `FEATURES_DEFAULTS.terrain` (relief_stamps false at `:59`); `:448-449` `feature_terrain_relief_stamps()`. |
| S4 | `variant3d/config.json` | `:24-31` — `features.terrain.relief_stamps` is now **`true`** (`:29`). |
| S5 | `variant3d/scripts/world3d.gd` | `:108,604` terrain module; `:224-233` `_has_height_source()`; `:635-639` `terrain.bind(game)` + `terrain.build()` on live boot. |
| S6 | `variant3d/scripts/world3d_terrain.gd` | `:910-953` `_dump_from_game()` (synthesized live dump); `:1163-1195` `build()` / stamp call; `:1441-1454` `stats["relief_grid"]`. |
| S7 | `variant3d/scripts/pattern_gen.gd` | `:1-6` donor-mask provenance; `:40-57` `load_data()` + `Stamp`; `:60-107` `build()` / `scale_cells()`; `:158-190` `stamp_family()`; `:474-549` relief stamp pass; `:27-36` `RELIEF_RECIPES`. |
| S8 | `variant3d/scripts/mapgen.gd` | `:63-73` analytic `relief()` band mapping. |
| S9 | `variant3d/assets/terrain/patterns/donor_patterns.json` | parsed read-only: top keys `version/source/note/donor_units/families/patterns`; 282 patterns; `plt2` keys = **`w`, `h`, `cells` only**; `source` cites donor `.pattern` + `generator.cfg`. |
| S10 | `variant3d/assets/terrain/structs/presets_summer.json` | parsed read-only ids: `grass1`=0, `rock4`=20, `rock8`=24, `test7`=78, `test8`=79, `test9`=80. |
| S11 | `variant3d/shaders/terrain_tileindex.gdshader` | `:322-335` `v_tile` / `tile_rgb()` atlas lookup; `:338-347` alpha patch PORT APPROX; `:386-390` fragment RGB; `:469` `ALPHA = mix(...)`. |
| S12 | `variant3d/assets/terrain/blocks/{test7,test8,test9,rock4,rock8,grass1}.png` | read-only PIL measurement of 1024² art (§3.4). |
| S13 | `C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/reliefenabl01_dump.json` | existing flag-on dump artifact read read-only: `relief_stamps: []`, seed 20261113, 64², `meta.stamp_counts.plateau = 2`. |

### 1.2 Prior reports consulted (not new evidence)

`DPATTERN_01_relief_grids.md` (`:101-124`, `:142`, `:154`, `:237-249`,
`:302-382`, `:595-626`), `DTRN_02_donor_terrain_geometry.md` (`:102-106`,
`:310-327`, `:362-428`), `RELIEF_01_stamping.md`, `RELIEF_02_stamp_marker.md`,
`RELIEF_ENABLE_01.md` (`:118-134`), `QA_RELIEF_ON_01.md`, `QA_RELIEF_DUMP_01.md`,
`TERRAIN_MARKS_01.md` (`:90-124`, `:156-191`), `TRN_DATA_implementation.md`
(`:44-64`).

---

## 2. Live data-flow trace (`path:line`)

### 2.1 The config flag changes only the dump key — CONFIRMED

- `config.gd:59` stores the default `relief_stamps: false`; `config.gd:448-449`
  resolves `flag("features.terrain.relief_stamps", false)`. `config.json:29` now
  sets it to `true`, so the getter resolves true at runtime (confirmed by the
  flag-on dump artifact S13, which carries the key).
- `main.gd:767-783` builds `relief_stamps` from `game.pattern_stamps`, filtering
  to names `plt2` / `k_ravine_1`; `main.gd:788-803` is the **only** consumer of
  the flag in the dump path — `if relief_enabled: dump["relief_stamps"] = ...`.
  The dump dict itself (`main.gd:791-798`) contains `seed/map_w/map_h/terrain/
  blocked/height/tileblock/starts/clusters/res/meta`; the marker is appended
  afterwards.
- **Derived:** enabling the flag cannot change a single byte of `game.height`,
  `game.tileblock`, the live mesh, or the live HUD. It only adds one key to a
  `--dump-map` JSON file. This independently confirms RELIEF-VISUAL-01's note.

### 2.2 Live boot never feeds that marker to the terrain — CONFIRMED

- Live boot instantiates `world3d_terrain.gd` (`world3d.gd:108`, `:604`), then
  `terrain.bind(game)` and, if a height source exists, `terrain.build()`
  (`world3d.gd:635-639`; `_has_height_source()` at `:224-233` accepts a live
  `PackedFloat32Array height`).
- `world3d_terrain.gd:_dump_from_game()` (`:916-953`) first checks for an
  explicit `dump`/`map_dump`/`self_base` dictionary; **on live boot there is
  none**, so it synthesizes one from `game.height` and `game.tileblock`. The
  synthesized dict has exactly `map_w`, `map_h`, `height`, `tileblock`
  (`:945-953`) — **no `relief_stamps` key**.
- `world3d_terrain.gd:1193` calls `_apply_relief_stamps_from_dump(dump, ...)`;
  the reader (`:522-524`) does `dump.get("relief_stamps", null)` and therefore
  returns 0 for live boot. `stats["relief_grid"]` (`:1441-1454`) would report
  `applied = 0`.
- **Derived:** the entire RELIEF-01/02 donor-grid path is a **dump/capture-only
  facility**. Even a real `--dump-map` with a non-empty `plt2` marker would not
  affect live boot, because live boot rebuilds its own marker-free dump from
  `game.height`.

### 2.3 What actually shapes live `game.height` — CONFIRMED

`_generate_map()` (`game.gd:861-868`) calls `_gen_base()` first. Inside
`_gen_base()`:

1. **Base height** — `game.gd:1019-1021` takes `height` from
   `C3MapGen.build()`, whose relief decoder is the analytic band function
   `mapgen.gd:63-73` (`v>=250 → +2.964`, `|v-96|<=12 → +1.317`,
   `|v-48|<=12 → -2.964`, else scaled half-amplitude). Donor terrain-mask
   bitmaps are the *source*, but the height mapping is the port's band
   approximation, not the donor's exact class×R formula (DTRN-02 §7.2 item 2).
2. **Domes** — `game.gd:1042-1055` adds paraboloids
   `(1-dd)² × (2.964/2.25) × relief_scale` around random centres. These are
   port analytic shapes, not donor grids.
3. **Stamp footprints** — `game.gd:1090-1091` calls
   `C3PatternGen.build(...)`; `pattern_gen.gd:474-549` places relief stamps
   using donor **footprint cells** (`scale_cells()` at `:88-107` reads
   `patterns[name].cells`). `Stamp` carries `family/name/kind/x/y/cells`
   (`pattern_gen.gd:50-57`) — **no height grid field**.
4. **Stamp height** — `game.gd:1092` calls `_shape_stamp_relief()`. The function
   states at `:871-875`: *"Only the height profile is a port adaptation (the
   donor's per-cell height fields are undecoded)"*. For each stamp it maps
   `kind → amp/edge/rim_tiles` (`:896-914`), uses the donor mask occupancy only
   for hills (`:923-963`), builds an **analytic radial/taper profile**
   `f = clampf((edge-d)/rim,0,1)` for plateaus/hills/mountains or
   `f = wall*ends` for ravines (`:964-985`), and writes
   `height[i] = clampf(height[i] + amp*f, RELIEF_RAVINE, RELIEF_PLATEAU)`
   (`:993`). The amplitude constants are `2.964`, `2.964/2.25`, `-2.964`
   (`game.gd:73-75`) — donor *scalar* ceilings, not donor grid samples.
5. **Global overwrite/clamp** — `game.gd:1093-1109` then clamps **every non-water
   cell** to `[RELIEF_RAVINE, hcap]` where `hcap = 2.964` or `2.934` selected by
   a noise dither on `(x,y)` (`:1105-1108`). This is a second, later overwrite
   of `game.height`. The water sand collar is assigned at `:1062-1076`.
6. **Collision pass** — `game.gd:1110-1134` marks cells with `|dh|>0.5`
   cardinal / `>0.55` diagonal as `terrain = 5` and `blocked`.
7. `_gen_patterns()` (`game.gd:685-809`) only paints `terrain` and resource
   nodes; `:798-802` explicitly says *"never mutate height post-collision"*.
   No later generation stage writes height.

**Donor truth for contrast:** relief `.pattern` files carry a row-major
`w×h` float32 height window (`DPATTERN_01:101-124`); `plt2` grid is
`[-0.0732549, +3.6134117]` (`:154`), `k_ravine_1` is `[-2.9636276, +3.1398201]`
(`:142`), plateaus have broad flat caps ≈3.2–3.5 (`:237-249`). Donor sculpt is
engine-side and its blend is UNVERIFIED (`:348-382`). **None of these values is
present in the live height path** — see §3.1.

### 2.4 How the live mesh consumes `game.height`

- `world3d_terrain.gd:1163-1187` decodes the base64 `height[]` into a local
  `PackedFloat32Array` and computes `hmin/hmax`; `:1189-1199` applies the opt-in
  donor-grid stamp only if the marker exists (it does not on live boot);
  `:1201-1203` decodes `tileblock` for the atlas index buffer.
- Colour is **tile-id driven, not height driven**:
  `terrain_tileindex.gdshader:322-335` takes `v_tile = UV2.x` and
  `tile_rgb()` samples one atlas cell per id; `:386-390` uses that RGB directly
  in `fragment()`. Alpha may blend toward a patch value (`:338-347`, `:469`),
  but the bright RGB itself comes from the atlas art.

---

## 3. Findings (direct answers to the mandate)

### 3.1 What relief grids reach live `game.height`? — **NONE from the donor**

**observed/derived.** The only height inputs to live `game.height` are:
`mapgen.build()` band relief (`game.gd:1021`, `mapgen.gd:63-73`), analytic domes
(`game.gd:1042-1055`), and the analytic `_shape_stamp_relief()` profile
(`game.gd:870-993`), followed by the global clamp (`game.gd:1099-1109`).
`donor_patterns.json` records contain **only** `w`, `h`, `cells` (verified by
read-only parse of `plt2`); `pattern_gen.gd:50-57` `Stamp` has no grid field;
`game.gd:871-875` explicitly says the donor height fields are "undecoded".
The RELIEF-01 coarse `plt2` table lives in `world3d_terrain.gd` behind a marker
that live boot never supplies (§2.2).

**Donor `plt2`/ravine/plateau grids are NOT used.** Sandbox note: RELIEF-01's
8×10 block means are labelled "debug/preview aids only" by
`DPATTERN_01:595-600`, so even the dump path would not reproduce the donor
silhouette. Mountain relief is carried by `terrainmesh*` props in the donor
(`DPATTERN_01:271-285`, `DTRN_02:104-105`); the port has no such props.

### 3.2 Is `game.height` later overwritten/clamped? — **YES, twice**

**observed.** Stamp level: `game.gd:993` clamps the additive result to
`[-2.964, +2.964]`. Global level: `game.gd:1099-1109` clamps all land cells to
`[−2.964, 2.964 or 2.934]` with an `(x,y)` noise dither on the cap. Consequence
(derived): plateau tops saturate at ≈2.96 and read as a flat colour field rather
than a rounded hill; if the donor `plt2` grid (+3.6134) were ever stamped by the
dump path, this clamp would truncate it further (open in RELIEF-01 §5.6,
RELIEF-02 §7 Q3). The dither at `:1105-1108` is a quantisation/cap device — it
must **not** be repurposed as synthetic shape.

### 3.3 Can tile ids paint bright marks without a height change? — **YES**

**observed/derived.** Three height-independent insertion paths:

1. `game.gd:1783-1807` `_apply_detail_pass()`: every cell still on `grass1` gets
   a tile id from donor `tile_lowground/highground.bmp` via `tex = R div 2`
   (`:1805`). The only height gate is `h < 0.1` selecting which bitmap to read
   (`:1799-1802`) — on ordinary flat land (`h≈0`) the **lowground** bitmap is
   used and its authored bytes write `test7`(78)/`test8`(79) directly. No relief
   is required. TRN-DATA measured offline that `test7+test8 ≈14.89%` and
   `test9 ≈0.84%` of cells on the same 320² dump
   (`TRN_DATA_implementation.md:54-64`).
2. `game.gd:1895-1898` + `:2016-2077` `_tb_smooth_pair()`: the 3-pass donor
   smoothing table inserts midpoint/next transition ids between dissimilar
   neighbours (`test*` among them) with **no height read at all**, after the
   detail pass.
3. Colour then comes purely from the atlas id — `shader:322-335,390` — so a
   bright speckle in a transition tile's art appears as a mark on flat land.

`rock8`/`rock4` are different: `_cliff_tile_for()` requires `abs(h)>2.7` for
`rock8` and `>2.4` for `rock4`, and returns none for `abs(h)<0.1`
(`game.gd:1975-1982`); they are applied only to steep `terrain==5` cells
(`game.gd:1992-1995`, created at `:1110-1134`), and `rock4` is one of the base
steep-cell ids (`:1868-1880`). **Derived:** these ids cannot explain marks on
genuinely flat cells; if present, they *prove* real height ≥2.4.

### 3.4 Tile-art brightness — direct read-only measurement

1024×1024 art, PIL, 0.299R+0.587G+0.114B luma; "bright" = luma > 180:

| Tile (id) | max RGB | mean RGB | bright pixels |
|---|---|---|---:|
| `test7` (78) | (222, 215, 123) | (74.2, 78.8, 28.2) | 109 |
| `test8` (79) | (222, 231, 148) | (73.0, 77.9, 27.9) | **245** |
| `test9` (80) | (189, 195, 74) | (74.5, 76.4, 24.6) | **0** |
| `rock4` (20) | (255, 239, 189) | (70.8, 61.5, 49.9) | 68 |
| `rock8` (24) | (231, 211, 165) | (72.9, 65.7, 37.9) | 21 |
| `grass1` (0) | (132, 150, 57) | (76.0, 82.5, 30.4) | 0 |

**Derived:** `test7`/`test8`/`rock4` contain rare bright speckles on an otherwise
olive/brown mean; `test9` and `grass1` contain none. This matches
TERRAIN-MARKS_01's independent measurement (`:100`). A real map's `test*` ids can
therefore read as sparse pale marks even where height is flat; `rock*` marks
would be height-gated.

### 3.5 Status of the flag-on capture path

**observed.** `config.json:29` = true; the successful 64² dump
(`RELIEF_ENABLE_01.md:118-134`, artifact S13) has `relief_stamps` **present but
empty** for seed 20261113, while `meta.stamp_counts` lists `plateau: 2`. The two
plateau stamps were therefore *not* named `plt2` (the plateau family has five
equally weighted members, `donor_patterns.json` `plateau` list), so the producer
correctly emitted nothing. **Derived:** a flag-on capture of a real map will
still render the analytic relief of §2.3, because live boot does not read the
marker (§2.2). This is the decisive correction to the earlier "flag off explains
it" framing for the live path.

---

## 4. Ranked root-cause table

| Rank | Cause | Status | Evidence (`path:line`) | Explains |
|---:|---|---|---|---|
| **1** | **The flag is wired only to `--dump-map`; live boot discards its marker.** Even with `relief_stamps: true`, live terrain builds from `game.height` with a synthesized marker-free dump. | **CONFIRMED (observed + derived)** | `main.gd:788-803`; `config.json:29`; `world3d.gd:635-639`; `world3d_terrain.gd:916-953` (keys at `:945-953`), `:1193,522-524`; flag-on dump S13 / `RELIEF_ENABLE_01.md:118-134` | Why "relief on" does not change the live picture; why TERRAIN-MARKS-01's dump-path diagnosis does not resolve the owner's real map. |
| **2** | **Live `game.height` receives no donor float32 relief grid.** Footprints are donor-derived, but the height profile is an analytic radial/taper approximation over those footprints; `donor_patterns.json` carries no grid and `Stamp` has no grid field. | **CONFIRMED (observed)** | `game.gd:871-875,893-993`; `pattern_gen.gd:50-57,88-107,474-549`; S9 `plt2` keys `w/h/cells`; `DPATTERN_01:101-124,142,154` | The primary reason donor hills / asymmetric ravines / plateau caps are absent — "flat land" in donor terms. |
| **3** | **Later clamping flattens every land cap to ≈2.96.** Stamp clamp at `:993` and global clamp+dither at `:1099-1109` saturate plateaus; `plt2`'s +3.6134 would also be truncated if the dump path fired. | **CONFIRMED mechanism; visual contribution inferred** | `game.gd:993,1093-1109`; `DPATTERN_01:154,237-249`; RELIEF-01 §5.6 | Saturated flat-coloured plateau tops; "pattern looks like a mark, not a hill". |
| **4** | **Bright marks from tile-id art on flat cells.** Donor detail-bitmap bytes and donor smoothing insert `test7/8/9` without any height change; atlas art supplies bright speckles. | **Mechanism CONFIRMED; attribution to owner's exact frame UNVERIFIED** | `game.gd:1783-1807,1894-1898,2016-2077`; `shader:322-335,386-390`; `TRN_DATA_implementation.md:54-64`; §3.4 measurements | Best available explanation for literal pale/white marks on flat land in a real generated map. |
| **5** | **Analytic domes are geometrically tiny at map scale.** `(1-dd)²×1.317×relief_scale` over a 320²/640 m map is <1 m ≈0.2%. | **CONFIRMED source; visual effect inferred** | `game.gd:1042-1055`; `mapgen.gd:63-73`; DTRN-02 `:265-270,346-348` | Residual "almost flat" appearance even where stamps run. **Do not "fix" by raising amplitude** — that would be synthetic hills. |
| **6** | **`rock8`/`rock4` as the cause of flat-land marks — refuted.** Both require real height (`>2.7`/`>2.4`) and a steep cell; they cannot appear at `abs(h)<0.1`. | **CONFIRMED refutation for flat cells** | `game.gd:1975-1982,1992-1995,1868-1880,1110-1134`; DTRN-02 C13 `:109` | Rules out the brightest tile art unless the marked cells are genuinely high/steep — a useful probe discriminator. |
| **7** | **Alpha-patch / sky-blend seam exposing bright background.** | **UNVERIFIED (low); refuted for tile id 0 in P0** | `shader:338-347,469`; `TERRAIN_MARKS_01.md:103`; `V3D_02` P4/F4 | Possible only if a real map's tile→patch mapping is wrong; not demonstrated by any frame here. |

**Cross-checks that sharpen the ranking**

- The *missing donor hills* and the *pale marks* have **different** causes: ranks
  1–3 / 5 for the former, rank 4 for the latter. No source path writes white
  colour from a height stamp: the stamp writes `height[]` only
  (`game.gd:993`, `world3d_terrain.gd:497-499`); colour enters via the atlas
  (`shader:330-335`).
- `k_ravine_1` cannot be emitted by the producer at all (absent from
  `donor_patterns.json`, no `ravine_medium` recipe in `pattern_gen.gd:27-36`,
  donor disables it at `dogenerate.inc:1760`; `RELIEF_02_stamp_marker.md:68-84`),
  so a donor ravine can never appear in any current path — another facet of rank
  2.
- TERRAIN-MARKS-01's "flag off" rank-1 remains correct **for the dump/P0 path**;
  it is superseded for the live path by rank 1 above, because the flag is now
  true yet live boot still ignores the marker.

---

## 5. Smallest discriminating probe (PROPOSED — not run, no code edits)

The dump's `height` is written straight from `game.height` (`main.gd:795`), so a
dump is a valid read-only proxy for the array live boot renders. One seed with a
known `plt2` marker is all that is needed.

1. **Find the seed (cheap, producer side).** Reuse the already-working flag-on
   `--dump-map` path at 64² (flag-on 320² previously needed >180 s; 64²
   succeeded — `RELIEF_ENABLE_01.md:116-134`). Sweep `Data.RANDOM_SEED` via the
   existing `--config` override until the dump's `relief_stamps` contains
   `{"name":"plt2","cx":…,"cy":…}`. Seed 20261113 produces `[]` (S13), so it is
   **not** a valid probe seed. Record `(cx,cy)`, `stamp_counts`, and confirm
   `SCRIPT ERROR == 0`.
2. **Decode the same dump in memory** (Python 3.14, no file written):
   `height` base64 → `float32[w*h]`; `tileblock` base64 → `u8[w*h]`.
3. **Report four numbers**, global and in the `plt2` window (footprint `42×55`
   donor cells scaled by `s = MAP_W/160`, `pattern_gen.gd:71,89-107`;
   at 64² `s=0.4` → ≈17×22 cells):
   - `height` min/max and count at cap (`≥2.93`) / below `−2.0`;
   - window `height` min/max/mean — donor expects a broad ≈3.2–3.5 cap
     (`DPATTERN_01:237-249`, Appendix A2 `:615-626`), port analytic expects
     ≤2.964 with radial falloff (`game.gd:904,993,1109`);
   - `tileblock` histogram for ids **78/79/80** (`test7/8/9`), **20** (`rock4`),
     **24** (`rock8`), **0** (`grass1`), globally and in-window;
   - for every bright-id cell, local `|dh|` to its 4 neighbours, classified
     `|dh|<0.5` → flat-land tile art, `|h|>2.4` → height-gated rock art.
4. **Interpretation (decision table):**
   - Window cap ≈2.96–2.93 and radial, while `relief_stamps` holds `plt2` ⇒
     the live analytic path (ranks 1–2) is confirmed; the marker did nothing.
   - `test7/8` present with `|dh|<0.5` ⇒ pale marks are tile art (rank 4),
     independent of relief.
   - `rock8`/`rock4` present ⇒ those cells really are high/steep (rank 6 not
     the cause of *flat-land* marks).
   - Only if the window shows ≈3.2–3.5 with a donor-grid-shaped cap would a
     donor grid have been applied — which current source says is impossible on
     the live path.
5. **Guard:** this is a port-internal measurement. It does **not** validate the
   donor engine blend (`Replace`/`Smooth` order UNVERIFIED,
   `DPATTERN_01:348-382`) and yields **no donor parity claim**. No runner job
   was submitted by this worker.

---

## 6. Owner-file recommendation

**Primary single owner file: `variant3d/scripts/game.gd`** — specifically
`_shape_stamp_relief()` (`:870-993`) and the immediately following global clamp
(`:1093-1109`).

Justification: it is the **sole writer of live stamp height**, and it is where
the live/dump disconnect becomes visible (`:871-875` still calls the donor height
fields "undecoded"). Adding grid data in `pattern_gen.gd` alone changes nothing
unless this function consumes it; conversely a donor-derived numeric grid table
(numbers only, no donor binary — cf. RELIEF-01's tables in
`world3d_terrain.gd:185-243`) can be consumed locally in `game.gd`, keyed by
`st.name`, with donor `HeightFieldScale/Min/Max`. The smallest defensible change
is therefore: stamp the donor grid when one exists for `st.name`, keep the donor
footprint from `st.cells`, fall back to the existing analytic profile **only**
where no donor grid exists, and reconcile the later ±2.964 cap with the donor
`plt2` max — without adding noise, raising amplitude, or inventing hills.

**Secondary enabler (not the live disconnect):** `pattern_gen.gd` / the donor
pattern export owns the `Stamp` data contract (`:50-57`) and
`donor_patterns.json` (currently `w/h/cells` only). Mountain stamps need
`terrainmesh*` props (`DPATTERN_01:271-285`), which is a separate asset/prop
ticket, not a height edit.

**Not the owner for a live fix:** `main.gd`/`config.gd` (dump key only),
`world3d_terrain.gd` (consumer of a marker live boot never supplies).

---

## 7. Open questions (UNVERIFIED — do not guess)

1. Which seed/preset actually places a `plt2` stamp? Seed 20261113 at 64² emits
   `[]` despite `plateau: 2`; no runtime dump with a `plt2` entry exists here.
2. Which frame/seed/config produced the owner's white marks? No report frame
   from the still-RUNNING RELIEF-VISUAL-01 was available; visual attribution
   stays inferred.
3. Are the owner's marks grid-aligned (tile/alpha patch, rank 4/7) or
   height-driven cliff art (rank 6)? This one observation separates them.
4. Does a real generated map contain `test7/8` cells with `|dh|<0.5`? The live
   tileblock histogram has never been dumped in-engine (TRN-DATA used an
   offline Python-RNG replay, `TRN_DATA_implementation.md:54-64,85`).
5. Will a donor-grid live stamp read as a hill at the fixed camera, given the
   +2.964 cap and the coarse tables being debug aids only?
6. Donor engine blend (`Replace`/`ReplaceForWater`/`Smooth`, clamp/scale order,
   row flip) is engine-side and UNVERIFIED (`DPATTERN_01:348-382`, §9).
7. Donor metres per cell and surface LOD remain UNVERIFIED (`DTRN_02:116,115`);
   no absolute donor-vs-port steepness claim is possible.
8. Donor parity of hue, grain, relief silhouette and luma is blocked on a donor
   GPU A/B; none exists. **No parity claim.**

---

## 8. Summary

Read-only diagnosis of the **live** skirmish terrain path. Confirmed: the
`features.terrain.relief_stamps` switch (now `true` at `config.json:29`) gates
only `main.gd:788-803`, i.e. one key in a `--dump-map` JSON. Live boot
(`world3d.gd:635-639`) feeds `world3d_terrain.gd` a dump synthesized from
`game.height` (`world3d_terrain.gd:916-953`) with **no** marker, so the
RELIEF-01/02 donor-grid path is inert in the live renderer.

Live `game.height` is shaped by `game.gd:_shape_stamp_relief()`
(`game.gd:870-993`, called at `:1092`) using **analytic radial/taper profiles**
over donor *footprints*, plus band-decoded base heights (`mapgen.gd:63-73`) and
parabolic domes (`game.gd:1042-1055`). No donor float32 relief grid
(`plt2`/ravine/plateau) reaches live height: `donor_patterns.json` holds only
`w/h/cells`, `Stamp` has no grid field, and `game.gd:871-875` still says the
height fields are "undecoded". Height is then overwritten/clamped at
`game.gd:993` and again at `:1099-1109`, flattening caps to ≈2.96.

Ranked causes: (1) flag is dump-only — CONFIRMED, explains why "relief on" does
not change live terrain; (2) no donor grid in the live height path — CONFIRMED,
the primary reason donor hills are missing; (3) later clamping flattens caps —
CONFIRMED mechanism; (4) `test7/8` tile-id art authored into flat cells by donor
detail bitmaps/smoothing — CONFIRMED mechanism, best explanation for the pale
marks, attribution UNVERIFIED; (5) analytic domes are tiny at map scale —
CONFIRMED source; (6) `rock8/rock4` refuted as flat-land marks (height-gated);
(7) alpha seam UNVERIFIED.

Smallest discriminating probe: find a seed whose flag-on dump contains a `plt2`
marker, then decode that dump's `height` min/max and `tileblock` histogram
(ids 78/79/80/20/24/0) inside the `plt2` window, cross-checked against local
`|dh|`. Single owner file for a fix: **`variant3d/scripts/game.gd`** — consume a
donor-derived grid in `_shape_stamp_relief()` and reconcile the later clamp;
no synthetic noise or fabricated hills. **No file was edited; no runner job was
submitted; no donor parity claim.**

---

*End of RELIEF-LIVE-DIAG-01. Read-only diagnosis; one report written; no code, asset, config, test, shader, JSON, PNG or git change; no Godot job; no donor access.*
