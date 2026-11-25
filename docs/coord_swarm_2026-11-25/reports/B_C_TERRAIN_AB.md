---
id: B-C-TERRAIN-AB
title: "Dump-only tile-boundary provenance added to world3d_terrain.gd (stats-exposed), with not_done note — no render-path change"
agent: "B-C-TERRAIN-AB (terrain-gd builder), coord swarm 2026-11-25"
date: 2026-11-25
status: DELIVERED__ONE_PARSE_VALIDATION__NO_PARITY_CLAIM
scope: "Exactly two files written: variant3d/scripts/world3d_terrain.gd and this report. Shader, game.gd, pattern_gen.gd, config untouched; app/ never touched; no donor binary access; no git operation."
exclusive_output: "docs/coord_swarm_2026-11-25/reports/B_C_TERRAIN_AB.md"
owned_code_file: "variant3d/scripts/world3d_terrain.gd"
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
labels: [observed, derived]
parity_guard: "PORT APPROXIMATION — internal consistency only. No donor GPU A/B frame exists; no donor parity is claimed."
---

# B-C-TERRAIN-AB — dump-only provenance, stats-only exposure

## 0. Mandate and boundary

- Governing briefs: `Z3_VISUAL_BLEED.md §5.1/§5.3` ("terrain-gd owner: dump-only neighbour/direction provenance around `:959-993` + stats note near `:1445-1458`; bind the A/B uniform only if A published its name") and `MAPGEN_RECON_01.md §5 P0-3` ("mirror full-grid tables LATER; this ticket provenance-only, footprint stays 10×8").
- **Shader owner (A) is NOT yet dispatched** → no uniform was bound. No `ALPHA`, mask, sampler, patch-rule, floor, art or donor claim was added.
- Invariants preserved: 1 surface, `w*h` verts, `(w-1)*(h-1)*2` tris, `UV2.x=tid` / `UV2.y=face`, atlas `(16,8)`, face_hist contract, shadow OFF, water/light/sim untouched. Footprint stays 10×8 (no `RELIEF_COARSE_*` edit). No sampling change.
- **Concurrent-work note (observed):** a final `git diff --name-only` also lists `variant3d/config.json`, `variant3d/scripts/config.gd` and `variant3d/scripts/pattern_gen.gd`. Those edits belong to other builders running in parallel and were **not** made by this ticket; this agent's only code edit is the `world3d_terrain.gd` diff in §2 (75+/1-).

## 1. Backup evidence (before edit, verified)

| Field | Value |
|---|---|
| Source | `variant3d/scripts/world3d_terrain.gd` |
| Backup | `inbox/backup/world3d_terrain.gd.bak-BCTERRAIN` |
| Source SHA-256 | `9678811A1690527FC3CFF7385C7C7B2506F3AE732E2C0D1741314179AF6C3CEA` |
| Backup SHA-256 | `9678811A1690527FC3CFF7385C7C7B2506F3AE732E2C0D1741314179AF6C3CEA` |
| Bytes (src / bak) | 80,505 / 80,505 |
| Result | **MATCH: True** (copy created and hash/size verified before first edit) |

## 2. Exact diff (additive-only; 75 insertions, 1 deletion)

`git --no-pager diff -- variant3d/scripts/world3d_terrain.gd` → `1 file changed, 75 insertions(+), 1 deletion(-)`. The single deletion is the line replaced by the 6-line `not_done` block (existing items kept verbatim). Six additive hunks:

