---
id: V58
ticket: "TERRAIN-SWARM-2026-11-26 / V58 — READ-ONLY audit of I07 generation module against DONOR TRUTH"
title: "V58 — file:line audit of variant3d/scripts/terrain_donor_gen.gd (I07)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_EDIT__NO_GODOT_JOB
owner_file: "docs/terrain_swarm_2026-11-26/reports/V58_i07_audit.md (the ONLY repo file written)"
labels: [O, D, I, U, "PORT APPROXIMATION"]
audited_file: "variant3d/scripts/terrain_donor_gen.gd (2042 lines, read in full)"
parity_claim: false
parity_guard: "No donor GPU A/B frame exists (CHARTER.md:43-44,125). Every verdict below is a structural/source audit only; nothing here certifies donor visual parity."
---

# V58 — I07 generation module vs DONOR TRUTH

## 0. Scope, authority and pass register

Audited target: `variant3d/scripts/terrain_donor_gen.gd` (I07, SWARM_BOARD:138).
Authority chain used: `CHARTER.md`, `SWARM_BOARD.md`, `spec/02`, `spec/03`,
`spec/04`, `spec/05`, `spec/07`, `spec/10`, `reports/X03_dscript_corpus.md`,
`reports/X21_rng_vectors.md`, `reports/X26_blend_formula_verification.md`,
`reports/X23_corrected_relief_grids.md`, `reports/X28_shore_tile_vectors.md`.
Secondary (for item 9 only): `variant3d/scripts/terrain_donor_data.gd`,
`variant3d/scripts/terrain_donor_world.gd`.

Owner directive — multiple passes before any defect declared. Passes actually run:

| # | Pass | Result |
|---|---|---|
| P1 | Full sequential read of audited file, lines 1–1062, 1063–1762, 1763–2042 | Baseline map of every constant/stage/helper; no line skipped. |
| P2 | Targeted `grep` passes: `collision|set_u8|set_u16|collision|from_live_object`, `C_WATER_BYTE|hwater|hterrain`, `RESEED`, `F01_GRID_OFFSETS` | Confirmed 11+3 reseed sites, 3-of-4 grid offsets, ZERO collision writes. |
| P3 | Second read of coordinate-critical block, lines 1280–1324, and `_to_scan` 2013–2022 | Confirmed centre double-conversion defect (§Additional A). |
| P4 | Cross-check every numeric literal against cited spec/report line; X21 vector #1 hand-replay; X28 vectors 9/17–22 traced through `_shore_tile_name`/`_cliff_tile_name` | Confirmed RNG arithmetic, found shore/cliff selection defects (§Additional B/C). |
| P5 | Re-grep for any indirect collision write through generic setters (`data.set_*`) | Only `set_height` and `set_u16(resource_id)` exist; no collision path. |

No donor binary executed, no donor file copied, no repo source/config/test/shader/queue/git touched,
no Godot job. **No parity claim is made anywhere in this report.**

## 1. Verdict summary

