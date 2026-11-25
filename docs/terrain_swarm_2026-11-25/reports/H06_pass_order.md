---
id: H06
ticket: "HEIGHTMAP WAVE follow-up — H06: donor pass order (detail-bitmap tile-id selection vs 3-pass SmoothTileMap) and 2D/3D order"
wave: "WAVE H follow-up (HEIGHTMAP WAVE)"
owner: "H06 (read-only)"
created: 2026-11-25
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_RUNNER_JOB__NO_CODE_OR_ASSET_EDIT__NO_PARITY_CLAIM
charter: docs/terrain_swarm_2026-11-25/CHARTER.md
board: docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
scope: "This report is the ONLY repo file written. Donor files under C:\\Games\\Cossacks 3\\data\\scripts read READ-ONLY (no copy/execute/render). No Godot process, no runner job, no source/asset/config/test/shader/JSON/git edit."
labels: [OBSERVED, DERIVED, UNVERIFIED, "PORT APPROXIMATION"]
parity_guard: "DONOR PARITY STAYS UNVERIFIED (CHARTER.md:55-58,122-131; A08_donor_truth_local.md:274). No donor GPU A/B frame exists. 'Donor-faithful' below means agreement with the authored donor call-site ORDER only, never verified runtime equivalence or visual parity."
sources_read:
  - docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
  - docs/terrain_swarm_2026-11-25/CHARTER.md
  - docs/terrain_swarm_2026-11-25/reports/G22_2d_vs_3d.md
  - docs/terrain_swarm_2026-11-25/reports/A08_donor_truth_local.md
  - docs/terrain_swarm_2026-11-25/reports/B03_diversity_impl.md
  - docs/TERRAIN_GEN_RESEARCH.md
  - docs/coord_swarm_2026-11-25/reports/DTRN_01_donor_terrain_pipeline.md
  - docs/coord_swarm_2026-11-25/reports/RV_TRN_02_smoothing_rules.md
  - "C:\\Games\\Cossacks 3\\data\\scripts\\common.inc\\generatemap.inc"
  - "C:\\Games\\Cossacks 3\\data\\scripts\\common.inc\\dogenerate.inc"
  - "C:\\Games\\Cossacks 3\\data\\scripts\\common.inc\\texturemap.inc"
  - "C:\\Games\\Cossacks 3\\data\\scripts\\common.inc\\smoothtiles.inc"
  - "C:\\Games\\Cossacks 3\\data\\scripts\\common.inc\\loadtextureterrainfrombitmap.inc"
  - variant3d/scripts/game.gd
  - app/scripts/game.gd
  - variant3d/tests/t_map_variety.gd
---

# H06 — Donor pass order vs 2D/3D `_assign_tileblocks()`

## 0. Verdict (labelled)

- **(a) OBSERVED (donor call sites):** the authored donor generator runs **TextureMap → SmoothTiles (3 passes) → LoadTextureTerrainFromBitmap (detail-bitmap tile-id selection)**. The detail-bitmap pass therefore runs **after** smoothing and its ids are **not** smoothed afterwards. Evidence: `generatemap.inc:770-779`, `:781-789`, `:791-798`; gates all `True` at `generatemap.inc:42-44`.
- **(b) OBSERVED (code):** current 3D order after B03 is base fill → shore/cliffs → **detail pass** → B03 `tiles`→`ground1` stamps → **3-pass smooth** → forest borders. `variant3d/scripts/game.gd:1957,1971-2033,2034-2039,2040-2063,2064-2067,2068-2070`.
- **(c) OBSERVED (code):** 2D order is base fill → shore/cliffs → **3-pass smooth** → **detail pass** → forest borders. `app/scripts/game.gd:1610,1624-1680,1681-1682,1683-1689,1690-1692`.
- **(d) DERIVED:** the 2D order agrees with the donor *call-site* order; the 3D order is flipped. Flipping 3D would be donor-faithful **only in the narrow sense of call order** — it is **not cosmetic** (it changes `tileblock` bytes and the shared RNG stream), and it is **not sufficient** for donor fidelity because of B03's PORT APPROXIMATION substitutions and other structural differences. **UNVERIFIED:** that any flip improves visuals or gates; no runner/capture/donor GPU A/B was produced by this ticket.

