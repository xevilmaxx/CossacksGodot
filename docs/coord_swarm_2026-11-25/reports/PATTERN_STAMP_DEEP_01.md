---
id: PATTERN-STAMP-DEEP-01
title: "Donor relief stamps: height-grid sculpt vs 3D props — and whether they explain pale marks"
agent: "Donor deep-dive worker — 3 independent passes (read-only subagent, coord swarm 2026-11-25)"
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
donor: "C:\\Games\\Cossacks 3 (private-use reference; bytes/latin-1, struct.unpack_from, numpy.frombuffer, PIL DDS; never executed, written or copied)"
output: "docs/coord_swarm_2026-11-25/reports/PATTERN_STAMP_DEEP_01.md"
scope: "Fresh donor pattern.lib/.pattern/.actor/.prop/.osm/DDS reads; read-only port source comparison; no synthetic hills, no code edits, no runner jobs"
passes: "P1 binary decode+stats; P2 raw pattern.lib section text with path:line + field/object scan; P3 prop-asset byte decode + donor tile-art/plaintext consumer scan"
labels: [observed, derived, inferred, UNVERIFIED]
verdict: "FOR THE FIVE AUDITED PATTERNS THE VISUAL RELIEF IS A HEIGHT DEFORMATION (non-zero float32 grid, HeightFieldStand=True, NO terrainmesh/terrainplateau object); MOUNTAIN RELIEF IS A PROP MESH (terrainmeshN, zero height grid). NO DONOR PATTERN OPERATION WRITES PALE TILE IDS/COLOUR — pale pixels exist in donor tile ART placed by a separate global detail-bitmap/smoothing pass, not by a stamp."
parity_guard: "PORT APPROXIMATION only. No donor GPU A/B frame was produced; no donor parity is claimed anywhere in this report."
---

# PATTERN-STAMP-DEEP-01 — donor relief sculpting vs props, and the pale-mark question

> [!IMPORTANT]
> Donor is truth. Every donor statement below is **observed** (literal `path:line`
> or decoded bytes with the offset stated), **derived** (arithmetic/control-flow
> consequence of observed data), **inferred** (best reading, caveat given), or
> **UNVERIFIED** (not provable from the files read). Three independent passes
> were made over the same questions (see §2). No Godot process was run; no donor
> file was executed, copied or modified; no repo source, asset, config, test or
> JSON was edited. **No donor parity claim is made.**

---

## 1. Mandate

1. Fresh-read five donor relief patterns (`plt2`, `hil1`, `k_ravine_1`,
   `f_plt_big_1`, `g_hil4`): sculpt config, season, and the **exact embedded
   height-grid arrays**; derive how the grid is applied (additive? max? blend?).
2. From `.prop`/`.actor`/`.osm` bytes decide whether the visual hill is a prop
   mesh or a height deformation, and resolve the contradictory prior claims.
