---
id: L01-IMPL
ticket: "WAVE L integration — L01-IMPL (exclusive owner of variant3d/scripts/game.gd)"
title: "L01-IMPL — organic light/dark grass SPOTS from forest stamp cores, applied on top of Y03"
owner: L01 (COORD grant: exclusive `variant3d/scripts/game.gd` owner after Y03 released the file)
created: 2026-11-25
status: APPLIED__NO_RUNNER__NO_GODOT__GATES_WITH_G04
scope: "Exactly two repo files changed by this ticket: variant3d/scripts/game.gd (2 added hunks) and this report. Plus one pre-edit backup outside the source tree (inbox/backup/game.gd.bak-L01) and one read-only scratch checker in C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/. No shader, atlas, asset, config, test, world3d_terrain.gd, pattern_gen.gd, donor file, git state, runner job or Godot process touched."
labels: [observed, derived, inferred, UNVERIFIED, PORT APPROX]
parity_guard: "NO DONOR PARITY CLAIM. No donor GPU A/B frame exists (CHARTER §3/§5). Every visual expectation below is INFERRED or UNVERIFIED."
backed_up_file: inbox/backup/game.gd.bak-L01
backup_sha256: 851E81537F1ACADB281B08CE42B65EEEF6BF946EC7003374E1B6C251BBAA9AF4
backup_git_blob: e0c2b5ed28979d65ee0505b77ad33259a925847a
post_edit_git_blob: 8373cfee26e2f98b66e148621afa030a7e421957
sources_read:
  - docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
  - docs/terrain_swarm_2026-11-25/CHARTER.md
  - docs/terrain_swarm_2026-11-25/reports/L01_spot_grass.md
  - docs/terrain_swarm_2026-11-25/reports/Y03_detail_pass_fix.md
  - docs/terrain_swarm_2026-11-25/reports/Y06_visual_verdict.md
  - docs/terrain_swarm_2026-11-25/reports/B03_diversity_impl.md
  - variant3d/scripts/game.gd (post-Y03 working tree, read before and after edit)
---

# L01-IMPL — applied spot-grass pass

## 0. Mandate executed

Owner directive: *"I would mix light-colour grass with darker in SPOTS, not like a chessboard."* Y06 confirmed that Y03's forced-`grass9` detail pass removed the field maze but replaced it with dense horizontal corrugation / tile repetition. The directive is explicit: **keep Y03's neutralisation**, add L01's stamp-derived spots as a **separate pass**, never from the height-derived detail bitmaps, never from raw stamp cells.

Applied exactly:

1. **Light ids** `grass9` (8), `test9` (80), `test8` (79); **dark id** `grass5` (4). All are existing donor ids in `presets_summer.json` and A03's clean shortlist (A03 §2/§4). No `grass2/3/4`, no `grass_ground*`, no `ground1`.
2. **1–6 cell contiguous runs** from the **FILLED forest-stamp core discs** that `_gen_patterns()` already computes at `game.gd:772-807` — never from raw `st.cells` (s-scaled `*..*..*` → lattice) and never from `tile_low/highground` (Y01b/Y03 maze).
3. **Donor `tilesmooth_scripts.cfg` probabilities** read from the embedded `tbl_smooth` — cfg:67 (run length), cfg:846 (polarity), cfg:798 (row eligibility and light-id choice). All role repurposing is **PORT APPROX**.
4. **Insertion**: after B03's `kind=="tile"` loop, before `_smooth_tilemap(brng,3)`. Post-edit call at `:2130`, smoother at `:2134`, forest borders at `:2137`.
5. **Y03/B03 invariants**: kept (§4). **No Godot, no runner** (§6).

---

## 1. Backup (taken BEFORE the first edit)

