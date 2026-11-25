---
id: Z06
ticket: "HEIGHT WAVE / Z06 — exact donor terrainmeshN prop placement and minimal port instancing consumer"
agent: "Z06 (read-only donor + read-only local audit, subagent)"
date: 2026-11-25
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_RUNNER_JOB__NO_CODE_EDIT
scope: "This report is the ONLY repo file written. No source/shader/config/asset/test/JSON/PNG/donor/queue/git edit. No Godot process or runner job. Donor installation read in place (bytes/latin-1, struct); helper scripts lived in %TEMP%\\opencode and were not committed. Nothing copied from the donor."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
donor_root: "C:\\Games\\Cossacks 3 (private use, read-only)"
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, PORT APPROX]
parity_guard: "No donor GPU A/B frame exists (CHARTER §3/§5; Z03 §0). Engine-side native consumers were not executed or disassembled. NO DONOR PARITY CLAIM."
---

# Z06 — how the donor actually places `terrainmeshN` props

> [!IMPORTANT]
> Donor is truth. Labels: **OBSERVED** (literal donor line, decoded donor bytes, or
> direct on-disk file listing), **DERIVED** (arithmetic/control-flow consequence of
> observed values), **INFERRED** (best reading without a donor GPU A/B), **UNVERIFIED**
> (not provable with the files/instruments available), **PORT APPROX** (an explicit
> port substitute for an engine-side rule). All donor paths are relative to
> `C:\Games\Cossacks 3\`; all local paths to the repo root. No Godot process was run;
> no donor file was executed or copied. **No donor parity claim.**

---

## 0. Mandate and method

Ticket Z06 asks: (1) which `.pattern` families reference `terrainmeshN` props;
(2) how many per stamp; (3) their world coordinates / scale / roll as carried by the
pattern data; (4) whether the port's `pattern_stamps` already retain the needed
footprint/positions (`game.gd:730-870`, `pattern_gen.gd`); (5) what minimal instancing
consumer would render them at the right spots.

Orientation documents read (not new evidence): `WAVE_G_CHARTER.md`, `CHARTER.md`,
`reports/Z03_donor_relief_props.md`, `DPATTERN_01_relief_grids.md`,
`DMAPGEN_01_skirmish_options.md`, `DTRN_02_donor_terrain_geometry.md`, and sibling
`reports/Z05_relief_prop_conversion.md` (read for cross-check only, after the evidence
below was gathered; its non-unit `Scaling` finding agrees with §2.1).

**New direct evidence this ticket:** a full parse of all 680 top-level sections of
donor `data/pattern/pattern.lib` (1,172,416 lines) extracting every `Objects` record
whose `BaseName` contains `terrainmesh`, with its `Position / Direction / Up / Scaling`
vectors; donor `dogenerate.inc:1960-2004,1775-1814` and `misc.script:3320-3434`;
read-only binary decode of `g_mnt_1/g_mnt_3/plt1/hil1.pattern`; local reads of
`variant3d/scripts/game.gd:700-870,927-1118,1236-1260`, `pattern_gen.gd:1-760`,
`world3d_terrain.gd:85-99,345-384,1508-1525`, `world3d_entities.gd:1130-1174,1400-1470,1960-1985`,
`world3d.gd:125-199`, `tools/export_donor_patterns.py`, `tools/convert_models.py:410-499`,
and `assets/terrain/patterns/donor_patterns.json`.

---

## 1. Which pattern families reference the props (OBSERVED — fresh full-file parse)

All **112** `Objects` records with `BaseName = terrainmesh*` live in exactly **30**
`pattern.lib` sections. This count and family set independently match DPATTERN-01 §6
(second source, same numbers).

| Family | Sections | Props per section (min–max) | Total records | Prop base names |
|---|---:|---:|---:|---|
| `g_mnt_1..7` | 7 | 1–5 | 22 | `terrainmesh1..4` |
| `i_mnt_big_1..5` | 5 | 4–8 | 28 | `terrainmesh1..4` |
| `i_mnt_long_1..5` | 5 | 7–9 | 39 | `terrainmesh1..4` |
| `desert_mnt_1..13` | 13 | 1–3 | 23 | `terrainmeshdesert1..4` |
| **all** | **30** | **1–9** | **112** | — |

Exact per-pattern counts (OBSERVED, `pattern.lib` section line in parentheses):

```
g_mnt_1  (337461) = 5   g_mnt_2 (340275) = 2   g_mnt_3 (342333) = 4
g_mnt_4  (345119) = 1   g_mnt_5 (346869) = 4   g_mnt_6 (349375) = 4
g_mnt_7  (352189) = 2
i_mnt_big_1 (391809) = 8   _2 (423477) = 6   _3 (397787) = 4   _4 (405949) = 5   _5 (415035) = 5
i_mnt_long_1 (432899) = 7  _2 (441369) = 8   _3 (445779) = 7   _4 (453465) = 8   _5 (460479) = 9
desert_mnt_1 (1087549) = 2 … desert_mnt_13 (1097209) = 1  (1–3 each)
```

Base-name census across the 112 records (OBSERVED): `terrainmesh3` ×29,
`terrainmesh4` ×25, `terrainmesh2` ×21, `terrainmesh1` ×14,
`terrainmeshdesert4` ×9, `...desert3` ×7, `...desert2` ×5, `...desert1` ×2.

**Negative findings (OBSERVED, full 680-section scan this ticket):**
- **Zero** `terrainmesh*` records in the plateau (`plt*`, `d_plt*`, `f_plt*`),
  hill (`hil*`, `g_hil*`) or ravine (`k_ravine*`) families. Those families sculpt
  height from their float grids instead (DPATTERN-01 §4.1–4.5, §8 rule 4).
- **Zero** `terrainplateau*` references (corroborates Z03 §1.2 / DPATTERN-01 §6:
  no `.prop` files and no generator stamping). UNVERIFIED whether they are editor-only.
- Mountain configs are consistent with "props, not height": `g_mnt_1`
  `HeightFieldMin=0 / Max=0` (`pattern.lib:337491-337492`), `g_mnt_3` likewise
  (`pattern.lib:342363-342364`); `GameObjectsStand=True` (`pattern.lib:337466`),
  `ObjectsScale=1` (`:337476`), `RotationAngle=0` (`:337477`).

**Correction / nuance to Z03 B4.** Z03 called runtime selection "among several
`terrainmeshN` in one mountain `Objects` list" UNVERIFIED. The fresh parse shows the
list is not a set of alternatives but a **multi-prop arrangement**: each record has
its own distinct `Position` and `Up` (e.g. `g_mnt_1`'s five props sit at five
different X/Z offsets — §2). **INFERRED:** all N records of a stamped pattern are
instantiated, forming a small mountain group. **UNVERIFIED:** the native engine
consumer was not observed, so "all N" cannot be proven from plaintext.

---

## 2. The prop transform is in `pattern.lib`, not in the `.pattern` binary (new decisive evidence)

Each `Objects` entry is a `[*] : struct.begin` record with `RaceName`, `BaseName`,
and four vector structs (`Position`, `Direction`, `Up`, `Scaling`), each
`X/Y/Z/W` (OBSERVED). Worked example — `g_mnt_1`'s `terrainmesh4`, donor
`pattern.lib:338480-338507`:

```
338480  [*] : struct.begin
338481     RaceName = env
338482     BaseName = terrainmesh4
338483     Position : struct.begin
338484        X = -8.98600006103516 ; Y = 0 ; Z = 5.62277603149414 ; W = 1
338489     Direction : struct.begin
338490        X = 0 ; Y = 1 ; Z = 0 ; W = 0
338495     Up : struct.begin
338496        X = 0.939692616462707 ; Y = 0 ; Z = -0.342020153999329 ; W = 0
338501     Scaling : struct.begin
338502        X = Y = Z = 0.575703918933868 ; W = 0
```

### 2.1 Scale — NOT 1 (OBSERVED; corrects Z03's "authored scale 1")

Across all 112 records `Scaling.X = Y = Z` (uniform), range **0.353864 …
0.656215**; examples: `g_mnt_1` first prop `0.575704` (`:338502-338504`), the other
four `0.510000` (`pattern.lib:338872+`); `g_mnt_3` props `0.484000 / 0.608999 /
0.538999 / 0.484000` (`:343122`, `:343828+`, `:344360+`, `:344668+`).

Z03 §1.2/§4.1 derived "authored scale 1" from the scale-exemption at donor
`dogenerate.inc:1984-1985`. Read literally, that line only makes `terrainmesh` /
`stones` **skip the generic random-rescale pass** (which starts at
`dogenerate.inc:1986`, `GetGameObjectScaleXByHandle`); it does not set scale to 1.
The authored per-object `Scaling` is the value to use. **UNVERIFIED:** whether the
engine additionally multiplies by the section's `ObjectsScale` (1 in every audited
mountain section, e.g. `pattern.lib:337476`); no plaintext consumer exists.

### 2.2 Roll / yaw (OBSERVED values, DERIVED interpretation)

`Direction = (0,1,0)` in **all 112** records and `Up = (cos θ, 0, −sin θ)` with `θ`
a multiple of 10° (set observed: 0,10,20,30,40,50,60,70,80,90,100,110,140,160,180,
190,200,210,230,240,260,280,300,330,340,350). DERIVED: `θ = atan2(−Up.Z, Up.X)`
is a **pure yaw about donor Y**; there is no pitch/roll component in any record.
`g_mnt_1` yaws = `[20°, 0°, 0°, 140°, 210°]`; `g_mnt_3` = `[90°, 0°, 0°, 0°]`.
Eight records write `Up.X` in exponent form (e.g. `pattern.lib:343116`,
`X = -6.90493493493705E-8` ≈ 0 → yaw 90°); a parser must accept `E`/`e` notation.
**UNVERIFIED:** the sign convention when converting donor Y-yaw to Godot Y-up yaw
(DTRN-02 C3 gives the axis swap but not rotation handedness) — a port choice is
**PORT APPROX**.

### 2.3 Position (OBSERVED values, DERIVED frame)

`Position.W = 1` everywhere. `Position.Y`: 103 records `0`, 7 records `0.1`, one
`-0.002`, one `-0.15` — i.e. essentially ground-level offsets in donor height units.
`Position.X/Z` are pattern-local, centred, and lie inside the pattern's mask extent:
for `g_mnt_1` (43×38 cells) the five **terrainmesh** props have
`X ∈ [−8.986, +7.185]`, `Z ∈ [−7.500, +5.623]`, inside the exported cell range
`x ∈ [−21,+21]`, `y ∈ [−19,+17]` (the same section's *trees* reach wider X/Z)
(`donor_patterns.json["patterns"]["g_mnt_1"]["cells"]`). DERIVED: the object frame is
the same centred generator-cell frame as the mask cells; the donor-native mapping is
shown in §3 but its consumption is engine-side.

### 2.4 The `.pattern` file does not carry these transforms (OBSERVED negative)

Fresh read-only decode of `g_mnt_1.pattern` (43×38, 90,460 B), `g_mnt_3.pattern`,
`plt1.pattern`, `hil1.pattern`: header `int32 w,h` + `w*h` u8 cells + float32 window
(as DPATTERN-01 §2), followed by 24-byte records. Decoding those records as
`<i5f>` yields per-cell attribute tuples such as `(0x3F800000, 1,1,1,1,0,0)` for
`g_mnt_1` and `(0x3F800000, 0,0,1,1,1)` for `g_mnt_3` — **not** Position/Direction/
Up/Scaling records. Their exact semantics remain **UNVERIFIED** (DPATTERN-01 §2.3).
Consequence (OBSERVED): any port prop table must be derived from `pattern.lib`, not
from the `.pattern` binaries the current exporter reads.

---

## 3. How the donor stamps them (donor intent OBSERVED; engine binding UNVERIFIED)

1. `_misc_SetupPatternsByType` picks a pattern by family/`Freq`
   (`dogenerate.inc:1749-1765`, `generator.cfg:660-687` for mountains,
   `:503-535` desert). DMAPGEN-01 §2.3 confirms relief tier ids; DPATTERN-01 §5.1
   quotes the probability chain.
2. For each accepted placement, `_misc_CheckStandPattern(name, envplHnd, x, y, 0,
   True, False, 0)` (`dogenerate.inc:1796`) calls the engine native
   `StandPatternWithAngle(plHnd, patName, standX, standZ, angleRad, 0, 90)`
   (`misc.script:3384-3390`) with `angleRad = 0` for generator stamps. The native
   consumes the pattern's `Objects` list, `Position/Up/Scaling`, `ObjectsScale` and
   `RotationAngle`. **UNVERIFIED:** its exact transform math — no plaintext consumer
   of any sculpt/object field exists (DPATTERN-01 §5.2: 9,520 hits, all in
   `pattern.lib`).
3. The mask half-window arithmetic is plaintext (OBSERVED,
   `misc.script:3325-3379`): `x = standX + GetPatternOffsetX(name)`,
   `z = standZ + GetPatternOffsetZ(name)`, `w=(mWidth−1)/2`,
   `vMinX=floor(x−w)`, `maskValue=GetPatternMaskValue(patName, i−vMinY, j−vMinX)`,
   mapped to map indices `indI=fi+mapH/2`, `indJ=fj+mapW/2` (`:3370-3376`). For
   mountain sections `OffsetX=OffsetZ=0` (`pattern.lib:337485-337486`), so the
   pattern is centred on the stand point.
4. Derived port reading (**PORT APPROX**): props are placed at
   `stand + Position.X/Z` in the same centred cell frame, scaled by their authored
   `Scaling`, yawed by `atan2(−Up.Z, Up.X)`. This mirrors the port's own mask-cell
   convention (`export_donor_patterns.py:146` writes `x−w//2, y−h//2`), but the
   engine-side unit conversion, `ObjectsScale` multiplication and yaw sign are
   **UNVERIFIED**.