| # | Item | Verdict | One-line reason |
|---|---|---|---|
| 1 | 11 re-seed sites, key1-only LCG, key0 no-op, X21 vectors | **PASS** | 11+3 sites issued in order; `s=(s*0xFC0D+0x3C6EF35F)&0xFFFFFFFF`, f32 output, key0 ledger-only. |
| 2 | `h=-1.1*B/255`, B≥58, no sign flip, coastal gate = mask B + height band | **PASS** | `-1.1*B/255` at :888; B≥58 enforced via `h<-0.25`; coastal gate uses B==255 class + band. |
| 3 | Relief blend formula / D05 paths / Min pivot / Max unused / in-place post-pass / X23 offsets G=968/1864/2798/2222 | **FAIL** (sub-parts 3a–3c PASS, 3d FAIL) | Formula and in-place post-pass correct; `F01_GRID_OFFSETS` omits `plt2=2222` (and `k_ravine_big_stone_1=8225`), so `decode_pattern_grid("plt2",…)` always errors. |
| 4 | Shoreline 3-pass constants (bsmooth r3; land 4/0.5/[0.01,100]; 3× coastal 0.35/0.5/[−100,−0.01]) | **PASS** | All constants at :142–152 and issued in `_smooth_chain`:933–954. |
| 5 | Three distinct water levels (−1.1 / −0.5 / −0.25 / −0.1) | **PASS** | Four separate constants :122/:156/:157/:158, no conflation. |
| 6 | Tile smoothing 3 H-then-V passes, not 6, not 3×3 | **PASS** | `_smooth_tiles`:1138–1173, `TILE_SMOOTH_PASSES=3`, H then V per iteration, in place. |
| 7 | Mine rings/ellipses in CELLS, 256 attempts/ore/ring, no food rects, missing case i=2 with zero-init dst | **FAIL** (units/attempts/food/gap PASS; centre conversion FAIL) | Radii in cells and gap reproduced, but ellipse centres add `W/2` twice (:1298+:1316) and owner-map seeds too (:1974+:2020). |
| 8 | No forbidden constructs (noise/dither, face promotion, HEIGHT_SCALE fudge, tile-art relief, invented constants, parity claims) | **PASS** | Export `parity="UNVERIFIED"`; PostProcess noise skipped; no scale multiplier; no parity claim. |
| 9 | Collision populated explicitly (I06 `from_live_object` does NOT map blocked) | **FAIL** | Zero collision writes anywhere in I07; `collision_tags` is read-only cliff input; `from_live_object` explicitly leaves collision unmapped. |

---

## 2. Item-by-item findings (file:line, evidence, fix)

### Item 1 — 11 re-seed sites / LCG / key0 no-op / X21 — **PASS**

**Evidence.**
- Constants: `:95–100` `LCG_MUL=0xFC0D`, `LCG_ADD=0x3C6EF35F`, `LCG_U32=0xFFFFFFFF`,
  `LCG_DIV=4294967296.0`, separate `DELPHI_LCG_MUL=0x8088405`/`ADD=1`.
- Site tables: `:112–115` `RESEED_SITES` = `D3:99, D3:146, D1:1100, D1:1161,
  D1:1177, D1:1213, D1:1538, D1:1616, D1:1772, D1:1909, D1:1927` — exactly X03's 11
  (`X03:161-163,727-765,786,849,937,961`; spec/02 §4). `:116` `EXT_KEY_SITES` =
  `D2:216/:513/:774`.
- All 14 reseeds are **issued**, not merely listed: `:731,:733` (D3), `:786` (D1:1538),
  `:806,:811,:820` (D2 ext), `:1263,:1267,:1279,:1284,:1303` (D1 start sites + :1616),
  `:1866` (:1772), `:1932` (:1909), `:1951` (:1927).
- Recurrence: `:338–346` `s=(s*mul+add)&LCG_U32`, `r=_f32(float(s)/LCG_DIV)`;
  `:354–360` `_f32` round-trips through binary32 (matches X21 §4.5/§6 and X21 §5.1 vector 1:
  key1=1 → `s1=0x3C6FEF6C`, `r1=0.236083001`).
- key0 no-op: `:323–328` `reseed_from_key(k)` sets `s=k&U32` only; `:330–336`
  `reseed_from_key64(k0,k1)` stores `key0=k0` for the ledger but seeds `s=k1&U32`;
  `:520` telemetry `key0_semantics="DISCARDED mod 2^32"`; `:643/:651/:661`
  `key0_status="NO-OP — X21 §4.3"`. X21 §4.3/§5.2 satisfied.
- Fixed draws: foreststype `:736–739` (1 draw, forced 0); minesdensity>2 `:792–793`;
  relieftype `:1818–1819` (conditional on `>4`, matches `D1:1621-1622`).

**Fix suggestion:** none required. Optional: add the X21 §5.1 20-vector fixture as a
selftest in I12 (not an I07 source change).

### Item 2 — mask height / B≥58 / sign / coastal gate — **PASS**

