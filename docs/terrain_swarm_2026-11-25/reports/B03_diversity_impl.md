---
id: B03
ticket: TERRAIN-SWARM-2026-11-25 / B03 (IMPLEMENTATION, exclusive owner)
title: "Raise large-scale tile diversity / kill repeated-texture read — game.gd only"
owner: B03 (exclusive owner of variant3d/scripts/game.gd)
created: 2026-11-25
status: DELIVERED__NO_GODOT_JOB__COORD_GATES_PENDING__RELIEF_FIX_ADDED
backup: inbox/backup/game.gd.bak-B03
relief_backup: inbox/backup/game.gd.bak-B03-relief
files_changed:
  - variant3d/scripts/game.gd
  - docs/terrain_swarm_2026-11-25/reports/B03_diversity_impl.md
labels: [observed, derived, inferred, UNVERIFIED, PORT APPROXIMATION]
parity_guard: "No donor GPU A/B frame exists. No donor-parity claim is made."
---

# B03 — diversity implementation report

## 0. Mandate actually executed

Charter read in full first. The four COORD follow-ups were read and folded in, in
this order of authority (latest first):

1. **A03** (`A03_atlas_cells.md` §2/§4): `grass_ground1/2/3` (idx 14/15/16) are the
   worst repeating lattice art; redirect them to clean donor ids `grass9/test8/test7`.
2. **A11** (`A11_reference_metrics.md` §3): our BV32 native = **9.9** vs green-reference
   median **141.1** (14.2x; normalised 8.7 vs 247.6 = 28.6x). Energy must move to
   low spatial frequency via **tile-id diversity**, not a luminance field.
3. **A04** (`A04_tile_diversity.md` §6): **P1** re-roll bitmap `test7/test8` through
   their own donor lists; **P2** consume stored `kind=="tile"` stamps as `ground1`
   before smoothing; **P3** (full 25-unit donor grid) explicitly **not** in this ticket.
4. **A08** (`A08_donor_truth_local.md` §1): donor mottling is **tile identity**, not a
   luminance delta; the detail-bitmap pass is present and must stay donor-data-driven.
5. **F04** §2 F-1/F-2 and P0-3: low-frequency grass colour must come from existing
   tile/pattern data or donor relief only; no synthetic dither/noise (S-25-09).

Implemented: **A04 P1 + P2 + the A03 `grass_ground*` art redirect (labelled P3 here,
not to be confused with A04 P3)**. A04 P3 and A05 Fix #1 were **not** landed — see §6.

No Godot process, runner job, donor binary copy, shader, atlas loader,
`world3d_terrain.gd`, config, or test was touched. `app/` untouched.

## 1. Backup

`inbox/backup/game.gd.bak-B03` — byte copy of `variant3d/scripts/game.gd` taken
before the first edit (238,546 bytes). Diff below is against that file.

## 2. Exact diff / hunks

Post-edit line numbers refer to the current `variant3d/scripts/game.gd`.

### Hunk 1 — `_apply_detail_pass()` signature (current `:1913`)

```diff
-func _apply_detail_pass() -> void:
+func _apply_detail_pass(brng: RandomNumberGenerator) -> void:
```

### Hunk 2 — P1: re-roll the two bitmap transition ids (current `:1936-1950`)

```diff
 			var sx: int = clampi(int(float(x) / float(MAP_W) * float(iw)), 0, iw - 1)
 			var sy: int = clampi(int(float(y) / float(MAP_H) * float(ih)), 0, ih - 1)
 			var tex: int = int(im.get_pixel(sx, sy).r * 255.0) / 2
+			# B03-P1 (PORT APPROXIMATION, A04 §6 P1): the donor writes its two
+			# transition ids verbatim from the bitmap, which paints ~15% of the
+			# map one dark atlas cell. Re-roll ONLY those two through the donor
+			# lists that already contain them (RV-TRN-02 §7: Item 2 J=5
+			# test7/grass8/test6 cfg:267; Item 1 J=4 grass1/grass2/test8 cfg:155)
+			# using the port's existing weighted picker. No new id, no mask edit,
+			# no synthetic dither/noise field (charter S-25-09).
+			if tex == _blk("test7"):
+				var pick7 := _tb_pick(2, 5, brng)
+				if pick7 >= 0:
+					tex = pick7
+			elif tex == _blk("test8"):
+				var pick8 := _tb_pick(1, 4, brng)
+				if pick8 >= 0:
+					tex = pick8
 			if tex >= 0 and tex < tbl_names.size():
 				tileblock[i] = tex
```