3. Decide whether any **pattern operation** writes bright/pale TILE ids or colour
   on otherwise flat land (the owner's "white marks").
4. Read-only port comparison: `pattern_gen.gd`, `game.gd:_shape_stamp_relief()`,
   `world3d_terrain.gd` relief reader — exact mismatches with owners.

---

## 2. Sources and pass structure

### 2.1 Donor plaintext (read in place, bytes → latin-1)

| # | Donor path | Role / exact lines cited |
|---|---|---|
| T1 | `data\pattern\pattern.lib` | 30,309,138 B; 680 top-level sections (fresh parse). Sections: `plt2` `:6775-13507`, `hil1` `:33081-34745`, `k_ravine_1` `:549555-555363`, `f_plt_big_1` `:272109-283909`, `g_hil4` `:366469-369365`, `g_mnt_1` `:337462+` |
| T2 | `data\scripts\common.inc\generatemap.inc` | constants `:4-7`; R codes `:21-27`; mask sample `:537-543`; height formula `:565-574`; `cSmoothTile=True` `:43`, `SmoothTiles` call `:781-786` |
| T3 | `data\scripts\common.inc\dogenerate.inc` | relief probabilities `:1621-1650`; size modifier `:1715-1725`; family setup `:1749-1765`; `ravine_medium` `//`-disabled `:1760`; prop scale exemption `:1984-1985` |
| T4 | `data\scripts\lib\misc.script` | `_misc_StandPatternPlaceMask` `:3325-3380`; getters `:3330-3333,3361-3370`; `_misc_CheckStandPattern` `:3384`; `StandPatternWithAngle` `:3390`; getters `:3402-3405,3434-3461` |
| T5 | `data\scripts\common.inc\texturemap.inc` | `cDiff1/cDiff2` `:63-64`; water/collision `:66-72`; 2× collision grid `:133-138`; rock8/rock4 gates `:594-601` |
| T6 | `data\scripts\common.inc\loadtextureterrainfrombitmap.inc` | `tile_lowground.bmp`/`tile_highground.bmp` `:8-9`; `h<0.1` gate `:26-29`; `tex=r div 2`, `SetTileIndex` `:32-41` |
| T7 | `data\scripts\common.inc\smoothtiles.inc`, `data\gen\tilesmooth_scripts.cfg` | smoothing driver `:189-242`; `test7/test8/test9` transition lists e.g. `:166,262,270,354,370,475,491,596,604,705,741,849-854,873` |
| T8 | `data\terrain\tiles\tiles.lib` / `tiles.mat` | `test7` index `:320` → `test7.dds` `:316`; `test8` `:323` → `test8.dds` `:319`; `test9` `:326` → `test9.dds` `:323`; `rock4` `:101` → `rock4.dds` `:84`; `rock8` `:113` → `rock8.dds` `:100` |
| T9 | `data\actors\actors.lib` | `terrainmesh1..4` `:1200-1213`; `terrainplateau1..4` `:1216-1229` |
| T10 | `data\actors\env\terrainmesh{1..4}.actor`, `terrainplateau{1..4}.actor` | one `MeshObjects.LoadFromFile = …\.osm` each; **no scale field** |
| T11 | `data\objects\env\terrainmesh{1..4}.prop`, `terrainmeshdesert1.prop` | season material swap `:16-18`; **no scale/offset field**; **no `terrainplateau*.prop` files exist** |

### 2.2 Donor binaries decoded read-only

| # | Path | What was decoded (pass) |
|---|---|---|
| B1 | `data\pattern\{plt2,hil1,k_ravine_1,f_plt_big_1,g_hil4,g_mnt_1}.pattern` | int32 `w,h` header; `w*h` u8 cell grid; `w*h` float32 grid at stated offset G; min/max/mean/zeros/distinct; exact centre-row bytes and floats (P1) |
| B2 | `data\actors\env\terrainmesh{1..4}.osm`, `terrainplateau{1..4}.osm` | IDP2 68-byte header, `nv/nu/nt`, `of/oe`, closure `of+16+nv*16==oe==filesize`, vertex bbox (P3) |
| B3 | `data\terrain\tiles\textures\{test7,test8,test9,rock4,rock8,grass1}.dds` | 1024² RGBA via PIL; max RGB, mean RGB, luma>180 pixel counts (P3) |

### 2.3 Prior docs read (orientation only, not new donor evidence)

`DPATTERN_01_relief_grids.md`, `DTRN_02_donor_terrain_geometry.md`,
`PIECES/{plateau,hill_ridge,ravine_face,verdict_grass_relief}.md`,
`TERRAIN_PORT_HILLS.md`, `RELIEF_LIVE_DIAG_01.md`, `TERRAIN_MARKS_01.md`.

### 2.4 Port files read only (no edit)

`variant3d/scripts/pattern_gen.gd`, `variant3d/scripts/game.gd`,
`variant3d/scripts/world3d_terrain.gd`, `variant3d/scripts/main.gd`,
`variant3d/scripts/config.gd`,
`variant3d/assets/terrain/patterns/donor_patterns.json` (also the `app/` mirror).

### 2.5 Pass ledger

| Claim | P1 binary | P2 text/line | P3 asset/plaintext | Verdict |
|---|---|---|---|---|
| Grid min/max = `HeightFieldMin/Max` for all 5 | ✔ 5/5 exact float32 | ✔ literals at cited lines | — | **observed** |
| No `terrainmesh`/`terrainplateau` object in the 5 patterns | — | ✔ 0 hits / 239+58+206+420+102 BaseNames | ✔ `.actor`/`.prop`/`.osm` exist but unreferenced | **observed** |
| Mountain props are `terrainmeshN`, plateau props unreferenced | — | ✔ 30 sections w/ terrainmesh; 0 w/ terrainplateau | ✔ files exist | **observed** |
| No plaintext consumer of sculpt fields | — | ✔ field tokens only in pattern.lib (680 each) | ✔ `GetPattern*` getters are mask/offset only | **observed** |
| Pale tile art exists in donor DDS | — | ✔ tile names + smoothing lists | ✔ PIL max RGB measured | **observed** |
| Pattern operation writes pale tile ids | — | ✔ no tile/colour field in 5 sections | ✔ trailing records are float flags, not ids | **UNVERIFIED → no mechanism found** |

---

## 3. Pattern parameter tables (fresh, with `path:line`)

### 3.1 Identity / flags / season

| Pattern | Section (`pattern.lib`) | w×h (`pattern.lib`) | `HeightFieldStand` | `TilesStand` | `DecalsStand` | `GameObjectsStand` | `CollisionStand` | `NativeSeason` | `Winter` | `ObjectsScale` |
|---|---|---|---|---|---|---|---|---|---|---|
| `plt2` | `:6775-13507` | 42×55 `:6777-6778` | True `:6782` | True `:6779` | True `:6781` | True `:6780` | True `:6798` | Summer `:6808` | True `:6811` | 1 `:6790` |
| `hil1` | `:33081-34745` | 25×41 `:33083-33084` | True `:33088` | True `:33085` | True `:33087` | True `:33086` | True `:33104` | Summer `:33114` | True `:33117` | 1 `:33096` |
| `k_ravine_1` | `:549555-555363` | 46×63 `:549557-549558` | True `:549562` | True `:549559` | True `:549561` | True `:549560` | True `:549578` | Summer `:549588` | True `:549591` | 1 `:549570` |
| `f_plt_big_1` | `:272109-283909` | 81×93 `:272111-272112` | True `:272116` | True `:272113` | True `:272115` | True `:272114` | True `:272132` | Summer `:272142` | True `:272145` | 1 `:272124` |
| `g_hil4` | `:366469-369365` | 33×59 `:366471-366472` | True `:366476` | True `:366473` | True `:366475` | True `:366474` | True `:366492` | Summer `:366502` | True `:366505` | 1 `:366484` |

All five: `Summer/Autumn/Winter/Spring = True` (e.g. `plt2 :6809-6812`), so
there is no season-specific height grid (matches DPATTERN-01 §3 season finding;
**observed**).

### 3.2 Sculpt numerics (`pattern.lib` literals)

| Pattern | `HeightFieldScale` | `HeightFieldMin` | `HeightFieldMax` | `HeightFieldOffset` | `HeightFieldSmooth` (radius/factor/offset) | `HeightFieldReplace` | `ReplaceForWater` | `UseRndScale` | `TerrainScale` |
|---|---|---|---|---|---|---|---|---|---|
| `plt2` | 1 `:6788` | −0.0732548981904984 `:6805` | 3.61341166496277 `:6806` | 0 `:6807` | False `:6792` (2/4/0 `:6793-6795`) | False `:6783` | True `:6784` | False `:6785` | 1 `:6789` |
| `hil1` | **0.649999976158142** `:33094` | 0 `:33111` | 3.86130237579346 `:33112` | 0 `:33113` | False `:33098` (2/4/0 `:33099-33101`) | False `:33089` | True `:33090` | False `:33091` | 1 `:33095` |
| `k_ravine_1` | 1 `:549568` | −2.963627576828 `:549585` | 3.13982009887695 `:549586` | 0 `:549587` | False `:549572` (2/4/0 `:549573-549575`) | False `:549563` | True `:549564` | False `:549565` | 1 `:549569` |
| `f_plt_big_1` | 1 `:272122` | 0 `:272139` | 2.96362733840942 `:272140` | 0 `:272141` | False `:272126` (**3/4/2** `:272127-272129`) | False `:272117` | **False** `:272118` | False `:272119` | 1 `:272123` |
| `g_hil4` | 1 `:366482` | −4.32127315701247E−13 `:366499` | 1.91698789596558 `:366500` | 0 `:366501` | **True** `:366486` (3/4/2 `:366487-366489`) | False `:366477` | True `:366478` | False `:366479` | 1 `:366483` |

Notable fresh observations (**observed**): `hil1` is the only one with a
non-unit `HeightFieldScale` (0.65); `g_hil4` is the only one with
`HeightFieldSmooth=True`; `f_plt_big_1` is the only one with
`HeightFieldReplaceForWater=False` and non-zero smooth offset (2); all five
have `HeightFieldReplace=False` and `TerrainScale=1`.

### 3.3 Exact embedded height grids (binary decode)

| Pattern | file bytes | chosen G (byte offset) | nominal `8+w*h` | decoded min / max | MATCH vs `pattern.lib` | mean | zeros | distinct | at min / at max |
|---|---:|---:|---:|---|---|---:|---:|---:|---|
| `plt2` | 128,804 | **2266** | 2318 | −0.07325489819049835 / +3.6134116649627686 | ✔ exact | 0.812417 | 435 | 1817 | 2 / 1 |
| `hil1` | 55,948 | **1000** | 1033 | 0.0 / +3.861302375793457 | ✔ exact | 0.536347 | 408 | 555 | 408 / 1 |
| `k_ravine_1` | 162,260 | **2866** | 2906 | −2.963627576828003 / +3.139820098876953 | ✔ exact | −0.195773 | 1177 | 1695 | 2 / 1 |
| `f_plt_big_1` | 427,580 | **7344** | 7541 | 0.0 / +2.963627338409424 | ✔ exact | 0.760027 | 3279 | 3570 | 3279 / 303 |
| `g_hil4` | 108,020 | **1912** | 1955 | −4.321273157012473e−13 / +1.9169878959655762 | ✔ exact | 0.353113 | 354 | 1587 | 1 / 1 |

**Byte-boundary caveat (UNVERIFIED):** the float-plane start is not uniquely
determinable from bytes. For `plt2` 101 offsets from 2266 onward reproduce the
same min/max because of long zero runs; for `f_plt_big_1` 125 offsets in
`7300..7796` reproduce min/max, and the chosen G=7344 begins inside the
`0x01` mask tail (first 6 floats decode as `0x01010101` = 2.37e−38, **observed**
hex `0101010101010101…`). Fresh check: `g_mnt_1` at G=1562 is all-zero (min=max=0),
but at nominal `8+w*h=1642` it contains sixteen `1.0` values — using the wrong
offset fabricates relief. The offsets above are the DPATTERN-01 authoritative
values; they reproduce every number in this report exactly. Row order is file
order `idx=v*w+u`; the file-row → map-row sign flip remains **UNVERIFIED**.

#### 3.3.1 Exact bytes (first 12 floats of each chosen window, little-endian hex)

```
plt2        G=2266  822038ba2aca28bb045a2abb783e40bb936088bb9420dabb44621ebca6b44fbc6913ddbb20ffab39a9962b3b712bf03a
hil1        G=1000  145c603b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
k_ravine_1  G=2866  cb03ceb9109f9dba9ebd02bb947821bbbdc821bb2a8d89bb9bcf9cbaf0f8ccbaf2778ebb012d98bbaef734bb00000000
f_plt_big_1 G=7344  010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000
g_hil4      G=1912  121ff834f4e934359b22e135286a5035140135353c211235fb72d6340000000000000000000000000000000000000000
```

#### 3.3.2 Exact centre-row arrays (`row = h//2`, float32 → Python float, file order)

```
plt2 row 27 (42 values):
[2.6911215782165527, 3.0058860778808594, 3.2708942890167236, 3.450568437576294, 3.5032310485839844, 3.44830060005188, 3.4094767570495605, 3.3725056648254395, 3.3326895236968994, 3.287485122680664, 3.235680341720581, 3.1771838665008545, 3.113049030303955, 3.046844720840454, 2.982727527618408, 2.9246301651000977, 2.8760323524475098, 2.7232065200805664, 2.1652095317840576, 1.4276858568191528, 0.8011850118637085, 0.30674508213996887, 0.21701285243034363, 0.13251416385173798, 0.07637734711170197, 0.04221314564347267, 0.021528350189328194, 0.008041628636419773, 0.0025891494005918503, -0.0013489711564034224, 0.0, -0.0020590575877577066, -0.0037597822956740856, -0.006171426735818386, -0.00805642269551754, -0.007100189570337534, -0.0044112433679401875, -0.01156863197684288, 0.06011763960123062, 0.40215685963630676, 1.3146666288375854, 2.223803758621216]

hil1 row 20 (25 values):
[3.050211191177368, 3.49788236618042, 3.539128065109253, 3.1317358016967773, 2.556443452835083, 2.1734654903411865, 2.047785758972168, 1.9453164339065552, 1.7872915267944336, 1.5261485576629639, 1.1725001335144043, 0.45500004291534424, 0.14000001549720764, 0.0, 0.0, 0.0, 0.0, 0.26249998807907104, 0.4025000035762787, 0.4024999737739563, 0.770000159740448, 1.3715605735778809, 1.7779061794281006, 2.158097743988037, 2.667076587677002]

k_ravine_1 row 31 (46 values):
[-2.9593429565429688, -2.9603114128112793, -2.9290037155151367, -2.678358554840088, -2.0585403442382812, -1.714810848236084, -0.9764026403427124, 0.10443319380283356, 0.9830064177513123, 0.27104008197784424, 0.061201199889183044, 0.014140373095870018, 0.008179490454494953, 0.002586978953331709, 0.0006696960772387683, 0.00015890237409621477, 3.5673197999130934e-05, 7.642283890163526e-06, 1.5679438547522295e-06, 3.091244593633746e-07, 5.878592901353841e-08, 1.0825230489786009e-08, 1.9374417625783735e-09, 3.3814170907753294e-10, 5.712859005302384e-11, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.019696490839123726, 0.18172737956047058, 0.45327743887901306, 0.8456542491912842, 1.402256965637207, 1.9976673126220703, 2.6081502437591553, 1.9957492351531982, 0.2252374291419983, -1.5961875915527344, -2.6068382263183594, -2.8260107040405273, -2.9207139015197754]

f_plt_big_1 row 46 (81 values):
[1.2487113053794019e-05, 1.889058466986171e-06, 2.8208788194206136e-07, 4.1671057715575444e-08, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.00660231988877058, 0.082743801176548, 1.6073039770126343, 2.295419216156006, 2.8787293434143066, 2.95283842086792, 2.9622559547424316, 2.9634530544281006, 2.9636054039001465, 2.9636247158050537, 2.9636270999908447, 2.963627338409424, 2.963627338409424, 2.963627338409424, 2.963627338409424, 2.963627338409424, 2.963627338409424, 2.963627338409424, 2.963627338409424, 2.9628818035125732, 2.9623923301696777, 2.9619317054748535, 2.9601364135742188, 2.9621894359588623, 2.962799310684204, 2.963165521621704, 2.9635696411132812, 2.963620185852051, 2.9636266231536865, 2.963627338409424, 2.963627338409424, 2.963627338409424, 2.963627338409424, 2.963627338409424, 2.963627338409424, 2.963627338409424, 2.963627338409424, 2.963627338409424, 2.963627338409424, 2.9636270999908447, 2.963624954223633, 2.96327805519104, 2.963244915008545, 2.9635536670684814, 2.9635791778564453, 2.9636216163635254, 2.9636268615722656, 2.963627338409424, 2.963627338409424, 2.963627338409424, 2.963627338409424, 2.963627338409424, 2.963627338409424, 2.963627338409424, 2.9636270999908447, 2.9636247158050537, 2.9636054039001465, 2.9627301692962646, 2.165910482406616, 0.9746464490890503, 0.2554299831390381, 0.0065206438302993774, 0.0009306799038313329, 0.00013213542115408927]

g_hil4 row 29 (33 values):
[0.92824387550354, 1.3724733591079712, 1.651113748550415, 1.7976734638214111, 1.8656270503997803, 1.833112359046936, 1.7342876195907593, 1.5806440114974976, 1.327527642250061, 0.7596449255943298, 0.7118631601333618, 0.571073591709137, 0.44857245683670044, 0.316189706325531, 0.3160342276096344, 0.29098373651504517, 0.22006411850452423, 0.10765554010868073, 0.05372728407382965, 0.027711842209100723, 0.012423330917954445, 0.0, 0.0, 0.0, 0.0, 0.000998242641799152, 0.009966881014406681, 0.02944541722536087, 0.06279444694519043, 0.11108770221471786, 0.16815632581710815, 0.23189927637577057, 0.29838985204696655]
```

Derived shape reading: `plt2` has a broad flat cap ≈3.0–3.5 with a small
negative rim; `hil1` a narrow crest ≈3.54 attenuated by `HeightFieldScale=0.65`
to ≈2.30 effective; `k_ravine_1` a −2.96 floor with an asymmetric +3.14 lip;
`f_plt_big_1` a wide ≈2.9636 cap; `g_hil4` a ≈1.87 crest with a zero surround
and a smoothing flag. These are **derived** from the exact arrays above.

---

## 4. How the grid is applied — additive / max / blend?

### 4.1 Decisive negative (observed)

A fresh full-text scan of all `data\**\*.{script,inc,cfg,lib,global,txt,ini}`
files gives:

| Token | Total hits | Files |
|---|---:|---|
| `TilesStand` | 680 | `pattern\pattern.lib` only |
| `DecalsStand` | 680 | `pattern\pattern.lib` only |
| `HeightFieldStand` | 680 | `pattern\pattern.lib` only |
| `HeightFieldScale` | 680 | `pattern\pattern.lib` only |
| `HeightFieldMin` / `Max` | 1360 each | `pattern\pattern.lib` only |
| `HeightFieldOffset` | 680 | `pattern\pattern.lib` only |
| `HeightFieldSmooth*` | 2720 | `pattern\pattern.lib` only |
| `HeightFieldReplace` | 1360 | `pattern\pattern.lib` only |
| `TerrainScale` | 680 | `pattern\pattern.lib` only |
| `CollisionStand` | 680 | `pattern\pattern.lib` only |
| `ObjectsScale` | 683 | `pattern.lib` 680 + `dogenerate.inc:2055` (commented) + `misc.script:3805,3810` |
| `PatternMaskStand` | 682 | `pattern.lib` 680 + `misc.script:3361,3434` |

Every `GetPattern*` call in donor plaintext is a **mask or offset getter**:
`GetPatternMaskWidth/Height` (`:3330-3331,3402-3403`),
`GetPatternOffsetX/Z` (`:3332-3333,3404-3405`),
`GetPatternMaskStand`/`GetPatternInvMaskStand` (`:3361-3362,3434-3435`),
`GetPatternMaskValue` (`:3370,3460`). The engine call that consumes the whole
pattern is `StandPatternWithAngle(plHnd, patName, standX, standZ, angleRad, 0, 90)`
at `misc.script:3390` — **native, engine-side**. There is **no plaintext script
that reads a height sample or chooses the blend**. Therefore the operation
(additive / max / blend) is **UNVERIFIED** — it cannot be proven from the files read.

### 4.2 Best defensible derivation (labelled)

From observed config and grid values:

- `HeightFieldStand=True` on all five ⇒ the height payload is applied at all
  (**inferred**).
- Grids contain both negative (`k_ravine_1` min −2.9636, `plt2` min −0.0733) and
  positive values ⇒ a pure `max(base, grid)` cannot produce a cut; **derived**
  rejection of max-only for ravines/plateau rims.
- `HeightFieldReplace=False` on all five ⇒ not a wholesale replace of the base
  cell (**inferred**); `ReplaceForWater=True` on four of five ⇒ a water-specific
  override exists (**inferred**, semantics UNVERIFIED).
- `HeightFieldScale` multiplies each sample (**inferred**); `Min/Max` clamp the
  result (**inferred**); `Smooth` applies an unknown local filter
  (**UNVERIFIED**, radius/factor/offset are literals only).
- The decoded grid min/max equal the clamp literals **exactly** for 5/5
  (**observed**) — exporting the clamp values is safe; the *operation* is not.
- Cross-check: donor plateau cap `plt2` max +3.6134 **exceeds** the baked map
  ceiling `cPlateauHeight=2.964` (`generatemap.inc:4`) — derived consequence:
  clamp order (stamp clamp vs baked-map clamp) materially changes the visible
  cap and is engine-side UNVERIFIED.

Safe port reading (this is the form actually used in the port — §7):

```
h_final = clamp(h_base * TerrainScale + grid[v*w+u] * HeightFieldScale
                + HeightFieldOffset, HeightFieldMin, HeightFieldMax)
if HeightFieldSmooth: local_smooth(radius, factor, offset)   # definition UNVERIFIED
# PORT APPROXIMATION — donor engine blend Replace/Smooth/clamp order UNVERIFIED
```

---

## 5. Donor stamping algorithm (reconstructed, with citations)

```
# A. BASE HEIGHT (donor intent, live "[*] = ;" text)
mask = choose(data/gen/terrainmasks.src/.../*.tga)         # generatemap.inc:537-543
for (x,y) in map:                                          # :556-575
    (fr,fg,fb,fa) = GetBitmapPixel(mask, floor(x/W*Wm), floor(y/H*Hm))  # :541-543
    if bRandomMap and fr=1 and fb=1: continue              # start pixel :565-566
    hwater   = -1.1 * fb * (1 + fr*3.5)                    # :567 (cWaterHeight :7)
    hterrain = { +2.964*fr  if R=plateau (255/191)         # :4, :21, :25, :570
               { +1.3173*fr if R=hill    (96/112)          # :5, :22, :26, :571
               { -2.964*fr  if R=ravine  (48/88)           # :6, :23, :27, :572
    SetHeightData(floor(lx+x), floor(ty+y), hwater+hterrain) # :559-574

# B. RELIEF FAMILIES (stage 9)
if relieftype>4: relieftype := floor(RandomExt*5)          # dogenerate.inc:1621-1622
(plt,mnt,hil) := probability_table[relieftype]             # :1625-1650
modifier := 640/((W+H)/2)  when W<>640 or H<>640            # :1718-1725
(mnt,plt,hil) *= problarge                                 # :1737-1739
SetupPatternsByType: mountains mnt; plateau_big plt/3;     # :1757-1765
   plain_huge pln_huge; ravine_big plt/1.5; plateau plt/3;
   plateau_small plt/3; hills_dark hil/2; hills_light hil/2
#   ravine_medium is //-DISABLED at :1760; k_ravine_1..9 configured but not stamped
pat := weighted_pick(family, generator.cfg Freq)           # generator.cfg families

# C. PLACE + STAMP
_misc_CheckStandPattern(pat, plHnd, x, z, angle, doStand)  # misc.script:3384
   maskStand := GetPatternMaskStand(pat)                   # :3361,3434 (config!)
   maskValue := GetPatternMaskValue(pat, i-vMinY, j-vMinX) # :3370,3460
   if doStand: StandPatternWithAngle(plHnd, pat, x, z, ...) # :3390
   -> engine applies mask + height field + objects/decals  # engine-side, UNVERIFIED blend

# D. COLLISION / ROCK ART from the SAME field
cDiff1=0.5, cDiff2=0.55                                    # texturemap.inc:63-64
2x sampler: realx = lx + x/2 + 0.25                        # :133-138
rock8 if abs(h)>2.7; rock4 if >2.4; none if abs(h)<0.1     # :594-601
```

**Port-relevant consequence:** the height sculpt and the props are two payloads
of the same `StandPatternWithAngle` call, but the sculpt is engine-side and the
props are explicit `Objects` records in `pattern.lib`. They must be ported as
two separate mechanisms.

---

## 6. Prop-vs-height verdict (resolving the contradictory prior claims)

### 6.1 The five audited patterns = HEIGHT DEFORMATION, not relief props

Fresh `Objects : struct` BaseName histogram (P2):

| Pattern | Object records | Distinct names | `terrainmesh`/`terrainplateau` records | Relief-like object records |
|---|---:|---:|---:|---|
| `plt2` | 239 | 25 | **0** | 22 `stones`/`smallstones.*` e.g. `pattern.lib:6900,6928,6984,7068,…` |
| `hil1` | 58 | 6 | **0** | 0 (firsmall1 22, pinesmall1 19, plantain.1 6, pine1 6, flowers 3, grass.1 2) |
| `k_ravine_1` | 206 | 12 | **0** | 0 (plantain 48, pine1 35, firsmall1 34, fir 30, flowers 26, …) |
| `f_plt_big_1` | 420 | 16 | **0** | 0 (plantain 110, pine1 79, pinesmall1 78, firsmall1 51, fir 43, …) |
| `g_hil4` | 102 | 13 | **0** | 0 (spruce1 28, chamomile.1 17, firsmall1 14, fir 11, plantain 9, …) |

All five have `HeightFieldStand=True` and a non-zero grid whose min/max match
config exactly (§3.3). **Verdict (observed + derived):** for these five, the
hill/plateau/ravine *shape* is a **height deformation stored in the `.pattern`
float grid**; the objects are vegetation (and, for `plt2`, small stones), not a
relief mesh. The prior claim "plateau/hill patterns are only object clumps,
plaintext never adds height from a stamp" (`PIECES/plateau.md:41-46`,
`PIECES/hill_ridge.md:59-60`, `TERRAIN_PORT_HILLS.md:167-169`) is **corrected
for the sculpt half** by the decoded grid and `HeightFieldStand=True` — but it
was right about the *plaintext*: no script adds the height; the native engine
does (`misc.script:3390`; §4.1).

