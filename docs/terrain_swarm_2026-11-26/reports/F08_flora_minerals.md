---
id: F08
ticket: "TERRAIN-SWARM-2026-11-26 / WAVE F / F08"
title: "Donor forest / stone / mine pattern families — object contents, footprints, weights and placement recipe"
date: 2026-11-26
status: DELIVERED__READ_ONLY__NO_RUNNER__NO_CODE_EDIT
scope: "One report only. Donor read READ-ONLY in place at C:\Games\Cossacks 3; no donor binary run, copied or committed; no port source/asset/config/test/git edit; no runner job."
labels: [O], [D], [I], [U], "PORT APPROXIMATION"
visual_parity_claim: false
donor_root: "C:\\Games\\Cossacks 3\\data (READ-ONLY, private use)"
---

# F08 — Donor flora / mineral pattern families

## 0. Mandate, conventions and sources

Per `docs/terrain_swarm_2026-11-26/CHARTER.md:11-45,66-84`, this report is
**donor truth first**: catalogue the `.pattern` families that place forests,
stone/quarries and mineral mines; decode *what objects they stamp* and *with what
placement weights*; state how that relates to the port's converted assets. It
makes **no parity claim** — no donor GPU A/B frame exists in this lane.

Labels are literal: **[O]** observed donor byte/line; **[D]** deterministic
arithmetic over observed values; **[I]** plausible reading, unproven; **[U]**
UNVERIFIED; **PORT APPROXIMATION** = port-side divergence or engine term not
recovered.