---

## 4. Does the port's `pattern_stamps` already retain what is needed?

### 4.1 Retained (OBSERVED, port)

| Data | Port location | Label |
|---|---|---|
| Stamp object with `family`, `name`, `kind`, `res`, `x`, `y`, `cells: Array[Vector2i]` | `pattern_gen.gd:66-73` | **OBSERVED** |
| Stamp produced only after footprint test; `st.name = picked donor pattern id`, `st.x/st.y = centre tile`, `st.cells = scaled footprint` | `pattern_gen.gd:179-211` (generic), `:536-560` (relief), `:549-557` | **OBSERVED** |
| `mountains` → kind `"mountain"` is an active recipe | `pattern_gen.gd:43-52` (`:44` family→kind) | **OBSERVED** |
| `s = map_w / DONOR_UNITS`, `DONOR_UNITS = 160.0`; cells scaled by `round(c*s)` | `pattern_gen.gd:9`, `:92`, `:110-128` | **OBSERVED** |
| Result cached once and exposed as `pattern_stamps` | `game.gd:66-70`, `:748`, `:1245-1247` | **OBSERVED** |
| Stamp centre → world metres `((cx+0.5)*TILE, (cy+0.5)*TILE)`, `TILE = 2.0` | `game.gd:16`, `:766` | **OBSERVED** |
| `donor_patterns.json` has `families["mountains"] = g_mnt_1..7` and `desert_mnt_1..13`, and patterns `g_mnt_1..7`/`desert_mnt_1..13` | local JSON (read this ticket); `export_donor_patterns.py:83-103` | **OBSERVED** |

