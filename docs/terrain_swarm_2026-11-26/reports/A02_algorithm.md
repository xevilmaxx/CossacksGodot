---
id: A02
ticket: TERRAIN-SWARM-2026-11-26 / Wave A / A02 (DESIGN ONLY — one report, no code)
title: "Donor-faithful generation algorithm — ordered stage pipeline for a fresh variant3d terrain module"
agent: "A02 (design subagent)"
created: 2026-11-26
status: DELIVERED__DESIGN_ONLY__ONE_REPORT__NO_CODE_EDIT__NO_RUNNER_JOB__NO_DONOR_BINARY
scope: "Exactly one repo file written: this report. No source, shader, config, asset, test, JSON, PNG, donor, queue or git edit; no Godot process or runner job."
owner_file: docs/terrain_swarm_2026-11-26/reports/A02_algorithm.md
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION"]
parity_guard: "No donor GPU A/B frame exists (CHARTER §2/§3). Every visual expectation is INFERRED/UNVERIFIED. Every substitute, per-stage key-derivation formula and blend implementation is PORT APPROXIMATION. NO DONOR PARITY CLAIM."
concurrent_reports_state: "When this worker first inspected docs/terrain_swarm_2026-11-26/reports/ it was empty; sibling A01/A03 reports landed during authoring. No D01–D08 or F01–F10 report was available to this worker at write time. All donor numbers below are cited from already-landed prior art (TERRAIN_DONOR_PIPELINE, DPATTERN_01, GUIDE4, RC_TERRAIN, 2026-11-25 reports), NOT from this wave's binary/data workers. COORD must re-check every [U] item in §8 against those reports before integration."
---

# A02 — Donor-faithful generation algorithm (stage pipeline + constants)

## 0. Mandate, label key and boundary

CHARTER §3 item 3 asks for a **fresh, donor-shaped pipeline** in `variant3d/`
composed by `world3d.gd`, reproducing the donor stage-for-stage
(mask → height → relief stamp → smooth → water/shore → tile ids → props/mines/fields).
This report specifies **only the algorithm**: stage order, exact inputs/outputs,
candidate constants, donor evidence, the port approximation each stage replaces,
and acceptance telemetry. It deliberately says **nothing** about which Godot
file owns which stage (A06) or how donor bytes become runtime assets (A03).

**Label key.** **[O]** observed — literal donor script line or decoded donor
literal quoted in a landed report. **[D]** derived — arithmetic/control-flow
consequence of observed lines. **[I]** inference without a pixel-aligned donor
A/B frame. **[U]** UNVERIFIED — not measurable with the instruments used.
Every port-authored selection rule is **PORT APPROXIMATION**. **No parity claim.**

**Donor file shorthand** (defined in `docs/audit/TERRAIN_DONOR_PIPELINE.md §1`,
all read-only at `C:\Games\Cossacks 3`):

| Id | Donor file | Lines |
|---|---|---|
| D1 | `data/scripts/common.inc/dogenerate.inc` | 2102 |
| D2 | `data/scripts/common.inc/generatemap.inc` | 1058 |
| D3 | `data/scripts/common.inc/initmapgen.inc` | 288 |
| D4 | `data/scripts/common.inc/texturemap.inc` | 962 |
| D5 | `data/scripts/common.inc/smoothtiles.inc` | 245 |
| D6 | `data/scripts/common.inc/smoothforestborders.inc` | 170 |
| D7 | `data/scripts/common.inc/postprocess.inc` | 465 |
| D8 | `data/game/var/generator.cfg` | 2366 |
| D9 | `data/scripts/lib/misc.script` | 6765 |
| PL | `data/pattern/pattern.lib` (decoded fields) | DPATTERN_01 |

Evidence ids `C1…C28` below are the claim ids of
`docs/audit/TERRAIN_DONOR_PIPELINE.md §4` (landed 2026-11-21).
Evidence ids `S-25-09`, `Z04`, `G07` refer to the named 2026-11-25 reports.

---

## 1. Executive summary

1. **[O] The donor has a canonical stage order** — `DoGenerate` (D1) calls, in
   order: init/seed (D3) → clear (D1:444–481) → base tiled patterns
   (D1:1530–1536) → settings branch (D1:1542–1565) → `GenerateMap` mask/height/
   water/forest/texture/tile-smooth (D2) → shore exclusion mask (D1:1568–1581)
   → starts + border keep-clear (D1:1586–1616) → relief pattern passes
   (D1:1621–1770) → forest/stone/decor passes (D1:1774–1907) → units + scale
   (D1:1914–2027) → `FillOwnerMap` (D1:2062) → border objects (D1:2064–2065)
   → finalize (D1:2068–2100). The 11-stage pipeline in §4 is this order with
   the texture/tile-smooth sub-stages of D2 split out explicitly. This is the
   **single most important finding**: the port's current order is different
   (analytic domes + fixed noise + post-collision height writes), which is why
   prior waves produced concentric rings and flat relief.
2. **[O] Determinism is per-stage re-seeding, not one continuous RNG stream.**
   `SetRandomKey(randkey1)` is called at D3:99 and D3:146, and D1 re-seeds before
   each stamp family (D1:1538, :1616, :1772, :1909, :1927). The port seeds once
   (`game.gd:152`). A fresh module must expose a stage-keyed stream ledger;
   the exact donor key-derivation function is **[U]** (no plaintext consumer),
   so the derivation formula is **PORT APPROXIMATION**.
3. **[O] Relief is stamped, not synthesized.** The unit of generation is a
   `.pattern` with a height grid + object list + footprint; height uses the
   donor code→class amplitude map (`cPlateauHeight=2.964`, `cHillHeight=1.31733…`,
   `cRavineHeight=−2.964`, `cWaterHeight=−1.1`, R multiplier `3.5` —
   D2:4–7, :567–574), and stamping is rejection sampling against an occupancy
   grid `_misc_CheckStandPattern(Ext)` (D9:3384–3521). The port's 8×10 block-mean
   grids (`G07 §3`, `DPATTERN_01 Appendix A`) and analytic domes
   (`game.gd:638–657`) are the approximations replaced.
4. **[O] Blend modes are config flags with UNVERIFIED engine math.**
   `HeightFieldStand/Scale/Min/Max/Replace/ReplaceForWater/Smooth` occur only in
   `pattern.lib` (9,520 hits, no plaintext consumer — DPATTERN_01:366–370);
   `HeightFieldReplace=False` 680/680, `ReplaceForWater=True` 85/680,
   `Smooth=True` 41/680. Any implementation must read those flags from decoded
   data and use the labelled approximation (DPATTERN_01:373–378). No invented
   constant, no `HEIGHT_SCALE` fudge.
5. **[O] Two distinct water constants** must stay distinct: `−1.1` (height
   depth term, D2:7) and `−0.25` / `−0.1` (classification/shore, D4:30–31).
   Coastal smoothing is gated by **mask B + height band**, not by a height
   threshold (C4) — the port's `mapgen.gd:179–196` is wrong here.
6. **[O] Resources are clustered per player side** as a consequence of
   rejection-sampled multi-object patterns and 3 keep-clear ellipses per start
   (C1 5×7, C2 12×15, C3 22×18 — D1:407–414), plus `FillOwnerMap` BFS
   (D1:1370–1428). Mines are indexed **by round, not by resource kind** (C10),
   and C3 is a keep-clear zone, not a placement region (C18). Uniform scatter
   is explicitly forbidden.
7. **[U] No donor GPU A/B frame.** All visual acceptance below is telemetry and
   "readable landscape class", **not** donor parity.

---

## 2. Evidence table

