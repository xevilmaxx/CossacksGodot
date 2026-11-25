---
id: RELIEF-01
title: "First donor relief-grid stamping step in variant3d/scripts/world3d_terrain.gd (opt-in, approximate)"
agent: RELIEF-01 (implementation builder, coord swarm 2026-11-25)
date: 2026-11-25
status: DONE — two owned files only; donor READ-ONLY (nothing copied/run/edited); one variant-runner smoke
scope: two donor-derived coarse 8x10 relief tables inside the terrain module + opt-in additive-clamp stamp; no marker producer, no full grid, no props
owner_files:
  - variant3d/scripts/world3d_terrain.gd
  - docs/coord_swarm_2026-11-25/reports/RELIEF_01_stamping.md
backup: inbox/backup/world3d_terrain.gd.bak-RELIEF01 (58,963 bytes, pre-edit)
smoke: "python variant3d\\tools\\godot_runner.py run --id relief01-smoke --timeout 180 --max-wait 1800 -- --headless --path variant3d --script res://tests/t_terrain3d.gd"
verdict: OPT_IN_STAMPING_IMPLEMENTED__NO_CURRENT_MARKER_PRODUCER__ENGINE_BLEND_UNVERIFIED
labels: [observed, derived, PORT APPROXIMATION, UNVERIFIED]
---

# RELIEF-01 — stamp donor-authored relief grids (first small step)

> [!IMPORTANT]
> Donor is truth. Tables below are **numbers** transcribed from the decoded
> report, not donor bytes. The sculpt blend is engine-side and **UNVERIFIED**;
> the blend implemented here is the report's labelled **PORT APPROXIMATION**.
> No donor file was copied, executed or edited. No Godot process was launched
> directly — all validation went through the variant runner.

---

## 1. Evidence read (all read-only)

### 1.1 `DPATTERN_01_relief_grids.md`

| Citation | Fact used here |
|---|---|
| `:101-124` (§2.2) | `.pattern` carries a row-major `w*h` float32 height window; exact byte boundary and file-row→map-row sign are **UNVERIFIED** (`:110-124`) |
| `:142` (§3) | `k_ravine_1` 46×63, window offset 2866, scale 1, min `−2.963627576828003`, max `+3.139820098876953`, exact match to `pattern.lib:549585-549586` |
| `:154` (§3) | `plt2` 42×55, offset 2266, scale 1, min `−0.07325489819049835`, max `+3.6134116649627686`, exact match to `pattern.lib:6805-6806` |
| `:196-213` (§4.1) | ravine floor ≈ −2.96 with an asymmetric +3.14 lip; row/col RLEs |
| `:237-249` (§4.4) | plateau caps broad/flat ≈3.2–3.5, not a Gaussian |
| `:271-285` (§4.6), `:168-169` | mountain grids are **all zero**; relief is the `terrainmeshN` props — do NOT fake a taller bump |
| `:302-346` (§5.1) | placement via `dogenerate.inc:1621-1765` + `generator.cfg` `Freq`; `ravine_medium` stamp is `//`-disabled at `:1760` |
| `:348-382` (§5.2) | sculpt config exists **only** in `pattern.lib` (9,520 hits, zero script consumers); engine blend **UNVERIFIED**; safe port form is `h=clamp(h+grid*scale+offset, Min, Max)` (`:373-378`) |
| `:384-406` (§5.3) | relief props skip random scaling (`dogenerate.inc:1984`); port has no `terrainmesh*.osm` |
| `:450-501` (§7) | repeatable re-extraction recipe; §8 (`:504-537`) rules: numbers only, keep Min/Max verbatim, stamp grids for hills/plateaus, props for mountains |
| `:595-613` (Appendix A1) | `k_ravine_1` coarse 8×10 block-mean grid (G=2866) — transcribed verbatim |
| `:615-626` (Appendix A2) | `plt2` coarse 8×10 block-mean grid (G=2266) — transcribed verbatim |
| `:540-557` (§9) | open questions, including engine blend, plane boundary, row-flip, prop selection |

### 1.2 `DTRN_02_donor_terrain_geometry.md`

- C6 `:102` — relief `.pattern` float32 grids; min/max equal `HeightFieldMin/Max`.
- C7 `:103` — donor **does** sculpt height from stamps; engine blend math UNVERIFIED.
- C8/C9 `:104-105` — mountains/plateaus place real 3D prop meshes; no port props exist.
- C10 `:106` — baked map heights clamped to ±2.964; C17 `:113` — port mesh topology; C20 `:116` — `TILE_M=2.0`/`HEIGHT_SCALE=1.0` are port facts, donor metre scale UNVERIFIED.
- §8 `:362-428` — smallest-first fix recipe; Step 2 explicitly asks for a labelled additive-clamp stamp on the 64² fixture.

