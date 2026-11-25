---
id: Z01
title: "HEIGHT WAVE — decode on-disk height dumps; verify the 'heightmap was never implemented' claim with data"
agent: "Z01 (HEIGHT WAVE, read-only)"
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB__NO_DONOR_ACCESS
scope: "One new file only: this report. No source/asset/config/test/shader/JSON/PNG/queue/git edit; no Godot process; no donor file opened."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
labels: [OBSERVED, DERIVED, UNVERIFIED, REFUTED]
parity_guard: "PORT-INTERNAL MEASUREMENT ONLY. No donor GPU A/B frame exists. NO DONOR PARITY CLAIM."
verdict: "OBSERVED: the seed-20261113 dumps carry a fully populated, NON-FLAT float32 height grid (320x320, -2.964..+2.964 m, std 1.191 m, 63.20% exactly 0, 1.689% of cardinal edges >0.5 m) with large hill/plateau and ravine components. REFUTED: 'the heightmap was never implemented' for those dumps. OBSERVED: older same-seed dumps ARE nearly flat (std 0.041 m, 98.6% exactly 0, no edge >0.5 m). UNVERIFIED: the shipped default (240x240, mediterranean/low_mountains, seed 20261113) has NO on-disk height dump — 0 of 130 height-bearing JSON files are 240x240 — so exact world.stats/dump probes are specified in §8."
---

# Z01 — Height data: is the heightmap flat, and by how much?

> [!IMPORTANT]
> Labels follow the charter: **observed** = literal file content or a computed
> result from decoded bytes; **derived** = arithmetic/control-flow consequence
> of observed data; **UNVERIFIED** = not measurable with the available on-disk
> instruments; **REFUTED** = the claim is contradicted by observed data.
> No Godot process was launched by this agent (Wave G rule: only G04 runs the
> runner). No donor file was read, copied or executed. All analysis scripts
> were written only to the approved temp folder
> `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\z01_*.py`, never into the
> repository. **No donor parity claim.**

---

## 0. Mandate

Owner: *"until now I never really saw hills; every time it was a plain draw — it's like the heightmap was never implemented at all."*

Ticket asks to verify with **data**: decode on-disk dumps (`g32_dump.json`, `dump_20261113_a.json`, `w52_self_base.json`, any others with height arrays); compute min/max/std/percentiles, fraction exactly 0, spatial-gradient distribution, and whether hill/plateau/ravine regions exist; cross-check the code path `game.gd` height sources → `world3d_terrain.gd:1310-1312` vertex Y with `HEIGHT_SCALE`; decide whether height is nearly flat in the shipped default and by how much; if dumps lack height, specify the exact `world.stats` probe.

---

## 1. Evidence read (all read-only)

### 1.1 Dumps decoded (observed)

| # | File | Role |
|---|---|---|
| D1 | `app/shots/g32_dump.json` | 320² dump, `seed=20261113`, `type=land`, mask `land/4pl_mask_land_176_gauss.png`, quality high |
| D2 | `app/shots/t6t90_dumps/dump_20261113_a.json` | same seed/type/mask |
| D3 | `app/shots/t6t90_dumps/dump_20261113_b.json` | same seed/type/mask |
| D4 | `variant3d/tests/results/w52_self_base.json` | 320² selftest save state, `seed=20261113`; `base.height` base64 + top-level `height` PackedFloat32Array (identical data, see §4) |
| D5 | `app/tests/results/w52_self_base.json` | same size/content class as D4 |
| D6 | `app/scans/atomic/def.json` | 320², `seed=20261113`, **same mask**, older (2026-11-20) — the flat comparison case |
| D7 | `scans/scan_8.json`, `app/scans/atomic/{low8,high8,islands8}.json` | other flat/non-flat comparison cases |
| D8 | `scans/t2gen/dump_{8,9}.json` | other non-flat dumps |

An exhaustive walk found **130 JSON files with a base64 `height` array**; all are 320² except four `scans/relief1_hills/*` debug files at 128². **Zero are 240².** (OBSERVED, §4.1.)

### 1.2 Source locations read (observed)