| Id | Claim (label) | Donor evidence | What it pins in this design |
|---|---|---|---|
| E01 | Seed pair `randkey1/2`, `SetRandomKey` (O) | D3:99, :146; `TERRAIN_GEN_RESEARCH.md:17–18` | Stage 0 inputs |
| E02 | Re-seed before each stage (O) | D1:1538, :1616, :1772, :1909, :1927; `TERRAIN_DONOR_PIPELINE.md:67` | Stage 0 stream discipline |
| E03 | Clear mask + objects + collision (O) | D1:444–481 | Stage 2 pre-state |
| E04 | Mask folder by TerrainType (O) | D8:2–28; D1:1542–1565 | Stage 1 shape selection |
| E05 | Mask pick `floor(RandomExt*count)` (O) | D2:139–208, :216, :285–503 | Stage 1 selection rule |
| E06 | R/G/B channel codes (O) | D2:21–32; D4:16–27; C1/C3 | Stage 2 decode table |
| E07 | Height formula + constants (O) | D2:4–7, :567–574; C1 | Stage 2 height |
| E08 | R smooth codes + wrong-sign port bug (O/D) | D2:24–27, :352–370; port `mapgen.gd:51–61`; C3 | Stage 2 must use class×R, not `relief()` |
| E09 | Height smoothing passes (O) | D2:587–592, :606, :611–640, :238–242; C4/C5 | Stage 3 exact params |
| E10 | Coastal gate = mask B + height band (O) | D2:611–640; C4 | Stage 5, replaces port threshold gate |
| E11 | Water fields from mask B (O) | D2:646–709 | Stage 5 water mesh flag |
| E12 | Tile smoothing 3 passes, probability tables (O) | D5:4–6, :84–187, :237; C23 | Stage 6 |
| E13 | Tiled patterns 25-unit grid, inclusive (O/D) | D1:1330–1359, :1335–1345; C8/C9 | Stage 4 base grid, replaces 120-unit |
| E14 | Rejection test + atomic Ext (O) | D9:3384–3521; C12 | Stage 4/7 stand rule |
| E15 | Occupancy prefill layers (O) | D2:311–495; D1:1568–1581, :1613; C13 | Stage 4/7 keep-clear |
| E16 | Freq damping ×0.2, floor 1e-4 (O) | D9:3588–3630; C14 | Stage 4/7 variety |
| E17 | `needed=floor(W*H*freq)`, `trycount=256*(320²)/(W*H)` (O/D) | D9:3686–3704; C15 | Stage 4/7 attempt budget |
| E18 | Free-mask modifiers measured (O) | D9:3896–3897, :3931–3941; C16 | Stage 4/7 density calibration |
| E19 | Relief frequency table relieftype 0–4 (O) | D1:1625–1649, :1757–1765; §3.5 | Stage 4 hill/mountain family counts |
| E20 | Mine radii by round + version/size gate (O) | D1:525, :528–534, :594–645; C10/C11 | Stage 7 mine placement |
| E21 | `SetupStartingResources` 7-step order (O) | D1:720–980, :732–769…:947; C17/C18 | Stage 7 guaranteed rings |
| E22 | Keep-clear ellipses C1/C2/C3 (O) | D1:407–414; §3.4 | Stage 7 zones |
| E23 | `FillOwnerMap` 4-neighbour BFS (O) | D1:1370–1428, :2062; C19 | Stage 8 |
| E24 | Border objects peace-mode only, are markers (O) | D1:1430–1527, :2059–2065; C20 | Stage 8 (corrects TERRAIN_GEN_RESEARCH:54–57) |
| E25 | Pattern-lib height blend flags; math UNVERIFIED (O/U) | PL; DPATTERN_01:354–382, :544–545 | Stage 4 blend modes |
| E26 | Scale jitter + winter leaftree delete (O) | D1:1914–2027, :1984–1985, :1975–1982 | Stage 10 props |
| E27 | Season colour tables 6/7/0 (O) | D1:2075–2084; D4:525–526, :605–606, :639–640 | Stage 10 season |
| E28 | Field decals `envfieldd`, food rects (O) | GUIDE4:2029; `TERRAIN_GEN_RESEARCH.md:75`; D1:720–980 | Stage 9 mill-field decoration |
| E29 | Rejected hacks (O) | Z04 §7; S-25-09; G07 §7; `CHARTER.md:84` | §3 forbid list |
| E30 | Port approximations being replaced (O) | G07 §3.1; Z04 §1–2; `TERRAIN_DONOR_PIPELINE.md C1–C28` | Per-stage "replaces" column |

**Not used as evidence:** this wave's D0*/F0* reports (not landed — see
frontmatter); the truncated S11 patch-note multipliers (`RC_TERRAIN.md:226`);
R1–R6 numeric ranges (`C27` UNVERIFIED); the discarded Steam id 1599319598
(`RC_TERRAIN.md:44–45`).

---

## 3. Explicitly forbidden — known-rejected hacks (binding)

These are **not** stage options. A fresh variant3d module MUST NOT contain any
of them; each is rejected by landed evidence, not by taste.

| # | Forbidden hack | Evidence | Why rejected |
|---|---|---|---|
| F1 | **Synthetic dither/noise field** added to relief or height | `CHARTER.md:84` (decision S-25-09); Z04 §7; G07 §7 #7 | Prior wave's terracing/rings; "no synthetic noise/dither field". The existing `game.gd:1248–1252` 0.03 dither is **not** extended; donor-grid cells must skip it. |
| F2 | **Face promotion** to force cliff/rock art | B04 (reverted), Z04 §7; Z04 Part C does the *opposite* guard | No `_relief_face_at()`, no span-scaled `cDiff` (`span*0.03`, floor 0.05), no absolute-height promoter (`|h|>2.4/>2.7`). Art promotion is a GUARD only: return face 0 on producer-stamped cells. |
| F3 | **`HEIGHT_SCALE` fudge / amplitude multiplier** | Z02 §2 "Rejected"; Z04 §7 | `HEIGHT_SCALE=1.0` is donor geometry; multiplying desyncs `height_at_world()`, resource Y, water gate and re-triggers baseline face gates. No invented visual constant. |
| F4 | **Tile-art relief** — relief writing `terrain=5` / rock/cliff tile ids | H03/H05/Y02; Z04 §7 | Put the maze rings on screen; relief owns HEIGHT only, `blocked[]` owns walkability. |
| F5 | **Uniform Poisson/random scatter** replacing stamped clumps | `TERRAIN_GEN_RESEARCH.md:66–69`; C17 | "Always clustered" is a direct consequence of multi-object patterns; uniform scatter is not donor-shaped. |
| F6 | **One continuous RNG stream** seeded once | E02 | Donor re-seeds before each stage; a single stream desyncs all later stages if any stage changes count. |
| F7 | **Port `relief()` / height-threshold coastal gate** | C3, C4; `TERRAIN_DONOR_PIPELINE.md §5.1–5.2` | Wrong sign for R=88, spurious bump at R=64; coastal gate must be mask-B + height band. |
| F8 | **Teaching resources with CIRCLE3 as a placement region** | C18 | C3 is filled into `gPatternMask` as keep-clear; the placement block is commented out (D1:949–977). |
| F9 | **Rocks/trees as border objects** | C20 | `SetupBorderObjects` is peace-mode-only and places invisible `ptborder`/`ptborderwater` markers. |
| F10 | **Porting `postprocess.inc` Gaussian into skirmish** | C6 | Runs only when `not bRandomMap`; shipped masks are already blurred. |
| F11 | **Inventing donor constants for R1–R6** | C27 UNVERIFIED | No donor numeric source exists in the script tree. |
| F12 | **Seeding family weights from hand-written lists** | C26, E16 | `generator.cfg` weights are parsed data; static `pick` (`pattern_gen.gd:104–123`) is non-donor. |

