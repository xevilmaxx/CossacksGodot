# QA-1 — `scan_map.py` forest-gate calibration (T2QA, 2026-11-21)

Scope: `app/tools/scan_map.py` only (backup at
`inbox/backup/scan_map.py.bak-T2QA`). No `.gd` file, `.import` file or game
logic was touched. No Godot process was started; all work is a Python tool
plus Python analysis of existing dumps. `python -m py_compile
app/tools/scan_map.py` is clean.

## 1. Why the old gate was wrong

The old forest gates were:

```python
if not (8 <= r["patches"] <= 16): ...
lo, hi = 40 * (r["map_w"]/160.0)**2, 120 * (r["map_w"]/160.0)**2
if not (lo*0.6 <= r["mean_sz"] <= hi*1.6): ...
```

At 320 that is `patches 8..16`, `mean_sz 96..768`. The product ceiling is
`16 × 768 = 12,288` cells = **12.0 %** of a 102,400-cell map — below the
donor-derived 17–48 % band. `GEN.md:173-178` already records that the harness
was written for the 160-tile baseline and was not scaled (only *mean* size was
area-scaled; patch count was left at 8–16). `map_density.md:212` records that
"8–14 patches" is a port-invented target with no donor source.

The gate was not merely strict: it was also **too loose at the low end**. The
pre-GEN baseline (0.9 % forest) and the improved GEN dumps (5.1–5.7 %) both
scored "ALL GREEN" under it, so it could not distinguish donor-like structure
from a bare map.

## 2. Scaled thresholds — derivation from first principles

All donor inputs are from `docs/audit/PIECES/map_density.md`:

| Input | Value | Source |
|---|---|---|
| donor forest-family stamps at 320 | 115 (prob=1) … 236 (mod×2) | §3.2 table |
| same count at 160 | 29 … 59 | `needed=floor(W*H*freq)`, so ×4 at 320 |
| merge ratio, 160 baseline | ~29–59 stamps → 8–14 patches ⇒ **2–4 stamps per patch** | §2.2 + §4 |
| forest coverage band | **15 %** (F1/A1 acceptance floor) … **48 %** (§3.3 inferred donor upper) | §3.3, §6 |
| TS-1 tree-density band | 20–60 / 150–250 / 650–1000 trees/MP | `TERRAIN_REFERENCE_IMAGES.md:176` |

Derivation (implemented as `patch_gates(w, h)`):

1. **Stamp count scales with area**, not linearly. The donor rule is
   `needed = floor(W*H*freq)`, so 115…236 at 320 ×(area/102400) at any size.
   This is the same area law that produced the old `s² = 4` mean-size scaling,
   but applied to the *count* gate the old code left unscaled.
2. **Patch count = stamps ÷ merge factor.** Using the donor-derived 160 merge
   observation: lower bound `round(115 / 2.9) = 40`, upper bound
   `int(236 / 2.6) = 90`. The 2.9/2.6 bracket sits inside the observed 2–4
   stamps-per-patch range. ⇒ **patches 40…90**.
3. **Mean size is the coverage band divided by the patch extremes**, so the
   `(patches × mean_sz)` product envelope equals the donor coverage envelope:
   - floor: `int(0.15 × 102400 / 90) = 170` cells
   - ceiling: `int(0.48 × 102400 / 40) = 1228` cells

   ⇒ **mean_sz 170…1228**. Cross-check: `90 × 170 = 15,300` cells = 14.9 %
   ≈ the 15 % floor; `40 × 1228 = 49,120` = 48.0 % ≈ the donor upper bound.
   The old 96…768 band could express at most 12 % and could not reach 15–48 %.
4. TS-1's 650–1000 trees/MP band is a **per-cell detail** criterion
   (`map_density.md:195-204`: the port is 2–3× too dense inside existing
   cells); it constrains `pattern_gen`/`world`, not the patch *count*. This
   gate therefore checks structure (count × size), and `dark` (coverage) is
   printed alongside it for the analyst. No new coverage gate was added, so a
   donor-like map is not blocked by an extra metric.

Runtime print (adds no gate, just makes the calibration visible):

```
gates @320x320 (s=2.00, area x4.00): donor stamps 115..236, patches 40..90, mean_sz 170..1228, forest coverage 15..48%
```

`patch_gates(160,160) = (10, 22, 174, 1228)` and `patch_gates(128,128) =
(6, 14, 175, 1310)` — the helper is size-general, not a hard-coded 320 pair.

## 3. Exact diff (`git diff -- app/tools/scan_map.py`)

Three edits (full unified diff reproduced in the report channel; summary):

- module docstring: replace `patches - 8..16 discrete forest belts, mean size
  40..120 tiles` with a pointer to `patch_gates()` and the 320 derived values;
- add `STAMPS_320`, `MERGE_PER_PATCH`, `COVER_BAND`, `REF_AREA` constants and
  `patch_gates(w, h)` after `NB`;
