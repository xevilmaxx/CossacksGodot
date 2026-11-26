# 10 — Generation stage order (from A02)

Source: `reports/A02_algorithm.md` (design only, 842 lines). Every donor number
below is cited from already-landed prior art (`docs/audit/TERRAIN_DONOR_PIPELINE.md`
D1–D9, `DPATTERN_01`, GUIDE4, RC_TERRAIN, 2026-11-25 reports), **not** from this
wave's D/F reports (which had not landed). A02 registers 16 `[U]` constants for
COORD cross-check. **PORT APPROXIMATION; no donor parity claim.**

Donor file shorthand (A02 §1): D1 `dogenerate.inc` (2102 lines), D2
`generatemap.inc` (1058), D3 `initmapgen.inc` (288), D4 `texturemap.inc` (962),
D5 `smoothtiles.inc` (245), D6 `smoothforestborders.inc` (170), D7
`postprocess.inc` (465), D8 `generator.cfg` (2366), D9 `misc.script` (6765),
PL `pattern.lib`.

## 1. The canonical order [O] — the single most important finding

`DoGenerate` (D1) calls, in order:

1. `init/seed` (D3:99, :146)
2. `clear` mask/objects/collision (D1:444–481)
3. base tiled patterns (D1:1530–1536)
4. settings branch (D1:1542–1565)
5. `GenerateMap` — mask decode, height, water, forest, texture, tile-smooth (D2)
6. shore exclusion mask (D1:1568–1581)
7. starts + border keep-clear (D1:1586–1616)
8. relief pattern passes (D1:1621–1770)
9. forest/stone/decor passes (D1:1774–1907)
10. units + scale (D1:1914–2027)
11. `FillOwnerMap` (D1:2062) + border objects (D1:2064–2065)
12. finalize (D1:2068–2100)

A02 splits D2's texture/tile-smooth sub-stages into an 11-stage pipeline. The
port's present order (analytic domes + fixed noise + post-collision height writes)
is **different**, which explains the concentric rings and flat relief.

## 2. Key donor-grounded rules [O]/[D]

| Rule | Value / evidence | Replaces (port approximation) |
|---|---|---|
| Determinism | **per-stage re-seeding**, not one continuous stream: `SetRandomKey(randkey1)` at D3:99/:146; re-seed at D1:1538, :1616, :1772, :1909, :1927 | single seed at `game.gd:152` — key derivation formula `[U]` |
| Height classes | `cPlateauHeight=2.964`, `cHillHeight=1.31733…`, `cRavineHeight=−2.964`, `cWaterHeight=−1.1`, R multiplier `3.5` (D2:4–7, :567–574). Class×R amplitudes are donor-intent text (`generatemap.inc:4-7,567-574`), **inert on shipped masks** (spec §03 §1/§2); the actual ±2.964 m relief comes from §04/D05 stamps. *(V26 C3)* | analytic domes |
| Relief | stamped `.pattern` (height grid + object list + footprint), rejection sampling via `_misc_CheckStandPattern(Ext)` (D9:3384–3521) | 8×10 block-mean grids, analytic radial profiles |
| Blend flags | **Native three-path stamp math [O]** — D05 §F4 / X12 claims 3–5: `ReplaceForWater` `g*Scale+Offset`; `Replace` `base_h+(g−Min)*Scale+Min+Offset`; default Smooth `h1+(base_h−h0)*TerrainScale+(g−Min)*Scale+Min+Offset` with two height reads. `Min` pivot; `HeightFieldMax` never read in the stamp; **no `[Min,Max]` clamp**. A02's `clamp(...)` placeholder is **SUPERSEDED**; row-flip and global setter clamp stay `[U]`. *(V26 C1)* | guessed additive clamp (`PORT APPROXIMATION`, remove) |
| Water constants | `−1.1` depth term (D2:7) is **distinct** from `−0.25` classify / `−0.1` shore (D4:30–31) | conflated in port |
| Coastal smoothing | gated by **mask B + height band** (D2:611–640, C4), not a height threshold | `mapgen.gd:179–196` is wrong here |
| Placement budget | `needed=floor(W*H*freq)`, `trycount=256*(320²)/(W*H)` (D9:3686–3704); `Freq` damping ×0.2 floor 1e-4 (D9:3588–3630) | uniform scatter |
| Placement grid | tiled patterns on strict 25-unit grid, inclusive (D1:1330–1359, C8/C9) | port 120-unit grid |
| Keep-clear | 3 ellipses per start: 5×7, 12×15, 22×18 (D1:407–414, C1/C2/C3); C3 is keep-clear, **not** placement region (C18) | port rings |
| Mines | indexed **by round**, not resource kind (C10); radii D1:525, :528–534, :594–645 | kind-based placement |
| Starting resources | `SetupStartingResources` (`dogenerate.inc:720-977`): six attempted stone/forest placements + three keep-clear ellipses; **no `food`/`field` rects** (V12 C-V4, X22 X-C6, D07 §3.6) *(V26 C2)* | port food rects (REFUTED) |
| Owner | `FillOwnerMap` 4-neighbour BFS (D1:1370–1428, :2062, C19); border objects are peace-mode markers (C20) | port flood fill |
| Season | colour tables 6/7/0 (D1:2075–2084; D4:525–526, :605–606, :639–640) | partial biome |
| Fields | **Script-sown**, not a generation pattern stage: `_unit_DoSeedWheat` 49-node 45° lattice (`unit.script:6470-6570`); `envfieldd`/`envfielddw` decal per field object (`writenewp.inc:23-29`, `misc.script:4286-4306`); no pattern/lib field family (`F07 E15`); caller activation `[U]` *(V26 C2)* | missing / invented food rects |
| Props | scale jitter, winter leaftree delete (D1:1914–2027, :1984–1985, :1975–1982) | missing |
| Tile smoothing | 3 passes, probability tables (D5:4–6, :84–187, :237, C23) | port smoothing |
| Rock/cliff art | collision tag + 8-sector gradient; `|h|>2.7→rock8`, `>2.4→rock4`, `<0.1→none` (D4:433–447, :557–611); `cDiff1/cDiff2=0.5/0.55` (D4:63–64) | port face promotion (REJECTED) |

