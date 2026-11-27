# PORT1TO1 — GEN-GAPS: static probe of 7 NEW generation gaps

- id: PORT1TO1-gen-gaps-2026-11-27
- worker: GEN-GAPS (read-only static probe, generation/terrain)
- date: 2026-11-27
- source: `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_review_gen.md` §3 (G-NEW-1..G-NEW-7)
- method: read-only file-existence + content checks of the live tree. No code/Godot/git/donor execution. No gate run.
- parity: **UNVERIFIED. No approximations. No parity claim.**
- chain: **0/6. `blocking_unverified` non-empty ⇒ RESULT IS NOT GOOD.**
- output: exactly one file (this report); no other edits.

## Honest verdict (read first)

Parity is UNVERIFIED for every gap below. Presence on disk is existence only — never correctness, never a gate PASS, never donor fidelity. No bridge/scale/chain value is invented here; no port behaviour is wired; completeness/parity is NOT declared. Static evidence narrows only.

## G-NEW-1 — Bridge generation: genuinely ABSENT (constants only, not under another name/path)

- Donor element (read-only cite): `_misc_CreateBridge` (`misc.script:5271-5346`): `cScale=1.15`, `cBaseHeightOffset=0.4876`, block width `2.81*scale`, end widths `1.78*scale`, offsets `1.07*scale`, collision radius 3, step 2, tag 10; water-border radius `gc_WaterBorderSize=3` (`dmscript.global:819`); `fordtyp` is a squad formation field, not a ford generator. Byte-proven donor-text record: `docs/terrain_swarm_2026-11-26/reports/D06_water_shore.md:23` `[O]`; `docs/terrain_swarm_2026-11-26/spec/05_WATER_SHORE.md:66-73` `[O]`; evidence ids `ev_7bf36259e8e006453e403f0bb9404918e2e706ff3bd25fbb3992c737529f6ab6` (`misc.script:5271-5346`) and `ev_57b8cb760afa6ef7995a869a21d8a6ff292e74934701914caac6367a2c803a57` (`dmscript.global:818-822`) at `D06_water_shore.md:84-86`.
- Road/ford companion: donor road branch `D4:622-636` broad/fa absent in shipped 24-bit TGAs — recorded in-port at `variant3d/scripts/terrain_donor_gen.gd:1898` `[U]` label; no ford-generation rule found in `data/**` `[U]` (`D06_water_shore.md:23,361`).
- Port state: ABSENT as an implementation. Only tag/radius constants exist:
  - `[O]` `variant3d/scripts/terrain_donor_gen.gd:164` `const C_TAG_BRIDGE: int = 10  # gc_collisiontag_bridge; D06:146,352`
  - `[O]` `variant3d/scripts/terrain_donor_gen.gd:167` `const C_WATERBORDER_RAD: int = 3  # gc_WaterBorderSize, dmscript.global:819; D06:146`
  - `[O]` `variant3d/scripts/terrain_donor_gen.gd:2421-2422` `func _shore_collision_ring` uses `C_WATERBORDER_RAD` (`var rad: int = C_WATERBORDER_RAD  # gc_WaterBorderSize=3`)
- Present-under-a-different-name check (negative): grep `CreateBridge|SetupBorder|fordtyp` in `variant3d/scripts/terrain_donor_gen.gd` → zero matches (only the two constants above via `C_TAG_BRIDGE|C_WATERBORDER_RAD`); grep `bridge|Bridge|road|Road` in `variant3d/scripts/terrain_donor_props.gd` → one false positive only (`terrain_donor_props.gd:1102` word "broad" in relief-geometry comment), no bridge/road builder; `variant3d/scripts/testbridge.gd:1-9` is a test-only localhost TCP remote-control bridge, not a terrain bridge — name collision ruled out by read. Stage list has no bridge stage (`PORT1TO1_review_gen.md:38-39` cites `generate` `:816`, stage calls `:887-904`); `_stage_owner_map` (`terrain_donor_gen.gd:3661`) covers owner fill only.
- `[U]` remains with exact termination: runtime proof that a bridge builder exists and paints tag-10 collision + topology refresh per `misc.script:5271-5346` with zero-mismatch on all eight constants + tag/radius; terminates only on an OWNER-GPU-RUNTIME probe observing a built bridge on a qualifying seed, or a signed scope ruling. Static part needs nothing further.

