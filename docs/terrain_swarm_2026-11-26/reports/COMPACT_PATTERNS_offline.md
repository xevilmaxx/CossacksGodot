# COMPACT-PATTERNS — offline runtime bundle

Date: 2026-11-26  
Scope: derived `variant3d/assets/terrain_new/patterns/compact/` data and builder.

## Result

The compact bundle preserves all runtime-consumed pattern/family data while
removing unused object records, collision tails, census metadata and line offsets.

| Metric | Source corpus | Compact |
|---|---:|---:|
| Family index | 55,507,231 B | included in `families.json` |
| 64 family files | 46,555,804 B | included in `families.json` |
| 710 pattern files | 136,161,127 B | included in `patterns.json` |
| Total | **238,224,162 B** | **7,525,961 B** |
| Reduction | — | **96.841%** |

Output files:

- `compact/manifest.json`
- `compact/families.json`
- `compact/patterns.json`

## Preserved data

- Family order and `family/output/pattern_count` metadata.
- Ordered pattern name/frequency pairs.
- Pattern `name`, `w`, `h`, `relief_float_grid`, `flags`, `grid_offset`,
  `grid_layout`, optional canonical `grid`, and `occupancy_cells`.
- Exact JSON numeric values and array lengths.
- Null flags normalize to `{}`, matching the existing loader's default behavior.
- `match:null` entries resolve through the valid `pattern` field instead of
  producing a null-name bug.

## Explicit absences retained

Five family-referenced pattern files do not exist in the decoded corpus and are
not invented:

- `desert_mnt_14`
- `desert_mnt_15`
- `k_plain_mid_12a`
- `k_plain_mid_12b`
- `k_ravine_2` (filesystem case mismatch: `K_ravine_2.json`)

`blend_test_vectors.json` is not a terrain pattern and is excluded.

## Reproducible builder

`variant3d/tools/build_compact_patterns.py`

```powershell
python -B variant3d\tools\build_compact_patterns.py --check
python -B variant3d\tools\build_compact_patterns.py --write
```

The builder performs full JSON round-trip checks before writing. `--check` after
regeneration reports `changed_files: []` and `roundtrip: PASS`.

A local Python 3.14 read-only timing probe measured median JSON parse times of
**0.5786 s** for `patterns.json`, **0.0015 s** for `families.json`, and **0.6864 s**
for the original `family_index.json` alone. These are Python-side measurements,
not Godot timings, but they show the compact bundle is not trading parse cost for
its size reduction.

Runtime integration into `terrain_donor_inputs.gd` must retain the existing
file-based fallback and explicit missing-pattern skips. No donor binary was
executed or copied; no parity claim is made.
