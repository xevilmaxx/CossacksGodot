# DEC-SHORE-EDGE — donor source of ids 87–90 and outer-edge stripe mechanism

Date: 2026-11-26
Scope: small READ-ONLY decomp, 3 passes max. Exactly one file written (this one). No code/Godot/git changed. Donor READ-ONLY; no binary executed or copied. Muse Spark.
Donor pinned: Craft Anything `core_session_show` + `core_targets_list` this ticket — active target `t_87f0f3c130b0` = `cossacks.exe`, 5,768,048 B, sha256 `87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c`, Deep mode. No `core_target_open/select` issued; target never changed.
Context: after neutral alpha on ids 93/97/98, close sequence `donor_64_shorealpha2/frame_0012.png` shows central sandsea continuous but outer sand/grass edge still shows repeated narrow parallel stripes. 64² diagnostic histogram: 3585 tile0 plus 87/88/89/90/93/97/98. Prior reports `DEC_SMALL_shore_rings.md`, `PHOTO_LED_chevron_ab.md`, `PHOTO_SEQUENCE_review.md`. No parity claim. `[U]` = unresolved, stated exactly.

## 1. Donor source of ids 87–90 — exact tile and style [O]

F05 §3 table (verified this ticket against donor text):

| id | name | atlas cell | donor bitmap | port PNG kind |
|---:|---|---|---|---|
| 87 | `sandrock1` | (7,5) | `.\data\terrain\tiles\textures\sandrock1.dds` | DIRECT |
| 88 | `sandrock2` | (8,5) | `sandrock2.dds` | DIRECT |
| 89 | `sandrock3` | (9,5) | `sandrock3.dds` | DIRECT |
| 90 | `sandrock4` | (10,5) | `sandrock4.dds` | DIRECT |

- `terrain.presets:93-96` order fixes ids 87–90 (`sandrock1..4`); `:99/:103/:104` fix `sandsea1=93`, `sandsea5=97`, `sandsea6=98` (F05 E01).
- `tiles.mat:361-376`: each of `sandrock1..4` is `section.begin {refurl=.\data\terrain\ref\reftile.mat; refkey=normal}` binding its own `sandrockN.dds`. Same refkey/style as `sandsea1..6` (`:385-408`): ground UV, `Texture2Name=alpha` via `reftile.mat:1-108` (`normal`), `bmTransparency`, `maNearest/miNearestMipmapLinear`. Never `verticalfront/side`, never `alphavert`.
- `tiles.lib:352-363`: `sandrock1..4` sections carry only `TileBlockName`, no `AngleX/AngleZ`, no `TileSize/Rows/Cols` override — i.e. default `reftile.lib:2-12` (`tsDouble`, `ttExtended`, offsets 0.1/0.2). Ground tiles, not faces.
- So style = normal ground photograph + `alpha.bmp` crossfade, exactly like the sandsea shore tiles.

## 2. Live script, smoothing list, or another stage

- Live shore paint is NOT sandrock. `texturemap.inc:503-511` paints only three textures: `bB/bT→sandsea1`, `bLB/bRT→sandsea5`, `bR/bRB/bL/bLT→sandsea6` (all `;`-commented text intent, runtime `[U]`; X28 M-tables). No `sandrock*` appears in `texturemap.inc` (grep of `common.inc` this ticket: only the 8 `sandsea` lines above).
- Smoothing Item 0 alone is commented — this is what `DEC_SMALL_shore_rings.md` §6.2 reported, and it is incomplete. `tilesmooth_scripts.cfg:37-50` (chain C00, Item 0) comments out only the `sandrock1/3` group; the same file has LIVE sandrock groups in the very next chains:
  - C01 (`:97-192`): g0 `sandsea1-4` (1.0) → g1 `sandsea5/6` (0.7/0.3) → g2 `sandrock1(0.4)/sandrock3(0.6)` (`:131-142`) → g3 `sandrock4(0.6)/sandrock2(0.4)` (`:143-154`) → g4 `grass1/grass2/test8` → g5 `grass7/test12/13/14`.
  - C02 (`:193-284`) and C03 (`:285-…`): identical g0–g3 sandsea→sandrock layout, different grass tails (`:227-282`, `:319-342`).
  - Winter mirrors C12–C14 carry `sandrockN_winter` (`:1064-1080`, `:1160-1176`, `:1252-1268`).
- Mechanism `[D]` (X08 §5.4–5.5): a chain is an ordered compatibility sequence; smoothing replaces the farther-from-water side from `nearer+1` when distance >2, or the middle group when distance =2. A `sandsea*` cell adjacent to a `grass*` cell shares only C01/C02/C03-class chains, at distance 3–4, so the engine inserts the intermediate groups g2/g3 — i.e. ids 87–90 — as a one-cell transition band. That is the donor origin of the outer 87–90 ring: **live smoothing intermediates, not live shore paint, not the commented Item-0 block**.
- Correction to prior art: `DEC_SMALL_shore_rings.md` §6.2 ("the only sandrock smoothing list is commented out") holds only for C00/Item 0. Live C01+ lists above supersede it for 87–90. `miscext.script:1490-1492` (`_misc_SetDesert`: `sandrock2/3/4→sandsea6/5/5`) is a desert-season remap, not the skirmish-shore stage — cited only to exclude it.

## 3. Why a one-cell 87–90 ring renders as many narrow stripes

Port facts cited, not modified (read-only inspection):

