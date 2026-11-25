---
id: L01
ticket: "OWNER DIRECTIVE wave — L01 (design only, DATA-ONLY)"
title: "L01 — organic light/dark grass SPOTS from existing donor ids, stamp masks and tilesmooth probabilities"
owner: L01 (read-only subagent)
created: 2026-11-25
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_RUNNER_JOB__NO_CODE_OR_ASSET_EDIT
scope: "This report is the ONLY repo file written. No Godot process, no godot_runner.py job, no runner/queue mutation, no .gd/.gdshader/config/asset/test/JSON edit, no donor file opened or copied. Two inline `python -c` reads parsed app/assets/terrain/patterns/donor_patterns.json (stdout only) and computed luma from A03's published means; nothing was written."
charter: docs/terrain_swarm_2026-11-25/CHARTER.md
board: docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
labels: [observed, derived, inferred, UNVERIFIED, PORT APPROX]
parity_guard: "DONOR PARITY STAYS UNVERIFIED (CHARTER §3/§5). No donor GPU A/B frame exists. Every visual expectation below is INFERRED or UNVERIFIED; no parity, equivalence or 'closer by N%' claim is made."
sources_read:
  - docs/terrain_swarm_2026-11-25/CHARTER.md
  - docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
  - docs/terrain_swarm_2026-11-25/reports/A03_atlas_cells.md
  - docs/terrain_swarm_2026-11-25/reports/A04_tile_diversity.md
  - docs/terrain_swarm_2026-11-25/reports/B03_diversity_impl.md
  - docs/terrain_swarm_2026-11-25/reports/B01_shader_impl.md
  - docs/terrain_swarm_2026-11-25/reports/A11_reference_metrics.md
  - docs/terrain_swarm_2026-11-25/reports/G05_visual_review.md
  - docs/terrain_swarm_2026-11-25/reports/G22_2d_vs_3d.md
  - docs/coord_swarm_2026-11-25/reports/RV_TRN_02_smoothing_rules.md
  - variant3d/scripts/game.gd (:66, :730-747, :765-801, :838-839, :1558-1717, :1720-1724, :1903-1952, :1957-2085, :2166-2284)
  - variant3d/scripts/pattern_gen.gd (:9, :110-128, :179-211, :230-251, :430-493)
  - app/assets/terrain/patterns/donor_patterns.json (families/patterns, read-only parse)
  - variant3d/assets/terrain/structs/presets_summer.json
---

# L01 — organic light/dark grass SPOTS, data-only design

## 0. Owner directive and answer in one paragraph

Owner: *"I would mix light-colour grass with darker or do it in spots but not like a chessboard."*

**Answer (INFERRED design, UNVERIFIED visually):** add **one data-only pass in `variant3d/scripts/game.gd`** that repaints **short, contiguous 1–6 map-cell row-runs** inside the **already-placed forest stamp core discs** (the filled discs the port already derives from donor stamp masks at `game.gd:765-801`) with two existing donor ids — **`grass9` (idx 8, light)** and **`grass5` (idx 4, dark)** — using **verbatim probability weights from `tilesmooth_scripts.cfg`** already embedded at `game.gd:1558-1717`. The runs are mask-derived and 4-connected; they are **not** a per-cell `(x,y)` lattice, **not** a synthetic noise/dither/luminance field, and require **no shader, atlas, mesh, test, asset or config edit**. The pass goes between B03's `tls_*` stamp loop and the 3-pass donor smoother, so donor smoothing reconciles every spot border. All non-donor choices (which donor list is reused for what, the id substitutions, the s×s disc solidification) are labelled **PORT APPROX** below.

---

## 1. Evidence ledger (file:line)

