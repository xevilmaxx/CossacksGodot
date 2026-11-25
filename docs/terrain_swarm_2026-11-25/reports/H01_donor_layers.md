---
id: H01
ticket: "TERRAIN-SWARM-2026-11-25 / Wave H / H01"
task: "Trace every donor terrain data layer; classify height source vs tile-ID selector vs blend alpha vs collision/forest mask"
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_RUNNER__NO_CODE_EDIT
scope: "One report written. No runner job, no Godot process, no code/asset/config/test/git edit. Donor inspected READ-ONLY (bytes/latin-1/struct + import_donor_map.read_donor); no donor file copied, modified, executed or rendered."
donor: "C:\\Games\\Cossacks 3 (accessible READ-ONLY this ticket and re-read directly for every path:line below)"
labels: [OBSERVED, DERIVED, UNVERIFIED]
visual_parity_claim: false
---

# H01 — Every donor terrain layer and its role

## 0. Mandate and evidence discipline

Charter: `docs/terrain_swarm_2026-11-25/CHARTER.md:55-69,122-131`; Wave H assignment
`docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md:106-124`. Read-only, no runner
(G04 owns Godot), one report, **no donor-parity claim** (no donor GPU A/B frame exists).

Labels follow the charter: **OBSERVED** = literal donor line / decoded byte / measured
value re-read this ticket; **DERIVED** = deterministic consequence of cited lines;
**UNVERIFIED** = not provable from readable donor data.

Encoding note (critical for all `.inc` citations): in these donor scripts `[*] = ;`
is the live source-storage prefix, **not a comment**; `//` and `{…}` are the real
disable tokens (DPATTERN_01 §5.1, RV-SEL-01:65-83). Every `.inc` line quoted below is
therefore donor *intent*. Whether the engine executes the script at runtime is
**UNVERIFIED** in this ticket (no EXE probe, no GPU frame) — consistently flagged.