Path convention **`D:` = `C:\Games\Cossacks 3\data\`**. `lib line` = 1-based line
in `D:pattern\pattern.lib` (30,309,138 B, 1,172,416 lines; 680 sections, SHA-256
`f7b421b179dee5ad2b28e025c6b776d8eeccfbec74a93a13c3d1c9d9f10dc1c0` per Z08 §2.1).
`.pattern` byte offsets are 0-based. Repo paths are relative to the workspace root.
All donor `.inc` script lines are `[*] = ;`-prefixed: **text OBSERVED, runtime
activation UNVERIFIED** (F2-02 §0, A08 §8 item 7) — this caveat applies to every
`dogenerate.inc` / `generatemap.inc` citation below and is not repeated each time.

Evidence was gathered by read-only Python over: `D:game\var\generator.cfg`,
`D:pattern\pattern.lib`, `D:pattern\*.pattern` (710 files), `D:game\var\envscales.cfg`,
`D:objects\env\*.prop`, `D:actors\actors.lib`, `D:actors\env\*.actor`,
`D:scripts\common.inc\dogenerate.inc`, `D:scripts\lib\misc.script`,
`D:scripts\dmscript.global`. Prior art re-read first: `F2_02_donor_fields_mines.md`,
`FOLD_05_all_folders.md`, `N02_donor_nation_objects.md`, `docs/research/RC_TERRAIN.md`,
`DPATTERN_01_relief_grids.md`, `Z05/Z06/Z08`, `TERRAIN_DONOR_PATTERNS.md`.

---

## 1. Executive summary

1. **[O]** The authoritative per-pattern **object list is not in the `.pattern`
   binary** — it is the `Objects : struct` array of `D:pattern\pattern.lib`. Each
   record carries `RaceName`, `BaseName`, `Position`, `Direction`, `Up`, `Scaling`
   (e.g. `mng_1` at `lib:713323-713633`, 11 records; first `minegold` at
   `lib:713408-713430`, scale `0.315200001001358`). The 24-byte tail of the
   `.pattern` binary has a **different count** (63 records in `mng_1`, 2,072 in
   `d_frt_big_1`, 323 in `d_stn_1`) so it cannot be a 1:1 object list **[D]**.
2. **[O]** Forest families are dense authored clumps, not scatter: e.g.
   `forests_pinefir_big` = 6 patterns, 115–348 objects each, 31×50…60×72 cells;
   `forests_mixed_big` = 298–548 objects, up to 86×92 cells. Stone families are
   mixed tree+rock clumps (`stoneforests` 38–60 objects), not bare rock piles.
   Every mineral stamp contains exactly **one** ore prop plus weeds/saplings on
   an 8×10-cell footprint **[O]**.
3. **[D]** `Freq` in `generator.cfg` is a **roulette weight**, not a probability;
   after a pick the family member's weight is multiplied by `0.2` with floor
   `0.0001` (`misc.script:3588-3629`). For all target forest/stone/mine families
   the member weights are 1 (mines' legacy `*_4` variants are 0; four
   `desert_stones` members are 0.5). The **real placement frequency** is the
   `frs_big/frs_mid/frs_small/stn1/stn2` pass rate in `dogenerate.inc:1688-1693,
   1774-1785,1836-1898`.
4. **[O]** A hard-coded `foreststype := 0` at `dogenerate.inc:5-6` overrides the
   preceding `floor(RandomExt*3)`, so the shipped text runs **only the conifer
   branch**; leaf/mixed branches (`:1871-1897`) are unreachable unless edited.
5. **[O]** No separate winter pattern exists: all 680 `pattern.lib` sections are
   `NativeSeason = Summer` and declare `Summer/Autumn/Winter/Spring = True`.
   Winter appearance is a **prop material swap** (`UseableWinterMaterials`, e.g.
   `fir.prop:52-57`, `stones.prop:49-50`, `minegold.prop:27-28`).
6. **PORT APPROXIMATION** — the port converts only `{w,h,cells}` masks
   (`donor_patterns.json:patterns`), **not** the `pattern.lib` Objects arrays;
   `game.gd:740-869` synthesises wood/stone nodes with port-invented probabilities
   (forest fill `0.30`, cap 14; 4–7 stones) instead of stamping the donor's
   BaseNames/positions/scales. Only relief props (`terrainmeshN`) use the Objects
   table (Z08). Port mine layout is its own cluster algorithm
   (`pattern_gen.gd:369-427`), not the donor's rings.

---

## 2. Evidence table

| # | Claim | Donor evidence | Label | Caveat |
|---|---|---|---|---|
| E1 | `generator.cfg` has 64 family blocks / 60 unique names; four names are duplicated (`desert_mng/mni/mnc`, `plain_medium`) | `D:game\var\generator.cfg:156,173,190,288,1658,1683,1708,1762` | [O] | First match wins in `_misc_SelectPatternListParser` (`misc.script:3573-3580`) |
| E2 | Family `Freq` is a roulette weight; pick = `freqrnd=RandomExt*freqsum`, first `freqrnd<freq`; on placement `freq*=0.2`, floor `0.0001` | `D:scripts\lib\misc.script:3568-3584,3634-3653,3588-3629` | [O] | Script text active-looking, not executed |
| E3 | Pass count `needed=floor(mapW*mapH*freq)`, `trycount=floor(256*mapsizeoptimise)`, `mapsizeoptimise=(320²)/(W*H)` (×0.65 if <1) | `D:scripts\lib\misc.script:3681-3729` | [O] | Rejection sampling via `_misc_CheckStandPatternExt` |
| E4 | Free-mask modifiers denominators 340/182/74/29; size modifier `640/((W+H)/2)` | `misc.script:3931-3941`; `dogenerate.inc:1718-1725` | [O]/[D] | Engine-computed mask counts UNVERIFIED |
| E5 | Global rates `frs_big=0.0009`, `frs_mid=0.0009`, `frs_small=0.00054`, `dcr=0.0005`, `stn1=0.00016`, `stn2=0.00012` | `D:scripts\common.inc\dogenerate.inc:1688-1693` | [O] | — |
| E6 | `foreststype` forced to 0 | `dogenerate.inc:5-6` | [O] | Leaf/mixed branches `:1871-1897` dead in shipped text |
| E7 | `mng/mni/mnc` mine stamps: 8×10 cells, one ore prop each, 11/14/13 objects in `_1` variants | `generator.cfg:69-153`; `pattern.lib:713285` (`mng_1`), `715147` (`mni_1`), `716813` (`mnc_1`) | [O] | `mng4/mni4/mnc4` Freq 0 |
| E8 | `SetupMines`: 3/4/5 rings by density 0/1/2, 3 ores/ring, 256 angle tries; start call uses `(0,1,...)`, global call `(1,0,...)` | `dogenerate.inc:522-535,544-557,705-716,985,1769-1770` | [O] | Distance bands version-gated `:559-701` |
| E9 | `SetupStartingResources`: per start 1 `stoneforests`, 2 `stones`, 3 forest clumps, trycount 128×3, ellipse radii 5×7 / 12×15 / 22×18 | `dogenerate.inc:407-414,720-861,863-945,947` | [O] | `mindst=Min(rx,ry)+RandomExt*3+((i+j)*0.5)` |
| E10 | Object records live in `pattern.lib` `Objects` arrays with BaseName/Position/Up/Scaling | `pattern.lib:713323-713633` (`mng_1`), `:127343` (`d_frt_big_1`), `:203425` (`d_stn_1`) | [O] | 680 sections all `NativeSeason=Summer` |
| E11 | `.pattern` contains `int32 w,h` + cell grid + float height grid + 24-byte tail; tail count ≠ Objects count | `mng_1.pattern` bytes 0..7 (`w=8,h=10`), first 24-B record at 0x18B, 63 records to 0x773; `d_frt_big_1.pattern` record at 0x29FC ×2072; `d_stn_1.pattern` at 0x6EF ×323; cf. `DPATTERN_01 §2.1-2.3`, `TERRAIN_DONOR_PATTERNS.md:92-132` | [O]/[D] | Tail field semantics UNVERIFIED |
| E12 | BaseName → `.prop` → `LODActorName` → `.actor` → `.mesh` chain resolves for trees/rocks/ores | `objects\env\pine1.prop:9-17` → `actors.lib:1517` → `actors\env\pine.actor:2-15`; `minegold.prop:1-28` → `actors.lib:1248`; `stones.prop` → `actors.lib:1232`; `oak.prop:9-18,106-115` → `actors.lib:1589` | [O] | `.N` suffixes are mesh/material variants (`envscales.cfg:161-255`), not separate props |
| E13 | Ore scale 0.3152 fixed, no jitter; stones 0.25–0.4 with ±15% jitter | `D:game\var\envscales.cfg:15-37` (mines), `:39-109` (stones) | [O] | Matches `mng_1` `minegold` `Scaling=0.3152` at `pattern.lib:713429` |
| E14 | Winter variants are material swaps on the same mesh | `fir.prop:33-43,52-57`; `pine1.prop:33-43`; `stones.prop:49-50`; `minegold.prop:27-28` | [O] | No winter `.pattern` sections (680/680 Summer) |
| E15 | `pump`/`christmas` gated by `gc_halloween>0 and season<>2` / `gc_christmas>0`; both globals −1 | `dogenerate.inc:1848-1851`; `dmscript.global:1668-1669` | [O] | Disabled by default in shipped text |
| E16 | Name mismatches: `desert_forests_big` cfg names `n_desert_frt_big1..17` have no `pattern.lib`/file (actual `n_desert_frt_big_1..17`); `pump` cfg `k_pump_1..9` vs files `k_pump_01..09` | `generator.cfg:2006-2175,1539-1603`; `pattern.lib` name set; `pattern\` file list | [O]/[D] | Engine may normalise names — UNVERIFIED |
| E17 | `k_rock_*` not referenced by `generator.cfg`; `k_rock_1` carries shoreline props (`rocksea4`, `stonessea1`, `smallstonessea.3`) | `pattern.lib:626290` (W19 H18, 30 objects); 0 occurrences of `k_rock_` in `generator.cfg` | [O] | Likely shore/other-stage pass [I] |
| E18 | Port encodes 43 families incl. all target forests/stones/mines but stores only `{w,h,cells}`; port `desert_mng` unions both duplicate cfg definitions | `variant3d\assets\terrain\patterns\donor_patterns.json` (`patterns.mng_1` = `w8 h10 cells32`); `pattern_gen.gd:153-172` | [O] repo | PORT APPROXIMATION, not donor behaviour |
| E19 | Port realises forest/stone stamps with synthetic node probabilities; mine layout is cluster-based with its own RNG stream | `game.gd:772-844,847-869`; `pattern_gen.gd:276-298,369-427` | [O] repo | PORT APPROXIMATION |

Not promoted: runtime execution of any commented `.inc` line, the semantic meaning
of the 24-byte `.pattern` tail, whether the engine normalises the mismatched
family names, and all visual parity.

---

## 3. Family catalogue

### 3.1 Forest families

All members have `Freq = 1` in `generator.cfg` (weights are equal; the member is
chosen by roulette with damping, §4). All pattern.lib sections: `NativeSeason=Summer`,
`Summer/Autumn/Winter/Spring=True`, `HeightFieldStand=True`, `CollisionStand=True`,
`PatternMaskStand=False`, `ObjectsScale=1`, `RotationAngle=0`. Footprints in donor
**map cells**; "objs" = `pattern.lib` `Objects` records per pattern.

| Family (`generator.cfg` lines) | Members (Freq) | Objs/pattern | Footprint W×H | Dominant stamped objects (counts summed over family) |
|---|---|---:|---|---|
| `forests_pinefir_big` (909-937) | `d_frt_big_1..5`, `e_frt_big_3` (×1) | 115–348 | 31–60 × 50–72 | pine1 269, pinesmall1 191, firsmall1 163, plantain 136, fir 123, fern 89 |
| `forests_pinefir_medium` (938-966) | `d_frt_mid_1..6` | 61–87 | 20–39 × 27–33 | pine1 146, pinesmall1 54, plantain 53, firsmall1 39, fir 39, fern 38 |
| `forests_pinefir_small` (967-995) | `d_frt_small_1..6` | 29–43 | 18–24 × 13–25 | pine1 81, pinesmall1 40, firsmall1 31, fir 19 |
| `forests_spruce_big` (996-1017) | `d_frt_spr_big_1..4` | 86–105 | 30–36 × 37–40 | spruce1 178, pine1 87, pinesmall1 83, grassforest.3 15 |
| `forests_spruce_medium` (1018-1039) | `d_frt_spr_mid_1..4` | 75–111 | 29–34 × 29–38 | spruce1 153, pine1 63, pinesmall1 43, pinedry1 20 |
| `forests_pinedrygreen_small` (1040-1061) | `d_frt_pinedry_big_1..4` | 103–144 | 27–35 × 34–43 | pine1 170, pinesmall1 148, pinedry1 88, pinebroken1 24 |
| `forests_pine_small` (1062-1090) | `frt_s_p_1..6` | 5–14 | 8–11 × 6–11 | pinesmall1 14, fern 12, pine1 9, spruce1 6 |
| `forests_pine_medium` (1091-1135) | `frt_m_p_1..10` | 12–30 | 13–16 × 10–14 | pine1 41, pinesmall1 32, fir 21, spruce1 19, drybushes 14 |
| `forests_pine_big` (1136-1173) | `frt_b_p_1..7`, `f1_from_big3` | 46–83 | 13–22 × 18–31 | pinesmall1 160, pine1 109, spruce1 59, fern 28 |
| `forests_pine_big_2` (1174-1190) | `b_frt_b_p_1..3` | 49–64 | 22–24 × 19–23 | pinesmall1 59, pine1 39, spruce1 23 |
| `forests_mixed_big` (1191-1207) | `e_frt_big_1,2,4` | 298–548 | 59–86 × 61–92 | pine1 231, oak 139, firsmall1 124, pinesmall1 104, leaftree 40, drytree 32 |
| `forests_mixed_medium` (1208-1232) | `e_frt_mid_1..5` | 94–234 | 39–55 × 43–54 | oak 146, pine1 118, pinesmall1 66, firsmall1 48 |
| `forests_leaf_big` (1233-1246) | `g_frt_big_1,2` | 135–167 | 39–47 × 41–45 | oak.3 48, firsmall1 32, oak.4 29, oak.2 26, drytree 18 |
| `forests_leaf_medium` (1247-1260) | `g_frt_mid_1,2` | 110–125 | 35–41 × 34–44 | oak.2 30, pinesmall1 29, pine1 29, oak.3 28 |
| `forests_leaf_small` (1261-1289) | `g_frt_small_1..6` | 13–50 | 19–29 × 16–34 | oak.3 24, plantain.1 21, firsmall1 20, oak.4 18 |
| `desert_forests_medium` (2079-2175) | `n_desert_frt_m_1..23` | 19–49 | 14–21 × 10–24 | palm 163, plantyellow 102, plantainyellow 101, desert5 100 |
| `desert_forests_small` (2176-2260) | `n_desert_frt_s_1..20` | 18–34 | 12–19 × 12–18 | plantyellow 109, palm 99, desert4 78, desert3 64 |
| `desert_forests_unique` (2261-2313) | `desert_frt_un_1..12` | 30–79 | 16–28 × 22–35 | palm 149, plantyellow 136, palmsmall 84, smallstonessea 47 |
| `desert_forests_big` (2006-2078) | `n_desert_frt_big1..17` | **0 resolvable** | — | **name mismatch E16** [U] |

Worked examples **[O]** (all at `pattern.lib`):
- `d_frt_big_1` `:127343`, W38 H57, **124** objects: firsmall1×34, pine1×27,
  pinesmall1×16, plantain×14, fir×14; per-object Scaling `0.3564..0.8162`;
  `HeightFieldMax=0.464999884366989`. First record `:127382` = firsmall1 at
  `(13.3319, 0, 22.0814)`, Up `(-0.9563, 0, 0.2924)`, scale `0.4689`.
- `frt_b_p_1` `:55411`, W18 H18, **49** objects, `HeightFieldMin=-0.28`,
  `HeightFieldMax=0.45` — small pine stamps carry authored relief, not just props.
- `e_frt_big_1` `:209291`, W69 H61, **313** objects: pine1×81, oak×53,
  leaftree×29; scale `0.1647..0.7101`.
- `g_frt_big_1` `:323713`, W47 H45, **167** objects dominated by `oak.1..4`
  mesh/material variants (23+17+14+12) — leaf species variety lives *inside*
  the prop, not in separate pattern families.

### 3.2 Stone / quarry families

| Family (`generator.cfg` lines) | Members (Freq) | Objs/pattern | Footprint W×H | Dominant stamped objects |
|---|---|---:|---|---|
| `stoneforests` (802-838) | `str_new_1..8` (×1) | 38–60 | 19–24 × 16–20 | pinesmall1 52, plantain 48, pine1 42, plant 38, leaftree 23, oak 20, smallstones 16, stones 14 |
| `stoneforests_old` (839-875) | `str_1,2`, `b_str_3`, `str_4,5,6`, `b_str_7`, `str_8` (×1) | 29–52 | 16–24 × 11–20 | pinesmall1 54, pine1 46, pinedry1 29, drybushes 20, smallstones 14 |
| `stones` (876-908) | `d_stn_1..7` (×1) | 13–41 | 15–21 × 17–22 | plantain.2 24, firsmall1 13, stones10 11, smallstones.5 11, stones9 11, stones8 9 |
| `desert_stoneforests` (1932-1952) | `desert_stn_5,7,8,12` (×1) | 16–24 | 14–17 × 12–14 | smallstonesdesert.3 10, desert1 9, stonesdesert10 5, palmsmall 5 |
| `desert_stones` (1953-2005) | `desert_stn_1..12` (8×1, four ×0.5) | 14–24 | 13–17 × 12–17 | smallstonesdesert.2/.3 19 each, plantyellow.1 27, stonesdesert10 14, palm 12 |
| `k_rock_*` (orphan, 0 cfg refs) | `k_rock_1..18` | 30 (`k_rock_1`) | 19×18 (`k_rock_1`) | rocksea4 3, stonessea1, smallstonessea.3/4/5/6, pinesmall1 5 [I: shore pass] |

Worked examples **[O]**: `d_stn_1` `pattern.lib:203425`, W20 H18, 34 objects
(`plantain.2`×4, `smallstones.2`×3, `stones9`×3, `pinesmall4.4`×3, scale
`0.1251..0.6098`); `d_stn_7` `:208101`, W21 H17, 41 objects; `str_new_1`
`:718451` W22 H18, 45 objects mixing pines, bushes and `stones1/2/4/8/10`.
**Stone families are deliberately tree+weed+rock clumps**, not bare quarry scars —
the quarry *scar* is a separate terrain/decal effect (F2-02 §4.2, DTRN-05 C14).

### 3.3 Mineral mine families

`mng` = gold, `mni` = iron, `mnc` = coal (`dogenerate.inc:547-551`). Every live
variant is 8×10 cells with `HeightFieldMin=HeightFieldMax=0` — **no relief**, only
props/collision. Exactly one ore prop per stamp, at the stamp's local centre
(`mng_1` ore at `(0,0,-0.25)`, scale `0.315200001001358`).

| Family (`generator.cfg`) | Members (Freq) | Objs/pattern | Ore prop (count) | Other objects |
|---|---|---:|---|---|
| `mng` (69-96) | `mng4`(**0**), `mng_1..5`(1) | 7–16 | `minegold` 1 each | bushes 18, horseradish 10, plantain.3 8, plant.5 7, pinesmall1 4 |
| `mni` (98-125) | `mni4`(0), `mni_1..5`(1) | 7–15 | `mineiron` 1 each | plantain.1 18, bushes 12, plant 8, firsmall1 4 |
| `mnc` (127-154) | `mnc4`(0), `mnc_1..5`(1) | 8–18 | `minecoal` 1 each | plantain.3 17, plantain.1 11, plant 10, pinesmall1 6 |
| `desert_mng` (156-171, shadowed by 1658-1681) | `desert_mng_1_a..3_a`(1) / `mng_1..5`(1) | 7–15 | `minegolds` 1 | plantyellow, palm, plantainyellow, desert1/5 |
| `desert_mni` (173-188, shadowed by 1683-1707) | `desert_mni_1_a..3_a` / `mni_1..5` | 7–14 | `mineirons` 1 | desert1/5, plantyellow |
| `desert_mnc` (190-205, shadowed by 1708-1732) | `desert_mnc_1_a..3_a` / `mnc_1..5` | 8–13 | `minecoals` 1 | plantainyellow, palmsmall3.3, desert5 |

Worked example **[O]**: `mng_1` `pattern.lib:713285` W8 H10, 11 objects:
`plant`×2 (`lib:713324`, scale 0.2779), `bushes`×5, `plantain.3`×2, `fern`×1,
`minegold`×1 (`lib:713408`, scale 0.3152). `mni_1` `:715147` 14 objects,
`mnc_1` `:716813` 13 objects. Desert `desert_mng_1_a` `:1170037` 11 objects with
`minegolds` instead of `minegold` **[O]**.

### 3.4 Season variants

- **[O]** 680/680 `pattern.lib` sections: `NativeSeason = Summer`,
  `Summer/Autumn/Winter/Spring = True`; no winter-named sections. Season is
  therefore **a material choice at prop render time**, not a pattern-family
  choice: `fir.prop:33-43,52-57` (`fir1..3` ↔ `fir1w..3w`), `stones.prop:49-50`
  (`stones` ↔ `stonesw`), `minegold.prop:27-28` (`minegold` ↔ `minegoldw`),
  `pine1.prop:33-43` (`UseableSummerMaterials` / `UseableWinterMaterials`).
- **[O]** `desert_*` families are selected by `season=3` (`bDesert`,
  `dogenerate.inc:4`) and swap to `desert_*` ore props and palm/desert weeds.
- **[O]** `pump` requires `gc_halloween>0 and GetSeasonType<>2` and `christmas`
  requires `gc_christmas>0` (`dogenerate.inc:1848-1851`), while both globals are
  `-1` (`dmscript.global:1668-1669`) — off in shipped text **[D]**.

### 3.5 The object chain (what "stamps a model" actually means)

**[O]** `BaseName` → `objects\env\<name>.prop` (`mainproperty.BaseName`) →
`actorproperty.LODActorName` → `actors.lib` `LODActorName` →
`actors\env\<actor>.actor` → `ActorList.Items[n].MeshObjects.LoadFromFile`
(`.osm`). Verified resolutions:

| BaseName(s) | `.prop` | Actor | Meshes in `.actor` |
|---|---|---|---|
| `minegold`, `mineiron`, `minecoal` | `minegold.prop:1-28` etc. | `minegold` (`actors.lib:1248`) | `minegold.mesh` (single) |
| `minegolds/irons/coals` | `minegolds.prop` etc. | `minegolds` | desert ore mesh |
| `pine1`, `pine1.1`, `pine2.2`, `pine3.3`, `pine4.4` | `pine1.prop:9-17` | `pine` (`actors.lib:1517`) | `pine1..4.mesh` (`pine.actor:2-15`) |
| `pinesmall1`, `pinesmall4.4` | `pinesmall1.prop` | `pinesmall` (`:1521`) | `pinesmall1..4.mesh` |
| `fir`, `fir1.1`, `firsmall1`, `firsmall1.1` | `fir.prop`, `firsmall1.prop` | `fir` / `firsmall` | 4 meshes each |
| `spruce1`, `spruce4.4` | `spruce1.prop` | `spruce` | `spruce1..4.mesh` |
| `oak`, `oak.1..4` | `oak.prop:9-18`, `oak1..4.prop` | `oak` (`:1589`) | `oak1..4.mesh` |
| `leaftree`, `drytree`, `pinedry1` | respective `.prop` | `leaftree`/`drytree`/`pinedry` | 4 meshes each |
| `stones`, `stones1..10`, `smallstones`, `smallstones.1..6` | `stones1.prop` … | `stones` (`:1232`) / `smallstones` | 6 meshes each |
| `rocksea*`, `stonessea*`, `smallstonessea*` (`k_rock_*`) | shore props | `rocksea` etc. | sea-rock meshes |

Suffixes `.1/.2/.3/.4` are **mesh/material variant selectors**, listed with
their own scale/jitter in `envscales.cfg` (e.g. `firsmall1.1` `:202`,
`pine1.1` `:237`, `smallstones.1` `:120`, `plantain.3` `:832`; DEC_03 §4
table). [I] The exact runtime mapping of suffix → mesh index is engine-side and
UNVERIFIED; the prop/actor chain itself is OBSERVED.

### 3.6 What the `.pattern` binary tail is **not**

**[O]/[D]** Read-only byte scan (24-byte stride `[int32 id][4×float32 1.0][4B]`):

| Pattern | bytes | w,h | first record offset | consecutive records | `pattern.lib` Objects |
|---|---:|---|---:|---:|---:|
| `mng_1` | 3,730 | 8×10 | 0x18B = 395 | 63 (to 0x773 = 1,907) | **11** |
| `d_frt_big_1` | 120,560 | 38×57 | 0x29FC = 10,748 | 2,072 | **124** |
| `d_stn_1` | 18,890 | 20×18 | 0x6EF = 1,775 | 323 | **34** |
| `g_hil1` | 99,246 | 32×56 | 0x22B5 = 8,885 | 1,705 | (relief family) |

**DERIVED:** ratios ~5.7× / 16.7× / 9.5× — the 24-byte tail is *not* the
`pattern.lib` object list. Prior art that treated the record count as the object
count (`TERRAIN_DONOR_PATTERNS.md:92-116`, DPATTERN_01 §2.3 "semantics
UNVERIFIED") stays UNVERIFIED; this report **does not promote** the tail as
placement data. The authoritative object contents are the `pattern.lib` records.

---

## 4. Placement weights — decoded algorithm

1. **[O]** Load `generator.cfg` `Patterns`; for each family compute `FreqSum`
   (`misc.script:3532-3563`). `Freq` absent ⇒ set to 1.
2. **[O]** `_misc_SelectPatternListParser(name)` returns the **first** family
   block whose `Name` matches (`misc.script:3568-3580`) — so the second
   `desert_mng/mni/mnc` and second `plain_medium` definitions are shadowed **[D]**.
3. **[O]** `_misc_GetPatternNameByParser` picks by roulette
   `freqrnd = RandomExt*freqsum`, subtract weights in file order (`:3634-3653`).
4. **[O]** `_misc_PatternIncreaseFreq` on a successful stamp does
   `newfreq = max(oldfreq*0.2, 0.0001)`, bumps `UsedCount`/`TotalCount` and
   updates `FreqSum` (`:3588-3629`). **Anti-repetition, not a static probability.**
5. **[O]** `_misc_SetupPatternsByType(freq)` computes
   `needed = floor(W*H*freq)`, `neededround = round(W*H*freq)` (if `needed=0` and
   `freq>0`, round up to 1), `trycount = floor(256*mapsizeoptimise)`, and for each
   needed stamp draws a uniform cell and accepts the first candidate passing
   `_misc_CheckStandPatternExt` (`:3681-3729`).
6. **[D]** At 320×320 with all free-mask modifiers ≡1, the shipped rates
   (`dogenerate.inc:1688-1693,1774-1778,1836-1898`) yield:

   | pass | family | per-family `needed` | families | total |
   |---|---|---:|---:|---:|
   | big conifer | `forests_pinefir_big`, `forests_spruce_big`, `forests_pine_big`, `forests_pine_big_2` | `floor(102400×0.0009/8)=11` | 4 | 44 |
   | mid conifer | `forests_spruce_medium`, `forests_pinefir_medium`, `forests_pine_medium` | `floor(102400×0.0009/6)=15` | 3 | 45 |
   | small conifer | `forests_pinefir_small`, `forests_pine_small` | `floor(102400×0.00054/4)=13` | 2 | 26 |
   | stone | `stones` (stn1 / stn2) | 16 / 12 | 1 | 28 |
   | per start | `stoneforests` 1; `stones` 2; forest 3 | — | 2 starts | 12 |

   Leaf/mixed equivalents (`frs/4`) and `pump`/`christmas` are unreachable in
   shipped text (E6/E15). Desert halves `frs_*` (`dogenerate.inc:1780-1785`).
7. **[O]** Two `SetRandomKey(randkey1)` resets bracket the stages
   (`dogenerate.inc:1772,1909`): relief+mines use one stream, the forest/stone
   pass is re-seeded. `foreststype := floor(RandomExt*3)` consumes one draw before
   being overwritten (`:5-6`).

---

## 5. Concrete donor-grounded placement recipe

Stage order and numbers below are transcribed from the donor text; every literal
has a citation. This is a **specification**, not a port edit.

```
0  seed: randkey1 (and randkey2 per D02); SetRandomKey(randkey1) at start
   foreststype := floor(RandomExt*3); foreststype := 0        # dogenerate.inc:5-6
   bDesert := (season=3)                                       # :4

