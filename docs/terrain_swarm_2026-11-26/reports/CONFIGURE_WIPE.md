# CONFIGURE-WIPE-01 — root cause of the one-tile terrain, fix and config alignment

Date: 2026-11-27. Evidence: runner tickets 213-221. No donor execution, no new
constants, no parity claim. All code edits are backed up; preserve-only user
mods are untouched.

## 1. Symptom

`mesh.tile_array layers=1 ids=1` and `mesh.tile_id_distribution ... distinct=1
counts={0:57600}` — the whole map was painted with tile ID 0 (flat green),
even though the live game tileblock carried varied donor IDs.

## 2. Byte-proven handoff trace (print-only DEBUG diagnostics)

Added `TILE-HANDOFF-DIAG` / `TILE-ID-DIAG` to `terrain_donor_data.gd`,
`terrain_donor_world.gd` and `terrain_donor_mesh.gd` (C3Log.debug; default
level OFF, no behaviour change). Ticket 215 (`--headless`, seed 20261113):

```
data.from_live_object tileblock n=57600 distinct=14
  counts={79:51021,73:106,10:159,23:16,17:4,22:6,18:7,19:9,93:105,255:5776,98:234,97:120,74:10,20:27}
world.build gen applied=true params=17
data.after_gen tex n=57600 distinct=1 counts={0:57600}
mesh.tile_id_distribution n=57600 tex=57600 distinct=1 counts={0:57600}
mesh.tile_array layers=1 ids=1
```

So `from_live_object()` correctly loads 14 tile IDs; I07 `generate()` reduces
`tex` to a single ID.

## 3. Root cause

`terrain_donor_data.gd:configure_grid()` (lines 170-193) unconditionally
reallocates `height`, `tex` and `collision` to zero-filled arrays (178-183).
`terrain_donor_gen.gd:generate()` called `_set_size(data, wv, hv)` (line 872)
again on the already-loaded container, so the live tileblock was wiped before
the mesh handoff. No donor value, selector or RNG draw is involved — this is a
port-only handoff defect, not a donor-law question.

## 4. Fix

`terrain_donor_gen.gd` (backup `.bak-CONFIGUREWIPE`, SHA-256 of backup
`5E1601408C4F3226246E5EB2B0CCB5CE07E00FE02632C28BED3A2B5E13A4F676`):

```
var data_w: int = 0
var data_h: int = 0
if data != null:
    data_w = int(data.get("w"))
    data_h = int(data.get("h"))
if data_w != wv or data_h != hv:
    if not _set_size(data, wv, hv):
        ...abort...
```

Skip the resize only when the container is already sized to the requested
grid. `configure_grid()` itself is unchanged.

### 4.1 False positive caught and corrected

The first form used `data.get("w", 0)`; Godot `Object.get()` takes at most one
argument, so `terrain_donor_gen.gd` failed to parse (tickets 216: 3 script
errors, `Failed to load script`), I07 never ran and the mesh simply inherited
the unwiped tileblock (13 IDs). That run is **not** evidence for the fix. The
one-argument form above was substituted and re-verified with I07 live.

## 5. True verification (ticket 217, I07 active)

Command used the project-relative config path `--config config_donor_capture.json`
(under `--path variant3d`); earlier tickets used
`--config variant3d/config_donor_capture.json`, which Godot reported as
`extra settings file not found` and therefore ran on defaults. This explains
the different handoff counts (14 IDs on defaults vs 10 IDs with the real
capture config) — it is a config-path correction, not a regression.

```
world.build gen applied=true params=17
data.from_live_object tileblock n=57600 distinct=10
data.after_gen tex n=57600 distinct=19
  counts={79:55620,78:524,72:272,74:307,73:502,10:192,14:35,25:39,24:16,
          22:7,19:8,23:14,1:2,16:14,21:19,20:17,17:3,18:8,0:1}
mesh.tile_id_distribution ... distinct=19
mesh.tile_array layers=19 ids=19
parse/script errors: 0
```

I07's donor detail/smooth passes now **add** 9 IDs to the live tileblock
instead of erasing it. The 19-ID distribution is byte-identical across two
independent headless runs (tickets 218/219).

## 6. Config alignment (owner request, standing instruction)

The owner asked that `variant3d/config.json` always match the config used for
the latest visual test. Semantic diff of `config.json` vs
`config_donor_capture.json` found four differences; alignment applied with
backup `.bak-CONFIGALIGN` (original SHA-256
`223767E57B506577EAD54633708380A425A0B8AA439C8E3C28478C15C8ED44E2`):

| Key | Before | After | Reason |
|---|---|---|---|
| `features.terrain.demo_mill` | absent | `true` | match test config |
| `gameplay.start_resources.gold` | 200 | 1000 | match test config |
| `gameplay.terrain_type` | absent | `"land"` | match test config |
| `features.terrain.color_unify` | `true` | `true` (kept) | preserve-only user mod |

`features.terrain.backend = "donor"` and all `_readme` comments are untouched.
New `config.json` SHA-256:
`56B078241B880E041666060DF25C32425FDAE504127000C0F6E755E413680356`.
The only remaining semantic difference vs the test config is the preserved
`color_unify=true` calibration.

## 7. Deterministic viewport gate

`capture_sequence.py --seed 20261113 --frames 4 --step 0.25 --deterministic
--capture-ticks 32 --verify-repeat --view aligned=variant3d/config.json`
(tickets 220/221) — real windowed viewport, 1280x720, recorded config SHA-256
`56b078…`, `byte_identical=TRUE`, 0 mismatches, clean engine stderr.

Evidence: `inbox/qa/captures/configalign_seq_20261127/manifest.json` and
`.../repeat_verification.json`. A plain `--screenshot` capture differed by 19
pixels in one small sprite cluster (frame-paced, not fixed-step); the harness
fixed-step mode is the admissible port-internal repeatability gate.

## 8. Status

`parity=UNVERIFIED`. The 19-ID distribution is a port-internal byte result;
no donor GPU A/B frame or camera manifest exists, and the COORD donor
zero-mismatch ruling is still owner-gated. `RESULT IS NOT GOOD` while
`blocking_unverified` is non-empty. The three DEBUG diagnostics are retained
(print-only, level OFF by default) for future handoff tracing.