| ID | Label | Evidence |
|---|---|---|
| E01 | OBSERVED | `game.gd:66,741` — `pattern_stamps` is populated from `C3PatternGen.build()`; `:743-747` publishes `stamp_counts` by `kind`. A04 §2 measured `forest = 117`, `tile = 4` on the shipped seed 20261113 at 320². |
| E02 | OBSERVED | `game.gd:762-764` — literal code comment: *"the scaled donor cells are sparse (`*..*..*`), so painting raw cells makes thousands of one-tile flecks. Paint a FILLED contiguous core disc sized from the stamp extent instead (no rng consumed)."* `:765-801` computes `cext`, `core_r`, bbox and terrain guards and sets `terrain=2`. |
| E03 | OBSERVED | `pattern_gen.gd:110-128` — donor mask offsets are scaled by `s = map_w/160` and deduped, so `st.cells` at 320² are every-other-cell. `game.gd:777-779` converts the extent into a filled disc radius `clampf(cext*0.25, 14, 22) * size_k`. |
| E04 | OBSERVED | `game.gd:838-839` — `kind=="tile"` stamps are deliberately dropped (`pass`); B03 reuses them at `:2051-2063` to paint `ground1`. `game.gd:813-826` — `kind=="forest"` stamps fill a sod core and plant wood. |
| E05 | OBSERVED | `game.gd:1558-1717` — `DONOR_SMOOTH_RULES` embeds all 118 active `tilesmooth_scripts.cfg` lists; `tbl_smooth` is built from it at `:1740-1749` (order: Items 0–9 at indices 0–9; Item 10 has no active lists and is omitted, so index 10 = Item 11 Winter). |
| E06 | OBSERVED | Donor weights relevant here: Item 0 J=3 `cfg:67` = `rock1:.16, rock2:.16, rock3:.16, rock6:.16, rock7:.16, rock4:.20` (SumProb 1); Item 8 J=2 `cfg:798` = `grass_ground1:.36, grass_ground2:.28, grass_ground3:.36` (SumProb 1); Item 9 J=3 `cfg:846` = `test8:.4, test7:.6` (SumProb 1). RV-TRN-02 §7 rows; all live in `game.gd:1563,1629,1635`. |
| E07 | OBSERVED | `game.gd:2166-2198` `_tb_pick(li,gi,brng)` is the existing weighted roulette over `tbl_smooth`; `:2191-2196` already maps B03's donor art substitutions. `:2200-2261` `_tb_smooth_pair()` reconciles **donor list indices J**, not art ids. |
| E08 | OBSERVED | A03 §2/§4: `grass9` idx 8 is the cleanest isotropic seamless cell (FFT-aniso 1.20, Sx 0.93, Sy 1.02, |ΔY|≤0.8); `test8` 79 and `test9` 80 are the same class (1.27/1.26); `grass5` idx 4 is "usable; darker/cooler, slight bottom edge" (aniso 1.51, Sx 0.95, Sy 1.01, ΔYy −3.16); `grass6` idx 5 is much darker but aniso 2.20. Excluded: `grass2` aniso 5.16/Sy 1.81; `grass3` ΔYy +8.47; `grass4` +7.58; `grass_ground1/2/3` idx 14/15/16 vein lattice; `ground1` idx 10 grey-brown off-palette. A03 §4 R01–R06. |
| E09 | OBSERVED | A04 §3: on the real 320² `g32` dump, one uniform `grass_ground1` component covers **2,036 cells**, **29.93%** of the map lies in ≥100-cell uniform components; neighbour equality ≈48%. Smoothing preserves `|Δ|=1`, so interiors never diversify internally (A04 C3). |
| E10 | OBSERVED | A11 §5: target bands `BV32 n640` 8.7 → ≈150–270, `grad n640` 5.0 → ≈1–2, luma std 10.6 → ≈18–22, p5–p95 34 → ≈60–80 with bins 2–4 and 7–9 occupied. G05 §5 freezes the BEFORE numbers. |
| E11 | OBSERVED | B01 §1/§3: the shader already removes the verbatim per-cell 2 m repeat with mirror + low-frequency UV warp, linear mipmap, `textureGrad`, half-texel inset and mask contrast compression; it deliberately does **not** manufacture colour/noise. CHARTER §3 decision S-25-09 forbids a synthetic dither/noise field; A02 docs the old per-cell 4-way variant decomposition. |
| E12 | OBSERVED | All donor smoothing `.inc` code is `;`-commented; the cfg bytes and authored rules are real, but donor runtime activity is **UNVERIFIED** (RV-TRN-02 §4.6). No donor GPU A/B frame exists. |

---

## 2. What is allowed and what is forbidden (binding constraints)

**Allowed (this design uses only these):**
1. Tile ids that already exist in `presets_summer.json` and already occur in `DONOR_SMOOTH_RULES`.
2. Donor probabilities already embedded in `DONOR_SMOOTH_RULES` / `tbl_smooth` (`game.gd:1558-1717`).
3. Stamp masks/stamp geometry already placed by `pattern_gen.gd` and already in `pattern_stamps` (`game.gd:741`), including the port's own already-computed filled forest core discs (`game.gd:765-801`).
4. The existing tile RNG `brng` (`game.gd:1969-1970`), already dedicated to tile decisions (B03 §4).
5. The existing 3-pass donor smoother and all final authorities (water, mine apron, winter alias).

**Forbidden (none of this appears in the proposal):**
- Any per-cell `(x,y)`-hashed id/mirror/luminance variant — that is the per-cell lattice/chessboard B01 removes (E11) and the A04 §6 preamble's `_hash2`.
- Any synthetic noise/dither/Bayer/gain/beauty field, any new bitmap or mask edit (CHARTER S-25-09; A04 §6 "explicitly rejected"; B01 §1).
- Any new tile id, new stamp, new donor constant, probability normalisation, edit to the 118-rule table, or change to `_tb_smooth_pair`/`_tb_pick`/`_smooth_tilemap` logic.
- Any shader/atlas/mesh/`world3d_terrain.gd`/`pattern_gen.gd`/test/config/`app/` edit.
- Any donor-parity claim.

