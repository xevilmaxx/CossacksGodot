---
id: A05
title: "Relief visibility — is generated height reading as flat, and why cliffs/ravines do not appear"
agent: "A05 (terrain swarm diagnosis, read-only)"
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_CODE_EDIT__NO_GODOT_JOB__NO_DONOR_ACCESS
scope: "One new file only: this report. No source, asset, config, test, shader, JSON, PNG, donor, queue or git edit; no runner job."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
labels: [observed, derived, inferred, UNVERIFIED, REFUTED, BLOCKED]
parity_guard: "PORT APPROXIMATION — internal source/measurement consistency only. No donor GPU A/B frame exists. NO DONOR PARITY CLAIM."
verdict: "RELIEF IS GENERATED IN THE LIVE PATH BUT READS FLAT: PRIMARY CAUSE IS AMPLITUDE-vs-FOOTPRINT SCALE (CONFIRMED source), COMPOUNDED BY ONLY 2/26 DONOR GRIDS REACHING HEIGHT (CONFIRMED) AND BY FACE-MODE GATES THAT CANNOT PROMOTE CLIFF ART ON GENTLE SLOPES (CONFIRMED mechanism). SMOOTH NORMALS ARE REFUTED AS THE CAUSE. k_ravine_1 IS BLOCKED (RELIEF-02) BUT IS NOT THE WHOLE STORY: THE DONOR-ACTIVE ravine_big FAMILY HAS NO PORT GRID AT ALL."
---

# A05 — Relief visibility: why the reference ravines/cliffs are missing

> [!IMPORTANT]
> Donor is truth. Every claim below is labelled **observed** (literal current
> source line, dump measurement, or decoded donor field quoted from a prior
> report), **derived** (arithmetic/control-flow consequence of observed lines),
> **inferred** (attribution without a pixel-aligned donor A/B), **UNVERIFIED**
> (not measurable with the available instruments), **REFUTED**, or **BLOCKED**
> (no producer/instrument exists). No donor file was read, copied or executed by
> this worker; donor facts are cited from prior read-only reports. No Godot
> process was launched. No code, config, asset, test or shader was edited.
> **No donor parity claim.**

---

## 0. Mandate and boundary

The charter (`:50-52`, suspect 6) records the gap: donor samples show ravines,
cliffs and rolling relief; our capture reads near-flat. This ticket asks:

1. Is relief actually generated but visually flat because of **height scale**,
   **smooth normals**, **camera**, or **missing relief markers**?
2. Are cliffs/ravines absent because the donor marker producer is **BLOCKED**
   (RELIEF-02)?
3. What **single change** would most improve the look?

Answer is built from the CURRENT tree at the exact locations named in the
ticket — `variant3d/scripts/mapgen.gd`, `game.gd` `_gen_base()` /
`_gen_patterns()` / `_shape_stamp_relief()` (`:918-1279`), and
`world3d_terrain.gd` mesh/normals/face-mode promotion (`:1300-1456`) — plus the
three requested reports DPATTERN-01, RELIEF-01, RELIEF-02 and the later RELIEF
chain reports that changed the state.

---

## 1. Evidence read (all read-only)

### 1.1 Current port source (observed)