| Item | Value |
|---|---|
| Command | `Copy-Item -LiteralPath 'variant3d\scripts\game.gd' -Destination 'inbox\backup\game.gd.bak-L01' -Force` |
| Pre-edit `game.gd` size | **250,615 bytes** |
| Pre-edit git blob | `e0c2b5ed28979d65ee0505b77ad33259a925847a` — exactly Y03's post-apply blob (Y03 §10.1), so no intervening `game.gd` edit existed |
| Pre-edit SHA-256 | `851E81537F1ACADB281B08CE42B65EEEF6BF946EC7003374E1B6C251BBAA9AF4` |
| Backup file | `inbox/backup/game.gd.bak-L01`, **250,615 bytes**, SHA-256 **identical** to the above, git blob `e0c2b5ed…` |
| Other backups | `game.gd.bak-B03`, `game.gd.bak-B03-relief`, `game.gd.bak-Y03` left untouched |

Rollback is a byte copy of this backup over `variant3d/scripts/game.gd` (§9).

---

## 2. Exact diff (verbatim `git diff -- variant3d/scripts/game.gd`)

Post-edit git blob `8373cfee26e2f98b66e148621afa030a7e421957`; `git diff --stat`: **1 file, 162 insertions, 0 deletions**. Three hunks appear against HEAD; **hunk 1 is Y03's already-applied neutralisation (not written by L01)** — it is shown so the full tree state is auditable. Hunks 2 and 3 are L01-IMPL's only edits.