1  relief pass (mountains/plateau/hills, NOT forest)            # :1743-1766
   then SetRandomKey(randkey1)                                 # :1772

2  per start i: CreateStartPoint                               # :980-988
   a. FillPatternMaskElipse(start, +2, 5, 7)                   # :984, :407-408
   b. SetupMines(start, minround=0, maxround=1, density, spcount)  # :985
      -> rounds = 3/4/5 for density 0/1/2; maxround clamps to 1 ring
      -> loop i=0 only; 3 ores (mng, mni, mnc) x 1 stamp each
      -> desert => 'desert_'+family; 256 angle tries;
         accept first _misc_CheckStandPatternExt; damp Freq x0.2  # :522-557,705-716
   c. SetupStartingResources(start)                            # :986
      - ring cCircle1: 1 stamp from 'stoneforests'
        (or 'desert_stoneforests' v<77 / 'desert_forests_big' v>=77)
        mindst=min(5,7)=5, dst=5+RandomExt*3+((i+j)*0.5),
        128 angles x 3 radial tries                             # :733-767
      - FillPatternMaskElipse(start,+2,12,15)                  # :769, :410-411
      - ring cCircle2: 1 stamp from 'stones' (or desert_stones)
        mindst=min(12,15)=12                                   # :772-805
      - ring cCircle2: 2 stamps from conifer/leaf/mixed medium families
        foreststype=0 => rnd=floor(RandomExt*7) picking one of
        pinefir_medium, spruce_medium, pine_medium, pinefir_big,
        spruce_big, pine_big, pine_big_2                       # :808-861
      - ring cCircle2+4: 1 more 'stones', then 1 more forest     # :863-945
      - FillPatternMaskElipse(start,+2,22,18)                   # :947, :413-414