---

## 4. Stage pipeline — ordered, with exact inputs/outputs

**Global data contract (fresh module, PORT APPROXIMATION shape):**

```
Input  cfg        : {seed:{randkey1,randkey2}, season, shape, relief_type,
                     terrain_type, minerals, size, teams, player_count}
Input  donor_data  : {masks:<shape>/<N>pl_*.tga derived RGBA + manifest,
                     pattern_lib:<decoded records>, generator_cfg:<parsed Freq>,
                     tilesmooth:<parsed compat tables>, atlas:<tile id table>}
State  gPatternMask: byte[W*H]      # occupancy: 1 = banned for stamping
State  height      : float[W*H]
State  water       : byte[W*H]      # mask-B water mesh flag
State  terrain     : byte[W*H]      # 6 ids only (GUIDE4:311 — never add id 6)
State  tile_id     : byte[W*H]
State  owner/dist  : int[W*H]        # from BFS
State  objects     : list[{kind,pattern,x,y,scale,footprint}]
State  gen_trace   : dict           # accumulator; telemetry only, never feeds generation
Output map_bundle  : {height,terrain,tile_id,water,owner,starts,objects,gen_trace}
```

Every stage writes `gen_trace[<stage>]` with `{inputs_hash, outputs_hash,
rng_key_id, attempt_count, accept_count, reject_reason_hist, elapsed_us}`.
`inputs_hash` = deterministic hash of the stage's read-only inputs; this is the
replay instrument (A05), not a generation input.

### Stage 0 — Seed / keys → RNG stream discipline

- **Donor evidence:** E01/E02 [O]; `InitMapGen` D3:4–19, :99, :146, :232–239.
- **Inputs:** `cfg.seed.{randkey1,randkey2}` (64-bit pair); stage ordinal.
- **Output:** `rng_stream[stage]` — one independent deterministic stream per
  stage, plus `gen_trace.seed`.
- **Labels:** stream *discipline* [O]; key-derivation formula **[U] / PORT
  APPROXIMATION** (no plaintext consumer for the key-mixing function).

```python
# PORT APPROXIMATION — donor key derivation UNVERIFIED; discipline is [O].
def make_streams(randkey1, randkey2, stage_ids):
    return {sid: RNG(mix64(randkey1, randkey2, stable_hash(sid)))
            for sid in stage_ids}
# mix64 is a label-only placeholder: DO NOT claim it is donor RandomExt.
# Call sites that MUST re-seed (E02): stage 4 base tiles, stage 4 relief,
# stage 7 forest/stone, stage 7 mines, stage 10 units/scale.
```

- **Replaces:** port `game.gd:152` single `rng.seed = Data.RANDOM_SEED`
  (G07/Z04 baseline) — the reason adding one stamp shifted every later stage.
- **Acceptance telemetry:** `same_seed_byte_identical` across two runs; a
  per-stage `stream_id` ledger with 5 distinct ids; replaying only stage 7
  leaves stages 0–4 byte-identical. No parity claim.

### Stage 1 — Choose mask by shape + seed

- **Donor evidence:** E04/E05 [O]; D8:2–28, D1:1542–1565, D2:139–208, :216,
  :285–503. Out-of-range relief/terrain type → `floor(RandomExt*6)` /
  `*gc_MaxTerrainTypeCount` (D1:1542–1565; value of `gc_MaxTerrainTypeCount`
  **[U]** — `TERRAIN_DONOR_PIPELINE.md §6.2`).
- **Inputs:** `cfg.shape`, `cfg.player_count`, `rng_stream[mask]`.
- **Output:** chosen mask path/name (recorded back to the record manager,
  D2:216) + channel images `{R,G,B,alpha}` + pure-white start markers.
- **Candidate constants:** per-shape mask counts `continent 121, continents 187,
  islands 320, land 230, med 122, nowater 42, nowater2 33, peninsulas 280`
  (**[I]** — "almanac recon" inherited from GUIDE4 A09; `RC_TERRAIN.md:223–224`
  explicitly says not independently re-verified; **F04 must confirm**). EMOM
  adds 151 lake / 57 coastal / 157 river / 100 med (`RC_TERRAIN.md:73`, source
  S7). `bDesert := season==3` (D1:4).
- **Labels:** selection rule [O]; counts [I]/UNVERIFIED until F04 lands.

```python
files = manifest[shape][player_count]        # sorted, donor order preserved
idx   = floor(streams["mask"].next() * len(files))
mask  = load_derived_rgba(files[idx])
trace["stage1"] = {"mask": files[idx], "count": len(files),
                   "selection": "floor(RandomExt*count)"}
```

- **Replaces:** port `mapgen.gd:39–49,63–84` (mask pick exists but uses
  farthest-pair starts, E05/C3 note).
- **Acceptance telemetry:** chosen mask name recorded; count matches manifest;
  same seed + same manifest ⇒ same mask byte-for-byte; no mask file is a donor
  binary (derived assets only, CHARTER §3 item 2).

### Stage 2 — Decode R/G/B mask → height / forest / water

- **Donor evidence:** E06/E07/E08 [O]; D2:21–32, :352–370, :454–472,
  :567–574; constants D2:4–7; C1/C3 (port delta).
- **Inputs:** `mask.R/G/B/alpha`, stage-0 streams.
- **Output:** `height[]` (base term), `forest_class[]`, `water_mask[]`,
  `broad[]` (alpha/road), `bsmooth[]`, `starts[]`, `terrain[]` initial class.
- **Exact donor constants [O]:**

| Field | Value | Source |
|---|---|---|
| `cPlateauHeight` | `2.964` | D2:4 |
| `cHillHeight` | `2.964/2.25 = 1.31733…` | D2:5 |
| `cRavineHeight` | `−2.964` | D2:6 |
| `cWaterHeight` (height term) | `−1.1` | D2:7 |
| water R multiplier | `3.5` | D2:567 |
| R plateau / hill / ravine | `255 / 96 / 48` | D2:21–23 |
| R smooth "none" | `128 div 2 = 64` | D2:24 |
| R plateau/hill/ravine **smooth** | `191 / 112 / 88` | D2:25–27 |
| G forest / genforest / stone / foreststone | `255 / 64 / 128 / 192` | D2:28–31; G=127 special at :373–377 |
| B water | `255` | D2:32 |
| max height | `2.96` | D4:29 |
| collision gates `cDiff1/cDiff2` | `0.5 / 0.55` | D4:63–64 |

```python
# [O] exact code→class→amplitude; NO port relief() approximation (C3).
def relief_amp(r):
    if r in (255, 191): return  cPlateauHeight * r/255   # +2.964 max
    if r in ( 96, 112): return  cHillHeight   * r/255   # +1.317 max
    if r in ( 48,  88): return  cRavineHeight * r/255   # NEGATIVE; R=88=-1.023
    if r == 64:         return  0.0                      # bsmooth=True, no relief
    return 0.0  # UNVERIFIED codes: leave 0, record in trace; do not invent

def decode(mask):
    for i in cells:
        r,g,b,a = mask[i]
        hwater   = -1.1 * (b/255) * (1 + (r/255)*3.5)     # D2:567–574
        hterr    = relief_amp(r)
        if pure_white(r,g,b):                            # D2:565–566
            starts.append(i); height[i] = hwater; continue
        height[i] = hwater + hterr
        forest_class[i] = decode_g(g, r)                 # D2:371–383
        water_mask[i]   = (b == 255)                     # D2:646–709
        broad[i]        = (a > 0)                        # mask alpha/road
        bsmooth[i]      = (r == 64)
```