**G22 context, not re-litigated:** G22's order statement was OBSERVED from code and its donor-correctness was left UNVERIFIED (`G22_2d_vs_3d.md:125`). This ticket resolves that specific UNVERIFIED using donor call sites, with the standing caveat that all donor code lines are `;`-commented (see §1.2). No parity, equivalence or "closer by N%" claim is made here.

---

## 1. (a) Exact donor sequence — call sites in `GenerateMap`

### 1.1 The three gated blocks, in file order

| # | Order in file | Evidence (donor `path:line`) | Label |
|---:|---|---|---|
| 1 | Parent state reaches `GenerateMap` | `dogenerate.inc:1565` `ExecuteState('GenerateMap')`; `generatemap.inc:2` `Name = GenerateMap` | OBSERVED |
| 2 | `TextureMap` per-cell id assignment (height/aspect/shore/rock/roads) | `generatemap.inc:770-779`, call at `:776` `ExecuteState('TextureMap')`; gate `cTextureTerrain = True` at `:42`; target section `texturemap.inc:2` `Name = TextureMap` | OBSERVED |
| 3 | `SmoothTiles` → **3-pass `SmoothTileMap`** | `generatemap.inc:781-789`, call at `:786` `ExecuteState('SmoothTiles')`; gate `cSmoothTile = True` at `:43`; procedure `smoothtiles.inc:191-235`; invocation `smoothtiles.inc:237` `SmoothTileMap(0, 0, GetMapWidth, GetMapHeight, 3)` | OBSERVED |
| 4 | `LoadTextureTerrainFromBitmap` — **detail-bitmap tile-id selection** | `generatemap.inc:791-798`, call at `:795`; gate `cLoadTextureFromBitmap = True` at `:44`; target `loadtextureterrainfrombitmap.inc:1-2` (`Name = LoadTextureTerrainFromBitmap`) | OBSERVED |

**Exact sequence (OBSERVED):** `TextureMap` (`generatemap.inc:776`) → `SmoothTiles` / 3-pass `SmoothTileMap` (`generatemap.inc:786`; `smoothtiles.inc:237`) → `LoadTextureTerrainFromBitmap` (`generatemap.inc:795`). No other `ExecuteState('SmoothTiles')` or `ExecuteState('LoadTextureTerrainFromBitmap')` call site exists in the readable donor `common.inc` tree (**OBSERVED**, full-file search of `C:\Games\Cossacks 3\data\scripts`). The commented `MapGeneratorSmoothTiles` at `generatemap.inc:784` is not a call site; `RV_TRN_02_smoothing_rules.md:452-466` records it as a commented line and derives that the skirmish call site is `:781-789`.

**Inside the smooth stage (OBSERVED):** each of the 3 passes (`smoothtiles.inc:197-234`) does a horizontal sweep `:200-215` then a vertical sweep `:218-233`, rewriting `atilemap` in place; final write-back to `SetTileIndex` at `:240-242`.

**Inside the detail stage (OBSERVED):** `cLowHeight = 0.1` at `loadtextureterrainfrombitmap.inc:4`; low/high bitmaps loaded at `:8-9`; height chooses bitmap at `:25-29`; `r = floor(fr*255)` and `tex = r div 2` at `:33-36`; assignment **only where the cell is still tile index 0** at `:37-41` (`if (GetTileIndex(x,y)=0) ... SetTileIndex(x,y,tex)`).

**DERIVED consequence:** donor detail ids (the `grass1/test7/8/9/12/14` family listed in `A08_donor_truth_local.md:66-67`) are written after the compatibility rewrite, so they are final values, not smoothing inputs. If the order were reversed, those ids would instead be eligible for rewriting by `_tb_smooth_pair`-equivalent logic.

### 1.2 Activity caveat and internal cross-checks