3  global mines per start: SetupMines(start, minround=1, maxround=0, ...)
   -> loops i=1..rounds-1 => 2/3/4 rings x 3 ores for density 0/1/2
      (distance bands version/size-gated at :559-701)           # :1769-1770

4  re-seed: SetRandomKey(randkey1)                              # :1909
   forest/stone pass, W=320 prob=1:
   frs_big=0.0009, frs_mid=0.0009, frs_small=0.00054,
   stn1=0.00016, stn2=0.00012                                  # :1688-1693
   modifiers: frs_big*=probsmall, frs_mid*=probmid,
              frs_small*=problarge, stn*=probsmall; desert halves frs  # :1774-1785
   needed = floor(W*H*freq); trycount=floor(256*mapsizeopt)    # misc.script:3695-3704
   conifer branch (foreststype=0):
     big:    4 families x frs_big/8   (11 stamps each @320)
     mid:    3 families x frs_mid/6   (15 stamps each)
     small:  2 families x frs_small/4 (13 stamps each)
     stones: stn1 then stn2           (16 then 12)
     swamp/lake/plain passes as in :1899-1906
   For each stamp: name = roulette(family, FreqSum), then up to `trycount`
   uniform (x,y) attempts until _misc_CheckStandPatternExt passes; on success
   damp that member's Freq x0.2.                                # misc.script:3706-3727

