---
id: Y04
ticket: "URGENT — surviving rings after Y03 detail-pass neutralisation"
title: "Y04 — which producers survive, ranked, and the minimal ring fix"
agent: "Y04 (read-only analysis subagent)"
created: 2026-11-25
status: DELIVERED__READ_ONLY_ANALYSIS_THEN_Y04_IMPL_APPLIED__ONE_REPORT_PLUS_EXACT_ONE_GAME_GD_HUNK__NO_RUNNER__NO_GODOT
scope: "Analysis phase wrote one report only (plus scratch PNG crops under C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\y04\\, outside the repo). Under COORD's Y04-IMPL exclusive-ownership grant, exactly one four-line hunk was applied to variant3d/scripts/game.gd and this report was updated with §8. No runner job, no Godot process, no .gdshader/asset/config/test/JSON/donor edit. See §8."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
labels: [OBSERVED, DERIVED, UNVERIFIED]
parity_guard: "NO DONOR PARITY CLAIM. No donor file, donor screenshot or donor GPU A/B frame was read, copied or executed for an attribution claim. All donor references are structural citations from prior in-repo reports; every visual expectation here is internal consistency only."
inputs_read:
  - docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
  - docs/terrain_swarm_2026-11-25/CHARTER.md
  - docs/terrain_swarm_2026-11-25/reports/Y01_maze_data_proof.md
  - docs/terrain_swarm_2026-11-25/reports/Y03_detail_pass_fix.md
  - docs/terrain_swarm_2026-11-25/reports/L03_realmap_regression.md
  - docs/terrain_swarm_2026-11-25/reports/B03_diversity_impl.md
  - docs/terrain_swarm_2026-11-25/reports/Y02_maze_root_cause.md
  - docs/terrain_swarm_2026-11-25/reports/Y03_capture_log.md
  - docs/terrain_swarm_2026-11-25/reports/Y06_visual_verdict.md
  - docs/terrain_swarm_2026-11-25/reports/A03_atlas_cells.md
  - "variant3d/scripts/game.gd (current tree, all producer sites cited below)"
  - "variant3d/shaders/terrain_tileindex.gdshader:214,305,332,392,417,427"
  - "IMAGE (before): C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\l07c\\realmap.png"
  - "IMAGE (after): C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\y03\\realmap.png"
verdict: "Y03 killed the FIELD-WIDE maze (detail-pass ids collapsed to grass9) but the LOCAL rings survive. Rank 1 is the leftover 3-pass donor smoothing chain (game.gd:2125, :2321-2328, :2258-2319, :2224-2256, donor rules :1604-1760): it is the only remaining code that amplifies local non-grass patches into multi-cell nested bands. The non-grass patches themselves come from rank 2 (mine apron / road ground1+test2/3), rank 3 (stone-quarry terrain=5 disc -> rock ids) and rank 4 (B03-P2 ground1 tile stamps). Minimal fix: keep every _tb_pick draw (RNG byte-identical) but refuse to write a midpoint id into an already-grass9 meadow cell in _tb_smooth_pair(); four one-line guards, no terrain/height/blocked change, no re-enabled gradient paint, no B04. Exact tile ids at the surviving pixels remain UNVERIFIED (no post-Y03 dump)."
---

# Y04 — remaining rings after Y03

> **Labels:** **OBSERVED** = literal source line, decoded file byte, or a pixel read
> directly from the two named PNGs; **DERIVED** = control-flow/arithmetic consequence
> of observed values; **UNVERIFIED** = not provable with the available instruments.
> No Godot process was launched, no runner job submitted, no source/asset/config/test/
> donor file edited. **No donor parity claim.**

---

## 0. Mandate

COORD: after Y03 forced every `_apply_detail_pass()` output to `grass9` (idx 8), the
field-wide concentric maze mostly vanished, but rings still remain around buildings,
starts and resource deposits, plus checkerboard blocks. Identify the **surviving
producers** with exact current `file:line`, rank them, and give the **minimal fix**
that removes the rings without reintroducing the field maze or breaking gates.
Also open both captures and describe the remaining patterns **in words first**.

Guardrails read: `WAVE_G_CHARTER.md:29-33` (G04 sole runner owner; one report/agent),
`CHARTER.md:55-69` (labels, no test weakening, no synthetic field, no donor parity).

---

## 1. Patterns described in words BEFORE any verdict (OBSERVED)