**Evidence.**
- `:122` `C_WATER_HEIGHT=-1.1`, `:123` `C_R_MULT=3.5`; `:882–894`
  `hwater = C_WATER_HEIGHT*(fb*(1+fr*C_R_MULT))`, `hterrain` by class,
  `data.height[i]=hwater+hterrain`. For shipped `_gauss` masks R=0 (`spec/03 §1`), this
  is exactly `h=-1.1*B/255`. Sign is negative — the stale "wrong-sign `relief()`" claim is
  **not** reintroduced; `:62–63` explicitly records X19's refutation.
- Three distinct thresholds: `:878` `_mask_water[i]=1 if ib==C_BCOLOR_WATER(255)` (class);
  `:888` depth bed; `:1071–1072` tile tag `b>0.0 and h<−0.25 / h<−0.1`.
  B≥58 boundary is the integer form of `h<−0.25` (`B=58 → h=−0.2502`); the port
  `B>58` off-by-one of `import_donor_masks.py:98` is avoided (`:64, :926`).
- Coastal gate: `:983–989` `_has_water_5x5` tests `_mask_water` (B==255 class), not a
  height-only threshold; `:963` applies the gate, `:967` applies the `[-100,-0.01]` band,
  `:950–952` runs 3 passes. This matches `D2:621,625-637` and spec/03 §3 / spec/05 §2.

**Note (not a defect):** `C_WATER_BYTE=58` at `:138–139` is referenced only in comments
(`:64,:67,:926`); the boundary is enforced through `h<−0.25` on the live height array,
which is donor-correct for tile classification. The constant is dead but harmless.

**Fix suggestion:** optional — delete or explicitly mark `C_WATER_BYTE` as a
documentation-only literal to avoid a future worker wiring it in twice.

### Item 3 — relief blend / D05 paths / X23 offsets — **FAIL** (3a–3c PASS, 3d FAIL)

**3a Formula — PASS.** `:1612–1618` reads `min` (`+0x5c`), `offset` (`+0x64`),
`terrain_scale` (`+0x68`), `replace` (`+0x3a`), `replace_for_water` (`+0x3b`), and
`base_h` (bilinear centre sample). `:1630–1633` applies the pivot
`g2 = (g−Min)*Scale + Min` for Replace/Smooth, `g2 = g*Scale` for ReplaceForWater.
Combines at `:1655–1663`:
- RFW `:1656` `stamped = g + hoff` → `g*Scale + Offset` (X26 table row 1).
- Replace `:1658` `stamped = base_h + g + hoff` with `g` already pivoted → `base_h + ((g−Min)*Scale+Min) + Offset` (X26 row 2 / X13 `REP-hil1-01` discriminator).
- Smooth `:1660–1663` reads `h0`, forms `t=(base_h−h0)*TerrainScale + g2 + Offset`, re-reads `h1`, `stamped=t+h1` — two distinct height reads, X26 row 3.
No `HeightFieldMax` read exists in the stamp (`:1612–1668` mentions only `hmin`), satisfying X26 E7 (0/6,751 `+0x60` operands).

**3b Min pivot / no clamp — PASS.** `:1627–1629` comment + code: `Min` is a pivot, no `[Min,Max]` clamp; the only clamp hook is the explicitly `[U]` `global_setter_clamp_hook` (`:250,:1664–1667`).

**3c In-place post-pass — PASS.** Gate is `Stand && Smooth` independent of blend branch
(`:1672–1676`, matching X26 implication 4 / `g_hil4`). Default
`stamp_smooth_buffer_mode="in_place"` (`:238`); `:1725` selects `data.height` as source,
`:1757` `src = snap if double_buffer else data.height`, `:1760` writes `data.set_height`
on the same field — in-place read-after-write per X26 E8. Kernel constants: 8-neighbour
clear test `:1731–1737`, radial remap `(Radius−Offset)/d` `:1738–1744`, `Factor`
iterations `:1745`, 4-neighbour mean `/C_STAMP_SMOOTH_DIV(=4.0)` `:1758–1760`.

