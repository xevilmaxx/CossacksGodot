---
id: V09
ticket: "TERRAIN-SWARM-2026-11-26 / Verify / V09 — extract an implementation-ready spec for the 2D smooth→detail order + verbatim rules transplant into the fresh terrain_donor_* module"
agent: "V09 (verification subagent, 30-agent donor-first terrain swarm)"
owner_file: docs/terrain_swarm_2026-11-26/reports/V09_2d_order_transplant.md
created: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_APP_EDIT__NO_VARIANT3D_EDIT__NO_GODOT_JOB__NO_DONOR_ACCESS
labels: [O, D, I, U, "PORT APPROXIMATION"]
scope: "Exactly one repo file written (this report). `app/**` and `variant3d/**` read-only. No .gd/.gdshader/.json/.cfg/.import/asset/test/git edit; no Godot process; no godot_runner.py job; no donor file opened this pass."
parity_claim: false
parity_guard: "NO DONOR PARITY CLAIM. No donor GPU A/B frame exists and no donor binary was opened by V09. 'More donor-faithful' means only (a) literal agreement with a cited authored donor path:line in prior read-only reports, or (b) absence of a change its own author labels PORT APPROXIMATION. Runtime activity of every cited donor `.inc` line is [U] because all code lines are `;`-commented. Everything implemented from this report stays PORT APPROXIMATION until a real A/B frame lands (CHARTER.md:41,44,125)."
verification_passes: 3
sources_read:
  - docs/terrain_swarm_2026-11-26/CHARTER.md; docs/terrain_swarm_2026-11-26/SWARM_BOARD.md
  - docs/terrain_swarm_2026-11-26/reports/P05_2d_reuse.md
  - docs/terrain_swarm_2026-11-26/spec/10_STAGE_ORDER.md; docs/terrain_swarm_2026-11-26/spec/06_TILE_AND_ATLAS.md
  - docs/terrain_swarm_2026-11-26/reports/F03_gen_config.md; docs/terrain_swarm_2026-11-26/reports/F05_tile_mapping.md
  - docs/terrain_swarm_2026-11-25/reports/H06_pass_order.md
  - docs/coord_swarm_2026-11-25/reports/RV_TRN_02_smoothing_rules.md; docs/coord_swarm_2026-11-25/reports/DTRN_01_donor_terrain_pipeline.md
  - app/scripts/game.gd (read tool + grep tool + PowerShell re-read; see §0 frontmatter correction)
  - variant3d/scripts/game.gd (read tool + grep tool + PowerShell re-read)
---

# V09 — 2D smooth→detail order and verbatim rules: transplant specification

## 0. Label key and the line-number reconciliation (three passes)

**[O]** observed (literal on-disk line / cited text). **[D]** derived (deterministic
consequence of [O]). **[I]** inference without a donor A/B. **[U]** UNVERIFIED.
**PORT APPROXIMATION** = an explicit port substitute for an unrecovered donor rule.

- **[O] Pass discipline.** The task warns of contradictory line numbers. Three
  passes were run over **both** files before any number below was declared:
  (1) `read` tool on the full function bodies; (2) `grep` for every `func` name and
  for distinctive statements (`_smooth_tilemap(brng, 3)`, `_apply_detail_pass(`,
  `int(im.get_pixel(sx, sy).r * 255.0) / 2`, `_noise2(`, `tex = _blk("test8")`,
  `return _blk(...)`, `terrain[...] = 5`); (3) an independent **PowerShell**
  `Get-Content` re-read of the exact line indices. All three agree on every number
  declared in this report. Where a prior report disagrees, **this report governs**
  (same convention as P05:35-38).
- **[O] The contradiction resolved.** `H06_pass_order.md:37,90-106` cites 3D lines
  `_assign_tileblocks():1957`, detail `:2039`, smooth `:2067`, `_tb_pick():2170`,
  `_tb_smooth_pair():2200`, `_smooth_tilemap():2263`. Those are **stale**: the
  current file has `2015 / 2097 / 2134 / 2251 / 2285 / 2348` respectively
  (verified 3×). P05:105/`E11` and P05:107-109 (`1959-2012`, `2097`, `2134`,
  `2251-2283`, `2285-2346`, `2144-2161`) **are** current. H06's 2D numbers
  (`app:1581-1605`, `:1682`, `:1689`, `:1787-1804`, `:1806-1867`, `:1869-1876`)
  remain current and are confirmed here.
- **[D] Cross-file line numbers collide**: e.g. `app:1959` is `var ri := ...`,
  while `variant3d:1959` is `func _apply_detail_pass(...)`. Every citation below
  is prefixed with its full file path.
- **[O] Frontmatter correction**: the intended source line `app/scripts/gdgame.gd`
  was a drafting typo; the only file read is `app/scripts/game.gd`.

---

## 1. Executive summary

1. **[O]/[D] The transplant is a behaviour transplant into a NEW file, not a file
   copy.** The receiving module is `variant3d/scripts/terrain_donor_*.gd`
   (`CHARTER.md:57-61`), composed at the `world3d.gd` seam (`P01:71-78`; C1 is still
   being reconciled by V05). Every 2D file stays byte-untouched; all terrain art is
   already hardlinked (P05 E22: 685 inode pairs).
2. **[O] Exact 2D smooth/detail functions (current tree, 3-pass verified):**
   `app/scripts/game.gd:_apply_detail_pass()` **:1581-1605** (loader `_load_detail_bitmaps()`
   **:1571-1579**); `_assign_tileblocks()` **:1610-1707** with smooth call at **:1682**
   and detail call at **:1689**; `_tb_pick()` **:1787-1804**; `_tb_smooth_pair()`
   **:1806-1867**; `_smooth_tilemap()` **:1869-1876**; rule table loaded by
   `_load_terrain_structs()` **:1409-1419**. Quoted verbatim in §3.
3. **[O] Corresponding 3D sites:** `variant3d/scripts/game.gd:_apply_detail_pass(brng)`
   **:1959-2010** (with B03-P1 re-roll **:1989-1996** and Y03 collapse **:2008**);
   detail call **:2097**, smooth call **:2134** (flipped); `_tb_pick()` **:2251-2283**
   (B03-P3 redirect **:2276-2281**); `_tb_smooth_pair()` **:2285-2346** (four
   `test8/grass9` guards **:2333,2337,2341,2345**); `_smooth_tilemap()` **:2348-2355**;
   Y08/Y08b `test8` flatten **:2144-2161** plus mine/start `test8` **:382,388,398**.