```diff
diff --git a/variant3d/scripts/game.gd b/variant3d/scripts/game.gd
index c0c884ce..8373cfee 100644
--- a/variant3d/scripts/game.gd
+++ b/variant3d/scripts/game.gd
@@ -1994,6 +1994,18 @@ func _apply_detail_pass(brng: RandomNumberGenerator) -> void:
 				var pick8 := _tb_pick(1, 4, brng)
 				if pick8 >= 0:
 					tex = pick8
+			# Y03 (PORT APPROXIMATION, diagnostic baseline — A08 §1.2, Y01b §8):
+			# the bitmap R is a CATEGORICAL tile id and the h<0.1 low/high
+			# selection makes its 1-6 cell runs follow height contours — the
+			# surviving concentric maze after B03 removed terrain=5. Collapse
+			# every detail-pass output to ONE clean donor grass id (grass9 idx 8,
+			# A03 §2 "best isotropic/seamless"). Keep the TWO _tb_pick calls
+			# ABOVE: they must consume the same brng draws so _smooth_tilemap
+			# and _stamp_forest_borders see an unchanged RNG stream. The donor
+			# uses these ids for mottling; removing their variety is a port-level
+			# substitution, not donor parity (UNVERIFIED). L01's stamp-mask
+			# spots are the planned organic-variety follow-up.
+			tex = _blk("grass9")
 			if tex >= 0 and tex < tbl_names.size():
 				tileblock[i] = tex
 
@@ -2107,6 +2119,15 @@ func _assign_tileblocks() -> void:
 			var pti := _t(px, py)
 			if tileblock[pti] != BLK_WATER:
 				tileblock[pti] = _blk("ground1")
+	# L01-IMPL (PORT APPROXIMATION, L01_spot_grass.md §5): organic light/dark
+	# grass SPOTS from the already-placed FOREST stamp masks — the FILLED core
+	# discs computed in _gen_patterns above (:772-807), never raw sparse st.cells
+	# (that would lattice) and never the height-derived detail bitmaps Y03
+	# neutralised (that would restore the maze). 1-6 contiguous cells per run;
+	# donor tilesmooth weights only; brng-only determinism. Runs BEFORE the
+	# 3-pass smoother so donor rules reconcile every spot border; mine apron and
+	# winter alias still win last. Y03's grass9 detail neutralisation is intact.
+	_stamp_grass_spots(brng)
 	# 4) exact 3-pass SmoothTileMap (donor smoothtiles.inc:191-237): three
 	# passes, horizontal then vertical, over the FINAL tile field before UV2.
 	# TRN-DATA: the donor rule table now covers all 118 active lists.
@@ -2329,6 +2350,147 @@ func _stamp_forest_borders(brng: RandomNumberGenerator) -> void:
 			if n == 1:
 				tileblock[_t(x, y)] = _blk("grass5") if brng.randf() < 0.34 else _blk("rock9")
 
+# L01-IMPL (PORT APPROXIMATION, L01_spot_grass.md §3/§4/§5): stamp-mask grass
+# spots. Every id and every probability comes from the embedded donor data;
+# repurposing donor rule weights for run length / polarity / light-id choice and
+# using the forest core disc as a ground stencil are port-level substitutions,
+# NOT donor parity (CHARTER §3; no donor GPU A/B frame). No hash, noise, dither
+# or luminance field — S-25-09 honoured.
+func _stamp_grass_spots(brng: RandomNumberGenerator) -> void:
+	var id_dark := _tb_pick(7, 1, brng)  # grass5, Item 7 J=1 cfg:762, prob 1.0
+	if id_dark < 0:
+		return
+	# Post-Y03 meadow base ids: the detail pass now emits grass9, forest interiors
+	# keep the DONOR_FOREST_BASE family; grass1/test7/8/9 are legacy leftovers.
+	var base_ids := [_blk("grass1"), _blk("grass9"), _blk("test7"), _blk("test8"), _blk("test9")]
+	for fp in DONOR_FOREST_BASE:
+		base_ids.append(_blk(str(fp[0])))
+	var size_k := clampf(float(MAP_W) / 320.0, 0.60, 1.0)
+	var row_w: Array = tbl_smooth[8][2]  # Item 8 J=2 cfg:798 .36/.28/.36, SumProb 1
+	if row_w.size() < 3:
+		return
+	var row_prob := float(row_w[0].get("prob", 0.0))  # donor .36 -> row eligibility
+	for ps in pattern_stamps:
+		var st: Object = ps
+		if str(st.kind) != "forest":
+			continue
+		# Same FILLED core disc _gen_patterns already paints (:772-807). Raw
+		# st.cells are s-scaled *..*..* and would produce a one-cell lattice.
+		var cext := 0.0
+		for c0 in (st.cells as Array):
+			var cc0: Vector2i = c0
+			cext = maxf(cext, float(maxi(abs(cc0.x), abs(cc0.y))) * TILE)
+		var core_r: float = clampf(cext * 0.25, 14.0 * TILE, 22.0 * TILE) * size_k
+		var steps: int = ceili(core_r / TILE)
+		var cx: int = int(st.x)
+		var cy: int = int(st.y)
+		var cpos := Vector2((float(cx) + 0.5) * TILE, (float(cy) + 0.5) * TILE)
+		var rows: Dictionary = {}
+		for yy in range(maxi(0, cy - steps), mini(MAP_H - 1, cy + steps) + 1):
+			for xx in range(maxi(0, cx - steps), mini(MAP_W - 1, cx + steps) + 1):
+				var i := _t(xx, yy)
+				if mine_mask[i] != 0 or tileblock[i] == BLK_WATER:
+					continue
+				var tt: int = terrain[i]
+				if tt == 3 or tt == 4 or tt == 5:
+					continue
+				var p2 := Vector2((float(xx) + 0.5) * TILE, (float(yy) + 0.5) * TILE)
+				if p2.distance_to(cpos) > core_r:
+					continue
+				var in_ring := false
+				for sp in map_starts:
+					if p2.distance_to(sp as Vector2) < 7.0 * TILE:
+						in_ring = true
+						break
+				if in_ring:
+					continue
+				if not base_ids.has(int(tileblock[i])):
+					continue
+				if not rows.has(yy):
+					rows[yy] = [xx, xx, [xx]]
+				else:
+					var rg: Array = rows[yy]
+					rg[1] = xx
+					var accx: Array = rg[2]
+					accx.append(xx)
+		# Dictionary keys were inserted in ascending yy; row runs follow the
+		# stamp disc outline, so spots are organic, never a fixed grid cadence.
+		for yy in rows.keys():
+			if brng.randf() >= row_prob:
+				continue
+			var rg2: Array = rows[yy]
+			var x0: int = int(rg2[0])
+			var x1: int = int(rg2[1])
+			var n := _donor_run_len(brng)  # 1-6 from cfg:67
+			if x1 - x0 + 1 < n:
+				continue
+			var xs := brng.randi_range(x0, x1 - n + 1)
+			var tid: int = id_dark
+			if _donor_polarity(brng):  # 0.4 light / 0.6 dark from cfg:846
+				tid = _donor_light_id(brng, row_w)  # grass9/test9/test8
+			if tid < 0:
+				continue
+			# Only paint cells that actually passed every guard above: the row's
+			# min/max can span filtered-out water/shore/mine/start-ring cells.
+			var accx: Array = rg2[2]
+			var contiguous := true
+			for k in n:
+				if not accx.has(xs + k):
+					contiguous = false
+					break
+			if not contiguous:
+				continue
+			for k in n:
+				tileblock[_t(xs + k, yy)] = tid
+
+# L01 PORT APPROX: Item 0 J=3 cfg:67 .16x5/.20 -> run length 1..6.
+func _donor_run_len(brng: RandomNumberGenerator) -> int:
+	var g: Array = tbl_smooth[0][3]
+	var total := 0.0
+	for td in g:
+		total += float(td.get("prob", 0.0))
+	if total <= 0.0:
+		return 1
+	var r := brng.randf() * total
+	var acc := 0.0
+	for i in g.size():
+		acc += float(g[i].get("prob", 0.0))
+		if r < acc:
+			return i + 1
+	return g.size()
+
+# L01 PORT APPROX: Item 9 J=3 cfg:846 test8:.4 / test7:.6 -> light/dark.
+func _donor_polarity(brng: RandomNumberGenerator) -> bool:
+	var g: Array = tbl_smooth[9][3]
+	var total := 0.0
+	for td in g:
+		total += float(td.get("prob", 0.0))
+	if total <= 0.0:
+		return false
+	var r := brng.randf() * total
+	var acc := 0.0
+	for i in g.size():
+		acc += float(g[i].get("prob", 0.0))
+		if r < acc:
+			return i == 0  # test8 weight .4 -> light; test7 .6 -> dark
+	return false
+
+# L01 PORT APPROX: cfg:798 .36/.28/.36 -> grass9/test9/test8 (all A03-clean).
+func _donor_light_id(brng: RandomNumberGenerator, weights: Array) -> int:
+	var picks := [_blk("grass9"), _blk("test9"), _blk("test8")]
+	var total := 0.0
+	for td in weights:
+		total += float(td.get("prob", 0.0))
+	if total <= 0.0:
+		return picks[0]
+	var r := brng.randf() * total
+	var acc := 0.0
+	for i in picks.size():
+		acc += float(weights[i].get("prob", 0.0))
+		if r < acc:
+			return picks[i]
+	return picks[picks.size() - 1]
+
 # stored height field (filled in _generate_map); bilinear read for smooth slopes
 func height_at(p: Vector2) -> float:
 	if height.size() != MAP_W * MAP_H:
```