### 6.2 Mountains = PROP MESH with a zero height grid

Fresh full-file scan (P2): **30** pattern sections have `BaseName` containing
`terrainmesh` (g_mnt_1..7, i_mnt_big_1..5, i_mnt_long_1..5, desert_mnt_1..13);
**0** sections reference `terrainplateau*`. Examples:
`g_mnt_1 → terrainmesh4 @pattern.lib:338482`, `terrainmesh3 :338874`,
`terrainmesh2 :339322`, `terrainmesh4 :339686`, `terrainmesh3 :339854`;
`g_mnt_3 → terrainmesh1 @:344362`. `g_mnt_1` config has
`HeightFieldMin=0`/`Max=0` (`pattern.lib:337491-337492`) and its grid at G=1562
is **all 1,634 floats zero** (fresh decode; at nominal G=1642 it falsely shows
sixteen `1.0`s from the mask tail).

Asset bytes (P3), all closure checks true:

| Prop | `.osm` bytes / `nv` / `nu` / `nt` | bbox x / y / z | actor | prop |
|---|---|---|---|---|
| `terrainmesh1` | 191,356 / 2,662 / 2,662 / 5,305 | [−14.0205,13.8877] / [−13.5237,13.4457] / [0.0700,**7.4485**] | `terrainmesh1.actor:3-4` | `terrainmesh1.prop:4-18` |
| `terrainmesh2` | 163,452 / 2,272 / 2,273 / 4,532 | [−13.2274,13.0921] / [−12.6664,12.9535] / [−0.0251,**8.0346**] | `terrainmesh2.actor:2-3` | `terrainmesh2.prop:4-18` |
| `terrainmesh3` | 156,092 / 2,177 / 2,170 / 4,323 | [−12.9348,12.9880] / [−12.8390,12.9765] / [0.0106,**9.5503**] | `terrainmesh3.actor:2-3` | `terrainmesh3.prop:4-18` |
| `terrainmesh4` | 201,604 / 2,509 / 5,158 / 5,002 | [−12.6697,12.6697] / [−12.8276,12.8276] / [0.0125,**6.9330**] | `terrainmesh4.actor:2-3` | `terrainmesh4.prop:4-18` |
| `terrainplateau1` | 25,540 / 472 / 472 / 586 | [−10.8806,11.3491] / [−12.3489,11.3131] / [−5.3496,5.3496] | `terrainplateau1.actor:2-3` | **prop file absent** |
| `terrainplateau2` | 15,788 / 231 / 239 / 418 | [−8.7753,8.7753] / [−5.6059,5.6059] / [−0.2393,10.9325] | `terrainplateau2.actor:2-3` | **prop file absent** |
| `terrainplateau3` | 45,340 / 645 / 645 / 1,238 | [−4.4927,4.3110] / [−3.5146,3.2364] / [−0.3193,2.8398] | `terrainplateau3.actor:2-3` | **prop file absent** |
| `terrainplateau4` | 46,444 / 655 / 655 / 1,274 | [3.1445,11.0032] / [−3.4613,3.8073] / [−0.5249,4.3355] | `terrainplateau4.actor:2-3` | **prop file absent** |

