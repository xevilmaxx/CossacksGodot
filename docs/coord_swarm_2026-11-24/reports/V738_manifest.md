# V7-38 — Variant manifest registration report (2026-11-24, updated follow-up)

## Owned files
- `variant3d/tests/manifest.json`
- `docs/coord_swarm_2026-11-24/reports/V738_manifest.md` (this file)

No Godot runs (not required). No test files edited.

## Correction to earlier state
The initial V7-38 audit found none of the 7 atomic test files on disk and
registered zero entries. Independent supervision V7-41 found all 7 now exist.
Re-audit confirms this: all seven `.gd` files are present in `variant3d/tests/`.
The manifest has now been updated accordingly.

## Audit of `variant3d/tests/`
Present and registered (7):
- `t_terrain3d.gd` -> `t_terrain3d`
- `t_camera3d.gd` -> `t_camera3d`
- `t_pick3d.gd` -> `t_pick3d`
- `t_entities3d.gd` -> `t_entities3d`
- `t_fx3d.gd` -> `t_fx3d`
- `t_fog3d.gd` -> `t_fog3d`
- `t_render_mode.gd` -> `t_render_mode`

Pending (absent from disk, NOT registered): none of the 7 contract atoms.

## Registered ids (appended LAST to `tests[]`, in contract order)
1. `t_terrain3d` — owner `V7-31`, timeout 90
2. `t_camera3d` — owner `V7-32`, timeout 90
3. `t_pick3d` — owner `T-PICK3D`, timeout 60
4. `t_entities3d` — owner `V7-34`, timeout 90
5. `t_fx3d` — owner `V7-35`, timeout 60
6. `t_fog3d` — owner `V7-36`, timeout 60
7. `t_render_mode` — owner `V7-37`, timeout 60

Each entry uses the manifest's exact schema keys: `id`, `path`, `feature`,
`status`, `owner`, `timeout` (no `windowed` needed — all are headless). Paths
are `res://tests/<name>.gd`. All 24 inherited 2D entries are preserved
byte-for-byte as the first 24 elements; the 29/29 + 17/17 2D baselines remain
covered. Total entries: 31 (24 inherited + 7 atomic), all ids unique.

## Verification (no Godot runs)
```
python -c "import json; json.load(open('variant3d/tests/manifest.json'))"
```
Result: **VALID JSON** — `version` 1, 31 tests, no exceptions.

Additional programmatic checks:
- 24-entry 2D prefix unchanged: **True**
- New ids: all 7 present, in order: **True**
- Ids unique: **True**
- Every new `path` resolves to an existing file on disk: **True**
- Schema keys used by new entries: `feature, id, owner, path, status, timeout`

## Expected failure note
Disk inspection shows `camera3d.gd`, `picking3d.gd`, `world3d_terrain.gd`,
`world3d_fx.gd`, `world3d_fog.gd` present, but `world3d_entities.gd` absent and
`main.gd` has no `render_mode` / `make_world3d` / `make_camera3d` seam yet.
So `t_entities3d` and `t_render_mode` are expected to fail with
`MODULE_MISSING` / `SEAM_MISSING` until those land. This is expected during the
port. Do NOT "fix" by removing or weakening assertions in any test file —
assertions must remain so the tests actually validate the modules once they
exist. No pass/fail is claimed here because no Godot run was performed.