1. **`:185-188`** — new constant `TILE_PROV_MAX: int = 8192`, a debug/stat cap on the `per_cell` dict only. Comment states it bounds neither mesh, UV2, water nor sampling; labelled PORT APPROXIMATION / diagnostic, not a donor value.
2. **`:329-333`** — three class vars: `_tile_prov: Dictionary`, `_tile_prov_cells: int`, `_tile_prov_dir_hist: Dictionary`. Comment: "DUMP-ONLY per-cell tile provenance (diagnostic; NEVER fed back into UV2 / mesh / water / light / sim)".
3. **`:1008-1050`** — appended to the end of `_decode_tile_indices()` (after the existing histogram loop). Scans all `w*h` cells; for each cell reads centre tid + 4 axis neighbours with the same clamped-edge stencil as `_face_mode_at()` (`:746-768`). Builds a 4-bit `mask` (bit0 left, bit1 right, bit2 top, bit3 bottom) of neighbours whose tid differs from the centre. Cells with `mask == 0` are skipped (no boundary to score). For boundary cells: increments `_tile_prov_dir_hist[str(dir)]`, increments `_tile_prov_cells`, and while `_tile_prov_cells < TILE_PROV_MAX` stores `_tile_prov[str(i)] = {"tid": c, "nb": [nl,nr,nt,nb], "mask": mask, "dir": dir}`. `dir` is a derived axis code (`3` both axes / `1` X-only / `2` Z-only) — no donor rule inferred.
4. **`:1204-1207`** — `invalidate()` resets the three prov vars so a rebuild cannot stack stale provenance (mirrors `_relief_applied = []`). No mesh state.
5. **`:1513-1517`** — `stats.relief_grid.not_done` extended by one appended item: `"tile->patch boundary-direction rule (dump-only prov added; donor rule UNVERIFIED)"`. The four pre-existing items (`full 26-grid float32 tables`, `mountain terrainmesh props`, `exact donor engine blend`, `2x collision sampler`) are **kept verbatim**, so the full-grid / props / engine-blend note from the brief remains `not_done`.
6. **`:1519-1531`** — new `stats.prov` key: `label` (PORT APPROXIMATION, dump-only, no donor rule), `source`, `dir_codes`, `cells_scanned = w*h`, `boundary_cells = _tile_prov_cells`, `dir_hist`, `per_cell_cap`, `per_cell = _tile_prov.duplicate(true)`, `fed_back_into_render = false`.

### 2.1 What the new data is / is not

- **observed** — neighbour tids come solely from `_tile_indices` (decoded `tileblock` uint8, same source as `UV2.x`); direction is derived from tid discontinuity only. `height[]` is not read by the new code (the brief's `height` source at `:746-768` is used by `_face_mode_at` for face mode, which is unchanged).
- **derived** — `dir` codes are a port-side axis classification, not a donor patch index; they are diagnostic stand-ins for a future patch-rule A/B, explicitly labelled UNVERIFIED in `not_done` and in the `prov.label`.
- **not done here** — no per-cell export to disk, no shader uniform, no `stats.relief_grid` footprint change, no sampling or mesh edit. The `per_cell` dict is exposed only through the in-memory `stats` dictionary.

## 3. Targeted validation (ONE job, variant runner only)

| Field | Value |
|---|---|
| Ticket | **571** |
| Job id | `bcterrain-parse` |
| Command | `python variant3d/tools/godot_runner.py run --id bcterrain-parse --timeout 180 --max-wait 1800 -- --headless --path variant3d --check-only --script res://scripts/world3d_terrain.gd` |
| Queue at submit | `pending=0`, `godot.lock=free` (no wait; no WAIT needed) |
| Status / wait / run | **`ok`** / `0.0010 s` / `5.020 s` |
| **Exit** | **`0`** |
| stdout | 75 bytes — Godot 4.7.2 banner only |
| stderr | **0 bytes** ⇒ **`SCRIPT ERROR == 0`** |
| Artifacts | `variant3d/.godot_queue/results/00000571.json`, `.../00000571_bcterrain-parse/{stdout,stderr}.txt` |

`--check-only` parses/compiles the edited script; it executes no game frame and captures no image. Per governance this is the single allowed targeted validation — **no full gate, no ladder, no windowed capture** (verifier C owns capture). No donor parity is asserted: the job proves parse validity only.

## 4. Conformance checklist

- [x] Backup created and hash-verified before edit.
- [x] Only owned code file + this report written; `app/` never touched.
- [x] Minimal additive diff (75+/1-); no mesh/UV2/topology/water/light/sim change.
- [x] No new patch rule, sampler, floor, art or donor claim; `dir` code labelled PORT APPROXIMATION / UNVERIFIED.
- [x] Existing `PORT APPROXIMATION` labels retained; new labels added in the same style.
- [x] Provenance dump-only, stats-exposed, never fed back into UV2/mesh/water.
- [x] `not_done` list extended (existing wording kept); footprint stays 10×8.
- [x] No uniform binding (shader owner not dispatched).
- [x] Exactly one runner job (`bcterrain-parse`), `ok` / exit 0 / `SCRIPT ERROR 0`.
- [x] No parity claim anywhere.

## 5. Handoff / open items (not this ticket)

- Shader owner A must publish the exact `mask_to_alpha` A/B uniform name before any binding is attempted; B binds by name only after that publication.
- Mirror of full 26-grid float32 tables + scaled donor footprint remains `P0-3 LATER` (owner: this file + shader), explicitly still listed under `stats.relief_grid.not_done`.
- Verifier C owns the identical-camera windowed capture and pixel measurement; no capture was done here.

---

*End of B-C-TERRAIN-AB. One code file + one report; one parse job (ticket 571, exit 0, SCRIPT ERROR 0); PORT APPROXIMATION throughout; no donor parity claim.*