| # | File | Exact locations read |
|---|---|---|
| S1 | `variant3d/scripts/mapgen.gd` | `:25-30` constants; `:63-85` `relief()` R-code decode (RCODE-FIX-01); `:87-94` `relief_smooth()`; `:145-238` `build()`; `:212-215` height write; `:218-235` coastal smoothing |
| S2 | `variant3d/scripts/game.gd` | `:64-73` stamp state; `:74-123` relief constants + two 8×10 tables + `RELIEF_GRID_META`; `:733,850` `_gen_patterns()` (height untouched); `:909-916` `_generate_map()`; `:918-934` `_sample_relief_grid()`; `:937-1113` `_shape_stamp_relief()`; `:1115-1279` `_gen_base()`; `:1175` domes; `:1210-1212` pattern build + stamp call; `:1219-1239` global clamp; `:1243-1264` collision |
| S3 | `variant3d/scripts/pattern_gen.gd` | `:9` `DONOR_UNITS=160`; `:24-33` relief presets; `:34-52` `RELIEF_RECIPES` (incl. `ravine_big` at `:47`) |
| S4 | `variant3d/scripts/world3d_terrain.gd` | `:130-132` `TILE_M=2.0`, `HEIGHT_SCALE=1.0`, `WATER_LEVEL`; `:137-181` sun/colours/cliff gates; `:756-778` `_face_mode_at()`; `:805-836` `_donor_cliff_name()`; `:1310-1312` vertex Y; `:1332-1354` cliff-face promotion; `:1387` normals; `:1407` UV2; `:1434-1455` material + `cast_shadow=OFF` |
| S5 | `variant3d/shaders/terrain_tileindex.gdshader` | `:43` `render_mode blend_mix, unshaded, cull_disabled`; `:274-326` vertex; `:294-306` sun/normal/diffuse; `:427` `rgb*…*v_packed+v_specular` |
| S6 | `variant3d/scripts/main.gd` | `:751-810` `_dump_map()`; `:767-783` producer filter `plt2`/`k_ravine_1`; `:788-803` flag gate |
| S7 | `variant3d/config.json` | `:24-26` `features.terrain.relief_stamps = true`; `:61-71` camera (`pitch -32`, `max_height 58`, `start_zoom 0.3448276`); `:75-77` shipped 240² / seed 20261113 |
| S8 | `variant3d/tests/fixtures/small_map_64.json` | 64² overlay (seed inherited 20261113), per prior reports |

### 1.2 Prior reports cited (not new evidence gathered here)

`DPATTERN_01_relief_grids.md` (`:142,152,154,168-169,271-285,341-346,
348-382,504-537,595-626`); `RELIEF_01_stamping.md` (`:71-91,117-131`);
`RELIEF_02_stamp_marker.md` (`:49-84,144-164,188-205`);
`RELIEF_ENABLE_01.md` (`:118-134`); `RELIEF_LIVE_DIAG_01.md`
(`:121-165,201-209,271-298`); `RELIEF_LIVE_FIX_01.md`
(`:156-175,237-259,263-276`); `RELIEF_SEED_SCAN_01.md` (`:184-240`);
`RELIEF_SEED_PROBE_01.md` (`:143-181`); `RELIEF_VISUAL_01.md`
(`:101-174,224-247`); `HEIGHT_GEN_DEEP_01.md` as summarised in
`RELIEF_LIVE_FIX_01.md:86-131`.

---

## 2. The full height/relief chain, end to end (observed)

```
mapgen.gd build()            height = -1.1*b*(1+r*3.5) + relief(R-code)   :212-213
                              relief(): 255/191→+2.964·code/255, 96/112→
                              +1.317·code/255, 48/88→-2.964·code/255, else 0  :75-85
                              relief_smooth flag exposed, NOT consumed        :87-94
        ↓
game.gd _gen_base()          height ← C3MapGen.build(...)                  :1139-1141
                             + parabolic domes (1-dd)²·1.317·relief_scale     :1162-1175
                             terrain roles from h thresholds                 :1182-1196
                             C3PatternGen.build(...) → stamps                :1210-1211
                             _shape_stamp_relief() → live height writes      :1212, :937-1113
                                 id gate: plt2 / k_ravine_1 only              :974-984
                                 donor grid branch (8×10 bilinear)           :1039-1057
                                 analytic radial/taper fallback               :1059-1102
                             global clamp/dither on non-donor cells          :1219-1239
                             collision pass |dh|>0.5/0.55 → terrain=5        :1243-1264
        ↓
game.gd _gen_patterns()      paints terrain/resources; "never mutate height post-collision"  :733,850
        ↓
game.gd _assign_tileblocks() donor detail-bitmap/smoothing tile ids          :916, :1942
        ↓
world3d_terrain.gd build()   vertex.y = height[i] * HEIGHT_SCALE(=1.0)       :1310-1312
                             face = _face_mode_at() unless shore/water       :1332
                             cliff art only when face!=0 AND |h| gates pass  :1340-1354
                             normals = 1-cell forward difference             :1387, :901-917
                             UV2 = (tile_id, face)                            :1407
                             material = unshaded tile-index shader           :1434-1446
        ↓
shader                       n transformed to eye space, donor Blinn-Phong   :294-306
                             rgb = albedo * v_packed + specular              :427
```

