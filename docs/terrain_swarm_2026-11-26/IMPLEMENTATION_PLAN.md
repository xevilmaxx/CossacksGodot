# Implementation wave — prepared ticket board (COORD)

Do **not** start these until the cited spec sections are marked READY. Every
implementation worker gets one owner file (or one disjoint new file) and must
back up anything it edits to `inbox/backup/<file>.bak-<TICKET>`.

| Ticket | New / owned file(s) | Depends on spec | Work |
|---|---|---|---|
| I01 | `variant3d/tools/decode_donor_cfg.py` | §09, §11 | Emit `terrain_new/cfg/constants.json` + `config_strings.json`, each value with donor path:line; dry-run default |
| I02 | `variant3d/tools/decode_donor_pattern.py` | §04, §11 | Decode `.pattern` occupancy + float grid + object tail (only decoded fields; `null`+UNVERIFIED otherwise) |
| I03 | `variant3d/tools/decode_pattern_lib.py` | §04, §11 | Enumerate `pattern.lib` records, family index, weights, blend flags |
| I04 | `variant3d/tools/decode_donor_masks.py` | §03, §11 | TGA → height tiles + start dots + water/forest channels, deterministic shas |
| I05 | `variant3d/tools/build_terrain_new_atlas.py` | §06, §11 | Commit-safe atlas tier + alpha masks + winter aliases; mip fix per B02 |
| I06 | `variant3d/scripts/terrain_donor_data.gd` | §01 | SoA container + additive dump `fields` contract; no legacy edit |
| I07 | `variant3d/scripts/terrain_donor_gen.gd` | §02, §03, §04, §05, §07, §10 | Stage pipeline with per-stage RNG ledger; emits I06 container |
| I08 | `variant3d/scripts/terrain_donor_mesh.gd` | §01, §06 | One ArrayMesh, height→Y, normals, UV2=(tex,face), water bind; no art hacks |
| I09 | `variant3d/scripts/terrain_donor_props.gd` | §08 | Instanced relief props, forests, stones, mines, mill fields, shore rocks |
| I10 | `variant3d/scripts/terrain_donor_shader.gdshader` (only if needed) | §06, §05 | Donor tile/alpha/water semantics; no invented constants |
| I11 | `variant3d/scripts/world3d.gd` (seam only) | §12 | `terrain_backend` switch: legacy default, new opt-in; additive |
| I12 | `variant3d/tests/t_terrain_donor.gd` | §12 | Determinism + telemetry gate; registers in manifest LAST |
| I13 | QA/capture by COORD | §12 | Gates + fresh 240²/320² capture + honest verdict |

## Non-negotiable invariants

- `app/**` byte-identical; variant selftest 29/29, uitest 17/17, `t_render_mode`,
  `assert_clean` CLEAN stay green.
- Legacy `world3d_terrain.gd`, current shader, existing atlas contract untouched
  until the new backend is proven; A/B switch defaults to legacy.
- No donor binary copied/committed; only derived assets with provenance manifest.
- No synthetic noise/dither, no face promotion, no `HEIGHT_SCALE` multiplier,
  no lowered gate, no donor-parity claim without a real GPU A/B frame.
- One Godot at a time through `variant3d/tools/godot_runner.py`, unique `--id`.

## Ordering

I01–I05 (decoders/assets) → I06–I10 (runtime) → I11–I12 (integration/tests) →
I13 (gates/capture). At least 30 workers remain active across waves; finished
research workers are recycled into implementation or verification tickets.