`actors.lib:1200-1213` lists only `LODActorName`/`LODActorFileName`;
`.actor` files bind one `.osm` each; `.prop` files bind
`LODActorName`/`DefaultMeshName` and season materials
(`UseableSummerMaterials[0]` / `UseableWinterMaterials[0]`, e.g.
`terrainmesh1.prop:17-18` → `terrainmesh1`/`terrainmesh1w`). **No scale field
in any of these files (observed negative)**; relief props skip the generic
random-scale pass (`dogenerate.inc:1984-1985`: `terrainmesh`/`stones` →
`continue`). `terrainplateau*.osm` exist as actors but are **never referenced
by any pattern and have no `.prop` file** — selection/placement is **UNVERIFIED**
(editor/manual only is an inference, not a donor fact).

**Consolidated verdict:** *both* prior claims were partly right and partly wrong:
- plateau/hill/ravine patterns (`plt2`, `hil1`, `k_ravine_1`,
  `f_plt_big_1`, `g_hil4`) → **height deformation**; no relief prop.
- mountain patterns (`g_mnt_*`, `i_mnt_*`, `desert_mnt_*`) → **3D prop mesh**
  (`terrainmeshN`) with an all-zero height grid.
A port that only inflates grid bumps will still lack mountain silhouettes; a
port that only adds props will still lack asymmetric ravines and plateau caps.