---

## 3. Palette: which ids are lighter and which are darker

A03's cell means are sRGB 8-bit. Two luma conventions are shown so the numbers can be checked against both reports: `Y709 = .2126R+.7152G+.0722B` (A11/C01 acceptance convention) and `Y299 = .299R+.587G+.114B` (A03 §2 measurement convention). **DERIVED** arithmetic from E08's published means; no new pixel measurement was made.

| Role | Tile id (idx) | Mean RGB (A03) | Y709 / Y299 | A03 texture class | Donor list / cfg | Label |
|---|---|---|---|---|---|---|
| **LIGHT spot (primary)** | `grass9` (8) | 77.0, 79.4, 29.4 | **75.3 / 73.0** | aniso 1.20, Sx .93, Sy 1.02, ΔYy +0.78, std 15.6 — *best isotropic/seamless* | Item 3 J=5 `grass9:1` `cfg:359` (= Item 4 J=5 `cfg:480`) | donor id + donor prob 1.0; **PORT APPROX** to use it as a spot colour |
| LIGHT spot (alternate) | `test9` (80) | 74.5, 76.4, 24.6 | 72.3 / 69.9 | aniso 1.26, Sx 1.07, Sy .94, std 16.0 — *good, isotropic* | Item 3 J=6 `test9:1` `cfg:367` | donor id; **PORT APPROX** use |
| LIGHT spot (alternate) | `test8` (79) | 73.0, 77.9, 27.9 | 73.3 / 70.7 | aniso 1.27, Sx .95, Sy .96, std 15.0 — *good, isotropic* | Item 1 J=4 `grass1:1,grass2:1,test8:1` `cfg:155` | donor id; **PORT APPROX** use |
| **DARK spot (primary)** | `grass5` (4) | 64.7, 62.0, 31.4 | **60.4 / 59.3** | aniso 1.51, Sx .95, Sy 1.01, ΔYy −3.16, std 16.3 — *usable, darker/cooler, slight bottom edge* | Item 7 J=1 `grass5:1` `cfg:762` (= Item 8 J=1 `cfg:790`) | donor id + donor prob 1.0; **PORT APPROX** to use it as a spot colour |
| DARK spot (optional, ≤2-cell only) | `grass6` (5) | 54.8, 48.0, 25.2 | 47.8 / 47.4 | aniso 2.20, gx/gy +0.14, LF .25 — *dark olive-brown, mottled, mild directionality* | Item 7 J=2 `grass6:1` `cfg:770` | **PORT APPROX**, higher risk (§9 R2) |
| Unchanged base field | `grass1` (0), `test7/8/9` (78/79/80), `grass7`, `test12/13/14` (DONOR_FOREST_BASE) | — | ≈72–77 | mostly flat std 8.5–12 | `game.gd:1982, :1724`, detail pass `:1913-1952` | no change |
| Explicitly excluded | `grass2` (1), `grass3` (2), `grass4` (3), `grass_ground1/2/3` (14/15/16), `ground1` (10), `test0/10/11` | — | — | streak/wrap seam, vein lattice, off-palette, or exact copies | A03 §4 R02–R06 | hard exclusion |

**DERIVED contrast:** `grass9 − grass5` ≈ **14.9 Y709 / 13.7 Y299** luma levels. This is the entire designed light/dark signal; no luminance multiplier, overlay or shader term is added. The base ids are clustered at 72–77 (A03 between-cell std only ~5.6/8.8/3.5), which is why `grass5` is necessary — swapping clean ids alone (grass9 vs test8 vs test9) changes luma by <3 levels and would be invisible (A03 F02). **INFERRED:** ~15 levels is comparable to one bucket of A11's desired p5–p95 widening (34 → 60–80), but whether it moves frame-level `BV32` depends on spot coverage, which is **UNVERIFIED** until G04's capture.

---

## 4. Donor probabilities actually used (verbatim weights, repurposed = PORT APPROX)

All three probability vectors are **literal donor weights** from `tilesmooth_scripts.cfg` (E06), read from `tbl_smooth` so no new constant is invented. The *repurposing* (a rock list deciding grass-run length, a road/transition list deciding spot polarity) is a documented **PORT APPROXIMATION**, not donor parity.