| # | File | Exact lines |
|---|---|---|
| S1 | `variant3d/scripts/mapgen.gd` | `:25-28` constants; `:63-85` R-code `relief()`; `:87-94` `relief_smooth()` flag; `:212-213` `height[i] = hw + relief(cr)`; `:214` smooth flag; `:218-235` coastal smoothing |
| S2 | `variant3d/scripts/game.gd` | `:81-90` legacy amplitude constants; `:91-129` donor-derived coarse grids/meta; `:918-948` bilinear grid sampler; `:960-996` relief-stamp id gate (`plt2`/`k_ravine_1`); `:1115-1118` analytic fallback write; `:1119-1137` stamp-mask dilation; `:1150-1176` `C3MapGen.build` → `height`; `:1191-1210` analytic domes; `:1243-1247` pattern build + `_shape_stamp_relief()`; `:1248-1274` global clamp/dither; `:1275+` collision pass |
| S3 | `variant3d/scripts/main.gd` | `:751-755` `_dump_map()` headless producer; `:767-790` `relief_stamps` producer + config gate; `:791-798` dump schema, **`height` base64 at `:795`** |
| S4 | `variant3d/scripts/world3d_terrain.gd` | `:130-132` `TILE_M=2.0`, `HEIGHT_SCALE=1.0`, `WATER_LEVEL=-0.25`; `:921-958` dump-vs-live height source; `:1227-1243` base64 decode loop (`raw.decode_float(i*4)`); `:1246-1256` opt-in relief stamp; `:1310-1312` vertex Y; `:1492-1498` `stats` height fields; `:1502-1517` `relief_grid` ledger; `:1618-1627` `tile_index` incl. `face_hist` |
| S5 | `variant3d/config.json` | `:24-26` `relief_stamps=true`; `:61-71` camera; **`:75-77` shipped 240² / seed 20261113** |
| S6 | `variant3d/scripts/menu.gd` | `:55,64,71` shipped defaults `mediterranean` / `mediterranean` / `low_mountains` |
| S7 | `variant3d/scripts/data.gd` | `:246-247` `RELIEF_SCALE{hills:1.5}`, `RELIEF_DOME_DELTA{hills:1}`; `:365` `low_mountains → hills` |
| S8 | Godot 4.7 docs, `PackedByteArray.decode_float` | signature `decode_float(byte_offset)` only — native float encoding (little-endian on x86), no endianness flag |

### 1.3 Prior reports read (not new evidence)

`WAVE_G_CHARTER.md`, `CHARTER.md`, `A05_relief_visibility.md`, `RELIEF_01_stamping.md`, `RELIEF_02_stamp_marker.md`. A05's amplitude-vs-footprint analysis is **consistent with** the data below but is not itself re-measured here.

---

## 2. Method (reproducible, offline, read-only)

1. Base64-decode `dump["height"]`; assert `len(raw) == w*h*4` (observed: 409,600 bytes for 320²). Unpack as little-endian float32 (`struct.unpack('<102400f', …)`).
2. Byte-order check (OBSERVED): LE gives `min=-2.964, max=+2.964`; BE gives `min=-3.27e38, max=+3.40e38` (garbage). Godot 4.7's single-argument `decode_float` uses native float encoding, so LE is the correct reading of a `PackedFloat32Array.to_byte_array()` payload (S4:1240, S3:795, S8).
3. Statistics: population mean/std; percentiles by linear interpolation on sorted values; "exactly 0" counts `x == 0.0`; near-zero counts `|x| <= ε`.
4. Spatial gradient: all forward cardinal differences `|h[x+1]-h[x]|` and `|h[z+1]-h[z]|` (204,160 edges on 320²), matching the 1-cell stencil used by `_face_mode_at()` (`world3d_terrain.gd:756-778`) and the collision pass (`game.gd:1275+`).
5. Regions: 4-connected components on threshold masks (`h>t` for hill/plateau, `h<t` for ravine); only components ≥10 cells reported, with bounding boxes and centroids.
6. Note: **the `stats` dictionary alone cannot yield std/zero-fraction/gradient** — S4:1496-1498 exposes only `height_min_m`, `height_max_m`, `height_range_m`. The raw array (dump `height` key) is required.