**L01's own delta against its backup = hunk 2 (9 insertions) + hunk 3 (141 insertions) = 150 inserted lines, 0 deletions.** Hunk 1 is Y03's pre-existing 12-line neutralisation and was not edited.

---

## 3. What the new pass actually does (DERIVED from the applied code)

- **Source geometry** — only `kind=="forest"` stamps in `pattern_stamps` (A04 measured 117 on seed 20261113). For each, it recomputes the **same filled core disc** `_gen_patterns()` uses (`cext*0.25` clamped to `[14,22]·TILE`, ×`size_k`, bbox, `7·TILE` start-ring keep-clear, terrain 3/4/5 exclusion). The disc is grouped into per-row contiguous accepted-x lists; `rows` keys are inserted in ascending `y`.
- **No lattice / no noise** — a spot is a 4-connected horizontal run of 1–6 accepted cells; start is `brng.randi_range` within the row extent, not `(x,y)` parity. Every probability is a live donor weight read from `tbl_smooth`; no `_hash2`, no dither, no gain/luminance field.
- **Guard-rail on the run** — a candidate run is painted only if **all** its cells were accepted by the water / mine / terrain / start-ring / base-id filters (`accx.has`), so a row's min/max cannot leak a spot into a filtered cell.
- **Palette** — dark: `grass5` from `_tb_pick(7,1)` (Item 7 J=1, cfg:762, prob 1.0). Light: `grass9`/`test9`/`test8` from cfg:798's `.36/.28/.36` weights (PORT APPROX mapping of donor transition weights onto clean light ids). Polarity: cfg:846 `.4` light / `.6` dark. Length: cfg:67 six weights `.16×5/.20` → 1–6.
- **Order** — spots are written after B03's tile stamps and before the unchanged 3-pass smoother; forest borders, mine apron and winter alias still run afterwards and win.