- **UNVERIFIED:** whether any of these commented scripts executes in the shipped build. Every executable line in these donor files is stored as `[*] = ;<code>` (e.g. `smoothtiles.inc:4-6,191-237`, `loadtextureterrainfrombitmap.inc:4-41`, `generatemap.inc:770-798`). This is already registered at `A08_donor_truth_local.md:271`, `DTRN_01_donor_terrain_pipeline.md:510-512`, `RV_TRN_02_smoothing_rules.md:468-478`. The order above is therefore **authored donor intent as text**, not proven runtime behaviour.
- **OBSERVED:** `texturemap.inc` contains no `SmoothTileMap`/`LoadTextureTerrainFromBitmap` call; its only `ExecuteState` is `SmoothForestBorders` at `texturemap.inc:360`. So the relative order of the two passes is set by `generatemap.inc`, not inside `texturemap.inc`.
- **OBSERVED:** `dogenerate.inc` is itself entirely `;`-commented (`dogenerate.inc:1-3` etc.); its role here is only to show the parent call at `:1565`.
- **UNVERIFIED:** `docs/TERRAIN_GEN_RESEARCH.md:58` says "Finalize — smooth forest borders, `postprocess.inc`, roads, balance" and does not specify detail-vs-smooth order; it is not evidence for either ordering.

### 1.3 Existing repo docs that disagree with the call sites (important)

| Source claim | Label | Assessment |
|---|---|---|
| `DTRN_01_donor_terrain_pipeline.md:224-230` pseudocode puts the bitmap base fill **before** "neighbour compatibility, 3 passes" (`:230`) | DERIVED reconstruction of donor text | Contradicted by the literal call sites `generatemap.inc:786` vs `:795`. |
| `DTRN_01_donor_terrain_pipeline.md:525-527` summary: "…and a bitmap base …, **then** resolves seams with 3 passes…" | DERIVED summary | Same contradiction. |
| `A08_donor_truth_local.md:145-148` stage list L1 base → **L2 detail-bitmap variety → L3 3-pass smoothing**; checklist order `:234-236` items 2 then 4 | DERIVED/INFERRED stage numbering (A08 header `:18-24` declares consolidation, not new discovery) | Follows the DTRN reconstruction; the stage numbers are not taken from `generatemap.inc` call sites. **A08:271** does flag donor-script activity as UNVERIFIED. |
| `variant3d/scripts/game.gd:2036-2038` comment: "Donor order is TextureMap -> bitmap base -> SmoothTiles (DTRN-01 §4 / RV-TRN-02 §4.4), so the detail tiles are reconciled too…" | OBSERVED comment text; its order claim is **contradicted** by `generatemap.inc:781-795` | The cited `RV_TRN_02_smoothing_rules.md:461-463` actually quotes the `ExecuteState('SmoothTiles')` call site and does **not** assert bitmap-before-smooth. |

**Conclusion for (a), labelled:** OBSERVED call-site order = smooth first, detail second. The repo's "detail first, then smooth" narrative is DERIVED from a reconstruction (`DTRN_01:224-230`, propagated to `A08:145-148` and the 3D comment `variant3d/scripts/game.gd:2036-2038`) and does not match the generator's literal call sequence.

---

## 2. (b) Current 3D `_assign_tileblocks()` order (after B03)

All paths `variant3d/scripts/game.gd`; labels OBSERVED unless noted.

| Step | Line | Effect |
|---|---|---|
| Function entry | `:1957` | `func _assign_tileblocks()` |
| Seed / brng | `:1968-1970` | `brng.seed = int(Data.RANDOM_SEED) + 7` |
| 1) base blocks | `:1971-1982` | every land cell starts `grass1`; donor `SetTileIndex(x,y,0)` analogy at `:1972-1973` |
| Forest family draw | `:1997-2008` | `DONOR_FOREST_BASE` roulette (3D-specific) |
| Mine apron base | `:2026-2031` | `ground1` over mine mask |
| 2) shore/cliffs | `:2032-2033` | `_apply_shore_cliffs()` |
| **3) DETAIL pass** | `:2034-2039` | `_apply_detail_pass(brng)` at `:2039`; comment at `:2036-2038` makes the disputed order claim (see §1.3) |
| B03-P2 `tiles`→`ground1` stamps | `:2040-2063` | writes `ground1` on `kind=="tile"` stamp cells before smoothing; explicit **PORT APPROXIMATION** at `:2040-2050` |
| **4) SMOOTH pass** | `:2064-2067` | `_smooth_tilemap(brng, 3)` at `:2067` |
| 5) forest borders | `:2068-2070` | `_stamp_forest_borders(brng)` |
| Mine authority | `:2071-2076` | final `ground1` write-back |

