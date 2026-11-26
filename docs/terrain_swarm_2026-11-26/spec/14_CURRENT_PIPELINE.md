# 14 — Current variant3d terrain pipeline (from P01)

Source: `reports/P01_pipeline_audit.md` (508 lines, read-only trace). Facts here
describe the **legacy** path the new module must coexist with.

## 1. Stage trace with exact file:line citations [O]

config/seed → `game.setup` / staged loader → `mapgen.gd` mask height →
`pattern_gen.gd` stamps → `_shape_stamp_relief` → clamp/collision →
`_gen_patterns` → `_assign_tileblocks` → `world3d_terrain` dump/mesh → shader →
water. Per-stage file:line in P01 §.

## 2. Ownership boundary [O]

- Sim owns `terrain`, `blocked`, `height`, `tileblock`, `mine_mask`, `res_nodes`.
- Renderer reads only `height` + `tileblock` from a **synthesized dump**.
- `_generate_map()` is **dead code**.
- `relief_stamps` and `_relief_stamp_mask` **never reach live 3D**.

## 3. RNG [O]

Five live streams: `game.rng`, mask `r`, `C3PatternGen.rng`, `mine_rng`, tileblock
`brng`, plus seed-derived `_hash2`. The `gen_rng` stage reseeds are **inert**.

## 4. Divergences from donor [O]/[U]

Donor smoothing, blend, tile variety, relief props and water bindings are PORT
APPROXIMATION or UNVERIFIED. The Y02 `terrain=5` maze route is severed, but the
**height → face → cliff-art** route and Y08 meadow flattening remain.

## 5. Seam — P01 placement + V05 control flow, now reconciled and applied [D]/[O]

Compose a fresh `terrain_donor_*.gd` behind the COORD-owned `terrain_backend` switch (`world3d.gd` ternary at current `:624`, gate/bind unchanged; `main.gd` config read and both `make_world3d()` sites) using the `world3d_relief.gd` sibling pattern; **no edits to the six legacy pipeline files**. V05 **has landed** and `spec/12 §12.1` is authoritative — remove the "when landed" qualifier and the "V05 is reconciling" sentence. At V26 read the seam inserts and `.bak-COORD-I11` backups are present in the working tree while the composer `terrain_donor_world.gd` is still absent; default remains `"legacy"` and no A/B or parity verdict exists. *(V26 C4)*

V43 live re-read (read-only): `terrain_donor_world.gd` now **exists** (untracked), so the V26 "composer still absent" clause is point-in-time and must not be carried forward; `world3d.gd:118,144,220-224,624,706-707` and both `.bak-COORD-I11` hashes were re-verified unchanged. Default remains `"legacy"`; no gate result and no donor parity claim. Re-run `git status`/hashes/anchors before any dispatch. *(V43 re-verify)*

---
*Integrated by COORD from P01.*