**3d X23 grid offsets — FAIL.** `:214–218`:
```
const F01_GRID_OFFSETS = { "hil1": 968, "g_hil4": 1864, "k_ravine_1": 2798 }
```
X23 §4/§6 S1 (and the task) require **`plt2 = 2222`** (and `k_ravine_big_stone_1 = 8225`).
`decode_pattern_grid` (`:560–588`) returns
`"no F01/X26 offset for this pattern — TODO(I02)"` at `:574–576` for `plt2`, so the
corrected `plt2` grid can never be stamped. Header comment `:51–55` lists only three
offsets, confirming the omission is systemic rather than a hidden alias.

**Precision caveat (not counted as the item verdict):** `:240–243` default
`stamp_precision_model="double_store_f32"`; `_pf` (`:1681–1687`) is a no-op in that mode,
so the pivot `g2` is left as f64 until `set_height` stores f32. X26 §Vector verification
declares the **f32-step** model the bit-exact contract (`g2` stored f32 at donor
`0x756619`, `base_h` stored f32 at `0x75643a` before the final add). The formula
structure is right but the default precision model is not the authoritative one.

**Fix suggestion (3d):** add `"plt2": 2222` and `"k_ravine_big_stone_1": 8225` to
`F01_GRID_OFFSETS` (`:214–218`) and extend the header provenance comment (`:51–55`)
with X23 §4 E2/S1. **Fix suggestion (precision):** change the default
`stamp_precision_model` to the f32-step behaviour (round `g2` and `base_h` to f32 before
the final add) or document the current default as explicitly non-bit-exact in telemetry.

### Item 4 — shoreline 3-pass constants — **PASS**

**Evidence.** `:142` `C_SMOOTH_RADIUS_BSMOOTH=3`; `:143–146` land `power=4.0,
lerp=0.5, min=0.01, max=100`; `:147–150` coastal `power=0.35, lerp=0.5,
min=−100, max=−0.01`; `:151` `C_SMOOTH_COAST_PASSES=3`; `:152` neighbour radius 2.
Issued in `_smooth_chain`:933–954 — bsmooth hook `:936–941` (radius 3),
whole-map land pass `:943–945`, loop of 3 coastal passes `:950–952`.
`_smooth_custom`:957–980 reproduces `D2:220-242` (power==0 early-out `:959–960`,
diagonal sampling `:969–973`, equality skip `:974–975`, `res=h+((z1+z2)/2−h)/power`
`:976–978`, `Lerp` `:979`, store `:980`). All values are verbatim `generatemap.inc:591,
606,612,625,637` (X03:536,538,543–547) and spec/05 §2.

**Caveat (labelled, not a defect):** the radius-3 `SmoothTerrain` pass is a `[U]` native
kernel (D03 U3) and is skipped by default via `bsmooth_kernel` (`:261–265,:936–941`),
with a telemetry note. The charter permits this labelled skip.

**Fix suggestion:** none for constants; if/when D03 recovers the kernel, wire it to
`bsmooth_kernel` without changing the constants.

### Item 5 — three distinct water levels — **PASS**

**Evidence.** `:122` basin `−1.1`; `:156` water-field Y `−0.5` (`generatemap.inc:688,704`);
`:157` tile classify `−0.25` (`texturemap.inc:30,466-467`); `:158` shore band `−0.1`
(`:31,469-470`). Four separate fields, no value reused for a second role:
`_water_fields`:1000–1028 derives flags from mask B (`:1011`) and stores `y=C_WATERFIELD_OFFSET_Y`
(`:1020`); `_texture_tiles`:1071–1072 uses `−0.25/−0.1` only for classification.
Matches spec/05 §1 and X28 §3.5 (which counts the shader plane as a fifth, `[U]`, field).

**Fix suggestion:** none. Keep the fields separate at the I11/I12 seam (X28 §5 item 5).

### Item 6 — tile smoothing 3 H-then-V passes — **PASS**