**Detail pass internals (OBSERVED):** only cells whose id equals `grass1` are eligible (`:1927-1928`); `h < 0.1` selects low vs high bitmap (`:1929-1932`); `tex = int(pixel.r*255)/2` at `:1935`; **B03-P1** re-rolls `test7` and `test8` through donor smoothing lists (`:1936-1950`, explicit PORT APPROXIMATION at `:1936-1942`); write at `:1951-1952`. Bitmap loading at `:1903-1911`.

**Smooth pass internals (OBSERVED):** `_smooth_tilemap` horizontal-then-vertical, 3 passes at `:2263-2270`; `_tb_smooth_pair` at `:2200-2261`; `_tb_pick` at `:2170-2198` with **B03-P3** art redirect `grass_ground1/2/3 → grass9/test8/test7` at `:2183-2197` (PORT APPROXIMATION, comment `:2188-2190`).

**B03 provenance (OBSERVED):** the signature change (`_apply_detail_pass()` → `(brng)`) is `B03_diversity_impl.md:51-56`; the P2 stamp block insertion is `:88-96`; the smooth call remains step 4 at `:112`. B03 did **not** change the relative detail/smooth order; it inserted P2 between them.

**Effective 3D order (DERIVED):** base → shore → **detail** → tile stamps → **smooth** → borders → mine authority.

---

## 3. (c) Current 2D `app/scripts/game.gd` order

All paths `app/scripts/game.gd`; labels OBSERVED unless noted.

| Step | Line | Effect |
|---|---|---|
| Function entry | `:1610` | `func _assign_tileblocks()` |
| Seed / brng | `:1621-1623` | same `+7` seed |
| 1) base blocks | `:1624-1635` | every land cell `grass1` |
| Forest family | `:1649-1655` | `grass_ground1/2/3` with `0.64/0.0028/0.36` split (2D-specific) |
| Mine apron base | `:1673-1678` | `ground1` |
| 2) shore/cliffs | `:1679-1680` | `_apply_shore_cliffs()` |
| **3) SMOOTH pass** | `:1681-1682` | `_smooth_tilemap(brng, 3)` |
| **4) DETAIL pass** | `:1683-1689` | `_apply_detail_pass()` at `:1689`; comment `:1686-1688` asserts "SmoothTiles ran BEFORE it" |
| 5) forest borders | `:1690-1692` | `_stamp_forest_borders(brng)` |
| Mine authority | `:1693-1698` | final `ground1` write-back |

**Detail pass internals (OBSERVED):** only `grass1` cells (`:1595-1596`); `h < 0.1` bitmap choice (`:1597-1600`); `tex = pixel.r*255/2` at `:1603`; plain donor ids written at `:1604-1605` — **no** B03 re-roll in 2D.

**Smooth internals (OBSERVED):** `_smooth_tilemap` `:1869-1876`; `_tb_smooth_pair` `:1806-1867`; `_tb_pick` `:1787-1804`.

**Effective 2D order (DERIVED):** base → shore → **smooth** → **detail** → borders → mine authority. There is no `tiles`→`ground1` stamp block in 2D (OBSERVED: absent between `:1680` and `:1690`).

---

## 4. (d) Would flipping 3D be donor-faithful, or just cosmetic?

### 4.1 Order agreement (DERIVED)

| Variant | Relative order | Matches donor call sites? |
|---|---|---|
| Donor (authored call sites) | smooth (`:786`) → detail (`:795`) | reference |
| 2D (`app/scripts/game.gd:1682` → `:1689`) | smooth → detail | **yes**, in order only |
| 3D (`variant3d/scripts/game.gd:2039` → `:2067`) | detail → smooth | **no** — flipped |