### Hunk 3 — P2: call-site change + consume `tls_*` stamps (current `:2039-2063`)

```diff
-	_apply_detail_pass()
+	_apply_detail_pass(brng)
+	# B03-P2 (PORT APPROXIMATION, A04 §6 P2): restore the donor's
+	# SetupTiledPatterns('tiles') background-detail pass structurally. The tls_*
+	# masks are real donor decal footprints placed by pattern_gen.gd:230-251 and
+	# stored on kind=="tile" stamps, but game.gd:838-839 drops them (they are
+	# thin decals, not terrain recolour). Paint their exact donor mask cells with
+	# the nearest existing donor id, ground1 (Item 9 J=0 cfg:818 / donor
+	# texturemap.inc:622-642 worked ground). No new stamp, no RNG draw, no change
+	# to terrain/blocked - the mapgen stream stays byte-identical; the 3-pass
+	# donor smoothing below reconciles the new borders with donor rules and the
+	# final mine-apron authority still wins. P3 (full 25-unit donor grid) is
+	# deliberately NOT attempted: it touches pattern_gen.gd and the stamp RNG.
+	for ps in pattern_stamps:
+		var pst: Object = ps
+		if str(pst.kind) != "tile":
+			continue
+		for pc in (pst.cells as Array):
+			var pcc: Vector2i = pc
+			var px: int = int(pst.x) + pcc.x
+			var py: int = int(pst.y) + pcc.y
+			if px < 0 or py < 0 or px >= MAP_W or py >= MAP_H:
+				continue
+			var pti := _t(px, py)
+			if tileblock[pti] != BLK_WATER:
+				tileblock[pti] = _blk("ground1")
 	# 4) exact 3-pass SmoothTileMap (donor smoothtiles.inc:191-237): three
```

### Hunk 4 — A03 art redirect in `_tb_pick()` (current `:2182-2196`)

```diff
 		if p > 0.0 and r < acc:
-			return _blk(str(td.get("name", "")))
+			var nm := str(td.get("name", ""))
+			# B03-P3 (PORT APPROXIMATION, A03 §2/§4): the donor lists that emit
+			# grass_ground1/2/3 (Item 4/5/6 J=3, 0.64/0.0028/0.36, and Item 8 J=2)
+			# stay verbatim in DONOR_SMOOTH_RULES; only the ART chosen for those
+			# three draws is redirected to clean donor ids (A03: grass9 = best
+			# isotropic/seamless; test8/test7 = good isotropic/seamless). No new
+			# id, no extra RNG draw, no luminance/noise/dither field. The donor
+			# does not swap art by quality, so this is an explicit port-level
+			# substitution, not donor parity (UNVERIFIED).
+			if nm == "grass_ground1":
+				return _blk("grass9")
+			if nm == "grass_ground2":
+				return _blk("test8")
+			if nm == "grass_ground3":
+				return _blk("test7")
+			return _blk(nm)
 	return -1
```

**Diff totals:** 57 lines added, 3 removed, 4 hunks. A Python static bracket/quote
balance check (no Godot) reports `{ '(': 0, '[': 0, '{': 0 }`.

## 3. Donor citations and PORT APPROX labels

