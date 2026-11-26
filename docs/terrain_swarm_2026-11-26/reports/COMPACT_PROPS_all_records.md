# COMPACT-PROPS — all donor object records retained

Date: 2026-11-26  
Scope: `variant3d/` only; donor-derived JSON read-only.

## Change

The compact runtime prop feed now includes all structurally valid Objects
records instead of excluding three `style=="inline"` records to preserve the old
39,780 count.

| Metric | Before | After |
|---|---:|---:|
| Records | 39,780 | **39,783** |
| Sections with Objects | 665 | **668** |
| Families | 77 | 77 |
| Files | 78 | 78 |
| Total bytes | 11,015,153 | **11,016,176** |
| Source monolith bytes | 55,784,815 | 55,784,815 |
| Size reduction | 80.254% | **80.252%** |

Restored records:

- `fb_6` → `firsmall1`
- `fb_11` → `pinebroken2.2`
- `fb_33` → `plantain`

Only `props/props_index.json` and `props/families/fb.json` changed. The runtime
layout and schema string remain `terrain_new/props_preindex/v1`, so the existing
compact-feed consumer path is unchanged.

## Reproducible builder

`variant3d/tools/build_compact_props.py`

```powershell
python -B variant3d\tools\build_compact_props.py --check
python -B variant3d\tools\build_compact_props.py --write
```

The builder:

- reads all `Objects` records, nested and inline;
- preserves record order and `Position/Direction/Up/Scaling` X/Y/Z/W values;
- unwraps only `BaseName.value`;
- rejects missing/non-numeric/non-finite fields;
- performs a full independent round-trip comparison before writing;
- writes only changed files;
- records source index SHA-256, counts and style census.

`--check` after regeneration reports `changed_files: []` and
`roundtrip: PASS`.

No donor binary was executed or copied. No parity claim is made.