5  realised objects for every accepted stamp: iterate the matching
   `pattern.lib` section `Objects` array and instantiate each record with
   RaceName/BaseName, Position (X,Y,Z), Direction, Up (Y-yaw), Scaling
   (X=Y=Z). Example `mng_1`: one `minegold` at (0,0,-0.25) scale 0.3152
   plus 10 weeds/saplings; `d_frt_big_1`: 124 trees/weeds.         # pattern.lib

6  mine build snap (separate from generation): cursor picks nearest
   gold/iron/coal deposit within 1.5 map cells and moves the building to the
   deposit centre; no deposit => invalid. (F2-02 §4.3, dmscript.global:206,
   unit.script:6629-6672; commented GUI callers, activation UNVERIFIED)
```

**Scale/units:** stamp footprints and `Objects[].Position` are in donor map cells
(`dmscript.global:171` `gc_meters_to_tile=2` per F2-02 §4.1); per-object `Scaling`
is the prop-instance scale, and `envscales.cfg` adds jitter for non-mine props.
No metres-per-cell factor is invented here.

---

## 6. Relation to the port's converted assets — **PORT APPROXIMATION**

- **[O] repo** `variant3d/assets/terrain/patterns/donor_patterns.json` stores 43
  families / 282 patterns with only `{w, h, cells}` (e.g. `mng_1` = `w8 h10
  cells32`, `d_frt_big_1` = `38×57 / 920`, `d_stn_1` = `20×18 / 125`). The
  `pattern.lib` `Objects` arrays are **not** exported. Only `mountain_props.json`
  (Z08) carries object records — for `terrainmesh*` relief props, not for
  forest/stone/mine content.
- **[O] repo** Converted terrain meshes exist under
  `variant3d/assets/models/obj/shared/terrain/`: `tree_pine`, `tree_pinesmall1..4`,
  `tree_firsmall1..4`, `tree_spruce1..4`, `tree_pinedry1..4`, `tree_oak`,
  `tree_stump1..4`, `rock_stones1..10`, `rock_smallstones1..6`, `rock_sea*`,
  `christmastree`, `gift1..6`, `terrainmesh1..4`; manifest entries point back to
  donor `.osm`/`.dds` (`manifest.json:2212-2263` for `minegold/mineiron/minecoal`).
  So **the meshes needed to stamp donor object lists are largely already present**.
- **[O] repo / PORT APPROXIMATION** `game.gd:_gen_patterns` (`:740-869`) realises
  `kind=="forest"` by painting a synthetic filled core disc and spawning up to 14
  `wood` nodes per stamp with `rng.randf()<0.30`; `kind=="stone"` paints 1/5 terrain
  tiles and adds `rng.randi_range(4,7)` quarry stones. Donor per-object
  BaseName/Position/Scaling is not consulted. This is the direct explanation of
  the "repeated / generic grove" read; it is a documented approximation, **not**
  donor parity.
- **[O] repo / PORT APPROXIMATION** `pattern_gen.gd:9-13` keeps donor constants
  `CIRCLE1/2/3`, `MINE_RINGS` and the weighted `pick` (`:153-172`), but: (a) no
  `Freq*=0.2` damping after placement; (b) `desert_mng/mni/mnc` union both
  duplicate cfg blocks (8 members vs donor's first-block 3); (c) mine placement
  uses its own cluster RNG and 120° sectors (`:369-427`) instead of donor rings;
  (d) forest recipe counts (`pattern_gen.gd:456-466`) are port-scaled, not the
  derived 11/15/13-per-family values of §4; (e) `stoneforests_old`, `pump`,
  `christmas` are not encoded.
- **[O] repo** Port enrichment (`Data.RICHNESS`) changes mine cluster count
  (`pattern_gen.gd:314,412`) — donor richness changes ring count/deposit amounts
  (`F2-02 §4.1`, `config.gd:580`), a different mechanism **[D]**.

---

## 7. Implications

1. **Implement the object-list export.** A donor-grounded compiler should emit,
   per pattern name, `Objects[] = {base, race, x,y,z, dir, up, scale}` from
   `pattern.lib` (numbers only, no donor binary), and a stamp realiser should
   instantiate those records with the already-converted meshes. This is the
   single largest fidelity gain: it replaces synthetic wood/stone nodes with the
   donor's authored clump shapes and per-object jitter.
2. **Respect the two-level weight system.** Family selection weight (`Freq`) and
   pass frequency (`frs/stn`) are distinct; porting only the roulette without
   `Freq*=0.2` damping will over-repeat the same pattern. Use `needed =
   floor(W*H*freq)` and `trycount = floor(256*mapsizeopt)` at 320.
3. **Preserve stage order and RNG resets.** Relief+mines and forest/stone are
   separate seeded streams (`dogenerate.inc:1772,1909`); collapsing them into one
   RNG stream changes which pattern lands where for the same seed (D02 owner).
4. **Model season as prop material swap**, not separate patterns. All 680 sections
   are Summer; winter albedo already exists in the converted winter material JSON
   (`variant3d/assets/terrain/prop_winter_materials.json`) — verify binding before
   wiring (risk R5).
5. **Forest species gating:** shipped donor always takes conifer (`foreststype=0`).
   A port that randomly mixes leaf/mixed families diverges from the shipped
   text unless the owner deliberately wants the (dead) branch revived; expose it
   as an explicit option with labelled provenance.
6. **Stone read:** quarries are tree+weed+rock clumps plus a terrain/decal scar;
   reproducing bare grey patches is a PORT APPROXIMATION, not the donor clump.
7. **Mine read:** the deposit stamp is 8×10 cells / 7–18 objects / one ore prop;
   the built mine is a 5×5 half-cell mask with a 5×5 dirt plate (F2-02 §4.2).
   These are two different footprints and must not be conflated.
8. **Name mismatches must be resolved explicitly** (`desert_forests_big`,
   `k_pump_1..9`, duplicate family blocks) — a naive cfg→file join silently
   drops 17 desert-big and 9 pump patterns.

---

## 8. Risks

- **R1** `.inc` activation: every placement rule cited is commented
  `[*] = ;` text. It is authoritative-looking intent, not proven execution.
- **R2** `pattern.lib` sections are duplicated for 15 names (mostly `x#y#`
  coordinate sections); a naive dict keyed by `Name` collapses 680 → 665 and
  can silently drop object lists. The parser used here kept last-seen sections;
  family members queried above were checked against direct section scans.