**Evidence.** `:166` `TILE_SMOOTH_PASSES=3` (`smoothtiles.inc:237`; cfg's 6 preserved as
contradiction at SWARM_BOARD C2). `_smooth_tiles`:1138–1173: one snapshot (`:1142–1145`),
`for k in range(3)` (`:1146`); inside each iteration a horizontal sweep over all
`(x,x+1)` pairs (`:1147–1158`) then a vertical sweep over all `(y,y+1)` pairs
(`:1159–1170`), both in place on `a`; single write-back (`:1171–1172`). Chain matching
`_neighbour_tiles`:1176–1220 and `_find_random`:1223–1237 follow X08 §5.4/§5.5
(strict `<` first-tie, no `break`, 80-bit-independent probability walk). No 3×3 kernel,
no face promotion — stated at `:1140–1141` and confirmed in code.

**Fix suggestion:** none.

### Item 7 — cells / 256 attempts / no food rects / missing case i=2 — **FAIL**

**Passing sub-parts.**
- Units are cells: `:1470–1489` radii `14+8R, 38+8R, 130+40R, 22+16R, …` written as
  plain cell numbers; `:724` telemetry `mine_band_units="MAP CELLS 1:1 — no DONOR_UNITS
  scaling"`; ellipses `:175–180` are `5/7, 12/15, 22/18` used unscaled. V08 §8 satisfied.
- 256 attempts per ore per ring: `:172` `C_TRYCOUNT_MINES=256`; `_setup_mines`:1333–1379 —
  ring loop `:1341`, three ores `:1344–1345`, `for k in range(256)` `:1347`, name draw
  `:1348`, band draw `:1351`, angle draw `:1360`, first-success break `:1371`. `continue`
  rings skip the angle draw but still consume the name draw (`:1351–1353`), matching
  V12/X03 :854–891.
- Missing case i=2: `_band_id`:1439,1447,1455 return `-2`; `_setup_mines`:1342 zero-inits
  `dst=0.0`, `:1354–1355` sets `gap_reproduced`, `:1372–1374` sets the trace flag and
  `PORT APPROXIMATION` note "NO fix" — matches spec/07 §1/§7 and V12 §4.
- No food rects: `_setup_starting_resources`:1505–1548 implements six stone/forest
  placements + three keep-clear ellipses; `:1548` note "No food rects in
  SetupStartingResources (X22 X-C6)"; `sow_field`:540–553 is deliberately NOT called from
  `generate()` (`:531–539`). spec/07 §1 / V26 C2 satisfied.

**Failing sub-part — centre double-conversion (P3 second pass).**
`_start_to_cell`:1308–1317 converts donor-centred starts to **cell indices** by adding
`W/2, H/2`. The same cell index is passed to `_fill_ellipse` at `:1298` (and `:1518`,
`:1546` inside `_setup_starting_resources`), but `_fill_ellipse`:1316–1317 adds
`_grid_w/2`, `_grid_h/2` **again**:
```
:1316  var ix = int(floor(float(cx0) + float(_grid_w / 2) + float(xx)))
:1317  var iy = int(floor(float(cy0) + float(_grid_h / 2) + float(yy)))
```
For a 640² map a centred start at `(0,0)` becomes `c=(320,320)`, then the ellipse centre
becomes `(640,640)` — out of map; only starts in the negative half survive the bounds
test at `:1318`. Conversely `_setup_mines`/`_setup_starting_resources` use `cx0, cy0`
**directly** as cell indices (`:1366, :1536, :1538`), so ellipses and mines are placed in
two different coordinate systems in the same stage. Donor `D1:26-27` adds `mapW div 2`
exactly once (`X03:206-208`), to an already-centred coordinate. The same double-add
exists in owner-map seeding: `_stage_owner_map`:1974 calls `_start_to_cell`, then
`_to_scan`:2020–2021 adds `+320` and divides by 4, shifting every owner seed by ~80 scan
cells for a 640² map.