Reports used: DTRN_01, DTRN_02, DTRN_06, A08, DEC-05, DPATTERN_01 (each read in
full), plus direct donor re-reads listed in §6. All paths below are relative to
`C:\Games\Cossacks 3\` unless marked otherwise.

---

## 1. Complete layer inventory

`Visible colour?` = is the layer's own data ever read as RGB/albedo by a render
shader. `→ Height?` = does its data enter the height grid (`SetHeightData` / the
baked float32 grid), as opposed to merely *reading* height.

| # | Layer (donor path) | Role | Visible colour? | → Height? | Label |
|---:|---|---|---|---|---|
| 1 | `data\gen\terrainmasks*\**\*.tga` R channel | **(a) height** — class + amplitude | **No** (generator-only; no material binds it) | **Yes** — `generatemap.inc:567-573` | OBSERVED + UNVERIFIED(runtime) |
| 2 | same TGA B channel | **(a) height** — water-bed term + water/shore class | No | **Yes** — `:567` | OBSERVED + UNVERIFIED(runtime) |
| 3 | same TGA G channel | **(d) forest/stone placement** | No | **No** — height loop uses only R,B (`:563-573`); G decode at `:473-485` | OBSERVED |
| 4 | same TGA A channel (`fa`) | **(b) tile-ID** — road mask `broad` | No | No | OBSERVED |
| 5 | `data\maps\missions\*.map` baked `float32[W*H]` grid | **(a) height** (baked result) | No | **Yes** (is the height) | OBSERVED (decode) / UNVERIFIED(engine binding) |
| 6 | `*.map` 37-byte record array | **(b) tile-ID candidate**, *not* a proven height source | No | **No confirmed height field** | OBSERVED layout / UNVERIFIED field semantics |
| 7 | `data\pattern\*.pattern` float32 relief window | **(a) height** — authored stamp deltas | **No** — binary payload, no `image=`/`.dds` in `pattern.lib` | **Yes** (engine stamp; blend math UNVERIFIED) | OBSERVED / UNVERIFIED(blend) |
| 8 | `data\gen\bitmap\ext\tile_lowground.bmp`, `tile_highground.bmp` R | **(b) tile-ID selector** | No (only `r` integer read) | **No** — reads `h`, writes `tex` | OBSERVED text / UNVERIFIED(runtime) |
| 9 | `data\scripts\common.inc\texturemap.inc` sector/rock/road rules | **(b) tile-ID selector** | No (script, not texture) | No — reads height | OBSERVED text / UNVERIFIED(runtime) |
| 10 | `data\gen\tilesmooth_scripts.cfg` + `smoothtiles.inc` | **(b) tile-ID selector** (compatibility rewrite) | No | No | OBSERVED text / UNVERIFIED(runtime) |
| 11 | `data\terrain\tiles\textures\alpha.bmp` 8×4×64 masks | **(c) blend alpha** | **No** — shader reads only `.a` (`hf.pvl.smx3.frag:14`) | **No** | OBSERVED / UNVERIFIED(patch mapping) |
| 12 | `data\terrain\tiles\textures\alphavert.bmp` | **(c) blend alpha** (cliff faces) | No — `.a` only | No | OBSERVED |
| 13 | `data\terrain\tiles\textures\alphanull.bmp` | **(c) blend alpha** sentinel (all zero) | No | No | OBSERVED |
| 14 | `data\scripts\common.inc\texturemap.inc` collision grid / `.forest` | **(d) collision + forest mask** | No | No (collision derived *from* height) | OBSERVED text / UNVERIFIED(runtime) |
| 15 | `data\terrain\tiles\textures\*.dds` (112 tile blocks) | visible **albedo** (the contrast case) | **Yes** — `texUnit0` at `hf.pvl.smx3.frag:13` | No | OBSERVED |
| 16 | `data\water\textures\heightmapwaves0.tga` | decoy: water normal-like RGB, **not** terrain height | No (terrain) | No — alpha constant 255 | OBSERVED |

---

## 2. (a) Height sources

### 2.1 Terrain-mask TGA — R and B enter height; G does not

- Mask families and paths: `data\game\var\generator.cfg:2-28` (6 non-DLC types,
  e.g. `:6 path = .\data\gen\terrainmasks\nowater2`) and `:29-66` (9 DLC5 types).
  Census: `data\gen\terrainmasks` 1,336 files / 1,331 TGA 320×320 RLE-24;
  `.src` 1,281 / 1,279 TGA 256×256; `.dlc5` 1,861 / 1,856 TGA 320×320
  (DEC-05 §3.2 N9). **OBSERVED**.
- Decode into the per-cell mask (`generatemap.inc:400-453`): `ir=floor(fr*255)`,
  `ig=floor(fg*255)`, `ib=floor(fb*255)` at `:444-446`; `.r/.g/.b` stored at
  `:447-449`; **`:448 gMapMask[x,y].g := fg;` is live** (the later duplicate at
  `:545 //gMapMask[x,y].g := fg;` is disabled). `fa>0` → `.broad := True` at
  `:450-452`. **OBSERVED**.
- R → relief class: `generatemap.inc:454-472` (`ir` 255/191 plateau, 96/112 hill,
  48/88 ravine, 64 none/smooth; constants at `:21-27`). B → water class
  `generatemap.inc:486-490` (`ib=255`). **OBSERVED**.
- **Height formula** (`generatemap.inc:562-574`, constants `:4-7`):
  `fr = gMapMask[ix,iy].r`, `fb = gMapMask[ix,iy].b`;
  `hwater = -1.1*(fb*(1+fr*3.5))`;
  `hterrain = { 2.964*fr | 1.31733*fr | -2.964*fr | 0 }` by class;
  `SetHeightData(realx, realy, hwater+hterrain)`. Note **no `fg`/`.g` term**.
  **OBSERVED**. `generatemap.inc:541-543` samples the post-processed
  `bitmaptrg.bmp` (`:519-521`) into the same R/B fields. **OBSERVED**.