**Answer:** the port **does** retain the stamp identity (`st.name`), centre and
footprint. That is enough to *attach* a prop list keyed by pattern name — no change
to stamp generation, RNG streams or footprint logic is required. `game.gd:1010-1011`
already treats `"mountain"` stamps as a relief kind (analytic `amp`), and
`_shape_stamp_relief()` reads `donor_name = str(st.get("name"))` at `game.gd:988`,
so the lookup key is already in hand.

### 4.2 Not retained / missing (OBSERVED negative)

| Gap | Evidence | Label |
|---|---|---|
| Per-pattern prop list (`BaseName`, Position, Up, Scaling) absent from derived data | `export_donor_patterns.py:139-155` writes only `{"w","h","cells"}`; `donor_patterns.json` string `terrainmesh` count = **0** (fresh check) | **OBSERVED** |
| No runtime prop consumer | repo `*.gd` grep; `world3d_terrain.gd:91-93` ("props are a separate ticket") and `:1515` (`not_done` lists "mountain terrainmesh props") | **OBSERVED** |
| No relief prop geometry in assets | `convert_models.py:412-496` `env_models()` table (trees/rock/stone/field/decor/gifts only); Z03 §3 (280 OBJs, zero relief props) | **OBSERVED** |
| Exact metres-per-donor-unit for prop mesh scale | DTRN-02 C20; Z03 B7 | **UNVERIFIED** |