- `scan_one()` returns `map_h` as well as `map_w`;
- `main()` computes/prints the gates once and uses them in the two gate
  comparisons, replacing the literal `8..16` and the `40/120 × s² × 0.6/1.6`
  band.

**Unchanged:** water/mask, purity, clearance, sand ring, cliff ring, tileflow,
reachability (including `reach_radius()`'s 25→50 scaling), and all metric
functions. No other gate was relaxed.

## 4. Before / after scan on the named dumps

Command (Python only; copies of the four dumps collected in a temp dir):

```
python -m py_compile app/tools/scan_map.py
python app/tools/scan_map.py --dir <temp>/t2qa_scans
```

Dumps: `app/shots/full_map_dump.json` (pre-GEN baseline, seed 20261113) and
`scans/t2gen/L_7.json`, `L_8.json`, `L_9.json` — the products of runner jobs
`t2gen-verify7e` (ticket 806), `t2gen-final8b` (808), `t2gen-final9b` (810).

| dump | forest `dark` | patches | mean_sz | BEFORE (8–16 / 96–768) | AFTER (40–90 / 170–1228) |
|---|---:|---:|---:|---|---|
| `full_map_dump.json` (baseline) | 0.9 % | 10 | 96 | **ALL GREEN** | **FAIL** `patches=10,mean_sz=96` |
| `L_7.json` (seed 7) | 5.1 % | 16 | 325 | **ALL GREEN** | **FAIL** `patches=16` |
| `L_8.json` (seed 8) | 5.7 % | 9 | 645 | **ALL GREEN** | **FAIL** `patches=9` |
| `L_9.json` (seed 9) | 5.7 % | 12 | 483 | **ALL GREEN** | **FAIL** `patches=12` |

All other gates remained green in both passes: `coast` 99–100 %, `cliff`
99–100 %, `tileflow` 100 %, `reach` 4/4, purity/clearance 100. Water matched
the mask on all four (seed 7's 10.6 % vs 10 % mask is within ±5 pp).

**Honest reading:** the new mean-size band *does* admit the improved stands
(325/645/483 all sit inside 170–1228), and the baseline's 96-cell flecks are
now correctly rejected. But the GEN dumps still have only 9–16 forest
components, far below the donor-derived 40–90, because the generator merges
many stamps into a few large belts. Coverage 5.1–5.7 % is also still well
below the donor 15–48 % band. **This is expected: T2-BUILD-GEN's change is a
large improvement over 0.9 % but is not yet donor-like, so the calibrated gate
correctly stays red.** The gate now measures the gap instead of hiding it.

## 5. Degenerate-case regression (new gate still catches bad maps)

Three synthetic 320×320 dumps were generated (Python, no Godot) and scanned:

| case | patches | mean_sz | result |
|---|---:|---:|---|
| zero forest | 0 | 0 | FAIL `patches=0,mean_sz=0` |
| uniform moss (one 67,200-cell rectangle, 65.6 % cover) | 1 | 67,200 | FAIL `patches=1,mean_sz=67200` |
| checkerboard (1,600 four-cell flecks, 6.2 % cover) | 1600 | 4 | FAIL `patches=1600,mean_sz=4` |

All three are rejected by the patch/mean gates alone, on **both** axes. The
old gate also happened to reject them (`patches=1/0` and `mean=4` were outside
8–16 / 96–768), so this is a no-regression check rather than a new capability.
The gate's actual defect was the opposite: it passed the 0.9 %-coverage
baseline and capped achievable coverage at 12 %, while a donor-like 15–48 %
map with 40–90 patches could never be green. The new band fixes that without
losing the degenerate-case detections.

## 6. Residual conflicts / open items

1. **Current GEN dumps are red on patch count.** That is a real generator
   gap (9–16 components vs 40–90), not a calibration error. T2-BUILD-GEN
   should either increase the number of separate stands or accept that the
   scan gate stays red until coverage approaches 15 %.
2. **Coverage is not directly gated.** A map with 90 patches × 170 mean sits
   at 14.9 % and passes, just under the 15 % floor. Adding a `dark >= 15`
   gate would close that corner but is outside this ticket's scope ("update
   the patch-count and mean-size gates"; all other gates unchanged).
3. **Trees/MP (650–1000) is not measured by this tool.** The dump carries
   terrain codes, not tree counts; TS-1's band must be verified by
   `full_map_shot.py`-style census or a render, not by `scan_map.py`.
4. **Donor placement success (50–70 %) is an assumption**
   (`map_density.md:180-182`), so the 15–48 % band and hence the derived gates
   inherit that UNVERIFIED assumption. The 2.6–2.9 merge bracket is derived
   from the port's own 160 baseline, not from a donor map.
5. The backup `inbox/backup/scan_map.py.bak-T2QA` is the pre-edit file; no
   rollback was needed.