- **Never sampled as visible colour: OBSERVED negative.** Search of
  `data\materials\**` and `data\terrain\**` for `terrainmasks` → 0 hits; the only
  image bindings in `reftilealpha.mat` are the three alpha BMPs (`:30,139,248`)
  and ground albedo is bound through `tiles.mat` → `*.dds` (`hf.pvl.smx3.frag:13`).
  The mask is a generator input that *authors* height, not a texture.
- Caveat: all quoted `.inc` lines are `[*] = ;` intent text; **runtime activity
  UNVERIFIED** (consistent with DTRN_01 Q9, A08 §8 #7).

### 2.2 `.map` — baked height grid vs the 37-byte records (ticket premise corrected)

- A `float32[W*H]` height grid is decodable from every shipped map: marker
  `TerrainMapBegin` (e.g. `data\maps\missions\ausmis1.map:0x012f63ee` → `<4i 320,320,4,64>`),
  then a repeated `<w,w>` header; the grid is `w*h` float32 after the second header
  (`variant3d\tools\import_donor_map.py:113-174`; DTRN-02 C16). **Re-decoded this
  ticket**: `bonmis1.map` `w=h=320`, `cells=102400`, min `−2.9639999866485596`,
  max `+2.9639999866485596`, mean `−0.072741`. **OBSERVED** (decode) / the exact
  engine field that owns it is **UNVERIFIED**.
- **Correction:** the ticket groups "`.map` 37-byte terrain records" under height
  sources. Direct read at `ausmis1.map:0x014f4a3d` gives
  `00 00 80 3f ×4 | 00×10 | ff ff | 00 | 4e 00 4e 4e | 37 | 00×3`:
  four float32 **1.0**, padding, constant `ff ff`, **id-like bytes +29…+32**
  (`78,0,78,78` → `test8/grass1/test8/test8`), byte +33 = `55`, padding.
  This matches DEC-05 §4.5/N8 exactly (102,400 records, 37-byte stride,
  reproduced in 4 maps). These are **tile-id/attribute records, not a height
  source**; the height float32 array is a *separate* region. Which record field
  (if any) is authoritative `GetTileIndex`, and what byte +33 encodes, remain
  **UNVERIFIED** (DEC-05 Q1/Q2). **Never sampled as visible colour: OBSERVED**
  (map container, no material binding; `.map` is loaded through a Python importer,
  not a sampler).

### 2.3 `.pattern` float32 relief grids — height input, never albedo

- Format: `int32 w,h @0x00`, `w*h` u8 cell grid `@0x08`, then a row-major
  `w*h` float32 height window near `8+w*h` (DPATTERN_01 §2.1/§2.2, §7 recipe;
  exact byte offsets in §3 — e.g. `k_ravine_1` `w×h=46×63`, grid @2866,
  min/max `−2.963627576828003 / +3.139820098876953`). **OBSERVED**.
- Per-pattern sculpt config is in `data\pattern\pattern.lib` (680 sections):
  `pattern.lib:549562-549587` for `k_ravine_1` shows `HeightFieldStand=True`,
  `HeightFieldScale=1`, `HeightFieldMin/Max=-2.963627576828/3.13982009887695`,
  `HeightFieldSmooth=False`, `CollisionStand=True`, `HeightFieldOffset=0` —
  re-read verbatim this ticket. All 26 audited grids reproduce their `pattern.lib`
  min/max bit-exactly (DPATTERN_01 §4.7). **OBSERVED** / **DERIVED**.
- Placement intent: `dogenerate.inc:1621-1765` (family probabilities and
  `_misc_SetupPatternsByType`), `generator.cfg:67+` (`Freq` weights),
  `dogenerate.inc:1984-1985` (relief props skip random scaling). **OBSERVED text;
  native runtime + engine blend (`Replace`/`Smooth`, clamp order) UNVERIFIED**
  (DPATTERN_01 §5.1/§5.2; DEC-05 Q).
- **Never sampled as visible colour: OBSERVED negative.** `pattern.lib` contains
  no `image =` and no `.dds` binding for the relief window (full-file grep this
  ticket); the only `LibMaterialName` hits are decal props (e.g.
  `pattern.lib:923484 christmastreed`). Albedo for relief *props* comes from
  `data\materials\env\terrainmesh{1..4}[w].dds` via `.actor`/`.prop` and
  `actors.lib:1200-1229` (DEC-05 §3.1/§4.1) — a different asset class.
- How it reaches height: engine stamp consumes the float window as a per-cell
  height delta, labelled `PORT APPROXIMATION` in any port reading
  (`h_final = clamp(h_base + grid*scale + offset, min, max)`); the *operation*
  is **UNVERIFIED** (no plaintext consumer of these config fields: 9,520 hits
  only in `pattern.lib`, DPATTERN_01 §5.2).

---

## 3. (b) Tile-ID selectors

### 3.1 `tile_lowground.bmp` / `tile_highground.bmp`

- Assets: `data\gen\bitmap\ext\tile_lowground.bmp` and `tile_highground.bmp`,
  BMP DIB40 320×320×24, pixel offset 54 (DEC-05 §4.4/N4), R histogram 12/10
  discrete values (DEC-05 §4.4, DTRN-06 C07). **OBSERVED**.
- Selector logic (`loadtextureterrainfrombitmap.inc:6-9,25-29`): `h<0.1` → low
  bitmap, else high; `:31-36` reads `fr,fg,fb,fa`, `r=floor(fr*255)`,
  `tex = r div 2`; `:37-42` **only where `GetTileIndex(x,y)=0`**, then
  `SetTileIndex(x,y,tex)`. **OBSERVED text; all lines `[*] = ;` → runtime
  UNVERIFIED.**
- R `div 2` yields the 12/10 preset ids (low `{0,1,6,7,77,78,79,80,82,83,84,85}`,
  high `{1,7,8,9,78,79,80,83,84,85}`) = `grass1/grass2/test7/8/9/12/14` family;
  measured patch runs 1–6 cells (DEC-05 §4.4, DTRN-06 C07/C08). **DERIVED**.
- **Visible colour? NO** — the BMP itself is never bound as albedo; only its R
  integer is read, and the visible RGB comes from the DDS tile via `tiles.mat`.
  **→ Height? NO** — the layer *reads* `h` to choose a bitmap (`:25`) but its R
  value never enters `SetHeightData`. This is the decisive distinction for the
  owner's hypothesis (§5).

### 3.2 `texturemap.inc` sector / rock / road rules

- `texturemap.inc:433-447` height gradients `dirX=lh-rh`, `dirY=th-bh`,
  `VectorAngle` + sign flip → sector; `:463-471` mask `b>0` with `h<−0.25` /
  `h<−0.1`; `:474-511` 8×45° sectors → `sandsea5/6/1/...`; `:525-528` winter
  suffix + `SetTileIndex`. **OBSERVED**.
- `texturemap.inc:557-591` map edge or `GetMapCollisionTagInRadius>0` →
  `rock7/1/3/4`; `:594-601` `abs(h)>2.7→rock8`, `>2.4→rock4`, `<0.1→none`;
  `:603-608` `SetTileIndex`. **OBSERVED**.
- `texturemap.inc:617-646` `gMapMask[x,y].broad` (TGA A channel, §2.1) →
  `ground1` p=0.5 / `test2` p=0.25 / `test3` p=0.25 + `SetTileIndex`. **OBSERVED**.
- **Visible colour? NO** (script logic). **→ Height? NO** — height and mask are
  *inputs* to tile selection; the output is only `tex`. Runtime activity
  **UNVERIFIED** (`[*] = ;` intent).

### 3.3 `tilesmooth_scripts.cfg` + `smoothtiles.inc`

- `data\gen\tilesmooth_scripts.cfg:1-36` first rule re-read: `sandsea1..4 Prob=1`,
  `sandsea5=0.7`, `sandsea6=0.3`; grass rule `grass1/grass2/test8=1`,
  `grass7/test12/13/14=0.25` at `:155-190` (DTRN-06 C10). 118 active groups,
  282 `TileName`/`Prob` pairs, 86 distinct names (DEC-05 §4.6). **OBSERVED**.
- Consumer `smoothtiles.inc:4-6,42-80,126-180,191-237`: load config, roulette over
  `SumProb`, reconcile neighbours, `SmoothTileMap(...,3)` horizontal then vertical.
  **OBSERVED text; runtime UNVERIFIED.**
- **Visible colour? NO. → Height? NO.** Purely rewrites tile ids after they are set.
- Related carrier: the `.map` 37-byte record id-like bytes (+29…+32, §2.2) are an
  *additional* per-cell tile-id field, but which field is authoritative is
  **UNVERIFIED** (DEC-05 Q1) — do not overwrite `game.tileblock` from it blindly.

---

## 4. (c) Blend-alpha layers

- `alpha.bmp`: 512×256 8 bpp, data @1070 with 256-entry palette (DEC-05 §4.4);
  an 8 columns × 4 rows grid of 64×64 organic feather masks, 254 grey intensities
  (A08 §2; DTRN-06 C14/C15; commented `AlphaRows=8/AlphaCols=4/AlphaTileSize=64`
  at `reftile.lib:10-12`). **OBSERVED pixels / DERIVED grid**.
- Binding: `reftilealpha.mat:3 Name=alpha`, `:17 bmTransparency`, `:30 image=…\alpha.bmp`,
  `:31 imagealpha=tiaAlphaFromIntensity`, `:32-33 maNearest/miNearest`,
  `:35 textureformat=tfAlpha`, `:36 tmModulate` — all re-read verbatim. The tile
  material sets `reftile.mat:6 Texture2Name=alpha`, `:17 bmTransparency`,
  `:31 imagealpha=tiaDefault` (tile image alpha unused). **OBSERVED**.
- **Visible colour? NO — OBSERVED:** `hf.pvl.smx3.frag:13` reads
  `color.rgb = texture2D(texUnit0, …).rgb` (the DDS tile), `:14` reads
  `color.a = texture2D(texUnit1, …).a` **only**. `texUnit1` UV is
  `gl_MultiTexCoord1` (`hf.pvl.sm.vert:34`), written by the engine mesh builder —
  the cell→64² patch mapping (`tsDouble`/`ttExtended`/`TileXOffset`/`TileYOffset`,
  `reftile.lib:7-12`) is **CONFIRMED_UNVERIFIED** (A08 §2, DTRN-01 Q4).
- **→ Height? NO.** Alpha is an authored seam-feather opacity. No donor plaintext
  connects it to `SetHeightData` or the height grid; claiming a height role would
  be an invention.
- `alphavert.bmp` 1024×512×24 (DEC-05 §4.4); `reftilealpha.mat:139-145` binds it
  with `tiaAlphaFromIntensity`/`tfAlpha`; `reftile.mat:120-169` switches cliff
  faces to `Texture2Name=alphavert`, `TextureScale=0.125`, `mappingmode=tmmEyeLinear`,
  front S=(1,0,0,0)/T=(0,0,1,0), side S=(0,1,0,0)/T=(0,0,1,0). **OBSERVED**.
  Same `.a`-only fragment path; **no height role**.
- `alphanull.bmp` 512×256 8 bpp DIB12, all-zero (DEC-05 §4.4/N5, DTRN-06 C16);
  `reftilealpha.mat:248-254`; bound only via `alpha0a/b/c → alphanull` overrides
  (`tiles.mat:347-360`, A08 §2). Deliberate "no transition" sentinel; **no height
  role, no colour role**.
- Contrast: the 112 tile DDS are the layers actually sampled as visible RGB
  (`tiles.mat:2-141`; `hf.pvl.smx3.frag:13`). **OBSERVED**.

---

## 5. (d) Collision / forest mask — G channel and the collision grid

- G codes: `generatemap.inc:13-17,28-31` (`cGForest=1`, `cGGenForest=2`,
  `cGStone=3`, `cGForestStone=4`; image codes 255/64/128/192); decoded at
  `generatemap.inc:473-485` into `gMapMask[x,y].forest`. **OBSERVED**.
- **G does not reach height.** The height loop reads only `.r` and `.b`
  (`generatemap.inc:563-573`); the `g` assignment there is disabled (`:545`).
  **OBSERVED + DERIVED.**
- G → props, not colour: `texturemap.inc:180-218` places `n_small_frt_*` stones for
  `cGStone/cGForestStone`; `:234-330` places `b_frt_b_p_*`, `frt_b_p_*`,
  `frt_m_p_*`, `frt_s_p_*`, `n_small_frt_*` for `cGForest`; `:339-363`
  `SaveEnvironmentToBitmap`/`LoadEnvironmentFromBitmap`/`SmoothForestBorders`;
  `:365-413` `cFixPlaceForestsObjSizes` skips `terrainmesh`/`stones` basenames.
  **OBSERVED text; runtime UNVERIFIED.** **Visible colour? NO** — the mask is a
  placement field; the trees/stones have their own albedo assets.
- Collision is derived from the *same height field*, not an independent layer:
  `texturemap.inc:53-176` uses `GetHeightData` deltas with `cDiff1=0.5`/`cDiff2=0.55`
  (`:63-64`), water tag from mask `b>0 & h<−0.25` (`:66-87`), drawn on a 2× grid
  at 0.5-cell offsets (`:133-137`); grid caps `dmscript.global:78-80`, record
  `collision=Integer[4]` at `:2026-2035`. **OBSERVED**. Collision then gates *tile
  identity* at `texturemap.inc:557` (`GetMapCollisionTagInRadius>0 → rock…`), not
  height. **Never sampled as visible colour: OBSERVED** (per-cell integer, no
  material binding).
- Decoy: `data\water\textures\heightmapwaves0.tga` is named "heightmap" but has
  constant alpha 255 for all 65,536 pixels, so it cannot carry the shader's
  `hmapTex.w`; `water.mat` binds it as a commented `tfNormalMap` block
  (DEC-05 §4.3, DTRN-01 C22, A08 §8 #8). **Not a terrain height input and not
  terrain albedo. OBSERVED.**

---

## 6. Direct answer to the owner's question

> "one of the terrain layers, the one that produces strange patterns, should not
> be visible but used for heightmap only" (WAVE_G_CHARTER.md:107-109).

**Yes — but only for the layers that produce *relief*, not for the layer that
produces the visible blotchy/mottled pattern.** Split the hypothesis:

1. **Confirmed part (OBSERVED):** there ARE donor pattern-producing layers that
   are height inputs and are never drawn as albedo:
   - terrain-mask TGA **R** (relief class + amplitude) and **B** (water bed), via
     `generatemap.inc:567-573` (§2.1);
   - `.pattern` float32 relief windows (`pattern.lib:549562-549587`; grid decode
     DPATTERN_01 §2/§3), which sculpt hills/ravines/plateaus and have **no image
     binding** in `pattern.lib` (§2.3);
   - the `.map` baked float32 height grid (`import_donor_map.py:113-174`, §2.2).
   None is a texture sampled by `hf.pvl.smx3.frag:13-14`; all feed height/geometry.

2. **Refuted part for the visible pattern (OBSERVED/DERIVED):** the donor layer
   that produces the *mottled tile-identity pattern* is
   `tile_lowground.bmp`/`tile_highground.bmp` R → `tex = r div 2`
   (`loadtextureterrainfrombitmap.inc:25-42`). It is indeed **never drawn as
   albedo** (the owner is right about *invisible*), but it is a **tile-ID
   selector, not a height input**: it reads `h` to choose the bitmap and writes
   `tex`; its R never enters `SetHeightData`. Likewise `alpha.bmp`/`alphavert.bmp`
   are **blend alpha only** (`.a` at `hf.pvl.smx3.frag:14`), not height. Donor's
   visible mottling is discrete tile identity + 3-pass weighted smoothing
   (`smoothtiles.inc:191-237`, `tilesmooth_scripts.cfg:1-36`) + authored alpha
   feather — not a hidden height layer. (H03/H05 own the port-side test of the
   hypothesis against our render.)

3. **Ticket-premise correction (OBSERVED):** the `.map` **37-byte records** are
   tile-id/attribute records (four float32 1.0 + id-like bytes at +29…+32),
   **not** a height source; the height in `.map` is a separate float32 grid.
   Field semantics are **UNVERIFIED** (§2.2).

**Bottom line:** "invisible pattern-producing layer that is height-only" is true
of the *authored relief/height* layers, but the donor never renders those as
colour in the first place; the layer that would be a candidate for "stop drawing
it as albedo, feed it as height instead" — the detail bitmaps / alpha masks — is
**not** a height source in the donor. Any port change that routes a tile-ID or
alpha layer into height would be a **PORT APPROXIMATION**, not donor-grounded.
No parity claim is made; no donor GPU frame was captured.

---

## 7. Open questions (UNVERIFIED — do not promote)

1. Runtime activity of all `[*] = ;` generator/smoothing/alpha `.inc` text.
2. `gl_EyePlaneS/T[0]`, `gl_TextureMatrix[0]`, cell→64² alpha patch index,
   `bmTransparency` pass count — engine-side (A08 §8 #2/#3/#5).
3. Engine stamp blend math for `.pattern` (`HeightFieldReplace/Smooth`, clamp
   order, `HeightFieldScale=-0.925` sign) — config-only, no plaintext consumer.
4. Which `.map` 37-byte field is authoritative `tex`; what byte +33 encodes;
   how the float-array regions relate to the record block (DEC-05 Q1/Q2).
5. Height-grid→mesh LOD/tessellation and exact engine normal formula
   (DTRN-02 C14/C19).
6. Whether any runtime path samples the terrain-mask TGA as colour — no binding
   observed, but no EXE/GPU probe (negative is OBSERVED in scanned bindings,
   8 §2.1 caveat).

---

## 8. Sources

Direct donor reads this ticket (all READ-ONLY, paths relative to `C:\Games\Cossacks 3\`):
`data\scripts\common.inc\generatemap.inc:1-32,400-453,454-495,500-575`;
`data\scripts\common.inc\texturemap.inc:1-176,180-415,415-535,550-650`;
`data\scripts\common.inc\loadtextureterrainfrombitmap.inc:1-50`;
`data\shaders\obj\hf.pvl.smx3.frag:1-51`;
`data\shaders\obj\hf.pvl.sm.vert:1-50`;
`data\terrain\ref\reftile.mat:1-50,118-170`;
`data\terrain\ref\reftilealpha.mat:1-45,135-150,245-258`;
`data\scripts\dmscript.global:78-81,170-173,2026-2035`;
`data\gen\tilesmooth_scripts.cfg:1-36`;
`data\game\var\generator.cfg:1-70`;
`data\pattern\pattern.lib:549560-549590` + full-file grep for `image =`/`.dds`;
`data\maps\missions\ausmis1.map:0x014f4a3d` (37-byte record) and
`bonmis1.map` float grid via `variant3d\tools\import_donor_map.py:113-174`.

Reports read in full:
`docs/coord_swarm_2026-11-25/reports/DTRN_01_donor_terrain_pipeline.md`,
`DTRN_02_donor_terrain_geometry.md`, `DTRN_06_donor_grass_decals.md`,
`docs/coord_swarm_2026-11-25/reports/DPATTERN_01_relief_grids.md`,
`docs/coord_swarm_2026-11-25/decomp/DEC_05_terrain_formats.md`,
`docs/terrain_swarm_2026-11-25/reports/A08_donor_truth_local.md`.

*End of H01. One report written. No donor file copied/executed/rendered; no
code, asset, config, test, git or Godot-runner state changed. Visual parity not
claimed.*