---

## 4. Invariance proof vs Y03 / B03 (DERIVED from the diff)

| Invariant | Status | Proof |
|---|---|---|
| **Y03 grass9 neutralisation** | **intact** | Hunk 1 is verbatim; `tex = _blk("grass9")` occurs exactly once (static anchor count = 1). The two B03-P1 `_tb_pick(2,5)` / `_tb_pick(1,4)` calls above it are unchanged, so Y03's zero-RNG-delta property is preserved. L01 adds a *separate* pass; it never reads the detail bitmaps or `height` for spot placement. |
| **B03-P1 / P2 / P3** | **intact** | P1 detail re-roll lines unchanged; P2 `kind=="tile"` → `ground1` loop unchanged (anchor `if str(pst.kind) != "tile":` count = 1); P3 redirect block in `_tb_pick` unchanged. New code adds no redirect and no change to `_tb_pick`. |
| **terrain=5 removal (L03)** | **intact** | The gradient pass remains collision-only; the new pass performs **zero** `terrain` writes. Stone-quarry `terrain=5` disc at `:852` untouched. |
| **`height` / `blocked` / `res_nodes` / `map_starts` / `rng` / `gen_rng`** | **byte-identical** | New pass writes only `tileblock`. It *reads* `map_starts` for the same 7-tile keep-clear already used in `_gen_patterns`, and reads `terrain`/`mine_mask`. `_gen_patterns()` replay and mapgen/gameplay streams untouched. |
| **`tileblock` contract** | **intact** | `PackedByteArray` size `MAP_W*MAP_H`, uint8 ids unchanged; `BLK_WATER=255` never written (guard); `grass9/test9/test8/grass5` all exist in `tbl_idx` (124 names); no out-of-atlas id introduced. |
| **Mine apron / winter alias** | **intact and last** | Final `for mi in mine_mask` → `ground1` loop and `winter_tile_names` alias block remain after the smoother and forest borders; spot ids are Summer ids and are aliased normally. |
| **`_tb_smooth_pair` / `_tb_pick` / `_smooth_tilemap` logic** | **unchanged** | No edit to any of the three; `_smooth_tilemap(brng,3)` called once with the same arguments, now after the new pass. Spot ids `grass9` (Item 3/4 J=5), `test9` (Item 3/4 J=6), `test8` (Item 1 J=4), `grass5` (Item 7/8 J=1) all occur in `tbl_smooth`, so no orphan id reaches the smoother. |
| **S-25-09 / no synthetic field** | **honoured** | No new bitmap, mask, hash, dither, noise or luminance term. Static check: `dither(` = 0, `noise(` = 0 in the whole file; the 5 `_hash2(` and 6 `_noise2(` hits are pre-existing terrain/decor helpers at `:620,:1272,:2498,:2524-2539,:2557,:2577`, all outside the added region (`:2359–2493`). |
| **Shader / atlas / mesh / tests / config / `app/`** | **untouched** | Only `game.gd` was edited; no other source file changed by this ticket. |
| **Determinism** | **preserved** | Same seed → same `brng` seed (`Data.RANDOM_SEED+7`) → same stamp iteration → same rows/lengths/starts/polarity/ids → same bytes. `t_map_variety same_seed_byte_identical` holds by construction. Frozen tileblock hashes are **not** a valid gate (B03 R1 / TRN-DATA precedent). |