## G-NEW-2 — Mine corner relocation: PRESENT as code, runtime UNVERIFIED (not double-counted)

- Donor element (read-only cite): D1:658-702 far-ring corner relocation (v>=90, big map, i=2, sp<=4) → corners `±(maphW-24)` centred coords (`PORT1TO1_review_gen.md:92`).
- Port state: IMPLEMENTED (code) / runtime UNVERIFIED — present at its own name/path, not elsewhere:
  - `[O]` `variant3d/scripts/terrain_donor_gen.gd:2702-2713` `func _mine_centre(start: Vector2, i: int) -> Vector2` — gate `i == 2 and spcount <= 4 and mapsize_gt2 and version >= 90` (`:2703`), half-size computation (`:2704-2707`), centred→grid conversion comment citing D1:667-689 + V08 + V58 (`:2708-2710`), mapping `+corner → W-24, -corner → 24` (`:2711-2712`), else `return start` (`:2713`)
  - `[O]` call-site `variant3d/scripts/terrain_donor_gen.gd:2564-2565` — comment `D1:658-702 far-ring corner relocation (v>=90, big, i=2, sp<=4)` + `var centre: Vector2 = _mine_centre(...)`
  - `[O]` surrounding mine-placement context re-verified this pass: `func _setup_mines` (`:2535`), `C_TRYCOUNT_MINES=256` (`:271`), ring/round + per-attempt order cite P-PLACE-08 (`:2549-2553`), `_mine_band`/`_band_id` (`:2589-2598` ff), gap-reproduce telemetry `ring2_dst_mode` (`:2579-2581`)
- `[U]` remains with exact termination: observed corner relocation ON across the v90 boundary on a qualifying seed (big map, i=2, sp<=4) vs OFF below it, with exact ±24-cell corners and no second W/2 (V58); terminates only on that OWNER-GPU-RUNTIME probe. Static part needs nothing.

## G-NEW-3 — Object-scale 3-branch application: PARTIAL, skip is explicit (constant + record present, application absent)

- Donor element (read-only cite): `dogenerate.inc:1990-2021` three branches — 5% dead-band scale jitter, skip terrainmesh/stones, winter `leaftree` delete; spec rows `docs/terrain_swarm_2026-11-26/spec/10_STAGE_ORDER.md:54` (`Props | scale jitter, winter leaftree delete (D1:1914–2027, :1984–1985, :1975–1982) | missing`), `docs/terrain_swarm_2026-11-26/spec/00_EVIDENCE_INDEX.md:219` (`D1:1984-1985 winter leaftree delete; D1:1998 scale dead-band 0.05` `[O]`).
- Port state: PARTIAL — constant + per-record field present, application explicitly skipped:
  - `[O]` `variant3d/scripts/terrain_donor_gen.gd:284` `const C_SCALE_DEADBAND: float = 0.05  # dogenerate.inc:1998; X03:977`
  - `[O]` `variant3d/scripts/terrain_donor_gen.gd:3639-3643` hook branch writes `e["scale_jitter"] = r  # D1:1990-2021, dead-band 0.05`
  - `[O]` `variant3d/scripts/terrain_donor_gen.gd:3644-3651` explicit NULL skip: `_note("object scale jitter skipped: separate object RNG [U] D1:1990-2021; future hook must also skip terrainmesh/stones and delete leaftree in winter (TODO D01/D07)", "unverified")` (`:3648`) + N17-G16 trace rule requiring zero RNG draws and all three branches together (`:3649-3651`)
- `[U]` remains with exact termination: the separate object-scale jitter RNG stream (spec/02 §3 stream-2 family) plus both companion branches (terrainmesh/stone skip, winter leaftree delete) applied together per in-file rule `:3650-3651`; terminates only on an OWNER-GPU-RUNTIME hook demonstration with all three branches together and zero-mismatch (jitter-only partial application forbidden). No value invented here.

## G-NEW-4 — `tile_smooth_chains` consumer/producer wiring: PARTIAL, end-to-end flow UNPROVEN