**Fix suggestion.** Make one convention explicit. Minimal: remove the `+ _grid_w/2 /
_grid_h/2` at `:1316–1317` (keep `cx0, cy0` as cell indices, matching mines) and change
`_to_scan`:2020–2021 to accept cell indices (drop the `+320`, use `floor(x/4)` for a
640²-equivalent scan grid, or add a `centred→cell→scan` helper and call it once).
Do **not** change the radii — they are already correctly in cells.

### Item 8 — forbidden constructs — **PASS**

**Evidence.**
- No noise/dither: `:812–814` explicitly skips the editor-only PostProcess Gaussian
  ("Do NOT port its Gaussian/noise (X03 §5h, D7:63-82)"); `_channel`:918–919 zero-fills
  absent mask channels with a note rather than synthesising a field.
- No face promotion: `:1124–1135` and `:1133–1135` keep cliff art as art gates; no
  `vf/vs` id promotion exists (default rock ids only).
- No `HEIGHT_SCALE` fudge: `:441` telemetry `height_unit="UNVERIFIED raw float32; no
  HEIGHT_SCALE multiplier"`; I06 mirrors this (`terrain_donor_data.gd:208`). No
  multiplier applied in `_mask_to_height` or `_stamp_pattern`.
- No tile-art relief: `:2040` "NO post-collision height writes"; no height write in
  `finalize`.
- No invented donor constants masquerading as truth: every numeric literal carries a
  `donor path:line` comment (`:13`); genuinely `[U]` values live behind named hooks with
  TODO owners (`:220–303`). `sector_names`:275–277 is labelled `[D]`/`[U]`.
- No parity claim: header `:71–72`, telemetry `:426,:501`, stats `:522` all say
  `"UNVERIFIED"`; no A/B frame referenced.

**Caveat (labelled PORT APPROXIMATION, not a forbidden-construct defect):**
`_cliff_tile_name`:1135 returns a hardcoded `"rock4"` face default with `TODO(D08)` —
see Additional B below.

**Fix suggestion:** none for the eight forbidden constructs; keep parity string at
`"UNVERIFIED"` in all emitters.

### Item 9 — collision populated explicitly — **FAIL**

**Evidence.**
- I06 contract: `terrain_donor_data.gd:211–212` `collision_layout` label and
  `"collision_population": "from_live_object does NOT map legacy blocked -> collision;
  I07/I11 must populate collision explicitly (4 tags/cell; 2x view is derived); no legacy
  semantics invented"`. `from_live_object`:411–423 confirms at `:423`
  `"legacy blocked -> collision NOT mapped; I07/I11 must populate collision explicitly"`.
  `terrain_donor_world.gd:192–193,210–211` calls `from_live_object` during `bind`/`build`
  but never writes collision.
- I07: **zero collision writes.** P2/P5 greps over the whole audited file find only:
  a contract comment `:84`, tag constants `:101–107`, an unresolved cliff-tag hook
  `:294–298` (`collision_tag_cliff=null`), an input-only `collision_tags` parameter
  `:417`, a "TODO(D01): collision clear" comment at `:751`, a **read** of caller tags
  for the cliff trigger `:1116–1120`, owner-map note `:1960`, and finalize note
  `"shore_collision … engine side [U]"` at `:2038`. The only setter calls in the file
  are `set_height` (`:894,:1674,:1766`) and `set_u16(resource_id)` (`:1677`).
  `_stage_clear`:746–751 clears `_occ/_bsmooth/_mask_water` but not `data.collision`.
- Donor tags are defined (`:102–107`: clear/water=87/bridge=10/landborder=109/
  waterborder=110, radius 3) but never applied to any cell.

**Consequence:** whatever `from_live_object` left in `collision` (or the zero state after
`configure_grid`) is passed unchanged to I08/mesh. The donor's water-border/shore and
cliff/steep collision painting (`dmscript.global:819`, `texturemap.inc:88-129`,
`_misc_SetShoresCollision` at `D1:2068`) is not reproduced.