### 4.1 Documented RNG delta (required by L01 §9 R7)

Unlike Y03 (zero delta), L01 **does** add `brng` draws — all before `_smooth_tilemap`, all documented here:

- 1 `randf()` per pass invocation for `_tb_pick(7,1)` (dark id).
- Per accepted disc row: 1 `randf()` for eligibility (`< 0.36`), then on eligible rows 1 `randf()` for run length, 1 `randi_range()` for start, 1 `randf()` for polarity, and **only on light rows (~40%)** 1 `randf()` for light-id choice.
- Exact totals depend on stamp count/geometry and are **UNVERIFIED** without a runner; the sequence is deterministic for a given seed.
- Consequence: tileblock bytes change for every seed and later smoother/forest-border picks shift relative to Y03. This is the accepted TRN-DATA precedent; gameplay streams (`rng`, `gen_rng`, terrain, blocked) do **not** shift.

---

## 5. Static verification actually performed (no Godot, no runner)

- `Get-FileHash` before copy: both `game.gd` and `game.gd.bak-L01` SHA-256 `851E8153…AA9AF4`; `git hash-object` on both `e0c2b5ed…`.
- `git apply` was **not** used for L01 (targeted tool edits were used); `git diff --check -- variant3d/scripts/game.gd` exited **0** (no whitespace error).
- Read-only Python checker (`...\Temp\opencode\l01_impl_check.py`, outside the repo): stripped comments/strings and verified bracket balance `{'(':0,'[':0,'{':0}`, no unterminated string; verified anchor counts (Y03 neutralisation 1, `_stamp_grass_spots(brng)` call 1, four new function definitions 1 each, smoother call 1, mine-apron authority 1).
- Verified call order by line number: `_stamp_grass_spots(brng)` `:2130` → `_smooth_tilemap(brng,3)` `:2134` → `_stamp_forest_borders(brng)` `:2137`.
- Verified helper table indices against `DONOR_SMOOTH_RULES` in the file: `tbl_smooth[0][3]` = Item 0 J=3 cfg:67; `[8][2]` = Item 8 J=2 cfg:798; `[9][3]` = Item 9 J=3 cfg:846; `[7][1]` = Item 7 J=1 cfg:762 (Item 10 has no active lists and is omitted, so indices 0–9 = Items 0–9).
- **No Godot process, no `godot_runner.py`, no queue/lock/counter mutation, no donor file read or copy.**

---

## 6. Risks / limitations (INFERRED / UNVERIFIED)

1. **Y06's corrugation may persist.** Y06's R1/R2 FAIL was attributed to Y03 forcing one atlas cell (`grass9`) over the height-derived detail field. L01's spots are confined to forest-stamp cores; the open detail field stays uniform by explicit directive. This change is **not claimed** to fix R1/R2 or the nested bands (R5). If corrugation persists, that is a separate shader/atlas/detail-density ticket, not a reason to weaken this one.
2. **Coverage.** A04 measured ~117 forest stamps; eligibility ≈0.36 and run length ≈1–6 give limited spot density. Whether frame-level `BV32`/luma bands move is **UNVERIFIED** until a matched capture.
3. **Repeated spot art.** `grass9/test9/test8/grass5` are four cells; many identical runs could read as a larger pattern. Density is donor-weighted and moderate; monitor C04 R1/R3 and `tile_repeat`.
4. **`grass5` bottom edge** (A03 ΔYy −3.16) and differing donor smoothing groups may expose faint steps or let the smoother erode runs. Donor smoothing rules are unchanged by design; no custom compatibility rule added.
5. **RNG delta** (§4.1) changes tileblock bytes relative to Y03; use `same_seed_byte_identical`, not a frozen hash.
6. **Donor runtime activity UNVERIFIED** — all donor `.inc` code is `;`-commented (RV-TRN-02 §4.6); the weights are real bytes, the role reassignment is PORT APPROX. **No donor parity claim.**