- Donor element (read-only cite): tile smoothing 3-pass H-then-V sweep (`smoothtiles.inc:191-237`); weighted chains from `tilesmooth_scripts.cfg` (22 chains / 130 groups / 310 entries, spec/09 §1); script-over-cfg rule (spec/09 §4: script 3 wins for skirmish).
- Port consumer (present): `[O]` `variant3d/scripts/terrain_donor_gen.gd:810` param contract `tile_smooth_chains : Array[Array[Array[Dictionary]]] (I01 decoder)`; `[O]` `:1883` `var chains: Array = p.get("tile_smooth_chains", [])`; `[O]` `:1886-1887` skip note `tile_smooth_chains absent — tile smoothing skipped; TODO(I01) decoder`; `[O]` `:1933-1934` `if not chains.is_empty() ...: _smooth_tiles(data, chains, id_of, name_of, TILE_SMOOTH_PASSES)`; `[O]` `func _smooth_tiles` (`:2266`) with H-pass `:2274-2286` / V-pass `:2287-2298` and `TILE_SMOOTH_PASSES=3` (`:245`, cites `smoothtiles.inc:237` + preserved cfg-6 contradiction); `[O]` `func _neighbour_tiles` (`:2304`) chain-walk logic.
- Port producer (present): `[O]` `variant3d/tools/decode_donor_cfg.py:480-503` self-checks C06 (22 chains), C07 (130 groups), C09/C11 entries; `[D]` decoder emits `constants.json` + `config_strings.json` only (`decode_donor_cfg.py:13-14,741,874-875`) — the literal string `tile_smooth_chains` does NOT occur in that file (verified by grep this pass).
- Port bridge (present, unproven end-to-end): `[O]` `variant3d/scripts/terrain_donor_inputs.gd:828-843` `func _valid_tile_smooth_chains` shape validator; `[O]` `:912-914` canonical `tile_smooth_chains` passthrough; `[O]` `:918-928` `TileSmoothLists/` structural-path rebuild buffers (`stat_names`/`stat_probs`); `[O]` `:970-985` direct-table validation + load label; `[O]` `:986-1027` rebuild path (completeness gate `:986-993`, donor-order chain build `:995-1012`, 22-slot census preserve `:1013-1017`, load label citing `tilesmooth_scripts.cfg:1-1863`); `[O]` `:1028-1029` fail-closed skip `tile_smooth_chains not emitted [U] — tile smoothing stays skipped, no invented table`.
- `[U]` remains with exact termination: proof that a decoded `constants.json` flows caller→`terrain_donor_inputs`→`terrain_donor_gen._smooth_tiles` as a non-empty `Array[Array[Array[Dictionary]]]` matching `:810` with zero skipped notes (`tile_smooth_pairs` counted, no silent skip, no cfg-6 confusion); terminates only on a WORKER-EXECUTABLE-STATIC emit→consume shape proof on one decoded cfg plus an OWNER-GPU-RUNTIME smoothed-tile gate run. Nothing is wired or asserted here.

## G-NEW-5 — Editor UI→cfg mapping: genuinely ABSENT (no file found)

- Donor element (read-only cite): D09 editor binary + F09 editor script → UI controls bound to `globalparams.cfg`/`localparams.cfg` keys; `[D]` consequence `docs/terrain_swarm_2026-11-26/spec/09_EDITOR_PARAMETERS.md:68-72`: "`decode_donor_cfg.py` (I01) must emit `constants.json` ... The editor-parameter mapping (D09) should map UI controls to these keys."
- Port state: ABSENT — glob `variant3d/scripts/*editor*` → no files found; glob `variant3d/tools/*editor*` → no files found (verified this pass). Nearest text matches are unrelated: `config.gd:653` (cossacks.ini/editor.ini comment), `camera3d.gd:4` (Godot editor import comment), `game.gd` peacemode/scenario-editor comments, `decode_donor_masks.py:563` ("editor authoring"), `convert_models.py:910` ("no Godot editor"). `brush_plt_*` family data in gen (`terrain_donor_gen.gd:336-339,443`) is family data, not editor bindings; `decode_donor_cfg.py` decodes literals only; `terrain_donor_inputs.gd` handles masks/patterns/compact bundles only.
- `[U]` remains with exact termination: a control→key ledger row per binding (all `[U]` until captured) with a PRESENT mapping file, or a signed out-of-scope ruling with link; terminates only on mapping-file-PRESENT or ruled-absent-with-link. No binding invented here.

## G-NEW-6 — Legacy `terrain_tileindex.gdshader`: PRESENT on disk, prior-audit inventory absent