| Decision | Donor source | Verbatim weights | Use in this design | Label |
|---|---|---|---|---|
| Run length `n ∈ 1..6` | Item 0 J=3 `cfg:67`, `tbl_smooth[0][3]` | `.16,.16,.16,.16,.16,.20` (SumProb 1) | Roulette over the six entries → `n = index+1`; the donor's slightly heavier last weight makes 6-cell runs marginally more common | **PORT APPROX** (rock compatibility list → grass spot length) |
| Spot polarity | Item 9 J=3 `cfg:846`, `tbl_smooth[9][3]` | `test8:.4, test7:.6` (SumProb 1) | index 0 → LIGHT (`grass9`), index 1 → DARK (`grass5`): **40% light / 60% dark** | **PORT APPROX** (both the repurposing and the id substitutions) |
| Row eligibility (how many candidate rows get a spot) | Item 8 J=2 `cfg:798`, `tbl_smooth[8][2]` | `grass_ground1:.36, grass_ground2:.28, grass_ground3:.36` (SumProb 1) | threshold **0.36** (the `grass_ground1` weight) per eligible disc row → ≈1 in 3 rows | **PORT APPROX** (transition-list weight → row probability) |
| Spot art | Items 3/7 `cfg:359/369/762` | `1.0` each | `_tb_pick(3,5)` → `grass9`; `_tb_pick(3,6)` → `test9` (alternate); `_tb_pick(7,1)` → `grass5` | donor id + donor weight; **PORT APPROX** role |