---

## 7. Gate list for G04 (L01 runs none — one Godot at a time)

Run on the post-L01 tree with unique ids; **no threshold lowered, no assertion deleted, no expected-failure flipped**:

1. `variant3d` selftest — expect **29/29**.
2. `variant3d` uitest — expect **17/17**.
3. `t_render_mode` — green.
4. `t_map_variety` — **5/5**, including `same_seed_byte_identical` (two runs of the same seed must match; **do not** use a frozen tileblock hash).
5. `assert_clean` — **CLEAN**.
6. 2D `app/` gates — untouched, still green.
7. **Matched-camera captures** with `--seed 20261113`, unique ids, same harness/camera/zoom for both arms: a fresh **post-Y03 BEFORE** and a **post-L01 AFTER** real-map PNG (and 64² P0). Record paths, timestamps, camera and result JSON fields verbatim. Y06's `y03\realmap.png` lacks `stderr.txt`/camera diag, so it is **not** an admissible controlled BEFORE on its own (Y06 §1).
8. C04/G05 R1–R6 visual read on the AFTER frame: check especially that no **new** checker/lattice appears from the spots; no repeated dark blotches; no new seams/black rows; `non_black_fraction=1.0`, `full_width_dark_rows=0`. R7/R8 need CAP-3 frames if in scope (Y06 had none).
9. **C01 metric** (`terrain_ab_metric.py`) on the identical crop for both arms — `BV32`, `grad`, luma std, `tile_repeat`, `coherence`. These are **movement indicators only, never thresholds or parity**. A11 bands (BV32 n640 8.7→≈150–270, grad 5.0→≈1–2, luma std 10.6→≈18–22) were defined against the pre-fix frame; the immediate BEFORE for this ticket is post-Y03 (Y06 measured mean_luma 77.35, std_luma 19.54, `tile_repeat 0.796493`, `coherence 0.311491`), so record both and do not silently swap baselines.
10. Optional read-only dump probe (same post-L01 run): decode `stats.tile_index_hist` (`world3d_terrain.gd:1570,1641`) and confirm `grass5`, `grass9`, `test9`, `test8` are present; check spot runs are 1–6 contiguous cells and no out-of-atlas id. A04's component targets are directional here because Y03 changed the field's id distribution.

---

## 8. Rollback

```powershell
Copy-Item -LiteralPath 'inbox\backup\game.gd.bak-L01' -Destination 'variant3d\scripts\game.gd' -Force
```

Restores `game.gd` to blob `e0c2b5ed28979d65ee0505b77ad33259a925847a` / SHA-256 `851E81537F1ACADB281B08CE42B65EEEF6BF946EC7003374E1B6C251BBAA9AF4` (the exact post-Y03 state), removing only L01's two hunks. To remove Y03 as well, use `game.gd.bak-Y03` (a different baseline) — do not conflate the two.

---

## 9. Scope statement

Repo files changed: `variant3d/scripts/game.gd` (two added hunks) and this report. One backup file created outside the source tree. One read-only checker written to the pre-approved temp folder. No shader, atlas, asset, config, test, `world3d_terrain.gd`, `pattern_gen.gd`, donor file, git write, runner job or Godot process. Whether the spots improve the rendered terrain is **UNVERIFIED** until G04's matched-camera captures and metrics; **no donor parity or gate PASS is claimed**.

*End of L01-IMPL. Applied on top of Y03; exclusive `game.gd` ownership released back to COORD after this report.*