- File-existence check (verified this pass): `[O]` `variant3d/shaders/terrain_tileindex.gdshader` PRESENT (read `:1-30`: header cites `TERRAIN2_06_tileindex_architecture.md`, `TERRAIN2_01_donor_pipeline.md`, donor root note, per-cell integer tile index `TMapTerrainDataTile.tex` `dmscript.global:2026-2035`, `gc_meters_to_tile=2` `dmscript.global:171`, `BlendingMode = bmTransparency` `reftile.mat:17`, PORT APPROXIMATION labels). Sibling `variant3d/shaders/terrain_tileindex.gdshader.uid` PRESENT.
- Donor-cite lines inside the file (read-only): `[O]` `:14-16` donor path:line rule; `[O]` `:27` `BlendingMode = bmTransparency` (`reftile.mat:17; reftilealpha.mat:17`).
- Inventory gap: named in neither completeness §5 (which inventories only the I10 `terrain_donor_shader.gdshader`) nor the gap-packet tool/shader lists, per `PORT1TO1_review_gen.md:121`.
- `[U]` remains with exact termination: one-line containment ledger (loader + backend-gate cite proving unreachable when `terrain_backend=="donor"`, per spec/14 P01 legacy-coexistence rule); terminates only on that recorded reachability row. No shader edit, no donor-proof citation of the legacy path.

## G-NEW-7 — Legacy tool per-file dispositions: files PRESENT, disposition ledger absent

- File-existence checks (verified this pass via `variant3d/tools/*.py` glob — all PRESENT):
  - `[O]` `variant3d/tools/build_tile_index_atlas.py` PRESENT
  - `[O]` `variant3d/tools/build_winter_atlas.py` PRESENT
  - `[O]` `variant3d/tools/donor_gen.py` PRESENT (stops at the `w*h` occupancy prefix `:74-85`, synthesises the rest — P04 F1/F2, per review `:129`)
  - `[O]` `variant3d/tools/gen_variant_maps.py` PRESENT
  - `[O]` `variant3d/tools/heightmap_splat.py` PRESENT
  - `[O]` `variant3d/tools/scan_map.py` PRESENT
  - `[O]` `variant3d/tools/import_donor_map.py` PRESENT (zero tileblock placeholder `:450,462-465`)
  - `[O]` `variant3d/scripts/tile_atlas_loader.gd` PRESENT (three atlas modes + overrides)
- Disposition source (read-only): `[D]` `docs/terrain_swarm_2026-11-26/spec/11_ASSET_CONVERSION.md:75-94` §11.7 table — `import_donor_map.py` KEEP/PORT LOGIC, `import_donor_masks.py` KEEP/EXTEND, `donor_gen.py`/`gen_variant_maps.py` DO NOT PORT, `export_donor_patterns.py` KEEP cross-check, `build_tile_index_atlas.py` KEEP `--check`, `heightmap_splat.py` KEEP dump reader, `convert_models.py` KEEP readers, `scan_map.py` EXTEND, `parse_terrain.py`/`extract_map.py`/`build_missions.py`/`compute_ortho.py`/`t6_registry.py` RETIRE, `pieces/t6_*.py` + `piece_specs/*.json` KEEP as QA fixtures.
- Missing half: no port-side per-file disposition ledger carrying these §11.7 rows (including the `import_donor_map.py` zero-tileblock caveat for `.map` work, D04-owned) was found; gap packet names only six importer tools without these seven.
- `[U]` remains with exact termination: per-tool disposition ledger rows (KEEP/PORT/DO-NOT-PORT/RETIRE + caveats) recorded read-only; `app/tools/**` mirror stays byte-untouched; terminates only on that ledger. `donor_gen.py` is never cited as a compiler and zero-tileblock dumps are never cited as tile truth.

## Blocking / close-out

- `blocking_unverified` (all 7 non-empty): G-NEW-1 bridge runtime probe; G-NEW-2 v90 corner probe; G-NEW-3 3-branch hook probe; G-NEW-4 emit→consume shape proof + gate run; G-NEW-5 mapping PRESENT-or-ruled-absent; G-NEW-6 containment row; G-NEW-7 disposition ledger.
- Chain **0/6**; **RESULT IS NOT GOOD** while `blocking_unverified` is non-empty.
- Parity **UNVERIFIED** for every element above. No approximations, no parity claim. Read-only; exactly one file written (this report).

*End of report. Parity UNVERIFIED. Chain 0/6, RESULT IS NOT GOOD while `blocking_unverified` is non-empty.*