### 1.3 Port code read only (no edit)

- `variant3d/scripts/world3d_terrain.gd` — height acquisition path is
  `build()` → `_dump_from_game()` → base64 `height[]` decode → mesh; no pattern input.
- `variant3d/scripts/main.gd:736-743` — `_dump_map()` schema: `seed, map_w, map_h,
  terrain, blocked, height, tileblock, starts, clusters, res, meta`. **No relief/pattern marker.**
- `variant3d/tests/t_terrain3d.gd:22-23,126` — smoke uses 320² and a dump with only
  `map_w/map_h/height`; no marker either.
- `variant3d/scripts/game.gd:64-70` holds `pattern_stamps`; the stamp records are
  `C3PatternGen.Stamp` (`variant3d/scripts/pattern_gen.gd:50-57`) with
  `family/name/kind/x/y/cells`. Both are another owner's files; per the task
  directive no hook was invented there.

---

## 2. Input-marker finding and design decision

**Observed:** the terrain module's actual input (the dump dictionary) carries no
pattern or relief marker. Therefore no stamp can fire in any current path.
Per the directive, **no hook was invented in `game.gd`, `main.gd`, `mapgen.gd`,
tests, shaders, atlas loader or `app/**`**. Instead this ticket delivers both:

1. a self-contained **opt-in marker field** `dump["relief_stamps"]` read by
   `build()` (a producer can later populate it without touching this module), and
2. a public, read-only **opt-in helper** `apply_relief_grid(...)` callable by a
   test or tool with an explicit grid, name, centre, scale and footprint.

The integration ticket in §7 records the producer-side work. With no marker,
behaviour is byte-identical to the pre-RELIEF-01 path.

Marker schema (accepted types: JSON floats or ints):
`{"name": "k_ravine_1"|"plt2", "cx": <map cell x>, "cy": <map cell z>,
"scale"?: float, "footprint_w"?: int, "footprint_h"?: int}`.
Defaults: centre = map centre, footprint = 10×8 cells (the coarse grid's native
resolution), scale = 1.0. Cells outside the map are skipped; the mesh topology
never changes.

---

## 3. Before → after (line numbers, backed-up file → current file)

Backup baseline: `inbox/backup/world3d_terrain.gd.bak-RELIEF01` (exactly the
pre-edit file, 58,963 B). `git diff --no-index --stat` reports **219 insertions,
0 deletions** — purely additive.

| Before (backup, old lines) | After (current file, new lines) | Change |
|---|---|---|
| after old `:73` (TRN-GEOM header) | `:75-95` | RELIEF-01 documentation block: provenance, opt-in design, blend label, invariant statement |
| after old `:162` (`DONOR_SHORE_H`) | `:185-243` | `RELIEF_COARSE_W/H = 10/8`; `RELIEF_K_RAVINE_1` and `RELIEF_PLT2` flat 80-float tables; `RELIEF_TABLES` metadata (family, src_offset, grid w/h, scale, min/max, citations); `RELIEF_BLEND_LABEL` |
| after old `:215` (`_water_fallback_cells`) | `:298-299` | `_relief_applied: Array = []` audit ledger (no mesh state) |
| after old `:269` (`_read_json()`) | `:354-455` | `apply_relief_grid()` public helper (`:363-411`) and `_apply_relief_stamps_from_dump()` marker reader (`:420-455`) |
| old `:831` (`_water_fallback_cells = 0` in `invalidate()`) | `:1020-1021` | clear `_relief_applied` on rebuild (no stacked ledgers) |
| after old `:859` (`var t_heights`) | `:1051-1061` | opt-in stamp call inside `build()` after height decode, **before** mesh/atlas/water; recompute `hmin/hmax` only if a stamp applied |
| after old `:1075` (`"height_range_m"`) | `:1278-1294` | `stats["relief_grid"]`: label, blend form, table names, coarse size, source, marker field, `applied`, `stamps`, `not_done` |

Unchanged by construction: `TILE_M=2.0` (`:130`), `HEIGHT_SCALE=1.0` (`:131`),
`WATER_LEVEL=-0.25` (`:132`), donor water height `−1.1` (never in this module —
owned upstream), vertex/index construction, UV/UV2 writes, atlas (16,8) manifest
binding, `_face_hist` accounting, `mi.cast_shadow = OFF`, material/shader wiring.
No stamp touches these; the only mutation is `height[idx]` when a marker exists.