---

## 3. OBSERVED — per-dump height statistics

### 3.1 Seed-20261113 dumps D1–D4 (identical height payload)

All four decode to the **same SHA-256 prefix `9beb972d7145893f`** over the 409,600 raw bytes, so one statistic block covers D1, D2, D3 and D4's `base.height`:

| Metric | Value (320² = 102,400 cells) |
|---|---|
| min / max / range | **−2.964000 / +2.964000 / 5.928000 m** |
| mean / population std | +0.566362 / **1.191107 m** |
| percentiles | p0 −2.9640, p1 −2.9640, p5 0, p25 0, **p50 0**, p75 0.7370, p95 2.9640, p99 2.9640, p100 2.9640 |
| exactly 0 | **64,712 cells (63.20%)** |
| \|h\| ≤ 1e−6 (incl. −0.0) | 66,149 (64.60%) |
| \|h\| ≤ 0.01 / 0.1 | 66,252 (64.70%) / 67,136 (65.56%) |
| distinct values | 8,065 |
| top values (count) | 0.0 (64,712), +2.964 (9,417), +2.934 (5,684), +1.317333 (2,664), +0.45 (1,986), −2.964 (1,459), −0.0 (1,437), +2.634667 (297) |

D4 also has a top-level `height: PackedFloat32Array(…)` of **102,400 values, 37,688 non-zero, min −2.964 / max +2.964** — i.e. the 3D selftest save state carries the same populated grid, not a zeroed one. (OBSERVED.)

### 3.2 Gradient distribution, D1–D4

| Metric | Value (204,160 edges) |
|---|---|
| mean \|dh\| | 0.038427 m |
| p50 / p75 / p90 | 0 / 0 / 0.08373 |
| p95 / p99 / max | 0.21812 / 0.98202 / **2.63467** |
| edges >0.1 | 16,909 (8.282%) |
| edges >0.25 | 9,309 (4.560%) |
| **edges >0.5 (collision/face cardinal gate)** | **3,449 (1.6894%)** |
| **edges >0.55 (diagonal gate)** | **3,304 (1.6183%)** |
| edges >2.4 / >2.7 | 17 (0.0083%) / 0 |

**Derived:** 98.31% of cardinal edges are ≤0.5 m, so most of the mesh sees a flat board — but 1.69% of edges are steep enough to fire the donor cliff/collision gates, and the maximum edge step is 2.635 m. "Flat" is a coverage statement, not an all-zero field.

### 3.3 The nearly-flat dumps (observed)

| Dump | seed | min / max | mean / std | exactly 0 | grad max | edges >0.5 |
|---|---|---|---|---|---|---|
| `app/scans/atomic/def.json` (same mask+seed as D1) | 20261113 | 0.000 / 1.272 | ~0 / **0.0406** | **98.6%** | 0.2737 | **0%** |
| `scans/scan_8.json` | 8 | 0.000 / 1.2493 | 0.00435 / **0.043568** | **98.13%** | 0.41734 | **0%** |
| `app/scans/atomic/low8.json` | 8 | 0.000 / 1.249 | — / **0.0272** | **99.4%** | — | — |

`def.json` meta has **no `stamp_counts` key**, whereas D1–D3 meta records `hill:22, plateau:3, ravine:1, mountain:2, forest:117, …`. (OBSERVED.) This is a direct, same-seed, same-mask contrast: with relief passes present the grid is non-flat; in the older dumps it is a near-zero field with only small positive bumps.

### 3.4 Other non-flat dumps (observed)

| Dump | seed | min / max | std | exactly 0 | edges >0.5 |
|---|---|---|---|---|---|
| `scans/t2gen/dump_8.json` | 8 | −2.964 / +2.964 | 1.378381 | 56.33% | 2.4231% |
| `scans/t2gen/dump_9.json` | 9 | −2.964 / +2.964 | 1.210993 | 63.76% | 2.4672% |