---

## 7. White-mark mechanism analysis

**Question:** does any *pattern operation* write bright/pale TILE ids or colour
on otherwise flat land?

### 7.1 Pattern-side: NO mechanism found (explicit negative)

- The five pattern sections contain **no tile id, tile name, texture, colour or
  decal asset field**. The only related keys are boolean `TilesStand=True` and
  `DecalsStand=True` (§3.1, e.g. `pattern.lib:6779`, `:6781`); both have
  **zero plaintext consumers** (§4.1).
- Trailing 24-byte records after the chosen height window decode as float
  flags, not tile ids: `plt2` rec0 `@11506`: `id=1065353216` (= float32 `1.0`)
  and floats `(0,0,1,1)`; `hil1` rec0 `@5100`: `(1,1,1,0)`;
  `k_ravine_1` rec0 `@14458`: `(0,0,1,1)`; `f_plt_big_1`/`g_hil4` rec0 `id=0`.
  Their semantics are **UNVERIFIED**, but **no value in these records is a
  tile index or RGB colour**, and the offsets are ambiguous because of zero
  runs (§3.3).
- No `SetTileIndex`/`MapGetTileBlockByTileIndex` call in any donor script
  mentions a pattern name, `TilesStand`, `DecalsStand` or a pattern getter
  (fresh scan of `data\scripts\**`).