4. **[D] Donor-grounded differences** (§4): the smooth→detail order
   (`generatemap.inc:776`→`:786`→`:795` via H06:36-39,52-56), the detail rule
   (`loadtextureterrainfrombitmap.inc:4,8-9,25-29,33-41` via H06:60 / RV-TRN-02:557-565),
   the 3-pass roulette/Δ rules (`smoothtiles.inc:63-80,84-187,191-237` via
   RV-TRN_02:368-445 / F03:562-568), and the `ground1`/`grass1` ids
   (`texturemap.inc:627-636` via F05:113,146; `terrain.presets:6` id 0 = `grass1`
   via F05:56). All are **[O] as authored text / [U] runtime** — every donor code
   line is `;`-commented (RV_TRN_02:468-478; F03 F15:815).
5. **[O]/[D] Port inventions** (§4): all seven labelled 3D substitutions — B03-P1,
   Y03, B03-P2, B03-P3, the four art guards, L01 spots and Y08/Y08b — are explicit
   **PORT APPROXIMATION** in their own comments. None is donor-grounded. The
   reversed 3D order is also a port deviation whose stated donor justification
   (`variant3d/scripts/game.gd:2094-2096`) cites a reconstruction that
   `H06:71-80` shows is contradicted by the literal call sites.
6. **[O] Do not transplant** the `_noise2` height-cap dither
   (`app/scripts/game.gd:1090-1097`, statement at `:1095-1096`) — forbidden by
   `CHARTER.md:60` / S-25-09. **[D] Honest correction to P05 E23:** the dither is
   **not** 2D-only — `variant3d/scripts/game.gd:1267-1274` carries it verbatim
   (`:1272`). It is a *shared* forbidden field, so "not transplanting" it requires
   actively omitting it from the fresh module, not merely copying 2D. The
   `terrain=5` hill paint (`app:786-792`, statement `:792`) and steep-cell paint
   (`app:1098-1122`, statement `:1121`) are donor-literal but were removed in 3D
   (`variant3d:853-861`, `:1297-1310`) to kill the concentric maze; conditional
   only, never a verbatim transplant (P05 T7/U5).
7. **[U] No parity claim.** "More donor-faithful" = citation-level agreement with
   authored donor text or absence of a self-labelled PORT APPROXIMATION. Same-seed
   determinism is preserved by construction but **UNVERIFIED** without a run;
   visual equivalence and gate movement are **UNVERIFIED**.

---

## 2. Evidence table

| ID | Source (file:line) | Observation | Label |
|---|---|---|---|
| V09-E01 | `app/scripts/game.gd:1581-1605` | `_apply_detail_pass()` verbatim donor detail rule; no `brng` parameter. | [O] 3× verified |
| V09-E02 | `app/scripts/game.gd:1603,1605` | `tex = int(im.get_pixel(sx, sy).r * 255.0) / 2`; written verbatim to `tileblock[i]`. | [O] |
| V09-E03 | `app/scripts/game.gd:1682` → `:1689` | `_smooth_tilemap(brng, 3)` **before** `_apply_detail_pass()`; comment at `:1686-1688` states "SmoothTiles ran BEFORE it". | [O] |
| V09-E04 | `app/scripts/game.gd:1787-1804` | `_tb_pick` sums `prob`, one `brng.randf()` draw, returns `_blk(str(td.get("name","")))` at `:1803` — authored name, no art redirect. | [O] |
| V09-E05 | `app/scripts/game.gd:1806-1867` | `_tb_smooth_pair` applies donor Δ rules verbatim: `absi(...)==1 and not (az_best and bz_best)` at `:1850`; Δ=2 midpoint pick `:1852-1859`; Δ>2 one-step pull `:1860-1867`. | [O] |
| V09-E06 | `app/scripts/game.gd:1869-1876` | `_smooth_tilemap` = 3 passes, horizontal then vertical sweep. | [O] |
| V09-E07 | `app/scripts/game.gd:1409-1419` | `_load_terrain_structs` loads `presets_summer.json` + `smooth_summer.json` (10 chains) into `tbl_names`/`tbl_smooth`. | [O] |
| V09-E08 | `app/scripts/game.gd:1571-1579`, `:1587`, `:1595` | Bitmap loader; eligibility test `int(tileblock[i]) != grass0` → only index-0/`grass1` cells change. | [O] |
| V09-E09 | `variant3d/scripts/game.gd:1959-2010` | Detail pass, same base rule (`tex` at `:1981`) but adds B03-P1 (`:1989-1996`) and Y03 `tex = _blk("test8")` (`:2008`). | [O] |
| V09-E10 | `variant3d/scripts/game.gd:2097` vs `:2134` | **Detail before smooth** (flipped vs 2D). Comment `:2094-2096` cites DTRN-01, contradicted by `H06:71-80`. | [O]/[D] |
| V09-E11 | `variant3d/scripts/game.gd:2266-2282` | `_tb_pick` redirects `grass_ground1/2/3 → grass9/test8/test7`; label PORT APPROXIMATION at `:2268-2275`. | [O] |
| V09-E12 | `variant3d/scripts/game.gd:2331-2346` | Four `!= test8 && != grass9` write guards at `:2333,2337,2341,2345`; absent in 2D. | [O] |
| V09-E13 | `variant3d/scripts/game.gd:2144-2161`, `:382`, `:388`, `:398` | Whole-disc `test8` flatten (role 0/2 land); mine/start aprons use `test8`; self-labelled PORT APPROXIMATION at `:2144`, `:2149`, `:382`, `:388`. | [O] |
| V09-E14 | `app/scripts/game.gd:324-330`, `:333-343`, `:1673-1678`, `:1693-1698` | Mine apron `ground1`, start clearing `grass1`, in-base and final-authority writes. | [O] |
| V09-E15 | Donor `generatemap.inc:776`→`:786`→`:795`; `smoothtiles.inc:237`; `loadtextureterrainfrombitmap.inc:4,25-29,33-41` via H06:36-39,52-60 | Authored call order TextureMap → 3-pass SmoothTiles → detail bitmap; detail ids are final, not smoothed. | [O] text / [U] runtime |
| V09-E16 | `smoothtiles.inc:63-80,84-187,191-237` via RV_TRN_02:368-445; `tilesmooth_scripts.cfg` via F03:539-568, F03 F3/F6/F8 | Roulette over SumProb, J-index Δ rules, 3 passes; `TileSmoothPasses=6` is editor-facing; `grass_ground` SumProb 1.0028 is authored. | [O]/[D] text / [U] runtime |
| V09-E17 | F05:56,113,146,150,215,215-218; `texturemap.inc:627-636` via F05:113 | `grass1` = donor preset id 0; `ground1` = id 10 road/worked dirt; `grass_ground1` = id 14 transition; `test8` = id 79 "detail variant"; `grass1=test10=test11` byte-identical art. | [O]/[D] |
| V09-E18 | `app/scripts/game.gd:1090-1097` (`:1095-1096`); `variant3d/scripts/game.gd:1267-1274` (`:1272-1273`) | `_noise2`-based `RELIEF_PLATEAU` vs `RELIEF_PLATEAU - 0.03` cap; present in **both** trees; synthetic field. | [O]; forbidden by CHARTER.md:60 |
| V09-E19 | `app/scripts/game.gd:792`, `:1121`; `variant3d/scripts/game.gd:853-861`, `:1297-1310` | 2D paints `terrain=5` on hill stamps and steep cells; 3D uses `pass` / collision-only and documents the maze. | [O]/[I] / [U] |
| V09-E20 | `app/scripts/game.gd:1649-1655` vs `variant3d/scripts/game.gd:2055-2066` (`DONOR_FOREST_BASE`) | Two different donor-authored family lists for terrain role 2; P05 U3/Q3 unresolved. | [O] + [U] |
| V09-E21 | P05 E22 / R6, `CHARTER.md:64` | 685 hardlinked terrain asset pairs; a write through either tree mutates both. Fresh module must use read-only `res://` loads. | [O]/[D] |

