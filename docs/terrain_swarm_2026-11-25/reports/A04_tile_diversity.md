---
id: A04
ticket: "TERRAIN SWARM A04 — why the ground uses too few distinct tiles"
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_CODE_EDIT__NO_GODOT_JOB
scope: "ONE new report written. No game code, shader, asset, config, test or git edit. No Godot runner job, no donor file executed or copied."
owner_files:
  - docs/terrain_swarm_2026-11-25/reports/A04_tile_diversity.md
labels: [observed, derived, inferred, UNVERIFIED]
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
inputs_read:
  - docs/terrain_swarm_2026-11-25/CHARTER.md
  - docs/coord_swarm_2026-11-25/reports/TRN_DATA_implementation.md
  - docs/coord_swarm_2026-11-25/reports/V3D_02_terrain_render_audit.md
  - docs/coord_swarm_2026-11-25/reports/RV_TRN_02_smoothing_rules.md
  - variant3d/scripts/game.gd (:733-859, :909-916, :1903-1941, :1942-2046, :2127-2230)
  - variant3d/scripts/world3d_terrain.gd (:920-1010, :1268-1409, :1570, :1641)
  - variant3d/scripts/pattern_gen.gd (:9, :92, :220-251)
  - variant3d/tools/donor_gen.py (:357-374, :474-481)
  - variant3d/tools/export_donor_patterns.py (:83-87)
  - variant3d/assets/terrain/structs/presets_summer.json
  - variant3d/assets/terrain/structs/tile_lowground.png, tile_highground.png
  - app/assets/terrain/patterns/donor_patterns.json
  - app/shots/g32_dump.json, app/shots/t6t90_dumps/dump_20261113_a.json,
    scans/t2gen/dump_9.json, variant3d/tests/results/w52_self_base.json,
    variant3d/tests/results/t_combo_shore_mines.json
parity_guard: "No donor GPU A/B frame exists. Every visual-parity statement is UNVERIFIED."
---

# A04 — Tile diversity on a real generated map

## 0. Method and honesty labels