Corpus-wide (DERIVED from all 130 height dumps): **30 dumps are in the flat class (std < 0.1 m), 100 are non-flat (std 0.166–2.243 m).** Flatness is therefore a function of generator era/config, not of the height-array mechanism itself.

---

## 4. OBSERVED — hill / plateau / ravine regions exist in D1–D4

| Region test | Largest 4-connected components (cells, bbox x0..x1 / y0..y1, centroid) |
|---|---|
| hill `h>0.5` | **18,047** cells, x50..203 / y24..283, centroid (132,144) = **17.6% of the map**; then 2,921 (x197..261/y26..94), 1,881 (x211..271/y170..254), 1,580 |
| hill `h>1` | 15,808 (x53..200/y63..281), 2,633, 1,683, 1,143 |
| hill `h>2` | **13,960** (x56..198/y68..258), 2,067, 833, 443 — 7 components ≥10 cells |
| plateau cap `h≈2.964` | **9,417 cells (9.2% of map)** at exactly +2.964; +2.934 adds 5,684 (5.6%) |
| ravine `h<−0.5` | **2 components**: 2,139 cells (x174..212 / y252..313, centroid (193,286)) and 187 (x196..212 / y163..178) |
| ravine `h<−2` | 1,741 (x176..210/y257..311) and 79 (x198..210/y165..173) |

By contrast, in flat dump `def.json` the largest `h>0.5` component is **71 cells**, there is **no `h>2`** region and **no `h<−0.5`** region. (OBSERVED.)

**Derived:** the non-flat dumps contain genuine large-scale relief: three distinct hill/plateau massifs plus two ravines, one of which is a ~39×62-cell gully in the south-central map. The plateau is a **clamped flat top** (9.2% of cells at exactly +2.964), i.e. a plateau in the literal sense — which can itself read as "flat" locally, but it is elevated 5.9 m above the ravine floor.

---

## 5. OBSERVED — code-path cross-check (source → vertex Y)

```
mapgen.gd build()                         :212-213
  h = -1.1*b*(1+r*3.5) + relief(R-code)   :25-28,75-85
      R=255/191 -> +2.964*R/255 ; R=96/112 -> +1.3173*R/255
      R=48/88   -> -2.964*R/255 ; all other codes -> 0
      relief_smooth flag exposed, NOT consumed       :87-94,214,238
        ↓
game.gd _gen_base()                       :1150-1176
  height <- C3MapGen.build(...)           :1174-1176
  + analytic domes (1-dd)^2*(2.964/2.25)*relief_scale  :1191-1210
  + _shape_stamp_relief()                  :1243-1247
      stamp id gate: plt2 / k_ravine_1 only           :984-996
      donor 8x10 grid branch or analytic radial fallback :999-1118
  + global clamp to [-2.964, +2.964] with 0.03 dither :1248-1274
  + collision pass |dh|>0.5 / >0.55                   :1275+
        ↓
main.gd _dump_map()                       :751-798
  dump["height"] = base64(game.height.to_byte_array())  :795
        ↓ (or world3d_terrain.gd:921-958 synthesises the same shape from live game.height)
world3d_terrain.gd build()                :1220-1312
  raw = base64_to_raw(dump["height"])      :1229
  height[i] = raw.decode_float(i*4)        :1240
  verts[i].y = height[i] * HEIGHT_SCALE(1.0) :1310-1312
  stats: height_min/max/range_m           :1496-1498
  stats: tile_index.face_hist             :1625
  stats: relief_grid.applied/stamps       :1502-1517
```

**OBSERVED / DERIVED:**