---

## 3. Verbatim excerpts

### 3.1 2D `app/scripts/game.gd` — smooth and detail passes (exact functions, 3× verified)

`_load_detail_bitmaps()` **:1571-1579** and `_apply_detail_pass()` **:1581-1605**:

```
1571: func _load_detail_bitmaps() -> void:
1572: 	# donor data/gen/bitmap/ext/tile_low/highground.bmp (320x320, R = tex*2):
1573: 	# LoadTextureTerrainFromBitmap picks the bitmap by height and paints every
1574: 	# cell still on TileBlock 0 with the bitmap's tile.  Copied to
1575: 	# assets/terrain/structs/*.png by tools/copy_assets.py.
1576: 	if tile_low_im != null and tile_high_im != null:
1577: 		return
1578: 	tile_low_im = _load_image_tex("res://assets/terrain/structs/tile_lowground.png")
1579: 	tile_high_im = _load_image_tex("res://assets/terrain/structs/tile_highground.png")
1580:
1581: func _apply_detail_pass() -> void:
1582: 	# donor loadtextureterrainfrombitmap.inc: h < 0.1 reads tile_lowground,
1583: 	# else tile_highground; tex = R div 2; only cells still on block 0 change.
1584: 	_load_detail_bitmaps()
1585: 	if tile_low_im == null or tile_high_im == null:
1586: 		return
1587: 	var grass0 := _blk("grass1")
1588: 	var lw := tile_low_im.get_width()
1589: 	var lh := tile_low_im.get_height()
1590: 	var hw := tile_high_im.get_width()
1591: 	var hh2 := tile_high_im.get_height()
1592: 	for y in MAP_H:
1593: 		for x in MAP_W:
1594: 			var i := _t(x, y)
1595: 			if int(tileblock[i]) != grass0:
1596: 				continue
1597: 			var h: float = height[i] if height.size() == MAP_W * MAP_H else 0.0
1598: 			var im: Image = tile_low_im if h < 0.1 else tile_high_im
1599: 			var iw := lw if h < 0.1 else hw
1600: 			var ih := lh if h < 0.1 else hh2
1601: 			var sx: int = clampi(int(float(x) / float(MAP_W) * float(iw)), 0, iw - 1)
1602: 			var sy: int = clampi(int(float(y) / float(MAP_H) * float(ih)), 0, ih - 1)
1603: 			var tex: int = int(im.get_pixel(sx, sy).r * 255.0) / 2
1604: 			if tex >= 0 and tex < tbl_names.size():
1605: 				tileblock[i] = tex
```

`_tb_pick()` **:1787-1804**, `_tb_smooth_pair()` **:1806-1867**, `_smooth_tilemap()` **:1869-1876**:

```
1787: func _tb_pick(li: int, gi: int, brng: RandomNumberGenerator) -> int:
1788: 	var chain: Array = tbl_smooth[li]
1789: 	if gi < 0 or gi >= chain.size():
1790: 		return -1
1791: 	var group: Array = chain[gi]
1792: 	var total := 0.0
1793: 	for td in group:
1794: 		total += float(td.get("prob", 0.0))
1795: 	if total <= 0.0:
1796: 		return -1
1797: 	var r := brng.randf() * total
1798: 	var acc := 0.0
1799: 	for td in group:
1800: 		var p := float(td.get("prob", 0.0))
1801: 		acc += p
1802: 		if p > 0.0 and r < acc:
1803: 			return _blk(str(td.get("name", "")))
1804: 	return -1
1805:
1806: func _tb_smooth_pair(x1: int, y1: int, x2: int, y2: int, brng: RandomNumberGenerator) -> void:
1807: 	# T2GEN P0-1: smoothing must not replace a mine apron's neutral ground1
1808: 	# with a test2/test3 transition tile (mines_display.md A2).
1809: 	if mine_mask[_t(x1, y1)] != 0 or mine_mask[_t(x2, y2)] != 0:
1810: 		return
1811: 	var i1: int = tileblock[_t(x1, y1)]
1812: 	var i2: int = tileblock[_t(x2, y2)]
1813: 	if i1 == BLK_WATER or i2 == BLK_WATER or i1 == i2:
1814: 		return
1815: 	if i1 >= tbl_names.size() or i2 >= tbl_names.size():
1816: 		return
1817: 	var n1 := str(tbl_names[i1])
1818: 	var n2 := str(tbl_names[i2])
1819: 	var best := -1
1820: 	var bi1 := -1
1821: 	var bi2 := -1
1822: 	var az_best := false
1823: 	var bz_best := false
1824: 	var md := 1000000
1825: 	for li in tbl_smooth.size():
1826: 		var chain: Array = tbl_smooth[li]
1827: 		var a := -1
1828: 		var b := -1
1829: 		var az := false
1830: 		var bz := false
1831: 		for gi in chain.size():
1832: 			for td in chain[gi]:
1833: 				var nm := str(td.get("name", ""))
1834: 				if nm == n1:
1835: 					a = gi
1836: 					az = float(td.get("prob", 1.0)) <= 0.0
1837: 				if nm == n2:
1838: 					b = gi
1839: 					bz = float(td.get("prob", 1.0)) <= 0.0
1840: 		if a >= 0 and b >= 0 and a != b and absi(a - b) < md:
1841: 			md = absi(a - b)
1842: 			best = li
1843: 			bi1 = a
1844: 			bi2 = b
1845: 			az_best = az
1846: 			bz_best = bz
1847: 	if best < 0:
1848: 		return
1849: 	# donor: adjacent groups are compatible only if at least one has prob>0
1850: 	if absi(bi1 - bi2) == 1 and not (az_best and bz_best):
1851: 		return
1852: 	if bi1 - bi2 == 2:
1853: 		var ni := _tb_pick(best, int((bi1 + bi2) / 2), brng)
1854: 		if ni >= 0:
1855: 			tileblock[_t(x1, y1)] = ni
1856: 	elif bi2 - bi1 == 2:
1857: 		var ni2 := _tb_pick(best, int((bi1 + bi2) / 2), brng)
1858: 		if ni2 >= 0:
1859: 			tileblock[_t(x2, y2)] = ni2
1860: 	elif bi1 < bi2:
1861: 		var ni3 := _tb_pick(best, bi1 + 1, brng)
1862: 		if ni3 >= 0:
1863: 			tileblock[_t(x2, y2)] = ni3
1864: 	else:
1865: 		var ni4 := _tb_pick(best, bi2 + 1, brng)
1866: 		if ni4 >= 0:
1867: 			tileblock[_t(x1, y1)] = ni4
1868:
1869: func _smooth_tilemap(brng: RandomNumberGenerator, passes: int = 3) -> void:
1870: 	for _pass in passes:
1871: 		for y in MAP_H:
1872: 			for x in range(0, MAP_W - 1):
1873: 				_tb_smooth_pair(x, y, x + 1, y, brng)
1874: 		for x in MAP_W:
1875: 			for y in range(0, MAP_H - 1):
1876: 				_tb_smooth_pair(x, y, x, y + 1, brng)
```

The order call site, `_assign_tileblocks()` **:1679-1698**:

```
1679: 	# 2) oriented shores + cliffs (donor texturemap.inc 8-sector tables)
1680: 	_apply_shore_cliffs()
1681: 	# 3) exact 3-pass SmoothTileMap (donor smoothtiles.inc)
1682: 	_smooth_tilemap(brng, 3)
1683: 	# 4) donor detail variety (loadtextureterrainfrombitmap.inc): cells still
1684: 	# on the default block get their TileBlock from the low/high-ground
1685: 	# bitmaps (R div 2), picked by height.  This is the real meadow mottling.
1686: 	# Single pass, exactly like the original (SmoothTiles ran BEFORE it, the
1687: 	# bitmaps are authored to agree with their neighbours, so no second
1688: 	# smooth/detail round that would quilt contrasting samples together).
1689: 	_apply_detail_pass()
1690: 	# 5) forest-border stamps (donor smoothforestborders.inc: grass5/rock9
1691: 	# tiles + bushes at edge cells with exactly one forest neighbour)
1692: 	_stamp_forest_borders(brng)
1693: 	# T2GEN P0-1: final authority - real mine worked ground, after every
1694: 	# smoothing/detail/border pass that could otherwise reintroduce a test*
1695: 	# transition tile inside the apron.
1696: 	for mi in mine_mask.size():
1697: 		if mine_mask[mi] != 0:
1698: 			tileblock[mi] = _blk("ground1")
```

Rule table source, `_load_terrain_structs()` **:1409-1419**:

```
1409: func _load_terrain_structs() -> void:
1410: 	if not tbl_names.is_empty():
1411: 		return
1412: 	var a1 = JSON.parse_string(FileAccess.get_file_as_string("res://assets/terrain/structs/presets_summer.json"))
1413: 	if a1 is Array:
1414: 		tbl_names = a1
1415: 	for i in tbl_names.size():
1416: 		tbl_idx[str(tbl_names[i])] = i
1417: 	var a2 = JSON.parse_string(FileAccess.get_file_as_string("res://assets/terrain/structs/smooth_summer.json"))
1418: 	if a2 is Array:
1419: 		tbl_smooth = a2
```

### 3.2 Corresponding `variant3d/scripts/game.gd` lines (exact differences highlighted)

Detail pass **:1959-2010** (only the divergent tail is quoted in full):

```
1981: 			var tex: int = int(im.get_pixel(sx, sy).r * 255.0) / 2
1982: 			# B03-P1 (PORT APPROXIMATION, A04 §6 P1): the donor writes its two
1983: 			# transition ids verbatim from the bitmap, which paints ~15% of the
1984: 			# map one dark atlas cell. Re-roll ONLY those two through the donor
1985: 			# lists that already contain them (RV-TRN-02 §7: Item 2 J=5
1986: 			# test7/grass8/test6 cfg:267; Item 1 J=4 grass1/grass2/test8 cfg:155)
1987: 			# using the port's existing weighted picker. No new id, no mask edit,
1988: 			# no synthetic dither/noise field (charter S-25-09).
1989: 			if tex == _blk("test7"):
1990: 				var pick7 := _tb_pick(2, 5, brng)
1991: 				if pick7 >= 0:
1992: 					tex = pick7
1993: 			elif tex == _blk("test8"):
1994: 				var pick8 := _tb_pick(1, 4, brng)
1995: 				if pick8 >= 0:
1996: 					tex = pick8
1997: 			# Y03 (PORT APPROXIMATION, diagnostic baseline — A08 §1.2, Y01b §8):
...
2008: 			tex = _blk("test8")
2009: 			if tex >= 0 and tex < tbl_names.size():
2010: 				tileblock[i] = tex
```

Order **:2090-2097** and **:2131-2134**:

```
2090: 	# 2) oriented shores + cliffs (donor texturemap.inc 8-sector tables)
2091: 	_apply_shore_cliffs()
2092: 	# 3) donor detail variety (loadtextureterrainfrombitmap.inc): cells still
2093: 	# on the default block get their TileBlock from the low/high-ground
2094: 	# bitmaps (R div 2), picked by height.  Donor order is TextureMap ->
2095: 	# bitmap base -> SmoothTiles (DTRN-01 §4 / RV-TRN-02 §4.4), so the
2096: 	# detail tiles are reconciled too instead of being left as final cells.
2097: 	_apply_detail_pass(brng)
...
2131: 	# 4) exact 3-pass SmoothTileMap (donor smoothtiles.inc:191-237): three
2132: 	# passes, horizontal then vertical, over the FINAL tile field before UV2.
2133: 	# TRN-DATA: the donor rule table now covers all 118 active lists.
2134: 	_smooth_tilemap(brng, 3)
```

`_tb_pick` redirect **:2266-2282** and smooth guards **:2331-2346**:

```
2266: 		if p > 0.0 and r < acc:
2267: 			var nm := str(td.get("name", ""))
2268: 			# B03-P3 (PORT APPROXIMATION, A03 §2/§4): the donor lists that emit
...
2275: 			# substitution, not donor parity (UNVERIFIED).
2276: 			if nm == "grass_ground1":
2277: 				return _blk("grass9")
2278: 			if nm == "grass_ground2":
2279: 				return _blk("test8")
2280: 			if nm == "grass_ground3":
2281: 				return _blk("test7")
2282: 			return _blk(nm)
...
2333: 		if ni >= 0 and int(tileblock[_t(x1, y1)]) != _blk("test8") and int(tileblock[_t(x1, y1)]) != _blk("grass9"):
2337: 		if ni2 >= 0 and int(tileblock[_t(x2, y2)]) != _blk("test8") and int(tileblock[_t(x2, y2)]) != _blk("grass9"):
2341: 		if ni3 >= 0 and int(tileblock[_t(x2, y2)]) != _blk("test8") and int(tileblock[_t(x2, y2)]) != _blk("grass9"):
2345: 		if ni4 >= 0 and int(tileblock[_t(x1, y1)]) != _blk("test8") and int(tileblock[_t(x1, y1)]) != _blk("grass9"):
```

Y08/Y08b flatten **:2144-2161** (abridged with exact boundary lines):

```
2144: 	# Y08 (PORT APPROXIMATION): FINAL AUTHORITY. Collapse every ordinary land
2145: 	# cell to ONE clean donor id (test8 idx 79; A03 §4 isotropic/seamless, alpha
...
2151: 	var meadow_id := _blk("test8")
2152: 	for i in tileblock.size():
2153: 		if int(tileblock[i]) == BLK_WATER:   # 255, game.gd:52
2154: 			continue
2155: 		if mine_mask[i] != 0:                # Y08b: VISIBLE id only; mask/terrain untouched
2156: 			tileblock[i] = meadow_id
2157: 			continue
2158: 		var role: int = int(terrain[i])
2159: 		if role == 1 or role == 3 or role == 4 or role == 5:
2160: 			continue  # road / water / shore-sand / rock-cliff
2161: 		tileblock[i] = meadow_id
```

Mine/start aprons: 2D `_finalize_mine_tiles()` **:327-343** uses `_blk("ground1")`
(`:327`, written `:330`) and `_blk("grass1")` (`:333`, written `:343`);
3D **:382** `var g1 := _blk("test8")  # Y08b PORT APPROX...`, **:388**
`var g0 := _blk("test8")  # Y08 PORT APPROX...`, written at `:385` and `:398`.

---

## 4. Differences table — donor-grounded vs port invention

| # | Aspect | 2D `app/scripts/game.gd` (current) | 3D `variant3d/scripts/game.gd` (current) | Classification / evidence |
|---|---|---|---|---|
| D1 | **Pass order** | smooth `:1682` → detail `:1689` | detail `:2097` → smooth `:2134` | **Donor-grounded difference [O] text / [U] runtime.** `generatemap.inc:776` → `:786` → `:795` (H06:36-39,52-56); 3D's own justification `:2094-2096` is the contradicted reconstruction (`H06:71-80`). |
| D2 | **Detail `tex` source** | `tex = R div 2` written verbatim `:1603,1605` | same `tex` at `:1981`, then B03-P1 re-roll `:1989-1996`, Y03 `test8` `:2008` | **Donor-grounded base [O]; 3D additions are PORT APPROXIMATION** (`loadtextureterrainfrombitmap.inc:33-41` via H06:60 / RV_TRN_02:557-565; labels at 3D `:1982-1988,1997-2007`). |
| D3 | **Detail eligibility** | only `grass1`/index-0 cells `:1587,1595` | identical `:1965,1973` | **Shared donor-grounded** (`loadtextureterrainfrombitmap.inc:37-41`). Not a difference. |
| D4 | **Pick return** | authored name `_blk(str(td.get("name","")))` `:1803` | `grass_ground1/2/3 → grass9/test8/test7` `:2276-2281` | **Port invention** B03-P3, self-labelled PORT APPROXIMATION `:2268-2275`. Donor names are verbatim in `tilesmooth_scripts.cfg` (F03 §6.4). **[D]** redirect does not change RNG draw count (one `brng.randf()` at `:2261` in both). |
| D5 | **Smooth Δ rules** | Δ=1 guard `:1850`; Δ=2 midpoint `:1852-1859`; Δ>2 pull `:1860-1867` | identical rules at `:2329-2346` but four `test8/grass9` write guards `:2333,2337,2341,2345` | **Donor-grounded rules [O] text; guards are port invention** (`smoothtiles.inc:142-180` via RV_TRN_02:400-412 / F03:566-568). |
| D6 | **Rule table** | `smooth_summer.json`, 10 chains `:1417-1419` | embedded `DONOR_SMOOTH_RULES`, 118 active lists (Summer+Winter), e.g. `:1682`, `:1787` | **Both donor-derived**; 3D more complete (F03 F6/F7, RV_TRN_02 §7). **[D]** transplant 3D *data*, 2D *application semantics* (P05 E16/R4). |
| D7 | **Mine apron id** | `ground1` `:327,330,1676-1677,1696-1698` | `test8` `:382,385,2141-2143` + Y08b `:2155-2156` | **2D donor-grounded** (`texturemap.inc:627-636` roads/worked ground via F05:113; F05:146 `ground1`=id 10); **3D port invention** labelled PORT APPROXIMATION `:382,2144`. |
| D8 | **Start plaza id** | `grass1` `:333,343` (2D) / `_blk("grass1")` base `:1635` | `test8` `:388,398`, whole-disc flatten | **2D donor-grounded** (F05:56 donor preset id 0 = `grass1`; `tiles.season:2-3` F05:107); **3D port invention** labelled `:388,2144`. |
| D9 | **Extra passes between detail and smooth** | none (`:1680`→`:1682`→`:1689`) | B03-P2 `tiles`→`ground1` stamps `:2098-2121`; L01 `_stamp_grass_spots(brng)` `:2130` | **Port inventions**, both self-labelled PORT APPROXIMATION `:2098,2122`; no 2D counterpart (H06:158-159). |
| D10 | **Forest role-2 family** | `grass_ground1/2/3` at `0.64/0.0028/0.36` `:1649-1655` | `DONOR_FOREST_BASE` `grass7/test12/13/14` ×0.25 `:2055-2066` | **Both donor-authored lists; mapping [U]** (RV_TRN_02:213/222/230, `:194`; P05 U3/Q3). Not a "verbatim vs invented" case — do not decide by adjacency. |
| D11 | **Height-cap dither** | `_noise2` cap `:1090-1097` (`:1095-1096`) | same field `:1267-1274` (`:1272-1273`) | **Shared forbidden invention** — CHARTER.md:60 / S-25-09. **Not a 2D-only difference** (correction to P05 E23/§3.10). |
| D12 | **Hill rock paint / steep paint** | `terrain=5` `:792`, `:1121` | hill branch `pass` `:853-861`; collision only `:1297-1310` | **Donor-literal rule** (`texturemap.inc:63-64` cDiff1/cDiff2 per spec 10:56), but port application caused the maze. **[U]/PORT APPROXIMATION**; conditional only (P05 T7). |
| D13 | **Final authority** | mine `ground1` write-back after detail/borders `:1693-1698` | whole-disc `test8` flatten `:2144-2161` after all passes | **2D keeps donor apron semantics**; 3D flatten is PORT APPROXIMATION. **[D]** mine apron must survive smoothing by copying 2D's final-authority placement, not the flatten. |