| Change | Data source | Label |
|---|---|---|
| P1 `test7` list | `RV_TRN_02_smoothing_rules.md` §7 Item 2 J=5, `tilesmooth_scripts.cfg:267` = `test7:1, grass8:1, test6:1` (SumProb 3); embedded verbatim at `game.gd:1588` | **PORT APPROXIMATION** — the donor does not re-roll bitmap output; we apply its own list a second time |
| P1 `test8` list | `RV_TRN_02` §7 Item 1 J=4, `cfg:155` = `grass1:1, grass2:1, test8:1`; embedded at `game.gd:1579` | **PORT APPROXIMATION** (same reason) |
| P1 picker | Existing `_tb_pick()` (`game.gd:2166-2183`) — donor weighted roulette, unchanged logic | donor-rule mechanism, OBSERVED in port |
| P2 paint id | `ground1`, Item 9 J=0 `cfg:818` / donor `texturemap.inc:622-642` worked ground; id exists in `presets_summer.json` idx 10 | **PORT APPROXIMATION** — donor `tls_*` are a decal layer; the port has none, so the nearest existing donor id is used |
| P2 footprints | Real exported donor `d_tls_1..d_tls_4` masks, placed by `pattern_gen.gd:230-251`, stored on `kind=="tile"` stamps; A04 §4 confirms the live game drops them at `game.gd:838-839` | donor asset + **PORT APPROX** substitution for the decal |
| P3 redirect targets | `grass9` = donor Item 3 J=5 `cfg:359` / A03 §4 "best: isotropic, seamless"; `test8` = Item 1 J=4 / Item 9 J=3 `cfg:846`; `test7` = Item 2 J=5 / Item 9 J=3. All ids are in `presets_summer.json` | **PORT APPROXIMATION** — donor does not swap art by measured quality; no donor parity claim |
| `0.64/0.0028/0.36` anomaly, `Prob=0` separators, all 118 lists | `DONOR_SMOOTH_RULES` | untouched, OBSERVED donor text per RV-TRN-02 |
| No synthetic field | Charter §3 decision S-25-09; A08 §7 #2 (no dither/noise/beauty field) | guardrail honoured — no `_hash2`, no gain grid, no bitmap edit |

## 4. Determinism reasoning

- `brng` is created fresh inside `_assign_tileblocks()` with `brng.seed =
  int(Data.RANDOM_SEED) + 7` (current `:1984-1985`) and is used **only** for tile
  decisions: base family draws, `_apply_detail_pass`, `_smooth_tilemap`,
  `_stamp_forest_borders`. Grep confirms no other consumer. Terrain, `blocked`,
  `res_nodes`, `map_starts`, `rng` and `gen_rng` are untouched by any of the four
  hunks. So gameplay/mapgen seed replay stays byte-identical.