- Mesh: vertices at cell centres `(x+0.5)/w` world XZ (`world3d_terrain.gd:1310-1314`); one fixed diagonal per quad (`:1415-1418`). Tile id rides `UV2.x → v_tile = UV2.x` (`terrain_tileindex.gdshader:324`) with no `flat` qualifier, so the fragment interpolates a discrete id across each triangle edge.
- RGB: `tile_rgb` (`:329-338`) looks up `(cell+uv)/grid` with `cell=(idx%16,idx//16)` and `fract(v_st*0.5)` (2 m repeat from `gc_meters_to_tile=2`) plus an invented `0.125*sin/cos(dot(v_st,…))` warp (`:334`) and half-texel inset (`:335-336`).
- Mask: `alpha_patch_uv` (`:365-378`) hashes the id (`dir=id%4, variant=(id/4)%4, half=(id/16)%2, opposite=(id/64)%2` + 180° mirror) and samples a different 64² `alpha.bmp` sub-rect per id at `fract(v_alpha_uv)` (`:417`), then the pre-neutral shader folded it into RGB. Neutral-alpha already fixed 93/97/98 (centre now continuous); 87–90 still carry per-id sub-rects and the RGB fold on this capture path.

Mechanism `[D]`:

1. Donor intent is one discrete transition cell per edge (87 vs 88 vs 89 vs 90 chosen by roulette 0.4/0.6 from g2/g3). The port keeps the correct discrete ids (histogram proves it) but interpolates `v_tile` across the shared triangle diagonal, so fragments between an 87 cell and neighbouring grass/sandsea sweep fractional ids (e.g. 87.x) that address neighbouring atlas cells mid-pixel — one logical edge becomes a ramp through several photographs.
2. Each of 87/88/89/90 hashes to a different alpha sub-rect and (pre-fix path) a different brightness fold, so adjacent ring cells get different gains; world-continuous `fract(v_st*0.5)` then slices each 1024² sandrock photo into multiple 2 m bands inside a single tile-id cell, and the `0.125` warp shifts that phase per world position (no donor counterpart; donor filtering is `maNearest/miNearestMipmapLinear`).
3. Centre-sampled heights with a single fixed diagonal quantise the smooth `atan2` shore circle into axis-aligned stairsteps, stretching (1)+(2) into long parallel bands at close camera. Central sandsea is now flat because its three ids were neutralised to `a=1.0`; the outer sandrock ring still modulates, so only it still stripes. This matches PHOTO_SEQUENCE observation 3 exactly.

## 4. Donor-grounded port change (no invented constants)

Existing files only; reuse literals/ids already in repo; add no foam/tint/noise/threshold:

1. `variant3d/shaders/terrain_tileindex.gdshader` — extend the existing shore neutral already applied to 93/97/98 to the four smoothing-transition ids resolved from the manifest already loaded in GDScript (`sandrock1..4` = 87–90, F05 §3; `smooth_summer.json` chain g2/g3): bypass `alpha_patch_uv` + RGB fold on that path and set `a=1.0` (opaque donor base RGB, `ALPHA=1.0` unchanged). Rationale: donor tile→patch rule is CONFIRMED_UNVERIFIED (F05 G4/U3, F06 U-F06-1); the id hash is the stripe amplifier. No new art, no new number.
2. Same shader `tile_rgb (:334)`: delete the `0.125*sin/cos` warp (no donor counterpart). Keep donor-grounded `fract(v_st*0.5)` 2 m repeat and half-texel inset.
3. Same shader varyings: make the tile-id discrete across cell borders (round `v_tile` to the nearest manifest id / flat-shade the id, donor `MapGetTileIndexByTileBlock`/`SetTileIndex` writes one integer per cell, `texturemap.inc:527-528`). Do not invent a blend width — a hard discrete select with the existing `alpha.bmp` crossfade path disabled per (1) reproduces donor base photographs without creating new intermediate cells. True water/foam and neighbour-aware `MultiTexCoord1` stay out of scope until donor patch rule is recovered.

Verify by re-capturing the same close camera at 64² and comparing the PHOTO A/B ROIs (luma std, gradient, 24/48 autocorrelation, anisotropy): ids 87–90/93/97/98 histogram must be unchanged, banding metrics must fall. Central sandsea must stay continuous.

## 5. `[U]` precisely

1. Runtime execution of the whole `texturemap.inc:426-530` block and of `SmoothTileMap(0,0,W,H,3)` (`smoothtiles.inc:237`) — all `;`-commented text intent `[O]`, activity `[U]`; `TileSmoothPasses=6` vs script `3` contradiction preserved (X08 C2).
2. Which smoothing chain instance (C01 vs C02 vs C03+) painted each specific 87–90 cell in the 64² capture — chains share identical g0–g3; groups distinguishable only by grass tail, not readable from the shore ROI.
3. Donor tile→`alpha.bmp` patch rule, `tsDouble/ttExtended/TileXOffset=0.1/TileYOffset=0.2` arithmetic, `tiaAlphaFromIntensity` formula (F05 U3, F06 U-F06-1/3).
4. `bmTransparency` GL factors/equation/pass count (F06 U-F06-2); port single `blend_mix` + RGB fold stays PORT APPROX.
5. Donor metres-per-cell for any screen-space stripe width; depth-space shore band is `0.15` height units (`-0.1 minus -0.25`) only.
6. Native `VectorAngle` return convention beyond X28 `atan2` derivation (cardinals insensitive).
7. Any visual parity: no donor GPU A/B frame exists; this report makes none.

*End of DEC_SHORE_EDGE. Donor read-only; Craft Anything target `t_87f0f3c130b0` verified but never opened, executed, or copied.*