**DERIVED:** moving `_smooth_tilemap(brng,3)` to before `_apply_detail_pass(brng)` in `variant3d/scripts/game.gd` would make 3D agree with the donor *call-site* order. That is the full extent of the donor-faithfulness established here.

### 4.2 It is NOT "just cosmetic" (DERIVED mechanics; no run performed)

1. **Eligibility changes.** Detail writes only cells still equal to `grass1` (`variant3d/scripts/game.gd:1927-1928`). With smooth first, some `grass1` cells are rewritten by `_tb_smooth_pair` (`:2200-2261`) and become ineligible; with detail first, detail-family ids instead enter the smoother and can be rewritten by `_tb_pick` (`:2170-2198`). Final `tileblock` values differ.
2. **Shared RNG stream changes.** `brng` is consumed by base draws, detail (B03-P1 `_tb_pick` at `:1943-1950`), smooth (`:2247-2259`) and borders (`:2283-2284`). Reordering changes which draws land on which decision. B03 already records that P1's extra draws shift later smoothing/border draws and change `tileblock` bytes for a given seed (`B03_diversity_impl.md:163-168`).
3. **Downstream data consumers.** `variant3d/tests/t_map_variety.gd:69-89` includes `Marshalls.raw_to_base64(g.tileblock)` in its byte summary; the dump-driven tests read `tileblock` into mesh UV2 (`variant3d/tests/t_season_overlay.gd:266-280`, `t_terrain_only.gd:268-308`). A flip changes those bytes (**DERIVED**), while same-seed determinism is preserved by construction (**DERIVED**; **UNVERIFIED** without a run).

### 4.3 It is NOT sufficient for donor fidelity (DERIVED / PORT APPROXIMATION)

- B03-P1 re-roll of bitmap `test7/test8` is an explicit **PORT APPROXIMATION** (`variant3d/scripts/game.gd:1936-1942`; `B03_diversity_impl.md:146`: "the donor does not re-roll bitmap output"). Even in donor order, 3D's detail ids would differ from donor's verbatim `tex` values.
- B03-P2 `tiles`→`ground1` stamps (`:2040-2063`) and B03-P3 art redirect (`:2183-2197`) are **PORT APPROXIMATION**; P2 sits between detail and smooth in 3D and has no 2D counterpart.
- Base distributions differ: 3D `DONOR_FOREST_BASE` (`:1997-2008`) vs 2D `grass_ground1/2/3` (`app/scripts/game.gd:1649-1655`); 2D lacks P2 entirely.
- Donor script runtime activity remains **UNVERIFIED** (§1.2), so "donor-faithful" can only describe authored call order, never verified execution or visual equivalence.

### 4.4 Explicitly UNVERIFIED

- That flipping 3D reduces the artificial patterns or moves any gate: no Godot run, no capture, no metric. `CHARTER.md:63-65` reserves runner jobs to G04; this ticket ran none.
- That 2D looks closer to donor stills as a general fact: G22's reading is INFERRED/UNVERIFIED (`G22_2d_vs_3d.md:31-37`) and its far-grass ROI is as flat as 3D (`:34-35,88`).
- Donor parity of any variant: no donor GPU A/B frame exists (`CHARTER.md:55-58,122-131`; `A08_donor_truth_local.md:274`; `G22_2d_vs_3d.md:12`).

---

## 5. Claim ledger (path:line + label)