- **Replaces:** port `mapgen.gd:51–61` `relief()` (wrong sign at R=88, spurious
  bump at R=64 — C3) and `mapgen.gd:148–176` RGB-averaging decode
  (`TERRAIN_DONOR_PIPELINE.md C3`).
- **Acceptance telemetry:** unit test over R∈{48,64,88,96,112,191,255} yields
  `−2.964 / 0.000 / −1.023 / +1.317 / +0.578 / +2.220 / +2.964` (±0.001,
  B=0) per `§5.1` of the pipeline report; `starts_count == player_count`;
  `height_min/max` recorded; `unknown_r_codes` histogram empty or explained.

### Stage 3 — Relief smoothing passes

- **Donor evidence:** E09 [O]; D2:587–592, :606, :238–242; C5.
- **Inputs:** `height[]`, `bsmooth[]`, `forest_class[]`, stage streams.
- **Output:** `height[]` smoothed; **no** terrain/tile write.
- **Exact donor params [O]:**

| Pass | Scope | Params | Source |
|---|---|---|---|
| a | cells with `bsmooth` | `SmoothTerrain(x,−y,False,3)` — 3 neighbour passes | D2:587–592 |
| b | whole land map (h≥0.01) | `times=1, power=4, lerp=0.5, minh=0.01, maxh=100` | D2:606 |
| helper | — | `res = h + (((lt+rt)/2 + (lb+rb)/2)/2 − h)/power; res = Lerp(h,res,lerp)` | D2:238–242 |

```python
def smooth_cell(h, lt, rt, lb, rb, power, lerp):
    res = h + (((lt+rt)/2 + (lb+rb)/2)/2 - h)/power
    return lerp_f(h, res, lerp)
# a) for i where bsmooth[i]: repeat 3×: height[i] = smooth_cell(... power=?, lerp=?)
# b) for i where height[i] >= 0.01: once with power=4, lerp=0.5
```

- **[U]** `SmoothTerrain`'s internal `power`/`lerp` for pass (a) is not in the
  plaintext scripts (helper signature only). Use the whole-map `power=4,
  lerp=0.5` as an explicitly labelled **PORT APPROXIMATION** default and record
  it as such; do **not** claim it is a donor literal.
- **Replaces:** port `mapgen.gd:179–196` (3 passes but wrong gate — see Stage 5)
  and the absence of any global land pass (C5).
- **Acceptance telemetry:** `pass_a_cells`, `pass_b_cells`, `before/after height
  hash`, `max_abs_delta`; assert no cell with `height<0.01` modified by pass (b);
  exactly 3 passes on pass (a) at all quality levels (or record the documented
  divergence — no silent quality downgrade).

### Stage 4 — Pattern stamping from `pattern.lib` families with donor blend modes

This is the heart of the donor algorithm. It runs **three sub-passes** in donor
order: (4a) base tiled patterns, (4b) relief families, (4c) forest/stone/decor
families. Mines and guaranteed start rings are Stage 7.

#### 4a. Base tiled patterns

- **Donor evidence:** E13 [O]; D1:1330–1359, :1335–1345; C8/C9.
- **Inputs:** `gPatternMask` (prefilled by Stage 4d), `pattern_lib` `tiles`
  family (`d_tls_1..4`, D8:781), stream `tiles`.
- **Output:** base "cracked earth" footprint stamps in `objects[]` + occupancy.
- **Constants [O]:** `cSize=25`; `wcount=floor(W/25)`, `hcount=floor(H/25)`;
  loops `0..wcount` **inclusive** → `13×13=169` cells at W=320, `7×7=49` at
  W=160; centre `round(x*25+12−W/2−1)`; one `CheckStandPattern` +
  `PatternIncreaseFreq` per cell. `SetupTiles(freq)` = 64 attempts, names
  `tls_1..4` skipping `tls_3`, is **dead** (call commented at D1:1593) — do not
  implement it as live.
- **Replaces:** port `pattern_gen.gd:180–201` `tile_step=max(6,60*s)=120` at
  s=2 (≈3× sparser, wrong centring).

#### 4b. Relief families (hills / mountains / ravines / plateaus)

- **Donor evidence:** E19 [O]; D1:1621–1770, :1625–1649, :1757–1765; §3.5.
- **Inputs:** `cfg.relief_type` → relieftype 0..4; `problarge`; `gPatternMask`.
- **Output:** height stamps + relief props; family counts in telemetry.
- **Exact donor frequency table [O]** (`freq` per family, multiplied by
  `problarge`):

| relieftype | plt | mnt | hil | Source |
|---|---|---|---|---|
| 0 | 0.000010 | 0.000020 | 0.000075 | D1:1625–1629 |
| 1 | 0.000020 | 0.000002 | 0.000125 | D1:1630–1634 |
| 2 | 0.000075 | 0.000075 | 0.000030 | D1:1635–1639 |
| 3 | 0.000055 | 0.000120 | 0.000050 | D1:1640–1644 |
| 4 | 0.000090 | 0.000035 | 0.000035 | D1:1645–1649 |

  Distribution [O]: `mountains=mnt`; `plateau_big=plt/3`; `plain_huge=pln_huge`;
  `ravine_big=plt/1.5`; `plateau=plt/3`; `plateau_small=plt/3`;
  `hills_dark=hil/2`; `hills_light=hil/2` (D1:1757–1765).
  Desert uses `desert_*` equivalents (D1:1747–1754). `relieftype>4 →
  floor(RandomExt*5)` (D1:1621). `plain` stamping disabled (D1:1801),
  `ravine_medium` disabled / `//`-commented (D1:1760; DPATTERN_01:341–346) —
  **do not** add a `ravine_medium`/`k_ravine_1` producer (G07 §2.2).
- **Family contents [O]:** `mountains` = `g_mnt_1..7` (7, D8:660);
  `hills_dark` = `hil1..4` (4, D8:693); `hills_light` = `g_hil1..9` (9,
  D8:714); `plateau*` 5/6/5 (D8:581/606/635); `ravine_big` 8 (D8:503).
- **Blend modes (donor flags, E25):** `HeightFieldStand`, `HeightFieldScale`,
  `HeightFieldMin/Max`, `HeightFieldOffset`, `HeightFieldSmooth`,
  `HeightFieldReplace`, `HeightFieldReplaceForWater`, `HeightFieldUseRndScale`,
  `TerrainScale`, `CollisionStand`, `ObjectsScale` (PL; DPATTERN_01:354–364).
  Observed values: `Replace=False` 680/680; `ReplaceForWater=True` 85/680;
  `Smooth=True` 41/680 (radius 2/3, factor 4, offset 0/2);
  `HeightFieldScale ∈ {1(669), −0.925(4), +0.925(3), 1.175, 0.8, 1.5, 0.65}`;
  `TerrainScale=1` 680/680; `HeightFieldOffset=0` in all audited sections;
  `CollisionStand=True` 625/680.
- **Engine blend math [U] / PORT APPROXIMATION** (DPATTERN_01:366–378):

```python
# PORT APPROXIMATION — engine blend UNVERIFIED (no plaintext consumer).
def stamp_height(h_base, grid, meta, water_here):
    if not meta["HeightFieldStand"]: return h_base
    if meta["HeightFieldReplace"] or (meta["HeightFieldReplaceForWater"] and water_here):
        h_final = meta["HeightFieldMin"] + 0.0   # placeholder: REPLACE target UNVERIFIED
    else:
        h_final = h_base*meta["TerrainScale"] \
                + grid[v*w+u]*meta["HeightFieldScale"] + meta["HeightFieldOffset"]
    h_final = clamp(h_final, meta["HeightFieldMin"], meta["HeightFieldMax"])
    if meta["HeightFieldSmooth"]: h_final = local_smooth(h_final, meta)  # definition UNVERIFIED
    return h_final
```

  **Critical:** do not collapse this to a single additive formula. The flags
  must be carried per pattern; the *operation* is what is UNVERIFIED.
  `HeightFieldMin/Max` equal the decoded grid min/max exactly for all 26 audited
  patterns (DPATTERN_01:380–382) — safe to export from `pattern.lib`.

