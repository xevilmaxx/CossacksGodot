---
id: DTRN-05
title: "Donor MINES / resource nodes — display, placement, scale and jitter"
owner: DTRN-05
date: 2026-11-25
scope: "RESEARCH ONLY. One new file: this report. No code/asset/config/test/git edit. Donor read read-only via Python bytes/latin-1; no donor binary copied into the repo, no donor game run."
status: DONE__3_PASSES__DONOR_TRUTH__PORT_GAP__NO_VISUAL_PARITY_CLAIM
labels: [DONOR_TRUTH, MINES, RESOURCE_NODES, ENVSCALES, PATTERN_STAMPS, BUILT_MINE, SMALL_MAP_TEST]
verification: "Independent passes: P1 filename/text inventory; P2 prop/actor/cfg/script line reads; P3 binary .pattern decode, .osm geometry parse, DDS pixel/UV correlation; P4 variant3d code + test-result read. Every headline claim re-checked at least twice."
donor_root: "C:\\Games\\Cossacks 3 (READ-ONLY)"
---

# DTRN-05 — donor MINES / resource nodes

## 1. Goal

Establish **donor truth** for Cossacks 3 mine/resource nodes — asset chain, on-ground
appearance, scale/jitter, placement algorithm, ownership/capture visuals and
map-generation counts — with `path:line` citations and evidence labels. Then
state what variant3d 4.x already implements, what is missing/wrong, and give a
concrete fix recipe plus an isolated **terrain + mines** piece-test criterion on
a small map. This report is the only deliverable; **no code was edited**.

Labels: **observed** (bytes/lines/pixels read here), **derived** (arithmetic on
observed values), **inferred** (plausible reading, not proven), **UNVERIFIED**
(do not promote without a donor run or a resolved table).

---

## 2. Sources

### 2.1 Donor (all under `C:\Games\Cossacks 3\data\`, private-use only)