1. The mesh consumes exactly the decoded dump array; `HEIGHT_SCALE=1.0` (`:131`) means dump metres are used verbatim as vertex Y. There is no scale step that could zero the field.
2. The height sources are **three** independent adds (mask R, domes, stamps) followed by a single clamp — consistent with the ±2.964 saturation and the discrete values seen in §3.1.
3. `game.gd:81-90` documents that the larger `+1.317333 / −2.964` amplitudes belong to donor `//`-disabled multipliers; current `mapgen.gd:75-85` uses `+0.495937 / −0.557929` at R=96/R=48. The dumps' dominant `+1.317333 / −2.964` values therefore match the **legacy constants** (DERIVED: dumps predate the current RCODE-FIX decoder; git shows D1–D3 committed 2026-11-24 and `mapgen.gd` last changed 2026-11-25). Which exact config/flag produced each dump is **UNVERIFIED** — no dump records a relief id (meta has `type`, `quality`, `mask`, `stamp_counts` only).
4. Normals are computed from the same array (`world3d_terrain.gd:901-917,1387`) and consumed by the shader; no step zeroes them. (Confirms A05's "smooth normals REFUTED" from a different angle: the data itself is present.)
5. Cliff/collision gates need `|dh|>0.5/0.55`; §3.2 shows 1.69%/1.62% of edges qualify in D1–D4 and **0%** in the flat dumps — so on flat dumps no cliff art can ever fire, on D1–D4 a small fraction can.

---

## 6. Direct answer to the owner (evidence-labelled)

| Claim | Verdict | Evidence |
|---|---|---|
| "heightmap was never implemented at all" | **REFUTED for the seed-20261113 dumps** — a full 102,400-cell float32 grid is present, non-zero on 36.8% of cells, with ±2.964 m range and distinct hill/plateau/ravine regions | §3.1, §4; `main.gd:795`, `world3d_terrain.gd:1229-1243,1310-1312` |
| "every time it was a plain draw" | **OBSERVED for an older dump class** — same seed/mask, 98.6% zeros, std 0.041 m, no edge >0.5 m, no region >71 cells | §3.3 `app/scans/atomic/def.json`; git 2026-11-20 |
| "height is nearly flat in the shipped default (240², mediterranean/low_mountains, seed 20261113)" | **UNVERIFIED from dumps** — no 240² height dump exists on disk (0/130); the shipped settings are OBSERVED (`config.json:75-77`, `menu.gd:55,64,71`) and the code path would add base R relief + hills domes (scale 1.5, +1 dome: `data.gd:246-247,365`) + relief stamps, but the resulting array is not measured here | §4.1, §5, §8 |
| "by how much" (measured cases) | D1–D4: std **1.191 m**, range **5.928 m**, 63.20% exactly 0, 1.689% steep edges. Flat dumps: std **0.027–0.044 m** (≈**27–44× smaller**), 98.1–99.4% exactly 0 (≈**35 percentage points** more), **0%** steep edges | §3 |

**Derived synthesis:** the owner's experience is compatible with *either* (a) having looked at the older near-flat dumps/frames, or (b) the non-flat grid being visually under-read because 63% of cells are exactly zero, 9.2% are a clamped flat cap, and only 1.69% of edges are steep — the amplitude-vs-footprint mechanism already documented in A05. Data here **cannot** distinguish (a) from (b) for the owner's exact frame; that needs the §8 probe plus a capture.

---

## 7. UNVERIFIED / BLOCKED — do not guess

1. **No 240² dump** of any kind with a height array exists on disk; the shipped default's actual numeric height grid is unmeasured.
2. The available height dumps are 320² `type=land` with mask `land/4pl_mask_land_176_gauss.png` (or seeds 7/8/9 with other masks) — **not** the shipped `mediterranean` map shape with `low_mountains` relief.
3. Which exact generator config/era produced each dump is not recorded in the dumps; the amplitude constants match the legacy decoder (DERIVED), but no config snapshot is attached.
4. No donor GPU A/B frame exists; whether any of these heights *looks* like the reference hills/ravines is **UNVERIFIED**. **No donor parity claim.**
5. `stats` exposes only min/max/range; std, zero fraction and gradient must come from the raw array.
6. The 3D module can source height either from a supplied dump or from live `game.height` (`world3d_terrain.gd:921-958`); `stats` has no explicit height-source key, so a stats print alone cannot prove which array a given frame used.
7. Donor engine sculpt blend, row-flip sign and stamp extent remain UNVERIFIED (A05 §7, RELIEF-01 §5, RELIEF-02 §6) — not re-tested here.

---

## 8. Exact `world.stats` / dump probe needed for the shipped default

**This agent did not run it — G04 owns the runner.** Minimal contract for whoever does:

1. **Generate the array.** Run the existing headless `--dump-map` path (`main.gd:751-755`) with `config.json` untouched (240², seed 20261113: `config.json:75-77`) and the shipped lobby defaults mediterranean / `low_mountains` (`menu.gd:55,64,71` → `data.gd:365` `hills` → `RELIEF_SCALE=1.5`, `RELIEF_DOME_DELTA=1` at `data.gd:246-247`). The dump already contains everything needed:
   - `dump["height"]` — base64 float32, `main.gd:795` (decode LE per §2);
   - `dump["meta"]` — `type`, `mask`, `stamp_counts`, `relief_grid` ledger (`main.gd:797`, `game.gd:1139-1148`);
   - `dump["relief_stamps"]` — emitted only when `features.terrain.relief_stamps=true` (`config.json:24-26`, gate `main.gd:788-790`, producer `:777-783`).
2. **Compute offline** from `dump["height"]` exactly the §2 metrics: min/max/std, p0/p1/p5/p25/p50/p75/p95/p99/p100, exactly-zero fraction, 204,160-cardinal-edge gradient distribution (p50/p95/p99/max, counts >0.5/>0.55), and connected components at `h>0.5/1/2` and `h<−0.5/−1/−2`.
3. **Read the mesh's own view.** In the same job, after `terrain.build()`, print `terrain.get("stats")` (access pattern: `t_terrain_shore.gd:781`, `t_terrain_only.gd:507`) and capture exactly:
   - `stats["grid"]` → expect `{w:240,h:240,cells:57600}`;
   - `stats["height_min_m"]`, `stats["height_max_m"]`, `stats["height_range_m"]`, `stats["height_scale"]` (`world3d_terrain.gd:1493-1498`);
   - `stats["tile_index"]["face_hist"]` (`:1625`) — non-zero faces prove relief reaches geometry selection;
   - `stats["relief_grid"]["applied"]`, `["stamps"]`, `["tables"]` (`:1502-1517`);
   - `stats["tile_index"]["source"]` and a SHA/min-max comparison of `dump["height"]` vs `stats` to disambiguate dump-fed vs live-fed height (§7 #6).
4. **Acceptance for the owner's question:** if decoded std < 0.1 m, exactly-zero > 95% and zero edges >0.5 m, the shipped default is genuinely flat in data; if min/max ≈ ±2.964 with >1% steep edges and >1000-cell hill/ravine components (as D1–D4), the heightmap exists and the remaining gap is visual/readout, not generation. Either result is a **port-internal measurement**, not donor parity.

---

## 9. Summary

- **OBSERVED:** 130 on-disk JSON files carry height arrays; all are 320² (four 128² debug files), none 240². Four seed-20261113 files (`g32_dump.json`, `dump_20261113_a/b.json`, `w52_self_base.json`) share a byte-identical, non-flat 320² float32 height grid: **−2.964…+2.964 m, std 1.191 m, 63.20% exactly zero, 1.689% of edges >0.5 m**, with a 18,047-cell hill massif, a 9,417-cell +2.964 plateau cap and two ravines (2,139 + 187 cells).
- **OBSERVED:** older same-seed/same-mask dumps (`app/scans/atomic/def.json`, `scans/scan_8.json`) are nearly flat: **98.1–98.6% zeros, std 0.027–0.044 m, no edge >0.5 m, no region above 71 cells**. 30 of 130 dumps are in that flat class.
- **REFUTED:** "the heightmap was never implemented" for the seed-20261113 dumps; the grid is decoded and wired to `verts[i].y = height[i]*1.0` (`world3d_terrain.gd:1310-1312`).
- **UNVERIFIED:** the shipped 240² mediterranean/low_mountains default — no on-disk dump; exact `world.stats` + dump probe specified in §8. Whether the owner's frame came from the flat or non-flat class cannot be settled from data alone.
- No code, config, asset, test, shader, donor, queue or git edit; no Godot job. **No donor parity claim.**

*End of Z01.*