| Claim | Evidence | Label |
|---|---|---|
| Donor parent state calls `GenerateMap` | `dogenerate.inc:1565`; `generatemap.inc:2` | OBSERVED |
| Three generation gates all `True` | `generatemap.inc:42-44` | OBSERVED |
| `TextureMap` runs first | `generatemap.inc:770-779` (call `:776`) | OBSERVED |
| `SmoothTiles` runs second and invokes 3-pass `SmoothTileMap` | `generatemap.inc:781-789` (call `:786`); `smoothtiles.inc:191-237` (`237` = 3 passes) | OBSERVED |
| Each pass = horizontal then vertical sweep | `smoothtiles.inc:197-234` (`200-215`, `218-233`) | OBSERVED |
| Smooth writes back via `SetTileIndex` | `smoothtiles.inc:240-242` | OBSERVED |
| Detail bitmap selection runs third | `generatemap.inc:791-798` (call `:795`); `loadtextureterrainfrombitmap.inc:1-2` | OBSERVED |
| Detail rule: `h<0.1`, `tex = floor(r*255) div 2`, only where index 0 | `loadtextureterrainfrombitmap.inc:4,8-9,25-29,33-36,37-41` | OBSERVED |
| Donor detail ids are not smoothed afterwards | sequence above, `generatemap.inc:786` vs `:795` | DERIVED |
| All donor code lines `;`-commented → runtime activity unknown | `generatemap.inc:770-798`, `smoothtiles.inc:191-243`, `loadtextureterrainfrombitmap.inc:4-41`; `A08_donor_truth_local.md:271`; `RV_TRN_02_smoothing_rules.md:468-478` | OBSERVED (text) + UNVERIFIED (activity) |
| `texturemap.inc` has no detail/smooth call; only `SmoothForestBorders` | `texturemap.inc:360` (full-file search) | OBSERVED |
| DTRN/A08 "detail before smooth" narrative | `DTRN_01_donor_terrain_pipeline.md:224-230,525-527`; `A08_donor_truth_local.md:145-148,234-236` | DERIVED (contradicted by call sites) |
| 3D comment asserts "bitmap base -> SmoothTiles" | `variant3d/scripts/game.gd:2036-2038` | OBSERVED (comment); claim contradicted by `generatemap.inc:781-795` |
| Current 3D order detail→smooth | `variant3d/scripts/game.gd:2039,2067` | OBSERVED |
| B03 inserted P2 between detail and smooth, kept order | `B03_diversity_impl.md:88-96,112`; `variant3d/scripts/game.gd:2040-2063` | OBSERVED |
| Current 2D order smooth→detail | `app/scripts/game.gd:1682,1689` | OBSERVED |
| 2D claims donor order in a comment | `app/scripts/game.gd:1686-1688` | OBSERVED (comment); consistent with `generatemap.inc:786/795` |
| 2D has no B03 P1/P2/P3 | `app/scripts/game.gd:1581-1605`; absent `:1680-1690`; `:1787-1804` | OBSERVED |
| Flipping 3D changes tileblock bytes / RNG outcomes | `variant3d/scripts/game.gd:1927-1928,1943-1950,2170-2198,2200-2261`; `B03_diversity_impl.md:163-168`; `t_map_variety.gd:69-89` | DERIVED |
| Flipping 3D is donor-faithful in order only | `generatemap.inc:786,795` vs `variant3d/scripts/game.gd:2039,2067` | DERIVED |
| B03 substitutions remain non-donor after any flip | `variant3d/scripts/game.gd:1936-1942,2040-2050,2183-2197`; `B03_diversity_impl.md:146` | OBSERVED (PORT APPROXIMATION labels) |
| Visual/gate effect of a flip | none measured this ticket | UNVERIFIED |
| Donor parity of either renderer | no donor GPU A/B | UNVERIFIED |

---

## 6. Scope / limitations

- READ-ONLY: only this report was written in the repo. Donor scripts were read as text under `C:\Games\Cossacks 3\data\scripts`; none was copied, executed or rendered.
- No Godot process, no `godot_runner.py` job, no test run, no code/asset/config/test/shader/JSON/git mutation. G04 remains the sole runner owner (`WAVE_G_CHARTER.md:31`).
- The donor "order" finding is about authored call sites in commented scripts. It does not prove what the shipped donor executable does at runtime (`A08_donor_truth_local.md:271`).
- No donor-parity claim, no equivalence claim, and no assertion that either order is visually better. Any change to 3D would need a G04/COORD gate + capture before any visual conclusion (`CHARTER.md:63-65,122-131`).

*End of H06 report. Read-only; one report file; no runner job; no code or asset edit; donor parity UNVERIFIED.*