**Answer, stated explicitly: no donor *pattern* operation writes pale tile
marks.** The stamp's payloads are a height field, a footprint mask, object
records and (probably) decal flags; colour enters elsewhere.

### 7.2 Donor DOES have a non-pattern mechanism that can pale-mark flat land

This is donor truth and is the best available explanation for literal bright
pixels on otherwise flat land in a *real generated map* (the supplied P0 PNG
contains no marks — `TERRAIN_MARKS_01.md:45-49`; attribution to the owner's
exact frame remains **inferred / UNVERIFIED**):

1. **Detail-bitmap tile pass** — `loadtextureterrainfrombitmap.inc:8-9` loads
   `data\gen\bitmap\ext\tile_lowground.bmp` and `tile_highground.bmp`;
   `:26-29` chooses by the **only** height gate `h < 0.1`;
   `:32-41` reads the pixel and writes `tex = r div 2` into `SetTileIndex`
   on any cell whose tile index is 0. On flat land (`h≈0`) the lowground bitmap
   is used — **no relief required**.
2. **Tile smoothing** — `generatemap.inc:43` (`cSmoothTile=True`) and
   `:781-786` call `SmoothTiles`; `smoothtiles.inc:189-242` inserts transition
   ids between dissimilar neighbours. `gen\tilesmooth_scripts.cfg` explicitly
   lists `test7`/`test8`/`test9` as transition names (`:166,262,270,354,370,
   475,491,596,604,705,741,849-854,873`; winter equivalents `:1096-1104`).