#### 4c. Forest / stone / decor families

- **Donor evidence:** D1:1774–1907; §3.5 global freqs; C7 (vanilla forces
  `foreststype=0`).
- **Constants [O]:** `frs_big=0.0009`, `frs_mid=0.0009`, `frs_small=0.00054`,
  `stn1=0.00016`, `stn2=0.00012` (D1:1688–1693); size modifiers
  `pln_small=plain*6*probsmall`, `pln_mid=plain*2*probmid`,
  `pln_large=plain*problarge`, `pln_huge=plain*probhuge`; swamp by same
  factors; `lake_big/lake_small` **hard-zeroed** (D1:1735–1736, :1902–1903);
  `pump`/`christmas` event-gated (D1:1848–1851). `foreststype` drawn then
  **forced to 0** in vanilla (D1:5–6; C7) → only pine/fir/spruce families are
  vanilla-correct; port's mixed/leaf recipes (`pattern_gen.gd:243,255`) are
  non-vanilla and must be gated, not default.
- **Placement budget (E17/E18) [O/D]:** `needed=floor(W*H*freq)` (round to 1 if
  `freq>0` but floor=0); `trycount=floor(256*(320²)/(W*H))`, and if `<1`, multiply
  by `0.65` (D9:3686–3704); size modifier `640/((W+H)/2)` when W≠640 or H≠640
  (D1:1718–1725); free-mask probabilities from 32,000 random probes ×4,
  `cSmall=340, cMid=182, cLarge=74, cHuge=55` (D9:3896–3897, :3931–3941).

#### 4d. Occupancy prefill + stand + weight damping (shared by 4/7)

- **Donor evidence:** E14/E15/E16 [O]; D9:3384–3521, :3588–3630; C12/C13/C14.
- **Prefill `gPatternMask` before ANY stamping [O]:** mask water B>0;
  all shore `height<−0.1` (D1:1568–1581); G forest/stone codes (D2:371–383);
  R smooth codes (`bsmooth`); `broad`/alpha roads; collision/blocked tiles;
  map border 3 (D1:1613); C1 ellipse; C3 as **keep-clear** (C18).
- **Stand rule [O]:** a pattern stands iff every stand-cell of its own footprint
  is in bounds and `gPatternMask` is false; `Ext` = test-then-stand atomically;
  fast path samples every 4th cell when angle=0 (D9:3441, :3475–3501,
  :3516–3521).
- **Weighted pick + damping [O]:** roulette over `FreqSum` (D9:3634–3653);
  after each success `newfreq = oldfreq*0.2`, floor `0.0001`, update `FreqSum`
  and `UsedCount/TotalCount` (D9:3590, :3615–3624). Seed weights from **parsed**
  `generator.cfg` (§3.6 counts/sums), never from a hand-written list (C26).

```python
for family, freq in stage4_families.items():
    needed  = max(1, floor(W*H*freq)) if freq > 0 else 0
    for n in range(needed):
        name = roulette(family.FreqSum)                 # D9:3634–3653
        pat  = pattern_lib[name]
        for attempt in range(trycount(family)):
            x, y, angle = proposal(streams[family])
            if _misc_CheckStandPattern_Ext(pat, x, y, angle, gPatternMask):
                stand(pat, x, y, angle)                 # writes height/objects/occupancy
                family.freq[name] = max(1e-4, family.freq[name]*0.2)
                break
        else:
            trace["stage4"].reject_reason_hist["no_free_footprint"] += 1
```

- **Replaces:** port `pattern_gen.gd:13` (`MINE_RINGS` pre-77), `:104–123`
  static `pick`, `:85–95` `can_stand` with under-populated occupancy,
  `:1906` invented 7-recipe list, and `game.gd:638–657` analytic domes; the
  8×10 block-mean relief grids (`G07 §3`, `DPATTERN_01 Appendix A`, label
  "debug/preview aids only") remain **PORT APPROXIMATION** and are only a
  fallback until full `w×h` grids are decoded (A03/F01).
- **Acceptance telemetry:** per-family `{needed, placed, rejected,
  freq_after}`, occupancy overlap count (target 0), `never a single member
  >25%` over 1,000 `forests_pine_big` stamps (pipeline §5.6), no stamp into
  prefill layers, `lake_*` stamp count == 0, `k_ravine_1` count == 0,
  `mixed/leaf` count == 0 unless explicit forest-type option (C7).

### Stage 5 — Water/shore classification + smoothing

- **Donor evidence:** E10/E11 [O]; D4:29–31, :30–31, :68–75; D2:611–640,
  :646–709; C2/C4.
- **Inputs:** `height[]` (post Stage 3), `water_mask[]` (mask B), stage streams.
- **Output:** `water[]` mesh flag, `shore[]` band, final `height[]` at coast.
- **Constants [O]:** `cWaterHeight` classification `−0.25` (D4:30);
  `cWaterShoreHeight` `−0.1` (D4:31; D1:1576 — also the Stage 4d occupancy
  gate); `cMaxHeight` `2.96` (D4:29). **Keep these distinct from the `−1.1`
  height-term constant in Stage 2** (C2).
- **Water mesh flag [O]:** `cWaterFieldSize=2`, grid `640/2`; a 2×2 cell is
  water iff any pixel has `B>0 and (R<1 or B<1)`; `WaterFieldAdd(...,
  cOffsetY=−0.5)` (D2:646–709). Donor water flag is from **mask B**, not from
  the height test (height test is collision/tile art only, D4).
- **Coastal smoothing [O]:** **3 passes**, radius `rad=2`, applied only to cells
  whose own **or a neighbour's mask-B is water** AND whose height is in
  `[−100, −0.01]`, with `power=0.35, lerp=0.5` (D2:611–640, call :637, helper
  :238–242).

```python
for p in range(3):                                   # D2:637 ×3
    for i in cells:
        if not (-100 <= height[i] <= -0.01): continue
        if not (water_mask[i] or any(water_mask[n] for n in neigh(i, rad=2))):
            continue
        height[i] = smooth_cell(height[i], *neigh4_avg(i), power=0.35, lerp=0.5)
    # classify AFTER smoothing:
water[i] = water_flag_from_maskB(i)                  # D2:646–709
shore[i] = height[i] < -0.1                          # D4:31 / D1:1576
deep[i]  = height[i] < -0.25                         # D4:30
```

- **Replaces:** port `mapgen.gd:86–110,179–196` `_near_water` (height<0.8 /
  <−0.1 and smooths **all** near-water cells — C4), and port deriving water
  mesh from `height<−0.25`.
- **Acceptance telemetry:** `cells_modified_coastal` all satisfy the mask-B/height-band
  gate (target: 0 violations); `pass_count==3` at every quality; `water_pct`
  vs mask B within ±5 pp; `sand_ring>=90` (scan_map target); no cell with
  `height>−0.01` touched by coastal pass.

### Stage 6 — Tile smoothing/detail pass → tile ids

- **Donor evidence:** E12 [O]; D5:4–6, :63–80, :84–187, :191–235, :237; C23.
  Shore/height tile thresholds are in D4:474–529 (8 sectors, `cAngle=45°`,
  `sandsea1/5/6`) and D4:594–601 (`abs(h)>2.7 → rock8`; `>2.4 → rock4`;
  `abs(h)<0.1 → no tile`). Roads: `ground1` p=0.5, `test2` p=0.25, `test3`
  p=0.25, applied only where mask alpha/`broad` set (D4:627–636; GUIDE4:934–935).