**Fix suggestion.** Populate `data.collision` explicitly in I07 (or assign a named I11
owner and implement there):
1. In `_stage_clear` (`:746–751`) zero the 4 tags/cell.
2. In `_texture_tiles` (`:1043–1079`) set `C_TAG_WATER(87)` on `b_water` cells and
   `C_TAG_WATERBORDER(110)` within `C_WATERBORDER_RAD(3)` of them (shore collision).
3. Paint the cliff/steep tag via `collision_tag_cliff` when resolved; until then record
   the cells in `meta` with an `[U]` label, never invent a tag value.
4. Emit telemetry counts per tag so I12 can assert non-zero water/waterborder coverage.

---

## 3. Additional observations (outside the nine items, found during P1/P4)

These are reported because X03/X28 were mandated reading and the implementations sit
inside the audited file; they are **not** promoted into the nine verdicts above.

**A. Centre double-conversion** — detailed under Item 7; affects both C1/C2/C3
keep-clear ellipses and owner-map seeds.

**B. Cliff six-face table stubbed.** `_cliff_tile_name`:1124–1135 checks only
`absf(h)` overrides (`:1127–1132`) and returns a hardcoded `"rock4"` at `:1135` for
every face. X28 §3.4 / `texturemap.inc:560-575` require six `vec_pre` windows
`bRB→rock4, bLB→rock7, bR→rock4, bB→rock1, bT→rock4, bL→rock3`, with **no `+180`**
(cliff is the `else` of the shore block). X28 vectors 18 (`pre=135→rock7`), 20
(`pre=90→rock1`) and 22 (`pre=180→rock3`) fail against the current code. The comment at
`:1133–1135` acknowledges the table but does not implement it.
**Fix:** implement the if/else chain on the pre-angle with first-match-wins, keeping the
`absf(h)` overrides after face choice.

**C. Shore `bRT` catch-all lost.** `_shore_tile_name`:1102 computes
`sector = int(floor((ang+22.5)/45)) % 8`; the `%8` wrap maps X28 vector 9
(`post=350°`) to sector 0 `bR→sandsea6`, whereas `texturemap.inc:500-501` has the
upper bound commented and an unguarded `else bRT→sandsea5`. The sector→tile mapping
itself (`:1107–1110`) is correct for the other seven sectors.
**Fix:** replace the modulo with the literal verbatim if/else windows of
`texturemap.inc:479-501`, unguarded final `else`.

**D. X13 stale-vector guard is correctly present.** `:51–55,:252–258` flag
`G=1000/1912/2866` as stale and refuse non-F01 offsets; this matches X23 §6 S4/S5.
Keep it when fixing 3d.

---

## 4. UNVERIFIED register (do not promote)

| ID | Claim | Status |
|---|---|---|
| UV1 | True x87 80-bit intermediate and f32-step default (Item 3 precision caveat) | `[U]` X26 U3; I07 default `double_store_f32` is `PORT APPROXIMATION`. |
| UV2 | Native `SmoothTerrain(...,3)` bsmooth kernel | `[U]` D03 U3; labelled skip at `:936–941`. |
| UV3 | Global `setHeight` clamp / row-sign flip / rotation rounding | `[U]` hooks at `:248–250`; no parity claim. |
| UV4 | Steep/cliff collision tag value | `[U]` `collision_tag_cliff=null` at `:298`; no value invented. |
| UV5 | Non-640 scan-grid mapping | `[U]` `:2018–2021` labelled; compounded by Item 7 centre bug. |
| UV6 | Runtime execution of `texturemap.inc` / `generatemap.inc` GSC text | `[U]` all tile/selection rules are authored intent; no donor GPU frame. |

**Closing:** 6 of 9 items PASS (1, 2, 4, 5, 6, 8), 3 items FAIL (3, 7, 9), with
sub-part detail recorded above. Every defect was re-read in at least two passes
(P2/P3/P4/P5). This is a source audit only: **no donor visual parity claim; parity
status remains `UNVERIFIED`.**

*End of V58. Exactly one repository file written. Donor read-only; no source, config, test, shader, queue, git or Godot state changed.*