Two independent height paths exist and must not be conflated:
- **Live boot**: `game.gd:_shape_stamp_relief()` writes `game.height[]`
  (`S2:1212`); `world3d_terrain.gd` synthesizes its own marker-free dump from
  that array (`RELIEF_LIVE_DIAG_01:101-119`) and builds the mesh from it.
- **`--dump-map` capture**: `main.gd` appends an optional `relief_stamps` key
  gated by the config flag (`S6:788-803`); the RELIEF-01 dump consumer in
  `world3d_terrain.gd` is a separate, opt-in path. `RELIEF_LIVE_FIX_01:70-76`
  explicitly records that the dump-path clamp conflict was refuted and that
  consumer was not the live fix target.

---

## 3. Direct answers to the four questions

### 3.1 Is relief actually generated? — YES, but mostly analytic/small

**observed + derived.** Live relief has three sources: (a) base R-code height
(`S1:212-213`), (b) parabolic domes (`S2:1162-1175`), (c) stamp relief
(`S2:1212` → `:937-1113`). Donor-derived grid heights reach (c) for **two ids
only** (`S2:974-984`); everything else uses the analytic radial/taper profile
(`S2:1059-1102`), whose amplitudes are the legacy constants `+2.964`,
`+1.317`, `−2.964` (`S2:81-83`). So relief is generated, but it is
**port-analytic for the overwhelming majority of stamps**, not donor-grid
sculpt. This matches `RELIEF_LIVE_DIAG_01:183-209` (CONFIRMED).

### 3.2 Height scale? — YES: PRIMARY CAUSE (CONFIRMED source, visual effect inferred)

**observed.** `HEIGHT_SCALE = 1.0` and `TILE_M = 2.0 m` (`S4:130-131`); the
vertex Y is literally `height * 1.0` (`S4:1310-1312`). All height sources are
bounded to ≈ `±2.964 m` (`S2:81-83`, `:1055`, `:1102`, `:1239`). Stamp
footprints come from donor cells scaled by `W / DONOR_UNITS` with
`DONOR_UNITS = 160` (`S2:955`, `S3:9`): at the shipped 240² map that is ×1.5,
so a `plt2` cap (42×55 donor cells, `DPATTERN-01:154`) spans roughly 63×82
cells ≈ **126×164 m** for a **≈3 m** rise.

**derived:** slope ≈ 3/164 ≈ **1.8 %** (≈1°). Even on the 64² capture
(×0.4, ≈17×22 cells ≈ 34×44 m) it is ≈3/44 ≈ 7 % (≈4°). A 4° slope under a
70°-elevation sun (`S4:137-138`, `y=0.939`) produces only a few percent
diffuse change (`dot(l,n)` in `S5:301`). `RELIEF_VISUAL_01:127-157` observed
exactly this: a real 64² frame with **no hills, no ridge, no self-shadowing**,
the ground reading as a flat board.

**Contributing and newly decisive:** RCODE-FIX-01 (`S1:63-85`) corrected the
base relief decoder to the donor's live amplitudes — `C_HILL·96/255 ≈ +0.496`
and `C_RAVINE·48/255 ≈ −0.558`, with `R=88` routed to ravine instead of
`+1.317`. The old port bands (`+1.317 / −2.964`, `RELIEF_LIVE_DIAG_01:281`)
were larger. **Derived:** the current base grid is *flatter than earlier
captures* by roughly 2.7× on hills and 5.3× on ravines. This is a correctness
fix, not a regression to undo — but it makes the amplitude/footprint problem
the dominant visual fact.

**Rejected as a fix:** simply raising `HEIGHT_SCALE` or the amplitude literals
would be an invented visual multiplier (no donor citation, violates the
charter's "no invented donor constants / no synthetic shape" guardrail,
`:57-63`). Label: **NOT DONOR-GROUNDED**.

### 3.3 Smooth normals? — REFUTED as the cause

**observed.** Mesh normals are computed per vertex and uploaded
(`S4:1387`, array at `:1423`) and **are consumed** by the in-shader
Blinn-Phong: `n = normalize((VIEW_MATRIX * MODEL_MATRIX * vec4(NORMAL,0)).xyz)`
(`S5:298`), `diffuse = max(dot(l,n),0)*diffuse_rgb` (`:301`), folded into final
RGB at `:427`. `S4:901-917` uses a *one-cell forward difference*, explicitly
chosen so a 1-cell cliff step is **not** averaged away. The shader is
`unshaded` only to prevent Godot lighting the already-lit donor colour twice
(`S5:31-43`); it is not discarding the normal.