Both PNGs were opened directly (each 1280×720). Scratch upscales/crops were written
only to `%TEMP%\opencode\y04\`. The camera is **not** identical between the two frames:
the Y03 capture log records `camera_pos=(145.2939,58.0,-87.389)`, `target=(385.2939,59.7916)`
versus `l07c` `(144.5727,58.0,-88.1103)` (`Y03_capture_log.md:90-98`; independently
noted in `Y06_visual_verdict.md:53-58`). Therefore this is a **comparative description,
not a pixel-aligned A/B**; cell-level attribution is UNVERIFIED.

### 1.1 BEFORE — `l07c/realmap.png` (OBSERVED)

- The **whole meadow** is covered by dense nested, stair-stepped, roughly octagonal
  contour bands, 1–2 cells wide, in grey-brown/olive striated art. They form long
  interlocking chains, isolated "eyelids", and closed loops nesting around the large
  plateau/hill features. Between the bands the ground is ordinary olive grass.
- The bands **encircle the central hall and both thatched huts**, sitting just outside
  each building's clear area; similar small nested rings sit around the reddish
  resource clusters. A long serpentine chain runs through the lower centre-left.
- Around 3–4 resource clusters there are **pale tan/grey square checkerboard aprons**
  with a green rubble disc at the centre. Conifers occupy the upper-right clearing and
  the lower-left. No water is visible.

### 1.2 AFTER — `y03/realmap.png` (OBSERVED)

- The **field-wide maze is gone**. Most of the meadow now reads as one olive field,
  but it is overlaid with a **new fine, evenly spaced horizontal corrugation**
  (light/dark lines at roughly 4–7 px spacing) — a regular, non-organic screen-level
  striping that was not the dominant signal before. This is a *new* artifact, not a
  ring, and is recorded here for completeness (Y06 R1/R2).
- **Nested stair-stepped bands remain, at the same characteristic places:**
  a tight cluster hugging the hall and both huts (several nested grey/tan/olive loops);
  a long serpentine nested band running down-left from the hall to a small isolated
  closed ring; a band set in the extreme top-left and along the top-right edge beside
  the tree clearing; and a small loop near the upper-right conifers.
- **Checkerboard blocks remain and are now more conspicuous:** large, sharply bounded
  tan/grey square or cross-shaped aprons around each resource cluster, made of
  grid-aligned alternating light/dark cells, each with a green rubble disc at centre.
- The upper-right grove reads as a flat dark-green clearing with a clean stepped
  border; no cyan water and no black full-width rows appear in either frame.

Pixel arithmetic (OBSERVED, scratch only): mean absolute RGB diff between the two
frames is 19.2/255; ~20% of pixels differ by <5 and ~17% by >30. The ring *outlines*
are bright in the difference map, i.e. the surviving rings changed colour value as
well as surviving geometrically — consistent with the smoothing picks being re-made
against a changed field (DERIVED, §3.1).

---

## 2. What Y03 actually changed, and what it did not (OBSERVED + DERIVED)

| Step | Site | Effect |
|---|---|---|
| Gradient/collision pass | `game.gd:1297-1310` (collision-only; `terrain[i]=5` removed per B03 §11) | No longer converts height terraces to rock art. Field maze source #1 gone. |
| Hill stamp | `game.gd:853-861` (`pass`) | No rock disc from hill stamps. |
| Stone stamp | `game.gd:849-852` | **Still** paints `terrain=1` (`dc<=3.2`) and `terrain=5` (`dc<=1.6`). |
| Detail pass | `game.gd:1959-2010`; Y03 assignment at **`:2008`** `tex = _blk("grass9")` | Every bitmap-derived output on an eligible `grass1` cell becomes grass9. Field maze source #2 gone. The two `_tb_pick` draws at `:1989-1996` are kept, so `brng` state is unchanged (Y03 §10.3). |
| B03-P2 tile stamps | current **`game.gd:2098-2121`** | Still paints `kind=="tile"` stamp cells `ground1`. |
| Mine apron | `game.gd:2084-2088`, **`:2129-2134`**, `_finalize_mine_tiles()` `:372-385` | Still forces `ground1` over the whole apron. |
| Smoothing | call **`:2125`**, `_smooth_tilemap` **`:2321-2328`**, `_tb_smooth_pair` **`:2258-2319`**, `_tb_pick` **`:2224-2256`**, donor rules `:1604-1760` | **Unchanged.** Reacts to the new field values. |
| Forest borders | `_stamp_forest_borders` **`:2330-2342`** | Unchanged; grass5/rock9 on forest edges. |
| Shore/cliffs | terrain=4/5 roles `:1225-1230`, `:2215-2222`; `_shore_tile_for` `:2145-2174`; `_cliff_tile_for` `:2176-2209` | Unchanged. |

**Note on stale line numbers in the ticket.** The ticket's "(b) B03-P2 `ground1` tile
stamps at `:2051-2072`" reflects a pre-Y03 tree. After Y03's +12-line insertion the
B03-P2 loop is at current **`game.gd:2098-2121`**, the base road/rock picks are at
`:2043-2083`, and the detail-pass Y03 hunk is at `:1997-2010`. All line numbers in
this report are **current tree** (verified by re-read, OBSERVED).

**Eliminated up front (OBSERVED/DERIVED):** grep over `variant3d/scripts/` finds
exactly **one** remaining `terrain[...] = 5` write — `game.gd:852` (the stone stamp).
There is no gradient write left anywhere. The shader is unshaded with constant
`v_packed = ambient_rgb + diffuse` (`terrain_tileindex.gdshader:305`), so residual
*height* terraces cannot recolour bands; the rings are tile-id art, not mesh shading.

---

## 3. Surviving producers — exact `file:line`, ranked

### Rank 0 — ALREADY NEUTRALISED: `_apply_detail_pass` (do not revert)

`variant3d/scripts/game.gd:1959-2010`, Y03 assignment **`:2008`**.
This was the field-wide maze carrier (Y01b §8, Y03 §2). Y03 collapsed its output to
`grass9` and the field maze vanished — **OBSERVED** in the after frame. Re-enabling
its bitmap ids would reintroduce the field maze; leave it alone.

### Rank 1 — Leftover 3-pass donor smoothing chain  **[PRIMARY — ring amplifier]**

- call site **`game.gd:2125`** `_smooth_tilemap(brng, 3)`;
- driver **`game.gd:2321-2328`** (horizontal then vertical pair passes);
- writer **`game.gd:2258-2319`** `_tb_smooth_pair()`, midpoint writes at
  **`:2305-2319`**;
- id picker **`game.gd:2224-2256`** `_tb_pick()` (B03-P3 redirect at `:2249-2254`);
- authored lists **`game.gd:1604-1760`** `DONOR_SMOOTH_RULES` / `tbl_smooth`
  (note `rock9` weight-1 groups at `:1608,:1641,:1652,:1662,:1668,:1673` and
  `grass5` at `:1669,:1674`).

**DERIVED:** after Y03 the meadow is one id (`grass9`), so the *only* remaining
code that can manufacture **multi-cell, nested, alternating bands** is the pair-wise
midpoint substitution at `:2305-2319`. Every non-grass patch (mine apron, road disc,
stone disc, tile stamp, forest edge) presents a boundary; three smoothing passes
reconcile each boundary by writing 1–3 concentric rings of transition ids into the
adjacent field. That is exactly the observed "nested stepped bands" around buildings,
starts and deposits. The bands survive Y03 because `_tb_smooth_pair()` acts on the
*post*-detail field and never consults `_apply_detail_pass`'s output value.
**UNVERIFIED:** the exact id at any given surviving ring pixel (no post-Y03 dump).

### Rank 2 — Mine apron and road `ground1` / `test2` / `test3` patches  **[patch interiors / checkerboard]**

- `mine_mask` marking **`game.gd:597-623`** (`_paint_terrain`, noisy feathered rim,
  `mark_mine=true` for deposits) and **`:628-629`** (`_mark_mine_mask` for richness ores,
  called from `_assign_tileblocks` `:2023-2025` and `_finalize_mine_tiles` `:377-379`);
- base road pick **`game.gd:2043-2053`** (`terrain==1` → 50% `ground1`, 37.5% `test2`,
  12.5% `test3`);
- road drawing **`game.gd:2401-2430`** `_draw_road()` (`terrain=1` with dithered rim),
  called at **`:1330-1331`**;
- whole-apron override **`game.gd:2084-2088`** and final authority **`:2129-2134`**;
- `_finalize_mine_tiles()` **`:372-385`** (ground1) and **`:386-398`** (start keep-clear
  back to grass1).

**DERIVED:** these supply the tan/grey square interiors — the "checkerboard blocks" —
and the non-grass boundaries that rank 1 rings surround. `ground1` is off-palette
grey-brown (A03 §2 row 10 / F06), so it reads as the light tan squares; `test2/test3`
are transition art. Mine stamps exist on the shipped seed (`g32_dump.json` meta
`stamp_counts.mine = 15`). **OBSERVED:** the tan squares are centred exactly on the
resource rubble discs in the after frame. Fixing rank 1 removes the *rings around*
these squares; the squares themselves are deliberate worked ground and are a separate
decision (§5.2).

### Rank 3 — Stone stamp `terrain=5` disc → rock art  **[small dark discs, minor]**

- stamp paint **`game.gd:849-850`** (`dc<=3.2 → terrain=1`) and **`game.gd:851-852`**
  (`dc<=1.6 → terrain=5`) — this is the ticket's `(a)`, current line confirmed;
- base rock pick **`game.gd:2071-2083`** (`terrain==5` → `rock1/2/3/6/7/4`, 1/6 each
  on `brng.randf()`);
- oriented cliff pick **`game.gd:2219-2222`** (`terrain==5` → `_cliff_tile_for()`
  `:2176-2209`, with `|h|>2.7 → rock8` `:2203-2204`, `>2.4 → rock4` `:2205-2206`).

**DERIVED:** this is the **only remaining source of genuine grey striated rock art**
(rock1/3/4/8 — the material seen inside the bands, A03/L03 §1). But the paint is a
≤2-cell disc per stone stamp (24 stone stamps on the shipped seed per the dump meta),
so it cannot by itself generate the long nested chains; it seeds them and rank 1
amplifies them. **UNVERIFIED:** how many surviving band pixels are stone-disc-derived
versus smoothing-derived.

### Rank 4 — B03-P2 `ground1` tile stamps  **[local, 4 stamps on shipped seed]**

- current **`game.gd:2098-2121`** — `for ps in pattern_stamps` /
  `if str(pst.kind) != "tile": continue` / `tileblock[pti] = _blk("ground1")` at **`:2121`**
  (ticket's `:2051-2072` is the stale pre-Y03 citation).

**OBSERVED:** `g32_dump.json` meta has `stamp_counts.tile = 4`. B03 §9 describes the
`d_tls_1..4` masks as 513–572-cell **nested maze shapes** painted with `ground1`;
no RNG draw. **DERIVED:** contributes a few local checkerboard patches and smoothing
halos, but is not map-wide and cannot explain the bands around every building/start.

### Rank 5 — `_stamp_forest_borders` grass5/rock9  **[forest-local only]**

- **`game.gd:2330-2342`**, write at **`:2342`**: for `terrain==2` cells with exactly
  one forest neighbour, `tileblock = grass5` (34%) else `rock9`.

**DERIVED:** a one-cell olive/dark outline around groves only. It can explain the
clean stepped border of the upper-right clearing (OBSERVED in the after frame), but
there is no forest around the central hall or the resource aprons, so it is **not**
the producer of the building/deposit rings.

### Rank 6 — Shore / sand collar  **[absent in this frame]**

- terrain role **`game.gd:1225-1230`** (`h ∈ [-0.25,-0.1) → t=4`);
- base sand ids **`game.gd:2070`** (`sand1/sand2/sand7`);
- oriented sand rim **`game.gd:2215-2218`** via `_shore_tile_for()` **`game.gd:2145-2174`**.

**OBSERVED:** Y06 §2 R6 scanned all 921,600 pixels and found **0 cyan-water pixels**;
no water boundary exists in either frame. **DERIVED:** contributes nothing here; it
remains a producer on water-bearing maps and must not be "fixed" on this evidence.

### Rank 7 — "(g) something else": two candidates, one refuted

- **New field corrugation (not a ring producer).** The after frame's dense horizontal
  striping is consistent (DERIVED) with a now-uniform `grass9` field sampled through
  the 2 m verbatim atlas repeat (`terrain_tileindex.gdshader:214`, `:392`), minified
  near-grazing sampling (A03 F09), with the per-cell mirror removed at `:332` and the
  alpha patch folded into albedo at `:417`/`:427`. Exact cause is **UNVERIFIED** (no
  dump, camera shifted). This needs a shader/atlas ticket, not a ring fix.
- **Height-only relief terraces — REFUTED as ring source.** `_shape_stamp_relief()`
  still writes height at `game.gd:1055`/`:1102`, but the terrain shader is unshaded
  with constant `v_packed` (`:305`) and `world3d_terrain.gd` has no B04 face promotion
  (L03 §2); height cannot recolour the bands. B03's retained `_relief_stamp_mask`
  is provenance-only and is no longer consulted by the gradient pass.
- **B03-P3 redirect (`:2249-2254`) is not sufficient.** It maps `grass_ground1/2/3`
  to `grass9/test8/test7`, removing the loud lattice art, but the donor lists still
  emit `rock9`/`grass5` and other transition ids (`:1604-1760`) — hence rings survive.

---

## 4. Short answer to the ticket's candidate list

| Ticket candidate | Current `file:line` | Survives? | Visual share |
|---|---|---:|---|
| (a) stone stamp `terrain=5` disc | `game.gd:852` (+ `:2071-2083`, `:2219-2222`) | **YES** | Minor: small grey discs; seeds rank 1 |
| (b) B03-P2 `ground1` stamps | `game.gd:2098-2121` (stale `:2051-2072`) | **YES** | Minor/local: 4 stamps; checkerboard + halos |
| (c) `_stamp_forest_borders` grass5/rock9 | `game.gd:2330-2342` | **YES** | Forest edges only; not the building rings |
| (d) shore/sand collar | `game.gd:1225-1230`, `:2070`, `:2215-2218`, `:2145-2174` | YES in code | **ZERO here** (no water in frame) |
| (e) mine apron `ground1` | `game.gd:2084-2088`, `:2129-2134`, `:372-385` | **YES** | Primary for checkerboard; patch boundaries for rings |
| (f) leftover smoothing chains | `game.gd:2125`, `:2321-2328`, `:2258-2319`, `:2224-2256`, `:1604-1760` | **YES** | **Primary for the rings themselves** |
| (g) something else | new horizontal corrugation (shader `:214/:392/:417/:427`); height terraces refuted | YES (corrugation) | Dominant *new* artifact, but not a ring |

**DERIVED causal chain (post-Y03):**
`stone/road/mine/tile stamps (terrain roles + ground1)` →
`local non-grass patch` → `_smooth_tilemap` 3 passes write transition ids into the
adjacent `grass9` field → `nested 1–3 cell bands` (the surviving rings) →
atlas UV2.x (`world3d_terrain.gd:1324,:1407`) → visible art.
Y03 removed the *field-wide* input to this chain but not the chain itself.

---

## 5. Minimal fix — remove the rings, keep the field clean, keep the gates

### 5.1 Primary hunk (recommended): suppress midpoint writes into meadow cells

**One file:** `variant3d/scripts/game.gd`. **Four one-line condition edits** in
`_tb_smooth_pair()` (current `:2258-2319`). Keep every `_tb_pick()` call exactly where
it is — the draw count/order feeding `_smooth_tilemap` and `_stamp_forest_borders`
stays byte-identical — but refuse to write a transition id into a cell that Y03 has
already neutralised to `grass9` (idx 8). `_blk()` is a pure dictionary lookup and
draws no RNG (Y03 §10.3).

```diff
--- a/variant3d/scripts/game.gd
+++ b/variant3d/scripts/game.gd
@@ -2303,17 +2303,21 @@ func _tb_smooth_pair(x1: int, y1: int, x2: int, y2: int, brng: RandomNumberGenerator) -> void:
 	if bi1 - bi2 == 2:
 		var ni := _tb_pick(best, int((bi1 + bi2) / 2), brng)