- P1 consumes extra `brng.randf()` draws (one per bitmap-cell reading `test7`/`test8`).
  This deterministically shifts later smoothing/border draws, so **tileblock bytes
  change for a given seed** — accepted by the existing TRN-DATA precedent
  (`game.gd:2079-2080`: "changes the tileblock bytes but leaves every other seed
  output byte-identical"). Two runs of the same seed still produce the same bytes
  (`t_map_variety same_seed_byte_identical` invariant preserved by construction).
- P2 consumes **no RNG at all** — it only reads already-placed stamps. The mapgen
  stamp stream, `terrain` and `blocked` are unchanged; the `pass` at `:838-839`
  remains, so `_gen_patterns()` replay is identical.
- P3 redirect consumes **no RNG** — it is a pure name→id substitution after the
  donor roulette has already drawn. `_tb_smooth_pair()` still keys compatibility
  on group indices (tile *names*), not on the returned art id, so smoothing
  topology is unaffected.
- All new ids are looked up through `_blk()` against `tbl_idx`, populated from
  `presets_summer.json`; no out-of-atlas id can be emitted. The water guard in P2
  preserves `BLK_WATER`; the final mine-apron authority (`:2074-2076`) still wins;
  `tileblock` size and uint8 type are unchanged; forest start keep-clear in
  `_finalize_mine_tiles()` still overwrites the same cells. Top-level tileblock
  contract intact.

## 5. Expected direction (INFERRED — no live histogram produced)

- A04 §7 offline baseline (post-TRN-DATA): top-5 58.52%, `test7+test8` 14.89%,
  distinct 32. P1 should push `test7+test8` to roughly 5-6% and raise distinct ids
  as `grass8/test6/grass1/grass2` appear; A04 estimates distinct >= 35.
- P2 touches only the 4 surviving `tile` stamps on seed 20261113 — a small but
  structurally real restoration of a discarded donor pass; larger gain needs
  A04 P3 (separate ticket / owner).
- P3 should remove the worst lattice art wherever smoothing still emits
  `grass_ground*`. Note A03's 43% figure comes from **pre-TRN-DATA** dumps; the
  current tree's forest base is already `DONOR_FOREST_BASE`
  (`grass7/test12/13/14`, `game.gd:1724`), so `grass_ground*` now arises mainly
  as a smoothing midpoint — the redirect is defensive rather than a 43% rewrite.
- A11's BV32 deficit cannot be claimed closed by these changes: no live render was
  produced (no Godot by ticket order). Whether id diversity alone moves enough
  energy to low frequency is **UNVERIFIED** until COORD's render gate.

## 6. Explicitly NOT done (with reasons)

- **A04 P3** (`pattern_gen.gd:230-231` full 25-unit grid): different owner file,
  A04 §6 itself marks it higher risk (touches stamp RNG/occupancy). Not attempted.
- **A05 Fix #1 (extra donor relief grids)** — **deferred, not abandoned**. COORD
  asked for "full derived numeric tables from DPATTERN_01", but:
  (a) `DPATTERN_01` does **not** contain full `w×h` float32 tables; its Appendix A
  explicitly says the 8×10 block means are *"debug/preview aids only — stamp from
  the full grid, not from these means"* (`DPATTERN_01:595-600`);
  (b) A05 §7.5 records that full windows are **not in the port** and exporting them
  is a derived-data task; embedding ~8,400 floats per pattern in `game.gd` (and my
  ownership forbids adding an asset file) would be disproportionate;
  (c) A05's acceptance needs runtime proof (`candidates>0`, `applied_cells>0`,
  changed hashes, a cell below −2.0) and this ticket is forbidden to run Godot;
  (d) adding height/collision stamps changes `terrain` and `tileblock` for many
  seeds, risking the mapgen/scan gates COORD owns.
  I did derive and **verify** the 8×10 tables from the donor `.pattern` files using
  the documented Appendix A method, reproducing A1/A2 to <=0.0005; they can be
  handed to a dedicated relief ticket. No relief code was changed here.
- No shader, atlas/blocks, `world3d_terrain.gd`, `pattern_gen.gd`, config or test
  edit. No donor asset copied. No luminance/noise/dither field of any kind.

## 7. Risk list

| # | Risk | Severity | Mitigation / gate |
|---:|---|---|---|
| R1 | P1's extra `brng` draws change tileblock bytes for every seed; a fixed-hash baseline would fail | medium | Expected and deterministic; TRN-DATA precedent; use `same_seed_byte_identical` (two runs), not a frozen hash |
| R2 | P1 donor list Item 1 J=4 can return `grass2`, which A03 §2/§4 flags as vertical-streak/wrap-cut art (~1/3 of re-rolled `test8`) | medium | Left donor-faithful per COORD's exact P1 diff; if COORD wants it removed, redirect `grass2` in a follow-up with its own PORT APPROX label |
| R3 | P2 uses `ground1`, which A03 §4 calls off-palette grey-brown; OK only because `tls_*` are dirt/crack decals | low | Documented as nearest donor worked-ground id; footprint is 4 stamps on the shipped seed |
| R4 | P3 removes `grass_ground*` ids entirely from smoothing output; a test asserting their presence would fail | low | No test references those ids (grep of `variant3d/**/*.gd`); contract is id validity, not specific ids |
| R5 | Both P2 and P3 touch the smoothing input, so changes to top-5 / component size are unverified without Godot | medium | COORD gates: `t_map_variety` 5/5, selftest 29/29, uitest 17/17, `t_render_mode`, `assert_clean CLEAN`; A04 §7 component target <800 largest / <15% in >=100 |
| R5b | Redirected ids belong to **different donor smoothing groups** than `grass_ground*` (e.g. `grass9` is Item 4 J=5 vs `grass_ground1` J=3), so `_tb_smooth_pair` `abs(Δ)` decisions near redirected cells change; compatibility is still computed from donor lists only | low | No custom rule introduced; `grass9/test8/test7` all occur in `tbl_smooth` (Items 3/4/9 etc.), so no orphan id; determinism unaffected. Verify via the A04 component scan gate. |
| R6 | No donor GPU A/B frame exists — none of the visual improvement is confirmed | high (epistemic) | All visual claims labelled INFERRED / UNVERIFIED; no parity assertion |
| R7 | Two `_assign_tileblocks()` calls per setup path consume `brng` twice; P1 draw counts differ between the calls | low | Both calls re-seed `brng` identically, so output is stable; already true before this change |

