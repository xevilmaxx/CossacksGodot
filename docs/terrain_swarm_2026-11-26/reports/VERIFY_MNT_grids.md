---
id: VERIFY-MNT
ticket: "TERRAIN-SWARM-2026-11-26 / VERIFY-MNT — SECONDARY verification of the donor mountain data model (g_mnt_1..7 grids + mountain_props.json)"
agent: "VERIFY-MNT (VISUAL WAVE read-only verification subagent; reporting to COORD)"
created: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_CODE__NO_GODOT__NO_GIT
owner_file: docs/terrain_swarm_2026-11-26/reports/VERIFY_MNT_grids.md
files_created: [docs/terrain_swarm_2026-11-26/reports/VERIFY_MNT_grids.md]
files_edited: []
labels: [O, D, I, U, "PORT APPROXIMATION"]
scope_guard: "Exactly one repo file written (this report). No code, Godot, asset, config, test, fixture, runner job or git state touched. All inputs read in place; donor at C:\\Games\\Cossacks 3 not opened by this worker. Scratch scripts/JSON live only in %TEMP%\\opencode\\verify_mnt\\."
priors_read:
  - docs/terrain_swarm_2026-11-26/reports/X54_ground_truth_card.md
  - docs/terrain_swarm_2026-11-26/reports/X25_relief_silhouette_reference.md
  - docs/terrain_swarm_2026-11-26/reports/A04_landscape_props.md
  - variant3d/assets/terrain_new/patterns/g_mnt_1.json .. g_mnt_7.json
  - variant3d/assets/terrain/mountain_props.json
parity_guard: "NO DONOR VISUAL PARITY CLAIM. No donor GPU A/B frame exists, no donor binary was executed, no gate was run. This report verifies the on-disk derived data model only; 'confirmed' means byte/field-level agreement across independent read passes, never visual fidelity."
parity_claim: false
parity_status: UNVERIFIED
multiple_passes: true
multiple_pass_note: "Every field below was read at least twice; the g_mnt_7 nonzero-grid anomaly received five distinct passes (JSON parse, raw-literal regex scan, flags-vs-grid cross-check, float32 bit-equality, distribution/max-index check). No value was promoted on a single reading."
---

# VERIFY-MNT — donor mountain data model, secondary verification

> [!IMPORTANT]
> Labels: `[O]` = literal on-disk field/value read this ticket · `[D]` = arithmetic or set
> consequence of observed values · `[I]` = best reading without an engine run · `[U]` =
> UNVERIFIED · `PORT APPROXIMATION` = explicit port substitute, never donor truth.
> Repo paths are relative to the workspace root. **NO DONOR PARITY CLAIM.**

---

## 1. Executive findings

1. **[O] Six of seven `g_mnt_*` height grids are all-zero; `g_mnt_7` is NOT.**
   `g_mnt_1..6` have `relief_float_grid` min = max = `0.0` with **0 nonzero values**.
   `g_mnt_7` has **526 nonzero of 2,200** values, min `0.0`, max
   `0.8755102157592773` (float32 bits `7021603f`), all nonzero values positive. Its
   `flags.Max` is `0.875510215759277` — the **same float32 bit pattern** (`7021603f`),
   i.e. the grid maximum is bit-exactly consistent with the decoded metadata Max. The
   blanket statement "all mountain height grids are zero" is therefore **only true for
   `g_mnt_1..6`** and must be qualified for `g_mnt_7` (§4, multiple passes M1–M5).