-		if ni >= 0:
+		# Y04 (PORT APPROXIMATION, diagnostic): keep the draw (brng stream
+		# unchanged) but never overwrite a Y03-neutralised meadow cell with a
+		# transition id — that is the surviving ring amplifier around local
+		# aprons/discs. FIELD MAZE STAYS OFF (detail pass still all-grass9).
+		if ni >= 0 and int(tileblock[_t(x1, y1)]) != _blk("grass9"):
 			tileblock[_t(x1, y1)] = ni
 	elif bi2 - bi1 == 2:
 		var ni2 := _tb_pick(best, int((bi1 + bi2) / 2), brng)
-		if ni2 >= 0:
+		if ni2 >= 0 and int(tileblock[_t(x2, y2)]) != _blk("grass9"):
 			tileblock[_t(x2, y2)] = ni2
 	elif bi1 < bi2:
 		var ni3 := _tb_pick(best, bi1 + 1, brng)
-		if ni3 >= 0:
+		if ni3 >= 0 and int(tileblock[_t(x2, y2)]) != _blk("grass9"):
 			tileblock[_t(x2, y2)] = ni3
 	else:
 		var ni4 := _tb_pick(best, bi2 + 1, brng)
-		if ni4 >= 0:
+		if ni4 >= 0 and int(tileblock[_t(x1, y1)]) != _blk("grass9"):
 			tileblock[_t(x1, y1)] = ni4