- **Inputs:** `terrain[]`, `height[]`, `water[]`, `broad[]`, `tilesmooth` compat
  tables, stage streams.
- **Output:** `tile_id[]` (atlas cell ids; **6 terrain ids only**, GUIDE4:311).
- **Constants [O]:** `SmoothTileMap(0,0,W,H,3)` — **3 passes**, horizontal then
  vertical per pass; 64 probability tables loaded from `tilesmooth_scripts.cfg`;
  `GetNeighbourTiles` compatibility resolution. **[U]** the actual
  compatibility lists/weights (`TileNames`/`Prob`, D5:44–57) were **not read**
  (`TERRAIN_DONOR_PIPELINE.md §6.4`) — **F03/F05 must supply**; until then use a
  labelled **PORT APPROXIMATION** compatibility table and record it as such.
- **Replaces:** port `game.gd:1011 _assign_tileblocks` (no compatibility pass).
- **Acceptance telemetry:** `incompatible_adjacent_pairs` before/after (target
  0 after passes for a fixed dump); identical between two identical seeds;
  road-tile cells coincide with mask-alpha cells (Jaccard ≥0.95 per pipeline
  §5.12); `tileflow>=99` (scan_map); `app/` byte-untouched.

### Stage 7 — Resource / mine / stone / forest placement with keep-clear zones

- **Donor evidence:** E20/E21/E22 [O]; D1:407–414, :522–717, :720–980,
  :1430–1527; C10/C11/C17/C18.
- **Inputs:** `starts[]`, `gPatternMask` (with Stage 4d prefill), `cfg.minerals`
  (0–3; `>2 → floor(RandomExt*3)`, D1:1586–1590), stream `resources`.
- **Output:** `objects[]` deposits/stone/forest/food; per-start guaranteed rings.
- **Keep-clear zones [O]:** C1 `5×7`, C2 `12×15`, C3 `22×18` (D1:407–414);
  map border `r=3` (D1:1613); shore `height<−0.1` (D1:1568–1581). **C3 is
  keep-clear only** — its placement block is commented out (D1:949–977, C18).
- **Mines [O]:** `trycount=256` (D1:525); `rounds = 3/4/5` for density `0/1/2`,
  clamped by `maxround` (D1:528–534); **loop nesting is `for i` rounds → `for j`
  restypes → one `mng`, one `mni`, one `mnc` per round** (D1:535–551, :704–713)
  — radius depends on **round**, not resource kind (C10). Version≥80 radii
  (current branch, **inferred** — `gRecordGeneratorVersion` value [U],
  pipeline §6.1): small map ≤4 players `round0 14+8r`, `round1 32+10r`,
  `round2 unassigned`, `round3 70+12r`, `round4 22+16r`, `round5 continue`;
  large map `round0 14+8r`, `round1 32+10r`, `round2 70+12r`, `round3 22+16r`,
  `round4 continue`. `VectorRotateY` puts it on a ring around the start.
  `mng/mni/mnc` 6 patterns each (one legacy `Freq=0`), sum Freq 5 each
  (D8:69/98/127, §3.6).
- **Guaranteed starting resources — exact 7-step order [O]** (D1:732–769,
  :771–805, :807–861, :863–945, :947; C17): 1 stoneforest (C1 ring) → fill C2
  → 1 stones → 2 medium/big forest stamps → 1 stones at C2+4 → 1 more forest
  → fill C3 (keep-clear). `trycount=128`, `trycount2=3`, `smalltry=4`;
  distance `mindst + RandomExt*3 + ((i+j)*0.5)`; stone ring at `mindst+4`
  (D1:724–726, :754, :793, :848, :880, :933).

```python
for start in starts:
    for round_i in rounds:                    # C10: index = ROUND
        radius = MINE_RADIUS[version_gate][size_gate][round_i]
        for kind in ("mng","mni","mnc"):       # one of EACH per round
            for attempt in range(256):
                ang  = streams["mines"].next()*2*pi
                dst  = radius + streams["mines"].next()*span(round_i)
                x,y  = rotate_y(start, ang, dst)
                if check_stand(pattern_lib[roulette(kind)], x, y, occ):
                    stand_deposit(kind, x, y); break
    # guaranteed C1/C2 sequence, in the exact donor order above
```

- **Replaces:** port `pattern_gen.gd:13` `MINE_RINGS=[[14,22],[32,42],[50,62]]`
  (pre-77 third ring — C11), `:143–147` CIRCLE3 used as region limit (C18),
  `:239–245` only 2 stones + 2 forests (C17), and GUIDE4 L3's
  quarry/mine/food recipe counts.
- **Acceptance telemetry:** per start, exactly 1 stoneforest, ≥2 stones, ≥3
  forest stamps; radial distance bands 5–10 / 12–18 / 16–24 tiles before
  s-scaling (pipeline §5.8); nearest gold/iron/coal all in the round-0 14–22
  band; `50–62` ring never appears; zero overlap with prefill layers;
  `quarry purity=100`, `mine clearance=100`, `reach=True` for all starts
  (scan_map targets); deposit amounts scale with `cfg.minerals`.

### Stage 8 — Owner / start flood fill

- **Donor evidence:** E23/E24 [O]; D1:1370–1428 (impl), :2062 (call),
  :1430–1527, :2059–2065; C19/C20.
- **Inputs:** `starts[]`, `gScanGrid` walkability, `player_count`, `teams`.
- **Output:** `owner[W*H]`, `dist[W*H]`; (peace mode only) border marker objects.
- **Constants [O]:** 4-neighbour BFS from every start simultaneously;
  seed cells at :1381–1389, BFS at :1395–1419; border markers at spacing
  `cBorderObjDist=1`. `teams=nearby` supported by `GenerateTeamStartingPoints`
  (D1:999–1088) / `RandomStartingPoints` (D1:1090–1229) — [O] with the
  caveat that `RandomStartingPoints` picks nearest-to-chosen / farthest-from-busy
  candidates (D1:1048–1084); exact acceptance spacing [U] (EMOM's ≥0.7 cm to
  water/edge, ≥1.5–2 cm between starts, `RC_TERRAIN.md:73`, is modder
  changelog, not a donor script literal).
- **Crucial correction [O]:** `SetupBorderObjects` runs **only when
  `gbool_peacemode`** (D1:2059–2065) and places **invisible**
  `ptborder`/`ptborderwater` markers — **not** rocks/trees (C20 contradicts
  `TERRAIN_GEN_RESEARCH.md:54–57`). Do not render a rock border.

```python
q = deque()
for p, s in enumerate(starts):
    owner[s], dist[s] = p, 0; q.append(s)
while q:                                    # D1:1395–1419
    i = q.popleft()
    for n in walkable_neighbors4(i):
        if owner[n] == -1: owner[n], dist[n] = owner[i], dist[i]+1; q.append(n)
if cfg.peacetime:
    for edge in boundary_edges(owner):
        place_marker("ptborderwater" if water[edge] else "ptborder", spacing=1)
```

- **Replaces:** port has no owner grid (`TERRAIN_DONOR_PIPELINE.md` stage 12);
  port `_start_positions()` corners and "snap starts off water" (`game.gd:731–747`).
- **Acceptance telemetry:** every non-blocked cell reached from exactly one
  start; `dist` monotonic; start-spacing report (min pairwise distance, min
  distance to water/edge); `border_marker_count==0` unless peace time;
  `reach=True` all seeds.

### Stage 9 — Mill-field decoration

