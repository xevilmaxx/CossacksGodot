---
id: DTRN-04
owner: DTRN-04
swarm: coord_swarm_2026-11-25
date: 2026-11-25
scope: donor-read-only research; one report; no code, config, asset, test or Godot edits
donor: "C:\\Games\\Cossacks 3 (bytes read via Python latin-1; never run, never copied)"
verification: "two independent passes: A = direct file:line read; B = regex/byte structured re-parse of the same files"
labels: [DONOR_TRUTH, TREES, FOREST, PLACEMENT, VARIANT3D, ISOLATED_TEST]
---

# DTRN-04 — Donor TREES / FOREST decor placement and appearance

## 1. Goal

Extract donor truth for tree/forest **decor** — species/assets, placement, density, clustering,
scale/jitter, rotation, LOD/second frame, terrain-height and passability interaction, and the
visual role of trees against ground quality — and state exactly what variant3d has, lacks or gets
wrong. Secondary: cross-check the 2D port (`app/scripts/world.gd`) only where it informs the 3D
fix. Produce a concrete fix recipe and precise acceptance criteria for the isolated
"terrain + trees" 64² test row (TEST-01 P1). Research only; no code edits.

All donor paths below are relative to `C:\Games\Cossacks 3\`. Port paths are relative to the
project root. Tags: **observed** (read directly), **derived** (computed from observed values),
**inferred** (interpretation), **UNVERIFIED** (could not be confirmed read-only).

## 2. Sources

**Donor (read-only, two passes):**
`data\game\var\envscales.cfg`; `data\game\var\generator.cfg`;
`data\scripts\common.inc\dogenerate.inc`; `data\scripts\lib\misc.script`;
`data\scripts\common.inc\texturemap.inc`; `data\scripts\common.inc\smoothforestborders.inc`;
`data\scripts\common.inc\loadenvironmentfrombitmap.inc`;
`data\pattern\pattern.lib` (sections `e_frt_big_1`, `g_frt_big_1`, `n_small_frt_1`, `dcr1`, `fb_1`);
`data\actors\env\*.actor` + `*.osm`; `data\actors\ref\reftree.actor`;
`data\actors\ref\refobj.actor`; `data\objects\env\*.prop`; `data\objects\ref\refenv.prop`;
`data\materials\env\*.dds`; `data\shaders\obj\tree.ppl.id6.{vert,frag}`.

**Orientation docs (given):** `docs/audit/PIECES/forest_broadleaf.md`, `forest_conifer.md`,
`bushes_understory.md`, `map_density.md`, `verdict_decor.md`;
`docs/audit/TERRAIN_PORT_DECOR.md`;
`docs/coord_swarm_2026-11-24/reports/W27_ambient_beds.md`, `V763_missing_models.md`,
`V772_import_new_objs.md`; plus `docs/coord_swarm_2026-11-25/reports/TEST_01_smallmap_harness.md`
(for the isolated-test row).

**Port code read only:** `variant3d\scripts\world3d_entities.gd`, `world3d.gd`, `game.gd`,
`pattern_gen.gd`; `variant3d\assets\models\manifest.json`; `app\scripts\world.gd` (2D secondary).

## 3. Claim table

| # | Claim | Evidence (`path:line`) | Tag / verdict |
|---|-------|-------------------------|---------------|
| C1 | 15 tree/decor actor families exist as authored mesh banks: oak 4, burch 6, leaftree 4, fir 4, firsmall 4, pine 4, pinesmall 4, pinedry 4, spruce 4, drytree 4, decortree1/2/3 3 each, pinestump 4, burchstump 4 | `data\actors\env\oak.actor:1-16`, `burch.actor:1-26`, `leaftree.actor:1-16`, `fir.actor:1-16`, `firsmall.actor:1-16`, `pine.actor:1-16`, `pinesmall.actor:1-16`, `pinedry.actor:1-16`, `spruce.actor:1-16`, `drytree.actor:1-16`; pass B regex mesh counts | **observed**, PASS×2 |
| C2 | All tree actors inherit `reftree.actor` → shader ID 6 (`tree.ppl/pvl.id6`) | `data\actors\env\pine.actor:1`, `spruce.actor:1`; `data\actors\ref\reftree.actor:1-5` | **observed** |
| C3 | Per-variant scale ladder is family-specific: fir/firsmall/spruce 0.5; pine 0.475; pinesmall 0.55/0.535/0.56/0.61/0.5; pinedry 0.65/0.618/0.706/0.76/0.5; leaftree 0.425×4 + 0.504; burch 0.38/0.374/0.366/0.341/0.415/0.434/0.354 | `data\game\var\envscales.cfg:158-188`, `:193-223`, `:228-258`, `:263-293`, `:368-398`, `:403-433`, `:473-503`, `:508-550` | **observed**, PASS×2 |
| C4 | Jitter is ±15 % (`minscale=0.85`, `maxscale=1.15`) for every tree/bush group; grass groups use ±5 % | `data\game\var\envscales.cfg:162-164`, `:267-269`, `:371-374`, `:511-513`, `:594-596` | **observed** |
| C5 | Pattern placement is `needed=floor(W*H*freq)`, `trycount=floor(256*mapsizeoptimise)`, 320×320 ⇒ 256 tries, Freq damped ×0.2 (floor 0.0001) per placement | `data\scripts\lib\misc.script:3681-3704`, `:3590`, `:3614-3618` | **observed** |
| C6 | No-overlap is cell-mask based: `gPatternMask`, 4-step fast reject, rotated-mask support; forest masks use `PatternMaskStand=False, PatternMaskReverceStand=True` | `data\scripts\lib\misc.script:3384-3390`, `:3441-3472`, `:3491-3508`; `data\pattern\pattern.lib:209312-209313` | **observed** |
| C7 | Per-cell small-forest detail (`n_small_frt_1..24`, `_lite_` variants) fills forest cells not already claimed by a pattern; `cLiteProb=0.6`; conifer ind 1–17, mixed/leaf ind 18–24 with leaf exclusions | `data\scripts\common.inc\texturemap.inc:209-216`, `:220-336`, `:296-319` | **observed** |
| C8 | Forest-edge clumps `fb_1..fb_53` are placed on cells with exactly one forest neighbour; 1–16 tries per cell, ±1.5-cell jitter; `grass5`/`rock9` fringe tiles; only for `forestType=0` (conifer) | `data\scripts\common.inc\smoothforestborders.inc:36-69`, `:100-125`, `:127-148`; `texturemap.inc:356-360` | **observed** |
| C9 | Pattern header fields: `RotationAngle=0`, `ObjectsScale=1`, `HeightFieldStand=True`, `HeightFieldSmooth=False`, `CollisionStand=True`, `NativeSeason=Summer`, all four season flags True; each object stores authored `Position/Direction/Up/Scaling` | `data\pattern\pattern.lib:209292-209329`, `:323713-323...`, `:382653-382...` | **observed**, PASS×2 |
| C10 | Authored yaw is baked per object in `Up` (X=cosθ, Z=−sinθ); `e_frt_big_1` has 200 distinct yaw values, `g_frt_big_1` 101, `n_small_frt_1` 10 | derived from `data\pattern\pattern.lib` object blocks (`e_frt_big_1:209291-218095`, `g_frt_big_1:323713-328429`, `n_small_frt_1:382653-382973`) via `atan2(-Z,X)`; pass B re-parse | **derived**, PASS×2 |
| C11 | Per-object scale inside a forest pattern is authored 0.165–0.71 (`e_frt_big_1`), 0.259–0.558 (`g_frt_big_1`), before envscales jitter | same sections as C10; `Scaling` structs | **derived**, PASS×2 |
| C12 | Tree meshes have exactly one animation frame (`FRAME 000`) and one mesh LOD (`DistanceMin=0, DistanceMax=150`, `ScaleFrames=1`); imposter off (`Impostered=False, ImposterFrame=0`); `AnimationMode=aamNone`, `Interval=33` ms; winter is a *material* swap, not a second mesh frame | `data\actors\env\pine1.osm` byte scan (1 `FRAME`); `oak1.osm`, `spruce1.osm`, `fir1.osm`, `burch1.osm`, `leaftree1.osm` same; `data\actors\env\pine1.actor:1-16`; `data\actors\ref\refobj.actor:76-84`, `:88-109`; `data\objects\env\pine1.prop:33-43`, `:106-115` | **observed**, PASS×2 |
| C13 | Trees participate in collision/passability: forest patterns `CollisionStand=True`; env props carry collision mesh + inertia collision; building placement rejects wood nodes within `envRad` unless near an existing building; co-located collision objects are destroyed to avoid pathfinding jams | `data\pattern\pattern.lib:209314`; `data\objects\ref\refenv.prop:39-121`; `data\scripts\lib\misc.script:3739-3780`, `:4640-4661`, `:4971-4975`, `:5004-5033`; `data\objects\env\pine1.prop:102-104` (`CategorieName=resources`) | **observed** |
| C14 | Terrain quality is coupled to forest density: the environment bitmap's green channel maps forest density to `grass1` (light), `grass6`/`rock9` (dense) with `_winter` suffix in winter | `data\scripts\common.inc\loadenvironmentfrombitmap.inc:27-76`; `smoothforestborders.inc:127-148` | **observed** |
| C15 | Winter removes leaf trees and clamps scales toward the authored min/max band in a post-generation pass | `data\scripts\common.inc\dogenerate.inc:1971-2027` (`:1977-1981` leaf removal, `:1990-2026` scale clamp) | **observed** |
| C16 | Global forest families are forced to `foreststype=0` (pine/fir/spruce); leaf/mixed families exist in cfg but are only called for foreststype 1/2, which vanilla disables | `data\scripts\common.inc\dogenerate.inc:5-6`, `:1836-1896`; `data\game\var\generator.cfg:909-1288` | **observed** |
| C17 | variant3d exposes 22 tree-ish env sids on disk but its runtime `POOL_TREE` has only 6, all res nodes use one `ENV_SCALE["tree"]=0.5`, and res-node yaw is always 0 | `variant3d\scripts\world3d_entities.gd:113-118`, `:326-333`, `:721-727`, `:1094-1121`, `:1269-1291`; `variant3d\assets\models\manifest.json` env list | **observed** |
| C18 | variant3d has no forest bake/decor stand pass: trees exist only as harvestable `wood` res nodes; `invalidate_forest_bake()` is a NO-OP | `variant3d\scripts\world3d_entities.gd:1294-1315`; `variant3d\scripts\world3d.gd:795-797`; `variant3d\scripts\game.gd:584-609`, `:752-777` | **observed** |
| C19 | 2D port has three size buckets, ±0.13 rad yaw/mirror, 14 % broadleaf share and 1–3 trees per forest cell (≈1953/MP, 2–3× donor dense) | `app\scripts\world.gd:1376`, `:1410`, `:1414-1427`, `:1472-1506` as cited in `docs/audit/PIECES/forest_conifer.md:107-123`; `map_density.md:190-204` | **observed** (docs), 2D secondary |
| C20 | Donor dense forest is 650–1000 trees/MP; rim 150–250; whole-map coverage 17–48 % inferred from donor freq vs port 0.94 % | `docs/audit/TERRAIN_REFERENCE_IMAGES.md:176`; `docs/audit/PIECES/map_density.md:117-204`, claim 9 | **observed** targets / **inferred** coverage |

**Unverified items:** exact semantics of the last two args of `StandPatternWithAngle(..., 0, 90)`
(no donor source found; `misc.script:3390`); runtime `prob{small,mid,large,huge}` values sampled
from the free mask (`dogenerate.inc:1774-1776`); donor placement success rate under `trycount`;
whether shader ID 6 applies wind motion (`tree.ppl.id6.vert` contains no `wind`/`frame`/`time`
tokens, but engine-side behaviour unobservable read-only); engine-side height snap of patterned
trees (`Position.Y=0` in `pattern.lib`, no explicit `RayCastHeight` for env objects found).

## 4. Donor tree inventory

### 4.1 Mesh/actor banks (`observed`, pass A + B)

Tree-relevant actor families under `data\actors\env\` (each `.actor` references a shared ref actor
and lists N `.osm` meshes, one per authored variant):

| Family | Variants | Mesh files | Scale group (`envscales.cfg`) |
|--------|---------:|-----------|-------------------------------|
| `oak` | 4 | `oak1..4.osm` | no dedicated group → default 1 (see note) |
| `burch` (birch) | 6 | `burch1..6.osm` | `burch` `:508-550` |
| `leaftree` | 4 | `leaftree1..4.osm` | `leaftree` `:473-503` |
| `fir` | 4 | `fir1..4.osm` | `fir` `:158-188` |
| `firsmall` | 4 | `firsmall1..4.osm` | `firsmall` `:193-223` |
| `pine` | 4 | `pine1..4.osm` | `pine1` `:228-258` |
| `pinesmall` | 4 | `pinesmall1..4.osm` | `pinesmall1` `:263-293` |
| `pinedry` | 4 | `pinedry1..4.osm` | `pinedry1` `:403-433` |
| `spruce` | 4 | `spruce1..4.osm` | `spruce1` `:368-398` |
| `drytree` | 4 | `drytree1..4.osm` | — |
| `decortree1/2/3` | 3+3+3 | `decortree11..33.osm` | — |
| `pinestump`, `burchstump` | 4+4 | `pinestump1..4.osm`, `burchstump1..4.osm` | `:438-468`, `:555-585` |

Evidence: `data\actors\env\oak.actor:1-16`, `burch.actor:1-26`, `leaftree.actor:1-16`,
`fir.actor:1-16`, `firsmall.actor:1-16`, `pine.actor:1-16`, `pinesmall.actor:1-16`,
`pinedry.actor:1-16`, `spruce.actor:1-16`; envscales line ranges as in the table.
**Note:** `oak` is not a named group in `envscales.cfg`; its per-instance scale therefore comes
from the pattern's authored `Scaling` (e.g. `g_frt_big_1` 0.259–0.558) plus the post-gen clamp
(`dogenerate.inc:1990-2026`), or the prop's own `scaleproperty` — **UNVERIFIED** which one wins
for oak. All tree actors inherit `reftree.actor` → shader ID 6
(`data\actors\env\pine.actor:1`; `data\actors\ref\reftree.actor:1-5`).

Textures: paired summer/winter albedos exist for every mesh family, e.g.
`data\materials\env\pine1.dds` / `pine1w.dds`, `spruce1.dds` / `spruce1w.dds`,
`oak1.dds` / `oak1w.dds`, `burch1.dds` / `burch1w.dds`; props switch via
`UseSeasonMaterial=True` + `UseableSummerMaterials` / `UseableWinterMaterials`
(`data\objects\env\pine1.prop:33-43`, same shape in `oak1.prop:33-43`). Forest-floor textures
`grassforest.dds`/`grassforestw.dds` and `grassleafforest.dds`/`grassleafforestw.dds` exist in
`data\materials\env\`.

### 4.2 Pattern/forest banks (`observed`)

`data\game\var\generator.cfg` forest families and member counts (structured re-parse):

| Family | Members | First/last | cfg line |
|--------|--------:|-----------|----------|
| `forests_pinefir_big` | 6 | `d_frt_big_1` … `e_frt_big_3` | 909 |
| `forests_pinefir_medium` | 6 | `d_frt_mid_1` … `d_frt_mid_6` | 938 |
| `forests_pinefir_small` | 6 | `d_frt_small_1` … `d_frt_small_6` | 967 |
| `forests_spruce_big` | 4 | `d_frt_spr_big_1..4` | 996 |
| `forests_spruce_medium` | 4 | `d_frt_spr_mid_1..4` | 1018 |
| `forests_pinedrygreen_small` | 4 | `d_frt_pinedry_big_1..4` | 1040 |
| `forests_pine_small` | 6 | `frt_s_p_1..6` | 1062 |
| `forests_pine_medium` | 10 | `frt_m_p_1..10` | 1091 |
| `forests_pine_big` | 8 | `frt_b_p_1..f1_from_big3` | 1136 |
| `forests_pine_big_2` | 3 | `b_frt_b_p_1..3` | 1174 |
| `forests_mixed_big` | 3 | `e_frt_big_1`, `_2`, `_4` | 1191 |
| `forests_mixed_medium` | 5 | `e_frt_mid_1..5` | 1208 |
| `forests_leaf_big` | 2 | `g_frt_big_1`, `_2` | 1233 |
| `forests_leaf_medium` | 2 | `g_frt_mid_1`, `_2` | 1247 |
| `forests_leaf_small` | 6 | `g_frt_small_1..6` (`:1264-1285`) | 1261 |

All members `Freq=1` (`generator.cfg:1190-1288`). Desert families add 17+23+20+24 members
(`:2006`, `:2079`, `:2176`, `:2261`). Decorator patterns: `dcr1..3`, `fb_1..fb_53`,
`n_small_frt_1..24` + `n_small_frt_lite_*` (`data\pattern\pattern.lib:39186`,
`:533098`, `:382654`, `:607670`).

## 5. Placement algorithm (donor truth)

1. **Forest type selection** — random 0..2 is immediately overwritten to `foreststype := 0`
   (`dogenerate.inc:5-6`). So global generation uses conifer families; leaf/mixed family calls
   exist only in cases 1/2 of the same switch (`:1836-1896`) and are dead in vanilla.
2. **Frequency model** — base `frs_big=0.0009`, `frs_mid=0.0009`, `frs_small=0.00054`
   (`dogenerate.inc:1688-1690`), multiplied by runtime `prob{small,mid,large,huge}` sampled from
   the free mask (`:1774-1778`, `misc.script:3878-3941`), halved on desert (`:1780-1785`). Calls:
   big `frs_big/8` (`:1838-1841`), medium `frs_mid/6` (`:1855-1857`), small `frs_small/4`
   (`:1866-1867`). `needed=floor(W*H*freq)` and `trycount=floor(256*mapsizeoptimise)` at
   `misc.script:3695`, `:3704`. At 320²: 115 stamps (prob=1) / 236 (size modifier ×2)
   (`map_density.md:142-155`).
3. **Pattern choice** — weighted by per-member `Freq` (`misc.script:3634-3647`); after a
   successful stand, that member's Freq is multiplied by 0.2 (floor 0.0001,
   `misc.script:3590`, `:3614-3618`) so one family does not repeat the same mask.
4. **Standing a pattern** — random integer cell `(x,y)` in `[-W/2, W/2)` (`misc.script:3714-3715`),
   then `_misc_CheckStandPatternExt` (`:3516-3520`) does a reject test and, on success, writes the
   mask and returns the objects via `StandPatternWithAngle(plHnd, patName, x, z, angleRad, 0, 90)`
   (`:3390`). Rejection is per masked cell: out-of-bounds or already occupied ⇒ false
   (`:3499-3508`); a 4-step sampled fast path rejects earlier (`:3441-3472`). **No explicit
   min-distance constant exists** — separation is the no-overlap mask plus the authored mask
   footprint (derived; the `90` argument's meaning is UNVERIFIED).
5. **Per-cell detail** — after big stands, every unclaimed `cGForest` cell gets a small pattern:
   conifer `n_small_frt_1..17`, mixed 18..24, leaf 18..24 with 22/23 re-rolled and 22→24
   (`texturemap.inc:220-336`, esp. `:296-319`). `cLiteProb=0.6` picks the lighter variant
   (`:312-319`). This is the donor's **clustering**: large authored stands plus a light per-cell
   fill, not a uniform grid or a Poisson disc.
6. **Forest edge** — cells with exactly one forest neighbour (channel g∈{2,3}, r=0) are fringe
   (`smoothforestborders.inc:36-69`); for forestType 0 only, 1–16 `fb_1..fb_53` clumps are tried
   at ±1.5 cells jitter (`:100-125`), each with 1–3 `grass5`/`rock9` tiles (`:127-148`). Types 1/2
   get no fringe (`pname` stays empty, `:111-116`).
7. **Season pass** — winter removes all objects whose basename contains `leaftree`
   (`dogenerate.inc:1975-1981`); surviving objects are clamped into their authored min/max scale
   band using `GetGameObjectDefScalePropsByHandle` (`:1988-2026`); Z scale is corrected when
   `z<>x` (`:2025-2026`).
8. **Determinism** — no persistent RNG in the render pass; placement uses seeded `RandomExt`
   (`misc.script:3714-3715`) and position hashes. This is the donor analogue of the port's
   deterministic hash approach (inferred).

### Constants to carry into the port

| Constant | Value | Source (`path:line`) |
|----------|-------|----------------------|
| Tree jitter | `minscale=0.85`, `maxscale=1.15` (±15 %) | `envscales.cfg:162-164` |
| Grammar jitter | `0.95..1.05` | `envscales.cfg:594-596` |
| Spruce / fir / firsmall | base 0.5 | `envscales.cfg:371-374`, `:161-164`, `:196-199` |
| Pine / pinesmall | 0.475 / 0.55,0.535,0.56,0.61,0.5 | `envscales.cfg:231-234`, `:266-292` |
| Pinedry / leaftree / burch | 0.65,0.618,0.706,0.76,0.5 / 0.425×4,0.504 / 0.38,0.374,0.366,0.341,0.415,0.434,0.354 | `envscales.cfg:406-432`, `:476-502`, `:511-549` |
| `needed`, `trycount` | `floor(W*H*freq)`, `floor(256*mapsizeoptimise)` | `misc.script:3695`, `:3704` |
| Freq damping | ×0.2, floor 0.0001 | `misc.script:3590`, `:3615-3617` |
| Mask fast-test step | 4 cells | `misc.script:3441` |
| Small-detail light probability | 0.6 | `texturemap.inc:312-317` |
| Border clump count / jitter | 1–16 tries, ±1.5 cells, `fb_1..fb_53` | `smoothforestborders.inc:104-125` |
| Mesh LOD / shader LOD | `0..150` m / `0..2500` m | `refobj.actor:93-95`, `:46-49` |
| Imposter / animation | off / `aamNone`, interval 33 ms | `refobj.actor:76-84`, `:107-108` |
| Building height tolerance | `cHeightDelta=0.275` m | `misc.script:4645`, `:4985-4995` |
| Collision dedupe epsilon | 0.001 m | `misc.script:3749-3770` |

### Rotation, LOD and "second frame" (`observed`/`derived`)

- Pattern-level `RotationAngle=0` (`pattern.lib:209307`); per-object yaw is authored into the
  `Up` vector, giving 200/101/10 distinct yaw values in the three patterns examined (C10).
- `scaleproperty.RandomScale=True` with per-prop factors (pine1: 0.95–1.15,
  `pine1.prop:106-115`); `directionupproperty.RandomRollAngle=True`, `DeltaRollAngle=1` degree
  (`pine1.prop:117-120`) — roll/tilt, **not** yaw.
- No second geometry frame: one `FRAME 000` per `.osm` (byte-verified on 8 tree meshes), one
  LOD entry, imposter off, no `wind`/`frame`/`time` token in the tree vertex shaders. Winter is
  a second **material** set (`UseableWinterMaterials`, `pine1.prop:39-43`), and leaftrees are
  destroyed in winter (`dogenerate.inc:1977-1981`).

### Terrain height, passability and ground quality

- Trees are placed at `Position.Y=0` inside patterns (`e_frt_big_1` object blocks); the engine
  resolves height from the heightfield via `StandPatternWithAngle` (engine-side, UNVERIFIED);
  units explicitly use `RayCastHeight` (`dogenerate.inc:103`, `:201`). Building placement samples
  `RayCastHeight` and rejects >0.275 m spread (`misc.script:4985-4995`).
- `CollisionStand=True` on forest patterns (`pattern.lib:209314`); env props have collision mesh
  and inertia collision enabled with AABB `(−0.5,−0.1,−0.5)..(0.5,2.0,0.5)`, sphere 0.32,
  `CIIntersectRadius=0.16` (`refenv.prop:73-121`); co-located collision objects are deleted so
  pathfinding does not jam (`misc.script:3739-3780`). Wood resource nodes block building
  placement at `envRad` unless near an existing building (`misc.script:5004-5016`, `:5029-5033`).
- Trees are categorized as `resources` (`pine1.prop:102-104`), i.e. harvestable, not pure decal.
- Ground quality is density-driven: light forest `grass1`, dense forest `grass6`/`rock9`, forest
  border `grass5`/`rock9` (`loadenvironmentfrombitmap.inc:27-76`,
  `smoothforestborders.inc:127-148`). This is the donor reason dense woods read darker/rockier;
  port's single forest-floor block has no such coupling.

## 6. What variant3d has / missing / wrong

**Has:**
- 22 tree-ish donor-derived OBJ/MTL/PNG sids on disk and imported (manifest env=93;
  `V772_import_new_objs.md:91-97`), including 4 spruce, 4 pinesmall, 4 firsmall, 4 pinedry,
  pine, fir, oak, 4 stumps, 2 christmastree.
- `_world_pos` snaps entity Y to `game.height_at()` (`world3d_entities.gd:1074-1079`).
- Wood/bush/stump res nodes are drawn via MultiMesh batches with a deterministic position hash
  (`world3d_entities.gd:1269-1315`). Wood nodes block via `set_blocked_circle` while bush/stump
  do not (`game.gd:508-519`, `:611-613`) — matches donor decor-vs-resource split.
- Generator already raises forest density: `core_r = clamp(cext*0.25, 14*TILE, 22*TILE)*size_k`,
  per-cell wood probability 0.30, cap 14 (`game.gd:717-718`, `:759-777`).

**Missing / wrong:**
1. **Species breadth in the live pool** — `POOL_TREE` has 6 sids, no birch/leaftree/decortree,
   no firsmall/pinesmall variants (`world3d_entities.gd:114-115`; manifest env list). Donor has
   14+ mesh variants per mixed stand (`pattern.lib:209291-218095`).
2. **One size for all trees** — `ENV_SCALE["tree"]=0.5` applied to every sid whose name starts
   with `tree` (`world3d_entities.gd:113`, `:326-333`, `:721-727`). Donor ladder is 0.341–0.76
   with per-variant jitter and authored per-object scaling (C3, C11). Result: spruce/pine/fir/oak
   all same apparent height; no canopy tiers.
3. **No rotation for decor** — `_xf()` sets yaw only for class `unit`; res nodes keep yaw 0
   (`world3d_entities.gd:1094-1121`). Donor bakes arbitrary yaw per object (C10); the 2D port at
   least applies ±0.13 rad + mirror (`app\scripts\world.gd:1425-1427`).
4. **No forest stand/decor pass at all** — trees exist only as resource nodes;
   `invalidate_forest_bake()` is a NO-OP (`world3d.gd:795-797`); no `n_small_frt_*`,
   `fb_*`, forest-edge fringe or season material swap anywhere in variant3d scripts. Forest
   "clusters" are uniform-random points in a disc (`game.gd:584-609`, `:752-777`), not donor
   authored masks.
5. **No winter/season variant** — `_default_material` loads one `tex/<sid>.png`
   (`world3d_entities.gd:336-343`); donor swaps to `*_w.dds` and removes leaftrees.
6. **Ground coupling absent** — no density→grass/rock tile selection in 3D terrain; forest-floor
   tone does not darken with canopy.

2D secondary: `world.gd` has particles of truth the 3D port lacks (14 % broadleaf, 3 size
buckets, yaw/mirror, blob shadow) but the same blue-deficit sprite-bake problem
(`verdict_decor.md:177-182`, `:350-357`; `forest_broadleaf.md:112-123`). Do not solve donor
palette by a render-time tint: donor albedos are the truth source.

## 7. Fix recipe (file-scoped, research proposal; no edits made)

- **F1 — per-family scale ladder + jitter** (`variant3d\scripts\world3d_entities.gd:113`,
  `:326-333`, `:721-727`). Replace single `tree=0.5` with a map keyed by donor family:
  spruce 0.5, fir 0.5, firsmall 0.5, pine 0.475, pinesmall 0.55/0.535/0.56/0.61/0.5,
  pinedry 0.65/0.618/0.706/0.76/0.5, leaftree 0.425/0.504, burch 0.341–0.434. Apply a
  deterministic ±15 % `hash(pos)` jitter (pass A/B donor evidence C3/C4). Acceptance: per-tree
  rendered heights span ≥3 separated buckets, all scales within `[0.85,1.15]×base`.
- **F2 — yaw + mirror for res decor** (`world3d_entities.gd:1094-1121`). For class `res`
  with `type=="wood"`, set `yaw = (hash(pos)*2−1)*PI` (donor uses full 360° authored yaw; 2D
  port's ±0.13 rad is a weaker proxy), plus deterministic mirror by negating local X for half
  the hashes. Keep units' `PI/2−face` path byte-identical. Acceptance: ≥6 distinct 30°-yaw bins
  in a 16-tree sample; unit transform test unchanged.
- **F3 — authored stand geometry** (`variant3d\scripts\game.gd:752-777`, `pattern_gen.gd`).
  Add a separate decor pass that places trees from donor pattern cells (already parsed in
  `donor_patterns.json`) into a tree-decor array distinct from `res_nodes`; use per-cell authored
  `BaseName`, scale and yaw where available, else hash; keep the existing wood nodes as the
  harvestable overlay. Preserve the 7-tile start ring and the 14–22-tile core radius. Acceptance:
  forest-cell coverage ≥15 % and ≥40 forest components of ≥10 cells for a 320² seed sweep,
  with wood node count unchanged for the generation seed (no double-counting).
- **F4 — winter variant** (`world3d_entities.gd:336-343`, `:1294-1315`). Load `<sid>w.png` when
  available under the season key; drop `tree_oak`/leaftree sids in winter. Acceptance: winter
  screenshot shows no broadleaf tree and a different material; summer PNG byte-identical.
- **F5 — height/passability preservation** (`world3d_entities.gd:1074-1079`, `game.gd:508-519`).
  Keep Y from `height_at()` for every new decor instance; never add blocked circles for
  non-wood decor. Acceptance: base Y error <1e-3 m; `is_blocked()` true only for wood nodes.
- **F6 — 2D parity only, separate owner** (`app\scripts\world.gd:1410`, `:1376`, `:1423-1427`,
  `:1472-1506`; sprite PNGs). Blue-lift sprite rebakes and raise broadleaf share from 14 % to
  30–50 %; do not change 3D meshes for a 2D palette problem. Evidence:
  `verdict_decor.md:350-357`.

## 8. "Terrain + trees" isolated piece test — precise criteria

Use TEST-01 P1 (`docs/coord_swarm_2026-11-25/reports/TEST_01_smallmap_harness.md:212-214`):
same 64² stub as P0, windowed capture, no units/buildings/water, seed fixed.

| # | Criterion | Target | How to measure | Source / tag |
|---|-----------|--------|----------------|--------------|
| T1 | Structural non-regression vs P0 | surfaces=1, verts=4096, tris=7938, UV2=4096, UV2.y⊂{0,1,2}, promoted=0, no full-width dark rows | stub telemetry + `smallmap_capture.py stats` | TEST-01 P0/P1; **observed** harness |
| T2 | Tree count / category purity | `Batch_*_res` instances == N; N=12–16 for donor-dense band (650–1000/MP on 64²×2 m = 128 m square ⇒ 10.7–16.4 trees); N=20 allowed only as labelled stress case; 0 stone/ore/stump/food | instance counter from `world3d_entities.sync()` stats | `TERRAIN_REFERENCE_IMAGES.md:176`; **derived** |
| T3 | Scale ladder | ≥3 separated rendered-height buckets; every scale ∈[0.85,1.15]×family base from F1; no two species share one base | transform dump per instance | `envscales.cfg:158-188` etc; **observed** target |
| T4 | Rotation | ≥6 distinct 30° yaw bins (or explicit note if F2 not implemented ⇒ current 1 bin = FAIL) | transform basis azimuth | C10; **derived** target |
| T5 | Height snap | every tree base Y == `game.height_at(pos)` ±1e-3 m; 0 trees below water level | stub `height` array vs instance transforms | `world3d_entities.gd:1077-1079`; **observed** |
| T6 | Passability | `is_blocked(pos)` true for all wood nodes; false for any non-wood decor added by F3 | game query on known positions | `game.gd:508-519`; **observed** |
| T7 | Ground coupling | P0-vs-P1 PNG difference mask is confined to tree footprints + shadows; ground mean unchanged outside mask; no opaque black rectangles | Pillow diff on the two PNGs, temp only | C14; **derived** |
| T8 | Determinism | two identical-seed runs ⇒ byte-identical PNG and identical instance transform list | SHA-256 of PNG + JSON transforms | donor seeded generation; **inferred** |
| T9 | No script errors | `smallmap_capture.py scan-stderr` reports 0 `SCRIPT ERROR` | runner stderr | TEST-01; **observed** |
| T10 | Visual review | second agent confirms distinct conifer/broadleaf silhouettes, layered canopy, no repeated single outline, shadows at tree base, ground not washed out; donor hex anchors for 2D cross-check only (conifer hue 58–69°, B/G≥0.40) | visual A/B, no numeric gate in 3D (lighting differs) | `forest_conifer.md:44-58`, `verdict_decor.md:287-298`; **inferred** |

Pass rule: T1–T9 must all be true; T10 is a documented second-agent judgement, not self-pass.
This row must run **before** any combo row; do not use the CLI `--dump-map` map dump (it is the
2D generator path) to judge the 3D stub.

## 9. Open questions

1. What do the `0, 90` arguments of `StandPatternWithAngle` mean, and does the 90 impose a height
   difference limit? (`misc.script:3390`.) Affects T5 tolerance.
2. Runtime `prob*` values from `misc.script:3931-3941` were not re-derived read-only; donor stamp
   counts 115 vs 236 are a bracket, not a point.
3. Does shader ID 6 animate trees (wind)? Shader source has no frame/time tokens; renderer-side
   behaviour UNVERIFIED. If it does, variant3d's static bind pose is additionally wrong.
4. Is `oak` scale governed by its prop, by pattern `Scaling`, or by a default group not found in
   `envscales.cfg`? (C3 note.)
5. Are donor forest-pattern trees the same harvestable wood nodes as `res_nodes`, or separate
   collision props with a parallel resource link? `pine1.prop:102-104` suggests resources; exact
   linkage UNVERIFIED.
6. Should F3 place decor trees into a new array or reuse wood nodes with a decor flag? Impacts
   T2/T6 purity and the blocked-circle semantics.

## 10. Summary

Donor trees are **authored, multi-variant, multi-family meshes** placed by a two-level algorithm:
big forest patterns stamped with `needed=floor(W*H*freq)`/256 tries and a no-overlap cell mask,
then per-cell `n_small_frt_*` fill (60 % lite) and conifer-only `fb_*` edge clumps. Each tree
carries an authored yaw, an authored scale, a family-specific envscale and ±15 % jitter; one
mesh frame, one LOD, winter is a material swap plus leaftree removal. Trees are collidable
resource props, snapped to the heightfield, and the ground tile darkens/rockifies with forest
density.

variant3d has the donor OBJ assets but uses only 6 of 22 tree sids, collapses all species to one
0.5 scale, never rotates resource decor, has no forest-stand/decor pass, no season swap and no
ground-density coupling. Minimum fixes: per-family scale+jitter (F1), hashed yaw/mirror (F2),
an authored stand/decor pass separate from harvestable wood nodes (F3), and winter materials
(F4). The isolated 64² P1 test above measures count, purity, scale, yaw, height snap, passability,
ground diff, determinism and stderr before any combo row. No code was edited by this ticket.