Read-only analysis. Two throwaway Python scripts were written **only** to
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\` (outside the repo) to decode the
base64/`PackedByteArray` tileblock dumps into histograms and 4-connected components, and
to read the port's own copied detail bitmaps with Pillow. No repo file was edited, no
Godot job was submitted, no donor file was opened in this pass — all donor facts are
cited from `RV_TRN_02_smoothing_rules.md` / `TRN_DATA_implementation.md` /
`V3D_02_terrain_render_audit.md`, which read the donor text in earlier passes.

**observed** = literal code/data or a measurement made here; **derived** = arithmetic
or control-flow consequence of cited lines; **inferred** = visual attribution with no
pixel-aligned donor frame; **UNVERIFIED** = not provable from readable data.

---

## 1. What one tile id means on screen (why this ticket matters)

**observed** — `variant3d/scripts/world3d_terrain.gd`:

- `_dump_from_game()` `:926-963` reads the live `game.tileblock` (`PackedByteArray`, one
  uint8 per cell) and base64-encodes it; `_decode_tile_indices()` `:969-1006` decodes it,
  builds `_tile_index_hist` (`:1000-1006`) and flags out-of-atlas ids.
- `build()` `:1324-1329` resolves the raw id, clamps water sentinel `255` to shore art;
  `:1340-1385` applies donor cliff/shore name overrides; `:1407` writes
  `uvs2[i] = Vector2(float(tid), float(face))`.
- The shader (`V3D-02` §DTA trace, `terrain_tileindex.gdshader:281-300`) samples **one
  whole 1024² atlas cell per id**, repeated at `fract(v_st*uv_repeat)`. There is no
  second pass, no donor decal layer, and the mask sub-rect mapping is a PORT APPROX.

**derived**: therefore each distinct donor id in `tileblock` = one distinct piece of
donor tile art on the ground, and any large region sharing one id is a large region
painted with **the same atlas cell verbatim**. Raising id diversity is the only lever
that changes *what* is sampled; it cannot by itself fix the shader's texgen (V3D-02
P2), headlight (P3) or mask (P4/P7) gaps. That is why A04 amplifies repetition but is
not the sole cause of it.

---

## 2. OBSERVED — tile-id distribution on real generated maps

All dumps on disk are **pre-TRN-DATA** (the change landed after they were captured:
their top-5 is the 73% baseline quoted by `TRN_DATA_implementation.md:47-51`). No
post-TRN-DATA live tileblock histogram exists anywhere in the tree — this is checked
below, not assumed.

| Dump (320² = 102,400 cells) | Seed | Distinct ids | Top-5 share | Top five ids (count, %) |
|---|---:|---:|---:|---|
| `app/shots/g32_dump.json` | 20261113 | 31 | **73.09%** | `14 grass_ground1` 28,535 (27.87%), `0 grass1` 15,993 (15.62%), `16 grass_ground3` 15,962 (15.59%), `79 test8` 7,667 (7.49%), `78 test7` 6,691 (6.53%) |
| `app/shots/t6t90_dumps/dump_20261113_a.json` | 20261113 | 31 | 73.16% | same five, ±0.1% |
| `variant3d/tests/results/w52_self_base.json` (live Godot self-base) | — | 31 | **73.09%** | byte-for-byte the g32 histogram |
| `scans/t2gen/dump_9.json` | 9 | 31 | 64.79% | `0 grass1` 29.64%, `79` 13.93%, `78` 11.57%, `1 grass2` 4.93%, `14` 4.72% |
| `t_combo_shore_mines.json` (64² fixture) | — | 5 | ~97% | `{0:3779, 93:42, 98:84, 255:149, 97:42}` |

**derived / observed**: the divergence between seed 20261113 and seed 9 is diagnostic.
`g32` has `stamp_counts.forest = 117`; `dump_9` has `forest = 13`. The two ids that
exploit the gap — `grass_ground1` (27.87% → 4.72%) and `grass_ground3` (15.59% →
2.65%) — are exactly the **old forest-interior base pair** in `_assign_tileblocks()`
before TRN-DATA (see the ticket's own comment at `game.gd:1720-1724`: "the former
grass_ground1/3 pair are transition tiles and made top-5 = 73%"). Forest area, not
the shader, produced the dominant id.

**observed** — the port's own copied donor detail bitmaps, read here:

| Bitmap (`res://assets/terrain/structs/*.png`, 320×320) | `R div 2` histogram (top values) |
|---|---|
| `tile_lowground.png` | 12 distinct: `0 grass1` 50.31%, `79 test8` 19.32%, `78 test7` 10.59%, `1 grass2` 7.42%, `83/85 test12/14` 3.45% each, `80 test9` 2.62% |
| `tile_highground.png` | 10 distinct: `78 test7` 34.02%, `79 test8` 16.76%, `80 test9` 14.28%, `85 test14` 12.67%, `83 test12` 8.65%, `7 grass8` 7.41% |