Roulette arithmetic is copied from `_tb_pick` (`game.gd:2171-2181`): `r = brng.randf() * total`, accumulate `prob`, return the first index where `r < acc`. Nothing is normalised; the `0.64/0.0028/0.36` anomaly and `Prob=0` separators are untouched (RV-TRN-02 §3.5/§6 #7).

---

## 5. Exact spot-formation algorithm (deterministic, mask-derived)

All steps are **PORT APPROX** unless marked donor. Source data is only `pattern_stamps`, `terrain`, `tileblock`, `mine_mask`, `map_starts`, `tbl_smooth`, `DONOR_FOREST_BASE`, `brng`.

1. **Choose source stamps.** Iterate `pattern_stamps` (`game.gd:741`). Use only `kind == "forest"` — the 117 stamps on seed 20261113 (E01) whose masks actually produce the huge uniform interiors A04 measured (E09). **Do not** use raw `st.cells`: E02/E03 prove they are sparse (`*..*..*`), and painting them would recreate exactly the per-cell flecks/lattice that is forbidden. `kind=="tile"` stamps stay owned by B03-P2 (`:2051-2063`); this ticket does not touch them.
2. **Rebuild the existing filled core disc.** Recompute the same filled core the port already uses at `game.gd:766-801`: `cext = max(|st.cells[i].x|, |st.cells[i].y|)`, `core = clampf(cext*0.25, 14, 22) * size_k` with `size_k = clampf(MAP_W/320, 0.60, 1.0)`, then the same bbox and the same start-ring keep-clear (`7.0*TILE`, `game.gd:795`). This is the "existing stamp mask" as materialised in this port — a **PORT APPROX** substitution for the sparse donor mask (already made once at `:765-801`; we reuse it, we do not invent a new mask).
3. **Filter to editable meadow cells.** Keep a cell only if: in-bounds; `tileblock != BLK_WATER`; `mine_mask[i] == 0`; `terrain[i]` is not water/sand/rock (3/4/5); not in a start ring; and the current id is in the whitelist `[grass1, test7, test8, test9, grass7, test12, test13, test14]` (`game.gd:1982,1724,1913-1952`). This guarantees spots never touch shore, cliffs, roads, mines or forest-border `rock9`.
4. **Derive row-runs from the mask.** Group the surviving disc cells by map row `y`; each row gives a contiguous integer run `[x0, x1]` because the disc is filled (step 2). These runs are organic in length and placement (they follow the donor stamp's extent), never a fixed 2 m cadence.
5. **Per row, decide deterministically.** Iterate rows in ascending `y` (Dictionary insertion order):
   - eligibility: `brng.randf() < 0.36` (donor `cfg:798` weight) else skip;
   - length: `n = donor_run_len(brng)` over `tbl_smooth[0][3]` → 1..6; skip if `x1-x0+1 < n`;
   - start: `xs = brng.randi_range(x0, x1-n+1)` — the RNG is per row, **not** a per-cell `(x,y)` hash;
   - polarity: `light = donor_polarity(brng)` over `tbl_smooth[9][3]` → 40% light / 60% dark;
   - paint `id = light ? _blk("grass9") : _blk("grass5")` into `tileblock[_t(xs+k, y)]` for `k = 0..n-1`. Use `_tb_pick(3,5,brng)` / `_tb_pick(7,1,brng)` rather than raw `_blk()` so every written id is validated against a donor list (a picked id is always `>=0` for these 1.0-weight lists; keep a `if id >= 0` guard). Optional light alternation: on a second donor draw use `_tb_pick(3,6)` → `test9` (PORT APPROX).
6. **Let donor smoothing reconcile.** Run the existing `_smooth_tilemap(brng,3)` immediately afterwards (`game.gd:2067`); it rewrites spot borders using unchanged donor rules. `_stamp_forest_borders(brng)` (`:2070`) and the mine-apron authority (`:2074-2076`) still run last and still win. Winter alias at `:2081-2085` still converts the written Summer ids to `*_winter` art.

**Why this is not a chessboard (DERIVED):** the written cells form a 4-connected horizontal run of 1–6 cells whose position and length come from a stamp's filled disc and a per-row roulette. There is no per-cell parity term, no `(x+y) mod 2`, no alternating two-id lattice, and no luminance field. If a reviewer sees a *regular* spot cadence, revert — that would mean the mask derivation was bypassed.

**Why this is not synthetic noise (DERIVED):** every probability is a live donor weight from `tilesmooth_scripts.cfg`, every id is a donor id, and the spatial support is an existing donor stamp mask. Nothing is evaluated per cell as a hash/gain/dither.

### 5.1 Proposed code shape (PROPOSAL ONLY — not applied)

```gdscript
# L01 (PORT APPROX): donor stamp disc -> 1-6 cell light/dark grass runs.
func _stamp_grass_spots(brng: RandomNumberGenerator) -> void:
	var id_light := _tb_pick(3, 5, brng)   # grass9, cfg:359, prob 1.0
	var id_dark  := _tb_pick(7, 1, brng)   # grass5, cfg:762, prob 1.0
	if id_light < 0 or id_dark < 0:
		return
	var base_ids := [_blk("grass1"), _blk("test7"), _blk("test8"), _blk("test9")]
	for fp in DONOR_FOREST_BASE:
		base_ids.append(_blk(str(fp[0])))
	var size_k := clampf(float(MAP_W) / 320.0, 0.60, 1.0)
	for ps in pattern_stamps:
		var st: Object = ps
		if str(st.kind) != "forest":
			continue
		var cext := 0.0
		for c0 in (st.cells as Array):
			var cc0: Vector2i = c0
			cext = maxf(cext, float(maxi(abs(cc0.x), abs(cc0.y))))
		var core := clampf(cext * 0.25, 14.0, 22.0) * size_k  # game.gd:777-779
		var steps: int = ceili(core)
		var cx: int = int(st.x)
		var cy: int = int(st.y)
		var rows: Dictionary = {}
		for yy in range(maxi(0, cy - steps), mini(MAP_H - 1, cy + steps) + 1):
			for xx in range(maxi(0, cx - steps), mini(MAP_W - 1, cx + steps) + 1):
				if Vector2(float(xx - cx), float(yy - cy)).length() > core:
					continue
				var i := _t(xx, yy)
				if mine_mask[i] != 0 or tileblock[i] == BLK_WATER:
					continue
				if not base_ids.has(int(tileblock[i])):
					continue
				var in_ring := false
				for sp in map_starts:
					if Vector2((float(xx) + 0.5) * TILE, (float(yy) + 0.5) * TILE).distance_to(sp as Vector2) < 7.0 * TILE:
						in_ring = true
						break
				if in_ring:
					continue
				if not rows.has(yy):
					rows[yy] = [xx, xx]
				else:
					var rg: Array = rows[yy]
					rg[1] = xx
		for yy in rows.keys():                         # insertion order = ascending y
			if brng.randf() >= 0.36:                   # donor cfg:798 weight
				continue
			var rg2: Array = rows[yy]
			var x0: int = int(rg2[0])
			var x1: int = int(rg2[1])
			var n := _donor_run_len(brng)              # 1..6 from cfg:67
			if x1 - x0 + 1 < n:
				continue
			var xs := brng.randi_range(x0, x1 - n + 1)
			var light := _donor_polarity(brng)         # 0.4/0.6 from cfg:846
			var tid: int = id_light if light else id_dark
			for k in n:
				tileblock[_t(xs + k, yy)] = tid

# L01 PORT APPROX: Item 0 J=3 cfg:67 weights -> run length 1..6.
func _donor_run_len(brng: RandomNumberGenerator) -> int:
	var g: Array = tbl_smooth[0][3]
	var total := 0.0
	for td in g:
		total += float(td.get("prob", 0.0))
	var r := brng.randf() * total
	var acc := 0.0
	for i in g.size():
		acc += float(g[i].get("prob", 0.0))
		if r < acc:
			return i + 1
	return g.size()

# L01 PORT APPROX: Item 9 J=3 cfg:846 test8:.4 / test7:.6 -> light/dark.
func _donor_polarity(brng: RandomNumberGenerator) -> bool:
	var g: Array = tbl_smooth[9][3]
	var total := 0.0
	for td in g:
		total += float(td.get("prob", 0.0))
	var r := brng.randf() * total
	var acc := 0.0
	for i in g.size():
		acc += float(g[i].get("prob", 0.0))
		if r < acc:
			return i == 0
	return false
```

Static sanity (no Godot, no execution): the helpers only read `tbl_smooth`, use the same roulette as `_tb_pick:2171-2181`, and write only `tileblock`; no new uniform/constant/id. **This pseudocode was not applied to any file.**

---

## 6. Insertion point, ownership, backup

- **File:** `variant3d/scripts/game.gd` only — B03's owned file (B03 §0). Per `WAVE_G_CHARTER.md:31` only G04 runs Godot; per the standing Wave-P/M/F2/S rule, COORD grants exclusive ownership of shared files **after G04 finishes**. **L01 does not edit now**; the implementation owner must wait for COORD's explicit grant.
- **Call site:** immediately after B03's `kind=="tile"` loop at `game.gd:2051-2063`, i.e. at current `:2064`, **before** `_smooth_tilemap(brng, 3)` at `:2067`. Do not move the detail pass (`:2039`), shore pass (`:2033`), forest borders (`:2070`) or mine apron (`:2074-2076`).
- **Function placement:** add `_stamp_grass_spots()` and the two helpers near `_stamp_forest_borders()` (`game.gd:2272-2284`), after `_tb_pick()`/before or after `_stamp_forest_borders`; line numbers below will shift, so cite by function name in the merge report.
- **Backup:** `inbox/backup/game.gd.bak-L01` — byte copy of the **current post-B03** file taken before the first edit (B03's own backup is `game.gd.bak-B03`, a different baseline). Confirm size/hash after copy; do not overwrite the B03 backup.
- **Untouched:** shader, atlas, block PNGs, `world3d_terrain.gd`, `pattern_gen.gd`, config, tests, `app/`, donor data. If A04 P3 (full 25-unit tile grid) is wanted for more tile stamps, it is a **separate ticket owning `pattern_gen.gd`** (A04 §6 P3), not this one.

---

## 7. Determinism and invariants (DERIVED)

- `brng` is seeded `int(Data.RANDOM_SEED)+7` at `game.gd:1969-1970` and (per B03 §4) has no consumer outside tile decisions. The new pass adds draws only to `brng`; terrain, `blocked`, `res_nodes`, `map_starts`, `rng`, `gen_rng` and `_gen_patterns()` replay are unchanged — no new stamp, no occupancy change.
- `t_map_variety same_seed_byte_identical` is preserved by construction: same seed → same `brng` sequence → same rows/lengths/polarity/ids. Frozen tileblock hashes are **not** a valid gate (B03 R1/TRN-DATA precedent); two runs of the same seed must match.
- Guardrails preserved: `BLK_WATER` skip, `mine_mask` skip and final mine-apron authority (`:2074-2076`), whitelist excludes shore/cliff/road ids, start-ring keep-clear, `tileblock` size/uint8 type unchanged, winter alias (`:2081-2085`) converts the Summer ids normally.
- `_tb_smooth_pair()` compatibility is unchanged and keys on donor list indices, not art ids (`:2227-2240`); the spot ids occur in `tbl_smooth` (`grass9` Items 3/4 J=5, `grass5` Items 7/8 J=1), so no orphan id reaches the shader.
- Mesh/atlas contract intact: one uint8 tile index per cell → `UV2.x` → one 1024² atlas cell (`world3d_terrain.gd:1407`, B01 §6). No sampler, UV2, shader or atlas change.

---

## 8. Acceptance (measure, do not assert)

### 8.1 A11 bands + G05 frozen baseline (movement indicators only, NOT thresholds or parity)

| Metric | G05/A11 BEFORE | A11 desired direction/band | What this design is expected to do (INFERRED) |
|---|---|---|---|
| `BV32 n640` (A11 §3) | **8.7** | up ≈20–30× → ≈**150–270** (ref median 247.6, ref A 205.0) | spots create coherent block-mean differences; magnitude UNVERIFIED |
| `grad n640` | **5.00** | down 3–4× → ≈**1–2** | no new per-cell grain is added; spot borders add some local gradient — must be measured, not assumed |
| luma std | **10.596** | up ≈1.9× → **18–22** | dark spots at Y≈60 vs base ≈74 widen the distribution |
| p05 / p95, histogram bins | 74.88 / 108.88 (span 34; 84% in bins 5–6) | span ≈**60–80**, bins 2–4 and 7–9 occupied | dark tail from `grass5`; light tail from `grass9` small (Δ≈1 level vs base) |
| `BV128 between_block_var` (G05 §5, full frame) | **6.9579** (ground crop **4.4176**) | up toward donor distribution | same low-frequency direction at the larger block scale |
| `row_periodicity` | **0.688919** | down toward donor median 0.232 | no new regular cadence; if it rises, the mask derivation failed |
| `tile_repeat` / `tile_period_px` | 0.085161 / 64 | down / no new 2 m cadence | runs are 1–6 contiguous cells at mask-derived offsets |
| `full_width_dark_rows`, `non_black_fraction` | 0, 1.0 | unchanged | water/mine guards and B01 sentinel guard preserved |
| `mean_saturation` | 0.674 | down ≈20% → ≈0.53 | palette only, secondary; **not** a substitute for structure |

Use the **exact same G04 pipeline and crop** on both arms: `python variant3d\tools\terrain_ab_metric.py <PNG> --crop 120,60,1040,580 --json` (G05 §3) with seed, camera and zoom pinned; record paths/timestamps. The C01 `flags` (`flat_large_scale`, `low_fine_variation`, `seam_repetition.row_periodicity`) are heuristic prompts, **never** a gate (C01 §5).

### 8.2 Structural acceptance (A04 §7)

- On seed 20261113 at 320², a live histogram/component scan should show: largest uniform 4-component **< 800 cells** (from 2,036), cells in ≥100-cell uniform components **< 15%** (from 29.93%); distinct ids ≥ 35; top-5 < 58.52%; `test7+test8` < 10%; no out-of-atlas id.
- `world3d_terrain.gd:1570,1641` already publishes `stats.tile_index_hist` — no new probe file needed (A04 P4). Spot ids `grass5`/`grass9` must appear in the histogram; if they do not, the pass did not run.
- Gates unchanged and green: `t_map_variety` 5/5 incl. `same_seed_byte_identical`, selftest 29/29, uitest 17/17, `t_render_mode`, `assert_clean CLEAN`; 2D `app/` untouched.
- C04/G05 R1–R4 visual scan on the AFTER capture: no checker mosaic, no repeated dark blotches, visible soft light/dark patchwork; no new seams/black rows.

### 8.3 Epistemic acceptance

No A11 band is "passed" by this report. Donor parity remains **UNVERIFIED**; a GPU A/B donor frame does not exist (CHARTER §3). All expectations above are **INFERRED** from data-structure arguments; only a G04 capture plus the metric/component gates can promote them.

---

## 9. Risks and mitigations

| # | Risk | Severity | Mitigation / gate |
|---|---|---|---|
| R1 | **False positive "checkerboard".** If someone implements the spots from raw `st.cells` instead of the filled core disc, at `s=2` the offsets are `*..*..*` (E02/E03) → dotted one-cell lattice, exactly the defect B01 removes. | **high** | Hard rule: source cells = the **filled core disc** recomputed per `game.gd:777-779`, then grouped into contiguous row-runs; verify 4-connectivity offline; C04 R1 scan on AFTER frame. |
| R2 | **Synthetic-field regression.** Adding any per-cell hash, dither, gain or luminance field would violate S-25-09 and recreate the 2D checkerboard (G22 §3 item 4, G18). | **high** | Only donor weights + stamp geometry; no new bitmap/mask/uniform; no `(x,y)` parity. Review the diff for `_hash2`/`noise`/`dither` tokens. |
| R3 | **Coverage too small to move BV32.** 117 forest stamps × ≈1/3 eligible rows × ≈3 cells ≈ 3% of 320² (DERIVED rough); open meadow has only 4 `tile` stamps (A04 §4), which this ticket does not touch. | **medium** | Measure with A04 component scan + G04 capture first. If insufficient, follow up with A04 P3 (`pattern_gen.gd`, separate owner) or a higher row-eligibility weight **with a new PORT APPROX label**, not a noise field. |
| R4 | **Spot art repeats.** A 1-id light and 1-id dark family means every spot samples the same atlas cell; A03 F02 warns no cell supplies donor-scale mottling, so many identical spots could read as a new, larger pattern. | **medium** | Keep density moderate; optional `test9` (`_tb_pick(3,6)`) and `test8` alternation from donor 1.0 lists; monitor C04 R1/R3 and `tile_repeat`; no donor-parity claim. |
| R5 | **`grass5` bottom edge.** ΔYy −3.16 (E08) — repeated 1–6 cell runs could expose a faint horizontal step at 2 m cadence. | **medium** | Runs stay ≤6 cells and are followed by 3-pass donor smoothing; if visible, restrict dark id to `grass6`? No — `grass6` aniso 2.20 is worse; prefer art-edge healing in a **separate asset ticket** (A03 R04-style). |
| R6 | **Smoothing erodes spots.** `grass9` (Item 3/4 J=5) and `grass5` (Item 7/8 J=1) sit in different donor chains from `grass1`/`test8` (J=4) and forest ids (Item 1 J=5); `_tb_smooth_pair` may pull border cells one step (Δ>2 rule, RV-TRN-02 §4.3). | **low/medium** | Expected and donor-rule-driven; do **not** add a custom compatibility rule; verify via component scan that runs survive ≥1–6 cells; B03 R5b precedent. |
| R7 | **RNG stream shift.** Per-row draws add many `brng` randf/randi calls, changing tileblock bytes for every seed and shifting later smoothing/border picks. | **low** | Deterministic per seed; use `same_seed_byte_identical`, not a frozen hash (B03 R1); terrain/blocked/res_nodes untouched; TRN-DATA precedent. |
| R8 | **Fine-grain metric could worsen.** Spot ids have std 15–16 vs base ~9–12; B01 §7 wants `grad n640` DOWN. | **medium** | Do not tune B01's mask strength to compensate; measure `grad n640` on the AFTER capture; if it rises, reduce spot density (a PORT APPROX knob) rather than adding blur or a luminance field. |
| R9 | **Winter/season.** Spots write Summer ids; winter maps must still alias through `winter_block_for()` at `game.gd:2081-2085`. | **low** | Reuse the existing alias path; check with G16 season consistency after G04. |
| R10 | **Donor runtime activity UNVERIFIED.** All donor `.inc` code is `;`-commented (E12); the weights are real bytes but "the donor does this" cannot be asserted. | epistemic | Every reuse labelled PORT APPROX; no donor-parity sentence anywhere. |
| R11 | **Ownership/race.** `game.gd` is B03's file; P/M/S waves also contest files. | **low** | L01 edits nothing; COORD grants after G04; backup `game.gd.bak-L01`; no cross-touch. |

---

## 10. Explicitly rejected alternatives

1. **Per-cell light/dark alternation or a hashed id/mirror variant** — the chessboard B01 removes and A04's old per-cell `test7/8/9` speckle (charter §2 suspect 5). Rejected.
2. **Synthetic noise/dither/beauty field, new bitmap, mask edit or luminance multiplier** — CHARTER §3 S-25-09, A04 §6 "explicitly rejected", B01 §1, G22 §6 item 4. Rejected.
3. **Using `grass_ground1/2/3` as the dark/light pair** — A03 F03/R02: bright diagonal vein lattice, worst visual repeat; B03-P3 already redirects them to clean art. Rejected.
4. **Using `grass2/3/4`** — A03 F04/F05: aniso 5.16/Sy 1.81, and ΔYy +8.47/+7.58 authored seams. Rejected.
5. **Using `ground1` for spots** — A03 F06: off-palette grey-brown; it belongs only to roads/mines and B03-P2's decal substitution. Rejected.
6. **Changing shader, atlas, mesh, `tilesmooth_scripts.cfg` weights, SumProb anomaly, Prob=0 separators or smoother logic** — out of ticket scope and/or guardrail violations. Rejected.
7. **Claiming donor parity or a PASS verdict** — no donor GPU A/B frame; G05 explicitly records no PASS. Rejected.

---

## 11. UNVERIFIED / open questions

1. Whether ~15 luma levels of spot contrast at ~3% coverage actually raises `BV32 n640` into A11's band — needs a G04 capture and the A04 component scan. No claim made.
2. Which of the 117 forest stamps survive `can_stand`/start keep-clear on a given seed; exact spot cell count for seed 20261113 is not measured here (reading dumps only would need a read-only decode, deliberately not done in this ticket).
3. Donor runtime execution of the smoothing/detail passes (E12) — UNVERIFIED; only authored bytes are real.
4. Whether the donor ever uses `grass5` as a meadow colour (vs a border/transition tile): Item 7 J=1 / Item 8 J=1 exist, but the item-selection binding is UNVERIFIED (RV-TRN-02 §8 Q4). The spot role is therefore PORT APPROX.
5. Whether `test13` (in DONOR_FOREST_BASE, not measured by A03) has acceptable seam/isotropy — irrelevant to the spot ids themselves but affects the base field A03 §7 left open.
6. Exact `grad n640` response to localized higher-std spot art (R8) — needs measurement, not inference.

---

## 12. Scope statement

Files created by this ticket: **this report only**. No code, shader, asset, config, test, runner job, git state or donor file was changed. The `python -c` invocations parsed `donor_patterns.json` and computed luma from A03's already-published means, wrote nothing to the repo, and ran no Godot process. All diffs in §5.1 are **proposals** for a future, COORD-granted implementation owner. Donor parity stays **UNVERIFIED**.

*End of L01 report. Read-only; one report file; no Godot, no runner job, no code or asset edit.*