**derived:** normals are near-uniform **because the heights are near-uniform**
(§3.2), not because they were smoothed away. Label: **REFUTED**.

### 3.4 Camera / sun? — CONTRIBUTING AMPLIFIER, NOT ACTIONABLE

**observed.** The 64² capture camera was at height 58 m looking ≈13° above the
horizon (`RELIEF_VISUAL_01:105`), and the shipped config is already at the
donor's maximum zoom-out (`S7:14,70`: `start_zoom 0.3448276` = SphereHeight 58
m; `pitch -32`). The donor sun is high (`S4:137-138`, elevation ≈70°).

**derived/inferred:** a shallow eye plus a high sun minimizes silhouette and
shading contrast from few-degree slopes. But the camera is already at the
donor-legal wide end and the sun is a donor literal — changing either would be
a non-donor-grounded visual fudge. Label: **CONTRIBUTING (inferred), NOT A FIX
TARGET**.

### 3.5 Missing relief markers? — PARTIAL, and NOT why live terrain is flat today

**observed.** The config flag is `true` (`S7:24-26`); the producer emits only
`plt2`/`k_ravine_1` (`S6:777-783`); the id gate in the live consumer accepts
only those two (`S2:974-984`). `RELIEF-ENABLE-01:118-134` measured a flag-on
dump with the key present but `[]` for seed 20261113. However
`RELIEF_SEED_PROBE_01:143-181` **runtime-confirmed** seed 20261150 emits
`relief_stamps=[{plt2,cx:54,cy:33}]`, `candidates=1`, `applied_cells=443`, with
changed `height`/`tileblock` hashes. And `RELIEF_LIVE_FIX_01:156-175` wired the
grid into the **live** `game.gd` path, so the marker is no longer dump-only.

**derived:** the live flatness is therefore **not** explainable by "the flag
is off / the marker never reaches the live mesh" — that was true before
RELIEF-LIVE-FIX-01 and is superseded now (`RELIEF_LIVE_DIAG_01:295-297`
itself flags the supersession). What *is* missing is **coverage**: 2 decoded
grids out of 26 (`DPATTERN-01:140-170`), and one of those two cannot be
emitted. Label: **PARTIAL CONFIRMED**.

### 3.6 Are cliffs/ravines absent because RELIEF-02 is BLOCKED? — NECESSARY BUT NOT SUFFICIENT

**observed.** `RELIEF_02_stamp_marker.md:68-84,144-164` establishes:
`k_ravine_1` is absent from `donor_patterns.json` and every family list,
`ravine_medium` has no recipe in `pattern_gen.gd:43-52`, and the donor itself
`//`-disables `ravine_medium` at `dogenerate.inc:1760` while stamping
`ravine_big` at `:1761` (`DPATTERN-01:341-346`). The current gate still
comments this at `S2:970-973`, and the producer filter at `S6:774-776`.

**observed (decisive nuance).** The donor's **active** ravine family is
`ravine_big` (`k_ravine_big_stone_1..8`), and the port **does** place it —
`S3:47` has `["ravine_big", "plt", 1.5, "ravine"]`. But `RELIEF_GRID_META`
contains only `k_ravine_1` and `plt2` (`S2:118-123`). `DPATTERN-01:152` decoded
`k_ravine_big_stone_1` (84×100, offset 8225, min −2.9636 / max +0.1739), but no
port table exists for it.

**derived:** unblocking `k_ravine_1` alone would not produce the reference
ravines, because (a) the donor disables that family in the skirmish path, and
(b) even if emitted it would be a coarse 8×10 block-mean table
(`DPATTERN-01:595-600` labels them "debug/preview aids only"). Conversely, a
real donor ravine **can** be obtained without changing family coverage by
decoding/exporting the already-placed `ravine_big` grids. Label: **BLOCKED is a
real cause for `k_ravine_1`; the deeper, dominant cause is that the
donor-active ravine family was never decoded into the port** (CONFIRMED).

### 3.7 Why no grey cliff faces even where height exists