2. **[O]/[D] The mountain silhouette is carried by `terrainmesh*` props, not by the
   height grid.** All seven patterns carry terrainmesh prop records in
   `mountain_props.json` (22 records across 7 sections), and A04 §0.1/§4.2 + X25 §4.1
   establish the four converted meshes are **6.92–9.54 donor units tall** and ≈25–28
   units wide. Even `g_mnt_7`'s +0.8755 window is ≤ 1 unit and cannot supply a mountain
   silhouette. Engine-side blend of the window remains `[U]` (file label: "engine blend
   [U]").
3. **[O] `mountain_props.json` cross-check passes:** `records_total = 112`,
   `port_stampable_sections = 20`, `sections_with_props = 30`; an independent sum of all
   `by_pattern[*]` list lengths also returns **112**; the seven `g_mnt_*` sections map
   **exclusively to `terrainmesh1..4`** (no desert BaseName leaks), with per-section
   counts `5/2/4/1/4/4/2` = **22** renderable records — matching X25 §4.2 exactly.
4. **[O]/[D] `object_records` in the `g_mnt_*.json` files is NOT the prop count.** It is
   the raw structural `Rec24` decode (1,554 / 1,176 / 1,116 / 750 / 1,554 / 1,443 /
   2,107 records), whose `id`/`tail4` semantics are `[U]` and which carries **no
   prop-name mapping** (the file's own `labels.object_records` says so). The terrainmesh
   BaseNames come only from `mountain_props.json`, derived from `pattern.lib`. Do not
   read `1,554` as "number of mountain props."
5. **[D] Exact I07/I09 implication: do not synthesize height for mountains; place
   props.** See §6 for the full statement. No analytic dome, invented grid, or
   `HEIGHT_SCALE` fudge is donor-grounded for `g_mnt_*`.

---

## 2. Evidence

| ID | Evidence (exact path / field) | Label | Establishes |
|---|---|---|---|
| V-MNT-E01 | `variant3d/assets/terrain_new/patterns/g_mnt_{1..7}.json` — top-level `w`, `h`, `flags`, `relief_float_grid`, `object_records`, `byte_closure.ok`, `labels` | `[O]` | Direct on-disk derived data model, seven files |
| V-MNT-E02 | Same files, `labels.min_max_crosscheck`: "[O] bit-exact float32 match vs lib Min/Max at CORRECTED G"; `labels.metadata_source` e.g. `g_mnt_7`: `pattern.lib:352189 (byte 9086301)` | `[O]` text | flags Min/Max are decoded donor metadata, not port-invented |
| V-MNT-E03 | `variant3d/assets/terrain/mountain_props.json` — `derived_stats` (`records_total`, `sections_with_props`, `port_stampable_sections`, `port_stampable_records`, `base_name_census`), `by_pattern`, `props`, `pattern_meta` | `[O]` | Authoritative derived prop table; independent sums match |
| V-MNT-E04 | X25 E05/E06/§4.2: 22 renderable `g_mnt_*` records, 23 desert skipped, 30 sections / 112 records / 20 stampable / 45 stampable records | `[O]` prior | Cross-report agreement with V-MNT-E03 |
| V-MNT-E05 | A04 E02: `pattern.lib:337491-337492` (`g_mnt_1` `HeightFieldMin=Max=0`); A04 §0.1 verdict + §4.2; X25 §4.1 mesh geometry | `[O]`/`[D]` prior | Prior "mountain grids zero" reading is g_mnt_1-scoped; silhouette attribution to props |

**Method.** Read-only Python 3.14.3 (`C:\Python314\python.exe`). Pass 1: `json.load` +
field extraction for all seven files and `mountain_props.json`. Pass 2: independent
regex scan of the raw `relief_float_grid` literal text for `g_mnt_7`. Pass 3: `flags`
Min/Max vs grid min/max across all seven. Pass 4: `grid_len == w*h` and
`byte_closure.ok` across all seven. Pass 5: `struct.pack('<f', …)` bit-equality of
`flags.Max` vs grid max plus nonzero distribution/max index. Pass 6: independent
re-summation of `by_pattern`/`props`/`base_name_census`. No engine, no donor binary,
no gate, no write inside the repo other than this report.

---

## 3. Per-pattern data model (`g_mnt_1..7`)

### 3.1 Grid and record table

| Pattern | w × h | grid len (= w·h) | relief_float_grid min | max | nonzero | object_records (raw Rec24) | BaseNames (`mountain_props.json::by_pattern`) |
|---|---|---|---|---|---|---|---|
| `g_mnt_1` | 43 × 38 | 1,634 | `0.0` | `0.0` | **0 / 1,634** | 1,554 | `terrainmesh4, terrainmesh3, terrainmesh2, terrainmesh4, terrainmesh3` (5) |
| `g_mnt_2` | 43 × 29 | 1,247 | `0.0` | `0.0` | **0 / 1,247** | 1,176 | `terrainmesh3, terrainmesh4` (2) |
| `g_mnt_3` | 32 × 37 | 1,184 | `0.0` | `0.0` | **0 / 1,184** | 1,116 | `terrainmesh2, terrainmesh4, terrainmesh1, terrainmesh3` (4) |
| `g_mnt_4` | 31 × 26 | 806 | `0.0` | `0.0` | **0 / 806** | 750 | `terrainmesh2` (1) |
| `g_mnt_5` | 38 × 43 | 1,634 | `0.0` | `0.0` | **0 / 1,634** | 1,554 | `terrainmesh3, terrainmesh3, terrainmesh2, terrainmesh1` (4) |
| `g_mnt_6` | 40 × 38 | 1,520 | `0.0` | `0.0` | **0 / 1,520** | 1,443 | `terrainmesh2, terrainmesh4, terrainmesh3, terrainmesh3` (4) |
| `g_mnt_7` | 44 × 50 | 2,200 | `0.0` | **`0.8755102157592773`** | **526 / 2,200** | 2,107 | `terrainmesh3, terrainmesh1` (2) |

`[O]` all columns. `grid len == w*h` and `byte_closure.ok == true` for all seven
(pass 4). `object_records` counts equal `(w−1)·(h−1)` in every case (e.g. `g_mnt_7`:
49·43 = 2,107) — consistent with the structural `Rec24`/occupancy lattice, and a
further reason not to equate this count with props. `[D]`

### 3.2 Flags

| Pattern | Min | Max | Offset | Scale | TerrainScale | Replace | ReplaceForWater | Smooth | Stand |
|---|---|---|---|---|---|---|---|---|---|
| `g_mnt_1` … `g_mnt_6` | `0.0` | `0.0` | `0.0` | `1.0` | `1.0` | `false` | `true` | `true` | `true` |
| `g_mnt_7` | `0.0` | `0.875510215759277` | `0.0` | `1.0` | `1.0` | `false` | `true` | `true` | `true` |

`[O]`. Pass 7: `g_mnt_1..6` flags are byte-for-byte identical; `g_mnt_7` differs in
**`Max` only**. Note `Replace = false`, `ReplaceForWater = true`, `Smooth = true`,
`Stand = true` on all seven — these are the decoded sculpt flags, but the **engine
blend path for them remains `[U]`** (X54 row 3; A04 §4.1). No claim is made here about
runtime height modification.

### 3.3 `mountain_props.json` cross-check

| Field | Declared (`derived_stats`) | Independent recount | Result |
|---|---|---|---|
| `records_total` | 112 | `Σ len(props[section]) = 112`; `Σ len(by_pattern[section]) = 112` | `[O]` match |
| `sections_with_props` | 30 | `len(by_pattern) = 30`, `len(props) = 30` | `[O]` match |
| `port_stampable_sections` | 20 | `len(list) = 20` (13 `desert_mnt_*` + 7 `g_mnt_*`) | `[O]` match |
| `port_stampable_records` | 45 | 23 desert + 22 `g_mnt_*` = 45 | `[O]` match |
| `base_name_census` | mesh1 14, mesh2 21, mesh3 29, mesh4 25; desert1 2, desert2 5, desert3 7, desert4 9 | 14+21+29+25+2+5+7+9 = 112 | `[O]` match |

`[D]` g_mnt section counts: `g_mnt_1`=5, `_2`=2, `_3`=4, `_4`=1, `_5`=4, `_6`=4,
`_7`=2 → **22**, identical to X25 §4.2's renderable-record census and to the
`mountain_props.json` `pattern.lib` line decode (A04 E03). `i_mnt_*` contributes 10
sections / 67 records; 22 + 23 + 67 = 112. **Every `g_mnt_*` BaseName is one of
`terrainmesh1..4`; zero desert BaseNames leak into `g_mnt_*`.** `[O]`

---

## 4. Nonzero-grid anomaly — `g_mnt_7` (multiple passes)

| Pass | Method | Result | Verdict |
|---|---|---|---|
| M1 | `json.load` → `min`, `max`, `sum(x != 0)` over `relief_float_grid` | min `0.0`, max `0.8755102157592773`, nz **526 / 2,200** | anomaly present |
| M2 | Independent raw-text regex capture of the `relief_float_grid` JSON array, split/float-parse literals | 2,200 literals, **526** nonzero, min `0.0`, max `0.8755102157592773`; first nonzeros `2.82e-06, 4.97e-05, 3.61e-04, …` (smooth small rise) | agrees with M1 |
| M3 | Compare `flags.Min/Max` to grid min/max for all 7 | `g_mnt_7` `flags.Max = 0.875510215759277`; 1,674 grid values equal `flags.Min = 0.0`; all other 6 patterns `Min=Max=0` with 0 nonzero | anomaly isolated to g_mnt_7 |
| M4 | `struct.pack('<f', …)` on `flags.Max` and grid max | both `7021603f` → **bit-exact float32 match** (the 15-vs-16-digit decimal difference is JSON serialization, not a value difference); re-confirms file's `min_max_crosscheck` label | not a decode artifact |
| M5 | Distribution + location of max | 526 distinct positive values; max at row-major index 130 → row 2, col 42 (44-wide grid), i.e. a localised positive bump near the top edge | raw window is a small local bump, not a mountain field |

**Accepted reading `[O]`/`[D]`:** `g_mnt_7` genuinely carries a small positive float
height window (max ≈ +0.8755 in the stored f32 units, 526 cells) that is
**bit-exactly consistent with its decoded metadata Max**, plus **2** terrainmesh props.
This does **not** overturn the central data-model fact (A04 §0.1, X25 §1/§4.1) that
mountain silhouettes come from `terrainmesh*` geometry: 0.8755 units is an order of
magnitude below the 6.92–9.54-unit mesh Z-spans, and the blend path that would apply
this window is `[U]`. The prior blanket wording "mountain grids are all-zero"
(A04 E02 citing `g_mnt_1` only; X25 implies the same for the family) is **correct for
`g_mnt_1..6` and must be qualified for `g_mnt_7`**. This is a primary-data correction
for COORD's attention, **not** a donor-parity or gate finding.

---

## 5. Do `terrainmesh*` objects carry the actual silhouette? — confirmation

**Yes `[O]`/`[D]`.** Three independent lines of evidence:

1. **Data model:** every `g_mnt_*` section resolves exclusively to `terrainmesh1..4`
   BaseNames (§3.3), 22 records; no section relies on its height grid for silhouette
   (6 grids zero, 7th ≤0.8755).
2. **Geometry (X25 §4.1, `[O]`):** `terrainmesh1..4` OBJs total 9,620 V / 19,162 F with
   Z-spans 7.379 / 8.060 / 9.540 / 6.920 donor units and h/w 0.264 / 0.306 / 0.368 /
   0.270 — broad shallow relief caps, i.e. the mountain shape.
3. **Design/decoded donor (A04 §0.1, E02/E04, `[O]`):** "Mountains need channel P: the
   donor `g_mnt_*` patterns have zero height grid and exist to carry `terrainmeshN`
   props"; meshes are 6.93–9.55 units tall with their own albedo.

Caveats carried forward, not closed here: terrainmesh3 topology anomaly and yaw sign
are `[U]` (X25 §7 items 4/1); `terrainmeshdesert1..4` are unconverted (X25 §7 item 2);
the engine transform has no metres-per-unit factor (`PORT APPROX`). None of these
changes the silhouette-source attribution.

---

## 6. Exact implication for I07 / I09

> **Do not synthesize height for mountains; place props.**

- **I07 (height/stamp channel):** For any `g_mnt_*` stamp, emit **no synthetic mountain
  height**. Do not add an analytic dome, do not invent a float window, do not apply a
  non-1.0 `HEIGHT_SCALE` fudge. The only decoded windows are the seven stored arrays
  (six all-zero; `g_mnt_7` max +0.8755102 as-is), and even those are subject to an
  `[U]` engine blend. `g_mnt_7`'s small bump may be carried verbatim if a future
  contract decodes the blend, but it must never be promoted into a ridge cue.
- **I09 (props channel):** Instantiate the **22 renderable `g_mnt_*` records** from
  `mountain_props.json` verbatim — per-section counts 5/2/4/1/4/4/2, authored uniform
  scales, `terrainmesh1..4` sids, one `MultiMeshInstance3D` per sid, ground Y from the
  height field. The 23 `desert_mnt_*` records have **no converted sid** and are counted
  as `skipped_unknown_sid` (X25 §1.3/§6). A "mountains present" gate must key on the
  seven `g_mnt_*` sections (X25 §6.3), not on desert props, mines, or synthetic height.
- **Forbidden substitutes (A04 §5.5):** flat-only mountains, radial rock rings,
  diagonal vein lattice, per-cell noise/dither, fabricated quarry asset, invented
  height. None may be used to "make" a mountain where props are absent.

This is a structural/data-model instruction for the port's own stages. It is **not**
a donor-parity verdict; the props ON/OFF A/B and geometry checks remain the
authorised runner owner's work (X25 §6.5, A04 P0/P3).

---

## 7. UNVERIFIED register (do not promote)

1. Engine blend of any `relief_float_grid` window, including `g_mnt_7` — `[U]` (file
   label "engine blend [U]"; X54 row 3). No runtime height modification is claimed.
2. `object_records` `id`/`tail4` semantics and any id→prop-name mapping inside the
   `g_mnt_*.json` files — `[U]` (file label "no prop-name mapping"). BaseNames used
   here come only from `mountain_props.json`/`pattern.lib`.
3. Whether `g_mnt_7`'s +0.8755 window is donor-authored or a decode-window shift —
   its bit-exact Min/Max agreement favours authored, but no donor binary was run;
   `[U]`. Metadata source `pattern.lib:352189` recorded, not re-opened.
4. Prop placement transform, yaw sign, metres-per-unit factor — `[U]`/`PORT APPROX`
   (X25 §7 items 1/6).
5. Donor visual parity of any silhouette — no GPU A/B frame exists; `[U]`, no claim.

---

## 8. Claim register

| # | Claim | Evidence | Label |
|---|---|---|---|
| 1 | `g_mnt_1..6` grids all-zero; `g_mnt_7` 526/2200 nonzero, max +0.8755102, flags Max bit-exact | §3, §4 M1–M5 | `[O]`/`[D]` |
| 2 | All seven `w/h`, grid len = w·h, byte_closure ok; flags identical except g_mnt_7 Max | §3.1/§3.2 | `[O]` |
| 3 | `object_records` = raw Rec24 count, not prop count; BaseNames from mountain_props.json only | §1.4, §7 item 2 | `[O]`/`[D]` |
| 4 | `mountain_props.json`: 112 records / 30 sections / 20 stampable / 45 stampable records, independently recounted | §3.3 | `[O]` |
| 5 | All `g_mnt_*` map exclusively to `terrainmesh1..4`; 22 renderable records match X25 | §3.3 | `[O]`/`[D]` |
| 6 | Silhouette carried by terrainmesh props (6.92–9.54 units), not height grid | §5 | `[O]`/`[D]` prior |
| 7 | I07/I09: do not synthesize height for mountains; place props | §6 | `[D]` |
| 8 | No donor GPU A/B frame, no donor binary run, no gate; **no parity claim** | frontmatter, §7 | `[U]` |

---

*End of VERIFY-MNT. Read-only secondary verification: no code, asset, config, test,
fixture, runner job or git edit; no donor binary executed or copied; no donor-parity
claim. Exactly one repo file written (this report).*