## 8. Verification actually performed (no Godot)

- Read charter + A03/A04/A05/A08/A11/F04 reports before editing.
- Verified `_tb_pick(2,5)` and `_tb_pick(1,4)` map to the correct authored lists in
  `DONOR_SMOOTH_RULES` / `tbl_smooth` (Items 2 and 1, J=5 and J=4).
- Verified `pattern_stamps` is populated (`game.gd:741`) and `Stamp.kind/x/y/cells`
  are the fields used elsewhere (`:744-758`).
- Verified `brng` has no consumer outside tile selection (grep, 23 hits).
- Verified every redirected/picked id exists in `presets_summer.json` (124 names).
- Verified UTF-8 encoding of inserted comments and static bracket/quote balance.
- **Did not** run Godot, any runner job, or any test — per ticket order.

## 9. Maze regression — investigation and verdict (2026-11-25, urgent follow-up)

Opened `...\opencode\g04\realmap.png`. It shows dense nested contour/maze bands
with sharp stair-steps, at fixed map positions. COORD then supplied the decisive
owner clarification: *"those maze patterns have always been there — that's what I
was talking about; color changed but pattern is still same and position +- is the
same."* So the maze is **pre-existing and position-locked**, not a new B04/shader
artifact.

**My diversity hunks were investigated and ruled out as the maze source:**

- P2 paints `kind=="tile"` stamps. I decoded their real masks from
  `donor_patterns.json`: `d_tls_1..4` carry 513-572 cells each in ~25x33..33x44
  donor-cell boxes (nested maze shapes). At 320² (`s=2`) one stamp is ~2,000
  painted cells; A04 §4 measured only **4** surviving tile stamps on seed
  20261113 (~8% of cells, not map-wide, and not position-locked to relief
  terraces). P2 changes `tileblock` art only — it never writes `height`,
  `terrain` or `blocked`. It cannot create elevation contours.
- P3 (the `grass_ground*` art redirect) is a pure post-roulette id substitution;
  it changes **which art** is sampled, not the spatial distribution, and adds no
  RNG draw. It cannot create new ring geometry.
- The maze geometry is driven by `terrain[i]=5` rock-art paint on relief
  terraces, which routes those cells to rock atlas cells in `_assign_tileblocks`.
  B04's face promotion was fully reverted; the rings remain — consistent with
  the owner's "always been there" statement.

**No diversity hunk was reverted.** COORD traced the cause to `game.gd` relief
code that is also in my exclusive file; the fix is §10.

## 10. Relief HEIGHT-ONLY fix (owner's hypothesis, COORD-mandated)