**observed.** Face promotion requires `|Δh| > 0.5` (cardinal) or `> 0.55`
(diagonal) (`S4:756-778`, thresholds `:161-162`); cliff art then requires
`|h| ≥ 0.1` and `>2.4/>2.7` for rock4/rock8 (`S4:805-836`, constants
`:179-181`); the tile is only swapped when `face != 0` (`S4:1340-1354`).

**derived:** with the ≈1–4° slopes of §3.2, `|Δh|` between neighbouring cells
stays far below 0.5, so `face` remains 0 and **no `rockNvf`/`rockNvs` art is
ever selected**. The reference's grey rock faces are therefore absent even
though small height variation exists. Label: **CONFIRMED mechanism; visual
contribution inferred** (no donor A/B).

---

## 4. Evidence-labelled root-cause ranking

| Rank | Cause | Status | Evidence (`path:line` / report) | Explains |
|---:|---|---|---|---|
| **1** | **Amplitude vs footprint**: ≤±2.964 m spread over footprints that grow with map size (W/160); base R-code amplitudes now +0.496/−0.558. Heights are near-flat before rendering. | **CONFIRMED source; visual effect inferred (one real capture observed)** | `S1:63-85,212-213`; `S2:81-83,955,1055,1102,1162-1175,1219-1239`; `S3:9`; `S4:130-131,1310-1312`; `RELIEF_VISUAL_01:127-157` | Near-flat capture, no hills/ridges/self-shadow; weak diffuse contrast |
| **2** | **Grid coverage**: only 2/26 decoded donor grids reach live height; id gate hard-codes `plt2`/`k_ravine_1`. | **CONFIRMED** | `S2:84-123,974-984`; `DPATTERN-01:140-170`; `RELIEF_LIVE_FIX_01:263-276`; `RELIEF_SEED_PROBE_01:143-181` | Most stamps use analytic profile; no donor hill/ravine silhouettes |
| **3** | **Ravine family gap**: donor-active `ravine_big` is placed by the port but has no decoded grid; `k_ravine_1` producer is BLOCKED and donor-disabled. | **CONFIRMED (BLOCKED for k_ravine_1)** | `S3:47`; `S2:118-123,970-973`; `S6:774-776`; `RELIEF_02:68-84,144-164`; `DPATTERN-01:152,341-346` | No ravines / asymmetric gullies / raised far banks at all |
| **4** | **Face-mode gates cannot fire** on the gentle slopes of rank 1 → no grey cliff art. | **CONFIRMED mechanism; contribution inferred** | `S4:161-162,179-181,756-778,805-836,1332-1354` | Absence of rock faces in reference samples |
| **5** | **Camera/sun contrast**: shallow eye (58 m, ≈13°) + high donor sun (≈70°) under-reads few-degree slopes. | **CONTRIBUTING (inferred); NOT ACTIONABLE** | `S7:14,61-71`; `S4:137-138`; `RELIEF_VISUAL_01:105,153-157`; `S5:294-306,427` | Amplifies rank 1; cannot be fixed without leaving donor grounding |
| **6** | **"Flat because normals are smoothed"** — normals ARE used; they are near-up because heights are near-up. | **REFUTED** | `S4:901-917,1387,1423`; `S5:43,298,301,427` | Not a cause |
| **7** | **"Flag/marker never reaches live terrain"** — true before RELIEF-LIVE-FIX-01, superseded now. | **REFUTED for current tree; CONFIRMED for dump path** | `S2:1212,974-984`; `S6:788-803`; `RELIEF_LIVE_FIX_01:156-175`; `RELIEF_LIVE_DIAG_01:295-297` | Not the current cause |
| **8** | **Pale stepped marks** on flat land (tile-id art, not relief) — a different symptom owned by other tickets. | **Mechanism CONFIRMED upstream; attribution UNVERIFIED here** | `RELIEF_LIVE_DIAG_01:212-255,271-298`; `RELIEF_VISUAL_01:141-174` | The white bands, not the flatness |

**Cross-check:** ranks 1–4 all concern *height shape*; rank 8 concerns *colour*.
No path writes pale colour from a height stamp (`S2:1055,1102` write height
only; `S5:427` gets RGB from the atlas). Killing the marks will not add relief,
and adding relief will not kill the marks.

---

## 5. The single change that would most improve the look

**Expand the live, id-gated donor-grid stamp from 2 patterns to the decoded
donor-active relief families — above all `k_ravine_big_stone_*` from
`ravine_big` — using full derived float32 numeric tables instead of the two
8×10 block-mean tables.**