3. **Exact art and colours** (fresh PIL on donor 1024² DDS):

| Asset (tile id) | Donor path | max RGB | mean RGB | px with luma>180 |
|---|---|---|---|---:|
| `test7` (78) | `data\terrain\tiles\textures\test7.dds` | **(222,215,123)** | (74.2,78.8,28.2) | 109 |
| `test8` (79) | `…\test8.dds` | **(222,231,148)** | (73.0,77.9,27.9) | **245** |
| `test9` (80) | `…\test9.dds` | (189,195,74) | (74.5,76.4,24.6) | 0 |
| `rock4` (20) | `…\rock4.dds` | **(255,239,189)** | (70.8,61.5,49.9) | 68 |
| `rock8` (24) | `…\rock8.dds` | (231,211,165) | (72.9,65.7,37.9) | 21 |
| `grass1` (0) | `…\grass1.dds` | (132,150,57) | (76.0,82.5,30.4) | 0 |

Tile names → ids: `tiles.lib:320,323,326,101,113`; DDS bindings:
`tiles.mat:316,319,323,84,100`. Derived: `test7`/`test8`/`rock4` carry rare
bright speckles on an otherwise olive/brown mean — sparse pale marks can arise
purely from tile-id art on flat cells.
4. **`rock8`/`rock4` are height-gated**, so they cannot explain marks on
   genuinely flat land: `texturemap.inc:594-601` requires `abs(h)>2.7` /
   `>2.4` and suppresses the tile when `abs(h)<0.1`. If those ids appear at a
   marked cell, that cell is really high/steep — a useful discriminator.

**Ranking (inferred, no pixel-aligned donor A/B):** for the owner's white marks,
the donor-grounded candidate is *tile-id art from the detail-bitmap/smoothing
pass*, not a relief stamp. Missing relief and pale marks have **different
causes**; no source path writes white colour from a height stamp (the stamp
writes height only). The exact frame/seed/config that produced the marks is
**UNVERIFIED**.

---

## 8. Port comparison (read-only) — exact mismatches and owners

Port tree is `variant3d/` (the tree matching the live path); the `app/` mirror
has the same `pattern_gen.gd`/JSON contents.