### 4.3 Will a 64² fixture even contain a mountain stamp? (DERIVED)

`pattern_gen.gd:565,576,584`: `size_mod = 640/((W+H)/2)` = 2 at 320²;
`needed = floor(W*H * preset.mnt / 1 * size_mod)` (fallback `round` when 0).
At 320²: plains (`mnt=2e-5`) → **4** mountain stamps; high mountains (`7.5e-5`) →
**15**; highlands (`1.2e-4`) → **24**; plateaus (`3.5e-5`) → **7**. At 64², plains
gives `floor(4096*2e-5*10)=0` → `round(0.8192)=1` (borderline); hills gives 0.
A small-map QA atom must therefore either force a mountain stamp or use ≥320².
No capture was run — this is arithmetic over observed code, **DERIVED**.

---

## 5. Minimal instancing consumer (PROPOSAL — not executed, no edit made)

Design goal: render each `terrainmeshN` at its authored pattern-local spot without
touching stamp generation, RNG streams, `height[]`, `blocked[]`, or contested files
(`world3d_entities.gd` is contested by M03/P11 per Z03 B3; a new sibling module under
`world3d.gd:129-134` avoids that, subject to COORD's ownership grant).

**Step 1 — derived prop table (data only, no donor binary copied).** Add e.g.
`variant3d/assets/terrain/structs/mountain_props.json`: a dict keyed by the 20
port-stamped mountain pattern names (`g_mnt_1..7`, `desert_mnt_1..13`; covers all
112 records) → list of `{base, px, py, pz, sx, sy, sz, yaw_deg}`. Values are the
`pattern.lib` literals from §2 (numbers/labels only, per DPATTERN-01 §8 rule 1).
Source citations per row are the `pattern.lib` line numbers (e.g. `338480`).

**Step 2 — geometry.** Add `terrainmesh1..4` rows to `env_models()`
(`convert_models.py:422-487`) using donor `data/actors/env/terrainmeshN.osm` +
`data/materials/env/terrainmeshN.dds` assembled at `:489-495`; re-run the converter
(`Z03 §4.1`, invocation at `convert_models.py:main`). Result: `obj/terrainmeshN.obj`,
`tex/terrainmeshN.png`, 4 manifest entries. Winter sids optional (Z03 B6); desert
props need their own `.osm`/`.dds` if the desert biome is in scope (**UNVERIFIED**
that donor `.dds` exists for `terrainmeshdesertN` — check before adding those rows).

**Step 3 — placement formula (PORT APPROX for every engine-side term).** For each
`st` in `game._pattern_build["stamps"]` with `st.name` in the prop table (or
`st.kind == "mountain"`), for each prop:

```
var s := float(MAP_W) / C3PatternGen.DONOR_UNITS          # pattern_gen.gd:92 = 2 at 320
var dx := roundf(px * s) ; var dy := roundf(pz * s)       # same rounding as pattern_gen.gd:121-122
var wx := (float(st.x) + dx + 0.5) * TILE                 # game.gd:766
var wz := (float(st.y) + dy + 0.5) * TILE
var wy := py * HEIGHT_SCALE                               # py mostly 0; ground offset UNVERIFIED
var rot := deg_to_rad(yaw_deg) * PORT_YAW_SIGN            # sign UNVERIFIED (DTRN-02 C3)
var mesh_scale := sx                                     # authored Scaling; OBJ stays in raw donor units
```

`gx/gy` raw floats may replace `roundf` for sub-tile fidelity — either way label
**PORT APPROX** (engine native transform UNVERIFIED, §3). `ObjectsScale=1` means no
additional authored factor in the data read (UNVERIFIED engine multiplication). Keep
the converted `.obj` in **raw donor units** and apply only the authored `Scaling` at
placement: donor metres-per-unit is UNVERIFIED (DTRN-02 C20), so no metre factor is
invented here (consistent with sibling Z05 §1.2/R2/R3, read for consistency only).
If a world-metre factor is later chosen, it is a **PORT APPROX**.

**Step 4 — rendering.** Static props need no per-frame sync. Either one
`MeshInstance3D` per prop with `load(OBJ_DIR + sid + ".obj")`
(`world3d_entities.gd:1146-1150`) or, preferably for draw calls, one
`MultiMeshInstance3D` batch per sid following `_new_batch` / `_acquire`
(`world3d_entities.gd:1401-1438`, `:1443-1466`; OBJ mesh baked by `_mesh_info`
`:1130-1159`). Expected instance counts: ~20 at 320² plains (4 stamps × 5 props for
`g_mnt_1`-like patterns), up to ~120 at highlands (24 stamps × 1–5 props) —
DERIVED from §4.3 and §1; batching avoids one draw call per prop (P02/P11 concern).

**Step 5 — observability / acceptance (proposal).** Expose `prop_count`,
`prop_source = "pattern.lib Objects (derived numbers)"`, and the PORT APPROX label
via `stats` (cf. `world3d_terrain.gd:1508-1517`). Assert only *derived* invariants:
`prop_count == sum(table[st.name].size() for placed mountain stamps)`; each prop
centre inside the stamp footprint bbox; deterministic for a fixed seed; `height[]`,
`blocked[]` and all RNG draws unchanged. **Visual correctness stays UNVERIFIED**
until a real capture exists — no parity claim.

**Explicit non-goals:** no donor binary copy, no synthetic dither/noise, no test
weakening, no Godot run in this ticket, no claim that this reproduces donor pixels.

---

## 6. Claim register

| # | Claim | Evidence | Label |
|---|---|---|---|
| 1 | 112 `terrainmesh*` `Objects` records in 30 `pattern.lib` sections | fresh full-file parse this ticket; DPATTERN-01 §6 (independent) | **OBSERVED** |
| 2 | Only mountain families carry props; plateau/hill/ravine carry none | full 680-section negative scan | **OBSERVED** (negative) |
| 3 | Per stamp 1–9 props; `g_mnt_1`=5, `g_mnt_3`=4 | §1 line list; `pattern.lib:338480,338872,339320,339684,339852` | **OBSERVED** |
| 4 | Each prop has Position/Direction/Up/Scaling; scale uniform 0.354–0.656, not 1 | `pattern.lib:338480-338507`; 112-record census | **OBSERVED**; "not 1" **DERIVED** |
| 5 | `dogenerate.inc:1984-1985` only skips random rescale, it does not set scale 1 | `dogenerate.inc:1984-1986` | **OBSERVED** → **DERIVED** |
| 6 | `Up` encodes pure yaw (10° multiples); no pitch/roll | 112-record census; `pattern.lib:343116` | **OBSERVED** values / **DERIVED** reading |
| 7 | Native `StandPatternWithAngle` instantiates the Objects list at angle 0 | `misc.script:3384-3390`; `dogenerate.inc:1796` | **OBSERVED** call; **UNVERIFIED** binding |
| 8 | Mask placement is centred on stand point | `misc.script:3325-3379`; `pattern.lib:337485-337486` | **OBSERVED** |
| 9 | Port retains stamp name/centre/footprint but not prop transforms | `pattern_gen.gd:66-73,179-211,536-560`; `game.gd:748`; `export_donor_patterns.py:139-155` | **OBSERVED** |
| 10 | Port has no prop geometry/consumer | `convert_models.py:412-496`; `world3d_terrain.gd:91-93,1515`; repo grep | **OBSERVED** (negative) |
| 11 | `.pattern` trailing 24B records are per-cell attributes, not prop transforms | fresh binary decode §2.4 | **OBSERVED** (decode); semantics **UNVERIFIED** |
| 12 | Mountain stamp counts at 320²: 4/7/15/24 by preset | `pattern_gen.gd:565,576,584` | **DERIVED** |
| 13 | Port formula `round(px*s)` + `TILE` + yaw sign + metres/unit | §5 Step 3 | **PORT APPROX** (all engine-side terms **UNVERIFIED**) |
| 14 | Pixel-to-prop attribution in the reference samples | CHARTER §3/§5; no donor GPU A/B | **UNVERIFIED** — **no parity claim** |

---

## 7. Open questions (UNVERIFIED — do not guess)

1. Exact engine transform: does `StandPatternWithAngle` instantiate **all** records,
   and does it apply `ObjectsScale` / `ObjectsHeightOffset` / `ObjAutoOffset`
   (`pattern.lib:337476,337487-337489`) to scale and ground height?
2. Donor metres-per-cell / metres-per-unit and yaw sign for prop meshes
   (DTRN-02 C20) — blocks an absolute "correct size/rotation" claim.
3. Exact relationship between `Position.X/Z` floats and the mask cell grid at
   runtime (centred integer frame is INFERRED from `misc.script:3325-3379` + export
   convention; native consumption UNVERIFIED).
4. Winter prop materials and desert prop textures (Z03 B6; check donor `.dds`).
5. `terrainplateau1..4` authoring — zero `pattern.lib` refs (editor-only?).
6. Whether a real donor skirmish seed places any mountain stamp in the two
   reference screenshots (engine-side/no plaintext).
7. Draw-call and ownership grant for the instancing module (P02/P11, Z03 B3).

---

## 8. Summary — direct answers

- **Families / count:** donor places `terrainmeshN` via **mountain patterns only** —
  `g_mnt_1..7`, `i_mnt_big_1..5`, `i_mnt_long_1..5`, `desert_mnt_1..13`
  (30 sections, **112** prop records, **1–9 props per stamp**; `g_mnt_1`=5,
  `g_mnt_3`=4). No plateau/hill/ravine pattern carries one. (OBSERVED)
- **Transform source:** each prop's exact local `Position` (X/Z centred, Y≈0),
  uniform `Scaling` (**0.354–0.656**, not 1), and pure-Y `Up` yaw (10° multiples,
  e.g. `g_mnt_1` = 20/0/0/140/210°) is in `pattern.lib`'s `Objects` records
  (`pattern.lib:338480-338507` etc.), **not** in the `.pattern` binary. The
  `dogenerate.inc:1984-1985` exemption only prevents an extra random rescale.
  (OBSERVED values; scale reading DERIVED; engine binding UNVERIFIED.)
- **World placement:** donor centres the mask on the stand point
  (`misc.script:3325-3379`) and hands the Objects list to the native
  `StandPatternWithAngle(..., angle=0)` (`misc.script:3390`); the native's transform
  math is **UNVERIFIED**. A port formula using the same centred frame is **PORT APPROX**.
- **Port readiness:** `pattern_stamps` **does** retain stamp identity (`name`),
  centre and scaled footprint (`pattern_gen.gd:66-73,179-211,536-560`; `game.gd:748`),
  but the prop list, meshes and consumer are absent (`export_donor_patterns.py:139-155`,
  `convert_models.py:412-496`, `world3d_terrain.gd:1515`). No stamp/RNG change is
  needed — attach a prop table keyed by `st.name`.
- **Minimal consumer:** derived `mountain_props.json` (numbers from `pattern.lib`) +
  4 `terrainmeshN` rows in `convert_models.py:422-487` + a static per-sid
  `MultiMeshInstance3D` layer under `world3d.gd` reading `_pattern_build.stamps`
  and applying the §5 Step-3 formula. All engine-side placement terms are
  **PORT APPROX**; visual correctness **UNVERIFIED** without a capture.
- **No donor parity claim.**

*End of Z06. Read-only; one report; no runner job; no donor file copied, run or
edited; no code, asset, config or test edit.*