| Role | Path | How read |
|---|---|---|
| Mine props | `objects/env/mine{gold,iron,coal}.prop`, `mine{gold,iron,coal}s.prop` | latin-1 lines 1–41 |
| Prop registry | `objects/env/env.objects` | latin-1 lines 2–4, 337–339 |
| Actors/meshes | `actors/env/mine{gold,iron,coal}.actor`, `.osm` (55,876 B each) | actor text 1–5; IDP2 header/verts via `convert_models.py:74-99` parser re-implemented read-only |
| Materials/textures | `materials/env/env.mat:378-435,715-770,1193-1236`; `materials/env/mine*.dds` (2,048² DXT5, 12 mips) | latin-1 lines; DDS header via `struct`; temp thumbnails in `%TEMP%\opencode\dtrn05_img\` (outside repo) |
| Mine scale | `game/var/envscales.cfg:1-70` (utf-8, 869 lines); whole-file grep for `name = mine` → 3 hits | line reads |
| Generator families | `game/var/generator.cfg:67-205` and `:1645-1735` (cp1251, 2,367 lines) | line reads |
| Patterns | `pattern/mng_1.pattern` etc. (3,730 B each) | `struct` header/mask + 24-byte record-chain decode |
| Placement script | `scripts/common.inc/dogenerate.inc:522-717` (`SetupMines`), `:720-805` (`SetupStartingResources`), `:980-988` (`CreateStartPoint`), `:1090-1230` (`RandomStartingPoints`), `:1544,1586-1587,1615,1768-1772`, `:1971-2027` (scale pass) | latin-1 line reads |
| Env object → resource | `scripts/env/env.inc/initial.inc:42-71,94-107` | latin-1 |
| Mines density UI/defaults | `gui/menu.inc/showcustomgame.inc:219-231`; `gui/menu.inc/initmapsettings.inc:12-15`; `scripts/common.inc/initmap.inc:29-31`; `scripts/lib/map.script:251-254`; `scripts/dmscript.global:240,955-957`; `locale/en/gui.txt:222-226,435-440` | latin-1/cp1251 |
| Built mines | `objects/buildings/{eurcoa,eurgol,euriro}.prop` (123 lines each); `objects/buildings/attach/eur{coa,gol,iro}*.prop`; `actors/buildings/commoneur/{eurcoa,eurgol,euriro}.actor`; `animations/aaf/{eurcoaanim,eurgolanim}.aaf` | latin-1; raw bytes for `.aaf` |
| Built-mine ground plate | `terrain/decals/decals.lib:142-163`; `terrain/decals/decals.mat:170-179,753-762`; `terrain/decals/buildings/eur*.dds` (1,024² RGBA) | latin-1; Pillow thumbnails in temp |
| AI/capture/ownership | `scripts/units/global.inc/progresseconomicai.inc:2892-2913`; `scripts/lib/unit.script:4731-4755,11337-11352`; `scripts/units/unit.inc/nothing.inc:507-519`; `scripts/lib/country.script:326-337,2864-2866`; `hotkeys.cfg`, `locale/en/gui.txt` | latin-1 line reads |
| Cursor/audio | `cursors/textures/bmp/gotomine.bmp` (4,152 B); `sounds/interface/upgmine.ogg` (68,249 B) | file listing only |

### 2.2 Repo (read only)

`docs/audit/PIECES/mines_display.md`, `stones_rocks.md`, `map_density.md`,
`verdict_decor.md`; `docs/audit/TERRAIN_DONOR_ASSETS.md`, `TERRAIN_DONOR_PATTERNS.md`;
`docs/decomp/DB_SCRIPTS.md`; `docs/coord_swarm_2026-11-24/reports/I06_ai_metal_mines.md`,
`V783_donor_map_importer.md`, `TERRAIN_SMALL_maps.md`;
`variant3d/scripts/{pattern_gen,game,world,world3d_entities,data,ai}.gd`;
`variant3d/tests/t_mines_fix.gd`, `t_mines_place.gd`, `t_smallmap_terrain.gd`;
`variant3d/tests/results/{t_mines_fix,t_mines_place,t_mine_unified,t_mine_build}.json`;
`variant3d/tests/fixtures/small_map_{64,128}.json`;
`app/scripts/{game,world}.gd` (2D legacy, secondary only).

---

## 3. Claim table

| # | Claim | Evidence (`path:line` / bytes) | Label | Verdict after 2–3 passes | Correction / caveat |
|---|---|---|---|---|---|
| C1 | Three ore families only: gold `mng`, iron `mni`, coal `mnc` (desert `desert_*`) | `dogenerate.inc:548-553`; `generator.cfg:69-153` | observed | **CONFIRMED** | No silver/gem mines anywhere in donor data filename scan (23 `mine*` files, §4.1) |
| C2 | Six env mine props: full + `s` variants | `env.objects:2-4,337-339`; `minegold.prop:4-5` vs `minegolds.prop:4-5` | observed | **CONFIRMED** | `s` shares the **same mesh and 0.3152 scale**; only material/DDS differs |
| C3 | Prop chain `prop → actor → .osm` resolves for all three | `minegold.prop:18-21`; `minegold.actor:1-5`; `.osm` IDP2 header | observed | **CONFIRMED** | `.actor` refs `refstone.actor`, `Tag = 300` |
| C4 | Three `.osm` are byte-identical (one silhouette) | SHA-256 all three `A2A6380C7521B941…289A`; P3 parse: 1,065 v / 1,234 f / 1,134 UV / 1 frame | observed | **CONFIRMED** | Ore identity is **material only**, matching `mines_display.md` C2 |
| C5 | Mine scale 0.3152, **no jitter** (min=max=1) | `envscales.cfg:16-36` (3 entries, all `minscale=1`, `maxscale=1`); props `:35-40` | observed | **CONFIRMED** | `mines_display.md` C3/C14-jitter applies to stones (`:40-46`), not mines; variant3d `world.gd:229-232` now encodes the fix |
| C6 | Raw mesh 15.026×15.822×1.913 → 4.736×4.987×0.603 m at 0.3152 | `.osm` parsed bounds X −7.1416..7.8848 / Y −7.9127..7.9091 / Z −1.5514..0.3619; ×0.3152 | derived | **CONFIRMED (twice)** | ≈2.37×2.49 tiles at `TILE_M=2.0` (`data.gd:23`) |
| C7 | Olive/brown ground disc is **donor art**, not a private-use bake artefact | P2 viewer of `materials/env/minegold.dds` (2048² DXT5) shows a green cracked disc under a dark ore pile; P3 UV/Z correlation: low-Z face tercile mean RGB (68,72,32), **50.6% green-dominant**, high-Z (63,61,35), 27.6% | observed + derived | **CONFIRMED** — refutes `mines_display.md` §1.2 and `world.gd:2635-2638` premise | `*s` DDS uses a **beige/sand** disc (same mesh); likely terrain-adaptive material, which variant chosen is UNVERIFIED |
| C8 | Donor mines have no sparkle VFX; ore colour is in the texture | filename scan of `effects/`, `materials/pfx/`, `env/pfx/` → 0 mine/gold/iron/coal hits; DDS ore specks visible (gold yellow / iron red / coal grey) | observed | **CONFIRMED** | Built mines have an **animated attachment** (C12), which is the only motion |
| C9 | Mine stamp = 8×10 cells, 32/80 occupied, 63 record structures | `pattern/mng_1.pattern` 3,730 B, header `08 00 00 00 0a 00 00 00`; records at 0x18b stride 24 (P3 re-derived for mng/mni/mnc/desert_*) | observed | **CONFIRMED** | Record-**id → prop** mapping remains UNVERIFIED (also `TERRAIN_DONOR_PATTERNS.md §2.2`) |
| C10 | 256 angle tries per ore per ring, first accepted by `_misc_CheckStandPatternExt` | `dogenerate.inc:525,555-557,704-713` | observed | **CONFIRMED** | `Freq` damping after accept at `:711` |
| C11 | Density 0/1/2 → rings 3/4/5; near call uses ring 0, global uses rings 1.. | `dogenerate.inc:528-535`, `:985`, `:1769-1770` | observed | **CONFIRMED** | `minesdensity>2` → random `:1586-1587` |
| C12 | Distance bands are version/size/player-count gated, in **map cells** (not metres) | `dogenerate.inc:559-655`; corner logic `:658-697` uses `±maphW±24` with `maphW=160` (`:669-688`) | observed + derived | **CONFIRMED** | Example v≥80, mapsize>2: 14+8, 32+10, 70+12, 22+16, ring4 `continue` (`:595-601`); ring 0 = 14–22 cells = 28–44 m |
| C13 | Built mines are full buildings: 4 build stages + 2 death stages, scaffold child, animated attach, scale 0.51 | `eurcoa.prop:8-11,13-18,73-113,115-119`; `eurcoa.actor:1-28`; `eurcoaanim.aaf` = `"idle",1,99,morph`; `eurgolanim.aaf` = `"idle",1,56,morph` | observed | **CONFIRMED** | `euriroanim.prop:9-10` and `eurcoaanim2.prop:9-10` reuse `eurgolanim.mesh` (donor copy-paste) |
| C14 | Dedicated 5×5 worked-ground decals exist for the three built mines | `decals.lib:142-163` (`eurcoad`, `eurgold`, `eurirod`; width=height=5, summer/winter); `decals.mat:170-179,753-762`; DDS viewed = brown dirt plate + small dark bar + pebbles | observed | **CONFIRMED** | Converted in repo (`decals_png/eurgold.png`), but 2D `_draw_mine` bypasses `_bld_decal` (`world.gd:2860` vs `:2873`); unwired for mines |
| C15 | Mine ownership/capture = generic building tinting/capture, no mine-specific overlay found | built mine props have no capture flag asset; `unit.script:4731-4755` `_unit_TestCapture`; `nothing.inc:507-519`; `unit.script:11340` special-cases mine usage in AI target choice; port tint at `world3d_entities.gd:1172-1178` | observed + **UNVERIFIED** | **PARTIAL** | No mine-specific capture art found by filename scan; do not claim mines are uncapturable from `:11340` alone |
| C16 | Menu "Minerals" Poor/Medium/Rich + Random controls `resourcemines` | `showcustomgame.inc:219-231`; `locale/en/gui.txt:435-440`; `dmscript.global:240` (`gc_MaxResourceMinesCount=3`) | observed | **CONFIRMED** | Map/AI default 1 (Medium): `initmap.inc:31`, `map.script:253`; menu init 0 but combo selects index 1 (`:230`) |
| C17 | AI builds `rounds-1` mines per ore, mirroring density | `progresseconomicai.inc:2892-2913` | observed | **CONFIRMED** | Independent of map pattern acceptance; can exceed accepted deposits |
| C18 | Deposit node is a real resource object tagged by basename | `env.inc/initial.inc:47-71` maps `'minegold','minegolds'→gold`, iron/coal likewise; `:70-71` `_res_Init` + `_res_ResGridAdd` | observed | **CONFIRMED** | `StringTag=101` in props; hover text in `locale/en/gui.txt:222-226` |
| C19 | variant3d places mine deposits via donor-family stamps, 256 tries, no overlap | `pattern_gen.gd:255-277,322-346`; final authority `:551-720` | observed | **CONFIRMED** | Uses a dedicated `mine_rng` so shared RNG is unchanged |
| C20 | variant3d count/layout diverges from donor density model | `pattern_gen.gd:391` (`cluster_target = 9±2 × RICHNESS_CLUSTER_SCALE`); `data.gd:205-214`; near band 6..14 (16 last resort) at `:659-663`; 11-tile separation `:593` | observed | **CONFIRMED divergence** | Donor bands are 14+… cells with no 11-tile rule; port count is richness-cluster-based, not `rounds×3` |
| C21 | variant3d 2D draws a mine sprite at the deposit (no boulder) and strips the disc | `world.gd:2809-2833`, `_mine_marker_tex` `:2635-2693`; jitter gate `:229-232` | observed | **CONFIRMED** | Correct vs prior bug, but disc removal is wrong per C7 |
| C22 | Built-mine sim/build tests all pass | `tests/results/t_mine_unified.json` 13/13, `t_mine_build.json` 8/8, `t_mines_fix.json` 5/5, `t_mines_place.json` 3/3 | observed | **CONFIRMED** | Placement/build logic sound; visual/art gap remains |
| C23 | Small-map fixtures and a 64² terrain probe already exist | `tests/fixtures/small_map_{64,128}.json`; `t_smallmap_terrain.gd:1-120`; `TERRAIN_SMALL_maps.md:99-120` (64² probe 21/21) | observed | **CONFIRMED** | Ideal host for the mines-piece test (§8) |
| C24 | Prior "test2/test3 in mine footprint" defect is fixed in current port | `game.gd:54-57` (`mine_mask`), `:320-330,534-568,1614`; apron still `terrain=1` `:841` | observed | **CONFIRMED (stale prior claim)** | `game.gd:841` paints 3-tile dirt; picker forced to `ground1` on the mask |

---

## 4. Donor mine inventory, constants and appearance

### 4.1 Inventory (observed)

Filename scan of `data/` for `mine` returned **23 files** (§2.1); the only
gameplay mine objects are the six env props plus three built-mine buildings.
No ore beyond gold/iron/coal exists. Related interface/audio:
`cursors/textures/bmp/gotomine.bmp`, `sounds/interface/upgmine.ogg`,
`hotkeys.cfg` (N = `gol/iro/coa`, Ctrl+M = idle mines).

### 4.2 Deposit/resource node (observed)

```
objects/env/minegold.prop:18-20   LODActorName=minegold; DefaultMeshName=minegold.mesh
objects/env/minegold.prop:23-29   summer minegold / winter minegoldw, UseSeasonMaterial=True
objects/env/minegold.prop:35-40   DefaultScale X=Y=Z=0.3152
actors/env/minegold.actor:1-5     → .\data\actors\env\minegold.osm (IDP2, 55,876 B)
```

`CategorieName = resources`, `StringTag = 101`, `PlayableObject = False`,
collision disabled (`minegold.prop:6,10-16`). All three `.osm` share one
SHA-256 (`A2A6380C7521B941…`), so **gold/iron/coal deposits have the same
silhouette** and differ only by material (C4). The `*s` props use the same
actor/mesh and 0.3152 scale but a different DDS (`minegolds.prop:19-28`), whose
ground disc is beige rather than olive (P2 viewer) — likely a sand/desert
material choice; which terrain selects it is **UNVERIFIED**.

**On-ground look (P2 visual + P3 UV/Z correlation):** the 2,048² DXT5 atlas holds
an irregular **ground disc** (cracked olive grass for `minegold`, beige for
`minegolds`) with a central **dark rubble pile** whose specks are gold-yellow,
iron-red or coal-grey. The disc is sampled by low-Z faces of the same mesh
(low-Z tercile: RGB (68,72,32), 50.6% green-dominant vs high-Z 27.6%, C7) —
therefore it is **donor art**, not a renderer artefact. There is **no**
headframe, cart or sparkle particle on the *deposit*; those belong to the
*built* mine (§4.4).

### 4.3 Scale and jitter (observed / derived)

| Constant | Donor value | Source |
|---|---|---|
| Env mine prop scale | 0.3152 (X=Y=Z) | `minegold.prop:37-39`, iron/coal identical |
| `envscales.cfg` `group=mines` | `minecoal/minegold/mineiron scale=0.3152`, `minscale=1`, `maxscale=1` | `envscales.cfg:16-36` |
| Stones (contrast) | `stones scale=0.329 min=0.85 max=1.15` | `envscales.cfg:40-46` |
| Raw mesh AABB | 15.026 × 15.822 × 1.913 | `.osm` parse, P3 |
| Scaled world size | **4.736 × 4.987 × 0.603 m** (≈2.37 × 2.49 tiles) | derived ×0.3152 |
| Built-mine prop scale | 0.51, `DefaultRollAngle=45` | `eurcoa.prop:115-123` |

The donor's generic scale-clamp pass (`dogenerate.inc:1971-2027`) only jitters
objects whose `GetGameObjectDefScalePropsByHandle` reports `rand=True` and a
spread >5% of the mid-scale (`:1990-2023`). Mines have `min=max`, so they are
deterministically 0.3152. `_misc_FixEnvironmentObjectsScales`
(`misc.script:3805-3866`) is **commented out** at `dogenerate.inc:2055`.
**Therefore any ±15% wobble on mines is a port invention.**

### 4.4 Built mine (observed)

```
objects/buildings/eurcoa.prop:8-10     LODActorName=eurcoa, DefaultMeshName=eurcoa.mesh
objects/buildings/eurcoa.prop:13-18    summer eurcoa / winter eurcoaw
objects/buildings/eurcoa.prop:73-110   scaffold child eurcoaa with Mesh[0..4] build
                                       stages, Mesh[5..6] death stages