| # | Area | Donor (observed) | Port (current, observed) | Mismatch / label | Owner file |
|---|---|---|---|---|---|
| 1 | Data contract | `.pattern` carries a `w*h` float32 grid; 5/5 decoded exactly (§3.3) | `donor_patterns.json` `plt2`/`hil1`/`f_plt_big_1`/`g_hil4` have **only** `w`,`h`,`cells`; `k_ravine_1` **absent** (fresh parse). `Stamp` has no grid field (`pattern_gen.gd:50-57`) | Full grids never reach the generator — **observed** | `pattern_gen.gd` / JSON export worker |
| 2 | Relief families | `dogenerate.inc:1760` disables `ravine_medium`; active ravine is `ravine_big` `:1761` | `pattern_gen.gd:27-36` has `ravine_big` but no `ravine_medium`; `main.gd:774-776` notes `k_ravine_1` producer hook blocked | Consistent with donor for `ravine_big`; `k_ravine_1` unreachable **observed** | `pattern_gen.gd` / `main.gd` worker |
| 3 | Live grid stamp | Engine applies full grid via `StandPatternWithAngle` (`misc.script:3390`); blend UNVERIFIED | `game.gd:932-1105` now stamps a **coarse 8×10 block-mean** from DPATTERN-01 A1/A2 for `st.name=="plt2"` (and unreachable `k_ravine_1`) at `:969-978,1034-1049`; labelled PORT APPROXIMATION | Coarse means ≈ one cell per ~4–5 donor rows/cols; DPATTERN-01:599-600 calls them "debug/preview aids only — stamp from the full grid"; **observed**, not parity | `game.gd` worker |
| 4 | Stale comment | Grids decoded (§3.3) | `game.gd:74-75` still says "per-cell height records are UNVERIFIED (TDR-2 §2.2)"; `:109-112` marks smoothing unmodelled | Now stale for the five grids; smoothing genuinely UNVERIFIED. **observed** | `game.gd` worker |
| 5 | Clamp reconciliation | `HeightFieldMin/Max` per pattern; `plt2` max +3.6134 > baked ceiling +2.964 (`generatemap.inc:4`) | `game.gd:1047` clamps donor cells to the pattern min/max at stamp time; `:1211-1230` re-clamps non-donor land to ±2.964 with a dither cap, but `_relief_donor_mask` (`:73,944,1214-1222`) exempts donor cells from the dither | Sensible port reconciliation; donor clamp ORDER still UNVERIFIED. **derived** | `game.gd` worker |
| 6 | Dump-only reader | No donor "marker" concept | `world3d_terrain.gd:465-513` `apply_relief_grid()` + `:522-557` marker reader; fires only on `dump["relief_stamps"]`; `main.gd:767-803` produces it behind `config.gd:59,448-449` flag | Duplicate grid path; live boot synthesizes a marker-free dump (`world3d_terrain.gd:916-953`), so this path is inert live. Comment `:82-84,1190-1191,1453` saying "no marker in current schema" is stale vs `main.gd:802-803`. **observed** | `world3d_terrain.gd` / `main.gd` worker |
| 7 | `g_hil4` smoothing | `HeightFieldSmooth=True`, radius 3 / factor 4 / offset 2 (`:366486-366489`) | No smoothing emulation in either port path; only `plt2`/`k_ravine_1` tables exist (`game.gd:1098`, `world3d_terrain.gd:1450`) | `g_hil4` (and `f_plt_big_1`'s offset 2) cannot be stamped faithfully; definition UNVERIFIED anyway. **observed** | `game.gd` worker |
| 8 | `hil1` scale | `HeightFieldScale=0.649999976158142` (`:33094`) | No `hil1` grid entry in either port table; hill relief falls back to analytic `amp=RELIEF_HILL`, rim 8 (`game.gd:993-994,1051-1094`) | Authored scale 0.65 is ignored; crest ≈3.54 raw / 2.30 effective is replaced by an analytic ≤1.317 parabola. **observed** | `game.gd` worker |
| 9 | Props | Mountain patterns embed `terrainmeshN`; zero-grid; `.prop`/`.actor`/`.osm` exist (§6.2) | No `terrainmesh*` meshes/props in the port; `world3d_terrain.gd:1456` lists `"mountain terrainmesh props"` under `not_done` | Mountain silhouette absent even after grid stamping. **observed** | prop/asset worker |
| 10 | `terrainplateau*` props | 4 `.osm` + `.actor` exist but **0** pattern references and **0** `.prop` files | Absent in port | No parity target identifiable; selection rule UNVERIFIED. **observed / UNVERIFIED** | prop/asset worker |
| 11 | Collision sampling | 2× grid at `lx+x/2+0.25` (`texturemap.inc:133-138`), gates 0.5/0.55 (`:63-64`) | 1× `blocked[]`, gates 0.5/0.55 (`game.gd:1231-1255`); `world3d_terrain.gd:1457` lists `"2x collision sampler"` under `not_done` | Sub-cell edges differ. **observed** | `game.gd` worker |
| 12 | Tile marks | Detail bitmaps + smoothing place `test7/8/9` on flat land (§7.2) | `game.gd` detail pass writes tile ids from donor `tile_low/highground` bytes; bright PNG copies of the same DDS exist in port (`RELIEF_LIVE_DIAG_01.md:238-255`) | Port art is byte-equivalent to donor DDS; this mechanism is NOT a stamp and remains a plausible mark source; attribution to owner's frame UNVERIFIED. **observed / inferred** | `game.gd` / art worker |

No code was edited for any row; owners above are the files a fix would have to
touch, not a work assignment made by this worker.

---

## 9. Open questions (UNVERIFIED — do not guess)

1. Exact float-plane byte boundary per pattern (101–125 ambiguous offsets for
   `plt2`/`f_plt_big_1`); a donor struct definition would settle it.
2. Native blend math: `Replace`/`ReplaceForWater`/`Smooth` order, clamp-vs-scale
   order, sign convention, and the meaning of `HeightFieldSmoothOffset=2`.
3. File-row → centred-map-Y sign flip (row order is file order here).
4. Which `terrainmeshN` is chosen at runtime when a mountain lists 5 (e.g.
   `g_mnt_1`); engine-side, no plaintext rule.
5. `terrainplateau1..4` selection/placement: zero pattern references, no `.prop`
   files — editor-only? UNVERIFIED.
6. Meaning of `TilesStand`/`DecalsStand` and of the 24-byte trailing records;
   no plaintext consumer, so the trail cannot be proven to be decal/tile data.
7. Which frame/seed/config produced the owner's pale marks; the supplied P0 PNG
   contains none, so visual attribution stays inferred.
8. Whether a real 320² generated map has `test7/8` cells at `|dh|<0.5` — needs a
   tileblock dump; existing offline replays are not in-engine proof.
9. Donor metres per cell and surface tessellation/LOD (props have
   `LODActorName`; the height surface's LOD is UNVERIFIED).
10. Donor GPU A/B terrain frame does not exist; all visual checks here are
    source/asset-level only. **No parity claim.**

---

## 10. Summary

- **Fresh donor decode (3 passes, 5 patterns):** `plt2` (42×55, G=2266),
  `hil1` (25×41, G=1000, scale 0.65), `k_ravine_1` (46×63, G=2866),
  `f_plt_big_1` (81×93, G=7344, smooth offset 2), `g_hil4` (33×59, G=1912,
  smooth True) all carry a row-major `w*h` float32 height grid whose min/max
  **exactly** equal `HeightFieldMin/Max` in `pattern.lib`; exact centre-row
  arrays, hex and statistics are in §3.3. All are `NativeSeason=Summer`,
  `Winter=True` — one grid for all seasons (**observed**).
- **How applied:** no plaintext consumer of any sculpt field exists (680 hits
  each, `pattern.lib` only); the only script-visible pattern API is mask/offset
  getters plus `StandPatternWithAngle` (`misc.script:3390`). Additive-clamp is
  the labelled port approximation; donor blend is **UNVERIFIED**. Pure `max` is
  **derived-rejected** because the grids contain negative cut values.
- **Prop-vs-height (contradiction resolved):** the five audited patterns have
  **zero** `terrainmesh`/`terrainplateau` objects and non-zero grids → **height
  deformation**. Mountains have all-zero grids **and** `terrainmeshN` prop
  records (30 sections), with real `.actor`/`.prop`/`.osm` assets and no scale
  field → **3D prop mesh**. `terrainplateau*` has 0 pattern references and no
  `.prop` files → UNVERIFIED placement.
- **White marks:** **no donor pattern operation writes pale tile ids or
  colour** — explicitly stated. A separate donor mechanism does: detail bitmaps
  (`loadtextureterrainfrombitmap.inc:8-9,26-42`) and tile smoothing
  (`smoothtiles.inc`, `tilesmooth_scripts.cfg`) place `test7`/`test8`/`test9`
  on flat land, whose DDS art has bright speckles (max RGB `(222,215,123)`,
  `(222,231,148)`, `(255,239,189)`). `rock8/rock4` require `abs(h)>2.7/2.4`
  and cannot mark truly flat cells. Attribution to the owner's exact frame is
  **UNVERIFIED**.
- **Port:** `pattern_gen.gd` carries only `w/h/cells` (no grid); `game.gd:932-1105`
  now stamps a coarse 8×10 donor-derived table for `plt2` on the live path with
  a labelled additive-clamp approximation, but `hil1`/`f_plt_big_1`/`g_hil4`
  and their scales/smoothing are absent; `world3d_terrain.gd` has a second,
  dump-only opt-in reader; mountain props and the 2× collision sampler remain
  absent. Exact mismatches and owner files are in §8. **No parity claim;**
  no synthetic hills were added, no code was edited, no runner job was run.

*End of PATTERN-STAMP-DEEP-01. This report is the only file written by this
worker. Donor was read in place and never executed, copied or modified.*