- **Donor evidence:** E28 [O/—]; `envfieldd = tilled soil (fields)`
  (GUIDE4:2029); donor field decals `app/assets/terrain/deco_png/envfieldd|--w.png`
  (`TERRAIN_GEN_RESEARCH.md:75`); guaranteed food rects inside
  `SetupStartingResources` (D1:720–980); GUIDE4 L3 food-rect recipe
  (GUIDE4:421–427, :480–488). Mill *building* rotor work is a separate
  non-terrain ticket (`REVIEW_REPORT.md:14`, `REPORT_FOOD_MILL_PERF.md:29`) —
  out of scope here.
- **[U] Honest scope note:** the donor plaintext scripts do **not** expose a
  standalone "mill-field decoration" stage. What exists is (a) food rects in
  `SetupStartingResources`, (b) `envfieldd` decals in the texture/decal layer,
  and (c) mill-attached fields at runtime. The stage is kept in the pipeline
  because the owner explicitly lists "mill fields" as an acceptance class
  (CHARTER §6.1), but its **exact donor stage position and tile rule are
  UNVERIFIED**. Treat the sub-rules below as **PORT APPROXIMATION** anchored to
  donor decal names + GUIDE4 footage-derived rect dimensions.
- **Inputs:** `starts[]`, `owner[]`, `terrain[]`, `decal_atlas` (`envfieldd`,
  `_winter` suffix when season==winter — D4:525–526), stream `fields`.
- **Output:** `field_decals[]` rects (5×4 nodes in GUIDE4 L3), tilled-soil tile
  ids, `objects[]` food nodes; no blocking for food (GUIDE4:104).
- **Candidate constants [I]/PORT APPROXIMATION until F07:** rect `5 cols × 4
  rows` at `1.5*TILE` spacing (GUIDE4:421–427); re-plant origin
  `st+(-9+g*8, 8.5)*TILE` after start clear r9 (GUIDE4:480–488); fields on
  terrain 0/1 only, never 2/3/4/5 (GUIDE4:489–490); `_winter` suffix in winter.

```python
for s in starts:
    for g in (0, 1):                                   # two rects + straggler
        origin = s + (-10+g*7, 7)*TILE
        for cx in range(5):
            for cy in range(4):
                p = origin + (cx*1.5, cy*1.5)*TILE
                if terrain_at(p) in (0,1) and not blocked_at(p):
                    place_food_rect_decal(p, "envfieldd" + winter_suffix)
                    add_food_node(p)                   # non-blocking
```

- **Replaces:** GUIDE4 L3 `_add_res("food", …)` rectangular clusters and the
  separate mill-rotor/field work that drifted outside the terrain ticket
  (`REVIEW_REPORT.md:14`, `REPORT_FOOD_MILL_PERF.md:29`).
- **Acceptance telemetry:** per start `food_rect_count` ≥2, `food_node_count`
  ≥20/rect, `field_decal_tile_count`, `field_on_water_or_rock==0`,
  `_winter` suffix count == field count in winter, `reach` to ≥1 food within
  25 tiles for each start (scan_map reachability target); visual "readable
  mill-field" is **[U]** until capture.

### Stage 10 — Prop / asset instancing

- **Donor evidence:** E26/E27 [O]; D1:1914–2027, :1984–1985, :1975–1982,
  :2075–2084; D4:209–217, :265–292, :296–327, :312; D6:36–148.
- **Inputs:** `objects[]` from stages 4/7/9, `cfg.season`, stream `props`.
- **Output:** final instance list with per-object scale/rotation; season-filtered.
- **Constants [O]:** 18 peasants per start on a 3-column grid (`cUnitR=0.75`,
  D1:1255–1267) — **units are a separate sim concern**; for terrain props:
  per-object random scale clamped to `[minfact,maxfact]` with 5% dead-band
  (D1:1914–2027); objects whose base name contains `terrainmesh` or `stones`
  are **skipped** by the generic random-scale pass (authored scale 1,
  D1:1984–1985); winter **deletes all `leaftree` objects** (D1:1975–1982);
  forest `cLiteProb=0.6` (`n_small_frt_lite_*` vs `n_small_frt_*`, D4:312);
  `frt_*` big/med/small sets with 16 internal retries, skipping
  `frt_s_p_2/4/6` (D4:265–292, :296–327); forest-border pass stamps
  `fb_1..fb_53`, 1–16 per cell at radius 1.5, `fb_` index `1+floor(RandomExt*53)`,
  code-3 extra probability `0.025` (D6:36, :65, :100, :104, :108, :113);
  season colour table 6/PHDR 1 (winter), 7 (desert), else 0/0 (D1:2075–2084);
  `_winter` tile suffix (D4:525–526, :605–606, :639–640; D6:138–139).

```python
for obj in objects:
    if season == "winter" and "leaftree" in obj.base_name:   # D1:1975–1982
        drop(obj); continue
    if "terrainmesh" in obj.base_name or "stones" in obj.base_name:
        obj.scale = 1.0                                       # D1:1984–1985
    else:
        obj.scale = clamp_with_deadband(streams["props"].next(),
                                        minfact, maxfact, deadband=0.05)
    obj.tile_suffix = "_winter" if season == "winter" else ""
finalize_colour_table(6 if winter else 7 if desert else 0)
```

- **Replaces:** port has no winter object deletion and no donor min/max scale
  jitter (`TERRAIN_DONOR_PIPELINE.md` stage 11); port world has no season
  texture swap (`RC_TERRAIN.md:117–120`); port `_stamp_forest_borders`
  (`game.gd:1250`) unverified against D6 (C22).
- **Acceptance telemetry:** `leaftree_count==0` in winter; scale histogram within
  `[minfact,maxfact]` with 5% dead-band and `terrainmesh/stones` share == 1.0;
  `fb_` index range 1..53; no `fb_` on interior forest cells; `colour_table`
  matches season; `app/` byte-identical; no donor binary in repo.

---

## 5. Stage-order invariants (must be preserved by any implementation)

1. **Height writes happen inside stamping (Stage 4), before collision
   (Stage 6/10) — never after.** Pipeline §5.7 / `GEN.md` Branch C: a
   post-collision height write is the cliff-ordering defect.
2. **`gPatternMask` is prefilled in Stage 4d before ANY stamp**, and includes
   shore `height<−0.1` computed from Stage 5's *classification* — so Stage 5's
   height gate must be computed before Stage 4 stamping, or shore prefill must
   use the Stage 2 `height` and be recomputed after Stage 5. **[I]** This is the
   one place where the strict donor order (shore prefill D1:1568–1581 occurs
   before relief D1:1621) interacts with height smoothing; freeze the choice
   in the spec and record it in `gen_trace`.
3. **No RNG draw in art-only branches** (Z04 §3.1 hill stamp): removing or
   adding an art write must not consume a stream value.
4. **`terrain[]` stays 0..5** (GUIDE4:311); `tile_id` atlas cells may be many,
   terrain ids may not grow.
5. **Relief owns HEIGHT only; `blocked[]` owns walkability** (Z04 Part A).
   Art promotion is a guard (return face 0 on producer-stamped cells), never a
   promoter (F2).
6. **Bank each stage's `gen_trace` before the next stage runs**; a stage that
   fails its telemetry gate must not silently continue (A05 owns the harness).

---

## 6. Implications for other workers