```

**Why this works (DERIVED).** The mine-apron guard already returns early for
`mine_mask` cells (`:2261-2262`), so the new condition affects only meadow cells —
exactly the cells that carry the concentric bands. After the guard, a smoothing
boundary collapses from a 1–3 band transition sequence to a single hard edge between
the intentional patch and the clean `grass9` field. The nested rings disappear; the
worked-ground squares remain (they are intentional and gate-protected).

**Invariants (DERIVED from the diff):**
- **RNG stream:** all four `_tb_pick` calls fire in the same order with the same
  arguments; the guards only gate the *writes*. `brng` entering later passes is
  bit-identical. Same seed → same bytes (`t_map_variety same_seed_byte_identical`).
- **Field maze:** untouched — Y03's `:2008` still forces every detail-pass output to
  `grass9`. No bitmap id, no `terrain=5` gradient paint, no B04 re-enable.
- **`terrain` / `height` / `blocked`:** no write added or removed; collision, start
  protection and walkability stay byte-identical. Stone-quarry `terrain=5` at `:852`
  stays (real donor quarry collision).
- **Tileblock contract:** `PackedByteArray` size `MAP_W*MAP_H`, uint8 ids, `_blk`
  validity and the existing `ni >= 0` checks unchanged; no out-of-atlas id.
- **Guardrails:** no threshold lowered, no assertion deleted, no synthetic dither/
  noise/`_hash2` field (CHARTER §3 / S-25-09). PORT APPROXIMATION; no donor parity.

**Optional refinement (only if small rings still appear at starts):** also exclude
`_blk("grass1")` (id 0) in the four conditions — `_finalize_mine_tiles()` restores
`grass1` on the start keep-clear at `:398`, and those few cells are still writable by
smoothing. This is the same one-line pattern, no RNG change.

### 5.2 Secondary, independent decision: checkerboard blocks

If the aprons themselves must go, revert **only** the B03-P2 loop at current
`game.gd:2098-2121` (the `for ps in pattern_stamps … tileblock[pti] = _blk("ground1")`
hunk). It consumes no RNG and touches no `terrain`/`height`/`blocked` (B03 §4);
B03 §9 explicitly says keep it *unless a checkerboard persists* — it persists in
`y03/realmap.png`. This is **not** needed to remove the rings and is listed separately
so COORD can decide. **Do not** revert the mine-apron authority at `:2084-2088` /
`:2129-2134` / `:372-385` — it is required by the T2GEN P0-1 start/mine gates.

### 5.3 What NOT to do

1. **Do not re-enable the height-gradient `terrain=5` write** (`game.gd:1297-1310`
   collision-only state) — that is the field-wide maze of Y01/L03.
2. **Do not undo Y03's `tex = _blk("grass9")` at `:2008`** — same regression.
3. **Do not re-apply B04 face promotion** — L03 §2 shows it was reverted precisely
   for this contour regression and would add face-mode rock art.
4. **Do not edit the shader/atlas to fix rings** — the corrugation (rank 7) is a
   separate artifact; tile-id field data drives the rings.
5. **Do not "fix" shore/sand on this frame** — no water pixels exist (Y06 R6).

### 5.4 Acceptance (requires G04's sole runner — Y04 runs none)

Structural/gates: selftest 29/29, uitest 17/17, `t_render_mode`, `t_map_variety` 5/5
including `same_seed_byte_identical` (frozen tileblock hash is not a valid gate —
B03 R1), `assert_clean CLEAN`, 2D `app/` untouched, `script_error_lines == 0`,
`full_width_dark_rows == 0`, `non_black_fraction == 1.0`. No threshold changed.

Decisive read-only probe (Y01b §8.5 recipe, new unique id): capture the same
windowed seed-20261113 run with `--dump-map`, decode `tileblock`, and check:
1. non-`grass9` transition ids (`rock9=25`, `grass5=4`, `test7=78`, `test8=79`) collapse
   in the meadow; radial profiles at the historical ring centres lose their peaks;
2. `terrain==5` count stays at the stone-disc level only; `blocked[]` is byte-identical
   to the pre-fix same-seed dump;
3. no out-of-atlas id; no new black rows/seams.
Then a second-agent visual read (C04/G05 protocol) for **zero nested stepped bands**.
Any donor comparison stays **UNVERIFIED** — no donor GPU A/B frame exists.

---

## 6. UNVERIFIED register — do not guess

1. **No post-Y03 dump exists.** The exact `tileblock` id at any surviving ring pixel
   in `y03/realmap.png` was not measured; rank 1 is a control-flow derivation from
   the current source plus the unchanged ring geometry, not a decoded histogram.
2. **Camera is not pinned between the two frames** (`Y03_capture_log.md:95-98`), so
   pixel-aligned before/after attribution is UNVERIFIED. The description in §1 is
   comparative only.
3. **No runner, no Godot, no new capture, no dump** by this agent. Scratch image
   arithmetic was performed on the two supplied PNGs only.
4. **The horizontal corrugation's exact cause** (atlas repeat vs alpha patch vs
   capture-time shader state) is UNVERIFIED; it is not attributed to Y04's fix.
5. **No donor parity claim.** Donor stills were not read in this ticket; prior donor
   citations are structural only. PORT APPROXIMATION throughout.

---

## 7. Claim ledger

| Claim | Label | Evidence |
|---|---|---|
| Field-wide maze gone, local rings + checkerboard remain | OBSERVED | §1 direct reads of `l07c` and `y03` PNGs; Y06 §2 R1/R5 |
| Y03 collapses all detail-pass output to grass9 and keeps the two P1 draws | OBSERVED | `game.gd:1997-2010`; Y03 §10.2/§10.3 |
| Only one `terrain=5` write survives (stone stamp) | OBSERVED | grep `variant3d/scripts/`; `game.gd:852` |
| Smoothing is the only remaining multi-band amplifier | DERIVED | `game.gd:2125`, `:2321-2328`, `:2258-2319`, `:2224-2256`, `:1604-1760` |
| Mine apron / road ground1+test2/3 supply the patch interiors | OBSERVED + DERIVED | `game.gd:597-623`, `:1330-1331`, `:2043-2053`, `:2084-2088`, `:2129-2134`, `:372-385`; A03 F06 |
| Stone disc feeds the only grey striated rock art left | OBSERVED + DERIVED | `game.gd:852`, `:2071-2083`, `:2176-2222`; A03/L03 §1 |
| B03-P2 is 4 stamps, no RNG | OBSERVED | `game.gd:2098-2121`; `g32_dump.json` meta `tile=4`; B03 §4/§9 |
| Forest borders are one-cell and forest-local | OBSERVED + DERIVED | `game.gd:2330-2342` |
| Shore/sand collar contributes nothing in this frame | OBSERVED + DERIVED | Y06 §2 R6: 0 cyan pixels; `game.gd:1225-1230` etc. |
| Height terraces cannot recolour bands (unshaded shader) | OBSERVED + DERIVED | `terrain_tileindex.gdshader:305`; L03 §2 |
| Exact ring id attribution / donor parity | UNVERIFIED | no post-Y03 dump; no donor A/B frame |
| Proposed guard is gate-safe (RNG/determinism/collision) | DERIVED | §5.1 diff; `_tb_pick` draws retained; no terrain/height/blocked write |

---

## 8. APPLIED — Y04-IMPL (COORD exclusive-ownership grant, after L01 released `game.gd`)

Status: **APPLIED**. Exactly one hunk — the four one-line midpoint guards of §5.1 —
was applied to `variant3d/scripts/game.gd`. No other file was edited. The proposed
explanatory comment block from §5.1 was **not** inserted: COORD's grant specified
"four one-line guards", so the diff is strictly four changed lines. No Godot process,
no runner job, no queue/lock/counter mutation. Donor parity remains **UNVERIFIED**.

### 8.1 Backup and hashes (OBSERVED)

- Backup created **before** the edit: `inbox/backup/game.gd.bak-Y04` (did not exist
  beforehand; `Test-Path` = False).
- Pre-edit `game.gd` and backup SHA-256, **identical**:
  `25094E5FB90D2AF5036391513C8F166A97608654C90B6F88645F3424E994C36E`.
- Pre-edit size: **256,415 bytes**, mtime 2026-11-25 16:20:21 (includes L01's 162
  inserted lines and Y03's grass9 neutralisation).
- Post-edit `game.gd` SHA-256:
  `77DF5CE57E38A1B23A8EAD960895E8C01CA334DE3B2D807549A7B1468ACF11C3`.

### 8.2 Exact applied diff (verbatim `git diff --no-index -- inbox/backup/game.gd.bak-Y04 variant3d/scripts/game.gd`)

```diff
diff --git a/inbox/backup/game.gd.bak-Y04 b/variant3d/scripts/game.gd
index 8373cfee..5614673f 100644
--- a/inbox/backup/game.gd.bak-Y04
+++ b/variant3d/scripts/game.gd
@@ -2312,19 +2312,19 @@ func _tb_smooth_pair(x1: int, y1: int, x2: int, y2: int, brng: RandomNumberGener
 		return
 	if bi1 - bi2 == 2:
 		var ni := _tb_pick(best, int((bi1 + bi2) / 2), brng)
-		if ni >= 0:
+		if ni >= 0 and int(tileblock[_t(x1, y1)]) != _blk("grass9"):
 			tileblock[_t(x1, y1)] = ni
 	elif bi2 - bi1 == 2:
 		var ni2 := _tb_pick(best, int((bi1 + bi2) / 2), brng)
-		if ni2 >= 0:
+		if ni2 >= 0 and int(tileblock[_t(x2, y2)]) != _blk("grass9"):
 			tileblock[_t(x2, y2)] = ni2
 	elif bi1 < bi2:
 		var ni3 := _tb_pick(best, bi1 + 1, brng)
-		if ni3 >= 0:
+		if ni3 >= 0 and int(tileblock[_t(x2, y2)]) != _blk("grass9"):
 			tileblock[_t(x2, y2)] = ni3
 	else:
 		var ni4 := _tb_pick(best, bi2 + 1, brng)
-		if ni4 >= 0:
+		if ni4 >= 0 and int(tileblock[_t(x1, y1)]) != _blk("grass9"):
 			tileblock[_t(x1, y1)] = ni4
 
 func _smooth_tilemap(brng: RandomNumberGenerator, passes: int = 3) -> void:
```

**One hunk, 4 lines added / 4 removed.** Against HEAD the same file now reads
`170 +++…-- / 166 insertions(+), 4 deletions(-)`: L01's 162 insertions plus this
4-line replacement. Line numbers shifted +8 from the analysis (`:2305-2319` →
current **`:2313-2327`**) because L01's spot work landed before this function.

### 8.3 Invariants confirmed (OBSERVED / DERIVED)

| Item | Status | Evidence |
|---|---|---|
| All four `_tb_pick` draws kept, same order/arguments | OBSERVED | diff leaves `:2314`, `:2318`, `:2322`, `:2326` verbatim; guards gate only the writes |
| `brng` stream byte-identical | DERIVED | `_blk()` is a pure dictionary lookup, draws no RNG (Y03 §10.3); no draw added/removed |
| Y03 neutralisation intact | OBSERVED | `tex = _blk("grass9")` still at `game.gd:2008`; P1 draws at `:1990`/`:1994` |
| L01 spot work intact | OBSERVED | `_stamp_grass_spots(brng)` call at `:2130`; function at `:2359`; diff vs backup contains no other change |
| B03 `terrain=5` removal intact | OBSERVED | grep finds exactly one `terrain[ii] = 5` at `:852`; gradient pass still collision-only |
| Mine apron / tile stamps intact | OBSERVED | `:2084-2088`, `:2121`, `:2143` unchanged; `_finalize_mine_tiles()` unchanged |
| Later passes intact | OBSERVED | `_smooth_tilemap(brng,3)` `:2134`, `_stamp_forest_borders(brng)` `:2137`, winter alias unchanged |
| `terrain` / `height` / `blocked` | DERIVED | no write added or removed; walkability/start protection byte-identical |
| Tileblock contract | DERIVED | `PackedByteArray` size/type, `ni >= 0` checks and `_blk()` validity unchanged; no out-of-atlas id |
| Static syntax balance (no Godot) | OBSERVED | comment/string-stripped counts: `()` 0, `[]` 0, `{}` 0 |
| Guardrails | DERIVED | no threshold lowered, no assertion deleted, no synthetic field; PORT APPROXIMATION, no donor parity |

### 8.4 Gate list for G04 (Y04 runs none — one Godot at a time)

1. `variant3d` selftest — expect **29/29**.
2. `variant3d` uitest — expect **17/17**.
3. `t_render_mode` — green.
4. `t_map_variety` — **5/5**, including `same_seed_byte_identical`; a frozen
   tileblock hash is not a valid gate (TRN-DATA / B03 R1).
5. `assert_clean` — **CLEAN**; 2D `app/` gates untouched.
6. Windowed `--seed 20261113` real-map + 64² P0 captures at matched camera, unique
   ids; `script_error_lines == 0`, `full_width_dark_rows == 0`,
   `non_black_fraction == 1.0`; second-agent C04/G05 read for **zero nested stepped
   rings**, L01 spots still present, no new seams/black rows.
7. Optional decisive probe (§5.4): same run with `--dump-map` → decode `tileblock`;
   check non-`grass9` transition ids collapse in the meadow, `terrain==5` stays at
   stone-disc level, `blocked[]` byte-identical to the pre-fix same-seed dump. No
   donor access required.

G04 should record paths, timestamps, camera and result JSON fields verbatim; C01
metric numbers are movement indicators only, never thresholds or parity claims.

### 8.5 Rollback

```powershell
Copy-Item -LiteralPath 'inbox\backup\game.gd.bak-Y04' -Destination 'variant3d\scripts\game.gd' -Force
```

Restores SHA-256 `25094E5FB90D2AF5036391513C8F166A97608654C90B6F88645F3424E994C36E`
exactly (Y03 + L01 state). No other file is involved.

### 8.6 Epistemic status

No Godot, runner job, queue mutation, donor file read/copy, or other source edit
occurred in this implementation step. Whether the rings are actually gone in the
rendered frame is **UNVERIFIED** until G04's matched-camera capture and the dump
probe. **No donor parity claim.**

---

*End of Y04 (analysis + Y04-IMPL). No Godot, no runner job, no queue mutation. Only
this report and the granted four-line `game.gd` hunk were written. No donor parity
claim.*