Why this one, and not another:

- It targets ranks **2 and 3**, the only causes that remove whole *classes* of
  reference geometry (ravines, asymmetric lips, broad plateau caps, hill
  crests). Rank 1 cannot be fixed without donor-grounded shape data; this
  change supplies that data at the amplitude the donor authored, rather than
  multiplying an arbitrary scale.
- It needs **no family-coverage decision and no new producer**: `ravine_big`
  is already in `RELIEF_RECIPES` (`S3:47`) and the live consumer reads
  `st.name` directly (`S2:974`), so adding ids to `RELIEF_GRID_META` is
  sufficient. This sidesteps the RELIEF-02 dilemma (enabling donor-disabled
  `ravine_medium` would change coverage — `RELIEF_02:154-157`).
- It is donor-grounded and label-safe: only **numbers** cross the boundary, per
  `DPATTERN-01:504-537`; blend stays `PORT APPROXIMATION`, row flip stays
  `UNVERIFIED`, no noise/dither-as-shape, no donor binary copied.

**Caveat (UNVERIFIED):** the 8×10 tables are debug aids; full windows may
still read as flat at a 240² footprint (rank 1). A donor GPU A/B remains the
only way to judge the result. **No parity claim.**

---

## 6. Three concrete fixes (proposals only — not executed)

### Fix 1 — Highest leverage: give the live stamp real donor grids for the families already placed

**File:** `variant3d/scripts/game.gd`

**Exact locations:**
- `:84-123` — replace/extend `RELIEF_GRID_K_RAVINE_1`, `RELIEF_GRID_PLT2` and
  `RELIEF_GRID_META` with a derived numeric table for every decoded
  donor-active relief id (min. `k_ravine_big_stone_1` `:152`; plus `plt1/3/4/5`,
  `hil1..4`, `g_hil1..9`, `f_plt_big_1`), transcribed per `DPATTERN-01:504-537`.
  Keep verbatim `HeightFieldScale/Min/Max`, keep the `PORT APPROXIMATION`
  provenance block at `:84-91`.
- `:974-984` — extend the id gate: select a grid for any id present in the new
  meta table; keep `candidates` counting and the "no id invented" rule.
- `:1039-1057` — unchanged blend formula, but sample the full `w×h` grid (new
  sampler beside `_sample_relief_grid()` at `:918-934`) over the existing
  `st.cells` footprint; keep the single port ±2.964 bound at `:1055`.
- `:1104-1113` — update the ledger `tables`/`source` strings to match.

**Acceptance:** a dump for a seed with a `ravine_big` stamp shows
`candidates>0`, `applied_cells>0`, changed `height`/`tileblock` hashes, and at
least one cell below −2.0. No tile/RNG/collision rule changes.

### Fix 2 — Make cliff-face promotion reachable on real relief

**File:** `variant3d/scripts/world3d_terrain.gd`

**Exact locations:**
- `:756-778` `_face_mode_at()` — today a pure `|Δh|>0.5/0.55` test on the
  smoothed cell-centred grid. Add a relief-aware input: either consume a
  per-cell donor-delta/relief flag carried from `game.gd:1039-1057` (the
  `_relief_donor_mask` already exists at `game.gd:73,1056`), or apply the donor
  `cDiff` thresholds to the sampled donor grid delta before the height clamp.
- `:805-836` `_donor_cliff_name()` and `:1332-1354` (cliff promotion inside the
  mesh loop) — ensure promoted cells resolve `rockNvf`/`rockNvs` art; keep the
  water/shore-first ordering at `:1330-1331`.
- Document the change as **PORT APPROXIMATION** — the donor promotion rule is
  `UNVERIFIED` (`TERRAIN2-01 §6 #3`, `RV-TRN-01` verdict C, cited at `:752-755`).

**Acceptance:** with Fix 1 active, `_face_hist` shows non-zero face 1/2 counts
and `_rock_override_cells`/`_face_tilt_cells` increase on the stamped footprint;
vertex/index/surface counts stay unchanged.

### Fix 3 — Consume the donor `relief_smooth` flag instead of exposing it as data only

**File:** `variant3d/scripts/mapgen.gd`