---

## 5. Transplant recipe — fresh `terrain_donor_*` module (no 2D file touched)

> All steps target **new** `variant3d/scripts/terrain_donor_*.gd` files
> (`CHARTER.md:57-61`). `app/**` and legacy `variant3d/scripts/game.gd`,
> `world3d_terrain.gd` and the tile-index shader are **not edited**. COORD owns the
> `world3d.gd` switch (`P01:71-78`). No Godot job is submitted by V09.

1. **Create `variant3d/scripts/terrain_donor_tiles.gd`** exposing a single
   `assign_tileblocks(brng)` plus helpers. Seed exactly as 2D/3D:
   `brng.seed = int(Data.RANDOM_SEED) + 7` (`app:1622-1623` = `variant3d:2027-2028`)
   **[O]**. Keep a per-stage RNG account in the QA harness: reordering changes which
   draw lands on which decision (H06 §4.2; P05 R1). **[D]**
2. **Stage order — transplant D1 verbatim:** base fill → shore/cliff → **3-pass
   smooth** → **detail** → forest borders → mine-apron final authority
   (`app:1679-1698`). Do **not** insert B03-P2 (`:2098-2121`) or L01 (`:2130`);
   both are labelled PORT APPROXIMATION and have no 2D/donor call-site anchor.
   **[O]/[D]**
3. **Detail pass — transplant `_apply_detail_pass()` verbatim** (`app:1581-1605`,
   signature without `brng`): load `res://assets/terrain/structs/tile_lowground.png`
   and `tile_highground.png` via `_load_image_tex` (`app:1562-1569,1571-1579`);
   eligibility `int(tileblock[i]) != grass0` (`:1595`); `h < 0.1`; `tex = R div 2`
   (`:1603`); write `tex` (`:1605`). **No** B03-P1 re-roll, **no** Y03 `test8`
   collapse. **[O] base / PORT APPROXIMATION for the result until A/B.**