This matches `TRN_DATA_implementation.md:64` ("the donor bitmaps encode those indices
directly, `R=156/158 ⇒ tex 78/79` ≈ 30% of low-ground pixels") and explains why
`test7+test8` survived TRN-DATA unchanged: **offline 14.63% → 14.89%**, `test9` 2.29%
→ 0.84%, top-5 **72.68% → 58.52%**, distinct 31 → 32 (same report §2). Those are the
only post-change numbers available; exact live-build histogram is **UNVERIFIED**.

**observed** — a measurement atom already exists without any game-code edit:
`world3d_terrain.gd:1570` and `:1641` expose the full `tile_index_hist` in `stats`.
A new test can assert top-5 / distinct-id / `test7+8` thresholds directly.

---

## 3. OBSERVED / DERIVED — do large uniform areas share one id? Yes.

4-connected component scan of the real 320² `g32` tileblock (component = maximal
orthogonally contiguous run of one id):

| Id | Cells | % map | Largest 4-comp | Comps ≥100 cells | Cells in comps ≥100 |
|---:|---:|---:|---:|---:|---:|
| 14 `grass_ground1` | 28,535 | 27.87% | **2,036** | 42 | 21,508 |
| 0 `grass1` | 15,993 | 15.62% | 613 | 30 | 7,148 |
| 16 `grass_ground3` | 15,962 | 15.59% | 40 | 0 | 0 |
| 79 `test8` | 7,667 | 7.49% | 47 | 0 | 0 |
| 78 `test7` | 6,691 | 6.53% | 167 | 2 | 315 |
| 20 `rock4` | 2,415 | 2.36% | 214 | 6 | 1,074 |

- **29.93% of every cell on the map (30,651 / 102,400)** lies inside a uniform
  ≥100-cell component. The single largest patch is 2,036 cells ≈ 8,144 m² at
  `TILE_M=2` — one atlas cell repeated over a visually huge area.
- Neighbour equality: 48.07% of horizontal cell pairs and 47.65% of vertical pairs
  have the *same* id.
- `grass_ground3` has no ≥100 component because it is interleaved with
  `grass_ground1` (both from one old 2-way roulette), but the pair jointly covers
  43.5% of the map — the "same handful of tiles" the charter describes.

**derived — the code chain that makes and preserves these patches:**

1. `game.gd:1964-1967` seeds **every** land cell with `_blk("grass1")` (id 0).
2. `game.gd:1981-1993` (pre-TRN-DATA) gave terrain type 2 (forest) cells a 2-way
   `grass_ground1 / grass_ground3` draw. `_gen_patterns()` stamps forest as filled
   core discs (`game.gd:765-800`, radius 14–22 tiles), so a single draw family is
   applied to contiguous hundreds of cells → the 2,036-cell patch.
3. `_apply_detail_pass()` `:1913-1937` only touches cells **still** equal to `grass1`
   (`:1927`) — forest interiors are skipped, so they receive zero bitmap detail.
4. `_smooth_tilemap()` `:2209-2216` runs 3 passes, but `_tb_smooth_pair()` `:2190-2191`
   returns unchanged for adjacent compatible lists (`|Δ|=1`, donor
   `smoothtiles.inc:142`). Uniform interiors therefore stay uniform; smoothing can
   only rewrite **boundaries**. It cannot create variety inside a patch.

TRN-DATA widened step 2 to the donor Item 1 J=5 four-way family
(`grass7/test12/test13/test14`, 0.25 each), which is why top-5 falls 73% → 58.5%;
but the four new ids still occupy ~43% of the map (offline new top five: `grass1`
15.28%, `test14` 11.82%, `test12` 11.62%, `test13` 10.29%, `grass7` 9.51%). The
mechanism — "one stamp family over a contiguous disc, no interior detail" — remains.
**inferred**: this is the data half of the "flat uniform olive field with faint
repeating bands" in the charter's P0 frame; the shader half is V3D-02 P1–P4.

---

## 4. OBSERVED — is the donor `SetupTiledPatterns('tiles')` detail pass ported?

**Answer: effectively NO.** Three separate facts:

1. **The stamps are placed.** `pattern_gen.gd:230-251` runs a tiled-pattern grid,
   picks from the home family `"tiles"` and stores each `kind = "tile"` stamp with
   its donor mask cells in `st.cells`. The donor pattern names are real and exported:
   `app/assets/terrain/patterns/donor_patterns.json` family `tiles` =
   `d_tls_1..d_tls_4`. `export_donor_patterns.py:83-87` lists `tiles` / `desert_tiles`
   as generator-stamped families.
2. **The live game throws them away.** `game.gd:838-839`:
   ```gdscript
   				"tile":
   					pass  # donor tls_* are thin decals, not terrain recolour
   ```
   The cells are processed through `painted_cells.append()` (`:807`) but never
   change `terrain`, `tileblock`, or any renderer input. `world3d_terrain.gd` and
   `world3d.gd` contain no reference to `pattern_stamps` or `"tile"`; `main.gd:770-778`
   emits only two relief ids (`plt2`, `k_ravine_1`) from the stamp list, not tile art.
3. **The only other implementation is offline and thinned.**
   `variant3d/tools/donor_gen.py:357-374` `setup_tiles()` reimplements the donor pass
   for tool-generated maps: it says *"25-unit strict grid, one pattern/cell"* but
   deliberately uses `step = max(6, round(60*self.s))` and paints `DIRT` with
   `probability = 0.18`; `generate()` calls it at `:477`. Its consumers are
   `tools/gen_variant_maps.py` and `tools/export_donor_patterns.py` — **not**
   `variant3d/scripts/`. So it never reaches the live tileblock.

**derived**: on the real 320² `g32` map, `map_meta.stamp_counts.tile = 4`. With
`DONOR_UNITS = 160.0` (`pattern_gen.gd:9`) and `s = map_w/160 = 2.0` (`:92`), the
current thinning `round(60*s) = 120` cells yields a 3×3 candidate grid; the donor's
25-unit grid would be `25*s = 50` cells, a 7×7 grid. Even if the `pass` at
`game.gd:839` were removed, only four decal footprints exist on this seed — a small
but structurally important missing donor pass, not a large-scale variety source on
its own. **UNVERIFIED**: whether the donor's `.inc` code actually executes in the
shipped donor build (`RV_TRN_02 §4.6`: every code line is `;`-commented); the *intent*
and the pattern masks are real donor data.

---

## 5. Diagnosis — ranked causes of "too few distinct tiles"

| # | Cause | Citation | Label |
|---:|---|---|---|
| C1 | Forest interior = one contiguous stamp disc fed by a tiny base family; pre-TRN-DATA 2 ids, post-TRN-DATA 4 ids, with **no** detail pass on those cells. | `game.gd:765-800`, `:1981-1993`, `:1927` | observed + derived |
| C2 | Plain cells get their ids from two donor bitmaps with only 10–12 distinct values, ~56–65% of which are `test7/test8/test9` transition ids. | `_apply_detail_pass()` `:1913-1937`; measured PNG histograms §2 | observed |
| C3 | Smoothing preserves `|Δ|=1` neighbours, so uniform regions are never diversified internally; it only rewrites boundaries and tends to homogenise them. | `_tb_smooth_pair()` `:2190-2207`; `RV_TRN_02 §4.3` | observed + derived |
| C4 | Donor `tls_*` dirt/crack detail pass is discarded by the live mapgen, so no donor-authored decal art ever touches the tile field. | `game.gd:838-839`; `pattern_gen.gd:230-251` | observed |
| C5 | Tile stamps are thinned from the donor 25-unit grid to `round(60*s)`, cutting candidates 7×7 → 3×3 at 320². | `pattern_gen.gd:230-231` (`PORT APPROX` comment on that line) | observed + derived |
| C6 | Renderer samples one whole atlas cell per id with no decal/second pass, so id repetition is visually verbatim. | `world3d_terrain.gd:1407`; V3D-02 P1/P2 | observed + inferred |

**Not a cause / do not redo**: the live tile index reaches the GPU for every cell
(V3D-02 §"already correct" #1); the atlas grid comes from the manifest; donor source
bitmaps themselves must not be edited (`S-25-09` / DTRN-01 M10).

---

## 6. Proposals — low-risk, donor ids and donor smoothing rules only

All three proposals are **proposals only**, with exact diffs. Every one reuses ids
from `presets_summer.json` and either an embedded donor rule list
(`DONOR_SMOOTH_RULES`, transcribed in `RV_TRN_02 §7`) or an already-placed donor
stamp. **No synthetic noise field, no per-cell `_hash2`/dither, no new tile art, no
probability normalisation, no change to the 118-rule table, no change to
`_tb_smooth_pair`, `_tb_pick` or `_smooth_tilemap` logic.** Per charter S-25-09 these
are hard guardrails.

### P1 — Re-roll bitmap transition ids through their own donor families (highest leverage)

The detail pass writes `test7` (id 78) and `test8` (id 79) directly from the donor
bitmap. Both ids already belong to donor-authored lists that contain grass tiles:
`test8` → Item 1 J=4 `grass1:1, grass2:1, test8:1` (cfg:155, SumProb 3);
`test7` → Item 2 J=5 `test7:1, grass8:1, test6:1` (cfg:267, SumProb 3).
Applying the donor's own roulette (the already-implemented `_tb_pick`) to those cells
replaces a flat two-transition-tile field with grass ids, and the existing 3-pass
smoothing then reconciles the result with its neighbours using donor rules.

`variant3d/scripts/game.gd`, in `_apply_detail_pass()` (`:1913-1937`) and its single
call site (`:2024`):

```diff
-func _apply_detail_pass() -> void:
+func _apply_detail_pass(brng: RandomNumberGenerator) -> void:
 	# donor loadtextureterrainfrombitmap.inc: h < 0.1 reads tile_lowground,
 	# else tile_highground; tex = R div 2; only cells still on block 0 change.
+	# TRN-A04 P1 (PORT APPROX): the donor writes its transition ids verbatim;
+	# re-roll ONLY those two through the donor list that already contains them
+	# (RV-TRN-02 §7 Item 1 J=4 / Item 2 J=5). No new id, no noise field.
 	_load_detail_bitmaps()
 	if tile_low_im == null or tile_high_im == null:
 		return
 	var grass0 := _blk("grass1")
+	var id_test7 := _blk("test7")
+	var id_test8 := _blk("test8")
 	...
 			var tex: int = int(im.get_pixel(sx, sy).r * 255.0) / 2
+			if tex == id_test7:
+				var pick := _tb_pick(2, 5, brng)  # Item 2 J=5 test7/grass8/test6
+				if pick >= 0:
+					tex = pick
+			elif tex == id_test8:
+				var pick2 := _tb_pick(1, 4, brng) # Item 1 J=4 grass1/grass2/test8
+				if pick2 >= 0:
+					tex = pick2
 			if tex >= 0 and tex < tbl_names.size():
 				tileblock[i] = tex
```

```diff
-	_apply_detail_pass()
+	_apply_detail_pass(brng)
```

Expected direction (derived, from the measured bitmap histograms): `test7+test8`
shares fall by roughly 2/3 of their bitmap contribution (14.9% → ~5–6% offline),
`grass1/grass2/grass8/test6` rise, distinct ids ≥ 35. **PORT APPROXIMATION**: the
donor detail pass itself does not re-roll; this is an extra application of a donor
rule to donor bitmap output. Risk: extra `brng` draws shift later smoothing/border
draws (deterministic per seed, but tileblock bytes change — TRN-DATA already accepts
that). Do **not** substitute `_hash2(x,y)` or any noise here: that is exactly the
S-25-09 forbidden synthetic field.

### P2 — Consume the already-placed `tls_*` stamps instead of discarding them

Restores `SetupTiledPatterns('tiles')` structurally with **zero new RNG draws, zero
new stamps and no `terrain`/`blocked` change**. Keep the `pass` at `game.gd:838-839`
(so the mapgen RNG stream and gameplay fields stay byte-identical) and paint the tile
field later, from the stored `pattern_stamps`, immediately before smoothing.

`variant3d/scripts/game.gd`, inside `_assign_tileblocks()` between `:2024` and `:2028`:

```diff
 	_apply_detail_pass(brng)
+	# TRN-A04 P2 (PORT APPROX of donor SetupTiledPatterns('tiles')): the tls_*
+	# masks are dirt/crack decals stored on kind=="tile" stamps by
+	# pattern_gen.gd:230-251 and currently dropped at game.gd:838-839. Paint
+	# their exact donor mask cells with the donor neutral worked-ground tile
+	# (ground1, Item 9 J=0, cfg:818 / texturemap.inc:622-642). No new stamp,
+	# no RNG draw; smoothing below reconciles the borders with donor rules.
+	for s in pattern_stamps:
+		var st: Object = s
+		if str(st.kind) != "tile":
+			continue
+		for c in (st.cells as Array):
+			var cc: Vector2i = c
+			var tx: int = int(st.x) + cc.x
+			var ty: int = int(st.y) + cc.y
+			if tx < 0 or ty < 0 or tx >= MAP_W or ty >= MAP_H:
+				continue
+			var ti := _t(tx, ty)
+			if tileblock[ti] != BLK_WATER:
+				tileblock[ti] = _blk("ground1")
 	# 4) exact 3-pass SmoothTileMap ...
 	_smooth_tilemap(brng, 3)
```

Covers only the 4 stamp footprints on seed 20261113 (small visual effect) but closes
a real donor gap and gives large uniform forest patches donor-authored dirt marks.
The later mine-apron authority at `:2035-2037` still wins. `PORT APPROXIMATION`: the
donor's tls art is a decal layer; the port has no decal layer, so the nearest
existing donor id is `ground1`.

### P3 — Restore the donor 25-unit tile grid (follow-up ticket, different owner file)

`variant3d/scripts/pattern_gen.gd:230-231` deliberately thins the donor grid:

```diff
-	# SetupTiles: thin tiled-pattern grid (full donor grid would saturate a small map)
-	var tile_step := maxi(6, int(round(60.0 * s)))
+	# TRN-A04 P3 — donor 25-unit strict grid (SetupTiledPatterns, donor_gen.py:358).
+	# 25 donor units * s map-cells/unit; the old 60-unit thinning was a PORT APPROX.
+	var tile_step := maxi(4, int(round(25.0 * s)))
```

At 320² this changes candidates from 3×3 to 7×7. **Higher risk than P1/P2**: it
consumes `can_stand`/occupancy and the tile-family RNG stream, which can shift every
later stamp. Must be its own ticket owning `pattern_gen.gd`, gated by
`t_map_variety` `same_seed_byte_identical` and the full selftest before merge; do not
bundle with P1/P2. If `can_stand` still rejects most cells, combine with P2 so the
extra stamps actually reach the tile field.

### P4 — Measurement atom, no game edit

`world3d_terrain.gd:1570,1641` already publishes `stats.tile_index_hist`. A new
read-only test can, on seed 20261113 at 320², assert:
distinct ids ≥ 35, top-5 < 58.52% (the post-TRN-DATA offline baseline),
`test7+test8` < 10% (from 14.89% offline), no new out-of-atlas id, and identical
histograms across two runs of the same seed. This is the clean way to turn the
offline 58.52% number into an in-engine gate.

### Explicitly rejected

- Editing `tile_lowground/highground` bitmaps or inventing a mask/noise/dither field
  (S-25-09; DTRN-01 M10).
- Adding ids not present in `presets_summer.json` / the donor smoothing table.
- Changing the 118 embedded rule lists, `SumProb` anomalies (`0.64/0.0028/0.36`) or
  the `Prob=0` separators (`RV_TRN_02 §3.5`).
- Reordering the smoothing sweeps to donor loop nesting: TRN-DATA §5 measured that
  this homogenised the fixture to top-5 ≈ 95%, the opposite of this ticket.

---

## 7. Verification / acceptance

1. Offline replay of P1+P2 over the same `g32_dump.json` `terrain`/`height`/ore nodes
   (the TRN-DATA §2 method), then a live 320² dump with a new histogram probe (P4).
2. Compare against post-TRN-DATA offline: top-5 58.52%, `test7+8` 14.89%, distinct 32.
3. Keep all gates green: `t_map_variety` 5/5 incl. `same_seed_byte_identical`,
   selftest 29/29, uitest 17/17, `t_render_mode`, `assert_clean` CLEAN; 2D `app/`
   untouched.
4. Large-scale check: re-run the connected-component scan of §3 — target
   largest uniform component < 800 cells and cells in ≥100-cell uniform components
   < 15% (from 2,036 cells and 29.93% measured here). This measures the *patch*
   problem directly rather than only the global histogram.

---

## 8. UNVERIFIED / open questions

1. **Post-TRN-DATA live histogram** — none on disk; 58.52% is an offline replay with
   Python RNG substituted for Godot's. P4 is required before any threshold is claimed.
2. **Donor runtime activity** — all donor `.inc` code lines are `;`-commented
   (`RV_TRN_02 §4.6`); the smoothing rules, bitmaps and pattern masks are real donor
   data, but "the donor game executes this pass" is UNVERIFIED.
3. **Effect of P1 on visual darkness** — `test7/8/9` are transition tiles; replacing
   them with `grass1/2/8` and `test6` should reduce dark blotches (charter suspect
   #2), but without a donor GPU A/B this is **inferred**, not proven.
4. **P2 coverage** — only 4 `tile` stamps survive `can_stand` on seed 20261113; the
   visual gain depends on stamp density, which is P3's separate risk.
5. **Item-selection binding** — 11 Summer + 11 Winter Items exist but no plaintext
   statement selects them by season (`RV_TRN_02 §8 Q4`); P1 uses Summer Item 1/2
   indices directly, consistent with TRN-DATA's alias handling, but donor parity of
   that choice is UNVERIFIED.
6. Whether an existing 64² capture fixture can show the patch-size change, or whether
   a fresh 320² dump is required (the 64² fixture histogram is 5 ids, ~97% top-1,
   dominated by shore/water sentinels and therefore not representative of meadow
   diversity).

---

## 9. Scope statement

Files created by this ticket: this report only. No code, shader, asset, config, test,
runner job, git state or donor file was changed. All diffs in §6 are proposals for an
implementation wave; their authors must own the named files separately.

*End of A04.*