**Exact locations:**
- `:87-94` `relief_smooth()` already returns the donor `bsmooth` flag
  (`generatemap.inc:354,358,362,367`) but `build()` only writes it to the
  result dictionary (`:214,238`).
- `:218-235` — apply a labelled local smoothing pass to cells with
  `smooth[i] != 0`, reusing the existing 4-neighbour 0.5 blend at `:233-235`
  (already used for the coast) as a **PORT APPROXIMATION** of the donor
  `SmoothTerrain(...,3)` call (`generatemap.inc:587-592`); do **not** invent a
  kernel and do **not** change `relief()` amplitudes at `:75-85`.

**Acceptance:** plateau/hill/ravine transitions inside smooth-code regions
become rolling rather than banded; water/shore cells and start positions are
unchanged; the RCODE-FIX amplitudes remain verbatim. Lower leverage than Fixes
1–2 — it improves the *read* of relief, not its presence.

---

## 7. UNVERIFIED / BLOCKED — do not guess

1. **No donor GPU A/B frame exists.** Whether any of these changes matches the
   reference hue, silhouette, grain or luma is **UNVERIFIED**. **No parity claim.**
2. Donor engine sculpt blend (`Replace`/`ReplaceForWater`/`Smooth`, clamp and
   scale order, `−0.925` sign) has no plaintext consumer
   (`DPATTERN-01:348-382`, §9 Q2) — all stamp math stays **PORT APPROXIMATION**.
3. File-row → map-row sign is **UNVERIFIED** (`DPATTERN-01:120-124`); current
   code keeps file order (`S2:919-921`).
4. Donor stamp extent/placement is engine-side (`dogenerate.inc:1621-1765`,
   native `StandPattern`); using the scaled `st.cells` bbox is a port
   approximation (`RELIEF_LIVE_FIX_01:212-221`).
5. Full `w×h` float32 windows are **not in the port**; exporting them is a
   derived-data task, not a donor-binary copy (`DPATTERN-01:526-534`).
6. Mountain relief in the donor lives in `terrainmesh1..4` props, not a height
   grid (`DPATTERN-01:271-285,435-446`); the port has none. No prop work is
   proposed here.
7. `stats.relief_grid.applied` (consumer-side) is not in the `--dump-map`
   schema; only `meta.relief_grid.applied_cells` is measured
   (`RELIEF_SEED_PROBE_01:223-225`). Do not conflate them.
8. Visual attribution of the owner's exact frame remains inferred: the only
   real capture available (`RELIEF_VISUAL_01`) was a raw sidecar from a job that
   `failed` on a blank-detector false positive; no flag-off A/B exists.

---

## 8. Summary

- **Relief is generated** in the live path, but it is overwhelmingly
  port-analytic and geometrically tiny: ≤±2.964 m spread over footprints that
  scale with map size (`W/160`), with base R-code amplitudes now only
  +0.496/−0.558 after RCODE-FIX-01. This is the **primary** cause of the
  near-flat look (**CONFIRMED source; visual effect inferred**).
- **Not smooth normals** (**REFUTED**): the shader consumes `NORMAL` for
  donor Blinn-Phong; normals are near-uniform because heights are.
- **Camera/sun** (**CONTRIBUTING, not actionable**): shallow eye + high donor
  sun under-read few-degree slopes; both are already at donor-legal settings.
- **Missing markers** (**PARTIAL**): `plt2` is confirmed to fire at runtime
  (seed 20261150, `applied_cells=443`), so the flag is not the live blocker;
  but only 2 of 26 donor grids exist in the port.
- **Ravines/cliffs** (**CONFIRMED gap**): `k_ravine_1` is BLOCKED
  (RELIEF-02) *and* donor-disabled; the donor-active `ravine_big` family is
  placed by the port but has no decoded grid. Face-mode gates additionally
  cannot promote cliff art on the available gentle slopes.
- **Single highest-leverage change:** extend the live id-gated donor-grid
  stamp to the decoded donor-active families (especially `ravine_big`) using
  full derived numeric tables — no new producer decision, no synthetic shape.
- Three file-specific fixes are given in §6 (`game.gd`, `world3d_terrain.gd`,
  `mapgen.gd`). **PORT APPROXIMATION throughout; no donor parity claim.**
- This worker wrote only this report: no code, config, asset, test, shader,
  donor, queue or git edit; no Godot job.

*End of A05.*