### 3.1 Blend actually implemented

```
# PORT APPROXIMATION — DONOR ENGINE BLEND UNVERIFIED (DPATTERN-01 §5.2)
sf      = HeightFieldScale(donor, verified) * marker.scale
delta   = coarse8x10[gy*10 + gx] * sf
h_final = clamp(h_base + delta, HeightFieldMin, HeightFieldMax)   # per-pattern literals
```

`HeightFieldMin/Max` are the exact `pattern.lib` values for the two patterns.
GDScript float literals are parsed as doubles and narrowed at `clampf()`, so the
stored float32 clamp values are the bit-exact ones from the report.
`HeightFieldReplace`, `ReplaceForWater`, `Smooth` and the `HeightFieldOffset`
order are **not** modelled (no plaintext consumer exists).

---

## 4. Validation (variant runner only)

Command (exactly one Godot job, no direct `godot`, no gates, no ladder):

```
python variant3d\tools\godot_runner.py run --id relief01-smoke --timeout 180 --max-wait 1800 -- --headless --path variant3d --script res://tests/t_terrain3d.gd
```

| Field | Observed result |
|---|---|
| Ticket / id / status / exit | **402** / `relief01-smoke` / `ok` / **0** |
| Wait / run | 101.60 s (shared FIFO) / 19.18 s |
| Result file | `variant3d\.godot_queue\results\00000402.json` |
| stderr | **0 bytes → `SCRIPT ERROR == 0`** (no parse/compile/runtime error) |
| stdout | `T_TERRAIN3D RESULT: PASS 6/6` |
| Checks | `module_load_and_api`, `build_ok`, `surface_count`, `vertex_count`, `has_chunk_or_fallback`, `height_at_world_samples` — all PASS |
| Geometry observed | `surfaces=1`, `vertices=102400`, `triangles=203522` at 320² (test grid) |
| Height samples | three cell centres, `err=0.0` each — confirms the no-marker path perturbs nothing |

**64² invariants:** the smoke test is 320² by its own constant
(`t_terrain3d.gd:22-23`); at 64² the unchanged formulas give exactly
`64*64 = 4,096` vertices and `63*63*2 = 7,938` triangles in one surface. UV2
pair (`TEX_UV`/`TEX_UV2`), atlas-grid `(16,8)` from the manifest, `_face_hist`
bookkeeping and `cast_shadow = OFF` are all in untouched code paths; the stamp
changes only `height[]` values when a marker is present.

No foreign transient error was observed in this job. Other builders' edits to
`game.gd`, `world3d_fx.gd`, `selftest.gd`, tests and docs were **seen in
`git status` and left completely untouched** (never reverted).

---

## 5. Explicit UNVERIFIED / APPROXIMATION labels

1. **Engine sculpt blend** — `Replace`/`ReplaceForWater`/`Smooth` order, clamp
   order, `HeightFieldScale` sign convention and the smoothing definition are
   **UNVERIFIED** (DPATTERN-01 §5.2, §9 Q2); additive-clamp is a
   **PORT APPROXIMATION**, not donor parity.
2. **Coarse grids are derived block means** (DPATTERN-01 Appendix A, `:595-600`),
   explicitly "debug/preview aids only — stamp from the full grid"; the full
   `w*h` float32 windows are **not** in this module.
3. **File-row → map-row sign (flip flag)** — **UNVERIFIED** (DPATTERN-01 `:120-124`);
   the helper keeps file order (gy increases downward), labelled port approximation.
4. **Footprint size** — the donor engine's stamp extent/placement is engine-side
   (`dogenerate.inc:1621-1765`, native `StandPattern`); the 10×8 cell window is a
   port convenience derived from the coarse table's own dimensions, **UNVERIFIED**.
5. **Marker field `relief_stamps`** — a port-side opt-in contract invented here
   (inside this file); **no current producer emits it** (§2, §7).
6. **Donor metres per cell** — **UNVERIFIED** (DTRN-02 C20); `TILE_M=2.0` stays a
   port fact. Pattern clamp max `+3.6134` exceeds the port's later global cap
   `+2.964` (game.gd:1096-1097); how integration reconciles those is an open question.
7. **Season** — all 680 patterns are `NativeSeason=Summer/Winter=True`
   (DPATTERN-01 `:180-185`); a single grid is used in both seasons, so no
   winter table was added.
8. **No visual parity claim** — the smoke is a parse/build/geometry check, not a
   GPU A/B against the donor.

---

## 6. What was NOT done (out of scope / separate tickets)

