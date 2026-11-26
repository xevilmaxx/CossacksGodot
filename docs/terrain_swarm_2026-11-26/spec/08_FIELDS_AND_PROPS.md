# 08 — Fields and landscape props (from A04; F07/V07 pending)

Source: `reports/A04_landscape_props.md` (603 lines). **No donor parity claim.**
A04 read donor paths and port assets read-only.

## 1. Central finding [O]/[D]

Donor landscape decodes into **three independent channels**:
1. **float32 height windows** (stamped into `height[]`),
2. **pattern `Objects` 3D props** (instance transforms from `pattern.lib`),
3. **tile / decal / shader art** (surfaces).

A flat height field alone therefore **cannot** supply mountain silhouettes. The
fresh module must instance props; it must not bake silhouette into `height`.

## 2. Per-class coverage (A04 §per-class table)

hills · mountains · mill fields · sea · shore · forests · stone quarries ·
gold/iron/coal mines · swamps/lakes · decor — each has donor asset source, port
asset status, donor placement rule, 3D representation (mesh / MultiMesh /
billboard / decal / shader), LOD/culling and an acceptance visual cue. Full table
with citations in the report; highlights below.

## 3. Already converted but never QA-run [O]

- `terrainmesh1..4` models are converted.
- `assets/terrain/mountain_props.json` holds 112 `pattern.lib` object records.
- A MultiMesh consumer exists (Z08) — **never QA-run** (A04 §).
- Relief float windows and swamp/lake families still need export (I02/I03).

## 4. Field / mine status [O]/[U]

Mill fields are **decals**, not terrain tile ids (F05 §3); field and mine
placement remains **PORT APPROXIMATION** until F07/F08/D07 land.

## 5. Staged order (A04 P0–P6)

Prop silhouette (hills/mountains) first, then shore rocks, forests/stones, mines,
mill fields, swamps/lakes, decor — each stage with its own visual cue and no
synth noise/dither.

## 6. Cross-check

F07 (mill/fields), F08 (forest/stone/mine families), V07 (asset-readiness ledger),
D07 (placement functions).

## 7. Flora/mineral families (from F08) [O]

- Donor object contents live in `pattern.lib` **`Objects` arrays** (e.g. `mng_1`
  at `:713285`, 11 records incl. one `minegold` scale 0.3152), **not** in the
  `.pattern` 24-byte tail — record counts differ 63/2072/323 vs 11/124/34.
- Catalogued **19 forest, 5 stone, 6 mine families** with per-pattern member
  lists, object censuses, footprints (8×10 mine stamps; up to 86×92 mixed
  forest) and `Freq=1` equal weights. All 680 sections are Summer-only; winter
  via prop material swaps.
- `Freq` is a roulette weight damped **×0.2** after each placement
  (`misc.script:3588-3629`). Real pass rates:
  `frs_big/mid/small = 0.0009/0.0009/0.00054`,
  `stn1/stn2 = 0.00016/0.00012`, yielding 11/15/13 stamps per conifer family
  at 320². `foreststype` is hard-forced to 0 (`dogenerate.inc:5-6`).
- Donor-grounded placement recipe: RNG resets, ellipses 5×7/12×15/22×18,
  3/4/5 mine rings ×3 ores, 128×3 rejection tries (matches spec §07).
- **Port relation PORT APPROX:** only `{w,h,cells}` masks are exported;
  `game.gd` synthesises wood/stone nodes; `pattern_gen.gd` uses its own mine
  clusters. `X16` is auditing mesh coverage.

## 8. Mill fields are SCRIPT-SOWN (from F07) [O] — not pattern stamps

- Donor fields come from `unit.script:6468-6570`: **7×7 = 49 nodes**, step
  **1.6981 cells**, **45° rotation**, `√2·size` snap, up to ~7.8-cell
  half-diagonal, **5 gold each**. No pattern/lib record names a field or mill.
- `frt_*` (248 patterns) is **forest**; `k_pump_*` (15) is **decorative pumps** —
  neither is a field source.
- With `gc_meters_to_tile=2`: donor spacing **3.3962 m**, clearance **3.0566 m**.
  Port's 3.0 m clash is donor-close but its 1.6981 m step is half-scaled; F2-01's
  clash reduction is a **PORT APPROX**, not a donor fix.
- Port assets: 10 eur-mill OBJs, 1 field OBJ/texture, 2 field decals, baked
  rotor; **missing** death stages, rus/tur mills, winter crops, `.oss`/`.aaf`,
  pump family.
- Consistent with D07: `SetupStartingResources` places **no food rects** — food
  is mill-seeded by this unit script.

## 9. Cross-check (updated)

X16 (mesh coverage), V07 (asset readiness), V12 (resource spec), X09
(start settings), X22 (field-sowing translation), F07 ✓.

---
*Integrated by COORD from A04 + F08 + F07.*