actors/buildings/commoneur/eurcoa.actor:2-27  base + eurcoa1..4 + death1/2
animations/aaf/eurcoaanim.aaf          "idle",1,99,morph  (morph frames)
animations/aaf/eurgolanim.aaf          "idle",1,56,morph
terrain/decals/decals.lib:142-163      eurcoad/eurgold/eurirod, 5x5, summer+winter
```

So a built mine is a **proper 3D building** with construction scaffold,
four appearance stages, two destruction stages, an animated working attachment
(56 or 99 morph frames), and a dedicated 5×5 dirt plate. The animated meshes
are shared (`euriroanim.prop:9-10`, `eurcoaanim2.prop:9-10` both point at
`eurgolanim.mesh`). No mine-specific sparkle/glow VFX exists (C8).

### 4.5 Ownership / capture (partial)

Built mines are ordinary playable buildings; the port applies per-player tint
(`world3d_entities.gd:1172-1178`) and donor capture is handled generically by
`_unit_TestCapture` (`unit.script:4731-4755`) and `nothing.inc:507-519`. Mine
*usage* is special-cased in AI target selection (`unit.script:11340`) and in the
"select idle mines" hotkey/locale (`Ctrl+M`, `locale/en/gui.txt:257-258`).
**No mine-specific capture flag, banner or recolour asset was found** by the
filename scan and the `bcapture` grep; whether the donor shows a distinct mine
capture overlay is **UNVERIFIED**.

### 4.6 Placement algorithm (observed)

**Families** (`generator.cfg:67-205`): `mng`, `mni`, `mnc`, each with alias
`mng4/mni4/mnc4` (`Freq = 0`) and five numbered patterns (`mng_1..mng_5`,
`Freq = 1`); a desert set uses `desert_mng_*_a` (`:156-204`) plus a second
desert block pointing back at `mng_1..mnc_5` (`:1658-1731`). Why both blocks
exist is **UNVERIFIED**.

**Stamp shape**: `mng_1.pattern` = 8×10 cells, 32/80 occupied, 63 24-byte
records (`id:int32 + 1.0f×4 + 4 tail bytes`) at `0x18b` stride 24. All six
sampled mine patterns share this exact size/record count. Record ids are
byte-sized (0..255) and **do not map cleanly** to `env.objects` ordinals
(mine props are ordinals 0/1/2 and 318/319/320 at `env.objects:2-4,337-339`);
no asset names are embedded in any `.pattern` (`TERRAIN_DONOR_PATTERNS.md §2.3`).
The 63 records are plausibly mine prop + rubble/carts/bags (some ids resolve to
`rocks`, `cart5`, `barrel3`, `bags3` if interpreted as `env.objects` indices),
but the binding is **UNVERIFIED** and out of this ticket's scope.

**`SetupMines(pointx, pointy, minround, maxround, minesdensity, spcount)`**
(`dogenerate.inc:522-717`):

1. `trycount = 256` (`:525`); `rounds = 3/4/5` for density 0/1/2 (`:528-532`),
   capped by `maxround` (`:533-534`); loop `i = minround .. rounds-1` (`:535`).
2. For each of `mng,mni,mnc` (`:544-553`), prefixed `desert_` when `bDesert`
   (`:552-553`), select a pattern from the family list (`:554,557`).
3. Distance `dst` by `gRecordGeneratorVersion` and map/player size:
   - v<70 (`:561-567`): `14+8R, 38+8R, 130+40R, 52+8R, 26+5R`.
   - v≥80, mapsize>2 (`:595-601`): `14+8R, 32+10R, 70+12R, 22+16R`, ring4 skipped.
   - v≥80, spcount≤4 (`:639-645`): `14+8R, 32+10R, 70+12R, 22+16R`, ring5 skipped
     — note **case i=2 has no `dst` assignment in this branch** (observed anomaly).
   - spcount>4 (`:648-654`): `14+6R, 23+10R, 39+9R, 33+9R`, ring4 skipped.
4. Ring 2 with spcount≤4 on big maps places at a map **corner**
   `±maphW∓24, ±maphH∓24` for `gRecordGeneratorVersion≥90` (`:658-697`).
5. `angle = RandomExt*360`, rotate `(dst,0,0)` by Y (`:704-708`), accept the
   first candidate passing
   `_misc_CheckStandPatternExt(envplHnd, name, round(newpointx+px), round(newpointy+pz), True, pRecordManagerPatternList)` (`:709`),
   then `_misc_PatternIncreaseFreq` and `break` (`:711-712`).
6. `dst` is in **map cells** (corner math uses `maphW≈160`, map 320²): ring0
   ≈14–22 cells = **28–44 m** at TILE=2 m (derived).

**Call sites / counts**: `CreateStartPoint` calls `SetupMines(...,0,1,...)` —
only ring 0, per start (`:985`); the global relief block calls
`SetupMines(arrStartPos[i].x, arrStartPos[i].y, 1, 0, ...)` — rings 1..rounds-1
for each of `spcount` starts (`:1769-1770`). So **each start gets one deposit
of each ore per ring**, upper bound `rounds × 3` deposits per start before
rejections; the actual count is acceptance-limited by `trycount=256` and the
footprint test. `minesdensity > 2` → `floor(RandomExt*3)` (`:1586-1587`).
Donor UI labels: 0=Poor, 1=Medium, 2=Rich, 3=Random
(`showcustomgame.inc:224-230`, `locale/en/gui.txt:435-440`), map default 1
(`initmap.inc:31`, `map.script:253`). AI target count mirrors density minus one
ring (`progresseconomicai.inc:2892-2913`).

---

## 5. What exists / missing / wrong in variant3d (read only)

### 5.1 Exists and correct

| Item | Evidence |
|---|---|
| Mine deposits are real typed resource nodes (`max_hits=0`) from stamped donor families | `game.gd:808-842`; `pattern_gen.gd:255-277,322-346` |
| 256-try footprint rejection, no overlap, per-start ore guarantee, deterministic dedicated RNG | `pattern_gen.gd:328-346`, `:551-720`; `tests/results/t_mines_fix.json` 5/5 |
| Donor scale constants (0.3152 mine / 0.329 stone) present | `world.gd:222`; `world3d_entities.gd:113` |
| Mine jitter disabled (min=max=1) | `world.gd:229-232` (`if kind == "mine": return base`) |
| Converted 3D mine meshes and textures (same shared silhouette) | `assets/models/obj/mine_{gold,iron,coal}.obj`, `tex/mine_*.png`; `_resource_sid` → `mine_<ore>` at `world3d_entities.gd:1269-1277` |
| 2D deposit marker uses the mine sprite, not `rock.png` | `world.gd:2809-2833` |
| `test2/test3` no longer leak into the mine apron | `game.gd:54-57,320-330,534-568,1614`; `game.gd:841` keeps terrain=1 but picker emits `ground1` |
| Deposit/build simulation green | `t_mine_unified.json` 13/13, `t_mine_build.json` 8/8, `t_mines_fix.json` 5/5, `t_mines_place.json` 3/3 |

### 5.2 Missing / wrong versus donor

1. **Count and layout model is port-invented, not donor.** `RICHNESS_CLUSTER_SCALE`
   (`data.gd:205-214`) drives `cluster_target = 9±2 × scale`
   (`pattern_gen.gd:391`), deposits land 6–14 (16 last resort) tiles from a hall
   (`:659-663`) and are forced ≥11 tiles apart (`:593`). Donor uses `rounds×3`
   rings at version-gated 14+… **cell** bands with no 11-tile rule
   (§4.6). The port deliberately pins its own count baseline
   (`t_mines_fix.gd:20-28`) instead of donor acceptance counts.
2. **Ground disc is stripped as a "bake artefact"** (`world.gd:2635-2638,2681-2682`).
   P2/P3 show the disc is donor texture sampled by low-Z faces (C7). The port
   therefore removes donor ground art and substitutes a generic `ground1` tile
   inside a 3-tile terrain=1 apron (`game.gd:841`). Donor `*s` sand disc is not
   represented at all.
3. **Stamp contents are not reproduced.** Donor `mng_1` carries 63 object
   records in an 8×10 footprint; port emits one sprite/mesh at the stamp centre
   and paints a uniform disc. Whether the records are mine+rubble/carts is
   UNVERIFIED (C9), so a faithful scatter cannot yet be claimed.
4. **Built-mine art is a bbox proxy.** No `eurcoa/eurgol/euriro` mesh/OBJ exists
   in `variant3d/assets/models`; `world3d_entities.gd:1163-1166,749` uses
   `_proxy_mesh_raw` with per-player tint. 2D `_draw_mine` uses the deposit
   sprite at ≤3 m (`world.gd:3110-3125`). Donor's 4 build stages, scaffold,
   2 death stages, 56/99-frame working animation and 5×5 dirt plate are absent
   at runtime (`eurgold.png` is converted but only `_bld_decal` at `:731-740`
   loads it, and `_draw_mine` bypasses that path at `:2860`).
5. **Ownership/capture visual not implemented beyond generic tint** (C15); no
   mine-specific capture state on either renderer (UNVERIFIED in donor too).
6. **Secondary 2D legacy** (`app/scripts/world.gd:223-235`, `game.gd:54-57,841`)
   mirrors the variant3d fixes; no separate defect claimed here.
7. **Reference visual remains UNVERIFIED**: `mines_display.md §1.5/T6` found no
   donor screenshot with a clear mine; the piece render's donor panel is a
   proxy. Donor *art* evidence available here is the texture atlas, the `.osm`
   geometry and the decal, not a gameplay screenshot.

---

## 6. Concrete fix recipe (no donor byte copied; pixels/metadata only)

Ordered by confidence and cost. All targets are **proposals**, not edits made.

### F1 — Restore donor mine scale semantics and ground disc (highest confidence)
- Keep `ENV_SCALE.mine = 0.3152`; keep the `kind == "mine"` jitter bypass.
- Replace the disc-strip in `world.gd:_mine_marker_tex` (`:2635-2693`) with a
  donor-faithful ground apron: either use the olive/brown disc region of the
  converted `tex/mine_gold.png` / `mine_iron.png` / `mine_coal.png` at the
  deposit foot, or (better) convert `minegold.dds`/`minegolds.dds` disc pixels
  into a separate RGBA apron PNG in `assets/terrain/` and draw it under the
  mound. Preserve the beige `*s` variant as an explicit sand-terrain choice.
- Keep 3.0 m cap but derive it from the scaled mesh Z extent (0.603 m) plus
  the converted sprite's ink box, not a hand-tuned height that exceeds the
  built mine.

### F2 — Align mine counts/radii with the donor density model
- Add the donor `rounds = 3 + resourcemines` rule and version-family distance
  bands (`14+8R`, `32+10R`, `70+12R`, `22+16R`, … in **cells**) to
  `pattern_gen.gd:279-405`; derive the menu value from `Data.RICHNESS` via an
  explicit map (`low→0`, `med→1`, `rich→2`, `random→floor(rng*3)`) instead of
  `RICHNESS_CLUSTER_SCALE`'s 0.55/1.0/1.55 multiplier.
- Keep the near-start fairness guarantee and the footprint non-overlap check,
  but reconcile their radii with donor bands: the near ring must be 14–22
  cells (28–44 m), not 6–14 tiles (12–28 m). Record both counts in the test so
  the intended divergence is explicit if gameplay overrides donor.
- Do **not** reuse the "pre-fix baseline" count table as donor truth; it is a
  port snapshot (`t_mines_fix.gd:20-28`).

### F3 — Wire the donor built-mine art and ground plate
- Convert `eurcoa/eurgol/euriro` `.osm` + materials to OBJ/GLB (same pipeline as
  other buildings), including `eurcoa1..4`, `death1/2`, the `eurcoa*` scaffold
  child and the `eurcoaanim`/`eurgolanim` `.oss` morph frames (56/99 frames).
- In `world3d_entities.gd:_add_building` (`:1163-1182`) select this mesh by
  `sid` instead of `_proxy_mesh_raw`; keep per-player tint (`:1172-1178`).
- In 2D, route `_draw_mine` (`world.gd:2860`) through `_bld_decal` so
  `eurcoad/eurgold/eurirod` (5×5, summer/winter) sits under the built mine;
  keep the procedural ellipse only as fallback.

### F4 — Stamp detail (needs T3 record-id resolution first)
- Resolve `.pattern` record ids against donor engine tables (out of scope here:
  `TERRAIN_DONOR_PATTERNS.md` C7/C8/T3). Once mapped, scatter the donor's
  63 objects (mine prop + rubble/cart/bag) inside the 8×10 footprint instead
  of one sprite. **Do not guess** a prop from a byte value.

### F5 — Documentation hygiene / no-go
- Correct `mines_display.md §1.2` ("disc is a renderer artefact") and the
  `world.gd:2637` comment to the P2/P3 evidence (C7).
- Do not edit `tileblocks.json` (unwired, no mine entry — `mines_display.md` C12).
- Do not import donor `.osm/.dds/.pattern` binaries into the repo; convert
  pixels/geometry only, as done by `variant3d/tools/convert_models.py`.

---

## 7. Evidence-quality notes from the three passes

- **P1** filename inventory: 23 `mine*` donor files; no silver/gems, no mine pfx.
- **P2** line reads: props/actors/envscales/generator/scripts/menu/locale/decals
  all re-read with explicit line numbers; `envscales.cfg` grep returns exactly
  three mine names (no `*s`).
- **P3** binary: three `.osm` hashes identical; parsed geometry and UV/Z
  correlation confirm the ground disc; six `.pattern` files decoded
  independently of `TERRAIN_DONOR_PATTERNS.md`.
- **P4** port: every cited `.gd` line was read in the current tree; test results
  read from JSON, not from stale prose. Prior-lane claims about jitter and
  `test*` tiles are stale in the current variant3d tree and were corrected.

---

## 8. "Terrain + mines" isolated piece test on a small map

**Host**: reuse `variant3d/tests/fixtures/small_map_64.json` (64×64,
`render_mode=3d`, seed 20261113, all other keys inherited — `TERRAIN_SMALL_maps.md:43-55`)
and the boot pattern of `variant3d/tests/t_smallmap_terrain.gd:9-20,42-85`.
New test file (`tests/t_smallmap_mines.gd`) would be owned by an implementation
ticket; this report only defines criteria.

**Procedure** (through `variant3d/tools/godot_runner.py` only):
```
python variant3d/tools/godot_runner.py run --id smallmap-mines --timeout 300 -- \
  --headless --path variant3d --script res://tests/t_smallmap_mines.gd -- \
  --config <abs>/small_map_64.json --screenshot <temp>/unused_64.png