| Worker | Implication from this design |
|---|---|
| A01 (data model) | Must carry `gPatternMask`, `height`, `water`, `broad`, `bsmooth`, `owner/dist`, per-pattern blend flags, and `gen_trace`. `height` and `tile_id` are separate arrays; 6 terrain ids only. |
| A03 (asset pipeline) | Must export full `w×h` relief grids (not just 8×10 block means), parsed `generator.cfg` Freq table, `tilesmooth_scripts.cfg` compat tables, and mask manifests with **verified per-shape counts**. Until then stages 4b/6 stay PORT APPROX. |
| A04 (landscape props) | Hills/mountains = stamped height-grid + `terrainmesh` props (authored scale 1); not tile art. Shore = mask-B water flag + `sandsea*` aspect tiles. Mines = deposits from Stage 7; fields = Stage 9 decals. |
| A05 (QA/A-B) | Replay harness must assert per-stage stream ids, not just final hash. Histograms: height deciles, per-family stamp counts, water vs mask, occupancy overlap, scale dead-band. |
| A06 (integration) | Fresh module must be composed by `world3d.gd` behind a switch; legacy `world3d_terrain.gd` retained until A/B. No gate weakening; `app/` byte-untouched. |
| D02 / D05 / D06 | Confirm the 5-stage re-seed call sites and the `RandomExt` mixing function; confirm engine blend order and clamp; confirm water field/current. Until they land, stages 0/4b/5 are PORT APPROX/UNVERIFIED. |
| F01 / F02 / F03 / F04 / F07 | Deliver pattern record boundaries, family catalogue, parsed Freq/tilesmooth constants, verified mask counts, and mill/field family assets — all marked UNVERIFIED in this report. |

---

## 7. Risks

| # | Risk | Severity | Mitigation / gate |
|---|---|---|---|
| R1 | Per-stage re-seeding changes every downstream stage vs the port's single stream → all hashes move | high | Expected. Freeze stream ids; re-baseline diagnostics (no frozen parity baseline exists); `same_seed_byte_identical` is the invariant, not old hashes. |
| R2 | Engine blend math UNVERIFIED → stamping may read wrong height sign | high | Carry blend flags per pattern; use labelled approximation; unit-test `HeightFieldMin/Max` = grid min/max (26/26 verified); D05 must confirm. |
| R3 | 8×10 block means still read flat at 240²/320² | medium | A03 full-grid export; histogram gate proves shape reached height; honest read target, not silhouette parity. |
| R4 | Pattern-lib parsing wrong (offset ±24–160 B ambiguity, G07 §7.4) | medium-high | Bit-exact min/max gate before any table is used (G07 §3.3); no donor binary shipped. |
| R5 | Occupancy prefill incomplete → overlapping stamps | medium | Overlap telemetry target 0; 20-seed dump; C13 list is exhaustive. |
| R6 | `gRecordGeneratorVersion` [U] → wrong mine radii branch | medium | Read version at A/B time; currently use ≥80 branch and mark inferred (pipeline §6.1). |
| R7 | Mask counts [I] wrong → different mask chosen than donor for a seed | medium | F04 verification; record chosen mask name in telemetry; no parity claim until then. |
| R8 | Stage 9 mill-field has no donor stage line | medium | Kept with [U] label; no numeric donor constant asserted; F07 to resolve. |
| R9 | `tilesmooth` compat tables unread → tile seams persist | medium | F03/F05; until then PORT APPROX table and `tileflow>=99` gate. |
| R10 | No donor GPU A/B; all visual classes INFERRED | high (epistemic) | Every claim labelled; capture + histogram are the only arbiter; no parity assertion. |

---

## 8. UNVERIFIED register (constants / rules NOT confirmed by today's decoding)

| # | Item | Status | Owner to resolve |
|---|---|---|---|
| U1 | Per-shape mask counts (121/187/320/230/122/42/33/280) | [I] almanac recon, not re-verified | F04 |
| U2 | `RandomExt` / key-mix function (seed derivation formula) | [U] no plaintext consumer | D02 |
| U3 | Engine height blend operation, clamp/scale order, `HeightFieldScale=-0.925` sign, `row_flip` | [U] DPATTERN_01:366–370 | D05 |
| U4 | `HeightFieldReplace` replacement target value | [U] flag observed, operation not | D05 |
| U5 | `HeightFieldSmooth` local-smooth definition (radius/factor/offset semantics) | [U] | D05 |
| U6 | `SmoothTerrain` internal power/lerp for `bsmooth` pass | [U] | D03 |
| U7 | `tilesmooth_scripts.cfg` `TileNames`/`Prob` lists | [U] config not read | F03/F05 |
| U8 | `gRecordGeneratorVersion` shipping value (mine radius branch) | [U] | D07 |
| U9 | `gc_MaxTerrainTypeCount` value | [U] | D03/F03 |
| U10 | Exact start-spacing rules (0.7 cm / 1.5–2 cm) | [U] modder changelog, not donor literal | D07 |
| U11 | Mill-field standalone stage / exact tile rule | [U] no donor stage line | F07 |
| U12 | R1–R6 relief generator numeric parameters | [U] C27 — absent from script tree | editor/binary lane |
| U13 | Full `w×h` relief grids for all donor-active ids | [U] only 4 8×10 block means decoded | F01/A03 |
| U14 | Winter tile-name mapping for `_winter` suffix | [U] | F05/F10 |
| U15 | Donor units → port tile scale denominator (160 vs 320) | [U] derived from prior docs | D04/F03 |
| U16 | `cstartoffset=60` / `cstartoffsetrnd=25` meaning | [U] vestigial | D01/D03 |

---

## 9. Open questions

1. Does D1's `SetRandomKey` re-seed use the same 64-bit pair each time or a
   derived key? (Determines whether Stage 0's per-stage streams are truly
   independent or share a sub-sequence.) **[U] → D02.**
2. At what point is shore `height<−0.1` computed relative to Stage 3 smoothing
   — before (D1:1568) using raw height, or after using smoothed height? This
   changes the occupancy mask and therefore every stamp. **[I] → D03/D06.**
3. Are C2/C3 ellipses also applied to relief/mountain stamps, or only to
   forest/stone/mines? C13 says all mask layers prefill `gPatternMask`; C1 is
   explicit, C2/C3 less so. **[U] → D07.**
4. Does `HeightFieldReplaceForWater=True` replace height with `HeightFieldMin`
   or with a separate water depth field? **[U] → D05.**
5. Does the 3-pass `SmoothTileMap` run before or after forest-border `fb_`
   stamping? D2:781–789 then D6 is implied by call order but not pinned.
   **[U] → F03/D08.**
6. Is `season==3` (desert) the only season that changes pattern families, or do
   winter/spring/autumn also swap family weights in the shipping build? Only
   winter leaftree delete + `_winter` suffix are observed. **[U] → F10.**
7. Do the 6 terrain ids map 1:1 to donor tile classes after tile smoothing, or
   are `tile_id` atlas cells a strictly larger set? (A01 needs this answer.)
   **[U] → F05/D08.**
8. Are the mask files' RGB channels already blurred (`*_gauss`) as shipped, or
   does the kernel blur at load? C6 says random maps do **not** call
   `postprocess.inc`; confirm the derived mask export path. **[U] → F04.**

---

## 10. Closing

This report specifies an **11-stage donor-shaped pipeline** (0 seed → 1 mask →
2 decode → 3 smooth → 4 stamp → 5 water → 6 tile ids → 7 resources → 8 owner →
9 fields → 10 props) with exact donor constants, pseudocode, the port
approximation each stage replaces, and per-stage acceptance telemetry. The
dominant fidelity levers are: **per-stage RNG re-seeding**, **class×R height
decode including the negative smooth-ravine code**, **rejection-sampled pattern
stamping with a fully prefilled occupancy grid and Freq damping**, and
**mask-B-gated coastal smoothing**. Twelve rejected hacks are explicitly
forbidden. Sixteen constants/rules remain UNVERIFIED and are assigned to
specific D0*/F0* workers. **No donor parity claim is made; no donor GPU A/B
frame exists.** One report written; no code, shader, config, asset, test,
donor, queue or git edit; no Godot process or runner job.
