# B-GHOST-FIX — transparent stage-0 building ghost (implemented)

- id: B-GHOST-FIX; role: implementation builder; scope: `variant3d/scripts/world3d_fx.gd` + this report ONLY.
- Owner acceptance: phantom preview must be a TRANSPARENT BUILDING, never a green quad.
- Labels: OBSERVED = read at cited path:line; DERIVED = control-flow conclusion; INFERRED = likely cause; UNVERIFIED = no evidence. No parity/gate claim.

## 1. Backup (OBSERVED)

- `inbox/backup/world3d_fx.gd.bak-BGHOST` written before any edit; both SHA256 hashes `874DEE65…F56C5FE2C` matched (byte-identical, verified via `Get-FileHash`).

## 2. Exact diff (`variant3d/scripts/world3d_fx.gd`, +116 lines, no other file edited)

1. **New state** (after `:271`): `_ghost_building: MeshInstance3D`, `_ghost_building_sid: String`, `_ghost_mesh_cache: Dictionary`, with a `PORT APPROXIMATION — NOT DONOR PARITY` header. `_ghost_mesh` (Footprint BoxMesh) retained ONLY as the no-art fallback.
2. **`draw_ghost()`** (`:590-600`): after the existing radius scale of the footprint, calls `_ghost_swap_building_mesh(s)`. SIM→world_pos subtraction (`:690-699`), validity gates (caller `world3d.gd:463-498`), GHOST_OK/FAIL tint + pulse (`:1357-1367`), GHOST_OK/BAD alpha 0.45 (`:141-142`) all byte-identical.
3. **New helpers** (after `draw_ghost`):
   - `_ghost_entities_provider()` — read-only sibling lookup via `get_parent().get("entities")` (`world3d.gd:131` var, `:604-606` siblings, `:640-641` bind). No edit to `world3d_entities.gd`.
   - `_ghost_swap_building_mesh()` — sid-change swap; building node at scale 1 (provider mesh is bbox-normalised, `world3d_entities.gd:1810-1815`); footprint hidden when art resolves, shown ONLY when no mesh (labelled fallback).
   - `_ghost_resolve_mesh()` — (1) read-only `provider.call("_stage_mesh_info", sid, "1", false)` (resolver `world3d_entities.gd:1796-1821`, suffix rule `:1782-1788`, donor `floor(progress*4)` cite carried from DBUILD_01 §2.2), then provider `_mesh_info(sid,"building")` (`:1087-1137`, instance at `:1638-1640`); (2) standalone direct-load fallback (`obj/<sid>1.obj`, `obj/<sid>.obj`, `glb/<sid>.glb`, dirs from `:84-85`) explicitly labelled unbaked PORT APPROXIMATION / UNVERIFIED (no Z-up→Y-up bake duplicated; bake lives at `:1031-1084`).
   - `_ghost_first_mesh()` — PackedScene first-mesh unwrap for the GLB fallback path.
4. **`_ensure_roots()`** (`:885-910`): `_ghost_mat.depth_draw_mode = DEPTH_DRAW_DISABLED` scoped to the ghost material only (mirrors snow/impact `:846`/`:903`); `cast_shadow OFF` on both ghost nodes; new `GhostBuildingStage0` MeshInstance3D sharing `_ghost_mat` so validity tint + pulse apply to the building mesh with zero extra wiring.

## 3. What was NOT touched (OBSERVED)

- `git diff --stat` for `world3d.gd`, `hud.gd`, `world3d_entities.gd` = empty (zero diff). `input_controller.gd` shows a 32+/18- diff owned by another worker (backup `input_controller.gd.bak-BSELFIX` on disk); none of my edits touched it (all `edit` calls targeted `world3d_fx.gd` only). SIM→world_pos, gates at `world3d.gd:463-498`, sid set at `hud.gd:1107`, handoff at `input_controller.gd:1348` unchanged.

## 4. Validation — ONE runner job (parse), no gates

- Queue was quiet before submit (`status`: spool `variant3d/.godot_queue`, `now_serving=577`, `pending=0`, `godot.lock=free`).
- Job: `python variant3d/tools/godot_runner.py run --id bghostfix-parse --timeout 120 -- --headless --path variant3d --check-only --script res://scripts/world3d_fx.gd`
- Result: ticket **577** `bghostfix-parse`, status **ok** (run 4.25 s, waited 0.00 s). `stdout.txt` = engine banner only (75 B); `stderr.txt` = **0 bytes** → SCRIPT ERROR **0**. Artifacts: `variant3d/.godot_queue/results/00000577_bghostfix-parse/`.
- Hover probe (visible=true, XZ ≤1 m of cursor SIM, building-mesh-not-BoxMesh check, screenshot) NOT run: governance allows ONE validation max (parse OR hover); parse consumed it. Hover result is **UNVERIFIED**, deferred to COORD. No selftest/uitest run.

## 5. No parity claim

- Transparent-building preview is a PORT APPROXIMATION using the port's own baked stage-0 mesh; donor ghost colour/size/blink appearance remain UNVERIFIED per B-GHOST-DIAG. Footprint BoxMesh survives ONLY as the labelled no-art fallback.