```
plus one windowed capture for visual review with `smallmap_capture.py scan-stderr`
on the runner stderr (`TERRAIN_SMALL_maps.md:57-70`).

| # | Criterion | Target / measurement | Gate |
|---|---|---|---|
| M1 | Terrain module intact | 64² = 4,096 vertices / 7,938 triangles / 4,096 UV2; one surface; UV2.x in 0..123; `face_hist` matches | hard (reuse `t_smallmap_terrain.gd` 21/21) |
| M2 | Mine deposits exist and are typed | every 64² map has ≥1 node of each of `gold/iron/coal`, `max_hits==0`; count recorded | hard |
| M3 | Donor-family stamping | each deposit traces to a `Stamp.kind=="mine"` with family `mng/mni/mnc` and a donor pattern name; 256-try path exercised | hard |
| M4 | No footprint intersection | dilated stamped cells (margin 1) disjoint; measured overlaps == 0 | hard (as `t_mines_fix.json`) |
| M5 | Terrain remain walkable | `terrain` at each deposit cell is not water/rock; `is_blocked(mine_pos)==false` | hard |
| M6 | Apron ground truth | inside the 3-tile apron, tile picker emits **zero** `test2`/`test3`; `mine_mask` set; outside apron road cells may still use them | hard (donor-equivalent of `mines_display.md` A2) |
| M7 | Deposit visual | drawn sid is `mine_<ore>` (not `rock`); visible ink height ≤3 m and ≈2.4–2.5 tiles wide; no procedural boulder fallback in the normal path | hard |
| M8 | Ground disc policy | if F1 lands: olive/brown apron present under the mound and no green-dominant *oval* floating above the pile; if F1 not landed: record explicit DEVIATION, not PASS | soft / documented |
| M9 | Scale constant | `ENV_SCALE.mine==0.3152` and no jitter: two renders of the same node with different position hashes have identical sprite height | hard |
| M10 | Built mine | build one `mine_gold` on its deposit; `t_mine_unified`/`t_mine_build` checks remain green; 2D/3D node sid is `mine_gold`; if F3 lands, mesh source is donor, not `donor_bbox_proxy` | hard for sim / soft for art |
| M11 | Determinism | same fixture + seed twice → byte-identical result JSON and identical sorted ore signature | hard |
| M12 | No script errors | `smallmap_capture.py scan-stderr` reports zero `SCRIPT ERROR` | hard |

**Pass gate**: M1–M7, M9, M11, M12 all green; M8/M10-art may be DEVIATION with a
written reason until F1/F3 land. Photograph both 2D and 3D modes; **no donor
visual-parity claim** — donor reference for mines is asset geometry/texture,
not a captured gameplay frame (`mines_display.md §1.5`, `verdict_decor.md`
proxy-crop disclosure).

---

## 9. Open questions

1. **Record-id binding**: what do the 63 `mng_1` records name? `env.objects`
   ordinals 0/1/2 and 318/319/320 are mine props, but sampled record ids
   (161, 223, 175, …) do not index them cleanly. Needs donor engine tables or a
   correlated record→prop probe, not guesswork.
2. **`*s` variant trigger**: `minegolds/mineirons/minecoals` have beige ground
   discs and identical meshes; which terrain/season selects them is UNVERIFIED
   (no script reference outside `env.inc/initial.inc:47-51`).
3. **Disc ownership**: P2/P3 show the disc is sampled donor texture, so stripping
   it in `world.gd:2681` is a fidelity regression. Confirming the exact on-screen
   polygon would need an in-engine donor capture, which is out of scope here.
4. **Both desert family blocks** in `generator.cfg:156-204` and `:1658-1731`
   exist with different pattern names; the selecting condition is UNVERIFIED.
5. **Anomalous `dst` branches**: `dogenerate.inc:617-645` omit `case i=2`
   for some versions/player counts; whether `dst` is intentionally inherited
   from the previous ring is UNVERIFIED (replay compatibility is plausible).
6. **Mine capture visuals**: no mine-specific overlay/flag asset found; generic
   capture code exists. Confirm with a donor gameplay capture before adding art.
7. **Donor unit of `dst`**: derived as map cells from corner math (`maphW≈160`);
   a donor-side coordinate probe would remove the last uncertainty in the
   metre conversion (28–44 m near ring).
8. **Donor visual reference**: still absent from the 12 catalogued screenshots;
   all appearance claims here anchor to donor mesh/texture/decal bytes.

---

## 10. Summary

Donor has exactly **three ores** (gold/iron/coal), each with a **full and a
sand-tinted small-variant prop**, one **shared 0.3152-scaled silhouette**, and
**zero scale jitter** (`envscales.cfg:16-36`). On the ground a deposit is a
**cracked olive/beigen ground disc with a dark ore-speck pile** — the disc is
donor art (verified by DDS pixels and `.osm` UV/Z correlation), not a bake
artefact. Placement is `SetupMines`: **3/4/5 rings**, **3 ores per ring**,
**256 random angles**, a donor footprint test, version-gated **14+… cell**
bands, and two call sites (near ring 0 per start, rings 1.. per start). Built
mines are full buildings with scaffold, 4 build stages, 2 death stages, a
56/99-frame animated attachment and a 5×5 dirt decal; capture/tint is generic.

variant3d already has correct mine typed nodes, 256-try stamping, no-overlap
guarantees, donor scale constants, no jitter, mine sprites at deposits and a
`mine_mask` that removes `test*` tiles from the apron — all sim/build tests are
green. The remaining gap is **fidelity, not logic**: port-invented cluster
counts/radii, runtime stripping of donor ground art, one-sprite stamps instead
of the donor's 63 record objects, and bbox-proxy built mines instead of the
donor building/stage/animation/decal chain. The isolated 64² terrain+mines test
above gates those fixes with M1–M12. No code was edited and no donor binary was
copied; donor paths are private-use references only.

*End of DTRN-05.*