4. **Smooth pass — reuse 3D's DATA, apply 2D's RULES.** Copy the full 118-rule
   `DONOR_SMOOTH_RULES` table (Summer + Winter, `_winter` alias normalisation) from
   `variant3d/scripts/game.gd:1604-1767,1780-1820` into the new module; do **not**
   copy `smooth_summer.json`'s smaller 10-chain subset (`app:1417-1419`) as the
   authority (P05 E16/R4). Implement `_tb_pick` as `app:1787-1804` (return authored
   `name`, no redirect at 3D `:2276-2281`) and `_tb_smooth_pair` as `app:1806-1867`
   (Δ guard `:1850`, Δ=2 `:1852-1859`, Δ>2 `:1860-1867`, **no** `test8/grass9`
   guards at 3D `:2333/2337/2341/2345`). Run 3 passes, horizontal then vertical,
   as `app:1869-1876` = `smoothtiles.inc:191-237`. Preserve `Prob=0` hard
   separators, the highest-J duplicate rule, and the `grass_ground`
   `SumProb=1.0028` anomaly verbatim (RV_TRN_02 §3.5/§6 #7; F03 F8:808). **[O]/[D]**
   - Keep the shared `mine_mask` protection guard (`app:1809-1810` =
     `variant3d:2288-2289`) as a **labelled PORT APPROXIMATION** (it is not in the
     donor script); it exists in both trees and is not a differentiator. **[O]**
5. **Aprons — transplant `ground1`/`grass1` semantics:** base mine apron
   `_blk("ground1")` (`app:1676-1677`), final authority after detail/borders
   (`app:1693-1698`), start clearing `grass1` (`app:333-343`) and
   `_finalize_mine_tiles()` (`app:317-330`). Do **not** reproduce the 3D Y08/Y08b
   whole-disc `test8` flatten (`variant3d:2144-2161`, `:382,388,398`). Donor anchors:
   `ground1` = id 10 / worked dirt (`texturemap.inc:627-636` via F05:113,146);
   `grass1` = preset id 0 (F05:56,107). **[O]/[D]**
6. **Reuse unchanged donor-derived code, do not copy art:** shore 8-sector and
   cliff aspect + height overrides (`app:1708-1785`, byte-identical in 3D; donor
   `texturemap.inc:433-511,557-611` via F05:113 / RV_TRN_02 §5), water cells keep
   `terrain=3` + `BLK_WATER` (`app:1067-1075`), winter alias table
   (`app:1424-1476`). Reference hardlinked `res://` paths read-only; **never write
   through a hardlinked path** (P05 R6/U11; E22). **[O]**
7. **Omit all forbidden/substituted fields:** no `_noise2` dither (step 8 below),
   no `terrain=5` rock paint on port heights, no synthetic spot/stamp passes, no
   donor binary or new asset. **[O]/[D]**
8. **QA gates (COORD-owned):** same seed + camera + zoom + BIOME pinned; compare
   `tileblock` histogram and a fresh capture against the legacy tree one axis at a
   time (pass order vs detail verbatimness vs apron id — P05 Q8). Required gates:
   selftest 29/29, uitest 17/17, `t_render_mode`, `assert_clean` CLEAN,
   `app/` byte-identical (`CHARTER.md:64`; P03). **No donor parity verdict** without
   a real donor GPU A/B frame (`CHARTER.md:41,125`). **[U]**

---

## 6. Do-not-transplant list

| # | Item | Exact location | Why not | Label |
|---|---|---|---|---|
| N1 | Height-cap `_noise2` dither | `app/scripts/game.gd:1090-1097` (statements `:1095-1096`); **also** `variant3d/scripts/game.gd:1267-1274` (`:1272-1273`) | Synthetic noise field explicitly forbidden by `CHARTER.md:60` / S-25-09. Correction to P05 E23: it exists in both trees, so the fresh module must **actively omit** it. | [O] / forbidden |
| N2 | Hill-stamp `terrain=5` paint | `app/scripts/game.gd:786-792` (statement `:792`); 3D is `pass` at `:853-861` | Donor-literal rock rule, but port application produced the concentric maze. Only P05 T7 conditional (real donor height grids + COORD/owner grant + A/B); **never** verbatim. | [O]/[U]/PORT APPROXIMATION |
| N3 | Steep-cell `terrain=5` paint | `app/scripts/game.gd:1098-1122` (statement `:1121`); 3D collision-only `:1297-1310` | Same cDiff1/cDiff2 donor rule (spec 10:56); the |dh| test on port 8-bit terraces fired outside stamp masks and created grey rings. | [O]/[I]/PORT APPROXIMATION |
| N4 | 2D forest-floor family choice | `app/scripts/game.gd:1649-1655` vs `variant3d:2055-2066` | Both donor-authored lists; mapping to terrain role 2 unresolved (P05 U3/Q3). Do not decide by adjacency. | [U] |
| N5 | 2D analytic relief domes | `app/scripts/game.gd:858-982` | Explicit port adaptation; 3D donor-grid path supersedes (P05 E07/§3.10). | [O]/PORT APPROXIMATION |
| N6 | Any asset copy / hardlink write | P05 E22/R6/U11 | 685 assets already inode-identical; writing through either tree mutates `app/`. | [O]/[D] |
| N7 | 3D-only substitutions | `variant3d:1989-1996,2008,2098-2121,2130,2276-2281,2333/2337/2341/2345,2144-2161` | All self-labelled PORT APPROXIMATION; none donor-grounded. Do not carry them into the fresh module by copying the 3D file wholesale. | [O]/PORT APPROXIMATION |
| N8 | `terrain=5` on road/sand cells | shared steep test skips `terrain==3 or 4` (`app:1104-1105`, `variant3d:1281-1282`) | Preserve the skip if a donor-grid rock rule is later approved; shore collar must keep sand art and stay walkable. | [O] |

---

## 7. Risks

| # | Risk | Evidence / label | Mitigation |
|---|---|---|---|
| R1 | Reordering smooth/detail changes which decision consumes which `brng` draw; `tileblock` bytes change though same-seed determinism holds by construction. | H06 §4.2 `:149-153`; P05 R1; [D] / [U] without run | Pin seed/camera/zoom/BIOME; A/B one axis; compare histogram + capture. |
| R2 | Removing Y03(test8)/Y08 flatten may expose the Y08 checkerboard or flat field instead of donor mottling. | 3D `:1997-2008,2144-2161`; P05 R2/U4; [I]/[U] | No assumed improvement; A/B decides; COORD rollback. |
| R3 | Restoring `terrain=5` on port terraces recreates the concentric maze. | `app:792,1121`; `variant3d:853-861,1297-1310`; P01:55-60; [O]/[I] | N2/N3 conditional only; donor-grid height + grant. |
| R4 | Using 2D's 10-chain `smooth_summer.json` loses Winter and 108 of the 118 active donor lists. | `app:1417-1419`; F03 F6/F7:806-807; P05 R4; [O]/[D] | Recipe step 4: 3D table data + 2D application semantics. |
| R5 | Donor order is authored, `;`-commented text; shipped runtime activity unknown. | RV_TRN_02:468-478; F03 F15:815; H06 §1.2; [U] | Keep "donor-faithful" narrow = call order + rule text only. |
| R6 | `grass1 = test10 = test11` are byte-identical art; verbatim detail ids may look visually flat even when citation-faithful. | F05:116,371,217-218; [O]/[I] | Do not equate id variety with visible variety; A/B only. |
| R7 | `ground1` mine apron can be rewritten by smoothing unless final authority is placed last. | `app:1809-1810` guard + `:1693-1698`; 3D Y08b `:2155-2156`; [D] | Recipe step 5 copies 2D's final-authority position. |
| R8 | `SumProb=1.0028`, Prob=0 separators and highest-J duplicate rule are easy to "fix" accidentally. | RV_TRN_02 §3.5/§6 #7/§8 #8; F03 F8:808; [O]/[D] | Preserve literal values; add a table-equality assert in QA. |
| R9 | Forest-family choice is unresolved; picking 2D's list may be wrong for role 2. | P05 U3/Q3; RV_TRN_02 `:194,213,222,230`; [U] | Leave as an explicitly flagged switch; no silent choice. |
| R10 | Hardlink writes mutate `app/` silently; `.import`/`.uid` are per-project. | P05 E22/R6/R7/U11; [O]/[D] | Read-only `res://` loads; no re-import; `app/` byte check at gate. |
| R11 | No donor GPU A/B exists; any "closer" wording can be over-read as parity. | CHARTER.md:41,44,125; [U] | Every output labelled PORT APPROXIMATION; no % verdict. |

---

## 8. UNVERIFIED register

| ID | Claim | Why UNVERIFIED | Needed |
|---|---|---|---|
| V-U1 | Donor generator executes `TextureMap → SmoothTiles → LoadTextureTerrainFromBitmap` as authored at `generatemap.inc:776/786/795` | All donor code lines `;`-commented (RV_TRN_02:468-478; H06 §1.2) | D-wave binary/Ghidra anchor |
| V-U2 | 2D order + verbatim detail after smoothing reproduces donor mottling | No A/B; Y08 flatten removal may reintroduce checkerboard (P05 U4) | Fresh-module capture + `tileblock` histogram |
| V-U3 | Same-seed determinism survives the reorder | True by construction, but unrun (H06:153) | Seeded replay gate |
| V-U4 | Forest interior family = 2D `grass_ground1/2/3` (`:1649-1655`) vs 3D `grass7/test12/13/14` (`:2055-2066`) | Both donor-authored; role-2 mapping uncited (P05 U3) | F08/D07 family mapping + capture |
| V-U5 | `terrain=5` rock paint is correct on real donor height grids | Donor rule literal; port terraces caused maze (P05 U5) | Donor-grid A/B + owner grant |
| V-U6 | `ground1`/`grass1` apron survives the smooth/detail passes without a special guard | Guard present in both trees is a port addition (`app:1809-1810`) | Fresh-module seed dump |
| V-U7 | `smooth_summer.json` 10 chains suffice for the skirmish path | Donor has 22 chains / 118 active lists (F03 F6) | P05 Q1 resolution; use 3D table |
| V-U8 | Hardlinks stay valid after git checkout / CI clone | Local filesystem property, not recorded by git (P05 U11) | Re-run census after checkout |
| V-U9 | Season swap executes on the 3D frame | `G22:126`; P05 U6 | Render-mode trace |
| V-U10 | Any donor parity for either tree | No donor GPU A/B frame (CHARTER.md:41,125) | Charter-defined capture |

---

## 9. Open questions

- **Q1** — Use the full 118-rule 3D table with 2D's verbatim application, or the
  2D 10-chain `smooth_summer.json` subset? Evidence: `app:1417-1419`; F03 F6/F7;
  P05 Q1; V-U7.
- **Q2** — Does verbatim detail-after-smooth restore donor mottling or the Y08
  checkerboard? Evidence: `app:1682/1689` vs `variant3d:2008,2144-2161`; P05 Q2; V-U2.
- **Q3** — Which family is authoritative for forest-interior ids? Evidence:
  `app:1649-1655` vs `variant3d:2055-2066`; RV_TRN_02:194,213,222,230; P05 Q3; V-U4.
- **Q4** — Can a donor-grid height path carry `terrain=5` without the concentric
  rings? Evidence: `app:792,1121`; `variant3d:853-861,1297-1310`; P05 Q4; V-U5.
- **Q5** — Can one A/B isolate pass order (D1) from detail verbatimness (D2) and
  the apron/flatten id (D7/D8)? All three change the same `tileblock` bytes.
  Evidence: P05 Q8; R1/R2.
- **Q6** — Does the donor `SmoothTerrain` native kernel exist and does it consume
  the `bsmooth` flag exposed at `variant3d/scripts/mapgen.gd:43-50`? Evidence:
  P05 U7; spec 10 cross-check queue.
- **Q7** — Should the fresh module keep the shared `mine_mask` smooth guard
  (`app:1809-1810` = `variant3d:2288-2289`), labelled PORT APPROXIMATION, or drop
  it for literal donor rules? Evidence: §5 step 4; V-U6.
- **Q8** — Given `grass1=test10=test11` byte-identical art (F05:116), what
  observable metric can distinguish verbatim detail ids from the `test8` flatten?
  Evidence: F05:217-218,371; R6.

---

## 10. Guardrails and hand-off

- **Read-only this pass:** exactly one repo file written (this report). No `app/**`
  or `variant3d/**` edit, no donor file opened, no Godot process, no runner job,
  no source/shader/config/asset/test/git mutation.
- **No parity claim.** Donor-faithful = agreement with cited authored donor text;
  "closer" = absence of a self-labelled PORT APPROXIMATION. All fresh-module output
  stays **PORT APPROXIMATION** until a real donor GPU A/B frame exists.
- **No gate weakening, no synthetic noise/dither, no donor binaries**
  (`CHARTER.md:60,66-69`).
- COORD owns integration at `world3d.gd`; V09 proposes only.

### Hand-off summary (5 lines)

1. Verified in 3 passes: 2D detail `_apply_detail_pass()` is `app/scripts/game.gd:1581-1605`; smooth is `_tb_pick():1787-1804`, `_tb_smooth_pair():1806-1867`, `_smooth_tilemap():1869-1876`; order is smooth `:1682` → detail `:1689`.
2. 3D counterparts are `variant3d/scripts/game.gd:1959-2010` (B03-P1 `:1989-1996`, Y03 `:2008`), detail `:2097` → smooth `:2134` (flipped), `_tb_pick():2251-2283` (P3 redirect `:2276-2281`), guards `:2333/2337/2341/2345`, Y08 flatten `:2144-2161`; H06's older 3D numbers are stale and P05's govern.
3. Donor-grounded: order (`generatemap.inc:776/786/795`), detail rule (`loadtextureterrainfrombitmap.inc:33-41`), Δ rules (`smoothtiles.inc:142-180`), `ground1`/`grass1` ids (`texturemap.inc:627-636`; F05:56,113,146) — all authored text only, runtime [U].
4. Port inventions: B03-P1/P2/P3, Y03, four art guards, L01 spots, Y08/Y08b `test8` flatten — all self-labelled PORT APPROXIMATION; recipe keeps 2D rules/order but 3D's 118-rule data table in a fresh `terrain_donor_*.gd`.
5. Do NOT transplant the `_noise2` cap dither (in **both** trees: `app:1090-1097`, `variant3d:1267-1274`) or the `terrain=5` hill/steep paint (`app:792,1121`) verbatim; no parity claim.

*End of V09 report. Read-only; one report file; `app/**` and `variant3d/**` byte-untouched; no runner job; no donor parity claim.*