## 3. Explicitly forbidden (A02 §3, 12 hacks)

dither/noise fields (S-25-09), face promotion (B04), `HEIGHT_SCALE` fudge, tile-art
relief, uniform scatter, post-collision height writes, forcing cliff art,
heightmap-as-albedo (H03/H05 REFUTED), shadow/AO fakery, synthetic mottling,
lowered gates, invented donor constants. Each is rejected by landed evidence.

## 4. Cross-check queue (COORD)

All `[U]` items in A02 §8 — especially per-stage key derivation (resolved as identity re-seed by V01, engine RNG still `[U]`) and row-flip/global-setter clamp (still `[U]`); **blend-mode math is resolved for the stamp by D05/X12/X13 — see `spec/04 §6`, do not re-open it as `[U]`**. V01 resolved 10 of A02's 16 `[U]` items (3 partial, 3 open); fold that table here before dispatch. R1–R6 ranges, exact mine radii, and `envfieldd` field-decal rule must be resolved against D01–D09 / F01–F10 before the spec is final. *(V26 C1)*

## 5. Verbatim donor corpus and corrections (from X03) [O]

`reports/X03_dscript_corpus.md` (1,300 lines, 972 line-cited verbatim excerpts)
read all 8 donor files in full with a second-pass re-read and cross-check. It is
the **translation source** for implementation — use it instead of paraphrasing.

- **Canonical order confirmed verbatim** at `D1:1530-2100` — matches §1 items 1–12.
- **Re-seed sites are 11, not 5**: `D3:99, :146`, `D1:1100, :1161, :1177, :1213,
  :1538, :1616, :1772, :1909, :1927` (all `SetRandomKey(randkey1)`), plus
  `SetRandomExtKey64(randkey0,randkey1)` at `D2:216, :513, :774`. A02's 5-site
  list is a subset. Key-mixing function remains `[U]`.
- **All 12 stages' numeric constants quoted verbatim** in X03 §3: height
  amplitudes `D2:4-7`, R/G/B codes `D2:21-32`, smoothing `D2:606,612-637`,
  water field `D2:649-650,688`, keep-clear ellipses `D1:407-416`, relief freq
  table `D1:1625-1649`, mine radii `D1:559-654`, tile grid `cSize=25`
  (`D1:1335`), tile-smooth passes 3 (`D5:237`), scale dead-band 0.05
  (`D1:1998`), forest borders `D6:100-113`, season tables `D1:2075-2084`.
- **Family index** (X03 §2b): 64 families / 493 `Pattern`+`Freq` pairs; e.g.
  `mng/mni/mnc` 6 members ΣFreq 5, `plain_small` 19/13.0625,
  `plain_medium` **24/67.6875** (audit claimed 31/74.6875), `mountains` 7,
  `hills_dark` 4. D9 (`misc.script`) has **7,013** lines, not 6,765.

### Five donor contradictions — re-verified, preserve [O]/[D]

| # | Contradiction | Consequence |
|---|---|---|
| A1 | `frt_*` 16-retry branch unreachable — `for try0:=1 to 1` (`D4:222`) | implement single attempt, not 16 |
| A2 | `fb_*` 1–16 loop always `break`s after one stamp (`D6:151`) | one stamp only |
| A3 | `lake_big` hard-zeroed (`D1:1735`) but re-assigned `plain*35` in desert branch (`D1:1812`) | preserve desert override |
| A4 | layer-by-layer occupancy prefill at `D2:818` is **editor-only** (`not bRandomMap`) | skip in skirmish path |
| A5 | D1 vs D2/D4 use different scale-clamp formulas | keep both, stage-specific |

X03 §6 registers 13 anomalies with multi-pass verdicts and 16 UNVERIFIED items;
COORD/V01 must reconcile them before the spec is marked READY.

---
*Integrated by COORD from A02 + X03.*