Fresh backup taken first: `inbox/backup/game.gd.bak-B03-relief` (241,205 bytes,
i.e. including all of §2's diversity work). Diff below is against that backup.

### Why the rings formed (DERIVED from current source)

- `_shape_stamp_relief()` writes height with a **fixed 6-tile rim**
  (`rim_tiles = 6`, `:995-1001`) and `f = clamp((edge-d)/rim, 0, 1)`. For a
  320² footprint (~84 cells half-extent) the rise is ~2.964 over ~6 cells,
  i.e. |dh| ~0.5 per cell — right at the gradient threshold. Each stamp's
  rim therefore becomes a closed ring of `terrain=5`.
- The 2-pattern `_relief_donor_mask` only covers `plt2`/`k_ravine_1`; the
  analytic fallback (`plateau`/`plain`/`mountain`/`hill`/`ravine`) — which makes
  most rings — is unmarked. Using `_relief_donor_mask` alone would have skipped
  almost nothing.
- The `"hill"` branch in `_gen_patterns()` also painted `terrain[ii]=5` for
  `dc<=2.2`, adding rock-art discs on hill stamps.

### Exact diff (relief-only, 6 hunks)

```diff
@@ -71,6 +71,13 @@
 var _relief_donor_mask: PackedByteArray = PackedByteArray()
+# B03-RELIEF: every cell whose HEIGHT was written by _shape_stamp_relief
+# (donor-grid branch OR analytic fallback), plus the near_start protection ring.
+# The gradient/collision pass uses it to keep relief terraces from being painted
+# as rock ART (the owner's concentric maze).  `blocked[]` is still applied there,
+# so walkability is byte-identical; only the terrain=5 art paint is suppressed.
+# PORT APPROXIMATION — the donor's cliff-promotion rule is UNVERIFIED (RV-TRN-01).
+var _relief_stamp_mask: PackedByteArray = PackedByteArray()
```

```diff
@@ -844,12 +851,14 @@  (in _gen_patterns)
 				"hill":
-					# P-47: ... Keep only the terrain paint; never mutate height...
-					if dc <= 2.2:
-						terrain[ii] = 5
+					# B03-RELIEF: height-only relief. The old terrain[ii]=5 here
+					# painted donor hill footprints as ROCK ART (the concentric
+					# maze the owner reported); relief HEIGHT is already written
+					# by _shape_stamp_relief() in _gen_base...
+					pass
```

```diff
@@ -948,6 +957,8 @@  (in _shape_stamp_relief)
 	_relief_donor_mask.resize(MAP_W * MAP_H)
+	_relief_stamp_mask = PackedByteArray()
+	_relief_stamp_mask.resize(MAP_W * MAP_H)
@@ -964,6 +975,9 @@  (near_start ring)
 					near_start[y0 * MAP_W + x0] = 1
+					# B03-RELIEF: suppress rock ART on the near_start step too.
+					_relief_stamp_mask[y0 * MAP_W + x0] = 1
@@ -1054,6 +1068,7 @@  (donor-grid height write)
 					_relief_donor_mask[i] = 1
+					_relief_stamp_mask[i] = 1
@@ -1100,6 +1115,26 @@  (analytic height write + dilation)
 				height[i] = clampf(height[i] + amp * f, RELIEF_RAVINE, RELIEF_PLATEAU)
+				_relief_stamp_mask[i] = 1
+	# B03-RELIEF: dilate one cell (8-neighbourhood). The gradient pass sees a
+	# |dh|>0.5 STEP from an un-stamped cell adjacent to a relief terrace; that
+	# outside cell would otherwise still be painted as a rock-ART ring. Only the
+	# mask grows - no height, blocked, terrain, rng or tileblock write here.
+	var _rm_dil := PackedByteArray()
+	_rm_dil.resize(MAP_W * MAP_H)
+	for y in MAP_H:
+		for x in MAP_W:
+			if _relief_stamp_mask[_t(x, y)] == 0:
+				continue
+			for dy in range(-1, 2):
+				for dx in range(-1, 2):
+					var nx: int = x + dx
+					var ny: int = y + dy
+					if nx >= 0 and ny >= 0 and nx < MAP_W and ny < MAP_H:
+						_rm_dil[_t(nx, ny)] = 1
+	for ri in _rm_dil.size():
+		if _rm_dil[ri] != 0:
+			_relief_stamp_mask[ri] = 1
```

```diff
@@ -1260,7 +1295,16 @@  (gradient/collision pass)
 			if steep:
-				terrain[i] = 5
+				# B03-RELIEF: relief stamps own HEIGHT only. Their terraced rims
+				# (and the near_start step that borders them) must not be painted
+				# as rock ART - that is the owner's concentric maze. The stamp
+				# mask covers both donor-grid and analytic-fallback cells; the
+				# 2-pattern _relief_donor_mask alone would miss the analytic rims
+				# that make most rings. Real donor rock/stone collision OUTSIDE
+				# relief stamps is unchanged. `blocked[]` is still applied to
+				# EVERY steep cell, so walkability/start protection are intact.
+				if _relief_stamp_mask[i] == 0:
+					terrain[i] = 5
 				set_blocked_tile(x, y, true)
```

**Stone stamps kept.** Their paint is `dc<=3.2 → terrain=1`, `dc<=1.6 →
terrain=5`: a small solid quarry disc, not a concentric footprint ring. Stone
stamps are never relief-stamped (`_shape_stamp_relief` matches only
plateau/plain/mountain/hill/ravine), so this is real donor quarry collision and
stays.

### Invariant proof

| Invariant | Status | Reason |
|---|---|---|
| `height[]` | **unchanged** | No height write added or removed; `_shape_stamp_relief` still clamps at `:1068/:1117`; the dilation writes only `_relief_stamp_mask` |
| `blocked[]` | **byte-identical** | `set_blocked_tile(x,y,true)` still executes for every steep non-water/sand cell; the guard wraps ONLY `terrain[i]=5` |
| `water`/`sand` shore | unchanged | Gradient pass still `continue`s on `terrain==3/4`; shore tile logic untouched |
| Start protection | unchanged | `near_start` mask and `_finalize_mine_tiles()` keep-clear untouched; start cells additionally exempt from rock art |
| Mine apron | unchanged | `_assign_tileblocks()` final authority and `mine_mask` untouched |
| `tileblock` size / uint8 / contract | unchanged | No tileblock write; fewer `terrain=5` cells only change which donor id the existing `match t` picks |
| RNG / determinism | unchanged | No `rng`/`brng`/`gen_rng` draw added or removed; the `"hill"` branch never drew RNG; dilation is pure boolean work. Same seed → same bytes |
| Real donor rock/stone collision | unchanged | Non-relief steep cells still get `terrain=5`; stone quarry paint kept |
| `relief_grid` ledger | unchanged | No new grids; A05/G07 deferral stands |

`scan_map.py:246-248` explicitly measures `cliff_ring` as **blocked / steep**,
not rock paint ("Rock PAINT is not collision"), and `rock` has no pass threshold
(`:478-493`) — so preserving `blocked[]` while removing the art keeps that gate
valid. Static bracket/quote balance check passes.

### New risks

| # | Risk | Mitigation |
|---:|---|---|
| R8 | `patches`/`mean_sz` scan metrics (forest connectivity) may shift where relief cells stop being terrain=5 | COORD's scan gate; no threshold edited |
| R9 | One-cell dilation exempts cells adjacent to relief stamps from rock art, including some genuine donor steep cells near stamp rims | Still blocked (collision preserved); visual-only change; A05 says donor promotion rule is UNVERIFIED |
| R10 | The maze may persist if its source is a `terrain=5` paint outside `_shape_stamp_relief` and the gradient pass | Re-capture after this change; if still present, the next suspect is `_assign_tileblocks` cliff/shore overrides, not B03 diversity hunks |
| R11 | No donor GPU A/B frame | All claims labelled INFERRED/UNVERIFIED; no parity assertion |

**Not run:** Godot, runner jobs, or tests — per ticket order. Available for
COORD's re-capture and further isolation.

*End of B03 report.*