- **R3** The 24-byte `.pattern` tail (63/2072/323 records) has unknown semantics.
  Do not treat its count or IDs as object/prop references.
- **R4** Object suffix semantics (`.1/.2/.3/.4`) are inferred from `envscales.cfg`
  variant entries; exact mesh-index binding is engine-side.
- **R5** Converted terrain OBJs collapse donor variants (e.g. donor `pine1..4.mesh`
  → port `tree_pine` single OBJ; donor `stones1..10` → `rock_stones1..10`).
  Instantiating all donor object records through the current manifest may
  repeat identical meshes; provenance must be labelled.
- **R6** Port asset paths in `manifest.json` still point at donor absolute paths
  as provenance metadata (`manifest.json:2212-2263`); derived OBJ/PNG copies only
  live in `variant3d/assets/models/**`. No donor asset was copied this session.
- **R7** Desert ore props (`minegolds/irons/coals`) appear in `pattern.lib` but
  are not in the converted summer terrain mesh set inventoried here — verify
  before wiring desert mines (UNVERIFIED).
- **R8** Any visual statement about how the resulting groves/quarries *look* is
  INFERRED; no donor GPU frame was captured in this lane.

---

## 9. UNVERIFIED register (do not promote)

1. Runtime execution of every `[*] = ;` line in `dogenerate.inc`, `generatemap.inc`.
2. Semantics of `.pattern` 24-byte tail records (`int32 id`, 4×1.0f, 4B) and the
   parallel `int16 0xffff` flags; count ≠ `pattern.lib` Objects count (E11).