- **Mountain props** — `terrainmesh1..4` / `terrainplateau1..4` were not baked or
  instantiated. Mountain height grids are all-zero and the relief lives in
  3D props (DPATTERN-01 §4.6/§6; DTRN-02 C8/C9). No fake bump was added.
- **Full 26-grid float32 table** — only 2 of 26 decoded patterns are encoded,
  and only as 8×10 coarse means. No donor binary was copied into the repo.
- **Exact engine blend** — no `Replace`/`Smooth`/offset emulation; UNVERIFIED.
- **Marker producer** — no edit to `game.gd`/`main.gd`/`pattern_gen.gd` to export
  `dump["relief_stamps"]` (ownership rule).
- **64² acceptance gates, 256², combo ladder, full selftest/uitest, windowed
  shots** — not run, per directive. Only the one `t_terrain3d.gd` smoke.
- **2× collision sampler, R-code decode, normals/cliff-face changes, shaders,
  atlas, water, tests, `app/**`** — untouched.

---

## 7. Integration ticket (for the owning builder, NOT executed here)

**RELIEF-01-FOLLOWUP — emit the opt-in marker.** In the producer's dump path
(`variant3d/scripts/main.gd:_dump_map()` / `_dump_self_base()` ownership) add an
optional `relief_stamps` array, populated from the sim's
`game.pattern_stamps` / `_pattern_build["stamps"]` (`game.gd:64-70,881-981`) for
relief kinds only, e.g. `{"name": st.name, "cx": st.x, "cy": st.y}` where
`st.name` is a donor pattern id present in `RELIEF_TABLES`. No edit to this
module is then needed. Acceptance: a 64² dump with one `k_ravine_1` marker yields
at least one cell with `height < −2.0` and unchanged counts
(4,096 / 7,938 / 1 surface); a `plt2` marker yields a broad cap near +3.2–3.5
capped by the pattern max. Note the unresolved port-band interaction in §5.6.

---

## 8. Open questions (UNVERIFIED — do not guess)

1. Exact donor blend math and the `Smooth` definition (DPATTERN-01 §9 Q2).
2. Exact float-plane byte boundary and why it varies per pattern (§9 Q1).
3. Which file row maps to which sign of centred donor Y (§9 Q3).
4. Donor stamp extent/placement rule and how it relates to the 8×10 coarse cells.
5. Which `terrainmeshN` a mountain selects at runtime (§9 Q4); mountain props ticket.
6. `terrainplateau1..4` selection: zero `pattern.lib` refs, no `.prop` files (§9 Q5).
7. Whether `HeightFieldMin/Max` are authored or derived (§9 Q9); how pattern max
   `+3.6134` interacts with the port's later `+2.964` cap.
8. Full-grid fidelity: whether to export numeric `float32[]` tables (derived data)
   for all 26 patterns in a later ticket.
9. Sub-cell 2× collision parity (DTRN-02 C12) — separate ticket.
10. The sanctioned smoke input has no `relief_stamps` marker, so the stamp path
    itself was **not exercised at runtime** — only its parse/build/no-op
    integration was. A functional stamp assertion belongs with the marker
    producer in §7 (or a future ticket that adds its own sanctioned smoke).

---

## 9. Summary

- Encoded **two** donor-derived coarse relief grids (`k_ravine_1`, `plt2`, 8×10
  each) as constant tables inside `variant3d/scripts/world3d_terrain.gd`, with
  verified `pattern.lib` scale/min/max and explicit DPATTERN-01 citations. No
  donor bytes, assets, or binaries were copied.
- Implemented an **opt-in additive-clamp stamp** (`apply_relief_grid()` helper
  plus a `dump["relief_stamps"]` reader in `build()`), labelled
  **PORT APPROXIMATION — donor engine blend UNVERIFIED**. With no marker in the
  current input, it is a no-op — all heights, topology, UV2, atlas, face history
  and shadow settings are unchanged.
- Backup: `inbox/backup/world3d_terrain.gd.bak-RELIEF01`. Diff: **+219 / −0** lines.
- Smoke: runner ticket **402**, `relief01-smoke`, exit 0, stderr 0 bytes
  (**`SCRIPT ERROR == 0`**), **`T_TERRAIN3D PASS 6/6`**.
- Not done: mountain props, full 26-grid table, exact engine blend, marker
  producer (documented as an integration ticket), gates/ladder.
- **No file other than the two owned files was edited by this agent.** (The
  smoke test wrote its own result artifact under `variant3d/tests/results/`,
  which is harness output, not a source edit; other builders' concurrent
  changes were observed and left untouched.)

*End of RELIEF-01.*