3. Whether the engine normalises mismatched family names
   (`n_desert_frt_big1` vs `_big_1`, `k_pump_1` vs `k_pump_01`) or those picks
   simply fail; effect on `desert_forests_big` / `pump`.
4. Which duplicate family block actually wins in the OSW parser at runtime
   (first-match in text is OBSERVED; load-time merge semantics UNVERIFIED).
5. Suffix `.N` → concrete mesh/material index for tree/rock variants.
6. Exact metres-per-cell and pattern height-grid sculpt blend (D05 scope).
7. Engine-side `StandPatternWithAngle` transform math: how `Objects[].Up`
   yaw maps to a world rotation, and whether all records or a random subset
   are instantiated per stamp (Z08 §2.3 / Z06 §7 Q1).
8. Runtime values of `probsmall/mid/large/huge` and `minesdensity` for a given
   lobby "Minerals" setting; §4 counts assume ≡1 and density 0/1/2 mapping.
9. Availability/converted state of `minegolds/mineirons/minecoals`, `rocksea*`,
   `desert*` palm meshes in `variant3d/assets/models/**`.
10. All visual parity: no donor A/B frame; no claim made.

---

## 10. Open questions

- Q1 (D07/F01): can the `.pattern` tail be decoded as *per-cell gameplay
  attributes* (collision/resource flags) rather than objects? A 1:1 relation is
  refuted; a per-cell relation is still possible.
- Q2 (D02/A02): confirm the exact `SetRandomKey` call sites and RNG draw order
  around `foreststype` so a seed replay matches the donor stream.
- Q3 (F09): does any other script re-enable `foreststype=1/2` or the shadowed
  duplicate families at runtime?
- Q4 (F10/A03): do DLC/expansion data add forest/stone/mine families beyond the
  64 blocks in `generator.cfg` (e.g. `terrainmasks.dlc5` patterns)?
- Q5: should the port reproduce the donor's `Freq` damping inside a single
  generation call, given that port stamps are re-built on every map load?
- Q6: can `pattern.lib` `Objects` be exported into a compact JSON without
  committing donor binaries, and verified byte-exactly against the cited lines?

---

*End of F08. One report written. Donor READ ONLY; no binary run or copied; no
port file, gate, git state or runner job changed. No donor parity claim.*
